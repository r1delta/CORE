// NOTE this gets run on both client and server!
function main()
{
	Assert( GAMETYPE == COOPERATIVE )
	Fracture_SetupRoutesAndPositions()
	Fracture_SetupWaveSpawns()

  if ( IsServer() )
    SetCustomWaveSpawn_SideView( )
}

function Fracture_SetupRoutesAndPositions()
{
	if ( !IsServer() )
		return

	TowerDefense_AddGeneratorLocation( Vector( 2320, -544, 105 ), Vector( 0, 0, 0 ) )
	SetCustomPlayerDropshipSpawn( TEAM_MILITIA, Vector( 3682, -309, -12 ), Vector( 0, -170, 0 ), Vector( 2575, -1220, 260 ), Vector( 0, 100, 0 ) )
	SetCustomWaveSpawn_SideView( Vector(  2688, -750, 250 ), Vector( 0, 125, 0 ) )

	AddLoadoutCrate( level.nv.attackingTeam, Vector( 2170, 220, 358 ), Vector( 0, 0, 0 ) )  //Center building not B
	AddLoadoutCrate( level.nv.attackingTeam, Vector( 510, -594, 624 ), Vector( 0, 90, 0 ) )//center dirt
	AddLoadoutCrate( level.nv.attackingTeam, Vector( 2600, -1544, 480), Vector( 0, -160, 0 ) )//B


//ROUTES
	//CHARLIE
	local LowerRoute = [ Vector( 4419, 3866, -152 ),  Vector( 2898, 3220, -23 ),  Vector( 1745, -272, 172 ) ]
	TowerDefense_AddRoute( LowerRoute, "LowerRoute" )

	//APLHA
	local UpperRoute = [ Vector( -1425, -3894, 285 ),  Vector( 1021, -3389, 320 ),  Vector( 1778, -946, 173 ) ]
	TowerDefense_AddRoute( UpperRoute, "UpperRoute" )

	//UPPER CLOSE FIELD
	local UpperCloseRoute = [ Vector( -1332, -1205, 272 ),  Vector( 1626, -500, 172 ) ]
	TowerDefense_AddRoute( UpperCloseRoute, "UpperCloseRoute", false )

	//LOWER CLOSE BRAVO
	local LowerBravoCloseRoute = [ Vector( 4674, -2297, -126 ),  Vector( 4541, -1816, -122 ),  Vector( 3097, -457, 36 ) ]
	TowerDefense_AddRoute( LowerBravoCloseRoute, "LowerBravoCloseRoute", false )

	//LOWER CLOSE CHARLIE
	local LowerCharlieCloseRoute = [ Vector( 4324, 1889, -53 ),  Vector( 2766, 1729, -12 ),  Vector( 3206, -171, 9 ) ]
	TowerDefense_AddRoute( LowerCharlieCloseRoute, "LowerCharlieCloseRoute", false )

//mortar titan locations
//Behind B
	AddStationaryTitanPosition( Vector( 4294, -2290, -128 ) )
	AddStationaryTitanPosition( Vector( 3930, -1770, 38 ) )
	AddStationaryTitanPosition( Vector( 5071, 376, 202 ) )
	AddStationaryTitanPosition( Vector( 4238, -89, -28) )
	AddStationaryTitanPosition( Vector( 4793, 1808, -48 ) )

//Behind C
	AddStationaryTitanPosition( Vector( 3174, 1136, 143 ) )
	AddStationaryTitanPosition( Vector( 5323, 2890, -125) )
	AddStationaryTitanPosition( Vector( 4242, 4087, -168 ) )
	AddStationaryTitanPosition( Vector( 4604, 3556, -128 ) )
	AddStationaryTitanPosition( Vector( 4760, 3300, -124 ) )


//Sniper spots
	TowerDefense_AddSniperLocation( Vector( -648, -3452, 654 ), -35 )
	TowerDefense_AddSniperLocation( Vector( 571, -3319, 475 ), -143 )
	TowerDefense_AddSniperLocation( Vector( -504, -3096, 427 ), -70 )
	TowerDefense_AddSniperLocation( Vector( 1076, -3828, 270 ), 137 )
	TowerDefense_AddSniperLocation( Vector( 1430, -4109, 312 ), 173 )
	TowerDefense_AddSniperLocation( Vector( 964, -5422, 101 ), 147 )
	TowerDefense_AddSniperLocation( Vector( -68, -5145, 310 ), 86 )
	TowerDefense_AddSniperLocation( Vector( 83, -5310, 230 ), 103 )
	TowerDefense_AddSniperLocation( Vector( -1988, -3922, 327 ), 50 )
	TowerDefense_AddSniperLocation( Vector( -2675, -3434, 634 ), 16 )



/*
//CENTER OF MAP
	TowerDefense_AddGeneratorLocation( Vector( 1790, -464, 174 ), Vector( 0, 0, 0 ) )
	SetCustomPlayerDropshipSpawn( TEAM_MILITIA, Vector( 2652, -1331, 1127 ), Vector( 0, 135, 0 ) )

	AddLoadoutCrate( level.nv.attackingTeam, Vector( 2170, 220, 358 ), Vector( 0, 0, 0 ) )  //Center building not B
	AddLoadoutCrate( level.nv.attackingTeam, Vector( 510, -594, 624 ), Vector( 0, 90, 0 ) )//center dirt
	AddLoadoutCrate( level.nv.attackingTeam, Vector( 2600, -1544, 480), Vector( 0, -180, 0 ) )//B


//mortar titan locations
//sink hole titans
	AddStationaryTitanPosition( Vector( 5680, 4832, -288 ) )
	AddStationaryTitanPosition( Vector( 5368, 4352, -304) )
	AddStationaryTitanPosition( Vector( 6320, 3960, -256 ) )
	AddStationaryTitanPosition( Vector( 6944, 3008, -168 ) )
	AddStationaryTitanPosition( Vector( 6528, 2328, -216 ) )
// IMC start
	AddStationaryTitanPosition( Vector( -4144, -4616, 144 ) )
	AddStationaryTitanPosition( Vector( -2840, -5120, 112) )
	AddStationaryTitanPosition( Vector( -2280, -4560, 136 ) )
	AddStationaryTitanPosition( Vector( -1824, -4984, 160 ) )
	AddStationaryTitanPosition( Vector( -4336, -3112, 192 ) )
// Behind curved building
	AddStationaryTitanPosition( Vector( 136, -5704, 216 ) )
	AddStationaryTitanPosition( Vector( 0, -5392, 240 ) )
	AddStationaryTitanPosition( Vector( 592, -5408, 144 ) )
// near refueling point
	AddStationaryTitanPosition( Vector( -1216, -488, 272 ) )
	AddStationaryTitanPosition( Vector( -2048, -400, 144 ) )
	AddStationaryTitanPosition( Vector( -2360, -632, 136 ) )

//Sniper spots
	TowerDefense_AddSniperLocation( Vector( 2432, 704, 568 ), 90 )


	local charlieRoute = [ Vector( 3728, 4248, -192 ),  Vector( 1576, 296, 128 ) ]
	TowerDefense_AddRoute( charlieRoute )


	local alphaRoute = [ Vector( -2216, -4768, 128 ),  Vector( -968, -3936, 304 ),  Vector( 1680, -1424, 168 ) ]
	TowerDefense_AddRoute( alphaRoute )

	local alphaCloseRoute = [ Vector( -1240, -632, 264 ),  Vector( 1416, -1112, 232 ) ]
	TowerDefense_AddRoute( alphaCloseRoute )


	local charlieCloseRoute = [ Vector( 3960, -2672, -112 ),  Vector( 2192, -656, 120 ) ]
	TowerDefense_AddRoute( charlieCloseRoute )


// BEHIND CURVED BUILDING
//ROUTES
	local centerRoute = [ Vector( 3299, -147, 2 ), Vector( -344, -2108, 290 ), Vector( -674, -3855, 299 ) ]
	TowerDefense_AddRoute( centerRoute, "centerRoute" )

//	local bRoute = [ Vector( 4994, -1206, -182 ), Vector(  446, -3877, 257 ) ]
//	TowerDefense_AddRoute( bRoute, "bRoute" )

	local cRoute = [ Vector( 1887, 1786, 97 ), Vector(  124, 210, 182 ), Vector( -1826, -2259, 288 ), Vector( -661, -3869, 299 ) ]
	TowerDefense_AddRoute( cRoute, "cRoute" )

// CLOSE ROUTES
	local centercloseRoute = [ Vector( -126, -1867, 291 ), Vector( -434, -3518, 310 ) ]
	TowerDefense_AddRoute( centercloseRoute, "centercloseRoute", false )  // false = don't use this route for "random" route selection

	local rightcloseRoute = [ Vector(  -2877, -4930, 86 ), Vector( -386, -4071, 305 ) ]
	TowerDefense_AddRoute( rightcloseRoute, "rightcloseRoute", false )  // false = don't use this route for "random" route selection

	local leftcloseRoute = [ Vector( 3284, -2768, -81 ), Vector( 521, -3907, 253 ) ]
	TowerDefense_AddRoute( leftcloseRoute, "leftcloseRoute", false )  // false = don't use this route for "random" route selection


	AddLoadoutCrate( level.nv.attackingTeam, Vector( 2170, 220, 358 ), Vector( 0, 0, 0 ) )  //Center building not B
	AddLoadoutCrate( level.nv.attackingTeam, Vector( 510, -594, 624 ), Vector( 0, 90, 0 ) )//center dirt
	AddLoadoutCrate( level.nv.attackingTeam, Vector( 2600, -1544, 480), Vector( 0, -180, 0 ) )//B
	AddLoadoutCrate( level.nv.attackingTeam, Vector( -2268, -2883, 462), Vector( 3, -64, -3 ) )//1


// BACK OF MAP REFUELING POINT
//		local roadRoute = [ Vector( 3820, -2641, -120 ),  Vector( 1460, -3113, 221 ),  Vector( -271, -3907, 306 ),  Vector( -856, -2592, 278 ) ]
//		TowerDefense_AddRoute( roadRoute )
//
//		local centerRoute = [ Vector( 4491, 1309, -59 ),  Vector( 3645, -467, -23 ),  Vector( -104, -2285, 305 ) ]
//		TowerDefense_AddRoute( centerRoute )
//
//		local fracturedRoute = [ Vector( 3650, 3931, -174 ), Vector ( 419, 263, 174 ), Vector ( -716, -1704, 452 ) ]
//		TowerDefense_AddRoute( fracturedRoute )

//	TowerDefense_AddGeneratorLocation( Vector( -525, -2415, 308 ), Vector( 0, 0, 0 ) ) //near refuel platform
//	SetCustomPlayerDropshipSpawn( TEAM_MILITIA, Vector( -1981, -2410, 1093 ), Vector( 0, 20, 0 ) )


// BEHIND C POINT
		local backRoute = [ Vector( 5120, -1152, -176 ),  Vector( 5056, 2680, -160 ),  Vector( 3640, 3952, -176 ) ]
		TowerDefense_AddRoute( backRoute )

		local centerRoute = [ Vector( 3400, -2584, -72), Vector( 3008, 3368, -32 ) ]
		TowerDefense_AddRoute( centerRoute )

		local roadRoute = [ Vector( 1096, -1384, 272), Vector( 1904, 3208, -64 ), Vector( 2712, 4120, -136 ) ]
		TowerDefense_AddRoute( roadRoute )

	TowerDefense_AddGeneratorLocation( Vector( 3632, 3320, -32 ), Vector( 0, 0, 0 ) ) //behind C
	SetCustomPlayerDropshipSpawn( TEAM_MILITIA, Vector( 4454, 3984, 762 ), Vector( 0, -128, 0 ) )



	AddLoadoutCrate( level.nv.attackingTeam, Vector( 2960, 2424, -24 ), Vector( 0, 135		, 0 ) )//center dirt
	AddLoadoutCrate( level.nv.attackingTeam, Vector( 2464, 24, 360 ), Vector( 0, 90, 0 ) )//curved building



//Titan spots
	AddStationaryTitanPosition( Vector( 4528, -2168, -120 ) )
	AddStationaryTitanPosition( Vector( 4256, -2472, -88 ) )
	AddStationaryTitanPosition( Vector( 3696, -2768, -112 ) )
	AddStationaryTitanPosition( Vector( 3248, -2920, -80 ) )
	AddStationaryTitanPosition( Vector( 3360, -1664, 176 ) )
	AddStationaryTitanPosition( Vector( 2192, -2376, 72 ) )
	AddStationaryTitanPosition( Vector( -912, -1040, 336 ) )
	AddStationaryTitanPosition( Vector( -1016, -1312, 344 ) )
	AddStationaryTitanPosition( Vector( -1256, -1232, 280 ) )

//Sniper spots
	TowerDefense_AddSniperLocation( Vector( 2432, 704, 568 ), 90 )
	TowerDefense_AddSniperLocation( Vector( 1008, 24, 528  ), 45 )
	TowerDefense_AddSniperLocation( Vector( 3496, 1192, 280 ), 135 )
	TowerDefense_AddSniperLocation( Vector( 4928, 488, 200 ), 135 )
	TowerDefense_AddSniperLocation( Vector( 3416, -944, 320 ), 90 )
	TowerDefense_AddSniperLocation( Vector( 3776, -800, 320 ), 90 )
	TowerDefense_AddSniperLocation( Vector( 2776, -1104, 480 ), 45 )
	TowerDefense_AddSniperLocation( Vector( 1464, -1880, 480 ), 90 )
	TowerDefense_AddSniperLocation( Vector( 2032, -2688, 680 ), 90 )
	TowerDefense_AddSniperLocation( Vector(	2340, 536, 348 ), 90 )
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
		TD_SpawnMortarTitan						-> 1 mortar titan
		TD_SpawnEmpTitan 						-> 1 emp titan
		TD_SpawnCloakedDrone							-> 1 cloak drone


\***************************************************/

function Fracture_SetupWaveSpawns()
{
	if ( IsClient() )
		return

	CommonWave_Fracture_Waves()
}
