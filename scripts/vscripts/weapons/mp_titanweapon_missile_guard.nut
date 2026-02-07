/*
SetWeaponSound( "fire", "Weapon_titansniper.Fire" )
SetWeaponSound( "empty", "Weapon_SMG1.Empty" )
//SetWeaponSound( "reload", "Weapon_R1Shotgun.Dryfire" )
SetWeaponSound( "double_shot", "Weapon_titansniper.Fire" )
SetWeaponSound( "reload_npc", "Weapon_SMG1.NPC_Reload" )
SetWeaponSound( "single_shot_npc", "ai_weapon_fire" )
SetWeaponSound( "casings", "Weapon_bulletCasings.Bounce" )
SetWeaponSound( "charge", "anti_titan_rifle_charge" )
SetWeaponSound( "bullet_absorb", "Weapon_Vortex_Gun.BulletAbsorb" )
SetWeaponSound( "blocking", "Weapon_R1sonargrenade.Effect" )
*/
const REPAIR_RANGE = 1000
const PERCENT_REPAIR = 0.2

const RECHARGE_TIME = 20.0
lastFireTime <- Time() - RECHARGE_TIME

function MissleGuardPrecache()
{
	if ( WeaponIsPrecached( self ) )
		return

	PrecacheParticleSystem( "wpn_muzzleflash_xo_fp" )
	PrecacheParticleSystem( "wpn_muzzleflash_xo" )
	PrecacheParticleSystem( "wpn_shelleject_pistol_FP" )
	PrecacheParticleSystem( "wpn_shelleject_pistol" )

	if ( IsServer() )
	{
		PrecacheSprite( "sprites/laserbeam.vmt" )
		PrecacheSprite( "sprites/blueflare1.vmt" )
		PrecacheModel( "models/robots/agp/agp_hemlok_static.mdl" )
	}
}
MissleGuardPrecache()

function OnWeaponActivate( activateParams )
{
}

function OnWeaponDeactivate( deactivateParams )
{
}

function OnWeaponPrimaryAttack( attackParams )
{
	if ( Time() - lastFireTime < RECHARGE_TIME )
		return 0

	if( IsServer() )
		SpawnRepairDrone( attackParams )

	lastFireTime = Time()
	return 1
}

function SpawnRepairDrone( attackParams )
{
	local weaponOwner = self.GetWeaponOwner()
	local spawnPos = weaponOwner.OffsetPositionFromView( attackParams[ "pos" ], Vector( 80.0, -20.0, 15.0 ) )

	local hoverdrone = CreateEntity( "npc_cscanner" )
	hoverdrone.SetName( "hoverdrone" + UniqueString() )
	//hoverdrone.SetModel( "models/weapons/satchel_charge/satchel_charge.mdl" )
	hoverdrone.SetModel( "models/robots/agp/agp_hemlok_static.mdl" )
	hoverdrone.kv.rendercolor = "255 255 255"
	hoverdrone.kv.health = 6500
	hoverdrone.kv.max_health = 6500
	hoverdrone.kv.spawnflags = 8208	//16 = Efficient - Don't acquire enemies 8192 - don't drop weapons
	hoverdrone.kv.FieldOfView = 0
	hoverdrone.kv.FieldOfViewAlert = 0
	hoverdrone.kv.sleepstate = 0
	hoverdrone.kv.AccuracyMultiplier = 1.0
	hoverdrone.kv.reactChance = 0
	hoverdrone.kv.physdamagescale = 1.0
	hoverdrone.kv.WeaponProficiency = 0
	hoverdrone.kv.spotlightlength = 500
	hoverdrone.kv.spotlightwidth = 50
	hoverdrone.kv.ShouldInspect = 0
	hoverdrone.kv.NeverInspectPlayers = true
	hoverdrone.kv.suppressLKPDuration = 0.0
	hoverdrone.kv.ignoreunseenenemies = true
	hoverdrone.SetOrigin( spawnPos )
	hoverdrone.SetAngles( Vector( 0, 0, 0 ) )
	//hoverdrone.SetRevealRadius( 0 )
	//hoverdrone.SetAffectedByShroud( true )
	DispatchSpawn( hoverdrone, false )

	hoverdrone.Fire( "SetMoveSpeedScale", 0 )
	hoverdrone.SetTeam( weaponOwner.GetTeam() )
	hoverdrone.SetTitle( "#REPAIR_DRONE" )
	hoverdrone.SetOwnerPlayer( weaponOwner )
	printt(hoverdrone.GetEntIndex())
	printt(weaponOwner.GetEntIndex())
//	thread MissileGuard( hoverdrone )
	thread RepairDrone( hoverdrone )
}

