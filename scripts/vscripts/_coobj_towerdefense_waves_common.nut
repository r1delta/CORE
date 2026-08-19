// _COOBJ_towerdefense_waves_common.nut
//
function main()
{
	Assert( GAMETYPE == COOPERATIVE )

	Setup_Common_WaveNames()
}

function Setup_Common_WaveNames()
{
	AddWaveName( "name_angel_city_warm_up", 			"#WAVE_NAME_ANGEL_CITY_WARM_UP" )
	AddWaveName( "name_angel_city_mortar_intro", 		"#WAVE_NAME_ANGEL_CITY_MORTAR_INTRO" )
	AddWaveName( "name_angel_city_emp_intro", 			"#WAVE_NAME_ANGEL_CITY_EMP_INTRO" )
	AddWaveName( "name_angel_city_close_titans", 		"#WAVE_NAME_ANGEL_CITY_CLOSE_TITANS" )
	AddWaveName( "name_angel_city_final", 				"#WAVE_NAME_ANGEL_CITY_FINAL" )
	AddWaveName( "name_colony_wepierce", 				"#WAVE_NAME_COLONY_WEPIERCE" )
	AddWaveName( "name_colony_seekstrikedestroy", 		"#WAVE_NAME_COLONY_SEEKSTRIKEDESTROY" )
	AddWaveName( "name_colony_battlebots", 				"#WAVE_NAME_COLONY_BATTLEBOTS" )
	AddWaveName( "name_colony_warmachines", 			"#WAVE_NAME_COLONY_WARMACHINES" )
	AddWaveName( "name_colony_armorcompany", 			"#WAVE_NAME_COLONY_ARMORCOMPANY" )
	AddWaveName( "name_colony_ironcurtain", 			"#WAVE_NAME_COLONY_IRONCURTAIN" )
	AddWaveName( "name_fracture_warm_up", 				"#WAVE_NAME_FRACTURE_WARM_UP" )
	AddWaveName( "name_fracture_suicide", 				"#WAVE_NAME_FRACTURE_SUICIDE" )
	AddWaveName( "name_fracture_nuke", 					"#WAVE_NAME_FRACTURE_NUKE" )
	AddWaveName( "name_fracture_arc", 					"#WAVE_NAME_FRACTURE_ARC" )
	AddWaveName( "name_fracture_final", 				"#WAVE_NAME_FRACTURE_FINAL" )
	AddWaveName( "name_overlook_warm_up", 				"#WAVE_NAME_OVERLOOK_WARM_UP" )
	AddWaveName( "name_overlook_suicide", 				"#WAVE_NAME_OVERLOOK_SUICIDE" )
	AddWaveName( "name_overlook_nuke", 					"#WAVE_NAME_OVERLOOK_NUKE" )
	AddWaveName( "name_overlook_close", 				"#WAVE_NAME_OVERLOOK_CLOSE" )
	AddWaveName( "name_overlook_final", 				"#WAVE_NAME_OVERLOOK_FINAL" )
	AddWaveName( "name_smuggler_mechanizedinfantry",	"#WAVE_NAME_SMUGGLER_MECHANIZEDINFANTRY" )
	AddWaveName( "name_smuggler_touchsensitive", 		"#WAVE_NAME_SMUGGLER_TOUCHSENSITIVE" )
	AddWaveName( "name_smuggler_mixedmetal", 			"#WAVE_NAME_SMUGGLER_MIXEDMETAL" )
	AddWaveName( "name_smuggler_armorcompany", 			"#WAVE_NAME_SMUGGLER_ARMORCOMPANY" )
	AddWaveName( "name_smuggler_mechanizedwarfare", 	"#WAVE_NAME_SMUGGLER_MECHANIZEDWARFARE" )
	AddWaveName( "name_smuggler_fallout", 				"#WAVE_NAME_SMUGGLER_FALLOUT" )
	AddWaveName( "name_mortarstrike", 					"#WAVE_NAME_MORTARSTRIKE" )
	AddWaveName( "name_lagoon_rangers", 				"#WAVE_NAME_LAGOON_RANGERS" )
	AddWaveName( "name_lagoon_zeroin", 					"#WAVE_NAME_LAGOON_ZEROIN" )
	AddWaveName( "name_lagoon_armorcompany", 			"#WAVE_NAME_LAGOON_ARMORCOMPANY" )
	AddWaveName( "name_lagoon_mechanizedwarfare", 		"#WAVE_NAME_LAGOON_MECHANIZEDWARFARE" )
	AddWaveName( "name_lagoon_fissionassist", 			"#WAVE_NAME_LAGOON_FISSIONASSIST" )
	AddWaveName( "name_rise_nutsandbolts", 				"#WAVE_NAME_RISE_NUTSANDBOLTS" )
	AddWaveName( "name_rise_corioliseffect", 			"#WAVE_NAME_RISE_CORIOLISEFFECT" )
	AddWaveName( "name_rise_armorcompany", 				"#WAVE_NAME_RISE_ARMORCOMPANY" )
	AddWaveName( "name_rise_mad", 						"#WAVE_NAME_RISE_MAD" )
	AddWaveName( "name_sandtrap_warm_up", 				"#WAVE_NAME_SANDTRAP_WARM_UP" )
	AddWaveName( "name_sandtrap_suicide", 				"#WAVE_NAME_SANDTRAP_SUICIDE" )
	AddWaveName( "name_sandtrap_nuke", 					"#WAVE_NAME_SANDTRAP_NUKE" )
	AddWaveName( "name_sandtrap_arc", 					"#WAVE_NAME_SANDTRAP_ARC" )
	AddWaveName( "name_sandtrap_final", 				"#WAVE_NAME_SANDTRAP_FINAL" )
	AddWaveName( "name_swampland_warm_up", 				"#WAVE_NAME_SWAMPLAND_WARM_UP" )
	AddWaveName( "name_swampland_mortar_intro", 		"#WAVE_NAME_SWAMPLAND_MORTAR_INTRO" )
	AddWaveName( "name_swampland_emp_intro", 			"#WAVE_NAME_SWAMPLAND_EMP_INTRO" )
	AddWaveName( "name_swampland_mortars2", 			"#WAVE_NAME_SWAMPLAND_MORTARS2" )
	AddWaveName( "name_swampland_final", 				"#WAVE_NAME_SWAMPLAND_FINAL" )
	AddWaveName( "name_training_ground_wave1", 			"#WAVE_NAME_TRAINING_GROUND_WAVE1" )
	AddWaveName( "name_training_ground_wave2", 			"#WAVE_NAME_TRAINING_GROUND_WAVE2" )
	AddWaveName( "name_training_ground_wave3", 			"#WAVE_NAME_TRAINING_GROUND_WAVE3" )
	AddWaveName( "name_training_ground_wave4", 			"#WAVE_NAME_TRAINING_GROUND_WAVE4" )
	AddWaveName( "name_training_ground_wave5", 			"#WAVE_NAME_TRAINING_GROUND_WAVE5" )
	AddWaveName( "name_training_ground_wave6", 			"#WAVE_NAME_TRAINING_GROUND_WAVE6" )
	AddWaveName( "name_nexus_wave1", 					"#WAVE_NAME_NEXUS_WAVE1" )
	AddWaveName( "name_nexus_wave2", 					"#WAVE_NAME_NEXUS_WAVE2" )
	AddWaveName( "name_nexus_wave3", 					"#WAVE_NAME_NEXUS_WAVE3" )
	AddWaveName( "name_nexus_wave4", 					"#WAVE_NAME_NEXUS_WAVE4" )
	AddWaveName( "name_nexus_wave5", 					"#WAVE_NAME_NEXUS_WAVE5" )
	AddWaveName( "name_relic_wave1", 					"#WAVE_NAME_RELIC_WAVE1" )
	AddWaveName( "name_relic_wave2", 					"#WAVE_NAME_RELIC_WAVE2" )
	AddWaveName( "name_relic_wave3", 					"#WAVE_NAME_RELIC_WAVE3" )
	AddWaveName( "name_relic_wave4", 					"#WAVE_NAME_RELIC_WAVE4" )
	AddWaveName( "name_endless_zero", 					"#WAVE_NAME_ENDLESS_ZERO" )
	AddWaveName( "name_endless_one", 					"#WAVE_NAME_ENDLESS_ONE" )
	AddWaveName( "name_airbase_wave1", 					"#WAVE_NAME_AIRBASE_WAVE1" )
	AddWaveName( "name_airbase_wave2", 					"#WAVE_NAME_AIRBASE_WAVE2" )
	AddWaveName( "name_airbase_wave3", 					"#WAVE_NAME_AIRBASE_WAVE3" )
	AddWaveName( "name_airbase_wave4", 					"#WAVE_NAME_AIRBASE_WAVE4" )
	AddWaveName( "name_airbase_wave5", 					"#WAVE_NAME_AIRBASE_WAVE5" )
	AddWaveName( "name_corporate_wave1", 				"#WAVE_NAME_CORPORATE_WAVE1" )
	AddWaveName( "name_corporate_wave2", 				"#WAVE_NAME_CORPORATE_WAVE2" )
	AddWaveName( "name_corporate_wave3", 				"#WAVE_NAME_CORPORATE_WAVE3" )
	AddWaveName( "name_corporate_wave4", 				"#WAVE_NAME_CORPORATE_WAVE4" )
	AddWaveName( "name_corporate_wave5", 				"#WAVE_NAME_CORPORATE_WAVE5" )
	AddWaveName( "name_boneyard_wave1", 				"#WAVE_NAME_NEXUS_WAVE2" )
	AddWaveName( "name_boneyard_wave2", 				"#WAVE_NAME_BONEYARD_WAVE2" )
	AddWaveName( "name_boneyard_wave3", 				"#WAVE_NAME_BONEYARD_WAVE3" )
	AddWaveName( "name_boneyard_wave4", 				"#WAVE_NAME_BONEYARD_WAVE4" )
	AddWaveName( "name_boneyard_wave5", 				"#WAVE_NAME_BONEYARD_WAVE5" )
	AddWaveName( "name_backwater_wave1", 				"#WAVE_NAME_BACKWATER_WAVE1" )
	AddWaveName( "name_backwater_wave2", 				"#WAVE_NAME_BACKWATER_WAVE2" )
	AddWaveName( "name_backwater_wave3", 				"#WAVE_NAME_BACKWATER_WAVE3" )
	AddWaveName( "name_backwater_wave4", 				"#WAVE_NAME_BACKWATER_WAVE4" )
	AddWaveName( "name_backwater_wave5", 				"#WAVE_NAME_BACKWATER_WAVE5" )

	AddWaveName( "name_nest1", "Surrounding Threat" )
	AddWaveName( "name_nest2", "Spectres of Death" )
	AddWaveName( "name_nest3", "Titan Activation" )
	AddWaveName( "name_nest4", "Bullet Storm" )
	AddWaveName( "name_nest5", "Missile Rain" )
	AddWaveName( "name_nest6", "Budget Issues" )
	AddWaveName( "name_nest7", "Thunder Strikes" )
	AddWaveName( "name_nest8", "Accelerating Fusion" )
	AddWaveName( "name_nest9", "Final Hour" )// Yoshi was here

	/*
	// WAVE ANNOUNCE VO - for LD reference, please do not remove -SRS
	// - This is for when an LD wants to totally customize the wave announcement VO that plays at the start of a wave.
	HOWTO: set up your wave like normal, then do:  Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Infantry_NoTitans" )

	// "standard"
	CoopTD_EnemyAnnounce_Infantry
	CoopTD_EnemyAnnounce_SuicideSpectre
	CoopTD_EnemyAnnounce_CloakDrone
	CoopTD_EnemyAnnounce_Titans
	CoopTD_EnemyAnnounce_MortarTitans
	CoopTD_EnemyAnnounce_NukeTitans
	CoopTD_EnemyAnnounce_ArcTitans

	// "custom"
	CoopTD_EnemyAnnounce_Infantry_NoTitans
	CoopTD_EnemyAnnounce_Combo_NukeMortar
	CoopTD_EnemyAnnounce_Combo_ArcMortar
	CoopTD_EnemyAnnounce_Combo_ArcNuke
	CoopTD_EnemyAnnounce_Combo_CloakNuke
	CoopTD_EnemyAnnounce_Combo_NukeSuicide
	CoopTD_EnemyAnnounce_Combo_SniperSuicide
	CoopTD_EnemyAnnounce_Combo_MortarSuicide
	CoopTD_EnemyAnnounce_KitchenSink
	CoopTD_EnemyAnnounce_NukeTrain
	CoopTD_EnemyAnnounce_Rise_HugeWave
	*/
}

// -------------------------------------
// ADD NEW COMMON WAVE FUNCTIONS BELOW!
// -------------------------------------
/* EXAMPLE FUNCTION TEMPLATE
function CommonWave_MyWave()
{
	// 1) Always want to create a wave
	local wave = TowerDefense_AddWave()

	// 2) WAVE BEHAVIOR GOES HERE!

	// 3) always return the wave at the end
	return wave
}
Globalize( CommonWave_MyWave )  // Don't forget to globalize the actual function name
*/

	//=============LEVEL SPECIFIC=============
	//=============LEVEL SPECIFIC=============
	//=============LEVEL SPECIFIC=============
	//=============LEVEL SPECIFIC=============

