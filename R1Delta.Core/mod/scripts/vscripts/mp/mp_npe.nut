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
const FX_SWAPDOOR_CLOSED 		= "P_npe_door_closed_sml"
const FX_SWAPDOOR_OPEN 			= "P_npe_door_open_sml"
const FX_SWAPDOOR_CLOSED_TITAN 	= "P_npe_door_closed_titan"
const FX_SWAPDOOR_OPEN_TITAN 	= "P_npe_door_open_titan"
const FX_SWAPDOOR_CLOSED_ARCH 	= "P_npe_door_closed_arch"
const FX_SWAPDOOR_OPEN_ARCH 	= "P_npe_door_open_arch"

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
PrecacheParticleSystem( FX_SWAPDOOR_CLOSED )
PrecacheParticleSystem( FX_SWAPDOOR_OPEN )
PrecacheParticleSystem( FX_SWAPDOOR_CLOSED_TITAN )
PrecacheParticleSystem( FX_SWAPDOOR_OPEN_TITAN )
PrecacheParticleSystem( FX_SWAPDOOR_CLOSED_ARCH )
PrecacheParticleSystem( FX_SWAPDOOR_OPEN_ARCH )

PrecacheWeapon( "mp_projectile_orbital_strike" )

const PILOT_WEAPON_1					= "mp_weapon_semipistol"
const PILOT_WEAPON_2 					= "mp_weapon_smart_pistol"
const PILOT_WEAPON_3					= "mp_weapon_rspn101"
const PILOT_WEAPON_4					= "mp_weapon_wingman"
const PILOT_WEAPON_OFFHAND_OFFENSIVE 	= "mp_weapon_frag_grenade"
const PILOT_WEAPON_AT 					= "mp_weapon_rocket_launcher"
const GRENADE_SLOT 						= 0

const TITAN_WEAPON_1 					= "mp_titanweapon_xo16"
const TITAN_WEAPON_OFFHAND_DEFENSIVE 	= "mp_titanweapon_vortex_shield"
const TITAN_WEAPON_OFFHAND_OFFENSIVE 	= "mp_titanweapon_salvo_rockets"

const FX_DEREZ = "env_training_derez"
const FX_DEREZ_BLACK = "env_training_derez_blackout"

const LEVEL_START_MODULE = -1  // set the default module to run at start (NOT dev)

TITAN_CORE_ENABLED = false

function main()
{
	IncludeScript( "mp_npe_shared" )

	if ( reloadingScripts )
		return

	Riff_ForceSetSpawnAsTitan( eSpawnAsTitan.Never )

	AddCallback_OnClientConnected( NPE_PlayerConnected )
	AddClientCommandCallback( "topTarget", ClientCommand_LookTarget_Top )
	AddClientCommandCallback( "bottomTarget", ClientCommand_LookTarget_Bottom )
	AddClientCommandCallback( "lookInverted", ClientCommand_NPE_LookWasInverted )
	AddClientCommandCallback( "noButtonClicked", ClientCommand_NPE_NoButtonClicked )
	AddClientCommandCallback( "confirmInvertSettings", ClientCommand_NPE_ConfirmInvertYes )
	AddClientCommandCallback( "startBedEndModule", ClientCommand_NPE_StartBedEndModule )
	AddClientCommandCallback( "startTitanMoshPitModule", ClientCommand_NPE_StartTitanMoshPitModule )
	AddClientCommandCallback( "NPE_WeaponSwitch", ClientCommand_NPE_PressedWeaponSwitch )
	AddClientCommandCallback( "NPE_DashMeterLow", ClientCommand_NPE_DashMeterLow )
	AddClientCommandCallback( "NPE_DashMeterReady", ClientCommand_NPE_DashMeterReady )
	AddClientCommandCallback( "NPE_PlayerReloaded", ClientCommand_NPE_PlayerReloaded )
	AddClientCommandCallback( "NPE_PlayerDashed", ClientCommand_NPE_PlayerDashed )
	AddClientCommandCallback( "NPE_PlayerPressedUse", ClientCommand_NPE_PlayerPressedUse )
	AddClientCommandCallback( "NPE_PlayerPressedPrimaryWeapon", ClientCommand_NPE_PlayerPressedPrimaryWeapon)
	AddClientCommandCallback( "NPE_FiredOffhandOffensive", ClientCommand_NPE_FiredOffhandOffensive )
	AddClientCommandCallback( "NPE_PlayerPressedJump", ClientCommand_NPE_PlayerPressedJump )
	AddClientCommandCallback( "leaveTraining", ClientCommand_LeaveTraining )  // for the pause menu
	AddClientCommandCallback( "callConversationOverSignal", ClientCommand_CallConversationOverSignal )  // for the pause menu
	AddClientCommandCallback( "callConversationOverEndSignal", ClientCommand_CallConversationOverEndSignal )  // for the pause menu

	//AddClientCommandCallback( "trainingFinished", ClientCommand_SetTrainingHasEverFinished )
	//AddClientCommandCallback( "trainingStarted", ClientCommand_SetTrainingHasEverBeenStarted )
	//AddClientCommandCallback( "resumeChoice", ClientCommand_ResumeChoice )

	AddDeathCallback( "npc_soldier", NPE_GroundTroopsDeathCallback )
	AddDeathCallback( "npc_spectre", NPE_GroundTroopsDeathCallback )
	AddDeathCallback( "npc_marvin", NPE_GroundTroopsDeathCallback )

	level.grenadesThrown <- 0
	AddSpawnCallback( "npc_grenade_frag", NPE_GrenadeCreatedCallback )

	level.trainingRocketEffectTable <- PrecacheImpactEffectTable( GetWeaponInfoFileKeyField_Global( "mp_projectile_orbital_strike", "impact_effect_table" ) )

	//level.resumeChoice 					<- null
	//level.training_hasEverBeenStarted 	<- null
	//level.training_hasEverFinished 		<- null
	level.doQuickIntro 					<- false
	level.doQuickOutro 					<- false
	level.pilotTrainingOnly 			<- false

	level.currentTrainingModule <- null
	level.trainingModuleInfos <- null
	level.player <- null
	level.trainingPod <- null
	level.lastTrainingPrompt <- null
	level.skyboxCamDefault <- null
	level.skyboxCamSpace <- null
	level.skyboxModelSpace <- null
	level.titanPetControlPanel <- null
	level.titanDisembarkDisabled <- true
	level.dashMoves <- null
	level.moshpitStartAreaTrig <- null
	level.vortexDamage <- 0
	level.wallrunPlayerPos <- -1
	level.previousWallrunPlayerPos <- -1
	level.wallrunPlatformTrigs <- []
	level.lastSmartPistolTargs <- []
	level.trainingModules <- []
	level.lightSwitchTrigs <- []
	level.grenadeTrigs <- []
	level.lookTargets <- []
	level.walkDoors <- []
	level.sprintDoors <- []
	level.dashRockets <- []
	level.cabinWindowShutters <- []
	level.trainingPodGlowLightRows <- []

	RegisterSignal( "ConversationOver" )
	RegisterSignal( "ModuleChanging" )
	RegisterSignal( "Teleported" )
	RegisterSignal( "TeleportedPlayer" )
	RegisterSignal( "ModuleChangeDone" )
	RegisterSignal( "DoorResetting" )
	RegisterSignal( "PlayerInvertedLook" )
	RegisterSignal( "PlayerClickedNoButton" )
	RegisterSignal( "InvertSettingsConfirmed" )
	RegisterSignal( "Cloak_PlayerFound" )
	RegisterSignal( "Cloak_RanIntoPlayer" )
	RegisterSignal( "PlayerKilledAllSentries" )
	RegisterSignal( "CloakModuleResetting" )
	RegisterSignal( "DetectPlayerFailedMultiTarget_Stop" )
	RegisterSignal( "DetectTargetWasMeleed_Stop" )
	RegisterSignal( "SetPlayerRocketDamageFlag" )
	RegisterSignal( "StopSkyRotation" )
	RegisterSignal( "PodInteriorSequenceDone" )
	RegisterSignal( "TrainingPod_BeginInteriorShutdown" )
	RegisterSignal( "StopFiringRockets" )
	RegisterSignal( "StopRechargingVortex" )
	RegisterSignal( "PlayTitanAnimSafe_Start" )
	RegisterSignal( "NPC_FightPlayer" )
	RegisterSignal( "StandDown_Change" )
	RegisterSignal( "StopRefillingPlayerAmmo" )
	RegisterSignal( "StopRefillingOffhandWeapons" )
	RegisterSignal( "TeleportingPlayer" )

	PrecacheParticleSystem( FX_DEREZ )
	PrecacheParticleSystem( FX_DEREZ_BLACK )

	FlagInit( "HealthSuperRegenEnd" )
	FlagInit( "ModuleChangeInProgress" )
	FlagInit( "FirstSpawnDone" )
	FlagInit( "PlayerIsTeleporting" )
	FlagInit( "PlayerPressedUse" )
	FlagInit( "PlayerPressedPrimaryWeapon" )
	FlagInit( "PlayerPressedJump" )
	FlagInit( "PlayerLookedAtTopTarget" )
	FlagInit( "PlayerLookedAtBottomTarget" )
	FlagInit( "NagFlag" )
	FlagInit( "DoorsImpassable" )
	FlagInit( "PlayerNotSprintingThroughTrigger" )
	FlagInit( "DoingBasicWallrunVO" )
	FlagInit( "DoingWallrunHelperVO" )
	FlagInit( "ShortWallrunDetected" )
	FlagInit( "PlayerPastCloakArea" )
	FlagInit( "NotKilledUsingSmartPistol" )
	FlagInit( "PlayerReloaded" )
	FlagInit( "PlayerPressedWeaponSwitchButton" )
	FlagInit( "PlayerFailedMultiTarget" )
	FlagInit( "SmartPistolMultiTargetsDead" )
	FlagInit( "PlayerFailedMultiLock" )
	FlagInit( "PlayerPassedMultiLock" )
	FlagInit( "MultiLock_TargetWasMeleed" )
	FlagInit( "FiringRangeWeaponSwapped" )
	FlagInit( "PlayerADSed" )
	FlagInit( "NonHeadshot" )
	FlagInit( "PlayerThrewGrenade" )
	FlagInit( "GrenadeThrowingDone" )
	FlagInit( "PilotMoshPit_AllSquadsSpawned" )
	FlagInit( "TrainingPilotHealth" )
	FlagInit( "PilotHealthTrainingStarted" )
	FlagInit( "MoshPit_GroundTroops_Done" )
	FlagInit( "PlayerCalledInTitan" )
	FlagInit( "TitanDropped" )
	FlagInit( "PlayerEnteredTitan" )
	FlagInit( "TitanDash_StartDirectionalVO" )
	FlagInit( "PlayerDashMeterLow" )
	FlagInit( "PlayerDashed" )
	FlagInit( "PlayerDashed_Left" )
	FlagInit( "PlayerDashed_Right" )
	FlagInit( "PlayerDashed_Forward" )
	FlagInit( "PlayerDashed_Back" )
	FlagInit( "TeachingDashDirection" )
	FlagInit( "TeachingDashMeter" )
	FlagInit( "DashThreat_PlayerPastAlcove1" )
	FlagInit( "PlayerTookRocketDamage" )
	FlagInit( "PlayerVortexed" )
	FlagInit( "PlayerVortex_CanRefire" )
	FlagInit( "TitanVortex_NPCTitanDead" )
	FlagInit( "TitanVortex_PlayerDamaged" )
	FlagInit( "PlayerDisembarked" )
	FlagInit( "PlayerInsideControlRoom" )
	FlagInit( "TitanFollowModeEngaged" )
	FlagInit( "FiredOffhandOffensive" )
	FlagInit( "TitanMoshPitCombatStarted" )
	FlagInit( "TitanShieldTrainingStarted" )
	FlagInit( "TrainingTitanShields")
	FlagInit( "TitanHealthTrainingStarted" )
	FlagInit( "TrainingTitanHealth")
	FlagInit( "CombatTestDone" )
	FlagInit( "PlayerEjected" )
	FlagInit( "Moshpit_Grenade" )
	FlagInit( "Moshpit_Melee" )
	FlagInit( "ConversationOver" )

	FlagSet( "ForceStartSpawn" )  	// always spawn as though the match just started
	FlagSet( "DisableTimeLimit" )	// won't end the game from time limit

	SetTitanEmbarkFailsafeOverrideFunc( NPE_TitanEmbarkFailsafeOverrideFunc )
}

function EntitiesDidLoad()
{
	NPE_EntitySetup()

	SetupTrainingModules()

	thread TrainerStart()
}

function NPE_PlayerConnected( player )
{
    printt( "NPE_PlayerConnected" )

	thread NPE_PlayerConnected_Threaded( player )
}

function NPE_PlayerConnected_Threaded( player )
{
    printt( "NPE_PlayerConnected_Threaded" )

	if ( IsValid( level.player ) )
	{
		printt( "WARNING multiple players connected to training level! Forcing return to lobby..." )
		ReturnToLobby()
	}

	level.player = player
	level.player.EnableDemigod()

	level.player.SetTeam( TEAM_IMC )

	//level.player.SetNextTitanRespawnAvailable( -1 )
	
	if (GAMETYPE != "battle_practice")
		InitTitanBuildRule( level.player )

	CreatePlayerAssaultEnt()

    printt( "invoke ServerCallback_PilotTrainingStart" )

	Remote.CallFunction_Replay( level.player, "ServerCallback_PilotTrainingStart" )
}

function TrainerStart()
{
    printt( "TrainerStart" )

	disable_npcs()
	SetGlobalForcedDialogueOnly( true )

    printt( "NPE waiting for resume choice" )

    //while ( level.resumeChoice == null )
    //   wait 0

	printt( "NPE waiting for player" )

	while ( !IsValidPlayer( level.player ) )
		wait 0

	printt( "NPE player found!" )

	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )

	// default start
	if (GAMETYPE == "tutorial")
		level.currentTrainingModule = TRAINING_BEDROOM
	else if (GAMETYPE == "titan_tutorial")
		level.currentTrainingModule = TRAINING_TITAN_MOSH_PIT
	else if (GAMETYPE == "battle_practice")
	{
		level.currentTrainingModule = TRAINING_BATTLE_PRACTICE
		Remote.CallFunction_Replay(level.player, "ServerCallback_EnableTitanModeChange")
	}

	// first time playing the level start -- OR -- dev test start
	thread StartTrainingModule( level.currentTrainingModule )
	
	wait 0.5

	level.player.s.rodeoEnabled = false

	// HACK shouldn't have to wait this long! (Related to player load time)
	wait 5
	ModuleAdvanceTriggers_StartLoopedSFX()
}


// =========================== MODULE SETUP & FUNCTIONS ===========================

function SetupTrainingModules()
{
	level.trainingModuleInfos = []

	if (GAMETYPE == "tutorial")
	{
		local module = CreateTrainingModuleInfo()
		module.id 			= TRAINING_BEDROOM/*eTrainingModules.BEDROOM*/
		module.startPos 	= Vector( -13536, -6643, 0 )
		module.startAng 	= Vector( 0, 100, 0 )
		module.runFunc 		= Module_Bedroom
		module.resetFlags 	= [ "PlayerLookedAtTopTarget", "PlayerLookedAtBottomTarget" ]
		module.showLoading	= true
		module.resumePoint 	= true
		module.showEndEMP 	= false
		AddTrainingModuleInfo( module )

		local module = CreateTrainingModuleInfo()
		module.id 		= TRAINING_BEDROOM_END/*eTrainingModules.BEDROOM_END*/
		module.startPos = Vector( -13536, -6643, 0 )
		module.startAng = Vector( 0, 100, 0 )
		module.runFunc 	= Module_Bedroom_End
		module.showLoading	= true
		module.resumePoint 	= true
		module.showEndEMP	= false
		AddTrainingModuleInfo( module )

		local module = CreateTrainingModuleInfo()
		module.id 			= TRAINING_JUMP/*eTrainingModules.JUMP*/
		module.startEnt		= "destination_run_and_jump_training"
		module.runFunc 		= Module_RunAndJump
		module.playerMods 	= [ "disable_doublejump", "disable_wallrun" ]
		module.resetTrigs 	= [ "trigger_lightswitch3", "trigger_lightswitch2", "trigger_lightswitch", "trigger_lightswitch1", "trigger_lightswitch4" ]
		module.resetFlags 	= [ "DoorsImpassable", "PlayerStartWalkSection", "PlayerPassedWalkDoors", "SafeToCloseWalkDoors", "SprintDoorsStartClosing", "PlayerNotSprintingThroughTrigger", "PlayerPassedSprintDoors", "SafeToCloseSprintDoors", "PlayerNearJump", "PlayerPastJump", "PlayerPastRunAndJump", "PlayerNearMantle", "PlayerPastMantle" ]
		module.showLoading	= true
		module.resumePoint 	= true
		module.showEndEMP	= true
		AddTrainingModuleInfo( module )

		local module = CreateTrainingModuleInfo()
		module.id 			= TRAINING_DOUBLEJUMP/*eTrainingModules.DOUBLEJUMP*/
		module.startEnt		= "destination_wallrun_training"
		module.runFunc 		= Module_Wallrun
	//	module.playerMods 	= [ "disable_doublejump" ]
		module.resetTrigs 	= [ "trigger_lightswitch8", "trigger_lightswitch9", "trigger_lightswitch10", "trigger_lightswitch11" ]
		module.resetFlags 	= [ "PlayerEnteredWallrunArea", "DoingBasicWallrunVO", "DoingWallrunHelperVO", "PlayerReachedWallrunPlatform2", "PlayerReachedWallrunPlatform3", "PlayerReachedWallrunPlatform4", "PlayerReachedWallrunEnd" ]
		module.showLoading	= false
		module.resumePoint 	= false
		module.showEndEMP	= true
		AddTrainingModuleInfo( module )

		local module = CreateTrainingModuleInfo()
		module.id 			= TRAINING_WALLRUN/*eTrainingModules.WALLRUN*/
		module.startEnt		= "destination_doublejump_training"
		module.runFunc 		= Module_Doublejump
	 	module.resetTrigs 	= [ "trigger_lightswitch12", "trigger_lightswitch13", "trigger_lightswitch14" ]
		module.resetFlags 	= [ "PlayerReachedDoublejumpPlatform2", "PlayerPastDoubleJump2", "PlayerPassedDoubleJumpCeiling" ]
		module.showLoading	= false
		module.resumePoint 	= false
		module.showEndEMP	= true
		AddTrainingModuleInfo( module )

		local module = CreateTrainingModuleInfo()
		module.id 			= TRAINING_MOSH_PIT/*eTrainingModules.MOSH_PIT*/
		module.startEnt		= "destination_mosh_pit_playground"
		module.runFunc 		= Module_MoshPit
		module.resetFlags 	= [ "PlayerPressedWeaponSwitchButton", "PlayerReloaded", "PilotMoshPit_AllSquadsSpawned", "TrainingPilotHealth", "PilotHealthTrainingStarted", "MoshPit_GroundTroops_Done", "FiringRangeWeaponSwapped", "PlayerCalledInTitan", "TitanDropped", "PlayerEnteredTitan" ]
		module.showLoading	= true
		module.resumePoint 	= true
		module.showEndEMP	= false
		AddTrainingModuleInfo( module )
	}

	if (GAMETYPE == "tutorial" || GAMETYPE == "titan_tutorial")
	{
		local module 		= CreateTrainingModuleInfo()
		module.id 			= TRAINING_TITAN_MOSH_PIT/*eTrainingModules.TITAN_MOSH_PIT*/
		module.startEnt 	= "destination_mosh_pit_playground"
		module.runFunc 		= Module_TitanMoshPit
		module.resetFlags 	= [ "TitanMoshPitCombatStarted", "TitanShieldTrainingStarted", "TrainingTitanShields", "TitanHealthTrainingStarted", "TrainingTitanHealth", "CombatTestDone" ]
		module.showLoading	= true
		module.resumePoint 	= true
		module.showEndEMP	= false
		AddTrainingModuleInfo( module )
	}

	if (GAMETYPE == "battle_practice")
	{
		local module 		= CreateTrainingModuleInfo()
		module.id 			= TRAINING_BATTLE_PRACTICE
		module.startEnt 	= "destination_mosh_pit_playground"
		module.runFunc 		= Module_BattlePractice
		module.resetFlags 	= [ "TitanMoshPitCombatStarted", "TitanShieldTrainingStarted", "TrainingTitanShields", "TitanHealthTrainingStarted", "TrainingTitanHealth", "CombatTestDone" ]
		module.showLoading	= true
		module.resumePoint 	= true
		module.showEndEMP	= false
		AddTrainingModuleInfo( module )	
	}
}

function CreateTrainingModuleInfo()
{
	local info = {}
	info.id 			<- null
	info.startPos 		<- null
	info.startAng 		<- null
	info.startEnt 		<- null
	info.runFunc 		<- null
	info.runFuncVar 	<- null
	info.playerMods 	<- null
	info.startAsTitan 	<- null
	info.resetTrigs 	<- null
	info.resetFlags 	<- null
	info.showLoading	<- null
	info.resumePoint	<- null
	info.showEndEMP		<- null

	return info
}

function AddTrainingModuleInfo( table )
{
	if ( table.startEnt != null )
	{
		local entArray = GetEntArrayByName_Expensive( table.startEnt )
		Assert( entArray.len(), "Couldn't find ent called " + table.startEnt )
		Assert( entArray.len() == 1, "Found " + entArray.len() + " ent(s) with name " + startEnt + ", expected just one." )
		local startEnt = entArray[ 0 ]

		table.startPos = startEnt.GetOrigin()
		table.startAng = startEnt.GetAngles()
	}

	if ( table.playerMods != null )
		Assert( type( table.playerMods ) == "array", "Need to set player mods up as an array for module ID " + table.id )

	level.trainingModuleInfos.append( table )
}

function GetTrainingModuleInfo( moduleID )
{
	local moduleInfos = null

	foreach ( module in level.trainingModuleInfos )
	{
		if ( module.id == moduleID )
		{
			moduleInfos = module
			break
		}
	}

	Assert( moduleInfos, "Couldn't find training module info for moduleID " + moduleID )
	return moduleInfos
}

function StartTrainingModule_FromDevMenu( moduleID )
{
	if ( !Flag( "FirstSpawnDone" ) )
	{
		printt( "WARNING: Can't use dev menu until first spawn is finished." )
		return
	}

	StartTrainingModule( moduleID )
}


// If this function is called it means the player got stuck in a bad state while embarking/disembarking.
function NPE_TitanEmbarkFailsafeOverrideFunc( player )
{
	printt( "NPE: Player titan embark failsafe override!" )

	if ( Flag( "ModuleChangeInProgress" ) )
		return

	// if player got stuck, restart the current training module
	thread StartTrainingModule( level.currentTrainingModule )
}

function StartTrainingModule( moduleID )
{
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.player.EndSignal( "OnDeath" )
	level.ent.Signal( "ModuleChanging" )
	level.ent.EndSignal( "ModuleChanging" )

	FlagSet( "ModuleChangeInProgress" )

	OnThreadEnd(
		function() : ()
		{
			FlagClear( "ModuleChangeInProgress" )
		}
	)

	printt( "starting module", moduleID )

	Remote.CallFunction_Replay( level.player, "ScriptCallback_NPE_ModuleChanging" )

	local moduleInfo = GetTrainingModuleInfo( moduleID )

	if (moduleInfo.showEndEMP)
	{
		Remote.CallFunction_Replay( level.player, "ServerCallback_TrainingTeleportLong" )
		wait 0.5
	}

	// sets the module we're about to execute as the current module so that advancing the module can increment the variable
	// EXCEPTION: intro cabin module doesn't set it because we might want to go to a module other than the very next one afterward (for continuing training after start)
	if (moduleID != TRAINING_BEDROOM/*eTrainingModules.BEDROOM*/)
	{
		level.currentTrainingModule = moduleID  // server script
	}

	level.ui.trainingModule = moduleID  // UI script needs to know when we are in BEDROOM or BEDROOM_END, so we always set it

	HideTrainingPrompt()

	level.player.HolsterWeapon()

	MuteAll( level.player, 2.5 )

	// fix for moduleInfo being null sometimes in the wild
	if ( !IsValid( moduleInfo ) )
	{
		local printstr = "$$$$ StartTrainingModule aborting because moduleInfo was invalid for ID " + moduleID
		printtodiag( printstr + "\n" )
		printt( printstr )
		return
	}

	if (GAMETYPE != "battle_practice")
		TakeAllWeapons( level.player )

	TrainingModule_ResetTriggers( moduleInfo )
	TrainingModule_ResetFlags( moduleInfo )
	TrainingModule_SetPlayerSettings( moduleInfo )

	HideMinimap()

	if ( moduleInfo.runFunc != null )
	{
		if ( moduleInfo.runFuncVar != null )
			thread moduleInfo.runFunc( moduleInfo.runFuncVar )
		else
			thread moduleInfo.runFunc()
	}

	// INTROSCREEN TEXT
	if (ShouldDoIntroscreens() && moduleInfo.showLoading) 
	{
		Remote.CallFunction_Replay( level.player, "ServerCallback_ShowIntroScreen", moduleID )

		// let the intro screen start before we teleport, this is set up to work with the timing of the introscreen fade from black
		local waitTime = 5.3
		
		if ( moduleID == TRAINING_BEDROOM/*eTrainingModules.BEDROOM*/ )
			waitTime = 1  // SimpleBlackscreen wait

		wait waitTime
	}

	EnablePilotHud()
	//level.player.SetNextTitanRespawnAvailable( -1 )

	if (GAMETYPE != "battle_practice")
		InitTitanBuildRule( level.player )

	// teleport player before introscreen wait, so the module can set things up under blackscreen if necessary
	TeleportPlayer( moduleInfo.startPos, moduleInfo.startAng, false )

	Remote.CallFunction_Replay( level.player, "ServerCallback_EnableFog" )
	level.player.SetSkyCamera( level.skyboxCamDefault )
	CleanupCorpses()

	local totalWait 				= 0
	local waitBeforeTeleportFX 		= 0
	local waitBeforeWeaponDeploy 	= 0

	if (ShouldDoIntroscreens() && moduleInfo.showLoading)
	{
		totalWait 				= 1.5
		waitBeforeTeleportFX 	= 0.6
		waitBeforeWeaponDeploy 	= totalWait - waitBeforeTeleportFX
	}

	if ( !Flag( "FirstSpawnDone" ) )
		FlagSet( "FirstSpawnDone" )

	if (moduleInfo.showLoading)
	{
		wait waitBeforeTeleportFX

		if (moduleID != TRAINING_BEDROOM/*eTrainingModules.BEDROOM*/)  // don't do the audio when players first spawn in
			Remote.CallFunction_Replay( level.player, "ServerCallback_TrainingTeleport" )
	}

	UnMuteAll( level.player, 1.0 )

	wait waitBeforeWeaponDeploy
	TrainingModule_GiveDefaultWeapons()

	level.ent.Signal( "ModuleChangeDone" )
}

function TrainingModule_SetPlayerSettings( moduleInfo )
{
	local cancelDoomedState = moduleInfo.startAsTitan && level.player.IsTitan() && level.player.GetDoomedState()

	// Handle player embarking/disembarking
	local playerEmbarking = false
	local playerTitan = GetPlayerTitanInMap( level.player )
	if ( playerTitan )
		if ( "disembarkingPlayer" in playerTitan.s || "embarkingPlayer" in playerTitan.s )
			playerEmbarking = true

	printt( "Player embarking?", playerEmbarking )
	if ( playerEmbarking )
		level.player.ClearParent()  // trying to kill the titan while the player is attached causes an engine error

	// Kill player's pet titan in the world. If embarking/disembarking this also kills that scripting.
	if ( playerTitan && !playerTitan.IsPlayer() )
		playerTitan.Kill()

	// if module is for pilots and we're a Titan, OR if we're already a Titan and need to cancel doomed state, turn player into a pilot
	if ( ( moduleInfo.startAsTitan == null && level.player.IsTitan() ) || cancelDoomedState )
	{
		local dummyTitan = CreateTitanFromPlayer( level.player )
		TitanBecomesPilot( level.player, dummyTitan )
		dummyTitan.Kill()

		// HACK this forces the cockpit HUD to redraw, clearing the health bar hazard lines and the eject button prompt
		if ( cancelDoomedState )
			Remote.CallFunction_NonReplay( level.player, "ScriptCallback_DestroyPlayerCockpit" )
	}

	if ( moduleInfo.startAsTitan && !level.player.IsTitan() )
	{
		local titan = CreateNPCTitanForPlayer( level.player, level.player.GetOrigin(), level.player.GetAngles() )
		PilotBecomesTitan( level.player, titan )
		titan.Kill()

		DisableTitanDisembark()
	}

	local playerSetFile = "pilot_training"
	if ( moduleInfo.startAsTitan != null )
		playerSetFile = "titan_atlas_training"

	if ( moduleInfo.playerMods != null )
		level.player.SetPlayerSettingsWithMods( playerSetFile, moduleInfo.playerMods )
	else
		level.player.SetPlayerSettings( playerSetFile )
}

function TrainingModule_GiveDefaultWeapons()
{
	if (GAMETYPE == "battle_practice")
		return

	TakeAllWeapons( level.player )

	if ( level.player.IsTitan() )
	{
		level.player.GiveWeapon( TITAN_WEAPON_1 )
		//level.player.GiveOffhandWeapon( TITAN_WEAPON_OFFHAND_OFFENSIVE, 0 )
		//level.player.GiveOffhandWeapon( TITAN_WEAPON_OFFHAND_DEFENSIVE, 1 )
		level.player.DeployWeapon()
	}
	else
	{
		level.player.GiveWeapon( PILOT_WEAPON_1 )
		level.player.DeployWeapon()
	}

	thread TakeAmmoFromPlayerASAP()
}

function AdvanceToNextTrainingModule()
{
	//printt( "AdvanceToNextTrainingModule: level.currentTrainingModule: " + level.currentTrainingModule )

	AdvanceCurrentTrainingModuleIdx()

	if ( level.currentTrainingModule > 0 )
		EmitSoundOnEntity( level.player, "NPE_Module_Finish" )

	thread StartTrainingModule( level.currentTrainingModule )
}

