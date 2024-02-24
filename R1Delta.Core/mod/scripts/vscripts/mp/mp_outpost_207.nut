const ANIMREF_MODEL 			= "models/dev/editor_ref.mdl"
const CANNON_BASE_MODEL 		= "models/Weapons/railgun_outpost_207/railgun_outpost_01_base_dynamic.mdl"
const CANNON_BARREL_MODEL 		= "models/Weapons/railgun_outpost_207/railgun_outpost_01_barrel.mdl"
const SKYCANNON_BASE_MODEL 		= "models/Weapons/railgun_outpost_207/railgun_skybox_base_dyn.mdl"
const SKYCANNON_BARREL_MODEL 	= "models/Weapons/railgun_outpost_207/railgun_skybox_barrel.mdl"
const CAPITAL_SHIP_MODEL_CLEAN 	= "models/vehicle/imc_carrier/vehicle_imc_carrier207_stage1.mdl"
const CAPITAL_SHIP_MODEL_DMG_1 	= "models/vehicle/imc_carrier/vehicle_imc_carrier207_stage2.mdl"
const CAPITAL_SHIP_MODEL_DMG_2 	= "models/vehicle/imc_carrier/vehicle_imc_carrier207_stage3.mdl"
const CAPITAL_SHIP_MODEL_DMG_3 	= "models/vehicle/imc_carrier/vehicle_imc_carrier207_stage4.mdl"
const CAPITAL_SHIP_MODEL_DMG_4 	= "models/vehicle/imc_carrier/vehicle_imc_carrier207_stage5.mdl"
const CAPITAL_SHIP_PIECES_MODEL	= "models/vehicle/imc_carrier/imc_carrier207_broken.mdl"
const MILITIA_DECOY_SHIP_MODEL 	= "models/vehicle/capital_ship_birmingham/birmingham_decoy.mdl"
const SAFETY_BATON_MODEL 		= "models/industrial/safety_baton.mdl"
PrecacheModel( ANIMREF_MODEL )
PrecacheModel( CANNON_BASE_MODEL )
PrecacheModel( CANNON_BARREL_MODEL )
PrecacheModel( SKYCANNON_BASE_MODEL )
PrecacheModel( SKYCANNON_BARREL_MODEL )
PrecacheModel( CAPITAL_SHIP_MODEL_CLEAN )
PrecacheModel( CAPITAL_SHIP_MODEL_DMG_1 )
PrecacheModel( CAPITAL_SHIP_MODEL_DMG_2 )
PrecacheModel( CAPITAL_SHIP_MODEL_DMG_3 )
PrecacheModel( CAPITAL_SHIP_MODEL_DMG_4 )
PrecacheModel( CAPITAL_SHIP_PIECES_MODEL )
PrecacheModel( MILITIA_DECOY_SHIP_MODEL )
PrecacheModel( SAFETY_BATON_MODEL )

// set up in _consts
PrecacheModel( TEAM_IMC_GRUNT_MDL )
PrecacheModel( NEUTRAL_SPECTRE_MODEL )
PrecacheModel( MARVIN_MODEL )

const FX_DROPSHIP_WARPEFFECT 		= "veh_gunship_warp_FULL"
const FX_TITAN_COCKPIT_LIGHT 		= "veh_interior_DLight_cabin"
const FX_CAPITAL_SHIP_DMG_BREAKSUP 	= "P_exp_SB_carrier_XLG"
const FX_CANNON_BEAM 				= "P_rail_fire_beam_scale"
const FX_CANNON_PREFIRE_SKY 		= "P_rail_charge_SB_1"
const FX_CANNON_BEAM_SKY 			= "P_rail_fire_beam_scale_SB"
const FX_CANNON_MUZZLEFLASH_SKY 	= "P_rail_fire_flash_SB"
const FX_DECOY_SHIP_BEAM_IMPACT 	= "P_exp_birm_Impact_LG_1"
const FX_DECOY_SHIP_DESTRUCTION 	= "P_exp_birm_death"

PrecacheParticleSystem( FX_DROPSHIP_WARPEFFECT )
PrecacheParticleSystem( FX_TITAN_COCKPIT_LIGHT )
PrecacheParticleSystem( FX_CAPITAL_SHIP_DMG_BREAKSUP )
PrecacheParticleSystem( FX_CANNON_BEAM )
PrecacheParticleSystem( FX_CANNON_PREFIRE_SKY )
PrecacheParticleSystem( FX_CANNON_BEAM_SKY )
PrecacheParticleSystem( FX_CANNON_MUZZLEFLASH_SKY )
PrecacheParticleSystem( FX_DECOY_SHIP_BEAM_IMPACT )
PrecacheParticleSystem( FX_DECOY_SHIP_DESTRUCTION )

PrecacheParticleSystem( "P_exp_SB_carrier_NRG_LG_loop" )
PrecacheParticleSystem( "P_exp_SB_carrier_LG_loop" )
PrecacheParticleSystem( "P_exp_SB_carrier_MD_loop" )


const CAPITAL_SHIP_FACADE_FADETIME = 5.0

const SFX_CANNON_PREFIRE_KLAXON_LOOP 	= "Outpost207_Cannon_Alarm_Loop"
const SFX_CANNON_ROTATE_LOOP 			= "amb_outpost_cannon_servo"

const GAMESTATE_EARLY 			= 5
const GAMESTATE_QUARTER 		= 25
const GAMESTATE_HALF 			= 50
const GAMESTATE_THREEQUARTER 	= 75

// RESET AFTER TESTING
const DEV_TEST 						= false
// these only work if dev_test is set
const DEV_SKIP_INTRO 				= true		// intro only tries to play if playlist Campaign is set
const DEV_DISABLE_NPCS 				= false
const DEV_DISABLE_PROGRESS_UPDATES 	= false 	// set to true to turn off match progress checking (gamestate updates etc)
const DEV_SIM_GAME_SCORE	 		= false 	// set to true to simulate game scoring for testing
const DEV_SKIP_INTRO_SLOTS_IMC 		= 0  		// set to 0-7 inclusive to test other dropship seats during the intro
const DEV_SKIP_INTRO_SLOTS_MCOR		= 0
const DEV_FORCE_EVAC_LOC 			= false		//"evacNode_3" 	// set this to one of the evac location string aliases for testing

const GUN_MODEL = "models/weapons/m1a1_hemlok/w_hemlok.mdl"

function main()
{
	FlagSet( "StratonFlybys" )

	IncludeScript( "mp_outpost_207_shared" )

	SetupRefInfo()

	if ( reloadingScripts )
		return

	FlagInit( "Outpost_StartIntroFlyIn" )
	FlagInit( "MCOR_FlyInDone" )
	FlagInit( "IMC_FlyInDone" )
	FlagInit( "DecoyShipDestroyed" )
	FlagInit( "MCOR_Intro_TitanDone" )
	FlagInit( "MCOR_IntroDone" )
	FlagInit( "IMC_Intro_TitanDone" )
	FlagInit( "IMC_Intro_SpectresDone" )
	FlagInit( "IMC_StartTitanBootup" )
	FlagInit( "IMC_StartLandingPadSpectres" )
	FlagInit( "IMC_StartSpectreRacks" )
	FlagInit( "IMC_HumanSquadRollOut" )
	FlagInit( "IMC_HumanSquad_RolledOut" )
	FlagInit( "Intro_FinalInstructions" )
	FlagInit( "IMC_IntroDone" )
	FlagInit( "GameStateUpdateHappening" )
	FlagInit( "EvacStarted" )
	FlagInit( "MCOR_ReachedHalfScore" )
	FlagInit( "CapitalShip_JumpDrivesDisabled" )
	FlagInit( "CapitalShipEscaping" )

	RegisterSignal( "CannonFireSequenceStart" )
	RegisterSignal( "CannonFlapsOpen" )
	RegisterSignal( "CannonFired" )
	RegisterSignal( "StopFacadeFade" )
	RegisterSignal( "GameStateUpdate" )
	RegisterSignal( "DecoyShipReset" )
	RegisterSignal( "CapitalShipResetting" )
	RegisterSignal( "CapitalShipDriftSegment" )

	PrecacheModel( GUN_MODEL )

	level.scoreLimit <- GetScoreLimit_FromPlaylist().tointeger()
	level.matchTimeLimitSeconds <- ( GetTimeLimit_ForGameMode() * 60.0 ).tofloat()
	level.avgScorePerSecondToWin <- ( level.scoreLimit / level.matchTimeLimitSeconds )

	level.capitalShipAudioEnt <- null
	level.spectreRackSpawns <- []
	level.spectreRackSpawns_LandingPad <- []
	level.rackSpawnedSpectres <- []

	AddSpawnCallback( "npc_soldier", Outpost_NPCSoldierSpawned )

	if ( EvacEnabled() )
		Outpost_InitEvac()

	if ( DEV_TEST || GetCinematicMode() )
	{
		Outpost_SetupGamestateMilestones()
		RegisterServerVarChangeCallback( "matchProgress", Outpost_MatchProgressTriggersEvents )
	}

	if ( !GetCinematicMode() )
		return
	// ====== cinematic-mode only stuff past this point ======

	level.levelSpecificChatterFunc = Outpost207SpecificChatter

	FlagSet( "CinematicIntro" )
}

function EntitiesDidLoad()
{
	FlagClear( "AnnounceWinnerEnabled" )

	if ( !IsServer() )
		return

	level.maxMarvinJobDistance = 2500

	level.skycamera <- GetEnt( level.SKYCAMERA_REF )
	Assert( level.skycamera )

	CannonSetup()
	DecoyShipSetup()
	CapitalShipSetup()

	Outpost_SpectreRacksSetup()

	level.klaxonsActive <- null
	AlarmLocationsSetup()

	if ( DEV_TEST && DEV_DISABLE_NPCS )
		disable_npcs()

	if ( DEV_TEST && DEV_SIM_GAME_SCORE )
		thread SimulateGameScore()

	if ( EvacEnabled() )
		Outpost_EvacSetup()

	// ====== cinematic-mode only stuff past this point ======
	if ( !GetCinematicMode() )
		return

	thread AmbientGunshipsBuzzLevel()

	if ( DEV_TEST && DEV_SKIP_INTRO )
	{
		SetCustomIntroLength( 0.1 )
		FlagWait( "GamePlaying" )
		NonCinematicSpawn()
	}
	else
	{
		thread IntroMain()
	}
}


function SetupRefInfo()
{
	// decoy ship reference info
	if ( !( "DECOY_SHIP_START_ORG" in level ) )
	{
		level.DECOY_SHIP_START_ORG 		<- null
		level.DECOY_SHIP_START_ANG 		<- null
		level.DECOY_SHIP_FIRSTMOVE_DIST <- null
	}

	level.DECOY_SHIP_START_ORG = Vector( -9500, -16200, 4500 )
	level.DECOY_SHIP_START_ANG = Vector( 0, 20, 0 )
	level.DECOY_SHIP_FIRSTMOVE_DIST = 10000

	// capital ship reference info
	if ( !( "CAPITAL_SHIP_REF_ORG" in level ) )
	{
		level.CAPITAL_SHIP_REF_ORG <- null
		level.CAPITAL_SHIP_REF_ANG <- null
		level.CAPITAL_SHIP_FIRST_MOVE_DIST <- null

		level.CAPSHIP_DRIFT_PATH_START_ORG <- null
		level.CAPSHIP_DRIFT_PATH_START_ANG <- null

		level.CAPSHIP_DRIFT_PATH_MOVE_1_ORG <- null
		level.CAPSHIP_DRIFT_PATH_MOVE_1_ANG <- null

		level.CAPSHIP_DRIFT_PATH_MOVE_2_ORG <- null
		level.CAPSHIP_DRIFT_PATH_MOVE_2_ANG <- null

		level.CAPSHIP_DRIFT_PATH_MOVE_3_ORG <- null
		level.CAPSHIP_DRIFT_PATH_MOVE_3_ANG <- null

		level.CAPSHIP_DRIFT_PATH_MOVE_4_ORG <- null
		level.CAPSHIP_DRIFT_PATH_MOVE_4_ANG <- null
	}

	level.CAPITAL_SHIP_REF_ORG			= Vector( 11906.53, 11874.93, -11761.96 )
	level.CAPITAL_SHIP_REF_ANG 			= Vector( 0, 60, 0 )
	level.CAPITAL_SHIP_FIRST_MOVE_DIST 	= 6

	level.CAPSHIP_DRIFT_PATH_START_ORG 	= Vector( 11909.530273, 11880.125977, -11761.959961 )
	level.CAPSHIP_DRIFT_PATH_START_ANG 	= Vector( 0, 60, 0 )

	level.CAPSHIP_DRIFT_PATH_MOVE_1_ORG = Vector( 11907, 11881, -11763 )
	level.CAPSHIP_DRIFT_PATH_MOVE_1_ANG = Vector( 3, 78, -7.5 )

	level.CAPSHIP_DRIFT_PATH_MOVE_2_ORG = Vector( 11905.5, 11885, -11766 )
	level.CAPSHIP_DRIFT_PATH_MOVE_2_ANG = Vector( 2.75, 106, -10 )

	level.CAPSHIP_DRIFT_PATH_MOVE_3_ORG = Vector( 11904.5, 11889, -11768 )
	level.CAPSHIP_DRIFT_PATH_MOVE_3_ANG = Vector( 0, 131, -17 )

	level.CAPSHIP_DRIFT_PATH_MOVE_4_ORG = Vector( 11902.5, 11894, -11770.5 )
	level.CAPSHIP_DRIFT_PATH_MOVE_4_ANG = Vector( -5, 165, -22 )
}

function Outpost_NPCSoldierSpawned( soldier )
{
	SetRebreatherMaskVisible( soldier, true )
}


// =========== MATCH EVENTS =========== //
function Outpost_SetupGamestateMilestones()
{
	level.gameStateMilestones <- []

	local milestone = AddGameStateMilestone( GAMESTATE_EARLY, false )
	AddGameStateMilestone( GAMESTATE_QUARTER )
	AddGameStateMilestone( GAMESTATE_HALF )
	AddGameStateMilestone( GAMESTATE_THREEQUARTER )
}

function AddGameStateMilestone( progressPercentage, isTeamSpecific = true )
{
	local milestone = {}
	milestone.progressPercentage 	<- progressPercentage
	milestone.isTeamSpecific		<- isTeamSpecific
	milestone.completedByMilitia 	<- null
	milestone.completedByIMC 		<- null

	level.gameStateMilestones.append( milestone )
	return milestone
}

function Outpost_MatchProgressTriggersEvents()
{
	if ( DEV_TEST && DEV_DISABLE_PROGRESS_UPDATES )
		return

	if ( GetGameState() != eGameState.Playing )
		return

	wait 0.1  // if evac started on this score event, EvacStarted won't be set until a bit later

	if ( Flag( "EvacStarted" ) )
		return

	TryGameStateUpdate()
}


// =================== GAME STATE UPDATES =================== //
function TryGameStateUpdate()
{
	// game state updates shouldn't step on each other
	if ( Flag( "GameStateUpdateHappening" ) )
		return

	local militiaScore = GameRules.GetTeamScore( TEAM_MILITIA )
	local imcScore = GameRules.GetTeamScore( TEAM_IMC )

	foreach ( milestone in level.gameStateMilestones )
	{
		if ( milestone.completedByMilitia )
			continue

		// score requirements will assert if game is not playing
		if ( GetGameState() != eGameState.Playing )
			return

		local currMilitiaScoreReq 	= GetScoreRequiredForGamestateUpdate( milestone.progressPercentage, militiaScore )
		local currIMCScoreReq 		= GetScoreRequiredForGamestateUpdate( milestone.progressPercentage, imcScore )

		local militiaReachedScore = militiaScore >= currMilitiaScoreReq
		local imcReachedScore = imcScore >= currIMCScoreReq

		local winningTeam = null
		if ( militiaReachedScore )
			winningTeam = TEAM_MILITIA
		else if ( imcReachedScore )
			winningTeam = TEAM_IMC

		if ( !winningTeam )
			break  // don't bother testing higher score milestones if the lower one hasn't been hit

		// if the IMC are winning but they completed this milestone already, skip it
		if ( winningTeam == TEAM_IMC && milestone.completedByIMC )
			break

		local elapsedTime = level.nv.gameEndTime - Time()

		local winnerScore = ( winningTeam == TEAM_MILITIA ) ? militiaScore : imcScore
		printt( "Score for", milestone.progressPercentage, "% milestone reached by team", winningTeam, "- (", winnerScore, "/", level.scoreLimit, ", elapsedTime:", elapsedTime, ") - doing game state update" )
		printt( "militia currScore:", militiaScore, "currScoreReq:", currMilitiaScoreReq, "for progress %", milestone.progressPercentage )
		printt( "IMC currScore:", militiaScore, "currScoreReq:", currIMCScoreReq, "for progress %", milestone.progressPercentage )

		if ( milestone.isTeamSpecific == true )
		{
			if ( winningTeam == TEAM_MILITIA )
				milestone.completedByMilitia = true
			else if ( winningTeam == TEAM_IMC )
				milestone.completedByIMC = true
		}
		else
		{
			milestone.completedByMilitia = true
			milestone.completedByIMC = true
		}

		ProcessGameStateUpdate( milestone, winningTeam )

		break  // if we processed a score update, don't do another one right now
	}
}

function GetScoreRequiredForGamestateUpdate( ogScorePercentReq, currScore, timeRemaining = null )
{
	Assert( GetGameState() == eGameState.Playing, "Can't calculate required score unless game is actively playing. Current gamestate: " + GetGameState() )

	local scoreFraqReq = ogScorePercentReq * 0.01
	local unadjustedScoreReq = level.scoreLimit * scoreFraqReq

	if ( !GameRules.TimeLimitEnabled() || currScore < 1 )
		return unadjustedScoreReq

	if ( !timeRemaining )
		timeRemaining = level.nv.gameEndTime - Time()

	// ( CAS / SAS ) * ( scoreLimit * scoreFracReq )

	local timePlaying = level.matchTimeLimitSeconds - timeRemaining //GameTime.TimeSpentInCurrentState()

	local currentAverageScore = currScore / timePlaying
	//printt( "----- currentScorePerSec:", currentAverageScore, "avgScorePerSec:", level.avgScorePerSecondToWin )

	// if we're scoring at the normal rate or faster, don't do compression on the score requirement
	if ( currentAverageScore >= level.avgScorePerSecondToWin )
		return unadjustedScoreReq

	// KNOWN ISSUE when CAS = zero, it starts to moosh the updates together
	// - if we have lots of time remaining don't be so aggressive about the score requirement compressing: if zero,
	//   should it just be 25%/50%/75% of the time limit when the update happens?
	//
	// - remember, if the time elapses and militia has won, we need the ship to blow up.
	//   Just need to get the ship to a point where the breaking apart anim looks good. (past the 25% shot?)
	//   Might need a few different kinds of ending VO to reflect a "real" victory vs the players just F'ing around

	local scoringRateAdjustment = currentAverageScore / level.avgScorePerSecondToWin
	//printt( "----- scoringRateAdjustment:", scoringRateAdjustment, "for CAS", currentAverageScore, "over avgScoreToWin", level.avgScorePerSecondToWin )

	local adjustedScoreReqForUpdate = floor( ( scoringRateAdjustment * unadjustedScoreReq ) + 0.5 )
	return adjustedScoreReqForUpdate
}

