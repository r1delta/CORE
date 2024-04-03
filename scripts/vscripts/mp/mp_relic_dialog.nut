function main()
{
	RegisterConversation( "matchIntro",				VO_PRIORITY_GAMESTATE )

	RegisterConversation( "matchIntroMilitiaMac",	VO_PRIORITY_GAMESTATE )

	RegisterConversation( "modeAnnc_attrition",		VO_PRIORITY_GAMESTATE )

	RegisterConversation( "groundIntro",			VO_PRIORITY_GAMESTATE )


	RegisterConversation( "matchProg_MIL01",		VO_PRIORITY_GAMESTATE )
	RegisterConversation( "matchProg_MIL02",		VO_PRIORITY_GAMESTATE )
	RegisterConversation( "matchProg_MIL03",		VO_PRIORITY_GAMESTATE )
	RegisterConversation( "matchProg_MIL04",		VO_PRIORITY_GAMESTATE )

	RegisterConversation( "matchProg_IMC01",		VO_PRIORITY_GAMESTATE )
	RegisterConversation( "matchProg_IMC02",		VO_PRIORITY_GAMESTATE )
	RegisterConversation( "matchProg_IMC03",		VO_PRIORITY_GAMESTATE )
	RegisterConversation( "matchProg_IMC04",		VO_PRIORITY_GAMESTATE )

	RegisterConversation( "matchWin",				VO_PRIORITY_GAMESTATE )
	RegisterConversation( "matchLoss",				VO_PRIORITY_GAMESTATE )

	RegisterConversation( "epilogue_mid",			VO_PRIORITY_GAMESTATE )

	RegisterConversation( "post_epilogue_win",		VO_PRIORITY_GAMESTATE )
	RegisterConversation( "post_epilogue_loss",		VO_PRIORITY_GAMESTATE )

	RegisterConversation( "EarlyProgressWinning",	VO_PRIORITY_GAMEMODE )
	RegisterConversation( "MidProgressWinning",		VO_PRIORITY_GAMEMODE )
	RegisterConversation( "LateProgressWinning",	VO_PRIORITY_GAMEMODE )

	RegisterConversation( "EarlyProgressLosing",	VO_PRIORITY_GAMEMODE )
	RegisterConversation( "MidProgressLosing",		VO_PRIORITY_GAMEMODE )
	RegisterConversation( "LateProgressLosing",		VO_PRIORITY_GAMEMODE )

	// dev menu
	RegisterConversation( "BliskTest1",				VO_PRIORITY_GAMESTATE )
	RegisterConversation( "MacTest1",				VO_PRIORITY_GAMESTATE )
	RegisterConversation( "MacTest2",				VO_PRIORITY_GAMESTATE )
	RegisterConversation( "MacTest3",				VO_PRIORITY_GAMESTATE )

	//AI Chatter
	RegisterConversation( "relic_grunt_chatter",	VO_PRIORITY_AI_CHATTER_LOW )
	RegisterConversation( "relic_grunt_chatter_engine_starting",	VO_PRIORITY_AI_CHATTER_LOW )

	if ( IsServer() )
		return

	Globalize( CustomRelicVDU )
	Globalize( EngineStartupVDUThread )
	Globalize( EnginePlungeVDUThread )
	Globalize( MacAllanEndPickupVDUThread )

	RelicAIChatter()
	RelicIMCDialog()
	RelicMilitiaDialog()

	AddCreateCallback( "mac", MacAllanCreated )

	// dev menu
	AddCustomVDUFunction( AddConversation( "BliskTest1", 3 ), CustomBliskVDU_1 )
	AddCustomVDUFunction( AddConversation( "MacTest1", 3 ), CustomMacAllanVDU_1 )
	AddCustomVDUFunction( AddConversation( "MacTest2", 3 ), CustomMacAllanVDU_4 )
	AddCustomVDUFunction( AddConversation( "MacTest3", 3 ), CustomMacAllanVDU_5 )
}

