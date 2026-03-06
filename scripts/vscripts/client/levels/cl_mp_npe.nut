TITAN_CORE_ENABLED = false

function main()
{
	IncludeScript( "mp_npe_shared" )

	if ( !IsTrainingMode() )
	{
		IncludeScript( "client/levels/cl_mp_npe_multiplayer" )
		return
	}

	Globalize( ServerCallback_SetFreezePlayerControls )
	Globalize( ScriptCallback_NPE_ModuleChanging )
	Globalize( ScriptCallback_DestroyPlayerCockpit )
	Globalize( ScriptCallback_SetupLookTargets )
	Globalize( ScriptCallback_LookTargets_WaitForLookat )
	Globalize( ScriptCallback_LookTargets_KillLights )
	Globalize( ServerCallback_PilotTrainingStart )
	Globalize( ServerCallback_TrainingTeleport )
	Globalize( ServerCallback_CleanupCorpses )
	Globalize( ServerCallback_ShowIntroScreen )
	Globalize( ServerCallback_DisplayTrainingPrompt )
	Globalize( ServerCallback_HideTrainingPrompt )
	Globalize( ServerCallback_EnableTitanModeHUD )
	Globalize( ServerCallback_EnableTitanDisembark )
	Globalize( ServerCallback_DisableTitanDisembark )
	Globalize( ServerCallback_EnableTitanModeChange )
	Globalize( ServerCallback_EnableTitanModeChange_Once )
	Globalize( ServerCallback_DisableTitanModeChange )
	Globalize( ScriptCallback_NPE_TrackPlayerDashMeter )
	Globalize( ScriptCallback_NPE_TrackPlayerDashMeter_Stop )
	Globalize( ServerCallback_SetTrainingResumeChoice )
	Globalize( ServerCallback_Turbulence )
	Globalize( ServerCallback_EnableFog )
	Globalize( ServerCallback_DisableFog )
	Globalize( ServerCallback_ResetHoloscreen )
	Globalize( ServerCallback_FadeHoloscreen )
	Globalize( ServerCallback_SetMeleePromptEnabled )
	Globalize( ServerCallback_SetPlayerHasFinishedTraining )
	Globalize( VMTCallback_NPE_HoloScreen_Alpha )

	Globalize( ControllerImageHint_Sprint )
	Globalize( ControllerImageHint_Melee )
	Globalize( ControllerImageHint_Bumper )
	Globalize( ControllerImageHint_DPad )
	Globalize( ControllerImageHint_OffhandDefensive )
	Globalize( ControllerImageHint_OffhandOffensive )
	Globalize( StopControllerImageHint )
	Globalize( HUDHintPulse )
	Globalize( StopHintPulse )
	Globalize( HighlightMinimap )
	Globalize( StopHighlightMinimap )

	AddCreateCallback( "player", PlayerCreated )

	RegisterConCommandTriggeredCallback( "+useAndReload", ScriptCallback_NPE_PlayerPressedReload )
	RegisterConCommandTriggeredCallback( "+reload", ScriptCallback_NPE_PlayerPressedReload )  // keyboard input mapping
	RegisterConCommandTriggeredCallback( "+weaponPickupAndCycle", ScriptCallback_NPE_PlayerPressedWeaponSwitch )
	RegisterConCommandTriggeredCallback( "+weaponCycle", ScriptCallback_NPE_PlayerPressedWeaponSwitch )
	RegisterConCommandTriggeredCallback( "+offhand1", ScriptCallback_NPE_FiredOffhandOffensive )
	RegisterConCommandTriggeredCallback( "+jump", ScriptCallback_NPE_PlayerJumped )
	RegisterConCommandTriggeredCallback( "+dodge", ScriptCallback_NPE_PlayerDashed )

	AddLocalPlayerDidDamageCallback( ScriptCallback_NPE_MarvinBodyshot )
	file.alreadyHitMarvinBodyshot <- false

	FirstIntroScreenSetup()

	level.STICK_CLICK_UP 	<- "../ui/menu/controls_menu/stickClick_up"
	level.STICK_CLICK_DOWN 	<- "../ui/menu/controls_menu/stickClick_down"
	PrecacheHUDMaterial( level.STICK_CLICK_UP )
	PrecacheHUDMaterial( level.STICK_CLICK_DOWN )

	PrecacheWeapon( "mp_projectile_orbital_strike" )

	RegisterSignal( "HideControllerImage" )
	RegisterSignal( "StopHintPulse" )
	RegisterSignal( "StopMinimapHighlight" )
	RegisterSignal( "ModuleChanging" )
	RegisterSignal( "StartWaitingForLookatTargets" )
	RegisterSignal( "StopHoloscreenFade" )
	RegisterSignal( "StopTrackingPlayerDashMeter" )

	level.FX_LIGHT_RED_POD 	<- PrecacheParticleSystem( "panel_light_red" )
	level.FX_LIGHT_BLUE_POD <- PrecacheParticleSystem( "panel_light_blue" )

	level.trainingPromptShowing <- false
	level.controllerImageHintDesired <- false  // so we can track the window of time when the server wants this to potentially display
	level.lastTrainingPrompt 	<- null
	level.gamepadStickLayout 	<- null
	level.gamepadButtonLayout 	<- null
	level.gamepadButtonsAreSouthpaw <- null

	level.cabinHoloScreenAlpha <- 1.0
	level.trainingPod <- null
	level.titanPetControlPanel <- null
	level.DAMAGE_DEBUG_PRINTS = null
	level.flags[ "EnableTitanModeChange" ] = false // level.ent does not exist yet

	// don't ever show the scoreboard or XP bar in this level
	level.showScoreboard = false
	level.showXPBar = false

	level.musicEnabled = false // Turn off all music in this level
	SetFullscreenMinimapParameters( 2.7, 1000, 1800, 0 )
}

function ServerCallback_SetMeleePromptEnabled( isEnabled )
{
	if ( isEnabled )
		FlagClear( "HideMeleePrompt" )
	else
		FlagSet( "HideMeleePrompt" )
}

function EntitiesDidLoad()
{
	if ( !IsTrainingMode()  )
		return

	local arr = GetEntArrayByClassAndTargetname( "prop_dynamic", "training_pod" )
	Assert( arr.len() == 1 )
	level.trainingPod = arr[ 0 ]
	level.trainingPod.s.lookTargets <- null

	// Titan pet control panel setup
	local arr = GetEntArrayByClassAndTargetname( "prop_control_panel", "control_panel_titan_pet" )
	Assert( arr.len() == 1 )
	level.titanPetControlPanel = arr[ 0 ]

	local arr = GetEntArrayByClassAndTargetname( "info_target", "controlpanel_target" )
	Assert( arr.len() == 1 )
	local controlPanelTarg = arr[ 0 ]
	level.titanPetControlPanel.s.targetArray.append( controlPanelTarg )

	Create_Display( level.titanPetControlPanel )

	//level.titanPetControlPanel.s.resfile = "control_panel_generic_screen"
	//level.titanPetControlPanel.s.VGUIFunc = Bind( VGUIUpdateLightTurret )
	//level.titanPetControlPanel.s.VGUISetupFunc = VGUISetupGeneric
}

function ScriptReloadables()
{
	SetupIntroscreens()
	RegisterTrainingPromptText()
	NPE_SetupRumble()
}

function PlayerCreated( ent, isRecreate )
{
	Assert( !isRecreate )

    printl( "NPE: PlayerCreated" )

	thread NPE_ClientBlackScreen()

	level.vduEnabled = true  // we want VDU radio but this only gets auto set when the VDU instance is found

	FlagInit( "PlayerDashInProgress" )

	SetupTrainingPrompt()
	SetupControllerImages()

	ClientCommand_SetTrainingVars( ent )

	thread HandleControlsChanging()
}

// this level skips normal gamestate changes (goes from 0 to 4 for connected client) so we have to do this custom to avoid seeing a flash of the level right at the start
function NPE_ClientBlackScreen()
{
	local player = GetLocalClientPlayer()

	if ( !IsValid( player ) )
		return

	player.EndSignal( "OnDestroy")

	printt( "NPE blacking out screen for connected client" )
	ClientSetScreenColor( 0, 0, 0, 255 )  //Set screen to black

	while ( GetGameState() != eGameState.Playing )
		wait 0

	printt( "NPE fading in screen for connected client over 0.8 sec" )
	ClientScreenFadeFromBlack( 0.8 )
}

// ------ ONSCREEN HELP ------
function SetupControllerImages()
{
	if ( !( "controllerImages" in level ) )
	{
		level.controllerImages 		<- HudElementGroup( "ControllerImages" )
		level.controllerBG	 		<- level.controllerImages.CreateElement( "ControllerImage" )
		level.leftStickArrow 		<- level.controllerImages.CreateElement( "ControllerCallout_LeftStick" )
		level.rightStickArrow 		<- level.controllerImages.CreateElement( "ControllerCallout_RightStick" )
		level.stickClickLeft 		<- level.controllerImages.CreateElement( "Controller_StickClick_Left" )
		level.stickClickRight 		<- level.controllerImages.CreateElement( "Controller_StickClick_Right" )

		level.stickOverlay_L 		<- level.controllerImages.CreateElement( "Controller_GrayStickOverlay_L" )
		level.stickOverlay_R 		<- level.controllerImages.CreateElement( "Controller_GrayStickOverlay_R" )

		level.bumper_L 				<- level.controllerImages.CreateElement( "ControllerCallout_Bumper_Left" )
		level.bumper_R 				<- level.controllerImages.CreateElement( "ControllerCallout_Bumper_Right" )
		level.bumperGlow_L 			<- level.controllerImages.CreateElement( "ControllerCallout_BumperGlow_Left" )
		level.bumperGlow_R 			<- level.controllerImages.CreateElement( "ControllerCallout_BumperGlow_Right" )

		level.dpad 					<- level.controllerImages.CreateElement( "ControllerCallout_DPad" )
		level.dpadGlow_L 			<- level.controllerImages.CreateElement( "ControllerCallout_DPadGlow_Left" )
		level.dpadGlow_Down 		<- level.controllerImages.CreateElement( "ControllerCallout_DPadGlow_Down" )
		level.dpadArrow_L 			<- level.controllerImages.CreateElement( "ControllerCallout_DPad_Arrow_Left" )
		level.dpadArrow_Down 		<- level.controllerImages.CreateElement( "ControllerCallout_DPad_Arrow_Down" )
	}
}