function CommonWave_Angel_City_Waves()
{
	//WARM UP
	local wave = TowerDefense_AddWave( "name_angel_city_warm_up" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Infantry" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "centerRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "harborRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "fieldRouteClose" )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "centerRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "harborRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "fieldRouteClose" )

	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "group1", null, "centerRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "group1", null, "harborRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "group1", null, "fieldRouteClose" )

	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "group2", "group1", "fieldRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "group2", "group1", "harborRouteClose" )

	Wave_AddPause( wave, 10 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, "group2", "centerRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, "group2", "harborRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, "group2", "fieldRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, "group2" )

	Wave_AddPause( wave, 3 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, "group2"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, "group2" )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group2", "centerRouteClose"  )

	Wave_SetBreakTime( wave, 15 )

	//Wave: EMP TITANS + SOLDIERS
	local wave = TowerDefense_AddWave( "name_angel_city_emp_intro" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_ArcTitans" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "start", null, "centerRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "start", null, "harborRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "start", null, "fieldRouteClose" )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "start", null, "centerRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "start", null, "harborRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "start", null, "fieldRouteClose" )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, "start", null, "centerRouteClose"  )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", "start", "centerRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops1", "start", "centerRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", "start", "centerRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops1", "start", "centerRoute" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 		"titan1", "start", "centerRoute" )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 		"titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan2", "titan1" )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 		"troops3", "troops2", "centerRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			"troops3", "titan2", "fieldRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 		"troops3", "troops2", "harborRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 		"troops3", "troops2", "centerRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 			"troops3", "titan2", "fieldRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 		"troops3", "troops2", "harborRouteClose" )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 					null, "troops3" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 		null, "troops3" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 					null, "troops3" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 						null, "troops3" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 						null, "troops3" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 						null, "troops3" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 						null, "troops3" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 					null, "troops3", "centerRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 		null, "troops3", "fieldRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 					null, "troops3", "harborRouteClose" )

	Wave_SetBreakTime( wave, 15 )

//MORTAR INTRO
	local wave = TowerDefense_AddWave( "name_angel_city_mortar_intro" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_MortarTitans" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "start", null, "centerRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "start", null, "harborRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "start", null, "fieldRouteClose" )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "start", null, "centerRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "start", null, "harborRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "start", null, "fieldRouteClose" )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "start", null, "centerRoute"  )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", "start", "centerRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops1", "start", "centerRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", "start", "centerRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops1", "start", "centerRoute" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 		"titan1", "start", "centerRoute" )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 		"titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan2", "titan1" )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 					"troops3", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 		"troops3", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 					"troops3", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 		"troops3", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			"troops3", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnTitan,  						"titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 						"titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 						"titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 						"titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 						"titan3", "titan2" )

	Wave_SetBreakTime( wave, 15 )


	//Wave: CLOSE TITANS
	local wave = TowerDefense_AddWave( "name_angel_city_close_titans" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Titans" )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "centerRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops1", null, "centerRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "centerRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops1", null, "centerRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "harborRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "fieldRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 	"troops1", null, "harborRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 	"troops1", null, "fieldRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 		"titan1", null, "centerRoute" )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 		"titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan2", "titan1" )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 					"troops3", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 		"troops3", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 					"troops3", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 		"troops3", "troops2", "harborRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			"troops3", "troops2", "fieldRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 		"troops3", "troops2", "harborRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 			"troops3", "troops2", "fieldRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnTitan,  						"titan3", "titan2", "harborRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 						"titan3", "titan2", "fieldRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 						"titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 						"titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 						"titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 						"titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 						"titan3", "titan2" )

	Wave_SetBreakTime( wave, 15 )

	//Wave: FINAL - EVERYTHING
	local wave = TowerDefense_AddWave( "name_angel_city_final" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Combo_ArcMortar" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"close1", null, "centerRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"close1", null, "harborRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"close1", null, "fieldRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"close1", null, "centerRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"close1", null, "harborRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"close1", null, "fieldRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnTitan, 	"close1", null, "harborRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 	"close1", null, "fieldRouteClose"  )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", 	"close1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops1", 	"close1" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", 	"close1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops1", 	"close1" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 		"titan1", 	"close1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan1", 	"close1" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 		"titan1", 	"close1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan1", 	"close1" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 		"titan1", 	"close1" )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", "troops1", "centerRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", "titan1", "harborRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", "titan1", "fieldRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "titan1"  )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops3", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3", "troops2", "fieldRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3", "troops2", "harborRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan2", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan2", "troops2", "harborRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 		"titan2", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan2", "troops2", "fieldRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 		"titan2", "troops2" )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4", "troops3", "centerRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops4", "titan2", "harborRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops4", "titan2", "fieldRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops4", "troops3"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops4", "titan2"  )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 					null, "troops4", "fieldRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 		null, "troops4", "harborRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 					null, "troops4" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 		null, "troops4" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 					null, "troops4" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			null, "troops4" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 					null, "troops4" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 					null, "troops4" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 					null, "troops4" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 					null, "troops4", "fieldRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 						null, "troops4", "harborRouteClose" )

	Wave_AddPause( wave, 5, "troops4" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 					null, "troops4" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 						null, "troops4" )

	Wave_AddPause( wave, 5, "troops4" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 						null, "troops4", "fieldRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 						null, "troops4", "harborRouteClose" )


	Wave_SetBreakTime( wave, 15 )


	return wave
}
Globalize( CommonWave_Angel_City_Waves )

function CommonWave_Colony_Waves()
{
	//wave 1:
	local wave = TowerDefense_AddWave( "name_colony_wepierce" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Infantry_NoTitans" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,	"troops1", null, "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops1", null, "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops1", null, "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops1", null, "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", null, "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", null, "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", null, "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", null, "fourRoute" )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	null, "troops1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	null, "troops1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	null, "troops1", "leftcloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	null, "troops2", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	null, "troops2", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	null, "troops2", "rightcloseRoute" )

	Wave_SetBreakTime( wave, 10 )


	//wave 2:
	local wave = TowerDefense_AddWave( "name_colony_seekstrikedestroy" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_SuicideSpectre" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, "titan1", null, "twoRoute")
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, "titan1", null, "fourRoute")
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, "titan2", "titan1", "twoRoute")
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, "titan2", "titan1", "fourRoute")

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", null, "twoRoute")
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", null, "twoRoute")
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", null, "twoRoute")
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", null, "fourRoute")
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", null, "fourRoute")
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", null, "fourRoute")

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide2", "suicide1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide2", "suicide1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide2", "suicide1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide2", "suicide1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide2", "suicide1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide2", "suicide1", "rightcloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide3", "suicide2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide3", "suicide2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide3", "suicide2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide3", "suicide2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide3", "suicide2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide3", "suicide2", "centercloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide4", "suicide3", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide4", "suicide3", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide4", "suicide3", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide4", "suicide3", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide4", "suicide3", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide4", "suicide3", "leftcloseRoute" )

	Wave_SetBreakTime( wave, 10 )


	//wave 3:
	local wave = TowerDefense_AddWave( "name_colony_battlebots" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Combo_NukeSuicide" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops1", null, "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone, 	"troops1", null, "twoRoute" )

	Wave_AddPause( wave, 1.5 )

	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops1", null, "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops1", null, "twoRoute" )

	Wave_AddSpawn( wave, TD_SpawnCloakedDrone, 	"troops2", "troops1", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,	"troops2", "troops1", "fourRoute" )

	Wave_AddPause( wave, 1.5 )

	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops2", "troops1", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops2", "troops1", "fourRoute" )

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", "troops2", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", "troops2", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", "troops2", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", "troops2", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", "troops2", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", "troops2", "rightcloseRoute" )

	Wave_AddPause( wave, 0.5 )

	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops3", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops3", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops3", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops3", "troops2" )

	Wave_SetBreakTime( wave, 10 )


	//wave 4:
	local wave = TowerDefense_AddWave( "name_colony_warmachines" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Combo_ArcMortar" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 		"titan1", null, "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan1", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan1", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan1", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan1" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan1", null, "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan1", null, "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan1", null, "twoRoute" )

	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 		"titan2", "titan1", "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan2", "titan1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan2", "titan1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan2", "titan1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan2", "titan1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan2", "titan1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan2", "titan1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan2", "titan1", "twoRoute" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan2", "titan1", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan2", "titan1", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan2", "titan1", "fourRoute" )

	Wave_SetBreakTime( wave, 15 )


	//wave 5: 12 Grunts, 28 Spectres, 52 Suicide Spectres, 6 Titans, 4 Nuke Titan == Introduce Nuke Titan (102 Units)
	local wave = TowerDefense_AddWave( "name_colony_armorcompany" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_NukeTrain" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops1", null, "centercloseRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 		"troops1", null, "twoRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops1", null, "twoRoute" )

	Wave_AddPause( wave, 8 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", null, "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", null, "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", null, "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", null, "fourRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 		"troops2", null, "fourRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops2", null, "fourRoute" )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3", "troops1", "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3", "troops1", "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3", "troops1", "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3", "troops1", "twoRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"troops3", "troops1", "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"troops3", "troops1", "twoRoute" )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3", "troops2", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3", "troops2", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3", "troops2", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3", "troops2", "fourRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"troops3", "troops2", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"troops3", "troops2", "fourRoute" )

	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops4", "troops3", "twoRoute" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4", "troops3", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops4", "troops3", "fourRoute" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4", "troops3", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops4", "troops3", "twoRoute" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4", "troops3", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops4", "troops3", "fourRoute" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4", "troops3", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops4", "troops3", "twoRoute" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4", "troops3", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops4", "troops3", "fourRoute" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4", "troops3", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops4", "troops3", "twoRoute" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4", "troops3", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops4", "troops3", "fourRoute" )

	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops5", "troops4", "fourRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops5", "troops4", "twoRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops5", "troops4", "fourRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops5", "troops4", "twoRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops5", "troops4", "fourRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops5", "troops4", "twoRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops5", "troops4", "fourRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops5", "troops4", "twoRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops5", "troops4", "fourRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops5", "troops4", "twoRoute" )

	Wave_SetBreakTime( wave, 10 )


	return wave
}
Globalize( CommonWave_Colony_Waves )

function CommonWave_Fracture_Waves()
{
	//WARM UP
	local wave = TowerDefense_AddWave( "name_fracture_warm_up" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Infantry" )	
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "UpperCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "UpperCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "UpperCloseRoute" )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "LowerCharlieCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "LowerCharlieCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "LowerBravoCloseRoute" )

	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "group1", null, "UpperCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "group1", null, "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "group1", null, "LowerCharlieCloseRoute" )

	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "group2", "group1", "UpperCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "group2", "group1", "LowerBravoCloseRoute" )

	Wave_AddPause( wave, 10 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, "group2", "UpperCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, "group2", "UpperCloseRoute" )

	Wave_AddPause( wave, 3 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, "group2", "UpperCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, "group2", "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, "group2", "LowerBravoCloseRoute" )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group2", "UpperCloseRoute" )

	Wave_SetBreakTime( wave, 15 )

	//TEST - Suicide intro
	local wave = TowerDefense_AddWave( "name_fracture_suicide" )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, null, "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, null, "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group1", null, "LowerBravoCloseRoute" )

	Wave_AddPause( wave, 7 )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, null, "UpperCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, null, "UpperCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group1", null, "UpperCloseRoute"  )

	Wave_AddPause( wave, 7 )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, null, "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, null, "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group1", null, "LowerCharlieCloseRoute" )

	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group2", "group1", "UpperCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group2", "group1", "LowerBravoCloseRoute" )
	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group2", "group1", "UpperCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group2", "group1", "LowerCharlieCloseRoute" )
	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnTitan, "group2", "group1", "UpperCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnTitan, "group2", "group1", "LowerCharlieCloseRoute"  )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, "group2", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, "group2", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerRoute" )

	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group2", "LowerRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerRoute" )


	Wave_AddPause( wave, 5 )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, "group2", "UpperCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, "group2", "UpperCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "UpperCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "UpperCloseRoute"  )

	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group2", "LowerRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerRoute" )

	Wave_AddPause( wave, 5 )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, "group2", "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, "group2", "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerRoute" )

	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group2", "LowerRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerRoute" )

	Wave_SetBreakTime( wave, 15 )


	//TEST - Nuke intro
	local wave = TowerDefense_AddWave( "name_fracture_nuke" )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "UpperCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, null, "UpperCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group1", null, "UpperCloseRoute" )

	Wave_AddPause( wave, 7 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "LowerBravoCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, null, "LowerBravoCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnTitan, "group1", null, "LowerBravoCloseRoute"  )

	Wave_AddPause( wave, 7 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, null, "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, "group1", null, "LowerCharlieCloseRoute" )

	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "group2", "group1", "LowerCharlieCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, "group2", "group1", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "group2", "group1", "LowerCharlieCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, "group2", "group1", "LowerBravoCloseRoute" )

	Wave_AddPause( wave, 10 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, "group2", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, null, "group2", "LowerBravoCloseRoute" )

	Wave_AddPause( wave, 4 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, "group2", "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group2", "LowerCharlieCloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnNukeTitan, null, "group2", "UpperRoute" )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group2", "UpperRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "UpperRoute" )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, null, "group2", "UpperRoute" )

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "UpperCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group2", "UpperCloseRoute" )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group2", "UpperRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "UpperRoute" )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, null, "group2", "UpperRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "UpperRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "UpperRoute" )

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "UpperCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "UpperCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerCharlieCloseRoute" )

	Wave_SetBreakTime( wave, 15 )


	//TEST - ARC Intro
	local wave = TowerDefense_AddWave( "name_fracture_arc" )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "UpperCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, null, "UpperCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, "group1", null, "UpperCloseRoute" )

	Wave_AddPause( wave, 7 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "LowerBravoCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, null, "LowerBravoCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnTitan, "group1", null, "LowerBravoCloseRoute"  )

	Wave_AddPause( wave, 7 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, null, "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, "group1", null, "LowerCharlieCloseRoute" )

	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "group2", "group1", "LowerCharlieCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, "group2", "group1", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "group2", "group1", "LowerCharlieCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, "group2", "group1", "LowerBravoCloseRoute" )

	Wave_AddPause( wave, 10 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, "group2", "UpperCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "UpperCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "UpperCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, null, "group2", "UpperCloseRoute" )

	Wave_AddPause( wave, 4 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, "group2", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group2", "LowerBravoCloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnEmpTitan, null, "group2", "LowerRoute" )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group2", "LowerRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerRoute" )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group2", "LowerRoute" )

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, null, "group2", "LowerCharlieCloseRoute" )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group2", "LowerRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerRoute" )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group2", "LowerRoute" )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group2", "LowerRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerRoute" )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, null, "group2", "LowerRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "UpperCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "UpperCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerCharlieCloseRoute" )

	Wave_SetBreakTime( wave, 15 )


	//TEST - Final wave
	local wave = TowerDefense_AddWave( "name_fracture_final" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Combo_ArcNuke" )	

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, null, "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group1", null, "LowerBravoCloseRoute" )

	Wave_AddPause( wave, 7 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "UpperCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, null, "UpperCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, "group1", null, "UpperCloseRoute"  )

	Wave_AddPause( wave, 7 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, null, "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group1", null, "LowerCharlieCloseRoute" )

	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "group2", "group1", "UpperCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "group2", "group1", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group2", "group1", "LowerCharlieCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group2", "group1", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, "group2", "group1", "UpperCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, "group2", "group1", "LowerCharlieCloseRoute" )

	Wave_AddPause( wave, 10 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, "group2", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, "group3", "group2", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, "group3", "group2", "LowerBravoCloseRoute" )

	Wave_AddPause( wave, 4 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, "group2", "UpperCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, "group3", "group2", "UpperCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "UpperCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, "group3", "group2", "UpperCloseRoute" )

	Wave_AddPause( wave, 4 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, "group2", "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, "group3", "group2", "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, "group3", "group2", "LowerCharlieCloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnNukeTitan, null, "group3", "LowerRoute"  )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, "group4", "group3", "UpperCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, "group4", "group3", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, "group4", "group3", "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, "group4", "group3", "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group4", "group3", "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group4", "group3", "UpperCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group4", "group3", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, "group4", "group3", "UpperRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group4", "group3", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group4", "group3", "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group4", "group3", "UpperCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, "group4", "group3", "LowerBravoCloseRoute" )

	Wave_AddPause( wave, 4 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, null, "group4", "LowerRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group4", "LowerRoute" )

	Wave_AddPause( wave, 4 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, null, "group4", "LowerRoute" )

	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, null, "group4", "UpperRoute" )

	Wave_AddPause( wave, 4 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, null, "group4", "UpperRoute" )

	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, null, "group4", "LowerRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group4", "LowerRoute" )

	Wave_AddPause( wave, 4 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, null, "group4", "UpperRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group4", "UpperRoute" )

	Wave_AddPause( wave, 4 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, null, "group4", "UpperRoute" )

	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, null, "group4", "LowerRoute" )

	Wave_AddPause( wave, 4 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, null, "group4", "UpperRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group4", "UpperRoute" )

	Wave_SetBreakTime( wave, 10 )

	return wave
}
Globalize( CommonWave_Fracture_Waves )