if ( IsServer() )
	return

///////////////////////////////////////////////////////////////////
function RelicMilitiaDialog()
{
	local convRef

	// PROGRESS Announcements
	// early winning
	AddVDULineForBish( "EarlyProgressWinning",	"diag_matchProgWinning_RC301_01_01_mcor_bish" )
	// early losing
	AddVDULineForBish( "EarlyProgressLosing",	"diag_matchProgLosing_RC302_01_01_mcor_bish" )

	// mid winning
	AddVDULineForBish( "MidProgressWinning",	"diag_matchProgWinning_RC301_02_01_mcor_bish" )
	// mid losing
	AddVDULineForBish( "MidProgressLosing",		"diag_matchProgLosing_RC302_02_01_mcor_bish" )

	// late winning
	AddVDULineForBish( "LateProgressWinning",	"diag_matchProgWinning_RC301_03_01_mcor_bish" )
	// late losing
	AddVDULineForBish( "LateProgressLosing",	"diag_matchProgLosing_RC303_03_01_mcor_bish" )


	// MAC: Bish, I'm gonna transmit some intel from the Odyssey. I'm going in. Stand by.
	// audio is played in the anim event callback, MacAllanDropoffDialog( ... )
	/**** VDU ****/
	convRef = AddConversation( "matchIntroMilitiaMac" )
	AddCustomVDUFunction( convRef, MacAllanDropoffVDU )

	// BISH - All right guys, this is a battle of attrition. Keep the IMC out of MacAllan’s hair and buy time for the survivors to escape. Let’s move out!
	/**** VDU ****/
	convRef = AddConversation( "modeAnnc_attrition" )
	AddVDURadio( convRef, "bish",	null, 	"diag_modeAnnc_RC104_01_01_mcor_bish" )

	// SARAH - Bish! We’re taking orders from this MacAllan now?
	// BIAH	 - The guy knows the area better than we do, Sarah.
	// SARAH - He’s ex-IMC! I don’t trust him and neither should you.
	// BISH  - Maybe, but our tactics are a mess, and he’s seen more combat than both of us combined. Don’t worry, I’ll keep an eye on him. Out.
	/**** VDU ****/
	convRef = AddConversation( "groundIntro" )
	AddVDURadio( convRef, "sarah",	null,	"diag_groundIntro_RC103_01_01_mcor_sarah" )
	AddVDURadio( convRef, "bish",	null,	"diag_groundIntro_RC103_02_01_mcor_bish" )
	AddVDURadio( convRef, "sarah",	null,	"diag_groundIntro_RC103_03_01_mcor_sarah" )
	AddVDURadio( convRef, "bish",	null,	"diag_groundIntro_RC103_04_01_mcor_bish" )

	// MACALLAN	- Bish, I’m patching you into the Odyssey’s flight computers and black box. Gonna have to fire her up to start the transmission.
	// BISH		- The better half of this wreck is a scrap heap, Mac. What’s on there? What’s so important?
	// MACALLAN	- Trust me - you wanna take the fight back to the IMC? Then you’re gonna want this data. Standby while I fire up the reactor.
	/**** VDU first line ****/
	convRef = AddConversation( "matchProg_MIL01" )
	AddCustomVDUFunction( convRef, CustomMacAllanVDU_1 ) // 5.63841
	AddVDUHide( convRef )
	AddRadio( convRef,		"diag_matchProg_MIL01_RC107_02_01_mcor_bish" ) // 4.38202
	AddRadio( convRef,		"diag_matchProg_MIL01_RC107_03_01_mcor_macal", -3.5 ) // 6.73308 - 3.5
	AddCustomVDUFunction( convRef, EngineStartupVDU )
	AddWait( convRef, 12 )

	// BISH	 	- Mac, the Odyssey is coming online. Transfer initiated. Whoa! You're getting schematics for Demeter?
	// MACALLAN - Damn right, Bish. Shut that place down, and the IMC lose their access to the Frontier. That’s how we’re gonna take the fight to them.
	// SARAH	- We’ve been taking the fight to ‘em every day, while you’ve been hiding out in the sticks.
	// MACALLAN - Believe me, I’m not hiding anymore. Starting Phase Two upload now.
	/**** VDU ****/
	convRef = AddConversation( "matchProg_MIL02" )
	AddVDURadio( convRef, "bish",	null,	"diag_matchProg_MIL02_RC109_01a_01_mcor_bish" )
	AddCustomVDUFunction( convRef, CustomMacAllanVDU_4 )

	// BISH		- Mac! The Odyssey’s shaking itself apart! You sure this is gonna work?
	// MACALLAN - Have a little faith Bish, we’re not flying this thing. She’ll hold together for what we need.
	// BISH	 	- So… MacAllan, you’re crazy if you think we can take out Demeter. The air support there alone is bigger than all the Militia fleets combined.
	// MACALLAN - You don’t know the half of it.
	// SARAH	- We don't know the half of it??? We’ve been taking the fight to ‘em every day, while you’ve been hiding out in the sticks.
	// MACALLAN - Believe me, I’m not hiding anymore.

	convRef = AddConversation( "matchProg_MIL03" )
	AddCustomVDUFunction( convRef, EnginePlungeVDU )
	AddWait( convRef, 6 )
	AddVDURadio( convRef, "bish",	"diag_matchProg_MIL01_RC107_04_01_mcor_bish" )
	AddVDURadio( convRef, "mac",	"diag_matchProg_MIL01_RC107_05_01_mcor_macal" )
	AddVDURadio( convRef, "bish",	"diag_matchProg_MIL03_RC111_01_01_mcor_bish" )
	AddRadio( convRef,				"diag_matchProg_MIL03_RC111_02_01_mcor_macal", -0.5 )
	AddVDURadio( convRef, "sarah",	null, "diag_matchProg_MIL02_RC111_03_01_mcor_sarah" )
	AddCustomVDUFunction( convRef, CustomMacAllanVDU_5 )

	// BISH	 	- Hot damn, this intel is a gold mine, Mac! But kicking the IMC out of the Frontier? That’s just impossible.
	// MACALLAN - Wrong word, Bish. This scenario can work, I know it. And so does Graves.
	// BISH	 	- Yeah? How?
	// MACALLAN - Let’s just say that once upon a time, we worked it out together.
	convRef = AddConversation( "matchProg_MIL04" )
	AddVDURadio( convRef, "bish", null, "diag_matchProg_MIL04_RC113_01_01_mcor_bish" )
	AddCustomVDUFunction( convRef, MacAllanEndPickupVDU )
	AddWait( convRef, 6.5 )
	AddRadio( convRef,	"diag_matchProg_MIL04_RC113_03_01_mcor_bish" )
	AddRadio( convRef, 	"diag_matchProg_MIL04_RC113_04_01_mcor_macal" )

	// SARAH - Well done team! All the survivors escaped and MacAllan uploaded a shit load of intel. Now chase those IMC babies back to their evac ships.
	/**** VDU ****/
	convRef = AddConversation( "matchWin" )
	AddVDURadio( convRef, "sarah",	null,	"diag_milWin_RC117_01_01_mcor_sarah" )

	// SARAH - We’ve lost. Get to your evac ships. Got a partial upload of the carrier’s intel. We’re gonna have to rely on MacAllan to fill in the blanks.
	convRef = AddConversation( "matchLoss" )
	AddVDURadio( convRef, "sarah",	"diag_imcWin_RC115_01_01_mcor_sarah" )

	// BISH - Why are we taking orders from this guy, Sarah? Well he just uploaded more intel than we’ve grabbed in the past year. I think we just might have a chance of taking the fight back to the IMC.
	convRef = AddConversation( "epilogue_mid" )
	AddVDURadio( convRef, "bish",	"diag_epMid_RC119_01_01_mcor_bish" )

	// MACALLAN - Graves once told me he could change the IMC from the inside, but it’s only gotten worse.
	// BISH		- Call the shot, Mac. Where to?
	// MACALLAN - Angel City.
	convRef = AddConversation( "post_epilogue_win" )
	AddVDURadio( convRef, "mac",	"diag_epPost_RC121_01_01_mcor_macal" )
	AddVDURadio( convRef, "bish",	"diag_epPost_RC121_02_01_mcor_bish" )
	AddVDURadio( convRef, "mac",	"diag_epPost_RC121_03_01_mcor_macal" )

	// same post epilogue lines if you win or lose
	convRef = AddConversation( "post_epilogue_loss" )
	AddVDURadio( convRef, "mac",	"diag_epPost_RC121_01_01_mcor_macal" )
	AddVDURadio( convRef, "bish",	"diag_epPost_RC121_02_01_mcor_bish" )
	AddVDURadio( convRef, "mac",	"diag_epPost_RC121_03_01_mcor_macal" )
}

