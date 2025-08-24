
//********************************************************************************************
//	capture_point mp gametype client script
//********************************************************************************************

const TEAM_NEUTRAL = 0
const TEAM_FRIENDLY = 1
const TEAM_ENEMY = 2

capturePointColor <- {}
capturePointColor[ TEAM_NEUTRAL ] <- StringToColors( CAPTURE_POINT_COLOR_NEUTRAL )
capturePointColor[ TEAM_ENEMY ] <- StringToColors( CAPTURE_POINT_COLOR_ENEMY )
capturePointColor[ TEAM_FRIENDLY ] <- StringToColors( CAPTURE_POINT_COLOR_FRIENDLY )
capturePointColor[ "TEAM_ENEMY_CAP" ] <- StringToColors( CAPTURE_POINT_COLOR_ENEMY_CAP )
capturePointColor[ "TEAM_FRIENDLY_CAP" ] <- StringToColors( CAPTURE_POINT_COLOR_FRIENDLY_CAP )

PrecacheHUDMaterial( "HUD/capture_point_status_round_orange_a" )
PrecacheHUDMaterial( "HUD/capture_point_status_round_blue_a" )
PrecacheHUDMaterial( "HUD/capture_point_status_round_grey_a" )

const CAPTURE_POINT_UI_UPDATE = "CapturePointUIUpdate"

function main()
{
	Globalize( CapturePoint_AddPlayer )
	Globalize( ShowHardpointIcons )
	Globalize( HideHardpointIcons )
	Globalize( VarChangedCallback_GameStateChanged )
	Globalize( HardpointChanged )
	Globalize( OnHardpointCockpitCreated )
	Globalize( HardpointEntityChanged )

	AddPlayerFunc( Bind( CapturePoint_AddPlayer ) )

	RegisterSignal( "HardpointCaptureStateChanged" )
	RegisterSignal( CAPTURE_POINT_UI_UPDATE )

	RegisterServerVarChangeCallback( "gameState", VarChangedCallback_GameStateChanged )
	RegisterServerVarChangeCallback( "activeUplinkID", VarChangedCallback_GameStateChanged )

	AddCreateCallback( "info_hardpoint", OnHardpointCreated )

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

	local index = 0
	player.s.worldIcon <- HudElementGroup( "CapturePoint_" + index )
	player.s.worldIcon.CreateElement( "CapturePointIcon_" + index )
	player.s.progressBar <- player.s.worldIcon.CreateElement( "CapturePointIconBG_" + index )
	player.s.statusText <- HudElement( "CaptureBarStatus_" + index )
	player.s.labelText <- HudElement( "CaptureBarLabel_" + index )


}

function OnHardpointCreated( hardpoint, isRecreate )
{
	if ( hardpoint.GetHardpointID() < 0 )
		return

	hardpoint.s.previousOwnerTeam <- -1	// force the icons etc to be updated on connect
	hardpoint.s.currentProgress <- 0
	hardpoint.s.lastCappingTeam <- null
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

	local player = GetLocalViewPlayer()
	if ( !player )
		return

	if ( !( "hardpointArray" in player.s ) )
		CapturePoint_AddPlayer( player )

	//---------------------------------------------
	// Set up data about the hardpoint
	//---------------------------------------------

	player.s.hardpointArray.append( hardpoint )

	HardpointChanged( hardpoint )
}


function UpdateHardpointIconPosition( player )
{
	local hardpoint
	foreach ( arrayHardpoint in player.s.hardpointArray )
	{
		if ( arrayHardpoint.GetHardpointID() != level.nv.activeUplinkID )
			continue

		hardpoint = arrayHardpoint
		break
	}

	Assert( hardpoint )

	local terminal = hardpoint.GetTerminal()
	Assert( terminal, "No terminal" )

	// attach icon hud element to the hardpoint at the location of the ICON attachment of the terminal
	// offset is based on a box of 120 x 80 and a icon 48 x 48 in the lower left corner
	player.s.worldIcon.SetEntityOverhead( terminal, Vector( 0, 0, 0 ), 0.5, 1.0 )
	player.s.worldIcon.SetClampToScreen( CLAMP_RECT )
	player.s.worldIcon.SetADSFade( deg_cos( 5 ), deg_cos( 2 ), 0, 1 )
	//player.s.worldIcon.SetWorldSpaceScale( 0.9, 0.4, 500, 3500 )
	player.s.worldIcon.Show()

	player.s.statusText.Show()
	player.s.statusText.SetADSFade( deg_cos( 5 ), deg_cos( 2 ), 0, 1 )

	player.s.labelText.Show()
	player.s.labelText.SetADSFade( deg_cos( 5 ), deg_cos( 2 ), 0, 1 )
}


