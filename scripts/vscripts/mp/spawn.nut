
const SPAWNPOINT_USE_COOLDOWN = 1.0

function main()
{
	level.spawnData <- []
	level.postDropData <- []
	level.viewPointData <- {}
	level.spawnpointVisibilityCheck <- true
	level.allSpawnpoints <- []

	Globalize( IsSpawnpointValid )
	Globalize( IsSpawnpointValidDrop )
	Globalize( CreateNoSpawnArea )
	Globalize( DeleteNoSpawnArea )
	Globalize( IsSpawnpointInNoSpawnArea )
	Globalize( InitSpawnpointNearbyHardpoints )
	Globalize( Spawning_HardpointChangedTeams )
	Globalize( SpawnpointShowHardpoints )

	// spawn debug
	Globalize( RecordSpawnData )
	Globalize( StoreSpawnData )
	Globalize( PostDropSpawnData )

	if ( IsHighPerfDevServer() )
	{
		Globalize( DumpSpawnData )
		Globalize( DumpLastSpawndata )

	    Globalize( RecalculateSpawnData )
	    Globalize( RecalculateSpawnDataComplete )
	    Globalize( RestoreSpawnData )
	    Globalize( SetSpawnDataIndex )
	    Globalize( CullSpawnData )
	    Globalize( CullTitanPlayerData )
	    Globalize( CullSpawnDataPlayers )
	    Globalize( CullNoPetData )
	    Globalize( CullSpawnDataKeepPlayer )
	    Globalize( DeepClone )
	    Globalize( SpawnDataIsSpawnpointInvalid )
	}

	//Globalize( RateSpawnpoint )

	Globalize( SwapSpawnpointTeams )

	Globalize( DebugCycleSpawns )

	Globalize( SpawnRandomTitan )

	Globalize( FilterSpawnpointsByTeam )
	Globalize( FindSpawnPoint )
	Globalize( FindStartSpawnPoint )
	//Globalize( CodeCallback_SpawnpointDebugText )
	Globalize( GameModeRemove )

	Globalize( RateFrontLinePlayerSpawnpoint )
	Globalize( RateSpawnpoint_Generic )

	FlagInit( "DisplaySpawnData" )
	thread DisplaySpawnData()

	level._titan_starts <- []
	AddSpawnCallback( "info_spawnpoint_titan_start", OnTitanStartSpawn )
	AddSpawnCallback( "info_intermission", OnInfoIntermissionSpawn )

	AddSpawnCallback( "info_player_teamspawn", InitSpawnpoints )
	AddSpawnCallback( "info_player_start", InitSpawnpoints )
	AddSpawnCallback( "info_spawnpoint_droppod", InitSpawnpoints )
	AddSpawnCallback( "info_spawnpoint_titan", InitSpawnpoints )
	AddSpawnCallback( "info_spawnpoint_human", InitSpawnpoints )
	AddSpawnCallback( "info_spawnpoint_dropship_start", InitSpawnpoints )
	AddSpawnCallback( "info_spawnpoint_droppod_start", InitSpawnpoints )
	AddSpawnCallback( "info_spawnpoint_titan_start", InitSpawnpoints )
	AddSpawnCallback( "info_spawnpoint_human_start", InitSpawnpoints )
	AddSpawnCallback( "info_spawnpoint_dropship", InitSpawnpoints )
	AddSpawnCallback( "info_replacement_titan_spawn", InitSpawnpoints )
	AddSpawnCallback( "info_spawnpoint_marvin", InitSpawnpoints )
	AddSpawnCallback( "info_spawnpoint_flag", InitSpawnpoints )

	level.spawnRatingFunc_Pilot <- Bind( RateSpawnpoint_Generic )
	level.spawnRatingFunc_Generic <- Bind( RateSpawnpoint_Generic )
	file.cycleSpawns <- false
	file.noSpawnArea <- {}

	local friendlyAIValue = 1.75
	if ( GameModeHasCapturePoints() )
		friendlyAIValue = 0.75

	SpawnPoints_SetRatingMultipliers_Enemy( TD_TITAN, -10.0, -6.0, -1.0 )
	SpawnPoints_SetRatingMultipliers_Friendly( TD_TITAN, 0.25, 1.75, friendlyAIValue )

	SpawnPoints_SetRatingMultipliers_Enemy( TD_WALLRUN, -10.0, -6.0, -1.0 )
	SpawnPoints_SetRatingMultipliers_Friendly( TD_WALLRUN, 0.25, 1.75, friendlyAIValue )
}

function EntitiesDidLoad()
{
	InitSpawnsVisibleToTurret()
	InitSpawnsVisibleToBBTurret()
	InitSpawnpointsFloorIsLava()
}


function InitSpawnpointsFloorIsLava()
{
	if ( !Riff_FloorIsLava() )
		return

	local visibleFogTop = GetVisibleFogTop()
	local maxTitanSpawnFogHeight = GetMaxTitanSpawnFogHeight()

	foreach ( spawnpoint in level.allSpawnpoints )
	{
		local spawnpointClassname = spawnpoint.GetClassname()

		if ( spawnpointClassname == "info_spawnpoint_human" )
		{
			if ( spawnpoint.GetOrigin().z < visibleFogTop )
				spawnpoint.Destroy()
		}
		else if ( spawnpointClassname == "info_spawnpoint_titan" )
		{
			if ( spawnpoint.GetOrigin().z < maxTitanSpawnFogHeight )
				spawnpoint.Destroy()
		}
	}
}

function GameModeRemove( spawnpoint )
{
	local gameMode = GameRules.GetGameMode()
	switch ( gameMode )
	{
		// these modes use the "gamemode_tdm" spawn points
		case TEAM_DEATHMATCH:
		case PILOT_SKIRMISH:
		case ATTRITION:
		case ELIMINATION:
		case TITAN_TAG:
		case SCAVENGER:
		case TITAN_ESCORT:
		case MARKED_FOR_DEATH_PRO:
		case MARKED_FOR_DEATH:
		case COOPERATIVE:
			gameMode = TEAM_DEATHMATCH
			break

		case ATDM:
			gameMode = ATDM
			break

		// these modes have custom spawnpoints designated with "gamemode_xxx" keys
		// case TITAN_RUSH:
		// 	gameMode = TITAN_RUSH
		// 	break
		
		case HEIST:
			// may rename, prototyping entities
			gameMode = BIG_BROTHER
			break

		case LAST_TITAN_STANDING:
		case WINGMAN_LAST_TITAN_STANDING:
		case TITAN_BRAWL:
		case TITAN_MFD:
		case TITAN_MFD_PRO:
		//case MARKED_FOR_DEATH_PRO: //Uncomment to use LTS spawns for Titan variant
			gameMode = LAST_TITAN_STANDING
			break

		case CAPTURE_THE_FLAG_PRO:
			gameMode = CAPTURE_THE_FLAG
			break

		case CAPTURE_THE_TITAN:
		case BIG_BROTHER:
		case CAPTURE_THE_FLAG:
		case CAPTURE_POINT:
		case EXFILTRATION:
		default:
			break
	}

	local gamemodeKey = "gamemode_" + gameMode
	if ( spawnpoint.HasKey( gamemodeKey ) && (spawnpoint.kv[gamemodeKey] == "0" || spawnpoint.kv[gamemodeKey] == "") )
	{
		// printt( "Removing spawnpoint " + spawnpoint.GetClassname() + " with " + gamemodeKey + " = \"" + spawnpoint.kv[gamemodeKey] + "\" at " + spawnpoint.GetOrigin() )
		spawnpoint.Destroy()
		return true
	}
	//printt( "keeping spawnpoint", spawnpoint.GetClassname() )

	return false
}

function OnTitanStartSpawn( spawn )
{
	level._titan_starts.append( spawn )
}

function InitSpawnpoints( spawnpoint )
{
	// printt( "InitSpawnPoints" )

	if ( GameModeRemove( spawnpoint ) )
		return

	spawnpoint.s.inUse <- false // for drop pod logic
	spawnpoint.s.lastUsedTime <- -9999.0

	if ( ShouldIgnoreVisibleToEnemies( spawnpoint ) )
		spawnpoint.s.ignoreVisible <- true

	Assert( IsValid( spawnpoint ) )
	level.allSpawnpoints.append( spawnpoint )
}

function SpawnpointDisplay( spawnpoint )
{
	spawnpoint.EndSignal( "OnDeath" )
	local org = spawnpoint.GetOrigin()
	for ( ;; )
	{
		DebugDrawLine( org, org + Vector(0,0,100), 255, 255, 0, true, 10 )
		wait 10
	}
}

function InitSpawnsVisibleToTurret()
{
	// store all npc_turret_mega that can see a spawnpoint on that spawnpoint

	local turretMaxDistSq = 3000 * 3000 // - no idea what the actual distance is
	local turretArray = GetNPCArrayByClass( "npc_turret_mega" )

	foreach( turret in turretArray )
	{
		local eyePos = turret.EyePosition()
		foreach( spawnpoint in level.allSpawnpoints )
		{
			local origin = spawnpoint.GetOrigin() + Vector( 0,0,64 )
			if ( spawnpoint.GetClassname() == "info_spawnpoint_titan" )
				origin += Vector( 0,0,128 )

			if ( DistanceSqr( origin, eyePos ) > turretMaxDistSq )
				continue

			local trace = TraceLineSimple( eyePos, origin, turret )
			if ( trace < 0.99 )
				continue	// trace was blocked

			if ( !( "visibleToTurret" in spawnpoint.s ) )
				spawnpoint.s.visibleToTurret <- []
			spawnpoint.s.visibleToTurret.append( turret.weakref() )
		}
	}
}

