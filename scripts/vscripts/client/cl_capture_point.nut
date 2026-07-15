//********************************************************************************************
//	capture_point mp gametype client script
//********************************************************************************************

const TEAM_NEUTRAL = 0
const TEAM_FRIENDLY = 1
const TEAM_ENEMY = 2

captureAnnouceSounds_Win <- {}
captureAnnouceSounds_Win[0] <- "mp_domination_wona"
captureAnnouceSounds_Win[1] <- "mp_domination_wonb"
captureAnnouceSounds_Win[2] <- "mp_domination_wonc"
captureAnnouceSounds_Win[3] <- "mp_domination_won"

captureAnnouceSounds_Lose <- {}
captureAnnouceSounds_Lose[0] <- "mp_domination_losta"
captureAnnouceSounds_Lose[1] <- "mp_domination_lostb"
captureAnnouceSounds_Lose[2] <- "mp_domination_lostc"
captureAnnouceSounds_Lose[3] <- "mp_domination_lost"

capturePointColor <- {}
capturePointColor[ TEAM_NEUTRAL ] <- StringToColors( CAPTURE_POINT_COLOR_NEUTRAL )
capturePointColor[ TEAM_ENEMY ] <- StringToColors( CAPTURE_POINT_COLOR_ENEMY )
capturePointColor[ TEAM_FRIENDLY ] <- StringToColors( CAPTURE_POINT_COLOR_FRIENDLY )
capturePointColor[ "TEAM_ENEMY_CAP" ] <- StringToColors( CAPTURE_POINT_COLOR_ENEMY_CAP )
capturePointColor[ "TEAM_FRIENDLY_CAP" ] <- StringToColors( CAPTURE_POINT_COLOR_FRIENDLY_CAP )

const CAPTURE_POINT_UI_UPDATE = "CapturePointUIUpdate"

function main()
{
	Globalize( CapturePoint_AddPlayer )
	Globalize( ShowHardpointIcons )
	Globalize( HideHardpointIcons )
	Globalize( GetFgColorState )
	Globalize( GetBgColorState )
	Globalize( UpdateHardPointCaptureBar )
	Globalize( VarChangedCallback_GameStateChanged )
	Globalize( HardpointChanged )
	Globalize( OnHardpointCockpitCreated )
	Globalize( HardpointEntityChanged )
	Globalize( GetNumOwnedHardpoints )
	Globalize( GetHardpointCount )

	RegisterServerVarChangeCallback( "gameState", VarChangedCallback_GameStateChanged )

	AddPlayerFunc( Bind( CapturePoint_AddPlayer ) )

	RegisterSignal( "HardpointCaptureStateChanged" )
	RegisterSignal( CAPTURE_POINT_UI_UPDATE )

	AddCreateCallback( "info_hardpoint", OnHardpointCreated )

	level.hardpointIDsToOwner <- {}
}

// INITIALIZATION

function CapturePoint_AddPlayer( player )
{
	if ( "hardpointArray" in player.s )
		return
	//---------------------------------------------
	// Create HUD elements for capturing capture points
	//---------------------------------------------
	player.s.captureBarData <- {
		startProgress = null
		goalProgress = null
		durationToCapture = null
		color = null
		labelText = null
		statusText = null
		isVisible = null
		arrowCount = null
	}

	player.s.hardpointsHidden <- true
	player.s.hardpointArray <- []

	file.captureBarAnchor <- HudElement( "CaptureBarAnchor" )
}

function OnHardpointCreated( hardpoint, isRecreate )
{
	hardpoint.s.previousOwnerTeam <- -1	// force the icons etc to be updated on connect
	hardpoint.s.currentProgress <- 0
	hardpoint.s.lastOwner <- null
	hardpoint.s.pulseSpeed <- null

	hardpoint.s.startProgress <- null
	hardpoint.s.goalProgress <- null
	hardpoint.s.durationToCapture <- null
	hardpoint.s.color <- null

	//---------------------------------------------
	// Create icons for the capture points
	// The have unique names but the same icons
	// Also adds status indicator to the HUD
	//---------------------------------------------

	InitializeHardpoint( hardpoint )
}

