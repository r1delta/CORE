//=========================================================
// MP ai functions for game modes
//
//=========================================================

RegisterSignal( "spotted_by_ai" )

const FRONTLINE_MIN_DIST_SQR		= 262144	// 512
const FRONTLINE_MAX_DIST_SQR		= 16777216	// 4096
const FRONTLINE_NPC_SPAWN_OFFSET	= 0			// min distance away from the frontline that a droppod will spawn.
const FRONTLINE_PLAYER_SPAWN_OFFSET	= 256		// min distance away from the frontline that a player will spawn.
const FRONTLINE_PLAYER_SPAWN_DIST	= 1536		// distance where the spawn score is at it's highest
const FRONTLINE_PLAYER_SPAWN_HEIGHT	= 320		//

const KPS_TIMEFRAME = 20.0			// timeframe in seconds to count death per second within.
const PLAYER_KPS_TIMEFRAME = 60.0	// timeframe in seconds to count death per second within. The goal is to kill 50% of the total player count per team
const FRONTLINE_MIN_TIME = 30.0
const NPC_KPS_LIMIT	= 10			// kills per KPS_TIMEFRAME to trigger a frontline change
const PLAYER_KPS_LIMIT = 0.75		// fraction of player count needed to be killed withing PLAYER_KPS_TIMEFRAME to trigger a frontline change

const MID_SPEC_MAX_AI_COUNT = 9		// max number of AI per side when playing on less then high-end machines (durango)
const MID_SPEC_PLAYER_CUTOFF = 8	// treat the server as high-end when the player count is less or equal to this.

function main()
{
	Globalize( SetupTeamDeathmatchNPCs )
	Globalize( SquadAssaultFrontline )
	Globalize( SquadAssault )
	Globalize( SpawnFrontlineSquad )

	Globalize( GetCurrentFrontline )
	Globalize( GetTeamCombatDir )
	Globalize( MoveFrontline )

	Globalize( GetFreeAISlots )
	Globalize( GetReservedAISquadSlots )
	Globalize( ReserveAISlots )
	Globalize( ReleaseAISlots )
	Globalize( FreeAISlotOnDeath )
	Globalize( ReserveSquadSlots )
	Globalize( ReleaseSquadSlots )

	Globalize( Spawn_TrackedGrunt )
	Globalize( Spawn_TrackedSpectre )
	Globalize( GetIndexSmallestSquad )
	Globalize( TryGetSmallestValidSquad )
	Globalize( SquadValidForClass )
	Globalize( GetReservedSquadSize )

	Globalize( SetFrontlineSides )
	Globalize( GetMaxAICount )
	Globalize( GetSpawnSquadSize )
	Globalize( SetLevelAICount )

	FlagInit( "FrontlineInitiated" )
	RegisterSignal( "FreeAISlotsUpdated" )

	level.max_npc_per_side <- 12

	level.occupiedAISlots <- {}
	level.occupiedAISlots[TEAM_IMC] <- 0
	level.occupiedAISlots[TEAM_MILITIA] <- 0
	level.levelAICount <- {}
	level.levelAICount[ TEAM_IMC ] <- level.max_npc_per_side
	level.levelAICount[ TEAM_MILITIA ] <- level.max_npc_per_side

	level.gameModeAICount <- {}
	level.gameModeAICount[ TEAM_IMC ] <- level.max_npc_per_side
	level.gameModeAICount[ TEAM_MILITIA ] <- level.max_npc_per_side

	level.midSpecAICount <- {}
	level.midSpecAICount[ TEAM_IMC ] <- level.max_npc_per_side
	level.midSpecAICount[ TEAM_MILITIA ] <- level.max_npc_per_side

	level.npcRespawnWait <- 5

	local npcPerSide = level.max_npc_per_side
	switch( GameRules.GetGameMode() )
	{
		case TEAM_DEATHMATCH:
			level.npcRespawnWait = 5
			break
		case ATTRITION:
			level.npcRespawnWait = 5
			break
		case LAST_TITAN_STANDING:
		case WINGMAN_LAST_TITAN_STANDING:
			level.npcRespawnWait = 5
			npcPerSide = GetCPULevelWrapper() == CPU_LEVEL_HIGHEND ? level.max_npc_per_side : 9
			break
		case CAPTURE_THE_FLAG:
			level.npcRespawnWait = 10
			npcPerSide = 9
			break
	}

	SetGameModeAICount( npcPerSide, TEAM_IMC )
	SetGameModeAICount( npcPerSide, TEAM_MILITIA )

	SetMidSpecAICount( MID_SPEC_MAX_AI_COUNT, TEAM_IMC )
	SetMidSpecAICount( MID_SPEC_MAX_AI_COUNT, TEAM_MILITIA )

	SetupLevelAICount()

	level.modifyAISlots <- {}
	level.modifyAISlots[TEAM_IMC] <- 0
	level.modifyAISlots[TEAM_MILITIA] <- 0

	level.reservedAISquadSlots <- {}
	level.dropship_team <- 0
	level.aiSquadCount <- 3
	level.aiSpawnCounter <- {}
	level.aiSpawnCounter[ TEAM_IMC ] <- 0
	level.aiSpawnCounter[ TEAM_MILITIA ] <- 0

	// debug stuff
	Globalize( DebugSendClientFrontline )
	Globalize( DebugSendClientFrontlineAllPlayers )
	Globalize( DebugSquad )
	Globalize( DebugNextFrontline )
	Globalize( DrawCurrentFrontline )
	Globalize( DebugDrawFrontLine )
	Globalize( DebugDrawFrontLineSpawn )
	Globalize( DrawMapCenter )
	Globalize( MoveBot )

	file.botIndex <- 
	{
	 	[TEAM_IMC] = 0, 
	 	[TEAM_MILITIA] = 0
	}

	RegisterSignal( "EndDebugSquadIndex" )

	const DEBUG_NPC_SPAWN			= 1
	const DEBUG_NPC_FRONTLINE		= 2
	const DEBUG_FRONTLINE_ENTS		= 4
	const DEBUG_KPS					= 8
	const DEBUG_ASSAULTPOINT		= 16
	const DEBUG_FRONTLINE_SELECTED	= 32
	const DEBUG_FRONTLINE_SWITCHED	= 64

	level.AssaultFunc <- null
	Globalize( ScriptedSquadAssault )

	file.debug <- 0
//	file.debug = DEBUG_FRONTLINE_SWITCHED
//	file.debug = DEBUG_NPC_SPAWN // + DEBUG_ASSAULTPOINT // + DEBUG_KPS // + DEBUG_FRONTLINE_SELECTED
	// end debug stuff

	SpawnPoints_SetRatingMultipliers_Enemy( TD_AI, -2.0, -0.25, 0.0 )
	SpawnPoints_SetRatingMultipliers_Friendly( TD_AI, 0.5, 0.25, 0.0 )
}

function SetupLevelAICount()
{
	local aiCount = level.max_npc_per_side	// 12

	switch ( GetMapName() )
	{
		case "mp_airbase":
		case "mp_boneyard":
		case "mp_corporate":
		case "mp_nexus":
		case "mp_rise":
		case "mp_outpost_207":
		case "mp_fracture":
		case "mp_relic":
		case "mp_o2":
		case "mp_training_ground":
			// leave at 12
			break

		case "mp_angel_city":
		case "mp_lagoon":
		case "mp_colony":
		case "mp_overlook":
		case "mp_smugglers_cove":
			aiCount = 9
			break

			//aiCount = 6
			//break
	}

	SetLevelAICount( aiCount, TEAM_MILITIA )
	SetLevelAICount( aiCount, TEAM_IMC )
}

function GetMaxAICount( team )
{
	local AICount = min( level.levelAICount[ team ] , level.gameModeAICount[ team ]  )
	if ( GetCPULevelWrapper() != CPU_LEVEL_HIGHEND && !IsTrainingLevel() )
	{
		if ( Flag( "GamePlaying" ) && GameTime.PlayingTime() > START_SPAWN_GRACE_PERIOD )
		{
			// if we have fewer player lets use more AI
			if ( GetPlayerArray().len() > MID_SPEC_PLAYER_CUTOFF ) // fancy lerp action here
				AICount = min( AICount, level.midSpecAICount[ team ] )
		}
	}

	return AICount
}

function SetGameModeAICount( count, team )
{
	Assert( count <= level.max_npc_per_side, "Trying to set the AI count to more then max allowed (" + count + " vs 12)" )
	level.gameModeAICount[ team ] = count
}
Globalize( SetGameModeAICount )

function SetLevelAICount( count, team )
{
	Assert( count <= level.max_npc_per_side, "Trying to set the AI count to more then max allowed (" + count + " vs 12)" )
	level.levelAICount[ team ] = count
}

function SetMidSpecAICount( count, team )
{
	Assert( count <= level.max_npc_per_side, "Trying to set the AI count to more then max allowed (" + count + " vs 12)" )
	level.midSpecAICount[ team ] = count
}

function GetSpawnSquadSize( team )
{
	local maxAICount = GetMaxAICount( team )
	local squadSize = max( 1, floor( maxAICount / 3 ) )	// 3 is the number of squads we have per side.
	return min( squadSize, SQUAD_SIZE )	// never higher then SQUAD_SIZE, it's the max we can spawn with droppods
}

function ReleaseAISlots( team, count = 1 )
{
	level.occupiedAISlots[team] -= count
	level.ent.Signal( "FreeAISlotsUpdated" )
}

function ReserveAISlots( team, count = 1 )
{
	level.occupiedAISlots[team] += count
	level.ent.Signal( "FreeAISlotsUpdated" )
}

function GetFreeAISlots( team )
{
	local maxAICount = GetMaxAICount( team )
	local freeAISlots = maxAICount - level.occupiedAISlots[ team ]

	local modifyAISlots = 0

	if ( level.modifyAISlots[team] < 0 )
		modifyAISlots = min( abs( level.modifyAISlots[team] ), freeAISlots ) * -1
	else if ( level.modifyAISlots[team] > 0 )
		modifyAISlots = min( abs( level.modifyAISlots[team] ), freeAISlots )

	return freeAISlots + modifyAISlots
}