function ControllerImageHint_Sprint()
{
	Assert( "leftStickArrow" in level, "HUD elems might not be set up yet for leftStickArrow" )

	level.controllerImageHintDesired = true

	local clickType = "stickClickLeft"
	if ( level.gamepadButtonsAreSouthpaw )
		clickType = "stickClickRight"

	thread ControllerImageHint( clickType )
}

function ControllerImageHint_Melee()
{
	Assert( "rightStickArrow" in level, "HUD elems might not be set up yet for rightStickArrow" )

	level.controllerImageHintDesired = true

	local buttonLayout = level.gamepadButtonLayout
	// the image hint doesn't support this alternate control scheme
	if ( buttonLayout == 3 || buttonLayout == 4 )
		return

	local hintStr = "stickClickRight"
	// for this control scheme show the bumper instead
	if ( buttonLayout == 5 && !level.gamepadButtonsAreSouthpaw )
		hintStr = "bumperRight"
	else if ( buttonLayout == 5 && level.gamepadButtonsAreSouthpaw )
		hintStr = "bumperLeft"
	else if ( level.gamepadButtonsAreSouthpaw )
		hintStr = "stickClickLeft"

	thread ControllerImageHint( hintStr )
}

function ControllerImageHint_Bumper( bumperIdx )
{
	Assert( bumperIdx == 0 || bumperIdx == 1 )

	level.controllerImageHintDesired = true

	// the image hint doesn't support this alternate control scheme
	if ( level.gamepadButtonLayout == 5 )
		return

	local bumperStr = "bumperLeft"
	if ( bumperIdx == 1 )
		bumperStr = "bumperRight"

	thread ControllerImageHint( bumperStr )
}

function ControllerImageHint_DPad( dpadIdx )
{
	Assert( dpadIdx == 0 || dpadIdx == 1 )

	level.controllerImageHintDesired = true

	local dpadStr = "dpadLeft"
	if ( dpadIdx == 1 )
		dpadStr = "dpadDown"

	thread ControllerImageHint( dpadStr )
}

function ControllerImageHint_OffhandDefensive()
{
	level.controllerImageHintDesired = true

	local player = GetLocalViewPlayer()

	// Bumper Jumper or Bumper Jumper Pilot
	if ( level.gamepadButtonLayout == 1 || ( !player.IsTitan() && ( level.gamepadButtonLayout == 2 || level.gamepadButtonLayout == 3 ) ) )
		return

	local bumperStr = "bumperLeft"
	if ( level.gamepadButtonsAreSouthpaw )
		bumperStr = "bumperRight"

	thread ControllerImageHint( bumperStr )
}

function ControllerImageHint_OffhandOffensive()
{
	level.controllerImageHintDesired = true

	// fruit loop - fires with trigger, not bumper
	if ( level.gamepadButtonLayout == 5 )
		return

	local bumperStr = "bumperRight"
	if ( level.gamepadButtonsAreSouthpaw )
		bumperStr = "bumperLeft"

	thread ControllerImageHint( bumperStr )
}

// only gets called when we want to stop this from possibly displaying
function StopControllerImageHint()
{
	level.controllerImageHintDesired = false

	StopControllerImageHint_Internal()
}

// called directly to stop the hint when we might need to redraw it (settings change)
function StopControllerImageHint_Internal()
{
	level.ent.Signal( "HideControllerImage" )
	level.ent.Signal( "StopHintPulse" )

	level.controllerImages.Hide()
	level.controllerImages.ReturnToBasePos()
}

function ControllerImageHint( hintType )
{
	if ( !( "controllerImages" in level ) )
		return

	level.controllerBG.Show()

	if ( hintType == "stickClickLeft" || hintType == "stickClickRight" )
	{
		local swapElem = level.stickClickLeft
		local arrowElem = level.leftStickArrow
		local stickHideElem = level.stickOverlay_R

		if ( hintType == "stickClickRight" )
		{
			swapElem = level.stickClickRight
			arrowElem = level.rightStickArrow
			stickHideElem = level.stickOverlay_L
		}

		swapElem.SetImage( level.STICK_CLICK_UP )
		swapElem.Show()
		arrowElem.Show()
		stickHideElem.Show()

		thread SwapHUDElem( swapElem, level.STICK_CLICK_DOWN, level.STICK_CLICK_UP )
	}
	else if ( hintType == "bumperLeft" || hintType == "bumperRight" )
	{
		level.stickOverlay_L.Show()
		level.stickOverlay_R.Show()

		local buttonElem = level.bumper_L
		local glowElem = level.bumperGlow_L
		if ( hintType == "bumperRight" )
		{
			buttonElem = level.bumper_R
			glowElem = level.bumperGlow_R
		}

		buttonElem.Show()

		local pulseTime = 0.8
		local startOn = true
		thread PulseHUDElem( glowElem, pulseTime, startOn )
	}
	else if ( hintType == "dpadLeft" || hintType == "dpadDown" )
	{
		level.stickOverlay_L.Show()
		level.stickOverlay_R.Show()
		level.dpad.Show()

		local glowElem = level.dpadGlow_L
		local arrowElem = level.dpadArrow_L
		if ( hintType == "dpadDown" )
		{
			glowElem = level.dpadGlow_Down
			arrowElem = level.dpadArrow_Down
		}

		glowElem.Show()

		local pulseTime = 0.7
		thread PulseHUDElemColorAndScale( arrowElem, pulseTime )
		local startOn = true
		thread PulseHUDElem( glowElem, pulseTime, startOn )
	}
}

function SwapHUDElem( swapElem, swapImgDown, swapImgUp )
{
	level.ent.Signal( "HideControllerImage" )
	level.ent.EndSignal( "HideControllerImage" )

	local player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )

	local upTime = 0.9
	local downTime = 0.3
	local state = "up"

	wait downTime

	while ( 1 )
	{
		if ( state == "up" )
		{
			swapElem.SetImage( swapImgDown )
			state = "down"
			wait downTime
		}
		else
		{
			swapElem.SetImage( swapImgUp )
			state = "up"
			wait upTime
		}
	}
}

function StopHintPulse()
{
	level.ent.Signal( "StopHintPulse" )
}

function HUDHintPulse( elemID )
{
	local player = GetLocalViewPlayer()
	local cockpit = player.GetCockpit()

	local elem
	local pulseTime = 0.8
	local startOn = false
	// CLOAK (OFFHAND DEFENSIVE)
	if ( elemID == 0 )
	{
		elem = cockpit.s.offhandHud[ OFFHAND_LEFT ].outline
		startOn = true
	}
	// GRENADES (OFFHAND OFFENSIVE)
	else if ( elemID == 1 )
	{
		elem = cockpit.s.offhandHud[ OFFHAND_RIGHT ].outline
		startOn = true
	}
	// DASH
	else if ( elemID == 2 )
	{
		elem = cockpit.s.dashBarOutline
		pulseTime = 0.5
	}
	// TITAN AI CONTROL
	else if ( elemID == 3 )
	{
		elem = cockpit.s.mainVGUI.s.dpadIconBGOutline
	}
	Assert( elem )

	//level.ent.Signal( "StopHintPulse" )
	thread PulseHUDElem( elem, pulseTime, startOn, cockpit )
}

function PulseHUDElem( elem, pulseTime = 0.8, startOn = false, cockpit = null )
{
	level.ent.EndSignal( "StopHintPulse" )

	local player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )

	if ( IsValid( cockpit ) )
		cockpit.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( player, cockpit, elem )
		{
			if ( IsValid( player ) && elem.IsValidInternal() )
				elem.Hide()
		}
	)

	local state = "off"
	if ( startOn )
	{
		elem.Show()
		elem.SetAlpha( 255 )
		state = "on"
	}

	while ( 1 )
	{
		if ( state == "on" )
		{
			elem.HideOverTime( pulseTime )
			state = "off"
		}
		else if ( state == "off" )
		{
			elem.Show()
			elem.FadeOverTime( 255, pulseTime )
			state = "on"
		}

		wait pulseTime
	}
}

function PulseHUDElemColorAndScale( elem, pulseTime = 0.8 )
{
	level.ent.EndSignal( "StopHintPulse" )

	local player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( player, elem )
		{
			if ( IsValid( player ) && elem.IsValidInternal() )
			{
				elem.Hide()
				elem.ReturnToBaseSize()
				elem.ReturnToBaseColor()
			}
		}
	)

	elem.Show()

	local size = elem.GetSize()
	local color = elem.GetColor()
	local onColor = [ 255, 234, 0, 200 ]

	local scaleX = 2.5
	local scaleY = 3.0

	local state = "off"
	while ( 1 )
	{
		if ( state == "off" )
		{
			elem.ScaleOverTime( scaleX, scaleY, pulseTime, INTERPOLATOR_LINEAR )
			elem.ColorOverTime( onColor[0], onColor[1], onColor[2], onColor[3], pulseTime, INTERPOLATOR_ACCEL )
			state = "on"
		}
		else if ( state == "on" )
		{
			elem.ScaleOverTime( 1.0, 1.0, pulseTime, INTERPOLATOR_LINEAR )
			elem.ColorOverTime( color[0], color[1], color[2], 255, pulseTime, INTERPOLATOR_ACCEL )
			state = "off"
		}

		wait pulseTime
	}
}

function HighlightMinimap()
{
	thread HighlightMinimap_Threaded()
}

function HighlightMinimap_Threaded()
{
	level.ent.Signal( "StopMinimapHighlight" )
	level.ent.EndSignal( "StopMinimapHighlight" )
	level.ent.EndSignal( "ModuleChanging" )

	local player = GetLocalViewPlayer()
	local cockpit = player.GetCockpit()

	player.EndSignal( "OnDestroy" )
	cockpit.EndSignal( "OnDestroy" )
	level.ent.EndSignal( "ModuleChanging" )

	MinimapPulse( GetLocalViewPlayer() )

	local pulseWait = 0.5
	while ( 1 )
	{
		MinimapPulse( player )
		wait pulseWait
	}
}

