
const SNIPER_PROJECTILE_SPEED				= 10000
const DEBUG_DRAW_PATH 			= false

// mp_weapon_charge_cannon
const LAUNCHER_CHARGE_TIME = 15.0
const LAUNCHER_MAX_CHARGES = 1

RegisterSignal( "RegenAmmo" )
RegisterSignal( "UpdateWeapons" )
chargeDownSoundDuration <- 1.0 //"charge_cooldown_time"

const CHARGE_FX = "P_wpn_defender_charge" //"P_wpn_charge_cannon_charge"
const CHARGE_FX_FP = "P_wpn_defender_charge_FP" //"P_wpn_charge_cannon_charge_FP"

function LauncherPrecache( weapon )
{
	if ( WeaponIsPrecached( self ) )
		return

	PrecacheParticleSystem( CHARGE_FX )
	PrecacheParticleSystem( CHARGE_FX_FP )
	PrecacheParticleSystem( "defender_charge_CH_dlight" )
}

LauncherPrecache( self )

function OnWeaponActivate( activateParams )
{
	//self.EmitWeaponSound( "Weapon_Charge_cannon_chaRgeStart" )

	chargeDownSoundDuration = self.GetWeaponModSetting( "charge_cooldown_time" )

	if ( !( "maxAmmoCharges" in self.s ) )
		self.s.maxAmmoCharges <- LAUNCHER_MAX_CHARGES

	if ( IsServer() )
	{
		self.s.shoulderChargeEffect1 <- null
		self.s.shoulderChargeEffect2 <- null
	}
}

function OnWeaponDeactivate( deactivateParams )
{
	self.StopWeaponSound( "Weapon_Titan_Charge_Cannon_Loop" )
}

function OnWeaponOwnerChanged( changeParams )
{
}

function OnWeaponPrimaryAttack( attackParams )
{
	return FireChargeCannon( self, attackParams, true)
	//return FireSniper( self, attackParams, true )
}

function OnWeaponNpcPrimaryAttack( attackParams )
{
	return FireChargeCannon( self, attackParams, false)
	//return FireSniper( self, attackParams, false )
}

function OnWeaponChargeBegin( chargeParams )
{
	if ( IsClient() && InPrediction() && !IsFirstTimePredicted() )
		return

	local chargeTime = self.GetWeaponChargeTime()

	//StopSoundOnEntity( self, "Weapon_Titan_Sniper_WindDown" )

	if( IsClient() )
		EmitSoundOnEntityWithSeek( self, "Weapon_Charge_Cannon_ChargeStart", chargeTime )	
	else
	{
		EmitSoundOnEntityExceptToPlayerWithSeek( self, self.GetWeaponOwner(), "Weapon_Charge_Cannon_ChargeStart", chargeTime )
	}

	printt("------------charge begin------------")

	self.PlayWeaponEffect( CHARGE_FX_FP, null, "muzzle_flash" )

	if ( IsServer() )
	{
		self.s.shoulderChargeEffect1 = PlayShoulderCannonFX( CHARGE_FX, true )
		self.s.shoulderChargeEffect2 = PlayShoulderCannonFX( "defender_charge_CH_dlight", true )
	}
}

function OnWeaponCustomActivityStart()
{
	if (IsServer())
	{
		self.SetWeaponChargeFractionForced(0)
	}

	StopSoundOnEntity( self, "Weapon_Titan_Charge_Cannon_Loop" )

	self.StopWeaponEffect( CHARGE_FX_FP, null )

	if ( IsServer() )
	{
		StopShoulderCannonFX( self.s.shoulderChargeEffect1 )
		StopShoulderCannonFX( self.s.shoulderChargeEffect2 )
	}
}

function OnWeaponChargeEnd( chargeParams )
{
	if ( IsClient() && InPrediction() && !IsFirstTimePredicted() )
		return

//	local firstChargeEnd = chargeParams["firstChargeEnd"]
//
//	if (firstChargeEnd == false)
//		return

	local chargeFraction = self.GetWeaponChargeFraction()
	local seekFrac = chargeDownSoundDuration * chargeFraction
	local seekTime = max( (1 - (seekFrac * chargeDownSoundDuration)), 0 )

	StopSoundOnEntity( self, "Weapon_Charge_Cannon_ChargeStart" )

	printt( format( "charge end!! %f, %f", seekFrac, seekTime ) )
}

