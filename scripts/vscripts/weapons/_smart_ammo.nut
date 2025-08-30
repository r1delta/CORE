const SMART_AMMO_DEFAULT_AIM_ATTACHMENT = "CHESTFOCUS"
const SMART_AMMO_AI_AIM_ATTACHMENT = "HEADSHOT"
const SMART_AMMO_GRENADE_AIM_ATTACHMENT = "LIGHT" //Satchels have LIGHT others grenades default to worldspace.
const TARGET_SET_FRACTION = 0.0001 //This target.fraction is set so the target is not seen as new.
const HOMING_SFX_LOOP	= "Weapon_ARL.Projectile"
const SMART_AMMO_PLAYER_MAX_LOCKS			= 3

function main()
{
	/****************************************************/
	/*				Mega Weapon Functions				*/
	/****************************************************/

	// Called from mega weapon script callbacks
	Globalize( SmartAmmo_Start )					// Start smart ammo logic. Call this from OnWeaponActivate()
	Globalize( SmartAmmo_Stop )						// Stop smart ammo logic. Call this from OnWeaponDeactivate()
	Globalize( SmartAmmo_FireWeapon )				// Fire smart ammo. Call this from OnWeaponPrimaryAttack()

	/********************************/
	/*	 Global Utility Functions	*/
	/*	Call these from any script	*/
	/********************************/

	// Behavior Option Functions
	Globalize( SmartAmmo_SetAllowUnlockedFiring )	// Allow or Disallow the weapon to be fired even if no targets have been locked. Default is false ( requires lock )
	Globalize( SmartAmmo_SetAimAttachment )			// Set a custom attachment name for target lockon
	Globalize( SmartAmmo_SetMissileSpeed )			// Set the speed the missile will travel when it is first created
	Globalize( SmartAmmo_SetMissileSpeedLimit )		// Sets the max speed for the missile. After being created it will accelerate up to this speed
	Globalize( SmartAmmo_SetMissileHomingSpeed )	// Set the turning 'homing' rate of the missile
	Globalize( SmartAmmo_SetMissileShouldDropKick ) // Set whether missiles from this weapon should do "drop-kick" behavior (kinetic firing + gravity drop for a moment before thrusters kick in)
	Globalize( SmartAmmo_SetUnlockAfterBurst )		// Makes the targets get cleared after the burst fire is complete. Default is false
	Globalize( SmartAmmo_SetMissileAimAtCursor )	// Makes missiles fly towards where the crosshair is aimed, instead of parallel to the crosshair direction. Default is false.
	Globalize( SmartAmmo_SetWarningIndicatorDelay )
	Globalize( SmartAmmo_SetDisplayKeybinding )
	Globalize( SmartAmmo_SetExpandContract )

	/****************************************************/
	/*				Interal Get/Set Functions			*/
	/*	( not meant to be called outside smart script )	*/
	/****************************************************/

	Globalize( SmartAmmo_GetUseAltAmmoFunc )
	Globalize( SmartAmmo_GetAllowUnlockedFiring )
	Globalize( SmartAmmo_SetWeaponFireFailedTime )
	Globalize( SmartAmmo_GetWeaponFireFailedTime )
	Globalize( SmartAmmo_GetAimAttachment )
	Globalize( SmartAmmo_GetLockonCoordinate )
	Globalize( SmartAmmo_GetHudLockonStyle )
	Globalize( SmartAmmo_GetMissileSpeed )
	Globalize( SmartAmmo_GetMissileSpeedLimit )
	Globalize( SmartAmmo_GetMissileHomingSpeed )
	Globalize( SmartAmmo_GetMissileShouldDropKick )
	Globalize( SmartAmmo_GetUnlockAfterBurst )
	Globalize( SmartAmmo_GetMissileAimAtCursor )
	Globalize( SmartAmmo_GetWarningIndicatorDelay )
	Globalize( SmartAmmo_GetDisplayKeybinding )
	Globalize( SmartAmmo_GetExpandContract )

	Globalize( SmartAmmo_SetMissileTarget )
	Globalize( SmartAmmo_TransferMissileLockons )
	Globalize( SmartAmmo_CanWeaponBeFired )

	if ( IsClient() )
	{
		Globalize( ClientCodeCallback_OnPredictedEntityRemove )
	}
	else
	{
		AddDamageCallbackSourceID( eDamageSourceId.mp_weapon_smart_pistol, SmartPistol_DamagedPlayerOrNPC )
	}
}