function CommonWave_Sandtrap_Waves()
{
	//WARM UP
	local wave = TowerDefense_AddWave( "name_sandtrap_warm_up" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Infantry" )	
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "UpperCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "UpperCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "UpperCloseRoute" )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "LowerCharlieCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "LowerCharlieCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "LowerBravoCloseRoute" )

	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "group1", null, "UpperCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "group1", null, "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "group1", null, "LowerCharlieCloseRoute" )

	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "group2", "group1", "UpperCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "group2", "group1", "LowerBravoCloseRoute" )

	Wave_AddPause( wave, 10 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, "group2", "UpperCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, "group2", "UpperCloseRoute" )

	Wave_AddPause( wave, 3 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, "group2", "UpperCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, "group2", "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, "group2", "LowerBravoCloseRoute" )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group2", "UpperCloseRoute" )

	Wave_SetBreakTime( wave, 15 )

	//TEST - Suicide intro
	local wave = TowerDefense_AddWave( "name_sandtrap_suicide" )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, null, "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, null, "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group1", null, "LowerBravoCloseRoute" )

	Wave_AddPause( wave, 7 )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, null, "UpperCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, null, "UpperCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group1", null, "UpperCloseRoute"  )

	Wave_AddPause( wave, 7 )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, null, "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, null, "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group1", null, "LowerCharlieCloseRoute" )

	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group2", "group1", "UpperCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group2", "group1", "LowerBravoCloseRoute" )
	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group2", "group1", "UpperCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group2", "group1", "LowerCharlieCloseRoute" )
	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnTitan, "group2", "group1", "UpperCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnTitan, "group2", "group1", "LowerCharlieCloseRoute"  )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, "group2", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, "group2", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerRoute" )

	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group2", "LowerRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerRoute" )


	Wave_AddPause( wave, 5 )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, "group2", "UpperCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, "group2", "UpperCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "UpperCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "UpperCloseRoute"  )

	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group2", "LowerRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerRoute" )

	Wave_AddPause( wave, 5 )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, "group2", "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, "group2", "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerRoute" )

	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group2", "LowerRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerRoute" )

	Wave_SetBreakTime( wave, 15 )


	//TEST - Nuke intro
	local wave = TowerDefense_AddWave( "name_sandtrap_nuke" )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "UpperCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, null, "UpperCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group1", null, "UpperCloseRoute" )

	Wave_AddPause( wave, 7 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "LowerBravoCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, null, "LowerBravoCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnTitan, "group1", null, "LowerBravoCloseRoute"  )

	Wave_AddPause( wave, 7 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, null, "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, "group1", null, "LowerCharlieCloseRoute" )

	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "group2", "group1", "LowerCharlieCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, "group2", "group1", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "group2", "group1", "LowerCharlieCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, "group2", "group1", "LowerBravoCloseRoute" )

	Wave_AddPause( wave, 10 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, "group2", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, null, "group2", "LowerBravoCloseRoute" )

	Wave_AddPause( wave, 4 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, "group2", "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group2", "LowerCharlieCloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnNukeTitan, null, "group2", "UpperRoute" )

	Wave_AddPause( wave, 4 )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group2", "UpperRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "UpperRoute" )

	Wave_AddPause( wave, 4 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, null, "group2", "UpperRoute" )

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "UpperCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group2", "UpperCloseRoute" )

	Wave_AddPause( wave, 4 )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group2", "UpperRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "UpperRoute" )

	Wave_AddPause( wave, 4 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, null, "group2", "UpperRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "UpperRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "UpperRoute" )

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "UpperCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "UpperCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerCharlieCloseRoute" )

	Wave_SetBreakTime( wave, 15 )


	//TEST - ARC Intro
	local wave = TowerDefense_AddWave( "name_sandtrap_arc" )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "UpperCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, null, "UpperCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, "group1", null, "UpperCloseRoute" )

	Wave_AddPause( wave, 7 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "LowerBravoCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, null, "LowerBravoCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnTitan, "group1", null, "LowerBravoCloseRoute"  )

	Wave_AddPause( wave, 7 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, null, "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, "group1", null, "LowerCharlieCloseRoute" )

	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "group2", "group1", "LowerCharlieCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, "group2", "group1", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "group2", "group1", "LowerCharlieCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, "group2", "group1", "LowerBravoCloseRoute" )

	Wave_AddPause( wave, 10 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, "group2", "UpperCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "UpperCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "UpperCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, null, "group2", "UpperCloseRoute" )

	Wave_AddPause( wave, 4 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, "group2", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group2", "LowerBravoCloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnEmpTitan, null, "group2", "LowerRoute" )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group2", "LowerRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerRoute" )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group2", "LowerRoute" )

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, null, "group2", "LowerCharlieCloseRoute" )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group2", "LowerRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerRoute" )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group2", "LowerRoute" )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group2", "LowerRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerRoute" )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, null, "group2", "LowerRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "UpperCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "UpperCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerCharlieCloseRoute" )

	Wave_SetBreakTime( wave, 15 )


	//TEST - Final wave
	local wave = TowerDefense_AddWave( "name_sandtrap_final" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Combo_ArcNuke" )	
	
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, null, "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group1", null, "LowerBravoCloseRoute" )

	Wave_AddPause( wave, 7 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "UpperCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, null, "UpperCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, "group1", null, "UpperCloseRoute"  )

	Wave_AddPause( wave, 7 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, null, "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group1", null, "LowerCharlieCloseRoute" )

	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "group2", "group1", "UpperCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "group2", "group1", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group2", "group1", "LowerCharlieCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group2", "group1", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, "group2", "group1", "UpperCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, "group2", "group1", "LowerCharlieCloseRoute" )

	Wave_AddPause( wave, 10 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, "group2", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, "group3", "group2", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, "group3", "group2", "LowerBravoCloseRoute" )

	Wave_AddPause( wave, 4 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, "group2", "UpperCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, "group3", "group2", "UpperCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "UpperCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, "group3", "group2", "UpperCloseRoute" )

	Wave_AddPause( wave, 4 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, "group2", "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, "group3", "group2", "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, "group3", "group2", "LowerCharlieCloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnNukeTitan, null, "group3", "LowerRoute"  )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, "group4", "group3", "UpperCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, "group4", "group3", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, "group4", "group3", "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, "group4", "group3", "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group4", "group3", "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group4", "group3", "UpperCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group4", "group3", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, "group4", "group3", "UpperRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group4", "group3", "LowerBravoCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group4", "group3", "LowerCharlieCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group4", "group3", "UpperCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, "group4", "group3", "LowerBravoCloseRoute" )

	Wave_AddPause( wave, 4 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, null, "group4", "LowerRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group4", "LowerRoute" )

	Wave_AddPause( wave, 4 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, null, "group4", "LowerRoute" )

	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, null, "group4", "UpperRoute" )

	Wave_AddPause( wave, 4 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, null, "group4", "UpperRoute" )

	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, null, "group4", "LowerRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group4", "LowerRoute" )

	Wave_AddPause( wave, 4 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, null, "group4", "UpperRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group4", "UpperRoute" )

	Wave_AddPause( wave, 4 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, null, "group4", "UpperRoute" )

	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, null, "group4", "LowerRoute" )

	Wave_AddPause( wave, 4 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, null, "group4", "UpperRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group4", "UpperRoute" )

	Wave_SetBreakTime( wave, 10 )

	return wave
}
Globalize( CommonWave_Sandtrap_Waves )

function CommonWave_Smuggler_Waves()
{
	//wave 1: 64 Grunts == Introduce grunts, cloakedDrone and spectres (64 Units)
	local wave = TowerDefense_AddWave( "name_smuggler_mechanizedinfantry" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Infantry_NoTitans" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,	"troops1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops1", null, "leftcloseRoute" )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnCloakedDrone,	"troops2", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,	"troops2", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops2", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops2", null, "leftcloseRoute" )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,	"troops3", "troops1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops3", "troops1", "rightcloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops3", "troops1", "rightcloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops3", "troops1", "rightcloseRoute"  )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,	"troops4", "troops2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,	"troops4", "troops2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,	"troops4", "troops2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,	"troops4", "troops2", "centercloseRoute" )

	Wave_SetBreakTime( wave, 10 )


	//wave 2: 60 Suicide Spectres == Introduce Suicide Spectres (60 Units)
	local wave = TowerDefense_AddWave( "name_smuggler_touchsensitive" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_SuicideSpectre" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,	"troops1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,	"troops1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,	"troops1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,	"troops1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,	"troops1", null, "leftcloseRoute" )

	Wave_AddPause( wave, 1 )

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,	"troops2", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,	"troops2", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,	"troops2", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,	"troops2", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,	"troops2", null, "rightcloseRoute" )


	Wave_AddPause( wave, 1 )

	Wave_AddSpawn( wave, TD_SpawnCloakedDrone )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,	"troops3", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,	"troops3", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,	"troops3", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,	"troops3", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,	"troops3", null, "centercloseRoute" )

	Wave_AddPause( wave, 1 )

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,	"troops4", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,	"troops4", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,	"troops4", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,	"troops4", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,	"troops4", null, "centercloseRoute" )

	Wave_SetBreakTime( wave, 10 )


	//wave 3: 32 Grunts, 16 Spectres, 32 Suicide Spectres == Mix all enemies (80 units)
	local wave = TowerDefense_AddWave( "name_smuggler_mixedmetal" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Titans" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,			"troops1", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,			"troops1", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,			"troops1", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,	"troops1", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone,			"troops1", null, "rightcloseRoute" )
	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops2", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			"troops2", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone,			"troops2", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops2", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops2", null, "leftcloseRoute" )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops3", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops3", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops3", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops3", null, "centercloseRoute" )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnTitan, 				"titan1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			"troops4", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 				"titan1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			"troops4", null, "centercloseRoute" )

	Wave_SetBreakTime( wave, 10 )


	//wave 4: 8 Grunts,	16 Spectres, 24 Suicide Spectres, 6 Titans, 1 CloakedDrone == Introduce Titans (55 Units)
	local wave = TowerDefense_AddWave( "name_smuggler_armorcompany" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_MortarTitans" )
	Wave_AddSpawn( wave, TD_SpawnTitan, "titan1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, "titan1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, "titan1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, "titan1" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnTitan, "titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, "titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, "titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, "titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnTitan,  		"titan4", "titan3" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan4", "titan3" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan4", "titan3" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan4", "titan3" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan4", "titan3" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan4", "titan3" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone )

	Wave_SetBreakTime( wave, 10 )


	//wave 5: 12 Grunts, 28 Spectres, 52 Suicide Spectres, 6 Titans, 4 Nuke Titan == Introduce Nuke Titan (102 Units)
	local wave = TowerDefense_AddWave( "name_smuggler_mechanizedwarfare" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Combo_NukeMortar" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,	"troops1", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,	"troops1", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,	"troops1", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,	"troops1", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan1" )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,	"troops2", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,	"troops2", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,	"troops2", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,	"troops2", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,	"troops2", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,	"troops2", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan2", "titan1" )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,	"troops3", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,	"troops3", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,	"troops3", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,	"troops3", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,	"troops3", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,	"troops3", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan3", "titan2" )


	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,	"troops4", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,	"troops4", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,	"troops4", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan4", "titan3" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"titan4", "titan3" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan4", "titan3" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan4", "titan3" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"titan4", "titan3" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan4", "titan3" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan4", "titan3" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"titan4", "titan3" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan4", "titan3" )

	Wave_SetBreakTime( wave, 10 )


/*	//wave 6:  == 8 Grunts, 72 Spectres, 48 Suicide Spectres, 7 Nuke Titans, 4 Mortar Titans (139 Units)
	local wave = TowerDefense_AddWave( "name_smuggler_fallout" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 				"titan5" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 				"titan5" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 				"titan5" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 				"titan5" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 			"titan5" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 			"titan5" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 			"titan5" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 			"titan5" )

	Wave_AddPause( wave, 7.5 )

	Wave_AddSpawn( wave, TD_SpawnTitan, 				"titan6", "titan5" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 				"titan6", "titan5" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 				"titan6", "titan5" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 				"titan6", "titan5" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 			"titan6", "titan5" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 			"titan6", "titan5" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 			"titan6", "titan5" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 			"titan6", "titan5" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,	"troops1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,	"troops1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,	"troops1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,	"troops1", null, "centercloseRoute" )

	Wave_AddPause( wave, 7.5 )

	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 			"titan7", "titan6" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 			"titan7", "titan6" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 			"titan7", "titan6" )
//	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 			"titan7", "titan6" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 			"titan7", "titan6" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 			"titan7", "titan6" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 			"titan7", "titan6" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 			"titan7", "titan6" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,	"troops2", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,	"troops2", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,	"troops2", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,	"troops2", null, "centercloseRoute" )

	Wave_AddPause( wave, 7.5 )

	Wave_AddSpawn( wave, TD_SpawnTitan, 				"titan8", "titan7" )
	Wave_AddSpawn( wave, TD_SpawnTitan,			 		"titan8", "titan7" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 				"titan8", "titan7" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 				"titan8", "titan7" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 			"titan8", "titan7" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 			"titan8", "titan7" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 			"titan8", "titan7" )
//	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 			"titan8", "titan7" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 			"titan8", "titan7" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 			"titan8", "titan7" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 			"titan8", "titan7" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 			"titan8", "titan7" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,	"troops3", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,	"troops3", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,	"troops3", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,	"troops3", null, "centercloseRoute" )


	Wave_SetBreakTime( wave, 10 )

*/	return wave
}
Globalize( CommonWave_Smuggler_Waves )


function CommonWave_Swampland_Waves()
{

	//Angel City
	local wave = TowerDefense_AddWave( "name_swampland_warm_up" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Infantry" )	
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "centerRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "templeRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "clearcutRouteClose" )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "centerRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "templeRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "clearcutRouteClose" )

	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "group1", null, "centerRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "group1", null, "templeRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "group1", null, "clearcutRouteClose" )

	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "group2", "group1", "clearcutRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "group2", "group1", "templeRouteClose" )

	Wave_AddPause( wave, 10 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, "group2", "centerRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, "group2", "templeRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, "group2", "clearcutRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, "group2" )

	Wave_AddPause( wave, 3 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, "group2", "centerRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, "group2", "centerRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group2", "centerRoute"  )

	Wave_SetBreakTime( wave, 15 )

	//Wave: EMP TITANS + SOLDIERS
	local wave = TowerDefense_AddWave( "name_swampland_emp_intro" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "start", null, "centerRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "start", null, "templeRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "start", null, "clearcutRouteClose" )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "start", null, "centerRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "start", null, "templeRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "start", null, "clearcutRouteClose" )

	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, "start", null, "centerRoute"  )

	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "start", null, "centerRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "start", null, "centerRoute"  )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", "start", "centerRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops1", "start", "centerRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 	"troops1", "start", "centerRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", "start", "centerRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops1", "start", "centerRoute" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 		"titan1", "start", "centerRoute" )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 		"titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan2", "titan1" )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 		"troops3", "troops2", "centerRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			"troops3", "titan2", "clearcutRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 		"troops3", "troops2", "templeRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 		"troops3", "troops2", "centerRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 			"troops3", "titan2", "clearcutRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 		"troops3", "troops2", "templeRouteClose" )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 					null, "troops3" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 		null, "troops3" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 					null, "troops3" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 						null, "troops3" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 						null, "troops3" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 						null, "troops3" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 						null, "troops3" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 					null, "troops3", "centerRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 		null, "troops3", "clearcutRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 					null, "troops3", "templeRouteClose" )

	Wave_SetBreakTime( wave, 15 )

