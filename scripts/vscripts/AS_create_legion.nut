
const LEGION_MODEL = "models/titans/heavy/titan_heavy_deadbolt.mdl"

function main()
{
	local offhand_override = {}
	offhand_override.replaces_tactical <- false
	offhand_override.tactical_weapon_id <- ""
	offhand_override.replaces_ordnance <- false
	offhand_override.ordnance_weapon_id <- ""
	offhand_override.replaces_primary <- true
	offhand_override.primary_weapon_id <- "mp_weapon_mega6"

	CreateTitan( offhand_override )
}

function CreateTitan( offhand_override_data )
{
	local core_start = StartBulletStormCore
	local core_end = EndBulletStormCore
	
	printl( "Legion Created" )

	MasterTitanCreation( 
		"titan_legion", 
		"special_ogre", 
		"titan_ogre", 
		50, 
		"Legion", 
		"Ultra-Heavy Titan equipped with the Predator Cannon Gatling Gun.", 
		"../ui/menu/loadouts/titan_chassis_ogre_imc", 
		"../ui/menu/loadouts/titan_chassis_ogre_mcor", 
		"Core Ability: Bullet Storm", 
		"Dramatically boosts Predator Cannon fire-rate and ammo capacity for a short time.", 
		"../ui/menu/items/mod_icons/scatterfire", 
		10, 
		20, 
		100, 
		1, 
		"chest_focus", 
		LEGION_MODEL, 
		STRYDER_HATCH_PANEL, 
		53, 
		"../ui/menu/items/mod_icons/scatterfire", 
		offhand_override_data,
		"Bullet Storm Online",
		"Predator Cannon Overrides unlocked",
		core_start,
		core_end
		)
}

function EndBulletStormCore( soul )
{
	local titan = soul.GetTitan()
	TakePlayerWeapons( soul, "primary" )

	thread ReplaceTitanWeapon( titan, primary_before_replace, p_mods, "primary" )
}

function StartBulletStormCore( soul )//do i use minigun....do i use XO16? do i use... idk
{
	local titan = soul.GetTitan()
	RegisterPreviousWeapons( titan )
	TakePlayerWeapons( soul, "primary" )

	thread ReplaceTitanWeapon( titan, "mp_weapon_mega6", ["bullet_storm"], "primary" )
}

main()

// LOOK HERE FOR WHAT THESE ARE

/*
	setfile, 
	type, 
	emb_ove, # embark override. REQUIRED
	unl_lv, 
	p_name, # ui only
	p_desc, # ui only
	t_img_imc, # ui only
	t_img_mcor, # ui only
	c_name, # ui only
	c_desc, # ui only
	c_img, # ui only
	stat_speed, # ui only
	stat_acceleration, # ui only
	stat_health amount, # ui only
	stat_boost count, # ui only
	rodeo reference override, # can leave as just "" for default

	titan model, # titan model
	hatch model, # rodeo hatch
	rodeo hitbox number, # the weakpoint for when rodeoing. ttf2 titans dont have it by default ;-;
	co_op img, # frontier defense player img

	core name # core name on hud when it is ready, always capitalized anyways
	core hint # splash text when core is ready, always capatalized anyways
	custom core s # when core starts
	custom core e # when core ends
*/