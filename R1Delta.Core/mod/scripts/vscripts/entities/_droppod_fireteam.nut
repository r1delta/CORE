//const DP_TURRET_MODEL = "models/vehicle/droppod_fireteam/droppod_fireteam_turret.mdl"
const DP_DOOR_MODEL = "models/vehicle/droppod_fireteam/droppod_fireteam_door.mdl"
const DP_ARM_MODEL = "models/vehicle/droppod_fireteam/droppod_fireteam_arm.mdl"

const POST_TURRET_DELAY = 0.25

function main()
{
	Globalize( InitFireteamDropPod )
	Globalize( ActivateFireteamDropPod )

	Globalize( CreateDropPodDoor )
	Globalize( CleanupFireteamPod )

	RegisterSignal( "OpenDoor" )
	RegisterSignal( "player_exits_droppod" ) // used by the exit anim
	RegisterSignal( "player_hands_down" ) // used by the exit anim

	//PrecacheTurret( "droppod_fireteam_turret" )

	PrecacheModelPhysics( DP_DOOR_MODEL )
	//PrecacheModelPhysics( DP_TURRET_MODEL )
	PrecacheModel( DP_ARM_MODEL )
}


function DestroyOnPlayerDisconnected( pod, player )
{
	pod.EndSignal( "OnDestroy" )

	pod.WaitSignal( "OnImpact" )

	if ( IsValid_ThisFrame( player ) )
		return

	CleanupFireteamPod( pod )
}


function InitFireteamDropPod( pod )
{
	pod.SetModel( DEFAULT_FIRETEAM_DROP_MODEL )

	pod.s.onTarget <- false
	pod.s.autoCleanupDelay <- 0  // -1 = never cleanup automatically
	pod.s.numGuys <- 0
	pod.s.door <- CreateDropPodDoor( pod )
	pod.s.turret <- null
	pod.s.hasPlayer <- false
	pod.s.fireteamPlayer <- null

//	pod.s.arm <- CreateDropPodArm( pod )
//	pod.s.arm.Fire( "SetAnimation", "arm_idle" )

	pod.InitFlag( "OpenDoor" )
	pod.InitFlag( "OnImpact" )

	pod.Anim_Play( "idle" )

}


function ActivateFireteamDropPod( pod, player = null, guys = [] )
{
	if ( !player || player.IsBot() )
		pod.SetFlag( "OpenDoor" )

	if ( player )
		thread PlayerRidesDropPod( pod, player )

	if ( guys.len() >= 1 )
	{
		SetAnim( guys[0], "drop_pod_exit_anim", "pt_dp_exit_a" )
		SetAnim( guys[0], "drop_pod_idle_anim", "pt_dp_idle_a" )
	}

	if ( guys.len() >= 2 )
	{
		SetAnim( guys[1], "drop_pod_exit_anim", "pt_dp_exit_b" )
		SetAnim( guys[1], "drop_pod_idle_anim", "pt_dp_idle_b" )
	}

	if ( guys.len() >= 3 )
	{
		SetAnim( guys[2], "drop_pod_exit_anim", "pt_dp_exit_c" )
		SetAnim( guys[2], "drop_pod_idle_anim", "pt_dp_idle_c" )
	}

	if ( guys.len() >= 4 )
	{
		Assert( !player )
		SetAnim( guys[3], "drop_pod_exit_anim", "pt_dp_exit_d" )
		SetAnim( guys[3], "drop_pod_idle_anim", "pt_dp_idle_d" )
	}

	foreach ( guy in guys )
	{
		if ( IsAlive( guy ) )
		{
			guy.MakeVisible()
			local weapon = guy.GetActiveWeapon()
			if ( IsValid( weapon ) )
				weapon.MakeVisible()

			thread GuyHangsInPod( guy, pod )
		}
	}

	thread DropPodActiveThink( pod, player )
}



