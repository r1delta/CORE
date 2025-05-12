const FX_SPACE_REDEYE_EXPLOSION = "P_exp_redeye_space"
const FX_SPACE_BIRMINGHAM_EXPLOSION = "P_exp_birmingham_space"
const FX_SPACE_ANNAPOLIS_EXPLOSION = "P_exp_annapolis_space"
const FX_SPACE_CARRIER_EXPLOSION = "P_exp_carrier_space"
const FX_SPACE_ARGO_EXPLOSION = "P_exp_annapolis_space"  // TODO: Get a real one for the Argo?
const FX_SPACE_WALLACE_EXPLOSION = "P_exp_wallace_space"

const FX_O2_AIRBURST = "p_exp_redeye_med"

const FX_O2_CRASHBURST 		= "p_exp_redeye_sml"
const FX_O2_CRASHBURST_POV 	= "p_exp_redeye_sml"

const FX_WARP_OUT_ANNAP_SB = "veh_annap_warp_out_SB_1000"
const FX_WARP_OUT_RED_SB = "veh_red_warp_out_full_SB_1000"
const FX_WARP_OUT_BIRM_SB = "veh_birm_warp_out_full_SB_1000"
const FX_WARP_OUT_ARGO_SB = "veh_argo_warp_out_SB_1000"
const FX_WARP_OUT_CARRIER_SB = "veh_carrier_warp_out_full_SB_1000"
const FX_WARP_OUT_WALLACE_SB = "veh_wallace_warp_out_full_SB_1000"

const FX_SPACE_IMC_TRACERS = "P_tracers_carrier_space"
const FX_SPACE_MCOR_TRACERS = "P_tracers_birmingham_space"
const FX_SPACE_IMC_TRACERS2 = "P_tracers_carrier_space2"
const FX_SPACE_MCOR_TRACERS2 = "P_tracers_birmingham_space2"
const FX_SPACE_MCOR_TRACERS_INIT = "P_tracers_birmingham_space_init"
const FX_SPACE_IMC_TRACERS_INIT = "P_tracers_carrier_space_init"

const FX_PIPE_STEAM             = "P_steam_leak_LG"
const FX_PIPE_FIRE              = "P_fire_jet_med"
const FX_EXP_TOWER              = "P_impact_exp_XLG_metal"

const FX_NUKE_SKYBOX			= "P_exp_nuke_SB_1k"

const FX_ROCKET_EXPLOSION_SKYBOX = "P_exp_ship2ship_SB"
const FX_ROCKET_SKYBOX 			 = "Rocket_Smoke_Swirl_SB_o2"
const FX_SHIP_EXPLOSION_SKYBOX   = "P_exp_capital_ship_SB"
const FX_SHIPCRASH_EXPLOSIONS_AND_TRAIL_SKYBOX = "P_crashing_ship_smoke_SB"

const SFX_EXP_LARGE             = "o2_hardpoint_militia_capture_explode"
const SFX_EXP_TOWER             = "corporate_building_explosion"
const SFX_STEAM_LOOP_SMALL      = "o2_hardpoint_steam_loop"
const SFX_STEAM_SHUTOFF			= "o2_steam_shut_off"
const SFX_FIRE_BURST			= "amb_o2_fire_burst"
const SFX_FIRE_SHUTOFF			= "o2_fire_shut_off"
const SFX_CORE_SHUTDOWN			= "o2_facility_shutdown"
const SFX_O2_NUKE_PLAYER		= "O2_Scr_NuclearExplo"
const SFX_AMB_O2_FLEET_BATTLE   = "amb_O2_SkyboxBattle"
const SFX_AMB_O2_REFINERY		= "amb_O2_refinery"
const SFX_SKYBOX_SHIP_WARPOUT	= "O2_Scr_Dropship_Warpout"
const SFX_SKYBOX_FLEET_WARPOUT  = "O2_Scr_FleetMassWarpOut"
const SFX_SKYBOX_FLEET_WARPOUT_2 = "O2_Scr_FleetMassWarpOut_2"
const SFX_TOWER_ELECTRICAL_ARC	= "o2_Giant_Electrical_Arc"

const WARNING_LIGHT_ON_MODEL    = "models/lamps/warning_light_ON_orange.mdl"
const WARNING_LIGHT_OFF_MODEL   = "models/lamps/warning_light.mdl"
const FX_WARNING_LIGHT          = "warning_light_orange_blink"
const FX_WARNING_LIGHT_NOWALL   = "warning_light_orange_blink_nowall"

const FX_BLOOD_SQUIB = "death_pinkmist_trails"

const DP_DOOR_MODEL = "models/vehicle/droppod_fireteam/droppod_fireteam_door.mdl"
const CAPSHIP_BIRM_MODEL_LG = "models/vehicle/capital_ship_birmingham/birmingham_fleetScale.mdl"

const FX_CRASH = "P_impact_dpod_dirt"

const REFINERY_HARDPOINT_ID 	= 1

const MACGUN 	= "models/weapons/m1a1_hemlok/w_hemlok.mdl"
const BLISKGUN 	= "models/weapons/car101/w_car101.mdl"
const O2FUELROD = "models/levels_terrain/mp_o2/mp_o2_fuel_rod.mdl"
const DOORIMC64_MODEL = "models/door/door_imc_interior_split_64_animated.mdl"
const OPAQUE_PIECE = "models/domestic/floor_mat_black_01.mdl"
const KNIFE_MODEL = "models/weapons/combat_knife/w_combat_knife.mdl"

const FX_ENDING_NUKE = "P_exp_nuke_SB_1k_surface"

function main()
{
	IncludeFile( "mp_o2_shared" )
	IncludeFile( "client/cl_carrier" ) //Included for skyshow dogfights
	IncludeFile( "client/levels/cl_mp_o2_ending" )

	IncludeFileAllowMultipleLoads( "client/objects/cl_hornet_fighter" )
	IncludeFileAllowMultipleLoads( "client/objects/cl_phantom_fighter" )
	IncludeFileAllowMultipleLoads( "client/objects/cl_redeye" )
	IncludeFileAllowMultipleLoads( "client/objects/cl_imc_carrier" )
	IncludeFileAllowMultipleLoads( "client/objects/cl_annapolis" )
	IncludeFileAllowMultipleLoads( "client/objects/cl_birmingham" )
	IncludeFileAllowMultipleLoads( "client/objects/cl_bomber" )
	IncludeFileAllowMultipleLoads( "client/objects/cl_ai_turret" )

	FlagInit( "PostWorldSettings" )
	FlagInit( "StopSunAnim" )
	FlagInit( "StopInGameArmadaFX" )
	FlagInit( "PauseInGameArmadaExplosions" )
	FlagInit( "InGameArmadasWarpOut" )
	FlagInit( "SunDirections" )
	FlagInit( "EntsSetup" )
	FlagInit( "EvacInSpace" )
	FlagInit( "IMCKillDrones" )
	FlagInit( "IMCStartDrones" )
	FlagInit( "HardpointSetupDone" )
	FlagInit( "MegaCarrierArrives" )
	FlagInit( "CoreDestabalized" )
	FlagInit( "EpilogueStarts" )
	FlagInit( "IntroDone" )
	FlagInit( "O2BloomSetting")
	FlagInit( "WinnerDetermined" )
	FlagInit( "MilitiaIntroEyesOpen" )

	RegisterSignal( "Birm1RandomFX" )
	RegisterSignal( "DoingDeathAnim" )
	RegisterSignal( "cl_airburst_01" )
	RegisterSignal( "cl_airburst_02" )
	RegisterSignal( "cl_airburst_03" )
	RegisterSignal( "cl_airburst_04" )
	RegisterSignal( "cl_airburst_05" )
	RegisterSignal( "StopFireFXThink" )
	RegisterSignal( "StopTowerExplosions" )
	RegisterSignal( "TowerExplosionsThink" )
	RegisterSignal( "idling" )

	PrecacheParticleSystem( FX_SPACE_REDEYE_EXPLOSION )
	PrecacheParticleSystem( FX_SPACE_BIRMINGHAM_EXPLOSION )
	PrecacheParticleSystem( FX_SPACE_ANNAPOLIS_EXPLOSION )
	PrecacheParticleSystem( FX_SPACE_CARRIER_EXPLOSION )
	PrecacheParticleSystem( FX_SPACE_WALLACE_EXPLOSION )
	PrecacheParticleSystem( FX_SPACE_IMC_TRACERS )
	PrecacheParticleSystem( FX_SPACE_MCOR_TRACERS )
	PrecacheParticleSystem( FX_SPACE_IMC_TRACERS2 )
	PrecacheParticleSystem( FX_SPACE_MCOR_TRACERS2 )
	PrecacheParticleSystem( FX_SPACE_MCOR_TRACERS_INIT )
	PrecacheParticleSystem( FX_SPACE_IMC_TRACERS_INIT )
	PrecacheParticleSystem( FX_BLOOD_SQUIB )
	PrecacheParticleSystem( FX_WARNING_LIGHT )
	PrecacheParticleSystem( FX_WARNING_LIGHT_NOWALL )
	PrecacheParticleSystem( FX_PIPE_STEAM )
 	PrecacheParticleSystem( FX_EXP_TOWER )
 	PrecacheParticleSystem( FX_PIPE_FIRE )
 	PrecacheParticleSystem( FX_NUKE_SKYBOX )
	PrecacheParticleSystem( FX_O2_AIRBURST )
	PrecacheParticleSystem( FX_O2_CRASHBURST )
	PrecacheParticleSystem( FX_O2_CRASHBURST_POV )
	PrecacheParticleSystem( FX_WARP_OUT_ANNAP_SB )
	PrecacheParticleSystem( FX_WARP_OUT_RED_SB )
	PrecacheParticleSystem( FX_WARP_OUT_BIRM_SB )
	PrecacheParticleSystem( FX_WARP_OUT_ARGO_SB )
	PrecacheParticleSystem( FX_WARP_OUT_CARRIER_SB )
	PrecacheParticleSystem( FX_WARP_OUT_WALLACE_SB )
	PrecacheParticleSystem( FX_ROCKET_EXPLOSION_SKYBOX )
	PrecacheParticleSystem( FX_ROCKET_SKYBOX )
	PrecacheParticleSystem( FX_SHIP_EXPLOSION_SKYBOX )
	PrecacheParticleSystem( FX_SHIPCRASH_EXPLOSIONS_AND_TRAIL_SKYBOX )
	PrecacheParticleSystem( "P_fire_med_FULL" )
	PrecacheParticleSystem( "P_fire_grass" )
	PrecacheParticleSystem( "P_fire_small_FULL" )
	PrecacheParticleSystem( "P_fire_tiny_FULL" )
	PrecacheParticleSystem( FX_ENDING_NUKE )

	PrecacheWeapon( "mp_weapon_mega_turret_aa" )

	Globalize( ServerCallback_TonemappingNuke )
	Globalize( ServerCallback_O2CrashBurst )
	Globalize( ServerCallback_ScreenShakeOzone )
	Globalize( ServerCallback_NukePlayers )
	Globalize( CE_O2VisualSettingsSpaceIMC )
	Globalize( CE_O2VisualSettingsSpaceMCOR )
	Globalize( CE_O2VisualSettingsTransition )
	Globalize( CE_O2VisualSettingsEject )
	Globalize( CE_O2VisualSettingsEvac )
	Globalize( CE_O2VisualSettingsWorldIMC )
	Globalize( CE_O2VisualSettingsWorldMCOR )
	Globalize( CE_O2BloomOnRampOpen )
	Globalize( CE_O2BloomOnRampOpenIMC )
	Globalize( CE_O2SkyScaleShipOnRampClose )
	Globalize( CE_O2SkyScaleShipEnterAtmos )
	Globalize( CE_02AirBurstEvents )
	Globalize( CE_O2Wakeup )
	Globalize( CE_O2SmokePlumes )
	Globalize( CE_O2BlackOut )
	Globalize( CE_O2CrashVisual )
	Globalize( DEV_TeamFX )
	Globalize( DEV_TestNukeFX )
	Globalize( UpdateTowerExplosions )
	Globalize( ShowVDU_ArmadaBattle )

	level.fleetIntroTravelTime 		<- 400
	level.fleetArrivalTimeModifier  <- 0.6
	level.clusterDestroyDelay       <- 45
	level.minClusterCount 			<- 4   		// Make sure we have a decent sized skyshow at the end of the level
	level.minClusterShipKillDelay	<- 30
	level.maxClusterShipKillDelay 	<- 90
	level.independentShips          <- []
	level.hardpointSearchRadius 	<- []
	level.towerExpFxArray 			<- null
	level.steamSFXRadiusSqr 		<- 0
	level.steamSFXRadiusSqr 		= pow( GetSoundRadius( SFX_STEAM_LOOP_SMALL ), 2 )
	level.sfxArcPos					<- Vector( -323, 255, 1248 )

	if( GetCPULevel() != CPU_LEVEL_HIGHEND )
		level.clusterDestroyDelay = 60

	RegisterServerVarChangeCallback( "gameState", O2GameStateChanged )
	RegisterServerVarChangeCallback( "IMCClientTiming", IMCClientTimingFlags )
	RegisterServerVarChangeCallback( "megaCarrier", MegaCarrier_Changed )
	RegisterServerVarChangeCallback( "matchProgressMilestone", MatchProgressMilestone_Changed )
	RegisterServerVarChangeCallback( "introDone", IntroDone_Changed )

	AddCreateCallback( "info_hardpoint", OnHardpointCreated )

	if( O2_DEV_DISABLE_SKYSHOW )
		return

	InitSkyshowArmadaData()
	CreateSkyshowArmadas()
	O2_IngameArmadaSetGoals( 350, 40, -60 )

	if( GetCinematicMode() )
		IntroScreen_Setup()

	SetFullscreenMinimapParameters( 3.2, 0, -1200, 180 )
	if ( GAMETYPE == COOPERATIVE )
		SetCustomMinimapZoom( 2 )
}

function IntroScreen_Setup()
{
	CinematicIntroScreen_SetText( TEAM_IMC, 	[ "#INTRO_SCREEN_O2_LINE1", "#INTRO_SCREEN_O2_LINE2", "#INTRO_SCREEN_O2_LINE3" ] )
	CinematicIntroScreen_SetText( TEAM_MILITIA, [ "#INTRO_SCREEN_O2_LINE1", "#INTRO_SCREEN_O2_LINE2", "#INTRO_SCREEN_O2_LINE3" ] )
	CinematicIntroScreen_SetQuickIntro( TEAM_MILITIA )
}

