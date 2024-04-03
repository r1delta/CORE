const SHIP_LIGHT_ON_MODEL 			= "models/IMC_base/light_wall_IMC_01_on.mdl"
const WARNING_LIGHT_ON_MODEL		= "models/lamps/warning_light_ON_orange.mdl"
const ENGINE_MALFUNCTION_PROGRESS	= 50
const ENGINE_FALL_OFF_PROGRESS		= 75
const ENGINE_COLLISION				= "models/levels_terrain/mp_relic/mp_relic_ship_engine_collision.mdl"
const ENGINE_COLLISION_2			= "models/levels_terrain/mp_relic/mp_relic_ship_engine_collision2.mdl"
const POV_MODEL						= "models/weapons/arms/pov_mcor_pilot_male_dm.mdl"
const ROCK_MODEL 					= "models/stage_props/gravestone/gravestone_01_animated.mdl"

PrecacheModel( BISH_MODEL )
PrecacheModel( MAC_MODEL )
PrecacheModel( ROCK_MODEL )
PrecacheModel( GRAVES_MODEL )
PrecacheModel( SHIP_LIGHT_ON_MODEL )
PrecacheModel( WARNING_LIGHT_ON_MODEL )
PrecacheModel( ENGINE_COLLISION )
PrecacheModel( ENGINE_COLLISION_2 )

const FX_CARRIER_WARPIN				= "veh_carrier_warp_FULL_ground"

PrecacheParticleSystem( FX_CARRIER_WARPIN )

const AI_CHATTER_ENGINE_STARTUP_LENGTH = 20

function main()
{
	if ( reloadingScripts )
		return

	level.shipEngineLeft	<- null
	level.shipEngineRight	<- null
	level.engineStartTime	<- 0
	level.povCamera			<- null
	level.hurtTrigger1		<- null
	level.hurtTrigger2		<- null

	RegisterSignal( "StopEngineIdle" )
	RegisterSignal( "dropoff" )


	level.playCinematicContent <- false
	if ( GetCinematicMode() && IsAttritionMode() )
		level.playCinematicContent = true

	level.progressFuncArray <- []
	RegisterServerVarChangeCallback( "matchProgress", MatchProgressUpdate )

	if ( EvacEnabled() )
		GM_AddEndRoundFunc( EndRoundMain )

	if ( !level.playCinematicContent )
		return

	// add touch and go dropship to the auto trigger list for cinematic mode
	level.autoTriggeredCinematicTypes[ CINEMATIC_TYPES.DROPSHIP_TOUCH_AND_GO ] <- true

	FlagInit( "StartIMCDropships" )
	FlagInit( "StartMilitiaDropships" )

	FlagSet( "CinematicIntro" )
	FlagSet( "CinematicOutro" )
	FlagClear( "AnnounceProgressEnabled" )

	SetGameWonAnnouncement( "matchWin" )
	SetGameLostAnnouncement( "matchLoss" )
	SetGameModeAnnouncement( "modeAnnc_attrition" )

	level.levelSpecificChatterFunc = RelicSpecificChatter
}

function EntitiesDidLoad()
{
	if ( GetBugReproNum() == 1970 )
	{
		Disable_IMC()
		Disable_MILITIA()
	}

	SetupShipEngines()

	if ( EvacEnabled() )
		EvacSetup()

	if ( level.playCinematicContent )
	{
		SetupProgression()
		SetCustomIntroLength( 27 ) // tweak so that countdown ends as the guys jump out of the ship.
		thread RelicIntros()
	}
	else
	{
		SetupClassicMode()
	}
}


/*--------------------------------------------------------------------------------------------------------*\
|
|											  MATCH PROGRESS
|
\*--------------------------------------------------------------------------------------------------------*/

function SetupProgression()
{
	// order is important for functions to be called correctly after each other
	AddProgressionFunc( 20,  ProgressStageIMC_Early )
	AddProgressionFunc( 30, ProgressStagePowerOn )
	AddProgressionFunc( 45, ProgressStageMilitia_Middle )
	AddProgressionFunc( ENGINE_MALFUNCTION_PROGRESS, ProgressStageEngineMalfunction )
	AddProgressionFunc( ENGINE_FALL_OFF_PROGRESS, ProgressStage_Late )
	AddProgressionFunc( 90, ProgressStageMilitia_Last )
	AddProgressionFunc( 90,  ProgressStageIMC_Last )

	AddProgressionFunc( 25,  ProgressAnnouncementEarly )
	AddProgressionFunc( 60,  ProgressAnnouncementMid )
	AddProgressionFunc( 85,  ProgressAnnouncementLate )
}

function AdvanceProgression( team = TEAM_MILITIA )
{
	wait 0.5

	local steps = [ 20, 30, 45, ENGINE_FALL_OFF_PROGRESS, 90 ]
	local maxScore  = GetScoreLimit_FromPlaylist()
	local teamScore = GameRules.GetTeamScore( team )
	local progress = level.nv.matchProgress

	foreach( step in steps )
	{
		if ( progress >= step )
			continue

		local goalScore = ceil( maxScore * ( step.tofloat() / 100.0 ) )
		AddTeamScore( team, goalScore - teamScore )
		return
	}
}

function SetupClassicMode()
{
	if ( !IsSwitchSidesBased() && !IsRoundBased() )
	{
		AddProgressionFunc( 25,  ClassicProgressEngineStart )
		AddProgressionFunc( ENGINE_MALFUNCTION_PROGRESS, ClassicProgressMalfunction )
		AddProgressionFunc( ENGINE_FALL_OFF_PROGRESS, ClassicProgressEngineFall )
	}
	else
	{
		// State doesn't change
		level.shipEngineRight.Destroy()
		thread ShipEngineMalfunction( level.shipEngineLeft )
		thread EngineLoopSound( level.shipEngineLeft )

		ShipLightsTurnOn()
		level.nv.shipFx = true

		GetEnt( "fx_engine_break_1" ).Fire( "start" )
		GetEnt( "fx_engine_break_2" ).Fire( "start" )
		GetEnt( "fx_engine_break_3" ).Fire( "start" )
	}
}