function ReleaseSquadSlots( squadName, count, npcClass )
{
	Assert( squadName in level.reservedAISquadSlots )
	Assert( count >= 1 )
	Assert( level.reservedAISquadSlots[ squadName ].npcClass == npcClass )

	level.reservedAISquadSlots[ squadName ].count -= count
	Assert( level.reservedAISquadSlots[ squadName ].count >= 0 )

	// remove classname when reserved slots are zero
	if ( level.reservedAISquadSlots[ squadName ].count == 0 )
		level.reservedAISquadSlots[ squadName ].npcClass = null
}

function ReserveSquadSlots( squadName, count, npcClass, team )
{
	if ( squadName == null )
		return

	if ( !( squadName in level.reservedAISquadSlots ) )
		level.reservedAISquadSlots[ squadName ] <- { count = 0, npcClass = null, team = team }

	local currentClass = level.reservedAISquadSlots[ squadName ].npcClass
	Assert( currentClass == null || currentClass == npcClass, "Can't reserve slot for npc of class " + npcClass + " in squad " + squadName + " because the NPC's classname doesn't match existing squad classname: " + currentClass )

	level.reservedAISquadSlots[ squadName ].count += count
	level.reservedAISquadSlots[ squadName ].npcClass = npcClass
}

function GetReservedAISquadSlots( squadName )
{
	if ( squadName in level.reservedAISquadSlots )
		return level.reservedAISquadSlots[ squadName ].count

	return 0
}

function GetReservedAISquadSlotsOfClassForTeam( npcClass, team )
{
	local count = 0
	foreach ( table in level.reservedAISquadSlots )
	{
		if ( table.team != team )
			continue

		if ( table.npcClass == npcClass )
			count += table.count
	}

	return count
}
Globalize( GetReservedAISquadSlotsOfClassForTeam )

function IsClassInReservedAISquadSlots_ForSquadName( squadName, npcClass )
{
	if ( squadName in level.reservedAISquadSlots )
	{
		if ( level.reservedAISquadSlots[ squadName ].npcClass == npcClass )
			return true
	}

	return false
}

function Spawn_TrackedSpectre( team, squadName, origin, angles, alert = true, weapon = null, hidden = false )
{
	local spectre = SpawnSpectre( team, squadName, origin, angles, alert, weapon, hidden )

	Assert( IsAlive( spectre ) )

	ReserveAISlots( team )
	FreeAISlotOnDeath( spectre )

	return spectre
}

function Spawn_TrackedGrunt( team, squadName, origin, angles, alert = true )
{
	// Assert( level.freeAISlots[team] > 0 )

	local soldier = SpawnGrunt( team, squadName, origin, angles, alert )

	Assert( IsAlive( soldier ) )

	ReserveAISlots( team )
	FreeAISlotOnDeath( soldier )

	return soldier
}


function Spawn_TrackedDropPodGruntSquad( team, count, spawnPoint, squadName = null )
{
	local ai_type = "npc_soldier"
	return Spawn_TrackedDropPodSquad( ai_type, team, count, spawnPoint, squadName )
}
Globalize( Spawn_TrackedDropPodGruntSquad )


function Spawn_TrackedDropPodSpectreSquad( team, count, spawnPoint, squadName = null )
{
	local ai_type = "npc_spectre"
	return Spawn_TrackedDropPodSquad( ai_type, team, count, spawnPoint, squadName )
}
Globalize( Spawn_TrackedDropPodSpectreSquad )


function Spawn_ScriptedTrackedDropPodGruntSquad( team, count, origin, angles, squadName = null, spawnfunc = null, onImpactFunc = null )
{
	local ai_type 		= "npc_soldier"
	local forced 		= true
	local spawnPoint 	= __CreateDummySpawnPoint( origin, angles )

	local soldierEntities = Spawn_TrackedDropPodSquad( ai_type, team, count, spawnPoint, squadName, forced, spawnfunc, onImpactFunc )
	spawnPoint.Kill()

	return soldierEntities
}
Globalize( Spawn_ScriptedTrackedDropPodGruntSquad )


function Spawn_ScriptedTrackedDropPodSpectreSquad( team, count, origin, angles, squadName = null, spawnfunc = null, onImpactFunc = null )
{
	local ai_type 		= "npc_spectre"
	local forced 		= true
	local spawnPoint 	= __CreateDummySpawnPoint( origin, angles )

	if ( spawnfunc == null )
		spawnfunc = SpawnSpectre

	local soldierEntities = Spawn_TrackedDropPodSquad( ai_type, team, count, spawnPoint, squadName, forced, spawnfunc, onImpactFunc )
	spawnPoint.Kill()

	return soldierEntities
}
Globalize( Spawn_ScriptedTrackedDropPodSpectreSquad )


function __CreateDummySpawnPoint( origin, angles )
{
	local spawnPoint 	= CreateScriptRef( origin, angles )
	spawnPoint.s.inUse 	<- false
	return spawnPoint
}


function Spawn_TrackedDropPodSquad( ai_type, team, count, spawnPoint, squadName = null, force = false, spawnfunc = null, onImpactFunc = null )
{
	if ( !IsNPCSpawningEnabled( team ) && !force )
		return []

	if ( !force )
		Assert( count <= GetFreeAISlots(team), "wanted to spawn: " + count + " AI but only " + GetFreeAISlots( team ) + " slots where free" )

	if(!spawnPoint)		// 데이터가 없을 경우에는 리턴
		return

	CommonTrackingInit( ai_type, team, count, squadName )
	spawnPoint.s.inUse = true

	local dropPod = CreatePropDynamic( DROPPOD_MODEL ) // model is set in InitFireteamDropPod()
	InitFireteamDropPod( dropPod )

	local options = {}
	if ( onImpactFunc )
		options.onImpactFunc <- onImpactFunc

	waitthread LaunchAnimDropPod( dropPod, "pod_testpath", spawnPoint.GetOrigin(), spawnPoint.GetAngles(), options )
	if ( force )
		PlayFX( "droppod_impact", spawnPoint.GetOrigin(), spawnPoint.GetAngles() )

	if ( spawnfunc == null )
	{
		if ( ai_type == "npc_spectre" )
			spawnfunc = SpawnSpectre
		else
			spawnfunc = SpawnGrunt
	}

	local soldierEntities = CreateNPCSForDroppod( team, count, spawnPoint.GetOrigin(), spawnPoint.GetAngles(), squadName, force, spawnfunc )
	ActivateFireteamDropPod( dropPod, null, soldierEntities )

	CommonTrackingCleanup( soldierEntities, ai_type, team, count, squadName )
	spawnPoint.s.inUse = false

	return soldierEntities
}
Globalize( Spawn_TrackedDropPodSquad )


function CommonTrackingInit( ai_type, team, count, squadName )
{
	Assert( ai_type != null )
	ReserveAISlots( team, count )
	ReserveSquadSlots( squadName, count, ai_type, team )
}
Globalize( CommonTrackingInit )


function CommonTrackingCleanup( guys, ai_type, team, count, squadName )
{
	Assert( ai_type != null )
	if ( count != guys.len() )
		ReleaseAISlots( team, count - guys.len() )
	ReleaseSquadSlots( squadName, count, ai_type )

	foreach ( npc in guys )
		FreeAISlotOnDeath( npc )
}
Globalize( CommonTrackingCleanup )


function Spawn_TrackedZipLineGruntSquad( team, count, spawnPoint, squadName = null )
{
	local ai_type = "npc_soldier"
	local dropTable = CreateZipLineSquadDropTable( team, count, spawnPoint, squadName )
	return Spawn_TrackedZipLineSquad( ai_type, spawnPoint, dropTable )
}
Globalize( Spawn_TrackedZipLineGruntSquad )


function Spawn_TrackedZipLineSpectreSquad( team, count, spawnPoint, squadName = null )
{
	local ai_type = "npc_spectre"
	local dropTable = CreateZipLineSquadDropTable( team, count, spawnPoint, squadName )
	return Spawn_TrackedZipLineSquad( ai_type, spawnPoint, dropTable )
}
Globalize( Spawn_TrackedZipLineSpectreSquad )


function Spawn_ScriptedTrackedZipLineGruntSquad( team, count, origin, angles, squadName = null, spawnfunc = null )
{
	local ai_type 		= "npc_soldier"
	local forced 		= true
	local spawnPoint 	= __CreateDummySpawnPoint( origin, angles )
	local dropTable 	= CreateZipLineSquadDropTable( team, count, spawnPoint, squadName, forced, spawnfunc )

	local soldierEntities = Spawn_TrackedZipLineSquad( ai_type, spawnPoint, dropTable, forced )
	spawnPoint.Kill()

	return soldierEntities
}
Globalize( Spawn_ScriptedTrackedZipLineGruntSquad )


function Spawn_ScriptedTrackedZipLineSpectreSquad( team, count, origin, angles, squadName = null, spawnfunc = null )
{
	local ai_type 		= "npc_spectre"
	local forced 		= true
	local spawnPoint 	= __CreateDummySpawnPoint( origin, angles )
	local dropTable 	= CreateZipLineSquadDropTable( team, count, spawnPoint, squadName, forced, spawnfunc )

	local soldierEntities = Spawn_TrackedZipLineSquad( ai_type, spawnPoint, dropTable, forced )
	spawnPoint.Kill()

	return soldierEntities
}
Globalize( Spawn_ScriptedTrackedZipLineSpectreSquad )