function StopHighlightMinimap()
{
	level.ent.Signal( "StopMinimapHighlight" )
}


function RegisterTrainingPromptText()
{
	if ( !( "trainingPromptText" in level ) )
		level.trainingPromptText <- {}

	if ( !( "trainingPromptHeaders" in level ) )
		level.trainingPromptHeaders <- {}

	// for script reloading
	level.trainingPromptText = {}
	level.trainingPromptHeaders = {}

	AddTrainingPromptText( -1, "TRAINING PROMPT DEFAULT TEXT" )
	AddTrainingPromptHeader( -1, " ////////  INSTRUCTION  //////// " )

	AddTrainingPromptText( eTrainingButtonPrompts.START_SIM, 		"#NPE_START_TEXT_GP", "#NPE_START_TEXT_KB" )
	AddTrainingPromptHeader( eTrainingButtonPrompts.START_SIM, 		"#NPE_START_HEADER" )

	AddTrainingPromptText( eTrainingButtonPrompts.LOOK, 			"#NPE_LOOK_TEXT_GP", "#NPE_LOOK_TEXT_KB", "#NPE_LOOK_TEXT_GP_SOUTHPAW", "#NPE_LOOK_TEXT_GP", "#NPE_LOOK_TEXT_GP_SOUTHPAW" )
	AddTrainingPromptHeader( eTrainingButtonPrompts.LOOK, 			"#NPE_LOOK_HEADER" )

	AddTrainingPromptText( eTrainingButtonPrompts.MOVE, 			"#NPE_MOVE_TEXT_GP", "#NPE_MOVE_TEXT_KB", "#NPE_MOVE_TEXT_GP_SOUTHPAW", "#NPE_MOVE_TEXT_GP_LEGACY", "#NPE_MOVE_TEXT_GP_LEGACYSOUTHPAW" )
	AddTrainingPromptHeader( eTrainingButtonPrompts.MOVE, 			"#NPE_MOVE_HEADER" )

	AddTrainingPromptText( eTrainingButtonPrompts.MOVEFORWARD, 		"#NPE_MOVEFORWARD_TEXT_GP", "#NPE_MOVEFORWARD_TEXT_KB", "#NPE_MOVEFORWARD_TEXT_GP_SOUTHPAW", "#NPE_MOVEFORWARD_TEXT_GP", "#NPE_MOVEFORWARD_TEXT_GP_SOUTHPAW" )
	AddTrainingPromptHeader( eTrainingButtonPrompts.MOVEFORWARD, 	"#NPE_MOVEFORWARD_HEADER"  )

	AddTrainingPromptText( eTrainingButtonPrompts.SPRINT, 			"#NPE_SPRINT_TEXT_GP", "#NPE_SPRINT_TEXT_KB", null, null, "#NPE_SPRINT_TEXT_GP_FACEBUTTON" )
	AddTrainingPromptHeader( eTrainingButtonPrompts.SPRINT, 		"#NPE_SPRINT_HEADER" )

	AddTrainingPromptText( eTrainingButtonPrompts.JUMP, 			 "#NPE_JUMP_TEXT_GP" )
	AddTrainingPromptHeader( eTrainingButtonPrompts.JUMP, 			 "#NPE_JUMP_HEADER" )

	AddTrainingPromptText( eTrainingButtonPrompts.LONGJUMP, 		 "#NPE_LONGJUMP_TEXT_GP" )
	AddTrainingPromptHeader( eTrainingButtonPrompts.LONGJUMP, 		 "#NPE_LONGJUMP_HEADER" )

	AddTrainingPromptText( eTrainingButtonPrompts.MANTLE, 			"#NPE_MANTLE_TEXT_GP", "#NPE_MANTLE_TEXT_KB", "#NPE_MANTLE_TEXT_GP_SOUTHPAW", "#NPE_MANTLE_TEXT_GP", "#NPE_MANTLE_TEXT_GP_SOUTHPAW" )
	AddTrainingPromptHeader( eTrainingButtonPrompts.MANTLE, 		"#NPE_MANTLE_HEADER" )

	AddTrainingPromptText( eTrainingButtonPrompts.WALLRUN, 			"#NPE_WALLRUN_TEXT_GP", "#NPE_WALLRUN_TEXT_KB", "#NPE_WALLRUN_TEXT_GP_SOUTHPAW", "#NPE_WALLRUN_TEXT_GP", "#NPE_WALLRUN_TEXT_GP_SOUTHPAW" )
	AddTrainingPromptHeader( eTrainingButtonPrompts.WALLRUN, 		"#NPE_WALLRUN_HEADER" )

	AddTrainingPromptText( eTrainingButtonPrompts.WALLRUN_EXTEND, 	"#NPE_WALLRUN_EXTENDED_TEXT_GP", "#NPE_WALLRUN_EXTENDED_TEXT_KB", "#NPE_WALLRUN_EXTENDED_TEXT_GP_SOUTHPAW", "#NPE_WALLRUN_EXTENDED_TEXT_GP", "#NPE_WALLRUN_EXTENDED_TEXT_GP_SOUTHPAW" )
	AddTrainingPromptHeader( eTrainingButtonPrompts.WALLRUN_EXTEND, "#NPE_WALLRUN_EXTENDED_HEADER" )

	AddTrainingPromptText( eTrainingButtonPrompts.WALLRUN_DETACH, 	"#NPE_WALLRUN_DETACH_TEXT_GP" )
	AddTrainingPromptHeader( eTrainingButtonPrompts.WALLRUN_DETACH, "#NPE_WALLRUN_DETACH_HEADER" )

	AddTrainingPromptText( eTrainingButtonPrompts.DOUBLEJUMP, 		 "#NPE_DOUBLEJUMP_TEXT_GP" )
	AddTrainingPromptHeader( eTrainingButtonPrompts.DOUBLEJUMP, 	 "#NPE_DOUBLEJUMP_HEADER" )

	AddTrainingPromptText( eTrainingButtonPrompts.DOUBLEJUMP_FAR, 	 "#NPE_DOUBLEJUMP_FAR_TEXT_GP" )
	AddTrainingPromptHeader( eTrainingButtonPrompts.DOUBLEJUMP_FAR,  "#NPE_DOUBLEJUMP_FAR_HEADER" )

	AddTrainingPromptText( eTrainingButtonPrompts.CLOAK, 			 "#NPE_CLOAK_TEXT_GP" )
	AddTrainingPromptHeader( eTrainingButtonPrompts.CLOAK, 			 "#NPE_CLOAK_HEADER" )

	AddTrainingPromptText( eTrainingButtonPrompts.MELEE, 			"#NPE_MELEE_TEXT_GP", "#NPE_MELEE_TEXT_KB" )
	AddTrainingPromptHeader( eTrainingButtonPrompts.MELEE, 			"#NPE_MELEE_HEADER" )

	AddTrainingPromptText( eTrainingButtonPrompts.WEAPONSWITCH, 	"#NPE_WEAPONSWITCH_TEXT_GP", "#NPE_WEAPONSWITCH_TEXT_KB" )
	AddTrainingPromptHeader( eTrainingButtonPrompts.WEAPONSWITCH, 	"#NPE_WEAPONSWITCH_HEADER" )

	AddTrainingPromptText( eTrainingButtonPrompts.RELOAD, 			"#NPE_RELOAD_TEXT_GP", "#NPE_RELOAD_TEXT_KB" )
	AddTrainingPromptHeader( eTrainingButtonPrompts.RELOAD, 		"#NPE_RELOAD_HEADER" )

	AddTrainingPromptText( eTrainingButtonPrompts.FIREPRIMARY, 		"#NPE_FIREPRIMARY_TEXT_GP", "#NPE_FIREPRIMARY_TEXT_KB" )
	AddTrainingPromptHeader( eTrainingButtonPrompts.FIREPRIMARY, 	"#NPE_FIREPRIMARY_HEADER" )

	AddTrainingPromptText( eTrainingButtonPrompts.ADS, 				"#NPE_ADS_TEXT_GP", "#NPE_ADS_TEXT_KB" )
	AddTrainingPromptHeader( eTrainingButtonPrompts.ADS, 			"#NPE_ADS_HEADER" )

	AddTrainingPromptText( eTrainingButtonPrompts.FIREGRENADE, 		 "#NPE_FIREGRENADE_TEXT_GP" )
	AddTrainingPromptHeader( eTrainingButtonPrompts.FIREGRENADE, 	 "#NPE_FIREGRENADE_HEADER" )

	AddTrainingPromptText( eTrainingButtonPrompts.WEAPONSWITCH_AT, 		 "#NPE_WEAPONSWITCH_AT_TEXT_GP" )
	AddTrainingPromptHeader( eTrainingButtonPrompts.WEAPONSWITCH_AT, 	 "#NPE_WEAPONSWITCH_AT_HEADER" )

	AddTrainingPromptText( eTrainingButtonPrompts.PILOT_HEALTH, 	 "#NPE_PILOT_HEALTH_TEXT_GP" )
	AddTrainingPromptHeader( eTrainingButtonPrompts.PILOT_HEALTH, 	 "#NPE_PILOT_HEALTH_HEADER" )

	AddTrainingPromptText( eTrainingButtonPrompts.MOSHPIT_KILLGUYS, 	"#NPE_MOSHPIT_KILLGUYS_TEXT_GP"	)
	AddTrainingPromptHeader( eTrainingButtonPrompts.MOSHPIT_KILLGUYS, 	"#NPE_MOSHPIT_KILLGUYS_HEADER" )

	AddTrainingPromptText( eTrainingButtonPrompts.MOSHPIT_KILLTITAN, 	"#NPE_MOSHPIT_KILLTITAN_TEXT_GP" )
	AddTrainingPromptHeader( eTrainingButtonPrompts.MOSHPIT_KILLTITAN, 	"#NPE_MOSHPIT_KILLTITAN_HEADER" )

	AddTrainingPromptText( eTrainingButtonPrompts.CALL_TITAN, 		"#NPE_CALL_TITAN_TEXT_GP" )
	AddTrainingPromptHeader( eTrainingButtonPrompts.CALL_TITAN, 	"#NPE_CALL_TITAN_HEADER")

	AddTrainingPromptText( eTrainingButtonPrompts.ENTER_TITAN, 		 "#NPE_ENTER_TITAN_TEXT_GP", "#NPE_ENTER_TITAN_TEXT_KB" )
	AddTrainingPromptHeader( eTrainingButtonPrompts.ENTER_TITAN, 	"#NPE_ENTER_TITAN_HEADER" )

	AddTrainingPromptText( eTrainingButtonPrompts.TITAN_DASH, 		"#NPE_TITAN_DASH_TEXT_GP", "#NPE_TITAN_DASH_TEXT_KB" )
	AddTrainingPromptHeader( eTrainingButtonPrompts.TITAN_DASH, 	"#NPE_TITAN_DASH_HEADER" )

	AddTrainingPromptText( eTrainingButtonPrompts.DASH_LEFT, 		"#NPE_DASH_LEFT_TEXT_GP", "#NPE_DASH_LEFT_TEXT_KB", "#NPE_DASH_LEFT_TEXT_GP_SOUTHPAW", "#NPE_DASH_LEFT_TEXT_GP_SOUTHPAW", "#NPE_DASH_LEFT_TEXT_GP" )
	AddTrainingPromptHeader( eTrainingButtonPrompts.DASH_LEFT, 		"#NPE_DASH_LEFT_HEADER" )

	AddTrainingPromptText( eTrainingButtonPrompts.DASH_RIGHT, 		"#NPE_DASH_RIGHT_TEXT_GP", "#NPE_DASH_RIGHT_TEXT_KB", "#NPE_DASH_RIGHT_TEXT_GP_SOUTHPAW", "#NPE_DASH_RIGHT_TEXT_GP_SOUTHPAW", "#NPE_DASH_RIGHT_TEXT_GP" )
	AddTrainingPromptHeader( eTrainingButtonPrompts.DASH_RIGHT, 	"#NPE_DASH_RIGHT_HEADER" )

	AddTrainingPromptText( eTrainingButtonPrompts.DASH_FORWARD,		"#NPE_DASH_FORWARD_TEXT_GP", "#NPE_DASH_FORWARD_TEXT_KB", "#NPE_DASH_FORWARD_TEXT_GP_SOUTHPAW", "#NPE_DASH_FORWARD_TEXT_GP", "#NPE_DASH_FORWARD_TEXT_GP_SOUTHPAW" )
	AddTrainingPromptHeader( eTrainingButtonPrompts.DASH_FORWARD, 	"#NPE_DASH_FORWARD_HEADER" )

	AddTrainingPromptText( eTrainingButtonPrompts.DASH_BACK, 		"#NPE_DASH_BACK_TEXT_GP", "#NPE_DASH_BACK_TEXT_KB", "#NPE_DASH_BACK_TEXT_GP_SOUTHPAW", "#NPE_DASH_BACK_TEXT_GP", "#NPE_DASH_BACK_TEXT_GP_SOUTHPAW" )
	AddTrainingPromptHeader( eTrainingButtonPrompts.DASH_BACK, 		"#NPE_DASH_BACK_HEADER" )

	AddTrainingPromptText( eTrainingButtonPrompts.DASH_THREAT_HELP, 	"#NPE_DASH_THREAT_HELP_TEXT_GP" )
	AddTrainingPromptHeader( eTrainingButtonPrompts.DASH_THREAT_HELP, 	"#NPE_DASH_THREAT_HELP_HEADER" )

	AddTrainingPromptText( eTrainingButtonPrompts.TITAN_VORTEX, 	"#NPE_TITAN_VORTEX_TEXT_GP" )
	AddTrainingPromptHeader( eTrainingButtonPrompts.TITAN_VORTEX,   "#NPE_TITAN_VORTEX_HEADER" )

	AddTrainingPromptText( eTrainingButtonPrompts.TITAN_VORTEX_NAG, 	"#NPE_TITAN_VORTEX_NAG_TEXT_GP" )
	AddTrainingPromptHeader( eTrainingButtonPrompts.TITAN_VORTEX_NAG, 	"#NPE_TITAN_VORTEX_NAG_HEADER" )

	AddTrainingPromptText( eTrainingButtonPrompts.TITAN_VORTEX_STARTINGLINE, 	"#NPE_TITAN_VORTEX_STARTINGLINE_TEXT_GP" )
	AddTrainingPromptHeader( eTrainingButtonPrompts.TITAN_VORTEX_STARTINGLINE, 	"#NPE_TITAN_VORTEX_STARTINGLINE_HEADER" )

	AddTrainingPromptText( eTrainingButtonPrompts.VORTEX_REFIRE, 	"#NPE_VORTEX_REFIRE_TEXT_GP" )
	AddTrainingPromptHeader( eTrainingButtonPrompts.VORTEX_REFIRE, 	"#NPE_VORTEX_REFIRE_HEADER" )

	AddTrainingPromptText( eTrainingButtonPrompts.TITAN_DISEMBARK, 		"#NPE_TITAN_DISEMBARK_TEXT_GP", "#NPE_TITAN_DISEMBARK_TEXT_KB" )
	AddTrainingPromptHeader( eTrainingButtonPrompts.TITAN_DISEMBARK, 	"#NPE_TITAN_DISEMBARK_HEADER" )

	AddTrainingPromptText( eTrainingButtonPrompts.MOVE_TO_CONTROL_ROOM, 	"#NPE_MOVE_TO_CONTROL_ROOM_TEXT_GP" )
	AddTrainingPromptHeader( eTrainingButtonPrompts.MOVE_TO_CONTROL_ROOM,   "#NPE_MOVE_TO_CONTROL_ROOM_HEADER" )

	AddTrainingPromptText( eTrainingButtonPrompts.DATA_KNIFE, 		"#NPE_DATA_KNIFE_TEXT_GP", "#NPE_DATA_KNIFE_TEXT_KB" )
	AddTrainingPromptHeader( eTrainingButtonPrompts.DATA_KNIFE, 	"#NPE_DATA_KNIFE_HEADER" )

	AddTrainingPromptText( eTrainingButtonPrompts.TITAN_AI_MODE, 	"#NPE_TITAN_AI_MODE_TEXT_GP" )
	AddTrainingPromptHeader( eTrainingButtonPrompts.TITAN_AI_MODE,  "#NPE_TITAN_AI_MODE_HEADER"	)

	AddTrainingPromptText( eTrainingButtonPrompts.TITAN_OFFHAND_OFFENSIVE, 		"#NPE_TITAN_OFFHAND_OFFENSIVE_TEXT_GP" )
	AddTrainingPromptHeader( eTrainingButtonPrompts.TITAN_OFFHAND_OFFENSIVE, 	"#NPE_TITAN_OFFHAND_OFFENSIVE_HEADER" )

	AddTrainingPromptText( eTrainingButtonPrompts.TITAN_MOSH_PIT_SURVIVE, 	"#NPE_TITAN_MOSH_PIT_SURVIVE_TEXT_GP" )
	AddTrainingPromptHeader( eTrainingButtonPrompts.TITAN_MOSH_PIT_SURVIVE, "#NPE_TITAN_MOSH_PIT_SURVIVE_HEADER" )

	AddTrainingPromptText( eTrainingButtonPrompts.TITAN_SHIELDS, 	 "#NPE_TITAN_SHIELDS_TEXT_GP" )
	AddTrainingPromptHeader( eTrainingButtonPrompts.TITAN_SHIELDS, 	 "#NPE_TITAN_SHIELDS_HEADER" )

	AddTrainingPromptText( eTrainingButtonPrompts.TITAN_HEALTH, 	 "#NPE_TITAN_HEALTH_TEXT_GP" )
	AddTrainingPromptHeader( eTrainingButtonPrompts.TITAN_HEALTH, 	 "#NPE_TITAN_HEALTH_HEADER" )

	AddTrainingPromptText( eTrainingButtonPrompts.EJECT_CONFIRM, 	"#NPE_EJECT_CONFIRM_TEXT_GP", "#NPE_EJECT_CONFIRM_TEXT_KB" )
	AddTrainingPromptHeader( eTrainingButtonPrompts.EJECT_CONFIRM,  "#NPE_EJECT_CONFIRM_HEADER" )
}
// script_client DisplayTrainingPrompt( eTrainingButtonPrompts.MOVE )