function EntitiesDidLoad()
{
	level.hardpointSearchRadius.append( 1200 ) // 0 = a
	level.hardpointSearchRadius.append( 1300 ) // 1 = b
	level.hardpointSearchRadius.append( 1600 ) // 2 = c

	level.towerExpFxArray = GetClientEntArray( "info_target_clientside", "hardpoint_tower_exp_fx" )

	//setup ents with targets
	FlagSet( "EntsSetup" )

	if ( GameRules.GetGameMode() == CAPTURE_POINT )
		O2_HardpointSetup()

	HideEndingArmada()
	thread StartSkyboxTracers()
	thread SetupMegaTurrets()

	if( !O2_DEV_DISABLE_SKYSHOW )
		thread O2_ArmadaThink()
}

function SetupMegaTurrets()
{
	local turrets = GetNPCArrayByClass( "npc_turret_mega" )
	foreach ( turret in turrets )
		SetHealthBarVisibilityOnEntity( turret, false )
}

function IMCClientTimingFlags()
{
	if ( level.nv.IMCClientTiming > 0 )
		FlagSet( "IMCStartDrones" )

	if ( level.nv.IMCClientTiming < 0 )
		FlagSet( "IMCKillDrones" )
}

function IntroDone_Changed()
{
	local introDone = level.nv.introDone
	if ( !introDone )
		return

	FlagSet( "IntroDone" )
}

function MatchProgressMilestone_Changed()
{
	local matchProgressMilestone = level.nv.matchProgressMilestone

	if ( !matchProgressMilestone )
		return

	switch ( matchProgressMilestone )
	{
		case 15:
			if ( GetCinematicMode() && GameRules.GetGameMode() == CAPTURE_POINT )
				waitthread StoryBlurb1()
			break

		case 25:
			if ( GetCinematicMode() && ( GameRules.GetGameMode() == CAPTURE_POINT ) )
					delaythread( 1.5 ) ShowVDU_Tower( 7 )
			break

		case 40:
			if ( GetCinematicMode() && GameRules.GetGameMode() == CAPTURE_POINT )
				waitthread StoryBlurb2()
			break

		case 45:
			if ( GetCinematicMode() && GameRules.GetGameMode() == CAPTURE_POINT )
					delaythread( level.redeyeAttackDuration + 2 ) ShowVDU_ArmadaBattle( 15 )
			break

		case 60:
			if ( GetCinematicMode() && GameRules.GetGameMode() == CAPTURE_POINT )
				waitthread StoryBlurb3()
			break

		case 80:
			if ( GetCinematicMode() && GameRules.GetGameMode() == CAPTURE_POINT )
				waitthread StoryBlurb4()
			break

		case 90:
			thread SecondRedeyeAndCarrierBattle()
			break

		case 98:
			break
	}
}

function O2GameStateChanged()
{
	switch ( GetGameState() )
	{
		case eGameState.Prematch:
			if ( GetCinematicMode() )
			{
				if ( GetLocalViewPlayer().GetTeam() == TEAM_IMC )
				{
					IMCArmadaFXMain()
					thread NPCDropPodsMain()
				}
				else
					MCORArmadaFXMain()
			}
			else
				O2Bloom()
			break

		case eGameState.Playing:
			O2Bloom()
			thread AmbientFleetSoundThink()
			if ( GetCinematicMode() && GameRules.GetGameMode() == CAPTURE_POINT )
				AddSpeakerToBlacklist( "blisk" )
			break

		case eGameState.WinnerDetermined:
			O2Bloom()
			if ( GetCinematicMode() && GameRules.GetGameMode() == CAPTURE_POINT )
				thread EndTheStory()
			break

		case eGameState.Epilogue:
			FlagSet( "EpilogueStarts" )
			thread EvacEventsMain()

			if ( GameRules.GetGameMode() == CAPTURE_POINT )
				thread UpdateTowerExplosions()

			if ( GetCinematicMode() && GameRules.GetGameMode() == CAPTURE_POINT )
			{
				RemoveSpeakerFromBlacklist( "blisk" )
				thread InGameArmadasWarpOut()
			}

			break
	}
}

function StartSkyboxTracers()
{
	if ( GetCinematicMode() && GameRules.GetGameMode() == CAPTURE_POINT )
		FlagWait( "IntroDone" )
	thread FractureSkyboxTracers_StartAll()
}

function IsPlayerOnIntroRef()
{
	if ( GetLocalClientPlayer().GetCinematicEventRef() != null )
		return true
}


/************************************************************************************************\

#### ##     ##  ######        ##    ## ########   ######
 ##  ###   ### ##    ##       ###   ## ##     ## ##    ##
 ##  #### #### ##             ####  ## ##     ## ##
 ##  ## ### ## ##             ## ## ## ########  ##
 ##  ##     ## ##             ##  #### ##        ##
 ##  ##     ## ##    ##       ##   ### ##        ##    ##
#### ##     ##  ######        ##    ## ##         ######

\************************************************************************************************/
function NPCDropPodsMain()
{
	FlagWait( "IMCStartDrones" )

	if ( Flag( "IMCKillDrones" ) )
		return

	local refs = GetClientEntArray( "info_target_clientside", "imc_npc_droppods" )
	local deltaTime = Time() - level.nv.IMCClientTiming

	foreach( index, ref in refs )
		thread NPCDropPods( ref, index, refs.len(), deltaTime )
}

function NPCDropPods( ref, index, max, deltaTime )
{
	local origin = ref.GetOrigin()
	local angles = ref.GetAngles()
	ref.Kill()

	local baseTime 	= 1 + deltaTime

	local totalTime = 1.0
	local increment = totalTime / max
	local randTime 	= index * increment

	local skipTime	= baseTime + randTime

	local node = CreateClientsideScriptMover( "models/dev/empty_model.mdl", origin, angles )
	node.DisableDraw()
	local droppod 	= CreatePropDynamic( DROPPOD_MODEL, node.GetOrigin() )
	droppod.SetParent( node )
	droppod.s.door 	<- CreateClientDPDoor( droppod )
	droppod.s.door.MarkAsNonMovingAttachment()
	droppod.s.squad <- CreateDPSquad( droppod )

	OnThreadEnd(
		function() : ( droppod, node )
		{
			if ( IsValid( node ) )
				node.Kill()
			if ( IsValid( droppod.s.door ) )
				droppod.s.door.Kill()
			foreach( guy in droppod.s.squad )
			{
				if ( IsValid( guy ) )
					guy.Kill()
			}
			if ( IsValid( droppod ) )
				droppod.Kill()
		}
	)

	if ( Flag( "IMCKillDrones" ) )
		return
	FlagEnd( "IMCKillDrones" )

	local dpAnim = "dp_droppod_ready"
	local squadAnims = [
		"pt_droppod_ready_front_R",
		"pt_droppod_ready_front_L",
		"pt_droppod_ready_back_R",
		"pt_droppod_ready_back_L"
	]

	local sceneTime = 23

	local animTime = droppod.GetSequenceDuration( dpAnim )
	if ( skipTime >= animTime )
		return

	if ( skipTime > sceneTime )
		return

	thread PlayAnimTeleport( droppod, dpAnim, node )
	droppod.Anim_SetInitialTime( skipTime )

	foreach( index, guy in droppod.s.squad )
	{
		thread PlayAnimTeleport( guy, squadAnims[ index ], droppod, "ORIGIN" )
		guy.Anim_SetInitialTime( skipTime )
	}

	local tubeTime = sceneTime - skipTime
	wait tubeTime

	local movetime = 3.0
	node.NonPhysicsRotateTo( node.GetAngles() + Vector( 0,90,0 ), movetime, movetime * 0.1, 0 )
	node.NonPhysicsMoveTo( node.GetOrigin() + Vector( 0,0,-200 ), movetime, movetime * 0.1, 0 )

	wait movetime
}

function CreateClientDPDoor( pod )
{
	local attachment = "hatch"
	local attachIndex = pod.LookupAttachment( attachment )
	local origin = pod.GetAttachmentOrigin( attachIndex )
	local angles = pod.GetAttachmentAngles( attachIndex )

	local door = CreatePropDynamic( DP_DOOR_MODEL, origin, angles )
	door.SetParent( pod, "HATCH" )

	return door
}

function CreateDPSquad( droppod )
{
	local squad = []
	local origin = droppod.GetOrigin()

	for ( local i = 0; i< 4; i++ )
	{
		local guy = CreatePropDynamic( TEAM_IMC_GRUNT_MDL, origin )
		guy.SetParent( droppod, "ORIGIN" )
		guy.MarkAsNonMovingAttachment()
		squad.append( guy )
	}

	return squad
}

/************************************************************************************************\

   ###    ########  ##     ##    ###    ########     ###          ##        #######   ######   ####  ######
  ## ##   ##     ## ###   ###   ## ##   ##     ##   ## ##         ##       ##     ## ##    ##   ##  ##    ##
 ##   ##  ##     ## #### ####  ##   ##  ##     ##  ##   ##        ##       ##     ## ##         ##  ##
##     ## ########  ## ### ## ##     ## ##     ## ##     ##       ##       ##     ## ##   ####  ##  ##
######### ##   ##   ##     ## ######### ##     ## #########       ##       ##     ## ##    ##   ##  ##
##     ## ##    ##  ##     ## ##     ## ##     ## ##     ##       ##       ##     ## ##    ##   ##  ##    ##
##     ## ##     ## ##     ## ##     ## ########  ##     ##       ########  #######   ######   ####  ######

\************************************************************************************************/
function InitSkyshowArmadaData()
{
	level.skyshowFleetData <- {}
	level.skyshowFleetData[ TEAM_IMC ] <- []
	level.skyshowFleetData[ TEAM_MILITIA ] <- []

	level.skyshowShips <- {}
	level.skyshowShips[ TEAM_IMC ] <- []
	level.skyshowShips[ TEAM_MILITIA ] <- []

	level.shipClusterToShip <- {}
	level.shipClusterToShip[ FLEET_MCOR_ANNAPOLIS_1000X ] 												<- FLEET_MCOR_ANNAPOLIS_1000X
	level.shipClusterToShip[ FLEET_CAPITAL_SHIP_ARGO_1000X ] 											<- FLEET_CAPITAL_SHIP_ARGO_1000X
	level.shipClusterToShip[ "models/vehicle/space_cluster/redeye_space_clustera1000x.mdl" ] 			<- FLEET_MCOR_REDEYE_1000X
	level.shipClusterToShip[ "models/vehicle/space_cluster/redeye_space_clusterb1000x.mdl" ] 			<- FLEET_MCOR_REDEYE_1000X
	level.shipClusterToShip[ "models/vehicle/space_cluster/redeye_space_clusterc1000x.mdl" ]			<- FLEET_MCOR_REDEYE_1000X
	level.shipClusterToShip[ "models/vehicle/space_cluster/birmingham_space_clustera1000x.mdl" ] 		<- FLEET_MCOR_BIRMINGHAM_1000X
	level.shipClusterToShip[ "models/vehicle/space_cluster/imc_carrier_space_clustera_1000x.mdl" ] 		<- FLEET_IMC_CARRIER_1000X
	level.shipClusterToShip[ "models/vehicle/space_cluster/imc_carrier_space_clusterb_1000x.mdl" ] 		<- FLEET_IMC_CARRIER_1000X
	level.shipClusterToShip[ "models/vehicle/space_cluster/imc_carrier_space_clusterc_1000x.mdl" ] 		<- FLEET_IMC_CARRIER_1000X
	level.shipClusterToShip[ "models/vehicle/capital_ship_wallace/capital_ship_wallace_1000x.mdl" ] 	<- FLEET_IMC_WALLACE_1000x
	level.shipClusterToShip[ "models/vehicle/space_cluster/ship_wallace_clustera_1000x.mdl" ] 			<- FLEET_IMC_WALLACE_1000x
	level.shipClusterToShip[ "models/vehicle/space_cluster/ship_wallace_clusterb_1000x.mdl" ] 			<- FLEET_IMC_WALLACE_1000x
	level.shipClusterToShip[ "models/vehicle/space_cluster/ship_wallace_clusterc_1000x.mdl" ] 			<- FLEET_IMC_WALLACE_1000x

	level.shipToWarpOutFX <- {}
	level.shipToWarpOutFX[ FLEET_MCOR_ANNAPOLIS_1000X ] 	<- FX_WARP_OUT_ANNAP_SB
	level.shipToWarpOutFX[ FLEET_CAPITAL_SHIP_ARGO_1000X ] 	<- FX_WARP_OUT_ARGO_SB
	level.shipToWarpOutFX[ FLEET_IMC_CARRIER_1000X ] 		<- FX_WARP_OUT_CARRIER_SB
	level.shipToWarpOutFX[ FLEET_IMC_WALLACE_1000x ] 		<- FX_WARP_OUT_WALLACE_SB
	level.shipToWarpOutFX[ FLEET_MCOR_REDEYE_1000X ] 		<- FX_WARP_OUT_RED_SB
	level.shipToWarpOutFX[ FLEET_MCOR_BIRMINGHAM_1000X ] 	<- FX_WARP_OUT_BIRM_SB
	level.shipToWarpOutFX[ "models/vehicle/capital_ship_Birmingham/birmingham_fleetscale_1000x.mdl" ] <- FX_WARP_OUT_BIRM_SB

	// Exported from map using DEV_ExportArmadaData()
	CreateShipData( "models/vehicle/capital_ship_annapolis/annapolis_fleetscale_1000x.mdl", Vector( 12027, 4581, -12643 ), Vector( 0, 32.124, 0 ), TEAM_MILITIA )
	CreateShipData( "models/vehicle/capital_ship_argo/capital_ship_argo_1000x.mdl", Vector( 11903, 4722, -12640 ), Vector( 0, 31.8164, 0 ), TEAM_IMC )

	CreateShipData( "models/vehicle/space_cluster/redeye_space_clustera1000x.mdl", Vector( 12043, 4592, -12636 ), Vector( 0, 29.1357, 0 ), TEAM_MILITIA )
	CreateShipData( "models/vehicle/space_cluster/redeye_space_clusterb1000x.mdl", Vector( 12071, 4617, -12664 ), Vector( 0, 29.1357, 0 ), TEAM_MILITIA )
	CreateShipData( "models/vehicle/space_cluster/redeye_space_clusterc1000x.mdl", Vector( 11994, 4569, -12665 ), Vector( 0, 29.1357, 0 ), TEAM_MILITIA )
	CreateShipData( "models/vehicle/space_cluster/birmingham_space_clustera1000x.mdl", Vector( 12029, 4562, -12580 ), Vector( 0, 29.1357, 0 ), TEAM_MILITIA )
	CreateShipData( "models/vehicle/space_cluster/birmingham_space_clustera1000x.mdl", Vector( 11959, 4536, -12618 ), Vector( 0, 29.1357, 0 ), TEAM_MILITIA )
	CreateShipData( "models/vehicle/space_cluster/birmingham_space_clustera1000x.mdl", Vector( 11956, 4535, -12659 ), Vector( 0, 29.1357, 0 ), TEAM_MILITIA )

	CreateShipData( "models/vehicle/space_cluster/imc_carrier_space_clustera_1000x.mdl", Vector( 11952, 4731, -12651 ), Vector( 0, 31.8164, 0 ), TEAM_IMC )
	CreateShipData( "models/vehicle/space_cluster/imc_carrier_space_clusterb_1000x.mdl", Vector( 11997, 4761, -12661 ), Vector( 0, 31.8164, 0 ), TEAM_IMC )
	CreateShipData( "models/vehicle/space_cluster/imc_carrier_space_clusterc_1000x.mdl", Vector( 11837, 4747, -12604 ), Vector( 0, 31.8164, 0 ), TEAM_IMC )
	CreateShipData( "models/vehicle/space_cluster/ship_wallace_clustera_1000x.mdl", Vector( 11921, 4782, -12657 ), Vector( 0, 31.8164, 0 ), TEAM_IMC )
	CreateShipData( "models/vehicle/space_cluster/ship_wallace_clusterb_1000x.mdl", Vector( 11890, 4719, -12579 ), Vector( 0, 31.8164, 0 ), TEAM_IMC )
	CreateShipData( "models/vehicle/space_cluster/ship_wallace_clusterc_1000x.mdl", Vector( 11857, 4697, -12671 ), Vector( 0, 31.8164, 0 ), TEAM_IMC )

	if( GetCPULevel() == CPU_LEVEL_HIGHEND )
	{
		CreateShipData( "models/vehicle/space_cluster/redeye_space_clustera1000x.mdl", Vector( 12015, 4572, -12665 ), Vector( 0, 29.1357, 0 ), TEAM_MILITIA )
		CreateShipData( "models/vehicle/space_cluster/redeye_space_clusterc1000x.mdl", Vector( 11945, 4552, -12628 ), Vector( 0, 29.1357, 0 ), TEAM_MILITIA )
		CreateShipData( "models/vehicle/space_cluster/birmingham_space_clustera1000x.mdl", Vector( 12070, 4614, -12650 ), Vector( 0, 29.1357, 0 ), TEAM_MILITIA )
		CreateShipData( "models/vehicle/space_cluster/imc_carrier_space_clustera_1000x.mdl", Vector( 11872, 4683, -12668 ), Vector( 0, 31.8164, 0 ), TEAM_IMC )
		CreateShipData( "models/vehicle/space_cluster/imc_carrier_space_clusterc_1000x.mdl", Vector( 11880, 4755, -12668 ), Vector( 0, 31.8164, 0 ), TEAM_IMC )
		CreateShipData( "models/vehicle/space_cluster/ship_wallace_clusterb_1000x.mdl", Vector( 11862, 4712, -12621 ), Vector( 0, 31.8164, 0 ), TEAM_IMC )
	}
}