function ProgressAnnouncementEarly()
{
	if ( GetTeamIndex(GetWinningTeam()) == TEAM_IMC )
	{
		PlayConversationToTeam( "EarlyProgressWinning", TEAM_IMC )
		PlayConversationToTeam( "EarlyProgressLosing", TEAM_MILITIA )
	}
	else if ( GetTeamIndex(GetWinningTeam()) == TEAM_MILITIA )
	{
		PlayConversationToTeam( "EarlyProgressWinning", TEAM_MILITIA )
		PlayConversationToTeam( "EarlyProgressLosing", TEAM_IMC )
	}
}

function ProgressAnnouncementMid()
{
	if ( GetTeamIndex(GetWinningTeam()) == TEAM_IMC )
	{
		PlayConversationToTeam( "MidProgressWinning", TEAM_IMC )
		PlayConversationToTeam( "MidProgressLosing", TEAM_MILITIA )
	}
	else if ( GetTeamIndex(GetWinningTeam()) == TEAM_MILITIA )
	{
		PlayConversationToTeam( "MidProgressWinning", TEAM_MILITIA )
		PlayConversationToTeam( "MidProgressLosing", TEAM_IMC )
	}
}

function ProgressAnnouncementLate()
{
	if ( GetTeamIndex(GetWinningTeam()) == TEAM_IMC )
	{
		PlayConversationToTeam( "LateProgressWinning", TEAM_IMC )
		PlayConversationToTeam( "LateProgressLosing", TEAM_MILITIA )
	}
	else if ( GetTeamIndex(GetWinningTeam()) == TEAM_MILITIA )
	{
		PlayConversationToTeam( "LateProgressWinning", TEAM_MILITIA )
		PlayConversationToTeam( "LateProgressLosing", TEAM_IMC )
	}
}


function ProgressStageMilitia_Middle()
{
	PlayConversationToTeam( "matchProg_MIL02", TEAM_MILITIA )
	wait 27 // rough estimate of how long the conversation lasts
}

function ProgressStageMilitia_Late()
{
	PlayConversationToTeam( "matchProg_MIL03", TEAM_MILITIA )
}

function ProgressStageMilitia_Last()
{
	PlayConversationToTeam( "matchProg_MIL04", TEAM_MILITIA )
	thread MacAllanPickup( 5.5 )
}

function ProgressStageIMC_Early()
{
	PlayConversationToTeam( "matchProg_IMC01", TEAM_IMC )
	wait 15 // rough estimate of how long the conversation lasts
}

function ProgressStageIMC_Late()
{
	PlayConversationToTeam( "matchProg_IMC03", TEAM_IMC )
}

function ProgressStageIMC_Last()
{
	PlayConversationToTeam( "matchProg_IMC04", TEAM_IMC )
	wait 20 // rough estimate of how long the conversation lasts
}

function ProgressStagePowerOn()
{
	PlayConversationToTeam( "matchProg_MIL01", TEAM_MILITIA )
	wait 3
	ShipLightsTurnOn()

	// the wait time are based on current anim and dialog length.
	wait 9.75

	PlayConversationToTeam( "matchProg_IMC02", TEAM_IMC )
	wait 5
	ProgressStageEngineStart()
	wait 15 // rough length of IMC conversation
	level.nv.shipSpeakers = true
}

function ShipLightsTurnOn()
{
	level.nv.shipLights = true
	EmitSoundAtPosition( Vector( 805, -3857, 800 ), "Relic_Scr_ShipLights_On" )
	EmitSoundAtPosition( Vector( -1167, -3637, 800 ), "Relic_Scr_ShipLights_On" )
}

function ShipLightsTurnOff()
{
	level.nv.shipLights = false
	EmitSoundAtPosition( Vector( 805, -3857, 800 ), "Relic_Scr_ShipLights_Off" )
	EmitSoundAtPosition( Vector( -1167, -3637, 800 ), "Relic_Scr_ShipLights_Off" )
}

function ProgressStageEngineStart()
{
	level.engineStartTime = Time()
	level.nv.shipFx = true
	thread ActivateShipEngine( level.shipEngineLeft )
	wait 3
	thread ActivateShipEngine( level.shipEngineRight )
}

function ProgressStageEngineMalfunction()
{
	thread ShipEngineMalfunction( level.shipEngineRight )
	delaythread( 10 ) ShipEngineMalfunction( level.shipEngineLeft )
}

function ProgressStage_Late()
{
	thread ProgressStageMilitia_Late()
	thread ProgressStageIMC_Late()
	thread RightEngineFallOff()
	wait 30	// rough estimate of how long the conversation lasts
}

function MacAllanPickup( delay )
{
	local origin = Vector( 5312, -3104, 120 )
	local angles = Vector( 0, 0, 0 )

	local povCamera = CreateEntity( "prop_dynamic" )
	povCamera.kv.targetname = "pov_model"
	povCamera.kv.model = POV_MODEL
	DispatchSpawn( povCamera )
	povCamera.Hide()

	wait delay - WARPINFXTIME
	waitthread WarpinEffect( CROW_MODEL, "ds_relic_runto_dropship", origin, angles )

	local dropship = SpawnAnimatedDropship( origin, TEAM_MILITIA, null, null, null, CROW_MODEL )
	dropship.SetNoTarget( true )
	dropship.SetNoTargetSmartAmmo( true )
	dropship.EndSignal( "OnDestroy" )

	povCamera.SetParent( dropship, "ORIGIN" )

	level.povCamera = povCamera
	local mac = CreatePropDynamic( MAC_MODEL, origin, angles )
	mac.SetName( "mac" )
	mac.SetParent( dropship, "ORIGIN" )

	thread PlayAnimTeleport( povCamera, "ptpov_relic_runto_dropship", dropship, "ORIGIN" )
	thread PlayAnimTeleport( mac, "pt_relic_runto_dropship_macallan", dropship, "ORIGIN" )
	waitthread  PlayAnimTeleport( dropship, "ds_relic_runto_dropship", origin, angles )

	dropship.Destroy()
}

