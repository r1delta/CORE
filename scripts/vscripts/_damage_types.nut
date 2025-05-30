enum eDamageSourceId
{
	titan_step 	= -4  // used in code
	despawn 	= -3 // used in code
	suicide 	= -2 // used in code
	invalid 	= -1  // used in code
	unknown
	unknownBugIt

	// Titan Weapons
	mp_titanweapon_40mm
	mp_titanweapon_arc_cannon
	mp_titanweapon_chaff
	mp_titanweapon_rocket_launcher
	mp_titanweapon_shotgun
	mp_titanweapon_shoulder_rockets
	mp_titanweapon_orbital_strike
	mp_titanweapon_shoulder_turret
	mp_titanweapon_mortar
	mp_titanweapon_homing_rockets
	mp_titanweapon_dumbfire_rockets
	mp_titanweapon_salvo_rockets
	mp_titanweapon_missile_guard
	mp_titanweapon_sniper
	mp_titanweapon_triple_threat
	mp_titanweapon_vortex_shield
	mp_titanweapon_xo16
	mp_titanweapon_target_designator
	mp_titanweapon_orbital_laser
	mp_titanability_healthdrop
	mp_titanability_smoke
	mp_titanability_cloak
	mp_ability_cloak
	mp_ability_emp
	mp_ability_heal
	mp_ability_sonar
	mp_weapon_orbital_laser
	mp_weapon_orbital_strike
	mp_titanability_fusion_core		// Stryder Signature Active
	mp_titanability_emp				// Atlas Signature Active
	mp_titanability_bubble_shield

	// Pilot Weapons
	mp_weapon_hemlok
	mp_weapon_lmg
	mp_weapon_pss
	weapon_rspn101	// added back to fix SRE. Somewhere is using this weapon but shouldn't. Maybe legacy SP level that was loaded?
	mp_weapon_rspn101
	mp_weapon_g2
	mp_weapon_smart_pistol
	mp_weapon_r97
	mp_weapon_car
	mp_weapon_dmr
	mp_weapon_wingman
	mp_weapon_semipistol
	mp_weapon_autopistol
	mp_weapon_gibber
	mp_weapon_mgl
	mp_weapon_sniper
	mp_weapon_shotgun
	mp_weapon_frag_grenade
	mp_weapon_grenade_repeating
	mp_weapon_grenade_emp
	mp_weapon_satchel
	mp_weapon_nuke_satchel
	mp_weapon_proximity_mine
	mp_weapon_mega17
	mp_weapon_laser_mine
	mp_weapon_grenade_multi
	mp_weapon_suck
	mp_weapon_smr
	mp_weapon_rocket_launcher
	mp_weapon_defender
	mp_extreme_environment

	// Turret Weapons
	mp_weapon_yh803
	mp_weapon_turret_rockets
	mp_weapon_yh803_bullet
	mp_weapon_mega_turret
	mp_weapon_mega_turret_aa
	mp_weapon_target_designator
	mp_turretweapon_rockets


	// Supers
	super_electric_smoke_screen   //TODO: After ship, Get rid of this, it is now deprecated by mp_titanability_smoke
	super_orbital_strike
	super_bomb_run

	// Misc
	rodeo
	rodeo_forced_titan_eject //For awarding points when you force a pilot to eject via rodeo
	nuclear_core
	titan_melee
	human_melee
	mind_crime
	grunt_melee
	spectre_melee
	titan_execution
	human_execution
	wall_smash
	ai_turret
	team_switch
	rocket
	titan_hotdrop
	titan_explosion
	operator_drone_crash
	flash_surge
	molotov
	sticky_time_bomb
	vortex_grenade
	droppod_impact
	operator_satellite_strike
	ai_turret_explosion
	rodeo_caber
	rodeo_trap
	round_end
	bubble_shield
	titan_fall
	evac_dropship_explosion

	// Environmental
	fall
	splat
	crushed
	burn
	outOfBounds
	indoor_inferno
	submerged
	switchback_trap
	floor_is_lava
	suicideSpectre
	suicideSpectreAoE
	titanEmpField
	stuck

	// development
	weapon_cubemap

	//damageSourceId=eDamageSourceId.xxxxx
	//fireteam
	//marvin
	//rocketstrike
	//orbitallaser
	//explosion
}

damageSourceIdToString <- {}
local table = getconsttable().eDamageSourceId
foreach( key, val in table )
{
	damageSourceIdToString[val] <- key
}