// sets the next module ID to use
function AdvanceCurrentTrainingModuleIdx()
{
	local table = getconsttable().eTrainingModules

	local lastIdx = 0
	foreach ( val in table )
	{
		if ( val > lastIdx )
			lastIdx = val
	}

	local nextModuleID = level.currentTrainingModule + 1

	nextModuleID = FindValidModuleID(nextModuleID)

	if ( nextModuleID == -1 )
	{
		local printstr = "No training modules set up past index " + level.currentTrainingModule + ", setting to zero."
		printt( printstr )
		printtodiag( printstr + "\n" )
		nextModuleID = 0
	}

	level.currentTrainingModule = nextModuleID
}

function FindValidModuleID( moduleID )
{
	local table = getconsttable().eTrainingModules
	local lastIdx = 0

	foreach ( val in table )
	{
		if ( val > lastIdx )
			lastIdx = val
	}

	while ( 1 )
	{
		if ( moduleID > lastIdx )
			break

		foreach ( module in level.trainingModuleInfos )
		{
			if ( module.id == moduleID )
			{
				return module.id
			}
		}

		moduleID = moduleID + 1	
	}

	return -1
}


// =========================== ENTITY SETUP ===========================

function NPE_EntitySetup()
{
	SetupLightSwitchTriggers()

	SetupModuleAdvanceTriggers()

	SetupPlayerResetTriggers()

	SetupGrenadeTriggers()

	SetupDoors()

	SetupCabinWindowShutters()

	SetupSkyboxEnts()

	local arr = GetEntArrayByName_Expensive( "control_panel_titan_pet" )
	Assert( arr.len() == 1 )
	level.titanPetControlPanel = arr[ 0 ]

	SetupTrainingPod()

	TrainingPod_GlowLightsArraySetup()

	// the order of these should match the order of the gapInfo indices
	level.wallrunPlatformTrigs.append( GetEnt( "trig_wallrun_start" ) )
	level.wallrunPlatformTrigs.append( GetEnt( "trig_wallrun_platform2" ) )
	level.wallrunPlatformTrigs.append( GetEnt( "trig_wallrun_platform3" ) )
	level.wallrunPlatformTrigs.append( GetEnt( "trig_wallrun_platform4" ) )
	level.wallrunPlatformTrigs.append( GetEnt( "trigger_lightswitch11" ) )

	level.moshpitStartAreaTrig = GetEnt( "trig_moshpit_start_building" )
}

function SetupLightSwitchTriggers()
{
	local lightTrigs = GetEntArrayByNameWildCard_Expensive( "trigger_lightswitch*" )

	foreach ( trig in lightTrigs )
	{
		trig.s.triggered <- null
		trig.s.lights <- []

		local targs = GetEntArrayByName_Expensive( trig.GetTarget() )
		Assert( targs.len(), "Couldn't find lightswitch trigger target named " + trig.GetTarget() + " from trigger " + trig.GetName() )
		Assert( targs.len() == 1 )
		local targetEnt = targs[ 0 ]

		while ( IsValid( targetEnt ) )
		{
			trig.s.lights.append( targetEnt )

			local targs = GetEntArrayByName_Expensive( targetEnt.GetTarget() )
			if ( !targs.len() )
			break

			Assert( targs.len() == 1 )
			targetEnt = targs[ 0 ]
		}

		foreach ( fxSpot in trig.s.lights )
			ChangeFXOnRef( fxSpot, FX_LIGHT_ORANGE )

		level.lightSwitchTrigs.append( trig )

		// HACK want to disable the auto triggering on this one without recompiling the map
		if ( trig.GetName() == "trigger_lightswitch6" )
			continue

		trig.ConnectOutput( "OnStartTouch", PlayerTouchedLightSwitchTrigger )
	}
}

function TrainingModule_ResetTriggers( moduleInfo )
{
	if ( moduleInfo.resetTrigs == null )
		return

	LightTriggers_Reset( moduleInfo.resetTrigs )
}

function LightTriggers_Reset( lightTrigArray )
{
	foreach ( name in lightTrigArray )
	{
		local trig = GetLightTrigger( name )
		Assert( IsValid( trig ), "Couldn't find valid trigger named " + name )

		trig.s.triggered = null

		foreach ( fxSpot in trig.s.lights )
			ChangeFXOnRef( fxSpot, FX_LIGHT_ORANGE )
	}
}

function LightTrigger_On( trigTN, fxAlias = FX_LIGHT_ORANGE )
{
	local lightTrig = GetLightTrigger( trigTN)
	Assert( lightTrig )

	foreach ( fxSpot in lightTrig.s.lights )
		ChangeFXOnRef( fxSpot, fxAlias )
}

function LightTrigger_Off( trigTN )
{
	local lightTrig = GetLightTrigger( trigTN)
	Assert( lightTrig )

	foreach ( fxSpot in lightTrig.s.lights )
		KillFX( fxSpot.s.fxHandle )
}

function GetLightTrigger( trigTN )
{
	foreach ( trig in level.lightSwitchTrigs )
		if ( trig.GetName() == trigTN )
			return trig

	return null
}

function TriggerSetRequireSprint( trigTN )
{
	local trig = GetLightTrigger( trigTN )
	Assert( IsValid( trig ), "Can't set requireSprint on trigger named " + trigTN + " because it wasn't found." )

	if ( !( "requireSprint" in trig.s ) )
		trig.s.requireSprint <- 1
}

function TrainingModule_ResetFlags( moduleInfo )
{
	if ( moduleInfo.resetFlags == null )
		return

	foreach ( flagname in moduleInfo.resetFlags )
	{
		FlagClear( flagname )
	}
}

function PlayerTouchedLightSwitchTrigger( trig, entity, caller, value )
{
	if ( entity != level.player )
		return

	if ( trig.s.triggered != null )
		return

	trig.s.triggered = 1

	local lightColorFX = FX_LIGHT_GREEN
	local soundAlias = "NPE_Player_Succeed"
	if ( "requireSprint" in trig.s && !entity.IsSprinting() )
	{
		lightColorFX = null
		soundAlias = null
		FlagSet( "PlayerNotSprintingThroughTrigger" )
	}

	Assert( trig.s.lights.len() )

	if ( soundAlias != null )
		EmitSoundOnEntity( level.player, soundAlias )

	if ( lightColorFX != null )
		foreach ( fxSpot in trig.s.lights )
			ChangeFXOnRef( fxSpot, lightColorFX )
}

function ChangeFXOnRef( fxSpot, fxAlias, endcapPlayTime = null )
{
	if ( "fxHandle" in fxSpot.s )
	{
		if ( endcapPlayTime != null )
			thread KillFXWithEndcap( fxSpot.s.fxHandle, endcapPlayTime )
		else
			KillFX( fxSpot.s.fxHandle )

		fxSpot.s.fxHandle = null
	}
	else
	{
		fxSpot.s.fxHandle <- null
	}

	fxSpot.s.fxHandle = PlayLoopFX( fxAlias, fxSpot.GetOrigin(), fxSpot.GetAngles() )
}

function KillFX( fxHandle, doDestroyImmediately = false )
{
	if ( !IsValid_ThisFrame( fxHandle ) )
		return

	fxHandle.Fire( "DestroyImmediately" )
	fxHandle.ClearParent()
	fxHandle.Destroy()
}

function KillFXWithEndcap( fxHandle, killDelay = 1.0 )
{
	if ( !IsValid_ThisFrame( fxHandle ) )
		return

	fxHandle.Fire( "StopPlayEndCap" )
	wait killDelay

	if ( !IsValid_ThisFrame( fxHandle ) )
		return

	fxHandle.ClearParent()
	fxHandle.Destroy()
}

function KillFXWithEndlessEndcap( fxHandle )
{
	if ( !IsValid_ThisFrame( fxHandle ) )
		return

	fxHandle.Fire( "StopPlayEndCap" )
}

function SetupModuleAdvanceTriggers()
{
	local moduleChangeTrigs = GetEntArrayByNameWildCard_Expensive( "module_advance_trigger*" )
	level.moduleChangeTrigs <- []
	foreach ( trig in moduleChangeTrigs )
	{
		trig.ConnectOutput( "OnStartTouch", PlayerTouchedModuleAdvanceTrigger )

		level.moduleChangeTrigs.append( trig )
	}
}

function ModuleAdvanceTriggers_StartLoopedSFX()
{
	Assert( level.moduleChangeTrigs && level.moduleChangeTrigs.len() )

	foreach ( trig in level.moduleChangeTrigs )
	{
		local ref = CreateScriptMover( trig, trig.GetOrigin(), Vector( 0, 0, 0 ) )
		ref.Show()
		trig.s.sfxEmitter <- ref
		//printt( "trying to play successdeck sound on", ref, "isvalid?", IsValid( ref ) )
		EmitSoundOnEntity( trig.s.sfxEmitter, "NPE_Emit_SuccessDeck" )
	}
}

function PlayerTouchedModuleAdvanceTrigger( trig, entity, caller, value )
{
	trig.EndSignal( "OnDeath" )
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )

	if ( entity != level.player )
		return

	//printt( "touched module advance trigger" )

	if ( IsValid( trig.s.sfxEmitter ) )
		FadeOutSoundOnEntity( trig.s.sfxEmitter, "NPE_Emit_SuccessDeck", 1 )

	thread AdvanceToNextTrainingModule()

	// wait for teleport away, then play sound again
	level.player.WaitSignal( "Teleported" )
	EmitSoundOnEntity( trig.s.sfxEmitter, "NPE_Emit_SuccessDeck" )
}

function SetupPlayerResetTriggers()
{
	local resetTrigs = GetEntArrayByNameWildCard_Expensive( "player_reset_trigger*" )
	foreach ( trig in resetTrigs )
	{
		local targs = GetEntArrayByName_Expensive( trig.GetTarget() )
		Assert( targs.len(), "Couldn't find player reset trigger target named " + trig.GetTarget() + " from trigger " + trig.GetName() )
		Assert( targs.len() == 1 )
		local targetEnt = targs[ 0 ]
		trig.s.targetOrg <- targetEnt.GetOrigin()
		trig.s.targetAng <- targetEnt.GetAngles()

		trig.ConnectOutput( "OnStartTouch", PlayerTouchedPlayerResetTrigger )
	}
}

function PlayerTouchedPlayerResetTrigger( trig, entity, caller, value )
{
	if ( entity != level.player )
		return

	Assert( trig.s.targetOrg && trig.s.targetAng )

	if ( Flag( "PlayerIsTeleporting" ) )
	{
		printt( "canceled teleport from trig", trig, "because a teleport is already happening." )
		return
	}

	EmitSoundOnEntity( level.player, "NPE_Player_Fail" )

	thread TeleportPlayer( trig.s.targetOrg, trig.s.targetAng, true, true )
}

function SetupGrenadeTriggers()
{
	local grenadeTrigs = GetEntArrayByNameWildCard_Expensive( "trig_grenade_target*" )
	foreach ( trig in grenadeTrigs )
	{
		local targs = GetEntArrayByName_Expensive( trig.GetTarget() )
		Assert( targs.len(), "Couldn't find light named " + trig.GetTarget() + " from trigger " + trig.GetName() )
		Assert( targs.len() == 1 )
		local targetEnt = targs[ 0 ]

		trig.s.fxSpot <- targetEnt
		trig.s.wasTriggered <- false
		trig.ConnectOutput( "OnStartTouch", GrenadeTriggerTouched )
	}

	level.grenadeTrigs = grenadeTrigs
}

function GrenadeTriggerTouched( trig, entity, caller, value )
{
	Assert( "wasTriggered" in trig.s )
	Assert( "fxSpot" in trig.s )

	if ( entity.GetClassname() != "npc_grenade_frag" )
		return

	trig.EndSignal( "OnDestroy" )
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )

	// let the grenade explode before it's registered
	trig.DisconnectOutput( "OnStartTouch", "GrenadeTriggerTouched" )
	wait 0.25

	EmitSoundOnEntity( level.player, "NPE_Player_Succeed" )

	// just turn the light off
	KillFX( trig.s.fxSpot.s.fxHandle )
	trig.s.wasTriggered = true
}

function ResetGrenadeTriggers()
{
	foreach ( trig in level.grenadeTrigs )
	{
		ChangeFXOnRef( trig.s.fxSpot, FX_LIGHT_ORANGE )
		trig.s.wasTriggered = false
	}
}

function SetupCabinWindowShutters()
{
	local shutterNames = [ "cabin_shutter_1", "cabin_shutter_2", "cabin_shutter_3", "cabin_shutter_4", "cabin_shutter_5", "cabin_shutter_6" ]

	foreach ( name in shutterNames )
	{
		local arr = GetEntArrayByName_Expensive( name )
		Assert( arr.len() == 1, "Couldn't find cabin window shutter named " + name )
		local shutter = arr[ 0 ]

		shutter.s.ogPos <- shutter.GetOrigin()
		shutter.s.ogAng <- shutter.GetAngles()

		level.cabinWindowShutters.append( shutter )
	}
}

function SetupSkyboxEnts()
{
	local arr = GetEntArrayByName_Expensive( "skybox_cam_level" )
	Assert( arr.len() == 1 )
	level.skyboxCamDefault = arr[ 0 ]

	local arr = GetEntArrayByName_Expensive( "skybox_cam_intro" )
	Assert( arr.len() == 1 )
	level.skyboxCamSpace = arr[ 0 ]

	local arr = GetEntArrayByName_Expensive( "skybox_model_space" )
	Assert( arr.len() == 1 )
	level.skyboxModelSpace = arr[ 0 ]
	level.skyboxModelSpace.s.ogAng <- level.skyboxModelSpace.GetAngles()
}


function SetupDoors()
{
	level.walkDoors = GetEntArrayByNameWildCard_Expensive( "walk_door*" )
	Assert( level.walkDoors.len() == 2 )

	level.sprintDoors = GetEntArrayByNameWildCard_Expensive( "sprint_door*" )
	Assert( level.sprintDoors.len() == 2 )

	local allDoors = clone level.walkDoors
	allDoors.extend( clone level.sprintDoors )

	foreach ( door in allDoors )
		door.s.ogPos <- door.GetOrigin()

	level.swapDoors <- {}
	AddSwapDoors( "door_walk_enter", "arch" )
	AddSwapDoors( "door_sprint_enter", "arch" )
	AddSwapDoors( "door_cloak_exit", "small" )
	AddSwapDoors( "door_cloak_secondexit", "small" )
	AddSwapDoors( "door_melee_enter", "small" )
	AddSwapDoors( "door_melee_exit", "small" )
	AddSwapDoors( "door_smartpistol_enter", "small" )
	AddSwapDoors( "door_smartpistol_exit", "small" )
	AddSwapDoors( "door_smartpistolpilots_enter", "small" )
	AddSwapDoors( "door_smartpistolpilots_exit", "small" )
	AddSwapDoors( "door_titan_dash_threat_enter", "titan" )
	AddSwapDoors( "door_titan_dash_threat_start", "titan" )
	AddSwapDoors( "door_titan_vortex_enter", "titan" )
	AddSwapDoors( "door_titan_vortex_exit", "titan" )
	AddSwapDoors( "door_titan_pet_gate", "titan" )
	AddSwapDoors( "door_titan_pet_exit_gate", "titan" )
	AddSwapDoors( "door_controlpanel_exit", "small" )
	AddSwapDoors( "door_controlpanel_enter", "small" )
}

// door pairs that slide open
function GetDoorPair( doorArray )
{
	local doorL
	local doorR
	foreach ( door in doorArray )
	{
		local doorName = door.GetName()
		local suffix = doorName.slice( doorName.len() - 2 )
		Assert( suffix == "_L" || suffix == "_R" )

		if ( suffix == "_L" )
			doorL = door
		else
			doorR = door
	}
	Assert( IsValid( doorL ) && IsValid( doorR ) )

	return { doorL = doorL, doorR = doorR }
}

function DoorPair_SnapOpen( doorArray, moveDist )
{
	DoorPair_Reset( doorArray )
	wait 0.05  // make sure the doors are done resetting before moving them

	local doors = GetDoorPair( doorArray )
	local doorL = doors.doorL
	local doorR = doors.doorR

	local doorL_org = doorL.GetOrigin()
	local doorL_movePos = Vector( doorL_org.x - moveDist, doorL_org.y, doorL_org.z )

	local doorR_org = doorR.GetOrigin()
	local doorR_movePos = Vector( doorR_org.x + moveDist, doorR_org.y, doorR_org.z )

	doorL.MoveTo( doorL_movePos, 0.05 )
	doorR.MoveTo( doorR_movePos, 0.05 )
}

function DoorPair_SnapClosed( doorArray )
{
	DoorPair_Reset( doorArray )

	local doors = GetDoorPair( doorArray )
	local doorL = doors.doorL
	local doorR = doors.doorR

	doorL.MoveTo( doorL.s.ogPos, 0.05 )
	doorR.MoveTo( doorR.s.ogPos, 0.05 )
}

/* DEPRECATED we don't use this anymore
function DoorPair_SlideOpen( doorArray, moveDist, moveTime, secondDoorDelay = 0.0 )
{
	local doors = GetDoorPair( doorArray )
	local doorL = doors.doorL
	local doorR = doors.doorR

	local doorL_org = doorL.GetOrigin()
	local doorL_movePos = Vector( doorL_org.x - moveDist, doorL_org.y, doorL_org.z )

	local doorR_org = doorR.GetOrigin()
	local doorR_movePos = Vector( doorR_org.x + moveDist, doorR_org.y, doorR_org.z )

	local accel = moveTime * 0.2
	local decel = moveTime * 0.2

	thread LoopSoundOnDoor_ForTime( doorL, "NPE_Scr_SprintDoor_Loop", moveTime, null, "NPE_Scr_SprintDoor_Shut", "NPE_Scr_SprintDoor_Stop" )

	doorL.MoveTo( doorL_movePos, moveTime, accel, decel )
	delaythread( secondDoorDelay ) doorR.MoveTo( doorR_movePos, moveTime, accel, decel )
}
*/

function DoorPair_SlideClosed( doorArray, moveTime, secondDoorDelay = 0, endFlag = null )
{
	local doors = GetDoorPair( doorArray )
	local doorL = doors.doorL
	local doorR = doors.doorR

	local accel = moveTime * 0.2
	local decel = moveTime * 0.2

	EmitSoundOnEntity( doorL, "NPE_Scr_SprintDoor_Start" )
	thread LoopSoundOnDoor_ForTime( doorL, "NPE_Scr_SprintDoor_Loop", moveTime, endFlag, "NPE_Scr_SprintDoor_Shut", "NPE_Scr_SprintDoor_Stop" )

	doorL.MoveTo( doorL.s.ogPos, moveTime, accel, decel )
	thread MoveTo_Delayed( secondDoorDelay, doorR, doorR.s.ogPos, moveTime, accel, decel )
}

function SetFlagWhenDoorsImpossibleToPass( doorArray, setFlag, stopSignal )
{
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )
	level.ent.EndSignal( stopSignal )

	// min dist the doors need to be apart for players to pass
	local minDistApart = 66  // player width is 64

	local doors = GetDoorPair( doorArray )
	local doorL = doors.doorL
	local doorR = doors.doorR

	Assert( Distance( doorL.GetOrigin(), doorL.s.ogPos ) + Distance( doorR.GetOrigin(), doorR.s.ogPos ) > minDistApart )

	doorL.EndSignal( "OnDestroy" )
	doorR.EndSignal( "OnDestroy" )

	local totalDist = 0
	while ( 1 )
	{
		local doorL_dist = Distance( doorL.GetOrigin(), doorL.s.ogPos )
		local doorR_dist = Distance( doorR.GetOrigin(), doorR.s.ogPos )
		totalDist = doorL_dist + doorR_dist
		//printt( "doorL_dist", doorL_dist, "doorR_dist", doorR_dist, "totalDist", totalDist )

		if ( totalDist <= minDistApart )
			break

		wait 0
	}

	//printt( "doors impossible to pass at dist", totalDist, "setting flag", setFlag )
	FlagSet( setFlag )
}

function LoopSoundOnDoor_ForTime( ent, alias, time, endFlag = null, endAlias = null, earlyEndAlias = null )
{
	ent.EndSignal( "OnDeath" )
	ent.EndSignal( "DoorResetting" )
	//printt( "looping sound")

	local expectedEndTime = Time() + time

	if ( endFlag )
		level.ent.EndSignal( endFlag )

	OnThreadEnd(
		function() : ( ent, alias, expectedEndTime, endAlias, earlyEndAlias )
		{
			//printt( "ending loop sound" )
			if ( IsValid( ent ) )
			{
				StopSoundOnEntity( ent, alias )

				if ( Time() < expectedEndTime && earlyEndAlias )
					EmitSoundOnEntity( ent, earlyEndAlias )
				else if ( Time() >= expectedEndTime && endAlias )
					EmitSoundOnEntity( ent, endAlias )
			}
		}
	)

	EmitSoundOnEntity( ent, alias )
	wait time
}

function DoorPair_Reset( doorArray )
{
	local doors = GetDoorPair( doorArray )

	foreach ( door in doors )
		door.Signal( "DoorResetting" )

	local didMoveTo = false
	foreach ( door in doors )
	{
		// doing a moveto
		if ( "_internalMover" in door.s )
		{
			door.MoveTo( door.s.ogPos, 0.05 )
			didMoveTo = true
			continue
		}

		door.SetOrigin( door.s.ogPos )
	}

	if ( didMoveTo )
		wait 0.05
}

function DoorPair_Freeze( doorPair )
{
	local doors = GetDoorPair( doorPair )
	foreach( door in doors )
		door.MoveTo( door.GetOrigin(), 0.05 )

	wait 0.05
}

function AddSwapDoors( tnPrefix, doorSize = null )
{
	Assert( !( tnPrefix in level.swapDoors ), "Tried to set up swap doors twice: " + tnPrefix )

	level.swapDoors[ tnPrefix ] <- SetupSwapDoors( tnPrefix, doorSize )
}

// grid style doors that swap
function SetupSwapDoors( tnPrefix, doorSize = null )
{
	local doorClosed
	local doorOpen

	local doors = GetEntArrayByNameWildCard_Expensive( tnPrefix + "*" )
	foreach ( door in doors )
	{
		local doorName = door.GetName()

		if ( doorName.find( "_red" ) )
			doorClosed = door
		else if ( doorName.find( "_green" ) )
			doorOpen = door
		else
			printt( "Couldn't find red/green door using prefix", tnPrefix )
	}
	Assert( IsValid( doorClosed ) && IsValid( doorOpen ) )

	doorClosed.s.ogPos <- doorClosed.GetOrigin()
	doorOpen.s.doorSize <- doorSize

	doorOpen.s.fxSpot <- null
	local targs = GetEntArrayByName_Expensive( doorOpen.GetTarget() )
	if ( targs.len() )
	{
		Assert( targs.len() == 1 )
		local targetEnt = targs[ 0 ]
		printt( doorOpen.GetName(), "found target ent" )
		doorOpen.s.fxSpot = targetEnt
	}
	else
	{
		local centerpoint = OriginToGround( doorOpen.GetOrigin() )
		local centerang = doorOpen.GetAngles() + Vector( 0, 90, 0 )  // HACK
		doorOpen.s.fxSpot = CreateScriptRef( centerpoint, centerang )
	}

	return { doorClosed = doorClosed, doorOpen = doorOpen }
}

function GetSwapDoors( tnPrefix )
{
	Assert( tnPrefix in level.swapDoors, "No swap doors found with prefix name " + tnPrefix )
	return level.swapDoors[ tnPrefix ]
}

function OpenSwapDoors( tnPrefix )
{
	local doors = GetSwapDoors( tnPrefix )
	local doorClosed = doors.doorClosed
	local doorOpen = doors.doorOpen

	doorClosed.Hide()
	doorClosed.MoveTo( doorClosed.GetOrigin() + Vector( 0, 0, 256 ), 0.05 )

	doorOpen.Show()

	StopSwapDoorLoopSFX( doorOpen )
	EmitSoundAtPosition( doorOpen.GetOrigin(), "NPE_Scr_DigitalDoor_Open" )

	// doors replaced with FX
	if ( doorOpen.s.doorSize )
	{
		SwapDoorOpenFX( doorOpen )
		doorOpen.Hide()
	}
}

function CloseSwapDoors( tnPrefix )
{
	local doors = GetSwapDoors( tnPrefix )
	local doorClosed = doors.doorClosed
	local doorOpen = doors.doorOpen

	Assert( "ogPos" in doorClosed.s, "Couldn't find ogPos for door " + doorClosed )
	doorClosed.MoveTo( doorClosed.s.ogPos, 0.05 )
	doorClosed.Show()

	doorOpen.Hide()
	StartSwapDoorLoopSFX( doorOpen )

	// doors replaced with FX
	if ( doorOpen.s.doorSize )
	{
		SwapDoorCloseFX( doorOpen )
		doorClosed.Hide()
	}
}

function SwapDoorOpenFX( swapDoor )
{
	Assert( "fxSpot" in swapDoor.s )

	local doorSize = swapDoor.s.doorSize

	local doorFX = FX_SWAPDOOR_OPEN
	if ( doorSize == "titan" )
		doorFX = FX_SWAPDOOR_OPEN_TITAN
	else if ( doorSize == "arch" )
		doorFX = FX_SWAPDOOR_OPEN_ARCH

	ChangeFXOnRef( swapDoor.s.fxSpot, doorFX, 2 )
}

function SwapDoorCloseFX( swapDoor )
{
	Assert( "fxSpot" in swapDoor.s )

	local doorSize = swapDoor.s.doorSize

	local doorFX = FX_SWAPDOOR_CLOSED
	if ( doorSize == "titan" )
		doorFX = FX_SWAPDOOR_CLOSED_TITAN
	else if ( doorSize == "arch" )
		doorFX = FX_SWAPDOOR_CLOSED_ARCH

	ChangeFXOnRef( swapDoor.s.fxSpot, doorFX, 2 )
}

function StartSwapDoorLoopSFX( swapDoor )
{
	if ( !( "loopSFX" in swapDoor.s ) )
		swapDoor.s.loopSFX <- null
	else if ( swapDoor.s.loopSFX )
	{
		// already playing
		return
	}

	EmitSoundOnEntity( swapDoor, "NPE_Emit_DigitalDoor_Presence" )
	swapDoor.s.loopSFX = "NPE_Emit_DigitalDoor_Presence"
}

function StopSwapDoorLoopSFX( swapDoor )
{
	if ( !( "loopSFX" in swapDoor.s ) || !swapDoor.s.loopSFX )
		return

	StopSoundOnEntity( swapDoor, "NPE_Emit_DigitalDoor_Presence" )
	swapDoor.s.loopSFX = null
}


function SetupTrainingPod()
{
	local arr = GetEntArrayByName_Expensive( "training_pod" )
	Assert( arr.len() == 1 )
	level.trainingPod = arr[ 0 ]
	level.trainingPod.s.laserEmitters <- []
	level.trainingPod.s.glowLightFXHandles <- []
	level.trainingPod.s.dLights <- []

	TrainingPod_SetupInteriorDLights()

	local laserAttachNames = [ "fx_laser_L", "fx_laser_R" ]

	foreach ( attachName in laserAttachNames )
	{
		local emitter = CreateScriptMover( level.trainingPod )
		local attachID = level.trainingPod.LookupAttachment( attachName )
		local attachAng = level.trainingPod.GetAttachmentAngles( attachID )

		emitter.s.attachName <- attachName
		emitter.s.ogAng 	<- attachAng
		emitter.s.sweepDone <- false
		emitter.s.fxHandle 	<- null

		level.trainingPod.s.laserEmitters.append( emitter )
	}

	// HACK we do this later as well to reset the emitter positions, so it's a separate function
	TrainingPod_SnapLaserEmittersToAttachPoints()

	level.trainingPod.SetAngles( Vector( 0, 109, 0 ) )  // these angles are a little better for seeing the room
}

function TrainingPod_SetupInteriorDLights()
{
	local pod = level.trainingPod

    local map = []
    map.append( { scriptAlias = "console1", 		fxName = FX_POD_DLIGHT_CONSOLE1, 		attachName = "light_console1" } )
    map.append( { scriptAlias = "console2", 		fxName = FX_POD_DLIGHT_CONSOLE2, 		attachName = "light_console2" } )
    map.append( { scriptAlias = "backlight_side_L", fxName = FX_POD_DLIGHT_BACKLIGHT_SIDE, 	attachName = "light_back1" } )
    map.append( { scriptAlias = "backlight_side_R", fxName = FX_POD_DLIGHT_BACKLIGHT_SIDE, 	attachName = "light_back2" } )
    map.append( { scriptAlias = "backlight_top", 	fxName = FX_POD_DLIGHT_BACKLIGHT_TOP, 	attachName = "light_backtop" } )
    level.trainingPod.s.dLightMappings <- map
}

function TrainingPod_TurnOnInteriorDLights_Delayed( delay )
{
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )

	wait delay

	TrainingPod_TurnOnInteriorDLight( "console1" )
	TrainingPod_TurnOnInteriorDLight( "console2" )
}

function TrainingPod_TurnOnInteriorDLight( scriptAlias )
{
	local pod = level.trainingPod

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
	level.trainingPod.s.dLights.append( fxHandle )
}

function TrainingPod_KillInteriorDLights_Delayed( delay )
{
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )

	wait delay

	TrainingPod_KillInteriorDLights()
}

function TrainingPod_KillInteriorDLights()
{
	foreach ( fxHandle in level.trainingPod.s.dLights )
	{
		if ( !IsValid_ThisFrame( fxHandle ) )
			continue

		KillFX( fxHandle )
	}

	level.trainingPod.s.dLights = []
}

function TrainingPod_SnapLaserEmittersToAttachPoints()
{
	foreach ( emitter in level.trainingPod.s.laserEmitters )
	{
		local attachID = level.trainingPod.LookupAttachment( emitter.s.attachName )
		local attachOrg = level.trainingPod.GetAttachmentOrigin( attachID )
		local attachAng = level.trainingPod.GetAttachmentAngles( attachID )

		emitter.ClearParent()
		emitter.SetOrigin( attachOrg )  // HACK set this to ANYTHING  (even 0, 0, 0) and the position is correct, otherwise it's offset from the attachpoint when parented
		emitter.SetParent( level.trainingPod, emitter.s.attachName )
	}
}

function DrawEmitterArrows()
{
	level.ent.EndSignal( "ModuleChanging" )
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )

	while ( 1 )
	{
		foreach ( e in level.trainingPod.s.laserEmitters )
			DrawArrow( e.GetOrigin(), e.GetAngles(), 1, 10 )

		wait 1
	}
}

