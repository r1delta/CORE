const TEAM_NEUTRAL = 0
const TEAM_FRIENDLY = 1
const TEAM_ENEMY = 2

const EXPLO_TIME = 30

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
	file.bigBrotherPanelNames <- { bb_panel_a = 0, bb_panel_b = 1 }
	file.controlPanels <- {}
	AddCreateCallback( "prop_control_panel", BigBrotherControlPanelCreate )
	AddCreateCallback( "titan_soul", BBCreateCallback_TitanSoul )

	RegisterServerVarChangeCallback( "gameState", VarChangedCallback_GameStateChanged )
	
	RegisterSignal( "HardpointCaptureStateChanged" )
	RegisterSignal( CAPTURE_POINT_UI_UPDATE )
	Globalize( HardpointChanged )
	AddPlayerFunc( Bind( CapturePoint_AddPlayer ) )
	Globalize( CapturePoint_AddPlayer )
	Globalize( OnHardpointCockpitCreated )
	Globalize( HardpointEntityChanged )


	RegisterSignal( "Stop_VDU" )
	AddCallback_OnClientScriptInit( BB_AddPlayer )
	// AddCreateCallback( "info_hardpoint", OnHardpointCreated )

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

function HardpointEntityChanged( player )
{
	if ( player != GetLocalViewPlayer() )
		return

	UpdateHardpointVisibility()
	HardpointChanged( hardpoint )
}

function UpdateHardpointLabelAndColor( player, hardpoint )
{
	// // sets the color of the bar for the local players team
	// local team = hardpoint.GetTeam()
	// local color = GetColorForTeam( hardpoint )
	// if ( hardpoint == player.GetHardpointEntity() )
	// {
	// 	player.s.captureBarData.color = color
	// 	player.s.captureBarData.labelText = "UPLINK"
	// }

	// player.s.labelText.SetText( "UPLINK" )
	// hardpoint.s.color = color

	// level.ent.Signal( CAPTURE_POINT_UI_UPDATE )
}


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


function BB_AddPlayer( player )
{
	player.cv.BBTitanIcon <- HudElement( "NeutralPetTitanIcon" )
	player.cv.BBTitanIcon.SetClampToScreen( CLAMP_RECT )
	player.cv.BBTitanIcon.SetADSFade( 0, 0, 0, 1 )
	// player.cv.BBTitanIcon.Show()
}

function VarChangedCallback_GameStateChanged()
{
	foreach ( index, panel in file.controlPanels )
	{
		BigBrotherUpdatePanel( panel, index )
	}
}

function BigBrotherControlPanelCreate( ent, isRecreate )
{
	local name = ent.GetName()
	if ( !( name in file.bigBrotherPanelNames ) )
		return
	printt( "BigBrotherControlPanelCreate: ", name )
	local index = file.bigBrotherPanelNames[ name ]
	file.controlPanels[ index ] <- ent

	local worldIcon = HudElementGroup( "CapturePoint_" + index )
	worldIcon.CreateElement( "CapturePointIcon_" + index )
	local progressBar = worldIcon.CreateElement( "CapturePointIconBG_" + index )
	local statusText = HudElement( "CaptureBarStatus_" + index )
	local labelText = HudElement( "CaptureBarLabel_" + index )

	worldIcon.Show()

	local offset = Vector(0,0,76)
	worldIcon.SetEntity( ent, offset, 0.5, 1.0 )
	worldIcon.SetClampToScreen( CLAMP_RECT )
	worldIcon.SetADSFade( deg_cos( 5 ), deg_cos( 2 ), 0, 1 )
	worldIcon.SetWorldSpaceScale( 1.0, 0.7, 500, 3500 )

	ent.s.worldIcon <- worldIcon

	GetPanelRanges( ent )

	ent.s.statusText <- HudElement( "CaptureBarStatus_" + index )
	ent.s.statusText.SetEntity( ent, offset, 0.5, 0.0 )
	ent.s.statusText.SetClampToScreen( CLAMP_RECT )
	ent.s.statusText.Show()

	ent.s.statusText.SetAutoTextVector( "#HUD_DISTANCE_METERS", HATT_DISTANCE_METERS, ent.GetOrigin() )
	ent.s.VGUIFunc <- UpdateBBText

	if ( !ent.s.statusText.IsAutoText() )
		ent.s.statusText.EnableAutoText()

	ent.s.labelText <- HudElement( "CaptureBarLabel_" + index )
	ent.s.labelText.SetText("Hack") 
	ent.s.labelText.Show()
	BigBrotherUpdatePanel( ent, index )
	if(CanUpdateVGUI(ent))
	{
		local stateElement = ent.s.HudVGUI.s.state
		local controlledItem = ent.s.HudVGUI.s.controlledItem
		controlledItem.SetText( "" )
		stateElement.SetText( "" )
	}

	// statusText.SetEntity( ent, offset, 0.5, 0.0 )
	// statusText.SetClampToScreen( CLAMP_RECT )
	// statusText.SetFOVFade( deg_cos( 40 ), deg_cos( 15 ), 0, 1 )
	// statusText.SetADSFade( deg_cos( 5 ), deg_cos( 2 ), 0, 1 )
	statusText.Show()
}