/******************************************/
/* 	GLOBAL - CALLED ON CLIENT AND SERVER  */
/******************************************/

function SmartAmmo_Start( weapon )
{
	local player = weapon.GetWeaponOwner()
	if ( !IsValid_ThisFrame( player ) || !player.IsPlayer() )
		return

	if ( IsServer() || InPrediction() )
		weapon.SmartAmmo_Enable()
}

function SmartAmmo_Stop( weapon, player = null )
{
	if ( IsClient() && DoesPlayerOwnWeapon( GetLocalViewPlayer(), weapon ) )
			SmartAmmo_ClientStop( weapon )

	if ( IsServer() || InPrediction() )
		weapon.SmartAmmo_Disable()
}

function SmartAmmo_FireWeapon( weapon, attackParams, damageType = 0 )
{
	if ( !IsValid( weapon ) || !weapon.SmartAmmo_IsEnabled() )
		return 0

	local player = weapon.GetWeaponOwner()
	local storedTargets

	local targets = weapon.SmartAmmo_GetTargets()
	local targetFracs = {}
	foreach ( target in targets )
	{
		if ( target.fraction < 1.0 )
			continue

		targetFracs[target.entity] <- target.fraction
	}

	if ( attackParams.burstIndex == 0 )
	{
		// The first time we fire the weapon we store off all targets we are locked onto so we can iterate through them with each burst shot.
		// The reason we have to store them off is because if burst bullet 1 kills the first target they will be removed from the smart targets array
		// when the second burst bullet is fired, and when we try to shoot target '2' we will actually be shooting target '3' becuase index 0 is removed
		// and all targets shift in the array

		weapon.SmartAmmo_StoreTargets()
		//printt( "Storing", weapon.SmartAmmo_GetStoredTargets().len(), "targets" )
		//PrintTable( weapon.SmartAmmo_GetStoredTargets() )

		// figure out how many targets to hit with one pull of the trigger
		local maxTargetedBurst = SmartAmmo_GetMaxTargetedBurst( weapon )

		storedTargets = weapon.SmartAmmo_GetStoredTargets()
		local alwaysDoBurst = weapon.GetWeaponModSetting( "smart_ammo_always_do_burst" )
		local burstCount = 0

		if ( weapon.GetWeaponModSetting( "smart_ammo_alt_lock_style" ) )
		{
			local chargeFrac = 1 - weapon.GetWeaponChargeFraction()
			local shotFrac = 1 / maxTargetedBurst.tofloat()

			if ( chargeFrac < shotFrac )
				return 0
		}

		foreach ( target in storedTargets )
		{
			Assert( target in targetFracs )

			burstCount += floor( targetFracs[target] )
		}

		if ( alwaysDoBurst )
			burstCount = maxTargetedBurst

		burstCount = min( maxTargetedBurst, burstCount )

		if ( burstCount <= 0 )
			burstCount = 1

		weapon.SetWeaponBurstFireCount( burstCount )
	}

	storedTargets = weapon.SmartAmmo_GetStoredTargets()

	// We don't have any targets locked. Should we do unlocked fire?
	if ( storedTargets.len() == 0 && !SmartAmmo_GetAllowUnlockedFiring( weapon ) )
	{
		SmartAmmo_SetWeaponFireFailedTime( weapon )
		return 0
	}

	local expandedStoredTargets = []

	foreach ( target in storedTargets )
	{
		local burstCount

		if ( target in targetFracs )
			burstCount = floor( targetFracs[target] )
		else
			burstCount = 1

		for ( local index = 0; index < burstCount; index++ )
		{
			expandedStoredTargets.append( target )
		}
	}

	// Figure out the target we should be shooting this round
	local target = null
	if ( expandedStoredTargets.len() > 0 )
	{
		local index = attackParams.burstIndex
		while( index >= expandedStoredTargets.len() )
			index -= expandedStoredTargets.len()
		target = expandedStoredTargets[index]
	}

	// Tried to shoot at a target but it's no longer valid. Don't do anything
	if ( target != null && !IsValid( target ) )
		return 0

	// play weapon sounds
	local weaponscriptscope = weapon.GetScriptScope()
	weaponscriptscope.SmartWeaponFireSound( weapon, target )

	// Fire the weapon
	local weaponType = weapon.GetSmartAmmoWeaponType()
	Assert( weaponType in VALID_WEAPON_TYPES )

	local shotsFired = VALID_WEAPON_TYPES[ weaponType ]( weapon, attackParams, damageType, target )

	local isLastShot = ( attackParams.burstIndex + 1 == weapon.GetWeaponBurstFireCount() )
	if ( isLastShot && SmartAmmo_GetUnlockAfterBurst( weapon ) )
	{
		weapon.SmartAmmo_Clear( true )
	}

	return shotsFired
}

