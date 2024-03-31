function main()
{
	Globalize( ArmadaGetGroupNum )
	Globalize( ArmadaGetExpFX )
	Globalize( ArmadaGetTracerFX )
	Globalize( ArmadaGetAttach )
	Globalize( ArmadaGetSpeedModifier )
	Globalize( GetShipAttachID )

	level.redeyeAttackDuration <- 20   // seconds

	// TEAM_UNASSIGNED = normal screens, TEAM_MILITIA = overloaded screens, TEAM_IMC = no screens
	level.monitorScreenModelsLarge 			<- { [ "BLUE" ] = [], [ "ORANGE" ] = [] }
	level.monitorScreenModelsLargeSpecial 	<- { [ "BLUE" ] = [], [ "ORANGE" ] = [] }
	level.monitorScreenModelsMedium 		<- { [ "BLUE" ] = [], [ "ORANGE" ] = [] }
	level.monitorScreenModelsMediumSpecial 	<- { [ "BLUE" ] = [], [ "ORANGE" ] = [] }
	level.monitorScreenModelsSmall 			<- { [ "BLUE" ] = [], [ "ORANGE" ] = [] }

	// Large monitors
	level.monitorScreenModelsLarge[ "BLUE" ].append( "models/holo_screens/monitor_screen_O2_large_01.mdl" )
	level.monitorScreenModelsLarge[ "BLUE" ].append( "models/holo_screens/monitor_screen_O2_large_04.mdl" )
	level.monitorScreenModelsLarge[ "ORANGE" ].append( "models/holo_screens/monitor_screen_O2_large_02.mdl" )
	level.monitorScreenModelsLarge[ "ORANGE" ].append( "models/holo_screens/monitor_screen_O2_large_03.mdl" )

	level.monitorScreenModelsLargeSpecial[ "BLUE" ].append( "models/holo_screens/monitor_screen_O2_large_01_75pct.mdl" )
	level.monitorScreenModelsLargeSpecial[ "BLUE" ].append( "models/holo_screens/monitor_screen_O2_large_04_75pct.mdl" )
	level.monitorScreenModelsLargeSpecial[ "ORANGE" ].append( "models/holo_screens/monitor_screen_O2_large_02_75pct.mdl" )
	level.monitorScreenModelsLargeSpecial[ "ORANGE" ].append( "models/holo_screens/monitor_screen_O2_large_03_75pct.mdl" )

	// Medium monitors
	level.monitorScreenModelsMedium[ "BLUE" ].append( "models/holo_screens/monitor_screen_O2_medium_04.mdl" )
	level.monitorScreenModelsMedium[ "BLUE" ].append( "models/holo_screens/monitor_screen_O2_medium_06.mdl" )
	level.monitorScreenModelsMedium[ "ORANGE" ].append( "models/holo_screens/monitor_screen_O2_medium_03.mdl" )
	level.monitorScreenModelsMedium[ "ORANGE" ].append( "models/holo_screens/monitor_screen_O2_medium_05.mdl" )

	level.monitorScreenModelsMediumSpecial[ "BLUE" ].append( "models/holo_screens/monitor_screen_O2_medium_01.mdl" )
	level.monitorScreenModelsMediumSpecial[ "BLUE" ].append( "models/holo_screens/monitor_screen_O2_medium_02.mdl" )
	level.monitorScreenModelsMediumSpecial[ "ORANGE" ].append( "models/holo_screens/monitor_screen_O2_medium_01_orange.mdl" )
	level.monitorScreenModelsMediumSpecial[ "ORANGE" ].append( "models/holo_screens/monitor_screen_O2_medium_02_orange.mdl" )

	// Small monitors
	level.monitorScreenModelsSmall[ "BLUE" ].append( "models/holo_screens/monitor_screen_O2_small_01.mdl" )
	level.monitorScreenModelsSmall[ "BLUE" ].append( "models/holo_screens/monitor_screen_O2_small_02.mdl" )
	level.monitorScreenModelsSmall[ "BLUE" ].append( "models/holo_screens/monitor_screen_O2_small_05.mdl" )
	level.monitorScreenModelsSmall[ "BLUE" ].append( "models/holo_screens/monitor_screen_O2_small_04.mdl" )
	level.monitorScreenModelsSmall[ "ORANGE" ].append( "models/holo_screens/monitor_screen_O2_small_03.mdl" )
	level.monitorScreenModelsSmall[ "ORANGE" ].append( "models/holo_screens/monitor_screen_O2_small_06.mdl" )
	level.monitorScreenModelsSmall[ "ORANGE" ].append( "models/holo_screens/monitor_screen_O2_small_07.mdl" )
	level.monitorScreenModelsSmall[ "ORANGE" ].append( "models/holo_screens/monitor_screen_O2_small_08.mdl" )
	level.monitorScreenModelsSmall[ "ORANGE" ].append( "models/holo_screens/monitor_screen_O2_small_09.mdl" )
	level.monitorScreenModelsSmall[ "ORANGE" ].append( "models/holo_screens/monitor_screen_O2_small_10.mdl" )

	if ( IsServer() )
	{
		// Precaching models for clientside model swaps only works on the server
		PrecacheMonitorModels( level.monitorScreenModelsLarge )
		PrecacheMonitorModels( level.monitorScreenModelsMedium )
		PrecacheMonitorModels( level.monitorScreenModelsSmall )
		PrecacheMonitorModels( level.monitorScreenModelsLargeSpecial )
		PrecacheMonitorModels( level.monitorScreenModelsMediumSpecial )
	}

	if ( GetCinematicMode() && ( GameRules.GetGameMode() == CAPTURE_POINT ) )
	{
		RegisterObjective( "O2_noEvacEnding" )

		if ( IsClient() )
			AddObjective( "O2_noEvacEnding", "#HUD_O2_EPILOGUE_NO_EVAC_TITLE", "#HUD_O2_EPILOGUE_NO_EVAC_DESC" )
	}

}

