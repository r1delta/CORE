// Ordinary SERVER VM presentation for pilot.slide_grapple. Including this file
// does not register a program, start a thread, or opt a player in.
// Only Movement_HasPlayerState's post-native publication may create effects.
// Rope entities replicate normally; there is no second movement/trace solver.
// Slide body/audio consumers use only published state. Weapon suppression belongs
// to the predicted movement command, never to this ordinary presentation loop.

function PilotMovement_ServerThink()
{
	Assert( IsServer() )
	if ( "pilotMovementServer" in level && level.pilotMovementServer != null )
		return

	local state = { players = {}, running = true, visit = false, map = level.ent }
	level.pilotMovementServer <- state
	level.ent.EndSignal( "OnDestroy" )
	OnThreadEnd(
		function() : ( state )
		{
			state.running = false
			foreach ( record in state.players )
			{
				PilotMovement_ServerReleaseRecord( record )
				PilotMovement_ServerClearPresentation( record.player )
			}
			state.players.clear()
			if ( "pilotMovementServer" in level && level.pilotMovementServer == state )
				level.pilotMovementServer = null
		}
	)

	if ( !( "pilotMovementServerCallbacks" in level ) )
	{
		AddCallback_OnPlayerKilled( PilotMovement_ServerPlayerKilled )
		AddCallback_OnClientDisconnected( PilotMovement_ServerPlayerDisconnected )
		level.pilotMovementServerCallbacks <- true
	}

	// Playtest default (r2-combo / R1Delta 3.0): opt every pilot into pilot.slide_grapple on converted R2 maps while
	// delta_pilot_movement_auto_r2 is 1 (default) and on stock R1 maps while delta_pilot_movement_auto_r1 is 1 (default 0).
	// Map changes, respawns and joiners are covered by the per-frame loop below. One program owns a player: a player that
	// already runs another program (autobhop, a mod) is left alone.
	local autoCvar = Movement_IsR2PortMap( GetMapName() ) ? "delta_pilot_movement_auto_r2" : "delta_pilot_movement_auto_r1"
	local autoDefault = Movement_IsR2PortMap( GetMapName() )

	while ( state.running )
	{
		if ( ConVarExists( autoCvar ) ? GetConVarInt( autoCvar ) != 0 : autoDefault )
		{
			foreach ( player in GetPlayerArray() )
			{
				if ( IsValid( player ) && player.IsPlayer() && !Movement_IsEnabled( player, "" ) )
					Movement_Enable( player, ::PilotMovementProgramName )
			}
		}
		state.visit = !state.visit
		foreach ( player in GetPlayerArray() )
		{
			if ( !IsValid( player ) || !Movement_HasPlayerState( player, ::PilotMovementProgramName ) )
				continue

			local session = Movement_GetPlayerStateSession( player, ::PilotMovementProgramName )
			local command = Movement_GetPlayerStateCommand( player, ::PilotMovementProgramName )
			local simulationTime = Movement_GetPlayerStateTime( player, ::PilotMovementProgramName )
			if ( player in state.players && state.players[ player ].session != session )
			{
				PilotMovement_ServerReleaseRecord( state.players[ player ] )
				PilotMovement_ServerClearPresentation( player )
				delete state.players[ player ]
			}
			if ( !( player in state.players ) )
			{
				state.players[ player ] <- {
					player = player, session = session, command = command,
					simulationTime = simulationTime, clockAnchor = Time(),
					visit = state.visit, suspended = false, serial = -1,
					ropes = [], tip = null, attached = false
				}
			}
			local record = state.players[ player ]
			record.visit = state.visit
			if ( !IsAlive( player ) || player.IsTitan() || player.IsObserver() )
			{
				PilotMovement_ServerReleaseRecord( record )
				PilotMovement_ServerClearPresentation( player )
				record.suspended = true
				record.command = command
				continue
			}
			// A respawn must not resurrect a pre-death rope before a new native
			// command has published. The death callback also covers fast respawns.
			if ( record.suspended && record.command == command )
				continue
			record.suspended = false
			if ( command != record.command || simulationTime != record.simulationTime )
			{
				record.simulationTime = simulationTime
				record.clockAnchor = Time()
			}
			record.command = command
			local sliding = Movement_GetPlayerStateInt( player, ::PilotMovementProgramName, 0 ) != 0
			player.nv.pilotMovementSession = session
			player.nv.pilotMovementSlide = sliding
			player.nv.pilotMovementLongJump = Movement_GetPlayerStateInt( player, ::PilotMovementProgramName, 1 ) != 0
			player.nv.pilotMovementSurface = Movement_GetPlayerStateInt( player, ::PilotMovementProgramName, 15 )
			if ( GetConVarInt( "delta_pilot_slide_body" ) != 0 ) Movement_SetSlideActivity( player, session, sliding )
			PilotSlideAudio_ServerUpdate( player, session, sliding )
			PilotMovement_ServerPresent( record )
		}

		local stale = []
		foreach ( player, record in state.players )
		{
			if ( record.visit == state.visit )
				continue
			PilotMovement_ServerReleaseRecord( record )
			PilotMovement_ServerClearPresentation( player )
			stale.append( player )
		}
		foreach ( player in stale )
			delete state.players[ player ]
		wait 0
	}
}

