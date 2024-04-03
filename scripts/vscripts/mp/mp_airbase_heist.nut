

const INTROCUSTOMLENGTH_TDM = 24.5
const INTROCUSTOMLENGTH_CP = 8
const LEVIATHAN_SMALL_MODEL = "models/Creatures/leviathan/leviathan_brown_airbase_small.mdl"
const LEVIATHAN_MEDIUM_MODEL = "models/Creatures/leviathan/leviathan_brown_airbase_medium.mdl"
const LEVIATHAN_LARGE_MODEL = "models/Creatures/leviathan/leviathan_brown_airbase_large.mdl"
const TOWER_SKYBOX_MODEL = "models/IMC_base/worker_base_whistle_tower_skybox.mdl"
const IMC_CARRIER_MODEL = "models/vehicle/imc_carrier/imc_carrier_airbase.mdl"
const RADAR_A_MODEL = "models/IMC_base/radar_a.mdl"
const RADAR_B_MODEL = "models/IMC_base/radar_b.mdl"
const RADAR_C_MODEL = "models/IMC_base/radar_c.mdl"
const RADAR_D_MODEL = "models/IMC_base/radar_d.mdl"
const RADAR_E_MODEL = "models/IMC_base/radar_e.mdl"
const RADAR_F_MODEL = "models/IMC_base/radar_f.mdl"
const RADAR_G_MODEL = "models/IMC_base/radar_g.mdl"
const RADAR_H_MODEL = "models/IMC_base/radar_h.mdl"
const RADAR_I_MODEL = "models/IMC_base/radar_i.mdl"
const RADAR_A_SKYBOX_MODEL = "models/IMC_base/radar_a_skybox.mdl"
const RADAR_B_SKYBOX_MODEL = "models/IMC_base/radar_b_skybox.mdl"
const RADAR_C_SKYBOX_MODEL = "models/IMC_base/radar_c_skybox.mdl"
const RADAR_D_SKYBOX_MODEL = "models/IMC_base/radar_d_skybox.mdl"
const RADAR_E_SKYBOX_MODEL = "models/IMC_base/radar_e_skybox.mdl"
const RADAR_F_SKYBOX_MODEL = "models/IMC_base/radar_f_skybox.mdl"
const RADAR_G_SKYBOX_MODEL = "models/IMC_base/radar_g_skybox.mdl"
const RADAR_H_SKYBOX_MODEL = "models/IMC_base/radar_h_skybox.mdl"
const RADAR_I_SKYBOX_MODEL = "models/IMC_base/radar_i_skybox.mdl"
const STRATON_MODEL = "models/vehicle/straton/straton_imc_gunship_01.mdl"
const STRATON_SKYBOX_MODEL = "models/vehicle/straton/straton_imc_gunship_01_1000x.mdl"
const STRATON_SKYBOX_PARKED_MODEL = "models/vistas/straton_single01.mdl"
const BOMBER_SKYBOX_PARKED_MODEL = "models/vistas/bomber_single01.mdl"
const GOBLIN_DROPSHIP_MODEL = "models/vehicle/goblin_dropship/goblin_dropship.mdl"
const BOMBER_MODEL = "models/vehicle/imc_bomber/bomber.mdl"
const WALLACE_MODEL = "models/vehicle/capital_ship_wallace/capital_ship_wallace_1000x.mdl"

const SARAH_MODEL = "models/humans/mcor_hero/sarah/mcor_hero_sarah.mdl"
const PILOT_MODEL = "models/humans/mcor_grunt/battle_rifle/mcor_grunt_battle_rifle.mdl"
const LAPTOP_MODEL_SMALL = "models/communication/terminal_usable_airbase.mdl"
const GUN_MODEL = "models/weapons/p2011/p2011_handgun_ab_01.mdl"
const BOMBER_MODEL = "models/vehicle/imc_bomber/bomber.mdl"
const GUNRACK_MODEL = "models/industrial/gun_rack_arm_down.mdl"

const TOWER_PULSE_FX = "P_dog_w_pulse_st_idle"
const TOWER_SKYBOX_PULSE_FX = "P_dog_w_pulse_st_idle_SB"
const SHIP_CRUSH_FX = "P_veh_gunship_exp_SB"
const LEVIATHAN_SPOTLIGHT_FX = "P_lev_spotlight"

function main()
{
	IncludeFile( "_flyers_shared" )
	IncludeFileAllowMultipleLoads( "mp/_vehicle_gunship" )

	if ( reloadingScripts )
		return

	PrecacheModel( "models/IMC_base/imc_tech_tallpanel_48_02.mdl" )

	GM_AddEndRoundFunc( EndRoundMain )

	level.isCinematicMode <- GetCinematicMode()

	if ( level.isCinematicMode )
	{
		FlagSet( "CinematicIntro" )
		level.levelSpecificChatterFunc = AirBaseSpecificChatter
		if ( IsCaptureMode() )
		{
			IncludeFile( "mp/mp_airbase_cp" )
			FlagSet( "Cinematic_IMCSpawnOnGround" )
			FlagSet( "Cinematic_MilitiaSpawnOnGround" )
			SetCustomIntroLength( INTROCUSTOMLENGTH_CP )

		}
		else
		{
			IncludeFile( "mp/mp_airbase_tdm" )
			FlagSet( "Cinematic_IMCSpawnOnGround" )
			SetCustomIntroLength( INTROCUSTOMLENGTH_TDM )

			//SetGameWonAnnouncement( "airbase_won_announcement" )
			//SetGameLostAnnouncement( "airbase_lost_announcement" )
			SetGameModeAnnouncement( "airbase_game_mode_announce_at" )
		}
	}
	else
		FlagSet( "IntroDone" )

	RegisterServerVarChangeCallback( "matchProgress", MatchProgressChanged )

	FlagSet( "FlyerPickupAnalysis" )

	RegisterSignal( "leviathan_spotlight_stop" )
	RegisterSignal( "tower_down" )
	RegisterSignal( "BurnDamage" )
	RegisterSignal( "RunToAnimStartForcedTimeOut" )

	level.skyboxCamOrigin <- Vector( -10688.0, 7584.0, -6400.0 )
	level.progressEnabled <- true
	level.progressFuncArray <- []
	level.IMCTitans <- []
	level.MCORTitans <- []

	level.defenseTeam = TEAM_MILITIA

	PrecacheModel( GRAVES_MODEL )
	PrecacheModel( LEVIATHAN_SMALL_MODEL )
	PrecacheModel( LEVIATHAN_MEDIUM_MODEL )
	PrecacheModel( LEVIATHAN_LARGE_MODEL )
	PrecacheModel( TOWER_SKYBOX_MODEL )
	PrecacheModel( IMC_CARRIER_MODEL )
	PrecacheModel( RADAR_A_MODEL )
	PrecacheModel( RADAR_B_MODEL )
	PrecacheModel( RADAR_C_MODEL )
	PrecacheModel( RADAR_D_MODEL )
	PrecacheModel( RADAR_E_MODEL )
	PrecacheModel( RADAR_F_MODEL )
	PrecacheModel( RADAR_G_MODEL )
	PrecacheModel( RADAR_H_MODEL )
	PrecacheModel( RADAR_I_MODEL )
	PrecacheModel( RADAR_A_SKYBOX_MODEL )
	PrecacheModel( RADAR_B_SKYBOX_MODEL )
	PrecacheModel( RADAR_C_SKYBOX_MODEL )
	PrecacheModel( RADAR_D_SKYBOX_MODEL )
	PrecacheModel( RADAR_E_SKYBOX_MODEL )
	PrecacheModel( RADAR_F_SKYBOX_MODEL )
	PrecacheModel( RADAR_G_SKYBOX_MODEL )
	PrecacheModel( RADAR_H_SKYBOX_MODEL )
	PrecacheModel( RADAR_I_SKYBOX_MODEL )
	PrecacheModel( STRATON_MODEL )
	PrecacheModel( WALLACE_MODEL )
	PrecacheModel( STRATON_SKYBOX_MODEL )
	PrecacheModel( STRATON_SKYBOX_PARKED_MODEL )
	PrecacheModel( BOMBER_SKYBOX_PARKED_MODEL )
	PrecacheModel( GOBLIN_DROPSHIP_MODEL )
	PrecacheModel( BOMBER_MODEL )
	PrecacheModel( TEAM_MILITIA_CAPTAIN_MDL )
	PrecacheModel( TEAM_IMC_CAPTAIN_MDL )
	PrecacheModel( GOBLIN_MODEL )

	PrecacheModel( BISH_MODEL )
	PrecacheModel( SARAH_MODEL )
	PrecacheModel( PILOT_MODEL )
	PrecacheModel( LAPTOP_MODEL_SMALL )
	PrecacheModel( GUN_MODEL )
	PrecacheModel( BOMBER_MODEL )
	PrecacheModel( GUNRACK_MODEL )

	PrecacheParticleSystem( TOWER_PULSE_FX )
	PrecacheParticleSystem( TOWER_SKYBOX_PULSE_FX )
	PrecacheParticleSystem( SHIP_CRUSH_FX )
	PrecacheParticleSystem( LEVIATHAN_SPOTLIGHT_FX )
}

