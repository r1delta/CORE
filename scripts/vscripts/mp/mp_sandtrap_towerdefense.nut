// NOTE this gets run on both client and server!
function main()
{
	Assert( GAMETYPE == COOPERATIVE )
	Sandtrap_SetupRoutesAndPositions()

	Sandtrap_SetupWaveSpawns()
	//TestWaves()

	  if ( IsServer() )
    SetCustomWaveSpawn_SideView( Vector(  -3768, -702, 100 ), Vector( 0, 0, 0 ) )

	//set the custom wave spawn anim
	//if ( IsServer() )
    //	SetCustomWaveSpawn_SideView( optionalOrigin, optionalAngles )
}

function Sandtrap_SetupRoutesAndPositions()
{
	if ( !IsServer() )
		return

		SetCustomPlayerDropshipSpawn( TEAM_MILITIA, Vector( -2800, -1509, 300 ), Vector( 0, 130, 0 ), Vector( -3724, -1069, 41 ), Vector( 0, 12, 0 ) )

//ROUTES
	//DUNES
	local LowerRoute = [ Vector(  -2512, -5667, -234 ),  Vector( -2281, -3667, 0 ),  Vector( -4092, -2415, 3 ),  Vector( -3922, -955, 8 ) ]
	TowerDefense_AddRoute( LowerRoute, "LowerRoute" )

	//HANGAR  
	local UpperRoute = [ Vector( -223, 2267, -127 ),  Vector( -776, 1719, -125 ),  Vector( -719, 976, 0 ),  Vector( -742, 692, -4 ),  Vector( -956, 689, -4 ),  Vector( -1611, 742, 0 ),  Vector( -3207, -66, 3 ) ]
	TowerDefense_AddRoute( UpperRoute, "UpperRoute" )

	//CLOSE HANGAR
	local LowerBravoCloseRoute = [ Vector(  -2066, 1993, -123 ),  Vector( -2689, -252, 57 ) ]
	TowerDefense_AddRoute( LowerBravoCloseRoute, "LowerBravoCloseRoute", false )

	//CLOSE BRAVO
	local UpperCloseRoute = [ Vector( -1476, -2386, 192 ),  Vector( -2675, -1101, 131) ]
	TowerDefense_AddRoute( UpperCloseRoute, "UpperCloseRoute", false )

	//CLOSE CYLINDERS
	local LowerCharlieCloseRoute = [ Vector(  -5396, 1332, -32 ),  Vector( -3422, -664, 0 ) ]
	TowerDefense_AddRoute( LowerCharlieCloseRoute, "LowerCharlieCloseRoute", false )

	TowerDefense_AddGeneratorLocation( Vector( -3315, -904, 0 ), Vector( 0, 0, 0 ) )

	AddLoadoutCrate( level.nv.attackingTeam, Vector( -2670, -1500, 0 ), Vector( 0, 0, 0 ) )
	AddLoadoutCrate( level.nv.attackingTeam, Vector( -2760, 1029, 160 ), Vector( 0, 135, 0 ) )
	AddLoadoutCrate( level.nv.attackingTeam, Vector( -4115, -3207, 0 ), Vector( 0, 135, 0 ) )


//	AddStationaryTitanPosition( Vector( -2056, 3035, 7 ) )

//	TowerDefense_AddSniperLocation( Vector( -829, -3430, 544 ), 	70	)
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

function Sandtrap_SetupWaveSpawns()
{
	if ( IsClient() )
		return

	//Relic waves
	CommonWave_Sandtrap_Waves()
}