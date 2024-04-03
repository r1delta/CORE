const CAPSHIP_BIRM_MODEL = "models/vehicle/capital_ship_birmingham/birmingham.mdl"
const CAPSHIP_ANNA_MODEL = "models/vehicle/capital_ship_annapolis/annapolis.mdl"
const KNIFE_MODEL = "models/weapons/combat_knife/w_combat_knife.mdl"

const FX_TITAN_COCKPIT_LIGHT = "veh_interior_DLight_cabin"
const FX_DROPSHIP_WARPOUT_SPACE = "veh_carrier_warp_out_full_SB"

const SQUADSIZE = 4

function main()
{
	if ( reloadingScripts )
		return

	IncludeFile( "mp/mp_fracture_cinematics" )

	if ( GetCinematicMode() )
		FlagSet( "CinematicIntro" )

	FlagSet( "CinematicOutro" ) //-->deprecated? do we even need this anymore?

	FlagInit( "IntroGoMilitia" )
	FlagInit( "MCOR_captain_anim" )
	FlagInit( "IMC_captain_anim" )
	FlagInit( "IntroMilitiaNPCsSpawned" )
	FlagInit( "IntroGoIMC" )
	FlagInit( "MCORCaptainReadyToFight" )
	FlagInit( "IMCCaptainReadyToFight" )
	FlagInit( "IMC_IntroDone" )
	FlagInit( "MCORGroup1Assault" )
	FlagInit( "MILITIA_IntroDone" )
	FlagInit( "spaceSceneStart" )
	FlagInit( "MilitiaWarped" )
	FlagInit( "TransitionEvent" )
	FlagInit( "IMC_idleover")
	FlagInit( "IMCSeesFleetInvade" )

	PrecacheModel( GRAVES_MODEL )
	PrecacheModel( BLISK_MODEL )
	PrecacheModel( KNIFE_MODEL )
	PrecacheModel( DROPSHIP_HERO_PLATFORM )
	PrecacheModel( SPYGLASS_MODEL )
	PrecacheModel( TEAM_MILITIA_CAPTAIN_MDL )
	PrecacheModel( TEAM_IMC_CAPTAIN_MDL )
	PrecacheModel( CAPSHIP_BIRM_MODEL )
	PrecacheModel( CAPSHIP_ANNA_MODEL )
	PrecacheModel( CASE_MODEL )
	PrecacheModel( SKYBOX_ARMADA_SHIP_MODEL_BERMINGHAM )
	PrecacheModel( "models/weapons/rspn101/r101_ab_01.mdl" )

	PrecacheModel( HORNET_MODEL )
	IncludeFileAllowMultipleLoads( "mp/_vehicle_gunship" )
	PrecacheModel( REDEYE_MODEL )

	PrecacheModel( BISH_MODEL )
	PrecacheModel( MAC_MODEL )
	PrecacheModel( MARVIN_NO_JIGGLE_MODEL )
	PrecacheModel( SARAH_MODEL )
	PrecacheModel( LAPTOP_MODEL )

	PrecacheWeapon( "mp_weapon_mega_turret_aa" )

	PrecacheParticleSystem( FX_TITAN_COCKPIT_LIGHT )
	PrecacheParticleSystem( FX_DROPSHIP_WARPOUT_SPACE )
	PrecacheParticleSystem( "bish_comp_glow_01" )

	RegisterSignal( "dialogue" )
	RegisterSignal( "StopShaking" )

	//AddCustomPlayerCinematicFunc( IMCPlayerSkyScale, TEAM_IMC )

	if ( GetCinematicMode() && GAMETYPE == CAPTURE_POINT )
	{
		SetGameWonAnnouncement( "FractureWonAnnouncement" )
		SetGameLostAnnouncement( "FractureLostAnnouncement" )
		SetGameModeAnnouncement( "GameModeAnnounce_CP" )
	}
}

function EntitiesDidLoad()
{
	if ( !IsServer() )
		return

	GM_AddEndRoundFunc( EndRoundMain )

	RegisterSignal( "megathumper_impact" )

	local thumpers = GetEntArrayByNameWildCard_Expensive( "thumper_animated*" )
	local generators = GetEntArrayByNameWildCard_Expensive( "thumper_generator__animated*" )
	local skyboxPlates = GetEntArrayByNameWildCard_Expensive( "sky_plate_animated*" )
	local skyboxThumpers = GetEntArrayByNameWildCard_Expensive( "sky_thumper_animated*" )
	local radarArrays = GetEntArrayByNameWildCard_Expensive( "radar_tower_animated*" )
	local treesKnotty = GetEntArrayByNameWildCard_Expensive( "tree_knotty_anim*" )

	foreach ( thumper in thumpers )
		thread StaggerThumperAnim( thumper )

	foreach ( generator in generators )
		thread ThumperGeneratorAnim( generator )

	foreach ( radar in radarArrays )
		thread RadarAnim( radar )

	foreach ( tree in treesKnotty )
		thread TreeAnim( tree )

	//HACK ->adjusting for new getin anims
	local shipArray = GetEntArrayByNameWildCard_Expensive( "endingRescueShip*" )
	foreach ( node in shipArray )
		node.SetOrigin( node.GetOrigin() + ( node.GetForwardVector() * -48 ) )



	foreach ( skyboxThumper in skyboxThumpers )
	{
		thread SkyboxThumperAnim_loop( skyboxThumper )
		thread SkyboxThumperSounds( skyboxThumper )
	}

	foreach ( skyboxPlate in skyboxPlates )
		thread SkyboxLandPlateAnim_loop( skyboxPlate )

	if ( GAMETYPE == CAPTURE_POINT )
		InitHardpointTurrets()

	InitSpaceArmada()
	if ( GetCinematicMode() )
		thread IntroFractureMain()

	if ( GetCinematicMode() )
		level.levelSpecificChatterFunc = FractureSpecificChatter

	local ref = GetEnt( "intro_MCOR_spacenode" )
	local angles = ref.GetAngles()
	angles = angles.AnglesCompose( Vector( 30,200,20 ) )
	local spacenode = CreateScriptRef( ref.GetOrigin(), angles )

	if ( EvacEnabled() )
	{
		Evac_SetSpaceNode( spacenode )

		Evac_SetupDefaultVDUs()

		// Set up the extract ship locations and spectator view for each
		Evac_AddLocation( "endingRescueShip1", Vector( 5433, 2784, 280 ), Vector( -14, 173, 0 ) )
		Evac_AddLocation( "endingRescueShip2", Vector( 6458, -643, 512 ), Vector( -6, 137, 0 ) )
		Evac_AddLocation( "endingRescueShip3", Vector( -751, -5043, 1314 ), Vector( 0, 62, 0 ) )
		Evac_AddLocation( "endingRescueShip4", Vector( -4131, -6485, 673 ), Vector( 0, 57, 0 ) )

		//Evac_SetCustomDropshipFunc( SetEvacDropship )

	}

}

function InitHardpointTurrets()
{
	Assert( GAMETYPE == CAPTURE_POINT )

	// Set up hardpoint turrets
	local turret_hpA = GetEnt("turret_mega_hpA")
	local turret_hpB = GetEnt("turret_mega_hpB")
	local turret_hpC = GetEnt("turret_mega_hpC")

	turret_hpA.GiveWeapon( "mp_weapon_mega_turret_aa" )
	turret_hpA.SetActiveWeapon( "mp_weapon_mega_turret_aa" )
	turret_hpA.s.notitle <- true
	SetCrosshairTeamColoringDisabled( turret_hpA, true )

	turret_hpB.GiveWeapon( "mp_weapon_mega_turret_aa" )
	turret_hpB.SetActiveWeapon( "mp_weapon_mega_turret_aa" )
	turret_hpB.s.notitle <- true
	SetCrosshairTeamColoringDisabled( turret_hpB, true )

	turret_hpC.GiveWeapon( "mp_weapon_mega_turret_aa" )
	turret_hpC.SetActiveWeapon( "mp_weapon_mega_turret_aa" )
	turret_hpC.s.notitle <- true
	SetCrosshairTeamColoringDisabled( turret_hpC, true )

	LinkTurretWithHardpoint( GetEnt("hpA"), turret_hpA, TEAM_IMC )
	LinkTurretWithHardpoint( GetEnt("hpB"), turret_hpB, TEAM_IMC )
	LinkTurretWithHardpoint( GetEnt("hpC"), turret_hpC, TEAM_IMC )
}

function IntroFractureMain()
{
	SetGlobalForcedDialogueOnly( true )
	FlagSet( "Disable_IMC" )//no random ai spawning
	FlagSet( "Disable_MILITIA" )//no random ai spawning

	IntroSetupMilitiaHero()
	IntroSetupMilitiaNPC()
	IntroSetupIMCHero()
	IntroSetupIMCNPC()

	FlagWait( "ReadyToStartMatch" )
	delaythread( 23 ) FlagSet( "TransitionEvent" )

	thread IntroMilitia()
	thread IntroMilitiaCaptain()
	thread IntroMilitiaCaptainGruntSquad()
	local nodes = GetEntArrayByNameWildCard_Expensive( "introSquadGrunt*" )
	foreach ( node in nodes )
		thread IntroSquadGrunt( node )

	thread IntroIMC()
	thread IntroIMCCaptain()
	thread IntroIMCGrunts()
	thread IntroIMCCaptainGruntSquad()

	FlagWait( "IMC_IntroDone" )
	FlagWait( "MILITIA_IntroDone" )
	FlagClear( "Disable_IMC" )
	FlagClear( "Disable_MILITIA" )

	wait 5.0
	SetGlobalForcedDialogueOnly( false )
	FlagSet( "IntroDone" )
}

