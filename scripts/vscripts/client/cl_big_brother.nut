function main()
{
	file.bigBrotherPanelNames <- { bb_panel_a = 0, bb_panel_b = 1 }
	file.controlPanels <- {}
	AddCreateCallback( "prop_control_panel", BigBrotherControlPanelCreate )
	AddCreateCallback( "titan_soul", BBCreateCallback_TitanSoul )

	RegisterServerVarChangeCallback( "gameState", VarChangedCallback_GameStateChanged )

	RegisterSignal( "Stop_VDU" )
	AddCallback_OnClientScriptInit( BB_AddPlayer )
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
	BigBrotherUpdatePanel( ent, index )

	GetPanelRanges( ent )

	ent.s.statusText <- HudElement( "CaptureBarStatus_" + index )
	ent.s.statusText.SetEntity( ent, offset, 0.5, 0.0 )
	ent.s.statusText.SetClampToScreen( CLAMP_RECT )
	ent.s.statusText.Show()

	ent.s.statusText.SetAutoTextVector( "#HUD_DISTANCE_METERS", HATT_DISTANCE_METERS, ent.GetOrigin() )
	// ent.s.statusText.SetText("")
	ent.s.VGUIFunc <- UpdateBBText

	if ( !ent.s.statusText.IsAutoText() )
		ent.s.statusText.EnableAutoText()

	ent.s.labelText <- HudElement( "CaptureBarLabel_" + index )
	ent.s.labelText.Show()

	if(CanUpdateVGUI(ent))
	{
		local stateElement = ent.s.HudVGUI.s.state
		local controlledItem = ent.s.HudVGUI.s.controlledItem
		controlledItem.SetText( "" )
		stateElement.SetText( "" )
	}

	statusText.SetEntity( ent, offset, 0.5, 0.0 )
	statusText.SetClampToScreen( CLAMP_RECT )
	statusText.SetFOVFade( deg_cos( 40 ), deg_cos( 15 ), 0, 1 )
	statusText.SetADSFade( deg_cos( 5 ), deg_cos( 2 ), 0, 1 )
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
	local endTime = Time() + 45;
	stateElement.SetAutoText( "", HATT_COUNTDOWN_TIME, endTime )


	controlledItem.SetText( "Panel " + panel.GetName() )
	// stateElement.SetText( Time().tointeger() + "" )
}

function InitializeHardpoint( hardpoint )
{
	
}

function BigBrotherUpdatePanel( panel, index )
{
	local capturePointIcon = panel.s.worldIcon.GetElement( "CapturePointIcon_" + index )

	local icons = GetCapturePointStatusIcon( index )
	local player = GetLocalViewPlayer()
	local team = player.GetTeam()
	local panelTeam = panel.GetTeam()
	local icon

	if ( panelTeam == 0 )
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

	if ( panelTeam == TEAM_UNASSIGNED )
		panel.s.worldIcon.Hide()
	else
		panel.s.worldIcon.Show()


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