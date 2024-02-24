// NOTE this gets run on both client and server!
function main()
{
	Assert( GAMETYPE == COOPERATIVE )

	Colony_SetupRoutesAndPositions()

	Colony_SetupWaveSpawns()
	//TestWaves()

  if ( IsServer() )
    SetCustomWaveSpawn_SideView( Vector( 914, -1966, 389 ), Vector( 0, 155, 0 ) )

	//set the custom wave spawn anim
	//if ( IsServer() )
    //	SetCustomWaveSpawn_SideView( optionalOrigin, optionalAngles )
}

function Colony_SetupRoutesAndPositions()
{
	if ( !IsServer() )
		return

		SetCustomPlayerDropshipSpawn( TEAM_MILITIA, Vector( 945, -2200, 150 ), Vector( 0, 105, 0 ) )

		local oneRoute = [ Vector( -2493, -1810, 157 ), Vector( 421, -1946, 256 ) ]
		TowerDefense_AddRoute( oneRoute )

		local twoRoute = [ Vector( -2709, 3995, -70 ),  Vector( -538, 2332, -1  ),  Vector( 662, 1365, 19 ),  Vector( -25, 434, 33 ),  Vector( 706, -1174, 203 ),  Vector( 703, -1657, 237 ) ]
		TowerDefense_AddRoute( twoRoute, "twoRoute" )

		local threeRoute = [ Vector( 2606, 4226, 42 ), Vector ( 1926, 997, 19 ), Vector ( 986, -1995, 253 ) ]
		TowerDefense_AddRoute( threeRoute )

		local fourRoute = [ Vector( -286, 5473, -70 ), Vector ( 1226, 1964, 7 ),  Vector( 662, 1365, 19 ),  Vector( -25, 434, 33 ),  Vector( 706, -1174, 203 ),  Vector( 703, -1657, 237 ) ]
		TowerDefense_AddRoute( fourRoute, "fourRoute" )

		local leftcloseRoute = [ Vector( -1424, -959, 139 ), Vector( -9, -1771, 208 )]
		TowerDefense_AddRoute( leftcloseRoute, "leftcloseRoute", false )

		local rightcloseRoute = [ Vector( 2303, -1076, 225 ), Vector( 1204, -1985, 246 )]
		TowerDefense_AddRoute( rightcloseRoute, "rightcloseRoute", false )

		local centercloseRoute = [ Vector( 0, 422, 35 ), Vector( 688, -1541, 225 )]
		TowerDefense_AddRoute( centercloseRoute, "centercloseRoute", false )


		TowerDefense_AddGeneratorLocation( Vector( 697, -1999, 272 ), Vector( 0, 0, 0 ) )

	AddLoadoutCrate( level.nv.attackingTeam, Vector( -808, -70, 244 ), Vector( 0, 0, 0 ) )
	AddLoadoutCrate( level.nv.attackingTeam, Vector( 1265, 566, 60 ), Vector( 0, 180, 0 ) )
	AddLoadoutCrate( level.nv.attackingTeam, Vector( 1662, -1532, 526 ), Vector( 0, 270, 0 ) )


	AddStationaryTitanPosition( Vector( -1011, 3361, 1 ) )
	AddStationaryTitanPosition( Vector( -261, 4229, 5 ) )
	AddStationaryTitanPosition( Vector( 2740, 4334, 33 ) )
	AddStationaryTitanPosition( Vector( 1126, 5101, -50 ) )
	AddStationaryTitanPosition( Vector( -2032, 3537, -40 ) )
	AddStationaryTitanPosition( Vector( -1660, 1921, 12 ) )
	AddStationaryTitanPosition( Vector( -1992, -1253, 179 ) )
	AddStationaryTitanPosition( Vector( -1177, -2790, 208 ) )
	AddStationaryTitanPosition( Vector( -239, -2465, 248 ) )
	AddStationaryTitanPosition( Vector( -1553, -3516, 184 ) )


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

function Colony_SetupWaveSpawns()
{
	if ( IsClient() )
		return

	//Colony Waves
	CommonWave_Colony_Waves()
}