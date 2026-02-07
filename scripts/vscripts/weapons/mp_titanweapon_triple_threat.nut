const FX_TRIPLE_IGNITION = "wpn_grenade_TT_activate"
const FX_TRIPLE_IGNITION_BURN = "wpn_grenade_TT_activate"

const BURN_MAGNETIC_FORCE = 2400

RegisterSignal( "ProxMineTrigger" )

const LAUNCH_VELOCITY = 1100
const MIN_FUSE_TIME = 2.3
const MAX_FUSE_TIME = 2.5
const MIN_ROLLING_ROUNDS_FUSE_TIME = 3.2
const MAX_ROLLING_ROUNDS_FUSE_TIME = 3.7
const MIN_MINE_FUSE_TIME = 8.2
const MAX_MINE_FUSE_TIME = 8.8
const MINE_FIELD_ACTIVATION_TIME = 1.15 //After landing
const MINE_FIELD_TITAN_ONLY = false
const MINE_FIELD_MAX_MINES = 9
const MINE_FIELD_LAUNCH_VELOCITY = 1100
const NUM_SHOTS = 3
const SPREAD_HORIZONTAL	= 5
const SPREAD_VERTICAL = 4
const ANGLE_ADJUSTMENT = 2.5
const PROX_MINE_RANGE = 200
const TRIPLE_THREAT_RUMBLE_TYPE_INDEX = 14
const TRIPLE_THREAT_RUMBLE_CHARGE_MIN = 10
const TRIPLE_THREAT_RUMBLE_CHARGE_MAX = 40

const TRIPLE_THREAT_SIGNAL_CHARGEEND = "TripleThreatChargeEnd"
RegisterSignal( TRIPLE_THREAT_SIGNAL_CHARGEEND )

function W40mmPrecache()
{
	if ( WeaponIsPrecached( self ) )
		return

	PrecacheParticleSystem( FX_TRIPLE_IGNITION )
	PrecacheParticleSystem( FX_TRIPLE_IGNITION_BURN )

	if ( IsServer() )
	{
		PrecacheEntity( "crossbow_bolt" )
		PrecacheEntity( "npc_grenade_frag" )
	}
}
W40mmPrecache()

function OnWeaponChargeBegin( chargeParams )
{
	if( IsClient() )
		thread cl_ChargeRumble( self, TRIPLE_THREAT_RUMBLE_TYPE_INDEX, TRIPLE_THREAT_RUMBLE_CHARGE_MIN, TRIPLE_THREAT_RUMBLE_CHARGE_MAX, TRIPLE_THREAT_SIGNAL_CHARGEEND )
}

function OnWeaponChargeEnd( chargeParams )
{
	self.Signal( TRIPLE_THREAT_SIGNAL_CHARGEEND )
}


function OnWeaponPrimaryAttack( attackParams )
{
	return FireTripleThreat( attackParams, PROJECTILE_PREDICTED )
}

function OnWeaponNpcPrimaryAttack( attackParams )
{
	return FireTripleThreat( attackParams, PROJECTILE_NOT_PREDICTED )
}