function InitializeHardpoint( hardpoint )
{
	local player = GetLocalViewPlayer()
	if ( !player )
		return

	// cleared?
	local index = hardpoint.GetHardpointID()
	if ( index < 0 )
		return

	// why would this have to be here? Because the hardpoint might get created before the player? seems bad
	if ( !( "hardpointArray" in player.s ) )
		CapturePoint_AddPlayer( player )

	if ( "storedIndex" in hardpoint.s )
	{
		Assert( hardpoint.s.storedIndex == index, "Hardpoint with oldindex " + hardpoint.s.storedIndex + " changed to " + index )
		return
	}

	// store the index so we can change it -1 to disable the hardpoint and restore it later.
	hardpoint.s.storedIndex <- index

	Assert( player.s.hardpointArray.len() <= 3 )

	hardpoint.s.worldIcon <- HudElementGroup( "CapturePoint_" + index )
	hardpoint.s.worldIcon.CreateElement( "CapturePointIcon_" + index )
	hardpoint.s.progressBar <- hardpoint.s.worldIcon.CreateElement( "CapturePointIconBG_" + index )
	hardpoint.s.statusText <- HudElement( "CaptureBarStatus_" + index )
	hardpoint.s.labelText <- HudElement( "CaptureBarLabel_" + index )

	UpdateHardpointIconPosition( player, hardpoint )
	hardpoint.s.worldIcon.Show()

	if ( !( index in level.hardpointIDsToOwner ) )
		level.hardpointIDsToOwner[index] <- null

	level.hardpointIDsToOwner[ index ] = hardpoint.GetTeam()

	//---------------------------------------------
	// Set up data about the hardpoint
	//---------------------------------------------

	player.s.hardpointArray.append( hardpoint )

	HardpointChanged( hardpoint )
}
Globalize( InitializeHardpoint )

function HideHardpointHUD( hardpoint )
{
	// hardpoint hasn't been setup yet?
	if ( !( "storedIndex" in hardpoint.s ) )
		return

	hardpoint.s.worldIcon.Hide()
	hardpoint.s.progressBar.Hide()
	hardpoint.s.statusText.Hide()
	hardpoint.s.labelText.Hide()
}
Globalize( HideHardpointHUD )

function ShowHardpointHUD( hardpoint )
{
	hardpoint.s.worldIcon.Show()
	hardpoint.s.progressBar.Show()
	hardpoint.s.statusText.Show()

	local player = GetLocalViewPlayer()
	local currentHardpoint = player.GetHardpointEntity()
	if ( hardpoint == currentHardpoint )
		hardpoint.s.labelText.Show()
	else
		hardpoint.s.labelText.Hide()
}
Globalize( ShowHardpointHUD )

function UpdateHardpointIconPosition( player, hardpoint )
{
	local terminal = hardpoint.GetTerminal()
	Assert( terminal, "No terminal" )

	if ( player.GetHardpointEntity() != hardpoint )
	{
		// attach icon hud element to the hardpoint at the location of the ICON attachment of the terminal
		// offset is based on a box of 120 x 80 and a icon 48 x 48 in the lower left corner
		local id = terminal.LookupAttachment( "ICON" )
		local offset = terminal.GetAttachmentOrigin( id ) - terminal.GetOrigin()

		local worldIcon = hardpoint.s.worldIcon
		local statusText = hardpoint.s.statusText

		worldIcon.SetEntity( terminal, offset, 0.5, 1.0 )
		worldIcon.SetClampToScreen( CLAMP_RECT )
		worldIcon.SetADSFade( deg_cos( 5 ), deg_cos( 2 ), 0, 1 )
		worldIcon.SetWorldSpaceScale( 1.0, 0.7, 500, 3500 )
		//hardpoint.s.statusText.Hide()
		statusText.SetEntity( terminal, offset, 0.5, 0.0 )
		statusText.SetClampToScreen( CLAMP_RECT )
		statusText.SetFOVFade( deg_cos( 40 ), deg_cos( 15 ), 0, 1 )
		statusText.SetADSFade( deg_cos( 5 ), deg_cos( 2 ), 0, 1 )
		statusText.Show()

		hardpoint.s.labelText.Hide()
	}
	else
	{
		local worldIcon = hardpoint.s.worldIcon
		local statusText = hardpoint.s.statusText

		worldIcon.SetEntity( null, Vector( 0, 0, 0 ), 0.5, 0.5 )
		worldIcon.SetClampToScreen( CLAMP_RECT )
		worldIcon.SetADSFade( 0, 0, 1, 1 )
		worldIcon.SetWorldSpaceScale( 1, 1, 0, 0 )
		worldIcon.SetScale( 1.0, 1.0 )
		worldIcon.FadePanelOverTime( 255, 0.15 )

		local xPos = file.captureBarAnchor.GetAbsX() - (worldIcon.GetWidth() / 2)
		local yPos = file.captureBarAnchor.GetAbsY()

		hardpoint.s.worldIcon.MoveOverTime( xPos, yPos, 0.15, INTERPOLATOR_DEACCEL )

		xPos = file.captureBarAnchor.GetAbsX() - (statusText.GetWidth() / 2)
		yPos = file.captureBarAnchor.GetAbsY() + worldIcon.GetHeight()

		statusText.MoveOverTime( xPos, yPos, 0.15, INTERPOLATOR_DEACCEL )
		statusText.SetEntity( null, Vector( 0, 0, 0 ), 0.5, 0.5 )
		statusText.Show()
		statusText.SetADSFade( 0, 0, 1, 1 )
		statusText.FadePanelOverTime( 255, 0.15 )
		hardpoint.s.labelText.Show()
	}
}


