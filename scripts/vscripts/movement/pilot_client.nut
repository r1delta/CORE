// Ordinary CLIENT consumer; the loader starts exactly one think thread.
// Nothing here runs inside movement simulation or prediction replay.
// Geometry is a fresh procedural cable/three-prong claw, not an authored hook
// model. Reuse the installed vgui_icon ImagePanel and shipped HUD/white;
// no new material is needed.
// Surface-dependent slide audio uses slide_audio.nut and its imported WAVs.
// Exact body/viewmodel animation and particles plus authored grapple model/
// audio require their actual assets and sequence/attachment/surface mappings.
::PilotMovementClient <- {
	running = false,
	player = null,
	session = -1,
	command = -1,
	simulationTime = -1.0,
	clockAnchor = 0.0,
	screens = [],
	viewOwned = false,
	sliding = false,
	fovActive = false,
	fov = 0.0,
	fovFrom = 0.0,
	fovBegan = 0.0,
	pose = 0.0,
	poseFrom = 0.0,
	poseBegan = 0.0,
	poseDuration = 0.18
}

function PilotMovement_ClientDestroyCable()
{
	foreach ( screen in ::PilotMovementClient.screens )
	{
		if ( IsValid( screen ) )
			screen.Destroy()
	}
	::PilotMovementClient.screens.clear()
}

function PilotMovement_ClientReset()
{
	local state = ::PilotMovementClient
	PilotSlideAudio_Cleanup()
	PilotMovement_ClientDestroyCable()
	if ( state.viewOwned )
		Movement_ClearView( ::PilotMovementProgramName )
	state.viewOwned = false
	state.player = null
	state.session = -1
	state.command = -1
	state.simulationTime = -1.0
	state.clockAnchor = 0.0
	state.sliding = false
	state.fovActive = false
	state.fov = 0.0
	state.fovFrom = 0.0
	state.fovBegan = 0.0
	state.pose = 0.0
	state.poseFrom = 0.0
	state.poseBegan = 0.0
	state.poseDuration = 0.18
}

function PilotMovement_ClientSmooth( fraction )
{
	fraction = min( 1.0, max( 0.0, fraction ) )
	return fraction * fraction * (3.0 - 2.0 * fraction)
}

function PilotMovement_ClientPoint( slot )
{
	local name = ::PilotMovementProgramName
	return Vector( Movement_GetPresentationFloat( name, slot ),
		Movement_GetPresentationFloat( name, slot + 1 ),
		Movement_GetPresentationFloat( name, slot + 2 ) )
}

function PilotMovement_ClientSlide( player, sliding, longJumpAllowed, now )
{
	local state = ::PilotMovementClient
	local fovTarget = state.fovActive ? 1.0 : 0.0
	local poseTarget = state.sliding ? 1.0 : 0.0
	local fovWeight = min( 1.0, max( 0.0, (now - state.fovBegan) / 0.25 ) )
	local poseWeight = PilotMovement_ClientSmooth( (now - state.poseBegan) / state.poseDuration )
	state.fov = state.fovFrom + (fovTarget - state.fovFrom) * fovWeight
	state.pose = state.poseFrom + (poseTarget - state.poseFrom) * poseWeight
	local fovActive = sliding && longJumpAllowed
	if ( fovActive != state.fovActive )
	{
		state.fovFrom = state.fov
		state.fovBegan = now
		state.fovActive = fovActive
	}
	if ( sliding != state.sliding )
	{
		state.poseFrom = state.pose
		state.poseBegan = now
		state.poseDuration = sliding ? 0.12 : 0.18
		state.sliding = sliding
	}
	if ( !sliding && state.fov <= 0.0 && state.pose <= 0.0 )
	{
		if ( state.viewOwned )
			Movement_ClearView( ::PilotMovementProgramName )
		state.viewOwned = false
		return
	}
	local attenuation = 1.0 - min( 1.0, max( 0.0, player.GetAdsFraction() ) )
	local pose = state.pose * attenuation
	// Native view hooks compose these camera-relative contributions with the
	// real viewmodel transform, including native bob/lag. Never move its entity.
	Movement_SetView( ::PilotMovementProgramName, 1.0 + 0.1 * state.fov,
		GetConVarFloat( "delta_sp_slide_viewmodel_forward" ) * pose,
		GetConVarFloat( "delta_sp_slide_viewmodel_right" ) * pose,
		GetConVarFloat( "delta_sp_slide_viewmodel_up" ) * pose,
		GetConVarFloat( "delta_sp_slide_viewmodel_pitch" ) * pose,
		GetConVarFloat( "delta_sp_slide_viewmodel_yaw" ) * pose,
		GetConVarFloat( "delta_sp_slide_viewmodel_roll" ) * pose )
	state.viewOwned = true
}

