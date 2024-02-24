const RADAR_A_MODEL = "models/IMC_base/radar_a.mdl"
const RADAR_B_MODEL = "models/IMC_base/radar_b.mdl"
const RADAR_C_MODEL = "models/IMC_base/radar_c.mdl"
const RADAR_D_MODEL = "models/IMC_base/radar_d.mdl"
const RADAR_E_MODEL = "models/IMC_base/radar_e.mdl"
const RADAR_F_MODEL = "models/IMC_base/radar_f.mdl"
const RADAR_G_MODEL = "models/IMC_base/radar_g.mdl"
const RADAR_H_MODEL = "models/IMC_base/radar_h.mdl"
const RADAR_I_MODEL = "models/IMC_base/radar_i.mdl"

function main()
{
	if ( reloadingScripts )
		return

	FlagSet( "DogFights" ) // tells flightpath to bake these into the ain

	GM_AddEndRoundFunc( EndRoundMain )

	PrecacheModel( RADAR_A_MODEL )
	PrecacheModel( RADAR_B_MODEL )
	PrecacheModel( RADAR_C_MODEL )
	PrecacheModel( RADAR_D_MODEL )
	PrecacheModel( RADAR_E_MODEL )
	PrecacheModel( RADAR_F_MODEL )
	PrecacheModel( RADAR_G_MODEL )
	PrecacheModel( RADAR_H_MODEL )
	PrecacheModel( RADAR_I_MODEL )
}

function EntitiesDidLoad()
{
	if ( EvacEnabled() )
		EvacSetup()

	if ( GetClassicMPMode() )
		delaythread ( CLASSIC_MP_SKYSHOW_DOGFIGHTS_DELAY ) StratonHornetDogfights()
}

function EvacSetup()
{
	//Set up is somewhat annoying. TODO: Make it better next game
	local escape_node1 = GetEnt( "escape_node" )
	local spectator_node1 = GetEnt( escape_node1.GetTarget() )

	local escape_node2 = GetEnt( "escape_node1" )
	local spectator_node2 = GetEnt( escape_node1.GetTarget() )

	local escape_node3 = GetEnt( "escape_node2" )
	local spectator_node3 = GetEnt( escape_node1.GetTarget() )

	local escape_node4 = GetEnt( "escape_node3" )
	local spectator_node4 = GetEnt ( escape_node1.GetTarget() )

	local escape_node5 = GetEnt( "escape_node4" )
	local spectator_node5 = GetEnt( escape_node1.GetTarget() )

	Evac_AddLocation( "escape_node", spectator_node1.GetOrigin(), spectator_node1.GetAngles() )
	Evac_AddLocation( "escape_node1", spectator_node2.GetOrigin(), spectator_node2.GetAngles() )
	Evac_AddLocation( "escape_node2", spectator_node3.GetOrigin(), spectator_node3.GetAngles() )
	Evac_AddLocation( "escape_node3", spectator_node4.GetOrigin(), spectator_node4.GetAngles() )
	Evac_AddLocation( "escape_node4", spectator_node5.GetOrigin(), spectator_node5.GetAngles() )

	local spacenode = GetEnt( "info_target_evacnode" )
	spacenode.SetAngles( Vector( 0, 90, 0 ) )

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