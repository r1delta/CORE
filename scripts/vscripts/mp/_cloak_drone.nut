const CLOAKED_DRONE_SPEED		= 1800
const CLOAKED_DRONE_ACC		= 1.75
const CLOAKED_DRONE_YAWRATE	= 150
const CLOAKED_DRONE_LOOPING_SFX = "Coop_CloakDrone_Beam"
const CLOAKED_DRONE_WARP_IN_SFX = "Coop_DroneTeleport_In"
const CLOAKED_DRONE_WARP_OUT_SFX = "Coop_DroneTeleport_Out"
const CLOAKED_DRONE_CLOAK_START_SFX = "CloakDrone_Cloak_On"
const CLOAKED_DRONE_CLOAK_LOOP_SFX = "CloakDrone_Cloak_Sustain_Loop"
const CLOAKED_DRONE_HOVER_LOOP_SFX = "AngelCity_Scr_DroneSearchHover"

const MINIMAP_CLOAKED_DRONE_SCALE 		= 0.070

function main()
{
	level.cloakedDronesManagedEntArrayID <- CreateScriptManagedEntArray()
	level.cloakedDroneClaimedSquadList <- {}

	Globalize( CloakedDroneIsSquadClaimed )

	RegisterSignal( "DroneCleanup" )
}

function SpawnCloakDrone( team, origin, angles )
{
	local mover = CreateEntity( "script_mover" )
	local droneCount = GetNPCCloakedDrones().len()

	// add some minor randomness to the spawn location as well as an offset based on number of drones in the world.
	origin += Vector( RandomInt( -64, 64 ), RandomInt( -64, 64 ), 300 + ( droneCount * 128 ) )

	mover.kv.solid = 6
	mover.kv.model = CLOAKED_DRONE_MODEL
	mover.kv.SpawnAsPhysicsMover = 1
	mover.SetOrigin( origin )
	mover.SetAngles( angles )
	DispatchSpawn( mover, true )
	mover.Hide()
	mover.NotSolid()

	mover.SetMaxSpeed( CLOAKED_DRONE_SPEED )
	mover.SetAccelScale( CLOAKED_DRONE_ACC )
	mover.SetYawRate( CLOAKED_DRONE_YAWRATE )

	local cloakedDrone = CreatePropDynamic( CLOAKED_DRONE_MODEL, mover.GetOrigin(), mover.GetAngles(), 2, 8000 )

	//these enable global damage callbacks for the cloakedDrone
	cloakedDrone.s.searchShipMover <- mover
	cloakedDrone.s.isSearchDrone <- true
	cloakedDrone.s.isCloakedDrone <- true
	cloakedDrone.s.fakeHealth <- 250
	cloakedDrone.s.fakeMaxHealth <- 250
	cloakedDrone.s.isHidden <- false
	cloakedDrone.s.fx <- null

	cloakedDrone.SetTeam( team )
	cloakedDrone.SetName( "Cloak Drone" )
	cloakedDrone.SetTitle( "#NPC_CLOAK_DRONE" )
	cloakedDrone.Fire( "SetAnimation", "idle" )
	cloakedDrone.SetHealth( cloakedDrone.s.fakeHealth )
	cloakedDrone.SetDamageNotifications( true )
	cloakedDrone.Solid()
	cloakedDrone.Show()
	cloakedDrone.SetParent( mover, "", true, 0 )
	cloakedDrone.MarkAsNonMovingAttachment()
	cloakedDrone.EnableAttackableByAI()
	SetCustomSmartAmmoTarget( cloakedDrone, true )

	EmitSoundOnEntity( cloakedDrone, CLOAKED_DRONE_HOVER_LOOP_SFX )
	EmitSoundOnEntity( cloakedDrone, CLOAKED_DRONE_LOOPING_SFX )
	EmitSoundOnEntity( cloakedDrone, CLOAKED_DRONE_WARP_IN_SFX )

	cloakedDrone.s.fx = CreateDroneCloakBeam( cloakedDrone )


	SetObjectCanBeMeleed( cloakedDrone, true )
	SetVisibleEntitiesInConeQueriableEnabled( cloakedDrone, true )

	thread CloakedDronePathThink( cloakedDrone )
	thread CloakedDroneCloakThink( cloakedDrone )

	cloakedDrone.Minimap_SetDefaultMaterial( "vgui/hud/cloak_drone_minimap_orange" )
	cloakedDrone.Minimap_SetAlignUpright( true )
	cloakedDrone.Minimap_AlwaysShow( TEAM_IMC, null )
	cloakedDrone.Minimap_AlwaysShow( TEAM_MILITIA, null )
	cloakedDrone.Minimap_SetObjectScale( MINIMAP_CLOAKED_DRONE_SCALE )
	cloakedDrone.Minimap_SetZOrder( 10 )

	ShowName( cloakedDrone )
	mover.SetMoveToPosition( mover.GetOrigin() )//without this the drone will just start dropping until it finds a valid path

	AddToGlobalCloakedDroneList( cloakedDrone )
	return cloakedDrone
}
Globalize( SpawnCloakDrone )

