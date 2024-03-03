::ANALYSIS_PREVIEW_TIME <- 5.0

function main()
{
	Globalize( GetOriginFromPoint )
	Globalize( GetAnalysisSpawn_ClosestYaw )
	Globalize( GetAnalysisSpawn_Nearest )
	Globalize( GetAnalysisNodePos )
	Globalize( GetSpawnPointForStyle )
	Globalize( CreateCallinTable )
	Globalize( GetPointFromPosition )
	Globalize( IsLegalFlightPath )
	Globalize( GetAnalysisForModel )
	Globalize( GetFlightPathPoints )
	Globalize( GetAnglesFromPoint )
	Globalize( NodeAnalysis )
	Globalize( GetSpawnPoint_ClosestYaw )
	Globalize( GetWarpinPosition )
	Globalize( GetAnalysisDataIndex )
	Globalize( NodeAnalysisPreview )
	Globalize( NodeHasFlightPath )
	Globalize( IsLegalFlightPath_OverTime )
}

function GetOriginFromPoint( point, world, forward, right )
{
	local origin = VectorCopy( world )
	origin += forward * point.origin.x
	origin += right * -point.origin.y
	origin += Vector(0,0,point.origin.z)
	return origin
}

function GetAnglesFromPoint( point, angles )
{
	local angResult = VectorCopy( angles )
	local angResult = angResult.AnglesCompose( point.angles )

	return angResult
}

function GetFlightPathPoints( analysis, origin, forward, right )
{
	local orgs = []
	for ( local i = 0; i < analysis.points.len(); i++ )
	{
		local point = analysis.points[i]
		local origin = GetOriginFromPoint( point, origin, forward, right )

		orgs.append( origin )
	}

	return orgs
}

function GetAnalysisNodePos( analysis, node, hull )
{
	local origin = GetNodePos( node, hull )

	if ( analysis.model in level.superCallinOffset )
	{
		origin.z += level.superCallinOffset[ analysis.model ]
	}

	return origin
}

function GetAnalysisForModel( model, animation )
{
	if ( !( model in level.flightAnalysis ) )
		return null

	if ( !( animation in level.flightAnalysis[ model ] ) )
		return null

	return level.flightAnalysis[ model ][ animation ]
}

function GetPointFromPosition( dropship )
{
	local point = {}
	point.origin <- dropship.GetOrigin()

	local attach_id = dropship.LookupAttachment( "ORIGIN" )

	if ( attach_id == 0 )
	{
		point.angles <- dropship.GetAngles()
	}
	else
	{
		point.angles <- dropship.GetAttachmentAngles( attach_id )
	}

	return point
}

function IsLegalFlightPath( analysis, origin, forward, right, draw = false )
{
	local orgs = GetFlightPathPoints( analysis, origin, forward, right )

	local endPos = orgs[ orgs.len()-1 ]

	DoTraceCoordCheck( false )

	for ( local i = 1; i < orgs.len(); i++ )
	{
		local result = TraceHull( orgs[i-1], orgs[i], analysis.mins, analysis.maxs, null, analysis.traceMask, TRACE_COLLISION_GROUP_NONE )
		if ( result.fraction < 1 )
		{
			if ( result.hitSky )
			{
				DebugDrawLine( orgs[i-1], orgs[i], 0, 255, 0, true, ANALYSIS_PREVIEW_TIME )
				continue
			}

			if ( Distance( result.endPos, endPos ) > 16 )
			{
				if ( draw )
					DebugDrawLine( orgs[i-1], orgs[i], 255, 0, 0, true, ANALYSIS_PREVIEW_TIME )
				
				DoTraceCoordCheck( true )
				return false
			}
		}

		if ( draw )
			DebugDrawLine( orgs[i-1], orgs[i], 0, 255, 0, true, ANALYSIS_PREVIEW_TIME )
	}

//	DebugDrawLine( result.endPos, result.endPos + RandomVec( 50 ), 255, 255, 0, true, 0.2 )
	DoTraceCoordCheck( true )
	return true
}

function IsLegalFlightPath_OverTime( analysis, origin, forward, right, draw = false )
{
	local orgs = GetFlightPathPoints( analysis, origin, forward, right )

	local endPos = orgs[ orgs.len()-1 ]

	DoTraceCoordCheck( false )

	for ( local i = 1; i < orgs.len(); i++ )
	{
		local result = TraceHull( orgs[i-1], orgs[i], analysis.mins, analysis.maxs, null, analysis.traceMask, TRACE_COLLISION_GROUP_NONE )
		if ( result.fraction < 1 )
		{
			if ( result.hitSky )
			{
				if ( draw )
					DebugDrawLine( orgs[i-1], orgs[i], 0, 255, 0, true, ANALYSIS_PREVIEW_TIME )
				continue
			}

			if ( Distance( result.endPos, endPos ) > 16 )
			{
				if ( draw )
					DebugDrawLine( orgs[i-1], orgs[i], 255, 0, 0, true, ANALYSIS_PREVIEW_TIME )

				DoTraceCoordCheck( true )
				return false
			}
		}

		if ( draw )
			DebugDrawLine( orgs[i-1], orgs[i], 0, 255, 0, true, ANALYSIS_PREVIEW_TIME )

		wait 0
	}

//	DebugDrawLine( result.endPos, result.endPos + RandomVec( 50 ), 255, 255, 0, true, 0.2 )
	DoTraceCoordCheck( true )
	return true
}


function GetAnalysisDataIndex( analysis )
{
	return level.ainAnalysisIndices[ analysis.model ][ analysis.anim ] * ANALYSIS_STEPS
}

