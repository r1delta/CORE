// NOTE this gets run on both client and server!
function main()
{
	Assert( GAMETYPE == COOPERATIVE )
	Backwater_SetupRoutesAndPositions()

	Backwater_SetupWaveSpawns()
	//TestWaves()

  if ( IsServer() )
    SetCustomWaveSpawn_SideView( Vector( 91, -934, 300 ), Vector( 0, 45, 0 ) )

	//set the custom wave spawn anim
	//if ( IsServer() )
    //	SetCustomWaveSpawn_SideView( optionalOrigin, optionalAngles )
}

function Backwater_SetupRoutesAndPositions()
{
	if ( !IsServer() )
		return

    	SetCustomPlayerDropshipSpawn( TEAM_MILITIA, Vector( 747, 45, -101 ), Vector( 0, 0, 0 ), Vector( 2177, 230, -134 ), Vector( 0, -142, 0 ) )

		local oneRoute = [ Vector( 5153, -2239, 97 ), Vector( 1616, 55, -95 ) ]
		TowerDefense_AddRoute( oneRoute )

		//left side from hill, down center
		local twoRoute = [ Vector( 2522, -3763, 110 ),  Vector( 1960, -2400, 538 ),  Vector( 1386, -1494, 256 ),  Vector( 1398, -957, 88 ) ]
		TowerDefense_AddRoute( twoRoute, "twoRoute" )

		//right side
		local threeRoute = [ Vector( -1985, -1339, 184 ), Vector ( -315, -119, -147 ), Vector ( 1052, 55, -91 ) ]
		TowerDefense_AddRoute( threeRoute )

		//right side through town, down center
		local fourRoute = [ Vector( -1592, -5499, -182 ), Vector ( -1561, -3388, 70 ),  Vector( -1100, -2091, 140 ),  Vector( 252, -2097, 118 ),  Vector( 1399, -1478, 256 ),  Vector( 1389, -1042, 122 ) ]
		TowerDefense_AddRoute( fourRoute, "fourRoute" )

		local leftcloseRoute = [ Vector( 3483, -44, -184 ), Vector( 1616, 55, -95 )]
		TowerDefense_AddRoute( leftcloseRoute, "leftcloseRoute", false )

		local rightcloseRoute = [ Vector( -214, -345, -163 ), Vector( 1059, 66, -91 )]
		TowerDefense_AddRoute( rightcloseRoute, "rightcloseRoute", false )

		local centercloseRoute = [ Vector( 1379, -1654, 554 ), Vector( 1377, -38, -91 )]
		TowerDefense_AddRoute( centercloseRoute, "centercloseRoute", false )


		TowerDefense_AddGeneratorLocation( Vector( 1430, -256, -91 ), Vector( 0, -180, 0 ) )

	AddLoadoutCrate( level.nv.attackingTeam, Vector( 1656, 780, 40 ), Vector( 0, 270, 0 ) )
	AddLoadoutCrate( level.nv.attackingTeam, Vector( 1553, -1902, 552 ), Vector( 0, 180, 0 ) )
	AddLoadoutCrate( level.nv.attackingTeam, Vector( 1108, -245, -95 ), Vector( 0, 180, 0 ) )


	AddStationaryTitanPosition( Vector( 3837, -4119, 87 ) )
	AddStationaryTitanPosition( Vector( 4836, -3284, 98 ) )
	//AddStationaryTitanPosition( Vector( -360, -3486, 59 ) )
	AddStationaryTitanPosition( Vector( -2629, -1508, 314 ) )
	AddStationaryTitanPosition( Vector( 4715, -3807, 171 ) )
	AddStationaryTitanPosition( Vector( 4928, -2320, 97 ) )
	AddStationaryTitanPosition( Vector( 5136, -4087, 250 ) )
	AddStationaryTitanPosition( Vector( -418, -5301, -128 ) )
	AddStationaryTitanPosition( Vector( -905, -4801, -113 ) )
	AddStationaryTitanPosition( Vector( -38, -6120, 103 ) )



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

function Backwater_SetupWaveSpawns()
{
	if ( IsClient() )
		return

	//Colony Waves
	CommonWave_Backwater_Waves()
}