const FX_SPACE_NUKE_EXPLOSION = "P_exp_ship_nuke_space"
const FX_O2_AIRBURST = "p_exp_redeye_med"
const FX_DROPPOD_STEAM = "env_steam_shoot_burst_LG"
const FX_DROPPOD_REENTRY = "P_droppod_reentry"
const FX_DROPPOD_REENTRY2 = "P_droppod_reentry2"
const FX_DROPPOD_LAUNCH = "P_droppod_launch"

const FX_ATMOS_OK = "P_atmos_full"
const FX_ATMOS_BURN = "P_atmos_burn"

const SFX_REFINERY_RUMBLE 				= "o2_refinery_deep_rumble"
const SFX_CANNON_PREFIRE_KLAXON_LOOP	= "o2_klaxon_alarm_loop"

const CAPSHIP_BIRM_MODEL_LG = "models/vehicle/capital_ship_birmingham/birmingham_fleetScale.mdl"

const PILOT_MODEL = "models/humans/mcor_grunt/battle_rifle/mcor_grunt_battle_rifle.mdl"
const BIRMINGHAM_MODEL = "models/vehicle/capital_ship_birmingham/birmingham.mdl"
const ANNAPOLIS_MODEL = "models/vehicle/capital_ship_annapolis/annapolis.mdl"
const REDEYE_MODEL = "models/vehicle/redeye/redeye2.mdl"

const O2_GATE_MODEL = "models/door/imc_gate_large.mdl"

const SPECIAL_MONITOR_01_BLUE   = "models/holo_screens/monitor_screen_O2_medium_01.mdl"
const SPECIAL_MONITOR_01_ORANGE = "models/holo_screens/monitor_screen_O2_medium_01_orange.mdl"
const SPECIAL_MONITOR_02_BLUE   = "models/holo_screens/monitor_screen_O2_medium_02.mdl"
const SPECIAL_MONITOR_02_ORANGE = "models/holo_screens/monitor_screen_O2_medium_02_orange.mdl"

const FX_BLOOD_SQUIB = "death_pinkmist_trails"
const MACGUN = "models/weapons/m1a1_hemlok/w_hemlok.mdl"
const BLISKGUN = "models/weapons/car101/w_car101.mdl"
const O2FUELROD = "models/levels_terrain/mp_o2/mp_o2_fuel_rod.mdl"
const DOORIMC64_MODEL = "models/door/door_imc_interior_split_64_animated.mdl"
const OPAQUE_PIECE = "models/domestic/floor_mat_black_01.mdl"
const KNIFE_MODEL = "models/weapons/combat_knife/w_combat_knife.mdl"
const DP_DOOR_MODEL = "models/vehicle/droppod_fireteam/droppod_fireteam_door.mdl"
const DROPPODO2MODEL = "models/vehicle/droppod_fireteam/droppod_o2.mdl"
const INTROCUSTOMLENGTH_O2 = 52
const O2_POST_EPILOGUE_DURATION = 21