function NodeAnalysis( analysis, index, offset )
{
	local array = []
	array.resize( ANALYSIS_STEPS )

	local origin = GetNodePos( index, analysis.hull )
	origin = origin + offset

	TryAnalysisAtOrigin( analysis, array, origin )

	local dataIndex = GetAnalysisDataIndex( analysis )
	local count = 0

	for ( local p = 0; p < array.len(); p++ )
	{
		if ( !array[ p ] )
		{
			//printt( index + " " + p )
			continue
		}

		SetNodeScriptData_Boolean( index, dataIndex + p, true )
		count++
		//printt( index + " *" + p + "*" )
	}
	return count
}

function NodeAnalysisPreview( analysis, index, offset )
{
	local array = []
	array.resize( ANALYSIS_STEPS )

	local origin = GetNodePos( index, analysis.hull )
	origin = origin + offset

	TryAnalysisAtOriginPreview( analysis, array, origin )
	local dataIndex = GetAnalysisDataIndex( analysis )
	local count = 0

	for ( local p = 0; p < array.len(); p++ )
	{
		if ( !array[ p ] )
		{
			printt( ( p + dataIndex ) + ": False" )
			continue
		}

		printt( ( p + dataIndex ) + ": True" )
		local yaw = p * ANALYSIS_YAW_STEP
		local angles = Vector( 0, yaw, 0 )
		local forward = angles.AnglesToForward()
		//DebugDrawLine( origin, origin + forward * 80, 255, 100, 0, true, 5.0 )
		count++
	}
	return count
}

function TryAnalysisAtOrigin( analysis, array, origin )
{
	local prep = "analysisPrepSpawnpointFunc" in analysis
	for ( local i = 0; i < array.len(); i++ )
	{
		local yaw = i * ANALYSIS_YAW_STEP
		local org = VectorCopy( origin )
		if ( prep )
		{
			local newOrg = analysis.analysisPrepSpawnpointFunc( analysis, origin, yaw )
			if ( newOrg )
				org = newOrg
		}

		if ( !analysis.analysisFunc( analysis, org, yaw ) )
			continue

		array[ i ] = true
	}
}

function TryAnalysisAtOriginPreview( analysis, array, origin )
{
	TryAnalysisAtOrigin( analysis, array, origin )
}

function GetNearestSpawnPointFromFunc( analysis, origin, count, getFunc, var = null )
{
	//DebugDrawLine( origin, origin + Vector(0,0,100), 255, 0, 255, true, 2.0 )
	local node = GetNearestNodeToPos( origin )
	if ( node == -1 )
	{
		//DebugDrawLine( origin, origin + Vector(0,0,100), 255, 0, 0, true, 5.0 )
		origin = OriginToGround( origin )
		node = GetNearestNodeToPos( origin )

		if ( node == -1 )
		{
			//DebugDrawLine( origin, origin + Vector(0,0,100), 255, 0, 0, true, 5.0 )
			return null
		}
	}

	//DebugDrawLine( origin, GetNodePos( node, analysis.hull ), 0, 255, 0, true, 5.0 )

	local dataIndex = GetAnalysisDataIndex( analysis )

	if ( NodeAvailable( node ) )
	{
		local foundSpawnYaw = getFunc( node, dataIndex, var )
		if ( foundSpawnYaw != null )
			return CreateSpawnPoint( analysis, node, foundSpawnYaw )
	}

	local neighborNodes = GetNeighborNodes( node, count, analysis.hull )
	node = null

	//DebugDrawText( origin, neighborNodes.len() + "", true, 5.0 )


	for ( local i = 0; i < neighborNodes.len(); i++ )
	{
		local neighborNode = neighborNodes[i]
		if ( !NodeAvailable( neighborNode ) )
			continue
		//DebugDrawLine( GetNodePos( neighborNode, HULL_HUMAN ), origin, 255, 255, 0, true, 2.0 )

		local foundSpawnYaw = getFunc( neighborNode, dataIndex, var )
		if ( foundSpawnYaw != null )
			return CreateSpawnPoint( analysis, neighborNode, foundSpawnYaw )
	}

	return null
}

function GetAnalysisSpawn_ClosestToOriginInOtherHalf( analysis, origin, ownerEyePos, yaw )
{
	local nearestNodes = 32
	if ( GetAINScriptVersion() != AIN_REV )
		return

	//DebugDrawLine( origin, origin + Vector(0,0,100), 255, 0, 255, true, 2.0 )
	local node = GetNearestNodeToPos( origin )
	if ( node == -1 )
	{
//		DebugDrawLine( origin, origin + Vector(0,0,100), 255, 0, 0, true, 5.0 )
		node = GetNearestNodeToPos( OriginToGround( origin ) )

		if ( node == -1 )
		{
//			DebugDrawLine( origin, origin + Vector(0,0,100), 255, 0, 0, true, 5.0 )
			return null
		}
	}


	local dataIndex = GetAnalysisDataIndex( analysis )

	// found a node
	//DebugDrawLine( origin, GetNodePos( node, analysis.hull ), 0, 255, 0, true, 5.0 )

	// does the actual node work?
	local foundYaw = GetSpawnPoint_ClosestYaw( node, dataIndex, yaw, 360 )
	if ( foundYaw )
		return CreateSpawnPoint( analysis, node, foundYaw )

	// if not, lets try neighbor nodes
	local forward = ownerEyePos - origin
	forward.Norm()

	local masterNodeOrigin = GetNodePos( node, analysis.hull )
	local neighborNodes = GetNeighborNodes( node, nearestNodes, 0 ) // analysis.hull )

	local closestYaw = null
	local closestNode = null
	local closestDist = 9999
	local newDist

	for ( local nodeIndex = 0; nodeIndex < neighborNodes.len(); nodeIndex++ )
	{
		local node = neighborNodes[ nodeIndex ]
		local nodeOrigin = GetNodePos( node, analysis.hull )
		local foundYaw = GetSpawnPoint_ClosestYaw( node, dataIndex, yaw, 360 )

		if ( foundYaw == null )
		{
			//DebugDrawLine( masterNodeOrigin, nodeOrigin, 155, 100, 0, true, 5.0 )
			continue
		}

		local vec = nodeOrigin - origin
		if ( vec.Dot( forward ) < 0.0 )
		{
			//DebugDrawLine( masterNodeOrigin, nodeOrigin, 255, 0, 0, true, 5.0 )
			continue
		}

		//DebugDrawLine( masterNodeOrigin, nodeOrigin, 0, 255, 0, true, 5.0 )
		newDist = Distance( nodeOrigin, origin )
		if ( newDist >= closestDist )
			continue

		closestDist = newDist
		closestNode = node
		closestYaw = foundYaw
	}

	if ( closestNode )
		return CreateSpawnPoint( analysis, closestNode, closestYaw )

	return null
}