//MORTAR INTRO
	local wave = TowerDefense_AddWave( "name_swampland_mortar_intro" )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "start", null, "centerRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "start", null, "templeRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "start", null, "clearcutRouteClose" )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "start", null, "centerRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "start", null, "templeRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "start", null, "clearcutRouteClose" )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "start", null, "centerRoute"  )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", "start", "centerRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops1", "start", "centerRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", "start", "centerRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops1", "start", "centerRoute" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 		"titan1", "start", "centerRoute" )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 		"titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan2", "titan1" )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 					"troops3", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 		"troops3", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 					"troops3", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 		"troops3", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			"troops3", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnTitan,  						"titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 						"titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 						"titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 						"titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 						"titan3", "titan2" )

	Wave_SetBreakTime( wave, 15 )


	//Wave: CLOSE TITANS
	local wave = TowerDefense_AddWave( "name_swampland_mortars2" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Titans" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "centerRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops1", null, "centerRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "centerRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops1", null, "centerRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "templeRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "clearcutRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 	"troops1", null, "templeRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 	"troops1", null, "clearcutRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 		"titan1", null, "centerRoute" )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 		"titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan2", "titan1" )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 					"troops3", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 		"troops3", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 					"troops3", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 		"troops3", "troops2", "templeRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			"troops3", "troops2", "clearcutRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 		"troops3", "troops2", "templeRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 			"troops3", "troops2", "clearcutRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnTitan,  						"titan3", "titan2", "templeRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 						"titan3", "titan2", "clearcutRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 						"titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 						"titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 						"titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 						"titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 						"titan3", "titan2" )

	Wave_SetBreakTime( wave, 15 )

	//Wave: FINAL - EVERYTHING
	local wave = TowerDefense_AddWave( "name_swampland_final" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Combo_ArcMortar" )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"close1", null, "centerRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"close1", null, "templeRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"close1", null, "clearcutRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"close1", null, "centerRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"close1", null, "templeRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"close1", null, "clearcutRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnTitan, 	"close1", null, "templeRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 	"close1", null, "clearcutRouteClose"  )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", 	"close1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops1", 	"close1" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", 	"close1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops1", 	"close1" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 		"titan1", 	"close1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan1", 	"close1" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 		"titan1", 	"close1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan1", 	"close1" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 		"titan1", 	"close1" )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", "troops1", "centerRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", "titan1", "templeRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", "titan1", "clearcutRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "titan1"  )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops3", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3", "troops2", "clearcutRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3", "troops2", "templeRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan2", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan2", "troops2", "templeRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 		"titan2", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan2", "troops2", "clearcutRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 		"titan2", "troops2" )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4", "troops3", "centerRouteClose"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops4", "titan2", "templeRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops4", "titan2", "clearcutRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops4", "troops3"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops4", "titan2"  )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 					null, "troops4", "clearcutRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 		null, "troops4", "templeRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 					null, "troops4" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 		null, "troops4" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 					null, "troops4" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			null, "troops4" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 					null, "troops4" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 					null, "troops4" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 					null, "troops4" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 					null, "troops4", "clearcutRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 						null, "troops4", "templeRouteClose" )

	Wave_AddPause( wave, 5, "troops4" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 					null, "troops4" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 						null, "troops4" )

	Wave_AddPause( wave, 5, "troops4" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 						null, "troops4", "clearcutRouteClose" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 						null, "troops4", "templeRouteClose" )

	Wave_SetBreakTime( wave, 15 )

	return wave
}
Globalize( CommonWave_Swampland_Waves )

function CommonWave_Lagoon_Waves()
{
	//wave 1: Grunts and Cloak Drones
	local wave = TowerDefense_AddWave( "name_lagoon_rangers" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Infantry" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group2", "group1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group2", "group1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group2", "group1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group2", "group1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group2", "group1", "rightcloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group3", "group2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group3", "group2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group3", "group2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group3", "group2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group3", "group2", "centercloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group4", "group1" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group4", "group1" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group4", "group2" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group4", "group2" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group4", "group3" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group4", "group3" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group4", "group3" )

	Wave_SetBreakTime( wave, 10 )


	//wave 2: Spectres, Suicide Spectres, Cloak Drones, Mortar Titans
	local wave = TowerDefense_AddWave( "name_lagoon_zeroin" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_MortarTitans" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "troops1", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "troops1", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "troops2", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "troops2", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "troops2", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "troops3", "troops1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "troops3", "troops1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "troops3", "troops1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "troops4", "troops2", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "troops4", "troops2", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "troops4", "troops2", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "troops4", "troops2", "leftcloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan1", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan1", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan1", "troops2" )


	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "troops5", "troops3" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "troops5", "troops3" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "troops5", "troops3" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "troops5", "troops3" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "troops5", "troops3" )

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "troops6", "troops4" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "troops6", "troops4" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "troops6", "troops4" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "troops6", "troops4" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "troops6", "troops4" )

	Wave_SetBreakTime( wave, 10 )


	//wave 3: Grunts, Cloak Drones, Nuke Titans
	local wave = TowerDefense_AddWave( "name_lagoon_armorcompany" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_NukeTitans" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "troops1", null, "rightcloseRoute" )
	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "troops1", null, "rightcloseRoute" )
	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "troops1", null, "rightcloseRoute" )
	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "troops1", null, "rightcloseRoute" )
	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "troops1", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone )
	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "troops1", null, "leftcloseRoute" )
	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "troops1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone )
	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "troops1", null, "leftcloseRoute" )
	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "troops1", null, "leftcloseRoute" )
	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "troops1", null, "leftcloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "titan1" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "titan1" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "titan1" )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "troops2", "titan1", "centercloseRoute" )
	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "troops2", "titan1", "centercloseRoute" )
	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "troops2", "titan1", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone )
	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "troops2", "titan1", "centercloseRoute" )
	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "troops2", "titan1", "centercloseRoute" )
	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "troops2", "titan1", "centercloseRoute" )
	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "troops2", "titan1", "centercloseRoute" )
	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "troops2", "titan1", "centercloseRoute" )
	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "troops2", "titan1", "centercloseRoute" )
	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "troops2", "titan1", "centercloseRoute" )

	Wave_SetBreakTime( wave, 15 )


	//Wave 4: Spectres, Grunts, Mortar Titans
	local wave = TowerDefense_AddWave ( "name_mortarstrike" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Combo_MortarSuicide" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			"troops1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			"troops1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			"troops1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			"troops1" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 			"titan1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 			"titan2", null, "rightcloseRoute" )

	Wave_AddPause( wave, 2 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			"troops2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			"troops2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			"troops2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			"troops2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 			"titan3", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 			"titan4", "titan2" )

	Wave_AddPause( wave, 2 )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 			"troops3", "titan2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 			"troops3", "titan2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,			"troops3", "titan2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops3", "titan2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 			"troops3", "titan2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,			"troops3", "titan2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 			"troops3", "titan2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops3", "titan2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 			"troops3", "titan2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 			"troops3", "titan2", "centercloseRoute" )

	Wave_SetBreakTime( wave, 15 )


	//wave 5: Snipers, Grunts, Suicide Spectres, Mortar Titans, Nuke Titans
	local wave = TowerDefense_AddWave( "name_lagoon_mechanizedwarfare" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Combo_NukeMortar" )
	Wave_AddSpawn( wave, TD_SpawnSniper1x, 		"snipers1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSniper1x, 		"snipers1" )
	Wave_AddSpawn( wave, TD_SpawnSniper1x, 		"snipers1", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSniper1x, 		"snipers1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSniper1x, 		"snipers1" )
	Wave_AddSpawn( wave, TD_SpawnSniper1x, 		"snipers1", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "centercloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"titan1", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan1", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"titan1", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan1", "troops1" )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", "snipers1", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", "snipers1", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", "snipers1", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", "snipers1", "centercloseRoute" )
	Wave_AddPause( wave, 8 )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops2", "snipers1", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops2", "snipers1", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops2", "snipers1", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops2", "snipers1", "centercloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnSniper2x, 		"snipers2", "snipers1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSniper2x, 		"snipers2", "snipers1" )
	Wave_AddSpawn( wave, TD_SpawnSniper2x, 		"snipers2", "snipers1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSniper2x, 		"snipers2", "snipers1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSniper2x, 		"snipers2", "snipers1" )
	Wave_AddSpawn( wave, TD_SpawnSniper2x, 		"snipers2", "snipers1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops3", "troops1", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops3", "troops1", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops3", "troops1", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops3", "troops1", "centercloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan2", "troops3" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"titan2", "troops3" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan2", "troops3" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"titan2", "troops3" )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4", "snipers2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4", "snipers2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4", "snipers2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4", "snipers2", "centercloseRoute" )
	Wave_AddPause( wave, 8 )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops4", "snipers2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops4", "snipers2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops4", "snipers2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops4", "snipers2", "centercloseRoute" )

	Wave_SetBreakTime( wave, 15 )

	//wave 6:  == Suicide Spectres, Cloak Drones, Nuke Titans, Mortar Titans
	local wave = TowerDefense_AddWave( "name_lagoon_fissionassist" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Combo_NukeSuicide" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"titan1" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan2" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"titan3" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan4" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"group1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"group1", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"group1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"group2", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"group2", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"group2", null, "rightcloseRoute" )

	Wave_AddPause( wave, 1 )

	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"titan5", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan6", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"titan7", "titan3" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan8", "titan4" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"group3", "group1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"group3", "group1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"group3", "group1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"group4", "group2", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"group4", "group2", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"group4", "group2", "rightcloseRoute" )

	Wave_AddPause( wave, 1 )

	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"titan9", "titan5" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan9", "titan5" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"titan10", "titan6" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan10", "titan6" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"titan11", "titan7" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan11", "titan7" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"titan12", "titan8" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"titan12", "titan8" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"group5", "group3", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"group5", "group3", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"group5", "group3", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"group5", "group3", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"group5", "group3", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"group5", "group3", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"group6", "group4", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"group6", "group4", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"group6", "group4", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"group6", "group4", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"group6", "group4", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"group6", "group4", "rightcloseRoute" )

	return wave
}
Globalize( CommonWave_Lagoon_Waves )

function CommonWave_Overlook_Waves()
{

	//WARM UP
	local wave = TowerDefense_AddWave( "name_overlook_warm_up" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Infantry" )
	
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "landingpadCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "undergroundCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "hangarCloseRoute" )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "landingpadCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "undergroundCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "hangarCloseRoute" )

	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "group1", null, "landingpadCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "group1", null, "undergroundCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "group1", null, "hangarCloseRoute" )

	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "group2", "group1", "landingpadCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "group2", "group1", "hangarCloseRoute" )

	Wave_AddPause( wave, 10 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, "group2", "landingpadCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, "group2", "undergroundCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, "group2", "hangarCloseRoute" )

	Wave_AddPause( wave, 3 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, "group2", "undergroundCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, "group2", "undergroundCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group2", "undergroundCloseRoute" )

	Wave_SetBreakTime( wave, 15 )

	//TEST - Suicide intro
	local wave = TowerDefense_AddWave( "name_overlook_suicide" )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, null, "undergroundCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, null, "undergroundCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group1", null, "undergroundCloseRoute" )

	Wave_AddPause( wave, 7 )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, null, "landingpadCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, null, "landingpadCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group1", null, "landingpadCloseRoute"  )

	Wave_AddPause( wave, 7 )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, null, "hangarCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, null, "hangarCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group1", null, "hangarCloseRoute" )

	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group2", "group1", "landingpadCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group2", "group1", "hangarCloseRoute" )
	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group2", "group1", "landingpadCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group2", "group1", "hangarCloseRoute" )
	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnTitan, "group2", "group1", "landingpadCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnTitan, "group2", "group1", "hangarCloseRoute"  )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, "group2", "undergroundCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, "group2", "undergroundCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2" )

	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2" )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group2" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2" )


	Wave_AddPause( wave, 5 )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, "group2", "landingpadCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, "group2", "landingpadCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "landingpadCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "landingpadCloseRoute"  )

	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2" )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group2" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2" )

	Wave_AddPause( wave, 5 )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, "group2", "hangarCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, "group2", "hangarCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "hangarCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "hangarCloseRoute" )

	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2" )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group2" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2" )

	Wave_SetBreakTime( wave, 15 )


	//TEST - Nuke intro
	local wave = TowerDefense_AddWave( "name_overlook_nuke" )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "undergroundCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, null, "undergroundCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group1", null, "undergroundCloseRoute" )

	Wave_AddPause( wave, 7 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "landingpadCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, null, "landingpadCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnTitan, "group1", null, "landingpadCloseRoute"  )

	Wave_AddPause( wave, 7 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "hangarCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, null, "hangarCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, "group1", null, "hangarCloseRoute" )

	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "group2", "group1", "landingpadCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, "group2", "group1", "undergroundCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "group2", "group1", "landingpadCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, "group2", "group1", "undergroundCloseRoute" )

	Wave_AddPause( wave, 10 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, "group2", "landingpadCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "landingpadCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "landingpadCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group2", "landingpadCloseRoute" )

	Wave_AddPause( wave, 4 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, "group2", "hangarCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "hangarCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "hangarCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group2", "hangarCloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnNukeTitan, null, "group2" )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group2" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2" )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, null, "group2" )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group2" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2" )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, null, "group2" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2" )


	Wave_SetBreakTime( wave, 15 )


	//TEST - Lower Train
	local wave = TowerDefense_AddWave( "name_overlook_close" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Titans" )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "undergroundCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, null, "undergroundCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, null, "undergroundCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, "group1", null, "undergroundCloseRoute" )

	Wave_AddPause( wave, 7 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "landingpadCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, null, "landingpadCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, null, "landingpadCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group1", null, "landingpadCloseRoute"  )

	Wave_AddPause( wave, 7 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "hangarCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, null, "hangarCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, null, "hangarCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group1", null, "hangarCloseRoute" )

	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, "group1", "undergroundCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, "group1", "undergroundCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group1", "undergroundCloseRoute"  )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group1", "hangarCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group1", "hangarCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, "group1", "undergroundCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group1", "undergroundCloseRoute"  )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group1", "landingpadCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group1", "landingpadCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, "group1", "undergroundCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group1", "undergroundCloseRoute"  )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group1", "hangarCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, "group1", "undergroundCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group1", "undergroundCloseRoute"  )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, "group1", "landingpadCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, "group1", "undergroundCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, null, "group1", "undergroundCloseRoute"  )


	Wave_SetBreakTime( wave, 15 )


	//TEST - Final wave
	local wave = TowerDefense_AddWave( "name_overlook_final" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Combo_NukeSuicide" )
	
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "undergroundCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, null, "undergroundCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group1", null, "undergroundCloseRoute" )

	Wave_AddPause( wave, 7 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "landingpadCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, null, "landingpadCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group1", null, "landingpadCloseRoute"  )

	Wave_AddPause( wave, 7 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "hangarCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, null, null, "hangarCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group1", null, "hangarCloseRoute" )

	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "group2", "group1", "landingpadCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "group2", "group1", "undergroundCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group2", "group1", "landingpadCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group2", "group1", "undergroundCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, "group2", "group1", "landingpadCloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, "group2", "group1", "undergroundCloseRoute" )

	Wave_AddPause( wave, 10 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, "group2", "landingpadCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "landingpadCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "landingpadCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group2", "landingpadCloseRoute" )

	Wave_AddPause( wave, 4 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, "group2", "hangarCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "hangarCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "hangarCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, null, "group2", "hangarCloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnNukeTitan, null, "group2" )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, null, "group2" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2" )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, null, "group2" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, "group2", "hangarCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "hangarCloseRoute" )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, null, "group2" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2" )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, null, "group2" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquadWithSingleSuicide, null, "group2", "landingpadCloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2", "landingpadCloseRoute" )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, null, "group2" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "group2" )

	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, null, "group2" )

	return wave
}
Globalize( CommonWave_Overlook_Waves )

function CommonWave_RiseHC()
{
	//Wave: Spectres + Suicide Spectres + 4 snipers
	local wave = TowerDefense_AddWave( "name_rise_nutsandbolts" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,	"troops1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,		"troops1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,				"troops1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSniper1x,					"troops1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,				"troops1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,		"troops1", null, "leftcloseRoute" )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,	"troops2", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,		"troops2", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,				"troops2", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSniper1x,					"troops2", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,				"troops2", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,		"troops2", null, "rightcloseRoute" )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,	"troops3", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,		"troops3", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,				"troops3", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSniper1x,					"troops3", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,				"troops3", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,		"troops3", null, "centercloseRoute" )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,	"troops4", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,		"troops4", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,				"troops4", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSniper1x,					"troops4", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,				"troops4", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,		"troops4", null, "centercloseRoute" )

	Wave_SetBreakTime( wave, 10 )


	//Wave: Snipers + Titans
	local wave = TowerDefense_AddWave( "name_rise_corioliseffect" )
	Wave_AddSpawn( wave, TD_SpawnSniper2x, 	"troops1" )
	Wave_AddSpawn( wave, TD_SpawnSniper2x, 	"troops1" )
	Wave_AddSpawn( wave, TD_SpawnSniper2x, 	"troops1" )
	Wave_AddSpawn( wave, TD_SpawnTitan,		"titan1" )
	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnTitan,		"titan1" )
	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnTitan,		"titan1" )
	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnTitan,		"titan1" )

	Wave_AddPause( wave, 3 )

	Wave_AddSpawn( wave, TD_SpawnSniper2x,		"troops2", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSniper2x,		"troops2", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSniper2x,		"troops2", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan,			"titan2", "titan1" )
	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan,	"titan2", "titan1" )
	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan,	"titan2", "titan1" )
	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnTitan,			"titan2", "titan1" )

	Wave_AddPause( wave, 3 )

	Wave_AddSpawn( wave, TD_SpawnSniper2x,		"troops3", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSniper2x,		"troops3", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSniper2x,		"troops3", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan3", "titan2" )
	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"titan3", "titan2" )
	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan3", "titan2" )
	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan3", "titan2" )
	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"titan3", "titan2" )
	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan3", "titan2" )

	Wave_SetBreakTime( wave, 10 )


	//Wave: Titan Push
	local wave = TowerDefense_AddWave ( "name_rise_armorcompany" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"group1" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"group1" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"group1" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"group1" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"group1" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"group1" )

	Wave_AddPause( wave, 10 )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group2", "group1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group2", "group1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group2", "group1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group2", "group1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group2", "group1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group2", "group1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group2", "group1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"group2", "group1" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"group2", "group1" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"group2", "group1" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"group2", "group1" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"group2", "group1" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"group2", "group1" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"group2", "group1" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"group2", "group1" )

	Wave_AddPause( wave, 10 )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group3", "group2", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group3", "group2", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group3", "group2", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group3", "group2", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group3", "group2", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group3", "group2", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group3", "group2", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group3", "group2", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group3", "group2", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group3", "group2", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"group3", "group2" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"group3", "group2" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"group3", "group2" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"group3", "group2" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"group3", "group2" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"group3", "group2" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"group3", "group2" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"group3", "group2" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"group3", "group2" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"group3", "group2" )

	Wave_SetBreakTime( wave, 10 )


	//Wave: Nuke Titans
	local wave = TowerDefense_AddWave ( "name_rise_mad" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan1" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan1" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan2" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan2" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan3" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan3" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan4" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan4" )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group2", "group1", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group2", "group1", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group2", "group1", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group2", "group1", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group2", "group1", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group2", "group1", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group2", "group1", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan10", "Titan1" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan10", "Titan1" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan20", "Titan2" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan20", "Titan2" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan30", "Titan3" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan30", "Titan3" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan40", "Titan4" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan40", "Titan4" )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group3", "group2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group3", "group2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group3", "group2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group3", "group2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group3", "group2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group3", "group2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group3", "group2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group3", "group2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group3", "group2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group3", "group2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan100", "Titan10" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan100", "Titan10" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan200", "Titan20" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan200", "Titan20" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan300", "Titan30" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan300", "Titan30" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan300", "Titan30" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan400", "Titan40" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan400", "Titan40" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan400", "Titan40" )

	Wave_SetBreakTime( wave, 10 )

}
Globalize( CommonWave_RiseHC )