function ClassicProgressEngineStart()
{
	ShipLightsTurnOn()
	wait 10
	ProgressStageEngineStart()
}

function ClassicProgressMalfunction()
{
	thread ShipEngineMalfunction( level.shipEngineRight )
	wait 10
	thread ShipEngineMalfunction( level.shipEngineLeft )
}

function ClassicProgressEngineFall()
{
	thread RightEngineFallOff()
}

function MatchProgressUpdate()
{
	thread MatchProgressUpdateThread( level.nv.matchProgress )
}

function MatchProgressUpdateThread( progression )
{
	if ( level.devForcedWin )  //Don't announce progress if we force win
		return

	foreach ( funcTable in level.progressFuncArray )
	{
		if ( funcTable.called && !funcTable.done )
			return	// this will stop anything later to run until the current update is done.

		if ( funcTable.done )
			continue

		if ( level.nv.matchProgress < funcTable.progress )
			continue

		if ( !funcTable.everyTime )
			funcTable.called = true

		waitthread funcTable.func()

		if ( !funcTable.everyTime )
			funcTable.done = true
	}
}

function AddProgressionFunc( progress, func, everyTime = false )
{
	local funcTable = {}
	funcTable.func			<- func
	funcTable.progress		<- progress
	funcTable.everyTime		<- everyTime
	funcTable.scope			<- this
	funcTable.called		<- false
	funcTable.done			<- false

	level.progressFuncArray.append( funcTable )
}

/*--------------------------------------------------------------------------------------------------------*\
|
|												  SHIP
|
\*--------------------------------------------------------------------------------------------------------*/

function SetupShipEngines()
{
	level.shipEngineLeft = GetEnt( "engine_front_left" )
	level.shipEngineRight = GetEnt( "engine_front_right" )

	level.shipEngineLeft.Anim_Play( "engine_relic_idleOff" )
	level.shipEngineRight.Anim_Play( "engine_relic_idleOff" )

	AddAnimEvent( level.shipEngineLeft, "relic_engine_start_sound", EngineStartSound )
	AddAnimEvent( level.shipEngineRight, "relic_engine_start_sound", EngineStartSound )

	AddAnimEvent( level.shipEngineLeft, "relic_engine_loop_sound", EngineLoopSound )
	AddAnimEvent( level.shipEngineRight, "relic_engine_loop_sound", EngineLoopSound )

	AddAnimEvent( level.shipEngineLeft, "relic_engine_malfunction_sound", EngineMalfunctionSound )
	AddAnimEvent( level.shipEngineRight, "relic_engine_malfunction_sound", EngineMalfunctionSound )

	AddAnimEvent( level.shipEngineRight, "relic_engine_break_sound", EngineBreakSound )

	CreateEngineCollision( level.shipEngineLeft )
	CreateEngineCollision( level.shipEngineRight )

	CreateSoundSource( level.shipEngineLeft )
	CreateSoundSource( level.shipEngineRight )

	level.shipEngineLeft.SetAngles( level.shipEngineLeft.GetAngles() + Vector( -10, 1.0, 0 ) )

	level.hurtTrigger1 = GetEnt( "engine_crush1" )
	level.hurtTrigger2 = GetEnt( "engine_crush2" )
}

function CreateSoundSource( engine )
{
	engine.s.soundEnt <- CreateScriptMover()
	engine.s.soundEnt.SetName( "soundSource" )
	engine.s.soundEnt.SetParent( engine, "R_exhaust_side_1" )
}

function EngineStartSound( entity )
{
	EmitSoundOnEntity( entity.s.soundEnt, "Relic_Scr_ShipEngines_On" )
}

function EngineLoopSound( entity )
{
	EmitSoundOnEntity( entity.s.soundEnt, "Relic_Scr_ShipEngines_Loop" )
}

function EngineMalfunctionSound( entity )
{
	EmitSoundOnEntity( entity.s.soundEnt, "Relic_Scr_ShipEngines_Malfunction" )
}

function EngineBreakSound( entity )
{
	entity.EndSignal( "OnDestroy" )
	local soundEnt = CreateScriptMover()
	soundEnt.SetName( "breakSource" )
	soundEnt.SetParent( entity, "collision" )

	OnThreadEnd(
		function() : ( soundEnt )
		{
			if( IsValid( soundEnt ) )
				soundEnt.Destroy()
		}
	)

	EmitSoundOnEntity( soundEnt, "Relic_Scr_ShipEngines_Break" )
	local duration = entity.GetSequenceDuration( "engine_relic_fall_L" )
	wait duration + 5 // sound is a bit longer then then animation but since I can't get the exact length lets fudge it a bit.
}

function StopEngineLoopSound( entity )
{
	FadeOutSoundOnEntity( entity.s.soundEnt, "Relic_Scr_ShipEngines_Loop", 2 )
}

function CreateEngineCollision( engine )
{
	local id = engine.LookupAttachment( "collision" )
	local origin = engine.GetAttachmentOrigin( id )
	local angles = engine.GetAttachmentAngles( id )

	local collision = CreatePropDynamic( ENGINE_COLLISION, origin, angles, 6 )
	collision.Hide()

	local id = engine.LookupAttachment( "ORIGIN" )
	local origin = engine.GetAttachmentOrigin( id )
	local angles = engine.GetAttachmentAngles( id )

	local collision2 = CreatePropDynamic( ENGINE_COLLISION_2, origin, angles, 6 )
	collision2.Hide()

	engine.s.collision <- collision
	engine.s.collision2 <- collision2
}