function InitSpawnsVisibleToBBTurret()
{
	// store all npc_turret_mega that can see a spawnpoint on that spawnpoint

	local turretMaxDistSq = 3000 * 3000 // - no idea what the actual distance is
	local turretArray = GetNPCArrayByClass( "npc_turret_mega_bb" )

	foreach( turret in turretArray )
	{
		local eyePos = turret.EyePosition()
		foreach( spawnpoint in level.allSpawnpoints )
		{
			local origin = spawnpoint.GetOrigin() + Vector( 0,0,64 )
			if ( spawnpoint.GetClassname() == "info_spawnpoint_titan" )
				origin += Vector( 0,0,128 )

			if ( DistanceSqr( origin, eyePos ) > turretMaxDistSq )
				continue

			local trace = TraceLineSimple( eyePos, origin, turret )
			if ( trace < 0.99 )
				continue	// trace was blocked

			if ( !( "visibleToTurret" in spawnpoint.s ) )
				spawnpoint.s.visibleToTurret <- []
			spawnpoint.s.visibleToTurret.append( turret.weakref() )
		}
	}
}

function InitSpawnpointNearbyHardpoints()
{
	local highDist = 1000000.0 * 1000000.0
	foreach ( spawnpoint in level.allSpawnpoints )
	{
		local origin = spawnpoint.GetOrigin()

		local center = origin + Vector( 0, 0, 40 )

		spawnpoint.s.touchingHardpoint <- false

		local closestHardpoints = [null, null]
		local distsSq = [highDist, highDist]
		foreach( i, hardpoint in level.hardpoints )
		{
			local distSq = DistanceSqr( hardpoint.GetOrigin(), origin )

			if ( hardpoint.s.trigger.ContainsPoint( center ) )
			{
				// force this spawnpoint to associate with this hardpoint
				distSq = 0
				spawnpoint.s.touchingHardpoint = true
			}

			if ( distSq < distsSq[0] )
			{
				distsSq[1] = distsSq[0]
				closestHardpoints[1] = closestHardpoints[0]

				distsSq[0] = distSq
				closestHardpoints[0] = hardpoint
			}
			else if ( distSq < distsSq[1] )
			{
				distsSq[1] = distSq
				closestHardpoints[1] = hardpoint
			}
		}

		spawnpoint.s.hardpoint <- closestHardpoints[0]
		spawnpoint.s.hardpointNeighbor <- null
		spawnpoint.s.hardpointNeighborDist <- 0

		if ( closestHardpoints[1] )
		{
			local closestOrg = closestHardpoints[0].GetOrigin()
			local secondClosestOrg = closestHardpoints[1].GetOrigin()
			local dirToClosest = closestOrg - origin
			local hardpointAxis = secondClosestOrg - closestOrg
			local hardpointDistSq = DistanceSqr( closestOrg, secondClosestOrg )

			// if we're between the two hardpoints, use the second closest one as the "neighbor" hardpoint.
			if ( dirToClosest.Dot( hardpointAxis ) < 0 && distsSq[1] <= hardpointDistSq * 1.15 )
			{
				spawnpoint.s.hardpointNeighbor = closestHardpoints[1]
				spawnpoint.s.hardpointNeighborDist = distsSq[1]	// save the dist to the neighbouring hardpoint
			}
		}
	}

	// teamFallbackHardpoints are the hardpoints that a team uses for spawning when they don't own any hardpoints.
	level.teamFallbackHardpoints <- []
	level.teamFallbackHardpoints.resize( TEAM_COUNT )

	Assert( TEAM_MILITIA == TEAM_IMC + 1 )
	for ( local team = TEAM_IMC; team <= TEAM_MILITIA; team++ )
	{
		local teamStartSpawnpoints = SpawnPoints_GetPilotStart( team )

		if ( teamStartSpawnpoints.len() == 0 )
		{
			level.teamFallbackHardpoints[team] = null
			continue
		}

		local origin = teamStartSpawnpoints[0].GetOrigin()

		local closestDistSq = highDist
		// pick the closest hardpoint to any one of the start spawnpoints
		foreach( hardpoint in level.hardpoints )
		{
			local distSq = DistanceSqr( hardpoint.GetOrigin(), origin )
			if ( distSq < closestDistSq )
			{
				closestDistSq = distSq
				level.teamFallbackHardpoints[team] = hardpoint
			}
		}
	}

	level.teamFallbackHardpoints[TEAM_UNASSIGNED] = null
}

// for debugging
function SpawnpointShowHardpoints()
{
	thread SpawnpointShowHardpointsThread()
}

function SpawnpointShowHardpointsThread()
{
	local interval = 1
	while( 1 )
	{
		foreach ( spawnpoint in level.allSpawnpoints )
		{
			if ( !IsValid( spawnpoint ) )
				continue
			if ( spawnpoint.GetClassname().find( "_start" ) != null )
				continue
			if ( spawnpoint.GetClassname().find( "_human" ) == null )
				continue
			if ( !("hardpoint" in spawnpoint.s) )
				continue

			if ( IsValid( spawnpoint.s.hardpoint ) )
				DebugDrawLine( spawnpoint.s.hardpoint.GetOrigin(), spawnpoint.GetOrigin(), 255,255,255, true, interval + 0.05 )
			if ( IsValid( spawnpoint.s.hardpointNeighbor ) )
				DebugDrawLine( spawnpoint.s.hardpointNeighbor.GetOrigin(), spawnpoint.GetOrigin(), 255,128,0, true, interval + 0.05 )
		}

		wait interval
	}
}

function Spawning_HardpointChangedTeams( hardpoint, oldteam, newteam )
{
	Assert( oldteam != newteam )

	level.teamFallbackHardpoints[newteam] = null

	if ( oldteam != TEAM_UNASSIGNED )
	{
		local teamHasAnyHardpoint = false
		foreach( otherHardpoint in level.hardpoints )
		{
			if ( otherHardpoint.GetTeam() == oldteam )
			{
				teamHasAnyHardpoint = true
				break
			}
		}

		if ( !teamHasAnyHardpoint )
			level.teamFallbackHardpoints[oldteam] = hardpoint
	}

	// if either team has a fallback that belongs to the enemy, and there's a neutral point anywhere, switch their fallback to the neutral point.
	// helps avoid spawn camping.

	Assert( TEAM_MILITIA == TEAM_IMC + 1 )
	for ( local team = TEAM_IMC; team <= TEAM_MILITIA; team++ )
	{
		local fallback = level.teamFallbackHardpoints[team]
		if ( fallback == null )
			continue

		if ( fallback.GetTeam() == TEAM_UNASSIGNED )
			continue

		local teamStartSpawnpoints = SpawnPoints_GetPilotStart( team )

		local startOrigin
		if ( teamStartSpawnpoints.len() == 0 )
			startOrigin = Vector( 0, 0, 0 ) // whatever
		else
			startOrigin = teamStartSpawnpoints[0].GetOrigin()

		local closestDistSq = 1000000.0 * 1000000.0
		// pick the closest hardpoint to any one of the start spawnpoints
		foreach( hardpoint in level.hardpoints )
		{
			if ( hardpoint.GetTeam() != TEAM_UNASSIGNED )
				continue

			local distSq = DistanceSqr( hardpoint.GetOrigin(), startOrigin )
			if ( distSq < closestDistSq )
			{
				closestDistSq = distSq
				level.teamFallbackHardpoints[team] = hardpoint
			}
		}
	}
}

function ShouldIgnoreVisibleToEnemies( spawnpoint )
{
	local classname = spawnpoint.GetClassname()

	switch( classname )
	{
//		case "info_spawnpoint_droppod":
//		case "info_spawnpoint_titan":
		case "info_spawnpoint_titan_start":
		case "info_spawnpoint_human_start":
//		case "info_spawnpoint_dropship":
			return true
		default:
			return false
	}
}

function PrintHorribleWarning( msg )
{
	printl( "******************************************************************************************************************************************" )
	printl( "******************************************************************************************************************************************" )
	printt( msg )
	printl( "******************************************************************************************************************************************" )
	printl( "******************************************************************************************************************************************" )
}


function NoSpawnpointsFallback()
{
	PrintHorribleWarning( "WARNING: THIS MAP (" + GetMapName() + ") HAS NO SPAWNPOINTS\nSpawning at a random info_spawnpoint_titan" )

	local spawnpoints = SpawnPoints_GetTitan()
	if ( !spawnpoints.len() )
	{
		//printt( "Also, no info_spawnpoint_titan." )
		local start = GetEnt( "info_player_start" )
		Assert( start, "Also, no info_player_start" )

		return start
	}

	local idx = RandomInt( 0, spawnpoints.len() )
	return spawnpoints[idx]
}

function SpawnPoints_ScriptInitRatings( player )
{
	local frontline = GetCurrentFrontline()

	if ( frontline != null )
	{
		// get frontline stuff
		local spawnDir = GetTeamCombatDir( frontline, player.GetTeam() ) * -1
		local offsetOrigin = frontline.frontlineCenter + spawnDir * FRONTLINE_PLAYER_SPAWN_OFFSET

		SpawnPoints_InitFrontlineData( offsetOrigin, spawnDir, frontline.frontlineVector, frontline.frontlineCenter, frontline.width )
	}

	SpawnPoints_InitRatings( player )
}

