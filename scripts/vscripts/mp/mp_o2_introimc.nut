const IMC_DP_YAW = -26.5//pauls maya file has -26.5
const IMC_TRANSITION_YAW = -20

function main()
{
	FlagInit( "IntroGoIMC" )
	FlagInit( "IMC_IntroDone" )
	FlagInit( "IMCEnterTube" )
	FlagInit( "IMCDropPodsEnterAtmos" )
	FlagInit( "IMC_deletedDPs" )
	FlagInit( "IMCDropPodsFakeTravel" )
	FlagInit( "IMCDropPodLaunchTube" )
	FlagInit( "imc_intro_dp_node1" )
	FlagInit( "imc_intro_dp_node2" )
	FlagInit( "IMCTimingGo" )
	FlagInit( "IMC_InAtmosphere" )
	FlagInit( "RenderWithViewModelsNow" )

	Globalize( O2_IntroIMCMain )
	Globalize( DEV_IMCIntroStart )

	RegisterSignal( "DEV_IMCIntroStart" )
	PrecacheModel( TEAM_IMC_CAPTAIN_MDL )

	level.imcArmadaForward <- true
}

function O2_IntroIMCMain()
{
	IntroSetupIMCHeroDropPod()
	thread IntroIMCDropPod()
}

/************************************************************************************************\

 ######  ######## ######## ##     ## ########
##    ## ##          ##    ##     ## ##     ##
##       ##          ##    ##     ## ##     ##
 ######  ######      ##    ##     ## ########
      ## ##          ##    ##     ## ##
##    ## ##          ##    ##     ## ##
 ######  ########    ##     #######  ##

\************************************************************************************************/

function IntroSetupIMCHeroDropPod()
{
	//IMC 1
	////////////////////////////////////////////////////////////
	local launchOrigin = Vector( 96.0, 11640.0, -8296.0 )
	local launchAngles = Vector( 0, 60, 0 )
	local idlenode 			= GetEnt( "imc_intro_dp_node2" )
	local dropnode 			= GetEnt( "imc_intro_dropnode2" )
	dropnode.SetOrigin( dropnode.GetOrigin() + Vector( 0,0,16 ) )

	local spawnOrigin		= Vector( 0,100,0 )
	local spawnAngles		= Vector( 0,0,0 )

	local create			= CreateCinematicRef()
	create.origin 			= spawnOrigin
	create.angles 			= spawnAngles
	create.team				= TEAM_IMC
	create.count 			= 3
	create.style 			= "dpBridgeL"

	local event0 			= CreateCinematicEvent()
	event0.origin 			= spawnOrigin
	event0.yaw	 			= spawnAngles.y
	event0.anim				= "dp_droppod_ready"
	event0.teleport 		= true
	event0.skycam			= "skybox_cam_introRot"
	Event_AddFlagWaitToEnd( event0, "IMCTimingGo" )
	Event_AddAnimStartFunc( event0, LoudSpeakerDialogue )
	Event_AddAnimStartFunc( event0, IntroIMCSoundScapeStart )

	local event1 			= CreateCinematicEvent()
	event1.origin 			= idlenode.GetOrigin()
	event1.yaw	 			= idlenode.GetAngles().y
	event1.anim				= "dp_droppod_ready"
	event1.teleport 		= true
	event1.skycam			= "skybox_cam_introRot"
	Event_AddAnimStartFunc( event1, DropPodAIPart1 )
	Event_AddAnimStartFunc( event1, Bind( IntroIMCLiftAnim ) )
	Event_AddAnimStartFunc( event1, IntroIMCDialoguePreLaunch )
	Event_AddAnimStartFunc( event1, IntroIMCSoundScapeReady )
	Event_AddClientStateFunc( event1, "CE_O2VisualSettingsSpaceIMC" )
	Event_AddFlagWaitToEnd( event1, "IMCDropPodLaunchTube" )
	Event_AddServerStateFunc( event1, CE_PlayerSkyScaleO2OnRampCloseIMC )
	Event_AddClientStateFunc( event1, "CE_O2SkyScaleShipOnRampClose" )

	local event2 			= CreateCinematicEvent()
	event2.origin 			= launchOrigin
	event2.yaw				= launchAngles.y
	event2.anim				= "dp_droppod_idle"
	event2.teleport 		= true
	event2.skycam 			= "skybox_cam_introDP"
	Event_AddAnimStartFunc( event2, DropPodAIPart2 )
	Event_AddAnimStartFunc( event2, IntroIMCDropPodLaunch )
	Event_AddAnimStartFunc( event2, IntroIMCDialogueLaunch )
	Event_AddClientStateFunc( event2, "CE_O2VisualSettingsTransition" )
	Event_AddFlagSetOnStart( event2, "imc_intro_dp_node2" )
	Event_AddFlagWaitToEnd( event2, "IMCDropPodsEnterAtmos" )
	Event_AddServerStateFunc( event2, CE_PlayerSkyScaleO2EnterAtmosIMC )
	Event_AddClientStateFunc( event2, "CE_O2SkyScaleShipEnterAtmos" )
	Event_AddServerStateFunc( event2, CE_RenderWithViewmodels )
	Event_AddAnimStartFunc( event2, RenderDropPodWithViewModels )

	local event3 			= CreateCinematicEvent()
	event3.origin 			= dropnode.GetOrigin() + Vector( -30,0,0 )
	event3.yaw				= IMC_DP_YAW//dropnode.GetAngles().y
	event3.anim				= "dp_O2_IMC_hotdrop"
	event3.teleport 		= true
	event3.skycam			= SKYBOXLEVEL
	Event_AddAnimStartFunc( event3, DropPodAIPart3 )
	Event_AddAnimStartFunc( event3, Bind( IntroIMCOnImpactHack ) )
	Event_AddAnimStartFunc( event3, IntroIMCDialogueAtmos )
	Event_AddClientStateFunc( event3, "CE_O2VisualSettingsWorldIMC" )
	Event_AddServerStateFunc( event3, CE_PlayerSkyScaleO2WorldIMC )
	Event_AddFlagSetOnStart( event3, "IMC_InAtmosphere" )
	Event_AddFlagSetOnEnd( event3, "IMC_IntroDone" )

	local event4			= CreateCinematicEvent()
	event4.origin 			= dropnode.GetOrigin()
	event4.yaw				= dropnode.GetAngles().y
	event4.anim				= "dp_droppod_drop"
	Event_AddAnimStartFunc( event4, Bind( DropPodAIPart4 ) )
	Event_AddFlagWaitToEnd( event4, "IMC_deletedDPs" )
	Event_AddClientStateFunc( event4, "CE_O2BloomOnRampOpenIMC" )
	Event_AddServerStateFunc( event4, CE_PlayerSkyScaleO2OnRampOpenIMC )


	AddSavedDropEvent( "introDropPodIMC_1cr", create )
	AddSavedDropEvent( "introDropPodIMC_1e0", event0 )
	AddSavedDropEvent( "introDropPodIMC_1e1", event1 )
	AddSavedDropEvent( "introDropPodIMC_1e2", event2 )
	AddSavedDropEvent( "introDropPodIMC_1e3", event3 )
	AddSavedDropEvent( "introDropPodIMC_1e4", event4 )

	//IMC 2
	////////////////////////////////////////////////////////////
	local launchOrigin = Vector( -96.0, 11640.0, -8296.0 )
	local launchAngles = Vector( 0, 60, 0 )
	local idlenode 			= GetEnt( "imc_intro_dp_node1" )
	local dropnode 			= GetEnt( "imc_intro_dropnode1" )
	dropnode.SetOrigin( dropnode.GetOrigin() + Vector( 0,0,16 ) )

	local spawnOrigin		= Vector( 0,-100,0 )
	local spawnAngles		= Vector( 0,0,0 )

	local create			= CreateCinematicRef()
	create.origin 			= spawnOrigin
	create.angles 			= spawnAngles
	create.team				= TEAM_IMC
	create.count 			= 3
	create.style 			= "dpBridgeR"

	local event0 			= CreateCinematicEvent()
	event0.origin 			= spawnOrigin
	event0.yaw	 			= spawnAngles.y
	event0.anim				= "dp_droppod_ready"
	event0.teleport 		= true
	event0.skycam			= "skybox_cam_introRot"
	Event_AddFlagWaitToEnd( event0, "IMCTimingGo" )
	Event_AddAnimStartFunc( event0, LoudSpeakerDialogue )
	Event_AddAnimStartFunc( event0, IntroIMCSoundScapeStart )

	local event1 			= CreateCinematicEvent()
	event1.origin 			= idlenode.GetOrigin()
	event1.yaw	 			= idlenode.GetAngles().y
	event1.anim				= "dp_droppod_ready"
	event1.teleport 		= true
	event1.skycam			= "skybox_cam_introRot"
	Event_AddAnimStartFunc( event1, DropPodAIPart1 )
	Event_AddAnimStartFunc( event1, Bind( IntroIMCLiftAnim ) )
	Event_AddAnimStartFunc( event1, IntroIMCDialoguePreLaunch )
	Event_AddAnimStartFunc( event1, IntroIMCSoundScapeReady )
	Event_AddClientStateFunc( event1, "CE_O2VisualSettingsSpaceIMC" )
	Event_AddFlagWaitToEnd( event1, "IMCDropPodLaunchTube" )
	Event_AddServerStateFunc( event1, CE_PlayerSkyScaleO2OnRampCloseIMC )
	Event_AddClientStateFunc( event1, "CE_O2SkyScaleShipOnRampClose" )

	local event2 			= CreateCinematicEvent()
	event2.origin 			= launchOrigin
	event2.yaw				= launchAngles.y
	event2.anim				= "dp_droppod_idle"
	event2.teleport 		= true
	event2.skycam 			= "skybox_cam_introDP"
	Event_AddAnimStartFunc( event2, DropPodAIPart2 )
	Event_AddAnimStartFunc( event2, IntroIMCDropPodLaunch )
	Event_AddAnimStartFunc( event2, IntroIMCDialogueLaunch )
	Event_AddClientStateFunc( event2, "CE_O2VisualSettingsTransition" )
	Event_AddFlagSetOnStart( event2, "imc_intro_dp_node1" )
	Event_AddFlagWaitToEnd( event2, "IMCDropPodsEnterAtmos" )
	Event_AddServerStateFunc( event2, CE_PlayerSkyScaleO2EnterAtmosIMC )
	Event_AddClientStateFunc( event2, "CE_O2SkyScaleShipEnterAtmos" )
	Event_AddServerStateFunc( event2, CE_RenderWithViewmodels )
	Event_AddAnimStartFunc( event2, RenderDropPodWithViewModels )

	local event3 			= CreateCinematicEvent()
	event3.origin 			= dropnode.GetOrigin()
	event3.yaw				= IMC_DP_YAW//dropnode.GetAngles().y
	event3.anim				= "dp_O2_IMC_hotdrop"
	event3.teleport 		= true
	event3.skycam			= SKYBOXLEVEL
	Event_AddAnimStartFunc( event3, DropPodAIPart3 )
	Event_AddAnimStartFunc( event3, Bind( IntroIMCOnImpactHack ) )
	Event_AddAnimStartFunc( event3, IntroIMCDialogueAtmos )
	Event_AddClientStateFunc( event3, "CE_O2VisualSettingsWorldIMC" )
	Event_AddServerStateFunc( event3, CE_PlayerSkyScaleO2WorldIMC )
	Event_AddFlagSetOnStart( event3, "IMC_InAtmosphere" )
	Event_AddFlagSetOnEnd( event3, "IMC_IntroDone" )

	local event4			= CreateCinematicEvent()
	event4.origin 			= dropnode.GetOrigin()
	event4.yaw				= dropnode.GetAngles().y
	event4.anim				= "dp_droppod_drop"
	Event_AddAnimStartFunc( event4, Bind( DropPodAIPart4 ) )
	Event_AddFlagWaitToEnd( event4, "IMC_deletedDPs" )
	Event_AddClientStateFunc( event4, "CE_O2BloomOnRampOpenIMC" )
	Event_AddServerStateFunc( event4, CE_PlayerSkyScaleO2OnRampOpenIMC )


	AddSavedDropEvent( "introDropPodIMC_2cr", create )
	AddSavedDropEvent( "introDropPodIMC_2e0", event0 )
	AddSavedDropEvent( "introDropPodIMC_2e1", event1 )
	AddSavedDropEvent( "introDropPodIMC_2e2", event2 )
	AddSavedDropEvent( "introDropPodIMC_2e3", event3 )
	AddSavedDropEvent( "introDropPodIMC_2e4", event4 )
}

