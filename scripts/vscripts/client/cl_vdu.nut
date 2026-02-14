const STATIC_BLEND_IN = 12
const STATIC_BLEND_OUT = 6
const STATIC_MAX_ALPHA = 0.5

PrecacheHUDMaterial( "HUD/vdu_hud_monitor_widescreen" )
PrecacheHUDMaterial( "HUD/vdu_shape_widescreen" )

function main()
{
	Globalize( SetupVDU )
	Globalize( ShowVDU )
	Globalize( HideVDU )
	Globalize( UpdateVDUVisibility )
	Globalize( StaticOnThread )
	Globalize( StaticOffThread )
	Globalize( ClearVDUCharacter )
	Globalize( CreateVDUCharacter )

	Globalize( LockVDU )
	Globalize( UnlockVDU )
	Globalize( IsLockedVDU )
	Globalize( SetVDUStatic )
	Globalize( ClearVDUStatic )
	Globalize( ZoomCameraOverTime )
	Globalize( RotateCameraOverTime )
	Globalize( PivotCameraOverTime )
	Globalize( MoveCameraOverTime )
	Globalize( ShakeCamera )
	Globalize( DelayedUnlockVDU )
	Globalize( TrackEntityWithCamera )
	Globalize( TrackEntityWithMovingCamera )
	Globalize( TrackPointWithMovingCamera )
	Globalize( GetVDUCamTrackAngles )
	Globalize( FollowEntityWithCamera )

	Globalize( SetNextVDUWideScreen )

	Globalize( ServerCallback_EntityVDUCam )

	AddKillReplayStartedCallback( HideVDU )

	RegisterSignal( "VDUStatic" )
	RegisterSignal( "StartNewVDU" )
	RegisterSignal( "ZoomCameraOverTime" )
	RegisterSignal( "PivotCameraOverTime" )
	RegisterSignal( "ShakeCamera" )
	RegisterSignal( "RotateCameraOverTime" )
	RegisterSignal( "MoveCameraOverTime" )

	const DEFAULT_VDU_ANIM = "diag_vdu_default"

	level.camera <- null

	level.vduCameraRef <- null
	level.vduCharacterRef <- null

	level.vduActive <- false
	level.vduStatic <- 0.0
	level.vduCustomStatic <- null
	level.vduLocked <- false
	level.vduEnabled <- false

	level._vduCharacter <- null
}


function CalcVDUPosition( vduOrigin, angles )
{
	local VDU_OFFSET_FORWARD = 8
	local VDU_OFFSET_RIGHT = -7
	local VDU_OFFSET_UP = 0

	local forward = angles.AnglesToForward()
	local right = angles.AnglesToRight()
	local up = angles.AnglesToUp()

	vduOrigin += (forward * VDU_OFFSET_FORWARD)
	vduOrigin += (right * VDU_OFFSET_RIGHT)
	vduOrigin += (up * VDU_OFFSET_UP)

	return vduOrigin
}


function CalcVDUAngles( angles )
{
	angles = angles.AnglesCompose( Vector( 0, 25, 0 ) );

	return angles
}


function SetupVDU( player )
{
	// the vdu_room instance changed to use info_target_clientside
	// supporting both for now.
	local targets = GetClientEntArrayBySignifier( "info_target_clientside" )
	targets.extend( GetClientEntArrayBySignifier( "info_target" ) )

	foreach ( target in targets )
	{
		if ( target.GetName() == "vdu_camera_ref" )
			level.vduCameraRef = target
		else if ( target.GetName() == "vdu_character_ref" )
			level.vduCharacterRef = target
	}

	if ( !level.vduCameraRef || !level.vduCharacterRef )
	{
		level.vduEnabled = false
		return
	}
	level.vduEnabled = true

	local vduOrigin = CalcVDUPosition( player.CameraPosition(), player.CameraAngles() )
	local vduAngles = CalcVDUAngles( player.CameraAngles() )

	local vduModel

	if ( IsValid( level.camera ) )
		level.camera.Kill()

	local vduCamera
	if ( !level.vduCameraRef )
	{
		vduCamera = CreateClientSidePointCamera( Vector( 0, 0, 0 ), Vector( 0, 0, 0 ), 50 )
	}
	else
	{
		vduCamera = CreateClientSidePointCamera( level.vduCameraRef.GetOrigin(), level.vduCameraRef.GetAngles(), 50 )
		vduCamera.SetOrigin( level.vduCameraRef.GetOrigin() )
		vduCamera.SetAngles( level.vduCameraRef.GetAngles() )
	}

	level.camera = vduCamera

	player.s._customVDUStyle <- ""
	player.s._lastVDUStyle <- null
}

