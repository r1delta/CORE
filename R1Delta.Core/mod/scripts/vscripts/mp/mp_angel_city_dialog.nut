function main()
{

	RegisterConversation( "militia_strength_75_percent",	VO_PRIORITY_GAMESTATE )
	RegisterConversation( "militia_strength_50_percent",	VO_PRIORITY_GAMESTATE )
	RegisterConversation( "militia_strength_25_percent",	VO_PRIORITY_GAMESTATE )

	RegisterConversation( "imc_strength_75_percent",	VO_PRIORITY_GAMESTATE )
	RegisterConversation( "imc_strength_50_percent",	VO_PRIORITY_GAMESTATE )
	RegisterConversation( "imc_strength_25_percent",	VO_PRIORITY_GAMESTATE )

	RegisterConversation( "match_progress_15_percent",	VO_PRIORITY_GAMESTATE )
	RegisterConversation( "match_progress_40_percent",	VO_PRIORITY_GAMESTATE )

	RegisterConversation( "militia_intro_vdu",	    VO_PRIORITY_GAMESTATE )

	RegisterConversation( "megacarrier_announcement",	    VO_PRIORITY_GAMESTATE )

	//Evac stuff
	RegisterConversation( "losers_evac_post_evac", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "losers_evac_post_pursuit", VO_PRIORITY_GAMESTATE )

	//AI Chatter
	RegisterConversation( "angelcity_grunt_chatter", VO_PRIORITY_AI_CHATTER_LOW )
	RegisterConversation( "ai_announce_megacarrier", VO_PRIORITY_AI_CHATTER_HIGH )
	RegisterConversation( "ai_comment_megacarrier", VO_PRIORITY_AI_CHATTER_LOW )


	if ( IsServer() )
		return

	RegisterAngelCityAIChatter()

	local convRef

	//##################################
	//	 Militia Intro
	//##################################

	convRef = AddConversation( "militia_intro_vdu" )
	AddVDURadio( convRef, "mac", null, "diag_cmp_angc_mcor_macal_groundintro_116_11" )
	AddVDURadio( convRef, "bish", null, "diag_cmp_angc_mcor_bish1_groundintro_116_12" )
	AddWait( convRef, 0.5 )
	AddVDURadio( convRef, "mac", null, "diag_cmp_angc_mcor_macal_groundintro_116_14" )

	// barker line?
	//AddRadio( convRef, "diag_cmp_angc_mcor_barker_groundintro_116_10" )


	//##################################
	//	 Match Progress Dialogue
	//##################################

		//##################################
		//	 Blisk (IMC version of Bish)
		//##################################

	// Blisk: Be advised, we've taken some losses, and our ground forces are now at 75% strength.
	// AddVDUAnimWithEmbeddedAudioForBlisk( "imc_strength_75_percent", "diag_cmp_angc_imc_blisk_imcstren_106" ) // only imc -> militia change
	AddVDULineForBish( "imc_strength_75_percent", null, "diag_cmp_angc_mcor_bish1_militiaStren_103" )

	// Blisk: Our ground forces are down to 50%!
	// AddVDUAnimWithEmbeddedAudioForBlisk( "imc_strength_50_percent", "diag_cmp_angc_imc_blisk_imcstren_107" ) // only imc -> militia change
	AddVDULineForBish( "imc_strength_50_percent", null, "diag_cmp_angc_mcor_bish1_militiaStren_104" )

	// Blisk: Our ground forces are down to about 25%. Heavy losses across the board. We can't take much more of this.
	// AddVDUAnimWithEmbeddedAudioForBlisk( "imc_strength_25_percent", "diag_cmp_angc_imc_blisk_imcstren_108" ) // only imc -> militia change
	AddVDULineForBish( "imc_strength_25_percent", null, "diag_cmp_angc_mcor_bish1_militiaStren_105" )
	
	

		//##################################
		//	Mac & Bish ( MILITIA )
		//##################################

	// Bish:Ok, our combat effectiveness is down to 75%. We're doin' ok but things could be better.
	AddVDULineForBish( "militia_strength_75_percent", null, "diag_cmp_angc_mcor_bish1_militiaStren_103" )

	// Bish:Heads up, intel says we're down to 50% combat effectiveness. Let's pull it together team.
	AddVDULineForBish( "militia_strength_50_percent", null, "diag_cmp_angc_mcor_bish1_militiaStren_104" )

	// Bish:Hey! We've taken heavy losses! Combat effectiveness is down to 25%! We're gonna have to bug out if this keeps up.
	AddVDULineForBish( "militia_strength_25_percent", null, "diag_cmp_angc_mcor_bish1_militiaStren_105" )

	//These lines sound too much like they should be played when leading...
	//Sarah: Bish, I'm tracking MacAllan's team in the sewers. They're doing ok so far. Our topside diversion is definitely working.
	//Bish: Copy that. Keep your fingers crossed…
	local convRef = AddConversation( "match_progress_15_percent" )
	AddVDURadio( convRef, "sarah", "diag_cmp_angc_mcor_sarah_sitFlavor_124_1" )
	AddVDURadio( convRef, "bish", "diag_cmp_angc_mcor_bish1_sitFlavor_124_2" )

	//Sarah: Bish, MacAllan's team is almost clear of the sewers.
	//Bish: Got it. Ok Pilots, our diversion's still working, we just need to buy MacAllan and Barker a little more time…
	local convRef = AddConversation( "match_progress_40_percent" )
	AddVDURadio( convRef, "sarah", "diag_cmp_angc_mcor_sarah_sitFlavor_125_1" )
	AddVDURadio( convRef, "bish", "diag_cmp_angc_mcor_bish1_sitFlavor_125_2" )

		//##################################
		//	Post Evac Lines ( IMC ). No equivalent Militia lines
		//##################################

	//Winning lines
	//Graves: Sergeant Blisk, get your search parties working double time. I have a feeling this was a diversion, but we have to make sure.
	//Blisk: If it was just a diversion sir, they certainly paid a high price for it.
	convRef = AddConversation( "losers_evac_post_pursuit", TEAM_IMC ) // only imc campaign mode only
	AddVDURadio( convRef, "graves", "diag_cmp_angc_imc_grave_epflavor_128_1a" )
	AddVDURadio( convRef, "blisk", "diag_cmp_angc_imc_blisk_epflavor_128_2" )


	//Losing lines
	//Blisk: The Sentinel's taken severe internal damage sir, she'll need some repairs
	//Graves: Set a course for the Freeport system. We'll repair the ship there. We'll get MacAllan later.
	convRef = AddConversation( "losers_evac_post_evac", TEAM_IMC ) // only imc campaign mode only
	AddVDURadio( convRef, "blisk", "diag_cmp_angc_imc_blisk_losepostep_22_1a" )
	AddVDURadio( convRef, "graves", "diag_cmp_angc_imc_graves_losepostep_22_2" )

	//Losing lines
	//Blisk: The Sentinel's taken severe internal damage sir, she'll need some repairs
	//Graves: Set a course for the Freeport system. We'll repair the ship there. We'll get MacAllan later.
	convRef = AddConversation( "losers_evac_post_pursuit", TEAM_IMC ) // only imc campaign mode only
	AddVDURadio( convRef, "blisk", "diag_cmp_angc_imc_blisk_losepostep_22_1a" )
	AddVDURadio( convRef, "graves", "diag_cmp_angc_imc_graves_losepostep_22_2" )

	//##################################
	//	 MegaCarrier Announcement
	//##################################

	//Sarah: Bish, I'm picking up a MASSIVE incoming jump signature directly above the city. I don't know what it is, but it's… big... and whoa, heads up!
	//Bish: Holy s*bzzt*t. Mac, an IMC carrier just jumped in.... You better get Barker outta here quick!
	//Mac: "Copy that Bish, I'm working on it!"
	//Sarah: "I'm sending in some Hornets to keep that carrier busy. Pilots, focus on clearing out the IMC forces on the ground."
	convRef = AddConversation( "megacarrier_announcement" )
	AddVDURadio( convRef, "sarah", null, "diag_cmp_angc_mcor_sarah_megacarrierwarp_423_1" )
	AddWait( convRef, 1.0 )
	AddVDURadio( convRef, "bish", "diag_cmp_angc_mcor_bish1_megacarrierwarp_423_2", "diag_vdu_default" )
	AddVDURadio( convRef, "mac", "diag_cmp_angc_mcor_macal_megacarrierwarp_423_3", "diag_vdu_default" )
	AddWait( convRef, 1.3 )
	AddVDURadio( convRef, "sarah", null, "diag_cmp_angc_mcor_sarah_megacarrierwarp_423_4" )


	//##################################
	//	 Grunt AI Chatter
	//##################################

}