function RenderDropPodWithViewModels( pod, ref, table )
{
	FlagWait( "RenderWithViewModelsNow" )
	local captain = pod.s.captain
	pod.SetTeam( TEAM_IMC )
	pod.s.door.SetTeam( TEAM_IMC )
	captain.SetTeam( TEAM_IMC )

	pod.RenderWithViewModels( true )
	pod.s.door.RenderWithViewModels( true )
	captain.RenderWithViewModels( true )
	pod.kv.VisibilityFlags = 2 //Only friendlies can see this
	pod.s.door.kv.VisibilityFlags = 2 //Only friendlies can see this
	captain.kv.VisibilityFlags = 2 //Only friendlies can see this


	FlagWaitClear( "RenderWithViewModelsNow" )

	pod.RenderWithViewModels( false )
	pod.s.door.RenderWithViewModels( false )
	captain.RenderWithViewModels( false )
	pod.kv.VisibilityFlags = 7 //All can see
	pod.s.door.kv.VisibilityFlags = 7 //All can see
	captain.kv.VisibilityFlags = 7 //All can see
}

function CE_RenderWithViewmodels( player, dropship )
{
	if ( Flag( "IMC_deletedDPs" ) )
		return
	FlagEnd( "IMC_deletedDPs" )

	player.EndSignal( "Disconnected" )

	FlagWait( "RenderWithViewModelsNow" )

	player.RenderWithViewModels( true )
	player.kv.VisibilityFlags = 2 //Only friendlies can see this
	if ( IsPlayer( player ) )
		player.GetFirstPersonProxy().RenderWithViewModels( true )

	FlagWaitClear( "RenderWithViewModelsNow" )

	player.RenderWithViewModels( false )
	player.kv.VisibilityFlags = 7 //All can see
	if ( IsPlayer( player ) )
		player.GetFirstPersonProxy().RenderWithViewModels( false )
}

function CE_PlayerSkyScaleO2EnterAtmosIMC( player, dropship )
{
	player.EndSignal( "Disconnected" )

	wait SKYSCALE_EJECT_TIME
	player.LerpSkyScale( SKYSCALE_O2_EJECT_IMC_PLAYER, 0.2 )

	wait SKYSCALE_O2_FIRE_BUILDUP_TIME - SKYSCALE_EJECT_TIME
	player.LerpSkyScale( SKYSCALE_O2_FIRE_IMC_PLAYER, 2.0 )
}

function CE_PlayerSkyScaleO2OnRampOpenIMC( player, dropship )
{
	thread playerLerpSkyScaleOnSignal( player, dropship, "sRampOpen", SKYSCALE_DEFAULT, 1 )
}

function CE_PlayerSkyScaleO2OnRampCloseIMC( player, dropship )
{
	thread playerLerpSkyScaleOnSignal( player, dropship, "sRampClose", SKYSCALE_O2_DOORCLOSE_IMC_PLAYER, 1 )
}

function CE_PlayerSkyScaleO2WorldIMC( player, dropship )
{
	player.EndSignal( "Disconnected" )

	wait 2.0
	player.LerpSkyScale( SKYSCALE_O2_IMC_PLAYER, 2.0 )
}


/************************************************************************************************\

##     ##    ###    #### ##    ##
###   ###   ## ##    ##  ###   ##
#### ####  ##   ##   ##  ####  ##
## ### ## ##     ##  ##  ## ## ##
##     ## #########  ##  ##  ####
##     ## ##     ##  ##  ##   ###
##     ## ##     ## #### ##    ##

\************************************************************************************************/