function TestScoreCompression( fakeCurrScore = 10 )
{
	local percs = []
	percs.append( 5 )
	percs.append( 25 )
	percs.append( 50 )
	percs.append( 75 )

	local timeInc = 60

	foreach ( perc in percs )
	{
		local currTimeElapsed = 0
		while ( currTimeElapsed <= level.matchTimeLimitSeconds )
		{
			currTimeElapsed += timeInc
			if ( currTimeElapsed > level.matchTimeLimitSeconds )
				break

			local timeRemaining = level.matchTimeLimitSeconds - currTimeElapsed
			local scoreReq = GetScoreRequiredForGamestateUpdate( perc, fakeCurrScore, timeRemaining )

			//printt( "For score", fakeCurrScore, "at match %", perc, ", with", timeRemaining, "secs left, compress to", scoreReq, "required score." )
			printt( "At match %", perc, ", with", timeRemaining, "secs left, compress to", scoreReq, "required score, based on current score of", fakeCurrScore )
		}

		wait 0.05
	}
}

function ProcessGameStateUpdate( milestone, winningTeam )
{
	level.ent.Signal( "GameStateUpdate" )  // redundant?

	local prog = milestone.progressPercentage

	if ( prog >= GAMESTATE_EARLY && prog < GAMESTATE_QUARTER )
		prog = GAMESTATE_EARLY
	else if ( prog >= GAMESTATE_QUARTER && prog < GAMESTATE_HALF )
		prog = GAMESTATE_QUARTER
	else if ( prog >= GAMESTATE_HALF && prog < GAMESTATE_THREEQUARTER )
		prog = GAMESTATE_HALF
	else if ( prog >= GAMESTATE_THREEQUARTER )
		prog = GAMESTATE_THREEQUARTER

	local mcorReachedFirst = !( milestone.completedByIMC )

	switch ( prog )
	{
		case GAMESTATE_EARLY:
			thread JumpDrivesDisabled()
			break

		case GAMESTATE_QUARTER:
			thread GameStateUpdate_QuarterMark( winningTeam, mcorReachedFirst )
			break

		case GAMESTATE_HALF:
			thread GameStateUpdate_HalfwayMark( winningTeam, mcorReachedFirst )
			break

		case GAMESTATE_THREEQUARTER:
			thread GameStateUpdate_ThreeQuarterMark( winningTeam, mcorReachedFirst )
			break
	}
}

function GameStateUpdate_Start()
{
	level.ent.Signal( "GameStateUpdate" )
	SetGlobalForcedDialogueOnly( true )
	FlagSet( "GameStateUpdateHappening" )

	printt( "Game state update start! GameStateUpdateHappening set." )
}

function GameStateUpdate_Finish()
{
	SetGlobalForcedDialogueOnly( false )
	FlagClear( "GameStateUpdateHappening" )

	printt( "Game state update finished! GameStateUpdateHappening cleared." )
}

function JumpDrivesDisabled( isDev = false )
{
	if ( isDev )
	{
		CapitalShipReset()
		StopSoundOnEntity( level.capitalShipAudioEnt, "outpost207_Sentinel_Idle_Engine" )
		SnapCannonToAngles( level.cannonStartAngles )
	}

	level.ent.EndSignal( "CapitalShipEscaping" )

	GameStateUpdate_Start()

	waitthread TechTeamSequence()

	local waitBeforeFiring = 5

	thread JumpDrives_VO_And_VDU()

	thread CapitalShip_PlayAdditiveAnim( "ca_Outpost_warpPrepare" )

	// timed to end the move as the shot hits it
	local moveTime = waitBeforeFiring + 12
	thread CapitalShip_MoveAwayFromStation( moveTime )
	EmitSoundOnEntity( level.capitalShipAudioEnt, "outpost207_Sentinel_Idle_Engine" )

	wait waitBeforeFiring

	thread AimAndFire( "Impact_1" )
	level.cannon.WaitSignal( "CannonFired" )

	EmitSoundOnEntity( level.capitalShipAudioEnt, "outpost207_Sentinel_Hit1" )

	FlagSet( "CapitalShip_JumpDrivesDisabled" )

	// capital ship starts next move
	thread CapitalShip_DriftSegment_1( 60 )

	wait 7

	ForcePlayConversationToTeam( "JumpDrivesDisabled_pt2", TEAM_MILITIA )
	ForcePlayConversationToTeam( "JumpDrivesDisabled_pt2", TEAM_IMC )

	wait 5

	local winningTeam = GetCurrentWinner( TEAM_MILITIA )

	if ( winningTeam == TEAM_MILITIA )
	{
		ForcePlayConversationToTeam( "JumpDrivesDisabled_pt2_mcorWinning", TEAM_MILITIA )
		wait 4
	}
	else
	{
		ForcePlayConversationToTeam( "JumpDrivesDisabled_pt2_imcWinning", TEAM_MILITIA )
		wait 8  // two lines here
	}

	GameStateUpdate_Finish()
}

function JumpDrives_VO_And_VDU()
{
	level.ent.EndSignal( "CapitalShipEscaping" )

	ForcePlayConversationToTeam( "JumpDrivesDisabled", TEAM_IMC )
	wait 3
	ForcePlayConversationToTeam( "JumpDrivesDisabled", TEAM_MILITIA )
	wait 10

	RemoteFunctionCall_AllPlayers_NonReplay( "ServerCallback_VDU_JumpDriveSequence" )
}

function TechTeamSequence()
{
	RemoteFunctionCall_AllPlayers_NonReplay( "ServerCallback_VDU_TechTeamSequence" )

	wait 12.25  // tech team VDU sequence takes 10.25 seconds, wait an extra 2 second for coverage
}


//script thread GameStateUpdate_QuarterMark( TEAM_MILITIA, true )
function GameStateUpdate_QuarterMark( currentWinner, mcorReachedFirst )
{
	printt( "starting quarter mark update with winner:", currentWinner )

	GameStateUpdate_Start()

	level.ent.EndSignal( "GameStateUpdate" )

	OnThreadEnd(
		function() : ()
		{
			printt( "GameStateUpdate_QuarterMark finished" )
			GameStateUpdate_Finish()
		}
	)

	// IMC score limit: cannon doesn't fire
	if ( currentWinner == TEAM_IMC )
	{
		ForcePlayConversationToAll( "Gamestate_QuarterScore_IMC_ReachedScore" )
		wait 10
	}
	// otherwise we need to play conditional dialogue and fire the cannon
	else
	{
		if ( mcorReachedFirst )
		{
			ForcePlayConversationToAll( "Gamestate_QuarterScore_MCOR_ReachedScore" )
			wait 9
		}
		else
		{
			ForcePlayConversationToTeam( "Gamestate_QuarterScore_MCOR_ReachedScore", TEAM_IMC )
			wait 1
			ForcePlayConversationToTeam( "Gamestate_QuarterScore_MCOR_ReachedScore_AfterIMC", TEAM_MILITIA )
			wait 7
		}

		thread GameStateUpdate_QuarterMark_CapitalShipVDUs()

		thread AimAndFire( "Impact_2" )
		level.cannon.WaitSignal( "CannonFired" )

		EmitSoundOnEntity( level.capitalShipAudioEnt, "outpost207_Sentinel_Hit2" )

		local moveMins = 2
		thread CapitalShip_DriftSegment_2( moveMins * 60 )

		wait 5  // let the cannon firing SFX play

		EmitSoundOnEntity( level.capitalShipAudioEnt, "outpost207_Sentinel_Fire_Light" )

		if ( mcorReachedFirst )
		{
			ForcePlayConversationToAll(  "Gamestate_QuarterScore_MCOR_ReachedScore_pt2" )
			wait 10
		}
		else
		{
			ForcePlayConversationToAll(  "Gamestate_QuarterScore_MCOR_ReachedScore_AfterIMC_pt2" )
			wait 10
		}
	}

	printt( "finishing quarter mark update with winner:", currentWinner )
}

function GameStateUpdate_QuarterMark_CapitalShipVDUs()
{
	level.ent.EndSignal( "GameStateUpdate" )

	wait 3
	VDU_WatchCapitalShip( 13, 25, TEAM_MILITIA )

	wait 6.25
	VDU_WatchCapitalShip( 9.2, 28, TEAM_IMC )
}

function GameStateUpdate_HalfwayMark( currentWinner, mcorReachedFirst )
{
	printt( "starting halfway mark update with winner:", currentWinner )

	FlagSet( "MCOR_ReachedHalfScore" )

	GameStateUpdate_Start()

	level.ent.EndSignal( "GameStateUpdate" )

	OnThreadEnd(
		function() : ()
		{
			printt( "GameStateUpdate_HalfwayMark finished" )
			GameStateUpdate_Finish()
		}
	)

	// IMC score limit: cannon doesn't fire
	if ( currentWinner == TEAM_IMC )
	{
		ForcePlayConversationToAll( "Gamestate_HalfScore_IMC_ReachedScore" )
		wait 10
	}
	// otherwise we need to play conditional dialogue and fire the cannon
	else
	{
		if ( mcorReachedFirst )
		{
			ForcePlayConversationToTeam( "Gamestate_HalfScore_MCOR_ReachedScore", TEAM_MILITIA )
			wait 4
			ForcePlayConversationToTeam( "Gamestate_HalfScore_MCOR_ReachedScore", TEAM_IMC )
			wait 6
		}
		else
		{
			ForcePlayConversationToTeam( "Gamestate_HalfScore_MCOR_ReachedScore_AfterIMC", TEAM_MILITIA )
			wait 2
			ForcePlayConversationToTeam( "Gamestate_HalfScore_MCOR_ReachedScore_AfterIMC", TEAM_IMC )
			wait 4
		}

		thread GameStateUpdate_HalfwayMark_CapitalShipVDUs()

		thread AimAndFire( "Impact_3" )
		level.cannon.WaitSignal( "CannonFired" )

		EmitSoundOnEntity( level.capitalShipAudioEnt, "outpost207_Sentinel_Hit3" )

		local moveMins = 2
		thread CapitalShip_DriftSegment_3( moveMins * 60 )

		wait 5  // let the cannon firing SFX play

		if ( mcorReachedFirst )
		{
			ForcePlayConversationToAll(  "Gamestate_HalfScore_MCOR_ReachedScore_pt2" )
			wait 12
		}
		else
		{
			ForcePlayConversationToAll(  "Gamestate_HalfScore_MCOR_ReachedScore_AfterIMC_pt2" )
			wait 10
		}
	}

	printt( "finishing halfway mark update with winner:", currentWinner )
}

function GameStateUpdate_HalfwayMark_CapitalShipVDUs()
{
	level.ent.EndSignal( "GameStateUpdate" )
	wait 1.75

	thread VDU_WatchCapitalShip( 14.5, 25, TEAM_IMC )
	thread VDU_WatchCapitalShip( 14.5, 25, TEAM_MILITIA )
}

function GameStateUpdate_ThreeQuarterMark( currentWinner, mcorReachedFirst )
{
	printt( "starting 3/4 mark update with winner:", currentWinner )

	GameStateUpdate_Start()

	level.ent.EndSignal( "GameStateUpdate" )

	OnThreadEnd(
		function() : ()
		{
			printt( "GameStateUpdate_ThreeQuarterMark finished" )
			GameStateUpdate_Finish()
		}
	)

	// IMC score limit: cannon doesn't fire
	if ( currentWinner == TEAM_IMC )
	{
		ForcePlayConversationToAll( "Gamestate_ThreeQuarterScore_IMC_ReachedScore" )
		wait 15
	}
	// otherwise we need to play conditional dialogue and fire the cannon
	else
	{
		if ( mcorReachedFirst )
		{
			ForcePlayConversationToTeam( "Gamestate_ThreeQuarterScore_MCOR_ReachedScore", TEAM_IMC )
			ForcePlayConversationToTeam( "Gamestate_ThreeQuarterScore_MCOR_ReachedScore", TEAM_MILITIA )
			wait 6
		}
		else
		{
			ForcePlayConversationToTeam( "Gamestate_ThreeQuarterScore_MCOR_ReachedScore_AfterIMC", TEAM_IMC )
			wait 5
			ForcePlayConversationToTeam( "Gamestate_ThreeQuarterScore_MCOR_ReachedScore_AfterIMC", TEAM_MILITIA )
			wait 5
		}

		thread GameStateUpdate_ThreeQuarterMark_CapitalShipVDUs()

		thread AimAndFire( "Impact_4" )
		level.cannon.WaitSignal( "CannonFired" )

		EmitSoundOnEntity( level.capitalShipAudioEnt, "outpost207_Sentinel_Hit4" )

		local moveMins = 2
		thread CapitalShip_DriftSegment_4( moveMins * 60 )

		wait 5  // let the cannon firing SFX play

		StopSoundOnEntity( level.capitalShipAudioEnt, "outpost207_Sentinel_Fire_Light" )
		EmitSoundOnEntity( level.capitalShipAudioEnt, "outpost207_Sentinel_Fire_Heavy" )

		if ( mcorReachedFirst )
		{
			ForcePlayConversationToAll(  "Gamestate_ThreeQuarterScore_MCOR_ReachedScore_pt2" )
			wait 10
		}
		else
		{
			ForcePlayConversationToTeam(  "Gamestate_ThreeQuarterScore_MCOR_ReachedScore_AfterIMC_pt2", TEAM_MILITIA )
			ForcePlayConversationToTeam(  "Gamestate_ThreeQuarterScore_MCOR_ReachedScore_pt2", TEAM_IMC )  // NOTE this is the only post-firing conversation for this IMC gamestate update, no alt
			wait 10
		}
	}

	printt( "finishing 3/4 mark update with winner:", currentWinner )
}

function GameStateUpdate_ThreeQuarterMark_CapitalShipVDUs()
{
	level.ent.EndSignal( "GameStateUpdate" )

	wait 3
	thread VDU_WatchCapitalShip( 12, 30, TEAM_MILITIA )
	wait 0.7
	thread VDU_WatchCapitalShip( 12, 30, TEAM_IMC )
}

function VDU_WatchCapitalShip( vduActiveTime, finalFOV, team = null )
{
	local players

	if ( !team )
		players = GetPlayerArray()
	else
		players = GetPlayerArrayOfTeam( team )

	foreach ( player in players )
		Remote.CallFunction_NonReplay( player, "ServerCallback_VDU_WatchCapitalShip", vduActiveTime, finalFOV )
}

function VDU_WatchCapitalShip_Escape( vduActiveTime, finalFOV, team = null )
{
	local players

	if ( !team )
		players = GetPlayerArray()
	else
		players = GetPlayerArrayOfTeam( team )

	foreach ( player in players )
		Remote.CallFunction_NonReplay( player, "ServerCallback_VDU_WatchCapitalShip_Escape", vduActiveTime, finalFOV )
}

function KillScriptedVDUs()
{
	local players = GetPlayerArray()

	foreach ( player in players )
		Remote.CallFunction_NonReplay( player, "ServerCallback_ResetCannonVDU" )
}


// =================== CAPITAL SHIP MOVE PATH =================== //
// used for testing, to show the whole path at once
function CapitalShipDriftPath( driftSecs = null, skippedTo = null )
{
	if ( !driftSecs )
		driftSecs = 30

	if ( skippedTo )
		CapitalShipReset()

	level.ent.EndSignal( "CapitalShipResetting" )

	// roughly split the time
	local firstMoveTime = driftSecs * 0.25
	local crashTime = driftSecs * 0.75

	// first move - tries to escape
	thread CapitalShip_MoveAwayFromStation( firstMoveTime )
	wait firstMoveTime

	// split the segments up evenly
	local crashSegmentMoveTime = crashTime * 0.25

	// now it crashes slowly toward the level
	thread CapitalShip_DriftSegment_1( crashSegmentMoveTime )
	wait crashSegmentMoveTime

	thread CapitalShip_DriftSegment_2( crashSegmentMoveTime )
	wait crashSegmentMoveTime

	thread CapitalShip_DriftSegment_3( crashSegmentMoveTime )
	wait crashSegmentMoveTime

	thread CapitalShip_DriftSegment_4( crashSegmentMoveTime )
	wait crashSegmentMoveTime
}

// first move before jump drives are disabled
function CapitalShip_MoveAwayFromStation( moveTime = null, skippedTo = null )
{
	if ( !moveTime )
		moveTime = 60

	if ( skippedTo )
		CapitalShipReset()

	thread FadeFacade( moveTime * 0.65 )

	local movePos = CapitalShip_GetFirstMoveEndPos()
	thread CapitalShipDrift( moveTime, movePos, level.capitalShip.GetAngles(), moveTime * 0.3 )

	wait( moveTime )
}

function CapitalShip_GetFirstMoveEndPos()
{
	local forward = level.CAPITAL_SHIP_REF_ANG.AnglesToForward()
	local firstMoveOrg = level.CAPITAL_SHIP_REF_ORG + ( forward * level.CAPITAL_SHIP_FIRST_MOVE_DIST )

	return firstMoveOrg
}

function CapitalShip_DriftSegment_1( moveTime = null, skippedTo = null )
{
	level.ent.Signal( "CapitalShipDriftSegment" )
	level.ent.EndSignal( "CapitalShipDriftSegment" )

	if ( !moveTime )
		moveTime = 5

	if ( skippedTo )
	{
		StopCarrierDamageFX()

		CapitalShip_StopScriptedMove()
		CapitalShipResetPosition( level.CAPSHIP_DRIFT_PATH_START_ORG, level.CAPSHIP_DRIFT_PATH_START_ANG )
	}

	thread CapitalShipDrift( moveTime, level.CAPSHIP_DRIFT_PATH_MOVE_1_ORG, level.CAPSHIP_DRIFT_PATH_MOVE_1_ANG )

	wait 0.05
	CapitalShip_ModelSwap( CAPITAL_SHIP_MODEL_DMG_1 )
	wait 0.05
	thread CapitalShip_HitReactionAnim( "ca_Outpost_warpInterrupt" )
}

function CapitalShip_DriftSegment_2( moveTime = null, skippedTo = null )
{
	level.ent.Signal( "CapitalShipDriftSegment" )
	level.ent.EndSignal( "CapitalShipDriftSegment" )

	if ( !moveTime )
		moveTime = 5

	if ( skippedTo )
	{
		StopCarrierDamageFX()
		delaythread( 0.1 ) PlayCarrierDamageFX( null, "Impact_1" )
		delaythread( 0.1 ) PlayCarrierDamageFX( null, "Impact_1b" )

		CapitalShip_StopScriptedMove()
		CapitalShipResetPosition( level.CAPSHIP_DRIFT_PATH_MOVE_1_ORG, level.CAPSHIP_DRIFT_PATH_MOVE_1_ANG )
	}

	thread CapitalShipDrift( moveTime, level.CAPSHIP_DRIFT_PATH_MOVE_2_ORG, level.CAPSHIP_DRIFT_PATH_MOVE_2_ANG )

	wait 0.05
	CapitalShip_ModelSwap( CAPITAL_SHIP_MODEL_DMG_2 )
	wait 0.05
	thread CapitalShip_HitReactionAnim( "ca_Outpost_hit25" )
}

