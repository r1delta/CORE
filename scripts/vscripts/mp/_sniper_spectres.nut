
const MAXNODES_PER_SNIPERSPOT 	= 4
const MAX_SNIPERSPOTS 			= 30 // for speed of iterating through the array
const SNIPERSPOT_RADIUSCHECK 	= 200
const SNIPERSPOT_HEIGHTCHECK 	= 160
const SNIPERNODE_TOOCLOSE_SQR	= 2500//50x50

function main()
{
	FlagInit( "TD_SniperLocationsInit" )

	level.TowerDefense_SniperNodes <- []
}

function EntitiesDidLoad()
{
	thread SniperLocationsInit()
}

function SpawnSniperSpectre( team, squadName, origin, angles )
{
	local spectre = SpawnSpectre( team, squadName, origin, angles )
	MakeSniperSpectre( spectre )
	return spectre
}
Globalize( SpawnSniperSpectre )

function MakeSniperSpectre( sniper )
{
	sniper.SetModel( SNIPER_SPECTRE_MODEL )
	sniper.SetSkin( 3 )

	sniper.SetTitle( "#NPC_SPECTRE_SNIPER" )
	sniper.Minimap_SetDefaultMaterial( "vgui/hud/sniper_minimap_orange" )
	sniper.Minimap_SetZOrder( 10 )
	sniper.SetSubclass( eSubClass.sniperSpectre )

	sniper.kv.additionalequipment = "mp_weapon_dmr"
	sniper.TakeActiveWeapon()
	sniper.GiveWeapon( "mp_weapon_dmr", [ "scope_4x" ] )

	sniper.s.atWeapon <- "mp_weapon_defender"
	sniper.s.useRPGPreference = RPG_USE_ALWAYS

	sniper.Signal( "Stop_SimulateGrenadeThink" )
	sniper.TakeOffhandWeapon( 0 )
	sniper.StayPut( true )
	sniper.AllowSpectreTraverse( true )

	sniper.s.sniperNode <- null
	thread Sniper_FreeSniperNodeOnDeath( sniper )
}


/************************************************************************************************\

########  #######   #######  ##        ######
   ##    ##     ## ##     ## ##       ##    ##
   ##    ##     ## ##     ## ##       ##
   ##    ##     ## ##     ## ##        ######
   ##    ##     ## ##     ## ##             ##
   ##    ##     ## ##     ## ##       ##    ##
   ##     #######   #######  ########  ######

\************************************************************************************************/
function TowerDefense_AddSniperLocation( origin, yaw, heightCheck = SNIPERSPOT_HEIGHTCHECK )
{
	Assert( !Flag( "TD_SniperLocationsInit" ), "sniper locations added too late" )
	Assert( ( level.TowerDefense_SniperNodes.len() < MAX_SNIPERSPOTS ), "adding too many snper locations, max is " + MAX_SNIPERSPOTS )

	local loc = CreateSniperLocation( origin, yaw, heightCheck )

	level.TowerDefense_SniperNodes.append( loc )
}
Globalize( TowerDefense_AddSniperLocation )

function Dev_AddSniperLocation( origin, yaw, heightCheck = SNIPERSPOT_HEIGHTCHECK )
{
	thread __AddSniperLocationInternal( origin, yaw, heightCheck )
}

function __AddSniperLocationInternal( origin, yaw, heightCheck )
{
	local loc = CreateSniperLocation( origin, yaw, heightCheck )
	SniperLocationSetup( loc )
	DebugDrawSingleSniperLocation( loc, 4 )
}
Globalize( Dev_AddSniperLocation )

function DebugDrawSniperLocations()
{
	foreach ( loc in level.TowerDefense_SniperNodes )
		DebugDrawSingleSniperLocation( loc, 600 )
}
Globalize( DebugDrawSniperLocations )

function DebugDrawSingleSniperLocation( loc, time )
{
	if ( !loc.maxGuys )
	{
		DebugDrawSniperSpot( loc.pos, [ 32, 40, 48 ], 255, 0, 0, time, loc.yaw )
		return
	}

	DebugDrawSniperSpot( loc.pos, [ 28 ], 20, 20, 20, time, loc.yaw )

	foreach ( node in loc.coverNodes )
		DebugDrawSniperSpot( node.pos, [ 16, 24, 32 ], 50, 50, 255, time, null, loc.pos )

	foreach ( node in loc.extraNodes )
		DebugDrawSniperSpot( node.pos, [ 14, 22, 30 ], 255, 0, 255, time, null, loc.pos )
}

