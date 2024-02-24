// NOTE this gets run on both client and server!
function main()
{
	Assert( GAMETYPE == COOPERATIVE )
	Overlook_SetupRoutesAndPositions()
	//Overlook_CreateWaveNames()
	Overlook_SetupWaveSpawns()

  if ( IsServer() )
    SetCustomWaveSpawn_SideView( Vector(  2204, 1512, 200 ), Vector(  0, 156, 0 ), "dropship_coop_respawn_overlook" )
}

function Overlook_SetupRoutesAndPositions()
{
	if ( !IsServer() )
		return


		local mainHallRoute = [ Vector( -2038, -239, 0 ),  Vector(  3285, -507, 0 ),  Vector( 4312, 1013, -167 ),  Vector( 2420, 1747, -255 ) ]
		TowerDefense_AddRoute( mainHallRoute, "mainHallRoute" )

		local landingpadCloseRoute = [ Vector( -1140, 1975, -252),  Vector( 1845, 2396, -255 ) ]
		TowerDefense_AddRoute( landingpadCloseRoute, "landingpadCloseRoute", false )

		local undergroundCloseRoute = [ Vector( -55, -3174, 0 ), Vector( 767, -2393, -264 ),  Vector( 1657, 1270, -255 ) ]
		TowerDefense_AddRoute( undergroundCloseRoute, "undergroundCloseRoute", false )

		local hangarCloseRoute = [ Vector( 2270, -2751, -159 ),  Vector( 2301, 1401, -255 ) ]
		TowerDefense_AddRoute( hangarCloseRoute, "hangarCloseRoute", false )


		TowerDefense_AddGeneratorLocation( Vector( 2048, 1760, -256 ), Vector( 0, 0, 0 ) )

		SetCustomPlayerDropshipSpawn( TEAM_MILITIA, Vector( 3000, 2100, 0 ), Vector( 0, -145, 0 ), Vector( 2438, 1851, 322 ), Vector( 0, -157, 0 ) )

	AddLoadoutCrate( level.nv.attackingTeam, Vector( 2312, 1104, 0 ), Vector( 0, -90, 0 ) )//generator control room
	AddLoadoutCrate( level.nv.attackingTeam, Vector( 2840, -1144, 112 ), Vector( 0, 180, 0 ) )//hangar
	AddLoadoutCrate( level.nv.attackingTeam, Vector( -264, 752, 0 ), Vector( 0, 45, 0 ) )//landing pad control room
//	AddLoadoutCrate( level.nv.attackingTeam, Vector( 1072, -1536, 0 ), Vector( 0, -180, 0 ) )//center control room

	AddStationaryTitanPosition( Vector( -2805, -2239, -167.5 ) )
	AddStationaryTitanPosition( Vector( -1396, -3942, -232 ) )
	AddStationaryTitanPosition( Vector( -1163, -4640, -384 ) )
	AddStationaryTitanPosition( Vector( -305, -4248, 0 ) )
	AddStationaryTitanPosition( Vector( -2945, -1296, -128 ) )
	AddStationaryTitanPosition( Vector( -2091, -1129, 4 ) )
	AddStationaryTitanPosition( Vector( -2280, -1664, -131 ) )
	AddStationaryTitanPosition( Vector( 1168, -6005, 0 ) )
	AddStationaryTitanPosition( Vector( 352, -5033, 0 ) )
	AddStationaryTitanPosition( Vector( -492, -3284, 8 ) )//SHITTY SPOT TO SKIP STUPID ASSERT
/*
	TowerDefense_AddSniperLocation( Vector( -2740, 2109, 1040 ), 	-90 		)
	TowerDefense_AddSniperLocation( Vector( -2065, 987, 704 ), 		-112 		)
*/




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

function Overlook_CreateWaveNames()
{
	AddWaveName( "name_warm_up", "Close Call" )

}

function Overlook_SetupWaveSpawns()
{
	if ( IsClient() )
		return

	CommonWave_Overlook_Waves()

}

function Overlook_SpawnStartingGrunts()
{

	SpawnGrunt( TEAM_IMC, "intro_guys", Vector( 2134, 2495,1 -195 ), Vector( 0, -94, 0 ) )
	SpawnGrunt( TEAM_IMC, "intro_guys", Vector( 1956, 2294, -195 ), Vector( 0, -77, 0 ) )
	SpawnGrunt( TEAM_IMC, "intro_guys", Vector( 1616, 2416, -195 ), Vector( 0, -61, 0 ) )
	SpawnGrunt( TEAM_IMC, "intro_guys", Vector( 1483, 1444, -189 ), Vector( 0, 25, 0 ) )
	SpawnGrunt( TEAM_IMC, "intro_guys", Vector( 1452, 1101, -195  ), Vector( 0, 48, 0 ) )
	SpawnGrunt( TEAM_IMC, "intro_guys", Vector( 1900, 1253, -195 ), Vector( 0, 67, 0 ) )

}