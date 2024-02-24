const GUN_MODEL = "models/weapons/p2011/p2011_handgun_ab_01.mdl"
const SARAH_MODEL = "models/humans/mcor_hero/sarah/mcor_hero_sarah.mdl"
const PILOT_MODEL = "models/humans/mcor_grunt/battle_rifle/mcor_grunt_battle_rifle.mdl"
const BOMBER_MODEL = "models/vehicle/imc_bomber/bomber.mdl"
const GUNRACK_MODEL = "models/industrial/gun_rack_arm_down.mdl"
const LAPTOP_MODEL_SMALL = "models/communication/terminal_usable_airbase.mdl"

function main()
{
	FlagInit( "IMCIntroTitansReady1" )
	FlagInit( "IMCIntroTitansReady2" )
	FlagInit( "MCORIntroTitansReady1" )
	FlagInit( "MCORIntroTitansReady2" )
	FlagInit( "IMCDoorsOpen" )
	FlagInit( "IMCGuysExit" )
	FlagInit( "MCORStopIdle" )
	FlagInit( "IMCIntroGo" )

	Globalize( AB_IntroTDMSetup )
	Globalize( AB_IntroTDM )

	Globalize( IntroIMCGravesCrew_1 )
	Globalize( IntroIMCGravesCrew_2 )
	Globalize( IntroIMCGravesCrew_3 )
	Globalize( IntroIMCGravesCrew_4 )
	Globalize( IntroIMCGravesCrew_5 )
	Globalize( IntroIMCGravesCrew_6 )
	Globalize( IntroIMCGravesCrewHimself )
}

function AB_IntroTDMSetup()
{
	IntroSetupMilitiaHero()
}

function AB_IntroTDM()
{
	thread AB_IntroIMCTDM()
	thread AB_IntroMilitiaTDM()

/*	FlagWait( "IMCIntroTitansReady1" )
	FlagWait( "IMCIntroTitansReady2" )
	FlagWait( "MCORIntroTitansReady1" )
	FlagWait( "MCORIntroTitansReady2" )*/

	wait INTROCUSTOMLENGTH_TDM + 4.0
	FlagSet( "IntroDone" )
}

/************************************************************************************************\

#### ##     ##  ######
 ##  ###   ### ##    ##
 ##  #### #### ##
 ##  ## ### ## ##
 ##  ##     ## ##
 ##  ##     ## ##    ##
#### ##     ##  ######

\************************************************************************************************/

function AB_IntroIMCTDM()
{
	thread IntroDoorBehavior()
	thread IntroIMCGraves()
	thread IntroIMCGravesCrew()
	thread IntroIMCSquad3()
	thread IntroIMCTitanAlavi()
	thread IntroIMCTitanGates()
}

function IntroIMCGraves()
{
	local node = GetNodeByUniqueID( "cinematic_mp_node_GravesHimself" )
	IntroIMCGravesCrewHimself( node )//NodeDoMoment( node )
}

function IntroIMCGravesCrew()
{
	local squad1 = []
	local squad2 = []

	wait 7.5

	squad1.extend( IntroIMCGravesCrew_1( GetNodeByUniqueID( "cinematic_mp_node_GravesCrew1" ) ) )
	squad1.extend( IntroIMCGravesCrew_6( GetNodeByUniqueID( "cinematic_mp_node_GravesCrew6" ) ) )

	squad2.extend( IntroIMCGravesCrew_2( GetNodeByUniqueID( "cinematic_mp_node_GravesCrew2" ) ) )
	squad2.extend( IntroIMCGravesCrew_5( GetNodeByUniqueID( "cinematic_mp_node_GravesCrew5" ) ) )

	if ( GetCPULevelWrapper() == CPU_LEVEL_HIGHEND )
	{
		squad1.extend( IntroIMCGravesCrew_3( GetNodeByUniqueID( "cinematic_mp_node_GravesCrew3" ) ) )
		squad2.extend( IntroIMCGravesCrew_4( GetNodeByUniqueID( "cinematic_mp_node_GravesCrew4" ) ) )
	}



	FlagWait( "IMCIntroGo" )
	ArrayRemoveDead( squad1 )
	ArrayRemoveDead( squad2 )

	ScriptedSquadAssault( squad1, 0 )
	ScriptedSquadAssault( squad2, 1 )
}

function IntroIMCSquad3()
{
	FlagWait( "IMCDoorsOpen" )

	local squad = []
	local array = GetEntArrayByNameWildCard_Expensive( "imc_squad3_spot*" )
	foreach( num, node in array )
	{
		if ( num > 2 && GetCPULevelWrapper() != CPU_LEVEL_HIGHEND )
			continue

		local guy = Spawn_TrackedGrunt( TEAM_IMC, "imc_squad3", node.GetOrigin() + Vector( 0,0,8 ), node.GetAngles() )
		squad.append( guy )
		local target = GetEnt( node.GetTarget() )
		thread IntroIMCSquad3FollowPath( guy, target )
	}

	thread IntroIMCSquad3guywave( squad[ 0 ] )

	wait 5.0

	ArrayRemoveDead( squad )
	ScriptedSquadAssault( squad, 2 )
}