function main()
{
	if ( reloadingScripts )
		return
	IncludeFile( "mp_o2_shared" )
	IncludeFile( "mp/mp_o2_skyshow" )

	FlagInit( "O2_Match15Percent" )
	FlagInit( "O2_Match25Percent" )
	FlagInit( "O2_Match40Percent" )
	FlagInit( "O2_Match45Percent" )
	FlagInit( "O2_Match60Percent" )
	FlagInit( "O2_Match80Percent" )
	FlagInit( "O2_Match90Percent" )
	FlagInit( "O2_Match98Percent" )
	FlagInit( "CoreDestabalized" )

	if ( GetCinematicMode() )
	{
		SetCustomIntroLength( INTROCUSTOMLENGTH_O2 )
		FlagSet( "CinematicIntro" )
		RegisterServerVarChangeCallback( "gameState", O2GameStateChangedServer )
	}

	IncludeFile( "mp/mp_o2_introIMC" )
	IncludeFile( "mp/mp_o2_introMCOR" )

	RegisterSignal( "NewFollowTarget" )
	RegisterSignal( "dialogue" )

	PrecacheModel( GRAVES_MODEL )
	PrecacheModel( SPYGLASS_MODEL )
	PrecacheModel( BISH_MODEL )
	PrecacheModel( BLISK_MODEL )
	PrecacheModel( MAC_MODEL )
	PrecacheModel( SARAH_MODEL )
	PrecacheModel( PILOT_MODEL )
	PrecacheModel( MACGUN )
	PrecacheModel( BLISKGUN )
	PrecacheModel( O2FUELROD )
	PrecacheModel( DOORIMC64_MODEL )
	PrecacheModel( OPAQUE_PIECE )
	PrecacheModel( KNIFE_MODEL )
	PrecacheModel( DP_DOOR_MODEL )
	PrecacheModel( DROPPODO2MODEL )

	PrecacheModel( CAPSHIP_BIRM_MODEL_LG )
	PrecacheModel( BIRMINGHAM_MODEL )
	PrecacheModel( ANNAPOLIS_MODEL )
	PrecacheModel( REDEYE_MODEL )
	PrecacheModel( BOMBER_MODEL )

	PrecacheModel( O2_GATE_MODEL )

	PrecacheModel( TEAM_MILITIA_DRONE_MDL )
	PrecacheModel( TEAM_MILITIA_ROCKET_DRONE_MDL )

	PrecacheModel( SPECIAL_MONITOR_01_BLUE )
	PrecacheModel( SPECIAL_MONITOR_01_ORANGE )
	PrecacheModel( SPECIAL_MONITOR_02_BLUE )
	PrecacheModel( SPECIAL_MONITOR_02_ORANGE )

	PrecacheParticleSystem( FX_O2_AIRBURST )
	PrecacheParticleSystem( FX_DROPPOD_STEAM )
	PrecacheParticleSystem( FX_DROPPOD_REENTRY )
	PrecacheParticleSystem( FX_DROPPOD_REENTRY2 )
	PrecacheParticleSystem( FX_DROPPOD_LAUNCH )
	PrecacheParticleSystem( FX_SPACE_NUKE_EXPLOSION )
	PrecacheParticleSystem( FX_BLOOD_SQUIB )
	PrecacheParticleSystem( FX_ATMOS_OK )
	PrecacheParticleSystem( FX_ATMOS_BURN )

	PrecacheWeapon( "mp_weapon_mega_turret_aa" )

	level.IntroRefs 				<- {}
	level.IntroRefs[ TEAM_IMC ] 	<- []
	level.IntroRefs[ TEAM_MILITIA ] <- []
	level.progressDialogPlayed 		<- {}
	level.atmosOKFX 				<- null
	level.atmosBurnFX 				<- null

	MatchProgressSetup()

	AddClientCommandCallback( "CoreDestabalizedOnServer", ClientCallback_CoreDestabalized )

	if ( !GetCinematicMode() )
		return

	if ( GameRules.GetGameMode() != CAPTURE_POINT )
		return

	level.levelSpecificChatterFunc = O2SpecificChatter

	SetGameWonAnnouncement( "O2WonAnnouncement" )
	SetGameLostAnnouncement( "O2LostAnnouncement" )
	SetGameModeAnnouncement( "O2GameModeAnnounce_CP" )
}

function ClientCallback_CoreDestabalized( player )
{
	if ( Flag( "CoreDestabalized" ) )
		return

	FlagSet( "CoreDestabalized" )
	UpdateReactorFX()
}

function EntitiesDidLoad()
{
	if ( !IsServer() )
		return

	GM_AddEndRoundFunc( EndRoundMain )

	if ( GetCinematicMode() )
	{
		KillSpawns( "startSpawnMCOR_classic", true )
		local gate = GetEnt( "gatesmashmodelclassic" )
		gate.Kill()

		FlagSet( "Disable_Marvins" )
		thread IntroO2Main()
	}
	else
	{
		KillSpawns( "startSpawnMCOR_campaign" )
		if ( EvacEnabled() )
			EvacSetup()
	}

	DisableTurretsFromMinimap()

	FlagWait( "ReadyToStartMatch" )
	if ( GameRules.GetGameMode() == CAPTURE_POINT )
	{
		thread SetupFX()
		thread SetupO2Hardpoints()
		thread KlaxonSetup()
		thread EpilogueFXThink()
		SetMaxMarvinJobDistance(1300)

		if( GetCinematicMode() )
			thread PlayFinalWarningMessages()
	}

	thread O2_SkyShowMain()
	thread MatchProgressMilestones()
}

function IntroO2Main()
{
	O2_IntroIMCMain()
	O2_IntroMCORMain()

	FlagWait( "ReadyToStartMatch" )

	SetGlobalForcedDialogueOnly( true )
	FlagSet( "Disable_IMC" )//no random ai spawning
	FlagSet( "Disable_MILITIA" )//no random ai spawning

	FlagWait( "IMC_IntroDone" )
	FlagWait( "MILITIA_IntroDone" )
	FlagClear( "Disable_Marvins" )
	FlagClear( "Disable_IMC" )
	FlagClear( "Disable_MILITIA" )

	SetGlobalForcedDialogueOnly( false )
	FlagSet( "IntroDone" )
	level.nv.introDone = true
}


