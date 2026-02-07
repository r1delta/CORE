
const DRAW_DEBUG = 0
const DEBUG_FAIL = 0
const MERGEDEBUG = 0
const DEBUG_TIME = 5
const MIN_HEIGHT = 70
const POINT_FROM = 0
const POINT_TO = 1
const POINT_NEXT = 2
const POINT_FUTURE = 3
const TRACE_DIST_PER_SECTION = 800
const WALL_BUFFER = 74
const STEEPNESS_DOT = 0.6
const MISSILE_LOOKAHEAD = 150 // 150
const MATCHSLOPERISE = 40 // 32
const MISSILE_LIFETIME = 8.0
const FUDGEPOINT_RIGHT = 100
const FUDGEPOINT_UP = 150
const PROX_MISSILE_RANGE = 160

const BURN_CLUSTER_EXPLOSION_INNER_RADIUS = 150
const BURN_CLUSTER_EXPLOSION_RADIUS = 220
const BURN_CLUSTER_EXPLOSION_DAMAGE = 66
const BURN_CLUSTER_EXPLOSION_DAMAGE_HEAVY_ARMOR = 100
const BURN_CLUSTER_NPC_EXPLOSION_DAMAGE = 66
const BURN_CLUSTER_NPC_EXPLOSION_DAMAGE_HEAVY_ARMOR = 100

RegisterSignal( "FiredWeapon" )

guidedLaserPoint <- null
missileSpeed <- 2300

function RocketLauncherPrecache()
{
	if ( WeaponIsPrecached( self ) )
		return

	PrecacheParticleSystem( "wpn_muzzleflash_xo_rocket_FP" )
	PrecacheParticleSystem( "wpn_muzzleflash_xo_rocket" )
	PrecacheParticleSystem( "wpn_muzzleflash_xo_fp" )
	PrecacheParticleSystem( "P_muzzleflash_xo_mortar" )

}
RocketLauncherPrecache()

function OnWeaponActivate( activateParams )
{

}

function OnClientAnimEvent( name )
{
	if ( name == "muzzle_flash" )
	{
		if ( self.HasMod( "coop_mortar_titan" ) )
			self.PlayWeaponEffect( "wpn_muzzleflash_xo_fp", "P_muzzleflash_xo_mortar", "muzzle_flash" )
		else if ( self.HasMod( "rapid_fire_missiles" ) )
			self.PlayWeaponEffect( "wpn_muzzleflash_xo_fp", "wpn_muzzleflash_xo_rocket", "muzzle_flash" )
		else
			self.PlayWeaponEffect( "wpn_muzzleflash_xo_rocket_FP", "wpn_muzzleflash_xo_rocket", "muzzle_flash" )
	}
}

function WeaponRegenAmmoPrototype( weapon )
{
	weapon.EndSignal( "OnDestroy" )

	for ( ;; )
	{
		waitthread RegenIfNotFired( weapon )
	}
}

function RegenIfNotFired( weapon )
{
	weapon.EndSignal( "FiredWeapon" )

	wait 1

	local ammo = weapon.GetWeaponPrimaryClipCount()
	if ( ammo < weapon.s.maxAmmo )
		weapon.SetWeaponPrimaryClipCount( ammo + 1 )
}


function OnWeaponPrimaryAttack( attackParams )
{
	local numMissiles = 4

	//Checking if the weapon has 1 ammo when the mod requires 2 and playing a failure sound.
	local weaponOwner = self.GetWeaponOwner()
	local hasRapidFireMissilesMod = self.HasMod( "rapid_fire_missiles" )
	local hasAfterburnersMod = self.HasMod( "afterburners" )
	local hasBurnMod = self.HasMod( "burn_mod_titan_rocket_launcher" )
	local isADSPressed = self.IsWeaponAdsButtonPressed()
	if ( hasRapidFireMissilesMod )
	{
		self.EmitWeaponSound( "Weapon_Titan_Rocket_Launcher.RapidFire" )
	}
	else if( hasAfterburnersMod )
	{
		if ( isADSPressed )
		{
			if ( weaponOwner.GetActiveWeaponPrimaryAmmoLoaded() == 1  )
				numMissiles = 2
		}
		self.EmitWeaponSound( "Weapon_Titan_Rocket_Launcher.AfterburnFire" )
	}
	else if ( hasBurnMod )
	{
		if ( isADSPressed )
			self.EmitWeaponSound( "Weapon_Titan_Rocket_Launcher_Amped_AltFire" )
		else
			self.EmitWeaponSound( "Weapon_Titan_Rocket_Launcher_Amped_Fire" )
	}
	else
	{
		if ( isADSPressed )
			self.EmitWeaponSound( "Weapon_Titan_Rocket_Launcher.AfterburnFire" )
		else
			self.EmitWeaponSound( "Weapon_Titan_Rocket_Launcher.Fire" )
	}

	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	if ( IsClient() && !self.ShouldPredictProjectiles() )
		return 1

	if ( hasRapidFireMissilesMod )
	{
		FireMissile( attackParams, PROJECTILE_PREDICTED )
	}
	else
	{
		if( hasBurnMod )
			numMissiles = 2
		FireSpiralMissiles( attackParams, PROJECTILE_PREDICTED, numMissiles )
		if( self.IsWeaponAdsButtonPressed() && hasAfterburnersMod )
			return 2
	}

	return 1

}