function DropPodActiveThink( pod, player )
{
	OnThreadEnd(
		function() : ( pod, player )
		{
			if ( pod.s.autoCleanupDelay < 0 )
				return

			delaythread( 0 ) CleanupFireteamPod( pod )
		}
	)

	if ( player )
		player.EndSignal( "Disconnected" )

	pod.EndSignal( "OnDestroy" )

	pod.WaitFlag( "OpenDoor" )

	if ( DropPodDoorInGround( pod ) )
		pod.s.door.Kill()
	else
		DropPodOpenDoor( pod, pod.s.door )

	while ( pod.s.numGuys )
		wait 0

	while ( pod.s.hasPlayer )
		wait 0
}

function CreateDropPodImpactFX( pod )
{
	local impactFX = CreateEntity( "info_particle_system" )
	impactFX.SetName( "DropPodImpactFX" )
	impactFX.SetOrigin( pod.GetOrigin() )
	impactFX.SetAngles( Vector( 0, 0, 0 ) )
	impactFX.kv.effect_name = "droppod_impact"
	impactFX.kv.start_active = 0

	DispatchSpawn( impactFX, false )

	return impactFX
}


function CreateDropPodImactExplode( pod )
{
	local impactExplode = CreateEntity( "env_explosion" )
	impactExplode.SetOrigin( pod.GetOrigin() )
	impactExplode.kv.iRadiusOverride = 250
	impactExplode.kv.iInnerRadius = 80
	impactExplode.kv.iMagnitude = 150
	impactExplode.SetOwner( pod )
	impactExplode.kv.spawnflags = 1900
	impactExplode.kv.damageSourceId = eDamageSourceId.droppod_impact

	DispatchSpawn( impactExplode, false )

	return impactExplode
}


function DropPodDoorInGround( pod )
{
	local attachment = "hatch"
	local attachIndex = pod.LookupAttachment( attachment )
	local end = pod.GetAttachmentOrigin( attachIndex )

	local originAttachment = "origin"
	local originAttachIndex = pod.LookupAttachment( originAttachment )
	local start = pod.GetAttachmentOrigin( originAttachIndex )

	local result = TraceLine( start, end, pod, TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE )

//	DebugDrawLine( start, result.endPos, 0, 255, 0, true, 4.0 )
//	DebugDrawLine( result.endPos, end, 255, 0, 0, true, 4.0 )
//	DebugDrawLine( result.endPos, GetPlayerArray()[0].GetOrigin(), 255, 255, 0, true, 4.0 )
//	DebugDrawText( result.endPos, result.fraction + "", true, 4.0 )

	return result.fraction < 1.0
}

function PlayerRidesDropPod( pod, player )
{
	Assert( 0, "Broken due to disabled arm" )
	player.EndSignal( "Disconnected" )
	player.EndSignal( "OnDeath" )

	player.HolsterWeapon()

	pod.s.hasPlayer = true

	OnThreadEnd(
		function() : ( pod, player )
		{
			if ( IsValid_ThisFrame( player ) )
			{
				player.MinimapUnhide()
				player.DeployWeapon()
				delete player.s.pod
			}

			pod.s.hasPlayer = false
		}
	)

	Assert( !( "pod" in player.s ), "Tried to create pod, but already exists" )
	player.s.pod <- pod

	local arm = pod.s.arm

	local playerSequence = CreateFirstPersonSequence()
	playerSequence.attachment = "ATTACH"
	playerSequence.thirdPersonAnim = "pt_dp_idle_player"
	playerSequence.firstPersonAnim = "ptpov_dp_idle"

	thread FirstPersonSequence( playerSequence, player, pod )

	if ( !pod.IsFlagSet( "OpenDoor" ) )
	{
		/* NOPE.

		thread PlayAnim( player, "pt_dp_idle_player", pod, "ATTACH", 0.0 )

		if ( pod.s.turret )
		{
			local turret = pod.s.turret

			player.SetPlayerSettings( "fireteamDropPod" )
			pod.s.turret.SetDriver( player )

			thread DropPodRotates( pod, pod.s.turret, player )
		}

		thread PlayerControlsDropPod( player, pod )

		pod.WaitFlag( "OpenDoor" )

		if ( pod.s.turret )
		{
			pod.s.turret.SetDriver( null )
			player.SetPlayerSettings( "fireteam" )
		}

		player.HolsterWeapon()

		wait POST_TURRET_DELAY
		*/

		pod.WaitFlag( "OpenDoor" )
	}

	arm.Fire( "SetAnimation", "arm_exit" )

	local playerSequence = CreateFirstPersonSequence()
	playerSequence.blendTime = 0.25
	playerSequence.attachment = "ATTACH"
	playerSequence.thirdPersonAnim = "pt_dp_exit_player"
	playerSequence.firstPersonAnim = "ptpov_dp_exit"
	playerSequence.viewConeFunction = DropPodPlayerViewCone

	thread PlayerExitsDropPod( player )

	waitthread FirstPersonSequence( playerSequence, player, pod )

	player.ClearParent()
	player.ClearAnimViewEntity()

	player.DeployWeapon()
	player.MinimapUnhide()
}