function VDUShouldBeVisible( player )
{
	if ( !level.vduActive )
		return false

	if ( IsLockedVDU() )
		return true

	return !player.SniperCam_IsActive()
}

function UpdateVDUVisibility( player )
{
	local cockpit =  player.GetCockpit()

	if ( !cockpit  )
		return

	local titanModel = IsTitanCockpitModelName( cockpit.GetModelName() )
	if ( titanModel && !player.IsTitan() )
		return

	local mainVGUI = cockpit.GetMainVGUI()
	if ( !mainVGUI )
		return

	UpdateVGUIVDUVisibility( player, mainVGUI )
}

function UpdateVGUIVDUVisibility( player, mainVGUI )
{
	local vduShouldBeVisible = VDUShouldBeVisible( player )
	local mainVGUIVDUOpen  = mainVGUI.s.vduOpen
	if ( mainVGUIVDUOpen && !vduShouldBeVisible )
	{
		DeactivateVDUModel( player, mainVGUI )
	}
	else if ( !mainVGUIVDUOpen && vduShouldBeVisible )
	{
		ActivateVDUModel( player, mainVGUI )
	}
	else if ( mainVGUIVDUOpen && vduShouldBeVisible && player.s._customVDUStyle != player.s._lastVDUStyle )
	{
		ActivateVDUModel( player, mainVGUI )
	}
}


function ActivateVDUModel( player, mainVGUI )
{
	level.camera.SetActive( true )

	mainVGUI.s.vduOpen = true

	mainVGUI.s.VDU_ScreenGroup.Show()
	ActivateVDUModelStyle( player, mainVGUI )
}


function ActivateVDUModelStyle( player, mainVGUI  )
{
	switch ( player.s._customVDUStyle )
	{
		case "Style_WideScreenVDU":
			ActivateWideScreenVDUStyle( mainVGUI )
			break

		case "OpenPilotVDU":
		default:
			ActivatePilotVDUStyle( mainVGUI )
			break
	}

	player.s._lastVDUStyle = player.s._customVDUStyle
	EmitSoundOnEntity( player, "VDU_On" )
}

function ActivateWideScreenVDUStyle( mainVGUI )
{
	local pos = mainVGUI.s.VDU_ScreenGroup.GetBasePos()

	mainVGUI.GetPanel().RunAnimationScript( "OpenWidescreenVDU" )
	mainVGUI.s.VDU_Screen.SetPos( pos[ 0 ] - 20, pos[ 1 ] )
	mainVGUI.s.VDU_Screen.SetImage( "HUD/vdu_hud_monitor_widescreen" )
	mainVGUI.s.VDU_FG.SetImage( "HUD/vdu_shape_widescreen" )

}

function ActivatePilotVDUStyle( mainVGUI )
{
	mainVGUI.s.VDU_ScreenGroup.ReturnToBasePos()
	mainVGUI.s.VDU_Screen.SetImage( "HUD/vdu_hud_monitor" )
	mainVGUI.s.VDU_FG.SetImage( "HUD/vdu_shape" )
	mainVGUI.GetPanel().RunAnimationScript( "OpenPilotVDU" )
}

function SetNextVDUWideScreen( player )
{
	player.s._customVDUStyle = "Style_WideScreenVDU"
}

