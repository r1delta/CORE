const LINEGEN_DEBUG = 0
const PREVIEW_DEBUG = 0
const LINEGEN_TIME = 600

const OPTIMAL_ZIPNODE_DIST_SQRD = 16384 //128 sqrd
//	4096 	64 sqrd
//	65536 	256 sqrd

function main()
{
	Globalize( testa ) // debug
	Globalize( CreateDropshipDropoff )
	Globalize( CreateCinematicDropship )
	Globalize( CreateScriptedDropship )
	Globalize( CreateZiplinePoints )
	Globalize( RunDropshipDropoff )
	Globalize( RunScriptedDropShip )
	Globalize( SpawnCinematicDropship )
	Globalize( RunCinematicDropship )
	Globalize( RunCinematicDropshipEvent )
	Globalize( RunEvacDropship )
	Globalize( DropshipFindDropNodes )
	Globalize( AnaylsisFuncDropshipFindDropNodes )
	Globalize( AddTurret )
	Globalize( PlayWarpFxOnPlayers )

	Globalize( ChangeSkyCam )

	Globalize( debugKillGuyOnSlotTaken )

	RegisterSignal( "hackdone" )
	RegisterSignal( "OnDropoff" )
	RegisterSignal( "embark" )
	RegisterSignal( "WarpedIn" )
	PrecacheWeapon( TURRET_WEAPON_ROCKETS )
	PrecacheImpactEffectTable( "dropship_dust" )

	file.dropshipSound <- {
		[ TEAM_IMC ] = {
			[ DROPSHIP_STRAFE ]						= "Goblin_IMC_TroopDeploy_Flyin",
			[ DROPSHIP_VERTICAL ]					= "Goblin_Dropship_Flyer_Attack_Vertical_Succesful",
			[ DROPSHIP_FLYER_ATTACK_ANIM_VERTICAL ]	= "Goblin_Flyer_Dropshipattack_Vertical",
			[ DROPSHIP_FLYER_ATTACK_ANIM ]			= "Goblin_Flyer_Dropshipattack"
		},
		[ TEAM_MILITIA ] = {
			[ DROPSHIP_STRAFE ]						= "Crow_MCOR_TroopDeploy_Flyin",
			[ DROPSHIP_VERTICAL ]					= "Crow_Dropship_Flyer_Attack_Vertical_Succesful",
			[ DROPSHIP_FLYER_ATTACK_ANIM_VERTICAL ]	= "Crow_Flyer_Dropshipattack_Vertical",
			[ DROPSHIP_FLYER_ATTACK_ANIM ]			= "Crow_Flyer_Dropshipattack"
		}
	}
}

function testa()
{
	local analysis = GetAnalysisForModel( "models/vehicle/goblin_dropship/goblin_dropship.mdl", "gd_goblin_zipline_strafe" )
	local origin = GetAnalysisNodePos( analysis, 71, 0 )
	printt( "Origin " + origin )
	thread DropshipFindDropNodes( analysis, origin, 135 )
}

function AnaylsisFuncDropshipFindDropNodes( analysis, origin, yaw )
{
	return DropshipFindDropNodes( analysis, origin, yaw, "both", false, IsLegalFlightPath )
}