function PlayerExitsDropPod( player )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "Disconnected" )

	//player.WaitSignal( "player_exits_droppod" ) // not working... investigate
	wait 3.2

	player.DeployWeapon()
}


function DropPodPlayerViewCone( player )
{
	player.PlayerCone_FromAnim()
	player.PlayerCone_SetMinYaw( -15 )
	player.PlayerCone_SetMaxYaw( 15 )
	player.PlayerCone_SetMinPitch( -15 )
	player.PlayerCone_SetMaxPitch( 15 )
}


function CleanupFireteamPod( pod )
{
	if ( !IsValid( pod ) )
		return

	if ( IsValid( pod.s.door ) )
		pod.s.door.Dissolve( ENTITY_DISSOLVE_ELECTRICAL, Vector( 0, 0, 0 ), 50 )

	EmitSoundAtPosition( pod.GetOrigin(), "droppod_dissolve" )

	pod.Dissolve( ENTITY_DISSOLVE_ELECTRICAL, Vector( 0, 0, 0 ), 50 )
}


//function PrecacheTurret( turretSettings )
//{
//	local turret = CreateEntity( "turret" )
//	// Ignore range when making viewcone checks
//	// Aiming Assistance (Player Only)
//	// Active
//	// Controllable
//	// Non-solid.
//	turret.kv.model = DP_TURRET_MODEL
//	turret.kv.Settings = turretSettings
//	DispatchSpawn( turret, false )
//	turret.Kill()
//}


//function CreateDropPodTurret( pod )
//{
//	local turret = CreateEntity( "turret" )
//	// Ignore range when making viewcone checks
//	// Aiming Assistance (Player Only)
//	// Active
//	// Controllable
//	// Non-solid.
//
//	local origin, angles, forward, up, right
//	local attachIndex = pod.LookupAttachment( "TurretAttach" )
//
//	origin = pod.GetAttachmentOrigin( attachIndex )
//	angles = pod.GetAttachmentAngles( attachIndex )
//
//	turret.kv.model = DP_TURRET_MODEL
//	turret.kv.Settings = "droppod_fireteam_turret"
//
//	turret.SetParent( pod, "TurretAttach", false )
//
//	DispatchSpawn( turret, false )
//
//	origin = turret.GetOrigin()
//	angles = turret.GetAngles()
//	turret.Anim_PlayWithRefPoint( "droppod_turret_open", origin, angles, 0 )
//
//	return turret
//}


function CreateDropPodDoor( pod )
{
	local attachment = "hatch"
	local attachIndex = pod.LookupAttachment( attachment )
	local origin = pod.GetAttachmentOrigin( attachIndex )
	local angles = pod.GetAttachmentAngles( attachIndex )

	local prop_physics = CreateEntity( "prop_physics" )
	prop_physics.SetName( "door" + UniqueString() )
	prop_physics.kv.model = DP_DOOR_MODEL
	// Start Asleep
	// Debris - Don't collide with the player or other debris
	// Generate output on +USE
	prop_physics.kv.spawnflags = 261 // non solid for now
	prop_physics.kv.fadedist = -1
	prop_physics.kv.physdamagescale = 0.1
	prop_physics.kv.inertiaScale = 1.0
	prop_physics.kv.renderamt = 0
	prop_physics.kv.rendercolor = "255 255 255"

	DispatchSpawn( prop_physics, false )

	prop_physics.SetOrigin( origin )
	prop_physics.SetAngles( angles )
	prop_physics.SetParent( pod, "HATCH", false )
	prop_physics.MarkAsNonMovingAttachment()

	return prop_physics
}