function ActivateShipEngine( engine )
{
	engine.Signal( "StopEngineIdle" )
	engine.EndSignal( "OnDestroy" )

	if ( GetBugReproNum() == 1970 )
		DebugDrawText( engine.GetOrigin(), "engine_relic_turnOn", false, engine.GetSequenceDuration( "engine_relic_turnOn" ) )

	engine.Anim_Play( "engine_relic_turnOn" )
	engine.WaittillAnimDone()

	engine.Anim_Play( "engine_relic_idleOn" )
	if ( GetBugReproNum() == 1970 )
		DebugDrawText( engine.GetOrigin(), "engine_relic_idleOn", false, 3 )
}

function DeactivateShipEngine( engine )
{
	engine.Signal( "StopEngineIdle" )

	// should get an animation for turning the engine off.
	engine.Anim_Play( "engine_relic_shudder1" )
	engine.WaittillAnimDone()
	engine.Anim_Play( "engine_relic_idleOff" )

	StopEngineLoopSound( engine )
}

function ShipEngineMalfunction( engine )
{
	engine.Signal( "StopEngineIdle" )
	engine.EndSignal( "OnDestroy" )
	engine.EndSignal( "StopEngineIdle" )

	local animList = []
	animList.append( { anim = "engine_relic_shudder1", weight = 4, count = 0 } )
	animList.append( { anim = "engine_relic_shudder2", weight = 3, count = 0 } )
	animList.append( { anim = "engine_relic_shudder3", weight = 5, count = 0 } )
	animList.append( { anim = "engine_relic_adjust1",  weight = 1, count = 0 } )
	animList.append( { anim = "engine_relic_adjust2",  weight = 1, count = 0 } )

	local totalWeight = 0.0
	foreach( animTable in animList )
		totalWeight += animTable.weight

	local count = 0
	local shudderAnim
	while( true )
	{
		local roll = RandomFloat( 0, 1 )
		local weight = 0
		foreach( animTable in animList )
		{
			weight += animTable.weight - animTable.count
			if ( roll > ( weight.tofloat() / ( totalWeight - count ) ) )
				continue

			shudderAnim = animTable.anim
			animTable.count++
			break
		}

		local progress = level.nv.matchProgress
		local fraction = GraphCapped( progress, ENGINE_MALFUNCTION_PROGRESS, ENGINE_FALL_OFF_PROGRESS, 1, 0 )
		local delay = RandomFloat( 10.0, 30.0 ) * fraction

		if ( GetBugReproNum() == 1970 )
		{
			DebugDrawText( engine.GetOrigin(), shudderAnim, false, engine.GetSequenceDuration( shudderAnim ) )
			delay = 5
		}

		engine.Anim_Play( shudderAnim )
		engine.WaittillAnimDone()

		engine.Anim_Play( "engine_relic_idleOn" )

		if ( GetBugReproNum() == 1970 )
			DebugDrawText( engine.GetOrigin(), "engine_relic_idleOn", false, delay )

		wait delay

		count++
		if ( count == totalWeight )
		{
			// reset counts when everything has been used up.
			count = 0
			foreach( animTable in animList )
				animTable.count = 0
		}
	}
}

function RightEngineFallOff()
{
	level.shipEngineRight.Signal( "StopEngineIdle" )
	level.shipEngineRight.Anim_Play( "engine_relic_idleOn" )

	local collision = GetEnt( "engine_collision" )
	if ( IsValid( collision ) )
		collision.Destroy()

	GetEnt( "fx_engine_break_1" ).Fire( "start" )
	GetEnt( "fx_engine_break_2" ).Fire( "start" )
	GetEnt( "fx_engine_break_3" ).Fire( "start" )

	if ( IsValid( level.shipEngineRight.s.collision ) )
		level.shipEngineRight.s.collision.Destroy()
	if ( IsValid( level.shipEngineRight.s.collision2 ) )
		level.shipEngineRight.s.collision2.Destroy()

	wait 1

	level.shipEngineRight.Anim_Play( "engine_relic_fall_L" )
	StopEngineLoopSound( level.shipEngineRight )

	wait 6
	level.hurtTrigger1.Fire( "enable" )
	wait 1
	level.hurtTrigger2.Fire( "enable" )
	wait 1
	level.hurtTrigger1.Fire( "disable" )
	wait 1
	level.hurtTrigger2.Fire( "disable" )
}


function DevActivateEngines()
{
	wait 0.5
	thread ActivateShipEngine( level.shipEngineLeft )
	wait 2.0
	thread ActivateShipEngine( level.shipEngineRight )
}

function DevDeactivateEngines()
{
	wait 0.5
	thread DeactivateShipEngine( level.shipEngineLeft )
	thread DeactivateShipEngine( level.shipEngineRight )
}

function DevShipEnginesMalfunction()
{
	wait 0.5
	thread ShipEngineMalfunction( level.shipEngineLeft )
	thread ShipEngineMalfunction( level.shipEngineRight )
}

/*--------------------------------------------------------------------------------------------------------*\
|
|												  INTRO
|
\*--------------------------------------------------------------------------------------------------------*/
function RelicIntros()
{
	FlagSet( "Disable_IMC" )
	FlagSet( "Disable_MILITIA" )

	RelicIntroIMCSetup()
	RelicIntroMilitiaSetup()

	FlagWait( "ReadyToStartMatch" )

	SetGlobalForcedDialogueOnly( true )

	thread RelicIntroIMC()
	thread RelicIntroIMCDialog()
	thread RelicIntroIMCGrunts()

	thread RelicIntroMilitia()
	thread RelicIntroMilitiaGrunts()

	// how long after the 10 sec countdown start to start the final dropship anim
	delaythread( 8 ) FlagSet( "StartMilitiaDropships" )
	delaythread( 8 ) FlagSet( "StartIMCDropships" )

	WaittillGameStateOrHigher( eGameState.Playing )	// this will be as the guys jump out of the ship

	wait 15.0	// arbitrary delay before dialog can start and the game mode announcement happens
	SetGlobalForcedDialogueOnly( false )
	FlagSet( "IntroDone" )

	wait 10.0 // let new ai spawn in as needed, all cinematic stuff should be done

	ReleaseCinematicNPC()
	FlagClear( "Disable_IMC" )
	FlagClear( "Disable_MILITIA" )

	PlayConversationToAll( "groundIntro" )
}

