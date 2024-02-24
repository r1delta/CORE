function main()
{
	printl( "****mp_lagoon_script" )

	if ( reloadingScripts )
		return

	FlagSet( "DogFights" ) // tells flightpath to bake these into the ain

	GM_AddEndRoundFunc( EndRoundMain )
}

function EntitiesDidLoad()
{
	//thread debug()

	if ( EvacEnabled() )
		EvacSetup()

	if ( GetClassicMPMode() )
		delaythread ( CLASSIC_MP_SKYSHOW_DOGFIGHTS_DELAY ) StratonHornetDogfights()
}

function debug()
{
	printl( "**********************************************************" );
	local triggers = GetEntArrayByClass_Expensive( "trigger_capture_point" )
	local info_hardpoints = GetEntArrayByClass_Expensive( "info_hardpoint" )
	local assault_assaultpoints = GetEntArrayByClass_Expensive( "assault_assaultpoint" )

	foreach( info_hardpoint in info_hardpoints )
	{
		printl( "Hardpoint targetname: " + info_hardpoint.GetName() )
		printl( "Hardpoint target: " + info_hardpoint.kv.target )
		printl( "Hardpoint triggerTarget: " + info_hardpoint.kv.triggerTarget )
		printl( "Hardpoint hardpointName: " + info_hardpoint.kv.hardpointName )
	}

	printl( "**********************************************************" );

	foreach( trigger in triggers )
	{
		printl( "Trigger targetname: " + trigger.GetName() )
	}

	printl( "**********************************************************" );

	foreach( assault_assaultpoint in assault_assaultpoints )
	{
		printl( "Assaultpoint targetname: " + assault_assaultpoint.GetName() )
	}

	printl( "**********************************************************" );
}

function EvacSetup()
{
	//-------------------------
	// Evac locations
	//-------------------------
	local evacShack = GetEnt( "evacShack" )
	local evacOperations = GetEnt( "evacOperations" )
	local evacBoathouse = GetEnt( "evacBoathouse" )
	local evacOperations1 = GetEnt( "evacOperations1" )
	Assert( evacShack != null )
	Assert( evacOperations != null )
	Assert( evacBoathouse != null )
	Assert( evacOperations1 != null )

	Evac_AddLocation( "evacShack", Vector( -3637.635254, 1147.495605, 902.962219 ), Vector( 6.706433, 58.537022, 0 ) )
	Evac_AddLocation( "evacOperations", Vector( -733.931335, 4631.209473, 1227.685425 ), Vector( 34.912075, 61.126858, -0.000002 ) )
	Evac_AddLocation( "evacBoathouse", Vector( -4502.020508, 335.097656, 766.385132 ), Vector( 21.662722, 40.695465, 0.000001 ) )
	Evac_AddLocation( "evacOperations1", Vector( -22.699238, 5562.675781, 858.846802 ), Vector( 28.256578, -136.553879, 0 ) )

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