function IntroIMCDropPod()
{
	FlagWait( "ReadyToStartMatch" )

	thread IntroIMCDogFights()

	local table 	= GetSavedDropEvent( "introDropPodIMC_1cr" )
	local event0 	= GetSavedDropEvent( "introDropPodIMC_1e0" )
	local event1 	= GetSavedDropEvent( "introDropPodIMC_1e1" )
	local event2 	= GetSavedDropEvent( "introDropPodIMC_1e2" )
	local event3 	= GetSavedDropEvent( "introDropPodIMC_1e3" )
	local event4 	= GetSavedDropEvent( "introDropPodIMC_1e4" )
	local dropPod1 	= SpawnCinematicDropPod( table )
	dropPod1.SetModel( DROPPODO2MODEL )
	SetupLiftModel( dropPod1, "o2_imc_01_IntroLift1", "o2_imc_01_IntroRailing*" )
	thread RunCinematicDropship( dropPod1, event0, event1, event2, event3, event4 )

	local table 	= GetSavedDropEvent( "introDropPodIMC_2cr" )
	local event0 	= GetSavedDropEvent( "introDropPodIMC_2e0" )
	local event1 	= GetSavedDropEvent( "introDropPodIMC_2e1" )
	local event2 	= GetSavedDropEvent( "introDropPodIMC_2e2" )
	local event3 	= GetSavedDropEvent( "introDropPodIMC_2e3" )
	local event4 	= GetSavedDropEvent( "introDropPodIMC_2e4" )
	local dropPod2 	= SpawnCinematicDropPod( table )
	dropPod2.SetModel( DROPPODO2MODEL )
	SetupLiftModel( dropPod2, "o2_imc_02_IntroLift1", "o2_imc_02_IntroRailing*" )
	thread RunCinematicDropship( dropPod2, event0, event1, event2, event3, event4 )

	level.IntroRefs[ TEAM_IMC ].append( dropPod1 )
	level.IntroRefs[ TEAM_IMC ].append( dropPod2 )
	DebugSkipCinematicSlots( TEAM_IMC, 0 )
	//0 - front right
	//1 - front left
	//2 - back right
	//3 - back left

	//hack because really a dropship
	dropPod1.SetJetWakeFXEnabled( false )
	dropPod2.SetJetWakeFXEnabled( false )

	wait 4//timing to hault IMC intro
	thread DropPodIMCShakes( dropPod1 )
	thread DropPodIMCShakes( dropPod2 )
	thread DropPodIMCFX( dropPod1 )
	thread DropPodIMCFX( dropPod2 )
	thread IntroIMCWorldRotate()
	thread IntroIMCVillansDropPod()
	thread IntroIMCAramdaFakeDropPodTravel()

	IntroIMCDropPodEventHandler( dropPod1, dropPod2 )
}

function IntroIMCDropPodEventHandler( dropPod1, dropPod2 )
{
	FlagSet( "IMCTimingGo" )
	level.nv.IMCClientTiming = Time()

	FlagWait( "IMCEnterTube" )
	//clear the lift the guys are riding down from the droppod model
	dropPod1.s.liftModel.ClearParent()
	dropPod2.s.liftModel.ClearParent()

	foreach ( piece in dropPod1.s.liftModel.s.pieces )
		piece.ClearParent()
	foreach ( piece in dropPod2.s.liftModel.s.pieces )
		piece.ClearParent()

	FlagWait( "IMCDropPodLaunchTube" )
	level.nv.IMCClientTiming = -1
}

function SetupLiftModel( droppod, liftName, pieceName )
{
	local liftModel = GetEnt( liftName )
	if ( !( "pieces" in liftModel.s ) )
		liftModel.s.pieces <- GetEntArrayByNameWildCard_Expensive( pieceName )

	foreach( piece in liftModel.s.pieces )
	{
		piece.SetParent( liftModel, "", true )
		piece.MarkAsNonMovingAttachment()
	}

	droppod.s.liftModel <- liftModel
}

/************************************************************************************************\

#### ##    ## ######## ########   #######        ##    ## ########   ######
 ##  ###   ##    ##    ##     ## ##     ##       ###   ## ##     ## ##    ##
 ##  ####  ##    ##    ##     ## ##     ##       ####  ## ##     ## ##
 ##  ## ## ##    ##    ########  ##     ##       ## ## ## ########  ##
 ##  ##  ####    ##    ##   ##   ##     ##       ##  #### ##        ##
 ##  ##   ###    ##    ##    ##  ##     ##       ##   ### ##        ##    ##
#### ##    ##    ##    ##     ##  #######        ##    ## ##         ######

\************************************************************************************************/
function IntroIMCVillansDropPod()
{
	thread IntroConsoleGuys()
	thread IntroCrewGuys()
	delaythread( 3.5 ) IntroRunners()

	local node 		= GetEnt( "imc_intro_graves_node" )
	node.SetOrigin( node.GetOrigin() + Vector( 0,-30,-16 ) )
	local graves 	= CreatePropDynamic( GRAVES_MODEL )

	thread PlayAnimTeleport( graves, "gr_O2_briefing", node )

	FlagWait( "IMCDropPodsFakeTravel" )
	graves.Kill()

	FlagWait( "IMC_InAtmosphere" )
	local baseTime = 2.5

	delaythread( baseTime + 0.0 ) O2_IntroAIDropPod( TEAM_IMC, "imc_intro_npcDP_1", 0 )
	delaythread( baseTime + 2.5 ) O2_IntroAIDropPod( TEAM_IMC, "imc_intro_npcDP_2", 1 )
	delaythread( baseTime + 2.0 ) O2_IntroAIDropPod( TEAM_IMC, "imc_intro_npcDP_3", 2 )
}

function LoudSpeakerDialogue( pod, ref, table )
{
	wait 1.5

	//( loudspeaker )Graves to all personnel - Demeter is the gateway to the Frontier.
	PlaySoundToAttachedPlayers( pod, "diag_matchIntro_o2105_01_01_imc_graves" )
	wait 4.5

	//( loudspeaker )By attacking our largest refueling depot, the Militia thinks they can shut the door on us.
	PlaySoundToAttachedPlayers( pod, "diag_matchIntro_o2105_02_01_imc_graves" )
	wait 5

	//( loudspeaker )You will correct that perspective. Graves out.
	PlaySoundToAttachedPlayers( pod, "diag_matchIntro_o2105_03_01_imc_graves" )
	wait 3
}

function O2_IntroAIDropPod( team, dropNode, index )
{
	local node = GetEnt( dropNode )
	local numGuys = GetCPULevelWrapper() == CPU_LEVEL_HIGHEND ? 4 : 3
	local squad = Spawn_ScriptedTrackedDropPodGruntSquad( team, numGuys, node.GetOrigin(), node.GetAngles(), "IntroSquadTeam_" + team + "_" + index )

	ScriptedSquadAssault( squad, index )
}

function IntroRunners()
{
	local goal 		= Vector( -2122, 12895, -7580 )
	local angles 	= Vector( 0,0,0 )

	local origin 	= Vector( 675, 11455, -7580 )
	local guy1 = SpawnGrunt( TEAM_IMC, "nothing", origin, angles )
	guy1.SetEfficientMode( true )
	guy1.SetLookDist( 1 )
	thread GotoOrigin( guy1, goal )

	wait 0.25

	local origin 	= Vector( 700, 11480, -7580 )
	local guy2 = SpawnGrunt( TEAM_IMC, "nothing", origin, angles )
	guy2.SetEfficientMode( true )
	guy2.SetLookDist( 1 )
	thread GotoOrigin( guy2, goal )

	FlagWait( "IMCDropPodsFakeTravel" )
	guy1.Kill()
	guy2.Kill()
}

function IntroCrewGuys()
{
	local crewGuys = []

	local node = GetEnt( "imc_intro_crew1" )
	local guy = CreatePropDynamic( TEAM_IMC_GRUNT_MDL )
	crewGuys.append( guy )

	thread PlayAnimTeleport( guy, "pt_O2_briefing_crew_L", node )

	local node = GetEnt( "imc_intro_crew2" )
	local guy = CreatePropDynamic( TEAM_IMC_GRUNT_MDL )
	crewGuys.append( guy )

	thread PlayAnimTeleport( guy, "pt_O2_briefing_crew_R", node )

	FlagWait( "IMCDropPodsFakeTravel" )
	foreach( guy in crewGuys )
		guy.Kill()
}

function IntroConsoleGuys()
{
	local consoleGuys = []
	local nodes 	= GetEntArrayByNameWildCard_Expensive( "imc_intro_console*" )
	foreach( node in nodes )
	{
		node.SetOrigin( node.GetOrigin() + Vector( 0,0,-8 ) )
		local guy = CreatePropDynamic( TEAM_IMC_GRUNT_MDL )
		thread PlayAnimTeleport( guy, "pt_console_idle", node )
		consoleGuys.append( guy )
	}

	FlagWait( "IMCDropPodsFakeTravel" )
	foreach( guy in consoleGuys )
		guy.Kill()
}

