VORTEXGRENADE_PROJECTILE_LIGHT_COLOR <- "39 167 216"
TELEPORTGRENADE_TELEPORT_DELAY <- 1.0
TELEPORTGRENADE_TELEPORT_FX <- "Cleanser_edge_1"
TELEPORTGRENADE_FX_LIFETIME <- 1.5
TELEPORTGRENADE_TELEFRAG_RADIUS <- 90

function main()
{
}

function bamf()
{
	//printl ( "trying to bamf" )
	local bamfs = GetEntArrayByNameWildCard_Expensive( "bamf*" )
	if ( bamfs.len() == 0 )
	{
    printl ( "no bamfs" )
		return
	}

	//printl( "used button" )
	bamfs = ArrayClosestToView( bamfs, player )
	//bamfs = ArrayClosest( bamfs, player.GetOrigin() )
	local foundOne = false

	foreach ( bamf in bamfs )
	{
		//already standing there?
		if ( Distance( player.GetOrigin(), bamf.GetOrigin() ) < 100 )
			continue

		//Can trace to it?
    	local playerEye = player.GetOrigin() + Vector( 0, 0, 63 ) // player eye location
    	local trace = TraceLineSimple( playerEye, bamf.GetOrigin(), player )

    	if ( trace == 1 )
    	{
    		//DebugDrawLine( player.GetOrigin(), bamf.GetOrigin(), 0, 255, 0, true, 10 )
    		local footPosition = bamf.GetOrigin() + Vector( 0, 0, -60 )
    		if ( PlayerCanTeleportHere( player, footPosition ) )
			{
    			foundOne = true

				PlayerTeleport( player, footPosition )
				//DebugDrawBox( footPosition, Vector(-8,-8,-8), Vector(8,8,8), 255, 255, 0, 1, 8 )
				//DebugDrawLine( footPosition, footPosition + Vector( 0, 0, 63 ), 255, 100, 100, true, 3 )
			}

    		break
    	}
    	else
    	{
    		//DebugDrawLine( player.GetOrigin(), bamf.GetOrigin(), 255, 0, 0, true, 10 )
    		//printl ( "trace failed" )
    	}
	}

	if ( foundOne != true )
	{
		local footPosition = bamfs[0].GetOrigin() + Vector( 0, 0, -60 )
 		if ( PlayerCanTeleportHere( player, footPosition ) )
 		{
    	//printl ( "fall back to closest" )
			PlayerTeleport( player, footPosition )
		}
	}
}






function PlayerTeleport( player, teleportSpotOrigin )
{
	local startingPosition = player.GetOrigin()
	//local teleportSpotOrigin = teleportSpot.GetOrigin()
	local vector = startingPosition - teleportSpotOrigin
	vector.Norm()
	local angles = vector.GetAngles()
	player.SetAngles( Vector( angles.x, angles.y, 0 ) )

	printl( "Teleporting player to pos " + teleportSpotOrigin )
	player.SetOrigin( teleportSpotOrigin )

	local fxent = CreateTeleportFX( player )
	fxent.Kill( TELEPORTGRENADE_FX_LIFETIME )
	EmitSoundOnEntity( player, TELEPORTGRENADE_TELEPORT_BANG_SOUND )
	EmitSoundOnEntity( player, TELEPORTGRENADE_TELEPORT_FIZZLE_SOUND )

	TelefragNearPoint( player, teleportSpotOrigin, TELEPORTGRENADE_TELEFRAG_RADIUS )
}

function TelefragNearPoint( player, teleportSpot, telefragRadius )
{
	local localents = GetEntArrayWithin( "npc*", teleportSpot, telefragRadius )

	foreach ( ent in localents )
	{
		if ( IsValid_ThisFrame( ent ) && IsAlive( ent ) && ent.GetClassname() != "npc_bullseye" )
		{
			printl( "telefragging npc " + ent )
			PlayerTelefragEntity( player, ent )
		}
	}
}

function CreateTeleportFX( player )
{
	local info_particle_system = CreateEntity( "info_particle_system" )
	info_particle_system.kv.effect_name = TELEPORTGRENADE_TELEPORT_FX
	info_particle_system.kv.start_active = 1

	// put it a little in front of the player
	local basepos = player.GetOrigin() + Vector( 0, 0, 30 )
	local forward = player.GetAngles().AnglesToForward()
	local newpos = basepos + ( forward * 32 )
	info_particle_system.SetOrigin( newpos )

	info_particle_system.SetAngles( player.GetAngles() + Vector( 90, 90, 0 ) )
	DispatchSpawn( info_particle_system, false )

	info_particle_system.SetParent( player )

	return info_particle_system
}

function PlayerTelefragEntity( player, ent )
{
	local entOrg = ent.GetOrigin()
	ent.Kill()

	EmitSoundOnEntity( player, TELEPORTGRENADE_TELEFRAG_SOUND )

	local lifetime = 3.0
	local spraytime = 1.0

	local gibshooter = CreateEntity( "gibshooter" )
	gibshooter.kv.angles = "90 0 0"
	gibshooter.kv.m_iGibs = 5
	gibshooter.kv.gibangles = "0 0 0"
	gibshooter.kv.m_flVelocity = 200
	gibshooter.kv.m_flVariance = "0.15"
	gibshooter.kv.m_flGibLife = "4"
	DispatchSpawn( gibshooter, false )
	gibshooter.SetOrigin( entOrg )
	gibshooter.Fire( "Shoot" )
	gibshooter.Kill( lifetime )

	local info_paint_sprayer = CreateEntity( "info_paint_sprayer" )
	info_paint_sprayer.SetAngles( Vector( 90, 0, 0 ) )
	info_paint_sprayer.kv.maxblobcount = 250
	info_paint_sprayer.kv.PaintType = 2
	info_paint_sprayer.kv.blobs_per_second = 3
	info_paint_sprayer.kv.min_speed = 100
	info_paint_sprayer.kv.max_speed = 100
	info_paint_sprayer.kv.min_streak_time = 0.2
	info_paint_sprayer.kv.max_streak_time = 0.5
	info_paint_sprayer.kv.min_streak_speed_dampen = 500
	info_paint_sprayer.kv.max_streak_speed_dampen = 1000
	DispatchSpawn( info_paint_sprayer, false )
	info_paint_sprayer.SetOrigin( entOrg )
	info_paint_sprayer.Fire( "Start" )
	info_paint_sprayer.Fire( "Stop", "", spraytime )
	info_paint_sprayer.Kill( lifetime )
}






main()