// NOTE this gets run on both client and server!

function main()
{
	//VERY IMPORTANT: if it's not coop mode - just early out
	if ( GAMETYPE != COOPERATIVE )
		return
		
  	if ( IsServer() )
    SetCustomWaveSpawn_SideView( Vector( -1122, -483, 129 ), Vector( 0, 147, 0 ), "dropship_coop_respawn_outpost" )

	Outpost_207_SetupRoutesAndPositions()

	Outpost_207_SetupWaveNames()

	Outpost_207_SetupWaveSpawns()
	//TestWaves()
}

function Outpost_207_SetupRoutesAndPositions()
{
	if ( !IsServer() )
		return

	SetCustomPlayerDropshipSpawn( TEAM_MILITIA, Vector( -2541, -331, -322 ), Vector( 0, 0, 0 ), Vector( -2364, -1039, -191 ), Vector( 0, 53, 0 ) )

	local centerRoute = [ Vector( 4388, -688, -703 ), Vector( 75, 928, -308 ), Vector( -1754, -265, -318 ) ]
	TowerDefense_AddRoute( centerRoute )

	local cannonRoute = [ Vector( 3053, -1146, -481 ), Vector( -1714, -535, -317 ) ]
	TowerDefense_AddRoute( cannonRoute )

	local bridgeRoute = [ Vector( 2344, 3316, -328 ), Vector( 304, 3278, -317 ), Vector( -2261, -375, -317 ) ]
	TowerDefense_AddRoute( bridgeRoute )

	local leftcloseRoute = [ Vector( -2837, 1909, -191 ), Vector( -2261, -375, -317 )]
	TowerDefense_AddRoute( leftcloseRoute, "leftcloseRoute", false )

	local rightcloseRoute = [ Vector( 1325, -757, -448 ), Vector( -1714, -535, -317 )]
	TowerDefense_AddRoute( rightcloseRoute, "rightcloseRoute", false )

	local centercloseRoute = [ Vector( 58, 897, -317 ), Vector( -1754, -265, -318 )]
	TowerDefense_AddRoute( centercloseRoute, "centercloseRoute", false )

	TowerDefense_AddGeneratorLocation( Vector( -1965, -469, -317 ), Vector( 0, 0, 0 ) )

	AddLoadoutCrate( level.nv.attackingTeam, Vector( -2280, 879, -359 ), Vector( 0, 270, 0 ) )
	AddLoadoutCrate( level.nv.attackingTeam, Vector( -1080, -615, -63 ), Vector( 0, -4, 0 ) )
	AddLoadoutCrate( level.nv.attackingTeam, Vector( -1668, 2009, -55 ), Vector( 0, 255, 0 ) )

	AddStationaryTitanPosition( Vector( 1535, -1362, -445 ) )
	AddStationaryTitanPosition( Vector( 2086, -1903, -447 ) )
	AddStationaryTitanPosition( Vector( 2801, -1657, -445 ) )
	AddStationaryTitanPosition( Vector( 1774, 1252, -315 ) )
	AddStationaryTitanPosition( Vector( 2193, 777, -475 ) )
	AddStationaryTitanPosition( Vector( 2959, 2862, -329 ) )
	AddStationaryTitanPosition( Vector( 2479, 3253, -326 ) )
	AddStationaryTitanPosition( Vector( 2340, 3715, -313 ) )
	AddStationaryTitanPosition( Vector( 4105, -46, -711 ) )
	AddStationaryTitanPosition( Vector( 4406, -761, -703 ) )
	AddStationaryTitanPosition( Vector( 4580, 9, -693 ) )

//	TowerDefense_AddSniperLocation( Vector(  ), 	 	)

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

	local wave = TowerDefense_AddWave( name_gruntwork )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad )

	local wave = TowerDefense_AddWave()
	Wave_AddSpawn( wave, TD_SpawnGruntSquad )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad )

	local wave = TowerDefense_AddWave( name_machinewar )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad )

	local wave = TowerDefense_AddWave( name_nukeapoc )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan )
}

function Outpost_207_SetupWaveNames()
{
	AddWaveName( "name_contact", "Contact" )
	AddWaveName( "name_robobabylon", "Robot Babylon" )
	AddWaveName( "name_redeye", "Red Eyes" )
	AddWaveName( "name_aerialavalance", "Aerial Avalanche" )
	AddWaveName( "name_advent", "Advent" )
	AddWaveName( "name_mutual", "Mutually Assured Destruction" )
}

function Outpost_207_SetupWaveSpawns()
{
	if ( IsClient() )
		return

	//Wave: Relic Waves
	CommonWave_Relic()
}