function DeactivateVDUModel( player, mainVGUI )
{
	level.camera.SetActive( false )

	mainVGUI.s.vduOpen = false

	mainVGUI.GetPanel().RunAnimationScript( "ClosePilotVDU" )

	player.s._customVDUStyle = "" //reset so we can never forget to go back to normal
	EmitSoundOnEntity( player, "VDU_Off" )
}

function ClearVDUCharacter( player )
{
	if ( IsValid( level._vduCharacter ) )
		level._vduCharacter.Destroy()
}


function DestroyTitanVDU( cockpit )
{
	cockpit.EndSignal( "OnDestroy" )
	cockpit.s.vduVGUI.EndSignal( "StartNewVDU" )
	cockpit.s.vduVGUI.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function () : ( cockpit )
		{
			if ( !IsValid( cockpit ) )
				return
			if ( !( "vduVGUI" in cockpit.s ) )
				return
			if ( IsValid( cockpit.s.vduVGUI ) )
				return

			delete cockpit.s.vduVGUI
		}
	)

	wait 1

	local vgui = cockpit.s.vduVGUI
	delete cockpit.s.vduVGUI
	vgui.Destroy()
}

function SetVDUStatic( amt )
{
	level.vduCustomStatic = STATIC_LIGHT

	local player = GetLocalViewPlayer()
	local cockpit = player.GetCockpit()
	if ( !cockpit )
		return
	local mainVGUI = cockpit.GetMainVGUI()
	if ( !mainVGUI )
		return

	mainVGUI.s.VDU_Static.Show()
}

function ClearVDUStatic()
{
	level.vduCustomStatic = null

	local player = GetLocalViewPlayer()
	local cockpit = player.GetCockpit()
	if ( !cockpit )
		return
	local mainVGUI = cockpit.GetMainVGUI()
	if ( !mainVGUI )
		return
	mainVGUI.s.VDU_Static.Hide()
}


function ShowVDU( vduName = null )
{
	local player = GetLocalViewPlayer()
	if ( !IsValid( player ) )
		return

	player.Signal( "vdu_open" )

  	// reset static
 	player.Signal( "VDUStatic" )
	level.vduCustomStatic = null
	level.vduStatic = 0.0
	level.vduActive = true
	UpdateVDUVisibility( player )

	local cockpit = player.GetCockpit()
	if ( IsValid( cockpit ) )
	{
		local mainVGUI = cockpit.GetMainVGUI()
		if ( mainVGUI )
			mainVGUI.s.VDU_Static.Hide()
	}

	if ( !level.vduCameraRef || !level.vduCharacterRef )
	{
		StaticOn( player )
		return
	}

	ClearVDUCharacter( player )

	if ( !vduName )
		return

	CreateVDUCharacter( player, vduName )
}

function CreateVDUCharacter( player, vduName, anim = DEFAULT_VDU_ANIM )
{
	level.camera.SetFOV( 60 ) // default

	level._vduCharacter = CreateClientSidePropDynamic( level.vduCharacterRef.GetOrigin(), level.vduCharacterRef.GetAngles(), level.vduModels[ vduName ] );
	level._vduCharacter.SetOrigin( level.vduCharacterRef.GetOrigin() + Vector( 0, 0, 16 ) )
	level._vduCharacter.SetAngles( level.vduCharacterRef.GetAngles() )

	local attachID = level._vduCharacter.LookupAttachment( "VDU" )
	Assert(attachID > 0, level._vduCharacter + " has no VDU attachment!")

	local vduOrigin = level._vduCharacter.GetAttachmentOrigin( attachID )
	local vduAngles = level._vduCharacter.GetAttachmentAngles( attachID )

	level.camera.SetOrigin( vduOrigin )
	level.camera.SetAngles( vduAngles )
	level.camera.SetParent( level._vduCharacter, "VDU" )

	AddAnimEvent( level._vduCharacter, "vdu_static_on", StaticOn )
	AddAnimEvent( level._vduCharacter, "vdu_static_off", StaticOff )
	AddAnimEvent( level._vduCharacter, "vdu_random_static_on", RandomStaticOn )
	AddAnimEvent( level._vduCharacter, "vdu_random_static_off", RandomStaticOff )

	level._vduCharacter.Anim_NonScriptedPlay( anim )
}

