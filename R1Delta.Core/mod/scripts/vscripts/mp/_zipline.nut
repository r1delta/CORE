const ZIPLINE_IDLE_ANIM = "pt_zipline_slide_idle"

function main()
{
	if ( reloadingScripts )
		return

	RegisterSignal( "deploy" )
	RegisterSignal( "stop_deploy" )
	RegisterSignal( "npc_deployed" )

	IncludeFile( "mp/_vehicle_dropship_new" )

	level.MIN_ZIPLINE_LAND_DIST_SQRD <- 128 * 128
	level.MIN_ZIPLINE_HOOK_DIST_SQRD <- 256 * 256
	level._info_spawnpoint_dropships <- {}
	AddSpawnCallback( "info_spawnpoint_dropship", 		AddToSpawnpointDropships )

	Globalize( GuyZiplinesToGround )
	Globalize( PlayerZiplinesToGround )
	Globalize( GetZiplineSpawns )
	Globalize( GetHookOriginFromNode )
	Globalize( ZiplineInit )

	Globalize( CodeCallback_ZiplineMount );
	Globalize( CodeCallback_ZiplineStart );
	Globalize( CodeCallback_ZiplineStop );

	file.zipLineLandingAnimations <-
	[
		"pt_zipline_dismount_standF",
		"pt_zipline_dismount_crouchF",
		"pt_zipline_dismount_crouch180",
		"pt_zipline_dismount_breakright",
		"pt_zipline_land"
		"pt_zipline_land"
		"pt_zipline_land"
		"pt_zipline_land"
		"pt_zipline_land"
		"pt_zipline_land"
	]

	file.zipLinePlayerLandingAnimations <-
	[
		"pt_zipline_dismount_standF"
	]

	file.zipLineReadyAnimations <-
	[
		"pt_zipline_ready_idleA",
		"pt_zipline_ready_idleB"
	]

	PrecacheParticleSystem( "hmn_mcorps_jump_jet_wallrun_full" )
	PrecacheParticleSystem( "hmn_imc_jump_jet_wallrun_full" )
	PrecacheParticleSystem( "P_Zipline_hld_1" )

}

function AddToSpawnpointDropships( self )
{
	level._info_spawnpoint_dropships[ self ] <- self
}

function GetZiplineSpawns()
{
	local targets = []
	foreach ( ent in clone level._info_spawnpoint_dropships )
	{
		if ( IsValid( ent ) )
		{
			targets.append( ent )
			continue
		}

		delete level._info_spawnpoint_dropships[ ent ]
	}

	return targets
}


function GuyZiplinesToGround( guy, table )
{
	OnThreadEnd(
		function() : ( guy )
		{
			if ( IsValid( guy ) )
				guy.SetEfficientMode( false )
		}
	)

	local ship		= table.ship
	local dropNode 	= GetDropNode( table )

	// ship didn't find a drop spot
	if ( dropNode == null )
		WaitForever()


	//DebugDrawLine( guy.GetOrigin(), GetNodePos( dropNode, 0 ), 255, 0, 0, true, 8.0 )

	local attachOrigin = ship.GetAttachmentOrigin( table.attachIndex )
	local nodeOrigin = GetNodePos( dropNode, HULL_HUMAN )
	local hookOrigin = GetHookOriginFromNode( guy.GetOrigin(), nodeOrigin, attachOrigin )

	// couldn't find a place to hook it? This needs to be tested on precompile
	if ( !hookOrigin )
	{
		printt( "WARNING! Bad zipline dropship position!" )
		WaitForever()
	}

	table.hookOrigin <- hookOrigin

	// Track the movement of the script mover that moves the guy to the ground
	local e = {}

	waitthread GuyRidesZiplineToGround( guy, table, e, dropNode )

	//DebugDrawLine( guy.GetOrigin(), GetNodePos( dropNode, 0 ), 255, 0, 135, true, 5.0 )

	if ( !( "forward" in table ) )
	{
		// the sequence ended before the guy reached the ground
		local start = guy.GetOrigin()
		// this needs functionification
		local end = table.hookOrigin + Vector( 0,0,-80 )
		local result = TraceLine( start, end, guy )
		local angles = guy.GetAngles()
		table.forward <- angles.AnglesToForward()
		table.origin <- result.endPos
	}

	// the guy detaches and falls to the ground
	local landingAnim = Random( file.zipLineLandingAnimations )
	//DrawArrow( guy.GetOrigin(), guy.GetAngles(), 5.0, 80 )

	if ( !guy.IsInterruptable() )
		return

	guy.Anim_ScriptedPlay( landingAnim )
	guy.Anim_EnablePlanting()

	ShowName( guy )

	local vec = e.currentOrigin - e.oldOrigin

	guy.SetVelocity( vec * 15 )

	thread AnimDoneStuckInSolidFailSafe( guy )
}

