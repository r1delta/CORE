//----------------
// Spectre Swarms
//----------------
const SPECTRE_SPAWN_COOLDOWN = 6
const SPECTRE_SPAWN_COOLDOWN_EPILOGUE_RACKS = 10
const SPECTRES_MAX_AI = 30
const SPECTRE_MAX_DISTSQ_FROM_EVAC = 4194304 //2048 * 2048
const SPECTRE_MAX_DIST_FROM_ENEMY = 2048
const SPECTRE_MAX_DISTSQ_FROM_ENEMY = 4194304 //2048 * 2048
const GAY_LEVELED_ANGLE_OFFSET = 90

//----------------
// Models - SERVER
//----------------
const DROPSHIP_PILOT_MODEL = "models/humans/mcor_hero/officer/mcor_hero_officer.mdl"
PrecacheModel( DROPSHIP_PILOT_MODEL )

//----------------
// Models - CLIENT
//----------------
const INTACT_MODEL_ASSEMBLY = "models/levels_terrain/mp_corporate/assembly_tube_breaker_side_intact.mdl"
const BROKEN_MODEL_ASSEMBLY = "models/levels_terrain/mp_corporate/assembly_tube_breaker_side_broken.mdl"
const INTACT_MODEL_PARKING_01 = "models/levels_terrain/mp_corporate/corporate_parking_garage01_piece01_intact.mdl"
const BROKEN_MODEL_PARKING_01 = "models/levels_terrain/mp_corporate/corporate_parking_garage01_piece01_broken.mdl"
const INTACT_MODEL_PARKING_02 = "models/levels_terrain/mp_corporate/corporate_parking_garage01_piece02_intact.mdl"
const BROKEN_MODEL_PARKING_02 = "models/levels_terrain/mp_corporate/corporate_parking_garage01_piece02_broken.mdl"
const INTACT_MODEL_PARKING_03 = "models/levels_terrain/mp_corporate/corporate_parking_garage01_piece03_intact.mdl"
const BROKEN_MODEL_PARKING_03 = "models/levels_terrain/mp_corporate/corporate_parking_garage01_piece03_broken.mdl"
const INTACT_MODEL_PARKING_04 = "models/levels_terrain/mp_corporate/corporate_parking_garage01_piece04_intact.mdl"
const BROKEN_MODEL_PARKING_04 = "models/levels_terrain/mp_corporate/corporate_parking_garage01_piece04_broken.mdl"
const INTACT_MODEL_SMALLSTORAGE_01 = "models/levels_terrain/mp_corporate/corporate_parking_garage_small_piece01_intact.mdl"
const BROKEN_MODEL_SMALLSTORAGE_01 = "models/levels_terrain/mp_corporate/corporate_parking_garage_small_piece01_broken.mdl"
const INTACT_MODEL_SMALLSTORAGE_02 = "models/levels_terrain/mp_corporate/corporate_parking_garage_small_piece02_intact.mdl"
const BROKEN_MODEL_SMALLSTORAGE_02 = "models/levels_terrain/mp_corporate/corporate_parking_garage_small_piece02_broken.mdl"
const INTACT_MODEL_SMALLSTORAGE_03 = "models/levels_terrain/mp_corporate/corporate_parking_garage_small_piece03_intact.mdl"
const BROKEN_MODEL_SMALLSTORAGE_03 = "models/levels_terrain/mp_corporate/corporate_parking_garage_small_piece03_broken.mdl"
const INTACT_MODEL_SMALLSTORAGE_04 = "models/levels_terrain/mp_corporate/corporate_parking_garage_small_piece04_intact.mdl"
const BROKEN_MODEL_SMALLSTORAGE_04 = "models/levels_terrain/mp_corporate/corporate_parking_garage_small_piece04_broken.mdl"

PrecacheModel( NEUTRAL_SPECTRE_MODEL )

PrecacheModel( INTACT_MODEL_ASSEMBLY )
PrecacheModel( BROKEN_MODEL_ASSEMBLY )
PrecacheModel( INTACT_MODEL_PARKING_01 )
PrecacheModel( BROKEN_MODEL_PARKING_01 )
PrecacheModel( INTACT_MODEL_PARKING_02 )
PrecacheModel( BROKEN_MODEL_PARKING_02 )
PrecacheModel( INTACT_MODEL_PARKING_03 )
PrecacheModel( BROKEN_MODEL_PARKING_03 )
PrecacheModel( INTACT_MODEL_PARKING_04 )
PrecacheModel( BROKEN_MODEL_PARKING_04 )
PrecacheModel( INTACT_MODEL_SMALLSTORAGE_01 )
PrecacheModel( BROKEN_MODEL_SMALLSTORAGE_01 )
PrecacheModel( INTACT_MODEL_SMALLSTORAGE_02 )
PrecacheModel( BROKEN_MODEL_SMALLSTORAGE_02 )
PrecacheModel( INTACT_MODEL_SMALLSTORAGE_03 )
PrecacheModel( BROKEN_MODEL_SMALLSTORAGE_03 )
PrecacheModel( INTACT_MODEL_SMALLSTORAGE_04 )
PrecacheModel( BROKEN_MODEL_SMALLSTORAGE_04 )

PrecacheModel( "models/vehicle/capital_ship_annapolis/annapolis_fleetScale_1000x.mdl" )
PrecacheModel( "models/vehicle/space_cluster/birmingham_space_clusterA1000x.mdl" )
PrecacheModel( "models/vehicle/capital_ship_Birmingham/birmingham_fleetScale_1000x.mdl" )
PrecacheModel( "models/vehicle/space_cluster/crow_space_clusterA1000x.mdl" )
PrecacheModel( "models/vehicle/space_cluster/crow_space_clusterb1000x.mdl" )
PrecacheModel( "models/vehicle/space_cluster/redeye_space_clusterc1000x.mdl" )
PrecacheModel( "models/vehicle/space_cluster/redeye_space_clustera1000x.mdl" )
PrecacheModel( "models/vehicle/space_cluster/imc_carrier_space_clusterc_1000x.mdl" )
PrecacheModel( "models/vehicle/space_cluster/imc_carrier_space_clusterB_1000x.mdl" )
PrecacheModel( "models/vehicle/space_cluster/imc_carrier_space_clusterA_1000x.mdl" )
PrecacheModel( "models/vehicle/goblin_dropship/goblin_dropship_fleetscale_1000x.mdl" )
PrecacheModel( "models/vehicle/capital_ship_argo/capital_ship_argo_1000x.mdl" )

const SPECTRE_ASSEMBLY_ANIM_Z_OFFSET = 78
const MATCH_PROGRESS_CORPORATE_STOP_SPAWNING_GRUNTS = 90
const TIME_BEFORE_ASSEMBLY_CAN_STOP = 5	//need to allow at least this much time to allow the assembly line to come to a complete stop
const SPECTRE_TRIGGER_EXPLODE_DIST = 400
const SPECTRE_TRIGGER_EXPLODE_DIST_SQ = 160000 //400 * 400
const SPECTRE_TRIGGER_ACTIVATE_DIST_SQ = 262144 //512 * 512
const SPECTRE_EXPLOSION_RADIUS = 256
const SPECTRE_STATE_HANGING = 1
const SPECTRE_STATE_DEACTIVATING = 2
const SPECTRE_STATE_EXPLODING = 3
const SPECTRE_STATE_SEARCHING = 5

const SPECTRE_TYPE_RACK = 1
const SPECTRE_TYPE_LEAPER = 2
const SPECTRE_TYPE_SWARM = 3
const SPECTRE_TYPE_AI = 4

//----------------
// Sound
//----------------

//Spectres
const SFX_SPECTRE_RACK_RESIDUAL_FIRE_LOOP = "corporate_small_fire_loop"
const SFX_SPECTRE_RACK_RESET = "corporate_spectrerack_reset"
const SFX_SPECTRE_SPAWN_FROM_WINDOW = "corporate_glass_break"
const SFX_SPECTRE_OVERLOAD = "corporate_spectre_overload_beep"
const SFX_SPECTRE_EXPLODE = "corporate_spectre_death_explode"
const SFX_SPECTRE_EXPLODE_SMALL = "corporate_spectre_death_explode_small"
const SFX_SPECTRE_LIGHT_ACTIVATE = "corporate_spectre_initialize_beep"
const SFX_SPECTRE_RACK_ACTIVATE = "corporate_spectrerack_activate"
const SFX_SPECTRE_NEUTRALIZED = "corporate_spectre_neutralized"
const SFX_SPECTRE_NEUTRALIZED_SPARKS = "marvin_weld"
const SFX_SPECTRE_GROUND_SLAM = "Grass.BulletImpact_1P_vs_3P"

// dropship
const SFX_DROPSHIP_PLAYER_ENGINE_MILITIA = "Corporate_Militia_PlayerDropship_IntroFlyIn"
//const SFX_DROPSHIP_PLAYER_ENGINE_IMC = "Corporate_Militia_PlayerDropship_IntroFlyIn"
const SFX_DROPSHIP_PLAYER_ENGINE_IMC = "Corporate_IMC_PlayerDropship_IntroFlyIn"
const SFX_RADIO_STATIC = "Titan_Offhand_ElectricSmoke_Titan_Damage_1P"
const SFX_DROPSHIP_RODEO_ENGINE = "Corporate_MilitiaDropship_AttackedByTitan_FliesIn"
const SFX_DROPSHIP_RODEO_TITANLEAP = "corporate_dropshiprodeo_titanleap"
const SFX_DROPSHIP_RODEO_COCKPIT_PUNCH = "corporate_dropshiprodeo_cockpitpunch"
const SFX_DROPSHIP_RODEO_TITANLAND = "corporate_dropshiprodeo_titanland"
const SFX_DROPSHIP_RODEO_PILOT_SCREAM = "corporate_dropshiprodeo_pilotscream"
const SFX_DROPSHIP_RODEO_PILOT_RIP = "corporate_dropshiprodeo_pilotrip"
const SFX_DROPSHIP_RODEO_CRASH = "Corporate_MilitiaDropship_AttackedByTitan_Explodes"


//----------------
// FX
//----------------
const FX_SPECTRE_RACK_RESIDUAL_FIRE = "P_fire_med_FULL"
const FX_SPECTRE_RACK_RESET_TOP = "P_spectre_spawn_emitter"
const FX_SPECTRE_RACK_RESET_MID = "P_spectre_spawn_emitter"
const FX_SPECTRE_RACK_RESET_BOTTOM = "P_spectre_spawn"
const FX_SPECTRE_SPAWN_FROM_WINDOW = "P_env_glass_exp_tube"
const FX_INTRO_TITAN_FIRE_DAMAGE = "stage2_smoke_2"
const FX_INTRO_TITAN_FIRE_DAMAGE2 = "xo_health_dam_exhaust_burst_hld_1"
const FX_SPECTRE_GROUND_SLAM = "dpod_impact_CH_thin_out"
const FX_SPECTRE_ARMED_BLINK_LIGHT	= "acl_light_red"
const FX_SPECTRE_GOING_CRITICAL_1	= "P_spectre_suicide_warn"
//const FX_SPECTRE_GOING_CRITICAL_2	= "P_redeye_exp_flare"
//const FX_SPECTRE_GOING_CRITICAL_3	= "titan_doom_state_sparks_1"
const FX_SPECTRE_EXPLOSION	= "P_spectre_suicide"	//"xo_exp_death" is over the top
const FX_SPECTRE_EXPLOSION_SMALL	= "P_impact_exp_med_metal"
const FX_SPECTRE_DEACTIVATING	= "titan_doom_state_sparks_1"
const FX_SPECTRE_DEACTIVATED_SPARKS	= "weld_spark_01_sparksfly"
const FX_DROPSHIP_CRASH = "xo_exp_death"
const FX_DROPSHIP_COCKPIT_SMASH = "P_glass_exp_cockpit"

PrecacheParticleSystem( FX_SPECTRE_RACK_RESIDUAL_FIRE )
PrecacheParticleSystem( FX_SPECTRE_RACK_RESET_TOP )
PrecacheParticleSystem( FX_SPECTRE_RACK_RESET_MID )
PrecacheParticleSystem( FX_SPECTRE_RACK_RESET_BOTTOM )
PrecacheParticleSystem( FX_SPECTRE_SPAWN_FROM_WINDOW )
PrecacheParticleSystem( FX_INTRO_TITAN_FIRE_DAMAGE )
PrecacheParticleSystem( FX_INTRO_TITAN_FIRE_DAMAGE2 )
PrecacheParticleSystem( FX_SPECTRE_GROUND_SLAM )
PrecacheParticleSystem( FX_SPECTRE_ARMED_BLINK_LIGHT )
PrecacheParticleSystem( FX_SPECTRE_GOING_CRITICAL_1 )
//PrecacheParticleSystem( FX_SPECTRE_GOING_CRITICAL_2 )
//PrecacheParticleSystem( FX_SPECTRE_GOING_CRITICAL_3 )
PrecacheParticleSystem( FX_SPECTRE_EXPLOSION )
PrecacheParticleSystem( FX_SPECTRE_EXPLOSION_SMALL )
PrecacheParticleSystem( FX_SPECTRE_DEACTIVATING )
PrecacheParticleSystem( FX_SPECTRE_DEACTIVATED_SPARKS )
PrecacheParticleSystem( FX_DROPSHIP_CRASH )
PrecacheParticleSystem( FX_DROPSHIP_COCKPIT_SMASH )


//----------------
// ENDING
//----------------
const POSTDIALOGUETIME = 4
const POSTEPILOGUETIME = 39.5

//////////////////////////////////////////////////////////////////////////////////////
function main()
{
	if ( reloadingScripts )
		return

	// block an unclipped area
	AddTitanfallBlocker( Vector( 2910, 3606, -300 ), 500, 200 )
	AddTitanfallBlocker( Vector(-2108, -2144, -700), 1050, 200 )


	level.playCinematicContent <- false
	if ( ( GetCinematicMode() ) && ( GAMETYPE == CAPTURE_POINT ) )
		level.playCinematicContent = true

	IncludeFile( "mp_corporate_shared" )


	//------------------------------------------------------
	// CINEMATIC MODE ONLY
	//------------------------------------------------------
	if ( level.playCinematicContent )
	{
		//----------------
		// Signals
		//----------------
		RegisterSignal( "Dying" )
		RegisterSignal( "ShowTitle" )
		RegisterSignal( "SpectreReset" )
		RegisterSignal( "SpectreReadyToSpawn" )
		RegisterSignal( "SpectreRacksSpawned" )

		//-----------------------------------
		// Cinematic Spectre Spawns/anims
		//-----------------------------------
		level.spectreSpawns <- {}
		level.spectreSpawns[ "spectreRacks" ] <- {}
		level.spectreSpawns[ "spectreRacks" ][ "alpha" ] <- []
		level.spectreSpawns[ "spectreRacks" ][ "bravo" ] <- []
		level.spectreSpawns[ "spectreRacks" ][ "charlie" ] <- []
		level.spectreSpawns[ "spectreRacks" ][ "world" ] <- []
		level.spectreSpawns[ "spectreRacks" ][ "all" ] <- []
		level.spectreSpawns[ "assemblyLineQualityControl" ] <- []
		level.spectreSpawns[ "epilogue" ] <- []

		level.spectreAnims <- {}
		level.spectreAnims[ "SpectreNeutralized" ] <- []
		//level.spectreAnims[ "SpectreNeutralized" ].append( "sp_neutralized_A" )
		//level.spectreAnims[ "SpectreNeutralized" ].append( "sp_neutralized_B" )
		//level.spectreAnims[ "SpectreNeutralized" ].append( "sp_neutralized_C" )
		//level.spectreAnims[ "SpectreNeutralized" ].append( "sp_neutralized_D" )
		level.spectreAnims[ "SpectreNeutralized" ].append( "sp_death_twitch_backfall" )
		level.spectreAnims[ "SpectreNeutralized" ].append( "sp_death_twitch" )
		level.spectreAnims[ "SpectreNeutralized" ].append( "sp_death_sidefall" )
		level.spectreAnims[ "SpectreNeutralized" ].append( "sp_death_overload" )
		level.spectreAnims[ "SpectreNeutralized" ].append( "sp_death_fallback_fire" )
		level.spectreAnims[ "spectreSearch" ] <- []
		level.spectreAnims[ "spectreSearch" ].append( "sp_suicide_spectre_search" )
		level.spectreAnims[ "spectreSearch" ].append( "sp_suicide_spectre_search_B" )
		level.spectreAnims[ "spectreSearch" ].append( "sp_suicide_spectre_search_C" )
		level.spectreAnims[ "spectreSearchDrone" ] <- []
		level.spectreAnims[ "spectreSearchDrone" ].append( "sp_suicide_spectre_search_drone" )
		level.spectreAnims[ "spectreSearchDrone" ].append( "sp_suicide_spectre_search_drone_B" )
		level.spectreAnims[ "spectreSearchDrone" ].append( "sp_suicide_spectre_search_drone_C" )

		level.spectreAnims[ "SpectreSuicideWalk" ] <- []
		level.spectreAnims[ "SpectreSuicideWalk" ].append( "sp_suicide_spectre_run" )
		level.spectreAnims[ "SpectreSuicideWalk" ].append( "sp_suicide_spectre_fastwalk" )
		level.spectreAnims[ "SpectreSuicideWalk" ].append( "sp_suicide_spectre_walk" )

		//----------------
		// Cinematic Flags
		//----------------
		FlagSet( "CinematicIntro" )
		FlagSet( "CinematicOutro" )
		FlagSet( "AllSpectreIMC" )
		FlagSet( "NoSpectreMilitia" )

		FlagInit( "StartMilitiaDropships" )
		FlagInit( "StartMilitiaDropshipEvents" )
		FlagInit( "StartIMCDropships" )
		FlagInit( "IMCDropshipsIncoming" )
		FlagInit( "IntroDropshipDoneMilitia" )
		FlagInit( "IntroDropshipDoneIMC" )

		FlagInit( "SpectreRacksInitialized" )

		//Intro sequences
		FlagInit( "TitanPunchesCockpit" )
		FlagInit( "IntroStartIMCGround" )
		FlagInit( "IntroStartMilitiaGround" )
		FlagInit( "TitanIntroMilitiaSpawned" )

		FlagInit( "IMCPlayerOnGround" )
		FlagInit( "IntroDoneIMC" )
		FlagInit( "IntroDoneMilitia" )

		//----------------------------
		// Custom cinematic stuff
		//----------------------------
		GM_SetMatchProgressAnnounceFunc( MatchProgressUpdate )
		SetGameWonAnnouncement( "CorporateWonAnnouncement" )
		SetGameLostAnnouncement( "CorporateLostAnnouncement" )
		SetGameModeAnnouncement( "CorporateGameModeAnnounce_CP" )

		AddSpawnCallback( "info_target", InfoTargetCallbackCorporate )
		AddClientCommandCallback( "SetEndingSkyCamOnServer", ClientCallback_SetEndingSkyCam ) //

		level.levelSpecificChatterFunc = CorporateSpecificChatter //Uncomment when done!
	}

	FlagInit( "epilogueStarted" )

	AddSpawnCallback( "npc_spectre", SpectreDefaultSpawn )
	AddDeathCallback( "npc_spectre", SpectreDefaultDeath )
}