function DebugDrawSniperSpot( pos, radii, r, g, b, time, yaw = null, pos2 = null )
{
	foreach ( radius in radii )
		DebugDrawCircle( pos, Vector( 0, 0, 0 ), radius, r, g, b, time )

	if ( yaw != null )
	{
		local angles 	= Vector( 0, yaw, 0 )
		local forward 	= angles.AnglesToForward()
		local right 	= angles.AnglesToRight()
		local length 	= radii[ radii.len() - 1 ]
		local endPos 	= pos + ( forward * ( length * 1.75 ) )
		local rightPos 	= pos + ( right * length )
		local leftPos 	= pos + ( right * -length )
		DebugDrawLine( pos, 		endPos, r, g, b, true, time )
		DebugDrawLine( rightPos, 	endPos, r, g, b, true, time )
		DebugDrawLine( leftPos, 	endPos, r, g, b, true, time )

		local ring = GetDesirableRing( pos, yaw )
		DebugDrawCircle( ring.pos, Vector( 0, 0, 0 ), ring.radius, r, g, b, time )
	}

	if ( pos2 != null )
		DebugDrawLine( pos, pos2, r, g, b, true, time )
}

/************************************************************************************************\

########     ###    ######## ##     ## #### ##    ##  ######
##     ##   ## ##      ##    ##     ##  ##  ###   ## ##    ##
##     ##  ##   ##     ##    ##     ##  ##  ####  ## ##
########  ##     ##    ##    #########  ##  ## ## ## ##   ####
##        #########    ##    ##     ##  ##  ##  #### ##    ##
##        ##     ##    ##    ##     ##  ##  ##   ### ##    ##
##        ##     ##    ##    ##     ## #### ##    ##  ######

\************************************************************************************************/
//HACK -> this should probably move into code
function Sniper_MoveToNewLocation( sniper )
{
	sniper.EndSignal( "OnDeath" )
	sniper.EndSignal( "OnDestroy" )

	delaythread( 2 ) SniperCloak( sniper )

	//go searching for nodes that are up somewhere
	local sniperNode = GetRandomSniperNodeWithin( sniper, 3000 )

	Sniper_FreeSniperNode( sniper )//free his current node
	Sniper_TakeSniperNode( sniper, sniperNode )
	Sniper_AssaultLocation( sniper, sniperNode )

	WaitSignal( sniper, "OnFinishedAssault", "OnDeath", "OnDestroy", "AssaultTimeOut" )

	SniperDeCloak( sniper )
}
Globalize( Sniper_MoveToNewLocation )

function Sniper_TakeSniperNode( sniper, sniperNode )
{
	Assert( sniper.s.sniperNode == null ) // didn't free the last one
	sniper.s.sniperNode = sniperNode

	Assert( sniperNode.locked == false )// someone else already has it?
	sniperNode.locked = true

	local loc = sniperNode.loc
	loc.numGuys++
}

function Sniper_FreeSniperNode( sniper )
{
	local sniperNode = sniper.s.sniperNode
	if ( sniperNode == null )
		return

	sniper.s.sniperNode = null

	local loc = sniperNode.loc
	loc.numGuys--
	sniperNode.locked = false
}

function Sniper_FreeSniperNodeOnDeath( sniper )
{
	sniper.WaitSignal( "OnDeath" )
	Sniper_FreeSniperNode( sniper )
}

function SniperCloak( sniper )
{
	if ( !IsAlive( sniper ) )
		return

	if ( !sniper.CanCloak() )
		return

	sniper.kv.allowshoot = 0
	sniper.SetCloakDuration( 3.0, -1, 0 )
	sniper.Minimap_Hide( TEAM_IMC, null )
	sniper.Minimap_Hide( TEAM_MILITIA, null )
}
Globalize( SniperCloak )

function SniperDeCloak( sniper )
{
	if ( !IsAlive( sniper ) )
		return

	sniper.kv.allowshoot = 1
	sniper.SetCloakDuration( 0, 0, 1.5 )
	sniper.Minimap_AlwaysShow( TEAM_IMC, null )
	sniper.Minimap_AlwaysShow( TEAM_MILITIA, null )
}
Globalize( SniperDeCloak )


function Sniper_AssaultLocation( sniper, sniperNode )
{
	Assert( sniper.s.sniperNode == sniperNode ) // didn't get the right one

	local origin 	= sniperNode.pos
	local loc 		= sniperNode.loc
	local angles 	= Vector( 0, loc.yaw, 0 )

	Assert( "assaultPoint" in sniper.s )
	SniperAssaultPointSetup( sniper.s.assaultPoint )

	sniper.s.assaultPoint.SetOrigin( origin )
	if ( angles != null )
		sniper.s.assaultPoint.SetAngles( angles )

	sniper.AssaultPointEnt( sniper.s.assaultPoint )
	sniper.StayPut( true )
}