function AnimDoneStuckInSolidFailSafe( guy )
{
	guy.EndSignal( "OnDeath" )
	guy.WaitSignal( "OnAnimationDone" )
	if ( EntityInSolid( guy ) )
	{
		local index = GetNearestNodeToPos( guy.GetOrigin() )
		if ( index >= 0 )
		{
			local origin = GetNodePos( index, 0 )
			guy.SetOrigin( origin )
			printt( guy + " was in solid, teleported to node " + index )
		}
	}
}

function PlayerZiplinesToGround( sequenceDeploy, player, ref )
{
	local ship		= ref

	local table 	= {}
	table.ship 			<- ref
	table.shipAttach 	<- sequenceDeploy.attachment
	table.attachIndex	<- table.ship.LookupAttachment( table.shipAttach )
	table.deployAnim	<- sequenceDeploy.thirdPersonAnim

	local dropNode 	= GetDropNode( table )

	// ship didn't find a drop spot
	if ( dropNode == null )
		WaitForever()

	local attachOrigin = ship.GetAttachmentOrigin( table.attachIndex )
	local nodeOrigin = GetNodePos( dropNode, HULL_HUMAN )
	local hookOrigin = GetHookOriginFromNode( player.GetOrigin(), nodeOrigin, attachOrigin )

	// couldn't find a place to hook it? This needs to be tested on precompile
	if ( !hookOrigin )
		WaitForever()

	table.hookOrigin <- hookOrigin

	// Track the movement of the script mover that moves the guy to the ground
	local e = {}
	waitthread PlayerRidesZiplineToGround( sequenceDeploy, player, table, e )

	if ( !( "forward" in table ) )
	{
		// the sequence ended before the guy reached the ground
		local start = guy.GetOrigin()
		// this needs functionification
		local end = table.hookOrigin + Vector( 0,0,-80 )
		local result = TraceLine( start, end, guy )
		local angles = player.GetAngles()
		table.forward <- angles.AnglesToForward()
		table.origin <- result.endPos
	}

	// the guy detaches and falls to the ground
	local landingAnim = Random( file.zipLinePlayerLandingAnimations )
	player.Anim_PlayWithRefPoint( landingAnim, table.origin, player.GetAngles(), 0.5 )

	player.WaittillAnimDone()

	UnStuck( player, player.GetOrigin() + Vector( 0,0,10 ) )
}

function TrackMoverDirection( mover, e )
{
	mover.EndSignal( "OnDestroy" )
	// track the way the mover movers, so we can do the
	// correct velocity on the falling guy
	local origin = mover.GetOrigin()
	e.oldOrigin <- origin
	e.currentOrigin <- origin

	for ( ;; )
	{
		wait 0
		e.oldOrigin = e.currentOrigin
		e.currentOrigin = mover.GetOrigin()
	}
}

