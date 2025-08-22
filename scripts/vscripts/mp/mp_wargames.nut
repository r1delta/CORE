const TRAINING_POD 		= "models/weapons/training_pod/training_pod.mdl"
PrecacheModel( TRAINING_POD )

const POD_ATTACHPOINT  	= "REF"

const FX_LIGHT_ORANGE 	= "runway_light_orange"
const FX_LIGHT_GREEN 	= "runway_light_green"
const FX_POD_LASER 		= "P_pod_scan_laser_FP"
const FX_POD_GLOWLIGHT 	= "P_pod_door_glow_FP"
const FX_POD_SCREEN_IN	= "P_pod_screen_lasers_IN"
const FX_POD_SCREEN_OUT	= "P_pod_screen_lasers_OUT"
const FX_POD_DLIGHT_CONSOLE1 		= "P_pod_Dlight_console1"
const FX_POD_DLIGHT_CONSOLE2 		= "P_pod_Dlight_console2"
const FX_POD_DLIGHT_BACKLIGHT_SIDE 	= "P_pod_Dlight_backlight_side"
const FX_POD_DLIGHT_BACKLIGHT_TOP 	= "P_pod_Dlight_backlight_top"
const FX_TITAN_COCKPIT_LIGHT 		= "xo_cockpit_dlight"

PrecacheParticleSystem( FX_LIGHT_ORANGE )
PrecacheParticleSystem( FX_LIGHT_GREEN )
PrecacheParticleSystem( FX_POD_LASER )
PrecacheParticleSystem( FX_POD_GLOWLIGHT )
PrecacheParticleSystem( FX_POD_SCREEN_IN )
PrecacheParticleSystem( FX_POD_SCREEN_OUT )
PrecacheParticleSystem( FX_POD_DLIGHT_CONSOLE1 )
PrecacheParticleSystem( FX_POD_DLIGHT_CONSOLE2 )
PrecacheParticleSystem( FX_POD_DLIGHT_BACKLIGHT_SIDE )
PrecacheParticleSystem( FX_POD_DLIGHT_BACKLIGHT_TOP )
PrecacheParticleSystem( FX_TITAN_COCKPIT_LIGHT )

const OGRE_STATIC_MODEL = "models/titans/ogre/OgrePoseOpen.mdl"
PrecacheModel( OGRE_STATIC_MODEL )

PrecacheModel( BLISK_MODEL )
PrecacheModel( SPYGLASS_MODEL )
PrecacheModel( TEAM_IMC_GRUNT_MDL )
PrecacheModel( TEAM_IMC_CAPTAIN_MDL )
PrecacheModel( SARAH_MODEL )
PrecacheModel( BISH_MODEL )
PrecacheModel( TEAM_MILITIA_GRUNT_MDL )
PrecacheModel( TEAM_MILITIA_CAPTAIN_MDL )
PrecacheModel( MARVIN_MODEL )
PrecacheModel( SEARCH_DRONE_MODEL )

const CUSTOM_INTRO_LENGTH = 25.0

// RESET AFTER TESTING
const DEV_TEST 						= false
// these only work if dev_test is set
const DEV_CUSTOM_CONNECTWAIT 		= true
const DEV_CUSTOM_CONNECTWAIT_SECS 	= 1
const DEV_DISABLE_NPCS 				= true
const DEV_PRINT_GAMESTATE_CHANGES 	= false

function main()
{
	if ( EvacEnabled() )
		FlagSet( "CinematicOutro" )

	if ( reloadingScripts )
		return

	AddDeathCallback( "npc_soldier", Wargames_GroundTroopsDeathCallback )
	AddDeathCallback( "npc_spectre", Wargames_GroundTroopsDeathCallback )
	AddDeathCallback( "npc_marvin", Wargames_GroundTroopsDeathCallback )
	AddDeathCallback( "player", Wargames_GroundTroopsDeathCallback )

	FlagSet( "DogFights" ) // tells flightpath to bake these into the ain
	FlagSet( "StratonFlybys" )

	RegisterSignal( "EndSearchDronesThink" )
	AddCallback_GameStateEnter( eGameState.Postmatch, StopSearchDrones )

	if ( GAMETYPE != COOPERATIVE )  // competes vs cloak drones in this mode
		thread StartSearchDrones()

	AddTitanfallBlocker( Vector( 383, -85, -2700 ), 800, 2000 )
	AddTitanfallBlocker( Vector( -3140, 1621, 300 ), 236, 500 )

	// --- custom classic MP scripting after here ---
	if ( !GetClassicMPMode() )
		return

	level.pods <- {}
	level.pods[ TEAM_IMC ] <- null
	level.pods[ TEAM_MILITIA ] <- null
	level.playersWatchingIntro <- []
	level.podAnim <- "none"
	level.podAnimStartTime <- -1
	level.POD_EYEPOS_OFFSET <- Vector( 0.000488, 0.000488, 70.000000 )

	RegisterSignal( "PodInteriorSequenceDone" )

	FlagInit( "TrainingPodSetupDone" )
	FlagInit( "IntroRunning" )

	AddSpawnCallback( "info_spawnpoint_dropship_start", OnDropshipStartSpawn )
	ClassicMP_SetIntroLevelSetupFunc( Wargames_Intro_LevelSetupFunc )
	ClassicMP_SetIntroPlayerSpawnFunc( Wargames_ClassicMPIntroSpawn )
	ClassicMP_SetPrematchSpawnPlayersFunc( Wargames_PrematchSpawnPlayersFunc )

	AddCallback_GameStateEnter( eGameState.WaitingForPlayers, WargamesIntroStart )  // This starts the main intro control thread
	AddCallback_GameStateEnter( eGameState.PickLoadout, Wargames_GameStateEnterFunc_PickLoadout )
	AddCallback_GameStateEnter( eGameState.Prematch, Wargames_GameStateEnterFunc_PrematchCallback )

	if ( DEV_TEST && DEV_PRINT_GAMESTATE_CHANGES )
		thread PrintGameStateChanges()
}

function Wargames_GameStateEnterFunc_PickLoadout()
{
	level.nv.minPickLoadOutTime = Time() + 0.5  // we only want to spend a little bit of time in this gamestate before moving to "Prematch" (Campaign = no time in this gamestate)
}

function Wargames_GameStateEnterFunc_PrematchCallback()
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

function EntitiesDidLoad()
{
	// if we ever want to do custom win announcements for this level (teacher AI or whatever), clear this flag
	//FlagClear( "AnnounceWinnerEnabled" )

	if ( DEV_TEST && DEV_DISABLE_NPCS )
		disable_npcs()

	if ( EvacEnabled() )
		Wargames_EvacSetup()
}