function IntroIMCSquad3guywave( guy )
{
	guy.EndSignal( "OnDeath" )

	wait 3.75
	guy.DisableStarts()

	thread PlayAnimGravity( guy, "pt_generic_run_N_wave" )

	wait 1.1
	guy.Anim_Stop()

	wait 0.5
	guy.EnableStarts()
}

function IntroIMCSquad3FollowPath( guy, target )
{
	guy.EndSignal( "OnDeath" )

	while( target )
	{
		guy.DisableArrivalOnce( true )
		waitthread GotoOrigin( guy, target.GetOrigin() )
		guy.DisableStarts()
		target = GetEnt( target.GetTarget() )
	}
	guy.EnableStarts()
}

function IntroDoorBehavior()
{
	local doors2 = GetEntArrayByNameWildCard_Expensive( "imc_intro_door_outter*" )
	foreach ( door in doors2 )
		DoorOpen( door )

	wait GetTimeTillGameStarts()
	FlagSet( "IMCDoorsOpen" )
	delaythread( 0.5 ) FlagSet( "IMCGuysExit" )

	local doors1 = GetEntArrayByNameWildCard_Expensive( "imc_intro_door_inner*" )
	foreach ( door in doors1 )
		DoorOpen( door )
}

/************************************************************************************************\

##    ##  #######  ########  ########        ######   ##     ## ##    ##  ######
###   ## ##     ## ##     ## ##             ##    ##  ##     ##  ##  ##  ##    ##
####  ## ##     ## ##     ## ##             ##        ##     ##   ####   ##
## ## ## ##     ## ##     ## ######         ##   #### ##     ##    ##     ######
##  #### ##     ## ##     ## ##             ##    ##  ##     ##    ##          ##
##   ### ##     ## ##     ## ##             ##    ##  ##     ##    ##    ##    ##
##    ##  #######  ########  ########        ######    #######     ##     ######

\************************************************************************************************/
function IntroIMCGravesCrewHimself( node )
{
	if ( !( "graves" in node ) )
		node.graves <- null

	if ( IsValid( node.graves ) )
		node.graves.Kill()

	local graves 	= CreatePropDynamic( GRAVES_MODEL, node.pos, node.ang )
	graves.SetTeam( TEAM_IMC )
	graves.kv.VisibilityFlags = 2 //Only friendlies can see this
	graves.kv.skin = 1
	graves.kv.rendercolor = "94 174 255" //Blue

	node.graves = graves

	graves.EndSignal( "OnDeath" )

	thread IntroGravesDialogue( graves )

	wait 7.75//fade in from black

	AddAnimEvent( graves, "fizzleOut", GravesFizzleOut)
	waitthread PlayAnimTeleport( graves, "pt_airbase_Graves_hologram", node.pos, node.ang )

	wait 2.0
	graves.Kill()
}

function GravesFizzleOut( graves )
{
	graves.Dissolve( ENTITY_DISSOLVE_CHAR, Vector( 0, 0, 0 ), 500 )
}

function IntroGravesDialogue( graves )
{
	graves.EndSignal( "OnDeath" )
	graves.EndSignal( "OnDestroy" )

	wait 1.0
	//Attention. This is Vice Admiral Graves to all personnel. The Militia attack on this base is imminent.
	EmitSoundOnEntityToTeam( graves, "diag_matchIntro_AB139_01a_01_imc_graves", TEAM_IMC )
}

function IntroIMCGravesCrew_1( node )
{
	local idleTime = INTROCUSTOMLENGTH_TDM - 18.5

	IntroGravesCrewNodeCleanup( node )
	node.guys 		= AirbaseGravesCrewCommon( node.pos, node.ang, "squad_Graves_squad_0", "pt_airbase_weapon_toss_right_A", "pt_airbase_weapon_toss_right_B", idleTime )
	node.gunRack 	= AirbaseGravesCrewGunRack( node.pos, node.ang )
	foreach ( guy in node.guys )
		guy.DisableStarts()
	return node.guys
}

function IntroIMCGravesCrew_2( node )
{
	local idleTime = INTROCUSTOMLENGTH_TDM - 16.0

	IntroGravesCrewNodeCleanup( node )
	node.guys 		= AirbaseGravesCrewCommon( node.pos, node.ang, "squad_Graves_squad_0", "pt_airbase_weapon_toss_left_A", "pt_airbase_weapon_toss_left_B", idleTime )
	node.gunRack 	= AirbaseGravesCrewGunRack( node.pos, node.ang )
	foreach ( guy in node.guys )
		guy.DisableStarts()
	return node.guys
}