function RepairDrone( drone )
{
	local duration = 40
	drone.Kill( duration )
	drone.EndSignal( "OnDestroy" )

	while(1)
	{
		if ( !IsValid( drone ) || !IsAlive( drone ) )
			break

		if( drone.GetHealth() <= 5000 )	// Working around an AI pattern of cscanner's when they die.
			drone.Kill()

		local weaponOwner = self.GetWeaponOwner()
		local entityArray = ArrayWithin( GetAllFriendlyTitans( weaponOwner.GetTeam() ), drone.GetOrigin(), REPAIR_RANGE )
		foreach( ent in entityArray )
		{
			CreateMissileGuardBeam( drone, ent, drone.GetOrigin(), ent.GetOrigin(), 0.5, 256, 4, 5, true, false)
			local maxHealth = ent.GetMaxHealth()
			local repairAmount = maxHealth * PERCENT_REPAIR
			local repairLocation = drone.GetOrigin()
			local damageSourceId =  eDamageSourceId.mp_titanweapon_missile_guard
			local repairer = self.GetWeaponOwner()
			RepairTitanDamage( ent, repairAmount, repairLocation, damageSourceId, repairer )
		}
		wait 2
	}
}


function MissileGuard( drone )
{
	local duration = 20
	drone.Kill( duration )
	drone.EndSignal( "OnDestroy" )


	while(1)
	{
		wait 0

		if ( !IsValid( drone ) || !IsAlive( drone ) )
			break

		if( drone.GetHealth() <= 4500 )	// Working around an AI pattern of cscanner's when they die.
			drone.Kill()

		local missiles = GetProjectileArrayEx( "rpg_missile", -1, Vector( 0, 0, 0 ), -1 )
		if ( !missiles.len() )
			continue

		local closestMissile = GetClosest( missiles, drone.GetOrigin(), 1000 )
		printt( "Missiles:", missiles.len(), "closestMissile:", closestMissile )

		if ( !IsValid( closestMissile ) )
			continue

		CreateMissileGuardBeam( drone, closestMissile, drone.GetOrigin(), closestMissile.GetOrigin(), 0.5, 256, 4, 5, true, false)
		closestMissile.Kill()
		wait 0.2
	}

	printt("MissileGuard Drone Destroyed")
}

function CreateMissileGuardBeam( weapon, target, startPos, endPos, player, lifeDuration = 0.5, radius = 256, boltWidth = 4, noiseAmplitude = 5, hasTarget = true, firstBeam = false )
{
	Assert( startPos )
	Assert( endPos )
	Assert( IsServer() )

	//**************************
	// 	LIGHTNING BEAM EFFECT
	//**************************

	// Control point sets the end position of the effect
	local cpEnd = CreateEntity( "info_placement_helper" )
	cpEnd.SetName( UniqueString( "arc_cannon_beam_cpEnd" ) )
	cpEnd.SetOrigin( endPos )
	DispatchSpawn( cpEnd, false )

	local zapBeam = CreateEntity( "info_particle_system" )
	zapBeam.kv.cpoint1 = cpEnd.GetName()
	zapBeam.kv.effect_name = "wpn_arc_cannon_beam"
	zapBeam.kv.color = "0 255 0"
	zapBeam.kv.start_active = 0
	zapBeam.SetOwner( player )
	zapBeam.SetOrigin( startPos )
	DispatchSpawn( zapBeam )

	zapBeam.Fire( "Start" )
	zapBeam.Fire( "StopPlayEndCap", "", lifeDuration )
	zapBeam.Kill( lifeDuration )
	cpEnd.Kill( lifeDuration )
}

function OnClientAnimEvent( name )
{
}

function CooldownBarFracFunc()
{
	if ( IsValid( self ) )
		return GraphCapped( Time(), lastFireTime, lastFireTime + RECHARGE_TIME, 0.0, 1.0 )
	return 0
}