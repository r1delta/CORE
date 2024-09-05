// schema implementation of /cfg/server/persistent_player_data_version_299.pdef as a squirrel table
// we are never fucking getting normal persistence across r1o and engine_ds

::pdef_version <- 299
::pdef_values <- {}
::pdef_enums <- {}
::pdef_structs <- {}
::schema <- {}


function GetPDEFSchema()
{
    schema.pdef_version <- ::pdef_version
    schema.pdef_values <- ::pdef_values
    schema.pdef_enums <- ::pdef_enums
    schema.pdef_structs <- ::pdef_structs

    return schema
}

function main()
{
	Globalize( GetPDEFSchema )

	pdef_values <- { previouslyInitialized, "bool" }
	pdef_values <- { initializedVersion, "int" }

	pdef_values <- { xp = "int" }
	pdef_values <- { previousXP = "int" }
	pdef_values <- { xp_match = "int[48]" }
	pdef_values <- { xp_match_count = "int[48]" }

	pdef_values <- { showGameSummary = "bool" }
	pdef_values <- { regenShowNew = "bool" }
	pdef_values <- { spawnAsTitan = "bool" }
	pdef_values <- { haveSeenCustomCoop = "bool" }

	pdef_values <- { isACheater = "bool" }

	//#############################
	// LISTS OF THINGS IN THE GAME
	//#############################

	//All game modes in the game, including riffs
	enum gameModes
	{
		tdm,
		cp,
		at,
		ctf,
		lts,
		wlts,
		mfd,
		mfdp,
		coop,
		ps
	}

	pdef_enums <- gameModes

	//Gamemodes we want to have loadouts associated with them.
	//Riffs will normally not have loadouts associated with them
	enum gameModesWithLoadouts
	{
		tdm,
		cp,
		at,
		ctf,
		lts,
		mfd,
		coop,
	}

	pdef_enums <- gameModesWithLoadouts

	//Gamemodes we want to have 3 stars on every map for.
	enum gameModesWithStars
	{
		tdm,
		cp,
		at,
		ctf,
		lts,
		mfd,
		coop,
	}

	pdef_enums <- gameModesWithStars

	// enum used for stats. mp_box and mp_test_engagement_range are
	// in this list so I can test stat tracking in those maps
	// add new maps to the bottom of this list...DO NOT CHANGE ORDER!!
	enum maps
	{
		mp_box,
		mp_test_engagement_range,
		mp_airbase,
		mp_angel_city,
		mp_boneyard,
		mp_colony,
		mp_corporate,
		mp_fracture,
		mp_lagoon,
		mp_nexus,
		mp_o2,
		mp_outpost_207,
		mp_overlook,
		mp_relic,
		mp_rise,
		mp_smugglers_cove,
		mp_training_ground,
		mp_runoff,				// DLC 1
		mp_swampland,			// DLC 1
		mp_wargames,			// DLC 1
		mp_harmony_mines,		// DLC 2
		mp_switchback,			// DLC 2
		mp_haven,				// DLC 2
		mp_zone_18,				// DLC 3
		mp_backwater,			// DLC 3
		mp_sandtrap				// DLC 3
	}

	pdef_enums <- maps

	enum loadoutItems
	{
		NULL,
		mp_weapon_rspn101,
		mp_weapon_smart_pistol,
		mp_weapon_shotgun,
		mp_weapon_hemlok,
		mp_weapon_r97,
		mp_weapon_sniper,
		mp_weapon_g2,
		mp_weapon_car,
		mp_weapon_dmr,
		mp_weapon_smr,
		mp_weapon_defender,
		mp_weapon_lmg,
		mp_weapon_mgl,
		mp_weapon_rocket_launcher,
		mp_weapon_wingman,
		mp_weapon_semipistol,
		mp_weapon_autopistol,
		mp_weapon_frag_grenade,
		mp_weapon_grenade_emp,
		mp_weapon_satchel,
		mp_weapon_proximity_mine,
		mp_titanweapon_xo16,
		mp_titanweapon_40mm,
		mp_titanweapon_rocket_launcher,
		mp_titanweapon_arc_cannon,
		mp_titanweapon_triple_threat,
		mp_titanweapon_vortex_shield,
		mp_titanweapon_dumbfire_rockets,
		mp_titanweapon_shoulder_rockets,
		mp_titanweapon_homing_rockets,
		mp_titanweapon_salvo_rockets,
		mp_titanweapon_sniper,
		mp_titanability_smoke,
		mp_titanability_fusion_core,
		mp_titanability_bubble_shield,
		mp_ability_cloak,
		mp_ability_heal,
		mp_ability_sonar
	}

	pdef_enums <- loadoutItems

	enum pilotMod
	{
		NULL,
		aog,
		automatic_fire,
		burn_mod_autopistol,
		burn_mod_car,
		burn_mod_defender,
		burn_mod_dmr,
		burn_mod_emp_grenade,
		burn_mod_frag_grenade,
		burn_mod_g2,
		burn_mod_hemlok,
		burn_mod_lmg,
		burn_mod_mgl,
		burn_mod_proximity_mine,
		burn_mod_r97,
		burn_mod_rspn101,
		burn_mod_satchel,
		burn_mod_semipistol,
		burn_mod_smart_pistol,
		burn_mod_smr,
		burn_mod_sniper,
		burn_mod_rocket_launcher,
		burst,
		enhanced_targeting,
		extended_ammo,
		fast_lock,
		fast_reload,
		guided_missile,
		hcog,
		high_density,
		holosight,
		integrated_gyro,
		iron_sights,
		long_fuse,
		match_trigger,
		powered_magnets,
		recoil_compensator,
		scatterfire,
		scope_4x,
		scope_6x,
		scope_8x,
		scope_10x,
		scope_12x,
		burn_mod_shotgun,
		silencer,
		sniper_assist,
		stabilizer,
		starburst,
		single_shot,
		slammer,
		spread_increase_sg,
		stabilized_warhead,
		tank_buster,
		burn_mod_wingman
	}

	pdef_enums <- pilotMod

	enum titanSetFile
	{
		NULL,
		titan_atlas,
		titan_ogre,
		titan_stryder,
	}

	pdef_enums <- titanSetFile

	enum titanMod
	{
		NULL,
		accelerator,
		afterburners,
		arc_triple_threat,
		burn_mod_titan_40mm,
		burn_mod_titan_arc_cannon,
		burn_mod_titan_rocket_launcher,
		burn_mod_titan_sniper,
		burn_mod_titan_triple_threat,
		burn_mod_titan_xo16,
		burn_mod_titan_dumbfire_rockets,
		burn_mod_titan_homing_rockets,
		burn_mod_titan_salvo_rockets,
		burn_mod_titan_shoulder_rockets,
		burn_mod_titan_vortex_shield,
		burn_mod_titan_smoke,
		burn_mod_titan_bubble_shield,
		burst,
		capacitor,
		extended_ammo,
		fast_lock,
		fast_reload,
		instant_shot,
		mine_field,
		overcharge,
		quick_shot,
		rapid_fire_missiles
	}

	pdef_enums <- titanMod

	enum pilotPassive
	{
		NULL,
		pas_stealth_movement,
		pas_ordnance_pack,
		pas_power_cell,
		pas_minimap_ai,
		pas_longer_bubble,
		pas_run_and_gun,
		pas_dead_mans_trigger,
		pas_wall_runner,
		pas_turbo_drop,
		pas_enhanced_titan_ai,
		pas_fast_reload,
		pas_fast_hack
	}

	pdef_enums <- pilotPassive

	enum pilotRace
	{
		race_human_male,
		race_human_female
	}

	pdef_enums <- pilotRace

	enum titanPassive
	{
		NULL,
		pas_auto_eject,
		pas_doomed_time,
		pas_dash_recharge,
		pas_defensive_core,
		pas_titan_punch,
		pas_shield_regen,
		pas_assault_reactor,
		pas_hyper_core,
		pas_marathon_core,
		pas_build_up_nuclear_core
	}

	enum titanDecals
	{
		NULL,
		titan_decal_a_base_imc,
		titan_decal_b_base_mcor,
		5kw_custom_decal,
		30_titan_decal,
		ace_custom_decal,
		bomb_lit_custom_decal,
		bombs_custom_decal,
		bullet_hash_custom_decal,
		eye_custom_decal,
		hand_custom_decal,
		pitchfork_custom_decal,
		red_chevron_custom_decal,
		titan_decal_4,
		titan_decal_13,
		titan_decal_19,
		titan_decal_27,
		titan_decal_ace,
		titan_decal_animalskull,
		titan_decal_bluestar,
		titan_decal_brokenstar,
		titan_decal_conejo,
		titan_decal_crazybomb,
		titan_decal_defiant,
		titan_decal_dice,
		titan_decal_dino,
		titan_decal_eagle,
		titan_decal_eagleShield,
		titan_decal_fa95,
		titan_decal_flameskull,
		titan_decal_gen2,
		titan_decal_gen3,
		titan_decal_gen4,
		titan_decal_gen5,
		titan_decal_gen6,
		titan_decal_gen7,
		titan_decal_gen8,
		titan_decal_gen9,
		titan_decal_gen10,
		titan_decal_girly,
		titan_decal_gremlin,
		titan_decal_hammond,
		titan_decal_imc_gear,
		titan_decal_imc_old,
		titan_decal_IMC01,
		titan_decal_IMC02,
		titan_decal_IMC03,
		titan_decal_imctri,
		titan_decal_killmarks,
		titan_decal_ksa,
		titan_decal_letter01_opa,
		titan_decal_mcor,
		titan_decal_militia,
		titan_decal_oldMcor,
		titan_decal_redstarv,
		titan_decal_shield,
		titan_decal_skullwings,
		titan_decal_skullwingsBLK,
		titan_decal_st,
		titan_decal_ste,
		titan_decals_stinger,
		wings_custom_decal,
		titan_decal_flagrunner,
		titan_decal_twofer,
		titan_decal_100guns,
		titan_decal_crest,
		titan_decal_titankills,
		titan_decal_eagleside,
		titan_decal_chevrons,
		titan_decal_glyph,
		titan_decal_triangle,
		titan_decal_kodai,
		titan_decal_nuke,
		titan_decal_fallingbomb,
		titan_decal_grenade,
		titan_decal_firsttofall,
		titan_decal_pennyarcade,
		titan_decal_dragon,
		titan_decal_respawnbird,
		titan_decal_wonjae,
		titan_decal_lastimosa,
		titan_decal_austin,
		titan_decal_cobra,
		titan_decal_gunwing,
		titan_decal_hashtag,
		titan_decal_nomercy,
		titan_decal_pegasus,
		titan_decal_sword,
		titan_decal_gooser,
		titan_decal_padoublethreat,
		titan_decals_blackmarket01,
		titan_decals_blackmarket02,
		titan_decals_blackmarket03,
		titan_decals_blackmarket04,
		titan_decals_blackmarket05,
		titan_decals_blackmarket06,
		titan_decals_blackmarket07,
		titan_decals_blackmarket08,
		titan_decal_export,
		titan_decal_harmony,
		titan_decal_haven,
		titan_decal_ichicat,
		titan_decal_pf,
		titan_decal_coop_1,
		titan_decal_coop_2,
		titan_decals_3s_attrition,
		titan_decals_3s_ctf,
		titan_decals_3s_frontierdef,
		titan_decals_3s_hardpoint,
		titan_decals_3s_lts,
		titan_decals_3s_marked4death,
		titan_decals_3s_pilothunter,
	}

	pdef_enums <- titanDecals

	// This is needed so we know what decals were earned in the last match. We can't track it like we do unlocks from leveling or challenges where we know pre-game status
	pdef_values <- { decalsUnlocked = "bool[titanDecals]" }

	enum titanOS
	{
		titanos_betty,
		titanos_malebutler,
		titanos_femaleaudinav,
		titanos_femaleassistant,
		titanos_maleintimidator,
		titanos_bettyde,
		titanos_bettyen,
		titanos_bettyes,
		titanos_bettyfr,
		titanos_bettyit,
		titanos_bettyjp,
		titanos_bettyru
	}

	pdef_enums <- titanOS

	//######################
	//		LOADOUTS
	//######################

	pdef_structs <- {
	    spawnLoadout = {
	        isCustom = "bool",
	        index = "int"
	    },

	    spawnLoadout = {
	        isCustom = "bool",
	        index = "int"
	    },

	    pilotLoadout = {
	        name = "string{48}",
	        primary = "loadoutItems",
	        secondary = "loadoutItems",
	        sidearm = "loadoutItems",
	        special = "loadoutItems",
	        ordnance = "loadoutItems",
	        primaryAttachment = "pilotMod",
	        primaryMod = "pilotMod",
	        passive1 = "pilotPassive",
	        passive2 = "pilotPassive",
	        race = "pilotRace"
	    }, 

	    titanLoadout = {
	        name = "string{48}",
	        setFile = "titanSetFile",
	        primary = "loadoutItems",
	        special = "loadoutItems",
	        ordnance = "loadoutItems",
	        primaryMod = "titanMod",
	        passive1 = "titanPassive",
	        passive2 = "titanPassive",
	        decal = "titanDecals",
	        voiceChoice = "titanOS"
	    }
	}

	pdef_values <- { pilotSpawnLoadout = "spawnLoadout" }
	pdef_values <- { titanSpawnLoadout = "spawnLoadout" }

	pdef_values <- { pilotLoadouts = "pilotLoadout[19]" }
	pdef_values <- { titanLoadouts = "titanLoadout[19]" }

	enum modsCombined
	{
		mp_weapon_car_iron_sights,
		mp_weapon_car_hcog,
		mp_weapon_dmr_aog,
		mp_weapon_dmr_scope_4x,
		mp_weapon_dmr_scope_6x,
		mp_weapon_g2_iron_sights,
		mp_weapon_g2_hcog,
		mp_weapon_g2_holosight,
		mp_weapon_g2_aog,
		mp_weapon_hemlok_iron_sights,
		mp_weapon_hemlok_hcog,
		mp_weapon_hemlok_holosight,
		mp_weapon_hemlok_aog,
		mp_weapon_lmg_iron_sights,
		mp_weapon_lmg_hcog,
		mp_weapon_lmg_holosight,
		mp_weapon_lmg_aog,
		mp_weapon_rspn101_iron_sights,
		mp_weapon_rspn101_hcog,
		mp_weapon_rspn101_holosight,
		mp_weapon_rspn101_aog,
		mp_weapon_r97_iron_sights,
		mp_weapon_r97_hcog,
		mp_weapon_sniper_aog,
		mp_weapon_sniper_scope_4x,
		mp_weapon_sniper_scope_6x,
		mp_weapon_car_integrated_gyro,
		mp_weapon_car_extended_ammo,
		mp_weapon_car_silencer,
		mp_weapon_dmr_extended_ammo,
		mp_weapon_dmr_silencer,
		mp_weapon_dmr_stabilizer,
		mp_weapon_g2_extended_ammo,
		mp_weapon_g2_match_trigger,
		mp_weapon_g2_silencer,
		mp_weapon_hemlok_extended_ammo,
		mp_weapon_hemlok_silencer,
		mp_weapon_hemlok_starburst,
		mp_weapon_lmg_extended_ammo,
		mp_weapon_lmg_slammer,
		mp_weapon_r97_extended_ammo,
		mp_weapon_r97_scatterfire,
		mp_weapon_r97_silencer,
		mp_weapon_rspn101_extended_ammo,
		mp_weapon_rspn101_recoil_compensator,
		mp_weapon_rspn101_silencer,
		mp_weapon_shotgun_extended_ammo,
		mp_weapon_shotgun_spread_increase_sg,
		mp_weapon_shotgun_silencer,
		mp_weapon_smart_pistol_enhanced_targeting,
		mp_weapon_smart_pistol_extended_ammo,
		mp_weapon_smart_pistol_silencer,
		mp_weapon_sniper_extended_ammo,
		mp_weapon_sniper_silencer,
		mp_weapon_sniper_stabilizer,
		mp_weapon_car_burn_mod_car,
		mp_weapon_dmr_burn_mod_dmr,
		mp_weapon_g2_burn_mod_g2,
		mp_weapon_hemlok_burn_mod_hemlok,
		mp_weapon_lmg_burn_mod_lmg,
		mp_weapon_r97_burn_mod_r97,
		mp_weapon_rspn101_burn_mod_rspn101,
		mp_weapon_shotgun_burn_mod_shotgun,
		mp_weapon_smart_pistol_burn_mod_smart_pistol,
		mp_weapon_sniper_burn_mod_sniper,
		mp_weapon_wingman_burn_mod_wingman,
		mp_weapon_mgl_burn_mod_mgl,
		mp_weapon_rocket_launcher_burn_mod_rocket_launcher,
		mp_weapon_smr_burn_mod_smr,
		mp_weapon_defender_burn_mod_defender,
		mp_weapon_autopistol_burn_mod_autopistol,
		mp_weapon_semipistol_burn_mod_semipistol,
		mp_weapon_satchel_burn_mod_satchel,
		mp_weapon_frag_grenade_burn_mod_frag_grenade,
		mp_weapon_grenade_emp_burn_mod_grenade_emp,
		mp_weapon_proximity_mine_burn_mod_proximity_mine,
		mp_titanweapon_40mm_burst,
		mp_titanweapon_40mm_extended_ammo,
		mp_titanweapon_40mm_fast_reload,
		mp_titanweapon_arc_cannon_capacitor,
		mp_titanweapon_rocket_launcher_afterburners,
		mp_titanweapon_rocket_launcher_extended_ammo,
		mp_titanweapon_rocket_launcher_rapid_fire_missiles,
		mp_titanweapon_sniper_extended_ammo,
		mp_titanweapon_sniper_fast_reload,
		mp_titanweapon_sniper_instant_shot,
		mp_titanweapon_sniper_quick_shot,
		mp_titanweapon_triple_threat_extended_ammo,
		mp_titanweapon_triple_threat_mine_field,
		mp_titanweapon_xo16_accelerator,
		mp_titanweapon_xo16_burst,
		mp_titanweapon_xo16_extended_ammo,
		mp_titanweapon_xo16_fast_reload
	}

	pdef_enums <- modsCombined

	enum unlockRefs
	{
		edit_pilots, // these two must come first
		edit_titans,

		pilot_preset_loadout_1,
		pilot_preset_loadout_2,
		pilot_preset_loadout_3,

		titan_preset_loadout_1,
		titan_preset_loadout_2,
		titan_preset_loadout_3,

		pilot_custom_loadout_1,
		pilot_custom_loadout_2,
		pilot_custom_loadout_3,
		pilot_custom_loadout_4,
		pilot_custom_loadout_5,
		pilot_custom_loadout_6,
		pilot_custom_loadout_7,
		pilot_custom_loadout_8,
		pilot_custom_loadout_9,
		pilot_custom_loadout_10,
		pilot_custom_loadout_11,
		pilot_custom_loadout_12,
		pilot_custom_loadout_13,
		pilot_custom_loadout_14,
		pilot_custom_loadout_15,
		pilot_custom_loadout_16,
		pilot_custom_loadout_17,
		pilot_custom_loadout_18,
		pilot_custom_loadout_19,

		titan_custom_loadout_1,
		titan_custom_loadout_2,
		titan_custom_loadout_3,
		titan_custom_loadout_4,
		titan_custom_loadout_5,
		titan_custom_loadout_6,
		titan_custom_loadout_7,
		titan_custom_loadout_8,
		titan_custom_loadout_9,
		titan_custom_loadout_10,
		titan_custom_loadout_11,
		titan_custom_loadout_12,
		titan_custom_loadout_13,
		titan_custom_loadout_14,
		titan_custom_loadout_15,
		titan_custom_loadout_16,
		titan_custom_loadout_17,
		titan_custom_loadout_18,
		titan_custom_loadout_19,

		burn_card_slot_1,
		burn_card_slot_2,
		burn_card_slot_3,

		burn_card_pack_1,
		burn_card_pack_2,
		burn_card_pack_3,
		burn_card_pack_4,
		burn_card_pack_5,

		challenges
	}

	pdef_enums <- unlockRefs

	pdef_values <- { newLoadoutItems = "bool[loadoutItems]" }
	pdef_values <- { newMods = "bool[modsCombined]" }
	pdef_values <- { newChassis = "bool[titanSetFile]" }
	pdef_values <- { rewardChassis = "bool[titanSetFile]" }
	pdef_values <- { newPilotPassives = "bool[pilotPassive]" }
	pdef_values <- { newTitanPassives = "bool[titanPassive]" }
	pdef_values <- { newTitanOS = "bool[titanOS]" }
	pdef_values <- { newUnlocks = "bool[unlockRefs]" }
	pdef_values <- { newTitanDecals = "bool[titanDecals]" }

	//######################
	//		BURN CARDS
	//######################

	enum burnCard
	{
		NULL,
		bc_conscription,
		bc_double_xp,
		bc_free_xp,
		bc_fast_cooldown1,
		bc_fast_cooldown2,
		bc_super_stim,
		bc_super_cloak,
		bc_super_sonar,
		bc_summon_ogre,
		bc_cloak_forever,
		bc_stim_forever,
		bc_sonar_forever,
		bc_summon_stryder,
		bc_spectre_virus,
		bc_play_spectre,
		bc_double_agent,
		bc_minimap,
		bc_summon_atlas,
		bc_megaturrets,
		bc_summon_dogfighter,
		bc_wifi_spectre_hack,
		bc_nuclear_core,
		bc_core_charged,
		bc_smart_pistol_m2,
		bc_r97_m2,
		bc_rspn101_m2,
		bc_dmr_m2,
		bc_shotgun_m2,
		bc_lmg_m2,
		bc_g2_m2,
		bc_car_m2,
		bc_hemlok_m2,
		bc_sniper_m2,
		bc_smr_m2,
		bc_mgl_m2,
		bc_defender_m2,
		bc_rocket_launcher_m2,
		bc_semipistol_m2,
		bc_autopistol_m2,
		bc_wingman_m2,
		bc_satchel_m2,
		bc_frag_m2,
		bc_arc_m2,
		bc_prox_m2,
		bc_pilot_warning,
		bc_rematch,
		bc_minimap_scan,
		bc_free_build_time_1,
		bc_free_build_time_2,
		bc_fast_build_1,
		bc_fast_build_2,
		bc_hunt_soldier,
		bc_hunt_spectre,
		bc_hunt_titan,
		bc_hunt_pilot,
		bc_auto_sonar,
		bc_fast_movespeed,
		bc_auto_refill,
		bc_dice_ondeath,
		bc_titan_40mm_m2,
		bc_titan_arc_cannon_m2,
		bc_titan_rocket_launcher_m2,
		bc_titan_sniper_m2,
		bc_titan_triple_threat_m2,
		bc_titan_xo16_m2,
		bc_titan_dumbfire_missile_m2,
		bc_titan_homing_rockets_m2,
		bc_titan_salvo_rockets_m2,
		bc_titan_shoulder_rockets_m2,
		bc_titan_vortex_shield_m2,
		bc_titan_electric_smoke_m2,
		bc_titan_shield_wall_m2,
		bc_titan_melee_m2,
		bc_extra_dash
	}

	pdef_enums <- burnCard

	pdef_structs <- {
	    struct_activeBurnCardData = {
	        burnCard = "burnCard",
	        lastCardRef = "burnCard",
	        clearOnStart = "bool"
	    },

	    struct_historyBurnCardData = {
	        collected = "int",
	        spent = "int"
	    },

	    struct_blackMarketBurnCardUpgrades = {
	        burnCard = "burnCard"
	    },

	}

	pdef_values <- { persData_historyBurnCards = "struct_historyBurnCardData[burnCard]" }

	pdef_values <- { onDeckBurnCardIndex = "int" }
	pdef_values <- { activeBCID = "int" }

	pdef_values <- { persData_activeBurnCards = "struct_activeBurnCardData[3]" }
	pdef_values <- { persData_pm_activeBurnCards = "struct_activeBurnCardData[3]" }

	pdef_values <- { persData_unopenedBurnCards = "burnCard[25]" }

	pdef_values <- { burnCardStoryProgress = "int" }

	pdef_values <- { currentBurnCardPile = "int" }
	pdef_values <- { currentBurnCardOffset = "int[3]" }

	pdef_values <- { burnCardDeck = "burnCard[100]" }
	pdef_values <- { pm_burnCardDeck = "burnCard[100]" }

	pdef_structs <- {
	    struct_burnCardPlayerData = {
	        blackMarketTimeUntilBurnCardUpgradeReset = "int",
	        stashedCardRef = "burnCard[3]",
	        stashedCardTime = "int[3]",
	        burnCardIsNew = "bool[100]",
	        blackMarkedBurnCardUpgrades = "struct_blackMarketBurnCardUpgrades[3]",
	        burnCardUpgraded = "bool[burnCard]",
	        devReset = "int",
	        uiActiveBurnCardIndex = "int",
	        autofill = "bool"
	    }
	}

	pdef_values <- { bc = "struct_burnCardPlayerData" }
	pdef_values <- { pm_bc = "struct_burnCardPlayerData" }

	pdef_values <- { currentPack = "int" }
	pdef_values <- { currentPackIndex = "int" }

	pdef_values <- { nextBurnCard = "int[3]" }

	pdef_values <- { gen = "int" }


	//################################################
	// CHAD'S STAT TRACKING STUFF - DON'T MESS WIT IT
	//################################################


	pdef_structs <- {
	    sMapStats = {
	        gamesJoined = "int[gameModes]",
	        gamesCompleted = "int[gameModes]",
	        gamesWon = "int[gameModes]",
	        gamesLost = "int[gameModes]",
	        topPlayerOnTeam = "int[gameModes]",
	        top3OnTeam = "int[gameModes]",
	        hoursPlayed = "float[gameModes]",
	        timesScored100AttritionPoints_byMap = "int"
	    }
	} 

	pdef_structs <- {
	    sGameStats = {
	        modesPlayed = "int[gameModes]",
	        previousModesPlayed = "int[gameModes]",
	        modesWon = "int[gameModes]",
	        mvp_total = "int",
	        gamesCompletedTotal = "int",
	        gamesCompletetdTotaCampaign = "int",
	        gamesWonAsIMC = "int",
	        gamesWonAsMilitia = "int",
	        gamesCompletedAsIMC = "int",
	        gamesCompletedAsMilitia = "int",
	        pvpKills = "int[gameModes]",
	        timesKillDeathRatio2to1 = "int[gameModes]",
	        timesKillDeathRatio2to1_pvp = "int[gameModes]",
	        timesScored100AttritionPoints_total = "int",
	        mode_played_at = "int",
	        mode_played_ctf = "int",
	        mode_played_lts = "int",
	        mode_played_cp = "int",
	        mode_played_tdm = "int",
	        mode_played_wlts = "int",
	        mode_played_mfd = "int",
	        mode_played_coop = "int",
	        mode_won_at = "int",
	        mode_won_ctf = "int",
	        mode_won_lts = "int",
	        mode_won_cp = "int",
	        mode_won_tdm = "int",
	        mode_won_wlts = "int",
	        mode_won_mfd = "int",
	        mode_won_coop = "int",
	        coop_perfect_waves = "int"      
	    },

	    sHoursPlayed = {
	        total = "float",
	        asTitan = "float[titanSetFile]",
	        asPilot = "float",
	        asTitanTotal = "float",
	        dead = "float",
	        wallhanging = "float",
	        wallrunning = "float",
	        inAir = "float"
	    },

	    sMilesTraveled = {
	        total = "float",
	        asTitan = "float[titanSetFile]",
	        asPilot = "float",
	        asTitanTotal = "float",
	        wallrunning = "float",
	        inAir = "float",
	        ziplining = "float",
	        onFriendlyTitan = "float",
	        onEnemyTitan = "float"
	    },

	    sWeaponStats = {
	        hoursUsed = "float",
	        hoursEquipped = "float",
	        shotsFired = "int",
	        shotsHit = "int",
	        headshots = "int",
	        critHits = "int"
	    },

	    sWeaponKillStats = {
	        total = "int",
	        pilots = "int",
	        ejecting_pilots = "int",
	        spectres = "int",
	        marvins = "int",
	        grunts = "int",
	        titansTotal = "int",
	        titans = "int[titanSetFile]",
	        npcTitans = "int[titanSetFile]"
	    },

	    sKillStats = {
	        total = "int",
	        totalWhileUsingBurnCard = "int",
	        totalWhileTitanBCActive = "int",
	        totalPVP = "int",
	        pilots = "int",
	        spectres = "int",
	        marvins = "int",
	        grunts = "int",
	        totalTitans = "int",
	        totalTitansWhileDoomed = "int",
	        totalPilots = "int",
	        totalNPC = "int",
	        asPilot = "int",
	        asTitan = "int[titanSetFile]",
	        firstStrikes = "int",
	        ejectingPilots = "int",
	        whileEjecting = "int",
	        cloakedPilots = "int",
	        whileCloaked = "int",
	        wallrunningPilots = "int",
	        whileWallrunning = "int",
	        wallhangingPilots = "int",
	        whileWallhanging = "int",
	        pilotExecution = "int",
	        pilotExecutePilot = "int",
	        pilotKickMelee = "int",
	        pilotKickMeleePilot = "int",
	        titanMelee = "int",
	        titanMeleePilot = "int",
	        titanStepCrush = "int",
	        titanStepCrushPilot = "int",
	        titanExocutionStryder = "int",
	        titanExocutionAtlas = "int",
	        titanExocutionOgre = "int",
	        titanFallKill = "int",
	        petTitanKillsFollowMode = "int",
	        petTitanKillsGuardMode = "int",
	        rodeo_total = "int",
	        rodeo_stryder = "int",
	        rodeo_atlas = "int",
	        rodeo_ogre = "int",
	        pilot_headshots_total = "int",
	        evacShips = "int",
	        flyers = "int",
	        nuclearCore = "int",
	        evacuatingEnemies = "int",
	        exportTrapKills = "int",
	        coopChallenge_NukeTitan_Kills = "int",
	        coopChallenge_MortarTitan_Kills = "int",
	        coopChallenge_EmpTitan_Kills = "int",
	        coopChallenge_BubbleShieldGrunt_Kills = "int",
	        coopChallenge_CloakDrone_Kills = "int",
	        coopChallenge_Dropship_Kills = "int",
	        coopChallenge_SuicideSpectre_Kills = "int",
	        coopChallenge_Turret_Kills = "int",
	        coopChallenge_Sniper_Kills = "int",
	        ampedVortexKills = "int",
	        meleeWhileCloaked = "int",
	        pilotKillsWhileUsingActiveRadarPulse = "int",
	        titanKillsAsPilot = "int",
	        pilotKillsWhileStimActive = "int",
	        pilotKillsAsTitan = "int"
	    },

	    sDeathStats = {
	        total = "int",
	        totalPVP = "int",
	        asPilot = "int",
	        asTitan = "int[titanSetFile]",
	        byPilots = "int",
	        bySpectres = "int",
	        byGrunts = "int",
	        byTitans = "int[titanSetFile]",
	        byNPCTitans = "int[titanSetFile]",
	        suicides = "int",
	        whileEjecting = "int"
	    },

	    sMiscStats = {
	        titanFalls = "int",
	        titanFallsFirst = "int",
	        titanEmbarks = "int",
	        rodeos = "int",
	        rodeosFromEject = "int",
	        timesEjected = "int",
	        timesEjectedNuclear = "int",
	        burnCardsEarned = "int",
	        burnCardsSpent = "int",
	        spectreLeeches = "int",
	        spectreLeechesByMap = "int[maps]",
	        evacsAttempted = "int",
	        evacsSurvived = "int",
	        flagsCaptured = "int",
	        flagsReturned = "int",
	        arcCannonMultiKills = "int",
	        gruntsConscripted = "int",
	        hardpointsCaptured = "int",
	        challengeTiersCompleted = "int",
	        challengesCompleted = "int",
	        dailyChallengesCompleted = "int",
	        timesLastTitanRemaining = "int",
	        killingSprees = "int",
	        coopChallengesCompleted = "int",
	        forgedCertificationsUsed = "int",
	        regenForgedCertificationsUsed = "int"

	    }
	}

	pdef_values <- { campaignTeam, "int" }
	pdef_values <- { campaignStarted, "bool" }
	pdef_values <- { campaignLevelsFinishedIMC, "int" }
	pdef_values <- { campaignLevelsFinishedMCOR, "int" }
	pdef_values <- { campaignFinishedIMCjustNow, "int" }
	pdef_values <- { campaignFinishedMCORjustNow, "int" }
	pdef_values <- { campaignMapFinishedIMC, "bool[9]" }
	pdef_values <- { campaignMapFinishedMCOR, "bool[9]" }
	pdef_values <- { campaignMapWonIMC, "bool[9]" }
	pdef_values <- { campaignMapWonMCOR, "bool[9]" }
	pdef_values <- { desiredCampaignMapIndex, "int[2]" }

	pdef_values <- { gameStats = "sGameStats" }
	pdef_values <- { mapStats = "sMapStats[maps]" }
	pdef_values <- { timeStats = "sHoursPlayed" }
	pdef_values <- { distanceStats = "sMilesTraveled" }
	pdef_values <- { weaponStats = "sWeaponStats[loadoutItems]" }
	pdef_values <- { weaponKillStats = "sWeaponKillStats[loadoutItems]" }
	pdef_values <- { killStats = "sKillStats" }
	pdef_values <- { deathStats = "sDeathStats" }
	pdef_values <- { miscStats = "sMiscStats" }

	pdef_values <- { kdratio_lifetime = "float" }
	pdef_values <- { kdratio_lifetime_pvp = "float" }
	pdef_values <- { kdratio_match = "float[10]" }
	pdef_values <- { kdratiopvp_match = "float[10]" }

	pdef_values <- { winStreak = "int" }
	pdef_values <- { highestWinStreakEver = "int" }
	pdef_values <- { winStreakIsDraws = "bool" }
	pdef_values <- { winLossHistory = "int[10]" }
	pdef_values <- { winLossHistorySize = "int" }

	pdef_values <- { mostProjectilesCollectedInVortex = "int" }
	pdef_values <- { blackMarketItemsBought = "int" }

	pdef_values <- { respawnKillInfected = "bool" }

	enum eGemState
	{
	    gem_undefeated,
	    gem_damaged,
	    gem_captured,
	    gem_lost
	}

	pdef_enums <- eGemState

	pdef_structs <- {
	    struct_gem = {
	        gemScore = "float",
	        gemState = "eGemState"
	    },

	    struct_season = {
	        season = "int",
	        seasonStartTime = "int",
	        seasonEndTime = "int",
	        rank = "int",
	        gamesPlayed = "int",
	        bestRating = "float",
	        bestRank = "int",
	        rankGraph = "int[28]"
	    }
	}

	enum eMatchValid
	{
	    true,
	    low_player_count,
	    low_time_played,
	    quit_early
	}

	pdef_enums <- eMatchValid

	pdef_structs <- {
	    struct_ranked = {
	        gems = "struct_gem[135]",
	        previousGemCount = "int",
	        previousGems = "struct_gem[6]",

	        currentRank = "int",

	        isPlayingRanked = "bool",

	        sponsorHash = "int[15]",
	        sponsorName = "string{32}[15]",

	        historyHash = "int[120]",
	        historyWon = "bool[120]",
	        recordedSkill = "float",
	        matchValid = "eMatchValid",

	        contributionPoints = "int[8]",

	        lastSponsorshipDate = "int",
	        sponsorshipsRemaining = "int",
	        mySponsorXuid = "string{22}",
	        mySponsorName = "string{32}",

	        viewedRankedPlayIntro = "bool",
	        joinedRankedPlay = "bool",

	        debugMM = "bool",

	        nextGemDecayTime = "int",
	        nextInviteTime = "int",

	        currentSeason = "struct_season",
	        seasonHistory = "struct_season[24]",
	        showSeasonEndDialog = "bool"
	    }
	}

	pdef_values <- { ranked = "struct_ranked" }

	//#########################
	// 		CHALLENGES
	//#########################


	enum challenge
	{
		NULL,
		// General

		ch_games_played,
		ch_games_won,
		ch_games_mvp,
		ch_titan_falls,
		ch_rodeos,
		ch_times_ejected,
		ch_spectres_leeched,

		// Time

		ch_hours_played,
		ch_hours_played_pilot,
		ch_hours_played_titan,
		ch_hours_wallhang,

		// Distance

		ch_dist_total,
		ch_dist_pilot,
		ch_dist_titan,
		ch_dist_wallrun,
		ch_dist_inair,
		ch_dist_zipline,
		ch_dist_on_friendly_titan,
		ch_dist_on_enemy_titan,

		// Kills

		ch_grunt_kills,
		ch_spectre_kills,
		ch_marvin_kills,
		ch_first_strikes,
		ch_ejecting_pilot_kills,
		ch_kills_while_ejecting,
		ch_cloaked_pilot_kills,
		ch_kills_while_cloaked,
		ch_wallrunning_pilot_kills,
		ch_wallhanging_pilot_kills,
		ch_kills_while_wallrunning,
		ch_kills_while_wallhanging,
		ch_pilotExecutePilot,
		ch_pilotKickMelee,
		ch_pilotKickMeleePilot,
		ch_titanMelee,
		ch_titanMeleePilot,
		ch_titanStepCrush,
		ch_titanStepCrushPilot,
		ch_titanExocutionStryder,
		ch_titanExocutionAtlas,
		ch_titanExocutionOgre,
		ch_titanFallKill,
		ch_petTitanKillsFollowMode,
		ch_petTitanKillsGuardMode,
		ch_rodeo_kills,

		// Titan Primary

		ch_40mm_kills,
		ch_40mm_pilot_kills,
		ch_40mm_titan_kills,
		ch_40mm_spectre_kills,
		ch_40mm_grunt_kills,
		ch_40mm_hours_used,
		ch_40mm_crits,

		ch_xo16_kills,
		ch_xo16_pilot_kills,
		ch_xo16_titan_kills,
		ch_xo16_spectre_kills,
		ch_xo16_grunt_kills,
		ch_xo16_hours_used,
		ch_xo16_headshots,
		ch_xo16_crits,

		ch_titan_sniper_kills,
		ch_titan_sniper_pilot_kills,
		ch_titan_sniper_titan_kills,
		ch_titan_sniper_spectre_kills,
		ch_titan_sniper_grunt_kills,
		ch_titan_sniper_hours_used,
		ch_titan_sniper_crits,

		ch_arc_cannon_kills,
		ch_arc_cannon_pilot_kills,
		ch_arc_cannon_titan_kills,
		ch_arc_cannon_spectre_kills,
		ch_arc_cannon_grunt_kills,
		ch_arc_cannon_hours_used,

		ch_rocket_launcher_kills,
		ch_rocket_launcher_pilot_kills,
		ch_rocket_launcher_titan_kills,
		ch_rocket_launcher_spectre_kills,
		ch_rocket_launcher_grunt_kills,
		ch_rocket_launcher_hours_used,

		ch_triple_threat_kills,
		ch_triple_threat_pilot_kills,
		ch_triple_threat_titan_kills,
		ch_triple_threat_spectre_kills,
		ch_triple_threat_grunt_kills,
		ch_triple_threat_hours_used,

		// Titan Ordnance

		ch_salvo_rockets_kills,
		ch_salvo_rockets_pilot_kills,
		ch_salvo_rockets_titan_kills,
		ch_salvo_rockets_spectre_kills,
		ch_salvo_rockets_grunt_kills,
		ch_salvo_rockets_hours_used,

		ch_homing_rockets_titan_kills,
		ch_homing_rockets_hours_used,

		ch_dumbfire_rockets_kills,
		ch_dumbfire_rockets_pilot_kills,
		ch_dumbfire_rockets_titan_kills,
		ch_dumbfire_rockets_spectre_kills,
		ch_dumbfire_rockets_grunt_kills,
		ch_dumbfire_rockets_hours_used,

		ch_shoulder_rockets_titan_kills,
		ch_shoulder_rockets_hours_used,

		// Pilot Primary

		ch_smart_pistol_kills,
		ch_smart_pistol_pilot_kills,
		ch_smart_pistol_spectre_kills,
		ch_smart_pistol_grunt_kills,
		ch_smart_pistol_hours_used,

		ch_shotgun_kills,
		ch_shotgun_pilot_kills,
		ch_shotgun_spectre_kills,
		ch_shotgun_grunt_kills,
		ch_shotgun_hours_used,

		ch_r97_kills,
		ch_r97_pilot_kills,
		ch_r97_spectre_kills,
		ch_r97_grunt_kills,
		ch_r97_hours_used,
		ch_r97_headshots,

		ch_car_kills,
		ch_car_pilot_kills,
		ch_car_spectre_kills,
		ch_car_grunt_kills,
		ch_car_hours_used,
		ch_car_headshots,

		ch_lmg_kills,
		ch_lmg_pilot_kills,
		ch_lmg_spectre_kills,
		ch_lmg_grunt_kills,
		ch_lmg_hours_used,
		ch_lmg_headshots,

		ch_rspn101_kills,
		ch_rspn101_pilot_kills,
		ch_rspn101_spectre_kills,
		ch_rspn101_grunt_kills,
		ch_rspn101_hours_used,
		ch_rspn101_headshots,

		ch_hemlok_kills,
		ch_hemlok_pilot_kills,
		ch_hemlok_spectre_kills,
		ch_hemlok_grunt_kills,
		ch_hemlok_hours_used,
		ch_hemlok_headshots,

		ch_g2_kills,
		ch_g2_pilot_kills,
		ch_g2_spectre_kills,
		ch_g2_grunt_kills,
		ch_g2_hours_used,
		ch_g2_headshots,

		ch_dmr_kills,
		ch_dmr_pilot_kills,
		ch_dmr_spectre_kills,
		ch_dmr_grunt_kills,
		ch_dmr_hours_used,
		ch_dmr_headshots,

		ch_sniper_kills,
		ch_sniper_pilot_kills,
		ch_sniper_spectre_kills,
		ch_sniper_grunt_kills,
		ch_sniper_hours_used,

		// Pilot Secondary

		ch_smr_titan_kills,
		ch_smr_crits,

		ch_mgl_titan_kills,

		ch_archer_titan_kills,

		ch_defender_titan_kills,
		ch_defender_crits,

		// Pilot Sidearm

		ch_autopistol_kills,
		ch_autopistol_pilot_kills,
		ch_autopistol_spectre_kills,
		ch_autopistol_marvin_kills,
		ch_autopistol_grunt_kills,
		ch_autopistol_headshots,

		ch_semipistol_kills,
		ch_semipistol_pilot_kills,
		ch_semipistol_spectre_kills,
		ch_semipistol_marvin_kills,
		ch_semipistol_grunt_kills,
		ch_semipistol_headshots,

		ch_wingman_kills,
		ch_wingman_pilot_kills,
		ch_wingman_spectre_kills,
		ch_wingman_marvin_kills,
		ch_wingman_grunt_kills,
		ch_wingman_headshots,

		// Pilot Ordnance

		ch_frag_grenade_throws,
		ch_frag_grenade_kills,
		ch_frag_grenade_pilot_kills,
		ch_frag_grenade_grunt_kills,

		ch_emp_grenade_throws,
		ch_emp_grenade_kills,
		ch_emp_grenade_pilot_kills,
		ch_emp_grenade_grunt_kills,
		ch_emp_grenade_spectre_kills,

		ch_proximity_mine_throws,
		ch_proximity_mine_kills,
		ch_proximity_mine_pilot_kills,
		ch_proximity_mine_grunt_kills,

		ch_satchel_throws,
		ch_satchel_kills,
		ch_satchel_pilot_kills,
		ch_satchel_grunt_kills,

		//Fireteam Defense
		ch_coop_wins,
		ch_coop_perfect_waves,
		ch_coop_nuke_titans,
		ch_coop_suicide_spectres,
		ch_coop_mortar_titans,
		ch_coop_turrets,
		ch_coop_emp_titans,
		ch_coop_bubble_shield_grunts,
		ch_coop_cloak_drones,
		ch_coop_dropships,
		ch_coop_snipers
	}

	pdef_enums <- challenge

	enum dailychallenge
	{
		NULL,
		// Dailies

		ch_daily_games_played,
		ch_daily_games_won,
		ch_daily_games_mvp,
		ch_daily_titan_falls,
		ch_daily_rodeos,
		ch_daily_times_ejected,
		ch_daily_spectres_leeched,

		ch_daily_grunt_kills,
		ch_daily_marvin_kills,
		ch_daily_pilot_kills,
		ch_daily_titan_kills,
		ch_daily_spectre_kills,
		ch_daily_rodeo_kills,

		ch_daily_kills_while_using_burncard,
		ch_daily_kill_npcs,
		ch_daily_kills_while_doomed,
		ch_daily_kills_as_stryder,
		ch_daily_kills_as_atlas,
		ch_daily_kills_as_ogre,
		ch_daily_headshots,
		ch_daily_kills_evac_ships,
		ch_daily_kills_flyers,
		ch_daily_kills_nuclear_core,
		ch_daily_kills_evacuating_enemies,

		ch_daily_first_strikes,
		ch_daily_cloaked_pilot_kills,
		ch_daily_kills_while_cloaked,
		ch_daily_titanFallKill,
		ch_daily_petTitanKillsFollowMode,
		ch_daily_petTitanKillsGuardMode,

		ch_daily_ejecting_pilot_kills,
		ch_daily_kills_while_ejecting,
		ch_daily_kills_while_wallrunning,
		ch_daily_kills_while_wallhanging,
		ch_daily_titanStepCrush,
		ch_daily_titanStepCrushPilot,

		ch_daily_pilotExecutePilot,
		ch_daily_pilotKickMelee,
		ch_daily_pilotKickMeleePilot,
		ch_daily_titanMelee,
		ch_daily_titanMeleePilot,
		ch_daily_titanExocutionStryder,
		ch_daily_titanExocutionAtlas,
		ch_daily_titanExocutionOgre,

		ch_daily_40mm_kills,
		ch_daily_40mm_pilot_kills,
		ch_daily_40mm_titan_kills,
		ch_daily_40mm_grunt_kills,
		ch_daily_40mm_crits,

		ch_daily_xo16_kills,
		ch_daily_xo16_pilot_kills,
		ch_daily_xo16_titan_kills,
		ch_daily_xo16_grunt_kills,
		ch_daily_xo16_crits,

		ch_daily_titan_sniper_kills,
		ch_daily_titan_sniper_pilot_kills,
		ch_daily_titan_sniper_titan_kills,
		ch_daily_titan_sniper_grunt_kills,
		ch_daily_titan_sniper_crits,

		ch_daily_arc_cannon_kills,
		ch_daily_arc_cannon_pilot_kills,
		ch_daily_arc_cannon_titan_kills,
		ch_daily_arc_cannon_grunt_kills,
		ch_daily_arc_cannon_multi_kills,

		ch_daily_rocket_launcher_kills,
		ch_daily_rocket_launcher_pilot_kills,
		ch_daily_rocket_launcher_titan_kills,
		ch_daily_rocket_launcher_grunt_kills,

		ch_daily_triple_threat_kills,
		ch_daily_triple_threat_pilot_kills,
		ch_daily_triple_threat_titan_kills,
		ch_daily_triple_threat_grunt_kills,

		ch_daily_salvo_rockets_kills,
		ch_daily_salvo_rockets_pilot_kills,
		ch_daily_salvo_rockets_titan_kills,
		ch_daily_salvo_rockets_grunt_kills,

		ch_daily_homing_rockets_titan_kills,

		ch_daily_dumbfire_rockets_kills,
		ch_daily_dumbfire_rockets_pilot_kills,
		ch_daily_dumbfire_rockets_titan_kills,
		ch_daily_dumbfire_rockets_grunt_kills,

		ch_daily_shoulder_rockets_titan_kills,

		ch_daily_smart_pistol_kills,
		ch_daily_smart_pistol_pilot_kills,
		ch_daily_smart_pistol_spectre_kills,
		ch_daily_smart_pistol_grunt_kills,

		ch_daily_shotgun_kills,
		ch_daily_shotgun_pilot_kills,
		ch_daily_shotgun_spectre_kills,
		ch_daily_shotgun_grunt_kills,

		ch_daily_r97_kills,
		ch_daily_r97_pilot_kills,
		ch_daily_r97_spectre_kills,
		ch_daily_r97_grunt_kills,
		ch_daily_r97_headshots,

		ch_daily_car_kills,
		ch_daily_car_pilot_kills,
		ch_daily_car_spectre_kills,
		ch_daily_car_grunt_kills,
		ch_daily_car_headshots,

		ch_daily_lmg_kills,
		ch_daily_lmg_pilot_kills,
		ch_daily_lmg_spectre_kills,
		ch_daily_lmg_grunt_kills,
		ch_daily_lmg_headshots,

		ch_daily_rspn101_kills,
		ch_daily_rspn101_pilot_kills,
		ch_daily_rspn101_spectre_kills,
		ch_daily_rspn101_grunt_kills,
		ch_daily_rspn101_headshots,

		ch_daily_hemlok_kills,
		ch_daily_hemlok_pilot_kills,
		ch_daily_hemlok_spectre_kills,
		ch_daily_hemlok_grunt_kills,
		ch_daily_hemlok_headshots,

		ch_daily_g2_kills,
		ch_daily_g2_pilot_kills,
		ch_daily_g2_spectre_kills,
		ch_daily_g2_grunt_kills,
		ch_daily_g2_headshots,

		ch_daily_dmr_kills,
		ch_daily_dmr_pilot_kills,
		ch_daily_dmr_spectre_kills,
		ch_daily_dmr_grunt_kills,
		ch_daily_dmr_headshots,

		ch_daily_sniper_kills,
		ch_daily_sniper_pilot_kills,
		ch_daily_sniper_spectre_kills,
		ch_daily_sniper_grunt_kills,

		ch_daily_smr_titan_kills,
		ch_daily_smr_crits,
		ch_daily_mgl_titan_kills,
		ch_daily_archer_titan_kills,
		ch_daily_defender_titan_kills,
		ch_daily_defender_crits,

		ch_daily_autopistol_kills,
		ch_daily_autopistol_pilot_kills,
		ch_daily_autopistol_spectre_kills,
		ch_daily_autopistol_grunt_kills,
		ch_daily_autopistol_headshots,

		ch_daily_semipistol_kills,
		ch_daily_semipistol_pilot_kills,
		ch_daily_semipistol_spectre_kills,
		ch_daily_semipistol_grunt_kills,
		ch_daily_semipistol_headshots,

		ch_daily_wingman_kills,
		ch_daily_wingman_pilot_kills,
		ch_daily_wingman_spectre_kills,
		ch_daily_wingman_grunt_kills,
		ch_daily_wingman_headshots,

		ch_daily_frag_grenade_kills,
		ch_daily_frag_grenade_pilot_kills,
		ch_daily_frag_grenade_grunt_kills,

		ch_daily_emp_grenade_kills,
		ch_daily_emp_grenade_pilot_kills,
		ch_daily_emp_grenade_grunt_kills,
		ch_daily_emp_grenade_spectre_kills,

		ch_daily_proximity_mine_kills,
		ch_daily_proximity_mine_pilot_kills,
		ch_daily_proximity_mine_grunt_kills,

		ch_daily_satchel_kills,
		ch_daily_satchel_pilot_kills,
		ch_daily_satchel_grunt_kills,

		ch_daily_burncards_used,
		ch_daily_flag_captures,
		ch_daily_evacs_survived,
		ch_daily_hardpoints_captured,
		ch_daily_killing_sprees,

		ch_daily_play_at,
		ch_daily_play_ctf,
		ch_daily_play_lts,
		ch_daily_play_cp,
		ch_daily_play_tdm,
		ch_daily_play_wlts,
		ch_daily_play_mfd,
		ch_daily_play_coop,

		ch_daily_win_at,
		ch_daily_win_ctf,
		ch_daily_win_lts,
		ch_daily_win_cp,
		ch_daily_win_tdm,
		ch_daily_win_wlts,
		ch_daily_win_mfd,
		ch_daily_win_coop,
	}

	pdef_enums <- dailychallenge

	pdef_structs <- {
	    eChallenge = {
	        progress = "float",
	        previousProgress = "float"
	    }
	}

	pdef_values <- { challenges = "eChallenge[challenge]" }
	pdef_values <- { dailychallenges = "eChallenge[dailychallenge]" }

	pdef_structs <- {
	    activeDailyChallenge = {
	        ref = "dailychallenge",
	        day = "int"
	    }
	}

	pdef_values <- { activeDailyChallenges = "activeDailyChallenge[9]" }

	pdef_values <- { trackedChallenges = "int[3]" }
	pdef_values <- { EOGTrackedChallenges = "int[3]" }
	pdef_values <- { trackedChallengeRefs = "string{64}[3]" }
	pdef_values <- { EOGTrackedChallengeRefs = "string{64}[3]" }
	pdef_values <- { newRegenChallenges = "bool" }
	pdef_values <- { dailyChallengeDayIndex = "int" }
	pdef_values <- { newDailyChallenges = "bool" }

	//#########################
	// 		ACHIEVEMENTS
	//#########################

	pdef_values <- { ach_campaignWonAllLevelsIMC, "int" }
	pdef_values <- { ach_campaignWonAllLevelsMCOR, "int" }
	pdef_values <- { ach_createPilotLoadout, "bool" }
	pdef_values <- { ach_createTitanLoadout, "bool" }
	pdef_values <- { ach_allModesAllMaps, "bool" }
	pdef_values <- { ach_multikillArcRifle, "bool" }
	pdef_values <- { ach_completedTraining, "bool" }
	pdef_values <- { ach_unlockEverything, "bool" }
	pdef_values <- { ach_allChallengesForSingleWeapon, "bool" }
	pdef_values <- { ach_vortexVolley, "bool" }
	pdef_values <- { ach_killedAllEvacPlayersSolo, "bool" }
	pdef_values <- { ach_reachedMaxLevel, "bool" }

	// DLC 1
	pdef_values <- { ach_swamplandWon, "bool" }
	pdef_values <- { ach_swamplandAllModes, "int" }
	pdef_values <- { ach_swamplandDontTouchGround, "bool" }
	pdef_values <- { ach_swamplandAirborne, "float" }
	pdef_values <- { ach_runoffWon, "bool" }
	pdef_values <- { ach_runoffAllModes, "int" }
	pdef_values <- { ach_runoffEnemiesKilledWallrunning, "int" }
	pdef_values <- { ach_runoffEnemiesKilled, "int" }
	pdef_values <- { ach_wargamesWon, "bool" }
	pdef_values <- { ach_wargamesAllModes, "int" }
	pdef_values <- { ach_wargamesPilotKillsSingleMatch, "bool" }
	pdef_values <- { ach_wargamesPilotsKilled, "int" }

	// DLC 2
	pdef_structs <- {
	    dlc2achievements = {
	        ach_havenWon = "bool",
	        ach_havenAllModes = "int",
	        ach_havenTitansExecuted = "bool",
	        ach_havenTitansKilledWhileBCActive = "int",
	        ach_exportWon = "bool",
	        ach_exportAllModes = "int",
	        ach_exportTrapKill = "bool",
	        ach_exportKillsWhileCloaked = "int",
	        ach_digsiteWon = "bool",
	        ach_digsiteAllModes = "int",
	        ach_digsitePilotKillsSingleMatch = "bool",
	        ach_digsitePilotKills = "int"
	    }
	}

	pdef_values <- { dlc2achievement = "dlc2achievements" }

	// DLC 3
	pdef_values <- {
	    dlc3achievements = {
	        ach_backwaterWon = "bool",
	        ach_backwaterAllModes = "int",
	        ach_backwaterAmpedVortexKills = "int",
	        ach_backwaterMeleeCloakKills = "int",
	        ach_sandtrapWon = "bool",
	        ach_sandtrapAllModes = "int",
	        ach_sandtrapActiveRadarKills = "int",
	        ach_sandtrap2TitanKillsAsPilot = "bool",
	        ach_zone18Won = "bool",
	        ach_zone18AllModes = "int",
	        ach_zone18StimPilotKills = "int",
	        ach_zone18PilotKillsAsTitan = "bool"
	    }
	}

	pdef_values <- { dlc3achievement = "dlc3achievements" }

	pdef_values <- {
	    cu8achievements = {
	        ach_blackMarketCreditsEarned = "int",
	        ach_burncardsDiscarded = "int",
	        ach_titanVoicePacksUnlocked = "int",
	        ach_allDailyChallengesForDay = "bool",
	        ach_twoStarCoopMaps = "int",
	        ach_renamedCustomLoadout = "bool",
	        ach_titanInsigniasUnlocked = "int",
	        ach_titanBurnCardsUsed = "int",
	        ach_threeStarsAwarded = "bool",
	        ach_totalStarsEarned = "int",
	        ach_rankedGamesPlayed = "int",
	        ach_battlemarksEarned = "int",
	        ach_reachedGen10NoForgedCert = "bool"
	    }
	}

	pdef_structs <- {
	    cu8achievement = {
	        ach_blackMarketCreditsEarned = "int",
	        ach_burncardsDiscarded = "int",
	        ach_titanVoicePacksUnlocked = "int",
	        ach_allDailyChallengesForDay = "bool",
	        ach_twoStarCoopMaps = "int",
	        ach_renamedCustomLoadout = "bool",
	        ach_titanInsigniasUnlocked = "int",
	        ach_titanBurnCardsUsed = "int",
	        ach_threeStarsAwarded = "bool",
	        ach_totalStarsEarned = "int",
	        ach_rankedGamesPlayed = "int",
	        ach_battlemarksEarned = "int",
	        ach_reachedGen10NoForgedCert = "bool"
	    }
	}

	pdef_values <- { cu8achievements = "cu8achievement" }

	//#########################
	// TRAINING
	//#########################

	// the order of these should match the order of eTrainingModules in _consts
	enum trainingModules
	{
		JUMP,
		WALLRUN,
		WALLRUN_PLAYGROUND,
		DOUBLEJUMP,
		DOUBLEJUMP_PLAYGROUND,
		CLOAK,
		BASIC_COMBAT,
		FIRINGRANGE,
		FIRINGRANGE_GRENADES,
		MOSH_PIT,
		TITAN_DASH,
		TITAN_VORTEX,
		TITAN_PET,
		TITAN_MOSH_PIT,
		BEDROOM_END  // this is normally -2 in other enums that list the training modules
	}

	pdef_values <- { trainingModulesCompleted = "bool[trainingModules]" }

	//#########################
	//    EOG Scoreboard
	//#########################

	pdef_structs <- {
	    eScoreboardPlayer = {
	        name = "string{32}",
	        xuid = "string{22}",
	        level = "int",
	        gen = "int",
	        score_assault = "int",
	        score_defense = "int",
	        score_kills = "int",
	        score_deaths = "int",
	        score_titanKills = "int",
	        score_npcKills = "int",
	        score_assists = "int",
	        playingRanked = "bool",
	        rank = "int",
	        matchPerformance = "float"
	    }

	    eScoreboardData = {
	        gameMode = "int",
	        map = "int",
	        playerTeam = "int",
	        playerIndex = "int",
	        maxTeamPlayers = "int",
	        numPlayersIMC = "int",
	        numPlayersMCOR = "int",
	        scoreIMC = "int",
	        scoreMCOR = "int",
	        privateMatch = "bool",
	        campaign = "bool",
	        ranked = "bool",
	        hadMatchLossProtection = "bool",
	        playersIMC = "eScoreboardPlayer[8]",
	        playersMCOR = "eScoreboardPlayer[8]"
	    }
	}

	pdef_values <- { savedScoreboardData = "eScoreboardData" }

	pdef_values <- { previousGooserProgress = "int" }

	//#########################
	//    Coop EOG Scoreboard
	//#########################

	pdef_structs <- {
	    eCoopKillStats = {
	        killCount = "int",
	        turretKillCount = "int"
	    },

	    eCoopPlayer = {
	        name = "string{32}",
	        xuid = "string{22}",
	        entityIndex = "int",
	        enemyType = "eCoopKillStats[9]"
	    },

	    eCoopTeamScore = {
	        enemiesKilled = "int",
	        maxEnemiesKilled = "int",
	        harvesterHealth = "int",
	        maxHarvesterHealth = "int",
	        wavesCompletedBonus = "int",
	        maxWavesCompletedBonus = "int",
	        finalWaveCompletedBonus = "int",
	        maxFinalWaveCompletedBonus = "int",
	        flawlessWaveBonus = "int",
	        maxFlawlessWaveBonus = "int",
	        retriesBonus = "int",
	        maxRetriesBonus = "int",
	        teamScore = "int"
	    },

	    eCoopData = {
	        completedWaves = "int",
	        totalWaves = "int",
	        harvesterHealth = "int",
	        retriesUsed = "int",
	        gameDuration = "int",
	        starsEarned = "int",
	        teamScore = "eCoopTeamScore",
	        militiaKillCounts = "eCoopKillStats[9]",
	        players = "eCoopPlayer[4]"
	    },

	    eCoopData = {
	        completedWaves = "int",
	        totalWaves = "int",
	        harvesterHealth = "int",
	        retriesUsed = "int",
	        gameDuration = "int",
	        starsEarned = "int",
	        teamScore = "eCoopTeamScore",
	        militiaKillCounts = "eCoopKillStats[9]",
	        players = "eCoopPlayer[4]"
	    }
	}

	pdef_values <- { savedCoopData = "eCoopData" }

	//#########################
	// GAME HISTORY
	//#########################

	// If these are size adjusted, re-initialize with InitPlayerMapHistory() and InitPlayerModeHistory()
	pdef_values <- { mapHistory = "int[24]" }
	pdef_values <- { modeHistory = "int[10]" }

	//#########################
	// BLACK MARKET
	//#########################

	enum BlackMarketUnlocks
	{
	    titan_decals_blackmarket01,
		titan_decals_blackmarket02,
		titan_decals_blackmarket03,
		titan_decals_blackmarket04,
		titan_decals_blackmarket05,
		titan_decals_blackmarket06,
		titan_decals_blackmarket07,
		titan_decals_blackmarket08,
		titanos_femaleassistant,
		titanos_maleintimidator,
		titanos_bettyde,
		titanos_bettyen,
		titanos_bettyes,
		titanos_bettyfr,
		titanos_bettyit,
		titanos_bettyjp,
		titanos_bettyru
	}

	pdef_enums <- BlackMarketUnlocks

	enum blackMarketPerishableTypes
	{
	    NULL,
	    perishable_burncard
	}

	pdef_enums <- blackMarketPerishableTypes

	pdef_structs <- {
	    struct_blackMarketPerishables = {
	        nextRestockDate = "int",
	        perishableType = "blackMarketPerishableTypes",
	        cardRef = "burnCard",
	        coinCost = "int",
	        new = "bool"
	    },

	    struct_blackMarket = {
	        coinCount = "int",
	        previousCoinCount = "int",
	        coin_rewards = "int[6]",
	        coin_reward_counts = "int[6]",
	        newBlackMarketItems = "bool",
	        nextDiceCardDate = "int",
	        blackMarketItemUnlocks = "bool[BlackMarketUnlocks]",
	        blackMarketPerishables = "struct_blackMarketPerishables[9]",
	        challengeSkips = "int"
	    }
	}

	pdef_values <- { bm = "struct_blackMarket" }

	//#########################
	// Dailies
	//#########################

	pdef_values <- { lastDailyMatchVictory = "int" }
	pdef_values <- { lastTimePlayed = "int" }
	pdef_values <- { lastTimeLoggedIn = "int" }

	//#########################
	// 	  3 Stars Per Map
	//#########################

	pdef_structs <- {
	    structMapStars = {
	        bestScore = "int[gameModesWithStars]",
	        previousBestScore = "int[gameModesWithStars]"
	    }
	}

	pdef_values <- { mapStars = "structMapStars[maps]" }

	pdef_values <- { playlistAnnouncementSeen = "bool" }
}