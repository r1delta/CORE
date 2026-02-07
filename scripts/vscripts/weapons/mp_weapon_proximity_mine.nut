const MAX_PROXIMITY_MINES_IN_WORLD = 3  // if more than this are thrown, the oldest one gets cleaned up
const THROW_POWER = 620
const ATTACH_SFX = "Weapon_ProximityMine_Land"
const WARNING_SFX = "Weapon_ProximityMine_ArmedBeep"

function ProximityMinePrecache()
{
	if ( WeaponIsPrecached( self ) )
		return

	PrecacheParticleSystem( "wpn_laser_blink" )

	if ( IsServer() )
	{
		PrecacheEntity( "npc_grenade_frag" )
	}
}
ProximityMinePrecache()

function OnWeaponActivate( activateParams )
{
}

function OnWeaponDeactivate( deactivateParams )
{
}

function OnWeaponTossReleaseAnimEvent( attackParams )
{
	if ( IsClient() && !self.ShouldPredictProjectiles() )
		return

	local player = self.GetWeaponOwner()

	local attackPos
	if ( IsValid( player ) )
		attackPos = GetProximityMineThrowStartPos( player, attackParams.pos )
	else
		attackPos = attackParams.pos

	local velocity = GetProximityMineThrowVelocity( player, attackParams.dir.GetAngles() )
	local angularVelocity = Vector( 600, RandomFloat( -300, 300 ), 0 )

	local fuseTime = 0	// infinite

	if( IsServer() )
	{
		// If already at the proximity mine in world limit, remove the oldest
		ArrayRemoveInvalid( player.s.activeProximityMines )
		if ( player.s.activeProximityMines.len() > MAX_PROXIMITY_MINES_IN_WORLD )
		{
			local oldestProximityMine = player.s.activeProximityMines[ 0 ]  // since it's an array, the first one will be the oldest
			CleanupPlayerProximityMine( player, oldestProximityMine )
		}
	}

	local proximityMine = self.FireWeaponGrenade( attackPos, velocity, angularVelocity, fuseTime, damageTypes.Explosive, damageTypes.Explosive, PROJECTILE_PREDICTED, true, true )

	if ( proximityMine )
	{
		if ( IsServer() )
		{
			EmitSoundOnEntityExceptToPlayer( player, player, "weapon_proximitymine_throw" )
			Grenade_Init( proximityMine, self )
			ProximityCharge_PostFired_Init( proximityMine, player )
			thread ProximityMineThink( proximityMine, player )
		}
	}
	return 1
}

function GetProximityMineThrowStartPos( player, baseStartPos )
{
	local attackPos = player.OffsetPositionFromView( baseStartPos, Vector( 15.0, 0.0, 0.0 ) )	// forward, right, up
	return attackPos
}

function GetProximityMineThrowVelocity( player, baseAngles )
{
	baseAngles += Vector( -10, 0, 0 )
	local forward = baseAngles.AnglesToForward()
	local velocity = forward * THROW_POWER

	return velocity
}

function OnProjectileCollision( collisionParams )
{
	local bounceDot = 1.0  // sets the dot of the normals it'll stick to
	local result = PlantStickyEntity( self, collisionParams, bounceDot, Vector( 90, 0, 0 ), false, Vector( 0, 0, -3.9 ) )

	if ( IsServer() )
	{
		local player = self.GetOwner()

		if ( !IsValid( player ) )
		{
			self.Kill()
			return
		}

		EmitSoundOnEntity( self, ATTACH_SFX )

		thread EnableTrapWarningSound( self, PROXIMITY_MINE_ARMING_DELAY, WARNING_SFX )

		// if player is rodeoing a Titan and we stickied the mine onto the Titan, set lastAttackTime accordingly
		if ( result )
		{
			local entAttachedTo = self.GetParent()
			if ( !IsValid( entAttachedTo ) )
				return

			if ( !player.IsPlayer() ) //If an NPC Titan has vortexed a prox mine  and fires it back out, then it won't be a player that is the owner of this satchel
				return

			local titanSoulRodeoed = player.GetTitanSoulBeingRodeoed()
			if ( !IsValid( titanSoulRodeoed ) )
				return

			local titan = titanSoulRodeoed.GetTitan()

			if ( !IsAlive( titan ) )
				return

			if ( titan == entAttachedTo )
				titanSoulRodeoed.SetLastRodeoHitTime( Time() )
		}
	}
}