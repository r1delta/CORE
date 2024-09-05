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
