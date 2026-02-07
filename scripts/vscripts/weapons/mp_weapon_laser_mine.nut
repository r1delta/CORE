
const MAX_LASERMINES_IN_WORLD 	= 6  	// if more than this are thrown, the oldest one gets cleaned up
const LASERMINE_TIMEOUT 		= -1	// seconds after which the mine gets auto cleaned up; -1 = no timeout

function LaserMinePrecache()
{
	if ( WeaponIsPrecached( self ) )
		return

	PrecacheParticleSystem( "wpn_laser_blink" )
	PrecacheParticleSystem( "wpn_laser_beam" )
	PrecacheParticleSystem( "wpn_laser_end" )

	if ( IsServer() )
	{
		PrecacheEntity( "npc_grenade_frag" )
	}
}
LaserMinePrecache()

function OnWeaponPrimaryAttackAnimEvent( attackParams )
{
	if ( !IsServer() && !self.ShouldPredictProjectiles() )
		return

	local player = self.GetWeaponOwner()
	local attackPos
	if ( IsValid( player ) )
		attackPos = player.OffsetPositionFromView( attackParams.pos, Vector( 20.0, 0.0, -4.0 ) )	// forward, right, up
	else
		attackPos = attackParams.pos

	local velocity = (attackParams.dir + Vector( 0, 0, 0.1 )) * 700
	local angularVelocity = Vector( 600, RandomFloat( -300, 300 ), 0 )
	local fuseTime = 0	// infinite

	local mine = self.FireWeaponGrenade( attackPos, velocity, angularVelocity, fuseTime, damageTypes.Explosive, damageTypes.Explosive, PROJECTILE_PREDICTED, true, true )

	if ( mine )
	{
		mine.SetTeam( player.GetTeam() )

		if ( IsServer() )
		{
			mine.SetOwner( player )
			Grenade_Init( mine, self )
			mine.s.onlyAllowSmartPistolDamage = false

			local mineHealth = 75
			thread TrapExplodeOnDamage( mine, mineHealth )

			// HACK for FX
			if ( Flag( "ShowExplosionRadius" ) )
				thread ShowExplosionRadiusOnExplode( mine )
		}
	}

	return 1
}

function OnProjectileCollision( collisionParams )
{
	if( IsValid( collisionParams.hitent ) )
	{
		local planted = PlantStickyEntity( self, collisionParams, 1.0, Vector(90,0,0) ) // last number represents what normals it will stick to. 1.0 will stick to contact on anything, 0.65 will allow it to stick to anything greater than about a 45 degree slope

		if ( !planted )
			return

		if ( !IsServer() )
			return

		// owner disconnected while throwing
		if ( !IsValid( self.GetOwner() ) )
		{
			self.Kill()
			return
		}

//		if ( !self.nv.armed )
//			thread InitMine( self )
	}
}

function InitMine( mine )
{
	Assert( IsServer() )

	local endPointInfo = LaserMine_GetEndPointInfo( mine)
	local endPointOrg = endPointInfo.endPointOrg

	// entity that the mine can test against for laser beam breakage, parented to the mine so it moves with it
	local endPointEnt = CreateEntity( "info_placement_helper" )
	endPointEnt.SetName( UniqueString( "lasermine_endBeamOrg" ) )
	endPointEnt.kv.start_active = 1
	DispatchSpawn( endPointEnt )
	endPointEnt.SetOrigin( endPointOrg )
	endPointEnt.SetParent( mine, "", true )

	mine.s.laserEndPointEnt <- endPointEnt

	local player = mine.GetOwner()

	wait 0.8

	// if owner player disconnected while waiting to activate, kill the mine
	if ( !IsValid( player ) )
	{
		mine.Kill()
		return
	}

	// If already at the laser mine in world limit, remove the oldest mine before activating this one
	ArrayRemoveInvalid( player.s.activeLaserMines )
	if ( player.s.activeLaserMines.len() == MAX_LASERMINES_IN_WORLD )
	{
		local oldestMine = player.s.activeLaserMines[ 0 ]  // since it's an array, the first one will be the oldest
		thread LaserMine_DeactivateAndKill( oldestMine )
	}

	PlayerTrackLaserMine( player, mine )

	LaserMine_Enable( mine )
	//thread TestLaserEffects( mine )  // TEMP keeping for testing

	thread MineThink( mine )
}

// TEMP keeping this for testing
function TestLaserEffects( mine )
{
	mine.EndSignal( "OnDestroy" )

	local fxOn = true
	while ( IsValid( mine ) )
	{
		wait 3

		if ( fxOn )
		{
			LaserMine_Disable( mine )
			fxOn = false
		}
		else
		{
			LaserMine_Enable( mine )
			fxOn = true
		}
	}
}

function MineThink( mine )
{
	Assert( IsServer() )

	local laserLength = GetWeaponInfoFileKeyField_Global( "mp_weapon_laser_mine", "explosionradius" )
	local startTime = Time()

	while ( 1 )
	{
		wait 0

		if ( LASERMINE_TIMEOUT > 0 && Time() >= ( startTime + LASERMINE_TIMEOUT ) )
			break

		if ( !IsValid( mine ) || !IsValid( mine.s.laserEndPointEnt ) )
			break

		if ( !mine.nv.armed )
		{
			wait 0.1  // wait before continuing to ensure that players can see the laser before it can detonate
			continue
		}

		local traceResults = TraceLineHighDetail( mine.GetOrigin(),  mine.s.laserEndPointEnt.GetOrigin(), mine, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )

		local ent = traceResults.hitEnt

		if ( !IsValid( ent ) )
			continue

		if ( ent == level.worldspawn )
			continue

		if ( ent.GetTeam() == mine.GetTeam() )
			continue

		if ( ent == mine.GetParent() )
			continue

		local entClass = ent.GetClassname()

		if ( !( entClass in level.laserMineTripClasses ) )
			continue

		// "grenade" type entities are separately whitelisted by weapon classname
		if ( ent.GetClassname() == "npc_grenade_frag" )
		{
			Assert( "GetWeaponClassName" in ent )
			local weaponClass = ent.GetWeaponClassName()

			if ( !( weaponClass in level.laserMineTripClasses_GrenadeWeapons ) )
				continue
		}

		//printt( "Laser mine tripped by ", ent )
		//printt( "Mine Team:", mine.GetTeam() )
		//printt( "Ent Team:", ent.GetTeam() )

		break
	}

	if ( !IsValid( mine ) )
		return

	local shouldExplode = true
	if ( LASERMINE_TIMEOUT > 0 && Time() <= ( startTime + LASERMINE_TIMEOUT ) )
		shouldExplode = false

	if (  shouldExplode )
	{
		// explode!
		EmitSoundOnEntity( mine, LASER_TRIP_MINE_SOUND )
		mine.Explode( mine.s.bounceNormal )
	}
	else
	{
		// timed out, clean it up
		thread LaserMine_DeactivateAndKill( mine )
	}
}