function GetAnalysisSpawn_ClosestYaw( analysis, origin, yaw, nearestNodes = 10 )
{
	Assert( GetAINScriptVersion() == AIN_REV, "AIN out of date" )

	if ( yaw < 0 )
	{
		yaw += 360
	}
	else
	{
		yaw %= 360
	}

	Assert( yaw >= 0 && yaw <= 360 )

	return GetNearestSpawnPointFromFunc( analysis, origin, nearestNodes, GetSpawnPoint_ClosestYaw, yaw )
}

function GetAnalysisSpawn_Nearest( analysis, origin, count )
{
	if ( GetAINScriptVersion() != AIN_REV )
		return
	return GetNearestSpawnPointFromFunc( analysis, origin, count, GetSpawnPoint_Random )
}

function CreateSpawnPoint( analysis, node, spawnYaw )
{
	local table = {}
	table.origin <- GetNodePos( node, analysis.hull )
	table.angles <- Vector( 0, spawnYaw, 0 )
	table.node <- node

	if ( analysis.model in level.superCallinOffset )
	{
		table.origin.z += level.superCallinOffset[ analysis.model ]
	}

	return table
}

function GetSpawnPoint_ClosestYaw( nodeIndex, dataIndex, desiredYaw, lowestYawDifference = ANALYSIS_YAW_STEP )
{
	local yaw
	local closestYaw = null
	local dif

	for ( local i = 0; i < ANALYSIS_STEPS; i++ )
	{
//		local org = GetNodePos( nodeIndex, 0 )
		if ( !GetNodeScriptData_Boolean( nodeIndex, i + dataIndex ) )
		{
//			DebugDrawLine( org, org + Vector(0,0,100 ), 255, 150, 0, true, 5.0 )
			continue
		}

		yaw = i * ANALYSIS_YAW_STEP
		dif = YawDifference( desiredYaw, yaw )
		if ( dif > lowestYawDifference )
		{
//			DebugDrawLine( org, org + Vector(0,0,100 ), 0, 100, 255, true, 5.0 )
			continue
		}


//		DebugDrawLine( org, org + Vector(0,0,100 ), 0, 255, 0, true, 5.0 )
		lowestYawDifference = dif
		closestYaw = yaw
	}

	if ( closestYaw != null )
	{
		Assert( closestYaw >= 0 && closestYaw <= 360 )
	}
	return closestYaw
}

function GetSpawnPoint_Random( nodeIndex, dataIndex, _ )
{
	local yaw
	local legalYaws = []

	for ( local i = 0; i < ANALYSIS_STEPS; i++ )
	{
		if ( !GetNodeScriptData_Boolean( nodeIndex, i + dataIndex ) )
			continue

		yaw = i * ANALYSIS_YAW_STEP
		legalYaws.append( yaw )
	}

	if ( !legalYaws.len() )
		return null

	return Random( legalYaws )
}

function FindNearestDropPosWithYawAndFallback( analysis, drop )
{
	local angles = Vector( 0, drop.yaw, 0 )
	local forward = angles.AnglesToForward()

	// try in front of us
	return GetAnalysisSpawn_ClosestYaw( analysis, drop.origin, drop.yaw, 30 )
}

function FindNearestDropPositionWithYaw( analysis, drop )
{
	local angles = Vector( 0, drop.yaw, 0 )
	local forward = angles.AnglesToForward()

	// try in front of us
	return GetAnalysisSpawn_ClosestYaw( analysis, drop.origin, drop.yaw, 10 )
}

function FindNearestDropPosition( analysis, drop )
{
//	local angles = Vector( 0, drop.yaw, 0 )
//	local forward = angles.AnglesToForward()

	// try in front of us
	return GetAnalysisSpawn_Nearest( analysis, drop.origin, 5 )
}