function HideVDU()
{
	local player = GetLocalClientPlayer() //Not supporting VDUs during kill replays.
	if ( !IsValid( player ) )
		return
	level.vduActive = false
	UpdateVDUVisibility( player )
}

function StaticOn( player )
{
	player.Signal( "VDUStatic" )
	thread StaticOnThread( player )
}

function StaticOnThread( player )
{
	player.EndSignal( "VDUStatic" )
	for( local i = 0; i < STATIC_BLEND_IN; i++ )
	{
		level.vduStatic = Graph(  i, 0, STATIC_BLEND_IN, 0, STATIC_MAX_ALPHA )
		wait 0
	}
}

function StaticOff( player )
{
	player.Signal( "VDUStatic" )
	thread StaticOffThread( player )
}

function StaticOffThread( player )
{
	player.EndSignal( "VDUStatic" )
	local index = Graph(  level.vduStatic, 0, STATIC_MAX_ALPHA, 0, STATIC_BLEND_OUT ).tointeger()
	for( local i = index; i >= 0; i-- )
	{
		level.vduStatic = Graph(  i, 0, STATIC_BLEND_OUT, 0, STATIC_MAX_ALPHA )
		wait 0
	}
}

function RandomStaticOn( player )
{
	level.vduCustomStatic = STATIC_RANDOM
}

function RandomStaticOff( player )
{
	level.vduCustomStatic = null
}



function ServerCallback_EntityVDUCam( camEntHandle, optionalParm = null )
{
	local camEnt = GetEntityFromEncodedEHandle( camEntHandle )
	if ( !IsValid( camEnt ) )
		return
	if ( !( "vduFunc" in camEnt.s ) )
	{
		printt( "Tried ServerCallback_EntityVDUCam but " + camEnt + " has no .s.vduFunc" )
		return
	}

	thread ServerCallback_EntityVDUCamThread( camEnt, optionalParm )
}

function ServerCallback_EntityVDUCamThread( camEnt, optionalParm = null )
{
	local player = GetLocalViewPlayer()
	if ( IsLockedVDU() )
		return

	if ( optionalParm != null )
	{
		camEnt.s.vduFunc( camEnt, optionalParm )
	}
	else
	{
		camEnt.s.vduFunc( camEnt )
	}
}

function IsLockedVDU()
{
	return level.vduLocked
}

function LockVDU()
{
	// kill active conversations
	CancelConversation( GetLocalViewPlayer() )
	Assert( !level.vduLocked, "Already locked" )
	level.vduLocked	= true
}

function UnlockVDU()
{
	Assert( level.vduLocked, "Not locked" )
	level.vduLocked	= false
}

function ZoomCameraOverTime( player, startFov, endFov, zoomTime, easeIn = 0, easeOut = 0 )
{
	player.Signal( "ZoomCameraOverTime" )
	player.EndSignal( "ZoomCameraOverTime" )
	player.EndSignal( "OnDestroy" )

	local startTime = Time()

	for ( ;; )
	{
		local dif = Interpolate( startTime, zoomTime, easeIn, easeOut )
		local fov = GraphCapped( dif, 0.0, 1.0, startFov, endFov )
		level.camera.SetFOV( fov )
		if ( dif >= 1.0 )
			break
		wait 0
	}
}