function AddTrainingPromptText( id, gamepadStr, keyboardStr = null, gamepadSouthpaw = null, gamepadLegacy = null, gamepadLegacySouthpaw = null, gamepadButtonAlt = null )
{
	Assert( !( id in level.trainingPromptText ), "Tried to add training prompt text twice for ID: " + id )

	if ( keyboardStr == null )
		keyboardStr = gamepadStr

	level.trainingPromptText[ id ] <- { gamepad = gamepadStr, keyboard = keyboardStr, gamepadSouthpaw = gamepadSouthpaw, gamepadLegacy = gamepadLegacy, gamepadLegacySouthpaw = gamepadLegacySouthpaw, gamepadButtonAlt = gamepadButtonAlt }
}

function AddTrainingPromptHeader( id, headerStr )
{
	Assert( !( id in level.trainingPromptHeaders ), "Tried to add training prompt header twice for ID: " + id )

	level.trainingPromptHeaders[ id ] <- headerStr
}

function SetupTrainingPrompt()
{
	file.trainingPromptGroup			<- HudElementGroup( "ChallengePopup" )
	file.trainingPromptHeader_Keyboard 			<- file.trainingPromptGroup.CreateElement( "TrainingPromptHeader_Keyboard" )
	file.trainingPromptLabel_Keyboard 	<- file.trainingPromptGroup.CreateElement( "TrainingPromptLabel_Keyboard" )
	file.trainingPromptLabel_Keyboard_Condensed <- file.trainingPromptGroup.CreateElement( "TrainingPromptLabel_Keyboard_Condensed" )
	file.trainingPromptLabel_BufferRight_Keyboard 			<- file.trainingPromptGroup.CreateElement( "TrainingPromptLabel_BufferRight_Keyboard" )
	file.trainingPromptLabel_BufferRight_Keyboard_Condensed 	<- file.trainingPromptGroup.CreateElement( "TrainingPromptLabel_BufferRight_Keyboard_Condensed" )

	file.trainingPromptGroup.CreateElement( "TrainingPromptLabel_BufferLeft_Keyboard" )
	file.trainingPromptGroup.CreateElement( "TrainingPromptHeader_BufferLeft_Keyboard" )
	file.trainingPromptGroup.CreateElement( "TrainingPromptHeader_BufferRight_Keyboard" )
	file.trainingPromptGroup.CreateElement( "TrainingPromptHeader_BufferBottom_Keyboard" )
	file.trainingPromptGroup.CreateElement( "TrainingPromptHeader_SeparatorLine_Keyboard" )

	file.trainingPromptHeader_Gamepad 						<- file.trainingPromptGroup.CreateElement( "TrainingPromptHeader_Gamepad" )
	file.trainingPromptLabel_Gamepad 						<- file.trainingPromptGroup.CreateElement( "TrainingPromptLabel_Gamepad" )
	file.trainingPromptLabel_Gamepad_Condensed 				<- file.trainingPromptGroup.CreateElement( "TrainingPromptLabel_Gamepad_Condensed" )
	file.trainingPromptLabel_BufferRight_Gamepad 			<- file.trainingPromptGroup.CreateElement( "TrainingPromptLabel_BufferRight_Gamepad" )
	file.trainingPromptLabel_BufferRight_Gamepad_Condensed 	<- file.trainingPromptGroup.CreateElement( "TrainingPromptLabel_BufferRight_Gamepad_Condensed" )

	file.trainingPromptGroup.CreateElement( "TrainingPromptLabel_BufferLeft_Gamepad" )
	file.trainingPromptGroup.CreateElement( "TrainingPromptHeader_BufferLeft_Gamepad" )
	file.trainingPromptGroup.CreateElement( "TrainingPromptHeader_BufferRight_Gamepad" )
	file.trainingPromptGroup.CreateElement( "TrainingPromptHeader_BufferBottom_Gamepad" )
	file.trainingPromptGroup.CreateElement( "TrainingPromptHeader_SeparatorLine_Gamepad" )

	file.trainingPromptLabel_Keyboard.EnableKeyBindingIcons()
	file.trainingPromptLabel_Keyboard_Condensed.EnableKeyBindingIcons()
	file.trainingPromptLabel_Gamepad.EnableKeyBindingIcons()
	file.trainingPromptLabel_Gamepad_Condensed.EnableKeyBindingIcons()

	file.trainingPromptGroup.Hide()
}