function IntroIMCGravesCrew_3( node )
{
	local idleTime = INTROCUSTOMLENGTH_TDM - 17

	IntroGravesCrewNodeCleanup( node )
	node.guys 		= AirbaseGravesCrewSingle( node.pos, node.ang, "squad_Graves_squad_1", "pt_airbase_weapon_toss_background_A", idleTime )
	foreach ( guy in node.guys )
		guy.DisableStarts()
	return node.guys
}

function IntroIMCGravesCrew_4( node )
{
	local idleTime = INTROCUSTOMLENGTH_TDM - 17

	IntroGravesCrewNodeCleanup( node )
	node.guys 		= AirbaseGravesCrewSingle( node.pos, node.ang, "squad_Graves_squad_1", "pt_airbase_weapon_toss_background_B", idleTime )
	foreach ( guy in node.guys )
		guy.DisableStarts()
	return node.guys
}

function IntroIMCGravesCrew_5( node )
{
	IntroGravesCrewNodeCleanup( node )
	node.guys 		= AirbaseGravesCrewSingle( node.pos, node.ang, "squad_Graves_squad_1", "CQB_Idle_Casual", 0.0, PlayAnimGravity )
	return node.guys
}

function IntroIMCGravesCrew_6( node )
{
	IntroGravesCrewNodeCleanup( node )
	node.guys 		= AirbaseGravesCrewSingle( node.pos, node.ang, "squad_Graves_squad_1", "Militia_flyinA_idle_playerB", 0.0, PlayAnimGravity )
	return node.guys
}

/************************************************************************************************\

##    ##  #######  ########  ########       ########  #######   #######  ##        ######
###   ## ##     ## ##     ## ##                ##    ##     ## ##     ## ##       ##    ##
####  ## ##     ## ##     ## ##                ##    ##     ## ##     ## ##       ##
## ## ## ##     ## ##     ## ######            ##    ##     ## ##     ## ##        ######
##  #### ##     ## ##     ## ##                ##    ##     ## ##     ## ##             ##
##   ### ##     ## ##     ## ##                ##    ##     ## ##     ## ##       ##    ##
##    ##  #######  ########  ########          ##     #######   #######  ########  ######

\************************************************************************************************/
function IntroGravesCrewNodeCleanup( node )
{
	node.pos += Vector( 0,0,20 )
	local result = TraceLine( node.pos, node.pos + Vector( 0,0,-500 ), null, TRACE_MASK_NPCWORLDSTATIC, TRACE_COLLISION_GROUP_NONE )
	node.pos = result.endPos

	if ( !( "guys" in node ) )
	{
		node.guys <- []
		node.gunRack <- []
	}
	else
	{
		foreach ( guy in node.guys )
		{
			if ( ( IsValid( guy ) ) )
				guy.Kill()
		}

		foreach ( rack in node.gunRack )
			rack.Kill()
	}
}

function AirbaseGravesCrewCommon( origin, angles, name, anim1, anim2, idle = 0.0 )
{
	local guys		= []
	guys.append( Spawn_TrackedGrunt( TEAM_IMC, name, origin, angles ) )
	guys.append( Spawn_TrackedGrunt( TEAM_IMC, name, origin, angles ) )

	foreach( guy in guys )
	{
		guy.SetEfficientMode( true )
		thread IntroIMCGravesCrewGo( guy, idle )
	}

	if ( idle )
	{
		thread PlayAnimTeleport( guys[ 0 ], anim1 + "_idle", origin, angles )
		thread PlayAnimTeleport( guys[ 1 ], anim2 + "_idle", origin, angles )
		delaythread( idle ) PlayAnimTeleport( guys[ 0 ], anim1, origin, angles )
		delaythread( idle ) PlayAnimTeleport( guys[ 1 ], anim2, origin, angles )
	}
	else
	{
		thread PlayAnimTeleport( guys[ 0 ], anim1, origin, angles )
		thread PlayAnimTeleport( guys[ 1 ], anim2, origin, angles )
	}

	return guys
}

function AirbaseGravesCrewSingle( origin, angles, name, anim, idle = 0.0, func = PlayAnimTeleport )
{
	local guy = Spawn_TrackedGrunt( TEAM_IMC, name, origin, angles )

	guy.SetEfficientMode( true )
	thread IntroIMCGravesCrewGo( guy, idle )

	if ( idle )
	{
		thread func( guy, anim + "_idle", origin, angles )
		delaythread( idle ) func( guy, anim, origin, angles )
	}
	else
		thread func( guy, anim, origin, angles )

	local guys = [ guy ]
	return guys
}