// DOESNT NEED COCKPIT

function UpdateHardpointVisibility()
{
	local player = GetLocalViewPlayer()

	if ( !GamePlaying() || player.s.hardpointsHidden )
	{
		foreach ( hardpoint in player.s.hardpointArray )
		{
			HideHardpointHUD( hardpoint )
		}
	}
	else
	{
		foreach ( hardpoint in player.s.hardpointArray )
		{
			ShowHardpointHUD( hardpoint )
		}
	}
	level.ent.Signal( CAPTURE_POINT_UI_UPDATE )
}

function HideHardpointIcons( player )
{
	player.s.hardpointsHidden = true
	UpdateHardpointVisibility()
}

function ShowHardpointIcons( player )
{
	player.s.hardpointsHidden = false
	UpdateHardpointVisibility()
}

function HardpointEntityChanged( player )
{
	if ( player != GetLocalViewPlayer() )
		return

	foreach ( hardpoint in player.s.hardpointArray )
	{
		UpdateHardpointIconPosition( player, hardpoint )
	}

	local hardpoint = player.GetHardpointEntity()

//	if we skip this we don't get the flash of "Contested" before the correct status text shows up under the icon.
//	the text will remain the distance and change when ClientCodeCallback_OnHardpointChanged happens one frame later.
//	if ( hardpoint )
//		HardpointChanged( hardpoint )
}

function HardpointChanged( hardpoint )
{
	if ( !hardpoint.Enabled() )
		return

	local index = hardpoint.GetHardpointID()
	level.hardpointIDsToOwner[ index ] = hardpoint.GetTeam()

	local player = GetLocalViewPlayer()
	if ( !IsValid( player ) )
		return

	local powerTable = GetCapPower( hardpoint )
	local cappingTeam = powerTable.strongerTeam

	local color = GetColorForTeam( hardpoint, cappingTeam )
	local IconName = GetIconNameForTeam( hardpoint.GetTeam(), hardpoint.GetHardpointID() )

	local worldIcon = hardpoint.s.worldIcon
	local capturePointIcon = worldIcon.GetElement( "CapturePointIcon_" + index ) // gotta be a better way

	capturePointIcon.SetImage( IconName )
	//capturePointIcon.SetColor( color.r, color.g, color.b )

	SmartGlass_UpdateHardpoint( hardpoint, cappingTeam )
	UpdateHardpointLabelAndColor( player, hardpoint, cappingTeam )

	local pulsate = false
	if ( hardpoint.GetHardpointState() == CAPTURE_POINT_STATE_CAPPING )
	{
		if ( powerTable.strongerTeam != hardpoint.GetTeam() )
			pulsate = true
	}

	local worldIcon = hardpoint.s.worldIcon

	if ( pulsate )
	{
		local modifier = Graph( powerTable.power, 0, 5, 1, 2 )
		local pulseSpeed = CAPTURE_POINT_MAX_PULSE_SPEED * modifier
		//worldIcon.SetPulsate( 0.1, 0.95, pulseSpeed )
		hardpoint.s.pulseSpeed = pulseSpeed
	}
	else
	{
		//worldIcon.ClearPulsate()
		//worldIcon.SetAlpha( 240 )
		hardpoint.s.pulseSpeed = null
	}

	HardpointProgressBarUpdate( player, hardpoint, cappingTeam )

	if ( hardpoint.s.durationToCapture )
		hardpoint.s.progressBar.SetBarProgressOverTime( hardpoint.s.startProgress, hardpoint.s.goalProgress, hardpoint.s.durationToCapture )
	else
		hardpoint.s.progressBar.SetBarProgress( hardpoint.s.startProgress )

	hardpoint.s.progressBar.SetColor( hardpoint.s.color.r, hardpoint.s.color.g, hardpoint.s.color.b, hardpoint.s.color.a )

	level.ent.Signal( CAPTURE_POINT_UI_UPDATE )
}

