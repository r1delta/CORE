const TITAN_ALARM_SOUND 		= "titan_alarm"
const TITAN_NUCLEAR_DEATH_ALARM = "titan_nuclear_death_alarm"
const TITAN_EJECT_BOOST			= "titan_eject_boost"
const TITAN_EJECT_ASCENT		= "player_eject_windrush"
const TITAN_EJECT_APEX			= "player_eject_apex_wind"
const TITAN_EJECT_DESCENT		= "player_fallingdescent_windrush"

const EJECT_MIN_VELOCITY = 200.0
const EJECT_MAX_VELOCITY = 1000.0

cockpitFXEmitTags <- [ "FX_TL_PANEL", "FX_TR_PANEL", "FX_TC_PANELA", "FX_TC_PANELB", "FX_BL_PANEL", "FX_BR_PANEL" ]

function main()
{
	if ( reloadingScripts )
		return


	RegisterSignal( "DisembarkCheck" )
	RegisterSignal( "Rumble_Forward_End" )
	RegisterSignal( "Rumble_Back_End" )
	RegisterSignal( "Rumble_Left_End" )
	RegisterSignal( "Rumble_Right_End" )
	RegisterSignal( "EMP" )
	RegisterSignal( "Ejecting" )

	if ( IsMultiplayer() && !IsMenuLevel() )
		IncludeFile( "client/cl_titan_enemy_tracker" )

	Globalize( ServerCallback_TitanEMP )
	Globalize( ServerCallback_TitanCockpitBoot )
	Globalize( TitanCockpit_DamageFeedback )
	Globalize( VMTCallback_TitanScreenTop )
	Globalize( VMTCallback_TitanScreenBottom )
	Globalize( VMTCallback_TitanScreenLeft )
	Globalize( VMTCallback_TitanScreenRight )
	Globalize( VMTCallback_DoomedSelfIllumTint )
	Globalize( PlayerPressed_Disembark )
	Globalize( PlayerReleased_Disembark )
	Globalize( DisembarkCheckThread )
	Globalize( TitanCockpit_AddPlayer )
	Globalize( RegisterTitanBindings )
	Globalize( GetTitanBindings )
	Globalize( DeregisterTitanBindings )
	Globalize( ServerCallback_TitanEmbark )
	Globalize( ServerCallback_TitanDisembark )
	Globalize( PlayerPressed_EjectEnable ) // so can be called directly for debugging
	Globalize( PlayerPressed_Eject ) // so can be called directly for debugging
	Globalize( TitanCockpit_IsBooting )
	Globalize( ServerCallback_TitanCockpitEMP )
	Globalize( TitanCockpit_EMPFadeScale )
	Globalize( TitanCockpit_DoEMP )
	Globalize( TitanEMP_Internal )
	Globalize( ServerCallback_EjectConfirmed )

	PrecacheParticleSystem( "xo_cockpit_spark_01" )


	if ( !IsModelViewer() && !IsLobby() )
	{
		AddCreateCallback( "titan_cockpit", TitanCockpitInit )
		AddCinematicEventFlagChangedCallback( CE_FLAG_EMBARK, TitanEmbarkBegin )
	}

	if ( !reloadingScripts )
	{
		level.cockpitGeoRef <- null
	}

}

function GetTitanBindings()
{
	local table = {}
	table.PlayerPressed_Eject <- PlayerPressed_Eject
	table.PlayerPressed_EjectEnable <- PlayerPressed_EjectEnable
	table.PlayerPressed_Disembark <- PlayerPressed_Disembark
	table.PlayerReleased_Disembark <- PlayerReleased_Disembark
	return table
}

function RegisterTitanBindings( player, bind )
{
	if ( !IsMultiplayer() )
	 	return false
	if ( player != GetLocalViewPlayer() )
		return false
	if ( player != GetLocalClientPlayer() )
		return false
	RegisterConCommandTriggeredCallback( "+useAndReload", bind.PlayerPressed_Eject )
	RegisterConCommandTriggeredCallback( "+use", bind.PlayerPressed_Eject )

	if ( !IsTrainingLevel() )
	{
		RegisterConCommandTriggeredCallback( "+scriptCommand1", bind.PlayerPressed_EjectEnable )
		RegisterConCommandTriggeredCallback( "+useAndReload", bind.PlayerPressed_Disembark )
		RegisterConCommandTriggeredCallback( "+use", bind.PlayerPressed_Disembark )
		RegisterConCommandTriggeredCallback( "-useAndReload", bind.PlayerReleased_Disembark )
		RegisterConCommandTriggeredCallback( "-use", bind.PlayerReleased_Disembark )
	}

	return true
}