// ============ SKITS ============
function IntroSkits_Militia()
{
	local floorZ = -1412

	// guys looking at console in back corner
	local guy1 = SpawnSkitGuy( "console_lean", "pt_bored_interface_leanin", Vector( -2125, 3070, floorZ ), Vector( 0, -122, 0 ), TEAM_MILITIA, TEAM_MILITIA_GRUNT_MDL )
	local guy2 = SpawnSkitGuy( "console_supervisor", "pt_bored_interface_leanback", Vector( -2160, 3052, floorZ ), Vector( 0, -132, 0 ), TEAM_MILITIA, TEAM_MILITIA_GRUNT_MDL, "mp_weapon_shotgun" )
	SkitGuy_PlayAnim( guy1 )
	SkitGuy_PlayAnim( guy2 )

	// titan repair scene
	// static ogre
	local solidtype = 0  // no collision
	local staticOgre = CreatePropDynamic( OGRE_STATIC_MODEL, Vector( -2060, 2856, -1412.5 ), Vector( 0, 0, 0 ), solidtype )
	AddSkitGuy_Manually( "static_ogre", staticOgre )

	local marvin1 = SpawnSkitGuy( "marvin_weld", "mv_idle_weld", Vector( -2113, 2911, floorZ ), Vector( 0, -20, 0 ) )
	local marvin2 = SpawnSkitGuy( "marvin_weld2", "mv_idle_weld", Vector( -2040, 2788, floorZ ), Vector( 0, 140, 0 ) )
	SkitGuy_PlayAnim( marvin1 )
	SkitGuy_PlayAnim( marvin2, 3.0 )  // don't play same anim at same time

	local marvin3 = SpawnSkitGuy( "marvin_hanging", "mv_turret_repair_A_idle", Vector( -2116, 2868, -1458 ), Vector( 0, 127, 0 ) )
	SkitGuy_PlayAnim( marvin3 )

	local marvin4 = SpawnSkitGuy( "marvin_nearpod", "mv_idle_unarmed", Vector( -1786, 3060, floorZ ), Vector( 0, -120, 0 ) )
	SkitGuy_PlayAnim( marvin4 )

	// guys walking around
	thread IntroSkit_Militia_WalkingGuys()

	// titan bootup sequence
	thread IntroSkit_Militia_TitanBoot()
}

function IntroSkit_Militia_WalkingGuys()
{
	// far side near garage doors
	local path1 = []
	//path1.append( { origin = Vector( -1624.03, 2560.03, -1411.97 ), angles = Vector( 0, -179.997, 0 ) } )
	//path1.append( { origin = Vector( -1878.95, 2630.55, -1411.97 ), angles = Vector( 0, 164.58, 0 ) } )
	path1.append( { origin = Vector( -1990.31, 2621.2, -1411.97 ), angles = Vector( 0, -149.982, 0 ) } )
	path1.append( { origin = Vector( -2146.52, 2632.35, -1411.97 ), angles = Vector( 0, 179.65, 0 ) } )
	path1.append( { origin = Vector( -2186.87, 2770.55, -1411.97 ), angles = Vector( 0, 106.28, 0 ) } )
	local guy1 = SpawnSkitGuy( "mcor_walking_1", "", Vector( 0, 0, 0 ), Vector( 0, 0, 0 ), TEAM_MILITIA, TEAM_MILITIA_ROCKET_GRUNT_MDL, "mp_weapon_rspn101" )
	thread WalkPath( guy1, path1, 0.65, "pt_bored_idle_console_B" )

	// closer to pod near garage doors
	local path2 = []
	path2.append( { origin = Vector( -1666.76, 2783.05, -1411.97 ), angles = Vector( 0, -99.3093, 0 ) } )
	path2.append( { origin = Vector( -1740.53, 2648.25, -1416.49 ), angles = Vector( 0, -146.609, 0 ) } )
	path2.append( { origin = Vector( -1895.36, 2662.65, -1411.97 ), angles = Vector( 0, 172.801, 0 ) } )
	path2.append( { origin = Vector( -1957.57, 2737.42, -1411.97 ), angles = Vector( 0, 129.571, 0 ) } )
	path2.append( { origin = Vector( -1955.59, 2936.74, -1411.97 ), angles = Vector( 0, 89.7508, 0 ) } )
	local guy2 = SpawnSkitGuy( "mcor_walking_2", "", Vector( 0, 0, 0 ), Vector( 0, 0, 0 ), TEAM_MILITIA, TEAM_MILITIA_GRUNT_MDL, "mp_weapon_hemlok" )
	thread WalkPath( guy2, path2 )

	// walking through the middle of the garage
	local path3 = []
	//path3.append( { origin = Vector( -1951.84, 2708.57, -1411.97 ), angles = Vector( 0, 87.97, 0 ) } )
	path3.append( { origin = Vector( -1971.6, 2805.99, -1411.97 ), angles = Vector( 0, 86.4531, 0 ) } )
	path3.append( { origin = Vector( -1953.49, 2945.83, -1411.97 ), angles = Vector( 0, 164.61, 0 ) } )
	path3.append( { origin = Vector( -2048.39, 3030, -1411.97 ), angles = Vector( 0, 147.89, 0 ) } )
	local guy3 = SpawnSkitGuy( "mcor_walking_3", "", Vector( 0, 0, 0 ), Vector( 0, 0, 0 ), TEAM_MILITIA, TEAM_MILITIA_CAPTAIN_MDL, "mp_weapon_rspn101" )
	thread WalkPath( guy3, path3, 0.75, "pt_bored_idle_console_B" )

	// outside garage doors, walking right to left
	local path4 = []
	path4.append( { origin = Vector( -2065.2, 2504.03, -1411.97 ), angles = Vector( 0, -1.81964, 0 ) } )
	path4.append( { origin = Vector( -1915.45, 2515.81, -1411.97 ), angles = Vector( 0, -2.58969, 0 ) } )
	path4.append( { origin = Vector( -1694.83, 2512.52, -1411.97 ), angles = Vector( 0, 1.04034, 0 ) } )
	local guy4 = SpawnSkitGuy( "mcor_walking_4", "", Vector( 0, 0, 0 ), Vector( 0, 0, 0 ), TEAM_MILITIA, TEAM_MILITIA_ROCKET_GRUNT_MDL, "mp_weapon_sniper" )
	thread WalkPath( guy4, path4, 0.7 )

	local path5 = []
	path5.append( { origin = Vector( -2100.51, 2506.29, -1411.97 ), angles = Vector( 0, -22.0397, 0 ) } )
	path5.append( { origin = Vector( -1915.45, 2515.81, -1411.97 ), angles = Vector( 0, -2.58969, 0 ) } )
	path5.append( { origin = Vector( -1694.83, 2512.52, -1411.97 ), angles = Vector( 0, 1.04034, 0 ) } )
	local guy5 = SpawnSkitGuy( "mcor_walking_5", "", Vector( 0, 0, 0 ), Vector( 0, 0, 0 ), TEAM_MILITIA, TEAM_MILITIA_CAPTAIN_MDL, "mp_weapon_sniper" )
	thread WalkPath( guy5, path5, 0.7 )
}

function IntroSkit_Militia_TitanBoot()
{
	local refOrg = Vector( -1809.98, 2790.39, -1409 )
	local refAng = Vector( 0, 80, 0 )
	local animref = CreateScriptRef( refOrg, refAng )

	local table 	= CreateDefaultNPCTitanTemplate( TEAM_MILITIA )
	table.origin 	= refOrg
	table.angles 	= refAng
	local titan = SpawnNPCTitan( table )
	titan.DisableStarts()
	AddSkitGuy_Manually( "bootup_titan", titan )

	AddAnimEvent( titan, "hatch_closed", IntroSkit_MilitiaTitan_HatchClosed )

	local cockpitLightFX = PlayFXOnEntity( FX_TITAN_COCKPIT_LIGHT, titan, "HIJACK" )

	local titanPilot = SpawnSkitGuy( "titanPilot", "", Vector( 0, 0, 0 ), Vector( 0, 0, 0 ), TEAM_MILITIA, TEAM_MILITIA_CAPTAIN_MDL )
	local bish = SpawnSkitGuy( "bish", "", Vector( 0, 0, 0 ), Vector( 0, 0, 0 ), TEAM_MILITIA, BISH_MODEL )
	//titanPilot.SetTitle( "Cpt. Slayback" )
	//bish.SetTitle( "Bish" )

	local pilotAnim = "pt_titan_activation_pilot"
	local titanAnim = "at_titan_activation_wargames_intro"
	local crewAnim 	= "pt_titan_activation_crew"
	local animSkipTime = 4.0

	titanPilot.SetParent( titan, "HIJACK", false, 0.0 )
	titanPilot.MarkAsNonMovingAttachment()
	titanPilot.Anim_ScriptedPlay( pilotAnim )
	titanPilot.Anim_EnableUseAnimatedRefAttachmentInsteadOfRootMotion()

	OnThreadEnd(
		function() : ( titanPilot, bish, titan, cockpitLightFX, animref )
		{
			if ( IsAlive( titanPilot ) )
				DeleteSkitGuy( "titanPilot" )

			if ( IsAlive( bish ) )
				DeleteSkitGuy( "bish" )

			if ( IsValid_ThisFrame( cockpitLightFX ) )
			{
				cockpitLightFX.Fire( "Stop" )
				cockpitLightFX.ClearParent()
				cockpitLightFX.Destroy()
			}

			if ( IsAlive( titan ) )
			{
				StopSoundOnEntity( titan, "Wargames_MCOR_TitanActivate" )
				DeleteSkitGuy( "bootup_titan" )
			}

			if ( IsValid( animref ) )
				animref.Kill()
		}
	)

	EmitSoundOnEntity( titan, "Wargames_MCOR_TitanActivate" )

	thread PlayAnim( bish, crewAnim, animref, null, DEFAULT_SCRIPTED_ANIMATION_BLEND_TIME, animSkipTime )
	thread PlayAnim( titan, titanAnim, animref, null, DEFAULT_SCRIPTED_ANIMATION_BLEND_TIME, animSkipTime )

	// end it early so he doesn't make stomping sounds when the pod is closed
	wait 15.0
	printt( "Ending titan crew boot anim" )
}

