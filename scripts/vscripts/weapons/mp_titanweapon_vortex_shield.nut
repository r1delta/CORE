
self.s.lastFireTime <- 0
self.s.hadChargeWhenFired <- false

const ACTIVATION_COST_FRAC = 0.1

//Remove and replace with FireWeaponBulletBroadcast next patch.
RegisterSignal( "DisableAmpedVortex" )
RegisterSignal( "FireAmpedVortexBullet" )

if ( IsClient() )
{
	self.s.lastUseTime <- 0
}

function VortexShieldPrecache()
{
	if ( WeaponIsPrecached( self ) )
		return

	PrecacheParticleSystem( "wpn_vortex_chargingCP_titan_FP" )
	PrecacheParticleSystem( "wpn_vortex_chargingCP_titan_FP_replay" )
	PrecacheParticleSystem( "wpn_vortex_chargingCP_titan" )
	PrecacheParticleSystem( "wpn_vortex_shield_impact_titan" )
	PrecacheParticleSystem( "wpn_muzzleflash_vortex_titan_CP_FP" )

	PrecacheParticleSystem( "wpn_vortex_chargingCP_mod_FP" )
	PrecacheParticleSystem( "wpn_vortex_chargingCP_mod_FP_replay" )
	PrecacheParticleSystem( "wpn_vortex_chargingCP_mod" )
	PrecacheParticleSystem( "wpn_vortex_shield_impact_mod" )
	PrecacheParticleSystem( "wpn_muzzleflash_vortex_mod_CP_FP" )

	PrecacheParticleSystem( "P_impact_exp_emp_med_air" )
}
VortexShieldPrecache()

function VortexShieldMain()
{
	self.s.fxChargingFPControlPoint <- "wpn_vortex_chargingCP_titan_FP"
	self.s.fxChargingFPControlPointReplay <- "wpn_vortex_chargingCP_titan_FP_replay"
	self.s.fxChargingControlPoint <- "wpn_vortex_chargingCP_titan"
	self.s.fxBulletHit <- "wpn_vortex_shield_impact_titan"

	self.s.fxChargingFPControlPointBurn <- "wpn_vortex_chargingCP_mod_FP"
	self.s.fxChargingFPControlPointReplayBurn <- "wpn_vortex_chargingCP_mod_FP_replay"
	self.s.fxChargingControlPointBurn <- "wpn_vortex_chargingCP_mod"
	self.s.fxBulletHitBurn <- "wpn_vortex_shield_impact_mod"

	self.s.fxElectricalExplosion <- "P_impact_exp_emp_med_air"
}
VortexShieldMain()

function OnWeaponActivate( activateParams )
{
	local weaponOwner = self.GetWeaponOwner()


	// just for NPCs (they don't do the deploy event)
	if ( !weaponOwner.IsPlayer() )
	{
		Assert( !( "isVortexing" in weaponOwner.s ), "NPC trying to vortex before cleaning up last vortex" )
		StartVortex()
	}
	
	if ( IsServer() && self.GetWeaponModSetting( "is_burn_mod" ) )
		thread AmpedVortexRefireThink( self )
}

function OnWeaponDeactivate( deactivateParams )
{
	EndVortex()
	
	if ( self.GetWeaponModSetting( "is_burn_mod" ) )
		self.Signal( "DisableAmpedVortex" )
}

function OnWeaponCustomActivityStart()
{
	EndVortex()
}

function StartVortex()
{
	local weaponOwner = self.GetWeaponOwner()

	if ( IsClient() && weaponOwner != GetLocalViewPlayer() )
		return

	Assert( IsAlive( weaponOwner ),  "ent trying to start vortexing after death: " + weaponOwner )

	if ( "shotgunPelletsToIgnore" in self.s )
		self.s.shotgunPelletsToIgnore = 0
	else
		self.s.shotgunPelletsToIgnore <- 0

	Vortex_SetBulletCollectionOffset( self, Vector( 110, -28, -22.0 ) )

	local sphereRadius = 150
	local bulletFOV = 120

	ApplyActivationCost()

	local hasBurnMod = self.GetWeaponModSetting( "is_burn_mod" )
	if ( self.GetWeaponChargeFraction() < 1 )
	{
		self.s.hadChargeWhenFired = true

		//OnWeaponAttemptOffhandSwitch is not called for auto-Titans.
		if ( !weaponOwner.IsPlayer() )
		{
			if ( hasBurnMod )
				self.EmitWeaponSound( "Vortex_Shield_Start_Amped" )
			else
				self.EmitWeaponSound( "Vortex_Shield_Start" )
		}

		CreateVortexSphere( self, false, false, sphereRadius, bulletFOV )
		EnableVortexSphere( self )
	}
	else
	{
		self.s.hadChargeWhenFired = false
		//printt( "SFX no charge" )
			self.EmitWeaponSound( "Vortex_Shield_Empty" )
	}

	if ( IsServer() )
	{
		thread ForceReleaseOnPlayerEject()
	}

	if ( IsClient() )
	{
		self.s.lastUseTime = Time()
	}
}