function HardpointProgressBarUpdate( player, hardpoint, cappingTeam )
{
	UpdateCapturePointEnemyCount( player, hardpoint )
	local estCaptureTime = hardpoint.GetEstimatedCaptureTime()
	local progressRefPoint = hardpoint.GetHardpointProgressRefPoint()
	local startProgress = fabs( progressRefPoint )
	local durationToCapture = estCaptureTime - Time()

	local goalProgress = 0
	if ( progressRefPoint == 0 && durationToCapture < 0 )
		goalProgress = 0
	else if ( cappingTeam == TEAM_IMC && progressRefPoint <= 0 )
		goalProgress = 1.0
	else if ( cappingTeam == TEAM_MILITIA && progressRefPoint >= 0 )
		goalProgress = 1.0

	if ( estCaptureTime > 0 )
	{
		if ( hardpoint == player.GetHardpointEntity() )
		{
			player.s.captureBarData.startProgress = startProgress
			player.s.captureBarData.goalProgress = goalProgress
			player.s.captureBarData.durationToCapture = durationToCapture
		}

		hardpoint.s.startProgress = startProgress
		hardpoint.s.goalProgress = goalProgress
		hardpoint.s.durationToCapture = durationToCapture
	}
	else
	{
		if ( hardpoint == player.GetHardpointEntity() )
		{
			player.s.captureBarData.startProgress = startProgress
			player.s.captureBarData.goalProgress = null
			player.s.captureBarData.durationToCapture = null
		}

		hardpoint.s.startProgress = startProgress
		hardpoint.s.goalProgress = null
		hardpoint.s.durationToCapture = null
	}
}