function CapitalShip_DriftSegment_3( moveTime = null, skippedTo = null )
{
	level.ent.Signal( "CapitalShipDriftSegment" )
	level.ent.EndSignal( "CapitalShipDriftSegment" )

	if ( !moveTime )
		moveTime = 5

	if ( skippedTo )
	{
		StopCarrierDamageFX()
		delaythread( 0.1 ) PlayCarrierDamageFX( null, "Impact_1" )
		delaythread( 0.1 ) PlayCarrierDamageFX( null, "Impact_1b" )
		delaythread( 0.1 ) PlayCarrierDamageFX( null, "Impact_2" )
		delaythread( 0.1 ) PlayCarrierDamageFX( null, "Impact_2b" )

		CapitalShip_StopScriptedMove()
		CapitalShipResetPosition( level.CAPSHIP_DRIFT_PATH_MOVE_2_ORG, level.CAPSHIP_DRIFT_PATH_MOVE_2_ANG )
	}

	thread CapitalShipDrift( moveTime, level.CAPSHIP_DRIFT_PATH_MOVE_3_ORG, level.CAPSHIP_DRIFT_PATH_MOVE_3_ANG )

	wait 0.05
	CapitalShip_ModelSwap( CAPITAL_SHIP_MODEL_DMG_3 )
	wait 0.05
	thread CapitalShip_HitReactionAnim( "ca_Outpost_hit50" )
}

function CapitalShip_DriftSegment_4( moveTime = null, skippedTo = null )
{
	level.ent.Signal( "CapitalShipDriftSegment" )
	level.ent.EndSignal( "CapitalShipDriftSegment" )

	if ( !moveTime )
		moveTime = 5

	if ( skippedTo )
	{
		StopCarrierDamageFX()
		delaythread( 0.1 ) PlayCarrierDamageFX( null, "Impact_1" )
		delaythread( 0.1 ) PlayCarrierDamageFX( null, "Impact_1b" )
		delaythread( 0.1 ) PlayCarrierDamageFX( null, "Impact_2" )
		delaythread( 0.1 ) PlayCarrierDamageFX( null, "Impact_2b" )
		delaythread( 0.1 ) PlayCarrierDamageFX( null, "Impact_3" )
		delaythread( 0.1 ) PlayCarrierDamageFX( null, "Impact_3b" )

		CapitalShipReset()
		CapitalShipResetPosition( level.CAPSHIP_DRIFT_PATH_MOVE_3_ORG, level.CAPSHIP_DRIFT_PATH_MOVE_3_ANG )
	}

	thread CapitalShipDrift( moveTime, level.CAPSHIP_DRIFT_PATH_MOVE_4_ORG, level.CAPSHIP_DRIFT_PATH_MOVE_4_ANG )

	wait 0.05
	CapitalShip_ModelSwap( CAPITAL_SHIP_MODEL_DMG_4 )
	wait 0.05
	thread CapitalShip_HitReactionAnim( "ca_Outpost_hit75" )
}

function CapitalShip_SetToFinalDriftPathPos()
{
	local cs = level.capitalShip

	CapitalShip_ModelSwap( CAPITAL_SHIP_MODEL_DMG_4 )

	if ( Distance( cs.GetOrigin(), level.CAPSHIP_DRIFT_PATH_MOVE_4_ORG ) >= 0.5 )
		CapitalShipResetPosition( level.CAPSHIP_DRIFT_PATH_MOVE_4_ORG, level.CAPSHIP_DRIFT_PATH_MOVE_4_ANG )
}

function CapitalShip_HitReactionAnim( hitReactAnim = "ca_Outpost_hit01" )
{
	level.ent.EndSignal( "CapitalShipResetting" )
	level.ent.EndSignal( "CapitalShipEscaping" )

	CapitalShip_PlayAdditiveAnim( hitReactAnim )

	// idle after the hit react anim is done
	level.capitalShip.Anim_Play( "ca_Outpost_idle" )
	level.capitalShip.Anim_EnableUseAnimatedRefAttachmentInsteadOfRootMotion()
}

function CapitalShip_PlayAdditiveAnim( animname )
{
	local animtime = level.capitalShip.GetSequenceDuration( animname )

	level.capitalShip.Anim_Play( animname )
	level.capitalShip.Anim_EnableUseAnimatedRefAttachmentInsteadOfRootMotion()

	wait animtime
}


// =========== IMC CAPITAL SHIP =========== //
// this ship is in the skybox
function CapitalShipSetup()
{
	local spawnOrg = level.CAPITAL_SHIP_REF_ORG
	local spawnAng = level.CAPITAL_SHIP_REF_ANG

	local capShip = CreateEntity( "script_mover" )
	capShip.kv.solid = 0
	capShip.kv.model = CAPITAL_SHIP_MODEL_CLEAN
	capShip.kv.SpawnAsPhysicsMover = 0
	capShip.SetOrigin( spawnOrg )
	capShip.SetAngles( spawnAng )
	capShip.SetName( "imc_capital_ship" )
	DispatchSpawn( capShip )

	level.capitalShip <- capShip

	level.capitalShip.s.moveTarget <- null
	level.capitalShip.s.dmgFX <- []
	level.capitalShip.s.fxHandles <- []

	level.capitalShipMover <- CreateScriptMover( level.capitalShip )
	level.capitalShip.SetParent( level.capitalShipMover )

	AddAnimEvent( level.capitalShip, "CarrierDmgFX_Impact_1", PlayCarrierDamageFX, "Impact_1" )
	AddAnimEvent( level.capitalShip, "CarrierDmgFX_Impact_1b", PlayCarrierDamageFX, "Impact_1b" )

	AddAnimEvent( level.capitalShip, "CarrierDmgFX_Impact_2", PlayCarrierDamageFX, "Impact_2" )
	AddAnimEvent( level.capitalShip, "CarrierDmgFX_Impact_2b", PlayCarrierDamageFX, "Impact_2b" )

	AddAnimEvent( level.capitalShip, "CarrierDmgFX_Impact_3", PlayCarrierDamageFX, "Impact_3" )
	AddAnimEvent( level.capitalShip, "CarrierDmgFX_Impact_3b", PlayCarrierDamageFX, "Impact_3b" )

	AddAnimEvent( level.capitalShip, "CarrierDmgFX_Impact_4", PlayCarrierDamageFX, "Impact_4" )
	AddAnimEvent( level.capitalShip, "CarrierDmgFX_Impact_4b", PlayCarrierDamageFX, "Impact_4b" )

	level.capitalShipAudioEnt = CreateScriptMover( null, Vector( 3600, -16000, 4500 ), Vector( 0, 0, 0 ) )
}

function CapitalShip_Escapes( earlyEscape, isDev = false )
{
	level.ent.Signal( "CapitalShipDriftSegment" )
	level.ent.Signal( "CapitalShipEscaping" )

	if ( isDev )
	{
		CapitalShipReset()
		level.capitalShip.Hide()

		StopSoundOnEntity( level.capitalShipAudioEnt, "outpost207_Sentinel_Escape" )

		if ( earlyEscape )
		{
			StopCarrierDamageFX()
			delaythread( 0.1 ) PlayCarrierDamageFX( null, "Impact_1" )
			delaythread( 0.1 ) PlayCarrierDamageFX( null, "Impact_1b" )

			CapitalShipResetPosition( level.CAPSHIP_DRIFT_PATH_START_ORG, level.CAPSHIP_DRIFT_PATH_START_ANG )
		}
		else
		{
			StopCarrierDamageFX()
			delaythread( 0.1 ) PlayCarrierDamageFX( null, "Impact_1" )
			delaythread( 0.1 ) PlayCarrierDamageFX( null, "Impact_1b" )
			delaythread( 0.1 ) PlayCarrierDamageFX( null, "Impact_2" )
			delaythread( 0.1 ) PlayCarrierDamageFX( null, "Impact_2b" )
			delaythread( 0.1 ) PlayCarrierDamageFX( null, "Impact_3" )
			delaythread( 0.1 ) PlayCarrierDamageFX( null, "Impact_3b" )

			CapitalShip_SetToFinalDriftPathPos()
		}

		level.capitalShip.Show()
	}
	else if ( level.devForcedWin && !Flag( "MCOR_ReachedHalfScore" ) )
	{
		earlyEscape = true
	}

	// now that we're animating the ship with translation, unparent from mover
	level.capitalShip.ClearParent()

	local escapeAnim = "ca_Outpost_end_limp_away"
	if ( earlyEscape )
		escapeAnim = "ca_Outpost_end_early_escape"

	EmitSoundOnEntity( level.capitalShipAudioEnt, "outpost207_Sentinel_Escape" )

	printt( "playing anim", escapeAnim )
	thread PlayAnimTeleport( level.capitalShip, escapeAnim, level.capitalShip.GetOrigin(), level.capitalShip.GetAngles(), 2.0 )

	if ( escapeAnim == "ca_Outpost_end_limp_away" )
	{
		wait 16
		//printt( "firing lifeboats!" )
		RemoteFunctionCall_AllPlayers_NonReplay( "ServerCallback_CapitalShip_FireLifeboats" )
		wait 8
		RemoteFunctionCall_AllPlayers_NonReplay( "ServerCallback_CapitalShip_FireLifeboats" )
		wait 7
		RemoteFunctionCall_AllPlayers_NonReplay( "ServerCallback_CapitalShip_FireLifeboats" )
	}
	else
	{
		wait 18
		RemoteFunctionCall_AllPlayers_NonReplay( "ServerCallback_CapitalShip_FireLifeboats" )
		wait 8
		RemoteFunctionCall_AllPlayers_NonReplay( "ServerCallback_CapitalShip_FireLifeboats" )
	}
}

function CapitalShip_BreaksIntoPieces( isDev = false )
{
	local cs = level.capitalShip

	if ( !( "piece1" in level ) )
	{
		level.piece1 <- null
		level.piece2 <- null
		level.piece3 <- null
		level.capitalShipBroken <- null
	}
	else if ( isDev )
	{
		CapitalShip_RestoreFromPieces()
	}

	if ( isDev )
		CapitalShip_SetToFinalDriftPathPos()

	local tag1 		= cs.LookupAttachment( "broken01" )
	local tag1Org 	= cs.GetAttachmentOrigin( tag1 )
	local tag1Ang 	= cs.GetAttachmentAngles( tag1 )

	local tag2 		= cs.LookupAttachment( "broken02" )
	local tag2Org 	= cs.GetAttachmentOrigin( tag2 )
	local tag2Ang 	= cs.GetAttachmentAngles( tag2 )

	local tag3 		= cs.LookupAttachment( "broken03" )
	local tag3Org 	= cs.GetAttachmentOrigin( tag3 )
	local tag3Ang 	= cs.GetAttachmentAngles( tag3 )

	// this model is disappearing so kill the FX playing on it
	StopAllCarrierFX()
	level.nv.capitalShipThrustersOn = false

	if ( !level.capitalShipBroken )
	{
		level.capitalShipBroken = CreateCapitalShipPiece( CAPITAL_SHIP_PIECES_MODEL )
		level.capitalShipBroken.s.destroyFX <- null
	}

	level.capitalShipBroken.SetOrigin( cs.GetOrigin() )
	level.capitalShipBroken.SetAngles( cs.GetAngles() )

	level.capitalShipBroken.s.destroyFX = PlayFXOnEntity( FX_CAPITAL_SHIP_DMG_BREAKSUP, level.capitalShipBroken, "break_impact_LG_1" )
	level.capitalShipBroken.s.destroyFX.EnableRenderAlways()
	level.capitalShipBroken.s.destroyFX.kv.in_skybox = 1

	local breakupAnim = "ca_Outpost_end_explode"
	local animStartPos = level.capitalShipBroken.Anim_GetStartForRefEntity( breakupAnim, level.capitalShipBroken, "" )
	//printt( "intact ship pos:", level.capitalShip.GetOrigin(), "broken ship pos:", level.capitalShipBroken.GetOrigin(), "anim start pos:", animStartPos.origin )
	//printt( "intact ship ang:", level.capitalShip.GetAngles(), "broken ship ang:", level.capitalShipBroken.GetAngles(), "anim start ang:", animStartPos.angles )

	thread PlayAnim( level.capitalShipBroken, breakupAnim, null, null, 0.0 )

	wait( 0.05 )
	cs.Hide()
}

function CapitalShip_RestoreFromPieces()
{
	CapitalShip_StopScriptedMove()
	level.capitalShip.Show()

	if ( "capitalShipBroken" in level && level.capitalShipBroken )
	{
		if ( "destroyFX" in level.capitalShipBroken.s )
		{
			if ( IsValid_ThisFrame( level.capitalShipBroken.s.destroyFX ) )
				KillFX( level.capitalShipBroken.s.destroyFX )

			level.capitalShipBroken.s.destroyFX = null
		}

		level.capitalShipBroken.Anim_Stop()
		level.capitalShipBroken.Kill()
		level.capitalShipBroken = null
	}

	if ( ( "piece1" in level ) && level.piece1 )
	{
		level.piece1.Hide()
		level.piece1.MoveTo( level.piece1.GetOrigin(), 0.1 )
		level.piece1.RotateTo( level.piece1.GetAngles(), 0.1 )
	}

	if ( ( "piece2" in level ) && level.piece2 )
	{
		level.piece2.Hide()
		level.piece2.MoveTo( level.piece2.GetOrigin(), 0.1 )
		level.piece2.RotateTo( level.piece2.GetAngles(), 0.1 )
	}

	if ( ( "piece3" in level ) && level.piece3 )
	{
		level.piece3.Hide()
		level.piece3.MoveTo( level.piece3.GetOrigin(), 0.1 )
		level.piece3.RotateTo( level.piece3.GetAngles(), 0.1 )
	}

	wait 0.11
}

function CreateCapitalShipPiece( modelname )
{
	local script_mover = CreateEntity( "script_mover" )
	script_mover.kv.solid = 0
	script_mover.kv.model = modelname
	script_mover.kv.SpawnAsPhysicsMover = 0
	DispatchSpawn( script_mover )
	script_mover.Show()

	return script_mover
}

function CapitalShipDrift( driftTime, endOrg, endAng, accelTime = null, decelTime = 0 )
{
	level.ent.EndSignal( "CapitalShipDriftSegment" )

	if ( !accelTime )
		accelTime = driftTime / 5

	level.capitalShip.s.moveTarget = endOrg

	level.capitalShipMover.MoveTo( endOrg, driftTime, accelTime, decelTime )
	level.capitalShipMover.RotateTo( endAng, driftTime, accelTime, decelTime )

	wait driftTime

	level.capitalShip.s.moveTarget = null
}


function CapitalShipReset()
{
	level.ent.Signal( "CapitalShipResetting" )

	StopCarrierDamageFX()
	level.nv.capitalShipThrustersOn = true

	level.capitalShip.Anim_Stop()

	CapitalShip_RestoreFromPieces()
	CapitalShip_StopScriptedMove()

	CapitalShipResetPosition( level.CAPITAL_SHIP_REF_ORG, level.CAPITAL_SHIP_REF_ANG )

	CapitalShip_ModelSwap( CAPITAL_SHIP_MODEL_CLEAN )
	ResetFacade()
}

function CapitalShipResetPosition( newOrg, newAng )
{
	level.capitalShip.ClearParent()

	level.capitalShip.SetOrigin( newOrg )
	level.capitalShip.SetAngles( newAng )
	level.capitalShipMover.SetOrigin( level.capitalShip.GetOrigin() )
	level.capitalShipMover.SetAngles( level.capitalShip.GetAngles() )
	wait 0.05

	level.capitalShip.SetParent( level.capitalShipMover )
	wait 0.05
}

// cancels any existing moveto / rotateto
function CapitalShip_StopScriptedMove()
{
	//level.capitalShip.MoveTo( level.capitalShip.GetOrigin(), 0.1 )
	//level.capitalShip.RotateTo( level.capitalShip.GetAngles(), 0.1 )
	level.capitalShipMover.MoveTo( level.capitalShipMover.GetOrigin(), 0.1 )
	level.capitalShipMover.RotateTo( level.capitalShipMover.GetAngles(), 0.1 )
	wait 0.11
}

function CapitalShip_ModelSwap( modelname )
{
	Assert( modelname == CAPITAL_SHIP_MODEL_CLEAN
			|| modelname == CAPITAL_SHIP_MODEL_DMG_1
			|| modelname == CAPITAL_SHIP_MODEL_DMG_2
			|| modelname == CAPITAL_SHIP_MODEL_DMG_3
			|| modelname == CAPITAL_SHIP_MODEL_DMG_4
			|| modelname == CAPITAL_SHIP_PIECES_MODEL,
			"capital ship model swap failed: modelname " + modelname + " not recognized" )

	//printt( "Swapping model to", modelname )

	level.capitalShip.SetModel( modelname )

	if ( modelname == CAPITAL_SHIP_MODEL_CLEAN )
		level.nv.capitalShipLightingFacadeAlpha = 1
	else
		level.nv.capitalShipLightingFacadeAlpha = 0
}

function FadeFacade( fadeTime = CAPITAL_SHIP_FACADE_FADETIME )
{
	level.ent.Signal( "StopFacadeFade" )
	level.ent.EndSignal( "StopFacadeFade" )

	local minAlpha = 0
	local maxAlpha = 1

	local fadeStart = Time()
	local fadeEnd = fadeTime + fadeStart

	while ( level.nv.capitalShipLightingFacadeAlpha > minAlpha )
	{
		local newAlpha = GraphCapped( Time(), fadeStart, fadeEnd, maxAlpha, minAlpha )
		level.nv.capitalShipLightingFacadeAlpha = newAlpha
		level.nv.spaceStationLightingFacadeAlpha = newAlpha

		wait 0.05
	}
}

function ResetFacade()
{
	level.ent.Signal( "StopFacadeFade" )

	level.nv.capitalShipLightingFacadeAlpha = 1
	level.nv.spaceStationLightingFacadeAlpha = 1
}

// first arg is required because we use this as an anim event callback
function PlayCarrierDamageFX( carrier, impactAlias )
{
	local fx = null
	local attach = null

	switch ( impactAlias )
	{
		case "Impact_1":
			fx = "P_exp_SB_carrier_NRG_LG_loop"
			attach = "Impact_1"
			break

		case "Impact_1b":
			fx = "P_exp_SB_carrier_NRG_LG_loop"
			attach = "Impact_1b"
			break

		case "Impact_2":
			fx = "P_exp_SB_carrier_LG_loop"
			attach = "Impact_2"
			break

		case "Impact_2b":
			fx = "P_exp_SB_carrier_MD_loop"
			attach = "Impact_2b"
			break

		case "Impact_3":
			fx = "P_exp_SB_carrier_LG_loop"
			attach = "Impact_3"
			break

		case "Impact_3b":
			fx = "P_exp_SB_carrier_MD_loop"
			attach = "Impact_3b"
			break

		case "Impact_4":
			fx = "P_exp_SB_carrier_LG_loop"
			attach = "Impact_4"
			break

		case "Impact_4b":
			fx = "P_exp_SB_carrier_MD_loop"
			attach = "Impact_4b"
			break

		default:
			Assert( false, "PlayCarrierDamageFX: Couldn't resolve impactAlias " + impactAlias )
			return
	}
	Assert( fx && attach )

	StartCarrierDamageFX( fx, attach )
}