function SpawnRandomTitan()
{
 	local spawnpoints = SpawnPoints_GetTitan()
	if ( !spawnpoints.len() )
		return null

	local spawnpoint = spawnpoints[ RandomInt( spawnpoints.len() ) ]

	local titans = GetAllTitans()
	local numIMC = 0
	local numMilitia = 0
	foreach ( titan in titans )
	{
		if ( titan.GetTeam() == TEAM_IMC )
			numIMC++
		else
			numMilitia++
	}

	local team = RandomInt(2) ? TEAM_IMC : TEAM_MILITIA
	if ( numIMC > numMilitia )
		team = TEAM_MILITIA
	else if ( numMilitia > numIMC )
		team = TEAM_IMC

	local table 	= CreateDefaultNPCTitanTemplate( team )
	table.title 	= "Random Titan"
	table.weapon	= "mp_titanweapon_xo16"
	table.origin 	= spawnpoint.GetOrigin()
	table.angles 	= spawnpoint.GetAngles()

	return SpawnNPCTitan( table )
}

function FindSpawnPoint( player, isTitan = false )
{
	Assert( IsValid( player ), player + " is invalid!" )
	//printl( "***************************************************************************" )
	//printl( "***************************************************************************" )
	//printl( "***************************************************************************\n" )
	//printt( "FindSpawnPoint( " + player + ")" )
	local spawnpointType
	if ( isTitan )
 		spawnpointType = "info_spawnpoint_titan"
 	else
 		spawnpointType = "info_spawnpoint_human"

 	printl( "FindSpawnPoint: isTitan = " + isTitan + ", spawnpointType = " + spawnpointType )

	if ( file.cycleSpawns )
	{
		local index = file.cycleSpawnIndex
		file.cycleSpawnIndex = ( file.cycleSpawnIndex + 1 ) % file.cycleSpawnArray.len()

		printt( "Spawn", index ,"of", file.cycleSpawnArray.len() )

		return file.cycleSpawnArray[ index ]
	}

	local team = player.GetTeam()
 	local spawnpoints = isTitan ? SpawnPoints_GetTitan() : SpawnPoints_GetPilot()
	//printt( "spawnpoints.len()" + spawnpoints.len() )

	if ( !spawnpoints.len() )
		return NoSpawnpointsFallback()

	SpawnPoints_ScriptInitRatings( player )

	if ( isTitan )
	{
		foreach ( spawnpoint in spawnpoints )
			level.spawnRatingFunc_Generic( TD_TITAN, spawnpoint, team, player )

		SpawnPoints_SortTitan()
	}
	else
	{
		foreach ( spawnpoint in spawnpoints )
			level.spawnRatingFunc_Pilot( TD_WALLRUN, spawnpoint, team, player )

		SpawnPoints_SortPilot()
	}

	spawnpoints = isTitan ? SpawnPoints_GetTitan() : SpawnPoints_GetPilot()

	local spawnpoint = GetBestSpawnpoint( player, spawnpoints, spawnpointType )
	Assert( spawnpoint )

	spawnpoint.s.lastUsedTime = Time()
	player.SetLastSpawnPoint( spawnpoint )

	return spawnpoint
}



function FindStartSpawnPoint( player, isTitan = false )
{
	printl( "***************************************************************************" )
	printl( "***************************************************************************" )
	printl( "***************************************************************************\n" )
	printt( "FindStartSpawnPoint( " + player + ")" )
	local spawnpointType
	if ( isTitan )
 		spawnpointType = "info_spawnpoint_titan_start"
 	else
 		spawnpointType = "info_spawnpoint_human_start"

 	printl( "FindStartSpawnPoint: isTitan = " + isTitan + ", spawnpointType = " + spawnpointType )

	local team = player.GetTeam()

	local spawnpoints = isTitan ? SpawnPoints_GetTitanStart( team ) : SpawnPoints_GetPilotStart( team )
	printt( "spawnpoints.len()" + spawnpoints.len() )

	printt( "team # " + team )

	if ( !spawnpoints.len() )
	{
		PrintHorribleWarning( "WARNING: THIS MAP (" + GetMapName() + ") HAS NO STARTSPAWNPOINTS FOR TEAM " + team )

		return FindSpawnPoint( player, isTitan )
	}

	SpawnPoints_ScriptInitRatings( player )

	if ( isTitan )
	{
		foreach ( spawnpoint in spawnpoints )
			level.spawnRatingFunc_Generic( TD_TITAN, spawnpoint, team, player )

		SpawnPoints_SortTitanStart()
	}
	else
	{
		foreach ( spawnpoint in spawnpoints )
			level.spawnRatingFunc_Pilot( TD_WALLRUN, spawnpoint, team, player )

		SpawnPoints_SortPilotStart()
	}

	local spawnpoint = GetBestSpawnpoint( player, spawnpoints, spawnpointType, true )
	Assert( spawnpoint )

	player.SetLastSpawnPoint( spawnpoint )

	return spawnpoint
}

function FilterSpawnpointsByTeam( spawnpoints, team )
{
	local oldspawnpoints = clone spawnpoints
	//printt( "oldspawnpoints " + oldspawnpoints.len() )
	spawnpoints.clear()
	//printt( "spawnpoints after clear() " + spawnpoints.len() )

	foreach ( spawnpoint in oldspawnpoints )
	{
		//printt( "spawn team: " + spawnpoint.GetTeam() )
		if ( spawnpoint.GetTeam() != team )
			continue

		spawnpoints.append( spawnpoint )
	}
	//printt( "post filter spawnspoints " + spawnpoints.len() )
}


function GetBestSpawnpoint( player, spawnpoints, spawnpointType, loopAll = false )
{
	// lets not loop through all spawnpoints. The bottom batch is not good for spawning even if they are valid.
	// if no valid spawnpoints go for the first that is invalid due to visibility.
	// should always return a spawnpoint.

	local team = player.GetTeam()
	local count = (spawnpoints.len() + 1) / 2

	if ( loopAll )
		count = spawnpoints.len()

	local spawnpoint = GetFirstValidSpawnpoint( spawnpoints, team, count )

	if ( !spawnpoint )
	{
		spawnpoint = GetFirstValidSpawnpoint( spawnpoints, team, spawnpoints.len(), true )

		if ( !spawnpoint )
		{
			PrintNoValidSpawnpoint( spawnpointType, spawnpoints, player, team )
			spawnpoint = spawnpoints[0]
		}

		//if ( !level.isTestmap )
			NotifyClientOfBadSpawn( player, "SpawnIssueInvalid" )
	}

	//if ( !level.isTestmap )
		DebugCheckSpawnpointVsEnemies( player, spawnpoint, team )

	return spawnpoint
}

function GetFirstValidSpawnpoint( spawnpoints, team, count, ignoreVisible = false )
{
	for( local i = 0; i < count; i++ )
	{
		if ( !IsSpawnpointValid( spawnpoints[i], team, ignoreVisible ) )
			continue

		return spawnpoints[i]
	}
	return null
}

function SpawnPoint_HardpointScore( spawnpoint, team )
{
	if ( !("hardpoint" in spawnpoint.s) )
		return 0

	local score = 0
	local otherTeam = team == TEAM_IMC ? TEAM_MILITIA : TEAM_IMC

	local hardpoint = spawnpoint.s.hardpoint
	local hardpointTeam = hardpoint.GetTeam()
	local hardpointNeighborTeam
	if ( spawnpoint.s.hardpointNeighbor )
		hardpointNeighborTeam = spawnpoint.s.hardpointNeighbor.GetTeam()
	else
		hardpointNeighborTeam = null

	if ( hardpoint == level.teamFallbackHardpoints[team] )
	{
		score += 4.0

		// try to avoid spawnpoints that are inside enemy hardpoints
		if ( hardpointTeam == otherTeam && spawnpoint.s.touchingHardpoint )
			score -= 10.0

		// extra bonus if this spawnpoint is "behind" the hardpoint
		if ( hardpointNeighborTeam != otherTeam )
			score += 2.0
	}
	else if ( hardpoint == level.teamFallbackHardpoints[otherTeam] )
	{
		// treat as neutral
	}
	else if ( hardpointTeam == team )
	{
		if ( hardpoint.GetHardpointState() == CAPTURE_POINT_STATE_CAPTURED )
			score += 4.0
		else
			score += 2.0

		// prefer the spawnpoints closer to the enemy or neutral hardpoint (i.e. near the front line)
		if ( hardpointNeighborTeam != null && hardpointNeighborTeam != team )
			score += 2.0
	}
	else if ( hardpointTeam == otherTeam )
	{
		score -= 10.0

		// slightly favor the spawnpoints closer to the friendly hardpoint (i.e. near the front line)
		if ( hardpointNeighborTeam == team )
			score += 2.0

		// try extra hard to avoid spawnpoints that are inside enemy hardpoints
		if ( spawnpoint.s.touchingHardpoint )
			score -= 10.0
	}

	return score
}


function EnemyTeam( team )
{
	if ( team == TEAM_IMC )
		return TEAM_MILITIA
	else if ( team == TEAM_MILITIA )
		return TEAM_IMC

	Assert( 0, "invalid team for EnemyTeam" )
}

function DebugPrintRatings( string, rating )
{
	if ( !rating )
		return
	printt( "  - " + string + ":" + rating )
}


function AddSpawnPointDebugRatingData( spawnpoint, team, rating )
{
	// store data for the spawnpoint
	local spawnpointTable = spawnpoint.GetRatingData()

	local reason = SpawnDataIsSpawnpointInvalid( spawnpoint, team )
	spawnpointTable.origin <- spawnpoint.GetOrigin()
	spawnpointTable.reason <- reason
	spawnpointTable.isValid <- reason ? false : true

	if ( level.spawnData.len() )
	{
		// store rating for the spawnpoint
		spawnpointTable.rating <- rating

		// add this spawnpoint to the spawnpointData array
		local spawnData = level.spawnData.top()
		spawnData.spawnpointData.append( spawnpointTable )
	}
}


