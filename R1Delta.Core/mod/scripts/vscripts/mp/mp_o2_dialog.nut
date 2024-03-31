const FIRST_WARNING_PROGRESS  = 27
const SECOND_WARNING_PROGRESS = 54
const THIRD_WARNING_PROGRESS  = 76

function main()
{
	if ( !GetCinematicMode() )
		return

	if ( GAMETYPE != CAPTURE_POINT )
		return

	CapturePointDialogOverride()
	SetupProgressMessages()

	RegisterConversation( "O2LostAnnouncement", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "O2WonAnnouncement", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "O2GameModeAnnounce_CP", VO_PRIORITY_GAMESTATE )

	RegisterConversation( "GameOver25percentMilitiaWinning", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "GameOver25percentIMCWinning", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "GameOver50percentMilitiaWinning", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "GameOver50percentIMCWinning", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "GameOver75percentMilitiaWinning", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "GameOver75percentIMCWinning", VO_PRIORITY_GAMESTATE )

	// Evac
	RegisterConversation( "EvacNagMilitaWon", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "EvacNagIMCWon", VO_PRIORITY_GAMESTATE )

	//AI Chatter
	RegisterConversation( "o2_grunt_chatter", VO_PRIORITY_AI_CHATTER_LOW )

	if ( IsServer() )
		return

	O2AIChatter()

	local convRef


	/*----------------------------------------------------------------------------------
	/
	/				GAME MODE ANNOUNCE DIALOGUE
	/
	/-----------------------------------------------------------------------------------*/
	//-----------
	// MILITIA
	//-----------
	//Bish:	Pilot, this is a hardpoint mission. Patch me into the hardpoints so I can overload the fusion reactor core. The IMC is gonna try to shut down the system and lock us out. Let's blow this place before that happens.
	convRef = AddConversation( "O2GameModeAnnounce_CP" )
	AddVDURadio( convRef, "bish", null, "diag_hp_ModeAnnc_O2108a_01_01_mcor_bish" )


	/*----------------------------------------------------------------------------------
	/
	/				WINNING/LOSING STATUS DIALOGUE
	/
	/-----------------------------------------------------------------------------------*/
	//-----------
	// MILITIA
	//-----------
	//Bish:	We're doing great, keep it up.
	convRef = ReplaceConversation( "WinningScoreBigMarginMatchLate" )
	AddVDURadio( convRef, "bish", "diag_hp_milLeadGreat_matchLate_O2155_01_21_mcor_bish" )

	//Bish:	We're getting hammered down there!  Get it together or we won't have a chance to destroy this facility.
	convRef = ReplaceConversation( "LosingScoreBigMarginMatchLate" )
	AddVDURadio( convRef, "bish", "diag_hp_milTrailGreat_matchLate_O2156_01_01_mcor_bish" )

	//Bish:	We're winning, but just barely.
	convRef = ReplaceConversation( "WinningScoreSmallMarginMatchLate" )
	AddVDURadio( convRef, "bish", "diag_hp_milLeadSlight_matchLate_O2157_01_21_mcor_bish" )

	//Bish:	We're losing, but just barely. You need to push harder or the IMC is going to shut down the entire facility!
	convRef = ReplaceConversation( "LosingScoreSmallMarginMatchLate" )
	AddVDURadio( convRef, "bish", "diag_hp_milTrailSlight_matchLate_O2158_01_01_mcor_bish" )


	/*----------------------------------------------------------------------------------
	/
	/				MATCH PROGRESS DIALOGUE (WINNING/LOSING)
	/
	/-----------------------------------------------------------------------------------*/
	//----------------------------
	// 25% OVER, MILITIA WINNING
	//----------------------------
	//Bish:	We're 25% of the way there!
	//Bish:Control those hardpoints and I'll make sure this place becomes a cloud of vapor.
	convRef = AddConversation( "GameOver25percentMilitiaWinning" )
	AddVDURadio( convRef, "bish", "diag_hp_MatchProg_MIL25_O2111_02_01_mcor_bish" )


	//----------------------------
	// 25% OVER, IMC WINNING
	//----------------------------
	//Bish:	The IMC are 25% of the way to shutting down the reactor core! Control those hardpoints!
	convRef = AddConversation( "GameOver25percentIMCWinning" )
	AddVDURadio( convRef, "bish", "diag_hp_MatchProg_IMC25_O2112_01_01_mcor_bish" )


	//----------------------------
	// 50% OVER, MILITIA WINNING
	//----------------------------
	//Bish:	Were halfway there!
	//Bish: Keep control of the hardpoints or the IMC is going to shut down the reactor core!
	convRef = AddConversation( "GameOver50percentMilitiaWinning" )
	AddVDURadio( convRef, "bish", "diag_hp_MatchProg_MIL50_O2117_01_01_mcor_bish" )
	AddVDURadio( convRef, "bish", "diag_hp_MatchProg_MIL50_O2117_01_02_mcor_bish" )


	//----------------------------
	// 50% OVER, IMC WINNING
	//----------------------------
	//Bish:	The IMC are 50% of the way to shutting down the reactor core!
	//Bish:	Take those hardpoints or we'll never be able to get this reactor to explode!
	convRef = AddConversation( "GameOver50percentIMCWinning" )
	AddVDURadio( convRef, "bish", "diag_hp_MatchProg_IMC50_O2118_01_01_mcor_bish" )
	AddVDURadio( convRef, "bish", "diag_hp_MatchProg_IMC50_O2118_01_02_mcor_bish" )


	//----------------------------
	// 75% OVER, MILITA WINNING
	//----------------------------
	//Bish:	Good. We're 75% of the way to blowing this place sky high!
	//Bish:	Keep me patched in to those hardpoints!
	convRef = AddConversation( "GameOver75percentMilitiaWinning" )
	AddVDURadio( convRef, "bish", "diag_hp_MatchProg_MIL75_O2123_01_01_mcor_bish" )
	AddVDURadio( convRef, "bish", "diag_hp_MatchProg_MIL75_O2123_01_02_mcor_bish" )


	//----------------------------
	// 75% OVER, IMC WINNING
	//----------------------------
	//Bish:	This is bad, the IMC are 75% of the way to shutting down the reactor core!
	//Bish: Guys, you gotta step it up.  The IMC is nearly done shutting down the reactor core!
	convRef = AddConversation( "GameOver75percentIMCWinning" )
	AddVDURadio( convRef, "bish", "diag_hp_MatchProg_IMC75_O2124_01_01_mcor_bish" )
	AddVDURadio( convRef, "bish", "diag_hp_MatchProg_IMC75_O2124_01_02_mcor_bish" )


	/*----------------------------------------------------------------------------------
	/
	/				MILITA WON DIALOGUE - EPILOGUE START
	/
	/-----------------------------------------------------------------------------------*/
	//-----------
	// MILITIA
	//-----------
	//Bish:	You did it! The reactor core is ready to blow!  Now get to the IMC evac point and make sure they don't escape.
	convRef = AddConversation( "O2WonAnnouncement" )
	AddVDURadio( convRef, "bish", "diag_hp_milWinAnnc_O2140_03_01_mcor_bish"  )


	/*----------------------------------------------------------------------------------
	/
	/				IMC WON DIALOGUE - EPILOGUE START
	/
	/-----------------------------------------------------------------------------------*/
	//-----------
	// MILITIA
	//-----------
	//Bish: We lost. The IMC managed to shut down the reactor. Get to the evac point ASAP.  No sense losing any more pilots today.
	convRef = AddConversation( "O2LostAnnouncement" )
	AddVDURadio( convRef, "bish", "diag_hp_milLoseAnnc_O2139_03_01_mcor_bish" )


	/*----------------------------------------------------------------------------------
	/
	/				MILITA WON DIALOGUE NAGS
	/
	/-----------------------------------------------------------------------------------*/
	//-----------
	// MILITIA
	//-----------
	//Sarah: Alright, chase down the remaining ground forces at their evac point.  Bish will handle blowing up the reactor.
	convRef = AddConversation( "EvacNagMilitaWon" )
	AddWait( convRef, 2.5 )
	AddVDURadio( convRef, "sarah", "diag_hp_milWin_epNag_O2141_01_01_mcor_sarah" )


	/*----------------------------------------------------------------------------------
	/
	/				IMC WON DIALOGUE NAGS
	/
	/-----------------------------------------------------------------------------------*/
	//-----------
	// MILITIA
	//-----------
	convRef = AddConversation( "EvacNagIMCWon" )
	AddWait( convRef, 2 )

	//Militia radio chatter	(radio chatter) We’re being overrun! Combat Spectres are making suicide runs on us! We’ve got to bug out now!!!
	//AddVDURadio( convRef, "grunt", "diag_hp_milWin_epFlav_CR144_01_01_mcor_grunt1" )

	// --- OR ---

	convRef = AddConversation( "EvacNagIMCWon" )
	AddWait( convRef, 2 )
	//Sarah: Get to the evac point!  They've shut down the core so there's nothing else you can do now.
	AddVDURadio( convRef, "sarah", "diag_hp_milWin_epNag_O2142_01_01_mcor_sarah" )


	/*----------------------------------------------------------------------------------
	/
	/				MILITA WON DIALOGUE EPILOGUE END
	/
	/-----------------------------------------------------------------------------------*/
	//-----------
	// MILITIA
	//-----------


	/*----------------------------------------------------------------------------------
	/
	/				IMC WON DIALOGUE EPILOGUE END
	/
	/-----------------------------------------------------------------------------------*/
	//-----------
	// IMC
	//-----------


	/*----------------------------------------------------------------------------------
	/
	/				FACILITY WARNING MESSAGES
	/
	/-----------------------------------------------------------------------------------*/

	/*----------------------------------------------------------------------------------
	/
	/				GRUNT CHATTER
	/
	/-----------------------------------------------------------------------------------*/
}