function TrainingPod_GlowLightsArraySetup()
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

	level.trainingPodGlowLightRows = rows
}


// =========================== MODULE THINK FUNCTIONS ===========================
function Module_Bedroom()
{
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )

	level.player.WaitSignal( "Teleported" )

	ResetCabinHoloscreen()

	DisablePilotHud()

	local player = level.player
	local pod = level.trainingPod

	OnThreadEnd(
		function() : ()
		{
			if ( IsValid( level.player ) )
			{
				level.player.Anim_Stop()
				level.player.ClearAnimViewEntity()
				level.player.ClearParent()
				level.player.UnforceStand()
				StopSoundOnEntity( level.player, "Amb_NPE_Cabin_Intro" )
			}

			if ( IsValid ( level.trainingPod ) )
			{
				level.trainingPod.Anim_Stop()

				thread TrainingPod_ResetLaserEmitterRotation( level.trainingPod )
				thread TrainingPod_KillLasers( level.trainingPod )
				thread TrainingPod_KillGlowFX( level.trainingPod )
				TrainingPod_KillInteriorDLights()
			}

			if ( IsValid( level.player ) && IsValid( level.trainingPod ) )
				Remote.CallFunction_Replay( level.player, "ScriptCallback_LookTargets_KillLights" )
		}
	)

	// Have to do this first so the anim starts centered on the ref attachment angles
	local podAttach = "REF"
	local attachID = pod.LookupAttachment( podAttach )
	local podRefOrg = pod.GetAttachmentOrigin( attachID )
	local podRefAng = pod.GetAttachmentAngles( attachID )
	player.SetOrigin( podRefOrg )
	player.SetAngles( podRefAng )

	player.ForceStand()

	// default start anim starts open
	local viewConeFunction_start = TrainingPod_ViewConeLock_PodOpen
	local podAnim_start = "trainingpod_doors_open_idle"
	if ( level.doQuickIntro )
	{
		// quick start anim starts closed
		viewConeFunction_start = TrainingPod_ViewConeLock_PodClosed
		podAnim_start = "trainingpod_doors_close_idle"
	}

	// start open idle
	local playerSequence = CreateFirstPersonSequence()
	playerSequence.blendTime 			= 0.0
	playerSequence.attachment 			= podAttach
	playerSequence.firstPersonAnimIdle 	= "ptpov_trainingpod_idle"
	playerSequence.thirdPersonAnimIdle 	= "pt_trainingpod_idle"
	playerSequence.viewConeFunction 	= viewConeFunction_start
	playerSequence.renderWithViewModels = true

	local podSequence = CreateFirstPersonSequence()
	podSequence.blendTime 				= 0.0
	podSequence.thirdPersonAnimIdle 	= podAnim_start
	podSequence.renderWithViewModels 	= true

	thread FirstPersonSequence( podSequence, pod )
	thread FirstPersonSequence( playerSequence, player, pod )

	if ( !level.doQuickIntro )
	{
		TrainingPod_TurnOnInteriorDLight( "console1" )
		TrainingPod_TurnOnInteriorDLight( "console2" )
		//TrainingPod_TurnOnInteriorDLight( "backlight_side_L" )
		//TrainingPod_TurnOnInteriorDLight( "backlight_side_R" )
	}

	local startTime = Time()
	level.ent.WaitSignal( "ModuleChangeDone" )

	EmitSoundOnEntity( level.player, "Amb_NPE_Cabin_Intro" )

	TakeAllWeapons( player )

	local minWaitEnd = -1

	if ( !level.doQuickIntro )
	{
		wait 3

		local warningVOEmitterPos = level.trainingPod.GetAttachmentOrigin( level.trainingPod.LookupAttachment( "fx_lookat_top" ) )

		// This unit is authorized for: military use only.
		EmitSoundAtPosition( warningVOEmitterPos, "diag_npeLevelmsg_pickup_01" )
		wait 3.2  // line time

		// extra time
		wait 1

		// Possession by an individual is a Class One felony.
		EmitSoundAtPosition( warningVOEmitterPos, "diag_npeLevelmsg_pickup_02" )
		wait 3.2

		// --- WAIT FOR BUTTON PRESS TO CLOSE ---
		FlagClear( "PlayerPressedUse" )
		thread IntroPod_HandlePrompt()
		FlagWait( "PlayerPressedUse" )

		minWaitEnd = 11 + Time()

		ForcePlayConversationToPlayer( "intro", level.player )
		wait 3.25 // timed so that the "key accepted" happens after viewhand pushes buttons
	}

	if ( !level.doQuickIntro )
	{
		// normal intro sequence
		local playerSequence = CreateFirstPersonSequence()
		playerSequence.blendTime 			= 0.25
		playerSequence.attachment 			= podAttach
		playerSequence.firstPersonAnim 		= "ptpov_trainingpod_doors_close"
		playerSequence.firstPersonAnimIdle 	= "ptpov_trainingpod_idle"
		playerSequence.thirdPersonAnim 		= "pt_trainingpod_doors_close"
		playerSequence.thirdPersonAnimIdle 	= "pt_trainingpod_idle"
		playerSequence.viewConeFunction 	= TrainingPod_ViewConeLock_SemiStrict
		playerSequence.renderWithViewModels = true

		local podSequence = CreateFirstPersonSequence()
		podSequence.blendTime 				= 0.25
		podSequence.thirdPersonAnim 		= "trainingpod_doors_close"
		podSequence.thirdPersonAnimIdle 	= "trainingpod_doors_close_idle"
		podSequence.renderWithViewModels 	= true

		// HACK this should be based on an anim event
		thread TrainingPod_KillInteriorDLights_Delayed( 2.65 )

		thread FirstPersonSequence( podSequence, pod )
		waitthread FirstPersonSequence( playerSequence, player, pod )
	}

	waitthread WaittillTime( minWaitEnd )

	TrainingPod_ViewConeLock_PodClosed( level.player )

	// resumeChoice will have been set up before this runs based on how we are starting the level (first run, dev, or continuing)	
	FlagWait("ConversationOver")
	FlagClear("ConversationOver")
	ForcePlayConversationToPlayer( "intro_welcome", level.player )

	FlagWait("ConversationOver")
	FlagClear("ConversationOver")
	wait 1.5

	waitthread LookTraining()
	
	thread TrainingPod_Interior_BootSequence()
	level.ent.WaitSignal( "PodInteriorSequenceDone" )
	//printt( "POD SEQUENCE DONE" )

	wait 1

	local printstr = "bedroom intro about to increment and advance module, level.currentTrainingModule is " + level.currentTrainingModule
	//printt( printstr )
	printtodiag( printstr + "\n" )
	AdvanceToNextTrainingModule()
}


function IntroPod_HandlePrompt()
{
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )

	OnThreadEnd(
		function() : ()
		{
			if ( IsValid ( level.player ) )
			{
				HideTrainingPrompt()
			}
		}
	)

	DisplayTrainingPrompt( eTrainingButtonPrompts.START_SIM )

	level.ent.WaitSignal( "PlayerPressedUse" )
	EmitSoundOnEntity( level.player, "NPE_Player_Succeed" )
}


function LookTraining()
{
	// LOOKAT SECTION
	ForcePlayConversationToPlayer( "train_lookat", level.player )
	wait 3.5

	// TrainingPod_ViewConeLock_PodClosed( level.player )
	DisplayTrainingPrompt( eTrainingButtonPrompts.LOOK )

	// 마우스 회전축 연습만 남기고,
	Remote.CallFunction_Replay( level.player, "ScriptCallback_SetupLookTargets" )
	wait 0.5
	Remote.CallFunction_Replay( level.player, "ScriptCallback_LookTargets_WaitForLookat" )
	FlagWait( "PlayerLookedAtTopTarget" )
	FlagWait( "PlayerLookedAtBottomTarget" )
	
	 // 회전축 변경 팝업은 삭제
	/* local numInverts = 0
	local doConfirmMenu = false
	local doConfirmAudio = false
	while ( 1 )
	{
		Remote.CallFunction_Replay( level.player, "ScriptCallback_SetupLookTargets" )
		wait 0.5
		Remote.CallFunction_Replay( level.player, "ScriptCallback_LookTargets_WaitForLookat" )
		FlagWait( "PlayerLookedAtTopTarget" )
		FlagWait( "PlayerLookedAtBottomTarget" )

		doConfirmMenu = ( numInverts > 0 )
		doConfirmAudio = ( numInverts < 2 )

		// Would you like to reverse the vertical look input?
		local askAlias = "train_lookat_askIfInvertSettingIsGood"
		local askWait = 2
		// Y/N question is swapped on confirmation menu
		if ( doConfirmMenu )
		{
			// If these look input settings are to your liking, choose 'Yes.' Otherwise, choose 'No' to reverse the look input and try again.
			askAlias = "train_lookat_askIfInvertSettingIsGood_verbose"
			askWait = 4.5
		}

		if ( doConfirmAudio )
		{
			ForcePlayConversationToPlayer( askAlias, level.player )
			wait askWait
		}

		Remote.CallFunction_UI( level.player, "ServerCallback_ShowInvertLookMenu", doConfirmMenu )

		// wait for menu input
		local doneSig 		= "PlayerClickedNoButton"
		local tryAgainSig 	= "PlayerInvertedLook"
		if ( doConfirmMenu )
		{
			doneSig = "InvertSettingsConfirmed"
			tryAgainSig = "PlayerClickedNoButton"
		}

		local resultTable = WaitSignal( level.ent, doneSig, tryAgainSig )
		local sig = resultTable.signal
		if ( sig == doneSig )
			break

		numInverts++

		Remote.CallFunction_Replay( level.player, "ScriptCallback_LookTargets_KillLights" )

		// Please confirm your selection by looking at each of the lights again.
		ForcePlayConversationToPlayer( "train_lookat_confirmInvertSetting", level.player )
		wait 2
		TrainingPod_ViewConeLock_PodClosed( level.player )

		FlagClear( "PlayerLookedAtTopTarget" )
		FlagClear( "PlayerLookedAtBottomTarget" )
	}*/
	// 여기까지 회전축 변경 팝업삭제.

	HideTrainingPrompt()

	TrainingPod_ViewConeLock_PodClosed( level.player )

	ForcePlayConversationToPlayer( "train_lookat_pt2", level.player )
	wait 2
	TrainingPod_ViewConeLock_SemiStrict( level.player )  // recenter player view
	Remote.CallFunction_Replay( level.player, "ScriptCallback_LookTargets_KillLights" )
}


function TrainingPod_InteriorFX_CommonSetup()
{
	local pod = level.trainingPod

	if ( pod.s.laserEmitters.len() )
	{
		TrainingPod_KillLasers( pod )
		TrainingPod_ResetLaserEmitterRotation( pod )
	}

	TrainingPod_KillGlowFX( pod )
	//wait 1  // pause for iteration, to catch the sequence starting again
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


function TrainingPod_Interior_BootSequence()
{
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )

	TrainingPod_InteriorFX_CommonSetup()

	local pod = level.trainingPod

	EmitSoundOnEntity( level.player, "NPE_Scr_SimPod_PowerUp" )

	// Transition screen FX
	thread PlayFXOnEntity_Delayed( FX_POD_SCREEN_IN, level.player, 2.35 )

	// GLOW LIGHTS
	local lightWait = 0.015
	local rowWait 	= 0.05
	TrainingPod_GlowLightsTurnOn( lightWait, rowWait )

    // LASERS
    local longestSweepTime = -1
	foreach ( emitter in pod.s.laserEmitters )
	{
		local sweepTime = RandomFloat( 2.9, 3.15 )
		if ( sweepTime > longestSweepTime )
			longestSweepTime = sweepTime

		thread LaserSweep( sweepTime, emitter, pod, "top" )
	}

	wait longestSweepTime

    level.ent.Signal( "PodInteriorSequenceDone" )
}

function TrainingPod_GlowLightsTurnOn( lightWait, rowWait )
{
	//local startTime = Time()

	local pod = level.trainingPod

	// light up one light on each side at a time
	foreach ( row in level.trainingPodGlowLightRows )
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

// NOTE startPosition is actually inverted from what I think it should be. Tag orientation issue, maybe?
function LaserSweep( totalTime, emitter, pod, startPosition = "bottom" )
{
	//local startTime = Time()

	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	emitter.EndSignal( "OnDeath" )
	level.ent.EndSignal( "ModuleChanging" )

	emitter.s.sweepDone = false

	//printt( "emitter og angles:", emitter.GetAngles() )

	local vecToPlayerEye = ( level.player.EyePosition() + Vector( 0, 0, 7 ) ) - emitter.GetOrigin()  // eye position offset is a HACK, not sure why I need to do that here.
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


function TrainingPod_Interior_ShutdownSequence( shutdownTime )
{
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )

	TrainingPod_InteriorFX_CommonSetup()

	local pod = level.trainingPod

	// TURN ON GLOW LIGHTS
	TrainingPod_GlowLightsTurnOn( 0, 0 )

	// TURN ON LASERS
	thread TrainingPod_LasersInstantOn( pod )

	level.ent.WaitSignal( "TrainingPod_BeginInteriorShutdown" )

	thread TrainingPod_LasersShutDown( pod, shutdownTime * 0.7 )
	thread TrainingPod_GlowLightsShutDown( pod, shutdownTime )

	wait shutdownTime
	printt( "interior shutdown done" )
}

function TrainingPod_LasersInstantOn( pod )
{
	foreach ( emitter in pod.s.laserEmitters )
	{
		local vecToPlayerEye = ( level.player.EyePosition() + Vector( 0, 0, 7 ) ) - emitter.GetOrigin()  // eye position offset is a HACK, not sure why I need to do that here.
		local centerAng = VectorToAngles( vecToPlayerEye )
		emitter.RotateTo( centerAng, 0.05 )  // SETANGLES DOES NOT WORK! You have to rotate it for the FX to follow.

		local fxHandle = PlayLoopFXOnEntity( FX_POD_LASER, emitter )
		emitter.s.fxHandle = fxHandle
	}
}

function TrainingPod_LasersShutDown( pod, shutdownTime )
{
	level.player.EndSignal( "Teleported" )
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )

	local accelTime = shutdownTime * 0.25
	local decelTime = shutdownTime * 0.1

	foreach ( emitter in pod.s.laserEmitters )
	{
		local finalAng = emitter.GetAngles() + Vector( 30, 0, 0 )  // not sure why adding pitch makes them appear to drop down.
		emitter.RotateTo( finalAng, shutdownTime, accelTime, decelTime )
	}

	wait shutdownTime

	TrainingPod_KillLasers( pod, true )
}

function TrainingPod_GlowLightsShutDown( pod, shutdownTime )
{
	level.player.EndSignal( "Teleported" )
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )

	// reverse the array order
	/*
	local fxHandles = []
	for ( local i = ( pod.s.glowLightFXHandles.len() - 1 ); i > -1; i-- )
		fxHandles.append( pod.s.glowLightFXHandles[ i ] )
	*/
	local fxHandles = pod.s.glowLightFXHandles

	local timePerLight = shutdownTime / fxHandles.len()

	foreach ( fxHandle in fxHandles )
	{
		if ( !IsValid_ThisFrame( fxHandle ) )
			continue

		thread KillFXWithEndcap( fxHandle )
		wait timePerLight
	}
}

function Module_Bedroom_End()
{
	thread EmitSoundOnEntity_Delayed( level.player, "NPE_Scr_SimPod_End", 2.9 )

	level.player.WaitSignal( "Teleported" )
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )

	//thread DrawEmitterArrows()

	Remote.CallFunction_Replay( level.player, "ServerCallback_DisableFog" )

	ResetCabinHoloscreen()

	DisablePilotHud()

	local player = level.player
	local pod = level.trainingPod

	OnThreadEnd(
		function() : ()
		{
			if ( IsValid( level.player ) )
			{
				level.player.Anim_Stop()
				level.player.ClearAnimViewEntity()
				level.player.ClearParent()
				level.player.UnforceStand()
				StopSoundOnEntity( level.player, "Amb_NPE_Cabin_Reveal" )
				StopSoundOnEntity( level.player, "Music_NPE_Cabin_Reveal" )
				StopSoundOnEntity( level.player, "NPE_Scr_SimPod_End" )
				StopSoundOnEntity( level.player, "NPE_Scr_EngineSlow" )
				StopSoundOnEntity( level.player, "NPE_Scr_ScreenFlickerOff" )
				StopSoundOnEntity( level.player, "NPE_Scr_BlastDoorOpen" )
			}

			if ( IsValid ( level.trainingPod ) )
			{
				level.trainingPod.Anim_Stop()
				TrainingPod_KillInteriorDLights()
			}

			if ( IsValid( level.skyboxModelSpace ) )
				level.skyboxModelSpace.RotateTo( level.skyboxModelSpace.s.ogAng, 0.05 )

			thread ResetCabinWindowShutters()
		}
	)

	EmitSoundOnEntity( level.player, "Amb_NPE_Cabin_Reveal" )
	thread PlayFXOnEntity_Delayed( FX_POD_SCREEN_OUT, level.player, 0.2 )  // play screenFX here so it shows up as we exit the blackscreen

	local podAttach = "REF"
	local attachID = pod.LookupAttachment( podAttach )
	local podRefOrg = pod.GetAttachmentOrigin( attachID )
	local podRefAng = pod.GetAttachmentAngles( attachID )
	player.SetOrigin( podRefOrg )
	player.SetAngles( podRefAng )

	player.ForceStand()

	thread TrainingPod_Interior_ShutdownSequence( 4.35 )

	level.skyboxCamSpace.SetAngles( Vector( 0, 88, -30 ) )
	player.SetSkyCamera( level.skyboxCamSpace )

	// start closed idle
	local playerSequence = CreateFirstPersonSequence()
	playerSequence.blendTime 			= 0.0
	playerSequence.attachment 			= podAttach
	playerSequence.firstPersonAnimIdle 	= "ptpov_trainingpod_idle"
	playerSequence.thirdPersonAnimIdle 	= "pt_trainingpod_idle"
	playerSequence.viewConeFunction 	= TrainingPod_ViewConeLock_PodClosed
	playerSequence.renderWithViewModels = true

	local podSequence = CreateFirstPersonSequence()
	podSequence.blendTime 				= 0.0
	podSequence.thirdPersonAnimIdle 	= "trainingpod_doors_close_idle"
	podSequence.renderWithViewModels 	= true

	thread FirstPersonSequence( playerSequence, player, pod )
	thread FirstPersonSequence( podSequence, pod )

	// HACK reparent the emitters so they look correct, I didn't expect to have to do this
	TrainingPod_SnapLaserEmittersToAttachPoints()

	local startTime = Time()
	level.ent.WaitSignal( "ModuleChangeDone" )

	TakeAllWeapons( player )

	// time staring at inside of pod
	wait 1.5

	ForcePlayConversationToPlayer( "outro_simulator_finished", level.player )

	if ( level.doQuickOutro )
	{
		// stage the outside of the pod to have the cabin window already open
		FadeCabinHoloscreen( 0 )
		thread OpenCabinWindowShutters( 2, false )
		thread RotateSkyboxModel()
	}

	level.ent.Signal( "TrainingPod_BeginInteriorShutdown" )
	wait 2

	local playerSequence = CreateFirstPersonSequence()
	playerSequence.blendTime 			= 0.25
	playerSequence.attachment 			= podAttach
	playerSequence.firstPersonAnim 		= "ptpov_trainingpod_doors_open"
	playerSequence.firstPersonAnimIdle 	= "ptpov_trainingpod_idle"
	playerSequence.thirdPersonAnim 		= "pt_trainingpod_doors_open"
	playerSequence.thirdPersonAnimIdle 	= "pt_trainingpod_idle"
	playerSequence.viewConeFunction 	= TrainingPod_ViewConeLock_SemiStrict
	playerSequence.renderWithViewModels = true

	local podSequence = CreateFirstPersonSequence()
	podSequence.blendTime 				= 0.25
	podSequence.thirdPersonAnim 		= "trainingpod_doors_open"
	podSequence.thirdPersonAnimIdle 	= "trainingpod_doors_open_idle"
	podSequence.renderWithViewModels 	= true

	thread TrainingPod_TurnOnInteriorDLights_Delayed( 1.5 )

	thread FirstPersonSequence( podSequence, pod )
	waitthread FirstPersonSequence( playerSequence, player, pod )

	TrainingPod_ViewConeLock_PodOpen( level.player )

	if ( !level.doQuickOutro )
	{
		wait 0.5
		//printt( "ENGINE START SPINNING DOWN" )
		EmitSoundOnEntity( level.player, "NPE_Scr_EngineSlow" )

		wait 0.2
		//printt( "TURBULENCE START" )
		Remote.CallFunction_Replay( level.player, "ServerCallback_Turbulence" )

		wait 3
		EmitSoundOnEntity( level.player, "NPE_Scr_ScreenFlickerOff" )
		FadeCabinHoloscreen( 4 )

		wait 1
		//printt( "PA ANNOUNCE START" )
		// All hands, listen up. We're 5 minutes out from Horizon Station.
		// Pilots, this is your stop. You got 10 minutes to collect your gear and get off my boat.
		ForcePlayConversationToPlayer( "cabin_PA", level.player )

		wait 2

		thread RotateSkyboxModel()

		wait 2

		//printt( "MUSIC START" )
		EmitSoundOnEntity( level.player, "Music_NPE_Cabin_Reveal" )

		wait 1
		//printt( "OPEN SHUTTERS" )
		thread OpenCabinWindowShutters( 6 )

		wait 7
		// Welcome to the Frontier.
		ForcePlayConversationToPlayer( "cabin_PA_welcome", level.player )

		wait 5

		// Now that we've heard the money line, remember that we've seen the cinematic ending of the level
		//Remote.CallFunction_NonReplay( level.player, "ServerCallback_SetPlayerHasFinishedTraining" )

		wait 1
	}
	else
	{
		// time to look at the cabin before fading out
		wait 0.5
	}

	ScreenFadeToBlack( level.player, 2.5, 60.0 )
	wait 2
	MuteAll( level.player, 2 )

	wait 2

	if ( !NPE_DEV_TEST || ( NPE_DEV_TEST && NPE_DEV_RETURN_TO_LOBBY ) )
		ReturnToLobby()
	else
		level.ent.WaitSignal( "ModuleChanging" )
}

function ResetCabinHoloscreen()
{
	Remote.CallFunction_Replay( level.player, "ServerCallback_ResetHoloscreen" )
}

function FadeCabinHoloscreen( fadeTime )
{
	Remote.CallFunction_Replay( level.player, "ServerCallback_FadeHoloscreen", fadeTime )
}

function RotateSkyboxModel( yawRotateDist = -45, rotateTime = 30 )
{
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )

	level.ent.Signal( "StopSkyRotation" )
	level.ent.EndSignal( "StopSkyRotation" )

	OnThreadEnd(
		function() : ()
		{
			if ( IsValid( level.skyboxModelSpace ) )
				level.skyboxModelSpace.RotateTo( level.skyboxModelSpace.s.ogAng, 0.05 )
		}
	)

	local currAng = level.skyboxModelSpace.GetAngles()
	local newAng = currAng + Vector( 0, yawRotateDist, 0 )

	level.skyboxModelSpace.RotateTo( newAng, rotateTime, 0, 0 )
	wait rotateTime
}

function OpenCabinWindowShutters( totalMoveTime, doSound = true )
{
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )

	local timePerMove = totalMoveTime.tofloat() / level.cabinWindowShutters.len().tofloat()
	local accelTime = timePerMove * 0.2
	local decelTime = timePerMove * 0.1

	local moveY = -6
	local moveZ = 26

	if ( doSound )
		thread EmitSoundOnEntity_Delayed( level.player, "NPE_Scr_BlastDoorOpen", 0.25 )

	foreach ( idx, shutter in level.cabinWindowShutters )
	{
		if ( idx == level.cabinWindowShutters.len() - 1 )
			moveZ = 12

		local movePos = shutter.GetOrigin() + Vector( 0, moveY, moveZ )
		shutter.MoveTo( movePos, timePerMove, accelTime, decelTime )
		wait timePerMove

		if ( idx < ( level.cabinWindowShutters.len() - 1 ) )
			shutter.SetParent( level.cabinWindowShutters[ idx + 1 ] )
	}

	printt( "cabin window shutters opened" )
}

function ResetCabinWindowShutters()
{
	foreach ( shutter in level.cabinWindowShutters )
	{
		shutter.MoveTo( shutter.GetOrigin(), 0.05 )
		shutter.RotateTo( shutter.GetAngles(), 0.05 )
		wait 0.05

		shutter.SetOrigin( shutter.s.ogPos )
		shutter.SetAngles( shutter.s.ogAng )
	}
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

function TrainingPod_ViewConeLock_Strict( player )
{
	player.PlayerCone_FromAnim()
	player.PlayerCone_SetMinYaw( 0 )
	player.PlayerCone_SetMaxYaw( 0 )
	player.PlayerCone_SetMinPitch( 0 )
	player.PlayerCone_SetMaxPitch( 0 )
}


function Module_RunAndJump()
{
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )

	CloseSwapDoors( "door_walk_enter" )
	CloseSwapDoors( "door_sprint_enter" )
	wait 0.1

	local walkDoorsSnapOpenDist = 80
	local sprintDoorsSnapOpenDist = 80
	DoorPair_SnapOpen( level.walkDoors, walkDoorsSnapOpenDist )
	DoorPair_SnapOpen( level.sprintDoors, sprintDoorsSnapOpenDist )

	local sprintLightTrigs = [ "trigger_lightswitch3", "trigger_lightswitch2", "trigger_lightswitch" ]
	// gotta sprint through these triggers to make the sprint lights go
	foreach ( trigTN in sprintLightTrigs )
	{
		LightTrigger_Off( trigTN )
		TriggerSetRequireSprint( trigTN )
	}

	local walkLightTrigs = [ "trigger_lightswitch5", "trigger_lightswitch7", "trigger_lightswitch" ]
	foreach ( trigTN in walkLightTrigs )
		LightTrigger_Off( trigTN )

	level.ent.WaitSignal( "ModuleChangeDone" )

	DisablePilotHud()

	OnThreadEnd(
		function() : ()
		{
			if ( IsValid( level.player ) )
			{
				EnablePilotHud()
			}
		}
	)

	EnablePilotHud()

	waitthread MoveTraining( walkDoorsSnapOpenDist, walkLightTrigs )
	wait 1

	waitthread SprintTraining( sprintDoorsSnapOpenDist, sprintLightTrigs )

	thread JumpTrainingVO()

	FlagWait( "PlayerNearJump" )
	DisplayTrainingPrompt( eTrainingButtonPrompts.JUMP )

	FlagWait( "PlayerPastJump" )
	DisplayTrainingPrompt( eTrainingButtonPrompts.LONGJUMP )

	// sprint-and-jump combo- help them out if they already forgot how to sprint
	local sig
	local numResets = 0
	while ( 1 )
	{
		sig = ""
		local result = WaitSignal( level.ent, "PlayerPastRunAndJump", "TeleportedPlayer" )
		sig = result.signal
		if ( sig == "PlayerPastRunAndJump" )
		{
			StopControllerImageHint()
			break
		}

		numResets++
		if ( numResets % 2 == 0 )
		{
			ForcePlayConversationToPlayer( "train_sprint_and_jump_help", level.player )
			ControllerImageHint_Sprint()
		}
	}

	FlagWait( "PlayerPastRunAndJump" )
	HideTrainingPrompt()

	FlagWait( "PlayerNearMantle" )
	DisplayTrainingPrompt( eTrainingButtonPrompts.MANTLE )

	FlagWait( "PlayerPastMantle" )
	HideTrainingPrompt()

	level.ent.WaitSignal( "ModuleChanging" )
	HideTrainingPrompt()
}

function JumpTrainingVO()
{
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )

	// trigger flag
	FlagWait( "PlayerNearJump" )
	ForcePlayConversationToPlayer( "train_jump", level.player )
	local minWait = 2
	local startTime = Time()

	// trigger flag
	FlagWait( "PlayerPastJump" )
	while ( Time() < startTime + minWait )
		wait 0.1
	ForcePlayConversationToPlayer( "train_sprint_and_jump", level.player )
	local minWaitEnd = 3

	// trigger flag
	FlagWait( "PlayerNearMantle" )
	if ( Time() < minWaitEnd )
		wait ( minWaitEnd - Time() )

	ForcePlayConversationToPlayer( "train_mantle", level.player )
	wait 3.6

	FlagWait( "PlayerPastMantle" )

	ForcePlayConversationToPlayer( "nicelydone", level.player )
}

function MoveTraining( walkDoorsSnapOpenDist, lightTrigs )
{
	local ogPos = level.player.GetOrigin()

	DisplayTrainingPrompt( eTrainingButtonPrompts.MOVE )
	local minWaitTimeout = 2.75 + Time()
	ForcePlayConversationToPlayer( "train_move", level.player )

	level.player.ResetIdleTimer()

	waitthread NagPlayerUntilPlayerMove2D( 48, "train_move_nag" )

	level.player.ResetIdleTimer()

	if ( minWaitTimeout > Time() )
		wait ( minWaitTimeout - Time() )

	OpenSwapDoors( "door_walk_enter" )

	DisplayTrainingPrompt( eTrainingButtonPrompts.MOVEFORWARD )

	ForcePlayConversationToPlayer( "walk_through_tunnel", level.player )

	local doorsCloseTime = 8
	local teleOrg = Vector( -12285, -4106, 0 )
	local teleAng = Vector( 0, 90, 0 )

	local numResets = 0
	local sig = ""
	local lastHelpAlias = ""
	while ( 1 )
	{
		FlagClear( "PlayerPassedWalkDoors" )
		FlagClear( "DoorsImpassable" )
		OpenSwapDoors( "door_walk_enter" )

		thread NagPlayerUntilFlag( "PlayerStartWalkSection", "walk_through_tunnel_nag", 15 )

		FlagWait( "PlayerStartWalkSection" )
		DoorPair_SlideClosed( level.walkDoors, doorsCloseTime, 0, "PlayerPassedWalkDoors" )
		thread SetFlagWhenDoorsImpossibleToPass( level.walkDoors, "DoorsImpassable", "PlayerPassedWalkDoors" )

		sig = ""  // reset
		local result = WaitSignal( level.ent, "PlayerPassedWalkDoors", "DoorsImpassable" )
		sig = result.signal

		if ( sig == "PlayerPassedWalkDoors" )
			break

		numResets++

		// otherwise reset so they can try again
		thread TeleportPlayer( teleOrg, teleAng )
		wait 0.2
		CloseSwapDoors( "door_walk_enter" )
		thread DoorPair_SnapOpen( level.walkDoors, walkDoorsSnapOpenDist )
		thread LightTriggers_Reset( lightTrigs )
		foreach ( trig in lightTrigs )
			LightTrigger_Off( trig )

		level.player.WaitSignal( "Teleported" )
		FlagClear( "PlayerStartWalkSection")

		if ( numResets % 2 == 0 )
		{
			local alias
			if ( lastHelpAlias == "walk_through_tunnel_help1" )
				alias = "walk_through_tunnel_help2"
			else
				alias = "walk_through_tunnel_help1"

			lastHelpAlias = alias
			ForcePlayConversationToPlayer( alias, level.player )
		}

		wait 0.5
	}

	thread DoorPair_Freeze( level.walkDoors )

	Assert( !Flag( "SafeToCloseWalkDoors" ), "Expect to wait for this flag." )
	// close the doors behind the player
	FlagWait( "SafeToCloseWalkDoors" )
	DoorPair_SnapClosed( level.walkDoors )

	level.player.ResetIdleTimer()

	HideTrainingPrompt()
}

