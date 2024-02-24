
function main()
{
	if ( reloadingScripts )
		return

		// block an unclipped area
	AddTitanfallBlocker( Vector(2336, 5356, -2675), 4000, 2100 )

	FlagSet( "DogFights" ) // tells flightpath to bake these into the ain

	GM_AddEndRoundFunc( EndRoundMain )
}

function EntitiesDidLoad()
{
	if ( EvacEnabled() )
		EvacSetup()

	delaythread( CLASSIC_MP_SKYSHOW_DOGFIGHTS_DELAY ) StratonHornetDogfights()
}

function EvacSetup()
{

    PrintFunc()
	local spectatorNode1 = GetEnt( "spec_cam1" )
	local spectatorNode2 = GetEnt( "spec_cam2" )
	local spectatorNode3 = GetEnt( "spec_cam3" )

	Evac_AddLocation( "escape_node1", spectatorNode1.GetOrigin(), spectatorNode1.GetAngles() )
	Evac_AddLocation( "escape_node2", spectatorNode2.GetOrigin(), spectatorNode2.GetAngles() )
	Evac_AddLocation( "escape_node3", spectatorNode3.GetOrigin(), spectatorNode3.GetAngles() )

	local spacenode = GetEnt( "spacenode" )

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