function RateFrontLinePlayerSpawnpoint( checkclass, spawnpoint, team, player = null )
{
	local frontlineRating = spawnpoint.CalculateFrontlineRating()
	local ratingWithPetTitan = frontlineRating

	if ( frontlineRating > 0 )
		ratingWithPetTitan = frontlineRating * 0.25

	local rating = spawnpoint.CalculateRating( checkclass, team, frontlineRating, ratingWithPetTitan )

	if ( IsHighPerfDevServer() )
		AddSpawnPointDebugRatingData( spawnpoint, team, rating )
}


function RateSpawnpoint_Generic( checkclass, spawnpoint, team, player = null )
{
	local hardpointRating = SpawnPoint_HardpointScore( spawnpoint, team )
	local ratingWithPetTitan = hardpointRating

	// if we have a pet rating lower the influence of some other ratings
	if ( 0.0 > hardpointRating && hardpointRating > -3.5 )
		ratingWithPetTitan = hardpointRating * 0.25

	local rating = spawnpoint.CalculateRating( checkclass, team, hardpointRating, ratingWithPetTitan )

	if ( IsHighPerfDevServer() )
		AddSpawnPointDebugRatingData( spawnpoint, team, rating )
}


/*
function CodeCallback_SpawnpointDebugText( spawnpoint, team )
{
	// This is displayed in the spawnpoint's ent_text.
	// Should return an array of key-value pair arrays.
	// Example: [["test", 3.6], ["test2", "val"]]

	local player = null
	local players = GetPlayerArray()
	if ( players.len() == 1 )
		player = players[0]

	local e
	if ( spawnpoint.GetClassname().find( "titan" ) != null )
		e = level.spawnRatingFunc_Generic( spawnpoint, team, player )
	else
		e = level.spawnRatingFunc_Pilot( spawnpoint, team, player )

	local res = []
	foreach ( k,v in e )
	{
		res.append( [k, v] )
	}

	if ( "hardpoint" in spawnpoint.s )
	{
		if ( spawnpoint.s.hardpoint )
			res.append( ["hardpoint", GetHardpointStringID( spawnpoint.s.hardpoint.GetHardpointID() )] )
		if ( spawnpoint.s.hardpointNeighbor )
			res.append( ["hardpointNeighbor", GetHardpointStringID( spawnpoint.s.hardpointNeighbor.GetHardpointID() )] )

		if ( spawnpoint.s.hardpoint == level.teamFallbackHardpoints[team] )
			res.append( ["Hardpoint fallback for this team", ""] )
	}
	return res
}
*/

function IsSpawnpointValid( spawnpoint, team, ingoreVisible = false )
{
	// check if drop pod is en route to this spawnpoint
	if ( spawnpoint.s.inUse )
	{
		//printt( spawnpoint + ": inUse" )
		return false;
	}

	local spawnpointTeam = spawnpoint.GetTeam()

	if ( "spawnpointTeamOverrideFunc"  in spawnpoint.s )
		spawnpointTeam = spawnpoint.s.spawnpointTeamOverrideFunc( spawnpointTeam, team )

	if ( (spawnpointTeam > 0) && (spawnpointTeam != team) )
		return false

	// ensure spawnpoint is not occupied (i.e. would spawn inside another player or object )
	if ( spawnpoint.IsOccupied() )
	{
		//printt( spawnpoint + ": IsOccupied" )
		return false;
	}

	if ( IsSpawnpointVisibleToTurret( spawnpoint, team ) )
	{
		return false
	}

	if ( IsSpawnpointNearGrenade( spawnpoint, team ) )
	{
		return false
	}

	if ( !( "ignoreVisible" in spawnpoint.s ) && spawnpoint.IsVisibleToEnemies( team ) && !ingoreVisible )
	{
		//printt( spawnpoint + ": IsVisibleToEnemies" )
		return false
	}

	if ( IsSpawnpointInNoSpawnArea( spawnpoint, team ) )
	{
		return false
	}

	if ( Time() < spawnpoint.s.lastUsedTime + SPAWNPOINT_USE_COOLDOWN )
		return false

	return true
}


function IsSpawnpointNearGrenade( spawnpoint, team )
{
	local enemyTeam = GetEnemyTeam( team )
	local grenadeArray = GetProjectileArrayEx( "npc_grenade_frag", enemyTeam, spawnpoint.GetOrigin(), 1000 )

	foreach( grenade in grenadeArray )
	{
 		if ( !IsValid( grenade ) )
			continue

 		local radius = grenade.GetDamageRadius() * 2.0
		radius *= radius
		local distSqr = DistanceSqr( spawnpoint.GetOrigin(), grenade.GetOrigin() )
		if ( distSqr < radius )
			return true
	}

	return false
}

function IsSpawnpointVisibleToTurret( spawnpoint, team )
{
	if ( "visibleToTurret" in spawnpoint.s )
	{
		foreach( turret in spawnpoint.s.visibleToTurret )
		{
			if ( !IsValid( turret ) )
				continue

			local turretState = turret.GetTurretState()
			if ( turretState != TURRET_ACTIVE && turretState != TURRET_SEARCHING )
				continue

			local turretTeam = turret.GetTeam()
			if ( turretTeam == team || turretTeam == TEAM_UNASSIGNED )
				continue

			// if I get to here an enemy turret is active and can see the spawnpoint
			return true
		}
	}
	return false
}

function IsSpawnpointInNoSpawnArea( spawnpoint, team )
{
	PerfStart( PerfIndexServer.NoSpawnAreaCheck )

	local origin = spawnpoint.GetOrigin()

	local result = false

	foreach( area in file.noSpawnArea )
	{
		if ( area.team == team )
			continue

		if ( DistanceSqr( origin, area.origin ) > area.lengthSqr )
			continue

		if ( !area.rectangle )
		{
			PerfEnd( PerfIndexServer.NoSpawnAreaCheck )
			return true	// inside radius of no spawn area, return true
		}
		// check to see if it's inside the rectangle
		local lowerVector = origin - area.lowerRight
		local upperVector = origin - area.upperLeft
		if ( area.forward.Dot( lowerVector ) < 0 )
			continue
		if ( area.left.Dot( lowerVector ) < 0 )
			continue
		if ( area.right.Dot( upperVector ) < 0 )
			continue

		PerfEnd( PerfIndexServer.NoSpawnAreaCheck )
		return true	// inside the rectangle, return true
	}

	PerfEnd( PerfIndexServer.NoSpawnAreaCheck )
	return false
}

/*
	if you only pass length it will treat it as a circle and use the length as the radius.
	if you pass the length, width and angles it will become a rectangle the extends from the origin out.
	direction is based on the forward vector of the angles passed.
*/
function CreateNoSpawnArea( team, origin, timeout, length, width = null, angles = null )
{
	local area = {}
	area.team <- team
	area.origin <- origin
	area.lengthSqr <- length * length
	area.rectangle <- width == null ? false : true

//	local debugLineDuration = timeout
//	if ( debugLineDuration < 0 )
//		debugLineDuration = 9999

	if ( area.rectangle )
	{
		Assert( angles )
		area.forward <- angles.AnglesToForward()
		area.right <- angles.AnglesToRight()
		area.left <- area.right * -1
		area.lowerRight <- origin + area.right * ( width / 2 )
		area.upperLeft <- origin + area.forward * length - area.right * ( width / 2 )


//		DebugDrawLine( area.lowerRight, area.lowerRight + area.left * width, 255, 0, 0, true, debugLineDuration )
//		DebugDrawLine( area.lowerRight, area.lowerRight + area.forward * length, 255, 100, 0, true, debugLineDuration )
//		DebugDrawLine( area.upperLeft, area.upperLeft + area.forward * -length, 255, 100, 0, true, debugLineDuration )
//		DebugDrawLine( area.upperLeft, area.upperLeft + area.right * width, 255, 100, 0, true, debugLineDuration )
	}
	else
	{
//		DebugDrawCircle( origin, Vector( 0,0,0 ), length, 0, 100, 255, debugLineDuration )
	}

	local id = UniqueString( Time() )
	file.noSpawnArea[id] <- area

	if ( timeout >= 0 )
		thread NoSpawnAreaTimeout( id, timeout )

	return id
}

function NoSpawnAreaTimeout( id, timeout )
{
	wait timeout
	DeleteNoSpawnArea( id )
}

function DeleteNoSpawnArea( id )
{
	if ( id in file.noSpawnArea )
		delete file.noSpawnArea[ id ]
}

function IsSpawnpointValidDrop( spawnpoint, team )
{
	// check if drop pod is en route to this spawnpoint
	if ( spawnpoint.s.inUse )
		return false;

	// ensure spawnpoint is not occupied (i.e. would spawn inside another player or object )
	if ( spawnpoint.IsOccupied() )
		return false;

	return true
}

