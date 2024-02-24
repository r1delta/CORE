// NOTE this gets run on both client and server!

function main()
{
	//VERY IMPORTANT: if it's not coop mode - just early out

	Corporate_SetupRoutesAndPositions()
	Corporate_SetupWaveSpawns()

	if ( IsClient() )
		Global_MainHud_SetCustomMinimapZoom( 2 )

  	if ( IsServer() )
    	SetCustomWaveSpawn_SideView( Vector( 1388,-913, -353 ), Vector( 0, 90, 0 ) )

	if ( IsServer() )
	{
		Riff_ForceTitanAvailability( eTitanAvailability.Never )
		Riff_ForceSetSpawnAsTitan( eSpawnAsTitan.Never )
	}
}

function Corporate_SetupRoutesAndPositions()
{
	if ( !IsServer() )
		return

	SetCustomPlayerDropshipSpawn( TEAM_MILITIA, Vector( 1750, -941, -1300 ), Vector( 0, 90, 0 ), Vector( 1155, -432, -695 ), Vector( 0, -6, 0 ) )

	local oneRoute = [ Vector( 2992, -3228, -1002 ), Vector( 3084, -910, -1023 ), Vector( 1914, 825, -1015 ) ]
	TowerDefense_AddRoute( oneRoute, "oneRoute" )

	local twoRoute = [ Vector( 1130, -3138, -1333 ), Vector ( 1050, -1856, -1023 ), Vector( 753, -855, -1023 ), Vector( 1914, 825, -1015 ) ]
	TowerDefense_AddRoute( twoRoute, "twoRoute" )

	local threeRoute = [ Vector( -719, 4063, -1079 ), Vector( 996, 1997, -1023 ), Vector( 1643, 1077, -1015 ) ]
	TowerDefense_AddRoute( threeRoute, "threeRoute" )

	local fourRoute = [ Vector( 3095, 4222, -1023 ),  Vector( 2753, 1408, -1047 ), Vector( 2139, 1034, -1015 ) ]
	TowerDefense_AddRoute( fourRoute, "fourRoute" )

	local speconeRoute = [ Vector( 4121, 1390, -999 ),  Vector( 3143, 1552, -759 ), Vector( 2193, 1011, -1015 ) ]
	TowerDefense_AddRoute( speconeRoute, "speconeRoute" )

	local spectwoRoute = [ Vector( -90, 2122, -1123 ),  Vector( 1168, 1752, -759 ), Vector( 1631, 1085, -1015 ) ]
	TowerDefense_AddRoute( spectwoRoute, "spectwoRoute" )

	local leftcloseRoute = [ Vector( 3763, -920, -1023 ), Vector( 1916, 906, -1015 )]
	TowerDefense_AddRoute( leftcloseRoute, "leftcloseRoute", false )

	local rightcloseRoute = [ Vector( 280, -828, -1023 ), Vector( 1916, 906, -1015 )]
	TowerDefense_AddRoute( rightcloseRoute, "rightcloseRoute", false )

	local centercloseRoute = [ Vector( 1970, -1163, -1031 ), Vector( 1931, -63, -1031 ), Vector( 1916, 906, -1015 )]
	TowerDefense_AddRoute( centercloseRoute, "centercloseRoute", false )

	TowerDefense_AddGeneratorLocation( Vector( 1925, 1030, -1015 ), Vector( 0, 0, 0 ) ) //In main lobby

	AddLoadoutCrate( level.nv.attackingTeam, Vector( 2121, 2359, -711 ), Vector( 0, 0, 0 ) )	//lobby mezzanine 01
	AddLoadoutCrate( level.nv.attackingTeam, Vector( 1993, 1484, -847 ), Vector( 0, -270, 0 ) )  //lobby mezzanine 02

/*	AddStationaryTitanPosition( Vector( -179, 1118, -1227 ) )
	AddStationaryTitanPosition( Vector( -1956, -1465, -1376 ) )
	AddStationaryTitanPosition( Vector( -1249, -2320, -1375 ) )
	AddStationaryTitanPosition( Vector( -1020, -3009, -1419 ) )
	AddStationaryTitanPosition( Vector( -328, -3771, -1590 ) )
	AddStationaryTitanPosition( Vector( -2081, 509, -1459 ) )
	AddStationaryTitanPosition( Vector( 366, 4162, -1023 ) )
	AddStationaryTitanPosition( Vector( -983, 3344, -1102 ) )
	AddStationaryTitanPosition( Vector( 378, -3772, -1494 ) )
	AddStationaryTitanPosition( Vector( -1651, -2459, -1375 ) )

	TowerDefense_AddSniperLocation( Vector( 3462, 877, -567 ),  -81 )
	TowerDefense_AddSniperLocation( Vector( 3436, -722, -697 ),  -115 )
	TowerDefense_AddSniperLocation( Vector( 3259, -1878, -537 ),  0 )
	TowerDefense_AddSniperLocation( Vector( 3267, -2702, -534 ),  11 )
	TowerDefense_AddSniperLocation( Vector( 3366, -2788, -898 ),  19 )
	TowerDefense_AddSniperLocation( Vector( 3202, -2180, -895 ),  -33 )
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
		TD_SpawnEmpTitan 						-> 1 emp titan
		TD_SpawnCloakedDrone					-> 1 cloak drone

\***************************************************/

function Corporate_SetupWaveSpawns()
{

	if ( IsClient() )
		return

	//Wave: Corporate Waves
	CommonWave_Corporate_Waves()

}