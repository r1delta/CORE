const FX_LIGHT_ORANGE 	= "runway_light_orange"
const FX_LIGHT_GREEN 	= "runway_light_green"
const FX_POD_LASER 		= "P_pod_scan_laser_FP"
const FX_POD_SCREEN_IN	= "P_pod_screen_lasers_IN"
const FX_POD_SCREEN_OUT	= "P_pod_screen_lasers_OUT"

PrecacheParticleSystem( FX_LIGHT_ORANGE )
PrecacheParticleSystem( FX_LIGHT_GREEN )
PrecacheParticleSystem( FX_POD_LASER )
PrecacheParticleSystem( FX_POD_SCREEN_IN )
PrecacheParticleSystem( FX_POD_SCREEN_OUT )

const CUSTOM_INTRO_LENGTH = 25.0
const DEV_DISABLE_INTRO = false

function main()
{
	if ( reloadingScripts )
		return

	FlagSet( "DogFights" ) // tells flightpath to bake these into the ain
	FlagSet( "StratonFlybys" )

	PrecacheEntity( "point_spotlight" )
	PrecacheEntity( "beam_spotlight" )

	// --- custom classic MP scripting after here ---
	if ( DEV_DISABLE_INTRO || !GetClassicMPMode() )
		return

	level.trainingPod <- null
	//level.cabinWindowShutters <- []
	level.trainingPodGlowLightRows <- []

	level.playersWatchingIntro <- []
	level.podAnim <- "none"
	level.podAnimStartTime <- -1
	level.POD_EYEPOS_OFFSET <- Vector( 0.000488, 0.000488, 70.000000 )

	RegisterSignal( "PodInteriorSequenceDone" )

	FlagInit( "TrainingPodSetupDone" )
	FlagInit( "IntroRunning" )

	AddSpawnCallback( "info_spawnpoint_dropship_start", OnDropshipStartSpawn )
	ClassicMP_SetIntroLevelSetupFunc( NPE_Intro_LevelSetupFunc )
	ClassicMP_SetIntroPlayerSpawnFunc( NPE_ClassicMPIntroSpawn )
	ClassicMP_SetPrematchSpawnPlayersFunc( NPE_PrematchSpawnPlayersFunc )

	AddCallback_GameStateEnter( eGameState.WaitingForPlayers, NPEIntroStart )  // This starts the main intro control thread
	AddCallback_GameStateEnter( eGameState.PickLoadout, NPE_GameStateEnterFunc_PickLoadout )
	AddCallback_GameStateEnter( eGameState.Prematch, NPE_GameStateEnterFunc_PrematchCallback )
}

function EntitiesDidLoad()
{
	NPE_KillUnusedEntities()
	NPE_CreateMiscEntities()
	NPE_CreateSpawnpoints()

	// Disable if you want the map to be more accurate to the normal training map
	NPE_CreateExtraCover_Visibility()
	NPE_CreateCollisionBlockers()

	if ( EvacEnabled() )
		NPE_EvacSetup()
}

function NPE_KillUnusedEntities()
{
	// Old spawnpoints are garbage
	local classEnts = [
		"info_spawnpoint_human_start",
		"info_spawnpoint_droppod_start"
	]

	foreach( entry in classEnts )
	{
		foreach ( ent in GetEntArrayByClass_Expensive( entry ) )
			ent.Destroy()
	}

	local wildcardEnts = [
		"trigger_lightswitch*",
		"module_advance_trigger*",
		"player_reset_trigger*",
		"trig_grenade_target*",
		"door_*"
		"walk_door*",
		"sprint_door*",
		"dest_*",
		"destination_*",
		"teleport_*",
		"grenadetrig_*",
		"script_marvin*",
		"training_goal*",
		"trig_*" // All triggers that start with trig_ are only used during training
	]

	foreach( entry in wildcardEnts )
	{
		foreach ( ent in GetEntArrayByNameWildCard_Expensive( entry ) )
			ent.Destroy()
	}
}

function NPE_CreateMiscEntities()
{
	// VDU support
	local vduCamera = CreateEntity( "info_target" )
	vduCamera.SetName( "vdu_camera_ref" )
	vduCamera.SetOrigin( Vector( -13560, -4768, 0 ) )
	vduCamera.SetAngles( Vector( 0, 90, 0 ) )
	vduCamera.kv.spawnflags = 2
	DispatchSpawn( vduCamera )

	local vduCharacter = CreateEntity( "info_target" )
	vduCharacter.SetName( "vdu_character_ref" )
	vduCharacter.SetOrigin( Vector( -13560, -4704, 0 ) )
	vduCharacter.SetAngles( Vector( 0, -90, 0 ) )
	vduCharacter.kv.spawnflags = 2
	DispatchSpawn( vduCharacter )

	local intermission = GetEnt( "info_intermission_1" )
	intermission.SetOrigin( Vector( -516.749, 3391.6, 6477.14 ) )
	intermission.SetAngles( Vector( -10.34, -50.511, 0 ) )
}