function AmpedVortexRefireThink( weapon )
{
	local weaponOwner = weapon.GetWeaponOwner()
	weapon.EndSignal( "DisableAmpedVortex" )
	weapon.EndSignal( "OnDestroy" )
	weaponOwner.EndSignal( "Disconnected" )
		
	for ( ;; )
	{
		weapon.WaitSignal( "FireAmpedVortexBullet" )
		
		if ( IsValid( weaponOwner )	)
		{
			ShotgunBlast( weaponOwner.EyePosition(), weaponOwner.GetViewVector(), weapon.s.ampedBulletCount, damageTypes.Shotgun | DF_VORTEX_REFIRE )
			weapon.s.ampedBulletCount = 0
		}
	}	
}

function ForceReleaseOnPlayerEject()
{
	self.EndSignal( "VortexFired" )
	self.EndSignal( "OnDestroy" )

	local weaponOwner = self.GetWeaponOwner()
	if ( !IsAlive( weaponOwner ) )
		return

	weaponOwner.EndSignal( "OnDeath" )
	weaponOwner.EndSignal( "Disconnected" )

	weaponOwner.WaitSignal( "TitanEjectionStarted" )

	self.ForceRelease()
}

function ApplyActivationCost()
{
	local fracLeft = self.GetWeaponChargeFraction()

	if ( fracLeft + ACTIVATION_COST_FRAC >= 1 )
	{
		self.ForceRelease()
		self.SetWeaponChargeFraction( 1.0 )
	}
	else
	{
		self.SetWeaponChargeFraction( fracLeft + ACTIVATION_COST_FRAC )
	}
}

function EndVortex()
{
	if ( IsClient() )
	{
		self.s.lastUseTime = Time()
	}

	if ( self.GetWeaponModSetting( "is_burn_mod" ) )
		self.StopWeaponSound( "Vortex_Shield_Start_Amped" )
	else
		self.StopWeaponSound( "Vortex_Shield_Start" )

		self.StopWeaponSound( "Vortex_Shield_Loop" )			


	if ( self.HasMod( "unlimited_charge_time" ) )
		self.EmitWeaponSound( "Vortex_Shield_LoopStart" )

	DestroyVortexSphere( self )
}

function OnWeaponVortexHitBullet( vortexSphere, damageInfo )
{
	if ( IsClient() )
		return true

	if ( !ValidateVortexImpact( vortexSphere ) )
		return false


	local attacker			= damageInfo.GetAttacker()
	local origin			= damageInfo.GetDamagePosition()
	local damageSourceID	= damageInfo.GetDamageSourceIdentifier()
	local weapon			= damageInfo.GetWeapon()
	local weaponName		= weapon.GetClassname()
	local damageType		= damageInfo.GetCustomDamageType()

	return TryVortexAbsorb( vortexSphere, attacker, origin, damageSourceID, weapon, weaponName, "hitscan", null, damageType, self.HasMod( "burn_mod_titan_vortex_shield" ) )
}

function OnWeaponVortexHitProjectile( vortexSphere, attacker, projectile, contactPos )
{
	if ( IsClient() )
		return true

	if ( !ValidateVortexImpact( vortexSphere, projectile ) )
		return false

	local damageSourceID = projectile.GetDamageSourceID()
	local weaponName = projectile.GetWeaponClassName()

	return TryVortexAbsorb( vortexSphere, attacker, contactPos, damageSourceID, projectile, weaponName, "projectile", projectile, null, self.HasMod( "burn_mod_titan_vortex_shield" ) )
}