/************************************************************************************************\

 ######  ######## ######## ##     ## ########        ##     ##  ######   #######  ########
##    ## ##          ##    ##     ## ##     ##       ###   ### ##    ## ##     ## ##     ##
##       ##          ##    ##     ## ##     ##       #### #### ##       ##     ## ##     ##
 ######  ######      ##    ##     ## ########        ## ### ## ##       ##     ## ########
      ## ##          ##    ##     ## ##              ##     ## ##       ##     ## ##   ##
##    ## ##          ##    ##     ## ##              ##     ## ##    ## ##     ## ##    ##
 ######  ########    ##     #######  ##              ##     ##  ######   #######  ##     ##

\************************************************************************************************/
function IntroSetupMilitiaHero()
{
	local offset 	= Vector( -100,215,0 )
	local idlenode 	= GetEnt( "intro_MCOR_spacenode" )
	local angles 	= idlenode.GetAngles()
	angles = angles.AnglesCompose( Vector( 2, 0, 0 ) )
	idlenode.SetAngles( angles )

	//MILITIA SIDE
	////////////////////////////////////////////////////////////
	local spawnnode 	= GetEnt( "intro_idle_militia_1" )
	local dropnode 		= GetEnt( "gpmm_end_drop_ref" )

	local create			= CreateCinematicDropship()
	create.origin 			= spawnnode.GetOrigin()
	create.team				= TEAM_MILITIA
	create.count 			= 4
	create.side 			= "jump"

	local event1 			= CreateCinematicEvent()
	event1.origin 			= idlenode.GetOrigin()
	event1.angles			= idlenode.GetAngles()
	event1.anim				= "ds_space_flyby_dropshipA"
	event1.teleport 		= true
	event1.proceduralLength	= true
	event1.skycam			= SKYBOXSPACE
	Event_AddFlagSetOnStart( event1, "spaceSceneStart" )
	Event_AddClientStateFunc( event1, "CE_FractureVisualSettingsSpace" )
	Event_AddServerStateFunc( event1, CE_PlayerSkyScaleSpace )

	local event2 			= CreateCinematicEvent()
	event2.origin 			= dropnode.GetOrigin() + offset
	event2.yaw				= dropnode.GetAngles().y
	event2.anim				= "gd_fracture_flyin_mcor_L"
	event2.teleport 		= true
	event2.preAnimFPSWarp 	= true
	Event_AddFlagSetOnWarp( event2, "MilitiaWarped" )
	Event_AddFlagSetOnStart( event2, "IntroGoMilitia" )
	Event_AddAnimStartFunc( event2, IntroMilitiaHerosPart2 )
	Event_AddClientStateFunc( event2, "CE_VisualSettingsDropshipInterior" )
	Event_AddClientStateFunc( event2, "CE_BloomOnRampOpen" )
	Event_AddServerStateFunc( event2, CE_PlayerSkyScaleDropshipInterior )
	Event_AddServerStateFunc( event2, CE_PlayerSkyScaleOnRampOpen )

	AddSavedDropEvent( "introDropShipMCOR_1cr", create )
	AddSavedDropEvent( "introDropShipMCOR_1e1", event1 )
	AddSavedDropEvent( "introDropShipMCOR_1e2", event2 )

	////////////////////////////////////////////////////////////
	local spawnnode 	= GetEnt( "intro_idle_militia_2" )
	local dropnode 		= GetEnt( "gpmm_end_drop_ref" )

	local create			= CreateCinematicDropship()
	create.origin 			= spawnnode.GetOrigin()
	create.team				= TEAM_MILITIA
	create.count 			= 4
	create.side 			= "jump"

	local event1 			= CreateCinematicEvent()
	event1.origin 			= idlenode.GetOrigin()
	event1.angles			= idlenode.GetAngles()
	event1.anim				= "ds_space_flyby_dropshipB"
	event1.teleport 		= true
	event1.proceduralLength	= true
	event1.skycam			= SKYBOXSPACE
	Event_AddFlagSetOnStart( event1, "spaceSceneStart" )
	Event_AddClientStateFunc( event1, "CE_FractureVisualSettingsSpace" )
	Event_AddServerStateFunc( event1, CE_PlayerSkyScaleSpace )

	local event2 			= CreateCinematicEvent()
	event2.origin 			= dropnode.GetOrigin() + offset
	event2.yaw				= dropnode.GetAngles().y
	event2.anim				= "gd_fracture_flyin_mcor_R"
	event2.teleport 		= true
	event2.preAnimFPSWarp 	= true
	Event_AddFlagSetOnWarp( event2, "MilitiaWarped" )
	Event_AddFlagSetOnStart( event2, "IntroGoMilitia" )
	Event_AddAnimStartFunc( event2, IntroMilitiaHerosPart2 )
	Event_AddClientStateFunc( event2, "CE_VisualSettingsDropshipInterior" )
	Event_AddClientStateFunc( event2, "CE_BloomOnRampOpen" )
	Event_AddServerStateFunc( event2, CE_PlayerSkyScaleDropshipInterior )
	Event_AddServerStateFunc( event2, CE_PlayerSkyScaleOnRampOpen )

	AddSavedDropEvent( "introDropShipMCOR_2cr", create )
	AddSavedDropEvent( "introDropShipMCOR_2e1", event1 )
	AddSavedDropEvent( "introDropShipMCOR_2e2", event2 )
}

function IntroSetupMilitiaNPC()
{
	local dropnode 	= GetEnt( "introMilitiaNPCzipright" )
	local drop 		= CreateScriptedDropship()
	drop.origin 	= dropnode.GetOrigin()
	drop.yaw 		= dropnode.GetAngles().y
	drop.anim		= "gd_flyin_A_left_localnodes"
	drop.team 		= TEAM_MILITIA
	drop.side 		= "right"
	drop.count 		= GetCPULevelWrapper() == CPU_LEVEL_HIGHEND ? 3 : 2
	drop.squadFunc 	= ScriptedSquadAssault
	drop.squadParm 	= 2
	drop.style 		= eDropStyle.FORCED
	drop.customSnd	= "fracture_scr_intro_DropshipIn_2"
	AddSavedDropEvent( "introMilitiaNPCship_2", drop )

	local leftOrigin 	= GetEnt( "introzipland2" ).GetOrigin()
	local centerOrigin 	= GetEnt( "introzipland1" ).GetOrigin()
	local rightOrigin 	= GetEnt( "introzipland3" ).GetOrigin()
	CreateZiplinePoints( drop, "right", leftOrigin, centerOrigin, rightOrigin )

	local dropnode 	= GetEnt( "introMilitiaNPCzipleft" )
	local drop 		= CreateScriptedDropship()
	drop.origin 	= dropnode.GetOrigin()
	drop.yaw 		= dropnode.GetAngles().y
	drop.anim		= DROPSHIP_DROP_ANIM
	drop.team 		= TEAM_MILITIA
	drop.side 		= "left"
	drop.count 		= GetCPULevelWrapper() == CPU_LEVEL_HIGHEND ? 3 : 2
	drop.squadFunc 	= ScriptedSquadAssault
	drop.squadParm 	= 0
	drop.style 		= eDropStyle.FORCED
	drop.customSnd	= "fracture_scr_intro_DropshipIn_1"
	AddSavedDropEvent( "introMilitiaNPCship_3", drop )

	local leftOrigin 	= GetEnt( "introzipland4" ).GetOrigin()
	local centerOrigin 	= GetEnt( "introzipland6" ).GetOrigin()
	local rightOrigin 	= GetEnt( "introzipland5" ).GetOrigin()
	CreateZiplinePoints( drop, "left", leftOrigin, centerOrigin, rightOrigin )
}


/************************************************************************************************\

#### ##    ## ######## ########   #######        ##     ##  ######   #######  ########
 ##  ###   ##    ##    ##     ## ##     ##       ###   ### ##    ## ##     ## ##     ##
 ##  ####  ##    ##    ##     ## ##     ##       #### #### ##       ##     ## ##     ##
 ##  ## ## ##    ##    ########  ##     ##       ## ### ## ##       ##     ## ########
 ##  ##  ####    ##    ##   ##   ##     ##       ##     ## ##       ##     ## ##   ##
 ##  ##   ###    ##    ##    ##  ##     ##       ##     ## ##    ## ##     ## ##    ##
#### ##    ##    ##    ##     ##  #######        ##     ##  ######   #######  ##     ##

\************************************************************************************************/
function IntroMilitia()
{
	thread IntroSpaceScene()

	local table 	= GetSavedDropEvent( "introDropShipMCOR_1cr" )
	local event1 	= GetSavedDropEvent( "introDropShipMCOR_1e1" )
	local event2 	= GetSavedDropEvent( "introDropShipMCOR_1e2" )
	local dropship1 = SpawnCinematicDropship( table )
	dropship1.SetJetWakeFXEnabled( false )
	thread IntroMilitiaHeros( dropship1 )
	thread RunCinematicDropship( dropship1, event1, event2 )

	local table 	= GetSavedDropEvent( "introDropShipMCOR_2cr" )
	local event1 	= GetSavedDropEvent( "introDropShipMCOR_2e1" )
	local event2 	= GetSavedDropEvent( "introDropShipMCOR_2e2" )
	local dropship2	= SpawnCinematicDropship( table )
	dropship2.SetJetWakeFXEnabled( false )
	thread IntroMilitiaHeros( dropship2 )
	thread RunCinematicDropship( dropship2, event1, event2 )

	thread IntroMCORExperience( dropship1, dropship2 )

	DebugSkipCinematicSlots( TEAM_MILITIA, 0 )
	//0 - front right
	//1 - back right
	//2 - front left
	//3 - back left

	FlagWait( "IntroGoMilitia" )

	dropship1.SetJetWakeFXEnabled( true )
	dropship2.SetJetWakeFXEnabled( true )

	wait 10.75
	local drop 	= GetSavedDropEvent( "introMilitiaNPCship_2" )
	thread RunScriptedDropShip( drop )

	local drop 	= GetSavedDropEvent( "introMilitiaNPCship_3" )
	thread  RunScriptedDropShip( drop )

	wait WARPINFXTIME + 0.5//to make sure npc's spawned
	FlagSet( "IntroMilitiaNPCsSpawned" )
}

function IntroMCORExperience( dropship1, dropship2 )
{
	thread DropshipMCORIdleShake( dropship1 )
	thread DropshipMCORIdleShake( dropship2 )

	PlaySoundToAttachedPlayers( dropship1, "fracture_scr_intro_dropship_amb" )
	PlaySoundToAttachedPlayers( dropship2, "fracture_scr_intro_dropship_amb" )
	PlaySoundToAttachedPlayers( dropship1, "diag_cmp_intro_frac_idlechatter_01" )
	PlaySoundToAttachedPlayers( dropship2, "diag_cmp_intro_frac_idlechatter_01" )

	FlagWait( "TransitionEvent" )

	PlaySoundToAttachedPlayers( dropship1, "fracture_scr_intro_dropship_warpjump", "fracture_scr_intro_dropship_amb" )
	PlaySoundToAttachedPlayers( dropship2, "fracture_scr_intro_dropship_warpjump", "fracture_scr_intro_dropship_amb" )
	thread DropshipMCORFlyinShake( dropship1 )
	thread DropshipMCORFlyinShake( dropship2 )

	FlagWait( "MilitiaWarped" )
}

function DropshipMCORIdleShake( dropship )
{
	dropship.EndSignal( "StopShaking" )
	dropship.EndSignal( "OnDeath" )

	local radius = 200
	local shake, amplitude, frequency, duration

	//	delaythread( 3.0 ) DebugDrawSphereOnTag( dropship, "ORIGIN", radius, 255, 100, 100, 20 )

	//min rumble
	amplitude 	= 0.25
	frequency 	= 5
	duration 	= 20.0
	shake = CreateShake( dropship.GetOrigin(), amplitude, frequency, duration, radius )
	shake.SetParent( dropship, "ORIGIN" )

	//sound of ship rattling
	wait 7
	amplitude 	= 1
	frequency 	= 25
	duration 	= 5
	shake = CreateShake( dropship.GetOrigin(), amplitude, frequency, duration, radius )
	shake.SetParent( dropship, "ORIGIN" )

	wait duration - 1.0
	//min rumble
	amplitude 	= 0.25
	frequency 	= 5
	duration 	= 20.0
	shake = CreateShake( dropship.GetOrigin(), amplitude, frequency, duration, radius )
	shake.SetParent( dropship, "ORIGIN" )

	//bermingham passing by window
	wait 11
	amplitude 	= 0.75
	frequency 	= 25
	duration 	= 5
	shake = CreateShake( dropship.GetOrigin(), amplitude, frequency, duration, radius )
	shake.SetParent( dropship, "ORIGIN" )

	wait duration - 1.0
	//min rumble
	amplitude 	= 0.25
	frequency 	= 5
	duration 	= 40.0
	shake = CreateShake( dropship.GetOrigin(), amplitude, frequency, duration, radius )
	shake.SetParent( dropship, "ORIGIN" )
}

