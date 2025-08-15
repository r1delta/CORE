function main()
{
	level.titanHudVisible <- false
	level.hudVisibleEndSignal <- "hudVisibleEndSignal"

	level.allTitanHudElems <- null
	level.EMP_vguis <- []
	level.lastHudEMPStateAlpha <- 255

	level.hideThreatHud <- false

	RegisterSignal( level.hudVisibleEndSignal )
	RegisterSignal( "Doomed" )

	Globalize( TitanHud_AddPlayer )
	Globalize( TitanHud_HideThreatHud )
	Globalize( TitanHud_ShowThreatHud )
	Globalize( Create_VGUIMod )
	Globalize( rebuild )
	Globalize( Create_CenterVGUI )
	Globalize( Create_CenterLowerVGUI )
	Globalize( Create_BottomVGUI )
	Globalize( Create_BottomLeftVGUI )
	Globalize( Create_PilotVGUI )
	Globalize( Create_TitanMinimap )
	Globalize( ServerCallback_UpdateDashCount )

	if ( !IsMenuLevel() )
		AddCreateCallback( "titan_cockpit", TitanCockpitHudInit )
}


function rebuild()
{
	local player = GetLocalViewPlayer()
	local cockpit = player.GetCockpit()
}


function PilotThreatHud( cockpit, player )
{
	if ( !TargetHealthEnabled() )
		return

	// hide the eye
	local entParent = player.GetParent()
	if ( IsAlive( entParent ) && entParent.IsTitan() )
	{
		thread HideTitanEye( entParent )

		local soul = entParent.GetTitanSoul()
		Assert( IsValid( soul ), "Titan " + entParent + " has no soul!" )
		thread ShowTitanEyeDelayed( soul, 1.0 )
	}
}

function TitanCockpitHudInit( cockpit, isRecreate )
{
	Assert( !isRecreate )

	local player = GetLocalViewPlayer()

	if ( !IsTitanCockpitModelName( cockpit.GetModelName() ) )
	{
		if ( cockpit.GetModelName() == "models/weapons/arms/human_pov_cockpit.mdl" )
		{
			thread PilotThreatHud( cockpit, player )

			cockpit.SetCaptureScreenBeforeViewmodels( true )
			return
		}

		cockpit.SetCaptureScreenBeforeViewmodels( false )
		return
	}

	thread TitanCockpitHudInit_Internal( cockpit )
}