function EntitiesDidLoad()
{
	if ( EvacEnabled() ) //모드별 설정 선택
	{
		/*if ( GameRules.GetGameMode() == HEIST )
		{
			EvacSetupforHeist()
		}
		else
		{*/
			EvacSetup()
		//}
	}

	CreatePropDynamic( "models/IMC_base/imc_tech_tallpanel_48_02.mdl", Vector( -1184, 704, 156 ), Vector( 0, 211.563, 0 ), 6 )

	TowerInit()
	LeviathanInit()
	TurretsInit()
	FlyersInit()
	ProgressionInit()
	IMCCarrierInit()
	MilitiaWinInit()
	InitDoors()

	thread IntroPAAnnouncementRun()

	if ( level.isCinematicMode && IsAttritionMode() )
	{
		KillSpawns( "spawnPointIMCTDM_dev" )
		thread IntroAirbaseMain()
		//FlagClear( "AnnounceWinnerEnabled" ) // doing custom announcements
	}
	else
	{
		KillSpawns( "spawnPointIMCTDM_story" )
		DefaultDoorBehavior()
	}

	//thread StratonRandomTakeoff()
}

function IntroAirbaseMain()
{
	AB_IntroTDMSetup()

	FlagWait( "ReadyToStartMatch" )

	FlagSet( "Disable_IMC" )		// no random ai spawning
	FlagSet( "Disable_MILITIA" )	// no random ai spawning
	FlagSet( "DisableDropships" )	// no AI dropships or droppods
	SetGlobalForcedDialogueOnly( true )

	thread AB_IntroTDM()

	FlagWait( "IntroDone" )

	FlagClear( "Disable_MILITIA" )
	FlagClear( "DisableDropships" )
	FlagClear( "Disable_IMC" )

	SetGlobalForcedDialogueOnly( false )
}

function InitDoors()
{
	local doors = GetEntArrayByNameWildCard_Expensive( "imc_intro_door_inner*" )
	doors.extend( GetEntArrayByNameWildCard_Expensive( "imc_intro_door_outter*" ) )

	foreach( door in doors )
		DoorInit( door )
}

function DoorInit( door )
{
	door.s.clip <- GetEnt( door.GetTarget() )
	door.s.clip.SetParent( door, "", true )

	door.s.CloseOrigin <- door.GetOrigin()

	door.s.OpenOrigin <- door.GetOrigin() + ( door.GetRightVector() * 62 )
}

function DoorOpen( door )
{
	door.MoveTo( door.s.OpenOrigin, 0.5, 0.25, 0 )
}

function DoorClose( door )
{
	door.MoveTo( door.s.CloseOrigin, 0.5, 0.25, 0 )
}

function DefaultDoorBehavior()
{
	local doors = GetEntArrayByNameWildCard_Expensive( "imc_intro_door_inner*" )
	doors.extend( GetEntArrayByNameWildCard_Expensive( "imc_intro_door_outter*" ) )

	foreach ( door in doors )
		DoorOpen( door )
}

function IntroPAAnnouncementRun()
{
	if ( FlagExists( "IMCDoorsOpen" ) )
	{
		FlagWait( "IMCDoorsOpen" )
		wait( 9.5 )
		EmitSoundAtPosition( Vector( -2435.0, 3566.0, -11.0 ), "diag_airbasePa_AB122_01_01_imc_bgpa" )
		wait( 6.0 )
		EmitSoundAtPosition( Vector( -2435.0, 3566.0, -11.0 ), "diag_airbasePa_AB122_01_01_imc_bgpa" )
	}
}

function AB_IntroAIDropPod( team, dropNode, index )
{
	local node = GetEnt( dropNode )
	local numGuys = GetCPULevelWrapper() == CPU_LEVEL_HIGHEND ? 4 : 3
	local squad = Spawn_ScriptedTrackedDropPodGruntSquad( team, numGuys, node.GetOrigin(), node.GetAngles(), "IntroSquadTeam_" + team + "_" + index )

	ScriptedSquadAssault( squad, index )
}

function AB_IntroAITitanDrop( name, team, pilotNode, titanNode, flag, weapon = null, pilotDelay = 0 )
{
	local node		= GetEnt( pilotNode )
	local pilot 	= SpawnGrunt( team, "", node.GetOrigin(), node.GetAngles() )

	if ( team == TEAM_MILITIA )
		pilot.SetModel( TEAM_MILITIA_CAPTAIN_MDL )
	else
		pilot.SetModel( TEAM_IMC_CAPTAIN_MDL )
	pilot.SetEfficientMode( true )
	pilot.SetTitle( name )

	local anim 	= "CQB_Idle_Casual"
	local origin = HackGetDeltaToRef( node.GetOrigin(), node.GetAngles(), pilot, anim )
	node.SetOrigin( origin )

	thread PlayAnimGravity( pilot, anim, origin, pilot.GetAngles() )

	local node 		= GetEnt( titanNode )
	node.SetOrigin( node.GetOrigin() + Vector( 0, 0, 8 ))//HACK! - need to adjust up from ref node. Mackey says unavoidable due to length of distance traveled in animation
	local animation = "at_hotdrop_drop_2knee_turbo" // "at_hotdrop_drop_2knee"
	local table 	= CreateDefaultNPCTitanTemplate( team )
	table.title 	= ""
	if ( weapon )
		table.weapon	= weapon
	table.origin 	= node.GetOrigin() + Vector( 0,0,4000 )
	table.angles 	= node.GetAngles()

	local titan = SpawnNPCTitan( table )
	titan.SetEfficientMode( true )
	titan.SetTouchTriggers( false )

	titan.EndSignal( "OnDeath" )

	delaythread( 3.5 + pilotDelay ) RunToAnimStartForced( pilot, "a_crouch_2_stand", node )

	waitthread ScriptedHotDrop( titan, node.GetOrigin(), node.GetAngles(), animation )
	thread PlayAnim( titan, "at_MP_embark_idle", titan.GetOrigin(), titan.GetAngles() )

	waitthread AB_IntroPilotGetInTitan( pilot, titan, pilotDelay )

	waitthread PlayAnim( titan, "at_mount_kneel_front" )

	if ( IsValid( pilot ) )
		pilot.Kill()

	titan.SetTitle( name )
	titan.SetEfficientMode( false )
	titan.SetTouchTriggers( true )

	level.MCORTitans.append( titan )
	FlagSet( flag )

	local target = GetEnt( node.GetTarget() )
	titan.DisableArrivalOnce( true )

	while( target )
	{
		waitthread GotoOrigin( titan, target.GetOrigin() )
		titan.DisableStarts()
		target = GetEnt( target.GetTarget() )
	}
	titan.EnableStarts()
}

function AB_IntroPilotGetInTitan( pilot, titan, pilotDelay )
{
	if ( !IsAlive( pilot ) )
		return
	pilot.EndSignal( "OnDeath" )

	if ( pilotDelay )
		wait pilotDelay

	waitthread RunToAnimStartForcedTimeOut( pilot, "pt_mount_atlas_kneel_front", titan, "hijack", 20 )
	thread PlayAnim( pilot, "pt_mount_atlas_kneel_front", titan, "hijack" )
}

function KillSpawns( name )
{
	local spawns = GetEntArrayByNameWildCard_Expensive( name + "*" )
	foreach( spawnPoint in spawns )
		spawnPoint.Kill()
}