function IntroSkit_MilitiaTitan_HatchClosed( titan )
{
	DeleteSkitGuy( "titanPilot" )
}

function IntroSkits_IMC()
{
	local floorZ = -1786

	local guy1 = SpawnSkitGuy( "console_sitting", "pt_console_idle", Vector( -2915, 2867, -1788 ), Vector( 0, -137, 0 ), TEAM_IMC, TEAM_IMC_GRUNT_MDL )
	local guy2 = SpawnSkitGuy( "console_sitting_2", "pt_console_idle", Vector( -2870, 2746, -1786 ), Vector( 0, -167, 0 ), TEAM_IMC, TEAM_IMC_GRUNT_MDL )
	local guy3 = SpawnSkitGuy( "console_sitting_3", "pt_console_idle", Vector( -3200, 3017, -1794 ), Vector( 0, 118, 0 ), TEAM_IMC, TEAM_IMC_GRUNT_MDL )
	local guy4 = SpawnSkitGuy( "console_sitting_4", "pt_console_idle", Vector( -3281, 2941, -1790 ), Vector( 0, 138, 0 ), TEAM_IMC, TEAM_IMC_GRUNT_MDL )
	SkitGuy_PlayAnim( guy1 )
	SkitGuy_PlayAnim( guy2, 2.0 )
	SkitGuy_PlayAnim( guy3, 4.0 )
	SkitGuy_PlayAnim( guy4, 6.0 )

	local guy5 = SpawnSkitGuy( "console_standing", "pt_bored_interface_leanin", Vector( -3293, 2909, -1788 ), Vector( 0, -64, 0 ), TEAM_IMC, TEAM_IMC_CAPTAIN_MDL, "mp_weapon_car" )
	SkitGuy_PlayAnim( guy5 )

	local blisk = SpawnSkitGuy( "blisk", "pt_bored_interface_leanback", Vector( -2710, 2938, floorZ ), Vector( 0, -147, 0 ), TEAM_IMC, BLISK_MODEL, "mp_weapon_wingman" )
	SkitGuy_PlayAnim( blisk, 4.5 )  // start with some motion
	//blisk.SetTitle( "Cpt. Blisk" )

	local spyglass = SpawnSkitGuy( "spyglass", "pt_console_idle", Vector( -3037, 2909, -1786 ), Vector( 0, -60, 0 ), TEAM_IMC, SPYGLASS_MODEL )
	SkitGuy_PlayAnim( spyglass, 4.5 )
	//spyglass.SetTitle( "Spyglass" )

	thread IntroSkit_IMC_WalkingGuys()

	wait 1.5
	thread IntroSkit_IMC_SearchDrone()
}

function IntroSkit_IMC_WalkingGuys()
{
	// walking right to left in front of pod past heroes
	local path1 = []
	path1.append( { origin = Vector( -2895.33, 2956.34, -1784 ), angles = Vector( 0, -41.7502, 0 ) } )
	path1.append( { origin = Vector( -2797.34, 2839.85, -1784 ), angles = Vector( 0, -56.2701, 0 ) } )
	path1.append( { origin = Vector( -2774.61, 2683.44, -1786.06 ), angles = Vector( 0, -104.34, 0 ) } )
	path1.append( { origin = Vector( -2786.48, 2610.94, -1787.97 ), angles = Vector( 0, -109.29, 0 ) } )
	local guy1 = SpawnSkitGuy( "imc_walking_1", "", Vector( 0, 0, 0 ), Vector( 0, 0, 0 ), TEAM_IMC, TEAM_IMC_GRUNT_MDL, "mp_weapon_hemlok" )
	thread WalkPath( guy1, path1, 0.95 )

	// walking right side toward pod
	local path2 = []
	path2.append( { origin = Vector( -3150.06, 2928.16, -1785 ), angles = Vector( 0, 13.2199, 0 ) } )
	path2.append( { origin = Vector( -3070.74, 2968.58, -1785 ), angles = Vector( 0, 74.4037, 0 ) } )
	path2.append( { origin = Vector( -3029.33, 3135.87, -1783.97 ), angles = Vector( 0, 84.9015, 0 ) } )
	local guy2 = SpawnSkitGuy( "imc_walking_2", "", Vector( 0, 0, 0 ), Vector( 0, 0, 0 ), TEAM_IMC, TEAM_IMC_GRUNT_MDL, "mp_weapon_rspn101" )
	thread WalkPath( guy2, path2, 1.0 )

	// walking left to right in front of pod past heroes
	local path4 = []
	path4.append( { origin = Vector( -2613.05, 2733.49, -1783.97 ), angles = Vector( 0, 147.09, 0 ) } )
	path4.append( { origin = Vector( -2755.79, 2848.58, -1786.59 ), angles = Vector( 0, 142.47, 0 ) } )
	path4.append( { origin = Vector( -2939.95, 2962.15, -1785 ), angles = Vector( 0, 168.54, 0 ) } )
	path4.append( { origin = Vector( -3007.01, 3109.32, -1787.97 ), angles = Vector( 0, 112.55, 0 ) } )
	local guy4 = SpawnSkitGuy( "imc_walking_4", "", Vector( 0, 0, 0 ), Vector( 0, 0, 0 ), TEAM_IMC, TEAM_IMC_GRUNT_MDL, "mp_weapon_rspn101" )
	thread WalkPath( guy4, path4, 1.1 )

	wait 1

	// walking right side away from pod
	local path3 = []
	path3.append( { origin = Vector( -2951.05, 3123.97, -1784.98 ), angles = Vector( 0, -165.783, 0 ) } )
	path3.append( { origin = Vector( -2992.06, 3020.75, -1787.97 ), angles = Vector( 0, -113.648, 0 ) } )
	path3.append( { origin = Vector( -3076.69, 2976.41, -1785 ), angles = Vector( 0, -147.198, 0 ) } )
	path3.append( { origin = Vector( -3186.92, 2899.53, -1785 ), angles = Vector( 0, -145.108, 0 ) } )
	path3.append( { origin = Vector( -3253.93, 2805.77, -1785 ), angles = Vector( 0, -106.168, 0 ) } )
	local guy3 = SpawnSkitGuy( "imc_walking_3", "", Vector( 0, 0, 0 ), Vector( 0, 0, 0 ), TEAM_IMC, TEAM_IMC_GRUNT_MDL, "mp_weapon_autopistol" )
	thread WalkPath( guy3, path3, 1.0 )
}

