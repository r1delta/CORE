// _airvehicle_utility.nut

const AIRVEHICLE_FLAG_AWAIT_INPUT	= 0x040

function main()
{
	Globalize( CodeCallback_OnVehiclePass )
	Globalize( VehicleFlyingPath )
	Globalize( VehicleAutoBehavior )
	Globalize( VehicleAnimatedDropoff )
	Globalize( DefaultDropshipDropoff )
	Globalize( VehicleFliesToEntityAndPlaysAnim )
	Globalize( VehicleFliesToEntityAndStartsAnim )	
	
	RegisterSignal( "takeoff" )
	
}

// params: vehicle, nodePassed, nextNode, nextNextNode
function CodeCallback_OnVehiclePass( params )
{
	local vehicle = params.vehicle
	local node = params.nodePassed
	local nextNode = params.nextNode
	local nextNextNode = params.nextNextNode

//	printt( "Distance " + Distance( vehicle, node ) )
//	printl( "VehiclePass: " + params.vehicle + " " + params.nodePassed + " " + params.nextNode + " " + params.nextNextNode )

	Assert( node, "No node??" )

	if ( node.HasKey( "delete" ) )
	{
		vehicle.Kill()
		return
	}

	if ( node.HasKey( "SetFlag" ) )
	{
		FlagSet( node.kv.SetFlag )
	}

	if ( node.HasKey( "SendSignal" ) )
	{
		printt( "Sent signal " + node.kv.SendSignal )
		vehicle.Signal( node.kv.SendSignal )
	}

	if ( node.HasKey( "behavior" ) )
	{
		switch ( node.kv.behavior )
		{
			case "Land":
				
				// already at the landing node
				if ( nextNode )
					thread VehicleWaitsThenTakesOff( vehicle, node, nextNode )
					
				return
				
			case "Dropoff":

				VehicleDropoff( vehicle, node )
				break

			case "Delete":
				vehicle.Kill()
				return

			case "uturn":
				if ( params.isMovingForward )
				{
					// fly there full speed then delete				
					vehicle.FlyPathBackward( node )
					return
				}
				break

			case "uturn_reverse":
				if ( !params.isMovingForward )
				{
					// fly there full speed then delete				
					vehicle.FlyPath( node )
					return
				}
				break
		}
	}

	if ( node.HasKey( "WaitFlag" ) )
	{
		Assert( !node.HasKey( "WaitSignal" ), "Node " + node.GetOrigin() + " has multiple waits." )
		Assert( !node.HasKey( "WaitTime" ), "Node " + node.GetOrigin() + " has multiple waits." )

		// we should already be told to fly to this node, but this could
		// be the first node of the path, which is awkward but do our best
		if ( !Flag( node.kv.WaitFlag ) )
		{
			vehicle.FlyToNodeViaPath( node )
			thread VehicleWaitsForFlagThenContinues( vehicle, node.kv.WaitFlag, nextNode )
			return
		}

		return
	}
	else
	if ( node.HasKey( "WaitSignal" ) )
	{		
		Assert( !node.HasKey( "WaitFlag" ), "Node " + node.GetOrigin() + " has multiple waits." )
		Assert( !node.HasKey( "WaitTime" ), "Node " + node.GetOrigin() + " has multiple waits." )

		// we should already be told to fly to this node, but this could
		// be the first node of the path, which is awkward but do our best
		vehicle.FlyToNodeViaPath( node )
		thread VehicleWaitsForSignalThenContinues( vehicle, node.kv.WaitSignal, nextNode )
		return			
	}		
	else
	if ( node.HasKey( "WaitTime" ) )
	{		
		Assert( !node.HasKey( "WaitFlag" ), "Node " + node.GetOrigin() + " has multiple waits." )
		Assert( !node.HasKey( "WaitSignal" ), "Node " + node.GetOrigin() + " has multiple waits." )

		vehicle.FlyToNodeViaPath( node )
		thread VehicleWaitsThenContinues( vehicle, node.kv.WaitTime.tofloat(), nextNode )
		return			
	}		

	if ( nextNode )
	{
		DeprecatedTrackPathFunctionality( vehicle, nextNode, nextNextNode )
	
		VehicleFlyingPath( vehicle, nextNode, params.isMovingForward )
	}		
}