function DropshipMCORFlyinShake( dropship )
{
	dropship.Signal( "StopShaking" )
	dropship.EndSignal( "OnDeath" )

	local radius = 200
	local shake, amplitude, frequency, duration

	wait 2.0
	//build up to warp
	amplitude 	= 0.0
	frequency 	= 25
	duration 	= 1.0

	local max 	= 30
	local ramp 	= 0.25
	for( local i = 1; i <= max; i++ )
	{
		amplitude 	= ramp * i
		shake = CreateShake( dropship.GetOrigin(), amplitude, frequency, duration, radius )
		shake.SetParent( dropship, "ORIGIN" )

		wait 0.2
	}

	wait duration - 0.5

	//ramp down from warp
	amplitude 	= 5
	frequency 	= 25
	duration 	= 1.0
	shake = CreateShake( dropship.GetOrigin(), amplitude, frequency, duration, radius )
	shake.SetParent( dropship, "ORIGIN" )

	wait duration - 0.25

	//min rumble
	amplitude 	= 0.5
	frequency 	= 10
	duration 	= 20.0
	shake = CreateShake( dropship.GetOrigin(), amplitude, frequency, duration, radius )
	shake.SetParent( dropship, "ORIGIN" )

	wait 6.0

	//door open
	amplitude 	= 3.0
	frequency 	= 25
	duration 	= 3.0
	shake = CreateShake( dropship.GetOrigin(), amplitude, frequency, duration, radius )
	shake.SetParent( dropship, "ORIGIN" )

	wait duration - 0.5

	//min rumble with wind
	amplitude 	= 0.6
	frequency 	= 13
	duration 	= 11.25
	shake = CreateShake( dropship.GetOrigin(), amplitude, frequency, duration, radius )
	shake.SetParent( dropship, "ORIGIN" )
}

/************************************************************************************************\

##     ##  ######   #######  ########        ##     ## ######## ########   #######
###   ### ##    ## ##     ## ##     ##       ##     ## ##       ##     ## ##     ##
#### #### ##       ##     ## ##     ##       ##     ## ##       ##     ## ##     ##
## ### ## ##       ##     ## ########        ######### ######   ########  ##     ##
##     ## ##       ##     ## ##   ##         ##     ## ##       ##   ##   ##     ##
##     ## ##    ## ##     ## ##    ##        ##     ## ##       ##    ##  ##     ##
##     ##  ######   #######  ##     ##       ##     ## ######## ##     ##  #######

\************************************************************************************************/
function IntroMilitiaHeros( dropship )
{
	dropship.EndSignal( "OnDeath" )

	local bish = CreatePropDynamic( BISH_MODEL )
	local mac = CreatePropDynamic( MAC_MODEL )
	local marv = CreatePropDynamic( MARVIN_NO_JIGGLE_MODEL )
	local sara = CreatePropDynamic( SARAH_MODEL )
	local pcase = CreatePropDynamic( CASE_MODEL )
	local laptop 	= CreatePropDynamic( LAPTOP_MODEL )

	dropship.s.laptop <- laptop
	AddCustomCinematicRefFunc( dropship, Bind( DoLaptopFxPerPlayer ) )

	thread IntroMilitiaHerosDialogue( bish, mac, sara )

	sara.SetParent( dropship, "ORIGIN" )
	bish.SetParent( dropship, "ORIGIN" )
	mac.SetParent( dropship, "ORIGIN" )
	marv.SetParent( dropship, "ORIGIN" )
	pcase.SetParent( dropship, "pelicanCase" )
	laptop.SetParent( bish, "PROPGUN" )

	bish.MarkAsNonMovingAttachment()
	mac.MarkAsNonMovingAttachment()
	marv.MarkAsNonMovingAttachment()
	sara.MarkAsNonMovingAttachment()
	pcase.MarkAsNonMovingAttachment()
	laptop.MarkAsNonMovingAttachment()

	local skyScaleObj = []
	skyScaleObj.append( sara )
	skyScaleObj.append( bish )
	skyScaleObj.append( mac )
	skyScaleObj.append( marv )
	skyScaleObj.append( pcase )
	skyScaleObj.append( laptop )

	dropship.s.bish <- bish
	dropship.s.mac 	<- mac
	dropship.s.marv <- marv
	dropship.s.sara <- sara
	dropship.s.skyScaleObj <- skyScaleObj

	foreach( obj in skyScaleObj )
		obj.LerpSkyScale( SKYSCALE_SPACE, 0.01 )

	thread PlayAnimTeleport( bish, "Militia_flyinA_idle_bish", dropship, "ORIGIN" )
	thread PlayAnimTeleport( mac, "Militia_flyinA_idle_mac", dropship, "ORIGIN" )
	thread PlayAnimTeleport( marv, "Militia_flyinA_idle_marv", dropship, "ORIGIN" )
	thread PlayAnimTeleport( sara, "Militia_flyinA_idle_sarah", dropship, "ORIGIN" )

	FlagWait( "TransitionEvent" )

	thread PlayAnim( bish, "Militia_flyinA_countdown_bish", dropship, "ORIGIN" )
	thread PlayAnim( mac, "Militia_flyinA_countdown_mac", dropship, "ORIGIN" )
	thread PlayAnim( marv, "Militia_flyinA_countdown_marv", dropship, "ORIGIN" )
	thread PlayAnim( sara, "Militia_flyinA_countdown_sarah", dropship, "ORIGIN" )
}

function IntroMilitiaHerosPart2( dropship, ref, table )
{
	local bish 	= dropship.s.bish
	local mac 	= dropship.s.mac
	local marv 	= dropship.s.marv
	local sara 	= dropship.s.sara
	local skyScaleObj = dropship.s.skyScaleObj

	thread PlayAnim( bish, "Militia_flyinB_exit_bish", dropship, "ORIGIN" )
	thread PlayAnim( mac, 	"Militia_flyinB_exit_mac", dropship, "ORIGIN" )
	thread PlayAnim( marv, "Militia_flyinB_exit_marv", dropship, "ORIGIN" )
	thread PlayAnim( sara, "Militia_flyinB_exit_sarah", dropship, "ORIGIN" )

	FlagWait( "MilitiaWarped" )

	foreach( obj in skyScaleObj )
		obj.LerpSkyScale( SKYSCALE_FRACTURE_WARP, 0.01 )

	dropship.WaitSignal( "sRampOpen" )

	foreach( obj in skyScaleObj )
		obj.LerpSkyScale( SKYSCALE_FRACTURE_DOOROPEN_ACTOR, 1.0 )
}

function IntroMilitiaHerosDialogue( bish, mac, sara )
{
	mac.EndSignal( "OnDeath" )
	mac.WaitSignal( "dialogue" )
	//printt( "Jumping in 3�2�1卪ark!" )
	EmitSoundOnEntity( mac, "diag_mcor_macallan_cmp_frac_prewarp_01" )
}

/************************************************************************************************\

######## #### ########    ###    ##    ##       ##     ##  ######   #######  ########
   ##     ##     ##      ## ##   ###   ##       ###   ### ##    ## ##     ## ##     ##
   ##     ##     ##     ##   ##  ####  ##       #### #### ##       ##     ## ##     ##
   ##     ##     ##    ##     ## ## ## ##       ## ### ## ##       ##     ## ########
   ##     ##     ##    ######### ##  ####       ##     ## ##       ##     ## ##   ##
   ##     ##     ##    ##     ## ##   ###       ##     ## ##    ## ##     ## ##    ##
   ##    ####    ##    ##     ## ##    ##       ##     ##  ######   #######  ##     ##

\************************************************************************************************/
function IntroMilitiaCaptain()
{
	FlagWait( "IntroGoMilitia" )

	wait 3

	//create titan and captain
	local node = GetEnt( "spawnCaptainChang" )

	local table 	= CreateDefaultNPCTitanTemplate( TEAM_MILITIA )
	table.title 	= "#NPC_CAPTAIN_DUNNAM"
	table.weapon	= "mp_titanweapon_40mm"
	table.origin 	= node.GetOrigin() + Vector( 0,0,20 )
	table.angles 	= node.GetAngles()

	local titan = SpawnNPCTitan( table )
	level.MCORCaptainTitan <- titan

	titan.SetEfficientMode( true )
	DisableRodeo( titan )

	local captain = CreatePropDynamic( TEAM_MILITIA_CAPTAIN_MDL, node.GetOrigin() + Vector( 0,0,20 ), node.GetAngles() )
	captain.SetParent( titan, "HIJACK" )
	captain.MarkAsNonMovingAttachment()

	local node = GetEnt( "introCaptainChang" )
	node.SetAngles( node.GetAngles() + Vector( 0,4,0 ) )

	//animate him into an idle
	thread PlayAnimTeleport( captain, "pt_Militia_titan_commander_idle", titan, "HIJACK" )
	thread PlayAnimGravity( titan, "at_Militia_titan_commander_idle", node )

	OnThreadEnd(
		function() : ( captain, titan )
		{
			FlagSet( "MILITIA_IntroDone" )

			if ( IsValid( captain ) )
				captain.Kill( 0.5 )

			if ( IsAlive( titan ) )
			{
				titan.SetEfficientMode( false )
				DeleteAnimEvent( titan, "cockpitOpen", ChangCockpitOpen )
				thread IntroCaptainMCORFight( titan )
			}
		}
	)

	AddAnimEvent( captain, "dialogue", ChangDialogue )
	AddAnimEvent( titan, "cockpitOpen", ChangCockpitOpen )

	titan.EndSignal( "OnDeath" )
	captain.EndSignal( "OnDeath" )

	//time the event
	wait 14.0

	//come out to talk
	thread PlayAnimTeleport( captain, "pt_Militia_titan_commander_officer", titan, "HIJACK" )

	local blendtime = 0.0

	FlagSet( "MCOR_captain_anim" )
	titan.DisableStarts()
	waitthread PlayAnimGravity( titan, "at_Militia_titan_commander", node, null, blendtime )
}

function ChangDialogue( captain )
{
	//printt( "McCord, take your squad up this road! The rest of you move through this building behind me and secure all hardpoints!" )
	EmitSoundOnEntity( captain, "diag_cmp_frac_mcor_tcapn1_squadmove_10" )

	delaythread( 4.0 ) FlagSet( "MILITIA_IntroDone" )
}