// The loader may call this immediately after disabling a player. With no player
// it synchronously destroys all owned effects and stops this map's think loop.
function PilotMovement_ServerCleanup( player = null )
{
	Assert( IsServer() )
	if ( !( "pilotMovementServer" in level ) || level.pilotMovementServer == null )
		return
	local state = level.pilotMovementServer
	if ( player != null )
	{
		if ( player in state.players )
		{
			PilotMovement_ServerReleaseRecord( state.players[ player ] )
			PilotMovement_ServerClearPresentation( player )
			delete state.players[ player ]
		}
		return
	}

	state.running = false
	foreach ( record in state.players )
	{
		PilotMovement_ServerReleaseRecord( record )
		PilotMovement_ServerClearPresentation( record.player )
	}
	state.players.clear()
	level.pilotMovementServer = null
}

function PilotMovement_ServerPlayerKilled( player, damageInfo )
{
	if ( !( "pilotMovementServer" in level ) || level.pilotMovementServer == null )
		return
	local state = level.pilotMovementServer
	if ( !( player in state.players ) )
		return
	local record = state.players[ player ]
	PilotMovement_ServerReleaseRecord( record )
	PilotMovement_ServerClearPresentation( player )
	record.suspended = true
	if ( Movement_HasPlayerState( player, ::PilotMovementProgramName ) &&
		Movement_GetPlayerStateSession( player, ::PilotMovementProgramName ) == record.session )
		record.command = Movement_GetPlayerStateCommand( player, ::PilotMovementProgramName )
}

function PilotMovement_ServerPlayerDisconnected( player )
{
	if ( !( "pilotMovementServer" in level ) || level.pilotMovementServer == null )
		return
	local state = level.pilotMovementServer
	if ( player in state.players )
	{
		PilotMovement_ServerReleaseRecord( state.players[ player ] )
		PilotMovement_ServerClearPresentation( player )
		delete state.players[ player ]
	}
}

function PilotMovement_ServerReleaseRecord( record )
{
	PilotMovement_ServerDestroyRope( record )
	record.serial = -1
}

function PilotMovement_ServerClearPresentation( player )
{
	PilotSlideAudio_ServerCleanup( player )
	if ( !IsValid( player ) )
		return
	Movement_SetSlideActivity( player, 0, false )
	player.nv.pilotMovementSession = 0
	player.nv.pilotMovementSlide = false
	player.nv.pilotMovementLongJump = false
	player.nv.pilotMovementSurface = 0
}

function PilotMovement_ServerDestroyLinks( record )
{
	foreach ( rope in record.ropes )
		if ( IsValid( rope ) )
			rope.Destroy()
	record.ropes.clear()
}

function PilotMovement_ServerDestroyRope( record )
{
	PilotMovement_ServerDestroyLinks( record )
	if ( IsValid( record.tip ) )
		record.tip.Destroy()
	record.tip = null
	record.attached = false
}


function PilotMovement_ServerPoint( player, slot )
{
	return Vector(
		Movement_GetPlayerStateFloat( player, ::PilotMovementProgramName, slot ),
		Movement_GetPlayerStateFloat( player, ::PilotMovementProgramName, slot + 1 ),
		Movement_GetPlayerStateFloat( player, ::PilotMovementProgramName, slot + 2 ) )
}