// run from TryAnalysisAtOrigin
function DropshipFindDropNodes( analysis, origin, yaw, side = "both", ignoreCollision = false, legalFlightFunc = null, amortize = false )
{
	local angles = Vector( 0, yaw, 0 )
	local forward = angles.AnglesToForward()
	local right = angles.AnglesToRight()
	local start = GetWarpinPosition( analysis.model, analysis.anim, origin, angles )
	if ( fabs( start.origin.x ) > 16000 )
		return
	if ( fabs( start.origin.y ) > 16000 )
		return
	if ( fabs( start.origin.z ) > 16000 )
		return

	if ( !ignoreCollision )
	{
		if ( !legalFlightFunc( analysis, origin, forward, right, !level.activeNodeAnalysis && PREVIEW_DEBUG ) )
			return
	}

	local deployPoint = GetPreviewPoint( analysis )
	local deployOrigin = GetOriginFromPoint( deployPoint, origin, forward, right )
	local deployAngles = GetAnglesFromPoint( deployPoint, angles )
	local deployYaw = deployAngles.y

	// flatten it
	deployAngles.x = 0
	deployAngles.z = 0

	local pitch = 50
	local deployRightAngles = deployAngles.AnglesCompose( Vector( 0, -90, 0 ) )
	deployRightAngles = deployRightAngles.AnglesCompose( Vector( pitch, 0, 0 ) )

	local deployLeftAngles = deployAngles.AnglesCompose( Vector( 0, 90, 0 ) )
	deployLeftAngles = deployLeftAngles.AnglesCompose( Vector( pitch, 0, 0 ) )

	// find nodes to deploy to
	local foundNodes = {}

	local nodeTable
	local foundRightNodes = false
	local foundLeftNodes = false

	if ( side == "right" || side == "both" || side == "either" )
	{
		nodeTable = FindDropshipDeployNodes( deployOrigin, deployRightAngles, amortize )
		if ( nodeTable )
		{
			if ( amortize )
				wait 0
			foundRightNodes = FindBestDropshipNodesForSide( foundNodes, nodeTable, "right", analysis, origin, forward, right, angles, deployOrigin, deployRightAngles, amortize )
		}

		if ( !foundRightNodes && side != "either" )
			return

		if ( amortize )
			wait 0
	}

	if ( side == "left" || side == "both" || side == "either" )
	{
		nodeTable = FindDropshipDeployNodes( deployOrigin, deployLeftAngles, amortize )
		if ( nodeTable )
		{
			if ( amortize )
				wait 0
			foundLeftNodes = FindBestDropshipNodesForSide( foundNodes, nodeTable, "left", analysis, origin, forward, right, angles, deployOrigin, deployLeftAngles, amortize )
		}

		if ( !foundLeftNodes && side != "either" )
			return
	}

	if ( !foundRightNodes && !foundLeftNodes )
		return

	if ( LINEGEN_DEBUG || PREVIEW_DEBUG )
	{
		DrawArrow( origin, angles, 15, 250 )
		local time = 500
		foreach ( side, nodes in foundNodes )
		{
			//DebugDrawText( nodes.centerNode.origin + Vector(0,0,55), nodes.centerNode.fraction + "", true, time )
			//DebugDrawText( nodes.centerNode.origin, "" + nodes.centerNode.dot, true, time )
			DebugDrawLine( nodes.centerNode.origin, nodes.centerNode.attachOrigin, 120, 255, 120, true, time )
			DebugDrawCircle( nodes.centerNode.origin, Vector( 0,0,0 ), 15, 120, 255, 120, time )

			//DebugDrawText( nodes.leftNode.origin + Vector(0,0,55), nodes.leftNode.fraction + "", true, time )
			//DebugDrawText( nodes.leftNode.origin, "" + nodes.leftNode.dot, true, time )
			DebugDrawLine( nodes.leftNode.origin, nodes.leftNode.attachOrigin, 255, 120, 120, true, time )
			DebugDrawCircle( nodes.leftNode.origin, Vector( 0,0,0 ), 15, 255, 120, 120, time )

			//DebugDrawText( nodes.rightNode.origin + Vector(0,0,55), nodes.rightNode.fraction + "", true, time )
			//DebugDrawText( nodes.rightNode.origin, "" + nodes.rightNode.dot, true, time )
			DebugDrawLine( nodes.rightNode.origin, nodes.rightNode.attachOrigin, 120, 120, 255, true, time )
			DebugDrawCircle( nodes.rightNode.origin, Vector( 0,0,0 ), 15, 120, 120, 255, time )

			//DebugDrawLine( nodes.rightNode.origin, nodes.centerNode.origin, 200, 200, 200, true, time )
			//DebugDrawText( nodes.rightNode.origin + Vector(0,0,20), "dist: " + Distance( nodes.rightNode.origin, nodes.centerNode.origin ), true, time )
			//DebugDrawLine( nodes.leftNode.origin, nodes.centerNode.origin, 200, 200, 200, true, time )
			//DebugDrawText( nodes.leftNode.origin + Vector(0,0,20), "dist: " + Distance( nodes.leftNode.origin, nodes.centerNode.origin ), true, time )

			//DebugDrawLine( origin, origin + deployForward * 200, 50, 255, 50, true, time )

	//		foreach ( node in nodes.rightNodes )
	//		{
	//			DebugDrawText( node.origin + Vector(0,0,25), "R", true, 15 )
	//		}
	//
	//		foreach ( node in nodes.leftNodes )
	//		{
	//			DebugDrawText( node.origin + Vector(0,0,25), "L", true, 15 )
	//		}
		}

//		IsLegalFlightPath( analysis, origin, forward, right, true )
	}

	return foundNodes
}


function FindDropshipDeployNodes( deployOrigin, deployAngles, amortize = false )
{
	local deployForward = deployAngles.AnglesToForward()

	local end = deployOrigin + deployForward * 3000
	local result = TraceLine( deployOrigin, end, null, TRACE_MASK_NPCWORLDSTATIC )

	if ( LINEGEN_DEBUG )
	{
		DebugDrawLine( deployOrigin, result.endPos, 255, 255, 255, true, LINEGEN_TIME )
		DebugDrawText(result.endPos + Vector( 0,0,10 ), "test", true, LINEGEN_TIME )
		DebugDrawCircle( result.endPos, Vector( 0,0,0 ), 35, 255, 255, 255, LINEGEN_TIME )
	}
	// no hit?
	if ( result.fraction >= 1.0 )
		return

	local node = GetNearestNodeToPos( result.endPos )
	if ( node == -1 )
		return

	if ( IsSpectreNode( node ) )
		return

	if ( LINEGEN_DEBUG )
	{
		DebugDrawText( GetNodePos( node, HULL_HUMAN ) + Vector(0,0,10), "nearest node", true, 15 )
		DebugDrawCircle( GetNodePos( node, HULL_HUMAN ), Vector( 0,0,0 ), 20, 60, 60, 255, LINEGEN_TIME )
	}

	local neighborNodes = GetNeighborNodes( node, 20, HULL_HUMAN )
	neighborNodes.append( node )

	if ( amortize )
		wait 0

	local nodeTable = {}
	foreach ( nod in neighborNodes )
	{
		if ( IsSpectreNode( nod ) )
			continue

		local tab = {}
		tab.origin <- GetNodePos( nod, HULL_HUMAN )
		tab.node <- nod

		nodeTable[ nod ] <- tab
	}

	return nodeTable
}

function AddDirectionVec( nodeTable, origin, dir = null )
{
	// different direction vecs because we want a node to the left, center, and straight
	foreach ( node, tab in nodeTable )
	{
		if ( dir )
			tab.vec <- ( tab.origin + dir * 50 ) - origin
		else
			tab.vec <- tab.origin - origin

	//	if ( LINEGEN_DEBUG )
	//	DebugDrawLine( tab.origin, origin, 50, 50, 255, true, 15.0 )

		tab.vec.Norm()
	}
}