function SmartAmmo_FireWeapon_Bullet( weapon, attackParams, damageType, target )
{
	if ( target )
	{
		// Shoot at the specified target
		Assert( IsValid( target ) )
		local dir = SmartAmmo_GetLockonCoordinate( weapon, target ) - attackParams.pos
		weapon.FireWeaponBullet_Special( attackParams.pos, dir, 1, damageType, true, true, false, false )
	}
	else
	{
		// Not trying to shoot at a target, so just shoot straight
		weapon.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, damageType | DF_MAX_RANGE )
	}

	return 1
}

function SmartAmmo_FireWeapon_HomingMissile( weapon, attackParams, damageType, target )
{
	local shouldPredict = weapon.ShouldPredictProjectiles()

	if ( IsClient() && !shouldPredict )
		return 1

	local player = weapon.GetWeaponOwner()
	local attackPos = attackParams.pos
	local attackDir = attackParams.dir
	local missileSpeed = SmartAmmo_GetMissileSpeed( weapon )
	local doPopup = SmartAmmo_GetMissileShouldDropKick( weapon )

	if ( SmartAmmo_GetMissileAimAtCursor( weapon ) )
		attackDir = GetVectorFromPositionToCrosshair( player, attackPos )

	// Make the missile come from the rocket pods if this weapon uses them
	// Also play a pod launch effect
	if ( DoesWeaponHaveRocketPods( weapon ) )
	{
		local rocketPodInfo = GetNextRocketPodFiringInfo( weapon, attackParams )
		attackPos = rocketPodInfo.tagPos

		if( IsServer() && IsValid( rocketPodInfo.podModel ) )
		{
			local overrideAngle = VectorToAngles( attackDir )

			if ( "rocket_flash" in weapon.s )
				PlayFXOnEntity( weapon.s.rocket_flash, rocketPodInfo.podModel, rocketPodInfo.tagName, null, null, 6, player, overrideAngle )
		}
	}

	local homingSpeed = SmartAmmo_GetMissileHomingSpeed( weapon )
	local missileSpeedLimit = SmartAmmo_GetMissileSpeedLimit( weapon )

	local firedMissiles = []
	local missileFlightData = SmartAmmo_GetExpandContract( weapon )

	if ( missileFlightData == null )
	{
		local missile = weapon.FireWeaponMissile( attackPos, attackDir, missileSpeed, damageType, damageType, doPopup, shouldPredict )
		if ( missile )
		{
			//InitMissileForRandomDrift( missile, attackPos, attackDir )
			missile.InitMissileForRandomDriftFromWeaponSettings( attackPos, attackDir )
			firedMissiles.append( missile )
		}
	}
	else
	{
		firedMissiles = FireExpandContractMissiles( weapon, attackParams, attackPos, attackDir, shouldPredict, missileFlightData.numRocketsPerShot, missileSpeed, missileFlightData.launchOutAng, missileFlightData.launchOutTime, missileFlightData.launchInAng, missileFlightData.launchInTime, missileFlightData.launchInLerpTime, missileFlightData.launchStraightLerpTime, missileFlightData.applyRandSpread, weapon.GetWeaponBurstFireCount() )
	}

	foreach( missile in firedMissiles )
	{
		missile.kv.lifetime = 10

		if( IsServer() )
		{
			missile.SetOwner( player )
			EmitSoundOnEntity( missile, HOMING_SFX_LOOP )
		}

		missile.SetSpeed( missileSpeed )
		missile.SetHomingSpeeds( homingSpeed, homingSpeed / 8 )
		missile.SetTeam( player.GetTeam() )

		if ( "missileThinkThread" in weapon.s )
			thread weapon.s.missileThinkThread( weapon, missile )

		if ( missileSpeed <= missileSpeedLimit )
			thread MakeMissileAccelerate( missile, missileSpeed * 4.0, missileSpeedLimit, 0.25, 0.1 ) // missile, start accel speed, end accel speed, duration, delay

		if ( target )
		{
			//Homing Rockets continue to fire at the player when they're ejecting. This redirects them.
			if ( target.IsPlayer() && !target.IsTitan() )
			{
				local playerPetTitan = null
				if ( player.IsPlayer() )//could be npc titan
					playerPetTitan = player.GetPetTitan()

				if( IsValid( playerPetTitan ) )
				{
					SmartAmmo_SetMissileTarget( missile, playerPetTitan )
				}
			}
	        else
	        {
		        SmartAmmo_SetMissileTarget( missile, target )
	        }
		}
	}

	return firedMissiles.len()
}