function UpdateCapturePointEnemyCount( player, hardpoint )
{
	local text = ""
	local enemyCount = GetEnemyCount( hardpoint, player )
	local friendlyCount = GetFriendlyCount( hardpoint, player )
	local powerTable = GetCapPower( hardpoint )

	//local arrowsUp = [ "#HUD_ARROWS_UP_1", "#HUD_ARROWS_UP_2", "#HUD_ARROWS_UP_3"]
	//local arrowsDown = [ "#HUD_ARROWS_DOWN_1", "#HUD_ARROWS_DOWN_2", "#HUD_ARROWS_DOWN_3"]
	local arrowsUp = [ "#HUD_ARROWS_UP_1", "#HUD_ARROWS_UP_2", "#HUD_ARROWS_UP_3"]
	local arrowsDown = [ "#HUD_ARROWS_DOWN_1", "#HUD_ARROWS_DOWN_2", "#HUD_ARROWS_DOWN_3"]
	local arrowCount = floor( GraphCapped( powerTable.power, 0, CAPTURE_POINT_MAX_CAP_POWER, 0, 2 ) )

	local state = hardpoint.GetHardpointState()

	if ( hardpoint == player.GetHardpointEntity() )
	{
		if ( hardpoint.s.statusText.IsAutoText() )
			hardpoint.s.statusText.DisableAutoText()

		if ( hardpoint.GetTeam() == player.GetTeam() && enemyCount == 0 && state == CAPTURE_POINT_STATE_CAPTURED )
		{
				hardpoint.s.statusText.SetText( "#HUD_SECURED" )
		}
		else if ( powerTable.contested && state == CAPTURE_POINT_STATE_CAPPING )
		{
			if ( hardpoint.GetTeam() == TEAM_UNASSIGNED )
			{
				if ( powerTable.strongerTeam == player.GetTeam() )
				{
					hardpoint.s.statusText.SetText( "#HUD_CONTESTED_ARROWS_UP", arrowsUp[ arrowCount ], "" )
				}
				else
				{
					hardpoint.s.statusText.SetText( "#HUD_CONTESTED_ARROWS_DOWN", arrowsDown[ arrowCount ], "" )
				}
			}
			else
			{
				if ( powerTable.strongerTeam == hardpoint.GetTeam() )
				{
					hardpoint.s.statusText.SetText( "#HUD_CONTESTED_ARROWS_UP", arrowsUp[ arrowCount ], "" )
				}
				else
				{
					hardpoint.s.statusText.SetText( "#HUD_CONTESTED_ARROWS_DOWN", arrowsDown[ arrowCount ], "" )
				}
			}
		}
		else if ( state == CAPTURE_POINT_STATE_CAPPING )
		{
			if ( CAPTURE_POINT_TITANS_BREAK_CONTEST )
			{
				if ( powerTable.strongerTeam == player.GetTeam() )
				{
					if ( hardpoint.GetTeam() != TEAM_UNASSIGNED && hardpoint.GetTeam() != player.GetTeam() )
					{
						hardpoint.s.statusText.SetText( "#HUD_NEUTRALIZING_ARROWS_UP", arrowsUp[ arrowCount ], "" )
					}
					else
					{
						hardpoint.s.statusText.SetText( "#HUD_CAPTURING_ARROWS_UP", arrowsUp[ arrowCount ], "" )
					}
				}
				else
				{
					hardpoint.s.statusText.SetText( "#HUD_LOSING_ARROWS_DOWN", arrowsDown[ arrowCount ], "" )
				}
			}
			else
			{
				if ( hardpoint.GetTeam() == TEAM_UNASSIGNED || powerTable.strongerTeam == hardpoint.GetTeam() )
				{
					hardpoint.s.statusText.SetText( "#HUD_CAPTURING_ARROWS_UP", arrowsUp[ arrowCount ], "" )
				}
				else
				{
					hardpoint.s.statusText.SetText( "#HUD_CAPTURING_ARROWS_DOWN", arrowsDown[ arrowCount ], "" )
				}
			}
		}
		else
		{
			hardpoint.s.statusText.SetText( "#HUD_CONTESTED" )
		}
	}
	else
	{
		player.s.captureBarData.statusText = "#HUD_DISTANCE_METERS"
		hardpoint.s.statusText.SetAutoTextVector( "#HUD_DISTANCE_METERS", HATT_DISTANCE_METERS, hardpoint.GetOrigin() )
		hardpoint.s.statusText.SetText( "" )

		if ( !hardpoint.s.statusText.IsAutoText() )
			hardpoint.s.statusText.EnableAutoText()
	}

	level.ent.Signal( CAPTURE_POINT_UI_UPDATE )
}

function GetIconNameForTeam( team, hardpointID )
{
	local iconName
	local iconIdString = GetHardpointIcon( hardpointID )

	if ( team == TEAM_UNASSIGNED )
		iconName = "HUD/capture_point_status_round_grey_" + iconIdString
	else if ( team == GetLocalViewPlayer().GetTeamNumber() )
		iconName = "HUD/capture_point_status_round_blue_" + iconIdString
	else
		iconName = "HUD/capture_point_status_round_orange_" + iconIdString

	return iconName
}

function GetBgColorState( hardpoint )
{
	// return neutral = 0, friendly = 1, enemy = 2
	// based solely on who controls the hardpoint

	local hardpointTeam = hardpoint.GetTeam()
	local playerTeam = GetLocalViewPlayer().GetTeamNumber()

	if ( hardpointTeam == TEAM_UNASSIGNED )
		return TEAM_NEUTRAL
	else if ( hardpointTeam == playerTeam )
		return TEAM_FRIENDLY
	else
		return TEAM_ENEMY
}