function ReleaseCinematicNPC()
{
	Assert( IsAttritionMode() )

	local teamNames = [ "IMC", "MILITIA" ]
	local squadNames = [ "squad0", "squad1", "squad2" ]

	foreach( team in teamNames )
	{
		foreach( index, squadName in squadNames )
		{
			local combinedName = team + "_" + squadName
			if ( !GetNPCSquadSize( combinedName ) )
				continue

			local squad = GetNPCArrayBySquad( combinedName )

			foreach( npc in squad )
			{
				npc.SetLookDist( 5000 )
				npc.AllowHandSignals( true )
				npc.StayPut( false )
				// npc.Signal( "StopPath" )
				// npc.DisableBehavior( "Assault" )
			}

			if ( squad.len() )
				ScriptedSquadAssault( squad, index )
		}
	}
}

function RelicIntroIMCSetup()
{
	//IMC SIDE
	////////////////////////////////////////////////////////////
	local create_1				= CreateCinematicDropship()
	create_1.origin 			= Vector( 0,0,0 )
	create_1.team				= TEAM_IMC
	create_1.count 				= 4
	create_1.side 				= "jumpSideR"
	create_1.turret				= false

	local event_idle_1 			= CreateCinematicEvent()
	event_idle_1.origin 		= Vector( 0,0,0 )
	event_idle_1.yaw	 		= 0
	event_idle_1.anim			= "dropship_player_intro_idle"
	event_idle_1.teleport 		= true
	Event_AddFlagWaitToEnd( event_idle_1, "StartIMCDropships" )
	Event_AddServerStateFunc( event_idle_1, CE_PlayerSkyScaleIMC )
	Event_AddClientStateFunc( event_idle_1, "CE_VisualSettingRelicIMC" )

	local event_flyin_1 		= CreateCinematicEvent()
	event_flyin_1.origin 		= Vector( -3848, -4300, 700 )
	event_flyin_1.yaw			= 90
	event_flyin_1.anim			= "relic_imc_intro_dropship_flyin"
	event_flyin_1.teleport		= true

	local event_flyaway_1 		= CreateCinematicEvent()
	event_flyin_1.origin 		= Vector( -3848, -4300, 700 )
	event_flyaway_1.yaw			= 90
	event_flyaway_1.anim		= "relic_imc_intro_dropship_flyaway"

	Event_AddAnimStartFunc( event_flyin_1, RelicIntroIMCHeros )

	AddSavedDropEvent( "introDropShipIMC_1cr", create_1 )
	AddSavedDropEvent( "introDropShipIMC_1e0", event_idle_1 )
	AddSavedDropEvent( "introDropShipIMC_1e1", event_flyin_1 )
	AddSavedDropEvent( "introDropShipIMC_1e2", event_flyaway_1 )

	////////////////////////////////////////////////////////////
	local create_2				= CreateCinematicDropship()
	create_2.origin 			= Vector( 0,0,0 )
	create_2.team				= TEAM_IMC
	create_2.count 				= 4
	create_2.side 				= "jumpSideR"
	create_2.turret				= false

	local event_idle_2 			= CreateCinematicEvent()
	event_idle_2.origin 		= Vector( 0,0,0 )
	event_idle_2.yaw	 		= 0
	event_idle_2.anim			= "dropship_player_intro_idle"
	event_idle_2.teleport		= true
	Event_AddFlagWaitToEnd( event_idle_2, "StartIMCDropships" )
	Event_AddServerStateFunc( event_idle_2, CE_PlayerSkyScaleIMC )
	Event_AddClientStateFunc( event_idle_2, "CE_VisualSettingRelicIMC" )

	local event_flyin_2 		= CreateCinematicEvent()
	event_flyin_2.origin 		= Vector( -4034, -3114, 600 )
	event_flyin_2.yaw			= 90
	event_flyin_2.anim			= "relic_imc_intro_dropship_flyin"
	event_flyin_2.teleport 		= true

	local event_flyaway_2 		= CreateCinematicEvent()
	event_flyaway_2.origin 		= Vector( -4034, -3114, 600 )
	event_flyaway_2.yaw			= 90
	event_flyaway_2.anim		= "relic_imc_intro_dropship_flyaway"

	Event_AddAnimStartFunc( event_flyin_2, RelicIntroIMCHeros )

	AddSavedDropEvent( "introDropShipIMC_2cr", create_2 )
	AddSavedDropEvent( "introDropShipIMC_2e0", event_idle_2 )
	AddSavedDropEvent( "introDropShipIMC_2e1", event_flyin_2 )
	AddSavedDropEvent( "introDropShipIMC_2e2", event_flyaway_2 )
}

function RelicIntroIMC()
{
	local create_1 			= GetSavedDropEvent( "introDropShipIMC_1cr" )
	local event_idle_1 		= GetSavedDropEvent( "introDropShipIMC_1e0" )
	local event_flyin_1 	= GetSavedDropEvent( "introDropShipIMC_1e1" )
	local event_flyaway_1 	= GetSavedDropEvent( "introDropShipIMC_1e2" )

	local create_2 			= GetSavedDropEvent( "introDropShipIMC_2cr" )
	local event_idle_2 		= GetSavedDropEvent( "introDropShipIMC_2e0" )
	local event_flyin_2 	= GetSavedDropEvent( "introDropShipIMC_2e1" )
	local event_flyaway_2 	= GetSavedDropEvent( "introDropShipIMC_2e2" )

	local dropship1 = SpawnCinematicDropship( create_1 )
	dropship1.NotSolid()
	thread RunCinematicDropship( dropship1, event_idle_1, event_flyin_1, event_flyaway_1 )

	local dropship2 = SpawnCinematicDropship( create_2 )
	dropship2.NotSolid()
	thread RunCinematicDropship( dropship2, event_idle_2, event_flyin_2, event_flyaway_2)

	thread IntroIMCExperience( dropship1, dropship2 )

	dropship1.SetJetWakeFXEnabled( false )
	dropship2.SetJetWakeFXEnabled( false )

//	DebugSkipCinematicSlots( TEAM_IMC, 1 )
}