function ShouldSkipFleetTravel()
{
	if( Time() >= level.fleetIntroTravelTime * level.fleetArrivalTimeModifier )  // level.fleetArrivalTimeModifier because this is around when the fleet first arrives and then takes a lot of time to reach final spot due to damping
		return true

	return false
}

function CreateShipData( model, origin, angles, team )
{
	// Lower to the ground a bit so the reduced fleet sizes don't look bad
	if( GetCPULevel() != CPU_LEVEL_HIGHEND )
		origin = origin - Vector(0 ,0, 10)

	local shipData = {}
	shipData.model <- model
	shipData.origin <- origin
	shipData.angles <- angles

	level.skyshowFleetData[ team ].append( shipData )
}

function CreateSkyshowArmadas()
{
	foreach ( team, teamShips in level.skyshowFleetData )
	{
		foreach ( shipData in teamShips )
		{
			local ship = CreateClientsideScriptMover( shipData.model, shipData.origin, shipData.angles )
			ship.EnableRenderAlways()
			ship.s.startPos	<- ship.GetOrigin()
			ship.s.endPos 	<- null
			ship.s.speedModifier <- ArmadaGetSpeedModifier( shipData.model )

			Assert( ship.GetModelName() != "?")

			level.skyshowShips[ team ].append( ship )
		}
	}
}

function O2_ArmadaThink()
{
	if ( GetCinematicMode() && GameRules.GetGameMode() == CAPTURE_POINT )
		FlagWait( "IntroDone" )

	thread InGameArmadaFXMain()
	thread O2_ArmadaMove()
	thread ClusterShipsBattleThink()
	thread ClusterShipsFireRocketsThink()
}

function GetRandomShipCluster( team )
{
	local clusterCount 			= level.skyshowShips[ team ].len()
	Assert( clusterCount > 0 )

	local randomClusterIndex 	= RandomInt( 0, clusterCount-1 )
	local shipCluster 			= level.skyshowShips[ team ][ randomClusterIndex ]

	return shipCluster
}

function GetRandomShipAttachIdxInCluster( shipCluster )
{
	if( !IsValid( shipCluster ) )
		return

	local attach 	= ArmadaGetAttach( shipCluster.GetModelName() )
	local groupNum 	= ArmadaGetGroupNum( shipCluster.GetModelName() )

	Assert( attach != null )
	Assert( groupNum != null )

	// Pick a random ship from the cluster
	local randomShipIndex = RandomInt( 0, groupNum-1 )
	local attachIdx = GetShipAttachID( shipCluster, attach, groupNum, randomShipIndex )

	// These start at 1 so just pick a new one if it comes back zero...
	if( attachIdx <= 0 )
		attachIdx = 1

	return attachIdx
}

function ClusterShipsFireRocketsThink()
{
	if( Flag( "EpilogueStarts" ) )
		return
	FlagEnd( "EpilogueStarts" )

	local team 			= TEAM_MILITIA
	local targetTeam 	= TEAM_IMC
	local clusterCount 	= 0
	local rocketSpeed 	= 50

	while( 1 )
	{
		PerfStart( PerfIndexClient.ClusterShipsFireRocketsThink )

		if( team == TEAM_IMC )
			targetTeam = TEAM_MILITIA
		else
			targetTeam = TEAM_IMC

		// If either side doesn't have enough ships, then we're done
		clusterCount = level.skyshowShips[ team ].len()
		if (clusterCount < 1 )
		{
			PerfEnd( PerfIndexClient.ClusterShipsFireRocketsThink )
			return
		}
		clusterCount = level.skyshowShips[ targetTeam ].len()
		if (clusterCount < 1 )
		{
			PerfEnd( PerfIndexClient.ClusterShipsFireRocketsThink )
			return
		}

		// Pick a random cluster on the target team
		local friendlyShipCluster 	= GetRandomShipCluster( team )
		local targetShipCluster 	= GetRandomShipCluster( targetTeam )

		// Pick a random attacking ship and target ship & get their pos/angles
		local friendlyShipIndex 	= GetRandomShipAttachIdxInCluster( friendlyShipCluster )
		local targetShipIndex	 	= GetRandomShipAttachIdxInCluster( targetShipCluster )
		local startPos 				= friendlyShipCluster.GetAttachmentOrigin( friendlyShipIndex )
		local startAngles 			= friendlyShipCluster.GetAttachmentAngles( friendlyShipIndex )
		local endPos 				= targetShipCluster.GetAttachmentOrigin( targetShipIndex )
		local endAngles 			= targetShipCluster.GetAttachmentAngles( targetShipIndex )
		local doExplosion           = false

		if( ( GetCPULevel() == CPU_LEVEL_DURANGO ) || ( GetCPULevel() == CPU_LEVEL_HIGHEND ) )
			doExplosion = true

		thread MagicMissile( startPos, endPos, rocketSpeed, FX_ROCKET_EXPLOSION_SKYBOX, FX_ROCKET_SKYBOX, doExplosion )

		// Let the other team shoot next
		if( team == TEAM_IMC )
			team = TEAM_MILITIA
		else
			team = TEAM_IMC

		PerfEnd( PerfIndexClient.ClusterShipsFireRocketsThink )

		wait RandomFloat( 1.0, 2.0 )
	}
}

function ClusterShipsBattleThink()
{
	// NOTE: We do not want a FlagEnd here because we need the loop below to finish doing things with the cluster it is working on before we exit
	if( Flag( "EpilogueStarts" ) )
		return

	local team = TEAM_MILITIA
	local attachIdx = 1 	// 1 always exists on these ships

	while( 1 )
	{
		local attachAnglesAdjustment 	= GetClusterAnglesAdjustment( team )
		local clusterCount 	= level.skyshowShips[ team ].len()
		if (clusterCount <= level.minClusterCount )
			break

		local randomClusterIndex 	= RandomInt( 0, clusterCount-1 )
		local shipCluster 			= level.skyshowShips[ team ][ randomClusterIndex ]

		// These two ships stay till the end of the level
		local modelname = shipCluster.GetModelName()
		if( ( modelname == FLEET_MCOR_ANNAPOLIS_1000X ) || ( modelname == FLEET_CAPITAL_SHIP_ARGO_1000X ) )
			continue

		local ships = CreateIndividualShipsFromCluster( shipCluster, attachAnglesAdjustment )

		// Remove the cluster from level data
		level.skyshowShips[ team ].remove( randomClusterIndex )

		// Have each ship start going a different direction for visual variety
		ClusterShipsAltersCourse( ships, team )

		// Doom these ships
		DoomClusterShips( ships, team, attachIdx )

		// Next team gets to lose a cluster
		if( team == TEAM_IMC )
			team = TEAM_MILITIA
		else
			team = TEAM_IMC

		wait level.clusterDestroyDelay

		// If the epilogue started while we were dealing with that last cluster, then abort
		if( Flag( "EpilogueStarts" ) )
			return
	}
}

function DoomClusterShips( ships, team, attachIdx )
{
	foreach ( ship in ships )
	{
		if( !IsValid( ship ) )
			continue

		local attach 	= ArmadaGetAttach( ship.GetModelName() )
		local groupNum 	= ArmadaGetGroupNum( ship.GetModelName() )

		local delay = RandomFloat( level.minClusterShipKillDelay, level.maxClusterShipKillDelay )
		thread ClusterShipNoseDivesThenExplodes( team, ship, attach, groupNum, attachIdx, delay )
	}
}

function ClusterShipsAltersCourse( ships, team )
{
	if( Flag( "EpilogueStarts" ) )
		return
	FlagEnd( "EpilogueStarts" )

	foreach ( ship in ships )
	{
		if( !IsValid( ship ) )
			continue

		local forward = 350
		local right   = RandomInt( 0, 200 )

		// Only go AWAY from the playable level to be safe and avoid a ship crashing into it...
		if( team == TEAM_IMC )
			right *= -1

		local moveVector = ship.GetForwardVector() * forward
		moveVector += ship.GetRightVector() * right
		ship.s.endPos = ship.GetOrigin() + moveVector

		local rotateToVector = ship.s.endPos - ship.GetOrigin()
		local angles = rotateToVector.GetAngles()
		local speedModifier = ArmadaGetSpeedModifier( ship.GetModelName() )
		local shipMoveTime = level.fleetIntroTravelTime * speedModifier * 0.5  // We want these to stand out so go twice as fast

		ship.NonPhysicsMoveTo( ship.s.endPos, shipMoveTime, 0, 0 )
		ship.NonPhysicsRotateTo( angles, 10, 0, 0 )

		wait RandomInt( 1, 3 )
	}
}

function ClusterShipNoseDivesThenExplodes( team, ship, attach, groupNum, attachIdx, delay )
{
	if( Flag( "EpilogueStarts" ) )
		return
	FlagEnd( "EpilogueStarts" )

	wait delay

	if( !IsValid( ship ) )
		return

	local shipOrigin 	= ship.GetOrigin()
	local noseDiveTime 	= 55
	local randomX 		= RandomInt( 50, 100 )
	local randomY 		= 0
	local explodeZ 		= RandomInt( -60, -55 )
	local randomPitch 	= RandomInt( 40, 50 )
	local randomRoll 	= 0

	ship.s.isCrashing 	= true

	// Lots of explosions & smoke trail on this ship prior to death
	local effectIndex = GetParticleSystemIndex( FX_SHIPCRASH_EXPLOSIONS_AND_TRAIL_SKYBOX )
	StartParticleEffectOnEntity( ship, effectIndex, FX_PATTACH_POINT_FOLLOW, attachIdx )

	// Make the ship vear AWAY from the playable level
	if( team == TEAM_IMC )
	{
		randomY 	= RandomInt( 50, 100 )
		randomRoll 	= RandomInt( -45, -90 )
	}
	else
	{
		randomY 	= RandomInt( -50, -100 )
		randomRoll	= RandomInt( 45, 90 )
	}

	ship.NonPhysicsMoveTo( ship.GetOrigin() + Vector( randomX, randomY, explodeZ ), noseDiveTime, 0, 0 )
	ship.NonPhysicsRotateTo( ship.GetAngles() + Vector( randomPitch, 0, randomRoll ), noseDiveTime, 0, 0 )

	wait noseDiveTime

	if( !IsValid( ship ) )
		return

	ClusterShipExplodes( ship, attachIdx )
	RemoveIndieShipFromLevel( ship )
}

function ClusterShipExplodes( ship, attachIdx )
{
	local effectIndex = GetParticleSystemIndex( FX_SHIP_EXPLOSION_SKYBOX )
	StartParticleEffectInWorld( effectIndex, ship.GetOrigin(), Vector( 0,0,0 ) )
	wait 0.2
	ship.Kill()
}

function RemoveIndieShipFromLevel( ship )
{
	// Find and remove the reference to this ship in our list of indie skybox ships
	local index = null
	foreach ( idx, arrayShip in level.independentShips )
	{
		if( arrayShip == ship )
		{
			index = idx
			break
		}
	}

	if( index != null )
		level.independentShips.remove( index )
}

