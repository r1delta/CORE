
const WARNING_LIGHT_ON_MODEL	= "models/lamps/warning_light_ON_orange.mdl"
const WARNING_LIGHT_OFF_MODEL 	= "models/lamps/warning_light.mdl"
PrecacheModel( WARNING_LIGHT_ON_MODEL )
PrecacheModel( WARNING_LIGHT_OFF_MODEL )

function main()
{
	if ( reloadingScripts )
		return

	FlagSet( "DogFights" ) // tells flightpath to bake these into the ain

	//FlagSet( "CinematicIntro" )
	FlagSet( "CinematicOutro" )

	GM_AddEndRoundFunc( EndRoundMain )

	//RegisterServerVarChangeCallback( "matchProgress", MatchProgressUpdate )
}

//function MatchProgressUpdate()
//{
//	printt( "MatchProgressUpdate:", level.nv.matchProgress )
//}

function EntitiesDidLoad()
{
	//thread IntroIMC()
	//thread IntroMilitia()
	if ( EvacEnabled() )
	{
		EvacSetup()
	}

	//thread PrisonWarningLightsSetup()

	if ( GetClassicMPMode() )
		delaythread ( CLASSIC_MP_SKYSHOW_DOGFIGHTS_DELAY ) StratonHornetDogfights()

	/////////// bug 75121 ////////

	local trig1 = CreateScriptCylinderTrigger( Vector( -3254.0, -2639.0, 0.0 ), 120.0, 80.0, -420.0 )
	ScriptTriggerEnable( trig1, true )
	AddCallback_ScriptTriggerEnter( trig1, OOBCylinderEntered )
	AddCallback_ScriptTriggerLeave( trig1, OOBCylinderExited )

	local trig2 = CreateScriptCylinderTrigger( Vector( -3126.0, -2938.0, 0.0 ), 400.0, -250.0, -3000.0 )
	ScriptTriggerEnable( trig2, true )
	AddCallback_ScriptTriggerEnter( trig2, OOBCylinderEntered )
	AddCallback_ScriptTriggerLeave( trig2, OOBCylinderExited )

	local mdl1 = CreatePropDynamic( "models/containers/portable_holding_cell.mdl", Vector( -2760.0, -3050.0, -480.0 ), Vector( 0.0, 0.0, 0.0 ), 6 )
	local mdl2 = CreatePropDynamic( "models/containers/portable_holding_cell.mdl", Vector( -3264.0, -2628.4, -276.8 ), Vector( 0.0, -124.0, 0.0 ), 6 )
	local mdl3 = CreatePropDynamic( "models/angel_city/box_small_02.mdl", Vector( 2807.92, -3967.59, -182.985 ), Vector( 0.17514, -27.8427, 0.167999 ), 6 )
	local mdl4 = CreatePropDynamic( "models/angel_city/box_small_01.mdl", Vector( 2815.54, -3980.5, -167.408 ), Vector( -1.07208, -157.469, -0.756121 ), 6 )

	mdl1.MakeInvisible()
	mdl2.MakeInvisible()
	mdl3.MakeInvisible()
	mdl4.MakeInvisible()
}

function OOBCylinderEntered( trigger, player )
{
	EntityOutOfBounds( null, player, null, null )
}

function OOBCylinderExited( trigger, player )
{
	EntityBackInBounds( null, player, null, null )
}

function PrisonWarningLightsSetup()
{
	level.warningLightModels <- GetEntArrayByName_Expensive( "prison_warning_light_ON" )
	Assert( level.warningLightModels.len() )

	foreach ( model in level.warningLightModels )
		model.SetModel( WARNING_LIGHT_OFF_MODEL )
}

function PrisonWarningLightsStart()
{
	level.nv.emergencyLightsState = 1
	foreach ( model in level.warningLightModels )
		model.SetModel( WARNING_LIGHT_ON_MODEL )
}

