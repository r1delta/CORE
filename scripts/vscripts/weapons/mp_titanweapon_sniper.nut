const INSTANT_SHOT_DAMAGE = 1200

//const INSTANT_SHOT_MAX_CHARGES				= 2 // can't change this without updating crosshair
//const INSTANT_SHOT_TIME_PER_CHARGE			= 0
const SNIPER_PROJECTILE_SPEED				= 10000

chargeDownSoundDuration <- 1.0 //"charge_cooldown_time"


function OnWeaponActivate( activateParams )
{
	chargeDownSoundDuration = self.GetWeaponInfoFileKeyField( "charge_cooldown_time" )
}

function OnWeaponDeactivate( deactivateParams )
{
}

function OnWeaponReload( reloadParams )
{
}

function OnWeaponOwnerChanged( changeParams )
{
}

function OnWeaponPrimaryAttack( attackParams )
{
	return FireSniper( self, attackParams, true )
}

function OnWeaponNpcPrimaryAttack( attackParams )
{
	return FireSniper( self, attackParams, false )
}

function OnWeaponStartZoomIn()
{
	HandleWeaponSoundZoomIn( self, "Weapon_Rangemaster_Kraber.ADS_In" )
}

function OnWeaponStartZoomOut()
{
	HandleWeaponSoundZoomOut( self, "Weapon_Rangemaster_Kraber.ADS_Out" )
}

function OnWeaponChargeBegin( chargeParams )
{
	if ( IsClient() && InPrediction() && !IsFirstTimePredicted() )
		return

	local chargeTime = self.GetWeaponChargeTime()

	StopSoundOnEntity( self, "Weapon_Titan_Sniper_WindDown" )

	if( IsClient() )
	{
		if ( self.HasMod( "instant_shot" ) )
			EmitSoundOnEntityWithSeek( self, "ChargeRifle_TriggerOn", chargeTime )
		if ( self.HasMod( "burn_mod_titan_sniper" ) )
			EmitSoundOnEntityWithSeek( self, "Weapon_Titan_Sniper_WindUp_Amped", chargeTime )			
		else
			EmitSoundOnEntityWithSeek( self, "Weapon_Titan_Sniper_WindUp", chargeTime )
	}
	else
	{
		if ( self.HasMod( "instant_shot" ) )
			EmitSoundOnEntityExceptToPlayerWithSeek( self, self.GetWeaponOwner(), "ChargeRifle_TriggerOn", chargeTime )
		if ( self.HasMod( "burn_mod_titan_sniper" ) )
			EmitSoundOnEntityExceptToPlayerWithSeek( self, self.GetWeaponOwner(), "Weapon_Titan_Sniper_WindUp_Amped", chargeTime )
		else
			EmitSoundOnEntityExceptToPlayerWithSeek( self, self.GetWeaponOwner(), "Weapon_Titan_Sniper_WindUp", chargeTime )
	}
}

function OnWeaponChargeEnd( chargeParams )
{
	if ( IsClient() && InPrediction() && !IsFirstTimePredicted() )
		return

	local chargeFraction = self.GetWeaponChargeFraction()
	local seekFrac = chargeDownSoundDuration * chargeFraction
	local seekTime = max( (1 - (seekFrac * chargeDownSoundDuration)), 0 )

	StopSoundOnEntity( self, "Weapon_Titan_Sniper_SustainLoop" )

	if ( self.HasMod( "instant_shot" ) )
		StopSoundOnEntity( self, "ChargeRifle_TriggerOn" )
	if ( self.HasMod( "burn_mod_titan_sniper" ) )
		StopSoundOnEntity( self, "Weapon_Titan_Sniper_WindUp_Amped" )
	else
		StopSoundOnEntity( self, "Weapon_Titan_Sniper_WindUp" )

	if ( IsClient() )
		EmitSoundOnEntityWithSeek( self, "Weapon_Titan_Sniper_WindDown", seekTime )
	else
		EmitSoundOnEntityExceptToPlayerWithSeek( self, self.GetWeaponOwner(), "Weapon_Titan_Sniper_WindDown", seekTime )
}

function OnWeaponChargeLevelIncreased()
{
	if ( IsClient() && InPrediction() && !IsFirstTimePredicted() )
		return

	local level = self.GetWeaponChargeLevel();
	local maxLevel = self.GetWeaponChargeLevelMax();

	if ( level == maxLevel )
			self.EmitWeaponSound( "Weapon_Titan_Sniper_SustainLoop" )

	if ( IsClient() )
	{
		if ( level == maxLevel )
			self.EmitWeaponSound( "Weapon_Titan_Sniper_LevelTick_Final" )
		else
			self.EmitWeaponSound( "Weapon_Titan_Sniper_LevelTick_" + level )
	}
}


function FireSniper( weapon, attackParams, playerFired )
{
	local chargeLevel = GetTitanSniperChargeLevel( weapon )
	local weaponOwner = self.GetWeaponOwner()
	local weaponHasInstantShotMod = self.HasMod( "instant_shot" )
	if ( chargeLevel == 0 )
		return 0

	//printt( "GetTitanSniperChargeLevel():", chargeLevel )


	if ( chargeLevel > 4 )
		self.EmitWeaponSound( "Weapon_Titan_Sniper_Level_4" )
	else if ( chargeLevel > 3 || weaponHasInstantShotMod )
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
	else if ( chargeLevel > 2 || weaponHasInstantShotMod )
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

	local bolt = self.FireWeaponBolt( attackParams.pos, attackParams.dir, SNIPER_PROJECTILE_SPEED, DF_GIB | DF_BULLET | DF_ELECTRICAL, DF_EXPLOSION | DF_RAGDOLL | DF_SPECTRE_GIB, playerFired )
	bolt.kv.gravity = 0.001
	bolt.kv.bounceFrac = 0.0
	if ( weaponOwner.IsNPC() )
		bolt.s.bulletsToFire <- 0
	else
		bolt.s.bulletsToFire <- chargeLevel
	bolt.s.extraDamagePerBullet <- self.GetWeaponInfoFileKeyField( "damage_additional_bullets" )
	bolt.s.extraDamagePerBullet_Titan <- self.GetWeaponInfoFileKeyField( "damage_additional_bullets_titanarmor" )
	if( weaponHasInstantShotMod )
	{
		local damage_far_value_titanarmor = self.GetWeaponModSetting( "damage_far_value_titanarmor" )
		Assert( INSTANT_SHOT_DAMAGE > damage_far_value_titanarmor )
		bolt.s.extraDamagePerBullet_Titan = INSTANT_SHOT_DAMAGE - damage_far_value_titanarmor
		bolt.s.bulletsToFire = 2
	}

	if ( chargeLevel > 4 )
		bolt.SetProjectilTrailEffectIndex( 2 )
	else if ( chargeLevel > 2 )
		bolt.SetProjectilTrailEffectIndex( 1 )

	if ( IsServer() )
	{
		local weaponOwner = self.GetWeaponOwner()
		bolt.SetOwner( weaponOwner )
	}

	return 1
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
	return (1 + charges)
}