function EvacSetup()
{
	local spectatorNode1 = GetEnt( "spec_cam1" )
	/*local spectatorNode2 = GetEnt( "spec_cam2" )
	local spectatorNode3 = GetEnt( "spec_cam3" )
	local spectatorNode4 = GetEnt( "spec_cam4" )
	local spectatorNode5 = GetEnt( "spec_cam5" )*/
	local spectatorNode6 = GetEnt( "spec_cam6" )

	Evac_AddLocation( "escape_node1", spectatorNode1.GetOrigin(), spectatorNode1.GetAngles() )
	/*Evac_AddLocation( "escape_node2", spectatorNode2.GetOrigin(), spectatorNode2.GetAngles() )
	Evac_AddLocation( "escape_node3", spectatorNode3.GetOrigin(), spectatorNode3.GetAngles() )
	Evac_AddLocation( "escape_node4", spectatorNode4.GetOrigin(), spectatorNode4.GetAngles() )
	Evac_AddLocation( "escape_node5", spectatorNode5.GetOrigin(), spectatorNode5.GetAngles() )*/
	Evac_AddLocation( "escape_node6", spectatorNode6.GetOrigin(), spectatorNode6.GetAngles() )

	local spacenode = CreateScriptRef( Vector( -5714.0, -982.0, -7600.0 ), Vector( -3.62, 90.307, 0 ) )

	Evac_SetSpaceNode( spacenode )
	if ( !level.isCinematicMode )
		Evac_SetupDefaultVDUs()
}

/*function EvacSetupforHeist()
{
	//local spectatorNode1 = GetEnt( "spec_cam1" )
	//local spectatorNode2 = GetEnt( "spec_cam2" )
	//local spectatorNode3 = GetEnt( "spec_cam3" )
	//local spectatorNode4 = GetEnt( "spec_cam4" )
	local spectatorNode5 = GetEnt( "spec_cam5" )
	local spectatorNode6 = GetEnt( "spec_cam6" )

	//Evac_AddLocation( "escape_node1", spectatorNode1.GetOrigin(), spectatorNode1.GetAngles() )
	//Evac_AddLocation( "escape_node2", spectatorNode2.GetOrigin(), spectatorNode2.GetAngles() )
	//Evac_AddLocation( "escape_node3", spectatorNode3.GetOrigin(), spectatorNode3.GetAngles() )
	//Evac_AddLocation( "escape_node4", spectatorNode4.GetOrigin(), spectatorNode4.GetAngles() )
	Evac_AddLocation( "escape_node5", spectatorNode5.GetOrigin(), spectatorNode5.GetAngles() )
	Evac_AddLocation( "escape_node6", spectatorNode6.GetOrigin(), spectatorNode6.GetAngles() )

	local spacenode = CreateScriptRef( Vector( -5714.0, -982.0, -7600.0 ), Vector( -3.62, 90.307, 0 ) )

	Evac_SetSpaceNode( spacenode )
	if ( !level.isCinematicMode )
		Evac_SetupDefaultVDUs()
}*/

function EndRoundMain()
{
	if ( EvacEnabled() )
		GM_SetObserverFunc( EvacObserverFunc )
}

function EvacObserverFunc( player )
{
	player.SetObserverModeStaticPosition( level.ExtractLocations[ level.SelectedExtractLocationIndex ].spectatorPos )
	player.SetObserverModeStaticAngles( level.ExtractLocations[ level.SelectedExtractLocationIndex ].spectatorAng )

	player.StartObserverMode( OBS_MODE_CHASE )
	player.SetObserverTarget( null )
}

function ProgressionInit()
{
	AddProgressionFunc( 15, ProgressStage_PreAlphaTower )
	AddProgressionFunc( 30, ProgressStage_TowerAlphaFall )
	AddProgressionFunc( 38, ProgressStage_TowerAlphaFallPost )
	AddProgressionFunc( 55, ProgressStage_TowerCharlieFall )
	AddProgressionFunc( 66, ProgressStage_NearMatchOver )
	AddProgressionFunc( 74, ProgressStage_PreFinalTower )
	AddProgressionFunc( 100, ProgressStage_MatchOver )
}

function AddProgressionFunc( progress, func )
{
	local funcTable = {}
	funcTable.func			<- func
	funcTable.progress		<- progress
	funcTable.scope			<- this
	funcTable.called		<- false
	funcTable.ran			<- false

	level.progressFuncArray.append( funcTable )
}

function MatchProgressChanged()
{
	if ( !level.progressEnabled )
		return

	thread MatchProgressChangedThread()
}

function MatchProgressChangedThread()
{
	foreach ( funcTable in level.progressFuncArray )
	{
		if ( level.nv.matchProgress >= funcTable.progress )
		{
			if ( level.isCinematicMode && funcTable.called && !funcTable.ran )
				return

			if ( !funcTable.called )
			{
				funcTable.called = true
				if ( level.isCinematicMode )
				{
					waitthread funcTable.func()
					funcTable.ran = true
				}
				else
				{
					thread funcTable.func()
				}
			}
		}
	}
}

function ProgressStage_PreAlphaTower()
{
	if ( level.isCinematicMode )
	{
		SetGlobalForcedDialogueOnly( true )
		ForcePlayConversationToAll( "pre_alpha_tower" )
		wait( 20.0 )
		SetGlobalForcedDialogueOnly( false )
	}
}

function ProgressStage_TowerAlphaFall()
{
	if ( level.isCinematicMode )
	{
		SetGlobalForcedDialogueOnly( true )
		ForcePlayConversationToTeam( "militia_alpha_tower_down", TEAM_MILITIA )
	}

	wait( 5.0 )
	level.nv.towerAlphaFalling = Time()

	if ( level.isCinematicMode )
	{
		delaythread( 12.0 ) ForcePlayConversationToTeam( "imc_alpha_tower_down_post", TEAM_IMC )
	}
	TowerFall( level.tower_alpha )
	if ( level.isCinematicMode )
		ForcePlayConversationToTeam( "alpha_tower_fall", TEAM_MILITIA )
	thread LeviathanAlphaTowerRun()

	level.nv.towerAlphaDown = Time()

	wait( 20.0 )
	SetGlobalForcedDialogueOnly( false )
}

function ProgressStage_TowerAlphaFallPost()
{
	if ( level.isCinematicMode )
	{
		SetGlobalForcedDialogueOnly( true )
		ForcePlayConversationToTeam( "militia_alpha_tower_down_post", TEAM_MILITIA )
	}

	wait( 20.0 )
	SetGlobalForcedDialogueOnly( false )
}

function ProgressStage_TowerCharlieFall()
{
	if ( level.isCinematicMode )
	{
		SetGlobalForcedDialogueOnly( true )
		ForcePlayConversationToTeam( "militia_charlie_tower_down", TEAM_MILITIA )
		delaythread( 32.0 ) ForcePlayConversationToTeam( "militia_charlie_tower_down2", TEAM_MILITIA )

		ForcePlayConversationToTeam( "imc_charlie_tower_down", TEAM_IMC )
	}

	wait( 8.0 )

	level.nv.towerCharlieFalling = Time()
	TowerFall( level.tower_charlie )
	LeviathanCharlieTowerRun()

	level.nv.towerCharlieDown = Time()

	wait( 45.0 )
	SetGlobalForcedDialogueOnly( false )
}

function ProgressStage_NearMatchOver()
{
	if ( level.isCinematicMode )
	{
		SetGlobalForcedDialogueOnly( true )

		local imcScore = GameRules.GetTeamScore( TEAM_IMC )
		local militiaScore = GameRules.GetTeamScore( TEAM_MILITIA )

		if ( GetCurrentWinner() == TEAM_MILITIA )
		{
			ForcePlayConversationToTeam( "militia_near_match_over_winning", TEAM_MILITIA )

			if ( militiaScore >= imcScore * 1.25 )
			{
				ForcePlayConversationToTeam( "militia_npc_titan_support", TEAM_IMC )
				thread SpawnLosingTeamTitan( "imc_losing_titan_drop", "#NPC_SGT_FLAGG", TEAM_IMC )
			}
		}
		else if ( imcScore >= militiaScore * 1.25 )
		{
			ForcePlayConversationToTeam( "militia_npc_titan_support", TEAM_MILITIA )
			thread SpawnLosingTeamTitan( "militia_losing_titan_drop", "#NPC_SGT_HOFNER", TEAM_MILITIA )
		}
	}

	wait( 6.0 )

	SetGlobalForcedDialogueOnly( false )
}