function O2_ArmadaMove()
{
	if( Flag( "InGameArmadasWarpOut" ) )
		return
	FlagEnd( "InGameArmadasWarpOut" )

	// Move ship clusters forward
	foreach ( team, teamShips in level.skyshowShips )
		foreach ( ship in teamShips )
		{
			local shipMoveTime = level.fleetIntroTravelTime * ship.s.speedModifier * level.fleetArrivalTimeModifier

			// If the fleet should already be overhead for late joins, just start it there
			if( Time() >= shipMoveTime )
				ship.NonPhysicsMoveTo( ship.s.endPos, 1, 0, 0 )
			else
				ship.NonPhysicsMoveTo( ship.s.endPos, shipMoveTime, 0, shipMoveTime * 0.75 )
		}

	// Slowly rock the ship clusters back & forth to make it look less static in the sky
	local rotateTime = 10
	local rotateAmount = 5
	while( 1 )
	{
		foreach ( team, teamShips in level.skyshowShips )
			foreach ( ship in teamShips )
				if ( IsValid( ship ) )
					ship.NonPhysicsRotateTo( ship.GetAngles() + Vector( 0, 0, rotateAmount ), rotateTime, 0, RandomFloat( 0, rotateTime - 1) )

		wait rotateTime

		foreach ( team, teamShips in level.skyshowShips )
			foreach ( ship in teamShips )
				if ( IsValid( ship ) )
					ship.NonPhysicsRotateTo( ship.GetAngles() + Vector( 0, 0, -rotateAmount ), rotateTime, 0, RandomFloat( 0, rotateTime - 1) )

		wait rotateTime
	}
}

function O2_IngameArmadaSetGoals( forward, right, up )
{
	foreach ( ship in level.skyshowShips[ TEAM_MILITIA ] )
		O2_IngameArmadaCalc( ship, forward, -right, up )

	foreach ( ship in level.skyshowShips[ TEAM_IMC ] )
		O2_IngameArmadaCalc( ship, forward, right, up )
}

function O2_IngameArmadaCalc( ship, forward, right, up )
{
	local moveVector = ship.GetForwardVector() * forward
	moveVector += ship.GetRightVector() * right
	moveVector += Vector( 0, 0, up )

	ship.s.endPos = ship.s.startPos + moveVector
}

function InGameArmadaFXMain()
{
	if ( GetCinematicMode() && GameRules.GetGameMode() == CAPTURE_POINT )
		FlagWait( "IntroDone" )

	// We want a copy of the ships because without 'clone', armada.extend also extends the original level.skyShowShips!
	local armada = clone level.skyshowShips[ TEAM_MILITIA ]
	armada.extend( level.skyshowShips[ TEAM_IMC ] )

	AramadaTracerFXMain( armada, "StopInGameArmadaFX", FX_SPACE_MCOR_TRACERS, FX_SPACE_IMC_TRACERS, true )
	ArmadaExpFXMain( armada, "StopInGameArmadaFX", true )

	armada.extend( GetClientEntArray( "prop_dynamic", "ingame_MCOR_skybox_armada_expFX" ) )
	armada.extend( GetClientEntArray( "prop_dynamic", "ingame_IMC_skybox_armada_expFX" ) )

	ArmadaExpFXMain( armada, "StopInGameArmadaFX", true )
}

function MCORArmadaFXMain()
{
	delaythread( 2.0 ) MCORArmadaFXInitVisually()

	local armada = GetClientEntArray( "prop_dynamic", "MCOR_skybox_MCOR_armad" )
	armada.extend( GetClientEntArray( "prop_dynamic", "IMC_skybox_MCOR_carriersA" ) )
	armada.extend( GetClientEntArray( "prop_dynamic", "IMC_skybox_MCOR_carriersB" ) )
	armada.extend( GetClientEntArray( "prop_dynamic", "IMC_skybox_MCOR_carriersC" ) )

	AramadaTracerFXMain( armada, "PostWorldSettings", FX_SPACE_MCOR_TRACERS2, FX_SPACE_IMC_TRACERS2 )
	ArmadaExpFXMain( armada, "PostWorldSettings" )
}

function IMCArmadaFXMain()
{
	delaythread( 2.0 ) IMCArmadaFXInitVisually()

	local armada = GetClientEntArray( "prop_dynamic", "MCOR_skybox_armad" )
	ArmadaExpFXMain( armada, "PostWorldSettings" )

	armada.extend( GetClientEntArray( "prop_dynamic", "imc_skybox_carrier" ) )
	AramadaTracerFXMain( armada, "PostWorldSettings", FX_SPACE_MCOR_TRACERS, FX_SPACE_IMC_TRACERS )

	//some carriers
	local carriers = []
	carriers.append( GetClientEnt( "prop_dynamic", "imc_skybox_carriers6" ) )
	carriers.append( GetClientEnt( "prop_dynamic", "imc_skybox_carriers7" ) )
	carriers.append( GetClientEnt( "prop_dynamic", "imc_skybox_carriers9" ) )
	carriers.append( GetClientEnt( "prop_dynamic", "imc_skybox_extra_carriers23" ) )

	ArmadaExpFXMain( carriers, "PostWorldSettings" )

	//the players ship
	local skycam = GetClientEnt( "info_target_clientside", "imc_player_ship_cam" )
	local x = 16
	local y = 20
	local z = -10
	thread ArmadaFxTracersLoop( FX_SPACE_IMC_TRACERS, skycam.GetOrigin() + Vector( x, y, z ), Vector( 0,1,0 ), "PostWorldSettings" )
	thread ArmadaFxTracersLoop( FX_SPACE_IMC_TRACERS, skycam.GetOrigin() + Vector( -x, y, z ), Vector( 0,1,0 ), "PostWorldSettings" )
}

function IMCArmadaFXInitVisually()
{
	local initFX = GetClientEnt( "info_target_clientside", "FX_SPACE_MCOR_TRACERS_INIT" )
	local effectIndex 	= GetParticleSystemIndex( FX_SPACE_MCOR_TRACERS_INIT )
	StartParticleEffectInWorld( effectIndex, initFX.GetOrigin(), Vector( 1,0,0 ) )
}

function MCORArmadaFXInitVisually()
{
	local initFX = GetClientEnt( "info_target_clientside", "FX_SPACE_IMC_TRACERS_INIT" )
	initFX.SetOrigin( Vector( -7.75, 14415.5, -11015.5 ) )
	local effectIndex 	= GetParticleSystemIndex( FX_SPACE_IMC_TRACERS_INIT )
	StartParticleEffectInWorld( effectIndex, initFX.GetOrigin(), Vector( 1,0,0 ) )
}

function ArmadaExpFXMain( armada, endFlag, inGameFX = false )
{
	if ( Flag( endFlag ) )
		return

	ArrayRemoveDead( armada )

	foreach( ship in armada )
	{
		local attach 	= ArmadaGetAttach( ship.GetModelName() )
		local groupNum 	= ArmadaGetGroupNum( ship.GetModelName() )
		local fx		= ArmadaGetExpFX( ship.GetModelName() )

		if ( !fx )
			continue//means its not supported - don't assert - armada usually includes ships like crow clusters and what not

		Assert( attach != null )
		Assert( groupNum != null )

		if ( inGameFX )
			thread InGameArmadaExpFX( fx, ship, attach, groupNum, endFlag )
		else
			thread ArmadaExpFX( fx, ship, attach, groupNum, endFlag )
	}
}

function AramadaTracerFXMain( armada, endFlag, tracersMCOR, tracersIMC, inGameFX = false)
{
	if ( Flag( endFlag ) )
		return

	ArrayRemoveDead( armada )

	foreach( ship in armada )
	{
		local attach 	= ArmadaGetAttach( ship.GetModelName() )
		local groupNum 	= ArmadaGetGroupNum( ship.GetModelName() )
		local fx		= ArmadaGetTracerFX( ship.GetModelName(), tracersMCOR, tracersIMC )

		if ( !fx )
			continue//means its not supported - don't assert - armada usually includes ships like crow clusters and what not

		Assert( attach != null )
		Assert( groupNum != null )

		thread ArmadaTracerFX( fx, ship, attach, groupNum, endFlag, inGameFX )
	}
}

function ArmadaTracerFX( fx, ship, attach, group, endFlag, inGameFX = false )
{
	if ( Flag( endFlag ) )
		return

	ship.EndSignal( "OnDeath" )
	FlagEnd( endFlag )

	local effectIndex 	= GetParticleSystemIndex( fx )
	local effect 		= []
	local attachIdx

	OnThreadEnd(
		function() : ( effect )
		{
			foreach( id in effect )
				EffectStop( id, true, false )	// id, stop all particles, play end cap
		}
	)

	while( !Flag( endFlag ) )
	{
		local totalTime = 0.0

		for( local i = 0; i <= group; i++ )
		{
			if( !IsValid( ship ) )
				return

			attachIdx = GetShipAttachID( ship, attach, group, i )
			if(attachIdx <= 0 )
				continue

			local forward 	= ship.GetForwardVector()
			local origin 	= ship.GetAttachmentOrigin( attachIdx )

			StartParticleEffectInWorld( effectIndex, origin, forward )

			local waitTime = RandomFloat( 0.05,0.15 )//->creates variety in timing
			totalTime += waitTime
			wait waitTime
		}

		local effectTime = 5	// the length of the effect
		effectTime += RandomFloat( 1.5, 2.0 )
		effectTime -= totalTime

		if ( effectTime >= 0.0 )
			wait effectTime

		// Optimization so they don't play forever
		if( inGameFX )
		{
 			// pause before doing this ship cluster again
			if( GetCPULevel() != CPU_LEVEL_HIGHEND )
				wait RandomFloat( 5.0, 20.0 )           // 26-105 tracers at a time
			else
				wait RandomFloat( 3.0, 6.0)				// 112-130 tracers at a time
		}
	}
}

function ArmadaFxTracersLoop( fx, origin, forward, endFlag )
{
	if ( Flag( endFlag ) )
		return

	FlagEnd( endFlag )

	local effectIndex 	= GetParticleSystemIndex( fx )

	while( 1 )
	{
		StartParticleEffectInWorld( effectIndex, origin, forward )

		local effectTime = 5	// the length of the effect
		effectTime += RandomFloat( 1.5, 2.0 )
		wait effectTime
	}
}

function ArmadaExpFX( fx, ship, attach, group, endFlag )
{
	if ( Flag( endFlag ) )
		return

	ship.EndSignal( "OnDeath" )
	FlagEnd( endFlag )

	local effectIndex 	= GetParticleSystemIndex( fx )
	local effect 		= []
	local attachIdx

	OnThreadEnd(
		function() : ( effect )
		{
			foreach( id in effect )
				EffectStop( id, true, false )	// id, stop all particles, play end cap
		}
	)

	for( local i = 0; i <= group; i++ )
	{
		attachIdx = GetShipAttachID( ship, attach, group, i )
		if(attachIdx <= 0 )
			continue

		effect.append( StartParticleEffectOnEntity( ship, effectIndex, FX_PATTACH_POINT_FOLLOW, attachIdx ) )
		wait RandomFloat( 0.05,0.15 )//->creates variety in timing
	}

	FlagWait( endFlag )
}

function InGameArmadaExpFX( fx, ship, attach, group, endFlag )
{
	if ( Flag( endFlag ) )
		return

	ship.EndSignal( "OnDeath" )
	ship.EndSignal( "OnDestroy" )
	FlagEnd( endFlag )

	local effectIndex 	= GetParticleSystemIndex( fx )
	local effect 		= []
	local attachIdx     = 0

	local minDelay = 1.0
	local maxDelay = 2.0

	// Optimization
	if( GetCPULevel() != CPU_LEVEL_HIGHEND )
	{
		minDelay = 4
		maxDelay = 8
	}

	OnThreadEnd(
		function() : ( effect )
		{
			foreach( id in effect )
				EffectStop( id, true, false )
		}
	)

	while(1)
	{
		if( Flag( "PauseInGameArmadaExplosions" ) )
		{
			wait 1
			continue
		}

		if( !IsValid( ship ) )
			return

		// Don't play on every ship in the cluster
		local numShipsToHaveFX = RandomInt( 1, group )
		for( local i = 0; i <= numShipsToHaveFX; i++ )
		{
			// Pick a random ship from the cluster
			local randomShipIndex = RandomInt( 0, group-1 )

			attachIdx = GetShipAttachID( ship, attach, group, randomShipIndex )
			if(attachIdx <= 0 )
				continue

			effect.append( StartParticleEffectOnEntity( ship, effectIndex, FX_PATTACH_POINT_FOLLOW, attachIdx ) )
			wait RandomFloat( 0.2, 0.5 )  	// wait before starting the next ship
		}

		wait RandomFloat( 0.2, 0.5 )  		// let it play a bit before we stop it

		foreach( id in effect )
			EffectStop( id, false, false )

		wait RandomFloat( minDelay, maxDelay ) 		// pause before doing this ship cluster again
	}
}

function MegaCarrier_Changed()
{
	local carrier = level.nv.megaCarrier
	if ( carrier == null )
		return

	if( Flag( "MegaCarrierArrives") )
		return

	FlagSet( "MegaCarrierArrives" )

	thread CarrierShipLauncherInit( carrier )
	thread MegaCarrierShips( carrier )
	thread FirstRedeyeAndCarrierBattle()
}

function FirstRedeyeAndCarrierBattle()
{
	FlagWait( "MegaCarrierArrives" )

	while ( !IsValid( level.nv.redeye ) )
		wait 0
	while ( !IsValid( level.nv.megaCarrier ) )
		wait 0

	local redeye = level.nv.redeye
	local carrier = level.nv.megaCarrier

	thread PauseSkyshowExplosions( level.redeyeAttackDuration + 10 )	// +10 to give it some extra time to account for warp
	thread ShipFiresFromOriginToTargetShip( redeye, carrier )
	thread ShipFiresFromOriginToTargetShip( carrier, redeye, "redeye" )

	if ( GetCPULevel() == CPU_LEVEL_HIGHEND )
	{
		// Ramp up the IMC attacks to finish off the Redeye!
		wait level.redeyeAttackDuration * 0.5
		thread ShipFiresFromOriginToTargetShip( carrier, redeye, "redeye" )
		wait level.redeyeAttackDuration * 0.2
		thread ShipFiresFromOriginToTargetShip( carrier, redeye, "redeye" )
		wait level.redeyeAttackDuration * 0.1
		thread ShipFiresFromOriginToTargetShip( carrier, redeye, "redeye" )
	}
}