function FindBestDropshipNodesForSide( foundNodes, nodeTable, side, analysis, origin, forward, right, angles, deployOrigin, deployAngles, amortize )
{
	local deployForward = deployAngles.AnglesToForward()
	local deployRight = deployAngles.AnglesToRight()

	local RatioForLeftRight = 0.2
	local RightDeployForward = ( ( deployForward * ( 1.0 - RatioForLeftRight ) ) + ( deployRight * RatioForLeftRight * -1 ) )
	RightDeployForward.Norm()
	local LeftDeployForward = ( ( deployForward * ( 1.0 - RatioForLeftRight ) ) + ( deployRight * RatioForLeftRight ) )
	LeftDeployForward.Norm()

	if ( amortize )
		wait 0

	foundNodes[ side ] <- null
	local attachPoints = GetAttachPoints( analysis, side )

	local centerNodes = GetNodeArrayFromTable( nodeTable )
	AddDirectionVec( centerNodes, deployOrigin )
	local centerNode = GetBestDropshipNode( attachPoints[2], centerNodes, origin, deployForward, forward, right, angles )
	if ( !centerNode )
		return
	delete nodeTable[ centerNode.node ]

	if ( amortize )
		wait 0

	local leftNodes = GetCulledNodes( nodeTable, deployRight * -1 )
	AddDirectionVec( leftNodes, deployOrigin, deployRight * -1 )
	local leftNode = GetBestDropshipNode( attachPoints[1], leftNodes, origin, RightDeployForward, forward, right, angles, centerNode )
	if ( !leftNode )
		return
	delete nodeTable[ leftNode.node ]

	if ( amortize )
		wait 0

	local rightNodes = GetCulledNodes( nodeTable, deployRight )
	AddDirectionVec( rightNodes, deployOrigin, deployRight )
	local rightNode = GetBestDropshipNode( attachPoints[0], rightNodes, origin, LeftDeployForward, forward, right, angles, centerNode )
	if ( !rightNode )
		return

	local table = {}
	table.centerNode <- centerNode
	table.leftNode <- leftNode
	table.rightNode <- rightNode

	//table.rightNodes <- rightNodes // for debug
	//table.leftNodes <- leftNodes // for debug

	foundNodes[ side ] = table
	return true
}

function GetNodeArrayFromTable( nodeTable )
{
	local array = []
	foreach ( table in nodeTable )
	array.append( table )
	return array
}

function GetCulledNodes( nodeTable, right )
{
	local leftNodes = {}
	// get the nodes on the left
	foreach ( nod, tab in nodeTable )
	{
		local dot = tab.vec.Dot( right )
		if ( dot >= 0.0 )
		{
			leftNodes[ nod ] <- tab
		}
	}

	return GetNodeArrayFromTable( leftNodes )
}

function GetBestDropshipNode( attachPoint, nodeArray, origin, deployForward, forward, right, angles, centerNode = null, showdebug = false )
{
	foreach ( node in nodeArray )
	{
		node.dot <- node.vec.Dot( deployForward )
		if ( showdebug )
		{
			DebugDrawText( node.origin, "dot: " + node.dot, true, 15 )
			local green = 0
			local red 	= 255
			if( node.dot > 0.9 )
			{
				green = ( 1.0 - node.dot ) / 0.1
				green = 1.0 - green
				green *= 255

				red -= green
			}

			DebugDrawLine( node.origin, node.origin + ( node.vec * -1000 ), red, green, 0, true, 15.0 )
			DebugDrawCircle( node.origin, Vector( 0,0,0 ), 25, red, green, 0, 15.0 )
		}
	}

	if ( !nodeArray.len() )
		return

	local attachOrigin = GetOriginFromPoint( attachPoint, origin, forward, right )
	local attachAngles = GetAnglesFromPoint( attachPoint, angles )
	local attachForward = attachAngles.AnglesToForward()
	local attachRight = attachAngles.AnglesToRight()

	local offsetAnalysis = GetAnalysisForModel( TEAM_IMC_GRUNT_MDL, ZIPLINE_IDLE_ANIM )
	local offsetPoint = GetPreviewPoint( offsetAnalysis )
	local offsetOrigin = GetOriginFromPoint( offsetPoint, attachOrigin, attachForward, attachRight )
//	DebugDrawLine( offsetOrigin, attachOrigin, 255, 255, 0, true, 15 )

	nodeArray.sort( SortHighestDot )

	local mins = level.traceMins[ "npc_soldier" ]
	local maxs = level.traceMaxs[ "npc_soldier" ]

	local passedNodes = []

	for ( local i = 0; i < nodeArray.len(); i++ )
	{
		local node = nodeArray[i]

		// beyond the allowed dot
		if ( node.dot < 0.3 )
			return null

		// trace to see if the ai could drop to the node from here
		local result = TraceHull( offsetOrigin, node.origin, mins, maxs, null, TRACE_MASK_NPCWORLDSTATIC, TRACE_COLLISION_GROUP_NONE )
		if ( result.fraction < 1.0 )
			continue //return

		// trace to insure that there will be a good place to hook the zipline
		if ( !GetHookOriginFromNode( offsetOrigin, node.origin, attachOrigin ) )
			continue

		node.fraction <- result.fraction
		node.attachOrigin <- offsetOrigin
		node.attachName <- attachPoint.name

		if ( centerNode )
		{
			//test for distance, not too close, not too far
			local distSqr = DistanceSqr( centerNode.origin, node.origin )
			node.rating <- fabs( OPTIMAL_ZIPNODE_DIST_SQRD - distSqr )
			passedNodes.append( node )
			continue
		}

		return node
	}

	if ( centerNode && passedNodes.len() )
	{
		passedNodes.sort( SortLowestRating )
		return passedNodes[ 0 ]
	}

	return null
}