function CanUpdateVGUI( panel )
{
	if ( panel.s.VGUIFunc == null )
		return false

	if ( panel.s.HudVGUI == null )
		return false

	// if ( panel.s.targetArray.len() == 0 )
	// 	return false

	return true
}

function UpdateBBText(panel) {

	local stateElement = panel.s.HudVGUI.s.state
	local controlledItem = panel.s.HudVGUI.s.controlledItem
	if(level.nv.bbHackStartTime == 0.0)
	{
		// based on if the player is attacking or defending set the text and color appropriately
		local player = GetLocalViewPlayer()
		if ( player.GetTeam() != level.nv.attackingTeam )
		{
			controlledItem.SetText( "DEFEND" )
			controlledItem.SetColor( 0, 255, 0, 255 )

			stateElement.SetText( "PANEL SECURE" )
		}
		else
		{
			controlledItem.SetText( "HACK" )
			controlledItem.SetColor( 255, 0, 0, 255 )
			stateElement.SetText( "Destroy " )
		}
		return
	}
	if(level.nv.bbHackStartTime == 0.0)
	{
		stateElement.SetAutoText( "", HATT_COUNTDOWN_TIME, 0 )
		stateElement.EnableAutoText()
		controlledItem.SetText( "" )
		return
	}
	local endTime = level.nv.bbHackStartTime + EXPLO_TIME
	stateElement.SetAutoText( "", HATT_COUNTDOWN_TIME, endTime )


	controlledItem.SetText( "Defend")
	controlledItem.SetColor( 0, 255, 0, 255 )
	panel.s.labelText.SetAutoText( "#DEFEND_COUNTDOWNTIME", HATT_COUNTDOWN_TIME, endTime )
	panel.s.labelText.EnableAutoText()
	// stateElement.SetText( Time().tointeger() + "" )
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
	local index = hardpoint.GetHardpointID()
	local capturePointIcon = worldIcon.GetElement( "CapturePointIcon_" + index ) // gotta be a better way
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

		// player.s.progressBar.SetBarProgressOverTime( currentProgress, 0.0, endTime - Time() )
	}
	else
	{
		// player.s.progressBar.SetBarProgress( 0.0 )
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
function BigBrotherUpdatePanel( panel, index )
{
	local capturePointIcon = panel.s.worldIcon.GetElement( "CapturePointIcon_" + index )

	local icons = GetCapturePointStatusIcon( index )
	local player = GetLocalViewPlayer()
	local team = player.GetTeam()
	local panelTeam = panel.GetTeam()
	local icon

	if ( panelTeam == TEAM_UNASSIGNED )
	{
		icon = icons.neutral
	}
	else if ( team == panelTeam )
	{
		icon = icons.friendly
	}
	else if ( team == GetOtherTeam( panelTeam ) )
	{
		icon = icons.enemy
	}

	capturePointIcon.SetImage( icon )

	local progressBar =  panel.s.worldIcon.GetElement( "CapturePointIconBG_" + index )
	local startTime = Time() - level.nv.bbHackStartTime
	local endTime = level.nv.bbHackStartTime + 10
	local playerTeam = player.GetTeam()
	local color
	if( playerTeam == level.nv.attackingTeam)
	{
		color = StringToColors( CAPTURE_POINT_COLOR_FRIENDLY )
	}
	else
	{
		color = StringToColors( CAPTURE_POINT_COLOR_ENEMY )
	}
	capturePointIcon.SetColor( color.r, color.g, color.b )

	local curProgress = 0
	local estimatedTime = EXPLO_TIME
	local startHackingTime = level.nv.bbHackStartTime
	if( startHackingTime != 0 )
	{
		local timePassed = Time() - startHackingTime
		curProgress = timePassed / estimatedTime
		estimatedTime = estimatedTime - timePassed
		progressBar.SetBarProgressOverTime( curProgress, 1, estimatedTime )
		progressBar.SetColor( color.r, color.g, color.b, color.a )
	}

	
	if ( panelTeam == TEAM_UNASSIGNED ) {
		panel.s.worldIcon.Hide()
		panel.s.statusText.Hide()
		panel.s.labelText.Hide()
	}
	else {
		panel.s.worldIcon.Show()
		panel.s.statusText.Show()
		panel.s.labelText.Show()
	}

	if ( CanUpdateVGUI( panel ) ) {
		panel.s.VGUIFunc( panel )	// Update the panel vgui screen to match the state of the target(s)
	}

}

function GetCapturePointStatusIcon( index )
{
	local letters = [ "a", "b", "c" ]
	local table = {}
	local letter = letters[ index ]
	table.friendly <- "HUD/capture_point_status_round_blue_" + letter
	table.neutral <- "HUD/capture_point_status_round_grey_" + letter
	table.enemy <- "HUD/capture_point_status_round_orange_" + letter
	return table
}

function SCB_BBUpdate( playerHandle )
{
	foreach ( index, panel in file.controlPanels )
	{
		BigBrotherUpdatePanel( panel, index )
	}

	if(!playerHandle)
		return

	local panelUser = GetEntityFromEncodedEHandle( playerHandle )
	
	local player = GetLocalViewPlayer()
	if(!player)
		return	
	local msg
	local subMsg

	local team = player.GetTeam()

	if ( player == panelUser )
	{
		if ( team != level.nv.attackingTeam )
			return

		msg = "#BB_YOU_LAUNCHED_VIRUS"
		subMsg = "#BB_DEFEND_THE_PANEL"
	}
	else
	{
		if ( team == 0 )
		{
			msg = "#BB_VIRUS_LAUNCHED"
			subMsg = "#BB_CLOCK_TICKING"
		}
		else if ( team == level.nv.attackingTeam )
		{
			msg = "#BB_TEAMMATE_LAUNCHED_VIRUS"
			subMsg = "#BB_DEFEND_THE_PANEL"
		}
		else
		{
			msg = "#BB_VIRUS_LAUNCHED"
			subMsg = "#BB_HACK_THE_PANEL"
		}
	}

	local announcement = CAnnouncement( msg )
	announcement.SetSubText( subMsg )
	//announcement.SetTitleColor( [255, 190, 0] )
	//announcement.SetOptionalTextArgsArray( optionalTextArgs )
	//announcement.SetPurge( true )
	//announcement.SetPriority( 100 )
	//announcement.SetSoundAlias( "UI_InGame_LevelUp" )
	//announcement.SetIcon( "HUD/quest/bg_circle" )
	//announcement.SetIconText( "" + lvl )
	AnnouncementFromClass( player, announcement )
}
Globalize( SCB_BBUpdate )

function BBCreateCallback_TitanSoul( soul, isRecreate )
{
	local titan = soul.GetTitan()
	if ( !IsAlive( titan ) )
		return

	thread BBDisplayTitanIcon( soul, titan )
}

function BBDisplayTitanIcon( soul, titan )
{
	local player = GetLocalViewPlayer()

	// kill replay?
	if ( titan.GetTeam() != player.GetTeam() )
		return

	if ( IsWatchingKillReplay() )
		return

	player.cv.BBTitanIcon.Hide()

	soul.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDestroy" )

	for ( ;; )
	{
		local titan = soul.GetTitan()
		if ( !IsAlive( titan ) )
			return
		waitthread DrawTitanIconUntilStop( player, titan )
		player.cv.BBTitanIcon.Hide()
		wait 1 // due to soul related bug
	}
}

function DrawTitanIconUntilStop( player, titan )
{
	player.EndSignal( "SettingsChanged" )
	titan.EndSignal( "OnDestroy" )
	titan.EndSignal( "OnDeath" )

	if ( player == titan )
		WaitForever()

	player.cv.BBTitanIcon.SetEntityOverhead( titan, Vector( 0, 0, 16 ), 0.5, 0.5 )
	player.cv.BBTitanIcon.Show()
	WaitForever()
}

function SCB_BBVdu( panelEHandle, execute )
{
	local panel = GetEntityFromEncodedEHandle( panelEHandle )

	switch ( execute )
	{
		case 1:
			thread DisplayVDUHacking( panel )
			break

		case 0:
			panel.Signal( "Stop_VDU" )
			break
	}
}
Globalize( SCB_BBVdu )

function DisplayVDUHacking( panel )
{
	if ( IsLockedVDU() )
		return

	OnThreadEnd(
		function() : (  )
		{
			HideVDU()
			UnlockVDU()
		}
	)

	local player = GetLocalViewPlayer()

	panel.EndSignal( "Stop_VDU" )
	player.EndSignal( "OnDestroy" )
	panel.EndSignal( "OnDestroy" )

	LockVDU()

	level.camera.SetFOV( 100 )
	level.camera.SetOrigin( panel.s.scanOrigin )
	level.camera.SetAngles( panel.s.scanAngles )

	SetNextVDUWideScreen( player )
	ShowVDU()

//	local cameraDir = RandomInt( 2 )
//	local cameraSpeed = 5
//	local moveTime = Time()

	// failsafe, longer than the current max hack time
	local endTime = Time() + 10
	local min = panel.s.min
	local max = panel.s.max

	local scanAngles = panel.s.scanAngles
	//local ranges = GetPanelRangesForPosition( panel.s.scanOrigin, panel.s.scanAngles )
	//panel.s.min = ranges.min
	//panel.s.max = ranges.max

	for ( ;; )
	{
		if ( Time() >= endTime )
			break

		local dif = sin( Time() * 1.5 )
		local result = Graph( dif, -1.0, 1.0, min, max )
		local angles = scanAngles.AnglesCompose( Vector( 0, result, 0 ) )
		level.camera.SetAngles( angles )
		wait 0
	}
}

function GetPanelRanges( panel )
{
	local origin = panel.GetOrigin()
	origin.z += 80
	local angles = panel.GetAngles()

	//angles = angles.AnglesCompose( Vector(0,180,0) )
	local ranges = GetPanelRangesForPosition( origin, angles )

	panel.s.scanOrigin <- origin
	panel.s.scanAngles <- angles

	panel.s.min <- ranges.min
	panel.s.max <- ranges.max
}

function GetPanelRangesForPosition( origin, angles )
{
	local max = 120
	local iterator = 3

	local positiveMax = 0
	for ( local i = 0; i <= max; i += iterator )
	{
		if ( PanelTraceBlocked( origin, angles, i ) )
			break
		positiveMax = i
	}

	local positiveMin = 0
	for ( local i = 0; i >= -max; i -= iterator )
	{
		if ( PanelTraceBlocked( origin, angles, i ) )
			break
		positiveMin = i
	}

	local padding = 45
	positiveMin += padding
	positiveMax -= padding

	if ( positiveMin > positiveMax )
	{
		local average = positiveMin + positiveMax
		average *= 0.5

		positiveMin = average
		positiveMax = average
	}

	return { min = positiveMin, max = positiveMax }
}

function PanelTraceBlocked( origin, angles, yaw )
{
	local anglesCopy = angles.AnglesCompose( Vector( 0, yaw, 0 ) )
	local forward = anglesCopy.AnglesToForward()
	local result = TraceLine( origin, origin + forward * 300, null, TRACE_MASK_NPCWORLDSTATIC, TRACE_COLLISION_GROUP_NONE )
	local hit = result.fraction < 0.9
	//thread DisplayTraceResults( origin, result.endPos, hit )
	return hit
}

function DisplayTraceResults( origin, end, hit )
{
	wait 0.1
	if ( hit )
		DebugDrawLine( origin, end, 255, 0, 0, true, 10 )
	else
		DebugDrawLine( origin, end, 0, 255, 0, true, 10 )
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