function SprintTraining( sprintDoorsSnapOpenDist, lightTrigs )
{
	ForcePlayConversationToPlayer( "train_sprint", level.player )
	DisplayTrainingPrompt( eTrainingButtonPrompts.SPRINT )
	wait 1.5

	local doorsCloseTime = 6.5
	local teleOrg = Vector( -12289, -3111, 0 )
	local teleAng = Vector( 0, 90, 0 )

	OnThreadEnd(
		function() : ()
		{
			if ( IsValid( level.player ) )
				StopControllerImageHint()
		}
	)

	local notSprintingNagIdx = 0
	local notSprintingNags = []
	// To make it past this set of closing doors, you must SPRINT as you move.
	notSprintingNags.append( { alias = "train_sprint_verbose", aliasWait = 3 } )
	// If the lights in the tunnel do not turn green, you are not sprinting.
	notSprintingNags.append( { alias = "train_sprint_lights_mean_sprinting", aliasWait = 4 } )
	// Pilot, you are not sprinting!
	// Please refer to the onscreen instructions to learn how to SPRINT.
	notSprintingNags.append( { alias = "train_sprint_pilot_not_sprinting", aliasWait = 6 } )

	local generalNagIdx = 0
	local generalNags = []
	// Beat the closing doors by sprinting.
	generalNags.append( { alias = "train_sprint_tryagain", aliasWait = 2 } )
	// You must SPRINT all the way through the tunnel, from start to finish.
	generalNags.append( { alias = "train_sprint_fully_through_tunnel", aliasWait = 3.5 } )
	// Start moving first, then start sprinting a moment later.
	generalNags.append( { alias = "train_sprint_help_timing", aliasWait = 3.5 } )

	local numResets = 0
	local sig = ""
	while ( 1 )
	{
		FlagClear( "PlayerPassedSprintDoors" )
		FlagClear( "PlayerNotSprintingThroughTrigger" )
		FlagClear( "DoorsImpassable" )
		OpenSwapDoors( "door_sprint_enter" )

		// To proceed, please sprint through the tunnel.
		thread NagPlayerUntilFlag( "SprintDoorsStartClosing", "train_sprint_nag", 15 )

		FlagWait( "SprintDoorsStartClosing" )
		DoorPair_SlideClosed( level.sprintDoors, doorsCloseTime, 0, "PlayerPassedSprintDoors" )
		thread SetFlagWhenDoorsImpossibleToPass( level.sprintDoors, "DoorsImpassable", "PlayerPassedSprintDoors" )

		sig = ""  // reset
		local result = WaitSignal( level.ent, "PlayerPassedSprintDoors", "PlayerNotSprintingThroughTrigger", "DoorsImpassable" )
		sig = result.signal

		if ( sig == "PlayerPassedSprintDoors" )
			break

		numResets++

		// otherwise reset so they can try again
		thread TeleportPlayer( teleOrg, teleAng )
		wait 0.1
		CloseSwapDoors( "door_sprint_enter" )
		thread DoorPair_SnapOpen( level.sprintDoors, sprintDoorsSnapOpenDist )
		thread LightTriggers_Reset( lightTrigs )
		foreach ( trig in lightTrigs )
			LightTrigger_Off( trig )

		level.player.WaitSignal( "Teleported" )
		FlagClear( "SprintDoorsStartClosing")

		if ( numResets > 2 )
			ControllerImageHint_Sprint()

		if ( sig == "PlayerNotSprintingThroughTrigger" )
		{
			local alias = notSprintingNags[ notSprintingNagIdx ].alias
			local aliasWait = notSprintingNags[ notSprintingNagIdx ].aliasWait
			ForcePlayConversationToPlayer( alias, level.player )
			wait aliasWait

			notSprintingNagIdx++
			if ( notSprintingNagIdx >= notSprintingNags.len() )
				notSprintingNagIdx = 0
		}
		else
		{
			local alias = generalNags[ generalNagIdx ].alias
			local aliasWait = generalNags[ generalNagIdx ].aliasWait
			ForcePlayConversationToPlayer( alias, level.player )
			wait aliasWait

			generalNagIdx++
			if ( generalNagIdx >= generalNags.len() )
				generalNagIdx = 0
		}
	}

	StopControllerImageHint()

	DoorPair_Freeze( level.sprintDoors )

	FlagWait( "SafeToCloseSprintDoors" )
	DoorPair_SnapClosed( level.sprintDoors )

	HideTrainingPrompt()
}


function Module_Wallrun()
{
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )

	level.ent.WaitSignal( "ModuleChangeDone" )

	thread Wallrun_TrackPlayerPos()

	thread Wallrun_BasicVO()

	FlagWait ( "PlayerEnteredWallrunArea" )
	thread WallrunTraining_ManagePrompts()

	DisplayTrainingPrompt( eTrainingButtonPrompts.WALLRUN )

	local lastEarlyJumpOffVOTime = -1
	local earlyJumpOffVODebounceTime = 30

	local numResetsToTriggerHelperVO = 4

	local gapInfo = {}
	gapInfo[ 0 ] <- { nagIdx = 0, numResets = 0, nags = null, firstNagPlayed = false, nagRightAway = true }
	gapInfo[ 1 ] <- { nagIdx = 0, numResets = 0, nags = null, firstNagPlayed = false, nagRightAway = false }
	gapInfo[ 2 ] <- { nagIdx = 0, numResets = 0, nags = null, firstNagPlayed = false, nagRightAway = false }
	gapInfo[ 3 ] <- { nagIdx = 0, numResets = 0, nags = null, firstNagPlayed = false, nagRightAway = true }

	gapInfo[ 0 ].nags = []
	gapInfo[ 0 ].nags.append( { alias = "train_wallrun_instructions", aliasTime = 4.5 } )
	//gapInfo[ 0 ].nags.append( { alias = "train_wallrun_jump1_help1", aliasTime = 2.7 } )
	//gapInfo[ 0 ].nags.append( { alias = "train_wallrun_jump1_help2", aliasTime = 3 } )
	//gapInfo[ 0 ].nags.append( { alias = "train_wallrun_instructions", aliasTime = 4.5 } )

	gapInfo[ 1 ].nags = []
	gapInfo[ 1 ].nags.append( { alias = "train_wallrun_jump2_help1", aliasTime = 5.2 } )
	gapInfo[ 1 ].nags.append( { alias = "train_wallrun_jump2_help2", aliasTime = 3.0 } )
	gapInfo[ 1 ].nags.append( { alias = "train_wallrun_jump2_help3", aliasTime = 8.5 } )
	gapInfo[ 1 ].nags.append( { alias = "train_wallrun_jump2_help4", aliasTime = 4.5 } )
	gapInfo[ 1 ].nags.append( { alias = "train_wallrun_instructions_withjump", aliasTime = 7.7 } )

	gapInfo[ 2 ].nags = []
	gapInfo[ 2 ].nags.append( { alias = "train_wallrun_jump3_help1", aliasTime = 5.0 } )
	gapInfo[ 2 ].nags.append( { alias = "train_wallrun_jump3_help2", aliasTime = 7.0 } )
	gapInfo[ 2 ].nags.append( { alias = "train_wallrun_instructions_withjump", aliasTime = 7.7 } )

	gapInfo[ 3 ].nags = []
	gapInfo[ 3 ].nags.append( { alias = "train_wallrun_mantle", aliasTime = 7 } )
	gapInfo[ 3 ].nags.append( { alias = "train_wallrun_instructions_withjump", aliasTime = 7.7 } )

	while ( 1 )
	{
		FlagClear( "ShortWallrunDetected" )

		level.player.WaitSignal( "Teleported" )
		wait 0.1  // make sure the player position refreshes

		if ( Flag( "DoingBasicWallrunVO" ) )
			continue

		local wallrunPlayerPos = level.wallrunPlayerPos
		printt( "player position is:", wallrunPlayerPos )

		local infoIdx = wallrunPlayerPos

		local wentBackwards = level.wallrunPlayerPos < level.previousWallrunPlayerPos
		if ( wentBackwards )
		{
			printt( "player went backwards" )
			gapInfo[ infoIdx ].numResets = 0  // player went backwards- set the reset counter back to zero for this spot

			// set previous to current after the teleport so the next teleport will trigger a nag
			level.previousWallrunPlayerPos = level.wallrunPlayerPos

			continue  // don't ever want to nag right away after the player is teleported backwards
		}

		if ( !( infoIdx in gapInfo ) )
		{
			printt( "no gap info set up for idx", infoIdx )
			continue
		}

		gapInfo[ infoIdx ].numResets++

		local numResets = gapInfo[ infoIdx ].numResets
		local nags = gapInfo[ infoIdx ].nags

		if ( Flag( "ShortWallrunDetected" ) && Time() - lastEarlyJumpOffVOTime >= earlyJumpOffVODebounceTime )
		{
			FlagSet( "DoingWallrunHelperVO" )
			ForcePlayConversationToPlayer( "train_wallrun_hint_jumpingOffTooEarly", level.player )
			wait 8.5
			FlagClear( "DoingWallrunHelperVO" )

			lastEarlyJumpOffVOTime = Time()
		}
		else if ( nags != null )
		{
			local nagRightAway = gapInfo[ infoIdx ].nagRightAway

			local doNag = numResets >= numResetsToTriggerHelperVO
			if ( nagRightAway && !gapInfo[ infoIdx ].firstNagPlayed )
			{
				doNag = true
				gapInfo[ infoIdx ].firstNagPlayed = true
			}

			if ( doNag )
			{
				local nagIdx = gapInfo[ infoIdx ].nagIdx
				local alias = nags[ nagIdx ].alias
				local aliasTime = nags[ nagIdx ].aliasTime

				FlagSet( "DoingWallrunHelperVO" )
				ForcePlayConversationToPlayer( alias, level.player )
				wait aliasTime
				FlagClear( "DoingWallrunHelperVO" )

				nagIdx++
				if ( nagIdx == nags.len() )
					nagIdx = 0

				gapInfo[ infoIdx ].nagIdx = nagIdx
				gapInfo[ infoIdx ].numResets = 0
			}
		}
	}

	HideTrainingPrompt()
}

function Wallrun_BasicVO()
{
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )

	waitthread Wallrun_BasicVOLine( "train_wallrun", 6 )

	FlagWait ( "PlayerEnteredWallrunArea" )

	//waitthread Wallrun_BasicVOLine( "train_wallrun_instructions", 4 )
	waitthread Wallrun_BasicVOLine( "train_wallrun_jump1_help1", 2.7 )

	FlagWait( "PlayerReachedWallrunPlatform3" )

	waitthread Wallrun_BasicVOLine( "train_wallrun_3", 7.5 )

	FlagWait( "PlayerReachedWallrunEnd" )

	waitthread Wallrun_BasicVOLine( "welldone", 2.0 )
}

function Wallrun_BasicVOLine( alias, aliasTime )
{
	FlagWaitClear( "DoingWallrunHelperVO" )

	FlagSet( "DoingBasicWallrunVO" )

	OnThreadEnd(
		function() : ()
		{
			if ( IsValid( level.player ) )
				FlagClear( "DoingBasicWallrunVO" )
		}
	)

	ForcePlayConversationToPlayer( alias, level.player )
	wait aliasTime
}

function Wallrun_TrackPlayerPos()
{
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )

	// reset to base values
	level.wallrunPlayerPos = -1
	level.previousWallrunPlayerPos = -1

	local refreshTime = 0
	local playerPos = -1

	while ( 1 )
	{
		wait refreshTime

		playerPos = -1

		foreach ( idx, trig in level.wallrunPlatformTrigs )
		{
			if ( trig.IsTouching( level.player ) )
			{
				playerPos = idx
				break
			}
		}

		if ( playerPos == -1 )
			continue

		if ( level.wallrunPlayerPos != playerPos )
		{
			level.previousWallrunPlayerPos = level.wallrunPlayerPos
			level.wallrunPlayerPos = playerPos

			//printt( "playerpos:", level.wallrunPlayerPos, "previousPos:", level.previousWallrunPlayerPos )
		}
	}
}

function WallrunTraining_ManagePrompts( endFlag = null )
{
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )

	if ( endFlag )
		level.ent.EndSignal( endFlag )

	OnThreadEnd(
		function() : ()
		{
			HideTrainingPrompt()
		}
	)

	local wallrunTooShortTime = 0.25
	local wallTimeBeforeJumpPrompt = 1.1

	local currentPrompt = null
	local wallrunStartTime = -1
	local wallrunDone = true
	while ( 1 )
	{
		wait 0

		if ( !level.player.IsWallRunning() && wallrunStartTime != -1 && !wallrunDone )
		{
			local wallrunTime = Time() - wallrunStartTime
			printt( "wallrun time:", wallrunTime )
			wallrunDone = true

			if ( wallrunTime <= wallrunTooShortTime && !Flag( "PlayerPressedJump" ) )
				printt( "no player jump input detected during very short wallrun- false positive" )

			if ( wallrunTime <= wallrunTooShortTime && Flag( "PlayerPressedJump" ) )
			{
				printt( "very short wallrun" )
				FlagSet( "ShortWallrunDetected" )
			}
		}

		// if player is near the exit room, hide the prompt
		if ( ( level.wallrunPlayerPos > 3 ) )
		{
			if ( currentPrompt != null )
			{
				currentPrompt = null
				HideTrainingPrompt()
			}
		}
		else
		{
			if ( level.player.IsOnGround() && !level.player.IsWallRunning() && currentPrompt != eTrainingButtonPrompts.WALLRUN )
			{
				FlagClear( "PlayerPressedJump" )

				wallrunStartTime = -1
				wallrunDone = false

				currentPrompt = eTrainingButtonPrompts.WALLRUN
				DisplayTrainingPrompt( currentPrompt )
			}
			else if ( level.player.IsWallRunning() )
			{
				// just started
				if ( wallrunStartTime == -1 )
				{
					wallrunStartTime = Time()
					printt( "started wallrun at", wallrunStartTime )
				}
				// now running along wall before jump off point
				else if ( Time() - wallrunStartTime < wallTimeBeforeJumpPrompt && currentPrompt != eTrainingButtonPrompts.WALLRUN_EXTEND )
				{
					currentPrompt = eTrainingButtonPrompts.WALLRUN_EXTEND
					DisplayTrainingPrompt( currentPrompt )
				}
				// time to think about jumping off
				else if ( Time() - wallrunStartTime >= wallTimeBeforeJumpPrompt && currentPrompt != eTrainingButtonPrompts.WALLRUN_DETACH )
				{
					currentPrompt = eTrainingButtonPrompts.WALLRUN_DETACH
					DisplayTrainingPrompt( currentPrompt )
				}
				// player detached from wall after jump prompt appeared
				else if ( !level.player.IsWallRunning() && Time() - wallrunStartTime >= wallTimeBeforeJumpPrompt && currentPrompt != null )
				{
					printt( "detached from wall" )
					currentPrompt = null
					HideTrainingPrompt()
				}
			}
		}
	}
}


function Module_Wallrun_Playground()
{
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )

	level.ent.WaitSignal( "ModuleChangeDone" )

	ForcePlayConversationToPlayer( "train_wallrun_playground", level.player )

	//"WallrunPlayground_BonusEval", "WallrunPlayground_HighRoad_1", "WallrunPlayground_HighRoad_2", "WallrunPlayground_HighRoad_Fail"
	// "WallrunPlayground_LowRoad_1", "WallrunPlayground_LowRoad_2"

	// bonus line eval
	local numResets = 0
	while ( 1 )
	{
		FlagClear( "WallrunPlayground_BonusEval" )
		FlagClear( "WallrunPlayground_LowRoad_1" )
		FlagClear( "WallrunPlayground_LowRoad_2" )

		local result = WaitSignal( level.ent, "WallrunPlayground_BonusEval", "TeleportedPlayer" )
		local sig = result.signal

		if ( sig == "WallrunPlayground_BonusEval" )
			break

		if ( sig == "TeleportedPlayer" )
			numResets++
	}

	// Completion requirements met.
	local alias = "requirements_met"
	if ( Flag( "WallrunPlayground_LowRoad_1" ) && Flag( "WallrunPlayground_LowRoad_2" ) )
	{
		// Only a few Pilots can wallrun in tight spaces.
		// Your exceptional navigational abilities have been noted.
		alias = "bonus_wallrun_lowroad"
	}
	else if ( numResets == 0 && Flag( "WallrunPlayground_HighRoad_1" ) && Flag( "WallrunPlayground_HighRoad_2" ) && !Flag( "WallrunPlayground_HighRoad_Fail" ) )
	{
		// Your chosen route indicates above-average navigational skills.
		// Excellent route, Pilot.
		alias = "bonus_wallrun_highroad"
	}

	ForcePlayConversationToPlayer( alias, level.player )
}

function Module_Doublejump()
{
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )
	level.ent.WaitSignal( "ModuleChangeDone" )

	wait 0.5

	ForcePlayConversationToPlayer( "train_doublejump", level.player )
	DisplayTrainingPrompt( eTrainingButtonPrompts.DOUBLEJUMP )
	wait 6.5

	FlagWait( "PlayerReachedDoublejumpPlatform2" )
	DisplayTrainingPrompt( eTrainingButtonPrompts.DOUBLEJUMP_FAR )
	local minWaitEnd = 5.2 + Time()
	ForcePlayConversationToPlayer( "train_doublejump_2", level.player )

	local nags = [ "train_doublejump_help_1", "train_doublejump_help_2", "train_doublejump_help_3" ]
	local nagIdx = 0

	local sig
	local numResets = 0
	while ( 1 )
	{
		sig = ""
		local result = WaitSignal( level.ent, "PlayerPastDoubleJump2", "TeleportedPlayer" )
		sig = result.signal
		if ( sig == "PlayerPastDoubleJump2" )
		{
			break
		}

		numResets++
		if ( numResets > 1 && numResets % 2 == 0 )
		{
			local convAlias = nags[ nagIdx ]

			ForcePlayConversationToPlayer( nags[ nagIdx ], level.player )
			minWaitEnd = 5 + Time()

			nagIdx++
			if ( nagIdx == nags.len() )
				nagIdx = 0
		}
	}

	HideTrainingPrompt()

	// if player is slamming through it, don't let VO stomp
	if ( numResets == 0 && Time() < minWaitEnd )
		wait ( minWaitEnd - Time() )

	if ( !Flag( "PlayerPassedDoubleJumpCeiling" ) )
	{
		// Double jump and mantle into the hole above to proceed.
		ForcePlayConversationToPlayer( "train_doublejump_ceiling", level.player )
	}
}

function Module_Doublejump_Playground()
{
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )

	level.player.WaitSignal( "Teleported" )

	local ogOrg = level.player.GetOrigin()
	while ( Distance( level.player.GetOrigin(), ogOrg ) <= 32 )
		wait 0

	local timeForBonusLine = 12

	printt( "timer started" )
	local startTime = Time()

	ForcePlayConversationToPlayer( "train_doublejump_playground", level.player )

	FlagWait( "DoublejumpPlayground_PlayerEval" )

	local finishTime = Time() - startTime
	printt( "finish time:", finishTime )

	// Excellent navigational skills, Pilot.
	local alias = "bonus_nav_excellent"
	if ( finishTime <= timeForBonusLine )
	{
		// You made very good time.
		// You appear quite adept at rapid environment navigation.
		alias = "bonus_doublejump_playground_fasttime"
	}

	ForcePlayConversationToPlayer( alias, level.player )
}

function Module_Cloak()
{
	level.ent.EndSignal( "ModuleChanging" )
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )

	local playerResetOrg = Vector( -3847, -4592, 0 )
	local playerResetAng = Vector( 0, 90, 0 )

	local squadIdx = 0
	thread CloakArea_SpawnSentries( squadIdx )

	level.player.WaitSignal( "Teleported" )

	OnThreadEnd(
		function() : ()
		{
			foreach ( sentry in level.cloakSentries )
			{
				if ( IsAlive( sentry ) )
				{
					ClearInvincible( sentry )
					sentry.Kill()
				}
			}
		}
	)

	CloseSwapDoors( "door_cloak_secondexit" )
	OpenSwapDoors( "door_cloak_exit" )

	level.ent.WaitSignal( "ModuleChangeDone" )

	local cloakSlot = 1
	level.player.GiveOffhandWeapon( "mp_ability_cloak", cloakSlot, [ "bc_long_cloak1" ] )

	thread Cloak_IntroVO()
	thread Cloak_ManagePrompt( 3 )

	local timesFailed = 0
	local sig = ""
	while ( 1 )
	{
		if ( timesFailed > 0 && sig != "" )
		{
			if ( sig == "Cloak_RanIntoPlayer" )
				ForcePlayConversationToPlayer( "train_cloak_ranIntoPlayer", level.player )
			else if ( timesFailed % 2 == 0 )
				ForcePlayConversationToPlayer( "train_cloak_failed", level.player )
		}

		FlagClear( "CloseCloakSwapDoors" )  // in edge cases players can be seen, then quickly run into the end trigger before being reset back to the start

		sig = ""  // reset
		local result = WaitSignal( level.ent, "Cloak_PlayerFound", "Cloak_RanIntoPlayer", "CloseCloakSwapDoors", "PlayerKilledAllSentries" )
		sig = result.signal

		if ( sig == "CloseCloakSwapDoors" || sig == "PlayerKilledAllSentries" )
		{
			// player made it clean
			break
		}
		else
		{
			// Help with fuzzy edge case of being spotted by last guy as player is melee killing him
			local stillAlive = 0
			local aliveGuy = null
			foreach ( guy in level.cloakSentries )
			{
				if ( !IsAlive( guy ) )
					continue

				stillAlive++
				if ( stillAlive > 1 )
					break

				aliveGuy = guy
			}

			// if only one is still alive, that's the edge case
			if ( stillAlive == 1 )
			{
				waitthread WaitForPlayerMeleeFinished()

				// If last guy is alive after melee, they didn't pass
				if ( !IsAlive( aliveGuy ) )
				{
					break
				}
				else
				{
					printt( "single guy still alive, health is", aliveGuy.GetHealth(), "player melee state is", level.player.PlayerMelee_GetState() )
				}
			}
		}

		// make the remaining guys invincible so a melee doesn't seem to kill them when the player really got caught
		foreach ( guy in level.cloakSentries )
		{
			if ( !IsAlive( guy ) )
				continue

			MakeInvincible( guy )
		}

		// little break to hear guys chatter, etc. Realize what happened.
		local endTime = 1.5 + Time()
		// don't wait if I start a melee
		while ( Time() < endTime && level.player.PlayerMelee_GetState() == PLAYER_MELEE_STATE_NONE )
			wait 0.1

		waitthread WaitForPlayerMeleeFinished()

		// otherwise player failed, try again
		timesFailed++
		level.ent.Signal( "CloakModuleResetting" )

		DisableCloak( level.player )

		EmitSoundOnEntity( level.player, "NPE_Player_Fail" )

		thread TeleportPlayer( playerResetOrg, playerResetAng, true, true )
		wait 0.1

		thread CleanupCorpses()

		// respawn the guys after incrementing squad index
		squadIdx++
		if ( squadIdx >= 10 )
			squadIdx = 0  // reset it eventually, jiesang says we don't want too many unique squads

		thread CloakArea_SpawnSentries( squadIdx )

		level.player.GetOffhandWeapon( cloakSlot ).SetNextAttackAllowedTime( Time() )
	}

	// eval if anyone's alive here, instead of by using the signal, because time has passed since the signal that killed the loop was sent
	local killedAllSentries = true
	foreach ( guy in level.cloakSentries )
	{
		if ( IsAlive( guy ) )
		{
			killedAllSentries = false
			break
		}
	}

	FlagSet( "PlayerPastCloakArea" )
	thread Cloak_CloseSwapDoorsWhenFinished()

	local reactAlias = "welldone"
	local reactTime = 2
	if ( killedAllSentries )
	{
		reactAlias = "train_cloak_killedSentries"
		reactTime = 6.5
	}
	local minWaitEnd = reactTime + Time()

	HideTrainingPrompt()
	ForcePlayConversationToPlayer( reactAlias, level.player )
	EmitSoundOnEntity( level.player, "NPE_Player_Succeed" )

	foreach ( sentry in level.cloakSentries )
	{
		if ( IsAlive( sentry ) )
		{
			ClearInvincible( sentry )
			sentry.Kill()
		}
	}

	level.cloakSentries = []

	if ( killedAllSentries && !Flag( "CloseCloakSwapDoors" ) )
	{
		if ( Time() < minWaitEnd )
			wait minWaitEnd - Time()

		if ( !Flag( "CloseCloakSwapDoors" ) )
		{
			ForcePlayConversationToPlayer( "train_cloak_proceedtoExit", level.player )
			minWaitEnd = 3 + Time()
		}
	}

	FlagWait( "CloseCloakSwapDoors" )

	if ( Time() < minWaitEnd )
		wait( minWaitEnd - Time() )

	// pulse the hint again since we're talking about the meter
	CloakHintPulse()

	OnThreadEnd(
		function() : ()
		{
			if ( IsValid( level.player ) )
				StopHintPulse()
		}
	)

	ForcePlayConversationToPlayer( "train_cloak_limitedtime", level.player )
	wait 6

	OpenSwapDoors( "door_cloak_secondexit" )

	// wait til module change to clean up
	level.ent.WaitSignal( "ModuleChanging" )

	level.player.TakeOffhandWeapon( cloakSlot )
	DisableCloak( level.player )
}

function Cloak_CloseSwapDoorsWhenFinished()
{
	FlagWait( "CloseCloakSwapDoors" )
	CloseSwapDoors( "door_cloak_exit" )
}

function Cloak_ManagePrompt( waitTime )
{
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )
	level.ent.EndSignal( "PlayerPastCloakArea" )

	wait waitTime
	CloakHintPulse()
	ControllerImageHint_OffhandDefensive()

	OnThreadEnd(
		function() : ()
		{
			if ( IsValid( level.player ) )
			{
				HideTrainingPrompt()
				StopHintPulse()
				StopControllerImageHint()
			}
		}
	)

	local promptShowing = false

	while ( 1 )
	{
		if ( IsCloaked( level.player ) && promptShowing )
		{
			HideTrainingPrompt()
			StopControllerImageHint()
			promptShowing = false
			break
		}
		else if ( !IsCloaked( level.player ) && !promptShowing )
		{
			DisplayTrainingPrompt( eTrainingButtonPrompts.CLOAK )
			CloakHintPulse()
			ControllerImageHint_OffhandDefensive()
			promptShowing = true
		}

		wait 0.1
	}
}

function Cloak_MoshPit_ManagePrompt( waitTime )
{
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )
	level.ent.EndSignal( "PlayerPastCloakArea" )

	wait waitTime
	CloakHintPulse()
	ControllerImageHint_OffhandDefensive()

	OnThreadEnd(
		function() : ()
		{
			if ( IsValid( level.player ) )
			{
				HideTrainingPrompt()
				StopHintPulse()
				StopControllerImageHint()
			}
		}
	)

	local promptShowing = false

	while ( 1 )
	{
		if ( IsCloaked( level.player ) && promptShowing )
		{
			HideTrainingPrompt()
			StopControllerImageHint()
			promptShowing = false
		}
		else if ( !IsCloaked( level.player ) && !promptShowing )
		{
			DisplayTrainingPrompt( eTrainingButtonPrompts.CLOAK )
			CloakHintPulse()
			ControllerImageHint_OffhandDefensive()
			promptShowing = true
		}

		if (Flag("MoshPit_GroundTroops_Done"))
		{
			local foundOne = false
			foreach ( squad in level.moshPitSquads )
			{
				if ( squad == null )
				{
					foundOne = true
					break
				}
			}

			if ( !foundOne )
				break
		}

		wait 0.1
	}
}

function Cloak_IntroVO()
{
	level.ent.EndSignal( "ModuleChanging" )
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )

	ForcePlayConversationToPlayer( "train_cloak", level.player )
	wait 5.5

	ForcePlayConversationToPlayer( "train_cloak_pt2", level.player )
}

// if we teleport players during a synced melee it won't work
function WaitForPlayerMeleeFinished()
{
	local player = level.player
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "Disconnected" )
	player.EndSignal( "OnDeath" )

	local meleeState = player.PlayerMelee_GetState()

	if ( meleeState == PLAYER_MELEE_STATE_NONE )
		return

	Remote.CallFunction_Replay( level.player, "ServerCallback_SetFreezePlayerControls", true )

	OnThreadEnd(
		function() : ()
		{
			if ( IsValid( level.player ) )
				Remote.CallFunction_Replay( level.player, "ServerCallback_SetFreezePlayerControls", false )
		}
	)

	while ( meleeState != PLAYER_MELEE_STATE_NONE )
	{
		wait 0
		meleeState = player.PlayerMelee_GetState()
	}
}

