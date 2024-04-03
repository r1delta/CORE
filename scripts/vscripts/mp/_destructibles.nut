// script for global destructibles

// Name a trigger multipe titan_stepcrush_trigger*
// Have the output target destruction etc. on User1
// Titan will crush

const DESTROYED_MODEL = "models/vehicle/vehicle_w3_hatchback/vehicle_w3_hatch_destruction.mdl"
PrecacheModel( DESTROYED_MODEL )


function EntitiesDidLoad()
{
	local destructible_car_targetnames = []
	destructible_car_targetnames.append( "vehicle_w3_hatch_destructible" )
	destructible_car_targetnames.append( "sedan_clean_destructable" )
	destructible_car_targetnames.append( "vehicle_samson_destructible" )

	local vehicles = []
	foreach( name in destructible_car_targetnames )
		vehicles.extend( GetEntArrayByNameWildCard_Expensive( name ) )

	foreach( vehicle in vehicles )
	{
		vehicle.ConnectOutput( "OnBreak", VehicleDestroyed )

		Assert( !( "isDestructibleVehicle" in vehicle.s ) )
		vehicle.s.isDestructibleVehicle <- true
	}
}

function VehicleDestroyed( self, activator, caller, value )
{
	if ( caller == null )
		return
	EmitSoundAtPosition( caller.GetOrigin(), "AngelCity_Scr_CarExplodes" )

	local destroyed_mdl = CreatePropDynamic( caller.GetModelName(), caller.GetOrigin(), caller.GetAngles(), 6 )
	destroyed_mdl.Anim_Play( "destruction" )
	destroyed_mdl.SetBodygroup( 0, 1 )
	destroyed_mdl.kv.CollisionGroup = 21	// COLLISION_GROUP_BLOCK_WEAPONS
	destroyed_mdl.SetInvulnerable()
}