function TitanHud_InitEjectHint( cockpit, player )
{
	local mainVGUI = cockpit.GetMainVGUI()
	if ( !mainVGUI )
		return
	local panel = mainVGUI.GetPanel()

	cockpit.s.ejectHintGroup <- HudElementGroup( "ejectHint" )
	cockpit.s.crosshairHealthBarBackground <- HudElement( "CrosshairHealthBarBackground", panel )
	cockpit.s.crosshairHealthLabel <- HudElement( "CrosshairHealthLabel", panel )
	cockpit.s.crosshairHealthEjectIcon <- HudElement( "CrosshairEjectHintIcon", panel )
	cockpit.s.crosshairHealthEjectIcon.EnableKeyBindingIcons()
	cockpit.s.crosshairHealthEjectIconBG <- HudElement( "CrosshairEjectHintIconBG", panel )

	cockpit.s.crosshairHealthEjectRingBG <- HudElement( "CrosshairEjectRingBG", panel )
	cockpit.s.crosshairHealthEjectRingA <- HudElement( "CrosshairEjectRingA", panel )
	cockpit.s.crosshairHealthEjectRingB <- HudElement( "CrosshairEjectRingB", panel )
	cockpit.s.crosshairHealthEjectRingC <- HudElement( "CrosshairEjectRingC", panel )

	cockpit.s.ejectHintGroup.AddElement( cockpit.s.crosshairHealthBarBackground )
	cockpit.s.ejectHintGroup.AddElement( cockpit.s.crosshairHealthLabel )
	cockpit.s.ejectHintGroup.AddElement( cockpit.s.crosshairHealthEjectIcon )
	cockpit.s.ejectHintGroup.AddElement( cockpit.s.crosshairHealthEjectIconBG )
	cockpit.s.ejectHintGroup.AddElement( cockpit.s.crosshairHealthEjectRingBG )
	cockpit.s.ejectHintGroup.AddElement( cockpit.s.crosshairHealthEjectRingA )
	cockpit.s.ejectHintGroup.AddElement( cockpit.s.crosshairHealthEjectRingB )
	cockpit.s.ejectHintGroup.AddElement( cockpit.s.crosshairHealthEjectRingC )

	local numDashPips = floor( 100 / GetSettingsForPlayer_DodgeTable( player )["dodgePowerDrain"] )

	cockpit.s.dashBar <- HudElement( "DashBar", panel )
	cockpit.s.dashBarFG <- HudElement( "DashBarFG", panel )

	local width = cockpit.s.dashBar.GetWidth()
	local gap = 6
	local segmentWidth = (width - ((numDashPips - 1) * gap)) / numDashPips

	cockpit.s.dashBar.SetBarSegmentInfo( gap, segmentWidth )
	cockpit.s.dashBar.SetBarProgressSource( ProgressSource.PROGRESS_SOURCE_PLAYER_SUIT_POWER )
	cockpit.s.dashBar.SetBarProgressRemap( 0.0, 1.0, 0, 1 ) // avoids slivers of bars left over by precision issues with 33.33% suit power

	cockpit.s.dashBarFG.SetBarSegmentInfo( gap, segmentWidth )
	cockpit.s.dashBarFG.SetBarProgressSource( ProgressSource.PROGRESS_SOURCE_PLAYER_SUIT_POWER )
	cockpit.s.dashBarFG.SetBarProgressRemap( 0.0, 1.0, 0, 1.01 ) // avoids slivers of bars left over by precision issues with 33.33% suit power

	// training helper
	cockpit.s.dashBarOutline <- HudElement( "DashBar_Tutorial_Outline", panel )

	cockpit.s.dashGroup <- HudElementGroup( "dashBar" )
	cockpit.s.dashGroup.AddElement( cockpit.s.dashBar )
	cockpit.s.dashGroup.AddElement( cockpit.s.dashBarFG )
	cockpit.s.dashGroup.AddElement( cockpit.s.dashBarOutline )
	if ( IsWatchingKillReplay() )
		cockpit.s.dashGroup.Hide()

	thread TitanHud_EjectHintThink( cockpit, player )
}
Globalize( TitanHud_InitEjectHint )

function ServerCallback_UpdateDashCount()
{
	local player = GetLocalViewPlayer()
	if ( !IsValid( player ) )
		return

	local cockpit = player.GetCockpit()
	if ( !IsValid( cockpit ) )
		return

	local numDashPips = floor( 100 / GetSettingsForPlayer_DodgeTable( player )["dodgePowerDrain"] )
	local width = cockpit.s.dashBar.GetWidth()
	local gap = 6
	local segmentWidth = (width - ((numDashPips - 1) * gap)) / numDashPips
	cockpit.s.dashBar.SetBarSegmentInfo( gap, segmentWidth )
	cockpit.s.dashBarFG.SetBarSegmentInfo( gap, segmentWidth )
	cockpit.s.dashBar.Show()
	cockpit.s.dashBarFG.Show()
}