function DisplayTrainingPrompt( promptID = -1 )
{
	Assert( promptID in level.trainingPromptText, "Couldn't find training prompt with ID " + promptID )

	local headerID = promptID
	if ( !( headerID in level.trainingPromptHeaders ) )
		headerID = -1

	local gamepadText = level.trainingPromptText[ promptID ].gamepad

	// maybe use a different string if the controls are setup differently than default
	local buttonLayout = level.gamepadButtonLayout
	local stickLayout = level.gamepadStickLayout
	local gamepadButtonsAreSouthpaw = level.gamepadButtonsAreSouthpaw

	// HACK- for differences in button layout strings it's easier to just special case them (fewer)
	if ( promptID == eTrainingButtonPrompts.SPRINT )
	{
		if ( buttonLayout == 3 )
			gamepadText = "#NPE_SPRINT_TEXT_GP_FACEBUTTON"  // sprint is on a face button
		else if ( gamepadButtonsAreSouthpaw )
			gamepadText = "#NPE_SPRINT_TEXT_GP_STICKCLICK_LEFTYBUTTONS"  // sprint is on the opposite stick than we expect

		if ( level.controllerImageHintDesired )
		{
			StopControllerImageHint_Internal()

			if ( buttonLayout != 3 )
				ControllerImageHint_Sprint()
		}
	}
	else if ( promptID == eTrainingButtonPrompts.MELEE )
	{
		if ( buttonLayout == 3 || buttonLayout == 4 || buttonLayout == 5 )
			gamepadText = "#NPE_MELEE_TEXT_GP_FACEBUTTON"
		else if ( gamepadButtonsAreSouthpaw )
			gamepadText = "#NPE_MELEE_TEXT_GP_LEFTYBUTTONS"

		if ( level.controllerImageHintDesired )
		{
			StopControllerImageHint_Internal()
			ControllerImageHint_Melee()
		}
	}
	// "Fruit Loop" aka Halo style stick click to ADS
	else if ( promptID == eTrainingButtonPrompts.ADS && buttonLayout == 5 )
	{
		gamepadText = "#NPE_ADS_TEXT_GP_STICKCLICK"
		if ( gamepadButtonsAreSouthpaw )
			gamepadText = "#NPE_ADS_TEXT_GP_STICKCLICK_SOUTHPAW"
	}
	else if ( promptID == eTrainingButtonPrompts.FIREGRENADE || promptID == eTrainingButtonPrompts.TITAN_OFFHAND_OFFENSIVE )
	{
		if ( buttonLayout == 5 )
		{
			if ( promptID == eTrainingButtonPrompts.FIREGRENADE )
				gamepadText = "#NPE_FIREGRENADE_TEXT_GP_TRIGGER"
			else
				gamepadText = "#NPE_TITAN_OFFHAND_OFFENSIVE_TEXT_GP_TRIGGER"
		}

		if ( level.controllerImageHintDesired )
		{
			StopControllerImageHint_Internal()
			ControllerImageHint_OffhandOffensive()
			HUDHintPulse( 1 )
		}
	}
	// otherwise get the special case string from the table
	else
	{
		switch ( stickLayout )
		{
			case 1:
				if ( level.trainingPromptText[ promptID ].gamepadSouthpaw != null )
					gamepadText = level.trainingPromptText[ promptID ].gamepadSouthpaw
				break

			case 2:
				if ( level.trainingPromptText[ promptID ].gamepadLegacy != null )
					gamepadText = level.trainingPromptText[ promptID ].gamepadLegacy
				break

			case 3:
				if ( level.trainingPromptText[ promptID ].gamepadLegacySouthpaw != null )
					gamepadText = level.trainingPromptText[ promptID ].gamepadLegacySouthpaw
				break
		}

		// use the text we've set up but maybe change the controller image hint
		if ( promptID == eTrainingButtonPrompts.CLOAK || promptID == eTrainingButtonPrompts.TITAN_VORTEX || promptID == eTrainingButtonPrompts.TITAN_VORTEX_NAG )
		{
			if ( level.controllerImageHintDesired )
			{
				StopControllerImageHint_Internal()
				ControllerImageHint_OffhandDefensive()
				HUDHintPulse( 0 )
			}
		}
	}

	//printt( "setting gamepadText to:", gamepadText )

	local keyboardText = level.trainingPromptText[ promptID ].keyboard

	file.trainingPromptLabel_Gamepad.SetText( gamepadText )
	file.trainingPromptLabel_Gamepad_Condensed.SetText( gamepadText )
	file.trainingPromptLabel_Keyboard.SetText( keyboardText )
	file.trainingPromptLabel_Keyboard_Condensed.SetText( keyboardText )

	local headerText = level.trainingPromptHeaders[ headerID ]
	file.trainingPromptHeader_Gamepad.SetText( headerText )
	file.trainingPromptHeader_Keyboard.SetText( headerText )

	file.trainingPromptGroup.Show()

	if ( ShouldUseCondensedLabelFont( gamepadText, file.trainingPromptLabel_Gamepad, keyboardText, file.trainingPromptLabel_Keyboard ) )
	{
		file.trainingPromptLabel_Gamepad.Hide()
		file.trainingPromptLabel_BufferRight_Gamepad.Hide()

		file.trainingPromptLabel_Keyboard.Hide()
		file.trainingPromptLabel_BufferRight_Keyboard.Hide()
	}
	else
	{
		file.trainingPromptLabel_Gamepad_Condensed.Hide()
		file.trainingPromptLabel_BufferRight_Gamepad_Condensed.Hide()

		file.trainingPromptLabel_Keyboard_Condensed.Hide()
		file.trainingPromptLabel_BufferRight_Keyboard_Condensed.Hide()
	}

	level.trainingPromptShowing = true
	level.lastTrainingPrompt = promptID
}

// need to check vs both string lengths and if either is too long, switch it
function ShouldUseCondensedLabelFont( gamepadText, gamepadElem, keyboardText, keyboardElem )
{
	local screenWidth = Hud.GetScreenSize()[0]
	local safeAreaWidth = level.safeArea.GetWidth()
	local safeArea_rightSide = ( screenWidth - safeAreaWidth ) / 2
	local elemAbsX = gamepadElem.GetAbsX()  // this includes left side safe area buffer
	local maxScreenWidth = screenWidth - elemAbsX - safeArea_rightSide

	local texts = [ gamepadText, keyboardText ]
	local elems = [ gamepadElem, keyboardElem ]

	foreach ( idx, elem in elems )
	{
		local elemWidth = elem.GetTextWidth()

		if ( elemWidth >= maxScreenWidth )
		{
			printt( "ShouldUseCondensedLabelFont: label elem would be:", elem.GetTextWidth(), "wide for loc str:", texts[ idx ] )
			printt( " -elem width would be greater than maxScreenWidth", maxScreenWidth, ", using condensed-font hudelem." )
			return true
		}
	}

	return false
}

function HideTrainingPrompt()
{
	file.trainingPromptGroup.Hide()

	level.trainingPromptShowing = false
}

function HandleControlsChanging()
{
	local player = GetLocalClientPlayer()
	player.EndSignal( "OnDestroy" )

	level.gamepadStickLayout = GetConVarInt( "gamepad_stick_layout" )
	level.gamepadButtonLayout = GetConVarInt( "gamepad_button_layout" )
	level.gamepadButtonsAreSouthpaw = GetConVarInt( "gamepad_buttons_are_southpaw" )
	local currSticks
	local currButtons
	local currButtonsAreSouthpaw
	local didChange

	while ( 1 )
	{
		didChange = false
		currSticks = GetConVarInt( "gamepad_stick_layout" )
		currButtons = GetConVarInt( "gamepad_button_layout" )
		currButtonsAreSouthpaw = GetConVarInt( "gamepad_buttons_are_southpaw" )

		if ( currSticks != level.gamepadStickLayout )
		{
			level.gamepadStickLayout = currSticks
			didChange = true
		}

		if ( currButtons != level.gamepadButtonLayout )
		{
			level.gamepadButtonLayout = currButtons
			didChange = true
		}

		if ( currButtonsAreSouthpaw != level.gamepadButtonsAreSouthpaw )
		{
			level.gamepadButtonsAreSouthpaw = currButtonsAreSouthpaw
			didChange = true
		}

		if ( didChange )
		{
			// re-display the training prompt to pick up any button/stick changes
			if ( level.trainingPromptShowing )
				DisplayTrainingPrompt( level.lastTrainingPrompt )
		}

		wait 0.5
	}
}

