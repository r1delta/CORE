// NOTE this gets run on both client and server!
function main()
{
	Assert( GAMETYPE == COOPERATIVE )
	Haven_SetupRoutesAndPositions()

	Haven_SetupWaveSpawns()
	//TestWaves()

  if ( IsServer() )
    SetCustomWaveSpawn_SideView( Vector( 2380, 1569, 650 ), Vector( 0, 147, 0 ) )

	//set the custom wave spawn anim
	//if ( IsServer() )
    //	SetCustomWaveSpawn_SideView( optionalOrigin, optionalAngles )
}

function Haven_SetupRoutesAndPositions()
{
	if ( !IsServer() )
		return

		SetCustomPlayerDropshipSpawn( TEAM_MILITIA, Vector( 2471, 1529, -50 ), Vector( 0, 160, 0 ), Vector( 2165, 1248, 64 ), Vector( 0, 95, 0 ) )

		local oneRoute = [ Vector( -1961, 3556, -183 ), Vector( 1875, 1582, 72 ) ]
		TowerDefense_AddRoute( oneRoute )

		local twoRoute = [ Vector( -1367, -2252, -191 ),  Vector( 2448, -1680, -191 ),  Vector( 2130, 1321, 64 ) ]
		TowerDefense_AddRoute( twoRoute, "twoRoute" )

		local threeRoute = [ Vector( -1796, 195, -191 ), Vector ( 2212, 426, 64 ) ]
		TowerDefense_AddRoute( threeRoute )

		local fourRoute = [ Vector( -2733, 1423, -186 ), Vector ( 357, 2940, 64 ),  Vector( 1850, 1610, 72 ) ]
		TowerDefense_AddRoute( fourRoute, "fourRoute" )

		local leftcloseRoute = [ Vector( 2720, -993, -160 ), Vector( 2168, 1310, 64 ) ]
		TowerDefense_AddRoute( leftcloseRoute, "leftcloseRoute", false )

		local rightcloseRoute = [ Vector( 290, 3166, 64 ), Vector( 1934, 1557, 72 ) ]
		TowerDefense_AddRoute( rightcloseRoute, "rightcloseRoute", false )

		local centercloseRoute = [ Vector( 725, 17, -262 ), Vector( 2139, 847, 64 ), Vector( 2166, 1290, 64 ) ]
		TowerDefense_AddRoute( centercloseRoute, "centercloseRoute", false )


		TowerDefense_AddGeneratorLocation( Vector( 2107, 1762, 64 ), Vector( 0, 0, 0 ) )

	AddLoadoutCrate( level.nv.attackingTeam, Vector( 1930, 2586, 280 ), Vector( 0, 75, 0 ) )
	AddLoadoutCrate( level.nv.attackingTeam, Vector( 2500, 1751, 280 ), Vector( 0, 15, 0 ) )
	AddLoadoutCrate( level.nv.attackingTeam, Vector( 1565, 1508, 248 ), Vector( 0, 270, 0 ) )


	AddStationaryTitanPosition( Vector( 1110, -3434, -262 ) )
	AddStationaryTitanPosition( Vector( -427, -2731, -176 ) )
	AddStationaryTitanPosition( Vector( -1727, 3481, -182 ) )
	AddStationaryTitanPosition( Vector( -2094, 2415, -191 ) )
	AddStationaryTitanPosition( Vector( -3007, 3139, -241 ) )
	AddStationaryTitanPosition( Vector( -153, -2863, -194 ) )



/*	TowerDefense_AddSniperLocation( Vector( -2740, 2109, 1040 ), 	-90 		)
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
*/
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

function Haven_SetupWaveSpawns()
{
	if ( IsClient() )
		return

	//Colony Waves
	CommonWave_Colony_Waves()
}