function SecondRedeyeAndCarrierBattle()
{
	while ( !IsValid( level.nv.redeye ) )
		wait 0
	while ( !IsValid( level.nv.megaCarrier ) )
		wait 0

	local redeye = level.nv.redeye
	local carrier = level.nv.megaCarrier

	wait 1
	thread ShipFiresFromOriginToTargetShip( redeye, carrier )
	wait 1
	thread ShipFiresFromOriginToTargetShip( carrier, redeye, "redeye" )
}

function PauseSkyshowExplosions( duration )
{
	FlagSet( "PauseInGameArmadaExplosions" )
	wait duration
	FlagClear( "PauseInGameArmadaExplosions" )
}

// TODO: Art/Mo is going to add new references to use instead of the FXORIGIN so we can avoid this angle adjustment
function GetClusterAnglesAdjustment( team )
{
	local attachAnglesAdjustment = Vector( 0, 0, 0 )

	if( team == TEAM_MILITIA )
		attachAnglesAdjustment = Vector( 0, -90, -90 )
	else
		attachAnglesAdjustment =  Vector( 0, 90, -90 )

	return attachAnglesAdjustment
}

function InGameArmadasWarpOut()
{
	FlagSet( "InGameArmadasWarpOut" )

	wait 6.0

	FlagSet( "StopInGameArmadaFX" )

	local imcDelay, mcorDelay
	if ( GetLocalViewPlayer().GetTeam() == TEAM_MILITIA )
	{
		imcDelay = 0
		mcorDelay = 9.5
	}
	else
	{
		mcorDelay = 0
		imcDelay = 9.5
	}

	ArmadaWarpsOut( TEAM_MILITIA, GetClusterAnglesAdjustment( TEAM_MILITIA ), mcorDelay, SFX_SKYBOX_FLEET_WARPOUT )
	ArmadaWarpsOut( TEAM_IMC, GetClusterAnglesAdjustment( TEAM_IMC ), imcDelay, SFX_SKYBOX_FLEET_WARPOUT_2 )

	// Get rid of any ships that are no longer in clusters
	foreach ( arrayShip in level.independentShips )
	{
		if ( arrayShip.s.isCrashing == true )
 			thread ClusterShipExplodes( arrayShip, 1 )
 		else
			thread WarpOutShip( arrayShip, false)
	}

	level.independentShips.clear()
}

function ArmadaWarpsOut( team, attachAnglesAdjustment, delay, warpoutSFX )
{
	local soundDelay = 1.5  	// Sound has a 1.5 second buildup that needs to play before ships actually warp

	local waitTime = delay - soundDelay
	if( waitTime > 0 )
		wait waitTime

	EmitSoundOnEntity( GetLocalViewPlayer(), warpoutSFX )

	wait soundDelay

	local armada = level.skyshowShips[ team ]

	// These "ships" are actually clusters of ships that must be broken up into individual ships to be warped out
	foreach ( shipCluster in armada )
	{
		local ships = CreateIndividualShipsFromCluster( shipCluster, attachAnglesAdjustment )
		foreach ( ship in ships )
		{
			local mothershipDelay = 0
			if ( ship.GetModelName() == FLEET_MCOR_ANNAPOLIS_1000X )
			{
				if ( GetLocalViewPlayer().GetTeam() == TEAM_MILITIA )
					mothershipDelay = 2.0
				else
					mothershipDelay = 2.0
			}
			else if ( ship.GetModelName() == FLEET_CAPITAL_SHIP_ARGO_1000X )
				mothershipDelay = 1.5

			if ( mothershipDelay )
			{
				delaythread( mothershipDelay ) WarpOutShip( ship )
				delaythread( mothershipDelay + 1 ) ScheduleShipCleanup( ship )
			}
			else
			{
				local randomTime = RandomFloat( 0.0, 1.0 )
				delaythread( randomTime ) WarpOutShip( ship, false )
				delaythread( randomTime + 1) ScheduleShipCleanup( ship )
			}
		}
		wait 0.15
	}

	// Remove the clusters from level data.  Must be done after iterating on the array
	level.skyshowShips[ team ].clear()
}

function ScheduleShipCleanup( ship )
{
	RemoveIndieShipFromLevel( ship )
}

function CreateIndividualShipsFromCluster( shipCluster, attachAnglesAdjustment )
{
	local attach 	= ArmadaGetAttach( shipCluster.GetModelName() )
	local groupNum 	= ArmadaGetGroupNum( shipCluster.GetModelName() )

	Assert( attach != null )
	Assert( groupNum != null )

	PerfStart(PerfIndexClient.CreateIndividualShipsFromCluster)

	local modelname = shipCluster.GetModelName().tolower()

	// Special case for the motherships since their attachments are messed up.
	// TODO: Get art to fix the references
	if( ( modelname == FLEET_MCOR_ANNAPOLIS_1000X ) || ( modelname == FLEET_CAPITAL_SHIP_ARGO_1000X ) )
		attachAnglesAdjustment = Vector( 0, 0, 0 )

	// TODO: See if art will make a version to match the other ships.  This one's model faces backwards.
	if( modelname.find( "wallace" ) )
		attachAnglesAdjustment = Vector( 0, -90, -90 )

	local individualShips = []
	for( local i = 0; i <= groupNum; i++ )
	{
		local attachIdx = GetShipAttachID( shipCluster, attach, groupNum, i )
		if( attachIdx <= 0 )
			continue

		local origin = shipCluster.GetAttachmentOrigin( attachIdx )
		local angles = shipCluster.GetAttachmentAngles( attachIdx ) + attachAnglesAdjustment
		local ship = CreateClientsideScriptMover( level.shipClusterToShip[ modelname ], origin, angles )
		ship.s.endPos <- shipCluster.s.endPos
		ship.s.isCrashing <- false

		individualShips.append( ship )
		level.independentShips.append( ship )
	}

	shipCluster.Kill()

	PerfEnd(PerfIndexClient.CreateIndividualShipsFromCluster)

	return individualShips
}

function WarpOutShip( ship, playSound = true )
{
	if( !IsValid( ship ) )
		return

	local attach = ship.LookupAttachment( "origin" )
	local origin = ship.GetAttachmentOrigin( attach )
	local angles = ship.GetAttachmentAngles( attach )
	local model  = ship.GetModelName()
	local fxName = level.shipToWarpOutFX[ model.tolower() ]
	local fxIndex = GetParticleSystemIndex( fxName )
	StartParticleEffectInWorld( fxIndex, origin, angles )

	if( playSound )
		EmitSoundAtPosition( origin, SFX_SKYBOX_SHIP_WARPOUT )

	ship.Kill()
}


/************************************************************************************************\

##     ## ####  ######  ##     ##    ###    ##             ######## ##     ## ##    ##  ######   ######
##     ##  ##  ##    ## ##     ##   ## ##   ##             ##       ##     ## ###   ## ##    ## ##    ##
##     ##  ##  ##       ##     ##  ##   ##  ##             ##       ##     ## ####  ## ##       ##
##     ##  ##   ######  ##     ## ##     ## ##             ######   ##     ## ## ## ## ##        ######
 ##   ##   ##        ## ##     ## ######### ##             ##       ##     ## ##  #### ##             ##
  ## ##    ##  ##    ## ##     ## ##     ## ##             ##       ##     ## ##   ### ##    ## ##    ##
   ###    ####  ######   #######  ##     ## ########       ##        #######  ##    ##  ######   ######

\************************************************************************************************/
function CE_O2VisualSettingsSpaceIMC( player, dropPod )
{
	SetMapSetting_BloomScale( 6.0 )
	SetMapSetting_FogEnabled( false )

	SetMapSetting_CsmTexelScale( 0.4, 0.5 )

	CE_SetSunLightAngles( 10, 55 )
}

function CE_O2VisualSettingsSpaceMCOR( player, dropship )
{
	SetMapSetting_BloomScale( 5.0 )
	SetMapSetting_FogEnabled( false )

	SetMapSetting_CsmTexelScale( 0.4, 1.0 )

	CE_SetSunLightAngles( 7, 60 )

	dropship.LerpSkyScale( SKYSCALE_SPACE, 0.01 )
}

function CE_O2VisualSettingsTransition( player, dropPod )
{
	FlagSet( "StopSunAnim" )

	CE_O2VisualSettingsSpaceIMC( player, dropPod )

	CE_SetSunLightAngles( 10, 30 )
}

function CE_O2VisualSettingsEject( player, dropPod )
{
	dropPod.EndSignal( "OnDeath" )

	wait SKYSCALE_EJECT_TIME
	dropPod.LerpSkyScale( SKYSCALE_O2_EJECT_IMC_SHIP, 0.2 )
}

function CE_O2VisualSettingsEvac( player, dropship )
{
	thread CE_O2VisualSettingsEvacThread( player, dropship )
}

function CE_O2VisualSettingsEvacThread( player, dropship )
{
	wait 0.05//make sure its the last one

	SetMapSetting_BloomScale( 5.0 )
	SetMapSetting_FogEnabled( false )

	SetMapSetting_CsmTexelScale( 0.4, 1.0 )

	CE_SetSunLightAngles( 25, 50 )

	dropship.LerpSkyScale( SKYSCALE_SPACE, 0.01 )

	FlagSet( "EvacInSpace" )
}

function CE_O2VisualSettingsWorldIMC( player, dropPod )
{
	CE_ResetVisualSettings( player )
	O2Bloom()

	FlagSet( "PostWorldSettings" )

	dropPod.EndSignal( "OnDeath" )

	wait 2.0
	dropPod.LerpSkyScale( SKYSCALE_O2_IMC_SHIP, 2 )
}

function CE_O2VisualSettingsWorldMCOR( player, dropship )
{
	CE_ResetVisualSettings( player )
	CE_ResetSunLightAngles()
	O2Bloom()

	FlagSet( "PostWorldSettings" )
	dropship.LerpSkyScale( SKYSCALE_O2_MCOR_SHIP, 0.01 )
}

function O2Bloom()
{
	if ( Flag( "O2BloomSetting" ) )
		return
	FlagSet( "O2BloomSetting" )

	SetMapSetting_BloomScale( 2.0 )
}

function CE_O2SkyScaleShipEnterAtmos( player, dropship )
{
	dropship.EndSignal( "OnDeath" )

	wait SKYSCALE_O2_FIRE_BUILDUP_TIME
	dropship.LerpSkyScale( SKYSCALE_O2_FIRE_IMC_SHIP, 2.0 )
}

function CE_O2SkyScaleShipOnRampClose( player, dropship )
{
	AddAnimEvent( dropship, "cl_ramp_close", O2SkyScaleShipOnRampCloseEvent )
}

function O2SkyScaleShipOnRampCloseEvent( dropship )
{
	dropship.LerpSkyScale( SKYSCALE_O2_DOORCLOSE_IMC_SHIP, 1 )
}

function CE_O2BloomOnRampOpen( player, dropship )
{
	AddAnimEvent( dropship, "cl_ramp_open", O2TonemappingOnDoorOpen )
}

function CE_O2BloomOnRampOpenIMC( player, dropship )
{
	AddAnimEvent( dropship, "cl_ramp_open", O2TonemappingOnDoorOpenIMC )
}

function O2TonemappingOnDoorOpenIMC( dropship )
{
	dropship.LerpSkyScale( SKYSCALE_DEFAULT, 1.0 )
	//thread CinematicTonemappingThread( 12, 2, 0.1, 1 )
}

function O2TonemappingOnDoorOpen( dropship )
{
	dropship.LerpSkyScale( SKYSCALE_O2_DOOROPEN_MCOR_SHIP, 0.5 )
	thread CinematicTonemappingThread( 12, 2, 0.2, 1.5 )
}

function ServerCallback_ScreenShakeOzone()
{
	thread ScreenShakeOzoneThread()
}

function ScreenShakeOzoneThread()
{
	local amplitude, frequency, duration
	local direction = Vector( 0,0,0 )
	//build up to ozone entry
	amplitude 	= 1.0
	frequency 	= 50
	duration 	= 0.2

	local downamp = 5.0
	local max 	= 40
	local ramp 	= downamp / max
	for( local i = 1; i <= max; i++ )
	{
		amplitude 	= ramp * i
		ClientScreenShake( amplitude, frequency, duration, direction )
		wait 0.1
	}

	//ramp down from entry
	amplitude 	= downamp
	frequency 	= 25
	duration 	= 1.0
	ClientScreenShake( amplitude, frequency, duration, direction )
}


function ServerCallback_TonemappingNuke()
{
	if ( IsPlayerOnIntroRef() )
		thread CinematicTonemappingThread( 8, 1, 0.1, 0.35 )
}

function TonemappingSmlExplosion()
{
	thread CinematicTonemappingThread( 8, 1, 0.1, 0.35 )
}

function TonemappingLgExplosion()
{
	thread CinematicTonemappingThread( 30, 2 )
}

function ServerCallback_NukePlayers()
{
	thread NukePlayer()
}

/************************************************************************************************\

 ######  ########     ###     ######  ##     ##       ##     ## ####  ######  ##     ##    ###    ##
##    ## ##     ##   ## ##   ##    ## ##     ##       ##     ##  ##  ##    ## ##     ##   ## ##   ##
##       ##     ##  ##   ##  ##       ##     ##       ##     ##  ##  ##       ##     ##  ##   ##  ##
##       ########  ##     ##  ######  #########       ##     ##  ##   ######  ##     ## ##     ## ##
##       ##   ##   #########       ## ##     ##        ##   ##   ##        ## ##     ## ######### ##
##    ## ##    ##  ##     ## ##    ## ##     ##         ## ##    ##  ##    ## ##     ## ##     ## ##
 ######  ##     ## ##     ##  ######  ##     ##          ###    ####  ######   #######  ##     ## ########

\************************************************************************************************/
function CE_O2SmokePlumes( player, dropship )
{
	local handles = []

	local fxID = GetParticleSystemIndex( "P_fire_med_FULL" )
	local fx = GetClientEntArray( "info_target_clientside", "P_fire_med_FULL_fx_crashsite_fire" )
	foreach ( item in fx )
		handles.append( StartParticleEffectInWorldWithHandle( fxID, item.GetOrigin(), item.GetAngles() ) )

	local fxID = GetParticleSystemIndex( "P_fire_grass" )
	local fx = GetClientEntArray( "info_target_clientside", "P_fire_grass_fx_crashsite_fire" )
	foreach ( item in fx )
		handles.append( StartParticleEffectInWorldWithHandle( fxID, item.GetOrigin(), item.GetAngles() ) )

	local fxID = GetParticleSystemIndex( "P_fire_small_FULL" )
	local fx = GetClientEntArray( "info_target_clientside", "P_fire_grass_fx_crashsite_fire" )
	foreach ( item in fx )
		handles.append( StartParticleEffectInWorldWithHandle( fxID, item.GetOrigin(), item.GetAngles() ) )

	local fxID = GetParticleSystemIndex( "P_fire_tiny_FULL" )
	local fx = GetClientEntArray( "info_target_clientside", "P_fire_grass_fx_crashsite_fire" )
	foreach ( item in fx )
		handles.append( StartParticleEffectInWorldWithHandle( fxID, item.GetOrigin(), item.GetAngles() ) )

	wait 50

	foreach ( handle in handles )
		EffectStop( handle, false, true )
}

