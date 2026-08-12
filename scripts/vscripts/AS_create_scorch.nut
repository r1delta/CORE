
const SCORCH_MODEL = "models/titans/heavy/titan_heavy_ogre.mdl"

function main()
{

	local offhand_override = {}
	offhand_override.replaces_tactical <- true
	offhand_override.specific_weapon_id <- null

	CreateTitan( offhand_override )
}

function CreateTitan( offhand_override_data )
{

	local core_start = StartMissileCore
	local core_end = EndMissileCore

	printl( "Scorch Created" )

	MasterTitanCreation( 
		"titan_scorch", 
		"special_ogre", 
		"titan_ogre", 
		50, 
		"Scorch", 
		"Ultra-Heavy Titan with dual ordnance systems.", 
		"../ui/menu/loadouts/titan_chassis_ogre_imc", 
		"../ui/menu/loadouts/titan_chassis_ogre_mcor", 
		"Core Ability: Ordnance Core", 
		"Overclocks ordnance systems to enable rapid fire missiles.", 
		"../ui/menu/items/mod_icons/rapid_fire_missiles", 
		10, 
		20, 
		100, 
		1, 
		"chest_focus", 
		SCORCH_MODEL, 
		STRYDER_HATCH_PANEL, 
		53, 
		"../ui/menu/items/mod_icons/rapid_fire_missiles", 
		offhand_override_data,
		"Ordnance Core Online",
		"Route reserve power into ordnance system.",
		core_start,
		core_end
		)
}

function EndMissileCore( soul )
{
	local titan = soul.GetTitan()

	TakePlayerWeapons( soul, "ordnance" )
	TakePlayerWeapons( soul, "special" )

	thread ReplaceTitanWeapon( titan, ordnance_before_replace, o_mods, "ordnance" )
	thread ReplaceTitanWeapon( titan, special_before_replace, s_mods, "special" )
}

function StartMissileCore( soul )
{
	local titan = soul.GetTitan()
	RegisterPreviousWeapons( titan )
	local ordnance = titan.GetOffhandWeapon( 0 )
	local special = titan.GetOffhandWeapon( 1 )
	
	local ordnance_name = ordnance.GetWeaponClassName()
	local special_name = special.GetWeaponClassName()
	if ( ordnance_name == "mp_titanweapon_shoulder_turret" )
	{
		if( special_name == "mp_titanweapon_salvo_rockets" )
		{
			ordnance_name = "mp_titanweapon_shoulder_rockets"
		}
		else
		{
			ordnance_name = "mp_titanweapon_salvo_rockets"
		}
	}
	//switch( ordnance.GetWeaponClassName() )
	//{
		
	//}
	TakePlayerWeapons( soul, "ordnance" )
	TakePlayerWeapons( soul, "special" )

	thread ReplaceTitanWeapon( titan, ordnance_name, ["dev_mod_low_recharge"], "ordnance" )
	thread ReplaceTitanWeapon( titan, special_name, ["dev_mod_low_recharge"], "special" )
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