function PrintNoValidSpawnpoint( spawnpointType, spawnpoints, player, team )
{
	//printt( "No valid " + spawnpointType + " spawnpoint could be found for " + player + " at time " + Time() )

	local inUseCount = 0
	local visibleCount = 0
	local occupiedCount = 0

	foreach ( spawnpoint in spawnpoints )
	{
		if ( spawnpoint.s.inUse )
			inUseCount++

		if ( spawnpoint.IsVisibleToEnemies( team ) )
			visibleCount++

		if ( spawnpoint.IsOccupied() )
			occupiedCount++
	}

	//printt( "Out of " + spawnpoints.len() + " spawnpoints:" )
	printl( "   SPAWNING BUG " + player.GetPlayerName() + " using: " + spawnpointType  )
	printl( " " + inUseCount + " are in use by drop pods" )
	printl( " " + visibleCount + " are visible to enemies" )
	printl( " " + occupiedCount + " are occupied" )
}


function OnInfoIntermissionSpawn( ent )
{
	printt( "call OnInfoIntermissionSpawn" )

	local gametype = "0"
	if ( ent.HasKey( "GameType" ) )
		gametype = ent.Get( "GameType" ).tolower()
	// because the string table in code is case insensitive the getting the gametype "refuel" returns a uppercase string "REFUEL"

	printt( "game type: ",gametype )
	printt( "ent: ", ent)
	local team = ent.GetTeam()

	if ( !( gametype in level.viewPointData ) )
		level.viewPointData[ gametype ] <- {}

	if ( !( team in  level.viewPointData[ gametype ] ) )
		level.viewPointData[ gametype ][ team ] <- [ ent ]
	else
		level.viewPointData[ gametype ][ team ].append( ent )
}


/**** Spawn Debug stuff ****/

function RecordSpawnData( player )
{

	if ( !IsHighPerfDevServer() )
		return

//	printt( "RecordSpawnData" )

	local spawnData = {}
	spawnData.player <- player.GetPlayerName()
	spawnData.time <- Time()
	spawnData.locationData <- LocationData( player.GetTeam() )
	spawnData.playerTeam <- player.GetTeam()
	spawnData.titanSpawn <- ShouldSpawnAsTitan( player )
	spawnData.spawnpointData <- []
	spawnData.map <- GetMapName()

	local frontline = GetCurrentFrontline()
	if ( frontline )
	{
		spawnData.frontlineCenter <- frontline.frontlineCenter
		spawnData.frontlineVector <- frontline.frontlineVector
		spawnData.combarDirIMC <- GetTeamCombatDir( frontline, TEAM_IMC )
	}

	level.spawnData.append( spawnData )

	return ( level.spawnData.len() - 1 )
}

function StoreSpawnData( spawnpoint )
{
	if ( !IsHighPerfDevServer() )
		return

//	if ( !( "rating" in spawnpoint.s ) )
//	{
//		printt( "No Spawnpoints in this map" )
//		return
//	}

	local spawnData = level.spawnData.top()
	spawnData.pickedSpawnpoint <- spawnpoint.GetOrigin()
	spawnData.rating <- 123.321
//	spawnpoint.s.rating // code version doesn't store rating on the spawnpoint
//	we can find the correct value based on the origin if needed

//	printt( "StoreSpawnData" )
}

function PostDropSpawnData( player, index )
{
	if ( !IsHighPerfDevServer() )
		return

//	printt( "PostDropSpawnData" )

	local postDropData = {}
	postDropData.index <- index
	postDropData.player <- player.GetPlayerName()
	postDropData.time <- Time()
	postDropData.locationData <- LocationData( player.GetTeam() )
	postDropData.spawnpointData <- []
	postDropData.titanSpawn <- level.spawnData[ index ].titanSpawn

	level.postDropData.append( postDropData )
}

if ( IsHighPerfDevServer() )
{
	function DumpSpawnData()
	{
		thread DumpSpawnData_Internal()
	}

	function DumpLastSpawndata()
	{
		thread DumpLastSpawndata_Internal()
	}

	function DumpLastSpawndata_Internal()
	{
		if ( !level.spawnData.len() )
			return

		printt( "*********** LAST SPAWN DATA ************" )
		printt_spamLog( "*********** LAST SPAWN DATA ************" )
		local lastIndex = level.spawnData.len() - 1
		waitthread DumpData( level.spawnData[ lastIndex ] )
	}

	function DumpSpawnData_Internal()
	{
		if ( !level.spawnData.len() )
			return

		// dump the data to the console
		printt( "*********** SPAWN DATA ************" )
		printl_spamLog( "\n***********************************" )
		printl_spamLog( "*********** SPAWN DATA ************" )
		printl_spamLog( "***********************************\n" )
		printt_spamLog( "MAP: ", GetMapName() )

		SpamLog( "level.base_spawnData <- " )

		waitthread DumpData( level.spawnData )

//		SpamLog( "\nlevel.base_postDropData <- " )
//		waitthread DumpData( level.postDropData )

		printt( "*********** SPAWN DATA DONE ************" )
		printl_spamLog( "/n***********************************" )
		printl_spamLog( "***********************************" )
		printl_spamLog( "***********************************" )
	}

	function DumpData( obj, indent = 0, depth = 0, maxDepth = 5 )
	{
		if ( IsTable( obj ) )
		{
			if ( "player" in obj )
			{
				wait 0
			}

			if ( depth >= maxDepth )
			{
				printl_spamLog( "{...}" )
				return
			}

			printl_spamLog( "{" )
			foreach ( k, v in obj )
			{
				SpamLog( TableIndent( indent + 2 ) + k + " = " )
				DumpData( v, indent + 2, depth + 1, maxDepth )
			}
			printl_spamLog( TableIndent( indent ) + "}," )
		}
		else if ( IsArray( obj ) )
		{
			if ( depth >= maxDepth )
			{
				printl_spamLog( "[...]" )
				return
			}

			printl_spamLog( "[" )

			local index = 0
			foreach ( v in obj )
			{
				SpamLog( TableIndent( indent + 2 ) )
				DumpData( v, indent + 2, depth + 1, maxDepth )
				index++
				if ( ( index % 30 ) == 0 )
					wait 0
			}
			printl_spamLog( TableIndent( indent ) + "]," )
		}
		else if ( type( obj ) == "instance" && obj instanceof Vector )
		{
			printl_spamLog( "Vector( " + obj.x + ", " + obj.y + ", " + obj.z + " )," )
		}
		else if ( type( obj ) == "string" )
		{
			printl_spamLog( "\"" + obj + "\"," )
		}
		else
		{
			printl_spamLog( obj + "," )
		}
	}
}

function LocationData( team )
{
	local table = {}
	table.playerArray <- []
	table.npcArray <- []
	table.hardpointArray <- []

	local players = GetPlayerArray()
	foreach( player in players )
	{
		local playerData = {}
		playerData.name <- player.GetPlayerName()
		playerData.origin <- player.GetOrigin()
//		playerData.angles <- player.EyeAngles()
		playerData.titan <- player.IsTitan()
		playerData.team <- player.GetTeam()
		playerData.isAlive <-IsAlive( player )
		table.playerArray.append( playerData )
	}

	local NPCs = GetNPCArray()
	foreach( npc in NPCs )
	{
		local npcData = {}
		npcData.origin <- npc.GetOrigin()
		npcData.team <- npc.GetTeam()
		npcData.titan <- npc.IsTitan()
		local bossPlayer = npc.GetBossPlayer()
		npcData.bossPlayer <- ( bossPlayer != null && bossPlayer.IsPlayer() ) ? bossPlayer.GetPlayerName() : false
		if ( npcData.team != TEAM_UNASSIGNED )
			table.npcArray.append( npcData )
	}

	foreach( hardpoint in level.hardpoints )
	{
		local hardpointData = {}
		hardpointData.origin <- hardpoint.GetOrigin()
		hardpointData.team <- hardpoint.GetTeam()
		table.hardpointArray.append( hardpointData )
	}

	return table
}

function DisplaySpawnData()
{
	FlagWait( "DisplaySpawnData" )

	disable_npcs()

	if ( !("_spawnData" in level) )
		return

	local player = GetPlayerArray()[0]
	local postDrop = false


	if ( !( "spawnDataIndex" in level ) )
		level.spawnDataIndex <- 0
	level.spawnDataIndex = 0

	while( true )
	{
		local package = level._spawnData[ level.spawnDataIndex ]
		ShowPlayerData( package, postDrop, level.spawnDataIndex )
		ShowHardpointData( package )
		ShowNPCData( package, postDrop, level.spawnDataIndex )
		ShowSpawnPointData( package )
		ShowInfo( package, level.spawnDataIndex )
		ShowFrontline( package )
		ShowSpawnpointInfo( package )

		postDrop = false

		if ( ButtonPressed( player, "crouch" ) )
		{
			level.spawnDataIndex++
			if ( level.spawnDataIndex >= level._spawnData.len() )
				level.spawnDataIndex = 0
			printt( "level.spawnDataIndex = " + level.spawnDataIndex )
			wait 0.5
		}

		if ( ButtonPressed( player, "useandreload" ) )
		{
			level.spawnDataIndex--
			if ( level.spawnDataIndex < 0 )
				level.spawnDataIndex = ( level._spawnData.len() - 1 )
			printt( "level.spawnDataIndex = " + level.spawnDataIndex )
			wait 0.5
		}

		if ( ButtonPressed( player, "offhand1" ) )
		{
			postDrop = true
		}

		if ( ButtonPressed( player, "offhand2" ) )
		{
			printt( "****************************************" )
			PrintTable( package )
			printt( "****************************************" )
			wait 0.5
		}

		wait 0
	}
}

function SetSpawnDataIndex( index )
{
	if ( "spawnDataIndex" in level )
		level.spawnDataIndex = index
}