function GuyRidesZiplineToGround( guy, zipline, e, dropNode )
{
	local mover = CreateScriptMover( guy )
	mover.EndSignal( "OnDestroy" )

	thread TrackMoverDirection( mover, e )

	OnThreadEnd(
		function() : ( mover, zipline, guy )
		{
			thread ZiplineRetracts( zipline )

			if ( IsValid( guy ) )
			{
				guy.ClearParent()
				StopSoundOnEntity( guy, "3p_zipline_loop" )
				EmitSoundOnEntity( guy, "3p_zipline_detach" )
			}


			if ( IsValid( mover ) )
				mover.Kill()
		}
	)


	local rideDist = Distance( guy.GetOrigin(), zipline.hookOrigin )

	// how long it takes the zipline to travel 1000 units
	zipline.pinTime <- Graph( rideDist, 0, 1000, 0, 0.4 )

	// how long it takes the zipline to retract,
	zipline.retractTime <- Graph( rideDist, 0, 1000, 0, 0.5 )

	// how long it takes the rider to ride 1000 units
	local rideTime = Graph( rideDist, 0, 1000, 0, 2.5 )


	// orient the script_mover in the direction its going
	local angles = guy.GetAngles()
	local forward = angles.AnglesToForward()
	local right = angles.AnglesToRight()

	CreateRopeEntities( zipline )

	local zipAttachOrigin = zipline.ship.GetAttachmentOrigin( zipline.attachIndex )
	zipline.end.SetOrigin( zipAttachOrigin )

	zipline.start.SetParent( zipline.ship, zipline.shipAttach )
	zipline.mid.SetParent( zipline.ship, zipline.shipAttach )

	// now that the origin is set we can spawn the zipline, otherwise we
	// see the zipline lerp in
	SpawnZiplineEntities( zipline )


	// the zipline shoots out
	zipline.end.MoveTo( zipline.hookOrigin, zipline.pinTime )
	EmitSoundAtPosition( zipAttachOrigin, "dropship_zipline_zipfire" )
	delaythread( zipline.pinTime ) ZiplineMoveCleanup( zipline )

//	wait zipline.pinTime * 0.37
	wait zipline.pinTime
	EmitSoundAtPosition( zipline.hookOrigin, "dropship_zipline_impact" )

	zipline.mid.SetParent( mover, "ref", false )
	thread MoverMovesToGround( zipline, mover, rideTime )
	// the script_mover heads down the zipline
	//mover.MoveTo( zipline.landOrigin, rideTime, rideTime * 0.5, rideTime * 0.1 )

	if ( !guy.IsInterruptable() )
		return

	guy.SetParent( mover, "ref", false, 0.0 )

	EmitSoundOnEntity( guy, "3p_zipline_attach" )
	waitthread PlayAnim( guy, "pt_zipline_ready2slide", mover )
	EmitSoundOnEntity( guy, "3p_zipline_loop" )

	if ( !guy.IsInterruptable() )
		return
	thread PlayAnim( guy, ZIPLINE_IDLE_ANIM, mover, "ref" )

	//thread ZiplineAutoClipsToGeo( zipline, mover )

	//wait 0.4 // some time to clear the lip

	local nodeOrigin = GetNodePos( dropNode, 0 )
	//DebugDrawLine( guy.GetOrigin(), nodeOrigin, 200, 255, 50, true, 8.0 )

	local rideDist = Distance( guy.GetOrigin(), nodeOrigin )
	rideDist -= 100 // for animation at end
	if ( rideDist < 0 )
		rideDist = 0
	local rideTime = Graph( rideDist, 0, 100, 0, 0.15 )
/*
	printt( "ride time " + rideTime )
	local endTime = Time() + rideTime
	for ( ;; )
	{
		if ( Time() >= endTime )
			return

		DebugDrawLine( guy.GetOrigin(), nodeOrigin, 255, 0, 0, true, 0.15 )
		DebugDrawText( nodeOrigin, ( endTime - Time() ) + "", true, 0.15 )
		wait 0
	}
*/
	wait rideTime

	thread ZiplineStuckFailsafe( guy, nodeOrigin )
}

function ZiplineStuckFailsafe( guy, nodeOrigin )
{
	TimeOut( 15.0 )

	guy.EndSignal( "OnDeath" )

	guy.WaitSignal( "OnFailedToPath" )

	guy.SetOrigin( nodeOrigin )
	printt( "Warning: AI Path failsafe at " + nodeOrigin )
}