function TitanCockpitHudInit_Internal( cockpit )
{
	OnThreadEnd(
		function () : ()
		{
			ClearCrosshairPriority( crosshairPriorityLevel.TITANHUD )
		}
	)
	EndSignal( cockpit, "OnDestroy" )
	local player = GetLocalViewPlayer()

	// for now, delay hud element creation to sync with cockpit monitors turning on.  Ideally these would fade in,
	// but there is no good way to fade an entire vgui at once.
	SetCrosshairPriorityState( crosshairPriorityLevel.TITANHUD, CROSSHAIR_STATE_HIT_INDICATORS_ONLY )
	while ( IsValid( cockpit ) && TitanCockpit_IsBooting( cockpit ) )
	{
		wait 0
	}
	if ( !player.IsTitan() )
		return

	ClearCrosshairPriority( crosshairPriorityLevel.TITANHUD )

	if ( ShouldDrawRodeoVGUI( player ) )
	{
		TitanCockpitDialog_RodeoAnnounce( player )

		thread DrawRodeoAlertIcons( player.GetTitanSoul() )
	}

	cockpit.s.threatHudVGUI <- null
	//thread Create_TitanMinimap( cockpit, player )

	thread TitanCockpitThink( cockpit )
}


function TitanHud_AddPlayer()
{
	local player = GetLocalViewPlayer()
	player.s.numDashPips <- null
	player.s.healthBarBaseScale <- 1.0

	level.allTitanHudElems = HudElementGroup( "TitanHudElems" )
}



function TitanHud_Hide()
{
	if ( !level.titanHudVisible )
		return

	level.titanHudVisible = false

	// Stop think functions
	Signal( GetLocalViewPlayer(), level.hudVisibleEndSignal )

	local elems = level.allTitanHudElems.GetElements()
	foreach( elem in elems )
		elem.Hide()
}

function TitanHud_HideThreatHud()
{
	level.hideThreatHud = true
}

function TitanHud_ShowThreatHud()
{
	level.hideThreatHud = false
}

function TitanHudElement( name, ownerHud = Hud )
{
	local elem = HudElement( name, ownerHud )

	level.allTitanHudElems.AddElement( elem )

	return elem
}


function TargetHealthEnabled()
{
	return GetCurrentPlaylistVarInt( "target_health_bar", 0 )
}

function Create_CenterVGUI( vguiName, cockpit, player, mod = null )
{
	return Create_VGUI( vguiName, cockpit, player, "SCR_C_BL", "SCR_C_TR", mod )
}

function Create_CenterLowerVGUI( vguiName, cockpit, player, mod = null )
{
	return Create_VGUI( vguiName, cockpit, player, "SCR_CL_BL", "SCR_CL_TR", mod )
}

function Create_BottomVGUI( vguiName, cockpit, player, mod = null )
{
	return Create_VGUI( vguiName, cockpit, player, "SCR_B_BL", "SCR_B_TR", mod )
}

function Create_BottomLeftVGUI( vguiName, cockpit, player, mod = null )
{
	return Create_VGUI( vguiName, cockpit, player, "SCR_BL_BL", "SCR_BL_TR", mod )
}

function Create_VGUIMod()
{
	local mod = {}
	mod.forward <- null
	mod.right <- null
	mod.up <- null
	mod.sizeX <- 1.0
	mod.sizeY <- 1.0
	return mod
}

function Create_VGUI( vguiName, cockpit, player, bottomLeft, topRight, mod = null )
{
	local forward, right, up
	local sizeX = 1.0
	local sizeY = 1.0
	if ( mod )
	{
		forward = mod.forward
		right = mod.right
		up = mod.up
		sizeX = mod.sizeX
		sizeY = mod.sizeY
	}

	local bottomLeftID
	local topRightID
	local attachment
	local size
	local isTitanCockpit = IsTitanCockpitModelName( cockpit.GetModelName() )

	local origin
	local angles

	Assert( isTitanCockpit )

	bottomLeftID = cockpit.LookupAttachment( bottomLeft )
	topRightID = cockpit.LookupAttachment( topRight )
	attachment = bottomLeft
	size = ComputeSizeForAttachments( cockpit, bottomLeftID, topRightID, false )
	size[0] *= sizeX
	size[1] *= sizeY

	origin = cockpit.GetAttachmentOrigin( bottomLeftID )
	angles = cockpit.GetAttachmentAngles( bottomLeftID )

	// push the origin "out" slightly, since the tags are coplanar with the cockpit screen geo
	origin += angles.AnglesToUp() * 0.01

	if ( forward )
		origin += angles.AnglesToForward() * forward

	if ( right )
		origin += angles.AnglesToRight() * right

	if ( up )
		origin += angles.AnglesToUp() * up

	local vgui = CreateClientsideVGuiScreen( vguiName, VGUI_SCREEN_PASS_HUD, origin, angles, size[0], size[1] )
	local panel = vgui.GetPanel()
	vgui.s.panel <- panel
	vgui.SetParent( cockpit, attachment )
	return vgui
}