function CommonWave_Training_Ground_Waves()
{
	//wave 1:
	local wave = TowerDefense_AddWave( "name_training_ground_wave1" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Infantry" )
	Wave_AddSpawn( wave, TD_SpawnSniper2x )
	Wave_AddSpawn( wave, TD_SpawnSniper2x )
	Wave_AddSpawn( wave, TD_SpawnSniper2x )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops3", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops4", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops4", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops5", "troops1", "centercloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops5", "troops1", "centercloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops6", "troops2", "centercloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops6", "troops2", "centercloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops7", "troops3", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops7", "troops3", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops8", "troops4", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops8", "troops4", "rightcloseRoute" )

	Wave_SetBreakTime( wave, 10 )

	//wave 2:
	local wave = TowerDefense_AddWave( "name_training_ground_wave2" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Combo_MortarSuicide" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops2", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops2", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops3", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops3", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops4", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops4", null, "leftcloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan1" )

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops5", "troops1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops5", "troops1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops6", "troops2", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops6", "troops2", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops7", "troops3", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops7", "troops3", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops8", "troops4", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops8", "troops4", "rightcloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan2", "titan1" )

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops9", "troops5", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops9", "troops5", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops10", "troops6", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops10", "troops6", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops11", "troops7", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops11", "troops7", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops12", "troops8", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops12", "troops8", "centercloseRoute" )

	Wave_SetBreakTime( wave, 10 )

	//wave 3:
	local wave = TowerDefense_AddWave( "name_training_ground_wave3" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_ArcTitans" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "troops1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "troops1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "troops1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "troops1", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "troops1", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "troops1", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "troops1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "troops1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "troops1", null, "centercloseRoute" )
	Wave_AddPause( wave, 2 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			"troops2", "troops1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			"troops2", "troops1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops2", "troops1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			"troops2", "troops1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			"troops2", "troops1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops2", "troops1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			"troops2", "troops1", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			"troops2", "troops1", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops2", "troops1", "centercloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnEmpTitan, "titan2", null )
	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, "titan2", null )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			"troops3", "troops2", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			"troops3", "troops2", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops3", "troops2", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			"troops3", "troops2", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			"troops3", "troops2", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops3", "troops2", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			"troops3", "troops2", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			"troops3", "troops2", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops3", "troops2", "rightcloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnEmpTitan, "titan3", "titan2" )
	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, "titan3", "titan2" )
	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, "titan3", "titan2" )

	Wave_SetBreakTime( wave, 10 )

	//Wave 4:
	local wave = TowerDefense_AddWave ( "name_training_ground_wave4" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Combo_MortarSuicide" )
	Wave_AddSpawn( wave, TD_SpawnSniper2x )
	Wave_AddSpawn( wave, TD_SpawnSniper2x )
	Wave_AddSpawn( wave, TD_SpawnSniper2x )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "troops1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "troops1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "troops1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "troops1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "troops1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "troops1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "troops1", null, "centercloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnTitan, "titan1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, "titan1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, "titan1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, "titan1" )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "troops2", "troops1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "troops2", "troops1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "troops2", "troops1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "troops2", "troops1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "troops2", "troops1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "troops2", "troops1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "troops2", "troops1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "troops2", "troops1", "rightcloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan2", "titan1" )

	Wave_SetBreakTime( wave, 10 )

	//wave 5:
	local wave = TowerDefense_AddWave( "name_training_ground_wave5" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Combo_NukeMortar" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, null, "centercloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan1" )
	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan2" )
	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan3" )
	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan4" )

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group1", null, "leftcloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group2", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group2", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group2", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group2", null, "rightcloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group3", "group1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group3", "group1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group3", "group1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group3", "group1", "rightcloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group4", "group2", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group4", "group2", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group4", "group2", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group4", "group2", "leftcloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "titan5", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "titan6", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "titan7", "titan3" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "titan8", "titan4" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "titan9", "titan4" )

	Wave_SetBreakTime( wave, 10 )

	//wave 6: Grunts, Mortar Titans and Amped Titans
	local wave = TowerDefense_AddWave( "name_training_ground_wave6" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Combo_ArcNuke" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquadDroppod, "troops1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquadDroppod, "troops2", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquadDroppod, "troops3", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquadDroppod, "troops4", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquadDroppod, "troops5", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group1" )
	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group2" )
	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group2" )
	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group3" )
	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group3" )
	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group4" )
	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group4" )
	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group5" )
	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group5" )

	Wave_AddPause( wave, 1 )

	Wave_AddSpawn( wave, TD_SpawnEmpTitan, "group6", "group1" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, "group7", "group2" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, "group8", "group3" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, "group9", "group4" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, "group10", "group5" )

	Wave_AddPause( wave, 1 )

	Wave_AddSpawn( wave, TD_SpawnGruntSquadDroppod, "troops6", "troops1", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquadDroppod, "troops7", "troops2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquadDroppod, "troops8", "troops2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquadDroppod, "troops9", "troops3", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquadDroppod, "troops10", "troops3", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquadDroppod, "troops11", "troops4", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquadDroppod, "troops12", "troops4", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquadDroppod, "troops13", "troops5", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquadDroppod, "troops14", "troops5", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group11", "group6" )
	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group12", "group7" )
	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group12", "group7" )
	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group13", "group8" )
	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group13", "group8" )
	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group14", "group9" )
	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group14", "group9" )
	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group15", "group10" )
	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group15", "group10" )

	Wave_AddPause( wave, 1 )

	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group16", "group11" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group17", "group12" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group18", "group13" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group19", "group14" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group20", "group14" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group21", "group15" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group22", "group15" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group23", "group15" )

	Wave_SetBreakTime( wave, 10 )

	return wave
}
Globalize( CommonWave_Training_Ground_Waves )

