// Ordinary CLIENT presentation only. Call from the committed-state think, never
// movement callbacks or prediction replay. The step is the SP graph's resolved
// sound-source family for the current physical surface.
::PilotSlideAudio <- { player = null, session = -1, step = "", loop = "", active = false }

// Physical-surface -> authored slide source-family mapping. Categories that
// have no named source variant use the exact source family called by the SP
// graph (e.g. Default -> Concrete, MetalGrate -> SolidMetal).
::PilotSlideAudioSurfaceSteps <- {}
local pilotSlideAudioSurfaceGroups = {
	Concrete = ["default", "concrete", "rock", "lava_rock", "lava_rock_hot", "lava_flow",
		"porcelain", "boulder", "asphalt", "brick", "concrete_block", "ceiling_tile",
		"tile", "glass", "glass_breakable", "glassbottle", "pottery", "digital_water",
		"flesh", "armorflesh", "bloodyflesh", "alienflesh", "alienplant", "caustic_trap",
		"spiderflesh", "plastic_barrel", "plastic_box", "plastic", "item", "rubber",
		"rubbertire", "jeeptire", "slidingrubbertire", "brakingrubbertire",
		"slidingrubbertire_front", "slidingrubbertire_rear", "plastic_barrel_buoyant",
		"default_silent", "vehicle_barrier", "player", "player_control_clip",
		"upholstery", "flyerflesh", "ammo_box", "helmet", "large_backpack",
		"small_backpack", "large_medkit", "small_medkit", "att_scope", "att_sup",
		"wpn_ar", "wpn_sniper", "wpn_smg", "wpn_pistol", "wpn_shotgun", "vest",
		"mags", "cyn_medkit", "frag", "arcblade", "batteryshield", "void_ring",
		"beaconcapsule", "att_lasersight", "wpn_knife", "ferrofluid", "evactower",
		"shieldcore", "ribbon", "evo_orb"],
	Dirt = ["dirt", "dirt_red", "gravel", "slipperyslime", "carpet", "cardboard",
		"floatingstandable", "paper", "papercup"],
	Grass = ["grass", "foliage", "leafy_step"],
	Mud = ["mud"],
	Sand = ["sand", "sand_red", "sand_black", "sand_white", "quicksand", "snow", "ice"],
	SolidMetal = ["metal_titan", "solidmetal", "metal", "metal_box", "metalpanel",
		"metalgrate", "metalvent", "chainlink", "chain", "shellcasing_small",
		"shellcasing_large", "weapon", "computer", "canister", "metal_barrel",
		"grenade", "grenade_triple_threat", "bouncygrenade", "metal_bouncy",
		"slipperymetal", "vehicle", "floating_metal_barrel", "roller", "popcan",
		"paintcan", "metal_spectre", "arc_grenade", "underground_cube", "turret_gib",
		"reflective", "weightedcube_bounce", "paintbomb", "sphere2", "flesh_dummie"],
	Water = ["water", "slime"],
	Wood = ["wood", "wood_solid", "wood_lowdensity", "wood_box", "wood_crate",
		"wood_plank", "wood_furniture", "wood_panel", "plaster"],
	xo_shield = ["xo_shield"]
}
foreach ( step, surfaces in pilotSlideAudioSurfaceGroups )
	foreach ( surface in surfaces )
		::PilotSlideAudioSurfaceSteps[surface] <- step

function PilotSlideAudio_Step( surfaceName )
{
	local key = surfaceName.tolower()
	if ( key in ::PilotSlideAudioSurfaceSteps )
		return ::PilotSlideAudioSurfaceSteps[key]
	throw "PilotSlideAudio: unsupported SP physical surface '" + surfaceName + "'"
}

function PilotSlideAudio_Alias( verb, step )
{
	local key = step.tolower()
	local names = {
		concrete = "Concrete",
		dirt = "Dirt",
		grass = "Grass",
		mud = "Mud",
		sand = "Sand",
		solidmetal = "SolidMetal",
		water = "Water",
		wood = "Wood",
		xo_shield = "Concrete",
	}
	if ( key in names )
		return "R1D_Slide_" + verb + "_" + names[key]
	throw "PilotSlideAudio: no authored " + verb + " sound alias for SP step '" + step + "'"
}

