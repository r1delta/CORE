const CLUSTER_SFX_LOOP	= "Weapon_ARL.Projectile"
const AIRBURST_TRIGGER_SFX = "IMC_Mine_Beep"

RegisterSignal( "Airburst" )

const NUM_AIRBURST_EXPLOSIONS	= 10
const AIRBURST_EXPLOSIONS_DELAY = 0.1

function AirburstRocketsPrecache()
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
AirburstRocketsPrecache()

function OnWeaponOffhandFirePressedNotReady( params )
{
	local player = self.GetWeaponOwner()
	if ( "airburstReady" in player.s && player.s.airburstReady == true )
	{
		EmitSoundOnEntity( self.GetWeaponOwner(), AIRBURST_TRIGGER_SFX )

		player.s.airburstReady = false
		self.GetWeaponOwner().Signal( "Airburst" )
	}
}

function OnWeaponPrimaryAttack( attackParams )
{
	self.EmitWeaponSound( "rocket_pod_fire" )

	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	local shouldPredict = self.ShouldPredictProjectiles()
	if ( IsClient() && !shouldPredict )
		return 1

	// Get missile firing information
	local player = self.GetWeaponOwner()
	local rocketPodInfo = GetNextRocketPodFiringInfo( self, attackParams )
	local attackPos = rocketPodInfo.tagPos
	local attackDir = GetVectorFromPositionToCrosshair( player, attackPos )
	local missileSpeed = 1500
	local doPopup = false

	local missile = self.FireWeaponMissile( attackPos, attackDir, missileSpeed, damageTypes.ATRocket, damageTypes.ATRocket, doPopup, shouldPredict )

	if ( missile )
	{
		if ( IsClient() )
		{
			local owner = self.GetWeaponOwner()

			local origin = owner.OffsetPositionFromView( Vector( 0, 0, 0 ), Vector( 25, -25, 15 ) )
			local angles = owner.CameraAngles()

			StartParticleEffectOnEntityWithPos( owner, GetParticleSystemIndex( "wpn_mflash_xo_rocket_shoulder_FP" ), FX_PATTACH_EYES_FOLLOW, -1, origin, angles )
		}

		if ( IsServer() )
		{
			if ( "airburstReady" in player.s )
				player.s.airburstReady = true
			else
				player.s.airburstReady <- true

			thread Airburst( missile, player )
			if ( IsValid( rocketPodInfo.podModel ) )
			{
				local overrideAngle = VectorToAngles( attackDir )
				PlayFXOnEntity( self.GetScriptScope().GetWeaponEffect( "rocket_flash" ), rocketPodInfo.podModel, rocketPodInfo.tagName, null, null, 6, player, overrideAngle )
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

function Airburst( missile, player )
{
	missile.EndSignal( "OnDestroy" )
	player.EndSignal( "Disconnected" )

	OnThreadEnd(
		function() : ( player )
		{
			if( IsValid( player ) )
				Remote.CallFunction_Replay( player, "ServerCallback_AirburstIconUpdate", false )
		}
	)

	Remote.CallFunction_Replay( player, "ServerCallback_AirburstIconUpdate", true )

	WaitSignal( player, "Airburst" )

	if( IsServer() )
	{
		AirburstRocket_Detonate( missile )
	//	CreateNoSpawnArea( missile.GetTeam(), missile.GetOrigin(), ( CLUSTER_ROCKET_BURST_COUNT / 5.0 ) * 0.5 + 1.0, CLUSTER_ROCKET_BURST_RANGE + 100 )
	}
}

function AirburstRocket_Detonate( projectile )
{
	local owner = projectile.GetOwner()
	Assert( IsValid( owner ) )

	local weaponName = "mp_titanweapon_airburst_rockets"
	local innerRadius = GetWeaponInfoFileKeyField_Global( weaponName, "explosion_inner_radius" )
	local outerRadius = GetWeaponInfoFileKeyField_Global( weaponName, "explosionradius" )

	local explosionDamage
	local explosionDamageHeavyArmor

	if ( IsPlayer( owner ) )
	{
		owner.EndSignal( "Disconnected" )
		explosionDamage = GetWeaponInfoFileKeyField_Global( weaponName, "explosion_damage" )
		explosionDamageHeavyArmor = GetWeaponInfoFileKeyField_Global( weaponName, "explosion_damage_heavy_armor" )
	}
	else
	{
		explosionDamage = GetWeaponInfoFileKeyField_Global( weaponName, "npc_explosion_damage" )
		explosionDamageHeavyArmor = GetWeaponInfoFileKeyField_Global( weaponName, "npc_explosion_damage_heavy_armor" )
	}

	for ( local i = 0 ; i < NUM_AIRBURST_EXPLOSIONS ; i++ )
	{
		if ( i > 0 )
			wait AIRBURST_EXPLOSIONS_DELAY
		thread AirburstRocket_Explosion( projectile, explosionDamage, explosionDamageHeavyArmor, innerRadius, outerRadius, owner )
	}

	if ( IsValid( projectile ) )
		projectile.Explode()
}

function AirburstRocket_Explosion( projectile, damage, damageHeavyArmor, innerRadius, outerRadius, owner )
{
	owner.EndSignal( "OnDestroy" )
	projectile.EndSignal( "OnDestroy" )

	if ( !IsValid( projectile ) )
		return

	if ( IsServer() )
	{
		local explosion = CreateClusterExplosion( projectile.GetOrigin(), damage, damageHeavyArmor, innerRadius, outerRadius, owner, eDamageSourceId.mp_titanweapon_airburst_rockets )
		explosion.Fire( "Explode" )
		explosion.Kill( 5 )
	}

	ShotgunBlast( projectile.GetOrigin(), Vector( 0, 0, -1 ), 5, damageTypes.LargeCaliber, 1, 50.0, 512 )
}

/*
function ClusterRocketBurst( origin, damage, damageHeavyArmor, innerRadius, outerRadius, owner = null, selfDamage = true, popcornInfo = null, customFxTable = null )
{
	//titan_sniper_trail

	local counter = 0
	local randVec = null
	local randRangeMod = null
	local popRange = null
	local popVec = null
	local popOri = origin
	local popDelay = null
	local colTrace

	local burstDelay = CLUSTER_ROCKET_DURATION / (numBursts / CLUSTER_ROCKET_BURST_GROUP_SIZE)

	local clusterExplosion = CreateClusterExplosion( origin + (popcornInfo.normal * 8.0), damage, damageHeavyArmor, innerRadius, outerRadius, owner, eDamageSource )
	local clusterBurstEnt = CreateClusterBurst( origin + (popcornInfo.normal * 8.0) )
	local clusterBurstOrigin = origin + (popcornInfo.normal * 8.0)

	while( counter <= numBursts / CLUSTER_ROCKET_BURST_GROUP_SIZE )
	{
		randVec = RandomVecInDome( popcornInfo.normal )
		randRangeMod = ( RandomFloat( 0, 1 ) )
		popRange = popRangeBase * randRangeMod
		popVec = randVec * popRange
		popOri = origin + popVec
		popDelay = popDelayBase + RandomFloat( -popDelayRandRange, popDelayRandRange )

		colTrace = TraceLineSimple( origin, popOri, null )
		if ( TraceLineSimple( origin, popOri, null ) < 1 )
		{
			popVec = popVec * colTrace
			popOri = origin + popVec
		}

		clusterBurstEnt.SetOrigin( clusterBurstOrigin )

		local velocity = GetVelocityForDestOverTime( clusterBurstEnt.GetOrigin(), popOri, burstDelay - popDelay )
		clusterBurstEnt.SetVelocity( velocity )

		clusterBurstOrigin = popOri

		counter++

		wait burstDelay - popDelay

		clusterExplosion.SetOrigin( clusterBurstOrigin )
		clusterExplosion.Fire( "Explode" )
	}

	clusterBurstEnt.Destroy()
	clusterExplosion.Kill( 5 )
}
*/