/*----------------------------------------------------------------------------------
/
/				GAME PROGRESS MESSAGES
/
/-----------------------------------------------------------------------------------*/
function SetupProgressMessages()
{
	level.dialogAliases[ "warning_" + FIRST_WARNING_PROGRESS ]		<- "diag_hp_MatchProg_MIL25_O2110_01_01_ntrl_bgpa"
	level.dialogAliases[ "warning_" + SECOND_WARNING_PROGRESS ]		<- "diag_hp_MatchProg_MIL50_O2115_01_01_ntrl_bgpa"
	level.dialogAliases[ "warning_" + THIRD_WARNING_PROGRESS ]		<- "diag_hp_MatchProg_MIL75_O2121_01_01_ntrl_bgpa"

	level.progressConversations <- {}
	level.progressConversations[ FIRST_WARNING_PROGRESS ] 			<- "GameOver25percentMilitiaWinning"
	level.progressConversations[ SECOND_WARNING_PROGRESS ] 			<- "GameOver50percentMilitiaWinning"
	level.progressConversations[ THIRD_WARNING_PROGRESS ] 			<- "GameOver75percentMilitiaWinning"

	// These are all roughly 8 seconds long
	level.dialogAliases[ "warning_match_over" ] <- ["diag_hp_milWinAnnc_O2140_01_01_ntrl_bgpa", "diag_hp_milWinAnnc_O2140_01_02_ntrl_bgpa", "diag_hp_milWinAnnc_O2140_01_03_ntrl_bgpa", "diag_hp_milWinAnnc_O2140_02_01_ntrl_bgpa" ]
}


