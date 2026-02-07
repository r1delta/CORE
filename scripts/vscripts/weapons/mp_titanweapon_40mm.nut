PROJECTILE_SPEED <- 8000

//SetWeaponEffect( "shelleject_smoketrail", "wpn_grenade_frag_blue_rope" )  // "wpn_grenade_frag_blue_rope" "wpn_grenade_frag_blue_smoke"

TITAN_40MM_SHELL_EJECT <- "models/Weapons/shellejects/shelleject_40mm.mdl"

const TANK_BUSTER_40MM_SFX_LOOP = "Weapon_Vortex_Gun.ExplosiveWarningBeep"
const TITAN_40MM_EXPLOSION_SOUND = "Weapon.Explosion_Med"
const MORTAR_SHOT_SFX_LOOP	= "Weapon_ARL.Projectile"

AMMO_BODYGROUP_COUNT <- 10

function W40mmPrecache()
{
	if ( WeaponIsPrecached( self ) )
		return

	PrecacheParticleSystem( "wpn_mflash_40mm_smoke_side_FP" )
	PrecacheParticleSystem( "wpn_mflash_40mm_smoke_side" )

	if ( IsServer() )
	{
		PrecacheModel( TITAN_40MM_SHELL_EJECT )

		PrecacheEntity( "crossbow_bolt" )
	}
}
W40mmPrecache()

function OnWeaponActivate( activateParams )
{
	UpdateViewmodelAmmo()
	if (!( "burstFireCount" in self.s ) )
	{
		if ( self.HasMod( "burst" ) )
			self.s.burstFireCount <- self.GetWeaponModSetting("burst_fire_count")
		else
			self.s.burstFireCount <- 0
	}
}

function OnWeaponDeactivate( deactivateParams )
{
}

function OnWeaponPrimaryAttack( attackParams )
{
	Fire40mmSounds( self )
	self.EmitWeaponSound( "40mm_shell" )

	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	return FireWeaponPlayerAndNPC( attackParams, true )
}

function OnWeaponNpcPrimaryAttack( attackParams )
{
	Fire40mmSounds( self )

	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	return FireWeaponPlayerAndNPC( attackParams, false )
}

function FireWeaponPlayerAndNPC( attackParams, playerFired )
{
	local owner = self.GetWeaponOwner()
	local shouldCreateProjectile = false
	if ( IsServer() || self.ShouldPredictProjectiles() )
		shouldCreateProjectile = true
	if ( IsClient() && !playerFired )
		shouldCreateProjectile = false

	if ( shouldCreateProjectile )
	{
		local speed = PROJECTILE_SPEED
		if ( self.HasMod("tank_buster" ) )
		{
			local angularVelocity = Vector( 0, 0, 0 )
			local frag = self.FireWeaponGrenade( attackParams.pos, attackParams.dir * PROJECTILE_SPEED, angularVelocity, 5.0, damageTypes.GibBullet | DF_IMPACT | DF_EXPLOSION | DF_SPECTRE_GIB, DF_EXPLOSION | DF_RAGDOLL | DF_SPECTRE_GIB, playerFired, true, true )
			if ( frag )
			{
				frag.kv.CollideWithOwner = false
				frag.SetTeam( owner.GetTeam() )
				frag.s.explodeOnContact <- false
				frag.s.bounceNormal <- Vector( 0, 0, 0 )
				frag.s.planted <- false
				speed *= 0.8
				local viewVector = owner.GetViewVector()
				frag.SetAngles( VectorToAngles( viewVector ) )
			}
		}
		else
		{
			local hasMortarShotMod = self.HasMod( "mortar_shots" )
			if( hasMortarShotMod )
				speed *= 0.6

			//TODO:: Calculate better attackParams.dir if auto-titan using mortarShots
			local bolt = self.FireWeaponBolt( attackParams.pos, attackParams.dir, speed, damageTypes.GibBullet | DF_IMPACT | DF_EXPLOSION | DF_SPECTRE_GIB, DF_EXPLOSION | DF_RAGDOLL | DF_SPECTRE_GIB, playerFired )
			bolt.kv.bounceFrac = 0.0
			if ( hasMortarShotMod )
			{
				bolt.kv.gravity = 4.0
				bolt.kv.lifetime = 10.0
				if( IsServer() )
					EmitSoundOnEntity( bolt, MORTAR_SHOT_SFX_LOOP )
			}
			else
			{
				bolt.kv.gravity = 0.05
			}
		}
	}

	return 1
}

