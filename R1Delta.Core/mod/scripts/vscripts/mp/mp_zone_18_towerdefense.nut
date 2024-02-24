// NOTE this gets run on both client and server!
function main()
{
	Assert( GAMETYPE == COOPERATIVE )
	Zone_18_SetupRoutesAndPositions()

	Zone_18_SetupWaveSpawns()
	//TestWaves()

  if ( IsServer() )
    SetCustomWaveSpawn_SideView( Vector( 100, 125, 1200 ), Vector( 0, 54, 0 ), "dropship_coop_respawn_outpost" )

	//set the custom wave spawn anim
	//if ( IsServer() )
    //	SetCustomWaveSpawn_SideView( optionalOrigin, optionalAngles )
}

function Zone_18_SetupRoutesAndPositions()
{
	if ( !IsServer() )
		return

		SetCustomPlayerDropshipSpawn( TEAM_MILITIA, Vector( 281, 1225, 712 ), Vector( 0, -137, 0 ), Vector( -508, 1157, 680 ), Vector( 0, -42, 0 ) )

		local oneRoute = [ Vector( 2423, 2625, 448 ), Vector( 41, 1371, 320 ) ]
		TowerDefense_AddRoute( oneRoute )

		local twoRoute = [ Vector( 2834, -4246, 400 ),  Vector( 762, -1388, 444 ),  Vector( -62, 386, 448 ) ]
		TowerDefense_AddRoute( twoRoute, "twoRoute" )

		local threeRoute = [ Vector( -2383, 2143, 320 ), Vector ( -282, 1392, 320 ) ]
		TowerDefense_AddRoute( threeRoute )

		local fourRoute = [ Vector( -1849, -4131, 337 ), Vector ( -1569, -1373, 456 ),  Vector( -243, -1409, 289 ),  Vector( -73, 406, 448 ) ]
		TowerDefense_AddRoute( fourRoute, "fourRoute" )

		local leftcloseRoute = [ Vector( 2049, -156, 448 ), Vector( 175, 388, 448 )]
		TowerDefense_AddRoute( leftcloseRoute, "leftcloseRoute", false )

		local rightcloseRoute = [ Vector( -2614, -677, 414 ), Vector( -403, 349, 448 )]
		TowerDefense_AddRoute( rightcloseRoute, "rightcloseRoute", false )

		local centercloseRoute = [ Vector( -472, -3052, 456 ), Vector( 14, 374, 448 )]
		TowerDefense_AddRoute( centercloseRoute, "centercloseRoute", false )


		TowerDefense_AddGeneratorLocation( Vector( -75, 947, 320 ), Vector( 0, 90, 0 ) )

	AddLoadoutCrate( level.nv.attackingTeam, Vector( -445, -39, 594 ), Vector( 0, 270, 0 ) )
	AddLoadoutCrate( level.nv.attackingTeam, Vector( 533, -44, 600), Vector( 0, 270, 0 ) )


	AddStationaryTitanPosition( Vector( 2984, -2807, 337 ) )
	AddStationaryTitanPosition( Vector( 3357, -2006, 282 ) )
	AddStationaryTitanPosition( Vector( 981, -4292, 336 ) )
	AddStationaryTitanPosition( Vector( 1706, -4606, 373 ) )
	AddStationaryTitanPosition( Vector( 2852, -4206, 400 ) )
	AddStationaryTitanPosition( Vector( -1020, -4214, 330 ) )
	AddStationaryTitanPosition( Vector( -1876, -3750, 337 ) )
	AddStationaryTitanPosition( Vector( -2828, -3617, 432 ) )
	AddStationaryTitanPosition( Vector( -3311, -1912, 358 ) )
	AddStationaryTitanPosition( Vector( -1916, -2122, 456 ) )


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

function Zone_18_SetupWaveSpawns()
{
	if ( IsClient() )
		return

	//Colony Waves
	CommonWave_Backwater_Waves()
}