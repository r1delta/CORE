const TITANDROP_LOS_DIST = 2000 // 2D distance at which we do the line of sight check to see where the player wants to call in the titan
const TITANDROP_MIN_FOV = 10
const TITANDROP_MAX_FOV = 80
const TITANDROP_FOV_PENALTY = 8
const TITANDROP_PATHNODESEARCH_EXACTDIST = 500 // within this distance, we use the position the player is looking for the pathnode search
const TITANDROP_PATHNODESEARCH_DISTFRAC = 0.8 // beyond that distance, we use this fraction of how far the player is looking.
const TITANDROP_GROUNDSEARCH_ZDIR = -1.0 // if the player's not looking at anything, we search downward for ground at this slope
const TITANDROP_GROUNDSEARCH_FORWARDDIST = 350 // if the player's not looking at anything, we search for ground starting this many units in front of the player
const TITANDROP_GROUNDSEARCH_DIST = 1000 // if the player's not looking at anything, we search for ground this many units forward (max)
const TITANDROP_FALLBACK_DIST = 150 // if the ground search hits, we go this many units forward from it

function main()
{
	Globalize( GetTitanReplacementPoint )
	Globalize( HullTraceDropPoint )
	Globalize( DebugTitanSpawn )
	Globalize( EdgeTraceDropPoint )
	file.replacementSpawnpoints <- []

	AddSpawnCallback( "info_spawnpoint_titan", AddDroppoint )
	AddSpawnCallback( "info_spawnpoint_titan_start", AddDroppoint )
	AddSpawnCallback( "info_replacement_titan_spawn", AddDroppoint )
}

function EntitiesDidLoad()
{
	Assert( "replacementSpawnpoints" in file )

	wait 1	// hack: if I don't wait the bad nodes will still be valid
	ArrayRemoveInvalid( file.replacementSpawnpoints )
}


function AddDroppoint( ent, _ = null )
{
	file.replacementSpawnpoints.append( ent )
}

function DebugTitanSpawn()
{
	thread DebugTitanSpawnThread()
}

function DebugTitanSpawnThread()
{
	local player = GetPlayerArray()[0]

	local interval = 0.1

	local analysis = GetAnalysisForModel( ATLAS_MODEL, HOTDROP_TURBO_ANIM )
	local dataIndex = GetAnalysisDataIndex( analysis )

	for ( ;; )
	{
		if ( !IsValid( player ) )
		{
			wait interval
			continue
		}

		local playerOrg = player.GetOrigin()
		local playerEyeForward = player.GetViewVector()
		local playerEyePos = player.EyePosition()
		local playerEyeAngles = player.EyeAngles()
		local yaw = playerEyeAngles.y
		local desiredPos = GetReplacementTrace( player, playerEyePos, playerEyeForward )
		local pathNodeSearchPos
		if ( desiredPos )
		{
			DebugDrawCircle( desiredPos, Vector(0,0,0), 10, 128,255,128, interval )
			DebugDrawText( desiredPos + Vector(0,0,60), "Looking here", false, interval )
		}

		local pathNodeSearchPos = GetPathNodeSearchPos( playerOrg, playerEyePos, playerEyeForward, desiredPos, true )

		DebugDrawCircle( pathNodeSearchPos, Vector(0,0,0), 10, 128,128,255, interval )
		DebugDrawText( pathNodeSearchPos + Vector(0,0,40), "Searching from here", false, interval )

		DebugDrawLine( playerOrg, playerOrg + Vector( 0, yaw - TITANDROP_MIN_FOV, 0 ).AnglesToForward() * 500, 200,200,200, true, interval )
		DebugDrawLine( playerOrg, playerOrg + Vector( 0, yaw + TITANDROP_MIN_FOV, 0 ).AnglesToForward() * 500, 200,200,200, true, interval )
		DebugDrawLine( playerOrg, playerOrg + Vector( 0, yaw - TITANDROP_MAX_FOV, 0 ).AnglesToForward() * 500, 128,128,128, true, interval )
		DebugDrawLine( playerOrg, playerOrg + Vector( 0, yaw + TITANDROP_MAX_FOV, 0 ).AnglesToForward() * 500, 128,128,128, true, interval )

		local node = GetBestNodeForPosInWedge( pathNodeSearchPos, playerEyePos, yaw, TITANDROP_MIN_FOV, TITANDROP_MAX_FOV, TITANDROP_FOV_PENALTY, dataIndex, /*ANALYSIS_STEPS*/ 8 )
		Assert( NodeHasFlightPath( dataIndex, node ) )

		local pos = GetNodePos( node, analysis.hull )
		DebugDrawCircle( pos, Vector(0,0,0), 25, 255,255,128, interval )
		DebugDrawText( pos + Vector(0,0,20), "Best node", false, interval )

		local actualResult = GetTitanReplacementPoint( player, true )
		local actualPos = actualResult.origin
		DebugDrawCircle( actualPos, Vector(0,0,0), 32, 255,255,255, interval )
		DebugDrawLine( actualPos, actualPos + actualResult.angles.AnglesToForward() * 40, 255,255,255, true, interval )
		DebugDrawText( actualPos, "Final location", false, interval )

		wait interval
	}
}