function AddToGlobalCloakedDroneList( cloakedDrone )
{
	AddToScriptManagedEntArray( level.cloakedDronesManagedEntArrayID, cloakedDrone )
}

function GetNPCCloakedDrones()
{
	return GetScriptManagedEntArray( level.cloakedDronesManagedEntArrayID )
}
Globalize( GetNPCCloakedDrones )

function RemoveLeftoverCloakedDrones()
{
	local droneArray = GetNPCCloakedDrones()
	foreach( cloakedDrone in droneArray )
	{
		thread CloakedDroneWarpOutAndDestroy( cloakedDrone )
	}
}
Globalize( RemoveLeftoverCloakedDrones )

function CloakedDroneWarpOutAndDestroy( cloakedDrone )
{
	cloakedDrone.EndSignal( "OnDestroy" )
	cloakedDrone.EndSignal( "OnDeath" )
	cloakedDrone.SetInvulnerable()

	local scoreVal = GetCoopScoreValue( cloakedDrone )
	level.nv.TDCurrentTeamScore += scoreVal
	level.nv.TDStoredTeamScore += scoreVal
	UpdatePlayerKillHistory( null, cloakedDrone )

	CloakedDroneWarpOut( cloakedDrone, cloakedDrone.GetOrigin() )
	local mover = cloakedDrone.GetParent()

	if ( IsValid( mover ) )
		mover.Destroy()	// this destroys the cloackDrone propDynamic as well.
}