///////////////////////////////////////////////////////////////////
function RelicIMCDialog()
{
	local team = TEAM_IMC
	local convRef

	// SPYGLASS	- I am scanning the wreckage of the ship. Registered as the Odyssey. Reported lost to mutiny under your command, Colonel Graves.
	// GRAVES	- I’m well aware of the history of the ship, and I know who’s responsible for its present condition. What I want to know is how it got here.
	// GRAVES	- (more to self) It was only a matter of time.  (then) Pilots, get ready to move! Secure the site!
	convRef = AddConversation( "matchIntro", team ) // only imc -> militia change
	// AddRadio( convRef, "diag_matchIntro_RC101_02_01_imc_spygl" )
	AddVDURadio( convRef, "bish",	null, 	"diag_modeAnnc_RC104_01_01_mcor_bish" )
	// rest of intro is played on graves in the dropship

	// SPYGLASS	- Militia forces have penetrated the Odyssey.
	// GRAVES	- What the hell are they doing in there? Hiding? Spyglass, scan for electronic activity.
	// SPYGLASS	- Low level frequency only, Colonel Graves.
	// GRAVES	- Keep an eye on them, Spyglass. I want to know what they’re up to.
	convRef = AddConversation( "matchProg_IMC01", team ) // only imc campaign mode only 
	AddVDURadio( convRef, "spyglass",	"diag_matchProg_IMC01_RC108_01_01_imc_spygl" )
	AddVDURadio( convRef, "graves",		"diag_matchProg_IMC01_RC108_02_01_imc_graves" )
	AddVDURadio( convRef, "spyglass",	"diag_matchProg_IMC01_RC108_03_01_imc_spygl" )
	AddVDURadio( convRef, "graves",		"diag_matchProg_IMC01_RC108_04_01_imc_graves" )

	// SPYGLASS	- Colonel, I’m detecting increased heat signatures in the Odyssey’s central core.
	// GRAVES	- They’re trying to spin her up. But she’s half in the ground.
	// SPYGLASS	- Damage to her stabilizers make flight operations impossible, Colonel.
	// GRAVES	- They’re not trying to fly her. They’re looting her. Blisk, flush the terrorists from the ship.
	/**** VDU last line ****/
	convRef = AddConversation( "matchProg_IMC02", team ) // only imc campaign mode only
	AddRadio( convRef,					"diag_matchProg_IMC02_RC110_01_01_imc_spygl", -3 )
	// Engines start up VDU moment threaded some how.
	AddCustomVDUFunction( convRef, EngineStartupVDU )
	AddWait( convRef, 3 )
	AddVDURadio( convRef, "graves",		"diag_matchProg_IMC02_RC110_02_01_imc_graves" )
	AddVDURadio( convRef, "spyglass",	"diag_matchProg_IMC02_RC110_03_01_imc_spygl" )
	AddVDURadio( convRef, "graves",		null,	"diag_matchProg_IMC02_RC110_04_01_imc_graves" )

	// BLISK	- The Odyssey just shook off an engine – not going to be much left to salvage.
	// SPYGLASS	- Vice Admiral, scans indicate the Militia still have a stable uplink with the Odyssey’s CPU.
	// GRAVES	- They’re extracting crucial information from her every second. We have to secure the site immediately.
	// GRAVES	- Sever the Militia’s connection, Blisk. Do whatever it takes.
	convRef = AddConversation( "matchProg_IMC03", team ) // only imc campaign mode only
	AddCustomVDUFunction( convRef, EnginePlungeVDU )
	AddWait( convRef, 6 )
	AddVDURadio( convRef, "blisk",		"diag_matchProg_IMC03_RC112_01a_01_imc_blisk" )
	AddVDURadio( convRef, "spyglass",	"diag_matchProg_IMC03_RC112_01_01_imc_spygl" )
	AddVDURadio( convRef, "graves",		"diag_matchProg_IMC03_RC112_02_01_imc_graves" )
	AddVDURadio( convRef, "graves",		"diag_matchProg_IMC03_RC112_04_01_imc_graves" )

	// BLISK	- Admiral Graves, I’m in the ship’s command center. There’s no one here now, but it looks like MacAllan tapped into the ship’s archive.
	// GRAVES	- (to self) Well, Mac, I guess you’re with them now. (to Blisk) Blisk, return to base. We’ll deal with MacAllan later.
	/**** VDU first line ****/
	convRef = AddConversation( "matchProg_IMC04", team ) // only imc campaign mode only
	AddCustomVDUFunction( convRef, CustomBliskVDU_1 )
	AddVDUHide( convRef )
	AddVDURadio( convRef, "graves",	 	"diag_matchProg_IMC04_RC114_02a_01_imc_graves" )
}