function ServerCallback_DisplayTrainingPrompt( promptID )
{
	DisplayTrainingPrompt( promptID )
}

function ServerCallback_HideTrainingPrompt()
{
	HideTrainingPrompt()
}

function ServerCallback_DisableFog()
{
	SetMapSetting_FogEnabled( false )
}

function ServerCallback_EnableFog()
{
	SetMapSetting_FogEnabled( true )
}


function ServerCallback_ResetHoloscreen()
{
	level.cabinHoloScreenAlpha = 1.0
}

function ServerCallback_FadeHoloscreen( fadeTime )
{
	if ( fadeTime == 0 )
	{
		level.cabinHoloScreenAlpha = 0
		return
	}

	thread FadeHoloscreen_Threaded( fadeTime )
}

function FadeHoloscreen_Threaded( flickerTime )
{
	// for iterating
	if ( level.cabinHoloScreenAlpha < 1.0 )
		level.cabinHoloScreenAlpha = 1.0

	//printt( "fading holoscreen" )

	level.ent.Signal( "StopHoloscreenFade" )
	level.ent.EndSignal( "StopHoloscreenFade" )

	local slowFlickerFrac = 0.4  // percentage of flickerTime that the slow flicker takes up
	local slowFlickerTime = flickerTime * slowFlickerFrac
	local fastFlickerStartTime = Time()
	local fastFlickerTime = flickerTime - slowFlickerTime
	local fastFlickerEnd = Time() + fastFlickerTime

	local state = true

	local maxAlpha = 1
	local minAlpha = 0.25
	local minAlphaStartFrac = 0.75  // start min alpha at this percentage of max alpha, then it goes down to minAlpha over fastFlickerTime
	local currMinAlpha

	local minFlickerWait = 0.03
	local maxFlickerWait = 0.1
	while ( Time() < fastFlickerEnd )
	{
		currMinAlpha = GraphCapped( Time(), fastFlickerStartTime, fastFlickerEnd, ( maxAlpha * minAlphaStartFrac ), minAlpha )  // don't start "off" state as totally see-through, fade to it
		local flickerWait = RandomFloat( minFlickerWait, maxFlickerWait )

		if ( !state )
		{
			level.cabinHoloScreenAlpha = maxAlpha
			state = true

		}
		else
		{
			level.cabinHoloScreenAlpha = currMinAlpha
			state = false

			flickerWait = RandomFloat( minFlickerWait, maxFlickerWait )
			flickerWait *= 0.5
		}

		wait flickerWait
	}

	local slowFlickerStartTime = Time()
	local slowFlickerEnd = Time() + slowFlickerTime

	local minAlpha = 0
	local minAlphaStartFrac = 0.25  // start min alpha at this percentage of max alpha, then it goes down to minAlpha over fastFlickerTime
	local maxAlpha = 1

	local minFlickerWait = 0.1
	local maxFlickerWait = 0.15 //0.18

	local minFlickerWait_end = 0.125
	local maxFlickerWait_end = 0.175

	local currMinFlickerWait
	local currMaxFlickerWait
	while ( Time() < slowFlickerEnd )
	{
		currMinAlpha = GraphCapped( Time(), slowFlickerStartTime, slowFlickerEnd, ( maxAlpha * minAlphaStartFrac ), minAlpha )

		currMinFlickerWait = GraphCapped( Time(), slowFlickerStartTime, slowFlickerEnd, minFlickerWait, minFlickerWait_end )
		currMaxFlickerWait = GraphCapped( Time(), slowFlickerStartTime, slowFlickerEnd, maxFlickerWait, maxFlickerWait_end )
		local flickerWait = RandomFloat( currMinFlickerWait, currMaxFlickerWait )

		if ( !state )
		{
			level.cabinHoloScreenAlpha = maxAlpha
			state = true
		}
		else
		{
			level.cabinHoloScreenAlpha = currMinAlpha
			state = false
			flickerWait *= 0.25
		}

		wait flickerWait
	}

	level.cabinHoloScreenAlpha = 0

	//printt( "holoscreen fade done" )
}

function VMTCallback_NPE_HoloScreen_Alpha( ent )
{
	return level.cabinHoloScreenAlpha
}


// ------ INTROSCREENS ------
function SetupIntroscreens()
{
	Assert( IsClient() )

	if ( !( "introscreens" in level ) )
		level.introscreens <- null

	level.introscreens = {}

	level.introscreens[ "titlecard" ] <- {}
	level.introscreens[ "titlecard" ].title <- "#INTRO_SCREEN_NPE_TITLE_LINE1"
	level.introscreens[ "titlecard" ].desc 	<- "#INTRO_SCREEN_NPE_TITLE_LINE2"

	level.introscreens[ "default" ] <- {}
	level.introscreens[ "default" ].title 	<- "Default Training Module Title"
	level.introscreens[ "default" ].desc 	<- "Descriptive Text"

	local idx = eTrainingModules.TEST
	level.introscreens[ idx ] <- {}
	level.introscreens[ idx ].title <- "Test Start Point"
	level.introscreens[ idx ].desc 	<- MakeModuleDesc( "Dev Stuff" )

	local idx = eTrainingModules.BEDROOM
	level.introscreens[ idx ] <- {}
	level.introscreens[ idx ].title <- "" //"Readying Up"
	level.introscreens[ idx ].desc 	<- "" //MakeModuleDesc( "location unavailable" )

	local idx = eTrainingModules.BEDROOM_END
	level.introscreens[ idx ] <- {}
	level.introscreens[ idx ].title <- "" //"Exiting Simulation..."
	level.introscreens[ idx ].desc 	<- "" //MakeModuleDesc( "To avoid disorientation, stay in pod until nausea subsides." )

	local idx = eTrainingModules.JUMP
	level.introscreens[ idx ] <- {}
	level.introscreens[ idx ].title <- MakeModuleTitle( idx )
	level.introscreens[ idx ].desc 	<- MakeModuleDesc( idx )

	local idx = eTrainingModules.WALLRUN
	level.introscreens[ idx ] <- {}
	level.introscreens[ idx ].title <- MakeModuleTitle( idx )
	level.introscreens[ idx ].desc 	<- MakeModuleDesc( idx )

	local idx = eTrainingModules.WALLRUN_PLAYGROUND
	level.introscreens[ idx ] <- {}
	level.introscreens[ idx ].title <- MakeModuleTitle( idx )
	level.introscreens[ idx ].desc 	<- MakeModuleDesc( idx )

	local idx = eTrainingModules.DOUBLEJUMP
	level.introscreens[ idx ] <- {}
	level.introscreens[ idx ].title <- MakeModuleTitle( idx )
	level.introscreens[ idx ].desc 	<- MakeModuleDesc( idx )

	local idx = eTrainingModules.DOUBLEJUMP_PLAYGROUND
	level.introscreens[ idx ] <- {}
	level.introscreens[ idx ].title <- MakeModuleTitle( idx )
	level.introscreens[ idx ].desc 	<- MakeModuleDesc( idx )

	local idx = eTrainingModules.CLOAK
	level.introscreens[ idx ] <- {}
	level.introscreens[ idx ].title <- MakeModuleTitle( idx )
	level.introscreens[ idx ].desc 	<- MakeModuleDesc( idx )

	local idx = eTrainingModules.BASIC_COMBAT
	level.introscreens[ idx ] <- {}
	level.introscreens[ idx ].title <- MakeModuleTitle( idx )
	level.introscreens[ idx ].desc 	<- MakeModuleDesc( idx )

	local idx = eTrainingModules.FIRINGRANGE
	level.introscreens[ idx ] <- {}
	level.introscreens[ idx ].title <- MakeModuleTitle( idx )
	level.introscreens[ idx ].desc 	<- MakeModuleDesc( idx )

	local idx = eTrainingModules.FIRINGRANGE_GRENADES
	level.introscreens[ idx ] <- {}
	level.introscreens[ idx ].title <- MakeModuleTitle( idx )
	level.introscreens[ idx ].desc 	<- MakeModuleDesc( idx )

	local idx = eTrainingModules.MOSH_PIT
	level.introscreens[ idx ] <- {}
	level.introscreens[ idx ].title <- MakeModuleTitle( idx )
	level.introscreens[ idx ].desc 	<- MakeModuleDesc( idx )

	local idx = eTrainingModules.TITAN_DASH
	level.introscreens[ idx ] <- {}
	level.introscreens[ idx ].title <- MakeModuleTitle( idx )
	level.introscreens[ idx ].desc 	<- MakeModuleDesc( idx )

	local idx = eTrainingModules.TITAN_VORTEX
	level.introscreens[ idx ] <- {}
	level.introscreens[ idx ].title <- MakeModuleTitle( idx )
	level.introscreens[ idx ].desc 	<- MakeModuleDesc( idx )

	local idx = eTrainingModules.TITAN_PET
	level.introscreens[ idx ] <- {}
	level.introscreens[ idx ].title <- MakeModuleTitle( idx )
	level.introscreens[ idx ].desc 	<- MakeModuleDesc( idx )

	local idx = eTrainingModules.TITAN_MOSH_PIT
	level.introscreens[ idx ] <- {}
	level.introscreens[ idx ].title <- MakeModuleTitle( idx )
	level.introscreens[ idx ].desc 	<- MakeModuleDesc( idx )
}

function MakeModuleTitle( idx )
{
	if ( idx == eTrainingModules.BEDROOM || idx == eTrainingModules.BEDROOM_END )
		return null

	local str = "#NPE_MODULE_TITLE_"

	str += ( idx + 1 )
	return str
}