function SortHighestDot( a, b )
{
	if ( a.dot > b.dot )
		return -1

	if ( a.dot < b.dot )
		return 1

	return 0
}

function SortLowestRating( a, b )
{
	if ( a.rating > b.rating )
		return 1

	if ( a.rating < b.rating )
		return -1

	return 0
}

function CreateDropshipDropoff()
{
	local table = CreateCallinTable()
	table.side <- "both"
	table.count <- 6
	table.npcSpawnFunc <- SpawnGrunt
	table.rocketEquipped <- false
	table.anim	<- null

	return table
}

function CreateScriptedDropship()
{
	local table = CreateDropshipDropoff()
	table.style			= eDropStyle.FORCED
	table.npcSpawnFunc 	= Spawn_TrackedGrunt
	table.customSnd		<- null
	table.forcespawn 	<- false

	return table
}

function CreateCinematicDropship()
{
	local table = CreateDropshipDropoff()
	table.style				= eDropStyle.FORCED
	table.turret 	<- false

	return table
}

function CreateZiplinePoints( table, side, leftOrigin, centerOrigin, rightOrigin )
{
	if ( !( "dropTable" in table ) )
	{
		table.dropTable <- {}
		table.dropTable.nodes <- {}
	}

	table.dropTable.nodes[ side ] <- {}
	table.dropTable.nodes[ side ].centerNode 	<- {}
	table.dropTable.nodes[ side ].leftNode 		<- {}
	table.dropTable.nodes[ side ].rightNode 	<- {}

	table.dropTable.nodes[ side ].centerNode.origin 	<- centerOrigin
	table.dropTable.nodes[ side ].centerNode.node		<- GetNearestNodeToPos( centerOrigin )
	Assert( table.dropTable.nodes[ side ].centerNode.node != -1 )

	table.dropTable.nodes[ side ].leftNode.origin 		<- leftOrigin
	table.dropTable.nodes[ side ].leftNode.node			<- GetNearestNodeToPos( leftOrigin )
	Assert( table.dropTable.nodes[ side ].leftNode.node != -1 )

	table.dropTable.nodes[ side ].rightNode.origin 		<- rightOrigin
	table.dropTable.nodes[ side ].rightNode.node		<- GetNearestNodeToPos( rightOrigin )
	Assert( table.dropTable.nodes[ side ].rightNode.node != -1 )

	switch( side )
	{
		case "left":
			table.dropTable.nodes[ side ].rightNode.attachName 	<- GetAnimGroupAttachment( side, 0, "deploy" )
			table.dropTable.nodes[ side ].centerNode.attachName <- GetAnimGroupAttachment( side, 1, "deploy" )
			table.dropTable.nodes[ side ].leftNode.attachName 	<- GetAnimGroupAttachment( side, 2, "deploy" )
			break

		case "right":
			table.dropTable.nodes[ side ].leftNode.attachName 	<- GetAnimGroupAttachment( side, 0, "deploy" )
			table.dropTable.nodes[ side ].centerNode.attachName <- GetAnimGroupAttachment( side, 1, "deploy" )
			table.dropTable.nodes[ side ].rightNode.attachName 	<- GetAnimGroupAttachment( side, 2, "deploy" )
			break
	}
}