function Fire40mmSounds( self )
{
	if( "burstFireCount" in self.s && self.s.burstFireCount )
	{
		local remainingShots = self.GetBurstFireShotsPending()
		if ( remainingShots == self.s.burstFireCount )
			PlayWeaponSound_1p3p( "Weapon_40mm_Fire_fp_Burst_First", "Weapon_40mm_Fire_Burst" )
		else if ( remainingShots <= 1 )
			PlayWeaponSound_1p3p( "Weapon_40mm_Fire_fp_Burst_Last", "Weapon_40mm_Fire_Burst" )
		else
			PlayWeaponSound_1p3p( "Weapon_40mm_Fire_fp_Burst_First", "Weapon_40mm_Fire_Burst" )
	}
	else if ( self.HasMod( "mortar_shots" ) )
	{
		PlayWeaponSound_1p3p( "Weapon_40mm_Fire_fp", "Weapon_40mm_Fire" )
	}
	else if ( self.HasMod( "tank_buster" ) )
	{
		PlayWeaponSound_1p3p( "Weapon_40mm_Fire_fp", "Weapon_40mm_Fire" )
	}
	else if ( self.HasMod( "burn_mod_titan_40mm" ) )
	{
		if ( self.GetWeaponOwner().IsNPC() )
		{
			if ( self.GetShotCount() == 0 )
				self.EmitWeaponSound( "Weapon_40mm_Fire_Amped_First_3P" )
			else
				self.EmitWeaponSound( "Weapon_40mm_Fire_Amped_3P" )
		}
		else
		{
			if ( self.GetShotCount() == 0 )
				PlayWeaponSound_1p3p( "Weapon_40mm_Fire_Amped_First", "Weapon_40mm_Fire_Amped_First_3P" )
			else
				PlayWeaponSound_1p3p( "Weapon_40mm_Fire_Amped", "Weapon_40mm_Fire_Amped_3P" )
		}
	}
	else
	{
		if ( self.GetWeaponOwner().IsNPC() )
			self.EmitWeaponSound( "Weapon_40mm_Fire" )
		else
			PlayWeaponSound_1p3p( "Weapon_40mm_Fire_fp", "Weapon_40mm_Fire" )
	}
}

function OnWeaponBulletHit( hitParams )
{
	if ( IsClient() )
		return

	if ( hitParams.hitEnt.IsPlayer() )
	{
		if ( "damagePush" in self.s )
		{
			local direction = hitParams.hitEnt.GetOrigin() - self.GetOrigin()
			direction.Normalize()

			PushEntWithDamage( hitParams.hitEnt, self.s.damagePush, direction )
		}
	}
}

function OnClientAnimEvent( name )
{
	GlobalClientEventHandler( name )

	if ( name == "muzzle_flash" )
	{
		self.PlayWeaponEffect( "wpn_mflash_40mm_smoke_side_FP", "wpn_mflash_40mm_smoke_side", "muzzle_flash_L" )
		self.PlayWeaponEffect( "wpn_mflash_40mm_smoke_side_FP", "wpn_mflash_40mm_smoke_side", "muzzle_flash_R" )
	}

	if ( name == "shell_eject" )
		thread OnShellEjectEvent( name )
}

function OnShellEjectEvent( name )
{
	local weaponEnt = self

	local tag = "shell"
	local anglePlusMinus = 7.5
	local launchVecMultiplier = 250
	local launchVecRandFrac = 0.3
	local angularVelocity = Vector( RandomFloat( -5, -1 ), 0, RandomFloat( -5, 5 ) )
	local gibLifetime = 6.0

	local isFirstPerson = IsLocalViewPlayer( self.GetWeaponOwner() )
	if ( isFirstPerson )
	{
		weaponEnt = self.GetWeaponOwner().GetViewModelEntity()
		if( !IsValid( weaponEnt ) )
			return
		tag = "shell_fp"
		anglePlusMinus = 3
		launchVecMultiplier = 200
	}

	local tagIdx = weaponEnt.LookupAttachment( tag )
	if ( tagIdx <= 0 )
		return	// catch case of weapon firing at same time as eject or death and viewmodel is removed
	local tagOrg = weaponEnt.GetAttachmentOrigin( tagIdx )
	local tagAng = weaponEnt.GetAttachmentAngles( tagIdx )
	tagAng = tagAng.AnglesCompose( Vector( 0, 0, 90 ) )  // the tags have been rotated to be compatible with FX standards

	local tagAngRand = Vector( RandomFloat( tagAng.x - anglePlusMinus, tagAng.x + anglePlusMinus ), RandomFloat( tagAng.y - anglePlusMinus, tagAng.y + anglePlusMinus ), RandomFloat( tagAng.z - anglePlusMinus, tagAng.z + anglePlusMinus ) )
	local launchVec = tagAngRand.AnglesToForward()
	launchVec *= RandomFloat( launchVecMultiplier, launchVecMultiplier + ( launchVecMultiplier * launchVecRandFrac ) )

	local shelleject = CreateClientsideGib( TITAN_40MM_SHELL_EJECT, tagOrg, weaponEnt.GetAngles(), launchVec, angularVelocity, gibLifetime, 1000, 200 )

	/* shell eject smoke trail
	local attachID = shelleject.LookupAttachment( "REF" )
	local fxHandle = StartParticleEffectOnEntity( shelleject, GetParticleSystemIndex( GetWeaponEffect( "shelleject_smoketrail" ) ), FX_PATTACH_POINT_FOLLOW, attachID )
	thread StopFXAfterTime( fxHandle, 0.9 )
	*/
}

/*
function StopFXAfterTime( handle, waittime )
{
	Wait( waittime )

	if ( EffectDoesExist( handle ) )
		EffectStop( handle, false, true )
}
*/

function OnWeaponStartZoomIn()
{
	HandleWeaponSoundZoomIn( self, "Weapon_40mm.ADS_In" )
}

function OnWeaponStartZoomOut()
{
	HandleWeaponSoundZoomOut( self, "Weapon_40mm.ADS_Out" )
}

function OnWeaponOwnerChanged( changeParams )
{
	if ( IsClient() )
	{
		if ( changeParams.newOwner != null && changeParams.newOwner == GetLocalViewPlayer() )
			UpdateViewmodelAmmo()
	}
}