function VehicleFlyingPath( vehicle, node, isMovingForward )
{
	// the vehicle is flying to this node, so we might have to do
	// special stuff to prepare for arrival

	if ( node.HasKey( "ApproachSignal" ) )
	{				
		local table = { node = node }
		vehicle.Signal( node.kv.ApproachSignal, table )					
	}
	
	if ( node.HasKey( "behavior" ) )
	{
		switch ( node.kv.behavior )
		{
			case "Land":
				thread VehicleLands( vehicle, node )
				return				
			
			case "Delete":
				// fly there full speed then delete
				vehicle.FlyToNodeUseNodeSpeed( node )
				return				

			case "uturn":
				if ( isMovingForward )
				{
					// fly there full speed then delete
					vehicle.FlyToNodeUseNodeSpeed( node )
				}
				return				

			case "uturn_reverse":
				if ( !isMovingForward )
				{
					// fly there full speed then delete
					vehicle.FlyToNodeUseNodeSpeed( node )
				}
				return				
		}
	}

	if ( node.HasKey( "WaitFlag" ) )
	{
		Assert( !node.HasKey( "WaitSignal" ), "Node " + node.GetOrigin() + " has multiple waits." )
		Assert( !node.HasKey( "WaitTime" ), "Node " + node.GetOrigin() + " has multiple waits." )

		// we should already be told to fly to this node, but this could
		// be the first node of the path, which is awkward but do our best
		if ( !Flag( node.kv.WaitFlag ) )
		{
			vehicle.FlyToNodeViaPath( node )
			thread VehicleWaitsForFlagThenContinues( vehicle, node.kv.WaitFlag, node )
			return
		}
	}
	else
	if ( node.HasKey( "WaitSignal" ) )
	{		
		Assert( !node.HasKey( "WaitFlag" ), "Node " + node.GetOrigin() + " has multiple waits." )
		Assert( !node.HasKey( "WaitTime" ), "Node " + node.GetOrigin() + " has multiple waits." )

		// we should already be told to fly to this node, but this could 
		// be the first node of the path, which is awkward but do our best
		vehicle.FlyToNodeViaPath( node )
		thread VehicleWaitsForSignalThenContinues( vehicle, node.kv.WaitSignal, node )
	}		
	else
	if ( node.HasKey( "WaitTime" ) )
	{		
		Assert( !node.HasKey( "WaitFlag" ), "Node " + node.GetOrigin() + " has multiple waits." )
		Assert( !node.HasKey( "WaitSignal" ), "Node " + node.GetOrigin() + " has multiple waits." )

		vehicle.FlyToNodeViaPath( node )
	}		


}

function VehicleWaitsThenContinues( vehicle, time, node )
{
	Assert( IsAlive( vehicle ), "Dead!" )
	vehicle.EndSignal( "OnDeath" )
	vehicle.EndSignal( "OnFly" )

	wait time
	vehicle.FlyPath( node )
}

function VehicleWaitsForFlagThenContinues( vehicle, flag, node )
{
	Assert( IsAlive( vehicle ), "Dead!!" )
	vehicle.EndSignal( "OnDeath" )
	vehicle.EndSignal( "OnFly" )
	
	Assert( node, "No followup node to fly to" )
	FlagWait( flag )
	vehicle.FlyPath( node )
}

function VehicleWaitsForSignalThenContinues( vehicle, signal, node )
{
	Assert( IsAlive( vehicle ), "Dead!1!" )
	vehicle.EndSignal( "OnDeath" )
	vehicle.EndSignal( "OnFly" )
	
	Assert( node, "No followup node to fly to" )
	vehicle.WaitSignal( signal )
	vehicle.FlyPath( node )
}

function VehicleSetPlayerRelationship( vehicle )
{
	// threaded off because vehicle may exist before player does
	if ( !Flag( "PlayerDidSpawn" ) )
	{ 
		vehicle.EndSignal( "OnDeath" )
		FlagWait( "PlayerDidSpawn" )
	}
}

