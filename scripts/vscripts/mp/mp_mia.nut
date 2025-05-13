

function Mp_Mia_main()
{
	if ( reloadingScripts )
		return
	IncludeFile( "mp_mia_shared" )
	IncludeFile( "mp/mp_mia_skyshow" )

	FlagInit( "Mia_Match01Percent" )
	FlagInit( "Mia_Match15Percent" )
	FlagInit( "Mia_Match25Percent" )
	FlagInit( "Mia_Match40Percent" )
	FlagInit( "Mia_Match45Percent" )
	FlagInit( "Mia_Match60Percent" )
	FlagInit( "Mia_Match80Percent" )
	FlagInit( "Mia_Match90Percent" )
	FlagInit( "Mia_Match98Percent" )

	PrecacheWeapon( "mp_weapon_mega_turret_aa" )

	level.IntroRefs 				<- {}
	level.IntroRefs[ TEAM_IMC ] 	<- []
	level.IntroRefs[ TEAM_MILITIA ] <- []
	level.progressDialogPlayed 		<- {}
	level.atmosOKFX 				<- null
	level.atmosBurnFX 				<- null

	MatchProgressSetup()

}

function EntitiesDidLoad()
{
	if ( !IsServer() )
		return
	
	Mia_CreateSpawnPoints()

	if ( EvacEnabled() )
	{
		Mia_CreateEvacNodes()
	}

	switch(GameRules.GetGameMode()) {
		// Mode specifics setup
		case "cp":
			Mia_SetupHardpointMode()
			break;
	}

	FlagWait( "ReadyToStartMatch" )
	

	thread Mia_SkyShowMain()
	thread MatchProgressMilestones()
}

function Mia_SetupHardpointMode() {
	// remove this when mode is playable
	if( GetDeveloperLevel() < 1 )
	{
		return
	}

	// See maps/mp_mia_script.ent for creation of these ents
	local hardpointA = GetEnt("hardpoint_A")
	local hardpointB = GetEnt("hardpoint_B")
	local hardpointC = GetEnt("hardpoint_C")

	// spots
	hardpointA.SetOrigin( Vector( 3173, 3583, 64 ) ) // IMC side
	hardpointB.SetOrigin( Vector( 1021, 3583, 53 ) ) // Middle
	hardpointC.SetOrigin( Vector( -1158, 3583, 64 ) ) // Militia side

	// triggers
	local triggerHardpointA = GetEnt("trigger_hardpoint_A_target")
	local triggerHardpointA = GetEnt("trigger_hardpoint_B_target")
	local triggerHardpointA = GetEnt("trigger_hardpoint_C_target")

	// this placement is purely based on nothing btw
	triggerHardpointA.SetOrigin( Vector( 3318, 3583, 64 ) )
	triggerHardpointB.SetOrigin( Vector( 1021, 3663, 53 ) )
	triggerHardpointC.SetOrigin( Vector( -1290, 3583, 64 ) )

}

