
const SMART_AMMO_VICTIM_LOCKED_SOUND = "redeye.turret_alarm"  // sound the lockon detector uses to tell players they've been locked

//Auto-Lock Missiles - mp_titanweapon_homing_rockets
const SMART_AMMO_AUTOLOCK_SOUND_TARGET_ACQUIRE 		= "ShoulderRocket_Homing_AcquireTarget"
const SMART_AMMO_AUTOLOCK_SOUND_TARGET_LOCKED_LOOP 	= "ShoulderRocket_Homing_TargetLocked"

//Homing Rockets - mp_titanweapon_shoulder_rockets
const SMART_AMMO_HOMING_SOUND_TARGET_ACQUIRE 		= "Weapon_SmartAmmo_TargetLockingLoop"
const SMART_AMMO_HOMING_SOUND_TARGET_LOCKED 		= "ShoulderRocket_Paint"

const SMART_AMMO_DEFAULT_SOUND_PILOT_LOCKED 		= "Weapon_SmartAmmo.PilotLocked"
const SMART_AMMO_DEFAULT_SOUND_TARGET_ACQUIRE 		= "Weapon_SmartAmmo_TargetLockingLoop"

const SMART_AMMO_ARCHER_SOUND_TARGET_LOCKED_LOOP 	= "titan_missle_lock_tone"



const SMART_AMMO_COLOR_NO_TARGET			= "200 200 200 128"
const SMART_AMMO_COLOR_LOCKING 				= "255 182 55 128"
const SMART_AMMO_COLOR_LOCKED	 			= "255 58 12 128"
const SMART_AMMO_STATUS_TEXT_NO_TARGET		= ""
const SMART_AMMO_STATUS_TEXT_LOCKING		= "#HUD_LOCKING"
const SMART_AMMO_STATUS_TEXT_LOCKED			= "#HUD_TARGET_LOCKED"
const SMART_AMMO_STATUS_TEXT_NO_LOCK		= "NO LOCK"
const SMART_AMMO_STATUS_TEXT_LOCKED_LIMITED	= "TARGET LOCKED\nLOW AMMO"

const SMART_AMMO_LINE_DEVIATION_HORIZONTAL 	= 40
const SMART_AMMO_LINE_DEVIATION_VERTICAL 	= 20
const SMART_AMMO_LINE_COLOR_ACQUIRING 		= "153 190 246 128"
const SMART_AMMO_LINE_COLOR_LOCKED 			= "255 20 20 255"
const SMART_AMMO_TRIANGLE_ACQUIRING			= "255 240 10 255"

const AUTO_LOCK_READY_TO_FIRE_COLOR		= "255 182 55 128"
const AUTO_LOCK_ON_COOLDOWN_COLOR		= "255 255 255 20"

const HOMING_ROCKET_MAX_MISSILE_COUNT		= 12
const HOMING_ROCKET_MAX_MISSILE_COUNT_BURN 	= 18

// lockon detector won't alert until this much of the total lock time has passed
SmartAmmo_DetectorStartFracOverrides <- {}
//SmartAmmo_DetectorStartFracOverrides[ "mp_weapon_smart_pistol" ] <- (SMART_AMMO_PLAYER_MAX_LOCKS - 1) * 0.25
// HAX; make smart pistol not display lock indicator

SmartAmmo_DetectorStartFracOverrides[ "mp_weapon_smart_pistol" ] <- 0.0  // DISABLED, was 1200.0
SmartAmmo_DetectorStartFracOverrides[ "mp_weapon_rocket_launcher" ] <- 0.0
SmartAmmo_DetectorStartFracOverrides[ "mp_titanweapon_shoulder_rockets" ] <- 0.8
SmartAmmo_DetectorStartFracOverrides[ "mp_titanweapon_homing_rockets" ] <- 0.8

SmartAmmo_AcquireVecDirections <- {}
SmartAmmo_AcquireVecDirections[0] <- Vector( 0.866, 0.5, 0 )
SmartAmmo_AcquireVecDirections[1] <- Vector( -0.866, 0.5, 0 )
SmartAmmo_AcquireVecDirections[2] <- Vector( 0, -1, 0 )

COLOR_LOCKING <- StringToColors( SMART_AMMO_COLOR_LOCKING )
COLOR_LOCKED <- StringToColors( SMART_AMMO_COLOR_LOCKED )
COLOR_NO_TARGET <- StringToColors( SMART_AMMO_COLOR_NO_TARGET )
COLOR_DEBUGLINE_ACQUIRING <- StringToColors( SMART_AMMO_LINE_COLOR_ACQUIRING )
COLOR_DEBUGLINE_LOCKED <- StringToColors( SMART_AMMO_LINE_COLOR_LOCKED )
COLOR_TRIANGLE_ACQUIRING <- StringToColors( SMART_AMMO_TRIANGLE_ACQUIRING )

const SMART_AMMO_MAX_TARGETS = 5 //Set to the max used by any smart weapon.

autoLockCornersGroup <- null
autoLockCorners <- []
activeHomingRocketsGroup <- null
activeHomingRockets <- []
activeHomingRocketsText <- null
activeHomingRocketsTicker <- []


//These elements are for locking reticles that are centered around the bounding box.
missileLockElemInfo <- {}
missileLockElemInfo[0] <- { 	pos = [0,1], 	rotation = 0, 		moveX = -0.8, 	moveY = -0.8, 	startScale = 0.5, 	endScale = 1.0, 	startAlpha = 0.5,	fracStart = 0.2, 	fracEnd = 0.4 	}
missileLockElemInfo[1] <- { 	pos = [0,1], 	rotation = 0, 		moveX = -0.9, 	moveY = -0.9, 	startScale = 0.5, 	endScale = 1.0, 	startAlpha = 0.5,	fracStart = 0.4, 	fracEnd = 0.6 	}
missileLockElemInfo[2] <- { 	pos = [0,1], 	rotation = 0, 		moveX = -1.0, 	moveY = -1.0, 	startScale = 0.5, 	endScale = 1.0, 	startAlpha = 0.5,	fracStart = 0.8, 	fracEnd = 1.0 	}
missileLockElemInfo[3] <- { 	pos = [2,1], 	rotation = 270, 	moveX = 0.8, 	moveY = -0.8, 	startScale = 0.5, 	endScale = 1.0, 	startAlpha = 0.5,	fracStart = 0.2, 	fracEnd = 0.4 	}
missileLockElemInfo[4] <- { 	pos = [2,1], 	rotation = 270, 	moveX = 0.9, 	moveY = -0.9, 	startScale = 0.5, 	endScale = 1.0, 	startAlpha = 0.5,	fracStart = 0.4, 	fracEnd = 0.6 	}
missileLockElemInfo[5] <- { 	pos = [2,1], 	rotation = 270, 	moveX = 1.0, 	moveY = -1.0, 	startScale = 0.5, 	endScale = 1.0, 	startAlpha = 0.5,	fracStart = 0.8, 	fracEnd = 1.0 	}
missileLockElemInfo[6] <- { 	pos = [0,3], 	rotation = 90, 		moveX = -0.8, 	moveY = 0.8, 	startScale = 0.5, 	endScale = 1.0, 	startAlpha = 0.5,	fracStart = 0.2, 	fracEnd = 0.4 	}
missileLockElemInfo[7] <- { 	pos = [0,3], 	rotation = 90, 		moveX = -0.9, 	moveY = 0.9, 	startScale = 0.5, 	endScale = 1.0, 	startAlpha = 0.5,	fracStart = 0.4, 	fracEnd = 0.6 	}
missileLockElemInfo[8] <- { 	pos = [0,3], 	rotation = 90, 		moveX = -1.0, 	moveY = 1.0, 	startScale = 0.5, 	endScale = 1.0, 	startAlpha = 0.5,	fracStart = 0.8, 	fracEnd = 1.0 	}
missileLockElemInfo[9] <- { 	pos = [2,3], 	rotation = 180, 	moveX = 0.8, 	moveY = 0.8, 	startScale = 0.5, 	endScale = 1.0, 	startAlpha = 0.5,	fracStart = 0.2, 	fracEnd = 0.4 	}
missileLockElemInfo[10] <- { 	pos = [2,3], 	rotation = 180, 	moveX = 0.9, 	moveY = 0.9, 	startScale = 0.5, 	endScale = 1.0, 	startAlpha = 0.5,	fracStart = 0.4, 	fracEnd = 0.6 	}
missileLockElemInfo[11] <- { 	pos = [2,3], 	rotation = 180, 	moveX = 1.0, 	moveY = 1.0, 	startScale = 0.5, 	endScale = 1.0, 	startAlpha = 0.5,	fracStart = 0.8, 	fracEnd = 1.0 	}