/************************************************************************************************\

######## ##     ##    ###     ######         ##        ######## ##    ## ########     ########   #######  ##     ## ##    ## ########
##       ##     ##   ## ##   ##    ##       ####       ##       ###   ## ##     ##    ##     ## ##     ## ##     ## ###   ## ##     ##
##       ##     ##  ##   ##  ##              ##        ##       ####  ## ##     ##    ##     ## ##     ## ##     ## ####  ## ##     ##
######   ##     ## ##     ## ##                        ######   ## ## ## ##     ##    ########  ##     ## ##     ## ## ## ## ##     ##
##        ##   ##  ######### ##              ##        ##       ##  #### ##     ##    ##   ##   ##     ## ##     ## ##  #### ##     ##
##         ## ##   ##     ## ##    ##       ####       ##       ##   ### ##     ##    ##    ##  ##     ## ##     ## ##   ### ##     ##
########    ###    ##     ##  ######         ##        ######## ##    ## ########     ##     ##  #######   #######  ##    ## ########

\************************************************************************************************/
function EndRoundMain()
{
	thread CustomEpilogue()
}

function PlayFinalWarningMessages()
{
	if( Flag( "O2_Match98Percent" ) )
		return
	FlagWait( "O2_Match98Percent" )

	local winningTeam = TEAM_MILITIA  // Always play Militia overload warning
	local sirenRefs = GetEntArrayByName_Expensive( "ref_siren" )
	local randomIndex = RandomInt( 0, level.dialogAliases[ winningTeam ]["warning_match_over"].len() )
	local warningAlias = level.dialogAliases[ winningTeam ]["warning_match_over"][ randomIndex ]

	SetGlobalForcedDialogueOnly( true )

	foreach( siren in sirenRefs )
		EmitSoundAtPosition( siren.GetOrigin(), warningAlias )

	wait 8

	if ( GetGameState() >= eGameState.WinnerDetermined )
			return

	SetGlobalForcedDialogueOnly( false )
}

function PlayCountDownWarningMessage()
{
	local sirenRefs = GetEntArrayByName_Expensive( "ref_siren" )

	foreach( siren in sirenRefs )
		EmitSoundAtPosition( siren.GetOrigin(), "diag_hp_epEnd_O2514_04_01_neut_bgpa" )
}

function CustomEpilogue()
{
	if ( GetCinematicMode() && ( GameRules.GetGameMode() == CAPTURE_POINT ) )
	{
		SetEpilogueObjective()

		SetCustomEpilogueDuration( O2_EPILOGUE_DURATION + O2_POST_EPILOGUE_DURATION )

		delaythread( O2_EPILOGUE_DURATION - 6.1 ) PlayCountDownWarningMessage()

		// We are in the epilogue so use the short versions of the kill replay times
		local maxKillReplayTime = DEATHCAM_TIME_SHORT + KILL_REPLAY_LENGTH_SHORT + KILL_REPLAY_AFTER_KILL_TIME_SHORT   // 6 seconds

		wait O2_EPILOGUE_DURATION - maxKillReplayTime

		level.nv.replayDisabled = true

		wait maxKillReplayTime

		DoPostEpilogue()
	}
	else
	{
		if ( EvacEnabled() )
			GM_SetObserverFunc( EvacObserverFunc )
	}
}

function DoPostEpilogue( dev = false )
{
	if ( dev )
	{
		local armada = GetEntArrayByNameWildCard_Expensive( "MCOR_skybox_MCOR_armad*" )
		armada.extend( GetEntArrayByNameWildCard_Expensive( "IMC_skybox_MCOR_carriers*" ) )
		foreach( ship in armada )
			ship.Kill()
	}

	foreach( player in GetPlayerArray() )
	{
		if ( IsValid( player ) )
			Remote.CallFunction_Replay( player, "ServerCallback_NukePlayers" )
	}

	FlagSet( "CinematicEnding" )

	wait 3.0

	local players = GetPlayerArray()
	foreach( player in players )
	{
		player.DisableWeaponViewModel()
		player.Signal( "RodeoOver" )// Need to give rodeo threads a chance to terminate rodeo
	}

	// Hides the HUD
	players = GetPlayerArray()
	foreach( player in players )
		player.SetCinematicEventFlags( CE_FLAG_INTRO )

	wait 1.0

	ClearPlayers()
	level.clearedPlayers = true

	wait 2.5

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

	local skycam = GetEnt( "skybox_cam_intro" )
	player.SetSkyCamera( skycam )

	player.SetPlayerSettings( "spectator" )
}

