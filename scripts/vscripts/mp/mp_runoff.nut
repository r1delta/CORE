const WARNING_LIGHT_ON_MODEL	= "models/lamps/warning_light_ON_orange.mdl"
const WARNING_LIGHT_OFF_MODEL 	= "models/lamps/warning_light.mdl"

PrecacheModel( SKYBOX_ARMADA_SHIP_MODEL_REDEYE )
PrecacheModel( SKYBOX_ARMADA_SHIP_MODEL_BERMINGHAM )
PrecacheModel( WARNING_LIGHT_ON_MODEL )
PrecacheModel( WARNING_LIGHT_OFF_MODEL )

function main()
{
	if ( reloadingScripts )
		return

	GM_AddEndRoundFunc( EndRoundMain )
}

function EntitiesDidLoad()
{
	if ( EvacEnabled() )
		EvacSetup()

	local droppodBug71211 = GetEnt( "info_spawnpoint_human_start_25" )
	if ( IsValid( droppodBug71211 ) )
	{
		droppodBug71211.SetOrigin( Vector( 156.0, 69.0, 264.0 ) )
		droppodBug71211.SetAngles( Vector( 0.0, 127.0, 0.0 ) )
	}
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

main()