/************************************************************************************************\

########  ########   #######  ########        ########   #######  ########   ######
##     ## ##     ## ##     ## ##     ##       ##     ## ##     ## ##     ## ##    ##
##     ## ##     ## ##     ## ##     ##       ##     ## ##     ## ##     ## ##
##     ## ########  ##     ## ########        ########  ##     ## ##     ##  ######
##     ## ##   ##   ##     ## ##              ##        ##     ## ##     ##       ##
##     ## ##    ##  ##     ## ##              ##        ##     ## ##     ## ##    ##
########  ##     ##  #######  ##              ##         #######  ########   ######

\************************************************************************************************/
function IntroIMCLiftAnim( droppod, ref, table )
{
	wait 0.1
	droppod.SetParent( ref, "", true )
	droppod.s.door <- CreateDropPodDoor( droppod )
	droppod.s.door.MarkAsNonMovingAttachment()

	local liftModel = droppod.s.liftModel
	liftModel.SetOrigin( liftModel.GetOrigin() + Vector( 0,0,768 ) )
	liftModel.SetParent( droppod, "TurretAttach", true )
	foreach ( piece in liftModel.s.pieces )
	{
		piece.SetParent( droppod, "TurretAttach", true )
		piece.MarkAsNonMovingAttachment()
	}


	//create the entity that will move the droppod
	local attachID 	= droppod.LookupAttachment( "ATTACH" )
	local node = CreateScriptMover( droppod )
	droppod.s.moverNode <- node
	node.SetOrigin( droppod.GetOrigin() )
	node.SetAngles( droppod.GetAttachmentAngles( attachID ) )
	ref.SetParent( node, "", true, 0.0 )

	delaythread( 20 ) FlagSet( "IMCEnterTube" )
	wait 23.5//timed out to look good

	IntroIMCDropPodTubeAnim( droppod, ref, table )
}

function IntroIMCDropPodTubeAnim( droppod, ref, table )
{
	droppod.EndSignal( "OnDeath" )

	local node = droppod.s.moverNode

	//move down into blasting position
	local time = 3.0
	local anglesTube = Vector( 0, 60, 0 )
	node.RotateTo( anglesTube, time, time * 0.1, 0 )
	node.MoveTo( node.GetOrigin() + Vector( 0,0,-200 ), time, time * 0.1, 0 )

	wait time

	//abrupt stop
	local radius = 400
	local shake, amplitude, frequency, duration
	amplitude 	= 4.0
	frequency 	= 35
	duration 	= 0.5
	shake = CreateShake( droppod.GetOrigin(), amplitude, frequency, duration, radius )

	wait 2.0
	ref.ClearParent()

	waitthread PrelaunchShake( droppod, ref, table )

	FlagSet( "IMCDropPodLaunchTube" )
}

function PrelaunchShake( droppod, ref, table )
{
	local skyTable = clone table
	skyTable.skycam = "skybox_cam_introDP"
	ChangeSkyCam( droppod, skyTable )

	CallFuncForAttachedPlayers( droppod, "CE_O2VisualSettingsTransition", 0, 0 )

	local radius = 400
	local shake, amplitude, frequency, duration
	amplitude 	= 1.0
	frequency 	= 15
	duration 	= 0.75

	for ( local i = 0; i < 8; i++ )
	{
		shake = CreateShake( droppod.GetOrigin(), amplitude, frequency, duration, radius )
		amplitude += 1.0
		frequency += 15.0
		wait 0.3
	}
}

function IntroIMCDropPodLaunch( droppod, ref, table )
{
	FlagSet( "IMCDropPodsFakeTravel" )

	local attachID 	= droppod.LookupAttachment( "ATTACH" )
	local node = droppod.s.moverNode

	ref.SetParent( node )

	local tubeTime = 1.0
	local travelTime = 3.0
	local offsetTime = 4.0
	local offsetDistZ, offsetDistY
	//hack
	//lets take it for a ride
	switch( Event_GetFlagSetOnStartArray( table )[ 0 ] )
	{
		case "imc_intro_dp_node1":
			offsetDistZ = Vector( 0,0,-1700 )
			offsetDistY = Vector( 75,-200,0 )
			break

		case "imc_intro_dp_node2":
			offsetDistZ = Vector( 0,0, -2100 )
			offsetDistY = Vector( -75,200,0 )
			break
	}

	node.MoveTo( node.GetOrigin() + offsetDistZ, travelTime, 0.0,0 )
	node.RotateTo( node.GetAngles() + Vector( 0,90,0 ), travelTime, travelTime,0 )
	wait tubeTime

	local dummy = CreatePropDynamic( DROPPOD_MODEL, Vector( 0,0,0 ), Vector( 0,IMC_DP_YAW,0 ) )
	dummy.Hide()
	local anim 		= "dp_O2_IMC_hotdrop"
	local start 	= dummy.Anim_GetAttachmentAtTime( anim, "ATTACH", 0.0 )
	dummy.Destroy()

	local curAngles = droppod.GetAttachmentAngles( attachID )

	local endAngles = start.angle
	local delta 	= endAngles - curAngles
	local rotate 	= Vector( delta.x * 0.25, 	75, 							delta.z * 0.25 )
	local lookAngle = Vector( delta.x * 0.66, 	delta.y + IMC_TRANSITION_YAW,	delta.z * 0.66 )
	local ogAngles 	= node.GetAngles()

	local blendTime = 0.1

	local time = ( IMC_TRANSITION_TIME * 0.333 ) + blendTime

	node.RotateTo( ogAngles + rotate, time - tubeTime, 0, 0 )
	wait time - tubeTime - blendTime

	node.MoveTo( node.GetOrigin() + offsetDistY, offsetTime, offsetTime * 0.5, offsetTime * 0.5 )
	node.RotateTo( ogAngles + lookAngle, time, 0, 0 )
	wait time - blendTime

	node.RotateTo( ogAngles + delta, time, 0, time * 0.25 )
	wait time - blendTime

	ref.ClearParent()
	node.Kill()

	FlagSet( "IMCDropPodsEnterAtmos" )
}

function IntroIMCOnImpactHack( droppod, ref, table )
{
	droppod.WaitSignal( "OnImpact" )
	OnDropPodImpactO2( droppod )
	droppod.NotSolid()
	wait 10

	if ( IsValid( droppod ) )
		DefensiveFreePlayers( droppod )

	CleanupFireteamPod( droppod )
	wait 10
	FlagSet( "IMC_deletedDPs" )
}

function DropPodIMCFX( droppod )
{
	//maybe play effect on door closing? play on anim anyway
	//ClientStylePlayFXOnEntity( FX_DROPPOD_STEAM, droppod, "HATCH" )

	FlagWait( "IMCDropPodsFakeTravel" )

	//release from tube
	local fx = PlayFXOnEntity( FX_DROPPOD_LAUNCH, droppod, "HATCH" )

	wait IMC_TRANSITION_TIME - IMC_ENTER_ATMOS_FX_TIME
	KillEffect( fx )

	//start to enter atmosphere
	local fx = PlayFXOnEntity( FX_DROPPOD_REENTRY, droppod, "HATCH" )
	delaythread( 0.2 ) FlagSet( "RenderWithViewModelsNow" )
	wait 7
	KillEffect( fx )

	local fx = PlayFXOnEntity( FX_DROPPOD_REENTRY2, droppod, "HATCH" )

	//hit the ground - eventually move this to anim
	droppod.WaitSignal( "OnImpact" )
	KillEffect( fx )
	ClientStylePlayFXOnEntity( FX_DROPPOD_STEAM, droppod, "HATCH" )
	delaythread( 1.5 ) FlagClear( "RenderWithViewModelsNow" )
}

function KillEffect( FX )
{
	if ( IsValid_ThisFrame( FX ) )
		FX.Kill()
}