function PilotSlideAudio_Stop( playEnd )
{
	local state = ::PilotSlideAudio
	if ( IsValid( state.player ) )
	{
		if ( state.loop != "" )
			StopSoundOnEntity( state.player, state.loop )
			
		if ( playEnd && state.step != "" )
		{
			local ending = PilotSlideAudio_Alias( "End", state.step )
			EmitSoundOnEntity( state.player, ending )
			EmitSoundOnEntity( state.player, "R1D_Slide_End_Gear" )
			EmitSoundOnEntity( state.player, "R1D_Slide_Bump" )
			EmitSoundOnEntity( state.player, "R1D_Slide_3P_Gear" )
		}
	}
	state.player = null
	state.session = -1
	state.step = ""
	state.loop = ""
	state.active = false

}
function PilotSlideAudio_Cleanup( player = null )
{
	local state = ::PilotSlideAudio
	if ( player != null && state.player != player )
		return
	PilotSlideAudio_Stop( false )
}

function PilotSlideAudio_Update( player, session, sliding, step )
{
	local state = ::PilotSlideAudio
	if ( !sliding || !IsValid( player ) )
	{
		PilotSlideAudio_Stop( sliding == false )
		return
	}
	if ( state.player != player || state.session != session )
	{
		PilotSlideAudio_Stop( false )
		state.player = player
		state.session = session
	}
	if ( step == null )
	{
		if ( state.loop != "" )
			StopSoundOnEntity( player, state.loop )
		state.step = ""
		state.loop = ""
		state.active = true
		return
	}
	local loop = PilotSlideAudio_Alias( "Loop", step )
	if ( state.active && state.step == step && state.loop == loop )
		return
	if ( state.active )
	{
		if ( state.loop != "" )
			StopSoundOnEntity( player, state.loop )
		EmitSoundOnEntity( player, "R1D_Slide_Bump" )
	}
	else
	{
		EmitSoundOnEntity( player, PilotSlideAudio_Alias( "Start", step ) )
		if ( step.tolower() == "water" )
			EmitSoundOnEntity( player, "R1D_Slide_Start_Water_Gear" )
		if ( step.tolower() == "xo_shield" )
			EmitSoundOnEntity( player, "R1D_Slide_Start_XoShield_Gear" )
		else
			EmitSoundOnEntity( player, "R1D_Slide_3P_Gear" )
	}
	EmitSoundOnEntity( player, loop )
	state.step = step
	state.loop = loop
	state.active = true
}

Globalize( PilotSlideAudio_Cleanup )
Globalize( PilotSlideAudio_Update )

// SERVER ordinary published-state consumer. The imported graph has dedicated
// 3P gear one-shots only at slide start/stop; do not echo local-only 1P loops.
function PilotSlideAudio_ServerUpdate( player, session, sliding )
{
	if ( !IsValid( player ) || !player.IsPlayer() )
		return
	if ( !( "r1dSlideAudioSession" in player.s ) )
	{
		player.s.r1dSlideAudioSession <- -1
		player.s.r1dSlideAudioActive <- false
	}
	if ( player.s.r1dSlideAudioSession != session )
	{
		player.s.r1dSlideAudioSession = session
		player.s.r1dSlideAudioActive = false
	}
	if ( sliding == player.s.r1dSlideAudioActive )
		return
	EmitSoundOnEntityExceptToPlayerNotPredicted( player, player, "R1D_Slide_3P_Gear" )
	player.s.r1dSlideAudioActive = sliding
}

function PilotSlideAudio_ServerCleanup( player )
{
	if ( IsValid( player ) && "r1dSlideAudioSession" in player.s )
	{
		delete player.s.r1dSlideAudioSession
		delete player.s.r1dSlideAudioActive
	}
}

Globalize( PilotSlideAudio_ServerUpdate )
Globalize( PilotSlideAudio_ServerCleanup )
Globalize( PilotSlideAudio_Step )