function NPE_CreateSpawnpoints()
{
	local NPE_GENERIC_PILOT_SPAWNSTART_MILITIA = [
		{ origin = Vector( -933.7, 3083.08, 6690 ), angles = Vector( 0, -31.4, 0 ) },
		{ origin = Vector( -1160.68, 2587.88, 6381.74 ), angles = Vector( 0, 22.7775, 0 ) },
		{ origin = Vector( -1021.23, 2901.74, 6676.28 ), angles = Vector( 0, 13.1723, 0 ) },
		{ origin = Vector( -865.209, 1910.66, 6398.24 ), angles = Vector( 0, 17.9835, 0 ) },
		{ origin = Vector( -840.113, 1286.18, 6381.7 ), angles = Vector( 0, 21.0287, 0 ) },
	]

	local NPE_GENERIC_PILOT_SPAWNSTART_IMC = [
		{ origin = Vector( 2686.27, 2080.35, 6362.1 ), angles = Vector( 0, 180, 0 ) },
		{ origin = Vector( 2570.01, 1688.59, 6363.81 ), angles = Vector( 0, 177.283, 0 ) },
		{ origin = Vector( 2667.33, 2351.91, 6358.56 ), angles = Vector( 0, 153.701, 0 ) },
		{ origin = Vector( 2308.22, 2263.35, 6400.03 ), angles = Vector( 0, -170.841, 0 ) },
		{ origin = Vector( 2247.77, 1876.35, 6400.03 ), angles = Vector( 0, 160.838, 0 ) },
	]

	local NPE_GENERIC_PILOT_SPAWN = [
		{ origin = Vector( -608.031, 2899.21, 6404.28 ), angles = Vector( 0, 128.475, 0 ) },
		{ origin = Vector( 856.031, 2591.05, 6408.03 ), angles = Vector( 0, -90.0571, 0 ) },
		{ origin = Vector( 713.389, 3239.02, 6408.03 ), angles = Vector( 0, 9.48885, 0 ) },
		{ origin = Vector( 725.241, 3657.07, 6408.03 ), angles = Vector( 0, -21.6411, 0 ) },
		{ origin = Vector( 2244.97, 2320.13, 6400.03 ), angles = Vector( 0, -136.343, 0 ) },
		{ origin = Vector( 866.776, 1695.97, 6680.03 ), angles = Vector( 0, 179.996, 0 ) },
	]

	local NPE_TITAN_SPAWNSTART_MILITIA = [
		{ origin = Vector( -1197.84, 2443.52, 6372.8 ), angles = Vector( 0, 4.15304, 0 ) },
		{ origin = Vector( -925.166, 2115.2, 6465.09 ), angles = Vector( 0, -44.1209, 0 ) },
		{ origin = Vector( -1090.61, 1579.68, 6393.48 ), angles = Vector( 0, 44.523, 0 ) },
		{ origin = Vector( -1344.9, 2085.31, 6368.4 ), angles = Vector( 0, 9.87305, 0 ) },
		{ origin = Vector( -1398.02, 2520.1, 6392.22 ), angles = Vector( 0, -63.1437, 0 ) },
		{ origin = Vector( -703.893, 2447.94, 6406.03 ), angles = Vector( 0, 37.4538, 0 ) },
	]

	local NPE_TITAN_SPAWNSTART_IMC = [
		{ origin = Vector( 2684.45, 1624.51, 6346.82 ), angles = Vector( 0, -137.667, 0 ) },
		{ origin = Vector( 2585.83, 1397.25, 6339.88 ), angles = Vector( 0, 149.508, 0 ) },
		{ origin = Vector( 2092.86, 1590.46, 6383.08 ), angles = Vector( 0, 168.026, 0 ) },
		{ origin = Vector( 2608.51, 2493.89, 6360.52 ), angles = Vector( 0, 163.68, 0 ) },
		{ origin = Vector( 2367.87, 2819.52, 6399.1 ), angles = Vector( 0, -159.474, 0 ) },
		{ origin = Vector( 2526.46, 3125.29, 6404.53 ), angles = Vector( 0, 143.308, 0 ) },
	]

	// MoshPit_PlayerMopsUpAsTitan
	local NPE_GENERIC_DROPPOD_SPAWN = [
		{ origin = Vector( -9.97231, 3632.03, 6366.88 ), angles = Vector( 0, -52.5624, 0 ) },
		{ origin = Vector( 956.635, 3451.81, 6544.03 ), angles = Vector( 0, -96.4783, 0 ) },
		{ origin = Vector( 1721.89, 2756.19, 6400.51 ), angles = Vector( 0, -159.951, 0 ) },
		{ origin = Vector( 2114.33, 1099, 6372.17 ), angles = Vector( 0, 121.815, 0 ) },
		{ origin = Vector( -431.435, 725.337, 6400.03 ), angles = Vector( 0, 28.3477, 0 ) },
	]

	local NPE_DROPPOD_SPAWN_MILITIA = [
		{ origin = Vector( -815.808, 2169.22, 6402.76 ), angles = Vector( 0, 25.6661, 0 ) },
		{ origin = Vector( -812.441, 2583.46, 6386.79 ), angles = Vector( 0, -10.2173, 0 ) },
		{ origin = Vector( -303.457, 2806.81, 6374.05 ), angles = Vector( 0, 4.96268, 0 ) },
		{ origin = Vector( -417.945, 921.758, 6380.8 ), angles = Vector( 0, 5.22797, 0 ) },
	]

	local NPE_DROPPOD_SPAWN_IMC = [
		{ origin = Vector( 2499.68, 934.154, 6346.28 ), angles = Vector( 0, -143.334, 0 ) },
		{ origin = Vector( 1978.2, 1442.35, 6377.95 ), angles = Vector( 0, 156.249, 0 ) },
		{ origin = Vector( 1972.18, 2928.39, 6397.63 ), angles = Vector( 0, 141.011, 0 ) },
		{ origin = Vector( 2112.81, 3324.86, 6408.69 ), angles = Vector( 0, -159.543, 0 ) },
	]

	local NPE_DROPSHIP_SPAWN_MILITIA = [
		{ origin = Vector( -1116.73, 2444.92, 6369.01 ), angles = Vector( 0, 20.4007, 0 ) },
		{ origin = Vector( -947.797, 1990.81, 6390.45 ), angles = Vector( 0, 21.8237, 0 ) },
	]

	local NPE_DROPSHIP_SPAWN_IMC = [
		{ origin = Vector( 2502.68, 1585.22, 6370.08 ), angles = Vector( 0, 151.737, 0 ) },
		{ origin = Vector( 2626.71, 2588.06, 6372.57 ), angles = Vector( 0, -134.298, 0 ) },
	]

	local NPE_FRONTLINES_IMC = [
		// frontline imc spawn
		{ origin = Vector( 1708.68, 2081.26, 6371.22 ), angles = Vector( 0, 180, 0 ), group = "spawn_imc" }
		{ origin = Vector( 1708.2, 3570.37, 6371.42 ), angles = Vector( 0, 180, 0 ), group = "spawn_imc" }
		{ origin = Vector( 1707.95, 581.339, 6388.61 ), angles = Vector( 0, 180, 0 ), group = "spawn_imc" }

		// frontline mid - imc side
		{ origin = Vector( 1108.68, 2081.26, 6404.03 ), angles = Vector( 0, 180, 0 ), group = "mid" }
		{ origin = Vector( 1108.2, 3570.37, 6371.42 ), angles = Vector( 0, 180, 0 ), group = "mid" }
		{ origin = Vector( 1107.95, 581.339, 6388.61 ), angles = Vector( 0, 180, 0 ), group = "mid" }

		// frontline militia spawn - imc side
		{ origin = Vector( 291.32, 2081.26, 6384.38 ), angles = Vector( 0, 180, 0 ), group = "spawn_militia" }
		{ origin = Vector( 291.32, 3581.26, 6400.28 ), angles = Vector( 0, 180, 0 ), group = "spawn_militia" }
		{ origin = Vector( 291.32, 581.26, 6384.6 ), angles = Vector( 0, 180, 0 ), group = "spawn_militia" }
	]

	local NPE_FRONTLINES_MILITIA = [
		// frontline militia spawn
		{ origin = Vector( -491.32, 2081.26, 6384.38 ), angles = Vector( 0, 0, 0 ), group = "spawn_militia" }
		{ origin = Vector( -491.32, 3581.26, 6400.28 ), angles = Vector( 0, 0, 0 ), group = "spawn_militia" }
		{ origin = Vector( -491.32, 581.26, 6384.6 ), angles = Vector( 0, 0, 0 ), group = "spawn_militia" }

		// frontline mid - militia side
		{ origin = Vector( 291.32, 2081.26, 6384.38 ), angles = Vector( 0, 0, 0 ), group = "mid" }
		{ origin = Vector( 291.32, 3581.26, 6400.28 ), angles = Vector( 0, 0, 0 ), group = "mid" }
		{ origin = Vector( 291.32, 581.26, 6384.6 ), angles = Vector( 0, 0, 0 ), group = "mid" }

		// frontline imc spawn - militia side
		{ origin = Vector( 1108.68, 2081.26, 6404.03 ), angles = Vector( 0, 0, 0 ), group = "spawn_imc" }
		{ origin = Vector( 1108.2, 3570.37, 6371.42 ), angles = Vector( 0, 0, 0 ), group = "spawn_imc" }
		{ origin = Vector( 1107.95, 581.339, 6388.61 ), angles = Vector( 0, 0, 0 ), group = "spawn_imc" }
	]

	switch( GameRules.GetGameMode() )
	{
		case CAPTURE_THE_FLAG:
		case CAPTURE_THE_FLAG_PRO:
		case SCAVENGER:
			CreateFlagSpawnPoint( Vector( 2304.18, 2080.34, 6400.03 ), Vector( 0, 180, 0 ), TEAM_IMC, "info_spawnpoint_flag_1" )
			CreateFlagSpawnPoint( Vector( -894.322, 3035.11, 6540.28 ), Vector( 0, 0, 0 ), TEAM_MILITIA, "info_spawnpoint_flag_2" )
			break

		case CAPTURE_POINT:
		case EXFILTRATION:
			// hardpoint b
			//Vector( 786.676, 1502.96, 6544.03 ), Vector( 0, 180, 0 )
			break

		default:
			break
	}

	// Generic pilot spawnpoints for the rest of gamemodes that might require them
	// At the moment, start spawns will also be spawns when you die, would this go wrong? absolutely (not (probably))
	CreatePilotStartSpawnPointFromArray( NPE_GENERIC_PILOT_SPAWNSTART_IMC, TEAM_IMC )
	CreatePilotStartSpawnPointFromArray( NPE_GENERIC_PILOT_SPAWNSTART_MILITIA, TEAM_MILITIA )
	CreatePilotSpawnPointFromArray( NPE_GENERIC_PILOT_SPAWN, TEAM_UNASSIGNED )

	CreateTitanPilotStartSpawnPointFromArray( NPE_TITAN_SPAWNSTART_MILITIA, TEAM_MILITIA )
	CreateTitanPilotSpawnPointFromArray( NPE_TITAN_SPAWNSTART_MILITIA, TEAM_UNASSIGNED )
	CreateTitanPilotStartSpawnPointFromArray( NPE_TITAN_SPAWNSTART_IMC, TEAM_IMC )
	CreateTitanPilotSpawnPointFromArray( NPE_TITAN_SPAWNSTART_IMC, TEAM_UNASSIGNED )

	CreateDropPodStartSpawnPointFromArray( NPE_DROPPOD_SPAWN_IMC, TEAM_IMC )
	CreateDropPodSpawnPointFromArray( NPE_DROPPOD_SPAWN_IMC, TEAM_IMC )
	CreateDropPodStartSpawnPointFromArray( NPE_DROPPOD_SPAWN_MILITIA, TEAM_MILITIA )
	CreateDropPodSpawnPointFromArray( NPE_DROPPOD_SPAWN_MILITIA, TEAM_MILITIA )
	CreateDropPodSpawnPointFromArray( NPE_GENERIC_DROPPOD_SPAWN, TEAM_UNASSIGNED )

	CreateDropShipStartSpawnPointFromArray( NPE_DROPSHIP_SPAWN_IMC, TEAM_IMC )
	CreateDropShipSpawnPointFromArray( NPE_DROPSHIP_SPAWN_IMC, TEAM_IMC )
	CreateDropShipStartSpawnPointFromArray( NPE_DROPSHIP_SPAWN_MILITIA, TEAM_MILITIA )
	CreateDropShipSpawnPointFromArray( NPE_DROPSHIP_SPAWN_MILITIA, TEAM_MILITIA )

	CreateInfoFrontlineFromArray( NPE_FRONTLINES_IMC, TEAM_IMC )
	CreateInfoFrontlineFromArray( NPE_FRONTLINES_MILITIA, TEAM_MILITIA )
}

