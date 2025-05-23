
function main()
{
	file.fogDepth <- 64.0
	file.maxTitanSpawnFogDepth <- 170
	file.lethalTitanVolumes <- []
	file.lethalPilotVolumes <- []
	file.safePilotVolumes <- []
	file.volumesDebug <- false

	switch ( GetMapName() )
	{
		case "mp_lagoon":
			AddLethalTitanVolume( Vector( -45.656845, 3555.449463, 40.422455 ), Vector( 1209.944092, 5599.152832, 234.813217 ) )
			AddLethalTitanVolume( Vector( -5232.395020, 205.406250, 0.031250 ), Vector( -777.285400, 4075.119385, 300.634771 ) )
			AddLethalTitanVolume( Vector( -4686.448730, 4190.655273, 20.642021 ), Vector( -41.171387, 9072.019043, 200.697632 ) )
			AddLethalTitanVolume( Vector( -7586.861328, 4072.843994, 0.031254 ), Vector( -7012.854004, 4614.723145, 302.714966 ) )
			break

		case "mp_nexus":
			AddLethalTitanVolume( Vector( 1567.173523, -27.374023, 209.422455 ), Vector( 2516.944092, 2585.152832, 500.813217 ) )
			AddLethalTitanVolume( Vector( -2825.766113, 5056.203125, 243.706253 ), Vector( -2255.893555, 5688.334961, 400.251160 ) )
			AddLethalTitanVolume( Vector( -5717.068359, -349.599976, 189.669785 ), Vector( -4960.125000, 758.196350, 400.268097 ) )
			AddLethalTitanVolume( Vector( -3292.942139, 1713.916626, 233.749817 ), Vector( -2322.137695, 3091.497070, 477.462799 ) )
			AddLethalTitanVolume( Vector( -878.712769, -5878.528809, 71.145332 ), Vector( 338.741943, -5014.183594, 443.146179 ) )
			AddLethalTitanVolume( Vector( -6930.957031, -1277.388550, 107.619537 ), Vector( -6574.779297, -779.338013, 685.485901 ) )
			break

		case "mp_outpost_207":
			AddSafePilotVolume( Vector( 2359.524658, -631.065918, -256.714142 ), Vector( 2623.051270, -182.453323, -220.125641 ) )

			AddLethalTitanVolume( Vector( -100.349350, 2218.763916, -330.968750 ), Vector( 2561.511230, 4030.028320, -133.065369 ) )
			AddLethalTitanVolume( Vector( -452.031647, 282.244629, -255.968750 ), Vector( 2241.971069, 1594.146851, -100.212967 ) )
			break

		case "mp_training_ground":
			AddSafePilotVolume( Vector( -2618.053223, -3435.505615, 40.215054 ), Vector( -2309.167236, -3321.788330, 146.218491 ) )
			AddSafePilotVolume( Vector( -3187.767090, -2886.333496, 45.746925 ), Vector( -2865.753174, -2681.679443, 109.089279 ) )
			AddSafePilotVolume( Vector( -3717.815674, -2350.831543, 47.694588 ), Vector( -3431.980957, -2145.194092, 120.640717 ) )

			AddLethalTitanVolume( Vector( -3439.702179, -2227.359741, -8.036909 ), Vector( 2185.765076, 2384.459412, 225.199013 ) )
			AddLethalTitanVolume( Vector( -3200.747681, -4456.148926, 0.0 ), Vector( -1261.621826, -3000.667480, 160.689011 ) )
			AddLethalTitanVolume( Vector( 1261.621826, 3000.667480, 0.0 ), Vector( 2700.747681, 4456.148926, 160.689011 ) )
			AddLethalTitanVolume( Vector( -3291.510986, 3483.724609, 4.031250 ), Vector( -2018.871826, 4463.995850, 122.675621 ) )
			AddLethalTitanVolume( Vector( 2018.871826, -3638.995850, 4.031250 ), Vector( 2241.510986, -3483.724609, 122.675621 ) )
			AddLethalTitanVolume( Vector( -2798.816528, -2302.519897, -30.285933 ), Vector( -1561.589355, -791.616699, 300.917297 ) )
			AddLethalTitanVolume( Vector( 3809.276123, 1639.001587, 11.272846 ), Vector( 4056.847412, 1862.587036, 100.205643 ) )
			AddLethalTitanVolume( Vector( -4189.979492, -3298.505127, -5.597572 ), Vector( -3398.622803, -560.027344, 147.054291 ) )
			break

		case "mp_runoff":
			AddLethalPilotVolume( Vector( -621.502319, -5743.472656, 299.838928 ), Vector( -397.317047, -5578.512207, 425.437927 ) )
			break
	}
}