function EyesOpenFallback( player )
{
	local fallbackWaitTime = 15

	FlagEnd( "MilitiaIntroEyesOpen" )
	player.EndSignal( "OnDestroy" )

	wait fallbackWaitTime

	CE_O2WakeUpScreenFX( player )
}

function CE_O2WakeUpScreenFX( player )
{
	local holdTime = 0.25
	local fadeTime = 3.0
	ClientScreenFadeFromBlack( fadeTime, holdTime )

	wait holdTime + 1.0
	local fadeTime = 4.0

	player.hudElems.damageOverlayRedBloom.ColorOverTime( 0, 0, 0, 255, fadeTime )
	player.hudElems.damageOverlayOrangeBloom.ColorOverTime( 0, 0, 0, 255, fadeTime )
	player.hudElems.damageOverlayLightLines.ColorOverTime( 0, 0, 0, 255, fadeTime )
	player.hudElems.EMPScreenFX.FadeOverTime( 0, fadeTime )

	wait fadeTime

	player.hudElems.EMPScreenFX.Hide()
	player.hudElems.damageOverlayRedBloom.Hide()
	player.hudElems.damageOverlayOrangeBloom.Hide()
	player.hudElems.damageOverlayLightLines.Hide()
}

function CE_O2Wakeup( player, dropship )
{
	FlagSet( "MilitiaIntroEyesOpen" )

	CE_O2WakeUpScreenFX( player )
}

function CE_O2BlackOut( player, dropship )
{
	AddAnimEvent( dropship, "cl_BlackOut", O2BlackOut, player )
}

function O2BlackOut( dropship, player )
{
	// In case of bug #58049 which is super rare. Force the screen from black after a time out.
	thread EyesOpenFallback( player )

	ClientSetScreenColor( 0, 0, 0, 255 )
	player.cv.topBar.Hide()
	player.cv.bottomBar.Hide()
	player.cv.loadoutButtonText.Hide()
	player.cv.loadoutButtonIcon.Hide()
}

function CE_O2CrashVisual( player, dropship )
{
	AddAnimEvent( dropship, "cl_crash", O2CrashEvent, player )
}

function O2CrashEvent( dropship, player )
{
	O2CrashVisual( dropship, player )
	O2CrashFX( dropship, player )
}

function O2CrashFX( dropship, player )
{
	local origin 	= dropship.GetOrigin()
	local end 		= origin + Vector( 0, 0, -2000 )
	local result 	= TraceLine( origin, end, dropship, TRACE_MASK_NPCWORLDSTATIC, TRACE_COLLISION_GROUP_NONE )
	local effectIndex 	= GetParticleSystemIndex( FX_CRASH )

	StartParticleEffectInWorld( effectIndex, result.endPos, Vector( 0, 0, 0 ) )
}

function O2CrashVisual( dropship, player )
{
	ClientScreenShake( 40, 40, 4, Vector( 0,0,0 ) )

	player.hudElems.damageOverlayRedBloom.Show()
	player.hudElems.damageOverlayOrangeBloom.Show()
	player.hudElems.damageOverlayLightLines.Show()
	player.hudElems.damageOverlayRedBloom.ColorOverTime( 255, 255, 255, 255, 0.15 )
	player.hudElems.damageOverlayOrangeBloom.ColorOverTime( 255, 255, 255, 255, 0.15 )
	player.hudElems.damageOverlayLightLines.ColorOverTime( 255, 255, 255, 255, 0.15 )

	player.hudElems.EMPScreenFX.Show()
	player.hudElems.EMPScreenFX.SetAlpha( 30 )
	player.hudElems.EMPScreenFX.FadeOverTimeDelayed( 10, 2.0, 0.5 )
}

/************************************************************************************************\

   ###    #### ########        ########  ##     ## ########   ######  ########
  ## ##    ##  ##     ##       ##     ## ##     ## ##     ## ##    ##    ##
 ##   ##   ##  ##     ##       ##     ## ##     ## ##     ## ##          ##
##     ##  ##  ########        ########  ##     ## ########   ######     ##
#########  ##  ##   ##         ##     ## ##     ## ##   ##         ##    ##
##     ##  ##  ##    ##        ##     ## ##     ## ##    ##  ##    ##    ##
##     ## #### ##     ##       ########   #######  ##     ##  ######     ##

\************************************************************************************************/
function CE_02AirBurstEvents( player, dropship )
{
	AddAnimEvent( dropship, "cl_airburst_01", O2AirBurstWithSFX, "cl_airburst_01" )
	AddAnimEvent( dropship, "cl_airburst_02", O2AirBurstWithSFX, "cl_airburst_02" )
	AddAnimEvent( dropship, "cl_airburst_03", O2AirBurstWithSFX, "cl_airburst_03" )
	AddAnimEvent( dropship, "cl_airburst_04", O2AirBurstWithSFX, "cl_airburst_04" )
	AddAnimEvent( dropship, "cl_airburst_05", O2AirBurstWithSFX, "cl_airburst_05" )
}

function GetO2AirBurstData( index )
{
	local data = {}

	switch( index )
	{
		case "cl_airburst_01":
			data.offset <- Vector( 200,-1300,300 )
			data.sfx 	<- "O2_Scr_MilitiaIntro1_SpaceExplo2"
			break

		case "cl_airburst_02":
			data.offset <- Vector( 0,900,300 )
			data.sfx 	<- "O2_Scr_MilitiaIntro1_SpaceExplo3"
			break

		case "cl_airburst_03":
			data.offset <- Vector( 800,1400,-1800 )
			data.sfx 	<- "O2_Scr_MilitiaIntro1_SpaceExplo4"
			break

		case "cl_airburst_04":
			data.offset <- Vector( -300,-1100,400 )
			data.sfx 	<- "O2_Scr_MilitiaIntro1_SpaceExplo5"
			break

		case "cl_airburst_05":
			data.offset <- Vector( 100,1200,-100 )
			data.sfx 	<- "O2_Scr_MilitiaIntro1_SpaceExplo6"
			break

		default:
			Assert( 0 )
			break
	}

	return data
}

function O2AirBurstWithSFX( dropship, index )
{
	local data = GetO2AirBurstData( index )

	O2AirBurstSoundFx( dropship, data.offset, data.sfx )
	O2AirBurst( dropship, data.offset )
}

function ServerCallback_O2CrashBurst( eHandle, ship, forward, right, up )
{
	local dropship = GetEntityFromEncodedEHandle( eHandle )
	if ( !IsValid( dropship ) )
		return
	local offset = Vector( forward, right, up )
	local effect, amplitude

	switch( ship )
	{
		case 0:
			amplitude = 10
			effect = FX_O2_CRASHBURST
			break
		case 1:
			amplitude = 30
			effect = FX_O2_CRASHBURST_POV
			break
	}

	thread O2AirBurstFx( dropship, offset, effect )
	thread CinematicTonemappingThread( 50, 2 )
	ClientScreenShake( amplitude, 30, 1.0, Vector( 0,0,0 ) )
}

function O2AirBurst( dropship, offset )
{
	O2AirBurstFx( dropship, offset )
	thread CinematicTonemappingThread( 50, 2 )
	ClientScreenShake( 20, 30, 0.75, Vector( 0,0,0 ) )
}

function O2AirBurstSoundFx( dropship, offset, sfx )
{
	local origin = CalcOffset( dropship, offset )

	EmitSoundAtPosition( origin, sfx )
}

function O2AirBurstFx( dropship, offset, effect = null )
{
	local origin = CalcOffset( dropship, offset )

	local forward = origin - dropship.GetOrigin()
	forward.Norm()
	local angles = VectorToAngles( forward )

	if ( !effect )
		effect = FX_O2_AIRBURST

	local effectIndex 	= GetParticleSystemIndex( effect )

	StartParticleEffectInWorld( effectIndex, origin, angles )
}

function CalcOffset( dropship, offset )
{
	local origin = dropship.GetOrigin()

	origin += dropship.GetForwardVector() * offset.x
	origin += dropship.GetRightVector() * offset.y
	origin += dropship.GetUpVector() * offset.z

	return origin
}

/************************************************************************************************\

######## ##     ##    ###     ######
##       ##     ##   ## ##   ##    ##
##       ##     ##  ##   ##  ##
######   ##     ## ##     ## ##
##        ##   ##  ######### ##
##         ## ##   ##     ## ##    ##
########    ###    ##     ##  ######

\************************************************************************************************/
function EvacEventsMain()
{
	if ( GetLocalViewPlayer().GetTeam() != TEAM_MILITIA )
		return

	FlagWait( "EntsSetup" )
	FlagWait( "EvacInSpace" )
}

function EndTheStory()
{
	FlagSet( "WinnerDetermined" )
	waitthread StoryBlurb5()
}

/*--------------------------------------------------------------------------------------------------------*\
|
|									           HARD POINTS
|
\*--------------------------------------------------------------------------------------------------------*/
// HAX to quick fix hardpoints being nuked/recreated by kill replay/cl_fullupdate
function OnHardpointCreated( hardpoint, isRecreate )
{
	if( Flag( "HardpointSetupDone" ) )
		SetupHardPoint( hardpoint )  // Only called AFTER the level has setup the hardpoints once before
}

function O2_HardpointSetup()
{
	FlagWait( "ClientInitComplete" )

	local hardpointArray = GetClientEntArrayBySignifier( "info_hardpoint" )
	foreach( hardpoint in hardpointArray )
	{
		SetupHardPoint( hardpoint )

		local hardpointID = hardpoint.GetHardpointID()
		if( hardpointID == REFINERY_HARDPOINT_ID )
			EmitSoundOnEntity( hardpoint, SFX_AMB_O2_REFINERY )
	}

	FlagSet( "HardpointSetupDone" )
}

function SetupHardPoint( hardpoint )
{
	local steamFXArray 	= GetClientEntArray( "info_target_clientside", "hardpoint_steam_fx" )
	local fireFXArray 	= GetClientEntArray( "info_target_clientside", "hardpoint_fire_fx" )
	local warningLightFXArray 	= GetClientEntArray( "info_target_clientside", "warning_light_fx" )
	local warningLightFXNoWallArray = GetEntArrayByClassAndTargetname( "info_target_clientside", "warning_light_fx_nowall" )
 	local warningLightModelArray    = GetEntArrayByClassAndTargetname( "prop_dynamic", "warning_light_ON" )
 	local hardpointID = hardpoint.GetHardpointID()

	hardpoint.s.previousTeam <- TEAM_UNASSIGNED
	hardpoint.s.militiaFXHandles <- {}
	hardpoint.s.IMCFXHandles <- {}
	hardpoint.s.steamFXArray <- ArrayWithin( steamFXArray, hardpoint.GetOrigin(), level.hardpointSearchRadius[ hardpointID ] )
	hardpoint.s.fireFXArray <- ArrayWithin( fireFXArray, hardpoint.GetOrigin(), level.hardpointSearchRadius[ hardpointID ] )
	hardpoint.s.warningLightModelArray <- ArrayWithin( warningLightModelArray, hardpoint.GetOrigin(), level.hardpointSearchRadius[ hardpointID ] )
    hardpoint.s.warningLightFXArray <- ArrayWithin( warningLightFXArray, hardpoint.GetOrigin(), level.hardpointSearchRadius[ hardpointID ] )

	local tmpNoWallLightsArray = ArrayWithin( warningLightFXNoWallArray, hardpoint.GetOrigin(), level.hardpointSearchRadius[ hardpointID ] )
	hardpoint.s.warningLightFXArray.extend( tmpNoWallLightsArray )

	//special vdu fx
	if ( hardpointID == REFINERY_HARDPOINT_ID )
	{
		local vduHpFXArray, vduHpLightFXArray, vduHpLightmodelArray
		if( GetLocalClientPlayer().GetTeam() == TEAM_MILITIA )
		{
			vduHpFXArray 			= GetClientEntArray( "info_target_clientside", "vdu_fakeHpFX" )
			vduHpLightFXArray 		= GetClientEntArray( "info_target_clientside", "VDU_warning_light_fx" )
			vduHpLightmodelArray	= GetClientEntArray( "prop_dynamic", "VDU_warning_light_ON" )

		}
		else
		{
			vduHpFXArray = GetClientEntArray( "info_target_clientside", "vduIMC_fakeHpFX" )
			vduHpLightFXArray 		= GetClientEntArray( "info_target_clientside", "VDUIMC_warning_light_fx" )
			vduHpLightmodelArray	= GetClientEntArray( "prop_dynamic", "VDUIMC_warning_light_ON" )
		}
		hardpoint.s.steamFXArray.extend( vduHpFXArray )
		hardpoint.s.fireFXArray.extend( vduHpFXArray )
		hardpoint.s.warningLightFXArray.extend( vduHpLightFXArray )
		hardpoint.s.warningLightModelArray.extend( vduHpLightmodelArray )
	}

	foreach ( steamRef in hardpoint.s.steamFXArray )
		steamRef.s.isPlaying <- false

	foreach ( model in hardpoint.s.warningLightModelArray )
		model.SetModel( WARNING_LIGHT_OFF_MODEL )

	SetupHardpointMonitors( hardpoint )

	O2_HardpointUpdateState( hardpoint )
	thread O2_HardpointThink( hardpoint )
}

