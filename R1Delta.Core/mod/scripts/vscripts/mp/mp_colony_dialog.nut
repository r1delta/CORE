function main()
{
	RegisterConversation( "ColonyGameModeAnnounce_AT", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "ColonyLostAnnouncement", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "ColonyWonAnnouncement", VO_PRIORITY_GAMESTATE )

	//RegisterConversation( "IntroDropshipMilitia", VO_PRIORITY_GAMESTATE )
	//RegisterConversation( "IntroDropshipIMC", VO_PRIORITY_GAMESTATE )

	RegisterConversation( "IntroGroundIMCstart", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "IntroGroundMilitiaMoveUp", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "IntroGroundMilitiaFightStart", VO_PRIORITY_GAMESTATE )

	RegisterConversation( "ColonyEpilogueStory", VO_PRIORITY_STORY )
	//RegisterConversation( "ColonyEpilogueStoryEnd", VO_PRIORITY_GAMESTATE )

	RegisterConversation( "match_progress_15_percent",	VO_PRIORITY_STORY )
	RegisterConversation( "match_progress_40_percent",	VO_PRIORITY_STORY )
	RegisterConversation( "match_progress_60_percent",	VO_PRIORITY_STORY )
	RegisterConversation( "match_progress_80_percent",	VO_PRIORITY_STORY )

	RegisterConversation( "colony_grunt_chatter",	VO_PRIORITY_AI_CHATTER_LOW )


	if ( IsServer() )
		return

	ColonyAIChatter()

	local convRef


	/*----------------------------------------------------------------------------------
	/
	/				INTRO DROPSHIP - MILITIA
	/
	/-----------------------------------------------------------------------------------*/
	/*
	Playing attached to dropship now in main script

	convRef = AddConversation( "IntroDropshipMilitia" )

	//Bish, start playback
	AddVDURadio( convRef, "bish", "diag_matchIntro_CY101a_01_01_mcor_sarah" )

	//Radio (start with SOS beeps, then dialogue with fighting noises in background and Spectre sounds)
	//(beep) Mayday mayday, we are a small (garble garble) colony on planet Troy.
	//(garble garble) under attack from IMC forces (garble garble) need immediate assistance.
	//Please send help. Embedding coordinates.” (repeats 1.5x before being switched off with a ‘click’)
	AddVDURadio( convRef, "civilian", "diag_matchIntro_CY101_01_01_mcor_civi1" )

	AddWait( convRef, 0.5 )

	//Bish	That distress call was four hours old.
	// Ok…first squad on the ground, they have eyes on the distress signal coordinates.
	AddVDURadio( convRef, "bish", "diag_matchIntro_CY101_02_01_mcor_bish" )

	//Sarah	What do you see 3-2? Anything by the tower?
	AddVDURadio( convRef, "sarah", "diag_matchIntro_CY101_03_01_mcor_sarah" )

	AddWait( convRef, 0.5 )

	//Grunt	(radio) Nothing. The tower looks abandoned. We got dead colonists in the streets. No sign of the others.
	AddVDURadio( convRef, "grunt", "diag_matchIntro_CY101_04_01_mcor_grunt1" )

	//Sarah	Got it. Pilots, let’s find out what the hell happened here. Fan out through the village and we’ll meet up at the south gate. Be careful down there.
	AddVDURadio( convRef, "sarah", "diag_matchIntro_CY101_05_01_mcor_sarah" )

	*/
	/*----------------------------------------------------------------------------------
	/
	/				INTRO DROPSHIP - IMC
	/
	/-----------------------------------------------------------------------------------*/

	/*
	Playing attached to dropship now in main script

	//Blisk	- I like the way these Spectres kill.  Next-gen automated infantry’s the future.
	convRef = AddConversation( "IntroDropshipIMC", TEAM_IMC )
	AddVDURadio( convRef, "blisk", "diag_matchIntro_CY102_01_01_imc_blisk" )

	AddWait( convRef, 2.25 )

	//Graves	Wiping out this second-rate terrorist camp was barely a test.
	// Fighting veteran Pilots is a whole other story, Blisk.
	AddVDURadio( convRef, "graves", "diag_matchIntro_CY102_02_01_imc_graves" )

	//Blisk 	Good. That’s why they keep us around, eh?
	AddVDURadio( convRef, "blisk ", "diag_matchIntro_CY102_02a_01_imc_blisk" )


	AddWait( convRef, 1.5 )

	//Pilot Radio	Sir! It looks like Militia ships! They’re deploying ground forces at the north end of the village.
	AddVDURadio( convRef, "grunt", "diag_matchIntro_CY102_03_01_imc_tpilot1" )

	//Blisk	Now that’s a real threat. Perhaps it’s time to start Phase Two.
	AddVDURadio( convRef, "blisk", "diag_matchIntro_CY102_04_01_imc_blisk" )

	//Graves	Agreed. Activate 3 more racks of Spectres - let’s see how they do in a real fight.
	AddVDURadio( convRef, "graves", "diag_matchIntro_CY102_05_01_imc_graves" )

	//Blisk	Yes sir. Deploying additional Spectres at the south gate.
	AddVDURadio( convRef, "blisk", "diag_matchIntro_CY102_06_01_imc_blisk" )

	*/

	/*----------------------------------------------------------------------------------
	/
	/				GROUND INTRO - MILITIA
	/
	/-----------------------------------------------------------------------------------*/
	convRef = AddConversation( "IntroGroundMilitiaMoveUp" )
	//Grunt 2	First squad, move up
	AddVDURadio( convRef, "grunt", "diag_matchIntro_CY103_01_01_mcor_grunt2" )

	convRef = AddConversation( "IntroGroundMilitiaFightStart" )
	//Grunt 2	Spectres! Open fire!
	AddVDURadio( convRef, "grunt", "diag_matchIntro_CY103_03_01_mcor_grunt2" )

	AddWait( convRef, 2.5 )

	//Grunt 3 Radio	(radio) This is Wildcard 3-2, we’ve made contact with the enemy. Some new generation of automated combat troop! These things are everywhere!
	AddVDURadio( convRef, "grunt", "diag_matchIntro_CY103_04_01_mcor_grunt3" )

	//Pilot radio	(radio) Copy that, 3-2. Sending in additional dropships, ETA, 30 seconds.
	AddVDURadio( convRef, "pilot", "diag_matchIntro_CY103_05_01_mcor_tpilot1" )

	/*----------------------------------------------------------------------------------
	/
	/				GROUND INTRO - IMC
	/
	/-----------------------------------------------------------------------------------*/
	convRef = AddConversation( "IntroGroundIMCstart", TEAM_IMC ) // only imc grunt event
	//Grunt 1	Get those other Spectres online, we’ve got Militia pilots moving in from the east.
	AddVDURadio( convRef, "grunt", "diag_matchIntro_CY104_01_01_imc_grunt1" )

	//Grunt 2	Charlie Squad is still rounding up colonists.
	AddVDURadio( convRef, "grunt", "diag_matchIntro_CY104_02_01_imc_grunt2" )

	//Grunt 1	Well tell those metal bastards to wrap it up, we’ve got bigger fish to fry
	AddVDURadio( convRef, "grunt", "diag_matchIntro_CY104_03_01_imc_grunt1" )

	//Grunt 2	Copy that.
	AddVDURadio( convRef, "grunt", "diag_matchIntro_CY104_04_01_imc_grunt2" )

	/*----------------------------------------------------------------------------------
	/
	/				CUSTOM GAME MODE ANNOUNCEMENTS - ATTRITION
	/
	/-----------------------------------------------------------------------------------*/

	//-----------
	// MILITIA
	//-----------
	convRef = AddConversation( "ColonyGameModeAnnounce_AT" )
	//Sarah	Pilot, this is no longer a search and rescue! Get ready for a battle of attrition. Kill ‘em all. Bish, access the logs on that distress beacon, I want to know what happened here.
	AddVDURadio( convRef, "sarah", null, "diag_ModeAnnc_CY105_01_01_mcor_sarah" )


	/*----------------------------------------------------------------------------------
	/
	/				MATCH PROGRESS STORY DIALOGUE - 15%
	/
	/-----------------------------------------------------------------------------------*/

	//-----------
	// MILITIA
	//-----------
	convRef = AddConversation( "match_progress_15_percent" )
	//Sarah	Bish, any progress on tracking the remaining colonists?
	AddVDURadio( convRef, "sarah", "diag_MatchProg_MIL01_CY107_01_01_mcor_sarah" )

	//Bish	I’m picking up an incoming transmission, but it’s garbled. Give me some time to clean it up.
	AddVDURadio( convRef, "bish", "diag_MatchProg_MIL01_CY107_02_01_mcor_bish" )


	/*----------------------------------------------------------------------------------
	/
	/				MATCH PROGRESS STORY DIALOGUE - 40%
	/
	/-----------------------------------------------------------------------------------*/

	//-----------
	// MILITIA
	//-----------
	convRef = AddConversation( "match_progress_40_percent" )
	//Bish	I’ve decoded an incoming transmission. Can’t quite make it out. Voice only.
	AddVDURadio( convRef, "bish", "diag_MatchProg_MIL02_CY109_01_01_mcor_bish" )

	//Sarah	Play the transmission.
	AddVDURadio( convRef, "sarah", "diag_MatchProg_MIL02_CY109_02_01_mcor_sarah" )

	//MacAllan	<garbled and static> have found our little corner of the universe…
	//<garbled and static>… we are not ‘terrorists’, we’re not a part of your damn war
	//<garbled and static> We’re falling back to <garbled and static> <garbled and static>
	//if you can hear me, run, do not engage the IMC, they can’t be reasoned with…
	AddVDURadio( convRef, "mac", "diag_MatchProg_MIL02_CY109_03_01_mcor_macal" )

	//Sarah - Bish, clean it up and find out where the remaining colonists went.
	AddVDURadio( convRef, "sarah", "diag_MatchProg_MIL02_CY109_04_01_mcor_sarah" )

	//Bish - Got it.
	AddVDURadio( convRef, "bish", "diag_MatchProg_MIL02_CY109_05_01_mcor_bish" )


	/*----------------------------------------------------------------------------------
	/
	/				MATCH PROGRESS STORY DIALOGUE - 60%
	/
	/-----------------------------------------------------------------------------------*/

	//-----------
	// MILITIA
	//-----------
	convRef = AddConversation( "match_progress_60_percent" )

	//SARAH	Bish, gimme a status update!
	AddVDURadio( convRef, "sarah", "diag_MatchProg_MIL03_CY115_01_01_mcor_sarah" )

	//BISH	Still working on decrypting the full transmission. Here’s what I’ve got.
	AddVDURadio( convRef, "bish", "diag_MatchProg_MIL03_CY115_02_01_mcor_bish" )

	//MacAllan	…we’re falling back to higher ground…carrier…Odyssey is…
	// MacAllan: (garble garble) …we’re falling back to higher ground…carrier…Odyssey is…
	AddVDURadio( convRef, "mac", "diag_MatchProg_MIL03_CY115_03_01_mcor_macal" )

	//BISH	I know that voice – I’ve heard it somewhere before. I’m gonna run voice analysis, it’s gonna take a little more time.
	AddVDURadio( convRef, "bish", "diag_MatchProg_MIL03_CY115_04_01_mcor_bish" )


	/*----------------------------------------------------------------------------------
	/
	/				MATCH PROGRESS STORY DIALOGUE - 80%
	/
	/-----------------------------------------------------------------------------------*/

	//-----------
	// MILITIA
	//-----------
	convRef = AddConversation( "match_progress_80_percent" )

	//BISH	Sarah, I got a positive ID, but it doesn’t make any sense… This guy fell off the radar 15 years ago.
	AddVDURadio( convRef, "bish", null, "diag_MatchProg_MIL04_CY117_01_01_mcor_bish" )

	//SARAH	Spit it out, Bish, we’re running outta time.
	AddVDURadio( convRef, "sarah", null, "diag_MatchProg_MIL04_CY117_02_01_mcor_sarah" )

	//BISH	His name’s MacAllan. He was already a legend when I was just a rookie – only not on our side.
	AddVDURadio( convRef, "bish", null, "diag_MatchProg_MIL04_CY117_03_01_mcor_bish" )

	//SARAH:	All right, find out where he’s transmitting from.
	AddVDURadio( convRef, "sarah", null, "diag_MatchProg_MIL04_CY117_04_01_mcor_sarah" )


	/*----------------------------------------------------------------------------------
	/
	/				MILITA WON DIALOGUE - EPILOGUE START
	/
	/-----------------------------------------------------------------------------------*/

	//-----------
	// MILITIA
	//-----------
	//Bish	Good job, Pilot. We kicked their asses! Don’t let ‘em get to their evac point. I almost have a fix on the location of the survivors.
	convRef = AddConversation( "ColonyWonAnnouncement" )
	AddVDURadio( convRef, "bish", null, "diag_milWinAnnc_CY111_03_01_mcor_bish"  )


	/*----------------------------------------------------------------------------------
	/
	/				IMC WON DIALOGUE - EPILOGUE START
	/
	/-----------------------------------------------------------------------------------*/

	//-----------
	// MILITIA
	//-----------
	//Bish	Guys, we’ve lost this one but it’s not over yet. Get to the evac point. I’m working on the location of the survivors.
	convRef = AddConversation( "ColonyLostAnnouncement" )
	AddVDURadio( convRef, "bish", "diag_milLoseAnnc_CY111_02_01_mcor_bish" )

	/*----------------------------------------------------------------------------------
	/
	/		EPILOGUE STORY CONVERSATIONS
	/
	/-----------------------------------------------------------------------------------*/

	//-----------
	// MILITIA
	//-----------

	convRef = AddConversation( "ColonyEpilogueStory" )

	//Bish - Sarah, I’ve pinpointed the source of the transmission! Channel's open.
	AddVDURadio( convRef, "bish", "diag_epilogueMid_CY112_01_01_mcor_bish" )

	AddWait( convRef, 1 )

	//Sarah	To whoever’s on this channel, identify yourself!
	AddVDURadio( convRef, "sarah", "diag_epilogueMid_CY112_01a_01_mcor_sarah" )

	//MacAllan		Never mind who this is! They were tracking youand they found us instead. Damn Militia… 
	AddVDURadio( convRef, "mac", null, "diag_epilogueMid_CY112_02a_01_mcor_macal" )

	// macallan: We didn’t want any part of your war so you brought it to our doorstep?!  Those were civilians getting slaughtered!
	AddVDURadio( convRef, "mac", null, "diag_epilogueMid_CY112_02_01_mcor_macal" )

	//Sarah		We came to answer your distress signal! I repeat, identify yourself!
	AddVDURadio( convRef, "sarah", null, "diag_epilogueMid_CY112_03_01_mcor_sarah" )

	//MacAllan		This is James MacAllan, formerly of the IMC! You wanna help? You come and get me. (pause) I have a lot of survivors here that need an evac. (slams the phone down)
	AddVDURadio( convRef, "mac", null, "diag_epilogueMid_CY112_04_01_mcor_macal" )
	
	AddVDUHide( convRef )
	
	AddWait( convRef, 0.5 )
	
	//Bish: Hold on - I'm getting IMC Command on this frequency.
	AddVDURadio( convRef, "bish", "diag_epilogueMid_CY113a_02_01_mcor_bish" )

	AddWait( convRef, 1 )

	//Graves	You should have stayed gone, MacAllan.
	AddVDURadio( convRef, "graves", null, "diag_epiloguePost_CY119_01_01_imc_graves" )

	//MacAllan	Graves – you’re still on the wrong side, aren’t you?
	AddVDURadio( convRef, "mac", null, "diag_epiloguePost_CY119_02_01_mcor_macal" )

	//Graves	We’re soldiers, Mac. You’re dreaming if you think you can sit it out.
	AddVDURadio( convRef, "graves", null, "diag_epiloguePost_CY119_03_01_imc_graves" )

	//MacAllan	I’m awake now, you son of a bitch.
	AddVDURadio( convRef, "mac", null, "diag_epiloguePost_CY119_04_01_mcor_macal" )
}