function RelicAIChatter()
{
	RelicAddAIConversations( TEAM_MILITIA, level.actorsABCD )
	RelicAddAIConversations( TEAM_IMC, level.actorsABCD )
}

function RelicAddAIConversations( team, actors )
{
	//Relic specific lines
	Assert ( GetMapName() == "mp_relic" )
	local conversation = "relic_grunt_chatter"

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_RC_comment2L_01_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_RC_comment2L_01_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_RC_comment2L_02_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_RC_comment2L_02_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_RC_comment2L_03_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_RC_comment2L_03_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_RC_comment2L_04_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_RC_comment2L_04_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_RC_comment2L_05_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_RC_comment2L_05_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_RC_comment2L_06_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_RC_comment2L_06_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_RC_comment2L_08_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_RC_comment2L_08_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_RC_comment2L_09_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_RC_comment2L_09_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_RC_comment2L_10_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_RC_comment2L_10_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_RC_comment2L_11_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_RC_comment2L_11_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_RC_comment2L_12_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_RC_comment2L_12_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_RC_comment2L_13_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_RC_comment2L_13_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_RC_comment2L_14_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_RC_comment2L_14_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_RC_comment3L_01_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_RC_comment3L_01_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_RC_comment3L_01_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_RC_comment3L_02_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_RC_comment3L_02_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_RC_comment3L_02_03", actors )]}
	]
	AddConversation( conversation, team, lines )


	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_RC_comment3L_03_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_RC_comment3L_03_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_RC_comment3L_03_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_RC_comment3L_04_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_RC_comment3L_04_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_RC_comment3L_04_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_RC_comment3L_05_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_RC_comment3L_05_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_RC_comment3L_05_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_RC_comment3L_06_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_RC_comment3L_06_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_RC_comment3L_06_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_RC_comment3L_07_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_RC_comment3L_07_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_RC_comment3L_07_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_RC_comment3L_08_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_RC_comment3L_08_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_RC_comment3L_08_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_RC_comment3L_09_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_RC_comment3L_09_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_RC_comment3L_09_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_RC_comment3L_10_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_RC_comment3L_10_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_RC_comment3L_10_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_RC_comment3L_11_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_RC_comment3L_11_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_RC_comment3L_11_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_RC_comment3L_12_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_RC_comment3L_12_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_RC_comment3L_12_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_RC_comment3L_13_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_RC_comment3L_13_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_RC_comment3L_13_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_RC_comment4L_01_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_RC_comment4L_01_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_RC_comment4L_01_03", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_RC_comment4L_01_04", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_RC_comment4L_02_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_RC_comment4L_02_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_RC_comment4L_02_03", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_RC_comment4L_02_04", actors )]}
	]
	AddConversation( conversation, team, lines )


	//*******************************//
	//*******************************//
	//*******************************//
	local conversation = "relic_grunt_chatter_engine_starting"

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_RC_comment2L_07_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_RC_comment2L_07_02", actors )]}
	]
	AddConversation( conversation, team, lines )
}

