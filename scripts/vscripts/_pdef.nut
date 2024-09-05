::pdef_arrays <- {}
::pdef_enums <- {}
::pdef_keys <- {}

function AddPersistenceKey(key, type) {
    pdef_keys[key] <- type
}

function AddPersistenceEnum(key, table)
{
    pdef_enums[key] <- table
}

function AddPersistenceArray(key, length)
{
    pdef_arrays[key] <- length
}

function InitPersistence()
{
    AddPersistenceKey("previouslyInitialized", "bool")
    AddPersistenceKey("initializedVersion", "int")
    AddPersistenceKey("xp", "int")
    AddPersistenceKey("previousXP", "int")
    AddPersistenceKey("xp_match", "int")
    AddPersistenceArray("xp_match", 48)
    AddPersistenceKey("xp_match_count", "int")
    AddPersistenceArray("xp_match_count", 48)

    ::gameModes <- {
        tdm = 0
        cp = 1
        at = 2
        ctf = 3
        lts = 4
        wlts = 5
        mfd = 6
        mfdp = 7
        coop = 8
        ps = 9
    }

    AddPersistenceEnum("gameModes", gameModes)

    ::gameModesWithLoadouts <- {
        tdm = 0
	    cp = 1
	    at = 2
	    ctf = 3
	    lts = 4
	    mfd = 5
	    coop = 6
    }

    AddPersistenceEnum("gameModesWithLoadouts", gameModesWithLoadouts)

    ::gameModesWithStars <- {
	    tdm = 0
	    cp = 1
	    at = 2
	    ctf = 3
	    lts = 4
	    mfd = 5
	    coop = 6
    }

    AddPersistenceEnum("gameModesWithStars", gameModesWithStars)

    ::maps <- {
	    mp_box = 0
	    mp_test_engagement_range = 1
	    mp_airbase = 2
	    mp_angel_city = 3
	    mp_boneyard = 4
	    mp_colony = 5
	    mp_corporate = 6
	    mp_fracture = 7
	    mp_lagoon = 8
	    mp_nexus = 9
	    mp_o2 = 10
	    mp_outpost_207 = 11
	    mp_overlook = 12
	    mp_relic = 13
	    mp_rise = 14
	    mp_smugglers_cove = 15
	    mp_training_ground = 16
	    mp_runoff = 17				// DLC 1
	    mp_swampland = 18			// DLC 1
	    mp_wargames = 19			// DLC 1
	    mp_harmony_mines = 20		// DLC 2
	    mp_switchback = 21			// DLC 2
	    mp_haven = 22				// DLC 2
	    mp_zone_18 = 23				// DLC 3
	    mp_backwater = 24			// DLC 3
	    mp_sandtrap	= 25			// DLC 3
    }

    AddPersistenceEnum("maps", maps)

    ::loadoutItems <- {
        NULL = 0
	    mp_weapon_rspn101 = 1
	    mp_weapon_smart_pistol = 2
	    mp_weapon_shotgun = 3
	    mp_weapon_hemlok = 4
	    mp_weapon_r97 = 5
	    mp_weapon_sniper = 6
	    mp_weapon_g2 = 7
	    mp_weapon_car = 8
	    mp_weapon_dmr = 9
	    mp_weapon_smr = 10
	    mp_weapon_defender = 11
	    mp_weapon_lmg = 12
	    mp_weapon_mgl = 13
	    mp_weapon_rocket_launcher = 14
	    mp_weapon_wingman = 15
	    mp_weapon_semipistol = 16
	    mp_weapon_autopistol = 17
	    mp_weapon_frag_grenade = 18
	    mp_weapon_grenade_emp = 19
	    mp_weapon_satchel = 20
	    mp_weapon_proximity_mine = 21
	    mp_titanweapon_xo16 = 22
	    mp_titanweapon_40mm = 23
	    mp_titanweapon_rocket_launcher = 24
	    mp_titanweapon_arc_cannon = 25
	    mp_titanweapon_triple_threat = 26
	    mp_titanweapon_vortex_shield = 27
	    mp_titanweapon_dumbfire_rockets = 28
	    mp_titanweapon_shoulder_rockets = 29
	    mp_titanweapon_homing_rockets = 30
	    mp_titanweapon_salvo_rockets = 31
	    mp_titanweapon_sniper = 32
	    mp_titanability_smoke = 33
	    mp_titanability_fusion_core = 34
	    mp_titanability_bubble_shield = 35
	    mp_ability_cloak = 36
	    mp_ability_heal = 37
	    mp_ability_sonar = 38
    }

    AddPersistenceEnum("loadoutItems", loadoutItems)

    ::pilotMod <- {
        NULL = 0
	    aog = 1
	    automatic_fire = 2
	    burn_mod_autopistol = 3
	    burn_mod_car = 4
	    burn_mod_defender = 5
	    burn_mod_dmr = 6
	    burn_mod_emp_grenade = 7
	    burn_mod_frag_grenade = 8
	    burn_mod_g2 = 9
	    burn_mod_hemlok = 10
	    burn_mod_lmg = 11
	    burn_mod_mgl = 12
	    burn_mod_proximity_mine = 13
	    burn_mod_r97 = 14
	    burn_mod_rspn101 = 15
	    burn_mod_satchel = 16
	    burn_mod_semipistol = 17
	    burn_mod_smart_pistol = 18
	    burn_mod_smr = 19
	    burn_mod_sniper = 20
	    burn_mod_rocket_launcher = 21
	    burst = 22
	    enhanced_targeting = 23
	    extended_ammo = 24
	    fast_lock = 25
	    fast_reload = 26
	    guided_missile = 27
	    hcog = 28
	    high_density = 29
	    holosight = 30
	    integrated_gyro = 31
	    iron_sights = 32
	    long_fuse = 33
	    match_trigger = 34
	    powered_magnets = 35
	    recoil_compensator = 36
	    scatterfire = 37
	    scope_4x = 38
	    scope_6x = 39
	    scope_8x = 40
	    scope_10x = 41
	    scope_12x = 42
	    burn_mod_shotgun = 43
	    silencer = 44
	    sniper_assist = 45
	    stabilizer = 46
	    starburst = 47
	    single_shot = 48
	    slammer = 49
	    spread_increase_sg = 50
	    stabilized_warhead = 51
	    tank_buster = 52
	    burn_mod_wingman = 53
    }

    AddPersistenceEnum("pilotMod", pilotMod)

    ::titanSetFile <- {
        NULL = 0
	    titan_atlas = 1
	    titan_ogre = 2
	    titan_stryder = 3
    }

    AddPersistenceEnum("titanSetFile", titanSetFile)

    ::titanMod <- {
        NULL = 0
	    accelerator = 1
	    afterburners = 2
	    arc_triple_threat = 3
	    burn_mod_titan_40mm = 4
	    burn_mod_titan_arc_cannon = 5
	    burn_mod_titan_rocket_launcher = 6
	    burn_mod_titan_sniper = 7
	    burn_mod_titan_triple_threat = 8
	    burn_mod_titan_xo16 = 9
	    burn_mod_titan_dumbfire_rockets = 10
	    burn_mod_titan_homing_rockets = 11
	    burn_mod_titan_salvo_rockets = 12
	    burn_mod_titan_shoulder_rockets = 13
	    burn_mod_titan_vortex_shield = 14
	    burn_mod_titan_smoke = 15
	    burn_mod_titan_bubble_shield = 16
	    burst = 17
	    capacitor = 18
	    extended_ammo = 19
	    fast_lock = 20
	    fast_reload = 21
	    instant_shot = 22
	    mine_field = 23
	    overcharge = 24
	    quick_shot = 25
	    rapid_fire_missiles = 26
    }

    AddPersistenceEnum("titanMod", titanMod)

    ::pilotPassive <- {
        NULL = 0
	    pas_stealth_movement = 1
	    pas_ordnance_pack = 2
	    pas_power_cell = 3
	    pas_minimap_ai = 4
	    pas_longer_bubble = 5
	    pas_run_and_gun = 6
	    pas_dead_mans_trigger = 7
	    pas_wall_runner = 8
	    pas_turbo_drop = 9
	    pas_enhanced_titan_ai = 10
	    pas_fast_reload = 11
	    pas_fast_hack = 12
    }

    AddPersistenceEnum("pilotPassive", pilotPassive)

    ::pilotRace <- {
        race_human_male = 0
	    race_human_female = 1
    }

    AddPersistenceEnum("pilotRace", pilotRace)

    ::titanPassive <- {
        NULL = 0
	    pas_auto_eject = 1
	    pas_doomed_time = 2
	    pas_dash_recharge = 3
	    pas_defensive_core = 4
	    pas_titan_punch = 5
	    pas_shield_regen = 6
	    pas_assault_reactor = 7
	    pas_hyper_core = 8
	    pas_marathon_core = 9
	    pas_build_up_nuclear_core = 10
    }

    AddPersistenceEnum("titanPassive", titanPassive)

    ::titanDecals <- {
        NULL = 0,
	    titan_decal_a_base_imc = 1,
	    titan_decal_b_base_mcor = 2,
	    ["5kw_custom_decal"] = 3,
	    ["30_titan_decal"] = 4,
	    ace_custom_decal = 5,
	    bomb_lit_custom_decal = 6,
	    bombs_custom_decal = 7,
	    bullet_hash_custom_decal = 8,
	    eye_custom_decal = 9,
	    hand_custom_decal = 10,
	    pitchfork_custom_decal = 11,
	    red_chevron_custom_decal = 12,
	    ["titan_decal_4"] = 13,
	    ["titan_decal_13"] = 14,
	    ["titan_decal_19"] = 15,
	    ["titan_decal_27"] = 16,
	    titan_decal_ace = 17,
	    titan_decal_animalskull = 18,
	    titan_decal_bluestar = 19,
	    titan_decal_brokenstar = 20,
	    titan_decal_conejo = 21,
	    titan_decal_crazybomb = 22,
	    titan_decal_defiant = 23,
	    titan_decal_dice = 24,
	    titan_decal_dino = 25,
	    titan_decal_eagle = 26,
	    titan_decal_eagleShield = 27,
	    ["titan_decal_fa95"] = 28,
	    titan_decal_flameskull = 29,
	    ["titan_decal_gen1"] = 30,
	    ["titan_decal_gen2"] = 31,
	    ["titan_decal_gen3"] = 32,
	    ["titan_decal_gen4"] = 33,
	    ["titan_decal_gen5"] = 34,
	    ["titan_decal_gen6"] = 35,
	    ["titan_decal_gen7"] = 36,
	    ["titan_decal_gen8"] = 37,
	    ["titan_decal_gen9"] = 38,
	    ["titan_decal_gen10"] = 39,
	    titan_decal_girly = 40,
	    titan_decal_gremlin = 41,
	    titan_decal_hammond = 42,
	    titan_decal_imc_gear = 43,
	    titan_decal_imc_old = 44,
	    ["titan_decal_IMC01"] = 45,
	    ["titan_decal_IMC02"] = 46,
	    ["titan_decal_IMC03"] = 47,
	    titan_decal_imctri = 48,
	    titan_decal_killmarks = 49,
	    titan_decal_ksa = 50,
	    ["titan_decal_letter01_opa"] = 51,
	    titan_decal_mcor = 52,
	    titan_decal_militia = 53,
	    titan_decal_oldMcor = 54,
	    titan_decal_redstarv = 55,
	    titan_decal_shield = 56,
	    titan_decal_skullwings = 57,
	    titan_decal_skullwingsBLK = 58,
	    titan_decal_st = 59,
	    titan_decal_ste = 60,
	    titan_decals_stinger = 61,
	    wings_custom_decal = 62,
	    titan_decal_flagrunner = 63,
	    titan_decal_twofer = 64,
	    ["titan_decal_100guns"] = 65,
	    titan_decal_crest = 66,
	    titan_decal_titankills = 67,
	    titan_decal_eagleside = 68,
	    titan_decal_chevrons = 69,
	    titan_decal_glyph = 70,
	    titan_decal_triangle = 71,
	    titan_decal_kodai = 72,
	    titan_decal_nuke = 73,
	    titan_decal_fallingbomb = 74,
	    titan_decal_grenade = 75,
	    titan_decal_firsttofall = 76,
	    titan_decal_pennyarcade = 77,
	    titan_decal_dragon = 78,
	    titan_decal_respawnbird = 79,
	    titan_decal_wonjae = 80,
	    titan_decal_lastimosa = 81,
	    titan_decal_austin = 82,
	    titan_decal_cobra = 83,
	    titan_decal_gunwing = 84,
	    titan_decal_hashtag = 85,
	    titan_decal_nomercy = 86,
	    titan_decal_pegasus = 87,
	    titan_decal_sword = 88,
	    titan_decal_gooser = 89,
	    titan_decal_padoublethreat = 90,
	    ["titan_decals_blackmarket01"] = 91,
	    ["titan_decals_blackmarket02"] = 92,
	    ["titan_decals_blackmarket03"] = 93,
	    ["titan_decals_blackmarket04"] = 94,
	    ["titan_decals_blackmarket05"] = 95,
	    ["titan_decals_blackmarket06"] = 96,
	    ["titan_decals_blackmarket07"] = 97,
	    ["titan_decals_blackmarket08"] = 98,
	    titan_decal_export = 99,
	    titan_decal_harmony = 100,
	    titan_decal_haven = 101,
	    titan_decal_ichicat = 102,
	    titan_decal_pf = 103,
	    ["titan_decal_coop_1"] = 104,
	    ["titan_decal_coop_2"] = 105,
	    ["titan_decals_3s_attrition"] = 106,
	    ["titan_decals_3s_ctf"] = 107,
	    ["titan_decals_3s_frontierdef"] = 108,
	    ["titan_decals_3s_hardpoint"] = 109,
	    ["titan_decals_3s_lts"] = 110,
	    ["titan_decals_3s_marked4death"] = 111,
	    ["titan_decals_3s_pilothunter"] = 112
    }

    AddPersistenceEnum("titanDecals", titanDecals)

    AddPersistenceKey("decalsUnlocked", "bool")
    AddPersistenceArray("decalsUnlocked", "titanDecals")

    ::titanOS <- {
        titanos_betty = 0
	    titanos_malebutler = 1
	    titanos_femaleaudinav = 2
	    titanos_femaleassistant = 3
	    titanos_maleintimidator = 4
	    titanos_bettyde = 5
	    titanos_bettyen = 6
	    titanos_bettyes = 7
	    titanos_bettyfr = 8
	    titanos_bettyit = 9
	    titanos_bettyjp = 10
	    titanos_bettyru = 11
    }

    AddPersistenceEnum("titanOS", titanOS)

    AddPersistenceKey("pilotSpawnLoadout.isCustom", "bool")
    AddPersistenceKey("pilotSpawnLoadout.index", "int")
    AddPersistenceKey("titanSpawnLoadout.isCustom", "bool")
    AddPersistenceKey("titanSpawnLoadout.index", "int")

    AddPersistenceArray("pilotLoadouts", 19)
    AddPersistenceArray("titanLoadouts", 19)

    AddPersistenceKey("pilotLoadouts.name", "string")
    AddPersistenceKey("pilotLoadouts.primary", "loadoutItems")
    AddPersistenceKey("pilotLoadouts.secondary", "loadoutItems")
    AddPersistenceKey("pilotLoadouts.sidearm", "loadoutItems")
    AddPersistenceKey("pilotLoadouts.special", "loadoutItems")
    AddPersistenceKey("pilotLoadouts.ordnance", "loadoutItems")
    AddPersistenceKey("pilotLoadouts.primaryAttachment", "pilotMod")
    AddPersistenceKey("pilotLoadouts.primaryMod", "pilotMod")   
    AddPersistenceKey("pilotLoadouts.passive1", "pilotPassive")
    AddPersistenceKey("pilotLoadouts.passive2", "pilotPassive")
    AddPersistenceKey("pilotLoadouts.race", "pilotRace")

    AddPersistenceKey("titanLoadouts.name", "string")
    AddPersistenceKey("titanLoadouts.setFile", "titanSetFile")
    AddPersistenceKey("titanLoadouts.primary", "loadoutItems")
    AddPersistenceKey("titanLoadouts.special", "loadoutItems")
    AddPersistenceKey("titanLoadouts.ordnance", "loadoutItems")
    AddPersistenceKey("titanLoadouts.primaryMod", "titanMod")
    AddPersistenceKey("titanLoadouts.passive1", "titanPassive")
    AddPersistenceKey("titanLoadouts.passive2", "titanPassive")
    AddPersistenceKey("titanLoadouts.decal", "titanDecals")
    AddPersistenceKey("titanLoadouts.voiceChoice", "titanOS")

    ::modsCombined <- {
	    mp_weapon_car_iron_sights = 0,
	    mp_weapon_car_hcog = 1,
	    mp_weapon_dmr_aog = 2,
	    ["mp_weapon_dmr_scope_4x"] = 3,
	    ["mp_weapon_dmr_scope_6x"] = 4,
	    ["mp_weapon_g2_iron_sights"] = 5,
	    ["mp_weapon_g2_hcog"] = 6,
	    ["mp_weapon_g2_holosight"] = 7,
	    ["mp_weapon_g2_aog"] = 8,
	    mp_weapon_hemlok_iron_sights = 9,
	    mp_weapon_hemlok_hcog = 10,
	    mp_weapon_hemlok_holosight = 11,
	    mp_weapon_hemlok_aog = 12,
	    mp_weapon_lmg_iron_sights = 13,
	    mp_weapon_lmg_hcog = 14,
	    mp_weapon_lmg_holosight = 15,
	    mp_weapon_lmg_aog = 16,
	    ["mp_weapon_rspn101_iron_sights"] = 17,
	    ["mp_weapon_rspn101_hcog"] = 18,
	    ["mp_weapon_rspn101_holosight"] = 19,
	    ["mp_weapon_rspn101_aog"] = 20,
	    ["mp_weapon_r97_iron_sights"] = 21,
	    ["mp_weapon_r97_hcog"] = 22,
	    mp_weapon_sniper_aog = 23,
	    ["mp_weapon_sniper_scope_4x"] = 24,
	    ["mp_weapon_sniper_scope_6x"] = 25,
	    mp_weapon_car_integrated_gyro = 26,
	    mp_weapon_car_extended_ammo = 27,
	    mp_weapon_car_silencer = 28,
	    mp_weapon_dmr_extended_ammo = 29,
	    mp_weapon_dmr_silencer = 30,
	    mp_weapon_dmr_stabilizer = 31,
	    ["mp_weapon_g2_extended_ammo"] = 32,
	    ["mp_weapon_g2_match_trigger"] = 33,
	    ["mp_weapon_g2_silencer"] = 34,
	    mp_weapon_hemlok_extended_ammo = 35,
	    mp_weapon_hemlok_silencer = 36,
	    mp_weapon_hemlok_starburst = 37,
	    mp_weapon_lmg_extended_ammo = 38,
	    mp_weapon_lmg_slammer = 39,
	    ["mp_weapon_r97_extended_ammo"] = 40,
	    ["mp_weapon_r97_scatterfire"] = 41,
	    ["mp_weapon_r97_silencer"] = 42,
	    ["mp_weapon_rspn101_extended_ammo"] = 43,
	    ["mp_weapon_rspn101_recoil_compensator"] = 44,
	    ["mp_weapon_rspn101_silencer"] = 45,
	    mp_weapon_shotgun_extended_ammo = 46,
	    mp_weapon_shotgun_spread_increase_sg = 47,
	    mp_weapon_shotgun_silencer = 48,
	    mp_weapon_smart_pistol_enhanced_targeting = 49,
	    mp_weapon_smart_pistol_extended_ammo = 50,
	    mp_weapon_smart_pistol_silencer = 51,
	    mp_weapon_sniper_extended_ammo = 52,
	    mp_weapon_sniper_silencer = 53,
	    mp_weapon_sniper_stabilizer = 54,
	    mp_weapon_car_burn_mod_car = 55,
	    mp_weapon_dmr_burn_mod_dmr = 56,
	    ["mp_weapon_g2_burn_mod_g2"] = 57,
	    mp_weapon_hemlok_burn_mod_hemlok = 58,
	    mp_weapon_lmg_burn_mod_lmg = 59,
	    ["mp_weapon_r97_burn_mod_r97"] = 60,
	    ["mp_weapon_rspn101_burn_mod_rspn101"] = 61, 
	    mp_weapon_shotgun_burn_mod_shotgun = 62,
	    mp_weapon_smart_pistol_burn_mod_smart_pistol = 63,
	    mp_weapon_sniper_burn_mod_sniper = 64,
	    mp_weapon_wingman_burn_mod_wingman = 65,
	    mp_weapon_mgl_burn_mod_mgl = 66,
	    mp_weapon_rocket_launcher_burn_mod_rocket_launcher = 67,
	    mp_weapon_smr_burn_mod_smr = 68,
	    mp_weapon_defender_burn_mod_defender = 69,
	    mp_weapon_autopistol_burn_mod_autopistol = 70,
	    mp_weapon_semipistol_burn_mod_semipistol = 71,
	    mp_weapon_satchel_burn_mod_satchel = 72,
	    mp_weapon_frag_grenade_burn_mod_frag_grenade = 73,
	    mp_weapon_grenade_emp_burn_mod_grenade_emp = 74,
	    mp_weapon_proximity_mine_burn_mod_proximity_mine = 75,
	    ["mp_titanweapon_40mm_burst"] = 76,
	    ["mp_titanweapon_40mm_extended_ammo"] = 77,
	    ["mp_titanweapon_40mm_fast_reload"] = 78,
	    mp_titanweapon_arc_cannon_capacitor = 79,
	    mp_titanweapon_rocket_launcher_afterburners = 80,
	    mp_titanweapon_rocket_launcher_extended_ammo = 81,
	    mp_titanweapon_rocket_launcher_rapid_fire_missiles = 82,
	    mp_titanweapon_sniper_extended_ammo = 83,
	    mp_titanweapon_sniper_fast_reload = 84,
	    mp_titanweapon_sniper_instant_shot = 85,
	    mp_titanweapon_sniper_quick_shot = 86,
	    mp_titanweapon_triple_threat_extended_ammo = 87,
	    mp_titanweapon_triple_threat_mine_field = 88,
	    ["mp_titanweapon_xo16_accelerator"] = 89,
	    ["mp_titanweapon_xo16_burst"] = 90,
	    ["mp_titanweapon_xo16_extended_ammo"] = 91,
	    ["mp_titanweapon_xo16_fast_reload"] = 92
    }

    AddPersistenceEnum("modsCombined", modsCombined)

    ::unlockRefs <- {
        edit_pilots = 0, // these two must come first
	    edit_titans = 1,

	    ["pilot_preset_loadout_1"] = 2,
	    ["pilot_preset_loadout_2"] = 3,
	    ["pilot_preset_loadout_3"] = 4,

	    ["titan_preset_loadout_1"] = 5,
	    ["titan_preset_loadout_2"] = 6,
	    ["titan_preset_loadout_3"] = 7,

	    ["pilot_custom_loadout_1"] = 8,
	    ["pilot_custom_loadout_2"] = 9,
	    ["pilot_custom_loadout_3"] = 10,
	    ["pilot_custom_loadout_4"] = 11,
	    ["pilot_custom_loadout_5"] = 12,
	    ["pilot_custom_loadout_6"] = 13,
	    ["pilot_custom_loadout_7"] = 14,
	    ["pilot_custom_loadout_8"] = 15,
	    ["pilot_custom_loadout_9"] = 16,
	    ["pilot_custom_loadout_10"] = 17,
	    ["pilot_custom_loadout_11"] = 18,
	    ["pilot_custom_loadout_12"] = 19,
	    ["pilot_custom_loadout_13"] = 20,
	    ["pilot_custom_loadout_14"] = 21,
	    ["pilot_custom_loadout_15"] = 22,
	    ["pilot_custom_loadout_16"] = 23,
	    ["pilot_custom_loadout_17"] = 24,
	    ["pilot_custom_loadout_18"] = 25,
	    ["pilot_custom_loadout_19"] = 26,

	    ["titan_custom_loadout_1"] = 27,
	    ["titan_custom_loadout_2"] = 28,
	    ["titan_custom_loadout_3"] = 29,
	    ["titan_custom_loadout_4"] = 30,
	    ["titan_custom_loadout_5"] = 31,
	    ["titan_custom_loadout_6"] = 31,
	    ["titan_custom_loadout_7"] = 32,
	    ["titan_custom_loadout_8"] = 33,
	    ["titan_custom_loadout_9"] = 34,
	    ["titan_custom_loadout_10"] = 35,
	    ["titan_custom_loadout_11"] = 36,
	    ["titan_custom_loadout_12"] = 37,
	    ["titan_custom_loadout_13"] = 38,
	    ["titan_custom_loadout_14"] = 39,
	    ["titan_custom_loadout_15"] = 40,
	    ["titan_custom_loadout_16"] = 41,
	    ["titan_custom_loadout_17"] = 42,
	    ["titan_custom_loadout_18"] = 43,
	    ["titan_custom_loadout_19"] = 44,

	    ["burn_card_slot_1"] = 45,
	    ["burn_card_slot_2"] = 46,
	    ["burn_card_slot_3"] = 47,

	    ["burn_card_pack_1"] = 48,
	    ["burn_card_pack_2"] = 49,
	    ["burn_card_pack_3"] = 50,
	    ["burn_card_pack_4"] = 51,
	    ["burn_card_pack_5"] = 52,

	    challenges = 53    
    }

    AddPersistenceEnum("unlockRefs", unlockRefs)

    AddPersistenceArray("newLoadoutItems", "loadoutItems")
    AddPersistenceKey("newLoadoutItems", "bool")
    AddPersistenceArray("newMods", "modsCombined")
    AddPersistenceKey("newMods", "bool")
    AddPersistenceArray("newChassis", "titanSetFile")
    AddPersistenceKey("newChassis", "bool")
    AddPersistenceArray("rewardChassis", "titanSetFile")
    AddPersistenceKey("rewardChassis", "bool")
    AddPersistenceArray("newPilotPassives", "pilotPassive")
    AddPersistenceKey("newPilotPassives", "bool")
    AddPersistenceArray("newTitanPassives", "titanPassive")
    AddPersistenceKey("newTitanPassives", "bool")
    AddPersistenceArray("newTitanOS", "titanOS")
    AddPersistenceKey("newTitanOS", "bool")
    AddPersistenceArray("newUnlocks", "unlockRefs")
    AddPersistenceKey("newUnlocks", "bool")
    AddPersistenceArray("newTitanDecals", "titanDecals")
    AddPersistenceKey("newTitanDecals", "bool")

    ::burnCard <- {
	    NULL = 0,
	    bc_conscription = 1,
	    bc_double_xp = 2,
	    bc_free_xp = 3,
	    ["bc_fast_cooldown1"] = 4,
	    ["bc_fast_cooldown2"] = 5,
	    bc_super_stim = 6,
	    bc_super_cloak = 7,
	    bc_super_sonar = 8,
	    bc_summon_ogre = 9,
	    bc_cloak_forever = 10,
	    bc_stim_forever = 11,
	    bc_sonar_forever = 12,
	    bc_summon_stryder = 13,
	    bc_spectre_virus = 14,
	    bc_play_spectre = 15,
	    bc_double_agent = 16,
	    bc_minimap = 17,
	    bc_summon_atlas = 18,
	    bc_megaturrets = 19,
	    bc_summon_dogfighter = 20,
	    bc_wifi_spectre_hack = 21,
	    bc_nuclear_core = 22,
	    bc_core_charged = 23,
	    ["bc_smart_pistol_m2"] = 24,
	    ["bc_r97_m2"] = 25,
	    ["bc_rspn101_m2"] = 26,
	    ["bc_dmr_m2"] = 27,
	    ["bc_shotgun_m2"] = 28,
	    ["bc_lmg_m2"] = 29,
	    ["bc_g2_m2"] = 30,
	    ["bc_car_m2"] = 31,
	    ["bc_hemlok_m2"] = 32,
	    ["bc_sniper_m2"] = 33,
	    ["bc_smr_m2"] = 34,
	    ["bc_mgl_m2"] = 35,
	    ["bc_defender_m2"] = 36,
	    ["bc_rocket_launcher_m2"] = 37,
	    ["bc_semipistol_m2"] = 38,
	    ["bc_autopistol_m2"] = 39,
	    ["bc_wingman_m2"] = 40,
	    ["bc_satchel_m2"] = 41,
	    ["bc_frag_m2"] = 42,
	    ["bc_arc_m2"] = 43,
	    ["bc_prox_m2"] = 44,
	    bc_pilot_warning = 45,
	    bc_rematch = 46,
	    bc_minimap_scan = 47,
	    ["bc_free_build_time_1"] = 48,
	    ["bc_free_build_time_2"] = 49,
	    ["bc_fast_build_1"] = 50,
	    ["bc_fast_build_2"] = 51,
	    bc_hunt_soldier = 52,
	    bc_hunt_spectre = 53,
	    bc_hunt_titan = 54,
	    bc_hunt_pilot = 55,
	    bc_auto_sonar = 56,
	    bc_fast_movespeed = 57,
	    bc_auto_refill = 58,
	    bc_dice_ondeath = 59,
	    ["bc_titan_40mm_m2"] = 60,
	    ["bc_titan_arc_cannon_m2"] = 61,
	    ["bc_titan_rocket_launcher_m2"] = 62,
	    ["bc_titan_sniper_m2"] = 63,
	    ["bc_titan_triple_threat_m2"] = 64,
	    ["bc_titan_xo16_m2"] = 65,
	    ["bc_titan_dumbfire_missile_m2"] = 66,
	    ["bc_titan_homing_rockets_m2"] = 67,
	    ["bc_titan_salvo_rockets_m2"] = 68,
	    ["bc_titan_shoulder_rockets_m2"] = 69,
	    ["bc_titan_vortex_shield_m2"] = 70,
	    ["bc_titan_electric_smoke_m2"] = 71,
	    ["bc_titan_shield_wall_m2"] = 72,
	    ["bc_titan_melee_m2"] = 73,
	    ["bc_extra_dash"] = 74,      
    }

    AddPersistenceEnum("burnCard", burnCard)

    AddPersistenceArray("persData_historyBurnCards", "burnCard")
    AddPersistenceKey("persData_historyBurnCards.collected", "int")
    AddPersistenceKey("persData_historyBurnCards.spent", "int")

    AddPersistenceKey("onDeckBurnCardIndex", "int")
    AddPersistenceKey("activeBCID", "int")

    AddPersistenceArray("persData_activeBurnCards", 3)
    AddPersistenceKey("persData_activeBurnCards.cardRef", "burnCard")
    AddPersistenceKey("persData_activeBurnCards.lastCardRef", "burnCard")
    AddPersistenceKey("persData_activeBurnCards.clearOnStart", "bool")

    AddPersistenceArray("persData_unopenedBurnCards", 25)
    AddPersistenceKey("persData_unopenedBurnCards", "burnCard")

    AddPersistenceKey("burncardStoryProgress", "int")

    AddPersistenceKey("currentBurnCardPile", "int")
    AddPersistenceArray("currentBurnCardOffset", 3)
    AddPersistenceKey("currentBurnCardOffset", "int")

    AddPersistenceArray("burnCardDeck", 100)
    AddPersistenceKey("burnCardDeck", "burnCard")
    AddPersistenceArray("pm_burnCardDeck", 100)
    AddPersistenceKey("pm_burnCardDeck", "burnCard")

    AddPersistenceKey("bc.blackMarketTimeUntilBurnCardUpgradeReset", "int")
    AddPersistenceArray("bc.stashedCardRef", 3)
    AddPersistenceKey("bc.stashedCardRef", "burnCard")
    AddPersistenceArray("bc.stashedCardTime", 3)
    AddPersistenceKey("bc.stashedCardTime", "int")
    AddPersistenceArray("bc.burnCardIsNew", 100)
    AddPersistenceKey("bc.burnCardIsNew", "bool")
    AddPersistenceArray("bc.blackMarkedBurnCardUpgrades", 3)
    AddPersistenceKey("bc.blackMarkedBurnCardUpgrades.cardRef", "burnCard")
    AddPersistenceArray("bc.burnCardUpgraded", "burnCard")
    AddPersistenceKey("bc.burnCardUpgraded", "bool")
    AddPersistenceKey("bc.devReset", "int")
    AddPersistenceKey("bc.uiActiveBurnCardIndex", "int")
    AddPersistenceKey("bc.autofill", "bool")

    AddPersistenceKey("pm_bc.blackMarketTimeUntilBurnCardUpgradeReset", "int")
    AddPersistenceArray("pm_bc.stashedCardRef", 3)
    AddPersistenceKey("pm_bc.stashedCardRef", "burnCard")
    AddPersistenceArray("pm_bc.stashedCardTime", 3)
    AddPersistenceKey("pm_bc.stashedCardTime", "int")
    AddPersistenceArray("pm_bc.burnCardIsNew", 100)
    AddPersistenceKey("pm_bc.burnCardIsNew", "bool")
    AddPersistenceArray("pm_bc.blackMarkedBurnCardUpgrades", 3)
    AddPersistenceKey("pm_bc.blackMarkedBurnCardUpgrades.cardRef", "burnCard")
    AddPersistenceArray("pm_bc.burnCardUpgraded", "burnCard")
    AddPersistenceKey("pm_bc.burnCardUpgraded", "bool")
    AddPersistenceKey("pm_bc.devReset", "int")
    AddPersistenceKey("pm_bc.uiActiveBurnCardIndex", "int")
    AddPersistenceKey("pm_bc.autofill", "bool")

    AddPersistenceKey("currentPack", "int")
    AddPersistenceKey("currentPackIndex", "int")

    AddPersistenceArray("nextBurnCard", 3)
    AddPersistenceKey("nextBurnCard", "int")

    AddPersistenceKey("gen", "int")

    AddPersistenceKey("campaignTeam", "int")
    AddPersistenceKey("campaignStarted", "bool")
    AddPersistenceKey("campaignLevelsFinishedIMC", "int")
    AddPersistenceKey("campaignLevelsFinishedMCOR", "int")
    AddPersistenceKey("campaignFinishedIMCjustNow", "int")
    AddPersistenceKey("campaignFinishedMCORjustNow", "int")
    AddPersistenceArray("campaignMapFinishedIMC", 9)
    AddPersistenceKey("campaignMapFinishedIMC", "bool")
    AddPersistenceArray("campaignMapFinishedMCOR", 9)
    AddPersistenceKey("campaignMapFinishedMCOR", "bool")
    AddPersistenceArray("campaignMapWonIMC", 9)
    AddPersistenceKey("campaignMapWonIMC", "bool")
    AddPersistenceArray("campaignMapWonMCOR", 9)
    AddPersistenceKey("campaignMapWonMCOR", "bool")
    AddPersistenceKey("desiredCampaignMapIndex", "int")

    AddPersistenceArray("gameStats.modesPlayed", "gameModes")
    AddPersistenceKey("gameStats.modesPlayed", "int")
    AddPersistenceArray("gameStats.previousModesPlayed", "gameModes")
    AddPersistenceKey("gameStats.previousModesPlayed", "int")
    AddPersistenceArray("gameStats.modesWon", "gameModes")
    AddPersistenceKey("gameStats.modesWon", "int")
    AddPersistenceKey("gameStats.mvp_total", "int")
    AddPersistenceKey("gameStats.gamesCompletedTotal", "int")
    AddPersistenceKey("gameStats.gamesCompletedTotalCampaign", "int")
    AddPersistenceKey("gameStats.gamesWonAsIMC", "int")
    AddPersistenceKey("gameStats.gamesWonAsMilitia", "int")
    AddPersistenceKey("gameStats.gamesCompletedAsIMC", "int")
    AddPersistenceKey("gameStats.gamesCompletedAsMilitia", "int")
    AddPersistenceArray("gameStats.pvpKills", "gameModes")
    AddPersistenceKey("gameStats.pvpKills", "int")
    AddPersistenceArray("gameStats.timesKillDeathRatio2to1", "gameModes")
    AddPersistenceKey("gameStats.timesKillDeathRatio2to1", "int")
    AddPersistenceArray("gameStats.timesKillDeathRatio2to1_pvp", "gameModes")
    AddPersistenceKey("gameStats.timesKillDeathRatio2to1_pvp", "int")
    AddPersistenceKey("gameStats.timesScored100AttritionPoints_total", "int")
    AddPersistenceKey("gameStats.mode_played_at", "int")
    AddPersistenceKey("gameStats.mode_played_ctf", "int")
    AddPersistenceKey("gameStats.mode_played_lts", "int")
    AddPersistenceKey("gameStats.mode_played_cp", "int")
    AddPersistenceKey("gameStats.mode_played_tdm", "int")
    AddPersistenceKey("gameStats.mode_played_wlts", "int")
    AddPersistenceKey("gameStats.mode_played_mfd", "int")
    AddPersistenceKey("gameStats.mode_played_coop", "int")
    AddPersistenceKey("gameStats.mode_won_at", "int")
    AddPersistenceKey("gameStats.mode_won_ctf", "int")
    AddPersistenceKey("gameStats.mode_won_lts", "int")
    AddPersistenceKey("gameStats.mode_won_cp", "int")
    AddPersistenceKey("gameStats.mode_won_tdm", "int")
    AddPersistenceKey("gameStats.mode_won_wlts", "int")
    AddPersistenceKey("gameStats.mode_won_mfd", "int")
    AddPersistenceKey("gameStats.mode_won_coop", "int")
    AddPersistenceKey("gameStats.coop_perfect_waves", "int")

    AddPersistenceArray("mapStats", "maps")
    AddPersistenceArray("mapStats.gamesJoined", "gameModes")
    AddPersistenceKey("mapStats.gamesJoined", "int")
    AddPersistenceArray("mapStats.gamesCompleted", "gameModes")
    AddPersistenceKey("mapStats.gamesCompleted", "int")
    AddPersistenceArray("mapStats.gamesWon", "gameModes")
    AddPersistenceKey("mapStats.gamesWon", "int")
    AddPersistenceArray("mapStats.gamesLost", "gameModes")
    AddPersistenceKey("mapStats.gamesLost", "int")
    AddPersistenceArray("mapStats.topPlayerOnTeam", "gameModes")
    AddPersistenceKey("mapStats.topPlayerOnTeam", "int")
    AddPersistenceArray("mapStats.top3OnTeam", "gameModes")
    AddPersistenceKey("mapStats.top3OnTeam", "int")
    AddPersistenceArray("mapStats.hoursPlayed", "gameModes")
    AddPersistenceKey("mapStats.hoursPlayed", "float")
    AddPersistenceKey("mapStats.timesScored100AttritionPoints_byMap", "int")

    AddPersistanceKey("timeStats.total", "float")
    AddPersistenceArray("timeStats.asTitan", "titanSetFile")
    AddPersistanceKey("timeStats.asTitan", "float")
    AddPersistanceKey("timeStats.asPilot", "float")
    AddPersistanceKey("timeStats.asTitanTotal", "float")
    AddPersistanceKey("timeStats.dead", "float")
    AddPersistanceKey("timeStats.wallhanging", "float")
    AddPersistanceKey("timeStats.wallrunning", "float")
    AddPersistanceKey("timeStats.inAir", "float")

    AddPersistanceKey("distanceStats.total", "float")
    AddPersistenceArray("distanceStats.asTitan", "titanSetFile")
    AddPersistanceKey("distanceStats.asTitan", "float")
    AddPersistanceKey("distanceStats.asPilot", "float")
    AddPersistanceKey("distanceStats.asTitanTotal", "float")
    AddPersistanceKey("distanceStats.wallrunning", "float")
    AddPersistanceKey("distanceStats.inAir", "float")
    AddPersistanceKey("distanceStats.onFriendlyTitan", "float")
    AddPersistanceKey("distanceStats.onEnemyTitan", "float")

    AddPersistenceArray("weaponStats", "loadoutItems")
    AddPersistanceKey("weaponStats.hoursUsed", "float")
    AddPersistanceKey("weaponStats.hoursEquipped", "float")
    AddPersistanceKey("weaponStats.shotsFired", "int")
    AddPersistanceKey("weaponStats.shotsHit", "int")
    AddPersistanceKey("weaponStats.headshots", "int")
    AddPersistanceKey("weaponStats.critHits", "int")

    AddPersistenceArray("weaponKillStats", "loadoutItems")
    AddPersistanceKey("weaponKillStats.total", "int")
    AddPersistanceKey("weaponKillStats.pilots", "int")
    AddPersistanceKey("weaponKillStats.ejecting_pilots", "int")
    AddPersistanceKey("weaponKillStats.spectres", "int")
    AddPersistanceKey("weaponKillStats.marvins", "int")
    AddPersistanceKey("weaponKillStats.grunts", "int")
    AddPersistanceKey("weaponKillStats.titansTotal", "int")
    AddPersistenceArray("weaponKillStats.titans", "titanSetFile")
    AddPersistanceKey("weaponKillStats.titans", "int")
    AddPersistenceArray("weaponKillStats.npcTitans", "titanSetFile")
    AddPersistanceKey("weaponKillStats.npcTitans", "int")

    AddPersistanceKey("killStats.total", "int")
    AddPersistanceKey("killStats.totalWhileUsingBurnCard", "int")
    AddPersistanceKey("killStats.titansWhileTitanBCActive", "int")
    AddPersistanceKey("killStats.totalPVP", "int")
    AddPersistanceKey("killStats.pilots", "int")
    AddPersistanceKey("killStats.spectres", "int")
    AddPersistanceKey("killStats.marvins", "int")
    AddPersistanceKey("killStats.grunts", "int")
    AddPersistanceKey("killStats.totalTitans", "int")
    AddPersistanceKey("killStats.totalTitansWhileDoomed", "int")
    AddPersistanceKey("killStats.totalPilots", "int")
    AddPersistanceKey("killStats.totalNPC", "int")
    AddPersistanceKey("killStats.asPilot", "int")
    AddPersistenceArray("killStats.asTitan", "titanSetFile")
    AddPersistanceKey("killStats.asTitan", "int")
    AddPersistanceKey("killStats.firstStrikes", "int")
    AddPersistanceKey("killStats.ejectingPilots", "int")
    AddPersistanceKey("killStats.whileEjecting", "int")
    AddPersistanceKey("killStats.cloakedPilots", "int")
    AddPersistanceKey("killStats.whileCloaked", "int")
    AddPersistanceKey("killStats.wallrunningPilots", "int")
    AddPersistanceKey("killStats.whileWallrunning", "int")
    AddPersistanceKey("killStats.wallhangingPilots", "int")
    AddPersistanceKey("killStats.whileWallhanging", "int")
    AddPersistanceKey("killStats.pilotExecution", "int")
    AddPersistanceKey("killStats.pilotExecutePilot", "int")
    AddPersistanceKey("killStats.pilotKickMelee", "int")
    AddPersistanceKey("killStats.pilotKickMeleePilot", "int")
    AddPersistanceKey("killStats.titanMelee", "int")
    AddPersistanceKey("killStats.titanMeleePilot", "int")
    AddPersistanceKey("killStats.titanStepCrush", "int")
    AddPersistanceKey("killStats.titanStepCrushPilot", "int")
    AddPersistanceKey("killStats.titanExocutionStryder", "int")
    AddPersistanceKey("killStats.titanExocutionAtlas", "int")
    AddPersistanceKey("killStats.titanExocutionOgre", "int")
    AddPersistanceKey("killStats.titanFallKill", "int")
    AddPersistanceKey("killStats.petTitanKillsFollowMode", "int")
    AddPersistanceKey("killStats.petTitanKillsGuardMode", "int")
    AddPersistanceKey("killStats.rodeo_total", "int")
    AddPersistanceKey("killStats.rodeo_stryder", "int")
    AddPersistanceKey("killStats.rodeo_atlas", "int")
    AddPersistanceKey("killStats.rodeo_ogre", "int")
    AddPersistanceKey("killStats.pilot_headshots_total", "int")
    AddPersistanceKey("killStats.evacShips", "int")
    AddPersistanceKey("killStats.flyers", "int")
    AddPersistanceKey("killStats.nuclearCore", "int")
    AddPersistanceKey("killStats.evacuatingEnemies", "int")
    AddPersistanceKey("killStats.exportTrapKills", "int")
    AddPersistanceKey("killStats.coopChallenge_NukeTitan_Kills", "int")
    AddPersistanceKey("killStats.coopChallenge_MortarTitan_Kills", "int")
    AddPersistanceKey("killStats.coopChallenge_EmpTitan_Kills", "int")
    AddPersistanceKey("killStats.coopChallenge_BubbleShieldGrunt_Kills", "int")
    AddPersistanceKey("killStats.coopChallenge_CloakDrone_Kills", "int")
    AddPersistanceKey("killStats.coopChallenge_Dropship_Kills", "int")
    AddPersistanceKey("killStats.coopChallenge_SuicideSpectre_Kills", "int")
    AddPersistanceKey("killStats.coopChallenge_Turret_Kills", "int")
    AddPersistanceKey("killStats.coopChallenge_Sniper_Kills", "int")
    AddPersistanceKey("killStats.ampedVortexKills", "int")
    AddPersistanceKey("killStats.meleeWhileCloaked", "int")
    AddPersistanceKey("killStats.pilotKillsWhileUsingActiveRadarPulse", "int")
    AddPersistanceKey("killStats.titanKillsAsPilot", "int")
    AddPersistanceKey("killStats.pilotKillsWhileStimActive", "int")
    AddPersistanceKey("killStats.pilotKillsAsTitan", "int")

    AddPersistanceKey("deathStats.total", "int")
    AddPersistanceKey("deathStats.totalPVP", "int")
    AddPersistanceKey("deathStats.asPilot", "int")
    AddPersistenceArray("deathStats.asTitan", "titanSetFile")
    AddPersistanceKey("deathStats.asTitan", "int")
    AddPersistanceKey("deathStats.byPilots", "int")
    AddPersistanceKey("deathStats.bySpectres", "int")
    AddPersistanceKey("deathStats.byGrunts", "int")
    AddPersistenceArray("deathStats.byTitans", "titanSetFile")
    AddPersistanceKey("deathStats.byTitans", "int")
    AddPersistenceArray("deathStats.byNPCTitans", "titanSetFile")
    AddPersistanceKey("deathStats.byNPCTitans", "int")
    AddPersistanceKey("deathStats.suicides", "int")
    AddPersistanceKey("deathStats.whileEjecting", "int")

    AddPersistanceKey("miscStats.titanFalls", "int")
    AddPersistanceKey("miscStats.titanFallsFirst", "int")
    AddPersistanceKey("miscStats.titanEmbarks", "int")
    AddPersistanceKey("miscStats.rodeos", "int")
    AddPersistanceKey("miscStats.rodeosFromEject", "int")
    AddPersistanceKey("miscStats.timesEjected", "int")
    AddPersistanceKey("miscStats.timesEjectedNuclear", "int")
    AddPersistanceKey("miscStats.burnCardsEarned", "int")
    AddPersistanceKey("miscStats.burnCardsSpent", "int")
    AddPersistanceKey("miscStats.spectreLeeches", "int")
    AddPersistenceArray("miscStats.spectreLeechesByMap", "maps")
    AddPersistanceKey("miscStats.spectreLeechesByMap", "int")
    AddPersistanceKey("miscStats.evacsAttempted", "int")
    AddPersistanceKey("miscStats.evacsSurvived", "int")
    AddPersistanceKey("miscStats.flagsCaptured", "int")
    AddPersistanceKey("miscStats.flagsReturned", "int")
    AddPersistanceKey("miscStats.arcCannonMultiKills", "int")
    AddPersistanceKey("miscStats.gruntsConscripted", "int")
    AddPersistanceKey("miscStats.hardpointsCaptured", "int")
    AddPersistanceKey("miscStats.challengeTiersCompleted", "int")
    AddPersistanceKey("miscStats.challengesCompleted", "int")
    AddPersistanceKey("miscStats.dailyChallengesCompleted", "int")
    AddPersistanceKey("miscStats.timesLastTitanRemaining", "int")
    AddPersistanceKey("miscStats.killingSprees", "int")
    AddPersistanceKey("miscStats.coopChallengesCompleted", "int")
    AddPersistanceKey("miscStats.forgedCertificationsUsed", "int")
    AddPersistanceKey("miscStats.regenForgedCertificationsUsed", "int")

    AddPersistanceKey("kdratio_lifetime", "float")
    AddPersistanceKey("kdratio_lifetime_pvp", "float")
    AddPersistenceArray("kdratio_match", 10)
    AddPersistanceKey("kdratio_match", "float")
    AddPersistenceArray("kdratiopvp_match", 10)
    AddPersistanceKey("kdratiopvp_match", "float")

    AddPersistanceKey("winStreak", "int")
    AddPersistanceKey("highestWinStreakEver", "int")
    AddPersistanceKey("winStreakIsDraws", "bool")
    AddPersistenceArray("winLossHistory", 10)
    AddPersistanceKey("winLossHistory", "int")
    AddPersistanceKey("winLossHistorySize", "int")

    AddPersistanceKey("mostProjectilesCollectedInVortex", "int")
    AddPersistanceKey("blackMarketItemsBought", "int")

    AddPersistanceKey("respawnKillInfected", "bool")

    ::eGemState <- {
        gem_undefeated = 0
	    gem_damaged = 1
	    gem_captured = 2
	    gem_lost = 3
    }

    AddPersistenceEnum("eGemState", eGemState)

    ::eMatchValid <- {
     	["true"] = 0,
	    low_player_count = 1,
	    low_time_played = 2,
	    quit_early = 3
    }

    AddPersistenceArray("ranked.gems", 135)
    AddPersistanceKey("ranked.gems.gemScore", "float")
    AddPersistanceKey("ranked.gems.gemState", "eGemState")
    AddPersistanceKey("ranked.previousGemCount", "int")
    AddPersistenceArray("ranked.previousGems", 6)
    AddPersistanceKey("ranked.currentRank", "int")
    AddPersistanceKey("ranked.isPlayingRanked", "bool")
    AddPersistenceArray("ranked.sponsorHash", 15)
    AddPersistanceKey("ranked.sponsorHash", "int")
    AddPersistenceKey("ranked.sponsorName", "string")
    AddPersistenceArray("ranked.historyHash", 120)
    AddPersistanceKey("ranked.historyHash", "int")
    AddPersistenceArray("ranked.historyWon", 120)
    AddPersistanceKey("ranked.historyWon", "bool")
    AddPersistanceKey("ranked.recordedSkill", "float")
    AddPersistanceKey("ranked.matchValid", "eMatchValid")
    AddPersistenceArray("ranked.contributionPoints", 8)
    AddPersistanceKey("ranked.contributionPoints", "int")
    AddPersistanceKey("ranked.lastSponsorshipDate", "int")
    AddPersistanceKey("ranked.sponsorshipsRemaining", "int")
    AddPersistanceKey("ranked.mySponsorXuid", "string")
    AddPersistanceKey("ranked.mySponsorName", "string")
    AddPersistanceKey("ranked.viewRankedPlayIntro", "bool")
    AddPersistanceKey("ranked.joinedRankedPlay", "bool")
    AddPersistanceKey("ranked.debugMM", "bool")
    AddPersistanceKey("ranked.nextGemDecayTime", "int")
    AddPersistanceKey("ranked.nextInviteTime", "int")
    AddPersistanceKey("ranked.currentSeason.season", "int")
    AddPersistanceKey("ranked.currentSeason.seasonStartTime", "int")
    AddPersistanceKey("ranked.currentSeason.seasonEndTime", "int")
    AddPersistanceKey("ranked.currentSeason.rank", "int")
    AddPersistanceKey("ranked.currentSeason.gamesPlayed", "int")
    AddPersistanceKey("ranked.currentSeason.bestRating", "float")
    AddPersistanceKey("ranked.currentSeason.bestRank", "int")
    AddPersistenceArray("ranked.currentSeason.rankGraph", 28)
    AddPersistanceKey("ranked.currentSeason.rankGraph", "int")
    AddPersistenceArray("ranked.seasonHistory", 24)
    AddPersistanceKey("ranked.seasonHistory.season", "int")
    AddPersistanceKey("ranked.seasonHistory.seasonStartTime", "int")
    AddPersistanceKey("ranked.seasonHistory.seasonEndTime", "int")
    AddPersistanceKey("ranked.seasonHistory.rank", "int")
    AddPersistanceKey("ranked.seasonHistory.gamesPlayed", "int")
    AddPersistanceKey("ranked.seasonHistory.bestRating", "float")
    AddPersistanceKey("ranked.seasonHistory.bestRank", "int")
    AddPersistenceArray("ranked.seasonHistory.rankGraph", 28)
    AddPersistanceKey("ranked.seasonHistory.rankGraph", "int")
    AddPersistanceKey("ranked.showSeasonEndDialog", "bool")

    ::challenge <- {
        NULL = 0,
	    // General

	    ch_games_played = 1,
	    ch_games_won = 2,
	    ch_games_mvp = 3,
	    ch_titan_falls = 4,
	    ch_rodeos = 5,
	    ch_times_ejected = 6,
	    ch_spectres_leeched = 7,

	    // Time

	    ch_hours_played = 8,
	    ch_hours_played_pilot = 9,
	    ch_hours_played_titan = 10,
	    ch_hours_wallhang = 11,

	    // Distance

	    ch_dist_total = 12,
	    ch_dist_pilot = 13,
	    ch_dist_titan = 14,
	    ch_dist_wallrun = 15,
	    ch_dist_inair = 16,
	    ch_dist_zipline = 17,
	    ch_dist_on_friendly_titan = 18,
	    ch_dist_on_enemy_titan = 19,

	    // Kills

	    ch_grunt_kills = 20,
	    ch_spectre_kills = 21,
	    ch_marvin_kills = 22,
	    ch_first_strikes = 23,
	    ch_ejecting_pilot_kills = 24,
	    ch_kills_while_ejecting = 25,
	    ch_cloaked_pilot_kills = 26,
	    ch_kills_while_cloaked = 27,
	    ch_wallrunning_pilot_kills = 28,
	    ch_wallhanging_pilot_kills = 29,
	    ch_kills_while_wallrunning = 30,
	    ch_kills_while_wallhanging = 31,
	    ch_pilotExecutePilot = 32,
	    ch_pilotKickMelee = 33,
	    ch_pilotKickMeleePilot = 34,
	    ch_titanMelee = 35,
	    ch_titanMeleePilot = 36,
	    ch_titanStepCrush = 37
	    ch_titanStepCrushPilot = 38
	    ch_titanExocutionStryder = 39
	    ch_titanExocutionAtlas = 40
	    ch_titanExocutionOgre = 41
	    ch_titanFallKill = 42
	    ch_petTitanKillsFollowMode = 43
	    ch_petTitanKillsGuardMode = 44
	    ch_rodeo_kills = 45,

	    // Titan Primary

	    ["ch_40mm_kills"] = 46,
	    ["ch_40mm_pilot_kills"] = 47,
	    ["ch_40mm_titan_kills"] = 48,
	    ["ch_40mm_spectre_kills"] = 49,
	    ["ch_40mm_grunt_kills"] = 50,
	    ["ch_40mm_hours_used"] = 51,
	    ["ch_40mm_crits"] = 52,

	    ["ch_xo16_kills"] = 53,
	    ["ch_xo16_pilot_kills"] = 54,
	    ["ch_xo16_titan_kills"] = 55,
	    ["ch_xo16_spectre_kills"] = 56,
	    ["ch_xo16_grunt_kills"] = 57,
	    ["ch_xo16_hours_used"] = 58,
	    ["ch_xo16_headshots"] = 59,
	    ["ch_xo16_crits"] = 60,

	    ch_titan_sniper_kills = 61,
	    ch_titan_sniper_pilot_kills = 62,
	    ch_titan_sniper_titan_kills = 63,
	    ch_titan_sniper_spectre_kills = 64,
	    ch_titan_sniper_grunt_kills = 65,
	    ch_titan_sniper_hours_used = 66,
	    ch_titan_sniper_crits = 67,

	    ch_arc_cannon_kills = 68,
	    ch_arc_cannon_pilot_kills = 69,
	    ch_arc_cannon_titan_kills = 70,
	    ch_arc_cannon_spectre_kills = 71,
	    ch_arc_cannon_grunt_kills = 72,
	    ch_arc_cannon_hours_used = 73,

	    ch_rocket_launcher_kills = 74,
	    ch_rocket_launcher_pilot_kills = 75,
	    ch_rocket_launcher_titan_kills = 76,
	    ch_rocket_launcher_spectre_kills = 77,
	    ch_rocket_launcher_grunt_kills = 78,
	    ch_rocket_launcher_hours_used = 79,

	    ch_triple_threat_kills = 80,
	    ch_triple_threat_pilot_kills = 81,
	    ch_triple_threat_titan_kills = 82,
	    ch_triple_threat_spectre_kills = 83,
	    ch_triple_threat_grunt_kills = 84,
	    ch_triple_threat_hours_used = 85,

	    // Titan Ordnance

	    ch_salvo_rockets_kills = 86,
	    ch_salvo_rockets_pilot_kills = 87,
	    ch_salvo_rockets_titan_kills = 88,
	    ch_salvo_rockets_spectre_kills = 89,
	    ch_salvo_rockets_grunt_kills = 90,
	    ch_salvo_rockets_hours_used = 91,

	    ch_homing_rockets_titan_kills = 92,
	    ch_homing_rockets_hours_used = 93,

	    ch_dumbfire_rockets_kills = 94,
	    ch_dumbfire_rockets_pilot_kills = 95,
	    ch_dumbfire_rockets_titan_kills = 96,
	    ch_dumbfire_rockets_spectre_kills = 97,
	    ch_dumbfire_rockets_grunt_kills = 98,
	    ch_dumbfire_rockets_hours_used = 99,

	    ch_shoulder_rockets_titan_kills = 100,
	    ch_shoulder_rockets_hours_used = 101,

	    // Pilot Primary

	    ch_smart_pistol_kills = 102,
	    ch_smart_pistol_pilot_kills = 103,
	    ch_smart_pistol_spectre_kills = 104,
	    ch_smart_pistol_grunt_kills = 105,
	    ch_smart_pistol_hours_used = 106,

	    ch_shotgun_kills = 107,
	    ch_shotgun_pilot_kills = 108,
	    ch_shotgun_spectre_kills = 109,
	    ch_shotgun_grunt_kills = 110,
	    ch_shotgun_hours_used = 111,

	    ["ch_r97_kills"] = 112,
	    ["ch_r97_pilot_kills"] = 113,
	    ["ch_r97_spectre_kills"] = 114,
	    ["ch_r97_grunt_kills"] = 115,
	    ["ch_r97_hours_used"] = 116,
	    ["ch_r97_headshots"] = 117,

	    ch_car_kills = 118,
	    ch_car_pilot_kills = 119,
	    ch_car_spectre_kills = 120,
	    ch_car_grunt_kills = 121,
	    ch_car_hours_used = 122,
	    ch_car_headshots = 123,

	    ch_lmg_kills = 124,
	    ch_lmg_pilot_kills = 125,
	    ch_lmg_spectre_kills = 126,
	    ch_lmg_grunt_kills = 127,
	    ch_lmg_hours_used = 128,
	    ch_lmg_headshots = 129,   

	    ["ch_rspn101_kills"] = 130,
	    ["ch_rspn101_pilot_kills"] = 131,
	    ["ch_rspn101_spectre_kills"] = 132,
	    ["ch_rspn101_grunt_kills"] = 133,
	    ["ch_rspn101_hours_used"] = 134,
	    ["ch_rspn101_headshots"] = 135,

	    ch_hemlok_kills = 136,
	    ch_hemlok_pilot_kills = 137,
	    ch_hemlok_spectre_kills = 138,
	    ch_hemlok_grunt_kills = 139,
	    ch_hemlok_hours_used = 140,
	    ch_hemlok_headshots = 141,

	    ["ch_g2_kills"] = 142,
	    ["ch_g2_pilot_kills"] = 143,
	    ["ch_g2_spectre_kills"] = 144,
	    ["ch_g2_grunt_kills"] = 145,
	    ["ch_g2_hours_used"] = 146,
	    ["ch_g2_headshots"] = 147,

	    ch_dmr_kills = 148,
	    ch_dmr_pilot_kills = 149,
	    ch_dmr_spectre_kills = 150,
	    ch_dmr_grunt_kills = 151,
	    ch_dmr_hours_used = 152,   
	    ch_dmr_headshots = 153,

	    ch_sniper_kills = 154,
	    ch_sniper_pilot_kills = 155,
	    ch_sniper_spectre_kills = 156,
	    ch_sniper_grunt_kills = 157,
	    ch_sniper_hours_used = 158,

	    // Pilot Secondary

	    ch_smr_titan_kills = 159,
	    ch_smr_crits = 160,

	    ch_mgl_titan_kills = 161,

	    ch_archer_titan_kills = 162,

	    ch_defender_titan_kills = 163,
	    ch_defender_crits = 164,

	    // Pilot Sidearm

	    ch_autopistol_kills = 165,
	    ch_autopistol_pilot_kills = 166,
	    ch_autopistol_spectre_kills = 167,
	    ch_autopistol_marvin_kills = 168,
	    ch_autopistol_grunt_kills = 169,
	    ch_autopistol_headshots = 170,    

	    ch_semipistol_kills = 171,
	    ch_semipistol_pilot_kills = 172,
	    ch_semipistol_spectre_kills = 173,
	    ch_semipistol_marvin_kills = 174,
	    ch_semipistol_grunt_kills = 175,
	    ch_semipistol_headshots = 176,

	    ch_wingman_kills = 177,
	    ch_wingman_pilot_kills = 178,
	    ch_wingman_spectre_kills = 179,
	    ch_wingman_marvin_kills = 180,
	    ch_wingman_grunt_kills = 181,
	    ch_wingman_headshots = 182,

	    // Pilot Ordnance

	    ch_frag_grenade_throws = 183,
	    ch_frag_grenade_kills = 184,
	    ch_frag_grenade_pilot_kills = 185,
	    ch_frag_grenade_grunt_kills = 186,

	    ch_emp_grenade_throws = 187,
	    ch_emp_grenade_kills = 188,
	    ch_emp_grenade_pilot_kills = 189,
	    ch_emp_grenade_grunt_kills = 190,
	    ch_emp_grenade_spectre_kills = 191,

	    ch_proximity_mine_throws = 192,
	    ch_proximity_mine_kills = 193,
	    ch_proximity_mine_pilot_kills = 194,
	    ch_proximity_mine_grunt_kills = 195,

	    ch_satchel_throws = 196,
	    ch_satchel_kills = 197,
	    ch_satchel_pilot_kills = 198,
	    ch_satchel_grunt_kills = 199,

	    //Fireteam Defense
	    ch_coop_wins = 200,
	    ch_coop_perfect_waves = 201,
	    ch_coop_nuke_titans = 202,
	    ch_coop_suicide_spectres = 203,
	    ch_coop_mortar_titans = 204,
	    ch_coop_turrets = 205,
	    ch_coop_emp_titans = 206,
	    ch_coop_bubble_shield_grunts = 207,
	    ch_coop_cloak_drones = 208,
	    ch_coop_dropships = 209,
	    ch_coop_snipers = 210
    }

    AddPersistenceEnum("challenge", challenge)

    ::dailychallenge <- {
        NULL = 0,
	    // Dailies

	    ch_daily_games_played = 1,
	    ch_daily_games_won = 2,
	    ch_daily_games_mvp = 3,
	    ch_daily_titan_falls = 4,
	    ch_daily_rodeos = 5,
	    ch_daily_times_ejected = 6,
	    ch_daily_spectres_leeched = 7,

	    ch_daily_grunt_kills = 8,
	    ch_daily_marvin_kills = 9,
	    ch_daily_pilot_kills = 10,
	    ch_daily_titan_kills = 11,
	    ch_daily_spectre_kills = 12,
	    ch_daily_rodeo_kills = 13,

	    ch_daily_kills_while_using_burncard = 14,
	    ch_daily_kill_npcs = 15,
	    ch_daily_kills_while_doomed = 16,
	    ch_daily_kills_as_stryder = 17,
	    ch_daily_kills_as_atlas = 18
	    ch_daily_kills_as_ogre = 19,
	    ch_daily_headshots = 20,
	    ch_daily_kills_evac_ships = 21,
	    ch_daily_kills_flyers = 22,
	    ch_daily_kills_nuclear_core = 23,
	    ch_daily_kills_evacuating_enemies = 24,

	    ch_daily_first_strikes = 25,
	    ch_daily_cloaked_pilot_kills = 26,
	    ch_daily_kills_while_cloaked = 27,
	    ch_daily_titanFallKill = 28, 
	    ch_daily_petTitanKillsFollowMode = 29,
	    ch_daily_petTitanKillsGuardMode = 30,

	    ch_daily_ejecting_pilot_kills = 31,
	    ch_daily_kills_while_ejecting = 32,
	    ch_daily_kills_while_wallrunning = 33,
	    ch_daily_kills_while_wallhanging = 34,
	    ch_daily_titanStepCrush = 35,
	    ch_daily_titanStepCrushPilot = 36,

	    ch_daily_pilotExecutePilot = 37,
	    ch_daily_pilotKickMelee = 38,
	    ch_daily_pilotKickMeleePilot = 39,
	    ch_daily_titanMelee = 40,
	    ch_daily_titanMeleePilot = 41,
	    ch_daily_titanExocutionStryder = 42,
	    ch_daily_titanExocutionAtlas = 43,
	    ch_daily_titanExocutionOgre = 44,

	    ["ch_daily_40mm_kills"] = 45,
	    ["ch_daily_40mm_pilot_kills"] = 46,
	    ["ch_daily_40mm_titan_kills"] = 47,
	    ["ch_daily_40mm_grunt_kills"] = 48,
	    ["ch_daily_40mm_crits"] = 49,

	    ["ch_daily_xo16_kills"] = 50,
	    ["ch_daily_xo16_pilot_kills"] = 51,
	    ["ch_daily_xo16_titan_kills"] = 52,
	    ["ch_daily_xo16_grunt_kills"] = 53, 
	    ["ch_daily_xo16_crits"] = 54,

	    ch_daily_titan_sniper_kills = 55,
	    ch_daily_titan_sniper_pilot_kills = 56,
	    ch_daily_titan_sniper_titan_kills = 57,
	    ch_daily_titan_sniper_grunt_kills = 58,
	    ch_daily_titan_sniper_crits = 59,

	    ch_daily_arc_cannon_kills = 60,
	    ch_daily_arc_cannon_pilot_kills = 61,
	    ch_daily_arc_cannon_titan_kills = 62,
	    ch_daily_arc_cannon_grunt_kills = 63,
	    ch_daily_arc_cannon_multi_kills = 64,

	    ch_daily_rocket_launcher_kills = 65,
	    ch_daily_rocket_launcher_pilot_kills = 66,
	    ch_daily_rocket_launcher_titan_kills = 67,
	    ch_daily_rocket_launcher_grunt_kills = 68,

	    ch_daily_triple_threat_kills = 69,
	    ch_daily_triple_threat_pilot_kills = 70,
	    ch_daily_triple_threat_titan_kills = 71,
	    ch_daily_triple_threat_grunt_kills = 72,

	    ch_daily_salvo_rockets_kills = 73,
	    ch_daily_salvo_rockets_pilot_kills = 74,
	    ch_daily_salvo_rockets_titan_kills = 75,
	    ch_daily_salvo_rockets_grunt_kills = 76,

	    ch_daily_homing_rockets_titan_kills = 77,

	    ch_daily_dumbfire_rockets_kills = 78,
	    ch_daily_dumbfire_rockets_pilot_kills = 79,
	    ch_daily_dumbfire_rockets_titan_kills = 80,
	    ch_daily_dumbfire_rockets_grunt_kills = 81,

	    ch_daily_shoulder_rockets_titan_kills = 82,

	    ch_daily_smart_pistol_kills = 83,
	    ch_daily_smart_pistol_pilot_kills = 84,
	    ch_daily_smart_pistol_spectre_kills = 85,
	    ch_daily_smart_pistol_grunt_kills = 86,

	    ch_daily_shotgun_kills = 87,
	    ch_daily_shotgun_pilot_kills = 88,
	    ch_daily_shotgun_spectre_kills = 89,
	    ch_daily_shotgun_grunt_kills = 90,

	    ["ch_daily_r97_kills"] = 91,
	    ["ch_daily_r97_pilot_kills"] = 92,
	    ["ch_daily_r97_spectre_kills"] = 93,
	    ["ch_daily_r97_grunt_kills"] = 94,
	    ["ch_daily_r97_headshots"] = 95,

	    ch_daily_car_kills = 96,
	    ch_daily_car_pilot_kills = 97,
	    ch_daily_car_spectre_kills = 98,
	    ch_daily_car_grunt_kills = 99,
	    ch_daily_car_headshots = 100,

	    ch_daily_lmg_kills = 101,
	    ch_daily_lmg_pilot_kills = 102,
	    ch_daily_lmg_spectre_kills = 103,
	    ch_daily_lmg_grunt_kills = 104,
	    ch_daily_lmg_headshots = 105,

	    ["ch_daily_rspn101_kills"] = 106,
	    ["ch_daily_rspn101_pilot_kills"] = 107,
	    ["ch_daily_rspn101_spectre_kills"] = 108,
	    ["ch_daily_rspn101_grunt_kills"] = 109,
	    ["ch_daily_rspn101_headshots"] = 110,

	    ch_daily_hemlok_kills = 111, 
	    ch_daily_hemlok_pilot_kills = 112,
	    ch_daily_hemlok_spectre_kills = 113,
	    ch_daily_hemlok_grunt_kills = 114,
	    ch_daily_hemlok_headshots = 115,

	    ["ch_daily_g2_kills"] = 116,
	    ["ch_daily_g2_pilot_kills"] = 117,
	    ["ch_daily_g2_spectre_kills"] = 118,
	    ["ch_daily_g2_grunt_kills"] = 119,
	    ["ch_daily_g2_headshots"] = 120,

	    ch_daily_dmr_kills = 121,
	    ch_daily_dmr_pilot_kills = 122,
	    ch_daily_dmr_spectre_kills = 123,
	    ch_daily_dmr_grunt_kills = 124,
	    ch_daily_dmr_headshots = 125,

	    ch_daily_sniper_kills = 126,
	    ch_daily_sniper_pilot_kills = 127,
	    ch_daily_sniper_spectre_kills = 128,
	    ch_daily_sniper_grunt_kills = 129,

	    ch_daily_smr_titan_kills = 130,
	    ch_daily_smr_crits = 131,
	    ch_daily_mgl_titan_kills = 132,
	    ch_daily_archer_titan_kills = 133,
	    ch_daily_defender_titan_kills = 134,
	    ch_daily_defender_crits = 135,

	    ch_daily_autopistol_kills = 136,
	    ch_daily_autopistol_pilot_kills = 137,
	    ch_daily_autopistol_spectre_kills = 138,
	    ch_daily_autopistol_grunt_kills = 139,
	    ch_daily_autopistol_headshots = 140,

	    ch_daily_semipistol_kills = 141,
	    ch_daily_semipistol_pilot_kills = 142,
	    ch_daily_semipistol_spectre_kills = 143,
	    ch_daily_semipistol_grunt_kills = 144,
	    ch_daily_semipistol_headshots = 145,

	    ch_daily_wingman_kills = 146,
	    ch_daily_wingman_pilot_kills = 147,
	    ch_daily_wingman_spectre_kills = 148,
	    ch_daily_wingman_grunt_kills = 149,
	    ch_daily_wingman_headshots = 150,

	    ch_daily_frag_grenade_kills = 151, 
	    ch_daily_frag_grenade_pilot_kills = 152,
	    ch_daily_frag_grenade_grunt_kills = 153,

	    ch_daily_emp_grenade_kills = 154,
	    ch_daily_emp_grenade_pilot_kills = 155,
	    ch_daily_emp_grenade_grunt_kills = 156,
	    ch_daily_emp_grenade_spectre_kills = 157,

	    ch_daily_proximity_mine_kills = 158,
	    ch_daily_proximity_mine_pilot_kills = 159,
	    ch_daily_proximity_mine_grunt_kills = 160,

	    ch_daily_satchel_kills = 161,
	    ch_daily_satchel_pilot_kills = 162,
	    ch_daily_satchel_grunt_kills = 163,

	    ch_daily_burncards_used = 164,
	    ch_daily_flag_captures = 165,
	    ch_daily_evacs_survived = 166,
	    ch_daily_hardpoints_captured = 167,
	    ch_daily_killing_sprees = 168,

	    ch_daily_play_at = 169,
	    ch_daily_play_ctf = 170,
	    ch_daily_play_lts = 171,
	    ch_daily_play_cp = 172,
	    ch_daily_play_tdm = 173,
	    ch_daily_play_wlts = 174,
	    ch_daily_play_mfd = 175,
	    ch_daily_play_coop = 176,

	    ch_daily_win_at = 177,
	    ch_daily_win_ctf = 178,
	    ch_daily_win_lts = 179,
	    ch_daily_win_cp = 180,
	    ch_daily_win_tdm = 181,
	    ch_daily_win_wlts = 182,
	    ch_daily_win_mfd = 183,
	    ch_daily_win_coop = 184,
    }

    AddPersistenceEnum("dailychallenge", dailychallenge)

    AddPersistanceArray("challenges", "challenge")
    AddPersistanceKey("challenges.progress", "float")
    AddPersistanceKey("challenges.previousProgress", "float")
    AddPersistanceArray("dailychallenges", "dailychallenge")
    AddPersistanceKey("dailychallenges.progress", "float")
    AddPersistanceKey("dailychallenges.previousProgress", "float")

    AddPersistanceArray("activeDailyChallenges", 9)
    AddPersistanceKey("activeDailyChallenges.ref", "dailychallenge")
    AddPersistanceKey("activeDailyChallenges.day", "int")

    AddPersistanceArray("trackedChallenges", 3)
    AddPersistanceKey("trackedChallenges", "int")
    AddPersistanceArray("EOGTrackedChallenges", 3)
    AddPersistanceKey("EOGTrackedChallenges", "int")
    AddPersistanceArray("trackedChallengeRefs", 3)
    AddPersistanceKey("trackedChallengeRefs", "string")
    AddPersistanceArray("EOGTrackedChallengeRefs", 3)
    AddPersistanceKey("EOGTrackedChallengeRefs", "string")
    AddPersistanceKey("newRegenChallenges", "bool")
    AddPersistanceKey("dailyChallengeDayIndex", "int")
    AddPersistanceKey("newDailyChallenges", "bool")

    AddPersistanceKey("ach_campaignWonAllLevelsIMC", "int")
    AddPersistanceKey("ach_campaignWonAllLevelsMCOR", "int")
    AddPersistanceKey("ach_createPilotLoadout", "bool")
    AddPersistanceKey("ach_createTitanLoadout", "bool")
    AddPersistanceKey("ach_allModesAllMaps", "bool")
    AddPersistanceKey("ach_multikillArcRifle", "bool")
    AddPersistanceKey("ach_completedTraining", "bool")
    AddPersistanceKey("ach_unlockEverything", "bool")
    AddPersistanceKey("ach_allChallengesForSingleWeapon", "bool")
    AddPersistanceKey("ach_vortexVolley", "bool")
    AddPersistanceKey("ach_killedAllEvacPlayersSolo", "bool")
    AddPersistanceKey("ach_reachedMaxLevel", "bool")

    AddPersistanceKey("ach_swamplandWon", "bool")
    AddPersistenceKey("ach_swamplandAllModes", "int")
    AddPersistanceKey("ach_swamplandDontTouchGround", "bool")
    AddPersistanceKey("ach_swamplandAirborne", "float")
    AddPersistanceKey("ach_runoffWon", "bool")
    AddPersistenceKey("ach_runoffAllModes", "int")
    AddPersistanceKey("ach_runoffEnemiesKilledWallrunning", "int")
    AddPersistanceKey("ach_runoffEnemiesKilled", "int")
    AddPersistanceKey("ach_wargamesWon", "bool")
    AddPersistenceKey("ach_wargamesAllModes", "int")
    AddPersistanceKey("ach_wargamesPilotKillsSingleMatch", "int")
    AddPersistanceKey("ach_wargamesPilotsKilled", "int")

    AddPersistanceKey("dlc2achievement.ach_havenWon", "bool")
    AddPersistenceKey("dlc2achievement.ach_havenAllModes", "int")
    AddPersistanceKey("dlc2achievement.ach_havenTitansExecuted", "bool")
    AddPersistanceKey("dlc2achievement.ach_havenTitansKilledWhileBCActive", "int")
    AddPersistanceKey("dlc2achievement.ach_exportWon", "bool")
    AddPersistenceKey("dlc2achievement.ach_exportAllModes", "int")
    AddPersistanceKey("dlc2achievement.ach_exportTrapKill", "bool")
    AddPersistanceKey("dlc2achievement.ach_exportKillsWhileCloaked", "int")
    AddPersistanceKey("dlc2achievement.ach_digsiteWon", "bool")
    AddPersistenceKey("dlc2achievement.ach_digsiteAllModes", "int")
    AddPersistanceKey("dlc2achievement.ach_digsitePilotKillsSingleMatch", "bool")
    AddPersistanceKey("dlc2achievement.ach_digsitePilotKills", "int")

    AddPersistanceKey("dlc3achievement.ach_backwaterWon", "bool")
    AddPersistenceKey("dlc3achievement.ach_backwaterAllModes", "int")
    AddPersistanceKey("dlc3achievement.ach_backwaterAmpedVortexKills", "int")
    AddPersistanceKey("dlc3achievement.ach_backwaterMeleeCloakKills", "int")
    AddPersistenceKey("dlc3achievement.ach_sandtrapWon", "bool")
    AddPersistenceKey("dlc3achievement.ach_sandtrapAllModes", "int")
    AddPersistanceKey("dlc3achievement.ach_sandtrapActiveRadarKills", "int")
    AddPersistanceKey("dlc3achievement.ach_sandtrap2TitanKillsAsPilot", "bool")
    AddPersistenceKey("dlc3achievement.ach_zone18Won", "bool")
    AddPersistenceKey("dlc3achievement.ach_zone18AllModes", "int")
    AddPersistanceKey("dlc3achievement.ach_zone18StimPilotKills", "int")
    AddPersistanceKey("dlc3achievement.ach_zone18PilotKillsAsTitan", "bool")

    AddPersistenceKey("cu8achievement.ach_blackMarketCreditsEarned", "int")
    AddPersistenceKey("cu8achievement.ach_burncardsDiscarded", "int")
    AddPersistenceKey("cu8achievement.ach_titanVoicePacksUnlocked", "int")
    AddPersistenceKey("cu8achievement.ach_allDailyChallengesForDay", "bool")
    AddPersistenceKey("cu8achievement.ach_twoStarCoopMaps", "int")
    AddPersistenceKey("cu8achievement.ach_renamedCustomLoadout", "bool")
    AddPersistenceKey("cu8achievement.ach_titanInsigniasUnlocked", "int")
    AddPersistenceKey("cu8achievement.ach_titanBurnCardsUsed", "int")
    AddPersistenceKey("cu8achievement.ach_threeStarsAwarded", "bool")
    AddPersistanceKey("cu8achievement.ach_totalStarsEarned", "int")
    AddPersistenceKey("cu8achievement.ach_rankedGamesPlayed", "int")
    AddPersistenceKey("cu8achievement.ach_battlemarksEarned", "int")
    AddPersistenceKey("cu8achievement.ach_reachedGen10NoForgedCert", "bool")

    ::trainingModules <- {
	    JUMP = 0,
	    WALLRUN = 1,
	    WALLRUN_PLAYGROUND = 2,
	    DOUBLEJUMP = 3,
	    DOUBLEJUMP_PLAYGROUND = 4,
	    CLOAK = 5,
	    BASIC_COMBAT = 6,
	    FIRINGRANGE = 7,
	    FIRINGRANGE_GRENADES = 8,
	    MOSH_PIT = 9,
	    TITAN_DASH = 10,
	    TITAN_VORTEX = 11,
	    TITAN_PET = 12,
	    TITAN_MOSH_PIT = 13,
	    BEDROOM_END = 14,
    }

    AddPersistenceEnum("trainingModules", trainingModules)

    AddPersistanceArray("trainingModulesCompleted", "trainingModules")
    AddPersistanceKey("trainingModulesCompleted", "bool")

    AddPersistanceKey("savedScoreboardData.gameMode", "int")
    AddPersistanceKey("savedScoreboardData.map", "int")
    AddPersistanceKey("savedScoreboardData.playerTeam", "int")
    AddPersistanceKey("savedScoreboardData.playerIndex", "int")
    AddPersistanceKey("savedScoreboardData.maxTeamPlayers", "int")
    AddPersistanceKey("savedScoreboardData.numPlayersIMC", "int")
    AddPersistanceKey("savedScoreboardData.numPlayersMCOR", "int")
    AddPersistanceKey("savedScoreboardData.scoreIMC", "int")
    AddPersistanceKey("savedScoreboardData.scoreMCOR", "int")
    AddPersistanceKey("savedScoreboardData.privateMatch", "bool")
    AddPersistanceKey("savedScoreboardData.campaign", "bool")
    AddPersistanceKey("savedScoreboardData.ranked", "bool")
    AddPersistanceKey("savedScoreboardData.hadMatchLossProtection", "bool")
    AddPersistenceArray("savedScoreboardData.playersIMC", 8)
    AddPersistanceKey("savedScoreboardData.playersIMC.name", "string")
    AddPersistanceKey("savedScoreboardData.playersIMC.xuid", "string")
    AddPersistanceKey("savedScoreboardData.playersIMC.level", "int")
    AddPersistanceKey("savedScoreboardData.playersIMC.gen", "int")
    AddPersistanceKey("savedScoreboardData.playersIMC.score_assault", "int")
    AddPersistanceKey("savedScoreboardData.playersIMC.score_defense", "int")
    AddPersistanceKey("savedScoreboardData.playersIMC.score_kills", "int")
    AddPersistanceKey("savedScoreboardData.playersIMC.score_deaths", "int")
    AddPersistanceKey("savedScoreboardData.playersIMC.score_titanKills", "int")
    AddPersistanceKey("savedScoreboardData.playersIMC.score_npcKills", "int")
    AddPersistanceKey("savedScoreboardData.playersIMC.score_assists", "int")
    AddPersistanceKey("savedScoreboardData.playersIMC.playingRanked", "bool")
    AddPersistanceKey("savedScoreboardData.playersIMC.rank", "int")
    AddPersistanceKey("savedScoreboardData.playersIMC.matchPerformance", "float")
    AddPersistenceArray("savedScoreboardData.playersMCOR", 8)
    AddPersistanceKey("savedScoreboardData.playersMCOR.name", "string")
    AddPersistanceKey("savedScoreboardData.playersMCOR.xuid", "string")
    AddPersistanceKey("savedScoreboardData.playersMCOR.level", "int")
    AddPersistanceKey("savedScoreboardData.playersMCOR.gen", "int")
    AddPersistanceKey("savedScoreboardData.playersMCOR.score_assault", "int")
    AddPersistanceKey("savedScoreboardData.playersMCOR.score_defense", "int")
    AddPersistanceKey("savedScoreboardData.playersMCOR.score_kills", "int")
    AddPersistanceKey("savedScoreboardData.playersMCOR.score_deaths", "int")
    AddPersistanceKey("savedScoreboardData.playersMCOR.score_titanKills", "int")
    AddPersistanceKey("savedScoreboardData.playersMCOR.score_npcKills", "int")
    AddPersistanceKey("savedScoreboardData.playersMCOR.score_assists", "int")
    AddPersistanceKey("savedScoreboardData.playersMCOR.playingRanked", "bool")
    AddPersistanceKey("savedScoreboardData.playersMCOR.rank", "int")
    AddPersistanceKey("savedScoreboardData.playersMCOR.matchPerformance", "float")

    AddPersistanceKey("previousGooserProgress", "int")

    AddPersistenceKey("savedCoopData.completedWaves", "int")
    AddPersistenceKey("savedCoopData.totalWaves", "int")
    AddPersistenceKey("savedCoopData.harvesterHealth", "int")
    AddPersistenceKey("savedCoopData.retriesUsed", "int")
    AddPersistenceKey("savedCoopData.gameDuration", "int")
    AddPersistenceKey("savedCoopData.starsEarned", "int")
    AddPersistenceKey("savedCoopData.teamScore.enemiesKilled", "int")
    AddPersistenceKey("savedCoopData.teamScore.maxEnemiesKilled", "int")
    AddPersistenceKey("savedCoopData.teamScore.harvesterHealth", "int")
    AddPersistenceKey("savedCoopData.teamScore.maxHarvesterHealth", "int")
    AddPersistenceKey("savedCoopData.teamScore.wavesCompletedBonus", "int")
    AddPersistenceKey("savedCoopData.teamScore.maxWavesCompletedBonus", "int")
    AddPersistenceKey("savedCoopData.teamScore.finalWaveCompletedBonus", "int")
    AddPersistenceKey("savedCoopData.teamScore.maxFinalWaveCompletedBonus", "int")
    AddPersistenceKey("savedCoopData.teamScore.flawlessWaveBonus", "int")
    AddPersistenceKey("savedCoopData.teamScore.maxFlawlessWaveBonus", "int")
    AddPersistenceKey("savedCoopData.teamScore.retriesBonus", "int")
    AddPersistenceKey("savedCoopData.teamScore.maxRetriesBonus", "int")
    AddPersistenceKey("savedCoopData.teamScore.teamScore", "int")
    AddPersistanceArray("savedCoopData.militiaKillCounts", 9)
    AddPersistanceKey("savedCoopData.militiaKillCounts.killCount", "int")
    AddPersistanceKey("savedCoopData.militiaKillCounts.turretKillCount", "int")
    AddPersistanceArray("savedCoopData.players", 4)
    AddPersistanceKey("savedCoopData.players.name", "string")
    AddPersistanceKey("savedCoopData.players.xuid", "string")
    AddPersistanceKey("savedCoopData.players.entityIndex", "int")
    AddPersistanceArray("savedCoopData.players.enemyType", 9)
    AddPersistanceKey("savedCoopData.players.enemyType.killCount", "int")
    AddPersistanceKey("savedCoopData.players.enemyType.turretKillCount", "int")

    AddPersistanceArray("mapHistory", 24)
    AddPersistanceKey("mapHistory", "int")
    AddPersistanceArray("modeHistory", 10)
    AddPersistanceKey("modeHistory", "int")

    ::BlackMarketUnlocks <- {
        ["titan_decals_blackmarket01"] = 0,
	    ["titan_decals_blackmarket02"] = 1, 
	    ["titan_decals_blackmarket03"] = 2,
	    ["titan_decals_blackmarket04"] = 3,
	    ["titan_decals_blackmarket05"] = 4,
	    ["titan_decals_blackmarket06"] = 5,
	    ["titan_decals_blackmarket07"] = 6,
	    ["titan_decals_blackmarket08"] = 7,
	    titanos_femaleassistant = 8,
	    titanos_maleintimidator = 9,
	    titanos_bettyde = 10,
	    titanos_bettyen = 11,
	    titanos_bettyes = 12,
	    titanos_bettyfr = 13,
	    titanos_bettyit = 14,
	    titanos_bettyjp = 15,
	    titanos_bettyru = 16,
    }

    AddPersistenceEnum("BlackMarketUnlocks", BlackMarketUnlocks)

    ::blackMarketPerishableTypes <- {
        NULL = 0,
	    perishable_burncard = 1,
    }

    AddPersistenceEnum("blackMarketPerishableTypes", blackMarketPerishableTypes)

    AddPersistenceKey("bm.coinCount", "int")
    AddPersistenceKey("bm.previousCoinCount", "int")
    AddPersistanceArray("bm.coin_rewards", 6)
    AddPersistanceKey("bm.coin_rewards", "int")
    AddPersistanceArray("bm.coin_reward_counts", 6)
    AddPersistanceKey("bm.coin_reward_counts", "int")
    AddPersistanceKey("bm.newBlackMarketItems", "bool")
    AddPersistanceKey("bm.nextDiceCardDate", "int")
    AddPersistanceArray("bm.blackMarketItemUnlocks", "BlackMarketUnlocks")
    AddPersistanceKey("bm.blackMarketItemUnlocks", "bool")
    AddPersistanceArray("bm.blackMarketPerishables", 9)
    AddPersistanceKey("bm.blackMarketPerishables.nextRestockDate", "int")
    AddPersistanceKey("bm.blackMarketPerishables.perishableType", "blackMarketPerishableTypes")
    AddPersistanceKey("bm.blackMarketPerishables.cardRef", "burnCard")
    AddPersistanceKey("bm.blackMarketPerishables.coinCost", "int")
    AddPersistanceKey("bm.blackMarketPerishables.new", "bool")
    AddPersistanceKey("bm.challengeSkips", "int")

    AddPersistanceKey("lastDailyMatchVictory", "int")
    AddPersistanceKey("lastTimePlayed", "int")
    AddPersistanceKey("lastTimeLoggedIn", "int")

    AddPersistanceArray("mapStars", "maps")
    AddPersistenceArray("mapStars.bestScore", "gameModesWithStars")
    AddPersistanceKey("mapStars.bestScore", "int")
    AddPersistenceArray("mapStars.previousBestScore", "gameModesWithStars")
    AddPersistanceKey("mapStars.previousBestScore", "int")

    AddPersistanceKey("playlistAnnouncementSeen", "bool")
}