/*
function FindSpawnpointAtDistance( analysis, drop )
{
	local node, dist, origin
	local pumpOrigin = drop.origin
	local found = []

	if ( drop.yaw )
	{
		local forward = Vector(0, drop.yaw, 0).AnglesToForward()
		pumpOrigin += forward * drop.dist
		drop.dist = 800
	}

	local maxDist = 0
	local mostDistant = null

	local spawnPoints = GetSpawnPoints( analysis )

	foreach ( node, yaws in spawnPoints )
	{
		if ( !yaws.len() )
			continue

		origin = GetNodePos( node, analysis.hull )
		dist = Distance( origin, pumpOrigin )

		if ( dist > maxDist )
		{
			maxDist = dist
		}

		if ( dist >= drop.dist )
		{
			local spawn = CreateSpawnPoint( analysis, node, yaws[0] )
			spawn.dist <- dist // add this for sorting
			found.append( spawn )
		}
	}


	if ( !found.len() )
	{
		maxDist *= 0.9
		foreach ( node, yaws in spawnPoints )
		{
			if ( !yaws.len() )
				continue

			origin = GetNodePos( node, analysis.hull )
			dist = Distance( origin, pumpOrigin )

			if ( dist > maxDist )
			{
				local spawn = CreateSpawnPoint( analysis, node, yaws[0] )
				spawn.dist <- dist // add this for sorting
				found.append( spawn )
			}
		}

		if ( !found.len() )
			return
	}

	found.sort( CallinCompare )
	local result = found[0]

	local vec = drop.origin - result.origin
	local angles = VectorToAngles( vec )

	local table = {}
	table.origin <- result.origin
	table.yaw <- angles.y

	local betterResult = FindNearestDropPositionWithYaw( analysis, table )

	if ( betterResult )
	{
		return betterResult
	}

	return result
}
*/

function CallinCompare( a, b )
{
	if ( a.dist < b.dist )
		return -1
	if ( a.dist > b.dist )
		return 1
	return 0
}



function GetHotdropNodes( analysis, origin, count, getFunc, var = null )
{
	//DebugDrawLine( origin, origin + Vector(0,0,100), 255, 0, 255, true, 2.0 )
	local node = GetNearestNodeToPos( origin )
	if ( node == -1 )
	{
		//DebugDrawLine( origin, origin + Vector(0,0,100), 255, 0, 0, true, 5.0 )
		origin = OriginToGround( origin )
		node = GetNearestNodeToPos( origin )

		if ( node == -1 )
		{
			//DebugDrawLine( origin, origin + Vector(0,0,100), 255, 0, 0, true, 5.0 )
			return null
		}
	}

	//DebugDrawLine( origin, GetNodePos( node, analysis.hull ), 0, 255, 0, true, 5.0 )

	local dataIndex = GetAnalysisDataIndex( analysis )

	local foundSpawnYaw = getFunc( node, dataIndex, var )
	if ( foundSpawnYaw != null )
		return CreateSpawnPoint( analysis, node, foundSpawnYaw )

	local neighborNodes = GetNeighborNodes( node, count, analysis.hull )
	node = null

	//DebugDrawText( origin, neighborNodes.len() + "", true, 5.0 )


	for ( local i = 0; i < neighborNodes.len(); i++ )
	{
		local neighborNode = neighborNodes[i]
		//DebugDrawLine( GetNodePos( neighborNode, HULL_HUMAN ), origin, 255, 255, 0, true, 2.0 )

		foundSpawnYaw = getFunc( neighborNode, dataIndex, var )
		if ( foundSpawnYaw != null )
			return CreateSpawnPoint( analysis, neighborNode, foundSpawnYaw )
	}

	return null
}


function FindHotdropSpawnpoint( analysis, drop )
{
	Assert( drop.ownerEyePos != null, "Needs ownerEyePos" )
	Assert( drop.dist != null, "Needs dist" )
	Assert( drop.yaw != null, "Needs yaw" )
	local range = drop.dist
	Assert( range )
	local yaw = drop.yaw

	local forwardFacingYaw = yaw + 180 // yaw facing player if you just go forwards

	if ( forwardFacingYaw < 0 )
		forwardFacingYaw += 360
	else
		forwardFacingYaw %= 360


	if ( yaw < 0 )
		yaw += 360
	else
		yaw %= 360

	local angles = Vector( 0, yaw, 0 )
	local forward = angles.AnglesToForward()
	local forwardVec = forward * 250
	//DebugDrawLine( drop.ownerEyePos, drop.ownerEyePos + forwardVec, 255, 0, 0, true, 5.0 )
	local forwardOrigin = VectorCopy( drop.ownerEyePos )

	local dataIndex = GetAnalysisDataIndex( analysis )


//	local playerNode = GetNearestNodeToPos( drop.ownerEyePos )
	local height
//	if ( playerNode >= 0 )
//	{
//		local playerNodePos = GetNodePos( playerNode, 0 )
//
//		//DebugDrawLine( drop.ownerEyePos, playerNodePos, 255, 0, 0, true, 5.0 )
//		height = playerNodePos.z
//	}
//	else
	{
		local fallbackNode = GetClosestFallbackNode( dataIndex, forwardOrigin, analysis.hull )

		// move origin to height of nearest fallback node
		local fallbackNodePos = GetNodePos( fallbackNode, analysis.hull )
		//DebugDrawLine( drop.ownerEyePos, fallbackNodePos, 255, 0, 0, true, 5.0 )
		height = fallbackNodePos.z
	}

	forwardOrigin.z = height
	local startOrigin = VectorCopy( drop.ownerEyePos )
	startOrigin.z = height

	local result

	result = GetSpawnPointFromHotDropProjection( forwardOrigin, forward, forwardVec, forwardFacingYaw, analysis, dataIndex, startOrigin )
	if ( result )
	{
		local resultDist = Distance( result.origin, drop.ownerEyePos )

		if ( resultDist > 1200 )
		{
			// so far away, try finding a nearer node
			local nearestLegalNode = GetAnalysisSpawn_Nearest( analysis, drop.ownerEyePos, 20 )
			if ( nearestLegalNode )
			{
				local nearestDist = Distance( nearestLegalNode.origin, drop.ownerEyePos )
				if ( nearestDist < 800 )
					return nearestLegalNode
			}
		}

		return result
	}

	//printt( "couldnt find one in dot" )

//	// try at origin
//	result = GetAnalysisSpawn_ClosestToOriginInOtherHalf( analysis, origin, drop.ownerEyePos, yaw )
//	if ( result )
//		return result
//
//
//	// try at origin forward
//	result = GetAnalysisSpawn_ClosestToOriginInOtherHalf( analysis, origin + forward * range, drop.ownerEyePos, yaw )
//	if ( result )
//		return result
//
//	// try at origin

	result = GetAnalysisSpawn_ClosestYaw( analysis, drop.ownerEyePos, yaw )
	if ( result )
	{
		//printt( "found on origin" )
		return result
	}

	// try on us
	result = GetAnalysisSpawn_ClosestYaw( analysis, startOrigin, yaw )
	if ( result )
	{
		//printt( "found on us" )
		return result
	}

	// try to the right
	local right = angles.AnglesToRight()
	result = GetAnalysisSpawn_ClosestYaw( analysis, startOrigin + right * range, yaw + 30 ) // adjust the yaw to see the dropship fly in
	if ( result )
	{
		//printt( "found on right" )
		return result
	}

	// left
	result = GetAnalysisSpawn_ClosestYaw( analysis, startOrigin + right * -range, yaw - 30 )
	if ( result )
	{
		//printt( "found on left" )
		return result
	}

	// try in back
	result = GetAnalysisSpawn_ClosestYaw( analysis, startOrigin + forward * -range, yaw )
	if ( result )
	{
		//printt( "found on back" )
		return result
	}

	return null
/*
	local dataIndex = GetAnalysisDataIndex( analysis )

	local fallbackNode = GetClosestFallbackNode( dataIndex, origin + forward * range, analysis.hull )

	local closestYaw = GetSpawnPoint_ClosestYaw( fallbackNode, dataIndex, yaw, 360 )

	if ( closestYaw == null )
		return

	local result = CreateSpawnPoint( analysis, fallbackNode, closestYaw )
	Assert( result )

	return result
*/

}