function CloakArea_SpawnSentries( squadIdx )
{
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )
	level.ent.EndSignal( "CloakModuleResetting" )

	level.ent.EndSignal( "Cloak_PlayerFound" )
	level.ent.EndSignal( "Cloak_RanIntoPlayer" )
	level.ent.EndSignal( "PlayerPastCloakArea" )

	if ( !( "cloakSentries" in level ) )
	{
		level.cloakSentries <- []
	}
	else
	{
		foreach ( guy in level.cloakSentries )
		{
			if ( IsValid( guy ) )
			{
				ClearInvincible( guy )
				guy.Kill()
			}

			level.cloakSentries = []
		}
	}

	local spawns = []
	spawns.append( { origin = Vector( -3550, -3368, 208 ), angles = Vector( 0, -90, 0 ), anim = "pt_bored_stand_talker_A" } )
	spawns.append( { origin = Vector( -3840, -3360, 208 ), angles = Vector( 0, -90, 0 ), anim = "CQB_Idle_Casual" } )
	spawns.append( { origin = Vector( -4156, -3368, 208 ), angles = Vector( 0, -90, 0 ), anim = "pt_bored_stand_talker_B" } )

	foreach ( spawn in spawns )
	{
		local squadName = "cloak_squad_" + squadIdx  // dudes need a new squad name because AIs being put into a squad will inherit that squad's enemy (for a certain amount of time anyway)
		local sentry = SpawnDumbNPC( "grunt", spawn.origin, spawn.angles, false, squadName )
		sentry.StayPut( true )
		sentry.SetEfficientMode( false )
		sentry.Minimap_AlwaysShow( level.player.GetTeam(), level.player )
		sentry.AllowHandSignals( false )

		sentry.SetAISettings( "training_sentry_soldier" )  // custom AI settings so they have slightly wider vertical field of view

		thread PlayAnimGravity( sentry, spawn.anim, sentry )

		level.cloakSentries.append( sentry )

		thread CloakArea_SentryThink( sentry )
	}

	while( 1 )
	{
		local foundOne = false

		foreach ( sentry in level.cloakSentries )
		{
			if ( IsAlive( sentry ) )
			{
				foundOne = true
				break
			}
		}

		if ( !foundOne )
			break

		wait 0.1
	}

	level.ent.Signal( "PlayerKilledAllSentries" )
}

function CloakArea_SentryThink( sentry )
{
	sentry.EndSignal( "OnDeath" )
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )
	level.ent.EndSignal( "CloakModuleResetting" )

	level.ent.EndSignal( "Cloak_RanIntoPlayer" )
	level.ent.EndSignal( "PlayerPastCloakArea" )

	sentry.WaitSignal( "OnSeeEnemy" )

	// if he's in the middle of a death anim let him keep doing it
	if ( IsAlive( sentry ) )
		sentry.Anim_Stop()

	local ranIntoPlayer = false
	if ( Distance( level.player.GetOrigin(), sentry.GetOrigin() ) <= 72 )
	{
		ranIntoPlayer = true
		//printt( "Sentry ran into player!" )
		level.ent.Signal( "Cloak_RanIntoPlayer" )
	}
	else
	{
		//printt( "Sentry found player!", sentry )
		level.ent.Signal( "Cloak_PlayerFound" )
	}
}

function Module_BasicCombat()
{
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )
	level.player.WaitSignal( "Teleported" )

	OnThreadEnd(
		function() : ()
		{
			if ( IsValid( level.player ) )
				Remote.CallFunction_NonReplay( level.player, "ServerCallback_SetMeleePromptEnabled", true )
		}
	)

	// setup guys we're going to use
	if ( !( "meleeGuy" in level ) )
	{
		level.meleeGuy <- null
	}
	else
	{
		if ( IsValid( level.meleeGuy ) )
			level.meleeGuy.Kill()

		level.meleeGuy = null
	}

	CloseSwapDoors( "door_melee_enter" )
	CloseSwapDoors( "door_melee_exit" )
	CloseSwapDoors( "door_smartpistol_enter" )
	CloseSwapDoors( "door_smartpistol_exit" )
	CloseSwapDoors( "door_smartpistolpilots_enter" )
	CloseSwapDoors( "door_smartpistolpilots_exit" )

	level.ent.WaitSignal( "ModuleChangeDone" )

	waitthread TrainMelee()

	waitthread TrainWeaponSwitch()

	Remote.CallFunction_NonReplay( level.player, "ServerCallback_SetMeleePromptEnabled", false )
	wait 1
	OpenSwapDoors( "door_melee_exit" )

	waitthread TrainSmartPistol_Grunt()

	/* TEMP FOR TESTING
	OpenSwapDoors( "door_melee_enter" )
	OpenSwapDoors( "door_melee_exit" )
	OpenSwapDoors( "door_smartpistol_enter" )
	OpenSwapDoors( "door_smartpistol_exit" )
	TakeAllWeapons( level.player )
	level.player.GiveWeapon( PILOT_WEAPON_2 )
	local weapon = WaitForPlayerActiveWeapon()
	level.player.SetActiveWeaponPrimaryAmmoTotal( 48 )
	delaythread( 1 ) RefillPlayerAmmo( level.player )
	// before multitarget: Vector( -754, -3093, 390 )
	// before multilock: Vector( -764.937, -1741.57, 4.68284 )
	thread TeleportPlayer( Vector( -764.937, -1741.57, 4.68284 ), Vector( 0, 90, 0 ) )
	*/ //END TEMP

	waitthread TrainSmartPistol_MultiTarget()

	waitthread TrainSmartPistol_MultiLock()

	ForcePlayConversationToPlayer( "train_smart_pistol_multilock_done", level.player )
	wait 2

	OpenSwapDoors( "door_smartpistolpilots_exit" )
}

function TrainMelee()
{
	OnThreadEnd(
		function() : ()
		{
			if ( IsValid( level.player ) )
				StopControllerImageHint()
		}
	)

	TakeAllWeapons( level.player )
	level.player.GiveWeapon( PILOT_WEAPON_1 )
	WaitForPlayerActiveWeapon()
	level.player.SetActiveWeaponPrimaryAmmoTotal( 0 )
	level.player.SetActiveWeaponPrimaryAmmoLoaded( 0 )

	local spawnOrg = Vector( -765.9, -3777.02, 384 )
	local spawnAng = Vector( 0, 90, 0 )
	level.meleeGuy = SpawnDumbNPC( "grunt", spawnOrg, spawnAng )
	level.meleeGuy.SetModel( TEAM_MILITIA_ROCKET_GRUNT_MDL )  // guy with a face mask = less brutal feeling necksnap

	ForcePlayConversationToPlayer( "train_melee", level.player )
	wait 5.5
	OpenSwapDoors( "door_melee_enter" )
	DisplayTrainingPrompt( eTrainingButtonPrompts.MELEE )
	ForcePlayConversationToPlayer( "train_melee_nag", level.player )

	ControllerImageHint_Melee()

	waitthread NagPlayerUntilGuysAreDead( [ level.meleeGuy ], "train_melee_nag" )
	CloseSwapDoors( "door_melee_enter" )
	wait 0.5

	StopControllerImageHint()

	HideTrainingPrompt()
	ForcePlayConversationToPlayer( "train_melee_behind_is_safer", level.player )
	wait 9.5
}

function TrainWeaponSwitch()
{
	// WEAPON SWITCH AND RELOAD
	TakeAllWeapons( level.player )

	ForcePlayConversationToPlayer( "train_pull_weapon", level.player )
	DisplayTrainingPrompt( eTrainingButtonPrompts.WEAPONSWITCH )

	local minWaitEnd = 3 + Time()
	FlagClear( "PlayerPressedWeaponSwitchButton" )
	waitthread NagPlayerUntilFlag( "PlayerPressedWeaponSwitchButton", "train_pull_weapon" )
	HideTrainingPrompt()

	level.player.GiveWeapon( PILOT_WEAPON_2 )
	local weapon = WaitForPlayerActiveWeapon()
	SmartAmmo_Stop( weapon )
	level.player.SetActiveWeaponPrimaryAmmoLoaded( 0 )
	level.player.SetActiveWeaponPrimaryAmmoTotal( 0 )

	FlagClear( "PlayerReloaded" )
	thread GiveAmmoOnFlag( "PlayerReloaded" )

	wait 0.9 // let pro players reload before prompting
	if ( !Flag( "PlayerReloaded" ) )
	{
		waitthread WaittillTime( minWaitEnd )

		minWaitEnd = 3 + Time()
		ForcePlayConversationToPlayer( "train_reload", level.player )
		DisplayTrainingPrompt( eTrainingButtonPrompts.RELOAD )

		waitthread NagPlayerUntilFlag( "PlayerReloaded", "train_reload" )
		HideTrainingPrompt()
	}

	thread RefillPlayerAmmo( level.player )

	waitthread WaittillTime( minWaitEnd )
}

function GiveAmmoOnFlag( flag )
{
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )

	FlagWait( flag )
	level.player.SetActiveWeaponPrimaryAmmoTotal( 48 )
}

function TrainSmartPistol_Grunt()
{
	local weapon = WaitForPlayerActiveWeapon()
	SmartAmmo_Stop( weapon )

	waitthread SpawnSmartPistolGrunt()

	// don't target this guy with smart ammo until we say so
	level.smartPistolGuy.SetNoTarget( true )
	level.smartPistolGuy.SetNoTargetSmartAmmo( true )

	ForcePlayConversationToPlayer( "train_smart_pistol", level.player )
	wait 4
	ForcePlayConversationToPlayer( "train_smart_pistol_2", level.player )
	wait 8.5
	ForcePlayConversationToPlayer( "train_smart_pistol_reminder", level.player )
	wait 2
	DisplayTrainingPrompt( eTrainingButtonPrompts.FIREPRIMARY )

	local teleOrg = Vector( -768, -3479, 390 )
	local teleAng = Vector( 0, 90, 0 )

	while ( 1 )
	{
		thread MultiLock_DetectPlayerResult( weapon, level.smartPistolGuy, 1 )
		thread MultiLock_DetectTargetWasMeleed( level.smartPistolGuy )

		OpenSwapDoors( "door_smartpistol_enter" )
		level.smartPistolGuy.SetNoTarget( false )
		level.smartPistolGuy.SetNoTargetSmartAmmo( false )
		wait 0.35
		SmartAmmo_Start( weapon )

		FlagClear( "PlayerPassedMultiLock" )
		FlagClear( "PlayerFailedMultiLock" )
		FlagClear( "MultiLock_TargetWasMeleed" )

		local sig = ""
		local result = WaitSignal( level.ent, "PlayerPassedMultiLock", "PlayerFailedMultiLock", "MultiLock_TargetWasMeleed" )
		sig = result.signal

		if ( Flag( "PlayerPassedMultiLock" ) )
			break

		CloseSwapDoors( "door_smartpistol_enter" )

		waitthread WaitForPlayerMeleeFinished()
		SmartAmmo_Stop( weapon )

		thread TeleportPlayer( teleOrg, teleAng, true, true )
		wait 0.1

		CleanupCorpses()

		// do this manually here before threading the spawn, it takes longer on cloud servers to spawn the guy sometimes
		if ( IsAlive( level.smartPistolGuy ) )
			level.smartPistolGuy.Kill()

		thread SpawnSmartPistolGrunt()

		local minWaitEnd = 0.2 + Time()
		while ( !IsAlive( level.smartPistolGuy ) )
			wait 0

		if ( Time() < minWaitEnd )
			wait minWaitEnd - Time()

		local nagAlias = "train_smart_pistol_multilock_reminder_2"
		local lineWait = 4
		if ( Flag( "MultiLock_TargetWasMeleed" ) )
		{
			nagAlias = "train_smart_pistol_reminder"
			lineWait = 2
		}

		ForcePlayConversationToPlayer( nagAlias, level.player )
		wait lineWait
	}

	HideTrainingPrompt()
	ForcePlayConversationToPlayer( "train_smart_pistol_done", level.player )
	wait 2.5
}

function SpawnSmartPistolGrunt()
{
	if ( !( "smartPistolGuy" in level ) )
	{
		level.smartPistolGuy <- null
	}
	else
	{
		if ( IsValid( level.smartPistolGuy ) )
			level.smartPistolGuy.Kill()

		level.smartPistolGuy = null
	}

	local spawnOrg = Vector( -765.9, -3105.02, 384 )
	local spawnAng = Vector( 0, 90, 0 )
	level.smartPistolGuy = SpawnDumbNPC( "grunt", spawnOrg, spawnAng )
	level.smartPistolGuy.StayPut( true )
}

function TrainSmartPistol_MultiTarget()
{
	ForcePlayConversationToPlayer( "train_smart_pistol_multitarget", level.player )
	wait 3

	local swapDoors = "door_smartpistol_exit"

	local teleOrg = Vector( -766, -3065, 400 )
	local teleAng = Vector( 0, 90, 0 )

	local numResets = 0
	while ( 1 )
	{
		waitthread Spawn_SmartPistolMultiTargets()

		OpenSwapDoors( swapDoors )

		// trigger flag wait
		FlagWait( "PlayerNearMultikillSpot" )

		CloseSwapDoors( "door_melee_exit" )
		CloseSwapDoors( "door_smartpistol_enter" )

		if ( numResets == 0 )
			ForcePlayConversationToPlayer( "train_smart_pistol_multitarget_nag", level.player )

		FlagClear( "NotKilledUsingSmartPistol" )

		thread MultiTarget_DetectPlayerResult()

		local sig = ""
		local result = WaitSignal( level.ent, "SmartPistolMultiTargetsDead", "PlayerFailedMultiTarget", "NotKilledUsingSmartPistol" )
		sig = result.signal

		if ( sig == "SmartPistolMultiTargetsDead" )
			break

		numResets++

		waitthread WaitForPlayerMeleeFinished()

		thread TeleportPlayer( teleOrg, teleAng, true, true )
		CloseSwapDoors( swapDoors )

		level.player.WaitSignal( "Teleported" )

		if  ( Flag( "NotKilledUsingSmartPistol" ) )
		{
			ForcePlayConversationToPlayer( "train_smart_pistol_reminder", level.player )
			wait 2.25
		}
		else if ( ( numResets == 1 || ( numResets > 2 && numResets % 2 == 0 ) ) )
		{
			local alias = "train_smart_pistol_multitarget_nag"
			local waittime = 3

			if ( Flag( "PlayerFailedMultiTarget" ) )
			{
				alias = "train_smart_pistol_multitarget_2"
				waittime = 3
			}

			ForcePlayConversationToPlayer( alias, level.player )
			wait waittime
		}
		else
		{
			wait 1
		}

		FlagClear( "PlayerNearMultikillSpot" )
		FlagClear( "PlayerFailedMultiTarget" )
	}

	HideTrainingPrompt()

	ForcePlayConversationToPlayer( "train_smart_pistol_multitarget_done", level.player )
	wait 2.5
}

function Spawn_SmartPistolMultiTargets()
{
	if ( !( "smartPistolMultiGuys" in level ) )
	{
		level.smartPistolMultiGuys <- []
	}
	else
	{
		foreach ( guy in level.smartPistolMultiGuys )
			if ( IsValid( guy ) )
				guy.Kill()

		level.smartPistolMultiGuys = []
	}

	local spawns = []
	spawns.append( { origin = Vector( -766, -2180, 0 ), angles = Vector( 0, 90, 0 ) } )  // closest
	spawns.append( { origin = Vector( -896, -2040, 0 ), angles = Vector( 0, 90, 0 ) } )  // leftmost
	spawns.append( { origin = Vector( -640, -2040, 0 ), angles = Vector( 0, 90, 0 ) } )  // rightmost
	spawns.append( { origin = Vector( -768, -1912, 0 ), angles = Vector( 0, 90, 0 ) } )  // farthest

	foreach ( spot in spawns )
		level.smartPistolMultiGuys.append( SpawnDumbNPC( "grunt", spot.origin, spot.angles ) )
}

function MultiTarget_DetectPlayerResult()
{
	level.ent.Signal( "DetectPlayerFailedMultiTarget_Stop")
	level.ent.EndSignal( "DetectPlayerFailedMultiTarget_Stop" )
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )

	Assert( level.smartPistolMultiGuys.len() == 4 )

	local weapon = level.player.GetActiveWeapon()
	Assert( weapon )

	local lockedAllTargets = false

	local numDead
	while ( 1 )
	{
		level.player.WaitSignal( "OnPrimaryAttack" )

		local targs = weapon.SmartAmmo_GetTargets()
		if ( targs.len() == level.smartPistolMultiGuys.len() )
			lockedAllTargets = true

		numDead = 0
		foreach ( guy in level.smartPistolMultiGuys )
		{
			if ( !IsAlive( guy ) )
			{
				numDead++
			}
		}

		if ( numDead > 0 )
			break
	}

	// time for the pistol to fire four shots
	wait 1.0

	// re-evaluate
	numDead = 0
	foreach ( guy in level.smartPistolMultiGuys )
	{
		if ( !IsAlive( guy ) )
			numDead++
	}

	if ( numDead < 4 || !lockedAllTargets )
	{
		//printt( "Multitarget failed")
		FlagSet( "PlayerFailedMultiTarget" )
	}
	else
	{
		//printt( "Multitarget success")
		FlagSet( "SmartPistolMultiTargetsDead" )
	}
}

function TrainSmartPistol_MultiLock()
{
	local swapDoors = "door_smartpistolpilots_enter"

	local teleOrg = Vector( -766, -1742, 0 )
	local teleAng = Vector( 0, 90, 0 )

	local t = {}
	t.weapon <- null

	OnThreadEnd(
		function() : ( t )
		{
			if ( ( "multilockTargetGuy" in level ) && IsAlive( level.multilockTargetGuy ) )
			{
				printt( "level.multilockTargetGuy is still alive, killing him" )
				level.multilockTargetGuy.Kill()
			}

			if ( IsValid( t.weapon ) )
				thread TrainSmartPistol_MultiLock_Cleanup( t.weapon )
		}
	)

	// trigger flag wait
	FlagWait( "PlayerNearMultiLockSpot" )

	waitthread SmartPistol_SpawnMultiLockTarget()

	// Time can pass after a waitthread
	if ( !( "multilockTargetGuy" in level ) )
		return

	if ( !IsAlive( level.multilockTargetGuy ) )
		return

	level.multilockTargetGuy.SetNoTarget( true )
	level.multilockTargetGuy.SetNoTargetSmartAmmo( true )

	CloseSwapDoors( "door_smartpistol_exit" )

	local weapon = WaitForPlayerActiveWeapon()
	weapon.SetMods( [ "grunts_emulate_pilot_multilock" ] )
	SmartAmmo_Stop( weapon )
	weapon.EndSignal( "OnDestroy" )
	t.weapon = weapon

	local numResets = 0
	while ( 1 )
	{
		FlagClear( "PlayerPassedMultiLock" )
		FlagClear( "PlayerFailedMultiLock" )
		FlagClear( "MultiLock_TargetWasMeleed" )

		if ( numResets == 0 )
		{
			ForcePlayConversationToPlayer( "train_smart_pistol_multilock", level.player )
			wait 6
			ForcePlayConversationToPlayer( "train_smart_pistol_multilock_nag", level.player )
		}

		OpenSwapDoors( swapDoors )

		// defensive fix against phone_home errors
		if ( !IsAlive( level.multilockTargetGuy ) )
			return

		level.multilockTargetGuy.SetNoTarget( false )
		level.multilockTargetGuy.SetNoTargetSmartAmmo( false )
		wait 0.35
		SmartAmmo_Start( weapon )

		// defensive fix against phone_home errors
		if ( !IsAlive( level.multilockTargetGuy ) )
			return

		thread MultiLock_DetectPlayerResult( weapon, level.multilockTargetGuy, 3 )
		thread MultiLock_DetectTargetWasMeleed( level.multilockTargetGuy )

		local sig = ""
		local result = WaitSignal( level.ent, "PlayerPassedMultiLock", "PlayerFailedMultiLock", "MultiLock_TargetWasMeleed" )
		sig = result.signal

		if ( Flag( "PlayerPassedMultiLock" ) )
			break

		numResets++

		waitthread WaitForPlayerMeleeFinished()
		SmartAmmo_Stop( weapon )

		thread TeleportPlayer( teleOrg, teleAng, true, true )
		wait 0.2

		CloseSwapDoors( swapDoors )
		CleanupCorpses()
		waitthread SmartPistol_SpawnMultiLockTarget()

		// Wait for the weapon to finish the lockon process before pulling the trigger.
		//"train_smart_pistol_multilock_reminder_2"

		// Kill the Pilot with one trigger pull by waiting for multiple locks.
		local alias = "train_smart_pistol_multilock_reminder_1"
		local waitTime = 3.5
		if ( sig == "MultiLock_TargetWasMeleed" )
		{
			alias = "train_smart_pistol_reminder"
			waitTime = 2.5
		}

		ForcePlayConversationToPlayer( alias, level.player )
		wait waitTime
	}
}

function TrainSmartPistol_MultiLock_Cleanup( weapon )
{
	weapon.EndSignal( "OnDestroy" )

	// don't take the mod until the multilock burstfire is done
	while ( weapon.IsBurstFireInProgress() )
		wait 0

	weapon.SetMods( [] )
}

function SmartPistol_SpawnMultiLockTarget()
{
	if ( !( "multilockTargetGuy" in level ) )
	{
		level.multilockTargetGuy <- null
	}
	else
	{
		if ( IsAlive( level.multilockTargetGuy ) )
			level.multilockTargetGuy.Kill()

		level.multilockTargetGuy = null
	}

	local spawnOrg = Vector( -766, -1402, 0 )
	local spawnAng = Vector( 0, 90, 0 )

	if ( !( "multiLockAssaultPoint" in level ) )
		level.multiLockAssaultPoint <- CreateStrictAssaultEnt( spawnOrg, spawnAng, 64 )

	level.multilockTargetGuy = SpawnDumbNPC( "grunt", spawnOrg, spawnAng )
	level.multilockTargetGuy.SetModel( TEAM_MILITIA_GRUNT_MDL )
	level.multilockTargetGuy.StayPut( true )
	level.multilockTargetGuy.AssaultPointEnt( level.multiLockAssaultPoint )
	level.multilockTargetGuy.SetTitle( "#NPC_SIMULATED_PILOT" )
	level.multilockTargetGuy.SetShortTitle( "#NPC_SIMULATED_PILOT" )
	// TODO uncomment after StevenW looks at multilock firing bug
	//level.multilockTargetGuy.SetHealth( 300 )
	//level.multilockTargetGuy.SetMaxHealth( 300 )
}

function MultiLock_DetectTargetWasMeleed( target )
{
	level.ent.Signal( "DetectTargetWasMeleed_Stop")
	level.ent.EndSignal( "DetectTargetWasMeleed_Stop" )
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )

	Assert( IsAlive( target ) )

	target.WaitSignal( "OnDeath" )
	wait 0.1  // let the other result detect thread do its thing first

	if ( Flag( "PlayerPassedMultiLock" ) || Flag( "PlayerFailedMultiLock" ) )
		return

	FlagSet( "MultiLock_TargetWasMeleed" )
}

function MultiLock_DetectPlayerResult( weapon, target, numReqLocks )
{
	level.ent.Signal( "DetectPlayerFailedMultiTarget_Stop")
	level.ent.EndSignal( "DetectPlayerFailedMultiTarget_Stop" )
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )
	target.EndSignal( "OnDestroy" )
	weapon.EndSignal( "OnDestroy" )

	Assert( IsAlive( target ) )

	local ogHealth = target.GetHealth()
	local numDead

	level.lastSmartPistolTargs = []

	local t = {}
	t.success <- false

	OnThreadEnd(
		function() : ( t, target )
		{
			local setFlag = "PlayerFailedMultiLock"
			if ( t.success || !IsValid( target ) )  // defensive- always pass if target is invalid by now
				setFlag = "PlayerPassedMultiLock"

			//printt( "setting flag:", setFlag )
			FlagSet( setFlag )
		}
	)

	while ( 1 )
	{
		level.player.WaitSignal( "OnPrimaryAttack" )

		// make sure player hit the guy before checking smart ammo status
		if ( target.GetHealth() < ogHealth )
		{
			local targs

			// for more than one lock required, we can get targets here because OnPrimaryAttack happens after first shot
			if ( numReqLocks > 1 )
				targs = weapon.SmartAmmo_GetTargets()
			// otherwise we use the array that the death callback populates, because server tick rate is slow, and the weapon clears its targets before we get here
			else
				targs = level.lastSmartPistolTargs

			if ( !targs || !targs.len() )
			{
				//printt( "FAILED - no smart ammo targets" )
				break
			}
			else
			{
				foreach ( targ in targs )
				{
					if ( targ.entity == target && targ.fraction >= numReqLocks )
					{
						t.success = true
						break
					}
				}

				if ( t.success )
					break
			}
		}
	}
}


function Module_FiringRange()
{
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )

	if ( !( "firingRangeTargets" in level ) )
	{
		level.firingRangeTargets <- []
	}
	else
	{
		foreach ( targ in level.firingRangeTargets )
			if ( IsValid( targ ) )
				targ.Kill()

		level.firingRangeTargets = []
	}

	level.ent.WaitSignal( "ModuleChangeDone" )

	ForcePlayConversationToPlayer( "train_firingrange_rifleswap", level.player )
	DisplayTrainingPrompt( eTrainingButtonPrompts.WEAPONSWITCH )
	thread NagPlayerUntilFlag( "FiringRangeWeaponSwapped", "train_firingrange_rifleswap_nag" )

	level.player.GiveWeapon( PILOT_WEAPON_3 )

	local weapon

	while ( 1 )
	{
		weapon = WaitForPlayerActiveWeapon()
		if ( weapon.GetClassname() == PILOT_WEAPON_3 )
		{
			FlagSet( "FiringRangeWeaponSwapped" )
			break
		}

		wait 0.5
	}

	thread FiringRange_ReloadChecker( weapon )

	HideTrainingPrompt()

	thread RefillPlayerAmmo( level.player, weapon.GetClassname() )

	thread FlagSetWhenPlayerADS( "PlayerADSed" )
	wait 2

	if ( !Flag( "PlayerADSed" ) )
	{
		DisplayTrainingPrompt( eTrainingButtonPrompts.ADS )

		ForcePlayConversationToPlayer( "train_ads", level.player )
		wait 5

		waitthread NagPlayerUntilFlag( "PlayerADSed", "train_ads_nag", 15 )
		HideTrainingPrompt()
	}

	FlagClear( "NonHeadshot" )

	FiringRange_SpawnMarvins()

	DisplayTrainingPrompt( eTrainingButtonPrompts.FIREPRIMARY )
	thread FiringRange_HidePromptWhenMarvinDies()

	ForcePlayConversationToPlayer( "train_firingrange_killtargets", level.player )
	waitthread NagPlayerUntilGuysAreDead( level.firingRangeTargets, "train_firingrange_killtargets", 30 )

	// Targets neutralized.
	local alias = "train_smart_pistol_multitarget_done"
	local aliasTime = 2.5
	/* Marvins don't have normal headshot detection (no HITGROUP_HEAD maybe?)
	if ( !Flag( "NonHeadshot" ) )
	{
		// All headshots. You appear quite ready for ranged combat.
		alias = "bonus_firingrange_headshots"
		aliasTime = 5.2
	}
	else */
	if ( !Flag( "PlayerReloaded" ) )
	{
		// All targets eliminated without a magazine swap. Your ammunition conservation has been noted.
		alias = "bonus_firingrange_noreload"
		aliasTime = 5.5
	}

	ForcePlayConversationToPlayer( alias, level.player )
	wait aliasTime

	AdvanceToNextTrainingModule()
}

function FiringRange_HidePromptWhenMarvinDies()
{
	level.ent.EndSignal( "ModuleChanging" )
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )

	while ( 1 )
	{
		wait 0.2

		local foundOne = false
		foreach ( target in level.firingRangeTargets )
		{
			if ( !IsAlive( target ) )
			{
				foundOne = true
				break
			}
		}

		if ( foundOne )
			break
	}

	HideTrainingPrompt()
}

function FiringRange_ReloadChecker( weapon )
{
	level.ent.EndSignal( "ModuleChanging" )
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )

	local weaponName = weapon.GetClassname()
	local lastAmmo = level.player.GetActiveWeaponPrimaryAmmoLoaded()

	local newWeapon
	local newAmmo
	while ( 1 )
	{
		newWeapon = WaitForPlayerActiveWeapon()
		if ( newWeapon.GetClassname() != weaponName )
			return

		newAmmo = level.player.GetActiveWeaponPrimaryAmmoLoaded()
		if ( newAmmo > lastAmmo )
			break

		lastAmmo = newAmmo
	}

	FlagSet( "PlayerReloaded" )
}

function FiringRange_SpawnMarvins()
{
	local spots = []
	spots.append( { origin = Vector( 1478, -2130, 0 ), angles = Vector( 0, 130, 0 ) } )
	spots.append( { origin = Vector( 1624, -2095, 0 ), angles = Vector( 0, 25, 0 ) } )
	spots.append( { origin = Vector( 1460, -1849, 0 ), angles = Vector( 0, 165, 0 ) } )
	spots.append( { origin = Vector( 1616, -1732, 0 ), angles = Vector( 0, -35, 0 ) } )
	spots.append( { origin = Vector( 1441, -1411, 0 ), angles = Vector( 0, 140, 0 ) } )
	spots.append( { origin = Vector( 1586, -1320, 0 ), angles = Vector( 0, 45, 0 ) } )

	foreach ( spot in spots )
	{
		local marvin = FiringRange_SpawnMarvin( spot.origin, spot.angles )
		level.firingRangeTargets.append( marvin )
	}
}

function FlagSetWhenPlayerADS( setFlag )
{
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )

	while ( level.player.GetZoomFrac() < 0.9 )
		wait 0.1

	FlagSet( setFlag )
}

function FiringRange_SpawnMarvin( org, ang )
{
	local marvin = CreateEntity( "npc_marvin" )
	marvin.SetOrigin( org )
	marvin.SetAngles( ang )
	marvin.kv.health = -1
	marvin.kv.max_health = -1
	marvin.kv.spawnflags = 516  // Fall to ground, Fade Corpse
	marvin.kv.additionalequipment = "Nothing"
	marvin.SetModel( MARVIN_MODEL )

	DispatchSpawn( marvin, true )

	marvin.SetTeam( TEAM_UNASSIGNED )
	marvin.SetAimAssistAllowed( true )
	marvin.SetMoveSpeedScale( 0.6 )

	TakeAllJobs( marvin )

	thread MarvinMeandersAround( marvin )

	return marvin
}