level.vduOrigin1 <- Vector( 2621, -9674, -196 )
level.vduAngles1 <- Vector( 0, 104, 0 )

function CustomMacAllanVDU_1( player )
{
	// blurb1: MACALLAN	- Bish, I’m patching you into the Odyssey’s flight computers and black box. Gonna have to fire her up to start the transmission.
	CustomRelicVDU( player, MAC_MODEL, "diag_matchProg_MIL01_RC107_01_01_mcor_macal", level.vduOrigin1, level.vduAngles1 )
}

function CustomMacAllanVDU_4( player )
{
	// blurb2: // MACALLAN - Damn right, Bish. Shut that place down, and the IMC lose their access to the Frontier. That’s how we’re gonna take the fight to them.
	CustomRelicVDU( player, MAC_MODEL, "diag_matchProg_MIL02_RC109_02_01_mcor_macal", level.vduOrigin1, level.vduAngles1 )
}

function CustomMacAllanVDU_5( player )
{
	// blurb2: // MACALLAN - Believe me, I’m not hiding anymore.
	CustomRelicVDU( player, MAC_MODEL, "diag_matchProg_MIL02_RC111_04_01_mcor_macal", level.vduOrigin1, level.vduAngles1 )
}

function CustomBliskVDU_1( player )
{
	// BLISK	- Admiral Graves, I’m in the ship’s command center. There’s no one here now, but it looks like MacAllan tapped into the ship’s archive.
	CustomRelicVDU( player, BLISK_MODEL, "diag_matchProg_IMC04_RC114_01_01_imc_blisk", level.vduOrigin1, level.vduAngles1 )
}

