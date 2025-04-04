//TODO: CoreEffect doesn't transfer properly between titan and pilot!

enum oreTypes
{
	RANDOM,
	ROOF,
	TITAN,
	THROWN,
	ORE_DUMP_SPOT,
}

const randomOreSpawned = 20
const roofOreSpawned = 15
const titanOreSpawned = 1 //TODO: Can't actually have more than 1 right now because no way to mark that a spawnpoint is used!
const oreEffectThreshold = 5
const ORE_DISTANCE_SQUARED_FROM_DUMP_SPOT =  6250000 //UPDATE IF CHANGED: 6250000 = 2500 * 2500
const ORE_ROOF_DISTANCE_SQUARED_FROM_DUMP_SPOT =  2250000 //UPDATE IF CHANGED: 2250000 = 1500 * 1500
const ORE_DISTANCE_SQUARED_FROM_PLAYER = 75625 //UPDATE IF CHANGED: 75625 = 275 * 275
const ORE_BUILD_TIME = 5
const ORE_SPAWN_DELAY = 25


function main()
{
	level.spawnRatingFunc_Pilot = RateFrontLinePlayerSpawnpoint
	level.spawnRatingFunc_Generic = RateFrontLinePlayerSpawnpoint
	PrecacheModel( "models/rocks/rock_01_sandstone.mdl" )

	file.totalOre <- {}
	file.totalOre[ oreTypes.RANDOM ] <- 0
	file.totalOre[ oreTypes.ROOF ] <- 0
	file.totalOre[ oreTypes.TITAN] <- 0
	file.totalOre[ oreTypes.THROWN] <- 0
	file.totalOre[ oreTypes.ORE_DUMP_SPOT ] <- 0

	file.oreDumpSpots <- {}
	file.oreDumpSpots[ TEAM_IMC ] <- null
	file.oreDumpSpots[ TEAM_MILITIA ] <- null

	level.nodesInUse <- {}
	level.nodeInfo <- {}
	level.spectreJumpTraverseNodesInUse <- []

	if ( "CodeCallback_OnTouchHealthKit" in getroottable() )
		delete getroottable().CodeCallback_OnTouchHealthKit

	Globalize( CodeCallback_OnTouchHealthKit ) //Need to put it here after we delete the root table one, otherwise due to scoping rules the game complains.

	AddCallback_OnClientConnected( GameMode_Scavenger_PlayerConnected )

	AddDeathCallback( "player", SpawnThrownOreNugget )

	AddCallback_OnTitanBecomesPilot( Scavenger_TitanBecomesPilot )

	AddCallback_GameStateEnter( eGameState.WinnerDetermined, Scavenger_WinnerDeterminedEnter )

	AddDeathCallback( "npc_titan", SpawnThrownOreNugget )

}

function EntitiesDidLoad()
{
	//printl("running EntitiesDidLoad() in team_deathmatch.nut" )
	SetupAssaultPointKeyValues()

	InitOreDumpSpots()

	//Init for using nodes
	local nodeCount = GetNodeCount()
	file.nodeOrder <- array( nodeCount )

	for ( local i = 0; i < nodeCount; ++i )
	{
		file.nodeOrder[ i ] = i
	}

	level.spectreJumpTraverseNodes <- []

	local traverseNodes = GetEntArrayByClass_Expensive( "traverse" ) //Slow... but maybe ok to do this at start?
	foreach( traverse in traverseNodes )
	{
		if ( IsValidSpectreSuperJumpTraverseNode( traverse ) )
			level.spectreJumpTraverseNodes.append( traverse )
	}

	level.titanSpawnPointNodes <- []
	local titanSpawnPoints = GetEntArrayByClass_Expensive( "info_spawnpoint_titan" ) //Slow... but maybe ok to do this at start?
	foreach( titanSpawnPoint in titanSpawnPoints )
	{
		if ( IsValidTitanSpawnPointNode( titanSpawnPoint ) )
			level.titanSpawnPointNodes.append( titanSpawnPoint )
	}

	//monitor population and respawns
	thread SetupTeamDeathmatchNPCs()
	thread SpawnStartOres()
	/*printt( "Finish start ore spawn, printing nodesInUse" )
	PrintTable( level.nodesInUse )*/

	thread OreCreator()
}