function MakeModuleDesc( idx )
{
	local str = "#NPE_MODULE_DESC_"

	str += ( idx + 1 )
	return str
}

function FirstIntroScreenSetup()
{
	local line_1 = level.introscreens[ "titlecard" ].title
	local line_2 = level.introscreens[ "titlecard" ].desc
	IntroScreen_SetText( line_1, line_2 )

	CinematicIntroScreen_SetTextFadeTimes( TEAM_IMC, 			0.25, 3.5, 0.15 )
	CinematicIntroScreen_SetTextFadeTimes( TEAM_MILITIA, 		0.25, 3.5, 0.15 )

	CinematicIntroScreen_SetTextSpacingTimes( TEAM_IMC, 		0.5, 0.5 )
	CinematicIntroScreen_SetTextSpacingTimes( TEAM_MILITIA, 	0.5, 0.5 )

	CinematicIntroScreen_SetBlackscreenFadeTimes( TEAM_IMC, 	6.5, 0.5 )
	CinematicIntroScreen_SetBlackscreenFadeTimes( TEAM_MILITIA, 6.5, 0.5 )

	CinematicIntroScreen_SetTeamLogoFadeTimes( TEAM_IMC, 		0, 0.5, 1.0, 0.25 )
	CinematicIntroScreen_SetTeamLogoFadeTimes( TEAM_MILITIA, 	0, 0.5, 1.0, 0.25 )
}

function IntroScreen_SetText( line_1, line_2 )
{
	CinematicIntroScreen_SetText( TEAM_IMC, [ line_1, line_2 ] )
	CinematicIntroScreen_SetText( TEAM_MILITIA, [ line_1, line_2 ] )
}


function NPE_SetupRumble()
{
	local totalTime = 19

	// left = HEAVY motor
	local left_maxPower = 1.75
	local left_maxPowerAtTime = totalTime * 0.1
	local left_cruisePower = 0.2
	local left_cruisePowerAtTime = totalTime * 0.15

	// right = LIGHT motor
	local right_maxPower = 0.75
	local right_maxPowerAtTime = totalTime * 0.1
	local right_cruisePower = 0.15
	local right_cruisePowerAtTime = totalTime * 0.3

	// each vec = time, power
	local left = [ Vector( 0.0, 0.0 ), Vector( left_maxPowerAtTime, left_maxPower ), Vector( left_cruisePowerAtTime, left_cruisePower ), Vector( totalTime, 0.0 ) ]
	local right = [ Vector( 0.0, 0.0 ), Vector( right_maxPowerAtTime, right_maxPower ), Vector( right_cruisePowerAtTime, right_cruisePower ), Vector( totalTime, 0.0 ) ]
	local leftTrigger = []
	local rightTrigger = []

	Rumble_CreateGraph( "RumbleGraph_Turbulence", left, right, leftTrigger, rightTrigger )
	Rumble_CreatePlayParams( "Turbulence", { name = "RumbleGraph_Turbulence" } )
}

function ServerCallback_Turbulence()
{
	thread ServerCallback_Turbulence_Internal()
}

function ServerCallback_Turbulence_Internal()
{
	local player = GetLocalViewPlayer()

	if ( !IsAlive( player ) )
		return

	// NOT WORKING
	Rumble_Play( "Turbulence", {} )

	local amplitude
	local frequency
	local duration
	local nextShakeWait

	amplitude = 0.8
	frequency = 10
	duration = 6
	nextShakeWait = 3
	ClientScreenShake( amplitude, frequency, duration, Vector( 0, 0, 0 ) )

	wait nextShakeWait
	//printt( "shake2" )
	nextShakeWait = 4
	ClientScreenShake( amplitude, frequency, duration, Vector( 0, 0, 0 ) )

	wait nextShakeWait

	amplitude = 0.3
	frequency = 9
	duration = 8
	nextShakeWait = 4
	//printt( "shake3" )
	ClientScreenShake( amplitude, frequency, duration, Vector( 0, 0, 0 ) )

	wait nextShakeWait
	//printt( "shake4" )
	ClientScreenShake( amplitude, frequency, duration, Vector( 0, 0, 0 ) )
}


// ------ CALLBACKS ------
function ScriptCallback_SetupLookTargets()
{
	thread TrainingPod_SetupLookTargets()
}

function TrainingPod_SetupLookTargets()
{
	if ( level.trainingPod.s.lookTargets == null )
	{
		local targInfos = []
		targInfos.append( { attachName = "fx_lookat_top", clientCommand = "topTarget" } )  // dots are different when the lights are this close to the player
		targInfos.append( { attachName = "fx_lookat_bot", clientCommand = "bottomTarget" } )

		local lookTargets = []
		foreach ( targInfo in targInfos )
		{
			local attachName = targInfo.attachName

			local attachID = level.trainingPod.LookupAttachment( attachName )
			local attachOrg = level.trainingPod.GetAttachmentOrigin( attachID )
			local attachAng = level.trainingPod.GetAttachmentAngles( attachID )

			local lookTarget = CreateClientsideScriptMover( "models/dev/empty_model.mdl", attachOrg, attachAng )
			lookTarget.SetOrigin( attachOrg )
			lookTarget.SetAngles( attachAng )
			lookTarget.SetParent( level.trainingPod, attachName )

			lookTarget.s.attachName <- attachName
			lookTarget.s.fxHandle <- null
			lookTarget.s.clientCommand <- targInfo.clientCommand

			lookTargets.append( lookTarget )
		}

		level.trainingPod.s.lookTargets = lookTargets
	}
	else
	{
		foreach ( lookTarget in level.trainingPod.s.lookTargets )
		{
			KillClientFX( lookTarget.s.fxHandle )
		}
	}

	foreach ( lookTarget in level.trainingPod.s.lookTargets )
		ChangeClientFXOnRef( lookTarget, level.FX_LIGHT_RED_POD )
}

function ScriptCallback_LookTargets_KillLights()
{
	if ( !level.trainingPod.s.lookTargets )
		return

	foreach ( lookTarget in level.trainingPod.s.lookTargets )
	{
		if ( !("fxHandle" in lookTarget.s ) )
			continue

		KillClientFX( lookTarget.s.fxHandle )
	}
}

function ScriptCallback_LookTargets_WaitForLookat()
{
	level.ent.Signal( "StartWaitingForLookatTargets" )

	foreach ( lookTarget in level.trainingPod.s.lookTargets )
		thread TrainingPod_LookTarget_WaitForLookat_Think( lookTarget )
}

function TrainingPod_LookTarget_WaitForLookat_Think( lookTarget )
{
	local player = GetLocalViewPlayer()

	player.EndSignal( "OnDestroy" )
	level.ent.EndSignal( "ModuleChanging" )
	level.ent.EndSignal( "StartWaitingForLookatTargets" )

	local reqDist = 130
	local reqLookTime = 0.5
	local blinkFreq = 0.1
	local tickRate = 0.05

	local dist
	while ( 1 )
	{
		dist = GetDistFromLookTarget( lookTarget )

		while ( dist > reqDist )
		{
			wait tickRate
			dist = GetDistFromLookTarget( lookTarget )
		}

		local okEndTime = Time() + reqLookTime
		local nextBlinkTime = Time() + blinkFreq
		local blinkOn = false
		while ( dist <= reqDist && Time() < okEndTime )
		{
			wait tickRate

			if ( Time() >= nextBlinkTime )
			{
				if ( blinkOn )
				{
					//KillClientFX( lookTarget.s.fxHandle )
					ChangeClientFXOnRef( lookTarget, level.FX_LIGHT_RED_POD )
					EmitSoundOnEntity( player, "NPE_Scr_PodLightOn" )
					blinkOn = false
				}
				else
				{
					ChangeClientFXOnRef( lookTarget, level.FX_LIGHT_BLUE_POD )
					EmitSoundOnEntity( player, "NPE_Scr_PodLightOn" )
					blinkOn = true
				}

				nextBlinkTime = Time() + blinkFreq
			}

			dist = GetDistFromLookTarget( lookTarget )
		}

		// we waited long enough, break out
		if ( Time() >= okEndTime )
			break

		// otherwise set color back to incomplete
		ChangeClientFXOnRef( lookTarget, level.FX_LIGHT_RED_POD )
	}

	EmitSoundOnEntity( player, "NPE_Player_VerticalLookSucceed" )

	ChangeClientFXOnRef( lookTarget, level.FX_LIGHT_BLUE_POD )

	player.ClientCommand( lookTarget.s.clientCommand )
}

function GetDistFromLookTarget( lookTarget )
{
	local screenCenter = []
	screenCenter.append( Hud.GetScreenSize()[0] * 0.5 ) // x
	screenCenter.append( Hud.GetScreenSize()[1] * 0.5 ) // y

	local lightScreenPos = Hud.ToScreenSpace( lookTarget.GetOrigin() )
	local xOffset = fabs( screenCenter[ 0 ] - lightScreenPos[0] )
	local yOffset = fabs( screenCenter[ 1 ] - lightScreenPos[1] )
	local dist = sqrt( ( xOffset * xOffset ) + ( yOffset * yOffset ) )

	//printt( lookTarget.s.attachName, "dist", dist )

	return dist
}


function KillClientFX( fxHandle )
{
	if ( !fxHandle || !EffectDoesExist( fxHandle ) )
		return

	EffectStop( fxHandle, true, false )
}

function ChangeClientFXOnRef( fxSpot, fxAlias )
{
	if ( "fxHandle" in fxSpot.s )
	{
		KillClientFX( fxSpot.s.fxHandle)
		fxSpot.s.fxHandle = null
	}
	else
	{
		fxSpot.s.fxHandle <- null
	}

	fxSpot.s.fxHandle = StartParticleEffectOnEntity( fxSpot, fxAlias, FX_PATTACH_ROOTBONE_FOLLOW, -1 )
}


function ServerCallback_SetFreezePlayerControls( doFreeze )
{
	local player = GetLocalClientPlayer()

	//printt( "freezing player controls?", doFreeze )

	if ( doFreeze )
		player.FreezeControlsOnClient()
	else
		player.UnfreezeControlsOnClient()
}