function PilotMovement_ClientCreateCable()
{
	local screens = ::PilotMovementClient.screens
	if ( screens.len() != 0 )
		return
	// Five routed cable spans and seven simple claw edges. These are local
	// render entities only; no server marker/entity name or replication lookup.
	for ( local i = 0; i < 12; i++ )
	{
		local screen = CreateClientsideVGuiScreen( "vgui_icon",
			VGUI_SCREEN_PASS_WORLD, Vector( 0, 0, 0 ), Vector( 0, 0, 0 ), 1.0, 1.0 )
		screens.append( screen ) // own it before any panel operation can fail
		screen.Hide()
		local panel = screen.GetPanel()
		local image = HudElement( "CenterIcon", panel )
		screen.s.icon <- image
		image.SetSize( 150, 150 )
		image.SetPos( 0, 0 )
		image.SetImage( "HUD/white" )
		image.SetColor( i < 5 ? 110 : 185, i < 5 ? 115 : 190, i < 5 ? 120 : 195, 255 )
		image.Show()
	}
}

function PilotMovement_ClientDot( a, b )
{
	return a.x * b.x + a.y * b.y + a.z * b.z
}

function PilotMovement_ClientSpan( index, start, finish, width, camera, cameraAngles )
{
	local screen = ::PilotMovementClient.screens[index]
	local along = finish - start
	local length = along.Length()
	if ( length <= 0.001 )
	{
		screen.Hide()
		return
	}
	along *= 1.0 / length
	// VGUI lies in local XY: forward is screen width, -right is height,
	// up is its front normal. Project the camera onto the perpendicular plane
	// so every span is a world-depth-tested ribbon facing the actual camera.
	local normal = camera - (start + finish) * 0.5
	normal -= along * PilotMovement_ClientDot( normal, along )
	local normalLength = normal.Length()
	if ( normalLength <= 0.001 )
	{
		normal = cameraAngles.AnglesToUp()
		normal -= along * PilotMovement_ClientDot( normal, along )
		normalLength = normal.Length()
		if ( normalLength <= 0.001 )
		{
			normal = cameraAngles.AnglesToRight()
			normal -= along * PilotMovement_ClientDot( normal, along )
			normalLength = normal.Length()
		}
	}
	normal *= 1.0 / normalLength
	local angles = VectorToAngles( along )
	angles.z = atan2( -PilotMovement_ClientDot( normal, angles.AnglesToRight() ),
		PilotMovement_ClientDot( normal, angles.AnglesToUp() ) ) * 57.2957795130823
	screen.SetAngles( angles )
	screen.SetOrigin( start + angles.AnglesToRight() * (width * 0.5) )
	screen.SetSize( length, width )
	screen.Show()
}