function VehicleAutoBehavior( vehicle )
{
	vehicle.EndSignal( "OnDeath" )
	vehicle.EndSignal( "OnFly" )
	
	if ( EntHasSpawnflag( vehicle, AIRVEHICLE_FLAG_AWAIT_INPUT ) )
		vehicle.Fire( "Activate" )
	
	if ( !IsMultiplayer() )
		thread VehicleSetPlayerRelationship( vehicle )
	
	local target = GetEnt( vehicle.GetTarget() )	

	
	if ( vehicle.HasKey( "waitTakeoff" ) )
	{
		// dont use this behavior if you're playing your own takeoff anim.

		vehicle.Anim_Play( "test_runway_idle" )
		vehicle.kv.isUsingHoverNoise = false
		
		vehicle.EngineEffectsDisable()

		if ( !target )
			return

		vehicle.WaitSignal( "takeoff" )
		
		vehicle.EngineEffectsEnable()
		// play relative to ref because the ref and origin are not in the same place
		PlayAnim( vehicle, "test_takeoff", vehicle, "ref" )
		vehicle.kv.isUsingHoverNoise = true
		
	}
	else
	{
		//vehicle.Anim_NonScriptedPlay( "test_fly_idle" )

		if ( !target )
			return

		local speed
		speed = vehicle.kv.desiredSpeed.tofloat()
		
		if ( speed <= 0 )
		{
			speed = target.kv.speed.tofloat()
		}
	
		if ( speed > 0 )
		{
			vehicle.SetSpeedImmediate( speed )
		}
	}
		
	vehicle.FlyPath( target )
}


function VehicleLands( vehicle, node )
{
	vehicle.EndSignal( "OnDeath" )
	vehicle.EndSignal( "takeoff" )
	waitthread VehicleFliesToEntityAndPlaysAnim( vehicle, node, "test_land" )
	
	// make him not want to fly away once he's done animating
	// this is one of those rare cases where we want him to 
	// use only the code portion of FlyToNodeViaPath
	vehicle.__FlyToNodeViaPath( node )

	// play anim
	vehicle.EngineEffectsDisable()
	PlayAnim( vehicle, "test_runway_idle", node )

}

function VehicleFliesToEntityAndPlaysAnim( vehicle, refEntity, anim, lerpTime = 3 )
{
	vehicle.EndSignal( "OnDeath" )
	waitthread VehicleFliesToEntityAndStartsAnim( vehicle, refEntity, anim, lerpTime )
	vehicle.WaittillAnimDone()
}

function VehicleFliesToEntityAndStartsAnim( vehicle, refEntity, anim, lerpTime = 3 )
{
	vehicle.EndSignal( "OnDeath" )
	
	local origin = refEntity.GetOrigin()
	local angles = refEntity.GetAngles()	
	// fly to anim blend start point
	local animStart = vehicle.Anim_GetStartForRefPoint( anim, origin, angles )
	vehicle.FlyToPointToAnim( animStart.origin, anim )
	
	// any other incoming fly commands will break him out of this sequence
	vehicle.EndSignal( "OnFly" )
	vehicle.WaitSignal( "OnArrived" )
	
	// dont hover while playing a scripted animation
	vehicle.kv.isUsingHoverNoise = false
	
	// play anim
	thread PlayAnim( vehicle, anim, refEntity, null, lerpTime )
}