function CE_PlayerSkyScaleIMC( player, ref )
{
	player.LerpSkyScale( SKYSCALE_RELIC_IMC_PLAYER, 0.01 )
}

function IntroIMCExperience( dropship1, dropship2 )
{
	thread IntroDropshipSounds( dropship1, "Relic_Scr_IMCIntro_FlyIn" )
	thread IntroDropshipSounds( dropship2, "Relic_Scr_IMCIntro_FlyIn" )
}

function RelicIntroIMCDialog()
{
	wait 4
	ForcePlayConversationToTeam( "matchIntro", TEAM_IMC )
}

function RelicIntroIMCHeros( dropship, ref, table )
{
	local pilot = CreatePropDynamic( TEAM_IMC_GRUNT_MDL )
	local graves = CreatePropDynamic( GRAVES_MODEL, dropship.GetOrigin(), dropship.GetAngles() )

	pilot.SetParent( dropship, "ORIGIN" )
	graves.SetParent( dropship, "ORIGIN" )

	pilot.MarkAsNonMovingAttachment()
	graves.MarkAsNonMovingAttachment()

	pilot.LerpSkyScale( SKYSCALE_RELIC_IMC_ACTOR, 0.01 )
	graves.LerpSkyScale( SKYSCALE_RELIC_IMC_ACTOR, 0.01 )

	thread PlayAnimTeleport( pilot, "Militia_flyinA_idle_mac", dropship, "ORIGIN" )
	waitthread PlayAnimTeleport( graves,  "gr_relic_flyin", dropship, "ORIGIN" )
}

function RelicIntroIMCGrunts()
{
	wait 21.5
	local origin = Vector( -2991, -2955, 504 )
	local angles = Vector( 0, 23, 0 )
	local destination = Vector( 569, -3479, 476 )
	thread IntroNpcDropPod( TEAM_IMC, 4, origin, angles, destination, "IMC_squad1" )

	wait 1
	origin = Vector( -2997, -4599, 446 )
	angles = Vector( 0, 28, 0 )
	destination = Vector( 516, -4235, 383 )
	thread IntroNpcDropPod( TEAM_IMC, 4, origin, angles, destination,  "IMC_squad2" )

	wait 5
	origin = Vector( -2127, -1561, 40 )
	angles = Vector( 0, -38, 0 )
	destination = Vector( 569, -3479, 476 )
	thread IntroNpcDropPod( TEAM_IMC, 4, origin, angles, destination, "IMC_squad0" )
}

function RelicIntroMilitiaSetup()
{
	local create_1				= CreateCinematicDropship()
	create_1.origin 			= Vector( 0, 0, 0 )
	create_1.team				= TEAM_MILITIA
	create_1.count 				= 6
	create_1.side 				= "jumpSideR"
	create_1.turret				= false

	local event_idle_1			= CreateCinematicEvent()
	event_idle_1.origin 		= Vector( 0, 0, 0 )
	event_idle_1.yaw			= 0
	event_idle_1.anim			= "dropship_player_intro_idle"
	event_idle_1.teleport 		= true
	Event_AddFlagWaitToEnd( event_idle_1, "StartMilitiaDropships" )
	Event_AddServerStateFunc( event_idle_1, CE_PlayerSkyScaleMCOR )
	Event_AddClientStateFunc( event_idle_1, "CE_VisualSettingRelicMCOR" )

	local event_flyin_1			= CreateCinematicEvent()
	event_flyin_1.origin 		= Vector( 5312, -3104, 76 )
	event_flyin_1.yaw			= 0
	event_flyin_1.anim			= "relic_Mcor_intro_Dropship"

	Event_AddAnimStartFunc( event_flyin_1, RelicIntroMilitiaHerosMain )

	AddSavedDropEvent( "introDropShipMCOR_1cr", create_1 )
	AddSavedDropEvent( "introDropShipMCOR_1e0", event_idle_1 )
	AddSavedDropEvent( "introDropShipMCOR_1e1", event_flyin_1 )
}

function RelicIntroMilitia()
{
	local create_1 			= GetSavedDropEvent( "introDropShipMCOR_1cr" )
	local event_idle_1 		= GetSavedDropEvent( "introDropShipMCOR_1e0" )
	local event_flyin_1 	= GetSavedDropEvent( "introDropShipMCOR_1e1" )

	local dropship1 = SpawnCinematicDropship( create_1 )
	dropship1.SetName( "introDropship" )
	dropship1.NotSolid()
	thread RunCinematicDropship( dropship1, event_idle_1, event_flyin_1 )

	thread IntroMCORExperience( dropship1 )

	dropship1.SetJetWakeFXEnabled( false )

//	DebugSkipCinematicSlots( TEAM_MILITIA, 5 )
}

function CE_PlayerSkyScaleMCOR( player, ref )
{
	player.LerpSkyScale( SKYSCALE_RELIC_MCOR_PLAYER, 0.01 )
}

function IntroMCORExperience( dropship )
{
	thread IntroDropshipSounds( dropship, "Relic_Scr_MilitiaIntro_DropshipFlyinAmb", "Relic_Scr_MilitiaIntro_DropshipFlyaway" )
}