function DeregisterTitanBindings( bind )
{
	if ( !IsMultiplayer() )
	 	return
	DeregisterConCommandTriggeredCallback( "+useAndReload", bind.PlayerPressed_Eject )
	DeregisterConCommandTriggeredCallback( "+use", bind.PlayerPressed_Eject )

	if ( !IsTrainingLevel() && GetMapName() != "" )
	{
		DeregisterConCommandTriggeredCallback( "+scriptCommand1", bind.PlayerPressed_EjectEnable )
		DeregisterConCommandTriggeredCallback( "+useAndReload", bind.PlayerPressed_Disembark )
		DeregisterConCommandTriggeredCallback( "+use", bind.PlayerPressed_Disembark )
		DeregisterConCommandTriggeredCallback( "-useAndReload", bind.PlayerReleased_Disembark )
		DeregisterConCommandTriggeredCallback( "-use", bind.PlayerReleased_Disembark )
	}
}


function TitanCockpit_AddPlayer( player )
{
	if ( IsModelViewer() )
		return

	player.s.disembarkPressTime <- 0
	player.s.ejectEnableTime <- 0
	player.s.ejectPressTime <- 0
	player.s.ejectPressCount <- 0

	player.s.lastCockpitDamageSoundTime <- 0
	player.s.inTitanCockpit <- false
	player.s.lastDialogTime <- 0
	player.s.titanCockpitDialogActive <- false
	player.s.titanCockpitDialogAliasList <- []

	player.s.hitVectors <- []
}

function TitanCockpitInit( cockpit, isRecreate )
{
	local player = GetLocalViewPlayer()
	Assert( player.GetCockpit() == cockpit )
	if ( !IsAlive( player ) )
		return

	if ( !IsTitanCockpitModelName( cockpit.GetModelName() ) )
	{
		player.s.inTitanCockpit = false
		return
	}

	if ( !player.s.inTitanCockpit )
		TitanEmbarkDSP( 0.5 )

	player.s.inTitanCockpit = true

	// code aint callin this currently
	CodeCallback_PlayerInTitanCockpit( GetLocalViewPlayer(), GetLocalViewPlayer() )

	// move this
	local targets = GetClientEntArrayBySignifier( "info_target" )
	foreach ( target in targets )
	{
		if ( target.GetName() != "cockpit_geo_ref" )
			continue

		level.cockpitGeoRef = target
	}

	local cockpitParent = level.cockpitGeoRef

	if ( !cockpitParent )
		cockpitParent = GetLocalViewPlayer()

	cockpit.SetOrigin( cockpitParent.GetOrigin() )
	cockpit.SetParent( cockpitParent )
	cockpit.s.ejectStartTime <- 0
	cockpit.s.empInfo <- {}
	cockpit.s.empInfo["xOffset"] <- 0
	cockpit.s.empInfo["yOffset"] <- 0
	cockpit.s.empInfo["startTime"] <- 0
	cockpit.s.empInfo["duration"] <- 0
	cockpit.s.empInfo["sub_count"] <- 0
	cockpit.s.empInfo["sub_start"] <- 0
	cockpit.s.empInfo["sub_duration"] <- 0
	cockpit.s.empInfo["sub_pause"] <- 0
	cockpit.s.empInfo["sub_alpha"] <- 0

	cockpit.s.cockpitType <- 1
	cockpit.s.FOV <- 70

	cockpit.s.body <- CreateCockpitBody( cockpit, player, cockpitParent )

	thread TitanCockpitAnimThink( cockpit, cockpit.s.body )

	if ( player.IsTitan() ) // pilot with titan cockpit gets thrown from titan
		thread TitanCockpitDoomedThink( cockpit, player )

	SetCockpitLightingEnabled( 0, true )
}


function CockpitBodyThink( cockpit, cockpitBody )
{
	cockpitBody.EndSignal( "OnDestroy" )

	cockpit.WaitSignal( "OnDestroy" )

	cockpitBody.Destroy()
}


function CreateCockpitBody( cockpit, player, cockpitParent )
{
	local bodySettings = player.GetPlayerPilotSettings()
	if ( !bodySettings || GetPlayerSettingsFieldForClassName( bodySettings, "class" ) != "wallrun" )
		bodySettings = "pilot_male_br"

	local bodyModelName
	if ( player.GetTeam() == TEAM_IMC )
		bodyModelName = GetPlayerSettingsFieldForClassName( bodySettings, "armsmodel_imc" )
	else
		bodyModelName = GetPlayerSettingsFieldForClassName( bodySettings, "armsmodel_militia" )

	local cockpitBody = CreateClientSidePropDynamic( cockpitParent.GetOrigin(), Vector( 0, 0, 0 ), bodyModelName )
	cockpitBody.EnableRenderWithCockpit()
	cockpitBody.SetOrigin( cockpit.GetOrigin() )
	cockpitBody.SetParent( cockpit )

	thread CockpitBodyThink( cockpit, cockpitBody )

	return cockpitBody
}

::g_cockpitDSP <- 0

function TitanEmbarkDSP( transitionTime )
{
	if ( !g_cockpitDSP )
		return

	SetLocalPlayerDSP( g_cockpitDSP, transitionTime )
}

function TitanDisembarkDSP( transitionTime )
{
	if ( !g_cockpitDSP )
		return

	SetLocalPlayerDSP( 0, transitionTime )
}