function ShowPlayerData( package, postDrop, index )
{
	local playerTeam = package.playerTeam

	local playerArray = package.locationData.playerArray
	if ( postDrop )
	{
		foreach( postDropPackage in level._postDropData )
		{
			if ( postDropPackage.index == index )
			{
				playerArray = postDropPackage.locationData.playerArray
				break
			}
		}
	}

	foreach( playerData in playerArray )
	{
		local color = [ 50, 100, 200, 150 ]
		if ( playerData.team != playerTeam )
			color = [ 200, 50, 50, 150 ]
		if ( !playerData.isAlive )
			color = [ 250, 250, 250, 250 ]

		local boxSize1 = Vector(-48,-48,0)
		local boxSize2 = Vector(48,48,196)
		if ( !playerData.titan )
		{
			boxSize1 = Vector(-16,-16,0)
			boxSize2 = Vector(16,16,72)
		}

		if ( postDrop )
		{
			for( local i = 0; i<3; i++ )
			{
				color[i] = color[i] * 0.75
			}
		}

		DebugDrawLine( playerData.origin, playerData.origin + Vector( 0,0,boxSize2.z ), color[0], color[1], color[2], true, 0.15 )
		DebugDrawBox( playerData.origin, boxSize1, boxSize2, color[0], color[1], color[2], color[3], 0.15 )
		local name = playerData.name.slice( 0, 5 )
		if ( playerData.name != name )
			name += "..."
		DebugDrawText( playerData.origin + Vector(0,0,20), name, true, 0.15 )
	}
}

function ShowHardpointData( package )
{
	local playerTeam = package.playerTeam

	foreach( hardpointData in package.locationData.hardpointArray )
	{
		local color = [ 50, 100, 200, 5 ]
		if ( hardpointData.team != playerTeam )
			color = [ 200, 50, 50, 5 ]
		if ( hardpointData.team == TEAM_UNASSIGNED )
			color = [ 50, 50, 50, 100 ]

		DebugDrawBox( hardpointData.origin, Vector(-256,-256,0), Vector(265,256,64), color[0], color[1], color[2], color[3], 0.15 )
	}
}

function ShowNPCData( package, postDrop, index )
{
	local playerTeam = package.playerTeam

	local npcArray = package.locationData.npcArray
	if ( postDrop )
	{
		foreach( postDropPackage in level._postDropData )
		{
			if ( postDropPackage.index == index )
			{
				npcArray = postDropPackage.locationData.npcArray
				break
			}
		}
	}

	foreach( npcData in npcArray )
	{
		// don't show marvins etc.
		if ( npcData.team != TEAM_IMC && npcData.team != TEAM_MILITIA )
			continue

		local color = [ 10, 60, 125, 150 ]
		if ( npcData.team != playerTeam )
			color = [ 100, 10, 10, 150 ]

		if ( postDrop )
		{
			for( local i = 0; i<3; i++ )
			{
				color[i] = color[i] * 0.75
			}
		}

		if ( "titan" in npcData && npcData.titan )
		{
			DebugDrawLine( npcData.origin, npcData.origin + Vector( 0,0,32 ), color[0], color[1], color[2], true, 0.15 )
			DebugDrawBox( npcData.origin, Vector(-48,-48,0), Vector(48,48,196), color[0], color[1], color[2], color[3], 0.15 )
			if ( "bossPlayer" in npcData && npcData.bossPlayer )
				DebugDrawText( npcData.origin + Vector( 0,0,196 ), "NPC: " + npcData.bossPlayer.slice( 0, 5 ), true, 0.15 )
		}
		else
		{
			DebugDrawLine( npcData.origin, npcData.origin + Vector( 0,0,32 ), color[0], color[1], color[2], true, 0.15 )
			DebugDrawBox( npcData.origin, Vector(-16,-16,0), Vector(16,16,32), color[0], color[1], color[2], color[3], 0.15 )
		}
	}
}

function ShowSpawnPointData( package )
{
	local pickedSpawnpoint = package.pickedSpawnpoint

	local titanSpawn = false
	if ( "titanSpawn" in package )
		titanSpawn = package.titanSpawn

	local boxSize1 = Vector(-16,-16,0)
	local boxSize2 = Vector(16,16,72)
	if ( titanSpawn )
	{
		boxSize1 = Vector(-64,-64,0)
		boxSize2 = Vector(64,64,240)
	}

	local rating = format( "%2.2f", package.rating )

	DrawStar( pickedSpawnpoint + Vector( 0,0,96 ), 48, 0.1, true )
	DebugDrawBox( pickedSpawnpoint, boxSize1, boxSize2, 0, 250, 250, 250, 0.15 )
	DebugDrawText( pickedSpawnpoint + Vector( 0,0,boxSize2.z ), rating, true, 0.15 )

	foreach( spawnpointData in package.spawnpointData )
	{
		if ( VectorCompare( spawnpointData.origin, pickedSpawnpoint ) )
		{
			if ( !spawnpointData.isValid )
			{
				DebugDrawBox( spawnpointData.origin + Vector( 0,0,boxSize2.z ), boxSize1, Vector( boxSize2.x, boxSize2.y, 8 ), 255, 0, 0, 255, 0.15 )
			}
			// check if valid
			continue
		}

		rating = spawnpointData.rating
		local r = GraphCapped( rating, -5, 2, 50, 255 )

		local color = [ 50, r, 50, r ]

		rating = format( "%2.2f", spawnpointData.rating )
		DebugDrawLine( spawnpointData.origin, spawnpointData.origin + Vector( 0,0,boxSize2.z ), color[0], color[1], color[2], true, 0.15 )
		DebugDrawBox( spawnpointData.origin, boxSize1, boxSize2, color[0], color[1], color[2], color[3], 0.15 )
		DebugDrawText( spawnpointData.origin + Vector( 0,0,boxSize2.z ), rating, true, 0.15 )

		if ( !spawnpointData.isValid )
		{
			DebugDrawBox( spawnpointData.origin + Vector( 0,0,boxSize2.z ), boxSize1, Vector( boxSize2.x, boxSize2.y, 8 ), 255, 0, 0, 255, 0.15 )
			DebugDrawText( spawnpointData.origin + Vector( 0,0,boxSize2.z - 100 ), spawnpointData.reason.tostring(), true, 0.15 )
		}
	}
}

function ShowInfo( package, index )
{
	local players = GetPlayerArray()
	local localPlayer
	if ( players.len() )
		localPlayer = GetPlayerArray()[0]
	else
		return

	local velocity  = localPlayer.GetVelocity()
	if ( abs( velocity.x + velocity.y + velocity.z ) > 50 )
		return

	local eyeAngles = localPlayer.EyeAngles()
	local forward = eyeAngles.AnglesToForward()
	local right = eyeAngles.AnglesToRight()
	local up = eyeAngles.AnglesToUp()
	local line1 = localPlayer.EyePosition() + forward * 100 + right * 45 + up * 40
	local line2 = localPlayer.EyePosition() + forward * 100 + right * 45 + up * 38
	local line3 = localPlayer.EyePosition() + forward * 100 + right * 45 + up * 36
	local line4 = localPlayer.EyePosition() + forward * 100 + right * 45 + up * 34
	local line5 = localPlayer.EyePosition() + forward * 100 + right * 45 + up * 32
	local line6 = localPlayer.EyePosition() + forward * 100 + right * 45 + up * 30
	local line7 = localPlayer.EyePosition() + forward * 100 + right * 45 + up * 28
	local line8 = localPlayer.EyePosition() + forward * 100 + right * 45 + up * 26
	local line9 = localPlayer.EyePosition() + forward * 100 + right * 45 + up * 24
	local line10 = localPlayer.EyePosition() + forward * 100 + right * 45 + up * 22

	local playerTeam = package.playerTeam
	local rating = package.rating
	local spawningPlayer = package.player
	local playerArray = package.locationData.playerArray
	local npcArray = package.locationData.npcArray
	local indexText = index + "( " + ( level._spawnData.len() - 1 ) + " )"
	local titanSpawn = "unknown"
	if ( "titanSpawn" in package )
		titanSpawn = package.titanSpawn ? "Titan" : "Pilot"

	local map = ""
	if ( "map" in package )
		map = package.map

	local team = level._spawnData[ index ].playerTeam
	local otherTeam = team == TEAM_IMC ? TEAM_MILITIA : TEAM_IMC

	local closestEnemy = DebugDistToClosest( level._spawnData[ index ], team )
	local closestFriendly = DebugDistToClosest( level._spawnData[ index ], otherTeam )

	DebugDrawText( line1, "Current Index:     " + indexText, true, 0.15 )
	DebugDrawText( line2, "spawnpoint rating: " + rating, true, 0.15 )
	DebugDrawText( line3, "Spawning player:   " + spawningPlayer, false, 0.15 )
	DebugDrawText( line4, "Number of players: " + playerArray.len(), true, 0.15 )
	DebugDrawText( line5, "Number of NPC:     " + npcArray.len(), true, 0.15 )
	DebugDrawText( line6, "Timestamp:         " + package.time, true, 0.15 )
	DebugDrawText( line7, "Spawning as:       " + titanSpawn, true, 0.15 )
	DebugDrawText( line8, "Closest Enemy:     " + closestEnemy, true, 0.15 )
	DebugDrawText( line9, "Closest Friendly:  " + closestFriendly, true, 0.15 )
	DebugDrawText( line10, "Map:               " + map, true, 0.15 )
	// draw
}