/************************************************************************************************\

########  ########   #######  ########        ########   #######  ########           ###    ####
##     ## ##     ## ##     ## ##     ##       ##     ## ##     ## ##     ##         ## ##    ##
##     ## ##     ## ##     ## ##     ##       ##     ## ##     ## ##     ##        ##   ##   ##
##     ## ########  ##     ## ########        ########  ##     ## ##     ##       ##     ##  ##
##     ## ##   ##   ##     ## ##              ##        ##     ## ##     ##       #########  ##
##     ## ##    ##  ##     ## ##              ##        ##     ## ##     ##       ##     ##  ##
########  ##     ##  #######  ##              ##         #######  ########        ##     ## ####

\************************************************************************************************/
function DropPodAIPart1( pod, ref, table )
{
	local sequence = GetAnimGroupSequences( pod.s.style, 3 )[ 1 ]
	local model, weapon, name

	switch ( sequence.thirdPersonAnim )
	{
		case "pt_droppod_ready_back_L":
			model = BLISK_MODEL
			weapon = "mp_weapon_car"
			name = "#NPC_SGT_BLISK"
			break

		case "pt_droppod_ready_back_R":
			model = TEAM_IMC_CAPTAIN_MDL
			weapon = "mp_weapon_rspn101"
			name = "#NPC_CAPTAIN_VAUGHAN"
			break
	}


	local captain = CreateGrunt( TEAM_IMC, model, weapon, false )
	captain.SetOrigin( pod.GetOrigin() )
	captain.SetAngles( pod.GetAngles() )
	DispatchSpawn( captain, true )
	captain.SetEfficientMode( true )
	captain.SetTitle( name )

	pod.s.captain <- captain

	captain.SetParent( pod, sequence.attachment )
	thread PlayAnimTeleport( captain, sequence.thirdPersonAnim, pod, sequence.attachment )

	pod.WaitSignal( "sRampClose" )
	captain.LerpSkyScale( SKYSCALE_O2_DOORCLOSE_IMC_ACTOR, 1 )
}

function DropPodAIPart2( pod, ref, table )
{
	local captain = pod.s.captain
	local sequence = GetAnimGroupSequences( pod.s.style, 3 )[ 2 ]
	thread PlayAnim( captain, sequence.thirdPersonAnim, pod, sequence.attachment )

	wait SKYSCALE_EJECT_TIME
	captain.LerpSkyScale( SKYSCALE_O2_EJECT_IMC_ACTOR, 0.2 )

	wait SKYSCALE_O2_FIRE_BUILDUP_TIME - SKYSCALE_EJECT_TIME
	captain.LerpSkyScale( SKYSCALE_O2_FIRE_IMC_ACTOR, 2.0 )
}

function DropPodAIPart3( pod, ref, table )
{
	local captain = pod.s.captain
	local sequence = GetAnimGroupSequences( pod.s.style, 3 )[ 3 ]
	thread PlayAnim( captain, sequence.thirdPersonAnim, pod, sequence.attachment )

	wait 2.0
	captain.LerpSkyScale( SKYSCALE_O2_IMC_ACTOR, 2.0 )
}

function DropPodAIPart4( pod, ref, table )
{
	local captain = pod.s.captain
	thread captainSkyScaleOnLand( pod )
	local sequence = GetAnimGroupSequences( pod.s.style, 3 )[ 4 ]
	wait 0.1
	captain.ClearParent()
	waitthread PlayAnim( captain, sequence.thirdPersonAnim, pod, sequence.attachment )

	captain.SetEfficientMode( false )

	switch ( sequence.thirdPersonAnim )
	{
		//blisk
		case "pt_droppod_exit_back_L":
			thread DropPodAIBlisk( captain )
			break

		case "pt_droppod_exit_back_R":
			thread DroppodAICaptain( captain )
			break
	}
}

function captainSkyScaleOnLand( pod )
{
	local captain = pod.s.captain

	pod.WaitSignal( "sRampOpen" )
	captain.LerpSkyScale( SKYSCALE_DEFAULT, 1 )
}

function DropPodAIBlisk( blisk )
{
	blisk.EndSignal( "OnDeath" )
	waitthread DroppodAICaptain( blisk )

	wait 5.0

	local fade = 2
	local duration = 6

	blisk.SetCloakDuration( fade, duration, fade )
	EmitSoundOnEntity( blisk, "cloak_on" )

	wait 1.75

	blisk.Kill()
}

function DroppodAICaptain( captain )
{
	captain.DisableArrivalOnce( true )

	waitthread GotoOrigin( captain, Vector( -2991, 2758, 3 ) )
	thread GotoOrigin( captain, Vector( -543, 508, 10 ) )
}

/************************************************************************************************\

 ######   #######  ##     ## ##    ## ########         ######   ######     ###    ########  ########
##    ## ##     ## ##     ## ###   ## ##     ##       ##    ## ##    ##   ## ##   ##     ## ##
##       ##     ## ##     ## ####  ## ##     ##       ##       ##        ##   ##  ##     ## ##
 ######  ##     ## ##     ## ## ## ## ##     ##        ######  ##       ##     ## ########  ######
      ## ##     ## ##     ## ##  #### ##     ##             ## ##       ######### ##        ##
##    ## ##     ## ##     ## ##   ### ##     ##       ##    ## ##    ## ##     ## ##        ##
 ######   #######   #######  ##    ## ########         ######   ######  ##     ## ##        ########

\************************************************************************************************/
function IntroIMCSoundScapeStart( pod, ref, table )
{
	PlaySoundToAttachedPlayers( pod, "O2_Scr_IMCIntro_BattleAmb" )
	PlaySoundToAttachedPlayers( pod, "O2_Scr_IMCIntro_LiftAmb" )
}

function IntroIMCSoundScapeReady( pod, ref, table )
{
	AddAnimEvent( pod, "dooropen", 	PlaySoundToAttachedPlayers, "O2_Scr_IMCIntro_PodDoorsOpen" )
	AddAnimEvent( pod, "doorclose", PlaySoundToAttachedPlayers, "O2_Scr_IMCIntro_PodDoorClose" )
	AddAnimEvent( pod, "doorshut", 	PlaySoundToAttachedPlayers, "O2_Scr_IMCIntro_PodDrop" )
	AddAnimEvent( pod, "OnImpact", 	PlaySoundToAttachedPlayers, "O2_Scr_IMCIntro_PodLand" )

	local leftOrigin = CreatePropDynamic( "models/dev/editor_ref.mdl", Vector( 495, 11658, -8100 ) )
	local rightOrigin = CreatePropDynamic( "models/dev/editor_ref.mdl", Vector( -495, 11658, -8100 ) )
	leftOrigin.Hide()
	rightOrigin.Hide()

	wait 17
	PlaySoundToAttachedPlayersOnEnt( pod, leftOrigin, "O2_Scr_IMCIntro_SoldiersRun1" )

	wait 0.5
	PlaySoundToAttachedPlayersOnEnt( pod, rightOrigin, "O2_Scr_IMCIntro_SoldiersRun2" )

	FlagWait( "IMC_IntroDone" )

	leftOrigin.Kill()
	rightOrigin.Kill()
}


/************************************************************************************************\

 ######  ##     ##    ###    ##    ## ########  ######
##    ## ##     ##   ## ##   ##   ##  ##       ##    ##
##       ##     ##  ##   ##  ##  ##   ##       ##
 ######  ######### ##     ## #####    ######    ######
      ## ##     ## ######### ##  ##   ##             ##
##    ## ##     ## ##     ## ##   ##  ##       ##    ##
 ######  ##     ## ##     ## ##    ## ########  ######

\************************************************************************************************/

function DropPodIMCShakes( droppod )
{
	droppod.EndSignal( "OnDeath" )

	local radius = 500
	local shake, amplitude, frequency, duration

	wait 7
	local node = droppod.s.liftModel

	//suggested ship impact
	/*amplitude 	= 2.0
	frequency 	= 10
	duration 	= 4.0
	shake = CreateShake( node.GetOrigin(), amplitude, frequency, duration, radius )
	shake.SetParent( node )
*/
	wait 9.5

	//suggested ship impact
	amplitude 	= 2.0
	frequency 	= 10
	duration 	= 4.0
	shake = CreateShake( node.GetOrigin(), amplitude, frequency, duration, radius )
	shake.SetParent( node )

	FlagWait( "IMCDropPodsFakeTravel" )

	local blastOffDuration = 3.0
	//blast off
	amplitude 	= 4.0
	frequency 	= 60
	duration 	= blastOffDuration
	CallFuncForAttachedPlayers( droppod, "ServerCallback_ScreenShake", amplitude, frequency, duration )

	wait blastOffDuration
	//min rumble
	amplitude 	= 1.0
	frequency 	= 20
	duration 	= 20.0
	CallFuncForAttachedPlayers( droppod, "ServerCallback_ScreenShake", amplitude, frequency, duration )

	local timeToOzone = 5.0
	wait IMC_TRANSITION_TIME - timeToOzone - blastOffDuration
	CallFuncForAttachedPlayers( droppod, "ServerCallback_ScreenShakeOzone" )

	wait timeToOzone
	//min rumble
	amplitude 	= 5
	frequency 	= 20
	duration 	= 5.25
	CallFuncForAttachedPlayers( droppod, "ServerCallback_ScreenShake", amplitude, frequency, duration )

	droppod.WaitSignal( "OnImpact" )
	//impact
	amplitude 	= 8.0
	frequency 	= 25
	duration 	= 1.5
	CallFuncForAttachedPlayers( droppod, "ServerCallback_ScreenShake", amplitude, frequency, duration )
	//shake = CreateShake( droppod.GetOrigin(), amplitude, frequency, duration, radius ) // -> why server shakes not work when parented to dp??
}