function PivotCameraOverTime( player, origin, startAng, endAng, startRadius, endRadius, pivotTime, easeIn = 0, easeOut = 0 )
{
	player.Signal( "PivotCameraOverTime" )
	player.EndSignal( "PivotCameraOverTime" )
	player.EndSignal( "OnDestroy" )

	local startAngX = startAng.x
	local startAngY = startAng.y
	local startAngZ = startAng.z

	local endAngX = endAng.x
	local endAngY = endAng.y
	local endAngZ = endAng.z

	local startTime = Time()

	for ( ;; )
	{
		//calculate the difference
		local dif = Interpolate( startTime, pivotTime, easeIn, easeOut )

		//calculate the new angle
		local newAngX = GraphCapped( dif, 0.0, 1.0, startAngX, endAngX )
		local newAngY = GraphCapped( dif, 0.0, 1.0, startAngY, endAngY )
		local newAngZ = GraphCapped( dif, 0.0, 1.0, startAngZ, endAngZ )
		local newAng = Vector( newAngX, newAngY, newAngZ )

		//get the new forward
		local forward = newAng.AnglesToForward()

		//recalculate the start position based on new angles
		local start = origin + ( forward * startRadius )
		local startX = start.x
		local startY = start.y
		local startZ = start.z

		//recalculate the end position based on new angles
		local end = origin + ( forward * endRadius )
		local endX = end.x
		local endY = end.y
		local endZ = end.z

		//interpolate the new position
		local newX = GraphCapped( dif, 0.0, 1.0, startX, endX )
		local newY = GraphCapped( dif, 0.0, 1.0, startY, endY )
		local newZ = GraphCapped( dif, 0.0, 1.0, startZ, endZ )
		local newOrg = Vector( newX, newY, newZ )

		level.camera.SetOrigin( newOrg )

		if ( dif >= 1.0 )
			break

		wait 0
	}
}

function RotateCameraOverTime( player, startAng, endAng, rotateTime, easeIn = 0, easeOut = 0 )
{
	player.Signal( "RotateCameraOverTime" )
	player.EndSignal( "RotateCameraOverTime" )
	player.EndSignal( "OnDestroy" )

	local startX = startAng.x
	local startY = startAng.y
	local startZ = startAng.z

	local endX = endAng.x
	local endY = endAng.y
	local endZ = endAng.z

	local startTime = Time()

	for ( ;; )
	{
		local dif = Interpolate( startTime, rotateTime, easeIn, easeOut )

		local newX = GraphCapped( dif, 0.0, 1.0, startX, endX )
		local newY = GraphCapped( dif, 0.0, 1.0, startY, endY )
		local newZ = GraphCapped( dif, 0.0, 1.0, startZ, endZ )
		local newAng = Vector( newX, newY, newZ )

		level.camera.SetAngles( newAng )

		if ( dif >= 1.0 )
			break

		wait 0
	}
}

function ShakeCamera( player, baseOrigin, amplitude, frequency, duration )
{
	player.Signal( "ShakeCamera" )
	player.EndSignal( "ShakeCamera" )
	player.EndSignal( "OnDestroy" )

	local endTime = Time() + duration
	local startOrigin
	local cycleTime = 1.0 / frequency.tofloat()

	for ( ;; )
	{
		if ( Time() > endTime )
			break

		local x = RandomFloat( 0.0,360.0 )
		local y = RandomFloat( 0.0,360.0 )
		local z = RandomFloat( 0.0,360.0 )
		local angles = Vector( x, y, z )

		local dir = angles.AnglesToForward()
		local offset = dir * RandomFloat( amplitude.tofloat() * 0.5, amplitude.tofloat() )
		local endOrg 	= baseOrigin + offset

		waitthread MoveCameraOverTime( player, level.camera.GetOrigin(), endOrg, cycleTime, cycleTime * 0.5, cycleTime * 0.5 )
	}

	waitthread MoveCameraOverTime( player, level.camera.GetOrigin(), baseOrigin, cycleTime, cycleTime * 0.5, cycleTime * 0.5 )
}