if( IsServer() )
{
    
function PersistenceGetEnumCount( val )
{
	//printt("PersistenceGetEnumCount: " + val )
	return 0
}

function PersistenceGetArrayCount( val )
{
	//printt("PersistenceGetArrayCount: " + val )
	return 0
}

function PersistenceEnumValueIsValid( val, index )
{
	//printt("PersistenceEnumValueIsValid: " + val + " " + index )
	return false
}

}

// Helper function to pack values with type information
function PackValue(value, type) {
    local typeCode
    switch(type) {
        case "integer": typeCode = "i"; break
        case "float": typeCode = "f"; break
        case "bool": typeCode = "b"; break
        case "string": typeCode = "s"; break
        default: typeCode = "x"; break // Invalid type
    }
    if (typeCode != "x") {
        if (type == "bool") {
            return typeCode + (value ? "1" : "0")
        } else {
            return typeCode + value.tostring()
        }
    }
    return "x"
}

// Helper function to unpack values and verify their type
function UnpackValue(packedValue) {
    if (packedValue.len() < 2) return null
    local typeCode = packedValue[0].tochar()
    local value = packedValue.slice(1)
    
    if ("i" == typeCode) {
        return value.tointeger()
    } else if ("f" == typeCode) {
        return value.tofloat()
    } else if ("b" == typeCode) {
        return value == "1"
    } else if ("s" == typeCode) {
        return value
    } else {
        return null
    }
}

// Helper function to validate keys against the schema (unchanged)
function IsValidKey(key) {
/*
    local schema = GetPDEFSchema()
    local parts = split(key = ".")
    local current = schema
    
    foreach (part in parts) {
        if (part in current) {
            current = current[part]
        } else {
            return false
        }
    }
    */
    return true
}