function CustomRelicVDU( player, model, anim, origin, angles )
{
	Assert( IsClient() )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "vdu_open" )

	local cleanupArray = []

	OnThreadEnd(
		function() : ( cleanupArray )
		{
			foreach( elem in cleanupArray )
			{
				if ( IsValid( elem ) )
					elem.Destroy()
			}
		}
	)

	local guy = CreatePropDynamic( model )
	cleanupArray.append( guy )

	AddClientEventHandling( guy ) //Kinda clumsy, but have to do it here to get the signal to close the VDU

	local attachID = guy.LookupAttachment( "VDU" )
	Assert(attachID > 0, guy + " has no VDU attachment!")

	local vduOrigin = guy.GetAttachmentOrigin( attachID )
	local vduAngles = guy.GetAttachmentAngles( attachID )

	level.camera.SetOrigin( vduOrigin )
	level.camera.SetAngles( vduAngles )
	level.camera.SetParent( guy, "VDU" )
	level.camera.SetFOV( 60 )

	local duration = guy.GetSequenceDuration( anim )
	thread PlayAnimTeleport( guy, anim, origin, angles )

	wait duration
}


function EnginePlungeVDU( player )
{
	thread EnginePlungeVDUThread( player )
}

function EnginePlungeVDUThread( player )
{
	local player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "vdu_open" )

	// for dev purposes
	player.Signal( "ZoomCameraOverTime" )
	player.Signal( "RotateCameraOverTime" )
	player.Signal( "MoveCameraOverTime" )

	OnThreadEnd(
		function () : ( player )
		{
			if ( IsValid( player ) )
			{
				level.camera.SetFogEnable( false )
				player.Signal( "ZoomCameraOverTime" )
				player.Signal( "RotateCameraOverTime" )
				player.Signal( "MoveCameraOverTime" )
			}

			HideVDU()
		}
	)

	local org1 = Vector( 4554, -3960, 2029 )
	local org2 = Vector( 3086, -3835, 2351 )
	local org3 = Vector( 2170, -2937, 2570 )

	local ang1 = Vector( 21, 134, 0 )
	local ang2 = Vector( 14, 119, 0 )
	local ang3 = Vector( 16.6, 112.6, 0 )
	local ang4 = Vector( 51, 66, 0 )

	local fov1 = 60
	local fov2 = 35
	local fov3 = 50
	local fov4 = 30

	level.camera.SetOrigin( org1 )
	level.camera.SetAngles( ang1 )
	level.camera.SetFOV( fov1 )
	level.camera.SetFogEnable( true )

	// the animation is 630 frames, 21 sec

	thread RotateCameraOverTime( player, ang1, ang2, 4.5, 2, 0.5 )
	thread MoveCameraOverTime( player, org1, org2, 4.5, 2, 0.5 )
	wait 4.0

	thread ZoomCameraOverTime( player, fov1, fov2, 1, 0.25, 0.25 )
	wait 0.5
	thread RotateCameraOverTime( player, ang2, ang3, 1.5, 1.0, 0.5 )
	wait 1.5

	thread ZoomCameraOverTime( player, fov2, fov3, 2, 0.5, 0 )
	thread RotateCameraOverTime( player, ang3, ang4, 4.0, 2, 2 )
	thread MoveCameraOverTime( player, org2, org3, 4, 2, 2 )
	wait 2

	thread ZoomCameraOverTime( player, fov3, fov4, 4.5, 3.0, 0.0 )
	wait 4.5

	// total VDU time 12.5 seconds
}