function ShowSpawnpointInfo( package )
{
	local players = GetPlayerArray()
	local localPlayer
	if ( players.len() )
		localPlayer = GetPlayerArray()[0]
	else
		return

	local viewVector = localPlayer.GetViewVector()
	local eyePos = localPlayer.EyePosition()
	local selected = null

	foreach( spawnpoint in package.spawnpointData )
	{
		local vector = spawnpoint.origin - eyePos
		vector.Norm()
		local dot = viewVector.Dot( vector )
		if ( dot < 0.999 )
			continue
		selected = spawnpoint
		break
	}

	if ( !selected )
		return

	local eyeAngles = localPlayer.EyeAngles()
	local forward = eyeAngles.AnglesToForward()
	local right = eyeAngles.AnglesToRight()
	local up = eyeAngles.AnglesToUp()

	local index = 0
	foreach ( key, value in selected )
	{
		local pos = localPlayer.EyePosition() + forward * 100 + right * 45 + up * ( 15 - ( index * 2 ) )
		local label = key + ":" + padding( 10 - key.len() )

		if ( key.len() < 4 && key != "flr" && key != "lsr" )
			continue

		if ( ( type( value ) == "float" || type( value ) == "integer" ) && key != "rating" )
			value = format( "%2.2f", value )

		DebugDrawText( pos, label + value, true, 0.15 )

		index++
	}
}

function padding( width )
{
	local padding = ""
	for( local i = 0; i < width; i++ )
		padding += " "
	return padding
}

function ShowFrontline( package )
{
	if ( !( "frontlineCenter" in package ) )
		return

	local center = package.frontlineCenter
	local vector = package.frontlineVector

	local team
	local combatDir = Vector( 0,0,0 )
	if ( "combarDirIMC" in package )
	{
		combatDir = package.playerTeam == TEAM_IMC ? package.combarDirIMC : package.combarDirIMC * -1
		team = package.playerTeam == TEAM_IMC ? "IMC" : "MIL"
	}

	DebugDrawLine( center, center + vector * 1024, 0, 0, 250, true, 0.15 )
	DebugDrawLine( center, center - vector * 1024, 64, 64, 150, true, 0.15 )
	DebugDrawLine( center, center - combatDir * 256, 200, 64, 64, true, 0.15 )
	DebugDrawText( center, team, true, 0.15 )
}

if ( IsHighPerfDevServer() )
{
	function SpawnDataDistCheck()
	{
		foreach( index, package in level._spawnData )
		{
			local baseOrigin = package.pickedSpawnpoint
			local baseTeam = package.playerTeam
			local closestEnemyDist = 100000000
			local closestFriendlyDist = 100000000
			local enemyName

			foreach( enemy in package.locationData.playerArray )
			{
				if ( enemy.team != baseTeam )
				{
					local dist = Distance( baseOrigin, enemy.origin )
					if ( dist > closestEnemyDist )
						continue
					closestEnemyDist = dist
	//				enemyName = enemy.name
				}
				else
				{
					local dist = Distance( baseOrigin, enemy.origin )
					if ( dist > closestFriendlyDist )
						continue
					closestFriendlyDist = dist
				}
			}

			printl( "index:       " + index )
			printl( "name:        " + package.player )
			printl( "rating:      " + package.rating )
			printl( "enemy dist:  " + closestEnemyDist )
			printl( "friend dist: " + closestFriendlyDist )
			printl( "\n" )
		}
	}

	function CullSpawnDataPlayers( minPlayerCount = 6 )
	{
		// remove any spawn data that doesn't reach minPlayerCount
		for( local index = 0; index < level._spawnData.len(); index++ )
		{
			local package = level._spawnData[ index ]
			local playerCount = package.locationData.playerArray.len()
			local cullPackage = true

			if ( playerCount >= minPlayerCount )
				continue

			level._spawnData.remove( index )
			index--	// don't increment
		}

		if ( level._spawnData.len() < 1 )
		{
			level._spawnData = DeepClone( level.base_spawnData )	// everything got removed so restore to base
		}
		else
		{
			level.base_spawnData = DeepClone( level._spawnData )	// culling left something so make this the new base

			if ( !( "spawnDataIndex" in level ) )
				level.spawnDataIndex <- 0
			level.spawnDataIndex = 0
		}
	}

	function CullSpawnDataKeepPlayer( playerName )
	{
		// remove any spawn data that doesn't reach minPlayerCount
		for( local index = 0; index < level._spawnData.len(); index++ )
		{
			local package = level._spawnData[ index ]

			if ( package.player == playerName )
				continue

			level._spawnData.remove( index )
			index--	// don't increment
		}

		if ( level._spawnData.len() < 1 )
		{
			level._spawnData = DeepClone( level.base_spawnData )	// everything got removed so restore to base
		}
		else
		{
			level.base_spawnData = DeepClone( level._spawnData )	// culling left something so make this the new base

			if ( !( "spawnDataIndex" in level ) )
				level.spawnDataIndex <- 0
			level.spawnDataIndex = 0
		}
	}

	function CullSpawnData( distCap = 1000, cullEnemies = true )
	{
		// remove any spawn data that doesn't have an enemy closer then dist
		for( local index = 0; index < level._spawnData.len(); index++ )
		{
			local package = level._spawnData[ index ]
			local baseOrigin = package.pickedSpawnpoint
			local baseTeam = package.playerTeam
			local cullPackage = true

			foreach( enemy in package.locationData.playerArray )
			{
				local sameTeam = ( enemy.team == baseTeam )
				if ( sameTeam == cullEnemies )
					continue

				local dist = Distance( baseOrigin, enemy.origin )
				if ( cullEnemies )
				{	// culling enemies
					if ( dist > distCap || !enemy.isAlive )
						continue
					// an enemy was too close we need to keep this package.
					cullPackage = false
					break
				}
				else
				{	// culling friendlies
					if ( dist < distCap )
					{	// cull when a friendly is close enough, we don't care about this package
						cullPackage = true
						break
					}
					cullPackage = false
				}
			}

			if ( cullPackage )
			{
				// remove the data from level._spawnData
				level._spawnData.remove( index )
				index--	// don't increment
			}
		}

		if ( level._spawnData.len() < 1 )
		{
			level._spawnData = DeepClone( level.base_spawnData )	// everything got removed so restore to base
		}
		else
		{
			level.base_spawnData = DeepClone( level._spawnData )	// culling left something so make this the new base

			if ( !( "spawnDataIndex" in level ) )
				level.spawnDataIndex <- 0
			level.spawnDataIndex = 0
		}
	}

	function CullTitanPlayerData( cullTitans = true )
	{
		// remove any spawn data that isn't for a titan or player
		for( local index = 0; index < level._spawnData.len(); index++ )
		{
			local package = level._spawnData[ index ]

			if ( package.titanSpawn != cullTitans )
			{
				// remove the data from level._spawnData
				level._spawnData.remove( index )
				index--	// don't increment
			}
		}

		if ( level._spawnData.len() < 1 )
			level._spawnData = DeepClone( level.base_spawnData )	// everything got removed so restore to base
		else
			level.base_spawnData = DeepClone( level._spawnData )	// culling left something so make this the new base

	}

	function CullNoPetData( havePet = true )
	{
		// remove any spawn data where the player doesn't have a pet titan
		for( local index = 0; index < level._spawnData.len(); index++ )
		{
			local package = level._spawnData[ index ]
			local npcArray = package.locationData.npcArray
			local bossPlayer = package.player
			local cullPackage = true

			foreach ( npc in npcArray )
			{
				if ( npc.bossPlayer == bossPlayer && npc.titan )
					cullPackage = false
			}

			if ( cullPackage )
			{
				// remove the data from level._spawnData
				level._spawnData.remove( index )
				index--	// don't increment
			}
		}

		// replace the data
		if ( level._spawnData.len() < 1 )
			level._spawnData = DeepClone( level.base_spawnData )	// everything got removed so restore to base
		else
			level.base_spawnData = DeepClone( level._spawnData )	// culling left something so make this the new base

	}

	function RestoreSpawnData()
	{
		level._spawnData = DeepClone( level.base_spawnData )
	}

	function RecalculateSpawnDataComplete()
	{
		foreach( dataIndex, package in level.base_spawnData )
			RecalculateSpawnData( dataIndex )
	}

	function RecalculateSpawnData( dataIndex = null )
	{
		if ( !dataIndex )
			dataIndex = level.spawnDataIndex

		local package = level.base_spawnData[ dataIndex ]
		local newSpawnpointOrigin = package.pickedSpawnpoint
		local bestRating = -1000
		local foundSpawnpoint = false

		foreach( index, spawnpoint in package.spawnpointData )
		{
			local origin = spawnpoint.origin
			local result = ReRateSpawnpoint( package, spawnpoint )

			// don't change frontline invalidated spawnpoints
	//		if ( level._spawnData[ dataIndex ].spawnpointData[index].rating > -100 )
				level._spawnData[ dataIndex ].spawnpointData[index] = result

			if ( result.rating > bestRating && result.isValid )
			{
				newSpawnpointOrigin = origin
				bestRating = result.rating
				foundSpawnpoint = true
			}
		}

		if ( !foundSpawnpoint )
		{
			// if no valid spawns pick the best of the invalid ones
			foreach( index, spawnpoint in level._spawnData[ dataIndex ].spawnpointData )
			{
				if ( spawnpoint.rating > bestRating )
				{
					newSpawnpointOrigin = spawnpoint.origin
					bestRating = spawnpoint.rating
				}
			}
		}

		level._spawnData[ dataIndex ].pickedSpawnpoint = newSpawnpointOrigin
		level._spawnData[ dataIndex ].rating = bestRating
	}

	function ReRateSpawnpoint( package, spawnpoint )
	{
		local team = package.playerTeam
		local origin = spawnpoint.origin

		local e = {}
		e.titanFriendlyRating <- ScriptNearbyAllyScore( origin, package,	0,		1536, "titan" )
		e.npcFriendlyRating <- ScriptNearbyAllyScore( origin, package,		512,	1024, "npc" )
		e.pilotFriendlyRating <- ScriptNearbyAllyScore( origin, package,	0,		1536, "pilot" )

		e.titanEnemyRating <- ScriptNearbyEnemyScore( origin, package,		0,		2048, "titan" )
		e.npcEnemyRating <- ScriptNearbyEnemyScore( origin, package,		512,	1024, "npc" )
		e.pilotEnemyRating <- ScriptNearbyEnemyScore( origin, package,		0,		2048, "pilot" )

		e.petTitanRating <- 0

		local result = {}
		result.tfr	<- e.titanFriendlyRating
		result.pfr	<- e.pilotFriendlyRating
		result.nfr	<- e.npcFriendlyRating
		result.hpr	<- 0
		result.flr	<- 0
		result.ter	<- e.titanEnemyRating
		result.per	<- e.pilotEnemyRating
		result.ner	<- e.npcEnemyRating
		result.sfr	<- 0
		result.ptr	<- 0

		local petTitanOrigin = ReRatePetTitanOrigin( package )
		if ( petTitanOrigin )
		{
			local distSqr = Distance( petTitanOrigin, spawnpoint.origin )
	//		local distSqr = DistanceSqr( petTitanOrigin, spawnpoint.origin )

			local nearDistSqr = 0
			local farDistSqr = 5000
	//		local farDistSqr = 5000 * 5000

			e.petTitanRating = GraphCapped( distSqr, nearDistSqr, farDistSqr, 1, 0 )

			result.ptr = e.petTitanRating
		}

		if ( e.petTitanRating > 0.0  )
		{
			// if we have a pet rating lower the influence of some other ratings
			e.titanFriendlyRating *= 0.25
			e.pilotFriendlyRating *= 0.25
			e.npcFriendlyRating *= 0.25

			e.titanEnemyRating *= 0.5
			e.pilotEnemyRating *= 0.5
			e.npcEnemyRating *= 0.5
		}

		ApplySpawnpointRatingPetTitan( e )
		ApplySpawnpointRating( e )	// uses the same multipliers as the real game

		result.tfrm	<- e.titanFriendlyRating
		result.pfrm	<- e.pilotFriendlyRating
		result.nfrm	<- e.npcFriendlyRating
		result.hprm	<- 0
		result.flrm <- 0
		result.term	<- e.titanEnemyRating
		result.perm	<- e.pilotEnemyRating
		result.nerm	<- e.npcEnemyRating
		result.sfrm	<- 0
		result.ptrm	<- e.petTitanRating

		if ( "flr" in spawnpoint )
		{
			local frontlineRatingBase = spawnpoint.flr
			local frontlineRating

			if ( frontlineRatingBase > 0 )
			{
				// increase rating up to 2048 then back dowan to 0 by 4069 then decrease if further away
				frontlineRating = frontlineRatingBase > 1.0 ? 2.0 - frontlineRatingBase : frontlineRatingBase
			}
			else
			{
				// cap negative rating at -4.0
				frontlineRating = frontlineRatingBase < 0.0 ? max( frontlineRatingBase, -2.0 ): frontlineRatingBase
				frontlineRating *= 2.0
			}

			// if we have a pet rating, ignore frontline rating for this spawnpoint
			if ( e.petTitanRating > 0.0 )
				frontlineRating = frontlineRating > 0 ? frontlineRating * 0.25 : 0.0

			result.flr = frontlineRatingBase
			result.flrm	= frontlineRating * 1.0

		}
		if ( "hprm" in spawnpoint )
		{
			local hpr = spawnpoint.hpr
			result.hpr = hpr

			// if we have a pet rating, lower negative hardpoints ratings for this spawnpoint
			if ( e.petTitanRating > 0.0 && hpr > -3.5 )
				hpr = hpr > 0 ? hpr : hpr * 0.25

			result.hprm	= hpr
			// ApplySpawnpointRatingHardpoints( e )
		}
		if ( "sfr" in spawnpoint )
		{
			result.sfr = spawnpoint.sfr
			result.sfrm = spawnpoint.sfrm
		}


		local friendlyScore = result.tfrm + result.pfrm + result.nfrm + result.ptrm
		local enemyScore = result.term + result.perm + result.nerm

		result.rating	<- friendlyScore + enemyScore + result.flrm + result.hprm - result.sfrm
		result.isValid	<- spawnpoint.isValid
		if ( "reason" in spawnpoint )
			result.reason 	<- spawnpoint.reason
		result.origin	<- spawnpoint.origin

		return result
	}

	function ReRatePetTitanOrigin( package )
	{
		local player = package.player

		foreach( npc in package.locationData.npcArray )
		{
			if ( npc.bossPlayer == player )
				return npc.origin
		}

		return false
	}

	function DeepClone( data )
	{
		if ( type( data ) == "table" )
		{
			local newTable = {}
			foreach( key, value in data )
			{
				newTable[ key ] <- DeepClone( value )
			}
			return newTable
		}
		else if ( type( data ) == "array" )
		{
			local newArray = []
			for( local i = 0; i < data.len(); i++ )
			{
				newArray.append( DeepClone( data[ i ] ) )
			}
			return newArray
		}
		else
		{
			return data
		}
	}

		// special version of IsSpawnpointValid for spawn data collection. It returns the reason why a spawn was invalid.
	function SpawnDataIsSpawnpointInvalid( spawnpoint, team )
	{
		// CodeCallback_RateSpawnpoint sometimes causes this function to be called with spawnpoints that doesn't have .s.inUse
		if ( !( "inUse" in spawnpoint.s ) )
			return "invalid"

		// check if drop pod is en route to this spawnpoint
		if ( spawnpoint.s.inUse )
		{
			//printt( spawnpoint + ": inUse" )
			return "inUse";
		}

		// ensure spawnpoint is not occupied (i.e. would spawn inside another player or object )
		if ( spawnpoint.IsOccupied() )
		{
			//printt( spawnpoint + ": IsOccupied" )
			return "Occupied";
		}

		if ( IsSpawnpointVisibleToTurret( spawnpoint, team ) )
		{
			return "Visible to turret"
		}

		if ( IsSpawnpointNearGrenade( spawnpoint, team ) )
		{
			return "Near Grenade"
		}

		if ( !( "ignoreVisible" in spawnpoint.s ) && spawnpoint.IsVisibleToEnemies( team ) )
		{
			//printt( spawnpoint + ": IsVisibleToEnemies" )
			return "Visible"
		}

		if ( IsSpawnpointInNoSpawnArea( spawnpoint, team ) )
		{
			return "No Spawn Area"
		}

		return 0
	}
}