// DOESNT NEED COCKPIT
function UpdateHardpointVisibility()
{
	local player = GetLocalViewPlayer()

	if ( !GamePlaying() || player.s.hardpointsHidden || level.nv.activeUplinkID == null )
	{
		player.s.worldIcon.Hide()
		player.s.statusText.Hide()
		player.s.labelText.Hide()
	}
	else
	{
		UpdateHardpointIconPosition( player )
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

	UpdateHardpointVisibility()
	HardpointChanged( hardpoint )
}

function HardpointChanged( hardpoint )
{
	local player = GetLocalViewPlayer()
	if ( !IsValid( player ) )
		return

	UpdateHardpointVisibility()
	local state = hardpoint.GetHardpointState()

	local color = GetColorForTeam( hardpoint )
	local IconName = GetIconNameForTeam( hardpoint.GetTeam(), hardpoint.GetHardpointID() )

	local worldIcon = player.s.worldIcon
	local capturePointIcon = worldIcon.GetElement( "CapturePointIcon_0" ) // gotta be a better way

	capturePointIcon.SetImage( IconName )
	capturePointIcon.SetColor( color.r, color.g, color.b )

	UpdateHardpointLabelAndColor( player, hardpoint )
	///HardpointProgressBarUpdate( player, hardpoint )

	if ( hardpoint.GetEstimatedCaptureTime() > Time() && state != CAPTURE_POINT_STATE_NEXT )
	{
		local startTime = hardpoint.GetHardpointProgressRefPoint()
		local endTime = hardpoint.GetEstimatedCaptureTime()
		local currentProgress = GraphCapped( Time(), startTime, endTime, 1.0, 0.0 )

		printt( startTime, endTime, currentProgress, endTime - Time() )

		player.s.progressBar.SetBarProgressOverTime( currentProgress, 0.0, endTime - Time() )
	}
	else
	{
		player.s.progressBar.SetBarProgress( 0.0 )
	}

	player.s.progressBar.SetColor( color.r, color.g, color.b, color.a )

	if ( player.s.statusText.IsAutoText() )
		player.s.statusText.DisableAutoText()

	if ( state == CAPTURE_POINT_STATE_NEXT )
	{
		player.s.statusText.SetAutoText( "", HATT_COUNTDOWN_TIME, hardpoint.GetEstimatedCaptureTime() )
		player.s.statusText.EnableAutoText()
	}
	else
	{
		if ( hardpoint.GetTeam() == player.GetTeam() )
			player.s.statusText.SetAutoText( "#DEFEND_COUNTDOWNTIME", HATT_GAME_COUNTDOWN_SECONDS, hardpoint.GetEstimatedCaptureTime() )
		else
			player.s.statusText.SetText( "HACK" )
	}

	level.ent.Signal( CAPTURE_POINT_UI_UPDATE )
}


function HardpointProgressBarUpdate( player, hardpoint )
{
	local estCaptureTime = hardpoint.GetEstimatedCaptureTime()
	local progressRefPoint = hardpoint.GetHardpointProgressRefPoint()
	local startProgress = fabs( progressRefPoint )
	local lastCappingTeam = hardpoint.s.lastCappingTeam

	if ( hardpoint.GetHardpointState() == CAPTURE_POINT_STATE_NEXT )
		estCaptureTime = 0

	local goalProgress

	goalProgress = 1
	if ( lastCappingTeam == TEAM_IMC && progressRefPoint > 0 )
		goalProgress = 0
	if ( lastCappingTeam == TEAM_MILITIA && progressRefPoint < 0 )
		goalProgress = 0

	if ( estCaptureTime > 0 )
	{
		local durationToCapture = estCaptureTime - Time()

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


function GetIconNameForTeam( team, hardpointID )
{
	local iconName
	local iconIdString = GetHardpointIcon( hardpointID )

	if ( team == TEAM_UNASSIGNED )
		iconName = "HUD/capture_point_status_round_grey_a"
	else if ( team == GetLocalViewPlayer().GetTeamNumber() )
		iconName = "HUD/capture_point_status_round_blue_a"
	else
		iconName = "HUD/capture_point_status_round_orange_a"

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


function GetColorForTeam( hardpoint )
{
	local hardpointTeam = hardpoint.GetTeam()
	local playerTeam = GetLocalViewPlayer().GetTeam()

	if ( hardpointTeam == TEAM_UNASSIGNED )
		return capturePointColor[TEAM_NEUTRAL]
	else if ( hardpointTeam == playerTeam )
		return capturePointColor[TEAM_FRIENDLY]
	else
		return capturePointColor[TEAM_ENEMY]
}


function UpdateHardpointLabelAndColor( player, hardpoint )
{
	// sets the color of the bar for the local players team
	local team = hardpoint.GetTeam()
	local color = GetColorForTeam( hardpoint )
	if ( hardpoint == player.GetHardpointEntity() )
	{
		player.s.captureBarData.color = color
		player.s.captureBarData.labelText = "UPLINK"
	}

	player.s.labelText.SetText( "UPLINK" )
	hardpoint.s.color = color

	level.ent.Signal( CAPTURE_POINT_UI_UPDATE )
}














function VarChangedCallback_GameStateChanged()
{
	level.ent.Signal( CAPTURE_POINT_UI_UPDATE )
	UpdateHardpointVisibility()
}


// THIS SECTION DRAWS ON THE COCKPIT

function OnHardpointCockpitCreated( cockpit, panel, scoreGroup )
{
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
		UpdateHardpointVisibility()
	}
}