damageSourceStrings <- {}

damageSourceStrings[ eDamageSourceId.despawn ] 							<- "DESPAWN"
damageSourceStrings[ eDamageSourceId.suicide ] 							<- "#DEATH_SUICIDE"

damageSourceStrings[ eDamageSourceId.mp_titanweapon_40mm ] 				<- "#WPN_TITAN_40MM"
damageSourceStrings[ eDamageSourceId.mp_titanweapon_arc_cannon ] 		<- "#WPN_TITAN_ARC_CANNON"
damageSourceStrings[ eDamageSourceId.mp_titanweapon_chaff ] 			<- "#WPN_TITAN_CHAFF"
damageSourceStrings[ eDamageSourceId.mp_titanweapon_rocket_launcher ] 	<- "#WPN_TITAN_ROCKET_LAUNCHER"
damageSourceStrings[ eDamageSourceId.mp_titanweapon_shotgun ] 			<- "#WPN_TITAN_SHOTGUN"
damageSourceStrings[ eDamageSourceId.mp_titanweapon_shoulder_rockets ] 	<- "#WPN_TITAN_SHOULDER_ROCKETS"
damageSourceStrings[ eDamageSourceId.mp_titanweapon_mortar ]			<- "#WPN_TITAN_MORTAR"
damageSourceStrings[ eDamageSourceId.mp_titanweapon_homing_rockets ]	<- "#WPN_TITAN_HOMING_ROCKETS"
damageSourceStrings[ eDamageSourceId.mp_titanweapon_dumbfire_rockets ]	<- "#WPN_TITAN_DUMB_SHOULDER_ROCKETS"
damageSourceStrings[ eDamageSourceId.mp_titanweapon_salvo_rockets ]		<- "#WPN_TITAN_SALVO_ROCKETS"
damageSourceStrings[ eDamageSourceId.mp_titanweapon_orbital_strike ]	<- "Orbital Strike"
damageSourceStrings[ eDamageSourceId.mp_titanweapon_shoulder_turret ]	<- "Shoulder Turret"
damageSourceStrings[ eDamageSourceId.mp_titanweapon_sniper ] 			<- "#WPN_TITAN_SNIPER"
damageSourceStrings[ eDamageSourceId.mp_titanweapon_triple_threat ] 	<- "#WPN_TITAN_TRIPLE_THREAT"
damageSourceStrings[ eDamageSourceId.mp_titanweapon_vortex_shield ] 	<- "#WPN_TITAN_VORTEX_SHIELD"
damageSourceStrings[ eDamageSourceId.mp_titanweapon_xo16 ] 				<- "#WPN_TITAN_XO16"
damageSourceStrings[ eDamageSourceId.mp_titanweapon_target_designator ] <- "#WPN_TARGET_DESIGNATOR"
damageSourceStrings[ eDamageSourceId.mp_titanweapon_missile_guard ]		<- "#WPN_TITAN_MISSILE_GUARD"
damageSourceStrings[ eDamageSourceId.mp_titanability_fusion_core ] 		<- ""
damageSourceStrings[ eDamageSourceId.mp_titanability_bubble_shield ] 	<- ""
damageSourceStrings[ eDamageSourceId.mp_weapon_hemlok ] 				<- "#WPN_HEMLOK"
damageSourceStrings[ eDamageSourceId.mp_weapon_lmg ] 					<- "#WPN_LMG"
damageSourceStrings[ eDamageSourceId.mp_weapon_pss ] 					<- "#WPN_PSS"
damageSourceStrings[ eDamageSourceId.mp_weapon_rspn101 ] 				<- "#WPN_RSPN101"
damageSourceStrings[ eDamageSourceId.mp_weapon_g2 ] 					<- "#WPN_G2"
damageSourceStrings[ eDamageSourceId.weapon_rspn101 ] 					<- "#WPN_RSPN101"
damageSourceStrings[ eDamageSourceId.mp_weapon_smart_pistol ] 			<- "#WPN_SMART_PISTOL"
damageSourceStrings[ eDamageSourceId.mp_weapon_r97 ] 					<- "#WPN_R97"
damageSourceStrings[ eDamageSourceId.mp_weapon_car ] 					<- "#WPN_CAR"
damageSourceStrings[ eDamageSourceId.mp_weapon_dmr ] 					<- "#WPN_DMR"
damageSourceStrings[ eDamageSourceId.mp_weapon_wingman ] 				<- "#WPN_WINGMAN"
damageSourceStrings[ eDamageSourceId.mp_weapon_semipistol ] 			<- "#WPN_P2011"
damageSourceStrings[ eDamageSourceId.mp_weapon_autopistol ] 			<- "#WPN_RE45_AUTOPISTOL"
damageSourceStrings[ eDamageSourceId.mp_weapon_gibber ] 				<- "#WPN_GIBBER"
damageSourceStrings[ eDamageSourceId.mp_weapon_mgl ] 					<- "#WPN_MGL"
damageSourceStrings[ eDamageSourceId.mp_weapon_sniper			 ] 		<- "#WPN_SNIPER"
damageSourceStrings[ eDamageSourceId.mp_weapon_shotgun ] 				<- "#WPN_SHOTGUN"
damageSourceStrings[ eDamageSourceId.mp_weapon_frag_grenade ] 			<- "#WPN_FRAG_GRENADE"
damageSourceStrings[ eDamageSourceId.mp_weapon_grenade_repeating ] 		<- "#WPN_REPEATING_GRENADE"
damageSourceStrings[ eDamageSourceId.mp_weapon_grenade_emp ] 			<- "#WPN_GRENADE_EMP"
damageSourceStrings[ eDamageSourceId.mp_weapon_satchel ] 				<- "#WPN_SATCHEL"
damageSourceStrings[ eDamageSourceId.mp_weapon_nuke_satchel ] 			<- "#WPN_SATCHEL"
damageSourceStrings[ eDamageSourceId.mp_weapon_proximity_mine ]			<- "#WPN_PROXIMITY_MINE"
damageSourceStrings[ eDamageSourceId.mp_weapon_mega17 ] 				<- "#DEATH_RODEO_CABER"