function GetTitanReplacementPoint( player, forDebugging = false )
{
	if ( "customTitanSpawnpoint" in level )
	{
		// for training level - always drop our Titan in a predictable spot
		local point = GetEnt( level.customTitanSpawnpoint )
		Assert( point, "Couldn't find custom titan spawnpoint ent named " + level.customTitanSpawnpoint )
		return { origin = point.GetOrigin(), angles = point.GetAngles() }
	}

	local playerEyePos = player.EyePosition()
	local playerEyeAngles = player.EyeAngles()
	local playerOrg = player.GetOrigin()

	//local playerEyePos = 		Vector(-281.036224, 34.857925, 860.031250)
	//local playerEyeAngles = 	Vector(60.055622, 80.775780, 0.000000)
	//local playerOrg = 			Vector(-281.036224, 34.857925, 800.031250)

	if ( !forDebugging )
		printt( "Requested replacement Titan from eye pos " + playerEyePos + " view angles " + playerEyeAngles + " player origin " + playerOrg + " map " + GetMapName() )

	local playerEyeForward = playerEyeAngles.AnglesToForward()

	// use the analysis to find a position
	local analysis = GetAnalysisForModel( ATLAS_MODEL, HOTDROP_TURBO_ANIM )
	local dataIndex = GetAnalysisDataIndex( analysis )

	local dropPoint
	local traceOrigin = GetReplacementTrace( player, playerEyePos, playerEyeForward )
	if ( traceOrigin )
	{
//		local node = GetNearestNodeToPos( traceOrigin )
//		local nodeOrg = GetNodePos( node, 0 )
//		DebugDrawLine( traceOrigin, nodeOrg, 255, 0, 0, true, 5.0 )

		dropPoint = TitanHulldropSpawnpoint( analysis, traceOrigin, null )
		printt( "1dropPoint:", dropPoint )
		//printt( "dist: ", Distance2DSqr(dropPoint, playerOrg) )
		if ( dropPoint && !NearTitanfallBlocker( dropPoint ) )
		{
			if ( EdgeTraceDropPoint( dropPoint ) )
			{
				local nearHardpoint = NearHardpoint( dropPoint )
				local nearFlagSpawnPoint = NearFlagSpawnPoint( dropPoint )
				local nearDisallowedTitanfall = NearDisallowedTitanfall( dropPoint )

				if ( TitanTestDropPoint( dropPoint, analysis ) && !nearHardpoint && !nearFlagSpawnPoint && !nearDisallowedTitanfall )
				{
					local yawVec = playerEyePos - dropPoint
					local yawAngles = VectorToAngles( yawVec )
					yawAngles.x = 0
					yawAngles.z = 0
					// add some randomness
					yawAngles.y += RandomFloat( -60, 60 )
					if ( yawAngles.y < 0 )
						yawAngles.y += 360
					else if ( yawAngles.y > 360 )
						yawAngles.y -= 360
					return { origin = dropPoint, angles = yawAngles }//if ( EdgeTraceDropPoint( dropPoint ) )
				}
			}
//			if ( EdgeTraceDropPoint( dropPoint ) )
			//{
			//	local num = 4.0
			//	local dif = 360.0 / num
			//	for ( local i = 0; i <= num; i++ )
			//	{
			//		local yaw = dif * i
			//		local angles = Vector( 0, yaw, 0 )
			//		local forward = angles.AnglesToForward()
			//		local right = angles.AnglesToRight()
			//		if ( TitanFindDropNodes( analysis, dropPoint, yaw ) )
			//			return { origin = dropPoint, angles = angles }
			//	}
			//}
		}
	}

	printt( "2dropPoint:", dropPoint )

	local pathNodeSearchPos = GetPathNodeSearchPos( playerOrg, playerEyePos, playerEyeForward, traceOrigin, false )
	local node = GetBestNodeForPosInWedge( pathNodeSearchPos, playerEyePos, playerEyeAngles.y, TITANDROP_MIN_FOV, TITANDROP_MAX_FOV, TITANDROP_FOV_PENALTY, dataIndex, /*ANALYSIS_STEPS*/ 8 )
	Assert( NodeHasFlightPath( dataIndex, node ) )

	printt( "node:", node )

	if ( !node )
	{
		// This won't ever happen on a map with any reasonably placed path nodes.
		local spawner = FindSpawnpoint_ForReplacementTitan( player.GetOrigin() )
		Assert( spawner )
		return { origin = spawner.GetOrigin(), angles = null }
	}

	local nodeOrigin = GetNodePos( node, analysis.hull )
	local dir = nodeOrigin - playerEyePos
	local angles = VectorToAngles( dir )
	local yaw = angles.y + 180

	if ( yaw < 0 )
		yaw += 360
	else if ( yaw > 360 )
		yaw -= 360

	yaw = GetSpawnPoint_ClosestYaw( node, dataIndex, yaw, 360 )
	Assert( yaw != null )
	Assert( yaw >= 0 )
	Assert( yaw <= 360 )

 	return { origin = nodeOrigin, angles = Vector( 0, yaw, 0 ) }
}