function MarvinMeandersAround( marvin )
{
	marvin.EndSignal( "OnDeath" )

	local ogPos = marvin.GetOrigin()
	local ogX = ogPos.x
	local ogY = ogPos.y
	local ogZ = ogPos.z

	local randRange = 100
	local moveWaitMin = 2
	local moveWaitMax = 4

	local numLoops = 0
	while ( 1 )
	{
		local newX
		local newY

		newX = RandomIntRange( ogX - randRange, ogX + randRange )
		newY = RandomIntRange( ogY - randRange, ogY + randRange )

		local newPos = Vector( newX, newY, ogZ )

		local startWait = Time()
		waitthread GotoOrigin( marvin, newPos )

		// if they didn't move far let them loop again sooner
		if ( Time() - startWait >= 1.0 )
			wait ( RandomFloat( moveWaitMin, moveWaitMax ) )
		else if ( Time() - startWait < 0.1 )
			wait 0.1

		numLoops++
	}
}

function Module_FiringRange_Grenades()
{
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )

	level.player.WaitSignal( "Teleported" )

	ResetGrenadeTriggers()

	level.ent.WaitSignal( "ModuleChangeDone" )

	AddSpawnCallback( "npc_grenade_frag", FragCanTouchTriggers )

	level.player.GiveOffhandWeapon( PILOT_WEAPON_OFFHAND_OFFENSIVE, GRENADE_SLOT )
	local grenadeWeapon = level.player.GetOffhandWeapon( GRENADE_SLOT )
	level.grenadesThrown = 0
	thread RefillOffhandAmmoUntilSignal( grenadeWeapon, "GrenadeThrowingDone", 1.0 )

	ForcePlayConversationToPlayer( "train_firingrange_grenades", level.player )
	DisplayTrainingPrompt( eTrainingButtonPrompts.FIREGRENADE )
	ControllerImageHint_OffhandOffensive()
	OffhandOffensiveHintPulse()
	thread NagPlayerUntilFlag( "PlayerThrewGrenade", "train_firingrange_grenades", 15 )

	while ( 1 )
	{
		local foundOne = false
		foreach ( trig in level.grenadeTrigs )
		{
			// stop the nagging after one grenade is thrown
			if ( !Flag( "PlayerThrewGrenade" ) && trig.s.wasTriggered )
			{
				StopControllerImageHint()
				FlagSet( "PlayerThrewGrenade" )
			}

			if ( !trig.s.wasTriggered )
			{
				foundOne = true
				break
			}
		}

		if ( !foundOne )
			break

		wait 0
	}

	FlagSet( "GrenadeThrowingDone" )

	StopHintPulse()
	HideTrainingPrompt()

	local alias = "welldone"
	local aliasTime = 3.5
	if ( level.grenadesThrown < 5 )
	{
		// Four out of four. Nicely done.
		alias = "bonus_firingrange_no_grenade_misses"
		aliasTime = 4
	}

	ForcePlayConversationToPlayer( alias, level.player )
	wait aliasTime

	// Four out of four. Nicely done.
	//convRef = AddConversation( "bonus_firingrange_no_grenade_misses", TEAM_IMC )

	level.player.TakeOffhandWeapon( GRENADE_SLOT )

	AdvanceToNextTrainingModule()
}

function FragCanTouchTriggers( frag )
{
	frag.SetTouchTriggers( true )
}


function Module_MoshPit()
{
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )
	level.ent.WaitSignal( "ModuleChangeDone" )


	// ozyoon changed 4 - weapon switch and reload
	TakeAllWeapons( level.player )

	FlagClear("PlayerPressedPrimaryWeapon");

	ForcePlayConversationToPlayer( "train_pull_weapon", level.player )
	DisplayTrainingPrompt( eTrainingButtonPrompts.WEAPONSWITCH )

	FlagWait("PlayerPressedPrimaryWeapon");

	local weapon = level.player.GiveWeapon(PILOT_WEAPON_3)

	WaitForPlayerActiveWeapon(PILOT_WEAPON_3)

	local minWaitEnd = 3 + Time()
	HideTrainingPrompt()

	SmartAmmo_Stop( weapon )
	level.player.SetActiveWeaponPrimaryAmmoLoaded( 0 )
	level.player.SetActiveWeaponPrimaryAmmoTotal( 0 )

	FlagClear( "PlayerReloaded" )
	thread GiveAmmoOnFlag( "PlayerReloaded" )

	wait 0.9 // let pro players reload before prompting

	if ( !Flag( "PlayerReloaded" ) )
	{
		waitthread WaittillTime( minWaitEnd )

		minWaitEnd = 3 + Time()
		ForcePlayConversationToPlayer( "train_reload", level.player )
		DisplayTrainingPrompt( eTrainingButtonPrompts.RELOAD )

		waitthread NagPlayerUntilFlag( "PlayerReloaded", "train_reload" )
		HideTrainingPrompt()
	}

	level.player.GiveWeapon(PILOT_WEAPON_1)

	if ( !( "moshPitSquads" in level ) )
		level.moshPitSquads <- {}
	else if ( level.moshPitSquads )
	{
		foreach ( squad in level.moshPitSquads )
		{
			if ( !squad )
				continue

			foreach( guy in squad )
			{
				if ( IsAlive( guy ) )
					guy.Kill()
			}
		}
	}

	ShowMinimap()

	if ( !( "pilotMoshPlayerDamage" in level ) )
		level.pilotMoshPlayerDamage <- 0

	level.moshPitSquads = {}

	if ( !( "moshPitTitan" in level ) )
		level.moshPitTitan <- null

	if ( IsAlive( level.moshPitTitan ) )
		level.moshPitTitan.Kill()

	level.moshPitTitan = null

	level.pilotMoshPlayerDamage = 0
	AddDamageCallback( "player", ScriptCallback_PilotMoshPit_PlayerDamaged )

	OnThreadEnd(
		function() : ()
		{
			if ( IsValid( level.player ) )
			{
				StopControllerImageHint()

				if ( DamageCallbackExists( "player", ScriptCallback_PilotMoshPit_PlayerDamaged ) )
					RemoveDamageCallback( "player", ScriptCallback_PilotMoshPit_PlayerDamaged )
			}
		}
	)

	thread RefillPlayerAmmo( level.player )

	local spots = []

	thread HealthSuperRegen()


	// 기본 전투 훈련
	DisplayTrainingPrompt( eTrainingButtonPrompts.ADS )
	spots.append( CreateScriptRef( Vector( 112, 3883, 6400 ), Vector( 0, 50, 0 ) ) )

	waitthread PilotMoshPit_GroundTroops(spots)

	// 수류탄을 이용한 전투 훈련
	FlagClear("MoshPit_GroundTroops_Done")

	waitthread PilotMoshPit_Grenade()
	
	// 근접공격을 이용한 전투 훈련 
	spots.clear()
	spots.append( CreateScriptRef( Vector( 318, 2686, 6400 ), Vector( 0, 50, 0 ) ) )
	
	FlagClear("MoshPit_GroundTroops_Done")
	DisplayTrainingPrompt(eTrainingButtonPrompts.MELEE)
	
	waitthread PilotMoshPit_Melee(spots)

	FlagSet("HealthSuperRegenEnd")

	waitthread PilotMoshPit_KillTitanWithAT()

	waitthread PilotMoshPit_KillTitanWithRODEO()

	Remote.CallFunction_UI( level.player, "ServerCallback_ShowGoToLobbyOrMoreTrainingMenu" )
}

function HealthSuperRegen()
{
	while (1)
	{
		if (Flag("HealthSuperRegenEnd"))
			break;
	
		level.player.SetHealth(1000)
		wait 0
	}
}

function OffHintPulse()
{
	wait 10

	StopHintPulse()
	HideTrainingPrompt()
}

function ScriptCallback_PilotMoshPit_PlayerDamaged( player, damageInfo )
{
	local dmg = damageInfo.GetDamage()
	if ( dmg > 0 )
		level.pilotMoshPlayerDamage += dmg

	// wait for all squads to spawn before training health
	if ( !Flag( "PilotMoshPit_AllSquadsSpawned" ) )
		return

	local healthFrac = GetHealthFrac( level.player )
	//printt( "player health frac:", healthFrac )

	if ( healthFrac <= 0.49 && !Flag( "PilotHealthTrainingStarted" ) )
	{
		thread PilotMoshPit_TrainPilotHealth()
	}
}

function PilotMoshPit_TrainPilotHealth()
{
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )

	FlagSet( "TrainingPilotHealth" )
	FlagSet( "PilotHealthTrainingStarted" )

	// take weapons away
	level.ent.Signal( "StopRefillingOffhandWeapons" )

	if ( "storedPilotLoadout" in level.player.s )
		delete level.player.s.storedPilotLoadout

	StorePilotWeapons( level.player )

	level.player.SetNoTarget( true )
	level.player.SetNoTargetSmartAmmo( true )
	thread PilotMoshPit_NPCsStandDown()

	OnThreadEnd(
		function() : ()
		{
			if ( IsValid( level.player ) )
			{
				level.player.SetNoTarget( false )
				level.player.SetNoTargetSmartAmmo( false )
			}
		}
	)

	// in case the AT weapon hint is on screen
	StopControllerImageHint()

	local ogPrompt = level.lastTrainingPrompt
	DisplayTrainingPrompt( eTrainingButtonPrompts.PILOT_HEALTH )

	ForcePlayConversationToPlayer( "pilot_health_training", level.player )
	wait 18

	RetrievePilotWeapons( level.player )

	// if still in the pilot section, turn grenade weapon refills back on again
	if ( !Flag( "MoshPit_GroundTroops_Done" ) )
	{
		local grenadeWeapon = level.player.GetOffhandWeapon( GRENADE_SLOT )
		thread RefillOffhandAmmoUntilSignal( grenadeWeapon, "MoshPit_GroundTroops_Done" )
	}

	if ( ogPrompt != null )
	{
		DisplayTrainingPrompt( ogPrompt )

		if ( ogPrompt == eTrainingButtonPrompts.WEAPONSWITCH_AT )
			ControllerImageHint_DPad_Left()
	}

	wait 2

	thread PilotMoshPit_NPCsResumeFightingPlayer()
	level.player.SetNoTarget( false )
	level.player.SetNoTargetSmartAmmo( false )

	FlagClear( "TrainingPilotHealth" )
}

function PilotMoshPit_GroundTroops(spots)
{
	ForcePlayConversationToPlayer( "moshpit_combat_start", level.player )
	thread MoshPit_Minimap_VO()

	printt( "waiting for squads to spawn" )

	local delayIncrement = 5
	foreach ( idx, spot in spots )
	{
		spot.s.inUse <- false  // needed to spawn the guys

		local squadName = "moshpit_squad_" + idx
		level.moshPitSquads[ squadName ] <- null

		local delay = idx * delayIncrement
		wait delay

		thread MoshPit_SpawnZiplineSquad( spot, squadName )
	}

	OnThreadEnd(
		function() : ()
		{
			foreach ( squad in level.moshPitSquads )
			{
				if ( !squad )
					continue

				foreach( guy in squad )
				{
					if ( IsAlive( guy ) )
						guy.Kill()
				}
			}
		}
	)

	// wait for squads to all finish spawning
	while ( 1 )
	{
		local foundOne = false
		foreach ( squad in level.moshPitSquads )
		{
			if ( squad == null )
			{
				foundOne = true
				break
			}
		}

		if ( !foundOne )
			break

		wait 0.1
	}

	printt( "squads spawned" )
	FlagSet( "PilotMoshPit_AllSquadsSpawned" )

	// DisplayTrainingPrompt( eTrainingButtonPrompts.MOSHPIT_KILLGUYS )
	// I don't think this nag is necessary
	// thread NagPlayerUntilFlag( "MoshPit_GroundTroops_Done", "train_minimap_findgrunts", 35 )

	// now that everyone is spawned, get the guys and wait for death
	local allGuys = []
	foreach (squad in level.moshPitSquads)
	{
		foreach (guy in squad)
			allGuys.append(guy)
	}

	local combatTimeout = 90
	local combatTimeoutTime = combatTimeout + Time()

	while (Time() < combatTimeoutTime)
	{
		local foundOne = false

		foreach (guy in allGuys)
		{
			if (IsAlive(guy))
			{
				foundOne = true
				break
			}
		}

		if (!foundOne)
			break

		wait 0.1
	}

	if (Time() >= combatTimeoutTime)
	{
		printt( "squad killing timed out" )

		foreach (guy in allGuys)
		{
			if (IsAlive(guy))
				guy.Die()  // do this instead of Kill so he hits the death callback and dissolves
		}
	}
	else
		printt( "player killed all squads" )

	FlagSet( "MoshPit_GroundTroops_Done" )

	// if we're talking about pilot health at this point don't continue til that's done
	FlagWaitClear( "TrainingPilotHealth" )

	HideTrainingPrompt()  // put this after health training is done so in that case we will clear the health training prompt

	// Objective complete.
	local alias = "objective_complete"
	local aliasTime = 3
	if ( level.pilotMoshPlayerDamage <= 300 )
	{
		// Minimal damage sustained during live fire exercise. Well done.
		alias = "bonus_moshpit_lowdamage"
		aliasTime = 5.5
	}

	ForcePlayConversationToPlayer( alias, level.player )
	wait aliasTime
}

function PilotMoshPit_Melee(spots)
{
	FlagSet("Moshpit_Melee")

	ForcePlayConversationToPlayer( "moshpit_combat_start", level.player )
	thread MoshPit_Minimap_VO()

	thread MoshPit_Melee_VO()

	printt( "waiting for squads to spawn" )

	level.moshPitSquads = {}
	local podSpawns = []
	podSpawns.append( { origin = Vector( 325, 2945, 6390 ), angles = Vector( 0, 135, 0 ) } )

	foreach (idx, spawnpoint in podSpawns)
	{
		local squadName = "moshpit_droppod_squad_" + idx
		level.moshPitSquads[ squadName ] <- null

		thread MoshPit_LaunchGruntDropPod( squadName, spawnpoint )
	}

	OnThreadEnd(
		function() : ()
		{
			foreach ( squad in level.moshPitSquads )
			{
				if ( !squad )
					continue

				foreach( guy in squad )
				{
					if ( IsAlive( guy ) )
						guy.Kill()
				}
			}
		}
	)

	// wait for squads to all finish spawning
	while ( 1 )
	{
		local foundOne = false
		foreach ( squad in level.moshPitSquads )
		{
			if ( squad == null )
			{
				foundOne = true
				break
			}
		}

		if ( !foundOne )
			break

		wait 0.1
	}

	printt( "squads spawned" )
	FlagSet( "PilotMoshPit_AllSquadsSpawned" )

	// now that everyone is spawned, get the guys and wait for death
	local allGuys = []
	foreach (squad in level.moshPitSquads)
	{
		foreach (guy in squad)
			allGuys.append(guy)
	}

	wait 3

	foreach (guy in allGuys)
	{
		if (guy)
	  		guy.StopAllAction(true)
	}

	local combatTimeout = 90
	local combatTimeoutTime = combatTimeout + Time()

	while (Time() < combatTimeoutTime)
	{
		local foundOne = false

		foreach (guy in allGuys)
		{
			if (IsAlive(guy))
			{
				foundOne = true
				break
			}
		}

		if (!foundOne)
			break

		wait 0.1
	}

	if (Time() >= combatTimeoutTime)
	{
		printt( "squad killing timed out" )

		foreach (guy in allGuys)
		{
			if (IsAlive(guy))
				guy.Die()  // do this instead of Kill so he hits the death callback and dissolves
		}
	}
	else
		printt( "player killed all squads" )

	FlagClear("Moshpit_Melee")

	FlagSet( "MoshPit_GroundTroops_Done" )

	// if we're talking about pilot health at this point don't continue til that's done
	FlagWaitClear( "TrainingPilotHealth" )

	HideTrainingPrompt()  // put this after health training is done so in that case we will clear the health training prompt

	// Objective complete.
	local alias = "objective_complete"
	local aliasTime = 3
	if ( level.pilotMoshPlayerDamage <= 300 )
	{
		// Minimal damage sustained during live fire exercise. Well done.
		alias = "bonus_moshpit_lowdamage"
		aliasTime = 5.5
	}

	ForcePlayConversationToPlayer( alias, level.player )
	wait aliasTime
}

function PilotMoshPit_Grenade()
{
	FlagSet("Moshpit_Grenade")

	DisplayTrainingPrompt( eTrainingButtonPrompts.FIREGRENADE )

	// 수류탄 지급
	level.player.GiveOffhandWeapon( PILOT_WEAPON_OFFHAND_OFFENSIVE, GRENADE_SLOT )
	local grenadeWeapon = level.player.GetOffhandWeapon( GRENADE_SLOT )
	grenadeWeapon.SetWeaponPrimaryClipCount(2)

	ControllerImageHint_OffhandOffensive()
	OffhandOffensiveHintPulse()

	thread OffHintPulse()

	thread RefillOffhandAmmoUntilSignal( grenadeWeapon, "MoshPit_GroundTroops_Done" )

	ForcePlayConversationToPlayer( "moshpit_combat_start", level.player )
	thread MoshPit_Minimap_VO()

	thread MoshPit_Grenade_VO()

	printt( "waiting for squads to spawn" )

	local podSpawns = []
	podSpawns.append( { origin = Vector( 926, 3442, 6550 ), angles = Vector( 0, -50, 0 ) } )
	podSpawns.append( { origin = Vector( 894, 2930, 6550 ), angles = Vector( 0, -90, 0 ) } )
	podSpawns.append( { origin = Vector( 1406, 2930, 6400 ), angles = Vector( 0, -160, 0 ) } )
	podSpawns.append( { origin = Vector( 1534, 3442, 6400 ), angles = Vector( 0, 125, 0 ) } )
	podSpawns.append( { origin = Vector( 382, 3266, 6400 ), angles = Vector( 0, 30, 0 ) } )
	podSpawns.append( { origin = Vector( 574, 2946, 6450 ), angles = Vector( 0, 45, 0 ) } )
	podSpawns.append( { origin = Vector( 2046, 3698, 6400 ), angles = Vector( 0, 60, 0 ) } )
	podSpawns.append( { origin = Vector( 1982, 3122, 6400 ), angles = Vector( 0, 75, 0 ) } )

	foreach ( idx, spawnpoint in podSpawns )
	{
		local squadName = "moshpit_droppod_squad_" + idx
		level.moshPitSquads[ squadName ] <- null

		thread MoshPit_LaunchGruntDropPod( squadName, spawnpoint )
	}

	// wait for squads to all finish spawning
	while ( 1 )
	{
		local foundOne = false
		foreach ( squad in level.moshPitSquads )
		{
			if ( squad == null )
			{
				foundOne = true
				break
			}
		}

		if ( !foundOne )
			break

		wait 0.1
	}

	printt( "squads spawned" )
	FlagSet( "PilotMoshPit_AllSquadsSpawned" )

	local allGuys = []

	foreach (squad in level.moshPitSquads)
	{
		foreach( guy in squad )
			allGuys.append( guy )
	}

	local combatTimeout = 90
	local combatTimeoutTime = combatTimeout + Time()

	while (Time() < combatTimeoutTime)
	{
		local foundOne = false
		local deathCount = 0

		foreach (guy in allGuys)
		{
			if (!IsAlive(guy))
				++deathCount
		}

		if (deathCount >= 16)
			break

		wait 0.1
	}

	foreach (squad in level.moshPitSquads)
	{
		if (!squad)
			continue

		foreach (guy in squad)
		{
			if (IsAlive(guy))
				guy.Die()
		}
	}

	FlagClear("Moshpit_Grenade")

	FlagSet( "MoshPit_GroundTroops_Done" )

	// if we're talking about pilot health at this point don't continue til that's done
	FlagWaitClear( "TrainingPilotHealth" )

	HideTrainingPrompt()  // put this after health training is done so in that case we will clear the health training prompt

	// Objective complete.
	local alias = "objective_complete"
	local aliasTime = 5

	if (level.pilotMoshPlayerDamage <= 300)
	{
		// Minimal damage sustained during live fire exercise. Well done.
		alias = "bonus_moshpit_lowdamage"
		aliasTime = 5.5
	}

	ForcePlayConversationToPlayer( alias, level.player )
	wait aliasTime
}

function MoshPit_Grenade_VO()
{
	wait 18

	if (!Flag("Moshpit_Grenade"))
		return

	ForcePlayConversationToPlayer( "train_firingrange_grenades", level.player )
}

function MoshPit_Melee_VO()
{
	wait 18

	if (!Flag("Moshpit_Melee"))
		return

	ForcePlayConversationToPlayer( "train_melee_nag", level.player )
}

function MoshPit_TitanRodeo_VO()
{
	while ( 1 )
	{
		local rodeoedSoul = level.player.GetTitanSoulBeingRodeoed()

		if (level.player.GetTitanSoulBeingRodeoed())
		{
			ForcePlayConversationToPlayer("train_rodeo", level.player)
			break
		}

		wait 0.1
	}
}

function MoshPit_TitanAttack_VO()
{
	ForcePlayConversationToPlayer( "titan_kill_drop_pod_grunts", level.player )

	wait 5
	ForcePlayConversationToPlayer( "train_titan_attack", level.player )
}

function MoshPit_Minimap_VO()
{
	level.ent.EndSignal( "ModuleChanging" )
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )

	wait 7

	HighlightMinimap()

	ForcePlayConversationToPlayer( "train_minimap", level.player )

	FlagWait("ConversationOver")
	FlagClear("ConversationOver")	
	ForcePlayConversationToPlayer( "train_minimap_findgrunts", level.player )

	FlagWait("ConversationOver")
	FlagClear("ConversationOver")
	StopHighlightMinimap()
}

function MoshPit_SpawnZiplineSquad( spot, squadName )
{
	level.ent.EndSignal( "ModuleChanging" )
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )

	Assert( squadName in level.moshPitSquads )

	local oppTeam = GetOppositeTeam( level.player )

	// time passes before the squad spawns

	//have to do it like this because Flag( "disable_npcs" ) is true... so we must force it...
	//normally we'd use Spawn_ScriptedTrackedZipLineGruntSquad, but that wants the origin and angles of the animation, which is a different position than the spawn point.
	local ai_type = "npc_soldier"
	local forced = true
	local dropTable = CreateZipLineSquadDropTable( oppTeam, 4, spot, squadName )
	local squad = Spawn_TrackedZipLineSquad( ai_type, spot, dropTable, forced )
	level.moshPitSquads[ squadName ] = squad

	foreach ( guy in squad )
		thread MoshPit_NPC_FightPlayer( guy )
}

function MoshPit_NPC_FightPlayer( guy )
{
	guy.Signal( "NPC_FightPlayer" )
	guy.EndSignal( "NPC_FightPlayer" )

	guy.EndSignal( "StandDown_Change" )
	guy.EndSignal( "OnDeath" )

	level.player.EndSignal( "OnDeath" )
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )

	guy.Minimap_AlwaysShow( level.player.GetTeam(), level.player )
	guy.SetEnemy( level.player )

	if (guy.IsSoldier())
	{
		guy.SetEngagementDistVsWeak( 400, 1024 )
		guy.SetEngagementDistVsStrong( 400, 1024 )
	}

	local memoryRefreshTime = 5

	if (guy.IsTitan())
		memoryRefreshTime = 10

	if (!("backupAssaultEnt" in guy.s))
	{
		local ambushSpots = []
		ambushSpots.append( { origin = Vector( -778.451, 2458.06, 6383.9 ), angles = Vector( 0, 116.989, 0 ) } )
		ambushSpots.append( { origin = Vector( -1277.68, 3694.24, 6389.53 ), angles = Vector( 0, -58.9187, 0 ) } )
		ambushSpots.append( { origin = Vector( -333.503, 3687.86, 6368.16 ), angles = Vector( 0, -134.101, 0 ) } )
		local ambushSpot = Random( ambushSpots )
		guy.s.backupAssaultEnt <- CreateStrictAssaultEnt( ambushSpot.origin, ambushSpot.angles, 450 )
	}

	local playerIsTarget = true
	local lastTarget = null

	while (1)
	{
		if (level.moshpitStartAreaTrig.IsTouching(level.player))
			playerIsTarget = false

		if (playerIsTarget && lastTarget != level.player)
		{
			guy.AssaultPointEnt(level.player.s.playerAssaultEnt)
			lastTarget = level.player
		}
		else if (!playerIsTarget && lastTarget != guy.s.backupAssaultEnt)
		{
			guy.AssaultPointEnt( guy.s.backupAssaultEnt )
			lastTarget = guy.s.backupAssaultEnt
		}

		UpdateEnemyMemory(guy, level.player)
		wait memoryRefreshTime
	}
}

function PilotMoshPit_KillTitanWithAT()
{
	level.player.GiveWeapon( PILOT_WEAPON_AT )
	local weapon = WaitForPlayerActiveWeapon()

	if ( weapon.GetClassname() != PILOT_WEAPON_AT )
	{
		FlagClear( "FiringRangeWeaponSwapped" )
		thread MoshPit_TitanCombatStartVO( "FiringRangeWeaponSwapped" )
		thread NagPlayerUntilFlag( "FiringRangeWeaponSwapped", "train_firingrange_at_swap_nag" )

		while ( 1 )
		{
			local weapon = WaitForPlayerActiveWeapon()
			if ( weapon.GetClassname() == PILOT_WEAPON_AT )
			{
				FlagSet( "FiringRangeWeaponSwapped" )
				break
			}

			wait 0.1
		}

		HideTrainingPrompt()
		StopControllerImageHint()
	}

	MoshPit_SpawnDroneTitan({ origin = Vector( 905, 3446, 6540 ), angles = Vector( 0, -130, 0 ) })

	// if we started training the player on pilot health, wait for that to finish
	FlagWaitClear( "TrainingPilotHealth" )

	ForcePlayConversationToPlayer( "train_firingrange_at_killTitan", level.player )

	//ForcePlayConversationToPlayer( "moshpit_titan_at_reminder", level.player )  // CUT?
	thread MoshPit_TitanCombat_ManageVO( level.moshPitTitan )
	thread MoshPit_TitanCombat_ManagePrompts( level.moshPitTitan )

	waitthread WaitUntilGuysAreDead( [ level.moshPitTitan ] )

	// if currently training player on pilot health, wait for that to finish
	if ( Flag( "TrainingPilotHealth" ) )
	{
		FlagWaitClear( "TrainingPilotHealth" )
		HideTrainingPrompt()
	}
	else
	{
		ForcePlayConversationToPlayer( "goodjob", level.player )
		wait 1.5
	}

	ForcePlayConversationToPlayer( "train_firingrange_at_killTitan_done", level.player )
	wait 6
}

function SpawnStandDownTitan(spot, team, disableShield = true)
{
	local spawnOrg = spot.origin
	local spawnAng = spot.angles
	local oppTeam = team
	local alert = 0
	local titan = NPE_SpawnTitan( oppTeam, spawnOrg, spawnAng, alert )

	level.moshPitTitans.append( titan )

	titan.s.isHotDropping <- true
	titan.SetTitle( "#NPC_TITAN_TRAINING" )
	titan.TakeOffhandWeapon( 1 )

	if (disableShield)
		DisableTitanShield( titan )

	titan.Minimap_AlwaysShow( level.player.GetTeam(), level.player )

	waitthread SuperHotDropGenericTitan( titan, spawnOrg, spawnAng )

	titan.s.isHotDropping = false	

	NPC_StandDown( titan )
}

function PilotMoshPit_KillTitanWithRODEO()
{
	//중앙 하단 대타이탄 무기를 사용하라는 메세지 disable
	Remote.CallFunction_Replay( level.player, "ServerCallback_SetEnableAntiTitanHint", false )

	//로데오 하기전엔 무기사용을 못하게 막는다.
	level.player.FreezeFireControlsOnServer()

	level.player.SetActiveWeapon( PILOT_WEAPON_3 )
	WaitForPlayerActiveWeapon( PILOT_WEAPON_3 )
	level.player.TakeWeapon( PILOT_WEAPON_AT )

	MoshPit_SpawnDroneTitan({ origin = Vector( 905, 3446, 6540 ), angles = Vector( 0, -130, 0 ) })

	// if we started training the player on pilot health, wait for that to finish
	FlagWaitClear( "TrainingPilotHealth" )

	// 은폐장 능력.
	local cloakSlot = 1
	level.player.GiveOffhandWeapon( "mp_ability_cloak", cloakSlot, [ "bc_long_cloak1" ] )

	thread Cloak_IntroVO()
	waitthread Cloak_ManagePrompt(0)

	// 은폐장을 활성화하면 로데오 허용.
	EnableRodeo(level.moshPitTitan)

	thread MoshPit_TitanCombat_ManageVO(level.moshPitTitan)
	thread MoshPit_TitanRodeo_ManagePrompts(level.moshPitTitan)
	thread MoshPit_TitanRodeo_VO()

	waitthread WaitUntilGuysAreDead( [ level.moshPitTitan ] )

	// if currently training player on pilot health, wait for that to finish
	if ( Flag( "TrainingPilotHealth" ) )
	{
		FlagWaitClear( "TrainingPilotHealth" )
		HideTrainingPrompt()
	}
	else
	{
		ForcePlayConversationToPlayer( "goodjob", level.player )
		wait 1.5
	}

	ForcePlayConversationToPlayer( "train_firingrange_at_killTitan_done", level.player )
	wait 6

	//중앙 하단 대타이탄 무기를 사용하라는 메세지 enable
	Remote.CallFunction_Replay( level.player, "ServerCallback_SetEnableAntiTitanHint", true )
}

function MoshPit_TitanCombatStartVO( endFlag )
{
	level.ent.EndSignal( "ModuleChanging" )
	level.ent.EndSignal( endFlag )
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )

	ForcePlayConversationToPlayer( "moshpit_titan_combat_start", level.player )
	wait 5
	ForcePlayConversationToPlayer( "train_firingrange_at_swap", level.player )
	wait 4

	DisplayTrainingPrompt( eTrainingButtonPrompts.WEAPONSWITCH_AT )
	ControllerImageHint_DPad_Left()
}

function MoshPit_TitanCombat_ManageVO( titan )
{
	if ( Flag( "PilotHealthTrainingStarted" ) )
	{
		if ( !Flag( "TrainingPilotHealth" ) )
		{
			// health training is done
			return
		}
		else
		{
			// wait for health training to finish
			FlagWaitClear( "TrainingPilotHealth" )
		}
	}
	else
	{
		thread NagPlayerUntilGuysAreDead( [ titan ], "train_firingrange_at_killTitan", 40 )

		FlagWait( "PilotHealthTrainingStarted" ) // wait for health training to start

		FlagSet( "NagFlag" )  // manually stop the nag and wait for health training to finish
		FlagWaitClear( "TrainingPilotHealth" )
	}

	// turn the nags back on for AT training now that health training is done
	if ( IsAlive( titan ) )
		thread NagPlayerUntilGuysAreDead( [ titan ], "train_firingrange_at_killTitan", 40 )
}

