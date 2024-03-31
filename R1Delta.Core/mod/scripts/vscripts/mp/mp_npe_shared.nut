const TEACHER = "TEACHER"

if ( IsServer() && !reloadingScripts )
{
	level.tempConvs <- {}
	level.tempConvs[ TEAM_MILITIA ] <- []
	level.tempConvs[ TEAM_IMC ] <- []
}

function main()
{
	if ( reloadingScripts )
		return

	RegisterSignal( "TempConversationStart" )

	RegisterTestConversations()
	NPE_RegisterConversations()
}

function ShouldDoIntroscreens()
{
	return ( !NPE_DEV_TEST || ( NPE_DEV_TEST && NPE_DEV_SHOW_INTROSCREEN ) )
}

// ============== REAL CONVERSATIONS ================
function NPE_RegisterConversations()
{
	RegisterConversation( "welldone", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "nicelydone", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "goodjob", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "wellplayed", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "requirements_met", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "objective_complete", VO_PRIORITY_GAMESTATE )

	RegisterConversation( "intro", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "intro_welcome", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "intro_quickstart_titan", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "intro_quickstart_pilot", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "intro_simulator_initializing", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "outro_simulator_finished", VO_PRIORITY_GAMESTATE )

	RegisterConversation( "train_lookat", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_lookat_nag", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_lookat_askIfInvertSettingIsGood", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_lookat_askIfInvertSettingIsGood_verbose", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_lookat_confirmInvertSetting", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_lookat_menureminder", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_lookat_pt2", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_move", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_move_nag", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_move_nag_v2", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "walk_through_tunnel", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "walk_through_tunnel_nag", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "walk_through_tunnel_help1", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "walk_through_tunnel_help2", VO_PRIORITY_GAMESTATE )

	RegisterConversation( "train_sprint", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_sprint_nag", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_sprint_tryagain", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_sprint_help_timing", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_sprint_verbose", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_sprint_fully_through_tunnel", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_sprint_pilot_not_sprinting", VO_PRIORITY_GAMESTATE )
	//RegisterConversation( "train_sprint_lookat_onscreen_help", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_sprint_lights_mean_sprinting", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_sprint_dont_hold_button", VO_PRIORITY_GAMESTATE )

	RegisterConversation( "train_jump", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_sprint_and_jump", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_sprint_and_jump_help", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_mantle", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_mantle_help", VO_PRIORITY_GAMESTATE )

	RegisterConversation( "train_wallrun", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_wallrun_instructions", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_wallrun_instructions_withjump", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_wallrun_3", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_wallrun_jumpoffwall_hint", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_wallrun_mantle", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_wallrun_hint_jumpingOffTooEarly", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_wallrun_jump1_help1", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_wallrun_jump1_help2", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_wallrun_jump2_help1", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_wallrun_jump2_help2", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_wallrun_jump2_help3", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_wallrun_jump2_help4", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_wallrun_jump3_help1", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_wallrun_jump3_help2", VO_PRIORITY_GAMESTATE )


	RegisterConversation( "train_wallrun_playground", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_doublejump", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_doublejump_2", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_doublejump_help_1", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_doublejump_help_2", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_doublejump_help_3", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_doublejump_ceiling", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_doublejump_playground", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_cloak", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_cloak_pt2", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_cloak_failed", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_cloak_ranIntoPlayer", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_cloak_killedSentries", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_cloak_proceedtoExit", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_cloak_limitedtime", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_melee", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_melee_nag", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_rodeo", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_titan_attack", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_melee_behind_is_safer", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_pull_weapon", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_reload", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_smart_pistol", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_smart_pistol_2", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_smart_pistol_reminder", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_smart_pistol_done", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_smart_pistol_multitarget", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_smart_pistol_multitarget_2", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_smart_pistol_multitarget_nag", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_smart_pistol_multitarget_done", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_smart_pistol_multilock", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_smart_pistol_multilock_nag", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_smart_pistol_multilock_reminder_1", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_smart_pistol_multilock_reminder_2", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_smart_pistol_multilock_done", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_firingrange_rifleswap", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_firingrange_rifleswap_nag", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_ads", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_ads_nag", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_firingrange_killtargets", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_firingrange_grenades", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_firingrange_at_swap", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_firingrange_at_swap_nag", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_firingrange_at_killTitan", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_firingrange_at_killTitan_done", VO_PRIORITY_GAMESTATE )

	RegisterConversation( "moshpit_combat_start", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_minimap", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_minimap_findgrunts", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "moshpit_titan_combat_start", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "moshpit_titan_at_reminder", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "pilot_health_training", VO_PRIORITY_GAMESTATE )


	RegisterConversation( "train_titanfall", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_call_in_titan", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_call_in_titan_nag", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_titanfall_lookup", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "train_titan_mountup", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "titan_controls_like_pilot", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "titan_primary_fire_like_pilot", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "titan_kill_drop_pod_grunts", VO_PRIORITY_GAMESTATE )

	RegisterConversation( "moshpit_done", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "pilot_cert_done", VO_PRIORITY_GAMESTATE )

	RegisterConversation( "cabin_PA", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "cabin_PA_alt", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "cabin_PA_welcome", VO_PRIORITY_GAMESTATE )


	RegisterConversation( "titan_dash_speed_intro", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "titan_dash_meter", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "titan_dash_meter_2", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "titandash_dash_anydirection", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "titandash_dash_anydirection_nag", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "titandash_left", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "titandash_left_nag", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "titandash_right", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "titandash_right_nag", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "titandash_forward", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "titandash_forward_nag", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "titandash_back", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "titandash_back_nag", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "titandash_move_forward", VO_PRIORITY_GAMESTATE )

	RegisterConversation( "titan_dash_threat", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "titan_dash_hint_nodamage", VO_PRIORITY_GAMESTATE )

	RegisterConversation( "titan_vortex", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "titan_vortex_hint_nodamage", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "titan_vortex_refire", VO_PRIORITY_GAMESTATE )

	RegisterConversation( "titan_pet_intro", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "titan_pet_disembark", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "titan_pet_go_hack", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "titan_aimode_intro", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "titan_aimode_hud", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "titan_pet_toggle_follow", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "titan_pet_follow_info", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "titan_pet_reembark", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "titan_pet_exit", VO_PRIORITY_GAMESTATE )

	RegisterConversation( "offhand_rocket_intro", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "offhand_rocket_fire_name", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "offhand_rocket_fire_direction", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "offhand_rocket_fire_finish", VO_PRIORITY_GAMESTATE )

	RegisterConversation( "titan_mosh_intro", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "titan_mosh_start", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "titan_shields_training", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "titan_health_training", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "titan_mosh_wave_survived", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "titan_mosh_wave_start", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "titan_mosh_wave_shields_disabled", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "titan_mosh_wave_shields_enabled", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "titan_mosh_wave_advanced_weapons", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "titan_mosh_wave_vortex", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "titan_mosh_wave_all_survived", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "titan_mosh_wave_forced_standdown", VO_PRIORITY_GAMESTATE )

	RegisterConversation( "titan_doomed_info", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "titan_infinite_doomed_info", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "titan_doomed_eject", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "titan_eject_nag", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "titan_eject_in_air", VO_PRIORITY_GAMESTATE )

	RegisterConversation( "bonus_wallrun_highroad", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "bonus_wallrun_lowroad", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "bonus_nav_excellent", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "bonus_doublejump_playground_fasttime", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "bonus_firingrange_noreload", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "bonus_firingrange_headshots", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "bonus_firingrange_no_grenade_misses", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "bonus_moshpit_lowdamage", VO_PRIORITY_GAMESTATE )

	if ( IsServer() )
		return

	local convRef

	local voGuy = "spyglass"

	// Well done.
	convRef = AddConversation( "welldone" )
	AddVDURadio( convRef, voGuy, "diag_tut_calibration_NP104_01_01_neut_tutai" )

	// Nicely done.
	convRef = AddConversation( "nicelydone" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP266_01_01_neut_tutai" )

	// Good job.
	convRef = AddConversation( "goodjob" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP265_01_01_neut_tutai" )

	// Well played.
	convRef = AddConversation( "wellplayed" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP268_01_01_neut_tutai" )

	// Completion requirements met.
	convRef = AddConversation( "requirements_met" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP269_01_01_neut_tutai" )

	// Objective complete.
	convRef = AddConversation( "objective_complete" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP267_01_01_neut_tutai" )


	// Welcome to the Hammond Pilot Certification Simulator. Warning. Unregistered user detec--garble#($@*&133410952-- Key Accepted. Training Pod is Authorized.
	convRef = AddConversation( "intro" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP253_01_01_neut_tutai" )

	// Welcome, Pilot.
	convRef = AddConversation( "intro_welcome" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP254_01_01_neut_tutai" )

	// Welcome back, Pilot.
	// Now beginning Titan training.
	convRef = AddConversation( "intro_quickstart_titan" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP255_01_01_neut_tutai" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP275_01_01_neut_tutai" )

	// Welcome back to Pilot certification.
	convRef = AddConversation( "intro_quickstart_pilot" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP274_01_01_neut_tutai" )

	// Simulator initializing.
	convRef = AddConversation( "intro_simulator_initializing" )
	AddVDURadio( convRef, voGuy, "diag_tut_calibration_NP108z_01_01_neut_tutai" )

	// For your safety, please stay in the training pod to regain your equilibrium.
	convRef = AddConversation( "outro_simulator_finished" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP277_01_01_neut_tutai" )


	// To calibrate the AR display, please look at each of the RED lights.
	convRef = AddConversation( "train_lookat" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP258_01_01_neut_tutai" )


	// To continue, please look at both of the lights.
	convRef = AddConversation( "train_lookat_nag" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP259_01_01_neut_tutai" )

	// "Would you like to reverse the vertical look input?"
	convRef = AddConversation( "train_lookat_askIfInvertSettingIsGood" )
	AddVDURadio( convRef, voGuy, "diag_tut_calibration_NP105_01_01_neut_tutai" )


	// If these settings are comfortable, click YES. Otherwise click NO to calibrate again.
	convRef = AddConversation( "train_lookat_askIfInvertSettingIsGood_verbose" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP262_01_01_neut_tutai" )

	// Please confirm your selection by looking at each of the lights again.
	convRef = AddConversation( "train_lookat_confirmInvertSetting" )
	AddVDURadio( convRef, voGuy, "diag_tut_calibration_NP106_01_01_neut_tutai" )

	// "You may use the simulator menu at any time to adjust the look controls."
	convRef = AddConversation( "train_lookat_menureminder" )
	AddVDURadio( convRef, voGuy, "diag_tut_calibration_NP107_01_01_neut_tutai" )  // NOT YET IMPLEMENTED

	// "Visual calibration complete. Simulator initializing."
	convRef = AddConversation( "train_lookat_pt2" )
	AddVDURadio( convRef, voGuy, "diag_tut_calibration_NP108_01_01_neut_tutai" )

	convRef = AddConversation( "train_move" )
	AddVDURadio( convRef, voGuy, "diag_tut_movement_NP109_01_01_neut_tutai" )

	// "Please move around to continue."
	convRef = AddConversation( "train_move_nag" )
	AddVDURadio( convRef, voGuy, "diag_tut_movement_NP111_01_01_neut_tutai" )

	// "To proceed, please move around the simulation."
	convRef = AddConversation( "train_move_nag_v2" )
	AddVDURadio( convRef, voGuy, "diag_tut_movement_NP110_01_01_neut_tutai" )  // NOT YET IMPLEMENTED


	// "Please WALK through the tunnel in front of you."
	local convRef = AddConversation( "walk_through_tunnel" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP280_01_01_neut_tutai" )

	// "To continue, WALK through the tunnel."
	local convRef = AddConversation( "walk_through_tunnel_nag" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP281_01_01_neut_tutai" )

	// "The doors in front of you will slowly close as you move forward. To proceed, move quickly enough to beat the closing doors."
	local convRef = AddConversation( "walk_through_tunnel_help1" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP282_01_01_neut_tutai" )

	// "To make it past the closing doors, walk steadily through the tunnel."
	local convRef = AddConversation( "walk_through_tunnel_help2" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP283_01_01_neut_tutai" )


	// Sprint through the tunnel.
	convRef = AddConversation( "train_sprint" )
	AddVDURadio( convRef, voGuy, "diag_tut_movement_NP112_01_01_neut_tutai" )

	// To make it past this set of closing doors, you must SPRINT as you move.
	convRef = AddConversation( "train_sprint_verbose" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP284_01_01_neut_tutai" )

	// To proceed, please sprint through the tunnel.
	convRef = AddConversation( "train_sprint_nag" )
	AddVDURadio( convRef, voGuy, "diag_tut_movement_NP113_01_01_neut_tutai" )

	// Beat the closing doors by sprinting.
	convRef = AddConversation( "train_sprint_tryagain" )
	AddVDURadio( convRef, voGuy, "diag_tut_movement_NP114_01_01_neut_tutai" )

	// Start moving first, then start sprinting a moment later.
	convRef = AddConversation( "train_sprint_help_timing" )
	AddVDURadio( convRef, voGuy, "diag_tut_movement_NP115_01_01_neut_tutai" )

	// You must SPRINT all the way through the tunnel, from start to finish.
	convRef = AddConversation( "train_sprint_fully_through_tunnel" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP285_01_01_neut_tutai" )

	// Pilot, you are not SPRINTING!
	convRef = AddConversation( "train_sprint_pilot_not_sprinting" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP286_01_01_neut_tutai" )
	// Please refer to the onscreen instructions to learn how to SPRINT.
	//convRef = AddConversation( "train_sprint_lookat_onscreen_help" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP287_01_01_neut_tutai" )

	// If the lights in the tunnel do not turn green, you are not sprinting.
	convRef = AddConversation( "train_sprint_lights_mean_sprinting" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP288_01_01_neut_tutai" )

	// You do not need to HOLD the SPRINT button down while moving; just CLICK it once to start sprinting.
	convRef = AddConversation( "train_sprint_dont_hold_button" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP289_01_01_neut_tutai" )


	convRef = AddConversation( "train_jump" )
	AddVDURadio( convRef, voGuy, "diag_tut_movement_NP116_01_01_neut_tutai" )

	convRef = AddConversation( "train_sprint_and_jump" )
	AddVDURadio( convRef, voGuy, "diag_tut_movement_NP117_01_01_neut_tutai" )

	// Sprint toward the edge, then jump just before the edge.
	convRef = AddConversation( "train_sprint_and_jump_help" )
	AddVDURadio( convRef, voGuy, "diag_tut_movement_NP118_01_01_neut_tutai" )  // NOT YET IMPLEMENTED

	convRef = AddConversation( "train_mantle" )
	AddVDURadio( convRef, voGuy, "diag_tut_movement_NP119_01_01_neut_tutai" )

	// Jump up, while looking at the ledge, to start pulling yourself up.
	convRef = AddConversation( "train_mantle_help" )
	AddVDURadio( convRef, voGuy, "diag_tut_movement_NP120_01_01_neut_tutai" )  // NOT YET IMPLEMENTED


	// As a Pilot, your most important piece of gear is your JUMP KIT, which allows you to run on walls.
	convRef = AddConversation( "train_wallrun" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP256_01_01_neut_tutai" )

	// Run toward the wall at a diagonal angle and jump once to start wallrunning.
	convRef = AddConversation( "train_wallrun_instructions" )
	AddVDURadio( convRef, voGuy, "diag_tut_movement_NP122_01_01_neut_tutai" )

	// Run toward the wall at a diagonal angle and jump once to start wallrunning.
	// Jump again to detach from the wall.
	convRef = AddConversation( "train_wallrun_instructions_withjump" )
	AddVDURadio( convRef, voGuy, "diag_tut_movement_NP122_01_01_neut_tutai" )
	AddVDURadio( convRef, voGuy, "diag_tut_movement_NP123_01_01_neut_tutai" )

	// Wallruns can be chained together to travel farther.
	// Try jumping from one wallrun directly into another.
	convRef = AddConversation( "train_wallrun_3" )
	AddVDURadio( convRef, voGuy, "diag_tut_movement_NP125_01_01_neut_tutai" )
	AddVDURadio( convRef, voGuy, "diag_tut_movement_NP126_01_01_neut_tutai" )


	// WALLRUN, then JUMP, off of the wall, towards the ledge. This will give you enough height to MANTLE onto the ledge.
	convRef = AddConversation( "train_wallrun_mantle" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP300_01_01_neut_tutai" )

	// You are jumping OFF the wall too early.
	// After jumping ONCE to start wallrunning, WAIT before jumping off the wall.
	convRef = AddConversation( "train_wallrun_hint_jumpingOffTooEarly" )
	AddVDURadio( convRef, voGuy, "diag_tut_movement_NP184_01_01_neut_tutai" )
	AddVDURadio( convRef, voGuy, "diag_tut_movement_NP185_01_01_neut_tutai" )


	// WALLRUN across the gap to proceed.
	convRef = AddConversation( "train_wallrun_jump1_help1" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP296_01_01_neut_tutai" )

	// To continue, WALLRUN across the gap.
	convRef = AddConversation( "train_wallrun_jump1_help2" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP297_01_01_neut_tutai" )


	// To cross this gap, you can JUMP off the wall at the end of your wallrun.
	convRef = AddConversation( "train_wallrun_jump2_help1" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP290_01_01_neut_tutai" )

	// This distance is too far to cover with wallrun alone. JUMP at the end of your run to extend the distance.
	convRef = AddConversation( "train_wallrun_jump2_help2" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP292_01_01_neut_tutai" )

	// Wallruns only last for a short time.
	// Make sure to JUMP at the end of your wallrun to make it over the gap.
	convRef = AddConversation( "train_wallrun_jump2_help3" )
	AddVDURadio( convRef, voGuy, "diag_tut_movement_NP125a_01_01_neut_tutai" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP293_01_01_neut_tutai" )

	// JUMP off of the wall before you lose your grip.
	convRef = AddConversation( "train_wallrun_jump2_help4" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP291_01_01_neut_tutai" )


	// Be sure to jump toward the second wall before your first wallrun ends.
	convRef = AddConversation( "train_wallrun_jump3_help1" )
	AddVDURadio( convRef, voGuy, "diag_tut_movement_NP128_01_01_neut_tutai" )

	// If you detach from the first wall too early, you will not be able to run far enough on the second wall to make the jump.
	convRef = AddConversation( "train_wallrun_jump3_help2" )
	AddVDURadio( convRef, voGuy, "diag_tut_movement_NP127_01_01_neut_tutai" )


	// If you detach from the first wall too early, you will not be able to run far enough on the second wall to make the jump.
	//diag_tut_movement_NP127_01_01_neut_tutai

	// Be sure to jump toward the second wall before your first wallrun ends.
	//diag_tut_movement_NP128_01_01_neut_tutai

	// Use sprinting, jumping and wallrunning to make your way to the exit.
	convRef = AddConversation( "train_wallrun_playground" )
	AddVDURadio( convRef, voGuy, "diag_tut_movement_NP129_01_01_neut_tutai" )

	// The exit is on the opposite side of the room.
	//diag_tut_movement_NP130_01_01_neut_tutai

	// The exit is located above you.
	//diag_tut_movement_NP131_01_01_neut_tutai

	// Head for the objective marker on your AR display to find the exit.
	//diag_tut_movement_NP132_01_01_neut_tutai

	// Jump Kits extend your natural jumping ability. You can jump once more after leaving the ground.
	convRef = AddConversation( "train_doublejump" )
	AddVDURadio( convRef, voGuy, "diag_tut_movement_NP133_01_01_neut_tutai" )

	// To cover even more distance, wait longer before starting the second jump.
	convRef = AddConversation( "train_doublejump_2" )
	AddVDURadio( convRef, voGuy, "diag_tut_movement_NP135_01_01_neut_tutai" )

	// Let your first jump carry you for a moment before jumping again.
	convRef = AddConversation( "train_doublejump_help_1" )
	AddVDURadio( convRef, voGuy, "diag_tut_movement_NP134_01_01_neut_tutai" )

	// For more distance, wait longer before starting your second jump.
	convRef = AddConversation( "train_doublejump_help_2" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP303_01_01_neut_tutai" )

	// Jump at the very edge of the gap to achieve maximum distance.
	convRef = AddConversation( "train_doublejump_help_3" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP304_01_01_neut_tutai" )

	// Double jump and mantle into the hole above to proceed.
	convRef = AddConversation( "train_doublejump_ceiling" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP305_01_01_neut_tutai" )


	// Use wallrunning and double jumping to make your way to the exit.
	convRef = AddConversation( "train_doublejump_playground" )
	AddVDURadio( convRef, voGuy, "diag_tut_movement_NP136_01_01_neut_tutai" )

	// Cloaking - making yourself nearly invisible - is essential to Pilot survival.
	convRef = AddConversation( "train_cloak" )
	AddVDURadio( convRef, voGuy, "diag_tut_cloaking_NP137_01_01_neut_tutai" )

	convRef = AddConversation( "train_cloak_pt2" )
	AddVDURadio( convRef, voGuy, "diag_tut_cloaking_NP138_01_01_neut_tutai" )

	// To get past the sentries, cloak first, then move past quickly.
	convRef = AddConversation( "train_cloak_failed" )
	AddVDURadio( convRef, voGuy, "diag_tut_cloaking_NP138_01_01_neut_tutai" )

	convRef = AddConversation( "train_rodeo" )
	AddVDURadio( convRef, voGuy, "diag_tut_combat_np178_01_01_neut_tutai" )

	convRef = AddConversation( "train_titan_attack" )
	AddVDURadio( convRef, voGuy, "diag_tut_combat_np179_01_01_neut_tutai" )

	// Cloaking only lasts for a short time. Make your move decisively after cloaking.
	//diag_tut_cloaking_NP140_01_01_neut_tutai

	// For best results don't run into the sentries.
	convRef = AddConversation( "train_cloak_ranIntoPlayer" )
	AddVDURadio( convRef, voGuy, "diag_tut_cloaking_NP141_01_01_neut_tutai" )

	// Impressive moves, Pilot. A textbook demonstration of using cloak in melee combat.
	convRef = AddConversation( "train_cloak_killedSentries" )
	AddVDURadio( convRef, voGuy, "diag_tut_cloaking_NP186_01_01_neut_tutai" )

	// Please proceed to the exit.
	convRef = AddConversation( "train_cloak_proceedtoExit" )
	AddVDURadio( convRef, voGuy, "diag_tut_cloaking_NP187_01_01_neut_tutai" )

	//Cloaking does not last forever.  Look at your CLOAK METER on the bottom left of your screen to monitor your remaining cloak time.
	convRef = AddConversation( "train_cloak_limitedtime" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP387_01_01_neut_tutai" )



	// 	In close quarters situations, you can kill silently with a melee attack.
	convRef = AddConversation( "train_melee" )
	AddVDURadio( convRef, voGuy, "diag_tut_weapons_NP143_01_01_neut_tutai" )

	// Get close to the target to melee.
	convRef = AddConversation( "train_melee_nag" )
	AddVDURadio( convRef, voGuy, "diag_tut_weapons_NP142_01_01_neut_tutai" )

	//If you melee an opponent from behind, you will perform an execution. Meleeing an enemy from the front can be faster, but carries more risk of death.
	convRef = AddConversation( "train_melee_behind_is_safer" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP388_01_01_neut_tutai" )


	// To continue, please pull your weapon.
	convRef = AddConversation( "train_pull_weapon" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP317_01_01_neut_tutai" )

	// The weapon is empty. Load a fresh magazine.
	convRef = AddConversation( "train_reload" )
	AddVDURadio( convRef, voGuy, "diag_tut_weapons_NP146_01_01_neut_tutai" )

	// Reload your weapon.
	//diag_tut_weapons_NP147_01_01_neut_tutai


	// This is the Smart Pistol, an autotargeting weapon.
	convRef = AddConversation( "train_smart_pistol" )
	AddVDURadio( convRef, voGuy, "diag_tut_weapons_NP148_01_01_neut_tutai" )

	// Get close enough to a valid target and the Smart Pistol will start locking on. Wait for full lock before pulling the trigger.
	convRef = AddConversation( "train_smart_pistol_2" )
	AddVDURadio( convRef, voGuy, "diag_tut_weapons_NP149_01_01_neut_tutai" )

	// Use your Smart Pistol to neutralize the target.
	convRef = AddConversation( "train_smart_pistol_reminder" )
	AddVDURadio( convRef, voGuy, "diag_tut_weapons_NP152_01_01_neut_tutai" )

	// Target eliminated.
	convRef = AddConversation( "train_smart_pistol_done" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP325_01_01_neut_tutai" )

	// The Smart Pistol can lock onto more than one target.
	convRef = AddConversation( "train_smart_pistol_multitarget" )
	AddVDURadio( convRef, voGuy, "diag_tut_weapons_NP153_01_01_neut_tutai" )

	// Try to eliminate all the targets with one trigger pull.
	convRef = AddConversation( "train_smart_pistol_multitarget_2" )
	AddVDURadio( convRef, voGuy, "diag_tut_weapons_NP154_01_01_neut_tutai" )

	// Eliminate all of the targets with your Smart Pistol.
	convRef = AddConversation( "train_smart_pistol_multitarget_nag" )
	AddVDURadio( convRef, voGuy, "diag_tut_weapons_NP155_01_01_neut_tutai" )

	// Targets neutralized.
	convRef = AddConversation( "train_smart_pistol_multitarget_done" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP326_01_01_neut_tutai" )

	// Some enemies, especially Pilots, require multiple locks to kill with one trigger pull.
	convRef = AddConversation( "train_smart_pistol_multilock" )
	AddVDURadio( convRef, voGuy, "diag_tut_weapons_NP157_01_01_neut_tutai" )


	// Kill the Pilot with your SMART PISTOL.
	convRef = AddConversation( "train_smart_pistol_multilock_nag" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP319_01_01_neut_tutai" )


	// Wait until the weapon has acquired all of the possible lock points before pulling the trigger.
	convRef = AddConversation( "train_smart_pistol_multilock_reminder_1" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP249_01_01_neut_tutai" )

	// Wait for the weapon to finish the lockon process before pulling the trigger.
	convRef = AddConversation( "train_smart_pistol_multilock_reminder_2" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP243_01_01_neut_tutai" )

	// Target down.
	convRef = AddConversation( "train_smart_pistol_multilock_done" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP324_01_01_neut_tutai" )


	// Switch to your rifle.
	convRef = AddConversation( "train_firingrange_rifleswap" )
	AddVDURadio( convRef, voGuy, "diag_tut_weapons_NP159_01_01_neut_tutai" )

	// To continue, please switch to your rifle.
	convRef = AddConversation( "train_firingrange_rifleswap_nag" )
	AddVDURadio( convRef, voGuy, "diag_tut_weapons_NP160_01_01_neut_tutai" )

	// To take a more calculated shot, you can AIM DOWN THE SIGHTS of your weapon.
	convRef = AddConversation( "train_ads" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP201_01_01_neut_tutai" )

	// To continue, please AIM DOWN THE SIGHTS of your weapon.
	convRef = AddConversation( "train_ads_nag" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP202_01_01_neut_tutai" )

	// Destroy all of the targets in the shooting range.
	convRef = AddConversation( "train_firingrange_killtargets" )
	AddVDURadio( convRef, voGuy, "diag_tut_weapons_NP162_01_01_neut_tutai" )

	// Throw a grenade into each of the windows.
	convRef = AddConversation( "train_firingrange_grenades" )
	AddVDURadio( convRef, voGuy, "diag_tut_weapons_NP163_01_01_neut_tutai" )

	// To throw a grenade higher and farther, tilt your view up slightly while throwing.
	//diag_tut_weapons_NP164_01_01_neut_tutai

	// Titans won't take damage from small arms fire. Switch to your Anti-Titan weapon.
	convRef = AddConversation( "train_firingrange_at_swap" )
	AddVDURadio( convRef, voGuy, "diag_tut_weapons_NP165_01_01_neut_tutai" )

	// To continue, please switch to your Anti-Titan weapon.
	convRef = AddConversation( "train_firingrange_at_swap_nag" )
	AddVDURadio( convRef, voGuy, "diag_tut_weapons_NP166_01_01_neut_tutai" )

	// Destroy the Titan with your anti-titan weapon.
	convRef = AddConversation( "train_firingrange_at_killTitan" )
	AddVDURadio( convRef, voGuy, "diag_tut_weapons_NP167_01_01_neut_tutai" )

	// Taking on a Titan is very dangerous even with the right weaponry.
	convRef = AddConversation( "train_firingrange_at_killTitan_done" )
	AddVDURadio( convRef, voGuy, "diag_tut_weapons_NP168_01_01_neut_tutai" )


	// Combat scenario initialized. Destroy all opposition in the area.
	convRef = AddConversation( "moshpit_combat_start" )
	AddVDURadio( convRef, voGuy, "diag_tut_combat_NP171_01_01_neut_tutai" )

	// Your minimap is located in the upper left corner of your AR display.
	convRef = AddConversation( "train_minimap" )
	AddVDURadio( convRef, voGuy, "diag_tut_combat_NP172_01_01_neut_tutai" )

	// Look for the small dots on your minimap to find all the enemy troops.	
	convRef = AddConversation( "train_minimap_findgrunts" )
	AddVDURadio( convRef, voGuy, "diag_tut_combat_NP173_01_01_neut_tutai" )

	convRef = AddConversation( "pilot_health_training" )
	// For this certification, death simulation has been disabled.
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP334_01_01_neut_tutai" )
	// As a Pilot, when your viewscreen tints red, you are close to death.
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP335_01_01_neut_tutai" )
	// Avoid taking damage for a short time, and your health will stabilize.
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP336_01_01_neut_tutai" )
	// Once the red tint on your screen fades away, you have fully recovered.
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP337_01_01_neut_tutai" )


	// Combat scenario initialized. Hostile Titanfall imminent.
	convRef = AddConversation( "moshpit_titan_combat_start" )
	AddVDURadio( convRef, voGuy, "diag_tut_combat_NP174_01_01_neut_tutai" )

	// Remember to use your Anti-Titan weapons to destroy hostile Titans.
	convRef = AddConversation( "moshpit_titan_at_reminder" )
	AddVDURadio( convRef, voGuy, "diag_tut_combat_NP175_01_01_neut_tutai" )

	//Only Anti-Titan weapons can damage Titans.	diag_tut_combat_NP176_01_01_neut_tutai

	// Pilots earn credit toward their next Titan drop by engaging in combat.
	// Once your Titan is built, you can drop your Titan onto the battlefield.
	convRef = AddConversation( "train_titanfall" )
	AddVDURadio( convRef, voGuy, "diag_tut_titanIntro_NP178_01_01_neut_tutai" )

	// To continue, please initiate Titanfall.
	convRef = AddConversation( "train_call_in_titan" )
	AddVDURadio( convRef, voGuy, "diag_tut_titanIntro_NP180_01_01_neut_tutai" )

	// To proceed, please call in your Titan.
	convRef = AddConversation( "train_call_in_titan_nag" )
	AddVDURadio( convRef, voGuy, "diag_tut_titanIntro_NP181_01_01_neut_tutai" )

	// Look to the sky to watch your Titan fall into battle.
	convRef = AddConversation( "train_titanfall_lookup" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP203_01_01_neut_tutai" )

	// Get close to your Titan to mount up.
	convRef = AddConversation( "train_titan_mountup" )
	AddVDURadio( convRef, voGuy, "diag_tut_titanIntro_NP182_01_01_neut_tutai" )


	// Titans are designed to be a natural extension of the Pilot
	convRef = AddConversation( "titan_controls_like_pilot" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP204_01_01_neut_tutai" )

	// Firing your Titan's primary weapon is as easy as firing a Pilot weapon.
	convRef = AddConversation( "titan_primary_fire_like_pilot" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP205_01_01_neut_tutai" )

	// Kill the hostiles arriving in drop pods
	convRef = AddConversation( "titan_kill_drop_pod_grunts" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP206_01_01_neut_tutai" )


	// Excellent. Combat scenario complete.
	convRef = AddConversation( "moshpit_done" )
	AddVDURadio( convRef, voGuy, "diag_tut_combat_NP177_01_01_neut_tutai" )

	// Excellent. Your Pilot combat certification is complete.
	convRef = AddConversation( "pilot_cert_done" )
	AddVDURadio( convRef, voGuy, "diag_tut_titanIntro_NP183_01_01_neut_tutai" )  // NOT YET IMPLEMENTED

	local shipCaptain = "graves"

	//All hands, listen up. We're 5 minutes out from Horizon Station.
	//Pilots, this is your stop. You got 10 minutes to collect your gear and get off my boat.
	convRef = AddConversation( "cabin_PA" )
	AddVDURadio( convRef, shipCaptain, "diag_tut_stationArrival_NP190_01_01_neut_tutcaptain" )
	AddVDURadio( convRef, shipCaptain, "diag_tut_stationArrival_NP191_01_01_neut_tutcaptain" )
	
	//All hands, listen up. We're docking at Horizon Station in 5 minutes.
	//Pilots, you got 10 minutes to collect your gear and get off my boat.
	convRef = AddConversation( "cabin_PA_alt" )
	AddVDURadio( convRef, shipCaptain, "diag_tut_stationArrival_NP189_01_01_neut_tutcaptain" )
	AddVDURadio( convRef, shipCaptain, "diag_tut_stationArrival_NP192_01_01_neut_tutcaptain" )
	
	//Welcome to the Frontier.
	convRef = AddConversation( "cabin_PA_welcome" )
	AddVDURadio( convRef, shipCaptain, "diag_tut_stationArrival_NP193_01_01_neut_tutcaptain" )


	// Titans can Dash laterally to perform fast directional changes.
	convRef = AddConversation( "titan_dash_speed_intro" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP209_01_01_neut_tutai" )

	// The Dash meter is located beneath the crosshair on the Titan cockpit display.
	// Each blue box represents one Dash.
	convRef = AddConversation( "titan_dash_meter" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP210_01_01_neut_tutai" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP211_01_01_neut_tutai" )

	// Dash energy refills over time, so watch the Dash Meter to know when you can Dash again.
	convRef = AddConversation( "titan_dash_meter_2" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP212_01_01_neut_tutai" )

	// To proceed, please dash in any direction you like.
	convRef = AddConversation( "titandash_dash_anydirection" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP351_01_01_neut_tutai" )

	// DASH in any direction.
	convRef = AddConversation( "titandash_dash_anydirection_nag" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP350_01_01_neut_tutai" )


	// Please dash to the left.
	convRef = AddConversation( "titandash_left" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP341_01_01_neut_tutai" )

	// To continue, please dash to the left.
	convRef = AddConversation( "titandash_left_nag" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP342_01_01_neut_tutai" )

	// Dash to your right.
	convRef = AddConversation( "titandash_right" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP343_01_01_neut_tutai" )

	// To proceed, dash to the right.
	convRef = AddConversation( "titandash_right_nag" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP344_01_01_neut_tutai" )

	// Dash forward.
	convRef = AddConversation( "titandash_forward" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP345_01_01_neut_tutai" )

	// To continue, dash forward.
	convRef = AddConversation( "titandash_forward_nag" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP347_01_01_neut_tutai" )

	// Dash backwards.
	convRef = AddConversation( "titandash_back" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP348_01_01_neut_tutai" )

	// To proceed, dash backwards.
	convRef = AddConversation( "titandash_back_nag" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP349_01_01_neut_tutai" )

	// Please proceed to the exit.
	convRef = AddConversation( "titandash_move_forward" )
	AddVDURadio( convRef, voGuy, "diag_tut_cloaking_NP187_01_01_neut_tutai" )



	// Titans frequently DASH to avoid threats in combat.
	// Move down the hallway while avoiding the rockets.
	convRef = AddConversation( "titan_dash_threat" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP213_01_01_neut_tutai" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP214_01_01_neut_tutai" )

	// DASH out of the way of the rockets.
	convRef = AddConversation( "titan_dash_hint_nodamage" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP215_01_01_neut_tutai" )


	// To defend against ranged threats, Titans can be equipped with the VORTEX SHIELD.
	// This weapon absorbs incoming ballistics for a limited time, then refires them.
	convRef = AddConversation( "titan_vortex" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP216_01_01_neut_tutai" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP217_01_01_neut_tutai" )

	// Use your VORTEX SHIELD to absorb the projectiles.
	convRef = AddConversation( "titan_vortex_hint_nodamage" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP218_01_01_neut_tutai" )

	// When the Vortex runs out of charge it will REFIRE whatever projectiles it has absorbed.
	convRef = AddConversation( "titan_vortex_refire" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP359_01_01_neut_tutai" )


	// Skilled Pilots often disembark from their Titans on the battlefield.
	convRef = AddConversation( "titan_pet_intro" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP219_01_01_neut_tutai" )

	// To continue, disembark from your Titan.
	convRef = AddConversation( "titan_pet_disembark" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP389_01_01_neut_tutai" )

	// Head into the control room to open the gate for your Titan.
	convRef = AddConversation( "titan_pet_go_hack" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP220_01_01_neut_tutai" )

	// Pilots can control their Titan's AI when they are on foot. The AI can be toggled to FOLLOW you, or GUARD its current location.
	convRef = AddConversation( "titan_aimode_intro" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP221_01_01_neut_tutai" )


	//The lower RIGHT corner of your Pilot HUD displays your Titan's current AI mode.
	convRef = AddConversation( "titan_aimode_hud" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP250_01_01_neut_tutai" )

	// Put your Titan into FOLLOW mode and it will follow you through the gate.
	convRef = AddConversation( "titan_pet_toggle_follow" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP223_01_01_neut_tutai" )

	// When your Titan is in FOLLOW mode it will try to stay close to your position.
	convRef = AddConversation( "titan_pet_follow_info" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP224_01_01_neut_tutai" )

	// Get close to your Titan, and re-embark.
	convRef = AddConversation( "titan_pet_reembark" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP225_01_01_neut_tutai" )

	// To continue, pilot your Titan to the exit.
	convRef = AddConversation( "titan_pet_exit" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP226_01_01_neut_tutai" )


	// Titans also carry OFFHAND WEAPONS into combat.
	// These weapons can be fired at times when primary weapons are unavailable, which enhances your Titan's combat effectiveness.
	convRef = AddConversation( "offhand_rocket_intro" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP227_01_01_neut_tutai" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP228_01_01_neut_tutai" )

	// Your Titan has been equipped with the ROCKET SALVO.
	convRef = AddConversation( "offhand_rocket_fire_name" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP229_01_01_neut_tutai" )

	// Try firing your ROCKET SALVO now.
	convRef = AddConversation( "offhand_rocket_fire_direction" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP230_01_01_neut_tutai" )

	// Be sure to deploy offhand weapons to maximize your firepower in combat.
	convRef = AddConversation( "offhand_rocket_fire_finish" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP231_03_01_neut_tutai" )


	// Prepare for final combat test. Try to use all of the skills you have learned.
	convRef = AddConversation( "titan_mosh_intro" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP232_01_01_neut_tutai" )

	// ALERT! Titan combat scenario initialized.
	// Survive for as long as possible.
	convRef = AddConversation( "titan_mosh_start" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP233_01_01_neut_tutai" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP234_01_01_neut_tutai" )


	convRef = AddConversation( "titan_shields_training" )
	// Each Titan has a shield that deflects incoming damage. 
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP365_01_01_neut_tutai" )
	// Your SHIELD BAR wraps above the HEALTH BAR, at the top center of your HUD.
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP366_01_01_neut_tutai" )
	// If you avoid taking damage for a short time, your SHIELDS will recharge. 
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP367_01_01_neut_tutai" )
	// The best Pilots will monitor their Titan's SHIELDS in combat, taking breaks to recharge as necessary.
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP368_01_01_neut_tutai" )

	convRef = AddConversation( "titan_health_training" )
	// Your Titan's HEALTH BAR status is located at the top center of your HUD.
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP362_01_01_neut_tutai" )
	// Notice that when your HEALTH BAR goes down, it will not replenish.
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP364_01_01_neut_tutai" )
	// Once your HEALTH BAR is depleted, your Titan is DOOMED to die shortly.
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP363_01_01_neut_tutai" )


	// Wave survived. Prepare for the next wave.
	convRef = AddConversation( "titan_mosh_wave_survived" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP235_01_01_neut_tutai" )

	// Next wave incoming.
	convRef = AddConversation( "titan_mosh_wave_start" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP236_01_01_neut_tutai" )


	// Enemy Titan shields temporarily disabled.
	convRef = AddConversation( "titan_mosh_wave_shields_disabled" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP369_01_01_neut_tutai" )

	// Enemy Titan shields online. Use caution.
	convRef = AddConversation( "titan_mosh_wave_shields_enabled" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP370_01_01_neut_tutai" )

	// Alert: enemy Titans may now appear with more advanced weapons.
	convRef = AddConversation( "titan_mosh_wave_advanced_weapons" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP371_01_01_neut_tutai" )

	// Enemy Titans will now be equipped with the Vortex Shield.
	convRef = AddConversation( "titan_mosh_wave_vortex" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP372_01_01_neut_tutai" )


	//Maximum threat wave defeated. Exemplary combat skills, Pilot.
	convRef = AddConversation( "titan_mosh_wave_all_survived" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP374_01_01_neut_tutai" )

	//Initiating forced stand-down.
	convRef = AddConversation( "titan_mosh_wave_forced_standdown" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP375_01_01_neut_tutai" )


	//Your Titan is critically damaged. Combat veterans refer to this as "Doomed State". Your Titan will inevitably self-destruct once it is Doomed.
	convRef = AddConversation( "titan_doomed_info" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP391_01_01_neut_tutai" )

	// In this simulation, you have infinite time to eject. This WILL NOT be the case in actual combat.
	convRef = AddConversation( "titan_infinite_doomed_info" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP392_01_01_neut_tutai" )


	// You must EJECT before your Titan goes critical!
	convRef = AddConversation( "titan_doomed_eject" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP238_01_01_neut_tutai" )

	// To continue, please EJECT from your Titan.
	convRef = AddConversation( "titan_eject_nag" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP239_01_01_neut_tutai" )


	// When you eject, you can use the higher vantage point to plan your next move.
	convRef = AddConversation( "titan_eject_in_air" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP361_01_01_neut_tutai" )


	//===== BONUS LINES =====
	// Your chosen route indicates above-average navigational skills.
	// Excellent route, Pilot.
	convRef = AddConversation( "bonus_wallrun_highroad" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP376_01_01_neut_tutai" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP380_01_01_neut_tutai" )

	// Only a few Pilots can wallrun in tight spaces.
	// Your exceptional navigational abilities have been noted.
	convRef = AddConversation( "bonus_wallrun_lowroad" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP377_01_01_neut_tutai" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP379_01_01_neut_tutai" )
	
	// Excellent navigational skills, Pilot.
	convRef = AddConversation( "bonus_nav_excellent" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP378_01_01_neut_tutai" )

	// You made very good time.
	// You appear quite adept at rapid environment navigation.
	convRef = AddConversation( "bonus_doublejump_playground_fasttime" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP381_01_01_neut_tutai" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP382_01_01_neut_tutai" )

	// All targets eliminated without a magazine swap. Your ammunition conservation has been noted.
	convRef = AddConversation( "bonus_firingrange_noreload" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP383_01_01_neut_tutai" )

	// All headshots. You appear quite ready for ranged combat.
	convRef = AddConversation( "bonus_firingrange_headshots" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP384_01_01_neut_tutai" )

	// Four out of four. Nicely done.
	convRef = AddConversation( "bonus_firingrange_no_grenade_misses" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP385_01_01_neut_tutai" )

	// Minimal damage sustained during live fire exercise. Well done.
	convRef = AddConversation( "bonus_moshpit_lowdamage" )
	AddVDURadio( convRef, voGuy, "diag_tut_npeLevel_NP386_01_01_neut_tutai" )
}

// ============== TEMP CONVERSATIONS ================
function RegisterTestConversations()
{
	if ( !IsServer() )
		return

	RegisterTempConversation( "titan_vortex_to_open_door", VO_PRIORITY_GAMESTATE )
	RegisterTempConversation( "titan_vortex_starting_line", VO_PRIORITY_GAMESTATE )

	local convRef = AddTempConversation( "titan_vortex_to_open_door" )
	AddTempConversationLine( convRef, TEACHER, "Please try your VORTEX SHIELD to continue." )	

	local convRef = AddTempConversation( "titan_vortex_starting_line" )
	AddTempConversationLine( convRef, TEACHER, "Move down the hallway with your VORTEX SHIELD active." )

}

function PlayTempConversationToAll( convAlias )
{
	Assert( convAlias in level.tempConvs )

	PlayTempConversationToTeam( convAlias, TEAM_MILITIA )
	PlayTempConversationToTeam( convAlias, TEAM_IMC )
}

function PlayTempConversationToTeam( convAlias, teamID )
{
	Assert( convAlias in level.tempConvs )
	Assert( teamID in level.tempConvs[ convAlias ], "Conversation " + convAlias + " not set up for team " + teamID )

	local players = GetPlayerArrayOfTeam( teamID )

	foreach ( player in players )
	{
		local convRef = level.tempConvs[ convAlias ][ teamID ]
		thread PlayTempConversationToPlayer_Internal( convRef, player )
	}
}

function PlayTempConversationToPlayer( convAlias, player )
{
	Assert( convAlias in level.tempConvs )
	local teamID = player.GetTeam()
	Assert( teamID in level.tempConvs[ convAlias ], "Conversation " + convAlias + " not set up for team " + teamID )

	local convRef = level.tempConvs[ convAlias ][ teamID ]
	thread PlayTempConversationToPlayer_Internal( convRef, player )
}

function PlayTempConversationToPlayer_Internal( convRef, player )
{
	player.Signal( "TempConversationStart" )
	player.EndSignal( "TempConversationStart" )
	player.EndSignal( "Disconnected" )
	level.ent.EndSignal( "ModuleChanging" )

	foreach ( line in convRef.lines )
		TempConversationDisplayLineToPlayer( player, line.speaker, line.text )
}

function TempConversationDisplayLineToPlayer( player, speaker, text )
{
	player.EndSignal( "Disconnected" )

	local xPosPercent = 0.3
	local yPosPercent = 0.7
	local fadeTimeIn = 0.1
	local fadeTimeOut = 0.1
	local output = speaker + ": " + text

	local minHold = 2
	local maxHold = 4
	local minChars = 20
	local maxChars = 60
	local holdTime = GraphCapped( text.len(), minChars, maxChars, minHold, maxHold )

	SendHudMessage( player, output, xPosPercent, yPosPercent, 255, 255, 255, 255, fadeTimeIn, holdTime, fadeTimeOut )

	wait holdTime + fadeTimeOut
}

function RegisterTempConversation( convAlias, priority )
{
	Assert( !( convAlias in level.tempConvs ), "Can't register temp conversation alias name twice: " + convAlias )

	local conv = {}
	conv.priority <- priority
	conv[ TEAM_MILITIA ] <- {}
	conv[ TEAM_IMC ] <- {}

	level.tempConvs[ convAlias ] <- conv
}

function AddTempConversation( convAlias, teamID = TEAM_MILITIA)
{
	Assert( teamID == TEAM_MILITIA || teamID == TEAM_IMC )
	Assert( convAlias in level.tempConvs, "Temp conversation alias " + convAlias + " not yet registered." )

	local convRef = {}
	convRef.lines <- {}

	local idx = level.tempConvs[ convAlias ][ teamID ].len()
	level.tempConvs[ convAlias ][ teamID ] <- convRef

	return convRef
}

function AddTempConversationLine( convRef, speaker, text )
{
	local line = {}
	line.speaker <- speaker
	line.text <- text

	convRef.lines[ convRef.lines.len() ] <- line
}

function AddVDURadio_WithAnim( convRef, character, soundalias, anim = "diag_vdu_default" )
{
	AddVDURadio( convRef, character, soundalias, anim )
}



main()
