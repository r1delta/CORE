
const ION_MODEL = "models/titans/medium/titan_medium_ajax.mdl"

function main()
{

	local offhand_override = {}
	offhand_override.replaces_tactical <- false
	offhand_override.specific_weapon_id <- null

	CreateTitan( offhand_override )
}

function CreateTitan( offhand_override_data )
{

	local core_start = StartPiercerCore
	local core_end = EndPiercerCore

	printl( "Ion Created" )

	MasterTitanCreation( 
		"titan_ion", 
		"special_atlas", 
		"titan_atlas", 
		50, 
		"Ion", 
		"An energy based titan with dual tactical systems.", 
		"../ui/menu/loadouts/titan_chassis_atlas_imc", 
		"../ui/menu/loadouts/titan_chassis_atlas_mcor", 
		"Core Ability: Piercer Core", 
		"Deploys a variant of the Charge Cannon built to charge to a higher capacity.", 
		"../ui/menu/items/mod_icons/instant_shot", 
		85, 
		90, 
		76, 
		2, 
		"", 
		ION_MODEL, 
		STRYDER_HATCH_PANEL, 
		53, 
		"../ui/menu/items/mod_icons/instant_shot", 
		offhand_override_data,
		"Piercer Cannon Online",
		"Route reserve power into ordnance system.",
		core_start,
		core_end
		)
}

function EndPiercerCore( soul )
{
	local titan = soul.GetTitan()

	TakePlayerWeapons( soul, "ordnance" )
	
	thread ReplaceTitanWeapon( titan, ordnance_before_replace, o_mods, "ordnance" )
}

function StartPiercerCore( soul )//decided they should have their shields with it since Ion is energy based.
{
	local titan = soul.GetTitan()
	RegisterPreviousWeapons( titan )
	TakePlayerWeapons( soul, "ordnance" )
	thread ReplaceTitanWeapon( titan, "mp_weapon_mega4", ["piercer_core"], "ordnance" )
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