function IsValidSpectreSuperJumpTraverseNode( traverseNode )
{
	//if ( level.isTestmap )
	//	return true

	local traverseType = traverseNode.kv.traverseType.tointeger() //Is string instead of integer at first
	/*printt( "This is traverseType: " + traverseType )
	printt( "Typeof traverseType: " + typeof traverseType )*/
	if ( traverseType == 8 || traverseType == 9 || traverseType == 10 ) //8: Jump Up/Down 160, 9: Jump Up/Down 320, 10: Jump Up/Down 512
	{
		return !NodeNearOreDumpSpot( traverseNode.GetOrigin(), ORE_ROOF_DISTANCE_SQUARED_FROM_DUMP_SPOT )

	}

	return false
}

function IsValidTitanSpawnPointNode( titanSpawnPoint )
{

	//if ( level.isTestmap )
	//	return true

	return !NodeNearOreDumpSpot( titanSpawnPoint.GetOrigin(), ORE_ROOF_DISTANCE_SQUARED_FROM_DUMP_SPOT )

}

function InitOreDumpSpots()
{
	local imcFlag = GetFlagSpawnPoint( TEAM_IMC )
	local militiaFlag = GetFlagSpawnPoint( TEAM_MILITIA )

	foreach ( spawnpoint in level.allSpawnpoints )
	{
		if ( !IsValid( spawnpoint ) )
			continue

		local distToIMC = Distance( imcFlag.GetOrigin(), spawnpoint.GetOrigin() )
		local distToMilitia = Distance( militiaFlag.GetOrigin(), spawnpoint.GetOrigin() )

		local totalDist = (imcFlag.GetOrigin() - militiaFlag.GetOrigin()).Length()

		if ( distToMilitia > distToIMC )
			spawnpoint.SetTeam( TEAM_IMC )
		else if ( distToIMC > distToMilitia )
			spawnpoint.SetTeam( TEAM_MILITIA )
		else
			spawnpoint.SetTeam( TEAM_UNASSIGNED )
	}

	CreateOreDumpSpot( imcFlag.GetOrigin(), TEAM_IMC )
	CreateOreDumpSpot( militiaFlag.GetOrigin(), TEAM_MILITIA )
}

function CreateOreDumpSpot( origin, team )
{
	local model = CTF_FLAG_BASE_MODEL

	local oreDumpSpot = CreateEntity( "item_healthcore" )
	oreDumpSpot.SetOrigin( origin )
	oreDumpSpot.SetTeam( team )
	oreDumpSpot.MarkAsNonMovingAttachment()
	DispatchSpawn( oreDumpSpot, true )

	oreDumpSpot.s.oreType <- oreTypes.ORE_DUMP_SPOT

	oreDumpSpot.SetModel( model )
	oreDumpSpot.StopPhysics()

	oreDumpSpot.Minimap_SetFriendlyMaterial( "vgui/HUD/ctf_flag_friendly_minimap" )
	oreDumpSpot.Minimap_SetEnemyMaterial( "vgui/HUD/ctf_flag_enemy_minimap" )
	oreDumpSpot.Minimap_SetAlignUpright( true )
	oreDumpSpot.Minimap_SetObjectScale( 0.15 )
	oreDumpSpot.Minimap_SetClampToEdge( true )
	oreDumpSpot.Minimap_SetZOrder( 100 )
	oreDumpSpot.Minimap_AlwaysShow( TEAM_IMC, null )
	oreDumpSpot.Minimap_AlwaysShow( TEAM_MILITIA, null )

	file.oreDumpSpots[ team ] = oreDumpSpot

}

function GetFlagSpawnPoint( team ) //Taken from CTF script file...
{
	local flagSpawns = GetEntArrayByClass_Expensive( "info_spawnpoint_flag" )

	if ( flagSpawns.len() )
	{
		foreach ( spawnPoint in flagSpawns )
		{
			if ( spawnPoint.GetTeam() != team )
				continue

			return spawnPoint
		}
	}

	local spawnpoints = GetEntArrayByClass_Expensive( "info_spawnpoint_titan_start" )
	Assert( spawnpoints.len(), "Map has no valid flag spawns: if this is a shipping map bug this to the designer" )

	FilterSpawnpointsByTeam( spawnpoints, team ) // inline array modify BS...

	local randomVal = RandomInt( spawnpoints.len() - 1 )
	return spawnpoints[randomVal]
}