function RelicIntroMilitiaHerosMain( dropship, ref, table )
{
	local solidType = 8
	local fadeDist = 5000

	local animOrigin = Vector( 5312, -3104, 76 )
	local animAngles = Vector( 0, 0, 0 )

	local pilot = CreatePropDynamic( TEAM_MILITIA_GRUNT_MDL )
	local bish = CreatePropDynamic( BISH_MODEL, animOrigin, animAngles, solidType, fadeDist )
	local mac = CreatePropDynamic( MAC_MODEL, animOrigin, animAngles, solidType, fadeDist )
	local rock = CreatePropDynamic( ROCK_MODEL, animOrigin, animAngles )

	mac.SetName( "mac" )

	pilot.SetParent( dropship, "ORIGIN" )
	bish.SetParent( dropship, "ORIGIN" )

	pilot.MarkAsNonMovingAttachment()
	bish.MarkAsNonMovingAttachment()

	pilot.LerpSkyScale( SKYSCALE_RELIC_MCOR_ACTOR, 0.01 )
	bish.LerpSkyScale( SKYSCALE_RELIC_MCOR_ACTOR, 0.01 )

	local ref = CreateScriptRef( Vector( 5312, -3104, 76 ), Vector( 0, 0, 0 ) )

	AddAnimEvent( mac, "skyScaleLerp1", MacAllanSkyScaleLerp1 )
	AddAnimEvent( mac, "skyScaleLerp2", MacAllanSkyScaleLerp2 )

	thread PlayAnimTeleport( pilot, "Militia_flyinA_idle_mac", dropship, "ORIGIN" )
	thread PlayAnimTeleport( bish,  "relic_Mcor_intro_Bish_alt", dropship, "ORIGIN" )
	thread PlayAnimTeleport( mac, "relic_Mcor_intro_Mac", ref )
	rock.Anim_Play( "relic_Mcor_intro_rock" )

	dropship.WaitSignal( "dropoff" )

	ForcePlayConversationToTeam( "matchIntroMilitiaMac", TEAM_MILITIA )

	bish.Anim_Stop()
	mac.Anim_Stop()

	mac.SetParent( dropship, "ORIGIN" )
	mac.MarkAsNonMovingAttachment()

	local weaponModel = CreatePropPhysics( "models/weapons/rspn101/w_rspn101.mdl" )
	weaponModel.SetParent( mac, "PROPGUN", false, 0.0 )
	weaponModel.MarkAsNonMovingAttachment()

	thread PlayAnimTeleport( bish, "relic_jumpoff_dropship_bish", dropship, "ORIGIN" )
	PlayAnimTeleport( mac, "relic_jumpoff_dropship_macallan", dropship, "RESCUE" )

	if ( IsValid( bish ) )
		bish.Destroy()
	if ( IsValid( mac ) )
		mac.Destroy()
	if ( IsValid( rock ) )
		rock.Destroy()
}

//when he's engulfed by the shadow of the ship
function MacAllanSkyScaleLerp1( mac )
{
	local delta = ( SKYSCALE_DEFAULT - SKYSCALE_RELIC_MCOR_ACTOR ) * 0.6
	delta += SKYSCALE_RELIC_MCOR_ACTOR

	mac.LerpSkyScale( delta, 0.5 )
}

//when he enters the ship
function MacAllanSkyScaleLerp2( mac )
{
	mac.LerpSkyScale( SKYSCALE_RELIC_MCOR_ACTOR, 0.75 )
}

function TestMilitiaIntro()
{
	local create_1				= CreateCinematicDropship()
	create_1.origin 			= Vector( 0, 0, 0 )
	create_1.team				= TEAM_MILITIA
	create_1.count 				= 6
	create_1.side 				= "jumpSideR"
	create_1.turret				= false

	local event_flyin_1			= CreateCinematicEvent()
	event_flyin_1.origin 		= Vector( 5312, -3104, 76 )
	event_flyin_1.yaw			= 0
	event_flyin_1.anim			= "relic_Mcor_intro_Dropship"

	Event_AddAnimStartFunc( event_flyin_1, RelicIntroMilitiaHerosMain )

	local dropship1	= SpawnCinematicDropship( create_1 )
	dropship1.SetName( "introDropship" )
	dropship1.NotSolid()
	thread RunCinematicDropship( dropship1, event_flyin_1 )
}

function RelicIntroMilitiaGrunts()
{
	wait 18.5

	local origin = Vector( 4153, -4679, 100 )
	local angles = Vector(0, 75, 0 )
	local destination = Vector( 2000, -5050, 345 )
	thread IntroNpcDropship( TEAM_MILITIA, 4, origin, angles, destination, "MILITIA_squad0" )

	wait 6
	origin = Vector( 4030, -5077, 5 )
	angles = Vector( 0, 121, 0 )
	destination = Vector( 1827, -3826, 340 )
	thread IntroNpcDropPod( TEAM_MILITIA, 4, origin, angles, destination, "MILITIA_squad1" )

	wait 1
	origin = Vector( 4124, -2955, 66 )
	angles = Vector( 0, -155, 0 )
	destination = Vector( 2144, -2448, 200 )
	thread IntroNpcDropPod( TEAM_MILITIA, 4, origin, angles, destination,  "MILITIA_squad2" )
}

function IntroNpcDropship( team, count, origin, angles, destination, squadName )
{
	local ref = CreateScriptRef( origin, angles )
	ref.s.inUse <- false	// mimics a real spawnpoint
	local squad = Spawn_TrackedZipLineGruntSquad( team, count, ref, squadName )
	ref.Destroy()

	foreach( guy in squad )
	{
		if ( IsAlive( guy ) )
			thread MoveToAfterDeployed( guy, destination )
	}
}

function IntroNpcDropPod( team, count, origin, angles, destination, squadName )
{
	local squad = Spawn_ScriptedTrackedDropPodGruntSquad( team, count, origin, angles, squadName )

	foreach( guy in squad )
	{
		if ( IsAlive( guy ) )
			thread MoveToAfterDeployed( guy, destination )
	}
}

function MoveToAfterDeployed( guy, destination )
{
	guy.EndSignal( "OnDeath" )

	guy.WaitSignal( "npc_deployed" )
	guy.AssaultPoint( destination, 512 )
}