//These elements are for the center static elements moving towards the Titan when you acquire a lock.
autoLockNoTargetElemInfo <- {}
autoLockNoTargetElemInfo[0] <- { 	pos = [0,1], 	rotation = 0, 		moveX = -0.8, 	moveY = -0.8, 	startScale = 1.0, 	endScale = 0.5, 	startAlpha = 0.5,	fracStart = 0.0, 	fracEnd = 0.2 	}
autoLockNoTargetElemInfo[1] <- { 	pos = [0,3], 	rotation = 90,	 	moveX = -0.8, 	moveY = 0.8, 	startScale = 1.0, 	endScale = 0.5, 	startAlpha = 0.5,	fracStart = 0.0, 	fracEnd = 0.2 	}
autoLockNoTargetElemInfo[2] <- { 	pos = [2,3], 	rotation = 180,	 	moveX = 1.0, 	moveY = 1.0, 	startScale = 1.0, 	endScale = 0.5, 	startAlpha = 0.5,	fracStart = 0.0, 	fracEnd = 0.2 	}
autoLockNoTargetElemInfo[3] <- { 	pos = [2,1], 	rotation = 270, 	moveX = 1.0, 	moveY = -1.0, 	startScale = 1.0, 	endScale = 0.5, 	startAlpha = 0.5,	fracStart = 0.0, 	fracEnd = 0.2 	}

const OFFSET_AMPLITUDE = 50
homingRocketOffsets <- []
homingRocketOffsets.append( Vector( OFFSET_AMPLITUDE * RandomFloat( 0, 0 ), OFFSET_AMPLITUDE * RandomFloat( 0, 0 ) ) )
homingRocketOffsets.append( Vector( OFFSET_AMPLITUDE * RandomFloat( 0.5, 1 ), OFFSET_AMPLITUDE * RandomFloat( 0.5, 1 ) ) )
homingRocketOffsets.append( Vector( OFFSET_AMPLITUDE * RandomFloat( -1, -0.5 ), OFFSET_AMPLITUDE * RandomFloat( -1, -0.5 ) ) )
homingRocketOffsets.append( Vector( OFFSET_AMPLITUDE * RandomFloat( 0.5, 1 ), OFFSET_AMPLITUDE * RandomFloat( 0.5, 1 ) ) )
homingRocketOffsets.append( Vector( OFFSET_AMPLITUDE * RandomFloat( -1, -0.5 ), OFFSET_AMPLITUDE * RandomFloat( 0.5, 1 ) ) )
homingRocketOffsets.append( Vector( OFFSET_AMPLITUDE * RandomFloat( 0.5, 1 ), OFFSET_AMPLITUDE * RandomFloat( -1, -0.5 ) ) )
homingRocketOffsets.append( Vector( OFFSET_AMPLITUDE * RandomFloat( -1, -0.5 ), OFFSET_AMPLITUDE * RandomFloat( -1, 1 ) ) )
homingRocketOffsets.append( Vector( OFFSET_AMPLITUDE * RandomFloat( 0.5, 1 ), OFFSET_AMPLITUDE * RandomFloat( -1, -0.5 ) ) )
homingRocketOffsets.append( Vector( OFFSET_AMPLITUDE * RandomFloat( 0.25, 0.5 ), OFFSET_AMPLITUDE * RandomFloat( 0.25, 0.5 ) ) )
homingRocketOffsets.append( Vector( OFFSET_AMPLITUDE * RandomFloat( -0.5, -0.25 ), OFFSET_AMPLITUDE * RandomFloat( 0.25, 0.5 ) ) )
homingRocketOffsets.append( Vector( OFFSET_AMPLITUDE * RandomFloat( 0.25, 0.5 ), OFFSET_AMPLITUDE * RandomFloat( -0.5, 0.25 ) ) )
homingRocketOffsets.append( Vector( OFFSET_AMPLITUDE * RandomFloat( -0.5, -0.25 ), OFFSET_AMPLITUDE * RandomFloat( -0.5, 0.25 ) ) )

const SIGNAL_LOCK_LOOP_SOUND_STOP = "signal_lock_loop_sound_stop"
RegisterSignal( SIGNAL_LOCK_LOOP_SOUND_STOP )

PrecacheHUDMaterial( "hud/sram/sram_targeting_inner_ring_static" )
PrecacheHUDMaterial( "hud/sram/sram_targeting_outer_ring_static" )
PrecacheHUDMaterial( "hud/weapons/target_ring_titan_locked" )
PrecacheHUDMaterial( "hud/weapons/target_ring_front_pilot" )
PrecacheHUDMaterial( "hud/weapons/target_ring_mid_pilot" )
PrecacheHUDMaterial( "hud/weapons/target_ring_back_pilot" )
PrecacheHUDMaterial( "hud/lock_indicator_down_danger" )
PrecacheHUDMaterial( "hud/lock_indicator_up_danger" )
PrecacheHUDMaterial( "hud/lock_indicator_text_box_danger" )
PrecacheHUDMaterial( "hud/lock_indicator_left_danger" )
PrecacheHUDMaterial( "hud/lock_indicator_right_danger" )
PrecacheHUDMaterial( "hud/homing_missile_lock_ring" )


/******************************************/
/*				CLIENT FUNCTIONS		  */
/******************************************/

function main()
{
	Globalize( SmartAmmo_ClientStop )
	Globalize( ClientCodeCallback_SmartAmmo_UpdateHUD )
	Globalize( ClientCodeCallback_SmartAmmoSoundEffectsLockStatus )
	Globalize( SmartAmmo_LockedOntoWarningHUD_Init )
	Globalize( SmartAmmo_LockedOntoWarningHUD_Update )

	Globalize( SmartAmmo_SetSound_Locking )

	// Export these to the root table so code can call it. Needed for transition of this script to code.
	Globalize( ClientCodeCallback_SmartAmmo_LockIconUpdate_TitanMissile )
	Globalize( ClientCodeBallback_SmartAmmo_LockIconUpdate_TitanTargetMissile )

	AddKillReplayEndedCallback( KillReplay_SmartAmmo_ClientStop )
}

function SmartAmmo_SetSound_Locking( weapon, soundalias )
{
	if ( !( "smartAmmoSoundLocking" in weapon.s ) )
		weapon.s.smartAmmoSoundLocking <- null

	weapon.s.smartAmmoSoundLocking = soundalias
}

function SmartAmmo_GetSound_Locking( weapon )
{
	if ( !( "smartAmmoSoundLocking" in weapon.s ) )
	{
		local alias
		local lockStyle = SmartAmmo_GetHudLockonStyle( weapon )

		if ( lockStyle == "titan_missile" )
			alias = SMART_AMMO_AUTOLOCK_SOUND_TARGET_ACQUIRE
		else if ( lockStyle == "titan_target_missile" )
			alias = SMART_AMMO_HOMING_SOUND_TARGET_ACQUIRE
		else
			alias = SMART_AMMO_DEFAULT_SOUND_TARGET_ACQUIRE

		return alias

	}

	return weapon.s.smartAmmoSoundLocking
}