function Mia_CreateSpawnPoints()
{
	local ENT_STARTSPAWNPILOT_COUNT = GetEntArrayByClass_Expensive("info_spawnpoint_human_start").len()
	local ENT_STARTSPAWNTITAN_COUNT = GetEntArrayByClass_Expensive("info_spawnpoint_titan_start").len()
	local ENT_SPAWNPILOT_COUNT = GetEntArrayByClass_Expensive("info_spawnpoint_human").len()
	local ENT_SPAWNTITAN_COUNT = GetEntArrayByClass_Expensive("info_spawnpoint_titan").len()

	local ENT_STARTSPAWNDROPPOD_COUNT = GetEntArrayByClass_Expensive("info_spawnpoint_droppod_start").len()
	local ENT_SPAWNDROPPOD_COUNT = GetEntArrayByClass_Expensive("info_spawnpoint_droppod").len()

	local ENT_SPAWNDROSHIP_COUNT = GetEntArrayByClass_Expensive("info_spawnpoint_dropship").len()
	local ENT_SPAWNMARVIN_COUNT = GetEntArrayByClass_Expensive("info_spawnpoint_marvin").len()

	// Generic spawns
	// Basically each team on their respective cabin side on the ship
	local MIA_GENERIC_PILOT_SPAWNSTART_MILITIA = [
		// cabin right side
		{ origin = Vector( -1747, 4006, -64 ), angles = Vector( 0, 2, 0 ) },
		{ origin = Vector( -1886, 4006, -64 ), angles = Vector( 0, 2, 0 ) },
		{ origin = Vector( -2025, 4006, -64 ), angles = Vector( 0, 2, 0 ) },
		// cabin left side
		{ origin = Vector( -1747, 3161, -64 ), angles = Vector( 0, 2, 0 ) },
		{ origin = Vector( -1887, 3162, -64 ), angles = Vector( 0, 2, 0 ) },
		{ origin = Vector( -2026, 3161, -64 ), angles = Vector( 0, 2, 0 ) }
	]
	local MIA_GENERIC_PILOT_SPAWNSTART_IMC = [
		// cabin right side
		{ origin = Vector( 3785, 4003, -64 ), angles = Vector( 0, -178, 0 ) },
		{ origin = Vector( 3914, 4003, -64 ), angles = Vector( 0, -178, 0 ) },
		{ origin = Vector( 4042, 4004, -64 ), angles = Vector( 0, -178, 0 ) },
		// cabin left side
		{ origin = Vector( 3786, 3164, -64 ), angles = Vector( 0, -178, 0 ) },
		{ origin = Vector( 3913, 3164, -64 ), angles = Vector( 0, -178, 0 ) },
		{ origin = Vector( 4041, 3163, -64 ), angles = Vector( 0, -178, 0 ) }
	]

	// From now on, all spawn locations are proudly provided by xFrann
	// Titan spawns
	local MIA_TITAN_SPAWNSTART_MILITIA = [
		{ origin = Vector( 1710, 7452, 8 ), angles = Vector( 0, -92, 0 ) },
		{ origin = Vector( 1084, 7536, 147 ), angles = Vector( 0, -92, 0 ) },
		{ origin = Vector( 180, 7518, 95 ), angles = Vector( 0, -86, 0 ) },
		{ origin = Vector( -1514, 7467, 31 ), angles = Vector( 0, -52, 0 ) },
		{ origin = Vector( -2760, 7011, -44 ), angles = Vector( 0, -51, 0 ) },
		{ origin = Vector( 3539, 6716, -217 ), angles = Vector( 0, -123, 0 ) }
	]
	local MIA_TITAN_SPAWNSTART_IMC = [
		{ origin = Vector( 1718, 339, -106 ), angles = Vector( 0, 96, 0 ) },
		{ origin = Vector( 1048, -30, -154 ), angles = Vector( 0, 91, 0 ) },
		{ origin = Vector( -146, 105, -97 ), angles = Vector( 0, 89, 0 ) },
		{ origin = Vector( -1653, 277, -105 ), angles = Vector( 0, 80, 0 ) },
		{ origin = Vector( 3555, 492, -288 ), angles = Vector( 0, 124, 0 ) },
		{ origin = Vector( -2469, 545, -59 ), angles = Vector( 0, 40, 0 ) }
	]
	// CTF specific spawns
	local MIA_CTF_PILOT_SPAWNSTART_MILITIA = [
		{ origin = Vector( -2090, 4116, -64 ), angles = Vector( 0, -3, 0 ) },
		{ origin = Vector( -2165, 3044, -64 ), angles = Vector( 0, -2, 0 ) },
		{ origin = Vector( -2095, 4007, -64 ), angles = Vector( 0, -1, 0 ) },
		{ origin = Vector( -2151, 3160, -64 ), angles = Vector( 0, 1, 0 ) },
		{ origin = Vector( -2092, 3896, -64 ), angles = Vector( 0, 3, 0 ) },
		{ origin = Vector( -2146, 3269, -64 ), angles = Vector( 0, -4, 0 ) },
	]
	local MIA_CTF_PILOT_SPAWNSTART_IMC = [
		{ origin = Vector( 4254, 3029, -64 ), angles = Vector( 0, 177, 0 ) },
		{ origin = Vector( 4205, 3906, -64 ), angles = Vector( 0, 157, 0 ) },
		{ origin = Vector( 4243, 3171, -64 ), angles = Vector( 0, -179, 0 ) },
		{ origin = Vector( 4207, 4008, -64 ), angles = Vector( 0, 178, 0 ) },
		{ origin = Vector( 4207, 3296, -63 ), angles = Vector( 0, -177, 0 ) },
		{ origin = Vector( 4208, 4103, -64 ), angles = Vector( 0, 179, 0 ) },
	]
	// P7 [TODO?] As these spawns are now used by every team it might be worth it to go through all of them since
	//			  some might be harmful to this specific mode, and merge all of these in a unique array
	local MIA_CTF_PILOT_SPAWN_MILITIA = [
		// down-center
		{ origin = Vector( -1558, 3408, -320 ), angles = Vector( 0, 19, 0 ) },
		{ origin = Vector( -1574, 3717, -320 ), angles = Vector( 0, -1, 0 ) },
		{ origin = Vector( -1574, 3496, -320 ), angles = Vector( 0, 5, 0 ) },
		{ origin = Vector( -1467, 3819, -320 ), angles = Vector( 0, -1, 0 ) },
		// left corridor
		{ origin = Vector( -1455, 4605, -64 ), angles = Vector( 0, -55, 0 ) },
		{ origin = Vector( -1323, 4591, -64 ), angles = Vector( 0, -90, 0 ) },
		{ origin = Vector( -977, 4591, -62 ), angles = Vector( 0, -90, 0 ) },
		// right corridor
		{ origin = Vector( -1421, 2580, -65 ), angles = Vector( 0, 90, 0 ) },
		{ origin = Vector( -1493, 2582, -64 ), angles = Vector( 0, 58, 0 ) },
		{ origin = Vector( -977, 2577, -62 ), angles = Vector( 0, 150, 0 ) },
		// cargo door right
		{ origin = Vector( -528, 2729, -302 ), angles = Vector( 0, 90, 0 ) },
		{ origin = Vector( -598, 2748, -306 ), angles = Vector( 0, 86, 0 ) },
		{ origin = Vector( -426, 2941, -320 ), angles = Vector( 0, 8, 0 ) },
		// cargo door left
		{ origin = Vector( -570, 4478, -296 ), angles = Vector( 0, -87, 0 ) },
		{ origin = Vector( -552, 4358, -310 ), angles = Vector( 0, -90, 0 ) },
		{ origin = Vector( -446, 4226, -320 ), angles = Vector( 0, -2, 0 ) },
		// outdoors - right
		{ origin = Vector( -1268, 2380, -250 ), angles = Vector( 0, 25, 0 ) },
		{ origin = Vector( -1088, 2418, -261 ), angles = Vector( 0, -16, 0 ) },
		// outdoors - left
		{ origin = Vector( -1197, 4915, -286 ), angles = Vector( 0, -9, 0 ) },
		{ origin = Vector( -1223, 4772, -263 ), angles = Vector( 0, -33, 0 ) },
		// special
		{ origin = Vector( -454, 4143, -320 ), angles = Vector( 0, -89, 0 ) },
		{ origin = Vector( -430, 4034, -320 ), angles = Vector( 0, -65, 0 ) },
		{ origin = Vector( -430, 3976, -320 ), angles = Vector( 0, -102, 0 ) }
	]
	local MIA_CTF_PILOT_SPAWN_IMC = [
		// down-center
		{ origin = Vector( 3497, 3620, -318 ), angles = Vector( 0, -179, 0 ) },
		{ origin = Vector( 3493, 3535, -318 ), angles = Vector( 0, 177, 0 ) },
		// up-center
		{ origin = Vector( 4151, 3516, 7 ), angles = Vector( 0, 175, 0 ) },
		{ origin = Vector( 4144, 3654, 7 ), angles = Vector( 0, -176, 0 ) },
		// left corridor
		{ origin = Vector( 3025, 2577, -62 ), angles = Vector( 0, 90, 0 ) },
		{ origin = Vector( 3356, 2577, -64 ), angles = Vector( 0, 90, 0 ) },
		{ origin = Vector( 3408, 2580, -64 ), angles = Vector( 0, 119, 0 ) },
		// right corridor
		{ origin = Vector( 3034, 4576, -64 ), angles = Vector( 0, -73, 0 ) },
		{ origin = Vector( 3549, 4582, -64 ), angles = Vector( 0, -83, 0 ) },
		{ origin = Vector( 3596, 4576, -64 ), angles = Vector( 0, -100, 0 ) },
		// cargo door left
		{ origin = Vector( 2606, 2740, -289 ), angles = Vector( 0, 86, 0 ) },
		{ origin = Vector( 2615, 2850, -309 ), angles = Vector( 0, 85, 0 ) },
		{ origin = Vector( 2465, 2947, -317 ), angles = Vector( 0, 176, 0 ) },
		// cargo door right
		{ origin = Vector( 2600, 4398, -286 ), angles = Vector( 0, -93, 0 ) },
		{ origin = Vector( 2596, 4313, -291 ), angles = Vector( 0, -94, 0 ) },
		{ origin = Vector( 2475, 4224, -320 ), angles = Vector( 0, 142, 0 ) },
		// outdoors - left
		{ origin = Vector( 3320, 2377, -252 ), angles = Vector( 0, 162, 0 ) },
		{ origin = Vector( 3168, 2361, -265 ), angles = Vector( 0, 145, 0 ) },
		// special
		{ origin = Vector( 2100, 3579, -315 ), angles = Vector( 0, 68, 0 ) },
		{ origin = Vector( 2112, 3495, -315 ), angles = Vector( 0, -84, 0 ) },
		{ origin = Vector( 2093, 3579, -218 ), angles = Vector( 0, 69, 0 ) }
	]

	// Droppod spawns
	local MIA_DROPPOD_SPAWN_MILITIA = [
		// Front cargo door
		{ origin = Vector( 3125, 5274, -304 ), angles = Vector( 0, -125, 0 ) },
		{ origin = Vector( 2398, 5269, -271 ), angles = Vector( 0, -60, 0 ) },

		// Mid
		{ origin = Vector( 1060, 5202, -64 ), angles = Vector( 0, -90, 0 ) },
		{ origin = Vector( 688, 5691, -74 ), angles = Vector( 0, -70, 0 ) },

		// Back
		{ origin = Vector( -333, 5420, -252 ), angles = Vector( 0, -125, 0 ) },
		{ origin = Vector( -538, 6080, -212 ), angles = Vector( 0, -90, 0 ) },
		{ origin = Vector( -1261, 5593, -285 ), angles = Vector( 0, -125, 0 ) },
		{ origin = Vector( -977, 5280, -287 ), angles = Vector( 0, -64, 0 ) }
	]
	local MIA_DROPPOD_SPAWN_IMC = [
		// Front cargo door
		{ origin = Vector( 3521, 444, -294 ), angles = Vector( 0, 110, 0 ) },
		{ origin = Vector( 3096, 694, -219 ), angles = Vector( 0, 90, 0 ) },
		{ origin = Vector( 2465, 1278, -209 ), angles = Vector( 0, 92, 0 ) },
		{ origin = Vector( 2851, 1682, -231 ), angles = Vector( 0, 90, 0 ) },

		// Mid
		{ origin = Vector( 579, 1133, -147 ), angles = Vector( 0, 72, 0 ) },
		{ origin = Vector( 170, 2039, -275 ), angles = Vector( 0, 25, 0 ) },
		{ origin = Vector( 167, 1433, -202 ), angles = Vector( 0, 80, 0 ) },

		// Back
		{ origin = Vector( -978, 839, -192 ), angles = Vector( 0, -146, 0 ) },
		{ origin = Vector( -196, 1497, -235 ), angles = Vector( 0, 120, 0 ) },
		{ origin = Vector( -643, 1916, -281 ), angles = Vector( 0, 100, 0 ) }
	]

	local MIA_DROPSHIP_SPAWN = [
		{ origin = Vector( -811, 1727, -271 ), angles = Vector( 0, 90, 0 ) }
	]
	local MIA_MARVIN_SPAWN = [
		{ origin = Vector( -1264, 3545, 64 ), angles = Vector( 0, 90, 0 ) },
		{ origin = Vector( -296, 3441, -319 ), angles = Vector( 0, 0, 0 ) }
	]

	switch(GameRules.GetGameMode()) {
		case "ctf":
		case "ctfp":
		case "scv":
			// P7: [CTF] Fix flag spawns
			//	   The flags were already in the map, so we just move them somewhere else
			local imcFlag = GetFlagSpawnPoint( TEAM_IMC )
			local militiaFlag = GetFlagSpawnPoint( TEAM_MILITIA )
			// more or less the cabin center pos:
			// Vector( -1158, 3583, 64 )
			// Vector( 3173, 3583, 64 )
			imcFlag.SetOrigin( Vector( 3173, 3583, 64 ) )
			militiaFlag.SetOrigin( Vector( -1158, 3583, 64 ) )
			// CTF spawn setup
			foreach(location in MIA_CTF_PILOT_SPAWNSTART_MILITIA) {
				CreatePilotStartSpawnPoint(location.origin, location.angles, TEAM_MILITIA, "info_spawnpoint_human_start_" + (ENT_STARTSPAWNPILOT_COUNT+1))
				ENT_STARTSPAWNPILOT_COUNT++
			}
			foreach(location in MIA_CTF_PILOT_SPAWNSTART_IMC) {
				CreatePilotStartSpawnPoint(location.origin, location.angles, TEAM_IMC, "info_spawnpoint_human_start_" + (ENT_STARTSPAWNPILOT_COUNT+1))
				ENT_STARTSPAWNPILOT_COUNT++
			}
			// P7 [TODO?] Maybe merge these loops later since they're all to unassigned teams anyway, check previous comment
			foreach(location in MIA_CTF_PILOT_SPAWN_MILITIA) {
				CreatePilotSpawnPoint(location.origin, location.angles, TEAM_UNASSIGNED, "info_spawnpoint_human_" + (ENT_SPAWNPILOT_COUNT+1))
				ENT_SPAWNPILOT_COUNT++
			}
			foreach(location in MIA_CTF_PILOT_SPAWN_IMC) {
				CreatePilotSpawnPoint(location.origin, location.angles, TEAM_UNASSIGNED, "info_spawnpoint_human_" + (ENT_SPAWNPILOT_COUNT+1))
				ENT_SPAWNPILOT_COUNT++
			}
			break
		default:
			// Generic pilot spawnpoints for the rest of gamemodes that might require them
			// At the moment, start spawns will also be spawns when you die, would this go wrong? absolutely (not (probably))
			foreach(location in MIA_GENERIC_PILOT_SPAWNSTART_MILITIA) {
				CreatePilotStartSpawnPoint(location.origin, location.angles, TEAM_MILITIA, "info_spawnpoint_human_start_" + (ENT_STARTSPAWNPILOT_COUNT+1))
				CreatePilotSpawnPoint(location.origin, location.angles, TEAM_UNASSIGNED, "info_spawnpoint_human_" + (ENT_SPAWNPILOT_COUNT+1))
				ENT_STARTSPAWNPILOT_COUNT++
				ENT_SPAWNPILOT_COUNT++
			}
			foreach(location in MIA_GENERIC_PILOT_SPAWNSTART_IMC) {
				CreatePilotStartSpawnPoint(location.origin, location.angles, TEAM_IMC, "info_spawnpoint_human_start_" + (ENT_STARTSPAWNPILOT_COUNT+1))
				CreatePilotSpawnPoint(location.origin, location.angles, TEAM_UNASSIGNED, "info_spawnpoint_human_" + (ENT_SPAWNPILOT_COUNT+1))
				ENT_STARTSPAWNPILOT_COUNT++
				ENT_SPAWNPILOT_COUNT++
			}
			break
	}
	// Titan spawn setup (for LTS/WLTS) also provided by xFrann
	// At the moment, these will be the spawns when starting and respawning for every mode that might require it
	foreach(location in MIA_TITAN_SPAWNSTART_MILITIA) {
		CreateTitanPilotStartSpawnPoint(location.origin, location.angles, TEAM_MILITIA, "info_spawnpoint_titan_start_" + (ENT_STARTSPAWNTITAN_COUNT+1))
		CreateTitanPilotSpawnPoint(location.origin, location.angles, TEAM_UNASSIGNED, "info_spawnpoint_titan_" + ENT_SPAWNTITAN_COUNT+1)
		ENT_STARTSPAWNTITAN_COUNT++
		ENT_SPAWNTITAN_COUNT++
	}
	foreach(location in MIA_TITAN_SPAWNSTART_IMC) {
		CreateTitanPilotStartSpawnPoint(location.origin, location.angles, TEAM_IMC, "info_spawnpoint_titan_start_" + (ENT_STARTSPAWNTITAN_COUNT+1))
		CreateTitanPilotSpawnPoint(location.origin, location.angles, TEAM_UNASSIGNED, "info_spawnpoint_titan_" + (ENT_SPAWNTITAN_COUNT+1))
		ENT_STARTSPAWNTITAN_COUNT++
		ENT_SPAWNTITAN_COUNT++
	}

	foreach(location in MIA_DROPPOD_SPAWN_MILITIA) {
		CreateDropPodStartSpawnPoint(location.origin, location.angles, TEAM_MILITIA, "info_spawnpoint_droppod_start_" + (ENT_STARTSPAWNDROPPOD_COUNT+1))
		CreateDropPodSpawnPoint(location.origin, location.angles, TEAM_MILITIA, "info_spawnpoint_droppod_" + (ENT_SPAWNDROPPOD_COUNT+1))
		ENT_STARTSPAWNDROPPOD_COUNT++
		ENT_SPAWNDROPPOD_COUNT++
	}
	foreach(location in MIA_DROPPOD_SPAWN_IMC) {
		CreateDropPodStartSpawnPoint(location.origin, location.angles, TEAM_IMC, "info_spawnpoint_droppod_start_" + (ENT_STARTSPAWNDROPPOD_COUNT+1))
		CreateDropPodSpawnPoint(location.origin, location.angles, TEAM_IMC, "info_spawnpoint_droppod_" + (ENT_SPAWNDROPPOD_COUNT+1))
		ENT_STARTSPAWNDROPPOD_COUNT++
		ENT_SPAWNDROPPOD_COUNT++
	}

/*
	foreach(location in MIA_DROPSHIP_SPAWN) {
		CreateDropShipSpawnPoint(location.origin, location.angles, TEAM_UNASSIGNED, "info_spawnpoint_dropship_" + (ENT_SPAWNDROSHIP_COUNT+1))
		ENT_SPAWNDROSHIP_COUNT++
	}
	foreach(location in MIA_MARVIN_SPAWN) {
		CreateMarvinSpawnPoint(location.origin, location.angles, TEAM_UNASSIGNED, "info_spawnpoint_marvin_" + (ENT_SPAWNMARVIN_COUNT+1))
		ENT_SPAWNMARVIN_COUNT++
	}
*/
}