function CreateDropPodArm( pod )
{
	local attachment = "ATTACH"
	local attachIndex = pod.LookupAttachment( attachment )

	local origin = pod.GetAttachmentOrigin( attachIndex )
	local angles = pod.GetAttachmentAngles( attachIndex )

	local arm = CreateEntity( "prop_dynamic" )

	arm.kv.fadedist = -1
	arm.kv.renderamt = 255
	arm.kv.rendercolor = "255 255 255"
	//arm.kv.solid = 6
	arm.kv.MinAnimTime = 5
	arm.kv.MaxAnimTime = 10

	arm.SetModel( DP_ARM_MODEL )
	arm.SetOrigin( origin )

	DispatchSpawn( arm, false )

	arm.SetParent( pod, "ARM", false )

	return arm
}


function DropPodOpenDoor( pod, door )
{
	door.ClearParent()

	// update origin/angles
	local attachment = "hatch"
	local attachIndex = pod.LookupAttachment( attachment )

	local origin = pod.GetAttachmentOrigin( attachIndex )
	local angles = pod.GetAttachmentAngles( attachIndex )
	local right = angles.AnglesToRight()

	local phys_hinge = CreateEntity( "phys_hinge" )
	// Start inactive
	phys_hinge.kv.spawnflags = 4
	phys_hinge.SetName( "droppod_hinge" )
	phys_hinge.kv.attach1 = pod.GetName()
	phys_hinge.kv.attach2 = door.GetName()
	phys_hinge.kv.forcelimit = 99999
	phys_hinge.kv.torquelimit = 99999
	phys_hinge.kv.SystemLoadScale = 1
	phys_hinge.kv.minSoundThreshold = 6
	phys_hinge.kv.maxSoundThreshold = 80
	//phys_hinge.kv.Friction = 2000 friction does nothing apparently
	phys_hinge.kv.origin = origin.x + " " + origin.y + " " + origin.z

	local hingeOrg = origin + right * 16
	phys_hinge.kv.hingeaxis = hingeOrg.x + " " + hingeOrg.y + " " + hingeOrg.z

	DispatchSpawn( phys_hinge, false )
	pod.s.hinge <- phys_hinge

	phys_hinge.SetOrigin( origin )
	phys_hinge.SetAngles( angles )
	//phys_hinge.SetParent( pod, "HATCH", false )
	phys_hinge.Fire( "turnon" )

	EmitSoundOnEntity( pod, "droppod_door_open" )

	phys_hinge.Fire( "SetAngularVelocity", 200 )
}


function DropPodRotates( pod, turret, player )
{
	pod.EndSignal( "OnDestroy" )
	turret.EndSignal( "OnDestroy" )
	player.EndSignal( "Disconnected" )

	local yaw = 0
	local dif = 5
	local turret_yaw

	local pitch = 0

	local index = pod.LookupPoseParameterIndex( "Aim_yaw" )

	local attachment = "ATTACH"
	local attachIndex = pod.LookupAttachment( attachment )

	wait 0.5 // bad things happen otherwise

	pod.s.yawpos <- 0

	local turretAttachIndex = turret.LookupAttachment( attachment )

	while ( !pod.IsFlagSet( "OpenDoor" ) )
	{
		DropPodRotateFunction( pod, turret, index, attachIndex, turretAttachIndex )

		wait 0 // wait one frame
	}

	for ( ;; )
	{
		pod.SetPoseParameter( index, pod.s.yawpos )

		wait 0
	}
}

