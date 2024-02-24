// NOTE this gets run on both client and server!
function main()
{
	Assert( GAMETYPE == COOPERATIVE )

	AngelCity_SetupRoutesAndPositions()

	AngelCity_SetupWaveSpawns()

	//TestWaves()

	//WaveRouteDemo()
}

function AngelCity_SetupRoutesAndPositions()
{
	if ( !IsServer() )
		return

	//set the custom wave spawn anim
	SetCustomWaveSpawn_SideView( Vector(  -3500, 2014, 120 ), Vector( 0, -77, 0 ) )


	local centerRoute = [ Vector( 2146, -1457, 120 ), Vector( 788, 482, 120 ), Vector( -960, 1671, 120 ), Vector( -2782, 1538, 120 ) ]
	TowerDefense_AddRoute( centerRoute, "centerRoute" )

	local dirtRoute = [ Vector( 74, -2250, 21 ), Vector( -1681, -1144, 112 ), Vector( -2742, 1124, 120 ) ]
	TowerDefense_AddRoute( dirtRoute, "dirtRoute" )

	local harborRoute = [ Vector( 2295, 3219, 136 ), Vector( -221, 4077, 129 ), Vector( -3297, 1639, 120 ) ]
	TowerDefense_AddRoute( harborRoute, "harborRoute" )

// CLOSE ROUTES
	local centerRouteClose = [ Vector( 720, 1072, 128 ), Vector( -2736, 1400, 128 ) ]
	TowerDefense_AddRoute( centerRouteClose, "centerRouteClose", false )  // false = don't use this route for "random" route selection

	local harborRouteClose = [ Vector( -2624, 4464, 128 ), Vector( -3024, 1768, 128 ) ]
	TowerDefense_AddRoute( harborRouteClose, "harborRouteClose", false )  // false = don't use this route for "random" route selection

	local fieldRouteClose = [ Vector( -2936, -1168, 112 ), Vector( -2832, 1128, 128 ) ]
	TowerDefense_AddRoute( fieldRouteClose, "fieldRouteClose", false )  // false = don't use this route for "random" route selection

	TowerDefense_AddGeneratorLocation( Vector( -3100, 1480, 120 ), Vector( 0, 0, 0 ) )

	AddLoadoutCrate( level.nv.attackingTeam, Vector( -1700, 1135, 512 ), Vector( 0, -90, 0 ) )
	AddLoadoutCrate( level.nv.attackingTeam, Vector( -2820, 1300, 120 ), Vector( 0, 0, 0 ), false ) // no minimap icon, it's to close too the generator

	AddStationaryTitanPosition( Vector( 1919, 4020, 130 ) )
	AddStationaryTitanPosition( Vector( 3502, 430, 161 ) )
	AddStationaryTitanPosition( Vector( 3630, -1769, 200 ) )
	AddStationaryTitanPosition( Vector( 1706, -2375, 129 ) )
	AddStationaryTitanPosition( Vector( 933, 4408, 141 ) )
	AddStationaryTitanPosition( Vector( 1307, 4365, 137 ) )
	AddStationaryTitanPosition( Vector( 2735, 1699, 120 ) )
	AddStationaryTitanPosition( Vector( 3711, -542, 194 ) )
	AddStationaryTitanPosition( Vector( 76, -2484, 52 ) )
	AddStationaryTitanPosition( Vector( 3272, 516, 172 ) )

	TowerDefense_AddSniperLocation( Vector( -1871.699829, 965.876648, 512.031250 ), 	162 )
	TowerDefense_AddSniperLocation( Vector( -1491.588623, 531.156799, 512.031250 ),		-90 )
	TowerDefense_AddSniperLocation( Vector( -1450.329346, 1320.684448, 960.031250 ),	 -31 )
	TowerDefense_AddSniperLocation( Vector( -319.849609, 60.319150, 800.031250 ), 		90 )
	TowerDefense_AddSniperLocation( Vector( 802.521667, 237.125397, 550.874084 ), 		91 )
	TowerDefense_AddSniperLocation( Vector( 2300.754883, 23.578373, 556.775818 ),		-146 )
	TowerDefense_AddSniperLocation( Vector( 1860.532959, -1420.161987, 592.156006 ),	-87 )
	TowerDefense_AddSniperLocation( Vector( 910.868774, 671.848999, 744.031250 ),		-171 )
	TowerDefense_AddSniperLocation( Vector( 870.868774, 970.848999, 744.031250 ),		-210 )
	TowerDefense_AddSniperLocation( Vector( -1100.069519, 2611.914063, 523.517273 ),	-25 )
	TowerDefense_AddSniperLocation( Vector( -820.087463, 3900.873047, 453.031250 ),		-10 )
	TowerDefense_AddSniperLocation( Vector( -616.662903, 1780.513550, 540.031250 ),		-177 )
	TowerDefense_AddSniperLocation( Vector( 1308.031372, 2553.492188, 312.031250 ),		-180 )
	TowerDefense_AddSniperLocation( Vector( -990.259766, 3140.317871, 595.031250 ),		-45 )
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
		TD_SpawnCloakedDrone							-> 1 cloak drone

\***************************************************/
function WaveRouteDemo()
{
	if ( IsClient() )
		return

	local wave = TowerDefense_AddWave()
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "centerRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "centerRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "harborRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "dirtRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "centerRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "centerRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "harborRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "dirtRoute" )

	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 		"titan1", null, "harborRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan1", null, "dirtRoute" )

	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan2", "titan1", "centerRoute" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 		"titan2", "titan1", "harborRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan2", "titan1", "dirtRoute" )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", "troops1", "centerRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", "troops1", "centerRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", "troops1", "harborRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", "troops1", "dirtRoute" )

}