function CommonWave_Nexus_Waves()
{
	//wave 1:
	local wave = TowerDefense_AddWave( "name_nexus_wave1" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Infantry_NoTitans" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops3" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops4" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops4" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops5", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops5", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops6", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops6", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops7", "troops3", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops7", "troops3", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops8", "troops4", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops8", "troops4", "rightcloseRoute" )

	Wave_SetBreakTime( wave, 10 )

	//wave 2:
	local wave = TowerDefense_AddWave( "name_nexus_wave2" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_SuicideSpectre" )
	Wave_AddSpawn( wave, TD_SpawnSniper1x, 	"troops1" )
	Wave_AddSpawn( wave, TD_SpawnSniper1x, 	"troops1" )
	Wave_AddSpawn( wave, TD_SpawnSniper1x, 	"troops2" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops2" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops3" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops3" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops4" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops4" )

	Wave_AddSpawn( wave, TD_SpawnEmpTitan, "titan1" )

	Wave_AddSpawn( wave, TD_SpawnSniper1x, 	"troops5", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnSniper1x, 	"troops5", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnSniper1x, 	"troops6", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops6", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops7", "troops3" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops7", "troops3" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops8", "troops4" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops8", "troops4" )

	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan2", "titan1" )

	Wave_AddSpawn( wave, TD_SpawnSniper2x, 	"troops9", "troops5" )
	Wave_AddSpawn( wave, TD_SpawnSniper2x, 	"troops9", "troops5" )
	Wave_AddSpawn( wave, TD_SpawnSniper2x, 	"troops10", "troops6" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops10", "troops6" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops11", "troops7" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops11", "troops7" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops12", "troops8" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops12", "troops8" )

	Wave_SetBreakTime( wave, 10 )

	//wave 3:
	local wave = TowerDefense_AddWave( "name_nexus_wave3" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_NukeTitans" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "troops1" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "troops1" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "troops2" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "troops2" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "troops3" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "troops3" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "troops4" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "troops4" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "titan1" )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			"troops5", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops5", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			"troops6", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			"troops6", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops7", "troops3" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			"troops7", "troops3" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			"troops8", "troops4" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops8", "troops4" )

	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "titan2", "titan1" )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			"troops9", "troops5", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			"troops9", "troops5", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops10", "troops6", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			"troops10", "troops6", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			"troops11", "troops7", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops11", "troops7", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			"troops12", "troops8", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 			"troops12", "troops8", "rightcloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "titan3", "titan2" )

	Wave_SetBreakTime( wave, 10 )


	//wave 4:
	local wave = TowerDefense_AddWave( "name_nexus_wave4" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Combo_ArcMortar" )
	Wave_AddSpawn( wave, TD_SpawnSniper2x )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad )
	Wave_AddSpawn( wave, TD_SpawnSniper2x )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad )

	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan1" )
	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan1" )
	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan2" )
	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan2" )
	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan3", "titan1" )
	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan3", "titan1" )
	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan4", "titan2" )
	Wave_AddPause( wave, 1 )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan4", "titan2" )

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group1", null, "leftcloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group2", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group2", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group2", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group2", null, "rightcloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group3", "group1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group3", "group1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group3", "group1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group3", "group1", "rightcloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group4", "group2", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group4", "group2", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group4", "group2", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "group4", "group2", "leftcloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnEmpTitan, "titan5", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, "titan6", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, "titan7", "titan3" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, "titan8", "titan4" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, "titan9", "titan4" )

	Wave_SetBreakTime( wave, 10 )

	//wave 5: Grunts, Nuke Titans and EMP Titans
	local wave = TowerDefense_AddWave( "name_nexus_wave5" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Combo_NukeMortar" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquadDroppod, "troops1" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquadDroppod, "troops2" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquadDroppod, "troops3" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquadDroppod, "troops4" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquadDroppod, "troops5" )

	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group1", null, "southRoute" )
	Wave_AddPause( wave, 2.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group1", null, "southRoute" )
	Wave_AddPause( wave, 2.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group2", null, "southRoute" )
	Wave_AddPause( wave, 2.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group2", null, "southRoute" )
	Wave_AddPause( wave, 2.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group3", null, "southRoute" )
	Wave_AddPause( wave, 2.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group3", null, "southRoute" )
	Wave_AddPause( wave, 2.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group4", null, "southRoute" )
	Wave_AddPause( wave, 2.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group4", null, "southRoute" )
	Wave_AddPause( wave, 2.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group5", null, "southRoute" )
	Wave_AddPause( wave, 2.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group5", null, "southRoute" )

	Wave_AddPause( wave, 1 )

	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "group6", "group1" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "group7", "group2" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "group8", "group3" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "group9", "group4" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "group10", "group5" )

	Wave_AddPause( wave, 1 )

	Wave_AddSpawn( wave, TD_SpawnGruntSquadDroppod, "troops6", "troops1" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquadDroppod, "troops7", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquadDroppod, "troops8", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquadDroppod, "troops9", "troops3" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquadDroppod, "troops10", "troops3" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquadDroppod, "troops11", "troops4" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquadDroppod, "troops12", "troops4" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquadDroppod, "troops13", "troops5" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquadDroppod, "troops14", "troops5" )

	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group11", "group6", "northRoute" )
	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group11", "group6", "northRoute" )
	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group12", "group7", "northRoute" )
	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group12", "group7", "northRoute" )
	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group13", "group8", "northRoute" )
	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group13", "group8", "northRoute" )
	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group14", "group9", "northRoute" )
	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group14", "group9", "northRoute" )
	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group15", "group10", "northRoute" )
	Wave_AddPause( wave, 2 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "group15", "group10", "northRoute" )


	Wave_SetBreakTime( wave, 10 )

	return wave
}
Globalize( CommonWave_Nexus_Waves )

function CommonWave_Relic()
{
	//Wave:
	local wave = TowerDefense_AddWave( "name_relic_wave1" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Titans" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "troops1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "troops1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "troops1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "troops1", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "troops2", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "troops2", null, "rightcloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnTitan, "troops2", "troops1" )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "troops3", "troops2", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "troops3", "troops2", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "troops3", "troops2", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "troops4", "troops3", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "troops5", "troops3", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "troops5", "troops3", "rightcloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnTitan, "titan2", "troops4" )
	Wave_AddSpawn( wave, TD_SpawnTitan, "titan3", "troops4" )

	Wave_SetBreakTime( wave, 10 )


	//Wave:
	local wave = TowerDefense_AddWave( "name_relic_wave2" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Combo_MortarSuicide" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan1" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan2" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan3" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan4" )

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "titan1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "titan1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "titan1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "titan2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "titan2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "titan2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "titan3", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "titan3", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "titan3", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "titan4", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "titan4", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "titan4", "centercloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan5", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan6", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan7", "titan3" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan8", "titan4" )

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "titan5", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "titan5", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "titan5", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "titan6", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "titan6", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "titan6", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "titan7", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "titan7", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "titan7", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "titan8", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "titan8", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, null, "titan8", "centercloseRoute" )

	Wave_SetBreakTime( wave, 10 )


	//Wave:
	local wave = TowerDefense_AddWave ( "name_relic_wave3" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_NukeTitans" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan1" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan1" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan2" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan2" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan3" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan3" )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group2", "group1", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group2", "group1", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group2", "group1", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group2", "group1", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group2", "group1", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group2", "group1", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group2", "group1", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan10", "Titan1" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan10", "Titan1" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan20", "Titan2" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan20", "Titan2" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan30", "Titan3" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan30", "Titan3" )

	Wave_AddPause( wave, 5 )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group3", "group2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group3", "group2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group3", "group2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group3", "group2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group3", "group2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group3", "group2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group3", "group2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group3", "group2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group3", "group2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"group3", "group2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan100", "Titan10" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan100", "Titan10" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan200", "Titan20" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan200", "Titan20" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan300", "Titan30" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan300", "Titan30" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"Titan300", "Titan30" )

	Wave_SetBreakTime( wave, 10 )


	//Wave:
	local wave = TowerDefense_AddWave ( "name_relic_wave4" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_KitchenSink" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops2", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops2", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops3", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops3", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops4", "troops1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops4", "troops1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops5", "troops2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops5", "troops2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops6", "troops3", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops6", "troops3", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops7", "troops4", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops7", "troops4", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops8", "troops5", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops8", "troops5", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops9", "troops6", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops9", "troops6", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan,		"emptitan1" )
	Wave_AddSpawn( wave, TD_SpawnTitan,		"emptitan1" )
	Wave_AddSpawn( wave, TD_SpawnTitan,		"emptitan2", "emptitan1" )
	Wave_AddSpawn( wave, TD_SpawnTitan,		"emptitan2", "emptitan1" )
	Wave_AddSpawn( wave, TD_SpawnTitan,		"emptitan3", "emptitan2" )
	Wave_AddSpawn( wave, TD_SpawnTitan,		"emptitan3", "emptitan2" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan,	"titan1" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan,	"titan1" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan,	"titan1" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan,	"titan5", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan,	"titan6", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan,	"titan7", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan,		"titan8", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan,		"titan9", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan,		"titan10", "titan1" )


}
Globalize( CommonWave_Relic )

function CommonWave_Endless_Waves()
{
	//wave 0:
	local wave = TowerDefense_AddWave( "name_endless_zero" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Infantry_NoTitans" )
	Wave_SetWaveCompleteVO( wave, "CoopTD_WaveCompleteComment_Rise_TinyWave" )
	Wave_AddSpawn( wave, TD_SpawnSniper2x,	null, null, "centercloseRoute" )
	Wave_SetBreakTime( wave, 10 )

	//wave 1:
	local wave = TowerDefense_AddWave( "name_endless_one" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Rise_HugeWave" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"alphasquad1", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"alphasquad1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"alphasquad1", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"alphasquad2", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"alphasquad2", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"alphasquad2", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"alphasquad3", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"alphasquad3", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"alphasquad3", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"alphasquad4", "alphasquad1", "centercloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"alphasquad5", "alphasquad2", "centercloseRoute"  )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"alphasquad6", "alphasquad3", "centercloseRoute"  )

	Wave_AddPause( wave, 5 )

////////////////////////

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,	"bravosquad1", "alphasquad6", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,	"bravosquad2", "alphasquad6", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,	"bravosquad3", "alphasquad6", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,	"bravosquad4", "alphasquad6", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,	"bravosquad5", "alphasquad6", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,	"bravosquad6", "bravosquad1", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,	"bravosquad7", "bravosquad2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,	"bravosquad8", "bravosquad3", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,	"bravosquad9", "bravosquad4", "centercloseRoute" )

	Wave_AddPause( wave, 5 )

////////////////////////

	Wave_AddSpawn( wave, TD_SpawnTitan, 					"charlietitan1", "bravosquad9" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 					"charlietitan1", "bravosquad9" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,				"charliesquad1", "bravosquad9" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,				"charliesquad1", "bravosquad9" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,				"charliesquad1", "bravosquad9" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,				"charliesquad1", "bravosquad9" )

	Wave_AddSpawn( wave, TD_SpawnTitan, 					"charlietitan2", "charlietitan1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 					"charlietitan2", "charlietitan1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,				"charliesquad2", "charliesquad1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,				"charliesquad2", "charliesquad1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,				"charliesquad2", "charliesquad1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,				"charliesquad2", "charliesquad1", "rightcloseRoute" )

	Wave_AddPause( wave, 5 )

////////////////////////

	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 				"deltatitan1", "charlietitan2" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 				"deltatitan1", "charlietitan2" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 				"deltatitan2", "charlietitan2" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 				"deltatitan2", "charlietitan2" )

	Wave_AddSpawn( wave, TD_SpawnTitan, 					"deltatitan3", "deltatitan1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 					"deltatitan3", "deltatitan1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 					"deltatitan3", "deltatitan2" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 					"deltatitan3", "deltatitan2" )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad,				"deltasquad1", "charliesquad2" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,				"deltasquad1", "charliesquad2" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,				"deltasquad1", "charliesquad2" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,				"deltasquad1", "charliesquad2" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,				"deltasquad1", "charliesquad2" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,				"deltasquad1", "charliesquad2" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,				"deltasquad1", "charliesquad2" )

	Wave_AddPause( wave, 5 )

////////////////////////

	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 					"echotitan1", "deltatitan3" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 				"echotitan1", "deltatitan3" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 					"echotitan1", "deltatitan3" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 				"echotitan1", "deltatitan3" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 					"echotitan1", "deltatitan3" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 				"echotitan1", "deltatitan3" )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,				"echosquad1", "deltasquad1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,				"echosquad1", "deltasquad1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,				"echosquad1", "deltasquad1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,				"echosquad1", "deltasquad1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,				"echosquad1", "deltasquad1" )

	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 					"echotitan2", "echotitan1" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 				"echotitan2", "echotitan1" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 					"echotitan2", "echotitan1" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 				"echotitan2", "echotitan1" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 					"echotitan2", "echotitan1" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 				"echotitan2", "echotitan1" )

	Wave_AddPause( wave, 5 )

////////////////////////

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,		"foxsquad1", "echosquad1", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,		"foxsquad1", "echosquad1", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,		"foxsquad1", "echosquad1", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,		"foxsquad1", "echosquad1", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad,		"foxsquad1", "echosquad1", "centercloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 				"foxtitan1", "echotitan2" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 				"foxtitan1", "echotitan2" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 				"foxtitan1", "echotitan2" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 				"foxtitan1", "echotitan2" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 				"foxtitan1", "echotitan2" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 				"foxtitan1", "echotitan2" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 				"foxtitan1", "echotitan2" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 				"foxtitan1", "echotitan2" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 				"foxtitan1", "echotitan2" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 				"foxtitan1", "echotitan2" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 				"foxtitan1", "echotitan2" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 				"foxtitan1", "echotitan2" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 				"foxtitan1", "echotitan2" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 				"foxtitan1", "echotitan2" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 				"foxtitan1", "echotitan2" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 				"foxtitan1", "echotitan2" )

	Wave_SetBreakTime( wave, 5 )


	return wave
}
Globalize( CommonWave_Endless_Waves )

function CommonWave_Airbase_Waves()
{
	//wave 1:
	local wave = TowerDefense_AddWave( "name_airbase_wave1" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Infantry_NoTitans" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,	"troops1", null, "oneRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops1", null, "oneRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops1", null, "oneRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops1", null, "oneRoute" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", null, "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", null, "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", null, "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", null, "fourRoute" )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	null, "troops1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	null, "troops1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	null, "troops1", "leftcloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	null, "troops2", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	null, "troops2", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	null, "troops2", "rightcloseRoute" )

	Wave_SetBreakTime( wave, 10 )


	//wave 2:
	local wave = TowerDefense_AddWave( "name_airbase_wave2" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_ArcTitans" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 			"titan1", null, "twoRoute")
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 			"titan1", null, "fourRoute")
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 			"titan2", "titan1", "twoRoute")
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 			"titan2", "titan1", "fourRoute")

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", null, "twoRoute")
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", null, "twoRoute")
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", null, "twoRoute")
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", null, "fourRoute")
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", null, "fourRoute")
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", null, "fourRoute")

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide2", "suicide1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide2", "suicide1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide2", "suicide1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide2", "suicide1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide2", "suicide1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide2", "suicide1", "rightcloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide3", "suicide2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide3", "suicide2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide3", "suicide2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide3", "suicide2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide3", "suicide2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide3", "suicide2", "centercloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide4", "suicide3", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide4", "suicide3", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide4", "suicide3", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide4", "suicide3", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide4", "suicide3", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide4", "suicide3", "leftcloseRoute" )

	Wave_SetBreakTime( wave, 10 )


	//wave 3:
	local wave = TowerDefense_AddWave( "name_airbase_wave3" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_NukeTitans" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "oneRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "oneRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "oneRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "oneRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "oneRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops1", null, "oneRoute" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone, 	"troops1", null, "oneRoute" )

	Wave_AddPause( wave, 1.5 )

	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops1", null, "oneRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops1", null, "oneRoute" )

	Wave_AddSpawn( wave, TD_SpawnCloakedDrone, 	"troops2", "troops1", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,	"troops2", "troops1", "fourRoute" )

	Wave_AddPause( wave, 1.5 )

	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops2", "troops1", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops2", "troops1", "fourRoute" )

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", "troops2", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", "troops2", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", "troops2", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", "troops2", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", "troops2", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", "troops2", "rightcloseRoute" )

	Wave_AddPause( wave, 0.5 )

	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops3", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops3", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops3", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops3", "troops2" )

	Wave_SetBreakTime( wave, 10 )


	//wave 4:
	local wave = TowerDefense_AddWave( "name_airbase_wave4" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Combo_ArcMortar" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 		"titan1", null, "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan1", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan1", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan1", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan1" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 		"titan1", null, "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan1", null, "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan1", null, "twoRoute" )

	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 		"titan2", "titan1", "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan2", "titan1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan2", "titan1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan2", "titan1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan2", "titan1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan2", "titan1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan2", "titan1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan2", "titan1", "twoRoute" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 		"titan2", "titan1", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan2", "titan1", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan2", "titan1", "fourRoute" )

	Wave_SetBreakTime( wave, 15 )


	//wave 5: 12 Grunts, 28 Spectres, 52 Suicide Spectres, 6 Titans, 4 Nuke Titan == Introduce Nuke Titan (102 Units)
	local wave = TowerDefense_AddWave( "name_airbase_wave5" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_NukeTrain" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops1", null, "centercloseRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 		"troops1", null, "oneRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops1", null, "oneRoute" )

	Wave_AddPause( wave, 8 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", null, "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", null, "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", null, "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", null, "fourRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 		"troops2", null, "fourRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops2", null, "fourRoute" )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3", "troops1", "oneRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3", "troops1", "oneRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3", "troops1", "oneRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3", "troops1", "oneRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 		"troops3", "troops1", "oneRoute" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"troops3", "troops1", "oneRoute" )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3", "troops2", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3", "troops2", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3", "troops2", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3", "troops2", "fourRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 		"troops3", "troops2", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"troops3", "troops2", "fourRoute" )

	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops4", "troops3", "oneRoute" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4", "troops3", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops4", "troops3", "fourRoute" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4", "troops3", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops4", "troops3", "oneRoute" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4", "troops3", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops4", "troops3", "fourRoute" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4", "troops3", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops4", "troops3", "oneRoute" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4", "troops3", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops4", "troops3", "fourRoute" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4", "troops3", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops4", "troops3", "oneRoute" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4", "troops3", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops4", "troops3", "fourRoute" )

	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops5", "troops4", "fourRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops5", "troops4", "oneRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops5", "troops4", "fourRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops5", "troops4", "oneRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops5", "troops4", "fourRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops5", "troops4", "oneRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops5", "troops4", "fourRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops5", "troops4", "oneRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops5", "troops4", "fourRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops5", "troops4", "oneRoute" )

	Wave_SetBreakTime( wave, 10 )


	return wave
}
Globalize( CommonWave_Airbase_Waves )

function CommonWave_Corporate_Waves()
{
	//wave 1:
	local wave = TowerDefense_AddWave( "name_corporate_wave1" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Infantry_NoTitans" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops2", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops2", null, "centercloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops3", "troops1", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops3", "troops1", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4", "troops2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4", "troops2", "centercloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	null, "troops3", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	null, "troops3", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	null, "troops3", "centercloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	null, "troops4", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	null, "troops4", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	null, "troops4", "centercloseRoute" )

	Wave_SetBreakTime( wave, 10 )


	//wave 2:
	local wave = TowerDefense_AddWave( "name_corporate_wave2" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_SuicideSpectre" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1" )

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide2", "suicide1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide2", "suicide1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide2", "suicide1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide2", "suicide1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide2", "suicide1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide2", "suicide1", "rightcloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide3", "suicide2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide3", "suicide2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide3", "suicide2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide3", "suicide2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide3", "suicide2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide3", "suicide2", "centercloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide4", "suicide3", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide4", "suicide3", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide4", "suicide3", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide4", "suicide3", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide4", "suicide3", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide4", "suicide3", "leftcloseRoute" )

	Wave_SetBreakTime( wave, 10 )


	//wave 3:
	local wave = TowerDefense_AddWave( "name_corporate_wave3" )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "oneRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "oneRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops1", null, "oneRoute" )

	Wave_AddPause( wave, 1.5 )

//	Wave_AddSpawn( wave, TD_SpawnTitan, 		"troops1", null, "oneRoute" )
//	Wave_AddSpawn( wave, TD_SpawnTitan, 		"troops1", null, "twoRoute" )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1", "oneRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1", "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1", "oneRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1", "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1", "oneRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,	"troops2", "troops1", "twoRoute" )

	Wave_AddPause( wave, 1.5 )

	Wave_AddSpawn( wave, TD_SpawnTitan, 		"troops2", "troops1", "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"troops2", "troops1", "oneRoute" )

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", "troops2", "speconeRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", "troops2", "speconeRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", "troops2", "speconeRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", "troops2", "spectwoRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", "troops2", "spectwoRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", "troops2", "spectwoRoute" )

	Wave_AddPause( wave, 1.5 )

	Wave_AddSpawn( wave, TD_SpawnTitan, 		"troops3", "troops2", "threeRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"troops3", "troops2", "fourRoute" )

	Wave_SetBreakTime( wave, 10 )


	//wave 4:
	local wave = TowerDefense_AddWave( "name_corporate_wave4" )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"titan1", null, "speconeRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"titan1", null, "speconeRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"titan1", null, "speconeRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"titan1", null, "spectwoRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"titan1", null, "spectwoRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"titan1", null, "spectwoRoute" )
	Wave_AddPause( wave, 10 )
//	Wave_AddSpawn( wave, TD_SpawnAmpedTitan, 	"titan1", null, "oneRoute" )
//	Wave_AddSpawn( wave, TD_SpawnAmpedTitan, 	"titan1", null, "oneRoute" )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"titan2", "titan1", "speconeRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"titan2", "titan1", "speconeRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"titan2", "titan1", "speconeRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"titan2", "titan1", "spectwoRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"titan2", "titan1", "spectwoRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"titan2", "titan1", "spectwoRoute" )
	Wave_AddPause( wave, 15 )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan2", "titan1", "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan2", "titan1", "twoRoute" )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan3", "titan2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan3", "titan2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan3", "titan2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan3", "titan2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan3", "titan2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan3", "titan2", "centercloseRoute" )
	Wave_AddPause( wave, 15 )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan3", "titan2", "centercloseRoute" )
	Wave_AddPause( wave, 6 )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan3", "titan2", "centercloseRoute" )

	Wave_SetBreakTime( wave, 15 )


	//wave 5: 12 Grunts, 28 Spectres, 52 Suicide Spectres, 6 Titans, 4 Nuke Titan == Introduce Nuke Titan (102 Units)
	local wave = TowerDefense_AddWave( "name_corporate_wave5" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Titans" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan1", null, "centercloseRoute" )
	Wave_AddPause( wave, 5 )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan1", null, "threeRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan1", null, "fourRoute" )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan2", "titan1", "speconeRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan2", "titan1", "speconeRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan2", "titan1", "speconeRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan2", "titan1", "spectwoRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan2", "titan1", "spectwoRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan2", "titan1", "spectwoRoute" )
	Wave_AddPause( wave, 5 )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan2", "titan1", "threeRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 		"titan2", "titan1", "fourRoute" )

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"titan3", "titan2", "speconeRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"titan3", "titan2", "speconeRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"titan3", "titan2", "speconeRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"titan3", "titan2", "spectwoRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"titan3", "titan2", "spectwoRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"titan3", "titan2", "spectwoRoute" )
	Wave_AddPause( wave, 5 )
	Wave_AddSpawn( wave, TD_SpawnTitan, 				"titan3", "titan2", "threeRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 				"titan3", "titan2", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 			"titan3", "titan2", "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 			"titan3", "titan2", "oneRoute" )

	Wave_SetBreakTime( wave, 10 )


	return wave
}
Globalize( CommonWave_Corporate_Waves )

function CommonWave_Harmony_Mines_Waves()
{
	//wave 1:
	local wave = TowerDefense_AddWave( "name_colony_wepierce" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Infantry_NoTitans" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,	"troops1", null, "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops1", null, "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops1", null, "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops1", null, "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", null, "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", null, "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", null, "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", null, "fourRoute" )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	null, "troops1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	null, "troops1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	null, "troops1", "leftcloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	null, "troops2", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	null, "troops2", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	null, "troops2", "rightcloseRoute" )

	Wave_SetBreakTime( wave, 10 )


	//wave 2:
	local wave = TowerDefense_AddWave( "name_colony_seekstrikedestroy" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_SuicideSpectre" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, "titan1", null, "twoRoute")
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, "titan1", null, "fourRoute")
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, "titan2", "titan1", "twoRoute")
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, "titan2", "titan1", "fourRoute")

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", null, "twoRoute")
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", null, "twoRoute")
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", null, "twoRoute")
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", null, "fourRoute")
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", null, "fourRoute")
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", null, "fourRoute")

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide2", "suicide1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide2", "suicide1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide2", "suicide1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide2", "suicide1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide2", "suicide1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide2", "suicide1", "rightcloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide3", "suicide2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide3", "suicide2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide3", "suicide2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide3", "suicide2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide3", "suicide2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide3", "suicide2", "centercloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide4", "suicide3", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide4", "suicide3", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide4", "suicide3", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide4", "suicide3", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide4", "suicide3", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide4", "suicide3", "leftcloseRoute" )

	Wave_SetBreakTime( wave, 10 )


	//wave 3:
	local wave = TowerDefense_AddWave( "name_colony_battlebots" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Combo_NukeSuicide" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops1", null, "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone, 	"troops1", null, "twoRoute" )

	Wave_AddPause( wave, 1.5 )

	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops1", null, "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops1", null, "twoRoute" )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone, 	"troops2", "troops1", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,	"troops2", "troops1", "fourRoute" )

	Wave_AddPause( wave, 1.5 )

	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops2", "troops1", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops2", "troops1", "fourRoute" )

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", "troops2", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", "troops2", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", "troops2", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", "troops2", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", "troops2", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", "troops2", "rightcloseRoute" )

	Wave_AddPause( wave, 0.5 )

	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops3", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops3", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops3", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops3", "troops2" )

	Wave_SetBreakTime( wave, 10 )


	//wave 4:
	local wave = TowerDefense_AddWave( "name_colony_warmachines" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_ArcTitans" )
	Wave_AddSpawn( wave, TD_SpawnAmpedTitan, 	"titan1", null, "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan1", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan1", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan1", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan1" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 		"titan1", null, "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnAmpedTitan, 	"titan1", null, "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 		"titan1", null, "twoRoute" )

	Wave_AddSpawn( wave, TD_SpawnAmpedTitan, 	"titan2", "titan1", "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan2", "titan1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan2", "titan1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan2", "titan1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan2", "titan1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan2", "titan1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan2", "titan1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan2", "titan1", "twoRoute" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 		"titan2", "titan1", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnAmpedTitan, 	"titan2", "titan1", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 		"titan2", "titan1", "fourRoute" )

	Wave_SetBreakTime( wave, 15 )


	//wave 5: 12 Grunts, 28 Spectres, 52 Suicide Spectres, 6 Titans, 4 Nuke Titan == Introduce Nuke Titan (102 Units)
	local wave = TowerDefense_AddWave( "name_colony_armorcompany" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_NukeTrain" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops1", null, "centercloseRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 		"troops1", null, "twoRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops1", null, "twoRoute" )

	Wave_AddPause( wave, 8 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", null, "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", null, "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", null, "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", null, "fourRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 		"troops2", null, "fourRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops2", null, "fourRoute" )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3", "troops1", "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3", "troops1", "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3", "troops1", "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3", "troops1", "twoRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnAmpedTitan, 	"troops3", "troops1", "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnAmpedTitan, 	"troops3", "troops1", "twoRoute" )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3", "troops2", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3", "troops2", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3", "troops2", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3", "troops2", "fourRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnAmpedTitan, 	"troops3", "troops2", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnAmpedTitan, 	"troops3", "troops2", "fourRoute" )

	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops4", "troops3", "twoRoute" )
	Wave_AddPause( wave, 3 )
//	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4", "troops3", "centercloseRoute" )
//	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops4", "troops3", "fourRoute" )
//	Wave_AddPause( wave, 3 )
//	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4", "troops3", "centercloseRoute" )
//	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops4", "troops3", "twoRoute" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4", "troops3", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops4", "troops3", "fourRoute" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4", "troops3", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops4", "troops3", "twoRoute" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4", "troops3", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops4", "troops3", "fourRoute" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4", "troops3", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops4", "troops3", "twoRoute" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4", "troops3", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops4", "troops3", "fourRoute" )

//	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops5", "troops4", "fourRoute" )
//	Wave_AddPause( wave, 1.5 )
//	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops5", "troops4", "twoRoute" )
//	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops5", "troops4", "fourRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops5", "troops4", "twoRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops5", "troops4", "fourRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops5", "troops4", "twoRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops5", "troops4", "fourRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops5", "troops4", "twoRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops5", "troops4", "fourRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops5", "troops4", "twoRoute" )

	Wave_SetBreakTime( wave, 10 )


	return wave
}
Globalize( CommonWave_Harmony_Mines_Waves )

function CommonWave_Boneyard_Waves()
{
	//wave 1: Grunts and Spectres with Cloak Drones, 1 Titan
	local wave = TowerDefense_AddWave("name_boneyard_wave1")
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_CloakDrone" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "cloaksquad1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "cloaksquad1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "cloaksquad1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "cloaksquad1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone, "cloaksquad1", null, "leftcloseRoute" )
	//Wave_AddSpawn( wave, TD_SpawnGruntSquad, "cloaksquad1" )

	Wave_AddPause( wave, 1 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "cloaksquad2", "cloaksquad1", "middlecloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone, "cloaksquad2", "cloaksquad1", "middlecloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "cloaksquad2", "cloaksquad1", "middlecloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "cloaksquad2", "cloaksquad1", "middlecloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone, "cloaksquad2", "cloaksquad1", "middlecloseRoute" )
	//Wave_AddSpawn( wave, TD_SpawnGruntSquad, "cloaksquad2", "cloaksquad1" )

	Wave_AddPause( wave, 1 )

	Wave_AddSpawn( wave, TD_SpawnCloakedDrone, "cloaksquad3", "cloaksquad2" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone, "cloaksquad3", "cloaksquad2" )
	Wave_AddSpawn( wave, TD_SpawnTitan, "cloaksquad3", "cloaksquad2" )
	//Wave_AddSpawn( wave, TD_SpawnGruntSquad, "cloaksquad3", "cloaksquad2" )


	Wave_SetBreakTime( wave, 10 )


	//wave 2: Grunts, Spectres and Suicide Spectres with Cloak Drones, more Titans
	local wave = TowerDefense_AddWave("name_boneyard_wave2")
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_SuicideSpectre" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "cloaksquad1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "cloaksquad1", null, "middlecloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, "cloaksquad1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, "cloaksquad1" )
Wave_AddSpawn( wave, TD_SpawnCloakedDrone, "cloaksquad1" )
	//Wave_AddSpawn( wave, TD_SpawnGruntSquad, "cloaksquad1" )

	Wave_AddPause( wave, 1 )

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "cloaksquad2", "cloaksquad1" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "cloaksquad2", "cloaksquad1" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone, "cloaksquad2", "cloaksquad1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, "cloaksquad2", "cloaksquad1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, "cloaksquad2", "cloaksquad1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, "cloaksquad2", "cloaksquad1" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone, "cloaksquad2", "cloaksquad1" )

	Wave_AddPause( wave, 1 )

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "cloaksquad3", "cloaksquad2" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "cloaksquad3", "cloaksquad2" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone, "cloaksquad3", "cloaksquad2" )
	Wave_AddSpawn( wave, TD_SpawnTitan, "cloaksquad3", "cloaksquad2" )
	Wave_AddSpawn( wave, TD_SpawnTitan, "cloaksquad3", "cloaksquad2" )
	Wave_AddSpawn( wave, TD_SpawnTitan, "cloaksquad3", "cloaksquad2" )
	Wave_AddSpawn( wave, TD_SpawnTitan, "cloaksquad3", "cloaksquad2" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone, "cloaksquad3", "cloaksquad2" )

	Wave_SetBreakTime( wave, 15 )


	//wave 3: Mortar Titan Intro
	local wave = TowerDefense_AddWave( "name_boneyard_wave3" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_MortarTitans" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, null, null, "middlecloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnTitan, "titan1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, "titan1" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan1" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad )
	//Wave_AddSpawn( wave, TD_SpawnSniper3x )
	Wave_AddSpawn( wave, TD_SpawnTitan, "titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "titan3", "titan2", "middlecloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "titan3", "titan2", "leftcloseRoute" )
	//Wave_AddSpawn( wave, TD_SpawnSniper4x )
	Wave_AddSpawn( wave, TD_SpawnTitan, "titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnTitan, "titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnTitan, "titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad )



	//wave 4: Nuke Titan Intro
	local wave = TowerDefense_AddWave( "name_boneyard_wave4" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_NukeTitans" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "titan1" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "titan1" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "titan1" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone, "titan1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "titan1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, "titan1" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "titan1" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "titan1" )

	Wave_AddPause( wave, 10 )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone, "titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone, "titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "titan2", "titan1" )

	Wave_AddPause( wave, 10 )

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone, "titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone, "titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "titan3", "titan2" )

	Wave_SetBreakTime( wave, 20 )


	//wave 5:  Nukes and Mortars together, alternating to push and pull
	local wave = TowerDefense_AddWave( "name_boneyard_wave5" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Combo_NukeMortar" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan1" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan1" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan1" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan1" )

//	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "titan2", "titan1" )
//	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone, "titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone, "titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "titan2", "titan1" )

	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan3", "titan2" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan3", "titan2" )

