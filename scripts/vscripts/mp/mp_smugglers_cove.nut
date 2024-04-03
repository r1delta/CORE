function main()
{
	if ( reloadingScripts )
		return

	level.defenseTeam = TEAM_MILITIA

	FlagSet( "DogFights" ) // tells flightpath to bake these into the ain

	GM_AddEndRoundFunc( EndRoundMain )

	PrecacheModel( "models/angel_city/small_planter_01.mdl" )
}

function EntitiesDidLoad()
{
	if ( EvacEnabled() )
		EvacSetup()

	if ( GetClassicMPMode() )
		delaythread ( CLASSIC_MP_SKYSHOW_DOGFIGHTS_DELAY ) StratonHornetDogfights()

	CreatePropDynamic( "models/angel_city/small_planter_01.mdl", Vector( -1550.804810, 649.066223, 351.031250 ), Vector( 0.000000, -12.369751, 0.000000 ), 6 )
	CreatePropDynamic( "models/angel_city/small_planter_01.mdl", Vector( -1607.296143, 270.570801, 351.031250 ), Vector( 0.000000, -17.759766, 0.000000 ), 6 )
	CreatePropDynamic( "models/angel_city/small_planter_01.mdl", Vector( -1795.920410, 297.185822, 351.031250 ), Vector( 0.000000, -7.969788, 0.000000 ), 6 )
	CreatePropDynamic( "models/angel_city/small_planter_01.mdl", Vector( -1522.411255, 837.113403, 351.031250 ), Vector( 0.000000, -7.779541, 0.000000 ), 6 )
	CreatePropDynamic( "models/angel_city/small_planter_01.mdl", Vector( -1465.333252, 1216.735474, 351.031250), Vector( 0.000000, -14.189156, 0.000000 ), 6 )
}

function EvacSetup()
{



	//-------------------------
	// Evac locations
	//-------------------------
	Evac_AddLocation( "evac_point1", Vector( 318.411407, -1090.354004, 835.199768 ), Vector( 6.697716, -36.380295, 0.000000 ) )
	Evac_AddLocation( "evac_point2", Vector( 2998.471680, -1160.312622, 1072.092407 ), Vector( 11.041658, 151.812775, 0.000000 ) )
	Evac_AddLocation( "evac_point3", Vector( 908.494202, 983.316162, 811.075989 ), Vector( 5.263328, 231.079742, 0.000000 ) )
	Evac_AddLocation( "evac_point4", Vector( 1234.564087, 1257.419922, 1050.463623 ), Vector( 14.643608, 241.049469, 0.000000 ) )
	Evac_AddLocation( "evac_point5", Vector( -1814.789307, 2053.205078, 1076.510254 ), Vector( 3.727635, -95.771507, 0.000000 ) )
	Evac_AddLocation( "evac_point6", Vector( 2914.585205, 1452.237183, 915.377441 ), Vector( 1.560672, -118.929665, 0.000000 ) )
	Evac_AddLocation( "evac_point7", Vector( 2438.312012, 2234.653564, 840.212646 ), Vector( 1.858571, -112.010323, 0.000000 ) )
	Evac_AddLocation( "evac_point8", Vector( -126.282837, 1623.915283, 716.387573 ), Vector( -0.392171, -128.235718, 0.000000 ) )
	Evac_AddLocation( "evac_point9", Vector( -1460.424927, -1496.693237, 753.878418 ), Vector( -356.985596, 87.414734, 0.000000 ) )

	local spacenode = GetEnt( "intro_spacenode" )
	Assert( spacenode != null )

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