function RegisterAngelCityAIChatter()
{
	AngelCityAddConversations( TEAM_MILITIA, level.actorsABCD )
	AngelCityAddConversations( TEAM_IMC, level.actorsABCD )
}

function AngelCityAddConversations( team, actors )
{
	//Angel City specific lines
	Assert ( GetMapName() == "mp_angel_city" )
	local conversation = "angelcity_grunt_chatter"

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment2L_01_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AC_comment2L_01_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment2L_02_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AC_comment2L_02_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment2L_03_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AC_comment2L_03_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment2L_04_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AC_comment2L_04_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment2L_05_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AC_comment2L_05_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment2L_06_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AC_comment2L_06_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment2L_07_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AC_comment2L_07_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment2L_08_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AC_comment2L_08_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment2L_09_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AC_comment2L_09_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment2L_10_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AC_comment2L_10_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment2L_11_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AC_comment2L_11_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	//gs_AC_comment2L_12 are lines that only make sense after the mega carrier has arrived

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment2L_13_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AC_comment2L_13_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment2L_14_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AC_comment2L_14_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment2L_15_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AC_comment2L_15_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment2L_16_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AC_comment2L_16_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment2L_17_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AC_comment2L_17_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment2L_18_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AC_comment2L_18_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment3L_01_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AC_comment3L_01_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment3L_01_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment3L_02_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AC_comment3L_02_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment3L_02_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment3L_03_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AC_comment3L_03_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment3L_03_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	// gs_AC_comment3L_04 has a line commenting on the mega carrier for the IMC ( even though the militia side doesn't!) so shifting it to ai_comment_megacarrier

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment3L_05_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AC_comment3L_05_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment3L_05_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment3L_06_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AC_comment3L_06_02", actors )]}
		{ dialogType = "speech", speakerIndex = 2, choices = [Voices( team, "gs_AC_comment3L_06_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment3L_07_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AC_comment3L_07_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment3L_07_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment3L_08_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AC_comment3L_08_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment3L_08_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment3L_09_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AC_comment3L_09_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment3L_09_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment3L_10_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AC_comment3L_10_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment3L_10_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment3L_11_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AC_comment3L_11_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment3L_11_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment3L_12_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AC_comment3L_12_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment3L_12_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment4L_01_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AC_comment4L_01_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment4L_01_03", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AC_comment4L_01_04", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment4L_02_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AC_comment4L_02_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment4L_02_03", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AC_comment4L_02_04", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment4L_03_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AC_comment4L_03_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment4L_03_03", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AC_comment4L_03_04", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment4L_04_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AC_comment4L_04_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment4L_04_03", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AC_comment4L_04_04", actors )]}
	]
	AddConversation( conversation, team, lines )


	//Played immediately after the mega carrier jumps in
	local conversation = "ai_announce_megacarrier"

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment2L_12_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AC_comment2L_12_02", actors )]}
	]

	AddConversation( conversation, team, lines )


    //Played sometime after the mega carrier jumps in, after the sequence finishes
	local conversation = "ai_comment_megacarrier"

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment2L_12_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AC_comment2L_12_02", actors )]}
	]

	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment3L_13_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AC_comment3L_13_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment3L_13_01", actors )]}
	]

	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment3L_04_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AC_comment3L_04_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AC_comment3L_04_03", actors )]}
	]
	AddConversation( conversation, team, lines )



}