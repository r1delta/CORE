// NOTE this gets run on both client and server!

function main()
{
	//VERY IMPORTANT: if it's not coop mode - just early out
	if ( GAMETYPE != COOPERATIVE )
		return

	relic_SetupRoutesAndPositions()

	relic_SetupWaveNames()

	relic_SetupWaveSpawns()
	//TestWaves()

  if ( IsServer() )
    SetCustomWaveSpawn_SideView( Vector( -2709, -3533, 773 ), Vector( 0, 40, 0 ) )

}

function relic_SetupRoutesAndPositions()
{
	if ( !IsServer() )
		return

	SetCustomPlayerDropshipSpawn( TEAM_MILITIA, Vector( -4794, -3712, 362 ), Vector( 0, 15, 0 ), Vector( -3478, -4434, 484 ), Vector( 0, 50, 0 ) )
	//SetCustomPlayerDropshipSpawn( TEAM_IMC, Vector( -1600, -1600, 1000 ), Vector( 0, 45, 0 ), Vector( -2000, -600, 1000 ), Vector( 0, 25, 0 ) )

	local shipRoute = [ Vector( 5268, -5389, 53 ), Vector( 292, -4206, 317 ), Vector( -23, -2564, 441 ), Vector( -4140, -3099, 474 ) ]
	TowerDefense_AddRoute( shipRoute )

	local thrusterRoute = [ Vector( 5242, -3604, 94 ), Vector( -49, -2132, -207 ), Vector( -3799, -3091, 468 ) ]
	TowerDefense_AddRoute( thrusterRoute )

	local leftcloseRoute = [ Vector( -1220, -1974, -194 ), Vector( -4140, -3099, 474 )]
	TowerDefense_AddRoute( leftcloseRoute, "leftcloseRoute", false )

	local rightcloseRoute = [ Vector( -1485, -4470, 187 ), Vector( -4033, -3874, 467 )]
	TowerDefense_AddRoute( rightcloseRoute, "rightcloseRoute", false )

	local centercloseRoute = [ Vector( -1270, -3443, 2 ), Vector( -4033, -3874, 467 )]
	TowerDefense_AddRoute( centercloseRoute, "centercloseRoute", false )

	TowerDefense_AddGeneratorLocation( Vector( -4113, -3481, 456 ), Vector( 0, 22, 0 ) )


	AddLoadoutCrate( level.nv.attackingTeam, Vector( -2404, -3236, 584 ), Vector( 0, 0, 0 ) )
	AddLoadoutCrate( level.nv.attackingTeam, Vector( -2284, -4234, 312 ), Vector( 0, -270, 0 ) )


	AddStationaryTitanPosition( Vector( 2380, -2120, 87 ) )
	AddStationaryTitanPosition( Vector( 4171, -3502, 78 ) )
	AddStationaryTitanPosition( Vector( 3174, -5289, 79 ) )
	AddStationaryTitanPosition( Vector( 4182, -4990, 16 ) )
	AddStationaryTitanPosition( Vector( 4310, -5800, -12 ) )
	AddStationaryTitanPosition( Vector( 1885, -6438, 236 ) )
	AddStationaryTitanPosition( Vector( 3616, -5004, 11 ) )
	AddStationaryTitanPosition( Vector( 4145, -5606, 15 ) )
	AddStationaryTitanPosition( Vector( 4363, -6069, 14 ) )
	AddStationaryTitanPosition( Vector( 4704, -5896, 11 ) )
	AddStationaryTitanPosition( Vector( 4915, -5444, 14 ) )
	AddStationaryTitanPosition( Vector( 4343, -2774, 88 ) )
	AddStationaryTitanPosition( Vector( 3679, -1981, 83 ) )
	AddStationaryTitanPosition( Vector( 2482, -1815, 13 ) )

	TowerDefense_AddSniperLocation( Vector( -2592, -1712, 370 ), 	 -92	)
	TowerDefense_AddSniperLocation( Vector( -1086, -4954, 535 ), 	 166	)
	TowerDefense_AddSniperLocation( Vector( -753, -4072, 653 ), 	 180	)
	TowerDefense_AddSniperLocation( Vector( 477, -2153, 614 ), 	 -172	)
	TowerDefense_AddSniperLocation( Vector( -123, -3366, 731 ), 	56	)
	TowerDefense_AddSniperLocation( Vector( 372, -4618, 555 ), 	 163	)
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

function relic_SetupWaveNames()
{
	AddWaveName( "name_hidthreat", "Hidden Threats" )
	AddWaveName( "name_countersnipe", "Countersnipe" )
	AddWaveName( "name_heavyart", "Heavy Artillery" )
	AddWaveName( "name_mobilebatt", "Mobile Titan Battery" )
	AddWaveName( "name_massdest", "Weapons of Mass Destruction" )
	AddWaveName( "name_theend", "The End is Here!!" )
}

function relic_SetupWaveSpawns()
{
	if ( IsClient() )
		return

	//Wave: Relic Waves
	CommonWave_Relic()
}