function SpawnStartOres()
{
	//wait 5.0
	PrintFunc()
	local nodes = GetNodeCount()

	local totalRandomOre = randomOreSpawned - file.totalOre[ oreTypes.RANDOM ]
	local totalRoofOre = roofOreSpawned - file.totalOre[ oreTypes.ROOF ]
	local totalTitanOre = titanOreSpawned - file.totalOre[ oreTypes.TITAN ]

	printt( "TotalRandomOre: " + totalRandomOre + ", totalRoofOre: " + totalRoofOre  + ", totalTitanOre: " + totalTitanOre )

	if ( totalRandomOre > 0 ) //TODO: Functionize this properly plz so we don't copy paste 3 blocks
	{
		//printt( "Trying to create random ore" )
		ArrayRandomize( file.nodeOrder )
		for ( local i = 0; i < file.nodeOrder.len(); i++ ) //Makes the minimum of totalNodeCount or totalRandomOre(150), random ores
		{

			if ( TrySpawnOreOnNode( file.nodeOrder[ i ], oreTypes.RANDOM, level.scavengerSmallRocks ) )
			{
				totalRandomOre--  //Doesn't strictly count down to 0?

				if ( totalRandomOre <= 0 )
					break
			}

		}
	}

	if ( totalRoofOre > 0 ) //TODO: Functionize this properly plz so we don't copy paste 3 blocks
	{
		//printt( "Trying to create roof ore" )
		ArrayRandomize( level.spectreJumpTraverseNodes )
		for ( local i = 0; i < level.spectreJumpTraverseNodes.len(); i++ ) //Makes the minimum of totalNodeCount or totalRoofOre (12.5), roof ores
		{
			if ( TrySpawnOreOnSpectreTraverseNode( level.spectreJumpTraverseNodes[ i ], level.scavengerSmallRocks ) )
			{
				totalRoofOre--  //Doesn't strictly count down to 0?

				if ( totalRoofOre <= 0 )
					break
			}

		}
	}

	if ( totalTitanOre > 0 ) //TODO: Functionize this properly plz so we don't copy paste 3 blocks
	{
		//printt( "Trying to create titan ore" )
		ArrayRandomize( level.titanSpawnPointNodes )
		for ( local i = 0; i < level.titanSpawnPointNodes.len(); i++ ) //Makes the minimum of totalNodeCount or totalRoofOre (47.5), roof ores
		{

			if ( TrySpawnTitanOreOnTitanSpawnpointNode( level.titanSpawnPointNodes[ i ],  level.scavengerLargeRocks ) )
			{
				totalTitanOre--

				if ( totalTitanOre <= 0 )
					break
			}
		}
	}

	PrintOreInfo()

	//printt( level.nodesInUse.len() )


}
Globalize( SpawnStartOres )

function PrintOreInfo()
{
	local randomCount = file.totalOre[ oreTypes.RANDOM ]
	local roofCount = file.totalOre[ oreTypes.ROOF ]
	local titanCount = file.totalOre[ oreTypes.TITAN ]
	local thrownCount = file.totalOre[ oreTypes.THROWN ]

	printt( "RandomCount: " + randomCount + ", roofCount: " + roofCount + ", titanCount: " + titanCount + ", thrown: " +  thrownCount )
	printt( "Total oreCount: " +  ( randomCount +  roofCount + titanCount + thrownCount ) )

}
Globalize( PrintOreInfo )

function TrySpawnOreOnNode( nodeIndex, oreType, oreModels )
{
	if ( nodeIndex in level.nodesInUse ) //Not true at first
			return false

	local nodePos = GetNodePos( nodeIndex, 0 )

	if ( NodeNearPlayer( nodePos ) )
		return false

	if ( NodeNearOreDumpSpot( nodePos, ORE_DISTANCE_SQUARED_FROM_DUMP_SPOT ) )
		return false

	SpawnOreNugget( nodeIndex, nodePos, oreModels, oreType )

	return true

}