/************************************************************************************************\

########  ####    ###    ##        #######   ######   ##     ## ########
##     ##  ##    ## ##   ##       ##     ## ##    ##  ##     ## ##
##     ##  ##   ##   ##  ##       ##     ## ##        ##     ## ##
##     ##  ##  ##     ## ##       ##     ## ##   #### ##     ## ######
##     ##  ##  ######### ##       ##     ## ##    ##  ##     ## ##
##     ##  ##  ##     ## ##       ##     ## ##    ##  ##     ## ##
########  #### ##     ## ########  #######   ######    #######  ########

\************************************************************************************************/

function IntroIMCDialoguePreLaunch( droppod, ref, table )
{
	wait 18.25

	//( Radio chatter: ) Anvil 1 is a go.
	PlaySoundToAttachedPlayersOnEnt( droppod, droppod, "diag_matchIntro_o2106_01_01_imc_flt01" )
	wait 1.5

	//( Radio chatter: ) Anvil 2 standing by.
	PlaySoundToAttachedPlayersOnEnt( droppod, droppod, "diag_matchIntro_o2106_02_01_imc_flt02" )
	wait 1.5

	//( Radio chatter: ) Anvil 3 is good to go.
	PlaySoundToAttachedPlayersOnEnt( droppod, droppod, "diag_matchIntro_o2106_03_01_imc_flt03" )
	wait 1.5

	//( Radio chatter: ) Anvil 4 is a go.
	PlaySoundToAttachedPlayersOnEnt( droppod, droppod, "diag_matchIntro_o2106_04_01_imc_flt04" )
	wait 1.5

	wait 1.0
	//( Radio chatter: ) I hate this part.
	PlaySoundToAttachedPlayersOnEnt( droppod, droppod, "diag_matchIntro_o2106_05_01_imc_flt01" )
	wait 1.5

	//( Radio chatter: ) Try not to throw up. ( sarcastic )
//	PlaySoundToAttachedPlayersOnEnt( droppod, droppod, "diag_matchIntro_o2106_06_01_imc_flt02" )
//	wait 1.5

	//( Radio chatter: ) Cut the chatter. Initiating drop sequence.
	PlaySoundToAttachedPlayersOnEnt( droppod, droppod, "diag_matchIntro_o2106_07_01_imc_flt04" )
	wait 2
}

function IntroIMCDialogueLaunch( droppod, ref, table )
{
	wait 2.5
	//Separation...confirmed.
	PlaySoundToAttachedPlayers( droppod, "diag_matchIntro_o2107_03_01_imc_cpu01" )

	wait 4.0
	//(electronic chime) Recalculating angle of attack.
//	PlaySoundToAttachedPlayers( droppod, "diag_matchIntro_o2107_04_01_imc_cpu01" )

	//wait 2.0
	//Applying course correction: Yaw, 3.15 degrees
	//PlaySoundToAttachedPlayers( droppod, "diag_matchIntro_o2107_05_01_imc_cpu01" )

	wait 5.0
	//(electronic chime) Standby. Approaching shock layer.
	PlaySoundToAttachedPlayers( droppod, "diag_matchIntro_o2107_07_01_imc_cpu01" )

	wait 5.25
	//Aeroshell within acceptable parameters.
	//PlaySoundToAttachedPlayers( droppod, "diag_matchIntro_o2107_08_01_imc_cpu01" )
}

function IntroIMCDialogueAtmos( droppod, ref, table )
{
	wait 2.1
	//Impact in 3, 2, 1, mark.
	PlaySoundToAttachedPlayers( droppod, "diag_matchIntro_o2107_10_01_imc_cpu01" )
}


/************************************************************************************************\

 ######  ##    ## ##    ## ########   #######  ##     ##       ###    ########  ##     ##    ###    ########     ###
##    ## ##   ##   ##  ##  ##     ## ##     ##  ##   ##       ## ##   ##     ## ###   ###   ## ##   ##     ##   ## ##
##       ##  ##     ####   ##     ## ##     ##   ## ##       ##   ##  ##     ## #### ####  ##   ##  ##     ##  ##   ##
 ######  #####       ##    ########  ##     ##    ###       ##     ## ########  ## ### ## ##     ## ##     ## ##     ##
      ## ##  ##      ##    ##     ## ##     ##   ## ##      ######### ##   ##   ##     ## ######### ##     ## #########
##    ## ##   ##     ##    ##     ## ##     ##  ##   ##     ##     ## ##    ##  ##     ## ##     ## ##     ## ##     ##
 ######  ##    ##    ##    ########   #######  ##     ##    ##     ## ##     ## ##     ## ##     ## ########  ##     ##

\************************************************************************************************/
function IntroIMCWorldRotate()
{
	local worldModel = GetEnt( "red_giant_worldmodelRot" )
	worldModel.SetTeam( TEAM_IMC )
	worldModel.kv.VisibilityFlags = 2 //Only friendlies can see this

	local rotator = CreateScriptMover( worldModel )
	rotator.SetAngles( Vector( 0,0,0 ) )
	level.nv.worldRotator = rotator

	worldModel.SetParent( rotator, "", true, 0 )

	local imcLinker 	= GetEnt( "imc_fleet_linker" )
	local mcorLinker 	= GetEnt( "mcor_fleet_linker" )
	imcLinker.SetParent( rotator, "", true, 0 )
	mcorLinker.SetParent( rotator, "", true, 0 )

	local worldFX = GetEntArrayByNameWildCard_Expensive( "IMC_SpaceFX*" )
	foreach( fx in worldFX )
		fx.SetParent( rotator, "", true, 0 )

	local armada = GetEntArrayByNameWildCard_Expensive( "MCOR_skybox_armad*" )
	armada.extend( GetEntArrayByNameWildCard_Expensive( "imc_skybox_carrier*" ) )
	armada.extend( GetEntArrayByNameWildCard_Expensive( "imc_skybox_extra_carrier*" ) )

	foreach( ship in armada )
	{
		ship.SetTeam( TEAM_IMC )
		ship.kv.VisibilityFlags = 2 //Only friendlies can see this
		ship.SetParent( rotator, "", true, 0 )
	}

	local angles = rotator.GetAngles()
	local delta = Vector( 7.5, -7.5, -7.5 )

	rotator.SetAngles( angles - delta )
	wait 0.05

	CalcArmada( armada )
	rotator.SetAngles( angles + delta )

	wait 0.05

	foreach( ship in armada )
	{
		ship.ClearParent()
		ship.MoveTo( ship.s.movePos, 90.0 )
		ship.RotateTo( ship.s.moveAng, 90.0 )
	}

	rotator.RotateTo( angles - delta, 50, 0, 0 )

	//handle the ones that explode
	local ships = GetEntArrayByNameWildCard_Expensive( "MCOR_skybox_armada_exp*" )
	foreach( index, ship in ships )
	{
		local delay = null
		switch( index )
		{
			case 0:
				delay = 8
				break
			case 1:
				delay = 21
				break
		}
		thread ExplodeSpaceShip( delay, ship, TEAM_IMC )
	}

	local ship = GetEnt( "imc_skybox_carriers6" )
		thread ExplodeSpaceShip( 14, ship, TEAM_IMC )

	FlagWait( "IMC_IntroDone" )

	local armada = GetEntArrayByNameWildCard_Expensive( "MCOR_skybox_armad*" )
	armada.extend( GetEntArrayByNameWildCard_Expensive( "imc_skybox_carrier*" ) )
	armada.extend( GetEntArrayByNameWildCard_Expensive( "imc_skybox_extra_carrier*" ) )

	foreach( ship in armada )
		ship.Kill()
}

