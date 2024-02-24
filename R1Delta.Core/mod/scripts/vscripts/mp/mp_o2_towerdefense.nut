// NOTE this gets run on both client and server!
function main()
{
	//VERY IMPORTANT: if it's not coop mode - just early out
	if ( GAMETYPE != COOPERATIVE )
		return
		
  	if ( IsServer() )
    SetCustomWaveSpawn_SideView( Vector( -620, -1923, 428 ), Vector( 0, -15, 0 ) )

	o2_SetupRoutesAndPositions()

	o2_SetupWaveNames()

	o2_SetupWaveSpawns()
	//TestWaves()
}

function o2_SetupRoutesAndPositions()
{
	if ( !IsServer() )
		return

	SetCustomPlayerDropshipSpawn( TEAM_MILITIA, Vector( -206, -2979, -8 ), Vector( 0, 141, 0 ), Vector( -1879, -2535, -7 ), Vector( 0, -5, 0 ) )

	local oneRoute = [ Vector( -2576, 2863, -6 ), Vector( -3540, -573, 3 ),  Vector( -1325, -2612, -7 ) ]
	TowerDefense_AddRoute( oneRoute )

	local twoRoute = [ Vector( -2469, 3479, -6 ),  Vector( -1844, 1384, -80 ),  Vector( -1476, -2590, -7 ) ]
	TowerDefense_AddRoute( twoRoute, "twoRoute" )

	local threeRoute = [ Vector( 1753, 2391, -140 ), Vector ( 1805, -1848, -10 ), Vector ( -857, -3128, -8 ) ]
	TowerDefense_AddRoute( threeRoute )

	local fourRoute = [ Vector( -326, 3511, -39 ), Vector ( 1079, 1080, -128 ),  Vector( 1078, -792, -8 ),  Vector( -751, -2669, -7 ) ]
	TowerDefense_AddRoute( fourRoute, "fourRoute" )

	local leftcloseRoute = [ Vector( -3190, -1134, -12 ), Vector( -1299, -3175, -8 )]
	TowerDefense_AddRoute( leftcloseRoute, "leftcloseRoute", false )

	local rightcloseRoute = [ Vector( 1819, 343, -135 ), Vector( -751, -2669, -7 )]
	TowerDefense_AddRoute( rightcloseRoute, "rightcloseRoute", false )

	local centercloseRoute = [ Vector( -356, -635, -13 ), Vector( -1074, -2631, -7 )]
	TowerDefense_AddRoute( centercloseRoute, "centercloseRoute", false )

	TowerDefense_AddGeneratorLocation( Vector( -1074, -2878, -7 ), Vector( 0, 0, 0 ) )

	AddLoadoutCrate( level.nv.attackingTeam, Vector( 1362, -1099, 184 ), Vector( 0, 0, 0 ) )
	AddLoadoutCrate( level.nv.attackingTeam, Vector( -699, -1301, 272 ), Vector( 0, 270, 0 ) )
	AddLoadoutCrate( level.nv.attackingTeam, Vector( -2420, 356, 324 ), Vector( 0, 180, 0 ) )

	AddStationaryTitanPosition( Vector( 2758, 1738, -141 ) )
	AddStationaryTitanPosition( Vector( 826, 1911, -135 ) )
	AddStationaryTitanPosition( Vector( 206, 1535, -128 ) )
	AddStationaryTitanPosition( Vector( -1235, 1521, -62 ) )
	AddStationaryTitanPosition( Vector( -1993, 3704, -45 ) )
	AddStationaryTitanPosition( Vector( -2649, 1448, -6 ) )
	AddStationaryTitanPosition( Vector( -3626, 234, -14 ) )
	AddStationaryTitanPosition( Vector( -3511, -521, 4 ) )
	AddStationaryTitanPosition( Vector( -3532, 2835, -6 ) )
	AddStationaryTitanPosition( Vector( -378, 3687, -41 ) )

	TowerDefense_AddSniperLocation( Vector( 1080, -314, 268 ), 	 -94	)
	TowerDefense_AddSniperLocation( Vector( 588, -306, 268 ), 	 -103	)
	TowerDefense_AddSniperLocation( Vector( -4, -545, 272 ), 	 -92	)
	TowerDefense_AddSniperLocation( Vector( -304, -373, 270 ), 	 -95	)
	TowerDefense_AddSniperLocation( Vector( -700, -540, 272 ), 	 -90	)
	TowerDefense_AddSniperLocation( Vector( -386, -1457, 176 ), 	 -7	)
	TowerDefense_AddSniperLocation( Vector( -695, -1989, 272 ), 	 0	)
	TowerDefense_AddSniperLocation( Vector( 1310, -1424, 372 ), 	-144	)
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

	local wave = TowerDefense_AddWave( name_gruntwork )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad )

	local wave = TowerDefense_AddWave()
	Wave_AddSpawn( wave, TD_SpawnGruntSquad )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad )

	local wave = TowerDefense_AddWave( name_machinewar )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad )

	local wave = TowerDefense_AddWave( name_nukeapoc )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan )
}

function o2_SetupWaveNames()
{
	AddWaveName( "name_spaceship", "Spaceship Broken Parts Needed" )
	AddWaveName( "name_creeper", "The Creeper" )
	AddWaveName( "name_redeye", "Red Eyes" )
	AddWaveName( "name_relocation", "Relocation Swarm" )
	AddWaveName( "name_core", "Core Relations" )
	AddWaveName( "name_failsafe", "The Failsafe" )
}

function o2_SetupWaveSpawns()
{
	if ( IsClient() )
		return

	//Colony Waves
	CommonWave_Colony_Waves()
}
