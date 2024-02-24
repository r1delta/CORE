// NOTE this gets run on both client and server!

function main()
{
	Assert( GAMETYPE == COOPERATIVE )

	Nexus_SetupRoutesAndPositions()

	Nexus_AddWaveNames()

	Nexus_SetupWaveSpawns()
	//TestWaves()

	  if ( IsServer() )
    SetCustomWaveSpawn_SideView( Vector( 44, 380, 648 ), Vector( 0, -87, 0 ) )
}

function Nexus_SetupRoutesAndPositions()
{
	if ( !IsServer() )
		return

	SetCustomPlayerDropshipSpawn( TEAM_MILITIA, Vector( -450, 150, 250 ), Vector( 0, -60, 0 ), Vector( -368, -757, 184 ), Vector( 0, 91, 0 ) )

	local southRoute = [ Vector( 3268, 1164, 268 ), Vector( 434, -127, 176 ) ]
	TowerDefense_AddRoute( southRoute, "southRoute" )

	local northRoute = [ Vector( -4403, -2016, 5 ), Vector( -680, -544, 176 ) ]
	TowerDefense_AddRoute( northRoute, "northRoute" )

	local eastRoute = [ Vector( -89, 6028, 240 ), Vector( 434, -127, 176 ) ]
	TowerDefense_AddRoute( eastRoute, "eastRoute" )

	local westRoute = [ Vector( -223, -4867, 52 ), Vector( 37, -543, 184 ) ]
	TowerDefense_AddRoute( westRoute, "westRoute" )

	local leftcloseRoute = [ Vector( -1920, 301, 176 ), Vector( -577, -339, 183 )]
	TowerDefense_AddRoute( leftcloseRoute, "leftcloseRoute", false )

	local rightcloseRoute = [ Vector( 2400, -1319, 12 ), Vector( 14, -374, 176 )]
	TowerDefense_AddRoute( rightcloseRoute, "rightcloseRoute", false )

	TowerDefense_AddGeneratorLocation( Vector( -258, -244, 185.5 ), Vector( 0, 0, 0 ) )

	AddLoadoutCrate( level.nv.attackingTeam, Vector( 842, 1007, 500 ), Vector( 0, 270, 0 ) )
	AddLoadoutCrate( level.nv.attackingTeam, Vector( -316, -1327, 184 ), Vector( 0, 90, 0 ) )

	AddStationaryTitanPosition( Vector( -1966, -3063, 5 ) )
	AddStationaryTitanPosition( Vector( -2494, -3913, 0 ) )
	AddStationaryTitanPosition( Vector( 1521, -3925, -11 ) )
	AddStationaryTitanPosition( Vector( 3605, -2395, 0 ) )
	AddStationaryTitanPosition( Vector( 4274, -1079, 50 ) )
	AddStationaryTitanPosition( Vector( 3669, 404, 211 ) )
	AddStationaryTitanPosition( Vector( 3309, 3265, 255 ) )
	AddStationaryTitanPosition( Vector( 2048, 4224, 271 ) )
	AddStationaryTitanPosition( Vector( -608, 4029, 449 ) )
	AddStationaryTitanPosition( Vector( -2691, 2634, 249 ) )
	AddStationaryTitanPosition( Vector( -3622, 1678, 238 ) )
	AddStationaryTitanPosition( Vector( -4613, -11, 176 ) )
	AddStationaryTitanPosition( Vector( -3783, -2008, 1 ) )

	TowerDefense_AddSniperLocation( Vector( 1214, 1088, 904 ), 	-121 )
	TowerDefense_AddSniperLocation( Vector( 270, 1135, 904 ),		-70 )
	TowerDefense_AddSniperLocation( Vector( -274, 737, 928 ),		-70 )
	TowerDefense_AddSniperLocation( Vector( -2023, -799, 512 ),		77 )
	TowerDefense_AddSniperLocation( Vector( 2436, 201, 472 ),		180 )

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

function Nexus_AddWaveNames()
{
	AddWaveName( "name_machinewar", "Machine War" )
	AddWaveName( "name_nukeapoc", "Nuclear Apocalypse" )
	AddWaveName( "name_onslaught", "Final Onslaught!" )
}

function Nexus_SetupWaveSpawns()
{
	if ( IsClient() )
		return

	//Nexus Waves
	CommonWave_Nexus_Waves()

}