function OnClientAnimEvent( name ) //총구에서 발사되도록 수정 KWANYONG
{
	local handle = null
	local fpEffect
	fpEffect = "wpn_muzzleflash_vortex_mod_CP_FP"
		
	if ( GetLocalViewPlayer() == self.GetWeaponOwner() )
	{
		self.PlayWeaponEffect( fpEffect, null, "muzzle_flash")
		handle = self.AllocateHandleForViewmodelEffect( fpEffect )

		if ( !handle && GetBugReproNum() != 25362 )
			handle = StartParticleEffectOnEntity( self, GetParticleSystemIndex( fpEffect ), FX_PATTACH_POINT_FOLLOW, self.LookupAttachment( "muzzle_flash" ) )
	}
	else
	{
		handle = StartParticleEffectOnEntity( self, GetParticleSystemIndex( fpEffect ), FX_PATTACH_POINT_FOLLOW, self.LookupAttachment( "muzzle_flash" ) )
	}

	//Assert( handle )
	// This Assert isn't valid because Effect might have been culled
	// Assert( EffectDoesExist( handle ), "vortex shield OnClientAnimEvent: Couldn't find viewmodel effect handle for vortex muzzle flash effect on client " + GetLocalViewPlayer() )

	//local colorVec = GetVortexSphereCurrentColor( self )
	//EffectSetControlPointVector( handle, 1, colorVec )

}

function OnWeaponChargeLevelIncreased()
{
	if ( IsClient() && InPrediction() && !IsFirstTimePredicted() )
		return

	local level = self.GetWeaponChargeLevel();
	local maxLevel = self.GetWeaponChargeLevelMax();

	if ( level == maxLevel )
		self.EmitWeaponSound( "Weapon_Titan_Charge_Cannon_Loop" )

	if ( IsClient() )
	{
		if ( level == maxLevel )
			self.EmitWeaponSound( "Weapon_Charge_Cannon_LevelTick_Final" )
		else
			self.EmitWeaponSound( "Weapon_Charge_Cannon_LevelTick_" + level )
	}
}

function RegenerateAmmo()
{
	wait chargeDownSoundDuration

	if ( IsServer() )
	{
		if( IsValid(self) )
		{
			local ammo = self.GetWeaponPrimaryClipCount()
			if ( ammo < LAUNCHER_MAX_CHARGES )
				self.SetWeaponPrimaryClipCount( ammo + 1 )
		}
	}
}

function GetTitanSniperChargeLevel( weapon )
{
	if ( !IsValid( weapon ) )
		return 0

	local owner = weapon.GetWeaponOwner()

	if ( !IsValid( owner ) )
		return 0

	if ( !owner.IsPlayer() )
		return 3

	if ( !weapon.IsReadyToFire() )
		return 0

	local charges = weapon.GetWeaponChargeLevel()

	if( charges >= 2 )
	{
		charges = 2
	}
	
	return (1 + charges)
}

function CooldownBarFracFunc()
{
	if ( !IsValid( self ) )
		return 0

	if ( self.IsBurstFireInProgress() )
		return 0

	local frac = self.TimeUntilReadyToFire()
	if ( frac > 1 )
		frac = 1
	return 1 - frac
}