function RunDropshipDropoff( table )
{
	local origin =   	table.origin
	local yaw =   		table.yaw
	local team =   		table.team
	local owner =		table.owner
	local squadname = 	table.squadname
	local side =   		table.side
	local count =      	table.count
	local squadFunc =	table.squadFunc
	local squadParm =	table.squadParm
	local style =		table.style
	local health = 7800
	if ( table.dropshipHealth != null )
		health = table.dropshipHealth
	table.success <- false
	table.dropship <- null

	if ( Flag( "DisableDropships" ) )
		return

	if ( team == null )
	{
		if ( owner )
			team = owner.GetTeam()
		else
			team = 0
	}

	local spawnPoint
//	local anims = [ DROPSHIP_STRAFE ]
//	local anims = [ DROPSHIP_VERTICAL ]
	local anims = level.dropshipDropoffAnims	// there are now two animation for most levels

	ArrayRandomize( anims )

	local animation
	local analysis
	local wasPlayerOwned = owner && IsValidPlayer( owner )

	foreach ( anim in anims )
	{
		animation = anim
		printt( "Using model " + DROPSHIP_MODEL + " with animation " + anim )
		analysis = GetAnalysisForModel( DROPSHIP_MODEL, anim )
		printt(analysis)

		if ( style == null )
		{
			if ( yaw == null )
			{
				style = eDropStyle.NEAREST
			}
			else
			{
				style = eDropStyle.NEAREST_YAW
			}
		}

		spawnPoint = GetSpawnPointForStyle( analysis, table )

		if ( spawnPoint )
			break
	}

	if ( !spawnPoint )
	{
		printt( "Couldn't find good spawn location for dropship" )
		return
	}

	table.success = true

//	origin = GetNodePos( 72, 0 )
//	origin.z += level.superCallinOffset[ DROPSHIP_MODEL ]
//	angles.y = 202.5

	local ref = CreateScriptRef()
	ref.SetOrigin( spawnPoint.origin )
	ref.SetAngles( spawnPoint.angles )

	// used for when flyers attack dropships
	if ( "nextDropshipAttackedByFlyers" in level && level.nextDropshipAttackedByFlyers )
		animation = FlyersAttackDropship( ref, animation )

	Assert( IsNewThread(), "Must be threaded off" )

	local dropTable = {}
	dropTable.nodes <- null

	local ignoreCollision = true // = style == eDropStyle.FORCED
	thread FindDropshipZiplineNodes( dropTable, analysis, spawnPoint.origin, spawnPoint.angles, side, ignoreCollision, true )

	local model = GetTeamDropshipModel( team )
	waitthread WarpinEffect( model, animation, spawnPoint.origin, spawnPoint.angles )
	local dropship = SpawnAnimatedDropship( spawnPoint.origin, team, squadname, health )
	table.dropship = dropship
	dropship.EndSignal( "OnDeath" )
	dropship.Signal( "WarpedIn" )
	ref.Signal( "WarpedIn" )
	Signal( table, "WarpedIn" )

	dropship.s.dropTable <- dropTable // this is where the ai will drop to

	if ( IsValid( owner ) )
	{
		dropship.SetCanCloak( false )
		dropship.SetOwner( owner )
		if ( owner.IsPlayer() )
			dropship.SetBossPlayer( owner )
	}

	//AddTurret( dropship, team, TURRET_WEAPON_BULLETS, "FRONT_TURRET" )
	if ( table.rocketEquipped )
	{
		AddTurret( dropship, team, TURRET_WEAPON_ROCKETS, "BOMB_L" )
		AddTurret( dropship, team, TURRET_WEAPON_ROCKETS, "BOMB_R" )
	}

	local dropshipSound = GetTeamDropshipSound( team, animation )


	OnThreadEnd(
		function() : ( dropship, ref, table, dropshipSound )
		{
			ref.Kill()
			if ( IsValid( dropship ) )
				StopSoundOnEntity( dropship, dropshipSound )
			if ( IsAlive( dropship ) )
			{
				dropship.Kill()
			}

			Signal( table, "OnDropoff", { guys = null } )
		}
	)

	local guys = []
	if ( !wasPlayerOwned || IsValidPlayer( owner ) )
	{
		guys = CreateNPCSForDropship( dropship, table.npcSpawnFunc, side, count )

		foreach ( guy in guys )
		{
			if ( IsAlive( guy ) )
			{
				if ( IsValidPlayer( owner ) )
				{
					guy.SetBossPlayer( owner )
					thread DieIfBossDisconnects( guy, owner )
				}
			}
		}

		if ( squadFunc )
		{
			if ( squadParm )
				squadFunc( guys, squadParm )
			else
				squadFunc( guys )
		}
	}

	//thread DropshipMissiles( dropship )
	dropship.Hide()
	EmitSoundOnEntity( dropship, dropshipSound )
	thread ShowDropship( dropship )
	thread PlayAnimTeleport( dropship, animation, ref, 0 )

	//HACK: coop needs the dudes immediately, so if the dropship is destroyed and they are killed before being dropped off...
	//coop hud can accurately display how many enemies are left and give points for killing them
	if ( GAMETYPE != COOPERATIVE )
		WaittillPlayDeployAnims( dropship )

	ArrayRemoveDead( guys )

	Signal( table, "OnDropoff", { guys = guys } )

	dropship.WaittillAnimDone()
	wait 2.0
}

function FindDropshipZiplineNodes( dropTable, analysis, origin, angles, side = "both", ignoreCollision = false, amortize = false )
{
	dropTable.nodes = DropshipFindDropNodes( analysis, origin, angles.y, side, ignoreCollision, IsLegalFlightPath_OverTime, amortize )
}

function ShowDropship( dropship )
{
	dropship.EndSignal( "OnDestroy" )
	wait 0.16
	dropship.Show()
}

function AddTurret( dropship, team, turretWeapon, attachment, health = 700 )
{
	local turret = CreateEntity( TURRET_ENTITY )
	turret.kv.TurretRange = 1500
	turret.kv.AccuracyMultiplier = 1.0
	turret.kv.FieldOfView = 0.4
	turret.kv.FieldOfViewAlert = 0.4
	turret.kv.additionalequipment = turretWeapon
	turret.SetOrigin( Vector(0,0,0) )
	turret.SetTitle( "#NPC_DROPSHIP" )
	turret.s.skipTurretFX <- true
	DispatchSpawn( turret )

	turret.SetName( "DropshipTurret" )
	turret.SetHealth( health)
	turret.SetMaxHealth( health )
	turret.Hide()
	//turret.Show()
	local weapon = turret.GetActiveWeapon()
	weapon.Hide()
	turret.SetTeam( team )
	turret.SetParent( dropship, attachment, false )
	turret.EnableTurret()
	turret.SetOwner( dropship.GetOwner() )
	turret.SetAimAssistAllowed( false )

	local bossPlayer = dropship.GetBossPlayer()
	if ( IsValidPlayer( bossPlayer ) )
		turret.SetBossPlayer( dropship.GetBossPlayer() )

	HideName( turret )
	return turret
}

function SpawnCinematicDropship( table )
{
	local dropship = SpawnAnimatedHeroDropship( table.origin, table.team, table.squadname, 10000 )
	if ( IntroPreviewOn() )
		dropship.s.guys <- CreateDebugSlotsForDropship( dropship, SpawnGrunt, table.side, table.count )

	SpawnCinematicRefCommon( dropship, table )

	MakeInvincible( dropship )
	HideName( dropship )

	if ( table.turret )
		AddTurret( dropship, table.team, TURRET_WEAPON_BULLETS, "FRONT_TURRET" )

	return dropship
}

function debugKillGuyOnSlotTaken( guy, slot )
{
	slot.EndSignal( "OnDeath" )

	while( 1 )
	{
		wait 0.2

		local player = GetPlayerFromSlot( slot )

		if ( !player )
			continue
		if ( !player.IsPlayer() )
			continue

		break
	}

	guy.Kill()
}