function PrecacheMonitorModels( monitorModels )
{
	foreach ( teamArray in monitorModels )
		foreach ( model in teamArray )
			PrecacheModel( model )
}


/************************************************************************************************\

   ###    ########  ##     ##    ###    ########     ###          ######## ##     ##
  ## ##   ##     ## ###   ###   ## ##   ##     ##   ## ##         ##        ##   ##
 ##   ##  ##     ## #### ####  ##   ##  ##     ##  ##   ##        ##         ## ##
##     ## ########  ## ### ## ##     ## ##     ## ##     ##       ######      ###
######### ##   ##   ##     ## ######### ##     ## #########       ##         ## ##
##     ## ##    ##  ##     ## ##     ## ##     ## ##     ##       ##        ##   ##
##     ## ##     ## ##     ## ##     ## ########  ##     ##       ##       ##     ##

\************************************************************************************************/

function ArmadaGetGroupNum( model )
{
	switch( model.tolower() )
	{
		case FLEET_CAPITAL_SHIP_ARGO_1000X:
		case FLEET_MCOR_ANNAPOLIS_1000X:
		case FLEET_MCOR_REDEYE_1000X:
		case FLEET_MCOR_BIRMINGHAM_1000X:
		case FLEET_IMC_CARRIER_1000X:
		case FLEET_IMC_WALLACE_1000x:
			return 0

		case FLEET_MCOR_REDEYE_1000X_CLUSTERB:
		case FLEET_MCOR_REDEYE_1000X_CLUSTERC:
			return 5

		case FLEET_MCOR_REDEYE_1000X_CLUSTERA:
		case FLEET_IMC_CARRIER_1000X_CLUSTERA:
		case FLEET_IMC_CARRIER_1000X_CLUSTERB:
		case FLEET_IMC_CARRIER_1000X_CLUSTERC:
		case FLEET_IMC_WALLACE_1000X_CLUSTERA:
		case FLEET_IMC_WALLACE_1000X_CLUSTERB:
		case FLEET_IMC_WALLACE_1000X_CLUSTERC:
			return 6

		case FLEET_MCOR_BIRMINGHAM_1000X_CLUSTERA:
			return 7
	}
}

function ArmadaGetExpFX( model )
{
	switch( model.tolower() )
	{
		case FLEET_CAPITAL_SHIP_ARGO_1000X:
			return FX_SPACE_ARGO_EXPLOSION

		case FLEET_MCOR_ANNAPOLIS_1000X:
			return FX_SPACE_ANNAPOLIS_EXPLOSION

		case FLEET_MCOR_BIRMINGHAM_1000X:
		case FLEET_MCOR_BIRMINGHAM_1000X_CLUSTERA:
			return FX_SPACE_BIRMINGHAM_EXPLOSION

		case FLEET_MCOR_REDEYE_1000X:
		case FLEET_MCOR_REDEYE_1000X_CLUSTERA:
		case FLEET_MCOR_REDEYE_1000X_CLUSTERB:
		case FLEET_MCOR_REDEYE_1000X_CLUSTERC:
			return FX_SPACE_REDEYE_EXPLOSION

		case FLEET_IMC_CARRIER_1000X:
		case FLEET_IMC_CARRIER_1000X_CLUSTERA:
		case FLEET_IMC_CARRIER_1000X_CLUSTERB:
		case FLEET_IMC_CARRIER_1000X_CLUSTERC:
			return FX_SPACE_CARRIER_EXPLOSION

		case FLEET_IMC_WALLACE_1000x:
		case FLEET_IMC_WALLACE_1000X_CLUSTERA:
		case FLEET_IMC_WALLACE_1000X_CLUSTERB:
		case FLEET_IMC_WALLACE_1000X_CLUSTERC:
			return FX_SPACE_WALLACE_EXPLOSION
	}
}