function CapturePointDialogOverride()
{
	/*----------------------------------------------------------------------------------
	/
	/				HARDPOINT DIALOGUE OVERRIDES
	/
	/-----------------------------------------------------------------------------------*/
	// overrides the default lines for capture point mode

	local dialogAliases = level.dialogAliases

	// this clears the VDU whitelist
	level.whiteList = {}


	//-------------------------------------------
	// MILITIA lost all hardpoints
	//-------------------------------------------
	//Bish:	All hardpoints are under enemy control! Take over those hardpoints or they’ll shut down the core entirely and we'll never get it to meltdown!
	//Bish:	Enemy has control of the hardpoints! We need to regain control or we'll never nuke that facility!
	//Bish: IMC has all three hardpoints. If we don't get them back, the reactor core will go completely offline and be useless to us.
	dialogAliases["hardpoint_lost_all"] = ["diag_hp_LostAll_O2127_01_01_mcor_bish",
													 "diag_hp_LostAll_O2127_01_02_mcor_bish",
													 "diag_hp_LostAll_O2127_01_03_mcor_bish"]


	//----------------------------------------------------------
	// MILITIA capping hardpoint
	//----------------------------------------------------------
	// Starting cap from enemy controlled
	//Bish:	Stay close to the hardpoint while I patch into the reactor's mainframe.
	//Bish:	Keep close to the terminal while I try to gain access to the reactor's mainframe.
	//Bish:	Attempting to bypass security protocols for the reactor…stay close to the terminal.
	dialogAliases["hardpoint_status_0_a"] = ["diag_hp_PatchedIn_O2129_01_01_mcor_bish", "diag_hp_PatchedIn_O2129_01_02_mcor_bish", "diag_hp_PatchedIn_O2129_01_03_mcor_bish" ]
	dialogAliases["hardpoint_status_0_b"] = ["diag_hp_PatchedIn_O2129_01_01_mcor_bish", "diag_hp_PatchedIn_O2129_01_02_mcor_bish", "diag_hp_PatchedIn_O2129_01_03_mcor_bish" ]
	dialogAliases["hardpoint_status_0_c"] = ["diag_hp_PatchedIn_O2129_01_01_mcor_bish", "diag_hp_PatchedIn_O2129_01_02_mcor_bish", "diag_hp_PatchedIn_O2129_01_03_mcor_bish" ]

	//Cap at 25%...generic short version only
	dialogAliases["hardpoint_status_25"] = "diag_hp_mcor_bish_generalpurpose_noprefix_03"

	//Cap at 50%...use custom dialogue here
	//Bish:	Reactor overload pressure at 50%
	//Bish:	50% reactor overload pressure.
	//Bish:	50% overload pressure complete.
	dialogAliases["hardpoint_status_50"] = ["diag_hp_CapProg_MIL50_O2131_01_01_mcor_bish", "diag_hp_CapProg_MIL50_O2131_01_02_mcor_bish", "diag_hp_CapProg_MIL50_O2131_01_03_mcor_bish"]

	//Cap at 75%...generic short version only
	dialogAliases["hardpoint_status_75"] = "diag_hp_mcor_bish_generalpurpose_noprefix_01"
	dialogAliases["hardpoint_status_100"] = ["null_temp"] // not used


	// Starting cap from neutral
	// Bish: Stay close to the hardpoint while I patch into the reactor's mainframe.
	// Bish: Keep close to the terminal while I try to gain access to the reactor's mainframe.
	// Bish: Attempting to bypass security protocols for the reactor�stay close to the terminal.
	dialogAliases["hardpoint_player_capping_a"] = ["diag_hp_PatchedIn_O2129_01_01_mcor_bish", "diag_hp_PatchedIn_O2129_01_02_mcor_bish", "diag_hp_PatchedIn_O2129_01_03_mcor_bish" ]
	dialogAliases["hardpoint_player_capping_b"] = ["diag_hp_PatchedIn_O2129_01_01_mcor_bish", "diag_hp_PatchedIn_O2129_01_02_mcor_bish", "diag_hp_PatchedIn_O2129_01_03_mcor_bish" ]
	dialogAliases["hardpoint_player_capping_c"] = ["diag_hp_PatchedIn_O2129_01_01_mcor_bish", "diag_hp_PatchedIn_O2129_01_02_mcor_bish", "diag_hp_PatchedIn_O2129_01_03_mcor_bish" ]


	// Continuing cap after neutralizing hardpoint
	//Bish: Hardpoint neutralized. Preparing to access the reactor's mainframe.
	//Bish:	I'm in…shutting down safety protocols and increasing reactor pressure. Keep me connected while I overload the system.
	//Bish:	Bypassing security protocols and increasing reactor pressure…standby.
	dialogAliases["hardpoint_status_neutral_0_a"] = "diag_hp_Neutralized_O2130_01_01_mcor_bish"
	dialogAliases["hardpoint_status_neutral_0_b"] = "diag_hp_Neutralized_O2130_01_02_mcor_bish"
	dialogAliases["hardpoint_status_neutral_0_c"] = "diag_hp_Neutralized_O2130_01_03_mcor_bish"

	//Cap at 25%...generic short version only
	dialogAliases["hardpoint_status_neutral_25"] = "diag_hp_mcor_bish_generalpurpose_noprefix_03"

	//Cap at 50%...use custom dialogue here
	//Bish:	Spectre A.I. mainframe bypass at 50%
	//Bish:	50% bypass of local A.I. mainframe.
	//Bish:	50% bypass complete
	dialogAliases["hardpoint_status_neutral_50"] = ["diag_hp_CapProg_MIL50_O2131_01_01_mcor_bish", "diag_hp_CapProg_MIL50_O2131_01_02_mcor_bish", "diag_hp_CapProg_MIL50_O2131_01_03_mcor_bish"]

	//Cap at 75%...generic short version only
	dialogAliases["hardpoint_status_neutral_75"] = "diag_hp_mcor_bish_datagrabprogress_03"
	dialogAliases["hardpoint_status_neutral_100"] =["null_temp"] // not used


	//-------------------------------------------
	// MILITIA capped hardpoint
	//-------------------------------------------
	// Capturing 1 of 3
	//Bish:	Good work. I've overloaded this sector. Reactor pressure is increasing.
	//Bish:	Right on. I have access to this section of the mainframe…increasing reactor pressure in that area.
	//Bish:	Alright I have control over this section of the mainframe…let's heat things up.
	dialogAliases["hardpoint_player_captured_get_ac"] = ["diag_hp_CapHpMIL_O2132_01_01_mcor_bish", "diag_hp_CapHpMIL_O2132_01_02_mcor_bish", "diag_hp_CapHpMIL_O2132_01_03_mcor_bish" ]
	dialogAliases["hardpoint_player_captured_get_bc"] = ["diag_hp_CapHpMIL_O2132_01_01_mcor_bish", "diag_hp_CapHpMIL_O2132_01_02_mcor_bish", "diag_hp_CapHpMIL_O2132_01_03_mcor_bish" ]
	dialogAliases["hardpoint_player_captured_get_ab"] = ["diag_hp_CapHpMIL_O2132_01_01_mcor_bish", "diag_hp_CapHpMIL_O2132_01_02_mcor_bish", "diag_hp_CapHpMIL_O2132_01_03_mcor_bish" ]

	// Capturing 2 of 3
	//Bish:	Good work. I’ve locked down this portion of the Spectre A.I. mainframe. Activating dormant Spectres near the hardpoint to help you out.
	//Bish:	Right on. I have access to this section of the A.I. mainframe…activating stored Spectres in the vicinity to fight for us
	//Bish:	Alright I have control over this section of the A.I. mainframe…let's activate some shiny metal friends to help us out, shall we?
	dialogAliases["hardpoint_player_captured_get_a_b"] = ["diag_hp_CapHpMIL_O2132_01_01_mcor_bish", "diag_hp_CapHpMIL_O2132_01_02_mcor_bish", "diag_hp_CapHpMIL_O2132_01_03_mcor_bish" ]
	dialogAliases["hardpoint_player_captured_get_a_c"] = ["diag_hp_CapHpMIL_O2132_01_01_mcor_bish", "diag_hp_CapHpMIL_O2132_01_02_mcor_bish", "diag_hp_CapHpMIL_O2132_01_03_mcor_bish" ]
	dialogAliases["hardpoint_player_captured_get_b_a"] = ["diag_hp_CapHpMIL_O2132_01_01_mcor_bish", "diag_hp_CapHpMIL_O2132_01_02_mcor_bish", "diag_hp_CapHpMIL_O2132_01_03_mcor_bish" ]
	dialogAliases["hardpoint_player_captured_get_b_c"] = ["diag_hp_CapHpMIL_O2132_01_01_mcor_bish", "diag_hp_CapHpMIL_O2132_01_02_mcor_bish", "diag_hp_CapHpMIL_O2132_01_03_mcor_bish" ]
	dialogAliases["hardpoint_player_captured_get_c_a"] = ["diag_hp_CapHpMIL_O2132_01_01_mcor_bish", "diag_hp_CapHpMIL_O2132_01_02_mcor_bish", "diag_hp_CapHpMIL_O2132_01_03_mcor_bish" ]
	dialogAliases["hardpoint_player_captured_get_c_b"] = ["diag_hp_CapHpMIL_O2132_01_01_mcor_bish", "diag_hp_CapHpMIL_O2132_01_02_mcor_bish", "diag_hp_CapHpMIL_O2132_01_03_mcor_bish" ]
	// dummy lines for the registering to work // not good
	// dummy lines for the registering to work // not good
	dialogAliases["hardpoint_player_captured_get_a_a"] = ["null_temp"]
	dialogAliases["hardpoint_player_captured_get_b_b"] = ["null_temp"]
	dialogAliases["hardpoint_player_captured_get_c_c"] = ["null_temp"]

	//---------------------------------------------------------
	// MILITIA capped hardpoint "We have all 3"
	//----------------------------------------------------------

	// Capturing 3 of 3
	//Bish:	Good work Pilot, we have control of all three hardpoints.
	//Bish:	Good work, we're controlling all three hardpoints.
	//Bish:	Alright! We're dominating all three hardpoints.
	dialogAliases["hardpoint_player_captured_a"] = ["diag_hp_CapAll_O2128_01_21_mcor_bish", "diag_hp_CapAll_O2128_01_22_mcor_bish", "diag_hp_CapAll_O2128_01_24_mcor_bish"]
	dialogAliases["hardpoint_player_captured_b"] = ["diag_hp_CapAll_O2128_01_21_mcor_bish", "diag_hp_CapAll_O2128_01_22_mcor_bish", "diag_hp_CapAll_O2128_01_24_mcor_bish"]
	dialogAliases["hardpoint_player_captured_c"] = ["diag_hp_CapAll_O2128_01_21_mcor_bish", "diag_hp_CapAll_O2128_01_22_mcor_bish", "diag_hp_CapAll_O2128_01_24_mcor_bish"]
}