function NPE_CreateExtraCover_Visibility()
{
/*
	local beamLength = 1500 // 120
	local beamWidth = 100 // 22

	// long thin beam of light
	local point_spotlight = CreateEntity( "point_spotlight" )
	point_spotlight.SetOrigin( Vector( -1055.97, 3183.97, 6404.28 + 16 ) )
	point_spotlight.SetAngles( Vector( 0, -0.00233459, 0 ) )
	point_spotlight.kv.spawnflags = 0
	point_spotlight.kv.renderamt = 255
	point_spotlight.kv.rendercolor = "200 200 200"
	point_spotlight.kv.rendermode = 5
	point_spotlight.kv.spotlightlength = beamLength
	point_spotlight.kv.spotlightwidth = beamWidth
	point_spotlight.kv.HDRColorScale = 0.25 // affects beam alpha, range from 0 to 1.0
	DispatchSpawn( point_spotlight, false )

	// the "source" of the beam
	local beam_spotlight = CreateEntity( "beam_spotlight" )
	beam_spotlight.SetOrigin( Vector( -1055.97, 3183.97, 6404.28 + 16 ) )
	beam_spotlight.SetAngles( Vector( 0, -0.00233459, 0 ) )
	beam_spotlight.kv.renderamt = 255
	beam_spotlight.kv.rendercolor = "200 200 200"
	point_spotlight.kv.rendermode = 5
	beam_spotlight.kv.spawnflags = 1
	beam_spotlight.kv.maxspeed = 100
	beam_spotlight.kv.spotlightlength = beamLength
	beam_spotlight.kv.spotlightwidth = beamWidth
	beam_spotlight.kv.HDRColorScale = 0.3
	DispatchSpawn( beam_spotlight, false )

	beam_spotlight.Fire( "LightOn" )
*/
}