function SmartAmmo_GetSound_LockedLoop( weapon )
{
	return weapon.GetWeaponModSetting( "smart_ammo_looping_sound_locked" )
}

function SmartAmmo_ClientStop( weapon )
{
	Assert( IsClient() )

	_cl_SmartAmmo_SoundEffect_Locking_Loopsound_Stop( GetLocalViewPlayer() )
	_cl_SmartAmmo_SoundEffect_Locked_Loopsound_Stop( GetLocalViewPlayer() )
	_cl_HideAllOverlays( weapon )

	if ( !IsValid( weapon ) )
		return

	if ( "smartAmmoLastEntity" in weapon.s )
	{
		delete weapon.s.smartAmmoLastEntity
	}

	if ( "smartAmmoLastLockIdx" in weapon.s )
	{
		delete weapon.s.smartAmmoLastLockIdx
	}
}

function _cl_HideAllOverlays( weapon )
{
	// Hide the HUD overlays
	//local groupIndex = SmartAmmo_Client_GetHudElemGroupIndex( weapon )

	for ( local groupIndex = 0; groupIndex < 2; groupIndex++ )
	{
		if ( SmartAmmo_Client_GetStatusText( groupIndex ) != null )
			SmartAmmo_Client_GetStatusText( groupIndex ).Hide()

		if ( SmartAmmo_Client_GetStatusTextIcon( groupIndex ) != null )
			SmartAmmo_Client_GetStatusTextIcon( groupIndex ).Hide()

		SmartAmmo_Client_HideAllTargetRings( groupIndex, 0 )
	}

	if ( IsValid( autoLockCornersGroup ) )
	{
		autoLockCornersGroup.Hide()
	}

	if ( IsValid( activeHomingRocketsGroup )  )
	{
		activeHomingRocketsGroup.Hide()
	}
}

function _cl_SmartAmmo_Init( weapon )
{
	SmartAmmo_Client_InitHud( weapon )

	local groupIndex = SmartAmmo_Client_GetHudElemGroupIndex( weapon )

	if ( autoLockCornersGroup == null  )
	{
		autoLockCornersGroup <- HudElementGroup( "AutoLockCorners" )
		for ( local i = 0; i < 4; i++ )
		{
			autoLockCorners.append( HudElement( "AutoLockCorner_" + i ) )
			autoLockCorners[i].SetRotation( i * 90 )
			autoLockCornersGroup.AddElement( autoLockCorners[i] )
		}
		autoLockCornersGroup.Hide()
	}

	if ( activeHomingRocketsGroup == null )
	{
		activeHomingRocketsGroup <- HudElementGroup( "ActiveHomingRocket" )
		for ( local i = 0; i < HOMING_ROCKET_MAX_MISSILE_COUNT_BURN; i++ )
		{
			activeHomingRockets.append( HudElement( "ActiveHomingRocketIcon_" + i ) )
			activeHomingRocketsGroup.AddElement( activeHomingRockets[i] )
		}
		//activeHomingRocketsTicker.append( HudElement("ActiveHomingRocketTicker" ) )
		//activeHomingRocketsTicker.append( HudElement("ActiveHomingRocketTicker2" ) )
		//activeHomingRocketsGroup.AddElement( activeHomingRocketsTicker[0] )
		//activeHomingRocketsGroup.AddElement( activeHomingRocketsTicker[1] )
		activeHomingRocketsText = HudElement( "ActiveHomingRocketLockStatus" )
		activeHomingRocketsGroup.AddElement( activeHomingRocketsText )
		activeHomingRocketsText.SetText("#SHOULDER_ROCKET_STATUS_1" )

		activeHomingRocketsGroup.Hide()
	}
}

function ClientCodeCallback_SmartAmmo_UpdateHUD( weapon )
{
	if ( !IsValid( weapon ) )
	{
		SmartAmmo_ClientStop( weapon )
		return
	}

	local player = weapon.GetWeaponOwner()
	if ( IsValid( player ) && player.IsInThirdPersonReplay() )
	{
		SmartAmmo_ClientStop( weapon )
		return
	}

	// Create HUD overlays if they aren't created yet
	_cl_SmartAmmo_Init( weapon )

	// Max targets we should care about. Weapon can set max targets to a specific number even though the smart ammo code can track up to 8
	local maxTargets = weapon.GetWeaponModSetting( "smart_ammo_max_targets" )

	// lockStatus will track the lock status of all targets so that later we can get the highest/lowest lock status of all targets
	local lockStatus = {}
	for( local i = 0 ; i < maxTargets ; i++ )
		lockStatus[i] <- 0

	local color

	if ( !IsAlive( player ) )
		return

	if ( !weapon.SmartAmmo_IsEnabled() )
	{
		SmartAmmo_ClientStop( weapon )
		return
	}

	local smartAmmoTargets = weapon.SmartAmmo_GetTargets()
	local numTargets = min( smartAmmoTargets.len(), maxTargets )

	local groupIndex = SmartAmmo_Client_GetHudElemGroupIndex( weapon )	// What HUD group we should be using. Will be 0 for handheld and 1 for offhand so elems dont conflict when we have one of each active at the same time

	local highestLockFraction = 0
	local numLockedTargets = 0
	for( local i = 0 ; i < numTargets ; i++ )
	{
		if ( smartAmmoTargets[i].fraction > highestLockFraction )
			highestLockFraction = smartAmmoTargets[i].fraction

		numLockedTargets += floor( smartAmmoTargets[i].fraction )
	}

	/****************************************/
	/*	UPDATE OVERLAY HUD FOR EACH TARGET	*/
	/****************************************/

	local fullLocks = 0
	local targetIndex = 0
	local totalFraction = 0
	for ( ; targetIndex < numTargets; ++targetIndex )
	{
		local target = smartAmmoTargets[ targetIndex ]
		Assert( IsValid( target.entity ) )	// SmartAmmo_GetTargets() isn't supposed to return invalid targets, but may return not alive targets which is good

		local groupIndex = SmartAmmo_Client_GetHudElemGroupIndex( weapon )
		// Hide all elements by default. We will show whatever should be visible each frame
		SmartAmmo_Client_GetTargetRings( groupIndex, targetIndex ).Hide()

		local isMultiLockTarget = SmartAmmo_GetTargetMaxLocks( weapon, target.entity ) > 1.0
		totalFraction += target.fraction

		if ( isMultiLockTarget )
		{
			local startFrac = target.fraction

			lockStatus[ targetIndex ] = _cl_SmartAmmo_UpdateTargetOverlay( weapon, target, targetIndex, totalFraction )

			for ( local index = 1; index < ceil( target.fraction ); index++ )
			{
				_cl_SmartAmmo_UpdateTargetOverlay( weapon, target, targetIndex, totalFraction, index )
			}

			if ( target.fraction == SmartAmmo_GetTargetMaxLocks( weapon, target.entity ) )
				fullLocks++
		}
		else
		{
			lockStatus[ targetIndex ] = _cl_SmartAmmo_UpdateTargetOverlay( weapon, target, targetIndex, totalFraction )

			if ( lockStatus[ targetIndex ] >= 1.0 )
				fullLocks++
		}
	}

	if ( numTargets == 0 )
	{
		local lockStyle = SmartAmmo_GetHudLockonStyle( weapon )
		if( lockStyle == "titan_missile" )
		{
			_cl_SmartAmmo_LockIconUpdate_NoTarget_TitanMissile( weapon )
		}

		if( lockStyle == "titan_target_missile" )
		{
			_cl_SmartAmmo_LockIconUpdate_NoTarget_TitanTargetMissile( weapon )
		}
	}

	/************************************/
	/*	CLEAR UNUSED OVERLAY HUD ELEMS	*/
	/************************************/

	SmartAmmo_Client_HideAllTargetRings( groupIndex, targetIndex )

	for ( ; targetIndex < maxTargets ; ++targetIndex )
	{
		if ( targetIndex in lockStatus )
			lockStatus[targetIndex] = 0.0
	}

	/****************************************/
	/*	UPDATE THE SMART AMMO STATUS TEXT	*/
	/****************************************/

	local pulseFrac = 1.0
	local statusText
	local timeSinceFireFail = SmartAmmo_GetWeaponFireFailedTime( weapon )
	local lockOnStyle = SmartAmmo_GetHudLockonStyle( weapon )
	if ( weapon.GetClassname() == "mp_weapon_smart_pistol" && 0 )
	{
		SmartAmmo_Client_GetStatusText( groupIndex ).Hide()
	}
	else if ( lockOnStyle != "pilot_launcher" )
	{
		if ( lockOnStyle == "titan_launcher" )
		{
			if ( fullLocks )
			{
				color = COLOR_LOCKED
				statusText = SMART_AMMO_STATUS_TEXT_LOCKED
				if ( player.GetWeaponAmmoLoaded( weapon ) < numLockedTargets )
					statusText = SMART_AMMO_STATUS_TEXT_LOCKED_LIMITED
			}
			else if ( highestLockFraction > 0.0 )
			{
				color = COLOR_LOCKING
				statusText = SMART_AMMO_STATUS_TEXT_LOCKING
				pulseFrac = Graph( GetPulseFrac( 3.0 ), 0.0, 1.0, 0.2, 1.0 )
			}
			else
			{
				color = COLOR_NO_TARGET
				if ( timeSinceFireFail >= 0 && timeSinceFireFail <= 2.0 )
					statusText = SMART_AMMO_STATUS_TEXT_NO_LOCK
				else
					statusText = SMART_AMMO_STATUS_TEXT_NO_TARGET
			}

			local smartPistolStatusText = SmartAmmo_Client_GetStatusText( groupIndex )
			smartPistolStatusText.SetText( statusText )
			smartPistolStatusText.SetColor( color.r, color.g, color.b, color.a * pulseFrac )
			smartPistolStatusText.Show()
		}
		else
		{
			SmartAmmo_Client_GetStatusText( groupIndex ).Hide()
		}
	}

	local weaponType = weapon.GetSmartAmmoWeaponType()
	if ( weaponType == "homing_missile" && ( highestLockFraction == 1.0 ) && SmartAmmo_GetHudLockonStyle( weapon ) != "pilot_launcher" && SmartAmmo_GetDisplayKeybinding( weapon ) )
	{
		local statusTextIcon = SmartAmmo_Client_GetStatusTextIcon( groupIndex )

		if ( weapon.IsWeaponOffhand() )
		{
			statusTextIcon.SetText( "#OFFHAND1_KEY_BINDING" )
		}
		else
		{
			statusTextIcon.SetText( "#ATTACK_KEY_BINDING" )
		}

		if ( weapon.IsReloading() )
		{
			statusTextIcon.Hide()
		}
		else
		{
			statusTextIcon.Show()
		}

		statusTextIcon.SetColor( 255, 255, 255, 255 * pulseFrac )
	}
	else
	{
		SmartAmmo_Client_GetStatusText( groupIndex ).Hide()
	}

	/************************/
	/*	LOCK SOUND EFFECTS	*/
	/************************/

	SmartAmmo_Client_PlayTargetConfirmedSounds( weapon )

	local highestFrac = 0.0
	local highestPrevFrac = 0.0

	for ( targetIndex = 0 ; targetIndex < numTargets; ++targetIndex )
	{
		local target = smartAmmoTargets[ targetIndex ]
		if ( target.fraction >= highestFrac )
			highestFrac = target.fraction
		if ( target.prevFraction >= highestPrevFrac )
			highestPrevFrac = target.prevFraction
	}

	thread _cl_SmartAmmo_SoundEffects_LockStatus( player, weapon, highestFrac, highestPrevFrac, smartAmmoTargets, numTargets )
}