function OnWeaponNpcPrimaryAttack( attackParams )
{
	local fireSound
	if ( self.HasMod( "coop_mortar_titan" ) )
		fireSound = "Weapon_TitanMortar_Fire"
	else
		fireSound = "Weapon_Titan_Rocket_Launcher.Fire"

	self.EmitWeaponSound( fireSound )
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	if ( IsClient() && !self.ShouldPredictProjectiles() )
		return 1

	local numMissiles = 4
	if ( self.HasMod( "burn_mod_titan_rocket_launcher" ) )
		numMissiles = 2

	if ( self.HasMod( "rapid_fire_missiles" ) )
		FireMissile( attackParams, PROJECTILE_NOT_PREDICTED )
	else
		FireSpiralMissiles( attackParams, PROJECTILE_NOT_PREDICTED, numMissiles )
}

function FireMissile( attackParams, predicted )
{
	attackParams.pos = attackParams.pos + Vector( 0, 0, -20 )
	local weaponOwner = self.GetWeaponOwner()
	local up = weaponOwner.GetUpVector()
	local right = weaponOwner.GetRightVector()
	local launchPositionOffsets = [	( up * 10 + right * 10 ),( up * 10 + right * -10 ),( up * -10 + right * -10 ),( up * -10 + right * 10 ) ]
	local launchPosition = attackParams.pos + launchPositionOffsets[ weaponOwner.GetActiveWeaponPrimaryAmmoLoaded() % 4 ]
	local launchDirection = ApplyVectorSpread( attackParams.dir, weaponOwner.GetAttackSpreadAngle() )

	local missile = self.FireWeaponMissile( launchPosition, launchDirection, missileSpeed, damageTypes.Explosive | DF_IMPACT, damageTypes.Explosive, false, predicted )

	if ( missile )
	{
		missile.SetTeam( weaponOwner.GetTeam() )
		missile.s.startDir <- launchDirection
		missile.s.speed <- missileSpeed
		missile.s.startPos <- launchPosition
		if( IsServer() )
		{
			local whizBySound
			if ( self.HasMod( "coop_mortar_titan" ) )
				whizBySound = "Weapon_TitanMortar_Projectile"
			else
				whizBySound = "Weapon_ARL.Projectile"
			EmitSoundOnEntity( missile, whizBySound )

			if ( "missileFiredCallback" in self.s )
			{
				local callbackInfo = self.s.missileFiredCallback
				callbackInfo.func.acall( [callbackInfo.scope, missile, weaponOwner] )
	        }
		}
	}
}

function FireSpiralMissiles( attackParams, predicted, numMissiles = 4 )
{
	attackParams.pos = attackParams.pos + Vector( 0, 0, -20 )
	local missiles = []

	local adsPressed = self.IsWeaponAdsButtonPressed()
	local afterBurn = self.HasMod( "afterburners" )
	if ( afterBurn )
		adsPressed = !adsPressed

	for ( local i = 0; i < numMissiles; i++ )
	{
		local missile = self.FireWeaponMissile( attackParams.pos, attackParams.dir, missileSpeed, damageTypes.Explosive | DF_IMPACT, damageTypes.Explosive, false, predicted )
		if ( self.HasMod( "burn_mod_titan_rocket_launcher" ) )
			InitBurnMissile ( missile )
		missile.kv.lifetime = MISSILE_LIFETIME
		//missile.s.missileSpeed <- missileSpeed
		missile.SetTeam( self.GetWeaponOwner().GetTeam() )
		//SpiralMissileSetup( missile, attackParams, i )
		missile.SetSpeed( missileSpeed );
		//Spreading out the missiles
		local missileNumber = FindIdealMissileConfiguration( numMissiles, i )
		missile.InitMissileSpiral( attackParams.pos, attackParams.dir, missileNumber, adsPressed, afterBurn )

		if ( missile )
		{
			missiles.append( missile )
			missile.s.launchTime <- Time()
			missile.s.spiralMissiles <- missiles
			if ( self.HasMod( "mini_clusters" ) )
				InitBurnMissile ( missile )
			missile.kv.lifetime = MISSILE_LIFETIME
			//missile.s.missileSpeed <- missileSpeed
			missile.SetTeam( self.GetWeaponOwner().GetTeam() )
			//SpiralMissileSetup( missile, attackParams, i )
			missile.SetSpeed( missileSpeed );
			missile.InitMissileSpiral( attackParams.pos, attackParams.dir, i, adsPressed, afterBurn )

			if( IsServer() )
			{
				if ( adsPressed )
					EmitSoundOnEntity( missile, "Weapon_ARL.Projectile" )
				else
					EmitSoundOnEntity( missile, "Weapon_ARL.Projectile" )
			}
		}
	}
}