function TitanCockpit_EMPFadeScale( cockpit, elapsedMod = 0 )
{
	local fadeInTime = 0.0
	local fadeOutTime = 1.5
	local elapsedTime = Time() - cockpit.s.empInfo.startTime
	elapsedTime += elapsedMod

	// ToDo:
	// Fade in/out from last frames amount so it doesnt pop
	// Make strength var to control max fade ( less strength returns max of like 0.5 )

	//------------------------
	// EMP effect is finished
	//------------------------

	//printt( "elapsedTime:" + elapsedTime + " cockpit.s.empInfo.duration:" + cockpit.s.empInfo.duration + " fadeOutTime:" + fadeOutTime )
	if ( elapsedTime < cockpit.s.empInfo.duration - fadeOutTime )
	{
		return 1.0
	}


	if ( elapsedTime >= fadeInTime + cockpit.s.empInfo.duration + fadeOutTime )
	{
		cockpit.s.empInfo.startTime = 0
		return 0.0
	}

	//------------------------
	// EMP effect is starting
	//------------------------

	if ( elapsedTime < fadeInTime )
	{
		return GraphCapped( elapsedTime, 0.0, fadeInTime, 0.0, 1.0 )
	}

	//----------------------
	// EMP effect is ending
	//----------------------

	if ( elapsedTime > fadeInTime + cockpit.s.empInfo.duration )
	{
		cockpit.s.empInfo["sub_count"] = 0
		return GraphCapped( elapsedTime, fadeInTime + cockpit.s.empInfo.duration, fadeInTime + cockpit.s.empInfo.duration + fadeOutTime, 1.0, 0.0 )
	}

	//---------------------
	// EMP flicker effect
	//---------------------

	// Time to start a new flicker
	if ( cockpit.s.empInfo["sub_start"] == 0 )
	{
		cockpit.s.empInfo["sub_start"] 		<- Time()
		if ( cockpit.s.empInfo["sub_count"] == 0 )
			cockpit.s.empInfo["sub_pause"] 	<- RandomFloat( 0.5, 1.5 )
		else
			cockpit.s.empInfo["sub_pause"] 	<- RandomFloat( 0.0, 0.5 )
		cockpit.s.empInfo["sub_duration"] 	<- RandomFloat( 0.1, 0.4 )
		cockpit.s.empInfo["sub_alpha"] 		<- RandomFloat( 0.4, 0.9 )
		cockpit.s.empInfo["sub_count"]++;

		// Do another spark effect for each flicker
		//thread PlayCockpitSparkFX( cockpit )	// commented out because it makes the black screens turn white and look ugly
	}
	local flickerElapsedTime = Time() - cockpit.s.empInfo["sub_start"]

	// Start a new flicker if the current one is finished
	if ( flickerElapsedTime > cockpit.s.empInfo["sub_pause"] + cockpit.s.empInfo["sub_duration"] )
		cockpit.s.empInfo["sub_start"] = 0

	if ( flickerElapsedTime < cockpit.s.empInfo["sub_pause"] )
	{
		// Pause before the flicker
		return 1.0
	}
	else if ( flickerElapsedTime < cockpit.s.empInfo["sub_pause"] + ( cockpit.s.empInfo["sub_duration"] / 2.0 ) )
	{
		// First half of the flicker
		return GraphCapped( flickerElapsedTime, 0.0, cockpit.s.empInfo["sub_duration"] / 2.0, 1.0, cockpit.s.empInfo["sub_alpha"] )
	}
	else
	{
		// Second half of the flicker
		return GraphCapped( flickerElapsedTime, cockpit.s.empInfo["sub_duration"] / 2.0, cockpit.s.empInfo["sub_duration"], cockpit.s.empInfo["sub_alpha"], 1.0 )
	}
}

function ServerCallback_TitanCockpitEMP( duration )
{
	thread TitanCockpit_DoEMP( duration / 4 )
}

function TitanCockpit_DoEMP( duration )
{
	local player = GetLocalViewPlayer()
	local cockpit = player.GetCockpit()

	if ( !IsValid( cockpit ) )
		return

	if ( !player.IsTitan() )
		return

	if ( !player.s.inTitanCockpit )
		return

	Signal( player, "EMP" )
	EndSignal( player, "EMP" )
	player.EndSignal( "OnDestroy" )

	// this needs tweaking... looks a bit artificial
	player.Jolt( Vector( 0, RandomFloat( -50.0, 50.0 ), 100 ), 10 )
	ClientCockpitShake( 0.25, 3, 1.0, Vector( 0, 0, 1 ) )

	// Spark Effects
	foreach ( tag in cockpitFXEmitTags )
	{
		delaythread( RandomFloat( 0.0, 0.5 ) ) PlayCockpitSparkFX( cockpit, tag )
	}

	thread PlayCockpitEMPLights( cockpit, duration )

	// Start the screens and vdu power outages
	cockpit.s.empInfo.xOffset = RandomFloat( 0.5, 0.75 )
	cockpit.s.empInfo.yOffset = RandomFloat( 0.5, 0.75 )
	if ( CoinFlip() )
		cockpit.s.empInfo.xOffset *= -1
	if ( CoinFlip() )
		cockpit.s.empInfo.yOffset *= -1

	cockpit.s.empInfo.startTime = Time()
	cockpit.s.empInfo.duration = duration

	EmitSoundOnEntity( player, EMP_IMPARED_SOUND )
	wait duration
	FadeOutSoundOnEntity( player, EMP_IMPARED_SOUND, 1.5 )
}

