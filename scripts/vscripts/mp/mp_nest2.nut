
function main()
{
	if ( reloadingScripts )
		return
}

function EntitiesDidLoad()
{
	local ENT_STARTSPAWNPILOT_COUNT = GetEntArrayByClass_Expensive("info_spawnpoint_human_start").len()
	local ENT_STARTSPAWNTITAN_COUNT = GetEntArrayByClass_Expensive("info_spawnpoint_titan_start").len()
	local ENT_SPAWNPILOT_COUNT = GetEntArrayByClass_Expensive("info_spawnpoint_human").len()
	local ENT_SPAWNTITAN_COUNT = GetEntArrayByClass_Expensive("info_spawnpoint_titan").len()

	// P7 [TODO] - Maybe fill these later with some generic spawns
	//	  [TODO2] - Is it necessary? Some modes already fills up these and I have no idea why yet.
	local NEST2_GENERIC_PILOT_SPAWNSTART_MILITIA = [
		{ origin = Vector( 3141, 3204, 176 ), angles = Vector( 0, -77, 0 )}
	]
	local NEST2_GENERIC_PILOT_SPAWNSTART_IMC = [
		{ origin = Vector( -3705, 179, 336 ), angles = Vector( 0, 6, 0 )}
	]
	// Generic pilot spawns sponsored by xFrann - 45 spawns more or less idk
	local NEST2_GENERIC_PILOT_SPAWN = [
		{ origin = Vector(-3705, 179, 336), angles = Vector(0, 6, 0) },
		{ origin = Vector(-3703, 52, 336), angles = Vector(0, 2, 0) },
		{ origin = Vector(-3696, -153, 336), angles = Vector(0, 8, 0) },
		{ origin = Vector(-3771, -109, 336), angles = Vector(0, -2, 0) },
		{ origin = Vector(-3768, 38, 336), angles = Vector(0, -0, 0) },
		{ origin = Vector(-3755, 178, 336), angles = Vector(0, -6, 0) },
		{ origin = Vector(-2413, -753, 336), angles = Vector(0, -138, 0) },
		{ origin = Vector(-2995, -938, 176), angles = Vector(0, 0, 0) },
		{ origin = Vector(-3341, -953, 176), angles = Vector(0, 42, 0) },
		{ origin = Vector(-3517, -869, 176), angles = Vector(0, 69, 0) },
		{ origin = Vector(-3683, -562, 176), angles = Vector(0, 1, 0) },
		{ origin = Vector(-3256, -704, 0), angles = Vector(0, 100, 0) },
		{ origin = Vector(-1796, -823, 336), angles = Vector(0, -156, 0) },
		{ origin = Vector(-1777, -920, 336), angles = Vector(0, 145, 0) },
		{ origin = Vector(-1938, -861, 336), angles = Vector(0, -177, 0) },
		{ origin = Vector(-1916, -1050, 336), angles = Vector(0, 128, 0) },
		{ origin = Vector(-1697, -1470, 208), angles = Vector(0, 176, 0) },
		{ origin = Vector(-1951, -1205, 336), angles = Vector(0, 178, 0) },
		{ origin = Vector(2411, 447, 288), angles = Vector(0, -55, 0) },
		{ origin = Vector(2557, 440, 288), angles = Vector(0, -89, 0) },
		{ origin = Vector(2580, 1048, 0), angles = Vector(0, -30, 0) },
		{ origin = Vector(2565, 878, 0), angles = Vector(0, -36, 0) },
		{ origin = Vector(2352, 711, 0), angles = Vector(0, -21, 0) },
		{ origin = Vector(2234, 566, 0), angles = Vector(0, -85, 0) },
		{ origin = Vector(1603, -128, 368), angles = Vector(0, -74, 0) },
		{ origin = Vector(1615, -387, 288), angles = Vector(0, -59, 0) },
		{ origin = Vector(1638, -564, 288), angles = Vector(0, 2, 0) },
		{ origin = Vector(1718, -921, 288), angles = Vector(0, -5, 0) },
		{ origin = Vector(1800, -1109, 0), angles = Vector(0, 42, 0) },
		{ origin = Vector(1642, -1562, 152), angles = Vector(0, 39, 0) },
		{ origin = Vector(-203, 2826, 192), angles = Vector(0, -96, 0) },
		{ origin = Vector(-101, 2690, 192), angles = Vector(0, -112, 0) },
		{ origin = Vector(-1252, 1518, -63), angles = Vector(0, 156, 0) },
		{ origin = Vector(-1236, 1696, -63), angles = Vector(0, 163, 0) },
		{ origin = Vector(-2176, 2332, -191), angles = Vector(0, -56, 0) },
		{ origin = Vector(-2166, 2181, -191), angles = Vector(0, -2, 0) },
		{ origin = Vector(-1982, 2188, -191), angles = Vector(0, -18, 0) },
		{ origin = Vector(-1633, 1990, -191), angles = Vector(0, 94, 0) },
		{ origin = Vector(-1778, 1951, -191), angles = Vector(0, 122, 0) },
		{ origin = Vector(-1220, -2255, 288), angles = Vector(0, 20, 0) },
		{ origin = Vector(1265, 2829, 128), angles = Vector(0, -87, 0) },
		{ origin = Vector(1711, 2839, 128), angles = Vector(0, -125, 0) },
		{ origin = Vector(1685, 2567, 128), angles = Vector(0, -158, 0) },
		{ origin = Vector(1698, 2353, 128), angles = Vector(0, 161, 0) },
		{ origin = Vector(1690, 1983, 272), angles = Vector(0, 127, 0) },
	]

	// CTF spawns sponsored by xFrann :D
	local NEST2_CTF_PILOT_SPAWNSTART_MILITIA = [
		{ origin = Vector( 3141, 3204, 176 ), angles = Vector( 0, -77, 0 )}
		{ origin = Vector( 2967, 3218, 176 ), angles = Vector( 0, -91, 0 )}
		{ origin = Vector( 2795, 3233, 176 ), angles = Vector( 0, -93, 0 )}
		{ origin = Vector( 2737, 3438, 176 ), angles = Vector( 0, -88, 0 )}
		{ origin = Vector( 2906, 3438, 176 ), angles = Vector( 0, -86, 0 )}
		{ origin = Vector( 2999, 3430, 176 ), angles = Vector( 0, -88, 0 )}
	]
	local NEST2_CTF_PILOT_SPAWNSTART_IMC = [
		{ origin = Vector( -3705, 179, 336 ), angles = Vector( 0, 6, 0 )}
		{ origin = Vector( -3703, 52, 336 ), angles = Vector( 0, 2, 0 )}
		{ origin = Vector( -3696, -153, 336 ), angles = Vector( 0, 8, 0 )}
		{ origin = Vector( -3771, -109, 336 ), angles = Vector( 0, -2, 0 )}
		{ origin = Vector( -3768, 38, 336 ), angles = Vector( 0, -1, 0 )}
		{ origin = Vector( -3755, 178, 336 ), angles = Vector( 0, -7, 0 )}
	]
	local NEST2_CTF_PILOT_SPAWN_MILITIA = [
		// near base
		{ origin = Vector( 2411, 447, 288 ), angles = Vector( 0, -55, 0 )}
		{ origin = Vector( 2557, 440, 288 ), angles = Vector( 0, -89, 0 )}
		{ origin = Vector( 2580, 1048, 0 ), angles = Vector( 0, -30, 0 )}
		{ origin = Vector( 2565, 878, 0 ), angles = Vector( 0, -36, 0 )}
		{ origin = Vector( 2352, 711, 0 ), angles = Vector( 0, -21, 0 )}
		{ origin = Vector( 2234, 566, 0 ), angles = Vector( 0, -85, 0 )}
		// base - right side
		{ origin = Vector( 3526, 1328, 192 ), angles = Vector( 0, 178, 0 )}
		{ origin = Vector( 3776, 1291, 191 ), angles = Vector( 0, 119, 0 )}
		{ origin = Vector( 2573, 1348, 0 ), angles = Vector( 0, 52, 0 )}
		{ origin = Vector( 2514, 1453, 1 ), angles = Vector( 0, 40, 0 )}
		{ origin = Vector( 1939, 2044, -89 ), angles = Vector( 0, -74, 0 )}
		{ origin = Vector( 1879, 1945, -107 ), angles = Vector( 0, -74, 0 )}
		// base - left side
		{ origin = Vector( 1603, -128, 368 ), angles = Vector( 0, -74, 0 )}
		{ origin = Vector( 1615, -387, 288 ), angles = Vector( 0, -59, 0 )}
		{ origin = Vector( 1638, -564, 288 ), angles = Vector( 0, 2, 0 )}
		{ origin = Vector( 1718, -921, 288 ), angles = Vector( 0, -5, 0 )}
		{ origin = Vector( 1800, -1109, 0 ), angles = Vector( 0, 42, 0 )}
		{ origin = Vector( 1642, -1562, 152 ), angles = Vector( 0, 39, 0 )}
	]
	local NEST2_CTF_PILOT_SPAWN_IMC = [
		// near base
		{ origin = Vector( -2413, -753, 336 ), angles = Vector( 0, -138, 0 )}
		{ origin = Vector( -2995, -938, 176 ), angles = Vector( 0, 1, 0 )}
		{ origin = Vector( -3341, -953, 176 ), angles = Vector( 0, 42, 0 )}
		{ origin = Vector( -3517, -869, 176 ), angles = Vector( 0, 69, 0 )}
		{ origin = Vector( -3683, -562, 176 ), angles = Vector( 0, 1, 0 )}
		{ origin = Vector( -3256, -704, 0 ), angles = Vector( 0, 100, 0 )}
		// base - right side
		{ origin = Vector( -1796, -823, 336 ), angles = Vector( 0, -156, 0 )}
		{ origin = Vector( -1777, -920, 336 ), angles = Vector( 0, 145, 0 )}
		{ origin = Vector( -1938, -861, 336 ), angles = Vector( 0, -177, 0 )}
		{ origin = Vector( -1916, -1050, 336 ), angles = Vector( 0, 128, 0 )}
		{ origin = Vector( -1697, -1470, 208 ), angles = Vector( 0, 176, 0 )}
		{ origin = Vector( -1951, -1205, 336 ), angles = Vector( 0, 178, 0 )}
		// base - left side
		{ origin = Vector( -3431, 291, 16 ), angles = Vector( 0, -59, 0 )}
		{ origin = Vector( 3446, 846, 206 ), angles = Vector( 0, 21, 0 )}
		{ origin = Vector( -3437, 476, 336 ), angles = Vector( 0, -89, 0 )}
		{ origin = Vector( -2087, 339, 0 ), angles = Vector( 0, -83, 0 )}
		{ origin = Vector( -1929, 337, 0 ), angles = Vector( 0, -75, 0 )}
		{ origin = Vector( -1829, 393, 0 ), angles = Vector( 0, -71, 0 )}
	]
	local NEST2_CTF_TITAN_SPAWN = [
		// imc - left side
		{ origin = Vector(-2741, 2039, -59), angles = Vector(0, -12, 0) },
		{ origin = Vector(-2734, 2577, -63), angles = Vector(0, -48, 0) },
		{ origin = Vector(-2634, 3043, -63), angles = Vector(0, -52, 0) },
		{ origin = Vector(-2255, 3342, -65), angles = Vector(0, -85, 0) },
		{ origin = Vector(-1553, 3381, -61), angles = Vector(0, -114, 0) },
		{ origin = Vector(-1303, 2328, -59), angles = Vector(0, -92, 0) },
		// imc - right side
		{ origin = Vector(-2539, -2275, 0), angles = Vector(0, 19, 0) },
		{ origin = Vector(-2582, -2810, -1), angles = Vector(0, 39, 0) },
		{ origin = Vector(-2665, -3420, 2), angles = Vector(0, -1, 0) },
		{ origin = Vector(-2138, -3704, 2), angles = Vector(0, 76, 0) },
		{ origin = Vector(-1695, -3662, 4), angles = Vector(0, 94, 0) },
		{ origin = Vector(-1142, -3525, 16), angles = Vector(0, 123, 0) },
		// militia - left side
		{ origin = Vector(3669, -1229, 8), angles = Vector(0, 144, 0) },
		{ origin = Vector(3346, -1592, 8), angles = Vector(0, 142, 0) },
		{ origin = Vector(3134, -1899, 8), angles = Vector(0, 129, 0) },
		{ origin = Vector(3118, -2343, 8), angles = Vector(0, 123, 0) },
		{ origin = Vector(3254, -3001, 8), angles = Vector(0, 107, 0) },
		{ origin = Vector(3384, -3364, 8), angles = Vector(0, 122, 0) },
		// militia - right side
		{ origin = Vector(2871, 2279, 50), angles = Vector(0, -126, 0) },
		{ origin = Vector(3405, 2412, 50), angles = Vector(0, -139, 0) },
		{ origin = Vector(3450, 2744, 50), angles = Vector(0, -138, 0) },
		{ origin = Vector(3595, 3153, 50), angles = Vector(0, -127, 0) },
		{ origin = Vector(3155, 3214, 176), angles = Vector(0, -96, 0) },
		{ origin = Vector(2718, 3277, 176), angles = Vector(0, -101, 0) },
	]

	// Titan spawns
	//local NEST2_TITAN_SPAWNSTART_MILITIA = []
	//local NEST2_TITAN_SPAWNSTART_IMC = []
	// Generic titan spawns sponsored by xFrann
	local NEST2_GENERIC_TITAN_SPAWN = [
		{ origin = Vector(-2741, 2039, -59), angles = Vector(0, -12, 0) },
		{ origin = Vector(-2734, 2577, -63), angles = Vector(0, -48, 0) },
		{ origin = Vector(-2634, 3043, -63), angles = Vector(0, -52, 0) },
		{ origin = Vector(-2255, 3342, -65), angles = Vector(0, -85, 0) },
		{ origin = Vector(-1553, 3381, -61), angles = Vector(0, -114, 0) },
		{ origin = Vector(-1303, 2328, -59), angles = Vector(0, -92, 0) },
		{ origin = Vector(-2539, -2275, 0), angles = Vector(0, 19, 0) },
		{ origin = Vector(-2582, -2810, -1), angles = Vector(0, 39, 0) },
		{ origin = Vector(-2665, -3420, 2), angles = Vector(0, -1, 0) },
		{ origin = Vector(-2138, -3704, 2), angles = Vector(0, 76, 0) },
		{ origin = Vector(-1695, -3662, 4), angles = Vector(0, 94, 0) },
		{ origin = Vector(-1142, -3525, 16), angles = Vector(0, 123, 0) },
		{ origin = Vector(3669, -1229, 8), angles = Vector(0, 144, 0) },
		{ origin = Vector(3346, -1592, 8), angles = Vector(0, 142, 0) },
		{ origin = Vector(3134, -1899, 8), angles = Vector(0, 129, 0) },
		{ origin = Vector(3118, -2343, 8), angles = Vector(0, 123, 0) },
		{ origin = Vector(3254, -3001, 8), angles = Vector(0, 107, 0) },
		{ origin = Vector(3384, -3364, 8), angles = Vector(0, 122, 0) },
		{ origin = Vector(2871, 2279, 50), angles = Vector(0, -126, 0) },
		{ origin = Vector(3405, 2412, 50), angles = Vector(0, -139, 0) },
		{ origin = Vector(3450, 2744, 50), angles = Vector(0, -138, 0) },
		{ origin = Vector(3595, 3153, 50), angles = Vector(0, -127, 0) },
		{ origin = Vector(3155, 3214, 176), angles = Vector(0, -96, 0) },
		{ origin = Vector(2718, 3277, 176), angles = Vector(0, -101, 0) },
		{ origin = Vector(112, 1952, -191), angles = Vector(0, -175, 0) },
	]

	switch(GameRules.GetGameMode()) {
		case "ctf":
		case "ctfp":
			// P7: [CTF] Fix flag spawns
			//	   Flags on this map were on the air so... we need to create new ones
			// Flags
			// IMC: -2924.667480, -772.578552, 336.031250
			// MILITIA: 2432.482666, 126.611160, 288.031250
			CreateFlagSpawnPoint( Vector( -2924, -772, 336 ), Vector(0, 0, 0), TEAM_IMC, "info_spawnpoint_flag_1" )
			CreateFlagSpawnPoint( Vector( 2432, 126, 288 ), Vector(0, 0, 0), TEAM_MILITIA, "info_spawnpoint_flag_2" )
			// CTF spawn setup
			// First we delete previous pilot start spawns for this mode as we have our own
			foreach(ent in GetEntArrayByClass_Expensive("info_spawnpoint_human_start")) {
				printt("Destroyed ", ent.GetName(), " - unwanted spawn for this mode.")
				ent.Destroy()
			}
			// then we do the thing
			foreach(location in NEST2_CTF_PILOT_SPAWNSTART_MILITIA) {
				CreatePilotStartSpawnPoint(location.origin, location.angles, TEAM_MILITIA, "info_spawnpoint_human_start_" + (ENT_STARTSPAWNPILOT_COUNT+1))
				ENT_STARTSPAWNPILOT_COUNT++
			}
			foreach(location in NEST2_CTF_PILOT_SPAWNSTART_IMC) {
				CreatePilotStartSpawnPoint(location.origin, location.angles, TEAM_IMC, "info_spawnpoint_human_start_" + (ENT_STARTSPAWNPILOT_COUNT+1))
				ENT_STARTSPAWNPILOT_COUNT++
			}
			// P7 [TODO?] Maybe merge these loops later since they're all to unassigned teams anyway, check previous comment
			foreach(location in NEST2_CTF_PILOT_SPAWN_MILITIA) {
				CreatePilotSpawnPoint(location.origin, location.angles, TEAM_UNASSIGNED, "info_spawnpoint_human_" + (ENT_SPAWNPILOT_COUNT+1))
				ENT_SPAWNPILOT_COUNT++
			}
			foreach(location in NEST2_CTF_PILOT_SPAWN_IMC) {
				CreatePilotSpawnPoint(location.origin, location.angles, TEAM_UNASSIGNED, "info_spawnpoint_human_" + (ENT_SPAWNPILOT_COUNT+1))
				ENT_SPAWNPILOT_COUNT++
			}
			foreach(location in NEST2_CTF_TITAN_SPAWN) {
				CreateTitanPilotSpawnPoint(location.origin, location.angles, TEAM_UNASSIGNED, "info_spawnpoint_titan_" + ENT_SPAWNTITAN_COUNT+1)
				ENT_STARTSPAWNTITAN_COUNT++
				ENT_SPAWNTITAN_COUNT++
			}
			break
		default:
			// Generic pilot spawnpoints for the rest of gamemodes that might require them
			foreach(location in NEST2_GENERIC_PILOT_SPAWNSTART_MILITIA) {
				CreatePilotStartSpawnPoint(location.origin, location.angles, TEAM_MILITIA, "info_spawnpoint_human_start_" + (ENT_STARTSPAWNPILOT_COUNT+1))
				//CreatePilotSpawnPoint(location.origin, location.angles, TEAM_UNASSIGNED, "info_spawnpoint_human_" + (ENT_SPAWNPILOT_COUNT+1))
				ENT_STARTSPAWNPILOT_COUNT++
				ENT_SPAWNPILOT_COUNT++
			}
			foreach(location in NEST2_GENERIC_PILOT_SPAWNSTART_IMC) {
				CreatePilotStartSpawnPoint(location.origin, location.angles, TEAM_IMC, "info_spawnpoint_human_start_" + (ENT_STARTSPAWNPILOT_COUNT+1))
				//CreatePilotSpawnPoint(location.origin, location.angles, TEAM_UNASSIGNED, "info_spawnpoint_human_" + (ENT_SPAWNPILOT_COUNT+1))
				ENT_STARTSPAWNPILOT_COUNT++
				ENT_SPAWNPILOT_COUNT++
			}
			foreach(location in NEST2_GENERIC_PILOT_SPAWN) {
				CreatePilotSpawnPoint(location.origin, location.angles, TEAM_UNASSIGNED, "info_spawnpoint_human_" + (ENT_SPAWNPILOT_COUNT+1))
				ENT_STARTSPAWNPILOT_COUNT++
				ENT_SPAWNPILOT_COUNT++
			}
			break
	}
	// Titan spawn setup
	foreach(location in NEST2_GENERIC_TITAN_SPAWN) {
		//CreateTitanPilotStartSpawnPoint(location.origin, location.angles, TEAM_MILITIA, "info_spawnpoint_titan_start_" + (ENT_STARTSPAWNTITAN_COUNT+1))
		CreateTitanPilotSpawnPoint(location.origin, location.angles, TEAM_UNASSIGNED, "info_spawnpoint_titan_" + ENT_SPAWNTITAN_COUNT+1)
		ENT_STARTSPAWNTITAN_COUNT++
		ENT_SPAWNTITAN_COUNT++
	}

	FlagWait( "ReadyToStartMatch" ) // maaaaybe it just works here as well?

	GM_SetObserverFunc( ObserverFunc )
	BBPanelCamSetup()
}