function IntroSkit_IMC_SearchDrone()
{
	if ( level.activeSearchDrones.len() )
	{
		foreach ( drone in level.activeSearchDrones )
			if ( IsValid( drone ) )
				drone.Destroy()

		level.activeSearchDrones = []
	}

	local node = GetNodeByUniqueID( "cinematic_mp_node_us0" )
	NodeDoMoment( node )
}

function WalkPath( guy, path, walkSpeedScale = 0.8, idleAnim = null )
{
	guy.EndSignal( "OnDeath" )

	guy.DisableStarts()
	guy.SetMoveSpeedScale( walkSpeedScale )
	guy.SetMoveAnim( "patrol_walk_bored" )

	local waitSignal = "OnEnterAssaultTolerance" //"OnFinishedAssault"
	local pathfindingFailTimeout = 20

	OnThreadEnd(
		function() : ( guy )
		{
			if ( IsAlive( guy ) )
				DeleteSkitGuy( guy.s.skitGuyName )
		}
	)

	foreach ( idx, pathpoint in path )
	{
		if ( idx == 0 )
		{
			guy.SetOrigin( pathpoint.origin )
			guy.SetAngles( pathpoint.angles )
		}

		local goalradius = 36 //STANDARDGOALRADIUS
		guy.DisableArrivalOnce( true )  // always want arrivals disabled because they are blended from run anim, not walking

		local assaultEnt = CreateStrictAssaultEnt( pathpoint.origin, pathpoint.angles, goalradius )
		guy.AssaultPointEnt( assaultEnt )

		local result = WaitSignalTimeout( guy, pathfindingFailTimeout, waitSignal )
		if ( result == null || result.signal != waitSignal )
		{
			printt( guy, "'s scripted walk pathfinding stopped, quitting." )
			break
		}
	}

	if ( idleAnim )
	{
		local lastpath = path[ path.len() - 1 ]
		local ref = CreateScriptMover( guy, lastpath.origin, lastpath.angles )

		PlayAnim( guy, idleAnim, ref, null, 0.4 )
	}
}

function AddSkitGuy_Manually( name, guy )
{
	if ( !( "skitguys" in level ) )
		level.skitguys <- {}

	if ( name in level.skitguys )
		DeleteSkitGuy( name )
	else
		level.skitguys[ name ] <- null

	level.skitguys[ name ] = guy
}

function SpawnSkitGuy( name, anim, origin, angles, team = TEAM_IMC, model = TEAM_IMC_GRUNT_MDL, weapon = "mp_weapon_semipistol" )
{
	if ( !( "skitguys" in level ) )
		level.skitguys <- {}

	if ( name in level.skitguys )
		DeleteSkitGuy( name )
	else
		level.skitguys[ name ] <- null

	local guyType = "grunt"
	if ( StringContains( name, "marvin" ) )
		guyType = "marvin"

	// spawn the guy
	local guy = null
	if ( guyType == "marvin" )
	{
		guy = CreateEntity( "npc_marvin" )
		guy.kv.additionalequipment = "Nothing"
		guy.SetModel( MARVIN_MODEL )

		DispatchSpawn( guy, true )

		guy.SetTeam( TEAM_SPECTATOR )
		guy.SetMoveSpeedScale( 0.6 )

		TakeAllJobs( guy )
	}
	else
	{
		guy = CreateGrunt( team, model, weapon )
		DispatchSpawn( guy, true )
	}

	guy.SetTitle( "" )

	local ref = CreateScriptMover( guy, origin, angles )
	ref.SetOrigin( origin )
	ref.SetAngles( angles )
	guy.s.skitRef <- ref

	guy.SetOrigin( ref.GetOrigin() )
	guy.SetAngles( ref.GetAngles() )
	guy.StayPut( true )

	MakeInvincible( guy )
	guy.SetEfficientMode( true )
	guy.AllowHandSignals( false )
	guy.AllowFlee( false )

	guy.s.skitAnim <- anim
	guy.s.skitGuyName <- name

	level.skitguys[ name ] = guy

	return guy
}

function PrintSkitGuy( name )
{
	local guy = level.skitguys[ name ]

	if ( "skitRef" in guy.s )
		print( name + " ref origin: " + guy.s.skitRef.GetOrigin() + " | angles: " + guy.s.skitRef.GetAngles() )
	else
		print( name + " origin: " + guy.GetOrigin() + " | angles: " + guy.GetAngles() )
}

function PlaceSkitGuy( name )
{
	local org = GetPlayerArray()[0].GetOrigin()
	local ang = GetPlayerArray()[0].GetAngles()
	ang = Vector( 0, ang.y, 0 )

	local guy = level.skitguys[ name ]
	guy.s.skitRef.SetOrigin( org )
	guy.s.skitRef.SetAngles( ang )
	SkitGuy_PlayAnim( guy )

	PrintSkitGuy( name )
}

function NudgeSkitGuy( name, offsetX, offsetY = 0, offsetZ = 0 )
{
	if ( !( name in level.skitguys ) )
	{
		printt( "WARNING NAME NOT RECOGNIZED:", name )
		return
	}

	local guy = level.skitguys[ name ]

	local offset = Vector( offsetX, offsetY, offsetZ )

	if ( "skitRef" in guy.s )
		guy.s.skitRef.SetOrigin( guy.s.skitRef.GetOrigin() + offset )
	else
		guy.SetOrigin( guy.GetOrigin() + offset )

	if ( "skitAnim" in guy.s )
		SkitGuy_PlayAnim( guy )

	printt( "NUDGED:")
	PrintSkitGuy( name )
}

function TweakSkitGuy( name, offsetY )
{
	if ( !( name in level.skitguys ) )
	{
		printt( "WARNING NAME NOT RECOGNIZED:", name )
		return
	}

	local addAngles = Vector( 0, offsetY, 0 )

	local guy = level.skitguys[ name ]

	if ( "skitRef" in guy.s )
		guy.s.skitRef.SetAngles( guy.s.skitRef.GetAngles() + addAngles )
	else
		guy.SetAngles( guy.GetAngles() + addAngles )

	if ( "skitAnim" in guy.s )
		SkitGuy_PlayAnim( guy )

	printt( "TWEAKED:")
	PrintSkitGuy( name )
}

function SkitGuy_PlayAnim( guy, skipAheadTime = null )
{
	Assert( guy.s.skitAnim )
	Assert( guy.s.skitRef )

	thread PlayAnim( guy, guy.s.skitAnim, guy.s.skitRef, null, 0.0, skipAheadTime )
}

function DeleteAllSkitGuys()
{
	local names = []
	foreach ( name, guy in level.skitguys )
		names.append( name )

	foreach ( name in names )
		DeleteSkitGuy( name )
}

function DeleteSkitGuy( name )
{
	if ( !( name in level.skitguys ) )
	{
		printt( "WARNING tried to clear a skit slot that was already clear, name:", name )
		return
	}

	KillSkitGuy( name )

	level.skitguys[ name ] = null
}

function KillSkitGuy( name )
{
	Assert( ( name in level.skitguys ), "couldn't find index in level.skitguys: " + name )

	local guy = level.skitguys[ name ]

	if ( IsAlive( guy ) )
	{
		if ( "skitRef" in guy.s && IsValid( guy.s.skitRef ) )
		{
			guy.s.skitRef.Kill()
		}

		guy.Anim_Stop()
		ClearInvincible( guy )
		guy.Kill()
	}
	else if ( IsValid( guy ) )
	{
		guy.Destroy()
	}
}
// ============ END SKITS ============

// This is run when the server enters Prematch and wants to spawn all the connected clients as players.
function Wargames_PrematchSpawnPlayersFunc( players )
{
	foreach ( player in players )
	{
		if ( !IsAlive( player ) )
			Wargames_ClassicMPIntroSpawn( player )
	}
}

