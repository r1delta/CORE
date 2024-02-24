
// NOTE this gets run on both client and server!
function main()
{
	Assert( GAMETYPE == COOPERATIVE )
	SmugglersCove_SetupRoutesAndPositions()

	SmugglersCove_SetupWaveSpawns()

	  if ( IsServer() )
    SetCustomWaveSpawn_SideView( Vector( -1246, 588, 856 ), Vector( 0, -10, 0 ) )
}

function SmugglersCove_SetupRoutesAndPositions()
{
	if ( !IsServer() )
		return

		SetCustomPlayerDropshipSpawn( TEAM_MILITIA, Vector( 1628, 1600, 308 ), Vector( 0, -155, 0 ), Vector( -829, 1206, 336 ), Vector( 0, -21, 0 ) )

		local southRoute = [ Vector( 2142, -5519, -20 ),  Vector( 1826, -1314, 175 ), Vector( 999, 1146, 376 ) ]
		TowerDefense_AddRoute( southRoute )

		local centerRoute = [ Vector( -430, -3647, -16 ),  Vector( 304, 1087, 375 ) ]
		TowerDefense_AddRoute( centerRoute )

		local dirtRoute = [ Vector( -1906, -5380, -4 ), Vector( -1727, -4117, 168 ), Vector ( -1738, -477, 175 ), Vector ( -384, 1171, 376 ) ]
		TowerDefense_AddRoute( dirtRoute )

		local northRoute = [ Vector( -5298, -4072, 19 ), Vector( -3229, -2705, 297 ), Vector( -2535, 172, 339 ), Vector ( -384, 1171, 376 ) ]
		TowerDefense_AddRoute( northRoute )

		local behindRoute = [ Vector( 703, -2867, 112 ), Vector( 302, 2326, 95 ), Vector ( 315, 1113, 376 ) ]
		TowerDefense_AddRoute( behindRoute )

		local leftcloseRoute = [ Vector( 1790, -550, 176 ), Vector( 698, 1144, 376 )]
		TowerDefense_AddRoute( leftcloseRoute, "leftcloseRoute", false )

		local rightcloseRoute = [ Vector( -2533, 1888, 336 ), Vector( -29, 1167, 376 )]
		TowerDefense_AddRoute( rightcloseRoute, "rightcloseRoute", false )

		local centercloseRoute = [ Vector( -1244, 199, 305 ), Vector( -29, 1167, 376 )]
		TowerDefense_AddRoute( centercloseRoute, "centercloseRoute", false )

		TowerDefense_AddGeneratorLocation( Vector( 328, 1350, 384 ), Vector( 0, 0, 0 ) )

	AddLoadoutCrate( level.nv.attackingTeam, Vector( -1959, 2104, 344 ), Vector( 0, 90, 0 ) )
	AddLoadoutCrate( level.nv.attackingTeam, Vector( 2181, 88, 304 ), Vector( 0, 90, 0 ) )
//	AddLoadoutCrate( level.nv.attackingTeam, Vector( -2970, 2470, 425 ), Vector( 0, -103, 0 ) )


	AddStationaryTitanPosition( Vector( 752, -3413, 112 ) )
	AddStationaryTitanPosition( Vector( -1002, -4560, -2 ) )
	AddStationaryTitanPosition( Vector( -658, -2829, -17 ) )
	AddStationaryTitanPosition( Vector( 133, -2444, -14 ) )
	AddStationaryTitanPosition( Vector( -618, -5767, -23 ) )
	AddStationaryTitanPosition( Vector( -102, -5821, -15 ) )
	AddStationaryTitanPosition( Vector( 447, -950, 112 ) )
	AddStationaryTitanPosition( Vector( 73, -2214, -11 ) )
	AddStationaryTitanPosition( Vector( -221, -3670, -20 ) )
	AddStationaryTitanPosition( Vector( -825, -3512, -1 ) )
	AddStationaryTitanPosition( Vector( -910, -4193, 8 ) )
	AddStationaryTitanPosition( Vector( -243, -5863, -13 ) )


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
function SmugglersCove_SetupWaveSpawns()
{
	if ( IsClient() )
		return

	//Smugglers Cove Waves
	CommonWave_Smuggler_Waves()
}