function RunCinematicDropship( dropship, ... )
{
	Assert( Flag( "ReadyToStartMatch" ), "cinematic events shouldn't be called until after the flag 'ReadyToStartMatch' has been set" )
	Assert( vargc > 0, "no tables passed to RunCinematicDropship" )

	//create list of events from variable args
	local events = []
	for ( local i = 0; i < vargc; i++ )
		events.append( vargv[ i ] )

	//if it needs zipline data - get it
	if ( dropship.s.GetZipLineData )
	{
		//find the last event...we'll assume this is the one with zipline anim info
		local table 	= events[ events.len() - 1 ]

		//copy needed variables
		if ( !( "side" in table ) )
			table.side <- null
		table.side = dropship.s.side

		//make sure analysis exists first
		if( !FlagExists( "FlightAnalysisReady" ) )
			FlagInit( "FlightAnalysisReady" )
		FlagWait( "FlightAnalysisReady" )

		//get the data
		GetDropshipZipLineData( dropship, table )
	}

	//create a single ref for all the anims
	local ref = CreateScriptRef()

	OnThreadEnd(
		function() : ( dropship, ref )
		{
				ref.Kill()
				if ( IsAlive( dropship ) )
					dropship.Kill()
		}
	)

	dropship.EndSignal( "OnDeath" )

	AddAnimEvent( dropship, "ramp_open", PlayDropshipRampDoorOpenSound )

	foreach ( slot in GetSlotsFromRef( dropship ) )
		thread BeginSlotAnimTracking( slot )

	//play events in order
	for ( local i = 0; i < events.len(); i++ )
	{
		local table = events[ i ]
		Assert( typeof( table ) == "table", "something other than a table passed into RunCinematicDropship for variable number " + ( i + 2 )  )

		local futureEvents = GetFutureEvents( events, i )

		waitthread RunCinematicDropshipEvent( dropship, ref, table, futureEvents )
	}
}

//Very similar to RunEvacDropship. Doesn't do ziplines, doesn't delete dropship at end
function RunEvacDropship( dropship, ... )
{
	Assert( Flag( "ReadyToStartMatch" ), "cinematic events shouldn't be called until after the flag 'ReadyToStartMatch' has been set" )
	Assert( vargc > 0, "no tables passed to RunCinematicDropship" )

	//create list of events from variable args
	local events = []
	for ( local i = 0; i < vargc; i++ )
		events.append( vargv[ i ] )

	//create a single ref for all the anims
	local ref = CreateScriptRef()

	dropship.EndSignal( "OnDeath" )

	AddAnimEvent( dropship, "ramp_open", PlayDropshipRampDoorOpenSound )

	foreach ( slot in GetSlotsFromRef( dropship ) )
		thread BeginSlotAnimTracking( slot )

	//play events in order
	for ( local i = 0; i < events.len(); i++ )
	{
		local table = events[ i ]
		Assert( typeof( table ) == "table", "something other than a table passed into RunCinematicDropship for variable number " + ( i + 2 )  )

		local futureEvents = GetFutureEvents( events, i )

		waitthread RunCinematicDropshipEvent( dropship, ref, table, futureEvents )
	}
}

function GetFutureEvents( events, eventCur )
{
	if ( eventCur + 1 >= events.len() )
		return null

	local futureEvents = []

	for ( local i = eventCur + 1; i < events.len(); i++ )
		futureEvents.append( events[ i ] )

	return futureEvents
}

function RunCinematicDropshipEvent( dropship, ref, table, futureEvents = null )
{
	dropship.EndSignal( "OnDeath" )

	/////////////////////////////////	SETUP	///////////////////////////////////////////
	local origin 	= table.origin
	local angles 	= null

	if ( table.angles )
		angles = table.angles
	else
	if ( table.yaw != null )
		angles = Vector( 0, table.yaw, 0 )

	local anim		= table.anim
	local blendTime	= table.blendTime

	if ( origin )
		ref.SetOrigin( origin )
	if ( angles )
		ref.SetAngles( angles )

	OnThreadEnd(
		function() : ( table )
		{
			foreach ( flag in Event_GetFlagSetOnEndArray( table ) )
				FlagSet( flag )
		}
	)

	foreach ( flag in Event_GetFlagWaitToStartArray( table ) )
		FlagWait( flag )

	foreach ( flag in Event_GetFlagSetOnStartArray( table ) )
		FlagSet( flag )

	if ( table.skycam )
	{
		//lets set the skycam unless it should be set after a warpjump or cloud jump
		if ( !( table.preAnimFPSWarp || table.postAnimFPSWarp || table.preAnimFPSClouds ) )
			ChangeSkyCam( dropship, table )
	}

	//////////////////////////////////////	 WARP JUMP	///////////////////////////////////////////
	if ( table.preAnimFPSWarp )
	{
		waitthread DoFPSWarpIn( dropship, anim, ref, table )

		foreach ( flag in Event_GetFlagSetOnWarpArray( table ) )
			FlagSet( flag )

		ChangeSkyCam( dropship, table, SKYBOXLEVEL )
	}
	else
	if ( table.preAnimWarp )
	{
		dropship.Hide()
		waitthread WarpinEffect( dropship.GetModelName(), anim, ref.GetOrigin(), ref.GetAngles() )
		dropship.Show()

		foreach ( flag in Event_GetFlagSetOnWarpArray( table ) )
			FlagSet( flag )
	}

	////////////////////////////////////	 CLOUD COVER	///////////////////////////////////////
	if ( table.preAnimFPSClouds )
	{
		waitthread CloudCoverEffect( dropship )

		foreach ( flag in Event_GetFlagSetOnCloudsArray( table ) )
			FlagSet( flag )

		ChangeSkyCam( dropship, table )
	}

	/////////////////////////////////////	PLAY ANIM	///////////////////////////////////////
	//run the non state functions
	foreach ( func in Event_GetAnimStartFuncArray( table ) )
		thread func( dropship, ref, table )

	//setup state functions for client
	if ( table.eventState != null )		//->check null, because if nothing new, don't override the last state
		dropship.SetCinematicEventState( table.eventState )

	//setup state functions for server
	if ( Event_GetServerStateFuncArray( table ).len() )	//->check length, because if nothing new, don't override the last state
	{
		dropship.s.serverStateFuncs = Event_GetServerStateFuncArray( table )
		RunServerStateFuncsForAttachedPlayers( dropship, Event_GetServerStateFuncArray( table ) )
	}

	dropship.Signal( "CinematicEventAnim" )

	switch( anim )
	{
		//hack because I dont have proper landing anim
		case "test_land":
			thread DoHackedLandingAnim( dropship, ref, anim )
			break

		default:
		{
			if ( table.teleport )
				thread PlayAnimTeleport( dropship, anim, ref )
			else
				thread PlayAnim( dropship, anim, ref, null, blendTime )

		}break
	}

	//WAIT the proper amount of time

	if ( Event_GetFlagWaitToEndArray( table ).len() )
	{
		foreach ( flag in Event_GetFlagWaitToEndArray( table ) )
			FlagWait( flag )
	}
	else if ( table.proceduralLength )
	{
		local waitTime = CalculateWaitTime( dropship, table, futureEvents )

		if ( waitTime )
			wait waitTime
	}
	else if ( table.postAnimFPSWarp )
	{
		waitthread DoFPSWarpOut( dropship, anim, ref, table )
		ChangeSkyCam( dropship, table, SKYBOXSPACE )
	}
	else
	{
		//hack because I dont have proper landing anim
		switch( anim )
		{
			case "test_land":
				dropship.WaitSignal( "hackdone" )
				break

			default:
				dropship.WaittillAnimDone()
				break
		}
	}
}