function Mia_CreateEvacNodes()
{
	// The single previous evac spot sucks so im getting rid of it
	local oldEvacNode = GetEnt( "escape_node1" )
	oldEvacNode.Kill()

	// Nothing wrong with this camera spot, just recreating it below
	local oldSpecCam = GetEnt( "spec_cam1" )
	oldSpecCam.Kill()

	local ENT_EVACNODES_COUNT = GetEntArrayByNameWildCard_Expensive( "escape_node*" ).len()
	local ENT_EVACSPEC_CAM_COUNT = GetEntArrayByNameWildCard_Expensive( "spec_cam*" ).len()

	local MIA_EVACNODES = [
		// Front cargo door, Militia side
		{ origin = Vector( 3100, 5000, 0 ), angles = Vector( 0, 90, 0 ), camera = "spec_cam1" },
		{ origin = Vector( 2350, 5000, 0 ), angles = Vector( 0, 90, 0 ), camera = "spec_cam1" },

		// Mid
		{ origin = Vector( 1408, 5000, 0 ), angles = Vector( 0, 90, 0 ), camera = "spec_cam2" },
		{ origin = Vector( 650, 5000, 0 ), angles = Vector( 0, 90, 0 ), camera = "spec_cam2" },

		// Back
		{ origin = Vector( -350, 5000, 0 ), angles = Vector( 0, 90, 0 ), camera = "spec_cam2" },
		{ origin = Vector( -1080, 5000, 0 ), angles = Vector( 0, 90, 0 ), camera = "spec_cam2" },

////////////////////////////////////////////////////////////////////////////////////////////////////////////

		// Front cargo door, IMC side
		{ origin = Vector( 3100, 2100, 0 ), angles = Vector( 0, -90, 0 ), camera = "spec_cam3" },
		{ origin = Vector( 2350, 2100, 0 ), angles = Vector( 0, -90, 0 ), camera = "spec_cam3" },

		// Mid
		{ origin = Vector( 1408, 2100, 0 ), angles = Vector( 0, -90, 0 ), camera = "spec_cam4" },
		{ origin = Vector( 650, 2100, 0 ), angles = Vector( 0, -90, 0 ), camera = "spec_cam4" },

		// Back
		{ origin = Vector( -350, 2100, 0 ), angles = Vector( 0, -90, 0 ), camera = "spec_cam4" },
		{ origin = Vector( -1080, 2100, 0 ), angles = Vector( 0, -90, 0 ), camera = "spec_cam4" }
	]

/*
	// This is stupid, theres definitely a better way to do this
	local MIA_CAMNODES = [
		// Front cargo door, Militia side
		{ origin = Vector( -576, 5920, 480 ), angles = Vector( 18.0352, -43.483, 13.322 ) },
		{ origin = Vector( -576, 5920, 480 ), angles = Vector( 18.0352, -43.483, 13.322 ) },

		// Mid
		{ origin = Vector( 2976, 5920, 480 ), angles = Vector( 18.0352, -143.483, 13.322 ) },
		{ origin = Vector( 2976, 5920, 480 ), angles = Vector( 18.0352, -143.483, 13.322 ) },

		// Back
		{ origin = Vector( 2976, 5920, 480 ), angles = Vector( 18.0352, -143.483, 13.322 ) },
		{ origin = Vector( 2976, 5920, 480 ), angles = Vector( 18.0352, -143.483, 13.322 ) },

////////////////////////////////////////////////////////////////////////////////////////////////////////////

		// Front cargo door, IMC side
		{ origin = Vector( -576, 1180, 480 ), angles = Vector( 18.0352, 43.483, 13.322 ) },
		{ origin = Vector( -576, 1180, 480 ), angles = Vector( 18.0352, 43.483, 13.322 ) },

		// Mid
		{ origin = Vector( 2976, 1180, 480 ), angles = Vector( 18.0352, 143.483, 13.322 ) },
		{ origin = Vector( 2976, 1180, 480 ), angles = Vector( 18.0352, 143.483, 13.322 ) },

		// Back
		{ origin = Vector( 2976, 1180, 480 ), angles = Vector( 18.0352, 143.483, 13.322 ) },
		{ origin = Vector( 2976, 1180, 480 ), angles = Vector( 18.0352, 143.483, 13.322 ) }
	]
*/

	local MIA_CAMNODES = [
		// Front cargo door, Militia side
		{ origin = Vector( -576, 5920, 480 ), angles = Vector( 18.0352, -43.483, 13.322 ) },

		// Mid + back
		{ origin = Vector( 2976, 5920, 480 ), angles = Vector( 18.0352, -143.483, 13.322 ) },

////////////////////////////////////////////////////////////////////////////////////////////////////////////

		// Front cargo door, IMC side
		{ origin = Vector( -576, 1180, 480 ), angles = Vector( 18.0352, 43.483, 13.322 ) },

		// Mid
		{ origin = Vector( 2976, 1180, 480 ), angles = Vector( 18.0352, 143.483, 13.322 ) }
	]

	foreach( location in MIA_CAMNODES )
	{
		CreateInfoTarget( location.origin, location.angles, "spec_cam" + ( ENT_EVACSPEC_CAM_COUNT + 1 ) )
		ENT_EVACSPEC_CAM_COUNT++
	}

	foreach( location in MIA_EVACNODES )
	{
		//CreateInfoTarget( location.origin, location.angles, "escape_node" + ( ENT_EVACNODES_COUNT + 1 ), "spec_cam" + ENT_EVACSPEC_CAM_COUNT )
		CreateInfoTarget( location.origin, location.angles, "escape_node" + ( ENT_EVACNODES_COUNT + 1 ), location.camera )
		ENT_EVACNODES_COUNT++

		Evac_AddLocation( "escape_node" + ENT_EVACNODES_COUNT, location.origin, location.angles )
	}

	local spacenode = GetEnt( "intro_spacenode" )
	Evac_SetSpaceNode( spacenode )
}

