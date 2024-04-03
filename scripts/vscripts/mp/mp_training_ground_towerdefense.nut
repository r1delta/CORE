// NOTE this gets run on both client and server!
function main()
{
	Assert( GAMETYPE == COOPERATIVE )
	Trainingground_SetupRoutesAndPositions()

	Trainingground_SetupWaveSpawns()
	//TestWaves()

	//set the custom wave spawn anim
	//if ( IsServer() )
    //	SetCustomWaveSpawn_SideView( optionalOrigin, optionalAngles )

     if ( IsServer() )
   SetCustomWaveSpawn_SideView( Vector( -373, -2103, 287 ), Vector( 0, -90, 0 ) )
}

function Trainingground_SetupRoutesAndPositions()
{
	if ( !IsServer() )
		return

		SetCustomPlayerDropshipSpawn( TEAM_MILITIA, Vector( 1015, -3736, -33 ), Vector( 0, 162, 0 ), Vector( -875, -3788, -20 ), Vector( 0, 2, 0 ) )

		local northeastRoute = [ Vector( -2051, 3919, -22 ), Vector( -2799, 12, 64 ), Vector( -2829, -1481, -28 ), Vector( -290, -4047, -0 ) ]
		TowerDefense_AddRoute( northeastRoute )

		local southeastRoute = [ Vector( 1587, 3869, -12 ), Vector( 2258, -20, 64 ), Vector ( 258, -4001, -8 ) ]
		TowerDefense_AddRoute( southeastRoute )

		local eastRoute = [ Vector( 10, 3936, 0 ), Vector ( 26, -4379, 2 ) ]
		TowerDefense_AddRoute( eastRoute )

		local leftcloseRoute = [ Vector( -3263, -2173, -50 ), Vector( -290, -4047, -0 )]
		TowerDefense_AddRoute( leftcloseRoute, "leftcloseRoute", false )

		local centercloseRoute = [ Vector( 154, -1009, -11 ), Vector( 28, -3880, -4 )]
		TowerDefense_AddRoute( centercloseRoute, "centercloseRoute", false )

		local rightcloseRoute = [ Vector( 3070, -2168, -9 ), Vector( 258, -4001, -8 )]
		TowerDefense_AddRoute( rightcloseRoute, "rightcloseRoute", false )

		TowerDefense_AddGeneratorLocation( Vector( 21, -4071, -1 ), Vector( 0, 0, 0 ) )

	AddLoadoutCrate( level.nv.attackingTeam, Vector( 1460, -3044, 280 ), Vector( 0, 0, 0 ) )
	AddLoadoutCrate( level.nv.attackingTeam, Vector( -1437, -2854, 280 ), Vector( 0, 270, 0 ) )
//	AddLoadoutCrate( level.nv.attackingTeam, Vector( -2970, 2470, 425 ), Vector( 0, -103, 0 ) )

	AddStationaryTitanPosition( Vector( 3364, 1465, -62 ) )
	AddStationaryTitanPosition( Vector( 3242, 2503, -47 ) )
	AddStationaryTitanPosition( Vector( 2386, 2939, -18 ) )
	AddStationaryTitanPosition( Vector( 2029, 1394, -54 ) )
	AddStationaryTitanPosition( Vector( 858, 1329, -32 ) )
	AddStationaryTitanPosition( Vector( 625, 2924, -23 ) )
	AddStationaryTitanPosition( Vector( -697, 2809, -30 ) )
	AddStationaryTitanPosition( Vector( -649, 1432, -14 ) )
	AddStationaryTitanPosition( Vector( -1830, 2260, -29 ) )
	AddStationaryTitanPosition( Vector( -1016, 3877, -35 ) )
	AddStationaryTitanPosition( Vector( -2743, 1884, -23 ) )
	AddStationaryTitanPosition( Vector( -2315, 1027, -16 ) )
	AddStationaryTitanPosition( Vector( -3189, 1259, 17 ) )


	TowerDefense_AddSniperLocation( Vector( -2687, -2346, 280 ), 	-49	)
	TowerDefense_AddSniperLocation( Vector( 138, -1664, 280 ), 	-90	)
	TowerDefense_AddSniperLocation( Vector( 76, -2551, 272 ), 	-90	)
	TowerDefense_AddSniperLocation( Vector( 1570, -3451, 144 ), 	-148	)
	TowerDefense_AddSniperLocation( Vector( -1151, -2947, 280 ), 	0	)
	TowerDefense_AddSniperLocation( Vector( -166, -2241, 272 ), 	-90	)
	TowerDefense_AddSniperLocation( Vector( -787, -677, 200 ), 	-90	)
	TowerDefense_AddSniperLocation( Vector( 1048, -672, 200 ), 	-90	)

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

function Trainingground_SetupWaveSpawns()
{
	if ( IsClient() )
		return

	//Training Ground
	CommonWave_Training_Ground_Waves()
}