function GetFgColorState( hardpoint, cappingTeam )
{
	// return neutral = 0, friendly = 1, enemy = 2
	// based on what the progressRefPoint is etc.

	local playerTeam = GetLocalViewPlayer().GetTeamNumber()
	local progressRefPoint = hardpoint.GetHardpointProgressRefPoint()

	/*
		the bar will be blue if the progressRefPoint is closer to the friendly side.
		the bar will be red if the progressRefPoint is closer to the enemy side.
		if progressRefPoint is 0 the bar will be blue if the player is on the capping team
		and red if he is not on the capping team.
	*/

	// if the progress bar is on the side of the opposing team return 'enemy'
	if ( playerTeam == TEAM_IMC && progressRefPoint > 0 )
		return TEAM_ENEMY
	if ( playerTeam == TEAM_MILITIA && progressRefPoint < 0 )
		return TEAM_ENEMY
	if ( progressRefPoint == 0 && cappingTeam == GetOtherTeam( playerTeam ) )
		return TEAM_ENEMY

	return TEAM_FRIENDLY
}

function GetColorForTeam( hardpoint, cappingTeam )
{
	local colorState = GetFgColorState( hardpoint, cappingTeam )
	return capturePointColor[ colorState ]
}

function UpdateHardpointLabelAndColor( player, hardpoint, cappingTeam )
{
	// sets the color of the bar for the local players team
	local team = hardpoint.GetTeam()
	local color = GetColorForTeam( hardpoint, cappingTeam )
	if ( hardpoint == player.GetHardpointEntity() )
	{
		player.s.captureBarData.color = color
		player.s.captureBarData.labelText = GetHardpointName( hardpoint.GetHardpointID() )
	}

	hardpoint.s.labelText.SetText( GetHardpointName( hardpoint.GetHardpointID() ) )
	hardpoint.s.color = color

	level.ent.Signal( CAPTURE_POINT_UI_UPDATE )
}


function VarChangedCallback_GameStateChanged()
{
	level.ent.Signal( CAPTURE_POINT_UI_UPDATE )
}


// THIS SECTION DRAWS ON THE COCKPIT

function OnHardpointCockpitCreated( cockpit, panel, scoreGroup )
{
	Assert( GameModeHasCapturePoints() )

	cockpit.s.hardpointStatus_a <- scoreGroup.CreateElement( "ScoresHardpointFill_A", panel )
	cockpit.s.hardpointStatusBGA <- scoreGroup.CreateElement( "ScoresHardpointBg_A", panel )
	cockpit.s.hardpointStatusFG_a <- scoreGroup.CreateElement( "ScoresHardpointFg_A", panel )

	cockpit.s.hardpointStatus_b <- scoreGroup.CreateElement( "ScoresHardpointFill_B", panel )
	cockpit.s.hardpointStatusBGB <- scoreGroup.CreateElement( "ScoresHardpointBg_B", panel )
	cockpit.s.hardpointStatusFG_b <- scoreGroup.CreateElement( "ScoresHardpointFg_B", panel )

	cockpit.s.hardpointStatus_c <- scoreGroup.CreateElement( "ScoresHardpointFill_C", panel )
	cockpit.s.hardpointStatusBGC <- scoreGroup.CreateElement( "ScoresHardpointBg_C", panel )
	cockpit.s.hardpointStatusFG_c <- scoreGroup.CreateElement( "ScoresHardpointFg_C", panel )

	cockpit.s.hardpointStatus_a.Show()
	cockpit.s.hardpointStatusBGA.Show()
	cockpit.s.hardpointStatusFG_a.Show()

	cockpit.s.hardpointStatus_b.Show()
	cockpit.s.hardpointStatusBGB.Show()
	cockpit.s.hardpointStatusFG_b.Show()

	cockpit.s.hardpointStatus_c.Show()
	cockpit.s.hardpointStatusBGC.Show()
	cockpit.s.hardpointStatusFG_c.Show()

	cockpit.s.captureBarGroup <- HudElementGroup( "captureBar" )

	thread CapturePointUpdateCockpitThread( cockpit )
}

