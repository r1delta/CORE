function main()
{
	IncludeFile( "mp_nexus_shared" )
	if ( reloadingScripts )
		return

	//Removing Skyshow from Nexus since we're ovebudget
	//FlagSet( "DogFights" ) // tells flightpath to bake these into the ain

	GM_AddEndRoundFunc( EndRoundMain )

	PrecacheModel( "models/containers/box_large_cardboard.mdl" )

}

function EntitiesDidLoad()
{
	if ( EvacEnabled() )
		EvacSetup()

	CreatePropDynamic( "models/containers/box_large_cardboard.mdl", Vector( 1570.364624, 1448.523804, 800.031250 ), Vector( 0.000000, 90.000, 0.000000 ), 6 )
	CreatePropDynamic( "models/containers/box_large_cardboard.mdl", Vector( 1550.364624, 1448.523804, 800.031250 ), Vector( 0.000000, 90.000, 0.000000 ), 6 )
	CreatePropDynamic( "models/containers/box_large_cardboard.mdl", Vector( 1500.364624, 1448.523804, 800.031250 ), Vector( 0.000000, 90.000, 0.000000 ), 6 )
	CreatePropDynamic( "models/containers/box_large_cardboard.mdl", Vector( 1450.364624, 1448.523804, 800.031250 ), Vector( 0.000000, 90.000, 0.000000 ), 6 )
	CreatePropDynamic( "models/containers/box_large_cardboard.mdl", Vector( 1400.364624, 1448.523804, 800.031250 ), Vector( 0.000000, 90.000, 0.000000 ), 6 )
	CreatePropDynamic( "models/containers/box_large_cardboard.mdl", Vector( 1350.364624, 1448.523804, 800.031250 ), Vector( 0.000000, 90.000, 0.000000 ), 6 )
	CreatePropDynamic( "models/containers/box_large_cardboard.mdl", Vector( 1300.364624, 1448.523804, 800.031250 ), Vector( 0.000000, 90.000, 0.000000 ), 6 )
	CreatePropDynamic( "models/containers/box_large_cardboard.mdl", Vector( 1250.364624, 1448.523804, 800.031250 ), Vector( 0.000000, 90.000, 0.000000 ), 6 )

	CreatePropDynamic( "models/containers/box_large_cardboard.mdl", Vector( 358.000671, 792.362976, 423.031250 ), Vector( 0.000000, 90.000, 0.000000 ), 6 )

	local spawnpointForBug79250 = GetEnt( "info_spawnpoint_human_3522" )
	spawnpointForBug79250.SetAngles( Vector( 0.0, 24.0, 0.0 ) )

	//Removing Skyshow from Nexus since we're ovebudget
	//if ( GetClassicMPMode() )
	//	delaythread ( CLASSIC_MP_SKYSHOW_DOGFIGHTS_DELAY ) StratonHornetDogfights()
}

function EvacSetup()
{
	local spectatorNode1 = GetEnt( "spec_cam1" )
	local spectatorNode2 = GetEnt( "spec_cam2" )
	local spectatorNode3 = GetEnt( "spec_cam3" )

	local spaceNode = GetEnt("spacenode")

	Evac_AddLocation( "escape_node1", spectatorNode1.GetOrigin(), spectatorNode1.GetAngles() )
	Evac_AddLocation( "escape_node2", spectatorNode2.GetOrigin(), spectatorNode2.GetAngles() )
	Evac_AddLocation( "escape_node3", spectatorNode3.GetOrigin(), spectatorNode3.GetAngles() )

	Evac_SetSpaceNode( spaceNode )
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