function DebugDistToClosest( entry, team )
{
	local spawnOrigin = entry.pickedSpawnpoint
	local enemyArray = entry.locationData.playerArray
	local shortest = 1000000
	local name = ""
	foreach( enemyData in enemyArray )
	{
		if ( !enemyData.isAlive || enemyData.team == team )
			continue
		local dist = Distance( enemyData.origin, spawnOrigin )
		if ( dist < shortest )
		{
			shortest = dist
			name = enemyData.name
		}
	}

	return shortest + " - " + name
}


function DebugCheckSpawnpointVsEnemies( player, spawnpoint, team )
{
	local alertDistSqr = 1000 * 1000
	local origin = spawnpoint.GetOrigin()
	local otherTeam = team == TEAM_IMC ? TEAM_MILITIA : TEAM_IMC

	local enemyArray = GetPlayerArrayOfTeam( otherTeam )
	foreach ( enemy in enemyArray )
	{
		if ( !IsAlive( enemy ) )
			continue

		local dist = DistanceSqr( enemy.GetOrigin(), origin )
		if ( dist < alertDistSqr )
			NotifyClientOfBadSpawn( player, "SpawnIssueDistance" )
	}
}

function NotifyClientOfBadSpawn( player, conversation )
{
	return

	DumpLastSpawndata()
	// hud message here if needed
}

function DebugCycleSpawns( titan = false )
{
	printt( "DebugCycleSpawns( titan = " + titan + " )" )
	printt( "****************" )
	DumpStack( 2 )
	printt( "****************" )

	file.cycleSpawns = true
	file.cycleSpawnIndex <- 0

	disable_npcs()

	if ( titan )
	{
		file.cycleSpawnArray <- GetEntArrayByClass_Expensive( "info_spawnpoint_titan_start" )
		file.cycleSpawnArray.extend( SpawnPoints_GetTitan() )
		printt( "Number of Titan spawns:", file.cycleSpawnArray.len() )
	}
	else
	{
		file.cycleSpawnArray <- GetEntArrayByClass_Expensive( "info_spawnpoint_human_start" )
		file.cycleSpawnArray.extend( SpawnPoints_GetPilot() )
		printt( "Number of Pilot spawns:", file.cycleSpawnArray.len() )
	}
}

function SwapSpawnpointTeams()
{
	foreach ( spawnPoint in level.allSpawnpoints )
	{
		// TODO: figure out why these are sometimes invalid
		if ( !IsValid( spawnPoint ) )
			continue

		local spawnPointTeam = spawnPoint.GetTeam()

		if ( spawnPointTeam == TEAM_IMC )
			spawnPoint.SetTeam( TEAM_MILITIA )
		else if ( spawnPointTeam == TEAM_MILITIA )
			spawnPoint.SetTeam( TEAM_IMC )
	}
}