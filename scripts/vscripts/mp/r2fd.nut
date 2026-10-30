// r2fd.nut : Frontier Defense (Titanfall 2) wave data on top of R1 coop (Fireteam Defense).
// Original glue code. It contains no R2 data: a per-map script (generated from the player's own install) calls
// R2FD_Setup() with the harvester position, route polylines, origin pools and wave events.
//
// Event arrays (compact, written by the generator):
//   [ "g"|"gs"|"sp"|"cl"|"t"|"nt"|"mt"|"et", origin, routeName, delay ]
//        g  grunt squad drop pod        gs grunt squad dropship     sp spectre squad drop pod
//        cl cloaked drone               t  regular titan            nt nuke titan
//        mt mortar titan                et EMP (arc) titan
//        origin    = Vector, or a pool name (string) in def.pools (one origin is rolled at load)
//        routeName = key in def.routes ("" = nearest eligible route start), delay = seconds after the spawn (number or [lo,hi])
//   [ "w", n, titanOnly ]   barrier: continue when at most n enemies (titans only if titanOnly) are alive
//   [ "d", seconds ]        pause (skipped R2-only events keep their delay this way)
//
// R1's wave loop gates events by group "death" dependencies (half the group dead). The watcher thread below rewrites
// that requirement per wave so that a barrier releases exactly when the number of living enemies reaches n.

const R2FD_BREAK_TIME = 60.0 // R2 fd_wave_buy_time
const R2FD_SPAWN_OVERHEAD = 1.0 // R1 waits 0.5 to 1.5 s after every spawned group
const R2FD_RELEASE_MARGIN = 1.5

function main()
{
	if ( !IsServer() )
		return

	level.r2fd <- {}
	level.r2fd.barriers <- {} // waveIdx -> { groupName = { n, titanOnly } }
	level.r2fd.lastInfos <- null // the group table R1 rebuilds at every wave start (also on a wave restart)
	level.r2fd.harvester <- null

	Globalize( R2FD_Setup )

	AddCallback_GameStateEnter( eGameState.Playing, R2FD_OnPlaying )
}

function R2FD_OnPlaying()
{
	if ( !( "watcher" in level.r2fd ) )
	{
		level.r2fd.watcher <- true
		thread R2FD_BarrierWatcher()
	}
}

function R2FD_SpawnFuncForKind( kind )
{
	switch ( kind )
	{
		case "g":  return TD_SpawnGruntSquadDroppod
		case "gs": return TD_SpawnGruntSquadDropship
		case "sp": return TD_SpawnSpectreSquadDroppod
		case "cl": return TD_SpawnCloakedDrone
		case "t":  return TD_SpawnTitan
		case "nt": return TD_SpawnNukeTitan
		case "mt": return TD_SpawnMortarTitan
		case "et": return TD_SpawnEmpTitan
	}
	Assert( 0, "R2FD: unknown event kind " + kind )
}

function R2FD_Delay( d )
{
	if ( typeof d == "array" )
		return RandomFloat( d[0], d[1] )
	return d
}

// nearest named route start to origin (R2 picks the nearest start when the event names no route)
function R2FD_NearestRoute( routes, origin )
{
	local best = null
	local bestDist = 1.0e12
	foreach ( name, pts in routes )
	{
		local d = DistanceSqr( pts[0], origin )
		if ( d < bestDist )
		{
			bestDist = d
			best = name
		}
	}
	return best
}

// polyline for one event: [spawn origin] + route nodes after the first one (R2 skips the first node) + the end point.
// The generator pre-snaps titan and infantry routes into the navigation component of the harvester (def.routesTitan,
// def.endTitan, def.routes, def.endInfantry).
function R2FD_IsTitanKind( kind )
{
	return kind == "t" || kind == "nt" || kind == "mt" || kind == "et"
}

function R2FD_BuildRoute( def, kind, origin, routeName )
{
	local titan = R2FD_IsTitanKind( kind )
	local table = titan ? def.routesTitan : def.routes
	local pts = [ origin ]
	if ( routeName == "" )
		routeName = R2FD_NearestRoute( table, origin )

	if ( routeName != null && routeName in table )
	{
		local src = table[ routeName ]
		for ( local i = 1; i < src.len(); i++ )
			pts.append( src[i] )
	}
	pts.append( titan ? def.endTitan : def.endInfantry )
	return pts
}