function PlayCockpitEMPLights( cockpit, duration )
{
	duration += 1.5 // blend out
	local attachID
	local origin
	local angles
	local fxLights = []

	local tagName = "COCKPIT" // SCR_CL_BL"
	attachID = cockpit.LookupAttachment( tagName )
	origin = cockpit.GetAttachmentOrigin( attachID )
	origin.z -= 25
	angles = Vector( 0, 0, 0 )
	local lightTable = {}
	lightTable.light <- CreateClientSideDynamicLight( origin, angles, Vector( 0.0, 0.0, 0.0 ), 80.0 )
	lightTable.modulate <- true
	fxLights.append( lightTable )

	wait 0.5

	foreach ( fxLight in fxLights )
	{
		fxLight.light.SetCockpitLight( true )
	}

	local startTime = Time()
	local rate = 1.2

	local endTime = Time() + duration

	while ( IsValid( cockpit ) )
	{
		if ( Time() > endTime )
			break

		local subtractColor = GraphCapped( Time(), endTime - 0.25, endTime, 1.0, 0.0 )
		local pulseFrac = GetPulseFrac( rate, startTime )
		pulseFrac *= subtractColor
		//pulseFrac -= fadeInColor

		foreach ( index, fxLight in fxLights )
		{
			if ( fxLight.modulate )
			{
				fxLight.light.SetLightColor( Vector( pulseFrac, 0, 0 ) )
			}
			else
			{
				fxLight.light.SetLightColor( Vector( fadeInColor, fadeInColor, fadeInColor ) )
			}
		}

		wait 0
	}

	foreach ( fxLight in fxLights )
	{
		fxLight.light.Destroy()
	}
}


function TitanCockpit_IsBooting( cockpit )
{
	return cockpit.GetTimeInCockpit() < 1.3
}

function TitanCockpitAnimThink( cockpit, body )
{
	cockpit.SetOpenViewmodelOffset( 20.0, 0.0, 10.0 )
	cockpit.Anim_NonScriptedPlay( "atpov_cockpit_hatch_close_idle" )

	if ( body )
		body.Anim_NonScriptedPlay( "atpov_cockpit_hatch_close_idle" )
}


function EjectHint_GetVisible( player, index )
{
	if ( Time() - player.s.ejectPressTime > TITAN_EJECT_MAX_PRESS_DELAY )
		return false

	if ( player.s.ejectPressCount >= index )
		return true
	else
		return false
}
Globalize( EjectHint_GetVisible )

function DisplayEjectInterface( player )
{
	if ( !player.IsTitan() )
		return false

	if ( player.ContextAction_IsMeleeExecution() ) //Could just check for ContextAction_IsActive() if we need to be more general
		return false

	if ( !player.GetDoomedState() && Time() - player.s.ejectEnableTime > EJECT_FADE_TIME )
		return false

	return true
}

RegisterSignal( "PressedEjectSignals" )
function PressedEjectSignals( player )
{
	player.Signal( "EjectHintUpdate" )

	player.Signal( "PressedEjectSignals" )
	player.EndSignal( "PressedEjectSignals" )

	// For some reason this makes us wait for the actual TITAN_EJECT_MAX_PRESS_DELAY delay time instead of falling short
	WaitEndFrame()

	wait TITAN_EJECT_MAX_PRESS_DELAY

	player.Signal( "EjectHintUpdate" )
}

function PlayerPressed_Eject( player )
{
	if ( !DisplayEjectInterface( player ) )
		return

	if ( Time() - player.s.ejectPressTime > TITAN_EJECT_MAX_PRESS_DELAY )
		player.s.ejectPressCount = 0

	if ( !IsAlive( player ) )
		return

	EmitSoundOnEntity( player, "titan_eject_xbutton" )
	player.s.ejectPressTime	= Time()
	player.s.ejectPressCount++
	thread PressedEjectSignals( player )

	player.ClientCommand( "TitanEject " + player.s.ejectPressCount )

	local cockpit = player.GetCockpit()

	if ( player.s.ejectPressCount < 3 || cockpit.s.ejectStartTime )
		return

	player.Signal( "Ejecting" )

	SmartGlass_SendEvent( "playerEject", "", "", "" )

	local ejectAlarmSound

	cockpit.s.ejectStartTime = Time()
	if ( GetNuclearPayload( player ) > 0 )
	{
		cockpit.Anim_NonScriptedPlay( "atpov_cockpit_eject_nuclear" )
		if ( cockpit.s.body )
			cockpit.s.body.Anim_NonScriptedPlay( "atpov_cockpit_eject_nuclear" )
		ejectAlarmSound = TITAN_NUCLEAR_DEATH_ALARM
	}
	else
	{
		cockpit.Anim_NonScriptedPlay( "atpov_cockpit_eject" )
		if ( cockpit.s.body )
			cockpit.s.body.Anim_NonScriptedPlay( "atpov_cockpit_eject" )

		ejectAlarmSound = TITAN_ALARM_SOUND
	}
	thread LightingUpdateAfterOpeningCockpit()

	thread EjectAudioThink( player, ejectAlarmSound  )
}

