// _airvehicle_utility.nut

const AIRVEHICLE_FLAG_AWAIT_INPUT	= 0x040

function main()
{
	SetupAirvehicleAnims()
	
	Globalize( FlyPath_Scripted )
	Globalize( Airvehicle_SpawnInit )
	Globalize( Airvehicle_PathSetup )
	Globalize( Airvehicle_Takeoff )
	Globalize( FlyPathAndDelete )
	Globalize( SetRefInfo )
	Globalize( GetRefOrigin )
	Globalize( GetRefAngles )
	Globalize( GetGroundIdleAnim )
	Globalize( VehicleWait )
	Globalize( FlyToSpecificTrackViaPath )
	Globalize( MoveSpecifiedSpeed )
	Globalize( SetupInitialSpeed )
	Globalize( AirVehicleSetCrashPath )
	Globalize( DeprecatedTrackPathFunctionality )	
}

function SetupAirvehicleAnims()
{
	level.airvehicleAnims <- {}
	level.airvehicleAnims.npc_gunship <- {}
	level.airvehicleAnims.npc_gunship.reqModel <- STRATON_MODEL
	level.airvehicleAnims.npc_gunship.takeoff <- "test_takeoff"
	level.airvehicleAnims.npc_gunship.land <- "test_land"
	level.airvehicleAnims.npc_gunship.ground_idle <- "test_runway_idle"
}

function Airvehicle_SpawnInit( airvehicle )
{
	airvehicle.s.startPathEnt <- null
	airvehicle.s.pathChain <- null
	airvehicle.s.endNode <- null
	
	SetRefInfo( airvehicle )
	
	if ( airvehicle.HasKey( "takeoff" ) )
	{
		airvehicle.s.initialTakeoff <- false
		thread Airvehicle_GroundIdle( airvehicle )
	}

	if ( EntHasSpawnflag( airvehicle, AIRVEHICLE_FLAG_AWAIT_INPUT ) )
		airvehicle.Fire( "Activate" )
}

function Airvehicle_PathSetup( vehicle, pathstart )
{
	Assert( pathstart.GetClassname() == "path_track", "pathstart ent specified for " + vehicle + " is a " + pathstart.GetClassname() + ", airvehicles should be flying a chain of path_tracks."  )
	
	if ( !( "startPathEnt" in vehicle.s ) )
		vehicle.s.startPathEnt <- null
	
	if ( !( "pathChain" in vehicle.s ) )
		vehicle.s.pathChain <- null
	
	if ( !( "endNode" in vehicle.s ) )
		vehicle.s.endNode <- null
		
	vehicle.s.pathChain = GetEntityChain( pathstart )
	vehicle.s.endNode = vehicle.s.pathChain[ vehicle.s.pathChain.len() - 1 ]
}

function FlyPathAndDelete( vehicle, path )
{
	MoveSpecifiedSpeed( vehicle, vehicle.s.initialSpeed )
	vehicle.EndSignal( "OnDeath" )
	vehicle.FlyPath( path )
	vehicle.WaitSignal( "OnArrived" )
	vehicle.Kill()
}

function FlyPath_Scripted( airvehicle, pathstart = null, doTakeoff = false )
{
	airvehicle.EndSignal( "OnDeath" )
	
	local vname = airvehicle.GetName()
	
	if ( !pathstart )
	{
		Assert( airvehicle.GetTarget() != "", "Airvehicle doesn't have a fight path start entity specified." )
		pathstart = GetEnt( airvehicle.GetTarget() )
		Assert( pathstart, "Couldn't find targeted ent with name " + airvehicle.GetTarget() )
	}
	
	//printl( vname + " flying path: " + pathstart )
	
	Airvehicle_PathSetup( airvehicle, pathstart )
	
	// if not explicitly told in params to doTakeoff, do it automatically for spawners with "takeoff" set on them
	if ( !doTakeoff )
		if ( "initialTakeoff" in airvehicle.s && airvehicle.s.initialTakeoff == false )
			doTakeoff = true
	
	// TAKEOFF
	if ( doTakeoff )
		waitthread FlyPathAction_Takeoff( airvehicle, pathstart )
	
	if ( !( "didTakeoff" in airvehicle.s ) )
		airvehicle.FlyPath( pathstart )
	
	//printl( airvehicle.GetName() + " starting to fly path, initial desiredSpeed " + airvehicle.Get( "desiredSpeed" ) )
}