function R2FD_Setup( def )
{
	level.r2fd.harvester = def.harvester
	TowerDefense_AddGeneratorLocation( def.harvester, def.harvesterAngles, true )

	// players are dropped by the wave dropship; R2 maps have no 2+2 info_spawnpoint_dropship_start, so use R2's FD dropship spot
	if ( "dropOrigin" in def )
		SetCustomWaveSpawn_SideView( def.dropOrigin, def.dropAngles )

	foreach ( pos in def.stationaryTitans )
		AddStationaryTitanPosition( pos )

	local routeCount = 0
	foreach ( waveIdx, events in def.waves )
	{
		local wave = TowerDefense_AddWave()
		local seg = 0
		local prevGroup = null // group that the current segment depends on
		local curGroup = "s0"
		local curGroupUsed = false
		level.r2fd.barriers[ waveIdx ] <- []

		foreach ( ev in events )
		{
			local kind = ev[0]

			if ( kind == "w" )
			{
				if ( !curGroupUsed )
					continue // nothing spawned since the previous barrier

				level.r2fd.barriers[ waveIdx ].append( { group = curGroup, n = ev[1], titanOnly = ( ev[2] != 0 ) } )
				prevGroup = curGroup
				seg++
				curGroup = "s" + seg
				curGroupUsed = false
				continue
			}

			if ( kind == "d" )
			{
				local p = R2FD_Delay( ev[1] ) - R2FD_SPAWN_OVERHEAD
				if ( p > 0.05 )
					Wave_AddPause( wave, p )
				continue
			}

			local origin = ev[1]
			if ( typeof origin == "string" )
			{
				local pool = def.pools[ origin ]
				origin = pool[ RandomInt( 0, pool.len() ) ]
			}

			local alias = "r2fd_" + waveIdx + "_" + routeCount
			routeCount++
			TowerDefense_AddRoute( R2FD_BuildRoute( def, kind, origin, ev[2] ), alias, false )

			Wave_AddSpawn( wave, R2FD_SpawnFuncForKind( kind ), curGroup, prevGroup, alias )
			curGroupUsed = true

			local p = R2FD_Delay( ev[3] ) - R2FD_SPAWN_OVERHEAD
			if ( p > 0.05 )
				Wave_AddPause( wave, p )
		}

		Wave_SetBreakTime( wave, R2FD_BREAK_TIME )
	}
}

function R2FD_CountAlive( titanOnly )
{
	local npcs = GetNPCArrayEx( "any", TEAM_IMC, Vector( 0, 0, 0 ), -1 )
	local n = 0
	foreach ( npc in npcs )
	{
		if ( !IsAlive( npc ) )
			continue
		if ( titanOnly )
		{
			if ( npc.GetClassname() == "npc_titan" )
				n++
			continue
		}
		if ( IsCloaked( npc ) && npc.GetClassname() == "npc_drone" )
			continue
		n++
	}
	return n
}

function R2FD_GroupProcessed( waveInfo, groupName )
{
	foreach ( info in waveInfo.spawngroups )
	{
		if ( !( "groupName" in info ) )
			continue
		if ( info.groupName != groupName )
			continue
		if ( !info.hasProcessed )
			return false
	}
	return true
}

function R2FD_BarrierWatcher()
{
	level.ent.EndSignal( "OnDestroy" )

	// barrier groups of a wave are strictly sequential (group k+1 is gated by group k), so only the head can be due
	local head = 0
	local seenTime = -1.0
	while ( true )
	{
		wait 0.2

		if ( !Flag( "CoopTD_WaveCombatInProgress" ) )
			continue

		local currWave = level.nv.TDCurrWave
		if ( currWave == null )
			continue
		local waveIdx = currWave - 1
		if ( !( waveIdx in level.r2fd.barriers ) )
			continue

		local list = level.r2fd.barriers[ waveIdx ]

		// first tick of a wave: block every barrier group (R1 computed "half dead" for them)
		if ( level.r2fd.lastInfos != level.waveSpawnGroupInfos )
		{
			if ( level.waveSpawnGroupInfos.len() == 0 )
				continue

			level.r2fd.lastInfos = level.waveSpawnGroupInfos
			head = 0
			seenTime = -1.0
			foreach ( b in list )
			{
				if ( b.group in level.waveSpawnGroupInfos )
					level.waveSpawnGroupInfos[ b.group ].reqDead = 999999
			}
		}

		if ( head >= list.len() )
			continue

		local b = list[ head ]
		local waveInfo = level.TowerDefenseWaves[ waveIdx ]
		if ( !R2FD_GroupProcessed( waveInfo, b.group ) )
			continue

		if ( seenTime < 0 )
		{
			seenTime = Time()
			continue
		}

		if ( Time() < seenTime + R2FD_RELEASE_MARGIN )
			continue

		if ( R2FD_CountAlive( b.titanOnly ) <= b.n )
		{
			if ( b.group in level.waveSpawnGroupInfos )
				level.waveSpawnGroupInfos[ b.group ].reqDead = 0
			printt( "R2FD barrier released: wave", currWave, "group", b.group, "alive<=", b.n )
			head++
			seenTime = -1.0
		}
	}
}