function PilotMovement_ServerPresent( record )
{
	local player = record.player
	local phase = Movement_GetPlayerStateInt( player, ::PilotMovementProgramName, 16 )
	if ( phase < 1 || phase > 6 )
	{
		PilotMovement_ServerReleaseRecord( record )
		return
	}
	local serial = Movement_GetPlayerStateInt( player, ::PilotMovementProgramName, 19 )
	if ( record.serial != serial )
	{
		PilotMovement_ServerReleaseRecord( record )
		record.serial = serial
	}

	local view = player.EyeAngles()
	local outlet = player.EyePosition() + view.AnglesToForward() * 32.0 - view.AnglesToUp() * 32.0
	local tip = PilotMovement_ServerPoint( player, 32 )
	local attached = phase == 4 || phase == 5
	local now = record.simulationTime + max( 0.0, Time() - record.clockAnchor )
	if ( phase == 1 || phase == 3 )
	{
		local fired = Movement_GetPlayerStateFloat( player, ::PilotMovementProgramName, 20 )
		local arrived = Movement_GetPlayerStateFloat( player, ::PilotMovementProgramName, 21 )
		local fraction = min( 1.0, max( 0.0, ( now - fired ) / max( 0.001, arrived - fired ) ) )
		if ( phase == 1 )
			fraction = 1.0 - ( 1.0 - fraction ) * ( 1.0 - fraction )
		local launch = PilotMovement_ServerPoint( player, 29 )
		tip = launch + ( tip - launch ) * fraction
	}
	else if ( phase == 2 || phase == 6 )
	{
		local began = Movement_GetPlayerStateFloat( player, ::PilotMovementProgramName, 23 )
		local duration = Movement_GetPlayerStateFloat( player, ::PilotMovementProgramName, 24 )
		local fraction = min( 1.0, max( 0.0, ( now - began ) / max( 0.001, duration ) ) )
		fraction = fraction * fraction * ( 3.0 - 2.0 * fraction )
		local returnedFrom = PilotMovement_ServerPoint( player, 56 )
		tip = returnedFrom + ( outlet - returnedFrom ) * fraction
	}

	local points = [ outlet ]
	if ( attached )
	{
		local corners = min( 4, max( 0, Movement_GetPlayerStateInt( player, ::PilotMovementProgramName, 18 ) ) )
		// The rollback ABI stores corners anchor-to-player; ropes link the reverse.
		for ( local corner = corners - 1; corner >= 0; corner-- )
			points.append( PilotMovement_ServerPoint( player, 38 + corner * 3 ) )
	}
	points.append( tip )

	if ( !IsValid( record.tip ) )
	{
		PilotMovement_ServerDestroyLinks( record )
		record.tip = CreateEntity( "script_mover" )
		record.tip.kv.solid = 0
		record.tip.kv.model = "models/dev/empty_model.mdl"
		record.tip.kv.SpawnAsPhysicsMover = 0
		record.tip.SetName( UniqueString( "pilot_movement_tip" ) )
		record.tip.SetOwner( player )
		// Unlike DT_RopeKeyframe, this anchor replicates BaseEntity owner and
		// visibility. The client rope renderer follows this endpoint declaration.
		record.tip.kv.VisibilityFlags = 6
		record.tip.SetTeam( player.GetTeam() )
		record.tip.SetOrigin( tip )
		DispatchSpawn( record.tip )
		record.attached = false
	}
	// Only a published clamped/pulling phase fixes the endpoint to the surface.
	// No hit entity is parented: slot 32 is a world-fixed anchor even on movers.
	if ( !attached || !record.attached )
		record.tip.SetOrigin( tip )
	if ( attached && !record.attached )
		record.tip.SetAngles( VectorToAngles( PilotMovement_ServerPoint( player, 35 ) ) )
	record.attached = attached

	local rebuild = record.ropes.len() != points.len()
	foreach ( rope in record.ropes )
		if ( !IsValid( rope ) )
			rebuild = true
	if ( rebuild )
		PilotMovement_ServerCreateLinks( record, points )
	else
		for ( local i = 0; i < points.len() - 1; i++ )
			record.ropes[ i ].SetOrigin( points[ i ] )
}

function PilotMovement_ServerCreateLinks( record, points )
{
	PilotMovement_ServerDestroyLinks( record )
	for ( local i = 0; i < points.len(); i++ )
	{
		local rope = CreateEntity( i == 0 ? "move_rope" : "keyframe_rope" )
		record.ropes.append( rope )
		rope.SetName( UniqueString( "pilot_movement_rope" ) )
		rope.SetOwner( record.player )
		rope.SetTeam( record.player.GetTeam() )
		rope.kv.MoveSpeed = 64
		rope.kv.Slack = 0
		rope.kv.Subdiv = 8
		rope.kv.Width = "2"
		rope.kv.TextureScale = "1"
		rope.kv.RopeMaterial = "cable/cable.vmt" // Shipped R1 material used by mp/_zipline.
		rope.SetOrigin( points[ i ] )
		if ( i == 0 )
			rope.kv.PositionInterpolator = 2
	}
	for ( local i = 0; i < record.ropes.len() - 1; i++ )
		record.ropes[ i ].kv.NextKey = record.ropes[ i + 1 ].GetName()
	record.ropes[ record.ropes.len() - 1 ].SetParent( record.tip )
	// Native NextKey resolution is established at spawn. Rebuild only when the
	// number of corners changes, not by retargeting live cached NextKey handles.
	for ( local i = record.ropes.len() - 1; i >= 0; i-- )
		DispatchSpawn( record.ropes[ i ] )
}