function Create_PilotVGUI( vguiName, cockpit, player, sizex, sizey, xOffset = 0, yOffset = 0 )
{
	local bottomLeftID
	local topRightID
	local size
	local attachment = "camera_base"
	local attachID = cockpit.LookupAttachment( attachment )
	size = [sizex, sizey]

	local origin = cockpit.GetAttachmentOrigin( attachID )
	local angles = cockpit.GetAttachmentAngles( attachID )


	origin += angles.AnglesToUp() * 0.01

	origin += (angles.AnglesToForward() * 150)
	origin -= (angles.AnglesToRight() * (size[0] * ( 0.5 - xOffset )))
	origin -= (angles.AnglesToUp() * (size[1] * ( 0.5 - yOffset )))
//	local up = angles.AnglesToUp()
//	origin += (up * (size[1] * -1.0) )
//	origin += up * 50.0
	if ( xOffset < 0 )
		angles = angles.AnglesCompose( Vector( 0, -75, 90 ) )
	else if ( xOffset > 0 )
		angles = angles.AnglesCompose( Vector( 0, -105, 90 ) )
	else
		angles = angles.AnglesCompose( Vector( 0, -90, 90 ) )


	local vgui = CreateClientsideVGuiScreen( vguiName, VGUI_SCREEN_PASS_HUD, origin, angles, size[0], size[1] );
	local panel = vgui.GetPanel()
	vgui.s.panel <- panel
	vgui.SetParent( cockpit, attachment )
	return vgui
}


function GetCockpitCoords( cockpit, player, bottomLeft, topRight, attachment )
{
	local table = {}
	table.size <- [7.0, 7.0]
	table.origin <- Vector( 0, 0, 0 )
	table.angles <- Vector( 0, 0, 0 )
	table.attachment <- "CAMERA_BASE"

	if ( IsTitanCockpitModelName( cockpit.GetModelName() ) )
	{
		table.attachment = attachment

		local bottomLeftID = cockpit.LookupAttachment( bottomLeft )
		local topRightID = cockpit.LookupAttachment( topRight )

		table.size = ComputeSizeForAttachments( cockpit, bottomLeftID, topRightID, false )
		table.size[0] -= 0.5
		table.size[1] -= 0.5

		table.origin.x += 0.25
		table.origin.y += 0.1875
		return table
	}

	if ( player.IsTitan() )
	{
		table.origin += (angles.AnglesToForward() * -1.75)
	}
	else
	{
		// pilots
		table.origin += (table.angles.AnglesToForward() * 18)
		table.origin -= (table.angles.AnglesToRight() * (table.size[0] * 2.45))
		table.origin += (table.angles.AnglesToUp() * 2.5)

		table.angles = table.angles.AnglesCompose( Vector( 0, -90, 90 ) )
	}

	return table
}