function TestWaves()
{
	if ( IsClient() )
		return

	//>>>> ORIGINAL //depot/r1dev/game/r1/scripts/vscripts/mp/mp_angel_city_towerdefense.nut#55
	//WARM UP
	local wave = TowerDefense_AddWave( "name_warm_up" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadDroppod, null, null, "centerRouteClose"  )

	local wave = TowerDefense_AddWave( "name_warm_up" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadDroppod, null, null, "centerRouteClose"  )

	local wave = TowerDefense_AddWave( "name_warm_up" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadDroppod, null, null, "centerRouteClose"  )

	local wave = TowerDefense_AddWave( "name_warm_up" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadDroppod, null, null, "centerRouteClose"  )


	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "centerRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "harborRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "fieldRouteClose" )

	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "group1", null, "centerRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "group1", null, "harborRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "group1", null, "fieldRouteClose" )

	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "group2", "group1", "fieldRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "group2", "group1", "harborRouteClose" )

	Wave_AddPause( wave, 10 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, "group2", "centerRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, "group2", "harborRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, "group2", "fieldRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, "group2" )

	Wave_AddPause( wave, 3 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, "group2"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, "group2" )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group2", "centerRouteClose"  )

	Wave_SetBreakTime( wave, 15 )

	//Wave: EMP TITANS + SOLDIERS
	local wave = TowerDefense_AddWave( "name_emp_intro" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "start", null, "centerRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "start", null, "harborRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "start", null, "fieldRouteClose" )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "start", null, "centerRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "start", null, "harborRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "start", null, "fieldRouteClose" )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, "start", null, "centerRouteClose"  )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", "start", "centerRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops1", "start", "centerRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", "start", "centerRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops1", "start", "centerRoute" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 		"titan1", "start", "centerRoute" )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 		"titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan2", "titan1" )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 		"troops3", "troops2", "centerRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			"troops3", "titan2", "fieldRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 		"troops3", "troops2", "harborRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 		"troops3", "troops2", "centerRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 			"troops3", "titan2", "fieldRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 		"troops3", "troops2", "harborRouteClose" )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 					null, "troops3" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 		null, "troops3" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 					null, "troops3" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 						null, "troops3" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 						null, "troops3" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 						null, "troops3" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 						null, "troops3" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 					null, "troops3", "centerRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 		null, "troops3", "fieldRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 					null, "troops3", "harborRouteClose" )

	Wave_SetBreakTime( wave, 15 )