function EndingObserverFunc( player )
{
	PutPlayerInEndingView( player )

	local cam = GetEnt( "ending_player_cam" )
	local origin = cam.GetOrigin()
	local angles = cam.GetAngles()
	player.SetObserverModeStaticPosition( origin )
	player.SetObserverModeStaticAngles( angles )

	player.StartObserverMode( OBS_MODE_STATIC_LOCKED )
	player.SetObserverTarget( null )
}

function EvacSetup()
{
	//setup evac nodes and spectator cams
	local escapeNodeArray = GetEntArrayByNameWildCard_Expensive( "escape_node*" )
	foreach( node in escapeNodeArray )
	{
		local name 	= node.GetName()
		local target = GetEnt( node.GetTarget() )
		local origin = target.GetOrigin()
		local angles = target.GetAngles()

		Evac_AddLocation( name, origin, angles )
	}

	local node = GetEnt( "evac_space_node" )
	local offsetY = Vector( 0,30,0 )
	local offsetP = Vector( 45,0,0 )
	local angles = node.GetAngles() + offsetY
	angles = angles.AnglesCompose( offsetP )
	node.SetAngles( angles )

	Evac_SetSpaceNode( node )
	Evac_SetupDefaultVDUs()

	Evac_SetRoundEndSetupFunc( EvacSetupRoundEnd )
}

function EvacSetupRoundEnd()
{
	local event4 	= GetSavedDropEvent( "EvacShipEpilogue_e4" )
	Event_AddClientStateFunc( event4, "CE_O2VisualSettingsEvac" )
}

function EvacObserverFunc( player )
{
	player.SetObserverModeStaticPosition( level.ExtractLocations[ level.SelectedExtractLocationIndex ].spectatorPos )
	player.SetObserverModeStaticAngles( level.ExtractLocations[ level.SelectedExtractLocationIndex ].spectatorAng )

	player.StartObserverMode( OBS_MODE_CHASE )
	player.SetObserverTarget( null )
}

function SetEpilogueObjective( )
{
	SetTeamActiveObjective( TEAM_MILITIA, "O2_noEvacEnding" )
	SetTeamActiveObjective( TEAM_IMC, "O2_noEvacEnding" )
}


/************************************************************************************************\

#### ##    ## ######## ########   #######        ########  #######   #######  ##        ######
 ##  ###   ##    ##    ##     ## ##     ##          ##    ##     ## ##     ## ##       ##    ##
 ##  ####  ##    ##    ##     ## ##     ##          ##    ##     ## ##     ## ##       ##
 ##  ## ## ##    ##    ########  ##     ##          ##    ##     ## ##     ## ##        ######
 ##  ##  ####    ##    ##   ##   ##     ##          ##    ##     ## ##     ## ##             ##
 ##  ##   ###    ##    ##    ##  ##     ##          ##    ##     ## ##     ## ##       ##    ##
#### ##    ##    ##    ##     ##  #######           ##     #######   #######  ########  ######

\************************************************************************************************/
function CreateDogFight( origin, angles, animIMC = "st_gunship_dogfight_C", animMCOR = "ht_gunship_dogfight_C", teamonly = null )
{
	local shipIMC 	= CreatePropDynamic( STRATON_MODEL, origin, angles )
	local shipMCOR 	= CreatePropDynamic( HORNET_MODEL, origin, angles )
	shipIMC.EnableRenderAlways()
	shipMCOR.EnableRenderAlways()
	if ( teamonly )
	{
		shipIMC.SetTeam( teamonly )
		shipIMC.kv.VisibilityFlags = 2 //Only friendlies can see this
		shipMCOR.SetTeam( teamonly )
		shipMCOR.kv.VisibilityFlags = 2 //Only friendlies can see this
	}

	thread AnimDogFight( shipMCOR, animMCOR, origin, angles )
	thread AnimDogFight( shipIMC, animIMC, origin, angles )

	return shipMCOR
}

function AnimDogFight( ship, anim, origin, angles )
{
	ship.EndSignal( "OnDeath" )
	FlagEnd( "IMCDropPodsFakeTravel" )

	local node = CreateScriptMover( ship )
	node.SetOrigin( origin )
	node.SetAngles( angles )

	OnThreadEnd(
		function() : ( node, ship )
		{
			if ( IsValid( ship ) )
				ship.Kill()

			if ( IsValid( node ) )
				node.Kill()
		}
	)

	//HACK: WANT TO DO THIS SO I CAN PARENT TO ROTATING WORLD
	//ship.SetParent( node, "REF", true, 0 )
	//node.SetParent( level.nv.worldRotator )

	thread PlayAnimTeleport( ship, anim, node, "REF" )

	local time = ship.GetSequenceDuration( anim )

	if ( ship.GetModelName() == HORNET_MODEL )
		wait time * RandomFloat( 0.7, 0.8 )
	else
		wait time - 0.5

	if ( IsValid( ship ) )
		thread PlayFX( FX_O2_AIRBURST, ship.GetOrigin(), ship.GetAngles() )
}

