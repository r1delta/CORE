function main()
{
	Globalize( SpawnAnimatedGunship )
	Globalize( InitLeanGunship )

	PrecacheModel( STRATON_MODEL )
	PrecacheModel( HORNET_MODEL )
	PrecacheParticleSystem( FX_GUNSHIP_THRUSTERS )
	PrecacheParticleSystem( FX_GUNSHIP_THRUSTERS_HEAT )
	PrecacheParticleSystem( FX_GUNSHIP_ACL_LIGHT_GREEN )
	PrecacheParticleSystem( FX_GUNSHIP_ACL_LIGHT_RED )
	PrecacheParticleSystem( FX_GUNSHIP_ACL_LIGHT_WHITE )
	PrecacheParticleSystem( FX_GUNSHIP_CRASHING_SMOKETRAIL )
	PrecacheParticleSystem( FX_GUNSHIP_CRASHING_FIREBALL )
	PrecacheParticleSystem( FX_GUNSHIP_CRASH_IMPACT )
	PrecacheParticleSystem( FX_GUNSHIP_CRASH_EXPLOSION )
/*
	Globalize( GunshipCrashLoopSounds )
	Globalize( GunshipSpawn )
	Globalize( GunshipSpawnAndPatrol )
	Globalize( GunshipPatrol )
	Globalize( GunshipStartHuntPlayer )
	Globalize( GunshipStopHuntPlayer )
	Globalize( GunshipHuntPlayerWhenInTrigger )
	Globalize( GunshipSpotlightOn )
	Globalize( GunshipSpotlightOff )
	Globalize( GunshipSetSpotlightTarget )
	Globalize( _GunshipTakesDamage )
	Globalize( GunshipCrashDeath )

	Globalize( _GunshipInit ) // temporarily exposing this

	//PrecacheModel( FUNC_TANK_MODEL )

	RegisterSignal( "EndSpotlightDefaultBehavior" )
	RegisterSignal( "GunshipStopFiringAtPlayer" )
	RegisterSignal( "Crashed" )
	RegisterSignal( "Crashing" )
	RegisterSignal( "GunshipCrashTimeout" )*/
}

function SpawnAnimatedGunship( origin, team, squadname = null, health = null, instamission = null, model = STRATON_MODEL )
{
	local gunship = CreateEntity( "npc_gunship" )
	gunship.kv.spawnflags = 0
	gunship.kv.vehiclescript = "scripts/vehicles/straton.txt"
	gunship.kv.teamnumber = team

	gunship.SetModel( model )

	gunship.SetOrigin( origin )

	if ( squadname == null )
	{
		squadname = "gunship_squad_" + gunship.GetEntIndex()
	}

	gunship.kv.squadname = squadname

	DispatchSpawn( gunship, true )

	local gunship_health = 3000
	if ( health )
		gunship_health = health
	gunship.SetHealth( gunship_health )
	gunship.SetMaxHealth( gunship_health )

//	thread DropshipDamageEffects( gunship )
	gunship.EnableRenderAlways()

//	AddAnimEvent( gunship, "dropship_warpout", WarpoutEffect )

	return gunship
}

function InitLeanGunship( gunship )
{
	if ( gunship.kv.desiredSpeed.tofloat() <= 0 )
	{
		gunship.kv.desiredSpeed = GUNSHIP_DEFAULT_AIRSPEED
	}

	gunship.Fire( "GunOff" )
	_GunshipFX( gunship )

	//------------------------------------------------
	//Weapons - Func_tanks for guns until actrual code gun is fixed
	//------------------------------------------------
//	gunship.s.machineGun1 <- _GunshipCreateGun( gunship, PositionOffsetFromEnt( gunship, 258, 22, -55 ) )
//	gunship.s.machineGun2 <- _GunshipCreateGun( gunship, PositionOffsetFromEnt( gunship, 258, -22, -55 ) )



	//------------------------------------------------------------------
	// Decide whether to do scripted death if there are "gunship_crash_locations"
	//------------------------------------------------------------------
	local crashLocations = GetEntArrayByNameWildCard_Expensive( "gunship_crash_location*" )
	if ( crashLocations.len() > 0 )
	{
		gunship.s.isCrashing <- false
		gunship.SetHealth( 9999 )
		gunship.s.crashLocations <- crashLocations
		gunship.s.hitsTaken <- 0
		gunship.ConnectOutput( "OnDamaged", "_GunshipTakesDamage" )
	}

	return gunship
}

function _GunshipFX( gunship )
{
	if ( gunship.GetModelName() == STRATON_MODEL )
	{
		//----------------------
		// ACL Lights
		//----------------------
		PlayLoopFXOnEntity( FX_GUNSHIP_ACL_LIGHT_RED, gunship, "light_red0", null, null )
		PlayLoopFXOnEntity( FX_GUNSHIP_ACL_LIGHT_RED, gunship, "light_red1", null, null )
		PlayLoopFXOnEntity( FX_GUNSHIP_ACL_LIGHT_RED, gunship, "light_red2", null, null )
		PlayLoopFXOnEntity( FX_GUNSHIP_ACL_LIGHT_GREEN, gunship, "light_green0", null, null )
		PlayLoopFXOnEntity( FX_GUNSHIP_ACL_LIGHT_GREEN, gunship, "light_green1", null, null )
		PlayLoopFXOnEntity( FX_GUNSHIP_ACL_LIGHT_GREEN, gunship, "light_green2", null, null )
	//	PlayLoopFXOnEntity( FX_GUNSHIP_ACL_LIGHT_WHITE, gunship, "light_white", null, null )

		//----------------------
		// Thrusters
		//----------------------
		PlayLoopFXOnEntity( FX_GUNSHIP_THRUSTERS, gunship, "R_exhaust_front_1", null, null )
		PlayLoopFXOnEntity( FX_GUNSHIP_THRUSTERS, gunship, "L_exhaust_front_1", null, null )
		PlayLoopFXOnEntity( FX_GUNSHIP_THRUSTERS, gunship, "R_exhaust_rear_1", null, null )
		PlayLoopFXOnEntity( FX_GUNSHIP_THRUSTERS, gunship, "L_exhaust_rear_1", null, null )

		//----------------------
		// Thrusters HEAT DISTORT - commented out for bug9119 with refract materials
		//----------------------
		PlayLoopFXOnEntity( FX_GUNSHIP_THRUSTERS_HEAT, gunship, "R_exhaust_front_1", null, null )
		PlayLoopFXOnEntity( FX_GUNSHIP_THRUSTERS_HEAT, gunship, "L_exhaust_front_1", null, null )
		PlayLoopFXOnEntity( FX_GUNSHIP_THRUSTERS_HEAT, gunship, "R_exhaust_rear_1", null, null )
		PlayLoopFXOnEntity( FX_GUNSHIP_THRUSTERS_HEAT, gunship, "L_exhaust_rear_1", null, null )

		//_GunshipSpotlightFX( gunship )
	}
	else if ( gunship.GetModelName() == HORNET_MODEL )
	{
		// Nothing yet - Robot needs to add effects. Model doesn't have the tags listed above
	}
}

