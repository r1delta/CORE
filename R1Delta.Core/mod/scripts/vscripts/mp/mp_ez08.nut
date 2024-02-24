
function main()
{
	if ( reloadingScripts )
		return

	//GM_AddEndRoundFunc( EndRoundMain )
}

function EntitiesDidLoad()
{
	//if ( EvacEnabled() )
	//	EvacSetup()
}

/*
function EvacSetup()
{
    PrintFunc()
	local spectatorNode1 = GetEnt( "spec_cam1" )
	
	Evac_AddLocation( "escape_node1", spectatorNode1.GetOrigin(), spectatorNode1.GetAngles() )
	
	local spacenode = GetEnt( "intro_SpaceNode" )

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
*/

main()