function NPE_CreateCollisionBlockers()
{
	// Improve wallrun in the tunnel
	local tunnel1 = CreatePropDynamic( "models/door/bunker_door_open_96x120.mdl", Vector( 950.426, 3054.36, 6408.03 ), null, 6 )
	local tunnel2 = CreatePropDynamic( "models/door/bunker_door_open_96x120.mdl", Vector( 950.426, 2800.36, 6408.03 ), null, 6 )
	local tunnel3 = CreatePropDynamic( "models/door/bunker_door_open_96x120.mdl", Vector( 950.426, 2540.36, 6408.03 ), null, 6 )

	tunnel1.MakeInvisible()
	tunnel2.MakeInvisible()
	tunnel3.MakeInvisible()
}

// Cant spawn them from script, and they instantly crash the game when spawned via ent_create
/*
function NPE_CreateAIHints()
{
	local NPE_INFO_HINTS = [
		// Militia spawn
		{ origin = Vector( -1083.97, 3132.16, 6619.75 ), angles = Vector( 0, 90, 0 ), hotspot = "window2" }
		{ origin = Vector( -953.069, 2815.03, 6592.28 ), angles = Vector( 0, 30, 0 ), hotspot = "window2" }
		{ origin = Vector( -800.612, 3263.28, 6580.39 ), angles = Vector( 0, 90, 0 ), hotspot = "balcony" }
	]

	CreateInfoHintFromArray( NPE_INFO_HINTS )
}
*/

function NPE_EvacSetup()
{
	local verticalAnims = Evac_CreateAnimPackage( "dropship_VTOL_evac_start", "dropship_VTOL_evac_idle", "dropship_VTOL_evac_end" )

	local locationNode1 = CreateInfoTarget( Vector( -824.612, 2788.55, 6763.57 ), Vector( 0, 270, 0 ), "evac_location1" )
	local locationNode2 = CreateInfoTarget( Vector( 366.184, 1921.18, 6562.96 ), Vector( 0, 180, 0 ), "evac_location2" )
	local locationNode3 = CreateInfoTarget( Vector( 2486.27, 2080.35, 6662.1 ), Vector( 0, 0, 0 ), "evac_location3" )

	local spectatorNode1 = CreateInfoTarget( Vector( -45.7324, 3157.62, 7086.39 ), Vector( 0, -144.742, 0 ), "spec_cam1", locationNode1.GetName() )
	local spectatorNode2 = CreateInfoTarget( Vector( 103.202, 2380.25, 6855.07 ), Vector( 0, -58.8073, 0 ), "spec_cam2", locationNode2.GetName() )
	local spectatorNode3 = CreateInfoTarget( Vector( 2110.41, 2802.76, 6943.53 ), Vector( 0, -88.3968, 0 ), "spec_cam3", locationNode3.GetName() )

	Evac_AddLocation( "evac_location1", spectatorNode1.GetOrigin(), spectatorNode1.GetAngles() )
	Evac_AddLocation( "evac_location2", spectatorNode2.GetOrigin(), spectatorNode2.GetAngles(), verticalAnims )
	Evac_AddLocation( "evac_location3", spectatorNode3.GetOrigin(), spectatorNode3.GetAngles() )

	local spacenode = CreateInfoTarget( Vector( -11912.5, 3737.54, 2195.74 ), Vector( 0, 0, 0 ), "end_spacenode" )
	Evac_SetSpaceNode( spacenode )

	Evac_SetupDefaultVDUs()

	GM_SetObserverFunc( EvacObserverFunc )
}