/************************************************************************************************\

##     ##    ###    ########  ######  ##     ##       ########  ########   #######   ######   ########  ########  ######   ######
###   ###   ## ##      ##    ##    ## ##     ##       ##     ## ##     ## ##     ## ##    ##  ##     ## ##       ##    ## ##    ##
#### ####  ##   ##     ##    ##       ##     ##       ##     ## ##     ## ##     ## ##        ##     ## ##       ##       ##
## ### ## ##     ##    ##    ##       #########       ########  ########  ##     ## ##   #### ########  ######    ######   ######
##     ## #########    ##    ##       ##     ##       ##        ##   ##   ##     ## ##    ##  ##   ##   ##             ##       ##
##     ## ##     ##    ##    ##    ## ##     ##       ##        ##    ##  ##     ## ##    ##  ##    ##  ##       ##    ## ##    ##
##     ## ##     ##    ##     ######  ##     ##       ##        ##     ##  #######   ######   ##     ## ########  ######   ######


\************************************************************************************************/
function MatchProgressSetup()
{
	GM_SetMatchProgressAnnounceFunc( MatchProgressUpdate )
}

// Only send important major milestones to client
function MatchProgressMilestones()
{
	FlagWait( "Mia_Match01Percent" )
	level.nv.matchProgressMilestone = 1

	FlagWait( "Mia_Match15Percent" )
	level.nv.matchProgressMilestone = 15

	FlagWait( "Mia_Match25Percent" )
	level.nv.matchProgressMilestone = 25

	FlagWait( "Mia_Match40Percent" )
	level.nv.matchProgressMilestone = 40

	FlagWait( "Mia_Match45Percent" )
	level.nv.matchProgressMilestone = 45

	FlagWait( "Mia_Match60Percent" )
	level.nv.matchProgressMilestone = 60

	FlagWait( "Mia_Match80Percent" )
	level.nv.matchProgressMilestone = 80

	FlagWait( "Mia_Match90Percent" )
	level.nv.matchProgressMilestone = 90

	FlagWait( "Mia_Match98Percent" )
	level.nv.matchProgressMilestone = 98
}

