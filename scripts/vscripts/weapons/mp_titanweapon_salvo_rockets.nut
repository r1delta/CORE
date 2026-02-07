


const MISSILE_SFX_LOOP		= "Weapon_ARL.Projectile"

const NUM_ROCKETS_PER_SHOT 		= 1
const MISSILE_SPEED 			= 1800
const MISSILE_LIFE				= 10
const APPLY_RANDOM_SPREAD 		= true
const LAUNCH_OUT_ANG 			= 7
const LAUNCH_OUT_TIME 			= 0.20
const LAUNCH_IN_LERP_TIME 		= 0.2
const LAUNCH_IN_ANG 			= -10
const LAUNCH_IN_TIME 			= 0.10
const LAUNCH_STRAIGHT_LERP_TIME = 0.1

const DEBUG_DRAW_PATH 			= false

function SalvoRocketsPrecache( weapon )
{
	if ( WeaponIsPrecached( self ) )
		return

	PrecacheParticleSystem( "wpn_mflash_xo_rocket_shoulder_FP" )
	PrecacheParticleSystem( "wpn_mflash_xo_rocket_shoulder" )
}
SalvoRocketsPrecache( self )

function OnWeaponActivate( activateParams )
{
}

function OnWeaponDeactivate( deactivateParams )
{
}

function OnWeaponOwnerChanged( changeParams )
{
}

function OnWeaponPrimaryAttack( attackParams )
{
	local shouldPredict = self.ShouldPredictProjectiles()

	if ( IsClient() && !shouldPredict )
		return 1

	local player = self.GetWeaponOwner()
	local attackPos = attackParams.pos
	local attackDir = attackParams.dir

	self.EmitWeaponSound( "ShoulderRocket_Salvo_Fire" )
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	if ( DoesWeaponHaveRocketPods( self ) )
	{
		local rocketPodInfo = GetNextRocketPodFiringInfo( self, attackParams )
		attackPos = rocketPodInfo.tagPos

		if( IsServer() && IsValid( rocketPodInfo.podModel ) )
		{
			local overrideAngle = VectorToAngles( attackDir )
			PlayFXOnEntity( "wpn_mflash_xo_rocket_shoulder", rocketPodInfo.podModel, rocketPodInfo.tagName, null, null, 6, player, overrideAngle )
		}
	}

	local firedMissiles = FireExpandContractMissiles( self, attackParams, attackPos, attackDir, shouldPredict, NUM_ROCKETS_PER_SHOT, MISSILE_SPEED, LAUNCH_OUT_ANG, LAUNCH_OUT_TIME, LAUNCH_IN_ANG, LAUNCH_IN_TIME, LAUNCH_IN_LERP_TIME, LAUNCH_STRAIGHT_LERP_TIME, APPLY_RANDOM_SPREAD, null, DEBUG_DRAW_PATH )
	foreach( missile in firedMissiles )
	{
		if( IsServer() )
		{
			missile.SetOwner( player )
			EmitSoundOnEntity( missile, MISSILE_SFX_LOOP )
		}
		missile.kv.lifetime = MISSILE_LIFE
		missile.SetTeam( player.GetTeam() )
	}

	return firedMissiles.len()
}

function CooldownBarFracFunc()
{
	printt( "CooldownBarFracFunc" )

	if ( !IsValid( self ) )
		return 0

	printt( "IsBurstFireInProgress:", self.IsBurstFireInProgress() )
	printt( "TimeUntilReadyToFire:", self.TimeUntilReadyToFire() )

	if ( self.IsBurstFireInProgress() )
		return 0

	local frac = self.TimeUntilReadyToFire() / self.GetWeaponInfoFileKeyField( "burst_fire_delay" )
	if ( frac > 1 )
		frac = 1
	return 1 - frac
}





