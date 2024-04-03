// NOTE this gets run on both client and server!
function main()
{
	Assert( GAMETYPE == COOPERATIVE )
	Runoff_SetupRoutesAndPositions()

	Runoff_SetupWaveSpawns()
	//TestWaves()

	  if ( IsServer() )
    SetCustomWaveSpawn_SideView( Vector( -132, -900, 815 ), Vector( 0, 180, 0 ) )

	//set the custom wave spawn anim
	//if ( IsServer() )
    //	SetCustomWaveSpawn_SideView( optionalOrigin, optionalAngles )
}

function Runoff_SetupRoutesAndPositions()
{
	if ( !IsServer() )
		return

		SetCustomPlayerDropshipSpawn( TEAM_MILITIA, Vector( 200, -1104, 250 ), Vector( 0, 180, 0 ), Vector( -263, -2101, 256 ), Vector( 0, 89, 0 ) )

		local northnorth1Route = [ Vector( -1901, -5089, -3 ), Vector( -1940, -1084, 216 ), Vector( -663, -1082, -7 ) ]
		TowerDefense_AddRoute( northnorth1Route )

		local northnorth2Route = [ Vector( -2118, 2601, 8 ), Vector( -1940, -1084, 216 ), Vector( -663, -1082, -7 ) ]
		TowerDefense_AddRoute( northnorth2Route )

		local northwestRoute = [ Vector( -1913, -4735, -7 ), Vector( -276, -1469, 19 ) ]
		TowerDefense_AddRoute( northwestRoute )

		local northeastRoute = [ Vector( -1812, 3002, 0 ),  Vector( -257, -791, -7 ) ]
		TowerDefense_AddRoute( northeastRoute )

		local southwestRoute = [ Vector( -81, -5190, -6 ), Vector ( 1351, -1177, -7 ), Vector ( 18, -1159, 7 ) ]
		TowerDefense_AddRoute( southwestRoute )

		local southeastRoute = [ Vector( 10, 3006, -1 ), Vector ( 1351, -1177, -7 ), Vector ( 18, -1159, 7 ) ]
		TowerDefense_AddRoute( southeastRoute )

		local leftcloseRoute = [ Vector( 728, -3918, -6 ), Vector( -268, -1974, 256 )]
		TowerDefense_AddRoute( leftcloseRoute, "leftcloseRoute", false )

		local rightcloseRoute = [ Vector( -1683, 347, 256 ), Vector( -410, -210, 256 )]
		TowerDefense_AddRoute( rightcloseRoute, "rightcloseRoute", false )

		local centercloseRoute = [ Vector( 1332, -1188, -7 ), Vector( 188, -1178, 10 )]
		TowerDefense_AddRoute( centercloseRoute, "centercloseRoute", false )

		TowerDefense_AddGeneratorLocation( Vector( -247, -1090, 12 ), Vector( 0, 0, 0 ) )

	AddLoadoutCrate( level.nv.attackingTeam, Vector( 152, -1948, 528 ), Vector( 0, 0, 0 ) )
	AddLoadoutCrate( level.nv.attackingTeam, Vector( 842, -164, 534 ), Vector( 0, 270, 0 ) )
	AddLoadoutCrate( level.nv.attackingTeam, Vector( -1067, -921, 512 ), Vector( 0, 180, 0 ) )


	AddStationaryTitanPosition( Vector( -2173, -5132, 1 ) )
	AddStationaryTitanPosition( Vector( -935, -5067, -7 ) )
	AddStationaryTitanPosition( Vector( 582, -5279, 14 ) )
	AddStationaryTitanPosition( Vector( 687, -5192, 8 ) )
	AddStationaryTitanPosition( Vector( 969, 2623, 14 ) )
	AddStationaryTitanPosition( Vector( 93, 2600, 14 ) )
	AddStationaryTitanPosition( Vector( -1089, 3102, 0 ) )
	AddStationaryTitanPosition( Vector( -672, 3140, -0 ) )
	AddStationaryTitanPosition( Vector( -2056, 3035, 7 ) )

	TowerDefense_AddSniperLocation( Vector( -536, -1147, 256 ), 	0	)
	TowerDefense_AddSniperLocation( Vector( -580, -1562, 256 ), 	0	)
	TowerDefense_AddSniperLocation( Vector( -554, -825, 256 ), 	-5 	)
	TowerDefense_AddSniperLocation( Vector( -824, -1094, 520 ), 	0	)
	TowerDefense_AddSniperLocation( Vector( 337, -1425, 534 ), 	0	)
	TowerDefense_AddSniperLocation( Vector( 348, -905, 534 ), 	0	)
	TowerDefense_AddSniperLocation( Vector( -671, 1075, 536 ), 	-77	)
	TowerDefense_AddSniperLocation( Vector( -829, -3430, 544 ), 	70	)
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

function Runoff_SetupWaveSpawns()
{
	if ( IsClient() )
		return

	//Relic waves
	CommonWave_Relic()
}