function PilotMovement_ClientGrapple( player, phase, simulationNow )
{
	if ( phase == 0 )
	{
		PilotMovement_ClientDestroyCable()
		return
	}
	PilotMovement_ClientCreateCable()
	local name = ::PilotMovementProgramName
	local camera = player.CameraPosition()
	local angles = player.CameraAngles()
	// The source captures eye + forward*32 - up*32 at fire. The near end
	// remains camera-relative every rendered frame, including between commands.
	local outlet = camera + angles.AnglesToForward() * 32.0 - angles.AnglesToUp() * 32.0
	local tip = PilotMovement_ClientPoint( 32 )
	if ( phase == 1 || phase == 3 )
	{
		local began = Movement_GetPresentationFloat( name, 20 )
		local arrival = Movement_GetPresentationFloat( name, 21 )
		local fraction = min( 1.0, max( 0.0, (simulationNow - began) / max( 0.001, arrival - began ) ) )
		if ( phase == 1 )
			fraction = 1.0 - (1.0 - fraction) * (1.0 - fraction)
		local launch = PilotMovement_ClientPoint( 29 )
		tip = launch + (tip - launch) * fraction
	}
	else if ( phase == 2 || phase == 6 )
	{
		local fraction = PilotMovement_ClientSmooth( (simulationNow - Movement_GetPresentationFloat( name, 23 )) /
			max( 0.001, Movement_GetPresentationFloat( name, 24 ) ) )
		local returnStart = PilotMovement_ClientPoint( 56 )
		tip = returnStart + (outlet - returnStart) * fraction
	}

	local previous = outlet
	local span = 0
	if ( phase == 4 || phase == 5 )
	{
		// ABI corners are ANCHOR -> PLAYER. Draw PLAYER -> ANCHOR, not the
		// tempting array order that crosses spans and skips the nearest corner.
		local count = Movement_GetPresentationInt( name, 18 )
		for ( local corner = count - 1; corner >= 0; corner-- )
		{
			local point = PilotMovement_ClientPoint( 38 + corner * 3 )
			PilotMovement_ClientSpan( span++, previous, point, 0.65, camera, angles )
			previous = point
		}
	}
	PilotMovement_ClientSpan( span++, previous, tip, 0.65, camera, angles )
	for ( local i = span; i < 5; i++ )
		::PilotMovementClient.screens[i].Hide()

	local direction = tip - previous
	if ( phase == 4 || phase == 5 )
		direction = PilotMovement_ClientPoint( 35 ) * -1.0
	else if ( phase == 2 || phase == 6 )
		direction = outlet - PilotMovement_ClientPoint( 56 )
	local directionLength = direction.Length()
	if ( directionLength <= 0.001 )
		direction = angles.AnglesToForward()
	else
		direction *= 1.0 / directionLength
	local basis = VectorToAngles( direction )
	local right = basis.AnglesToRight()
	local up = basis.AnglesToUp()
	local base = tip - direction * 7.0
	PilotMovement_ClientSpan( 5, base, tip, 1.25, camera, angles )
	// Three radial, hooked prongs; a deliberately simple original silhouette.
	for ( local prong = 0; prong < 3; prong++ )
	{
		local turn = prong * 2.0943951023932
		local radial = right * cos( turn ) + up * sin( turn )
		local shoulder = tip - direction * 2.0 + radial * 3.5
		local point = tip + direction + radial * 1.25
		PilotMovement_ClientSpan( 6 + prong * 2, base, shoulder, 0.95, camera, angles )
		PilotMovement_ClientSpan( 7 + prong * 2, shoulder, point, 0.95, camera, angles )
	}
}

function PilotMovement_ClientThink()
{
	// Registration happens before the local player's client surface exists.
	// Wait for the base tree's actual initialization boundary, not a timer.
	while ( !( "clientScriptInitialized" in level ) || !level.clientScriptInitialized )
		wait 0
	local state = ::PilotMovementClient
	if ( state.running )
		return
	state.running = true
	RegisterConCommandTriggeredCallback( "+scriptCommand3", PilotMovement_GrapplePressed )
	RegisterConCommandTriggeredCallback( "-scriptCommand3", PilotMovement_GrappleReleased )
	OnThreadEnd( function() {
		PilotMovement_ClientReset()
		::PilotMovementClient.running = false
	} )
	level.ent.EndSignal( "OnDestroy" )
	for ( ;; )
	{
		local player = GetLocalClientPlayer()
		local name = ::PilotMovementProgramName
		if ( !IsValid( player ) || !IsAlive( player ) || player.IsTitan() ||
			player != GetLocalViewPlayer() || IsWatchingKillReplay() || !Movement_HasPresentation( name ) )
		{
			PilotMovement_ClientReset()
			wait 0
			continue
		}
		local session = Movement_GetPresentationSession( name )
		if ( state.player != player || state.session != session )
		{
			PilotMovement_ClientReset()
			state.player = player
			state.session = session
		}
		local now = Time()
		local command = Movement_GetPresentationCommand( name )
		local simulationTime = Movement_GetPresentationTime( name )
		if ( command != state.command || simulationTime != state.simulationTime || now < state.clockAnchor )
		{
			state.command = command
			state.simulationTime = simulationTime
			state.clockAnchor = now
		}
		// Committed command time is not ordinary client Time(). Re-anchor on
		// each new snapshot and extrapolate only the elapsed render-frame time.
		local simulationNow = simulationTime + max( 0.0, now - state.clockAnchor )
		// Read current state even when command identity did not change: a
		// correction may replace slots for that very command/session/time.
		local sliding = Movement_GetPresentationInt( name, 0 ) != 0
		local surfaceKnown = Movement_GetPresentationInt( name, 9 ) != 0
		local soundStep = surfaceKnown ?
			PilotSlideAudio_Step( Movement_GetSurfaceName( Movement_GetPresentationInt( name, 15 ) ) ) : null
		PilotSlideAudio_Update( player, session, sliding, soundStep )
		PilotMovement_ClientSlide( player, sliding,
			Movement_GetPresentationInt( name, 1 ) != 0, now )
		PilotMovement_ClientGrapple( player, Movement_GetPresentationInt( name, 16 ), simulationNow )
		wait 0
	}
}