// This is run from DecideRespawnPlayer (can happen numerous different ways)
// search: level.classicMP_introPlayerSpawnFunc
function Wargames_ClassicMPIntroSpawn( player )
{
	Assert( !IsAlive( player ) )
	Assert( ClassicMP_CanUseIntroStartSpawn() )

	thread PlayerWatchPodIntro( player )
	return true
}

// This is run from _gamestate::EntitiesDidLoad()
// search: level.classicMP_introLevelSetupFunc
function Wargames_Intro_LevelSetupFunc()
{
	SetupTrainingPods()

	return true
}


function WargamesIntroStart()
{
	thread WargamesIntroMain()
}

function WargamesIntroMain()
{
	//printt( "WargamesIntroMain: waiting for flag TrainingPodSetupDone" )
	FlagWait( "TrainingPodSetupDone" )
	//printt( "WargamesIntroMain: flag TrainingPodSetupDone is set, continuing intro" )

	foreach ( pod in level.pods )
		pod.RenderWithViewModels( true )  // can't use podSequence.renderWithViewModels because the pod doesn't have a 1P anim in its sequence setup

	// early connecting players start idling
	level.podAnim = "idle"

	foreach ( pod in level.pods )
	{
		local ambienceLoud = "Wargames_Emit_IMC_Intro_HighPass"
		local ambienceQuiet = "Wargames_Emit_IMC_Intro_LowPass"

		if ( pod.s.teamIdx == TEAM_MILITIA )
		{
			ambienceLoud = "Wargames_Emit_MCOR_Intro_HighPass"
			ambienceQuiet = "Wargames_Emit_MCOR_Intro_LowPass"
		}

		pod.s.ambienceLoud <- ambienceLoud
		pod.s.ambienceQuiet <- ambienceQuiet
	}

	OnThreadEnd(
		function() : ()
		{
			if ( IsValid( level.pods  ) )
			{
				foreach ( pod in level.pods )
				{
					if ( IsValid( pod ) )
					{
						pod.Anim_Stop()
						pod.RenderWithViewModels( false )

						thread TrainingPod_ResetLaserEmitterRotation( pod )
						thread TrainingPod_KillLasers( pod )
						TrainingPod_KillGlowFX( pod )
						TrainingPod_KillInteriorDLights( pod )

						FadeOutSoundOnEntity( pod, pod.s.ambienceLoud, 0.1 )
						FadeOutSoundOnEntity( pod, pod.s.ambienceQuiet, 0.1 )
					}
				}
			}

			if ( Flag( "ForceStartSpawn" ) )
				FlagClear( "ForceStartSpawn" )
		}
	)

	// "Prematch" state starts right after "waiting for players"
	while ( GetGameState() < eGameState.Prematch )
		wait 0

	foreach ( pod in level.pods )
	{
		printt( "starting intro ambient audio" )
		EmitSoundOnEntity( pod, pod.s.ambienceLoud )
		EmitSoundOnEntity( pod, pod.s.ambienceQuiet )
	}

	thread IntroSkits_Militia()
	thread IntroSkits_IMC()

	FlagSet( "IntroRunning" )
	printt( "IntroRunning flag set" )

	local introStartTime = Time()

	level.podAnim = "idle"
	level.podAnimStartTime = Time()
	local podAnim_start = "trainingpod_doors_open_idle"
	local podSequence = CreateFirstPersonSequence()
	podSequence.blendTime 				= 0.0
	podSequence.thirdPersonAnimIdle 	= podAnim_start

	foreach ( pod in level.pods )
	{
		TrainingPod_TurnOnInteriorDLight( "console1", pod )
		TrainingPod_TurnOnInteriorDLight( "console2", pod )

		thread FirstPersonSequence( podSequence, pod )
	}

	thread Intro_PlayersHearPodVO()

	Intro_PlayersStartFirstPersonSequence()

	wait 8  // time just standing there in the pod before it closes - if this changes, remember to change CUSTOM_INTRO_LENGTH accordingly

	level.podAnim = "closing"
	level.podAnimStartTime = Time()
	local podSequence = CreateFirstPersonSequence()
	podSequence.blendTime 				= 0.0
	podSequence.thirdPersonAnim 		= "trainingpod_doors_close"
	podSequence.thirdPersonAnimIdle 	= "trainingpod_doors_close_idle"

	foreach ( pod in level.pods )
		thread TrainingPod_KillInteriorDLights_Delayed( pod, 2.65 )

	Intro_PlayersStartFirstPersonSequence()

	thread FirstPersonSequence( podSequence, level.pods[ TEAM_IMC ] )
	waitthread FirstPersonSequence( podSequence, level.pods[ TEAM_MILITIA ] )

	level.podAnim = "done"  // 1P catch-up anims won't try to start anymore when this is set

	// fade out the higher volume ambience
	printt( "pod doors closed- fading out ambience loud")
	foreach ( pod in level.pods )
		FadeOutSoundOnEntity( pod, pod.s.ambienceLoud, 0.1 )

	wait 4.5  // time standing there in the pod after it closes - adjust CUSTOM_INTRO_LENGTH accordingly

	foreach ( pod in level.pods )
	{
		pod.RenderWithViewModels( false )  // hurts the look of the FX if it keeps rendering on the viewmodel plane at this point
		thread TrainingPod_Interior_BootSequence( pod )
	}

	level.pods[ TEAM_MILITIA ].WaitSignal( "PodInteriorSequenceDone" )

	// ------ POD INTRO DONE, NOW TELEPORT PLAYERS TO REAL START SPAWNS ------
	level.canStillSpawnIntoIntro = false  // setting this here also ensure that next round we won't spawn into the intro again

	foreach ( player in level.playersWatchingIntro )
		thread TeleportPlayerToRealStartSpawn( player )

	//printt( "pod intro took", Time() - introStartTime, "secs" )

	printt( "IntroRunning flag cleared" )
	FlagClear( "IntroRunning" )

	DeleteAllSkitGuys()

	thread StratonHornetDogfights()
}

function SetupTrainingPods()
{
	if ( Flag( "TrainingPodSetupDone" ) )
		return

	local arr = GetEntArrayByName_Expensive( "training_pod" )
	Assert( arr.len() == 1 )
	level.pods[ TEAM_MILITIA ] = arr[0]
	level.pods[ TEAM_MILITIA ].s.teamIdx <- TEAM_MILITIA

	local arr = GetEntArrayByName_Expensive( "training_pod_imc" )
	Assert( arr.len() == 1 )
	level.pods[ TEAM_IMC ] = arr[0]
	level.pods[ TEAM_IMC ].s.teamIdx <- TEAM_IMC

	foreach ( pod in level.pods )
	{
		pod.s.laserEmitters <- []
		pod.s.glowLightFXHandles <- []
		pod.s.dLights <- []
		pod.s.trainingPodGlowLightRows <- []

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
	}

	FlagSet( "TrainingPodSetupDone" )
}

function TrainingPod_SetupInteriorDLights( pod )
{
	local map = []
    map.append( { scriptAlias = "console1", 		fxName = FX_POD_DLIGHT_CONSOLE1, 		attachName = "light_console1" } )
    map.append( { scriptAlias = "console2", 		fxName = FX_POD_DLIGHT_CONSOLE2, 		attachName = "light_console2" } )
    map.append( { scriptAlias = "backlight_side_L", fxName = FX_POD_DLIGHT_BACKLIGHT_SIDE, 	attachName = "light_back1" } )
    map.append( { scriptAlias = "backlight_side_R", fxName = FX_POD_DLIGHT_BACKLIGHT_SIDE, 	attachName = "light_back2" } )
    map.append( { scriptAlias = "backlight_top", 	fxName = FX_POD_DLIGHT_BACKLIGHT_TOP, 	attachName = "light_backtop" } )
    pod.s.dLightMappings <- map
}