function debug()
{
    local nodeCount = GetNodeCount()
    local origin

    while ( true )
    {
	    for ( local i = 0; i < nodeCount; i++ )
	    {
	        origin = GetNodePos( i, 0 )
	        if ( IsSpectreNode( i ) )
	            DebugDrawLine( origin, origin + Vector(0,0,64), 255, 0, 0, false, 1.0 )
	        else
	            DebugDrawLine( origin, origin + Vector(0,0,64), 0, 255, 0, false, 1.0 )
		}
		wait 0.1
	}
}

//////////////////////////////////////////////////////////////////////////////////////
function EntitiesDidLoad()
{
	if ( !IsServer() )
		return

	//------------------------------------------------------
	// CINEMATIC MODE ONLY
	//------------------------------------------------------
	if ( level.playCinematicContent )
	{
		level.winners <- null

		level.game10percentDialoguePlayed <- null
		level.game25percentDialoguePlayed <- null
		level.game50percentDialoguePlayed <- null
		level.game75percentDialoguePlayed <- null

		SetCustomIntroLength( 16.5 )

		thread HardpointModeSetup()
		AssemblyLineRoofSetup()
		thread Intro()
	}

	level.forceEvacNode <- null //set to 0, 1, 2 to test each one

	thread SpectreRacksSetup()	//Spawn racked spectres even in MP Classic...they just won't come alive

	//----------------
	// Evac/Epilogue
	//---------------
	if ( EvacEnabled() )
		EvacSetup()
}


/*----------------------------------------------------------------------------------
/
/				INTRO - SHARED
/
/-----------------------------------------------------------------------------------*/

///////////////////////////////////////////////////////////////////////////////////////////
function Intro()
{
	IntroIMCSetup()
	IntroMilitiaSetup()

	FlagWait( "ReadyToStartMatch" )

	SetGlobalForcedDialogueOnly( true )
	thread IntroIMC()
	thread IntroMilitia()

	FlagWait( "IntroDone" )

	SetGlobalForcedDialogueOnly( false )
}

/*----------------------------------------------------------------------------------
/
/				HARDPOINT-SPECIFIC
/
/-----------------------------------------------------------------------------------*/
///////////////////////////////////////////////////////////////////////////////////////////
function HardpointModeSetup()
{

	//when spawning reinforcements for an owned hardpoint, override standard CP spawn logic so we can use Spectre racks
	AddHardpointCustomSpawnCallback( HardpointSpawningOverride )

	FlagWait( "SpectreRacksInitialized" )

	//--------------------------------------
	// Hardpoints wait for action
	//--------------------------------------
	local hardpoints = GetEntArrayByClass_Expensive( "info_hardpoint" )
	foreach( hardpoint in hardpoints )
		thread HardpointThink( hardpoint )

	//--------------------------------------
	// Start AI count housekeeping thread
	//--------------------------------------
	thread HardpointModeAImanager()

}

///////////////////////////////////////////////////////////////////////////////////////////
//Since we are spawning spectres any time a hardpoint is capped, need to handle any AI overflow
function HardpointModeAImanager()
{
	FlagWait( "ReadyToStartMatch" )

	local maxSoldiers = GetMaxAICount( TEAM_IMC ) * 2
	local soldiers
	local soldiersMilitia
	local soldiersIMC

	while ( GetGameState() <= eGameState.Playing )
	{
		//----------------------------------------------
		// Check AI state whenever Spectre racks activated
		//-----------------------------------------------
		level.ent.WaitSignal( "SpectreRacksSpawned" )

		//--------------------------
		// 24 or less AI? We're good
		//--------------------------
		soldiers = GetGruntsAndSpectres()
		printt( "CORPORATE: AI culling - There are a total of ", soldiers.len(), " AI grunts currently active." )
		PrintStatusAI()

		if ( soldiers.len() <= maxSoldiers )
			continue

		//------------------------------------
		// More than 24?, Cull from each side
		//------------------------------------
		soldiersMilitia = []
		soldiersIMC = []

		foreach( index, soldier in soldiers )
		{
			if ( !IsValid( soldier ) )
			{
				printt( "CORPORATE: AI culling - Removed an invalid AI" )
				soldiers.remove( index )
				continue
			}
			if ( IsInSkit( soldier ) )
				continue
			if ( soldier.GetTeam() == TEAM_IMC )
				soldiersIMC.append( soldier )
			if ( soldier.GetTeam() == TEAM_MILITIA )
				soldiersMilitia.append( soldier )
		}

		if ( soldiersIMC.len() > GetMaxAICount( TEAM_IMC ) )
			thread ReduceAIcount( soldiersIMC, TEAM_IMC  )
		if ( soldiersMilitia.len() > GetMaxAICount( TEAM_MILITIA ) )
			thread ReduceAIcount( soldiersMilitia, TEAM_MILITIA )
	}
}

///////////////////////////////////////////////////////////////////////////////////////////
function HardpointThink( hardpoint )
{
	local results
	local newState
	local oldState
	local newTeam
	local oldTeam
	local spectreSquadName
	local spectres

	hardpoint.s.spectreRacks <- null
	hardpoint.s.spectreTrigger <- null

	//--------------------------------------
	// Assign squad prefixes, Spectre racks and triggers
	//--------------------------------------
	if( hardpoint.kv.hardpointGroup == "A" )
	{
		hardpoint.s.spectreRacks = level.spectreSpawns[ "spectreRacks" ][ "alpha" ]
		spectreSquadName = "alpha"
		hardpoint.s.spectreTrigger = GetEnt( "trigger_alpha" )
	}
	else if( hardpoint.kv.hardpointGroup == "B" )
	{
		hardpoint.s.spectreRacks = level.spectreSpawns[ "spectreRacks" ][ "bravo" ]
		spectreSquadName = "bravo"
		hardpoint.s.spectreTrigger = GetEnt( "trigger_bravo" )
	}
	else if ( hardpoint.kv.hardpointGroup == "C" )
	{
		hardpoint.s.spectreRacks = level.spectreSpawns[ "spectreRacks" ][ "charlie" ]
		spectreSquadName = "charlie"
		hardpoint.s.spectreTrigger = GetEnt( "trigger_charlie" )
	}
	else
		return	//ignore any inactive hardpoints like "D", etc

	if ( hardpoint.s.spectreRacks.len() == 0 )
		return

	//arrange array from closest to furthest
	hardpoint.s.spectreRacks = ArrayClosest( hardpoint.s.spectreRacks, hardpoint.GetOrigin() )

	FlagWait( "ReadyToStartMatch" )

	AddHardpointTeamSwitchCallback( hardpoint, HardpointSwitchedTeam )
	HardpointSwitchedTeam( hardpoint )	// set hardpoint to the unassigned state

	//--------------------------------------
	// Wait for hardpoint to change state
	//--------------------------------------
	while ( GetGameState() <= eGameState.Playing )
	{
		results = WaitSignal( hardpoint, "CapturePointStateChange" )
		newTeam = hardpoint.GetTeam()
		newState = hardpoint.GetHardpointState()
		oldState = results.oldState
		oldTeam = "oldTeam" in results ? results.oldTeam : newTeam

		if ( ( newState == CAPTURE_POINT_STATE_CAPTURED ) && ( newTeam != 0 ) )
		{
			//-----------------------------------------------------------------------
			// CAPPED - Neutralize all live enemy Spectres and spawn racks for new team
			//---------------------------------------------------------------------
			SpectresNeutralizeInTrigger( hardpoint.s.spectreTrigger, GetTeamIndex(GetOtherTeams(1 << newTeam)))
			wait 0.3																																							//try to spawn 4, but will accept less
			spectres = Spawn_TrackedSpectreRackSquad( hardpoint, newTeam, 4, UniqueString( spectreSquadName ), false )
			AssaultNearestAvailableHardpoint( spectres, hardpoint )
		}
		if ( newState == CAPTURE_POINT_STATE_CAPPING )
		{
			//--------------------------------------
			// CAPPING - TODO - free up some AI slots in advance?
			//--------------------------------------

		}
		if ( ( newState == oldState ) && ( newTeam == 0 ) && ( oldTeam != 0 ) )
		{
			//--------------------------------------
			// NEUTRALIZED - deactivate any enemy Spectres in trigger
			//--------------------------------------
			thread ForcePlayConversationToTeam( "CorpHardpointNeutralized", GetTeamIndex(GetOtherTeams(1 << oldTeam))) //Want to make sure we play neutralized dialogue to show why Spectres are deactivating
			SpectresNeutralizeInTrigger( hardpoint.s.spectreTrigger, oldTeam )
		}
	}
}

//////////////////////////////////////////////////////////////////////////////////////////////
function AssaultNearestAvailableHardpoint( spectres, hardpoint )
{
	//TODO - Need to have spawned Spectres go into hardpoint mode
	//SquadCapturePointThink fails if another squad has dibs
}