function ExplodeSpaceShip( delay, ship, team, sfx = null, sfxOffset = null )
{
	ship.EndSignal( "OnDeath" )

	wait delay

	if ( !IsValid( ship ) )
		return

	PlayFX( FX_SPACE_NUKE_EXPLOSION, ship.GetOrigin() )
	if ( sfx )
		thread ExplodeSpaceShipSFX( sfx, team, sfxOffset )

	foreach( player in GetPlayerArrayOfTeam( team ) )
	{
		if ( IsValid( player ) )
			Remote.CallFunction_Replay( player, "ServerCallback_TonemappingNuke" )
	}

	wait 0.2//don't hide it just yet
	ship.Kill()
}

function ExplodeSpaceShipSFX( sfx, team, offset )
{
	Assert( offset )

	local origins = []

	foreach( ref in level.IntroRefs[ team ] )
	{
		local node = CreatePropDynamic( "models/dev/editor_ref.mdl", ref.GetOrigin() )
		local origin = node.GetOrigin()
		origin += ( ref.GetRightVector() * offset.x )
		origin += ( ref.GetForwardVector() * offset.y )
		origin += ( ref.GetUpVector() * offset.z )
		node.SetOrigin( origin )

		PlaySoundToAttachedPlayersOnEnt( ref, node, sfx )

		origins.append( node )
	}

	wait 10//arbitrary time

	foreach ( node in origins )
		node.Kill()
}

function CallFuncForAttachedPlayers( ref, func, ... )
{
	local var = []
	for ( local i = 0; i < vargc; i++ )
		var.append( vargv[ i ] )

	foreach( slot in GetSlotsFromRef( ref ) )
	{
		local player = GetPlayerFromSlot( slot )

		if ( !IsAlive( player ) )
			continue

		//because of debug skipping - check for this
		if ( !player.IsPlayer() )
			continue

		switch( var.len() )
		{
			case 0:
				Remote.CallFunction_Replay( player, func )
				break
			case 1:
				Remote.CallFunction_Replay( player, func, var[ 0] )
				break
			case 2:
				Remote.CallFunction_Replay( player, func, var[ 0], var[ 1] )
				break
			case 3:
				Remote.CallFunction_Replay( player, func, var[ 0], var[ 1], var[ 2] )
				break
			case 4:
				Remote.CallFunction_Replay( player, func, var[ 0], var[ 1], var[ 2], var[ 3] )
				break
			case 5:
				Remote.CallFunction_Replay( player, func, var[ 0], var[ 1], var[ 2], var[ 3], var[ 4] )
				break
		}
	}
}

function DisableTurretsFromMinimap()
{
	local turrets = GetEntArrayByNameWildCard_Expensive( "turret_IMC_intro*" )
	turrets.extend( GetEntArrayByNameWildCard_Expensive( "turret_IMC_bridge*" ) )

	foreach( turret in turrets )
	{
		turret.Minimap_Hide( TEAM_IMC, null )
		turret.Minimap_Hide( TEAM_MILITIA, null )
	}
}

/************************************************************************************************\

##     ##    ###    ########  ########        ########   #######  #### ##    ## ########  ######
##     ##   ## ##   ##     ## ##     ##       ##     ## ##     ##  ##  ###   ##    ##    ##    ##
##     ##  ##   ##  ##     ## ##     ##       ##     ## ##     ##  ##  ####  ##    ##    ##
######### ##     ## ########  ##     ##       ########  ##     ##  ##  ## ## ##    ##     ######
##     ## ######### ##   ##   ##     ##       ##        ##     ##  ##  ##  ####    ##          ##
##     ## ##     ## ##    ##  ##     ##       ##        ##     ##  ##  ##   ###    ##    ##    ##
##     ## ##     ## ##     ## ########        ##         #######  #### ##    ##    ##     ######

\************************************************************************************************/
function SetupO2Hardpoints()
{
	FlagWait( "ReadyToStartMatch" )

	foreach( hardpoint in level.hardpoints )
	{
		AddHardpointTeamSwitchCallback( hardpoint, HardpointSwitchedTeam )
	}
}

function HardpointSwitchedTeam( hardpoint, previousTeam = null )
{
	local allMarvins = GetNPCArrayByClass( "npc_marvin" )
	local hardpointMarvins = ArrayWithin( allMarvins, hardpoint.GetOrigin(), 1500 )
	local team = hardpoint.GetTeam()

	UpdateReactorFX()

	if ( team == TEAM_MILITIA )
	{
		StartKlaxons( hardpoint )

		foreach ( marvin in hardpointMarvins )
			SetMarvinShouldFightFire( marvin, true )
	}
	else
	{
		StopKlaxons( hardpoint )

		foreach ( marvin in hardpointMarvins )
			SetMarvinShouldFightFire( marvin, false )
	}
}


