const CLUSTER_SFX_LOOP	= "Weapon_ARL.Projectile"

function DumbfireRocketsPrecache()
{
	if ( WeaponIsPrecached( self ) )
		return

	PrecacheParticleSystem( "wpn_mflash_xo_rocket_shoulder_FP" )
	PrecacheParticleSystem( "wpn_mflash_xo_rocket_shoulder" )

	if ( IsServer() )
	{
		PrecacheImpactEffectTable( CLUSTER_ROCKET_FX_TABLE )
	}
}
DumbfireRocketsPrecache()

function OnWeaponPrimaryAttack( attackParams )
{
	self.EmitWeaponSound( "rocket_pod_fire" )

	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	local shouldPredict = self.ShouldPredictProjectiles()
	if ( IsClient() && !shouldPredict )
		return 1

	// Get missile firing information
	local owner = self.GetWeaponOwner()
	local rocketPodInfo = GetNextRocketPodFiringInfo( self, attackParams )
	local attackPos = rocketPodInfo.tagPos
	local attackDir
	
	if ( owner.IsPlayer() )
		attackDir = GetVectorFromPositionToCrosshair( owner, attackPos )
	else
		attackDir = attackParams.dir

	local missileSpeed = 2500

	local doPopup = false

	local missile = self.FireWeaponMissile( attackPos, attackDir, missileSpeed, damageTypes.ATRocket, damageTypes.ATRocket, doPopup, shouldPredict )

	if ( missile )
	{
		missile.InitMissileForRandomDriftFromWeaponSettings( attackParams.pos, attackParams.dir )
		InitDumbfireRocket( missile, self )

		//InitMissileForRandomDrift( missile, attackParams.pos, attackParams.dir )

		if ( IsClient() )
		{
			local owner = self.GetWeaponOwner()

			local origin = owner.OffsetPositionFromView( Vector( 0, 0, 0 ), Vector( 25, -25, 15 ) )
			local angles = owner.CameraAngles()

			StartParticleEffectOnEntityWithPos( owner, GetParticleSystemIndex( "wpn_mflash_xo_rocket_shoulder_FP" ), FX_PATTACH_EYES_FOLLOW, -1, origin, angles )
		}

		if ( IsServer() )
		{
			if ( IsValid( rocketPodInfo.podModel ) )
			{
				local overrideAngle = VectorToAngles( attackDir )
				PlayFXOnEntity( "wpn_mflash_xo_rocket_shoulder", rocketPodInfo.podModel, rocketPodInfo.tagName, null, null, 6, owner, overrideAngle )
				EmitSoundOnEntity( missile, CLUSTER_SFX_LOOP )
			}
		}
	}

	return 1
}

function CooldownBarFracFunc()
{
	if ( !IsValid( self ) )
		return 0

	if ( self.IsBurstFireInProgress() )
		return 0

	local frac = self.TimeUntilReadyToFire() * CLUSTER_ROCKET_BASE_FIRERATE
	if ( frac > 1 )
		frac = 1
	return 1 - frac
}

function InitDumbfireRocket( missile, weapon )
{
	missile.s.innerRadius 					<- self.GetWeaponModSetting( "explosion_inner_radius" )
	missile.s.outerRadius 					<- self.GetWeaponModSetting( "explosionradius" )
	missile.s.explosionDamage 				<- self.GetWeaponModSetting( "explosion_damage" )
	missile.s.explosionDamageHeavyArmor 	<- self.GetWeaponModSetting( "explosion_damage_heavy_armor" )
	missile.s.npcExplosionDamage 			<- self.GetWeaponModSetting( "npc_explosion_damage" )
	missile.s.npcExplosionDamageHeavyArmor 	<- self.GetWeaponModSetting( "npc_explosion_damage_heavy_armor" )
	missile.s.initializedClusterExplosions		<- true
	if ( weapon.HasMod( "burn_mod_titan_dumbfire_rockets" ) )
		missile.s.burnMod <- true
}