function EvacObserverFunc( player )
{
	player.SetObserverModeStaticPosition( level.ExtractLocations[ level.SelectedExtractLocationIndex ].spectatorPos )
	player.SetObserverModeStaticAngles( level.ExtractLocations[ level.SelectedExtractLocationIndex ].spectatorAng )

	player.StartObserverMode( OBS_MODE_CHASE )
	player.SetObserverTarget( null )
}

//==============================
// 	Intro Setup
//==============================

function NPE_GameStateEnterFunc_PickLoadout()
{
	level.nv.minPickLoadOutTime = Time() + 0.5  // we only want to spend a little bit of time in this gamestate before moving to "Prematch" (Campaign = no time in this gamestate)
}

function NPE_GameStateEnterFunc_PrematchCallback()
{
	if ( ClassicMP_CanUseIntroStartSpawn() )
		SetCustomIntroLength( CUSTOM_INTRO_LENGTH )  // affects gamestate switch to "playing"
	else
	{
		foreach ( player in GetPlayerArray() )
			thread TeleportPlayerToRealStartSpawn_OnRestart( player )
	}
}

function TeleportPlayerToRealStartSpawn_OnRestart( player )
{
	player.EndSignal( "Disconnected" )

	// wait for player to be respawned
	while( !IsAlive( player ) )
		wait 0.1

	thread TeleportPlayerToRealStartSpawn( player )
}

// This is run from _gamestate::EntitiesDidLoad()
// search: level.classicMP_introLevelSetupFunc
function NPE_Intro_LevelSetupFunc()
{
	SetupTrainingPod()

	return true
}

// This is run when the server enters Prematch and wants to spawn all the connected clients as players.
function NPE_PrematchSpawnPlayersFunc( players )
{
	foreach ( player in players )
	{
		if ( !IsAlive( player ) )
			NPE_ClassicMPIntroSpawn( player )
	}
}

// This is run from DecideRespawnPlayer (can happen numerous different ways)
// search: level.classicMP_introPlayerSpawnFunc
function NPE_ClassicMPIntroSpawn( player )
{
	Assert( !IsAlive( player ) )
	Assert( ClassicMP_CanUseIntroStartSpawn() )

	thread PlayerWatchPodIntro( player )
	return true
}

function NPEIntroStart()
{
	thread NPEIntroMain()
}

function NPEIntroMain()
{
	//printt( "WargamesIntroMain: waiting for flag TrainingPodSetupDone" )
	FlagWait( "TrainingPodSetupDone" )
	//printt( "WargamesIntroMain: flag TrainingPodSetupDone is set, continuing intro" )

	local pod = level.trainingPod

	pod.RenderWithViewModels( true )

	// early connecting players start idling
	level.podAnim = "idle"

	OnThreadEnd(
		function() : ( pod )
		{
			if ( IsValid( pod ) )
			{
				pod.Anim_Stop()
				pod.RenderWithViewModels( false )

				thread TrainingPod_ResetLaserEmitterRotation( pod )
				thread TrainingPod_KillLasers( pod )
				TrainingPod_KillGlowFX( pod )
				TrainingPod_KillInteriorDLights( pod )

				FadeOutSoundOnEntity( pod, "Amb_NPE_Cabin_Intro", 0.1 )
			}

			if ( Flag( "ForceStartSpawn" ) )
				FlagClear( "ForceStartSpawn" )
		}
	)

	// "Prematch" state starts right after "waiting for players"
	while ( GetGameState() < eGameState.Prematch )
		wait 0

	EmitSoundOnEntity( pod, "Amb_NPE_Cabin_Intro" )

	FlagSet( "IntroRunning" )
	printt( "IntroRunning flag set" )

	local introStartTime = Time()

	level.podAnim = "idle"
	level.podAnimStartTime = Time()
	local podAnim_start = "trainingpod_doors_open_idle"
	local podSequence = CreateFirstPersonSequence()
	podSequence.blendTime 				= 0.0
	podSequence.thirdPersonAnimIdle 	= podAnim_start

	TrainingPod_TurnOnInteriorDLight( "console1", pod )
	TrainingPod_TurnOnInteriorDLight( "console2", pod )

	thread FirstPersonSequence( podSequence, pod )

	thread Intro_PlayersHearPodVO()

	Intro_PlayersStartFirstPersonSequence()

	wait 8  // time just standing there in the pod before it closes - if this changes, remember to change CUSTOM_INTRO_LENGTH accordingly

	level.podAnim = "closing"
	level.podAnimStartTime = Time()
	local podSequence = CreateFirstPersonSequence()
	podSequence.blendTime 				= 0.0
	podSequence.thirdPersonAnim 		= "trainingpod_doors_close"
	podSequence.thirdPersonAnimIdle 	= "trainingpod_doors_close_idle"

	thread TrainingPod_KillInteriorDLights_Delayed( pod, 2.65 )

	Intro_PlayersStartFirstPersonSequence()

	waitthread FirstPersonSequence( podSequence, pod )

	level.podAnim = "done"  // 1P catch-up anims won't try to start anymore when this is set

	wait 4.5  // time standing there in the pod after it closes - adjust CUSTOM_INTRO_LENGTH accordingly

	pod.RenderWithViewModels( false )  // hurts the look of the FX if it keeps rendering on the viewmodel plane at this point
	thread TrainingPod_Interior_BootSequence( pod )

	pod.WaitSignal( "PodInteriorSequenceDone" )

	// ------ POD INTRO DONE, NOW TELEPORT PLAYERS TO REAL START SPAWNS ------
	level.canStillSpawnIntoIntro = false  // setting this here also ensure that next round we won't spawn into the intro again

	foreach ( player in level.playersWatchingIntro )
		thread TeleportPlayerToRealStartSpawn( player )

	printt( "pod intro took", Time() - introStartTime, "secs" )

	printt( "IntroRunning flag cleared" )
	FlagClear( "IntroRunning" )

	thread StratonHornetDogfights()
}