damageSourceStrings[ eDamageSourceId.mp_extreme_environment ] 			<- "#DAMAGE_EXTREME_ENVIRONMENT"
damageSourceStrings[ eDamageSourceId.mp_titanability_healthdrop ] 		<- "Titan Health Drop"
damageSourceStrings[ eDamageSourceId.mp_titanability_smoke ] 			<- "#DAMAGE_ELECTRIC_SMOKE"
damageSourceStrings[ eDamageSourceId.mp_titanability_cloak ] 			<- "Titan Orbital Strike"
damageSourceStrings[ eDamageSourceId.mp_ability_cloak ] 				<- "Cloak"
damageSourceStrings[ eDamageSourceId.mp_ability_emp ] 					<- "EMP"
damageSourceStrings[ eDamageSourceId.mp_ability_sonar ] 				<- "Active Sonar Pulse"
damageSourceStrings[ eDamageSourceId.mp_ability_heal ] 					<- "Health"


damageSourceStrings[ eDamageSourceId.mp_weapon_laser_mine ]				<- "#WPN_LASER_MINE"
damageSourceStrings[ eDamageSourceId.mp_weapon_grenade_multi ] 			<- "#WPN_GRENADE_MULTI"
damageSourceStrings[ eDamageSourceId.mp_weapon_suck ] 					<- "#WPN_SUCK"
damageSourceStrings[ eDamageSourceId.mp_weapon_smr ] 					<- "#WPN_SMR"
damageSourceStrings[ eDamageSourceId.mp_weapon_defender ] 				<- "#WPN_CHARGE_RIFLE"
damageSourceStrings[ eDamageSourceId.mp_weapon_rocket_launcher ] 		<- "#WPN_ROCKET_LAUNCHER"
damageSourceStrings[ eDamageSourceId.mp_weapon_yh803 ] 					<- "#WPN_LIGHT_TURRET"
damageSourceStrings[ eDamageSourceId.mp_weapon_yh803_bullet ]			<- "#WPN_LIGHT_TURRET"
damageSourceStrings[ eDamageSourceId.mp_weapon_mega_turret ]			<- "#WPN_MEGA_TURRET"
damageSourceStrings[ eDamageSourceId.mp_weapon_mega_turret_aa ]			<- "#WPN_MEGA_TURRET"
damageSourceStrings[ eDamageSourceId.mp_turretweapon_rockets ]			<- "#WPN_TURRET_ROCKETS"
damageSourceStrings[ eDamageSourceId.mp_weapon_target_designator ] 		<- "#WPN_TARGET_DESIGNATOR"

