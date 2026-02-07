

const NUM_ROCKETS_PER_SHOT 		= 1
const MISSILE_SPEED 			= 1200
const APPLY_RANDOM_SPREAD 		= true
const LAUNCH_OUT_ANG 			= 15
const LAUNCH_OUT_TIME 			= 0.20
const LAUNCH_IN_LERP_TIME 		= 0.2
const LAUNCH_IN_ANG 			= -10
const LAUNCH_IN_TIME 			= 0.10
const LAUNCH_STRAIGHT_LERP_TIME = 0.1

SmartAmmo_SetMissileSpeed( self, MISSILE_SPEED )
SmartAmmo_SetMissileHomingSpeed( self, 500 )
SmartAmmo_SetUnlockAfterBurst( self, true )
SmartAmmo_SetExpandContract( self, NUM_ROCKETS_PER_SHOT, APPLY_RANDOM_SPREAD, LAUNCH_OUT_ANG, LAUNCH_OUT_TIME, LAUNCH_IN_LERP_TIME, LAUNCH_IN_ANG, LAUNCH_IN_TIME, LAUNCH_STRAIGHT_LERP_TIME )

function ShoulderRocketsPrecache()
{
	if ( WeaponIsPrecached( self ) )
		return

	PrecacheParticleSystem( "wpn_mflash_xo_rocket_shoulder_FP" )
	PrecacheParticleSystem( "wpn_mflash_xo_rocket_shoulder" )
}
ShoulderRocketsPrecache()

function missileMain()
{
	self.s.missileThinkThread <- Bind( MissileThink )
	self.s.rocket_flash <- "wpn_mflash_xo_rocket_shoulder" // used in SmartAmmo_FireWeapon()
}

function MissileThink( weapon, missile )
{
	if ( !IsServer() )
		return

	missile.EndSignal( "OnDestroy" )

	while ( IsValid( missile ) )
	{
		local target = missile.GetTarget()

		if ( IsValid( target ) && target.IsPlayer() )
		{
			if ( target.IsDodging() && Distance( missile.GetOrigin(), target.GetOrigin() ) < 1024.0 )
			{
				local homingSpeed = missile.GetHomingSpeed()
				local homingSpeedAtDodging = missile.GetHomingSpeedAtDodgingPlayer()
				missile.SetHomingSpeeds( homingSpeedAtDodging, homingSpeedAtDodging )
			}
		}

		wait 0
	}
}

function PanzerStart()
{
	SmartAmmo_Start( self )
}

function PanzerEnd()
{
	SmartAmmo_Stop( self )
}

function OnWeaponActivate( activateParams )
{
	//PanzerStart()
}

function OnWeaponDeactivate( deactivateParams )
{
	PanzerEnd()
}

function OnWeaponOwnerChanged( changeParams )
{
	if ( IsClient() )
	{
		if ( changeParams.newOwner == null && changeParams.oldOwner == GetLocalViewPlayer() )
			SmartAmmo_Stop( self, changeParams.oldOwner )			
	}
	else
	{
		if ( changeParams.newOwner == null )
			SmartAmmo_Stop( self, changeParams.oldOwner )		
	}
}

function OnWeaponPrimaryAttack( attackParams )
{
	local owner = self.GetWeaponOwner()
	local smartAmmoFired = SmartAmmo_FireWeapon( self, attackParams, damageTypes.ATRocket )

	if ( smartAmmoFired )
	{
		local maxTargetedBurst = self.GetWeaponModSetting( "smart_ammo_max_targeted_burst" )
		local shotFrac = 1 / maxTargetedBurst.tofloat()
		self.SetWeaponChargeFractionForced( self.GetWeaponChargeFraction() + shotFrac )
	}

	if ( IsClient() && smartAmmoFired )
	{
		local origin
		local angles = owner.CameraAngles()
		origin = owner.OffsetPositionFromView( Vector( 0, 0, 0 ), Vector( 25, -30, 15 ) )
		StartParticleEffectOnEntityWithPos( owner, GetParticleSystemIndex( "wpn_mflash_xo_rocket_shoulder_FP" ), FX_PATTACH_EYES_FOLLOW, -1, origin, angles )
	}

	if ( self.GetBurstFireShotsPending() <= 1 )
		PanzerEnd()

	if ( smartAmmoFired )
		return 1
	else
		return -1
}

function OnWeaponChargeBegin( chargeParams )
{
	PanzerStart()
}


function OnWeaponChargeEnd( chargeParams )
{
}

function CooldownBarFracFunc()
{
	if ( !IsValid( self ) )
		return 0

	if ( self.IsBurstFireInProgress() )
		return 0

	local frac = self.TimeUntilReadyToFire() / self.GetWeaponInfoFileKeyField( "burst_fire_delay" )
	if ( frac > 1 )
		frac = 1
	return 1 - frac
}

function SmartWeaponFireSound( weapon, target )
{
	weapon.EmitWeaponSound( "ShoulderRocket_Paint_Fire" )
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
}

missileMain()