function StartCarrierDamageFX( fxName, attachAlias )
{
	local fxHandle = PlayLoopFXOnEntity( fxName, level.capitalShip, attachAlias )
	fxHandle.EnableRenderAlways()
	fxHandle.kv.in_skybox = 1

	level.capitalShip.s.dmgFX.append( fxHandle )
	AddCarrierFX( fxHandle )
}

function StopCarrierDamageFX()
{
	if ( !level.capitalShip.s.dmgFX.len() )
		return

	foreach ( fxHandle in level.capitalShip.s.dmgFX )
	{
		if ( IsValid_ThisFrame( fxHandle ) )
		{
			KillFX( fxHandle )
		}
	}

	level.capitalShip.s.dmgFX = []
}

function StartCarrierFX( fxAlias )
{
	local fxHandle = PlayFXOnEntity( fxAlias, level.capitalShip, "c_bottom" )
	AddCarrierFX( fxHandle )
}

function AddCarrierFX( fxHandle )
{
	level.capitalShip.s.fxHandles.append( fxHandle )
}

function StopAllCarrierFX()
{
	StopCarrierDamageFX()

	foreach ( fxHandle in level.capitalShip.s.fxHandles )
		KillFX( fxHandle )
}

function KillFX( fxHandle )
{
	if ( !IsValid_ThisFrame( fxHandle ) )
		return

	fxHandle.Fire( "Stop" )
	fxHandle.ClearParent()
	fxHandle.Destroy()
}



// =========== CANNON =========== //
function CannonSetup()
{
	// --- main world cannon ---
	local ref = GetEnt( "cannon_spawn_ref" )
	local spawnOrg = ref.GetOrigin()
	local spawnAng = ref.GetAngles()

	local cannonBase = CreateEntity( "script_mover" )
	cannonBase.kv.solid = 1
	cannonBase.kv.model = CANNON_BASE_MODEL
	cannonBase.kv.SpawnAsPhysicsMover = 0
	cannonBase.SetOrigin( spawnOrg )
	cannonBase.SetAngles( spawnAng )
	DispatchSpawn( cannonBase )

	level.cannonBase <- cannonBase

	local cannon = CreateEntity( "script_mover" )
	cannon.kv.solid = 1
	cannon.kv.model = CANNON_BARREL_MODEL
	cannon.kv.SpawnAsPhysicsMover = 0
	cannon.SetName( "outpost_cannon_barrel" )
	DispatchSpawn( cannon )

	// CANNON BARREL COLLISION & HURT TRIGGERS
	local moverOrg = GetEnt( "cannon_barrel_collision_center" )
	local cbCollisionMover = CreateScriptMover( null, moverOrg.GetOrigin(), Vector( 0, 90, 0 ) )  // rotate to match the tag alignment

	local cbHurtTrig_1 = GetEnt( "trig_cannon_barrel_hurt_1" )  // back end of barrel- "splat"
	local cbHurtTrig_2 = GetEnt( "trig_cannon_barrel_hurt_2" )  // front charging part of barrel - "burn"
	local cbCollision = GetEnt( "cannon_barrel_collision" )

	cbHurtTrig_1.SetParent( cbCollisionMover, "ref", true )
	cbHurtTrig_2.SetParent( cbCollisionMover, "ref", true )
	cbCollision.SetParent( cbCollisionMover, "ref", true )
	cbCollisionMover.SetParent( cannon, "REF" )

	level.cbCollisionMover <- cbCollisionMover
	level.cbCollision <- cbCollision

	local attachIndex = cannonBase.LookupAttachment( "barrel_attachment" )
	local origin = cannonBase.GetAttachmentOrigin( attachIndex )
	local angles = cannonBase.GetAttachmentAngles( attachIndex )
	angles += Vector( 10, 0, 0 )  // start tilted up

	cannon.SetOrigin( origin )
	cannon.SetAngles( angles )
	level.cannonStartAngles <- cannon.GetAngles()

	level.cannon 				<- cannon
	level.cannon.s.isFiring 	<- null
	level.cannon.s.flapsOpened 	<- null

	level.cannon.s.target <- eOutpostCannonTargets.CAPITAL_SHIP

	local cpoint = CreateEntity( "info_placement_helper" )
	cpoint.SetName( UniqueString( "skycannon_distance_controlpoint" ) )
	DispatchSpawn( cpoint, false )
	level.cannon.s.cpointHelper <- cpoint

	CannonRefPose()

	AddAnimEvent( level.cannon, "cannon_fires", CannonFireAnimEvent )
	AddAnimEvent( level.cannon, "cannon_fire_fx", CannonFireFX )

	// starting angles for firing at the decoy ship
	SnapCannonToAngles( level.cannonStartAngles + Vector( 0, -25, -10 ) )

	// --- skybox cannons ---
	local orgLeft = Vector( 11933, 11890, -11775.2 )
	local angLeft = Vector( 15, 45, 0 )

	local orgRight = Vector( 11884, 11896.4, -11778.5 )
	local angRight = Vector( 15, 90, 0 )

	local orgCenter = Vector( 11867, 11815, -11774 )
	local angCenter = Vector( 30, 180, 0 )

	level.skyCannonL <- SkyboxCannonSetup( orgLeft, angLeft, "skybox_cannon_left" )
	level.skyCannonR <- SkyboxCannonSetup( orgRight, angRight, "skybox_cannon_right" )
	level.skyCannonC <- SkyboxCannonSetup( orgCenter, angCenter, "skybox_cannon_center" )
}

function CannonFireFX( cannon )
{
	thread CannonFireFX_Threaded()
}

function CannonFireFX_Threaded()
{
	if ( !IsValid( level.cannon ) )
		return

	Assert( "target" in level.cannon.s)
	local targetID = level.cannon.s.target
	Assert( targetID == eOutpostCannonTargets.CAPITAL_SHIP || targetID == eOutpostCannonTargets.DECOY_SHIP )

	// what are we shooting at, and where is it
	local targetEnt = null
	local entLocation = null
	if ( targetID == eOutpostCannonTargets.CAPITAL_SHIP )
	{
		targetEnt = level.capitalShip
		entLocation = "skybox"
	}
	else if ( targetID == eOutpostCannonTargets.DECOY_SHIP )
	{
		targetEnt = level.decoyShip
		entLocation = "world"
	}
	Assert( IsValid( targetEnt ), "Couldn't find ent to be targeted for targetID " + targetID )
	Assert( entLocation )

	local cannonAttach = level.cannon.LookupAttachment( "rail_flap_01" )
	local cannonAttachOrg = level.cannon.GetAttachmentOrigin( cannonAttach )
	local cannonAttachAng = level.cannon.GetAttachmentAngles( cannonAttach )

	local beamFX = PlayFX( FX_CANNON_BEAM, cannonAttachOrg, cannonAttachAng )
	beamFX.EnableRenderAlways()
}

function SkyCannons_TestRotation()
{
	thread SkyCannon_TestRotation( level.skyCannonL )
	thread SkyCannon_TestRotation( level.skyCannonR )
	thread SkyCannon_TestRotation( level.skyCannonC )
}

function RotateAndFireSkyCannonAtWorldPos( skyCannon, worldPos, rotateTime = 5, pauseBeforeFiring = 0 )
{
	Assert( IsValid( skyCannon ) )
	Assert( typeof( worldPos ) == "Vector" )

	local skycamOrg = level.skycamera.GetOrigin()

	local ogDist = Distance( worldPos, Vector( 0, 0, 0 ) )
	local scaleDist = ogDist / 1000
	//printt( "ogDist", ogDist, "scaleDist", scaleDist )

	// get point in the skybox that corresponds to worldPos
	local fwdToOffsetFromWorldCenter = worldPos - Vector( 0, 0, 0 )
	fwdToOffsetFromWorldCenter.Normalize()
	local skyboxPos = skycamOrg + ( fwdToOffsetFromWorldCenter * scaleDist )

	// figure out the vector from the skyCannon origin to the skyboxPos
	local fwdToTarget = skyCannon.GetOrigin() - skyboxPos
	fwdToTarget.Normalize()
	//printt( "fwdToTarget", fwdToTarget )

	local fireAng = VectorToAngles( fwdToTarget )
	//printt( "fireAng", fireAng )

	// rotate to fire
	//printt( "skyCannon angles", skyCannon.GetAngles() )
	if ( skyCannon.GetAngles() != fireAng )
	{
		thread RotateSkyCannonOverTime( skyCannon, fireAng, rotateTime )
		wait rotateTime
	}

	if ( pauseBeforeFiring > 0 )
		wait pauseBeforeFiring

	// create control point helper ent if we don't have one for this cannon yet
	if ( !( "cpointHelper" in skyCannon.s ) )
	{
		local cpoint = CreateEntity( "info_placement_helper" )
		cpoint.SetName( UniqueString( "skycannon_distance_controlpoint" ) )
		DispatchSpawn( cpoint, false )

		skyCannon.s.cpointHelper <- cpoint
	}

	local attachName = "rail_flap_01"
	local attachID = skyCannon.LookupAttachment( attachName )
	local attachOrg = skyCannon.GetAttachmentOrigin( attachID )

	// figure out the vector from the attach point on the sky cannon to the skyboxPos now that it's rotated
	local fwdToTarget = skyboxPos - attachOrg
	fwdToTarget.Normalize()
	//printt( "fwdToTarget", fwdToTarget )

	// figure out the end pos for the beam
	local beamLength = Distance( skycamOrg, attachOrg )
	local skyEndPos = attachOrg + ( fwdToTarget * beamLength )
	//printt( "skyboxPos:", skyboxPos, "skyEndPos", skyEndPos )

	// muzzle flash
	local muzzleFlashFX = PlayFXOnEntity( FX_CANNON_MUZZLEFLASH_SKY, skyCannon, attachName )
	muzzleFlashFX.EnableRenderAlways()
	muzzleFlashFX.kv.in_skybox = 1

	// beam
	skyCannon.s.cpointHelper.SetOrigin( skyEndPos )
	local beamFX = PlayFXWithControlPoint( FX_CANNON_BEAM_SKY, attachOrg, skyCannon.s.cpointHelper )
	beamFX.EnableRenderAlways()
}

function SkyCannon_PrefireFX( skyCannon )
{
	//printt( "starting prefire FX for cannon", skyCannon )
	local attachName = "rail_flap_01"
	local prefireFX = PlayFXOnEntity( FX_CANNON_PREFIRE_SKY, skyCannon, attachName )
	prefireFX.EnableRenderAlways()
	prefireFX.kv.in_skybox = 1
}

function SkyboxCannonSetup( spawnOrg, spawnAng, name )
{
	local cannonBase = CreateEntity( "script_mover" )
	cannonBase.kv.solid = 1
	cannonBase.kv.model = SKYCANNON_BASE_MODEL
	cannonBase.kv.SpawnAsPhysicsMover = 0
	DispatchSpawn( cannonBase )
	cannonBase.SetOrigin( spawnOrg )  // do this after DispatchSpawn, otherwise it'll round off the spawn org
	cannonBase.SetAngles( Vector( 0, spawnAng.y, 0 ) )  // always spawn them flat, yaw rotation only (won't work if you try to put it on an angled surface)

	local cannon = CreateEntity( "script_mover" )
	cannon.kv.solid = 1
	cannon.kv.model = SKYCANNON_BARREL_MODEL
	cannon.kv.SpawnAsPhysicsMover = 0
	cannon.SetName( name )
	DispatchSpawn( cannon )

	cannon.s.base <- cannonBase

	local attachIndex = cannonBase.LookupAttachment( "barrel_attachment" )
	local origin = cannonBase.GetAttachmentOrigin( attachIndex )
	local angles = cannonBase.GetAttachmentAngles( attachIndex )
	cannon.SetOrigin( origin )
	cannon.SetAngles( angles )

	cannon.s.spawnAng <- spawnAng

	// now snap to the starting angles
	SnapSkyCannonToAngles( cannon, spawnAng )

	// TEMP for testing
	//cannon.Hide()
	//return cannon.s.base

	return cannon
}


function SnapSkyCannonToOrigin( skyCannon, newOrg )
{
	local cannon = skyCannon
	local cannonBase = skyCannon.s.base

	cannonBase.SetOrigin( newOrg )

	local attachIndex = cannonBase.LookupAttachment( "barrel_attachment" )
	local origin = cannonBase.GetAttachmentOrigin( attachIndex )
	cannon.SetOrigin( origin )
}

function SnapSkyCannonToAngles( skyCannon, newAng )
{
	local barrel = skyCannon
	local cannonBase = skyCannon.s.base

	local barrelAngs = Vector( newAng.x, newAng.y, 0 )
	local baseAngs = Vector( 0, newAng.y, 0 )

	barrel.SetAngles( barrelAngs )
	cannonBase.SetAngles( baseAngs )
}

function SkyCannon_TestRotation( cannon )
{
	local startAngs = cannon.GetAngles()

	local rotateTime = 7
	local ang1 = startAngs + Vector( 5, 65, 0 )
	local ang2 = startAngs + Vector( -5, -65, 0 )

	local angs = null
	local lastAngs = 2

	while( 1 )
	{
		if ( lastAngs >= 2 )
		{
			angs = ang1
			lastAngs = 1
		}
		else
		{
			angs = ang2
			lastAngs = 2
		}

		RotateSkyCannonOverTime( cannon, angs, rotateTime )
		wait rotateTime + 1
	}
}

function RotateSkyCannonOverTime( skyCannon, newAng, rotateTime, accelTime = null, decelTime = 0 )
{
	local barrel = skyCannon
	local cannonBase = skyCannon.s.base

	local barrelAngs = Vector( newAng.x, newAng.y, 0 )
	local baseAngs = Vector( 0, newAng.y, 0 )

	if ( !accelTime )
		accelTime = rotateTime * 0.1

	if ( !decelTime )
		decelTime = rotateTime * 0.1

	barrel.RotateTo( barrelAngs, rotateTime, accelTime, decelTime )
	cannonBase.RotateTo( baseAngs, rotateTime, accelTime, decelTime )
}

function TestSkyboxCannon()
{
	local player = GetPlayerArray()[0]

	local cannon = SkyboxCannonSetup( player.EyePosition(), player.GetAngles(), "test_skybox_cannon" )

	printt( "SKYCANNON INFO: ORG:", cannon.GetOrigin(), "| ANG:", cannon.GetAngles() )
}

function AimAndFire( attachAlias = null )
{
	level.ent.EndSignal( "GameStateUpdate" )

	thread FireCannon()
	wait 2
	thread AimCannonAtCapitalShip( attachAlias )
}

function AimCannonAtCapitalShip( attachAlias = null )
{
	local cannonAttach = level.cannon.LookupAttachment( "rail_flap_01" )
	local cannonAttachOrg = level.cannon.GetAttachmentOrigin( cannonAttach )

	local targetPos = GetTargetPosForEntity( level.capitalShip, attachAlias )
	local vec = GetVectorFromWorldPosToSkyboxPos( cannonAttachOrg, targetPos )
	local angs = VectorToAngles( vec )

	thread RotateCannonToAngles( angs, 7 )
}

function FireCannon()
{
	level.ent.EndSignal( "GameStateUpdate" )

	level.cannon.s.flapsOpened = null

	OnThreadEnd (
		function () : ()
		{
			if ( level.cannon.s.isFiring )
			{
				printt( "aborting firing sequence")

				StopSoundOnEntity( level.cannon, "Outpost207_Railgun_Warmup" )

				if ( level.cannon.s.flapsOpened )
					thread CannonFlapsClose()

				if ( level.nv.cannonVentingFXOn )
					CannonVentSteamOff()

				level.cannon.s.isFiring = null
			}
		}
	)

	level.ent.Signal( "CannonFireSequenceStart" )

	delaythread( 1 ) StartCannonWarningVO()
	thread CannonPrefireKlaxons()
	delaythread( 1.2 ) WarningLightsOn()
	CannonMonitors_ScreenChange( level.CANNON_SCREEN_FIRING )

	wait 2

	level.cannon.s.isFiring = 1

	CannonFlapsOpen()
	level.cannon.WaittillAnimDone()

	level.cannon.Signal( "CannonFlapsOpen" )

	thread CannonThermalDrumsSpin()

	// little pause between warming up and firing
	wait 2.3

	CannonFire()
	delaythread( 1.05 ) FireCannon_CooldownSound()  // cooldown sound is authored to start during the firing animation

	level.cannon.WaitSignal( "CannonFired" )
	delaythread( 0.5 ) CannonVentSteamOn()
	delaythread( 0.25 ) CannonMonitors_ScreenChange( level.CANNON_SCREEN_COOLING )

	level.cannon.WaittillAnimDone()

	CannonFlapsClose()
	level.cannon.WaittillAnimDone()

	delaythread( 1 ) CannonThermalDrumsSpin_Stop()
	thread WarningLightsOff()
	thread DelayedCannonMonitorScreensReset( 7 )
	thread DelayedCannonVentSteamOff( 8 )

	level.cannon.s.isFiring = null
}

function FireCannon_CooldownSound()
{
	EmitSoundOnEntity( level.cannon, "Outpost207_Railgun_Cooldown" )
}

function RotateCannonToAngles( angs, rotateTime, accel = 1, decel = 1, doSound = true )
{
	if ( doSound )
		EmitSoundOnEntity( level.cannon, SFX_CANNON_ROTATE_LOOP )

	level.cannon.RotateTo( Vector( angs.x, angs.y, 0 ), rotateTime, accel, decel )
	level.cannonBase.RotateTo( Vector( 0, angs.y, 0 ), rotateTime, accel, decel )

	level.ent.EndSignal( "GameStateUpdate" )

	OnThreadEnd (
	   	function () : ()
	 	{
	 		StopSoundOnEntity( level.cannon, SFX_CANNON_ROTATE_LOOP )
	 	}
	 )

	Wait( rotateTime )
}

function SnapCannonToAngles( angs )
{
	level.cannon.SetAngles( Vector( angs.x, angs.y, 0 ) )
	level.cannonBase.SetAngles( Vector( 0, angs.y, 0 ) )
}

function CannonRefPose()
{
	level.cannon.Anim_Stop()
	level.cannon.Anim_Play( "flaps_close_idle" )
}

function CannonFlapsOpen()
{
	level.cannon.Anim_Stop()
	level.cannon.Anim_Play( "flaps_open" )

	level.cannon.s.flapsOpened = 1
}

function CannonFire()
{
	level.cannon.Anim_Stop()
	level.cannon.Anim_Play( "fire" )
}

function CannonFlapsClose()
{
	level.cannon.Anim_Stop()
	level.cannon.Anim_Play( "flaps_close" )

	level.cannon.s.flapsOpened = null
}

function CannonFireAnimEvent( cannon )
{
	level.cannon.Signal( "CannonFired" )
	CannonFireShake()
}

function CannonFireShake()
{
	local shake = CreateEntity( "env_shake" )
	shake.SetOrigin( level.cannonBase.GetOrigin() )
	shake.kv.amplitude = 15
	shake.kv.duration = 0.75
	shake.kv.frequency = 255
	shake.kv.radius = 5000000
	shake.kv.spawnflags = 29  // GlobalShake, In Air, Physics, Ropes
	DispatchSpawn( shake, false )

	shake.Fire( "StartShake" )
	shake.Kill( 1 )
}