function CreateZipLineSquadDropTable( team, count, spawnPoint, squadName, force = null, spawnfunc = null )
{
	if ( spawnfunc == null )
		spawnfunc = SpawnGrunt

	if(!spawnPoint)		// 스폰포인트가 없으면 스킵
		return

	local drop			= CreateDropshipDropoff()
	drop.origin 		= spawnPoint.GetOrigin()
	drop.yaw 			= spawnPoint.GetAngles().y
	drop.dist 			= 768
	drop.count 			= count
	drop.team 			= team
	drop.squadname 		= squadName
	drop.npcSpawnFunc 	= spawnfunc
	drop.style 			= eDropStyle.ZIPLINE_NPC
	drop.assaultEntity 	<- spawnPoint

	if ( force )
		drop.style			= eDropStyle.FORCED

	return drop
}
Globalize( CreateZipLineSquadDropTable )


function Spawn_TrackedZipLineSquad( ai_type, spawnPoint, dropTable, force = false )
{
	if(!spawnPoint)
		return
	
	local team 		= dropTable.team
	local count 	= dropTable.count
	local squadname = dropTable.squadname
	Assert( team != null )
	Assert( squadname != null )

	if ( !IsNPCSpawningEnabled( team ) && !force )
		return []

	if ( !force )
		Assert( count <= GetFreeAISlots(team), "wanted to spawn: " + count + " AI but only " + GetFreeAISlots( team ) + " slots where free" )

	CommonTrackingInit( ai_type, team, count, squadname )
	spawnPoint.s.inUse = true

	thread RunDropshipDropoff( dropTable )

	local soldierEntities = []
	if ( dropTable.success )
	{
		// get the guys that spawned
		local results = WaitSignal( dropTable, "OnDropoff" )
		Assert( "guys" in results )

		if ( results.guys )
			soldierEntities = results.guys
	}

	CommonTrackingCleanup( soldierEntities, ai_type, team, count, squadname )
	spawnPoint.s.inUse = false

	return soldierEntities
}
Globalize( Spawn_TrackedZipLineSquad )


function FreeAISlotOnDeath( soldier )
{
	Assert( IsAlive( soldier ), soldier + " is not alive!" )
	thread FreeAISlotOnDeathThread( soldier )
}

function FreeAISlotOnDeathThread( soldier )
{
	soldier.EndSignal( "OnDestroy" )

	local team = soldier.GetTeam()	//wouldn't leeched spectres break team AI slot counts?
	OnThreadEnd( function() : (team) { ReleaseAISlots( team ) } )

	soldier.WaitSignal( "OnDeath" )
}



//////////////////////////////////////////////////////////
function SetupTeamDeathmatchNPCs()
{
	FlagWait( "ReadyToStartMatch" )

	if ( InitFrontLine() )
	{
		FlagSet( "FrontlineInitiated" )

		local waitTime = GameTime.TimeLeftSeconds() - GetDropPodAnimDuration() + 3
		if ( GetGameState() <= eGameState.Prematch && waitTime > 0 )
			wait waitTime

		thread TeamDeathmatchSpawnNPCsThink()
	}
}

function TeamDeathmatchSpawnNPCsThink()
{
	local teams = [TEAM_IMC, TEAM_MILITIA]
	local extraGrunts

	while ( IsNPCSpawningEnabled() )
	{
		extraGrunts = GetGruntBonusForTeam( TEAM_IMC )

		level.modifyAISlots[ TEAM_IMC ] = extraGrunts * -1
		level.modifyAISlots[ TEAM_MILITIA ] = extraGrunts

		if ( !Flag( "Disable_IMC" ) )
			thread TeamDeathmatchSpawnNPCs( TEAM_IMC )

		if ( !Flag( "Disable_MILITIA" ) )
			thread TeamDeathmatchSpawnNPCs( TEAM_MILITIA )

		wait level.npcRespawnWait
	}
}

function GetGruntBonusForTeam( team )
{
	local titanCompare = CompareTitanTeamCount( team )

	// must have at least 3 titan difference
	if ( abs( titanCompare ) <= 2 )
		return 0

	if ( titanCompare > 0 )
	{
		titanCompare -= 1
	}
	else
	{
		titanCompare += 1
	}

	// a titan is worth how many grunts?
	return titanCompare * 2
}

function TeamDeathmatchSpawnNPCs( team )
{
	local numFreeSlots = GetFreeAISlots( team )

	while ( numFreeSlots >= GetSpawnSquadSize( team ) )
	{
		// this will do all the heavy lifting of where and how many to spawn and what they should do once they are in the match.
		thread SpawnFrontlineSquad( team, numFreeSlots )

		// add a little wait so that we don't spawn squads at the exact same time.
		wait RandomFloat( 0.8, 2.0 )

		// the function above will have used up some free slots, lets see how many remain
		numFreeSlots = GetFreeAISlots( team )
	}

}

function SpawnFrontlineSquad( team, numFreeSlots )
{
	if ( !IsNPCSpawningEnabled() )
		return

	local shouldSpawnSpectre = ShouldSpawnSpectre( team )

	local squadIndex = TryGetSmallestValidSquad( team, shouldSpawnSpectre )
	if ( squadIndex == null )
		return

	local squadName = MakeSquadName( team, squadIndex )
	local squadSize = min( numFreeSlots, GetSpawnSquadSize( team ) )
	Assert( squadSize <= GetFreeAISlots( team ), "Squadsize " + squadSize + " is greater than remaining ai slots " + GetFreeAISlots( team ) )

	local inGracePeriod = GameTime.PlayingTime() < START_SPAWN_GRACE_PERIOD
	local inGameState = GetGameState() <= eGameState.Prematch || GetGameState() ==  eGameState.SwitchingSides
	local useStartSpawn = inGameState || inGracePeriod
	local spawnPointArray

	if ( useStartSpawn )
	{
		spawnPointArray = SpawnPoints_GetDropPodStart( team )

		//Assert( /*level.isTestmap ||*/ spawnPointArray.len(), "level didn't have any info_spawnpoint_droppod_start for team " + team )

		if ( !spawnPointArray.len() )
		{
			spawnPointArray = SpawnPoints_GetDropPod()
			useStartSpawn = false
		}
	}
	else
	{
		spawnPointArray = SpawnPoints_GetDropPod()
	}

	//! 스폰포인트가 없으면 스킵
	if(spawnPointArray.len() < 1)
	{
		//printl("_ai_game_modes.nut : 스폰 포인트가 없음")
		return
	}
	// if something got this far and we don't have any spawnpoints then something is wrong.
	Assert( spawnPointArray.len() )

	local spawnPoint = GetFrontlineSpawnPoint( spawnPointArray, team, squadIndex, shouldSpawnSpectre, useStartSpawn )
	Assert( spawnPoint )
	++level.aiSpawnCounter[ team ]

	local npcArray

	if ( shouldSpawnSpectre )
	{
		npcArray = Spawn_TrackedDropPodSpectreSquad( team, squadSize, spawnPoint, squadName )
	}
	else
	{
		if ( Flag( "DisableDropships" ) || GameRules.GetGameMode() == EXFILTRATION )
		{
			Assert( squadSize <= GetFreeAISlots(team) )
			npcArray = Spawn_TrackedDropPodGruntSquad( team, squadSize, spawnPoint, squadName )
		}
		else
		{
			Assert( squadSize <= GetFreeAISlots(team) )
			if ( level.aiSpawnCounter[ team ] % 3 == 0 ) // 1 in every 3 grunt squad comes in via ship
				npcArray = Spawn_TrackedZipLineGruntSquad( team, squadSize, spawnPoint, squadName )
			else
				npcArray = Spawn_TrackedDropPodGruntSquad( team, squadSize, spawnPoint, squadName )
		}
	}

	// make the squad assault the correct frontline
	SquadAssaultFrontline( npcArray, squadIndex )
}


function GetIndexSmallestSquad( team )
{
	local smallestSize = null
	local squadIndex

	for( local index = 0; index < level.aiSquadCount; index++ )
	{
		local squadName = MakeSquadName( team, index )

		local squadSize = GetNPCSquadSize( squadName )
		squadSize += GetReservedAISquadSlots( squadName )	// add on any reserved AI squad slots

		if ( squadSize < smallestSize || smallestSize == null )
		{
			smallestSize = squadSize
			squadIndex = index
		}
	}

	Assert( squadIndex != null )
	return squadIndex
}

// Whichever type of guy we want to spawn, we have to make sure there is a squad for him.
//  - This means, an empty squad, OR a squad with guys of that type already in it.
//  - NOTE returns null if there's no valid squad for the guy
function TryGetSmallestValidSquad( team, wantSpectreSquad )
{
	local classnameToMatch = "npc_soldier"
	if ( wantSpectreSquad )
		classnameToMatch = "npc_spectre"

//	printt( "Trying to spawn in", classnameToMatch )

	local smallestSize = null
	local squadIndex = null

	for ( local index = 0; index < level.aiSquadCount; index++ )
	{
		local squadName = MakeSquadName( team, index )

		// we only want squads containing npcs with the same classname
		if ( !SquadValidForClass( squadName, classnameToMatch ) )
			continue

		local squadSize = GetReservedSquadSize( squadName )

		if ( squadSize < smallestSize || smallestSize == null )
		{
			smallestSize = squadSize
			squadIndex = index
		}
	}

//	printt( "adding", classnameToMatch, "to squad index", squadIndex )
	return squadIndex
}

function GetReservedSquadSize( squadName )
{
	local squadSize = GetNPCSquadSize( squadName )
	squadSize += GetReservedAISquadSlots( squadName )	// add on any reserved AI squad slots
	return squadSize
}

function SquadValidForClass( squadName, classnameToMatch )
{
	if ( GetReservedAISquadSlots( squadName ) )
	{
		// if we have reserved squad slots they must be reserved by the correct class.
		if ( !IsClassInReservedAISquadSlots_ForSquadName( squadName, classnameToMatch ) )
			return false
	}

	local squadSize = GetNPCSquadSize( squadName )

	// empty squads are legit for any class;
	//  also, can't GetNPCArrayBySquad if there are no NPCs with that squad set
	if ( !squadSize )
	{
		//printt( "squad is empty", squadName )
		return true
	}

	local checkSquad = GetNPCArrayBySquad( squadName )

	foreach ( guy in checkSquad )
	{
		if ( IsValid( guy ) && guy.GetClassname() != classnameToMatch )
			return false
	}

	//printt( "all guys are valid in", squadName )
	//Dump( checkSquad )
	return true
}