//	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "titan4", "titan3" )
//	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "titan4", "titan3" )
//	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "titan4", "titan3" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "titan4", "titan3" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "titan4", "titan3" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "titan4", "titan3" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone, "titan4", "titan3" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone, "titan4", "titan3" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "titan4", "titan3" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "titan4", "titan3" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "titan4", "titan3" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "titan4", "titan3" )

	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan5", "titan4" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan5", "titan4" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan5", "titan4" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan5", "titan4" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan5", "titan4" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, "titan5", "titan4" )

	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "titan6", "titan5" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "titan6", "titan5" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, "titan6", "titan5" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone, "titan6", "titan5" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone, "titan6", "titan5" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "titan6", "titan5" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "titan6", "titan5" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "titan6", "titan5" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, "titan6", "titan5" )

	Wave_SetBreakTime( wave, 10 )

	return wave
}
Globalize( CommonWave_Boneyard_Waves )

function CommonWave_Backwater_Waves()
{
	//wave 1:
	local wave = TowerDefense_AddWave( "name_backwater_wave1" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Infantry_NoTitans" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,	"troops1", null, "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops1", null, "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops1", null, "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops1", null, "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", null, "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", null, "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", null, "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", null, "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	null, "troops1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	null, "troops1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	null, "troops1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	null, "troops2", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	null, "troops2", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	null, "troops2", "rightcloseRoute" )

	Wave_SetBreakTime( wave, 10 )


	//wave 2:
	local wave = TowerDefense_AddWave( "name_backwater_wave2" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_SuicideSpectre" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, "titan1", null, "twoRoute")
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, "titan1", null, "fourRoute")
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, "titan2", "titan1", "twoRoute")
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, "titan2", "titan1", "fourRoute")

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", null, "twoRoute")
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", null, "twoRoute")
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", null, "twoRoute")
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", null, "fourRoute")
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", null, "fourRoute")
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", null, "fourRoute")

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide2", "suicide1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide2", "suicide1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide2", "suicide1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide2", "suicide1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide2", "suicide1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide2", "suicide1", "rightcloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide3", "suicide2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide3", "suicide2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide3", "suicide2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide3", "suicide2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide3", "suicide2", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide3", "suicide2", "centercloseRoute" )

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide4", "suicide3", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide4", "suicide3", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide4", "suicide3", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide4", "suicide3", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide4", "suicide3", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide4", "suicide3", "leftcloseRoute" )

	Wave_SetBreakTime( wave, 10 )


	//wave 3:
	local wave = TowerDefense_AddWave( "name_backwater_wave3" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Combo_NukeSuicide" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad,	"troops1", null, "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone, 	"troops1", null, "twoRoute" )

	Wave_AddPause( wave, 1.5 )

	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops1", null, "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops1", null, "twoRoute" )

	Wave_AddSpawn( wave, TD_SpawnCloakedDrone, 	"troops2", "troops1", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", "troops1", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad,	"troops2", "troops1", "fourRoute" )

	Wave_AddPause( wave, 1.5 )

	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops2", "troops1", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops2", "troops1", "fourRoute" )

	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", "troops2", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", "troops2", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", "troops2", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", "troops2", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", "troops2", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, "suicide1", "troops2", "rightcloseRoute" )

	Wave_AddPause( wave, 0.5 )

	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops3", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops3", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops3", "troops2" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops3", "troops2" )

	Wave_SetBreakTime( wave, 10 )


	//wave 4:
	local wave = TowerDefense_AddWave( "name_backwater_wave4" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Combo_ArcMortar" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 		"titan1", null, "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan1", null, "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan1", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan1", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan1", null, "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan1" )
	Wave_AddPause( wave, 4 )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan1", null, "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan1", null, "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan1", null, "twoRoute" )

	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 		"titan2", "titan1", "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan2", "titan1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan2", "titan1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan2", "titan1", "leftcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan2", "titan1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan2", "titan1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan2", "titan1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan2", "titan1", "rightcloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"titan2", "titan1", "twoRoute" )
	Wave_AddPause( wave, 4 )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan2", "titan1", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan2", "titan1", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"titan2", "titan1", "fourRoute" )

	Wave_SetBreakTime( wave, 15 )


	//wave 5: 12 Grunts, 28 Spectres, 52 Suicide Spectres, 6 Titans, 4 Nuke Titan == Introduce Nuke Titan (102 Units)
	local wave = TowerDefense_AddWave( "name_backwater_wave5" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_NukeTrain" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops1", null, "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops1", null, "centercloseRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 		"troops1", null, "twoRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops1", null, "twoRoute" )

	Wave_AddPause( wave, 8 )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", null, "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", null, "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", null, "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", null, "fourRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 		"troops2", null, "fourRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops2", null, "fourRoute" )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3", "troops1", "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3", "troops1", "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3", "troops1", "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3", "troops1", "twoRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"troops3", "troops1", "twoRoute" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"troops3", "troops1", "twoRoute" )

	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3", "troops2", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3", "troops2", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3", "troops2", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3", "troops2", "fourRoute" )
	Wave_AddPause( wave, 1.5 )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"troops3", "troops2", "fourRoute" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"troops3", "troops2", "fourRoute" )

	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops4", "troops3", "twoRoute" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4", "troops3", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops4", "troops3", "fourRoute" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4", "troops3", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops4", "troops3", "twoRoute" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4", "troops3", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops4", "troops3", "fourRoute" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4", "troops3", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops4", "troops3", "twoRoute" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4", "troops3", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops4", "troops3", "fourRoute" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4", "troops3", "centercloseRoute" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops4", "troops3", "twoRoute" )
	Wave_AddPause( wave, 3 )

	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops5", "troops4", "fourRoute" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops5", "troops4", "twoRoute" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops5", "troops4", "fourRoute" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops5", "troops4", "twoRoute" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops5", "troops4", "fourRoute" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops5", "troops4", "twoRoute" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops5", "troops4", "fourRoute" )
	Wave_AddPause( wave, 3 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops5", "troops4", "twoRoute" )


	Wave_SetBreakTime( wave, 10 )


	return wave
}
Globalize( CommonWave_Backwater_Waves )