function DeprecatedTrackPathFunctionality( vehicle, nextNode, nextNextNode )
{
	// still support the prior functionality for now
	if ( nextNode.HasKey( "land" ) )
	{
		thread FlyPathAction_LandAtNode( vehicle, nextNode, nextNextNode )
	}
	else
	if ( nextNode.HasKey( "delete" ) )
	{
		// the next node has delete so fly to it at full speed
		vehicle.FlyToNodeUseNodeSpeed( nextNode )
		return
	}
}

function FlyPathAction_Takeoff( airvehicle, pathstart )
{
	local vname = airvehicle.GetName()
	
	// for spawners with "takeoff" set on them
	if ( "initialTakeoff" in airvehicle.s )
	{
		/// either we already did initial takeoff, so exit
		if ( airvehicle.s.initialTakeoff == true )
			return
		// or we're doing it right now
		else
			airvehicle.s.initialTakeoff = true
	}
	// not a vehicle that has to take off
	else
		return
	
	waitthread VehicleWait( airvehicle )
	
	waitthread Airvehicle_Takeoff( airvehicle, pathstart )
}

function Airvehicle_Takeoff( airvehicle, pathstart )
{
	airvehicle.kv.isUsingHoverNoise = false
	
	//printl( vname + " taking off" )
	
	if ( EntHasSpawnflag( airvehicle, AIRVEHICLE_FLAG_AWAIT_INPUT ) )
	{
		//printl( vname + " activating" )
		airvehicle.Fire( "Activate" )
		wait 0.1  // HACK, if you don't wait the anim doesn't play correctly
	}
	
	// give flypath command as anim starts
	airvehicle.FlyPath( pathstart )
	
	// reset ref info since he may have moved before takeoff
	SetRefInfo( airvehicle )
	
	local takeoffAnim = GetTakeoffAnim( airvehicle )
	if ( takeoffAnim )
	{
		airvehicle.Anim_PlayWithRefPoint( takeoffAnim, GetRefOrigin( airvehicle ), GetRefAngles( airvehicle ), 0.2 )
		airvehicle.WaitSignal( "OnAnimationDone" )
	}
	
	airvehicle.kv.IsUsingHovernoise = true
	
	if ( !( "didTakeoff" in airvehicle.s ) )
		airvehicle.s.didTakeoff <- true
	else
		airvehicle.s.didTakeoff = true
}

function FlyPathAction_LandAtNode( airvehicle, node, nextNode )
{
	//printl( airvehicle.GetName() + " LANDING at " + node.GetName() )
	
	local landinganim = GetLandingAnim( airvehicle )
	if ( landinganim )
	{
		local nodeOrg = node.GetOrigin()
		local nodeAng = node.GetAngles()
		
		// fly to anim blend start point
		local animStart = airvehicle.Anim_GetStartForRefPoint( landinganim, nodeOrg, nodeAng )
		airvehicle.FlyToPointToAnim( animStart.origin, landinganim )
		airvehicle.WaitSignal( "OnArrived" )
		
		// make him not want to fly away once he's done animating
		airvehicle.FlyToNodeViaPath( node )
		
		// play anim
		airvehicle.Anim_PlayWithRefPoint( landinganim, nodeOrg, nodeAng, 1.2 )
		airvehicle.WaitSignal( "OnAnimationDone" )
	}
	else
	{
		// set this node as our stop target by sending the vehicle a new fly command, this makes the speed want to be zero at the stop point
		airvehicle.FlyToNodeViaPath( node )
		node.WaitSignal( "OnPass" )
	}
	
	//printl( airvehicle.GetName() + " LANDED" )
	
	thread Airvehicle_GroundIdle( airvehicle )
	
	if ( nextNode )
	{
		waitthread VehicleWait( node )
		
		// now continue to fly the path
		thread FlyPath_Scripted( airvehicle, nextNode, true )
	}
}

function Airvehicle_GroundIdle( airvehicle )
{
	// reset reference info since the airvehicle might have moved
	SetRefInfo( airvehicle )
	
	local groundIdleAnim = GetGroundIdleAnim( airvehicle )
	if ( groundIdleAnim )
		airvehicle.Anim_PlayWithRefPoint( groundIdleAnim, GetRefOrigin( airvehicle ), GetRefAngles( airvehicle ), 0 )
	
	airvehicle.kv.isUsingHoverNoise = false
}

function GetTakeoffAnim( airvehicle )
{
	return GetActionAnim( airvehicle, "takeoff" )
}

