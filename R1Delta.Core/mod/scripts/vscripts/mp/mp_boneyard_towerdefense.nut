// NOTE this gets run on both client and server!

function main()
{
	Assert( GAMETYPE == COOPERATIVE )

	Boneyard_SetupRoutesAndPositions()

	Boneyard_SetupWaveNames()

	Boneyard_SetupWaveSpawns()
	//TestWaves()

}

function Boneyard_SetupRoutesAndPositions()
{
	if ( !IsServer() )
		return

	//set the custom wave spawn anim
	SetCustomWaveSpawn_SideView()

	SetCustomPlayerDropshipSpawn( TEAM_MILITIA, Vector( 2509, -81, 550 ), Vector( 0, 175, 0 ), Vector( 2244, 616, 429 ), Vector( 0, -138, 0 ) )
	//SetCustomPlayerDropshipSpawn( TEAM_IMC, Vector( -1600, -1600, 1000 ), Vector( 0, 45, 0 ), Vector( -2000, -600, 1000 ), Vector( 0, 25, 0 ) )

	local dogwhistleRoute = [ Vector( -1966, 2459, 121 ), Vector( -1250, 2574, 287 ), Vector( 503, 1182, 216 ), Vector( 2027, 258, 424 ) ]
	TowerDefense_AddRoute( dogwhistleRoute )

	local underpassRoute = [ Vector( -2770, 574, -128 ), Vector( -1170, -821, -346 ), Vector( -323, -514, -207 ), Vector( 1940, -193, 424 ) ]
	TowerDefense_AddRoute( underpassRoute )

	local carrierRoute = [ Vector( -2797, -3454, 29 ), Vector( -684, -2721, 50 ), Vector( 2471, -83, 670 ) ]
	TowerDefense_AddRoute( carrierRoute )

	local leftcloseRoute = [ Vector( -245, -2520, 127 ), Vector( 1918, -393, 424 )]
		TowerDefense_AddRoute( leftcloseRoute, "leftcloseRoute", false )

	local middlecloseRoute = [ Vector( 990, 858, 322 ), Vector( 1986, 524, 446 )]
		TowerDefense_AddRoute( middlecloseRoute, "middlecloseRoute", false )


	TowerDefense_AddGeneratorLocation( Vector( 2070, 26, 428 ), Vector( 0, -106, 0 ) )


	//Loadout Crate Small Bunker
	AddLoadoutCrate( level.nv.attackingTeam, Vector( 1105, -501, 356 ), Vector( 0, -119, 0 ) )
	//Loadout Evac Bunker Interior
	AddLoadoutCrate( level.nv.attackingTeam, Vector( 1986, 1323, 581 ), Vector( 0, 29, 0 ) )
	//Loadout Blown Out Bunker
	AddLoadoutCrate( level.nv.attackingTeam, Vector( 30, 44, 336 ), Vector( 0, 105, 0 ) )


	//landing pad
	AddStationaryTitanPosition( Vector( -1616, -3556, 108 ) )
	//in front of A
	AddStationaryTitanPosition( Vector( -3221., -117, -9 ) )
	//hill between skull and dog whistle
	AddStationaryTitanPosition( Vector( -1729, 1871, 237 ) )
	//bottom of pit
	AddStationaryTitanPosition( Vector( -1188, 579, -260 ) )
	//behind tank
	AddStationaryTitanPosition( Vector( -4066, -3355, 12 ) )
	//dune hills
	AddStationaryTitanPosition( Vector( -1102, -4445, 463 ) )
	//next to barrack bunker`
	AddStationaryTitanPosition( Vector( -2878, 939, -26 ) )
	//militia start spawn
	AddStationaryTitanPosition( Vector( -3219, 2925, 238 ) )
	//crashed droppods
	AddStationaryTitanPosition( Vector( -2472, -5170, 207 ) )
	//on the carrier
	AddStationaryTitanPosition( Vector( -2861, -3472, 29 ) )


	TowerDefense_AddSniperLocation( Vector( -216, -925, 345 ), 	37 	)
	TowerDefense_AddSniperLocation( Vector( -205, -605, 384 ), 	-2 	)
	TowerDefense_AddSniperLocation( Vector( -423, 150, 349 ), 	179  )
	TowerDefense_AddSniperLocation( Vector( -566, 1061, 186 ), 	-125  )
	TowerDefense_AddSniperLocation( Vector( 484, -217, 295 ), 	-26  )
	TowerDefense_AddSniperLocation( Vector( -2427, -99, 219 ), 	63 	)
	TowerDefense_AddSniperLocation( Vector( -1939, 713, 167 ), -40  )
	TowerDefense_AddSniperLocation( Vector( -3095, -652, 215 ),  116 )
	TowerDefense_AddSniperLocation( Vector( -2055, -1790, -99 ),  -53 )
	TowerDefense_AddSniperLocation( Vector( -2859, -3740, 180 ),  39 )
	TowerDefense_AddSniperLocation( Vector( 707, 2041, 542 ),  -44 )
	TowerDefense_AddSniperLocation( Vector( -764, 1237, 162 ),  -128 )
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

function Boneyard_SetupWaveNames()
{
	//AddWaveName( "name_workclass", "Working Class" )
	AddWaveName( "name_hidthreat", "Hidden Threats" )
	AddWaveName( "name_cloakass", "Cloaked Assault" )
	AddWaveName( "name_countersnipe", "Countersnipe" )
	AddWaveName( "name_heavyart", "Heavy Artillery" )
	AddWaveName( "name_mobilebatt", "Mobile Titan Battery" )
	AddWaveName( "name_massdest", "Weapons of Mass Destruction" )
	AddWaveName( "name_theend", "The End is Here!!" )
}

function Boneyard_SetupWaveSpawns()
{
	if ( IsClient() )
		return

	//Wave: Boneyard Waves
	CommonWave_Boneyard_Waves()
}