function _cl_SmartAmmo_UpdateTargetOverlay( weapon, target, targetIndex, totalFraction = 0, altLockIndex = 0 )
{
	return SmartAmmo_Client_UpdateTargetOverlay( weapon, target.entity, target.fraction, targetIndex, totalFraction, altLockIndex, target )
}

function _cl_SmartAmmo_LockIconUpdate_Prediction( targetData )
{
	//// !!!!!!!!!!!!!!!!!!!!!!
	//// !!!!!!!!!!!!!!!!!!!!!!
	//// !!!!!!!!!!!!!!!!!!!!!!
	////
	//// SmartAmmo_Client_GetTriangle doesn't exist anymore, update this function or remove it
	////
	//// !!!!!!!!!!!!!!!!!!!!!!
	//// !!!!!!!!!!!!!!!!!!!!!!
	//// !!!!!!!!!!!!!!!!!!!!!!

	local scale = 1.0 + ( 5.0 * targetData.inverseFraction )
	local alphaMultiplier = targetData.fraction

	local baseSize = 50 * SmartAmmo_Client_GetContentScaleFactor()[0]

	local smartPistolTriangle = SmartAmmo_Client_GetTriangle( targetData.groupIndex, targetData.targetIndex )
	smartPistolTriangle.SetBaseSize( baseSize, baseSize )
	smartPistolTriangle.SetColor( targetData.color.r, targetData.color.g, targetData.color.b, 220 )

	// offset the position to triangulate into center
	local elems = SmartAmmo_Client_GetTargetRings( groupIndex, targetIndex ).GetElementsArray()

	local offsetX
	local offsetY
	local usedElems = 0

	for ( local elemIndex = SmartAmmo_AcquireVecDirections.len() * targetData.altLockIndex; elemIndex < elems.len(); elemIndex++ )
	{
		local elem = elems[elemIndex]
		if ( usedElems >= SmartAmmo_AcquireVecDirections.len() )
			break

		// Update locking elems
		elem.SetBaseSize( baseSize, baseSize )
		elem.SetColor( targetData.color.r, targetData.color.g, targetData.color.b, targetData.color.a * alphaMultiplier )
		elem.SetScale( scale, scale )

		local width = elem.GetWidth()
		local screenCoordX = targetData.screenCoord.x - (width / 2.0)
		local screenCoordY = targetData.screenCoord.y - (width / 2.0)

		if ( usedElems == 0 )
			elem.SetImage( "HUD/weapons/target_ring_front" )
		else if ( usedElems == 1 )
			elem.SetImage( "HUD/weapons/target_ring_mid" )
		else if ( usedElems == 2 )
			elem.SetImage( "HUD/weapons/target_ring_back" )

		offsetX = SmartAmmo_AcquireVecDirections[usedElems].x * targetData.inverseFraction * 100.0
		offsetY = SmartAmmo_AcquireVecDirections[usedElems].y * targetData.inverseFraction * 100.0

		elem.SetPos( screenCoordX + offsetX, screenCoordY + offsetY )
		elem.Show()

		usedElems++
	}


	//Creating Triangles along the side. Need to rotate, reposition, and scale according the base HUD.
	local sizeModifier
	local playerADSFrac = targetData.player.GetAdsFraction()
	// sync up to SetCrosshairScale in cl_crosshair.nut
	if ( targetData.weapon.IsWeaponAdsButtonPressed() )
		sizeModifier = GraphCapped( playerADSFrac, 0, 0.5 , 1.0 , 1.5 )
	else
		sizeModifier = GraphCapped( playerADSFrac, 0.25, 1.0 , 1.0 , 1.5 )

	//HACK - Ideally we could scale the crosshair with a general setting.
	if ( targetData.weapon.HasModDefined("enhanced_targeting") && targetData.weapon.HasMod( "enhanced_targeting" ) )
		sizeModifier *= 0.8

	local screenSize = Hud.GetScreenSize()
	local newXPos
	local newYPos = clamp( targetData.screenCoord.y, ( screenSize[1] / 2 - (screenSize[1] * 0.135 ) * sizeModifier), ( screenSize[1] / 2 + ( screenSize[1] * 0.115 ) * sizeModifier ) )
	if( targetData.screenCoord.x > screenSize[0] / 2 )
	{
		newXPos = screenSize[0] / 2 + ( screenSize[0] * 0.135 ) * sizeModifier
	}
	else
	{
		newXPos = screenSize[0] / 2 - ( screenSize[0] * 0.15 ) * sizeModifier
	}

	local smartPistolTriangle = SmartAmmo_Client_GetTriangle( targetData.groupIndex, targetData.targetIndex )
	smartPistolTriangle.SetScale( 0.25 * sizeModifier, 0.25 * sizeModifier )
	smartPistolTriangle.SetPos( newXPos, newYPos )
	smartPistolTriangle.Show()
}