/************************************************************************************************\

 ######  ##        #######     ###    ##    ## #### ##    ##  ######
##    ## ##       ##     ##   ## ##   ##   ##   ##  ###   ## ##    ##
##       ##       ##     ##  ##   ##  ##  ##    ##  ####  ## ##
##       ##       ##     ## ##     ## #####     ##  ## ## ## ##   ####
##       ##       ##     ## ######### ##  ##    ##  ##  #### ##    ##
##    ## ##       ##     ## ##     ## ##   ##   ##  ##   ### ##    ##
 ######  ########  #######  ##     ## ##    ## #### ##    ##  ######

\************************************************************************************************/
//HACK - this should probably move into code
function CloakedDroneCloakThink( cloakedDrone )
{
	cloakedDrone.EndSignal( "OnDestroy" )
	cloakedDrone.EndSignal( "OnDeath" )
	cloakedDrone.EndSignal( "DroneCrashing" )
	cloakedDrone.EndSignal( "DroneCleanup" )

	wait 2	// wait a few seconds since it would start cloaking before picking an npc to follow
			// some npcs might not be picked since they where already cloaked by accident.

	local offset = Vector( 0,0,-350 )
	local radius = 400
	local droneTeam = cloakedDrone.GetTeam()

	cloakedDrone.s.cloakList <- {}

	OnThreadEnd(
		function() : ( cloakedDrone )
		{
			local cloakList = clone cloakedDrone.s.cloakList
			foreach ( guy, value in cloakList )
			{
				if ( !IsAlive( guy ) )
					continue

				CloakedDroneDeCloaksGuy( cloakedDrone, guy )
			}
		}
	)

	while( 1 )
	{
		local origin = cloakedDrone.GetOrigin() + offset
		local ai = GetNPCArrayEx( "any", cloakedDrone.GetTeam(), origin, radius )
		local index = 0

		local waitTime = 1.5
		local startTime = Time()

		local cloakList = cloakedDrone.s.cloakList
		local decloakList = clone cloakList

		foreach( guy in ai )
		{
			//only do 5 distanceSqr / cansee checks per frame
			if ( index++ > 5 )
			{
				wait 0.1
				index = 0
				origin = cloakedDrone.GetOrigin() + offset
			}

			if ( !IsAlive( guy ) )
				continue

			if ( guy.GetTeam() != droneTeam )
				continue

			if ( !( guy.IsTitan() || guy.IsSpectre() || guy.IsSoldier() ) )
				continue

			if ( IsSniperSpectre( guy ) )
				continue

			if ( IsTitanBeingRodeod( guy ) )
				continue

			if ( cloakedDrone.CanSee( guy ) && cloakedDrone.s.isHidden == false )
			{
				if ( guy in decloakList )
					delete decloakList[ guy ]	// if guy is in the decloakList remove him because he should be cloaked

				if ( guy in cloakList )
					continue

				if ( IsCloaked( guy ) )	// cloaked by another cloakedDrone
					continue

				cloakList[ guy ] <- true
				CloakedDroneCloaksGuy( cloakedDrone, guy )
			}
		}

		foreach( guy, value in decloakList )
		{
			// any guys still in the decloakList shouldn't be decloaked ... if alive.
			Assert( guy in cloakList )
			delete cloakList[ guy ]

			if ( IsAlive( guy ) )
				CloakedDroneDeCloaksGuy( cloakedDrone, guy )
		}

		local endTime = Time()
		local elapsedTime = endTime - startTime
		if ( elapsedTime < waitTime )
			wait waitTime - elapsedTime

		//DebugDrawSphere( origin, radius, 50, 100, 255, 1.5 )
	}
}

function CloakedDroneCloaksGuy( cloakedDrone, guy )
{
	guy.SetCloakDuration( 2.0, -1, 0 )
	EmitSoundOnEntity( guy, CLOAKED_DRONE_CLOAK_START_SFX )
	EmitSoundOnEntity( guy, CLOAKED_DRONE_CLOAK_LOOP_SFX )
	guy.Minimap_Hide( TEAM_IMC, null )
	guy.Minimap_Hide( TEAM_MILITIA, null )
}