function HardpointKeepShaking( hardpoint )
{
	hardpoint.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function () : ( hardpoint )
		{
			hardpoint.s.hardpointShakeEnt.Fire( "StopShake")
		}
	)

	while(1)
	{
		hardpoint.s.hardpointShakeEnt.Fire( "StartShake")
		wait 1.0
	}
}

/************************************************************************************************\

     ######## ##     ##
     ##        ##   ##
     ##         ## ##
     ######      ###
     ##         ## ##
     ##        ##   ##
     ##       ##     ##


\************************************************************************************************/
function SetupFX()
{
	local fx_atmos_tower = GetEnt( "fx_atmosphere_processor" )
	Assert( IsValid( fx_atmos_tower ) )

	// Start O2 tower smoke
	level.atmosOKFX = PlayLoopFX( FX_ATMOS_OK, fx_atmos_tower.GetOrigin(), fx_atmos_tower.GetAngles() )
	level.atmosBurnFX = PlayLoopFX( FX_ATMOS_BURN, fx_atmos_tower.GetOrigin(), fx_atmos_tower.GetAngles() )
	StopFX( level.atmosBurnFX )
}

function UpdateReactorFX()
{
	if( O2_DEV_DISABLE_HARDPOINT_FX )
		return

	local fx_atmos_tower = GetEnt( "fx_atmosphere_processor" )

	Assert( IsValid( fx_atmos_tower ) )

	if( GetGameState() >= eGameState.Epilogue )			// Abort if someone captures a hardpoint during epilogue
		return

	// Stop all O2 tower FX
	StopFX( level.atmosOKFX )
	StopFX( level.atmosBurnFX )

	// If militia own 2+ hardpoints, show burning FX on O2 tower, otherwise always white smoke
	local hasMajority = GetNumHardpointsControlledByTeam( TEAM_MILITIA ) > ( level.hardpoints.len() / 2.0 )
	if ( hasMajority || Flag( "CoreDestabalized" ) )
	{
		StopFX( level.atmosOKFX )
		level.atmosBurnFX = PlayLoopFX( FX_ATMOS_BURN, fx_atmos_tower.GetOrigin(), fx_atmos_tower.GetAngles() )
	}
	else
	{
		StopFX( level.atmosOKFX )
		level.atmosOKFX = PlayLoopFX( FX_ATMOS_OK, fx_atmos_tower.GetOrigin(), fx_atmos_tower.GetAngles() )
	}
}

function EpilogueFXThink()
{
	local fx_atmos_tower = GetEnt( "fx_atmosphere_processor" )

	Assert( IsValid( fx_atmos_tower ) )

	WaittillGameStateOrHigher( eGameState.Epilogue )

	// Stop all O2 tower FX
	StopFX( level.atmosOKFX )
	StopFX( level.atmosBurnFX )

	// Always have the tower burning & shaking in epilogue no matter who is winning
	level.atmosBurnFX = PlayLoopFX( FX_ATMOS_BURN, fx_atmos_tower.GetOrigin(), fx_atmos_tower.GetAngles() )

	local hardpoint = GetEnt( "hardpoint_refinery" )
	local env_shake = CreateEntity( "env_shake" )
	env_shake.kv.amplitude = 3
	env_shake.kv.radius = 2048
	env_shake.kv.duration = 4
	env_shake.kv.frequency = 2
	DispatchSpawn( env_shake, false )
	env_shake.SetOrigin( hardpoint.GetOrigin() )
	hardpoint.s.hardpointShakeEnt <- env_shake

	thread HardpointKeepShaking( hardpoint )

	EmitSoundOnEntity( hardpoint, SFX_REFINERY_RUMBLE )
}

/************************************************************************************************\

##    ## ##          ###    ##     ##  #######  ##    ##        ######  #### ########  ######## ##    ##  ######
##   ##  ##         ## ##    ##   ##  ##     ## ###   ##       ##    ##  ##  ##     ## ##       ###   ## ##    ##
##  ##   ##        ##   ##    ## ##   ##     ## ####  ##       ##        ##  ##     ## ##       ####  ## ##
#####    ##       ##     ##    ###    ##     ## ## ## ##        ######   ##  ########  ######   ## ## ##  ######
##  ##   ##       #########   ## ##   ##     ## ##  ####             ##  ##  ##   ##   ##       ##  ####       ##
##   ##  ##       ##     ##  ##   ##  ##     ## ##   ###       ##    ##  ##  ##    ##  ##       ##   ### ##    ##
##    ## ######## ##     ## ##     ##  #######  ##    ##        ######  #### ##     ## ######## ##    ##  ######


\************************************************************************************************/
function KlaxonSetup()
{
	local sirenRefs = GetEntArrayByName_Expensive( "ref_siren" )

	foreach ( hardpoint in level.hardpoints )
		hardpoint.s.sirens <- ArrayWithin( sirenRefs, hardpoint.GetOrigin(), 1500 )
}