function FindIdealMissileConfiguration( numMissiles, i )
{
	//We're locked into 4 missiles from passing in 0-3, and in the case of 2 we want to fire the horizontal missiles for aesthetic reasons.
	local idealMissile
	if ( numMissiles == 2 )
	{
		if ( i == 0 )
			idealMissile = 1
		else
			idealMissile = 3
	}
	else
	{
		idealMissile = i
	}

	return idealMissile
}

function InitBurnMissile( missile )
{
	missile.s.innerRadius 					<- BURN_CLUSTER_EXPLOSION_INNER_RADIUS
	missile.s.outerRadius 					<- BURN_CLUSTER_EXPLOSION_RADIUS
	missile.s.explosionDamage 				<- BURN_CLUSTER_EXPLOSION_DAMAGE
	missile.s.explosionDamageHeavyArmor 	<- BURN_CLUSTER_EXPLOSION_DAMAGE_HEAVY_ARMOR
	missile.s.npcExplosionDamage 			<- BURN_CLUSTER_NPC_EXPLOSION_DAMAGE
	missile.s.npcExplosionDamageHeavyArmor 	<- BURN_CLUSTER_NPC_EXPLOSION_DAMAGE_HEAVY_ARMOR
	missile.s.initializedClusterExplosions	<- true
}
/*
function SpiralMissileSetup( missile, attackParams, missileIndex )
{
	local angles = VectorToAngles( attackParams.dir )
	local up = angles.AnglesToUp()
	local right = angles.AnglesToRight()

	missile.s.startPos <- attackParams.pos
	missile.s.startDir <- attackParams.dir
	missile.s.up <- up
	missile.s.right <- right
	missile.s.index <- missileIndex

	if ( self.IsWeaponAdsButtonPressed() )
	{
		missile.s.timescale <- 1
		missile.s.adsPressed <- true
		missile.s.afterburn <- true
	}
	else
	{
		missile.s.timescale <- RandomFloat( 0.9, 1.0 )
		missile.s.adsPressed <- false
	}
}
*/

function OnWeaponOwnerChanged( changeParams )
{
	if ( IsServer() )
	{
		//We're using the mortar mod to switch the impact table of the weapon. However, when players pick it up it's a normal rapid fire quad rocket, so we need to remove it.
		if( ShouldRemoveMortarMod( changeParams.newOwner ) )
			self.SetMods( ["rapid_fire_missiles"] )

		if ( "missileFiredCallback" in self.s )
			delete self.s.missileFiredCallback
	}
}

function ShouldRemoveMortarMod( newOwner )
{
	if ( !IsValid( newOwner ) )
		return false

	if ( !newOwner.IsPlayer() )
		return false

	if ( self.HasMod( "coop_mortar_titan" ) )
		return true

	return false
}

function OnWeaponDeactivate( deactivateParams )
{
	self.Signal("StopGuidedLaser")
}

function OnWeaponStartZoomIn()
{
	HandleWeaponSoundZoomIn( self, "Weapon_Titan_Rocket_Launcher.ADS_In" )
}

function OnWeaponStartZoomOut()
{
	HandleWeaponSoundZoomOut( self, "Weapon_Titan_Rocket_Launcher.ADS_Out" )
}

function ProximityTrigger( missile )
{
	if ( IsClient() )
		return

	missile.EndSignal( "OnDestroy" )
	local rangeCheck = PROX_MISSILE_RANGE
	local team = missile.GetTeam()
	local origin
	while( 1 )
	{
		origin = missile.GetOrigin()
		local entityArray = ArrayWithinCenter( GetProximityTargets(), origin, rangeCheck )
		foreach( ent in entityArray )
		{
			if ( ent.GetTeam() == team )
				continue

			if( !IsAlive( ent ) )
				continue

			foreach ( otherMissile in missile.s.spiralMissiles )
			{
				if ( IsValid( otherMissile ) && otherMissile != missile )
				{
					otherMissile.s.spiralMissiles = []
					otherMissile.Explode()
				}
			}
			missile.Explode()
		}

		wait 0
	}
}