function PlayerRidesZiplineToGround( sequenceDeploy, player, zipline, e )
{
	local mover = CreateScriptMover( player )
	mover.EndSignal( "OnDestroy" )

	thread TrackMoverDirection( mover, e )

	OnThreadEnd(
		function() : ( mover, zipline, player )
		{
			thread ZiplineRetracts( zipline )

			if ( IsValid( player ) )
			{
				player.ClearParent()


				StopSoundOnEntity( player, "player_zipline_loop" )
				StopSoundOnEntity( player, "3p_zipline_loop" )
				EmitDifferentSoundsOnEntityForPlayerAndWorld( "player_zipline_detach", "3p_zipline_detach", player, player )
			}


			if ( IsValid( mover ) )
				mover.Kill()
		}
	)

	local rideDist = Distance( player.GetOrigin(), zipline.hookOrigin )

	// how long it takes the zipline to travel 1000 units
	zipline.pinTime <- Graph( rideDist, 0, 1000, 0, 0.4 )

	// how long it takes the zipline to retract,
	zipline.retractTime <- Graph( rideDist, 0, 1000, 0, 0.5 )

	// how long it takes the rider to ride 1000 units
	local rideTime = Graph( rideDist, 0, 1000, 0, 2.5 )

	// orient the script_mover in the direction its going
	local angles = player.GetAngles()
	local forward = angles.AnglesToForward()
	local right = angles.AnglesToRight()

	CreateRopeEntities( zipline )

	local zipAttachOrigin = zipline.ship.GetAttachmentOrigin( zipline.attachIndex )
	zipline.end.SetOrigin( zipAttachOrigin )

	zipline.start.SetParent( zipline.ship, zipline.shipAttach )
	zipline.mid.SetParent( zipline.ship, zipline.shipAttach )

	// now that the origin is set we can spawn the zipline, otherwise we
	// see the zipline lerp in
	SpawnZiplineEntities( zipline )

	// the zipline shoots out
	zipline.end.MoveTo( zipline.hookOrigin, zipline.pinTime )
	EmitSoundAtPosition( zipAttachOrigin, "dropship_zipline_zipfire" )
	delaythread( zipline.pinTime ) ZiplineMoveCleanup( zipline )

	wait zipline.pinTime
	EmitSoundAtPosition( zipline.hookOrigin, "dropship_zipline_impact" )

	zipline.mid.SetParent( mover, "ref", false )
	thread MoverMovesToGround( zipline, mover, rideTime )

	EmitDifferentSoundsOnEntityForPlayerAndWorld( "player_zipline_attach", "3p_zipline_attach", player, player )
	//player.SetParent( mover, "ref", false, 0.0 )
	local sequence = CreateFirstPersonSequence()
	//sequence.firstPersonAnim 	= "something"
	sequence.thirdPersonAnim 	= "pt_zipline_ready2slide"
	sequence.attachment 		= "ref"
	sequence.blendTime			= 0.2
	sequence.viewConeFunction 	= sequenceDeploy.viewConeFunction

	waitthread FirstPersonSequence( sequence, player, mover )
	EmitDifferentSoundsOnEntityForPlayerAndWorld( "player_zipline_loop", "3p_zipline_loop", player, player )

	local sequence = CreateFirstPersonSequence()
	//sequence.firstPersonAnim 	= "something"
	sequence.thirdPersonAnim 	= ZIPLINE_IDLE_ANIM
	sequence.attachment 		= "ref"
	sequence.blendTime			= 0.2
	sequence.viewConeFunction 	= sequenceDeploy.viewConeFunction

	thread FirstPersonSequence( sequence, player, mover )

	//thread ZiplineAutoClipsToGeo( zipline, mover )

	WaitUntilZiplinerNearsGround( player, zipline )
}

/*
function ZiplineAutoClipsToGeo( zipline, mover )
{
	mover.EndSignal( "OnDestroy" )
	zipline.ship.EndSignal( "OnDestroy" )


	local start, end, result
	for ( ;; )
	{
		start = zipline.start.GetOrigin()
		end = zipline.mid.GetOrigin()
		result = TraceLine( start, end )
		if ( result.fraction < 1.0 )
		{
			mover.Kill()
		}

		start = zipline.mid.GetOrigin()
		end = zipline.end.GetOrigin()
		result = TraceLine( start, end )
		if ( result.fraction < 1.0 )
		{
			zipline.end.SetOrigin( result.endPos )
		}

		wait 0.35
	}
}
*/

function ZiplineMoveCleanup( zipline )
{
	// work around for moveto bug
	if ( IsValid( zipline.end ) )
	{
		zipline.end.SetOrigin( zipline.hookOrigin )
	}
}

function MoverMovesToGround( zipline, mover, timeTotal )
{
	// this handles the start point moving.
	mover.EndSignal( "OnDestroy" )
	zipline.ship.EndSignal( "OnDestroy" )

	local origin = zipline.ship.GetAttachmentOrigin( zipline.attachIndex )
	local angles = zipline.ship.GetAttachmentAngles( zipline.attachIndex )
	mover.SetOrigin( origin )
	mover.SetAngles( angles )

	local start = zipline.start.GetOrigin()
	local end = zipline.hookOrigin + Vector( 0,0,-180 )

	local blendTime = 0.5
	if ( timeTotal <= blendTime )
		blendTime = 0

	local angles = VectorToAngles( end - start )
	angles.x = 0
	angles.z = 0

	mover.MoveTo( end, timeTotal, blendTime, 0 )
	mover.RotateTo( angles, 0.2 )
}


