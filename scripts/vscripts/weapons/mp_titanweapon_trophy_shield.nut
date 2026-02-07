//SetWeaponSound( "explosive_round_impact", "Weapon.Explosion_Med" )
//SetWeaponSound( "vortex_active", "Vortex_Shield_Start" )
//SetWeaponSound( "vortex_release", "Vortex_Shield_End" )
//SetWeaponSound( "vortex_refire", "Vortex_Shield_Throw" )
//SetWeaponSound( "vortex_no_charge", "Vortex_Shield_Empty" )

//SetWeaponEffect( "charging_fp_controlpoint", "wpn_vortex_chargingCP_titan_FP" )
//SetWeaponEffect( "charging_controlpoint", "wpn_vortex_chargingCP_titan" )

//SetWeaponEffect( "bullet_hit", "wpn_vortex_shield_impact_titan" )

//SetWeaponEffect( "muzzle_flash_fp", "wpn_muzzleflash_vortex_titan_CP_FP" )
//SetWeaponEffect( "muzzle_flash", "wpn_muzzleflash_vortex_titan_CP" )
//SetWeaponEffect( "electric_explosion", "P_impact_exp_emp_med_air" )
//PrecacheWeaponAssets()

self.s.vortexSphere <- null

function TrophyShieldPrecache()
{
	if ( WeaponIsPrecached( self ) )
		return

	// currently these are unused, look at mp_titanweapon_vortex_shield for .s values to set
	PrecacheParticleSystem( "wpn_vortex_chargingCP_titan_FP" )
	PrecacheParticleSystem( "wpn_vortex_chargingCP_titan" )
	PrecacheParticleSystem( "wpn_vortex_shield_impact_titan" )
	PrecacheParticleSystem( "wpn_muzzleflash_vortex_titan_CP_FP" )
	PrecacheParticleSystem( "wpn_muzzleflash_vortex_titan_CP" )
	PrecacheParticleSystem( "P_impact_exp_emp_med_air" )
	PrecacheParticleSystem( "P_impact_exp_xsmll_air" )
}
TrophyShieldPrecache()

function OnWeaponOwnerChanged( changeParams )
{
	if ( !IsServer() )
		return

	if ( !self.s.vortexSphere )
	{
		local ownerWeapon = self
		local owner = self.GetWeaponOwner()

		local vortexSphere = CreateEntity( "vortex_sphere" )

		vortexSphere.kv.spawnflags = 1 | 8 //  SF_ABSORB_BULLETS | SF_ABSORB_CYLINDER
		vortexSphere.kv.enabled = 0
		vortexSphere.kv.radius = 160
		vortexSphere.kv.bullet_fov = 360
		vortexSphere.kv.physics_pull_strength = 25
		vortexSphere.kv.physics_side_dampening = 6
		vortexSphere.kv.physics_fov = 360
		vortexSphere.kv.physics_max_mass = 2
		vortexSphere.kv.physics_max_size = 6
		Assert( owner.IsNPC() || owner.IsPlayer(), "Vortex script expects the weapon owner to be a player or NPC." )
		local spawnAngles = VectorToAngles( owner.GetViewVector() )
		vortexSphere.SetAngles( spawnAngles )
		vortexSphere.SetOrigin( owner.GetWorldSpaceCenter() + ( spawnAngles.AnglesToForward() * 20 ) )

		DispatchSpawn( vortexSphere, false )

		self.s.vortexSphere = vortexSphere

		vortexSphere.SetOwnerWeapon( ownerWeapon )
	}

	if ( changeParams.oldOwner != null )
	{
		self.s.vortexSphere.SetOwner( null )
		self.s.vortexSphere.ClearParent()

		self.s.vortexSphere.FireNow( "Disable" )
	}

	if ( changeParams.newOwner != null )
	{
		self.s.vortexSphere.SetOwner( changeParams.newOwner )
		self.s.vortexSphere.SetParent( changeParams.newOwner, "exp_torso_up", false, 0 )

		self.s.vortexSphere.FireNow( "Enable" )
	}
}

function OnWeaponVortexHitBullet( vortexSphere, damageInfo )
{
	return false
}

function OnWeaponVortexHitProjectile( vortexSphere, attacker, projectile, contactPos )
{
	local chargeFraction = self.GetWeaponChargeFraction()

	if ( chargeFraction == 1.0 )
	{
		// play offline warning
		return false
	}

	printt( chargeFraction )

	chargeFraction += 0.2
	self.SetWeaponChargeFraction( chargeFraction )

	return true
}

function OnWeaponPrimaryAttack( attackParams )
{
	if ( !IsServer() )
		return 0

	if ( self.s.vortexSphere.kv.enabled )
	{
		self.s.vortexSphere.FireNow( "Disable" )
		// play powerdown sound and dialog
	}
	else
	{
		self.s.vortexSphere.FireNow( "Enable" )
		// play powerup sound and dialog
	}

	return 0
}


function OnWeaponNpcPrimaryAttack( attackParams )
{
	return 0
}