function SniperAssaultPointSetup( point )
{
	point.kv.stopToFightEnemyRadius = 0		//will stop moving and fight if enemy within this radius
	point.kv.allowdiversionradius = 0
	point.kv.allowdiversion = 0
	point.kv.faceAssaultPointAngles = 1
	point.kv.assaulttolerance = 256				//once at the assault point will move around within this radius to engage
	point.kv.nevertimeout = 1
	point.kv.strict = 1
	point.kv.forcecrouch = 0
	point.kv.spawnflags = 0
	point.kv.finalDestination = 1
	point.kv.clearoncontact = 0				//clear on enemy contact ( sight only, not shot at )
	point.kv.assaulttimeout = 0
	point.kv.arrivaltolerance = 100			//the radius from the point at which we have arrived
}

function GetRandomSniperNodeWithin( sniper, maxDist )
{
	Assert( level.TowerDefense_SniperNodes.len() >= 2 )

	local origin = sniper.GetOrigin()
	local locations = SniperNodeWithin( level.TowerDefense_SniperNodes, origin, maxDist )

	if ( locations.len() )
		ArrayRandomize( locations )

	local goalNode = FindFreeSniperNode( locations )
	if ( goalNode != null )
		return goalNode

	//if we get here it's because there are no free nodes within the maxDist
	local locations = SniperNodeClosest( level.TowerDefense_SniperNodes, origin )

	local goalNode = FindFreeSniperNode( locations )
	Assert ( goalNode != null )

	return goalNode
}

function FindFreeSniperNode( locations )
{
	foreach( loc in locations )
	{
		//is if filled up?
		if ( loc.numGuys >= loc.maxGuys )
			continue

		//grab the first unlocked cover node
		foreach ( node in loc.coverNodes )
		{
			if ( node.locked )
				continue

			return node
		}

		//ok then grab the first unlocked extra node
		foreach ( node in loc.extraNodes )
		{
			if ( node.locked )
				continue

			return node
		}
	}

	return null
}

//ArrayWithin() copy
function SniperNodeWithin( array, origin, maxDist )
{
	maxDist *= maxDist

	local resultArray = []
	foreach( loc in array )
	{
		local testspot = null
		testspot = loc.pos

		local dist = DistanceSqr( origin, testspot )
		if ( dist <= maxDist )
			resultArray.append( loc )
	}
	return resultArray
}

//ArrayClosest() copy
function SniperNodeClosest( array, origin )
{
	Assert( type( array ) == "array" )
	local allResults = SniperArrayDistanceResults( array, origin )

	allResults.sort( DistanceCompareClosest )

	local returnEntities = []

	foreach ( index, result in allResults )
	{
		returnEntities.insert( index, result.loc )
	}

	// the actual distances aren't returned
	return returnEntities
}

function SniperArrayDistanceResults( array, origin )
{
	Assert( type( array ) == "array" )
	local allResults = []

	foreach ( loc in array )
	{
		local results = {}
		local testspot = null

		testspot = loc.pos

		results.distanceSqr <- ( testspot - origin ).LengthSqr()
		results.loc <- loc
		allResults.append( results )
	}

	return allResults
}


/************************************************************************************************\

########  ########  ########          ######     ###    ##        ######
##     ## ##     ## ##               ##    ##   ## ##   ##       ##    ##
##     ## ##     ## ##               ##        ##   ##  ##       ##
########  ########  ######   ####### ##       ##     ## ##       ##
##        ##   ##   ##               ##       ######### ##       ##
##        ##    ##  ##               ##    ## ##     ## ##       ##    ##
##        ##     ## ########          ######  ##     ## ########  ######

\************************************************************************************************/
function CreateSniperLocation( origin, yaw, heightCheck )
{
	local loc = {}
	loc.pos 		<- origin
	loc.yaw 		<- yaw
	loc.heightCheck <- heightCheck
	loc.numGuys		<- 0
	loc.maxGuys 	<- 0
	loc.coverNodes 	<- []
	loc.extraNodes	<- []

	return loc
}

function CreateSniperNode( location, origin )
{
	local node = {}
	node.locked <- false
	node.loc 	<- location
	node.pos 	<- origin

	return node
}

function SniperLocationsInit()
{
	FlagSet( "TD_SniperLocationsInit" )
	local time = Time()

	foreach ( loc in level.TowerDefense_SniperNodes )
	{
		SniperLocationSetup( loc )
		wait 0.1 //space out all the slow stuff so it doesn't happen on the same frame
	}

	printt( "<<<<<***********************************************************>>>>>" )
	printt( "SniperLocationsInit() took ", Time() - time, " seconds to complete" )
	printt( "<<<<<***********************************************************>>>>>" )
}

