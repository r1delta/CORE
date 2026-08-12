
const RONIN_MODEL = "models/titans/light/titan_light_locust.mdl"

function main()
{
	CreateTitan( null )
}

function CreateTitan( offhand_override_data )
{

	local core_start = StartAutoBurstCore
	local core_end = EndAutoBurstCore

	printl( "Ronin Created" )

	MasterTitanCreation( 
		"titan_ronin", 
		"special_stryder", 
		"titan_stryder", 
		50, 
		"Ronin", 
		"Ultra-Light Stryder with a focus on close range engagement.", 
		"../ui/menu/loadouts/titan_chassis_stryder_imc", 
		"../ui/menu/loadouts/titan_chassis_stryder_mcor", 
		"Core Ability: Ripper Shotgun", 
		"Deploys an automatic variant of the WYS404 Shotgun with sprint-and-fire bracing.", 
		"../ui/menu/items/passive_icons/run_and_gun", 
		100, 
		100, 
		25, 
		4, 
		"", 
		RONIN_MODEL, 
		STRYDER_HATCH_PANEL, 
		53, 
		"../ui/menu/items/passive_icons/run_and_gun", 
		offhand_override_data,
		"Ripper Shotgun Ready",
		"Fast Firing WYS404 tuned and loaded",
		core_start,
		core_end
		)
}

function EndAutoBurstCore( soul )
{
	local titan = soul.GetTitan()
	TakePlayerWeapons( soul, "primary" )
	thread ReplaceTitanWeapon( titan, primary_before_replace, p_mods, "primary" )
}

function StartAutoBurstCore( soul )//do i use minigun....do i use XO16? do i use... idk
{
	local titan = soul.GetTitan()
	RegisterPreviousWeapons( titan )
	TakePlayerWeapons( soul, "primary" )
	thread ReplaceTitanWeapon( titan, "mp_titanweapon_shotgun", ["auto_burst"], "primary" )
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