/******************************************/
/* 	 GLOBAL - WEAPON SETTINGS OVERRIDES   */
/******************************************/

function SmartAmmo_SetWeaponSettingOverride( weapon, setting, value )
{
	if ( !( setting in weapon.s ) )
		weapon.s[ setting ] <- null
	weapon.s[ setting ] = value
}

function SmartAmmo_GetWeaponSettingOverride( weapon, setting, defaultValue = null )
{
	if ( setting in weapon.s )
		return weapon.s[ setting ]
	return defaultValue
}

function SmartAmmo_GetUseAltAmmoFunc( weapon )
{
	return SmartAmmo_GetWeaponSettingOverride( weapon, "useAltAmmoFunc" )
}

function SmartAmmo_SetWarningIndicatorDelay( weapon, warningIndicatorDelay )
{
	SmartAmmo_SetWeaponSettingOverride( weapon, "warningIndicatorDelay", warningIndicatorDelay.tofloat() )
}

function SmartAmmo_GetWarningIndicatorDelay( weapon )
{
	return SmartAmmo_GetWeaponSettingOverride( weapon, "warningIndicatorDelay", 0.0 )
}

function SmartAmmo_GetTargetMaxVelocity( weapon )
{
	return SmartAmmo_GetWeaponSettingOverride( weapon, "targetMaxVelocity", 0.0 )
}

function SmartAmmo_SetAllowUnlockedFiring( weapon, allow = true )
{
	SmartAmmo_SetWeaponSettingOverride( weapon, "allowUnlockedFiring", allow )
}

function SmartAmmo_GetAllowUnlockedFiring( weapon )
{
	return SmartAmmo_GetWeaponSettingOverride( weapon, "allowUnlockedFiring", false )
}

function SmartAmmo_SetWeaponFireFailedTime( weapon )
{
	SmartAmmo_SetWeaponSettingOverride( weapon, "lastFireWeaponFailTime", Time() )
}

function SmartAmmo_GetWeaponFireFailedTime( weapon )
{
	if ( !( "lastFireWeaponFailTime" in weapon.s ) )
		weapon.s.lastFireWeaponFailTime <- -1
	return Time() - weapon.s.lastFireWeaponFailTime
}

function SmartAmmo_SetAimAttachment( weapon, targetAttachment )
{
	SmartAmmo_SetWeaponSettingOverride( weapon, "targetAttachment", targetAttachment )
}

function SmartAmmo_GetAimAttachment( weapon, ent )
{
	if( ent.IsPlayer())
	{
		return SmartAmmo_GetWeaponSettingOverride( weapon, "targetAttachment", SMART_AMMO_DEFAULT_AIM_ATTACHMENT )
	}
	else if( ent.GetClassname() == "npc_grenade_frag" )
	{
		return SmartAmmo_GetWeaponSettingOverride( weapon, "targetAttachment", SMART_AMMO_GRENADE_AIM_ATTACHMENT )
	}
	else
	{
		return SmartAmmo_GetWeaponSettingOverride( weapon, "targetAttachment", SMART_AMMO_AI_AIM_ATTACHMENT )
	}
}