damageSourceStrings[ eDamageSourceId.super_electric_smoke_screen ] 		<- "#DEATH_ELECTRIC_SMOKE_SCREEN"
damageSourceStrings[ eDamageSourceId.super_orbital_strike ] 			<- "#DEATH_ORBITAL_STRIKE"
damageSourceStrings[ eDamageSourceId.mp_weapon_orbital_strike ]			<- "#DEATH_ORBITAL_STRIKE"
damageSourceStrings[ eDamageSourceId.mp_titanweapon_orbital_laser ]		<- "#DEATH_ORBITAL_LASER"
damageSourceStrings[ eDamageSourceId.mp_weapon_orbital_laser ]			<- "#DEATH_ORBITAL_LASER"
damageSourceStrings[ eDamageSourceId.super_bomb_run ] 					<- "#DEATH_BOMB_RUN"
damageSourceStrings[ eDamageSourceId.rodeo ] 							<- "#DEATH_TITAN_RODEO"
damageSourceStrings[ eDamageSourceId.rodeo_forced_titan_eject ] 		<- "#DEATH_TITAN_RODEO"
damageSourceStrings[ eDamageSourceId.nuclear_core ] 					<- "#DEATH_NUCLEAR_CORE"
damageSourceStrings[ eDamageSourceId.titan_melee ] 						<- "#DEATH_TITAN_MELEE"
damageSourceStrings[ eDamageSourceId.human_melee ] 						<- "#DEATH_HUMAN_MELEE"
damageSourceStrings[ eDamageSourceId.grunt_melee ] 						<- "#DEATH_GRUNT_MELEE"
damageSourceStrings[ eDamageSourceId.spectre_melee ] 					<- "#DEATH_SPECTRE_MELEE"
damageSourceStrings[ eDamageSourceId.wall_smash ] 						<- "#DEATH_WALL_SMASH"
damageSourceStrings[ eDamageSourceId.ai_turret ] 						<- "#DEATH_TURRET"
damageSourceStrings[ eDamageSourceId.team_switch ] 						<- "#DEATH_TEAM_CHANGE"
damageSourceStrings[ eDamageSourceId.rocket ] 							<- "#DEATH_ROCKET"
damageSourceStrings[ eDamageSourceId.titan_hotdrop ] 					<- "#DEATH_TITAN_HOT_DROP"
damageSourceStrings[ eDamageSourceId.titan_explosion ] 					<- "#DEATH_TITAN_EXPLOSION"
damageSourceStrings[ eDamageSourceId.titan_step ] 						<- "#DEATH_STEPPED_ON"
damageSourceStrings[ eDamageSourceId.operator_drone_crash ] 			<- "#DEATH_DRONE_EXPLOSION"
damageSourceStrings[ eDamageSourceId.evac_dropship_explosion ] 			<- "#DEATH_EVAC_DROPSHIP_EXPLOSION"
damageSourceStrings[ eDamageSourceId.flash_surge ] 						<- "#DEATH_FLASH_SURGE"
damageSourceStrings[ eDamageSourceId.molotov ] 							<- "#DEATH_MOLOTOV"
damageSourceStrings[ eDamageSourceId.sticky_time_bomb ] 				<- "#DEATH_STICKY_TIME_BOMB"
damageSourceStrings[ eDamageSourceId.vortex_grenade ] 					<- "#DEATH_VORTEX_GRENADE"
damageSourceStrings[ eDamageSourceId.droppod_impact ] 					<- "#DEATH_DROPPOD_CRUSH"
damageSourceStrings[ eDamageSourceId.operator_satellite_strike ] 		<- "#DEATH_SATELLITE_STRIKE"
damageSourceStrings[ eDamageSourceId.ai_turret_explosion ] 				<- "#DEATH_TURRET_EXPLOSION"
damageSourceStrings[ eDamageSourceId.rodeo_caber ] 						<- "#DEATH_RODEO_CABER"
damageSourceStrings[ eDamageSourceId.rodeo_trap 		] 				<- "#DEATH_RODEO_TRAP"
damageSourceStrings[ eDamageSourceId.round_end ] 						<- "#DEATH_ROUND_END"
damageSourceStrings[ eDamageSourceId.burn ]	 							<- "#DEATH_BURN"
damageSourceStrings[ eDamageSourceId.mind_crime ]						<- "Mind Crime"