function ScriptCallback_NPE_ModuleChanging()
{
	level.ent.Signal( "ModuleChanging" )

	StopControllerImageHint()
	StopHintPulse()
}

function ScriptCallback_DestroyPlayerCockpit()
{
	local player = GetLocalClientPlayer()
	local cockpit = player.GetCockpit()
	if ( cockpit )
		cockpit.Destroy()
}

function ServerCallback_ShowIntroScreen( idx = null )
{
	// first one is special
	if ( idx == 0 )
		idx = "titlecard"

	if ( idx == null )
		idx = "default"

	if ( !( idx in level.introscreens ) )
		idx = "default"

	if ( idx == eTrainingModules.BEDROOM )
	{
		thread SimpleBlackscreen( 3, 0.5 )
		return
	}

	local title 	= level.introscreens[ idx ].title
	local desc 		= level.introscreens[ idx ].desc

	IntroScreen_SetText( title, desc )

	if ( idx == eTrainingModules.BEDROOM || idx == eTrainingModules.BEDROOM_END )
	{
		CinematicIntroScreen_SetUseLoadingIcon( false )
	}
	else
	{
		CinematicIntroScreen_SetUseLoadingIcon( true )
	}

	local forced = true
	thread CinematicIntroScreen( forced )
}

function SimpleBlackscreen( waitTime, fadeTime )
{
	local player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )
	level.ent.EndSignal( "ModuleChanging" )

	//printt( "showing blackscreen" )

	local allElems = HudElementGroup( "IntroScreen" )
	local background = allElems.CreateElement( "IntroScreenBackground" )

	background.SetColor( 0, 0, 0, 255 )
	background.Show()
	player.FreezeControlsOnClient()

	OnThreadEnd(
		function() : ( player, allElems )
		{
			//printt( "blackscreen done" )

			if ( IsValid( player ) )
				allElems.Hide()
		}
	)

	// this function unfreezes the controls
	thread BlackScreenFadeOut( background, waitTime, fadeTime )

	wait waitTime + fadeTime
}

function ServerCallback_PilotTrainingStart()
{
	local player = GetLocalViewPlayer()

	TitanModeHUD_Disable( player )
	HideGameProgressScoreboard_ForPlayer( player )
}

function ServerCallback_TrainingTeleport()
{
	thread TrainingTeleport_Threaded()
}

function TrainingTeleport_Threaded()
{
	local player = GetLocalClientPlayer()
	player.EndSignal( "OnDestroy" )

	local maxValue = 0.175
	local duration = 0.25
	local fadeTime = 0.4
	local doFlash = true
	local doSound = false // we have our own special sounds for this level

	if ( player.IsTitan() )
		thread ServerCallback_TitanEMP( maxValue, duration, fadeTime, doFlash, doSound )
	else
		thread ServerCallback_PilotEMP( maxValue, duration, fadeTime, doFlash, doSound )

	EmitSoundOnEntity( player, "NPE_VisualImpair" )
	wait duration
	FadeOutSoundOnEntity( player, "NPE_VisualImpair", fadeTime )
	wait fadeTime
}

function ServerCallback_CleanupCorpses()
{
	RemoveAllRagdolls()
}

function ServerCallback_EnableTitanModeHUD()
{
	local player = GetLocalViewPlayer()

	TitanModeHUD_Enable( player )
	UpdateTitanModeHUD( player )
}

function ServerCallback_EnableTitanDisembark()
{
	RegisterConCommandTriggeredCallback( "+useAndReload", PlayerPressed_Disembark )
	RegisterConCommandTriggeredCallback( "+use", PlayerPressed_Disembark )

	RegisterConCommandTriggeredCallback( "-useAndReload", PlayerReleased_Disembark )
	RegisterConCommandTriggeredCallback( "-use", PlayerReleased_Disembark )
}

function ServerCallback_DisableTitanDisembark()
{
	DeregisterConCommandTriggeredCallback( "+useAndReload", PlayerPressed_Disembark )
	DeregisterConCommandTriggeredCallback( "+use", PlayerPressed_Disembark )

	DeregisterConCommandTriggeredCallback( "-useAndReload", PlayerReleased_Disembark )
	DeregisterConCommandTriggeredCallback( "-use", PlayerReleased_Disembark )
}

function ServerCallback_EnableTitanModeChange()
{
	FlagSet( "EnableTitanModeChange" )
}

function ServerCallback_EnableTitanModeChange_Once()
{
	thread EnableTitanModeChange_Once()
}

function EnableTitanModeChange_Once()
{
	local player = GetLocalClientPlayer()
	player.EndSignal( "OnDestroy" )
	level.ent.EndSignal( "ModuleChanging" )

	ServerCallback_EnableTitanModeChange()

	while ( player.GetPetTitanMode() != eNPCTitanMode.FOLLOW )
		wait 0

	ServerCallback_DisableTitanModeChange()
}

function ServerCallback_DisableTitanModeChange()
{
	FlagClear( "EnableTitanModeChange" )
}

function ScriptCallback_NPE_PlayerPressedReload( player )
{
	player.ClientCommand( "NPE_PlayerPressedUse" )

	local weapon = player.GetActiveWeapon()

	if ( !weapon )
		return

	if ( player.GetWeaponAmmoLoaded( weapon ) == player.GetWeaponAmmoMaxLoaded( weapon ) )
		return

	// HACK make sure code actually reloaded the weapon after the button press
	local endGracetime = Time() + 0.5
	while ( Time() > endGracetime && weapon == player.GetActiveWeapon() )
	{
		if ( weapon.IsReloading() )
			break

		wait 0.05
	}

	// he switched weapons instead
	if ( weapon != player.GetActiveWeapon() )
		return

	player.ClientCommand( "NPE_PlayerReloaded" )
}

function ScriptCallback_NPE_PlayerDashed( player )
{
	//printt( "client player dashed" )

	// make sure it's a legit, new dash
	if ( Flag( "PlayerDashInProgress" ) )
	{
		//printt( "CLIENT Dash already in progress!")
		return
	}

	local player = GetLocalClientPlayer()
	//printt( "CLIENT IsDodging?", player.IsDodging() )
	if ( !player.IsDodging() )
	{
		//printt( "CLIENT Player not dashing!")
		return
	}

	player.ClientCommand( "NPE_PlayerDashed" )

	thread PlayerWaitForDashEnd( player )
}

function PlayerWaitForDashEnd( player )
{
	player.EndSignal( "OnDestroy" )

	FlagSet( "PlayerDashInProgress" )

	while ( player.IsDodging() )
		wait 0

	//printt( "CLIENT player dash ended")

	FlagClear( "PlayerDashInProgress" )
}

function ScriptCallback_NPE_TrackPlayerDashMeter()
{
	thread TrackPlayerDashMeter()
}

function ScriptCallback_NPE_TrackPlayerDashMeter_Stop()
{
	level.ent.Signal( "StopTrackingPlayerDashMeter" )
}

function TrackPlayerDashMeter()
{
	local player = GetLocalClientPlayer()

	level.ent.Signal( "StopTrackingPlayerDashMeter" )
	level.ent.EndSignal( "StopTrackingPlayerDashMeter" )
	player.EndSignal( "OnDeath" )

	local cmdLow 	= "NPE_DashMeterLow"
	local cmdReady 	= "NPE_DashMeterReady"

	local lowPowerThreshold = 25
	local lastCmd = null

	while ( 1 )
	{
		local cmdToSend = null

		local power = player.GetSuitPower()

		if ( power < lowPowerThreshold && lastCmd != cmdLow )
			cmdToSend = cmdLow
		else if ( power >= lowPowerThreshold && lastCmd != cmdReady )
			cmdToSend = cmdReady

		if ( cmdToSend != null )
		{
			player.ClientCommand( cmdToSend )
			lastCmd = cmdToSend
		}

		wait 0.05
	}
}

function ScriptCallback_NPE_PlayerPressedWeaponSwitch( player )
{
	//printt( "client: player weapon switch button" )
	player.ClientCommand( "NPE_WeaponSwitch" )
}

function ScriptCallback_NPE_FiredOffhandOffensive( player )
{
	player.ClientCommand( "NPE_FiredOffhandOffensive" )
}

function ScriptCallback_NPE_PlayerJumped( player )
{
	player.ClientCommand( "NPE_PlayerPressedJump" )
}

function ScriptCallback_NPE_MarvinBodyshot( attacker, params )
{
	local victim = params.victim
	local damageType = params.damageType
	local isHeadShot = (damageType & DF_HEADSHOT) ? true : false

	if ( !IsValid( victim ) )
		return

	if ( victim.IsMarvin() && !isHeadShot && !file.alreadyHitMarvinBodyshot )
	{
		attacker.ClientCommand( "NPE_HitMarvinBodyshot" )
		file.alreadyHitMarvinBodyshot = true
	}
}

function ServerCallback_SetTrainingResumeChoice( resumeChoice )
{
	printt( "setting resume choice to", resumeChoice )

	SetPlayerTrainingResumeChoice( resumeChoice )
}

function ServerCallback_SetPlayerHasFinishedTraining()
{
	printt( "setting trainingHasEverFinished" )
	SetTrainingHasEverFinished()
}

function ClientCommand_SetTrainingVars( player )
{
	printt( "ClientCommand_SetTrainingVars player ent:", player, "isplayer?", player.IsPlayer() )

	// get the value that was set when the level loaded
	local everStarted = GetTrainingHasEverBeenStarted( player )
	everStarted == true ? everStarted = 1 : everStarted = 0
	player.ClientCommand( "trainingStarted " + everStarted )

	// Now, set that it's been started right here (instead of setting persistent var in the lobby before launching the level as we used to)
	SetTrainingHasEverBeenStarted()

	local everFinished = GetTrainingHasEverFinished()
	everFinished == true ? everFinished = 1 : everFinished = 0
	player.ClientCommand( "trainingFinished " + everFinished )

	local resumeChoice = GetPlayerTrainingResumeChoice( player )
	printt( "CLIENT resumeChoice is:", resumeChoice )
	player.ClientCommand( "resumeChoice " + resumeChoice )

	printt( "ClientCommand_SetTrainingVars (end)" )
}

ScriptReloadables()