function SetupTrainingPod()
{
	if ( Flag( "TrainingPodSetupDone" ) )
		return

	local arr = GetEntArrayByName_Expensive( "training_pod" )
	Assert( arr.len() == 1 )
	level.trainingPod = arr[ 0 ]
	level.trainingPod.s.laserEmitters <- []
	level.trainingPod.s.glowLightFXHandles <- []
	level.trainingPod.s.dLights <- []

	local pod = level.trainingPod

	TrainingPod_SetupInteriorDLights( pod )

	local laserAttachNames = [ "fx_laser_L", "fx_laser_R" ]

	foreach ( attachName in laserAttachNames )
	{
		local emitter = CreateScriptMover( pod )
		local attachID = pod.LookupAttachment( attachName )
		local attachAng = pod.GetAttachmentAngles( attachID )

		emitter.s.attachName <- attachName
		emitter.s.ogAng 	<- attachAng
		emitter.s.sweepDone <- false
		emitter.s.fxHandle 	<- null

		pod.s.laserEmitters.append( emitter )
	}

	// HACK we do this later as well to reset the emitter positions, so it's a separate function
	TrainingPod_SnapLaserEmittersToAttachPoints( pod )
	TrainingPod_GlowLightsArraySetup( pod )

	pod.SetAngles( Vector( 0, 109, 0 ) )  // these angles are a little better for seeing the room

	//thread TrainerStart()
	FlagSet( "TrainingPodSetupDone" )
}

function TrainingPod_Interior_BootSequence( pod )
{
	//level.player.EndSignal( "OnDestroy" )
	//level.player.EndSignal( "Disconnected" )
	//level.ent.EndSignal( "ModuleChanging" )
	pod.EndSignal( "OnDestroy" )

	TrainingPod_InteriorFX_CommonSetup( pod )

	EmitSoundToIntroPlayers( "NPE_Scr_SimPod_PowerUp" )

	// Transition screen FX
	//thread PlayFXOnEntity_Delayed( FX_POD_SCREEN_IN, level.player, 2.35 )
	thread TrainingPod_TransitionScreenFX( 2.25 )

	// GLOW LIGHTS
	local lightWait = 0.015
	local rowWait 	= 0.05
	TrainingPod_GlowLightsTurnOn( pod, lightWait, rowWait )

	local startTime = Time()
	local totalWait = 6  // be sure to change CUSTOM_INTRO_LENGTH accordingly if this changes
	local waitBeforeLasersStart = 0.5

	wait waitBeforeLasersStart

    // LASERS
    local longestSweepTime = -1
	foreach ( emitter in pod.s.laserEmitters )
	{
		//local sweepTime = RandomFloat( 2.9, 3.15 )
		local sweepTime = 3.0  // same timing for all players
		if ( sweepTime > longestSweepTime )
			longestSweepTime = sweepTime

		thread LaserSweep( sweepTime, emitter, pod, "top" )
	}

	local elapsedTime = Time() - startTime
	Assert( elapsedTime <= totalWait )
	wait ( totalWait - elapsedTime )

	FadeOutSoundOnIntroPlayers( "NPE_Scr_SimPod_PowerUp", 1.0 )

    pod.Signal( "PodInteriorSequenceDone" )
}

function TrainingPod_TransitionScreenFX( delayTime = 0, doForced = false )
{
	if ( delayTime > 0 )
		wait delayTime

	local players = level.playersWatchingIntro

	if ( !level.playersWatchingIntro.len() && !doForced )
	{
		printt( "Skipping training pod transition screen FX because no players are connected." )
		return
	}

	if ( !level.playersWatchingIntro.len() )
		players = GetPlayerArray()

	// find someone to play the effect on
	local fxPlayer = null
	foreach ( player in players )
	{
		if ( IsAlive( player ) )
		{
			fxPlayer = player
			break
		}
	}

	if ( !fxPlayer )
		return

	// Transition screen FX
	// - NOTE, this shows on all client screens when it happens
	// - NOTE: when played on client it doesn't show up
	//
	// HACK HACK HACK this makes it happen on all players - can we ship that?
	PlayFXOnEntity( FX_POD_SCREEN_IN, fxPlayer )
}