///////////////////////////////////////////////////////////////////////////////////////////
function HardpointSwitchedTeam( hardpoint, previousTeam = null )
{
	local team = hardpoint.GetTeam()

	//printt( "CORPORATE: Hardpoint switched to team: ", team )

	//TODO: turn on/off spectre screens with colored readouts showing team in control
	switch( team )
	{
		case TEAM_IMC:
			Assert( team != previousTeam, "hardpoint switched team to same team as before. " + team )
			break
		case TEAM_MILITIA:
			Assert( team != previousTeam, "hardpoint switched team to same team as before. " + team )
			break
		default:
			// neutralized
			break
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////
// Called from capture_point.nut to bypass standard CP spawn logic so we can use Spectre racks
function HardpointSpawningOverride( hardpoint, team, squadSize, squadName )
{
	local npcArray = Spawn_TrackedSpectreRackSquad( hardpoint, team, squadSize, squadName )
	return npcArray
}


/*----------------------------------------------------------------------------------
/
/				SPECTRE FUNCTIONS
/
/-----------------------------------------------------------------------------------*/
function AA_Spectre_Functions()
{
	//Bookmark to jump to this section
}

//////////////////////////////////////////////////////////////////////////////////////////
function SpectreSpawnSetupEpilogue( infoTargetOrSpectreDrone )
{
	local spectreSpawnType
	local spawnAnim

	if ( infoTargetOrSpectreDrone.GetName().find( "spectreDroneRackSpawner" ) != null )
		spectreSpawnType = "rack"
	else
		spectreSpawnType = infoTargetOrSpectreDrone.Get( "spectreSpawn" )

	Assert( spectreSpawnType != null )
	local table = {}
	table.spawnType <- spectreSpawnType
	table.org <- infoTargetOrSpectreDrone.GetOrigin()
	table.ang <- infoTargetOrSpectreDrone.GetAngles()
	table.anim <- null
	table.animEndPos <- null
	table.lastSpawnTime <- Time()
	table.spectreDrone <- null
	table.spawnCooldown <- SPECTRE_SPAWN_COOLDOWN
	if ( spectreSpawnType == "rack" )
	{
		table.spectreDrone = infoTargetOrSpectreDrone
		table.spawnCooldown <- SPECTRE_SPAWN_COOLDOWN_EPILOGUE_RACKS
	}

	if ( infoTargetOrSpectreDrone.HasKey( "anim" ) )
	{
		local tempSpectre = CreatePropDynamic( NEUTRAL_SPECTRE_MODEL, table.org, table.ang )
		spawnAnim = infoTargetOrSpectreDrone.Get( "anim" )
		local index = tempSpectre.LookupSequence( spawnAnim )
		local spawnAnimEndpos = tempSpectre.GetAnimEndPos( index, 0, 1 )
		tempSpectre.Kill()

		table.anim = spawnAnim
		table.animEndPos = spawnAnimEndpos

		//thread DrawLinePos( table.org, table.animEndPos )
	}
	else
		table.animEndPos = table.org

	level.spectreSpawns[ "epilogue" ].append( table )

}

///////////////////////////////////////////////////////////////////////////////////////////////
function SpectreDefaultSpawn( spectre )
{
	//Don't make coop spectres all white
	if ( GAMETYPE == COOPERATIVE )
		return

	if ( spectre.GetModelName() != NEUTRAL_SPECTRE_MODEL )
		spectre.SetModel( NEUTRAL_SPECTRE_MODEL )
	local team = spectre.GetTeam()
	if ( ( team == TEAM_IMC ) || ( team == TEAM_MILITIA ) )
		SpectreSetTeam( spectre, team )

}

///////////////////////////////////////////////////////////////////////////////////////////////
function SpectreDefaultDeath( spectre, damageInfo )
{
	local pos = spectre.GetOrigin() + Vector( 0, 0, 72 )
	EmitSoundAtPosition( pos, SFX_SPECTRE_NEUTRALIZED )
}

///////////////////////////////////////////////////////////////////////////////////////////////
function PlaySpectreSpawningAnim( spectre, spawnerTable )
{
	local anim = spawnerTable.anim
	local spawnFx
	local spawnSound
	local spawnFxAng
	local pos = spawnerTable.org
	local zOffset = 0

	switch( anim )
	{
		case "sp_bldg_traverse_down_670":
		case "sp_bldg_traverse_down_1024":
		case "sp_traverse_across_1024_down_256":
		case "sp_bldg_traverse_down_670":
		case "sp_traverse_down_512":
			spawnFx = FX_SPECTRE_SPAWN_FROM_WINDOW
			spawnFxAng = spawnerTable.ang
			spawnSound = SFX_SPECTRE_SPAWN_FROM_WINDOW
			break
		case "sp_corporate_wall_swarm_A":
		case "sp_corporate_wall_swarm_B":
		case "sp_assembly_line_drop":
			zOffset = 8
			break
	}

	if ( spawnFx )
		PlayFX( spawnFx, pos, spawnFxAng )
	if ( spawnSound )
		EmitSoundAtPosition( pos, spawnSound )

	waitthread PlayAnim( spectre, spawnerTable.anim, pos + Vector( 0, 0, zOffset ), spawnerTable.ang )
}
//////////////////////////////////////////////////////////////////////////////////////////////////////

function SpectreSuicideBehavior( spectre, spawnerTable = null )
{
	spectre.EndSignal( "OnDeath" )
	spectre.EndSignal( "Dying" )

	Assert( !( "suicideBehavior" in spectre.s ), "CORPORATE: Trying to run suicide behavior twice on a spectre" )

	//--------------------------------------------------------------
	// Spectre properties to make them do unarmed chase/search
	//--------------------------------------------------------------
	spectre.s.suicideBehavior <- 1
	spectre.s.state <- SPECTRE_STATE_SEARCHING
	spectre.s.droneType <- SPECTRE_TYPE_AI

	//spectre.SetMoveSpeedScale( 2.0 )
	//spectre.SetMoveAnim( "sprint2" )
	//spectre.kv.disableArrivalMoveTransitions = true  same as DisableStarts()
	//spectre.s.useRPGPreference = 0
	//spectre.SetEngagementDistVsWeak( 0, 16 )
	//spectre.SetEngagementDistVsStrong( 0, 16 )
	spectre.SetMaxHealth( 50 )
	spectre.SetHealth( 50 )
	spectre.SetAimAssistAllowed( false )
	spectre.SetAllowMelee( false )
	DisableLeeching( spectre )
	spectre.DisableStarts()
	DisableRockets( spectre )
	spectre.CrouchCombat( false )
	spectre.SetMoveAnim( GetRandomAnim( level.spectreAnims[ "SpectreSuicideWalk" ] ) )
	spectre.SetIdleAnim( GetRandomAnim( level.spectreAnims[ "spectreSearch" ] ) )
	spectre.TakeActiveWeapon()
	spectre.kv.allowShoot = 0
	spectre.SetHearingSensitivity( 0 )
	//spectre.SetEfficientMode( true )
	spectre.SetLookDist( SPECTRE_TRIGGER_EXPLODE_DIST )	//won't detonate unless it has line of sight

	//--------------------------------------------------------------
	// Play spawn animation if there is one
	//--------------------------------------------------------------
	if ( ( spawnerTable ) && ( spawnerTable.anim ) )
		waitthread PlaySpectreSpawningAnim( spectre, spawnerTable )

	//--------------------------------------------------------------
	// Wait to explode logic threaded off
	//--------------------------------------------------------------

	thread SpectreWaitToExplode( spectre )

	//--------------------------------------------------------------
	// Keep hunting nearest enemies until dead
	//--------------------------------------------------------------
	local targetEnt
	local node
	local nodePos
	local enemyTeam = GetTeamIndex(GetOtherTeams(1 << spectre.GetTeam()))
	local evacPos = level.evacNode.GetOrigin()

	while ( true )
	{
		wait RandomFloat( 0.75, 2.5 )

		//--------------------------------
		// If closest enemy is too far, delete self
		//--------------------------------
		targetEnt = GetClosestPlayer( spectre.GetOrigin(), enemyTeam )	//will return "null" if no players exist or if too far away to count

		if ( targetEnt == null )
		{
			thread KillWhenNotVisible( spectre )
			nodePos = GetSpectrePatrolPos()	//head to evac area while waiting to delete yourself
		}

		//--------------------------------
		// Chase after closest enemy player
		//--------------------------------
		else if ( targetEnt )
		{
			node = GetNearestNodeToPos( targetEnt.GetOrigin() )
			if ( node < 0 )
			{
				printl( "CORPORATE: No valid path nodes near player origin at " + targetEnt.GetOrigin() )
				nodePos = GetSpectrePatrolPos()
			}
			else
				nodePos = GetNodePos( node, HULL_HUMAN )

			//---------------
			// Spectre "Speaks"
			//---------------
			if ( ( RandomFloat( 0, 1 ) ) < 0.02 )
			{
				EmitSoundOnEntity( spectre, "diag_imc_spectre_gs_spotenemypilot_01_1" )
				//printt( "SPECTRE SPEAKS" )
			}

		}
		//--------------------------------
		// Otherwise head to evac point
		//--------------------------------
		else
		{
			nodePos = GetSpectrePatrolPos()
		}


		spectre.DisableArrivalOnce( true )
		spectre.AssaultPoint( nodePos )

		//DebugDrawLine( spectre.GetOrigin() + Vector( 0, 0, 64 ), nodePos, 0, 255, 0, true, 5.0 )

		//UpdateEnemyMemoryFromTeammates( spectre )
		//UpdateEnemyMemory( spectre, targetEnt )
		//spectre.SetEnemy( targetEnt )

	}
}
/////////////////////////////////////////////////////////////////////////////////////////////
function GetSpectrePatrolPos()
{
	//--------------------------------
	// Find a random evac location to assault
	//--------------------------------
	return Random( level.swarmLocations	)

}
///////////////////////////////////////////////////////////////////////////////////////////
function SpectreRacksSetup()
{

	//--------------------------------------
	// Setup all Spectres into default hang
	//--------------------------------------
	local spectreSpawnsOrgs = GetEntArrayByNameWildCard_Expensive( "spectreSpawnLabRack*" )

	local pos
	local ang
	local spectre
	local touchingTrigger
	local triggerAlpha = GetEnt( "trigger_alpha" )
	local triggerBravo = GetEnt( "trigger_bravo" )
	local triggerCharlie = GetEnt( "trigger_charlie" )
	Assert( triggerAlpha != null )
	Assert( triggerBravo != null )
	Assert( triggerCharlie != null )

	//--------------------------------------
	// Assign Spectres to Hardpoint triggers
	//--------------------------------------
	//-12.52 -0.44 -2

	foreach( ent in spectreSpawnsOrgs )
	{
		pos = ent.GetOrigin()
		ang = ent.GetAngles()
		local spectre = SpawnSpectreDrone( pos, ang, SPECTRE_TYPE_RACK )
		spectre.SetInactive( true )
		spectre.Anim_PlayWithRefPoint( "sp_med_bay_dropidle_A", pos, ang, 0 )

		if ( !level.playCinematicContent )
			continue

		//--------------------------------------
		// CINEMATIC SETUP ONLY
		//--------------------------------------
		spectre.SetName( "spectreDroneRackSpawner" )
		spectre.s.inUse <- false
		spectre.SetTouchTriggers( true ) //<- prop_dynamics won't activate triggers by default
		spectre.s.state = SPECTRE_STATE_HANGING
		spectre.s.animPos <- pos
		spectre.s.animAng <- ang
		spectre.s.posSpawnFxTop <- PositionOffsetFromEnt( ent, 12, -0.25, 93.7036 )
		spectre.s.angSpawnFxTop <- ang + Vector( 0, 0, 180 ) + Vector( 0, GAY_LEVELED_ANGLE_OFFSET, 0 )
		spectre.s.posSpawnFxMid <- PositionOffsetFromEnt( ent, 12, -0.25, 9.2036 )
		spectre.s.angSpawnFxMid <- ang + Vector( 0, 0, 0 ) + Vector( 0, GAY_LEVELED_ANGLE_OFFSET, 0 )
		spectre.s.posSpawnFxBottom <- pos
		spectre.s.angSpawnFxBottom <- ang + Vector( 0, -90, 0 ) + Vector( 0, GAY_LEVELED_ANGLE_OFFSET, 0 )

		if ( triggerAlpha.IsTouching( spectre ) )
			touchingTrigger = "alpha"
		else if ( triggerBravo.IsTouching( spectre ) )
			touchingTrigger = "bravo"
		else if ( triggerCharlie.IsTouching( spectre ) )
			touchingTrigger = "charlie"
		else
			touchingTrigger = "world"

		level.spectreSpawns[ "spectreRacks" ][ touchingTrigger ].append( spectre )
		level.spectreSpawns[ "spectreRacks" ][ "all" ].append( spectre )

		//--------------------------------------
		// Add spawn org into epilogue spawners
		//--------------------------------------
		SpectreSpawnSetupEpilogue( spectre )
	}

	if ( !level.playCinematicContent )
		return


	local minimumRacksPerHardpoint = 8
	Assert( level.spectreSpawns[ "spectreRacks" ][ "alpha" ].len() >= minimumRacksPerHardpoint, "CORPORATE: not enough spectre racks found at alpha: " + level.spectreSpawns[ "spectreRacks" ][ "alpha" ].len() )
	Assert( level.spectreSpawns[ "spectreRacks" ][ "bravo" ].len() >= minimumRacksPerHardpoint, "CORPORATE: not enough spectre racks found at bravo: " + level.spectreSpawns[ "spectreRacks" ][ "bravo" ].len() )
	Assert( level.spectreSpawns[ "spectreRacks" ][ "charlie" ].len() >= minimumRacksPerHardpoint, "CORPORATE: not enough spectre racks found at charlie: " + level.spectreSpawns[ "spectreRacks" ][ "charlie" ].len() )

	printt( "CORPORATE: Total spectre racks: ", level.spectreSpawns[ "spectreRacks" ][ "all" ].len() )

	FlagSet( "SpectreRacksInitialized" )

}

///////////////////////////////////////////////////////////////////////////////////////////
function SpawnSpectreDrone( pos, ang, droneType )
{
	local spectre = CreatePropDynamic( NEUTRAL_SPECTRE_MODEL, pos, ang, 8 )	//<- "hitboxes only" - Need to set collision to not be default 0, otherwise won't be detected in triggers
	spectre.s.state <- null
	spectre.s.droneType <- droneType
	spectre.UseHitBoxForTraceCheck()

	return spectre
}

////////////////////////////////////////////////////////////////////////////////////////////////
function Spawn_TrackedSpectreRackSquad( hardpoint, team, squadSize, squadName, forceSquadSize = true )
{
	//ReserveAISlots( team, squadSize )

	local hardpointSpectreRacks = hardpoint.s.spectreRacks

  //--------------------------------------
	// Get valid rack spawners for this hardpoint
	//--------------------------------------
 	local spawners = []
 	foreach( rackSpawner in hardpointSpectreRacks )
 	{
 		if ( rackSpawner.s.inUse == true )
 			continue
 		spawners.append( rackSpawner )
 		if ( spawners.len() == squadSize )
 			break
 	}

 	//--------------------------------------
	// Not enough free Spectre racks to spawn!
	//--------------------------------------
 	if ( ( spawners.len() != squadSize ) && ( forceSquadSize ) )
 	{
 		printt( "CORPORATE: Failed to spawn Spectre reinforcements at ", hardpoint.GetName(), ". Needed ", squadSize, " spectre racks free, but there were: ", spawners.len() )
 		return null
 	}

 	//--------------------------------------
	// Spawn spectres off the racks for this team
	//--------------------------------------
 	local spectreArray = []
 	local spectre
 	foreach( spawner in spawners )
 	{
 		spectre = SpawnRackedSpectre( spawner, team, squadName, "random" )
 		//thread FreeAISlotOnDeath( spectre )
 		spectreArray.append( spectre )
 	}

 	if ( forceSquadSize )
 		Assert( spectreArray.len() == squadSize, "CORPORATE: Array of spwned spectres ( " + spectreArray.len() + " ) does not equal desired squad size ( " + squadSize + " )" )

	//if ( squadSize != spectreArray.len() )
		//ReleaseAISlots( team, squadSize - spectreArray.len() )

	level.ent.Signal( "SpectreRacksSpawned" )

 	return spectreArray
}

///////////////////////////////////////////////////////////////////////////////////
function SpawnRackedSpectre( spawner, team, squadName, timeout, isDrone = false, animOverride = null )
{
	spawner.s.inUse = true
	local spectre

 	//--------------------------------------
	// Drone is just the hanging prop dynamic
	//--------------------------------------
	if ( isDrone )
	{
		//Spectre drone already exists
		spectre = spawner
		SpectreSetTeam( spectre, team )
		spectre.SetInactive( false )
	}
 	//------------------------
 	// Regular Spectre is AI
	//------------------------
	else
	{
		spectre = Spawn_TrackedSpectre( TEAM_IMC, UniqueString(), spawner.s.animPos, spawner.s.animAng, true, null, true ) // <-- hidden when spawned
		//spectre = SpawnSpectre( TEAM_UNASSIGNED, UniqueString(), spawner.s.animPos, spawner.s.animAng, true, null, true )// <---hidden when spawned
		MakeInvincible( spectre )
		thread PlayAnimTeleport( spectre, "sp_med_bay_dropidle_A", spawner.s.animPos, spawner.s.animAng )
		local weapon = spectre.GetActiveWeapon()
		spectre.TakeActiveWeapon()	//need to hide weapon or we'll see a pop
		spectre.s.weapon <- weapon.GetClassname()
		SpectreSetTeam( spectre, team )
		SetSquad( spectre, squadName )	//Need to set squad name after we switch default IMC team, otherwise will conflict with other spawning (imc) spectre racks
		spectre.SetEfficientMode( true )
	}

 	//--------------------------------------------
 	// Return spawned spectre and activate when seen
	//------------------------------------------------
	thread SpectreRackActivateWhenSeenOrTimeout( spawner, spectre, timeout, isDrone, animOverride )
	return spectre
}


///////////////////////////////////////////////////////////////////////////////////////////////
function SpectreRackActivateWhenSeenOrTimeout( spawner, spectreAI, timeout = null, isDrone = false, animOverride = null )
{

	local time
	local timeWaiting = 0
	local playerClose = false
	local spectrePos = spawner.GetOrigin()
	local players
 	//--------------------------------------
 	// Timout when not seen, or never timeout
	//---------------------------------------
	local neverTimeout = false
	if ( timeout == "random" )
		timeout = RandomFloat( 0.5, 1.5 )
	else if ( timeout == -1 )
	{
		timeout = 0
		neverTimeout = true
	}

 	//-------------------------------
 	// Wait to be seen or timeout
	//-------------------------------
	while( true )
	{
		time = RandomFloat( 0.5, 1.5 )
		wait time
		timeWaiting = ( timeWaiting + time )

		//exceeded timeout, go ahead and activate
		if ( ( timeWaiting >= timeout ) && ( neverTimeout == false ) )
			break

		//otherwise check if any player can see
		players = GetPlayerArray()
		foreach( player in players )
		{
			if ( !IsValid( player ) )
				continue
			if ( ( SpectreWithinTriggerDist( spectrePos, player.GetOrigin() ) ) ||  ( player.CanSee( spawner ) ) )
			{
				playerClose = true
				break
			}
		}

		if ( playerClose )
			break
	}

	if ( ( IsNPC ( spectreAI ) ) && ( !IsAlive( spectreAI ) ) )
		return

	thread SpectreRackActivate( spawner, spectreAI, isDrone, animOverride )
}

///////////////////////////////////////////////////////////////////////////////////
function SpectreRackActivate( spawner, spectreAI, isDrone = false, animOverride = null )
{
	spectreAI.EndSignal( "OnDeath" )

	EmitSoundAtPosition( spawner.s.animPos + Vector( 0, 0, 72), SFX_SPECTRE_LIGHT_ACTIVATE )
	EmitSoundAtPosition( spawner.s.animPos + Vector( 0, 0, 72), SFX_SPECTRE_RACK_ACTIVATE )


	local anim = animOverride

	OnThreadEnd
	(
		function () : ( isDrone, spawner )
		{
			if ( !isDrone )
			{
				thread SpectreSuicideRackReset( spawner )	//only for real AI...prop_dynamic versions won't reset till killed or blown up
			}
		}
	)

	//-------------------------------
 	// Suicide prop_dynamic drops and waits to blow up
	//-------------------------------
	if ( isDrone )
	{
		spawner.Anim_Stop()
		if ( !anim )
			anim = "sp_med_bay_drop_unarmed"
		waitthread PlayAnim( spawner, anim, spawner.s.animPos, spawner.s.animAng )
		spawner.Anim_PlayWithRefPoint( GetRandomAnim( level.spectreAnims[ "spectreSearchDrone" ] ), spawner.GetOrigin(), spawner.GetAngles(), 0 )
		thread SpectreWaitToExplode( spawner )

		//---------------
		// Spectre "Speaks"
		//---------------
		if ( CoinFlip() )
			EmitSoundOnEntity( spawner, "diag_imc_spectre_gs_deployedRack_01_1" )
	}
	//-------------------
 	// Regular AI drops
	//-------------------
	else
	{
		spawner.Hide()
		spectreAI.Show()
		spectreAI.GiveWeapon( spectreAI.s.weapon )
		spectreAI.SetActiveWeapon( spectreAI.s.weapon )
		delete spectreAI.s.weapon
		spectreAI.Anim_Stop()
		if ( !anim )
			anim = "sp_med_bay_drop_armed"
		waitthread PlayAnim( spectreAI, anim, spawner.s.animPos, spawner.s.animAng )
		spectreAI.SetEfficientMode( false )
		ClearInvincible( spectreAI )

		wait RandomFloat( 0.2, 1.2 )
		//---------------
		// Spectre "Speaks"
		//---------------
		if ( CoinFlip() )
			EmitSoundOnEntity( spectreAI, "diag_imc_spectre_gs_deployedRack_01_1" )

		wait 5

	}

}


///////////////////////////////////////////////////////////////////////////
function SpectreSuicideOnDamaged( spectre )
{
	spectre.EndSignal( "SpectreReset" )
	spectre.EndSignal( "OnDeath" )
	spectre.EndSignal( "OnDestroy" )

	local results
	local health = 50

	while( true )
	{
		results = WaitSignal( spectre, "OnDamaged" )
		if ( spectre.s.state == SPECTRE_STATE_HANGING )
			continue
		if ( spectre.s.state == SPECTRE_STATE_EXPLODING )
			break

		//GetWeapon
		//
		//printt( "Damage amount: ", results.value )
		//printt( "Damage inflictor: ", results.inflictor )
		//printt( "Damage activator: ", results.activator )
		//printt( "Damage caller: ", results.caller )

		if ( results.value )
			health -= results.value

		if ( health < 1 )
			break
	}


	thread SpectreNeutralize( spectre )
}

/////////////////////////////////////////////////////////////////////////////////
function SpectresNeutralizeInTrigger( trigger, team )
{
	Assert( team == TEAM_IMC || team == TEAM_MILITIA, "CORPORATE: Could not detect team: " + team  )

	local spectres = GetNPCArrayByClass( "npc_spectre" )

	foreach( spectre in spectres )
	{
		if ( !IsAlive( spectre ) )
			continue
		if ( spectre.GetTeam() != team )
			continue
		if ( trigger.IsTouching( spectre ) )
			thread SpectreNeutralize( spectre )
	}
}

//////////////////////////////////////////////////////////////////////////////
function SpectresNeutralizeAllOnTeam( team )
{
	local spectres = GetNPCArrayByClass( "npc_spectre" )
	foreach( spectre in spectres )
	{
		if ( !IsAlive( spectre ) )
			continue
		if ( spectre.GetTeam() == team )
			thread SpectreNeutralize( spectre )
	}
}

/////////////////////////////////////////////////////////////////////////////
function SpectreNeutralize( spectre )
{
	//Early out if being called twice (neutralized by a bullet while trying to be neutralized by a hardpoint cap
	if ( "neutralizing" in spectre.s )
		return

	spectre.s.neutralizing <- true

	if ( IsNPC( spectre ) )
	{
		Assert( IsAlive( spectre ), "CORPORATE: Trying to neutralize a spectre that is already dead at: " + spectre.GetOrigin() )
		spectre.EndSignal( "OnDeath" )
	}

	local pos = spectre.GetOrigin()
	local anim = GetRandomAnim( level.spectreAnims[ "SpectreNeutralized" ] )
	local fx = PlayFXOnEntity( FX_SPECTRE_DEACTIVATING, spectre, "CHESTFOCUS" )
	thread SpectreNeutralizeFx( pos )

	//----------------------------------
	// Kill if normal NPC
	//----------------------------------
	if ( spectre.IsNPC() )
	{
		ClearDeathFuncName( spectre )
		SetDeathFuncName( spectre, "SpectreNeutralizeDeath" )
		spectre.Die()
	}

	//------------------------------------------------------------------
	// Suicide drones deactivate then reset in the rack a few seconds later
	//------------------------------------------------------------------
	else
	{
		EmitSoundAtPosition( pos, SFX_SPECTRE_NEUTRALIZED )
		anim = "sp_death_overload_prop_dynamic"	//need specific anim without ragdoll notetracks, otherwise prop would get deleted
		spectre.Signal( "SpectreReset" )
		spectre.s.state = SPECTRE_STATE_DEACTIVATING

		waitthread PlayAnim( spectre, anim )

		if ( spectre.s.droneType == SPECTRE_TYPE_RACK )
		{
			delaythread ( 5 ) SpectreSuicideRackReset( spectre )
		}
	}
}

////////////////////////////////////////////////////////////
function SpectreNeutralizeFx( pos )
{
	wait 1.5
	EmitSoundAtPosition( pos, SFX_SPECTRE_NEUTRALIZED_SPARKS )
	PlayFX( FX_SPECTRE_DEACTIVATED_SPARKS, pos, Vector( 0, 0, 0 ) )
}
////////////////////////////////////////////////////////////
function SpectreNeutralizeDeath( spectre )
{
	local anim = GetRandomAnim( level.spectreAnims[ "SpectreNeutralized" ] )
	spectre.Anim_Play( anim )
	WaitSignalOnDeadEnt( spectre, "OnAnimationDone" )
	spectre.BecomeRagdoll( Vector( 0, 0, 0 ) )
}


//////////////////////////////////////////////////////////////////////////////////////
function SpectreWaitToExplode( spectre )
{
	spectre.EndSignal( "OnDeath" )

	local spectreTeam = spectre.GetTeam()
	local enemyTeam = GetTeamIndex(GetOtherTeams(1 << spectreTeam))
	local enemyPlayers
	local distSq
	local canExplode = false

	spectre.s.state = SPECTRE_STATE_SEARCHING

	thread SpectreSuicideOnDamaged( spectre )

	while( true )
	{
		wait RandomFloat( 0.25, 1 )

		//-------------------------------------------------------------
		// Get out of this loop if it's not in default mode
		//--------------------------------------------------------------
		if ( spectre.s.state != SPECTRE_STATE_SEARCHING )
			break

		//-------------------------------------------------------------
		//If spectre is not interrruptable, don't bother
		//-------------------------------------------------------------
		if ( ( IsNPC( spectre ) ) && ( !spectre.IsInterruptable() ) )
		{
			wait 1
			continue
		}

		//-------------------------------------------------------------
		//If spectre is in the middle of a jump/traverse, don't bother
		//-------------------------------------------------------------
		if ( ( IsNPC( spectre ) ) && ( !IsTouchingGround( spectre ) ) )
		{
			wait 1
			continue
		}


		//-------------------------------------------------------------
		// See if any player is close eneough to trigger self-destruct
		//--------------------------------------------------------------
		enemyPlayers = GetPlayerArrayOfTeam( enemyTeam )
		foreach( enemy in enemyPlayers )
		{
			if ( !SpectreWithinTriggerDist( spectre.GetOrigin(), enemy.GetOrigin() ) )
				continue
			if ( ( IsNPC( spectre ) ) && ( !spectre.CanSee( enemy ) ) )
			{
				printt( "Spectre can't see player" )
				continue
			}
			else
			{
				canExplode = true
				break
			}
		}
		if ( canExplode )
			break
	}

	if ( canExplode )
		thread SpectreSelfDestruct( spectre )
}


////////////////////////////////////////////////////////////////////////////////////
function SpectreWithinTriggerDist( spectrePos, playerPos )
{
	local distSq = DistanceSqr( spectrePos, playerPos )
	if ( distSq < SPECTRE_TRIGGER_EXPLODE_DIST_SQ )
		return true
	else
		return false
}

////////////////////////////////////////////////////////////////////////////////////
function SpectreSelfDestruct( spectre )
{
	spectre.EndSignal( "SpectreReset" )
	spectre.EndSignal( "OnDeath" )

	spectre.s.state = SPECTRE_STATE_EXPLODING
	spectre.Signal( "Dying" )

	local pos = spectre.GetOrigin()
	local ang = spectre.GetAngles()

	//---------------
	// Spectre "Speaks"
	//---------------
	EmitSoundOnEntity( spectre, "diag_imc_spectre_gs_selfDestruct_01_1" )





	//---------------
	// Overload FX
	//---------------
	local spectreFx = []
	spectreFx.append( PlayFXOnEntity( FX_SPECTRE_GOING_CRITICAL_1, spectre, "CHESTFOCUS" ) )
	//spectreFx.append( PlayFXOnEntity( FX_SPECTRE_GOING_CRITICAL_3, spectre, "CHESTFOCUS" ) )
	//spectreFx.append( PlayFXOnEntity( FX_SPECTRE_GOING_CRITICAL_2, spectre, "CHESTFOCUS" ) )

	//---------------
	// Overload Sound
	//---------------
	EmitSoundOnEntity( spectre, SFX_SPECTRE_OVERLOAD )

	//------------------------------------
	// Cleanup on thread end
	//------------------------------------
	OnThreadEnd
	(
		function() : ( spectre, spectreFx  )
		{
			if ( IsValid( spectre ) )
				StopSoundOnEntity( spectre, SFX_SPECTRE_OVERLOAD )
			foreach( fx in spectreFx )
				FxDestroy( fx )
		}
	)

	//------------------------------------
	// Abort if getting his neck snapped
	//------------------------------------
	if ( spectre.GetParent() )
		return


	//------------------------------------
	// Spectre plays self destruct anim
	//------------------------------------

	if ( ( IsNPC( spectre ) ) && ( !spectre.IsInterruptable() ) )	//Failsafe: Don't PlayAnimGravity if somehow he is not interruptable
		waitthread PlayAnimGravity( spectre, "sp_suicide_spectre_explode_stand" )
	else
		waitthread PlayAnim( spectre, "sp_suicide_spectre_explode_stand" )	//Only use PlayAnim on prop_dynamic versions or guys that are not interruptable (performing traverse)

	//----------------------------------------
	// Blow up if we've gotten this far
	//----------------------------------------
	waitthread SpectreExplode( spectre )

}

/////////////////////////////////////////////////////////////////////////////////////////////
function SpectreExplode( spectre, reset = true )
{
	local pos = spectre.GetOrigin()
	SpectreExplosionDamage( spectre )
	EmitSoundAtPosition( pos, SFX_SPECTRE_EXPLODE )
	CreateShake( pos, 10, 105, 1.25, 768 )

	local tagID = spectre.LookupAttachment( "CHESTFOCUS" )
	local fxOrg = spectre.GetAttachmentOrigin( tagID )

	PlayFX( FX_SPECTRE_EXPLOSION, fxOrg, Vector( 0, 0, 0 ) )

	//----------------------------
	// spectre real AI
	//----------------------------
	if ( IsNPC( spectre ) )
		SpectreExplodingDeath( spectre )

	//----------------------------
	// spectre is fake prop_dynamic
	//----------------------------
	else
	{
		//Can't actually kill the fake spectre, need to send him back to the rack
		if ( reset == true )
		{
			spectre.Hide()
			thread SpectreSuicideRackReset( spectre )	//will only reset if it's the right drone type
		}
		else
			spectre.Kill()	//this should only happen in Militia epilogue
	}

}
/////////////////////////////////////////////////////////////////////////////////////////////
function SpectreExplosionDamage( spectre )
{
	local pos = spectre.GetOrigin()

	//-----------------------------------
	// Do token damage to players
	//-----------------------------------
	RadiusDamage( spectre.GetOrigin(),	// origin
		15,								// titan damage
		15,								// pilot damage
		SPECTRE_EXPLOSION_RADIUS,		// radiusFalloffMax
		0,								// radiusFullDamage
		spectre, 						// owner
		eDamageSourceId.spectre_melee,  // damage source id
		true,							// alive only
		false,							// selfDamage
		null,							// team
		null )							// scriptFlags

	//-----------------------------------
	// Kill any nearby spectres
	//-----------------------------------
	if ( "activeSuicideSpectres" in level )
	{
		if ( level.activeSuicideSpectres.len() == 0 )
			return

		local spectresToKill = GetArrayOfClosest( level.activeSuicideSpectres, pos, SPECTRE_EXPLOSION_RADIUS, spectre)
		foreach( spectre in spectresToKill )
		{
			if ( IsAlive( spectre ) )
				spectre.Die()
		}
	}
}
///////////////////////////////////////////////////////////////////////////////////////////
// Move to utility?

function GetArrayOfClosest( array, origin, withinDist, excludeEnt = null )
{
	Assert( typeof array == "array" )
	Assert( array.len() > 0, "Empty array!" )
	Assert( withinDist, "Need to specify 'withinDist'" )

	local arrayOfClosest = []
	local withinDistSq = withinDist * withinDist
	local distSqr

	foreach( ent in array )
	{
		if ( !IsValid( ent ) )
			continue
		if ( ( excludeEnt ) && ( excludeEnt == ent ) )
			continue
		distSqr = ( ent.GetOrigin() - origin ).LengthSqr()
		if ( distSqr < withinDistSq )
			arrayOfClosest.append( ent )
	}

	return arrayOfClosest
}


///////////////////////////////////////////////////////////////////////////////////////////
function SpectreExplodingDeath ( spectre )
{
	spectre.Die( level.worldspawn, level.worldspawn, { force = Vector( 0.4, 0.2, 0.3 ), scriptType = DF_SPECTRE_GIB, damageSourceId=eDamageSourceId.mp_titanweapon_40mm } )
}


////////////////////////////////////////////////////////////////////////////////////////
function SpectreSuicideRackReset( spectre )
{
	if ( !IsValid( spectre ) )
		return

	spectre.EndSignal( "OnDestroy" )

	if ( spectre.s.droneType != SPECTRE_TYPE_RACK )
	{
		printl( "CORPORATE: calling 'SpectreSuicideRackReset()' on a non-rack Spectre" )
		return
	}

	if ( "neutralizing" in spectre.s )
		delete spectre.s.neutralizing

	spectre.Signal( "SpectreReset" )

	spectre.Hide()

	SpectreRackRestFx( spectre )

	wait 0.25
	spectre.SetInactive( true )
	spectre.Anim_PlayWithRefPoint( "sp_med_bay_dropidle_A", spectre.s.animPos, spectre.s.animAng, 0 )
	wait 0.25

	wait 3.5

	spectre.Show()
	spectre.s.state = SPECTRE_STATE_HANGING
	spectre.s.inUse = false
	spectre.Signal( "SpectreReadyToSpawn" )
}
////////////////////////////////////////////////////////////////////////////////////////
function SpectreRackRestFx( spectre )
{
	EmitSoundAtPosition( spectre.s.posSpawnFxTop, SFX_SPECTRE_RACK_RESET )
	PlayFX( FX_SPECTRE_RACK_RESET_TOP, spectre.s.posSpawnFxTop, spectre.s.angSpawnFxTop )
	PlayFX( FX_SPECTRE_RACK_RESET_MID, spectre.s.posSpawnFxMid, spectre.s.angSpawnFxMid )
	PlayFX( FX_SPECTRE_RACK_RESET_BOTTOM, spectre.s.posSpawnFxBottom, spectre.s.angSpawnFxBottom )
}
/*----------------------------------------------------------------------------------
/
/				INTRO - IMC
/
/-----------------------------------------------------------------------------------*/
function AA_Intro_IMC_functions()
{
	//Bookmark to jump to this section
}

/////////////////////////////////////////////////////////////////////////////////////////////////////
function IntroIMC()
{

	FlagSet( "Disable_IMC" )//don't spawn any IMC grunts until intro is done

	//----------------------
	// Player dropship
	//----------------------
	thread IntroDropshipIMC()
	//thread IntroDropships( TEAM_IMC, "IMCDropshipsIncoming" )


	//----------------------------------
	// Setup actors
	//------------------------------------

	thread IntroTitanSwarm()

	thread IntroSkit( "chestpunch", "squadIntroSpectres1", Vector( 4461, -1626, -731 ), Vector( 0, 90, 0 ), TEAM_IMC, Vector( 4216, -1656, -776 ), "IntroStartIMCGround", 1, IntroSpectreEngageTitan )
	//thread IntroSkit( "multikill", "squadIntroSpectres1", Vector( 4477, -2239, -740 ), Vector( 0, -90, 0 ), TEAM_IMC, Vector( 4328, -2152, -792 ), "IntroStartIMCGround", 0, IntroSpectreEngageTitan )
	thread IntroSkit( "curbstomp", "squadIntroSpectres1", Vector( 4477, -2239, -740 ), Vector( 0, 90, 0 ), TEAM_IMC, Vector( 3751, -2182, -1024 ), "IntroStartIMCGround", 1, IntroSpectreEngageTitan )
	thread IntroSkit( "blindfire", "squadIntroSpectres1", Vector( 3104, -2192, -896 ), Vector( 0, -130, 0 ), TEAM_IMC, null, "IntroStartIMCGround", 5 )
	//thread IntroSkit( "necksnap", "squadIntroSpectres1", Vector( 3744, -1728, -1024 ), Vector( 0, -90, 0 ), TEAM_IMC, null, "IntroStartIMCGround", 3, IntroSpectreEngageTitan )

	//----------------------
	// Idle till game starts
	//----------------------
	//FlagWait( "GamePlaying" )


	delaythread ( 0.25 ) IntroIMCDialogue()

	wait 2

	FlagSet( "StartIMCDropships" )

	wait 4

	FlagSet( "IMCDropshipsIncoming" )

	wait 6

	thread IntroSpectreGround( "squadIntroSpectres2", Vector( 4176, -2448, -880 ), Vector( 0, 0, 0 ), null )
	//thread IntroSpectreGround( "squadIntroSpectres2", Vector( 4368, -1920, -816 ), Vector( 0, 0, 0 ), null  )
	thread IntroSpectreGround( "squadIntroSpectres2", Vector( 3744, -1280, -1008 ), Vector( 0, 0, 0 ), null )


	wait 6

	FlagSet( "IMCPlayerOnGround" )
	wait 2

	FlagSet( "IntroStartIMCGround" )


	FlagWait( "IntroDoneIMC" )

	wait 1.5



	//----------------------
	// Spectres go back into normal AI
	//----------------------
	local squad = GetNPCArrayBySquad( "squadIntroSpectres1" )
	ArrayAppend( squad, GetNPCArrayBySquad( "squadIntroSpectres2" ) )
	//ArrayAppend( squad, GetNPCArrayBySquad( "squadIntroSpectres3" ) )
	foreach( spectre in squad )
	{
		if ( !IsAlive( spectre ) )
			continue
		SpectreIntroReset( spectre )
	}

	//---------------------------------------------
	// Make any remaining skit AI go into hardpoint mode
	//---------------------------------------------
	if ( GameRules.GetGameMode() == CAPTURE_POINT )
	{
		local hardpointSkybridge = GetEnt( "info_hardpoint_skybridge" )
		local hardpointAssembly = GetEnt( "info_hardpoint_assembly" )
		local hardpointLobby = GetEnt( "info_hardpoint_lobby" )
		Assert( hardpointSkybridge != null, "CORPORATE: There is no hardpoint with targetname: info_hardpoint_skybridge" )
		Assert( hardpointAssembly != null, "CORPORATE: There is no hardpoint with targetname: info_hardpoint_assembly" )
		Assert( hardpointLobby != null, "CORPORATE: There is no hardpoint with targetname: info_hardpoint_lobby" )

		thread SquadCapturePointThink( "squadIntroSpectres1", hardpointSkybridge, TEAM_IMC )
		thread SquadCapturePointThink( "squadIntroSpectres2", hardpointAssembly, TEAM_IMC )
		//thread SquadCapturePointThink( "squadIntroSpectres3", hardpointLobby, TEAM_IMC )
	}

	wait 3

	FlagSet( "IntroDone" )

	//----------------------
	// Resume AI spawning for IMC
	//----------------------
	FlagClear( "Disable_IMC" )	//intro done, can resume IMC ai spawning

}

function IntroIMCDialogue()
{
	//----------------------
	// IMC DROPSHIP SPEECH
	//----------------------

	//Triggered in Spyglass QC now
	//thread ForcePlayConversationToTeam( "CorporateIntroIMC_01", TEAM_IMC )

	//----------------------
	// RANDOM IMC GROUND CHATTER
	//----------------------
	FlagWait( "IMCPlayerOnGround" )

	local convRef
	local num = RandomInt( 1, 6 )
	switch ( num )
	{
		case 1:
			convRef = "CorporateGroundIMC_01"
			break
		case 2:
			convRef = "CorporateGroundIMC_02"
			break
		case 3:
			convRef = "CorporateGroundIMC_03"
			break
		case 4:
			convRef = "CorporateGroundIMC_04"
			break
		case 5:
			convRef = "CorporateGroundIMC_05"
			break
		default:
			Assert( 0, "CORPORATE: No dialogue with number " + num )
	}

	wait 2.8


	ForcePlayConversationToTeam( convRef, TEAM_IMC )

	wait 8

	FlagSet( "IntroDoneIMC" )

	wait 20

	//Female Computer Voice	: Warning. Three unauthorized network terminals detected. Militia Type 4 hardware profile. Notifying security personnel and shutting down production line.
	EmitSoundAtPosition( Vector( 1936, -1368, -328 ), "diag_sitFlavor_CR163_01_01_ntrl_bgpa" )
}


////////////////////////////////////////////////////////////////////////////////
function IntroSpectreEngageTitan( spectre )
{
	if ( !IsValid( spectre ) )
		return
	if ( !IsValid( level.titanIntroIMC ) )
		return
	if ( spectre.GetClassname() != "npc_spectre" )
		return

	spectre.EndSignal( "OnDeath" )
	local oldProficiency = spectre.kv.WeaponProficiency

	OnThreadEnd
	(
		function() : ( spectre, oldProficiency )
		{
			if ( IsValid( spectre ) )
			{
				spectre.kv.WeaponProficiency = oldProficiency
			}
		}
	)

	spectre.kv.WeaponProficiency = 4
	spectre.SetEfficientMode( false )
	//spectre.kv.alwaysalert = 1
	//spectre.kv.maxEnemyDist = 16000
	UpdateEnemyMemoryFromTeammates( spectre )
	UpdateEnemyMemory( spectre, level.titanIntroIMC )
	spectre.SetEnemy( level.titanIntroIMC )

	level.titanIntroIMC.WaitSignal( "Dying" )

}


//////////////////////////////////////////////////////////////////////////////
function IntroTitanSwarm()
{
	local animPos = Vector( 3760, -1928, -1024 )
	local animAng = Vector( 0, 0, 0 )
	local fxTitan = []


	//----------------------
	// Militia Titan/spectres hero spawn/idle
	//----------------------
	local titan = CreateNPCTitanFromSettings( "titan_atlas", TEAM_MILITIA, animPos, animAng )
	titan.GetTitanSoul().SetInvalidHealthBarEnt( true ) // disable critical hit locations

	titan.EndSignal( "OnDeath" )

	MakeInvincible( titan )
	level.titanIntroIMC <- titan

	titan.TakeActiveWeapon()

	DisableRodeo( titan )
	titan.SetEfficientMode( true )
	DisableTitanOverlays( titan )


	fxTitan.append( PlayFXOnEntity( FX_INTRO_TITAN_FIRE_DAMAGE, titan, "vent_left" ) )
	fxTitan.append( PlayFXOnEntity( FX_INTRO_TITAN_FIRE_DAMAGE2, titan, "dam_R_arm_upper" ) )



	local spectre1 = SpawnIntroNPC( "spectre", "squadIntroSpectresTitan1", TEAM_IMC, animPos, animAng, true )
	local spectre2 = SpawnIntroNPC( "spectre", "squadIntroSpectresTitan1", TEAM_IMC, animPos, animAng, true )
	local spectre3 = SpawnIntroNPC( "spectre", "squadIntroSpectresTitan1", TEAM_IMC, animPos, animAng, true )
	local spectre4 = SpawnIntroNPC( "spectre", "squadIntroSpectresTitan1", TEAM_IMC, animPos, animAng, true )
	local spectre5 = SpawnIntroNPC( "spectre", "squadIntroSpectresTitan2", TEAM_IMC, animPos, animAng, true )
	local spectre6 = SpawnIntroNPC( "spectre", "squadIntroSpectresTitan2", TEAM_IMC, animPos, animAng, true )

	AddAnimEvent( spectre1, "detach", ClearParentAndStopAnim )

	spectre1.SetParent( titan, "hijack" )
	spectre2.SetParent( titan, "hijack" )
	spectre3.SetParent( titan, "hijack" )
	spectre4.SetParent( titan, "hijack" )

	//----------------------
	// Idle until triggered
	//----------------------
	thread PlayAnim( titan, "at_titan_spectre_swarm_idle", animPos, animAng )

	spectre1.EndSignal( "OnDeath" )
	spectre2.EndSignal( "OnDeath" )
	spectre3.EndSignal( "OnDeath" )
	spectre4.EndSignal( "OnDeath" )
	spectre5.EndSignal( "OnDeath" )
	spectre6.EndSignal( "OnDeath" )

	spectre1.Anim_ScriptedPlay( "sp_titan_spectre_swarm_idle" )
	spectre1.Anim_EnableUseAnimatedRefAttachmentInsteadOfRootMotion()

	spectre2.Anim_ScriptedPlay( "sp_titan_spectre_swarm_2_idle" )
	spectre2.Anim_EnableUseAnimatedRefAttachmentInsteadOfRootMotion()

	spectre3.Anim_ScriptedPlay( "sp_titan_spectre_swarm_3_idle" )
	spectre3.Anim_EnableUseAnimatedRefAttachmentInsteadOfRootMotion()

	spectre4.Anim_ScriptedPlay( "sp_titan_spectre_swarm_4_idle" )
	spectre4.Anim_EnableUseAnimatedRefAttachmentInsteadOfRootMotion()

	thread PlayAnim( spectre5, "sp_titan_spectre_swarm_groundA_idle", animPos, animAng )
	thread PlayAnim( spectre6, "sp_titan_spectre_swarm_groundB_idle", animPos, animAng )

	FlagWait( "IMCDropshipsIncoming" )
	wait 9

	thread SetSignalDelayed( titan, "Dying", 6 )

	thread PlayAnim( titan, "at_titan_spectre_swarm", animPos, animAng )

	spectre1.Anim_ScriptedPlay( "sp_titan_spectre_swarm" )
	spectre1.Anim_EnableUseAnimatedRefAttachmentInsteadOfRootMotion()

	spectre2.Anim_ScriptedPlay( "sp_titan_spectre_swarm_2" )
	spectre2.Anim_EnableUseAnimatedRefAttachmentInsteadOfRootMotion()

	spectre3.Anim_ScriptedPlay( "sp_titan_spectre_swarm_3" )
	spectre3.Anim_EnableUseAnimatedRefAttachmentInsteadOfRootMotion()

	//guy who jumps on and is then ripped off
	spectre4.Anim_ScriptedPlay( "sp_titan_spectre_swarm_4" )
	spectre4.Anim_EnableUseAnimatedRefAttachmentInsteadOfRootMotion()

	//Ground spectres
	thread PlayAnim( spectre5, "sp_titan_spectre_swarm_groundA", animPos, animAng )	// gets backhanded across the level
	thread PlayAnim( spectre6, "sp_titan_spectre_swarm_groundB", animPos, animAng )	// runs around the titans feet shooting up

	//spectre1.WaittillAnimDone()

	//spectre1.ClearParent()
	//spectre2.ClearParent()
	//spectre3.ClearParent()
	//spectre4.ClearParent()


}

function ClearParentAndStopAnim( npc )
{
	if ( !IsAlive ( npc ) )
		return
	npc.ClearParent()
	npc.Anim_Stop()
	//PlayAnimGravity( npc, "pt_zipline_land", npc.GetOrigin(), npc.GetAngles() )
}

function SetSignalDelayed( npc, signal, delay )
{
	wait delay
	if ( IsValid( npc ) )
		npc.Signal( signal )
}

///////////////////////////////////////////////////////////////////////////////
function SpectreIntroReset( spectre )
{
	spectre.EndSignal( "OnDeath" )

	spectre.Signal( "SpectreReset" )
	spectre.Signal( "ShowTitle" )
	spectre.Anim_Stop()
	spectre.ClearMoveAnim()
	spectre.SetEfficientMode( false )
}

///////////////////////////////////////////////////////////////////////////////
function IntroSpectreLeaper( squadName, pos, ang, walkPos = null, flagToStart = null, delay = 0 )
{
	local spectre = SpawnIntroNPC( "spectre", squadName, TEAM_IMC, pos, ang, true )

	spectre.EndSignal( "OnDeath" )

	thread PlayAnim( spectre, "sp_casual_idle", pos, ang )

	if ( flagToStart )
		FlagWait( flagToStart )

	wait delay

	spectre.Anim_Stop()

	waitthread PlayAnim( spectre, "sp_bldg_traverse_down_670", pos, ang )
	local pos = spectre.GetOrigin()

	if ( walkPos )
		waitthread GotoOrigin( spectre, walkPos  )
	thread IntroSpectreEngageTitan( spectre )

	return spectre

}

//////////////////////////////////////////////////////////////////////////////
function IntroSpectreGround( squadName, pos, ang, walkPos = null, delay = 0 )
{
	local spectre = SpawnIntroNPC( "spectre", squadName, TEAM_IMC, pos, ang, true )

	spectre.EndSignal( "OnDeath" )

	GotoOrigin( spectre, spectre.GetOrigin()  )

	//FlagWait( "GamePlaying" )
	FlagWait( "ReadyToStartMatch" )

	wait delay

	if ( walkPos )
		waitthread GotoOrigin( spectre, walkPos  )
	thread IntroSpectreEngageTitan( spectre )

}

///////////////////////////////////////////////////////////////////////////////////////////////////
function IntroIMCSetup()
{
	//initialTime = 4

	local animEnt1 = CreateScriptRef( Vector( 4776, -1640, -1010 ), Vector( 0, 186, 0 ) )

	local table				= CreateCinematicDropship()
	table.origin 			= animEnt1.GetOrigin()
	table.team				= TEAM_IMC
	table.count 			= 4
	table.side 				= "jumpQuick"
	table.turret			= false

	local event0			= CreateCinematicEvent()
	event0.origin 			= animEnt1.GetOrigin()
	event0.angles			= animEnt1.GetAngles()
	event0.anim				= "dropship_corporate_flyin_imc_L_idle"
	//event0.anim				= "dropship_player_intro_idle"
	event0.teleport 		= true
	Event_AddFlagWaitToEnd( event0, "StartIMCDropships" )
	Event_AddClientStateFunc( event0, "CE_BloomOnRampOpenCorporateIMC" )
	Event_AddServerStateFunc( event0, CE_PlayerSkyScaleCorporateIMC )
	Event_AddServerStateFunc( event0, CE_PlayerSkyScaleCorporateOnRampOpenIMC )

	local event1			= CreateCinematicEvent()
	event1.origin 			= animEnt1.GetOrigin()
	event1.angles			= animEnt1.GetAngles()
	//event1.anim				= "dropship_angelcity_flyin_imc_L"
	event1.anim				= "dropship_corporate_flyin_imc_L"
	Event_AddFlagSetOnEnd( event1, "IntroDropshipDoneIMC" )
	Event_AddAnimStartFunc( event1, IntroIMCHeroes )
	Event_AddClientStateFunc( event1, "CE_VisualSettingCorporateIMC" )

	AddSavedDropEvent( "introDropShipIMC_1cr", table )
	AddSavedDropEvent( "introDropShipIMC_1e0", event0 )
	AddSavedDropEvent( "introDropShipIMC_1e1", event1 )

	local animEnt2 = CreateScriptRef( Vector( 4840, -1928, -1010 ), Vector( 0, 186, 0 ) )
	//local animEnt2 = animEnt1

	local table				= CreateCinematicDropship()
	table.origin 			= animEnt2.GetOrigin()
	table.team				= TEAM_IMC
	table.count 			= 4
	table.side 				= "jumpQuick"
	table.turret			= false

	local event0			= CreateCinematicEvent()
	event0.origin 			= animEnt2.GetOrigin()
	event0.angles			= animEnt2.GetAngles()
	event0.anim				= "dropship_corporate_flyin_imc_R_idle"
	//event0.anim				= "dropship_player_intro_idle"
	event0.teleport 		= true
	Event_AddFlagWaitToEnd( event0, "StartIMCDropships" )
	Event_AddClientStateFunc( event0, "CE_BloomOnRampOpenCorporateIMC" )
	Event_AddServerStateFunc( event0, CE_PlayerSkyScaleCorporateIMC )
	Event_AddServerStateFunc( event0, CE_PlayerSkyScaleCorporateOnRampOpenIMC )

	local event1 			= CreateCinematicEvent()
	event1.origin 			= animEnt2.GetOrigin()
	event1.angles			= animEnt2.GetAngles()
	event1.anim				= "dropship_corporate_flyin_imc_R"
	//event1.anim			= "dropship_angelcity_flyin_imc_R"
	Event_AddAnimStartFunc( event1, IntroIMCHeroes )
	Event_AddClientStateFunc( event1, "CE_VisualSettingCorporateIMC" )

	AddSavedDropEvent( "introDropShipIMC_2cr", table )
	AddSavedDropEvent( "introDropShipIMC_2e0", event0 )
	AddSavedDropEvent( "introDropShipIMC_2e1", event1 )
}

function IntroDropshipIMC()
{
	local table 	= GetSavedDropEvent( "introDropShipIMC_1cr" )
	local event0 	= GetSavedDropEvent( "introDropShipIMC_1e0" )
	local event1 	= GetSavedDropEvent( "introDropShipIMC_1e1" )

	local dropship1 = SpawnCinematicDropship( table )
	thread RunCinematicDropship( dropship1, event0, event1 )

	local table 	= GetSavedDropEvent( "introDropShipIMC_2cr" )
	local event0 	= GetSavedDropEvent( "introDropShipIMC_2e0" )
	local event1 	= GetSavedDropEvent( "introDropShipIMC_2e1" )

	local dropship2	= SpawnCinematicDropship( table )
	thread RunCinematicDropship( dropship2, event0, event1 )


	thread IntroIMCExperience( dropship1, dropship2 )

	DebugSkipCinematicSlotsWithBugRepro( TEAM_IMC )
	//DebugSkipCinematicSlots( TEAM_IMC, 0 )
	//0 - back
	//1 - back middle
	//2 - front middle
	//3 - front

}

function IntroIMCHeroes( dropship, ref, table )
{
	dropship.EndSignal( "OnDeath" )

	local pilot = CreatePropDynamic( TEAM_IMC_GRUNT_MDL )
	local spyglass = CreatePropDynamic( SPYGLASS_MODEL )

	pilot.SetParent( dropship, "ORIGIN" )
	spyglass.SetParent( dropship, "ORIGIN" )
	pilot.MarkAsNonMovingAttachment()
	spyglass.MarkAsNonMovingAttachment()

	pilot.LerpSkyScale( SKYSCALE_CORPORATE_IMC_ACTOR, 1 )
	spyglass.LerpSkyScale( SKYSCALE_CORPORATE_IMC_ACTOR, 1 )

	thread PlayAnimTeleport( pilot, "Militia_flyinA_idle_mac", dropship, "ORIGIN" )
	thread PlayAnimTeleport( spyglass, "pt_corporate_flyin_exit_spyglass", dropship, "ORIGIN" )

	dropship.WaitSignal( "sRampOpen" )

	pilot.LerpSkyScale( SKYSCALE_CORPORATE_DOOROPEN_IMC_ACTOR, 1 )
	spyglass.LerpSkyScale( SKYSCALE_CORPORATE_DOOROPEN_IMC_ACTOR, 1 )
}

function IntroMilitiaHeroes( dropship, ref, table )
{

	local pos = dropship.GetOrigin()
	local ang = dropship.GetAngles()

	local pilot = CreatePropDynamic( TEAM_MILITIA_GRUNT_MDL )
	local graves = CreatePropDynamic( GRAVES_MODEL )

	pilot.SetParent( dropship, "ORIGIN" )
	graves.SetParent( dropship, "ORIGIN" )

	pilot.MarkAsNonMovingAttachment()
	graves.MarkAsNonMovingAttachment()

	pilot.LerpSkyScale( SKYSCALE_CORPORATE_MCOR_ACTOR, 1 )
	graves.LerpSkyScale( SKYSCALE_CORPORATE_MCOR_ACTOR, 1 )

	thread PlayAnimTeleport( pilot, "Militia_flyinA_idle_mac", dropship, "ORIGIN" )
	thread PlayAnimTeleport( graves, "corporate_militia_intro_graves", dropship, "ORIGIN" )

}
///////////////////////////////////////////////////////////////////////////////////////////////////
function IntroIMCExperience( dropship1, dropship2 )
{
	printt( "******************************************************" )
	printt( "************Playing IMC dropship sounds****************" )
	printt( "******************************************************" )
	PlaySoundToAttachedPlayers( dropship1, SFX_DROPSHIP_PLAYER_ENGINE_IMC )
	PlaySoundToAttachedPlayers( dropship2, SFX_DROPSHIP_PLAYER_ENGINE_IMC )

}


/*----------------------------------------------------------------------------------
/
/				INTRO - MILITIA
/
/-----------------------------------------------------------------------------------*/
function AA_Intro_Militia_functions()
{
	//Bookmark to jump to this section
}

////////////////////////////////////////////////////////////////////////////////////////////////
function IntroMilitia()
{
	if ( !GetCinematicMode() )
		return
	FlagSet( "Disable_MILITIA" )//don't spawn any grunts until get close

	local animPos = Vector( -88, -88, -775 )
	local animAng = Vector( 0, 0, 0 )

	//----------------------
	// Player dropship
	//----------------------
	thread IntroDropshipMilitia()
	//thread IntroDropships( TEAM_MILITIA, "StartMilitiaDropships" )
	//SpawnOnGround( TEAM_MILITIA )

	//----------------------
	// Titan Dropship rodeo spawn/idle
	//----------------------
	thread IntroMilitiaDropshipRodeo( "StartMilitiaDropshipEvents", animPos, animAng )

	//delaythread ( 1.5 ) IntroMilitiaDialogue()

	FlagWait( "TitanIntroMilitiaSpawned" )

	//----------------------
	// Ground troop skits
	//----------------------
						//skitType, 	pos, 					  ang, 					team, 		  flagTrigger		  walkpos, delay
	thread IntroSkit( "spectreLoot", "squadIntroGrunts1", Vector( -128, -224, -1024 ), Vector( 0, 195.2, 0 ), TEAM_MILITIA, null, "IntroStartMilitiaGround", 8, IntroMilitiaGruntsAssaltTitan )
	//thread IntroSkit( "patrolSurprise1", "squadIntroGrunts1", Vector( -749, -279, -693 ), Vector( 0, 0, 0 ), TEAM_MILITIA, null, "IntroStartMilitiaGround", 0, IntroMilitiaGruntsAssaltTitan )
	thread IntroSkit( "spectreCrawl", "squadIntroGrunts1", Vector( -872, -296, -694 ), Vector( 0, 250, 0 ), TEAM_MILITIA, null, "StartMilitiaDropshipEvents", 4, IntroMilitiaGruntsAssaltTitan )
	thread IntroSkit( "spectreZombie", "squadIntroGrunts1", Vector( -719.949, -194.696, -692.429 ), Vector( 0, 52, 0 ), TEAM_MILITIA, null, "StartMilitiaDropshipEvents", 4, IntroMilitiaGruntsAssaltTitan )
	//thread IntroSkit( "spectreLeaper", UniqueString(), Vector( -501.766 -1615 -18 ), Vector( 0, 95.0932, 0 ), TEAM_IMC, null, "IntroStartMilitiaGround", 0.75 )
	//thread IntroSkit( "spectreLeaper", UniqueString(), Vector( 688.408, 603.64, -18 ), Vector( 0, 95.0932, 0 ), TEAM_IMC, null, "IntroStartMilitiaGround", 0.75 )
	thread IntroSkit( "multikillMilitia", "squadIntroGrunts1", Vector( -848, -424, -688 ), Vector( 0, 250, 0 ), TEAM_MILITIA, null, "IntroStartMilitiaGround", 2 )
	thread SpectreKiller()

	FlagWait( "ReadyToStartMatch" )
	//FlagWait( "GamePlaying" )

	wait 1.7

	FlagSet( "StartMilitiaDropships" )

	wait 4.3

	FlagSet( "StartMilitiaDropshipEvents" )

	wait 2

	FlagSet( "IntroStartMilitiaGround" )

	wait 5

	FlagClear( "Disable_MILITIA" )

	FlagWait( "IntroDone" )

	//---------------------------------------------
	// Make any remaining skit AI go into hardpoint mode
	//---------------------------------------------
	//ScriptedSquadAssault( "squadIntroGrunts1", 0 )
	//ScriptedSquadAssault( "squadIntroGrunts2", 1 )

}

///////////////////////////////////////////////////////////////////////////////////////////////////
function IntroMilitiaExperience( dropship1, dropship2 )
{
	PlaySoundToAttachedPlayers( dropship1, SFX_DROPSHIP_PLAYER_ENGINE_MILITIA )
	PlaySoundToAttachedPlayers( dropship2, SFX_DROPSHIP_PLAYER_ENGINE_MILITIA )

}




/////////////////////////////////////////////////////////////////////////
function IntroMilitiaSetup()
{
	local animEnt1 = CreateScriptRef( Vector( -88, -88, -775 ), Vector( 0, 0, 0 ) )

	local table				= CreateCinematicDropship()
	table.origin 			= animEnt1.GetOrigin()
	table.team				= TEAM_MILITIA
	table.count 			= 4
	table.side 				= "jumpSideR"
	table.turret			= false

	local event0			= CreateCinematicEvent()
	event0.origin 			= animEnt1.GetOrigin()
	event0.angles			= animEnt1.GetAngles()
	event0.anim				= "dropship_corporate_mcor_intro_flyin_A_idle"
	event0.teleport 		= true
	Event_AddFlagWaitToEnd( event0, "StartMilitiaDropships" )
	Event_AddClientStateFunc( event0, "CE_VisualSettingCorporateMCOR" )
	Event_AddServerStateFunc( event0, CE_PlayerSkyScaleCorporateMCOR )

	local event1			= CreateCinematicEvent()
	event1.origin 			= animEnt1.GetOrigin()
	event1.angles			= animEnt1.GetAngles()
	event1.anim				= "dropship_corporate_mcor_intro_flyin_A"
	Event_AddFlagSetOnEnd( event1, "IntroDropshipDoneMilitia" )
	Event_AddAnimStartFunc( event1, IntroMilitiaHeroes )

	local event2 			= CreateCinematicEvent()
	event2.anim				= "dropship_corporate_mcor_intro_warpout_A"
	event2.origin 			= animEnt1.GetOrigin()
	event2.angles			= animEnt1.GetAngles()

	AddSavedDropEvent( "introDropShipMCOR_1cr", table )
	AddSavedDropEvent( "introDropShipMCOR_1e0", event0 )
	AddSavedDropEvent( "introDropShipMCOR_1e1", event1 )
	AddSavedDropEvent( "introDropShipMCOR_1e2", event2 )

	//local animEnt2 = CreateScriptRef( Vector( -29, 250, -600 ), Vector( 0, 0, 0 ) )
	local animEnt2 = animEnt1

	local table				= CreateCinematicDropship()
	table.origin 			= animEnt2.GetOrigin()
	table.team				= TEAM_MILITIA
	table.count 			= 4
	table.side 				= "jumpSideR"
	table.turret			= false

	local event0			= CreateCinematicEvent()
	event0.origin 			= animEnt2.GetOrigin()
	event0.angles			= animEnt2.GetAngles()
	event0.anim				= "dropship_corporate_mcor_intro_flyin_B_idle"
	event0.teleport 		= true
	Event_AddFlagWaitToEnd( event0, "StartMilitiaDropships" )
	Event_AddClientStateFunc( event0, "CE_VisualSettingCorporateMCOR" )
	Event_AddServerStateFunc( event0, CE_PlayerSkyScaleCorporateMCOR )

	local event1 			= CreateCinematicEvent()
	event1.origin 			= animEnt2.GetOrigin()
	event1.angles			= animEnt2.GetAngles()
	event1.anim				= "dropship_corporate_mcor_intro_flyin_B"
	Event_AddAnimStartFunc( event1, IntroMilitiaHeroes )

	local event2 			= CreateCinematicEvent()
	event2.anim				= "dropship_corporate_mcor_intro_warpout_B"
	event2.origin 			= animEnt2.GetOrigin()
	event2.angles			= animEnt2.GetAngles()

	AddSavedDropEvent( "introDropShipMCOR_2cr", table )
	AddSavedDropEvent( "introDropShipMCOR_2e0", event0 )
	AddSavedDropEvent( "introDropShipMCOR_2e1", event1 )
	AddSavedDropEvent( "introDropShipMCOR_2e2", event2 )
}

function CE_PlayerSkyScaleCorporateMCOR( player, dropship )
{
	player.LerpSkyScale( SKYSCALE_CORPORATE_MCOR_PLAYER, 0.01 )
}

function CE_PlayerSkyScaleCorporateIMC( player, dropship )
{
	player.LerpSkyScale( SKYSCALE_CORPORATE_IMC_PLAYER, 0.01 )
}

function CE_PlayerSkyScaleCorporateOnRampOpenIMC( player, dropship )
{
	thread playerLerpSkyScaleOnSignal( player, dropship, "sRampOpen", SKYSCALE_CORPORATE_DOOROPEN_IMC_PLAYER, 1.0 )
}

function IntroDropshipMilitia()
{
	local table 	= GetSavedDropEvent( "introDropShipMCOR_1cr" )
	local event0 	= GetSavedDropEvent( "introDropShipMCOR_1e0" )
	local event1 	= GetSavedDropEvent( "introDropShipMCOR_1e1" )
	local event2 	= GetSavedDropEvent( "introDropShipMCOR_1e2" )

	local dropship1 = SpawnCinematicDropship( table )
	thread RunCinematicDropship( dropship1, event0, event1, event2 )


	local table 	= GetSavedDropEvent( "introDropShipMCOR_2cr" )
	local event0 	= GetSavedDropEvent( "introDropShipMCOR_2e0" )
	local event1 	= GetSavedDropEvent( "introDropShipMCOR_2e1" )
	local event2 	= GetSavedDropEvent( "introDropShipMCOR_2e2" )

	local dropship2	= SpawnCinematicDropship( table )
	thread RunCinematicDropship( dropship2, event0, event1, event2 )

	thread IntroMilitiaExperience( dropship1, dropship2 )

	DebugSkipCinematicSlotsWithBugRepro( TEAM_MILITIA )
	//DebugSkipCinematicSlots( TEAM_MILITIA, 4 )
	//0 - back
	//1 - back middle
	//2 - front middle
	//3 - front

}

//////////////////////////////////////////////////////////////////////
function SpectreKiller()
{
	local node = SpawnAnimRef(  Vector( -794, -516, -694 ), Vector( 0, 110, 0 ) )
	FlagWait( "IntroStartMilitiaGround" )

	wait 2.5

	local grunt = SpawnIntroNPC( "grunt", "squadIntroGrunts2", TEAM_MILITIA , Vector( -824, 128, -696 ), Vector( 0, -120, 0 ), true )
	grunt.SetEfficientMode( true )

	grunt.EndSignal( "OnDeath" )

	AddAnimEvent( grunt, "shotgunfired", SpectreKillerShoots )
	grunt.TakeActiveWeapon()
	grunt.GiveWeapon( "mp_weapon_shotgun" )
	waitthread RunToAnimStartForced( grunt, "pt_shotgun_wallslam_skit_B", node )

	waitthread PlayAnim( grunt, "pt_shotgun_wallslam_skit_B", node )

	grunt.SetEfficientMode( false )

	grunt.TakeActiveWeapon()
	grunt.GiveWeapon( "mp_weapon_rocket_launcher" )
	grunt.SetMaxHealth( 1 )
	grunt.SetHealth( 1 )
	thread IntroMilitiaGruntsAssaltTitan( grunt )

	//Grunt_1	Titan!!
	EmitSoundAtPosition( grunt.GetOrigin(), "diag_hp_matchIntro_CR103_04_01_mcor_grunt1" )

}

function SpectreKillerShoots( grunt )
{
	local spectre = GetEnt( "SpectreIntroMilitia01" )
	if ( !IsAlive( spectre ) )
		return
	local pos = spectre.GetOrigin()
	//EmitSoundAtPosition( pos, SFX_SPECTRE_NEUTRALIZED )
	PlayFX( FX_SPECTRE_DEACTIVATED_SPARKS, pos, Vector( 0, 0, 0 ) )
	SetDeathFuncName( spectre, "SpectreShotgunDeath" )
	spectre.Die()
}

function SpectreShotgunDeath( spectre )
{
	spectre.Anim_Play( "CQB_Death_headshot_kneespin" )
	WaitSignalOnDeadEnt( spectre, "OnAnimationDone" )
	spectre.BecomeRagdoll( Vector( 0, 0, 0 ) )
}

//function IntroMilitiaDialogue()
//{
//	// Triggered in QC for Graves now
//	//ForcePlayConversationToTeam( "CorporateIntroMilitia_01", TEAM_MILITIA )
//}

function IntroMilitiaGruntsAssaltTitan( grunt )
{
	if ( !IsValid( grunt ) )
		return
	if ( !IsValid( level.titanIntroMilitia ) )
		return
	if ( grunt.GetClassname() != "npc_soldier" )
		return

	grunt.kv.alwaysalert = 1
	grunt.kv.maxEnemyDist = 16000
	UpdateEnemyMemoryFromTeammates( grunt )
	UpdateEnemyMemory( grunt, level.titanIntroMilitia )
	grunt.SetEnemy( level.titanIntroMilitia )

}


function IntroMilitiaDropshipRodeo( flagToStart, animPos, animAng )
{
	//------------------------------------
	// IMC Titan that rodeos the dropship
	//-----------------------------------
	local table 	= CreateDefaultNPCTitanTemplate( TEAM_IMC )
	table.title 	= "IMC Titan"
	table.weapon	= "mp_titanweapon_40mm"
	table.origin 	= animPos
	table.angles 	= animAng
	local titan = SpawnNPCTitan( table )
	printt( titan.GetName() )
	titan.GetTitanSoul().SetInvalidHealthBarEnt( true ) // disable critical hit locations
	titan.SetEfficientMode( true )
	MakeInvincible( titan )
	DisableTitanOverlays( titan )
	DisableRodeo( titan )
	AddAnimEvent( titan, "exo_land_dropship", exo_land_dropship )
	AddAnimEvent( titan, "exo_punches_cockpit", exo_punches_cockpit )
	AddAnimEvent( titan, "exo_rips_pilot_out", exo_rips_pilot_out )
	//AddAnimEvent( titan, "exo_lands_on_ground", exo_lands_on_ground )
	titan.Hide()
	level.titanIntroMilitia <- titan

	FlagSet( "TitanIntroMilitiaSpawned" )

	//--------------------
	// Dropship and pilot
	//---------------------
	local dropship = SpawnAnimatedDropship( animPos, TEAM_MILITIA )
	level.dropshipRodeo <- dropship
	dropship.SetEfficientMode( true )
	HideName( dropship )
	AddAnimEvent( dropship, "dropship_hits_prop", dropship_hits_prop )
	dropship.Hide()
	EmitSoundOnEntityToTeam( dropship, SFX_DROPSHIP_RODEO_ENGINE, TEAM_MILITIA )

	local dropshipPilot = CreatePropDynamic( DROPSHIP_PILOT_MODEL, animPos, animAng )
	AddAnimEvent( dropshipPilot, "pilot_thrown", pilot_thrown )
	dropshipPilot.Hide()
	level.dropshipPilot <- dropshipPilot

	//---------------------------------------------
	// Hero AI that will shoot titan after he finishes
	//---------------------------------------------
	local gruntTitanKiller = SpawnGrunt( TEAM_MILITIA, UniqueString(), Vector( -296, 2256, -676 ), Vector( 0, 30.6981, 0 ) )
	local gruntTitanKiller2 = SpawnGrunt( TEAM_MILITIA, UniqueString(), Vector( -582, 1468, -1162 ), Vector( 0, 0, 0 ) )
	local gruntTitanKiller3 = SpawnGrunt( TEAM_MILITIA, UniqueString(), Vector( 396, 934, -744 ), Vector( 0, 0, 0 ) )

	thread HuntEnemyOnFlagSet( gruntTitanKiller, titan, "IntroDoneMilitia" )
	thread HuntEnemyOnFlagSet( gruntTitanKiller2, titan, "IntroDoneMilitia" )
	thread HuntEnemyOnFlagSet( gruntTitanKiller3, titan, "IntroDoneMilitia" )

	//----------------------
	// Idle till triggered
	//----------------------
	thread PlayAnim( titan, "at_jump_goblin_idle", animPos, animAng )
	thread PlayAnim( dropship, "gb_atlas_attack_idle", animPos, animAng )
	thread PlayAnim( dropshipPilot, "pt_atlas_grab_idle", animPos, animAng )

	FlagWait( flagToStart )

	//----------------------
	// Run intro sequence
	//----------------------
	dropship.Show()
	titan.Show()
	thread PlayAnim( titan, "at_jump_goblin", animPos, animAng )
	thread PlayAnim( dropship, "gb_atlas_attack", animPos, animAng )
	thread PlayAnim( dropshipPilot, "pt_atlas_grab", animPos, animAng )


	titan.WaitSignal( "OnAnimationDone" )

	FlagSet( "IntroDoneMilitia" )

	DeleteIfValid( dropship )
	DeleteIfValid( dropshipPilot )

	//----------------------
	// Titan made vulnerable to remaining grunts
	//----------------------
	if ( !IsAlive( titan ) )
		return

	titan.EndSignal( "OnDeath" )

	thread DialogueDropshipTitanKilled( titan )


	titan.SetEfficientMode( false )
	EnableRodeo( titan )
	titan.SetTitle( "#NPC_TITAN_IMC" )
	titan.SetShortTitle( "#NPC_TITAN_IMC" )

	local assaultPos = Vector( 168, 552, -1024 )

	titan.AssaultPoint( assaultPos )

	wait 2

	ClearInvincible( titan )
	titan.SetMaxHealth( 1 )
	titan.SetHealth( 1 )

	wait 10

	titan.Die()	//failsafe
}

function DialogueDropshipTitanKilled( titan )
{
	titan.WaitSignal( "OnDeath" )
	wait 1

	local npcs = GetNPCArrayByClass( "npc_soldier" )
	if ( npcs.len() == 0 )
		return

	local speaker = GetClosest( npcs, Vector( -88, -88, -775 ) )

	if ( !speaker )
		return

	speaker.EndSignal( "OnDeath" )

	//Got him, titan down.
	local duration = EmitSoundOnEntityToTeam( speaker, "diag_hp_matchIntro_CR182_01_01_mcor_grunt1", TEAM_MILITIA )

	wait duration
	wait 1.75

	//Copy that two two.
	EmitSoundOnEntityToTeam( speaker, "diag_hp_matchIntro_CR183_01_01_mcor_grunt2", TEAM_MILITIA )
}


function HuntEnemyOnFlagSet( npc, enemy, flagToStart )
{
	npc.EndSignal( "OnDeath" )

	local oldAlert = npc.kv.alwaysalert
	local oldMaxEnemyDist = npc.kv.alwaysalert
	local oldAccuracyMultiplier = npc.kv.AccuracyMultiplier
	local enemyIsTitan = false
	local stayPutPos = npc.GetOrigin()

	if ( enemy.IsNPC() && enemy.IsTitan() )
		enemyIsTitan = true

	npc.AllowFlee( false )
	npc.AllowHandSignals( false )
	npc.SetEfficientMode( true )
	npc.AssaultPoint( stayPutPos )
	npc.StayPut( true )
	//npc.DisableBehavior( "Assault" )

	FlagWait( flagToStart )

	if ( !IsAlive( enemy ) )
		return

	//---------------------
	// alter stats for quick kill
	//---------------------
	npc.SetEfficientMode( false )
	npc.kv.alwaysalert = 1
	npc.kv.maxEnemyDist = 20000
	npc.kv.AccuracyMultiplier = 3.0
	UpdateEnemyMemoryFromTeammates( npc )
	UpdateEnemyMemory( npc, enemy )
	npc.SetEnemy( enemy )
	npc.StayPut( false )
	//npc.AssaultPoint( stayPutPos )

	//npc.WaitSignal( "OnFinishedAssault" )
	//npc.StayPut( true )

	if ( enemyIsTitan )
	{
		npc.TakeActiveWeapon()
		npc.GiveWeapon( "mp_weapon_rocket_launcher" )
		npc.s.useRPGPreference = RPG_USE_ALWAYS
	}

	while( IsAlive( enemy ) )
	{
		wait 0.5
		npc.SetEnemy( enemy )
		//if ( stayPut )
			//npc.AssaultPoint( stayPutPos )
	}

	//---------------------
	// reset default stats
	//---------------------
	npc.AllowFlee( true )
	npc.AllowHandSignals( true )
	npc.kv.alwaysalert = oldAlert
	npc.kv.maxEnemyDist = oldMaxEnemyDist
	npc.kv.AccuracyMultiplier = oldAccuracyMultiplier
	npc.SetMaxHealth( 1 )
	npc.SetHealth( 1 )
}

/////////////////////////////////////////////////////////////////////////////////////////////

function exo_land_dropship( titan )
{
	CreateShake( titan.GetOrigin(), 8, 100, 1, 2048 )
	delaythread ( 0.5 ) DropshipRodeoPilotDialogue()
}

function DropshipRodeoPilotDialogue()
{
	local alias
	if ( CoinFlip() )
	{
		//(RADIO) We're going down! Everyone, bail out, now! We're going down!
		alias = "diag_hp_matchIntro_CR181_01_01_mcor_grunt1"
	}
	else
	{
		//(RADIO) Mayday! Mayday! Bail out! Repeat….
		alias = "diag_hp_matchIntro_CR180_01_01_mcor_grunt1"
	}
	EmitSoundOnEntityToTeam( level.dropshipRodeo, alias, TEAM_MILITIA )
	FlagWait( "TitanPunchesCockpit" )
	wait 0.75
	StopSoundOnEntity( level.dropshipRodeo, alias )
	EmitSoundOnEntityToTeam( level.dropshipRodeo, SFX_RADIO_STATIC, TEAM_MILITIA )
}
///////////////////////////////////////////////////////
function EmitSoundOnEntityToTeam( ent, sound, team )
{
	local players = GetPlayerArrayOfTeam( team )

	foreach ( player in players )
		EmitSoundOnEntityOnlyToPlayer( ent, player, sound )
}
///////////////////////////////////////////////////////
function EmitSoundAtPositionToTeam( pos, sound, team )
{
	local players = GetPlayerArrayOfTeam( team )

	foreach ( player in players )
		EmitSoundAtPositionOnlyToPlayer( pos, player, sound )
}
//////////////////////////////////////////////////////
function exo_punches_cockpit( titan )
{
	FlagSet( "TitanPunchesCockpit" )
	CreateShake( titan.GetOrigin(), 8, 100, 1, 2048 )
	//PlayFXOnEntity( FX_DROPSHIP_COCKPIT_SMASH, level.dropshipRodeo, "IntLightCockpit1", Vector( 180, 0, 0 ) )
	//EmitSoundOnEntity( titan, SFX_DROPSHIP_RODEO_COCKPIT_PUNCH )
	level.dropshipPilot.Show()
}

function exo_rips_pilot_out( titan )
{
	//EmitSoundOnEntity( titan, SFX_DROPSHIP_RODEO_PILOT_RIP )
	//PlayFXOnEntity( FX_DROPSHIP_COCKPIT_SMASH, level.dropshipRodeo, "IntLightCockpit1", Vector( 0, 180, 0 ) )
}

function pilot_thrown( soldier )
{
	//EmitSoundOnEntity( soldier, SFX_DROPSHIP_RODEO_PILOT_SCREAM )
}

function dropship_hits_prop( dropship )
{
	thread dropship_hits_prop_thread( dropship )
}

function dropship_hits_prop_thread( dropship )
{
	local tagID = dropship.LookupAttachment( "ORIGIN" )
	local pos = dropship.GetAttachmentOrigin( tagID )

	//local pos = dropship.GetOrigin()

	CreateShake( pos, 16, 150, 2.5, 3000 )
	PlayFX( FX_DROPSHIP_CRASH, pos )
	EmitSoundAtPositionToTeam( pos, SFX_DROPSHIP_RODEO_CRASH, TEAM_MILITIA )
	dropship.Die()
}

function exo_lands_on_ground( titan )
{
	if ( IsValid( titan ) )
		titan.Kill()
	if ( IsValid( level.dropshipPilot ) )
		level.dropshipPilot.Kill()
}

/*----------------------------------------------------------------------------------
/
/				EVAC/EPILOGUE
/
/-----------------------------------------------------------------------------------*/
function AA_Evac_functions()
{
	//Bookmark to jump to this section
}

//////////////////////////////////////////////////////////
function EvacSetup()
{

	//------------------------------------------------------
	// Default evac stuff for both cinematic and classic
	//------------------------------------------------------

	Evac_SetRoundEndSetupFunc( EvacSetupRoundEnd )

	// Manually add these so I can trigger by number to test
	local evacLabs = GetEnt( "evacLabs" )
	local evacAssemblyRoof = GetEnt( "evacAssemblyRoof" )
	local evacOffice = GetEnt( "evacOffice" )
	local evacSkybridge = GetEnt( "evacSkybridge" )
	local evacOffice2 = GetEnt( "evacOffice2" )
	Assert( evacLabs != null )
	Assert( evacAssemblyRoof != null )
	Assert( evacLabs != null )
	Assert( evacSkybridge != null )
	Assert( evacOffice2 != null )


	local verticalAnims = Evac_CreateAnimPackage( "dropship_VTOL_evac_start", "dropship_VTOL_evac_idle", "dropship_VTOL_evac_end" )

	Evac_AddLocation( "evacLabs", Vector( 1280.040649, -2764.959473, -169.014130 ), Vector( 14.181284, 48.997429, 0 ) )
	Evac_AddLocation( "evacAssemblyRoof", Vector( 462.380127, 2277.902832, 275.741028 ), Vector( 23.500288, 51.044209, -0.000004 ), verticalAnims )
	Evac_AddLocation( "evacOffice", Vector( 194.665588, 335.548370, -54.430099), Vector( 21.007761, -127.736145, 0 ) )

	//----------------------------------------------
	// Only add these 2 evacs if it's NOT cinematic MP
	//----------------------------------------------
	if ( !level.playCinematicContent )
	{
		//Evac locations used for exfil game mode (and anything besides cinematic hardpoints)
		Evac_AddLocation( "evacSkybridge", Vector( 2649.794434, -1904.816040, -8.484831 ), Vector( 23.176687, 122.673111, -0.000006 ) )
		Evac_AddLocation( "evacOffice2", Vector( 750.429260, 2734.310547, -194.741791 ), Vector( 29.665993, -32.754963, -0.000006 ) )

	}
	Evac_SetupDefaultVDUs()


	//----------------------------------------------
	// CINEMATIC MODE ONLY
	//----------------------------------------------

	if ( level.playCinematicContent )
	{
		Evac_SetPostEvacDialogueTime( POSTEPILOGUETIME + POSTDIALOGUETIME )
		Evac_SetCustomDropshipFunc( EvacCustomDropshipFunc )

		//----------------------------------------------
		// Spectre spawn locations on assembly line bldg
		//----------------------------------------------
		level.spectreSpawns[ "assemblyLineQualityControl" ] <- []
		//level.spectreSpawns[ "assemblyLineQualityControl" ].append( Vector ( 1064.497437, 3608.000000, -440.000000 ) )
		level.spectreSpawns[ "assemblyLineQualityControl" ].append( Vector ( 1162.922363, 3608.000000, -440.000000 ) )
		level.spectreSpawns[ "assemblyLineQualityControl" ].append( Vector ( 1261.347290, 3608.000000, -440.000000 ) )
		level.spectreSpawns[ "assemblyLineQualityControl" ].append( Vector ( 1458.197144, 3608.000000, -440.000000 ) )
		level.spectreSpawns[ "assemblyLineQualityControl" ].append( Vector ( 1556.622070, 3608.000000, -440.000000 ) )
		level.spectreSpawns[ "assemblyLineQualityControl" ].append( Vector ( 1655.046997, 3608.000000, -440.000000 ) )
		level.spectreSpawns[ "assemblyLineQualityControl" ].append( Vector ( 1851.896851, 3608.000000, -440.000000 ) )
		level.spectreSpawns[ "assemblyLineQualityControl" ].append( Vector ( 1950.321777, 3608.000000, -440.000000 ) )
		level.spectreSpawns[ "assemblyLineQualityControl" ].append( Vector ( 2048.746582, 3608.000000, -440.000000 ) )

		//----------------------------------------------
		// Evac custom dialogue
		//----------------------------------------------

		Evac_SetVDUEvacNag( TEAM_IMC, "EvacNagMilitaWon" )
		Evac_SetVDUEvacNag( TEAM_MILITIA, "EvacNagIMCWon" )

		Evac_SetVDUPursuitNag( TEAM_IMC, "EvacNagIMCWon" )
		Evac_SetVDUPursuitNag( TEAM_MILITIA, "EvacNagMilitaWon" )
	}
}

////////////////////////////////////////////////////////////////////////////////////
function DialogueEpilogueStory()
{
	SetGlobalForcedDialogueOnly( true )

	wait 5

	ForcePlayConversationToAll( "CorporateEpilogueStory" )

	wait 27

	ForcePlayConversationToTeam( "CorporateEpilogueStoryEnd", TEAM_MILITIA )
}


////////////////////////////////////////////////////////////////////////////////////
function EvacCustomDropshipFunc( dropship )
{
	//No spectres if it's an IMC ship
	if ( dropship.GetTeam() == TEAM_IMC )
		return

	Assert( dropship, "CORPORATE: No evac dropship found." )

	local spectre
	local anim
	for ( local i = 0; i < 4; i++ )
	{
		spectre = SpawnSpectre( TEAM_IMC, UniqueString(), dropship.GetOrigin(), dropship.GetAngles() )
		//spectre = CreatePropDynamic( NEUTRAL_SPECTRE_MODEL, dropship.GetOrigin(), dropship.GetAngles() )
		//SpectreSetTeam( spectre, TEAM_IMC )
		if ( i == 0 )
			anim = "sp_evac_cockpit_punch"
		else if ( i == 1 )
			anim = "sp_evac_engine_shoot"
		else if ( i == 2 )
			anim = "sp_evac_wing_shoot"
		else if ( i == 3 )
			anim = "sp_evac_engine_punch"

		thread EvacShipSpectreThink( spectre, anim, dropship )
	}
}
/////////////////////////////////////////////////////////////////////////////////////
function EvacShipSpectreThink( spectre, anim, dropship )
{
	spectre.EndSignal( "OnDeath" )

	spectre.SetParent( dropship, "origin" )
	spectre.Anim_ScriptedPlay( anim )
	spectre.Anim_EnableUseAnimatedRefAttachmentInsteadOfRootMotion()

	SetDeathFuncName( spectre, "EvacShipSpectreDeath" )
	//spectre.SetEfficientMode( true )
	spectre.SetMaxHealth( 50 )
	spectre.SetHealth( 50 )
	spectre.SetAimAssistAllowed( false )
	spectre.SetAllowMelee( false )
	DisableLeeching( spectre )
	//spectre.DisableStarts()
	DisableRockets( spectre )
	if ( ( anim == "sp_evac_cockpit_punch" ) || ( anim == "sp_evac_engine_punch" ) )
		spectre.TakeActiveWeapon()
	//spectre.SetHearingSensitivity( 0 )
	//spectre.SetLookDist( 0 )

	FlagWait( "EvacFinished" )

	spectre.Kill()
}

///////////////////////////////////////////////////////////////////////////////////
function EvacShipSpectreDeath( spectre )
{
	//local anim = GetRandomAnim( level.spectreAnims[ "SpectreNeutralized" ] )
	//spectre.Anim_Play( anim )
	//WaitSignalOnDeadEnt( spectre, "OnAnimationDone" )
	spectre.BecomeRagdoll( Vector( 0, 0, 0 ) )
}


///////////////////////////////////////////////////////////////////////////////////////////
function EvacSetupRoundEnd()
{
	//------------------------------------------------------
	// runs right at the end of the game before evac starts
	//------------------------------------------------------


	//------------------------------------------------------
	// CINEMATIC MODE ONLY
	//------------------------------------------------------
	if ( level.playCinematicContent )
	{
		//--------------------------------------------------------
		// Kill any remaining grunts (should mostly already be dead by now)
		//--------------------------------------------------------
		FlagSet( "Disable_IMC" )//don't spawn any IMC grunts
		FlagSet( "Disable_MILITIA" )//don't spawn any IMC grunts
		FlagSet( "DisableSkits" )	//if we skipped here in dev mode

		local soldiers = GetNPCArrayByClass( "npc_soldier" )
		printt( "CORPORATE: Remaining AI: ", soldiers.len() )
		foreach( soldier in soldiers )
		{
			if( IsValid( soldier ) )
				thread KillWhenNotVisible( soldier )
		}

		//-------------------------
		// Neutralize all Spectres on opposing team
		//-------------------------
		level.winners = GetWinningTeam()

		if ( level.winners )
		{
			thread SpectresNeutralizeAllOnTeam( GetTeamIndex(GetOtherTeams( level.winners )) )
		}
		else
		{
			thread SpectresNeutralizeAllOnTeam( TEAM_MILITIA )
			thread SpectresNeutralizeAllOnTeam( TEAM_IMC )
		}

		//-------------------------
		// Start the end sequnces
		//-------------------------
		FlagSet( "epilogueStarted" )

		if ( GetTeamIndex(level.winners) == TEAM_IMC )
			thread EvacWinnersIMC()
		else
			thread EvacWinnersMilitia()

		//-------------------------
		// Play story dialogue
		//-------------------------
		delaythread ( 30 ) DialogueEpilogueStory()

		thread DoEnding()
	}

	//------------------------------------------------------
	// Default evac stuff for both cinematic and classic
	//------------------------------------------------------

	if ( level.forceEvacNode )
		level.evacNode = level.ExtractLocations[ level.forceEvacNode ].node

	local ref = GetEnt( "intro_spacenode" )
	local angles = ref.GetAngles()
	local spacenode = CreateScriptRef( ref.GetOrigin(), angles )

	Evac_SetSpaceNode( spacenode )
	GM_SetObserverFunc( EvacObserverFunc )


}
////////////////////////////////////////////////////////////////////////////////
function EvacWinnersMilitia()
{
	local players = GetPlayerArray()

	foreach ( player in players )
		Remote.CallFunction_NonReplay( player, "ServerCallback_gameProgress", TEAM_MILITIA, 100 ) //tell client that game over, militia won

	//-------------------------
	// Wait for client dialogue to trigger
	//-------------------------
	wait 15


	//-------------------------
	// Blow up racked spectres
	//-------------------------
	foreach( spectre in level.spectreSpawns[ "spectreRacks" ][ "all" ] )
		thread SpectreExplodeWhenPlayerNear( spectre, false ) //<-- false means no reset

}

///////////////////////////////////////////////////////////////////////////
function SpectreExplodeWhenPlayerNear( spectre, reset = true )
{
	local players
	local canExplode = false
	while( true )
	{
		wait RandomFloat( 1, 3.5 )
		players = GetPlayerArray()
		foreach( player in players )
		{
			if ( !IsValid( player ) )
				continue
			if ( SpectreWithinTriggerDist( spectre.GetOrigin(), player.GetOrigin() ) )
			{
				canExplode = true
				break
			}
		}
		if ( canExplode )
			break
	}
	PlayFX( FX_SPECTRE_RACK_RESIDUAL_FIRE, spectre.GetOrigin(), spectre.GetAngles() )
	EmitSoundAtPosition( spectre.GetOrigin(), SFX_SPECTRE_RACK_RESIDUAL_FIRE_LOOP )
	thread SpectreExplode( spectre, reset )
}

//////////////////////////////////////////////////////////
function EvacWinnersIMC()
{
	local players = GetPlayerArray()
	foreach ( player in players )
		Remote.CallFunction_NonReplay( player, "ServerCallback_gameProgress", TEAM_IMC, 100 ) //tell client that game over, IMC  won

	//-------------------------
	// Break glass that Spectres need to path through
	//-------------------------
	local ents = GetEntArrayByClass_Expensive( "func_breakable_surf" )
	foreach ( ent in ents )
	{
		//ent.TakeDamage( 1000, null, null, {} )
		ent.Fire( "Break" )
		//printl( "Taking damage" )
	}

	//-------------------------
	// Setup assembly roof to break when Spectres crawl thru
	//-------------------------
	level.assemblyRoofBlocker.Kill()
	foreach( trigger in level.assemblyRoofBreakTriggers )
		trigger.ConnectOutput( "OnStartTouch", AssemblyRoofBreakersThink )

	//-------------------------
	// Setup evac patrol points for spectres
	//-------------------------
	level.swarmLocations <- EvacGetSwarmPatrolLocations()
	level.activeSuicideSpectres <- []

	//-------------------------
	// Existing spectres become suicide
	//-------------------------
	wait 4
	local spectres = GetNPCArrayByClass( "npc_spectre" )
	foreach( spectre in spectres )
	{
		if ( !IsAlive( spectre ) )
			continue

		if ( spectre.GetBossPlayer() && spectre.GetTeam() != TEAM_IMC )
			continue

		SpectreSetTeam( spectre, TEAM_IMC )
		thread SpectreSuicideBehavior( spectre )
		level.activeSuicideSpectres.append( spectre )
		thread FreeSpectreSlotOnDeath( spectre )
	}

	//-------------------------
	// Spawn Spectre AI as much as we can
	//-------------------------
	thread SpectreSwarmAI( TEAM_IMC )


}

function AssemblyRoofBreakersThink( trigger, entity, caller, value )
{

	// Setup assembly roof to break when Spectres crawl thru
	local brushBreaker = trigger.s.brushBreaker

	local pos = trigger.GetOrigin()

	if ( IsValid( brushBreaker ) )
	{
		brushBreaker.TakeDamage( 100000, null, null, {} )
		EmitSoundAtPosition( pos, SFX_SPECTRE_SPAWN_FROM_WINDOW )

	}
	DeleteIfValid( trigger )
}

function EvacGetSwarmPatrolLocations()
{
	local evacName = level.evacNode.GetName()
	local swarmLocations = []

	local startPos1
	local startPos2

	//-------------------------------------------------------------
	// Use two seed positions near evac to get some node positions
	//------------------------------------------------------------
	switch( evacName )
	{
		case "evacLabs":
			startPos1 = Vector( 2864, -1912, -540 )
			startPos2 = Vector( 2401, -1210, -537 )
			break
		case "evacAssemblyRoof":
			startPos1 = Vector( 1496, 3200, -112 )
			startPos2 = Vector( 1812, 2789, -287 )
			break
		case "evacOffice":
			startPos1 = Vector( -344, -360, -1024 )
			startPos2 = Vector( -49, -1423, -693 )
			break
		default:
			Assert( 0, "CORPORATE: No evac location named " + evacName )
	}

	//-------------------------------------------------------------
	// Merge together sampling of nodes near the seed positions
	//------------------------------------------------------------
	local nearestNode = GetNearestNodeToPos( startPos1 )
	local neighborNodes = GetNeighborNodes( nearestNode, 32, HULL_HUMAN )

	local nearestNode = GetNearestNodeToPos( startPos2 )
	local neighborNodes2 = GetNeighborNodes( nearestNode, 32, HULL_HUMAN )

	ArrayAppend( neighborNodes, neighborNodes2 )



	//-------------------------------------------------------------
	// Get 40 random nodes near evac for Spectres to swarm if no enemy
	//------------------------------------------------------------
	ArrayRandomize( neighborNodes )

	local nodeOrigin
	foreach( node in neighborNodes )
	{
		if ( node != -1 )
		{
			nodeOrigin = GetNodePos( node, HULL_HUMAN )
			swarmLocations.append( nodeOrigin )
			if ( swarmLocations.len() >= 40 )
				break
		}
	}
	if( swarmLocations.len() < 40 )
		printt( "CORPORATE: WARNING Need more spectre swarm locations for evac: ", evacName, ". Only ", swarmLocations.len(), " nodes found" )

	return swarmLocations
}

/////////////////////////////////////////////////////////////
function SpectreSwarmAI( team )
{
	local enemyTeam = GetTeamIndex(GetOtherTeams(1 << team))
	local players
	local spawnerTable
	local spectre
	local canSpawnAI = true


	while ( true )
	{
		wait 0.5

		canSpawnAI = true
		//------------------------------------------------------
		// Don't exceed max AI
		//------------------------------------------------------
		canSpawnAI = CanSpawnSpectres()

		//------------------------------------------------------
		// Try to spawn near an enemy, if that fails, a friendly
		//------------------------------------------------------
		players = GetPlayerArrayOfTeam( enemyTeam )
		if ( players.len() == 0 )
			players = GetPlayerArrayOfTeam( team )

		foreach( player in players )
		{
			if ( !IsValid( player ) )
				continue
			canSpawnAI = CanSpawnSpectres() //check again since may have changed since last frame
			spawnerTable = GetClosestEpilogueSpawner( player.GetOrigin(), canSpawnAI )
			if ( !spawnerTable )
				continue
			thread SpawnEpilogueSpectre( spawnerTable, team, canSpawnAI )
			wait 0.05
		}
	}
}



///////////////////////////////////////////////////////////////////
function CanSpawnSpectres()
{
	if ( level.activeSuicideSpectres.len() >= SPECTRES_MAX_AI )
		return false
	else
		return true
}
///////////////////////////////////////////////////////////////////
function GetClosestEpilogueSpawner( pos, canSpawnAI )
{
	local lastSpawnTime
	local distSqr
	local newDistSqr
	local bestSpawnerTable
	local fellowSpectres

	local spawnerTables = level.spectreSpawns[ "epilogue" ]


	distSqr = ( spawnerTables[ 0 ].animEndPos - pos ).LengthSqr()

	foreach( table in spawnerTables )
	{
		//------------------------------------------
		// If we're at AI limit, disregard everything but racks
		//------------------------------------------
		if ( ( !canSpawnAI ) && ( table.spawnType != "rack" ) )
			continue

		//------------------------------------------
		// Disregard if it's a rack and it's in use
		//------------------------------------------
		if ( ( table.spawnType == "rack" ) && ( table.spectreDrone.s.inUse == true ) )
			continue

		//---------------------------
		// Disregard if cooling down
		//--------------------------
		lastSpawnTime = table.lastSpawnTime
		if ( Time() - lastSpawnTime < table.spawnCooldown )
			continue

		//---------------------------
		// Disregard if high traffic
		//--------------------------
		if ( SpectresWithinRadiusOfPos( table.animEndPos, 64 ) )
			continue

		//---------------------------
		// Check dist to position
		//--------------------------
		newDistSqr = ( table.animEndPos - pos ).LengthSqr()

		//---------------------------
		// If rack, disregard unless really close
		//--------------------------
		if ( ( table.spawnType == "rack" ) && ( newDistSqr > SPECTRE_TRIGGER_ACTIVATE_DIST_SQ ) )
			continue

		//---------------------------
		// Got this far...it's a contender
		//--------------------------
		else if ( newDistSqr < distSqr )
		{
			bestSpawnerTable = table
			distSqr = newDistSqr
		}
	}

	return bestSpawnerTable
}
/////////////////////////////////////////////////////////////////////
function SpectresWithinRadiusOfPos( pos, radius )
{
	if ( level.activeSuicideSpectres.len() == 0 )
		return false
	local nearestSpectre = GetNPCArrayEx( "npc_spectre", TEAM_IMC, pos, radius )
	if ( nearestSpectre.len() > 0 )
		return true
	else
		return false

}
///////////////////////////////////////////////////////////////////
function SpawnEpilogueSpectre( spawnerTable, team, canSpawnAI )
{
	spawnerTable.lastSpawnTime = Time()
	local spectre
	local squadName = UniqueString()

	//-----------------------------------------------------
	// If at AI limit, better not be passing anything but a rack
	//-------------------------------------------------------
	if ( ( !canSpawnAI ) && ( spawnerTable.spawnType != "rack" ) )
		Assert( 0, "CORPORATE: Passing a spawner table that is not a spectre rack when canSpawnAI is false. SpawnerType: " + spawnerTable.spawnType )

	//---------------------------
	// Rack spawner - Real AI
	//--------------------------
	if ( ( spawnerTable.spawnType == "rack" ) && ( canSpawnAI ) )
	{
																					//isDrone
		spectre = SpawnRackedSpectre( spawnerTable.spectreDrone, team, squadName, 0, false, "sp_med_bay_drop_unarmed" )
	}
	//---------------------------
	// Rack spawner - Drone only
	//--------------------------
	else if ( ( spawnerTable.spawnType == "rack" ) && ( !canSpawnAI ) )
	{
																					//isDrone
		spectre = SpawnRackedSpectre( spawnerTable.spectreDrone, team, squadName, 0, true )
	}
	//---------------------------
	// Regular AI spawner
	//--------------------------
	else if ( canSpawnAI ) //still check to make sure we should be spawning a real AI
	{
		spectre = SpawnSpectre( team, squadName, spawnerTable.org, spawnerTable.ang )
		//SpectreSetTeam( spectre, team )
	}
	else
		Assert( 0, "CORPORATE: Attempting to spawn a spectre AI beyond AI limit" )

	//---------------------------
	// Only track if it's real AI
	//--------------------------
	if ( IsNPC ( spectre ) )
	{
		level.activeSuicideSpectres.append( spectre )
		thread FreeSpectreSlotOnDeath( spectre )
		thread SpectreSuicideBehavior( spectre, spawnerTable )
	}
}

///////////////////////////////////////////////////
function FreeSpectreSlotOnDeath( spectre )
{
	spectre.EndSignal( "OnDestroy" )

	OnThreadEnd
	(
		function () : ( spectre )
		{
			ArrayRemove( level.activeSuicideSpectres, spectre )
		}
	)

	spectre.WaitSignal( "OnDestroy" )
}

//////////////////////////////////////////////////////////
function DebugSpectreRoofLeap( animNode )
{
	local pos = animNode.GetOrigin()
	local ang = animNode.GetAngles()
	local spectre = SpawnSpectreDrone( pos, ang, SPECTRE_TYPE_LEAPER )


	while( true )
	{
		spectre.Signal( "SpectreReset" )
		spectre.s.state = null
		//SpectreSetTeam( spectre, level.winners )
		spectre.Show()
		spectre.Anim_PlayWithRefPoint( "sp_bldg_traverse_down_670", pos, ang, 0 )
		spectre.WaitSignal( "OnAnimationDone" )
		spectre.Anim_PlayWithRefPoint( GetRandomAnim( level.spectreAnims[ "spectreSearch" ] ), spectre.GetOrigin(), spectre.GetAngles(), 0 )

		thread SpectreWaitToExplode( spectre )
		spectre.WaitSignal( "SpectreReset" )
		wait 1.25
	}
}

////////////////////////////////////////////////////////////////////////////////////
function DebugSpectreClimb()
{
	local spectre

	foreach( pos in level.spectreSpawns[ "assemblyLineQualityControl" ] )
	{
		local spectre = SpawnSpectreDrone( pos, Vector( 0, 0, 0 ), SPECTRE_TYPE_SWARM )
		spectre.Hide()
		spectre.s.animPos <- pos + Vector( 0, 0, SPECTRE_ASSEMBLY_ANIM_Z_OFFSET )
		spectre.s.animAng <- spectre.GetAngles() + Vector( 0, 0, 0 )
		thread SpecterClimberThink( spectre )
	}
}
////////////////////////////////////////////////////////////////////////////////////
function SpecterClimberThink( spectre )
{
	local climbAnim

	if ( CoinFlip() )
		climbAnim = "sp_corporate_wall_swarm_A"
	else
		climbAnim = "sp_corporate_wall_swarm_B"
	local animLengthClimb = spectre.GetSequenceDuration( climbAnim )
	local animLengthDrop = spectre.GetSequenceDuration( "sp_assembly_line_drop" )

	while( true )
	{
		wait RandomFloat( 1, 3.5 )
		spectre.Show()
		//SpectreStartBlinkingLight( spectre )
		spectre.Anim_PlayWithRefPoint( "sp_assembly_line_drop", spectre.s.animPos , spectre.s.animAng, 0 )
		wait animLengthDrop
		spectre.Anim_PlayWithRefPoint( climbAnim, spectre.s.animPos , spectre.s.animAng, 0 )
		wait animLengthClimb
		spectre.Hide()
		//SpectreStopBlinkingLight( spectre )
	}
}

//////////////////////////////////////////////////////////
function EvacObserverFunc( player )
{
	player.SetObserverModeStaticPosition( level.ExtractLocations[ level.SelectedExtractLocationIndex ].spectatorPos )
	player.SetObserverModeStaticAngles( level.ExtractLocations[ level.SelectedExtractLocationIndex ].spectatorAng )

	player.StartObserverMode( OBS_MODE_CHASE )
	player.SetObserverTarget( null )

	//player.SetOrigin( level.ExtractLocations[ level.SelectedExtractLocationIndex ].spectatorPos )
	//player.SetAngles( level.ExtractLocations[ level.SelectedExtractLocationIndex ].spectatorAng )
}


/*----------------------------------------------------------------------------------
/
/				HOUSEKEEPING
/
/-----------------------------------------------------------------------------------*/
function AA_Housekeeping_functions()
{
	//Bookmark to jump to this section
}

//////////////////////////////////////////////////////////
function MatchProgressUpdate( progression )
{
	//------------------------------------
	// If match end is near, clear out grunt AI
	//------------------------------------
	if ( progression >= MATCH_PROGRESS_CORPORATE_STOP_SPAWNING_GRUNTS )
	{
		printt( "CORPORATE: Match close to end - stop spawning grunts....only spectres so we can deactivate losers at epilogue" )
		FlagClear( "AllSpectreIMC" )
		FlagClear( "NoSpectreMilitia" )
		FlagSet( "AllSpectre" )
		FlagSet( "DisableSkits" )	//no more skits since they may mess up spectre counts
	}

	thread MatchProgressDialog( progression )
}

//////////////////////////////////////////////////////////
function KillWhenNotVisible( npc )
{
	if( !IsValid( npc ) )
		return

	if ( "doomed" in npc.s )
		return

	printt( "CORPORATE: AI culling - Trying to cull a ", npc.GetClassname(), " from team ", npc.GetTeam() )

	npc.EndSignal( "OnDeath" )
	npc.EndSignal( "OnDestroy" )

	npc.s.doomed <- 1	//marked for death, don't run this thread on him twice
	npc.SetMaxHealth( 1 )
	npc.SetHealth( 1 )
	local players

	local npcIsVisible
	while( IsValid( npc ) )
	{
		wait RandomFloat( 1, 3 )
		players = GetPlayerArray()
		npcIsVisible = true
		foreach( player in players )
		{
			if ( !IsValid( player ) )
				continue
			if ( player.CanSee( npc ) )
				break
			else
				npcIsVisible = false
		}
		if ( !npcIsVisible )
			break
	}

	if ( IsValid( npc ) )
	{
		printt( "CORPORATE: AI culling - Successfully culled a ", npc.GetClassname(), " from team ", npc.GetTeam() )
		npc.Die()
	}
}

//////////////////////////////////////////////////////////
function GetGruntsAndSpectres( team = null )
{
	local dudes = GetNPCArrayByClass( "npc_spectre" )
	ArrayAppend( dudes, GetNPCArrayByClass( "npc_soldier" ) )

	if ( team != null )
	{
		foreach( index, dude in dudes )
		{
			if ( !IsValid( dude ) )
			{
				dudes.remove( index )
				continue
			}
			if ( duce.GetTeam == team )
				dudes.remove( index )
		}
	}
	return dudes
}



///////////////////////////////////////////////////////////////
function GetRandomAnim( animArray )
{
	return animArray[ RandomInt( animArray.len() ) ]
}

//////////////////////////////////////////////////////////
function ClientSpectreAssemblyLineStop()
{
	level.nv.assemblyLineStops = 1
}

//////////////////////////////////////////////////////////
function ClientSpectreAssemblyLineStart()
{
	level.nv.assemblyLineStops = 0
}

///////////////////////////////////////////////////////////////
function FxDestroy( fx )
{
	if ( !IsValid( fx ) )
		return
	fx.ClearParent()
	fx.Fire( "Stop" )
	fx.Fire( "DestroyImmediately" )
}

///////////////////////////////////////////////////////////////////
function CreateAnimNode( animPos = Vector( 0, 0, 0 ), animAng  = Vector( 0, 0, 0 ))
{
	local node = 	CreateEntity( "info_target" )
	node.SetOrigin( animPos )
	node.SetAngles( animAng )
	DispatchSpawn( node, false )
	return node
}

///////////////////////////////////////////////////////////////////////////////////////////
function GotoOriginAndIdle( guy, origin, idleAnim, endSignal = null )
{
	if ( !IsAlive( guy ) )
		return

	guy.EndSignal( "OnDeath" )

	if ( endSignal != null )
		guy.EndSignal( endSignal )

	if ( origin != null )
		GotoOrigin( guy, origin )
	thread PlayAnimGravity( guy, idleAnim, guy.GetOrigin(), guy.GetAngles() )

}


////////////////////////////////////////////////////////////////////////////////////////
function PrintStatusAI()
{
	local freeSlotsMilitia = GetFreeAISlots( TEAM_MILITIA )
	local freeSlotsIMC = GetFreeAISlots( TEAM_IMC )
	printl( "********************************************************" )
	printt( "CORPORATE: AI Culling - There are supposedly ", freeSlotsIMC, " free slots for IMC" )
	printt( "CORPORATE: AI Culling - There are supposedly ", freeSlotsMilitia, " free slots for Militia" )
	printl( "********************************************************" )
}
////////////////////////////////////////////////////////////////////////////////////////
function ReduceAIcount( npcArray, team, targetSize = null )
{
	local checkForSpectres = false
	if ( targetSize == null )
		targetSize = GetMaxAICount( TEAM_IMC )

	printt( "CORPORATE: AI culling - Team ", team, " has ", npcArray.len(), " grunts/spectres. Attempting to reduce to ", targetSize )
	PrintStatusAI()

	while( npcArray.len() > targetSize )
	{
		foreach( index, npc in npcArray )
		{
			//-------------------
			// remove dead npcs
			//-------------------
			if ( !IsValid( npc ) )
				npcArray.remove( index )

			//-------------------
			// remove already doomed npcs
			//-------------------
			else if ( "doomed" in npc.s )
				npcArray.remove( index )

			//-------------------
			// remove soldiers before spectres
			//-------------------
			else if ( npc.GetClassname() == "npc_soldier" )
			{
				thread KillWhenNotVisible( npc )
				npcArray.remove( index )
			}

			//-------------------------------------------
			// second run through? Delete Spectres now
			//-------------------------------------------
			else if ( ( checkForSpectres ) && ( npc.GetClassname() == "npc_spectre" ) )
			{
				thread KillWhenNotVisible( npc )
				npcArray.remove( index )
			}

			//-------------------
			// break out if we've deleted enough
			//-------------------
			if ( npcArray.len() == targetSize )
				break
			else
				continue
		}

		checkForSpectres = true	//only delete spectres on second loop through
	}
}
/////////////////////////////////////////////////////////////////////////////////////////////////
function SpawnOnGround( team )
{
	local players = GetPlayerArrayOfTeam( TEAM_MILITIA )
	foreach ( player in players )
		thread SpawnPlayerOnGround( player )
}

/////////////////////////////////////////////////////////////////////////////////////////////////
function DisableTitanOverlays( titan )
{
	//titan.SetTeam( 0 )
	DisableHealthRegen( titan )
	local soul = titan.GetTitanSoul()
	//soul.Signal( "Doomed" )
	soul.SetShieldHealthMax( 0 )
	soul.SetShieldHealth( 0 )
	titan.SetTitle( "" )
	titan.SetShortTitle( "" )
}

///////////////////////////////////////////////////////////////////////////////////////////////
function MatchProgressDialog( progression )
{
	//First do default stuff
	DefaultMatchProgressionAnnouncement( progression )
	if ( GAMETYPE != CAPTURE_POINT )
		return

	if ( level.devForcedWin )
		return

	if ( Flag( "epilogueStarted" ) )
		return

	if ( progression < 10 )
		return

	local percentComplete
	local winningTeam
	local militiaScore = GameRules.GetTeamScore( TEAM_MILITIA )
	local imcScore = GameRules.GetTeamScore( TEAM_IMC )
	local alias

	if ( militiaScore > imcScore )
		winningTeam = TEAM_MILITIA
	else
		winningTeam = TEAM_IMC

	if ( ( progression >= 75 ) && ( !level.game75percentDialoguePlayed ) )
	{
		level.game75percentDialoguePlayed = 1
		percentComplete = 75
		alias = "GameOver75percent"
	}
	else if ( ( progression >= 50 ) && ( !level.game50percentDialoguePlayed ) )
	{
		level.game50percentDialoguePlayed = 1
		percentComplete = 50
		alias = "GameOver50percent"
	}
	else if ( ( progression >= 25 )  && ( !level.game25percentDialoguePlayed ) )
	{
		level.game25percentDialoguePlayed = 1
		percentComplete = 25
		alias = "GameOver25percent"
	}
	else if ( ( progression >= 10 )  && ( !level.game10percentDialoguePlayed ) )
	{
		level.game10percentDialoguePlayed = 1
		percentComplete = null //don't need to trigger any client loudspeaker stuff for 10%
		alias = "GameOver10percent"
	}
	else
		return

	//--------------------------------------------------------------
	// Run client function to do match progress stuff
	//--------------------------------------------------------------
	if ( percentComplete )
	{
		local players = GetPlayerArray()
		foreach ( player in players )
			Remote.CallFunction_NonReplay( player, "ServerCallback_gameProgress", winningTeam, percentComplete )
	}

	//--------------------------------------------------------------
	// Delay radio conversation to allow client loudspeakers to play on client
	//--------------------------------------------------------------
	if ( alias )
	{
		delaythread( 10 ) PlayConversationToTeam( alias, TEAM_IMC )
		delaythread( 10 ) PlayConversationToTeam( alias, TEAM_MILITIA )
	}

}

///////////////////////////////////////////////////////////////////////////////////////////////
function GetClosestPlayer( pos, team )
{
	local players = GetPlayerArrayEx( "any", team, pos, SPECTRE_MAX_DIST_FROM_ENEMY )
	if ( players.len() == 0 )
		return null

	local player = GetClosest( players, pos, SPECTRE_MAX_DIST_FROM_ENEMY )
	return player
}

//////////////////////////////////////////////////////////////////////////////////////////
function InfoTargetCallbackCorporate( infoTarget )
{
	//--------------------------------
	// Is it a spectre spawn point?
	//--------------------------------
	if ( infoTarget.HasKey( "spectreSpawn" ) )
		SpectreSpawnSetupEpilogue( infoTarget )
}

//////////////////////////////////////////////////////////////////////////////////////////
function DrawLinePos( pos1, pos2 )
{
	while ( true )
	{
		DebugDrawLine( pos1, pos2, 0, 255, 0, true, 5.0 )
		wait 0.05
	}
}
//////////////////////////////////////////////////////////////////////////////////////////
function DrawLineEntToPos( ent, pos )
{
	ent.EndSignal( "OnDeath" )

	while ( IsAlive( ent ) )
	{
		DebugDrawLine( ent.GetOrigin() + Vector( 0, 0, 64 ), pos, 0, 255, 0, true, 5.0 )
		wait 0.05
	}
}
///////////////////////////////////////////////////////////////////////////////
function SpawnAnimRef( pos, ang )
{
	local node = CreateEntity( "info_target" )
	node.SetOrigin( pos )
	node.SetAngles( ang )
	DispatchSpawn( node, false )

	return node
}
///////////////////////////////////////////////////////////////////////////
function IsTouchingGround( npc )
{
	local start = npc.GetOrigin()
	local end = start + Vector( 0, 0, -1000 )
	local traceDist = ( start - end ).Length()

	local result = TraceLineSimple( start, end, npc )
	local distFromGround = traceDist * result

	//printt( "distFromGround: ", distFromGround )

	if ( distFromGround > 5.5 )
		return false
	else
		return true
}
///////////////////////////////////////////////////////////////////////////////////////////////
function AssemblyLineRoofSetup()
{

	local func_brush_assemblyRoofBlocker = GetEnt( "func_brush_assemblyRoofBlocker" )
	Assert( func_brush_assemblyRoofBlocker != null )
	level.assemblyRoofBlocker <- func_brush_assemblyRoofBlocker

	local triggers = GetEntArrayByNameWildCard_Expensive( "trigger_multiple_roofbreak*" )
	Assert( triggers.len() > 0 )
	level.assemblyRoofBreakTriggers <- triggers


	local brushBreaker
	foreach( trigger in triggers )
	{
		brushBreaker = GetEnt( trigger.GetTarget() )
		Assert( brushBreaker != null )
		trigger.s.brushBreaker <- brushBreaker
	}

}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function CorporateSpecificChatter( npc )
{
	Assert( GetMapName() == "mp_corporate" )

	if ( !GamePlayingOrSuddenDeath() )
		return false

	PlaySquadConversationToTeam( "corporate_grunt_chatter", npc.GetTeam(), npc, AI_FRIENDLY_CHATTER_RANGE_SQR )
	return true //return false if we should not be doing chatter so we can fall through and do other chatter if needed
}


/*----------------------------------------------------------------------------------
/
/				ENDING
/
/-----------------------------------------------------------------------------------*/
function DoEnding()
{
	FlagWait( "PlayPostEvacDialogue" )

	wait POSTDIALOGUETIME

	FlagSet( "CinematicEnding" )

	local fadeTime = 5.0
	AllPlayersMuteSFX( fadeTime )

	SetGlobalForcedDialogueOnly( true )

	//tell the client to start the ending
	level.nv.doEnding = 1

	//give a moment for fade to black
	wait fadeTime + 0.5

	local players = GetPlayerArray()
	foreach( player in players )
		player.Signal( "RodeoOver" )

	wait 0.5 // Need to give rodeo threads a chance to terminate rodeo

	//set the players view to spectators
	GM_SetObserverFunc( EndingObserverFunc )

	players = GetPlayerArray()
	foreach( player in players )
		ObserverEntities( player )
}

function PutPlayerInEndingView( player )
{
	player.FreezeControlsOnServer( false )
	TakeAllWeapons( player )
	AddCinematicFlag( player, CE_FLAG_INTRO )
	player.ClearParent()
	player.SetPlayerSettings( "spectator" )
}

function EndingObserverFunc( player )
{
	PutPlayerInEndingView( player )

	local origin = Vector( 0, 0, -8000 )
	local angles = Vector( -4, -151, 0 )
	player.SetObserverModeStaticPosition( origin )
	player.SetObserverModeStaticAngles( angles )

	player.StartObserverMode( OBS_MODE_STATIC_LOCKED )
	player.SetObserverTarget( null )
}

function ClientCallback_SetEndingSkyCam( player )
{
	local skycam = GetEnt( SKYBOXSPACE )
	player.SetSkyCamera( skycam )
}

/*----------------------------------------------------------------------------------
/
/				DEV COMMANDS
/
/-----------------------------------------------------------------------------------*/
function AA_Dev_functions()
{
	//Bookmark to jump to this section
}

///////////////////////////////////////////////////////////////////////////////////////////////
function DEV_EvacFactoryBlowsUp()
{
	thread EvacWinnersMilitia()
}
///////////////////////////////////////////////////////////////////////////////////////////////
function DEV_SpectreClimb()
{
	thread DebugSpectreClimb()
}
///////////////////////////////////////////////////////////////////////////////////////////////
function DEV_SpectreSwarm( evacNodeIndex )
{
	//level.evacCustomWaitTime <- 9999
	level.forceEvacNode = evacNodeIndex
	thread ForceIMCWin()
}
function DEV_MatchProgressDialogue( number )
{
	local alias
	if ( number == 1 )
		alias = "GameOver10percent"
	else if ( number == 2 )
		alias = "GameOver25percent"
	else if ( number == 3 )
		alias = "GameOver50percent"
	else if ( number == 4 )
		alias = "GameOver75percent"
	else if ( number == 5 )
		alias = "CorporateEpilogueStory"
	else if ( number == 6 )
		alias = "CorporateEpilogueStoryEnd"
	else
		return

	thread PlayConversationToTeam( alias, TEAM_IMC )
	thread PlayConversationToTeam( alias, TEAM_MILITIA )
}


main()