function StartKlaxons( hardpoint )
{
	foreach( siren in hardpoint.s.sirens )
		EmitSoundAtPosition( siren.GetOrigin(), SFX_CANNON_PREFIRE_KLAXON_LOOP )
}

function StopKlaxons( hardpoint )
{
	foreach( siren in hardpoint.s.sirens )
		StopSoundAtPosition( siren.GetOrigin(), SFX_CANNON_PREFIRE_KLAXON_LOOP )
}



/************************************************************************************************\

##     ##    ###    ########  ######  ##     ##       ########  ########   #######   ######   ########  ########  ######   ######
###   ###   ## ##      ##    ##    ## ##     ##       ##     ## ##     ## ##     ## ##    ##  ##     ## ##       ##    ## ##    ##
#### ####  ##   ##     ##    ##       ##     ##       ##     ## ##     ## ##     ## ##        ##     ## ##       ##       ##
## ### ## ##     ##    ##    ##       #########       ########  ########  ##     ## ##   #### ########  ######    ######   ######
##     ## #########    ##    ##       ##     ##       ##        ##   ##   ##     ## ##    ##  ##   ##   ##             ##       ##
##     ## ##     ##    ##    ##    ## ##     ##       ##        ##    ##  ##     ## ##    ##  ##    ##  ##       ##    ## ##    ##
##     ## ##     ##    ##     ######  ##     ##       ##        ##     ##  #######   ######   ##     ## ########  ######   ######


\************************************************************************************************/
function MatchProgressSetup()
{
	if ( GetCinematicMode() && GameRules.GetGameMode() == CAPTURE_POINT )
		level.progressDialogPlayed = { [ FIRST_WARNING_PROGRESS ] = false, [ SECOND_WARNING_PROGRESS ] = false, [ THIRD_WARNING_PROGRESS ] = false }

	GM_SetMatchProgressAnnounceFunc( MatchProgressUpdate )
}

function O2GameStateChangedServer()
{
	switch ( GetGameState() )
	{
		case eGameState.WinnerDetermined:
			if ( GetCinematicMode() && GameRules.GetGameMode() == CAPTURE_POINT )
				SetGlobalForcedDialogueOnly( true )
			break
	}
}
// Only send important major milestones to client
function MatchProgressMilestones()
{
	FlagWait( "O2_Match15Percent" )
	level.nv.matchProgressMilestone = 15

	FlagWait( "O2_Match25Percent" )
	level.nv.matchProgressMilestone = 25

	FlagWait( "O2_Match40Percent" )
	level.nv.matchProgressMilestone = 40

	FlagWait( "O2_Match45Percent" )
	level.nv.matchProgressMilestone = 45

	FlagWait( "O2_Match60Percent" )
	level.nv.matchProgressMilestone = 60

	FlagWait( "O2_Match80Percent" )
	level.nv.matchProgressMilestone = 80

	FlagWait( "O2_Match90Percent" )
	level.nv.matchProgressMilestone = 90

	FlagWait( "O2_Match98Percent" )
	level.nv.matchProgressMilestone = 98
}

function MatchProgressUpdate( percentComplete )
{
	Assert( GetGameState() == eGameState.Playing )

	if ( level.devForcedWin )
		return

	// Set some progress flags - used for narrative & skyshow
	if( !Flag( "O2_Match15Percent" )&& percentComplete >= 15 )
		FlagSet( "O2_Match15Percent" )

	if( !Flag( "O2_Match25Percent" )&& percentComplete >= 25 )
		FlagSet( "O2_Match25Percent" )

	if( !Flag( "O2_Match40Percent" ) && percentComplete >= 40 )
		FlagSet( "O2_Match40Percent" )

	if( !Flag( "O2_Match45Percent" ) && percentComplete >= 45 )
		FlagSet( "O2_Match45Percent" )

	if( !Flag( "O2_Match60Percent" ) && percentComplete >= 60 )
		FlagSet( "O2_Match60Percent" )

	if( !Flag( "O2_Match80Percent" ) && percentComplete >= 80 )
		FlagSet( "O2_Match80Percent" )

	if( !Flag( "O2_Match90Percent" ) && percentComplete >= 90 )
		FlagSet( "O2_Match90Percent" )

	if( !Flag( "O2_Match98Percent" ) && percentComplete >= 98 )
		FlagSet( "O2_Match98Percent" )

	if( GetCinematicMode() && ( GameRules.GetGameMode() == CAPTURE_POINT ) )
	{
		local clampedPercentComplete = GetClampedPercentComplete( percentComplete )
		if ( clampedPercentComplete >= FIRST_WARNING_PROGRESS && clampedPercentComplete <= THIRD_WARNING_PROGRESS )
			thread PlayProgressDialogOverLoudspeakers( clampedPercentComplete )
	}

	// On top of the custom stuff, we want the default announcements, so call default announcements
	DefaultMatchProgressionAnnouncement( percentComplete )
}