function TrainingPod_TurnOnInteriorDLight( scriptAlias, pod )
{
	local fxName
	local attachName
	foreach ( mapping in pod.s.dLightMappings )
	{
		if ( mapping.scriptAlias == scriptAlias )
		{
			fxName = mapping.fxName
			attachName = mapping.attachName
			break
		}
	}

	Assert( fxName && attachName )

	local fxHandle = PlayLoopFXOnEntity( fxName, pod, attachName )
	pod.s.dLights.append( fxHandle )
}

function TrainingPod_KillInteriorDLights_Delayed( pod, delay )
{
	pod.EndSignal( "OnDestroy" )

	wait delay

	TrainingPod_KillInteriorDLights( pod )
}

function TrainingPod_KillInteriorDLights( pod )
{
	foreach ( fxHandle in pod.s.dLights )
	{
		if ( !IsValid_ThisFrame( fxHandle ) )
			continue

		KillFX( fxHandle )
	}

	pod.s.dLights = []
}

function TrainingPod_SnapLaserEmittersToAttachPoints( pod )
{
	foreach ( emitter in pod.s.laserEmitters )
	{
		local attachID = pod.LookupAttachment( emitter.s.attachName )
		local attachOrg = pod.GetAttachmentOrigin( attachID )
		local attachAng = pod.GetAttachmentAngles( attachID )

		emitter.ClearParent()
		emitter.SetOrigin( attachOrg )  // HACK set this to ANYTHING  (even 0, 0, 0) and the position is correct, otherwise it's offset from the attachpoint when parented
		emitter.SetParent( pod, emitter.s.attachName )
	}
}