//goblin dropship plays special animation while dropping off zipline guys
function VehicleAnimatedDropoff( vehicle, node, selectedAnim )
{
	vehicle.EndSignal( "OnDeath" )
	vehicle.EndSignal( "takeoff" )
	local anim = "gd_goblin_zipline_dive"
	if ( selectedAnim )
		anim = selectedAnim
	local origin = node.GetOrigin()
	local angles = node.GetAngles()

	// fly to anim blend start point
	local animStart = vehicle.Anim_GetStartForRefPoint( anim, origin, angles )
	vehicle.FlyToPointToAnim( animStart.origin, anim )
	
	// any other incoming fly commands will break him out of this sequence
	vehicle.EndSignal( "OnFly" )
	
	//OnServerAnimEvent( "deploy" )
	AddAnimEvent( vehicle, "dropship_deploy", DefaultDropshipDropoff )


	vehicle.WaitSignal( "OnArrived" )
	
	// make him not want to fly away once he's done animating
	// this is one of those rare cases where we want him to 
	// use only the code portion of FlyToNodeViaPath
	vehicle.__FlyToNodeViaPath( node )
	
	// dont hover while playing a scripted animation
	vehicle.kv.isUsingHoverNoise = false

	// play anim
	PlayAnim( vehicle, anim, node, null, 3 )
	
	//vehicle.EngineEffectsDisable()
	//PlayAnim( vehicle, "test_runway_idle", node )
}


function DefaultDropshipDropoff( vehicle )
{
	if ( !( "dropFunc" in vehicle.s ) )
	{
		// only certain vehicles can drop guys.
		return
	}
	local count = 6
	local side = "both"
	
	thread vehicle.s.dropFunc( vehicle, side, count )
}




function VehicleWaitsThenTakesOff( vehicle, node, nextNode )
{
	vehicle.EndSignal( "OnDeath" )
	vehicle.EndSignal( "OnFly" )
	
	VehicleWaitNode( vehicle, node )
	
	// thread off so we dont get killed by OnFly endsignal
	thread VehicleTakesOff( vehicle, node, nextNode )
}

//Similar to VehicleWaitsThenTakesOff, except that the vehicle 
//wasn't actually landed, so we don't play the takeoff animation
function VehicleHoversWaitsThenFliesAway( vehicle, node, nextNode )
{
	vehicle.EndSignal( "OnDeath" )
	vehicle.EndSignal( "OnFly" )
	
	VehicleWaitNode( vehicle, node )
	
	// thread off so we dont get killed by OnFly endsignal
	thread vehicle.FlyPath( nextNode )
}
	
function VehicleTakesOff( vehicle, node, nextNode )
{
	vehicle.FlyPath( nextNode )
	vehicle.EngineEffectsEnable()
	PlayAnim( vehicle, "test_takeoff", node )
}

function VehicleWaitNode( vehicle, node )
{
	if ( node.HasKey( "WaitFlag" ) )
	{
		Assert( !node.HasKey( "WaitSignal" ), "Node " + node.GetOrigin() + " has multiple waits." )
		Assert( !node.HasKey( "WaitTime" ), "Node " + node.GetOrigin() + " has multiple waits." )

		FlagWait( node.kv.WaitFlag )
	}
	else
	if ( node.HasKey( "WaitSignal" ) )
	{		
		Assert( !node.HasKey( "WaitFlag" ), "Node " + node.GetOrigin() + " has multiple waits." )
		Assert( !node.HasKey( "WaitTime" ), "Node " + node.GetOrigin() + " has multiple waits." )

		vehicle.WaitSignal( node.kv.WaitSignal )
	}		
	else
	if ( node.HasKey( "WaitTime" ) )
	{		
		Assert( !node.HasKey( "WaitFlag" ), "Node " + node.GetOrigin() + " has multiple waits." )
		Assert( !node.HasKey( "WaitSignal" ), "Node " + node.GetOrigin() + " has multiple waits." )

		wait node.kv.WaitTime.tofloat()
	}	
}

function VehicleDropoff( vehicle, node )
{
	if ( !( "dropFunc" in vehicle.s ) )
	{
		// only certain vehicles can drop guys.
		return
	}

	local count = 6
	if ( node.HasKey( "dropoffCount" ) )
	{
		local newCount = node.kv.dropoffCount.tointeger()
		if ( newCount )
			count = newCount
	}

	local side = "both"
	if ( node.HasKey( "dropoffSide" ) && node.kv.dropoffSide != "" )
	{
		side = node.kv.dropoffSide
	}
	
	thread vehicle.s.dropFunc( vehicle, side, count )
}