function ChangCockpitOpen( titan )
{
	thread ChangCockpitOpenThread( titan )
}

function ChangCockpitOpenThread( titan )
{
	local fx = PlayFXOnEntity( FX_TITAN_COCKPIT_LIGHT, titan, "HIJACK" )

	titan.EndSignal( "OnDeath" )

	OnThreadEnd(
		function() : ( fx )
		{
			if ( !IsValid_ThisFrame( fx ) )
				return

			fx.Fire( "Stop" )
			fx.ClearParent()
			fx.Destroy()
		}
	)

	titan.WaittillAnimDone()
}

/************************************************************************************************\

 ######   ########  ##     ## ##    ## ########       ##     ##  ######   #######  ########
##    ##  ##     ## ##     ## ###   ##    ##          ###   ### ##    ## ##     ## ##     ##
##        ##     ## ##     ## ####  ##    ##          #### #### ##       ##     ## ##     ##
##   #### ########  ##     ## ## ## ##    ##          ## ### ## ##       ##     ## ########
##    ##  ##   ##   ##     ## ##  ####    ##          ##     ## ##       ##     ## ##   ##
##    ##  ##    ##  ##     ## ##   ###    ##          ##     ## ##    ## ##     ## ##    ##
 ######   ##     ##  #######  ##    ##    ##          ##     ##  ######   #######  ##     ##

\************************************************************************************************/
function IntroMilitiaCaptainGruntSquad()
{
	FlagWait( "IntroGoMilitia" )

	local squad = []

	wait 3

	local ref = GetEnt( "introCaptainChang" )
	local node = CreateScriptRef( ref.GetOrigin() + Vector( -50,107,0 ), ref.GetAngles() + Vector( 0,175,0 ) )

	local max = GetCPULevelWrapper() == CPU_LEVEL_HIGHEND ? 3 : 2
	for ( local i = 0; i < max; i++ )
	{
		local guy = Spawn_TrackedGrunt( TEAM_MILITIA, "", node.GetOrigin(), node.GetAngles() )
		squad.append( guy )

		thread IntroMilitiaCaptainGrunt( guy, i, node )
	}

	local node = CreateScriptRef( ref.GetOrigin() + Vector( 40,100,0 ), ref.GetAngles() + Vector( 0,180,0 ) )
	local guy = Spawn_TrackedGrunt( TEAM_MILITIA, "", node.GetOrigin(), node.GetAngles() )
	squad.append( guy )
	thread IntroMilitiaCaptainGrunt( guy, 3, node )

	FlagWait( "MILITIA_IntroDone" )

	FlagWait( "MCORGroup1Assault" )
	local index = 1
	ScriptedSquadAssault( squad, index )
}

function IntroMilitiaCaptainGrunt( guy, index, node )
{
	guy.EndSignal( "OnDeath" )

	local idles = [
		"pt_titan_briefingA_guy1_idle",
		"pt_titan_briefingA_guy2_idle",
		"pt_titan_briefingA_guy3_idle",
		"pt_titan_briefingB_guy2_idle",
	]

	local anims = [
		"pt_titan_briefingA_guy1",
		"pt_titan_briefingA_guy2",
		"pt_titan_briefingA_guy3",
		"pt_titan_briefingB_guy2",
	]

	guy.SetEfficientMode( true )

	thread PlayAnimGravity( guy, idles[ index ], node )

	FlagWait( "MCOR_captain_anim" )

	guy.DisableStarts()

	waitthread PlayAnimGravity( guy, anims[ index ], node )

	guy.SetEfficientMode( false )

	waitthread GotoOrigin( guy, Vector( 2492, 2993, 0 ) )
	FlagSet( "MCORGroup1Assault" )
	guy.EnableStarts()
}

function ClearGuysMoveAnim( guy, index )
{
	if ( !IsAlive( guy ) )
		return

	switch ( index )
	{
		case 0:
			guy.SetMoveAnim( "gun_run" )
			break
		case 1:
			guy.SetMoveAnim( "gun_run2" )
			break
		default:
			guy.SetMoveAnim( "gun_run3" )
			break
	}

	guy.EndSignal( "OnDeath" )

	wait 0.25
	guy.ClearMoveAnim()
}

function IntroSquadGrunt( node )
{
	FlagWait( "IntroGoMilitia" )
	wait 3

	local guy = Spawn_TrackedGrunt( TEAM_MILITIA, "", node.GetOrigin(), node.GetAngles() )

	guy.EndSignal( "OnDeath" )

	wait RandomFloat( 0, 1.5 )

	local origin = HackGetDeltaToRef( node.GetOrigin(), node.GetAngles(), guy, "CQB_Idle_Casual" )
	node.SetOrigin( origin )

	thread PlayAnimGravity( guy, "CQB_Idle_Casual", node )

	local squad = [ guy ]
	local index, anim

	switch( node.GetName() )
	{
		case "introSquadGrunt0":
			index = 0
			anim = "React_signal_thatway"
			break

		case "introSquadGrunt1":
			index = 2
			anim = "React_signal_overthere"
			break
	}

	FlagWait( "IntroMilitiaNPCsSpawned" )

	ScriptedSquadAssault( squad, index )

	local squad = GetNPCArrayBySquad( guy.kv.squadname )

	ArrayRemove( squad, guy )

	if ( squad.len() == 0 )
		return

	squad[ 0 ].WaitSignal( "npc_deployed" )

	local origin = HackGetDeltaToRef( guy.GetOrigin(), guy.GetAngles(), guy, anim )
	node.SetOrigin( origin )

	waitthread PlayAnimGravity( guy, anim, node )
}

/************************************************************************************************\

 ######  ######## ######## ##     ## ########        #### ##     ##  ######
##    ## ##          ##    ##     ## ##     ##        ##  ###   ### ##    ##
##       ##          ##    ##     ## ##     ##        ##  #### #### ##
 ######  ######      ##    ##     ## ########         ##  ## ### ## ##
      ## ##          ##    ##     ## ##               ##  ##     ## ##
##    ## ##          ##    ##     ## ##               ##  ##     ## ##    ##
 ######  ########    ##     #######  ##              #### ##     ##  ######

\************************************************************************************************/
function IntroSetupIMCHero()
{
	local dropnode 		= GetEnt( "gpmm_end_drop_ref" )
	//IMC SIDE
	////////////////////////////////////////////////////////////
	local create			= CreateCinematicDropship()
	create.origin 			= dropnode.GetOrigin() + Vector( 0,0,200 )
	create.team				= TEAM_IMC
	create.count 			= 4
	create.side 			= "jumpSideR"

	local event0 			= CreateCinematicEvent()
	event0.origin 			= dropnode.GetOrigin()
	event0.yaw	 			= dropnode.GetAngles().y
	event0.anim				= "test_fly_idle"
	event0.teleport 		= true
	Event_AddFlagWaitToEnd( event0, "IMC_idleover")
	Event_AddAnimStartFunc( event0, IntroIMCHeros )

	local event1 			= CreateCinematicEvent()
	event1.origin 			= dropnode.GetOrigin()
	event1.yaw				= dropnode.GetAngles().y
	event1.anim				= "gd_fracture_flyin_imc_bottom"
	event1.teleport 		= true
	Event_AddAnimStartFunc( event1, IntroIMCHeros2 )
	Event_AddClientStateFunc( event1, "CE_VisualSettingsDropshipIMC" )
	Event_AddClientStateFunc( event1, "CE_FractureIMCIntroBogies" )
	Event_AddServerStateFunc( event1, CE_PlayerSkyScaleIMC )

	AddSavedDropEvent( "introDropShipIMC_1cr", create )
	AddSavedDropEvent( "introDropShipIMC_1e0", event0 )
	AddSavedDropEvent( "introDropShipIMC_1e1", event1 )

	////////////////////////////////////////////////////////////
	local create			= CreateCinematicDropship()
	create.origin 			= dropnode.GetOrigin() + Vector( 0,0,200 )
	create.team				= TEAM_IMC
	create.count 			= 4
	create.side 			= "jumpSideR"

	local event0 			= CreateCinematicEvent()
	event0.origin 			= dropnode.GetOrigin()
	event0.yaw	 			= dropnode.GetAngles().y
	event0.anim				= "test_fly_idle"
	event0.teleport 		= true
	Event_AddFlagWaitToEnd( event0, "IMC_idleover")
	Event_AddAnimStartFunc( event0, IntroIMCHeros )

	local event1 			= CreateCinematicEvent()
	event1.origin 			= dropnode.GetOrigin()
	event1.yaw				= dropnode.GetAngles().y
	event1.anim				= "gd_fracture_flyin_imc_top"
	event1.teleport 		= true
	Event_AddAnimStartFunc( event1, IntroIMCHeros2 )
	Event_AddClientStateFunc( event1, "CE_VisualSettingsDropshipIMC" )
	Event_AddClientStateFunc( event1, "CE_FractureIMCIntroBogies" )
	Event_AddServerStateFunc( event1, CE_PlayerSkyScaleIMC )

	AddSavedDropEvent( "introDropShipIMC_2cr", create )
	AddSavedDropEvent( "introDropShipIMC_2e0", event0 )
	AddSavedDropEvent( "introDropShipIMC_2e1", event1 )
}

function IntroSetupIMCNPC()
{

}

function CE_PlayerSkyScaleIMC( player, ref )
{
	player.LerpSkyScale( SKYSCALE_FRACTURE_IMC_PLAYER, 0.01 )
}

/************************************************************************************************\

#### ##    ## ######## ########   #######        #### ##     ##  ######
 ##  ###   ##    ##    ##     ## ##     ##        ##  ###   ### ##    ##
 ##  ####  ##    ##    ##     ## ##     ##        ##  #### #### ##
 ##  ## ## ##    ##    ########  ##     ##        ##  ## ### ## ##
 ##  ##  ####    ##    ##   ##   ##     ##        ##  ##     ## ##
 ##  ##   ###    ##    ##    ##  ##     ##        ##  ##     ## ##    ##
#### ##    ##    ##    ##     ##  #######        #### ##     ##  ######

\************************************************************************************************/
function IntroIMC()
{
	//thread IntroIMCFlyers()
	thread IntroIMCExtras()

	local table 	= GetSavedDropEvent( "introDropShipIMC_1cr" )
	local event0 	= GetSavedDropEvent( "introDropShipIMC_1e0" )
	local event1 	= GetSavedDropEvent( "introDropShipIMC_1e1" )
	local dropship1 = SpawnCinematicDropship( table )
	dropship1.NotSolid()//garauntee players dont get stuck trying to exit the ship
	thread RunCinematicDropship( dropship1, event0, event1 )

	local table 	= GetSavedDropEvent( "introDropShipIMC_2cr" )
	local event0 	= GetSavedDropEvent( "introDropShipIMC_2e0" )
	local event1 	= GetSavedDropEvent( "introDropShipIMC_2e1" )
	local dropship2	= SpawnCinematicDropship( table )
	dropship2.NotSolid()//garauntee players dont get stuck trying to exit the ship
	thread RunCinematicDropship( dropship2, event0, event1 )

	thread IntroIMCExperience( dropship1, dropship2 )

	DebugSkipCinematicSlots( TEAM_IMC, 0 )
	//0 - front right
	//1 - back right
	//2 - front left
	//3 - back left

	wait 4.5
	FlagSet( "IMC_idleover" )
	delaythread( 17.5 ) FlagSet( "IntroGoIMC" )
}

