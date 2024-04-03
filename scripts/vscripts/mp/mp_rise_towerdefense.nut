// NOTE this gets run on both client and server!

function main()
{
	Assert( GAMETYPE == COOPERATIVE )
	Rise_SetupRoutesAndPositions()

	Rise_AddWaveNames()

	Rise_SetupWaveSpawns()
	//TestWaves()

	if ( IsServer() )
    	SetCustomWaveSpawn_SideView( Vector( -3760, -303, 697 ), Vector( 0, 0, 0 ) )
}

function EntitiesDidLoad()
{
	// do this here because _gamemode_coop_shared includes this script before _gamemode_coop is included.
	if ( IsServer() )
    	Coop_SetNumAllowedRestarts( COOP_RESTARTS_MP_RISE )
}

function Rise_SetupRoutesAndPositions()
{
	if ( !IsServer() )
		return

		SetCustomPlayerDropshipSpawn( TEAM_MILITIA, Vector( -5122, -1119, 520 ), Vector( 0, 26, 0 ) )

		local centerRoute = [ Vector( 1904, 1011, 116 ), Vector( -4542, 23, 384 ) ]
		TowerDefense_AddRoute( centerRoute )

		local dirtRoute = [ Vector( 3585, 367, 144 ), Vector ( -1180, -1612, 248 ) Vector( -4542, 23, 384 ) ]
		TowerDefense_AddRoute( dirtRoute )

		local harborRoute = [ Vector( 1856, 3304, 8 ), Vector( -4568, -658, 384 ) ]
		TowerDefense_AddRoute( harborRoute )

		local leftcloseRoute = [ Vector( -3279, 1457, 320 ), Vector( -4542, 23, 384 )]
		TowerDefense_AddRoute( leftcloseRoute, "leftcloseRoute", false )

		local rightcloseRoute = [ Vector( -826, -1361, 248 ), Vector( -4653, -719, 384 )]
		TowerDefense_AddRoute( rightcloseRoute, "rightcloseRoute", false )

		local centercloseRoute = [ Vector( -2422, -416, 384 ), Vector( -4366, -551, 384 )]
		TowerDefense_AddRoute( centercloseRoute, "centercloseRoute", false )

	TowerDefense_AddGeneratorLocation( Vector( -4565, -302, 384 ), Vector( 0, 0, 0 ) )

	AddLoadoutCrate( level.nv.attackingTeam, Vector( -2795, 702, 448 ), Vector( 0, 270, 0 ) )
	AddLoadoutCrate( level.nv.attackingTeam, Vector( -1644, -1358, 364 ), Vector( 0, 90, 0 ), false ) // no minimap icon, it's to close too the generator

	AddStationaryTitanPosition( Vector( 3666, 106, 154 ) )
	AddStationaryTitanPosition( Vector( 3721, 541, 144 ) )
	AddStationaryTitanPosition( Vector( 3356, 2612, 86 ) )
	AddStationaryTitanPosition( Vector( 3005, 3354, 10 ) )
	AddStationaryTitanPosition( Vector( 2514, 3554, 18 ) )
	AddStationaryTitanPosition( Vector( 1996, 3524, 8 ) )
	AddStationaryTitanPosition( Vector( 1509, 3222, 8 ) )
	AddStationaryTitanPosition( Vector( 1791, 1329, 39 ) )
	AddStationaryTitanPosition( Vector( 2580, 1281, 72 ) )
	AddStationaryTitanPosition( Vector( 2002, 2137, 8 ) )

	TowerDefense_AddSniperLocation( Vector( 1094, 1549, 507 ), 	-171 )
	TowerDefense_AddSniperLocation( Vector( 1019, 1849, 512 ), 	-168 )
	TowerDefense_AddSniperLocation( Vector( -198, 378, 544 ), 	178 )
	TowerDefense_AddSniperLocation( Vector( -1982, -1165, 364 ), 	149 )
	TowerDefense_AddSniperLocation( Vector( -2867, 740, 446 ), 	-137 )
	TowerDefense_AddSniperLocation( Vector( -2314, -878, 648 ), 	116 )
	TowerDefense_AddSniperLocation( Vector( -2481, -976, 648 ), 	130 )
	TowerDefense_AddSniperLocation( Vector( -3330, -1079, 776 ), 	87 )
	TowerDefense_AddSniperLocation( Vector( -1971, -141, 648 ), 	178 )
	TowerDefense_AddSniperLocation( Vector( -322, 1498, 544 ), 	180 )
	TowerDefense_AddSniperLocation( Vector( -1983, -504, 328 ), 	178 )
	TowerDefense_AddSniperLocation( Vector( -427, 710, 264 ), 	-90 )
	TowerDefense_AddSniperLocation( Vector( -63, 50, 256 ), 	-140 )
	TowerDefense_AddSniperLocation( Vector( -3671, 702, 448 ), 	-90 )

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
function TestWaves()
{
	if ( IsClient() )
		return

	local wave = TowerDefense_AddWave( "name_nukeapoc" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad )

	local wave = TowerDefense_AddWave( "name_gruntwork" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad )

	local wave = TowerDefense_AddWave()
	Wave_AddSpawn( wave, TD_SpawnGruntSquad )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad )

	local wave = TowerDefense_AddWave( "name_machinewar" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad )
}

function Rise_AddWaveNames()
{
	AddWaveName( "name_machinewar", "Machine War" )
	AddWaveName( "name_nukeapoc", "Nuclear Apocalypse" )
	AddWaveName( "name_onslaught", "Final Onslaught!" )
}

function Rise_SetupWaveSpawns()
{
	if ( IsClient() )
		return

	//Rise Hardcore Waves
	CommonWave_Endless_Waves()

}