function CloakedDroneDeCloaksGuy( cloakedDrone, guy )
{
	guy.SetCloakDuration( 0, 0, 1.5 )
	StopSoundOnEntity( guy, CLOAKED_DRONE_CLOAK_LOOP_SFX )
	guy.Minimap_AlwaysShow( TEAM_IMC, null )
	guy.Minimap_AlwaysShow( TEAM_MILITIA, null )
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
const VALIDPATHFRAC = 0.99

function CloakedDronePathThink( cloakedDrone )
{
	local mover = cloakedDrone.GetParent()
	Assert( mover != null )

	mover.EndSignal( "OnDestroy" )
	cloakedDrone.EndSignal( "OnDestroy" )
	mover.EndSignal( "OnDeath" )
	cloakedDrone.EndSignal( "OnDeath" )
	mover.EndSignal( "DroneCrashing" )
	cloakedDrone.EndSignal( "DroneCrashing" )
	cloakedDrone.EndSignal( "DroneCleanup" )

	local goalNPC = null
	local previousNPC = null
	local spawnOrigin = cloakedDrone.GetOrigin()
	local lastOrigin = cloakedDrone.GetOrigin()
	local stuckDistSqr = 64*64
	local targetLostTime = Time()
	local claimedGuys = []

	while( 1 )
	{
		while( goalNPC == null )
		{
			wait 1.0
			local testArray = GetNPCArrayEx( "any", cloakedDrone.GetTeam(), Vector(0,0,0), -1 )

			// remove guys already being followed by an cloakedDrone
			// or in other ways not suitable
			local NPCs = []
			foreach ( guy in testArray )
			{
				if ( !IsAlive( guy ) )
					continue

				if ( !( guy.IsTitan() || guy.IsSpectre() || guy.IsSoldier() ) )
					continue

				if ( IsSniperSpectre( guy ) )
					continue

				if ( IsSuicideSpectre( guy ) )
					continue

				if ( guy == previousNPC )
					continue

				if ( guy.ContextAction_IsBusy() )
					continue

				if ( guy.GetParent() != null )
					continue

				if ( IsCloaked( guy ) )
					continue

				if ( IsSquadCenterClose( guy ) == false )
					continue

				if ( "cloakedDrone" in guy.s && IsAlive( guy.s.cloakedDrone ) )
					continue

				if ( CloakedDroneIsSquadClaimed( guy.kv.squadname ) )
					continue

				if ( IsTitanBeingRodeod( guy ) )
					continue

				NPCs.append( guy )
			}

			if ( NPCs.len() == 0 )
			{
				previousNPC = null

				if ( Time() - targetLostTime > 10 )
				{
					// couldn't find anything to cloak for 10 seconds so we'll warp out until we find something
					if ( cloakedDrone.s.isHidden == false )
						CloakedDroneWarpOut( cloakedDrone, spawnOrigin )
				}
				continue
			}

			goalNPC = FindBestCloakTarget( NPCs, cloakedDrone.GetOrigin() )
			Assert( goalNPC )
		}

		// thread DrawSelectedEnt( cloakedDrone, goalNPC )
		CloakedDroneClaimSquad( cloakedDrone, goalNPC.kv.squadname )

		waitthread CloakedDronePathFollowNPC( cloakedDrone, goalNPC )

		CloakedDroneReleaseSquad( cloakedDrone )

		previousNPC = goalNPC
		goalNPC = null
		targetLostTime = Time()

		local distSqr = DistanceSqr( lastOrigin, mover.GetOrigin() )
		if ( distSqr < stuckDistSqr )
			CloakedDroneWarpOut( cloakedDrone, spawnOrigin )

		lastOrigin = cloakedDrone.GetOrigin()
	}
}

function CloakedDroneClaimSquad( cloakedDrone, squadname )
{
	if ( GetNPCSquadSize( squadname ) )
		level.cloakedDroneClaimedSquadList[ cloakedDrone ] <- squadname
}

function CloakedDroneReleaseSquad( cloakedDrone )
{
	if ( cloakedDrone in level.cloakedDroneClaimedSquadList )
		delete level.cloakedDroneClaimedSquadList[ cloakedDrone ]
}

function CloakedDroneIsSquadClaimed( squadname )
{
	local cloneTable = clone level.cloakedDroneClaimedSquadList
	foreach( cloakedDrone, squad in cloneTable )
	{
		if ( !IsAlive( cloakedDrone ) )
			delete level.cloakedDroneClaimedSquadList[ cloakedDrone ]
		else if ( squad == squadname )
			return true
	}
	return false
}

function CloakedDronePathFollowNPC( cloakedDrone, goalNPC )
{
	local mover = cloakedDrone.GetParent()
	Assert( mover != null )

	mover.EndSignal( "OnDestroy" )
	cloakedDrone.EndSignal( "OnDestroy" )
	mover.EndSignal( "OnDeath" )
	cloakedDrone.EndSignal( "OnDeath" )
	mover.EndSignal( "DroneCrashing" )
	cloakedDrone.EndSignal( "DroneCrashing" )
	goalNPC.EndSignal( "OnDeath" )
	goalNPC.EndSignal( "OnDestroy" )

	if ( !( "cloakedDrone" in goalNPC.s ) )
		goalNPC.s.cloakedDrone <- null
	goalNPC.s.cloakedDrone = cloakedDrone

	OnThreadEnd(
		function() : ( goalNPC )
		{
			if ( IsAlive( goalNPC ) )
				goalNPC.s.cloakedDrone = null
		}
	)

	local droneTeam = cloakedDrone.GetTeam()

	local maxs = Vector( 64, 64, 53.5 )//bigger than model to compensate for large effect
	local mins = Vector( -64, -64, -64 )
	local mask = cloakedDrone.GetPhysicsSolidMask()

	local defaultHeight 			= 300
	local traceHeightsLow			= [ -75, -150 ]
	local traceHeightsHigh			= [ 150, 300, 800, 1500 ]

	local waitTime 	= 0.25

	local path = {}
	path.start 		<- null
	path.goal 		<- null
	path.goalValid 	<- false
	path.lastHeight <- defaultHeight

	while( goalNPC.GetTeam() == droneTeam )
	{
		if ( IsTitanBeingRodeod( goalNPC ) )
			return

		local startTime = Time()
		path.goalValid 	= false

		CloakedDroneFindPathDefault( path, defaultHeight, mins, maxs, mover, cloakedDrone, goalNPC, mask )

		//find a new path if necessary
		if ( !path.goalValid )
		{
			//lets check some heights and see if any are valid
			CloakedDroneFindPathHorizontal( path, traceHeightsLow, defaultHeight, mins, maxs, mover, cloakedDrone, goalNPC, mask )

			if ( !path.goalValid )
			{
				//OK so no way to directly go to those heights - lets see if we can move vertically down,
				CloakedDroneFindPathVertical( path, traceHeightsLow, defaultHeight, mins, maxs, mover, cloakedDrone, goalNPC, mask )

				if ( !path.goalValid )
				{
					//still no good...lets check up
					CloakedDroneFindPathHorizontal( path, traceHeightsHigh, defaultHeight, mins, maxs, mover, cloakedDrone, goalNPC, mask )

					if ( !path.goalValid )
					{
						//no direct shots up - lets try moving vertically up first
						CloakedDroneFindPathVertical( path, traceHeightsHigh, defaultHeight, mins, maxs, mover, cloakedDrone, goalNPC, mask )
					}
				}
			}
		}

		// if we can't find a valid path find a new goal
		if ( !path.goalValid )
			break

		if ( cloakedDrone.s.isHidden == true )
			CloakedDroneWarpIn( cloakedDrone, cloakedDrone.GetOrigin() )

		local vec 		= path.goal - path.start
		local angles 	= VectorToAngles( vec )
		mover.SetDesiredYaw( angles.y )
		mover.SetMoveToPosition( path.goal )

		//DebugDrawLine( path.start + Vector(0,0,1), path.goal + Vector(0,0,1), 0, 255, 0, true, 1.0 )

		local endTime = Time()
		local elapsedTime = endTime - startTime
		if ( elapsedTime < waitTime )
			wait waitTime - elapsedTime
	}
}

function IsTitanBeingRodeod( npc )
{
	if ( !npc.IsTitan() )
		return false

	local soul = npc.GetTitanSoul()
	if ( !IsValid( soul ) )
		return false

	local rider = soul.GetRiderEnt()
	if ( !IsAlive( rider ) )
		return false

	if ( !rider.IsPlayer() )
		return false

	return true
}

function CloakedDroneFindPathDefault( path, defaultHeight, mins, maxs, mover, cloakedDrone, goalNPC, mask )
{
	local offset 	= Vector( 0, 0, defaultHeight )
	path.start 		= mover.GetOrigin()
	path.goal 		= GetCloakTargetOrigin( goalNPC ) + offset

	//find out if we can get there using the default height
	local result = TraceHull( path.start, path.goal, mins, maxs, cloakedDrone, mask, TRACE_COLLISION_GROUP_NONE )
	//DebugDrawLine( path.start, path.goal, 50, 0, 0, true, 1.0 )
	if ( result.fraction >= VALIDPATHFRAC )
	{
		path.lastHeight = defaultHeight
		path.goalValid 	= true
	}

	return path.goalValid
}

function CloakedDroneFindPathHorizontal( path, traceHeights, defaultHeight, mins, maxs, mover, cloakedDrone, goalNPC, mask )
{
	wait 0.1

	local offset, result, testHeight

	//slight optimization... recheck if the last time was also not the default height
	if ( path.lastHeight != defaultHeight )
	{
		offset 			= Vector( 0, 0, defaultHeight + path.lastHeight )
		path.start 		= mover.GetOrigin()
		path.goal 		= GetCloakTargetOrigin( goalNPC ) + offset

		result = TraceHull( path.start, path.goal, mins, maxs, cloakedDrone, mask, TRACE_COLLISION_GROUP_NONE )
		//DebugDrawLine( path.start, path.goal, 0, 255, 0, true, 1.0 )
		if ( result.fraction >= VALIDPATHFRAC )
		{
			path.goalValid = true
			return path.goalValid
		}
	}

	for ( local i = 0; i < traceHeights.len(); i++ )
	{
		testHeight = traceHeights[ i ]
		if ( path.lastHeight == testHeight )
			continue

		wait 0.1

		offset 			= Vector( 0, 0, defaultHeight + testHeight )
		path.start 		= mover.GetOrigin()
		path.goal 		= GetCloakTargetOrigin( goalNPC ) + offset

		result = TraceHull( path.start, path.goal, mins, maxs, cloakedDrone, mask, TRACE_COLLISION_GROUP_NONE )
		if ( result.fraction < VALIDPATHFRAC )
		{
			//DebugDrawLine( path.start, path.goal, 200, 0, 0, true, 3.0 )
			continue
		}

		//DebugDrawLine( path.start, path.goal, 0, 255, 0, true, 3.0 )

		path.lastHeight = testHeight
		path.goalValid = true
		break
	}

	return path.goalValid
}

function CloakedDroneFindPathVertical( path, traceHeights, defaultHeight, mins, maxs, mover, cloakedDrone, goalNPC, mask )
{
	local offset, result, origin, testHeight

	for ( local i = 0; i < traceHeights.len(); i++ )
	{
		wait 0.1

		testHeight 		= traceHeights[ i ]
		origin 			= mover.GetOrigin()
		offset 			= Vector( 0, 0, defaultHeight + testHeight )
		path.start 		= Vector( origin.x, origin.y, defaultHeight + testHeight )
		path.goal 		= GetCloakTargetOrigin( goalNPC ) + offset

		result = TraceHull( path.start, path.goal, mins, maxs, cloakedDrone, mask, TRACE_COLLISION_GROUP_NONE )
		//DebugDrawLine( path.start, path.goal, 50, 50, 100, true, 1.0 )
		if ( result.fraction < VALIDPATHFRAC )
			continue

		//ok so it's valid - lets see if we can move to it from where we are
		wait 0.1

		path.goal 	= Vector( path.start.x, path.start.y, path.start.z )
		path.start 	= mover.GetOrigin()

		result = TraceHull( path.start, path.goal, mins, maxs, cloakedDrone, mask, TRACE_COLLISION_GROUP_NONE )
		//DebugDrawLine( path.start, path.goal, 255, 255, 0, true, 1.0 )
		if ( result.fraction < VALIDPATHFRAC )
			continue

		path.lastHeight = testHeight
		path.goalValid = true
		break
	}

	return path.goalValid
}

function CloakedDroneWarpOut( cloakedDrone, origin )
{
	local mover = cloakedDrone.GetParent()
	Assert( mover != null )

	if ( cloakedDrone.s.isHidden == false )
	{
		// only do this if we are not already hidden
		FadeOutSoundOnEntity( cloakedDrone, CLOAKED_DRONE_LOOPING_SFX, 0.5 )
		FadeOutSoundOnEntity( cloakedDrone, CLOAKED_DRONE_HOVER_LOOP_SFX, 0.5 )
		EmitSoundOnEntity( cloakedDrone, CLOAKED_DRONE_WARP_OUT_SFX )

		cloakedDrone.s.fx.Fire( "StopPlayEndCap" )
		cloakedDrone.SetTitle( "" )
		cloakedDrone.s.isHidden = true
		cloakedDrone.NotSolid()
		cloakedDrone.Minimap_Hide( TEAM_IMC, null )
		cloakedDrone.Minimap_Hide( TEAM_MILITIA, null )
		cloakedDrone.SetNoTarget( true )
		// let the beam fx end

		if ( "smokeEffect" in cloakedDrone.s )
		{
			cloakedDrone.s.smokeEffect.Kill()
			delete cloakedDrone.s.smokeEffect
		}

		wait 0.3	// wait a bit before hidding the done so that the fx looks better
		cloakedDrone.Hide()
		SetCustomSmartAmmoTarget( cloakedDrone, false )
	}

	wait 2.0

	mover.SetMoveToPosition( origin )
	mover.SetOrigin( origin )
}

function CloakedDroneWarpIn( cloakedDrone, origin )
{
	local mover = cloakedDrone.GetParent()
	Assert( mover != null )

	mover.SetMoveToPosition( origin )
	mover.SetOrigin( origin )

	EmitSoundOnEntity( cloakedDrone, CLOAKED_DRONE_HOVER_LOOP_SFX )
	EmitSoundOnEntity( cloakedDrone, CLOAKED_DRONE_LOOPING_SFX )
	EmitSoundOnEntity( cloakedDrone, CLOAKED_DRONE_WARP_IN_SFX )

	cloakedDrone.Show()
	cloakedDrone.s.fx.Fire( "start" )
	cloakedDrone.SetTitle( "#NPC_CLOAK_DRONE" )
	cloakedDrone.s.isHidden = false
	cloakedDrone.Solid()
	cloakedDrone.Minimap_AlwaysShow( TEAM_IMC, null )
	cloakedDrone.Minimap_AlwaysShow( TEAM_MILITIA, null )
	cloakedDrone.SetNoTarget( false )

	SetCustomSmartAmmoTarget( cloakedDrone, true )
}


function CreateDroneCloakBeam( cloakedDrone )
{
	local fx = PlayLoopFXOnEntity( FX_DRONE_CLOAK_BEAM, cloakedDrone, null, null, Vector( 90, 0, 0 ) )//, visibilityFlagOverride = null, visibilityFlagEntOverride = null )
	return fx
}

function FindBestCloakTarget( npcArray, origin )
{
	local selectedNPC = null
	local maxDist = 5000 * 5000
	local minDist = 1300 * 1300
	local highestScore = null

	foreach( npc in npcArray )
	{
		local score = 0
		local distToGenerator = DistanceSqr( npc.GetOrigin(), level.TowerDefenseGenLocation.origin )
		if ( distToGenerator > minDist )
		{
			// only give dist bonus if we aren't to close to the generator.
			local dist = DistanceSqr( npc.GetOrigin(), origin )
			score = GraphCapped( dist, minDist, maxDist, 1, 0 )
		}

		if ( npc.IsTitan() )
		{
			score += 0.3
			if ( IsEMPTitan( npc ) )
				score -= 0.1
		 	if ( IsMortarTitan( npc ) )
				score -= 0.2
//			if ( IsNukeTitan( npc ) )
//				score += 0.1
		}
		if ( highestScore == null || score > highestScore )
		{
			highestScore = score
			selectedNPC = npc
		}
	}

	return selectedNPC
}

function GetCloakTargetOrigin( npc )
{
	// returns the center of squad if the npc is in one
	// else returns a good spot to cloak a titan

	local origin

	if ( GetNPCSquadSize( npc.kv.squadname ) == 0 )
		origin = npc.GetOrigin() + npc.GetNPCVelocity()
	else
		origin = npc.GetSquadCentroid()

	Assert( origin.x < ( 16384 * 100 ) );

	// defensive hack
	if ( origin.x > ( 16384 * 100 ) )
		origin = npc.GetOrigin()

	return origin
}

function IsSquadCenterClose( npc, dist = 256 )
{
	// return true if there is no squad
	if ( GetNPCSquadSize( npc.kv.squadname ) == 0 )
		return true

	// return true if the squad isn't too spread out.
	if ( DistanceSqr( npc.GetSquadCentroid(), npc.GetOrigin() ) <= ( dist * dist ) )
		return true

	return false
}

// DEV
RegisterSignal( "DrawSelectedEnt" )
function DrawSelectedEnt( cloakedDrone, npc )
{
	cloakedDrone.EndSignal( "OnDeath" )
	cloakedDrone.EndSignal( "OnDestroy" )
	npc.EndSignal( "OnDeath" )
	npc.EndSignal( "OnDestroy" )

	cloakedDrone.Signal( "DrawSelectedEnt" )
	cloakedDrone.EndSignal( "DrawSelectedEnt" )

	while( true )
	{
		DebugDrawLine( npc.GetOrigin(), cloakedDrone.GetOrigin(), 255,0,0,true,0.1)
		wait 0.1
	}
}