function ServerCallback_EjectConfirmed()
{
	if ( !IsWatchingKillReplay() )
		return

	local player = GetLocalViewPlayer()
	local cockpit = player.GetCockpit()

	if ( !cockpit || !IsTitanCockpitModelName( cockpit.GetModelName() ) )
		return

	player.Signal( "Ejecting" )

	local ejectAlarmSound

	cockpit.s.ejectStartTime = Time()
	if ( GetNuclearPayload( player ) > 0 )
	{
		cockpit.Anim_NonScriptedPlay( "atpov_cockpit_eject_nuclear" )
		if ( cockpit.s.body )
			cockpit.s.body.Anim_NonScriptedPlay( "atpov_cockpit_eject_nuclear" )
		ejectAlarmSound = TITAN_NUCLEAR_DEATH_ALARM
	}
	else
	{
		cockpit.Anim_NonScriptedPlay( "atpov_cockpit_eject" )
		if ( cockpit.s.body )
			cockpit.s.body.Anim_NonScriptedPlay( "atpov_cockpit_eject" )

		ejectAlarmSound = TITAN_ALARM_SOUND
	}
	thread LightingUpdateAfterOpeningCockpit()

	thread EjectAudioThink( player, ejectAlarmSound  )
}

function EjectAudioThink( player, ejectAlarmSound = TITAN_ALARM_SOUND )
{
	EmitSoundOnEntity( player, ejectAlarmSound )
	TitanCockpit_PlayDialog( player, "manual_eject" )

	player.EndSignal( "OnDeath" )

	player.WaitSignal( "SettingsChanged" )

	if ( player.GetPlayerClass() != "wallrun" )
		return

	OnThreadEnd(
		function() : ( player )
		{
			if ( !IsAlive( player ) )
			{
				StopSoundOnEntity( player, TITAN_EJECT_ASCENT )
				StopSoundOnEntity( player, TITAN_EJECT_DESCENT )
			}
			else
			{
				FadeOutSoundOnEntity( player, TITAN_EJECT_ASCENT, 0.25 )
				FadeOutSoundOnEntity( player, TITAN_EJECT_DESCENT, 0.25 )
			}

			StopSoundOnEntity( player, TITAN_EJECT_APEX )
		}
	)

	EmitSoundOnEntity( player, TITAN_EJECT_BOOST )

	local startTime = Time()
	local duration = EmitSoundOnEntity( player, TITAN_EJECT_ASCENT )
	local timeOut = duration - 0.25
	local velocity
	local diff = 0

	const STAGE_ASCENT = 1
	const STAGE_APEX = 2
	const STAGE_DESCENT = 3

	local ejectStage = STAGE_ASCENT

	local currentSound = TITAN_EJECT_ASCENT

	while ( diff < timeOut )
	{
		PerfStart( 127 )

		diff = (Time() - startTime)

		velocity = player.GetVelocity()
		local length = velocity.Normalize()

		if ( diff > 0.5 )
		{
			if ( player.IsOnGround() )
			{
				PerfEnd( 127 )
				break
			}
		}

		if ( ejectStage != STAGE_DESCENT && velocity.z < 0 )
		{
			FadeOutSoundOnEntity( player, TITAN_EJECT_ASCENT, 0.25 )
			timeOut = EmitSoundOnEntity( player, TITAN_EJECT_DESCENT )
			currentSound = TITAN_EJECT_DESCENT
			ejectStage = STAGE_DESCENT
		}
		else if ( ejectStage == STAGE_ASCENT && length < 400 )
		{
			EmitSoundOnEntity( player, TITAN_EJECT_APEX )
			ejectStage = STAGE_APEX
		}

		local volume = GraphCapped( length, EJECT_MIN_VELOCITY, EJECT_MAX_VELOCITY, 0.0, 1.0 )

		SetSoundVolumeOnEntity( player, currentSound, volume )

		PerfEnd( 127 )

		wait 0
	}
}

function LightingUpdateAfterOpeningCockpit()
{
 	while ( 1 )
 	{
 		if ( !GetLocalViewPlayer().s.inTitanCockpit )
 			break
 		wait 0
 	}

	SetCockpitLightingEnabled( 0, false )
}