function CalcArmada( armada )
{
	foreach( ship in armada )
	{
		ship.s.moveAng <- ship.GetAngles()

		switch( ship.GetModelName().tolower() )
		{
			case FLEET_MCOR_ANNAPOLIS_1000X:
				ship.s.movePos <- ( ship.GetOrigin() + ship.GetForwardVector() * 75 )
				break

			case FLEET_MCOR_BIRMINGHAM_1000X:
			case FLEET_MCOR_BIRMINGHAM_1000X_CLUSTERA:
				ship.s.movePos <- ( ship.GetOrigin() + ship.GetForwardVector() * ( 100 + RandomFloat( -25,25 ) ) )
				break

			case FLEET_MCOR_REDEYE_1000X:
			case FLEET_MCOR_REDEYE_1000X_CLUSTERA:
			case FLEET_MCOR_REDEYE_1000X_CLUSTERB:
			case FLEET_MCOR_REDEYE_1000X_CLUSTERC:
				ship.s.movePos <- ( ship.GetOrigin() + ship.GetForwardVector() * ( 125 + RandomFloat( -25,25 ) ) )
				break

			case FLEET_MCOR_CROW_1000X_CLUSTERA:
			case FLEET_MCOR_CROW_1000X_CLUSTERB:
				ship.s.movePos <- ( ship.GetOrigin() + ship.GetForwardVector() * ( 100 + RandomFloat( -25,25 ) ) )
				break

			case FLEET_IMC_CARRIER_1000X:
			case FLEET_IMC_CARRIER_1000X_CLUSTERA:
			case FLEET_IMC_CARRIER_1000X_CLUSTERB:
			case FLEET_IMC_CARRIER_1000X_CLUSTERC:
			case FLEET_IMC_WALLACE_1000x:
			case FLEET_IMC_WALLACE_1000X_CLUSTERA:
			case FLEET_IMC_WALLACE_1000X_CLUSTERB:
			case FLEET_IMC_WALLACE_1000X_CLUSTERC:
				if ( level.imcArmadaForward )
					ship.s.movePos <- ( ship.GetOrigin() + ship.GetForwardVector() * 20 )
				else
					ship.s.movePos <- ( ship.GetOrigin() + ship.GetForwardVector() * -10 )

				level.imcArmadaForward = !level.imcArmadaForward
				break
		}
	}
}

function IntroIMCAramdaFakeDropPodTravel()
{
	FlagWait( "IMCDropPodsFakeTravel" )

	local imcLinker 	= GetEnt( "imc_fleet_linker" )
	local mcorLinker 	= GetEnt( "mcor_fleet_linker" )
	local imcFleetStart = GetEnt( "imc_fleet_start" )
	local mcorFleetStart = GetEnt( "mcor_fleet_start" )
	local imcFleetEnd 	= GetEnt( "imc_fleet_dpEndPos" )
	local mcorFleetEnd 	= GetEnt( "mcor_fleet_dpEndPos" )
	local planet 		= GetEnt( "imcTransitionFakePlanet" )

	imcLinker.ClearParent()
	mcorLinker.ClearParent()
	planet.Hide()

	local mcorArmada 	= GetEntArrayByNameWildCard_Expensive( "MCOR_skybox_armad*" )
	local imcArmada 	= GetEntArrayByNameWildCard_Expensive( "imc_skybox_carrier*" )
	imcArmada.extend( GetEntArrayByNameWildCard_Expensive( "imc_skybox_extra_carrier*" ) )

	foreach( ship in mcorArmada )
		ship.SetParent( mcorLinker, "", true, 0 )
	foreach( ship in imcArmada )
		ship.SetParent( imcLinker, "", true, 0 )

	mcorLinker.SetOrigin( mcorFleetStart.GetOrigin() )
	mcorLinker.SetAngles( mcorFleetStart.GetAngles() )
	imcLinker.SetOrigin( imcFleetStart.GetOrigin() )
	imcLinker.SetAngles( imcFleetStart.GetAngles() )

	local time1 = 8
	local offset = Vector( -20, 20, 100 )

	local passers = GetEntArrayByNameWildCard_Expensive( "imc_entry_armada*" )
	foreach( ship in passers )
	{
		ship.SetOrigin( ship.GetOrigin() + Vector( 5, 0, 0 ) )
		ship.MoveTo( ship.GetOrigin() + offset, time1, time1 * 0.5,0 )
	}

	local time = IMC_TRANSITION_TIME + 0.1
	local rotFrac = 0.75

	local offset = Vector( 0, 0, -100 )
	mcorLinker.MoveTo( mcorFleetEnd.GetOrigin() + offset, time, time, 0 )
	imcLinker.MoveTo( imcFleetEnd.GetOrigin() + offset, time, time, 0 )
	mcorLinker.RotateTo( mcorFleetEnd.GetAngles(), time * rotFrac, 0, time * rotFrac )
	imcLinker.RotateTo( imcFleetEnd.GetAngles(), time * rotFrac, 0, time * rotFrac )

	local ogOrigin 	= planet.GetOrigin()
	local ptStart 	= Vector( 0,0,-300 )
	local ptEnd 	= Vector( 0,10,0 )
	planet.SetOrigin( ogOrigin + ptStart )
	planet.Show()
	planet.MoveTo( ogOrigin + ptEnd, time + 0.1, 0, time * 0.5 )

	wait time1
	foreach( ship in passers )
		ship.Kill()

	FlagWait( "IMCDropPodsEnterAtmos" )

	planet.Kill()
}

/************************************************************************************************\

########   #######   ######         ######## ####  ######   ##     ## ########  ######
##     ## ##     ## ##    ##        ##        ##  ##    ##  ##     ##    ##    ##    ##
##     ## ##     ## ##              ##        ##  ##        ##     ##    ##    ##
##     ## ##     ## ##   ####       ######    ##  ##   #### #########    ##     ######
##     ## ##     ## ##    ##        ##        ##  ##    ##  ##     ##    ##          ##
##     ## ##     ## ##    ##        ##        ##  ##    ##  ##     ##    ##    ##    ##
########   #######   ######         ##       ####  ######   ##     ##    ##     ######

\************************************************************************************************/

function IntroIMCDogFights()
{
	FlagEnd( "IMCDropPodsFakeTravel" )

	OnThreadEnd(
		function() : ( )
		{
			KillTurrets()
		}
	)

	InitTurrets()

	local node = {}
	local target = null

	//test out anim
	/*while( 1 )
	{
		wait 2
		node.origin <- Vector( 0,0,-5000 )
		node.angles <- Vector( -30,0,180 )
		target = CreateDogFight( node.origin, node.angles )
		delaythread( 4 ) SetTurretTarget( target )

		wait 10
	}*/

	wait 1
	node.origin <- Vector( 0,0,-5000 )
	node.angles <- Vector( 0,0,45 )
	target = CreateDogFight( node.origin, node.angles )
	delaythread( 3 ) SetTurretTarget( target )

	wait 5
	node.origin <- Vector( 1500,0,-4500 )
	node.angles <- Vector( -10,-15,180 )
	target = CreateDogFight( node.origin, node.angles )
	delaythread( 3 ) SetTurretTarget( target )

		//no target
		node.origin <- Vector( 600,0,-12000 )
		node.angles <- Vector( -40,180,130 )
		delaythread( 3 ) CreateDogFight( node.origin, node.angles )

	wait 7
	node.origin <- Vector( 0,0,-6000 )
	node.angles <- Vector( 0,0,0 )
	target = CreateDogFight( node.origin, node.angles )
	delaythread( 1.5 ) SetTurretTarget( target )

	wait 5.5
	node.origin <- Vector( 0,300,-9400 )
	node.angles <- Vector( 0,90,0 )
	target = CreateDogFight( node.origin, node.angles )
	delaythread( 2 ) SetTurretTarget( target )

	wait 1.5
	node.origin <- Vector( 0,0,-7000 )
	node.angles <- Vector( -25,0,180 )
	target = CreateDogFight( node.origin, node.angles )
	delaythread( 6 ) SetTurretTarget( target )

		//no target
		node.origin <- Vector( 0,-2000,-8000 )
		node.angles <- Vector( -90,-15,0 )
		delaythread( 4 ) CreateDogFight( node.origin, node.angles )
	/*
	wait 8
	node.origin <- Vector( 0,0,-5000 )
	node.angles <- Vector( -30,0,180 )
	target = CreateDogFight( node.origin, node.angles )
	delaythread( 4 ) SetTurretTarget( target )
		*/
	FlagWait( "IMCDropPodsFakeTravel" )
}

/************************************************************************************************\

######## ##     ## ########  ########  ######## ########  ######
   ##    ##     ## ##     ## ##     ## ##          ##    ##    ##
   ##    ##     ## ##     ## ##     ## ##          ##    ##
   ##    ##     ## ########  ########  ######      ##     ######
   ##    ##     ## ##   ##   ##   ##   ##          ##          ##
   ##    ##     ## ##    ##  ##    ##  ##          ##    ##    ##
   ##     #######  ##     ## ##     ## ########    ##     ######

\************************************************************************************************/