function ClientCodeBallback_SmartAmmo_LockIconUpdate_TitanTargetMissile( targetData, totalFraction = 0 )
{
	if ( !IsValid( activeHomingRocketsGroup ) )
		return
	activeHomingRocketsGroup.Show()
	local maxShots = SmartAmmo_GetMaxTargetedBurst( targetData.weapon )
	if( totalFraction >= maxShots )
	{
		if( Time() % 0.5 < 0.25 )
			activeHomingRocketsGroup.SetColor( 205, 72, 59, 225 )
		else
			activeHomingRocketsGroup.SetColor( 238, 146, 0, 225 )

		activeHomingRocketsText.SetText( "#SHOULDER_ROCKET_STATUS_3", "", "" )
		for( local i = maxShots; i < activeHomingRockets.len(); i++ )
		{
			activeHomingRockets[i].Hide()
		}
	}
	else
	{
		activeHomingRocketsGroup.SetColor( 238, 146, 0, 225 )
		local inverseChargeFrac = 1 - targetData.weapon.GetWeaponChargeFraction()
		local shotFrac = 1 / maxShots.tofloat()
		local availableShots = floor( inverseChargeFrac / shotFrac )
		local roundedTotalFrac = floor( totalFraction )
		activeHomingRocketsText.SetText( "#SHOULDER_ROCKET_STATUS_2", "", roundedTotalFrac.tostring(), "" )
		for( local i = 0; i < activeHomingRockets.len(); i++ )
		{
			if ( i >= availableShots )
				activeHomingRockets[i].Hide()
			else if( i > totalFraction )
				activeHomingRockets[i].SetColor( 177, 213, 227, 140 )
		}
	}


	local scale = 1.0
	local baseSize = 15 * SmartAmmo_Client_GetContentScaleFactor()[0]

	if ( targetData.fraction < 1.0 )
		return

	// Update locking elems
	local smartPistolTargetRings = SmartAmmo_Client_GetTargetRings( targetData.groupIndex, targetData.targetIndex )
	smartPistolTargetRings.SetBaseSize( baseSize, baseSize )
	smartPistolTargetRings.SetScale( scale, scale )

	// position the elems
	local elemIndex = 0
	local width
	local boundingBoxCoords = GetLocalViewPlayer().GetEntScreenSpaceBounds( targetData.entity, 100 )
	local elems = smartPistolTargetRings.GetElementsArray()

	local usedElems = 0

	local elem = elems[targetData.altLockIndex]

	elem.SetImage( "HUD/homing_missile_lock_ring" )
	elem.SetPos( targetData.screenCoord.x - (elem.GetWidth() * 0.5), targetData.screenCoord.y - (elem.GetHeight() * 0.5) )
	elem.SetColor( 255, 128, 64, 220 )
	elem.Show()
}

function _cl_SmartAmmo_LockIconUpdate_NoTarget_TitanTargetMissile( weapon )
{
		activeHomingRocketsGroup.Show()
		local inverseChargeFrac = 1 - weapon.GetWeaponChargeFraction()
		local shotFrac = 1 / SmartAmmo_GetMaxTargetedBurst( weapon ).tofloat()
		local availableShots = inverseChargeFrac / shotFrac
		for ( local i = floor( availableShots ); i < activeHomingRockets.len(); i++ )
		{
			activeHomingRockets[i].Hide()
		}
		activeHomingRocketsText.SetText("#SHOULDER_ROCKET_STATUS_1" )
		activeHomingRocketsGroup.SetColor( 177, 213, 227, 140 )
}

function _cl_SmartAmmo_LockIconUpdate_NoTarget_TitanMissile( weapon )
{
		if ( !weapon.IsReadyToFire() )
		{
			local onCooldownColor = StringToColors( AUTO_LOCK_ON_COOLDOWN_COLOR )
			autoLockCornersGroup.SetColor( onCooldownColor.r, onCooldownColor.g, onCooldownColor.b, onCooldownColor.a )
		}
		else
		{
			local readyToFireColor
			if ( weapon.HasModDefined( "burn_mod_titan_homing_rockets" ) && weapon.HasMod( "burn_mod_titan_homing_rockets" ) )
				readyToFireColor = StringToColors( BURN_CARD_WEAPON_HUD_COLOR_STRING )
			else
				readyToFireColor = StringToColors( AUTO_LOCK_READY_TO_FIRE_COLOR )

			autoLockCornersGroup.SetColor( readyToFireColor.r, readyToFireColor.g, readyToFireColor.b, readyToFireColor.a )
		}
		autoLockCornersGroup.ReturnToBasePos()
		//Resetting rotation, because using SetPos from the bounding box later on rotates the elements.
		for ( local i = 0; i < 4; i++ )
		{
			autoLockCorners[i].SetRotation( i * 90 )
		}
		autoLockCornersGroup.SetScale( 1.0, 1.0 )
		autoLockCornersGroup.SetImage( "HUD/weapons/target_ring_titan_locking" )
		autoLockCornersGroup.Show()
}

function ClientCodeCallback_SmartAmmo_LockIconUpdate_TitanMissile( targetData )
{
	local scale = 1.0
	local baseSize = 15 * SmartAmmo_Client_GetContentScaleFactor()[0]

	// Update locking elems
	local smartPistolTargetRings = SmartAmmo_Client_GetTargetRings( targetData.groupIndex, targetData.targetIndex )
	smartPistolTargetRings.SetBaseSize( baseSize, baseSize )
	smartPistolTargetRings.SetScale( scale, scale )
	autoLockCornersGroup.Hide()

	if ( IsValid( targetData.weapon ) )
	{
		if ( targetData.weapon.HasModDefined( "burn_mod_titan_homing_rockets" ) && targetData.weapon.HasMod( "burn_mod_titan_homing_rockets" ) )
		{
			targetData.color.r = BURN_CARD_WEAPON_HUD_COLOR[0]
			targetData.color.g = BURN_CARD_WEAPON_HUD_COLOR[1]
			targetData.color.b = BURN_CARD_WEAPON_HUD_COLOR[2]
			targetData.color.a = BURN_CARD_WEAPON_HUD_COLOR[3]
		}
	}

	//Two similar looking looking functions, but the guts are different.
	_cl_SmartAmmo_LockIconUpdate_TitanMissile_MoveIconsFromBoundingBox( SmartAmmo_Client_GetTargetRings( targetData.groupIndex, targetData.targetIndex ).GetElements(), missileLockElemInfo, targetData )
	_cl_SmartAmmo_LockIconUpdate_TitanMissile_MoveIconsFromCenter( autoLockCornersGroup.GetElements(), autoLockNoTargetElemInfo, targetData )
}

