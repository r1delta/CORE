
function main()
{
	IncludeFile( "_riff_floor_is_lava_shared" )

	level.spawnRatingFunc_Pilot = RateSpawnpoint_Generic
	level.spawnRatingFunc_Generic = RateSpawnpoint_Generic

	// floor is lava 인 경우 npc 안나옴.
	level.nv.allowNPCs = eAllowNPCs.None

	file.lavaWarmupTime <- 1.5
	file.lavaNewTouchTime <- 0.4
	file.lavaDamageables <- []
	file.lethalFogTopTitan <- GetLethalFogTopTitan()
	file.lethalFogTop <- GetLethalFogTop()
	file.lethalFogBottom <- GetLethalFogBottom()
	file.visibleFogTop <- GetVisibleFogTop()
	file.visibleFogBottom <- GetVisibleFogBottom()
	thread FloorIsLavaDamageThink()

	AddSpawnCallback( "env_fog_controller", InitLavaFogController )
	AddCallback_OnPlayerRespawned( FloorIsLavaPlayerRespawned )
	AddSpawnCallback( "npc_titan", FloorIsLavaTitanSpawned )

	FlagInit( "SafeSpawnpointsInitialized" )
}

function EntitiesDidLoad()
{
	RemoveInvalidZiplines()
	thread RemoveInvalidTurrets()
	InitSafeSpawnpoints()
}

function InitLavaFogController( fogController )
{
	fogController.kv.fogztop = file.visibleFogTop
	fogController.kv.fogzbottom = file.visibleFogBottom
	fogController.kv.foghalfdisttop = "60000"
	fogController.kv.foghalfdistbottom = "200"
	fogController.kv.fogdistoffset = "0"
	fogController.kv.fogdensity = ".85"

	switch ( GetMapName() )
	{
		case "mp_angel_city":
			fogController.kv.forceontosky = true
			fogController.kv.foghalfdisttop = "10000"
			break

		case "mp_harmony_mines":
			fogController.kv.forceontosky = true
			fogController.kv.foghalfdistbottom = "100"
			fogController.kv.fogdensity = ".2"
			fogController.kv.foghalfdisttop = "15000"
			break

		case "mp_haven":
			fogController.kv.fogdensity = ".5"
			fogController.kv.fogdircolorstrength = "1.5"
			fogController.kv.foghalfdisttop = "8000000"
			break

		case "mp_o2":
			fogController.kv.fogdensity = ".65"
			fogController.kv.foghalfdisttop = "4000"
			fogController.kv.fogdircolorstrength = "1"
			fogController.kv.foghalfdistbottom = "100"
			break

		case "mp_outpost_207":
			fogController.kv.forceontosky = true
			fogController.kv.fogdircolorstrength = "1"
			fogController.kv.foghalfdisttop = "5000"
			break

		case "mp_runoff":
			fogController.kv.forceontosky = true
			fogController.kv.foghalfdistbottom = "100"
			fogController.kv.fogdensity = ".6"
			fogController.kv.foghalfdisttop = "10000"
			break

		case "mp_training_ground":
			fogController.kv.forceontosky = true
			fogController.kv.fogdensity = ".5"
			fogController.kv.fogdircolorstrength = "2"
			fogController.kv.foghalfdisttop = "8000"
			break
	}
}

function FloorIsLavaPlayerRespawned( player )
{
	file.lavaDamageables.append( { ent = player, isPlayer = true, lastFloorNotLavaTime = -99.0 } )
}

function FloorIsLavaTitanSpawned( titan )
{
	file.lavaDamageables.append( { ent = titan, isPlayer = false, lastFloorNotLavaTime = -99.0 } )
}

function FloorIsLavaDamageThink()
{
	while ( GetGameState() < eGameState.Playing )
		wait( 0.0 )

	wait file.lavaWarmupTime

	local ent = null
	local damageable = null
	local time = 0.0
	local  i = 0
	local indicatorCount = 0
	local scriptTypeMask = damageTypes.Dissolve | DF_STOPS_TITAN_REGEN

	while ( true )
	{
		time = Time()

		for ( i = file.lavaDamageables.len() - 1; i >= 0; i-- )
		{
			damageable = file.lavaDamageables[ i ]

			ent = damageable.ent

			if ( !IsValid( ent ) )
			{
				file.lavaDamageables.remove( i )
				continue
			}

			if ( !IsAlive( ent ) )
			{
				file.lavaDamageables.remove( i )
				continue
			}

			if ( !IsEntInLava( ent ) )
			{
				damageable.lastFloorNotLavaTime = Time()
				continue
			}

			if ( time - damageable.lastFloorNotLavaTime < file.lavaNewTouchTime )
				continue

			local isTitan = ent.IsTitan()
			local damageOrigin = ent.GetOrigin() + ( isTitan ? Vector( 0.0, 0.0, 0.0 ) : Vector( 0.0 , 0.0, -200.0 ) )
			damageOrigin += Vector( RandomFloat( -300.0, 300.0 ), RandomFloat( -300.0, 300.0 ), RandomFloat( -100.0, 100.0 ) )

			if ( indicatorCount == 0 && !isTitan )
				scriptTypeMask = damageTypes.Dissolve | DF_STOPS_TITAN_REGEN
			else
				scriptTypeMask = damageTypes.Dissolve | DF_STOPS_TITAN_REGEN | DF_NO_INDICATOR

			indicatorCount++
			if ( indicatorCount >= 4 )
				indicatorCount = 0

			ent.TakeDamage( GetLavaDamage( ent ), level.worldspawn, level.worldspawn, { origin = damageOrigin, scriptType = scriptTypeMask, damageSourceId = eDamageSourceId.floor_is_lava } )
		}

		wait( 0.0 )
	}
}

function IsEntInLava( ent )
{
	if ( IsEntInSafeVolume( ent ) == true )
		return false

	if ( IsEntInLethalVolume( ent ) == true )
		return true

	if ( ent.IsTitan() )
	{
		if ( ent.GetOrigin().z > file.lethalFogTopTitan )
			return false
	}
	else
	{
		if ( ent.GetOrigin().z > file.lethalFogTop )
			return false
	}

	if ( EvacEnabled() && IsPlayerOnEvacDropship( ent ) )
		return false

	return true
}

