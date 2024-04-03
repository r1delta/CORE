function main()
{
	if ( !GetCinematicMode() )
		return

	if ( GAMETYPE != CAPTURE_POINT )
		return

	//----------------------------------------------
	// CINEMATIC MODE ONLY
	//----------------------------------------------

	CapturePointDialogOverride()

	RegisterConversation( "CorporateLostAnnouncement", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "CorporateWonAnnouncement", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "CorporateGameModeAnnounce_CP", VO_PRIORITY_GAMESTATE )

	//RegisterConversation( "CorporateIntroMilitia_01", VO_PRIORITY_GAMESTATE )
	//RegisterConversation( "CorporateIntroMilitia_02", VO_PRIORITY_GAMESTATE )

	//RegisterConversation( "CorporateIntroIMC_01", VO_PRIORITY_GAMESTATE )
	//RegisterConversation( "CorporateIntroIMC_02", VO_PRIORITY_GAMESTATE )

	RegisterConversation( "CorporateGroundIMC_01", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "CorporateGroundIMC_02", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "CorporateGroundIMC_03", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "CorporateGroundIMC_04", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "CorporateGroundIMC_05", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "CorporateGroundIMC_06", VO_PRIORITY_GAMESTATE )

	RegisterConversation( "GameOver10percent", VO_PRIORITY_STORY )
	RegisterConversation( "GameOver25percent", VO_PRIORITY_STORY )
	RegisterConversation( "GameOver50percent", VO_PRIORITY_STORY )
	RegisterConversation( "GameOver75percent", VO_PRIORITY_STORY )

	RegisterConversation( "CorpHardpointNeutralized", VO_PRIORITY_GAMESTATE )

	RegisterConversation( "hardpointFlavorLosing", VO_PRIORITY_PLAYERSTATE )

	//---------
	//Evac
	//---------
	RegisterConversation( "CorporateEpilogueStory", VO_PRIORITY_STORY )
	RegisterConversation( "losers_evac_post_evac", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "CorporateEpilogueStoryEnd", VO_PRIORITY_STORY )
	RegisterConversation( "EvacNagMilitaWon", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "EvacNagIMCWon", VO_PRIORITY_GAMESTATE )

	RegisterConversation( "corporate_grunt_chatter",	VO_PRIORITY_AI_CHATTER_LOW )


	if ( IsServer() )
		return

	CorporateAIChatter()


	/*----------------------------------------------------------------------------------
	/
	/				HARDPOINT NEUTRALIZED
	/
	/-----------------------------------------------------------------------------------*/
	local convRef

	//Bish:	Hardpoint neutralized. Preparing to access the Spectre mainframe
	//Bish:	I'm in…shutting down all enemy Spectres in range. Keep me connected while I take control.
	//Bish:	Neutralizing all hostile Spectres in the area…standby.

	AddVDULineForBish( "CorpHardpointNeutralized", "diag_hp_Neutralized_CR130_01_01_mcor_bish" )
	AddVDULineForBish( "CorpHardpointNeutralized", "diag_hp_Neutralized_CR130_01_02_mcor_bish" )
	AddVDULineForBish( "CorpHardpointNeutralized", "diag_hp_Neutralized_CR130_01_03_mcor_bish" )


	/*----------------------------------------------------------------------------------
	/
	/				DROPSHIP INTRO/GROUND DIALOGUE
	/
	/-----------------------------------------------------------------------------------*/

	//---------------------------------------
	// MILITIA - SELECT A RANDOM INTRO SPEECH
	//---------------------------------------

	//The IMC can no longer transport human forces to the Frontier fast enough to defeat us!
	//convRef = AddConversation( "CorporateIntroMilitia_01" )
	//AddVDURadio( convRef, "graves", "diag_matchIntro_CR213_01_01_mcor_graves" )

	//Graves: But what they have is an endless supply of Spectres, and we’re gonna put an end to it!
	//AddVDURadio( convRef, "graves", "diag_matchIntro_CR213_02_01_mcor_graves" )

	//SARAH:	Graves brought four Spectre platoons with him for our own use, and now we’re going to blow up the rest!
	//AddVDURadio( convRef, "sarah", "diag_matchIntro_CR213_03_01_mcor_sarah" )

	//SARAH:	MacAllan said we could trust this guy, and that’s good enough for me!
	//AddVDURadio( convRef, "sarah", "diag_matchIntro_CR213_04_01_mcor_sarah" )

	//GRAVES	I hope it’s good enough for all of you who knew him! Good luck!
	//AddVDURadio( convRef, "graves", "diag_matchIntro_CR213_05_01_mcor_graves" )

	//---------------------------------------
	// IMC - INTRO SPEECH
	//---------------------------------------

	//convRef = AddConversation( "CorporateIntroIMC_01", TEAM_IMC )

	//Spyglass:	Militia forces are using unauthorized remote terminals in an attempt to destroy the Spectre production line.
	//AddVDURadio( convRef, "spyglass", "diag_matchIntro_CR214_01_01_imc_spygl" )

	//Spyglass: Keep Blisk patched in and he will be able to pull Spectres off the racks to back you up down there.
	//AddVDURadio( convRef, "spyglass", "diag_matchIntro_CR214_02_01_imc_spygl" )

	//SPYGLASS:	Once we have control, all Spectre forces on the assembly line will be activated and the terrorists will have nowhere to run.
	//AddVDURadio( convRef, "spyglass", "diag_matchIntro_CR214_03_01_imc_spygl" )

	//BLISK:	They’re trying to activate all remaining Spectres in the facility to self-destruct and cripple our manufacturing.
	//AddVDURadio( convRef, "blisk", "diag_matchIntro_CR214_04_01_imc_blisk" )

	//BLISK:	Pilots, get in there and keep control of those hardpoints so we can activate all the Spectres in storage and drive these terrorists back.
	//AddVDURadio( convRef, "blisk", "diag_matchIntro_CR214_05_01_imc_blisk" )


	//---------------------------------------
	// IMC - SELECT A RANDOM GROUND LINE
	//---------------------------------------

	//IMC Captain Soldier	(radio pilot chatter) This is Mayhem 2-1, Spectres are active and engaging Militia forces…might want to stay out of their way.
	convRef = AddConversation( "CorporateGroundIMC_01", TEAM_IMC ) // only imc grunt event
	AddVDURadio( convRef, "imc2", "diag_hp_matchIntro_CR106A_01_01_imc_capt1" )

	//IMC Captain Soldier	(radio pilot chatter) This is Mayhem 2-1, first Spectre squad is on the ground and has made enemy contact…they’re tearing the militia a new one.
	convRef = AddConversation( "CorporateGroundIMC_02", TEAM_IMC ) // only imc grunt event
	AddVDURadio( convRef, "imc2", "diag_hp_matchIntro_CR106A_01_02_imc_capt1" )

	//IMC Captain Soldier	(radio pilot chatter) This is Mayhem 2-1, first Spectre squad is on the ground and raising hell.
	convRef = AddConversation( "CorporateGroundIMC_03", TEAM_IMC ) // only imc grunt event
	AddVDURadio( convRef, "imc2", "diag_hp_matchIntro_CR106A_01_03_imc_capt1" )

	//IMC Captain Soldier	(radio pilot chatter) This is Mayhem 2-1, I have visual on our Spectre ground forces...<short laugh> looks like they're taking down an enemy titan!
	convRef = AddConversation( "CorporateGroundIMC_04", TEAM_IMC ) // only imc grunt event
	AddVDURadio( convRef, "imc2", "diag_hp_matchIntro_CR106A_01_04_imc_capt1" )

	//IMC Captain Soldier	(radio pilot chatter) This is Mayhem 2-1, Spectre friendlies engaging an enemy Titan....he's going down. Viscious little bastards, glad they're on our side.
	convRef = AddConversation( "CorporateGroundIMC_05", TEAM_IMC ) // only imc grunt event
	AddVDURadio( convRef, "imc2", "diag_hp_matchIntro_CR106A_01_05_imc_capt1" )



	/*----------------------------------------------------------------------------------
	/
	/				GAME MODE ANNOUNCE DIALOGUE
	/
	/-----------------------------------------------------------------------------------*/

	//-----------
	// MILITIA
	//-----------

	//Bish:	This is a hardpoint mission. Taking the hardpoints will give us control of the facility and keep the IMC from activating every Spectre here. Once we have control, I'm detonating these things and crippling the facility.
	convRef = AddConversation( "CorporateGameModeAnnounce_CP" )
	AddVDURadio( convRef, "bish", null, "diag_hp_ModeAnnc_CR108_01_01_mcor_bish"  )


	/*----------------------------------------------------------------------------------
	/
	/				WINNING/LOSING STATUS DIALOGUE
	/
	/-----------------------------------------------------------------------------------*/

	//-----------
	// MILITIA
	//-----------

	//Bish:	We're doing great, keep it up. This place will be going up in flames soon!
	convRef = ReplaceConversation( "WinningScoreBigMarginMatchLate" )
	AddVDURadio( convRef, "bish", "diag_hp_milLeadGreat_matchLate_CR155_01_01_mcor_bish" )

	//Bish:	We're getting destroyed, pull it together. You do NOT want these Spectres fighting for the IMC
	convRef = ReplaceConversation( "LosingScoreBigMarginMatchLate" )
	AddVDURadio( convRef, "bish", "diag_hp_milTrailGreat_matchLate_CR156_01_01_mcor_bish" )

	//Bish:	We're winning, but just barely. Keep it up and we'll be able to turn this factory against them.
	convRef = ReplaceConversation( "WinningScoreSmallMarginMatchLate" )
	AddVDURadio( convRef, "bish", "diag_hp_milLeadSlight_matchLate_CR157_01_01_mcor_bish" )

	//Bish:	We're losing, but just barely. You need to push harder or every Spectre here is going to wake up angry.
	convRef = ReplaceConversation( "LosingScoreSmallMarginMatchLate" )
	AddVDURadio( convRef, "bish", "diag_hp_milTrailSlight_matchLate_CR158_01_01_mcor_bish" )


	/*----------------------------------------------------------------------------------
	/
	/				MATCH PROGRESS DIALOGUE (WINNING/LOSING)
	/
	/-----------------------------------------------------------------------------------*/

	//----------------------------
	// 10% OVER - MILITIA
	//----------------------------

	convRef = AddConversation( "GameOver10percent" )

	//GRAVES	Bish, I’d like to open a comm link to a private IMC channel.
	AddVDURadio( convRef, "graves", "diag_story10_CR201_01_01_mcor_graves" )

	//BISH	Uh, why would you do that, Commander?
	AddVDURadio( convRef, "bish", "diag_story10_CR201_02_01_mcor_bish" )

	//GRAVES	Why would I do it or why would I tell you about it?
	AddVDURadio( convRef, "graves", "diag_story10_CR201_03_01_mcor_graves" )

	//BISH	Um, I’ll take a little of both.
	AddVDURadio( convRef, "bish", "diag_story10_CR201_04_01_mcor_bish" )

	//GRAVES	I’m doing it cause there’s not too many actual humans left on that side. I’m telling you about it so you don’t get suspicious.
	AddVDURadio( convRef, "graves", "diag_story10_CR201_05_01_mcor_graves" )

	//BISH	Copy that. Trying to establish an open comm.
	AddVDURadio( convRef, "bish", "diag_story10_CR201_06_01_mcor_bish" )


	//----------------------------
	// 25% OVER - Militia and IMC
	//----------------------------
	convRef = AddConversation( "GameOver25percent" )

	//GRAVES	Blisk, this is Graves, can you hear me?
	//BLISK	What do you want?
	//GRAVES	I want to end the war.
	AddVDURadio( convRef, "graves", null, "diag_story20_CR203_01_01_both_graves" ) //VDU includes diag_story20_CR203_02_01_both_blisk and diag_story20_CR203_03_01_both_graves

	//BLISK	Yeah? Then fight harder. Maybe you will. Quickest way to end it is to wipe out everyone who stands against you.
	AddVDURadio( convRef, "blisk", null, "diag_story20_CR203_04_01_both_blisk" )


	//----------------------------
	// 50% OVER - Militia and IMC
	//----------------------------
	convRef = AddConversation( "GameOver50percent" )

	//GRAVES	We don’t have to be against each other, Blisk. It could be us against the machines.
	AddVDURadio( convRef, "graves", null, "diag_story20_CR203a_01_01_both_graves" )

	//BLISK	Then how we gonna ever know who’s better?
	AddVDURadio( convRef, "blisk", null, "diag_story20_CR203a_02_01_both_blisk" )

	//GRAVES	No person is better than another, Blisk.
	AddVDURadio( convRef, "graves", null, "diag_story20_CR203a_03_01_both_graves" )

	//BLISK	I disagree. You kill me, you’re better. I kill you, I’m better.
	AddVDURadio( convRef, "blisk", null, "diag_story20_CR203a_04_01_both_blisk" )



	//----------------------------
	// 75% OVER - Militia and IMC
	//----------------------------

	convRef = AddConversation( "GameOver75percent" )

	//GRAVES	Blisk, you fight alongside machines, but they believe in nothing. They have no loyalty. They’re loyal only to their operator.
	AddVDURadio( convRef, "graves", null, "diag_story20_CR204_01_01_both_graves" )

	//BLISK	You’re gonna lecture me about loyalty!? You change your uniform like you’re changing socks.
	AddVDURadio( convRef, "blisk", null, "diag_story20_CR204_02_01_both_blisk" )

	//GRAVES	In the end, against faceless machines and people like you who fight only for a paycheck, we will win.
	AddVDURadio( convRef, "graves", null, "diag_story20_CR204_03_01_both_graves" )

	//BLISK	(humorless, mean grin) I’ll fight you for free, Graves! Hope to find you on the ground soon.
	AddVDURadio( convRef, "blisk", null, "diag_story20_CR204_04_01_both_blisk" )


	/*----------------------------------------------------------------------------------
	/
	/				MILITA WON DIALOGUE - EPILOGUE START
	/
	/-----------------------------------------------------------------------------------*/

	//-----------
	// MILITIA
	//-----------

	convRef = AddConversation( "CorporateWonAnnouncement" )

	//BISH	We have control, I'm detonating these things and crippling the facility.
	AddVDURadio( convRef, "bish", null, "diag_milWinAnnc_CR205_01_01_mcor_bish" )

	AddVDUHide( convRef )

	AddWait( convRef, 1.5 )

	//SARAH	We’ve won! Intercept and take down any remaining IMC Pilots in the area!
	AddVDURadio( convRef, "sarah", "diag_milWinAnnc_CR205_02_01_mcor_sarah" )

	//GRAVES	And Pilots, there’s Spectres everywhere, so stay clear of the detonations!
	//AddVDURadio( convRef, "graves", "diag_milWinAnnc_CR205_03_01_mcor_graves" )

	//BISH	Yeah, these things pack a punch and they don’t care who they take with ‘em.
	//AddVDURadio( convRef, "bish", "diag_milWinAnnc_CR205_04_01_mcor_bish" )

	
	/*----------------------------------------------------------------------------------
	/
	/				IMC WON DIALOGUE - EPILOGUE START
	/
	/-----------------------------------------------------------------------------------*/

	//-----------
	// MILITIA
	//-----------
	convRef = AddConversation( "CorporateLostAnnouncement" )

	//BISH	Sarah, I’ve been locked out of the mainframe! They’ve got control of the remaining Spectres! Get our people outta there, now!
	AddVDURadio( convRef, "bish", "diag_milLoseAnnc_CR207_01_01_mcor_bish" )

	//SARAH	All Pilots, fall back to the evac site! Move!
	//AddVDURadio( convRef, "sarah", "diag_milLoseAnnc_CR207_02_01_mcor_sarah" )

	/*----------------------------------------------------------------------------------
	/
	/				MILITA WON DIALOGUE NAGS
	/
	/-----------------------------------------------------------------------------------*/

	//-----------
	// MILITIA
	//-----------
	//Sarah: Bish will handle blowing up the rest of this factory, you chase down any remaining ground forces to their evac point.
	convRef = AddConversation( "EvacNagMilitaWon" )
	AddWait( convRef, 2.5 )
	AddVDURadio( convRef, "sarah", "diag_hp_milWin_epNag_CR141_01_01_mcor_sarah" )


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
	AddVDURadio( convRef, "grunt", "diag_hp_milWin_epFlav_CR144_01_01_mcor_grunt1" )

	// --- OR ---

	convRef = AddConversation( "EvacNagIMCWon" )
	AddWait( convRef, 2 )
	//Sarah	Get to the evac point now! IMC has a whole robot army coming down on our heads and they’re suicide-running every Militia uniform they see.
	AddVDURadio( convRef, "sarah", "diag_hp_milWin_epNag_CR142_01_01_mcor_sarah" )


	/*----------------------------------------------------------------------------------
	/
	/				DIALOGUE EPILOGUE MID
	/
	/-----------------------------------------------------------------------------------*/



	//-----------
	// MILITIA
	//-----------
	convRef = AddConversation( "CorporateEpilogueStory" )
	//SARAH	It’s useless trying to reason with that side, Graves.
	AddVDURadio( convRef, "sarah", "diag_epMid_CR209_01_01_mcor_sarah" )

	//GRAVES	I was on that side. Worth a try.
	AddVDURadio( convRef, "graves", "diag_epMid_CR209_02_01_mcor_graves" )


	/*----------------------------------------------------------------------------------
	/
	/				DIALOGUE EPILOGUE END (BOTH SIDES HEAR
	/
	/-----------------------------------------------------------------------------------*/

	convRef = AddConversation( "CorporateEpilogueStoryEnd" )
	//SARAH:	This isn’t the end of the war, not by a long shot.
	AddVDURadio( convRef, "sarah", "diag_epPost_CR211_01_01_mcor_sarah" )
	//GRAVES:	No. It’s just the first battle of many. But for the first time, we can truly hope for victory.
	AddVDURadio( convRef, "graves", "diag_epPost_CR211_02_01_mcor_graves" )


	/*----------------------------------------------------------------------------------
	/
	/				AI HARDPOINT WINNING/LOSING CHATTER
	/
	/-----------------------------------------------------------------------------------*/

	//-----------
	// IMC
	//-----------

	//Doing this in "lost all hardpoints" global VO

	//not used
//	grunt1	(Radio) Enemy has activated Spectres at Alpha!	diag_spectresActivated_CR166_01_01_imc_grunt1
//	grunt1	(Radio) Enemy has activated Spectres at Bravo!	diag_spectresActivated_CR167_01_01_imc_grunt1
//	grunt1	(Radio) Enemy has activated Spectres at Charlie!	diag_spectresActivated_CR168_01_01_imc_grunt1

//	grunt1	(Radio) Enemy has activated Spectres at Alpha!	diag_spectresActivated_CR174_01_01_mcor_grunt1
//	grunt1	(Radio) Enemy has activated Spectres at Bravo!	diag_spectresActivated_CR175_01_01_mcor_grunt1
//	grunt1	(Radio) Enemy has activated Spectres at Charlie!	diag_spectresActivated_CR176_01_01_mcor_grunt1





	/*----------------------------------------------------------------------------------
	/
	/				AI CHATTER
	/
	/-----------------------------------------------------------------------------------*/

	//-----------
	// IMC
	//-----------

	/*
	Grunt_1	Damn terrorists are trying to turn our own Spectres against us	diag_imc_grunt1_gs_corpcommment_CR901_01
	Grunt_2	I’m more worried about these metal bastards replacing us!	diag_imc_grunt1_gs_corpcommment_CR901_02
	Grunt_1	There’s gotta be thousands of Spectres stored here	diag_imc_grunt1_gs_corpcommment_CR902_01
	Grunt_2	Let’s just make sure we activate them before the enemy does	diag_imc_grunt1_gs_corpcommment_CR902_02
	Grunt_1	Why the hell are the Militia stealing our Spectres anyway?	diag_imc_grunt1_gs_corpcommment_CR903_01
	Grunt_2	They’re running on fumes…they need more men but there’s only so many colonists they can recruit. 	diag_imc_grunt1_gs_corpcommment_CR903_02
	Grunt_1	Spectres ain’t so great. I hear Hammond’s son was working on something bigger	diag_imc_grunt1_gs_corpcommment_CR904_01
	Grunt_2	What, like smarter drones?	diag_imc_grunt1_gs_corpcommment_CR904_02
	Grunt_1	Nah some kind of synthetic biology work…next-gen shit	diag_imc_grunt1_gs_corpcommment_CR904_03
	Grunt_1	Why aren’t we deploying those new titans in the field?	diag_imc_grunt1_gs_corpcommment_CR905_01
	Grunt_2	Advanced prototypes, not stable enough for combat duty.	diag_imc_grunt1_gs_corpcommment_CR905_02
	Grunt_1	Last time I looked half our platoon was Spectres	diag_imc_grunt1_gs_corpcommment_CR906_01
	Grunt_2	They’re good at following orders, what do you expect?	diag_imc_grunt1_gs_corpcommment_CR906_02
	Grunt_1	I used to serve on Harmony with a whole platoon of Mark II’s. Things creeped me out. 	diag_imc_grunt1_gs_corpcommment_CR907_01
	Grunt_1	Graves wants to activate every single one of these things to take out the militia for good.	diag_imc_grunt1_gs_corpcommment_CR908_01
	Grunt_2	Yeah, well not if the terrorists activate them first.	diag_imc_grunt1_gs_corpcommment_CR908_02
	Grunt_1	I saw a malfunctioning Spectre strangle a guy with one hand. Took four guys to pull him off.	diag_imc_grunt1_gs_corpcommment_CR909_01
	Grunt_2	Old software on the Mark II’s . I hear they patched that bug.	diag_imc_grunt1_gs_corpcommment_CR909_02
	Grunt_1	I'm glad these spectres are on our side	diag_imc_grunt1_gs_corpcommment_CR910_01
	Grunt_2	Don’t forget the Terrorists can turn them with a data knife	diag_imc_grunt1_gs_corpcommment_CR910_02
	Grunt_1	Why would they build such sophisticated machines with a port that can easily be hacked?	diag_imc_grunt1_gs_corpcommment_CR911_01
	Grunt_2	Its to update their combat systems on the fly	diag_imc_grunt1_gs_corpcommment_CR911_02
	Grunt_1	Ohhh	diag_imc_grunt1_gs_corpcommment_CR911_03
	Grunt_2	Sometimes spectres need to be rebooted as well	diag_imc_grunt1_gs_corpcommment_CR911_04


	//-----------
	// MILITIA
	//-----------
	Grunt_1	Suicide drones aren’t too smart, but they’ll leave a mark if you get too close	diag_mcor_grunt1_gs_corpcommment_CR901_01
	Grunt_2	Apparently you can shoot them to keep ‘em from going super-nova	diag_mcor_grunt1_gs_corpcommment_CR901_02
	Grunt_1	Never seen so many damn Spectres in one place.	diag_mcor_grunt1_gs_corpcommment_CR902_01
	Grunt_2	Let’s just hope the IMC doesn’t get to wake them up	diag_mcor_grunt1_gs_corpcommment_CR902_02
	Grunt_1	So who’s this Hammond guy anyway?	diag_mcor_grunt1_gs_corpcommment_CR903_01
	Grunt_2	Man, don’t you read? Guy built the first Titan chassis…among like a million other things. He died years ago… now the whole place is owned by the IMC.	diag_mcor_grunt1_gs_corpcommment_CR903_02
	Grunt_1	Rumor is, Hammond was trying to figure out artificial humans. You know, like Spectres that can think?	diag_mcor_grunt1_gs_corpcommment_CR904_01
	Grunt_2	Yeah, right. How’d that work out for him?	diag_mcor_grunt1_gs_corpcommment_CR904_02
	Grunt_1	All I’m saying is we should get some intel while we’re here. See what they’re up to.	diag_mcor_grunt1_gs_corpcommment_CR904_03
	Grunt_1	What the hell were those flying Titans about? I didn’t know they could jump so high.	diag_mcor_grunt1_gs_corpcommment_CR905_01
	Grunt_2	Some advanced prototype. IMC always has the latest toys. Guess that’s why we’re trying to blow this place up. Even the playing field.	diag_mcor_grunt1_gs_corpcommment_CR905_02
	Grunt_1	All those sleeping Spectres freak me out.	diag_mcor_grunt1_gs_corpcommment_CR906_01
	Grunt_2	Yeah, well, If all goes according to plan, Bish will have them blowing themselves up in order to level this place for good.	diag_mcor_grunt1_gs_corpcommment_CR906_02
	Grunt_1	Brother used to work here, before it got taken over by the IMC. Working with Vektor now up at the F.O.B. 	diag_mcor_grunt1_gs_corpcommment_CR907_01
	Grunt_1	IMC is pissed we stole their Spectres, now they’re trying to activate every unholy robot here to wipe us out.	diag_mcor_grunt1_gs_corpcommment_CR908_01
	Grunt_2	Yeah, but not if Bish activates them first.	diag_mcor_grunt1_gs_corpcommment_CR908_02
	Grunt_1	I saw a Spectre punch a guy through the chest once.	diag_mcor_grunt1_gs_corpcommment_CR909_01
	Grunt_2	Things creep me out. I don’t even want them fighting for us	diag_mcor_grunt1_gs_corpcommment_CR909_02
	Grunt_1	These spectres are tough to kill	diag_mcor_grunt1_gs_corpcommment_CR910_01
	Grunt_2	Yeah, I guess that’s why Pilots just turn them	diag_mcor_grunt1_gs_corpcommment_CR910_02
	Grunt_1	Man, I wish I had one of those data-knifes they issue to Pilots	diag_mcor_grunt1_gs_corpcommment_CR911_01
	Grunt_2	Do you even know how to work one?	diag_mcor_grunt1_gs_corpcommment_CR911_02
	Grunt_1	Yeah, you just stick it in and magic...right?	diag_mcor_grunt1_gs_corpcommment_CR911_03
	Grunt_2	I don't think its that simple, plus those knives cost a fortune	diag_mcor_grunt1_gs_corpcommment_CR911_04

	*/


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
	//Bish:	All hardpoints are under enemy control! Take over those hardpoints or they’ll be able to activate the Spectres and wipe us off the map!
	//Bish:	Enemy has control of the hardpoints! We need to regain control or they're going to activate every Spectre in storage!
	//Bish:	IMC has all three hardpoints. If we don't get them back they'll turn every Spectre against us!
	//grunt1	(Radio) Enemy has too many Spectres! We're getting slaughtered out here!
	//grunt1	(Radio) We need to take over the terminals or we're going to get overrun!
	//grunt1	(Radio) Engaging another hostile Spectre squad…this things are everywhere!
	//grunt1	(Radio) Contact! Enemy Spectre squad is assaulting our position!
	//grunt1	(Radio) Hostile forces have activated multiple Spectre squads, we need to take those hardpoints!

	dialogAliases["hardpoint_lost_all"] = ["diag_hp_LostAll_CR127_01_01_mcor_bish",
										 "diag_hp_LostAll_CR127_01_02_mcor_bish",
										 "diag_hp_LostAll_CR127_01_03_mcor_bish",
										 "diag_spectresActivated_CR172_01_01_mcor_grunt1",
										 "diag_spectresActivated_CR173_01_01_mcor_grunt1",
										 "diag_spectresActivated_CR177_01_01_mcor_grunt1",
										 "diag_spectresActivated_CR178_01_01_mcor_grunt1",
										 "diag_spectresActivated_CR179_01_01_mcor_grunt1"]

	//---------------------------------------------------------
	// MILITIA capping hardpoint
	//----------------------------------------------------------

	// Starting cap from enemy controlled
	//Bish:	Stay close to the hardpoint while I patch into the Spectre mainframe.
	//Bish:	Keep close to the terminal while I try to gain access to the Spectre mainframe.
	//Bish:	Attempting to bypass security for all dormant Spectres…stay close to the terminal.
	dialogAliases["hardpoint_status_0_a"] = ["diag_hp_PatchedIn_CR129_01_01_mcor_bish", "diag_hp_PatchedIn_CR129_01_02_mcor_bish", "diag_hp_PatchedIn_CR129_01_03_mcor_bish" ]
	dialogAliases["hardpoint_status_0_b"] = ["diag_hp_PatchedIn_CR129_01_01_mcor_bish", "diag_hp_PatchedIn_CR129_01_02_mcor_bish", "diag_hp_PatchedIn_CR129_01_03_mcor_bish" ]
	dialogAliases["hardpoint_status_0_c"] = ["diag_hp_PatchedIn_CR129_01_01_mcor_bish", "diag_hp_PatchedIn_CR129_01_02_mcor_bish", "diag_hp_PatchedIn_CR129_01_03_mcor_bish" ]

	//Cap at 25%...generic short version only
	dialogAliases["hardpoint_status_25"] = "diag_hp_mcor_bish_generalpurpose_noprefix_03"

	//Cap at 50%...use custom dialogue here
	//Bish:	Spectre A.I. mainframe bypass at 50%
	//Bish:	50% bypass of local A.I. mainframe.
	//Bish:	50% bypass complete
	dialogAliases["hardpoint_status_50"] = ["null_temp"] // not used....no room for status with all the custom dialogue



	//Cap at 75%...
	dialogAliases["hardpoint_status_75"] = "diag_hp_mcor_bish_generalpurpose_noprefix_01"

	dialogAliases["hardpoint_status_100"] = ["null_temp"] // not used

	// Starting cap from neutral
	//Bish:	Alright, stay close to the hardpoint while I patch into the A.I. mainframe for all dormant Spectres.
	//Bish:	Keep close to the terminal while I gain access to the A.I. mainframe for all stored Spectres.
	//Bish:	Attempting to bypass security for all dormant Spectres…stay close to the terminal.
	dialogAliases["hardpoint_player_capping_a"] = ["diag_hp_PatchedIn_CR129_01_01_mcor_bish", "diag_hp_PatchedIn_CR129_01_02_mcor_bish", "diag_hp_PatchedIn_CR129_01_03_mcor_bish" ]
	dialogAliases["hardpoint_player_capping_b"] = ["diag_hp_PatchedIn_CR129_01_01_mcor_bish", "diag_hp_PatchedIn_CR129_01_02_mcor_bish", "diag_hp_PatchedIn_CR129_01_03_mcor_bish" ]
	dialogAliases["hardpoint_player_capping_c"] = ["diag_hp_PatchedIn_CR129_01_01_mcor_bish", "diag_hp_PatchedIn_CR129_01_02_mcor_bish", "diag_hp_PatchedIn_CR129_01_03_mcor_bish" ]

	// Continuing cap after neutralizing hardpoint
	//Bish:	Hardpoint neutralized. Preparing to access the A.I. mainframe
	//Bish:	I'm in…shutting down all enemy Spectres in range. Keep me connected while I take control.
	//Bish:	Neutralizing all hostile Spectres in the area…standby.
	dialogAliases["hardpoint_status_neutral_0_a"] = "null_temp"	//not used, trigering neutralization dialogue in main script
	dialogAliases["hardpoint_status_neutral_0_b"] = "null_temp"	//not used, trigering neutralization dialogue in main script
	dialogAliases["hardpoint_status_neutral_0_c"] = "null_temp"	//not used, trigering neutralization dialogue in main script



	//Cap at 25%...generic short version only
	dialogAliases["hardpoint_status_neutral_25"] = "diag_hp_mcor_bish_generalpurpose_noprefix_03"

	//Cap at 50%...use custom dialogue here
	//Bish:	Spectre mainframe bypass at 50%
	//Bish:	50% bypass of Spectre mainframe.
	//Bish:	50% bypass complete

	dialogAliases["hardpoint_status_neutral_50"] = ["diag_hp_CapProg_MIL50_CR131_01_01_mcor_bish", "diag_hp_CapProg_MIL50_CR131_01_02_mcor_bish", "diag_hp_CapProg_MIL50_CR131_01_03_mcor_bish"]

	//Cap at 75%...generic short version only
	dialogAliases["hardpoint_status_neutral_75"] = "diag_hp_mcor_bish_datagrabprogress_03"

	dialogAliases["hardpoint_status_neutral_100"] =["null_temp"] // not used


	//-------------------------------------------
	// MILITIA capped hardpoint
	//-------------------------------------------

	// Capturing 1 of 3
	//Bish:	Good work. I’ve locked down this section. Activating Spectres near the hardpoint to help you out.
	//Bish:	Right on. I have access to this section of the mainframe…activating Spectres in the vicinity to fight for us
	//Bish:	Alright I have control over this section of the mainframe…let's activate some shiny metal friends to help us out, shall we?

	dialogAliases["hardpoint_player_captured_get_ac"] = ["diag_hp_CapHpMIL_CR132_01_01_mcor_bish", "diag_hp_CapHpMIL_CR132_01_02_mcor_bish", "diag_hp_CapHpMIL_CR132_01_03_mcor_bish" ]
	dialogAliases["hardpoint_player_captured_get_bc"] = ["diag_hp_CapHpMIL_CR132_01_01_mcor_bish", "diag_hp_CapHpMIL_CR132_01_02_mcor_bish", "diag_hp_CapHpMIL_CR132_01_03_mcor_bish" ]
	dialogAliases["hardpoint_player_captured_get_ab"] = ["diag_hp_CapHpMIL_CR132_01_01_mcor_bish", "diag_hp_CapHpMIL_CR132_01_02_mcor_bish", "diag_hp_CapHpMIL_CR132_01_03_mcor_bish" ]

	// Capturing 2 of 3
	//Bish:	Good work. I’ve locked down this portion of the Spectre A.I. mainframe. Activating dormant Spectres near the hardpoint to help you out.
	//Bish:	Right on. I have access to this section of the A.I. mainframe…activating stored Spectres in the vicinity to fight for us
	//Bish:	Alright I have control over this section of the A.I. mainframe…let's activate some shiny metal friends to help us out, shall we?
	dialogAliases["hardpoint_player_captured_get_a_b"] = ["diag_hp_CapHpMIL_CR132_01_01_mcor_bish", "diag_hp_CapHpMIL_CR132_01_02_mcor_bish", "diag_hp_CapHpMIL_CR132_01_03_mcor_bish" ]
	dialogAliases["hardpoint_player_captured_get_a_c"] = ["diag_hp_CapHpMIL_CR132_01_01_mcor_bish", "diag_hp_CapHpMIL_CR132_01_02_mcor_bish", "diag_hp_CapHpMIL_CR132_01_03_mcor_bish" ]
	dialogAliases["hardpoint_player_captured_get_b_a"] = ["diag_hp_CapHpMIL_CR132_01_01_mcor_bish", "diag_hp_CapHpMIL_CR132_01_02_mcor_bish", "diag_hp_CapHpMIL_CR132_01_03_mcor_bish" ]
	dialogAliases["hardpoint_player_captured_get_b_c"] = ["diag_hp_CapHpMIL_CR132_01_01_mcor_bish", "diag_hp_CapHpMIL_CR132_01_02_mcor_bish", "diag_hp_CapHpMIL_CR132_01_03_mcor_bish" ]
	dialogAliases["hardpoint_player_captured_get_c_a"] = ["diag_hp_CapHpMIL_CR132_01_01_mcor_bish", "diag_hp_CapHpMIL_CR132_01_02_mcor_bish", "diag_hp_CapHpMIL_CR132_01_03_mcor_bish" ]
	dialogAliases["hardpoint_player_captured_get_c_b"] = ["diag_hp_CapHpMIL_CR132_01_01_mcor_bish", "diag_hp_CapHpMIL_CR132_01_02_mcor_bish", "diag_hp_CapHpMIL_CR132_01_03_mcor_bish" ]
	// dummy lines for the registering to work // not good
	// dummy lines for the registering to work // not good
	dialogAliases["hardpoint_player_captured_get_a_a"] = ["null_temp"]
	dialogAliases["hardpoint_player_captured_get_b_b"] = ["null_temp"]
	dialogAliases["hardpoint_player_captured_get_c_c"] = ["null_temp"]

	//---------------------------------------------------------
	// MILITIA capped hardpoint "We have all 3"
	//----------------------------------------------------------

	// Capturing 3 of 3
	//Bish:	We have control of all three hardpoints. Keep it up and we’ll have every Spectre on the assembly line set to self-destruct.  Then we can take out this factory for good.
	//Bish:	Good work, we're controlling all three hardpoints. I'm trying to reprogram the Spectres to self-destruct and take out this facility once and for all.
	//Bish:	Alright! We're dominating all three hardpoints. Keep it up and I'll have every one of these metal abominations re-wired for self-destruct!
	dialogAliases["hardpoint_player_captured_a"] = ["diag_hp_CapAll_CR128_01_01_mcor_bish", "diag_hp_CapAll_CR128_01_02_mcor_bish", "diag_hp_CapAll_CR128_01_04_mcor_bish"]
	dialogAliases["hardpoint_player_captured_b"] = ["diag_hp_CapAll_CR128_01_01_mcor_bish", "diag_hp_CapAll_CR128_01_02_mcor_bish", "diag_hp_CapAll_CR128_01_04_mcor_bish"]
	dialogAliases["hardpoint_player_captured_c"] = ["diag_hp_CapAll_CR128_01_01_mcor_bish", "diag_hp_CapAll_CR128_01_02_mcor_bish", "diag_hp_CapAll_CR128_01_04_mcor_bish"]
}