function StartCannonWarningVO()
{
	RemoteFunctionCall_AllPlayers( "ServerCallback_CannonWarningVO" )
}

function CannonPrefireKlaxons()
{
	if ( level.klaxonsActive )
		return

	StartKlaxons()

	level.cannon.WaitSignal( "CannonFired" )

	StopKlaxons()
}

function StartKlaxons()
{
	level.klaxonsActive = 1

	PlaySoundFromAlarmEmitters( SFX_CANNON_PREFIRE_KLAXON_LOOP )
}

function StopKlaxons()
{
	level.klaxonsActive = null

	StopSoundOnEntity( level.worldspawn, SFX_CANNON_PREFIRE_KLAXON_LOOP )
}

function AlarmLocationsSetup()
{
	level.alarmLocations <- []

	local refs = GetEntArrayByName_Expensive( "ref_siren" )
	foreach ( ref in refs )
	{
		AddAlarmLocation( ref.GetOrigin() )
	}
}

function AddAlarmLocation( vecLoc )
{
	local refName = "klaxon" + level.alarmLocations.len()
	AddSavedLocation( refName, vecLoc, 0 )

	level.alarmLocations.append( refName )
}

function PlaySoundFromAlarmEmitters( alias )
{
	foreach ( locName in level.alarmLocations )
	{
		local loc = GetSavedLocation( locName )
		EmitSoundAtPosition( loc.origin, alias )
	}
}

function CannonThermalDrumsSpin()
{
	 level.nv.cannonThermalDrumsSpin = 1
}

function CannonThermalDrumsSpin_Stop()
{
	 level.nv.cannonThermalDrumsSpin = null
}

function DelayedCannonThermalDrumsStop( delaytime )
{
	level.ent.EndSignal( "CannonFireSequenceStart" )
	wait delaytime

	CannonThermalDrumsSpin_Stop()
}

// level.CANNON_SCREEN_IDLE, level.CANNON_SCREEN_FIRING, level.CANNON_SCREEN_COOLING
function CannonMonitors_ScreenChange( stateID )
{
	level.nv.cannonMonitorScreenStatus = stateID
}

function DelayedCannonMonitorScreensReset( delaytime )
{
	level.ent.EndSignal( "CannonFireSequenceStart" )
	wait delaytime

	CannonMonitors_ScreenChange( level.CANNON_SCREEN_IDLE )
}

function WarningLightsOn()
{
	if ( level.nv.warningLightsOn )
		return

	level.nv.warningLightsOn = 1
}

function WarningLightsOff()
{
	if ( !level.nv.warningLightsOn )
		return

	level.nv.warningLightsOn = null
}

function CannonVentSteamOn()
{
	level.nv.cannonVentingFXOn = 1
}

function CannonVentSteamOff()
{
	level.nv.cannonVentingFXOn = null
}

function DelayedCannonVentSteamOff( delaytime )
{
	level.ent.EndSignal( "CannonFireSequenceStart" )

	wait delaytime

	CannonVentSteamOff()
}


// =========== EVAC / EPILOGUE =========== //
function Outpost_InitEvac()
{
	FlagSet( "CinematicOutro" )
}

// runs at the start of the game to set up winner-independent evac stuff
function Outpost_EvacSetup()
{
	Evac_SetRoundEndSetupFunc( Outpost_EvacSetup_RoundEnd )
	AddSavedLocation( "evacSpaceNode", Vector( 4200, -14420, -11400 ), 0 )

	// next to the Heavy Turret on the skybox side
	if (  !Riff_FloorIsLava() ) //Point is submerged in fog
	{
		AddSavedLocation( "evacNode_1", Vector( 2577, -2253, -370 ), 305 )
		AddSavedLocation( "evacNode_1_spectator", Vector( 3816, 2630, 842 ), Vector( 2, -113, 0 ) )
	}

	// on the helipad, skybox side
	AddSavedLocation( "evacNode_2", Vector( -2225, -1352, -120 ), -50 )
	AddSavedLocation( "evacNode_2_spectator", Vector( -3086, 285, -131.5 ), Vector( -18, -44.5, 0 ) )

	// on the bridge, back side of the level, by the gondola
	AddSavedLocation( "evacNode_3", Vector( 1221, 2600, 350 ), 90 )
	AddSavedLocation( "evacNode_3_spectator", Vector( 1459, 4956, -71 ), Vector( -11, -89, 0 ) )

	local evacLocRef = null

	if ( DEV_TEST && DEV_FORCE_EVAC_LOC )
	{
		evacLocRef = DEV_FORCE_EVAC_LOC
	}
	else
	{
		local evacLocRefs = []
		if (  !Riff_FloorIsLava() ) //Point is submerged in fog
			evacLocRefs.append( "evacNode_1" )

		evacLocRefs.append( "evacNode_2" )
		evacLocRefs.append( "evacNode_3" )

		evacLocRef = Random( evacLocRefs )
	}

	//local evacLocRef = "evacNode_1"

	local evacnode = CreateScriptRef( GetSavedLocationOrigin( evacLocRef ), GetSavedLocationAngles( evacLocRef ) )
	Evac_SetEvacNode( evacnode )

	local spacenode = CreateScriptRef( GetSavedLocationOrigin( "evacSpaceNode" ), GetSavedLocationAngles( "evacSpaceNode" ) )
	Evac_SetSpaceNode( spacenode )

	level.evacLocationInfo <- {}
	level.evacLocationInfo.evacLocRef <- evacLocRef
	level.evacLocationInfo.evacSpectatorLocRef <- evacLocRef + "_spectator"
	Assert( GetSavedLocation( level.evacLocationInfo.evacSpectatorLocRef ) )
}

function Outpost_EvacSetup_RoundEnd()
{
	GM_SetObserverFunc( Outpost_RoundEnd_ObserverFunc )

	if ( !GetCinematicMode() )
		return

	printt( "round end, gamestate set to", GetGameState() )

	local imcScore = GameRules.GetTeamScore( TEAM_IMC )
	local militiaScore = GameRules.GetTeamScore( TEAM_MILITIA )

	local currentWinner = TEAM_IMC
	if ( militiaScore > imcScore )
		currentWinner = TEAM_MILITIA

	thread Outpost_CinematicEpilogueAction( currentWinner )
}

function Outpost_CinematicEpilogueAction( currentWinner )
{
	local imcConv
	local militiaConv

	GameStateUpdate_Start()
	KillScriptedVDUs()
	FlagSet( "EvacStarted" )

	if ( currentWinner == TEAM_MILITIA )
	{
		thread PostEpilogue_MCOR_MCORwon()
		thread PostEpilogue_IMC_MCORwon()
	}
	else
	{
		thread PostEpilogue_MCOR_IMCwon()
		thread PostEpilogue_IMC_IMCwon()
	}

	if ( currentWinner == TEAM_MILITIA )
	{
		wait 2

		thread AimAndFire()
		level.cannon.WaitSignal( "CannonFired" )

		StopSoundOnEntity( level.capitalShipAudioEnt, "outpost207_Sentinel_Idle_Engine" )
		EmitSoundOnEntity( level.capitalShipAudioEnt, "outpost207_Sentinel_Destroyed" )

		thread CapitalShip_BreaksIntoPieces()
	}
	else
	{
		local earlyEscape = !Flag( "MCOR_ReachedHalfScore" )
		thread CapitalShip_Escapes( earlyEscape )
	}

	wait 30
	GameStateUpdate_Finish()
}

function PostEpilogue_MCOR_MCORwon()
{
	ForcePlayConversationToTeam( "Epilogue_MatchWon", TEAM_MILITIA )
	wait 7

	local vduActiveTime = 10
	VDU_WatchCapitalShip( vduActiveTime, 80, TEAM_MILITIA )
	wait vduActiveTime + 0.5

	ForcePlayConversationToTeam( "Epilogue_MatchWon_pt2", TEAM_MILITIA )
	wait 8.5

	ForcePlayConversationToTeam( "PostEpilogue", TEAM_MILITIA )
}

function PostEpilogue_IMC_MCORwon()
{
	ForcePlayConversationToTeam( "Epilogue_MatchLost", TEAM_IMC )
	wait 12

	waitthread PostEpilogue_IMCLoss_GravesLifeboatSequence()

	ForcePlayConversationToTeam( "PostEpilogue", TEAM_IMC )

	/*
	ForcePlayConversationToTeam( "Epilogue_Lifeboat1", TEAM_IMC )
	ForcePlayConversationToTeam( "Epilogue_Lifeboat2", TEAM_IMC )
	ForcePlayConversationToTeam( "Epilogue_Lifeboat3", TEAM_IMC )
	ForcePlayConversationToTeam( "Epilogue_Lifeboat4", TEAM_IMC )
	*/
}

function PostEpilogue_IMCLoss_GravesLifeboatSequence()
{
	RemoteFunctionCall_AllTeam_NonReplay( "ServerCallback_VDU_GravesLifeboat", TEAM_IMC )
	wait 15 // sequence time + ~1 sec buffer time
}

function PostEpilogue_MCOR_IMCwon()
{
	ForcePlayConversationToTeam( "Epilogue_MatchLost", TEAM_MILITIA )
	wait 16

	local vduActiveTime = 10
	VDU_WatchCapitalShip_Escape( vduActiveTime, 80, TEAM_MILITIA )
	wait vduActiveTime + 0.5

	ForcePlayConversationToTeam( "PostEpilogue", TEAM_MILITIA )
}

function PostEpilogue_IMC_IMCwon()
{
	ForcePlayConversationToTeam( "Epilogue_MatchWon", TEAM_IMC )
	wait 13

	RemoteFunctionCall_AllTeam_NonReplay( "ServerCallback_PostEpilogue_IMC_IMCwon_ShipEscapeVO", TEAM_IMC )

	local vduActiveTime = 20
	VDU_WatchCapitalShip_Escape( vduActiveTime, 40, TEAM_IMC )
	wait vduActiveTime + 0.5

	ForcePlayConversationToTeam( "PostEpilogue", TEAM_IMC )
}

function Outpost_RoundEnd_ObserverFunc( player )
{
	Assert( level.evacLocationInfo.evacSpectatorLocRef )
	local spectatorLocRef = level.evacLocationInfo.evacSpectatorLocRef

	player.SetObserverModeStaticPosition( GetSavedLocationOrigin( spectatorLocRef ) )
	player.SetObserverModeStaticAngles( GetSavedLocationAngles( spectatorLocRef ) )

	player.StartObserverMode( OBS_MODE_CHASE )
	player.SetObserverTarget( null )
}


// =========== DECOY SHIP =========== //
function DecoyShipSetup()
{
	local decoyShip = CreateEntity( "script_mover" )
	decoyShip.kv.solid = 0
	decoyShip.kv.model = MILITIA_DECOY_SHIP_MODEL
	decoyShip.kv.SpawnAsPhysicsMover = 0
	decoyShip.SetName( "militia_decoy_ship" )
	DispatchSpawn( decoyShip )

	decoyShip.SetOrigin( level.DECOY_SHIP_START_ORG )
	decoyShip.SetAngles( level.DECOY_SHIP_START_ANG )
	decoyShip.Hide()

	level.decoyShip <- decoyShip
	level.decoyShipFxHandles <- []
}

function DecoyShip()
{
	level.ent.Signal( "DecoyShipReset" )
	level.ent.EndSignal( "DecoyShipReset" )

	FlagClear( "DecoyShipDestroyed" )  // for testing

	thread DecoyShip_TurretsThink()

	// start warning lights/klaxons early for "on alert" feel
	thread CannonPrefireKlaxons()
	thread WarningLightsOn()

	// this is for when we want to repeat the event (dev)
	level.decoyShip.Hide()
	thread PlayAnim( level.decoyShip, "ref", level.decoyShip )
	// cancels existing moves/rotates
	level.decoyShip.MoveTo( level.decoyShip.GetOrigin(), 0.1 )
	level.decoyShip.RotateTo( level.decoyShip.GetAngles(), 0.1 )
	wait 0.11
	level.decoyShip.Anim_Stop()
	level.decoyShip.SetOrigin( level.DECOY_SHIP_START_ORG )
	level.decoyShip.SetAngles( level.DECOY_SHIP_START_ANG )
	wait 0.1

	// first move before cannon shoots it
	local warpInDelay = 2.9
	local moveTime = 13

	local fwd = level.decoyShip.GetAngles().AnglesToForward()
	local shipEndPos = level.decoyShip.GetOrigin() + ( fwd * level.DECOY_SHIP_FIRSTMOVE_DIST )
	//printt( "ship end move pos:", shipEndPos )
	local impactFX_attachAlias = "Explosion_LG_Impact"

	thread DecoyShip_CannonThink( warpInDelay, moveTime, shipEndPos, impactFX_attachAlias )

	RemoteFunctionCall_AllPlayers( "ServerCallback_DecoyShipWarpsIn" )
	wait warpInDelay  // let the warp-in sound & fx play on the clients

	level.decoyShip.Show()

	EmitSoundOnEntity( level.decoyShip, "outpost207_decoyship_explo" )

	level.decoyShip.MoveTo( shipEndPos, moveTime, 0, 0 )
	//wait moveTime * 0.99  // smooth transition to destruction
	wait moveTime

	thread DecoyShip_CrashFX( impactFX_attachAlias )
	FlagSet( "DecoyShipDestroyed" )

	local crashAnim = "ds_outpost_destroyed"
	local animtime = level.decoyShip.GetSequenceDuration( crashAnim )
	thread PlayAnim( level.decoyShip, crashAnim, level.decoyShip )
	wait animtime

	level.decoyShip.Hide()
}

function DecoyShip_CrashFX( attachAlias )
{
	StopDecoyShipFX()

	//printt( "attachAlias:", attachAlias )
	local impactFX = PlayFXOnEntity( FX_DECOY_SHIP_BEAM_IMPACT, level.decoyShip, attachAlias )
	level.decoyShipFxHandles.append( impactFX )

	local attachID = level.decoyShip.LookupAttachment( attachAlias )
	local attachOrg = level.decoyShip.GetAttachmentOrigin( attachID )

	// this particle replaces the ship, it looks like the ship breaking into two pieces
	local destroyFX = PlayFX( FX_DECOY_SHIP_DESTRUCTION, attachOrg )
	printt( "detruction FX origin:", attachOrg )
	level.decoyShipFxHandles.append( destroyFX )
}

function StopDecoyShipFX()
{
	foreach ( fxHandle in level.decoyShipFxHandles )
	{
		if ( IsValid_ThisFrame( fxHandle ) )
		{
			KillFX( fxHandle )
		}
	}

	level.decoyShipFxHandles = []
}

function DecoyShip_TurretsThink()
{
	local turrets = GetNPCArrayEx( "npc_turret_mega", -1, Vector( 0, 0, 0 ), -1 )
	Assert( turrets.len() )

	foreach ( turret in turrets )
		thread TurretTrackDecoyShip( turret )
}

function TurretTrackDecoyShip( turret )
{
	Assert( level.decoyShip )

	turret.EndSignal( "OnDeath" )
	level.decoyShip.EndSignal( "OnDeath" )

	turret.EnableTurret()
	TurretChangeTeam( turret, TEAM_IMC )

	local turretTarget = level.decoyShip
	turret.SetEnemy( turretTarget )

	OnThreadEnd(
		function() : ( turret )
		{
			//ReleaseTurret( turret )
			// want it to stay IMC controlled
			turret.ClearEnemy()
		}
	)

	while( IsValid( turretTarget ) && !Flag( "DecoyShipDestroyed" ) )
	{
		turret.SetEnemyLKP( turretTarget, turretTarget.GetOrigin() )
		wait 0.2
	}

	wait 3
}

function DecoyShip_CannonThink( warpInDelay, shipMoveTime, shipEndPos, fxAttachAlias )
{
	level.ent.EndSignal( "DecoyShipReset" )

	thread DecoyShip_ManageCannonFiringTargets()

	local warpInReactDelay = warpInDelay + 0.7
	local skyCannonWarpInReactDelay = warpInReactDelay + 0.1
	thread DecoyShip_SkyCannonsThink( skyCannonWarpInReactDelay, shipEndPos )

	wait ( warpInReactDelay )
	thread FireCannon()

	// get the future location of the target attachment on the decoy ship model and use that to figure out desired angle
	local warpInTargetOrg = GetEntityWorldPos_ForCannonFX( level.decoyShip, "world", fxAttachAlias )
	local deltaToAttachpoint = level.decoyShip.GetOrigin() + warpInTargetOrg
	local targetOrg = shipEndPos + deltaToAttachpoint

	local vec = GetWorldVectorToOrg_ForCannonFX( targetOrg )
	local rotateAngs = VectorToAngles( vec )

	local rotateTime = shipMoveTime + 0.5
	thread RotateCannonToAngles( rotateAngs, rotateTime, rotateTime * 0.25,  rotateTime * 0.2 )

	wait rotateTime
	wait 3

	// rotate back to start angs
	RotateCannonToAngles( level.cannonStartAngles, 8 )
}

/*
function CannonRotateTest()
{
	level.ent.Signal( "DecoyShipReset" )
	level.ent.EndSignal( "DecoyShipReset" )

	RotateCannonToAngles( level.cannonStartAngles, 2 )
	wait 2

	local rotateTime = 10
	while ( 1 )
	{
		RotateCannonToAngles( level.cannonStartAngles + Vector( 30, 80, 0 ), rotateTime, 0, 0 )
		wait rotateTime

		RotateCannonToAngles( level.cannonStartAngles + Vector( 30, -80, 0 ), rotateTime, 0, 0 )
		wait rotateTime
	}
}
*/

function DecoyShip_ManageCannonFiringTargets()
{
	level.ent.EndSignal( "DecoyShipReset" )

	level.cannon.s.target = eOutpostCannonTargets.DECOY_SHIP

	level.cannon.WaitSignal( "CannonFired" )
	wait 2

	level.cannon.s.target = eOutpostCannonTargets.CAPITAL_SHIP
}

function DecoyShip_SkyCannonsThink( warpInReactDelay, shipEndPos )
{
	level.ent.EndSignal( "DecoyShipReset" )

	local skyCannons = [ level.skyCannonL, level.skyCannonR ]

	foreach ( cannon in skyCannons )
		SnapSkyCannonToAngles( cannon, cannon.s.spawnAng )

	wait warpInReactDelay

	local totalFireDelay = 12.1
	local delayPostRotatePreFire = totalFireDelay * 0.1
	local rotateTime = totalFireDelay - delayPostRotatePreFire
	local prefireFXTime = 3.8

	foreach ( cannon in skyCannons )
	{
		thread RotateAndFireSkyCannonAtWorldPos( cannon, shipEndPos, rotateTime, delayPostRotatePreFire )
		delaythread( totalFireDelay - prefireFXTime ) SkyCannon_PrefireFX( cannon )
	}

	wait totalFireDelay

	wait 4
	// rotate back to start angs
	foreach ( cannon in skyCannons )
		delaythread( RandomFloat( 0, 2 ) ) RotateSkyCannonOverTime( cannon, cannon.s.spawnAng, RandomFloat( 10, 12 ) )
}