function WaitUntilZiplinerNearsGround( guy, zipline )
{
	local result, start, end, frac
	local angles = guy.GetAngles()
	local forward = angles.AnglesToForward()

	local zipAngles, zipForward, dropDist

	if ( IsNPC( guy ) )
		dropDist = 150
	else
		dropDist = 10  //much closer for player

	local mins = guy.GetBoundingMins()
	local maxs = guy.GetBoundingMaxs()

	for ( ;; )
	{
		start = guy.GetOrigin()
		end = start + Vector(0,0,-dropDist)
		end += forward * dropDist
//		result = TraceLine( start, end, guy )
		result = TraceHull( start, end, mins, maxs, guy, TRACE_MASK_NPCSOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE )
		//DebugDrawLine( start, end, 255, 0, 0, true, 0.2 )

		if ( result.fraction < 1.0 )
			break

		start = guy.GetOrigin()
		end = zipline.hookOrigin + Vector( 0,0,-80 )

		zipForward = ( end - start )
		zipForward.Norm()
		zipForward *= 250

		end = start + zipForward
		//DebugDrawLine( start, end, 255, 0, 0, true, 0.1 )

//		result = TraceLine( start, end, guy )
		//DebugDrawLine( start, end, 255, 150, 0, true, 0.2 )
		result = TraceHull( start, end, mins, maxs, guy, TRACE_MASK_NPCSOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE )

		if ( result.fraction < 1.0 )
			break

		wait 0
	}

	zipline.origin <- result.endPos
	zipline.forward <- forward
}


function ZiplineRetracts( zipline )
{
	if ( !IsValid( zipline.start ) )
		return
	if ( !IsValid( zipline.mid ) )
		return
	if ( !IsValid( zipline.end ) )
		return

	OnThreadEnd(
		function() : ( zipline )
		{
			if ( IsValid( zipline.start ) )
				zipline.start.Kill()

			if ( IsValid( zipline.mid ) )
				zipline.mid.Kill()

			// is the only one that's not parented and only gets deleted here
			zipline.end.Kill()
		}
	)

	// IsValid check succeeds, even if a delete brought us here.
	// IsValid should've failed.
	if ( !IsAlive( zipline.ship ) )
		return

	zipline.ship.EndSignal( "OnDestroy" )

	zipline.start.EndSignal( "OnDestroy" )
	zipline.mid.EndSignal( "OnDestroy" )
	zipline.end.EndSignal( "OnDestroy" )

	local start, end, mid
	local startDist
	local endDist
	local totalDist
	local progress
	local newMidPoint
	local midRetractProgress

	local startTime = Time()
	local endTime = startTime + 0.3

	zipline.mid.ClearParent()

	start = zipline.start.GetOrigin()
	end = zipline.end.GetOrigin()
	mid = zipline.mid.GetOrigin()

	startDist = Distance( mid, start )
	endDist = Distance( mid, end )
	totalDist = startDist + endDist

	if ( totalDist <= 0 )
		return

	progress = startDist / totalDist
//	newMidPoint = end * progress + start * ( 1 - progress )
//
//	// how far from the midpoint we are, vertically
//	local mid_z_offset = newMidPoint.z - mid.z
//	local addOffset

	for ( ;; )
	{
		start = zipline.start.GetOrigin()
		end = zipline.end.GetOrigin()

		newMidPoint = end * progress + start * ( 1 - progress )

		midRetractProgress = GraphCapped( Time(), startTime, endTime, 0, 1 )
		if ( midRetractProgress >= 1.0 )
			break

		newMidPoint = mid * ( 1 - midRetractProgress ) + newMidPoint * midRetractProgress
		//addOffset = mid_z_offset * ( 1 - midRetractProgress )
		//newMidPoint.z -= addOffset
		//DebugDrawLine( zipline.mid.GetOrigin(), newMidPoint, 255, 0, 0, true, 0.2 )

		if ( !IsValid( zipline.mid ) )
		{
			printt( "Invalid zipline mid! Impossible!" )
		}
		else
		{
			zipline.mid.SetOrigin( newMidPoint )
		}


//		startDist = Distance( mid, start )
//		endDist = Distance( mid, end )
//		totalDist = startDist + endDist
//		progress = startDist / totalDist
		wait 0
	}

//	DebugDrawLine( zipline.start.GetOrigin(), zipline.mid.GetOrigin(), 255, 100, 50, true, 5.0 )
//	DebugDrawLine( zipline.end.GetOrigin(), zipline.mid.GetOrigin(), 60, 100, 244, true, 5.0 )
	local moveTime = 0.4
	zipline.start.MoveTo( zipline.end.GetOrigin(), moveTime )
	zipline.mid.MoveTo( zipline.end.GetOrigin(), moveTime )

	wait moveTime
/*
	startTime = Time()
	endTime = startTime + zipline.retractTime
	end = zipline.end.GetOrigin()

	if ( !IsValid( zipline.mid ) )
		return
	mid = zipline.mid.GetOrigin()

	local org

	for ( ;; )
	{
		start = zipline.start.GetOrigin()

		progress = Graph( Time(), startTime, endTime )
		if ( progress >= 1.0 )
			break

		org = end * ( 1 - progress ) + start * progress
		zipline.end.SetOrigin( org )

		org = mid * ( 1 - progress ) + start * progress

		if ( !IsValid( zipline.mid ) )
			return
		zipline.mid.SetOrigin( org )

		wait 0
	}
*/
}