function O2AIChatter()
{
	O2AddAIConversations( TEAM_MILITIA, level.actorsABCD )
	O2AddAIConversations( TEAM_IMC, level.actorsABCD )
}

function O2AddAIConversations( team, actors )
{
	//O2 specific lines
	Assert ( GetMapName() == "mp_o2" )
	local conversation = "o2_grunt_chatter"

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_o2_comment2L_01_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_o2_comment2L_01_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_o2_comment2L_02_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_o2_comment2L_02_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_o2_comment2L_03_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_o2_comment2L_03_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_o2_comment2L_04_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_o2_comment2L_04_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_o2_comment2L_05_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_o2_comment2L_05_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_o2_comment2L_06_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_o2_comment2L_06_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_o2_comment2L_07_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_o2_comment2L_07_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_o2_comment2L_08_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_o2_comment2L_08_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_o2_comment2L_09_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_o2_comment2L_09_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_o2_comment2L_10_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_o2_comment2L_10_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_o2_comment2L_11_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_o2_comment2L_11_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_o2_comment2L_12_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_o2_comment2L_12_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_o2_comment2L_13_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_o2_comment2L_13_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_o2_comment2L_14_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_o2_comment2L_14_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_o2_comment2L_15_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_o2_comment2L_15_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_o2_comment2L_16_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_o2_comment2L_16_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_o2_comment2L_17_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_o2_comment2L_17_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_o2_comment3L_01_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_o2_comment3L_01_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_o2_comment3L_01_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_o2_comment3L_02_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_o2_comment3L_02_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_o2_comment3L_02_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_o2_comment3L_03_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_o2_comment3L_03_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_o2_comment3L_03_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_o2_comment3L_04_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_o2_comment3L_04_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_o2_comment3L_04_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_o2_comment3L_05_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_o2_comment3L_05_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_o2_comment3L_05_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_o2_comment3L_06_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_o2_comment3L_06_02", actors )]}
		{ dialogType = "speech", speakerIndex = 2, choices = [Voices( team, "gs_o2_comment3L_06_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_o2_comment3L_07_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_o2_comment3L_07_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_o2_comment3L_07_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_o2_comment3L_08_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_o2_comment3L_08_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_o2_comment3L_08_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_o2_comment3L_09_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_o2_comment3L_09_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_o2_comment3L_09_03", actors )]}
	]
	AddConversation( conversation, team, lines )
}