function SpawnLosingTeamTitan( titanNode, name, team )
{
	local node 		= GetEnt( titanNode )

	local table 	= CreateDefaultNPCTitanTemplate( team )
	table.title 	= name
	table.health 	= 3000
	table.maxHealth	= table.health
	table.origin 	= node.GetOrigin()
	table.angles 	= node.GetAngles()

	local titan = SpawnNPCTitan( table )
	titan.EndSignal( "OnDestroy" )
	titan.EndSignal( "OnDeath" )

	titan.SetEfficientMode( true )
	titan.SetTouchTriggers( false )

	thread ScriptedHotDrop( titan, node.GetOrigin(), node.GetAngles(), "at_hotdrop_drop_2knee_turbo", true )
	wait( 5.4 )
	waitthread PlayAnimGravity( titan, "at_MP_embark_fast" )
	titan.SetEfficientMode( false )
	titan.DisableArrivalOnce( true )

	local target = GetEnt( node.GetTarget() )

	while ( target )
	{
		waitthread GotoOrigin( titan, target.GetOrigin() )
		titan.DisableStarts()
		target = GetEnt( target.GetTarget() )
	}
	titan.EnableStarts()
}

function ProgressStage_PreFinalTower()
{
	if ( level.isCinematicMode )
	{
		SetGlobalForcedDialogueOnly( true )
		ForcePlayConversationToAll( "airbase_pre_final_tower" )
		wait( 15.0 )
		ForcePlayConversationToTeam( "airbase_pre_final_tower2", TEAM_MILITIA )
		wait( 6.0 )
		SetGlobalForcedDialogueOnly( false )
	}
}

function ProgressStage_MatchOver()
{
	if ( level.isCinematicMode )
		SetGlobalForcedDialogueOnly( true )

	local winner = GetCurrentWinner( TEAM_IMC )

	if ( winner == TEAM_MILITIA )
	{
		if ( level.isCinematicMode )
		{
			Evac_SetPostEvacDialogueTime( 8.0 )
			ForcePlayConversationToTeam( "airbase_won_announcement", TEAM_MILITIA )
			ForcePlayConversationToTeam( "airbase_lost_announcement", TEAM_IMC )
		}

		thread PlayAnim( level.militiaWinDropship1, "airbase_towerattack_dropship1", level.tower )
		thread PlayAnim( level.militiaWinDropship2, "airbase_towerattack_dropship2", level.tower )
		thread PlayAnim( level.militiaWinStraton1, "airbase_towerattack_straton1", level.tower )
		thread PlayAnim( level.militiaWinStraton2, "airbase_towerattack_straton2", level.tower )
		thread PlayAnim( level.militiaWinBomber, "airbase_towerattack_bomber", level.tower )

		thread TowerMainDeathTriggers()

		level.nv.towerMainAttackStarted = Time()
		wait( 13.4 )

		GetEnt( "particle_tower_beam_1" ).Destroy()
		GetEnt( "particle_tower_beam_2" ).Destroy()

		level.nv.towerMainFalling = Time()

		FadeOutSoundOnEntity( level.tower, "airbase_scr_dogwhistle_idle", 20.0 )

		thread LeviathanMainTowerRun()
		delaythread( 6.0 ) NpcFlyerPickupThink( { minStart = 4.0, maxStart = 6.0, minEnd = 4.0, maxEnd = 6.0 } )
		delaythread( 6.0 ) FlyersPerch()

		if ( level.isCinematicMode )
		{
			delaythread( 14.0 ) ForcePlayConversationToTeam( "airbase_main_tower_down", TEAM_IMC )
		}
		TowerFall( level.tower )

		level.nv.towerMainDown = Time()

		thread TurretsShootFlyers()
	}
	else if ( winner == TEAM_IMC )
	{
		if ( level.isCinematicMode )
		{
			ForcePlayConversationToTeam( "airbase_won_announcement", TEAM_IMC )
			ForcePlayConversationToTeam( "airbase_lost_announcement", TEAM_MILITIA )
		}

		delaythread( 8.0 ) IMCCarrierTakeOff()

		level.nv.imcWinShipsTakeOff = Time()

		thread LeviathanIMCWin()

		wait( 2.0 )
		local lev = GetEnt( "leviathan_alpha_down_1" )
		if ( IsValid( lev ) )
		{
			level.nv.fightersAttackLevStage = 4

			local players = GetPlayerArray()
			foreach ( player in players )
				Remote.CallFunction_NonReplay( player, "ServerCallback_FightersKillLeviathan", lev.GetEncodedEHandle(), -10693.0, 7614.0 )

			wait( 5.0 )
			Signal( lev, "EndLeviathanThink" )

			PlayAnim( lev, "leviathan_death", null, null, 4.0 )

			wait( 5.0 )

			lev = GetEnt( "leviathan_map_start_3" )
			if ( IsValid( lev ) )
			{
				players = GetPlayerArray()
				foreach ( player in players )
					Remote.CallFunction_NonReplay( player, "ServerCallback_FightersKillLeviathan", lev.GetEncodedEHandle(), -10658.15, 7618.46 )

				wait( 5.0 )
				Signal( lev, "EndLeviathanThink" )

				PlayAnim( lev, "leviathan_death", null, null, 4.0 )
			}
		}
	}
}

function MilitiaWinInit()
{
	level.militiaWinDropship1 <- CreatePropDynamic( GOBLIN_DROPSHIP_MODEL, null, null, 0 )
	level.militiaWinDropship1.SetName( "militiaWinDropship1" )
	thread PlayAnim( level.militiaWinDropship1, "airbase_towerattack_dropship1_idle", level.tower )

	level.militiaWinDropship2 <- CreatePropDynamic( GOBLIN_DROPSHIP_MODEL, null, null, 0 )
	level.militiaWinDropship2.SetName( "militiaWinDropship2" )
	thread PlayAnim( level.militiaWinDropship2, "airbase_towerattack_dropship2_idle", level.tower )

	level.militiaWinStraton1 <- CreatePropDynamic( STRATON_MODEL, null, null, 0 )
	level.militiaWinStraton1.SetName( "militiaWinStraton1" )
	thread PlayAnim( level.militiaWinStraton1, "airbase_towerattack_straton1_idle", level.tower )

	level.militiaWinStraton2 <- CreatePropDynamic( STRATON_MODEL, null, null, 0 )
	level.militiaWinStraton2.SetName( "militiaWinStraton2" )
	thread PlayAnim( level.militiaWinStraton2, "airbase_towerattack_straton2_idle", level.tower )

	level.militiaWinBomber <- CreatePropDynamic( BOMBER_MODEL, null, null, 0 )
	level.militiaWinBomber.SetName( "militiaWinBomber" )
	thread PlayAnim( level.militiaWinBomber, "airbase_towerattack_bomber_idle", level.tower )
}

///////////////////////////////////////////////////////////////////////
//
//								TOWER
//
///////////////////////////////////////////////////////////////////////

function TowerInit()
{
	level.tower <- GetEnt( "prop_airbase_tower" )
	level.tower.SetName( "prop_airbase_tower_main" )
	level.tower_alpha <- CreatePropDynamic( TOWER_SKYBOX_MODEL, Vector( -10717, 7587.2, -6400.0 ), Vector( 0.0, 45.0, 0.0 ) )
	level.tower_alpha.SetName( "prop_airbase_tower_alpha" )
	level.tower_charlie <- CreatePropDynamic( TOWER_SKYBOX_MODEL, Vector( -10691.4, 7614.6, -6400.0 ), Vector( 0.0, 290.0, 0.0 ) )
	level.tower_charlie.SetName( "prop_airbase_tower_charlie" )

	Assert( level.tower )
	Assert( level.tower_alpha )
	Assert( level.tower_charlie )

	level.tower.s.falling <- false
	level.tower_alpha.s.falling <- false
	level.tower_charlie.s.falling <- false

	level.tower.s.tower_down <- false
	level.tower_alpha.s.tower_down <- false
	level.tower_charlie.s.tower_down <- false

	AddSignalAnimEvent( level.tower, "tower_down" )
	AddSignalAnimEvent( level.tower_alpha, "tower_down" )
	AddSignalAnimEvent( level.tower_charlie, "tower_down" )

	level.towerMainRocketsHitDeathTrigger <- GetEnt( "tower_main_death_trigger_1" )
	level.towerMainTowerExplosionDeathTrigger <- GetEnt( "tower_main_death_trigger_2" )
	level.towerMainCollisionSwapDeathTrigger <- GetEnt( "tower_main_death_trigger_3" )

	TowersReset()

	thread TowerPulse()
}