function SmartAmmo_GetHudLockonStyle( weapon )
{
	return weapon.GetSmartAmmoHudLockStyle()
}

function SmartAmmo_SetMissileSpeed( weapon, missileSpeed )
{
	SmartAmmo_SetWeaponSettingOverride( weapon, "missileSpeed", missileSpeed )
}

function SmartAmmo_GetMissileSpeed( weapon )
{
	return SmartAmmo_GetWeaponSettingOverride( weapon, "missileSpeed", 2500 )
}

function SmartAmmo_SetMissileHomingSpeed( weapon, missileHomingSpeed )
{
	SmartAmmo_SetWeaponSettingOverride( weapon, "missileHomingSpeed", missileHomingSpeed )
}

function SmartAmmo_GetMissileHomingSpeed( weapon )
{
	return SmartAmmo_GetWeaponSettingOverride( weapon, "missileHomingSpeed", 300 )
}

function SmartAmmo_SetMissileShouldDropKick( weapon, doDropKick = false )
{
	SmartAmmo_SetWeaponSettingOverride( weapon, "missilesShouldDropKick", doDropKick )
}

function SmartAmmo_GetMissileShouldDropKick( weapon )
{
	return SmartAmmo_GetWeaponSettingOverride( weapon, "missilesShouldDropKick", false )
}

function SmartAmmo_SetMissileSpeedLimit( weapon, missileSpeedLimit = 0 )
{
	SmartAmmo_SetWeaponSettingOverride( weapon, "missileSpeedLimit", missileSpeedLimit )
}

function SmartAmmo_GetMissileSpeedLimit( weapon )
{
	return SmartAmmo_GetWeaponSettingOverride( weapon, "missileSpeedLimit", 0 )
}

function SmartAmmo_SetUnlockAfterBurst( weapon, unlockAfterBurst )
{
	SmartAmmo_SetWeaponSettingOverride( weapon, "unlockAfterBurst", unlockAfterBurst )
}

function SmartAmmo_GetUnlockAfterBurst( weapon )
{
	return SmartAmmo_GetWeaponSettingOverride( weapon, "unlockAfterBurst", false )
}

function SmartAmmo_SetMissileAimAtCursor( weapon, aimAtCenter )
{
	SmartAmmo_SetWeaponSettingOverride( weapon, "aimAtCenter", aimAtCenter )
}

function SmartAmmo_GetMissileAimAtCursor( weapon )
{
	return SmartAmmo_GetWeaponSettingOverride( weapon, "aimAtCenter", false )
}

function SmartAmmo_SetDisplayKeybinding( weapon, displayKeybinding )
{
	SmartAmmo_SetWeaponSettingOverride( weapon, "displayKeybinding", displayKeybinding )
}

function SmartAmmo_GetDisplayKeybinding( weapon )
{
	return SmartAmmo_GetWeaponSettingOverride( weapon, "displayKeybinding", true )
}

function SmartAmmo_SetExpandContract( weapon, numRocketsPerShot, applyRandSpread, launchOutAng, launchOutTime, launchInLerpTime, launchInAng, launchInTime, launchStraightLerpTime )
{
	SmartAmmo_SetWeaponSettingOverride( weapon, "exmissile_numRocketsPerShot", numRocketsPerShot )
	SmartAmmo_SetWeaponSettingOverride( weapon, "exmissile_applyRandSpread", applyRandSpread )
	SmartAmmo_SetWeaponSettingOverride( weapon, "exmissile_launchOutAng", launchOutAng )
	SmartAmmo_SetWeaponSettingOverride( weapon, "exmissile_launchOutTime", launchOutTime )
	SmartAmmo_SetWeaponSettingOverride( weapon, "exmissile_launchInLerpTime", launchInLerpTime )
	SmartAmmo_SetWeaponSettingOverride( weapon, "exmissile_launchInAng", launchInAng )
	SmartAmmo_SetWeaponSettingOverride( weapon, "exmissile_launchInTime", launchInTime )
	SmartAmmo_SetWeaponSettingOverride( weapon, "exmissile_launchStraightLerpTime", launchStraightLerpTime )
}