damageSourceStrings[ eDamageSourceId.bubble_shield ] 					<- "#DEATH_BUBBLE_SHIELD"
damageSourceStrings[ eDamageSourceId.titan_fall ] 						<- "#DEATH_TITAN_FALL"


// Instant death. Show no percentages on death recap.
damageSourceStrings[ eDamageSourceId.fall ]		 						<- "#DEATH_FALL"
 //Todo: Rename eDamageSourceId.splat with a more appropriate name. This damage type was used for enviornmental damage, but it was for eject killing pilots if they were near a ceiling. I've changed the localized string to "Enviornment Damage", but this will cause confusion in the future.
damageSourceStrings[ eDamageSourceId.splat ] 							<- "#DEATH_SPLAT"
damageSourceStrings[ eDamageSourceId.crushed ]							<- "#DEATH_CRUSHED"
damageSourceStrings[ eDamageSourceId.titan_execution ] 					<- "#DEATH_TITAN_EXECUTION"
damageSourceStrings[ eDamageSourceId.human_execution ] 					<- "#DEATH_HUMAN_EXECUTION"
damageSourceStrings[ eDamageSourceId.outOfBounds ] 						<- "#DEATH_OUT_OF_BOUNDS"
damageSourceStrings[ eDamageSourceId.indoor_inferno ]	 				<- "#DEATH_INDOOR_INFERNO"
damageSourceStrings[ eDamageSourceId.submerged ]						<- "#DEATH_SUBMERGED"
damageSourceStrings[ eDamageSourceId.switchback_trap ]					<- "#DEATH_ELECTROCUTION" // Damages teammates and opposing team
damageSourceStrings[ eDamageSourceId.floor_is_lava ]					<- "#DEATH_ELECTROCUTION"
damageSourceStrings[ eDamageSourceId.suicideSpectre ]					<- "#DEATH_SUICIDE_SPECTRE" // Damages teammates and opposing team
damageSourceStrings[ eDamageSourceId.suicideSpectreAoE ]				<- "#DEATH_SUICIDE_SPECTRE" // Used for distinguishing the initial spectre from allies.
damageSourceStrings[ eDamageSourceId.titanEmpField ] 					<- "#DEATH_TITAN_EMP_FIELD"


//damageSourceStrings[ eDamageSourceId.mp_weapon_turret_rockets ] 					<- "Rocket Turret" // temp mega usage

//development, with retail versions incase a rare bug happens we dont want to show developer text
if ( developer() > 0 )
{
	damageSourceStrings[ eDamageSourceId.unknownBugIt ] 				<- "UNKNOWN! BUG IT!"
	damageSourceStrings[ eDamageSourceId.unknown ] 						<- "Unknown"
	damageSourceStrings[ eDamageSourceId.weapon_cubemap ] 				<- "Cubemap"
	damageSourceStrings[ eDamageSourceId.invalid ] 						<- "INVALID (BUG IT!)"
	damageSourceStrings[ eDamageSourceId.stuck ]		 				<- "NPC got Stuck (Don't Bug it!)"
}
else
{
	damageSourceStrings[ eDamageSourceId.unknownBugIt ] 				<- "#DEATH_GENERIC_KILLED"
	damageSourceStrings[ eDamageSourceId.unknown ] 						<- "#DEATH_GENERIC_KILLED"
	damageSourceStrings[ eDamageSourceId.weapon_cubemap ] 				<- "#DEATH_GENERIC_KILLED"
	damageSourceStrings[ eDamageSourceId.invalid ] 						<- "#DEATH_GENERIC_KILLED"
	damageSourceStrings[ eDamageSourceId.stuck ]		 				<- "#DEATH_GENERIC_KILLED"
}



//When adding new mods, they need to be added below and to persistent_player_data_version_N.pdef in r1/cfg/server.
//Then when updating that file, save a new one and increment N.