function TowersReset()
{
	thread PlayAnim( level.tower, "worker_base_whistle_tower_idle_new" )
	thread TowerMainSound()
	thread PlayAnim( level.tower_alpha, "worker_base_whistle_tower_idle_new" )
	thread PlayAnim( level.tower_charlie, "worker_base_whistle_tower_idle_new" )
}

function TowerMainSound()
{
	FlagWait( "IntroDone" )
	wait( 2.0 )
	EmitSoundOnEntity( level.tower, "airbase_scr_dogwhistle_idle" )
}

function TowerPulse()
{
	local mainTowerOrg = level.tower.GetOrigin() + Vector( 0.0, 0.0, 13365.0 )
	local alphaTowerOrg = level.tower_alpha.GetOrigin() + Vector( 0.0, 0.0, 13.3 )
	local charlieTowerOrg = level.tower_charlie.GetOrigin() + Vector( 0.0, 0.0, 13.3 )

	while ( true )
	{
		wait( 20.0 )
		if ( !level.tower_alpha.s.falling )
			PlayFX( TOWER_SKYBOX_PULSE_FX, alphaTowerOrg )
		wait( 2.0 )
		if ( !level.tower_charlie.s.falling )
			PlayFX( TOWER_SKYBOX_PULSE_FX, charlieTowerOrg )
		wait( 2.0 )
		if ( !level.tower.s.falling )
		{
			PlayFX( TOWER_PULSE_FX, mainTowerOrg )
			EmitSoundAtPosition( Vector( -2405.0, 3518.0, 12664.0 ), "airbase_scr_dogwhistle_pulse" )
		}
	}
}

function TowerMainDeathTriggers()
{
	wait( 5.0 )

	level.towerMainRocketsHitDeathTrigger.ConnectOutput( "OnStartTouch", TriggerBurnDamage )
	level.towerMainRocketsHitDeathTrigger.ConnectOutput( "OnEndTouch", TriggerBurnDamageOff )

	local touchingEnts = level.towerMainRocketsHitDeathTrigger.GetTouchingEntities()
	foreach( ent in touchingEnts )
		TriggerBurnDamage( level.towerMainRocketsHitDeathTrigger, ent, null, null )
	wait( 8.4 )

	level.towerMainTowerExplosionDeathTrigger.ConnectOutput( "OnStartTouch", TriggerBurnDeath )

	touchingEnts = level.towerMainTowerExplosionDeathTrigger.GetTouchingEntities()
	foreach( ent in touchingEnts )
		TriggerBurnDeath( level.towerMainTowerExplosionDeathTrigger, ent, null, null )
	wait( 2.0 )

	level.towerMainTowerExplosionDeathTrigger.DisconnectOutput( "OnStartTouch", TriggerBurnDeath )
	wait( 4.0 )

	level.towerMainRocketsHitDeathTrigger.DisconnectOutput( "OnStartTouch", TriggerBurnDamage )
	level.towerMainRocketsHitDeathTrigger.DisconnectOutput( "OnEndTouch", TriggerBurnDamageOff )

	touchingEnts = level.towerMainRocketsHitDeathTrigger.GetTouchingEntities()
	foreach ( ent in touchingEnts )
		TriggerBurnDamageOff( level.towerMainRocketsHitDeathTrigger, ent, null, null )
	wait( 10.0 )

	touchingEnts = level.towerMainCollisionSwapDeathTrigger.GetTouchingEntities()
	foreach ( ent in touchingEnts )
		TriggerDeath( level.towerMainCollisionSwapDeathTrigger, ent, eDamageSourceId.crushed )

	GetEnt( "tower_collision_destroyed" ).Fire( "enable" )
	GetEnt( "tower_collision_intact" ).Fire( "disable" )
}

function TriggerDeath( self, activator, damageId )
{
	if ( !IsValid( self ) )
		return

	if ( IsAlive( activator ) && ( activator.IsPlayer() || activator.IsNPC() ) && !activator.IsTitan() )
		activator.Die( self, self, { scriptType = DF_INSTANT, damageSourceId = damageId } )
}

function TriggerBurnDeath( self, activator, caller, value )
{
	TriggerDeath( self, activator, eDamageSourceId.burn )
}

function TriggerBurnDamage( self, activator, caller, value )
{
	if ( !IsValid( self ) )
		return

	if ( IsAlive( activator ) && ( activator.IsPlayer() || activator.IsNPC() ) && !activator.IsTitan() )
		thread TriggerBurnDamageThread( activator, self )
}

function TriggerBurnDamageThread( guy, trigger )
{
	guy.EndSignal( "OnDeath" )
	guy.EndSignal( "OnDestroy" )
	guy.EndSignal( "BurnDamage" )

	local damage = guy.GetMaxHealth() / 10.0

	while ( true )
	{
		guy.TakeDamage( damage, trigger, trigger, { scriptType = DF_INSTANT, damageSourceId = eDamageSourceId.burn } )
		wait( 0.25 )
	}
}

function TriggerBurnDamageOff( self, activator, caller, value )
{
	if ( IsAlive( activator ) && ( activator.IsPlayer() || activator.IsNPC() ) && !activator.IsTitan() )
		activator.Signal( "BurnDamage" )
}

function TowerFall( tower )
{
	tower.s.falling = true
	thread PlayAnim( tower, "worker_base_whistle_tower_radar_fall_v2" )

	tower.WaitSignal( "tower_down" )
	tower.s.tower_down = true
}

///////////////////////////////////////////////////////////////////////
//
//							    TURRETS
//
///////////////////////////////////////////////////////////////////////

function TurretsInit()
{
	level.turrets <- [ GetEnt( "turret_mega_1" ), GetEnt( "turret_mega_2" ), GetEnt( "turret_mega_3" ) ]
	level.turretTargetOrg <- Vector( 0.0, 2500.0, 4500.0 )

	target <- CreateScriptRef( level.turretTargetOrg )

	foreach( turret in level.turrets )
	{
		turret.s.notitle <- true

		turret.Minimap_Hide( TEAM_IMC, null )
		turret.Minimap_Hide( TEAM_MILITIA, null )
	}
}

function TurretsShootFlyers()
{
	foreach( turret in level.turrets )
	{
		turret.EnableTurret()

		turret.SetEnemy( target )
		turret.SetEnemyLKP( target, level.turretTargetOrg )
		turret.Fire( "UpdateEnemyMemory", target.GetName() )
	}

	local targetPositions = [
		Vector( 0.0, 2500.0, 4500.0 ),
		Vector( -772.5, 2377.5, 4500.0 ),
		Vector( -1469.5, 2022.5, 5000.0 ),
		Vector( -2022.5, 1469.5, 3800.0 ),
		Vector( -2377.5, 772.5, 4500.0 ),
		Vector( -2500.0, 0.0, 4800.0 ),
		Vector( -2377.5, -772.5, 5200.0 ),
		Vector( -2022.5, -1469.5, 4500.0 ),
		Vector( -1469.5, -2022.5, 4700.0 ),
		Vector( -772.5, -2377.5, 4300.0 )
	]

	while ( true )
	{
		foreach ( pos in targetPositions )
		{
			target.SetOrigin( pos )
			wait( 1.0 )
		}
	}
}

///////////////////////////////////////////////////////////////////////
//
//							    FLYERS
//
///////////////////////////////////////////////////////////////////////