function CapturePointUpdateCockpitThread( cockpit )
{
	local player = GetLocalViewPlayer()
	if ( cockpit != player.GetCockpit() )
		return

	player.EndSignal( "OnDestroy" )
	cockpit.EndSignal( "OnDestroy" )

	for ( ;; )
	{
		level.ent.WaitSignal( CAPTURE_POINT_UI_UPDATE )
		UpdateHardpointIcons( player, cockpit )
		UpdateHardPointCaptureBar( player, cockpit )
	}
}

function UpdateHardpointIcons( player, cockpit )
{
	foreach ( hardpoint in player.s.hardpointArray )
	{
		DisplayHardpointIcons( hardpoint, cockpit )
	}
}

function DisplayHardpointIcons( hardpoint, cockpit )
{
	Assert( IsValid( hardpoint ) )
	if ( !hardpoint.Enabled() )
		return

	local hardpointStringID = GetHardpointStringID( hardpoint.GetHardpointID() )
	local hardpointElem = cockpit.s["hardpointStatus_" + hardpointStringID]
	local hardpointFGElem = cockpit.s["hardpointStatusFG_" + hardpointStringID]

	local hardpointIcon = null
	local hardpointTeam = hardpoint.GetTeam()

	local bgColorState = GetBgColorState( hardpoint )
	switch ( bgColorState )
	{
		case 0:
			hardpointIcon = "HUD/capture_point_status_grey_" + hardpointStringID
			break
		case 1:
			hardpointIcon = "HUD/capture_point_status_blue_" + hardpointStringID
			break
		case 2:
			hardpointIcon = "HUD/capture_point_status_orange_" + hardpointStringID
			break
	}

	hardpointElem.SetImage( hardpointIcon )

	if ( hardpoint.s.pulseSpeed )
	{
		hardpointElem.SetPulsate( 0.1, 0.95, hardpoint.s.pulseSpeed )
		hardpointFGElem.SetPulsate( 0.95, 0.1, hardpoint.s.pulseSpeed )
	}
	else
	{
		hardpointElem.ClearPulsate()
		hardpointElem.ReturnToBaseColor()

		hardpointFGElem.ClearPulsate()
		hardpointFGElem.ReturnToBaseColor()
	}
}

function UpdateHardPointCaptureBar( player, cockpit )
{
	UpdateHardpointVisibility()
}

function GetNumOwnedHardpoints( team )
{
	local ownedHardpoints = 0
	foreach ( hardpointTeam in level.hardpointIDsToOwner )
	{
		if ( hardpointTeam != team )
			continue

		ownedHardpoints++
	}

	return ownedHardpoints
}

function GetHardpointCount()
{
	local count = level.hardpointIDsToOwner.len()
	return count
}

function SmartGlass_UpdateHardpoint( hardpoint, cappingTeam )
{
	if ( !Durango_IsDurango() )
		return

	local letter = ""
	switch( hardpoint.GetHardpointID() )
	{
		case 0:
			letter = "a"
			break
		case 1:
			letter = "b"
			break
		case 2:
			letter = "c"
			break
		default:
			return
	}

	local state = ""
	switch( hardpoint.GetHardpointState() )
	{
		case CAPTURE_POINT_STATE_UNASSIGNED:	// State at start of match
		case CAPTURE_POINT_STATE_NEXT:			// State at start of match
			state = "neutral"
			break
		case CAPTURE_POINT_STATE_HALTED:		// In this state the bar is not moving and the icon is at full oppacity
			state = "halted"
			break
		case CAPTURE_POINT_STATE_CAPPING:	// In this state the bar is moving and the icon pulsate
			state = "capping"
			break
		case CAPTURE_POINT_STATE_CAPTURED:	// TBD what this looks like exatly.
			state = "captured"
			break
	}

	// Hardpoint State
	SmartGlass_SetGameStateProperty( "hardpoint_" + letter + "_state", state )
	//printt( "hardpoint_" + letter + "_state", state )

	// Hardpoint Team
	SmartGlass_SetGameStateProperty( "hardpoint_" + letter + "_team", hardpoint.GetTeam().tostring() )
	//printt( "hardpoint_" + letter + "_team", hardpoint.GetTeam() )

	// Hardpoint Capping Team
	SmartGlass_SetGameStateProperty( "hardpoint_" + letter + "_cappingteam", cappingTeam.tostring() )
	//printt( "hardpoint_" + letter + "_cappingteam", cappingTeam )
}