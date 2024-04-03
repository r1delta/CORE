// NOTE this gets run on both client and server!
function main()
{
	Assert( GAMETYPE == COOPERATIVE )
	Wargames_SetupRoutesAndPositions()

	Wargames_SetupWaveSpawns()
	//TestWaves()

	  if ( IsServer() )
    SetCustomWaveSpawn_SideView( Vector( -3520, 1304, 342 ), Vector( 0, 180, 0 ), "dropship_coop_respawn_wargames" )

	//set the custom wave spawn anim
	//if ( IsServer() )
    //	SetCustomWaveSpawn_SideView( optionalOrigin, optionalAngles )
}

function Wargames_SetupRoutesAndPositions()
{
	if ( !IsServer() )
		return

		local southwestRoute = [ Vector( -158, -3097, -127 ), Vector( -3616, 936, -133 ) ]
		TowerDefense_AddRoute( southwestRoute )

		local southRoute = [ Vector( 3100, 513, -127 ), Vector ( -3535, 1148, -133 ) ]
		TowerDefense_AddRoute( southRoute )

		local southeastRoute = [ Vector( 1080, 2718, -128 ), Vector ( -3794, 1493, -133 ) ]
		TowerDefense_AddRoute( southeastRoute )

		local leftcloseRoute = [ Vector( -2075, 2255, -255 ), Vector( -4056, 1550, -127 )]
		TowerDefense_AddRoute( leftcloseRoute, "leftcloseRoute", false )

		local rightcloseRoute = [ Vector( -955, -2916, -255 ), Vector( -3894, 756, -127 )]
		TowerDefense_AddRoute( rightcloseRoute, "rightcloseRoute", false )

		local centercloseRoute = [ Vector( -1746, 601, -127 ), Vector( -3556, 1142, -133 )]
		TowerDefense_AddRoute( centercloseRoute, "centercloseRoute", false )

		TowerDefense_AddGeneratorLocation( Vector( -3777, 1173, -127 ), Vector( 0, 0, 0 ) )

	AddLoadoutCrate( level.nv.attackingTeam, Vector( -2746, 1136, 112 ), Vector( 0, 135, 0 ) )
	AddLoadoutCrate( level.nv.attackingTeam, Vector( -3023, -201, 176 ), Vector( 0, 180, 0 ) )
	AddLoadoutCrate( level.nv.attackingTeam, Vector( -4104, 607, -127 ), Vector( 0, 78, 0 ) )

	AddStationaryTitanPosition( Vector( 1240, 3079, -128 ) )
	AddStationaryTitanPosition( Vector( -1104, -3335, -191 ) )
	AddStationaryTitanPosition( Vector( -1515, -3371, -191 ) )
	AddStationaryTitanPosition( Vector( -1833, -2862, -255 ) )
	AddStationaryTitanPosition( Vector( -2454, -2908, -127 ) )
	AddStationaryTitanPosition( Vector( -2965, -2348, -127 ) )
	AddStationaryTitanPosition( Vector( -1897, 3511, -255 ) )
	AddStationaryTitanPosition( Vector( -686, 3628, -255 ) )
	AddStationaryTitanPosition( Vector( -2200, 3597, -255 ) )

	TowerDefense_AddSniperLocation( Vector( -1571, 1474, 112 ), 	-149	)
	TowerDefense_AddSniperLocation( Vector( -1878, 1710, 112 ), 	104	)
	TowerDefense_AddSniperLocation( Vector( -3290, 1109, 328 ), 	144	)
	TowerDefense_AddSniperLocation( Vector( -3306, 1542, 328 ), 	-171	)
	TowerDefense_AddSniperLocation( Vector( -3381, -51, 176 ), 	118	)
	TowerDefense_AddSniperLocation( Vector( -3338, 389, 36 ), 	74	)
	TowerDefense_AddSniperLocation( Vector( -2371, 485, 120 ), 	177	)

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

function Wargames_SetupWaveSpawns()
{
	if ( IsClient() )
		return

	//Rise waves
	CommonWave_RiseHC()
}