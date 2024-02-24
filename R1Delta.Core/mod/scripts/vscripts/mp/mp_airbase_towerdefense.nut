// NOTE this gets run on both client and server!

function main()
{
	//VERY IMPORTANT: if it's not coop mode - just early out
	if ( GAMETYPE != COOPERATIVE )
		return

	airbase_SetupRoutesAndPositions()

	airbase_SetupWaveNames()

	airbase_SetupWaveSpawns()
	//TestWaves()
}

function airbase_SetupRoutesAndPositions()
{
	if ( !IsServer() )
		return

	//set the custom wave spawn anim
	SetCustomWaveSpawn_SideView()

	SetCustomPlayerDropshipSpawn( TEAM_MILITIA, Vector( -600, -3910, 250 ), Vector( 0, 88, 0 ), Vector( 679, -3775, 434 ), Vector( 0, 140, 0 ) )

	local oneRoute = [ Vector( -4833, 1853, 99 ), Vector( -939, -2956, 96 ) ]
	TowerDefense_AddRoute( oneRoute, "oneRoute" )

	local twoRoute = [ Vector( -2706, 1651, 102 ),  Vector( -2822, -2491, 96 ),  Vector( -943, -3043, 96 ) ]
	TowerDefense_AddRoute( twoRoute, "twoRoute" )

	local threeRoute = [ Vector( 525, 2740, 96 ), Vector ( -458, -2554, 92 ) ]
	TowerDefense_AddRoute( threeRoute )

	local fourRoute = [ Vector( -1220, 2323, 101 ), Vector ( 259, -685, 590 ),  Vector( 1924, -2737, 360 ),  Vector( 45, -3119, 96 ) ]
	TowerDefense_AddRoute( fourRoute, "fourRoute" )

	local leftcloseRoute = [ Vector( -3612, -2754, 96 ), Vector( -864, -3036, 96 )]
	TowerDefense_AddRoute( leftcloseRoute, "leftcloseRoute", false )

	local rightcloseRoute = [ Vector( 1898, -2463, 360 ), Vector( -203, -3193, 96 )]
	TowerDefense_AddRoute( rightcloseRoute, "rightcloseRoute", false )

	local centercloseRoute = [ Vector( -1636, -1395, 96 ), Vector( -864, -3036, 96 )]
	TowerDefense_AddRoute( centercloseRoute, "centercloseRoute", false )

	TowerDefense_AddGeneratorLocation( Vector( -348, -3219, 96 ), Vector( 0, 65, 0 ) )


	//Loadout Crate Tower Defense Building
	AddLoadoutCrate( level.nv.attackingTeam, Vector( -446, -4267, 360 ), Vector( 0, 85, 0 ) )
	//Loadout Crate Chokepoint Building
	AddLoadoutCrate( level.nv.attackingTeam, Vector( 380, -2608, 96 ), Vector( 0, -165, 0 ) )
	//Loadout Crate Fuel Hub
	AddLoadoutCrate( level.nv.attackingTeam, Vector( -1091, -2409, 456 ), Vector( 0, -59, 0 ) )

	AddStationaryTitanPosition( Vector( 987, 759, 584 ) )
	AddStationaryTitanPosition( Vector( 1517, 166, 584 ) )
	AddStationaryTitanPosition( Vector( 441, 787, 584 ) )
	AddStationaryTitanPosition( Vector( -208, 245, 576 ) )

	TowerDefense_AddSniperLocation( Vector( -1418, -2664, 456 ), 	-75 	)
	TowerDefense_AddSniperLocation( Vector( -1062, -2773, 458 ), 	-73 	)
	TowerDefense_AddSniperLocation( Vector( -613, -2381, 464 ), 	-68  )
	TowerDefense_AddSniperLocation( Vector( -830, -3634, 340 ), 	73  )
	TowerDefense_AddSniperLocation( Vector( -1269, -3668, 340 ), 	99  )
	TowerDefense_AddSniperLocation( Vector( 94, -3791, 340 ), 	80 	)
	TowerDefense_AddSniperLocation( Vector( 1403, -708, 924 ), -158  )
	TowerDefense_AddSniperLocation( Vector( -403, -1015, 170 ),  -150 )
	TowerDefense_AddSniperLocation( Vector( 1269, -3166, 371 ),  152 )
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
		TD_SpawnEmpTitan						-> 1 nuke titan
		TD_SpawnNukeTitan						-> 1 mortar titan
		TD_SpawnCloakedDrone							-> 1 cloak drone

\***************************************************/
function TestWaves()
{
	if ( IsClient() )
		return

	local wave = TowerDefense_AddWave()
	Wave_AddSpawn( wave, TD_SpawnTitan )

	local wave = TowerDefense_AddWave()
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad )

	local wave = TowerDefense_AddWave()
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad )

	local wave = TowerDefense_AddWave()
	Wave_AddSpawn( wave, TD_SpawnGruntSquad )
}

function airbase_SetupWaveNames()
{
//	AddWaveName( "name_workclass", "Working Class" )
	AddWaveName( "name_hidthreat", "Hidden Threats" )
	AddWaveName( "name_countersnipe", "Countersnipe" )
	AddWaveName( "name_heavyart", "Heavy Artillery" )
	AddWaveName( "name_mobilebatt", "Mobile Titan Battery" )
	AddWaveName( "name_overload", "Overload!" )
	AddWaveName( "name_sysshock", "System Shock" )
	AddWaveName( "name_massdest", "Weapons of Mass Destruction" )
	AddWaveName( "name_theend", "The End is Here!!" )
}

function airbase_SetupWaveSpawns()
{
	if ( IsClient() )
		return

	//Wave: Colony Waves
	CommonWave_Airbase_Waves()

}