function FireChargeCannon( weapon, attackParams, playerFired)
{
	StopSoundOnEntity( self, "Weapon_Titan_Charge_Cannon_Loop" )

	self.StopWeaponEffect( CHARGE_FX_FP, null )

	if ( IsServer() )
	{
		StopShoulderCannonFX( self.s.shoulderChargeEffect1 )
		StopShoulderCannonFX( self.s.shoulderChargeEffect2 )
	}

	local chargeLevel = GetTitanSniperChargeLevel( weapon )
	local maxLevel = self.GetWeaponChargeLevelMax();
	local weaponOwner = self.GetWeaponOwner()

	PlayShoulderCannonFX( "wpn_muzzleflash_xo_sniper", true )
	//PlayShoulderCannonFX( "P_wpn_defender_beam", false, some_angle ) // TODO

	if ( chargeLevel == 0 )
		return 0

	if( chargeLevel > maxLevel )
	{
		chargeLevel = maxLevel
	}

	// 발사 직후 hud ui 게이지 강제로 비워주는 코드. test 용
	self.ForceRelease()
	self.SetWeaponChargeFractionForced(1.0)

	//printt( "GetTitanSniperChargeLevel():", chargeLevel )

	if ( chargeLevel > 4 )
		self.EmitWeaponSound( "Weapon_Titan_Sniper_Level_4" )
	else if ( chargeLevel > 3  )
		self.EmitWeaponSound( "Weapon_Titan_Sniper_Level_3" )
	else if ( chargeLevel > 2  )
		self.EmitWeaponSound( "Weapon_Titan_Sniper_Level_2" )
	else
		self.EmitWeaponSound( "Weapon_Titan_Sniper_Level_1" )

	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 * chargeLevel )

	if ( chargeLevel > 5 )
	{
		self.SetAttackKickScale( 1.0 )
		self.SetAttackKickRollScale( 3.0 )
	}
	else if ( chargeLevel > 4 )
	{
		self.SetAttackKickScale( 0.75 )
		self.SetAttackKickRollScale( 2.5 )
	}
	else if ( chargeLevel > 3 )
	{
		self.SetAttackKickScale( 0.60 )
		self.SetAttackKickRollScale( 2.0 )
	}
	else if ( chargeLevel > 2 )
	{
		self.SetAttackKickScale( 0.45 )
		self.SetAttackKickRollScale( 1.60 )
	}
	else if ( chargeLevel > 1 )
	{
		self.SetAttackKickScale( 0.30 )
		self.SetAttackKickRollScale( 1.35 )
	}
	else
	{
		self.SetAttackKickScale( 0.20 )
		self.SetAttackKickRollScale( 1.0 )
	}

	local shouldCreateProjectile = false
	if ( IsServer() || self.ShouldPredictProjectiles() )
		shouldCreateProjectile = true
	if ( IsClient() && !playerFired )
		shouldCreateProjectile = false

	if ( !shouldCreateProjectile )
		return 1

	local weaponOwner = self.GetWeaponOwner()
	if ( weaponOwner.IsPlayer() )
		self.EmitWeaponSound( "ChargeRifle_Fire" )
	else
		self.EmitWeaponSound( "ChargeRifle_Fire" )
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	self.FireWeaponBullet( attackParams.pos, attackParams.dir, chargeLevel, DF_GIB | DF_SPECTRE_GIB | DF_EXPLOSION )

	thread RegenerateAmmo()

	return 1
}

function PlayShoulderCannonFX( effect, parentToCannon, optionalRotation = null )
{
	if ( IsClient() )
		return

	local weaponOwner = self.GetWeaponOwner()
	if ( !weaponOwner )
		return

	local soul = weaponOwner.GetTitanSoul()
	if ( !soul )
		return

	local chargeCannon = soul.chargeCannon.model
	if ( !chargeCannon )
		return

	local attachID = chargeCannon.LookupAttachment( "muzzle_flash" )
	local visibilityFlags = 6 // use null to view effects in thirdperson when testing

	if ( parentToCannon )
		PlayFXOnEntity( effect, chargeCannon, "muzzle_flash", null, optionalRotation, visibilityFlags, weaponOwner )
	else
		PlayFXOnEntity( effect, null, null, chargeCannon.GetAttachmentOrigin( attachID ), chargeCannon.GetAttachmentAngles( attachID ), visibilityFlags, weaponOwner )
}

function StopShoulderCannonFX( effect )
{
	if ( IsClient() )
		return

	local weaponOwner = self.GetWeaponOwner()
	if ( !weaponOwner )
		return

	local soul = weaponOwner.GetTitanSoul()
	if ( !soul )
		return

	local chargeCannon = soul.chargeCannon.model
	if ( !chargeCannon )
		return

	if ( !IsValid_ThisFrame( effect ) )
		return

	StopFX( effect )
	effect.Fire( "Destroy" )
	StopFX_DestroyImmediately( effect )
	effect.ClearParent()
	effect.Destroy()
	effect = null
}
