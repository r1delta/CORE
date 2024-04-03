// NOTE this gets run on both client and server!
function main()
{
	Assert( GAMETYPE == COOPERATIVE )

	Lagoon_SetupRoutesAndPositions()
	Lagoon_SetupWaveSpawns()
	//TestWaves()

  if ( IsServer() )
    SetCustomWaveSpawn_SideView( Vector( 1577, 1022, 1039 ), Vector( 0, 50, 0 ) )

	//set the custom wave spawn anim
	//if ( IsServer() )
    //	SetCustomWaveSpawn_SideView( optionalOrigin, optionalAngles )
}

function Lagoon_SetupRoutesAndPositions()
{
	if ( !IsServer() )
		return

		SetCustomPlayerDropshipSpawn( TEAM_MILITIA, Vector( 2302, 1920, 400 ), Vector( 0, 170, 0 ), Vector( 3110, 1097, 975 ), Vector( 0, 164, 0 ) )

		local sandbarRoute = [ Vector( -3418, -742, 0 ), Vector( 1794, 1956, 346 ) ]
		TowerDefense_AddRoute( sandbarRoute )

		local carrierRoute = [ Vector( -3254, 3215, 43 ),  Vector(  1794, 1956, 346 ) ]
		TowerDefense_AddRoute( carrierRoute )

		local imcbaseRoute = [ Vector( -490, 7375, 54 ), Vector ( 1794, 1956, 346 ) ]
		TowerDefense_AddRoute( imcbaseRoute )

		local leftcloseRoute = [ Vector( -2040, -1737, 183 ), Vector( 1794, 1956, 346 )]
		TowerDefense_AddRoute( leftcloseRoute, "leftcloseRoute", false )

		local rightcloseRoute = [ Vector( 1555, 6567, 67 ), Vector( 1794, 1956, 346 )]
		TowerDefense_AddRoute( rightcloseRoute, "rightcloseRoute", false )

		local centercloseRoute = [ Vector( 2636, 1202, 581 ), Vector( 1794, 1956, 346 )]
		TowerDefense_AddRoute( centercloseRoute, "centercloseRoute", false )

		local skipAssert = true
		TowerDefense_AddGeneratorLocation( Vector( 1777, 2190, 340 ), Vector( 0, 0, 0 ), skipAssert ) //HACK: SHOULDN"T skip assert -> lagoon is the exception for specific reasons.

	AddLoadoutCrate( level.nv.attackingTeam, Vector( 1631, 902, 540 ), Vector( 0, 20, 0 ) )
	AddLoadoutCrate( level.nv.attackingTeam, Vector( 2602, 2867, 1100 ), Vector( 0, 0, 0 ) )
	AddLoadoutCrate( level.nv.attackingTeam, Vector( -2593, 2511, 796 ), Vector( 0, 0, 0 ) )

	AddStationaryTitanPosition( Vector( -1327, 637, 0 ) )
	AddStationaryTitanPosition( Vector( -2172, 256, 9 ) )
	AddStationaryTitanPosition( Vector( -2387, -279, 105 ) )
	AddStationaryTitanPosition( Vector( -3285, -155, 36 ) )
	AddStationaryTitanPosition( Vector( 1366, 5570, 53 ) )
	AddStationaryTitanPosition( Vector( -1759, 5850, 5 ) )
	AddStationaryTitanPosition( Vector( -2319, 5080, 14 ) )
	AddStationaryTitanPosition( Vector( -2022, 5336, 16 ) )
	AddStationaryTitanPosition( Vector( -528, 6051, 26 ) )
	AddStationaryTitanPosition( Vector( -1887, -1836, 197 ) )

	TowerDefense_AddSniperLocation( Vector( -1536, 606, 121 ), 	41 )
	TowerDefense_AddSniperLocation( Vector( -986, 1002, 116 ), 	-2 )
	TowerDefense_AddSniperLocation( Vector( 789, 4344, 364 ), 	-68 )
	TowerDefense_AddSniperLocation( Vector( 327, 4233, 192 ), 	-77 )
	TowerDefense_AddSniperLocation( Vector( -878, 4870, 421 ), 	-45 )
	TowerDefense_AddSniperLocation( Vector( 1325, 5742, 453 ), 	-76 )
	TowerDefense_AddSniperLocation( Vector( -1437, -624, 177 ), 	39 )
	TowerDefense_AddSniperLocation( Vector( -2078, -227, 158 ), 	21 )


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

function Lagoon_SetupWaveSpawns()
{
	if ( IsClient() )
		return

	//Smugglers Cove Waves
	CommonWave_Lagoon_Waves()
}