function PlayDropshipRampDoorOpenSound ( dropship )
{
	local snd = CreateScriptMover( dropship )
	snd.SetParent( dropship, "RAMPDOORLIP" )

	EmitSoundOnEntity( snd, "fracture_scr_intro_dropship_dooropen" )
}

function DoFPSWarpIn( dropship, anim, ref, table )
{
	PlayWarpFxOnPlayers( GetSlotsFromRef( dropship ) )
	waitthread WarpinEffect( dropship.GetModelName(), anim, ref.GetOrigin(), ref.GetAngles() )
}

function DoFPSWarpOut( dropship, anim, ref, table )
{
	dropship.EndSignal( "OnDeath" )

	local duration 	= dropship.GetSequenceDuration( anim ) - 0.1 // subtract a fraction of a second just to be safe
	local time = duration - WARPINFXTIME

	wait time

	PlayWarpFxOnPlayers( GetSlotsFromRef( dropship ) )

	wait WARPINFXTIME

	WarpoutEffectFPS( dropship )
}

function ChangeSkyCam( dropship, table, defaultSky = null )
{
	local skycam = null

	if ( table.skycam )
		skycam = GetEnt( table.skycam )
	else if ( defaultSky )
		skycam = GetEnt( defaultSky )

	if ( !skycam )
		return

	dropship.s.lastSkyCam = skycam

	SetSkyBoxForAttachedPlayers( dropship, skycam )
}

function RunScriptedDropShip( table )
{
	local origin 	= table.origin
	local angles 	= Vector( 0, table.yaw, 0 )
	local team 		= table.team
	local side 		= table.side
	local count 	= table.count
	local anim		= table.anim

	local squadname	= table.squadname
	local squadFunc = table.squadFunc
	local squadParm = table.squadParm

	local model = GetTeamDropshipModel( team )
	waitthread WarpinEffect( model, anim, origin, angles )

	/////////////////////////////////	CREATION	//////////////////////////////////////
	//Create the Dropship
	local dropship = SpawnAnimatedDropship( origin, team, squadname, 10000 )

	if ( table.customSnd )
		EmitSoundOnEntity( dropship, table.customSnd )

	//MakeInvincible( dropship )
	HideName( dropship )

	//Prepare the Dropship
	//AddTurret( dropship, team, TURRET_WEAPON_BULLETS, "FRONT_TURRET" )

	//create the guys
	if ( !table.forcespawn )
	{
		//don't spawn guys unless we have room
		local freeAIcount = GetFreeAISlots( team )
		local overflow = freeAIcount - count
		if ( overflow < 0 )
			count += overflow
	}

	local guys = CreateNPCSForDropship( dropship, table.npcSpawnFunc, side, count )

	//prepare the guys
	if ( squadFunc )
	{
		if ( squadParm != null )//must check null - because 0 is a valid param
			squadFunc( guys, squadParm )
		else
			squadFunc( guys )
	}

	dropship.s.guys <- guys
	dropship.s.side <- table.side
	dropship.s.GetZipLineData <- null

	switch( side )
	{
		case "left":
		case "right":
		case "both":
			dropship.s.GetZipLineData = true
			break
		default:
			dropship.s.GetZipLineData = false
			break
	}

	//if it needs zipline data - get it
	if ( dropship.s.GetZipLineData )
	{
		//make sure analysis exists first
		if( !FlagExists( "FlightAnalysisReady" ) )
			FlagInit( "FlightAnalysisReady" )
		FlagWait( "FlightAnalysisReady" )

		//get the data
		GetDropshipZipLineData( dropship, table )
	}

	local ref = CreateScriptRef()
	ref.SetOrigin( origin )
	ref.SetAngles( angles )

	OnThreadEnd(
		function() : ( dropship, ref )
		{
			ref.Kill()
			if ( IsAlive( dropship ) )
				dropship.Kill()
		}
	)

	dropship.EndSignal( "OnDeath" )

	/////////////////////////////////////	PLAY ANIM	///////////////////////////////////////
	//hack because I dont have proper landing anim
	switch( anim )
	{
		case "test_land":
			thread DoHackedLandingAnim( dropship, ref, anim )
			dropship.WaitSignal( "hackdone" )
			break

		default:
			waitthread PlayAnimTeleport( dropship, anim, ref )
			break
	}
}