function GetFrontlineSpawnPoint( spawnPointArray, team, squadIndex, shouldSpawnSpectre, useStartSpawn )
{
	local frontlinePoint = GetFrontlineGoal( squadIndex, team, shouldSpawnSpectre )
	local combatDir = GetTeamCombatDir( file.currentFrontline, team )
	local edgeOrigin = frontlinePoint.GetOrigin() - combatDir * FRONTLINE_NPC_SPAWN_OFFSET

	SpawnPoints_InitRatings( null )

	foreach ( spawnpoint in spawnPointArray )
		RateFrontLineNPCSpawnpoint( spawnpoint, team, edgeOrigin, combatDir )

	if ( useStartSpawn )
	{
		SpawnPoints_SortDropPodStart()
		spawnPointArray = SpawnPoints_GetDropPodStart( team )
	}
	else
	{
		SpawnPoints_SortDropPod()
		spawnPointArray = SpawnPoints_GetDropPod()
	}

	foreach ( spawnpoint in spawnPointArray )
	{
		if ( IsSpawnpointValidDrop( spawnpoint, team ) )
			return spawnpoint
	}

	// 테스트 맵일 경우에는 이상한 정보가 올수 있다.
	//if(level.isTestmap)
	//	return

	// we will always return a spawnpoint even if it's a bad one.
	return spawnPointArray[0]
}


//////////////////////////////////////////////////////////
function InitFrontLine()
{
	file.nextOverrunCheck <- Time()
	file.frontlineGroupTable <- {}
	file.currentFrontline <- null
	
	file.frontlineTeamSide <- 
	{ 
		[TEAM_IMC] = 0, 
		[TEAM_MILITIA] = 1
	}

	file.npcDeathPerTeam <- 
	{
		[TEAM_UNASSIGNED] = [], 
		[TEAM_IMC] = [], 
		[TEAM_MILITIA] = []
	}

	file.playerDeathPerTeam <- 
	{
	 	[TEAM_UNASSIGNED] = [], 
	 	[TEAM_IMC] = [], 
	 	[TEAM_MILITIA] = []
	 }

	InitFrontlineGroups()
	if ( !file.frontlineGroupTable.len() )
		return false

	AddDeathCallback( "npc_soldier", FrontlineDeathNPC )
	AddDeathCallback( "npc_spectre", FrontlineDeathNPC )
	AddDeathCallback( "player", FrontlineDeath )
	AddDeathCallback( "npc_titan", FrontlineDeath )

	// select current frontline group
	// this will most likely be the one closest to the center of the map
	local spawnpoints = SpawnPoints_GetDropPodStart( TEAM_ANY )
	local mapCenter = GetMapCenter( spawnpoints )

	// get center most frontline to start with
	local oldDist = 100000 * 100000
	foreach( group, groupTable in file.frontlineGroupTable )
	{
		local dist = Distance2DSqr( mapCenter, groupTable.frontlineCenter )
		if ( dist > oldDist )
			continue

		oldDist = dist
		file.currentFrontline = groupTable	// set to closest group
	}

	SetFrontlineSides( file.currentFrontline, TEAM_MILITIA )

	DebugSendClientFrontlineAllPlayers()

	return true
}



//////////////////////////////////////////////////////////
function GameModeRemoveFrontline( entArray )
{
	// remove frontlines not for the current gamemode
	local keepUndefined = false
	local gameMode = GameRules.GetGameMode()
	switch ( gameMode )
	{
		case CAPTURE_THE_FLAG:
		case LAST_TITAN_STANDING:
		case WINGMAN_LAST_TITAN_STANDING:
			break
		default:
			keepUndefined = true
			gameMode = TEAM_DEATHMATCH
			break
	}

	local gamemodeKey = "gamemode_" + gameMode
	for ( local index = 0; index < entArray.len(); index++ )
	{
		local ent = entArray[ index ]

		if ( ent.HasKey( gamemodeKey ) && ent.kv[gamemodeKey] == "1" )
			continue	// if the key exist and it's true then keep the frontline
		else if ( !ent.HasKey( gamemodeKey ) && keepUndefined )
			continue	// if the key doesn't exist but keepUndefined is true keep the frontline

		// delete and remove it from the array
		ent.Destroy()
		entArray.remove( index )
		index--	// decrement to counteract the regular increment in the for loop
	}
}

//////////////////////////////////////////////////////////
function InitFrontlineGroups()
{
	// find all info_frontline ents
	local entArray = GetEntArrayByClass_Expensive( "info_frontline" )
	GameModeRemoveFrontline( entArray )

	if ( entArray.len() == 0 )
		entArray = CreateTempFrontline()

	local spectreNodeArray = []

	foreach ( info_frontline in entArray )
	{
		if ( info_frontline.HasKey( "spectrepoint" ) && info_frontline.kv.spectrepoint == "1" )
		{
			spectreNodeArray.append( info_frontline )
			continue
		}
		// group them based on group name
		local group = "temp_group"
		if ( info_frontline.HasKey( "group" ) )
			group = info_frontline.Get( "group" )
		local side = info_frontline.GetTeam()	//	0 or 1

		if ( !( group in file.frontlineGroupTable ) )
			file.frontlineGroupTable[ group ] <- CreateFrontlineTable()

		file.frontlineGroupTable[ group ].name = group

		if ( file.debug & DEBUG_FRONTLINE_ENTS )
			DebugDrawText( info_frontline.GetOrigin(), "o", false, 10 )

		file.frontlineGroupTable[ group ].sideNodeArray[ side ].append( info_frontline )
	}

	// calculate frontline center and direction
	foreach( group, frontlineTable in file.frontlineGroupTable )
	{
		Assert( frontlineTable.sideNodeArray[0].len() == 3, "Frontline group [" + group + "] does not have 3 info_frontline ents for side #0" )
		Assert( frontlineTable.sideNodeArray[1].len() == 3, "Frontline group [" + group + "] does not have 3 info_frontline ents for side #1" )

		frontlineTable.frontlineCenter = GetFrontlineCenter( frontlineTable )
		frontlineTable.frontlineVector = GetFrontlineVector( frontlineTable )

		frontlineTable.width = GetFrontlineWidth( frontlineTable )

		frontlineTable.combatDir = Vector( frontlineTable.frontlineVector.y, -frontlineTable.frontlineVector.x, 0 )

		if ( file.debug & DEBUG_FRONTLINE_ENTS )
		{
			// debug stuff
			local o = frontlineTable.frontlineCenter
			local v = frontlineTable.frontlineVector
			local dir = Vector( v.y, -v.x, 0 )	// vector pointing away from side 0 towards side 1
			DebugDrawLine( o, o + v * 1000, 0, 0, 255, true, 10 )
			DebugDrawLine( o, o + v * -1000, 0, 0, 128, true, 10 )
			DebugDrawLine( o, o + dir * 1000, 255,0, 0, true, 10 )
			DebugDrawLine( o, o + dir * -1000, 128, 0, 0, true, 10 )

			DebugDrawText( frontlineTable.frontlineCenter, group, false, 10 )
		}
	}

	// pair up spectre frontline nodes with it's closest regular frontline node
	foreach( spectreNode in spectreNodeArray )
	{
		local group = spectreNode.kv.group
		local side = spectreNode.GetTeam()
		local nearestDist = null
		local nearestNode = null
		Assert( group in file.frontlineGroupTable )

		foreach( frontlineNode in file.frontlineGroupTable[ group ]["sideNodeArray"][ side ] )
		{
			local dist = Distance( spectreNode.GetOrigin(), frontlineNode.GetOrigin() )
			if ( nearestDist == null || dist < nearestDist )
			{
				if ( "spectreNode" in frontlineNode.s )
					continue

				nearestDist = dist
				nearestNode = frontlineNode
			}
		}

		Assert( nearestNode, "couldn't find a frontline node to for frontline spectre node at " +  spectreNode.GetOrigin() )
		nearestNode.s.spectreNode <- spectreNode
	}
}

//////////////////////////////////////////////////////////
function CreateFrontlineTable()
{
	local frontlineTable = {}

	frontlineTable.sideNodeArray	<- [ [], [] ]	// two arrays for side 0 and side 1
	frontlineTable.frontlineCenter	<- null
	frontlineTable.frontlineVector	<- null
	frontlineTable.combatDir		<- null
	frontlineTable.width			<- null
	frontlineTable.lineDistFrac		<- 0
	frontlineTable.useCount			<- 0
	frontlineTable.name				<- ""

	return frontlineTable
}

//////////////////////////////////////////////////////////
function CheckFrontlineOverrun( losingTeam )
{
	// the frontline is overrun when there are more enemies then friendlies on the dead players side of the line.
	// losingTeam is the team of the player that died.

	// don't move frontline after the match is won.
	if ( GetGameState() >= eGameState.WinnerDetermined )
		return

	local otherTeam

	switch (losingTeam)
	{
		case TEAM_IMC:
		{
			otherTeam = TEAM_MILITIA
			break
		}
		case TEAM_MILITIA:
		{
			otherTeam = TEAM_IMC
			break
		}
	}

	local teamScore = [ 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ]
	local frontline = file.currentFrontline
	local center = frontline.frontlineCenter
	local combatDir = GetTeamCombatDir( frontline, otherTeam )
	local playerArray = GetLivingPlayers()
	local rest = 0

	foreach( player in playerArray )
	{
		local team = player.GetTeam()
		local offsetCenter = team == losingTeam ? center - combatDir * 512 : center

		if ( IsPointInFrontofLine( player.GetOrigin(), offsetCenter, combatDir ) )
		{
			teamScore[ team ] += 1.0
		}
		else
		{
			// player on the other side of the line
			rest++
		}
	}

	if ( rest > ( playerArray.len() / 2.0 ) )
		return	// more players on the other side of the line.

	if ( teamScore[ losingTeam ] < teamScore[ otherTeam ] )
	{
		local prevFrontlineName = file.currentFrontline.name

		MoveFrontline( otherTeam )

		if ( file.debug & DEBUG_FRONTLINE_SWITCHED )
		{
			local teamStr = ( otherTeam == TEAM_IMC ) ? "IMC" : "Militia"
			printt( teamStr, "forced a Frontline switch" )
			printt( prevFrontlineName, " --> ", file.currentFrontline.name )
			printt( format( "%2.1f points vs %2.1f points. A total of %d living Players.", teamScore[ otherTeam ], teamScore[ losingTeam ] , playerArray.len() ) )
		}
	}
}