function GetLavaDamage( ent )
{
	local scale = 1.0

	if ( ent.GetOrigin().z < file.lethalFogTop && ent.GetOrigin().z > file.lethalFogBottom )
		scale = ( file.lethalFogTop - ent.GetOrigin().z ) / ( file.lethalFogTop - file.lethalFogBottom )
	scale = GraphCapped( scale, 0.0, 1.0, 0.2, 1.0 )

	if ( ent.IsTitan() )
		return ent.GetMaxHealth() * 0.0025 * scale

	if ( ent.IsHuman() )
		return ent.GetMaxHealth() * 0.05 * scale

	return ent.GetMaxHealth() * 0.2 * scale
}

function RemoveInvalidZiplines()
{
	switch ( GetMapName() )
	{
		case "mp_haven":
			GetEnt( "keyframe_rope_4" ).Destroy()
			GetEnt( "keyframe_rope_3" ).Destroy()
			GetEnt( "keyframe_rope_9" ).Destroy()
			GetEnt( "keyframe_rope_10" ).Destroy()
			GetEnt( "keyframe_rope_14" ).Destroy()
			GetEnt( "keyframe_rope_13" ).Destroy()
			break

		case "mp_nexus":
			GetEnt( "keyframe_rope_36" ).Destroy()
			GetEnt( "keyframe_rope_37" ).Destroy()
			GetEnt( "keyframe_rope_34" ).Destroy()
			GetEnt( "keyframe_rope_35" ).Destroy()
			GetEnt( "keyframe_rope_16" ).Destroy()
			GetEnt( "keyframe_rope_17" ).Destroy()
			break
	}
}

function RemoveInvalidTurrets()
{
	local controlPanels = GetEntArrayByClassWildCard_Expensive( "prop_control_panel" )

	foreach ( cp in controlPanels )
	{
		if ( cp.GetOrigin().z < file.lethalFogTop )
		{
			local turret = null

			while ( true )
			{
				turret = GetMegaTurretLinkedToPanel( cp )

				if ( IsValid( turret ) && turret.IsTurret() && "linkedToControlPanel" in turret.s && turret.s.linkedToControlPanel == true )
				{
					turret.Destroy()
					break
				}

				wait( 0.0 )
			}

			cp.Destroy()
		}
	}
}