function TonemappingUpdateAfterOpeningCockpit() //Deprecated, no longer used
{
	local duration = 3
	local tonemapMin = 2
	local tonemapMax = 25

 	while ( 1 )
 	{
 		if ( !GetLocalViewPlayer().s.inTitanCockpit )
 			break
 		wait 0
 	}

	SetCockpitLightingEnabled( 0, false )

	ResetTonemapping( 0, tonemapMax )
	wait( 0.1 )

	TitanDisembarkDSP( 0.5 )

	local startTime = Time()
	while ( 1 )
	{
		local time = Time() - startTime
		local factor = GraphCapped( time, 0, duration, 1, 0 )
		factor = factor * factor * factor
		local toneMapScale = tonemapMin + (tonemapMax - tonemapMin) * factor
		ResetTonemapping( 0, toneMapScale )

		if ( factor == 0 )
			break
		wait  0
	}
}

function ServerCallback_TitanEmbark()
{
	TitanCockpit_PlayDialog( GetLocalViewPlayer(), "embark" )
}

function TitanEmbarkBegin( player )
{
	if ( !IsValid( player ) )
		return

	local titan = player.GetPetTitan()
	if ( !IsValid( titan ) )
		return

	local soul = titan.GetTitanSoul()
	if ( !IsValid( soul ) )
		return

	if ( GetGameState() != eGameState.SwitchingSides && GetGameState() != eGameState.WinnerDetermined )
	{
		local titanType = GetSoulTitanType( soul )
		SmartGlass_SendEvent( "titanEmbark", titanType, "", "" )
	}
}
Globalize( TitanEmbarkBegin )

function ServerCallback_TitanDisembark()
{
	local player = GetLocalViewPlayer()

	thread LightingUpdateAfterOpeningCockpit()

	if ( GetGameState() != eGameState.SwitchingSides && GetGameState() != eGameState.WinnerDetermined )
	{
		SmartGlass_SendEvent( "titanDisembark", "", "", "" )
		TitanCockpit_PlayDialog( player, "disembark" )
	}

	//HideFriendlyIndicatorAndCrosshairNames()

	//PlayMusic( "Music_FR_Militia_PilotAction2" )
}


function PlayerPressed_QuickDisembark( player )
{
	player.ClientCommand( "TitanDisembark" )
}

function PlayerPressed_Disembark( player )
{
	if ( player.HasUsePrompt() )
		return

	player.s.disembarkPressTime = Time()
	thread DisembarkCheckThread( player )
}

function DisembarkCheckThread( player )
{
	// this stuff should be commented.. why do we have this thread?
	Signal( player, "DisembarkCheck" )
	EndSignal( player, "DisembarkCheck" )
	EndSignal( player, "OnDestroy" )

	wait 0.4

	if ( !PlayerCanDisembarkTitan( player ) )
		return

	if ( Time() - player.s.disembarkPressTime > 0.5 )
		return

	local cockpit = player.GetCockpit()
	if ( !IsValid( cockpit ) )
		return

	if ( !player.IsTitan() )
		return

	player.ClientCommand( "TitanDisembark" )
}


function PlayerReleased_Disembark( player )
{
	player.s.disembarkPressTime = 0
}


RegisterSignal( "EjectHintUpdate" )
function PlayerPressed_EjectEnable( player )
{
	if ( !player.IsTitan() )
		return

	if ( player.ContextAction_IsMeleeExecution() ) //Could just check for ContextAction_IsActive() if we need to be more general
		return

	if ( player.GetHealth() == 1 )
	{
		player.ClientCommand( "TitanEject " + 3 )
		return
	}

	if ( !IsAlive( player ) )
		return

	EmitSoundOnEntity( player, "titan_eject_dpad" )
	player.s.ejectEnableTime = Time()
	player.Signal( "EjectHintUpdate" )
}

function CalculateJoltFrac( player, hitVector )
{
	local hitInfo = GetInfoForHitVector( player, hitVector )
	hitInfo.hitVector = hitVector
	hitInfo.hitCount++

	local joltFrac = 0.0
	local timeDiff = Time() - hitInfo.firstHitTime
	local timeFrac = clamp( timeDiff / HITVECTOR_EXPIRE_TIME, 0.0, 1.0 )

	hitInfo.lastHitTime = Time()

	/*
	local joltMagnitude = player.GetJoltMagnitude()

	if ( !joltMagnitude )
		joltFrac = pow( 0.5, hitInfo.hitCount )
	else
		joltFrac = pow( 0.5, hitInfo.hitCount ) * clamp( 1 - player.GetJoltMagnitude(), 0.0, 0.25 )

	joltFrac = max( 0.1, joltFrac )
	*/

	joltFrac = 1.0 / pow( hitInfo.hitCount, 0.95 )

	joltFrac *= (1 - timeFrac)

	//joltFrac = max( 0.18, joltFrac )

	return joltFrac
}


function JoltCockpit( cockpit, player, joltDir, damageAmount, damageType, damageSourceId )
{
	local joltAmount = CalcTitanCockpitJolt( player, cockpit, joltDir, damageAmount, damageType, damageSourceId )
	player.Jolt( joltDir * joltAmount, 1.0 - player.GetJoltMagnitude() )

	return joltAmount
}