function AirbaseGravesCrewGunRack( origin, angles )
{
	local right = angles.AnglesToRight()
	local offset = right * 6

	local rack = []
	rack.append( CreatePropDynamic( GUNRACK_MODEL, origin + offset, angles ) )
	rack.append( CreatePropDynamic( GUNRACK_MODEL, origin - offset, angles ) )

	return rack
}

function IntroIMCGravesCrewGo( guy, idle = 0.0 )
{
	guy.EndSignal( "OnDeath" )

	if( !idle )
		FlagEnd( "IMCGuysExit" )

	OnThreadEnd(
		function() : ( guy )
		{
			if ( !IsAlive( guy ) )
				return

			thread IntroIMCGravesCrewRunPath( guy )
		}
	)
	if ( idle )
		wait idle + 0.25

	guy.WaittillAnimDone()
}

function IntroIMCGravesCrewRunPath( guy )
{
	FlagEnd( "IMCIntroGo" )
	guy.EndSignal( "OnDeath" )

	guy.SetEfficientMode( false )
	guy.Anim_Stop()

	OnThreadEnd(
		function() : ( guy )
		{
			if ( IsAlive( guy) )
				guy.EnableStarts()
		}
	)

	//take him along his path
	local target = GetEnt( "imc_intro_runout_node" )
	while( target )
	{
		guy.DisableArrivalOnce( true )
		waitthread GotoOrigin( guy, target.GetOrigin() )
		guy.DisableStarts()
		target = GetEnt( target.GetTarget() )
	}

	//first guy to get there sets it for everyone in the room
	FlagSet( "IMCIntroGo" )
}