function CalculateWaitTime( ref, table, futureEvents = null )
{
	local waitTime = 0.0

	if ( futureEvents && futureEvents.len() )
	{
		foreach( event in futureEvents )
		{
			if ( Event_GetFlagWaitToEndArray( event ).len() )
				return 0
			if ( Event_GetFlagWaitToStartArray( event ).len() )
				return 0

			local dropshipDeployTime = GetDropshipDeployTime( ref, event.anim )
			waitTime += GetTimeTillIntroStarts( dropshipDeployTime )
		}
	}

	Assert( !( "proceduralWaitTime" in ref.s ), "can't have two procedural wait events" )
	ref.s.proceduralWaitTime <- Time() + waitTime
	ref.Signal( "CalculatedWaitTime" )
	//printt( "procedural wait time for ref", waitTime )

	if ( futureEvents && futureEvents.len() )
	{
		foreach( event in futureEvents )
		{
			if ( event.preAnimFPSWarp )
				waitTime -= WARPINFXTIME

			if ( event.preAnimFPSClouds )
				waitTime -= CLOUDCOVERFXTIME
		}
	}

	if ( waitTime < 0 )
		waitTime = 0.0

	return waitTime
}

function DoHackedLandingAnim( dropship, ref, anim )
{
	dropship.EndSignal( "OnDeath" )

	thread PlayAnimTeleport( dropship, "test_land", ref, null )

	wait 8
	dropship.Signal( "deploy" )
	wait 1

	thread PlayAnim( dropship, "test_takeoff", ref, null, 1.0 )
	wait 2
	dropship.NotSolid()
	wait 4

	thread PlayAnim( dropship, "refueling_sequence_end", ref, null, 1.5 )
	dropship.Solid()

	dropship.WaittillAnimDone()
	dropship.Signal( "hackdone" )
}

function GetDropshipZipLineData( dropship, table )
{
	if ( "dropTable" in table )
	{
		dropship.s.dropTable <- table.dropTable

		if ( LINEGEN_DEBUG || PREVIEW_DEBUG )
		{
			local time = 500

			foreach ( side, nodes in table.dropTable.nodes )
			{
			//	DebugDrawLine( nodes.centerNode.origin, nodes.centerNode.attachOrigin, 120, 255, 120, true, time )
				DebugDrawCircle( nodes.centerNode.origin, Vector( 0,0,0 ), 15, 120, 255, 120, time )
				DebugDrawCircle( GetNodePos( nodes.centerNode.node, HULL_HUMAN ), Vector( 0,0,0 ), 10, 60, 255, 60, time )

			//	DebugDrawLine( nodes.leftNode.origin, nodes.leftNode.attachOrigin, 255, 120, 120, true, time )
				DebugDrawCircle( nodes.leftNode.origin, Vector( 0,0,0 ), 15, 255, 120, 120, time )
				DebugDrawCircle( GetNodePos( nodes.leftNode.node, HULL_HUMAN ), Vector( 0,0,0 ), 10, 255, 60, 60, time )

			//	DebugDrawLine( nodes.rightNode.origin, nodes.rightNode.attachOrigin, 120, 120, 255, true, time )
				DebugDrawCircle( nodes.rightNode.origin, Vector( 0,0,0 ), 15, 120, 120, 255, time )
				DebugDrawCircle( GetNodePos( nodes.rightNode.node, HULL_HUMAN ), Vector( 0,0,0 ), 10, 60, 60, 255, time )
			}
		}

		return
	}

	local origin 	= table.origin
	local angles 	= Vector( 0, table.yaw, 0 )
	local side 		= table.side
	local animation = table.anim

	local analysis 	= GetAnalysisForModel( DROPSHIP_MODEL, animation )

	local dropTable = {}
	dropTable.nodes <- null

	local ignoreCollision = true

	thread FindDropshipZiplineNodes( dropTable, analysis, origin, angles, side, ignoreCollision )

	dropship.s.dropTable <- dropTable // this is where the ai will drop to
}

function PlayWarpFxOnPlayers( guys )
{
	foreach( guy in guys )
	{
		local player = GetPlayerFromSlot( guy )

		if ( !IsAlive( player ) )
			continue

		//because of debug skipping - check for this
		if ( !player.IsPlayer() )
			continue

		Remote.CallFunction_Replay( player, "ServerCallback_PlayScreenFXWarpJump" )
	}
}

function PlaySoundForPlayersOnCinematicDropship( sound, dropship )
{
	local guys = GetSlotsFromRef( dropship )
	foreach( guy in guys )
	{
		local player = GetPlayerFromSlot( guy )

		if ( !IsAlive( player ) )
			continue

		//because of debug skipping - check for this
		if ( !player.IsPlayer() )
			continue

		EmitSoundAtPositionOnlyToPlayer( player.GetOrigin(), player, sound)
	}
}

function GetTeamDropshipSound( team, animation )
{
	Assert( team in file.dropshipSound )
	Assert( animation in file.dropshipSound[ team ] )

	return file.dropshipSound[ team ][ animation ]
}