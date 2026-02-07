
const MAX_SATCHELS_IN_WORLD = 3  // if more than this are thrown, the oldest one gets cleaned up

RegisterSignal( "DetonateSatchels" )

const THROW_POWER = 620

function SatchelPrecache()
{
	if ( WeaponIsPrecached( self ) )
		return

	PrecacheParticleSystem( "wpn_satchel_clacker_glow_LG_1" )
	PrecacheParticleSystem( "wpn_satchel_clacker_glow_SM_1" )
	PrecacheParticleSystem( "wpn_laser_blink" )

	if ( IsServer() )
	{
		PrecacheEntity( "npc_grenade_frag" )
	}
}
SatchelPrecache()

function OnWeaponActivate( activateParams )
{
	if ( IsClient() && self.GetWeaponOwner() == GetLocalViewPlayer() )
	{
		self.PlayWeaponEffect( "wpn_satchel_clacker_glow_LG_1", null, "light_large" )
		self.PlayWeaponEffect( "wpn_satchel_clacker_glow_SM_1", null, "light_small" )
	}
}

function OnWeaponDeactivate( deactivateParams )
{
	if ( IsClient() && self.GetWeaponOwner() == GetLocalViewPlayer() )
	{
		self.StopWeaponEffect( "wpn_satchel_clacker_glow_LG_1", null )
		self.StopWeaponEffect( "wpn_satchel_clacker_glow_SM_1", null )
	}
}

function OnWeaponPrimaryAttackAnimEvent( attackParams )
{
	local player = self.GetWeaponOwner()
	if ( !IsValid( player ) )
		return

	if ( IsServer() )
		Player_DetonateSatchels( player )
}

function OnWeaponTossReleaseAnimEvent( attackParams )
{
	if ( IsClient() && !self.ShouldPredictProjectiles() )
		return

	local player = self.GetWeaponOwner()

	local attackPos
	if ( IsValid( player ) )
		attackPos = GetSatchelThrowStartPos( player, attackParams.pos )
	else
		attackPos = attackParams.pos

	local velocity = GetSatchelThrowVelocity( player, attackParams.dir.GetAngles() )
	local angularVelocity = Vector( 600, RandomFloat( -300, 300 ), 0 )

	local fuseTime = 0	// infinite

	if ( IsServer() )
	{
		// If already at the satchel in world limit, remove the oldest satchel
		ArrayRemoveInvalid( player.s.activeSatchels )
		if ( player.s.activeSatchels.len() > ( MAX_SATCHELS_IN_WORLD - 1 ) )
		{
			local oldestSatchel = player.s.activeSatchels[ 0 ]  // since it's an array, the first one will be the oldest
			CleanupPlayerSatchel( player, oldestSatchel )
		}
	}

	local satchel = self.FireWeaponGrenade( attackPos, velocity, angularVelocity, fuseTime, damageTypes.Explosive, damageTypes.Explosive, PROJECTILE_PREDICTED, true, true )

	if ( satchel )
	{
		if ( IsServer() )
		{
			thread EnableTrapWarningSound( satchel, 0, "Weapon_R1_LaserMine.ArmedBeep" )
			EmitSoundOnEntityExceptToPlayer( player, player, "weapon_r1_satchel.throw" )
			Grenade_Init( satchel, self )
			Satchel_PostFired_Init( satchel, player )
		}
	}
	return 1
}

function GetSatchelThrowStartPos( player, baseStartPos )
{
	local attackPos = player.OffsetPositionFromView( baseStartPos, Vector( 15.0, 0.0, 0.0 ) )	// forward, right, up
	return attackPos
}

function GetSatchelThrowVelocity( player, baseAngles )
{
	baseAngles += Vector( -8, 0, 0 )
	local forward = baseAngles.AnglesToForward()

	local throwPower = THROW_POWER

	if ( baseAngles.x < 80 )
		throwPower = GraphCapped( baseAngles.x, 0, 80, THROW_POWER, THROW_POWER * 3 )

	local velocity = forward * throwPower

	return velocity
}

function OnProjectileCollision( collisionParams )
{
	local bounceDot = 1.0  // sets the dot of the normals it'll stick to
	local result = PlantStickyEntity( self, collisionParams, bounceDot )

	if ( IsServer() )
	{
		local player = self.GetOwner()

		if ( !IsValid( player ) )
		{
			self.Kill()
			return
		}

		EmitSoundOnEntity( self, "Weapon_R1_Satchel.Attach" )


		//if player is rodeoing a Titan and we stickied the satchel onto the Titan, set lastAttackTime accordingly
		if ( result )
		{
			local entAttachedTo = self.GetParent()
			if ( !IsValid( entAttachedTo ) )
				return

			if ( !player.IsPlayer() ) //If an NPC Titan has vortexed a satchel and fires it back out, then it won't be a player that is the owner of this satchel
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