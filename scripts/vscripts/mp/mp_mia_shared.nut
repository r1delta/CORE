function main()
{
	Globalize( ArmadaGetGroupNum )
	Globalize( ArmadaGetExpFX )
	Globalize( ArmadaGetTracerFX )
	Globalize( ArmadaGetAttach )
	Globalize( ArmadaGetSpeedModifier )
	Globalize( GetShipAttachID )

	level.redeyeAttackDuration <- 20   // seconds

	

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