// =================== INTRO =================== //
function Outpost_Intro_DropshipSetup()
{
	local ref_imc = GetEnt( "ref_imc_dropship_intro" )
	local ref_mcor = GetEnt( "ref_mcor_dropship_intro" )
	Assert( ref_mcor )
	Assert( ref_imc )

	local mcorRefOrg = ref_mcor.GetOrigin()
	local mcorRefYaw = ref_mcor.GetAngles().y
	local imcRefOrg = ref_imc.GetOrigin()
	local imcRefYaw = ref_imc.GetAngles().y

	// MCOR DROPSHIPS
	////////////////////////////////////////////////////////////

	// ---------- MCOR SHIP 1 ----------
	local create	= CreateCinematicDropship()
	create.origin = mcorRefOrg
	create.team	= TEAM_MILITIA
	create.count 	= 4
	create.side 	= "jumpQuick"

	local event_idle 			= CreateCinematicEvent()
	event_idle.origin 			= mcorRefOrg
	event_idle.yaw	 			= mcorRefYaw
	event_idle.anim				= "gd_fracture_flyin_imc_L_intro"
	event_idle.teleport 		= true
	Event_AddFlagWaitToEnd( event_idle, "Outpost_StartIntroFlyIn" )
	Event_AddAnimStartFunc( event_idle, IntroDropship_SFX )

	local event_flyin 				= CreateCinematicEvent()
	event_flyin.origin 				= mcorRefOrg
	event_flyin.yaw	 				= mcorRefYaw
	event_flyin.anim 				= "dropship_outpost_flyin_mcor_L"
	event_flyin.teleport 			= true
	Event_AddAnimStartFunc( event_flyin, IntroDropship_MCOR_AddHero )
	Event_AddClientStateFunc( event_flyin, "CE_VisualSettingOutpostMCOR" )
	Event_AddClientStateFunc( event_flyin, "CE_BloomOnRampOpenOutpostMCOR" )
	Event_AddServerStateFunc( event_flyin, CE_PlayerSkyScaleOutpostMCOR )
	Event_AddServerStateFunc( event_flyin, CE_PlayerSkyScaleOutpostOnRampOpenMCOR )

	Event_AddFlagSetOnEnd( event_flyin, "MCOR_FlyInDone" )

	AddSavedDropEvent( "introDropShipMCOR_1cr", create )
	AddSavedDropEvent( "introDropShipMCOR_1e1", event_idle )
	AddSavedDropEvent( "introDropShipMCOR_1e2", event_flyin )

	// ---------- MCOR SHIP 2 ----------
	local create	= CreateCinematicDropship()
	create.origin 	= mcorRefOrg
	create.team		= TEAM_MILITIA
	create.count 	= 4
	create.side 	= "jumpQuick"

	local event_idle 			= CreateCinematicEvent()
	event_idle.origin 			= mcorRefOrg
	event_idle.yaw	 			=  mcorRefYaw
	event_idle.anim				= "gd_fracture_flyin_imc_L_intro"
	event_idle.teleport 		= true
	Event_AddFlagWaitToEnd( event_idle, "Outpost_StartIntroFlyIn" )
	Event_AddAnimStartFunc( event_idle, IntroDropship_SFX )

	local event_flyin 				= CreateCinematicEvent()
	event_flyin.origin 				= mcorRefOrg
	event_flyin.yaw	 				=  mcorRefYaw
	event_flyin.anim 				= "dropship_outpost_flyin_mcor_R"
	event_flyin.teleport 			= true
	Event_AddAnimStartFunc( event_flyin, IntroDropship_MCOR_AddHero )
	Event_AddClientStateFunc( event_flyin, "CE_VisualSettingOutpostMCOR" )
	Event_AddClientStateFunc( event_flyin, "CE_BloomOnRampOpenOutpostMCOR" )
	Event_AddServerStateFunc( event_flyin, CE_PlayerSkyScaleOutpostMCOR )
	Event_AddServerStateFunc( event_flyin, CE_PlayerSkyScaleOutpostOnRampOpenMCOR )

	AddSavedDropEvent( "introDropShipMCOR_2cr", create )
	AddSavedDropEvent( "introDropShipMCOR_2e1", event_idle )
	AddSavedDropEvent( "introDropShipMCOR_2e2", event_flyin )

	// IMC DROPSHIPS
	////////////////////////////////////////////////////////////

	// ---------- IMC SHIP 1 ----------
	local create	= CreateCinematicDropship()
	create.origin 	= imcRefOrg
	create.team		= TEAM_IMC
	create.count 	= 4
	create.side 	= "jumpQuick"

	local event_idle 				= CreateCinematicEvent()
	event_idle.origin 				= imcRefOrg
	event_idle.yaw					= imcRefYaw
	event_idle.anim					= "gd_fracture_flyin_imc_L_intro"
	event_idle.teleport 			= true
	Event_AddFlagWaitToEnd( event_idle, "Outpost_StartIntroFlyIn" )
	Event_AddAnimStartFunc( event_idle, IntroDropship_SFX )

	local event_flyin 				= CreateCinematicEvent()
	event_flyin.origin 				= imcRefOrg
	event_flyin.yaw					= imcRefYaw
	event_flyin.anim 				= "dropship_outpost_flyin_imc_L"
	event_flyin.teleport 			= true
	event_flyin.skycam 				= level.SKYCAMERA_REF
	event_flyin.proceduralLength	= false
	Event_AddAnimStartFunc( event_flyin, IntroDropship_IMC_AddHero )
	Event_AddClientStateFunc( event_flyin, "CE_VisualSettingOutpostIMC" )
	Event_AddClientStateFunc( event_flyin, "CE_BloomOnRampOpenOutpostIMC" )
	Event_AddServerStateFunc( event_flyin, CE_PlayerSkyScaleOutpostIMC )
	Event_AddServerStateFunc( event_flyin, CE_PlayerSkyScaleOutpostOnRampOpenIMC )

	Event_AddFlagSetOnEnd( event_flyin, "IMC_FlyInDone" )

	AddSavedDropEvent( "introDropShipIMC_1cr", create )
	AddSavedDropEvent( "introDropShipIMC_1e1", event_idle )
	AddSavedDropEvent( "introDropShipIMC_1e2", event_flyin )

	// ---------- IMC SHIP 2 ----------
	local create	= CreateCinematicDropship()
	create.origin 	= imcRefOrg
	create.team		= TEAM_IMC
	create.count 	= 4
	create.side 	= "jumpQuick"

	local event_idle 				= CreateCinematicEvent()
	event_idle.origin 				= imcRefOrg
	event_idle.yaw					= imcRefYaw
	event_idle.anim				= "gd_fracture_flyin_imc_L_intro"
	event_idle.teleport 			= true
	Event_AddFlagWaitToEnd( event_idle, "Outpost_StartIntroFlyIn" )
	Event_AddAnimStartFunc( event_idle, IntroDropship_SFX )

	local event_flyin 				= CreateCinematicEvent()
	event_flyin.origin 				= imcRefOrg
	event_flyin.yaw					= imcRefYaw
	event_flyin.anim 				= "dropship_outpost_flyin_imc_R"
	event_flyin.teleport 			= true
	event_flyin.skycam				= level.SKYCAMERA_REF
	event_flyin.proceduralLength	= false
	Event_AddAnimStartFunc( event_flyin, IntroDropship_IMC_AddHero )
	Event_AddClientStateFunc( event_flyin, "CE_VisualSettingOutpostIMC" )
	Event_AddClientStateFunc( event_flyin, "CE_BloomOnRampOpenOutpostIMC" )
	Event_AddServerStateFunc( event_flyin, CE_PlayerSkyScaleOutpostIMC )
	Event_AddServerStateFunc( event_flyin, CE_PlayerSkyScaleOutpostOnRampOpenIMC )

	AddSavedDropEvent( "introDropShipIMC_2cr", create )
	AddSavedDropEvent( "introDropShipIMC_2e1", event_idle )
	AddSavedDropEvent( "introDropShipIMC_2e2", event_flyin )
}


function CE_PlayerSkyScaleOutpostMCOR( player, dropship )
{
	player.LerpSkyScale( SKYSCALE_OUTPOST_MCOR_PLAYER, 0.01 )
}

function CE_PlayerSkyScaleOutpostOnRampOpenMCOR( player, dropship )
{
	thread playerLerpSkyScaleOnSignal( player, dropship, "sRampOpen", SKYSCALE_OUTPOST_DOOROPEN_MCOR_PLAYER, 1.0 )
}

function CE_PlayerSkyScaleOutpostIMC( player, dropship )
{
	player.LerpSkyScale( SKYSCALE_OUTPOST_IMC_PLAYER, 0.01 )
}

function CE_PlayerSkyScaleOutpostOnRampOpenIMC( player, dropship )
{
	thread playerLerpSkyScaleOnSignal( player, dropship, "sRampOpen", SKYSCALE_OUTPOST_DOOROPEN_IMC_PLAYER, 1.0 )
}


function IntroMain()
{
	// don't let game state updates happen during the intro
	GameStateUpdate_Start()

	thread HandleIntroFlags()

	SetCustomIntroLength( 35.5 )  // affects gamestate switch to "playing"

	Outpost_Intro_DropshipSetup()

	while ( GetGameState() < eGameState.WaitingForPlayers )
	{
		wait 0.05
	}

	FlagWait( "ReadyToStartMatch" )  // RELIABLE start point for intro

	local introscreenWait = 21
	local warpSoundTime = 2

	//local waitBeforeWarp = ( introscreenWait + pt2_convWait ) - warpSoundTime // start the sound before when the warp is supposed to happen
	local waitBeforeWarp = introscreenWait - warpSoundTime

	thread IntroDropship_IMC( waitBeforeWarp )
	thread IntroDropship_Militia( waitBeforeWarp )

	delaythread( 3 ) ForcePlayConversationToTeam( "Intro_FlyIn_MCOR", TEAM_MILITIA )
	delaythread( 3 ) ForcePlayConversationToTeam( "Intro_FlyIn_IMC", TEAM_IMC )

	// let the introscreen do its thing
	wait waitBeforeWarp
	FlagSet( "Outpost_StartIntroFlyIn" )

	thread IntroTitan_MCOR()
	thread IntroTitan_IMC()
	thread IntroSpectres_IMC()
	thread IntroMarvins_IMC()

	delaythread( 6 ) DecoyShip()
	delaythread( 16 ) FlagSet( "IMC_StartLandingPadSpectres" )
	delaythread( 26 ) FlagSet( "IMC_StartTitanBootup" )
	delaythread( 33 ) FlagSet( "IMC_StartSpectreRacks" )  // 29

	local pt2_convWait = 10
	delaythread( pt2_convWait ) ForcePlayConversationToTeam( "Intro_FlyIn_MCOR_pt2", TEAM_MILITIA )
	delaythread( pt2_convWait ) ForcePlayConversationToTeam( "Intro_FlyIn_IMC_pt2", TEAM_IMC )

	thread MCOR_HandleIntroFlags()
	thread IMC_HandleIntroFlags()

	FlagWait( "DecoyShipDestroyed" )
	wait 2

	ForcePlayConversationToTeam( "Intro_PostFlyIn_IMC", TEAM_IMC )
	ForcePlayConversationToTeam( "Intro_PostFlyIn_MCOR", TEAM_MILITIA )

	FlagWait( "Intro_FinalInstructions" )

	ForcePlayConversationToTeam( "Intro_PostFlyIn_MCOR_pt2", TEAM_MILITIA )
	delaythread( 1.5 ) ForcePlayConversationToTeam( "Intro_PostFlyIn_IMC_pt2", TEAM_IMC )
	wait 6.5  // timed so characters talk about game mode as game mode text shows up
	FlagSet( "IntroDone" )
	printt( "intro done flag set")

	FlagWait( "IMC_HumanSquad_RolledOut" )

	// extra wait- ensures that all AI squads finish deploying before regular reinforcements start
	wait 1

	printt( "LEVEL SCRIPT TURNING ON REGULAR REINFORCEMENTS" )
	FlagClear( "Disable_IMC" )
	FlagClear( "Disable_MILITIA" )
	FlagClear( "DisableDropships" )
	GameStateUpdate_Finish()
}

// so many flags to manage...
function HandleIntroFlags()
{
	// Disable normal AI spawns
	FlagSet( "Disable_IMC" )
	FlagSet( "Disable_MILITIA" )
	// disable AI dropships and droppods
	FlagSet( "DisableDropships" )

	// WAIT for both team intros to finish
	FlagWait( "MCOR_IntroDone" )
	FlagWait( "IMC_IntroDone" )

	FlagSet( "Intro_FinalInstructions" )

	FlagWait( "IntroDone" )
}

function MCOR_HandleIntroFlags()
{
	FlagWait( "MCOR_FlyInDone" )

	FlagWait( "MCOR_Intro_TitanDone" )
	//wait 5

	FlagSet( "MCOR_IntroDone" )
}

function IMC_HandleIntroFlags()
{
	FlagWait( "IMC_FlyInDone" )

	// post landing, timed to let conversation "Intro_PostFlyIn_IMC" finish
	wait 10.9

	FlagSet( "IMC_IntroDone" )
}

function IntroDropship_IMC( waitBeforeWarp )
{
	local table 	= GetSavedDropEvent( "introDropShipIMC_1cr" )
	local idle_blackscreen 	= GetSavedDropEvent( "introDropShipIMC_1e1" )
	local atmosphere 	= GetSavedDropEvent( "introDropShipIMC_1e2" )
	local dropship1 	= SpawnCinematicDropship( table )
	thread RunCinematicDropship( dropship1, idle_blackscreen, atmosphere )

	local table 	= GetSavedDropEvent( "introDropShipIMC_2cr" )
	local idle_blackscreen 	= GetSavedDropEvent( "introDropShipIMC_2e1" )
	local atmosphere 	= GetSavedDropEvent( "introDropShipIMC_2e2" )
	local dropship2 	= SpawnCinematicDropship( table )
	thread RunCinematicDropship( dropship2, idle_blackscreen, atmosphere )

	thread DropshipWarpsIn( dropship1, waitBeforeWarp )
	thread DropshipWarpsIn( dropship2, waitBeforeWarp )

	if ( DEV_TEST && DEV_SKIP_INTRO_SLOTS_IMC >= 0 )
		DebugSkipCinematicSlots( TEAM_IMC, DEV_SKIP_INTRO_SLOTS_IMC )
}

function IntroDropship_Militia( waitBeforeWarp )
{
	local table 	= GetSavedDropEvent( "introDropShipMCOR_1cr" )
	local idle_blackscreen 	= GetSavedDropEvent( "introDropShipMCOR_1e1" )
	local atmosphere 	= GetSavedDropEvent( "introDropShipMCOR_1e2" )
	local dropship1 	= SpawnCinematicDropship( table )
	thread RunCinematicDropship( dropship1, idle_blackscreen, atmosphere )

	local table 	= GetSavedDropEvent( "introDropShipMCOR_2cr" )
	local idle_blackscreen 	= GetSavedDropEvent( "introDropShipMCOR_2e1" )
	local atmosphere 	= GetSavedDropEvent( "introDropShipMCOR_2e2" )
	local dropship2 	= SpawnCinematicDropship( table )
	thread RunCinematicDropship( dropship2, idle_blackscreen, atmosphere )

	thread DropshipWarpsIn( dropship1, waitBeforeWarp )
	thread DropshipWarpsIn( dropship2, waitBeforeWarp )

	if ( DEV_TEST && DEV_SKIP_INTRO_SLOTS_MCOR >= 0 )
		DebugSkipCinematicSlots( TEAM_MILITIA, DEV_SKIP_INTRO_SLOTS_MCOR )
}

function IntroDropship_MCOR_AddHero( dropship, ref, table )
{
	dropship.EndSignal( "OnDeath" )

	local sarah = CreatePropDynamic( SARAH_MODEL )
	sarah.SetParent( dropship, "ORIGIN" )
	sarah.MarkAsNonMovingAttachment()
	sarah.LerpSkyScale( SKYSCALE_OUTPOST_MCOR_ACTOR, 0.1 )
	// (anim plays VO: "diag_at_matchIntro_OP201_05_02_mcor_sarah")
	// "We can see the decoy- it's working! The cannon's powering up!"
	thread PlayAnimTeleport( sarah, "militia_outpost_flyin_exit_sarah", dropship, "ORIGIN" )

	local pilot = CreatePropDynamic( TEAM_MILITIA_GRUNT_MDL )
	pilot.SetParent( dropship, "ORIGIN" )
	pilot.MarkAsNonMovingAttachment()
	pilot.LerpSkyScale( SKYSCALE_OUTPOST_MCOR_ACTOR, 0.1 )
	thread PlayAnimTeleport( pilot, "Militia_flyinA_idle_mac", dropship, "ORIGIN" )

	dropship.WaitSignal( "sRampOpen" )

	sarah.LerpSkyScale( SKYSCALE_OUTPOST_DOOROPEN_MCOR_ACTOR, 1 )
	pilot.LerpSkyScale( SKYSCALE_OUTPOST_DOOROPEN_MCOR_ACTOR, 1 )
}

function IntroDropship_IMC_AddHero( dropship, ref, table )
{
	dropship.EndSignal( "OnDeath" )

	local spyglass = CreatePropDynamic( SPYGLASS_MODEL )
	spyglass.SetParent( dropship, "ORIGIN" )
	spyglass.MarkAsNonMovingAttachment()
	spyglass.LerpSkyScale( SKYSCALE_OUTPOST_IMC_ACTOR, 0.1 )
	thread PlayAnimTeleport( spyglass, "spy_outpost_imc_intro", dropship, "ORIGIN" )

	local pilot = CreatePropDynamic( TEAM_IMC_GRUNT_MDL )
	pilot.SetParent( dropship, "ORIGIN" )
	pilot.MarkAsNonMovingAttachment()
	pilot.LerpSkyScale( SKYSCALE_OUTPOST_IMC_ACTOR, 0.1 )
	thread PlayAnimTeleport( pilot, "Militia_flyinA_idle_mac", dropship, "ORIGIN" )

	dropship.WaitSignal( "sRampOpen" )

	spyglass.LerpSkyScale( SKYSCALE_OUTPOST_DOOROPEN_IMC_ACTOR, 1 )
	pilot.LerpSkyScale( SKYSCALE_OUTPOST_DOOROPEN_IMC_ACTOR, 1 )
}

function IntroDropship_SFX( dropship, ref, table )
{
	dropship.EndSignal( "OnDeath" )

	local flyInAlias = null
	local flyAwayAlias = null
	if ( dropship.GetTeam() == TEAM_IMC )
	{
		flyInAlias = "Outpost207_Scr_IMCIntro_FlyIn"
	}
	else
	{
		flyInAlias 		= "Outpost207_Scr_MilitiaIntro_DropshipFlyinAmb"
		flyAwayAlias 	= "Outpost207_Scr_MilitiaIntro_DropshipFlyaway"
	}

	PlaySoundToAttachedPlayers( dropship, flyInAlias )

	// ship flying away audio (starts right at end of "playing" game state)
	if ( !flyAwayAlias )
		return

	WaittillGameStateOrHigher( eGameState.Playing )

	EmitSoundOnEntity( dropship, flyAwayAlias )
}