// NOTE startPosition is actually inverted from what I think it should be. Tag orientation issue, maybe?
function LaserSweep( totalTime, emitter, pod, startPosition = "bottom" )
{
	//local startTime = Time()

	//level.player.EndSignal( "OnDestroy" )
	//level.player.EndSignal( "Disconnected" )
	emitter.EndSignal( "OnDeath" )
	//level.ent.EndSignal( "ModuleChanging" )

	emitter.s.sweepDone = false

	//printt( "emitter og angles:", emitter.GetAngles() )

	if ( !level.playersWatchingIntro.len() )
	{
		printt( "LaserSweep not starting because no players are watching the intro. (Needs an eye position to start from.)" )
		return
	}

	// the position where players' eyes will be during the anim (relative to the pod)
	local playerEyePos = pod.GetOrigin() + level.POD_EYEPOS_OFFSET

	local vecToPlayerEye = playerEyePos - emitter.GetOrigin()  // eye position offset is a HACK, not sure why I need to do that here.
	local centerAng = VectorToAngles( vecToPlayerEye )
	local topAng = centerAng + Vector( 90, 0, 0 )
	local bottomAng = centerAng + Vector( -90, 0, 0 )

	//local topAng 	= emitter.GetAngles() + Vector( 90, -8, 0 )
	//local bottomAng = emitter.GetAngles() + Vector( -90, 8, 0 )

	//printt( "==== starting at:", startPosition )
	//printt( "topAng:", topAng )
	//printt( "bottomAng:", bottomAng )
	//printt( "centerAng:", centerAng )

	local lastBigSweepAng

	if ( startPosition == "bottom")
	{
		emitter.SetAbsAngles( bottomAng )
		lastBigSweepAng = bottomAng
	}
	else
	{
		emitter.SetAbsAngles( topAng )
		lastBigSweepAng = topAng
	}
	//printt( "setting start angles to:", lastBigSweepAng )

	local fxHandle = PlayLoopFXOnEntity( FX_POD_LASER, emitter )
	emitter.s.fxHandle = fxHandle

	local numBigSweeps = 2
	local finalCenterTime = totalTime * 0.15
	local bigSweepTime = ( totalTime - finalCenterTime ) / numBigSweeps

	local bigSweep_AccelTime = 0
	local bigSweep_DecelTime = bigSweepTime * 0.2

	// do the big sweeps
	local nextBigSweepAng
	for ( local i = 0; i < numBigSweeps; i++ )
	{
		nextBigSweepAng = topAng
		if ( lastBigSweepAng == topAng )
			nextBigSweepAng = bottomAng

		//printt( "rotating to", nextBigSweepAng )

		emitter.RotateTo( nextBigSweepAng, bigSweepTime, bigSweep_AccelTime, bigSweep_DecelTime )

		local waitTime = bigSweepTime
		if ( i < numBigSweeps - 1 )
			waitTime = bigSweepTime - 0.1

		wait waitTime

		lastBigSweepAng = nextBigSweepAng
	}

	// finish with centering move
	//printt( "centering to", centerAng )

	local finalCenter_AccelTime = 0
	local finalCenter_DecelTime = finalCenterTime * 0.2

	emitter.RotateTo( centerAng, finalCenterTime, finalCenter_AccelTime, finalCenter_DecelTime )
	wait finalCenterTime

	emitter.s.sweepDone = true
	//printt( "laser sweep done, total time", Time() - startTime, "should have been", totalTime )
}

function PlayerWatchPodIntro( player )
{
	player.EndSignal( "Disconnected" )
	player.EndSignal( "OnDeath" )

	local pod = level.trainingPod

	AddCinematicFlag( player, CE_FLAG_INTRO )

	level.playersWatchingIntro.append( player )

	OnThreadEnd(
		function() : ( player )
		{
			if ( IsValid( player ) )
			{
				//printt( "PlayerWatchPodIntro: clearing up player:", player )

				ArrayRemove( level.playersWatchingIntro, player )

				player.Anim_Stop()
				player.ClearAnimViewEntity()
				player.ClearParent()
				player.UnforceStand()
				player.EnableWeaponViewModel()
				player.kv.VisibilityFlags = 7  // All can see now that intro is over

				FadeOutSoundOnEntity( player, "Amb_Wargames_Pod_Ambience", 0.13 )

				// turns hud back on
				if ( HasCinematicFlag( player, CE_FLAG_INTRO ) )
					RemoveCinematicFlag( player, CE_FLAG_INTRO )
			}
		}
	)

	// FIRST SPAWN
	local pilotDataTable = GetPlayerClassDataTable( player, level.pilotClass )
	local pilotSettings = pilotDataTable.playerSetFile
	player.SetPlayerSettings( pilotSettings )
	player.SetPlayerPilotSettings( pilotSettings )

	// Have to do this first so the anim starts centered on the ref attachment angles
	local attachID = pod.LookupAttachment( "REF" )
	local podRefOrg = pod.GetAttachmentOrigin( attachID )
	local podRefAng = pod.GetAttachmentAngles( attachID )
	player.SetOrigin( podRefOrg )
	player.SetAngles( podRefAng )
	player.RespawnPlayer( null )

	player.kv.VisibilityFlags = 1 // visible to player only, so others don't see his viewmodel during the anim
	player.DisableWeaponViewModel()
	player.ForceStand()

	// HACK player height matches fine in NPE
	//player.SetOrigin( podRefOrg + Vector( 0, 0, 3 ) )
	// explicitly set parent here (if no parent set, FirstPersonSequence sets it with no offset)
	player.SetParent( pod, "REF", true, 0 )

	printt( "New player spawned!", player, "IsEntAlive?", player.IsEntAlive() )

	EmitSoundOnEntityOnlyToPlayer( player, player, "Amb_Wargames_Pod_Ambience" )

	if ( Flag( "IntroRunning" ) )
	{
		printt( "PlayerWatchPodIntro: Intro already started, jumping into sequence late.", player )
		thread Intro_StartPlayerFirstPersonSequence( player )
	}
	// player connected before pod anim started
	else
	{
		thread Intro_StartPlayerFirstPersonSequence( player )

		printt( "PlayerWatchPodIntro: Intro not started, waiting for IntroRunning to be set.", player )
		FlagWait( "IntroRunning" )
	}

	player.UnfreezeControlsOnServer()  // let him look around the pod

	// IMPORTANT this keeps them here until the end of the sequence, then they are cleaned up in OnThreadEnd
	FlagWaitClear( "IntroRunning" )

	printt( "PlayerWatchPodIntro: intro finished normally for player", player )
}