function GetPathNodeSearchPos( playerOrg, playerEyePos, playerEyeForward, playerLookPos, debug )
{
	if ( playerLookPos )
	{
		local dist2DSqr = Distance2DSqr( playerOrg, playerLookPos )
		if ( dist2DSqr > (TITANDROP_PATHNODESEARCH_EXACTDIST / TITANDROP_PATHNODESEARCH_DISTFRAC) * (TITANDROP_PATHNODESEARCH_EXACTDIST / TITANDROP_PATHNODESEARCH_DISTFRAC) )
		{
			return playerOrg + (playerLookPos - playerOrg) * TITANDROP_PATHNODESEARCH_DISTFRAC
		}
		else if ( dist2DSqr > TITANDROP_PATHNODESEARCH_EXACTDIST * TITANDROP_PATHNODESEARCH_EXACTDIST )
		{
			local dir = playerLookPos - playerOrg
			dir.Normalize()
			return playerOrg + dir * TITANDROP_PATHNODESEARCH_EXACTDIST
		}
		else
		{
			return playerLookPos
		}
	}
	else
	{
		local diagonallyDown = Vector( playerEyeForward.x, playerEyeForward.y, 0 )
		diagonallyDown.Normalize()
		diagonallyDown.z = TITANDROP_GROUNDSEARCH_ZDIR

		local startPos = playerEyePos + playerEyeForward * TITANDROP_GROUNDSEARCH_FORWARDDIST
		local endPos = startPos + diagonallyDown * TITANDROP_GROUNDSEARCH_DIST

		local result = TraceLine( startPos, endPos, null, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE )

		if ( debug )
		{
			DebugDrawLine( playerEyePos, startPos, 128,128,200, true, 0.1 )
			DebugDrawLine( startPos, result.endPos, 128,128,200, true, 0.1 )
			if ( result.fraction < 1 )
				DebugDrawLine( result.endPos, result.endPos + playerEyeForward * TITANDROP_FALLBACK_DIST, 128,128,200, true, 0.1 )
		}

		if ( result.fraction < 1 )
			return result.endPos + playerEyeForward * TITANDROP_FALLBACK_DIST

		return playerEyePos + playerEyeForward * TITANDROP_FALLBACK_DIST
	}
}

function GetReplacementTrace( player, startPos, viewVector )
{
	local viewDirLen2D = viewVector.Length2D()
	if ( viewDirLen2D < 0.1 )
		viewDirLen2D = 0.1

	local endPos = startPos + ( viewVector * (TITANDROP_LOS_DIST / viewDirLen2D) )
	local result = TraceLine( startPos, endPos, null, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE )
//	DebugDrawLine( result.endPos, endPos, 255, 0, 0, true, 20.0 )
//	DebugDrawLine( startPos, result.endPos, 0, 255, 0, true, 20.0 )

//	if ( result.fraction <= 0.02 )
//		return null
	if ( result.fraction == 1 )
		return null

	if ( result.surfaceNormal.Dot( Vector(0,0,1) ) < 0.7 )
	{
		local endPos = result.endPos
		//DebugDrawLine( endPos, Vector(0,0,0), 0, 200, 0, true, 5.0 )

		// pull it back towards player
		local titanRadius = level.traceMaxs[ "npc_titan" ].x * 1.2
		endPos -= viewVector * titanRadius
		endPos += result.surfaceNormal * titanRadius

		//DebugDrawLine( endPos, Vector(0,0,0), 0, 200, 0, true, 5.0 )
		endPos = OriginToGround( endPos )
		//DebugDrawLine( endPos, Vector(0,0,0), 0, 200, 0, true, 5.0 )
		return endPos
	}
	return result.endPos
}