function DropshipWarpsIn( dropship, waitBeforeWarp )
{
	// this visual effect needs to start a little early, need the white flash as the black screen is fading out
	delaythread( waitBeforeWarp - 2.2 ) PlayWarpFxOnPlayers( GetSlotsFromRef( dropship ) )

	wait waitBeforeWarp

	EmitSoundOnEntity( dropship, "dropship_warpin" )

	wait 2
	local fx = PlayFX( FX_DROPSHIP_WARPEFFECT, dropship.GetOrigin(), dropship.GetAngles() )
	fx.EnableRenderAlways()
}

// ===========================================
function IntroTitan_MCOR( isDev = false )
{
	if ( !( "introTitanMCOR" in level ) )
	{
		level.introTitanMCOR <- null
	}
	else if ( IsValid( level.introTitanMCOR ) )
	{
		level.introTitanMCOR.Kill()
	}

	local extraWait = 1

	thread IntroGrunts_MCOR( extraWait, isDev )

	local intro_animref = GetEnt( "ref_mcor_dropship_intro" )
	Assert( intro_animref )

	//local arOrg = Vector( -2510, 980, -190 )
	//local arAng = Vector( 0, -80, 0 )
	//local animref = CreateScriptRef( arOrg, arAng )

	local refOrg = intro_animref.GetOrigin()
	local refAng = intro_animref.GetAngles()

	local table 	= CreateDefaultNPCTitanTemplate( TEAM_MILITIA )
	table.title 	= "#NPC_LT_RIGGINS"
	table.weapon	= "mp_titanweapon_xo16"
	table.origin 	= refOrg
	table.angles 	= refAng
	local titan = SpawnNPCTitan( table )

	IntroTitan_PreAnim( titan )
	titan.DisableStarts()

	level.introTitanMCOR = titan

	local idleAnim = "at_outpost_militia_intro_idle"
	local titanAnim = "at_outpost_militia_intro"

	thread PlayAnim( titan, idleAnim, intro_animref )

	OnThreadEnd(
		function() : ( titan )
		{
			FlagSet( "MCOR_Intro_TitanDone" )

			if ( IsAlive( titan ) )
			{
				IntroTitan_PostAnim( titan )

				local assaultPos = Vector( 240, 665, -333 )
				thread IntroTitan_GoFight( titan, assaultPos )
			}
		}
	)

	if ( isDev )
		wait 1
	else
		level.cannon.WaitSignal( "CannonFlapsOpen" )

	// Add extra wait since the IMC side's Titan is delayed
	wait extraWait

	//printt( "playing titan anims" )

	local animtime = titan.GetSequenceDuration( titanAnim )

	thread PlayAnim( titan, titanAnim, intro_animref )

	wait animtime
}

function IntroGrunts_MCOR( extraWait, isDev = false )
{
	if ( !( "introGruntsMCOR" in level ) )
	{
		level.introGruntsMCOR <- []
	}
	else if ( level.introGruntsMCOR.len() )
	{
		foreach ( grunt in level.introGruntsMCOR )
		{
			if ( IsAlive( grunt ) )
				grunt.Kill()
		}

		level.introGruntsMCOR = []
	}

	local intro_animref = GetEnt( "ref_mcor_dropship_intro" )
	Assert( intro_animref )

	local squad0_name = MakeSquadName( TEAM_MILITIA, 0 )
	local squad1_name = MakeSquadName( TEAM_MILITIA, 1 )
	local squad2_name = MakeSquadName( TEAM_MILITIA, 2 )

	local animA_idle 	= "pt_outpost_MCOR_intro_squad_A_front_idle"
	local animA 		= "pt_outpost_MCOR_intro_squad_A_front"
	local animB_idle 	= "pt_outpost_MCOR_intro_squad_B_front_idle"
	local animB 		= "pt_outpost_MCOR_intro_squad_B_front"

	local animC_idle 	= "pt_outpost_militia_intro_A_idle"
	local animC 		= "pt_outpost_militia_intro_A"
	local animD_idle 	= "pt_outpost_militia_intro_B_idle"
	local animD 		= "pt_outpost_militia_intro_B"
	local animE_idle 	= "pt_outpost_militia_intro_C_idle"
	local animE 		= "pt_outpost_militia_intro_C"

	local spawnOrg
	local spawnAng
	local grunts = []

	// SQUAD 0 - by the ramp
	spawnOrg = Vector( -2771, 657, -190 )
	spawnAng = Vector( 0, -60, 0 )
	local s0g1 = Spawn_TrackedGrunt( TEAM_MILITIA, squad0_name, spawnOrg, spawnAng )
	s0g1.s.animref <- CreateScriptRef( spawnOrg, spawnAng )
	s0g1.s.idleAnim <- animA_idle
	s0g1.s.playAnim <- animA
	level.introGruntsMCOR.append( s0g1 )

	spawnOrg = Vector( -2810, 657, -190 )
	spawnAng = Vector( 0, -60, 0 )
	local s0g2 = Spawn_TrackedGrunt( TEAM_MILITIA, squad0_name, spawnOrg, spawnAng )
	s0g2.s.animref <- CreateScriptRef( spawnOrg, spawnAng )
	s0g2.s.idleAnim <- animB_idle
	s0g2.s.playAnim <- animB
	level.introGruntsMCOR.append( s0g2 )

	spawnOrg = Vector( -2900, 646, -190 )
	spawnAng = Vector( 0, 0, 0 )
	local s0g3 = Spawn_TrackedGrunt( TEAM_MILITIA, squad0_name, spawnOrg, spawnAng )
	s0g3.s.animref <- CreateScriptRef( spawnOrg, spawnAng )
	s0g3.s.idleAnim <- animA_idle
	s0g3.s.playAnim <- animA
	level.introGruntsMCOR.append( s0g3 )


	// SQUAD 1 - near the titan
	spawnOrg = Vector( -2555, 1286, -190 )
	spawnAng = Vector( 0, -85, 0 )
	local s1g1 = Spawn_TrackedGrunt( TEAM_MILITIA, squad1_name, spawnOrg, spawnAng )
	s1g1.s.animref <- CreateScriptRef( spawnOrg, spawnAng )
	s1g1.s.idleAnim <- animB_idle
	s1g1.s.playAnim <- animB
	level.introGruntsMCOR.append( s1g1 )

	spawnOrg = Vector( -2610, 1230, -190 )
	spawnAng = Vector( 0, -85, 0 )
	local s1g2 = Spawn_TrackedGrunt( TEAM_MILITIA, squad1_name, spawnOrg, spawnAng )
	s1g2.s.animref <- CreateScriptRef( spawnOrg, spawnAng )
	s1g2.s.idleAnim <- animA_idle
	s1g2.s.playAnim <- animA
	level.introGruntsMCOR.append( s1g2 )

	spawnOrg = Vector( -2468, 1242, -190 )
	spawnAng = Vector( 0, -130, 0 )
	local s1g3 = Spawn_TrackedGrunt( TEAM_MILITIA, squad1_name, spawnOrg, spawnAng )
	s1g3.s.animref <- CreateScriptRef( spawnOrg, spawnAng )
	s1g3.s.idleAnim <- animB_idle
	s1g3.s.playAnim <- animB
	level.introGruntsMCOR.append( s1g3 )


	// SQUAD 2 - between the other squads
	spawnOrg = Vector( -2853, 852, -190 )
	spawnAng = Vector( 0, -20, 0 )
	local s2g1 = Spawn_TrackedGrunt( TEAM_MILITIA, squad2_name, spawnOrg, spawnAng )
	s2g1.s.animref <- intro_animref
	s2g1.s.idleAnim <- animC_idle
	s2g1.s.playAnim <- animC
	level.introGruntsMCOR.append( s2g1 )

	spawnOrg = Vector( -2876, 952, -190 )
	spawnAng = Vector( 0, -55, 0 )
	local s2g2 = Spawn_TrackedGrunt( TEAM_MILITIA, squad2_name, spawnOrg, spawnAng )
	s2g2.s.animref <- intro_animref
	s2g2.s.idleAnim <- animD_idle
	s2g2.s.playAnim <- animD
	level.introGruntsMCOR.append( s2g2 )

	spawnOrg = Vector( -2950, 849, -190 )
	spawnAng = Vector( 0, -15, 0 )
	local s2g2 = Spawn_TrackedGrunt( TEAM_MILITIA, squad2_name, spawnOrg, spawnAng )
	s2g2.s.animref <- intro_animref
	s2g2.s.idleAnim <- animE_idle
	s2g2.s.playAnim <- animE
	level.introGruntsMCOR.append( s2g2 )

	local anims = [ animA, animB, animC, animD, animE ]
	local longestDuration = 0
	local testgrunt = s2g2
	foreach ( a in anims )
	{
		local dur = testgrunt.GetSequenceDuration( a )
		if ( dur > longestDuration )
			longestDuration = dur
	}

	foreach ( grunt in level.introGruntsMCOR )
	{
		ScriptedNPC_Setup( grunt )
		grunt.SetEfficientMode( true )
		grunt.StayPut( true )

		thread PlayAnimGravity( grunt, grunt.s.idleAnim, grunt.s.animref )
	}

	OnThreadEnd(
		function() : ( squad0_name, squad1_name, squad2_name )
		{
			foreach ( grunt in level.introGruntsMCOR )
			{
				if ( IsAlive( grunt ) )
				{
					ScriptedNPC_Reset( grunt )
					grunt.SetEfficientMode( false )
					grunt.StayPut( false )
				}

			}

			local squad0 = GetNPCArrayBySquad( squad0_name )
			local squad1 = GetNPCArrayBySquad( squad1_name )
			local squad2 = GetNPCArrayBySquad( squad2_name )

			Outpost_ScriptedSquadAssault( squad0, 0, 1 )
			Outpost_ScriptedSquadAssault( squad1, 1, 0 )
			Outpost_ScriptedSquadAssault( squad2, 2, 2 )
		}
	)

	if ( isDev )
		wait 1
	else
		level.cannon.WaitSignal( "CannonFlapsOpen" )

	wait extraWait

	//printt( "playing grunt anims" )

	foreach ( grunt in level.introGruntsMCOR )
		thread PlayAnim( grunt, grunt.s.playAnim, grunt.s.animref )

	wait longestDuration
}

function IntroTitan_IMC( isDev = false )
{
	if ( !( "introTitanIMC" in level ) )
	{
		level.introTitanIMC <- null

		// not necessary to be level vars for ship but nice for iteration
		level.introTitanPilotIMC <- null
		level.introTitanCrewIMC <- null
	}

	if ( IsValid( level.introTitanIMC ) )
	{
		level.introTitanIMC.Kill()
	}

	if ( IsValid( level.introTitanPilotIMC ) )
	{
		level.introTitanPilotIMC.Kill()
	}

	if ( IsValid( level.introTitanCrewIMC ) )
	{
		level.introTitanCrewIMC.Kill()
	}

	//local animref = GetEnt( "ref_imc_dropship_intro" )
	//Assert( animref )
	local animref = CreateScriptRef( Vector( 2680, -1311, -413 ), Vector( 0, 97, 0 ) )

	local refOrg = animref.GetOrigin()
	local refAng = animref.GetAngles()

	local table 	= CreateDefaultNPCTitanTemplate( TEAM_IMC )
	table.weapon	= "mp_titanweapon_xo16"
	table.origin 	= refOrg
	table.angles 	= refAng

	local titan = SpawnNPCTitan( table )

	MakeInvincible( titan )

	IntroTitan_PreAnim( titan )
	titan.DisableStarts()

	level.introTitanIMC = titan

	local titanIdle = "at_titan_activation_idle"
	local titanAnim = "at_titan_activation"

	local pilotIdle = "pt_titan_activation_pilot_idle"
	local pilotAnim = "pt_titan_activation_pilot"

	local crewIdle 	= "pt_titan_activation_crew_idle"
	local crewAnim 	= "pt_titan_activation_crew"

	local animStartPos = titan.Anim_GetStartForRefPoint( titanAnim, refOrg, refAng )
	titan.SetOrigin( animStartPos.origin )
	titan.SetAngles( animStartPos.angles )

	AddAnimEvent( titan, "hatch_closed", IntroTitan_IMC_HatchClosed )

	local pilot = CreateGrunt( TEAM_IMC, TEAM_IMC_GRUNT_MDL, "mp_weapon_r97" )
	pilot.SetTitle( "#NPC_SGT_MESSERLY" )
	DispatchSpawn( pilot )
	pilot.SetEfficientMode( true )
	level.introTitanPilotIMC = pilot

	local adjusted_animref = CreateScriptRef( animref.GetOrigin() + Vector( 0, 0, -35 ), animref.GetAngles() )

	local squadName = MakeSquadName( TEAM_IMC, 2 )
	local crew = Spawn_TrackedGrunt( TEAM_IMC, squadName, refOrg, refAng, true )
	crew.SetName( "imc_intro_titan_crew" )
	crew.SetTitle( "#NPC_PVT_HEPPE" )
	level.introTitanCrewIMC = crew

	// TEMP this is instead of an idle anim
	local crewStartPos = crew.Anim_GetStartForRefPoint( crewAnim, adjusted_animref.GetOrigin(), adjusted_animref.GetAngles() )
	crew.SetOrigin( crewStartPos.origin )

	ScriptedNPC_Setup( crew )
	crew.StayPut( true )

	MakeInvincible( pilot )

	// everyone idle
	pilot.SetParent( titan, "HIJACK", false, 0.0 )
	pilot.MarkAsNonMovingAttachment()
	pilot.Anim_ScriptedPlay( pilotIdle )
	pilot.Anim_EnableUseAnimatedRefAttachmentInsteadOfRootMotion()

	thread PlayAnimTeleport( crew, crewIdle, adjusted_animref )
	thread PlayAnimTeleport( titan, titanIdle, adjusted_animref )

	OnThreadEnd(
		function() : ( crew, titan )
		{
			FlagSet( "IMC_Intro_TitanDone" )

			if ( IsAlive( titan ) )
			{
				IntroTitan_PostAnim( titan )
				ClearInvincible( titan )
				DeleteAnimEvent( titan, "hatch_closed", IntroTitan_IMC_HatchClosed )

				local assaultPos = Vector( 1570, 378, -323 )

				// "Messerly to command, I'm mounted up and on the move."
				EmitSoundOnEntity( titan, "diag_at_matchIntro_OP224_07_01_imc_tpilot1" )

				thread IntroTitan_GoFight( titan, assaultPos )
			}

			if ( IsAlive( crew ) )
			{
				crew.SetEfficientMode( false )
				thread IntroTitanCrewman_MeetsUpWithSpectreGuy( crew, titan )
			}
			else
			{
				printt( "crewman dead before meetup function starts" )
				printt( "Flag set: IMC_HumanSquad_RolledOut" )
				FlagSet( "IMC_HumanSquad_RolledOut" )
			}
		}
	)

	if ( isDev )
		wait 3
	else
		FlagWait( "IMC_StartTitanBootup" )

	titan.SetTitle( "#BOOTING" )

	pilot.Anim_ScriptedPlay( pilotAnim )
	pilot.Anim_EnableUseAnimatedRefAttachmentInsteadOfRootMotion()

	local animtime = titan.GetSequenceDuration( titanAnim )
	thread PlayAnim( titan, titanAnim, adjusted_animref )

	if ( IsAlive( crew ) )
	{
		thread PlayAnim( crew, crewAnim, adjusted_animref )
		thread IntroTitan_IMC_VO( crew, titan )
	}

	wait animtime
}

function IntroTitan_IMC_VO( crew, titan )
{
	crew.EndSignal( "OnDeath" )
	titan.EndSignal( "OnDeath" )

	// "Fire it up."
	EmitSoundOnEntity( titan, "diag_at_matchIntro_OP224_01_01_imc_tpilot1" )

	wait 1.25

	// "Titan is hot."
	EmitSoundOnEntity( crew, "diag_at_matchIntro_OP224_02_01_imc_crew1" )

	wait 4.6

	// "Fine motor controls feel good... Heavy servos active."
	EmitSoundOnEntity( titan, "diag_at_matchIntro_OP224_03_01_imc_tpilot1" )

	wait 3

	// "Try standing up. Can you rotate the torso?"
	EmitSoundOnEntity( crew, "diag_at_matchIntro_OP224_04_01_imc_crew1" )

	wait 6

	// "A little stiff. I'll manage."
	EmitSoundOnEntity( titan, "diag_at_matchIntro_OP224_05_01_imc_tpilot1" )

	wait 3

	// "Alright, then you're good. Go get 'em sir."
	EmitSoundOnEntity( crew, "diag_at_matchIntro_OP224_06_01_imc_crew1" )
}

function IntroTitan_IMC_HatchClosed( titan )
{
	// switch title once the human takes control during the anim
	local newTitle = "#NPC_SGT_MESSERLY"
	titan.SetTitle( newTitle )
	titan.SetShortTitle( newTitle )

	if ( IsValid( level.introTitanPilotIMC ) )
	{
		ClearInvincible( level.introTitanPilotIMC )
		level.introTitanPilotIMC.Kill()
	}
}

function IntroTitanCrewman_MeetsUpWithSpectreGuy( crew, titan )
{
	crew.EndSignal( "OnDeath" )

	OnThreadEnd(
		function() : ( crew )
		{
			printt( "crewman alive?", IsAlive( crew ) )
			printt( "Flag set: IMC_HumanSquad_RolledOut" )
			FlagSet( "IMC_HumanSquad_RolledOut" )
		}
	)

	if ( IsAlive( titan ) )
	{
		// wait for the titan to leave before trying to run
		while ( IsAlive( titan ) && Distance( titan.GetOrigin(), crew.GetOrigin() ) <= 256 )
			wait 0.2
	}

	crew.StayPut( false )

	// make sure the other guy is alive while we try to run to him
	local squadName = MakeSquadName( TEAM_IMC, 2 )
	local existingSquad = GetNPCArrayBySquad( squadName )

	if ( existingSquad.len() >= 2 )
	{
		local assaultPath = []
		local assault1 = { origin = Vector( 2458, -953, -400 ), angles = Vector( 0, 150, 0 ) }
		assaultPath.append( assault1 )

		local assault2 = { origin = Vector( 1734, -663, -400 ), angles = Vector( 0, 140, 0 ) }
		assaultPath.append( assault2 )

		local waitSignal = "OnFinishedAssault"
		local timeout = 10

		foreach ( idx, point in assaultPath )
		{
			local goalradius = STANDARDGOALRADIUS

			if ( idx < assaultPath.len() )
			{
				crew.DisableArrivalOnce( true )
				goalradius = STANDARDGOALRADIUS * 2
			}

			local assaultEnt = CreateStrictAssaultEnt( point.origin, point.angles, goalradius )

			crew.AssaultPointEnt( assaultEnt )
			local result = WaitSignalTimeout( crew, timeout, waitSignal )
			if ( result == null || result.signal != waitSignal )
			{
				printt( "IMC intro titan crewman pathfinding stopped, quitting")
				break // pathfinding stopped so quit this
			}

			//printt( "finished assault" )
		}

		printt( "IMC intro titan crewman reached assault point" )
	}

	FlagWait( "IMC_HumanSquadRollOut" )

	local squad2 = GetNPCArrayBySquad( squadName )
	foreach ( guy in squad2 )
		ScriptedNPC_Reset( guy )

	thread IntroSquad_StartAssault( squad2, 2, 1 )

	wait 0.1
	printt( "IMC intro soldiers rolled out" )
}