function RandomizeDir( dir, randPitch = 0, randYaw = 0, basePitch = 0, baseYaw = 0 )
{
	local pitch = RandomFloat( -randPitch, randPitch )
	local yaw = RandomFloat( -randYaw, randYaw )
	local angles = VectorToAngles( dir )
	angles = angles.AnglesCompose( Vector( pitch, yaw, 0 ) )
	angles = angles.AnglesCompose( Vector( basePitch, baseYaw, 0 ) )
	return angles.AnglesToForward()
}

function TitanCockpitDoomedThink( cockpit, player )
{
	cockpit.EndSignal( "OnDestroy" )

	local titanSoul = player.GetTitanSoul()

	if ( !titanSoul.IsDoomed() )
		WaitSignal( player, "Doomed", "Ejecting" )

	local tag = "SCR_CL_BL"
	local color = Vector( 0.6, 0.06, 0 )
	local radius = 70.0

	local attachID = cockpit.LookupAttachment( tag )
	local origin = cockpit.GetAttachmentOrigin( attachID )
	local angles = Vector( 0, 0, 0 )

	local fxLight = CreateClientSideDynamicLight( origin, angles, color, radius )
	fxLight.SetCockpitLight( true )
	fxLight.SetParent( cockpit )

	OnThreadEnd(
		function() : ( fxLight )
		{
			fxLight.Destroy()
		}
	)

	local startTime = Time()
	local rate = 3.0

	while ( IsValid( cockpit ) )
	{
		local pulseFrac = GetPulseFrac( rate, startTime )
		pulseFrac += 0.5
		fxLight.SetLightColor( Vector( color.x * pulseFrac, color.y * pulseFrac, color.z * pulseFrac ) )

		wait 0
	}
}


function PlayCockpitSparkFX( cockpit, tagName = "" )
{
	// this is called from a delaythread so needs valid check
	if ( !IsValid( cockpit ) )
		return

	if ( tagName == "")
		tagName = Random( cockpitFXEmitTags )

	local attachID = cockpit.LookupAttachment( tagName )
	if ( attachID == 0 )
	{
		tagName = CoinFlip() ? "FX_TL_PANEL" : "FX_TR_PANEL"
		attachID = cockpit.LookupAttachment( tagName )
	}

	// e3 workaround
	if ( !attachID )
		return

	Assert( attachID, "Could not find attachment index " + attachID + " in model " + GetLocalViewPlayer().GetCockpit().GetModelName() )

	local origin = cockpit.GetAttachmentOrigin( attachID )
	local angles = Vector( 0, 0, 0 )

	local fxID = GetParticleSystemIndex( "xo_cockpit_spark_01" )

	local fxInstID = PlayFXOnTag( cockpit, fxID, attachID );
	EffectSetIsWithCockpit( fxInstID, true );
}
Globalize( PlayCockpitSparkFX )

function PlayIncomingDamageFeedback( player, cockpit, appliedJoltFrac, damageAmount, damageType, damageSourceId )
{
	if ( appliedJoltFrac >= 1.0 || Time() - player.s.lastCockpitDamageSoundTime > 3.0 )
	{
		if ( damageAmount >= COCKPIT_SPARK_FX_DAMAGE_LIMIT && !(damageType & DF_SHIELD_DAMAGE) )
			PlayCockpitSparkFX( cockpit )

		if ( damageType & DF_EXPLOSION || damageAmount >= 400 )
		{
			if ( damageAmount > 400 )
				EmitSoundOnEntity( player, "titan_heavy_damage" )
			else if ( damageAmount > 100 )
				EmitSoundOnEntity( player, "titan_armor_damage" )

			player.s.lastCockpitDamageSoundTime = Time()

			local healthFrac = GetHealthFrac( player )

			if ( healthFrac < 0.5 )
				EmitSoundOnEntity( player, "interior_cockpit_shake" )
		}

		player.HeavyDamage()
	}

	//HACK - Ideally the XO_16 would use a different damage flag than DF_ELECTRICAL, but it seems we're capped atm on damage flags.
	if ( damageSourceId != eDamageSourceId.mp_titanweapon_xo16 && damageType & DF_ELECTRICAL )
		EmitSoundOnEntity( player, "titan_cockpit_electrical_damage" )
}

function TitanCockpit_DamageFeedback( player, cockpit, damageAmount, damageType, damageOrigin, damageSourceId )
{
	local joltDir = ( player.CameraPosition() - damageOrigin )
	joltDir.Normalize()
	RumbleControl( player, joltDir, damageAmount, damageSourceId )

	local appliedJoltFrac = JoltCockpit( cockpit, player, joltDir, damageAmount, damageType, damageSourceId )

	PlayIncomingDamageFeedback( player, cockpit, appliedJoltFrac, damageAmount, damageType, damageSourceId )
}