// this function should be replaced with a bind-poseparms-to-ent sort of command
function DropPodRotateFunction( pod, turret, index, attachIndex, turretAttachIndex )
{
	local yaw
	yaw = turret.GetAttachmentAngles( turretAttachIndex ).y
	yaw -= pod.GetAngles().y
	yaw = AngleNormalize( yaw + 0 ) // 100 // 135

	pod.SetPoseParameter( index, yaw )
	pod.s.yawpos = yaw
}


function GuyHangsInPod( guy, pod )
{
	guy.EndSignal( "OnDeath" )
	guy.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( guy, pod )
		{
			if ( IsAlive( guy ) )
				delete guy.s.pod

			pod.s.numGuys--
		}
	)

	pod.s.numGuys++
	guy.s.pod <- pod

	if ( !pod.IsFlagSet( "OpenDoor" ) )
	{
		guy.SetEfficientMode( true )

		guy.SetParent( pod, "ATTACH", false )
		guy.Anim_ScriptedPlay( GetAnim( guy, "drop_pod_idle_anim" ) )

		pod.WaitFlag( "OpenDoor" )

		//wait POST_TURRET_DELAY

		guy.SetEfficientMode( false )
	}

	guy.SetParent( pod, "ATTACH", false )
	guy.Anim_ScriptedPlay( GetAnim( guy, "drop_pod_exit_anim" ) )
	guy.ClearParent()

	guy.WaittillAnimDone()
	guy.Signal( "npc_deployed" )
}


function PlayerControlsDropPod( player, pod )
{
	player.EndSignal( "Disconnected" )

	// slight delay before allowing exit
	wait 0.5

	player.ShowHint( "Exit Drop Pod", "+jump" )

	waitthread WaitForPlayerExit( player )

	player.HideHint()

	pod.SetFlag( "OpenDoor" )
}


function GetTracePositions( trace, origin, forward, classHull, door )
{
	trace.start <- origin + forward * 50
	trace.end <- origin + forward * 130

	trace.end.z += 22
	trace.start.z += 22

	trace.frac <- TraceHullSimple( trace.start, trace.end, level.traceMins[ classHull ], level.traceMaxs[ classHull ], door )
}


function WaitForPlayerExitButtonPressed( player )
{
	player.EndSignal( "Disconnected" )

	wait FIRETEAM_DROPPOD_FORCE_EXIT // forced out of droppod
}


function WaitForPlayerExit( player )
{
	local classHull = level.classHulls[ "fireteam" ]
	local origin, angles, forward
	local trace = {}
	local pod = player.s.pod

	local attachment = "ATTACH"
	local attachIndex = pod.LookupAttachment( attachment )

	for ( ;; )
	{
		waitthreadsolo WaitForPlayerExitButtonPressed( player )

		origin = pod.GetAttachmentOrigin( attachIndex )
		angles = pod.GetAttachmentAngles( attachIndex )
		forward = angles.AnglesToForward()

		GetTracePositions( trace, origin, forward, classHull, pod.s.door )

		if ( trace.frac == 1 )
			break;
	}
}


function CreateViewModel( player )
{
	local viewmodel = CreateEntity( "prop_dynamic" )
	viewmodel.kv.model = DEFAULT_VIEW_MODEL
	viewmodel.kv.fadedist = -1
	viewmodel.kv.rendercolor = "255 255 255"
	viewmodel.kv.renderamt = 255
	viewmodel.kv.solid = 0 //not solid
	viewmodel.kv.MinAnimTime = 5
	viewmodel.kv.MaxAnimTime = 10
	viewmodel.kv.VisibilityFlags = 1 // ONLY VISIBLE TO PLAYER
	DispatchSpawn( viewmodel, false )

	viewmodel.SetOrigin( player.GetOrigin() )
	viewmodel.SetOwner( player )

	player.SetViewOffsetEntity( viewmodel )
	viewmodel.Fire( "DisableDraw" )

	player.s.viewmodel <- viewmodel

	return viewmodel
}