function FlyersInit()
{
	level.perchFlyers <- [
		{ org = Vector( -1338.0, -2370.0, 930.0 ), ang = Vector( 0.0, -180.0, 0.0 ), land = true, scream = false },
		{ org = Vector( -1386.0, -1345.0, 892.0 ), ang = Vector( 0.0, 221.0, 0.0 ), land = true, scream = true },
	 	{ org = Vector( -67.0, -489.0, 588.0 ), ang = Vector( 0.0, -160.0, 0.0 ), land = true, scream = true },
	 	{ org = Vector( -1030.0, 325.0, 1084.0 ), ang = Vector( 0.0, -154.0, 0.0 ), land = true, scream = true },
	 	{ org = Vector( -900.0, -4433.0, 780.0 ), ang = Vector( 0.0, 100.0, 0.0 ), land = true, scream = true },
	 	{ org = Vector( 541.0, -2356.0, 800.0 ), ang = Vector( 0.0, -100.0, 0.0 ), land = true, scream = true },
	 	{ org = Vector( -892.0, -2933.0, 646.0 ), ang = Vector( 0.0, 0.0, 0.0 ), land = true, scream = false },
	 	{ org = Vector( -246.0, 471.0, 1084.0 ), ang = Vector( 0.0, -60.0, 0.0 ), land = true, scream = true },
		{ org = Vector( 1639.0, -996, 1155.0 ), ang = Vector( 0.0, 260.0, 0.0 ), land = true, scream = true },
		{ org = Vector( 1624.0, 532.0, 698.0 ), ang = Vector( 0.0, 90.0, 0.0 ), land = true, scream = false },
		{ org = Vector( -1788.0, 1032.0, 392.0 ), ang = Vector( 0.0, 115.0, 0.0 ), land = true, scream = true },
		{ org = Vector( 1024.0, 2584.0, 348.0 ), ang = Vector( 0.0, 240.0, 0.0 ), land = true, scream = true },
		{ org = Vector( 30.0, 2222.0, 391.0 ), ang = Vector( 0.0, 284.0, 0.0 ), land = true, scream = true },
		{ org = Vector( 312.0, 987.0, 674.0 ), ang = Vector( 0.0, 112.0, 0.0 ), land = true, scream = false },
		{ org = Vector( -738.0, 2970.0, 350.0 ), ang = Vector( 0.0, -37.0, 0.0 ), land = true, scream = true },
		{ org = Vector( 2047.0, -229.0, 1156.0 ), ang = Vector( 0.0, 128.0, 0.0 ), land = true, scream = true },
		{ org = Vector( -297.0, -1219.0, 588.0 ), ang = Vector( 0.0, 120.0, 0.0 ), land = true, scream = true },
		{ org = Vector( 2065.0, -3354.0, 941.0 ), ang = Vector( 0.0, 91.0, 0.0 ), land = true, scream = true },
		{ org = Vector( -3209.0, -5310.0, 1096.0 ), ang = Vector( 0.0, 94.0, 0.0 ), land = true, scream = true },
		{ org = Vector( 117.0, -4809.0, 968.0 ), ang = Vector( 0.0, 69.0, 0.0 ), land = true, scream = true },
		{ org = Vector( -2903.0, -701.0, 882.0 ), ang = Vector( 0.0, -69.0, 0.0 ), land = true, scream = true },
		{ org = Vector( -2413.0, -3034.0, 318.0 ), ang = Vector( 0.0, 20.0, 0.0 ), land = true, scream = true },
		{ org = Vector( 1326.0, -3477.0, 716.0 ), ang = Vector( 0.0, 129.0, 0.0 ), land = true, scream = true },
		{ org = Vector( 1512.0, -2585.0, 660.0 ), ang = Vector( 0.0, 280.0, 0.0 ), land = true, scream = true },
		{ org = Vector( -4520.0, 3025.0, 349.0 ), ang = Vector( 0.0, 326.0, 0.0 ), land = true, scream = true }
	]

	ArrayRandomize( level.perchFlyers )

	/*wait( 4.0 )
	foreach ( perch in level.perchFlyers )
	{
		DebugDrawLine( perch.org, perch.org + perch.ang.AnglesToForward() * 50.0, 255.0, 0.0, 255.0, true, 9999.0 )
	}*/
}

function FlyersPerch()
{
	for ( local i = 0; i < level.perchFlyers.len() && i < 16; i++ )
	{
		local perch = level.perchFlyers[ i ]

		CreatePerchedFlyer( perch.org, perch.ang, perch.land, perch.scream )

		wait( RandomFloat( 2.0, 6.0 ) )
	}
}

///////////////////////////////////////////////////////////////////////
//
//							LEVIATHAN
//
///////////////////////////////////////////////////////////////////////

function LeviathanInit()
{
	level.leviathans_approach_playspace <- false
	level.leviathans_leave_playspace <- false

	LeviathanSpawn( GetNodeByUniqueID( "cinematic_mp_node_mapstart_01" ), LEVIATHAN_MEDIUM_MODEL, "leviathan_map_start_1", LeviathanMapStart1ShouldInterrupt, LeviathanMapStart1Interrupt )
	LeviathanSpawn( GetNodeByUniqueID( "cinematic_mp_node_mapstart_02" ), LEVIATHAN_MEDIUM_MODEL, "leviathan_map_start_2", LeviathanMapStart2ShouldInterrupt, LeviathanMapStart2Interrupt )
	LeviathanSpawn( GetNodeByUniqueID( "cinematic_mp_node_mapstart_03" ), LEVIATHAN_MEDIUM_MODEL, "leviathan_map_start_3", LeviathanMapStart3ShouldInterrupt, LeviathanMapStart3Interrupt )
	LeviathanSpawn( GetNodeByUniqueID( "cinematic_mp_node_mapstart_04" ), LEVIATHAN_MEDIUM_MODEL, "leviathan_map_start_4" )
	LeviathanSpawn( GetNodeByUniqueID( "cinematic_mp_node_mapstart_05" ), LEVIATHAN_MEDIUM_MODEL, "leviathan_map_start_5" )
	LeviathanSpawn( GetNodeByUniqueID( "cinematic_mp_node_mapstart_06" ), LEVIATHAN_LARGE_MODEL, "leviathan_map_start_6" )
}

function LeviathanAddNode( array, name )
{
	local node = GetNodeByUniqueID( name )

	if ( IsValid( node ) )
		array.append( node )
}

function LeviathanAlphaTowerRun()
{
	LeviathanSpawn( GetNodeByUniqueID( "cinematic_mp_node_alpha_tower_01" ), LEVIATHAN_SMALL_MODEL, "leviathan_alpha_down_1", LeviathanAlphaDown1ShouldInterrupt, LeviathanAlphaDown1Interrupt )
	delaythread( 65.0 ) LeviathanSpawn( GetNodeByUniqueID( "cinematic_mp_node_alpha_tower_02" ), LEVIATHAN_MEDIUM_MODEL, "leviathan_alpha_down_2", LeviathanAlphaDown2ShouldInterrupt, LeviathanAlphaDown2Interrupt )
	delaythread( 100.0 ) LeviathanSpawn( GetNodeByUniqueID( "cinematic_mp_node_alpha_tower_03" ), LEVIATHAN_MEDIUM_MODEL, "leviathan_alpha_down_3", LeviathanAlphaDown3ShouldInterrupt, LeviathanAlphaDown3Interrupt )

	level.nv.leviathanAlphaCrush = true

	wait( 45.0 )

	level.nv.fightersAttackLevStage = 1

	wait( 10.0 )
	level.nv.fightersAttackLevStage = 2
}

function LeviathanCharlieTowerRun()
{
	local lev = LeviathanSpawn( GetNodeByUniqueID( "cinematic_mp_node_charlie_tower_01" ), LEVIATHAN_SMALL_MODEL, "leviathan_charlie_down_1", LeviathanCharlieDown1ShouldInterrupt, LeviathanCharlieDown1Interrupt )

	level.nv.leviathanCharlieCrush = true

	level.nv.fightersAttackLevStage = 3
}

function LeviathanMainTowerRun()
{
	level.leviathans_approach_playspace = true
	level.nv.leviathanFootstepsShake = true

	local leviathan = GetEnt( "leviathan_alpha_down_1" )
	if ( leviathan != null )
		thread PlayAnim( leviathan, "leviathan_idle_short" )

	leviathan = GetEnt( "leviathan_charlie_down_1" )
	if ( leviathan != null )
		thread PlayAnim( leviathan, "leviathan_idle_short" )
}

function LeviathanIMCWin()
{
	level.leviathans_leave_playspace = true

	local leviathan = GetEnt( "leviathan_alpha_down_2" )
	if ( leviathan != null )
		thread PlayAnim( leviathan, "leviathan_idle_short" )
}

