// NOTE this gets run on both client and server!
function main()
{
	Assert( GAMETYPE == COOPERATIVE )
	Swampland_SetupRoutesAndPositions()

	Swampland_SetupWaveSpawns()
	//TestWaves()
}

function Swampland_SetupRoutesAndPositions()
{
	if ( !IsServer() )
		return

		TowerDefense_AddGeneratorLocation( Vector( -6315, -746, -126 ), Vector( 0, 0, 0 ) )
		SetCustomPlayerDropshipSpawn( TEAM_MILITIA, Vector( -6953, -778, -156 ), Vector( 0, -5, 0 ), Vector( -5690, -1124, 320 ), Vector( 0, 144, 0 ) )
    	SetCustomWaveSpawn_SideView( Vector(  -7600, -900, 0 ), Vector( 0, -10, 0 ))	// Vector(  -6056, -547, 346 ), Vector( 0, -145, 0 ))


//FAR ROUTES
		local centerRoute = [ Vector( -176, -563, 255 ), Vector( -3772, -67, -167 ), Vector( -5827, -431, -127 ) ]
		TowerDefense_AddRoute( centerRoute, "centerRoute" )

		local bonerRoute = [ Vector( -1889, 4273, -15 ), Vector( -6783, 67, -159 ) ]
		TowerDefense_AddRoute( bonerRoute, "bonerRoute" )

		local processingRoute = [ Vector( -2575, -5215, -15 ), Vector( -6913, -1288, -156 ) ]
		TowerDefense_AddRoute( processingRoute, "processingRoute" )
//CLOSE ROUTES
		local centerRouteClose = [ Vector( -3055, -1407, 326 ), Vector( -5788, -769, -127 ) ]
		TowerDefense_AddRoute( centerRouteClose, "centerRouteClose", false )

		local templeRouteClose = [ Vector( -3142, 963, 6 ), Vector( -5883, -424, -127 ) ]
		TowerDefense_AddRoute( templeRouteClose, "templeRouteClose", false )

		local clearcutRouteClose = [ Vector( -3892, -2526, 200 ), Vector( -5832, -1206, -127 ) ]
		TowerDefense_AddRoute( clearcutRouteClose, "clearcutRouteClose", false )


	AddLoadoutCrate( level.nv.attackingTeam, Vector( -5375, -858, 383 ), Vector( 0, -145, 0 ) )
	AddLoadoutCrate( level.nv.attackingTeam, Vector( -4416, -304, 128 ), Vector( 0, 235, 0 ) )
//	AddLoadoutCrate( level.nv.attackingTeam, Vector( -2970, 2470, 425 ), Vector( 0, -103, 0 ) )

	AddStationaryTitanPosition( Vector( -2586, 2379, -15 ) )
	AddStationaryTitanPosition( Vector( -2787, 2848, 0 ) )
	AddStationaryTitanPosition( Vector( -3484, 2481, 18 ) )
	AddStationaryTitanPosition( Vector( -2193, 1606, 2 ) )
	AddStationaryTitanPosition( Vector( -1409, 539, -15 ) )
	AddStationaryTitanPosition( Vector( -1509, -1737, -15 ) )
	AddStationaryTitanPosition( Vector( -941, -3514, -15 ) )
	AddStationaryTitanPosition( Vector( -2022, -4066, -15 ) )
	AddStationaryTitanPosition( Vector( -2289, -6363, 67 ) )
	AddStationaryTitanPosition( Vector( 321, -2274, -3 ) )

	TowerDefense_AddSniperLocation( Vector( -2786, -856, 539 ), 	20	)

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

function Swampland_SetupWaveSpawns()
{
	if ( IsClient() )
		return

	CommonWave_Swampland_Waves()

}