enum eModSourceId
{
	accelerator
	afterburners
	arc_triple_threat
	aog
	burn_mod_autopistol
	burn_mod_car
	burn_mod_defender
	burn_mod_dmr
	burn_mod_emp_grenade
	burn_mod_frag_grenade
	burn_mod_g2
	burn_mod_hemlok
	burn_mod_lmg
	burn_mod_mgl
	burn_mod_proximity_mine
	burn_mod_r97
	burn_mod_rspn101
	burn_mod_satchel
	burn_mod_semipistol
    burn_mod_smart_pistol
	burn_mod_smr
	burn_mod_sniper
	burn_mod_rocket_launcher
	burn_mod_titan_40mm
	burn_mod_titan_arc_cannon
	burn_mod_titan_rocket_launcher
	burn_mod_titan_sniper
	burn_mod_titan_triple_threat
	burn_mod_titan_xo16
	burn_mod_titan_dumbfire_rockets
	burn_mod_titan_homing_rockets
	burn_mod_titan_salvo_rockets
	burn_mod_titan_shoulder_rockets
	burn_mod_titan_vortex_shield
	burn_mod_titan_smoke
	burn_mod_titan_bubble_shield
	burst
	capacitor
	enhanced_targeting
	extended_ammo
	fast_lock
	fast_reload
	guided_missile
	hcog
	holosight
	instant_shot
	integrated_gyro
	iron_sights
	match_trigger
	mine_field
	overcharge
	quick_shot
	rapid_fire_missiles
	recoil_compensator
	scope_4x
	scope_6x
	scope_8x
	scope_10x
	scope_12x
	burn_mod_shotgun
	silencer
	slammer
	spread_increase_sg
	spread_increase_ttt
	stabilizer
	starburst
	titanhammer
	burn_mod_wingman
}