function MoshPit_TitanRodeo_ManagePrompts( enemyTitan )
{
	level.ent.EndSignal( "ModuleChanging" )
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	enemyTitan.EndSignal( "OnDeath" )

	OnThreadEnd(
		function() : ()
		{
			StopControllerImageHint()

			// don't hide the prompt if the Titan dies while player is learning about health
			if ( !Flag( "TrainingPilotHealth" ) )
				HideTrainingPrompt()
		}
	)

	local currentPrompt = null
	while ( 1 )
	{
		wait 0.2

		// don't change the prompt while talking about pilot health
		if ( Flag( "TrainingPilotHealth" ) )
			continue

		local rodeoedSoul = level.player.GetTitanSoulBeingRodeoed()

		if ( rodeoedSoul == null )
		{
			if ( currentPrompt != eTrainingButtonPrompts.TITAN_RODEO )
			{
				currentPrompt = eTrainingButtonPrompts.TITAN_RODEO
				DisplayTrainingPrompt( currentPrompt )
				ControllerImageHint_DPad_Left()

				level.player.FreezeFireControlsOnServer()
			}
		}
		else
		{
			if ( currentPrompt != eTrainingButtonPrompts.TITAN_RODEO_COMBAT )
			{
				currentPrompt = eTrainingButtonPrompts.TITAN_RODEO_COMBAT
				DisplayTrainingPrompt( currentPrompt )
				StopControllerImageHint()
		
				level.player.UnfreezeFireControlsOnServer()
			}
		}
	}
}

function MoshPit_TitanCombat_ManagePrompts( enemyTitan )
{
	level.ent.EndSignal( "ModuleChanging" )
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	enemyTitan.EndSignal( "OnDeath" )

	OnThreadEnd(
		function() : ()
		{
			StopControllerImageHint()

			// don't hide the prompt if the Titan dies while player is learning about health
			if ( !Flag( "TrainingPilotHealth" ) )
				HideTrainingPrompt()
		}
	)

	local weapon
	local currentPrompt = null
	while ( 1 )
	{
		wait 0.2

		// don't change the prompt while talking about pilot health
		if ( Flag( "TrainingPilotHealth" ) )
			continue

		weapon = level.player.GetActiveWeapon()

		if ( !weapon )
			continue

		local weaponClass = weapon.GetClassname()

		if ( weaponClass != PILOT_WEAPON_AT && currentPrompt != eTrainingButtonPrompts.WEAPONSWITCH_AT )
		{
			currentPrompt = eTrainingButtonPrompts.WEAPONSWITCH_AT
			DisplayTrainingPrompt( currentPrompt )
			ControllerImageHint_DPad_Left()
		}
		else if ( weaponClass == PILOT_WEAPON_AT && currentPrompt != eTrainingButtonPrompts.ADS )
		{
			currentPrompt = eTrainingButtonPrompts.ADS
			DisplayTrainingPrompt( currentPrompt )
			StopControllerImageHint()
		}
	}
}

function SetFlagWhenPlayerTitanInMap( flag )
{
	level.ent.EndSignal( "ModuleChanging" )
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )

	while ( !GetPlayerTitanInMap( level.player ) )
		wait 0.1

	FlagSet( flag )
}

function SetFlagWhenTitanHitsGround( playerTitan, setFlag )
{
	playerTitan.EndSignal( "OnDeath" )  // titan is killed when player becomes the titan, this can happen before the impact signal

	OnThreadEnd(
		function() : ( setFlag )
		{
			FlagSet( setFlag )
		}
	)

	level.player.WaitSignal( "titan_impact" )
}

function SetFlagWhenPlayerEntersTitan( titan, flag )
{
	level.ent.EndSignal( "ModuleChanging" )
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )

	while ( !level.player.IsTitan() )
		wait 1

	FlagSet( flag )
}

function MoshPit_SpawnDroneTitan(spot, defaultWeapon = "mp_titanweapon_xo16")
{
	local spawnOrg = spot.origin
	local spawnAng = spot.angles

	local oppTeam = GetOppositeTeam( level.player )
	local alert = 0
	local titan = NPE_SpawnTitan(oppTeam, spawnOrg, spawnAng, alert, false, defaultWeapon)
	
	titan.s.isHotDropping <- true
	level.moshPitTitan = titan

	titan.SetTitle( "#NPC_TITAN_TRAINING" )
	titan.TakeOffhandWeapon( 1 )

	DisableRodeo( titan )
	DisableTitanShield( titan )

	titan.Minimap_AlwaysShow( level.player.GetTeam(), level.player )

	FlagSet( "DisableTitanKneelingEmbark" )

	OnThreadEnd(
		function() : ()
		{
			if ( IsValid ( level.player ) )
				FlagClear( "DisableTitanKneelingEmbark" )
		}
	)

	waitthread SuperHotDropGenericTitan( titan, spawnOrg, spawnAng )
	titan.s.isHotDropping = false
}

function PilotMoshPit_GetAllEnemies()
{
	// not reliable to get all enemies unless the zipline squad spawning has finished
	Assert( Flag( "PilotMoshPit_AllSquadsSpawned" ) )

	local allGuys = []
	foreach ( squad in level.moshPitSquads )
	{
		if ( !squad )
			continue

		foreach( guy in squad )
		{
			if ( !IsAlive( guy ) )
				continue

			allGuys.append( guy )
		}
	}

	if ( IsAlive( level.moshPitTitan ) )
		allGuys.append( level.moshPitTitan )

	return allGuys
}

function TitanMoshPit_NPCsStandDown()
{
	foreach ( titan in level.moshPitTitans )
		thread NPC_StandDown( titan )
}

function TitanMoshPit_NPCsResumeFightingPlayer()
{
	foreach ( titan in level.moshPitTitans )
	{
		if (!titan)
			continue

		if (titan.s.isHotDropping)
			continue

		thread NPC_StandDown_Stop( titan )
	}
}

function PilotMoshPit_NPCsStandDown()
{
	local allGuys = PilotMoshPit_GetAllEnemies()

	foreach ( guy in allGuys )
		thread NPC_StandDown( guy )
}

function PilotMoshPit_NPCsResumeFightingPlayer()
{
	local allGuys = PilotMoshPit_GetAllEnemies()

	foreach ( guy in allGuys )
	{
		if ( !IsAlive( guy ) )
			continue

		NPC_StandDown_Stop( guy )

		if ( guy.IsTitan() )
		{
			// AT training target Titan should still stay in place after stand down
			// TODO JIESANG! Titan thinks he needs to do the stance to a stand activity here which puts him in a weird looking loop
			thread NPE_NPCStayPut( guy )
		}
		else if ( guy.IsSoldier() )
		{
			thread MoshPit_NPC_FightPlayer( guy )
		}
	}
}


function MoshPit_PlayerMopsUpAsTitan()
{
	ForcePlayConversationToPlayer( "titan_controls_like_pilot", level.player )
	wait 4.25

	DisplayTrainingPrompt( eTrainingButtonPrompts.FIREPRIMARY )
	ForcePlayConversationToPlayer( "titan_primary_fire_like_pilot", level.player )
	wait 5

	level.moshPitSquads = {}  // reset so squads are null
	local podSpawns = []
	podSpawns.append( { origin = Vector( -9.97231, 3632.03, 6366.88 ), angles = Vector( 0, -52.5624, 0 ) } )
	podSpawns.append( { origin = Vector( 956.635, 3451.81, 6544.03 ), angles = Vector( 0, -96.4783, 0 ) } )
	podSpawns.append( { origin = Vector( 1721.89, 2756.19, 6400.51 ), angles = Vector( 0, -159.951, 0 ) } )
	podSpawns.append( { origin = Vector( 2114.33, 1099, 6372.17 ), angles = Vector( 0, 121.815, 0 ) } )
	podSpawns.append( { origin = Vector( -431.435, 725.337, 6400.03 ), angles = Vector( 0, 28.3477, 0 ) } )

	foreach ( idx, spawnpoint in podSpawns )
	{
		local squadName = "moshpit_droppod_squad_" + idx
		level.moshPitSquads[ squadName ] <- null

		thread MoshPit_LaunchGruntDropPod( squadName, spawnpoint )
	}

	HideTrainingPrompt()
	ForcePlayConversationToPlayer( "titan_kill_drop_pod_grunts", level.player )

	printt( "waiting for drop pod squads to spawn" )

	// wait for squads to all finish spawning
	while ( 1 )
	{
		local foundOneEmpty = false
		foreach ( squad in level.moshPitSquads )
		{
			if ( squad == null )
			{
				foundOneEmpty = true
				break
			}
		}

		if ( !foundOneEmpty )
			break

		wait 0.1
	}

	printt( "drop pod squads spawned" )

	FlagClear( "MoshPit_GroundTroops_Done" )

	DisplayTrainingPrompt( eTrainingButtonPrompts.MOSHPIT_KILLGUYS )
	// I don't think we need this nag
	//thread NagPlayerUntilFlag( "MoshPit_GroundTroops_Done", "train_minimap_findgrunts", 35 )

	// now that everyone is spawned, get the guys and wait for death
	local allGuys = []
	foreach ( squad in level.moshPitSquads )
		foreach( guy in squad )
			allGuys.append( guy )

	local combatTimeout = 60
	local combatTimeoutTime = combatTimeout + Time()
	while( Time() < combatTimeoutTime )
	{
		local foundOne = false

		foreach ( guy in allGuys )
		{
			if ( IsAlive( guy ) )
			{
				foundOne = true
				break
			}
		}

		if ( !foundOne )
			break

		wait 0.1
	}

	if ( Time() >= combatTimeoutTime )
	{
		printt( "squad killing timed out" )
		foreach ( guy in allGuys )
			if ( IsAlive( guy ) )
				guy.Die()  // do this instead of Kill so he hits the death callback and dissolves
	}
	else
	{
		printt( "player killed all squads" )
	}

	HideTrainingPrompt()
}

function MoshPit_LaunchGruntDropPod( squadName, spawnpoint )
{
	level.ent.EndSignal( "ModuleChanging" )
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )

	local oppTeam = GetOppositeTeam( level.player )

	Assert( squadName in level.moshPitSquads )

	local squad = GruntPod_LaunchToPoint( oppTeam, squadName, spawnpoint.origin, spawnpoint.angles, SpawnGrunt )
	level.moshPitSquads[ squadName ] = squad

	foreach ( guy in squad )
		thread MoshPit_NPC_FightPlayer( guy )
}

function InitMoshPitTitans()
{
	if ( !( "moshPitTitans" in level ) )
		level.moshPitTitans <- []
	else
	{
		foreach ( titan in level.moshPitTitans )
		{
			if ( !IsValid( titan ) )
				continue

			titan.Kill()
		}

		level.moshPitTitans = []
	}
}

function Module_BattlePractice()
{
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )
	level.player.WaitSignal( "Teleported" )	

	level.ent.WaitSignal( "ModuleChangeDone" )

	while (level.player.s.usedLoadoutCrate == true)
		wait 0.1

	level.player.DeployWeapon()
	ShowMinimap()

	wait 3

	while (1)
	{
		waitthread BattlePractice_Step_B()
		waitthread BattlePractice_Step_C()
		waitthread BattlePractice_Step_D()
		waitthread BattlePractice_Step_E()
	}

	GameRules.EndMatch()
}

function BattlePractice_Step_B()
{
	if ( !( "moshPitSquads" in level ) )
		level.moshPitSquads <- {}
	else 
		level.moshPitSquads = {}

	local podSpawns = []
	podSpawns.append( { origin = Vector( 926, 3442, 6550 ), angles = Vector( 0, -50, 0 ) } )

	foreach (idx, spawnpoint in podSpawns)
	{
		local squadName = "moshpit_droppod_squad_" + idx
		level.moshPitSquads[ squadName ] <- null

		waitthread MoshPit_LaunchGruntDropPod( squadName, spawnpoint )
	}

	while ( 1 )
	{
		local foundOne = false
		foreach ( squad in level.moshPitSquads )
		{
			if ( squad == null )
			{
				foundOne = true
				break
			}
		}

		if ( !foundOne )
			break

		wait 0.1
	}

	// 스폰완료.
	local allGuys = []
	foreach (squad in level.moshPitSquads)
	{
		foreach (guy in squad)
			allGuys.append(guy)
	}

	while (1)
	{
		local foundOne = false

		foreach (guy in allGuys)
		{
			if (IsAlive(guy))
			{
				foundOne = true
				break
			}
		}

		if (!foundOne)
			break

		wait 0.1
	}

	wait 3
}

function BattlePractice_Step_C()
{
	if ( !( "moshPitTitans" in level ) )
		level.moshPitTitans <- []
	else 
		level.moshPitTitans = []

	local spawns = []
	spawns.append({origin = Vector(876.222, 3413.73, 6590.57), angles = Vector(0, -142.022, 0)})

	waitthread SpawnBattlePracticeTitans(spawns)

	waitthread WaitUntilGuysAreDead(level.moshPitTitans)	

	wait 3
}

function BattlePractice_Step_D()
{
	if ( !( "moshPitSquads" in level ) )
		level.moshPitSquads <- {}
	else 
		level.moshPitSquads = {}

	local podSpawns = []
	podSpawns.append( { origin = Vector( 926, 3442, 6550 ), angles = Vector( 0, -50, 0 ) } )
	podSpawns.append( { origin = Vector( 894, 2930, 6550 ), angles = Vector( 0, -90, 0 ) } )

	foreach (idx, spawnpoint in podSpawns)
	{
		local squadName = "moshpit_droppod_squad_" + idx
		level.moshPitSquads[ squadName ] <- null

		waitthread MoshPit_LaunchGruntDropPod( squadName, spawnpoint )
	}

	while ( 1 )
	{
		local foundOne = false
		foreach ( squad in level.moshPitSquads )
		{
			if ( squad == null )
			{
				foundOne = true
				break
			}
		}

		if ( !foundOne )
			break

		wait 0.1
	}

	// 스폰완료.
	local allGuys = []
	foreach (squad in level.moshPitSquads)
	{
		foreach (guy in squad)
			allGuys.append(guy)
	}

	while (1)
	{
		local foundOne = false

		foreach (guy in allGuys)
		{
			if (IsAlive(guy))
			{
				foundOne = true
				break
			}
		}

		if (!foundOne)
			break

		wait 0.1
	}

	wait 3	
}

function BattlePractice_Step_E()
{
	if ( !( "moshPitTitans" in level ) )
		level.moshPitTitans <- []
	else 
		level.moshPitTitans = []

	local spawns = []
	spawns.append({origin = Vector(876.222, 3413.73, 6590.57), angles = Vector(0, -142.022, 0)})
	spawns.append({origin = Vector(2048, 3584, 6400), angles = Vector(0, 0, 0)})

	waitthread SpawnBattlePracticeTitans(spawns)

	waitthread WaitUntilGuysAreDead(level.moshPitTitans)	

	wait 3
}

function SpawnBattlePracticeTitan(spot)
{
	local spawnOrg = spot.origin
	local spawnAng = spot.angles
	local oppTeam = GetOppositeTeam( level.player )
	local alert = 0
	local titan = NPE_SpawnTitan(oppTeam, spawnOrg, spawnAng, alert, false, "mp_titanweapon_xo16")
	
	titan.s.isHotDropping <- true
	titan.SetTitle( "#NPC_TITAN_TRAINING" )
	titan.TakeOffhandWeapon( 1 )
	titan.Minimap_AlwaysShow( level.player.GetTeam(), level.player )

	FlagSet( "DisableTitanKneelingEmbark" )

	waitthread SuperHotDropGenericTitan( titan, spawnOrg, spawnAng )
	titan.s.isHotDropping = false

	FlagClear( "DisableTitanKneelingEmbark" )	

	level.moshPitTitans.append(titan)
}

function SpawnBattlePracticeTitans(spawns)
{
	foreach (spot in spawns)
		thread SpawnBattlePracticeTitan(spot)		

	while (1)
	{
		if (level.moshPitTitans.len() == spawns.len())
			break

		wait 0.1
	}
}

function Module_TitanMoshPit()
{
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )
	level.player.WaitSignal( "Teleported" )

	local table = level.player.playerClassData[ "titan" ]
	table.liverycode <- null
	table.liverycolor0 <- null
	table.liverycolor1 <- null
	table.liverycolor2 <- null

	InitMoshPitTitans()

	level.ent.WaitSignal( "ModuleChangeDone" )

	TakeAllWeapons( level.player )

	ForcePlayConversationToPlayer( "train_titanfall", level.player )

	//level.player.SetNextTitanRespawnAvailable( Time() )
	ForceTitanBuildComplete( level.player )
	Remote.CallFunction_Replay( level.player, "ServerCallback_EnableTitanModeHUD" )

	// 타이탄 호출 한번만 할수있게..
	level.nv.titanAvailability = eTitanAvailability.Once

	local minWaitEnd = 3.75 + Time()

	FlagWait("ConversationOver")
	FlagClear("ConversationOver")
	ForcePlayConversationToPlayer( "train_call_in_titan", level.player )

	DisplayTrainingPrompt( eTrainingButtonPrompts.CALL_TITAN )
	ControllerImageHint_DPad_Down()

	thread SetFlagWhenPlayerTitanInMap( "PlayerCalledInTitan" )
	waitthread NagPlayerUntilFlag( "PlayerCalledInTitan", "train_call_in_titan_nag", 15 )

	HideTrainingPrompt()
	StopControllerImageHint()

	WaittillTime( minWaitEnd )

	ForcePlayConversationToPlayer( "train_titanfall_lookup", level.player )

	local playerTitan = GetPlayerTitanInMap( level.player )
	TakeAllWeapons( playerTitan )
	playerTitan.GiveWeapon( "mp_titanweapon_rocket_launcher" )

	thread SetFlagWhenTitanHitsGround( playerTitan, "TitanDropped" )
	FlagWait( "TitanDropped" )

	DisplayTrainingPrompt( eTrainingButtonPrompts.ENTER_TITAN )
	thread SetFlagWhenPlayerEntersTitan( playerTitan, "PlayerEnteredTitan" )
	waitthread NagPlayerUntilFlag( "PlayerEnteredTitan", "train_titan_mountup", 20 )

	thread MoshPit_TitanAttack_VO()

	AddDamageCallback( "player", PlayerDamageCallback_TitanMoshPit )

	OnThreadEnd(
		function() : ()
		{
			if ( IsValid( level.player ) )
			{
				// turn demigod back on before removing the callback, in case Titan is currently at end of doomed state and one more hit would kill the player
				level.player.EnableDemigod()
				RemoveDamageCallback( "player", PlayerDamageCallback_TitanMoshPit )
			}
		}
	)

	HideTrainingPrompt()

	wait 5

	ShowMinimap()

	waitthread Titan_OffensiveMelee()

	wait 1
	waitthread Titan_OffensiveOffhandTraining()

	FlagSet( "TitanMoshPitCombatStarted" )

	waitthread TitanMoshPit_Combat()

	waitthread Titan_TrainEject()

	wait 1.2

	printt( "TITAN MOSH PIT ALL DONE" )

	// Excellent. Your Pilot combat certification is complete.
	ForcePlayConversationToPlayer( "pilot_cert_done", level.player )

	// ======== SEND TO END MODULE ========
	wait 5
	EmitSoundOnEntity( level.player, "NPE_Module_Finish" )

	if (GAMETYPE == "titan_tutorial")
	{
		GameRules.EndMatch()
	}
	else
	{
		level.player.SetTutorialStatus( TR_RESULT_COMPLETE );
		thread StartTrainingModule( TRAINING_BEDROOM_END/*eTrainingModules.BEDROOM_END*/ )
	}
}

function PlayerDamageCallback_TitanMoshPit( player, damageInfo )
{
	if ( !IsValid( player ) )
		return

	if ( !player.IsTitan() )
		return

	// no titanfall damage - usually causes instadeath
	if ( damageInfo.GetDamageSourceIdentifier() == eDamageSourceId.titan_fall )
	{
		printt( "Titanfall damage detected, zeroing out" )
		damageInfo.SetDamage( 0 )
		return
	}

	// only train these concepts after mosh pit combat section starts
	if ( Flag( "TitanMoshPitCombatStarted" ) )
	{
		// SHIELD TRAINING FIRST
		if ( !Flag( "TitanShieldTrainingStarted" ) )
		{
			local soul = level.player.GetTitanSoul()

			// defensive
			if ( !IsValid( soul ) )
				return

			local shieldHealth = soul.GetShieldHealth().tofloat()
			local shieldHealthMax = soul.GetShieldHealthMax().tofloat()
			local shieldFrac = shieldHealth / shieldHealthMax

			if ( shieldFrac <= 0.2 )
				thread TitanMoshPit_TrainTitanConcept( "shields" )
		}

		// HEALTH TRAINING ONLY HAPPENS AFTER SHIELD TRAINING
		else if ( Flag( "TitanShieldTrainingStarted" ) && !Flag( "TrainingTitanShields" ) && !Flag( "TitanHealthTrainingStarted" ) )
		{
			local healthFrac = GetHealthFrac( level.player )

			if ( healthFrac <= 0.75 )
				thread TitanMoshPit_TrainTitanConcept( "health" )
		}
	}

	if ( !level.player.GetDoomedState() )
		return

	// no doomed state death, but we want to let the doomed state bar drain to a sliver
	if ( player.GetHealth() - damageInfo.GetDamage() <= 0 )
		damageInfo.SetDamage( 0 )
}

// type = "shields" or "health"
function TitanMoshPit_TrainTitanConcept( type )
{
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )

	local startFlag
	local busyFlag
	local promptID
	local convAlias
	local convWait

	Assert( type == "shields" || type == "health" )

	if ( type == "shields" )
	{
		startFlag = "TitanShieldTrainingStarted"
		busyFlag = "TrainingTitanShields"

		promptID = eTrainingButtonPrompts.TITAN_SHIELDS

		convAlias = "titan_shields_training"
		convWait = 19
	}
	else if ( type == "health" )
	{
		startFlag = "TitanHealthTrainingStarted"
		busyFlag = "TrainingTitanHealth"

		promptID = eTrainingButtonPrompts.TITAN_HEALTH

		convAlias = "titan_health_training"
		convWait = 13
	}

	FlagSet( startFlag )
	FlagSet( busyFlag )

	// take weapons and infinite ammo
	level.ent.Signal( "StopRefillingPlayerAmmo" )

	local offhands = level.player.GetOffhandWeapons()
	local storedOffhands = {}
	StoreWeaponsToTable( storedOffhands, offhands, "offhandWeapons" )

	foreach ( index, offhand in clone offhands )
		level.player.TakeOffhandWeapon( index )
	thread TakeAmmoFromPlayerASAP()

	level.player.EnableDemigod()
	level.player.SetNoTarget( true )
	level.player.SetNoTargetSmartAmmo( true )
	thread TitanMoshPit_NPCsStandDown()

	OnThreadEnd(
		function() : ()
		{
			if ( IsValid( level.player ) )
			{
				level.player.SetNoTarget( false )
				level.player.SetNoTargetSmartAmmo( false )
				level.player.DisableDemigod()
			}
		}
	)

	local ogPrompt = level.lastTrainingPrompt
	DisplayTrainingPrompt( promptID )

	ForcePlayConversationToPlayer( convAlias, level.player )
	wait convWait
	printt( "conv done" )

	if ( ogPrompt != null )
		DisplayTrainingPrompt( ogPrompt )
	else
		HideTrainingPrompt()

	// give back weapons and infinite ammo
	foreach ( idx, offhand in storedOffhands.offhandWeapons )
		level.player.GiveOffhandWeapon( offhand.name, idx )

	thread RefillPlayerAmmo( level.player )

	// let player reload finish
	wait 2

	thread TitanMoshPit_NPCsResumeFightingPlayer()

	FlagClear( busyFlag )
}

function Titan_OffensiveMelee()
{
	DisplayTrainingPrompt(eTrainingButtonPrompts.TITAN_OFFENSIVE_MELEE)

	local podSpawns = []
	podSpawns.append( { origin = Vector( 926, 3442, 6550 ), angles = Vector( 0, -50, 0 ) } )
	podSpawns.append( { origin = Vector( 894, 2930, 6550 ), angles = Vector( 0, -90, 0 ) } )
	podSpawns.append( { origin = Vector( 1406, 2930, 6400 ), angles = Vector( 0, -160, 0 ) } )
	podSpawns.append( { origin = Vector( 1534, 3442, 6400 ), angles = Vector( 0, 125, 0 ) } )
	podSpawns.append( { origin = Vector( 382, 3266, 6400 ), angles = Vector( 0, 30, 0 ) } )
	podSpawns.append( { origin = Vector( 574, 2946, 6450 ), angles = Vector( 0, 45, 0 ) } )

	if ( !( "moshPitSquads" in level ) )
		level.moshPitSquads <- {}

	foreach (idx, spawnpoint in podSpawns)
	{
		local squadName = "moshpit_droppod_squad_" + idx
		level.moshPitSquads[squadName] <- null

		thread MoshPit_LaunchGruntDropPod(squadName, spawnpoint)
	}

	OnThreadEnd(
		function() : ()
		{
			foreach (squad in level.moshPitSquads)
			{
				if (!squad)
					continue

				foreach (guy in squad)
				{
					if (IsAlive(guy))
						guy.Die()
				}
			}
		}
	)

	level.player.FreezeFireControlsOnServer()

	while (1)
	{
		local foundOne = false
		foreach (squad in level.moshPitSquads)
		{
			if (squad == null)
			{
				foundOne = true
				break
			}
		}

		if (!foundOne)
			break

		wait 0.1
	}

	local allGuys = []
	foreach (squad in level.moshPitSquads)
	{
		foreach (guy in squad)
			allGuys.append(guy)
	}

	while (1)
	{
		local foundOne = false
		local deathCount = 0

		foreach (guy in allGuys)
		{
			if (!IsAlive(guy))
				++deathCount
		}

		if (deathCount >= 16)
			break

		wait 0.1
	}

	level.player.UnfreezeFireControlsOnServer()

	HideTrainingPrompt()
}

function Titan_OffensiveOffhandTraining()
{
	FlagClear( "FiredOffhandOffensive" )
	level.player.GiveOffhandWeapon( TITAN_WEAPON_OFFHAND_OFFENSIVE, 0 )

	OnThreadEnd(
		function() : ()
		{
			if ( IsValid( level.player ) )
			{
				StopHintPulse()
				StopControllerImageHint()
			}
		}
	)

	FlagClear("ConversationOver")
	ForcePlayConversationToPlayer( "offhand_rocket_intro", level.player )

	if ( !Flag( "FiredOffhandOffensive" ) )
	{
		OffhandOffensiveHintPulse()
		ControllerImageHint_OffhandOffensive()

		FlagWait("ConversationOver")
		FlagClear("ConversationOver")
		ForcePlayConversationToPlayer( "offhand_rocket_fire_name", level.player )
	}

	if ( !Flag( "FiredOffhandOffensive" ) )
	{
		FlagWait("ConversationOver")
		FlagClear("ConversationOver")
		ForcePlayConversationToPlayer( "offhand_rocket_fire_direction", level.player )

		DisplayTrainingPrompt( eTrainingButtonPrompts.TITAN_OFFHAND_OFFENSIVE )

		waitthread NagPlayerUntilFlag( "FiredOffhandOffensive", "offhand_rocket_fire_direction", 20 )

		HideTrainingPrompt()
		StopHintPulse()
		StopControllerImageHint()
	}

	FlagWait("ConversationOver")
	FlagClear("ConversationOver")
	ForcePlayConversationToPlayer( "offhand_rocket_fire_finish", level.player )
	wait 5
}

function TitanMoshPit_Combat()
{
	FlagSet( "DisableTitanKneelingEmbark" )

	OnThreadEnd(
		function() : ()
		{
			FlagClear( "DisableTitanKneelingEmbark" )
		}
	)

	ForcePlayConversationToPlayer( "titan_mosh_intro", level.player )
	wait 2

	// refill player health
	level.player.SetHealth( level.player.GetMaxHealth() )

	// give loadout and infinite ammo
	local offensiveOffhand = level.player.GetOffhandWeapon( 0 )
	if ( !offensiveOffhand )
		level.player.GiveOffhandWeapon( TITAN_WEAPON_OFFHAND_OFFENSIVE, 0 )

	level.player.GiveOffhandWeapon( TITAN_WEAPON_OFFHAND_DEFENSIVE, 1 )
	thread RefillPlayerAmmo( level.player )

	wait 4

	ForcePlayConversationToPlayer( "titan_mosh_start", level.player )
	// 기존의 메세지 팝업창(생존, 최대한 버티세요.)을 아래 스레드 안으로 가져가기 위해 주석처리
	// DisplayTrainingPrompt( eTrainingButtonPrompts.TITAN_MOSH_PIT_SURVIVE )

	thread TitanMoshPit_SpawnTitans_OrForceStandDown( "CombatTestDone" )

	// wait until player is in doomed state
	while ( !level.player.GetDoomedState() )
		wait 0

	HideTrainingPrompt()

	FlagSet( "CombatTestDone" )

	thread TitanMoshPit_NPCsStandDown()
}

function TitanMoshPit_SpawnTitans_OrForceStandDown( endSig )
{
	level.ent.EndSignal( endSig )
	level.ent.EndSignal( "ModuleChanging" )
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )

	DisplayTrainingPrompt( eTrainingButtonPrompts.TITAN_MOSH_PIT_SURVIVE )

	for (local i = 0; i < 1; i++)
		thread TitanMoshPit_SpawnEnemyTitan(endSig, i, true, true, true, false, ATLAS_MODEL)

	while (1)
	{
		local foundOne = false
		
		foreach (titan in level.moshPitTitans)
		{
			if (IsAlive(titan))
			{
				foundOne = true
				break
			}
		}

		if (!foundOne)
			break

		wait 2
	}	

	// 기존의 '생존' 메세지 노출 없애기
	HideTrainingPrompt()

	level.moshPitTitans = [];
	local soul = level.player.GetTitanSoul()
	soul.SetShieldHealth(soul.GetShieldHealthMax())

	ForcePlayConversationToPlayer( "titan_mosh_wave_survived", level.player )
	wait 8

	ForcePlayConversationToPlayer( "titan_mosh_wave_start", level.player )
	wait 2

	// 튜토리얼용 '비상사태' 메세지 출력
	DisplayTrainingPrompt( eTrainingButtonPrompts.TITAN_MOSH_PIT_EMERGENCY )

	for (local i = 0; i < 3; i++)
		thread TitanMoshPit_SpawnEnemyTitan(endSig, i, true, true, true, true, DESTROYER_MODEL)

	while (1)
	{
		local foundOne = false
		
		foreach (titan in level.moshPitTitans)
		{
			if (IsAlive(titan))
			{
				foundOne = true
				break
			}
		}

		if (!foundOne)
			break

		wait 2
	}		
}

