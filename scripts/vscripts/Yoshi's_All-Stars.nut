// For Modded Titans
//const LEGION_MODEL = "models/titans/heavy/titan_heavy_deadbolt.mdl"
function main()
{
	Globalize( MasterTitanCreation )
	printl( "STAAAARRRRSSSS" )
	//IncludeFile("AS_create_legion")

	
}

function MasterTitanCreation( file, type, emb_ove, unl_lv, p_name, p_desc, t_img_imc, t_img_mcor, c_name, c_desc, c_img, s_s, s_a, s_h, s_b, ref_rodeo, titan_mdl, hatch_mdl, rodeo_num, coop_img, off_weap_overrides, hud_c_name, hud_c_hint, custom_core_start, custom_core_end )
{
	//local modded_titan_table = {}

	printl( file )

	local loop_max = MasterModdedTitans.len()
	for( local E = 0; E < loop_max; E++ )
	{
		if( loop_max > 0 )
		{
			local t_a = MasterModdedTitans[ E ]

			if( t_a.setfile == file )
				return
			
		}
	}

	local titan_array_name = {}
	
	titan_array_name.setfile <- file//a
	titan_array_name.titan_type <- type //b
	titan_array_name.embark_override <- emb_ove //c

	titan_array_name.unlock_level <- unl_lv //d
	titan_array_name.print_name <- p_name // e
	titan_array_name.print_desc <- p_desc // f
	titan_array_name.titan_img_imc <- t_img_imc // g
	titan_array_name.titan_img_mcor <- t_img_mcor // h

	titan_array_name.core_name <- c_name // i
	titan_array_name.core_desc <- c_desc // j
	titan_array_name.core_img <- c_img // k

	titan_array_name.stat_speed <- s_s // l
	titan_array_name.stat_accel <- s_a // m
	titan_array_name.stat_health <- s_h // n
	titan_array_name.stat_boost_count <- s_b // o

	titan_array_name.rodeo_ref_override <- ref_rodeo // p

	titan_array_name.titan_model <- titan_mdl // q
	titan_array_name.hatch_model <- hatch_mdl // r
	titan_array_name.rodeo_hitbox_number <- rodeo_num // s
	titan_array_name.coop_img <- coop_img // t

	titan_array_name.offhand_override <- off_weap_overrides // u

	titan_array_name.hud_core_name <- hud_c_name // v
	titan_array_name.hud_core_hint <- hud_c_hint // w
	titan_array_name.core_start <- custom_core_start // x
	titan_array_name.core_end <- custom_core_end // y

	MasterModdedTitans.append(titan_array_name)

	printt( titan_array_name )
	
	::Titans_Enum_Placement <- ::Titans_Enum_Placement + 1
	printl(::Titans_Enum_Placement)
	
	add_setfile_persistance( file, ::Titans_Enum_Placement )
	//CreateBlackMarketModdedItems( Titans_Enum_Placement - BASE_TITAN_COUNT )
}
//holy shit i almost had the entire alphabet [ z ]

main()

/*



*/