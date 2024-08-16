
//////////////////////////////////////////////////////////
function GetMapCenter( spawnpoints )
{
	local centerPos = Vector( 0, 0, 0 )
	foreach ( spawnpoint in spawnpoints )
		centerPos += spawnpoint.GetOrigin()
	centerPos *= ( 1.0 / spawnpoints.len() )

	return centerPos
}

//////////////////////////////////////////////////////////
function GetMapDirection( centerPos, startSpawnPoints )
{
	if ( startSpawnPoints.len() == 0 )
		return Vector( 1, 0, 0 )

	local imcCount = 0
	local militiaCount = 0
	local imcCenter = Vector( 0, 0, 0 )
	local militiaCenter = Vector( 0, 0, 0 )
	local dirToIMC = Vector( 1, 0, 0 )
	local dirFromMilitia = Vector( 1, 0, 0 )

	foreach ( startSpawn in startSpawnPoints )
	{
		if ( startSpawn.GetTeam() == TEAM_IMC )
		{
			imcCenter += startSpawn.GetOrigin()
			imcCount++
		}
		else if ( startSpawn.GetTeam() == TEAM_MILITIA )
		{
			militiaCenter += startSpawn.GetOrigin()
			militiaCount++
		}
	}

	if ( imcCount > 0 )
	{
		imcCenter *= 1.0 / imcCount.tofloat()
		dirToIMC = imcCenter - centerPos
		dirToIMC.Normalize()
	}

	if ( militiaCount > 0 )
	{
		militiaCenter *= 1.0 / militiaCount.tofloat()
		dirFromMilitia = centerPos - militiaCenter	// reverse of dirToIMC
		dirFromMilitia.Normalize()
	}

	local mapDir = ( dirFromMilitia + dirToIMC ) * 0.5
	return mapDir	//	vector points away from the IMC side
}

// NOTE this gets run on both client and server!
function CreateDropPodSpawnPoint( origin, angles, team )
{
	/*printt("origin: "+origin)
	return*/
	local ent = CreateEntity( "info_spawnpoint_droppod" )
	ent.SetOrigin( origin )
	ent.SetAngles( angles )
	ent.SetTeam( team )
        ent.s.inUse <- false
	DispatchSpawn( ent )
	return ent
}