function ForceDoomedState()
{
	Assert( level.player.IsTitan() )

	level.player.DisableDemigod()

	local soul = level.player.GetTitanSoul()

	soul.SetShieldHealth( 0 )
	level.player.TakeDamage( level.player.GetHealth() + 1, null, null, { damageSourceId=eDamageSourceId.suicide } )
}

function InvincibleTitan(titan)
{
	while(1)
	{
		titan.SetHealth(titan.GetMaxHealth())

		wait 0
	}
}

function TitanMoshPit_SpawnEnemyTitan(endSig, idxInSpawnGroup, giveShield, giveVortex, doRandWeapons, invincible, model)
{
	level.ent.EndSignal( endSig )
	level.ent.EndSignal( "ModuleChanging" )
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )

	local startTime = Time()
	local spawnpoint = TitanMoshPit_GetBestTitanSpawn(idxInSpawnGroup)
	local spawnOrg = spawnpoint.origin
	local spawnAng = spawnpoint.angles
	local oppTeam = GetOppositeTeam( level.player )
	local alert = 1
	local titan = NPE_SpawnTitan(oppTeam, spawnOrg, spawnAng, alert, doRandWeapons, "mp_titanweapon_xo16", model)
	titan.s.isHotDropping <- true
	level.moshPitTitans.append( titan )

	titan.SetTitle( "#NPC_TITAN_TRAINING" )
	DisableRodeo( titan )

	if ( !giveShield )
		DisableTitanShield( titan )

	if ( !giveVortex )
		titan.TakeOffhandWeapon( 1 )

	titan.Minimap_AlwaysShow( level.player.GetTeam(), level.player )

	waitthread SuperHotDropGenericTitan( titan, spawnOrg, spawnAng )
	titan.s.isHotDropping = false

	if (invincible)
		thread InvincibleTitan(titan)

	thread MoshPit_NPC_FightPlayer( titan )
}

function TitanMoshPit_GetBestTitanSpawn(idx)
{
	if ( !( "moshPitTitanSpawns" in level ) )
	{
		level.moshPitTitanSpawns <- []
		level.moshPitTitanSpawns.append( { origin = OriginToGround( Vector( 876.222, 3413.73, 6590.57 ) ), angles = Vector( 0, -142.022, 0 ) } )
		level.moshPitTitanSpawns.append( { origin = OriginToGround( Vector( 2204.86, 3212.06, 6496.67 ) ), angles = Vector( 0, 167.431, 0 ) } )
		level.moshPitTitanSpawns.append( { origin = OriginToGround( Vector( 2355.67, 1046.02, 6478.31 ) ), angles = Vector( 0, 134.641, 0 ) } )
		level.moshPitTitanSpawns.append( { origin = OriginToGround( Vector( 886.44, 687.81, 6492.99 ) ), angles = Vector( 0, 162.233, 0 ) } )
		level.moshPitTitanSpawns.append( { origin = OriginToGround( Vector( -1325.17, 1287.77, 6470.94 ) ), angles = Vector( 0, 41.3458, 0 ) } )
		level.moshPitTitanSpawns.append( { origin = OriginToGround( Vector( -29.9723, 3779.67, 6458.22 ) ), angles = Vector( 0, -95.2431, 0 ) } )
	}

	return level.moshPitTitanSpawns[idx]
}


function Titan_TrainEject()
{
	FlagClear( "PlayerEjected" )

	local playertitan = GetPlayerTitanInMap( level.player )
	GivePassive( playertitan, PAS_NUCLEAR_CORE )

	thread CatchPlayerEject()

	// set player invincible again
	level.player.EnableDemigod()

	if ( level.player.IsTitan() )
	{
		ForcePlayConversationToPlayer( "titan_doomed_info", level.player )
		wait 9
	}

	if ( level.player.IsTitan() )
	{
		ForcePlayConversationToPlayer( "titan_infinite_doomed_info", level.player )
	}

	if ( level.player.IsTitan() )
	{
		FlagWait("ConversationOver")
		FlagClear("ConversationOver")
		DisplayTrainingPrompt( eTrainingButtonPrompts.EJECT_CONFIRM )
		ForcePlayConversationToPlayer( "titan_doomed_eject", level.player )
		wait 5
	}

	if ( level.player.IsTitan() )
	{
		waitthread NagPlayerUntilFlag( "PlayerEjected", "titan_eject_nag", 15 )
	}

	// -- PLAYER PUNCHED OUT --

	HideTrainingPrompt()

	local minWaitEnd = 5 + Time()
		ForcePlayConversationToPlayer( "titan_eject_in_air", level.player )

	while ( !level.player.IsOnGround() )
		wait 0.2

	// let the VO finish playing
	if ( Time() < minWaitEnd )
		wait minWaitEnd - Time()
}

function CatchPlayerEject()
{
	level.ent.EndSignal( "ModuleChanging" )
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )

	while ( level.player.IsTitan() )
		wait 0.1

	FlagSet( "PlayerEjected" )
}


// =========================== CALLBACKS & MISC FUNCTIONS ===========================
function ControllerImageHint_Sprint()
{
	Remote.CallFunction_Replay( level.player, "ControllerImageHint_Sprint" )
}

function ControllerImageHint_Melee()
{
	Remote.CallFunction_Replay( level.player, "ControllerImageHint_Melee" )
}

function ControllerImageHint_OffhandDefensive()
{
	Remote.CallFunction_Replay( level.player, "ControllerImageHint_OffhandDefensive" )
}

function ControllerImageHint_OffhandOffensive()
{
	Remote.CallFunction_Replay( level.player, "ControllerImageHint_OffhandOffensive" )
}

function ControllerImageHint_DPad_Left()
{
	Remote.CallFunction_Replay( level.player, "ControllerImageHint_DPad", 0 )
}

function ControllerImageHint_DPad_Down()
{
	Remote.CallFunction_Replay( level.player, "ControllerImageHint_DPad", 1 )
}

function StopControllerImageHint()
{
	Remote.CallFunction_Replay( level.player, "StopControllerImageHint" )
}

function CloakHintPulse()
{
	Remote.CallFunction_Replay( level.player, "HUDHintPulse", 0 )
}

function OffhandOffensiveHintPulse()
{
	Remote.CallFunction_Replay( level.player, "HUDHintPulse", 1 )
}

function DashMeterHintPulse()
{
	Remote.CallFunction_Replay( level.player, "HUDHintPulse", 2 )
}

function TitanAIControlHintPulse()
{
	Remote.CallFunction_Replay( level.player, "HUDHintPulse", 3 )
}

function StopHintPulse()
{
	Remote.CallFunction_Replay( level.player, "StopHintPulse" )
}

function HighlightMinimap()
{
	Remote.CallFunction_Replay( level.player, "HighlightMinimap" )
}

function StopHighlightMinimap()
{
	Remote.CallFunction_Replay( level.player, "StopHighlightMinimap" )
}

function CleanupCorpses( delay = 0 )
{
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )

	if ( delay > 0 )
		wait delay

	Remote.CallFunction_Replay( level.player, "ServerCallback_CleanupCorpses" )
}

function WaittillTime( minWaitEnd )
{
	if ( Time() < minWaitEnd )
		wait ( minWaitEnd - Time() )
}

function EmitSoundOnEntity_Delayed( ent, alias, delay )
{
	ent.EndSignal( "OnDeath" )
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )

	if ( delay > 0 )
		wait delay

	EmitSoundOnEntity( ent, alias )
}

function PlayFXOnEntity_Delayed( alias, entity, delay )
{
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )
	entity.EndSignal( "OnDeath" )

	wait delay

	PlayFXOnEntity( alias, entity )
}

function MoveTo_Delayed( delay, moveEnt, movePos, moveTime, accel, decel )
{
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )
	moveEnt.EndSignal( "OnDeath" )

	wait delay

	moveEnt.MoveTo( movePos, moveTime, accel, decel )
}

function FireRocketsUntilSignal( rocketSpots, rocketSpeed, volleyWait, endSig, lightTrigTN = null )
{
	level.player.EndSignal( "OnDeath" )
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )
	level.ent.EndSignal( endSig )

	local oppTeam = GetOppositeTeam( level.player )
	//local rocketWait = 0.1

	if ( lightTrigTN )
		LightTrigger_On( lightTrigTN, FX_LIGHT_GREEN )

	OnThreadEnd(
		function() : ( lightTrigTN )
		{
			if ( lightTrigTN && IsValid( lightTrigTN ) )
			{
				LightTrigger_Off( lightTrigTN )
			}
		}
	)

	while ( 1 )
	{
		foreach ( idx, spot in rocketSpots )
		{
			local rocket = NPE_SpawnRocket( spot.origin, spot.angles, level, oppTeam, rocketSpeed )
			thread RocketSeekPlayer( rocket, rocketSpeed )
			level.dashRockets.append( rocket )

			//if ( ( idx + 1 ) % 2 == 0 )
			//	wait rocketWait
		}

		wait volleyWait
	}
}

function NPE_SpawnRocket( spawnPos, spawnAng, owner, team, rocketSpeed )
{
	local rocket = CreateEntity( "rpg_missile" )
	rocket.SetOrigin( spawnPos )
	rocket.SetAngles( spawnAng )
	rocket.SetOwner( owner )
	rocket.SetTeam( team )
	rocket.SetModel( "models/weapons/bullets/projectile_rocket.mdl" )
	rocket.SetImpactEffectTable( level.trainingRocketEffectTable )
	rocket.SetWeaponClassName( "mp_projectile_orbital_strike" )
	rocket.SetSpeed( rocketSpeed )
	rocket.kv.damageSourceId = eDamageSourceId.mp_titanweapon_orbital_strike
	DispatchSpawn( rocket )

	EmitSoundAtPosition( spawnPos, "Weapon_Archer.Fire" )

	return rocket
}

function GetScriptPos( player = null )
{
	if ( !player )
		player = level.player

	local pos = player.GetOrigin()
	local ang = player.GetAngles()

	local returnStr = "Vector( " + pos.x + ", " + pos.y + ", " + pos.z + " ), Vector( 0, " + ang.y + ", 0 )"
	return returnStr
}

function TakeAmmoFromPlayerASAP()
{
	level.player.EndSignal( "OnDeath" )
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )

	local weapon = null
	while ( !weapon )
	{
		weapon = level.player.GetActiveWeapon()
		if ( !weapon )
			wait 0.1
	}

	level.player.SetActiveWeaponPrimaryAmmoTotal( 0 )
	level.player.SetActiveWeaponPrimaryAmmoLoaded( 0 )
}

function DisplayTrainingPrompt( promptID )
{
	level.lastTrainingPrompt = promptID

	Remote.CallFunction_Replay( level.player, "ServerCallback_DisplayTrainingPrompt", promptID )
}

function HideTrainingPrompt()
{
	Remote.CallFunction_Replay( level.player, "ServerCallback_HideTrainingPrompt" )
}

function NPE_GrenadeCreatedCallback( ent )
{
	if ( ent.GetOwner() != level.player )
		return

	level.grenadesThrown++
}

function NPE_GroundTroopsDeathCallback( guy, damageInfo )
{
	TryTakeWeaponOnDeath( guy )

	local dmgSourceID = damageInfo.GetDamageSourceIdentifier()
    if ( dmgSourceID != eDamageSourceId.mp_weapon_smart_pistol )
		FlagSet( "NotKilledUsingSmartPistol" )
	else
	{
		local weapon = damageInfo.GetWeapon()

		if ( IsValid( weapon ) )
			level.lastSmartPistolTargs = weapon.SmartAmmo_GetTargets()
	}

	/*
	if ( !( damageInfo.GetDamageType() & DF_HEADSHOT ) )
	{
		printt( "Not a headshot!")
		FlagSet( "NonHeadshot" )
	}
	else
	{
		printt( "Headshot!")
	}
	*/

	EmitSoundAtPosition( guy.GetOrigin(), "Object_Dissolve" )
	guy.Dissolve( ENTITY_DISSOLVE_CHAR, Vector( 0, 0, 0 ), 0 )
}

function TryTakeWeaponOnDeath( guy )
{
	if ( !( "dontDropWeapon" in guy.s ) )
		return

	local activeWeapon = guy.GetActiveWeapon()
	if ( activeWeapon )
		guy.TakeWeapon( activeWeapon.GetClassname() )
}

function ClientCommand_LookTarget_Top( player, ... )
{
	level.player.ResetIdleTimer()
	FlagSet( "PlayerLookedAtTopTarget" )
	return true
}

function ClientCommand_LookTarget_Bottom( player, ... )
{
	level.player.ResetIdleTimer()
	FlagSet( "PlayerLookedAtBottomTarget" )
	return true
}

function ClientCommand_NPE_LookWasInverted( player, ... )
{
	level.player.ResetIdleTimer()
	level.ent.Signal( "PlayerInvertedLook" )
	return true
}

function ClientCommand_NPE_NoButtonClicked( player, ... )
{
	level.player.ResetIdleTimer()
	//printt( "clicked no button" )
	level.ent.Signal( "PlayerClickedNoButton" )
	return true
}

function ClientCommand_NPE_StartBedEndModule( player, ... ) 
{
	if (GAMETYPE == "tutorial")
		thread StartTrainingModule( TRAINING_BEDROOM_END/*eTrainingModules.BEDROOM_END*/ )
	else 
		GameRules.EndMatch()		
}

function ClientCommand_NPE_StartTitanMoshPitModule( player, ... )
{
	thread StartTrainingModule( TRAINING_TITAN_MOSH_PIT/*eTrainingModules.TITAN_MOSH_PIT*/ )
}

function ClientCommand_NPE_ConfirmInvertYes( player, ... )
{
	level.player.ResetIdleTimer()
	level.ent.Signal( "InvertSettingsConfirmed" )
	return true
}

function ClientCommand_NPE_PlayerReloaded( player, ... )
{
	FlagSet( "PlayerReloaded" )
	return true
}

function ClientCommand_NPE_PlayerPressedPrimaryWeapon( player, ... )
{
	FlagSet("PlayerPressedPrimaryWeapon");
	return true;
}

function ClientCommand_NPE_PlayerPressedUse( player, ... )
{
	FlagSet( "PlayerPressedUse" )
	return true
}

function ClientCommand_NPE_FiredOffhandOffensive( player, ... )
{
	FlagSet( "FiredOffhandOffensive" )
	return true
}

function ClientCommand_NPE_PlayerPressedJump( player, ... )
{
	FlagSet( "PlayerPressedJump" )
	return true
}

function ClientCommand_NPE_PressedWeaponSwitch( player, ... )
{
	FlagSet( "PlayerPressedWeaponSwitchButton" )
	return true
}

function ClientCommand_NPE_DashMeterLow( player, ... )
{
	FlagSet( "PlayerDashMeterLow" )
	return true
}

function ClientCommand_NPE_DashMeterReady( player, ... )
{
	FlagClear( "PlayerDashMeterLow" )
	return true
}

function ClientCommand_NPE_PlayerDashed( player, ... )
{
	//printt( "SERVER Setting PlayerDashed" )
	FlagSet( "PlayerDashed" )
	thread ClearDashFlagAfterTime( player )
	return true
}

function ClearDashFlagAfterTime( player )
{
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "PlayerDashed" )

	wait 1
	//printt( "SERVER Clearing PlayerDashed" )
	FlagClear( "PlayerDashed" )
}

function ClientCommand_CallConversationOverSignal( player, ... )
{
	FlagSet("ConversationOver")
}

function ClientCommand_CallConversationOverEndSignal( player, ... )
{
	FlagClear("ConversationOver")
}

// when players select "Skip Training" from the menu
function ClientCommand_LeaveTraining( player, ... )
{
	// if in cabin start or end, go right to lobby
	if ( level.currentTrainingModule == TRAINING_BEDROOM/*eTrainingModules.BEDROOM*/ || level.currentTrainingModule == TRAINING_BEDROOM_END/*eTrainingModules.BEDROOM_END*/ )
	{
		if ( IsValid( level.player ) )  // defensive
			MuteAll( level.player, 1.0 )

		ReturnToLobby()
		return true
	}

	// otherwise go to end cabin to see end scripting
	if (GAMETYPE == "tutorial")
		thread StartTrainingModule( TRAINING_BEDROOM_END/*eTrainingModules.BEDROOM_END*/ )
	else 
		GameRules.EndMatch()

	return true
}

function ShowMinimap()
{
	level.nv.minimapState = eMinimapState.Default
}

function HideMinimap()
{
	level.nv.minimapState = eMinimapState.Hidden
}

function ReturnToLobby()
{
	printt( "returning to lobby" )
	Remote.CallFunction_UI( level.player, "ServerCallback_EndTraining" )
}

function NagPlayerUntilFlag( flagName, nagAlias, nagInterval = 20, trainingPromptID = null, useTempConversation = null )
{
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )

	local nextNagTime = Time() + nagInterval
	while ( !Flag( flagName ) )
	{
		if ( Time() > nextNagTime )
		{
			if ( trainingPromptID != null )
				DisplayTrainingPrompt( trainingPromptID )

			if ( useTempConversation )
				PlayTempConversationToPlayer( nagAlias, level.player )
			else
				ForcePlayConversationToPlayer( nagAlias, level.player )

			nextNagTime = Time() + nagInterval
		}

		wait 0.1
	}
}

function NagPlayerUntilGuysAreDead( guys, nagAlias, nagInterval = 20, trainingPromptID = null )
{
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )

	if ( !guys.len() )
	{
		printt( "NagPlayerUntilGuysAreDead: everyone is dead at the start, returning" )
		return
	}

	FlagClear( "NagFlag" )

	thread NagPlayerUntilFlag( "NagFlag", nagAlias, nagInterval, trainingPromptID )

	waitthread( WaitUntilGuysAreDead( guys ) )

	FlagSet( "NagFlag" )
}

function WaitUntilGuysAreDead( guys )
{
	if ( !guys.len() )
	{
		printt( "WaitUntilGuysAreDead: everyone is dead at the start, returning" )
		return
	}

	while( 1 )
	{
		local foundOne = false

		foreach ( guy in guys )
		{
			if ( IsAlive( guy ) )
			{
				foundOne = true
				break
			}
		}

		if ( !foundOne )
			break

		wait 0.1
	}
}

function NagPlayerUntilPlayerMove2D( distToMove, nagAlias, nagInterval = 20, trainingPromptID = null )
{
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )

	local ogPos = level.player.GetOrigin()

	FlagClear( "NagFlag" )

	thread NagPlayerUntilFlag( "NagFlag", nagAlias, nagInterval, trainingPromptID )

	while ( Distance2D( ogPos, level.player.GetOrigin() ) < distToMove )
		wait 0.1

	FlagSet( "NagFlag" )
}

function WaitForPlayerActiveWeapon( className = null )
{
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )

	local weapon = null

	while ( 1 )
	{
		wait 0
		weapon = level.player.GetActiveWeapon()

		if( weapon )
		{
			if( className )
			{
				if ( weapon.GetClassname() == className )
					break;
			}
			else
				break;
		}
	}

	return weapon
}

function SpawnDumbNPC( npcType, spawnOrg, spawnAng, shouldDropWeapon = false, squadName = null )
{
	Assert( npcType == "grunt" || npcType == "spectre" || npcType == "titan" )

	local spawnTeam = GetOppositeTeam( level.player )
	local alert = false

	if ( squadName == null )
		squadName = "training_guys"

	local npc = null
	if ( npcType == "grunt" )
		npc = SpawnGrunt( spawnTeam, squadName, spawnOrg, spawnAng, alert )
	else if ( npcType == "spectre" )
		npc = SpawnSpectre( spawnTeam, squadName, spawnOrg, spawnAng, alert )
	else
		npc = NPE_SpawnTitan( spawnTeam, spawnOrg, spawnAng, alert )

	if ( npcType == "spectre" )
		DisableLeeching( npc )

	npc.kv.reactChance = 0
	npc.kv.reactFriendlyChance = 0
	npc.SetEfficientMode( true )

	if ( !shouldDropWeapon )
		npc.s.dontDropWeapon <- 1

	return npc
}

function NPE_SpawnTitan(spawnTeam, org, ang, alert, doRandWeapons = false, defaultWeapon = "mp_titanweapon_xo16", model = null)
{
	local weapon = defaultWeapon

	if (doRandWeapons)
	{
		local randWeaps = []
		randWeaps.append( "mp_titanweapon_xo16" )
		randWeaps.append( "mp_titanweapon_40mm" )
		randWeaps.append( "mp_titanweapon_rocket_launcher" )

		weapon = Random( randWeaps )
	}

	local table 	= CreateDefaultNPCTitanTemplate( spawnTeam )
	table.title 	= "#NPC_TITAN_TRAINING"
	table.weapon	= weapon
	table.origin 	= org
	table.angles 	= ang

	if (model)
		table.model	= model
	local titan = SpawnNPCTitan( table )
	local alertVal = alert ? 1 : 0
	titan.kv.alwaysalert = alertVal

	return titan
}

function NPC_StandDown( npc )
{
	if ( !IsAlive( npc ) )
		return

	if ( npc.IsTitan() && ( "isHotDropping" in npc.s ) && npc.s.isHotDropping )
		while ( npc.s.isHotDropping )
			wait 0

	thread NPE_NPCStayPut( npc )

	if ( !( "ogLookDist" in npc.s ) )
		npc.s.ogLookDist <- null

	npc.s.ogLookDist = npc.GetLookDist()
	npc.SetLookDist( 0 )

	// Titans play kneel anim
	if ( npc.IsTitan() )
		thread PlayTitanAnimSafe( npc, "at_MP_embark_idle_blended" )
}

function NPC_StandDown_Stop( npc, waitForAnimDone = false )
{
	if ( !IsAlive( npc ) )
		return

	npc.Signal( "StandDown_Change" )
	npc.DisableBehavior( "Assault" )
	npc.StayPut( false )

	if ( "ogLookDist" in npc.s )
		npc.SetLookDist( npc.s.ogLookDist )

	// Titan get back up
	if ( npc.IsTitan() )
		thread PlayTitanAnimSafe( npc, "at_MP_embark_fast" )
}

function PlayTitanAnimSafe( titan, anim )
{
	titan.Signal( "PlayTitanAnimSafe_Start" )
	titan.EndSignal( "PlayTitanAnimSafe_Start" )

	titan.EndSignal( "OnDeath" )
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )

	while ( titan.ContextAction_IsActive() )
		wait 0

	thread PlayAnim( titan, anim )
}

function NPE_NPCStayPut( npc, origin = null, angles = null )
{
	npc.EndSignal( "OnDeath" )
	npc.EndSignal( "StandDown_Change" )

	while ( !npc.IsOnGround() )
		wait 0

	npc.DisableBehavior( "Assault" )

	if ( !( "ap" in npc.s ) )
		npc.s.ap <- CreateStrictAssaultEnt( npc.GetOrigin(), npc.GetAngles() )

	local stayOrg = npc.GetOrigin()
	local stayAng = npc.GetAngles()

	if ( origin )
		stayOrg = origin

	if ( angles )
		stayAng = angles

	npc.s.ap.SetOrigin( stayOrg )
	npc.s.ap.SetAngles( stayAng )
	npc.AssaultPointEnt( npc.s.ap )

	if ( npc.IsSoldier() )
		npc.s.ap.kv.forcecrouch = 1

	npc.WaitSignal( "OnFinishedAssault" )
	npc.StayPut( true )
}

function CreatePlayerAssaultEnt()
{
	level.player.s.playerAssaultEnt <- CreateStrictAssaultEnt( level.player.GetOrigin(), level.player.GetAngles(), 250 )
	level.player.s.playerAssaultEnt.kv.forcecrouch = 0
	thread UpdatePlayerAssaultEnt()
}

function UpdatePlayerAssaultEnt()
{
	level.player.s.playerAssaultEnt.EndSignal( "OnDeath" )
	level.player.EndSignal( "OnDeath" )
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )

	local newPos
	local lastPos = level.player.s.playerAssaultEnt.GetOrigin()
	while( 1 )
	{
		newPos = level.player.GetOrigin()

		if ( Distance( newPos, lastPos ) > 64 )
		{
			//printt( "moving player assault ent" )
			level.player.s.playerAssaultEnt.SetOrigin( newPos )
			lastPos = newPos
		}

		wait 2.0
	}
}

function GetOppositeTeam( ent )
{
	local oppTeam = TEAM_IMC
	if ( ent.GetTeam() == TEAM_IMC )
		oppTeam = TEAM_MILITIA

	return oppTeam
}

function TeleportPlayer( targetOrg, targetAng, doTeleportFX = true, doInstantTeleport = false )
{
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )

	level.ent.Signal( "TeleportingPlayer" )
	level.ent.EndSignal( "TeleportingPlayer" )
	level.ent.EndSignal( "ModuleChanging" )

	FlagSet( "PlayerIsTeleporting" )

	if ( doTeleportFX )
		Remote.CallFunction_Replay( level.player, "ServerCallback_TrainingTeleport" )

	level.player.ResetIdleTimer()

	OnThreadEnd(
		function() : ()
		{
			if ( IsValid( level.player ) )
			{
				Remote.CallFunction_Replay( level.player, "ServerCallback_SetFreezePlayerControls", false )
				FlagClear( "PlayerIsTeleporting" )
			}
		}
	)

	if ( !doInstantTeleport )
		wait 0.25  // small wait before freezing feels good

	level.player.FreezeControlsOnServer( false )
	Remote.CallFunction_Replay( level.player, "ServerCallback_SetFreezePlayerControls", true )

	wait 0.1

	level.player.SetOrigin( targetOrg )
	level.player.SetAngles( targetAng )
	level.player.ForceStand()
	wait 0.1

	level.player.UnforceStand()
	level.player.UnfreezeControlsOnServer()

	level.player.Signal( "Teleported" )
	level.ent.Signal( "TeleportedPlayer" )  // so we can do combo waitsignals on the level.ent
}

function LockPlayerMovement( player )
{
	if ( "movementLocked" in player.s )
		return

	local sequence = CreateFirstPersonSequence()
	sequence.thirdPersonAnim = "UseTurretIdle" //"ref"
	sequence.attachment = "ref"
	sequence.blendTime = 0.0
	sequence.viewConeFunction = PlayerLockViewCone

	player.s.movementLocked <- 1

	thread FirstPersonSequence( sequence, player )
}

function UnlockPlayerMovement( player )
{
	if ( !( "movementLocked" in player.s ) )
		return

	delete player.s.movementLocked
	player.Anim_Stop()
}

function PlayerLockViewCone( player )
{
	player.PlayerCone_FromAnim()
	player.PlayerCone_SetMinYaw( -70 )
	player.PlayerCone_SetMaxYaw( 60 )
	player.PlayerCone_SetMinPitch( -80 )
	player.PlayerCone_SetMaxPitch( 30 )
}

function RefillOffhandAmmoUntilSignal( weapon, endSig, loopTime = 0.1 )
{
	level.ent.EndSignal( "StopRefillingOffhandWeapons" )
	level.ent.EndSignal( "ModuleChanging" )
	level.player.EndSignal( "OnDestroy" )
	level.player.EndSignal( "Disconnected" )
	weapon.EndSignal( "OnDestroy" )
	level.ent.EndSignal( endSig )

	local maxAmmoClip = weapon.GetWeaponPrimaryClipCount()

	while ( 1 )
	{
		local currAmmo = level.player.GetWeaponAmmoLoaded( weapon )
		if ( currAmmo <= 0 )
		{
			weapon.SetWeaponPrimaryClipCount( maxAmmoClip )
		}

		wait loopTime
	}
}

function RefillPlayerAmmo( player, classnameFilter = null )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )
	level.ent.EndSignal( "StopRefillingPlayerAmmo" )

	local refillThreshold = 0.98
	local weapon
	local maxAmmoMag

	while ( 1 )
	{
		wait 0.5

		weapon = level.player.GetActiveWeapon()

		if ( !weapon )
			continue

		if ( classnameFilter && weapon.GetClassname() != classnameFilter )
			continue

		maxAmmoMag = level.player.GetWeaponAmmoMaxLoaded( weapon )

		if ( player.GetWeaponAmmoStockpile( weapon ) == 0 )  // doesn't count ammo in the mag
			weapon.SetWeaponPrimaryAmmoCount( maxAmmoMag * 2 )  // give him 2 mags worth
	}
}

function DisablePilotHud()
{
	AddCinematicFlag( level.player, CE_FLAG_INTRO )
}

function EnablePilotHud()
{
	RemoveCinematicFlag( level.player, CE_FLAG_INTRO )
}

function EnableTitanDisembark()
{
	if ( !level.titanDisembarkDisabled )
		return

	Remote.CallFunction_Replay( level.player, "ServerCallback_EnableTitanDisembark" )
	level.titanDisembarkDisabled = null
}

//check
function DisableTitanDisembark()
{
	if ( level.titanDisembarkDisabled )
		return

	Remote.CallFunction_Replay( level.player, "ServerCallback_DisableTitanDisembark" )
	level.titanDisembarkDisabled = true
}

/*
//check
function ClientCommand_SetTrainingHasEverFinished( player, training_hasEverFinished )
{
	local intVal = SanitizeClientCommandInput( training_hasEverFinished )
	if ( intVal == null )
		return false

	level.training_hasEverFinished = intVal
	return true
}
*/

/*
//check
function ClientCommand_SetTrainingHasEverBeenStarted( player, training_hasEverBeenStarted )
{
	local intVal = SanitizeClientCommandInput( training_hasEverBeenStarted )
	if ( intVal == null )
		return false

	level.training_hasEverBeenStarted = intVal
	return true
}
*/

/*
//check
function ClientCommand_ResumeChoice( player, resumeChoice )
{
	local intVal = SanitizeClientCommandInput( resumeChoice )
	if ( intVal == null )
		return false

	level.resumeChoice = intVal
	return true
}
*/

//check
function SanitizeClientCommandInput( inputStr )
{
	// Need to do this so people can't use our client commands for evil
	if ( inputStr == null )
		return inputStr

	// tointeger returns null if it's operating on a string
	local intVal = inputStr.tointeger()

	return intVal
}

main()