function InitTurrets()
{
	local turrets = GetEntArrayByNameWildCard_Expensive( "turret_IMC_bridge*" )
	foreach ( turret in turrets )
	{
		turret.GiveWeapon( "mp_weapon_mega_turret_aa", [ "O2Bridge" ] )
		turret.SetActiveWeapon( "mp_weapon_mega_turret_aa" )
		turret.s.notitle <- true

		turret.Minimap_Hide( TEAM_IMC, null )
		turret.Minimap_Hide( TEAM_MILITIA, null )

		turret.EnableTurret()
		TurretChangeTeam( turret, TEAM_IMC )
		turret.ClearBossPlayer()

		turret.s.myTarget <- null
	}
}

function KillTurrets()
{
	local turrets = GetEntArrayByNameWildCard_Expensive( "turret_IMC_bridge*" )
	foreach ( turret in turrets )
		turret.Kill()
}

function SetTurretTarget( turretTarget )
{
	if ( !IsValid( turretTarget ) )
		return

	local r = RandomInt( 5, 26 ) * 10
	local g = RandomInt( 5, 26 ) * 10
	local b = RandomInt( 5, 26 ) * 10

	local turrets = GetEntArrayByNameWildCard_Expensive( "turret_IMC_bridge*" )
	foreach ( turret in turrets )
		thread TurretFollowTarget( turret, turretTarget, r, g, b )
}

//HACK
function TurretFollowTarget( turret, turretTarget, r, g, b )
{
	turret.Signal( "NewFollowTarget" )
	turret.EndSignal( "NewFollowTarget" )
	turret.EndSignal( "OnDeath" )

	if( IsValid( turret.s.myTarget ) )
		turret.s.myTarget.Kill()

	turret.s.myTarget = CreateScriptMover( turretTarget )
	turret.SetEnemy( turret.s.myTarget )
	turret.s.myTarget.SetParent( turretTarget )
	turret.s.myTarget.MarkAsNonMovingAttachment()

	local time = 0.2

	while( IsValid( turretTarget ) )
	{
		turret.SetEnemyLKP( turret.s.myTarget, turret.s.myTarget.GetOrigin() )
		//DebugDrawLine( turret.GetOrigin(), turret.s.myTarget.GetOrigin(), r, g, b, true, time )
		wait time
	}
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

function DEV_IMCIntroStart( seat )
{
	level.ent.Signal( "DEV_IMCIntroStart" )
	level.ent.EndSignal( "DEV_IMCIntroStart" )

	DEV_IMCIntroSetup()

	local table 	= GetSavedDropEvent( "introDropPodIMC_1cr" )
	local event0 	= GetSavedDropEvent( "introDropPodIMC_1e0" )
	local event1 	= GetSavedDropEvent( "introDropPodIMC_1e1" )
	local event2 	= GetSavedDropEvent( "introDropPodIMC_1e2" )
	local event3 	= GetSavedDropEvent( "introDropPodIMC_1e3" )
	local event4 	= GetSavedDropEvent( "introDropPodIMC_1e4" )
	local dropPod1 	= SpawnCinematicDropPod( table )
	SetupLiftModel( dropPod1, "o2_imc_01_IntroLift1", "o2_imc_01_IntroRailing*" )
	thread RunCinematicDropship( dropPod1, event0, event1, event2, event3, event4 )

	local table 	= GetSavedDropEvent( "introDropPodIMC_2cr" )
	local event0 	= GetSavedDropEvent( "introDropPodIMC_2e0" )
	local event1 	= GetSavedDropEvent( "introDropPodIMC_2e1" )
	local event2 	= GetSavedDropEvent( "introDropPodIMC_2e2" )
	local event3 	= GetSavedDropEvent( "introDropPodIMC_2e3" )
	local event4 	= GetSavedDropEvent( "introDropPodIMC_2e4" )
	local dropPod2 	= SpawnCinematicDropPod( table )
	SetupLiftModel( dropPod2, "o2_imc_02_IntroLift1", "o2_imc_02_IntroRailing*" )
	thread RunCinematicDropship( dropPod2, event0, event1, event2, event3, event4 )

	DebugSkipCinematicSlots( TEAM_IMC, seat )
	dropPod1.SetJetWakeFXEnabled( false )
	dropPod2.SetJetWakeFXEnabled( false )

	thread IntroIMCVillansDropPod()
	wait 0.1

	DEV_HackAttachPlayer( dropPod1, dropPod2 )

	wait 0.5
	IntroIMCDropPodEventHandler( dropPod1, dropPod2 )
}

function DEV_IMCIntroSetup()
{
	local player = GetPlayerArray()[ 0 ]
	player.ClearParent()
	player.Anim_Stop()
	level.ent.Signal( "closeSpawnWindow" )

	FlagSet( "IMC_deletedDPs" )
	wait 0.1
	FlagClear( "IntroGoIMC" )
	FlagClear( "IMC_IntroDone" )
	FlagClear( "IMCEnterTube" )
	FlagClear( "IMCDropPodsEnterAtmos" )
	FlagClear( "IMC_deletedDPs" )
	FlagClear( "IMCDropPodsFakeTravel" )
	FlagClear( "IMCDropPodLaunchTube" )
	FlagClear( "imc_intro_dp_node1" )
	FlagClear( "imc_intro_dp_node2" )
	FlagClear( "IMCTimingGo" )
	FlagClear( "IMC_InAtmosphere" )

	if ( ( "storedDropEvents" in level ) && ( "introDropPodIMC_1cr" in level.storedDropEvents ) )
		return

	IntroSetupIMCHeroDropPod()

	local event = GetSavedDropEvent( "introDropPodIMC_1e0" )
	event.animStartFunc = []
	local event = GetSavedDropEvent( "introDropPodIMC_2e0" )
	event.animStartFunc = []

	local event = GetSavedDropEvent( "introDropPodIMC_1e1" )
	event.animStartFunc = []
	Event_AddAnimStartFunc( event, Bind( IntroIMCLiftAnim ) )
	local event = GetSavedDropEvent( "introDropPodIMC_2e1" )
	event.animStartFunc = []
	Event_AddAnimStartFunc( event, Bind( IntroIMCLiftAnim ) )

	local event = GetSavedDropEvent( "introDropPodIMC_1e2" )
	event.animStartFunc = []
	Event_AddAnimStartFunc( event, IntroIMCDropPodLaunch )
	local event = GetSavedDropEvent( "introDropPodIMC_2e2" )
	event.animStartFunc = []
	Event_AddAnimStartFunc( event, IntroIMCDropPodLaunch )

	local event = GetSavedDropEvent( "introDropPodIMC_1e3" )
	event.animStartFunc = []
	Event_AddAnimStartFunc( event, Bind( IntroIMCOnImpactHack ) )
	local event = GetSavedDropEvent( "introDropPodIMC_2e3" )
	event.animStartFunc = []
	Event_AddAnimStartFunc( event, Bind( IntroIMCOnImpactHack ) )
}

/************************************************************************************************\

#### ##    ## ######## ########   #######     ########  #######   #######  ##        ######
 ##  ###   ##    ##    ##     ## ##     ##       ##    ##     ## ##     ## ##       ##    ##
 ##  ####  ##    ##    ##     ## ##     ##       ##    ##     ## ##     ## ##       ##
 ##  ## ## ##    ##    ########  ##     ##       ##    ##     ## ##     ## ##        ######
 ##  ##  ####    ##    ##   ##   ##     ##       ##    ##     ## ##     ## ##             ##
 ##  ##   ###    ##    ##    ##  ##     ##       ##    ##     ## ##     ## ##       ##    ##
#### ##    ##    ##    ##     ##  #######        ##     #######   #######  ########  ######

\************************************************************************************************/
function OnDropPodImpactO2( droppod )
{
	PlayFX( HOTDROP_IMPACT_FX_TABLE, droppod.GetOrigin(), droppod.GetAngles() )

	CreateShake( droppod.GetOrigin(), 7, 150, 2, 1500 )
	// No Damage - Only Force
	// Push players
	// Push radially - not as a sphere
	// Test LOS before pushing
	local flags = 15
	local impactOrigin = droppod.GetOrigin() + Vector( 0,0,10 )
	local impactRadius = 512
}