function IntroIMCExperience( dropship1, dropship2 )
{
	PlaySoundToAttachedPlayers( dropship1, "Fracture_Scr_IMCIntro_Dropship_Amb" )
	PlaySoundToAttachedPlayers( dropship2, "Fracture_Scr_IMCIntro_Dropship_Amb" )
}



/************************************************************************************************\

#### ##     ##  ######        ##     ## #### ##       ##          ###    #### ##    ##
 ##  ###   ### ##    ##       ##     ##  ##  ##       ##         ## ##    ##  ###   ##
 ##  #### #### ##             ##     ##  ##  ##       ##        ##   ##   ##  ####  ##
 ##  ## ### ## ##             ##     ##  ##  ##       ##       ##     ##  ##  ## ## ##
 ##  ##     ## ##              ##   ##   ##  ##       ##       #########  ##  ##  ####
 ##  ##     ## ##    ##         ## ##    ##  ##       ##       ##     ##  ##  ##   ###
#### ##     ##  ######           ###    #### ######## ######## ##     ## #### ##    ##

\************************************************************************************************/
const GRAVES_FLY_ANIM = "gr_fracture_flyin" // hero_dropship_sidepose_graves_C

function IntroIMCHeros( dropship, ref, table )
{
	dropship.EndSignal( "OnDeath" )

	local graves 	= CreatePropDynamic( GRAVES_MODEL )
	local blisk 	= CreatePropDynamic( BLISK_MODEL )
	local pilot 	= CreatePropDynamic( TEAM_IMC_GRUNT_MDL )
	local knife 	= CreatePropDynamic( KNIFE_MODEL )
	local platform 	= CreatePropDynamic( DROPSHIP_HERO_PLATFORM, dropship.GetOrigin(), dropship.GetAngles() )
	thread IntroIMCChatter( pilot, graves )

	graves.SetParent( dropship, "ORIGIN" )
	blisk.SetParent( dropship, "ORIGIN" )
	pilot.SetParent( dropship, "ORIGIN" )
	platform.SetParent( dropship, "ORIGIN" )
	knife.SetParent( blisk, "R_HAND_alt" )

	graves.MarkAsNonMovingAttachment()
	blisk.MarkAsNonMovingAttachment()
	pilot.MarkAsNonMovingAttachment()
	platform.MarkAsNonMovingAttachment()
	knife.MarkAsNonMovingAttachment()

	local skyScaleObj = []
	skyScaleObj.append( graves )
	skyScaleObj.append( blisk )
	skyScaleObj.append( pilot )
	skyScaleObj.append( knife )

	dropship.s.graves 	<- graves
	dropship.s.blisk  	<- blisk
	dropship.s.pilot 	<- pilot
	dropship.s.skyScaleObj <- skyScaleObj

	foreach( obj in skyScaleObj )
		obj.LerpSkyScale( SKYSCALE_FRACTURE_IMC_ACTOR, 0.01 )
	platform.LerpSkyScale( SKYSCALE_FRACTURE_IMC_SHIP, 0.01 )

	thread PlayAnimTeleport( graves, "gr_fracture_flyin_start", dropship, "ORIGIN" )
	thread PlayAnimTeleport( blisk, "fracture_MC_flyin_blisk", dropship, "ORIGIN" )
	thread PlayAnimTeleport( pilot, "Militia_flyinA_idle_mac", dropship, "ORIGIN" )
}

function IntroIMCHeros2( dropship, ref, table )
{
	dropship.EndSignal( "OnDeath" )

	local graves 	= dropship.s.graves
	local blisk 	= dropship.s.blisk
	local pilot 	= dropship.s.pilot

	thread IntroIMCVillansDialogue( pilot, graves, blisk )

	thread PlayAnimTeleport( graves, GRAVES_FLY_ANIM, dropship, "ORIGIN" )

	FlagWait( "IMCSeesFleetInvade" )
	local players = GetAttachedPlayers( dropship )
	foreach( player in players )
		Remote.CallFunction_Replay( player, "ServerCallback_IMCSeesFleetInvade" )
}

function IntroIMCChatter( pilot, graves )
{
	pilot.EndSignal( "OnDeath" )
	graves.EndSignal( "OnDeath" )

	wait 1.75
	//In space, fuel is life, and the Militia fleet is running low.
	EmitSoundOnEntity( graves, "diag_matchintro_FR101_01_01_imc_graves" )

}

function IntroIMCVillansDialogue( pilot, graves, blisk )
{
	pilot.EndSignal( "OnDeath" )
	graves.EndSignal( "OnDeath" )
	blisk.EndSignal( "OnDeath" )

	delaythread( 20.5 ) IntroIMCTurretSitRep()

	wait 22
	//Operator: Turret online and operational sir. ( over comms )
	EmitSoundOnEntity( graves, "diag_matchintro_FR101_16_01_imc_pilot" )

	wait 2.0
	//Colonel Graves, Zulu Three shows multiple jump signatures three clicks out.
	EmitSoundOnEntity( pilot, "diag_imc_fltofficer_cmp_frac_countdown_01_2" )
	delaythread( 5.25 ) FlagSet( "IMCSeesFleetInvade" )
}

function IntroIMCTurretSitRep()
{
	local turret = GetEnt( "turret_mega_hpB" )

	turret.EnableTurret()
	turret.ClearBossPlayer()

	wait 4

	turret.DisableTurret()
}


/************************************************************************************************\

######## #### ########    ###    ##    ##       #### ##     ##  ######
   ##     ##     ##      ## ##   ###   ##        ##  ###   ### ##    ##
   ##     ##     ##     ##   ##  ####  ##        ##  #### #### ##
   ##     ##     ##    ##     ## ## ## ##        ##  ## ### ## ##
   ##     ##     ##    ######### ##  ####        ##  ##     ## ##
   ##     ##     ##    ##     ## ##   ###        ##  ##     ## ##    ##
   ##    ####    ##    ##     ## ##    ##       #### ##     ##  ######

\************************************************************************************************/
function IntroIMCCaptain( test = false )
{
	if ( !test )
		FlagWait( "IntroGoIMC" )

	local node 		= GetEnt( "introcaptainIMC" )
	local table 	= CreateDefaultNPCTitanTemplate( TEAM_IMC )
	table.title 	= ""

	table.origin 	= node.GetOrigin() + Vector( 0, 0, 100 )
	table.angles 	= node.GetAngles()

	local titan = SpawnNPCTitan( table )

	if ( !test )
		level.IMCCaptainTitan <- titan

	titan.SetEfficientMode( true )
	DisableRodeo( titan )

	local captain = SpawnGrunt( TEAM_IMC, "", node.GetOrigin(), node.GetAngles() )
	captain.SetModel( TEAM_IMC_CAPTAIN_MDL )
	captain.SetTitle( "#NPC_CAPTAIN_RIGGS" )
	captain.SetShortTitle( "#NPC_CAPTAIN_RIGGS" )
	MakeInvincible( captain )

	thread PlayAnimTeleport( titan, "at_IMC_titan_commander_idle", node )
	thread PlayAnimTeleport( captain, "pt_IMC_titan_commander_idle", titan, "HIJACK" )

	OnThreadEnd(
		function() : ( captain, titan )
		{
			FlagSet( "IMC_IntroDone" )

			if ( IsValid( captain ) )
				captain.Kill()

			if( IsAlive( titan ) )
			{
				titan.SetTitle( "#NPC_CAPTAIN_RIGGS" )
				titan.SetShortTitle( "#NPC_CAPTAIN_RIGGS" )
				titan.SetEfficientMode( false )
				thread IntroCaptainIMCFight( titan )
			}
		}
	)

	titan.EndSignal( "OnDeath" )
	captain.EndSignal( "OnDeath" )

	//time it out
	if ( !test )
	{
		delaythread( 16.5 ) FlagSet( "IMC_captain_anim" )
		wait 24.5
	}
	else
		wait 1

	titan.DisableStarts()

	thread PlayAnim( titan, "at_IMC_titan_commander", node )
	waitthread PlayAnim( captain, "pt_IMC_titan_commander", titan, "HIJACK" )

	if ( !test )
		FlagSet( "IMC_IntroDone" )

	if ( test )
		titan.Kill()
}


/************************************************************************************************\

 ######   ########  ##     ## ##    ## ########       #### ##     ##  ######
##    ##  ##     ## ##     ## ###   ##    ##           ##  ###   ### ##    ##
##        ##     ## ##     ## ####  ##    ##           ##  #### #### ##
##   #### ########  ##     ## ## ## ##    ##           ##  ## ### ## ##
##    ##  ##   ##   ##     ## ##  ####    ##           ##  ##     ## ##
##    ##  ##    ##  ##     ## ##   ###    ##           ##  ##     ## ##    ##
 ######   ##     ##  #######  ##    ##    ##          #### ##     ##  ######

\************************************************************************************************/
function IntroIMCGrunts()
{
	FlagWait( "IntroGoIMC" )

	delaythread( 21 ) IntroIMCGruntsSpawnAndAssault( 2 )

	wait 21

	local numGuys = GetCPULevelWrapper() == CPU_LEVEL_HIGHEND ? 4 : 3
	local squad = Moment_Dropship_DropOffAISide( GetNodeByUniqueID( "cinematic_mp_node_IMCSquad2" ), TEAM_IMC, numGuys )

	ScriptedSquadAssault( squad, 0 )
}

function IntroIMCGruntsSpawnAndAssault( index )
{
	local spawns = GetEntArrayByNameWildCard_Expensive( "introIMCgrunt*" )
	local squad = []
	foreach ( num, node in spawns )
	{
		if ( num > 2 && GetCPULevelWrapper() != CPU_LEVEL_HIGHEND )
			continue

		local guy = Spawn_TrackedGrunt( TEAM_IMC, "", node.GetOrigin(), node.GetAngles() )
		squad.append( guy )
	}

	FlagWait( "IMC_captain_anim" )
	wait 5

	ScriptedSquadAssault( squad, index )
}