function MatchProgressUpdate( percentComplete )
{
	Assert( GetGameState() == eGameState.Playing )

	if ( level.devForcedWin )
		return

	// Set some progress flags - used for narrative & skyshow
	if( !Flag( "Mia_Match01Percent" )&& percentComplete >= 1 )
		FlagSet( "Mia_Match01Percent" )

	if( !Flag( "Mia_Match15Percent" )&& percentComplete >= 15 )
		FlagSet( "Mia_Match15Percent" )

	if( !Flag( "Mia_Match25Percent" )&& percentComplete >= 25 )
		FlagSet( "Mia_Match25Percent" )

	if( !Flag( "Mia_Match40Percent" ) && percentComplete >= 40 )
		FlagSet( "Mia_Match40Percent" )

	if( !Flag( "Mia_Match45Percent" ) && percentComplete >= 45 )
		FlagSet( "Mia_Match45Percent" )

	if( !Flag( "Mia_Match60Percent" ) && percentComplete >= 60 )
		FlagSet( "Mia_Match60Percent" )

	if( !Flag( "Mia_Match80Percent" ) && percentComplete >= 80 )
		FlagSet( "Mia_Match80Percent" )

	if( !Flag( "Mia_Match90Percent" ) && percentComplete >= 90 )
		FlagSet( "Mia_Match90Percent" )

	if( !Flag( "Mia_Match98Percent" ) && percentComplete >= 98 )
		FlagSet( "Mia_Match98Percent" )

	// On top of the custom stuff, we want the default announcements, so call default announcements
	DefaultMatchProgressionAnnouncement( percentComplete )
}

Mp_Mia_main()