//////////////////////////////////////////////////////////
function MoveFrontline( winningTeam )
{
	if ( GameRules.GetGameMode() == CAPTURE_THE_FLAG )
		return

	local prevFrontlineName = file.currentFrontline.name

	// switch to different frontline
	file.currentFrontline = GetBestFrontline( winningTeam )
	file.currentFrontline.useCount++
	file.nextOverrunCheck = Time() + FRONTLINE_MIN_TIME

	DebugSendClientFrontlineAllPlayers()

	// determine what sides of the new fronline belong to what team
	SetFrontlineSides( file.currentFrontline, winningTeam )

	// reset the KPS stuff
	ResetFrontlineKillsPerSecond()

	// gather all squads and have them assault the new fronline
	for ( local squadIndex = 0; squadIndex < level.aiSquadCount; squadIndex++ )
	{
		local squadName = MakeSquadName( TEAM_IMC, squadIndex )
		local squadSize = GetNPCSquadSize( squadName )
		if ( squadSize )
		{
			local squad = GetNPCArrayBySquad( squadName )
			SquadAssaultFrontline( squad, squadIndex )
		}

		squadName = MakeSquadName( TEAM_MILITIA, squadIndex )
		squadSize = GetNPCSquadSize( squadName )
		if ( squadSize )
		{
			local squad = GetNPCArrayBySquad( squadName )
			SquadAssaultFrontline( squad, squadIndex )
		}
	}
}

//////////////////////////////////////////////////////////
function GetCurrentFrontline()
{
	if ( !Flag( "FrontlineInitiated" ) )
		return null

	return file.currentFrontline
}

//////////////////////////////////////////////////////////
function GetTeamCombatDir( frontline, team )
{
	// combatDir points towards side 1 by default
	// if the team belongs to side 1 we need to reverse the direction
	local combatDir = frontline.combatDir
	if ( file.frontlineTeamSide[ team ] == 1 )
		combatDir *= -1	// make sure combatDir is heading away from the team side, combatDir points towards side 1 by default.
	return combatDir
}

//////////////////////////////////////////////////////////
function GetBestFrontline( winningTeam )
{
	/*
		will look for frontlines in the winning teams combat direction.
		if none is found it will look 45 degrees to the right then 45 degrees to the left and finally opposite to the combat direction.
		with a fov (minDot) of 67.5 degree every direction will be covered, so it should always return a frontline.
	*/

	local combatDir = GetTeamCombatDir( file.currentFrontline, winningTeam )

	local right = CalcRelativeVector( Vector( 0,45,0), combatDir )
	local left = CalcRelativeVector( Vector( 0,-45,0), combatDir )
	local rear = combatDir * -1
	local vectorArray = [ combatDir, right, left, rear ]

	foreach( index, vector in vectorArray )
	{
		//DebugDrawLine( file.currentFrontline.frontlineCenter, file.currentFrontline.frontlineCenter + vector * 5000, 0, 255, 0, true, 2 )
		local frontline = FindFrontlineInDirection( vector )
		if ( frontline )
		{
			//printt( "Found frontline using index: ", index )
			return frontline
		}
	}

	// fallback in case no new frontline was found. Happens in map that only have one.
	return file.currentFrontline
}

//////////////////////////////////////////////////////////
function FindFrontlineInDirection( forwardVector )
{
	local currentCenter = file.currentFrontline.frontlineCenter
	local maxDist = 5000
	local graceRange = 768
	local minDot = 0.38		// about 67.5 degrees.
	local forwardFrontline = null
	local leastUsed
	local closestDistFrac = 1
	local frontlineSelection = []

	foreach( groupName, frontline in file.frontlineGroupTable )
	{
		frontline.lineDistFrac = 0

		if ( frontline == file.currentFrontline )
			continue

		local vector = frontline.frontlineCenter - currentCenter
		local dist = vector.Norm()
		local dot = forwardVector.Dot( vector )	// positive is infront of the line

		if ( dot > minDot && dist < maxDist )
		{
			//DebugDrawLine( currentCenter, frontline.frontlineCenter, 255, 255, 0, true, 2 )
			//DebugDrawText( frontline.frontlineCenter + Vector(0,0,200), "Dot: " + dot.tostring() + " Dist: " + dist.tostring(), false, 2 )

			local lineTable = CalcClosestPointOnLine( frontline.frontlineCenter, currentCenter, currentCenter + forwardVector * maxDist )
			Assert( lineTable.t > 0 )

			frontline.lineDistFrac = lineTable.t
			frontlineSelection.append( frontline )

			if ( lineTable.t < closestDistFrac )
			{
				closestDistFrac = lineTable.t
				leastUsed = frontline.useCount
				forwardFrontline = frontline
			}
		}
	}

	if ( !forwardFrontline )
		return false

	// find any frontlines withing graceRange of the closest frontline and select the least used.
	foreach( frontline in frontlineSelection )
	{
		if ( frontline == file.currentFrontline )
			continue

		local distDif = ( frontline.lineDistFrac - closestDistFrac ) * maxDist
		if ( abs( distDif ) > graceRange )
			continue

		if ( frontline.useCount < leastUsed )
		{
			forwardFrontline = frontline
			leastUsed = frontline.useCount
		}
	}

	Assert( forwardFrontline )
	return forwardFrontline
}

//////////////////////////////////////////////////////////
function GetFrontlineCenter( frontlineTable )
{
	local entArray = clone frontlineTable.sideNodeArray[0]
	Assert( entArray.len() )

	entArray.extend( frontlineTable.sideNodeArray[1] )

	local centerPos = Vector( 0,0,0 )
	foreach( ent in entArray )
		centerPos += ent.GetOrigin()

	centerPos *= ( 1.0 / entArray.len() )
	return centerPos
}

//////////////////////////////////////////////////////////
function GetFrontlineVector( frontlineTable )
{
	local centerPos0 = Vector( 0,0,0 )
	foreach( ent in frontlineTable.sideNodeArray[0] )
		centerPos0 += ent.GetOrigin()

	local centerPos1 = Vector( 0,0,0 )
	foreach( ent in frontlineTable.sideNodeArray[1] )
		centerPos1 += ent.GetOrigin()

	centerPos0 *= ( 1.0 / frontlineTable.sideNodeArray[0].len() )
	centerPos1 *= ( 1.0 / frontlineTable.sideNodeArray[1].len() )

	local vector = centerPos1 - centerPos0
	vector.Norm()

	// return the left vector
	return Vector( -vector.y, vector.x, 0 )
}

function GetFrontlineWidth( frontlineTable )
{
	local highDist = 0
	for ( local side = 0; side < 2; side++ )
	{
		local nodeArray = frontlineTable.sideNodeArray[ side ]
		foreach ( baseNode in nodeArray )
		{
			foreach ( node in nodeArray )
			{
				local dist = Distance( baseNode.GetOrigin(), node.GetOrigin() )
				if ( dist > highDist )
					highDist = dist
			}
		}
	}

	printt( frontlineTable.name, frontlineTable, highDist )
	local width = ( highDist * 0.5 ) + 512
	return width	// half the width since all calculations are based on the center of the frontline
}

// Temporary - backup stuff incase a map doesn't have info_frontline ents
function CreateTempFrontline()
{
	printt( "************************************" )
	printt( "Map doesn't have info_frontline ents" )
	printt( "************************************" )

	local spawnpoints = SpawnPoints_GetPilotStart( TEAM_ANY )
	if ( GameRules.GetGameMode() == LAST_TITAN_STANDING || GameRules.GetGameMode() == WINGMAN_LAST_TITAN_STANDING )
		spawnpoints = SpawnPoints_GetTitanStart( TEAM_ANY )

	if ( spawnpoints.len() == 0 )
		return []

	local originArray = []
	local mapCenter = GetMapCenter( spawnpoints )
	local mapDir = GetMapDirection( mapCenter, spawnpoints )	//	vector points away from the IMC side
	local leftDir = Vector( -mapDir.y, mapDir.x, 0 )

	local flankDist = 1024
	leftDir *= flankDist

	originArray.append( mapCenter )
	originArray.append( mapCenter + leftDir )
	originArray.append( mapCenter - leftDir )

	local entArray = []
	foreach( origin in originArray )
	{
		local info_frontline = CreateEntity( "info_frontline" )
		info_frontline.kv.group = "tempgroups"	// doesn't work
		info_frontline.kv.TeamNum = 0
		info_frontline.SetOrigin( origin + ( mapDir * 512 ) )
		DispatchSpawn( info_frontline )
		entArray.append( info_frontline )
	}

	foreach( origin in originArray )
	{
		local info_frontline = CreateEntity( "info_frontline" )
		info_frontline.kv.group = "temp_group"	// doesn't work
		info_frontline.kv.TeamNum = 1
		info_frontline.SetOrigin( origin + ( mapDir * -512 ) )
		DispatchSpawn( info_frontline )
		entArray.append( info_frontline )
	}

	return entArray
}

//////////////////////////////////////////////////////////
function GetMapCenter( spawnpoints )
{
	local centerPos = Vector( 0, 0, 0 )
	foreach ( spawnpoint in spawnpoints )
		centerPos += spawnpoint.GetOrigin()
	centerPos *= ( 1.0 / spawnpoints.len() )

	return centerPos
}