function _cl_SmartAmmo_LockIconUpdate_TitanMissile_MoveIconsFromBoundingBox( elems, infoTable, targetData )
{
	local elemIndex = 0
	local scale = 1.0
	local lockingTravelDistance = 30 * SmartAmmo_Client_GetContentScaleFactor()[0]
	local boundingBoxCoords = GetLocalViewPlayer().GetEntScreenSpaceBounds( targetData.entity, 100 )
	local duration = SmartAmmo_GetTargetingTime( targetData.weapon, targetData.entity )

	foreach( elem in elems )
	{
		if ( elemIndex >= infoTable.len() )
			break

		Assert( elemIndex in infoTable )

		local elemPosition = [
					boundingBoxCoords[infoTable[elemIndex].pos[0]],
					boundingBoxCoords[infoTable[elemIndex].pos[1]]
				]

		local adjustedAcquireFrac = GraphCapped( targetData.target.fraction, infoTable[elemIndex].fracStart, infoTable[elemIndex].fracEnd, 0.0, 1.0 )
		local adjustedInverseAcquireFrac = clamp( 1.0 - adjustedAcquireFrac, 1.0, 0.0 )

		if ( adjustedAcquireFrac == 0 )
		{
			elemIndex++
			continue
		}

		// simple linear tweening - no easing, no acceleration
		local elapsedTime = duration * adjustedAcquireFrac
		local tweenFrac = Tween_ExpoEaseIn( elapsedTime, 0.0, 1.0, duration )	// current time, start value, change in value, duration
		local inverseTweenFrac = clamp( 1.0 - tweenFrac, 1.0, 0.0 )

		// Calculate scale for the elem
		local elemScale = GraphCapped( tweenFrac, 0.0, 1.0, scale * infoTable[elemIndex].startScale, infoTable[elemIndex].endScale )

		elemPosition[0] += lockingTravelDistance * infoTable[elemIndex].moveX * inverseTweenFrac
		elemPosition[1] += lockingTravelDistance * infoTable[elemIndex].moveY * inverseTweenFrac

		// only show this elem if we have a lock
		if ( targetData.target.fraction < 1.0 )
		{
			// locking
			local pulseFrac = clamp( GetPulseFrac( 3.5 ), 0.1, 1.0 )
			elem.SetImage( "HUD/weapons/target_ring_titan_locking" )
			elem.SetColor( targetData.color.r, targetData.color.g, targetData.color.b, targetData.color.a * pulseFrac )
			elem.Show()
		}
		else
		{
			// locked
			elem.SetImage( "HUD/weapons/target_ring_titan_locked" )
			elem.SetColor( 255, 255, 255, 255 )
			elem.Show()
		}

		elemPosition[0] -= elem.GetWidth() * 0.5
		elemPosition[1] -= elem.GetHeight() * 0.5
		elem.SetPos( elemPosition[0], elemPosition[1] )
		elem.SetScale( elemScale, elemScale )
		elem.SetRotation( infoTable[elemIndex].rotation )

		elemIndex++
	}
}

function _cl_SmartAmmo_LockIconUpdate_TitanMissile_MoveIconsFromCenter( elems, infoTable, targetData )
{
	local elemIndex = 0
	local scale = 1.0
	local boundingBoxCoords = GetLocalViewPlayer().GetEntScreenSpaceBounds( targetData.entity, 100 )
	local duration = SmartAmmo_GetTargetingTime( targetData.weapon, targetData.entity )

	foreach( elem in elems )
	{
		Assert( elemIndex in infoTable )

		local elemPosition = [
					boundingBoxCoords[infoTable[elemIndex].pos[0]],
					boundingBoxCoords[infoTable[elemIndex].pos[1]]
				]

		local adjustedAcquireFrac = GraphCapped( targetData.target.fraction, infoTable[elemIndex].fracStart, infoTable[elemIndex].fracEnd, 0.0, 1.0 )
		local adjustedInverseAcquireFrac = clamp( 1.0 - adjustedAcquireFrac, 1.0, 0.0 )

		if ( adjustedAcquireFrac == 0 )
		{
			elemIndex++
			continue
		}

		// simple linear tweening - no easing, no acceleration
		local elapsedTime = duration * adjustedAcquireFrac
		local tweenFrac = Tween_ExpoEaseIn( elapsedTime, 0.0, 1.0, duration )	// current time, start value, change in value, duration
		local inverseTweenFrac = clamp( 1.0 - tweenFrac, 1.0, 0.0 )
		local basePos = autoLockCorners[ elemIndex ].GetBasePos()
		local lockingDistanceX =  basePos[0] - elemPosition[0]
		local lockingDistanceY =  basePos[1] - elemPosition[1]

		// Calculate scale for the elem
		local elemScale = GraphCapped( tweenFrac, 0.0, 1.0, scale * infoTable[elemIndex].startScale, infoTable[elemIndex].endScale )

		elemPosition[0] += lockingDistanceX * inverseTweenFrac
		elemPosition[1] += lockingDistanceY * inverseTweenFrac

		// only show this elem if we have a lock
		if ( targetData.target.fraction < infoTable[elemIndex].fracEnd * 2)
		{
			// locking
			local pulseFrac = clamp( GetPulseFrac( 3.5 ), 0.1, 1.0 )
			elem.SetColor( targetData.color.r, targetData.color.g, targetData.color.b, targetData.color.a * pulseFrac )
			elem.Show()
		}
		else
		{
			elem.Hide()
		}

		elem.SetPos( elemPosition[0], elemPosition[1] )
		elem.SetScale( elemScale, elemScale )
		elem.SetRotation( infoTable[elemIndex].rotation )

		elemIndex++
	}
}

function ClientCodeCallback_SmartAmmoSoundEffectsLockStatus( weapon )
{
	local player = weapon.GetWeaponOwner()

	local smartAmmoTargets = weapon.SmartAmmo_GetTargets()
	local maxTargets = weapon.GetWeaponModSetting( "smart_ammo_max_targets" )
	local numTargets = min( smartAmmoTargets.len(), maxTargets )

	local highestFrac = 0.0
	local highestPrevFrac = 0.0

	for ( local targetIndex = 0 ; targetIndex < numTargets; ++targetIndex )
	{
		local target = smartAmmoTargets[ targetIndex ]
		if ( target.fraction >= highestFrac )
			highestFrac = target.fraction
		if ( target.prevFraction >= highestPrevFrac )
			highestPrevFrac = target.prevFraction
	}

	thread _cl_SmartAmmo_SoundEffects_LockStatus( player, weapon, highestFrac, highestPrevFrac, smartAmmoTargets, numTargets )
}

function _cl_SmartAmmo_SoundEffects_LockStatus( player, weapon, highestFrac, highestPrevFrac, smartAmmoTargets, numTargets )
{
	Assert( IsClient() )
	Assert( IsValid( player ) && IsAlive( player ) )

	local doLockingSound = null
	local doLockedSound = null

	// set based on highest frac
	if ( highestFrac >= 1.0 )
		doLockedSound = true
	else if ( highestFrac >= TARGET_SET_FRACTION )
		doLockingSound = true

	// now check if we have to add locking sounds for lower frac targets
	if ( doLockingSound == null )
	{
		// Get the target with the second highest lock frac
		for ( local targetIndex = 0 ; targetIndex < numTargets; ++targetIndex )
		{
			local target = smartAmmoTargets[ targetIndex ]
			local frac = target.fraction

			local maxFrac = SmartAmmo_GetTargetMaxLocks( weapon, target.entity )

			if ( frac < maxFrac )
			{
				doLockingSound = true
				break
			}

			if ( frac == highestFrac )
				continue  // skip the guy whose fraction we already know about

			if ( frac > TARGET_SET_FRACTION )
			{
				doLockingSound = true
				break
			}
		}
	}

	// stop or play the locking sound
	if ( doLockingSound )
	{
		local soundAliasLocking = SmartAmmo_GetSound_Locking( weapon )

		local hudLockonStyle = SmartAmmo_GetHudLockonStyle( weapon )
		if ( hudLockonStyle == "pilot_launcher" )
		{
			// beeping gets faster over time in this version so it's authored as a oneshot
			if ( !( "nextLockonBeepTime" in weapon.s ) )
				weapon.s.nextLockonBeepTime <- null

			// if prev frac was 1, don't do this beep (debounce)
			if ( highestPrevFrac != 1.0 && weapon.s.nextLockonBeepTime == null || Time() >= weapon.s.nextLockonBeepTime )
			{
					EmitSoundOnEntity( player, soundAliasLocking )
				weapon.s.nextLockonBeepTime = Time() + GraphCapped( highestFrac, 0.2, 0.8, 0.175, 0.08 )
			}
		}
		else if ( highestFrac > TARGET_SET_FRACTION )
		{
			// tone loops on its own in this version
			_cl_SmartAmmo_SoundEffect_Locking_Loopsound_Start( weapon, player, soundAliasLocking )
		}
	}
	else
	{
		_cl_SmartAmmo_SoundEffect_Locking_Loopsound_Stop( player )
	}

	// stop or play the locked sound
	if ( doLockedSound && IsValid( weapon ) )
	{
		local loopingLockSound = SmartAmmo_GetSound_LockedLoop( weapon )

		// not every weapon has a looping locked sound
		if ( loopingLockSound != "" )
		{
			_cl_SmartAmmo_SoundEffect_Locked_Loopsound_Start( weapon, player, loopingLockSound )
		}

	}
	else
	{
		_cl_SmartAmmo_SoundEffect_Locked_Loopsound_Stop( player )
	}
}