function BBPanelCamSetup()
{
    PrintFunc()
	//local spectatorNode1 = GetEnt( "panel_cam1" )
	//local spectatorNode2 = GetEnt( "panel_cam2" )

	level.DeathCamEnt1 <- GetEnt( "panel_cam1" )
	level.DeathCamEnt2 <- GetEnt( "panel_cam2" )

	level.DeathCamOutSide_A <- GetEnt( "panel_cam10" )
	level.DeathCamOutSide_B <- GetEnt( "panel_cam20" )

	printt( "DeathCamEnt1 = ", level.DeathCamEnt1)
	printt( "DeathCamEnt2 = ", level.DeathCamEnt2)
}

function ObserverFunc( player )
{
	printt( "player: ", player.GetName() )

	// Reenable this when big brother gets added back

//	if( IsBigBrotherPanelHacked() && IsMyTeamElimination( player ) )
//	{
//		local HackedPanelIndex = GetHackedBBPanelIndex()
//
//		Assert( HackedPanelIndex != 0 )
//
//		local deathCam
//		if( GetHackedBBPanelIndex() == 1 )
//		{
//			deathCam = level.DeathCamEnt1
//		}
//		else
//		{
//			deathCam = level.DeathCamEnt2
//		}
//
//		// player 및 같은 팀 플레이어의 옵저버 모드를 바꿈.
//		local playerArray = GetPlayerArrayOfTeam( player.GetTeam() )
//		foreach ( guy in playerArray )
//		{
//			guy.SetObserverModeStaticPosition( deathCam.GetOrigin() )
//			guy.SetObserverModeStaticAngles( deathCam.GetAngles() )
//
//			guy.StartObserverMode( OBS_MODE_STATIC_LOCKED )
//			guy.SetObserverTarget( null )
//
//			// SpectatorSelectButton Hide.
//			Remote.CallFunction_NonReplay( guy, "ServerCallback_HideSpectatorSelectButtons" )
//		}
//
//		/*
//		player.SetObserverModeStaticPosition( deathCam.GetOrigin() )
//		player.SetObserverModeStaticAngles( deathCam.GetAngles() )
//
//		player.StartObserverMode( OBS_MODE_STATIC_LOCKED )
//		player.SetObserverTarget( null )
//		*/
//	}
//	else

	{
		player.StartObserverMode( OBS_MODE_CHASE )
		player.SetObserverTarget( null )
	}
}

main()