function InitSafeSpawnpoints()
{
	local infoSpawnpointHuman = "info_spawnpoint_human"

	switch ( GetMapName() )
	{
		case "mp_angel_city":
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -3876.181641, 3039.127197, 296.031250 ), Vector( 0, -16, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -3226.761963, 2309.991699, 327.035248 ), Vector( 0, 75, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -2458.041992, 2740.752686, 416.031250 ), Vector( 0, -107, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -2139.593750, 2491.458984, 266.031250 ), Vector( 0, 75, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -4033.928223, 611.836548, 464.031250 ), Vector( 0, 90, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -3536.767334, 237.709427, 344.031250 ), Vector( 0, -87, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -2671.309570, 401.186646, 448.031250 ), Vector( 0, 94, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1827.068237, 1378.922729, 512.031250 ), Vector( 0, -94, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1706.778809, 1499.999146, 512.031250 ), Vector( 0, 0, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1565.782715, 2493.029297, 263.031250 ), Vector( 0, -109, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1413.554077, 2519.796875, 399.031250 ), Vector( 0, -103, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1343.489990, 3353.145996, 317.031250 ), Vector( 0, -107, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -977.248108, 4443.875488, 317.031250 ), Vector( 0, -62, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1197.061523, 3456.712646, 456.031250 ), Vector( 0, -175, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1383.006958, 1820.366699, 248.031250 ), Vector( 0, 179, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1431.394531, 1688.143677, 312.618591 ), Vector( 0, -125, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1577.109253, 1085.693237, 272.031250 ), Vector( 0, 179, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1057.924194, 665.447144, 304.031250 ), Vector( 0, 67, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 2437.566406, -2566.747070, 412.031250 ), Vector( 0, -89, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 3078.158691, -2768.876709, 412.031250 ), Vector( 0, 158, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 3039.607910, -2894.347412, 412.031250 ), Vector( 0, 175, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1557.348389, -2911.796631, 322.319153 ), Vector( 0, 0, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1684.379517, -1161.913208, 264.031250 ), Vector( 0, 67, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1286.811646, -918.913940, 265.031250 ), Vector( 0, 88, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 919.716980, -1114.093750, 295.037994 ), Vector( 0, 78, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 870.532410, -104.071373, 264.031250 ), Vector( 0, -119, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -355.340729, 1496.391235, 264.031250 ), Vector( 0, 43, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -11.591661, 1599.706787, 264.031250 ), Vector( 0, -145, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 353.943298, 2048.382324, 264.031250 ), Vector( 0, 121, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 165.970474, 2354.276855, 264.031250 ), Vector( 0, -118, 0 ) )

			// 3
			MoveSpawn( "info_spawnpoint_dropship_start_3", Vector( -4102.267578, 889.238831, 464.031250 ), Vector( 0, -2, 0 ) )

			// 1
			MoveSpawn( "info_spawnpoint_dropship_start_1", Vector( 3688.382568, -2391.510742, 604.031311 ), Vector( 0, 156, 0 ) )
			MoveSpawn( "info_spawnpoint_dropship_start_2", Vector( 2720.040527, -1497.251343, 336.880798 ), Vector( 0, 110, 0 ) )

			if ( GAMETYPE == CAPTURE_THE_FLAG )
			{
				local militiaFlag = GetFlagSpawnPoint( TEAM_MILITIA )
				militiaFlag.SetOrigin( Vector(1327.446045, -803.586731, 401.801422) )

				local imcFlag = GetFlagSpawnPoint( TEAM_IMC )
				imcFlag.SetOrigin( Vector(-1634.314209, 2461.618164, 263.031250) )
				imcFlag.SetAngles( Vector( 0, 70, 0 ) )
			}
			break

		case "mp_nexus":
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -6487.323242, 1809.342773, 683.363037 ), Vector( 0, -24, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -6176.771484, 5001.860352, 672.934326 ), Vector( 0, 12, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -2448.276855, 7072.885254, 673.768433 ), Vector( 0, -91, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 407.171539, 7297.197266, 507.725525 ), Vector( 0, -90, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 543.695923, 6998.306641, 781.031250 ), Vector( 0, 164, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 721.191101, 7148.569336, 645.031250 ), Vector( 0, -175, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 601.225220, 7069.000000, 509.031250 ), Vector( 0, -179, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 859.410950, 5420.658203, 438.263489 ), Vector( 0, -110, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1321.739990, 5428.174805, 384.003082 ), Vector( 0, -162, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 284.349640, 5512.765625, 448.031250 ), Vector( 0, 0, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1049.418701, 4856.965332, 458.571960 ), Vector( 0, -99, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1035.314331, 3698.493408, 448.720032 ), Vector( 0, 118, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -565.531006, 3663.853760, 448.031250 ), Vector( 0, 83, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1605.316162, 2559.206543, 448.031250 ), Vector( 0, -134, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1503.968750, 2451.407227, 448.031250 ), Vector( 0, 0, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1018.036194, 1890.985352, 440.031250 ), Vector( 0, 127, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1991.307495, 2265.090820, 448.031250 ), Vector( 0, -8, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -2037.464600, 2294.011230, 832.031250 ), Vector( 0, 74, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1417.653809, 2382.912598, 680.031250 ), Vector( 0, 1, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -402.205627, 3308.218506, 728.031250 ), Vector( 0, 176, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 730.256653, 3246.294678, 892.031250 ), Vector( 0, 67, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 748.350830, 2956.327393, 892.031250 ), Vector( 0, -111, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1132.470337, 3477.797119, 1118.031250 ), Vector( 0, -89, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 863.968384, 2993.333984, 576.031250 ), Vector( 0, 179, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -515.576050, 3303.397705, 576.031250 ), Vector( 0, 0, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 735.968567, 3017.967529, 440.031250 ), Vector( 0, -179, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -175.968460, 3021.533447, 440.031250 ), Vector( 0, 0, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 356.366882, 989.465881, 500.031250 ), Vector( 0, -54, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -728.483948, 1034.746582, 640.031250 ), Vector( 0, -97, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1183.968506, -1184.524780, 496.031250 ), Vector( 0, 0, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1228.138550, -1428.360229, 496.031250 ), Vector( 0, -161, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1502.203613, -1319.190552, 376.031250 ), Vector( 0, 6, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 611.974243, -825.271057, 492.031250 ), Vector( 0, 167, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 2735.306641, 108.479797, 472.031250 ), Vector( 0, -159, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 2719.395020, 2299.188477, 553.031189 ), Vector( 0, -116, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 3502.383057, 1768.029907, 440.031250 ), Vector( 0, 178, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1257.919678, -894.150879, 384.031250 ), Vector( 0, -154, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -2779.207275, 216.769058, 768.031250 ), Vector( 0, 93, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -6757.111328, -2062.690430, 750.945374 ), Vector( 0, 23, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -431.743408, -1043.527954, 496.031250 ), Vector( 0, -133, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -605.644897, -1037.658691, 496.031250 ), Vector( 0, -25.4, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -625.862305, -1311.590210, 496.031250 ), Vector( 0, 104, 0 ) )

			// militia
			MoveSpawn( "info_spawnpoint_dropship_start_1", Vector( 880.925659, 568.212646, 708.031250 ), Vector( 0, -178, 0 ) )
			MoveSpawn( "info_spawnpoint_dropship_start_2", Vector( 1749.331787, -607.073792, 438.031250 ), Vector( 0, 137, 0 ) )

			// imc
			MoveSpawn( "info_spawnpoint_dropship_start_3", Vector( -6443.421875, 1620.913452, 743.343140 ), Vector( 0, -15, 0 ) )
			MoveSpawn( "info_spawnpoint_dropship_start_4", Vector( -1853.301514, 1916.275024, 1107.533447 ), Vector( 0, -39, 0 ) )
			break

		case "mp_lagoon":
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1901.366089, 6018.688477, 453.649658 ), Vector( 0, 164, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 523.357300, 6078.498047, 254.031250 ), Vector( 0, 40, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1086.958374, 6416.407715, 153.851257 ), Vector( 0, 30, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 355.314056, 6445.423828, 304.031250 ), Vector( 0, -119, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 190.486313, 6053.564941, 292.031250 ), Vector( 0, 163, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 176.600571, 6157.667969, 192.031250 ), Vector( 0, 167, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 746.020264, 4764.297363, 192.531250 ), Vector( 0, 18, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 798.756897, 4237.321289, 217.427094 ), Vector( 0, 113, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 806.051758, 4637.765137, 209.749191 ), Vector( 0, -141, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 181.945816, 4270.963867, 192.031250 ), Vector( 0, 90, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 624.997620, 5099.337402, 192.031250), Vector( 0, 174, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 351.834290, 5938.455566, 1345.738525 ), Vector( 0, -143, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1235.968628, 4366.757813, 189.531250 ), Vector( 0, 51, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1038.200195, 4754.465820, 189.531250 ), Vector( 0, -15, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1082.388062, 5767.832031, 306.031250 ), Vector( 0, -155, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -2457.132324, 2376.914795, 796.031250 ), Vector( 0, 7, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -946.786438, 3299.740967, 354.431244 ), Vector( 0, 66, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -3611.205078, 2564.571777, 406.045990 ), Vector( 0, -28, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -4654.160645, 1410.191040, 188.052246 ), Vector( 0, -27, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -2717.455078, 2274.837646, 498.282806 ), Vector( 0, -120, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -2407.136719, 1911.373291, 399.656250 ), Vector( 0, -116, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -2153.086182, 1449.697632, 340.797668 ), Vector( 0, -7, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1958.064819, 846.353149, 428.381958 ), Vector( 0, -90, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1577.325684, 1210.419189, 322.951752 ), Vector( 0, -36, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -3178.687256, -2590.071289, 491.674286 ), Vector( 0, 77, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -2408.435059, -1693.230347, 442.956390 ), Vector( 0, 29, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -2773.184326, -1928.857788, 331.894257 ), Vector( 0, 121, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -2298.155273, -1635.423462, 331.894257 ), Vector( 0, 120, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -2233.643799, -1584.777100, 329.894257 ), Vector( 0, 67, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -2374.009033, -1372.658081, 187.894257 ), Vector( 0, 1, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1015.514160, -909.974426, 224.031250 ), Vector( 0, 31, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -585.323608, -413.122437, 224.031250 ), Vector( 0, -146, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1094.716797, -884.813660, 376.031250 ), Vector( 0, 32, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -445.976440, -644.321350, 470.797119 ), Vector( 0, 157, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -743.229736, -868.017151, 617.820374 ), Vector( 0, -144, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1075.816162, -1475.391357, 547.894775 ), Vector( 0, 122, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1422.379883, -2261.712891, 253.503845 ), Vector( 0, 105, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1627.083252, 888.805969, 540.241272 ), Vector( 0, 161, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1155.720459, 1315.245483, 715.481689 ), Vector( 0, -108, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1777.592407, 801.304871, 780.241272 ), Vector( 0, 127, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 730.038147, 753.984375, 910.431213 ), Vector( 0, 85, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1047.968140, 548.914917, 916.831238 ), Vector( 0, 7, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 2951.921387, 117.494682, 917.372803 ), Vector( 0, 88, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 4384.683105, -419.773376, 969.031250 ), Vector( 0, 146, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 4533.134766, 271.246979, 928.031250 ), Vector( 0, 132, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 4857.214844, 2000.922119, 944.031250 ), Vector( 0, -166, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 4654.534668, 660.369202, 1136.031250 ), Vector( 0, 168, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 3479.545898, 903.082642, 1024.587646 ), Vector( 0, -12, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 3936.374023, 2212.417480, 910.329224 ), Vector( 0, -153, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 4882.144043, 1895.679321, 752.031250 ), Vector( 0, -168, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 3737.161133, 1908.377319, 610.270874), Vector( 0, -123, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 3150.923340, 72.075989, 582.045715 ), Vector( 0, 70, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 4359.163086, -330.999298, 752.031250 ), Vector( 0, 141, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1420.482666, 526.021301, 305.190857 ), Vector( 0, 90, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 2557.471436, 2963.025879, 1100.831177 ), Vector( 0, -147, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 475.780243, 2361.825195, 807.290466 ), Vector( 0, 92, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 601.574280, 1519.258423, 837.280518 ), Vector( 0, -28, 0 ) )

			// imc
			MoveSpawn( "info_spawnpoint_dropship_start_1", Vector( 1398.158203, 6411.109375, 513.649719 ), Vector( 0, -160, 0 ) )
			MoveSpawn( "info_spawnpoint_dropship_start_2", Vector( 216.537292, 5439.375488, 580.031250 ), Vector( 0, -71, 0 ) )
			break

		case "mp_o2":
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -2983.968506, 317.765228, 332.031250 ), Vector( 0, 0, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -2983.968506, -194.934692, 120.031250 ), Vector( 0, 89, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -2846.968018, 497.099060, 120.031250 ), Vector( 0, -43, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1083.240967, 69.964584, 272.031250 ), Vector( 0, 156, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1169.342041, -269.378326, 272.031250 ), Vector( 0, 90, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -993.490723, -275.033661, 270.379639 ), Vector( 0, 44, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 356.924500, -301.632568, 268.031250 ), Vector( 0, 134, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 290.749573, 842.356628, 312.002441 ), Vector( 0, -158, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -311.750061, 1044.815918, 268.031250 ), Vector( 0, -141, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1155.968628, 1156.490723, 268.031250 ), Vector( 0, -90, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -883.280029, 1162.784668, 120.031250 ), Vector( 0, -90, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -240.081802, 930.724243, 268.031250 ), Vector( 0, 27, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -2084.957275, 2751.989746, 108.031250 ), Vector( 0, -12, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1386.614014, 2484.838135, 120.031250 ), Vector( 0, -91, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -839.844055, 2281.948730, 108.031250 ), Vector( 0, -123, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 51.807980, 2762.604248, 108.031250 ), Vector( 0, -120, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 384.409210, 3541.517090, 352.031250 ), Vector( 0, 172, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1456.043579, 1948.836304, 132.031250 ), Vector( 0, 0, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 2019.517212, -1416.606567, 184.031250 ), Vector( 0, 94, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 2221.527832, -706.409485, 184.031250 ), Vector( 0, 128, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 2052.701904, -288.052246, 216.031250 ), Vector( 0, -117, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1528.994019, -1407.968628, 184.031250 ), Vector( 0, 90, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1262.789063, -849.055115, 184.031250 ), Vector( 0, -1, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -640.031250, -2167.968750, 272.031250 ), Vector( 0, 89, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1375.968750, -2167.968750, 272.031250 ), Vector( 0, 90, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1014.360962, -2167.968506, 136.031250 ), Vector( 0, 89, 0 ) )

			// militia
			MoveSpawn( "info_spawnpoint_dropship_start_1", Vector( 2260.802490, -1203.198853, 432.031372 ), Vector( 0, 127, 0 ) )
			MoveSpawn( "info_spawnpoint_dropship_start_2", Vector( 1526.455322, -969.324829, 432.031250 ), Vector( 0, 120, 0 ) )

			// imc
			MoveSpawn( "info_spawnpoint_dropship_start_3", Vector( -2670.221924, 300.720947, 384.031281 ), Vector( 0, -8, 0 ) )
			MoveSpawn( "info_spawnpoint_dropship_start_4", Vector( -1360.340210, 2200.135498, 346.235504 ), Vector( 0, -78, 0 ) )
			break

		case "mp_outpost_207":
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 852.031250, 143.968750, -61.968750 ), Vector( 0, -90, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 687.786987, -857.144592, -63.968750 ), Vector( 0, 22, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -813.987854, -869.707520, -61.968750 ), Vector( 0, 112, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1000.031494, -1115.882813, -65.968750 ), Vector( 0, -179, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -650.060242, 92.012398, -63.968750 ), Vector( 0, -109, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 995.456909, -9.251128, -183.968750 ), Vector( 0, -48, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1472.274170, -397.820984, -183.968750 ), Vector( 0, 142, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 2171.296631, -51.316998, -183.968750 ), Vector( 0, -164, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1474.343872, 2159.934570, 0.031250 ), Vector( 0, -89, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 511.777435, 1558.012207, -103.968750 ), Vector( 0, 26, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 683.455383, 2248.577637, -103.968750 ), Vector( 0, -96, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1884.718628, 1607.800537, -55.968750 ), Vector( 0, 30, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1791.698364, 2003.693604, -55.968750 ), Vector( 0, -78, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -986.971252, 1161.800537, -55.968750 ), Vector( 0, 98, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1361.358154, 1173.075806, -55.968750 ), Vector( 0, 73, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1223.690063, 2928.463867, -23.968750 ), Vector( 0, -74, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 2612.384766, 1627.353638, -189.968750 ), Vector( 0, -10, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 3775.918457, 835.534546, -157.968750 ), Vector( 0, -150, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 3232.020752, 536.502441, -189.968750 ), Vector( 0, 77, 0 ) )

			if ( GAMETYPE == CAPTURE_POINT )
			{
				// militia
				MoveSpawn( "info_spawnpoint_dropship_start_11", Vector( -2664.739990, -1232.069946, -162.684998 ), Vector( 0, 24, 0 ) )
				MoveSpawn( "info_spawnpoint_dropship_start_12", Vector( -2866.649902, 918.487000, -155.966995 ), Vector( 0, -10.5, 0 ) )

				// imc
				MoveSpawn( "info_spawnpoint_dropship_start_10", Vector( 1775.547974, -43.144127, 88.031250 ), Vector( 0, 100, 0 ) )
				MoveSpawn( "info_spawnpoint_dropship_start_4", Vector( 3122.902832, 1255.629517, 108.031250 ), Vector( 0, 195, 0 ) )
			}
			else
			{
				// imc
				MoveSpawn( "info_spawnpoint_dropship_start_13", Vector( 1775.547974, -43.144127, 88.031250 ), Vector( 0, 100, 0 ) )
				MoveSpawn( "info_spawnpoint_dropship_start_17", Vector( 3122.902832, 1255.629517, 108.031250 ), Vector( 0, 195, 0 ) )
			}
			break

		case "mp_rise":
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -6376.154297, -1513.355591, 746.032593 ), Vector( 0, 89, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -6465.447754, -136.031387, 739.031250 ), Vector( 0, 0, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -4279.950195, -604.581787, 519.597168 ), Vector( 0, 0, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -4253.959473, 64.423790, 520.031250 ), Vector( 0, -36, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1881.947388, -82.277687, 648.031250 ), Vector( 0, -172, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1858.257935, -736.753723, 648.934448 ), Vector( 0, -146, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -3329.920410, -1400.575073, 776.031250 ), Vector( 0, 20, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1823.969238, 127.084023, 544.031250 ), Vector( 0, 0, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1603.854370, -201.912506, 544.031250 ), Vector( 0, 37, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -736.582520, 124.659790, 544.031250 ), Vector( 0, -157, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -711.312500, -639.968567, 544.031250 ), Vector( 0, 179, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -2352.031494, 747.306396, 544.031250 ), Vector( 0, -179, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -2415.321533, 917.826111, 542.031250 ), Vector( 0, 5, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -2042.505005, 702.189453, 544.031250 ), Vector( 0, -21, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -233.183746, 1015.417725, 544.031250 ), Vector( 0, 114, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -484.617859, 1682.659912, 544.031250 ), Vector( 0, 15, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -485.518524, 2340.956299, 544.031250 ), Vector( 0, -43, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 168.031525, 1045.525391, 544.031250 ), Vector( 0, 0, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 547.426575, 1063.968506, 544.031250 ), Vector( 0, 0, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1505.250977, 110.549080, 545.031250 ), Vector( 0, 99, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 3378.741455, 1293.194580, 544.031250 ), Vector( 0, 179, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 3381.506348, 945.171387, 583.502441 ), Vector( 0, -179, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -79.907616, -80.043327, 546.834045 ), Vector( 0, 0, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 764.419739, -1060.341553, 514.923218 ), Vector( 0, 41, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 2215.224365, -485.112457, 514.923340 ), Vector( 0, -89, 0 ) )
			break

		case "mp_training_ground":
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -580.137329, 264.214233, 456.031250 ), Vector( 0, -129, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 871.234924, -263.764465, 456.031250 ), Vector( 0, 59, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 2489.278076, 2183.503906, 204.031265 ), Vector( 0, 31, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1439.737549, 2933.404541, 204.031250 ), Vector( 0, 140, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1561.583008, 2925.530273, 204.031250 ), Vector( 0, 132, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1666.183350, 1626.565308, 204.031250 ), Vector( 0, -94, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -2468.971924, -2264.516113, 204.031235 ), Vector( 0, 121, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1476.480103, -2957.969482, 204.031250 ), Vector( 0, -23, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 879.104004, 253.857803, 456.626740 ), Vector( 0, -83, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -645.296875, -265.127655, 456.031250 ), Vector( 0, 88, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1646.577881, 1332.318481, 144.031250 ), Vector( 0, 132, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1646.384644, 1629.905151, 144.031250 ), Vector( 0, -137, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -2000.540405, 1665.006226, 144.031250 ), Vector( 0, -92, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1635.698242, 1375.881592, 280.031250 ), Vector( 0, 137, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1125.430664, 3210.460938, 280.031250 ), Vector( 0, -48, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1111.298706, 2897.593262, 144.031250 ), Vector( 0, 44, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1518.721191, 3214.689697, 144.031250 ), Vector( 0, 179, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 2790.072754, 1936.770752, 144.031250 ), Vector( 0, 178, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 2796.426270, -3214.286865, 144.031250 ), Vector( 0, -170, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1452.575195, -2884.891357, 144.031250 ), Vector( 0, -33, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1395.930420, -3194.523193, 144.031250 ), Vector( 0, -1, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1541.215576, -2865.562256, 280.031250 ), Vector( 0, -30, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -111.112617, -1365.745117, 145.031250 ), Vector( 0, -63, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -167.531311, -2172.736084, 144.031250 ), Vector( 0, -24, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1622.021973, -1376.069458, 294.915466 ), Vector( 0, -2, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1641.654663, -1577.254272, 280.031250 ), Vector( 0, 72, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -285.419037, -3356.958984, 144.031250 ), Vector( 0, -5, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1473.342285, -2944.853027, 144.031250 ), Vector( 0, -53, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1147.252686, -3166.470703, 280.031250 ), Vector( 0, 124, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -2790.296875, -2308.171631, 144.031250 ), Vector( 0, 1, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 298.403137, 3355.949463, 144.031250 ), Vector( 0, 177, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 2499.340820, 2317.993652, 144.031250 ), Vector( 0, -22, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1162.703491, -2895.614502, 144.031250 ), Vector( 0, -116, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1477.357300, 2888.122559, 144.031250 ), Vector( 0, 133, 0 ) )

			if ( GAMETYPE == CAPTURE_POINT )
			{
				// militia
				MoveSpawn( "info_spawnpoint_dropship_start_9", Vector( -1727.022217, 3120.413086, 340.031250 ), Vector( 0, -124, 0 ) )
				MoveSpawn( "info_spawnpoint_dropship_start_3", Vector( -69.382553, 2241.753662, 332.031250 ), Vector( 0, -81, 0 ) )

				// imc
				MoveSpawn( "info_spawnpoint_dropship_start_2", Vector( 93.601540, -2253.200195, 332.031250), Vector( 0, 89, 0 ) )
				MoveSpawn( "info_spawnpoint_dropship_start_8", Vector( 1691.411865, -3150.613770, 340.031250 ), Vector( 0, 51, 0 ) )
			}
			else
			{
				// militia
				MoveSpawn( "info_spawnpoint_dropship_start_4", Vector( -1727.022217, 3120.413086, 340.031250 ), Vector( 0, -124, 0 ) )
				MoveSpawn( "info_spawnpoint_dropship_start_10",	Vector( -69.382553, 2241.753662, 332.031250 ), Vector( 0, -81, 0 ) )

				// imc
				MoveSpawn( "info_spawnpoint_dropship_start_1", Vector( 93.601540, -2253.200195, 332.031250), Vector( 0, 89, 0 ) )
				MoveSpawn( "info_spawnpoint_dropship_start_7", Vector( 1691.411865, -3150.613770, 340.031250 ), Vector( 0, 51, 0 ) )
			}
			break

		case "mp_haven":
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 3315.121582, 4102.052246, 280.031250 ), Vector( 0, -133, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 2629.117676, 4123.416504, 284.031250 ), Vector( 0, -84, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 2859.343018, 2879.807129, 280.031250 ), Vector( 0, -157, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 3013.110107, 2725.354004, 280.031250 ), Vector( 0, -115, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 2066.721924, 2663.431885, 313.417572 ), Vector( 0, 162, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1619.568604, 2870.914307, 280.031250 ), Vector( 0, -72, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 2782.099365, 1887.093140, 313.417572 ), Vector( 0, -100, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 2988.499512, 1472.641357, 280.031250 ), Vector( 0, 151, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 3223.186768, 1071.464355, 320.031250 ), Vector( 0, -95, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 3536.533936, 795.676086, 317.672852 ), Vector( 0, -145, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 3930.475586, 63.628136, 324.031250 ), Vector( 0, -142, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 3340.714844, -114.615730, 328.031250 ), Vector( 0, -39, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 3563.320557, -475.350708, 324.031250 ), Vector( 0, 95, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 2151.917725, -669.125793, 233.031250 ), Vector( 0, -92, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 2152.668701, -1373.391602, 233.031250 ), Vector( 0, 91, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1950.637695, -657.272095, 409.031250 ), Vector( 0, 82, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1381.266846, -579.901245, 282.031250 ), Vector( 0, 9, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1109.168335, 583.257629, 381.749329 ), Vector( 0, 6, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1120.258179, 1476.270996, 381.749298 ), Vector( 0, -6, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 600.761475, 1576.425171, 232.031250 ), Vector( 0, 90, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 630.189392, 2449.083496, 232.031250 ), Vector( 0, -77, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1118.492554, 1465.045898, 232.031250 ), Vector( 0, 12, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1386.987183, 825.405029, 232.031250 ), Vector( 0, -1, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 0.036461, 1062.389404, 208.031250 ), Vector( 0, 0, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -93.910858, 1037.374390, 208.031250 ), Vector( 0, 107, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -806.511169, 1037.390381, 145.031250 ), Vector( 0, -2, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -820.406006, -839.744812, 192.031250 ), Vector( 0, 123, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1300.452515, -727.078857, 192.031250 ), Vector( 0, 11, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -55.752178, 2451.011719, 242.633270 ), Vector( 0, -38, 0 ) )

			MoveSpawn( "info_spawnpoint_dropship_start_3", Vector( 401.512939, -2809.902344, 233.671036 ), Vector( 0, 16, 0 ) )
			MoveSpawn( "info_spawnpoint_dropship_start_4", Vector( 400.800323, -3007.707764, 224.031250 ), Vector( 0, 161, 0 ) )
			MoveSpawn( "info_spawnpoint_dropship_start_5", Vector( 4138.300781, 3570.318115, 432.672272 ), Vector( 0, 171, 0 ) )
			MoveSpawn( "info_spawnpoint_dropship_start_6", Vector( 3046.927246, 3962.729492, 280.031250 ), Vector( 0, -133, 0 ) )

			break

		case "mp_backwater":
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 4040.761230, -2370.656006, 360.031250 ), Vector( 0, 162, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 4057.242188, -2703.772705, 360.031250 ), Vector( 0, -173, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 2344.414063, -3235.626953, 344.031250 ), Vector( 0, 95, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 2189.149902, -2715.558594, 400.031250 ), Vector( 0, -72, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 2407.470459, -3249.504639, 544.031250 ), Vector( 0, 144, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1632.351074, -2311.289063, 674.031250 ), Vector( 0, -51, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 902.057129, -2728.813965, 564.031250 ), Vector( 0, -23, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1249.578369, -2356.712891, 560.000427 ), Vector( 0, -56, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1647.212280, -2311.372559, 552.031250 ), Vector( 0, 98, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 2175.571289, -1681.959229, 336.031250 ), Vector( 0, -32, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 2281.422852, -1928.231323, 336.031250 ), Vector( 0, 85, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1854.607056, -1214.869751, 347.242798 ), Vector( 0, -91, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1508.765625, -1820.973877, 552.031250 ), Vector( 0, -113, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 941.816162, -2616.040771, 393.631256 ), Vector( 0, -90, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 788.596436, -2453.486084, 325.905731 ), Vector( 0, -155, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 758.831970, -3136.552734, 356.031250 ), Vector( 0, -144, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1069.670288, -2728.690918, 428.368439 ), Vector( 0, -43, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1074.342041, -3059.097412, 425.982574 ), Vector( 0, 8, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1659.129150, -3957.799072, 402.031250 ), Vector( 0, 31, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 2.533875, -1842.957031, 510.031250 ), Vector( 0, 11, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1131.859375, -2637.865967, 805.031250 ), Vector( 0, 142, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1491.416870, -2249.701172, 328.031250 ), Vector( 0, -115, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1267.230957, -2476.107422, 328.031250 ), Vector( 0, 62, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1387.781250, -2100.641357, 428.031250 ), Vector( 0, -111, 0 ) )

			MoveSpawn( "info_spawnpoint_dropship_start_1", Vector( -478.431000, -1983.400635, 344.893250 ), Vector( 0, -20, 0 ) )
			MoveSpawn( "info_spawnpoint_dropship_start_4", Vector( -656.085327, -2944.954102, 403.096710 ), Vector( 0, -5, 0 ) )
			MoveSpawn( "info_spawnpoint_dropship_start_2", Vector( 3665.218750, -2092.219971, 426.677765 ), Vector( 0, 172, 0 ) )
			MoveSpawn( "info_spawnpoint_dropship_start_3", Vector( 3802.989014, -2722.978271, 360.031250 ), Vector( 0, 169, 0 ) )
			break

		case "mp_harmony_mines":
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -3053.168701, 2053.368652, 450.031250 ), Vector( 0, -81, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -3246.716064, 2074.721924, 448.031250 ), Vector( 0, -57, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -4532.136230, 2179.438721, 376.031250 ), Vector( 0, -56, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -4022.926270, 2203.614258, 376.031250 ), Vector( 0, -78, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -5247.695801, 697.742798, 360.031250 ), Vector( 0, -50, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -5258.554199, 264.245819, 360.031250 ), Vector( 0, 27, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -3835.135986, 54.918797, 473.943695 ), Vector( 0, -16, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -2983.123535, 739.377991, 380.031250 ), Vector( 0, -145, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -2982.557373, 538.800415, 380.031250 ), Vector( 0, 148, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -2642.191162, -90.774879, 368.031250 ), Vector( 0, 42, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1834.917236, -6.631280, 368.031250 ), Vector( 0, -154, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1599.968628, 752.472412, 368.031250 ), Vector( 0, 7, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -935.195923, 895.786804, 368.031250 ), Vector( 0, -151, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1860.426147, -45.142124, 512.031250 ), Vector( 0, 152, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1428.593872, 833.904114, 868.031250 ), Vector( 0, 44, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1504.245361, -858.161438, 512.031250 ), Vector( 0, -14, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1747.878418, -917.032227, 368.031250 ), Vector( 0, 173, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1747.397461, -1104.521240, 366.031250 ), Vector( 0, -49, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1230.911011, -1328.536255, 368.031250 ), Vector( 0, -179, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -2174.968506, -1574.497803, 452.031250 ), Vector( 0, 53, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -2403.447021, -1875.523560, 512.031250 ), Vector( 0, 41, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1870.266602, -2746.317139, 440.031250 ), Vector( 0, 9, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1042.076538, -1944.880005, 368.031250 ), Vector( 0, -90, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1016.292847, -2687.351074, 296.031250 ), Vector( 0, 95, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -624.880798, -2836.326660, 395.615112 ), Vector( 0, -116, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1313.788330, -2800.041748, 368.031250 ), Vector( 0, -90, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -907.953430, -4074.602783, 328.031250 ), Vector( 0, -170, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1401.765137, -4477.748535, 480.031250 ), Vector( 0, 99, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1783.850708, -5530.604492, 480.031250 ), Vector( 0, 161, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -2345.060303, -5535.665527, 480.216095 ), Vector( 0, 69, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -2634.212402, -3633.686523, 336.031250 ), Vector( 0, 0, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -2469.232422, -4464.462402, 768.031250 ), Vector( 0, 141, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -3624.538330, -4149.050781, 590.246277 ), Vector( 0, 52, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -4131.340820, -3625.470459, 590.246277 ), Vector( 0, 7, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -3999.830322, -2113.367676, 464.031250 ), Vector( 0, 91, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -3885.201904, -2203.732178, 320.031250 ), Vector( 0, 58, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -3798.209961, -1762.132568, 320.031250 ), Vector( 0, -82, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -4067.716064, 146.779709, 568.031250 ), Vector( 0, -88, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -2762.643066, 26.962189, 368.031250 ), Vector( 0, -84, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -769.721313, -1569.130859, 512.031250 ), Vector( 0, 48, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -48.396263, -134.040375, 544.031250 ), Vector( 0, 179, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -420.996857, -941.848572, 368.031250 ), Vector( 0, 14, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 186.018143, -1000.708252, 368.031250 ), Vector( 0, 143, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 107.274658, 230.353134, 368.031250 ), Vector( 0, 179, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 99.752403, 394.036438, 368.031250 ), Vector( 0, 76, 0 ) )

			// imc
			MoveSpawn( "info_spawnpoint_dropship_start_3", Vector( -1532.574463, -3636.939453, 700.031250 ), Vector( 0, 170.0, 0 ) )
			MoveSpawn( "info_spawnpoint_dropship_start_4", Vector( -644.845276, -2809.126465, 459.015137 ), Vector( 0, 156.0, 0 ) )

			// militia
			MoveSpawn( "info_spawnpoint_dropship_start_1", Vector( -1168.801270, 883.169678, 572.031250 ), Vector( 0, -136.0, 0 ) )
			MoveSpawn( "info_spawnpoint_dropship_start_2", Vector( -1548.686035, 1259.402344, 572.031250 ), Vector( 0, -172.0, 0 ) )

			if ( GAMETYPE == CAPTURE_THE_FLAG )
			{
				local militiaFlag = GetFlagSpawnPoint( TEAM_MILITIA )
				militiaFlag.SetOrigin( Vector(-1913.392334, 216.284622, 368.031250) )

				local imcFlag = GetFlagSpawnPoint( TEAM_IMC )
				imcFlag.SetOrigin( Vector(-2148.124268, -4546.401367, 480.216095) )
				imcFlag.SetAngles( Vector( 0, 70, 0 ) )
			}
			break

		case "mp_sandtrap":
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -752.445435, -4935.423340, 224.282318 ), Vector( 0, 136, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1070.812012, -5436.780762, 64.031250 ), Vector( 0, 25, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -615.615479, -5415.234863, 64.031250 ), Vector( 0, 109, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1077.306274, -4923.520508, 64.031250 ), Vector( 0, -27, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1645.118042, -4151.067383, 256.031250 ), Vector( 0, -178, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -2610.004883, -4479.203125, 192.031250 ), Vector( 0, -143, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1206.740479, -4259.541992, 256.781494 ), Vector( 0, -88, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 457.206299, -3390.804688, 224.221268 ), Vector( 0, 52, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 189.743713, -2850.601318, 224.031250 ), Vector( 0, 20, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 601.406616, -2436.939697, 224.031250 ), Vector( 0, 177, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 836.007263, -1222.479004, 256.031250 ), Vector( 0, -167, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 840.737244, -628.263550, 256.031250 ), Vector( 0, -157, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 858.255798, -545.879456, 256.031250 ), Vector( 0, 149, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 859.968506, 233.089630, 256.031250 ), Vector( 0, -89, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 842.440796, 657.495178, 256.031250 ), Vector( 0, -168, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 840.941345, 304.099823, 256.031250 ), Vector( 0, 125, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 699.401672, 754.522644, 256.031250 ), Vector( 0, 155, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 651.269287, 599.551270, 112.031250 ), Vector( 0, 160, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 459.845673, 400.192657, 112.031250 ), Vector( 0, 114, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 111.964035, 918.835571, 112.031250 ), Vector( 0, -179, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -538.730896, 882.241211, 112.031250 ), Vector( 0, -75, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1392.817505, 1302.209106, 144.031250 ), Vector( 0, 74, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1074.031372, 1225.744385, 144.031250 ), Vector( 0, -90, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -2699.528564, 1473.766479, 160.031250 ), Vector( 0, -123, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -4445.968750, 1482.248291, 160.031250 ), Vector( 0, -30, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -4441.158203, 943.439819, 160.031250 ), Vector( 0, 20, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -5341.677734, -1907.952271, 200.031250 ), Vector( 0, 8, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -4862.353027, -1900.420532, 256.735168 ), Vector( 0, -66, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -5011.521973, -2326.677246, 144.031250 ), Vector( 0, -3, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1824.031250, -1847.735840, 160.780823 ), Vector( 0, -179, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -2709.137939, -1926.641724, 160.780838 ), Vector( 0, 17, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1472.859985, -4017.342529, 124.667015 ), Vector( 0, 25, 0 ) )

			MoveSpawn( "info_spawnpoint_dropship_start_3", Vector( -1447.437866, 1002.333374, 320.031250 ), Vector( 0, -102, 0 ) )
			MoveSpawn( "info_spawnpoint_dropship_start_4", Vector( -1879.750488, 1011.664185, 320.031250 ), Vector( 0, -45, 0 ) )
			MoveSpawn( "info_spawnpoint_dropship_start_1", Vector( -949.808655, -5281.473633, 224.588196 ), Vector( 0, 81, 0 ) )
			MoveSpawn( "info_spawnpoint_dropship_start_2", Vector( -2816.743408, -4348.377930, 192.031250 ), Vector( 0, 79, 0 ) )
			break

		case "mp_runoff":
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 183.343353, 1335.968506, 536.031250 ), Vector( 0, -89, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -618.237732, 1073.811890, 400.031250 ), Vector( 0, 136, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -2016.865723, 1100.127563, 400.031250 ), Vector( 0, 37, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1607.837280, -1714.454834, 448.031250 ), Vector( 0, -143, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1511.968506, -1878.269897, 528.031250 ), Vector( 0, -179, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1162.145874, -1989.329712, 528.031250 ), Vector( 0, -163, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 505.686005, -2781.347168, 512.031250 ), Vector( 0, -105, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 270.954498, -3369.566162, 400.031250 ), Vector( 0, -157, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -69.136574, -3360.031494, 400.031250 ), Vector( 0, -90, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -444.677338, -3809.557129, 400.031250 ), Vector( 0, 147, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -878.295776, -3379.499268, 392.031250 ), Vector( 0, -14, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 463.813049, -2107.773193, 512.031250 ), Vector( 0, -124, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -2637.691162, -2170.584961, 512.031250 ), Vector( 0, 89, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -2926.562500, -2174.299316, 384.031250 ), Vector( 0, 70, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -2698.142822, -1819.319824, 512.031250 ), Vector( 0, -2, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1552.031372, -1854.389038, 512.031250 ), Vector( 0, 89, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1905.190918, -1425.299683, 512.031250 ), Vector( 0, -48, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1344.031372, -257.663391, 512.031250 ), Vector( 0, 179, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -1887.968628, -452.781982, 512.031250 ), Vector( 0, 0, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -2691.676025, -311.588409, 512.031250 ), Vector( 0, -17, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -2600.113525, 29.215593, 512.031250 ), Vector( 0, -171, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( -2908.825684, -188.880859, 384.031250 ), Vector( 0, 52, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1383.968750, -144.032257, 536.031250 ), Vector( 0, 179, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1470.577271, -383.615662, 536.031250 ), Vector( 0, 147, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 1511.968506, -29.011820, 448.031250 ), Vector( 0, -89, 0 ) )
			CreateNewSpawnPoint( infoSpawnpointHuman, Vector( 659.710571, 598.054199, 536.031250 ), Vector( 0, 99, 0 ) )

			MoveSpawn( "info_spawnpoint_dropship_start_3", Vector( -1070.811646, 1166.325439, 536.031250 ), Vector( 0, -91, 0 ) )
			MoveSpawn( "info_spawnpoint_dropship_start_4", Vector( -1725.968750, 1183.646973, 536.031250 ), Vector( 0, -90, 0 ) )
			MoveSpawn( "info_spawnpoint_dropship_start_1", Vector( 98.213234, -3542.985596, 548.725464 ), Vector( 0, 74, 0 ) )
			MoveSpawn( "info_spawnpoint_dropship_start_2", Vector( -666.602173, -3538.318115, 544.031250 ), Vector( 0, 77, 0 ) )
			break
	}

	FlagSet( "SafeSpawnpointsInitialized" )
}