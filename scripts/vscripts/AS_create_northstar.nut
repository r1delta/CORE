
const NORTHSTAR_MODEL = "models/titans/light/titan_light_raptor.mdl"

function main()
{
	local offhand_override = {}
	offhand_override.replaces_tactical <- true
	offhand_override.tactical_weapon_id <- "mp_weapon_mega5"
	offhand_override.replaces_ordnance <- false
	offhand_override.ordnance_weapon_id <- ""
	offhand_override.replaces_primary <- false
	offhand_override.primary_weapon_id <- ""

	CreateTitan( offhand_override )
}

function CreateTitan( offhand_override_data )
{

	local core_start = StartFlightCore
	local core_end = EndFlightCore

	printl( "Northstar Created" )

	MasterTitanCreation( 
		"titan_northstar", 
		"special_stryder", 
		"titan_stryder", 
		50, 
		"Northstar", 
		"Ultra-Light Stryder with a focus on air-ground engagement.", 
		"../ui/menu/loadouts/titan_chassis_stryder_imc", 
		"../ui/menu/loadouts/titan_chassis_stryder_mcor", 
		"Core Ability: Flight Core", 
		"Allows stratospheric flight with lock-on and dumbfire rockets.", 
		"../ui/menu/items/mod_icons/starburst", 
		100, 
		100, 
		25, 
		4, 
		"", 
		NORTHSTAR_MODEL, 
		STRYDER_HATCH_PANEL, 
		53, 
		"../ui/menu/items/mod_icons/starburst", 
		offhand_override_data,
		"Flight Core Online",
		"Flight navigation systems calibrated",
		core_start,
		core_end
		)
}

function EndFlightCore( soul )
{
	is_hovering <- false
	local titan = soul.GetTitan()
	
	TakePlayerWeapons( soul, "ordnance" )
	TakePlayerWeapons( soul, "special" )

	thread ReplaceTitanWeapon( titan, ordnance_before_replace, o_mods, "ordnance" )
	thread ReplaceTitanWeapon( titan, special_before_replace, s_mods, "special" )
}

function StartFlightCore( soul )
{
	local titan = soul.GetTitan()
	RegisterPreviousWeapons( titan )
	is_hovering <- true
	thread HoverTitanWizardry( titan, soul, 650 )// hmmm might be able to replace with titan

	local player_ordnance = "mp_titanweapon_salvo_rockets"
	local player_tactical = "mp_titanweapon_shoulder_rockets"
	
	TakePlayerWeapons( soul, "ordnance" )
	TakePlayerWeapons( soul, "special" )

	thread ReplaceTitanWeapon( titan, player_ordnance, [ "mod_ordnance_core", "burn_mod_titan_salvo_rockets" ], "ordnance" )
	thread ReplaceTitanWeapon( titan, player_tactical, [ "mod_ordnance_core", "burn_mod_titan_shoulder_rockets" ], "special" )
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
	offhand override # for replacing either tactical ( true ) or ordnance ( false )
*/