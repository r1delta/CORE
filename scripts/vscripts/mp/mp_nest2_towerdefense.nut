// NOTE this gets run on both client and server!

function main()
{
	Assert( GAMETYPE == COOPERATIVE )

	nest2_SetupRoutesAndPositions2()

	nest2_AddWaveNames()

	nest2_SetupWaveSpawns()
	
	if ( IsServer() )
	{
		//Riff_ForceSetSpawnAsTitan( eSpawnAsTitan.Never )
		//SetCustomWaveSpawn_SideView( Vector( 40, 390, 640 ), Vector( 0, 90, 0 ) )//sets dropship spawn when ya die -YoshtheHut
		SetCustomWaveSpawn_SideView( Vector( 10, -50, 1750 ), Vector( 0, 0, 0 ) )//third number is height??? pos( z,x,y )?
	}
}

function nest2_SetupRoutesAndPositions()
{
	if ( !IsServer() )
		return

	SetCustomPlayerDropshipSpawn( TEAM_MILITIA, Vector( -1310, 195, 223 ), Vector( 0, -75, 0 ), Vector( -2608, -582, 224 ), Vector( 0, 4, 0 ) )

	local NESTsouthRoute = [ Vector( 3268, 1164, 268 ), Vector( 434, -127, 176 ) ]
	TowerDefense_AddRoute( NESTsouthRoute, "NEST_south" )

	local NESTnorthRoute = [ Vector( -4403, -2016, 5 ), Vector( -680, -544, 176 ) ]
	TowerDefense_AddRoute( NESTnorthRoute, "NEST_north" )

	local NESTeastRoute = [ Vector( -89, 6028, 240 ), Vector( 434, -127, 176 ) ]
	TowerDefense_AddRoute( NESTeastRoute, "NEST_east" )

	local NESTwestRoute = [ Vector( -223, -4867, 52 ), Vector( 37, -543, 184 ) ]
	TowerDefense_AddRoute( NESTwestRoute, "NEST_west" )

	local NESTleftcloseRoute = [ Vector( -1920, 301, 176 ), Vector( -577, -339, 183 )]
	TowerDefense_AddRoute( NESTleftcloseRoute, "NEST_west_close", false )

	local NESTrightcloseRoute = [ Vector( 2400, -1319, 12 ), Vector( 14, -374, 176 )]
	TowerDefense_AddRoute( NESTrightcloseRoute, "NEST_east_close", false )

	TowerDefense_AddGeneratorLocation( Vector( -328.404, -346.739, 0.03125 ), Vector( 0, 0, 0 ) )

	AddLoadoutCrate( level.nv.attackingTeam, Vector( 842, 1007, 500 ), Vector( 0, 270, 0 ) )
	AddLoadoutCrate( level.nv.attackingTeam, Vector( -316, -1327, 184 ), Vector( 0, 90, 0 ) )

	AddLoadoutCrate( level.nv.attackingTeam, Vector( 1930, 2586, 280 ), Vector( 0, 75, 0 ) )
	AddLoadoutCrate( level.nv.attackingTeam, Vector( 2500, 1751, 280 ), Vector( 0, 15, 0 ) )
	AddLoadoutCrate( level.nv.attackingTeam, Vector( 1565, 1508, 248 ), Vector( 0, 270, 0 ) )


	AddStationaryTitanPosition( Vector( 1110, -3434, -262 ) )
	AddStationaryTitanPosition( Vector( -427, -2731, -176 ) )
	AddStationaryTitanPosition( Vector( -1727, 3481, -182 ) )
	AddStationaryTitanPosition( Vector( -2094, 2415, -191 ) )
	AddStationaryTitanPosition( Vector( -3007, 3139, -241 ) )
	AddStationaryTitanPosition( Vector( -153, -2863, -194 ) )

}