function IntroIMCCaptainGruntSquad()
{
	FlagWait( "IntroGoIMC" )

	local nodes = GetEntArrayByNameWildCard_Expensive( "introIMCgrunt*" )
	local squad = []

	foreach ( index, nodeS in nodes )
	{
		if ( index > 2 && GetCPULevelWrapper() != CPU_LEVEL_HIGHEND )
			continue

		local node = GetEnt( nodeS.GetTarget() )
		local guy = Spawn_TrackedGrunt( TEAM_IMC, "", node.GetOrigin() + Vector( 0, 0, 100 ), node.GetAngles() )
		squad.append( guy )

		thread IntroIMCCaptainGrunt( guy, node, index )
	}

	FlagWait( "IMC_captain_anim" )

	wait 2.0

	local index = 1
	ScriptedSquadAssault( squad, index )
}

function IntroIMCCaptainGrunt( guy, node, index )
{
	guy.EndSignal( "OnDeath" )

	local idles = [
		"pt_titan_briefingA_guy1_idle",
		"pt_titan_briefingA_guy2_idle",
		"pt_titan_briefingA_guy3_idle",
		"pt_titan_briefingB_guy2_idle",
	]

	local anims = [
		"pt_titan_briefingA_guy1",
		"pt_titan_briefingA_guy2",
		"pt_titan_briefingA_guy3",
		"pt_titan_briefingB_guy2",
	]

	guy.SetEfficientMode( true )

	thread PlayAnimGravity( guy, idles[ index ], node )

	guy.DisableStarts()

	FlagWait( "IMC_captain_anim" )

	wait 1.0

	waitthread PlayAnimGravity( guy, anims[ index ], node )

	guy.SetEfficientMode( false )

	wait 1.0

	guy.EnableStarts()
}

function Moment_Dropship_DropOffAISide( node, team = TEAM_IMC, numGuys = 4, squadName = "" )
{
	local angles = node.ang
	local origin = node.pos + Vector( 0,0,500 )
	local result = TraceLine( origin, origin + Vector( 0,0,-4000 ), null, TRACE_MASK_NPCWORLDSTATIC, TRACE_COLLISION_GROUP_NONE )
	origin = result.endPos + Vector( 0, 0, 30 ) // give it some height off the ground

	//warpin
	local anim = "cd_dropship_rescue_side_start"
	local model = GetTeamDropshipModel( team )
	waitthread WarpinEffect( model, anim, origin, angles )

	//spawn the dropship and animate it in
	local dropship = SpawnAnimatedDropship( origin, team )
	dropship.s.guys <- 0
	thread DropOffAISide_StartAnimAndIdle( dropship, anim, origin, angles )

	dropship.EndSignal( "OnDeath" )

	//spawn the guys
	local attach = "RESCUE"
	local guys = DropOffAISide_CreateNPCs( dropship, team, attach, numGuys, squadName )

	//wait for them to finish deploying
	while( dropship.s.guys )
		dropship.WaitSignal( "GuysInSkitUpdated" )

	thread DropOffAISide_WarpOutShip( dropship, origin, angles )
	ArrayRemoveDead( guys )

	return guys
}

function DropOffAISide_WarpOutShip( dropship, origin, angles )
{
	local anim = "cd_dropship_rescue_side_end"
	thread PlayAnim( dropship, anim, origin, angles )

	//blend
	wait dropship.GetSequenceDuration( anim ) - 0.2

	dropship.Hide()
	thread WarpoutEffect( dropship )
}

function DropOffAISide_StartAnimAndIdle( dropship, anim, origin, angles )
{
	waitthread PlayAnimTeleport( dropship, anim, origin, angles )

	local anim = "cd_dropship_rescue_side_idle"
	thread PlayAnim( dropship, anim, origin, angles )
}

function DropOffAISide_CreateNPCs( dropship, team, attach, numGuys, squadName )
{
	local origin 	= dropship.GetOrigin()
	local angles 	= dropship.GetAngles()
	local guys 		= []

	for ( local i = 0; i < numGuys; i++ )
	{
		local guy = Spawn_TrackedGrunt( team, squadName, origin, angles )
		dropship.s.guys++
		guys.append( guy )

		thread DropOffAISide_NPCThink( guy, i, dropship, attach )
	}

	return guys
}

function DropOffAISide_NPCThink( guy, index, dropship, attach )
{
	guy.EndSignal( "OnDeath" )

	//init
	guy.SetParent( dropship, attach )
	guy.SetEfficientMode( true )

	//deploy
	local deployAnims = DropOffAISide_GetDeployAnims()
	local seekTimes = DropOffAISide_GetSeekTimes()

	thread PlayAnimTeleport( guy, deployAnims[ index ], dropship, attach )
	guy.Anim_SetInitialTime( seekTimes[ index ] )

	guy.WaittillAnimDone()

	//let the ship know
	if ( IsValid( dropship ) )
	{
		dropship.s.guys--
		dropship.Signal( "GuysInSkitUpdated" )
	}

	guy.SetEfficientMode( false )

	//disperse
	local disperseAnims = DropOffAISide_GetDisperseAnims()
	local origin = HackGetDeltaToRef( guy.GetOrigin(), guy.GetAngles(), guy, disperseAnims[ index ] ) + Vector( 0,0,2 )
	waitthread PlayAnimGravity( guy, disperseAnims[ index ], origin, guy.GetAngles() )

	//cleanup
	if ( level.UsingCinematicNodeEditor )
		guy.Kill( 4 )
}

function DropOffAISide_WaitForDeathOrDone( dropship )
{
	dropship.EndSignal( "OnDeath" )
	dropship.WaitSignal( "GuysInSkitUpdated" )
}

function DropOffAISide_GetIdleAnims()
{
	local anims = [
	"pt_ds_side_intro_gen_idle_A",	//standing right
	"pt_ds_side_intro_gen_idle_B",	//standing left
	"pt_ds_side_intro_gen_idle_C",	//sitting right
	"pt_ds_side_intro_gen_idle_D" ]	//sitting left

	return anims
}

function DropOffAISide_GetDeployAnims()
{
	local anims = [
	"pt_generic_side_jumpLand_A",	//standing right
	"pt_generic_side_jumpLand_B",	//standing left
	"pt_generic_side_jumpLand_C",	//sitting right
	"pt_generic_side_jumpLand_D" ]	//sitting left

	return anims
}
function DropOffAISide_GetDisperseAnims()
{
	local anims = [
	"React_signal_thatway",	//standing right
	"React_spot_radio2",	//standing left
	"stand_2_run_45R",		//sitting right
	"stand_2_run_45L" ]		//sitting left

	return anims
}

function DropOffAISide_GetSeekTimes()
{
	local anims = [
	9.75,	//standing right
	10.0,	//standing left
	10.5,	//sitting right
	11.25 ]	//sitting left

	return anims
}

/************************************************************************************************\

######## #### ########    ###    ##    ##       ######## ####  ######   ##     ## ########
   ##     ##     ##      ## ##   ###   ##       ##        ##  ##    ##  ##     ##    ##
   ##     ##     ##     ##   ##  ####  ##       ##        ##  ##        ##     ##    ##
   ##     ##     ##    ##     ## ## ## ##       ######    ##  ##   #### #########    ##
   ##     ##     ##    ######### ##  ####       ##        ##  ##    ##  ##     ##    ##
   ##     ##     ##    ##     ## ##   ###       ##        ##  ##    ##  ##     ##    ##
   ##    ####    ##    ##     ## ##    ##       ##       ####  ######   ##     ##    ##

\************************************************************************************************/

function IntroCaptainMCORFight( titan )
{
	titan.EndSignal( "OnDeath" )

	OnThreadEnd(
		function() : ()
		{
			FlagSet( "MCORCaptainReadyToFight" )
		}
	)

	EnableRodeo( titan )

	titan.DisableArrivalOnce( true )
	waitthread GotoOrigin( titan, Vector( 3287, 3400, 29 ), 65 )

	local node = GetEnt( "IntroMCORCaptainStep1" )
	waitthread RunToAnimStartForced( titan, "at_dash_F", node )

	titan.EnableStarts()

	if ( titan.ContextAction_IsMeleeExecution() )
		return
	waitthread PlayAnim( titan, "at_dash_F", node )

	FlagSet( "MCORCaptainReadyToFight" )

	if ( IsAlive( level.IMCCaptainTitan ) )
		titan.SetEnemy( level.IMCCaptainTitan )

	local node = GetEnt( "IntroCaptainDeath" )
	waitthread RunToAnimStartForced( titan, "at_car_shield", node )

	DisableHealthRegen( titan )

	local newAngles = node.GetAngles()
	local newOrigin = HackGetDeltaToRef( titan.GetOrigin(), newAngles, titan, "at_dash_F" )

	if ( titan.ContextAction_IsMeleeExecution() )
		return
	waitthread PlayAnim( titan, "at_dash_F", newOrigin, newAngles )
}

function IntroCaptainIMCFight( titan )
{
	titan.EndSignal( "OnDeath" )

	OnThreadEnd(
		function() : ()
		{
			FlagSet( "IMCCaptainReadyToFight" )
		}
	)

	EnableRodeo( titan )

	local node = GetEnt( "IntroIMCCaptainStep1" )
	node.SetOrigin( Vector( 1795, -1643, 190 ) )
	node.SetAngles( Vector( 0,90,0 ) )

	titan.DisableArrivalOnce( true )
	waitthread GotoOrigin( titan, node.GetOrigin() )

	local newAngles = node.GetAngles()
	local newOrigin = HackGetDeltaToRef( titan.GetOrigin(), newAngles, titan, "at_dash_F" )

	if ( titan.ContextAction_IsMeleeExecution() )
		return
	waitthread PlayAnim( titan, "at_dash_F", newOrigin, newAngles )



	wait 1
	titan.EnableStarts()
/*	wait 4

	local seconds = 2
	local interval = 0.5
	while( seconds > 0 )
	{
		titan.SetMoveAnim( "sprint" )
		seconds -= interval
		wait interval
	}

	titan.SetMoveAnim( "Run_mp_forward" )
*/
	if ( IsAlive( level.MCORCaptainTitan ) )
		titan.SetEnemy( level.MCORCaptainTitan )

	DisableHealthRegen( titan )
}


/************************************************************************************************\

#### ##     ##  ######        ######## ##     ## ######## ########     ###
 ##  ###   ### ##    ##       ##        ##   ##     ##    ##     ##   ## ##
 ##  #### #### ##             ##         ## ##      ##    ##     ##  ##   ##
 ##  ## ### ## ##             ######      ###       ##    ########  ##     ##
 ##  ##     ## ##             ##         ## ##      ##    ##   ##   #########
 ##  ##     ## ##    ##       ##        ##   ##     ##    ##    ##  ##     ##
#### ##     ##  ######        ######## ##     ##    ##    ##     ## ##     ##

\************************************************************************************************/
function IntroIMCFlyers()
{
	if ( Flag( "IntroGoIMC" ) )
		return

	local ents = []

	local ship 		= SpawnIntroIMCDS( Vector( 3916, -3700, 100 ), Vector( 10,-10,0 ), "gd_fracture_flyin_imc_R_intro", 0 )
	ents.append( ship )

	local ship 		= SpawnIntroIMCDS( Vector( 2800, 2000, -200 ), Vector( -5,10,0 ), "gd_fracture_flyin_imc_L_intro", 0 )
	ents.append( ship )

	thread SpawnIntroIMCST( Vector( 8000, 2000, 700 ), Vector( 45,-70,0 ), 4 )
	thread SpawnIntroIMCST2( Vector( 3200, -4000, 600 ), Vector( 0,225,0 ), 0.5 )

	FlagWait( "IntroGoIMC" )
	wait 6.25
	foreach( ship in ents )
	{
		if ( IsValid( ship ) )
			ship.Kill()
	}
}