function GetFogHeight()
{
	local mapName = GetMapName()

	lethalFogHeights <- {}
	lethalFogHeights[ "mp_angel_city" ] <- 216.0 // cp ctf mfd
	lethalFogHeights[ "mp_lagoon" ] <- 98.0 // cp mfd
	lethalFogHeights[ "mp_nexus" ] <- 310.0 // mfd
	lethalFogHeights[ "mp_o2" ] <- 40.0 // mfd
	lethalFogHeights[ "mp_outpost_207" ] <- -225.0 // mfd
	lethalFogHeights[ "mp_training_ground" ] <- 80.0 // cp mfd
	lethalFogHeights[ "mp_harmony_mines" ] <- 260.0 // cp ctf mfd
	lethalFogHeights[ "mp_haven" ] <- 128.0 // mfd

	// good map, needs spawns, etc...
	lethalFogHeights[ "mp_rise" ] <- 420.0 // mfd
	lethalFogHeights[ "mp_runoff" ] <- 340.0 // mfd
	lethalFogHeights[ "mp_zone_18" ] <- 460.0 // mfd
	lethalFogHeights[ "mp_sandtrap" ] <- 64.0

	// these don't work as well
	lethalFogHeights[ "mp_swampland" ] <- 350.0	// mfd
	lethalFogHeights[ "mp_backwater" ] <- 320.0 // mfd
	lethalFogHeights[ "mp_airbase" ] <- 450.0
	lethalFogHeights[ "mp_boneyard" ] <- 64.0
	lethalFogHeights[ "mp_colony" ] <- 270.0
	lethalFogHeights[ "mp_corporate" ] <- -765.0
	lethalFogHeights[ "mp_fracture" ] <- 270.0
	lethalFogHeights[ "mp_overlook" ] <- 16.0
	lethalFogHeights[ "mp_relic" ] <- 475.0
	lethalFogHeights[ "mp_smugglers_cove" ] <- 400.0
	lethalFogHeights[ "mp_wargames" ] <- 64.0
	lethalFogHeights[ "mp_switchback" ] <- 840.0

	lethalFogHeights[ "mp_mia" ] <- -128.0

	if ( mapName in lethalFogHeights )
		return lethalFogHeights[ mapName ]

	return 64.0
}
Globalize( GetFogHeight )

function GetLethalFogTopTitan()
{
	local fogTop = GetLethalFogTop()

	switch ( GetMapName() )
	{
		case "mp_lagoon":
		case "mp_nexus":
		case "mp_outpost_207":
		case "mp_training_ground":
			return fogTop

		default:
			return fogTop + 256.0
	}
}
Globalize( GetLethalFogTopTitan )

function GetLethalFogTop()
{
	return GetFogHeight() - file.fogDepth * 0.2
}
Globalize( GetLethalFogTop )

function GetLethalFogBottom()
{
	return GetFogHeight() - file.fogDepth * 0.7
}
Globalize( GetLethalFogBottom )

function GetVisibleFogTop()
{
	return GetFogHeight() + file.fogDepth * 0.5
}
Globalize( GetVisibleFogTop )

function GetVisibleFogBottom()
{
	return GetFogHeight() - file.fogDepth * 0.5
}
Globalize( GetVisibleFogBottom )

function GetMaxTitanSpawnFogHeight()
{
	return GetFogHeight() - file.maxTitanSpawnFogDepth
}
Globalize( GetMaxTitanSpawnFogHeight )

function AddLethalTitanVolume( volumeMins, volumeMaxs )
{
	Assert( volumeMins.x < volumeMaxs.x )
	Assert( volumeMins.y < volumeMaxs.y )
	Assert( volumeMins.z < volumeMaxs.z )

	file.lethalTitanVolumes.append( { mins = volumeMins, maxs = volumeMaxs } )
}

function AddLethalPilotVolume( volumeMins, volumeMaxs )
{
	Assert( volumeMins.x < volumeMaxs.x )
	Assert( volumeMins.y < volumeMaxs.y )
	Assert( volumeMins.z < volumeMaxs.z )

	file.lethalPilotVolumes.append( { mins = volumeMins, maxs = volumeMaxs } )
}

function AddSafePilotVolume( volumeMins, volumeMaxs )
{
	Assert( volumeMins.x < volumeMaxs.x )
	Assert( volumeMins.y < volumeMaxs.y )
	Assert( volumeMins.z < volumeMaxs.z )

	file.safePilotVolumes.append( { mins = volumeMins, maxs = volumeMaxs } )
}

function IsEntInSafeVolume( ent )
{
	if ( ent.IsPlayer() )
	{
		foreach ( volume in file.safePilotVolumes )
		{
			local entOrg = ent.GetOrigin()

			if ( IsServer() && file.volumesDebug )
				DebugDrawBox( Vector( 0.0, 0.0, 0.0 ), volume.mins, volume.maxs, 0, 0, 255, 1, 0.1 )

			if ( PointIsWithinBounds( entOrg, volume.mins, volume.maxs ) )
				return true
		}
	}
}
Globalize( IsEntInSafeVolume )

function IsEntInLethalVolume( ent )
{
	if ( ent.IsTitan() )
	{
		foreach ( volume in file.lethalTitanVolumes )
		{
			local entOrg = ent.GetOrigin()

			if ( IsServer() && file.volumesDebug )
				DebugDrawBox( Vector( 0.0, 0.0, 0.0 ), volume.mins, volume.maxs, 255, 255, 0, 1, 0.1 )

			if ( PointIsWithinBounds( entOrg, volume.mins, volume.maxs ) )
				return true
		}
	}
	else if ( ent.IsPlayer() )
	{
		foreach ( volume in file.lethalPilotVolumes )
		{
			local entOrg = ent.GetOrigin()

			if ( IsServer() && file.volumesDebug )
				DebugDrawBox( Vector( 0.0, 0.0, 0.0 ), volume.mins, volume.maxs, 255, 255, 0, 1, 0.1 )

			if ( PointIsWithinBounds( entOrg, volume.mins, volume.maxs ) )
				return true
		}
	}

	return false
}
Globalize( IsEntInLethalVolume )