function O2_HardpointThink( hardpoint )
{
	hardpoint.EndSignal( "OnDestroy" )

	// Cleanup the FX on these entities when destroyed (cl_fullupdate, etc.)
	OnThreadEnd(
		function () : ( hardpoint )
		{
			thread HardpointTurnOffFX( hardpoint, TEAM_IMC )
			thread HardpointTurnOffFX( hardpoint, TEAM_MILITIA )
		}
	)

	while( IsValid( hardpoint ) )
	{
		hardpoint.WaitSignal( "HardpointStateChanged" )

		O2_HardpointUpdateState( hardpoint )
	}
}

function O2_HardpointUpdateState( hardpoint )
{
	if( O2_DEV_DISABLE_HARDPOINT_FX )
		return

	local team = hardpoint.GetTeam()

	if ( hardpoint.s.previousTeam == team )
		return

	hardpoint.s.previousTeam = team

	thread UpdateHardpointMonitorScreens( hardpoint )
	thread UpdateTowerExplosions()

	switch( team )
	{
		case TEAM_IMC:
			thread HardpointIMCFX( hardpoint )
			break
		case TEAM_MILITIA:
			thread HardpointMilitiaFX( hardpoint )
			break
		default:
			// Turn off both IMC and Militia FX (neutral state)
			thread HardpointTurnOffFX( hardpoint, TEAM_IMC )
			thread HardpointTurnOffFX( hardpoint, TEAM_MILITIA )
	}
}

/*--------------------------------------------------------------------------------------------------------*\
|
|									           HARD POINT FX
|
\*--------------------------------------------------------------------------------------------------------*/
function HardpointIMCFX( hardpoint )
{
	FlagWait( "HardpointSetupDone" )

	local effectIndexSteam = GetParticleSystemIndex( FX_PIPE_STEAM )
	local showFX = true
	local cpuLevel = GetCPULevel()

	// Turn off Militia FX
	thread HardpointTurnOffFX( hardpoint, TEAM_MILITIA )

	// Steam FX
	foreach ( info_target in hardpoint.s.steamFXArray )
	{
		if( showFX )
		{
			local handle = StartParticleEffectInWorldWithHandle( effectIndexSteam, info_target.GetOrigin(), info_target.GetAngles() )
			hardpoint.s.IMCFXHandles[ handle ] <- handle
		}

		// Optimization: Skip every other steam effect on lower spec machines
		if ( cpuLevel != CPU_LEVEL_HIGHEND )
			showFX = !showFX
	}

	thread HardpointSteamSFXThink( hardpoint )

	if ( hardpoint.GetHardpointID() == REFINERY_HARDPOINT_ID )		// 0 = a, 1 = b, 2 =c
		EmitSoundAtPosition( hardpoint.GetOrigin(), SFX_CORE_SHUTDOWN )
}

function HardpointMilitiaFX( hardpoint )
{
	FlagWait( "HardpointSetupDone" )

	local effectIndexFire = GetParticleSystemIndex( FX_PIPE_FIRE )

	// Turn off IMC FX
	thread HardpointTurnOffFX( hardpoint, TEAM_IMC )

	// Initial explosion
	local maxExplosionDistance = 1000
	local playerDistance = DistanceSqr( hardpoint.GetOrigin(), GetLocalViewPlayer().GetOrigin() )
	local maxPlayerDistance = maxExplosionDistance * maxExplosionDistance
	if ( playerDistance <=  maxPlayerDistance )
		ClientScreenShake( 20, 40, 3, Vector( 0, 0, 0 ) )

	EmitSoundAtPosition( hardpoint.GetOrigin(), SFX_EXP_LARGE )

	thread WarningLightsStart( hardpoint )

	// Fire FX
	foreach ( info_target in hardpoint.s.fireFXArray )
		thread FireJetsThink( hardpoint, effectIndexFire, info_target )
}

function UpdateTowerExplosions()
{
	if( O2_DEV_DISABLE_HARDPOINT_FX )
		return

	if ( !level.towerExpFxArray )
		return

	if( ShouldShowTowerExplosions() )
	{
		foreach ( info_target in level.towerExpFxArray )
			thread TowerExplosionsThink( info_target )

		thread TowerElectricalSFXThink()
	}
	else
		level.ent.Signal( "StopTowerExplosions" )
}

function ShouldShowTowerExplosions()
{
	if ( GameRules.GetGameMode() != CAPTURE_POINT )
		return false

	local hardpointCount = GetHardpointCount()
	local militiaHasMajority = GetNumOwnedHardpoints( TEAM_MILITIA ) > ( hardpointCount / 2.0 )

	if( militiaHasMajority )
		return true

	if ( Flag( "CoreDestabalized" ) )
		return true

	// If we are in the epilogue, let's see some 'splosions!
	if ( GetGameState() >= eGameState.Epilogue )
		return true

	return false
}

function TowerElectricalSFXThink( )
{
	level.ent.EndSignal( "StopTowerExplosions" )

	while( 1 )
	{
		local duration = EmitSoundAtPosition( level.sfxArcPos, SFX_TOWER_ELECTRICAL_ARC )

		if ( duration <= 0 )
			wait 1
		else
			wait duration
	}
}

function TowerExplosionsThink( info_target )
{
	level.ent.EndSignal( "StopTowerExplosions" )
	info_target.Signal( "TowerExplosionsThink" )
	info_target.EndSignal( "TowerExplosionsThink" )

	local effectIndex = GetParticleSystemIndex( FX_EXP_TOWER )
	local minDelay = 5.0
	local maxDelay = 10.0

	// Optimization
	if( GetCPULevel() != CPU_LEVEL_HIGHEND )
	{
		minDelay = 10
		maxDelay = 20
	}

	if ( Flag( "CoreDestabalized" ) )
	{
		if( GetCPULevel() != CPU_LEVEL_HIGHEND )
		{
			minDelay = 5.0
			maxDelay = 10.0
		}
		else
		{
			minDelay = 1.0
			maxDelay = 3.0
		}
	}

	local angles = info_target.GetAngles() + Vector( 90, 0, 0 )

	while ( 1 )
	{
		wait ( RandomFloat( minDelay, maxDelay ) )

		StartParticleEffectInWorld( effectIndex, info_target.GetOrigin(), angles )
		EmitSoundOnEntity( info_target, SFX_EXP_TOWER )
	}
}

function FireJetsThink( hardpoint, effectIndex, info_target )
{
	hardpoint.EndSignal( "StopFireFXThink" )

	local doStartingFires = true
	local maxStartingFires = 3
	local burnDuration = 2.0  // This matches the sound. Do not change.
	local minDelay = 3.0
	local maxDelay = 7.0

	// Optimization
	if( GetCPULevel() != CPU_LEVEL_HIGHEND )
	{
		minDelay = 15
		maxDelay = 25
	}

	local startingFireCount = 0
	while ( 1 )
	{
		// Get a few of the fires started soon so the player sees immediate results.
		// This is especially important with the long minDelay on lower spec machines.
		if( doStartingFires )
		{
			if( startingFireCount >= maxStartingFires )
				doStartingFires = false

			startingFireCount++

			wait ( RandomFloat( 1, 5 ) )
		}
		else
		{
			wait ( RandomFloat( minDelay, maxDelay ) )
		}

		local handle = StartParticleEffectInWorldWithHandle( effectIndex, info_target.GetOrigin(), info_target.GetAngles() )
		hardpoint.s.militiaFXHandles[ handle ] <- handle

		EmitSoundOnEntity( info_target, SFX_FIRE_BURST )

		wait burnDuration

		delete hardpoint.s.militiaFXHandles[ handle ]

		if ( !( EffectDoesExist( handle ) ) )
			break

		EffectStop( handle, false, true )
	}
}

function HardpointSteamSFXThink( hardpoint )
{
	local player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( hardpoint )
		{
			foreach ( steamRef in hardpoint.s.steamFXArray )
			{
				if( IsValid( steamRef ) )
					StopSoundOnEntity( steamRef, SFX_STEAM_LOOP_SMALL )
			}
		}
	)

	while( true )
	{
		if( hardpoint.GetTeam() != TEAM_IMC )
			return

		foreach ( steamRef in hardpoint.s.steamFXArray )
		{
			wait 0	// check one sound each frame

			local dist = DistanceSqr( steamRef.GetOrigin(), player.GetOrigin() )
			if ( dist <= level.steamSFXRadiusSqr )
			{
				if( steamRef.s.isPlaying )
					continue

				EmitSoundOnEntity( steamRef, SFX_STEAM_LOOP_SMALL )
				steamRef.s.isPlaying = true
			}
			else
			{
				if( steamRef.s.isPlaying )
				{
					EmitSoundOnEntity( steamRef, SFX_STEAM_SHUTOFF )
					StopSoundOnEntity( steamRef, SFX_STEAM_LOOP_SMALL )
					steamRef.s.isPlaying = false
				}
			}
		}
	}
}

function HardpointTurnOffFX( hardpoint, team )
{
	FlagWait( "HardpointSetupDone" )

	local fxhandleTable = ( team == TEAM_IMC ? hardpoint.s.IMCFXHandles : hardpoint.s.militiaFXHandles )

	if ( team == TEAM_MILITIA )
	{
		hardpoint.Signal( "StopFireFXThink" )
		WarningLightsStop( hardpoint )
	}

	// Cleanup this hardpoint's fxhandleTable
	StopAndClearFXTable( fxhandleTable )
}

/*------------------------------------WARNING LIGHTS------------------------------------*/
function WarningLightsStart( hardpoint )
{
	foreach ( handle in hardpoint.s.warningLightFXArray )
	{
		WarningLightStartFX( hardpoint, handle )
		WarningLightsModelSwap( hardpoint, "on" )
		wait RandomFloat( 0, 0.1 )
	}
}

function WarningLightStartFX( hardpoint, handle )
{
	local fxAlias = GetParticleSystemIndex( FX_WARNING_LIGHT )

	if ( handle.GetName() == "warning_light_fx_nowall" )
		fxAlias = GetParticleSystemIndex( FX_WARNING_LIGHT_NOWALL )

	local handle = StartParticleEffectInWorldWithHandle( fxAlias, handle.GetOrigin(), handle.GetAngles() )
	hardpoint.s.militiaFXHandles[ handle ] <- handle
}

function WarningLightsStop( hardpoint )
{
	WarningLightsModelSwap( hardpoint, "off" )
}

function WarningLightsModelSwap( hardpoint, state )
{
	local swapModel = WARNING_LIGHT_ON_MODEL
	if ( state == "off" )
		swapModel = WARNING_LIGHT_OFF_MODEL

	foreach ( model in hardpoint.s.warningLightModelArray )
	{
		if ( IsValid( model ) )
			model.SetModel( swapModel )
	}
}

/*------------------------------------Computer Monitors------------------------------------*/
function SetupHardpointMonitors( hardpoint )
{
	hardpoint.s.monitorTable <- { [ "small" ] = [], [ "medium" ] = [], [ "large" ] = [] }

	local hardpointID = hardpoint.GetHardpointID()
	local hardpointName = HardpointIDToString( hardpointID )

	hardpoint.s.monitorTable[ "small" ] = GetClientEntArray( "prop_dynamic", "monitor_small_hardpoint_" + hardpointName)
	hardpoint.s.monitorTable[ "medium" ] = GetClientEntArray( "prop_dynamic", "monitor_medium_hardpoint_" + hardpointName)
	hardpoint.s.monitorTable[ "large" ]  = GetClientEntArray( "prop_dynamic", "monitor_large_hardpoint_" + hardpointName)

	// Start the level out with monitors off in hardpoint mode
	foreach( size, monitors in hardpoint.s.monitorTable )
		foreach( monitor in monitors )
			monitor.Hide()
}

function UpdateHardpointMonitorScreens( hardpoint )
{
	local modelname = null
	local team = hardpoint.GetTeam()

	foreach( size, monitors in hardpoint.s.monitorTable )
	{
		foreach( monitor in monitors )
		{
			if ( team == TEAM_UNASSIGNED )
			{
				monitor.Hide()
			}
			else
			{
				modelname = GetRandomMonitorScreen( size, team, monitor )
				Assert( modelname != null )

				delaythread( RandomFloat( 0, 0.8 ) ) MonitorFlickerAndChange( monitor, modelname )
			}
		}
	}
}

function GetRandomMonitorScreen( size, hardpointOwnerTeam, monitor )
{
	local randomIndex = 0
	local oldMonitorModelname = monitor.GetModelName()
	local player = GetLocalViewPlayer()
	local playerTeam = player.GetTeam()
	local oldMonitorColor = "BLUE"
	local newMonitorColor = "ORANGE"

	// Show blue ones for player team and orange ones for enemies
	if( playerTeam == hardpointOwnerTeam )
	{
		oldMonitorColor = "ORANGE"
		newMonitorColor = "BLUE"
	}

	if ( size == "small" )
	{
		randomIndex = RandomInt( level.monitorScreenModelsSmall[ newMonitorColor ].len() )
		return level.monitorScreenModelsSmall[ newMonitorColor ][ randomIndex ]
	}
	else if (size == "medium" )
	{
		// Special case for special shape & scale monitors
		foreach( monitorArray in level.monitorScreenModelsMediumSpecial )
		{
			foreach( model in monitorArray )
			{
				if( model.tolower() == oldMonitorModelname.tolower() )
				{
					randomIndex = RandomInt( level.monitorScreenModelsMediumSpecial[ newMonitorColor ].len() )
					return level.monitorScreenModelsMediumSpecial[ newMonitorColor ][ randomIndex ]
				}
			}
		}

		randomIndex = RandomInt( level.monitorScreenModelsMedium[ newMonitorColor ].len() )
		return level.monitorScreenModelsMedium[ newMonitorColor ][ randomIndex ]
	}
	else
	{
		// Special case for two different scales for large monitors
		if( oldMonitorModelname.find("_75pct") )
		{
			randomIndex = RandomInt( level.monitorScreenModelsLargeSpecial[ newMonitorColor ].len() )
			return level.monitorScreenModelsLargeSpecial[ newMonitorColor ][ randomIndex ]
		}

		randomIndex = RandomInt( level.monitorScreenModelsLarge[ newMonitorColor ].len() )
		return level.monitorScreenModelsLarge[ newMonitorColor ][ randomIndex ]
	}
}

/*------------------------------------FX UTILITY------------------------------------*/
function StopAndClearFXTable( fxHandleTable )
{
	foreach ( handle in fxHandleTable )
	{
		if ( EffectDoesExist( handle ) )
			EffectStop( handle, false, true )
	}

	fxHandleTable.clear()
}

