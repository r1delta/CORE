
::CF_NOTIFY_STARTED		<- 0x0001
::CF_NOTIFY_PROGRESS	<- 0x0002
::CF_PRIORITY_LOW		<- 0x0004
::CF_PRIORITY_NORMAL	<- 0x0004
::CF_PRIORITY_HIGH		<- 0x0008
//::CF_XXXXXXXX			<- 0x0010
//::CF_XXXXXXXX			<- 0x0020
//::CF_XXXXXXXX			<- 0x0040

const ICON_GRUNT 				= "../ui/menu/challenge_icons/grunt"
const ICON_MARVIN				= "../ui/menu/challenge_icons/marvin"
const ICON_PILOT				= "../ui/menu/challenge_icons/pilot"
const ICON_SPECTRE				= "../ui/menu/challenge_icons/spectre"
const ICON_TITAN				= "../ui/menu/challenge_icons/titan"
const ICON_WALLRUN				= "../ui/menu/challenge_icons/wallrun"
const ICON_WALLHANG				= "../ui/menu/challenge_icons/wallhang"
const ICON_ZIPLINE				= "../ui/menu/challenge_icons/zipline"
const ICON_CLOAKED_PILOT 		= "../ui/menu/challenge_icons/cloaked_pilot"
const ICON_DATA_KNIFE			= "../ui/menu/challenge_icons/data_knife"
const ICON_EJECT				= "../ui/menu/challenge_icons/eject"
const ICON_HEADSHOT				= "../ui/menu/challenge_icons/headshot"
const ICON_HITCH_RIDE			= "../ui/menu/challenge_icons/hitch_ride"
const ICON_RODEO				= "../ui/menu/challenge_icons/rodeo"
const ICON_PET_TITAN			= "../ui/menu/challenge_icons/pet_titan"
const ICON_TIME_PLAYED			= "../ui/menu/challenge_icons/time_played"
const ICON_TIME_PLAYED_PILOT	= "../ui/menu/challenge_icons/time_played_pilot"
const ICON_TIME_PLAYED_TITAN	= "../ui/menu/challenge_icons/time_played_titan"
const ICON_TIME_WALLHANG		= "../ui/menu/challenge_icons/time_wallhang"
const ICON_TITAN_FALL			= "../ui/menu/challenge_icons/titan_fall"
const ICON_GAMES_PLAYED			= "../ui/menu/challenge_icons/games_played"
const ICON_GAMES_WON			= "../ui/menu/challenge_icons/games_won"
const ICON_GAMES_MVP			= "../ui/menu/challenge_icons/games_mvp"
const ICON_DISTANCE				= "../ui/menu/challenge_icons/distance"
const ICON_DISTANCE_PILOT		= "../ui/menu/challenge_icons/distance_pilot"
const ICON_DISTANCE_TITAN		= "../ui/menu/challenge_icons/distance_titan"
const ICON_STEP_CRUSH			= "../ui/menu/challenge_icons/step_crush"
const ICON_WEAPON_KILLS			= "../ui/menu/challenge_icons/weapon_kills"
const ICON_PILOT_MELEE			= "../ui/menu/challenge_icons/pilot_melee"
const ICON_PILOT_EXECUTION		= "../ui/menu/challenge_icons/pilot_execution"
const ICON_TITAN_MELEE			= "../ui/menu/challenge_icons/titan_melee"
const ICON_TITAN_EXECUTION		= "../ui/menu/challenge_icons/titan_execution"
const ICON_CRITICAL_HIT			= "../ui/menu/challenge_icons/critical_hit"
const ICON_FIRST_STRIKE			= "../ui/menu/challenge_icons/first_strike"

level.weaponCategories <- []
level.weaponCategories.append( eChallengeCategory.WEAPON_40MM )
level.weaponCategories.append( eChallengeCategory.WEAPON_XO16 )
level.weaponCategories.append( eChallengeCategory.WEAPON_TITAN_SNIPER )
level.weaponCategories.append( eChallengeCategory.WEAPON_ARC_CANNON )
level.weaponCategories.append( eChallengeCategory.WEAPON_ROCKET_LAUNCHER )
level.weaponCategories.append( eChallengeCategory.WEAPON_TRIPLE_THREAT )
level.weaponCategories.append( eChallengeCategory.WEAPON_SALVO_ROCKETS )
level.weaponCategories.append( eChallengeCategory.WEAPON_HOMING_ROCKETS )
level.weaponCategories.append( eChallengeCategory.WEAPON_DUMBFIRE_ROCKETS )
level.weaponCategories.append( eChallengeCategory.WEAPON_SHOULDER_ROCKETS )
level.weaponCategories.append( eChallengeCategory.WEAPON_SMART_PISTOL )
level.weaponCategories.append( eChallengeCategory.WEAPON_SHOTGUN )
level.weaponCategories.append( eChallengeCategory.WEAPON_R97 )
level.weaponCategories.append( eChallengeCategory.WEAPON_CAR )
level.weaponCategories.append( eChallengeCategory.WEAPON_LMG )
level.weaponCategories.append( eChallengeCategory.WEAPON_RSPN101 )
level.weaponCategories.append( eChallengeCategory.WEAPON_HEMLOK )
level.weaponCategories.append( eChallengeCategory.WEAPON_G2 )
level.weaponCategories.append( eChallengeCategory.WEAPON_DMR )
level.weaponCategories.append( eChallengeCategory.WEAPON_SNIPER )
level.weaponCategories.append( eChallengeCategory.WEAPON_SMR )
level.weaponCategories.append( eChallengeCategory.WEAPON_MGL )
level.weaponCategories.append( eChallengeCategory.WEAPON_ARCHER )
level.weaponCategories.append( eChallengeCategory.WEAPON_DEFENDER )
level.weaponCategories.append( eChallengeCategory.WEAPON_AUTOPISTOL )
level.weaponCategories.append( eChallengeCategory.WEAPON_SEMIPISTOL )
level.weaponCategories.append( eChallengeCategory.WEAPON_WINGMAN )
level.weaponCategories.append( eChallengeCategory.WEAPON_FRAG_GRENADE )
level.weaponCategories.append( eChallengeCategory.WEAPON_EMP_GRENADE )
level.weaponCategories.append( eChallengeCategory.WEAPON_PROXIMITY_MINE )
level.weaponCategories.append( eChallengeCategory.WEAPON_SATCHEL )

level.regenChallenges <- {}
level.dailyChallenges <- {}

function main()
{
	Globalize( CreateChallenges )

	if ( IsClient() )
	{
		PrecacheHUDMaterial( ICON_GRUNT )
		PrecacheHUDMaterial( ICON_MARVIN )
		PrecacheHUDMaterial( ICON_PILOT )
		PrecacheHUDMaterial( ICON_SPECTRE )
		PrecacheHUDMaterial( ICON_TITAN )
		PrecacheHUDMaterial( ICON_WALLRUN )
		PrecacheHUDMaterial( ICON_WALLHANG )
		PrecacheHUDMaterial( ICON_ZIPLINE )
		PrecacheHUDMaterial( ICON_CLOAKED_PILOT )
		PrecacheHUDMaterial( ICON_DATA_KNIFE )
		PrecacheHUDMaterial( ICON_EJECT )
		PrecacheHUDMaterial( ICON_HEADSHOT )
		PrecacheHUDMaterial( ICON_HITCH_RIDE )
		PrecacheHUDMaterial( ICON_RODEO )
		PrecacheHUDMaterial( ICON_PET_TITAN )
		PrecacheHUDMaterial( ICON_TIME_PLAYED )
		PrecacheHUDMaterial( ICON_TIME_PLAYED_PILOT )
		PrecacheHUDMaterial( ICON_TIME_PLAYED_TITAN )
		PrecacheHUDMaterial( ICON_TIME_WALLHANG )
		PrecacheHUDMaterial( ICON_TITAN_FALL )
		PrecacheHUDMaterial( ICON_GAMES_PLAYED )
		PrecacheHUDMaterial( ICON_GAMES_WON )
		PrecacheHUDMaterial( ICON_GAMES_MVP )
		PrecacheHUDMaterial( ICON_DISTANCE )
		PrecacheHUDMaterial( ICON_DISTANCE_PILOT )
		PrecacheHUDMaterial( ICON_DISTANCE_TITAN )
		PrecacheHUDMaterial( ICON_STEP_CRUSH )
		PrecacheHUDMaterial( ICON_WEAPON_KILLS )
		PrecacheHUDMaterial( ICON_PILOT_MELEE )
		PrecacheHUDMaterial( ICON_PILOT_EXECUTION )
		PrecacheHUDMaterial( ICON_TITAN_MELEE )
		PrecacheHUDMaterial( ICON_TITAN_EXECUTION )
		PrecacheHUDMaterial( ICON_CRITICAL_HIT )
		PrecacheHUDMaterial( ICON_FIRST_STRIKE )
	}
}

