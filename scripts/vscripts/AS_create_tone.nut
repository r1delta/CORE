
const TONE_MODEL = "models/titans/medium/titan_medium_wraith.mdl"

function main()
{

	//local offhand_override = {}
	//offhand_override.replaces_tactical <- false
	//offhand_override.specific_weapon_id <- null

	CreateTitan( null )
}

function CreateTitan( offhand_override_data )
{

	local core_start = StartBulwarkCore
	local core_end = EndBulwarkCore

	printl( "Tone Created" )

	MasterTitanCreation( 
		"titan_tone", 
		"special_atlas", 
		"titan_atlas", 
		50, 
		"Tone", 
		"A heavier Atlas successor with more armor but slightly slower dash regeneration.", 
		"../ui/menu/loadouts/titan_chassis_atlas_imc", 
		"../ui/menu/loadouts/titan_chassis_atlas_mcor", 
		"Core Ability: Bulwark", 
		"Enables triple Particle Wall creation.", 
		"../ui/menu/items/ability_icons/bubble_shield", 
		85, 
		90, 
		76, 
		2, 
		"", 
		TONE_MODEL, 
		STRYDER_HATCH_PANEL, 
		53, 
		"../ui/menu/items/ability_icons/bubble_shield", 
		offhand_override_data,
		"Bulwark Online",
		"Defensive Super Capacitors Charged.",
		core_start,
		core_end
		)
}

function EndBulwarkCore( soul )
{
	local titan = soul.GetTitan()

	TakePlayerWeapons( soul, "special" )
	
	thread ReplaceTitanWeapon( titan, special_before_replace, s_mods, "special" )
}

function StartBulwarkCore( soul )//decided they should have their shields with it since Ion is energy based.
{
	local titan = soul.GetTitan()
	RegisterPreviousWeapons( titan )
	TakePlayerWeapons( soul, "special" )
	thread ReplaceTitanWeapon( titan, "mp_titanability_bubble_shield", ["bulwark"], "special" )
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