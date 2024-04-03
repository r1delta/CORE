// NOTE this gets run on both client and server!

function main()
{
	Assert( GAMETYPE == COOPERATIVE )

	Harmony_Mines_SetupRoutesAndPositions()

	Harmony_Mines_AddWaveNames()

	Harmony_Mines_SetupWaveSpawns()
	//TestWaves()

	  if ( IsServer() )
    SetCustomWaveSpawn_SideView( Vector( -1194, 452, 858 ), Vector( 0, -87, 0 ), "dropship_coop_respawn_digsite" )
}

function Harmony_Mines_SetupRoutesAndPositions()
{
	if ( !IsServer() )
		return

		SetCustomPlayerDropshipSpawn( TEAM_MILITIA, Vector( -1310, 195, 223 ), Vector( 0, -75, 0 ), Vector( -2608, -582, 224 ), Vector( 0, 4, 0 ) )

		local oneRoute = [ Vector( -4291, 1087, -223 ), Vector( -3259, -484, 209 ), Vector( -1700, -432, 224 ) ]
		TowerDefense_AddRoute( oneRoute )

		local twoRoute = [ Vector( 1750, 1173, 132 ),  Vector( -239, 1160, 220 ),  Vector( -1205, 47, 223 ) ]
		TowerDefense_AddRoute( twoRoute, "twoRoute" )

		local threeRoute = [ Vector( 877, -3571, -63 ), Vector ( -781, -2056, 227 ), Vector ( -1017, -786, 219 ) ]
		TowerDefense_AddRoute( threeRoute )

		local fourRoute = [ Vector( 713, -4196, -64 ), Vector ( -2270, -3078, 160 ),  Vector( -1623, -1632, 200 ),  Vector( -978, -711, 221 ) ]
		TowerDefense_AddRoute( fourRoute, "fourRoute" )

		local leftcloseRoute = [ Vector( 414, -2110, 43 ), Vector( -1034, -772, 219 )]
		TowerDefense_AddRoute( leftcloseRoute, "leftcloseRoute", false )

		local rightcloseRoute = [ Vector( -3321, -865, 191 ), Vector( -1661, -419, 224 )]
		TowerDefense_AddRoute( rightcloseRoute, "rightcloseRoute", false )

		local centercloseRoute = [ Vector( -1480, -1678, 199 ), Vector( -1452, -537, 224 )]
		TowerDefense_AddRoute( centercloseRoute, "centercloseRoute", false )

	TowerDefense_AddGeneratorLocation( Vector( -1151, -400, 223 ), Vector( 0, 0, 0 ) )

	AddLoadoutCrate( level.nv.attackingTeam, Vector( -116, -150, 544 ), Vector( 0, 267, 0 ) )
	AddLoadoutCrate( level.nv.attackingTeam, Vector( -2006, -1026, 512 ), Vector( 0, 90, 0 ) )
	AddLoadoutCrate( level.nv.attackingTeam, Vector( -1830, 91, 368 ), Vector( 0, 180, 0 ) )

	AddStationaryTitanPosition( Vector( -606, -4702, 126) )
	AddStationaryTitanPosition( Vector( -492, -4081, 145 ) )
	AddStationaryTitanPosition( Vector( -4690, -323, -43 ) )
	AddStationaryTitanPosition( Vector( -4338, -1384, 73 ) )
	AddStationaryTitanPosition( Vector( -3898, -1357, 86 ) )
	AddStationaryTitanPosition( Vector( 1700, 2373, 74 ) )

//	TowerDefense_AddSniperLocation( Vector(  ), 	 )

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

function Harmony_Mines_AddWaveNames()
{
	AddWaveName( "name_machinewar", "Machine War" )
	AddWaveName( "name_nukeapoc", "Nuclear Apocalypse" )
	AddWaveName( "name_onslaught", "Final Onslaught!" )
}

function Harmony_Mines_SetupWaveSpawns()
{
	if ( IsClient() )
		return

	//Rise Hardcore Waves
	CommonWave_Harmony_Mines_Waves()

}