function FindDogFighterSpawnpoint( analysis, drop )
{
	Assert( drop.ownerEyePos != null, "Needs ownerEyePos" )
	Assert( drop.dist != null, "Needs dist" )
	Assert( drop.yaw != null, "Needs yaw" )
	local range = drop.dist
	Assert( range )
	local yaw = drop.yaw

	//yaw = RandomInt( 360 )
	local forwardFacingYaw = yaw + 270 // yaw facing player if you just go forwards

	if ( forwardFacingYaw < 0 )
		forwardFacingYaw += 360
	else
		forwardFacingYaw %= 360

	if ( yaw < 0 )
		yaw += 360
	else
		yaw %= 360

	local angles = Vector( 0, yaw, 0 )
	local forward = angles.AnglesToForward()
	local forwardVec = forward * 1000
	//DebugDrawLine( drop.ownerEyePos, drop.ownerEyePos + forwardVec, 255, 0, 0, true, 5.0 )
	local forwardOrigin = VectorCopy( drop.ownerEyePos )
	forwardOrigin += forward * 1000

	local dataIndex = GetAnalysisDataIndex( analysis )


	local height
	local fallbackNode = GetClosestFallbackNode( dataIndex, forwardOrigin, analysis.hull )

	// move origin to height of nearest fallback node
	local fallbackNodePos = GetNodePos( fallbackNode, analysis.hull )
	//DebugDrawLine( drop.ownerEyePos, fallbackNodePos, 255, 0, 0, true, 5.0 )
	height = fallbackNodePos.z

	forwardOrigin.z = height
//	local startOrigin = VectorCopy( forwardOrigin )
	local startOrigin = VectorCopy( drop.ownerEyePos )
	startOrigin.z = height

	local result

	DebugDrawLine( forwardOrigin, forwardOrigin + forwardVec, 255, 0, 255, true, 5.0 )
	result = GetSpawnPointFromHotDropProjection( forwardOrigin, forward, forwardVec, forwardFacingYaw, analysis, dataIndex, startOrigin )
	if ( result )
	{
		return result
	}

	result = GetAnalysisSpawn_ClosestYaw( analysis, drop.ownerEyePos, yaw )
	if ( result )
	{
		//printt( "found on origin" )
		return result
	}

	// try on us
	result = GetAnalysisSpawn_ClosestYaw( analysis, startOrigin, yaw )
	if ( result )
	{
		//printt( "found on us" )
		return result
	}

	// try to the right
	local right = angles.AnglesToRight()
	result = GetAnalysisSpawn_ClosestYaw( analysis, startOrigin + right * range, yaw + 30 ) // adjust the yaw to see the dropship fly in
	if ( result )
	{
		//printt( "found on right" )
		return result
	}

	// left
	result = GetAnalysisSpawn_ClosestYaw( analysis, startOrigin + right * -range, yaw - 30 )
	if ( result )
	{
		//printt( "found on left" )
		return result
	}

	// try in back
	result = GetAnalysisSpawn_ClosestYaw( analysis, startOrigin + forward * -range, yaw )
	if ( result )
	{
		//printt( "found on back" )
		return result
	}

	return null

}


function GetSpawnPointFromHotDropProjection( forwardOrigin, forward, forwardVec, forwardFacingYaw, analysis, dataIndex, startOrigin )
{
	local foundNode = null
	local result, i
	local returnIterator = 2

	// return on returnIterator if we've found anything yet, this lets us only do super close ones if we have to

	for ( local i = 0; i < 14; i++ )
	{
		forwardOrigin += forwardVec
		result = FindHotDropSpawnPointInArea( forwardOrigin, forward, forwardFacingYaw, analysis, dataIndex, startOrigin )
		if ( !result )
		{
			if ( foundNode && i >= returnIterator )
				return foundNode
			continue
		}

		if ( i >= returnIterator )
			return result

		foundNode = result
	}
}