function CreateRopeEntities( table )
{
	local subdivisions = 8 // 25
	local slack = 100 // 25
	local midpointName = UniqueString( "rope_midpoint" )
	local endpointName = UniqueString( "rope_endpoint" )

	local rope_start  = CreateEntity( "move_rope" )
	rope_start.kv.NextKey = midpointName
	rope_start.kv.MoveSpeed = 64
	rope_start.kv.Slack = slack
	rope_start.kv.Subdiv = subdivisions
	rope_start.kv.Width = "2"
	rope_start.kv.TextureScale = "1"
	rope_start.kv.RopeMaterial = "cable/cable.vmt"
	rope_start.kv.PositionInterpolator = 2


	local rope_mid = CreateEntity( "keyframe_rope" )
	rope_mid.SetName( midpointName )
	rope_mid.kv.NextKey = endpointName
	rope_mid.kv.MoveSpeed = 64
	rope_mid.kv.Slack = slack
	rope_mid.kv.Subdiv = subdivisions
	rope_mid.kv.Width = "2"
	rope_mid.kv.TextureScale = "1"
	rope_mid.kv.RopeMaterial = "cable/cable.vmt"

	local rope_end = CreateEntity( "keyframe_rope" )
	rope_end.SetName( endpointName )
	rope_end.kv.MoveSpeed = 64
	rope_end.kv.Slack = slack
	rope_end.kv.Subdiv = subdivisions
	rope_end.kv.Width = "2"
	rope_end.kv.TextureScale = "1"
	rope_end.kv.RopeMaterial = "cable/cable.vmt"

	table.start <- rope_start
	table.mid <- rope_mid
	table.end <- rope_end

	return table
}

function SpawnZiplineEntities( table )
{
	// after origins are set
	DispatchSpawn( table.start )
	DispatchSpawn( table.mid   )
	DispatchSpawn( table.end   )
	return table
}

/*
function FoundGoodZiplineSpot( guy, zipline )
{
	local maxZipDist = 1500

	// too fast to land. Maybe check for accelerating too?
	if ( zipline.ship.GetVelocity().Length() > 3000 ) // 300
		return false

	local start = zipline.ship.GetAttachmentOrigin( zipline.attachIndex )
	local angles = zipline.ship.GetAttachmentAngles( zipline.attachIndex )

//	local velocity = zipline.ship.GetVelocity()

	local table = LegalShipZiplineSpot( start, angles )
	if ( !table )
		return false

	// these will be used for dropping in
	zipline.hookOrigin <- table.hookTrace.endPos
	zipline.landOrigin <- table.landTrace.endPos
	return true
}


function LegalShipZiplineSpot( origin, angles )
{
	local maxZipDist = 1500

	local landTrace, hookTrace, end, frac, forward

	angles.x = 62.5 // RandomFloat( 50, 75 )
	forward = angles.AnglesToForward()

	end = origin + forward * maxZipDist

	landTrace = TraceLine( origin, end )

	if ( landTrace.hitSky )
		return false

	if ( landTrace.fraction >= 1.0 )
	{
		DebugDrawLine( origin, landTrace.endPos, 255, 0, 0, true, 2 )
		DebugDrawLine( landTrace.endPos, end, 125, 0, 0, true, 2 )
		return false
	}

	DebugDrawLine( origin, landTrace.endPos, 0, 200, 0, true, 6 )
	DebugDrawLine( landTrace.endPos, end, 0, 100, 0, true, 6 )

	// how flat is the ground?
	local dot = landTrace.surfaceNormal.Dot( Vector(0,0,1) )

	if ( dot < 0.3 )
		return false

	local landTraceDist2d = ( origin - landTrace.endPos ).Length2DSqr()
	if ( landTraceDist2d < level.MIN_ZIPLINE_LAND_DIST_SQRD )
		return false

	angles.x -= 15
	forward = angles.AnglesToForward()
	end = origin + forward * maxZipDist

	hookTrace = TraceLine( origin, end )
	DebugDrawLine( origin, hookTrace.endPos, 0, 255, 255, true, 6 )
	DebugDrawLine( hookTrace.endPos, end, 0, 0, 255, true, 6 )

	if ( hookTrace.hitSky )
		return false

	if ( hookTrace.fraction >= 1.0 )
		return false

	local hookTraceDist2d = ( origin - hookTrace.endPos ).Length2DSqr()

	if ( hookTraceDist2d < level.MIN_ZIPLINE_HOOK_DIST_SQRD )
		return false

	if ( hookTraceDist2d < landTraceDist2d )
		return false


	local table = {}
	table.hookTrace <- hookTrace
	table.landTrace <- landTrace
	return table
}
*/