function DEV_TeamFX( team = null)
{
	local hardpointArray = GetClientEntArrayBySignifier( "info_hardpoint" )
	foreach ( hardpoint in hardpointArray )
	{
		if ( team == TEAM_MILITIA )
		{
			thread WarningLightsStart( hardpoint )
			thread HardpointTurnOffFX( hardpoint, TEAM_IMC )
			thread HardpointMilitiaFX( hardpoint )
		}
		else if ( team == TEAM_IMC )
		{
			WarningLightsStop( hardpoint )
			thread HardpointTurnOffFX( hardpoint, TEAM_MILITIA )
			thread HardpointIMCFX( hardpoint )
		}
		else
		{
			WarningLightsStop( hardpoint )
			thread HardpointTurnOffFX( hardpoint, TEAM_IMC )
			thread HardpointTurnOffFX( hardpoint, TEAM_MILITIA )
		}
	}

	thread UpdateTowerExplosions()
}



/*------------------------------------VDU's------------------------------------*/
function ShowVDU_Tower( duration )
{
	if ( IsLockedVDU() )
		return
	if ( Flag( "StoryVDU" ) )
		return
	FlagEnd( "StoryVDU" )

	local player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function () : ()
		{
			if ( !Flag( "StoryVDU" ) )
			{
				HideVDU()
				UnlockVDU()
			}
		}
	)

	local org1 = Vector( 2096, -2325, 700 )
 	local ang1 = Vector( -17, 130, 0 )

 	local org2 = Vector( -3475, -2385, 700 )
 	local ang2 = Vector( -17, 34, 0 )

	level.camera.SetOrigin( org1 )
	level.camera.SetAngles( ang1 )
	level.camera.SetFOV( 40 )
	level.camera.SetFogEnable( true )

	LockVDU()
	ShowVDU()
	wait 0.5
	thread RotateCameraOverTime( player, ang1, ang2, 5, 3, 2 )
	thread MoveCameraOverTime( player, org1, org2, 5, 2, 2 )
	wait duration
}

function ShowVDU_ArmadaBattle( duration )
{
	if ( IsLockedVDU() )
		return

	if ( Flag( "StoryVDU" ) )
		return
	FlagEnd( "StoryVDU" )

	local player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function () : ()
		{
			if ( !Flag( "StoryVDU" ) )
			{
				HideVDU()
				UnlockVDU()
			}
		}
	)

 	local org = Vector( 10279, -990.6, 1600.4 )
 	local ang = Vector( -24.6, -165.07, 0.0 )

	level.camera.SetOrigin( org )
	level.camera.SetAngles( ang )
	level.camera.SetFOV( 55 )
	level.camera.SetFogEnable( true )

	LockVDU()
	wait 1
	ShowVDU()
	//wait 1
	//thread ZoomCameraOverTime( player, 100, 70, 10, 2, 3 )
	wait duration
}


/*------------------------------------Nuke Players------------------------------------*/
function NukePlayer( dev = false )
{
	local player = GetLocalViewPlayer()
	local allElems = HudElementGroup( "IntroScreen" )
	local background = allElems.CreateElement( "IntroScreenBackground" )

	FlagSet( "DisableBurnCardMenu" )

	NukePlayerFX( background, player.GetOrigin(), 0.5 )

	// Return sight & controls to player
	if( dev )
	{
		wait 5
		background.SetColor( 0, 0, 0, 0 )
	}
}

function NukePlayerFX( background, soundPos, fadeTime )
{
	local nukeFXArray 	= GetClientEntArray( "info_target_clientside", "fx_skybox_nuke" )

	background.SetColor( 0, 0, 0, 0)
	background.Show()

	EmitSoundOnEntity( GetLocalViewPlayer(), SFX_O2_NUKE_PLAYER )

	thread CinematicTonemappingThread( 10, 1, 1.0, 0.5 )

	wait 0.25

	thread NukeScreenFlashFX()

	thread NukeGlowFX( nukeFXArray )

	wait 2.5

	thread CinematicTonemappingThread( 100, 1, 5, 5 )
	thread ClientScreenShake( 100, 100, 3, Vector( 0,0,0 ) )
	background.ColorOverTime( 255, 255, 255, 255, fadeTime, INTERPOLATOR_LINEAR )

	thread DoEndingFX()
	wait 5.5

	thread PostEpilogueVO()

	wait 1.5

	SetMapSetting_BloomScale( 6.0 )
	SetMapSetting_FogEnabled( false )
	CE_SetSunLightAngles( 10, 55 )
	DoEndingArmada( GetLocalViewPlayer().GetTeam() )

	//fade out
	background.ColorOverTime( 255, 255, 255, 0, 5.0, INTERPOLATOR_LINEAR )
}

function DoEndingFX()
{
	wait 5.0

	DoEndingFXNukeByName( "surface_nuke_1" )

	wait 3.5

	DoEndingFXNukeByName( "surface_nuke_2" )

	wait 5.0

	DoEndingFXNukeByName( "surface_nuke_3" )

	wait 2

	DoEndingFXNukeByName( "surface_nuke_4" )

	wait 3

	DoEndingFXNukeByName( "surface_nuke_1" )
}

function DoEndingFXNukeByName( name )
{
	local effectIndex = GetParticleSystemIndex( FX_ENDING_NUKE )
	local fxnode = GetClientEnt( "info_target_clientside", name )
	Assert( fxnode )

	StartParticleEffectInWorld( effectIndex, fxnode.GetOrigin(), fxnode.GetAngles() )
}

function NukeGlowFX( nukeFXArray )
{
	local effectNukeExp = GetParticleSystemIndex( FX_NUKE_SKYBOX )

	foreach ( info_target in nukeFXArray )
	{
		wait ( 0.157 ) //19x Nuke Positions
		//printt( info_target )
		StartParticleEffectInWorld( effectNukeExp, info_target.GetOrigin(), info_target.GetAngles() )
	}
}

function DEV_TestNukeFX()
{
	thread NukePlayer( true )
}


// Merges titan and player EMP screen effect into a single function without EMP sounds
function NukeScreenFlashFX()
{
	local maxValue 		 = 0.25
	local duration 		 = 2.0
	local fadeTime 	     = 0.5
	local player 		 = GetLocalViewPlayer()
	local EMPScreenFX 	 = player.hudElems.EMPScreenFX
	local EMPScreenFlash = player.hudElems.EMPScreenFlash
	local fadeOutTime    = min( 0.5, duration )

	player.EndSignal( "OnDeath" )

	if ( player.IsTitan() )
	{
		local angles = Vector( 0, -90, 90 )
		local wide = 16
		local tall = 9
		local empVgui = CreateClientsideVGuiScreen( "vgui_titan_emp", VGUI_SCREEN_PASS_VIEWMODEL, Vector(0,0,0), Vector(0,0,0), wide, tall );

		empVgui.SetParent( player )
		empVgui.SetAttachOffsetOrigin( Vector( 4, wide / 2, -tall / 2 ) )
		empVgui.SetAttachOffsetAngles( angles )
		empVgui.GetPanel().WarpEnable()

		EMPScreenFX = HudElement( "EMPScreenFX", empVgui.GetPanel() )
		EMPScreenFlash = HudElement( "EMPScreenFlash", empVgui.GetPanel() )

		fadeOutTime = fadeTime + duration

		OnThreadEnd(
			function() : ( player, empVgui )
			{
				empVgui.Destroy()
			}
		)
	}

	EMPScreenFX.Show()
	EMPScreenFX.SetAlpha( maxValue * 255 )
	EMPScreenFX.FadeOverTimeDelayed( 0, fadeTime, duration )
	EMPScreenFlash.Show()
	EMPScreenFlash.SetAlpha( 255 )
	EMPScreenFlash.FadeOverTimeDelayed( 0, fadeOutTime, 0 )

	wait duration + fadeTime
}

/*------------------------------------Post Game Ending Armada------------------------------------*/
function HideEndingArmada()
{
	level.endingArmadaData <- {}
	level.endingArmadaData[ TEAM_MILITIA ] <- []
	level.endingArmadaData[ TEAM_IMC ] <- []
	level.endingArmadaData[ "debris" ] <- []

	local armadaMCOR = GetClientEntArray( "prop_dynamic", "ending_scene_ships_MCOR" )
	local armadaIMC = GetClientEntArray( "prop_dynamic", "ending_scene_ships_IMC" )
	local debris = GetClientEntArray( "prop_dynamic", "ending_scene_ships_debris" )

	foreach ( ship in armadaMCOR )
		level.endingArmadaData[ TEAM_MILITIA ].append( GetEndingArmadaData( ship ) )
	foreach ( ship in armadaIMC )
		level.endingArmadaData[ TEAM_IMC ].append( GetEndingArmadaData( ship ) )
	foreach ( piece in debris )
		level.endingArmadaData[ "debris" ].append( GetEndingArmadaData( piece ) )


	foreach ( ship in armadaMCOR )
		ship.Kill()
	foreach ( ship in armadaIMC )
		ship.Kill()
	foreach ( piece in debris )
		piece.Kill()
}

function GetEndingArmadaData( ship )
{
	local data = {}
	data.origin 	<- ship.GetOrigin()
	data.angles 	<- ship.GetAngles()
	data.model 		<- ship.GetModelName()

	return data
}

function DoEndingArmada( team )
{
	local armada = []
	local debris = []

	foreach ( data in level.endingArmadaData[ team ] )
	{
		local ship = CreateClientsideScriptMover( data.model, data.origin, data.angles )
		armada.append( ship )
	}
	foreach ( data in level.endingArmadaData[ "debris" ] )
	{
		local piece = CreateClientsideScriptMover( data.model, data.origin, data.angles )
		piece.SetFadeDistance( 60000 )
		debris.append( piece )
	}

	CalcEndingArmada( armada )
	CalcEndingArmada( debris )

	local time = 90
	foreach ( ship in armada )
		ship.NonPhysicsMoveTo( ship.s.movePos, time, 0, 0 )

	foreach ( piece in debris )
	{
		piece.NonPhysicsMoveTo( piece.s.movePos, time, 0, 0 )
		piece.NonPhysicsRotateTo( piece.s.moveAng, 20, 0, 0 )
	}
}

function CalcEndingArmada( armada )
{
	foreach( ship in armada )
	{
		local name = ship.GetModelName().tolower()

		switch( name )
		{
			case FLEET_MCOR_ANNAPOLIS_1000X:
			case FLEET_CAPITAL_SHIP_ARGO_1000X:
				ship.s.movePos <- ( ship.GetOrigin() + ship.GetForwardVector() * 150 )
				break

			case FLEET_MCOR_BIRMINGHAM_1000X:
			case FLEET_MCOR_BIRMINGHAM_1000X_CLUSTERA:
			case FLEET_IMC_WALLACE_1000x:
			case FLEET_IMC_WALLACE_1000X_CLUSTERA:
			case FLEET_IMC_WALLACE_1000X_CLUSTERB:
			case FLEET_IMC_WALLACE_1000X_CLUSTERC:
				ship.s.movePos <- ( ship.GetOrigin() + ship.GetForwardVector() * 180 )
				break

			case FLEET_MCOR_REDEYE_1000X:
			case FLEET_MCOR_REDEYE_1000X_CLUSTERA:
			case FLEET_MCOR_REDEYE_1000X_CLUSTERB:
			case FLEET_MCOR_REDEYE_1000X_CLUSTERC:
			case FLEET_IMC_CARRIER_1000X:
			case FLEET_IMC_CARRIER_1000X_CLUSTERA:
			case FLEET_IMC_CARRIER_1000X_CLUSTERB:
			case FLEET_IMC_CARRIER_1000X_CLUSTERC:
				ship.s.movePos <- ( ship.GetOrigin() + ship.GetForwardVector() * 170 )
				break

			case FLEET_MCOR_CROW_1000X_CLUSTERA:
			case FLEET_MCOR_CROW_1000X_CLUSTERB:
			case FLEET_IMC_GOBLIN_1000X:
				ship.s.movePos <- ( ship.GetOrigin() + ship.GetForwardVector() * 200 )
				break

			case "models/vehicle/goblin_dropship/goblin_dropship_debris_01.mdl":
				ship.SetOrigin( ship.GetOrigin() + Vector( -500, 0, 0 ) )
				ship.s.movePos <- ( ship.GetOrigin() + Vector( RandomFloat( 1400, 2400 ), 0, 0) )
				local angles 	= ship.GetAngles()
				local pitch 	= angles.x
				local yaw 		= angles.y
				local roll 		= angles.z

				local min = 300
				local max = 360

				if ( pitch > 0 )
					pitch = RandomFloat( -max, -min )
				else
					pitch = RandomFloat( min, max )
				if ( yaw > 0 )
					yaw = RandomFloat( -max, -min )
				else
					yaw = RandomFloat( min, max )
				if ( roll > 0 )
					roll = RandomFloat( -max, -min )
				else
					roll = RandomFloat( min, max )

				ship.s.moveAng <- Vector( pitch, yaw, roll )
				break

			default:
				Assert( 0, "didn't handle " + name )
				break
		}
	}
}

/*------------------------------------Ambient SFX------------------------------------*/
function AmbientFleetSoundThink()
{
	if( Flag( "InGameArmadasWarpOut" ) )
		return
	FlagEnd( "InGameArmadasWarpOut" )

	OnThreadEnd(
		function() : ()
		{
			FadeOutSoundOnEntity( GetLocalViewPlayer(), SFX_AMB_O2_FLEET_BATTLE, 1 )
		}
	)

	local duration = level.fleetIntroTravelTime * level.fleetArrivalTimeModifier
	if ( ShouldSkipFleetTravel() )
		duration = 1.0

	local maxVolume			= 1.0
	local volume 			= 0.0
	local volumeIncrement 	= maxVolume / duration.tofloat()
	local sound 			= EmitSoundOnEntity( GetLocalViewPlayer(), SFX_AMB_O2_FLEET_BATTLE )

	while( 1 )
	{
		volume += volumeIncrement

		if( volume >= maxVolume )
			break

		SetSoundVolumeOnEntity( GetLocalViewPlayer(), SFX_AMB_O2_FLEET_BATTLE, volume )
		wait 1
	}

	// If we broke out of the loop due to reaching max volume, wait until it's time to stop playing the sound
	FlagWait( "InGameArmadasWarpOut" )
}