function SniperLocationSetup( loc )
{
	local coverPos = GetCoverNodesAroundSniperLocation( loc.pos, loc.yaw, loc.heightCheck, MAXNODES_PER_SNIPERSPOT )
	foreach ( origin in coverPos )
	{
		local node = CreateSniperNode( loc, origin )
		loc.coverNodes.append( node )
	}

	if ( loc.coverNodes.len() == MAXNODES_PER_SNIPERSPOT )
		return

	wait 0.1 //space out all the slow stuff so it doesn't happen on the same frame
	local extraPos = GetExtraNodesAroundSniperLocation( loc.pos, loc.yaw, loc.heightCheck, MAXNODES_PER_SNIPERSPOT - loc.coverNodes.len(), coverPos )
	foreach ( origin in extraPos )
	{
		local node = CreateSniperNode( loc, origin )
		loc.extraNodes.append( node )
	}

	loc.maxGuys = loc.coverNodes.len() + loc.extraNodes.len()
	if ( loc.maxGuys == 0 )
		printt( "sniper spot at [ " + loc.pos + " ] has no nodes around it within " + SNIPERSPOT_RADIUSCHECK + " units." )
	Assert( loc.maxGuys <= MAXNODES_PER_SNIPERSPOT )
}

function GetCoverNodesAroundSniperLocation( pos, yaw, heightCheck, max )
{
	local height 		= pos.z
	local isSpectre 	= true
	local radius 		= SNIPERSPOT_RADIUSCHECK
	local nearestNode 	= GetNearestNodeToPos( pos )
	local goalPos 	= []

	local coverNodes 	= GetNearbyCoverNodes( nearestNode, 4, HULL_HUMAN, isSpectre, radius, yaw, 90 )
	local coverPos	 	= SortNodesByClosestToPos( coverNodes, pos, yaw )
	foreach( origin in coverPos )
	{
		if ( fabs( origin.z - height ) > heightCheck )
			continue

		if ( !IsMostDesireablePos( origin, pos, yaw ) )
			continue

		if ( IsPosTooCloseToOtherPositions( origin, goalPos ) )
			continue

		goalPos.append( origin )
		if ( goalPos.len() == max )
			break
	}

	return goalPos
}

function GetExtraNodesAroundSniperLocation( pos, yaw, heightCheck, max, coverPos )
{
	local height 		= pos.z
	local isSpectre 	= true
	local radius 		= SNIPERSPOT_RADIUSCHECK
	local nearestNode 	= GetNearestNodeToPos( pos )
	local goalPos 		= []

	local neighborNodes = GetNeighborNodes( nearestNode, 10, HULL_HUMAN )
	local neighborPos 	= SortNodesByClosestToPos( neighborNodes, pos, yaw )
	foreach( origin in neighborPos )
	{
		if ( fabs( origin.z - height ) > heightCheck )
			continue

		if ( !IsMostDesireablePos( origin, pos, yaw ) )
			continue

		if ( IsPosTooCloseToOtherPositions( origin, coverPos ) )
			continue

		if ( IsPosTooCloseToOtherPositions( origin, goalPos ) )
			continue

		goalPos.append( origin )
		if ( goalPos.len() == max )
			break
	}

	return goalPos
}

function SortNodesByClosestToPos( nodes, pos, yaw )
{
	local ring 		= GetDesirableRing( pos, yaw )
	local testPos 	= ring.pos

	local testOrigins = []
	foreach( node in nodes )
	{
		if ( node < 0 )//invalid
			continue

		testOrigins.append( GetNodePos( node, HULL_HUMAN ) )
	}

	local returnOrigins = ArrayClosest( testOrigins, testPos )
	return returnOrigins
}

function IsPosTooCloseToOtherPositions( testPos, positions )
{
	foreach ( pos in positions )
	{
		if ( DistanceSqr( pos, testPos ) <= SNIPERNODE_TOOCLOSE_SQR )
			return true
	}
	return false
}

function IsMostDesireablePos( testPos, sniperPos, yaw )
{
	/*
	what this function does is actually draw a circle out infront of the position based on the yaw.
	then it checks to see if the node is within that circle.
	Since most sniper positions are on EDGES of buildings, windows, etc, this techinique helps grab more nodes along the edge
	*/

	local ring 		= GetDesirableRing( sniperPos, yaw )
	local radiusSqr = ring.radius * ring.radius

	if ( Distance2DSqr( testPos, ring.pos ) <= radiusSqr )
		return true

	return false
}

function GetDesirableRing( pos, yaw )
{
	local dist 		= 200
	local radius 	= 300

	local vec 		= Vector( 0, yaw, 0 ).AnglesToForward() * dist
	local testPos 	= pos + vec

	local ring = {}
	ring.pos <- testPos
	ring.radius <- radius
	return ring
}