function ColonyAIChatter()
{
	ColonyAddAIConversations( TEAM_MILITIA, level.actorsABCD )
	ColonyAddAIConversations( TEAM_IMC, level.actorsABCD )
}

function ColonyAddAIConversations( team, actors )
{
	//Relic specific lines
	Assert ( GetMapName() == "mp_colony" )
	local conversation = "colony_grunt_chatter"

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CY_comment2L_01_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CY_comment2L_01_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CY_comment2L_02_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CY_comment2L_02_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CY_comment2L_03_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CY_comment2L_03_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CY_comment2L_04_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CY_comment2L_04_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CY_comment2L_05_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CY_comment2L_05_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CY_comment2L_06_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CY_comment2L_06_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CY_comment2L_07_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CY_comment2L_07_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CY_comment2L_08_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CY_comment2L_08_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CY_comment2L_09_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CY_comment2L_09_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CY_comment2L_10_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CY_comment2L_10_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CY_comment2L_11_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CY_comment2L_11_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CY_comment3L_01_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CY_comment3L_01_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CY_comment3L_01_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CY_comment3L_02_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CY_comment3L_02_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CY_comment3L_02_03", actors )]}
	]
	AddConversation( conversation, team, lines )


	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CY_comment3L_03_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CY_comment3L_03_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CY_comment3L_03_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CY_comment3L_04_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CY_comment3L_04_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CY_comment3L_04_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CY_comment3L_05_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CY_comment3L_05_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CY_comment3L_05_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CY_comment3L_06_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CY_comment3L_06_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CY_comment3L_06_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CY_comment3L_07_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CY_comment3L_07_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CY_comment3L_07_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CY_comment3L_08_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CY_comment3L_08_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CY_comment3L_08_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CY_comment3L_09_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CY_comment3L_09_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CY_comment3L_09_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CY_comment3L_10_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CY_comment3L_10_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CY_comment3L_10_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CY_comment3L_11_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CY_comment3L_11_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CY_comment3L_11_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CY_comment4L_01_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CY_comment4L_01_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CY_comment4L_01_03", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CY_comment4L_01_04", actors )]}
	]
	AddConversation( conversation, team, lines )
}