function SpawnIntroIMCST( origin, angles, delay = 0 )
{
	local ship 		= SpawnAnimatedGunship( origin + Vector( 0,0, 300 ), TEAM_IMC )
	ship.kv.VisibilityFlags = 2 //Only friendlies can see this
	ship.SetEfficientMode( true )
	HideName( ship )

	OnThreadEnd(
		function() : ( ship )
		{
			if ( IsValid( ship ) )
				ship.Kill()
		}
	)

	ship.EndSignal( "OnDeath" )
	FlagEnd( "IntroGoIMC" )

	wait delay

	if ( IsValid_ThisFrame( ship ) )
		waitthread PlayAnim( ship, "st_straton_flyby_top_B", origin, angles )
}

function SpawnIntroIMCST2( origin, angles, delay = 0 )
{
	local ship 		= SpawnAnimatedGunship( origin + Vector( 0,0, 300 ), TEAM_IMC )
	ship.kv.VisibilityFlags = 2 //Only friendlies can see this
	ship.SetEfficientMode( true )
	HideName( ship )

	OnThreadEnd(
		function() : ( ship )
		{
			if ( IsValid( ship ) )
				ship.Kill()
		}
	)

	ship.EndSignal( "OnDeath" )
	FlagEnd( "IntroGoIMC" )

	wait delay

	if ( IsValid_ThisFrame( ship ) )
	{
		waitthread PlayAnim( ship, "test_land", origin, angles )
		thread PlayAnim( ship, "test_runway_idle", origin, angles )
		wait 3
		ship.Kill()
	}
}

function SpawnIntroIMCDS( origin, angles, anim, delay = 0 )
{
	local ship 		= SpawnAnimatedDropship( origin + Vector( 0,0, 300 ), TEAM_IMC )
	ship.kv.VisibilityFlags = 2 //Only friendlies can see this
	ship.SetEfficientMode( true )
	HideName( ship )

	delaythread ( delay ) AnimIntroIMCFlyers( ship, anim, origin, angles )

	return ship
}

function AnimIntroIMCFlyers( ship, anim, origin, angles )
{
	if ( IsValid_ThisFrame( ship ) )
		PlayAnim( ship, anim, origin, angles )
}

function IntroIMCExtras()
{
	FlagWait( "IMC_idleover" )

	//wave and talkers on turret roof
	delaythread( 0 ) DoPropSkit( GetNodeByUniqueID( "cinematic_mp_node_roofTalkersC1" ), true )
	delaythread( 4 ) DoPropSkit( GetNodeByUniqueID( "cinematic_mp_node_roofTalkersC2" ), true )

	//the guy on the first turret
	delaythread( 3 ) DoPropSkit( GetNodeByUniqueID( "cinematic_mp_node_look01" ), true )

	//the two guys walking under roof of first turret
	delaythread( 8 ) DoPropSkit( GetNodeByUniqueID( "cinematic_mp_node_patrol1" ), true )
	delaythread( 8 ) DoPropSkit( GetNodeByUniqueID( "cinematic_mp_node_patrol2" ), true )

	//3 guys walking under roof of first turret
	delaythread( 6 ) DoPropSkit( GetNodeByUniqueID( "cinematic_mp_node_turretRoofWalk1" ), true )
	delaythread( 6 ) DoPropSkit( GetNodeByUniqueID( "cinematic_mp_node_turretRoofWalk2" ), true )
	delaythread( 6 ) DoPropSkit( GetNodeByUniqueID( "cinematic_mp_node_turretRoofWalk3" ), true )

	//the 3 guys walking on the garden roof
	delaythread( 5 ) DoPropSkit( GetNodeByUniqueID( "cinematic_mp_node_patrolB1" ), true )
	delaythread( 5 ) DoPropSkit( GetNodeByUniqueID( "cinematic_mp_node_patrolB2" ), true )
	delaythread( 5 ) DoPropSkit( GetNodeByUniqueID( "cinematic_mp_node_patrolB3" ), true )

	//the 5 talkers on garden roof
	delaythread( 4 ) DoPropSkit( GetNodeByUniqueID( "cinematic_mp_node_gardenTalkers1" ), true )
	delaythread( 5 ) DoPropSkit( GetNodeByUniqueID( "cinematic_mp_node_gardenTalkers2" ), true )//walker
	delaythread( 5 ) DoPropSkit( GetNodeByUniqueID( "cinematic_mp_node_gardenTalkers3" ), true )

	//the guy at the turret waving to the player
	delaythread( 14.5 ) DoPropSkit( GetNodeByUniqueID( "cinematic_mp_node_salute01" ), true )

	//walking and 2 talkers on 2nd turret
	delaythread( 5 ) DoPropSkit( GetNodeByUniqueID( "cinematic_mp_node_roofTalkersB1" ), true )
	delaythread( 9 ) DoPropSkit( GetNodeByUniqueID( "cinematic_mp_node_roofTalkersB2" ), true )//walker

	//2 talkers on back house
	delaythread( 5 ) DoPropSkit( GetNodeByUniqueID( "cinematic_mp_node_roofTalkersA1" ), true )

	//goblin in the middle
	delaythread( 6 ) Moment_Dropship_Dropoff_NoAI( GetNodeByUniqueID( "cinematic_mp_node_imcgoblin1" ), "Fracture_Scr_IMCIntro_BackgroundGoblin1" )

	//goblin takeoff
	delaythread( 0 ) Moment_Dropship_Takeoff( GetNodeByUniqueID( "cinematic_mp_node_goblintakeoff" ) )

	//goblin takeoff
	delaythread( 7 ) Moment_Dropship_Takeoff( GetNodeByUniqueID( "cinematic_mp_node_goblintakeoff2" ), DROPSHIP_MODEL, "Fracture_Scr_IMCIntro_BackgroundGoblin2" )

	//roof searchers
	delaythread( 5 ) DoPropSkitSearchHole( GetNodeByUniqueID( "cinematic_mp_node_searchHoleA" ), true, 6 )

	//roof searchers
	delaythread( 0.0 ) DoPropSkitSearchHole( GetNodeByUniqueID( "cinematic_mp_node_searchHoleB1" ), true, 3 )
	delaythread( 2.0 ) DoPropSkitSearchHole( GetNodeByUniqueID( "cinematic_mp_node_searchHoleB2" ), true, 3 )
	delaythread( 0.5 ) DoPropSkitSearchHole( GetNodeByUniqueID( "cinematic_mp_node_searchHoleB3" ), true, 3 )

	//titan walking down the street
	local table 	= CreateDefaultNPCTitanTemplate( TEAM_IMC )
	table.title 	= ""
	table.origin 	= Vector( 1639, 1832, 136 )
	table.angles 	= Vector( 0, -90, 0 )
	local titan = SpawnNPCTitan( table )

	local destination = Vector( 1763, -2639, 149 )

	HideName( titan )
	titan.SetEfficientMode( true )
	titan.SetMoveAnim( "at_search_walk_slow" )
	delaythread( 5 ) GotoOrigin( titan, destination )

	FlagWait( "MilitiaWarped" )
	wait 7
	titan.Kill()
}


/************************************************************************************************\

 ######  ########     ###     ######  ########       #### ##    ## ######## ########   #######
##    ## ##     ##   ## ##   ##    ## ##              ##  ###   ##    ##    ##     ## ##     ##
##       ##     ##  ##   ##  ##       ##              ##  ####  ##    ##    ##     ## ##     ##
 ######  ########  ##     ## ##       ######          ##  ## ## ##    ##    ########  ##     ##
      ## ##        ######### ##       ##              ##  ##  ####    ##    ##   ##   ##     ##
##    ## ##        ##     ## ##    ## ##              ##  ##   ###    ##    ##    ##  ##     ##
 ######  ##        ##     ##  ######  ########       #### ##    ##    ##    ##     ##  #######

\************************************************************************************************/
function InitSpaceArmada()
{
	local armada = GetEntArrayByNameWildCard_Expensive( "intro_space_armada*" )

	level.armadaInfo <- []
	foreach( ship in armada )
	{
		local table 	= {}
		table.origin 	<- ship.GetOrigin()
		table.angles 	<- ship.GetAngles()
		table.model 	<- ship.GetModelName()
		level.armadaInfo.append( table )
	}
}

function IntroSpaceScene()
{
	FlagWait( "spaceSceneStart" )

	local armada = GetEntArrayByNameWildCard_Expensive( "intro_space_armada*" )

	local ref = GetEnt( "intro_MCOR_spacenode" )
	local refb = CreateScriptRef( ref.GetOrigin() + Vector( 0,0,-100 ), ref.GetAngles() + Vector(-15,0,0 ) )
	local ref1 = GetEnt( "intro_crow1_spacenode" )
	local ref2 = GetEnt( "intro_crow1_spacenode1" )
	local ref3 = GetEnt( "intro_crow1_spacenode2" )
	local ref4 = GetEnt( "intro_crow1_spacenode3" )
	local ref5 = GetEnt( "intro_crow1_spacenode4" )
	local ref6 = GetEnt( "intro_crow1_spacenode5" )

	local ships = {}
	ships.close1 	<- CreatePropDynamic( REDEYE_MODEL )
	ships.close2 	<- CreatePropDynamic( CAPSHIP_ANNA_MODEL )
	ships.redeye 	<- CreatePropDynamic( REDEYE_MODEL )
	ships.birm 		<- CreatePropDynamic( CAPSHIP_BIRM_MODEL )
	ships.crow1 	<- CreatePropDynamic( CROW_MODEL )
	ships.crow2 	<- CreatePropDynamic( CROW_MODEL )
	ships.crow3 	<- CreatePropDynamic( CROW_MODEL )
	ships.crow4 	<- CreatePropDynamic( CROW_MODEL )
	ships.crow5 	<- CreatePropDynamic( CROW_MODEL )
	ships.crow6 	<- CreatePropDynamic( CROW_MODEL )

	MoveArmada( armada )

	thread PlayAnimTeleport( ships.close1, "re_space_flyby_redeyeB", ref )
	thread PlayAnimTeleport( ships.close2, "cb_space_flyby_anna", refb )
	thread PlayAnimTeleport( ships.redeye, "re_space_flyby_redeye", ref )
	thread PlayAnimTeleport( ships.birm, "cb_space_flyby_birm", ref )

	thread DelayPlayAnimTeleport( 0.2, ships.crow1, "ds_space_flyby_dropshipB", ref1 )
	thread DelayPlayAnimTeleport( 0.3, ships.crow2, "ds_space_flyby_dropshipB", ref2 )
	thread DelayPlayAnimTeleport( 0.5, ships.crow3, "ds_space_flyby_dropshipB", ref3 )

	thread DelayPlayAnimTeleport( 0.2, ships.crow4, "ds_space_flyby_dropshipB", ref4 )
	thread DelayPlayAnimTeleport( 0.3, ships.crow5, "ds_space_flyby_dropshipB", ref5 )
	thread DelayPlayAnimTeleport( 0.5, ships.crow6, "ds_space_flyby_dropshipB", ref6 )

	OnThreadEnd(
		function() : ( ships, armada )
		{
			foreach ( ship in ships )
			{
				if ( IsValid( ship ) )
					ship.Kill()
			}

			foreach ( ship in armada )
			{
				if ( IsValid( ship ) )
					ship.Kill()
			}
		}
	)

	FlagEnd( "MilitiaWarped" )

	FlagWait( "TransitionEvent" )

	delaythread( 3.0 ) 	WarpoutEffect( ships.crow1 )
	delaythread( 3.5 ) 	WarpoutEffect( ships.crow2 )
	delaythread( 3.75 ) WarpoutEffect( ships.crow3 )
	delaythread( 3.25 ) WarpoutEffect( ships.crow4 )
	delaythread( 3.5 ) 	WarpoutEffect( ships.crow5 )
	delaythread( 4.0 ) 	WarpoutEffect( ships.crow6 )

	foreach( ship in armada )
	{
		switch( ship.GetModelName() )
		{
			case "models/vehicle/crow_dropship/crow_dropship_space.mdl":
			case "models/vehicle/space_cluster/crow_space_clustera.mdl":
			case "models/vehicle/space_cluster/crow_space_clusterb.mdl":
				delaythread( RandomFloat( 1.0, 3.5 ) ) WarpoutEffectSpace( ship, FX_DROPSHIP_WARPOUT_SPACE )
				break
		}
	}

	FlagWait( "MilitiaWarped" )
}