function TrySpawnOreOnSpectreTraverseNode( node, oreModels )
{
	/*if ( node.GetEntIndex() in level.spectreJumpTraverseNodesInUse ) //Not true at first
			return false*/

	local nodePos = node.GetOrigin()

	if ( NodeNearPlayer( nodePos ) )
		return false

	//Don't need to check for oredumpspot again because we did it when generating the initial list
	/*if ( NodeNearOreDumpSpot( nodePos, ORE_ROOF_DISTANCE_SQUARED_FROM_DUMP_SPOT ) )
		return false*/

	SpawnSpectreJumpTraverseOreNugget( node, oreModels )

	return true

	//TODO make these not spawn on top of each other!
	//level.spectreJumpTraverseNodesInUse //INCOMPLETE

	/*if ( traceMask )
	{
		local trace = TraceLine( nodePos, nodePos + Vector(0, 0, 3000 ), null, traceMask, TRACE_COLLISION_GROUP_PLAYER )
		if ( trace.fraction < 1.0 ) //TODO: Look at this more? Figure out what 1.0 means again
			return false
	}*/
}

function TrySpawnTitanOreOnTitanSpawnpointNode( node, oreModels )
{
	local nodePos = node.GetOrigin()

	if ( NodeNearPlayer( nodePos ) )
		return false

	//Don't need to check for oredumpspot again because we did it when generating the initial list
	/*if ( NodeNearOreDumpSpot( nodePos, ORE_ROOF_DISTANCE_SQUARED_FROM_DUMP_SPOT ) )
		return false*/

	SpawnTitanSpawnpointOreNugget( node, oreModels )

	return true


}

function NodeNearPlayer( nodePos ) //Todo: Fill out this function
{
	//if ( level.isTestmap )
	//	return false

	foreach( player in GetPlayerArray() )
	{
		if ( DistanceSqr( nodePos, player.GetOrigin() ) < ORE_DISTANCE_SQUARED_FROM_PLAYER )
		{
			//printt( "Rejected nodePos: " + nodePos + " because too near to player: " + player.GetOrigin() )
			return true
		}
	}

	return false
}

function NodeNearOreDumpSpot( nodePos, distanceThreshold )
{
	//if ( level.isTestmap )
	//	return false

	foreach( team, oreDumpSpot in file.oreDumpSpots )
	{
		if ( DistanceSqr( nodePos, oreDumpSpot.GetOrigin() ) < distanceThreshold )
		{
			//printt( "Rejected nodePos: " + nodePos + " because too near to oreDumpSpot: " + oreDumpSpot.GetOrigin() )
			return true
		}
	}

	return false
}

function DrawNodePos( nodePos )
{
	wait 1.0
	//DrawArrow( nodePos, Vector(0,0,0), 60 )
	DebugDrawLine( nodePos, nodePos + Vector(0,0,32), 255, 125, 0, false, 60 )
}

function SpawnOreNugget( nodeID, nodePos, models, oreType )
{
	local model = Random( models )

	local oreNugget = CreateEntity( "item_healthcore" )
	oreNugget.kv.rendercolor = "255 120 90 255"

	oreNugget.SetOrigin( nodePos )

	local angles = Vector( 0, RandomInt( 360 ), 0 )
	oreNugget.SetAngles( angles )
//	oreNugget.SetTeam( team )
	oreNugget.MarkAsNonMovingAttachment()
	DispatchSpawn( oreNugget, true )

	oreNugget.SetModel( model )

	level.nodesInUse[ nodeID ] <- true
	//printt( "ore: created with id: " + nodeID )
	oreNugget.s.oreType <- oreType
	oreNugget.s.nodeID <- nodeID
	file.totalOre[ oreType ]++

	oreNugget.StopPhysics()

	/*if ( GamePlaying() )
	{
		printt( "playing spawn sound" )
		EmitSoundOnEntity( oreNugget, "Menu_BurnCard_InspectMultipleCards" )

	}*/

	//Debug info:
	//level.nodeInfo[ nodeID ] <- oreNugget

	DisplayOreNuggetOnMinimap( oreNugget )
}