function MoveCameraOverTime( player, startOrg, endOrg, moveTime, easeIn = 0, easeOut = 0 )
{
	player.Signal( "MoveCameraOverTime" )
	player.EndSignal( "MoveCameraOverTime" )
	player.EndSignal( "OnDestroy" )

	local startX = startOrg.x
	local startY = startOrg.y
	local startZ = startOrg.z

	local endX = endOrg.x
	local endY = endOrg.y
	local endZ = endOrg.z

	local startTime = Time()

	for ( ;; )
	{
		local dif = Interpolate( startTime, moveTime, easeIn, easeOut )

		local newX = GraphCapped( dif, 0.0, 1.0, startX, endX )
		local newY = GraphCapped( dif, 0.0, 1.0, startY, endY )
		local newZ = GraphCapped( dif, 0.0, 1.0, startZ, endZ )
		local newOrg = Vector( newX, newY, newZ )

		level.camera.SetOrigin( newOrg )

		if ( dif >= 1.0 )
			break

		wait 0
	}
}


function DelayedUnlockVDU( delay )
{
	HideVDU()
	wait delay
	UnlockVDU()
}

function FollowEntityWithCamera( player, entity, time, angles, offset )
{
	player.Signal( "vdu_open" )
	player.EndSignal( "vdu_open" )
	player.EndSignal( "OnDestroy" )

	entity.EndSignal( "OnDeath" )
	entity.EndSignal( "OnDestroy" )

	level.camera.SetAngles( angles )
	local endTime = Time() + time

	for ( ;; )
	{
		if ( Time() > endTime )
			break

		level.camera.SetOrigin( entity.GetOrigin() + offset )
		wait 0
	}
}

function TrackEntityWithCamera( player, camOrg, entity, time, forwardDist = 0, rightDist = 0, upDist = 0 )
{
	player.Signal( "vdu_open" )
	player.EndSignal( "vdu_open" )
	player.EndSignal( "OnDestroy" )

	entity.EndSignal( "OnDeath" )
	entity.EndSignal( "OnDestroy" )

	level.camera.SetOrigin( camOrg )
	local endTime = Time() + time

	for ( ;; )
	{
		if ( Time() > endTime )
			break

		UpdateVDUCamTracker( player, camOrg, entity, forwardDist, rightDist, upDist )
		wait 0
	}
}

function TrackEntityWithMovingCamera( player, entity, time, forwardDist = 0, rightDist = 0, upDist = 0 )
{
	player.Signal( "vdu_open" )
	player.EndSignal( "vdu_open" )
	player.EndSignal( "OnDestroy" )

	entity.EndSignal( "OnDeath" )
	entity.EndSignal( "OnDestroy" )

	local endTime = Time() + time

	for ( ;; )
	{
		if ( Time() > endTime )
			break

		UpdateVDUCamTracker( player, level.camera.GetOrigin(), entity, forwardDist, rightDist, upDist )
		wait 0
	}
}

function TrackPointWithMovingCamera( player, point, time )
{
	player.Signal( "vdu_open" )
	player.EndSignal( "vdu_open" )
	player.EndSignal( "OnDestroy" )

	local endTime = Time() + time

	for ( ;; )
	{
		if ( Time() > endTime )
			break

		local vec = point - level.camera.GetOrigin()
		local angles = VectorToAngles( vec )
		level.camera.SetAngles( angles )
		wait 0
	}
}

function GetVDUCamTrackAngles( camOrg, entity, forwardDist = 0, rightDist = 0, upDist = 0 )
{
	local origin = entity.GetOrigin()
	local entAngles = entity.GetAngles()

	if ( forwardDist )
		origin += ( entAngles.AnglesToForward() * forwardDist )

	if ( rightDist )
		origin += ( entAngles.AnglesToRight() * rightDist )

	if ( upDist )
		origin += ( entAngles.AnglesToUp() * upDist )

	local vec = origin - camOrg
	return VectorToAngles( vec )
}

function UpdateVDUCamTracker( player, camOrg, entity, forwardDist = 0, rightDist = 0, upDist = 0 )
{
	local angles = GetVDUCamTrackAngles( camOrg, entity, forwardDist, rightDist, upDist )
	//DebugDrawLine( camOrg, origin, 255, 0, 0, true, 0.2 )
	//DrawArrow( camOrg, angles, 0.2, 350 )
	level.camera.SetAngles( angles )
}