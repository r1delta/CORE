
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

	local core_start = StartECHOCore
	local core_end = EndECHOCore

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
		"Core Ability: ECHO - Sonar", 
		"Enables titan sonar, when the core expires it continues to echo around the titan in a slower manner.", 
		"../ui/menu/items/ability_icons/sonar", 
		85, 
		90, 
		76, 
		2, 
		"", 
		TONE_MODEL, 
		STRYDER_HATCH_PANEL, 
		53, 
		"../ui/menu/items/ability_icons/sonar", 
		offhand_override_data,
		"ECHO Sonar Online",
		"Sonar Instruments calibrated.",
		core_start,
		core_end
		)
}

function EndECHOCore( soul )
{
	local titan = soul.GetTitan()
	
	ActivateSonar( titan.GetActiveWeapon(), 1 )
}

function StartECHOCore( soul )
{
	local titan = soul.GetTitan()
	
	ActivateSonar( titan.GetActiveWeapon(), 9999 )
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