/************************************************************************************************\

#### ##     ##  ######        ######## #### ########    ###    ##    ##  ######
 ##  ###   ### ##    ##          ##     ##     ##      ## ##   ###   ## ##    ##
 ##  #### #### ##                ##     ##     ##     ##   ##  ####  ## ##
 ##  ## ### ## ##                ##     ##     ##    ##     ## ## ## ##  ######
 ##  ##     ## ##                ##     ##     ##    ######### ##  ####       ##
 ##  ##     ## ##    ##          ##     ##     ##    ##     ## ##   ### ##    ##
#### ##     ##  ######           ##    ####    ##    ##     ## ##    ##  ######

\************************************************************************************************/
function IntroIMCTitanAlavi()
{
	local name 		= "#NPC_CAPTAIN_ALAVI"
	local node		= GetEnt( "imc_intro_titan1" )
	local table 	= CreateDefaultNPCTitanTemplate( TEAM_IMC )
	table.title 	= ""
	//table.weapon	= "mp_titanweapon_40mm"
	table.origin 	= node.GetOrigin()
	table.angles 	= node.GetAngles()

	local titan = SpawnNPCTitan( table )
	titan.SetEfficientMode( true )

	local node		= GetEnt( "imc_intro_titanpilot1" )
	local pilot 	= SpawnGrunt( TEAM_IMC, "", node.GetOrigin(), node.GetAngles() )
	pilot.SetModel( TEAM_IMC_CAPTAIN_MDL )
	pilot.SetEfficientMode( true )
	pilot.SetTitle( name )

	local anim 	= "CQB_Idle_Casual"
	local origin = HackGetDeltaToRef( node.GetOrigin(), node.GetAngles(), pilot, anim )
	node.SetOrigin( origin )

	thread PlayAnimGravity( pilot, anim, origin, pilot.GetAngles() )
	thread PlayAnimTeleport( titan, "at_MP_embark_idle", titan.GetOrigin(), titan.GetAngles() )

	titan.EndSignal( "OnDeath" )

	FlagWait( "IMCDoorsOpen" )
	wait 1

	if ( IsAlive( pilot ) )
	{
		pilot.Anim_Stop()
		waitthread RunToAnimStartForcedTimeOut( pilot, "pt_MP_embark", titan, null, 20 )
	}

	if ( IsAlive( pilot ) )
		thread PlayAnim( pilot, "pt_MP_embark", titan )

	delaythread( 0.1 ) PlayASound( titan, "Airbase_Scr_TitanCaptain_Alavi" )
	waitthread PlayAnim( titan, "at_MP_embark_start" )

	if ( IsAlive( pilot ) )
		pilot.Kill()


	titan.SetTitle( name )
	waitthread PlayAnim( titan, "at_MP_embark" )
	titan.SetEfficientMode( false )

	level.IMCTitans.append( titan )
	FlagSet( "IMCIntroTitansReady1" )

	local node = GetEnt( "imc_intro_titan1" )
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

function PlayASound( titan, sound )
{
	if ( IsValid( titan ) )
		EmitSoundOnEntity( titan, sound )
}

function IntroIMCTitanGates()
{
	local name 		= "#NPC_CAPTAIN_GATES"
	local node		= GetEnt( "imc_intro_titan2" )
	local table 	= CreateDefaultNPCTitanTemplate( TEAM_IMC )
	table.title 	= ""
	table.weapon	= "mp_titanweapon_40mm"
	table.origin 	= node.GetOrigin()
	table.angles 	= node.GetAngles()

	local titan = SpawnNPCTitan( table )
	titan.SetEfficientMode( true )

	local node		= GetEnt( "imc_intro_titanpilot2" )
	local pilot 	= SpawnGrunt( TEAM_IMC, "", node.GetOrigin(), node.GetAngles() )
	pilot.SetModel( TEAM_IMC_CAPTAIN_MDL )
	pilot.SetEfficientMode( true )
	pilot.SetTitle( name )

	local anim 	= "CQB_Idle_Casual"
	local origin = HackGetDeltaToRef( node.GetOrigin(), node.GetAngles(), pilot, anim )
	node.SetOrigin( origin )

	thread PlayAnimGravity( pilot, anim, origin, pilot.GetAngles() )
	thread PlayAnimTeleport( titan, "at_MP_embark_idle", titan.GetOrigin(), titan.GetAngles() )

	titan.EndSignal( "OnDeath" )

	FlagWait( "IMCDoorsOpen" )

	wait 2

	node = GetEnt( node.GetTarget() )
	node.SetOrigin( node.GetOrigin() + Vector( 0,0,8 ) )
	local index = titan.LookupAttachment( "hijack" )
	local origin = titan.GetAttachmentOrigin( index )
	local angles = titan.GetAttachmentAngles( index )

	if ( IsAlive( pilot ) )
	{
		pilot.Anim_Stop()
		//run to the spot to jump over barrier
		waitthread RunToAnimStartForcedTimeOut( pilot, "a_traverse_jump_over_fast", node, null, 20 )
	}

	if ( IsAlive( pilot ) )
	{
		thread PlayAnim( pilot, "a_traverse_jump_over_fast", node )
		//partially into jumping over play titan anim
		wait 0.1
	}

	local node		= GetEnt( "imc_intro_titan2" )
	thread PlayAnim( titan, "at_mount_kneel_left", node )
	thread PlayASound( titan, "Airbase_Scr_TitanCaptain_Gates" )
	//at a specific time play the pilot anim to catch up
	local time = 0.9
	wait time
	thread PlayAnim( titan, "at_mount_kneel_left", node )

	if ( IsAlive( pilot ) )
	{
		thread PlayAnim( pilot, "pt_mount_atlas_kneel_left", origin, angles )
		pilot.Anim_SetInitialTime( time )
	}

	titan.Anim_SetInitialTime( time )

	//wait for titan anim to finish and continue
	titan.WaittillAnimDone()

	if ( IsAlive( pilot ) )
		pilot.Kill()


	titan.SetTitle( name )
	titan.SetEfficientMode( false )

	level.IMCTitans.append( titan )
	FlagSet( "IMCIntroTitansReady2" )

	local node = GetEnt( "imc_intro_titan2" )
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


/************************************************************************************************\

##     ## #### ##       #### ######## ####    ###
###   ###  ##  ##        ##     ##     ##    ## ##
#### ####  ##  ##        ##     ##     ##   ##   ##
## ### ##  ##  ##        ##     ##     ##  ##     ##
##     ##  ##  ##        ##     ##     ##  #########
##     ##  ##  ##        ##     ##     ##  ##     ##
##     ## #### ######## ####    ##    #### ##     ##

\************************************************************************************************/

function AB_IntroMilitiaTDM()
{
	//set the timing for client extras and do the server extras
	level.nv.MCORClientTiming = Time()
	IntroGoblinTakeOff()
	IntroGoblinLiftTakeOff()
	thread IntroStratonLanding()
	IntroTitansWalking()

	local baseTime = INTROCUSTOMLENGTH_TDM - 5.0

	//fix for titan getting stuck on rack of crates sometimes
	local node = GetEnt( "militia_intro_titan2" )
	node.SetOrigin( node.GetOrigin() + Vector ( 50,100,0) )

	delaythread( baseTime + 2.0 ) AB_IntroAITitanDrop( "#NPC_CAPTAIN_DAVIS", TEAM_MILITIA, "mcor_intro_titanpilot1", "militia_intro_titan1", "MCORIntroTitansReady1", "mp_titanweapon_rocket_launcher" )
	delaythread( baseTime + 3.5 ) AB_IntroAITitanDrop( "#NPC_CAPTAIN_DROZ", TEAM_MILITIA, "mcor_intro_titanpilot2", "militia_intro_titan2", "MCORIntroTitansReady2" )
	delaythread( baseTime + 1.0 ) AB_IntroAIDropPod( TEAM_MILITIA, "MCORIntroDP0", 0 )
	delaythread( baseTime + 2.0 ) AB_IntroAIDropPod( TEAM_MILITIA, "MCORIntroDP1", 1 )
	delaythread( baseTime + 2.5 ) AB_IntroAIDropPod( TEAM_MILITIA, "MCORIntroDP2", 2 )

	local table 	= GetSavedDropEvent( "introDropShipMCOR_1cr" )
	local event1 	= GetSavedDropEvent( "introDropShipMCOR_1e1" )
	local event2 	= GetSavedDropEvent( "introDropShipMCOR_1e2" )
	local dropship1 = SpawnCinematicDropship( table )
	thread RunCinematicDropship( dropship1, event1, event2 )

	local table 	= GetSavedDropEvent( "introDropShipMCOR_2cr" )
	local event1 	= GetSavedDropEvent( "introDropShipMCOR_2e1" )
	local event2 	= GetSavedDropEvent( "introDropShipMCOR_2e2" )
	local dropship2	= SpawnCinematicDropship( table )
	thread RunCinematicDropship( dropship2, event1, event2 )

//	thread DropshipMCORShakes( dropship1 )
//	thread DropshipMCORShakes( dropship2 )

	//HACK: temp because the dropship origin isn't where the dropship is - when anim is fixed - we remove this
	dropship1.SetJetWakeFXEnabled( false )
	dropship2.SetJetWakeFXEnabled( false )

	DebugSkipCinematicSlots( TEAM_MILITIA, 0 )
	//0 - standing front
	//1 - sitting front
	//2 - standing back
	//3 - sitting back

	wait INTROCUSTOMLENGTH_TDM - 23.25
	FlagSet( "MCORStopIdle" )
}

function IntroSetupMilitiaHero()
{
	local introNode = GetEnt( "MCORIntroflyin" )
	//MCOR 1
	////////////////////////////////////////////////////////////
	local idleNode = GetEnt( "mcorIdle1" )

	local create			= CreateCinematicDropship()
	create.origin 			= idleNode.GetOrigin()
	create.team				= TEAM_MILITIA
	create.count 			= 4
	create.side 			= "jumpSideR"

	local event1 			= CreateCinematicEvent()
	event1.origin 			= introNode.GetOrigin()
	event1.angles			= introNode.GetAngles()
	event1.anim				= "dropship_player_intro_idle"
	event1.teleport 		= true
	Event_AddFlagWaitToEnd( event1, "MCORStopIdle")
	Event_AddAnimStartFunc( event1, IntroMCORSoundScape )
	Event_AddServerStateFunc( event1, CE_PlayerSkyScaleMCOR )
	Event_AddClientStateFunc( event1, "CE_VisualSettingAirbaseMCOR" )

	local event2 			= CreateCinematicEvent()
	event2.origin 			= introNode.GetOrigin()
	event2.angles			= introNode.GetAngles()
	event2.anim				= "dropship_airbase_flying2"
	event2.teleport 		= true
	Event_AddAnimStartFunc( event2, Bind( MCORHerosEvent2 ) )

	AddSavedDropEvent( "introDropShipMCOR_1cr", create )
	AddSavedDropEvent( "introDropShipMCOR_1e1", event1 )
	AddSavedDropEvent( "introDropShipMCOR_1e2", event2 )

	//MCOR 2
	////////////////////////////////////////////////////////////
	local idleNode = GetEnt( "mcorIdle2" )

	local create			= CreateCinematicDropship()
	create.origin 			= idleNode.GetOrigin()
	create.team				= TEAM_MILITIA
	create.count 			= 4
	create.side 			= "jumpSideR"

	local event1 			= CreateCinematicEvent()
	event1.origin 			= introNode.GetOrigin()
	event1.angles			= introNode.GetAngles()
	event1.anim				= "dropship_player_intro_idle"
	event1.teleport 		= true
	Event_AddFlagWaitToEnd( event1, "MCORStopIdle")
	Event_AddAnimStartFunc( event1, IntroMCORSoundScape )
	Event_AddServerStateFunc( event1, CE_PlayerSkyScaleMCOR )
	Event_AddClientStateFunc( event1, "CE_VisualSettingAirbaseMCOR" )

	local event2 			= CreateCinematicEvent()
	event2.origin 			= introNode.GetOrigin()
	event2.angles			= introNode.GetAngles()
	event2.anim				= "dropship_airbase_flying1"
	event2.teleport 		= true
	Event_AddAnimStartFunc( event2, Bind( MCORHerosEvent2 ) )

	AddSavedDropEvent( "introDropShipMCOR_2cr", create )
	AddSavedDropEvent( "introDropShipMCOR_2e1", event1 )
	AddSavedDropEvent( "introDropShipMCOR_2e2", event2 )
}

function CE_PlayerSkyScaleMCOR( player, ref )
{
	player.LerpSkyScale( SKYSCALE_AIRBASE_MCOR_PLAYER, 0.01 )
}

function MCORHerosEvent2( dropship, ref, table )
{
	dropship.EndSignal( "OnDeath" )
	dropship.NotSolid()

	local sara 		= CreateGrunt( TEAM_MILITIA, SARAH_MODEL, "", false )//CreatePropDynamic( SARAH_MODEL )
	DispatchSpawn( sara )
	local bish 		= CreatePropDynamic( BISH_MODEL )
	local pilot 	= CreatePropDynamic( PILOT_MODEL )
	local laptop 	= CreatePropDynamic( LAPTOP_MODEL_SMALL )
	local gun 		= CreatePropDynamic( GUN_MODEL )
	gun.Hide()

	pilot.SetParent( dropship, "ORIGIN" )
	sara.SetParent( dropship, "RESCUE" )
	gun.SetParent( sara, "PROPRHAND" )
	bish.SetParent( dropship, "RESCUE" )
	laptop.SetParent( bish, "PROPGUN" )
	dropship.s.laptop 	<- laptop
	AddCustomCinematicRefFunc( dropship, Bind( DoLaptopFxPerPlayer ) )

	pilot.MarkAsNonMovingAttachment()
	sara.MarkAsNonMovingAttachment()
	gun.MarkAsNonMovingAttachment()
	bish.MarkAsNonMovingAttachment()
	laptop.MarkAsNonMovingAttachment()

	dropship.s.children <- {}
	dropship.s.children.bish 	<- bish
	dropship.s.children.sara 	<- sara
	dropship.s.children.pilot 	<- pilot
	dropship.s.children.laptop 	<- laptop
	dropship.s.children.gun 	<- gun

	foreach( obj in dropship.s.children )
	{
		obj.SetTeam( TEAM_MILITIA )
		obj.LerpSkyScale( SKYSCALE_AIRBASE_MCOR_ACTOR, 0.01 )
	}

	AddAnimEvent( sara, "showGun", ShowEnt, gun )
	AddAnimEvent( sara, "hideGun", HideEnt, gun )
	AddAnimEvent( sara, "SkyScaleDefault", SaraSkyScaleDefault )

	thread PlayAnimTeleport( pilot, "MCOR_02_flyin_part1_pilot", dropship, "ORIGIN" )
	thread PlayAnimTeleport( bish, "airbase_militia_intro_bish", dropship, "RESCUE" )
	waitthread PlayAnimTeleport( sara, "airbase_militia_intro_sarah", dropship, "RESCUE" )

	sara.Kill()
}

function SaraSkyScaleDefault( sara )
{
	sara.LerpSkyScale( SKYSCALE_DEFAULT, 0.7 )
}

function ShowEnt( sara, gun )
{
	gun.Show()
}

function HideEnt( sara, gun )
{
	gun.Hide()
}

function IntroMCORSoundScape( dropship, ref, table )
{
	dropship.EndSignal( "OnDeath" )

	PlaySoundToAttachedPlayers( dropship, "Airbase_Scr_MilitaIntro_DropshipFlyinAmb" )

	FlagWait( "GamePlaying" )

	EmitSoundOnEntity( dropship, "Airbase_Scr_MilitaIntro_DropshipFlyaway" )
}

/************************************************************************************************\

##     ## #### ##       #### ######## ####    ###       #### ##    ## ######## ########   #######     ######## ##     ## ######## ########     ###
###   ###  ##  ##        ##     ##     ##    ## ##       ##  ###   ##    ##    ##     ## ##     ##    ##        ##   ##     ##    ##     ##   ## ##
#### ####  ##  ##        ##     ##     ##   ##   ##      ##  ####  ##    ##    ##     ## ##     ##    ##         ## ##      ##    ##     ##  ##   ##
## ### ##  ##  ##        ##     ##     ##  ##     ##     ##  ## ## ##    ##    ########  ##     ##    ######      ###       ##    ########  ##     ##
##     ##  ##  ##        ##     ##     ##  #########     ##  ##  ####    ##    ##   ##   ##     ##    ##         ## ##      ##    ##   ##   #########
##     ##  ##  ##        ##     ##     ##  ##     ##     ##  ##   ###    ##    ##    ##  ##     ##    ##        ##   ##     ##    ##    ##  ##     ##
##     ## #### ######## ####    ##    #### ##     ##    #### ##    ##    ##    ##     ##  #######     ######## ##     ##    ##    ##     ## ##     ##

\************************************************************************************************/

function IntroTitansWalking()
{
	local height = 100

	delaythread( 5.0 ) IntroTitansWalkingSkit( Vector( -3030.873779, 1855.481323, height ), Vector( 0, 0, 0 ), OGRE_MODEL, "at_search_walk_fast" )
	delaythread( 4.7 ) IntroTitansWalkingSkit( Vector( -2852.409912, 1259.906006, height ), Vector( 0, 0, 0 ), ATLAS_MODEL, "at_search_walk_lead" )
	delaythread( 4.5 ) IntroTitansWalkingSkit( Vector( -2507.674316, 1630.221313, height ), Vector( 0, 0, 0 ), ATLAS_MODEL, "at_search_walk_slow" )
}

function IntroTitansWalkingSkit( origin, angles, model, anim )
{
	local table 	= CreateDefaultNPCTitanTemplate( TEAM_IMC )
	table.title 	= ""
	table.origin 	= origin
	table.angles 	= angles
	table.model 	= model

	local titan = SpawnNPCTitan( table )
	titan.SetEfficientMode( true )
	titan.SetLookDist( 1 )
	titan.SetMoveAnim( anim )
	thread GotoOrigin( titan, titan.GetOrigin() + ( titan.GetForwardVector() * 2000 ) )

	wait 10

	titan.Kill()
}

function IntroStratonLanding()
{
	wait 3

	local height 	= 3000
	local rot 		= 90
	local time 		= 14.0

	local node = CreateScriptRef( Vector( 587.5, -1399.5, 700 + height ), Vector( 0, 190 + rot, 0 ) )
	local straton = SpawnAnimatedGunship( node.GetOrigin(), TEAM_IMC )
	straton.SetParent( node )

	node.MoveTo( node.GetOrigin() + Vector( 0, 0, -height ), time, 0, 0 )
	node.RotateTo( node.GetAngles() + Vector( 0, -rot, 0 ), time, 0, 0 )
	thread PlayAnimTeleport( straton, "test_land", node )

	wait 12.25

	straton.Kill()
	node.Kill()
}

function IntroGoblinLiftTakeOff()
{
	local height 	= 300
	local rot 		= -110

	local node = CreateScriptRef( Vector( -563.273, -672.098, 207.003 ), Vector( 0, 180, 0 ) )
	local goblin = SpawnAnimatedDropship( node.GetOrigin(), TEAM_IMC )
	goblin.SetParent( node )
	thread PlayAnimTeleport( goblin, "test_runway_idle", node )

	delaythread( 11.5 )	IntroGoblinFlyAway( goblin, "refueling_sequence_end", node, height, rot )
}

function IntroGoblinTakeOff()
{
	//create a bunch of origins and nodes
	local origins = []
	origins.append( Vector( -5152, -32, 95.9973 ) )
	origins.append( Vector( -4512, -1056, 95.9973 ) )
	origins.append( Vector( -5152, -2080, 95.9973 ) )
	origins.append( Vector( -4512, -3104, 95.9973 ) )

	local nodes = []
	foreach ( origin in origins )
		nodes.append( CreateScriptRef( origin, Vector( 0, 21.5, 0 ) ) )

	delaythread( 2.0 ) 	IntroGoblinTakeOffSkit( nodes[ 0 ], 25, "refueling_sequence_end" )
	delaythread( 2.5 ) 	IntroGoblinTakeOffSkit( nodes[ 1 ], 10, "refueling_sequence_end" )
	delaythread( 0.0 ) 	IntroGoblinTakeOffSkit( nodes[ 2 ], 0, "refueling_sequence_end" )
	delaythread( 3.25 ) IntroGoblinTakeOffSkit( nodes[ 3 ], -10, "refueling_sequence_end" )
}

function IntroGoblinTakeOffSkit( node, rot, anim )
{
	local goblin = SpawnAnimatedDropship( node.GetOrigin(), TEAM_IMC )

	goblin.EndSignal( "OnDeath" )

	OnThreadEnd(
		function() : ( goblin, node )
		{
			if ( IsValid( goblin ) )
				goblin.Kill()

			if ( IsValid( node) )
				node.Kill()
		}
	)

	goblin.SetParent( node )
	thread PlayAnimTeleport( goblin, "test_runway_idle", node )

	wait INTROCUSTOMLENGTH_TDM - 10.5

	IntroGoblinFlyAway( goblin, anim, node, 0, rot )
}

function IntroGoblinFlyAway( goblin, anim, node, height, rot )
{
	thread PlayAnim( goblin, "test_takeoff", node )

	wait 3.75
	local time = 3.6
	node.MoveTo( node.GetOrigin() + Vector( 0, 0, height ), time, time * 0.5, time * 0.5 )
	node.RotateTo( node.GetAngles() + Vector( 0, rot, 0 ), time, time * 0.5, time * 0.5 )

	goblin.WaittillAnimDone()
	goblin.ClearParent()

	wait 0.5

	local origin = HackGetDeltaToRef( goblin.GetOrigin(), goblin.GetAngles(), goblin, anim )

	waitthread PlayAnim( goblin, anim, origin, goblin.GetAngles(), 1.0 )
}