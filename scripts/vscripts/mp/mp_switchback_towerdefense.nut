// NOTE this gets run on both client and server!
function main()
{
	Assert( GAMETYPE == COOPERATIVE )
	Switchback_SetupRoutesAndPositions()

	Switchback_SetupWaveSpawns()
	//TestWaves()

	  if ( IsServer() )
    SetCustomWaveSpawn_SideView( Vector( -2640, 2105, 1344 ), Vector( 0, -135, 0 ) )

}

function Switchback_SetupRoutesAndPositions()
{
	if ( !IsServer() )
		return

		SetCustomPlayerDropshipSpawn( TEAM_MILITIA, Vector( -3501, 1562, 300 ), Vector( 0, -20, 0 ) )

		local trapRoute = [ Vector( 3859, 2217, 832 ),  Vector( -34, 3145, 1408 ), Vector( -2781, 1861, 640 ) ]
		TowerDefense_AddRoute( trapRoute )

		local centerRoute = [ Vector( 3859, 2217, 832 ),  Vector( -1273, 1648, 638 ), Vector( -2426, 1821, 637 ) ]
		TowerDefense_AddRoute( centerRoute )

		local dirtRoute = [ Vector( 3639, -2, 826 ), Vector ( -2617, 181, 266 ), Vector ( -2661, 1446, 629 ) ]
		TowerDefense_AddRoute( dirtRoute )

		local harborRoute = [ Vector( 1241, -1708, -138 ), Vector( -962, -1394, -126 ), Vector( -2645, 152, 266 ), Vector( -2676, 1407, 629 ) ]
		TowerDefense_AddRoute( harborRoute )

		local leftcloseRoute = [ Vector( -337, 2139, 640 ), Vector( -2574, 1749, 640 )]
		TowerDefense_AddRoute( leftcloseRoute, "leftcloseRoute", false )

		local rightcloseRoute = [ Vector( -1598, -1602, -123 ), Vector( -2673, 1435, 629 )]
		TowerDefense_AddRoute( rightcloseRoute, "rightcloseRoute", false )

		local centercloseRoute = [ Vector( 665, 1192, 440 ), Vector( -2574, 1749, 640 )]
		TowerDefense_AddRoute( centercloseRoute, "centercloseRoute", false )

		TowerDefense_AddGeneratorLocation( Vector( -3125, 1399, 640 ), Vector( 0, 0, 0 ) )

	AddLoadoutCrate( level.nv.attackingTeam, Vector( -2444, -682, 256 ), Vector( 0, -90, 0 ) )
	AddLoadoutCrate( level.nv.attackingTeam, Vector( -2448, 2496, 640 ), Vector( 0, 0, 0 ) )
//	AddLoadoutCrate( level.nv.attackingTeam, Vector( -2970, 2470, 425 ), Vector( 0, -103, 0 ) )

	AddStationaryTitanPosition( Vector( 2594, 3048, 908 ) )
	AddStationaryTitanPosition( Vector( 3459, 2749, 855 ) )
	AddStationaryTitanPosition( Vector( 1995, 2311, 895 ) )
	AddStationaryTitanPosition( Vector( 4250, 2036, 832 ) )
	AddStationaryTitanPosition( Vector( 4422, 1538, 841 ) )
	AddStationaryTitanPosition( Vector( 3784, 1415, 832 ) )
	AddStationaryTitanPosition( Vector( 3763, 916, 832 ) )
	AddStationaryTitanPosition( Vector( 3746, 13, 826 ) )
	AddStationaryTitanPosition( Vector( -376, -1835, -123 ) )

	TowerDefense_AddSniperLocation( Vector( -2740, 2109, 1040 ), 	-90 		)
	TowerDefense_AddSniperLocation( Vector( -2065, 987, 704 ), 		-112 		)
	TowerDefense_AddSniperLocation( Vector( -384, -208, 528 ), 	180 			)
	TowerDefense_AddSniperLocation( Vector( -383, -37, 528 ), 		180 		)
	TowerDefense_AddSniperLocation( Vector( -530, 328, 704 ), 	-174 			)
	TowerDefense_AddSniperLocation( Vector( 1150, 1608, 1195 ), 		-140	)
	TowerDefense_AddSniperLocation( Vector( 1204, 1162, 740 ), 	-140 			)
	TowerDefense_AddSniperLocation( Vector( 425, 1458, 776 ), 		-177	 	)
	TowerDefense_AddSniperLocation( Vector( -3252, 2186, 1040 ), 		-77 	)
	TowerDefense_AddSniperLocation( Vector( -2109, 2346, 1200 ), 	-104 		)
	TowerDefense_AddSniperLocation( Vector( -743, -44, 256 ), 	178 			)

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
/*
	local wave = TowerDefense_AddWave( "name_gruntwork" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad )

	local wave = TowerDefense_AddWave()
	Wave_AddSpawn( wave, TD_SpawnGruntSquad )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad )

	local wave = TowerDefense_AddWave( "name_machinewar" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad )
*/
	local wave = TowerDefense_AddWave()
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquadDroppod )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquadDroppod )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquadDroppod )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquadDroppod )
}

function Switchback_SetupWaveSpawns()
{
	if ( IsClient() )
		return

	//Rise waves
	CommonWave_RiseHC()

}