/*
NEST_north
NEST_east
NEST_west
NEST_south_west
NEST_south_east
*/

function CommonWave_NEST_Waves()
{
	//wave 1:
	local wave = TowerDefense_AddWave( "name_nest1" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Infantry_NoTitans" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "NEST_north" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "NEST_north" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", null, "NEST_north" )
	//Wave_AddPause( wave, 4 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", null, "NEST_south_east" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops3", null, "NEST_south_east" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4", null, "NEST_south_west" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4", null, "NEST_south_west" )
	//Wave_AddPause( wave, 4 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4", "troops1", "NEST_west" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops5", "troops2", "NEST_west" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops5", "troops2", "NEST_south_west" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops6", "troops3", "NEST_south_east" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops6", "troops3", "NEST_east" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops6", "troops3", "NEST_east" )//unknown what dependency does
	Wave_AddPause( wave, 4 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "NEST_north" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", null, "NEST_south_east" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops3", null, "NEST_east" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4", null, "NEST_west" )

	Wave_SetBreakTime( wave, 10 )

	local wave = TowerDefense_AddWave( "name_nest2" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Infantry" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 	"troops1" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops3" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops4" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops4" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 	"troops5", "troops1", "NEST_south_east" )
	Wave_AddPause( wave, 4 )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops1", null, "NEST_south_west" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", null, "NEST_west" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", null, "NEST_west" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3", null, "NEST_north" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops7", "troops3", "NEST_south_east" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops7", "troops3", "NEST_south_west" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops7", "troops3", "NEST_east" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops8", "troops4", "NEST_east" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"troops8", "troops4", "NEST_north" )

	Wave_SetBreakTime( wave, 10 )

	local wave = TowerDefense_AddWave( "name_nest3" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Titans" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops1" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 	"troops1" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", null, "NEST_west" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2", null, "NEST_west" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 	"troops3", null, "NEST_east" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 	"troops3", null, "NEST_east" )
	Wave_AddPause( wave, 4 )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops1", null, "NEST_south_east" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops1", null, "NEST_south_east" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops2", null, "NEST_south_west" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 	"troops2", null, "NEST_south_west" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops3", "troops1", "NEST_south_west" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops3", "troops1", "NEST_south_west" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops4", "troops2", "NEST_south_east" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 	"troops4", "troops2", "NEST_south_east" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops5", null, "NEST_east" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops5", null, "NEST_east" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops6", null, "NEST_west" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 	"troops6", null, "NEST_west" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops7", "troops5", "NEST_west" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops7", "troops5", "NEST_west" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops8", "troops6", "NEST_east" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 	"troops8", "troops6", "NEST_east" )

	Wave_SetBreakTime( wave, 10 )

	local wave = TowerDefense_AddWave( "name_nest4" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Titans" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 	"troops1", null, "NEST_north" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 	"troops2", null, "NEST_east" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 	"troops3", null, "NEST_west" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 	"troops4", null, "NEST_south_west" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 	"troops5", null, "NEST_south_east" )
	Wave_AddPause( wave, 4 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops3" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops3" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 	"troops5", "troops4" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 	"troops5", "troops4" )

	Wave_SetBreakTime( wave, 10 )

	local wave = TowerDefense_AddWave( "name_nest5" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_MortarTitans" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"troops1", null, "NEST_north" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"troops2", null, "NEST_east" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"troops3", null, "NEST_west" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"troops4", null, "NEST_south_west" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"troops5", null, "NEST_south_east" )
	Wave_AddPause( wave, 4 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops1" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops3" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops4" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"troops5", "troops4" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"troops5", "troops4" )

	Wave_SetBreakTime( wave, 10 )

	local wave = TowerDefense_AddWave( "name_nest6" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Infantry" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops1" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops2" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops3" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops3" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops4" )
	Wave_AddPause( wave, 4 )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 	"troops5" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone, 	"troops5" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops5" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops5" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"troops6", "troops5" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"troops6", "troops5" )

	Wave_SetBreakTime( wave, 10 )

	local wave = TowerDefense_AddWave( "name_nest7" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_ArcTitans" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops1" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops1" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops1" )
	Wave_AddSpawn( wave, TD_SpawnSuicideSpectreSquad, 	"troops1" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 	"troops2", null, "NEST_west"  )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 	"troops3", null, "NEST_east"  )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"troops3", null, "NEST_east"  )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops4" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops4" )
	Wave_AddSpawn( wave, TD_SpawnSpectreSquad, 	"troops4" )
	Wave_AddPause( wave, 4 )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 	"troops5" )
	Wave_AddSpawn( wave, TD_SpawnCloakedDrone, 	"troops5" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 	"troops6" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 	"troops6" )

	Wave_SetBreakTime( wave, 10 )

	local wave = TowerDefense_AddWave( "name_nest8" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_NukeTitans" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops1", null, "NEST_east" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops1", null, "NEST_east" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 	"troops1", null, "NEST_east" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "NEST_east" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops1", null, "NEST_east" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 	"troops2", null, "NEST_north" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops2", null, "NEST_north" )
	Wave_AddPause( wave, 4 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops3", null, "NEST_south_east" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops3", null, "NEST_south_east" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops4", null, "NEST_south_west" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops4", null, "NEST_south_west" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops4", null, "NEST_south_west" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"troops5", "troops4", "NEST_west" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 	"troops6", "troops5", "NEST_north" )
	Wave_AddSpawn( wave, TD_SpawnMortarTitan, 	"troops6", "troops5", "NEST_north" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 	"troops6", "troops5", "NEST_north" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops6", "troops5", "NEST_north" )
	
	Wave_SetBreakTime( wave, 15 )

	local wave = TowerDefense_AddWave( "name_nest9" )
	Wave_SetAnnounceVO( wave, "CoopTD_EnemyAnnounce_Rise_HugeWave" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 	"troops1", null, "NEST_east" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 	"troops1", null, "NEST_east" )
	Wave_AddSpawn( wave, TD_SpawnEmpTitan, 	"troops1", null, "NEST_east" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops2", null, "NEST_north" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops2", null, "NEST_north" )
	Wave_AddPause( wave, 5 )
	Wave_AddSpawn( wave, TD_SpawnTitan, 	"troops1", null, "NEST_north" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", null, "NEST_west" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops2", null, "NEST_west" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 	"troops2", null, "NEST_west" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 	"troops3", null, "NEST_south_east" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 	"troops3", null, "NEST_south_east" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 	"troops4", null, "NEST_east" )
	Wave_AddSpawn( wave, TD_SpawnTitan, 	"troops4", null, "NEST_east" )
	Wave_AddPause( wave, 5 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops5", null, "NEST_north" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops5", null, "NEST_north" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops5", null, "NEST_north" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops6", "troops5", "NEST_south_west" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops6", "troops5", "NEST_south_west" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops6", "troops5", "NEST_south_west" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops7", "troops6", "NEST_south_east" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops7", "troops6", "NEST_south_east" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops7", "troops6", "NEST_south_east" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops8", "troops7", "NEST_east" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops8", "troops7", "NEST_east" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops8", "troops7", "NEST_east" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops9", "troops8", "NEST_west" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquad, 	"troops9", "troops8", "NEST_west" )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops9", "troops8", "NEST_west" )
	Wave_AddPause( wave, 10 )
	Wave_AddSpawn( wave, TD_SpawnGruntSquadDroppod, 	"troops1", null, "NEST_north" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquadDroppod, 	"troops1", null, "NEST_north" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquadDroppod, 	"troops1", null, "NEST_north" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquadDroppod, 	"troops2", null, "NEST_west" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquadDroppod, 	"troops2", null, "NEST_west" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquadDroppod, 	"troops2", null, "NEST_west" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquadDroppod, 	"troops3", null, "NEST_east" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquadDroppod, 	"troops3", null, "NEST_east" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquadDroppod, 	"troops3", null, "NEST_east" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquadDroppod, 	"troops4", null, "NEST_south_west" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquadDroppod, 	"troops4", null, "NEST_south_west" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquadDroppod, 	"troops4", null, "NEST_south_west" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquadDroppod, 	"troops5", null, "NEST_south_east" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquadDroppod, 	"troops5", null, "NEST_south_east" )
	Wave_AddSpawn( wave, TD_SpawnGruntSquadDroppod, 	"troops5", null, "NEST_south_east" )
	Wave_AddPause( wave, 4 )
	Wave_AddSpawn( wave, TD_SpawnNukeTitan, 	"troops10", null, "NEST_south_east" )

	Wave_SetBreakTime( wave, 10 )

	return wave
}
Globalize( CommonWave_NEST_Waves )