function SpawnSpectreJumpTraverseOreNugget( traverseNode, models )
{
	local model = Random( models )

	local oreNugget = CreateEntity( "item_healthcore" )
	//oreNugget.kv.model = model //TODO: Need to do this AND setModel?
	oreNugget.kv.rendercolor = "255 120 90 255" //orange

	oreNugget.SetOrigin( traverseNode.GetOrigin() )

	local angles = Vector( 0, RandomInt( 360 ), 0 )
	oreNugget.SetAngles( angles )
//	oreNugget.SetTeam( team )
	oreNugget.MarkAsNonMovingAttachment()
	DispatchSpawn( oreNugget, true )

	oreNugget.SetModel( model )

	file.totalOre[ oreTypes.ROOF ]++
	oreNugget.StopPhysics()

	oreNugget.s.oreType <- oreTypes.ROOF
	//local traverseNodeEntIndex = traverseNode.GetEntIndex()
	//oreNugget.s.nodeEntIndex <- traverseNodeEntIndex
	//level.spectreJumpTraverseNodesInUse[ traverseNodeEntIndex ] <- true

	DisplayOreNuggetOnMinimap( oreNugget )
}

function SpawnTitanSpawnpointOreNugget( node, models )
{
	local model = Random( models )

	local oreNugget = CreateEntity( "item_healthcore" )
	//oreNugget.kv.model = model //TODO: Need to do this AND setModel?
	 oreNugget.kv.rendercolor = "120 90 255 255" //purple

	oreNugget.SetOrigin( node.GetOrigin() )

	local angles = Vector( 0, RandomInt( 360 ), 0 )
	oreNugget.SetAngles( angles )
	oreNugget.MarkAsNonMovingAttachment()
	DispatchSpawn( oreNugget, true )

	oreNugget.SetModel( model )

	file.totalOre[ oreTypes.TITAN ]++
	oreNugget.StopPhysics()

	oreNugget.s.oreType <- oreTypes.TITAN
	//local traverseNodeEntIndex = traverseNode.GetEntIndex()
	//oreNugget.s.nodeEntIndex <- traverseNodeEntIndex
	//level.spectreJumpTraverseNodesInUse[ traverseNodeEntIndex ] <- true

	thread DisplayMegaOreNuggetOnMinimap( oreNugget )

}

function SpawnThrownOreNugget( deadEntity, damageInfo ) //TODO: Make this worth correctly with Titan Executions
{
	local collectedOreBeforeDeath = 0

	if ( deadEntity.IsPlayer() ) //Might not need this check anymore if we only make core spawn when players die
	{
		collectedOreBeforeDeath = deadEntity.GetDefenseScore()
		deadEntity.SetDefenseScore(0)

		if ( IsValid( deadEntity.s.collectedOreEffect ) )
			deadEntity.s.collectedOreEffect.Kill()

		deadEntity.Minimap_DisplayDefault(GetOtherTeam(deadEntity), null ) //Take away always being on map once dead
	}

	if (  IsSuicide( damageInfo.GetAttacker(), deadEntity, damageInfo.GetDamageSourceIdentifier() ) )
		return

	local origin = deadEntity.GetOrigin()

	local totalThrownOreGenerated = min( collectedOreBeforeDeath, 20 )

	totalThrownOreGenerated = max(1, totalThrownOreGenerated )

	printt( "Trying to generate " + totalThrownOreGenerated + " thrown Ore" )

	local angleStep = 360 / totalThrownOreGenerated

	for ( local i = 0; i < totalThrownOreGenerated; ++i )
	{
		//local model = Random( models )
		local model = "models/rocks/rock_01_sandstone.mdl"

		local oreNugget = CreateEntity( "item_healthcore" )
		oreNugget.kv.rendercolor = "255 120 90 255"

		oreNugget.SetOrigin( origin )

		local angleOrientation = Vector( 0, RandomInt( 360 ), 0 )
		oreNugget.SetAngles( angleOrientation )
	//	oreNugget.SetTeam( team )
		oreNugget.MarkAsNonMovingAttachment()
		DispatchSpawn( oreNugget, true )

		oreNugget.SetModel( model )
		oreNugget.s.oreType <- oreTypes.THROWN
		oreNugget.SetTeam( deadEntity.GetTeam() )
		file.totalOre[ oreTypes.THROWN ]++

		local angleThrown = Vector( 0, angleStep * i, 0 )
		oreNugget.SetVelocity( ( angleThrown.AnglesToForward() + Vector( 0,0,1.25 ) ) * 400  )
		DisplayOreNuggetOnMinimap( oreNugget )
	}

	//EmitSoundOnEntity( deadEntity, "ui_ingame_burncardearned" ) //TODO: need sounds



}