function FindHotDropSpawnPointInArea( origin, forward, forwardFacingYaw, analysis, dataIndex, startOrigin )
{
	local nearestNode
	//DrawArrow( origin, Vector(0,0,0), 10, 150 )

	nearestNode = GetNearestNodeToPos( origin )
	if ( nearestNode < 0 )
		return

	if ( NodeAvailable( nearestNode ) && NodeInHotDropFov( nearestNode, analysis, dataIndex, startOrigin, forward ) )
	{
		local foundSpawnYaw = GetSpawnPoint_ClosestYaw( nearestNode, dataIndex, forwardFacingYaw, 360 )
		local result = CreateSpawnPoint( analysis, nearestNode, foundSpawnYaw )
		// should be a result
		if ( result )
			return result
	}

	local neighborNodes = GetNeighborNodes( nearestNode, 10, analysis.hull )
	//foreach ( nearestNode in neighborNodes )
	//{
	//	local org = GetNodePos( nearestNode, analysis.hull )
	//	DebugDrawLine( org, origin, 55, 0, 55, true, 5.0 )
	//}

	foreach ( nearestNode in neighborNodes )
	{
		if ( !NodeAvailable( nearestNode ) )
			continue

		if ( !NodeInHotDropFov( nearestNode, analysis, dataIndex, startOrigin, forward ) )
			continue

		local foundSpawnYaw = GetSpawnPoint_ClosestYaw( nearestNode, dataIndex, forwardFacingYaw, 360 )
		local result = CreateSpawnPoint( analysis, nearestNode, foundSpawnYaw )
		// should be a result
		if ( result )
			return result
	}
}

function NodeInHotDropFov( nearestNode, analysis, dataIndex, startOrigin, forward )
{
	if ( !NodeHasFlightPath( dataIndex, nearestNode ) )
		return false

	local nearestNodeOrigin = GetNodePos( nearestNode, analysis.hull )

	// do a flat dot
	nearestNodeOrigin.z = startOrigin.z

	local nearestVec = nearestNodeOrigin - startOrigin
	nearestVec.Norm()
	local nearestDot = forward.Dot( nearestVec )

	//if ( nearestDot >= 0.95 )
	//{
	//	local start = GetPlayerArray()[0].GetOrigin()
	//	DebugDrawLine( start, start + forward * 1500, 255, 255, 0, true, 5.0 )
	//	DebugDrawLine( start, start + nearestVec * 1500, 155, 255, 50, true, 5.0 )
	//}
	//printt( "dot " + nearestDot )
	return nearestDot >= 0.95
}

function GetClosestYawIndexFromYaw( desiredYaw )
{
	local lowestYawDifference = 360
	local yaw, dif
	local yawIndex = null
	for ( local i = 0; i < ANALYSIS_STEPS; i++ )
	{
		yaw = i * ANALYSIS_YAW_STEP
		dif = YawDifference( desiredYaw, yaw )
		if ( dif > lowestYawDifference )
			continue

		lowestYawDifference = dif
		yawIndex = i
	}

	Assert( yawIndex != null )
	return yawIndex
}

function FindSpawnpointFromYawOnly( analysis, drop )
{
	// find the yaw index we will be searching through
	local yawIndex = GetClosestYawIndexFromYaw( drop.yaw )
	local resultYaw = yawIndex * ANALYSIS_YAW_STEP // the yaw we'll actually be when we use the node

	local offset = GetAnalysisOffset( analysis )
	local iterator = analysis.iterator
	local dataIndex = GetAnalysisDataIndex( analysis )

	local nodeCount = GetNodeCount()

	local nodeIndex
	local nodeOffset = RandomInt( nodeCount )

	for ( local i = 0; i < nodeCount; i++ )
	{
		// start on a randone node and go forwards until we get a legal node
		nodeIndex = i + nodeOffset
		nodeIndex %= nodeCount
		local origin = GetNodePos( nodeIndex, analysis.hull )

		if ( !GetNodeScriptData_Boolean( nodeIndex, yawIndex + dataIndex ) )
			continue

		if ( !NodeAvailable( nodeIndex ) )
			continue

		return CreateSpawnPoint( analysis, nodeIndex, resultYaw )
	}
}


function NodeAvailable( nodeIndex )
{
	if ( !( nodeIndex in level.spawnPointsInUse ) )
		return true

	return Time() > level.spawnPointsInUse[ nodeIndex ]
}

function TryFromOriginWithFallback( analysis, drop )
{
	local range = drop.dist
	Assert( range )
	local yaw = drop.yaw
	local origin = drop.origin

	if ( yaw < 0 )
		yaw += 360
	else
		yaw %= 360

	// try at origin
	local result = GetAnalysisSpawn_ClosestYaw( analysis, origin, yaw, 30 )
	if ( result )
		return result

	local angles = Vector( 0, yaw, 0 )
	local forward = angles.AnglesToForward()
	local right = angles.AnglesToRight()

	// try to the right
	local result = GetAnalysisSpawn_ClosestYaw( analysis, origin + right * range, yaw, 30 )
	if ( result )
		return result

	// left
	local result = GetAnalysisSpawn_ClosestYaw( analysis, origin + right * -range, yaw, 30 )
	if ( result )
		return result

	// try in back
	local result = GetAnalysisSpawn_ClosestYaw( analysis, origin + forward * -range, yaw, 30 )
	if ( result )
		return result

	// try in front
	local result = GetAnalysisSpawn_ClosestYaw( analysis, origin + forward * range, yaw, 30 )
	if ( result )
		return result

	local dataIndex = GetAnalysisDataIndex( analysis )

	local fallbackNode = GetClosestFallbackNode( dataIndex, origin + forward * range, analysis.hull )

	local closestYaw = GetSpawnPoint_ClosestYaw( fallbackNode, dataIndex, yaw, 360 )

	if ( closestYaw == null )
		return

	local result = CreateSpawnPoint( analysis, fallbackNode, closestYaw )
	Assert( result )

	return result
}