function RumbleControl( player, joltDir, damageAmount, damageSourceId )
{
	local rumbleScale = GraphCapped( damageAmount, 0.0, 100.0, 0.2, 1.0 )

	local damageSuffix = ""

	switch ( damageSourceId )
	{
		case eDamageSourceId.mp_titanweapon_xo16:
			damageSuffix = "_short"
			break

		case eDamageSourceId.mp_titanweapon_arc_cannon:
		case eDamageSourceId.titanEmpField:
			damageSuffix = "_long"
			break
	}

	joltDir.z = 0.0
	joltDir.Normalize()

	local playerViewForward = player.GetViewVector()
	playerViewForward.z = 0.0
	playerViewForward.Normalize()

	local damageFrontDot = joltDir.Dot( playerViewForward )

	if ( damageFrontDot <= -0.707107 )
		Rumble_Play( "titan_damaged_front" + damageSuffix, { scale = rumbleScale } )
	else if ( damageFrontDot >= 0.707107 )
		Rumble_Play( "titan_damaged_back" + damageSuffix, { scale = rumbleScale } )
	else
	{
		local playerViewRight = player.GetViewRight()
		playerViewRight.z = 0.0
		playerViewRight.Normalize()

		local damageRightDot = joltDir.Dot( playerViewRight )

		if ( damageRightDot <= -0.707107 )
			Rumble_Play( "titan_damaged_right" + damageSuffix, { scale = rumbleScale } )
		else
			Rumble_Play( "titan_damaged_left" + damageSuffix, { scale = rumbleScale } )
	}
}

const TITAN_SCREEN_DAMAGE_TIME = 0.25

function ComputeDamageAlphaForDir( player, dir )
{
	if ( player.GetDoomedState() )
		return 1.0
	else
		return 0.0

	return alpha
}

function VMTCallback_TitanScreenTop( ent )
{
	if ( !GetLocalViewPlayer().GetDoomedState() )
		return 0.0

	return GetPulseFrac( 3.0 )
	//return ComputeDamageAlphaForDir( ent, 0 )
}

function VMTCallback_TitanScreenBottom( ent )
{
	return ComputeDamageAlphaForDir( ent, 180 )
}

function VMTCallback_TitanScreenLeft( ent )
{
	return ComputeDamageAlphaForDir( ent, 270 )
}

function VMTCallback_TitanScreenRight( ent )
{
	return ComputeDamageAlphaForDir( ent, 90 )
}


function VMTCallback_DoomedSelfIllumTint( player )
{
	//if ( !player.GetDoomedState() )
		return Vector( 0.0, 0.0, 0.0 )

	return Vector( GetPulseFrac( 2 ) * 2.0, 0.1019608, 0.1019608 )
}


function ServerCallback_TitanEMP( maxValue, duration, fadeTime, doFlash = true, doSound = true )
{
	thread TitanEMP_Internal( maxValue, duration, fadeTime, doFlash, doSound )
}

function ServerCallback_TitanCockpitBoot()
{
	ResetTonemapping( 0, 0.01 )
}

RegisterSignal( "TitanEMP_Internal" )

function TitanEMP_Internal( maxValue, duration, fadeTime, doFlash = true, doSound = true )
{
	local player = GetLocalViewPlayer()

	player.Signal( "TitanEMP_Internal" )
	player.EndSignal( "TitanEMP_Internal" )

	player.EndSignal( "OnDeath" )
	//player.Signal( "EMPScreenFX", { maxValue = maxValue, duration = duration, fadeTime = fadeTime } )

	local angles = Vector( 0, -90, 90 )

	local wide = 16
	local tall = 9

	local empVgui = CreateClientsideVGuiScreen( "vgui_titan_emp", VGUI_SCREEN_PASS_VIEWMODEL, Vector(0,0,0), Vector(0,0,0), wide, tall );

	//empVgui.SetParent( player.GetViewModelEntity(), "CAMERA_BASE" )
	empVgui.SetParent( player )
	empVgui.SetAttachOffsetOrigin( Vector( 4, wide / 2, -tall / 2 ) )
	empVgui.SetAttachOffsetAngles( angles )

	empVgui.GetPanel().WarpEnable()

	local EMPScreenFX = HudElement( "EMPScreenFX", empVgui.GetPanel() )
	local EMPScreenFlash = HudElement( "EMPScreenFlash", empVgui.GetPanel() )

	OnThreadEnd(
		function() : ( player, empVgui )
		{
			empVgui.Destroy()
			//player.hudElems.EMPScreenFX.Hide()
			//ColorCorrection_SetWeight( file.flashCorrection, 0.0 )
		}
	)

	EMPScreenFX.Show()
	EMPScreenFX.SetAlpha( maxValue * 255 )
	EMPScreenFX.FadeOverTimeDelayed( 0, fadeTime, duration )

	if ( doFlash )
	{
		EMPScreenFlash.Show()
		EMPScreenFlash.SetAlpha( 255 )
		EMPScreenFlash.FadeOverTimeDelayed( 0, fadeTime + duration, 0 )
	}

	if ( doSound )
	{
		EmitSoundOnEntity( player, EMP_IMPARED_SOUND )
		wait duration
		FadeOutSoundOnEntity( player, EMP_IMPARED_SOUND, fadeTime )
	}

	wait fadeTime
}