function CreateChallenges()
{
	SetChallengeCategory( eChallengeCategory.ROOT, "#CHALLENGE_CATEGORY_ROOT" )

	/*#######################################################################
		 ######   ######## ##    ## ######## ########     ###    ##
		##    ##  ##       ###   ## ##       ##     ##   ## ##   ##
		##        ##       ####  ## ##       ##     ##  ##   ##  ##
		##   #### ######   ## ## ## ######   ########  ##     ## ##
		##    ##  ##       ##  #### ##       ##   ##   ######### ##
		##    ##  ##       ##   ### ##       ##    ##  ##     ## ##
		 ######   ######## ##    ## ######## ##     ## ##     ## ########
	#######################################################################*/

	SetChallengeCategory( eChallengeCategory.GENERAL, "#CHALLENGE_CATEGORY_GENERAL", "#CHALLENGE_CATEGORY_DESC_GENERAL", "challenges_1" )

	AddChallenge( "ch_games_played", "#CHALLENGE_GAMES_PLAYED", "#CHALLENGE_GAMES_PLAYED_DESC", ICON_GAMES_PLAYED )
		SetChallengeStat( "game_stats", "game_completed", null )
		SetChallengeTiers( [ 10, 25, 50, 100, 250 ] )
		SetChallengeTierBurnCards( 2, ["bc_double_xp"] )
		SetChallengeTierBurnCards( 3, ["bc_double_xp"] )
		SetChallengeTierBurnCards( 4, ["bc_cloak_forever", "bc_stim_forever", "bc_sonar_forever"] )

	AddChallenge( "ch_games_won", "#CHALLENGE_GAMES_WON", "#CHALLENGE_GAMES_WON_DESC", ICON_GAMES_WON )
		SetChallengeStat( "game_stats", "game_won", null )
		SetChallengeTiers( [ 10, 30, 50, 70, 100 ] )
		SetChallengeTierBurnCards( 2, ["bc_double_xp"] )
		SetChallengeTierBurnCards( 3, ["bc_double_xp"] )
		SetChallengeTierBurnCards( 4, ["bc_cloak_forever", "bc_stim_forever", "bc_sonar_forever"] )

	AddChallenge( "ch_games_mvp", "#CHALLENGE_GAMES_MVP", "#CHALLENGE_GAMES_MVP_DESC", ICON_GAMES_MVP )
		SetChallengeStat( "game_stats", "mvp_total", null )
		SetChallengeTiers( [ 1, 5, 10, 25, 50 ] )
		SetChallengeTierBurnCards( 2, ["bc_double_xp", "bc_fast_movespeed", "bc_auto_sonar"] )
		SetChallengeTierBurnCards( 3, ["bc_super_cloak", "bc_super_stim", "bc_super_sonar"] )
		SetChallengeTierBurnCards( 4, ["bc_cloak_forever", "bc_stim_forever", "bc_sonar_forever"] )

	AddChallenge( "ch_titan_falls", "#CHALLENGE_TITAN_FALLS", "#CHALLENGE_TITAN_FALLS_DESC", ICON_TITAN_FALL )
		SetChallengeStat( "misc_stats", "titanFalls", null )
		SetChallengeTiers( [ 10, 25, 50, 80, 150 ] )
		SetChallengeTierBurnCards( 2, ["bc_free_build_time_1"] )
		SetChallengeTierBurnCards( 3, ["bc_free_build_time_1", "bc_free_build_time_2"] )
		SetChallengeTierBurnCards( 4, ["bc_free_build_time_1", "bc_free_build_time_2", "bc_summon_atlas"] )

	AddChallenge( "ch_rodeos", "#CHALLENGE_RODEOS", "#CHALLENGE_RODEOS_DESC", ICON_RODEO )
		SetChallengeStat( "misc_stats", "rodeos", null )
		SetChallengeTiers( [ 10, 25, 50, 80, 150 ] )
		SetChallengeTierBurnCards( 2, ["bc_smr_m2", "bc_free_build_time_2", "bc_core_charged"] )
		SetChallengeTierBurnCards( 3, ["bc_defender_m2", "bc_minimap_scan", "bc_nuclear_core"] )
		SetChallengeTierBurnCards( 4, ["bc_mgl_m2", "bc_fast_build_2", "bc_core_charged"] )

	AddChallenge( "ch_times_ejected", "#CHALLENGE_TIMES_EJECTED", "#CHALLENGE_TIMES_EJECTED_DESC", ICON_EJECT )
		SetChallengeStat( "misc_stats", "timesEjected", null )
		SetChallengeTiers( [ 10, 25, 50, 100, 250 ] )
		SetChallengeTierBurnCards( 2, ["bc_nuclear_core"] )
		SetChallengeTierBurnCards( 3, ["bc_nuclear_core","bc_nuclear_core"] )
		SetChallengeTierBurnCards( 4, ["bc_nuclear_core","bc_nuclear_core","bc_nuclear_core"] )

	AddChallenge( "ch_spectres_leeched", "#CHALLENGE_SPECTRES_LEECHED", "#CHALLENGE_SPECTRES_LEECHED_DESC", ICON_DATA_KNIFE )
		SetChallengeStat( "misc_stats", "spectreLeeches", null )
		SetChallengeTiers( [ 10, 25, 50, 80, 150 ] )
		SetChallengeTierBurnCards( 2, ["bc_wifi_spectre_hack", "bc_hunt_spectre", "bc_play_spectre"] )
		SetChallengeTierBurnCards( 3, ["bc_wifi_spectre_hack", "bc_hunt_spectre", "bc_play_spectre"] )
		SetChallengeTierBurnCards( 4, ["bc_wifi_spectre_hack", "bc_hunt_spectre", "bc_play_spectre"] )

	/*#######################################################################
					######## #### ##     ## ########
					   ##     ##  ###   ### ##
					   ##     ##  #### #### ##
					   ##     ##  ## ### ## ######
					   ##     ##  ##     ## ##
					   ##     ##  ##     ## ##
					   ##    #### ##     ## ########
	#######################################################################*/

	SetChallengeCategory( eChallengeCategory.TIME, "#CHALLENGE_CATEGORY_TIME", "#CHALLENGE_CATEGORY_DESC_TIME", "challenges_2" )

	AddChallenge( "ch_hours_played", "#CHALLENGE_HOURS_PLAYED", "#CHALLENGE_HOURS_PLAYED_DESC", ICON_TIME_PLAYED, null, true )
		SetChallengeStat( "time_stats", "hours_total", null )
		SetChallengeTiers( [ 1, 10, 20, 40, 60 ] )
		SetChallengeTierBurnCards( 2, ["bc_cloak_forever", "bc_stim_forever", "bc_sonar_forever"] )
		SetChallengeTierBurnCards( 3, ["bc_cloak_forever", "bc_stim_forever", "bc_sonar_forever"] )
		SetChallengeTierBurnCards( 4, ["bc_cloak_forever", "bc_stim_forever", "bc_sonar_forever"] )

	AddChallenge( "ch_hours_played_pilot", "#CHALLENGE_HOURS_PLAYED_PILOT", "#CHALLENGE_HOURS_PLAYED_PILOT_DESC", ICON_TIME_PLAYED_PILOT, null, true )
		SetChallengeStat( "time_stats", "hours_as_pilot", null )
		SetChallengeTiers( [ 1, 5, 10, 20, 40 ] )
		SetChallengeTierBurnCards( 2, ["bc_minimap_scan", "bc_minimap"] )
		SetChallengeTierBurnCards( 3, ["bc_minimap_scan", "bc_minimap"] )
		SetChallengeTierBurnCards( 4, ["bc_minimap_scan", "bc_minimap"] )

	AddChallenge( "ch_hours_played_titan", "#CHALLENGE_HOURS_PLAYED_TITAN", "#CHALLENGE_HOURS_PLAYED_TITAN_DESC", ICON_TIME_PLAYED_TITAN, null, true )
		SetChallengeStat( "time_stats", "hours_as_titan", null )
		SetChallengeTiers( [ 1, 2, 5, 10, 20 ] )
		SetChallengeTierBurnCards( 2, ["bc_free_build_time_2", "bc_core_charged"] )
		SetChallengeTierBurnCards( 3, ["bc_free_build_time_2", "bc_core_charged"] )
		SetChallengeTierBurnCards( 4, ["bc_free_build_time_2", "bc_core_charged"] )

	AddChallenge( "ch_hours_wallhang", "#CHALLENGE_HOURS_WALLHANG", "#CHALLENGE_HOURS_WALLHANG_DESC", ICON_TIME_WALLHANG, null, true )
		SetChallengeStat( "time_stats", "hours_wallhanging", null )
		SetChallengeTiers( [ 0.1, 0.25, 0.5, 1.0, 1.5 ] )
		SetChallengeTierBurnCards( 2, ["bc_pilot_warning"] )
		SetChallengeTierBurnCards( 3, ["bc_pilot_warning"] )
		SetChallengeTierBurnCards( 4, ["bc_pilot_warning"] )

	/*#######################################################################
	  ########  ####  ######  ########    ###    ##    ##  ######  ########
	  ##     ##  ##  ##    ##    ##      ## ##   ###   ## ##    ## ##
	  ##     ##  ##  ##          ##     ##   ##  ####  ## ##       ##
	  ##     ##  ##   ######     ##    ##     ## ## ## ## ##       ######
	  ##     ##  ##        ##    ##    ######### ##  #### ##       ##
	  ##     ##  ##  ##    ##    ##    ##     ## ##   ### ##    ## ##
	  ########  ####  ######     ##    ##     ## ##    ##  ######  ########
	#######################################################################*/

	SetChallengeCategory( eChallengeCategory.DISTANCE, "#CHALLENGE_CATEGORY_DISTANCE", "#CHALLENGE_CATEGORY_DESC_DISTANCE", "challenges_3" )

	AddChallenge( "ch_dist_total", "#CHALLENGE_DISTANCE_TOTAL", "#CHALLENGE_DISTANCE_TOTAL_DESC", ICON_DISTANCE, null, true )
		SetChallengeStat( "distance_stats", "total", null )
		SetChallengeTiers( [ 25, 80, 160, 250, 400 ] )
		SetChallengeTierBurnCards( 2, ["bc_fast_movespeed", "bc_free_build_time_1"] )
		SetChallengeTierBurnCards( 3, ["bc_super_stim", "bc_free_build_time_2", "bc_core_charged"] )
		SetChallengeTierBurnCards( 4, ["bc_stim_forever", "bc_summon_ogre", "bc_core_charged"] )

	AddChallenge( "ch_dist_pilot", "#CHALLENGE_DISTANCE_PILOT", "#CHALLENGE_DISTANCE_PILOT_DESC", ICON_DISTANCE_PILOT, null, true )
		SetChallengeStat( "distance_stats", "asPilot", null )
		SetChallengeTiers( [ 15, 40, 80, 145, 250 ] )
		SetChallengeTierBurnCards( 2, ["bc_fast_movespeed"] )
		SetChallengeTierBurnCards( 3, ["bc_fast_movespeed", "bc_super_stim"] )
		SetChallengeTierBurnCards( 4, ["bc_fast_movespeed", "bc_super_stim", "bc_stim_forever"] )

	AddChallenge( "ch_dist_titan", "#CHALLENGE_DISTANCE_TITAN", "#CHALLENGE_DISTANCE_TITAN_DESC", ICON_DISTANCE_TITAN, null, true )
		SetChallengeStat( "distance_stats", "asTitan", null )
		SetChallengeTiers( [ 8, 25, 50, 80, 130 ] )
		SetChallengeTierBurnCards( 2, ["bc_free_build_time_1", "bc_core_charged"] )
		SetChallengeTierBurnCards( 3, ["bc_free_build_time_2", "bc_core_charged"] )
		SetChallengeTierBurnCards( 4, ["bc_summon_stryder", "bc_core_charged"] )

	AddChallenge( "ch_dist_wallrun", "#CHALLENGE_DISTANCE_WALLRUN", "#CHALLENGE_DISTANCE_WALLRUN_DESC", ICON_WALLRUN, null, true )
		SetChallengeStat( "distance_stats", "wallrunning", null )
		SetChallengeTiers( [ 0.5, 1.0, 1.5, 2.5, 4.0 ] )
		SetChallengeTierBurnCards( 2, ["bc_fast_movespeed"] )
		SetChallengeTierBurnCards( 3, ["bc_fast_movespeed", "bc_super_stim"] )
		SetChallengeTierBurnCards( 4, ["bc_fast_movespeed", "bc_super_stim", "bc_stim_forever"] )

	AddChallenge( "ch_dist_inair", "#CHALLENGE_DISTANCE_INAIR", "#CHALLENGE_DISTANCE_INAIR_DESC", ICON_DISTANCE, null, true )
		SetChallengeStat( "distance_stats", "inAir", null )
		SetChallengeTiers( [ 8, 25, 50, 75, 100 ] )
		SetChallengeTierBurnCards( 2, ["bc_double_xp"] )
		SetChallengeTierBurnCards( 3, ["bc_double_xp"] )
		SetChallengeTierBurnCards( 4, ["bc_double_xp"] )

	AddChallenge( "ch_dist_zipline", "#CHALLENGE_DISTANCE_ZIPLINE", "#CHALLENGE_DISTANCE_ZIPLINE_DESC", ICON_ZIPLINE, null, true )
		SetChallengeStat( "distance_stats", "ziplining", null )
		SetChallengeTiers( [ 0.25, 1.0, 1.5, 3.0, 5.0 ] )
		SetChallengeTierBurnCards( 2, ["bc_double_xp"] )
		SetChallengeTierBurnCards( 3, ["bc_double_xp"] )
		SetChallengeTierBurnCards( 4, ["bc_double_xp"] )

	AddChallenge( "ch_dist_on_friendly_titan", "#CHALLENGE_DISTANCE_ON_FRIENDLY_TITAN", "#CHALLENGE_DISTANCE_ON_FRIENDLY_TITAN_DESC", ICON_HITCH_RIDE, null, true )
		SetChallengeStat( "distance_stats", "onFriendlyTitan", null )
		SetChallengeTiers( [ 0.1, 0.25, 1.0, 1.5, 2.5 ] )
		SetChallengeTierBurnCards( 2, ["bc_hunt_titan", "bc_mgl_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_hunt_titan", "bc_mgl_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_hunt_titan", "bc_mgl_m2"] )

	AddChallenge( "ch_dist_on_enemy_titan", "#CHALLENGE_DISTANCE_ON_ENEMY_TITAN", "#CHALLENGE_DISTANCE_ON_ENEMY_TITAN_DESC", ICON_RODEO, null, true )
		SetChallengeStat( "distance_stats", "onEnemyTitan", null )
		SetChallengeTiers( [ 0.1, 0.25, 1.0, 1.5, 2.5 ] )
		SetChallengeTierBurnCards( 2, ["bc_hunt_titan", "bc_lmg_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_hunt_titan", "bc_lmg_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_hunt_titan", "bc_lmg_m2"] )

	/*#######################################################################
					##    ## #### ##       ##        ######
					##   ##   ##  ##       ##       ##    ##
					##  ##    ##  ##       ##       ##
					#####     ##  ##       ##        ######
					##  ##    ##  ##       ##             ##
					##   ##   ##  ##       ##       ##    ##
					##    ## #### ######## ########  ######
	#######################################################################*/

	SetChallengeCategory( eChallengeCategory.KILLS, "#CHALLENGE_CATEGORY_KILLS", "#CHALLENGE_CATEGORY_DESC_KILLS", "challenges_4" )

	AddChallenge( "ch_grunt_kills", "#CHALLENGE_GRUNT_KILLS", "#CHALLENGE_GRUNT_KILLS_DESC", ICON_GRUNT )
		SetChallengeStat( "kills_stats", "grunts", null )
		SetChallengeTiers( [ 25, 100, 250, 500, 1000 ] )
		SetChallengeTierBurnCards( 2, ["bc_hunt_soldier"] )
		SetChallengeTierBurnCards( 3, ["bc_hunt_soldier", "bc_double_agent"] )
		SetChallengeTierBurnCards( 4, ["bc_hunt_soldier", "bc_double_agent", "bc_conscription"] )

	AddChallenge( "ch_spectre_kills", "#CHALLENGE_SPECTRE_KILLS", "#CHALLENGE_SPECTRE_KILLS_DESC", ICON_SPECTRE )
		SetChallengeStat( "kills_stats", "spectres", null )
		SetChallengeTiers( [ 25, 100, 200, 300, 400 ] )
		SetChallengeTierBurnCards( 2, ["bc_hunt_spectre"] )
		SetChallengeTierBurnCards( 3, ["bc_hunt_spectre", "bc_play_spectre"] )
		SetChallengeTierBurnCards( 4, ["bc_hunt_spectre", "bc_play_spectre", "bc_wifi_spectre_hack"] )

	AddChallenge( "ch_marvin_kills", "#CHALLENGE_MARVIN_KILLS", "#CHALLENGE_MARVIN_KILLS_DESC", ICON_MARVIN )
		SetChallengeStat( "kills_stats", "marvins", null )
		SetChallengeTiers( [ 10, 25, 50, 100, 250 ] )

	AddChallenge( "ch_first_strikes", "#CHALLENGE_FIRST_STRIKES", "#CHALLENGE_FIRST_STRIKES_DESC", ICON_FIRST_STRIKE )
		SetChallengeStat( "kills_stats", "firstStrikes", null )
		SetChallengeTiers( [ 1, 10, 25, 50, 100 ] )
		SetChallengeTierBurnCards( 2, ["bc_rematch", ] )
		SetChallengeTierBurnCards( 3, ["bc_rematch", "bc_rematch"] )
		SetChallengeTierBurnCards( 4, ["bc_rematch", "bc_rematch", "bc_rematch"] )

	AddChallenge( "ch_cloaked_pilot_kills", "#CHALLENGE_CLOAKED_PILOT_KILLS", "#CHALLENGE_CLOAKED_PILOT_KILLS_DESC", ICON_CLOAKED_PILOT )
		SetChallengeStat( "kills_stats", "cloakedPilots", null )
		SetChallengeTiers( [ 5, 15, 30, 50, 100 ] )
		SetChallengeTierBurnCards( 2, ["bc_pilot_warning"] )
		SetChallengeTierBurnCards( 3, ["bc_pilot_warning", "bc_minimap_scan"] )
		SetChallengeTierBurnCards( 4, ["bc_pilot_warning", "bc_minimap_scan", "bc_minimap"] )

	AddChallenge( "ch_kills_while_cloaked", "#CHALLENGE_KILLS_WHILE_CLOAKED", "#CHALLENGE_KILLS_WHILE_CLOAKED_DESC", ICON_CLOAKED_PILOT )
		SetChallengeStat( "kills_stats", "whileCloaked", null )
		SetChallengeTiers( [ 10, 25, 50, 100, 200 ] )
		SetChallengeTierBurnCards( 2, ["bc_double_agent"] )
		SetChallengeTierBurnCards( 3, ["bc_double_agent", "bc_super_cloak"] )
		SetChallengeTierBurnCards( 4, ["bc_double_agent", "bc_super_cloak", "bc_cloak_forever"] )

	AddChallenge( "ch_titanFallKill", "#CHALLENGE_TITAN_FALL_KILL", "#CHALLENGE_TITAN_FALL_KILL_DESC", ICON_TITAN_FALL )
		SetChallengeStat( "kills_stats", "titanFallKill", null )
		SetChallengeTiers( [ 1, 5, 15, 30, 50 ] )
		SetChallengeTierBurnCards( 2, ["bc_summon_atlas"] )
		SetChallengeTierBurnCards( 3, ["bc_summon_atlas", "bc_summon_stryder"] )
		SetChallengeTierBurnCards( 4, ["bc_summon_atlas", "bc_summon_stryder", "bc_summon_ogre"] )

	AddChallenge( "ch_petTitanKillsFollowMode", "#CHALLENGE_PET_TITAN_KILLS_ATTACK_MODE", "#CHALLENGE_PET_TITAN_KILLS_ATTACK_MODE_DESC", ICON_PET_TITAN )
		SetChallengeStat( "kills_stats", "petTitanKillsFollowMode", null )
		SetChallengeTiers( [ 10, 25, 50, 100, 200 ] )
		SetChallengeTierBurnCards( 2, ["bc_hunt_titan"] )
		SetChallengeTierBurnCards( 3, ["bc_hunt_titan", "bc_free_build_time_1"] )
		SetChallengeTierBurnCards( 4, ["bc_hunt_titan", "bc_free_build_time_2"] )

	AddChallenge( "ch_petTitanKillsGuardMode", "#CHALLENGE_PET_TITAN_KILLS_GUARD_MODE", "#CHALLENGE_PET_TITAN_KILLS_GUARD_MODE_DESC", ICON_PET_TITAN )
		SetChallengeStat( "kills_stats", "petTitanKillsGuardMode", null )
		SetChallengeTiers( [ 10, 25, 50, 100, 200 ] )
		SetChallengeTierBurnCards( 2, ["bc_hunt_titan"] )
		SetChallengeTierBurnCards( 3, ["bc_hunt_titan", "bc_free_build_time_1"] )
		SetChallengeTierBurnCards( 4, ["bc_hunt_titan", "bc_free_build_time_2"] )

	/*#######################################################################
		##     ##  #######  ########  #### ##       #### ######## ##    ##
		###   ### ##     ## ##     ##  ##  ##        ##     ##     ##  ##
		#### #### ##     ## ##     ##  ##  ##        ##     ##      ####
		## ### ## ##     ## ########   ##  ##        ##     ##       ##
		##     ## ##     ## ##     ##  ##  ##        ##     ##       ##
		##     ## ##     ## ##     ##  ##  ##        ##     ##       ##
		##     ##  #######  ########  #### ######## ####    ##       ##

					##    ## #### ##       ##        ######
					##   ##   ##  ##       ##       ##    ##
					##  ##    ##  ##       ##       ##
					#####     ##  ##       ##        ######
					##  ##    ##  ##       ##             ##
					##   ##   ##  ##       ##       ##    ##
					##    ## #### ######## ########  ######
	#######################################################################*/

	SetChallengeCategory( eChallengeCategory.MOBILITY_KILLS, "#CHALLENGE_CATEGORY_MOBILITY_KILLS", "#CHALLENGE_CATEGORY_DESC_MOBILITY_KILLS", "challenges_5" )

	AddChallenge( "ch_ejecting_pilot_kills", "#CHALLENGE_EJECTING_PILOT_KILLS", "#CHALLENGE_EJECTING_PILOT_KILLS_DESC", ICON_EJECT )
		SetChallengeStat( "kills_stats", "ejectingPilots", null )
		SetChallengeTiers( [ 1, 2, 3, 4, 5 ] )
		SetChallengeTierBurnCards( 2, ["bc_nuclear_core"] )
		SetChallengeTierBurnCards( 3, ["bc_nuclear_core"] )
		SetChallengeTierBurnCards( 4, ["bc_nuclear_core"] )

	AddChallenge( "ch_kills_while_ejecting", "#CHALLENGE_KILLS_WHILE_EJECTING", "#CHALLENGE_KILLS_WHILE_EJECTING_DESC", ICON_EJECT )
		SetChallengeStat( "kills_stats", "whileEjecting", null )
		SetChallengeTiers( [ 5, 15, 30, 50, 75 ] )
		SetChallengeTierBurnCards( 2, ["bc_nuclear_core"] )
		SetChallengeTierBurnCards( 3, ["bc_nuclear_core"] )
		SetChallengeTierBurnCards( 4, ["bc_nuclear_core"] )

	AddChallenge( "ch_wallrunning_pilot_kills", "#CHALLENGE_WALLRUNNING_PILOT_KILLS", "#CHALLENGE_WALLRUNNING_PILOT_KILLS_DESC", ICON_WALLRUN )
		SetChallengeStat( "kills_stats", "wallrunningPilots", null )
		SetChallengeTiers( [ 1, 5, 15, 30, 50 ] )
		SetChallengeTierBurnCards( 2, ["bc_hunt_pilot"] )
		SetChallengeTierBurnCards( 3, ["bc_hunt_pilot"] )
		SetChallengeTierBurnCards( 4, ["bc_hunt_pilot"] )

	AddChallenge( "ch_wallhanging_pilot_kills", "#CHALLENGE_WALLHANGING_PILOT_KILLS", "#CHALLENGE_WALLHANGING_PILOT_KILLS_DESC", ICON_WALLHANG )
		SetChallengeStat( "kills_stats", "wallhangingPilots", null )
		SetChallengeTiers( [ 1, 5, 15, 30, 50 ] )
		SetChallengeTierBurnCards( 2, ["bc_hunt_pilot"] )
		SetChallengeTierBurnCards( 3, ["bc_hunt_pilot"] )
		SetChallengeTierBurnCards( 4, ["bc_hunt_pilot"] )

	AddChallenge( "ch_kills_while_wallrunning", "#CHALLENGE_KILLS_WHILE_WALLRUNNING", "#CHALLENGE_KILLS_WHILE_WALLRUNNING_DESC", ICON_WALLRUN )
		SetChallengeStat( "kills_stats", "whileWallrunning", null )
		SetChallengeTiers( [ 5, 15, 30, 50, 75 ] )
		SetChallengeTierBurnCards( 2, ["bc_minimap_scan"] )
		SetChallengeTierBurnCards( 3, ["bc_minimap_scan", "bc_minimap_scan"] )
		SetChallengeTierBurnCards( 4, ["bc_minimap_scan", "bc_minimap_scan", "bc_minimap"] )

	AddChallenge( "ch_kills_while_wallhanging", "#CHALLENGE_KILLS_WHILE_WALLHANGING", "#CHALLENGE_KILLS_WHILE_WALLHANGING_DESC", ICON_WALLHANG )
		SetChallengeStat( "kills_stats", "whileWallhanging", null )
		SetChallengeTiers( [ 5, 15, 30, 50, 75 ] )
		SetChallengeTierBurnCards( 2, ["bc_double_agent"] )
		SetChallengeTierBurnCards( 3, ["bc_double_agent", "bc_super_cloak"] )
		SetChallengeTierBurnCards( 4, ["bc_double_agent", "bc_super_cloak", "bc_cloak_forever"] )

	AddChallenge( "ch_titanStepCrush", "#CHALLENGE_TITAN_STEP_CRUSH", "#CHALLENGE_TITAN_STEP_CRUSH_DESC", ICON_STEP_CRUSH )
		SetChallengeStat( "kills_stats", "titanStepCrush", null )
		SetChallengeTiers( [ 25, 50, 100, 200, 500 ] )
		SetChallengeTierBurnCards( 2, ["bc_double_xp"] )
		SetChallengeTierBurnCards( 3, ["bc_double_xp"] )
		SetChallengeTierBurnCards( 4, ["bc_double_xp"] )

	AddChallenge( "ch_titanStepCrushPilot", "#CHALLENGE_TITAN_STEP_CRUSH_PILOT", "#CHALLENGE_TITAN_STEP_CRUSH_PILOT_DESC", ICON_STEP_CRUSH )
		SetChallengeStat( "kills_stats", "titanStepCrushPilot", null )
		SetChallengeTiers( [ 5, 15, 30, 50, 100 ] )
		SetChallengeTierBurnCards( 2, ["bc_double_xp"] )
		SetChallengeTierBurnCards( 3, ["bc_double_xp"] )
		SetChallengeTierBurnCards( 4, ["bc_double_xp"] )

	AddChallenge( "ch_rodeo_kills", "#CHALLENGE_RODEO_KILLS", "#CHALLENGE_RODEO_KILLS_DESC", ICON_RODEO )
		SetChallengeStat( "kills_stats", "rodeo_total", null )
		SetChallengeTiers( [ 1, 5, 15, 30, 50 ] )
		SetChallengeTierBurnCards( 2, ["bc_hunt_titan"] )
		SetChallengeTierBurnCards( 3, ["bc_hunt_titan"] )
		SetChallengeTierBurnCards( 4, ["bc_hunt_titan"] )

	/*#######################################################################
				  ##     ## ######## ##       ######## ########
				  ###   ### ##       ##       ##       ##
				  #### #### ##       ##       ##       ##
				  ## ### ## ######   ##       ######   ######
				  ##     ## ##       ##       ##       ##
				  ##     ## ##       ##       ##       ##
				  ##     ## ######## ######## ######## ########

					##    ## #### ##       ##        ######
					##   ##   ##  ##       ##       ##    ##
					##  ##    ##  ##       ##       ##
					#####     ##  ##       ##        ######
					##  ##    ##  ##       ##             ##
					##   ##   ##  ##       ##       ##    ##
					##    ## #### ######## ########  ######
	#######################################################################*/

	SetChallengeCategory( eChallengeCategory.MELEE_KILLS, "#CHALLENGE_CATEGORY_MELEE_KILLS", "#CHALLENGE_CATEGORY_DESC_MELEE_KILLS", "challenges_6" )

	AddChallenge( "ch_pilotExecutePilot", "#CHALLENGE_PILOT_EXECUTE_PILOT", "#CHALLENGE_PILOT_EXECUTE_PILOT_DESC", ICON_PILOT_EXECUTION )
		SetChallengeStat( "kills_stats", "pilotExecutePilot", null )
		SetChallengeTiers( [ 5, 15, 30, 50, 100 ] )
		SetChallengeTierBurnCards( 2, ["bc_hunt_pilot"] )
		SetChallengeTierBurnCards( 3, ["bc_hunt_pilot"] )
		SetChallengeTierBurnCards( 4, ["bc_hunt_pilot"] )

	AddChallenge( "ch_pilotKickMelee", "#CHALLENGE_PILOT_KICK_MELEE", "#CHALLENGE_PILOT_KICK_MELEE_DESC", ICON_PILOT_MELEE )
		SetChallengeStat( "kills_stats", "pilotKickMelee", null )
		SetChallengeTiers( [ 10, 25, 50, 100, 200 ] )
		SetChallengeTierBurnCards( 2, ["bc_hunt_pilot"] )
		SetChallengeTierBurnCards( 3, ["bc_hunt_pilot"] )
		SetChallengeTierBurnCards( 4, ["bc_hunt_pilot"] )

	AddChallenge( "ch_pilotKickMeleePilot", "#CHALLENGE_PILOT_KICK_MELEE_PILOT", "#CHALLENGE_PILOT_KICK_MELEE_PILOT_DESC", ICON_PILOT_MELEE )
		SetChallengeStat( "kills_stats", "pilotKickMeleePilot", null )
		SetChallengeTiers( [ 10, 25, 50, 100, 200 ] )
		SetChallengeTierBurnCards( 2, ["bc_hunt_pilot"] )
		SetChallengeTierBurnCards( 3, ["bc_hunt_pilot"] )
		SetChallengeTierBurnCards( 4, ["bc_hunt_pilot"] )

	AddChallenge( "ch_titanMelee", "#CHALLENGE_TITAN_MELEE", "#CHALLENGE_TITAN_MELEE_DESC", ICON_TITAN_MELEE )
		SetChallengeStat( "kills_stats", "titanMelee", null )
		SetChallengeTiers( [ 5, 20, 50, 100, 200 ] )
		SetChallengeTierBurnCards( 2, ["bc_hunt_titan"] )
		SetChallengeTierBurnCards( 3, ["bc_hunt_titan"] )
		SetChallengeTierBurnCards( 4, ["bc_hunt_titan"] )

	AddChallenge( "ch_titanMeleePilot", "#CHALLENGE_TITAN_MELEE_PILOT", "#CHALLENGE_TITAN_MELEE_PILOT_DESC", ICON_TITAN_MELEE )
		SetChallengeStat( "kills_stats", "titanMeleePilot", null )
		SetChallengeTiers( [ 5, 15, 30, 50, 100 ] )
		SetChallengeTierBurnCards( 2, ["bc_hunt_titan"] )
		SetChallengeTierBurnCards( 3, ["bc_hunt_titan"] )
		SetChallengeTierBurnCards( 4, ["bc_hunt_titan"] )

	AddChallenge( "ch_titanExocutionStryder", "#CHALLENGE_TITAN_EXECUTION_STRYDER", "#CHALLENGE_TITAN_EXECUTION_STRYDER_DESC", ICON_TITAN_EXECUTION )
		SetChallengeStat( "kills_stats", "titanExocutionStryder", null )
		SetChallengeTiers( [ 1, 5, 10, 15, 25 ] )
		SetChallengeTierBurnCards( 2, ["bc_hunt_titan"] )
		SetChallengeTierBurnCards( 3, ["bc_hunt_titan"] )
		SetChallengeTierBurnCards( 4, ["bc_hunt_titan"] )

	AddChallenge( "ch_titanExocutionAtlas", "#CHALLENGE_TITAN_EXECUTION_ATLAS", "#CHALLENGE_TITAN_EXECUTION_ATLAS_DESC", ICON_TITAN_EXECUTION )
		SetChallengeStat( "kills_stats", "titanExocutionAtlas", null )
		SetChallengeTiers( [ 1, 5, 10, 15, 25 ] )
		SetChallengeTierBurnCards( 2, ["bc_hunt_titan"] )
		SetChallengeTierBurnCards( 3, ["bc_hunt_titan"] )
		SetChallengeTierBurnCards( 4, ["bc_hunt_titan"] )

	AddChallenge( "ch_titanExocutionOgre", "#CHALLENGE_TITAN_EXECUTION_OGRE", "#CHALLENGE_TITAN_EXECUTION_OGRE_DESC", ICON_TITAN_EXECUTION )
		SetChallengeStat( "kills_stats", "titanExocutionOgre", null )
		SetChallengeTiers( [ 1, 5, 10, 15, 25 ] )
		SetChallengeTierBurnCards( 2, ["bc_hunt_titan"] )
		SetChallengeTierBurnCards( 3, ["bc_hunt_titan"] )
		SetChallengeTierBurnCards( 4, ["bc_hunt_titan"] )

	/*#######################################################################
				######## #### ########    ###    ##    ##
				   ##     ##     ##      ## ##   ###   ##
				   ##     ##     ##     ##   ##  ####  ##
				   ##     ##     ##    ##     ## ## ## ##
				   ##     ##     ##    ######### ##  ####
				   ##     ##     ##    ##     ## ##   ###
				   ##    ####    ##    ##     ## ##    ##

		########  ########  #### ##     ##    ###    ########  ##    ##
		##     ## ##     ##  ##  ###   ###   ## ##   ##     ##  ##  ##
		##     ## ##     ##  ##  #### ####  ##   ##  ##     ##   ####
		########  ########   ##  ## ### ## ##     ## ########     ##
		##        ##   ##    ##  ##     ## ######### ##   ##      ##
		##        ##    ##   ##  ##     ## ##     ## ##    ##     ##
		##        ##     ## #### ##     ## ##     ## ##     ##    ##
	#######################################################################*/
	local linkedCategories = 	[
									eChallengeCategory.WEAPON_XO16,
									eChallengeCategory.WEAPON_40MM,
									eChallengeCategory.WEAPON_ROCKET_LAUNCHER,
									eChallengeCategory.WEAPON_TITAN_SNIPER,
									eChallengeCategory.WEAPON_ARC_CANNON,
									eChallengeCategory.WEAPON_TRIPLE_THREAT,
								]
	SetChallengeCategory( eChallengeCategory.TITAN_PRIMARY, "#CHALLENGE_CATEGORY_TITAN_PRIMARY", "#CHALLENGE_CATEGORY_DESC_TITAN_PRIMARY", "edit_titans", linkedCategories )

	local goals_kills 			= [ 10, 25, 50, 100, 200 ]
	local goals_pilot_kills 	= [ 5, 15, 30, 50, 75 ]
	local goals_titan_kills 	= [ 10, 20, 30, 40, 50 ]
	local goals_spectre_kills 	= [ 10, 25, 50, 75, 100 ]
	local goals_grunt_kills		= [ 10, 25, 50, 100, 200 ]
	local goals_hours_used		= [ 0.5, 1.0, 1.5, 2.0, 3.0 ]
	local goals_headshots		= [ 5, 15, 30, 50, 75 ]
	local goals_crits			= [ 5, 15, 30, 50, 75 ]

	//------------------
	// 		40mm
	//------------------

	local weaponRef = "mp_titanweapon_40mm"
	SetChallengeCategory( eChallengeCategory.WEAPON_40MM, "#WPN_TITAN_40MM", "", weaponRef )

	AddChallenge( "ch_40mm_kills", "#CHALLENGE_WEAPON_KILLS", "#CHALLENGE_WEAPON_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( goals_kills )

	AddChallenge( "ch_40mm_pilot_kills", "#CHALLENGE_WEAPON_PILOT_KILLS", "#CHALLENGE_WEAPON_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( goals_pilot_kills )
		SetChallengeTierBurnCards( 2, ["bc_hunt_pilot"] )
		SetChallengeTierBurnCards( 3, ["bc_hunt_pilot"] )
		SetChallengeTierBurnCards( 4, ["bc_hunt_pilot"] )

	AddChallenge( "ch_40mm_titan_kills", "#CHALLENGE_WEAPON_TITAN_KILLS", "#CHALLENGE_WEAPON_TITAN_KILLS_DESC", ICON_TITAN, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "titansTotal", weaponRef )
		SetChallengeTiers( goals_titan_kills )
		SetChallengeTierBurnCards( 2, ["bc_hunt_titan"] )
		SetChallengeTierBurnCards( 3, ["bc_hunt_titan"] )
		SetChallengeTierBurnCards( 4, ["bc_hunt_titan"] )

	AddChallenge( "ch_40mm_spectre_kills", "#CHALLENGE_WEAPON_SPECTRE_KILLS", "#CHALLENGE_WEAPON_SPECTRE_KILLS_DESC", ICON_SPECTRE, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "spectres", weaponRef )
		SetChallengeTiers( goals_spectre_kills )
		SetChallengeTierBurnCards( 2, ["bc_hunt_spectre"] )
		SetChallengeTierBurnCards( 3, ["bc_hunt_spectre"] )
		SetChallengeTierBurnCards( 4, ["bc_hunt_spectre"] )

	AddChallenge( "ch_40mm_grunt_kills", "#CHALLENGE_WEAPON_GRUNT_KILLS", "#CHALLENGE_WEAPON_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( goals_grunt_kills )
		SetChallengeTierBurnCards( 2, ["bc_hunt_soldier"] )
		SetChallengeTierBurnCards( 3, ["bc_hunt_soldier"] )
		SetChallengeTierBurnCards( 4, ["bc_hunt_soldier"] )

	AddChallenge( "ch_40mm_hours_used", "#CHALLENGE_WEAPON_HOURS_USED", "#CHALLENGE_WEAPON_HOURS_USED_DESC", ICON_TIME_PLAYED, weaponRef, true )
		SetChallengeStat( "weapon_stats", "hoursUsed", weaponRef )
		SetChallengeTiers( goals_hours_used )

	AddChallenge( "ch_40mm_crits", "#CHALLENGE_WEAPON_CRITS", "#CHALLENGE_WEAPON_CRITS_DESC", ICON_CRITICAL_HIT, weaponRef )
		SetChallengeStat( "weapon_stats", "critHits", weaponRef )
		SetChallengeTiers( goals_crits )

	//------------------
	// 		XO-16
	//------------------

	local weaponRef = "mp_titanweapon_xo16"
	SetChallengeCategory( eChallengeCategory.WEAPON_XO16, "#WPN_TITAN_XO16", "", weaponRef )

	AddChallenge( "ch_xo16_kills", "#CHALLENGE_WEAPON_KILLS", "#CHALLENGE_WEAPON_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( goals_kills )

	AddChallenge( "ch_xo16_pilot_kills", "#CHALLENGE_WEAPON_PILOT_KILLS", "#CHALLENGE_WEAPON_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( goals_pilot_kills )
		SetChallengeTierBurnCards( 2, ["bc_hunt_pilot"] )
		SetChallengeTierBurnCards( 3, ["bc_hunt_pilot"] )
		SetChallengeTierBurnCards( 4, ["bc_hunt_pilot"] )

	AddChallenge( "ch_xo16_titan_kills", "#CHALLENGE_WEAPON_TITAN_KILLS", "#CHALLENGE_WEAPON_TITAN_KILLS_DESC", ICON_TITAN, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "titansTotal", weaponRef )
		SetChallengeTiers( goals_titan_kills )
		SetChallengeTierBurnCards( 2, ["bc_hunt_titan"] )
		SetChallengeTierBurnCards( 3, ["bc_hunt_titan"] )
		SetChallengeTierBurnCards( 4, ["bc_hunt_titan"] )

	AddChallenge( "ch_xo16_spectre_kills", "#CHALLENGE_WEAPON_SPECTRE_KILLS", "#CHALLENGE_WEAPON_SPECTRE_KILLS_DESC", ICON_SPECTRE, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "spectres", weaponRef )
		SetChallengeTiers( goals_spectre_kills )
		SetChallengeTierBurnCards( 2, ["bc_hunt_spectre"] )
		SetChallengeTierBurnCards( 3, ["bc_hunt_spectre"] )
		SetChallengeTierBurnCards( 4, ["bc_hunt_spectre"] )

	AddChallenge( "ch_xo16_grunt_kills", "#CHALLENGE_WEAPON_GRUNT_KILLS", "#CHALLENGE_WEAPON_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( goals_grunt_kills )
		SetChallengeTierBurnCards( 2, ["bc_hunt_soldier"] )
		SetChallengeTierBurnCards( 3, ["bc_hunt_soldier"] )
		SetChallengeTierBurnCards( 4, ["bc_hunt_soldier"] )

	AddChallenge( "ch_xo16_hours_used", "#CHALLENGE_WEAPON_HOURS_USED", "#CHALLENGE_WEAPON_HOURS_USED_DESC", ICON_TIME_PLAYED, weaponRef, true )
		SetChallengeStat( "weapon_stats", "hoursUsed", weaponRef )
		SetChallengeTiers( goals_hours_used )

	AddChallenge( "ch_xo16_headshots", "#CHALLENGE_WEAPON_HEADSHOTS", "#CHALLENGE_WEAPON_HEADSHOTS_DESC", ICON_HEADSHOT, weaponRef )
		SetChallengeStat( "weapon_stats", "headshots", weaponRef )
		SetChallengeTiers( goals_headshots )

	AddChallenge( "ch_xo16_crits", "#CHALLENGE_WEAPON_CRITS", "#CHALLENGE_WEAPON_CRITS_DESC", ICON_CRITICAL_HIT, weaponRef )
		SetChallengeStat( "weapon_stats", "critHits", weaponRef )
		SetChallengeTiers( [ 50, 100, 200, 300, 400 ] )

	//------------------
	// 	 Titan Sniper
	//------------------

	local weaponRef = "mp_titanweapon_sniper"
	SetChallengeCategory( eChallengeCategory.WEAPON_TITAN_SNIPER, "#WPN_TITAN_SNIPER", "", weaponRef )

	AddChallenge( "ch_titan_sniper_kills", "#CHALLENGE_WEAPON_KILLS", "#CHALLENGE_WEAPON_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( [ 5, 15, 25, 50, 100 ] )

	AddChallenge( "ch_titan_sniper_pilot_kills", "#CHALLENGE_WEAPON_PILOT_KILLS", "#CHALLENGE_WEAPON_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( [ 1, 5, 10, 15, 25 ] )
		SetChallengeTierBurnCards( 2, ["bc_hunt_pilot"] )
		SetChallengeTierBurnCards( 3, ["bc_hunt_pilot"] )
		SetChallengeTierBurnCards( 4, ["bc_hunt_pilot"] )

	AddChallenge( "ch_titan_sniper_titan_kills", "#CHALLENGE_WEAPON_TITAN_KILLS", "#CHALLENGE_WEAPON_TITAN_KILLS_DESC", ICON_TITAN, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "titansTotal", weaponRef )
		SetChallengeTiers( goals_titan_kills )
		SetChallengeTierBurnCards( 2, ["bc_hunt_titan"] )
		SetChallengeTierBurnCards( 3, ["bc_hunt_titan"] )
		SetChallengeTierBurnCards( 4, ["bc_hunt_titan"] )

	AddChallenge( "ch_titan_sniper_spectre_kills", "#CHALLENGE_WEAPON_SPECTRE_KILLS", "#CHALLENGE_WEAPON_SPECTRE_KILLS_DESC", ICON_SPECTRE, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "spectres", weaponRef )
		SetChallengeTiers( [ 5, 15, 20, 30, 50 ] )
		SetChallengeTierBurnCards( 2, ["bc_hunt_spectre"] )
		SetChallengeTierBurnCards( 3, ["bc_hunt_spectre"] )
		SetChallengeTierBurnCards( 4, ["bc_hunt_spectre"] )

	AddChallenge( "ch_titan_sniper_grunt_kills", "#CHALLENGE_WEAPON_GRUNT_KILLS", "#CHALLENGE_WEAPON_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( [ 5, 15, 25, 50, 100 ] )

	AddChallenge( "ch_titan_sniper_hours_used", "#CHALLENGE_WEAPON_HOURS_USED", "#CHALLENGE_WEAPON_HOURS_USED_DESC", ICON_TIME_PLAYED, weaponRef, true )
		SetChallengeStat( "weapon_stats", "hoursUsed", weaponRef )
		SetChallengeTiers( goals_hours_used )

	AddChallenge( "ch_titan_sniper_crits", "#CHALLENGE_WEAPON_CRITS", "#CHALLENGE_WEAPON_CRITS_DESC", ICON_CRITICAL_HIT, weaponRef )
		SetChallengeStat( "weapon_stats", "critHits", weaponRef )
		SetChallengeTiers( [ 5, 10, 20, 30, 50 ] )

	//------------------
	// 	 Arc Cannon
	//------------------

	local weaponRef = "mp_titanweapon_arc_cannon"
	SetChallengeCategory( eChallengeCategory.WEAPON_ARC_CANNON, "#WPN_TITAN_ARC_CANNON", "", weaponRef )

	AddChallenge( "ch_arc_cannon_kills", "#CHALLENGE_WEAPON_KILLS", "#CHALLENGE_WEAPON_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( goals_kills )

	AddChallenge( "ch_arc_cannon_pilot_kills", "#CHALLENGE_WEAPON_PILOT_KILLS", "#CHALLENGE_WEAPON_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( goals_pilot_kills )
		SetChallengeTierBurnCards( 2, ["bc_hunt_pilot"] )
		SetChallengeTierBurnCards( 3, ["bc_hunt_pilot"] )
		SetChallengeTierBurnCards( 4, ["bc_hunt_pilot"] )

	AddChallenge( "ch_arc_cannon_titan_kills", "#CHALLENGE_WEAPON_TITAN_KILLS", "#CHALLENGE_WEAPON_TITAN_KILLS_DESC", ICON_TITAN, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "titansTotal", weaponRef )
		SetChallengeTiers( goals_titan_kills )
		SetChallengeTierBurnCards( 2, ["bc_hunt_titan"] )
		SetChallengeTierBurnCards( 3, ["bc_hunt_titan"] )
		SetChallengeTierBurnCards( 4, ["bc_hunt_titan"] )

	AddChallenge( "ch_arc_cannon_spectre_kills", "#CHALLENGE_WEAPON_SPECTRE_KILLS", "#CHALLENGE_WEAPON_SPECTRE_KILLS_DESC", ICON_SPECTRE, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "spectres", weaponRef )
		SetChallengeTiers( goals_spectre_kills )
		SetChallengeTierBurnCards( 2, ["bc_hunt_spectre"] )
		SetChallengeTierBurnCards( 3, ["bc_hunt_spectre"] )
		SetChallengeTierBurnCards( 4, ["bc_hunt_spectre"] )

	AddChallenge( "ch_arc_cannon_grunt_kills", "#CHALLENGE_WEAPON_GRUNT_KILLS", "#CHALLENGE_WEAPON_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( goals_grunt_kills )

	AddChallenge( "ch_arc_cannon_hours_used", "#CHALLENGE_WEAPON_HOURS_USED", "#CHALLENGE_WEAPON_HOURS_USED_DESC", ICON_TIME_PLAYED, weaponRef, true )
		SetChallengeStat( "weapon_stats", "hoursUsed", weaponRef )
		SetChallengeTiers( goals_hours_used )

	//------------------
	// Rocket Launcher
	//------------------

	local weaponRef = "mp_titanweapon_rocket_launcher"
	SetChallengeCategory( eChallengeCategory.WEAPON_ROCKET_LAUNCHER, "#WPN_TITAN_ROCKET_LAUNCHER", "", weaponRef )

	AddChallenge( "ch_rocket_launcher_kills", "#CHALLENGE_WEAPON_KILLS", "#CHALLENGE_WEAPON_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( goals_kills )

	AddChallenge( "ch_rocket_launcher_pilot_kills", "#CHALLENGE_WEAPON_PILOT_KILLS", "#CHALLENGE_WEAPON_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( goals_pilot_kills )
		SetChallengeTierBurnCards( 2, ["bc_hunt_pilot"] )
		SetChallengeTierBurnCards( 3, ["bc_hunt_pilot"] )
		SetChallengeTierBurnCards( 4, ["bc_hunt_pilot"] )

	AddChallenge( "ch_rocket_launcher_titan_kills", "#CHALLENGE_WEAPON_TITAN_KILLS", "#CHALLENGE_WEAPON_TITAN_KILLS_DESC", ICON_TITAN, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "titansTotal", weaponRef )
		SetChallengeTiers( goals_titan_kills )
		SetChallengeTierBurnCards( 2, ["bc_hunt_titan"] )
		SetChallengeTierBurnCards( 3, ["bc_hunt_titan"] )
		SetChallengeTierBurnCards( 4, ["bc_hunt_titan"] )

	AddChallenge( "ch_rocket_launcher_spectre_kills", "#CHALLENGE_WEAPON_SPECTRE_KILLS", "#CHALLENGE_WEAPON_SPECTRE_KILLS_DESC", ICON_SPECTRE, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "spectres", weaponRef )
		SetChallengeTiers( goals_spectre_kills )
		SetChallengeTierBurnCards( 2, ["bc_hunt_spectre"] )
		SetChallengeTierBurnCards( 3, ["bc_hunt_spectre"] )
		SetChallengeTierBurnCards( 4, ["bc_hunt_spectre"] )

	AddChallenge( "ch_rocket_launcher_grunt_kills", "#CHALLENGE_WEAPON_GRUNT_KILLS", "#CHALLENGE_WEAPON_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( goals_grunt_kills )

	AddChallenge( "ch_rocket_launcher_hours_used", "#CHALLENGE_WEAPON_HOURS_USED", "#CHALLENGE_WEAPON_HOURS_USED_DESC", ICON_TIME_PLAYED, weaponRef, true )
		SetChallengeStat( "weapon_stats", "hoursUsed", weaponRef )
		SetChallengeTiers( goals_hours_used )

	//------------------
	// 	 Triple Threat
	//------------------

	local weaponRef = "mp_titanweapon_triple_threat"
	SetChallengeCategory( eChallengeCategory.WEAPON_TRIPLE_THREAT, "#WPN_TITAN_TRIPLE_THREAT", "", weaponRef )

	AddChallenge( "ch_triple_threat_kills", "#CHALLENGE_WEAPON_KILLS", "#CHALLENGE_WEAPON_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( goals_kills )

	AddChallenge( "ch_triple_threat_pilot_kills", "#CHALLENGE_WEAPON_PILOT_KILLS", "#CHALLENGE_WEAPON_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( goals_pilot_kills )
		SetChallengeTierBurnCards( 2, ["bc_hunt_pilot"] )
		SetChallengeTierBurnCards( 3, ["bc_hunt_pilot"] )
		SetChallengeTierBurnCards( 4, ["bc_hunt_pilot"] )

	AddChallenge( "ch_triple_threat_titan_kills", "#CHALLENGE_WEAPON_TITAN_KILLS", "#CHALLENGE_WEAPON_TITAN_KILLS_DESC", ICON_TITAN, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "titansTotal", weaponRef )
		SetChallengeTiers( goals_titan_kills )
		SetChallengeTierBurnCards( 2, ["bc_hunt_titan"] )
		SetChallengeTierBurnCards( 3, ["bc_hunt_titan"] )
		SetChallengeTierBurnCards( 4, ["bc_hunt_titan"] )

	AddChallenge( "ch_triple_threat_spectre_kills", "#CHALLENGE_WEAPON_SPECTRE_KILLS", "#CHALLENGE_WEAPON_SPECTRE_KILLS_DESC", ICON_SPECTRE, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "spectres", weaponRef )
		SetChallengeTiers( goals_spectre_kills )
		SetChallengeTierBurnCards( 2, ["bc_hunt_spectre"] )
		SetChallengeTierBurnCards( 3, ["bc_hunt_spectre"] )
		SetChallengeTierBurnCards( 4, ["bc_hunt_spectre"] )

	AddChallenge( "ch_triple_threat_grunt_kills", "#CHALLENGE_WEAPON_GRUNT_KILLS", "#CHALLENGE_WEAPON_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( goals_grunt_kills )

	AddChallenge( "ch_triple_threat_hours_used", "#CHALLENGE_WEAPON_HOURS_USED", "#CHALLENGE_WEAPON_HOURS_USED_DESC", ICON_TIME_PLAYED, weaponRef, true )
		SetChallengeStat( "weapon_stats", "hoursUsed", weaponRef )
		SetChallengeTiers( goals_hours_used )

	/*##################################################################################
					######## #### ########    ###    ##    ##
					   ##     ##     ##      ## ##   ###   ##
					   ##     ##     ##     ##   ##  ####  ##
					   ##     ##     ##    ##     ## ## ## ##
					   ##     ##     ##    ######### ##  ####
					   ##     ##     ##    ##     ## ##   ###
					   ##    ####    ##    ##     ## ##    ##

		 #######  ########  ########  ##    ##    ###    ##    ##  ######  ########
		##     ## ##     ## ##     ## ###   ##   ## ##   ###   ## ##    ## ##
		##     ## ##     ## ##     ## ####  ##  ##   ##  ####  ## ##       ##
		##     ## ########  ##     ## ## ## ## ##     ## ## ## ## ##       ######
		##     ## ##   ##   ##     ## ##  #### ######### ##  #### ##       ##
		##     ## ##    ##  ##     ## ##   ### ##     ## ##   ### ##    ## ##
		 #######  ##     ## ########  ##    ## ##     ## ##    ##  ######  ########
	##################################################################################*/

	local linkedCategories = 	[
									eChallengeCategory.WEAPON_SALVO_ROCKETS,
									eChallengeCategory.WEAPON_HOMING_ROCKETS,
									eChallengeCategory.WEAPON_DUMBFIRE_ROCKETS,
									eChallengeCategory.WEAPON_SHOULDER_ROCKETS
								]
	SetChallengeCategory( eChallengeCategory.TITAN_ORDNANCE, "#CHALLENGE_CATEGORY_TITAN_ORDNANCE", "#CHALLENGE_CATEGORY_DESC_TITAN_ORDNANCE", "edit_titans", linkedCategories )

	//------------------
	// Salvo Rockets
	//------------------

	local weaponRef = "mp_titanweapon_salvo_rockets"
	SetChallengeCategory( eChallengeCategory.WEAPON_SALVO_ROCKETS, "#WPN_TITAN_SALVO_ROCKETS", "", weaponRef )

	AddChallenge( "ch_salvo_rockets_kills", "#CHALLENGE_WEAPON_KILLS", "#CHALLENGE_WEAPON_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( [ 10, 25, 50, 100, 150 ] )

	AddChallenge( "ch_salvo_rockets_pilot_kills", "#CHALLENGE_WEAPON_PILOT_KILLS", "#CHALLENGE_WEAPON_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( [ 5, 15, 30, 50, 75 ] )
		SetChallengeTierBurnCards( 2, ["bc_hunt_pilot"] )
		SetChallengeTierBurnCards( 3, ["bc_hunt_pilot"] )
		SetChallengeTierBurnCards( 4, ["bc_hunt_pilot"] )

	AddChallenge( "ch_salvo_rockets_titan_kills", "#CHALLENGE_WEAPON_TITAN_KILLS", "#CHALLENGE_WEAPON_TITAN_KILLS_DESC", ICON_TITAN, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "titansTotal", weaponRef )
		SetChallengeTiers( [ 5, 15, 20, 30, 50 ] )
		SetChallengeTierBurnCards( 2, ["bc_hunt_titan"] )
		SetChallengeTierBurnCards( 3, ["bc_hunt_titan"] )
		SetChallengeTierBurnCards( 4, ["bc_hunt_titan"] )

	AddChallenge( "ch_salvo_rockets_spectre_kills", "#CHALLENGE_WEAPON_SPECTRE_KILLS", "#CHALLENGE_WEAPON_SPECTRE_KILLS_DESC", ICON_SPECTRE, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "spectres", weaponRef )
		SetChallengeTiers( [ 5, 15, 30, 50, 75 ] )
		SetChallengeTierBurnCards( 2, ["bc_hunt_spectre"] )
		SetChallengeTierBurnCards( 3, ["bc_hunt_spectre"] )
		SetChallengeTierBurnCards( 4, ["bc_hunt_spectre"] )

	AddChallenge( "ch_salvo_rockets_grunt_kills", "#CHALLENGE_WEAPON_GRUNT_KILLS", "#CHALLENGE_WEAPON_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( [ 5, 15, 30, 50, 100 ] )

	AddChallenge( "ch_salvo_rockets_hours_used", "#CHALLENGE_WEAPON_HOURS_USED", "#CHALLENGE_WEAPON_HOURS_USED_DESC", ICON_TIME_PLAYED, weaponRef, true )
		SetChallengeStat( "weapon_stats", "hoursEquipped", weaponRef )
		SetChallengeTiers( goals_hours_used )

	//------------------
	//  Homing Rockets ( Slaved Warheads )
	//------------------

	local weaponRef = "mp_titanweapon_homing_rockets"
	SetChallengeCategory( eChallengeCategory.WEAPON_HOMING_ROCKETS, "#WPN_TITAN_HOMING_ROCKETS", "", weaponRef )

	AddChallenge( "ch_homing_rockets_titan_kills", "#CHALLENGE_WEAPON_TITAN_KILLS", "#CHALLENGE_WEAPON_TITAN_KILLS_DESC", ICON_TITAN, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "titansTotal", weaponRef )
		SetChallengeTiers( [ 5, 15, 20, 30, 50 ] )

	AddChallenge( "ch_homing_rockets_hours_used", "#CHALLENGE_WEAPON_HOURS_USED", "#CHALLENGE_WEAPON_HOURS_USED_DESC", ICON_TIME_PLAYED, weaponRef, true )
		SetChallengeStat( "weapon_stats", "hoursEquipped", weaponRef )
		SetChallengeTiers( goals_hours_used )

	//------------------
	// Cluster Rockets
	//------------------

	local weaponRef = "mp_titanweapon_dumbfire_rockets"
	SetChallengeCategory( eChallengeCategory.WEAPON_DUMBFIRE_ROCKETS, "#WPN_TITAN_DUMB_SHOULDER_ROCKETS", "", weaponRef )

	AddChallenge( "ch_dumbfire_rockets_kills", "#CHALLENGE_WEAPON_KILLS", "#CHALLENGE_WEAPON_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( [ 10, 25, 50, 100, 150 ] )

	AddChallenge( "ch_dumbfire_rockets_pilot_kills", "#CHALLENGE_WEAPON_PILOT_KILLS", "#CHALLENGE_WEAPON_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( [ 5, 15, 30, 50, 75 ] )
		SetChallengeTierBurnCards( 2, ["bc_hunt_pilot"] )
		SetChallengeTierBurnCards( 3, ["bc_hunt_pilot"] )
		SetChallengeTierBurnCards( 4, ["bc_hunt_pilot"] )

	AddChallenge( "ch_dumbfire_rockets_titan_kills", "#CHALLENGE_WEAPON_TITAN_KILLS", "#CHALLENGE_WEAPON_TITAN_KILLS_DESC", ICON_TITAN, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "titansTotal", weaponRef )
		SetChallengeTiers( [ 5, 15, 20, 30, 50 ] )
		SetChallengeTierBurnCards( 2, ["bc_hunt_titan"] )
		SetChallengeTierBurnCards( 3, ["bc_hunt_titan"] )
		SetChallengeTierBurnCards( 4, ["bc_hunt_titan"] )

	AddChallenge( "ch_dumbfire_rockets_spectre_kills", "#CHALLENGE_WEAPON_SPECTRE_KILLS", "#CHALLENGE_WEAPON_SPECTRE_KILLS_DESC", ICON_SPECTRE, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "spectres", weaponRef )
		SetChallengeTiers( [ 5, 15, 30, 50, 75 ] )
		SetChallengeTierBurnCards( 2, ["bc_hunt_spectre"] )
		SetChallengeTierBurnCards( 3, ["bc_hunt_spectre"] )
		SetChallengeTierBurnCards( 4, ["bc_hunt_spectre"] )

	AddChallenge( "ch_dumbfire_rockets_grunt_kills", "#CHALLENGE_WEAPON_GRUNT_KILLS", "#CHALLENGE_WEAPON_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( [ 5, 15, 30, 50, 100 ] )

	AddChallenge( "ch_dumbfire_rockets_hours_used", "#CHALLENGE_WEAPON_HOURS_USED", "#CHALLENGE_WEAPON_HOURS_USED_DESC", ICON_TIME_PLAYED, weaponRef, true )
		SetChallengeStat( "weapon_stats", "hoursEquipped", weaponRef )
		SetChallengeTiers( goals_hours_used )

	//------------------
	// Shoulder Rockets ( Multi-Target Missile System )
	//------------------

	local weaponRef = "mp_titanweapon_shoulder_rockets"
	SetChallengeCategory( eChallengeCategory.WEAPON_SHOULDER_ROCKETS, "#WPN_TITAN_SHOULDER_ROCKETS", "", weaponRef )

	//AddChallenge( "ch_shoulder_rockets_kills", "#CHALLENGE_WEAPON_KILLS", "#CHALLENGE_WEAPON_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
	//	SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
	//	SetChallengeTiers( goals_kills )

	AddChallenge( "ch_shoulder_rockets_titan_kills", "#CHALLENGE_WEAPON_TITAN_KILLS", "#CHALLENGE_WEAPON_TITAN_KILLS_DESC", ICON_TITAN, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "titansTotal", weaponRef )
		SetChallengeTiers( [ 5, 15, 20, 30, 50 ] )
		SetChallengeTierBurnCards( 2, ["bc_hunt_titan"] )
		SetChallengeTierBurnCards( 3, ["bc_hunt_titan"] )
		SetChallengeTierBurnCards( 4, ["bc_hunt_titan"] )

	AddChallenge( "ch_shoulder_rockets_hours_used", "#CHALLENGE_WEAPON_HOURS_USED", "#CHALLENGE_WEAPON_HOURS_USED_DESC", ICON_TIME_PLAYED, weaponRef, true )
		SetChallengeStat( "weapon_stats", "hoursEquipped", weaponRef )
		SetChallengeTiers( goals_hours_used )

	/*#######################################################################
				########  #### ##        #######  ########
				##     ##  ##  ##       ##     ##    ##
				##     ##  ##  ##       ##     ##    ##
				########   ##  ##       ##     ##    ##
				##         ##  ##       ##     ##    ##
				##         ##  ##       ##     ##    ##
				##        #### ########  #######     ##

		########  ########  #### ##     ##    ###    ########  ##    ##
		##     ## ##     ##  ##  ###   ###   ## ##   ##     ##  ##  ##
		##     ## ##     ##  ##  #### ####  ##   ##  ##     ##   ####
		########  ########   ##  ## ### ## ##     ## ########     ##
		##        ##   ##    ##  ##     ## ######### ##   ##      ##
		##        ##    ##   ##  ##     ## ##     ## ##    ##     ##
		##        ##     ## #### ##     ## ##     ## ##     ##    ##
	#######################################################################*/

	local linkedCategories = 	[
									eChallengeCategory.WEAPON_SMART_PISTOL,
									eChallengeCategory.WEAPON_SHOTGUN,
									eChallengeCategory.WEAPON_R97,
									eChallengeCategory.WEAPON_CAR,
									eChallengeCategory.WEAPON_LMG,
									eChallengeCategory.WEAPON_RSPN101,
									eChallengeCategory.WEAPON_HEMLOK,
									eChallengeCategory.WEAPON_G2,
									eChallengeCategory.WEAPON_DMR,
									eChallengeCategory.WEAPON_SNIPER
								]
	SetChallengeCategory( eChallengeCategory.PILOT_PRIMARY, "#CHALLENGE_CATEGORY_PILOT_PRIMARY", "#CHALLENGE_CATEGORY_DESC_PILOT_PRIMARY", "edit_pilots", linkedCategories )

	//------------------
	// 	Smart Pistol
	//------------------

	local weaponRef = "mp_weapon_smart_pistol"
	SetChallengeCategory( eChallengeCategory.WEAPON_SMART_PISTOL, "#WPN_SMART_PISTOL", "", weaponRef )

	AddChallenge( "ch_smart_pistol_kills", "#CHALLENGE_WEAPON_KILLS", "#CHALLENGE_WEAPON_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( goals_kills )
		SetChallengeTierBurnCards( 1, ["bc_smart_pistol_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_smart_pistol_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_smart_pistol_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_smart_pistol_m2"] )

	AddChallenge( "ch_smart_pistol_pilot_kills", "#CHALLENGE_WEAPON_PILOT_KILLS", "#CHALLENGE_WEAPON_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( goals_pilot_kills )
		SetChallengeTierBurnCards( 1, ["bc_smart_pistol_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_smart_pistol_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_smart_pistol_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_smart_pistol_m2"] )

	AddChallenge( "ch_smart_pistol_spectre_kills", "#CHALLENGE_WEAPON_SPECTRE_KILLS", "#CHALLENGE_WEAPON_SPECTRE_KILLS_DESC", ICON_SPECTRE, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "spectres", weaponRef )
		SetChallengeTiers( goals_spectre_kills )
		SetChallengeTierBurnCards( 1, ["bc_smart_pistol_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_smart_pistol_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_smart_pistol_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_smart_pistol_m2"] )

	AddChallenge( "ch_smart_pistol_grunt_kills", "#CHALLENGE_WEAPON_GRUNT_KILLS", "#CHALLENGE_WEAPON_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( goals_grunt_kills )
		SetChallengeTierBurnCards( 1, ["bc_smart_pistol_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_smart_pistol_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_smart_pistol_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_smart_pistol_m2"] )

	AddChallenge( "ch_smart_pistol_hours_used", "#CHALLENGE_WEAPON_HOURS_USED", "#CHALLENGE_WEAPON_HOURS_USED_DESC", ICON_TIME_PLAYED, weaponRef, true )
		SetChallengeStat( "weapon_stats", "hoursUsed", weaponRef )
		SetChallengeTiers( goals_hours_used )
		SetChallengeTierBurnCards( 1, ["bc_smart_pistol_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_smart_pistol_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_smart_pistol_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_smart_pistol_m2"] )

	//------------------
	// 	   Shotgun
	//------------------

	local weaponRef = "mp_weapon_shotgun"
	SetChallengeCategory( eChallengeCategory.WEAPON_SHOTGUN, "#WPN_SHOTGUN", "", weaponRef )

	AddChallenge( "ch_shotgun_kills", "#CHALLENGE_WEAPON_KILLS", "#CHALLENGE_WEAPON_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( goals_kills )
		SetChallengeTierBurnCards( 1, ["bc_shotgun_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_shotgun_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_shotgun_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_shotgun_m2"] )

	AddChallenge( "ch_shotgun_pilot_kills", "#CHALLENGE_WEAPON_PILOT_KILLS", "#CHALLENGE_WEAPON_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( goals_pilot_kills )
		SetChallengeTierBurnCards( 1, ["bc_shotgun_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_shotgun_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_shotgun_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_shotgun_m2"] )

	AddChallenge( "ch_shotgun_spectre_kills", "#CHALLENGE_WEAPON_SPECTRE_KILLS", "#CHALLENGE_WEAPON_SPECTRE_KILLS_DESC", ICON_SPECTRE, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "spectres", weaponRef )
		SetChallengeTiers( goals_spectre_kills )
		SetChallengeTierBurnCards( 1, ["bc_shotgun_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_shotgun_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_shotgun_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_shotgun_m2"] )

	AddChallenge( "ch_shotgun_grunt_kills", "#CHALLENGE_WEAPON_GRUNT_KILLS", "#CHALLENGE_WEAPON_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( goals_grunt_kills )
		SetChallengeTierBurnCards( 1, ["bc_shotgun_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_shotgun_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_shotgun_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_shotgun_m2"] )

	AddChallenge( "ch_shotgun_hours_used", "#CHALLENGE_WEAPON_HOURS_USED", "#CHALLENGE_WEAPON_HOURS_USED_DESC", ICON_TIME_PLAYED, weaponRef, true )
		SetChallengeStat( "weapon_stats", "hoursUsed", weaponRef )
		SetChallengeTiers( goals_hours_used )
		SetChallengeTierBurnCards( 1, ["bc_shotgun_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_shotgun_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_shotgun_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_shotgun_m2"] )

	//------------------
	// 		R97
	//------------------

	local weaponRef = "mp_weapon_r97"
	SetChallengeCategory( eChallengeCategory.WEAPON_R97, "#WPN_R97", "", weaponRef )

	AddChallenge( "ch_r97_kills", "#CHALLENGE_WEAPON_KILLS", "#CHALLENGE_WEAPON_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( goals_kills )
		SetChallengeTierBurnCards( 1, ["bc_r97_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_r97_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_r97_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_r97_m2"] )

	AddChallenge( "ch_r97_pilot_kills", "#CHALLENGE_WEAPON_PILOT_KILLS", "#CHALLENGE_WEAPON_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( goals_pilot_kills )
		SetChallengeTierBurnCards( 1, ["bc_r97_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_r97_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_r97_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_r97_m2"] )

	AddChallenge( "ch_r97_spectre_kills", "#CHALLENGE_WEAPON_SPECTRE_KILLS", "#CHALLENGE_WEAPON_SPECTRE_KILLS_DESC", ICON_SPECTRE, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "spectres", weaponRef )
		SetChallengeTiers( goals_spectre_kills )
		SetChallengeTierBurnCards( 1, ["bc_r97_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_r97_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_r97_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_r97_m2"] )

	AddChallenge( "ch_r97_grunt_kills", "#CHALLENGE_WEAPON_GRUNT_KILLS", "#CHALLENGE_WEAPON_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( goals_grunt_kills )
		SetChallengeTierBurnCards( 1, ["bc_r97_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_r97_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_r97_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_r97_m2"] )

	AddChallenge( "ch_r97_hours_used", "#CHALLENGE_WEAPON_HOURS_USED", "#CHALLENGE_WEAPON_HOURS_USED_DESC", ICON_TIME_PLAYED, weaponRef, true )
		SetChallengeStat( "weapon_stats", "hoursUsed", weaponRef )
		SetChallengeTiers( goals_hours_used )
		SetChallengeTierBurnCards( 1, ["bc_r97_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_r97_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_r97_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_r97_m2"] )

	AddChallenge( "ch_r97_headshots", "#CHALLENGE_WEAPON_HEADSHOTS", "#CHALLENGE_WEAPON_HEADSHOTS_DESC", ICON_HEADSHOT, weaponRef )
		SetChallengeStat( "weapon_stats", "headshots", weaponRef )
		SetChallengeTiers( goals_headshots )
		SetChallengeTierBurnCards( 1, ["bc_r97_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_r97_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_r97_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_r97_m2"] )

	//------------------
	// 		CAR
	//------------------

	local weaponRef = "mp_weapon_car"
	SetChallengeCategory( eChallengeCategory.WEAPON_CAR, "#WPN_CAR", "", weaponRef )

	AddChallenge( "ch_car_kills", "#CHALLENGE_WEAPON_KILLS", "#CHALLENGE_WEAPON_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( goals_kills )
		SetChallengeTierBurnCards( 1, ["bc_car_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_car_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_car_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_car_m2"] )

	AddChallenge( "ch_car_pilot_kills", "#CHALLENGE_WEAPON_PILOT_KILLS", "#CHALLENGE_WEAPON_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( goals_pilot_kills )
		SetChallengeTierBurnCards( 1, ["bc_car_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_car_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_car_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_car_m2"] )

	AddChallenge( "ch_car_spectre_kills", "#CHALLENGE_WEAPON_SPECTRE_KILLS", "#CHALLENGE_WEAPON_SPECTRE_KILLS_DESC", ICON_SPECTRE, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "spectres", weaponRef )
		SetChallengeTiers( goals_spectre_kills )
		SetChallengeTierBurnCards( 1, ["bc_car_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_car_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_car_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_car_m2"] )

	AddChallenge( "ch_car_grunt_kills", "#CHALLENGE_WEAPON_GRUNT_KILLS", "#CHALLENGE_WEAPON_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( goals_grunt_kills )
		SetChallengeTierBurnCards( 1, ["bc_car_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_car_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_car_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_car_m2"] )

	AddChallenge( "ch_car_hours_used", "#CHALLENGE_WEAPON_HOURS_USED", "#CHALLENGE_WEAPON_HOURS_USED_DESC", ICON_TIME_PLAYED, weaponRef, true )
		SetChallengeStat( "weapon_stats", "hoursUsed", weaponRef )
		SetChallengeTiers( goals_hours_used )
		SetChallengeTierBurnCards( 1, ["bc_car_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_car_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_car_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_car_m2"] )

	AddChallenge( "ch_car_headshots", "#CHALLENGE_WEAPON_HEADSHOTS", "#CHALLENGE_WEAPON_HEADSHOTS_DESC", ICON_HEADSHOT, weaponRef )
		SetChallengeStat( "weapon_stats", "headshots", weaponRef )
		SetChallengeTiers( goals_headshots )
		SetChallengeTierBurnCards( 1, ["bc_car_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_car_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_car_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_car_m2"] )

	//------------------
	// 		LMG
	//------------------

	local weaponRef = "mp_weapon_lmg"
	SetChallengeCategory( eChallengeCategory.WEAPON_LMG, "#WPN_LMG", "", weaponRef )

	AddChallenge( "ch_lmg_kills", "#CHALLENGE_WEAPON_KILLS", "#CHALLENGE_WEAPON_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( goals_kills )
		SetChallengeTierBurnCards( 1, ["bc_lmg_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_lmg_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_lmg_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_lmg_m2"] )

	AddChallenge( "ch_lmg_pilot_kills", "#CHALLENGE_WEAPON_PILOT_KILLS", "#CHALLENGE_WEAPON_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( goals_pilot_kills )
		SetChallengeTierBurnCards( 1, ["bc_lmg_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_lmg_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_lmg_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_lmg_m2"] )

	AddChallenge( "ch_lmg_spectre_kills", "#CHALLENGE_WEAPON_SPECTRE_KILLS", "#CHALLENGE_WEAPON_SPECTRE_KILLS_DESC", ICON_SPECTRE, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "spectres", weaponRef )
		SetChallengeTiers( goals_spectre_kills )
		SetChallengeTierBurnCards( 1, ["bc_lmg_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_lmg_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_lmg_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_lmg_m2"] )

	AddChallenge( "ch_lmg_grunt_kills", "#CHALLENGE_WEAPON_GRUNT_KILLS", "#CHALLENGE_WEAPON_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( goals_grunt_kills )
		SetChallengeTierBurnCards( 1, ["bc_lmg_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_lmg_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_lmg_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_lmg_m2"] )

	AddChallenge( "ch_lmg_hours_used", "#CHALLENGE_WEAPON_HOURS_USED", "#CHALLENGE_WEAPON_HOURS_USED_DESC", ICON_TIME_PLAYED, weaponRef, true )
		SetChallengeStat( "weapon_stats", "hoursUsed", weaponRef )
		SetChallengeTiers( goals_hours_used )
		SetChallengeTierBurnCards( 1, ["bc_lmg_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_lmg_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_lmg_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_lmg_m2"] )

	AddChallenge( "ch_lmg_headshots", "#CHALLENGE_WEAPON_HEADSHOTS", "#CHALLENGE_WEAPON_HEADSHOTS_DESC", ICON_HEADSHOT, weaponRef )
		SetChallengeStat( "weapon_stats", "headshots", weaponRef )
		SetChallengeTiers( goals_headshots )
		SetChallengeTierBurnCards( 1, ["bc_lmg_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_lmg_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_lmg_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_lmg_m2"] )

	//------------------
	// 	  Rspn 101
	//------------------

	local weaponRef = "mp_weapon_rspn101"
	SetChallengeCategory( eChallengeCategory.WEAPON_RSPN101, "#WPN_RSPN101", "", weaponRef )

	AddChallenge( "ch_rspn101_kills", "#CHALLENGE_WEAPON_KILLS", "#CHALLENGE_WEAPON_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( goals_kills )
		SetChallengeTierBurnCards( 1, ["bc_rspn101_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_rspn101_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_rspn101_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_rspn101_m2"] )

	AddChallenge( "ch_rspn101_pilot_kills", "#CHALLENGE_WEAPON_PILOT_KILLS", "#CHALLENGE_WEAPON_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( goals_pilot_kills )
		SetChallengeTierBurnCards( 1, ["bc_rspn101_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_rspn101_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_rspn101_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_rspn101_m2"] )

	AddChallenge( "ch_rspn101_spectre_kills", "#CHALLENGE_WEAPON_SPECTRE_KILLS", "#CHALLENGE_WEAPON_SPECTRE_KILLS_DESC", ICON_SPECTRE, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "spectres", weaponRef )
		SetChallengeTiers( goals_spectre_kills )
		SetChallengeTierBurnCards( 1, ["bc_rspn101_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_rspn101_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_rspn101_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_rspn101_m2"] )

	AddChallenge( "ch_rspn101_grunt_kills", "#CHALLENGE_WEAPON_GRUNT_KILLS", "#CHALLENGE_WEAPON_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( goals_grunt_kills )
		SetChallengeTierBurnCards( 1, ["bc_rspn101_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_rspn101_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_rspn101_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_rspn101_m2"] )

	AddChallenge( "ch_rspn101_hours_used", "#CHALLENGE_WEAPON_HOURS_USED", "#CHALLENGE_WEAPON_HOURS_USED_DESC", ICON_TIME_PLAYED, weaponRef, true )
		SetChallengeStat( "weapon_stats", "hoursUsed", weaponRef )
		SetChallengeTiers( goals_hours_used )
		SetChallengeTierBurnCards( 1, ["bc_rspn101_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_rspn101_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_rspn101_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_rspn101_m2"] )

	AddChallenge( "ch_rspn101_headshots", "#CHALLENGE_WEAPON_HEADSHOTS", "#CHALLENGE_WEAPON_HEADSHOTS_DESC", ICON_HEADSHOT, weaponRef )
		SetChallengeStat( "weapon_stats", "headshots", weaponRef )
		SetChallengeTiers( goals_headshots )
		SetChallengeTierBurnCards( 1, ["bc_rspn101_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_rspn101_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_rspn101_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_rspn101_m2"] )

	//------------------
	// 	   Hemlok
	//------------------

	local weaponRef = "mp_weapon_hemlok"
	SetChallengeCategory( eChallengeCategory.WEAPON_HEMLOK, "#WPN_HEMLOK", "", weaponRef )

	AddChallenge( "ch_hemlok_kills", "#CHALLENGE_WEAPON_KILLS", "#CHALLENGE_WEAPON_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( goals_kills )
		SetChallengeTierBurnCards( 1, ["bc_hemlok_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_hemlok_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_hemlok_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_hemlok_m2"] )

	AddChallenge( "ch_hemlok_pilot_kills", "#CHALLENGE_WEAPON_PILOT_KILLS", "#CHALLENGE_WEAPON_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( goals_pilot_kills )
		SetChallengeTierBurnCards( 1, ["bc_hemlok_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_hemlok_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_hemlok_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_hemlok_m2"] )

	AddChallenge( "ch_hemlok_spectre_kills", "#CHALLENGE_WEAPON_SPECTRE_KILLS", "#CHALLENGE_WEAPON_SPECTRE_KILLS_DESC", ICON_SPECTRE, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "spectres", weaponRef )
		SetChallengeTiers( goals_spectre_kills )
		SetChallengeTierBurnCards( 1, ["bc_hemlok_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_hemlok_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_hemlok_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_hemlok_m2"] )

	AddChallenge( "ch_hemlok_grunt_kills", "#CHALLENGE_WEAPON_GRUNT_KILLS", "#CHALLENGE_WEAPON_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( goals_grunt_kills )
		SetChallengeTierBurnCards( 1, ["bc_hemlok_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_hemlok_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_hemlok_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_hemlok_m2"] )

	AddChallenge( "ch_hemlok_hours_used", "#CHALLENGE_WEAPON_HOURS_USED", "#CHALLENGE_WEAPON_HOURS_USED_DESC", ICON_TIME_PLAYED, weaponRef, true )
		SetChallengeStat( "weapon_stats", "hoursUsed", weaponRef )
		SetChallengeTiers( goals_hours_used )
		SetChallengeTierBurnCards( 1, ["bc_hemlok_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_hemlok_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_hemlok_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_hemlok_m2"] )

	AddChallenge( "ch_hemlok_headshots", "#CHALLENGE_WEAPON_HEADSHOTS", "#CHALLENGE_WEAPON_HEADSHOTS_DESC", ICON_HEADSHOT, weaponRef )
		SetChallengeStat( "weapon_stats", "headshots", weaponRef )
		SetChallengeTiers( goals_headshots )
		SetChallengeTierBurnCards( 1, ["bc_hemlok_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_hemlok_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_hemlok_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_hemlok_m2"] )

	//------------------
	//		 G2
	//------------------

	local weaponRef = "mp_weapon_g2"
	SetChallengeCategory( eChallengeCategory.WEAPON_G2, "#WPN_G2", "", weaponRef )

	AddChallenge( "ch_g2_kills", "#CHALLENGE_WEAPON_KILLS", "#CHALLENGE_WEAPON_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( goals_kills )
		SetChallengeTierBurnCards( 1, ["bc_g2_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_g2_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_g2_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_g2_m2"] )

	AddChallenge( "ch_g2_pilot_kills", "#CHALLENGE_WEAPON_PILOT_KILLS", "#CHALLENGE_WEAPON_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( goals_pilot_kills )
		SetChallengeTierBurnCards( 1, ["bc_g2_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_g2_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_g2_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_g2_m2"] )

	AddChallenge( "ch_g2_spectre_kills", "#CHALLENGE_WEAPON_SPECTRE_KILLS", "#CHALLENGE_WEAPON_SPECTRE_KILLS_DESC", ICON_SPECTRE, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "spectres", weaponRef )
		SetChallengeTiers( goals_spectre_kills )
		SetChallengeTierBurnCards( 1, ["bc_g2_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_g2_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_g2_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_g2_m2"] )

	AddChallenge( "ch_g2_grunt_kills", "#CHALLENGE_WEAPON_GRUNT_KILLS", "#CHALLENGE_WEAPON_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( goals_grunt_kills )
		SetChallengeTierBurnCards( 1, ["bc_g2_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_g2_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_g2_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_g2_m2"] )

	AddChallenge( "ch_g2_hours_used", "#CHALLENGE_WEAPON_HOURS_USED", "#CHALLENGE_WEAPON_HOURS_USED_DESC", ICON_TIME_PLAYED, weaponRef, true )
		SetChallengeStat( "weapon_stats", "hoursUsed", weaponRef )
		SetChallengeTiers( goals_hours_used )
		SetChallengeTierBurnCards( 1, ["bc_g2_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_g2_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_g2_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_g2_m2"] )

	AddChallenge( "ch_g2_headshots", "#CHALLENGE_WEAPON_HEADSHOTS", "#CHALLENGE_WEAPON_HEADSHOTS_DESC", ICON_HEADSHOT, weaponRef )
		SetChallengeStat( "weapon_stats", "headshots", weaponRef )
		SetChallengeTiers( goals_headshots )
		SetChallengeTierBurnCards( 1, ["bc_g2_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_g2_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_g2_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_g2_m2"] )

	//------------------
	//		 DMR
	//------------------

	local weaponRef = "mp_weapon_dmr"
	SetChallengeCategory( eChallengeCategory.WEAPON_DMR, "#WPN_DMR", "", weaponRef )

	AddChallenge( "ch_dmr_kills", "#CHALLENGE_WEAPON_KILLS", "#CHALLENGE_WEAPON_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( [ 10, 25, 50, 100, 150 ] )
		SetChallengeTierBurnCards( 1, ["bc_dmr_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_dmr_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_dmr_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_dmr_m2"] )

	AddChallenge( "ch_dmr_pilot_kills", "#CHALLENGE_WEAPON_PILOT_KILLS", "#CHALLENGE_WEAPON_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( [ 5, 15, 25, 35, 50 ] )
		SetChallengeTierBurnCards( 1, ["bc_dmr_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_dmr_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_dmr_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_dmr_m2"] )

	AddChallenge( "ch_dmr_spectre_kills", "#CHALLENGE_WEAPON_SPECTRE_KILLS", "#CHALLENGE_WEAPON_SPECTRE_KILLS_DESC", ICON_SPECTRE, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "spectres", weaponRef )
		SetChallengeTiers( [ 5, 15, 25, 35, 50 ] )
		SetChallengeTierBurnCards( 1, ["bc_dmr_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_dmr_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_dmr_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_dmr_m2"] )

	AddChallenge( "ch_dmr_grunt_kills", "#CHALLENGE_WEAPON_GRUNT_KILLS", "#CHALLENGE_WEAPON_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( [ 5, 15, 50,100, 150 ] )
		SetChallengeTierBurnCards( 1, ["bc_dmr_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_dmr_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_dmr_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_dmr_m2"] )

	AddChallenge( "ch_dmr_hours_used", "#CHALLENGE_WEAPON_HOURS_USED", "#CHALLENGE_WEAPON_HOURS_USED_DESC", ICON_TIME_PLAYED, weaponRef, true )
		SetChallengeStat( "weapon_stats", "hoursUsed", weaponRef )
		SetChallengeTiers( goals_hours_used )
		SetChallengeTierBurnCards( 1, ["bc_dmr_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_dmr_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_dmr_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_dmr_m2"] )

	AddChallenge( "ch_dmr_headshots", "#CHALLENGE_WEAPON_HEADSHOTS", "#CHALLENGE_WEAPON_HEADSHOTS_DESC", ICON_HEADSHOT, weaponRef )
		SetChallengeStat( "weapon_stats", "headshots", weaponRef )
		SetChallengeTiers( goals_headshots )
		SetChallengeTierBurnCards( 1, ["bc_dmr_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_dmr_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_dmr_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_dmr_m2"] )

	//------------------
	//		Sniper
	//------------------

	local weaponRef = "mp_weapon_sniper"
	SetChallengeCategory( eChallengeCategory.WEAPON_SNIPER, "#WPN_SNIPER", "", weaponRef )

	AddChallenge( "ch_sniper_kills", "#CHALLENGE_WEAPON_KILLS", "#CHALLENGE_WEAPON_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( [ 5, 15, 25, 50, 100 ] )
		SetChallengeTierBurnCards( 1, ["bc_sniper_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_sniper_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_sniper_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_sniper_m2"] )

	AddChallenge( "ch_sniper_pilot_kills", "#CHALLENGE_WEAPON_PILOT_KILLS", "#CHALLENGE_WEAPON_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( [ 1, 5, 10, 15, 25 ] )
		SetChallengeTierBurnCards( 1, ["bc_sniper_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_sniper_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_sniper_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_sniper_m2"] )

	AddChallenge( "ch_sniper_spectre_kills", "#CHALLENGE_WEAPON_SPECTRE_KILLS", "#CHALLENGE_WEAPON_SPECTRE_KILLS_DESC", ICON_SPECTRE, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "spectres", weaponRef )
		SetChallengeTiers( [ 1, 5, 10, 15, 25 ] )
		SetChallengeTierBurnCards( 1, ["bc_sniper_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_sniper_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_sniper_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_sniper_m2"] )

	AddChallenge( "ch_sniper_grunt_kills", "#CHALLENGE_WEAPON_GRUNT_KILLS", "#CHALLENGE_WEAPON_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( [ 5, 15, 25, 35, 50 ] )
		SetChallengeTierBurnCards( 1, ["bc_sniper_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_sniper_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_sniper_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_sniper_m2"] )

	AddChallenge( "ch_sniper_hours_used", "#CHALLENGE_WEAPON_HOURS_USED", "#CHALLENGE_WEAPON_HOURS_USED_DESC", ICON_TIME_PLAYED, weaponRef, true )
		SetChallengeStat( "weapon_stats", "hoursUsed", weaponRef )
		SetChallengeTiers( goals_hours_used )
		SetChallengeTierBurnCards( 1, ["bc_sniper_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_sniper_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_sniper_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_sniper_m2"] )

	/*##################################################################################
						########  #### ##        #######  ########
						##     ##  ##  ##       ##     ##    ##
						##     ##  ##  ##       ##     ##    ##
						########   ##  ##       ##     ##    ##
						##         ##  ##       ##     ##    ##
						##         ##  ##       ##     ##    ##
						##        #### ########  #######     ##

	 ######  ########  ######   #######  ##    ## ########     ###    ########  ##    ##
	##    ## ##       ##    ## ##     ## ###   ## ##     ##   ## ##   ##     ##  ##  ##
	##       ##       ##       ##     ## ####  ## ##     ##  ##   ##  ##     ##   ####
	 ######  ######   ##       ##     ## ## ## ## ##     ## ##     ## ########     ##
	      ## ##       ##       ##     ## ##  #### ##     ## ######### ##   ##      ##
	##    ## ##       ##    ## ##     ## ##   ### ##     ## ##     ## ##    ##     ##
	 ######  ########  ######   #######  ##    ## ########  ##     ## ##     ##    ##
	##################################################################################*/
	local linkedCategories = 	[
									eChallengeCategory.WEAPON_SMR,
									eChallengeCategory.WEAPON_MGL,
									eChallengeCategory.WEAPON_ARCHER,
									eChallengeCategory.WEAPON_DEFENDER
								]
	SetChallengeCategory( eChallengeCategory.PILOT_SECONDARY, "#CHALLENGE_CATEGORY_PILOT_SECONDARY", "#CHALLENGE_CATEGORY_DESC_PILOT_SECONDARY", "edit_pilots", linkedCategories )

	//------------------
	//		SMR
	//------------------

	local weaponRef = "mp_weapon_smr"
	SetChallengeCategory( eChallengeCategory.WEAPON_SMR, "#WPN_SMR", "", weaponRef )

	AddChallenge( "ch_smr_titan_kills", "#CHALLENGE_WEAPON_TITAN_KILLS", "#CHALLENGE_WEAPON_TITAN_KILLS_DESC", ICON_TITAN, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "titansTotal", weaponRef )
		SetChallengeTiers( [ 1, 3, 5, 7, 10 ] )
		SetChallengeTierBurnCards( 1, ["bc_smr_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_smr_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_smr_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_smr_m2"] )

	AddChallenge( "ch_smr_crits", "#CHALLENGE_WEAPON_CRITS", "#CHALLENGE_WEAPON_CRITS_DESC", ICON_CRITICAL_HIT, weaponRef )
		SetChallengeStat( "weapon_stats", "critHits", weaponRef )
		SetChallengeTiers( [ 10, 50, 100, 150, 200 ] )
		SetChallengeTierBurnCards( 1, ["bc_smr_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_smr_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_smr_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_smr_m2"] )

	//------------------
	//		MGL
	//------------------

	local weaponRef = "mp_weapon_mgl"
	SetChallengeCategory( eChallengeCategory.WEAPON_MGL, "#WPN_MGL", "", weaponRef )

	AddChallenge( "ch_mgl_titan_kills", "#CHALLENGE_WEAPON_TITAN_KILLS", "#CHALLENGE_WEAPON_TITAN_KILLS_DESC", ICON_TITAN, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "titansTotal", weaponRef )
		SetChallengeTiers( [ 1, 3, 5, 7, 10 ] )
		SetChallengeTierBurnCards( 1, ["bc_mgl_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_mgl_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_mgl_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_mgl_m2"] )

	//------------------
	//	   Archer
	//------------------

	local weaponRef = "mp_weapon_rocket_launcher"
	SetChallengeCategory( eChallengeCategory.WEAPON_ARCHER, "#WPN_ROCKET_LAUNCHER", "", weaponRef )

	AddChallenge( "ch_archer_titan_kills", "#CHALLENGE_WEAPON_TITAN_KILLS", "#CHALLENGE_WEAPON_TITAN_KILLS_DESC", ICON_TITAN, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "titansTotal", weaponRef )
		SetChallengeTiers( [ 1, 3, 5, 7, 10 ] )
		SetChallengeTierBurnCards( 1, ["bc_rocket_launcher_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_rocket_launcher_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_rocket_launcher_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_rocket_launcher_m2"] )

	//------------------
	//	   Defender
	//------------------

	local weaponRef = "mp_weapon_defender"
	SetChallengeCategory( eChallengeCategory.WEAPON_DEFENDER, "#WPN_CHARGE_RIFLE", "", weaponRef )

	AddChallenge( "ch_defender_titan_kills", "#CHALLENGE_WEAPON_TITAN_KILLS", "#CHALLENGE_WEAPON_TITAN_KILLS_DESC", ICON_TITAN, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "titansTotal", weaponRef )
		SetChallengeTiers( [ 1, 3, 5, 7, 10 ] )
		SetChallengeTierBurnCards( 1, ["bc_defender_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_defender_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_defender_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_defender_m2"] )

	AddChallenge( "ch_defender_crits", "#CHALLENGE_WEAPON_CRITS", "#CHALLENGE_WEAPON_CRITS_DESC", ICON_CRITICAL_HIT, weaponRef )
		SetChallengeStat( "weapon_stats", "critHits", weaponRef )
		SetChallengeTiers( [ 5, 10, 15, 20, 30 ] )
		SetChallengeTierBurnCards( 1, ["bc_defender_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_defender_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_defender_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_defender_m2"] )

	/*##################################################################################
						########  #### ##        #######  ########
						##     ##  ##  ##       ##     ##    ##
						##     ##  ##  ##       ##     ##    ##
						########   ##  ##       ##     ##    ##
						##         ##  ##       ##     ##    ##
						##         ##  ##       ##     ##    ##
						##        #### ########  #######     ##

				 ######  #### ########  ########    ###    ########  ##     ##
				##    ##  ##  ##     ## ##         ## ##   ##     ## ###   ###
				##        ##  ##     ## ##        ##   ##  ##     ## #### ####
				 ######   ##  ##     ## ######   ##     ## ########  ## ### ##
				      ##  ##  ##     ## ##       ######### ##   ##   ##     ##
				##    ##  ##  ##     ## ##       ##     ## ##    ##  ##     ##
				 ######  #### ########  ######## ##     ## ##     ## ##     ##
	##################################################################################*/
	local linkedCategories = 	[
									eChallengeCategory.WEAPON_AUTOPISTOL,
									eChallengeCategory.WEAPON_SEMIPISTOL,
									eChallengeCategory.WEAPON_WINGMAN
								]
	SetChallengeCategory( eChallengeCategory.PILOT_SIDEARM, "#CHALLENGE_CATEGORY_PILOT_SIDEARM", "#CHALLENGE_CATEGORY_DESC_PILOT_SIDEARM", "edit_pilots", linkedCategories )

	//------------------
	// RE45 Autopistol
	//------------------

	local weaponRef = "mp_weapon_autopistol"
	SetChallengeCategory( eChallengeCategory.WEAPON_AUTOPISTOL, "#WPN_RE45_AUTOPISTOL", "", weaponRef )

	AddChallenge( "ch_autopistol_kills", "#CHALLENGE_WEAPON_KILLS", "#CHALLENGE_WEAPON_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( [ 10, 25, 50, 100, 150 ] )
		SetChallengeTierBurnCards( 1, ["bc_autopistol_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_autopistol_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_autopistol_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_autopistol_m2"] )

	AddChallenge( "ch_autopistol_pilot_kills", "#CHALLENGE_WEAPON_PILOT_KILLS", "#CHALLENGE_WEAPON_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( [ 5, 15, 25, 35, 50 ] )
		SetChallengeTierBurnCards( 1, ["bc_autopistol_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_autopistol_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_autopistol_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_autopistol_m2"] )

	AddChallenge( "ch_autopistol_spectre_kills", "#CHALLENGE_WEAPON_SPECTRE_KILLS", "#CHALLENGE_WEAPON_SPECTRE_KILLS_DESC", ICON_SPECTRE, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "spectres", weaponRef )
		SetChallengeTiers( [ 5, 15, 25, 35, 50 ] )
		SetChallengeTierBurnCards( 1, ["bc_autopistol_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_autopistol_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_autopistol_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_autopistol_m2"] )

	AddChallenge( "ch_autopistol_grunt_kills", "#CHALLENGE_WEAPON_GRUNT_KILLS", "#CHALLENGE_WEAPON_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( [ 5, 15, 30, 50, 100 ] )
		SetChallengeTierBurnCards( 1, ["bc_autopistol_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_autopistol_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_autopistol_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_autopistol_m2"] )

	AddChallenge( "ch_autopistol_headshots", "#CHALLENGE_WEAPON_HEADSHOTS", "#CHALLENGE_WEAPON_HEADSHOTS_DESC", ICON_HEADSHOT, weaponRef )
		SetChallengeStat( "weapon_stats", "headshots", weaponRef )
		SetChallengeTiers( [ 5, 15, 25, 35, 50 ] )
		SetChallengeTierBurnCards( 1, ["bc_autopistol_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_autopistol_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_autopistol_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_autopistol_m2"] )

	//------------------
	// 		P2011
	//------------------

	local weaponRef = "mp_weapon_semipistol"
	SetChallengeCategory( eChallengeCategory.WEAPON_SEMIPISTOL, "#WPN_P2011", "", weaponRef )

	AddChallenge( "ch_semipistol_kills", "#CHALLENGE_WEAPON_KILLS", "#CHALLENGE_WEAPON_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( [ 10, 25, 50, 100, 150 ] )
		SetChallengeTierBurnCards( 1, ["bc_semipistol_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_semipistol_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_semipistol_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_semipistol_m2"] )

	AddChallenge( "ch_semipistol_pilot_kills", "#CHALLENGE_WEAPON_PILOT_KILLS", "#CHALLENGE_WEAPON_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( [ 5, 15, 25, 35, 50 ] )
		SetChallengeTierBurnCards( 1, ["bc_semipistol_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_semipistol_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_semipistol_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_semipistol_m2"] )

	AddChallenge( "ch_semipistol_spectre_kills", "#CHALLENGE_WEAPON_SPECTRE_KILLS", "#CHALLENGE_WEAPON_SPECTRE_KILLS_DESC", ICON_SPECTRE, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "spectres", weaponRef )
		SetChallengeTiers( [ 5, 15, 25, 35, 50 ] )
		SetChallengeTierBurnCards( 1, ["bc_semipistol_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_semipistol_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_semipistol_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_semipistol_m2"] )

	AddChallenge( "ch_semipistol_grunt_kills", "#CHALLENGE_WEAPON_GRUNT_KILLS", "#CHALLENGE_WEAPON_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( [ 5, 15, 30, 50, 100 ] )
		SetChallengeTierBurnCards( 1, ["bc_semipistol_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_semipistol_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_semipistol_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_semipistol_m2"] )

	AddChallenge( "ch_semipistol_headshots", "#CHALLENGE_WEAPON_HEADSHOTS", "#CHALLENGE_WEAPON_HEADSHOTS_DESC", ICON_HEADSHOT, weaponRef )
		SetChallengeStat( "weapon_stats", "headshots", weaponRef )
		SetChallengeTiers( [ 5, 15, 25, 35, 50 ] )
		SetChallengeTierBurnCards( 1, ["bc_semipistol_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_semipistol_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_semipistol_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_semipistol_m2"] )

	//------------------
	// 	   Wingman
	//------------------

	local weaponRef = "mp_weapon_wingman"
	SetChallengeCategory( eChallengeCategory.WEAPON_WINGMAN, "#WPN_WINGMAN", "", weaponRef )

	AddChallenge( "ch_wingman_kills", "#CHALLENGE_WEAPON_KILLS", "#CHALLENGE_WEAPON_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( [ 10, 25, 50, 100, 150 ] )
		SetChallengeTierBurnCards( 1, ["bc_wingman_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_wingman_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_wingman_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_wingman_m2"] )

	AddChallenge( "ch_wingman_pilot_kills", "#CHALLENGE_WEAPON_PILOT_KILLS", "#CHALLENGE_WEAPON_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( [ 5, 15, 25, 35, 50 ] )
		SetChallengeTierBurnCards( 1, ["bc_wingman_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_wingman_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_wingman_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_wingman_m2"] )

	AddChallenge( "ch_wingman_spectre_kills", "#CHALLENGE_WEAPON_SPECTRE_KILLS", "#CHALLENGE_WEAPON_SPECTRE_KILLS_DESC", ICON_SPECTRE, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "spectres", weaponRef )
		SetChallengeTiers( [ 5, 15, 25, 35, 50 ] )
		SetChallengeTierBurnCards( 1, ["bc_wingman_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_wingman_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_wingman_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_wingman_m2"] )

	AddChallenge( "ch_wingman_grunt_kills", "#CHALLENGE_WEAPON_GRUNT_KILLS", "#CHALLENGE_WEAPON_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( [ 5, 15, 30, 50, 100 ] )
		SetChallengeTierBurnCards( 1, ["bc_wingman_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_wingman_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_wingman_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_wingman_m2"] )

	AddChallenge( "ch_wingman_headshots", "#CHALLENGE_WEAPON_HEADSHOTS", "#CHALLENGE_WEAPON_HEADSHOTS_DESC", ICON_HEADSHOT, weaponRef )
		SetChallengeStat( "weapon_stats", "headshots", weaponRef )
		SetChallengeTiers( [ 5, 15, 25, 35, 50 ] )
		SetChallengeTierBurnCards( 1, ["bc_wingman_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_wingman_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_wingman_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_wingman_m2"] )

	/*##################################################################################
						########  #### ##        #######  ########
						##     ##  ##  ##       ##     ##    ##
						##     ##  ##  ##       ##     ##    ##
						########   ##  ##       ##     ##    ##
						##         ##  ##       ##     ##    ##
						##         ##  ##       ##     ##    ##
						##        #### ########  #######     ##

		 #######  ########  ########  ##    ##    ###    ##    ##  ######  ########
		##     ## ##     ## ##     ## ###   ##   ## ##   ###   ## ##    ## ##
		##     ## ##     ## ##     ## ####  ##  ##   ##  ####  ## ##       ##
		##     ## ########  ##     ## ## ## ## ##     ## ## ## ## ##       ######
		##     ## ##   ##   ##     ## ##  #### ######### ##  #### ##       ##
		##     ## ##    ##  ##     ## ##   ### ##     ## ##   ### ##    ## ##
		 #######  ##     ## ########  ##    ## ##     ## ##    ##  ######  ########
	##################################################################################*/
	local linkedCategories = 	[
									eChallengeCategory.WEAPON_FRAG_GRENADE,
									eChallengeCategory.WEAPON_EMP_GRENADE,
									eChallengeCategory.WEAPON_PROXIMITY_MINE,
									eChallengeCategory.WEAPON_SATCHEL
								]
	SetChallengeCategory( eChallengeCategory.PILOT_ORDNANCE, "#CHALLENGE_CATEGORY_PILOT_ORDNANCE", "#CHALLENGE_CATEGORY_DESC_PILOT_ORDNANCE", "edit_pilots", linkedCategories )

	//------------------
	// 	 Frag Grenade
	//------------------

	local weaponRef = "mp_weapon_frag_grenade"
	SetChallengeCategory( eChallengeCategory.WEAPON_FRAG_GRENADE, "#WPN_FRAG_GRENADE", "", weaponRef )

	AddChallenge( "ch_frag_grenade_kills", "#CHALLENGE_WEAPON_GRENADE_KILLS", "#CHALLENGE_WEAPON_GRENADE_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( [ 10, 25, 50, 100, 150 ] )
		SetChallengeTierBurnCards( 1, ["bc_frag_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_frag_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_frag_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_frag_m2"] )

	AddChallenge( "ch_frag_grenade_pilot_kills", "#CHALLENGE_WEAPON_GRENADE_PILOT_KILLS", "#CHALLENGE_WEAPON_GRENADE_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( [ 5, 10, 20, 30, 50 ] )
		SetChallengeTierBurnCards( 1, ["bc_frag_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_frag_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_frag_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_frag_m2"] )

	AddChallenge( "ch_frag_grenade_grunt_kills", "#CHALLENGE_WEAPON_GRENADE_GRUNT_KILLS", "#CHALLENGE_WEAPON_GRENADE_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( [ 5, 15, 30, 50, 100 ] )
		SetChallengeTierBurnCards( 1, ["bc_frag_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_frag_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_frag_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_frag_m2"] )

	//------------------
	// 	 EMP Grenade
	//------------------

	local weaponRef = "mp_weapon_grenade_emp"
	SetChallengeCategory( eChallengeCategory.WEAPON_EMP_GRENADE, "#WPN_GRENADE_EMP", "", weaponRef )

	AddChallenge( "ch_emp_grenade_kills", "#CHALLENGE_WEAPON_EMP_GRENADE_KILLS", "#CHALLENGE_WEAPON_EMP_GRENADE_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( [ 5, 15, 30, 50, 100 ] )
		SetChallengeTierBurnCards( 1, ["bc_arc_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_arc_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_arc_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_arc_m2"] )

	AddChallenge( "ch_emp_grenade_pilot_kills", "#CHALLENGE_WEAPON_EMP_GRENADE_PILOT_KILLS", "#CHALLENGE_WEAPON_EMP_GRENADE_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( [ 1, 5, 10, 15, 25 ] )
		SetChallengeTierBurnCards( 1, ["bc_arc_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_arc_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_arc_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_arc_m2"] )

	AddChallenge( "ch_emp_grenade_grunt_kills", "#CHALLENGE_WEAPON_EMP_GRENADE_GRUNT_KILLS", "#CHALLENGE_WEAPON_EMP_GRENADE_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( [ 5, 15, 30, 50, 100 ] )
		SetChallengeTierBurnCards( 1, ["bc_arc_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_arc_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_arc_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_arc_m2"] )

	AddChallenge( "ch_emp_grenade_spectre_kills", "#CHALLENGE_WEAPON_EMP_GRENADE_SPECTRE_KILLS", "#CHALLENGE_WEAPON_EMP_GRENADE_SPECTRE_KILLS_DESC", ICON_SPECTRE, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "spectres", weaponRef )
		SetChallengeTiers( [ 5, 10, 20, 30, 50 ] )
		SetChallengeTierBurnCards( 1, ["bc_arc_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_arc_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_arc_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_arc_m2"] )

	//------------------
	// 	Proximity Mine
	//------------------

	local weaponRef = "mp_weapon_proximity_mine"
	SetChallengeCategory( eChallengeCategory.WEAPON_PROXIMITY_MINE, "#WPN_PROXIMITY_MINE", "", weaponRef )

	AddChallenge( "ch_proximity_mine_kills", "#CHALLENGE_WEAPON_PROXIMITY_MINE_KILLS", "#CHALLENGE_WEAPON_PROXIMITY_MINE_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( [ 10, 25, 50, 100, 150 ] )
		SetChallengeTierBurnCards( 1, ["bc_prox_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_prox_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_prox_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_prox_m2"] )

	AddChallenge( "ch_proximity_mine_pilot_kills", "#CHALLENGE_WEAPON_PROXIMITY_MINE_PILOT_KILLS", "#CHALLENGE_WEAPON_PROXIMITY_MINE_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( [ 1, 5, 15, 30, 50 ] )
		SetChallengeTierBurnCards( 1, ["bc_prox_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_prox_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_prox_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_prox_m2"] )

	AddChallenge( "ch_proximity_mine_grunt_kills", "#CHALLENGE_WEAPON_PROXIMITY_MINE_GRUNT_KILLS", "#CHALLENGE_WEAPON_PROXIMITY_MINE_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( [ 5, 15, 30, 50, 100 ] )
		SetChallengeTierBurnCards( 1, ["bc_prox_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_prox_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_prox_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_prox_m2"] )

	//------------------
	// 	   Satchel
	//------------------

	local weaponRef = "mp_weapon_satchel"
	SetChallengeCategory( eChallengeCategory.WEAPON_SATCHEL, "#WPN_SATCHEL", "", weaponRef )

	AddChallenge( "ch_satchel_kills", "#CHALLENGE_WEAPON_GRENADE_KILLS", "#CHALLENGE_WEAPON_GRENADE_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( [ 10, 25, 50, 100, 150 ] )
		SetChallengeTierBurnCards( 1, ["bc_satchel_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_satchel_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_satchel_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_satchel_m2"] )

	AddChallenge( "ch_satchel_pilot_kills", "#CHALLENGE_WEAPON_GRENADE_PILOT_KILLS", "#CHALLENGE_WEAPON_GRENADE_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( [ 1, 5, 15, 30, 50 ] )
		SetChallengeTierBurnCards( 1, ["bc_satchel_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_satchel_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_satchel_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_satchel_m2"] )

	AddChallenge( "ch_satchel_grunt_kills", "#CHALLENGE_WEAPON_GRENADE_GRUNT_KILLS", "#CHALLENGE_WEAPON_GRENADE_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( [ 5, 15, 30, 50, 100 ] )
		SetChallengeTierBurnCards( 1, ["bc_satchel_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_satchel_m2"] )
		SetChallengeTierBurnCards( 3, ["bc_satchel_m2"] )
		SetChallengeTierBurnCards( 4, ["bc_satchel_m2"] )

	/*#######################################################################
					COOP
	#######################################################################*/
	SetChallengeCategory( eChallengeCategory.COOP, "#CHALLENGE_CATEGORY_COOP", "#CHALLENGE_CATEGORY_DESC_COOP", "challenges_7" )

	AddChallenge( "ch_coop_wins", "#CHALLENGE_COOP_WINS", "#CHALLENGE_COOP_WINS_DESC", ICON_GAMES_WON, null, false )
		SetChallengeStat( "game_stats", "mode_won_coop", null )
		SetChallengeTiers( [ 10, 20, 30 ] )
		SetChallengeTierBurnCards( 0, ["bc_summon_stryder"] )
		SetChallengeTierBurnCards( 1, ["bc_summon_atlas"] )
		SetChallengeTierBurnCards( 2, ["bc_summon_ogre"] )

	AddChallenge( "ch_coop_perfect_waves", "#CHALLENGE_COOP_PERFECT_WAVES", "#CHALLENGE_COOP_PERFECT_WAVES_DESC", ICON_GAMES_MVP, null, false )
		SetChallengeStat( "game_stats", "coop_perfect_waves", null )
		SetChallengeTiers( [ 10, 20, 30 ] )
		SetChallengeTierBurnCards( 0, ["bc_arc_m2", "bc_frag_m2"] )
		SetChallengeTierBurnCards( 1, ["bc_arc_m2", "bc_frag_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_arc_m2", "bc_frag_m2"] )

	AddChallenge( "ch_coop_nuke_titans", "#CHALLENGE_COOP_NUKE_TITANS", "#CHALLENGE_COOP_NUKE_TITANS_DESC", ICON_EJECT, null, false )
		SetChallengeStat( "kills_stats", "coopChallenge_NukeTitan_Kills", null )
		SetChallengeTiers( [ 5, 10, 15 ] )
		SetChallengeTierBurnCards( 0, ["bc_nuclear_core"] )
		SetChallengeTierBurnCards( 1, ["bc_nuclear_core"] )
		SetChallengeTierBurnCards( 2, ["bc_nuclear_core"] )
		
	AddChallenge( "ch_coop_mortar_titans", "#CHALLENGE_COOP_MORTAR_TITANS", "#CHALLENGE_COOP_MORTAR_TITANS_DESC", ICON_TITAN_FALL, null, false )
		SetChallengeStat( "kills_stats", "coopChallenge_MortarTitan_Kills", null )
		SetChallengeTiers( [ 5, 10, 15 ] )
		SetChallengeTierBurnCards( 0, ["bc_titan_rocket_launcher_m2"] )
		SetChallengeTierBurnCards( 1, ["bc_titan_rocket_launcher_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_titan_rocket_launcher_m2"] )
		
	AddChallenge( "ch_coop_emp_titans", "#CHALLENGE_COOP_EMP_TITANS", "#CHALLENGE_COOP_EMP_TITANS_DESC", ICON_TITAN, null, false )
		SetChallengeStat( "kills_stats", "coopChallenge_EmpTitan_Kills", null )
		SetChallengeTiers( [ 5, 10, 15 ] )
		SetChallengeTierBurnCards( 0, ["bc_titan_arc_cannon_m2"] )
		SetChallengeTierBurnCards( 1, ["bc_titan_arc_cannon_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_titan_arc_cannon_m2"] )
		
	AddChallenge( "ch_coop_cloak_drones", "#CHALLENGE_COOP_CLOAK_DRONES", "#CHALLENGE_COOP_CLOAK_DRONES_DESC", ICON_CLOAKED_PILOT, null, false )
		SetChallengeStat( "kills_stats", "coopChallenge_CloakDrone_Kills", null )
		SetChallengeTiers( [ 10, 20, 30 ] )
		SetChallengeTierBurnCards( 0, ["bc_super_cloak"] )
		SetChallengeTierBurnCards( 1, ["bc_super_cloak"] )
		SetChallengeTierBurnCards( 2, ["bc_cloak_forever"] )

	/*
	AddChallenge( "ch_coop_bubble_shield_grunts", "#CHALLENGE_COOP_BUBBLE_SHIELD_GRUNTS", "#CHALLENGE_COOP_BUBBLE_SHIELD_GRUNTS_DESC", ICON_PILOT_MELEE, null, true )
		SetChallengeStat( "kills_stats", "coopChallenge_BubbleShieldGrunt_Kills", null )
		SetChallengeTiers( [ 5, 10, 15 ] )
		SetChallengeTierBurnCards( 0, ["bc_super_sonar"] )
		SetChallengeTierBurnCards( 1, ["bc_super_sonar"] )
		SetChallengeTierBurnCards( 2, ["bc_super_sonar"] )
	*/
	
	AddChallenge( "ch_coop_suicide_spectres", "#CHALLENGE_COOP_SUICIDE_SPECTRES", "#CHALLENGE_COOP_SUICIDE_SPECTRES_DESC", ICON_SPECTRE, null, false )
		SetChallengeStat( "kills_stats", "coopChallenge_SuicideSpectre_Kills", null )
		SetChallengeTiers( [ 40, 80, 120 ] )
		SetChallengeTierBurnCards( 0, ["bc_play_spectre"] )
		SetChallengeTierBurnCards( 1, ["bc_play_spectre"] )
		SetChallengeTierBurnCards( 2, ["bc_play_spectre"] )
		
	AddChallenge( "ch_coop_snipers", "#CHALLENGE_COOP_SNIPERS", "#CHALLENGE_COOP_SNIPERS_DESC", ICON_HEADSHOT, null, false )
		SetChallengeStat( "kills_stats", "coopChallenge_Sniper_Kills", null )
		SetChallengeTiers( [ 3, 6, 9 ] )
		SetChallengeTierBurnCards( 0, ["bc_dmr_m2"] )
		SetChallengeTierBurnCards( 1, ["bc_sniper_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_titan_sniper_m2"] )
		
	AddChallenge( "ch_coop_dropships", "#CHALLENGE_COOP_DROPSHIPS", "#CHALLENGE_COOP_DROPSHIPS_DESC", ICON_FIRST_STRIKE, null, false )
		SetChallengeStat( "kills_stats", "coopChallenge_Dropship_Kills", null )
		SetChallengeTiers( [ 5, 10, 15 ] )
		SetChallengeTierBurnCards( 0, ["bc_rocket_launcher_m2"] )
		SetChallengeTierBurnCards( 1, ["bc_rocket_launcher_m2"] )
		SetChallengeTierBurnCards( 2, ["bc_rocket_launcher_m2"] )

	AddChallenge( "ch_coop_turrets", "#CHALLENGE_COOP_TURRETS", "#CHALLENGE_COOP_TURRETS_DESC", ICON_WEAPON_KILLS, null, false )
		SetChallengeStat( "kills_stats", "coopChallenge_Turret_Kills", null )
		SetChallengeTiers( [ 50, 100, 150 ] )
		SetChallengeTierBurnCards( 0, ["bc_stim_forever"] )
		SetChallengeTierBurnCards( 1, ["bc_stim_forever"] )
		SetChallengeTierBurnCards( 2, ["bc_stim_forever"] )


	/*##################################################################################
					########  ########  ######   ######## ##    ##
					##     ## ##       ##    ##  ##       ###   ##
					##     ## ##       ##        ##       ####  ##
					########  ######   ##   #### ######   ## ## ##
					##   ##   ##       ##    ##  ##       ##  ####
					##    ##  ##       ##    ##  ##       ##   ###
					##     ## ########  ######   ######## ##    ##
	##################################################################################*/

	SetChallengeCategory( eChallengeCategory.REGEN_REQUIREMENTS, "#CHALLENGE_CATEGORY_REGEN", "#CHALLENGE_CATEGORY_DESC_REGEN" )

	//------------------
	// 	 Gen 2 -> 3
	//------------------

	level.regenChallenges[ 2 ] <- []
	level.regenChallenges[ 2 ].append( "ch_shotgun_kills" )
	level.regenChallenges[ 2 ].append( "ch_shotgun_pilot_kills" )
	level.regenChallenges[ 2 ].append( "ch_40mm_kills" )
	level.regenChallenges[ 2 ].append( "ch_40mm_titan_kills" )

	//------------------
	// 	 Gen 3 -> 4
	//------------------

	level.regenChallenges[ 3 ] <- []
	level.regenChallenges[ 3 ].append( "ch_r97_kills" )
	level.regenChallenges[ 3 ].append( "ch_r97_pilot_kills" )
	level.regenChallenges[ 3 ].append( "ch_titan_sniper_kills" )
	level.regenChallenges[ 3 ].append( "ch_titan_sniper_titan_kills" )
	level.regenChallenges[ 3 ].append( "ch_satchel_pilot_kills" )

	//------------------
	// 	 Gen 4 -> 5
	//------------------

	level.regenChallenges[ 4 ] <- []
	level.regenChallenges[ 4 ].append( "ch_dmr_kills" )
	level.regenChallenges[ 4 ].append( "ch_dmr_pilot_kills" )
	level.regenChallenges[ 4 ].append( "ch_rocket_launcher_kills" )
	level.regenChallenges[ 4 ].append( "ch_rocket_launcher_titan_kills" )
	level.regenChallenges[ 4 ].append( "ch_defender_crits" )
	level.regenChallenges[ 4 ].append( "ch_autopistol_pilot_kills" )

	//------------------
	// 	 Gen 5 -> 6
	//------------------

	level.regenChallenges[ 5 ] <- []
	level.regenChallenges[ 5 ].append( "ch_rspn101_kills" )
	level.regenChallenges[ 5 ].append( "ch_rspn101_pilot_kills" )
	level.regenChallenges[ 5 ].append( "ch_arc_cannon_kills" )
	level.regenChallenges[ 5 ].append( "ch_arc_cannon_titan_kills" )
	level.regenChallenges[ 5 ].append( "ch_smr_titan_kills" )
	level.regenChallenges[ 5 ].append( "ch_ejecting_pilot_kills" )

	//------------------
	// 	 Gen 6 -> 7
	//------------------

	level.regenChallenges[ 6 ] <- []
	level.regenChallenges[ 6 ].append( "ch_lmg_kills" )
	level.regenChallenges[ 6 ].append( "ch_lmg_pilot_kills" )
	level.regenChallenges[ 6 ].append( "ch_triple_threat_kills" )
	level.regenChallenges[ 6 ].append( "ch_triple_threat_titan_kills" )
	level.regenChallenges[ 6 ].append( "ch_mgl_titan_kills" )
	level.regenChallenges[ 6 ].append( "ch_rodeo_kills" )

	//------------------
	// 	 Gen 7 -> 8
	//------------------

	level.regenChallenges[ 7 ] <- []
	level.regenChallenges[ 7 ].append( "ch_g2_kills" )
	level.regenChallenges[ 7 ].append( "ch_g2_pilot_kills" )
	level.regenChallenges[ 7 ].append( "ch_xo16_kills" )
	level.regenChallenges[ 7 ].append( "ch_xo16_titan_kills" )
	level.regenChallenges[ 7 ].append( "ch_defender_titan_kills" )
	level.regenChallenges[ 7 ].append( "ch_titanexocutionstryder" )

	//------------------
	// 	 Gen 8 -> 9
	//------------------

	level.regenChallenges[ 8 ] <- []
	level.regenChallenges[ 8 ].append( "ch_car_kills" )
	level.regenChallenges[ 8 ].append( "ch_car_pilot_kills" )
	level.regenChallenges[ 8 ].append( "ch_titanexocutionatlas" )
	level.regenChallenges[ 8 ].append( "ch_archer_titan_kills" )
	level.regenChallenges[ 8 ].append( "ch_games_won" )
	level.regenChallenges[ 8 ].append( "ch_titanfallkill" )
	level.regenChallenges[ 8 ].append( "ch_40mm_crits" )

	//------------------
	// 	 Gen 9 -> 10
	//------------------

	level.regenChallenges[ 9 ] <- []
	level.regenChallenges[ 9 ].append( "ch_smart_pistol_pilot_kills" )
	level.regenChallenges[ 9 ].append( "ch_hemlok_pilot_kills" )
	level.regenChallenges[ 9 ].append( "ch_sniper_pilot_kills" )
	level.regenChallenges[ 9 ].append( "ch_titanexocutionogre" )
	level.regenChallenges[ 9 ].append( "ch_games_mvp" )
	level.regenChallenges[ 9 ].append( "ch_kills_while_cloaked" )
	level.regenChallenges[ 9 ].append( "ch_kills_while_ejecting" )
	level.regenChallenges[ 9 ].append( "ch_xo16_crits" )
	level.regenChallenges[ 9 ].append( "ch_titan_sniper_crits" )

	/*#######################################################################
					########     ###    #### ##       ##    ##
					##     ##   ## ##    ##  ##        ##  ##
					##     ##  ##   ##   ##  ##         ####
					##     ## ##     ##  ##  ##          ##
					##     ## #########  ##  ##          ##
					##     ## ##     ##  ##  ##          ##
					########  ##     ## #### ########    ##
	#######################################################################*/

	SetChallengeCategory( eChallengeCategory.DAILY, "#CHALLENGE_CATEGORY_DAILY", "#CHALLENGE_CATEGORY_DESC_DAILY" )

	AddChallenge( "ch_daily_games_played", "#DAILYCHALLENGE_GAMES_PLAYED", "#DAILYCHALLENGE_GAMES_PLAYED_DESC", ICON_GAMES_PLAYED )
		SetChallengeStat( "game_stats", "game_completed", null )
		SetChallengeTiers( [ 3 ] )
		SetChallengeTierBurnCards( 0, ["bc_cloak_forever", "bc_stim_forever"] )

	AddChallenge( "ch_daily_games_won", "#DAILYCHALLENGE_GAMES_WON", "#DAILYCHALLENGE_GAMES_WON_DESC", ICON_GAMES_WON )
		SetChallengeStat( "game_stats", "game_won", null )
		SetChallengeTiers( [ 2 ] )
		SetChallengeTierBurnCards( 0, ["bc_cloak_forever", "bc_stim_forever"] )

	AddChallenge( "ch_daily_games_mvp", "#DAILYCHALLENGE_GAMES_MVP", "#DAILYCHALLENGE_GAMES_MVP_DESC", ICON_GAMES_MVP )
		SetChallengeStat( "game_stats", "mvp_total", null )
		SetChallengeTiers( [ 1 ] )
		SetChallengeTierBurnCards( 0, ["bc_double_xp", "bc_fast_movespeed", "bc_auto_sonar"] )

	AddChallenge( "ch_daily_titan_falls", "#DAILYCHALLENGE_TITAN_FALLS", "#DAILYCHALLENGE_TITAN_FALLS_DESC", ICON_TITAN_FALL )
		SetChallengeStat( "misc_stats", "titanFalls", null )
		SetChallengeTiers( [ 5 ] )
		SetChallengeTierBurnCards( 0, ["bc_free_build_time_2"] )

	AddChallenge( "ch_daily_rodeos", "#DAILYCHALLENGE_RODEOS", "#DAILYCHALLENGE_RODEOS_DESC", ICON_RODEO )
		SetChallengeStat( "misc_stats", "rodeos", null )
		SetChallengeTiers( [ 5 ] )
		SetChallengeTierBurnCards( 0, ["bc_smr_m2"] )

	AddChallenge( "ch_daily_times_ejected", "#DAILYCHALLENGE_TIMES_EJECTED", "#DAILYCHALLENGE_TIMES_EJECTED_DESC", ICON_EJECT )
		SetChallengeStat( "misc_stats", "timesEjected", null )
		SetChallengeTiers( [ 5 ] )
		SetChallengeTierBurnCards( 0, ["bc_nuclear_core"] )

	AddChallenge( "ch_daily_spectres_leeched", "#DAILYCHALLENGE_SPECTRES_LEECHED", "#DAILYCHALLENGE_SPECTRES_LEECHED_DESC", ICON_DATA_KNIFE )
		SetChallengeStat( "misc_stats", "spectreLeeches", null )
		SetChallengeTiers( [ 8 ] )
		SetChallengeTierBurnCards( 0, ["bc_play_spectre"] )

	//--------------------------------------------------------

	AddChallenge( "ch_daily_grunt_kills", "#DAILYCHALLENGE_GRUNT_KILLS", "#DAILYCHALLENGE_GRUNT_KILLS_DESC", ICON_GRUNT )
		SetChallengeStat( "kills_stats", "grunts", null )
		SetChallengeTiers( [ 10 ] )
		SetChallengeTierBurnCards( 0, ["bc_hunt_soldier", "bc_double_agent"] )

	AddChallenge( "ch_daily_marvin_kills", "#DAILYCHALLENGE_MARVIN_KILLS", "#DAILYCHALLENGE_MARVIN_KILLS_DESC", ICON_MARVIN )
		SetChallengeStat( "kills_stats", "marvins", null )
		SetChallengeTiers( [ 4 ] )
		SetChallengeTierBurnCards( 0, ["bc_double_agent"] )

	AddChallenge( "ch_daily_pilot_kills", "#DAILYCHALLENGE_PILOT_KILLS", "#DAILYCHALLENGE_PILOT_KILLS_DESC", ICON_PILOT )
		SetChallengeStat( "kills_stats", "pilots", null )
		SetChallengeTiers( [ 10 ] )
		SetChallengeTierBurnCards( 0, ["bc_hunt_pilot", "bc_hunt_pilot"] )

	AddChallenge( "ch_daily_titan_kills", "#DAILYCHALLENGE_TITAN_KILLS", "#DAILYCHALLENGE_TITAN_KILLS_DESC", ICON_TITAN )
		SetChallengeStat( "kills_stats", "totalTitans", null )
		SetChallengeTiers( [ 3 ] )
		SetChallengeTierBurnCards( 0, ["bc_hunt_titan", "bc_hunt_titan"] )

	AddChallenge( "ch_daily_spectre_kills", "#DAILYCHALLENGE_SPECTRE_KILLS", "#DAILYCHALLENGE_SPECTRE_KILLS_DESC", ICON_SPECTRE )
		SetChallengeStat( "kills_stats", "spectres", null )
		SetChallengeTiers( [ 5 ] )
		SetChallengeTierBurnCards( 0, ["bc_hunt_spectre", "bc_hunt_spectre"] )

	AddChallenge( "ch_daily_rodeo_kills", "#DAILYCHALLENGE_RODEO_KILLS", "#DAILYCHALLENGE_RODEO_KILLS_DESC", ICON_RODEO )
		SetChallengeStat( "kills_stats", "rodeo_total", null )
		SetChallengeTiers( [ 2 ] )
		SetChallengeTierBurnCards( 0, ["bc_hunt_titan"] )

	AddChallenge( "ch_daily_kills_while_using_burncard", "#DAILYCHALLENGE_KILLS_WHILE_USING_BURNCARD", "#DAILYCHALLENGE_KILLS_WHILE_USING_BURNCARD_DESC", ICON_GRUNT )
		SetChallengeStat( "kills_stats", "totalWhileUsingBurnCard", null )
		SetChallengeTiers( [ 3 ] )

	AddChallenge( "ch_daily_kill_npcs", "#DAILYCHALLENGE_KILL_NPCS", "#DAILYCHALLENGE_KILL_NPCS_DESC", ICON_GRUNT )
		SetChallengeStat( "kills_stats", "totalNPC", null )
		SetChallengeTiers( [ 20 ] )

	AddChallenge( "ch_daily_kills_while_doomed", "#DAILYCHALLENGE_KILLS_WHILE_DOOMED", "#DAILYCHALLENGE_KILLS_WHILE_DOOMED_DESC", ICON_TITAN )
		SetChallengeStat( "kills_stats", "totalTitansWhileDoomed", null )
		SetChallengeTiers( [ 2 ] )

	AddChallenge( "ch_daily_kills_as_stryder", "#DAILYCHALLENGE_KILLS_AS_STRYDER", "#DAILYCHALLENGE_KILLS_AS_STRYDER_DESC", ICON_TITAN )
		SetChallengeStat( "kills_stats", "asTitan_stryder", null )
		SetChallengeTiers( [ 10 ] )

	AddChallenge( "ch_daily_kills_as_atlas", "#DAILYCHALLENGE_KILLS_AS_ATLAS", "#DAILYCHALLENGE_KILLS_AS_ATLAS_DESC", ICON_TITAN )
		SetChallengeStat( "kills_stats", "asTitan_atlas", null )
		SetChallengeTiers( [ 10 ] )

	AddChallenge( "ch_daily_kills_as_ogre", "#DAILYCHALLENGE_KILLS_AS_OGRE", "#DAILYCHALLENGE_KILLS_AS_OGRE_DESC", ICON_TITAN )
		SetChallengeStat( "kills_stats", "asTitan_ogre", null )
		SetChallengeTiers( [ 10 ] )

	AddChallenge( "ch_daily_headshots", "#DAILYCHALLENGE_HEADSHOTS", "#DAILYCHALLENGE_HEADSHOTS_DESC", ICON_HEADSHOT )
		SetChallengeStat( "kills_stats", "pilot_headshots_total", null )
		SetChallengeTiers( [ 3 ] )

	AddChallenge( "ch_daily_kills_evac_ships", "#DAILYCHALLENGE_KILLS_EVAC_SHIPS", "#DAILYCHALLENGE_KILLS_EVAC_SHIPS_DESC", ICON_FIRST_STRIKE )
		SetChallengeStat( "kills_stats", "evacShips", null )
		SetChallengeTiers( [ 1 ] )

	AddChallenge( "ch_daily_kills_flyers", "#DAILYCHALLENGE_KILLS_FLYERS", "#DAILYCHALLENGE_KILLS_FLYERS_DESC", ICON_WEAPON_KILLS )
		SetChallengeStat( "kills_stats", "flyers", null )
		SetChallengeTiers( [ 3 ] )

	AddChallenge( "ch_daily_kills_nuclear_core", "#DAILYCHALLENGE_KILLS_NUCLEAR_CORE", "#DAILYCHALLENGE_KILLS_NUCLEAR_CORE_DESC", ICON_EJECT )
		SetChallengeStat( "kills_stats", "nuclearCore", null )
		SetChallengeTiers( [ 2 ] )

	AddChallenge( "ch_daily_kills_evacuating_enemies", "#DAILYCHALLENGE_KILLS_EVACUATING_ENEMIES", "#DAILYCHALLENGE_KILLS_EVACUATING_ENEMIES_DESC", ICON_FIRST_STRIKE )
		SetChallengeStat( "kills_stats", "evacuatingEnemies", null )
		SetChallengeTiers( [ 2 ] )

	//--------------------------------------------------------

	AddChallenge( "ch_daily_first_strikes", "#DAILYCHALLENGE_FIRST_STRIKES", "#DAILYCHALLENGE_FIRST_STRIKES_DESC", ICON_FIRST_STRIKE )
		SetChallengeStat( "kills_stats", "firstStrikes", null )
		SetChallengeTiers( [ 1 ] )
		SetChallengeTierBurnCards( 0, ["bc_rematch" ] )

	AddChallenge( "ch_daily_cloaked_pilot_kills", "#DAILYCHALLENGE_CLOAKED_PILOT_KILLS", "#DAILYCHALLENGE_CLOAKED_PILOT_KILLS_DESC", ICON_CLOAKED_PILOT )
		SetChallengeStat( "kills_stats", "cloakedPilots", null )
		SetChallengeTiers( [ 3 ] )
		SetChallengeTierBurnCards( 0, ["bc_pilot_warning"] )

	AddChallenge( "ch_daily_kills_while_cloaked", "#DAILYCHALLENGE_KILLS_WHILE_CLOAKED", "#DAILYCHALLENGE_KILLS_WHILE_CLOAKED_DESC", ICON_CLOAKED_PILOT )
		SetChallengeStat( "kills_stats", "whileCloaked", null )
		SetChallengeTiers( [ 10 ] )
		SetChallengeTierBurnCards( 0, ["bc_super_cloak"] )

	AddChallenge( "ch_daily_titanFallKill", "#DAILYCHALLENGE_TITAN_FALL_KILL", "#DAILYCHALLENGE_TITAN_FALL_KILL_DESC", ICON_TITAN_FALL )
		SetChallengeStat( "kills_stats", "titanFallKill", null )
		SetChallengeTiers( [ 3 ] )

	AddChallenge( "ch_daily_petTitanKillsFollowMode", "#DAILYCHALLENGE_PET_TITAN_KILLS_ATTACK_MODE", "#DAILYCHALLENGE_PET_TITAN_KILLS_ATTACK_MODE_DESC", ICON_PET_TITAN )
		SetChallengeStat( "kills_stats", "petTitanKillsFollowMode", null )
		SetChallengeTiers( [ 5 ] )
		SetChallengeTierBurnCards( 0, ["bc_hunt_titan"] )

	AddChallenge( "ch_daily_petTitanKillsGuardMode", "#DAILYCHALLENGE_PET_TITAN_KILLS_GUARD_MODE", "#DAILYCHALLENGE_PET_TITAN_KILLS_GUARD_MODE_DESC", ICON_PET_TITAN )
		SetChallengeStat( "kills_stats", "petTitanKillsGuardMode", null )
		SetChallengeTiers( [ 5 ] )
		SetChallengeTierBurnCards( 0, ["bc_hunt_titan"] )

	//--------------------------------------------------------

	AddChallenge( "ch_daily_ejecting_pilot_kills", "#DAILYCHALLENGE_EJECTING_PILOT_KILLS", "#DAILYCHALLENGE_EJECTING_PILOT_KILLS_DESC", ICON_EJECT )
		SetChallengeStat( "kills_stats", "ejectingPilots", null )
		SetChallengeTiers( [ 1 ] )
		SetChallengeTierBurnCards( 0, ["bc_nuclear_core"] )

	AddChallenge( "ch_daily_kills_while_ejecting", "#DAILYCHALLENGE_KILLS_WHILE_EJECTING", "#DAILYCHALLENGE_KILLS_WHILE_EJECTING_DESC", ICON_EJECT )
		SetChallengeStat( "kills_stats", "whileEjecting", null )
		SetChallengeTiers( [ 2 ] )
		SetChallengeTierBurnCards( 0, ["bc_nuclear_core"] )

	AddChallenge( "ch_daily_kills_while_wallrunning", "#DAILYCHALLENGE_KILLS_WHILE_WALLRUNNING", "#DAILYCHALLENGE_KILLS_WHILE_WALLRUNNING_DESC", ICON_WALLRUN )
		SetChallengeStat( "kills_stats", "whileWallrunning", null )
		SetChallengeTiers( [ 2 ] )
		SetChallengeTierBurnCards( 0, ["bc_minimap_scan"] )

	AddChallenge( "ch_daily_kills_while_wallhanging", "#DAILYCHALLENGE_KILLS_WHILE_WALLHANGING", "#DAILYCHALLENGE_KILLS_WHILE_WALLHANGING_DESC", ICON_WALLHANG )
		SetChallengeStat( "kills_stats", "whileWallhanging", null )
		SetChallengeTiers( [ 3 ] )
		SetChallengeTierBurnCards( 0, ["bc_double_agent"] )

	AddChallenge( "ch_daily_titanStepCrush", "#DAILYCHALLENGE_TITAN_STEP_CRUSH", "#DAILYCHALLENGE_TITAN_STEP_CRUSH_DESC", ICON_STEP_CRUSH )
		SetChallengeStat( "kills_stats", "titanStepCrush", null )
		SetChallengeTiers( [ 10 ] )
		SetChallengeTierBurnCards( 0, ["bc_double_xp"] )

	AddChallenge( "ch_daily_titanStepCrushPilot", "#DAILYCHALLENGE_TITAN_STEP_CRUSH_PILOT", "#DAILYCHALLENGE_TITAN_STEP_CRUSH_PILOT_DESC", ICON_STEP_CRUSH )
		SetChallengeStat( "kills_stats", "titanStepCrushPilot", null )
		SetChallengeTiers( [ 1 ] )
		SetChallengeTierBurnCards( 0, ["bc_double_xp"] )

	//--------------------------------------------------------

	AddChallenge( "ch_daily_pilotExecutePilot", "#DAILYCHALLENGE_PILOT_EXECUTE_PILOT", "#DAILYCHALLENGE_PILOT_EXECUTE_PILOT_DESC", ICON_PILOT_EXECUTION )
		SetChallengeStat( "kills_stats", "pilotExecutePilot", null )
		SetChallengeTiers( [ 3 ] )
		SetChallengeTierBurnCards( 0, ["bc_hunt_pilot"] )

	AddChallenge( "ch_daily_pilotKickMelee", "#DAILYCHALLENGE_PILOT_KICK_MELEE", "#DAILYCHALLENGE_PILOT_KICK_MELEE_DESC", ICON_PILOT_MELEE )
		SetChallengeStat( "kills_stats", "pilotKickMelee", null )
		SetChallengeTiers( [ 5 ] )
		SetChallengeTierBurnCards( 0, ["bc_hunt_pilot"] )

	AddChallenge( "ch_daily_pilotKickMeleePilot", "#DAILYCHALLENGE_PILOT_KICK_MELEE_PILOT", "#DAILYCHALLENGE_PILOT_KICK_MELEE_PILOT_DESC", ICON_PILOT_MELEE )
		SetChallengeStat( "kills_stats", "pilotKickMeleePilot", null )
		SetChallengeTiers( [ 3 ] )
		SetChallengeTierBurnCards( 0, ["bc_hunt_pilot"] )

	AddChallenge( "ch_daily_titanMelee", "#DAILYCHALLENGE_TITAN_MELEE", "#DAILYCHALLENGE_TITAN_MELEE_DESC", ICON_TITAN_MELEE )
		SetChallengeStat( "kills_stats", "titanMelee", null )
		SetChallengeTiers( [ 10 ] )
		SetChallengeTierBurnCards( 0, ["bc_hunt_titan"] )

	AddChallenge( "ch_daily_titanMeleePilot", "#DAILYCHALLENGE_TITAN_MELEE_PILOT", "#DAILYCHALLENGE_TITAN_MELEE_PILOT_DESC", ICON_TITAN_MELEE )
		SetChallengeStat( "kills_stats", "titanMeleePilot", null )
		SetChallengeTiers( [ 1 ] )
		SetChallengeTierBurnCards( 0, ["bc_hunt_titan"] )

	AddChallenge( "ch_daily_titanExocutionStryder", "#DAILYCHALLENGE_TITAN_EXECUTION_STRYDER", "#DAILYCHALLENGE_TITAN_EXECUTION_STRYDER_DESC", ICON_TITAN_EXECUTION )
		SetChallengeStat( "kills_stats", "titanExocutionStryder", null )
		SetChallengeTiers( [ 1 ] )
		SetChallengeTierBurnCards( 0, ["bc_hunt_titan"] )

	AddChallenge( "ch_daily_titanExocutionAtlas", "#DAILYCHALLENGE_TITAN_EXECUTION_ATLAS", "#DAILYCHALLENGE_TITAN_EXECUTION_ATLAS_DESC", ICON_TITAN_EXECUTION )
		SetChallengeStat( "kills_stats", "titanExocutionAtlas", null )
		SetChallengeTiers( [ 1 ] )
		SetChallengeTierBurnCards( 0, ["bc_hunt_titan"] )

	AddChallenge( "ch_daily_titanExocutionOgre", "#DAILYCHALLENGE_TITAN_EXECUTION_OGRE", "#DAILYCHALLENGE_TITAN_EXECUTION_OGRE_DESC", ICON_TITAN_EXECUTION )
		SetChallengeStat( "kills_stats", "titanExocutionOgre", null )
		SetChallengeTiers( [ 1 ] )
		SetChallengeTierBurnCards( 0, ["bc_hunt_titan"] )

	//------------------
	// 		40mm
	//------------------

	local weaponRef = "mp_titanweapon_40mm"

	AddChallenge( "ch_daily_40mm_kills", "#DAILYCHALLENGE_WEAPON_KILLS", "#DAILYCHALLENGE_WEAPON_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( [ 30 ] )

	AddChallenge( "ch_daily_40mm_pilot_kills", "#DAILYCHALLENGE_WEAPON_PILOT_KILLS", "#DAILYCHALLENGE_WEAPON_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( [ 10 ] )
		SetChallengeTierBurnCards( 0, ["bc_hunt_pilot"] )

	AddChallenge( "ch_daily_40mm_titan_kills", "#DAILYCHALLENGE_WEAPON_TITAN_KILLS", "#DAILYCHALLENGE_WEAPON_TITAN_KILLS_DESC", ICON_TITAN, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "titansTotal", weaponRef )
		SetChallengeTiers( [ 10 ] )
		SetChallengeTierBurnCards( 0, ["bc_hunt_titan"] )

	AddChallenge( "ch_daily_40mm_grunt_kills", "#DAILYCHALLENGE_WEAPON_GRUNT_KILLS", "#DAILYCHALLENGE_WEAPON_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( [ 20 ] )
		SetChallengeTierBurnCards( 0, ["bc_hunt_soldier"] )

	AddChallenge( "ch_daily_40mm_crits", "#DAILYCHALLENGE_WEAPON_CRITS", "#DAILYCHALLENGE_WEAPON_CRITS_DESC", ICON_CRITICAL_HIT, weaponRef )
		SetChallengeStat( "weapon_stats", "critHits", weaponRef )
		SetChallengeTiers( [ 15 ] )

	//------------------
	// 		XO-16
	//------------------

	local weaponRef = "mp_titanweapon_xo16"

	AddChallenge( "ch_daily_xo16_kills", "#DAILYCHALLENGE_WEAPON_KILLS", "#DAILYCHALLENGE_WEAPON_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( [ 30 ] )

	AddChallenge( "ch_daily_xo16_pilot_kills", "#DAILYCHALLENGE_WEAPON_PILOT_KILLS", "#DAILYCHALLENGE_WEAPON_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( [ 10 ] )
		SetChallengeTierBurnCards( 0, ["bc_hunt_pilot"] )

	AddChallenge( "ch_daily_xo16_titan_kills", "#DAILYCHALLENGE_WEAPON_TITAN_KILLS", "#DAILYCHALLENGE_WEAPON_TITAN_KILLS_DESC", ICON_TITAN, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "titansTotal", weaponRef )
		SetChallengeTiers( [ 10 ] )
		SetChallengeTierBurnCards( 0, ["bc_hunt_titan"] )

	AddChallenge( "ch_daily_xo16_grunt_kills", "#DAILYCHALLENGE_WEAPON_GRUNT_KILLS", "#DAILYCHALLENGE_WEAPON_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( [ 20 ] )
		SetChallengeTierBurnCards( 0, ["bc_hunt_soldier"] )

	AddChallenge( "ch_daily_xo16_crits", "#DAILYCHALLENGE_WEAPON_CRITS", "#DAILYCHALLENGE_WEAPON_CRITS_DESC", ICON_CRITICAL_HIT, weaponRef )
		SetChallengeStat( "weapon_stats", "critHits", weaponRef )
		SetChallengeTiers( [ 15 ] )

	//------------------
	// 	 Titan Sniper
	//------------------

	local weaponRef = "mp_titanweapon_sniper"

	AddChallenge( "ch_daily_titan_sniper_kills", "#DAILYCHALLENGE_WEAPON_KILLS", "#DAILYCHALLENGE_WEAPON_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( [ 30 ] )

	AddChallenge( "ch_daily_titan_sniper_pilot_kills", "#DAILYCHALLENGE_WEAPON_PILOT_KILLS", "#DAILYCHALLENGE_WEAPON_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( [ 10 ] )
		SetChallengeTierBurnCards( 0, ["bc_hunt_pilot"] )

	AddChallenge( "ch_daily_titan_sniper_titan_kills", "#DAILYCHALLENGE_WEAPON_TITAN_KILLS", "#DAILYCHALLENGE_WEAPON_TITAN_KILLS_DESC", ICON_TITAN, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "titansTotal", weaponRef )
		SetChallengeTiers( [ 10 ] )
		SetChallengeTierBurnCards( 0, ["bc_hunt_titan"] )

	AddChallenge( "ch_daily_titan_sniper_grunt_kills", "#DAILYCHALLENGE_WEAPON_GRUNT_KILLS", "#DAILYCHALLENGE_WEAPON_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( [ 20 ] )

	AddChallenge( "ch_daily_titan_sniper_crits", "#DAILYCHALLENGE_WEAPON_CRITS", "#DAILYCHALLENGE_WEAPON_CRITS_DESC", ICON_CRITICAL_HIT, weaponRef )
		SetChallengeStat( "weapon_stats", "critHits", weaponRef )
		SetChallengeTiers( [ 10 ] )

	//------------------
	// 	 Arc Cannon
	//------------------

	local weaponRef = "mp_titanweapon_arc_cannon"

	AddChallenge( "ch_daily_arc_cannon_kills", "#DAILYCHALLENGE_WEAPON_KILLS", "#DAILYCHALLENGE_WEAPON_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( [ 20 ] )

	AddChallenge( "ch_daily_arc_cannon_pilot_kills", "#DAILYCHALLENGE_WEAPON_PILOT_KILLS", "#DAILYCHALLENGE_WEAPON_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( [ 10 ] )
		SetChallengeTierBurnCards( 0, ["bc_hunt_pilot"] )

	AddChallenge( "ch_daily_arc_cannon_titan_kills", "#DAILYCHALLENGE_WEAPON_TITAN_KILLS", "#DAILYCHALLENGE_WEAPON_TITAN_KILLS_DESC", ICON_TITAN, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "titansTotal", weaponRef )
		SetChallengeTiers( [ 10 ] )
		SetChallengeTierBurnCards( 0, ["bc_hunt_titan"] )

	AddChallenge( "ch_daily_arc_cannon_grunt_kills", "#DAILYCHALLENGE_WEAPON_GRUNT_KILLS", "#DAILYCHALLENGE_WEAPON_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( [ 20 ] )

	AddChallenge( "ch_daily_arc_cannon_multi_kills", "#DAILYCHALLENGE_ARC_CANNON_MULTI_KILLS", "#DAILYCHALLENGE_ARC_CANNON_MULTI_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "misc_stats", "arcCannonMultiKills", null )
		SetChallengeTiers( [ 5 ] )

	//------------------
	// Rocket Launcher
	//------------------

	local weaponRef = "mp_titanweapon_rocket_launcher"

	AddChallenge( "ch_daily_rocket_launcher_kills", "#DAILYCHALLENGE_WEAPON_KILLS", "#DAILYCHALLENGE_WEAPON_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( [ 20 ] )

	AddChallenge( "ch_daily_rocket_launcher_pilot_kills", "#DAILYCHALLENGE_WEAPON_PILOT_KILLS", "#DAILYCHALLENGE_WEAPON_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( [ 10 ] )
		SetChallengeTierBurnCards( 0, ["bc_hunt_pilot"] )

	AddChallenge( "ch_daily_rocket_launcher_titan_kills", "#DAILYCHALLENGE_WEAPON_TITAN_KILLS", "#DAILYCHALLENGE_WEAPON_TITAN_KILLS_DESC", ICON_TITAN, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "titansTotal", weaponRef )
		SetChallengeTiers( [ 10 ] )
		SetChallengeTierBurnCards( 0, ["bc_hunt_titan"] )

	AddChallenge( "ch_daily_rocket_launcher_grunt_kills", "#DAILYCHALLENGE_WEAPON_GRUNT_KILLS", "#DAILYCHALLENGE_WEAPON_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( [ 15 ] )

	//------------------
	// 	 Triple Threat
	//------------------

	local weaponRef = "mp_titanweapon_triple_threat"

	AddChallenge( "ch_daily_triple_threat_kills", "#DAILYCHALLENGE_WEAPON_KILLS", "#DAILYCHALLENGE_WEAPON_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( [ 20 ] )

	AddChallenge( "ch_daily_triple_threat_pilot_kills", "#DAILYCHALLENGE_WEAPON_PILOT_KILLS", "#DAILYCHALLENGE_WEAPON_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( [ 10 ] )
		SetChallengeTierBurnCards( 0, ["bc_hunt_pilot"] )

	AddChallenge( "ch_daily_triple_threat_titan_kills", "#DAILYCHALLENGE_WEAPON_TITAN_KILLS", "#DAILYCHALLENGE_WEAPON_TITAN_KILLS_DESC", ICON_TITAN, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "titansTotal", weaponRef )
		SetChallengeTiers( [ 5 ] )
		SetChallengeTierBurnCards( 0, ["bc_hunt_titan"] )

	AddChallenge( "ch_daily_triple_threat_grunt_kills", "#DAILYCHALLENGE_WEAPON_GRUNT_KILLS", "#DAILYCHALLENGE_WEAPON_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( [ 15 ] )

	//------------------
	// Salvo Rockets
	//------------------

	local weaponRef = "mp_titanweapon_salvo_rockets"

	AddChallenge( "ch_daily_salvo_rockets_kills", "#DAILYCHALLENGE_WEAPON_KILLS", "#DAILYCHALLENGE_WEAPON_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( [ 20 ] )

	AddChallenge( "ch_daily_salvo_rockets_pilot_kills", "#DAILYCHALLENGE_WEAPON_PILOT_KILLS", "#DAILYCHALLENGE_WEAPON_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( [ 5 ] )
		SetChallengeTierBurnCards( 0, ["bc_hunt_pilot"] )

	AddChallenge( "ch_daily_salvo_rockets_titan_kills", "#DAILYCHALLENGE_WEAPON_TITAN_KILLS", "#DAILYCHALLENGE_WEAPON_TITAN_KILLS_DESC", ICON_TITAN, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "titansTotal", weaponRef )
		SetChallengeTiers( [ 5 ] )
		SetChallengeTierBurnCards( 0, ["bc_hunt_titan"] )

	AddChallenge( "ch_daily_salvo_rockets_grunt_kills", "#DAILYCHALLENGE_WEAPON_GRUNT_KILLS", "#DAILYCHALLENGE_WEAPON_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( [ 15 ] )

	//------------------
	//  Homing Rockets ( Slaved Warheads )
	//------------------

	local weaponRef = "mp_titanweapon_homing_rockets"

	AddChallenge( "ch_daily_homing_rockets_titan_kills", "#DAILYCHALLENGE_WEAPON_TITAN_KILLS", "#DAILYCHALLENGE_WEAPON_TITAN_KILLS_DESC", ICON_TITAN, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "titansTotal", weaponRef )
		SetChallengeTiers( [ 5 ] )

	//------------------
	// Cluster Rockets
	//------------------

	local weaponRef = "mp_titanweapon_dumbfire_rockets"

	AddChallenge( "ch_daily_dumbfire_rockets_kills", "#DAILYCHALLENGE_WEAPON_KILLS", "#DAILYCHALLENGE_WEAPON_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( [ 10 ] )

	AddChallenge( "ch_daily_dumbfire_rockets_pilot_kills", "#DAILYCHALLENGE_WEAPON_PILOT_KILLS", "#DAILYCHALLENGE_WEAPON_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( [ 5 ] )
		SetChallengeTierBurnCards( 0, ["bc_hunt_pilot"] )

	AddChallenge( "ch_daily_dumbfire_rockets_titan_kills", "#DAILYCHALLENGE_WEAPON_TITAN_KILLS", "#DAILYCHALLENGE_WEAPON_TITAN_KILLS_DESC", ICON_TITAN, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "titansTotal", weaponRef )
		SetChallengeTiers( [ 5 ] )
		SetChallengeTierBurnCards( 0, ["bc_hunt_titan"] )

	AddChallenge( "ch_daily_dumbfire_rockets_grunt_kills", "#DAILYCHALLENGE_WEAPON_GRUNT_KILLS", "#DAILYCHALLENGE_WEAPON_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( [ 10 ] )

	//------------------
	// Shoulder Rockets ( Multi-Target Missile System )
	//------------------

	local weaponRef = "mp_titanweapon_shoulder_rockets"

	AddChallenge( "ch_daily_shoulder_rockets_titan_kills", "#DAILYCHALLENGE_WEAPON_TITAN_KILLS", "#DAILYCHALLENGE_WEAPON_TITAN_KILLS_DESC", ICON_TITAN, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "titansTotal", weaponRef )
		SetChallengeTiers( [ 5 ] )
		SetChallengeTierBurnCards( 0, ["bc_hunt_titan"] )

	//------------------
	// 	Smart Pistol
	//------------------

	local weaponRef = "mp_weapon_smart_pistol"

	AddChallenge( "ch_daily_smart_pistol_kills", "#DAILYCHALLENGE_WEAPON_KILLS", "#DAILYCHALLENGE_WEAPON_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( [ 20 ] )
		SetChallengeTierBurnCards( 0, ["bc_smart_pistol_m2"] )

	AddChallenge( "ch_daily_smart_pistol_pilot_kills", "#DAILYCHALLENGE_WEAPON_PILOT_KILLS", "#DAILYCHALLENGE_WEAPON_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( [ 10 ] )
		SetChallengeTierBurnCards( 0, ["bc_smart_pistol_m2"] )

	AddChallenge( "ch_daily_smart_pistol_spectre_kills", "#DAILYCHALLENGE_WEAPON_SPECTRE_KILLS", "#DAILYCHALLENGE_WEAPON_SPECTRE_KILLS_DESC", ICON_SPECTRE, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "spectres", weaponRef )
		SetChallengeTiers( [ 10 ] )
		SetChallengeTierBurnCards( 0, ["bc_smart_pistol_m2"] )

	AddChallenge( "ch_daily_smart_pistol_grunt_kills", "#DAILYCHALLENGE_WEAPON_GRUNT_KILLS", "#DAILYCHALLENGE_WEAPON_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( [ 15 ] )
		SetChallengeTierBurnCards( 0, ["bc_smart_pistol_m2"] )

	//------------------
	// 	   Shotgun
	//------------------

	local weaponRef = "mp_weapon_shotgun"

	AddChallenge( "ch_daily_shotgun_kills", "#DAILYCHALLENGE_WEAPON_KILLS", "#DAILYCHALLENGE_WEAPON_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( [ 20 ] )
		SetChallengeTierBurnCards( 0, ["bc_shotgun_m2"] )

	AddChallenge( "ch_daily_shotgun_pilot_kills", "#DAILYCHALLENGE_WEAPON_PILOT_KILLS", "#DAILYCHALLENGE_WEAPON_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( [ 10 ] )
		SetChallengeTierBurnCards( 0, ["bc_shotgun_m2"] )

	AddChallenge( "ch_daily_shotgun_spectre_kills", "#DAILYCHALLENGE_WEAPON_SPECTRE_KILLS", "#DAILYCHALLENGE_WEAPON_SPECTRE_KILLS_DESC", ICON_SPECTRE, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "spectres", weaponRef )
		SetChallengeTiers( [ 10 ] )
		SetChallengeTierBurnCards( 0, ["bc_shotgun_m2"] )

	AddChallenge( "ch_daily_shotgun_grunt_kills", "#DAILYCHALLENGE_WEAPON_GRUNT_KILLS", "#DAILYCHALLENGE_WEAPON_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( [ 15 ] )
		SetChallengeTierBurnCards( 0, ["bc_shotgun_m2"] )

	//------------------
	// 		R97
	//------------------

	local weaponRef = "mp_weapon_r97"

	AddChallenge( "ch_daily_r97_kills", "#DAILYCHALLENGE_WEAPON_KILLS", "#DAILYCHALLENGE_WEAPON_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( [ 20 ] )
		SetChallengeTierBurnCards( 0, ["bc_r97_m2"] )

	AddChallenge( "ch_daily_r97_pilot_kills", "#DAILYCHALLENGE_WEAPON_PILOT_KILLS", "#DAILYCHALLENGE_WEAPON_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( [ 10 ] )
		SetChallengeTierBurnCards( 0, ["bc_r97_m2"] )

	AddChallenge( "ch_daily_r97_spectre_kills", "#DAILYCHALLENGE_WEAPON_SPECTRE_KILLS", "#DAILYCHALLENGE_WEAPON_SPECTRE_KILLS_DESC", ICON_SPECTRE, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "spectres", weaponRef )
		SetChallengeTiers( [ 10 ] )
		SetChallengeTierBurnCards( 0, ["bc_r97_m2"] )

	AddChallenge( "ch_daily_r97_grunt_kills", "#DAILYCHALLENGE_WEAPON_GRUNT_KILLS", "#DAILYCHALLENGE_WEAPON_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( [ 15 ] )
		SetChallengeTierBurnCards( 0, ["bc_r97_m2"] )

	AddChallenge( "ch_daily_r97_headshots", "#DAILYCHALLENGE_WEAPON_HEADSHOTS", "#DAILYCHALLENGE_WEAPON_HEADSHOTS_DESC", ICON_HEADSHOT, weaponRef )
		SetChallengeStat( "weapon_stats", "headshots", weaponRef )
		SetChallengeTiers( [ 15 ] )
		SetChallengeTierBurnCards( 0, ["bc_r97_m2"] )

	//------------------
	// 		CAR
	//------------------

	local weaponRef = "mp_weapon_car"

	AddChallenge( "ch_daily_car_kills", "#DAILYCHALLENGE_WEAPON_KILLS", "#DAILYCHALLENGE_WEAPON_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( [ 20 ] )
		SetChallengeTierBurnCards( 0, ["bc_car_m2"] )

	AddChallenge( "ch_daily_car_pilot_kills", "#DAILYCHALLENGE_WEAPON_PILOT_KILLS", "#DAILYCHALLENGE_WEAPON_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( [ 10 ] )
		SetChallengeTierBurnCards( 0, ["bc_car_m2"] )

	AddChallenge( "ch_daily_car_spectre_kills", "#DAILYCHALLENGE_WEAPON_SPECTRE_KILLS", "#DAILYCHALLENGE_WEAPON_SPECTRE_KILLS_DESC", ICON_SPECTRE, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "spectres", weaponRef )
		SetChallengeTiers( [ 10 ] )
		SetChallengeTierBurnCards( 0, ["bc_car_m2"] )

	AddChallenge( "ch_daily_car_grunt_kills", "#DAILYCHALLENGE_WEAPON_GRUNT_KILLS", "#DAILYCHALLENGE_WEAPON_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( [ 25 ] )
		SetChallengeTierBurnCards( 0, ["bc_car_m2"] )

	AddChallenge( "ch_daily_car_headshots", "#DAILYCHALLENGE_WEAPON_HEADSHOTS", "#DAILYCHALLENGE_WEAPON_HEADSHOTS_DESC", ICON_HEADSHOT, weaponRef )
		SetChallengeStat( "weapon_stats", "headshots", weaponRef )
		SetChallengeTiers( [ 15 ] )
		SetChallengeTierBurnCards( 0, ["bc_car_m2"] )

	//------------------
	// 		LMG
	//------------------

	local weaponRef = "mp_weapon_lmg"

	AddChallenge( "ch_daily_lmg_kills", "#DAILYCHALLENGE_WEAPON_KILLS", "#DAILYCHALLENGE_WEAPON_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( [ 20 ] )
		SetChallengeTierBurnCards( 0, ["bc_lmg_m2"] )

	AddChallenge( "ch_daily_lmg_pilot_kills", "#DAILYCHALLENGE_WEAPON_PILOT_KILLS", "#DAILYCHALLENGE_WEAPON_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( [ 10 ] )
		SetChallengeTierBurnCards( 0, ["bc_lmg_m2"] )

	AddChallenge( "ch_daily_lmg_spectre_kills", "#DAILYCHALLENGE_WEAPON_SPECTRE_KILLS", "#DAILYCHALLENGE_WEAPON_SPECTRE_KILLS_DESC", ICON_SPECTRE, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "spectres", weaponRef )
		SetChallengeTiers( [ 10 ] )
		SetChallengeTierBurnCards( 0, ["bc_lmg_m2"] )

	AddChallenge( "ch_daily_lmg_grunt_kills", "#DAILYCHALLENGE_WEAPON_GRUNT_KILLS", "#DAILYCHALLENGE_WEAPON_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( [ 20 ] )
		SetChallengeTierBurnCards( 0, ["bc_lmg_m2"] )

	AddChallenge( "ch_daily_lmg_headshots", "#DAILYCHALLENGE_WEAPON_HEADSHOTS", "#DAILYCHALLENGE_WEAPON_HEADSHOTS_DESC", ICON_HEADSHOT, weaponRef )
		SetChallengeStat( "weapon_stats", "headshots", weaponRef )
		SetChallengeTiers( [ 15 ] )
		SetChallengeTierBurnCards( 0, ["bc_lmg_m2"] )

	//------------------
	// 	  Rspn 101
	//------------------

	local weaponRef = "mp_weapon_rspn101"

	AddChallenge( "ch_daily_rspn101_kills", "#DAILYCHALLENGE_WEAPON_KILLS", "#DAILYCHALLENGE_WEAPON_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( [ 20 ] )
		SetChallengeTierBurnCards( 0, ["bc_rspn101_m2"] )

	AddChallenge( "ch_daily_rspn101_pilot_kills", "#DAILYCHALLENGE_WEAPON_PILOT_KILLS", "#DAILYCHALLENGE_WEAPON_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( [ 10 ] )
		SetChallengeTierBurnCards( 0, ["bc_rspn101_m2"] )

	AddChallenge( "ch_daily_rspn101_spectre_kills", "#DAILYCHALLENGE_WEAPON_SPECTRE_KILLS", "#DAILYCHALLENGE_WEAPON_SPECTRE_KILLS_DESC", ICON_SPECTRE, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "spectres", weaponRef )
		SetChallengeTiers( [ 10 ] )
		SetChallengeTierBurnCards( 0, ["bc_rspn101_m2"] )

	AddChallenge( "ch_daily_rspn101_grunt_kills", "#DAILYCHALLENGE_WEAPON_GRUNT_KILLS", "#DAILYCHALLENGE_WEAPON_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( [ 15 ] )
		SetChallengeTierBurnCards( 0, ["bc_rspn101_m2"] )

	AddChallenge( "ch_daily_rspn101_headshots", "#DAILYCHALLENGE_WEAPON_HEADSHOTS", "#DAILYCHALLENGE_WEAPON_HEADSHOTS_DESC", ICON_HEADSHOT, weaponRef )
		SetChallengeStat( "weapon_stats", "headshots", weaponRef )
		SetChallengeTiers( [ 15 ] )
		SetChallengeTierBurnCards( 0, ["bc_rspn101_m2"] )

	//------------------
	// 	   Hemlok
	//------------------

	local weaponRef = "mp_weapon_hemlok"

	AddChallenge( "ch_daily_hemlok_kills", "#DAILYCHALLENGE_WEAPON_KILLS", "#DAILYCHALLENGE_WEAPON_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( [ 20 ] )
		SetChallengeTierBurnCards( 0, ["bc_hemlok_m2"] )

	AddChallenge( "ch_daily_hemlok_pilot_kills", "#DAILYCHALLENGE_WEAPON_PILOT_KILLS", "#DAILYCHALLENGE_WEAPON_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( [ 10 ] )
		SetChallengeTierBurnCards( 0, ["bc_hemlok_m2"] )

	AddChallenge( "ch_daily_hemlok_spectre_kills", "#DAILYCHALLENGE_WEAPON_SPECTRE_KILLS", "#DAILYCHALLENGE_WEAPON_SPECTRE_KILLS_DESC", ICON_SPECTRE, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "spectres", weaponRef )
		SetChallengeTiers( [ 10 ] )
		SetChallengeTierBurnCards( 0, ["bc_hemlok_m2"] )

	AddChallenge( "ch_daily_hemlok_grunt_kills", "#DAILYCHALLENGE_WEAPON_GRUNT_KILLS", "#DAILYCHALLENGE_WEAPON_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( [ 20 ] )
		SetChallengeTierBurnCards( 0, ["bc_hemlok_m2"] )

	AddChallenge( "ch_daily_hemlok_headshots", "#DAILYCHALLENGE_WEAPON_HEADSHOTS", "#DAILYCHALLENGE_WEAPON_HEADSHOTS_DESC", ICON_HEADSHOT, weaponRef )
		SetChallengeStat( "weapon_stats", "headshots", weaponRef )
		SetChallengeTiers( [ 15 ] )
		SetChallengeTierBurnCards( 0, ["bc_hemlok_m2"] )

	//------------------
	//		 G2
	//------------------

	local weaponRef = "mp_weapon_g2"

	AddChallenge( "ch_daily_g2_kills", "#DAILYCHALLENGE_WEAPON_KILLS", "#DAILYCHALLENGE_WEAPON_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( [ 20 ] )
		SetChallengeTierBurnCards( 0, ["bc_g2_m2"] )

	AddChallenge( "ch_daily_g2_pilot_kills", "#DAILYCHALLENGE_WEAPON_PILOT_KILLS", "#DAILYCHALLENGE_WEAPON_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( [ 10 ] )
		SetChallengeTierBurnCards( 0, ["bc_g2_m2"] )

	AddChallenge( "ch_daily_g2_spectre_kills", "#DAILYCHALLENGE_WEAPON_SPECTRE_KILLS", "#DAILYCHALLENGE_WEAPON_SPECTRE_KILLS_DESC", ICON_SPECTRE, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "spectres", weaponRef )
		SetChallengeTiers( [ 10 ] )
		SetChallengeTierBurnCards( 0, ["bc_g2_m2"] )

	AddChallenge( "ch_daily_g2_grunt_kills", "#DAILYCHALLENGE_WEAPON_GRUNT_KILLS", "#DAILYCHALLENGE_WEAPON_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( [ 20 ] )
		SetChallengeTierBurnCards( 0, ["bc_g2_m2"] )

	AddChallenge( "ch_daily_g2_headshots", "#DAILYCHALLENGE_WEAPON_HEADSHOTS", "#DAILYCHALLENGE_WEAPON_HEADSHOTS_DESC", ICON_HEADSHOT, weaponRef )
		SetChallengeStat( "weapon_stats", "headshots", weaponRef )
		SetChallengeTiers( [ 15 ] )
		SetChallengeTierBurnCards( 0, ["bc_g2_m2"] )

	//------------------
	//		 DMR
	//------------------

	local weaponRef = "mp_weapon_dmr"

	AddChallenge( "ch_daily_dmr_kills", "#DAILYCHALLENGE_WEAPON_KILLS", "#DAILYCHALLENGE_WEAPON_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( [ 20 ] )
		SetChallengeTierBurnCards( 0, ["bc_dmr_m2"] )

	AddChallenge( "ch_daily_dmr_pilot_kills", "#DAILYCHALLENGE_WEAPON_PILOT_KILLS", "#DAILYCHALLENGE_WEAPON_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( [ 10 ] )
		SetChallengeTierBurnCards( 0, ["bc_dmr_m2"] )

	AddChallenge( "ch_daily_dmr_spectre_kills", "#DAILYCHALLENGE_WEAPON_SPECTRE_KILLS", "#DAILYCHALLENGE_WEAPON_SPECTRE_KILLS_DESC", ICON_SPECTRE, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "spectres", weaponRef )
		SetChallengeTiers( [ 10 ] )
		SetChallengeTierBurnCards( 0, ["bc_dmr_m2"] )

	AddChallenge( "ch_daily_dmr_grunt_kills", "#DAILYCHALLENGE_WEAPON_GRUNT_KILLS", "#DAILYCHALLENGE_WEAPON_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( [ 20 ] )
		SetChallengeTierBurnCards( 0, ["bc_dmr_m2"] )

	AddChallenge( "ch_daily_dmr_headshots", "#DAILYCHALLENGE_WEAPON_HEADSHOTS", "#DAILYCHALLENGE_WEAPON_HEADSHOTS_DESC", ICON_HEADSHOT, weaponRef )
		SetChallengeStat( "weapon_stats", "headshots", weaponRef )
		SetChallengeTiers( [ 15 ] )
		SetChallengeTierBurnCards( 0, ["bc_dmr_m2"] )

	//------------------
	//		Sniper
	//------------------

	local weaponRef = "mp_weapon_sniper"

	AddChallenge( "ch_daily_sniper_kills", "#DAILYCHALLENGE_WEAPON_KILLS", "#DAILYCHALLENGE_WEAPON_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( [ 20 ] )
		SetChallengeTierBurnCards( 0, ["bc_sniper_m2"] )

	AddChallenge( "ch_daily_sniper_pilot_kills", "#DAILYCHALLENGE_WEAPON_PILOT_KILLS", "#DAILYCHALLENGE_WEAPON_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( [ 5 ] )
		SetChallengeTierBurnCards( 0, ["bc_sniper_m2"] )

	AddChallenge( "ch_daily_sniper_spectre_kills", "#DAILYCHALLENGE_WEAPON_SPECTRE_KILLS", "#DAILYCHALLENGE_WEAPON_SPECTRE_KILLS_DESC", ICON_SPECTRE, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "spectres", weaponRef )
		SetChallengeTiers( [ 5 ] )
		SetChallengeTierBurnCards( 0, ["bc_sniper_m2"] )

	AddChallenge( "ch_daily_sniper_grunt_kills", "#DAILYCHALLENGE_WEAPON_GRUNT_KILLS", "#DAILYCHALLENGE_WEAPON_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( [ 15 ] )
		SetChallengeTierBurnCards( 0, ["bc_sniper_m2"] )

	//------------------
	//		SMR
	//------------------

	local weaponRef = "mp_weapon_smr"

	AddChallenge( "ch_daily_smr_titan_kills", "#DAILYCHALLENGE_WEAPON_TITAN_KILLS", "#DAILYCHALLENGE_WEAPON_TITAN_KILLS_DESC", ICON_TITAN, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "titansTotal", weaponRef )
		SetChallengeTiers( [ 5 ] )
		SetChallengeTierBurnCards( 0, ["bc_smr_m2"] )

	AddChallenge( "ch_daily_smr_crits", "#DAILYCHALLENGE_WEAPON_CRITS", "#DAILYCHALLENGE_WEAPON_CRITS_DESC", ICON_CRITICAL_HIT, weaponRef )
		SetChallengeStat( "weapon_stats", "critHits", weaponRef )
		SetChallengeTiers( [ 20 ] )
		SetChallengeTierBurnCards( 0, ["bc_smr_m2"] )

	//------------------
	//		MGL
	//------------------

	local weaponRef = "mp_weapon_mgl"

	AddChallenge( "ch_daily_mgl_titan_kills", "#DAILYCHALLENGE_WEAPON_TITAN_KILLS", "#DAILYCHALLENGE_WEAPON_TITAN_KILLS_DESC", ICON_TITAN, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "titansTotal", weaponRef )
		SetChallengeTiers( [ 5 ] )
		SetChallengeTierBurnCards( 0, ["bc_mgl_m2"] )

	//------------------
	//	   Archer
	//------------------

	local weaponRef = "mp_weapon_rocket_launcher"

	AddChallenge( "ch_daily_archer_titan_kills", "#DAILYCHALLENGE_WEAPON_TITAN_KILLS", "#DAILYCHALLENGE_WEAPON_TITAN_KILLS_DESC", ICON_TITAN, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "titansTotal", weaponRef )
		SetChallengeTiers( [ 3 ] )
		SetChallengeTierBurnCards( 0, ["bc_rocket_launcher_m2"] )

	//------------------
	//	   Defender
	//------------------

	local weaponRef = "mp_weapon_defender"

	AddChallenge( "ch_daily_defender_titan_kills", "#DAILYCHALLENGE_WEAPON_TITAN_KILLS", "#DAILYCHALLENGE_WEAPON_TITAN_KILLS_DESC", ICON_TITAN, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "titansTotal", weaponRef )
		SetChallengeTiers( [ 3 ] )
		SetChallengeTierBurnCards( 0, ["bc_defender_m2"] )

	AddChallenge( "ch_daily_defender_crits", "#DAILYCHALLENGE_WEAPON_CRITS", "#DAILYCHALLENGE_WEAPON_CRITS_DESC", ICON_CRITICAL_HIT, weaponRef )
		SetChallengeStat( "weapon_stats", "critHits", weaponRef )
		SetChallengeTiers( [ 5 ] )
		SetChallengeTierBurnCards( 0, ["bc_defender_m2"] )

	//------------------
	// RE45 Autopistol
	//------------------

	local weaponRef = "mp_weapon_autopistol"

	AddChallenge( "ch_daily_autopistol_kills", "#DAILYCHALLENGE_WEAPON_KILLS", "#DAILYCHALLENGE_WEAPON_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( [ 20 ] )
		SetChallengeTierBurnCards( 0, ["bc_autopistol_m2"] )

	AddChallenge( "ch_daily_autopistol_pilot_kills", "#DAILYCHALLENGE_WEAPON_PILOT_KILLS", "#DAILYCHALLENGE_WEAPON_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( [ 5 ] )
		SetChallengeTierBurnCards( 0, ["bc_autopistol_m2"] )

	AddChallenge( "ch_daily_autopistol_spectre_kills", "#DAILYCHALLENGE_WEAPON_SPECTRE_KILLS", "#DAILYCHALLENGE_WEAPON_SPECTRE_KILLS_DESC", ICON_SPECTRE, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "spectres", weaponRef )
		SetChallengeTiers( [ 5 ] )
		SetChallengeTierBurnCards( 0, ["bc_autopistol_m2"] )

	AddChallenge( "ch_daily_autopistol_grunt_kills", "#DAILYCHALLENGE_WEAPON_GRUNT_KILLS", "#DAILYCHALLENGE_WEAPON_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( [ 15 ] )
		SetChallengeTierBurnCards( 0, ["bc_autopistol_m2"] )

	AddChallenge( "ch_daily_autopistol_headshots", "#DAILYCHALLENGE_WEAPON_HEADSHOTS", "#DAILYCHALLENGE_WEAPON_HEADSHOTS_DESC", ICON_HEADSHOT, weaponRef )
		SetChallengeStat( "weapon_stats", "headshots", weaponRef )
		SetChallengeTiers( [ 5 ] )
		SetChallengeTierBurnCards( 0, ["bc_autopistol_m2"] )

	//------------------
	// 		P2011
	//------------------

	local weaponRef = "mp_weapon_semipistol"

	AddChallenge( "ch_daily_semipistol_kills", "#DAILYCHALLENGE_WEAPON_KILLS", "#DAILYCHALLENGE_WEAPON_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( [ 10 ] )
		SetChallengeTierBurnCards( 0, ["bc_semipistol_m2"] )

	AddChallenge( "ch_daily_semipistol_pilot_kills", "#DAILYCHALLENGE_WEAPON_PILOT_KILLS", "#DAILYCHALLENGE_WEAPON_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( [ 5 ] )
		SetChallengeTierBurnCards( 0, ["bc_semipistol_m2"] )

	AddChallenge( "ch_daily_semipistol_spectre_kills", "#DAILYCHALLENGE_WEAPON_SPECTRE_KILLS", "#DAILYCHALLENGE_WEAPON_SPECTRE_KILLS_DESC", ICON_SPECTRE, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "spectres", weaponRef )
		SetChallengeTiers( [ 5 ] )
		SetChallengeTierBurnCards( 0, ["bc_semipistol_m2"] )

	AddChallenge( "ch_daily_semipistol_grunt_kills", "#DAILYCHALLENGE_WEAPON_GRUNT_KILLS", "#DAILYCHALLENGE_WEAPON_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( [ 10 ] )
		SetChallengeTierBurnCards( 0, ["bc_semipistol_m2"] )

	AddChallenge( "ch_daily_semipistol_headshots", "#DAILYCHALLENGE_WEAPON_HEADSHOTS", "#DAILYCHALLENGE_WEAPON_HEADSHOTS_DESC", ICON_HEADSHOT, weaponRef )
		SetChallengeStat( "weapon_stats", "headshots", weaponRef )
		SetChallengeTiers( [ 5 ] )
		SetChallengeTierBurnCards( 0, ["bc_semipistol_m2"] )

	//------------------
	// 	   Wingman
	//------------------

	local weaponRef = "mp_weapon_wingman"

	AddChallenge( "ch_daily_wingman_kills", "#DAILYCHALLENGE_WEAPON_KILLS", "#DAILYCHALLENGE_WEAPON_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( [ 10 ] )
		SetChallengeTierBurnCards( 0, ["bc_wingman_m2"] )

	AddChallenge( "ch_daily_wingman_pilot_kills", "#DAILYCHALLENGE_WEAPON_PILOT_KILLS", "#DAILYCHALLENGE_WEAPON_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( [ 5 ] )
		SetChallengeTierBurnCards( 0, ["bc_wingman_m2"] )

	AddChallenge( "ch_daily_wingman_spectre_kills", "#DAILYCHALLENGE_WEAPON_SPECTRE_KILLS", "#DAILYCHALLENGE_WEAPON_SPECTRE_KILLS_DESC", ICON_SPECTRE, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "spectres", weaponRef )
		SetChallengeTiers( [ 5 ] )
		SetChallengeTierBurnCards( 0, ["bc_wingman_m2"] )

	AddChallenge( "ch_daily_wingman_grunt_kills", "#DAILYCHALLENGE_WEAPON_GRUNT_KILLS", "#DAILYCHALLENGE_WEAPON_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( [ 10 ] )
		SetChallengeTierBurnCards( 0, ["bc_wingman_m2"] )

	AddChallenge( "ch_daily_wingman_headshots", "#DAILYCHALLENGE_WEAPON_HEADSHOTS", "#DAILYCHALLENGE_WEAPON_HEADSHOTS_DESC", ICON_HEADSHOT, weaponRef )
		SetChallengeStat( "weapon_stats", "headshots", weaponRef )
		SetChallengeTiers( [ 5 ] )
		SetChallengeTierBurnCards( 0, ["bc_wingman_m2"] )

	//------------------
	// 	 Frag Grenade
	//------------------

	local weaponRef = "mp_weapon_frag_grenade"

	AddChallenge( "ch_daily_frag_grenade_kills", "#DAILYCHALLENGE_WEAPON_GRENADE_KILLS", "#DAILYCHALLENGE_WEAPON_GRENADE_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( [ 10 ] )
		SetChallengeTierBurnCards( 0, ["bc_frag_m2"] )

	AddChallenge( "ch_daily_frag_grenade_pilot_kills", "#DAILYCHALLENGE_WEAPON_GRENADE_PILOT_KILLS", "#DAILYCHALLENGE_WEAPON_GRENADE_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( [ 5 ] )
		SetChallengeTierBurnCards( 0, ["bc_frag_m2"] )

	AddChallenge( "ch_daily_frag_grenade_grunt_kills", "#DAILYCHALLENGE_WEAPON_GRENADE_GRUNT_KILLS", "#DAILYCHALLENGE_WEAPON_GRENADE_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( [ 10 ] )
		SetChallengeTierBurnCards( 0, ["bc_frag_m2"] )

	//------------------
	// 	 EMP Grenade
	//------------------

	local weaponRef = "mp_weapon_grenade_emp"

	AddChallenge( "ch_daily_emp_grenade_kills", "#DAILYCHALLENGE_WEAPON_EMP_GRENADE_KILLS", "#DAILYCHALLENGE_WEAPON_EMP_GRENADE_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( [ 10 ] )
		SetChallengeTierBurnCards( 0, ["bc_arc_m2"] )

	AddChallenge( "ch_daily_emp_grenade_pilot_kills", "#DAILYCHALLENGE_WEAPON_EMP_GRENADE_PILOT_KILLS", "#DAILYCHALLENGE_WEAPON_EMP_GRENADE_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( [ 5 ] )
		SetChallengeTierBurnCards( 0, ["bc_arc_m2"] )

	AddChallenge( "ch_daily_emp_grenade_grunt_kills", "#DAILYCHALLENGE_WEAPON_EMP_GRENADE_GRUNT_KILLS", "#DAILYCHALLENGE_WEAPON_EMP_GRENADE_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( [ 10 ] )
		SetChallengeTierBurnCards( 0, ["bc_arc_m2"] )

	AddChallenge( "ch_daily_emp_grenade_spectre_kills", "#DAILYCHALLENGE_WEAPON_EMP_GRENADE_SPECTRE_KILLS", "#DAILYCHALLENGE_WEAPON_EMP_GRENADE_SPECTRE_KILLS_DESC", ICON_SPECTRE, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "spectres", weaponRef )
		SetChallengeTiers( [ 5 ] )
		SetChallengeTierBurnCards( 0, ["bc_arc_m2"] )

	//------------------
	// 	Proximity Mine
	//------------------

	local weaponRef = "mp_weapon_proximity_mine"

	AddChallenge( "ch_daily_proximity_mine_kills", "#DAILYCHALLENGE_WEAPON_PROXIMITY_MINE_KILLS", "#DAILYCHALLENGE_WEAPON_PROXIMITY_MINE_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( [ 5 ] )
		SetChallengeTierBurnCards( 0, ["bc_prox_m2"] )

	AddChallenge( "ch_daily_proximity_mine_pilot_kills", "#DAILYCHALLENGE_WEAPON_PROXIMITY_MINE_PILOT_KILLS", "#DAILYCHALLENGE_WEAPON_PROXIMITY_MINE_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( [ 3 ] )
		SetChallengeTierBurnCards( 0, ["bc_prox_m2"] )

	AddChallenge( "ch_daily_proximity_mine_grunt_kills", "#DAILYCHALLENGE_WEAPON_PROXIMITY_MINE_GRUNT_KILLS", "#DAILYCHALLENGE_WEAPON_PROXIMITY_MINE_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( [ 5 ] )
		SetChallengeTierBurnCards( 0, ["bc_prox_m2"] )

	//------------------
	// 	   Satchel
	//------------------

	local weaponRef = "mp_weapon_satchel"

	AddChallenge( "ch_daily_satchel_kills", "#DAILYCHALLENGE_WEAPON_GRENADE_KILLS", "#DAILYCHALLENGE_WEAPON_GRENADE_KILLS_DESC", ICON_WEAPON_KILLS, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "total", weaponRef )
		SetChallengeTiers( [ 10 ] )
		SetChallengeTierBurnCards( 0, ["bc_satchel_m2"] )

	AddChallenge( "ch_daily_satchel_pilot_kills", "#DAILYCHALLENGE_WEAPON_GRENADE_PILOT_KILLS", "#DAILYCHALLENGE_WEAPON_GRENADE_PILOT_KILLS_DESC", ICON_PILOT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "pilots", weaponRef )
		SetChallengeTiers( [ 5 ] )
		SetChallengeTierBurnCards( 0, ["bc_satchel_m2"] )

	AddChallenge( "ch_daily_satchel_grunt_kills", "#DAILYCHALLENGE_WEAPON_GRENADE_GRUNT_KILLS", "#DAILYCHALLENGE_WEAPON_GRENADE_GRUNT_KILLS_DESC", ICON_GRUNT, weaponRef )
		SetChallengeStat( "weapon_kill_stats", "grunts", weaponRef )
		SetChallengeTiers( [ 10 ] )
		SetChallengeTierBurnCards( 0, ["bc_satchel_m2"] )

	//-------------------------------------------------------------

	AddChallenge( "ch_daily_burncards_used", "#DAILYCHALLENGE_USE_BURNCARDS", "#DAILYCHALLENGE_USE_BURNCARDS_DESC", ICON_GAMES_PLAYED )
		SetChallengeStat( "misc_stats", "burnCardsSpent", null )
		SetChallengeTiers( [ 20 ] )
		SetChallengeTierBurnCards( 0, ["bc_auto_sonar"] )

	AddChallenge( "ch_daily_flag_captures", "#DAILYCHALLENGE_CTF_CAPTURES", "#DAILYCHALLENGE_CTF_CAPTURES_DESC", ICON_FIRST_STRIKE )
		SetChallengeStat( "misc_stats", "flagsCaptured", null )
		SetChallengeTiers( [ 2 ] )
		SetChallengeTierBurnCards( 0, ["bc_fast_movespeed", "bc_fast_movespeed"] )

	AddChallenge( "ch_daily_evacs_survived", "#DAILYCHALLENGE_EVACS_SURVIVED", "#DAILYCHALLENGE_EVACS_SURVIVED_DESC", ICON_FIRST_STRIKE )
		SetChallengeStat( "misc_stats", "evacsSurvived", null )
		SetChallengeTiers( [ 2 ] )

	AddChallenge( "ch_daily_hardpoints_captured", "#DAILYCHALLENGE_HARDPOINTS_CAPTURED", "#DAILYCHALLENGE_HARDPOINTS_CAPTURED_DESC", ICON_FIRST_STRIKE )
		SetChallengeStat( "misc_stats", "hardpointsCaptured", null )
		SetChallengeTiers( [ 5 ] )

	AddChallenge( "ch_daily_killing_sprees", "#DAILYCHALLENGE_KILLING_SPREES", "#DAILYCHALLENGE_KILLING_SPREES_DESC", ICON_PILOT )
		SetChallengeStat( "misc_stats", "killingSprees", null )
		SetChallengeTiers( [ 2 ] )

	//-------------------------------------------------------------

	AddChallenge( "ch_daily_play_at", "#DAILYCHALLENGE_PLAY_AT", "#DAILYCHALLENGE_PLAY_AT_DESC", ICON_FIRST_STRIKE )
		SetChallengeStat( "game_stats", "mode_played_at", null )
		SetChallengeTiers( [ 3 ] )
		SetChallengeTierBurnCards( 0, ["bc_nuclear_core"] )

	AddChallenge( "ch_daily_play_ctf", "#DAILYCHALLENGE_PLAY_CTF", "#DAILYCHALLENGE_PLAY_CTF_DESC", ICON_FIRST_STRIKE )
		SetChallengeStat( "game_stats", "mode_played_ctf", null )
		SetChallengeTiers( [ 3 ] )
		SetChallengeTierBurnCards( 0, ["bc_double_xp", "bc_rematch"] )

	AddChallenge( "ch_daily_play_lts", "#DAILYCHALLENGE_PLAY_LTS", "#DAILYCHALLENGE_PLAY_LTS_DESC", ICON_FIRST_STRIKE )
		SetChallengeStat( "game_stats", "mode_played_lts", null )
		SetChallengeTiers( [ 3 ] )
		SetChallengeTierBurnCards( 0, ["bc_double_xp", "bc_rematch"] )

	AddChallenge( "ch_daily_play_cp", "#DAILYCHALLENGE_PLAY_CP", "#DAILYCHALLENGE_PLAY_CP_DESC", ICON_FIRST_STRIKE )
		SetChallengeStat( "game_stats", "mode_played_cp", null )
		SetChallengeTiers( [ 3 ] )
		SetChallengeTierBurnCards( 0, ["bc_double_xp", "bc_rematch"] )

	AddChallenge( "ch_daily_play_tdm", "#DAILYCHALLENGE_PLAY_TDM", "#DAILYCHALLENGE_PLAY_TDM_DESC", ICON_FIRST_STRIKE )
		SetChallengeStat( "game_stats", "mode_played_tdm", null )
		SetChallengeTiers( [ 3 ] )
		SetChallengeTierBurnCards( 0, ["bc_double_xp", "bc_rematch"] )

	AddChallenge( "ch_daily_play_wlts", "#DAILYCHALLENGE_PLAY_WLTS", "#DAILYCHALLENGE_PLAY_WLTS_DESC", ICON_FIRST_STRIKE )
		SetChallengeStat( "game_stats", "mode_played_wlts", null )
		SetChallengeTiers( [ 3 ] )
		SetChallengeTierBurnCards( 0, ["bc_double_xp", "bc_rematch"] )

	AddChallenge( "ch_daily_play_mfd", "#DAILYCHALLENGE_PLAY_MFD", "#DAILYCHALLENGE_PLAY_MFD_DESC", ICON_FIRST_STRIKE )
		SetChallengeStat( "game_stats", "mode_played_mfd", null )
		SetChallengeTiers( [ 3 ] )
		SetChallengeTierBurnCards( 0, ["bc_double_xp", "bc_rematch"] )
		
	AddChallenge( "ch_daily_play_coop", "#DAILYCHALLENGE_PLAY_COOP", "#DAILYCHALLENGE_PLAY_COOP_DESC", ICON_FIRST_STRIKE )
		SetChallengeStat( "game_stats", "mode_played_coop", null )
		SetChallengeTiers( [ 1 ] )
		SetChallengeTierBurnCards( 0, ["bc_wifi_spectre_hack", "bc_double_xp"] )

	AddChallenge( "ch_daily_win_at", "#DAILYCHALLENGE_WIN_AT", "#DAILYCHALLENGE_WIN_AT_DESC", ICON_FIRST_STRIKE )
		SetChallengeStat( "game_stats", "mode_won_at", null )
		SetChallengeTiers( [ 2 ] )
		SetChallengeTierBurnCards( 0, ["bc_nuclear_core"] )

	AddChallenge( "ch_daily_win_ctf", "#DAILYCHALLENGE_WIN_CTF", "#DAILYCHALLENGE_WIN_CTF_DESC", ICON_FIRST_STRIKE )
		SetChallengeStat( "game_stats", "mode_won_ctf", null )
		SetChallengeTiers( [ 2 ] )
		SetChallengeTierBurnCards( 0, ["bc_double_xp", "bc_rematch"] )

	AddChallenge( "ch_daily_win_lts", "#DAILYCHALLENGE_WIN_LTS", "#DAILYCHALLENGE_WIN_LTS_DESC", ICON_FIRST_STRIKE )
		SetChallengeStat( "game_stats", "mode_won_lts", null )
		SetChallengeTiers( [ 2 ] )
		SetChallengeTierBurnCards( 0, ["bc_double_xp", "bc_rematch"] )

	AddChallenge( "ch_daily_win_cp", "#DAILYCHALLENGE_WIN_CP", "#DAILYCHALLENGE_WIN_CP_DESC", ICON_FIRST_STRIKE )
		SetChallengeStat( "game_stats", "mode_won_cp", null )
		SetChallengeTiers( [ 2 ] )
		SetChallengeTierBurnCards( 0, ["bc_double_xp", "bc_rematch"] )

	AddChallenge( "ch_daily_win_tdm", "#DAILYCHALLENGE_WIN_TDM", "#DAILYCHALLENGE_WIN_TDM_DESC", ICON_FIRST_STRIKE )
		SetChallengeStat( "game_stats", "mode_won_tdm", null )
		SetChallengeTiers( [ 2 ] )
		SetChallengeTierBurnCards( 0, ["bc_double_xp", "bc_rematch"] )

	AddChallenge( "ch_daily_win_wlts", "#DAILYCHALLENGE_WIN_WLTS", "#DAILYCHALLENGE_WIN_WLTS_DESC", ICON_FIRST_STRIKE )
		SetChallengeStat( "game_stats", "mode_won_wlts", null )
		SetChallengeTiers( [ 2 ] )
		SetChallengeTierBurnCards( 0, ["bc_double_xp", "bc_rematch"] )

	AddChallenge( "ch_daily_win_mfd", "#DAILYCHALLENGE_WIN_MFD", "#DAILYCHALLENGE_WIN_MFD_DESC", ICON_FIRST_STRIKE )
		SetChallengeStat( "game_stats", "mode_won_mfd", null )
		SetChallengeTiers( [ 2 ] )
		SetChallengeTierBurnCards( 0, ["bc_double_xp", "bc_rematch"] )
		
	AddChallenge( "ch_daily_win_coop", "#DAILYCHALLENGE_WIN_COOP", "#DAILYCHALLENGE_WIN_COOP_DESC", ICON_FIRST_STRIKE )
		SetChallengeStat( "game_stats", "mode_won_coop", null )
		SetChallengeTiers( [ 1 ] )
		SetChallengeTierBurnCards( 0, ["bc_double_xp", "bc_satchel_m2"] )


	//########################################################################################
	// Each day we grab one challenge from each of these lists. They go in order and repeat.
	// For more variety make lists not have the same number of challenges
	//########################################################################################

	level.dailyChallenges[0] <- []
	level.dailyChallenges[0].append( "ch_daily_xo16_pilot_kills" )
	level.dailyChallenges[0].append( "ch_daily_lmg_kills" )
	level.dailyChallenges[0].append( "ch_daily_g2_grunt_kills" )
	level.dailyChallenges[0].append( "ch_daily_hemlok_pilot_kills" )
	level.dailyChallenges[0].append( "ch_daily_sniper_kills" )
	level.dailyChallenges[0].append( "ch_daily_smr_crits" )
	level.dailyChallenges[0].append( "ch_daily_lmg_pilot_kills" )
	level.dailyChallenges[0].append( "ch_daily_homing_rockets_titan_kills" )
	level.dailyChallenges[0].append( "ch_daily_triple_threat_grunt_kills" )
	level.dailyChallenges[0].append( "ch_daily_rspn101_pilot_kills" )
	level.dailyChallenges[0].append( "ch_daily_sniper_spectre_kills" )
	level.dailyChallenges[0].append( "ch_daily_smart_pistol_kills" )
	level.dailyChallenges[0].append( "ch_daily_shotgun_kills" )
	level.dailyChallenges[0].append( "ch_daily_g2_spectre_kills" )
	level.dailyChallenges[0].append( "ch_daily_car_grunt_kills" )
	level.dailyChallenges[0].append( "ch_daily_dumbfire_rockets_pilot_kills" )
	level.dailyChallenges[0].append( "ch_daily_titan_sniper_pilot_kills" )
	level.dailyChallenges[0].append( "ch_daily_arc_cannon_pilot_kills" )
	level.dailyChallenges[0].append( "ch_daily_car_pilot_kills" )
	level.dailyChallenges[0].append( "ch_daily_r97_spectre_kills" )
	level.dailyChallenges[0].append( "ch_daily_salvo_rockets_kills" )
	level.dailyChallenges[0].append( "ch_daily_smart_pistol_grunt_kills" )
	level.dailyChallenges[0].append( "ch_daily_salvo_rockets_grunt_kills" )
	level.dailyChallenges[0].append( "ch_daily_g2_headshots" )
	level.dailyChallenges[0].append( "ch_daily_salvo_rockets_pilot_kills" )
	level.dailyChallenges[0].append( "ch_daily_lmg_grunt_kills" )
	level.dailyChallenges[0].append( "ch_daily_arc_cannon_titan_kills" )
	level.dailyChallenges[0].append( "ch_daily_xo16_kills" )
	level.dailyChallenges[0].append( "ch_daily_g2_pilot_kills" )
	level.dailyChallenges[0].append( "ch_daily_hemlok_headshots" )
	level.dailyChallenges[0].append( "ch_daily_car_kills" )
	level.dailyChallenges[0].append( "ch_daily_triple_threat_pilot_kills" )
	level.dailyChallenges[0].append( "ch_daily_rspn101_kills" )
	level.dailyChallenges[0].append( "ch_daily_defender_crits" )
	level.dailyChallenges[0].append( "ch_daily_car_headshots" )
	level.dailyChallenges[0].append( "ch_daily_40mm_pilot_kills" )
	level.dailyChallenges[0].append( "ch_daily_dmr_kills" )
	level.dailyChallenges[0].append( "ch_daily_r97_kills" )
	level.dailyChallenges[0].append( "ch_daily_dumbfire_rockets_titan_kills" )
	level.dailyChallenges[0].append( "ch_daily_titan_sniper_titan_kills" )
	level.dailyChallenges[0].append( "ch_daily_xo16_grunt_kills" )
	level.dailyChallenges[0].append( "ch_daily_triple_threat_kills" )
	level.dailyChallenges[0].append( "ch_daily_archer_titan_kills" )
	level.dailyChallenges[0].append( "ch_daily_hemlok_kills" )
	level.dailyChallenges[0].append( "ch_daily_r97_grunt_kills" )
	level.dailyChallenges[0].append( "ch_daily_40mm_grunt_kills" )
	level.dailyChallenges[0].append( "ch_daily_lmg_spectre_kills" )
	level.dailyChallenges[0].append( "ch_daily_mgl_titan_kills" )
	level.dailyChallenges[0].append( "ch_daily_dmr_spectre_kills" )
	level.dailyChallenges[0].append( "ch_daily_r97_pilot_kills" )
	level.dailyChallenges[0].append( "ch_daily_rocket_launcher_pilot_kills" )
	level.dailyChallenges[0].append( "ch_daily_smart_pistol_spectre_kills" )
	level.dailyChallenges[0].append( "ch_daily_dmr_pilot_kills" )
	level.dailyChallenges[0].append( "ch_daily_rspn101_spectre_kills" )
	level.dailyChallenges[0].append( "ch_daily_arc_cannon_grunt_kills" )
	level.dailyChallenges[0].append( "ch_daily_rocket_launcher_titan_kills" )
	level.dailyChallenges[0].append( "ch_daily_smr_titan_kills" )
	level.dailyChallenges[0].append( "ch_daily_defender_titan_kills" )
	level.dailyChallenges[0].append( "ch_daily_shotgun_spectre_kills" )
	level.dailyChallenges[0].append( "ch_daily_40mm_kills" )
	level.dailyChallenges[0].append( "ch_daily_rspn101_headshots" )
	level.dailyChallenges[0].append( "ch_daily_g2_kills" )
	level.dailyChallenges[0].append( "ch_daily_hemlok_spectre_kills" )
	level.dailyChallenges[0].append( "ch_daily_shoulder_rockets_titan_kills" )
	level.dailyChallenges[0].append( "ch_daily_dumbfire_rockets_kills" )
	level.dailyChallenges[0].append( "ch_daily_rocket_launcher_grunt_kills" )
	level.dailyChallenges[0].append( "ch_daily_xo16_titan_kills" )
	level.dailyChallenges[0].append( "ch_daily_40mm_titan_kills" )
	level.dailyChallenges[0].append( "ch_daily_rspn101_grunt_kills" )
	level.dailyChallenges[0].append( "ch_daily_titan_sniper_grunt_kills" )
	level.dailyChallenges[0].append( "ch_daily_sniper_grunt_kills" )
	level.dailyChallenges[0].append( "ch_daily_titan_sniper_crits" )
	level.dailyChallenges[0].append( "ch_daily_40mm_crits" )
	level.dailyChallenges[0].append( "ch_daily_rocket_launcher_kills" )
	level.dailyChallenges[0].append( "ch_daily_sniper_pilot_kills" )
	level.dailyChallenges[0].append( "ch_daily_hemlok_grunt_kills" )
	level.dailyChallenges[0].append( "ch_daily_r97_headshots" )
	level.dailyChallenges[0].append( "ch_daily_arc_cannon_kills" )
	level.dailyChallenges[0].append( "ch_daily_triple_threat_titan_kills" )
	level.dailyChallenges[0].append( "ch_daily_car_spectre_kills" )
	level.dailyChallenges[0].append( "ch_daily_shotgun_pilot_kills" )
	level.dailyChallenges[0].append( "ch_daily_lmg_headshots" )
	level.dailyChallenges[0].append( "ch_daily_dmr_grunt_kills" )
	level.dailyChallenges[0].append( "ch_daily_shotgun_grunt_kills" )
	level.dailyChallenges[0].append( "ch_daily_arc_cannon_multi_kills" )
	level.dailyChallenges[0].append( "ch_daily_dumbfire_rockets_grunt_kills" )
	level.dailyChallenges[0].append( "ch_daily_dmr_headshots" )
	level.dailyChallenges[0].append( "ch_daily_salvo_rockets_titan_kills" )
	level.dailyChallenges[0].append( "ch_daily_smart_pistol_pilot_kills" )
	level.dailyChallenges[0].append( "ch_daily_titan_sniper_kills" )
	level.dailyChallenges[0].append( "ch_daily_xo16_crits" )

	level.dailyChallenges[1] <- []
	level.dailyChallenges[1].append( "ch_daily_emp_grenade_kills" )
	level.dailyChallenges[1].append( "ch_daily_win_mfd" )
	level.dailyChallenges[1].append( "ch_daily_win_coop" )
	level.dailyChallenges[1].append( "ch_daily_times_ejected" )
	level.dailyChallenges[1].append( "ch_daily_play_ctf" )
	level.dailyChallenges[1].append( "ch_daily_proximity_mine_grunt_kills" )
	level.dailyChallenges[1].append( "ch_daily_wingman_spectre_kills" )
	level.dailyChallenges[1].append( "ch_daily_frag_grenade_kills" )
	level.dailyChallenges[1].append( "ch_daily_evacs_survived" )
	level.dailyChallenges[1].append( "ch_daily_semipistol_pilot_kills" )
	level.dailyChallenges[1].append( "ch_daily_emp_grenade_grunt_kills" )
	level.dailyChallenges[1].append( "ch_daily_play_cp" )
	level.dailyChallenges[1].append( "ch_daily_burncards_used" )
	level.dailyChallenges[1].append( "ch_daily_play_mfd" )
	level.dailyChallenges[1].append( "ch_daily_play_coop" )
	level.dailyChallenges[1].append( "ch_daily_satchel_kills" )
	level.dailyChallenges[1].append( "ch_daily_hardpoints_captured" )
	level.dailyChallenges[1].append( "ch_daily_proximity_mine_pilot_kills" )
	level.dailyChallenges[1].append( "ch_daily_wingman_grunt_kills" )
	level.dailyChallenges[1].append( "ch_daily_titan_falls" )
	level.dailyChallenges[1].append( "ch_daily_games_won" )
	level.dailyChallenges[1].append( "ch_daily_win_lts" )
	level.dailyChallenges[1].append( "ch_daily_satchel_pilot_kills" )
	level.dailyChallenges[1].append( "ch_daily_autopistol_grunt_kills" )
	level.dailyChallenges[1].append( "ch_daily_emp_grenade_spectre_kills" )
	level.dailyChallenges[1].append( "ch_daily_wingman_pilot_kills" )
	level.dailyChallenges[1].append( "ch_daily_spectres_leeched" )
	level.dailyChallenges[1].append( "ch_daily_autopistol_spectre_kills" )
	level.dailyChallenges[1].append( "ch_daily_semipistol_spectre_kills" )
	level.dailyChallenges[1].append( "ch_daily_frag_grenade_grunt_kills" )
	level.dailyChallenges[1].append( "ch_daily_play_at" )
	level.dailyChallenges[1].append( "ch_daily_proximity_mine_kills" )
	level.dailyChallenges[1].append( "ch_daily_flag_captures" )
	level.dailyChallenges[1].append( "ch_daily_autopistol_pilot_kills" )
	level.dailyChallenges[1].append( "ch_daily_satchel_grunt_kills" )
	//level.dailyChallenges[1].append( "ch_daily_play_wlts" )
	level.dailyChallenges[1].append( "ch_daily_frag_grenade_pilot_kills" )
	level.dailyChallenges[1].append( "ch_daily_win_tdm" )
	level.dailyChallenges[1].append( "ch_daily_wingman_headshots" )
	level.dailyChallenges[1].append( "ch_daily_play_lts" )
	level.dailyChallenges[1].append( "ch_daily_games_played" )
	level.dailyChallenges[1].append( "ch_daily_play_tdm" )
	level.dailyChallenges[1].append( "ch_daily_semipistol_grunt_kills" )
	level.dailyChallenges[1].append( "ch_daily_win_cp" )
	level.dailyChallenges[1].append( "ch_daily_games_mvp" )
	level.dailyChallenges[1].append( "ch_daily_rodeos" )
	level.dailyChallenges[1].append( "ch_daily_emp_grenade_pilot_kills" )
	level.dailyChallenges[1].append( "ch_daily_semipistol_kills" )
	level.dailyChallenges[1].append( "ch_daily_win_ctf" )
	level.dailyChallenges[1].append( "ch_daily_autopistol_headshots" )
	level.dailyChallenges[1].append( "ch_daily_wingman_kills" )
	level.dailyChallenges[1].append( "ch_daily_autopistol_kills" )
	level.dailyChallenges[1].append( "ch_daily_win_at" )
	level.dailyChallenges[1].append( "ch_daily_semipistol_headshots" )
	//level.dailyChallenges[1].append( "ch_daily_win_wlts" )

	level.dailyChallenges[2] <- []
	level.dailyChallenges[2].append( "ch_daily_kills_nuclear_core" )
	level.dailyChallenges[2].append( "ch_daily_kills_while_wallhanging" )
	level.dailyChallenges[2].append( "ch_daily_headshots" )
	level.dailyChallenges[2].append( "ch_daily_pettitankillsfollowmode" )
	level.dailyChallenges[2].append( "ch_daily_kills_while_using_burncard" )
	level.dailyChallenges[2].append( "ch_daily_kill_npcs" )
	level.dailyChallenges[2].append( "ch_daily_spectre_kills" )
	level.dailyChallenges[2].append( "ch_daily_rodeo_kills" )
	level.dailyChallenges[2].append( "ch_daily_pilot_kills" )
	level.dailyChallenges[2].append( "ch_daily_cloaked_pilot_kills" )
	level.dailyChallenges[2].append( "ch_daily_ejecting_pilot_kills" )
	level.dailyChallenges[2].append( "ch_daily_kills_as_ogre" )
	level.dailyChallenges[2].append( "ch_daily_pilotkickmelee" )
	level.dailyChallenges[2].append( "ch_daily_pilotkickmeleepilot" )
	level.dailyChallenges[2].append( "ch_daily_kills_while_wallrunning" )
	level.dailyChallenges[2].append( "ch_daily_titanexocutionatlas" )
	level.dailyChallenges[2].append( "ch_daily_titanexocutionstryder" )
	level.dailyChallenges[2].append( "ch_daily_kills_while_cloaked" )
	level.dailyChallenges[2].append( "ch_daily_titanmeleepilot" )
	level.dailyChallenges[2].append( "ch_daily_first_strikes" )
	level.dailyChallenges[2].append( "ch_daily_kills_as_stryder" )
	level.dailyChallenges[2].append( "ch_daily_kills_evacuating_enemies" )
	level.dailyChallenges[2].append( "ch_daily_titanstepcrush" )
	level.dailyChallenges[2].append( "ch_daily_killing_sprees" )
	level.dailyChallenges[2].append( "ch_daily_titanfallkill" )
	level.dailyChallenges[2].append( "ch_daily_marvin_kills" )
	level.dailyChallenges[2].append( "ch_daily_kills_while_doomed" )
	level.dailyChallenges[2].append( "ch_daily_titanstepcrushpilot" )
	level.dailyChallenges[2].append( "ch_daily_titanexocutionogre" )
	level.dailyChallenges[2].append( "ch_daily_titanmelee" )
	level.dailyChallenges[2].append( "ch_daily_grunt_kills" )
	level.dailyChallenges[2].append( "ch_daily_pilotexecutepilot" )
	level.dailyChallenges[2].append( "ch_daily_pettitankillsguardmode" )
	level.dailyChallenges[2].append( "ch_daily_kills_as_atlas" )
	level.dailyChallenges[2].append( "ch_daily_kills_while_ejecting" )
	level.dailyChallenges[2].append( "ch_daily_titan_kills" )
	level.dailyChallenges[2].append( "ch_daily_kills_evac_ships" )
	level.dailyChallenges[2].append( "ch_daily_kills_flyers" )

	// Check for errors, otherwise it could be days or months before a type gets found
	for ( local groupIndex = 0 ; groupIndex < level.dailyChallenges.len() ; groupIndex++ )
	{
		for ( local refIndex = 0 ; refIndex < level.dailyChallenges[groupIndex].len() ; refIndex++ )
		{
			level.dailyChallenges[groupIndex][refIndex] = level.dailyChallenges[groupIndex][refIndex].tolower()
			local ref = level.dailyChallenges[groupIndex][refIndex]
			Assert( GetChallengeCategory( ref ) == eChallengeCategory.DAILY, "Tried adding non-daily challenge to daily groups" )
			Assert( ref in level.challengeData, "Tried adding invalid challenge to daily groups" )
		}
	}
}