Globalize( SpawnThrownOreNugget )

function DisplayOreNuggetOnMinimap( oreNugget, oreNuggetMaterial = "vgui/HUD/minimap_goal_friendly"  )
{
	oreNugget.Minimap_SetDefaultMaterial( oreNuggetMaterial)
	oreNugget.Minimap_SetAlignUpright( true )
	oreNugget.Minimap_SetObjectScale( 0.08 )
	oreNugget.Minimap_SetClampToEdge( false )
	oreNugget.Minimap_SetZOrder( 100 )
	oreNugget.Minimap_AlwaysShow( TEAM_IMC, null )
	oreNugget.Minimap_AlwaysShow( TEAM_MILITIA, null )
	oreNugget.Minimap_SetFriendlyHeightArrow( true )
	oreNugget.Minimap_SetEnemyHeightArrow( true )

}

function DisplayMegaOreNuggetOnMinimap( oreNugget, oreNuggetMaterial = "vgui/HUD/minimap_goal_enemy" )
{
	oreNugget.Minimap_SetDefaultMaterial( oreNuggetMaterial)
	oreNugget.Minimap_SetAlignUpright( true )
	oreNugget.Minimap_SetObjectScale( 0.08 )
	oreNugget.Minimap_SetClampToEdge( false )
	oreNugget.Minimap_SetZOrder( 100 )
	oreNugget.Minimap_AlwaysShow( TEAM_IMC, null )
	oreNugget.Minimap_AlwaysShow( TEAM_MILITIA, null )
	oreNugget.Minimap_SetFriendlyHeightArrow( true )
	oreNugget.Minimap_SetEnemyHeightArrow( true )

	oreNugget.EndSignal( "OnDestroy" )

	while ( true )
	{
		EmitSoundOnEntity( oreNugget, "TEMP_Scavenger_Titan_Ore_Ping" )

		local pingCount = 5

		while( pingCount )
		{
			Minimap_CreatePingForTeam( TEAM_IMC, oreNugget.GetOrigin(), oreNuggetMaterial, 0.5 )
			Minimap_CreatePingForTeam( TEAM_MILITIA, oreNugget.GetOrigin(), oreNuggetMaterial, 0.5 )
			--pingCount
			wait 0.4
		}

		wait 7.0
	}


}