function Create_TitanMinimap( cockpit, player )
{
	if ( !IsValid( cockpit ) )
		return

	Assert( player.IsTitan() )
	local size
	local linkScreen

	size = [7.0, 7.0]

	local attachment = "CAMERA_BASE"
	local attachId = cockpit.LookupAttachment( attachment )
	local origin = Vector( 0, 0, 0 )
	local angles = Vector( 0, 0, 0 )

	local bottomLeftID = cockpit.LookupAttachment( "SCR_TL_BL" );
	local topRightID = cockpit.LookupAttachment( "SCR_TL_TR" );

	attachment = "SCR_TL_BL"
	attachId = cockpit.LookupAttachment( attachment )
	size = ComputeSizeForAttachments( cockpit, bottomLeftID, topRightID, false )

	// HACK; magic numbers suck and will break in other cockpits.
	size[0] -= 0.5
	size[1] -= 0.5

	// MORE HACKs; magic numbers suck and will break in other cockpits.
	origin.x += 0.25
	origin.y += 0.1875

	cockpit.s.threatHudVGUI <- CreateClientsideVGuiScreen( "vgui_titan_threat", VGUI_SCREEN_PASS_HUD, origin, angles, size[0], size[1] )
	level.EMP_vguis.append( cockpit.s.threatHudVGUI )
	cockpit.s.threatHudVGUI.s.panel <- cockpit.s.threatHudVGUI.GetPanel()

	cockpit.s.threatHudVGUI.SetParent( cockpit, attachment )
	cockpit.s.threatHudVGUI.SetAttachOffsetOrigin( origin )
	cockpit.s.threatHudVGUI.SetAttachOffsetAngles( angles )
}

function TitanCockpitThink( cockpit )
{
	local player = GetLocalViewPlayer()

	Assert( player.IsTitan(), player + " is not a titan" )

	waitthread TitanHudUpdate( cockpit, player )

	if ( cockpit.s.threatHudVGUI )
		cockpit.s.threatHudVGUI.Destroy()

	foreach ( attacker, attackerInfo in clone player.s.trackedAttackers )
	{
		delete player.s.trackedAttackers[ attacker ]
	}

	if ( "vduVGUI" in cockpit.s )
		cockpit.s.vduVGUI.Destroy()

	// Clear these since next time we get into the titan they get recreated
	level.EMP_vguis = []
}


function TitanHudUpdate( cockpit, player )
{
	if ( !IsAlive( player ) )
		return

	player.EndSignal( "OnDeath" )
	cockpit.EndSignal( "OnDestroy" )

	local e = {}
	e.dashVisible <- false
	e.healthFrac <- null
	e.nextBeepTime <- 0
	e.damageBeepDuration <- GetSoundDuration( "titan_damage_beep" ) + 0.25
	e.reserveStartTime <- 0
	e.ejectBeepDuration <- GetSoundDuration( "titan_eject_beeps" )

	thread TitanCockpit_WarningAudio( cockpit, player )

	while ( true )
	{
		UpdateHudEMPState( player, cockpit )

		wait 0
	}
}

function TitanHud_EjectHintThink( cockpit, player )
{
	cockpit.EndSignal( "OnDestroy" )

	local isDoomed = player.GetDoomedState()
	local wasDoomed = isDoomed

	while ( true )
	{
		WaitSignal( player, "EjectHintUpdate", "Doomed" )

		thread AnimateEjectIcon( cockpit, player )

		isDoomed = player.GetDoomedState()

		local ejectEnableTimeDiff = Time() - player.s.ejectEnableTime
		local ejectTimeDiff = Time() - player.s.ejectPressTime

		if ( isDoomed && !wasDoomed )
		{
			cockpit.s.ejectHintGroup.Show()
			cockpit.s.ejectHintGroup.SetAlpha( 255 )
			//INTERPOLATOR_PULSE
			//AlertDpadIcon( player, BUTTON_DPAD_UP, 3, 10 )

			wasDoomed = true
		}

		if ( (ejectEnableTimeDiff == 0 || ejectTimeDiff == 0) && !isDoomed )
		{
			cockpit.s.crosshairHealthLabel.SetText( "#HUD_EJECT" )

			cockpit.s.ejectHintGroup.Show()

			if ( ejectEnableTimeDiff == 0 )
				cockpit.s.ejectHintGroup.SetAlpha( 255 )

			if ( !EjectHint_GetVisible( player, 1 ) )
				cockpit.s.crosshairHealthEjectRingA.Hide()

			if ( !EjectHint_GetVisible( player, 2 ) )
				cockpit.s.crosshairHealthEjectRingB.Hide()

			if ( !EjectHint_GetVisible( player, 3 ) )
				cockpit.s.crosshairHealthEjectRingC.Hide()

			cockpit.s.ejectHintGroup.FadeOverTime( 0, EJECT_FADE_TIME )
		}
		else
		{
			if ( !EjectHint_GetVisible( player, 1 ) )
				cockpit.s.crosshairHealthEjectRingA.Hide()
			else
				cockpit.s.crosshairHealthEjectRingA.Show()

			if ( !EjectHint_GetVisible( player, 2 ) )
				cockpit.s.crosshairHealthEjectRingB.Hide()
			else
				cockpit.s.crosshairHealthEjectRingB.Show()

			if ( !EjectHint_GetVisible( player, 3 ) )
				cockpit.s.crosshairHealthEjectRingC.Hide()
			else
				cockpit.s.crosshairHealthEjectRingC.Show()
		}
	}
}

