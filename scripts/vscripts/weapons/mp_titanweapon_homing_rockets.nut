
const NUM_ROCKETS_PER_SHOT 		= 3
const MISSILE_SPEED 			= 1250
const APPLY_RANDOM_SPREAD 		= true
const LAUNCH_OUT_ANG 			= 17
const LAUNCH_OUT_TIME 			= 0.15
const LAUNCH_IN_LERP_TIME 		= 0.2
const LAUNCH_IN_ANG 			= -12
const LAUNCH_IN_TIME 			= 0.10
const LAUNCH_STRAIGHT_LERP_TIME = 0.1

SmartAmmo_SetMissileSpeed( self, MISSILE_SPEED )
SmartAmmo_SetMissileHomingSpeed( self, 500 )
SmartAmmo_SetUnlockAfterBurst( self, true )
SmartAmmo_SetDisplayKeybinding( self, false )
SmartAmmo_SetExpandContract( self, NUM_ROCKETS_PER_SHOT, APPLY_RANDOM_SPREAD, LAUNCH_OUT_ANG, LAUNCH_OUT_TIME, LAUNCH_IN_LERP_TIME, LAUNCH_IN_ANG, LAUNCH_IN_TIME, LAUNCH_STRAIGHT_LERP_TIME )

function HomingRocketsPrecache()
{
	if ( WeaponIsPrecached( self ) )
		return

	PrecacheParticleSystem( "wpn_mflash_xo_rocket_shoulder_FP" )
	PrecacheParticleSystem( "wpn_mflash_xo_rocket_shoulder" )
}
HomingRocketsPrecache()

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


function OnWeaponDeactivate( deactivateParams )
{
	SmartAmmo_Stop( self )
}

function OnWeaponOwnerChanged( changeParams )
{
	if ( IsClient() )
	{
		local viewPlayer = GetLocalViewPlayer() 
		if ( changeParams.newOwner != null && changeParams.newOwner == viewPlayer )
		{
			SmartAmmo_Start( self )
		}
		else if ( changeParams.oldOwner == viewPlayer )
		{
			SmartAmmo_Stop( self, changeParams.oldOwner )
		}		
	}
	else
	{
		if ( changeParams.newOwner != null )
		{
			SmartAmmo_Start( self )
		}
		else
		{
			SmartAmmo_Stop( self, changeParams.oldOwner )
		}
	}
}

function OnWeaponPrimaryAttack( attackParams )
{
	local owner = self.GetWeaponOwner()
	local returnValue = SmartAmmo_FireWeapon( self, attackParams, damageTypes.ATRocket )
	if ( IsClient() )
	{
		if ( returnValue )
		{
			local origin
			local angles = owner.CameraAngles()
			if ( !( "nextRocketPodToUse" in self.s ) )
				self.s.nextRocketPodToUse <- "rocketPodLeft"

			if ( self.s.nextRocketPodToUse == "rocketPodRight" )
			{
				origin = owner.OffsetPositionFromView( Vector( 0, 0, 0 ), Vector( 25, 30, 15 ) )
				StartParticleEffectOnEntityWithPos( owner, GetParticleSystemIndex( "wpn_mflash_xo_rocket_shoulder_FP" ), FX_PATTACH_EYES_FOLLOW, -1, origin, angles )
			}
			else
			{
				origin = owner.OffsetPositionFromView( Vector( 0, 0, 0 ), Vector( 25, -30, 15 ) )
				StartParticleEffectOnEntityWithPos( owner, GetParticleSystemIndex( "wpn_mflash_xo_rocket_shoulder_FP" ), FX_PATTACH_EYES_FOLLOW, -1, origin, angles )
			}

			if( !self.IsBurstFireInProgress() && owner == GetLocalViewPlayer() )
			{
				local cockpit = owner.GetCockpit()
				if ( cockpit )
				{
					local mainVGUI = cockpit.GetMainVGUI()
					if( mainVGUI )
						cockpit.s.offhandHud[ OFFHAND_RIGHT ].bar.SetBarProgressAndRate( 0.0, 1 / self.GetWeaponModSetting( "burst_fire_delay" )  )
				}
			}
		}
		else
		{
			EmitSoundOnEntity( owner, "titan_dryfire" )
		}
	}
	return returnValue
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
	weapon.EmitWeaponSound( "ShoulderRocket_Homing_Fire" )
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
}

missileMain()