//////////////////////////////////////////////////////////
function GetMapDirection( centerPos, startSpawnPoints )
{
	if ( startSpawnPoints.len() == 0 )
		return Vector( 1, 0, 0 )

	local imcCount = 0
	local militiaCount = 0
	local imcCenter = Vector( 0, 0, 0 )
	local militiaCenter = Vector( 0, 0, 0 )
	local dirToIMC = Vector( 1, 0, 0 )
	local dirFromMilitia = Vector( 1, 0, 0 )

	foreach ( startSpawn in startSpawnPoints )
	{
		if ( startSpawn.GetTeam() == TEAM_IMC )
		{
			imcCenter += startSpawn.GetOrigin()
			imcCount++
		}
		else if ( startSpawn.GetTeam() == TEAM_MILITIA )
		{
			militiaCenter += startSpawn.GetOrigin()
			militiaCount++
		}
	}

	if ( imcCount > 0 )
	{
		imcCenter *= 1.0 / imcCount.tofloat()
		dirToIMC = imcCenter - centerPos
		dirToIMC.Normalize()
	}

	if ( militiaCount > 0 )
	{
		militiaCenter *= 1.0 / militiaCount.tofloat()
		dirFromMilitia = centerPos - militiaCenter	// reverse of dirToIMC
		dirFromMilitia.Normalize()
	}

	local mapDir = ( dirFromMilitia + dirToIMC ) * 0.5
	return mapDir	//	vector points away from the IMC side
}


//////////////////////////////////////////////////////////
function SetFrontlineSides( frontline, winningTeam )
{
	local otherTeam

	switch (winningTeam)
	{
		case TEAM_IMC:
		{
			otherTeam = TEAM_MILITIA
			break
		}
		case TEAM_MILITIA:
		{
			otherTeam = TEAM_IMC
			break
		}
	}
	local center = frontline.frontlineCenter

	// combatDir is towards side 1, away from side 0
	local combatDir = file.currentFrontline.combatDir

	local playerArray = GetLivingPlayers()

	// for the start of the map when no players are avaliable
	if ( GetGameState() <= eGameState.Prematch || GetGameState() == eGameState.SwitchingSides || playerArray.len() == 0 )
		playerArray = GetEntArrayByClass_Expensive( "info_spawnpoint_human_start" )

	local teamCount = [ 0, 0 ]
	foreach ( player in playerArray )
	{
		if ( IsPlayer( player ) && player.GetDoomedState() )
			continue

		if ( IsPointInFrontofLine( player.GetOrigin(), center, combatDir ) )
		{
			if ( player.GetTeam() == winningTeam )
				teamCount[ 1 ]++
		}
		else
		{
			if ( player.GetTeam() == winningTeam )
				teamCount[ 0 ]++
		}

		if ( file.debug & DEBUG_FRONTLINE_SELECTED )
			DebugDrawText( player.GetOrigin(), ".xX " + player.GetTeam() + " Xx.", false, 10 )
	}

	if ( teamCount[ 1 ] > teamCount[ 0 ] )
	{
		file.frontlineTeamSide[ winningTeam ]	= 1
		file.frontlineTeamSide[ otherTeam ]		= 0
	}
	else
	{
		file.frontlineTeamSide[ otherTeam ]		= 1
		file.frontlineTeamSide[ winningTeam ]	= 0
	}

	if ( file.debug & DEBUG_FRONTLINE_SELECTED )
	{
		local vector = frontline.frontlineVector
		local combatDir = file.currentFrontline.combatDir	// towards side 1

		DebugDrawLine( center, center + vector * 1000, 0, 0, 255, true, 10 )
		DebugDrawLine( center, center + vector * -1000, 0, 0, 128, true, 10 )
		DebugDrawLine( center + Vector( 0,0,32 ), center + combatDir * 512, 255, 255, 255, true, 10 )
		DebugDrawLine( center + Vector( 0,0,32 ), center + Vector( 0,0,128), 255, 255, 255, true, 10 )
		DebugDrawText( center, frontline.name + " " + frontline.useCount, false, 10 )

		local teamStr = "MILITIA - " + teamCount[ 1 ] + " vs " + teamCount[ 0 ]
		if ( file.frontlineTeamSide[ TEAM_IMC ] == 1 )
			teamStr = "IMC - " + teamCount[ 1 ] + " vs " + teamCount[ 0 ]
		DebugDrawText( center + combatDir * 512, teamStr, false, 10 )
	}
}

//////////////////////////////////////////////////////////
function RateFrontLineNPCSpawnpoint( spawnpoint, team, edgeOrigin, combatDir )
{
	local frontlineRating = 0

	local testPoint = spawnpoint.GetOrigin()

	local infront = IsPointInFrontofLine( testPoint, edgeOrigin, combatDir )

	if ( !infront )
	{
		local distSqr = Distance2DSqr( testPoint, edgeOrigin )
		frontlineRating = GraphCapped( distSqr, FRONTLINE_MIN_DIST_SQR, FRONTLINE_MAX_DIST_SQR, 1.0, 0.0 )
	}
	else
	{
		frontlineRating = -100	// these are on the wrong side of the frontline so make them real bad to use
	}

	frontlineRating	*= 2.0

	spawnpoint.CalculateRating( TD_AI, team, frontlineRating, frontlineRating )

/*
	if ( file.debug & DEBUG_NPC_SPAWN )
	{
		// debug
		local textStr = format( ".xX%dXx.", spawnpoint.GetEntIndex() )
		if ( rating > -50 )
			textStr = format( "%d | %2.2f | %2.2f", spawnpoint.GetEntIndex(), frontlineRating, rating )

		DebugDrawText( testPoint + Vector(0,0,64), textStr, false, 10 )
	}
*/
}


//////////////////////////////////////////////////////////
function FrontlineDeathNPC( ent, damageInfo )
{
	FrontlineDeath( ent, damageInfo )
}

//////////////////////////////////////////////////////////
function FrontlineDeath( ent, damageInfo )
{
	if ( ent.IsTitan() && !ent.GetTitanSoul().GetBossPlayer() )
		return	// don't care about npc_titans that wasn't controlled by a player

	if ( ent.IsNPC() && !ent.IsTitan() )
	{
		// don't check if we recently moved the frontline
		local time = Time()
		if ( file.nextOverrunCheck > time )
			return

		file.nextOverrunCheck = Time() + 1
	}

	local team = ent.GetTeam()
	CheckFrontlineOverrun( team )
}

//////////////////////////////////////////////////////////
function GetFrontlineNPCKillsPerSec( team )
{
	// returns the number of dead npc in the last [KPS_TIMEFRAME] seconds
	local newArray = []
	foreach( timestamp in file.npcDeathPerTeam[ team ] )
	{
		if ( timestamp > Time() - KPS_TIMEFRAME )
			newArray.append( timestamp )
	}

	file.npcDeathPerTeam[ team ] = newArray

	return newArray.len() / KPS_TIMEFRAME.tofloat()
}

//////////////////////////////////////////////////////////
function GetFrontlinePlayerKillsPerSec( team )
{
	// returns the number of dead players in the last [PLAYER_KPS_TIMEFRAME] seconds
	local newArray = []
	foreach( timestamp in file.playerDeathPerTeam[ team ] )
	{
		if ( timestamp > Time() - PLAYER_KPS_TIMEFRAME )
			newArray.append( timestamp )
	}

	file.playerDeathPerTeam[ team ] = newArray

	return newArray.len() / PLAYER_KPS_TIMEFRAME.tofloat()
}

//////////////////////////////////////////////////////////
function ResetFrontlineKillsPerSecond()
{
	file.npcDeathPerTeam[ TEAM_IMC ] = []
	file.npcDeathPerTeam[ TEAM_MILITIA ] = []
	file.playerDeathPerTeam[ TEAM_IMC ] = []
	file.playerDeathPerTeam[ TEAM_MILITIA ] = []

}

//////////////////////////////////////////////////////////
function GetFrontlineGoal( index, team, spectre = false )
{
	local frontline = file.currentFrontline
	local side = file.frontlineTeamSide[ team ]
	local nodeArray = frontline.sideNodeArray[ side ]
	Assert( nodeArray.len() == 3 )

	local node = nodeArray[ index % 3 ]
	if ( spectre && "spectreNode" in node.s )
		node = node.s.spectreNode

	return node
}

//////////////////////////////////////////////////////////
function SquadAssaultFrontline( squad, squadIndex )
{
//	This was a version that created assault_assaultpoints so that I could tweek settings. Rather not use it.
	SquadAssaultFrontline_AssaultEnts( squad, squadIndex )
	//SquadAssaultFrontline_Old( squad )
}

//////////////////////////////////////////////////////////
function GetAdditionalNodesForNotEnoughCoverNodes( goalNodes, nearestNode, squadSize )
{
	// get enough nodes incase there are duplicates in neighborNodes and goalNodes
	local neighborNodes = GetNeighborNodes( nearestNode, squadSize + goalNodes.len(), HULL_HUMAN )
	foreach( i, node in neighborNodes )
	{
		if ( !( node in goalNodes ) )
		{
			goalNodes.append( node )
			if ( goalNodes.len() == squadSize )
				break
		}
	}
}
Globalize( GetAdditionalNodesForNotEnoughCoverNodes )

function GetAdditionalNodesForNotEnoughCoverNodesWithinHeight( goalNodes, nearestNode, squadSize, height, heightCheck )
{
	// get enough nodes incase there are duplicates in neighborNodes and goalNodes
	local neighborNodes = GetNeighborNodes( nearestNode, squadSize + goalNodes.len(), HULL_HUMAN )
	foreach( i, node in neighborNodes )
	{
		if ( !( node in goalNodes ) )
		{
			local pos = GetNodePos( node, HULL_HUMAN )
			if ( fabs( pos.z - height ) > heightCheck )
				continue

			goalNodes.append( node )
			if ( goalNodes.len() == squadSize )
				break
		}
	}
}
Globalize( GetAdditionalNodesForNotEnoughCoverNodesWithinHeight )