function GetDropNode( zipline )
{
	if ( zipline.ship.s.dropTable.nodes == null )
		return null

	foreach ( side, nodeTables in zipline.ship.s.dropTable.nodes )
	{
		foreach ( nodeTable in nodeTables )
		{
			if ( nodeTable.attachName == zipline.shipAttach )
				return nodeTable.node
		}
	}

	return null
}

function GetHookOriginFromNode( origin, nodeOrigin, attachOrigin )
{
	// need to use the slope of guy to node to get the slope for the zipline, then launch it from the attachment origin
	local dropVec = nodeOrigin - origin
	local dropDist = dropVec.Length()
	dropVec.Norm()

//	DrawArrow( nodeOrigin, Vector(0,0,0), 5, 100 )
	local attachEnd = attachOrigin + dropVec * ( dropDist + 1500 ) // some buffer
	local zipTrace = TraceLine( attachOrigin, attachEnd, null, TRACE_MASK_NPCWORLDSTATIC )

//	DebugDrawLine( attachOrigin, zipTrace.endPos, 0, 255, 0, true, 5.0 )
//	DebugDrawLine( zipTrace.endPos, attachEnd, 255, 0, 0, true, 5.0 )

	// zipline didn't connect with anything
	if ( zipTrace.fraction == 1.0 )
	{
//		DebugDrawLine( attachOrigin, attachEnd, 255, 255, 0, true, 5.0 )
		return null
	}

	if ( Distance( zipTrace.endPos, attachOrigin ) < 300 )
		return null

	return zipTrace.endPos
}

function ZiplineInit( player )
{
	player.s.ziplineEffects <- []
}

function CodeCallback_ZiplineMount( player, zipline )
{
	// printl( "Mounting zipline")
	if ( IsServer() )
	{

		EmitDifferentSoundsOnEntityForPlayerAndWorld( "player_zipline_attach", "3p_zipline_attach", player, player )
	}

}