function IntroIMC()
{
	local create			= CreateCinematicDropship()
	create.origin 			= Vector( 0, 0, 0 )
	create.team				= TEAM_IMC
	create.count 			= 4
	create.side 			= "jump"

	local event1 			= CreateCinematicEvent()
	event1.origin 			= Vector( -6219, -15467, 585 )
	event1.yaw	 			= 80
	event1.anim				= "gd_fracture_flyin_imc_R_intro"
	event1.teleport 		= true
	event1.proceduralLength	= true
	Event_AddClientStateFunc( event1, "CE_VisualSettingsDropshipInterior" )
	Event_AddServerStateFunc( event1, CE_PlayerSkyScaleDropshipInterior )

	local event2 			= CreateCinematicEvent()
	event2.origin 			= Vector( -3056, 1650, 136 )
	event2.yaw				= 90
	event2.anim				= "gd_fracture_flyin_imc_R"
	event2.teleport 		= true
	event2.preAnimFPSClouds = true
	Event_AddClientStateFunc( event2, "CE_BloomOnRampOpen" )
	Event_AddServerStateFunc( event2, CE_PlayerSkyScaleOnRampOpen )

	AddSavedDropEvent( "introDropShipIMC_1cr", create )
	AddSavedDropEvent( "introDropShipIMC_1e1", event1 )
	AddSavedDropEvent( "introDropShipIMC_1e2", event2 )

	////////////////////////////////////////////////////////////

	local create			= CreateCinematicDropship()
	create.origin 			= Vector( 0, 0, 0 )
	create.team				= TEAM_IMC
	create.count 			= 4
	create.side 			= "jump"

	local event1 			= CreateCinematicEvent()
	event1.origin 			= Vector( -10138, -10870, 800 )
	event1.yaw	 			= 50
	event1.anim				= "gd_fracture_flyin_imc_L_intro"
	event1.teleport 		= true
	event1.proceduralLength	= true
	Event_AddClientStateFunc( event1, "CE_VisualSettingsDropshipInterior" )
	Event_AddServerStateFunc( event1, CE_PlayerSkyScaleDropshipInterior )

	local event2 			= CreateCinematicEvent()
	event2.origin 			= Vector( 7579, -6122, -547 )
	event2.yaw				= -45
	event2.anim				= "gd_fracture_flyin_imc_L"
	event2.teleport 		= true
	event2.preAnimFPSClouds = true
	Event_AddClientStateFunc( event2, "CE_BloomOnRampOpen" )
	Event_AddServerStateFunc( event2, CE_PlayerSkyScaleOnRampOpen )

	AddSavedDropEvent( "introDropShipIMC_2cr", create )
	AddSavedDropEvent( "introDropShipIMC_2e1", event1 )
	AddSavedDropEvent( "introDropShipIMC_2e2", event2 )

	////////////////////////////////////////////////////////////

	local table 	= GetSavedDropEvent( "introDropShipIMC_1cr" )
	local event1 	= GetSavedDropEvent( "introDropShipIMC_1e1" )
	local event2 	= GetSavedDropEvent( "introDropShipIMC_1e2" )
	local dropship 	= SpawnCinematicDropship( table )
	thread RunCinematicDropship( dropship, event1, event2 )

	local table 	= GetSavedDropEvent( "introDropShipIMC_2cr" )
	local event1 	= GetSavedDropEvent( "introDropShipIMC_2e1" )
	local event2 	= GetSavedDropEvent( "introDropShipIMC_2e2" )
	local dropship 	= SpawnCinematicDropship( table )
	thread RunCinematicDropship( dropship, event1, event2 )
}