function ScriptedNPC_Setup( guy )
{
	guy.AllowHandSignals( false )
	guy.AllowFlee( false )
}

function ScriptedNPC_Reset( guy )
{
	guy.AllowHandSignals( true )
	guy.AllowFlee( true )

	// usually want to handle these in the event script, but make sure these definitely get reset
	ClearInvincible( guy )
	guy.StayPut( false )
}

function IntroTitan_PreAnim( titan )
{
	titan.SetEfficientMode( true )
	MakeInvincible( titan )
	DisableRodeo( titan )
}

function IntroTitan_PostAnim( titan )
{
	titan.SetEfficientMode( false )
	EnableRodeo( titan )
	ClearInvincible( titan )
}

function IntroTitan_GoFight( titan, assaultPos )
{
	titan.EndSignal( "OnDeath" )

	titan.DisableArrivalOnce( true )

	waitthread GotoOrigin( titan, assaultPos )

	titan.EnableStarts()
}


function IntroMarvins_IMC( isDev = false )
{
	if ( !( "introMarvins" in level ) )
		level.introMarvins <- []

	foreach ( marvin in level.introMarvins )
	{
		if ( IsValid( marvin ) )
		{
			ClearInvincible( marvin )
			marvin.Kill()
		}
	}

	level.introMarvins = []

	local ar1 = CreateScriptRef()
	ar1.SetOrigin( Vector( 4000, -800, -695 ) )
	ar1.SetAngles( Vector( 0, 0, 0 ) )
	ar1.s.anim <- "mv_trafic_controller_A"

	local ar2 = CreateScriptRef()
	ar2.SetOrigin( Vector( 4000, -650, -695 ) )
	ar2.SetAngles( Vector( 0, 0, 0 ) )
	ar2.s.anim <- "mv_trafic_controller_B"

	local animrefs = [ ar1, ar2 ]

	foreach ( animref in animrefs )
	{
		local marvin = SpawnIntroMarvin( animref.GetOrigin(), animref.GetAngles() )
		level.introMarvins.append( marvin )

		thread IntroMarvin_IMC_Think( marvin, animref, isDev )
	}
}

function IntroMarvin_IMC_Think( marvin, animref, isDev = false )
{
	marvin.EndSignal( "OnDeath" )

	MakeInvincible( marvin )
	TakeAllJobs( marvin )  // otherwise he walks off

	// dunno why TakeAllJobs doesn't do this, but they don't get them back later if this var is already set up
	delete marvin.s.jobs
	delete marvin.s.shouldFightFire

	OnThreadEnd(
		function() : ( marvin )
		{
			if ( !IsValid( marvin ) )
				return

			if ( "batons" in marvin.s )
			{
				foreach ( baton in marvin.s.batons )
				{
					if ( IsValid( baton ) )
					{
						baton.ClearParent()
					}
				}
			}

			ClearInvincible( marvin )
			thread SpawnMarvin_for_MP( marvin )
		}
	)

	Assert( "anim" in animref.s )

	local anim = animref.s.anim //"mv_trafic_controller_A"
	local animtime = marvin.GetSequenceDuration( anim )

	// for development
	local endTime = Time() + 9

	while ( 1 )
	{
		thread PlayAnimTeleport( marvin, anim, animref )
		wait animtime

		if ( isDev && Time() >= endTime )
			break
		else if ( Flag( "IMC_FlyInDone") )
			break
	}


	if ( isDev )
		wait 8
	else
		FlagWait( "IMC_FlyInDone" )
}

function SpawnIntroMarvin( org, ang )
{
	local marvin = CreateEntity( "npc_marvin" )
	marvin.SetName( UniqueString( "atc_marvin") )
	marvin.SetOrigin( org )
	marvin.SetAngles( ang )
	marvin.kv.health = -1
	marvin.kv.max_health = -1
	marvin.kv.spawnflags = 516  // Fall to ground, Fade Corpse
	marvin.kv.additionalequipment = "Nothing"
	marvin.SetModel( MARVIN_MODEL )

	DispatchSpawn( marvin, true )

	marvin.SetTeam( TEAM_UNASSIGNED )

	local batonRight = CreateSafetyBaton( marvin )
	batonRight.SetOrigin( marvin.GetAttachmentOrigin( marvin.LookupAttachment( "R_HAND" ) ) )
	// HACK adjust the angles since the tags are different
	local angs = marvin.GetAttachmentAngles( marvin.LookupAttachment( "R_HAND" ) ) + Vector( 0, 0, 180 )
	batonRight.SetAngles( angs )
	batonRight.SetParent( marvin, "R_HAND", true )

	local batonLeft = CreateSafetyBaton( marvin )
	batonLeft.SetParent( marvin, "L_HAND" )

	marvin.s.batons <- [ batonRight, batonLeft ]

	return marvin
}

function CreateSafetyBaton( owner )
{
	local baton = CreatePropPhysics( SAFETY_BATON_MODEL, owner.GetOrigin(), owner.GetAngles() )

	baton.SetName( UniqueString( "safety_baton" ) )

	return baton
}

function IntroSpectres_IMC( isDev = false )
{
	local spawners = level.spectreRackSpawns

	Assert( spawners.len() <= 4, "Squad sizes won't work" )

	foreach ( spawner in level.spectreRackSpawns_LandingPad )
		spawner.Show()

	foreach ( spawner in level.spectreRackSpawns )
		spawner.Show()

	foreach ( spectre in level.rackSpawnedSpectres )
		if ( IsAlive( spectre ) )
			spectre.Kill()

	thread IntroSpectres_IMC_LandingPad( isDev )

	thread IntroSpectres_IMC_SoldierUsesConsole( isDev )

	if ( isDev )
		wait 8
	else
		FlagWait( "IMC_StartSpectreRacks" )

	wait 5 // let the guy type before starting the spectre spawns

	local spawnWait = 0
 	foreach( idx, spawner in spawners )
 	{
 		wait spawnWait
 		spawnWait += RandomFloat( 0.2, 0.3 )

 		local squadName = MakeSquadName( TEAM_IMC, 0 )
 		if ( idx > 1 )
 			squadName = MakeSquadName( TEAM_IMC, 1 )

 		thread Outpost_SpawnRackedSpectre( spawner, TEAM_IMC, squadName, "#NPC_PFC_KEATINGS_SPECTRE" )

 		spawner.Hide()
 	}

 	wait 4

 	// now that they've spawned send them off to assault something
 	IntroIMC_SendSpectreSquadsAway()

 	FlagSet( "IMC_Intro_SpectresDone" )
}

function IntroIMC_SendSpectreSquadsAway()
{
	local squadName0 = MakeSquadName( TEAM_IMC, 0 )
 	local squad0 = GetNPCArrayBySquad( squadName0 )

 	local squadName1 = MakeSquadName( TEAM_IMC, 1 )
 	local squad1 = GetNPCArrayBySquad( squadName1 )

	thread IntroSquad_StartAssault( squad0, 0, 0 )
	thread IntroSquad_StartAssault( squad1, 1, 2 )
}

function IntroSpectres_IMC_LandingPad( isDev = false )
{
	Assert( level.spectreRackSpawns_LandingPad.len() <= 4, "Squad sizes won't work" )

	if ( isDev )
		wait 1
	else
		FlagWait( "IMC_StartLandingPadSpectres" )

	printt( "starting landing pad spectres" )

	local squad0_name = MakeSquadName( TEAM_IMC, 0 )
	local squad1_name = MakeSquadName( TEAM_IMC, 1 )

	local delay = 0
	local spawner
	// loop through backwards because the order of them spawning looks better this way
	for ( local i = ( level.spectreRackSpawns_LandingPad.len() - 1 ); i >= 0 ; i-- )
	{
		wait delay
 		delay += RandomFloat( 0.5, 0.75 )

 		local squadName = squad1_name
 		if ( i <= 1 )
 			squadName = squad0_name

 		spawner = level.spectreRackSpawns_LandingPad[ i ]
 		thread Outpost_SpawnRackedSpectre( spawner, TEAM_IMC, squadName, "#NPC_OUTPOST_DEFENSE_SPECTRE" )

 		spawner.Hide()
	}

	wait 2

	local spectres = GetNPCArrayBySquad( squad0_name )
	spectres.extend( GetNPCArrayBySquad( squad1_name ) )

	local point1 = {}
	point1.origin <- Vector( 3270, -960, -480 )
	point1.angles <- Vector( 0, 0, 0 )

	local point2 = {}
	point2.origin <- Vector( 1777, -969, -430 )
	point2.angles <- Vector( 0, 0, 0 )

	local points = [ point1, point2 ]

	local goalradius = 256

	foreach ( point in points )
	{
		local assaultEnt = CreateStrictAssaultEnt( point.origin, point.angles, goalradius )
		local testSpectre = null
		foreach ( spectre in spectres )
		{
			if ( !IsAlive( spectre ) )
				continue

			if ( !testSpectre )
				testSpectre = spectre

			spectre.AssaultPointEnt( assaultEnt )
		}

		// no more spectres
		if ( !testSpectre )
		{
			"Intro landing pad spectres all dead, aborting think function"
			return
		}

		while ( IsAlive( testSpectre ) && Distance( point.origin, testSpectre.GetOrigin() ) > goalradius )
			wait 1
	}

	foreach ( spectre in spectres )
	{
		if ( IsAlive( spectre ) )
			spectre.StayPut( true )
	}
}

function IntroSpectres_IMC_SoldierUsesConsole( isDev = false )
{
	if ( !( "introSoldierBootingSpectres" in level ) )
		level.introSoldierBootingSpectres <- null

	if ( IsAlive( level.introSoldierBootingSpectres ) )
		level.introSoldierBootingSpectres.Kill()

	local startanim = "pt_outpost_spectre_activation"
	local idleanim = "pt_outpost_spectre_activation_idle"

	local animref = GetEnt( "ref_spectre_console" )
	Assert( animref )

	// for iterating
	if ( !( "ogOrg" in animref.s ) )
		animref.s.ogOrg <- animref.GetOrigin()

	animref.SetOrigin( animref.s.ogOrg )
	// adjust here until anim is adjusted
	animref.SetOrigin( animref.GetOrigin() + Vector( 0, -24, -25 ) )

	local squadName = MakeSquadName( TEAM_IMC, 2 )
	local soldier = Spawn_TrackedGrunt( TEAM_IMC, squadName, Vector( 0, 0, 0 ), Vector( 0, 0, 0 ), true )
	local animStartPos = soldier.Anim_GetStartForRefPoint( startanim, animref.GetOrigin(), animref.GetAngles() )
	soldier.SetOrigin( animStartPos.origin )

	soldier.SetName( "imc_intro_console_soldier" )
	soldier.SetTitle( "#NPC_PFC_KEATING" )
	level.introSoldierBootingSpectres = soldier

	ScriptedNPC_Setup( soldier )
	MakeInvincible( soldier )
	soldier.StayPut( true )

	thread PlayAnim( soldier, idleanim, animref )

	soldier.EndSignal( "OnDeath" )

	OnThreadEnd(
		function() : ( soldier )
		{
			if ( IsAlive( soldier ) )
			{
				soldier.Anim_Stop()
				soldier.StayPut( false )
				ClearInvincible( soldier )
			}

			FlagSet( "IMC_HumanSquadRollOut" )
		}
	)

	if ( isDev )
		wait 5 // this is to expose the lack of an idle
	else
		FlagWait( "IMC_StartSpectreRacks" )

	printt( "clearing invincible on Keating" )
	ClearInvincible( soldier )
	local sequenceDuration = soldier.GetSequenceDuration( startanim )
	local minWaitEnd = sequenceDuration + Time()
	thread PlayAnimTeleport( soldier, startanim, animref )

	wait 5
	// "Keating, get those Spectres deployed! Let's go let's go!"
	EmitSoundOnEntity( soldier, "diag_at_matchIntro_OP224_08_01_imc_crew1" )
	printt( "start spectre racks")

	// type for another 10 seconds then finish
	wait 10
}

function Outpost_SpawnRackedSpectre( spawner, team, squadName, longTitle = null )
{
	spawner.s.inUse = true

	local spectre = Spawn_TrackedSpectre( TEAM_IMC, squadName, spawner.s.animPos, spawner.s.animAng, true, null, true ) // <-- hidden when spawned

	level.rackSpawnedSpectres.append( spectre )

	local weapon = spectre.GetActiveWeapon()
	spectre.TakeActiveWeapon()	//need to hide weapon or we'll see a pop
	spectre.s.weapon <- weapon.GetClassname()

	MakeInvincible( spectre )
	spectre.SetEfficientMode( true )

	// turn the spectre on
	EmitSoundAtPosition( spawner.s.animPos + Vector( 0, 0, 72), "corporate_spectrerack_activate" )

	//spawner.Hide()
	spectre.Show()

	if ( !longTitle )
		longTitle = "#NPC_SPECTRE"

	spectre.SetTitle( longTitle )
	spectre.SetShortTitle( "#NPC_SPECTRE" )

	spectre.GiveWeapon( spectre.s.weapon )
	spectre.SetActiveWeapon( spectre.s.weapon )
	delete spectre.s.weapon

	spectre.EndSignal( "OnDeath" )

	waitthread PlayAnim( spectre, "sp_med_bay_drop_armed", spawner.s.animPos, spawner.s.animAng )

	spectre.SetEfficientMode( false )
	ClearInvincible( spectre )
}

function Outpost_SpectreRacksSetup()
{
	local racks = GetEntArrayByName_Expensive( "spectreSpawnLabRack" )
	Assert( racks.len() )

	foreach( ent in racks )
	{
		local pos = ent.GetOrigin()
		local ang = ent.GetAngles()
		local drone = Outpost_SpawnSpectreDrone( pos, ang )

		drone.s.inUse <- false
		drone.s.animPos <- pos
		drone.s.animAng <- ang

		drone.Anim_PlayWithRefPoint( "sp_med_bay_dropidle_A", pos, ang, 0 )

		local landingPadCenter = Vector( 4370, -715, -700 )
		local nearbyDist = 800
		if ( Distance( pos, landingPadCenter ) <= nearbyDist )
			level.spectreRackSpawns_LandingPad.append( drone )
		else
			level.spectreRackSpawns.append( drone )
	}

	Assert( level.spectreRackSpawns_LandingPad.len() >= 4 )
}

function Outpost_SpawnSpectreDrone( pos, ang )
{
	local spectre = CreatePropDynamic( NEUTRAL_SPECTRE_MODEL, pos, ang, 0 )	//<- 8= "hitboxes only" - Need to set collision to not be default 0, otherwise won't be detected in triggers
	return spectre
}

function IntroSquad_StartAssault( squad, index, hardpointID )
{
	if( !squad.len() )
		return

	foreach( npc in squad )
	{
		npc.SetLookDist( 5000 )
		npc.StayPut( false )
		npc.DisableBehavior( "Assault" )

		if ( npc.GetClassname() == "npc_soldier" )
			npc.AllowHandSignals( true )
	}

	Outpost_ScriptedSquadAssault( squad, index, hardpointID )
}

function Outpost_ScriptedSquadAssault( squad, squadIdx, hardpointID )
{
	if ( GameRules.GetGameMode() == CAPTURE_POINT )
	{
		// override
		Outpost_JoinHPAssault( squad, squadIdx, hardpointID )
	}
	else
	{
		ScriptedSquadAssault( squad, squadIdx )
	}
}

function Outpost_JoinHPAssault( guys, squadIdx, hardpointID )
{
	if ( !guys.len() )
		return

	local team = guys[ 0 ].GetTeam()

	local hardpoint
	local hardpoints = GetHardpoints()
	foreach( point in hardpoints )
	{
		if ( hardpointID != point.GetHardpointID() )
			continue

		hardpoint = point
		break
	}

	Assert( hardpoint, "Couldn't find hardpoint in map with ID " + hardpointID )

	local hpIndex  = GetHardpointIndex( hardpoint )
	local squadName = MakeSquadName( team, squadIdx )

	foreach ( guy in guys )
		if ( IsAlive( guy ) )
			SetSquad( guy, squadName )

	printt( "Outpost_JoinHPAssault:", guys[0].kv.squadname, "going to", hardpoint )

	thread SquadCapturePointThink( squadName, hardpoint, team )
}


// =========== STRATON FLYBYS =========== //
function AmbientGunshipsBuzzLevel()
{
	while( 1 )
	{
		FlagWait( "IntroDone" )
		FlagWait( "GamePlaying" )

		if ( Flag( "IntroDone" ) && Flag( "GamePlaying" ) )
		{
			local yaw = RandomInt( 360 )

			local count = RandomInt( 7, 10 )
			for ( local i = 0; i < count; i++ )
			{
				//printt( "Ambient Gunship Spawning" )
				thread SpawnRandomGunship( yaw )
				wait RandomFloat( 0.2, 1.0 )
			}

		}

		wait RandomFloat( 20, 40 )
	}
}

function SpawnRandomGunship( yaw )
{
	local model = STRATON_MODEL
	local anim = STRATON_FLIGHT_ANIM
	local analysis = GetAnalysisForModel( model, anim )

	local drop = CreateCallinTable()
	drop.style = eDropStyle.RANDOM_FROM_YAW // spawn at a random node that points the right direction
	drop.yaw = yaw
 	local spawnPoint = GetSpawnPointForStyle( analysis, drop )
 	if ( !spawnPoint )
 		return

	local dropship = CreatePropDynamic( model, Vector(0,0,0), Vector(0,0,0) )
	waitthread PlayAnimTeleport( dropship, anim, spawnPoint.origin, spawnPoint.angles )
	dropship.Kill()
}


// =========== MISC STUFF ===========
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

function NonCinematicSpawn()
{
	local players = GetPlayerArray()

	foreach ( player in players )
	{
		if ( !IsAlive( player ) )
		{
			StartTitanBuildProgress( player )
			DecideRespawnPlayer( player )
		}
	}
}

// TEMP for dev
function CapitalShipPrintOriginAndAngles()
{
	printt( "----- CAP SHIP POS INFO -----")
	printt( "org:", level.capitalShip.GetOrigin() )
	printt( "ang:", level.capitalShip.GetAngles() )
}


/* DEPRECATED, this was used to rescale orgs that I had already figured out at a different scale, while we were figuring out the new scale
//level.CAPITAL_SHIP_SCALEFACTOR 		<- 30.480061
function RescaleOrg( ogOrg )
{
	local scaleFactor = level.CAPITAL_SHIP_SCALEFACTOR

	local skycamOrg = level.skycamera.GetOrigin()
	local ogDist = Distance( ogOrg, skycamOrg )

	local scaleDist = ogDist / scaleFactor

	local fwd = ogOrg - skycamOrg
	fwd.Normalize()

	local newOrg = skycamOrg + ( fwd * scaleDist )
	printt( "ORG RESCALED! Old:", ogOrg, "New:", newOrg )

	return newOrg
}
*/

function Outpost207SpecificChatter( npc )
{
	Assert( GetMapName() == "mp_outpost_207" )

	if ( !GamePlayingOrSuddenDeath() )
		return false

	PlaySquadConversationToTeam( "outpost_207_grunt_chatter", npc.GetTeam(), npc, AI_FRIENDLY_CHATTER_RANGE_SQR )
	return true //return false if we should not be doing chatter so we can fall through and do other chatter if needed
}


main()