function EngineStartupVDU( player )
{
	thread EngineStartupVDUThread( player )
}

function EngineStartupVDUThread( player )
{
	local player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "vdu_open" )

	// for dev purposes
	player.Signal( "ZoomCameraOverTime" )
	player.Signal( "RotateCameraOverTime" )
	player.Signal( "MoveCameraOverTime" )

	OnThreadEnd(
		function () : ( player )
		{
			if ( IsValid( player ) )
			{
				level.camera.SetFogEnable( false )
				player.Signal( "ZoomCameraOverTime" )
				player.Signal( "RotateCameraOverTime" )
				player.Signal( "MoveCameraOverTime" )
			}

			HideVDU() // might not be needed but probably doesn't hurt
		}
	)

	local org1 = Vector( -2591, 1803, 786 )
	local ang1 = Vector( -16, -68, 0 )
	local fov1 = 70

	local ang2 = Vector( -1.75, -84.5, 0 )
	local fov2 = 35

	local ang3 = Vector( -7, -81, 0 )
	local fov3 = 45

	level.camera.SetOrigin( org1 )
	level.camera.SetAngles( ang1 )
	level.camera.SetFOV( fov1 )
	level.camera.SetFogEnable( true )

	wait 1
	thread RotateCameraOverTime( player, ang1, ang2, 4, 3, 1 )
	thread ZoomCameraOverTime( player, fov1, fov2, 5, 2, 2 )
	wait 5
	thread RotateCameraOverTime( player, ang2, ang3, 7, 5, 2 )
	thread ZoomCameraOverTime( player, fov2, fov3, 7, 5, 2 )

	// Militia side is 12 seconds
	// IMC side I don't know yet

	player.WaitSignal( "vdu_close" )
}