function TrainingPod_Interior_BootSequence( pod )
{
	pod.EndSignal( "OnDestroy" )

	TrainingPod_InteriorFX_CommonSetup( pod )

	EmitSoundOnlyToIntroPlayers( "NPE_Scr_SimPod_PowerUp", pod.s.teamIdx )

	thread TrainingPod_TransitionScreenFX( 2.25 )

	// GLOW LIGHTS
	local lightWait = 0.015
	local rowWait 	= 0.05
	thread TrainingPod_GlowLightsTurnOn( pod, lightWait, rowWait )

	local startTime = Time()
	local totalWait = 6  // be sure to change CUSTOM_INTRO_LENGTH accordingly if this changes
	local waitBeforeLasersStart = 2

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
	emitter.EndSignal( "OnDeath" )

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

function TrainingPod_GlowLightsTurnOn( pod, lightWait, rowWait )
{
	//local startTime = Time()

	// light up one light on each side at a time
	foreach ( row in pod.s.trainingPodGlowLightRows )
	{
		local loopTime = Time()

		// assume both sides have same number of lights
		local numLights = row[ 0 ].len()

		for ( local i = 0; i < numLights; i++ )
		{
			foreach ( side in row )
			{
				local attachName = side[ i ]
				local fxHandle = PlayLoopFXOnEntity( FX_POD_GLOWLIGHT, pod, attachName )
				pod.s.glowLightFXHandles.append( fxHandle )
			}

			if ( lightWait > 0 )
				wait lightWait
		}

		if ( rowWait > 0)
			wait rowWait
	}

	//printt( "glow lights turn on took", Time() - startTime, "secs" )
}

function TrainingPod_InteriorFX_CommonSetup( pod )
{
	if ( pod.s.laserEmitters.len() )
	{
		TrainingPod_KillLasers( pod )
		TrainingPod_ResetLaserEmitterRotation( pod )
	}

	TrainingPod_KillGlowFX( pod )
}

function TrainingPod_KillLasers( pod, doEndCap = false )
{
	foreach ( emitter in pod.s.laserEmitters )
	{
		if ( IsValid_ThisFrame( emitter.s.fxHandle ) )
		{
			if ( !doEndCap )
			{
				//printt( "killing laser FX", emitter.s.fxHandle )
				KillFX( emitter.s.fxHandle )
			}
			else
			{
				//printt( "killing laser FX with endcap", emitter.s.fxHandle )
				KillFXWithEndcap( emitter.s.fxHandle )
			}
		}

		emitter.s.fxHandle = null
	}
}

function TrainingPod_ResetLaserEmitterRotation( pod )
{
	if ( !( "laserEmitters" in pod.s ) )
		return

	foreach ( emitter in pod.s.laserEmitters )
	{
		//reset to start position
		emitter.RotateTo( emitter.s.ogAng, 0.05 )
	}
}

function TrainingPod_KillGlowFX( pod )
{
	foreach ( fxHandle in pod.s.glowLightFXHandles )
	{
		if ( !IsValid_ThisFrame( fxHandle ) )
			continue

		KillFX( fxHandle )
	}

	pod.s.glowLightFXHandles = []
}

function TrainingPod_GlowLightsArraySetup( pod )
{
	local rows = []
	// rows are set up bottom to top
	// lights are set up outside to in (in = door close seam; opposite for each side)
	// process two rows per loop (one for each door side)
	local row = []
	row.append( [ "fx_glow_L_door012", "fx_glow_L_door013" ] )
	row.append( [ "fx_glow_R_door014", "fx_glow_R_door013" ] )
	rows.append( row )

	local row = []
	row.append( [ "fx_glow_L_door014", "fx_glow_L_door011" ] )
	row.append( [ "fx_glow_R_door012", "fx_glow_R_door011" ] )
	rows.append( row )

	local row = []
	row.append( [ "fx_glow_L_door09", "fx_glow_L_door010" ] )
	row.append( [ "fx_glow_R_door09", "fx_glow_R_door010" ] )
	rows.append( row )

	local row = []
	row.append( [ "fx_glow_L_door07", "fx_glow_L_door08" ] )
	row.append( [ "fx_glow_R_door07", "fx_glow_R_door08" ] )
	rows.append( row )

	local row = []
	row.append( [ "fx_glow_L_door05", "fx_glow_L_door06" ] )
	row.append( [ "fx_glow_R_door05", "fx_glow_R_door06" ] )
	rows.append( row )

	local row = []
	row.append( [ "fx_glow_L_door03", "fx_glow_L_door04" ] )
	row.append( [ "fx_glow_R_door03", "fx_glow_R_door04" ] )
	rows.append( row )

	local row = []
	row.append( [ "fx_glow_L_door01", "fx_glow_L_door02" ] )
	row.append( [ "fx_glow_R_door01", "fx_glow_R_door02" ] )
	rows.append( row )

	pod.s.trainingPodGlowLightRows = rows
}

function PlayerWatchPodIntro( player )
{
	player.EndSignal( "Disconnected" )
	player.EndSignal( "OnDeath" )

	local playerTeam = player.GetTeam()
	Assert( playerTeam == TEAM_IMC || playerTeam == TEAM_MILITIA, "Expecting players to have a team by now!" )
	local teamAlias = playerTeam == TEAM_IMC ? "imc" : "militia"

	local pod = level.pods[ playerTeam ]
	Assert( pod, "couldn't find pod for player team " + player.GetTeam() )

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
	local attachID = pod.LookupAttachment( POD_ATTACHPOINT )
	local podRefOrg = pod.GetAttachmentOrigin( attachID )
	local podRefAng = pod.GetAttachmentAngles( attachID )
	player.SetOrigin( podRefOrg )
	player.SetAngles( podRefAng )
	player.RespawnPlayer( null )

	player.kv.VisibilityFlags = 1 // visible to player only, so others don't see his viewmodel during the anim
	player.DisableWeaponViewModel()
	player.ForceStand()

	// HACK player height matches fine in NPE
	player.SetOrigin( podRefOrg + Vector( 0, 0, 3 ) )
	// explicitly set parent here (if no parent set, FirstPersonSequence sets it with no offset)
	player.SetParent( pod, POD_ATTACHPOINT, true, 0 )

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

function Intro_PlayersHearPodVO()
{
	wait 1  // initial delay

	// This unit is authorized for: military use only.
	EmitSoundToIntroPlayers( "diag_npeLevelmsg_pickup_01" )

	wait 5.0

	// "Signal decryption handshake is unstable. You may experience visual artifacts."
	EmitSoundToIntroPlayers( "diag_dlc1_WG101_01_01_neut_tutai" )

	wait 5.5

	foreach ( player in level.playersWatchingIntro )
	{
		local genIdx = player.GetGen()
		//printt( "$$$$ Player", player, "genIdx:", genIdx )

		// GetGen 1 = gen 2
		// GetGen 9 = gen 10

		if ( genIdx > 0 && genIdx <= 9 )
		{
			local gen = genIdx + 1
			Assert( gen >= 2 && gen <= 10 )  // make sure we have an alias to play
			// "Gen [x] Pilot on deck." (w variants)
			local genAlias = "diag_dlc1_WG_pilot_onboard_gen" + gen
			EmitSoundAtPositionOnlyToPlayer( player.GetOrigin(), player, genAlias )
		}
		else
		{
			// "Welcome back."
			EmitSoundAtPositionOnlyToPlayer( player.GetOrigin(), player, "diag_dlc1_WG129_01_01_neut_tutai" )
		}
	}

	wait 2.75

	EmitSoundToIntroPlayers( "diag_dlc1_WG_pod_getready" )

	wait 2.4

	local modeAliases = {}
	modeAliases[ ATTRITION ] 					<- "diag_dlc1_WG136_01_01_neut_tutai"  // "Attrition."
	modeAliases[ TEAM_DEATHMATCH ] 				<- "diag_dlc1_WG137_01_01_neut_tutai"  // "Pilot Hunter."
	modeAliases[ SCAVENGER ] 					<- "diag_dlc1_WG137_01_01_neut_tutai"
	modeAliases[ CAPTURE_POINT ] 				<- "diag_dlc1_WG138_01_01_neut_tutai"  // "Hardpoint Domination."
	modeAliases[ LAST_TITAN_STANDING ] 			<- "diag_dlc1_WG139_01_01_neut_tutai"  // "Last Titan Standing."
	modeAliases[ "lts_ffa" ]		 			<- "diag_dlc1_WG139_01_01_neut_tutai"  // "Last Titan Standing."
	modeAliases[ WINGMAN_LAST_TITAN_STANDING ] 	<- "diag_dlc1_WG142_01_01_neut_tutai"  // "Wingman Last Titan Standing."
	modeAliases[ CAPTURE_THE_FLAG ] 			<- "diag_dlc1_WG140_01_01_neut_tutai"  // "Capture The Flag."
	modeAliases[ CAPTURE_THE_FLAG_PRO ] 		<- "diag_dlc1_WG140_01_01_neut_tutai"
	modeAliases[ PILOT_SKIRMISH ] 				<- "diag_dlc1_WG232_01_01_neut_tutai"
	modeAliases[ MARKED_FOR_DEATH ] 			<- "diag_dlc1_WG236_01_01_neut_tutai"
	modeAliases[ MARKED_FOR_DEATH_PRO ] 		<- "diag_dlc1_WG237_01_01_neut_tutai"
	modeAliases[ TITAN_BRAWL ] 					<- "diag_dlc1_WG137_01_01_neut_tutai"
	modeAliases[ TITAN_MFD ] 					<- "diag_dlc1_WG236_01_01_neut_tutai"
	modeAliases[ TITAN_MFD_PRO ] 					<- "diag_dlc1_WG237_01_01_neut_tutai"

	// make sure we have VO for the game mode
	local mode = GameRules.GetGameMode()
	if ( !( mode in modeAliases ) )
	{
		printt( "Couldn't find alias VO for gamemode", mode,", finishing training pod VO early." )
		return
	}

	// "Simulation mode is:"
	EmitSoundToIntroPlayers( "diag_dlc1_WG135_01_01_neut_tutai" )

	wait 1.5

	EmitSoundToIntroPlayers( modeAliases[ mode ] )
}

function EmitSoundOnIntroPods( alias )
{
	foreach ( pod in level.pods )
		EmitSoundOnEntity( pod, alias )
}

function EmitSoundToIntroPlayers( alias )
{
	foreach ( player in level.playersWatchingIntro )
		if ( IsValid( player ) )
			EmitSoundAtPositionOnlyToPlayer( player.GetOrigin(), player, alias )
}

function EmitSoundOnlyToIntroPlayers( alias, team = null )
{
	foreach ( player in level.playersWatchingIntro )
	{
		if ( !IsValid( player ) )
			continue

		if ( team && player.GetTeam() != team )
			continue

		printt( "Emitting sound on player", player )
		EmitSoundOnEntityOnlyToPlayer( player, player, alias )
	}
}

function FadeOutSoundOnIntroPlayers( alias, fadeTime )
{
	foreach ( player in level.playersWatchingIntro )
		if ( IsValid( player ) )
			FadeOutSoundOnEntity( player, alias, fadeTime )
}

function Intro_PlayersStartFirstPersonSequence()
{
	foreach ( player in level.playersWatchingIntro )
		thread Intro_StartPlayerFirstPersonSequence( player )
}

function Intro_StartPlayerFirstPersonSequence( player )
{
	player.EndSignal( "Disconnected" )
	player.EndSignal( "OnDeath" )

	local pod = level.pods[ player.GetTeam() ]
	Assert( pod, "couldn't find pod for player team " + player.GetTeam() )
	Assert( level.podAnim != "none" )

	local viewConeFunction = null  // sometimes, can't use playerSequence.viewConeFunction
	local postAnim_viewConeLockFunc = null

	local playerSequence = CreateFirstPersonSequence()
	playerSequence.blendTime 			= 0.0
	playerSequence.attachment 			= POD_ATTACHPOINT
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

function TeleportPlayerToRealStartSpawn( player )
{
	player.EndSignal( "Disconnected" )

	if ( IsRoundBased() && GetRoundsPlayed() > 0 )
			return  // subsequent rounds don't do custom intro so gamestate scripts can handle spawning

	if ( ShouldIntroSpawnAsTitan() )
	{
		// spawn as a titan
		player.SetPlayerSettings( "spectator" )
		TitanPlayerHotDropsIntoLevel( player )
	}
	else
	{
		// spawn as a pilot
		local spawnpoint = FindStartSpawnPoint( player )
		spawnpoint.s.inUse = true  // this makes subsequent players not choose the same spawn point

		OnThreadEnd(
			function() : ( spawnpoint )
			{
				if ( IsValid( spawnpoint ) )
					spawnpoint.s.inUse = false
			}
		)

		WaitEndFrame() // let the last function's OnThreadEnd clear parent before setting origin
		Assert( player.GetParent() == null, "ERROR Can't teleport player to real start spawn because he's still parented to entity: " + player.GetParent() )

		thread TeleportPlayer_MaterializeSFX( player, 0.4 )

		player.SetOrigin( spawnpoint.GetOrigin() )
		player.SetAngles( spawnpoint.GetAngles() )

		//printt( player, "teleported to real start spawn,", "origin:", spawnpoint.GetOrigin(), "angles:", spawnpoint.GetAngles() )
	}
}

function TeleportPlayer_MaterializeSFX( player, delay = 0.0 )
{
	player.EndSignal( "Disconnected" )

	if ( delay > 0.0 )
		wait delay

	EmitSoundOnEntityOnlyToPlayer( player, player, "Wargames_Materialize" )
}

function TrainingPod_ViewConeLock_Shared( player )
{
	player.PlayerCone_FromAnim()
	player.PlayerCone_SetMinYaw( -25 )
	player.PlayerCone_SetMaxYaw( 25 )
	player.PlayerCone_SetMinPitch( -30 )
}

function TrainingPod_ViewConeLock_PodOpen( player )
{
	TrainingPod_ViewConeLock_Shared( player )
	player.PlayerCone_SetMaxPitch( 35 )
}

function TrainingPod_ViewConeLock_PodClosed( player )
{
	TrainingPod_ViewConeLock_Shared( player )
	player.PlayerCone_SetMaxPitch( 30 )
}

function TrainingPod_ViewConeLock_SemiStrict( player )
{
	player.PlayerCone_FromAnim()
	player.PlayerCone_SetMinYaw( -10 )
	player.PlayerCone_SetMaxYaw( 10 )
	player.PlayerCone_SetMinPitch( -10 )
	player.PlayerCone_SetMaxPitch( 10 )
}

// ==========================================
// --------------- EVAC STUFF ---------------
// ==========================================
function Wargames_EvacSetup()
{
	//local verticalAnims = Evac_CreateAnimPackage( "dropship_VTOL_evac_start", "dropship_VTOL_evac_idle", "dropship_VTOL_evac_end" )

	local spectatorNode1 = GetEnt( "spec_cam1" )
	local spectatorNode2 = GetEnt( "spec_cam2" )
	local spectatorNode3 = GetEnt( "spec_cam3" )
	local spectatorNode4 = GetEnt( "spec_cam4" )

	Evac_AddLocation( "evac_location1", spectatorNode1.GetOrigin(), spectatorNode1.GetAngles() )
	Evac_AddLocation( "evac_location2", spectatorNode2.GetOrigin(), spectatorNode2.GetAngles() ) //, verticalAnims )
	Evac_AddLocation( "evac_location3", spectatorNode3.GetOrigin(), spectatorNode3.GetAngles() )
	Evac_AddLocation( "evac_location4", spectatorNode4.GetOrigin(), spectatorNode4.GetAngles() )

	local spacenode = GetEnt( "end_spacenode" )
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


// ==========================================
// --------------- MISC STUFF ---------------
// ==========================================
function StartSearchDrones()
{
	WaittillGameStateOrHigher( eGameState.Prematch )

	if ( GetClassicMPMode() )
	{
		// let the level intro go for a while before starting the drones
		wait CUSTOM_INTRO_LENGTH * 0.5
	}

	local searchSpawnerNodeNames = []
	searchSpawnerNodeNames.append( "cinematic_mp_node_us3" )
	searchSpawnerNodeNames.append( "cinematic_mp_node_us8" )
	searchSpawnerNodeNames.append( "cinematic_mp_node_us24" )

	level.ent.EndSignal( "EndSearchDronesThink" )

	local searchSpawnerNodes = []
	foreach( name in searchSpawnerNodeNames )
	{
		local _node = GetNodeByUniqueID( name )
		Assert( _node != null )
		searchSpawnerNodes.append( _node )

		thread KeepSearchDronePathOccupied( _node )

		wait RandomFloat( 10, 15 )
	}
}

function KeepSearchDronePathOccupied( node )
{
	level.ent.EndSignal( "EndSearchDronesThink" )

	local spawnDelay = 10

	local t = {}
	t.drone <- null

	OnThreadEnd(
		function() : ( t )
		{
			if ( IsValid( t ) && IsValid( t.drone ) )
				t.drone.Kill()
		}
	)

	local maxSearchDrones = null

	while ( 1 )
	{
		// max drone check
		maxSearchDrones = GetMaxSearchDrones()
		ArrayRemoveInvalid( level.activeSearchDrones )
		if ( level.activeSearchDrones.len() >= maxSearchDrones )
		{
			printt( "Max # of drones active:", maxSearchDrones, "Delaying spawn from", node )
			wait spawnDelay * 0.75 // gives a better chance for this path to be chosen
			continue
		}

		// spawn new drone and wait for death
		local prevDrone = null
		if ( level.activeSearchDrones.len() )
			prevDrone = level.activeSearchDrones[ level.activeSearchDrones.len() - 1 ]

		local prevDrones = level.activeSearchDrones.len()

		NodeDoMoment( node )

		local nextDrones = level.activeSearchDrones.len()
		t.drone = level.activeSearchDrones[ level.activeSearchDrones.len() - 1 ]
		Assert( t.drone != prevDrone )  // make sure we grabbed the new one

		Assert( IsValid( t.drone ) )
		t.drone.WaitSignal( "OnDestroy" )
		t.drone = null

		wait spawnDelay
	}
}

function StopSearchDrones()
{
	level.ent.Signal( "EndSearchDronesThink" )
}


function NormalPlayerRespawn( player )
{
	ResetTitanRespawnTimer( player )
	DecideRespawnPlayer( player )
}

function Wargames_NonCinematicSpawn()
{
	local players = GetPlayerArray()

	foreach ( player in players )
	{
		if ( !IsAlive( player ) )
		{
			NormalPlayerRespawn( player )
		}
	}
}

function Wargames_GroundTroopsDeathCallback( guy, damageInfo )
{
	EmitSoundAtPosition( guy.GetOrigin(), "Object_Dissolve" )

	if ( ShouldDoDissolveDeath( guy, damageInfo ) )
		guy.Dissolve( ENTITY_DISSOLVE_CHAR, Vector( 0, 0, 0 ), 0 )
}

function ShouldDoDissolveDeath( guy, damageInfo )
{
	if ( !guy.IsPlayer() )
		return true

	// can't dissolve players when they're not playing the game, otherwise when the game starts again they're invisible
	local gs = GetGameState()
	if ( gs != eGameState.Playing && gs != eGameState.SuddenDeath && gs != eGameState.Epilogue )
	{
		printt( "Skipping player dissolve death because game is not active ( player:", guy, ")" )
		return false
	}

	return true
}

function KillFX( fxHandle, doDestroyImmediately = false )
{
	if ( !IsValid_ThisFrame( fxHandle ) )
		return

	fxHandle.Fire( "DestroyImmediately" )
	fxHandle.ClearParent()
	fxHandle.Destroy()
}

function RemoteFunctionCall_AllPlayers( funcName, arg = null )
{
	local players = GetPlayerArray()

	foreach ( player in players )
	{
		if ( arg != null )
			Remote.CallFunction_Replay( player, funcName, arg )
		else
			Remote.CallFunction_Replay( player, funcName )
	}
}

function RemoteFunctionCall_AllPlayers_NonReplay( funcName, arg = null )
{
	local players = GetPlayerArray()

	foreach ( player in players )
	{
		if ( arg != null )
			Remote.CallFunction_NonReplay( player, funcName, arg )
		else
			Remote.CallFunction_NonReplay( player, funcName )
	}
}

function RemoteFunctionCall_AllTeam_NonReplay( funcName, teamID, arg = null )
{
	local players = GetPlayerArrayOfTeam( teamID )

	foreach ( player in players )
	{
		if ( arg != null )
			Remote.CallFunction_NonReplay( player, funcName, arg )
		else
			Remote.CallFunction_NonReplay( player, funcName )
	}
}

function PrintGameStateChanges()
{
	local lastState = -1

	while ( 1 )
	{
		wait 0

		local state = GetGameState()
		if ( state == lastState )
			continue

		printt( "Gamestate changed! Now:", state )

		lastState = state

		if ( lastState == eGameState.Playing )
			break
	}
}

function GetScriptPos( player = null )
{
	if ( !player )
		player = gp()[0]

	local pos = player.GetOrigin()
	local ang = player.GetAngles()

	local returnStr = "append( { origin = Vector( " + pos.x + ", " + pos.y + ", " + pos.z + " ), angles = Vector( 0, " + ang.y + ", 0 ) } )"
	return returnStr
}


main()