function TryVariousCallinPositionsAroundPlayer( analysis, drop )
{
	// DROPSHIP style
	local range = drop.dist
	local player = drop.owner

	local origin = player.EyePosition()
	local angles = player.EyeAngles()

	printt( "Calling in dropship: " )
	printt( "View angles: " + angles )
	printt( "View pos: " + origin )

//	overwrite here to force certain drops
//	angles = 		Vector(1.654943, 138.194458, 0.000000)
//	origin = 		Vector(544.680176, -530.933777, 412.031250)

	local viewForward = angles.AnglesToForward()
	local trace = TraceLine( origin, origin + viewForward * 5000, player )

	return TryVariousCallinPositions_Internal( analysis, trace, range, origin, angles )
}

function TryVariousCallinPositionsAroundEnt( analysis, drop )
{
	Assert( "assaultEntity" in drop )
	local origin = drop.assaultEntity.GetOrigin()
	local angles = drop.assaultEntity.GetAngles()

	local forward = angles.AnglesToForward()
	local trace = TraceLine( drop.origin, origin + forward * 5000, drop.assaultEntity )

	return TryVariousCallinPositions_Internal( analysis, trace, 1800, origin, angles )
}

function TryVariousCallinPositions_Internal( analysis, trace, range, origin, angles )
{
	Assert( range )
//	origin = Vector( 1698.87, 664.859, -255.969 )
//	angles = Vector( 0, -84.7, 0 )
	angles.x = 0

	local yaw = angles.y
	yaw += 180

	if ( yaw < 0 )
	{
		yaw += 360
	}
	else
	{
		yaw %= 360
	}

	local forward = angles.AnglesToForward()

	// try in front of us
	local result = GetAnalysisSpawn_ClosestYaw( analysis, origin + forward * range, yaw )
	if ( result )
		return result

	// try our view
	local result = GetAnalysisSpawn_ClosestYaw( analysis, trace.endPos, yaw )
	if ( result )
		return result

	// try on us
	local result = GetAnalysisSpawn_ClosestYaw( analysis, origin, yaw )
	if ( result )
		return result

//	// try behind us
//	local result = GetAnalysisSpawn_ClosestYaw( analysis, origin + forward * -range, yaw )
//	if ( result )
//		return result

	// try to the right
	local right = angles.AnglesToRight()
	local result = GetAnalysisSpawn_ClosestYaw( analysis, origin + right * range, yaw + 30 ) // adjust the yaw to see the dropship fly in
	if ( result )
		return result

	// left
	local result = GetAnalysisSpawn_ClosestYaw( analysis, origin + right * -range, yaw - 30 )
	if ( result )
		return result

	local dataIndex = GetAnalysisDataIndex( analysis )

	local fallbackNode = GetClosestFallbackNode( dataIndex, origin + forward * range, analysis.hull )

	local closestYaw = GetSpawnPoint_ClosestYaw( fallbackNode, dataIndex, yaw, 360 )

	if ( closestYaw == null )
		return

	local result = CreateSpawnPoint( analysis, fallbackNode, closestYaw )
	Assert( result )

	return result
}

function GetClosestFallbackNode( dataIndex, origin, hull )
{
	local table = level.fallbackNodes[ dataIndex ]
	local x = ( origin.x * DESCRIPTION_MULTIPLIER ).tointeger()
	local y = ( origin.y * DESCRIPTION_MULTIPLIER ).tointeger()
	local z = ( origin.z * DESCRIPTION_MULTIPLIER ).tointeger()
	if ( x < table.minX )
		x = table.minX
	if ( x > table.maxX )
		x = table.maxX
	if ( y < table.minY )
		y = table.minY
	if ( y > table.maxY )
		y = table.maxY
	if ( z < table.minZ )
		z = table.minZ
	if ( z > table.maxZ )
		z = table.maxZ

	Assert( table[x][y][z] != null, "Couldn't find entry for " + origin + " in fallback nodes." )
	return table[x][y][z]
}