function MacAllanDropoffVDU( player )
{
	if ( !IsValid( level.introDropship ) )
		return

	local player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "vdu_open" )
	level.introDropship.EndSignal( "OnDestroy" )

	if ( IsLockedVDU() )
		return

	OnThreadEnd(
		function () : ( player )
		{
			if ( IsValid( player ) )
			{
				level.camera.SetFogEnable( false )
				level.camera.clClearParent()
			}

			HideVDU()
		}
	)

	local id = level.introDropship.LookupAttachment( "RampAttachA" )
	local origin = level.introDropship.GetAttachmentOrigin( id ) + Vector( 0, 0, 36 )
	local angles = level.introDropship.GetAttachmentAngles( id ) + Vector( 30, 165, 30 )

	level.camera.SetOrigin( origin )
	level.camera.SetAngles( angles )
	level.camera.SetParent( level.introDropship, "RampAttachA", true, 0.0 )
	level.camera.SetFOV( 55 )
	level.camera.SetFogEnable( true )

	wait 4.5
}

function MacAllanEndPickupVDU( player )
{
	thread MacAllanEndPickupVDUThread( player )
}

function MacAllanEndPickupVDUThread( player )
{
	if ( !IsValid( level.povModel ) )
		return

	local player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "vdu_open" )
	level.povModel.EndSignal( "OnDestroy" )

	// this VDU is for Militia only.
	if ( player.GetTeam() == TEAM_IMC )
		return

	// for dev purposes
	player.Signal( "ZoomCameraOverTime" )
	player.Signal( "RotateCameraOverTime" )
	player.Signal( "MoveCameraOverTime" )

	if ( IsLockedVDU() )
		return

	OnThreadEnd(
		function () : ( player )
		{
			if ( IsValid( player ) )
			{
				level.camera.SetFogEnable( false )
				level.camera.clClearParent()
				player.Signal( "ZoomCameraOverTime" )
				player.Signal( "RotateCameraOverTime" )
				player.Signal( "MoveCameraOverTime" )
			}

			HideVDU()
		}
	)

	local id = level.povModel.LookupAttachment( "POV" )
	local origin = level.povModel.GetAttachmentOrigin( id )
	local angles = level.povModel.GetAttachmentAngles( id )

	level.camera.SetOrigin( origin )
	level.camera.SetAngles( angles )
	level.camera.SetParent( level.povModel, "POV", false, 0.0 )	// for some reason this doesn't snap the camera as it should
	level.camera.SetFOV( 40 )
	level.camera.SetFogEnable( true )

	wait 7.5
}

function MacAllanCreated( entity, isRecreate )
{
	AddAnimEvent( entity, "mac_dropoff", MacAllanDropoffDialog )
	AddAnimEvent( entity, "mac_pickup", MacAllanPickupDialog )
}

function MacAllanDropoffDialog( macallan )
{
	local player = GetLocalViewPlayer()

	// MAC: Bish, I'm gonna transmit some intel from the Odyssey. I'm going in. Stand by.
	if ( player.GetTeam() == TEAM_MILITIA )
		EmitSoundOnEntity( player, "diag_matchProg_MIL01_RC107_01b_01_mcor_macal" )
}

function MacAllanPickupDialog( macallan )
{
	local player = GetLocalViewPlayer()

	// MACALLAN - Wrong word, Bish. This scenario can work, I know it. And so does Graves.
	if ( player.GetTeam() == TEAM_MILITIA )
		EmitSoundOnEntity( player, "diag_matchProg_MIL04_RC113_02_01_mcor_macal" )
}