//////////////////////////////////////////////////////////
function SquadAssaultFrontline_AssaultEnts( squad, squadIndex )
{
	Assert( squadIndex != null )

	if ( !Flag( "FrontlineInitiated" ) )
		return

	if(!squad)	// 스쿼드가 없으면 스킵환다.
		return

	// Guys in squad can die at any time - it seems bad that this can be the case, squad should be clean earlier if at all
	ArrayRemoveInvalid( squad )

	local squadSize = squad.len()
	if ( squadSize == 0 )
		return

	local isSpectre = squad[0].IsSpectre()
	local team = squad[0].GetTeam()
	local goal = GetFrontlineGoal( squadIndex, team, isSpectre )
	Assert( goal != null )

	local frontline = file.currentFrontline
	local combatDir = GetTeamCombatDir( frontline, team )

	local nearestNode = GetNearestNodeToPos( goal.GetOrigin() )
	if ( nearestNode < 0 )
	{
		printl( "Error: No path nodes near droppod spawn point at " + goal.GetOrigin() )
		return
	}

	local goalNodes = GetNearbyCoverNodes( nearestNode, squad.len(), HULL_HUMAN, isSpectre, 400, combatDir.GetAngles().y, 90 )

	// Debug lines
	if ( GetBugReproNum() == 1234 )
	{
		local pos = GetNodePos( nearestNode, HULL_HUMAN )
		DebugDrawLine( pos, pos + combatDir * 512, 0, 255, 255, true, 30 )

		foreach( node in goalNodes )
			DebugDrawLine( GetNodePos( node, HULL_HUMAN ), GetNodePos( node, HULL_HUMAN ) + Vector( 0,0,128 ), 0, 255, 0, true, 30 )
	}

	// fill up rest with regular nodes
	if ( goalNodes.len() < squadSize )
	{
		GetAdditionalNodesForNotEnoughCoverNodes( goalNodes, nearestNode, squadSize )

		// Debug lines
		if ( GetBugReproNum() == 1234 )
		{
			foreach( node in goalNodes )
				DebugDrawLine( GetNodePos( node, HULL_HUMAN ), GetNodePos( node, HULL_HUMAN ) + Vector( 0,0,64 ), 255, 0, 0, true, 30 )
		}
	}


	foreach ( i, node in goalNodes )
	{
		local nodePos = GetNodePos( node, HULL_HUMAN )
		local npc = squad[ i ]

		Assert( "assaultPoint" in npc.s )
		SetFrontlineAssaultPointValues( npc.s.assaultPoint )
		npc.s.assaultPoint.SetOrigin( nodePos )

		if ( file.debug & DEBUG_ASSAULTPOINT )
		{
			//DebugDrawText( nodePos, "AP", false, 10 )
			thread DrawAssaultGoal( squad[ i ], nodePos )
		}

		squad[ i ].AssaultPointEnt( npc.s.assaultPoint )
		squad[ i ].StayPut( true )
	}
}

//////////////////////////////////////////////////////////
function SetFrontlineAssaultPointValues( point )
{
	point.kv.stopToFightEnemyRadius = 800
	point.kv.allowdiversionradius = 0
	point.kv.allowdiversion = 1
	point.kv.faceAssaultPointAngles = 0
	point.kv.assaulttolerance = 512
	point.kv.nevertimeout = 0
	point.kv.strict = 0
	point.kv.forcecrouch = 0
	point.kv.spawnflags = 0
	point.kv.clearoncontact = 1
	point.kv.assaulttimeout = RandomFloat( 4, 8 )
	point.kv.arrivaltolerance = 600
}

//////////////////////////////////////////////////////////
function SquadAssaultFrontline_Old( squad, squadIndex )
{
	Assert( squadIndex != null )

	if ( !Flag( "FrontlineInitiated" ) )
		return

	if ( squad.len() > 1 )
	{
		local team = squad[0].GetTeam()
		local goal = GetFrontlineGoal( squadIndex, team )
		Assert( goal != null )

		SquadAssault( squad, goal.GetOrigin() )
	}
}


//////////////////////////////////////////////////////////
function SquadAssault( squad, pos )
{
	local nearestNode = GetNearestNodeToPos( pos )
	if ( nearestNode < 0 )
	{
		printl( "Error: No path nodes near droppod spawn point at " + pos )
		return
	}

	// Guys in squad can die at any time
	ArrayRemoveInvalid( squad )

	local squadSize = squad.len()
	if ( squadSize == 0 )
		return

	local isSpectre = squad[0].IsSpectre()

	// need a direction passed in here
	local goalNodes = GetNearbyCoverNodes( nearestNode, squad.len(), HULL_HUMAN, isSpectre, 400, 0, 180 )

	// fill up rest with regular nodes
	if ( goalNodes.len() < squadSize )
		GetAdditionalNodesForNotEnoughCoverNodes( goalNodes, nearestNode, squadSize )

	foreach ( i, node in goalNodes )
	{
		local nodePos = GetNodePos( node, HULL_HUMAN )
		squad[ i ].AssaultPoint( nodePos )
		squad[ i ].StayPut( true )

		if ( file.debug & DEBUG_ASSAULTPOINT )
			thread DrawAssaultGoal( squad[ i ], nodePos )
	}
}





// debug functions
function DebugSendClientFrontline( player )
{
	if ( developer() == 0 )
		return

	if ( "currentFrontline" in file && file.currentFrontline != null )
	{
		local center = file.currentFrontline.frontlineCenter
		local dir = GetTeamCombatDir( file.currentFrontline, TEAM_IMC )
		Remote.CallFunction_Replay( player, "DebugSetFrontline", center.x, center.y, center.z, dir.x, dir.y );
	}
}

function DebugSendClientFrontlineAllPlayers()
{
	if ( developer() == 0 )
		return

	local center = file.currentFrontline.frontlineCenter
	local dir = GetTeamCombatDir( file.currentFrontline, TEAM_IMC )
	local playerArray = GetPlayerArray()
	foreach( player in playerArray )
		Remote.CallFunction_Replay( player, "DebugSetFrontline", center.x, center.y, center.z, dir.x, dir.y )
}

function DebugSquad()
{
	local npcArray = GetNPCArrayByClass( "npc_soldier" )
	foreach( npc in npcArray )
		thread DebugSquadThread( npc )
}

function DebugSquadThread( npc )
{
	if ( !IsAlive( npc ) )
		return

	npc.Signal( "EndDebugSquadIndex" )
	npc.EndSignal( "EndDebugSquadIndex" )

	while( IsAlive( npc ) )
	{
		DebugDrawText( npc.GetOrigin() + Vector(0,0,64), npc.kv.squadname, false, 0.5 )
		wait 0.5
	}
}

function DebugNextFrontline()
{
	file.currentFrontline.useCount++

	local useCount = file.currentFrontline.useCount
	local selectedFrontline

	foreach( frontline in file.frontlineGroupTable )
	{
		if ( frontline.useCount <= useCount )
		{
			useCount = frontline.useCount
			selectedFrontline = frontline
		}
	}

	file.currentFrontline = selectedFrontline
	SetFrontlineSides( file.currentFrontline, TEAM_IMC )

	// gather all squads and have them assault the new fronline
	for ( local squadIndex = 0; squadIndex < level.aiSquadCount; squadIndex++ )
	{
		local squadName = MakeSquadName( TEAM_IMC, squadIndex )
		local squadSize = GetNPCSquadSize( squadName )
		if ( squadSize )
		{
			local squad = GetNPCArrayBySquad( squadName )
			SquadAssaultFrontline( squad, squadIndex )
		}

		squadName = MakeSquadName( TEAM_MILITIA, squadIndex )
		squadSize = GetNPCSquadSize( squadName )
		if ( squadSize )
		{
			local squad = GetNPCArrayBySquad( squadName )
			SquadAssaultFrontline( squad, squadIndex )
		}
	}

	DebugSendClientFrontlineAllPlayers()
}

function DrawMapCenter()
{
	local ents = SpawnPoints_GetDropPodStart( TEAM_ANY )
	local mapCenter = GetMapCenter( ents )

	foreach ( ent in ents )
		DebugDrawLine( ent.GetOrigin(), mapCenter, 128, 128, 128, true, 10 )
	DebugDrawText( mapCenter, "MAP CENTER", false, 10 )
}

function DebugDrawFrontLineSpawn()
{
	if ( "drawFrontlineSpawn" in file )
		delete file.drawFrontlineSpawn
	else
		file.drawFrontlineSpawn <- true

	if ( !( "spawnpoints" in file ) )
	{
		file.spawnpoints <- GetEntArrayByClass_Expensive( "info_spawnpoint_human" )
		file.spawnpoints.extend( GetEntArrayByClass_Expensive( "info_spawnpoint_titan" ) )
	}
}

function DrawCurrentFrontline()
{
	thread DrawCurrentFrontline_thread()
}

function DrawCurrentFrontline_thread()
{
	if ( "drawCurrentFrontline" in file )
	{
		delete file.drawCurrentFrontline
		return
	}

	file.drawCurrentFrontline <- true
	while( "drawCurrentFrontline" in file )
	{
		if ( "drawFrontlineSpawn" in file )
		{
			DebugDrawFrontlineSpawnBox( file.currentFrontline, TEAM_IMC, { r=64, g=64, b=255 } )
			DebugDrawFrontlineSpawnBox( file.currentFrontline, TEAM_MILITIA, { r=96, g=255, b=96 } )
		}

		DrawFrontline( file.currentFrontline )
		wait 0.5
	}
}