function HullTraceDropPoint( analysis, baseOrigin, heightCapMax = 190 )
{
	local heightCapMin = -512
	local startOrigin = baseOrigin + Vector( 0,0,1000 )
	local endOrigin = baseOrigin + Vector( 0,0, heightCapMin )

	local mask = analysis.traceMask

	local result = TraceHull( startOrigin, endOrigin, analysis.mins, analysis.maxs, null, mask, TRACE_COLLISION_GROUP_NONE )
	//DebugDrawLine( startOrigin, result.endPos, 0, 255, 0, true, 5.0 )
	//DebugDrawLine( result.endPos, endOrigin, 255, 0, 0, true, 5.0 )

//	DebugDrawLine( startOrigin, baseOrigin, 0, 255, 0, true, 5.0 )
//	DebugDrawLine( baseOrigin, endOrigin, 255, 0, 0, true, 5.0 )
//	local offset = Vector(0.15, 0.15, 0.0 )
//	DebugDrawLine( startOrigin + offset, result.endPos + offset, 0, 255, 0, true, 5.0 )
//	DebugDrawLine( result.endPos + offset, endOrigin + offset, 255, 0, 0, true, 5.0 )
//	DrawArrow( baseOrigin, Vector(0,0,0), 5.0, 50 )
//	DebugDrawLine( result.endPos, baseOrigin, 255, 255, 255, true, 4.5 )

/*
	printt( " " )
	printt( "Hull drop " )
	printt( "start " + startOrigin )
	printt( "end " + endOrigin )
	printt( "hit " + result.endPos )
	printt( "mins " + analysis.mins + " maxs " + analysis.maxs )
	printt( "mask " + mask )
*/


	if ( result.allSolid || result.startSolid || result.hitSky )
		return null

	if ( result.fraction == 0 || result.fraction == 1 )
		return null

	if ( fabs( result.endPos.z - baseOrigin.z ) > heightCapMax )
		return null

	return result.endPos
}

function EdgeTraceDropPoint( dropPoint )
{
	local offsetArray = [
		Vector( 64,64,0 ),
		Vector( -64,64,0 ),
		Vector( 64,-64,0 ),
		Vector( -64,-64,0 ),
	]
	local maxDif = 48
	local mask = TRACE_MASK_TITANSOLID | TRACE_MASK_PLAYERSOLID | TRACE_MASK_SOLID | TRACE_MASK_NPCSOLID
	local totalDif = 0

	foreach ( offset in offsetArray )
	{
		local startPos = dropPoint + Vector( 0, 0, 64 ) + offset
		local endPos = dropPoint + Vector( 0, 0, -64 ) + offset
		local result = TraceLine( startPos, endPos, null, mask, TRACE_COLLISION_GROUP_NONE )
		local dif = abs( result.endPos.z - dropPoint.z )
		totalDif += dif

		if ( dif > maxDif )
		{
			//DebugDrawLine( startPos, result.endPos, 200, 50, 50, true, 3  )
			return false
		}
		//DebugDrawLine( startPos, result.endPos, 50, 50, 200, true, 3  )
	}

	if ( totalDif > ( maxDif * 2 ) )
	{
		// this should catch cases where a small item like a box or barrel stops the hull collision trace above the ground.
		return false
	}

	return true
}

function FindSpawnpoint_ForReplacementTitan( origin )
{
	Assert( file.replacementSpawnpoints.len() )

	local spawnpoints = file.replacementSpawnpoints
	local selectedSpawnpoint = spawnpoints[0]

	local closestDist = null
	foreach ( spawnpoint in spawnpoints )
	{
		if ( spawnpoint.s.inUse )
			continue
		if ( spawnpoint.IsOccupied() )
			continue

		local dist = DistanceSqr( spawnpoint.GetOrigin(), origin )
		if ( closestDist == null || dist < closestDist )
		{
			closestDist = dist
			selectedSpawnpoint = spawnpoint
		}

	}

	Assert( selectedSpawnpoint )
	return selectedSpawnpoint
}