function PlayProgressDialogOverLoudspeakers( clampedPercentComplete )
{
	// Have we already played these messages?
	if ( level.progressDialogPlayed[ clampedPercentComplete ] )
		return

	//-------------------------------------------------------------------------
	// Play at all loudspeakers in the level
	//-------------------------------------------------------------------------
	local postWarningDelay = 8
	local winningTeam = GetCurrentWinner( TEAM_MILITIA )
	local warningAlias = level.dialogAliases[ winningTeam ][ "warning_" + clampedPercentComplete ]
	local sirenRefs = GetEntArrayByName_Expensive( "ref_siren" )
	foreach( siren in sirenRefs )
		EmitSoundAtPosition( siren.GetOrigin(), warningAlias )

	level.progressDialogPlayed[ clampedPercentComplete ] = true

	//-------------------------------------------------------------------------
	// Delay radio conversation to allow client loudspeakers to play on client
	//-------------------------------------------------------------------------
	if( clampedPercentComplete < THIRD_WARNING_PROGRESS ) // Disable the 3rd post-warning conversation since story VDU cuts it off
	{
		local progressAlias = level.progressConversations[ winningTeam ][ clampedPercentComplete ]

		wait postWarningDelay

		thread PlayConversationToTeam( progressAlias, TEAM_IMC )
		thread PlayConversationToTeam( progressAlias, TEAM_MILITIA )
	}
}

// Clamps the progress percent to a discrete value like 25, 75, 100 based on what is in level.progressDialogPlayed
function GetClampedPercentComplete( progressPercent )
{
	local clampedProgress = 0

	foreach ( progress, val in level.progressDialogPlayed )
	{
		if( ( progressPercent >= progress ) && ( clampedProgress < progress ) )
			clampedProgress = progress
	}

	//printt("GetClampedPercentComplete:", progressPercent, "-->", clampedProgress)

	return clampedProgress
}

function O2SpecificChatter( npc )
{
	Assert( GetMapName() == "mp_o2" )

	if ( !GamePlayingOrSuddenDeath() )
		return false

	PlaySquadConversationToTeam( "o2_grunt_chatter", npc.GetTeam(), npc, AI_FRIENDLY_CHATTER_RANGE_SQR )
	return true //return false if we should not be doing chatter so we can fall through and do other chatter if needed
}

/************************************************************************************************\

########  ######## ##     ##    ##     ## ######## ##    ## ##     ##
##     ## ##       ##     ##    ###   ### ##       ###   ## ##     ##
##     ## ##       ##     ##    #### #### ##       ####  ## ##     ##
##     ## ######   ##     ##    ## ### ## ######   ## ## ## ##     ##
##     ## ##        ##   ##     ##     ## ##       ##  #### ##     ##
##     ## ##         ## ##      ##     ## ##       ##   ### ##     ##
########  ########    ###       ##     ## ######## ##    ##  #######

\************************************************************************************************/

function DEV_HackAttachPlayer( dropship1, dropship2 )
{
	local slots = GetSlotsFromRef( dropship1 )
	slots.extend( GetSlotsFromRef( dropship2 ) )
	foreach( slot in slots )
	{
		slot.s.ogType <- slot.s.type
		slot.s.type = "evac"//hack to get into ship
	}

	TryAddPlayerToCinematic( GetPlayerArray()[ 0 ] )

	foreach( slot in slots )
		slot.s.type = slot.s.ogType
}

function KillSpawns( name, remember = false )
{
	local spawns = GetEntArrayByNameWildCard_Expensive( name + "*" )

	if ( remember )
	{
		level.O2StartSpawns <- []
		foreach( spawnPoint in spawns )
		{
			local data = {}
			data.pos <- spawnPoint.GetOrigin()
			data.ang <- spawnPoint.GetAngles()
			level.O2StartSpawns.append( data )
		}
	}

	foreach( spawnPoint in spawns )
		spawnPoint.Kill()
}

main()