function GetLandingAnim( airvehicle )
{
	return GetActionAnim( airvehicle, "land" )
}

function GetGroundIdleAnim( airvehicle )
{
	return GetActionAnim( airvehicle, "ground_idle" )
}

function GetActionAnim( airvehicle, actiontype )
{
	Assert( level.airvehicleAnims )
	
	local animArr = level.airvehicleAnims
	local vclass = airvehicle.GetClassname()
	
	if ( vclass in animArr )
	{
		if ( ValidateModelForAnims( airvehicle ) )
		{
			if ( actiontype in animArr[ vclass ] )
				return animArr[ vclass ][ actiontype ]
		}
	}
	
	return null
}

function HasActionAnims( airvehicle )
{
	Assert( level.airvehicleAnims )
	
	local animArr = level.airvehicleAnims
	local vclass = airvehicle.GetClassname()
	
	if ( vclass in animArr )
		return ValidateModelForAnims( airvehicle )
}

// a model's QC must be set up with the correct anims in order to play them
function ValidateModelForAnims( airvehicle )
{
	local vclass = airvehicle.GetClassname()
	
	Assert( "reqModel" in level.airvehicleAnims[ vclass ], "'reqModel' index not set up in level.airvehicleAnims." + vclass )
	
	return ( airvehicle.GetModelName() == level.airvehicleAnims[ vclass ][ "reqModel" ] )
}

function SetRefInfo( vehicle, origin = null, angles = null )
{
	local entOrg = vehicle.GetOrigin()
	local entAng = vehicle.GetAngles()
	
	if ( HasActionAnims( vehicle ) )
	{
		local attach = vehicle.LookupAttachment( "ref" )
		entOrg = vehicle.GetAttachmentOrigin( attach )
		entAng = vehicle.GetAttachmentAngles( attach )
	}
	
	if ( !origin )
		origin = entOrg
	
	if ( !angles )
		angles = entAng
	
	if ( !( "refOrigin" in vehicle.s ) )
		vehicle.s.refOrigin <- origin
	else
		vehicle.s.refOrigin = origin
	
	if ( !( "refAngles" in vehicle.s ) )
		vehicle.s.refAngles <- angles
	else
		vehicle.s.refAngles = angles
}

function GetRefOrigin( vehicle )
{
	Assert( "refOrigin" in vehicle.s )
	
	return vehicle.s.refOrigin
}

function GetRefAngles( vehicle )
{
	Assert( "refAngles" in vehicle.s )
	
	return vehicle.s.refAngles
}


function SetupInitialSpeed( vehicle, defaultSpeed )
{
	Assert( vehicle.HasKey( "desiredSpeed" ), "Entity " + vehicle + " doesn't have key 'desiredSpeed' - are you sure this is a vehicle?" )
	
	local initialSpeed = vehicle.Get( "desiredSpeed" ).tofloat()
	if ( initialSpeed <= 0 )
		initialSpeed = defaultSpeed
	
	vehicle.s.initialSpeed <- initialSpeed
}

function MoveSpecifiedSpeed( ent, speed )
{
	ent.Fire( "MoveSpecifiedSpeed", speed.tofloat() )
}

function FlyToSpecificTrackViaPath( ent, path )
{
	//printl( ent.GetName() + " flying to node " + path.GetName() )
	ent.Fire( "FlyToSpecificTrackViaPath", path.GetName() )
}

function VehicleWait( ent )
{
	ent.EndSignal( "OnDeath" )
	
	if ( ent.HasKey( "waitFlag" ) )
	{
		local waitFlag = ent.Get( "waitFlag" )
		//printl( ent + " waiting on flag " + waitFlag )
		FlagWait( waitFlag )
	}
		
	if ( ent.HasKey( "wait" ) )
	{
		local waitTime = ent.Get( "wait" ).tofloat()
		//printl( ent + " waiting for " + waitTime + " secs" )
		Wait( waitTime )
	}
}


//-----------------------------------------------
// AirVehicleSetCrashPath() - specify specific path to crash to instead of using GetClosest
//-----------------------------------------------
function AirVehicleSetCrashPath( vehicle, pathEnt )
{
	Assert( pathEnt != null, "Air vehicle crash path ent is not valid for " + vehicle )
	Assert( pathEnt.GetClassname != "path_track", "Air vehicle crash path at " + pathEnt.GetOrigin() + " needs to be a path_track entity" )
	vehicle.s.crashLocationOverride <- pathEnt
}