function Intro_StartPlayerFirstPersonSequence( player )
{
	player.EndSignal( "Disconnected" )
	player.EndSignal( "OnDeath" )

	local pod = level.trainingPod
	Assert( level.podAnim != "none" )

	local viewConeFunction = null  // sometimes, can't use playerSequence.viewConeFunction
	local postAnim_viewConeLockFunc = null

	local playerSequence = CreateFirstPersonSequence()
	playerSequence.blendTime 			= 0.0
	playerSequence.attachment 			= "REF"
	playerSequence.renderWithViewModels = true

	// TEMP for testing
	/*
	if ( gp().len() > 0 && player == gp()[0] )
	{
		// don't show player 1 FP model
		printt( "hiding 1P proxy model for player", player )
		playerSequence.hideProxy = true
	}
	*/

	printt( "1P sequence matching level.podAnim:", level.podAnim, "for player", player )

	if ( level.podAnim == "idle" || level.podAnim == "done" )
	{
		playerSequence.firstPersonAnimIdle 	= "ptpov_trainingpod_idle"

		viewConeFunction 	= TrainingPod_ViewConeLock_PodOpen  // can't use playerSequence.viewConeFunction here because it needs 1st person non-idle anims in the sequence setup
		postAnim_viewConeLockFunc = TrainingPod_ViewConeLock_PodOpen

		if ( level.podAnim == "done" )
		{
			printt( "PlayerWatchPodIntro: jumped in after intro view anims all done. Using idle anim for default positioning.", player )
			viewConeFunction 	= TrainingPod_ViewConeLock_PodClosed
			postAnim_viewConeLockFunc = TrainingPod_ViewConeLock_PodClosed
		}

	}
	if ( level.podAnim == "closing" )
	{
		playerSequence.firstPersonAnim 		= "ptpov_trainingpod_doors_close"
		playerSequence.firstPersonAnimIdle 	= "ptpov_trainingpod_idle"
		//playerSequence.thirdPersonAnim 		= "pt_trainingpod_doors_close"
		//playerSequence.thirdPersonAnimIdle 	= "pt_trainingpod_idle"

		viewConeFunction 	= TrainingPod_ViewConeLock_SemiStrict
		postAnim_viewConeLockFunc = TrainingPod_ViewConeLock_PodClosed
	}

	// if not a looping idle, get duration and skip forward if necessary
	local duration = null
	local animEntryTime = 0
	if ( playerSequence.firstPersonAnim )
	{
		local viewmodel = player.GetFirstPersonProxy()
		local duration = viewmodel.GetSequenceDuration( playerSequence.firstPersonAnim )

		if ( Time() > level.podAnimStartTime )
		{
			animEntryTime = Time() - level.podAnimStartTime
			printt( "1P non-looping animated sequence skipping ahead by", animEntryTime, "secs ( normal duration:", duration, ")" )
			playerSequence.setInitialTime = animEntryTime
		}
	}

	// run the sequence
	thread FirstPersonSequence( playerSequence, player, pod )

	if ( viewConeFunction )
	{
		// HACK known issue - after starting anim, need to wait before setting view cone
		thread SetViewCone_Delayed( player, viewConeFunction )
	}

	// if the anim is a one-shot, wait to be over
	if ( duration )
	{
		wait duration

		if ( postAnim_viewConeLockFunc )
		{
			printt( "running post-anim viewConeFunction:", viewConeFunction.getinfos().name, "on", player )
			postAnim_viewConeLockFunc( player )
		}
	}
}

function SetViewCone_Delayed( player, viewConeFunction )
{
	player.EndSignal( "Disconnected" )

	local tryWait = 0.5  // HACK, not sure what else to wait on. waiting 0.1 isn't long enough.
	wait tryWait

	//printt( "HACK! Starting viewConeFunction", viewConeFunction.getinfos().name, tryWait, "secs after anim started on", player )
	viewConeFunction( player )
}

function Intro_PlayersHearPodVO()
{
	wait 1  // initial delay

	// This unit is authorized for: military use only.
	EmitSoundToIntroPlayers( "diag_npeLevelmsg_pickup_01" )

	wait 3.2  // line time

	// extra time
	wait 1

	// Possession by an individual is a Class One felony.
	EmitSoundToIntroPlayers( "diag_npeLevelmsg_pickup_02" )
	wait 3.2

	// Welcome back to Pilot certification.
	EmitSoundToIntroPlayers( "diag_tut_npeLevel_NP274_01_01_neut_tutai" )
	wait 3

	thread PlayPodGamemodeVoicelines( false )
}
Globalize( Intro_PlayersHearPodVO )

main()