function IntroMilitia()
{
	local create			= CreateCinematicDropship()
	create.origin 			= Vector( 0, 0, 0 )
	create.team				= TEAM_MILITIA
	create.count 			= 4
	create.side 			= "jump"

	local event1 			= CreateCinematicEvent()
	event1.origin 			= Vector( 519, 6053, -10389 )
	event1.yaw	 			= 140
	event1.anim				= "gd_fracture_flyin_imc_L_intro"
	event1.teleport 		= true
	event1.proceduralLength	= true
	event1.skycam			= SKYBOXSPACE
	Event_AddClientStateFunc( event1, "CE_VisualSettingsSpace" )
	Event_AddServerStateFunc( event1, CE_PlayerSkyScaleSpace )

	local event2 			= CreateCinematicEvent()
	event2.origin 			= Vector( -4222, 3333, -656 )
	event2.yaw				= 135
	event2.anim				= "gd_fracture_flyin_imc_L"
	event2.teleport 		= true
	event2.preAnimFPSWarp 	= true
	Event_AddClientStateFunc( event2, "CE_VisualSettingsDropshipInterior" )
	Event_AddClientStateFunc( event2, "CE_BloomOnRampOpen" )
	Event_AddServerStateFunc( event2, CE_PlayerSkyScaleDropshipInterior )
	Event_AddServerStateFunc( event2, CE_PlayerSkyScaleOnRampOpen )

	AddSavedDropEvent( "introDropShipMCOR_1cr", create )
	AddSavedDropEvent( "introDropShipMCOR_1e1", event1 )
	AddSavedDropEvent( "introDropShipMCOR_1e2", event2 )

	////////////////////////////////////////////////////////////

	local create			= CreateCinematicDropship()
	create.origin 			= Vector( 0, 0, 0 )
	create.team				= TEAM_MILITIA
	create.count 			= 4
	create.side 			= "jump"

	local event1 			= CreateCinematicEvent()
	event1.origin 			= Vector( -4714, 1539, -11110 )
	event1.yaw	 			= 230
	event1.anim				= "gd_fracture_flyin_imc_R_intro"
	event1.teleport 		= true
	event1.proceduralLength	= true
	event1.skycam			= SKYBOXSPACE
	Event_AddClientStateFunc( event1, "CE_VisualSettingsSpace" )
	Event_AddServerStateFunc( event1, CE_PlayerSkyScaleSpace )

	local event2 			= CreateCinematicEvent()
	event2.origin 			= Vector( -4386, 4019, 250 )
	event2.yaw				= 135
	event2.anim				= "gd_fracture_flyin_imc_R"
	event2.teleport 		= true
	event2.preAnimFPSWarp 	= true
	Event_AddClientStateFunc( event2, "CE_VisualSettingsDropshipInterior" )
	Event_AddClientStateFunc( event2, "CE_BloomOnRampOpen" )
	Event_AddServerStateFunc( event2, CE_PlayerSkyScaleDropshipInterior )
	Event_AddServerStateFunc( event2, CE_PlayerSkyScaleOnRampOpen )

	AddSavedDropEvent( "introDropShipMCOR_2cr", create )
	AddSavedDropEvent( "introDropShipMCOR_2e1", event1 )
	AddSavedDropEvent( "introDropShipMCOR_2e2", event2 )

	////////////////////////////////////////////////////////////

	local table 	= GetSavedDropEvent( "introDropShipMCOR_1cr" )
	local event1 	= GetSavedDropEvent( "introDropShipMCOR_1e1" )
	local event2 	= GetSavedDropEvent( "introDropShipMCOR_1e2" )
	local dropship 	= SpawnCinematicDropship( table )
	thread RunCinematicDropship( dropship, event1, event2 )

	local table 	= GetSavedDropEvent( "introDropShipMCOR_2cr" )
	local event1 	= GetSavedDropEvent( "introDropShipMCOR_2e1" )
	local event2 	= GetSavedDropEvent( "introDropShipMCOR_2e2" )
	local dropship 	= SpawnCinematicDropship( table )
	thread RunCinematicDropship( dropship, event1, event2 )
}

function EvacSetup()
{
	Evac_AddLocation( "endingRescueShip1", Vector( 1023.801208, -5324.443359, 185.069397 ), Vector( -2.628336, -575.577271 , 0 ) )
	Evac_AddLocation( "endingRescueShip3", Vector( 2941.916992, 1266.422729, 176.686890 ), Vector( 8.509399, 37.891029, 0 ) )

	local spacenode = CreateScriptRef( Vector(-5393.483887, -13542.212891, -13132.572266 ), Vector( 0, 160, 0 ) )
	Evac_SetSpaceNode( spacenode )
	Evac_SetupDefaultVDUs()
}

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

main()