function FireTripleThreat( attackParams, predicted )
{
	local weaponOwner = self.GetWeaponOwner()
	local bossPlayer = weaponOwner
	local hasRollingRoundsMod = self.HasMod( "rolling_rounds" )
	local hasMineFieldMod = self.HasMod( "mine_field" )
	local hasBurnMod = self.HasMod( "burn_mod_titan_triple_threat" )

	if ( weaponOwner.IsNPC() )
		bossPlayer = weaponOwner.GetTitanSoul().GetBossPlayer()

	if ( weaponOwner.IsPlayer() )
		self.EmitWeaponSound( "Weapon_titantriplethreat.Fire" )
	else
		self.EmitWeaponSound( "Weapon_titantriplethreat.Fire" )
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )


	local numShots = min( self.GetWeaponPrimaryClipCount(), NUM_SHOTS )

	if ( IsServer() || self.ShouldPredictProjectiles() )
	{
		local attackOffsets
		local attackVelocities
		local attackPos
		local angleAdjustment = ANGLE_ADJUSTMENT
		local velocity = LAUNCH_VELOCITY
		if( hasMineFieldMod )
			velocity = MINE_FIELD_LAUNCH_VELOCITY

		if ( self.IsWeaponAdsButtonPressed() )
		{
			attackOffsets = [
				Vector( -2, RandomFloat( -0.15, 0.15 ), 0 )
				Vector( -4, RandomFloat( -0.15, 0.15 ), 0 ),
				Vector( -7, RandomFloat( -0.15, 0.15 ), 0 ),
			]

			attackVelocities = [
				velocity,
				velocity * 1.4,
				velocity * 1.8
			]
		}
		else
		{
			attackOffsets = [
				Vector( RandomFloat( 0.5, 0.75 ), 0, 0 ),
				Vector( RandomFloat( 0.5, 0.75 ), 3, 0 ),
				Vector( RandomFloat( 0.5, 0.75 ), -3, 0 ),
			]

			attackVelocities = [
				velocity,
				velocity,
				velocity
			]
		}
		Assert( numShots <= attackOffsets.len() )

		for( local i = 0; i < numShots; i++ )
		{
			local attackAngles = attackParams.dir.GetAngles()
			if ( !self.IsWeaponAdsButtonPressed() )
			{
				attackAngles.x -= 5
				if ( self.HasMod( "spread_increase_ttt" ) )
					angleAdjustment *= 1.5
				else if ( self.HasMod( "spread_decrease_ttt" ) )
					angleAdjustment *= 0.5

				if ( i % 2 != 0 )
				{
					attackAngles.y = attackAngles.y + angleAdjustment
				}
				else if ( i > 0 && i % 2 == 0 )
				{
					attackAngles.y = attackAngles.y - angleAdjustment
					angleAdjustment *= 2
				}
			}
			local fuseTime

			if( hasMineFieldMod )
			{
				fuseTime = RandomFloat( MIN_MINE_FUSE_TIME, MAX_MINE_FUSE_TIME )
				if( IsServer() )
				{
					if ( IsValid( bossPlayer ) )
					{
						ArrayRemoveInvalid( bossPlayer.s.activeTripleThreatMines )
						if ( bossPlayer.s.activeTripleThreatMines.len() > ( MINE_FIELD_MAX_MINES - 1 ) )
						{
							local oldestMine = bossPlayer.s.activeTripleThreatMines[ 0 ]  // since it's an array, the first one will be the oldest
							CleanupPlayerTripleThreatMine( bossPlayer, oldestMine )
						}
					}
				}
			}
			else if( hasRollingRoundsMod )
				fuseTime = RandomFloat( MIN_ROLLING_ROUNDS_FUSE_TIME, MAX_ROLLING_ROUNDS_FUSE_TIME )
			else
				fuseTime = RandomFloat( MIN_FUSE_TIME, MAX_FUSE_TIME )

			local attackVec
			if ( self.HasMod( "hydraulic_launcher" ) )
				attackVec = (attackAngles + attackOffsets[i]).AnglesToForward() * ( attackVelocities[i] + self.GetWeaponChargeFraction() * attackVelocities[i] )
			else
				attackVec = (attackAngles + attackOffsets[i]).AnglesToForward() * attackVelocities[i]


			local angularVelocity = Vector( RandomFloat( -velocity, velocity ), 100, 0 )
			local damageType = damageTypes.Explosive
			if ( self.HasMod( "arc_triple_threat" ) )
				damageType = damageType | damageTypes.Electric
			local nade = self.FireWeaponGrenade( attackParams.pos, attackVec, angularVelocity, fuseTime, damageType, damageType, predicted, true, true )
			//DebugDrawLine( attackPos, attackPos + ( attackVec * 1000 ), 255, 0, 0, true, 10.0 )

			if ( nade )
			{
				nade.kv.CollideWithOwner = false
				if( hasMineFieldMod )
					nade.s.becomeProxMine <- true

				if( IsServer() )
				{
					nade.SetOwner( weaponOwner )
					Grenade_Init( nade, self )
					thread EnableCollision( nade )
					thread AirPop( nade, fuseTime )
					if( hasMineFieldMod )
					{
						nade.s.onlyAllowSmartPistolDamage = false //Update in the future to use two different variable names. TakeTrapDamage and OnlyAllowSmartPistolDamage.
						thread TrapExplodeOnDamage( nade, 500, 0.0, 0.1 )
						if ( IsValid( bossPlayer ) )
							PlayerTrackTripleThreatMine( bossPlayer, nade )
					}
					else
					{
						thread TrapExplodeOnDamage( nade, 50, 0.0, 0.1 )
					}
					if( hasRollingRoundsMod )
						nade.s.rollingRound <- true
					if( self.HasMod( "impact_fuse" ) )
						nade.s.impactFuse <- true
					if( hasBurnMod )
					{
						nade.s.hasBurnMod <- true
						EmitSoundOnEntity( nade, "Weapon_R1_MGL_Grenade_Emitter" )
					}
				}
				else
				{
					nade.SetTeam( weaponOwner.GetTeam() )
				}

				if( hasBurnMod )
					nade.InitMagnetic( MGL_MAGNETIC_FORCE, "Explo_TripleThreat_MagneticAttract" )
				nade.SetModel( GRENADE_MODEL_LARGE )
			}
		}
	}

	return numShots
}

function EnableCollision( grenade )
{
	grenade.EndSignal("OnDestroy")

	wait 1.0
	grenade.kv.CollideWithOwner = true
}

function AirPop( grenade, fuseTime )
{
	grenade.EndSignal( "OnDestroy" )

	local popDelay = RandomFloat( 0.2, 0.3 )

	WaitSignalTimeout( grenade, (fuseTime - (popDelay + 0.2)), "ProxMineTrigger" )

	if( "hasBurnMod" in grenade.s && grenade.s.hasBurnMod )
		PlayLoopFXOnEntity( FX_TRIPLE_IGNITION_BURN, grenade )
	else
		PlayLoopFXOnEntity( FX_TRIPLE_IGNITION, grenade )
	EmitSoundOnEntity( grenade, "Triple_Threat_Grenade_Charge" )

	local popSpeed = RandomFloat( 25, 40 )
	local popVelocity = Vector ( 0, 0, popSpeed )
	local normal = Vector( 0, 0, 1 )
	if( "becomeProxMine" in grenade.s && grenade.s.becomeProxMine == true )
	{
		//grenade.ClearParent()
		if( "collisionNormal" in grenade.s )
		{
			normal = grenade.s.collisionNormal
			popVelocity = grenade.s.collisionNormal * popSpeed
		}
	}

	local newPosition = grenade.GetOrigin() + popVelocity
	grenade.SetVelocity( GetVelocityForDestOverTime( grenade.GetOrigin(), newPosition, popDelay ) )

	wait popDelay
	TripleThreat_Explode( grenade, null )
}

function OnWeaponStartZoomIn()
{
	HandleWeaponSoundZoomIn( self, "Weapon_Triple_Threat.ALT_On" )
}

function OnWeaponStartZoomOut()
{
	HandleWeaponSoundZoomOut( self, "Weapon_Triple_Threat.ALT_Off" )
}

function TripleThreat_Explode( grenade, collisionEnt = null)
{
	local normal = Vector( 0, 0, 1 )
	if( "collisionNormal" in grenade.s )
		normal = grenade.s.collisionNormal
	grenade.Explode( normal )
}