function OnWeaponPrimaryAttack( attackParams )
{
	local bulletsFired = VortexPrimaryAttack( self, attackParams )
	local hasBurnMod = self.GetWeaponModSetting( "is_burn_mod" )
	// only play the release/refire endcap sounds if we started with charge remaining
	if ( self.s.hadChargeWhenFired )
	{
		local attackSound = "Vortex_Shield_End"
		if ( bulletsFired )
		{
			self.s.lastFireTime = Time()
			if ( hasBurnMod )
				attackSound = "Vortex_Shield_Deflect_Amped"
			else
				attackSound = "Vortex_Shield_Throw"
		}

		//printt( "SFX attack sound:", attackSound )
		self.EmitWeaponSound( attackSound )
	}

	DestroyVortexSphere( self )  // sphere ent holds networked ammo count, destroy it after predicted firing is done

	if ( hasBurnMod )
		FadeOutSoundOnEntity( self, "Vortex_Shield_Start_Amped", 0.15 )			
	else
		FadeOutSoundOnEntity( self, "Vortex_Shield_Start", 0.15 )

	return bulletsFired
}


function OnWeaponNpcPrimaryAttack( attackParams )
{
	local bulletsFired = VortexPrimaryAttack( self, attackParams )

	DestroyVortexSphere( self )  // sphere ent holds networked ammo count, destroy it after predicted firing is done

	return bulletsFired
}

function OnClientAnimEvent( name )
{
	if ( name == "muzzle_flash" )
	{
		local handle = null
		local fpEffect
		if ( self.GetWeaponModSetting( "is_burn_mod" ) )
			fpEffect = "wpn_muzzleflash_vortex_mod_CP_FP"
		else
			fpEffect = "wpn_muzzleflash_vortex_titan_CP_FP"
			
		if ( GetLocalViewPlayer() == self.GetWeaponOwner() )
		{
			self.PlayWeaponEffect( fpEffect, null, "vortex_center" )
			handle = self.AllocateHandleForViewmodelEffect( fpEffect )

			if ( !handle && GetBugReproNum() != 25362 )
				handle = StartParticleEffectOnEntity( self, GetParticleSystemIndex( fpEffect ), FX_PATTACH_POINT_FOLLOW, self.LookupAttachment( "vortex_center" ) )
		}
		else
		{
			handle = StartParticleEffectOnEntity( self, GetParticleSystemIndex( fpEffect ), FX_PATTACH_POINT_FOLLOW, self.LookupAttachment( "vortex_center" ) )
		}

		Assert( handle )
		// This Assert isn't valid because Effect might have been culled
		// Assert( EffectDoesExist( handle ), "vortex shield OnClientAnimEvent: Couldn't find viewmodel effect handle for vortex muzzle flash effect on client " + GetLocalViewPlayer() )

		local colorVec = GetVortexSphereCurrentColor( self )
		EffectSetControlPointVector( handle, 1, colorVec )
	}
}

function CooldownBarFracFunc()
{
	if ( IsValid( self ) )
	{
		return 1.0 - ( self.GetWeaponChargeFraction() * 1.0 )

		/*
		local amount = ( ( 1.0 - self.GetWeaponChargeFraction() ) * 1.4 ) - 0.4

		// flicker
		if ( amount <= 0.1 )
		{
			if ( Time() % 0.4 > 0.2 )
				amount = 0
			else
				amount = 0.1
		}
		return amount
		*/
	}
	return 0
}


function OnWeaponChargeBegin( chargeParams )
{
	local weaponOwner = self.GetWeaponOwner()

	// just for players
	if ( weaponOwner.IsPlayer() )
	{
		StartVortex()
	}
}


function OnWeaponChargeEnd( chargeParams )
{
	if ( VORTEX_PAIN )
		return
}

function OnWeaponAttemptOffhandSwitch()
{
	local allowSwitch = self.GetWeaponChargeFraction() < 0.8

	if( !allowSwitch && IsFirstTimePredicted() )
	{
		// Play SFX and show some HUD feedback here...
	}
	if ( allowSwitch )
	{
		if ( self.HasMod( "unlimited_charge_time" ) )
		{
			self.EmitWeaponSound( "Vortex_Shield_LoopStart" )
			self.EmitWeaponSound( "Vortex_Shield_Loop" )
		}
		else if ( self.GetWeaponModSetting( "is_burn_mod" ) )
		{
			self.EmitWeaponSound( "Vortex_Shield_Start_Amped" )			
		}
		else
		{
			self.EmitWeaponSound( "Vortex_Shield_Start" )
		}
	}
	// Return whether or not we can bring up the vortex
	// Only allow it if we have enough charge to do anything
	return allowSwitch
}