function _cl_SmartAmmo_SoundEffect_Locked_Loopsound_Start( weapon, player, sound )
{
	if ( "smartAmmo_target_locked_loop_sound_playing" in player.s )
		return

	EndSignal( player, SIGNAL_LOCK_LOOP_SOUND_STOP )

	EmitSoundOnEntity( player, sound )
	player.s.smartAmmo_target_locked_loop_sound_playing <- sound

	WaitSignal( player, "OnDeath", "TitanExit" )

	_cl_SmartAmmo_SoundEffect_Locked_Loopsound_Stop( player )
}

function _cl_SmartAmmo_SoundEffect_Locked_Loopsound_Stop( player )
{
	if ( !( "smartAmmo_target_locked_loop_sound_playing" in player.s ) )
		return

	if ( !IsValid_ThisFrame( player ) )
		return

	Signal( player, SIGNAL_LOCK_LOOP_SOUND_STOP )
		StopSoundOnEntity( player, player.s.smartAmmo_target_locked_loop_sound_playing )
	delete player.s.smartAmmo_target_locked_loop_sound_playing
}

function _cl_SmartAmmo_SoundEffect_Locking_Loopsound_Start( weapon, player, sound )
{
	if ( "smartAmmo_target_locking_loop_sound_playing" in player.s )
		return

	EndSignal( player, SIGNAL_LOCK_LOOP_SOUND_STOP )

	EmitSoundOnEntity( player, sound )
	player.s.smartAmmo_target_locking_loop_sound_playing <- sound

	WaitSignal( player, "OnDeath", "TitanExit" )

	_cl_SmartAmmo_SoundEffect_Locking_Loopsound_Stop( player )
}

function _cl_SmartAmmo_SoundEffect_Locking_Loopsound_Stop( player )
{
	if ( !( "smartAmmo_target_locking_loop_sound_playing" in player.s ) )
		return

	if ( !IsValid_ThisFrame( player ) )
		return

	Signal( player, SIGNAL_LOCK_LOOP_SOUND_STOP )
	StopSoundOnEntity( player, player.s.smartAmmo_target_locking_loop_sound_playing )
	delete player.s.smartAmmo_target_locking_loop_sound_playing
}

function SmartAmmo_LockedOntoWarningHUD_Init()
{
	// return
	local player = GetLocalViewPlayer()

	player.InitHudElem( "LockonDetector_CenterBox" )
	player.InitHudElem( "LockonDetector_CenterBox_Label" )
	player.InitHudElem( "LockonDetector_ArrowForward" )
	player.InitHudElem( "LockonDetector_ArrowBack" )
	player.InitHudElem( "LockonDetector_ArrowLeft" )
	player.InitHudElem( "LockonDetector_ArrowRight" )
}