function nest2_SetupRoutesAndPositions2()
{
	if ( !IsServer() )
		return

	//SetCustomPlayerDropshipSpawn( TEAM_MILITIA, Vector( -1310, 195, 223 ), Vector( 0, -75, 0 ), Vector( -2608, -582, 224 ), Vector( 0, 4, 0 ) )

	local NESTsouthwestRoute = [ Vector( -2919.05, -2704.99, 4.53898 ), Vector( -616.71, -999.941, 0.03125 ) ]
	TowerDefense_AddRoute( NESTsouthwestRoute, "NEST_south_west" )

	local NESTnorthRoute = [ Vector( 3048.95, 2639.92, 50.0313 ), Vector( -124.128, 325.275, 0.0315 ) ]
	TowerDefense_AddRoute( NESTnorthRoute, "NEST_north" )

	local NESTeastRoute = [ Vector( 3048.95, 2639.92, 50.0313 ), Vector( 909.25, 3191.6, 128.031 ), Vector( -7.05391, 163.913, 0.03125 ) ]
	TowerDefense_AddRoute( NESTeastRoute, "NEST_east" )

	local NESTwestRoute = [ Vector( -2802.44, 2559.26, -63.9688 ), Vector( -1582.39, -153.07, -11.2176 ), Vector( -607.945, -291.55, 12.0313 ) ]
	TowerDefense_AddRoute( NESTwestRoute, "NEST_west" )

	local NESTsoutheast = [ Vector( 3396.02, -2735.54, 8.03123 ), Vector( 2099.82, -2062.07, -223.969 ), Vector( -51.3113, -1164.28, 0.03125 ) ]
	TowerDefense_AddRoute( NESTsoutheast, "NEST_south_east" )

	TowerDefense_AddGeneratorLocation( Vector( -328.404, -346.739, 0.03125 ), Vector( 0, 0, 0 ) )

	AddLoadoutCrate( level.nv.attackingTeam, Vector( 197.362, -392.614, 288.031 ), Vector( 0, 0, 0 ) )
	AddLoadoutCrate( level.nv.attackingTeam, Vector( -1908.53, -1086.95, 336.031 ), Vector( 0, 90, 0 ) )

	//AddLoadoutCrate( level.nv.attackingTeam, Vector( 1930, 2586, 280 ), Vector( 0, 75, 0 ) )
	//AddLoadoutCrate( level.nv.attackingTeam, Vector( 2500, 1751, 280 ), Vector( 0, 15, 0 ) )
	//AddLoadoutCrate( level.nv.attackingTeam, Vector( 1565, 1508, 248 ), Vector( 0, 270, 0 ) )


	//AddStationaryTitanPosition( Vector( 1110, -3434, -262 ) )
	AddStationaryTitanPosition( Vector( 2988.66, -2794.58, 8.03125 ) )
	AddStationaryTitanPosition( Vector( 3598.08, 568.166, -11.6658 ) )
	
	AddStationaryTitanPosition( Vector( -2282.85, 3454.31, -65.9688 ) )
	AddStationaryTitanPosition( Vector( -1706.25, 3480.48, -65.9688 ) )
	AddStationaryTitanPosition( Vector( 730.026, -4073.47, 2.03125 ) )

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

function nest2_AddWaveNames()
{
	AddWaveName( "name_nest1", "Surrounding Threat" )
	AddWaveName( "name_nest2", "Spectres of Death" )
	AddWaveName( "name_nest3", "Titan Activation" )
	AddWaveName( "name_nest4", "Bullet Storm" )
	AddWaveName( "name_nest5", "Missile Rain" )
	AddWaveName( "name_nest6", "Budget Issues" )
	AddWaveName( "name_nest7", "Thunder Strikes" )
	AddWaveName( "name_nest8", "Accelerating Fusion" )
	AddWaveName( "name_nest9", "Final Hour" )// Yoshi was here
}

function nest2_SetupWaveSpawns()
{
	if ( IsClient() )
		return

	//Nexus Waves
	CommonWave_NEST_Waves()

}