function CodeCallback_ZiplineStart( player, zipline )
{
	if ( GetBugReproNum() == 33760 )
		printl( "Starting zipline slide. IsServer() == " + IsServer() )
	if ( IsServer() )
	{
		 //printl( "Making zipline slide effect")

		local jumpJetEffectFriendlyName = "hmn_imc_jump_jet_wallrun_full"
		local jumpJetEffectEnemyName = "hmn_mcorps_jump_jet_wallrun_full"
		local playerTeam = player.GetTeam()

		//HACK!
		//Create 2 sets of jump jet effects, 1 visible to friendly, 1 visible to enemy
		//Doing this for a myriad of reasons on the server as opposed to on the client like the rest
		//of the jump jet effects. Since ziplining isn't all that common an action it should be fine

 		//create left jump jetfriendly
	 	local leftJumpJetFriendly = CreateEntity( "info_particle_system" )
		leftJumpJetFriendly.kv.start_active = 1
		leftJumpJetFriendly.kv.VisibilityFlags = 2
		leftJumpJetFriendly.kv.effect_name = jumpJetEffectFriendlyName
		leftJumpJetFriendly.SetName( UniqueString() )
		leftJumpJetFriendly.SetParent( player, "vent_left_back", false, 0 )
		leftJumpJetFriendly.SetTeam( playerTeam )
		leftJumpJetFriendly.SetOwner( player)
		DispatchSpawn( leftJumpJetFriendly, false )

		//now create right jump jet	for friendly
		local rightJumpJetFriendly = CreateEntity( "info_particle_system" )
		rightJumpJetFriendly.kv.start_active = 1
		rightJumpJetFriendly.kv.VisibilityFlags = 2
		rightJumpJetFriendly.kv.effect_name = jumpJetEffectFriendlyName
		rightJumpJetFriendly.SetName( UniqueString() )
		rightJumpJetFriendly.SetParent( player, "vent_right_back", false, 0 )
		rightJumpJetFriendly.SetTeam( playerTeam )
		rightJumpJetFriendly.SetOwner( player)
		DispatchSpawn( rightJumpJetFriendly, false )


		//create left jump jet for enemy
		local leftJumpJetEnemy = CreateEntity( "info_particle_system" )
		leftJumpJetEnemy.kv.start_active = 1
		leftJumpJetEnemy.kv.VisibilityFlags = 4
		leftJumpJetEnemy.kv.effect_name = jumpJetEffectEnemyName
		leftJumpJetEnemy.SetName( UniqueString() )
		leftJumpJetEnemy.SetParent( player, "vent_left_back", false, 0 )
		leftJumpJetEnemy.SetTeam( playerTeam )
		DispatchSpawn( leftJumpJetEnemy, false )

		//now create right jump jet	for enemy
		local rightJumpJetEnemy = CreateEntity( "info_particle_system" )
		rightJumpJetEnemy.kv.start_active = 1
		rightJumpJetEnemy.kv.VisibilityFlags = 4
		rightJumpJetEnemy.kv.effect_name = jumpJetEffectEnemyName
		rightJumpJetEnemy.SetName( UniqueString() )
		rightJumpJetEnemy.SetParent( player, "vent_right_back", false, 0 )
		rightJumpJetEnemy.SetTeam( playerTeam )
		DispatchSpawn( rightJumpJetEnemy, false )

		//sparks from the hand
		local handSparks = CreateEntity( "info_particle_system" )
		handSparks.kv.start_active = 1
		handSparks.kv.VisibilityFlags = 7
		handSparks.kv.effect_name = "P_Zipline_hld_1"
		handSparks.SetName( UniqueString() )
		handSparks.SetParent( player, "L_HAND", false, 0 )
		DispatchSpawn( handSparks, false )

		//Do it again for greater intensity!
		local handSparks2 = CreateEntity( "info_particle_system" )
		handSparks2.kv.start_active = 1
		handSparks2.kv.VisibilityFlags = 7
		handSparks2.kv.effect_name = "P_Zipline_hld_1"
		handSparks2.SetName( UniqueString() )
		handSparks2.SetParent( player, "L_HAND", false, 0 )
		DispatchSpawn( handSparks2, false )

		player.s.ziplineEffects.append( leftJumpJetFriendly	)
		player.s.ziplineEffects.append( rightJumpJetFriendly )
		player.s.ziplineEffects.append( leftJumpJetEnemy )
		player.s.ziplineEffects.append( rightJumpJetEnemy )

		player.s.ziplineEffects.append( handSparks )
		player.s.ziplineEffects.append( handSparks2 )

		if ( GetBugReproNum() == 33760 )
		{
			printt( "     Starting Effects" )
			local counter = 0
			foreach( effect in player.s.ziplineEffects )
			{
				printt( "     Starting effect " + counter + " " + effect )
				counter++
			}
		}

		EmitDifferentSoundsOnEntityForPlayerAndWorld( "player_zipline_loop", "3p_zipline_loop", player, player )

	}

}

function CodeCallback_ZiplineStop( player )
{
	if ( GetBugReproNum() == 33760 )
		printt( "Ending zipline slide. IsServer() == " + IsServer() )
	if ( IsServer() )
	{
		if ( GetBugReproNum() == 33760 )
			printt( "     Stopping Effects" )
		local counter = 0
		foreach( effect in player.s.ziplineEffects )
		{
			if ( GetBugReproNum() == 33760 )
				printt( "     stopping effect " + counter + " " + effect )
			counter++

			IsValid( effect )
				effect.Kill()
		}
		player.s.ziplineEffects.clear()

		StopSoundOnEntity( player, "player_zipline_loop" )
		StopSoundOnEntity( player, "3p_zipline_loop" )

		EmitDifferentSoundsOnEntityForPlayerAndWorld( "player_zipline_detach", "3p_zipline_detach", player, player )
	}
}