function SmartAmmo_LockedOntoWarningHUD_Update()
{
	local player = GetLocalViewPlayer()

	local cockpit = player.GetCockpit()
	if ( !cockpit )
		return

	local mainVGUI = cockpit.GetMainVGUI()
	if ( !mainVGUI )
		return

	local pulseFrac = clamp( GetPulseFrac( 2 ), 0.25, 1.0 )
	local previousLockedFraction = player.SmartAmmo_GetPrevHighestFraction()

	mainVGUI.s.LockonDetector_CenterBox.Hide()
	mainVGUI.s.LockonDetector_CenterBox_Label.Hide()
	mainVGUI.s.LockonDetector_ArrowForward.Hide()
	mainVGUI.s.LockonDetector_ArrowBack.Hide()
	mainVGUI.s.LockonDetector_ArrowLeft.Hide()
	mainVGUI.s.LockonDetector_ArrowRight.Hide()

	local lockedFraction = player.SmartAmmo_GetHighestFraction()
	local highestFractionSources = player.SmartAmmo_GetHighestFractionSources()
	local lockingWeapons = []
	local lockingEnemies = []
	foreach( weapon in highestFractionSources )
	{
		if ( IsValid( weapon ) )
		{
			lockingWeapons.append( weapon )
			local weaponOwner = weapon.GetWeaponOwner()
			if( IsValid( weaponOwner ) )
				lockingEnemies.append( weapon.GetWeaponOwner() )
		}
	}

	local activeLockingWeapon = null
	local highestLockSource = null
	if ( lockingWeapons && lockingWeapons.len() )
	{
		activeLockingWeapon = lockingWeapons[0]
		highestLockSource = activeLockingWeapon.GetWeaponOwner()
	}
	else
	{
		return
	}

	if ( level.meleeHintActive )
		return

	//printt( lockedFraction, highestLockSource, activeLockingWeapon )

	local reqFracForDetection = TARGET_SET_FRACTION
	if ( lockedFraction > TARGET_SET_FRACTION && IsValid( highestLockSource ) )
	{
		if ( SmartAmmo_GetWarningIndicatorDelay( activeLockingWeapon ) )
		{
			reqFracForDetection = SmartAmmo_GetWarningIndicatorDelay( activeLockingWeapon )
		}
		else
		{
			local weaponclass = activeLockingWeapon.GetSignifierName()
			if ( weaponclass in SmartAmmo_DetectorStartFracOverrides )
			{
				reqFracForDetection = SmartAmmo_DetectorStartFracOverrides[ weaponclass ]
			}
		}

		Assert( activeLockingWeapon != null )
	}

	local maxLocks = 1.0
	if ( IsValid( activeLockingWeapon ) )
	{
		maxLocks = SmartAmmo_GetTargetMaxLocks( activeLockingWeapon, player )
	}

	if ( lockedFraction >= maxLocks )
	{
		mainVGUI.s.LockonDetector_CenterBox.SetImage( "hud/lock_indicator_text_box_danger" )
		mainVGUI.s.LockonDetector_CenterBox.Show()

		local displayStr = MakeLockedOnWarningDisplayString( lockingEnemies, activeLockingWeapon )
		mainVGUI.s.LockonDetector_CenterBox_Label.SetText( displayStr )
		mainVGUI.s.LockonDetector_CenterBox_Label.SetColor( 255, 122, 56, 255 * pulseFrac )
		mainVGUI.s.LockonDetector_CenterBox_Label.Show()

		local showArrows = GetActiveLockQuadrants( player, lockingEnemies )

		if ( showArrows.forward )
		{
			mainVGUI.s.LockonDetector_ArrowForward.SetImage( "hud/lock_indicator_up_danger" )
			mainVGUI.s.LockonDetector_ArrowForward.Show()
		}
		else
		{
			mainVGUI.s.LockonDetector_ArrowForward.SetImage( "hud/lock_indicator_up" )
			mainVGUI.s.LockonDetector_ArrowForward.Show()
		}

		if ( showArrows.back )
		{
			mainVGUI.s.LockonDetector_ArrowBack.SetImage( "hud/lock_indicator_down_danger" )
			mainVGUI.s.LockonDetector_ArrowBack.Show()
		}
		else
		{
			mainVGUI.s.LockonDetector_ArrowBack.SetImage( "hud/lock_indicator_down" )
			mainVGUI.s.LockonDetector_ArrowBack.Show()
		}

		if ( showArrows.left )
		{
			mainVGUI.s.LockonDetector_ArrowLeft.SetImage( "hud/lock_indicator_left_danger" )
			mainVGUI.s.LockonDetector_ArrowLeft.Show()
		}
		else
		{
			mainVGUI.s.LockonDetector_ArrowLeft.SetImage( "hud/lock_indicator_left" )
			mainVGUI.s.LockonDetector_ArrowLeft.Show()
		}


		if ( showArrows.right )
		{
			mainVGUI.s.LockonDetector_ArrowRight.SetImage( "hud/lock_indicator_right_danger" )
			mainVGUI.s.LockonDetector_ArrowRight.Show()
		}
		else
		{
			mainVGUI.s.LockonDetector_ArrowRight.SetImage( "hud/lock_indicator_right" )
			mainVGUI.s.LockonDetector_ArrowRight.Show()
		}

		if ( previousLockedFraction < 1.0 )
		{
			if ( !( "playingVictimLockedSound" in player.s ) )
			{
				EmitSoundOnEntity( player, SMART_AMMO_VICTIM_LOCKED_SOUND )
				player.s.playingVictimLockedSound <- true
			}
		}
	}
	else if ( lockedFraction > reqFracForDetection && lockedFraction < maxLocks )
	{
		mainVGUI.s.LockonDetector_CenterBox.SetImage( "hud/lock_indicator_text_box" )
		mainVGUI.s.LockonDetector_CenterBox.Show()

		local displayStr = MakeLockingOnWarningDisplayString( lockingEnemies, activeLockingWeapon )
		mainVGUI.s.LockonDetector_CenterBox_Label.SetText( displayStr )
		//mainVGUI.s.LockonDetector_CenterBox_Label.SetColor( 255, 122, 56, 255 * pulseFrac )
		mainVGUI.s.LockonDetector_CenterBox_Label.SetColor( 255, 255, 255, 255 * pulseFrac )
		mainVGUI.s.LockonDetector_CenterBox_Label.Show()

		local showArrows = GetActiveLockQuadrants( player, lockingEnemies )

		if ( showArrows.forward )
		{
			mainVGUI.s.LockonDetector_ArrowForward.SetImage( "hud/lock_indicator_up_danger" )
			mainVGUI.s.LockonDetector_ArrowForward.Show()
		}
		else
		{
			mainVGUI.s.LockonDetector_ArrowForward.SetImage( "hud/lock_indicator_up" )
			mainVGUI.s.LockonDetector_ArrowForward.Show()
		}

		if ( showArrows.back )
		{
			mainVGUI.s.LockonDetector_ArrowBack.SetImage( "hud/lock_indicator_down_danger" )
			mainVGUI.s.LockonDetector_ArrowBack.Show()
		}
		else
		{
			mainVGUI.s.LockonDetector_ArrowBack.SetImage( "hud/lock_indicator_down" )
			mainVGUI.s.LockonDetector_ArrowBack.Show()
		}

		if ( showArrows.left )
		{
			mainVGUI.s.LockonDetector_ArrowLeft.SetImage( "hud/lock_indicator_left_danger" )
			mainVGUI.s.LockonDetector_ArrowLeft.Show()
		}
		else
		{
			mainVGUI.s.LockonDetector_ArrowLeft.SetImage( "hud/lock_indicator_left" )
			mainVGUI.s.LockonDetector_ArrowLeft.Show()
		}


		if ( showArrows.right )
		{
			mainVGUI.s.LockonDetector_ArrowRight.SetImage( "hud/lock_indicator_right_danger" )
			mainVGUI.s.LockonDetector_ArrowRight.Show()
		}
		else
		{
			mainVGUI.s.LockonDetector_ArrowRight.SetImage( "hud/lock_indicator_right" )
			mainVGUI.s.LockonDetector_ArrowRight.Show()
		}

		if ( "playingVictimLockedSound" in player.s )
		{
			StopSoundOnEntity( player, SMART_AMMO_VICTIM_LOCKED_SOUND )
			delete player.s.playingVictimLockedSound
		}
	}
	else
	{
		if ( "playingVictimLockedSound" in player.s )
		{
			StopSoundOnEntity( player, SMART_AMMO_VICTIM_LOCKED_SOUND )
			delete player.s.playingVictimLockedSound
		}
	}
}

function GetActiveLockQuadrants( player, lockingEnemies )
{
	local playerOrg = player.GetOrigin()
	local arrows = {}
	arrows.forward 	<- false
	arrows.back 	<- false
	arrows.left 	<- false
	arrows.right 	<- false

	foreach ( enemy in lockingEnemies )
	{
		local org = enemy.GetOrigin()

		local playerOrg2D = Vector( playerOrg.x, playerOrg.y, 0 )
		local lockOrg2D = Vector( org.x, org.y, 0 )

		local forward = player.GetViewVector()
		local forward2D = Vector( forward.x, forward.y, 0 )

		local right = player.GetViewRight()
		local right2D = Vector( right.x, right.y, 0 )

		local orgDiff = lockOrg2D - playerOrg2D
		orgDiff.Normalize()

		local dotForward = forward2D.Dot( orgDiff )
		local deg = DotToAngle( dotForward )

		local dotRight = right2D.Dot( orgDiff )

		//printt( "deg:", deg )

		// key: top down, first, separate into four primary quadrants (foursquare style)
		//   - q1 upperleft, q2 upperright, q3 lowerright, q4 lowerleft
		// Second: to map to the arrows we split each foursquare quadrant in half and check the degrees; half means one arrow, half means the other

		local dir = null
		if ( dotForward >= 0 && dotRight >= 0 )			// q2
			dir = deg <= 45 ? "forward" : "right"

		else if ( dotForward > 0 && dotRight < 0 )		// q1
			dir = deg <= 45 ? "forward" : "left"

		else if ( dotForward <= 0 && dotRight >= 0 )	// q3
			dir = deg <= 135 ? "right" : "back"

		else 											// q4
			dir = deg <= 135 ? "left" : "back"

		if ( !arrows[ dir ] )
			arrows[ dir ] <- true
	}

	return arrows
}

function MakeLockingOnWarningDisplayString( lockingEnemies, activeLockingWeapon )
{
	if ( lockingEnemies.len() > 1 )
	{
		return "#HUD_ENEMY_MULTIPLE_LOCKING"
	}
	else
	{
		Assert( IsValid( activeLockingWeapon ) )
		local activeLockingWeaponType = activeLockingWeapon.GetWeaponClass()
		if ( activeLockingWeaponType == "human" )
			return "#HUD_ENEMY_PILOT_LOCKING"
		else if ( activeLockingWeaponType == "titan" )
			return "#HUD_ENEMY_TITAN_LOCKING"
		else
			Assert( false, " weaponClass field is neither human nor titan!" )
	}

}

//Almost entirely the same as MakeLockingOnWarningDisplayString.
function MakeLockedOnWarningDisplayString( lockingEnemies, activeLockingWeapon )
{
	if ( lockingEnemies.len() > 1 )
	{
		return "#HUD_ENEMY_MULTIPLE_LOCK"
	}
	else
	{
		Assert( IsValid( activeLockingWeapon ) )
		local activeLockingWeaponType = activeLockingWeapon.GetWeaponClass()
		if ( activeLockingWeaponType == "human" )
			return "#HUD_ENEMY_PILOT_LOCK"
		else if ( activeLockingWeaponType == "titan" )
			return "#HUD_ENEMY_TITAN_LOCK"
		else
			Assert( false, " weaponClass field is neither human nor titan!" )

	}
}

function KillReplay_SmartAmmo_ClientStop()
{
	SmartAmmo_ClientStop( null )
}