function CreateSpawnPoints() {

	// Create info_spawnpoint_droppod entities from hardcoded origins and angles
	local tempSpawnPoints = []
	local spawnData = [
		{ origin = Vector(-686.581177, -848.779053, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(-647.009644, 505.799805, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(-488.776428, 265.791626, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(846.075562, -376.386108, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(-125.405029, 348.742798, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(-785.705261, -1301.537842, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(281.278809, -1347.336182, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(38.429810, 523.467773, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(-610.723633, -370.989380, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(555.893799, -1385.164307, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(-908.803467, -44.777954, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(-788.664429, 353.332520, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(-93.462891, -809.494934, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(-445.220764, -1177.813354, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(405.204712, -238.218506, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(-84.670227, -367.904785, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(-954.335083, -936.406738, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(-312.982361, -430.802002, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(974.430420, 298.592163, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(-960.564575, 278.180664, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(567.820190, -235.548340, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(-594.179321, -707.957764, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(554.078247, -513.168701, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(507.460938, 134.206665, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(1054.999146, -966.174194, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(976.515381, -289.642700, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(-547.711182, -1330.974609, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(-470.470459, -170.511230, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(-390.443237, -1004.588257, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(509.977173, 448.117065, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(-25.622131, -1113.699463, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(-713.934082, -662.324951, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(-859.982117, -708.249939, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(-936.800171, 41.071167, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(403.694336, -783.464172, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(-133.823669, -253.613281, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(870.243042, 234.763062, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(454.053589, 498.487061, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(-909.515869, -311.677979, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(-191.194275, 145.415771, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(-385.990967, -913.304260, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(908.688843, 390.833008, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(-684.619507, -541.756104, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(619.632324, -822.149597, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(484.109985, -1412.542236, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(744.543823, 139.612183, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(-543.825317, -112.233032, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(-818.203918, -1276.747559, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(45.917603, -102.742065, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(314.762573, -567.622681, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(383.259277, -1186.579346, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(944.494263, -1011.019043, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(190.661011, -1202.068237, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(199.384766, -1068.870117, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(904.558472, -899.071533, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(565.448975, -1024.942505, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(-888.711548, 90.595703, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(906.520874, -142.791626, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(-965.955139, 371.774170, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(-55.558716, 434.431152, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(1021.145874, 520.439209, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(65.439941, -414.619751, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(-241.096924, -1366.821411, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(1041.221313, 401.204224, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(620.969849, 395.687012, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(212.141357, -167.753418, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) },
		{ origin = Vector(989.758789, -991.813477, 0.031250), angles = Vector(-0.000000, -153.434952, 0.000000) }
	]

	foreach ( data in spawnData )
	{
		local info_spawnpoint_droppod = CreateDropPodSpawnPoint( data.origin, data.angles, TEAM_ANY )
		tempSpawnPoints.append( info_spawnpoint_droppod )
	}

	// Assign the temporary spawnpoints to the global spawnPointArray
	level.coopTempDropPodSpawnPoints <- tempSpawnPoints

}
function CreateSpawnPointsDebug() {
// Create info_spawnpoint_droppod entities from droppod starts
local spawnPointArray = SpawnPoints_GetDropPodStart( TEAM_ANY )
if ( spawnPointArray.len() > 0 )
{
	local mapCenter = GetMapCenter( spawnPointArray )
	local mapDir = GetMapDirection( mapCenter, spawnPointArray )
	local leftDir = Vector( -mapDir.y, mapDir.x, 0 )
	local flankDist = 2048  // Increased flank distance
	local centerDist = 3072  // New variable to control distance from the center
	leftDir *= flankDist

	local tempSpawnPoints = []
	local numSpawnPoints = RandomInt( 20, 30 )

	for ( local i = 0; i < numSpawnPoints; i++ )
	{
		local randomFlankOffset = Vector( RandomFloat( -flankDist, flankDist ), RandomFloat( -flankDist, flankDist ), 0 )
		local randomCenterOffset = mapDir * RandomFloat( centerDist, centerDist * 1.5 )  // Random offset from the center
		local origin = mapCenter + randomFlankOffset + randomCenterOffset
		local angles = VectorToAngles( mapDir )

		local info_spawnpoint_droppod = CreateDropPodSpawnPoint( origin, angles, TEAM_ANY )
		tempSpawnPoints.append( info_spawnpoint_droppod )
	}

	// Assign the temporary spawnpoints to the global spawnPointArray
	level.coopTempDropPodSpawnPoints <- tempSpawnPoints
}

}
Globalize(CreateSpawnPoints)
Globalize(CreateDropPodSpawnPoint)
function main()
{
	Assert( GAMETYPE == COOPERATIVE )
	if (IsServer()) {
		CreateSpawnPoints() }
	Box_SetupRoutesAndPositions()
        
	Box_SetupWaveSpawns()
	//TestWaves()
    SetCustomIntroLength(0)
	  //if ( IsServer() )
    //SetCustomWaveSpawn_SideView( Vector( -178, -493, 60 ), Vector( 0, 180, 0 ), "dropship_coop_respawn_box" )

	//set the custom wave spawn anim
	//if ( IsServer() )
    //	SetCustomWaveSpawn_SideView( optionalOrigin, optionalAngles )
}

function Box_SetupRoutesAndPositions()
{
	if ( !IsServer() )
		return

		local southwestRoute = [ Vector( -966, -1962, 0 ), Vector( 997, 1083, 0 ) ]
		TowerDefense_AddRoute( southwestRoute )

		local southRoute = [ Vector( 1088, -272, 0 ), Vector ( -1090, -567, 0 ) ]
		TowerDefense_AddRoute( southRoute )

		local southeastRoute = [ Vector( 860, -410, -68 ), Vector ( -850, -356, -68 ) ]
		TowerDefense_AddRoute( southeastRoute )

		local leftcloseRoute = [ Vector( -752, 982, 0 ), Vector( -704 -2142, 0 )]
		TowerDefense_AddRoute( leftcloseRoute, "leftcloseRoute", false )

		local rightcloseRoute = [ Vector( 1022, 1137, 0 ), Vector( 996, -2057, 0 )]
		TowerDefense_AddRoute( rightcloseRoute, "rightcloseRoute", false )

		local centercloseRoute = [ Vector( 129, -2018, 0 ), Vector( -191, 1056, 0 )]
		TowerDefense_AddRoute( centercloseRoute, "centercloseRoute", false )

		TowerDefense_AddGeneratorLocation( Vector( -178, -493, 0 ), Vector( 0, 0, 0 ) )

	AddLoadoutCrate( level.nv.attackingTeam, Vector( 144, 279, 400 ), Vector( 0, 135, 0 ) )
	AddLoadoutCrate( level.nv.attackingTeam, Vector( -161, -1211, 400 ), Vector( 0, 78, 0 ) )
/*
	AddStationaryTitanPosition( Vector( 1240, 3079, -128 ) )
	AddStationaryTitanPosition( Vector( -1104, -3335, -191 ) )
	AddStationaryTitanPosition( Vector( -1515, -3371, -191 ) )
	AddStationaryTitanPosition( Vector( -1833, -2862, -255 ) )
	AddStationaryTitanPosition( Vector( -2454, -2908, -127 ) )
	AddStationaryTitanPosition( Vector( -2965, -2348, -127 ) )
	AddStationaryTitanPosition( Vector( -1897, 3511, -255 ) )
	AddStationaryTitanPosition( Vector( -686, 3628, -255 ) )
	AddStationaryTitanPosition( Vector( -2200, 3597, -255 ) )

	TowerDefense_AddSniperLocation( Vector( -1571, 1474, 112 ), 	-149	)
	TowerDefense_AddSniperLocation( Vector( -1878, 1710, 112 ), 	104	)
	TowerDefense_AddSniperLocation( Vector( -3290, 1109, 328 ), 	144	)
	TowerDefense_AddSniperLocation( Vector( -3306, 1542, 328 ), 	-171	)
	TowerDefense_AddSniperLocation( Vector( -3381, -51, 176 ), 	118	)
	TowerDefense_AddSniperLocation( Vector( -3338, 389, 36 ), 	74	)
	TowerDefense_AddSniperLocation( Vector( -2371, 485, 120 ), 	177	)*/

}


/***************************************************\

	TowerDefense_AddWave 	// creates the wave you will fill with events (spawns, pauses)
	Wave_AddSpawn 			// adds a spawn event to the wave (see spawner legend below)
	Wave_AddPause 			// adds a timed pause to the wave (secs)
	Wave_SetBreakTime 		// sets a custom break time between this wave and the next

					WAVE SPAWNER LEGEND

		TD_SpawnGruntSquad						-> 4 grunts
		TD_SpawnSpectreSquad					-> 4 spectres
		TD_SpawnSuicideSpectreSquad				-> 4 suicide spectres
		TD_SpawnSpectreSquadWithSingleSuicide	-> 3 spectres, 1 suicide spectre ( better option than 4 suicide spectres because they won't clump up )
		TD_SpawnGruntSquadDroppod
		TD_SpawnGruntSquadDropship
		TD_SpawnSpectreSquadDroppod
		TD_SpawnSpectreSquadDropship
		TD_SpawnSuicideSpectreSquadDroppod
		TD_SpawnSuicideSpectreSquadDropship
		TD_SpawnSpectreSquadWithSingleSuicideDroppod
		TD_SpawnSpectreSquadWithSingleSuicideDropship
		TD_SpawnSniper1x						-> 1 sniper spectre ( droppod )
		TD_SpawnSniper2x						-> 2 sniper spectres ( droppod )
		TD_SpawnSniper3x						-> 3 sniper spectres ( droppod )
		TD_SpawnSniper4x						-> 4 sniper spectres ( droppod )
		TD_SpawnTitan							-> 1 random regular titan
		TD_SpawnNukeTitan						-> 1 nuke titan
		TD_SpawnMortarTitan						-> 1 mortar titan
		TD_SpawnCloakedDrone							-> 1 cloak drone

\***************************************************/
function TestWaves()
{
	if ( IsClient() )
		return

	local wave = TowerDefense_AddWave()
	Wave_AddSpawn( wave, TD_SpawnGruntSquad )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad )

	local wave = TowerDefense_AddWave()
	Wave_AddSpawn( wave, TD_SpawnGruntSquad )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad )

	local wave = TowerDefense_AddWave()
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad )

	local wave = TowerDefense_AddWave()
	Wave_AddSpawn( wave, TD_SpawnNukeTitan )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan )
}

function Box_SetupWaveSpawns()
{
	if ( IsClient() )
		return
	CommonWave_Training_Ground_Waves()
}