function SmartAmmo_GetExpandContract( weapon )
{
	local data = {}
	data.numRocketsPerShot <- SmartAmmo_GetWeaponSettingOverride( weapon, "exmissile_numRocketsPerShot" )
	data.applyRandSpread <- SmartAmmo_GetWeaponSettingOverride( weapon, "exmissile_applyRandSpread" )
	data.launchOutAng <- SmartAmmo_GetWeaponSettingOverride( weapon, "exmissile_launchOutAng" )
	data.launchOutTime <- SmartAmmo_GetWeaponSettingOverride( weapon, "exmissile_launchOutTime" )
	data.launchInLerpTime <- SmartAmmo_GetWeaponSettingOverride( weapon, "exmissile_launchInLerpTime" )
	data.launchInAng <- SmartAmmo_GetWeaponSettingOverride( weapon, "exmissile_launchInAng" )
	data.launchInTime <- SmartAmmo_GetWeaponSettingOverride( weapon, "exmissile_launchInTime" )
	data.launchStraightLerpTime <- SmartAmmo_GetWeaponSettingOverride( weapon, "exmissile_launchStraightLerpTime" )
	foreach( k, v in data )
	{
		if ( v == null )
			return null
	}
	return data
}

/*******************************/
/* 	 GLOBAL UTILITY FUNCTION   */
/*******************************/

function SmartAmmo_SetMissileTarget( missile, target )
{
	if ( !IsValid( missile ) || !IsValid( target ) )
		return

	// Set the missile locking offset
	//local missileTargetOffset = target.IsTitan() ? Vector( 0, 0, -25 ) : Vector( 0, 0, -25 )

	// Set the missile target and homing speed
	missile.SetTarget( target, Vector( 0, 0, 0 ) )
}

function SmartAmmo_TransferMissileLockons( soul, titan = null, oldTitan = null )
{
	if ( !IsValid( oldTitan ) || !IsValid( titan ) )
		return

	local missiles = GetProjectileArray()
	foreach( missile in missiles )
	{
		if ( missile.GetClassname() != "rpg_missile" )
			continue
		if ( !( "GetTarget" in missile ) )
			continue
		if ( missile.GetTarget() == oldTitan )
			SmartAmmo_SetMissileTarget( missile, titan )
	}
}

function SmartAmmo_CanWeaponBeFired( weapon )
{
	Assert( weapon.SmartAmmo_IsEnabled() )

	if ( !weapon.IsReadyToFire() || weapon.IsReloading() )
		return false

	// Weapon is ready to fire but it's a smart weapon so we have some additional checks.
	// If the weapon requires a lock to be fired then we make sure the weapon has a full lock
	if ( SmartAmmo_GetAllowUnlockedFiring( weapon ) == true )
		return true

	local targets = weapon.SmartAmmo_GetTargets()
	local highestFraction = 0
	foreach( target in targets )
	{
		if ( target.fraction > highestFraction )
			highestFraction = target.fraction
	}

	return highestFraction == 1.0
}

/*************************/
/* 	 INTERNAL FUNCTION   */
/*************************/

function SmartAmmo_GetLockonCoordinate( weapon, ent )
{
	return weapon.SmartAmmo_GetFirePosition( ent )
}

VALID_WEAPON_TYPES <- {
		bullet 					= SmartAmmo_FireWeapon_Bullet,
		homing_missile 			= SmartAmmo_FireWeapon_HomingMissile,
		sniper					= null,
}

if ( IsClient() )
{
	function ClientCodeCallback_OnPredictedEntityRemove( serverEntity, predictedEntity )
	{
	}
}


function SmartPistol_DamagedPlayerOrNPC( ent, damageInfo )
{
	if ( !IsValid( ent ) )
		return

	local maxHealth = ent.GetMaxHealth()
	local damage = damageInfo.GetDamage()

	if ( ent.IsSpectre() )
	{
		damageInfo.SetDamage( (maxHealth / 2) + 1 )
	}
	else if ( ent.IsSoldier() )
	{
		if ( damage < maxHealth )
			damageInfo.SetDamage( maxHealth )
	}
	else if ( ent.IsPlayer() && damageInfo.GetCustomDamageType() & DF_MAX_RANGE )
	{
		damageInfo.SetDamage( 50 )
	}

	damageInfo.SetCustomDamageType( damageInfo.GetCustomDamageType() & ( ~DF_MAX_RANGE ) )
}