function IntroDropshipSounds( dropship, sound, sound2 = null )
{
	WaittillGameStateOrHigher( eGameState.Prematch )
	PlaySoundToAttachedPlayers( dropship, sound )

	WaittillGameStateOrHigher( eGameState.Playing )

	if ( sound2 )
		EmitSoundOnEntity( dropship, sound2 )
}

/*--------------------------------------------------------------------------------------------------------*\
|
|												  EVAC
|
\*--------------------------------------------------------------------------------------------------------*/

function EvacSetup()
{
	local verticalAnims = Evac_CreateAnimPackage( "dropship_VTOL_evac_start", "dropship_VTOL_evac_idle", "dropship_VTOL_evac_end" )

	local spectatorNode1 = GetEnt( "spec_cam1" )
	local spectatorNode2 = GetEnt( "spec_cam2" )
	local spectatorNode3 = GetEnt( "spec_cam3" )
//	local spectatorNode4 = GetEnt( "spec_cam4" )
//	local spectatorNode5 = GetEnt( "spec_cam5" )

	Evac_AddLocation( "escape_node1", spectatorNode1.GetOrigin(), spectatorNode1.GetAngles(), verticalAnims )
	Evac_AddLocation( "escape_node2", spectatorNode2.GetOrigin(), spectatorNode2.GetAngles(), verticalAnims )
	Evac_AddLocation( "escape_node3", spectatorNode3.GetOrigin(), spectatorNode3.GetAngles(), verticalAnims )
//	Evac_AddLocation( "escape_node4", spectatorNode4.GetOrigin(), spectatorNode4.GetAngles(), verticalAnims )
//	Evac_AddLocation( "escape_node5", spectatorNode5.GetOrigin(), spectatorNode5.GetAngles(), verticalAnims )

	local spacenode = CreateScriptRef( Vector( 9668, -996, -7600 ), Vector( 0, 90, 0 ) )
	Evac_SetSpaceNode( spacenode )

	Evac_SetupDefaultVDUs()

	GM_SetObserverFunc( EvacObserverFunc )
}

function EndRoundMain()
{
	if ( EvacEnabled() )
		EvacRoundEnd()

	if ( !level.playCinematicContent )
		return

	thread MidEpilogue()
}

function MidEpilogue()
{
	wait 5
	SetGlobalForcedDialogueOnly( true )
	wait 5
	ForcePlayConversationToAll( "epilogue_mid" )
	wait 22
	SetGlobalForcedDialogueOnly( false )

	FlagWait( "EvacShipArrive" )
	wait 5

	if ( GetTeamIndex(GetWinningTeam()) == TEAM_IMC )
	{
//		IMC post epilogue lines moved into "epilogue_mid"
//		ForcePlayConversationToTeam( "post_epilogue_win", TEAM_IMC )
		ForcePlayConversationToTeam( "post_epilogue_loss", TEAM_MILITIA )
	}
	else
	{
		ForcePlayConversationToTeam( "post_epilogue_win", TEAM_MILITIA )
//		IMC post epilogue lines moved into "epilogue_mid"
//		ForcePlayConversationToTeam( "post_epilogue_loss", TEAM_IMC )
	}
}

function CarrierWarpinEffect( origin, angles )
{
	local time = 0.54

	local totalTime = 2.0
	local preWait = 0
	//wait preWait
	EmitSoundAtPosition( origin, "dropship_warpin" )
	wait ( totalTime - preWait )
	local fx = PlayFX( FX_CARRIER_WARPIN, origin, angles )
	//DrawArrow( origin, angles, 10.0, 350 )
	fx.EnableRenderAlways()

	wait time
	wait 0.16
}

function EvacRoundEnd()
{
	if ( level.playCinematicContent )
	{
		//-------------------------
		// Cinematic specific evac stuff
		//-------------------------
	}

	//-------------------------
	// Break AI out of global logic and have them die easier
	//-------------------------

	foreach( hardpoint in level.hardpoints )
	{
		// stop hardpoint ai think function
		hardpoint.Signal( "SquadCapturePointThink_TEAM_IMC" )
		hardpoint.Signal( "SquadCapturePointThink_TEAM_MILITIA" )
	}

	local npcArray = GetGruntsAndSpectres()
	foreach( index, npc in npcArray )
	{
		if( IsValid( npc ) )
		{
			npc.SetHealth( 1 )
			npc.Signal( "StopHardpointBehavior" )
			npc.DisableBehavior( "Assault" )
		}
	}
}

function GetGruntsAndSpectres()
{
	local dudes = GetNPCArrayByClass( "npc_spectre" )
	ArrayAppend( dudes, GetNPCArrayByClass( "npc_soldier" ) )
	return dudes
}

function EvacObserverFunc( player )
{
	player.SetObserverModeStaticPosition( level.ExtractLocations[ level.SelectedExtractLocationIndex ].spectatorPos )
	player.SetObserverModeStaticAngles( level.ExtractLocations[ level.SelectedExtractLocationIndex ].spectatorAng )

	player.StartObserverMode( OBS_MODE_CHASE )
	player.SetObserverTarget( null )
}

function RelicSpecificChatter( npc )
{
	Assert( GetMapName() == "mp_relic" )

	if ( !GamePlayingOrSuddenDeath() )
		return false

	if ( ( Time() - level.engineStartTime ) < AI_CHATTER_ENGINE_STARTUP_LENGTH )
		PlaySquadConversationToTeam( "relic_grunt_chatter_engine_starting", npc.GetTeam(), npc, AI_FRIENDLY_CHATTER_RANGE_SQR )
	else
		PlaySquadConversationToTeam( "relic_grunt_chatter", npc.GetTeam(), npc, AI_FRIENDLY_CHATTER_RANGE_SQR )
	return true //return false if we should not be doing chatter so we can fall through and do other chatter if needed
}

main()