function ArmadaGetTracerFX( model, tracersMCOR, tracersIMC )
{
	switch( model.tolower() )
	{
		case FLEET_CAPITAL_SHIP_ARGO_1000X:
		case FLEET_IMC_CARRIER_1000X:
		case FLEET_IMC_CARRIER_1000X_CLUSTERA:
		case FLEET_IMC_CARRIER_1000X_CLUSTERB:
		case FLEET_IMC_CARRIER_1000X_CLUSTERC:
		case FLEET_IMC_WALLACE_1000x:
		case FLEET_IMC_WALLACE_1000X_CLUSTERA:
		case FLEET_IMC_WALLACE_1000X_CLUSTERB:
		case FLEET_IMC_WALLACE_1000X_CLUSTERC:
			return tracersIMC

		case FLEET_MCOR_ANNAPOLIS_1000X:
		case FLEET_MCOR_BIRMINGHAM_1000X:
		case FLEET_MCOR_BIRMINGHAM_1000X_CLUSTERA:
		case FLEET_MCOR_REDEYE_1000X:
		case FLEET_MCOR_REDEYE_1000X_CLUSTERA:
		case FLEET_MCOR_REDEYE_1000X_CLUSTERB:
		case FLEET_MCOR_REDEYE_1000X_CLUSTERC:
			return tracersMCOR
	}
}

function ArmadaGetAttach( model )
{
	switch( model.tolower() )
	{
		case FLEET_MCOR_REDEYE_1000X:
		case FLEET_MCOR_BIRMINGHAM_1000X:
		case FLEET_MCOR_ANNAPOLIS_1000X:
		case FLEET_CAPITAL_SHIP_ARGO_1000X:
		case FLEET_IMC_WALLACE_1000x:
			return "ORIGIN"

		case FLEET_MCOR_REDEYE_1000X_CLUSTERA:
		case FLEET_MCOR_REDEYE_1000X_CLUSTERB:
		case FLEET_MCOR_REDEYE_1000X_CLUSTERC:
		case FLEET_IMC_CARRIER_1000X:
		case FLEET_IMC_CARRIER_1000X_CLUSTERA:
		case FLEET_IMC_CARRIER_1000X_CLUSTERB:
		case FLEET_IMC_CARRIER_1000X_CLUSTERC:
		case FLEET_MCOR_BIRMINGHAM_1000X_CLUSTERA:
		case FLEET_IMC_WALLACE_1000X_CLUSTERA:
		case FLEET_IMC_WALLACE_1000X_CLUSTERB:
		case FLEET_IMC_WALLACE_1000X_CLUSTERC:
			return "FXORIGIN"
	}
}

function ArmadaGetSpeedModifier( model )
{
	switch( model.tolower() )
	{
		case FLEET_CAPITAL_SHIP_ARGO_1000X:
			return 1.0

		case FLEET_MCOR_ANNAPOLIS_1000X:
			return 1.0

		case FLEET_MCOR_BIRMINGHAM_1000X:
		case FLEET_MCOR_BIRMINGHAM_1000X_CLUSTERA:
			return 0.85

		case FLEET_MCOR_REDEYE_1000X:
		case FLEET_MCOR_REDEYE_1000X_CLUSTERA:
		case FLEET_MCOR_REDEYE_1000X_CLUSTERB:
		case FLEET_MCOR_REDEYE_1000X_CLUSTERC:
			return 1.15

		case FLEET_IMC_CARRIER_1000X:
		case FLEET_IMC_CARRIER_1000X_CLUSTERA:
		case FLEET_IMC_CARRIER_1000X_CLUSTERB:
		case FLEET_IMC_CARRIER_1000X_CLUSTERC:
			return 1.15

		case FLEET_IMC_WALLACE_1000x:
		case FLEET_IMC_WALLACE_1000X_CLUSTERA:
		case FLEET_IMC_WALLACE_1000X_CLUSTERB:
		case FLEET_IMC_WALLACE_1000X_CLUSTERC:
			return 0.85
	}

	return 1.0 // just in case...
}

// NOTE: This is some wacky index stuff that can't be changed.  Let Mo explain it.
// Basically, the ship FX start at index 1 not 0
function GetShipAttachID( ship, attach, group, index )
{
	local attachIdx = 0

	if ( index == 0 && group == 0 )
		attachIdx = ship.LookupAttachment( attach )//the attachment name is final
	//else if ( index == 0 && group != 0 )
	//	continue //we need to skip this index
	else
		attachIdx = ship.LookupAttachment( attach + index )	//the attachment name needs to be appended

	return attachIdx
}