function AnimateEjectIcon( cockpit, player )
{
	local mainVGUI = cockpit.GetMainVGUI()
	if ( !mainVGUI )
		return

	player.Signal( "EjectHintUpdate" )
	player.EndSignal( "EjectHintUpdate" )
	cockpit.EndSignal( "OnDestroy" )
	mainVGUI.EndSignal( "OnDestroy" )

	for ( ;; )
	{
		mainVGUI.s.panel.RunAnimationScript( "AnimateEjectIcon" )
		wait 0.2
	}
}

function TitanCockpit_WarningAudio( cockpit, player )
{
	local duration = 1.0
	local healthFrac = GetHealthFrac( player )

	local damageBeepDuration = GetSoundDuration( "titan_damage_beep" ) + 0.25
	local ejectBeepDuration = GetSoundDuration( "titan_eject_beeps" )

	local isDoomed = player.GetDoomedState()
	local wasDoomed = isDoomed

	while ( IsValid( cockpit ) )
	{
		duration = 1.0
		healthFrac = GetHealthFrac( player )
		isDoomed = player.GetDoomedState()

		if ( !isDoomed )
		{
			local shieldFrac = GetShieldHealthFrac( player )

			if ( shieldFrac == 0 )
			{
				duration = damageBeepDuration
				EmitSoundOnEntity( player, "titan_damage_beep" )
			}
		}
		else
		{
			if ( !wasDoomed )
			{
				if ( PlayerHasPassive( player, PAS_AUTO_EJECT ) )
					TitanCockpit_PlayDialog( player, "autoeject" )
				else
					TitanCockpit_PlayDialog( player, "doomed" )
				wasDoomed = true
			}

			if ( healthFrac <= 0.5 )
				TitanCockpit_PlayDialog( player, "suggest_eject" )

			EmitSoundOnEntity( player, "titan_eject_beeps" )
			duration = ejectBeepDuration
		}

		wait duration
	}
}


function HideThreatHud( player, cockpit )
{
	cockpit.s.threatHudBackground.Hide()
	cockpit.s.threatHudBackgroundShadow.Hide()
}

function UpdateHudEMPState( player, cockpit )
{
	// Get Alpha
	local alpha = 255
	if ( cockpit.s.empInfo.startTime != 0 )
		alpha = ( 1.0 - TitanCockpit_EMPFadeScale( cockpit ) ) * 255

	if ( alpha == level.lastHudEMPStateAlpha )
		return

	level.lastHudEMPStateAlpha = alpha

	// Update Alpha
	for ( local i = 0; i < level.EMP_vguis.len(); i++ )
	{
		local vgui = level.EMP_vguis[i]
		if ( !IsValid( vgui ) )
		{
			level.EMP_vguis.remove( i )
			i--
		}
		else
		{
			vgui.SetAlpha( alpha )
		}
	}
}