function GetSpawnPointForStyle( analysis, drop )
{
	if ( GetAINScriptVersion() != AIN_REV )
    {
        printt( "AIN out of date: " + GetAINScriptVersion() + " vs " + AIN_REV )
        return
    }

	printt( "AIN not out of date (wowzers): " + GetAINScriptVersion() )

	PerfStart( PerfIndexServer.GetSpawnPointForStyle )

	local style = drop.style
	if ( style == null )
	{
		if ( drop.yaw == null )
		{
			style = eDropStyle.NEAREST
		}
		else
		{
			style = eDropStyle.NEAREST_YAW
		}
	}

	local spawnPoint

	switch ( style )
	{
		case eDropStyle.NEAREST_YAW:
			spawnPoint = FindNearestDropPositionWithYaw( analysis, drop )
			break

		case eDropStyle.NEAREST:
			spawnPoint = FindNearestDropPosition( analysis, drop )
			break

		case eDropStyle.DROPSHIP:
			spawnPoint = TryVariousCallinPositionsAroundPlayer( analysis, drop ) // owner, 1800 )
			break

		case eDropStyle.FLYER_PICKUP:
		case eDropStyle.ZIPLINE_NPC:
			spawnPoint = TryFromOriginWithFallback( analysis, drop )
			break

		case eDropStyle.RANDOM_FROM_YAW:
			spawnPoint = FindSpawnpointFromYawOnly( analysis, drop ) // owner, 1800 )
			break

		case eDropStyle.HOTDROP:
			spawnPoint = FindHotdropSpawnpoint( analysis, drop ) // owner, 1800 )
			break

		case eDropStyle.DOGFIGHTER:
			spawnPoint = FindDogFighterSpawnpoint( analysis, drop ) // owner, 1800 )
			break

		case eDropStyle.ASSAULT_ENTITY:
			spawnPoint = TryVariousCallinPositionsAroundEnt( analysis, drop )
			break

		case eDropStyle.FORCED:
			spawnPoint = {}
			spawnPoint.origin <- drop.origin
			spawnPoint.angles <- Vector( 0, drop.yaw, 0 )
			spawnPoint.node <- GetNearestNodeToPos( drop.origin ) // eep
			break

		case eDropStyle.NEAREST_YAW_FALLBACK:
			spawnPoint = FindNearestDropPosWithYawAndFallback( analysis, drop )
			break

//		case eDropStyle.FROM_SET_DISTANCE:
//			spawnPoint = FindSpawnpointAtDistance( analysis, drop )
//
//			break

		default:
			Assert(0, "Unknown style " + style )
			break
	}

	PerfEnd( PerfIndexServer.GetSpawnPointForStyle )

	if ( !spawnPoint )
		return

	//DebugDrawLine( spawnPoint.origin, drop.origin, 255, 0, 255, true, 15.0 )
	//printt( "Reserved " + spawnPoint.node )
	// reserve the spawn point

	//Assert( NodeAvailable( spawnPoint.node ) )
	level.spawnPointsInUse[ spawnPoint.node ] <- Time() + SPAWNPOINT_USE_TIME

	if ( "analysisPrepSpawnpointFunc" in analysis )
	{
		local newOrg = analysis.analysisPrepSpawnpointFunc( analysis, spawnPoint.origin, spawnPoint.angles.y )
		if ( newOrg )
			spawnPoint.origin = newOrg
		// bring this assert back
		//spawnPoint.origin = analysis.analysisPrepSpawnpointFunc( spawnPoint.origin, spawnPoint.angles.y )
		//Assert( spawnPoint.origin, "Spawnpoint failed prep!" )
	}

	return spawnPoint
}

function CreateCallinTable()
{
	local table = {}
	table.origin <- null
	table.yaw <- null
	table.team <- null
	table.owner <- null
	table.ownerEyePos <- null
	table.dist	<- null
	table.squadname <- null
	table.squadFunc <- null	//DefaultStayPut 	// function run by ai when they finish drop in
	table.squadParm <- null 	// gets passed to the squadfunc if it exists
	table.style <- null 		// how does it pick where to drop?
	table.dropshipHealth <- null

	return table
}

function GetWarpinPosition( model, animation, origin, angles )
{
	local start

	local analysis = GetAnalysisForModel( model, animation )
	if ( analysis )
	{
		start = {}
		Assert( analysis.points.len(), "No points in analysis" )
		local point = analysis.points[0]
		local forward = angles.AnglesToForward()
		local right = angles.AnglesToRight()

		start.origin <- GetOriginFromPoint( point, origin, forward, right )
		start.angles <- GetAnglesFromPoint( point, angles )
		return start
	}

	local dummyDropship = CreatePropDynamic( model, origin, angles )
	dummyDropship.Hide()
	dummyDropship.SetOrigin( origin )
    dummyDropship.SetAngles( angles )
	start = dummyDropship.Anim_GetAttachmentAtTime( animation, "ORIGIN", 0 )
	start.origin <- start.position
    start.angles <- start.angle
	dummyDropship.Destroy()

	return start
}

function testdrawtest( player )
{
	for ( ;; )
	{
		local origin = player.GetOrigin()
		local angles = player.EyeAngles()

		local viewAngles = player.EyeAngles()
		local viewForward = viewAngles.AnglesToForward()
		local viewPos = player.EyePosition()
		local trace = TraceLine( viewPos, viewPos + viewForward * 5000, player )

		local analysis = GetAnalysisForModel( "models/vehicle/goblin_dropship/goblin_dropship.mdl", "gd_goblin_zipline_strafe" )
		local dataIndex = GetAnalysisDataIndex( analysis )

		local node = GetNearestNodeToPos( trace.endPos )
		if ( node == -1 )
			return

		local origin = GetNodePos( node, analysis.hull )
		for ( local i = 0; i < ANALYSIS_STEPS; i++ )
		{
			if ( !GetNodeScriptData_Boolean( node, i ) )
				continue

			local yaw = i * ANALYSIS_YAW_STEP
			local angles = Vector( 0, yaw, 0 )
			local forward = angles.AnglesToForward()
			DebugDrawLine( origin, origin + forward * 80, 255, 100, 0, true, 2.0 )
		}
		wait 2
	}
}


function NodeHasFlightPath( dataIndex, nodeIndex )
{
	for ( local p = 0; p < ANALYSIS_STEPS; p++ )
	{
		if ( GetNodeScriptData_Boolean( nodeIndex, p + dataIndex ) )
			return true
	}

	return false
}

function GetFlightPathCount( dataIndex, nodeIndex )
{
	local count = 0
	for ( local p = 0; p < ANALYSIS_STEPS; p++ )
	{
		if ( GetNodeScriptData_Boolean( nodeIndex, p + dataIndex ) )
			count++
	}

	return count
}