function WarpoutEffectSpace( ship, fx )
{
	if ( !IsValid_ThisFrame )
		return

	PlayFX( fx, ship.GetOrigin(), ship.GetAngles() )

	switch( ship.GetModelName() )
	{
		case "models/vehicle/crow_dropship/crow_dropship_space.mdl":
			ship.Kill()
			break
	}
}

function DelayPlayAnimTeleport( delay, ent, anim, ref )
{
	ent.EndSignal( "OnDeath" )
	ref.EndSignal( "OnDeath" )

	wait delay

	if ( IsValid_ThisFrame( ent ) )
		PlayAnimTeleport( ent, anim, ref )
}

function MoveArmada( armada )
{
	foreach( ship in armada )
	{
		switch( ship.GetModelName() )
		{
			case "models/vehicle/capital_ship_annapolis/annapolis_space.mdl":
				ship.MoveTo( ship.GetOrigin() + ship.GetForwardVector() * 300, 90.0 )
				break

			case "models/vehicle/capital_ship_Birmingham/birmingham_space.mdl":
			case "models/vehicle/space_cluster/birmingham_space_clustera.mdl":
				ship.MoveTo( ship.GetOrigin() + ship.GetForwardVector() * ( 400 + RandomFloat( -50,50 ) ), 90.0 )
				break

			case "models/vehicle/redeye/redeye2_space.mdl":
			case "models/vehicle/space_cluster/redeye_space_clustera.mdl":
			case "models/vehicle/space_cluster/redeye_space_clusterb.mdl":
			case "models/vehicle/space_cluster/redeye_space_clusterc.mdl":
				ship.MoveTo( ship.GetOrigin() + ship.GetForwardVector() * ( 500 + RandomFloat( -50,50 ) ), 90.0 )
				break

			case "models/vehicle/crow_dropship/crow_dropship_space.mdl":
			case "models/vehicle/space_cluster/crow_space_clustera.mdl":
			case "models/vehicle/space_cluster/crow_space_clusterb.mdl":
				ship.MoveTo( ship.GetOrigin() + ship.GetForwardVector() * ( 600 + RandomFloat( -50,50 ) ), 90.0 )
				break
		}
	}
}





/************************************************************************************************\

######## ##    ## ########        ########   #######  ##     ## ##    ## ########
##       ###   ## ##     ##       ##     ## ##     ## ##     ## ###   ## ##     ##
##       ####  ## ##     ##       ##     ## ##     ## ##     ## ####  ## ##     ##
######   ## ## ## ##     ##       ########  ##     ## ##     ## ## ## ## ##     ##
##       ##  #### ##     ##       ##   ##   ##     ## ##     ## ##  #### ##     ##
##       ##   ### ##     ##       ##    ##  ##     ## ##     ## ##   ### ##     ##
######## ##    ## ########        ##     ##  #######   #######  ##    ## ########

\************************************************************************************************/
function EndRoundMain()
{
	//RemoveCustomPlayerCinematicFunc( IMCPlayerSkyScale, TEAM_IMC )

	local winningTeam = GetTeamIndex(GetWinningTeam())

	if ( EvacEnabled() )
	{
		GM_SetObserverFunc( ObserverFunc )

		if ( winningTeam == TEAM_IMC )
			thread OutroSpaceArmada()
	}

	if ( GetCinematicMode() && GAMETYPE == CAPTURE_POINT )
		delaythread( 28 ) ForcePlayConversationToAll( "fracture_storyEnd" )

	// TODO: needs to handle draw better
	if ( winningTeam == TEAM_IMC )
		thread EndRoundIMCWin()
	else
		thread EndRoundMCORWin()
}

function EndRoundIMCWin()
{
	// Refuel ship blows up
	thread BigRefuelShip_Ending_Explode()
}

function EndRoundMCORWin()
{
	// Refuel ship flies away and warps out
	thread BigRefuelShip_Ending_FlyAway()
}

function ObserverFunc( player )
{
	//if ( GetBugReproNum() != 2013 )
	//	return

	player.SetObserverModeStaticPosition( level.ExtractLocations[ level.SelectedExtractLocationIndex ].spectatorPos )
	player.SetObserverModeStaticAngles( level.ExtractLocations[ level.SelectedExtractLocationIndex ].spectatorAng )

	player.StartObserverMode( OBS_MODE_CHASE )
	player.SetObserverTarget( null )

	//player.SetOrigin( level.ExtractLocations[ level.SelectedExtractLocationIndex ].spectatorPos )
	//player.SetAngles( level.ExtractLocations[ level.SelectedExtractLocationIndex ].spectatorAng )
}

function OutroSpaceArmada()
{
	//cleanup ( mostly for testing purposes )
	local oldArmada = GetEntArrayByNameWildCard_Expensive( "intro_space_armada*" )
	if ( oldArmada.len() )
	{
		foreach ( ship in oldArmada )
		{
			if ( IsValid( ship ) )
				ship.Kill()
		}
	}

	local armada = []

	foreach( table in level.armadaInfo )
	{
		table.angles = table.angles.AnglesCompose( Vector( 0,180,0 ) )
		local ship = CreatePropDynamic( table.model, table.origin, table.angles )
		armada.append( ship )

		wait 0.1//add a delay so you dont make 25 dynamic objects in 1 frame
	}

	FlagWait( "EvacShipLeave" )

	MoveArmada( armada )
}


/************************************************************************************************\

######## ##     ## ##     ## ##     ## ########  ######## ########
   ##    ##     ## ##     ## ###   ### ##     ## ##       ##     ##
   ##    ##     ## ##     ## #### #### ##     ## ##       ##     ##
   ##    ######### ##     ## ## ### ## ########  ######   ########
   ##    ##     ## ##     ## ##     ## ##        ##       ##   ##
   ##    ##     ## ##     ## ##     ## ##        ##       ##    ##
   ##    ##     ##  #######  ##     ## ##        ######## ##     ##

\************************************************************************************************/
function StaggerThumperAnim( thumper )
{
	wait ( RandomFloat( 0.5, 3 ) )
	PlayAnim( thumper, "strike", thumper )//thumper.Anim_NonScriptedPlay( "strike" )
}

function ThumperGeneratorAnim( generator )
{
		PlayAnim( generator, "idle_spinning", generator )//generator.Anim_NonScriptedPlay( "idle_spinning" )
}

function RadarAnim( radar )
{
		PlayAnim( radar, "idle_spinning", radar )//generator.Anim_NonScriptedPlay( "idle_spinning" )
}

function TreeAnim( tree )
{
		PlayAnim( tree, "windy", tree )
}

function SkyboxLandPlateAnim( skyboxPlate )
{
	wait ( 20 )
		PlayAnim( skyboxPlate, "strike", skyboxPlate )//skyboxPlate.Anim_NonScriptedPlay( "test" )
}

function SkyboxLandPlateAnim_loop( skyboxPlate )
{
		PlayAnim( skyboxPlate, "post_strike", skyboxPlate )//skyboxPlate.Anim_NonScriptedPlay( "test" )
}

function SkyboxThumperAnim( skyboxThumper )
{
	wait ( 20 )
		PlayAnim( skyboxThumper, "strike", skyboxThumper )//skyboxPlate.Anim_NonScriptedPlay( "test" )
}

function SkyboxThumperAnim_loop( skyboxThumper )
{
		PlayAnim( skyboxThumper, "post_strike", skyboxThumper )//skyboxPlate.Anim_NonScriptedPlay( "test" )
}


function SkyboxThumperSounds( skyboxThumper )
{
	for ( ;; )
	{
		skyboxThumper.WaitSignal( "megathumper_impact" )

		EmitSoundAtPosition( Vector(16382, 2816, 156), "megathumper_impact" )

		wait 1.6
		EmitSoundAtPosition( Vector(16382, 2816, 156), "megathumper_earthquake" )
	}
}

function DebugAssaultEnt( guy, assaultEnt )
{
	guy.EndSignal( "OnDeath" )

	while( IsValid( assaultEnt ) )
	{
		DebugDrawLine( guy.GetOrigin(), assaultEnt.GetOrigin(), 120, RandomInt( 150, 255 ), 120, true, 0.1 )
		DebugDrawCircle( assaultEnt.GetOrigin(), Vector( 0,0,0 ), 45, 120, 255, 120, 0.1 )
		wait 0.1
	}
}

function FractureSpecificChatter( npc ) //level script files are includeScripted, so no need to globalize
{
	Assert( GetMapName() == "mp_fracture" )
	// Just comment about the enemy for now. When we get code functionality
	// that can tell is if we are indoors, can see ships etc plug in accordingly
	//printt("Doing fracture specific chatter")
	PlaySquadConversationToTeam( "fracture_grunt_chatter", npc.GetTeam(), npc, AI_FRIENDLY_CHATTER_RANGE_SQR )
	return true //return false if we should not be doing chatter so we can fall through and do other chatter if needed
}

main()