function LeviathanSpawn( node, model, name, funcShouldInterrupt = null, funcInterrupt = null )
{
	node.model <- model
	thread NodeDoMoment( node )

	Assert( "leviathan" in node )

	local leviathan = node.leviathan
	leviathan.s.interrupted <- false
	leviathan.s.pathNum <- 0
	leviathan.SetName( name )
	leviathan.s.Waits = 99
	leviathan.s.remove_at_path_end = false
	leviathan.s.walk_fast = true

	if ( funcShouldInterrupt != null && funcInterrupt != null )
	{
		leviathan.s.funcShouldInterrupt <- {}
		leviathan.s.funcShouldInterrupt.func	<- funcShouldInterrupt
		leviathan.s.funcShouldInterrupt.scope	<- this

		leviathan.s.funcInterrupt <- {}
		leviathan.s.funcInterrupt.func	<- funcInterrupt
		leviathan.s.funcInterrupt.scope	<- this

		SetLeviathanLevelFunc( leviathan, LeviathanInterrupt )
	}

	return leviathan
}

function LeviathanMapStart1ShouldInterrupt( leviathan )
{
	return ( ( level.tower_alpha.s.falling && leviathan.s.pathNum == 0 ) ||
		   ( level.leviathans_approach_playspace && leviathan.s.pathNum == 1 ) )
}

function LeviathanMapStart1Interrupt( leviathan, resultTable )
{
	if ( leviathan.s.pathNum == 0 )
	{
		if ( leviathan.s.walking )
		{
			leviathan.s.walking = false
			waitthread PlayAnim( leviathan, "leviathan_trans_2_idle_fast" )
		}

		if ( !level.tower_alpha.s.tower_down )
		{
			thread PlayAnim( leviathan, "leviathan_idle_short" )
			level.tower_alpha.WaitSignal( "tower_down" )
		}

		if ( level.nv.towerAlphaDown + 4.0 > Time() )
			waitthread PlayAnim( leviathan, "leviathan_reaction_big" )

		resultTable.resultVar = GetNodeByUniqueID( "cinematic_mp_node_mapstart_01_new_path" )
	}

	leviathan.s.pathNum++
}

function LeviathanMapStart2ShouldInterrupt( leviathan )
{
	return ( level.tower_alpha.s.falling && leviathan.s.pathNum == 0 ) ||
		   ( level.leviathans_approach_playspace && leviathan.s.pathNum == 1 )
}

function LeviathanMapStart2Interrupt( leviathan, resultTable )
{
	if ( leviathan.s.pathNum == 0 )
	{
		if ( leviathan.s.walking )
		{
			leviathan.s.walking = false
			waitthread PlayAnim( leviathan, "leviathan_trans_2_idle_fast" )
		}

		if ( !level.tower_alpha.s.tower_down )
		{
			thread PlayAnim( leviathan, "leviathan_idle_short" )
			level.tower_alpha.WaitSignal( "tower_down" )
		}

		wait( 2.5 )
		if ( level.nv.towerAlphaDown + 4.0 > Time() )
			waitthread PlayAnim( leviathan, "leviathan_reaction_big" )

		resultTable.resultVar = GetNodeByUniqueID( "cinematic_mp_node_mapstart_02_new_path" )
	}

	leviathan.s.pathNum++
}

function LeviathanMapStart3ShouldInterrupt( leviathan )
{
	return ( level.tower_charlie.s.falling && leviathan.s.pathNum == 0 )
}

function LeviathanMapStart3Interrupt( leviathan, resultTable )
{
	if ( leviathan.s.pathNum == 0 )
	{
		if ( leviathan.s.walking )
		{
			leviathan.s.walking = false
			waitthread PlayAnim( leviathan, "leviathan_trans_2_idle_fast" )
		}

		if ( !level.tower_charlie.s.tower_down )
		{
			thread PlayAnim( leviathan, "leviathan_idle_short" )
			level.tower_charlie.WaitSignal( "tower_down" )
		}

		thread PlayAnim( leviathan, "leviathan_idle_short" )
		wait( 2.0 )
		waitthread PlayAnim( leviathan, "leviathan_reaction_big" )

		resultTable.resultVar = GetNodeByUniqueID( "cinematic_mp_node_mapstart_03_new_path" )
	}

	leviathan.s.pathNum++
}

function LeviathanAlphaDown1ShouldInterrupt( leviathan )
{
	return ( level.leviathans_approach_playspace && leviathan.s.pathNum == 0 )
}

function LeviathanAlphaDown1Interrupt( leviathan, resultTable )
{
	if ( leviathan.s.pathNum == 0 )
		resultTable.resultVar = GetNodeByUniqueID( "cinematic_mp_node_alpha_tower_01_new_path" )

	leviathan.s.pathNum++
}

function LeviathanAlphaDown2ShouldInterrupt( leviathan )
{
	return ( level.leviathans_leave_playspace && leviathan.s.pathNum == 0 )
}

function LeviathanAlphaDown2Interrupt( leviathan, resultTable )
{
	if ( leviathan.s.pathNum == 0 )
		resultTable.resultVar = GetNodeByUniqueID( "cinematic_mp_node_alpha_tower_02_new_path" )

	leviathan.s.pathNum++

	waitthread PlayAnim( leviathan, "leviathan_reaction_big" )
}

function LeviathanAlphaDown3ShouldInterrupt( leviathan )
{
	return ( level.leviathans_leave_playspace && leviathan.s.pathNum == 0 )
}

function LeviathanAlphaDown3Interrupt( leviathan, resultTable )
{
	if ( leviathan.s.pathNum == 0 )
		resultTable.resultVar = GetNodeByUniqueID( "cinematic_mp_node_alpha_tower_03_new_path" )

	leviathan.s.pathNum++
}

function LeviathanCharlieDown1ShouldInterrupt( leviathan )
{
	return ( level.leviathans_approach_playspace && leviathan.s.pathNum == 0 )
}

function LeviathanCharlieDown1Interrupt( leviathan, resultTable )
{
	if ( leviathan.s.pathNum == 0 )
		resultTable.resultVar = GetNodeByUniqueID( "cinematic_mp_node_charlie_tower_01_new_path" )

	leviathan.s.pathNum++
}

function LeviathanInterrupt( leviathan, var, resultTable )
{
	leviathan.EndSignal( "OnDestroy" )

	if ( leviathan.s.funcShouldInterrupt.func( leviathan ) )
	{
		if ( type( var ) == "bool" )
		{
			resultTable.resultVar = true
			return
		}

		waitthread leviathan.s.funcInterrupt.func( leviathan, resultTable )
	}
}

function IMCCarrierInit()
{
	level.carrier <- CreatePropDynamic( IMC_CARRIER_MODEL, Vector( -10788.0, 7644.0, -6400.0 ), Vector( 0.0, 180.0, 0.0 ) )
	level.carrier.SetName( "carrier1" )

	level.wallace1 <- CreatePropDynamic( WALLACE_MODEL, Vector( -10669.0, 7603.0, -6397.3 ), Vector( 0.0, -180.0, 0.0 ) )
	level.wallace1.SetName( "wallace1" )
}