function CodeCallback_OnTouchHealthKit( player, oreNugget )
{
	if ( !GamePlaying()  )
		return false

	if ( oreNugget.s.oreType == oreTypes.ORE_DUMP_SPOT )
	{
			//printt( "OreDumpSpot touched!" )

		if ( oreNugget.GetTeam() == player.GetTeam() )
		{

			local collectedOre = player.GetDefenseScore()
			if ( collectedOre > 0 )
			{
				//printt( "Dumping collected Ore for team: " + player.GetTeam() )
				EmitSoundOnEntityOnlyToPlayer( player, player, "Menu_GameSummary_LevelUp" )
				GameScore.AddTeamScore( player.GetTeam(), collectedOre )

				for ( local i = 0; i < collectedOre; ++ i ) //Make
					AddPlayerScore( player, "DepositOre" )

				player.SetAssaultScore( player.GetAssaultScore() + collectedOre )
				Remote.CallFunction_Replay( player, "SCB_DeliveredOre", collectedOre )
			}

			player.Minimap_DisplayDefault(GetOtherTeam(player), null ) //Take away always being on map once ore deposited

			player.SetDefenseScore( 0 )

			if ( IsValid( player.s.collectedOreEffect ) )
				player.s.collectedOreEffect.Kill()
		}
	 	return false
	}

	local oreType = oreNugget.s.oreType

	if ( oreType == oreTypes.TITAN ) //TODO: Really should get this working more elegantly. Lots of copy paste!
	{
		if ( !player.IsTitan() )
		{
			EmitSoundOnEntityOnlyToPlayer( player, player, "Operator.Ability_offline" )
			Remote.CallFunction_Replay( player, "SCB_CantPickupMegaOre" ) //TODO: Can't actually ship this!
			return false
		}

		if ( player.GetDefenseScore() >= MAX_ORE_PLAYER_CAN_CARRY )
		{
			EmitSoundOnEntityOnlyToPlayer( player, player, "Operator.Ability_offline" )
			return false
		}

		player.SetDefenseScore( 10 )
		player.Minimap_AlwaysShow(GetOtherTeam(player), null )

		DecrementBuildCondition( player, 45 )
		EmitSoundOnEntityOnlyToPlayer( player, player, "BurnCard_SpiderSense_CloseWarn" ) //Temp, need another sound

		AddPlayerScore( player, "CollectMegaOre" )

		file.totalOre[ oreNugget.s.oreType ]--

		oreNugget.Kill()

		return true

	}

	if ( player.GetDefenseScore() >= MAX_ORE_PLAYER_CAN_CARRY )
	{
		EmitSoundOnEntityOnlyToPlayer( player, player, "Operator.Ability_offline" )
		return false
	}

	player.SetDefenseScore( player.GetDefenseScore() + 1 )
	if ( player.GetDefenseScore() >= oreEffectThreshold && !( IsValid( player.s.collectedOreEffect ) ) ) //TODO: Depending on .s variable here is fragile...
	//if ( player.GetDefenseScore() > oreEffectThreshold  ) //TODO: Depending on .s variable here is fragile...
	{
		player.Minimap_AlwaysShow(GetOtherTeam(player.GetTeam()), null )
		player.s.collectedOreEffect = PlayLoopFXOnEntity( EMP_BLAST_CHARGE_EFFECT, player, "chestFocus", null, null, 6, player ) //6: visible to everyone but owner
	}


	DecrementBuildCondition( player, ORE_BUILD_TIME )
	EmitSoundOnEntityOnlyToPlayer( player, player, "BurnCard_SpiderSense_CloseWarn" ) //Temp, need another sound

	AddPlayerScore( player, "CollectOre" )

	file.totalOre[ oreNugget.s.oreType ]--
	if ( oreNugget.s.oreType == oreTypes.RANDOM )
	{
		delete level.nodesInUse[ oreNugget.s.nodeID ]
	}

	oreNugget.Kill()

	return true
}

function OreCreator()
{
	for ( ;; )
	{
		if ( GamePlaying() )
			TryCreateOre()

		wait ORE_SPAWN_DELAY
	}
}

function TryCreateOre()
{
	SpawnStartOres()
}


function GameMode_Scavenger_PlayerConnected( player )
{
	//printt( "Player: " + player.GetEntIndex() + " has connected" )
	player.s.collectedOreEffect <- null
}
Globalize( GameMode_Scavenger_PlayerConnected )

function PrintPlayerOreCounts()
{
	foreach( player in GetPlayerArray() )
	{
		printt( "Player : " + player.GetEntIndex() + " has collectedOreCount: " + player.GetDefenseScore() ) //check to see clients know other player's ore count
	}

}

Globalize( PrintPlayerOreCounts )

function Scavenger_TitanBecomesPilot( player, npc_titan )
{
	if ( player.GetDefenseScore() >= oreEffectThreshold && IsValid( player.s.collectedOreEffect ) )
	{
		//printt( "Transfer effect? Titan Becomes Pilot" )
		player.s.collectedOreEffect.SetParent( player, "chestFocus" )
	}

}

function Scavenger_WinnerDeterminedEnter( )
{

	foreach ( player in GetPlayerArray() )
	{
		player.SetDefenseScore( 0 )
		if ( IsValid( player.s.collectedOreEffect ) )
			player.s.collectedOreEffect.Kill()
	}

	foreach ( _, oreDumpSpot in file.oreDumpSpots  )
	{
		oreDumpSpot.Minimap_AlwaysShow( TEAM_IMC, null )
		oreDumpSpot.Minimap_AlwaysShow( TEAM_MILITIA, null )

	}
}