//MORTAR INTRO
	local wave = TowerDefense_AddWave( "name_mortar_intro" )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "start", null, "centerRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "start", null, "harborRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "start", null, "fieldRouteClose" )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "start", null, "centerRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "start", null, "harborRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "start", null, "fieldRouteClose" )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "start", null, "centerRoute"  )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", "start", "centerRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops1", "start", "centerRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", "start", "centerRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops1", "start", "centerRoute" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 		"titan1", "start", "centerRoute" )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 		"titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan2", "titan1" )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 					"troops3", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 		"troops3", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 					"troops3", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 		"troops3", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			"troops3", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnTitan,  						"titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 						"titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 						"titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 						"titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 						"titan3", "titan2" )

	Wave_SetBreakTime( wave, 15 )


	//Wave: CLOSE TITANS
	local wave = TowerDefense_AddWave( "name_nuke_intro" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "centerRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops1", null, "centerRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "centerRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops1", null, "centerRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "harborRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "fieldRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 	"troops1", null, "harborRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 	"troops1", null, "fieldRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 		"titan1", null, "centerRoute" )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 		"titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan2", "titan1" )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 					"troops3", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 		"troops3", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 					"troops3", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 		"troops3", "troops2", "harborRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			"troops3", "troops2", "fieldRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 		"troops3", "troops2", "harborRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 			"troops3", "troops2", "fieldRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnTitan,  						"titan3", "titan2", "harborRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 						"titan3", "titan2", "fieldRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 						"titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 						"titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 						"titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 						"titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 						"titan3", "titan2" )

	Wave_SetBreakTime( wave, 15 )

	//Wave: FINAL - EVERYTHING
	local wave = TowerDefense_AddWave( "name_final" )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"close1", null, "centerRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"close1", null, "harborRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"close1", null, "fieldRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"close1", null, "centerRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"close1", null, "harborRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"close1", null, "fieldRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnTitan, 	"close1", null, "harborRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 	"close1", null, "fieldRouteClose"  )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", 	"close1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops1", 	"close1" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", 	"close1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops1", 	"close1" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 		"titan1", 	"close1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan1", 	"close1" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 		"titan1", 	"close1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan1", 	"close1" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 		"titan1", 	"close1" )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", "troops1", "centerRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", "titan1", "harborRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", "titan1", "fieldRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "titan1"  )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops3", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3", "troops2", "fieldRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3", "troops2", "harborRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan2", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan2", "troops2", "harborRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 		"titan2", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan2", "troops2", "fieldRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 		"titan2", "troops2" )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4", "troops3", "centerRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops4", "titan2", "harborRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops4", "titan2", "fieldRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops4", "troops3"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops4", "titan2"  )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 					null, "troops4", "fieldRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 		null, "troops4", "harborRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 					null, "troops4" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 		null, "troops4" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 					null, "troops4" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			null, "troops4" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 					null, "troops4" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 					null, "troops4" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 					null, "troops4" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 					null, "troops4", "fieldRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 						null, "troops4", "harborRouteClose" )

	Wave_AddPause( wave, 5, "troops4" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 					null, "troops4" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 						null, "troops4" )

	Wave_AddPause( wave, 5, "troops4" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 						null, "troops4", "fieldRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 						null, "troops4", "harborRouteClose" )


	Wave_SetBreakTime( wave, 15 )
}

function AngelCity_SetupWaveSpawns()
{
	if ( IsClient() )
		return

	CommonWave_Angel_City_Waves()
}