function IMCCarrierTakeOff()
{
	thread PlayAnim( level.wallace1, "capital_ship_wallace_airbase_takeoff" )
	level.wallace1.SetName( "wallace1" )
	wait( 2.0 )

	local wallace3 = CreatePropDynamic( WALLACE_MODEL, Vector( -10660.0, 7580.7, -6397.3 ), Vector( 0.0, -180.0, 0.0 ) )
	wallace3.SetName( "wallace3" )
	thread PlayAnim( wallace3, "capital_ship_wallace_airbase_takeoff" )
	wait( 2.0 )

	thread PlayAnim( level.carrier, "airbase_carrier_evac" )
	wait( 1.0 )

	thread IMCCarrierAlphaFade()
	wait( 3.0 )

	local wallace2 = CreatePropDynamic( WALLACE_MODEL, Vector( -10668.0, 7620.0, -6402.0 ), Vector( 0.0, -180.0, 0.0 ) )
	wallace2.SetName( "wallace2" )
	thread PlayAnim( wallace2, "capital_ship_wallace_airbase_takeoff" )

	local wallace4 = CreatePropDynamic( WALLACE_MODEL, Vector( -10686.0, 7542.0, -6402.3 ), Vector( 0.0, -180.0, 0.0 ) )
	wallace4.SetName( "wallace4" )
	thread PlayAnim( wallace4, "capital_ship_wallace_airbase_takeoff" )

	local wallace5 = CreatePropDynamic( WALLACE_MODEL, Vector( -10720.0, 7558.0, -6400.3 ), Vector( 0.0, -180.0, 0.0 ) )
	wallace5.SetName( "wallace5" )
	thread PlayAnim( wallace5, "capital_ship_wallace_airbase_takeoff" )
	wait( 10.0 )

	local wallace6 = CreatePropDynamic( WALLACE_MODEL, Vector( -10711.0, 7625.0, -6402.3 ), Vector( 0.0, -180.0, 0.0 ) )
	wallace6.SetName( "wallace6" )
	thread PlayAnim( wallace6, "capital_ship_wallace_airbase_takeoff" )
	wait( 4.0 )

	local wallace7 = CreatePropDynamic( WALLACE_MODEL, Vector( -10643.0, 7599.7, -6398.3 ), Vector( 0.0, -180.0, 0.0 ) )
	wallace7.SetName( "wallace7" )
	thread PlayAnim( wallace7, "capital_ship_wallace_airbase_takeoff" )
	wait( 4.0 )

	local wallace8 = CreatePropDynamic( WALLACE_MODEL, Vector( -10659.0, 7544.7, -6399.6 ), Vector( 0.0, -180.0, 0.0 ) )
	wallace8.SetName( "wallace8" )
	thread PlayAnim( wallace8, "capital_ship_wallace_airbase_takeoff" )
	wait( 8.0 )

	local wallace9 = CreatePropDynamic( WALLACE_MODEL, Vector( -10660.0, 7580.7, -6397.3 ), Vector( 0.0, -180.0, 0.0 ) )
	wallace9.SetName( "wallace9" )
	thread PlayAnim( wallace9, "capital_ship_wallace_airbase_takeoff" )
	wait( 8.0 )

	local wallace10 = CreatePropDynamic( WALLACE_MODEL, Vector( -10660.0, 7565.7, -6397.3 ), Vector( 0.0, -180.0, 0.0 ) )
	wallace10.SetName( "wallace10" )
	thread PlayAnim( wallace10, "capital_ship_wallace_airbase_takeoff" )
}

function IMCCarrierAlphaFade()
{
	level.nv.imcCarrierAlphaFadeStartTime = Time()
}

function StratonRandomTakeoff()
{
	local door = GetEnt( "runway_door01" )
	while ( true )
	{
		PlayAnim( door, "open" )

		local straton = CreatePropDynamic( STRATON_MODEL, Vector( -6030.0, -5278.0, 104.0 ), Vector( 0.0, 90.0, 0.0 ) )
		waitthread PlayAnim( straton, "st_straton_airbase_takeoff_runaway" )
		straton.Destroy()
		PlayAnim( door, "close" )
		wait( RandomFloat( 3.0, 5.0 ) )
	}
}

function DEV_Setup()
{
	level.isCinematicMode = true
	level.progressEnabled = false
	Evac_SetVDUEvacNag( TEAM_MILITIA, null )
	Evac_SetVDUEvacNag( TEAM_IMC, null )
	Evac_SetVDUPursuitNag( TEAM_MILITIA, null )
	Evac_SetVDUPursuitNag( TEAM_IMC, null )
	Evac_SetVDUEvacProximity( TEAM_MILITIA, null )
	Evac_SetVDUEvacProximity( TEAM_IMC, null )
	Evac_SetVDUPursuitProximity( TEAM_MILITIA, null )
	Evac_SetVDUPursuitProximity( TEAM_IMC, null )
	Evac_SetVDUEvacDustOff( TEAM_MILITIA, null )
	Evac_SetVDUEvacDustOff( TEAM_IMC, null )
	Evac_SetVDUPursuitDustOff( TEAM_MILITIA, null )
	Evac_SetVDUPursuitDustOff( TEAM_IMC, null )
}

function DEV_PreNorthTowerFall()
{
	DEV_Setup()
	thread ProgressStage_PreAlphaTower()
}

function DEV_NorthTowerFall()
{
	DEV_Setup()
	thread ProgressStage_TowerAlphaFall()
}


function DEV_TowerNorthTowerFallPost()
{
	DEV_Setup()
	thread ProgressStage_TowerAlphaFallPost()
}

function DEV_EastTowerFall()
{
	DEV_Setup()
	thread ProgressStage_TowerCharlieFall()
}

function DEV_PreFinalTower()
{
	DEV_Setup()
	thread ProgressStage_PreFinalTower()
}

function DEV_MilitiaWin()
{
	DEV_Setup()
	ServerCommand( "bot" )
	ServerCommand( "bot" )
	ServerCommand( "bot" )

	wait( 0.25 )

	//SetGameWonAnnouncement( "airbase_won_announcement" )
	//SetGameLostAnnouncement( "airbase_lost_announcement" )
	SetGameModeAnnouncement( "airbase_game_mode_announce_at" )

	foreach ( func in level.progressFuncArray )
		if ( func.func != ProgressStage_MatchOver )
		{
			func.called = true
			func.ran = true
		}

	ForceMilitiaWin()
	thread ProgressStage_MatchOver()
}

function DEV_ShipsAttackTower()
{
	thread PlayAnim( level.militiaWinDropship1, "airbase_towerattack_dropship1", level.tower )
	thread PlayAnim( level.militiaWinDropship2, "airbase_towerattack_dropship2", level.tower )
	thread PlayAnim( level.militiaWinStraton1, "airbase_towerattack_straton1", level.tower )
	thread PlayAnim( level.militiaWinStraton2, "airbase_towerattack_straton2", level.tower )
	thread PlayAnim( level.militiaWinBomber, "airbase_towerattack_bomber", level.tower )
}

function DEV_IMCWin()
{
	DEV_Setup()
	ServerCommand( "bot" )
	ServerCommand( "bot" )
	ServerCommand( "bot" )

	wait( 0.25 )

	//SetGameWonAnnouncement( "airbase_won_announcement" )
	//SetGameLostAnnouncement( "airbase_lost_announcement" )
	SetGameModeAnnouncement( "airbase_game_mode_announce_at" )

	foreach ( func in level.progressFuncArray )
		if ( func.func != ProgressStage_MatchOver )
		{
			func.called = true
			func.ran = true
		}

	ForceIMCWin()
	thread ProgressStage_MatchOver()
}

function ScoreTicker( team )
{
	DEV_Setup()
	level.progressEnabled = true
	//SetGameWonAnnouncement( "airbase_won_announcement" )
	//SetGameLostAnnouncement( "airbase_lost_announcement" )
	SetGameModeAnnouncement( "airbase_game_mode_announce_at" )

	while ( GameRules.GetTeamScore( team ) < 250.0 )
	{
		local score = GameRules.GetTeamScore( team )
		if ( score + 1.0 >= 250.0)
		{
			ServerCommand( "bot" )
			ServerCommand( "bot" )
			ServerCommand( "bot" )
		}
		GameRules.SetTeamScore( team, score + 1.0 )
		wait( 0.96 )
	}
}

function DEV_MilitiaScoreTicker()
{
	ScoreTicker( TEAM_MILITIA )
}

function DEV_IMCScoreTicker()
{
	ScoreTicker( TEAM_IMC )
}

function AirBaseSpecificChatter( npc )
{
	Assert( GetMapName() == "mp_airbase" )

	local probability = RandomFloat( 0, 1 )
	if ( probability < 0.04 && level.nv.towerAlphaDown > 0.0 )
	{
		PlaySquadConversationToTeam( "ai_announce_flying_creatures", npc.GetTeam(), npc, AI_FRIENDLY_CHATTER_RANGE_SQR )
		return true
	}
	else if ( probability < 0.08 && level.nv.fightersAttackLevStage > 1 )
	{
		PlaySquadConversationToTeam( "ai_announce_straton_attacks", npc.GetTeam(), npc, AI_FRIENDLY_CHATTER_RANGE_SQR )
		return true
	}

	PlaySquadConversationToTeam( "airbase_grunt_chatter", npc.GetTeam(), npc, AI_FRIENDLY_CHATTER_RANGE_SQR )
	return true //return false if we should not be doing chatter so we can fall through and do other chatter if needed
}

function RunToAnimStartForcedTimeOut( guy, animation_name, reference = null, optionalTag = null, timeOut = null )
{
	guy.EndSignal( "RunToAnimStartForcedTimeOut" )
	thread SetSignalDelayed( guy, "RunToAnimStartForcedTimeOut", timeOut )
	waitthread RunToAnimStartForced( guy, animation_name, reference, optionalTag )
}

function SetSignalDelayed( npc, signal, delay )
{
	wait delay
	if ( IsValid( npc ) )
		npc.Signal( signal )
}

main()