//Attachments intentionally left off. This prevents them from displaying in kill cards.
// modNameStrings should be defined when the mods are created, not in a separate table -Mackey
modNameStrings <- {}
modNameStrings[ eModSourceId.accelerator ]					<- "#MOD_ACCELERATOR_NAME"
modNameStrings[ eModSourceId.afterburners ]					<- "#MOD_AFTERBURNERS_NAME"
modNameStrings[ eModSourceId.arc_triple_threat ] 			<- "#MOD_ARC_TRIPLE_THREAT_NAME"
modNameStrings[ eModSourceId.burn_mod_autopistol ] 			<- "#BC_AUTOPISTOL_M2"
modNameStrings[ eModSourceId.burn_mod_car ] 				<- "#BC_CAR_M2"
modNameStrings[ eModSourceId.burn_mod_defender ] 			<- "#BC_DEFENDER_M2"
modNameStrings[ eModSourceId.burn_mod_dmr ] 				<- "#BC_DMR_M2"
modNameStrings[ eModSourceId.burn_mod_emp_grenade ] 		<- "#BC_EMP_GRENADE_M2"
modNameStrings[ eModSourceId.burn_mod_frag_grenade ] 		<- "#BC_FRAG_GRENADE_M2"
modNameStrings[ eModSourceId.burn_mod_g2 ] 					<- "#BC_G2_M2"
modNameStrings[ eModSourceId.burn_mod_hemlok ] 				<- "#BC_HEMLOK_M2"
modNameStrings[ eModSourceId.burn_mod_lmg ] 				<- "#BC_LMG_M2"
modNameStrings[ eModSourceId.burn_mod_mgl ] 				<- "#BC_MGL_M2"
modNameStrings[ eModSourceId.burn_mod_proximity_mine ] 		<- "#BC_PROXIMITY_MINE_M2"
modNameStrings[ eModSourceId.burn_mod_r97 ] 				<- "#BC_R97_M2"
modNameStrings[ eModSourceId.burn_mod_rspn101 ] 			<- "#BC_RSPN101_M2"
modNameStrings[ eModSourceId.burn_mod_satchel ] 			<- "#BC_SATCHEL_M2"
modNameStrings[ eModSourceId.burn_mod_semipistol ] 			<- "#BC_SEMIPISTOL_M2"
modNameStrings[ eModSourceId.burn_mod_smr ] 				<- "#BC_SMR_M2"
modNameStrings[ eModSourceId.burn_mod_smart_pistol ] 		<- "#BC_SMART_PISTOL_M2"
modNameStrings[ eModSourceId.burn_mod_sniper ] 				<- "#BC_SNIPER_M2"
modNameStrings[ eModSourceId.burn_mod_rocket_launcher ] 	<- "#BC_ROCKET_LAUNCHER_M2"
modNameStrings[ eModSourceId.burn_mod_titan_40mm ] 				<- "#BC_TITAN_40MM_M2"
modNameStrings[ eModSourceId.burn_mod_titan_arc_cannon ] 		<- "#BC_TITAN_ARC_CANNON_M2"
modNameStrings[ eModSourceId.burn_mod_titan_rocket_launcher ] 	<- "#BC_TITAN_ROCKET_LAUNCHER_M2"
modNameStrings[ eModSourceId.burn_mod_titan_sniper ] 			<- "#BC_TITAN_SNIPER_M2"
modNameStrings[ eModSourceId.burn_mod_titan_triple_threat ] 	<- "#BC_TITAN_TRIPLE_THREAT_M2"
modNameStrings[ eModSourceId.burn_mod_titan_xo16 ]			 	<- "#BC_TITAN_XO16_M2"
modNameStrings[ eModSourceId.burn_mod_titan_dumbfire_rockets ] 	<- "#BC_TITAN_DUMBFIRE_MISSILE_M2"
modNameStrings[ eModSourceId.burn_mod_titan_homing_rockets ] 	<- "#BC_TITAN_HOMING_ROCKETS_M2"
modNameStrings[ eModSourceId.burn_mod_titan_salvo_rockets ] 	<- "#BC_TITAN_SALVO_ROCKETS_M2"
modNameStrings[ eModSourceId.burn_mod_titan_shoulder_rockets ] 	<- "#BC_TITAN_SHOULDER_ROCKETS_M2"
modNameStrings[ eModSourceId.burn_mod_titan_vortex_shield ] 	<- "#BC_TITAN_VORTEX_SHIELD_M2"
modNameStrings[ eModSourceId.burn_mod_titan_smoke ] 			<- "#BC_TITAN_ELECTRIC_SMOKE_M2"
modNameStrings[ eModSourceId.burn_mod_titan_bubble_shield ] 	<- "#BC_TITAN_SHIELD_WALL_M2"
modNameStrings[ eModSourceId.burst ] 						<- "#MOD_BURST_NAME"
modNameStrings[ eModSourceId.capacitor ] 					<- "#MOD_CAPACITOR_NAME"
modNameStrings[ eModSourceId.enhanced_targeting ] 			<- "#MOD_ENHANCED_TARGETING_NAME"
modNameStrings[ eModSourceId.extended_ammo ] 				<- "#MOD_EXTENDED_MAG_NAME"
modNameStrings[ eModSourceId.fast_reload ] 					<- "#MOD_FAST_RELOAD_NAME"
modNameStrings[ eModSourceId.instant_shot ]					<- "#MOD_INSTANT_SHOT_NAME"
modNameStrings[ eModSourceId.integrated_gyro ] 				<- "#MOD_INTEGRATED_GYRO_NAME"
modNameStrings[ eModSourceId.match_trigger ] 				<- "#MOD_MATCH_TRIGGER_NAME"
modNameStrings[ eModSourceId.mine_field ] 					<- "#MOD_MINE_FIELD_NAME"
modNameStrings[	eModSourceId.overcharge ] 					<- "#MOD_OVERCHARGE_NAME"
modNameStrings[ eModSourceId.quick_shot ]					<- "#MOD_QUICK_SHOT_NAME"
modNameStrings[ eModSourceId.rapid_fire_missiles ] 			<- "#MOD_RAPID_FIRE_MISSILES_NAME"
modNameStrings[ eModSourceId.recoil_compensator ]			<- "#MOD_RECOIL_COMPENSATOR_NAME"
modNameStrings[ eModSourceId.burn_mod_shotgun ] 	<- "#BC_SHOTGUN_M2"
modNameStrings[	eModSourceId.silencer ] 					<- "#MOD_SILENCER_NAME"
modNameStrings[ eModSourceId.slammer ] 						<- "#MOD_SLAMMER_NAME"
modNameStrings[ eModSourceId.spread_increase_sg ]			<- "#MOD_SPREAD_INCREASE_SG_NAME"
modNameStrings[ eModSourceId.spread_increase_ttt ]			<- "#MOD_SPREAD_INCREASE_TTT_NAME"
modNameStrings[ eModSourceId.stabilizer ]					<- "#MOD_STABILIZER_NAME"
modNameStrings[ eModSourceId.starburst ] 					<- "#MOD_STARBURST_NAME"
modNameStrings[ eModSourceId.titanhammer ] 					<- "#MOD_TITANHAMMER_NAME"
modNameStrings[ eModSourceId.burn_mod_wingman ] 	<- "#BC_WINGMAN_M2"