function DebugDrawFrontlineSpawnBox( frontline, team, color )
{
	local spawnDir = GetTeamCombatDir( frontline, team ) * -1
	local offsetOrigin = frontline.frontlineCenter + spawnDir * FRONTLINE_PLAYER_SPAWN_OFFSET
	local midRange = FRONTLINE_PLAYER_SPAWN_DIST
	local maxRange = FRONTLINE_PLAYER_SPAWN_DIST * 3

	local left = offsetOrigin + frontline.frontlineVector * frontline.width
	local right = offsetOrigin + frontline.frontlineVector * -frontline.width
	local midOffset = spawnDir * midRange
	local maxOffset = spawnDir * maxRange

	DebugDrawLine( left, right, color.r, color.g, color.b, true, 0.5 )
	DebugDrawLine( left, left + maxOffset, color.r, color.g, color.b, true, 0.5 )
	DebugDrawLine( right, right + maxOffset, color.r, color.g, color.b, true, 0.5 )
	DebugDrawLine( left + maxOffset, right + maxOffset, color.r, color.g, color.b, true, 0.5 )
	DebugDrawLine( left + midOffset, right + midOffset, 255, 96, 96, true, 0.5 )
	DebugDrawText( offsetOrigin + midOffset, "Optimal distance", false, 0.5 )

	DebugDrawSpawnpoints( frontline, offsetOrigin, spawnDir, maxRange, color )
}

function DebugDrawSpawnpoints( frontline, origin, spawnDir, length, color )
{
	local badColor = { r = 96, g = 0, b = 0 }
	local drawColor

	foreach( spawnpoint in file.spawnpoints )
	{
		local spawnOrigin = spawnpoint.GetOrigin()
		local spawnAngles = spawnpoint.GetAngles()

		local spawnVector = spawnOrigin - origin
		local forwardDist = spawnDir.Dot( spawnVector )
		local sideDist = fabs( frontline.frontlineVector.Dot( spawnVector ) )

		if ( forwardDist > 0 && forwardDist < length &&  sideDist < frontline.width )
		{
			local vector = spawnOrigin - frontline.frontlineCenter
			local facing = spawnpoint.GetForwardVector()
			if ( vector.Dot( facing ) > 0 )
				drawColor = badColor
			else
				drawColor = color

			if ( spawnpoint.GetClassname() == "info_spawnpoint_human" )
				DrawLineBox( spawnOrigin, spawnAngles, Vector( 16, 16, 72 ), drawColor.r, drawColor.g, drawColor.b, 0.5 )
			else
				DrawLineBox( spawnOrigin, spawnAngles, Vector( 64, 64, 256 ), drawColor.r, drawColor.g, drawColor.b, 0.5 )
		}
	}
}

function DrawLineBox( origin, angles, size, r, g, b, time )
{
	local fVector = angles.AnglesToForward()
	local rVector = angles.AnglesToRight()

	local lfr  = origin + ( fVector * size.x ) + ( rVector * size.y )
	local lfl  = origin + ( fVector * size.x ) + ( rVector * -size.y )
	local lrr  = origin + ( fVector * -size.x ) + ( rVector * size.y )
	local lrl  = origin + ( fVector * -size.x ) + ( rVector * -size.y )

	local ufr  = lfr + Vector( 0, 0, size.z )
	local ufl  = lfl + Vector( 0, 0, size.z )
	local urr  = lrr + Vector( 0, 0, size.z )
	local url  = lrl + Vector( 0, 0, size.z )

	local dirStart = origin + Vector( 0, 0, size.z * 0.5 )
	local dirEnd = origin + fVector * ( size.x * 2 ) + Vector( 0, 0, size.z * 0.5 )

	DebugDrawLine( dirStart, dirEnd  , r, g, b, true, time )

	DebugDrawLine( lfr, lfl, r, g, b, true, time )
	DebugDrawLine( lfl, lrl, r, g, b, true, time )
	DebugDrawLine( lrl, lrr, r, g, b, true, time )
	DebugDrawLine( lrr, lfr, r, g, b, true, time )

	DebugDrawLine( lfr, ufr, r, g, b, true, time )
	DebugDrawLine( lfl, ufl, r, g, b, true, time )
	DebugDrawLine( lrl, url, r, g, b, true, time )
	DebugDrawLine( lrr, urr, r, g, b, true, time )

	DebugDrawLine( ufr, ufl, r, g, b, true, time )
	DebugDrawLine( ufl, url, r, g, b, true, time )
	DebugDrawLine( url, urr, r, g, b, true, time )
	DebugDrawLine( urr, ufr, r, g, b, true, time )
}

function DebugDrawFrontLine()
{
	thread DebugDrawFrontLine_thread()
}

function DebugDrawFrontLine_thread()
{
	if ( "drawFrontline" in file )
	{
		delete file.drawFrontline
		return
	}

	file.drawFrontline <- true
	while( "drawFrontline" in file )
	{
		foreach( frontline in file.frontlineGroupTable )
			DrawFrontline( frontline )
		wait 0.5
	}
}

function DrawFrontline( frontline )
{
	if ( !Flag( "FrontlineInitiated" ) )
		return

	local player = GetEntByIndex(1)
	if ( !player )
		return

	local team = player.GetTeam()
	local center = frontline.frontlineCenter
	local vector = frontline.frontlineVector
	local combatDir = GetTeamCombatDir( frontline, team )
	local width = frontline.width
	local left = center + vector * width
	local right = center + vector * -width

	DebugDrawLine( center, left, 255, 64, 0, true, 0.5 )
	DebugDrawLine( center, right, 255, 0, 64, true, 0.5 )

	local nameStr = frontline.name + " Used Count: " + frontline.useCount.tostring()
	if ( frontline == file.currentFrontline )
	{
		nameStr += " [CURRENT]"

		DebugDrawLine( center + Vector( 0,0,32 ), center + combatDir * 512, 255, 0, 0, true, 0.5 )
		DebugDrawLine( center + Vector( 0,0,32 ), center + Vector( 0,0,128), 255, 0, 0, true, 0.5 )

		if ( !( "drawFrontlineSpawn" in file ) )
		{
			local teamStr = "MILITIA"
			if ( team == TEAM_IMC )
				teamStr = "IMC"
			DebugDrawText( center + combatDir * 512, teamStr + " Combat Direction", false, 0.5 )
		}
	}
	else
	{
		DebugDrawLine( center + Vector( 0,0,32 ), center + combatDir * 256, 192, 0, 0, true, 0.5 )
		DebugDrawLine( center + Vector( 0,0,32 ), center + combatDir * -256, 192, 0, 0, true, 0.5 )
	}

	DebugDrawText( center, nameStr, false, 0.5 )

	if ( !( "drawFrontlineSpawn" in file )  )
	{
		local frontlineEnts = clone frontline.sideNodeArray[0]
		frontlineEnts.extend( frontline.sideNodeArray[1] )
		foreach( ent in frontlineEnts )
		{
			DebugDrawLine( center, ent.GetOrigin(), 192, 192, 192, true, 0.5 )
			DebugDrawText( ent.GetOrigin(), ent.GetTeam().tostring(), false, 0.5 )
		}
	}
}

RegisterSignal( "DrawAssaultGoal" )
function DrawAssaultGoal( npc, goal )
{
	npc.Signal( "DrawAssaultGoal" )
	npc.EndSignal( "DrawAssaultGoal" )

	while( IsAlive( npc ) )
	{
		DebugDrawLine( npc.GetOrigin(), goal, 128, 128, 128, true, 0.5 )
		wait 0.5
	}
}


function MoveBot( team )
{
	local player = GetEntByIndex( 1 )
	local eyePos = player.EyePosition()
	local vector = player.GetViewVector()

	local bots = GetLivingPlayers( team )
	local trace = TraceLineSimple( eyePos, eyePos + vector * 10000, player )
	local ground = eyePos + vector * ( 10000 * trace )

	local startIndex = file.botIndex[ team ] % bots.len()

	for( local i = startIndex; i < bots.len(); i++ )
	{
		file.botIndex[ team ]++
		if ( bots[ i ].IsBot() )
		{
			bots[ i ].SetOrigin( ground + Vector( 0,0,64 ) )
			break
		}
	}
}




function EntitiesDidLoad()
{
	switch( GameRules.GetGameMode() )
	{
		case CAPTURE_POINT:
			level.AssaultFunc = AssaultHP
			break

		default:
			level.AssaultFunc = AssaultTDM
			break
	}
}


const SQUADSIZE = 4
function ScriptedSquadAssault( squad, index )
{
	Assert( index >= 0 && index <= 2 )
	Assert( squad.len() <= SQUADSIZE, "Squad " + index + " is too big: " + squad.len() )
	level.AssaultFunc( squad, index )
}


function AssaultHP( guys, index )
{
	if ( !guys.len() )
		return

	//give everyone proper squad name
	local team 			= guys[ 0 ].GetTeam()
	local startPoint 	= null

	// find a rough start location for the team
	local spawnpoints = GetEntArrayByClass_Expensive( "info_spawnpoint_titan_start" )
	local startOrigin = Vector( 0, 0, 0 )
	local count = 0
	for( local i = 0; i < spawnpoints.len(); i++ )
	{
		if ( spawnpoints[ i ].GetTeam() == team )
		{
			startOrigin += spawnpoints[ i ].GetOrigin()
			count++
		}
	}

	startOrigin = startOrigin * ( 1.0 / count.tofloat() )

	local hardpoints 	= ArrayFarthest( GetHardpoints(), startOrigin )
	local hpIndex 		= GetHardpointIndex( hardpoints[ index ] )
	local squadName 	= MakeSquadName( team, hpIndex )

	foreach ( guy in guys )
	{
		if ( IsValid( guy ) )
			SetSquad( guy, squadName )
	}

	//is our squad filled up yet?
	local squad = GetNPCArrayBySquad( squadName )

	if ( squad.len() > SQUADSIZE )
		return

	//ok we got everyone - lets assault some shit
	thread SquadCapturePointThink( squadName, hardpoints[ index ], team )
}


function AssaultTDM( guys, index )
{
	if ( !guys.len() )
		return

	//give everyone proper squad name
	local team 		= guys[ 0 ].GetTeam()

	local squadName = MakeSquadName( team, index )

	foreach( guy in guys )
		SetSquad( guy, squadName )

	//is our squad filled up yet?
	local squad = GetNPCArrayBySquad( squadName )

	if ( squad.len() > SQUADSIZE )
		return

	//ok we got everyone - lets assault some shit
	thread SquadAssaultFrontline( squad, index )
}