function CorporateAIChatter()
{
	CorporateAddAIConversations( TEAM_MILITIA, level.actorsABCD )
	CorporateAddAIConversations( TEAM_IMC, level.actorsABCD )
}

function CorporateAddAIConversations( team, actors )
{
	//Corporate specific lines
	Assert ( GetMapName() == "mp_corporate" )
	local conversation = "corporate_grunt_chatter"

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CR_comment2L_01_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CR_comment2L_01_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CR_comment2L_02_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CR_comment2L_02_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CR_comment2L_03_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CR_comment2L_03_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CR_comment2L_04_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CR_comment2L_04_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CR_comment2L_05_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CR_comment2L_05_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CR_comment2L_06_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CR_comment2L_06_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CR_comment2L_07_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CR_comment2L_07_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CR_comment2L_08_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CR_comment2L_08_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CR_comment2L_09_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CR_comment2L_09_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CR_comment2L_10_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CR_comment2L_10_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CR_comment2L_11_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CR_comment2L_11_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CR_comment2L_12_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CR_comment2L_12_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CR_comment2L_13_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CR_comment2L_13_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CR_comment3L_01_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CR_comment3L_01_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CR_comment3L_01_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CR_comment3L_02_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CR_comment3L_02_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CR_comment3L_02_03", actors )]}
	]
	AddConversation( conversation, team, lines )


	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CR_comment3L_03_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CR_comment3L_03_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CR_comment3L_03_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CR_comment3L_04_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CR_comment3L_04_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CR_comment3L_04_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CR_comment3L_05_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CR_comment3L_05_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CR_comment3L_05_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CR_comment3L_06_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CR_comment3L_06_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CR_comment3L_06_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CR_comment3L_07_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CR_comment3L_07_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CR_comment3L_07_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CR_comment3L_08_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CR_comment3L_08_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CR_comment3L_08_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CR_comment3L_09_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CR_comment3L_09_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CR_comment3L_09_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CR_comment3L_10_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CR_comment3L_10_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CR_comment3L_10_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CR_comment3L_11_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CR_comment3L_11_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CR_comment3L_11_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CR_comment3L_12_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CR_comment3L_12_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CR_comment3L_12_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CR_comment4L_01_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CR_comment4L_01_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CR_comment4L_01_03", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CR_comment4L_01_04", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CR_comment4L_02_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CR_comment4L_02_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_CR_comment4L_02_03", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_CR_comment4L_02_04", actors )]}
	]
	AddConversation( conversation, team, lines )
}