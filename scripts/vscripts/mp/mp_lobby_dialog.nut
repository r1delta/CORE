const LOBBYSCENEDELAY = 5.5

function main()
{
	LobbyScriptSetup()

	RegisterLobbyScene( "mp_fracture" )
	RegisterLobbyScene( "mp_colony" )
	RegisterLobbyScene( "mp_relic" )
	RegisterLobbyScene( "mp_angel_city" )
	RegisterLobbyScene( "mp_outpost_207" )
	RegisterLobbyScene( "mp_boneyard" )
	RegisterLobbyScene( "mp_airbase" )
	RegisterLobbyScene( "mp_o2" )
	RegisterLobbyScene( "mp_corporate" )

	if ( IsServer() )
		return

	FlagInit( "LobbySceneStarted" )
	InitLobbyScenes()
}

function InitLobbyScenes()
{
	local scene
	//==============================
	// 	FRACTURE
	//==============================
	scene = AddLobbyScene( "mp_fracture", TEAM_MILITIA )	//50s
	AddLobbyMusic( scene, "Music_Lobby_Militia_2",	51.0, 1.0 )
	AddLobbyLine( scene, "diag_Lobby_FR901_01_01_mcor_bish",	6.25 )		//Crew, this is Bish. At 0800 today, General Anderson succumbed to wounds sustained in battle.
	AddLobbyLine( scene, "diag_Lobby_FR901_02_01_mcor_bish",	2.8 )		//We are out of jump range of every other fleet in the sector.
	AddLobbyLine( scene, "diag_Lobby_FR901_03_01_mcor_bish",	5.0 )		//In short, we are on our own – as we have always been.
	AddLobbyLine( scene, "diag_Lobby_FR901_04_01_mcor_bish",	3.5 )		//Every ship in this fleet is down to less than two hours of fuel.
	AddLobbyLine( scene, "diag_Lobby_FR901_05_01_mcor_bish",	6.0 )		//Our options are limited. Either we get the fuel we need, or we die out here.
	AddLobbyLine( scene, "diag_Lobby_FR901_06_01_mcor_bish",	1.5 )		//Sarah, tactical report.
	AddLobbyWait( scene, 0.75 )
	AddLobbyLine( scene, "diag_Lobby_FR901_07_01_mcor_sarah",	4.7 )		//All the viable fuel sources within range are heavily fortified and under IMC control.
	AddLobbyLine( scene, "diag_Lobby_FR901_08_01_mcor_sarah", 	4.5 )		//We’ve selected a remote target in the Yuma system, which gives us the most time to conduct the raid.
	AddLobbyLine( scene, "diag_Lobby_FR901_09_01_mcor_sarah",	5.0 )		//Titan Pilots, you will keep the anti-air defenses offline while the fleet refuels overhead.
	AddLobbyWait( scene, 0.75 )
	AddLobbyLine( scene, "diag_Lobby_FR901_10_01_mcor_bish",	4.3 )		//Let’s make this count, people. We’ll have the element of surprise but not for long.
	AddLobbyLine( scene, "diag_Lobby_FR901_11_01_mcor_bish", 	0.0 )		//Good luck. Signing off.


	scene = AddLobbyScene( "mp_fracture", TEAM_IMC )		//49.25s
	AddLobbyMusic( scene, "Music_Lobby_IMC_1",	48.9889, 2.85 )
	AddLobbyLine( scene, "diag_Lobby_FR902_01_01_imc_graves",	7.25 )		//All personnel, this is Vice Admiral Graves. We have a rare opportunity to destroy an entire Militia fleet.
	AddLobbyLine( scene, "diag_Lobby_FR902_02_01_imc_graves",	6.0 )		//We know these terrorists are almost out of fuel, but desperation will make them unpredictable.
	AddLobbyLine( scene, "diag_Lobby_FR902_03_01_imc_graves",	2.0 )		//Do not underestimate them.
	AddLobbyLine( scene, "diag_Lobby_FR902_04_01_imc_graves",	5.5 )		//They can’t run far and they will most likely hit a fueling facility in the next few hours.
	AddLobbyLine( scene, "diag_Lobby_FR902_05_01_imc_graves",	2.0 )		//Spyglass will fill you in.
	AddLobbyWait( scene, 0.5 )
	AddLobbyLine( scene, "diag_Lobby_FR902_06_01_imc_spygl",	5.75 )		//Titan Pilots, you will be assigned to dropships at all potential targets in the Yuma System.
	AddLobbyLine( scene, "diag_Lobby_FR902_07_01_imc_spygl",	3.75 )		//A heavy patrol rotation will be maintained at all sites.
	AddLobbyLine( scene, "diag_Lobby_FR902_08_01_imc_spygl",	6.5 )		//At the first sign of Militia forces, you will deploy to the ground and ensure that the air defense turrets remain online.
	AddLobbyWait( scene, 0.5 )
	AddLobbyLine( scene, "diag_Lobby_FR902_09_01_imc_graves",	2.75 )		//You are cleared weapons free for this operation.
	AddLobbyLine( scene, "diag_Lobby_FR902_10_01_imc_graves",	0.0 )		//Stay vigilant. Graves out.


	//==============================
	// 	COLONY
	//==============================
	scene = AddLobbyScene( "mp_colony", TEAM_MILITIA )		//55.5s
	AddLobbyMusic( scene, "Music_Lobby_Militia_3", 3.5, 1.5 )
	AddLobbyLine( scene, "diag_Lobby_CY901_01_01_mcor_bish", 	3.75 )		//Listen up crew, the good news is we are still alive.
	AddLobbyLine( scene, "diag_Lobby_CY901_02_01_mcor_bish", 	4.5 )		//The majority of our fleet survived the raid with enough fuel to run for another month.
	AddLobbyLine( scene, "diag_Lobby_CY901_03_01_mcor_bish", 	7.25 )		//According to the tactical computers, the operation was a success, but we cannot continue to trade human lives for fuel.
	AddLobbyLine( scene, "diag_Lobby_CY901_04a_01_mcor_bish", 	5.75 )		//If anything, we need to recruit more people to our cause wherever we can find them. Sarah?
	AddLobbyWait( scene, 0.5 )
	AddLobbyLine( scene, "diag_Lobby_CY901_05_01_mcor_sarah", 	2.5 )		//Two hours ago, we received this on the distress channel:
	AddLobbyLine( scene, "diag_Lobby_CY901_06_01_mcor_civi1", 	13.0 )		//…we are a small colony…what the f**k are these things!!!...we need help, activate the distress beacon, now!...they’re getting through the door they’re getting through the door…noooo!!!” (gunfire and Spectre noises throughout background)
	AddLobbyLine( scene, "diag_Lobby_CY901_07_01_mcor_sarah", 	4.15 )		//The origin of the signal is from a sector that isn’t populated. It’s not on any chart.
	AddLobbyLine( scene, "diag_Lobby_CY901_08_01_mcor_sarah", 	4.8 )		//There is a chance it could be an IMC trap. That’s why we’re sending you to check it out first.
	AddLobbyLine( scene, "diag_Lobby_CY901_09_01_mcor_sarah", 	4.2 )		//But if these guys are homesteaders and we help 'em out... they might join our cause.
	AddLobbyLine( scene, "diag_Lobby_CY901_11_01_mcor_sarah", 	0.0 )		//Good luck, pilots. Signing off.


	scene = AddLobbyScene( "mp_colony", TEAM_IMC )			//53.5s
	AddLobbyMusic( scene, "Music_Lobby_IMC_3",	2.5, 0 )
	AddLobbyLine( scene, "diag_Lobby_CY902_01_01_imc_graves",	3.75 )		//All personnel, this is Vice Admiral Graves.
	AddLobbyLine( scene, "diag_Lobby_CY902_02_01_imc_graves",	9.0 )		//As you know, the Militia fleet remains operational in the wake of their refueling raid in the Yuma system, and we have deployed probes to a number of sectors.
	AddLobbyLine( scene, "diag_Lobby_CY902_03_01_imc_graves",	2.75 )		//Spyglass will brief you on the results of the search
	AddLobbyWait( scene, 0.5 )
	AddLobbyLine( scene, "diag_Lobby_CY902_04_01_imc_spygl",	5.3 )		//Pilots, I have scanned all possible destinations within jump range of the Yuma System.
	AddLobbyLine( scene, "diag_Lobby_CY902_05_01_imc_spygl",	6.5 )		//Life forms have been detected in sector Bravo 217, previously believed to be uninhabited.
	AddLobbyLine( scene, "diag_Lobby_CY902_06_01_imc_spygl",	3.1 )		//The Militia forces we seek may be hiding there.
	AddLobbyLine( scene, "diag_Lobby_CY902_07_01_imc_spygl",	7.25 )		//Recommend an advance team led by Sgt. Blisk to investigate, with a suitable complement of supporting units.

	AddLobbyLine( scene, "diag_Lobby_CY902_08_01_imc_graves",	2.5 )		//Very well. So ordered.
	AddLobbyLine( scene, "diag_Lobby_CY902_09_01_imc_graves",	6.0 )		//All Pilots, gear up and standby for deployment. Sgt. Blisk has command on the ground.
	AddLobbyLine( scene, "diag_Lobby_CY902_10_01_imc_graves",	0.0 )		//Good luck, Graves out.


	//==============================
	// 	RELIC
	//==============================
	scene = AddLobbyScene( "mp_relic", TEAM_MILITIA )		//42.5s
	AddLobbyMusic( scene, "Music_Lobby_Militia_1", 0, 1.5 )
	AddLobbyLine( scene, "diag_Lobby_RC901_01_01_mcor_bish", 	2.5 )		//Listen up crew, we don’t have much time.
	AddLobbyLine( scene, "diag_Lobby_RC901_02_01_mcor_bish", 	6.5 )		//The surviving colonists have fallen back to the cliffs overlooking the colony. They're hiding in some hills around a large shipwreck.
	AddLobbyLine( scene, "diag_Lobby_RC901_03_01_mcor_bish", 	2.5 )		//Sarah’s gonna fill you in on the details.
	AddLobbyWait( scene, 0.5 )
	AddLobbyLine( scene, "diag_Lobby_RC901_04a_01_mcor_sarah", 	3.0 )		//Our dropships are standing by to rescue the surviving colonists.
	AddLobbyLine( scene, "diag_Lobby_RC901_04b_01_mcor_sarah", 	7.2 )		//Titan Pilots, your objective is to hold off the IMC at the shipwreck, until we've recovered the colonists and their leader, James MacAllan.
	AddLobbyLine( scene, "diag_Lobby_RC901_06_01_mcor_sarah", 	3.7 )		//His last detail was first mate of the IMS Odyssey. That’s where we’re headed.
	AddLobbyWait( scene, 0.5 )
	AddLobbyLine( scene, "diag_Lobby_RC901_10_01_mcor_bish", 	5.5 )		//MacAllan's an ex-IMC officer; used to be one of their best Pilots and tacticians.
	AddLobbyLine( scene, "diag_Lobby_RC901_11_01_mcor_bish", 	0.0 )		//He's agreed to help us fight the IMC, if we get his people out safely. So let's get it done people! Lock and load!


	scene = AddLobbyScene( "mp_relic", TEAM_IMC )			//44.5s
	AddLobbyMusic( scene, "Music_Lobby_IMC_relic",	0, 3.0 )
	AddLobbyLine( scene, "diag_Lobby_RC902_01a_01_imc_graves", 	10.25 )		//All personnel, this is Vice Admiral Graves. Our pursuit of the First Militia Fleet has produced surprising results:  We have flushed the mutineer MacAllan from hiding.
	AddLobbyLine( scene, "diag_Lobby_RC902_04_01_imc_graves", 	5.0 )		//MacAllan is now the IMC’s most wanted target in this sector. Blisk?
	AddLobbyWait( scene, 0.5 )
	AddLobbyLine( scene, "diag_Lobby_RC902_05_01_imc_blisk", 	7.25 )		//MacAllan is a notoriously dangerous tactician. If he falls in with the terrorists then they will gain a considerable advantage.
	AddLobbyLine( scene, "diag_Lobby_RC902_06_01_imc_blisk", 	8.5 )		//We’ve picked up transmissions that suggest they will attempt to extract him from the northern plateau, near the wreckage of the IMS Odyssey - the very ship MacAllan stole from us.
	AddLobbyWait( scene, 0.3 )
	AddLobbyLine( scene, "diag_Lobby_RC902_07a_01_imc_graves", 	12 )		//All Pilots - your objective is to eliminate all Militia forces and secure the site. Under cover of your fire, Blisk's capture team will attempt to locate MacAllan, and take him into custody.
	AddLobbyLine( scene, "diag_Lobby_RC902_09a_01_imc_graves", 	0.0 )		//Good luck. Graves out.


	//==============================
	// 	ANGEL CITY
	//==============================
	scene = AddLobbyScene( "mp_angel_city", TEAM_MILITIA )	//44.5s
	AddLobbyMusic( scene, "Music_Lobby_Militia_2", 0.0, 4.2 )
	AddLobbyLine( scene, "diag_Lobby_AC901_01_01_mcor_macal", 	4.8 )		//Attention all personnel. My name is James MacAllan.
	AddLobbyLine( scene, "diag_Lobby_AC901_02_01_mcor_macal", 	4.3 )		//You have saved lives this day, and we are all in your debt.
	AddLobbyLine( scene, "diag_Lobby_AC901_03_01_mcor_macal", 	5.5 )		//Now I’m going to return the favor. I’m going to help you beat the IMC.
	AddLobbyLine( scene, "diag_Lobby_AC901_05_01_mcor_macal", 	7.8 )		//Any small victory has been offset by the IMC’s superior numbers, with reinforcements arriving daily from Demeter.
	AddLobbyLine( scene, "diag_Lobby_AC901_06_01_mcor_macal", 	2.9 )		//I believe we can bring the fight to them.
	AddLobbyLine( scene, "diag_Lobby_AC901_07_01_mcor_macal", 	4.1 )		//I believe we can change the balance of power on the Frontier.
	AddLobbyLine( scene, "diag_Lobby_AC901_08_01_mcor_macal", 	10.35 )		//We’re heading to Angel City to acquire Barker, an old compatriot of mine, who, believes, as I do, that the IMC’s reign cannot last forever.  Pilots, prepare to deploy.
	AddLobbyLine( scene, "diag_Lobby_AC901_09_01_mcor_macal", 	0.0 )		//Let’s get it done. MacAllan out.


	scene = AddLobbyScene( "mp_angel_city", TEAM_IMC )		//33s
	AddLobbyMusic( scene, "Music_Lobby_IMC_1", 0, 3.1 )
	AddLobbyLine( scene, "diag_Lobby_AC902_01_01_imc_graves", 	4.0 )		//Attention all Pilots, this is Vice Admiral Graves.
	AddLobbyLine( scene, "diag_Lobby_AC902_02_01_imc_graves", 	5.2 )		//We have confirmed that the traitor MacAllan has joined forces with the Militia’s First Fleet.
	AddLobbyLine( scene, "diag_Lobby_AC902_03_01_imc_graves", 	3.1 )		//I know this man and I know how his mind works.
	AddLobbyLine( scene, "diag_Lobby_AC902_04_01_imc_graves", 	6.5 )		//He will attempt to make contact with a retired IMC officer named Barker last seen in Angel City.
	AddLobbyLine( scene, "diag_Lobby_AC902_05_01_imc_graves", 	4.5 )		//Our operatives are tracking Barker within the city as we speak.
	AddLobbyLine( scene, "diag_Lobby_AC902_06_01_imc_graves", 	5.0 )		//If MacAllan does make contact, we can expect heavy firepower to support him.
	AddLobbyLine( scene, "diag_Lobby_AC902_08_01_imc_graves", 	5.0 )		//Your assignment is to eliminate all Militia forces who stand with him.
	AddLobbyLine( scene, "diag_Lobby_AC902_09_01_imc_graves", 	1.0 )		//Prepare for combat.


	//==============================
	// 	OUTPOST 207
	//==============================
	scene = AddLobbyScene( "mp_outpost_207", TEAM_MILITIA )	//58.5s
	AddLobbyMusic( scene, "Music_Lobby_Militia_3", 0, 1.0 )
	AddLobbyLine( scene, "Lobby_Boneyard_MicBump1", 0.8 )
	AddLobbyLine( scene, "diag_Lobby_OP900_01_01_mcor_barker", 	3.0 )		//You guys are all going to die a horrible death.
	AddLobbyLine( scene, "diag_Lobby_OP900_03_01_mcor_barker", 	3.7 )		//All I wanted was my damned drink, and you took me away from my happy place you –
	AddLobbyLine( scene, "Lobby_Outpost_MicBump2", 	0.3 )
	AddLobbyLine( scene, "diag_Lobby_OP900_04_01_mcor_macal", 	1.0 )		//Gimme that thing.
	AddLobbyLine( scene, "diag_Lobby_OP900_05_01_mcor_barker", 	7.25 )		//I know what you’ve got planned, Mac.  I knew the second you came to drag me outta there.
	AddLobbyLine( scene, "diag_Lobby_OP900_06_01_mcor_barker", 	3.25 )		//But that Sentinel’s everywhere in your way.
	AddLobbyLine( scene, "diag_Lobby_OP900_07_01_mcor_barker", 	3.5 )		//And it’s gonna kick your ass no matter what you try.
	AddLobbyLine( scene, "diag_Lobby_OP900_08_01_mcor_bish", 	4.5 )		//Hold on, Mac. This clown suggesting we need to take down an IMC supercarrier?
	AddLobbyLine( scene, "diag_Lobby_OP900_09_01_mcor_macal", 	1.0 )		//I’ve done it before.
	AddLobbyLine( scene, "diag_Lobby_OP900_10_01_mcor_barker", 	2.4 )		//That’s cause you don’t know how to fly!
	AddLobbyLine( scene, "diag_Lobby_OP900_11_01_mcor_barker", 	4.8 )		//Crashing a carrier into a backwater planet’s not the same as shootin’ one on the move!
	AddLobbyLine( scene, "diag_Lobby_OP900_12_01_mcor_macal", 	3.25 )		//That’s why we’re gonna take it down while it’s sitting still.
	AddLobbyLine( scene, "diag_Lobby_OP900_13_01_mcor_sarah", 	4.0 )		//So that’s why you sent the Hornets after it. You knew it would go back to drydock.
	AddLobbyLine( scene, "diag_Lobby_OP900_15_01_mcor_bish", 	1.9 )		//Uh, Mac, the mike’s still on. (static squelch break)
	AddLobbyLine( scene, "Lobby_Outpost_MicBump2", 	1.0 )
	AddLobbyLine( scene, "diag_Lobby_OP900_16_01_mcor_bish", 	6.5 )		//All right. For those of you who missed that, we’re going to take down the supercarrier IMS Sentinel.
	AddLobbyLine( scene, "diag_Lobby_OP900_17_01_mcor_bish", 	0.0 )		//That’s it. Titan Pilots, suit up and get ready. (click)


	scene = AddLobbyScene( "mp_outpost_207", TEAM_IMC )		//55.5s
	AddLobbyMusic( scene, "Music_Lobby_IMC_2", 74.195, 1.25 + 1.5 )
	AddLobbyLine( scene, "Lobby_Boneyard_MicBump1", 1.5 )
	AddLobbyLine( scene, "diag_Lobby_OP901_01_01_imc_spygl", 	2.0 )		//Damage assessment complete
	AddLobbyLine( scene, "diag_Lobby_OP901_01a_01_imc_spygl", 	4.0 )		//Flagship: IMS Sentinel. Damage report.
	AddLobbyLine( scene, "diag_Lobby_OP901_01b_01_imc_spygl", 	6.0 )		//During the Battle of Angel City, the Sentinel took critical internal damage from Militia fighter craft.
	AddLobbyLine( scene, "diag_Lobby_OP901_01c_01_imc_spygl", 	3.25 )		//The aft stabilizer was rendered inoperative.
	AddLobbyLine( scene, "diag_Lobby_OP901_03_01_imc_spygl", 	4.0 )		//Vice Admiral, I recommend three days in repairs.
	AddLobbyLine( scene, "diag_Lobby_OP901_06_01_imc_graves", 	2.5 )		//There’s a purpose to their sacrifice.
	AddLobbyLine( scene, "diag_Lobby_OP901_07_01_imc_blisk", 	2.25 )		//What, to show how desperate they are?
	AddLobbyLine( scene, "diag_Lobby_OP901_08_01_imc_graves", 	3.0 )		//They were. A few weeks ago, I’d accept that.
	AddLobbyLine( scene, "diag_Lobby_OP901_09_01_imc_graves", 	4.5 )		//But with MacAllan calling the shots, I think he wants to move the Sentinel out of his way.
	AddLobbyLine( scene, "diag_Lobby_OP901_10_01_imc_graves", 	2.0 )		//Gotta see the whole board, Blisk.
	AddLobbyLine( scene, "diag_Lobby_OP901_11_01_imc_spygl", 	5.0 )		//The nearest drydock large enough to house the Sentinel is on Outpost 207.
	AddLobbyLine( scene, "diag_Lobby_OP901_12_01_imc_graves", 	5.25 )		//Spyglass, divert a destroyer to cover the Sentinel’s patrol route until the repairs are complete.
	AddLobbyLine( scene, "diag_Lobby_OP901_13a_01_imc_graves", 	4.75 )		//Activate all orbital cannons on the deck, and deploy pilots to the outposts, just in case.
	AddLobbyLine( scene, "Lobby_Outpost_MicBump1", 	1.0 )


	//==============================
	// 	BONEYARD
	//==============================
	scene = AddLobbyScene( "mp_boneyard", TEAM_MILITIA )	//59.5s
	AddLobbyMusic( scene, "Music_Lobby_MCOR_boneyard", 1.0, 0.5 )
	AddLobbyLine( scene, "diag_Lobby_BY900_01_01_mcor_macal", 	2.0 )		//Crew, this is MacAllan.
	AddLobbyLine( scene, "diag_Lobby_BY900_02_01_mcor_macal", 	7.6 )		//With the IMS Sentinel out of commission, we’ve got a window of opportunity to make a jump to a place that does not officially exist.
	AddLobbyLine( scene, "diag_Lobby_BY900_03_01_mcor_macal", 	3.5 )		//Barker, however, can get us there. Go ahead, Barker.
	AddLobbyLine( scene, "Lobby_GenericMilitia_MicBump_Big_2", 	0.5 )
	AddLobbyLine( scene, "diag_Lobby_BY900_04_01_mcor_barker", 	4.9 )		// – Well, first I’d like to say this is a horrible, horrible idea.
	AddLobbyLine( scene, "diag_Lobby_BY900_05_01_mcor_sarah", 	0.6 )		//Ahh not again…
	AddLobbyLine( scene, "diag_Lobby_BY900_06_01_mcor_barker", 	4.0 )		//You want to go to the abandoned IMC base where I used to work?
	AddLobbyLine( scene, "diag_Lobby_BY900_07_01_mcor_barker", 	6.0 )		//I’m not dumb enough to go down there myself, but I’ll plot the jump coordinates from memory and fly you there.
	AddLobbyLine( scene, "diag_Lobby_BY900_08_01_mcor_barker", 	5.0 )		//Titan Pilots! Once you’re on the ground, look up, and you’ll see a Massive Tower.
	AddLobbyLine( scene, "diag_Lobby_BY900_09_01_mcor_barker", 	5.25 )		//It was – was - designed to keep out the wildlife – past tense.
	AddLobbyLine( scene, "diag_Lobby_BY900_10_01_mcor_barker", 	5.75 )		//I’d say don’t feed the animals but you might not have a choice, because they’re a lot bigger than you are.
/*	AddLobbyLine( scene, "diag_Lobby_BY900_11_01_mcor_barker", 	1.2 )		//That’s it from me.*/
	AddLobbySFX( scene, "Lobby_Boneyard_MicBump1", 1.5 )
	AddLobbyLine( scene, "diag_Lobby_BY900_12_01_mcor_barker", 	3.0 )		//Mac, I’ll be at the bar if you need me.
	AddLobbyLine( scene, "diag_Lobby_BY900_13_01_mcor_macal", 	0.0 )		//Pilots, the tower technology is still used at the airbase that protects Demeter. If we can learn how it works, we can use it against the IMC. MacAllan out.


	scene = AddLobbyScene( "mp_boneyard", TEAM_IMC )		//51.5s
	AddLobbyMusic( scene, "Music_Lobby_IMC_2", 0.0, 2.75 )
	AddLobbyLine( scene, "diag_Lobby_BY901_01_01_imc_graves", 	4.0 )		//Attention all personnel, this is the six.
	AddLobbyLine( scene, "diag_Lobby_BY901_02_01_imc_graves", 	4.25 )		//We are approaching the first of twenty-six jump points to Tower Station Zulu.
	AddLobbyLine( scene, "diag_Lobby_BY901_03_01_imc_graves", 	4.0 )		//You have all been given Code Black-Five clearance for this operation.
	AddLobbyLine( scene, "diag_Lobby_BY901_04_01_imc_graves", 	4.5 )		//Understand that you are going to a hostile planet. It will try to kill you.
	AddLobbyLine( scene, "diag_Lobby_BY901_05_01_imc_graves", 	6.6 )		//The “dog whistle” tower at this site has not functioned for 20 years, so you will be exposed to the wildlife out there
	AddLobbyLine( scene, "diag_Lobby_BY901_06_01_imc_graves", 	6.5 )		//When you make planetfall, you will encounter flyers with beaks powerful enough to pierce 9-inch armor plating.
	AddLobbyLine( scene, "diag_Lobby_BY901_07_01_imc_graves", 	4.3 )		//You will see creatures so massive they affect the calculation of jump coordinates.
	AddLobbyLine( scene, "diag_Lobby_BY901_08_01_imc_graves", 	4.0 )		//Do not allow these hazards to distract you from the mission at hand.
	AddLobbyLine( scene, "diag_Lobby_BY901_09_01_imc_graves", 	4.75 )		//The Militia seeks to exploit the repulsor technology, and we cannot allow that to happen.
	AddLobbyLine( scene, "diag_Lobby_BY901_10_01_imc_graves", 	5.0 )		//Take control of all generator hardpoints, overload the tower, and scuttle the base.
	AddLobbyLine( scene, "diag_Lobby_BY901_11_01_imc_graves", 	0.0 )		//Graves out.


	//==============================
	// 	AIRBASE
	//==============================
	scene = AddLobbyScene( "mp_airbase", TEAM_MILITIA )		//56s
	AddLobbyMusic( scene, "Music_Lobby_Militia_2",	51.5, 1.75 )
	AddLobbyLine( scene, "diag_Lobby_AB901_01a_01_mcor_macal", 	3.25 )		//Crew, this is MacAllan.
	AddLobbyLine( scene, "diag_Lobby_AB901_01b_01_mcor_macal", 	3.25 )		//Good news - we got what we needed off that tower.
	AddLobbyLine( scene, "diag_Lobby_AB901_02a_01_mcor_macal", 	7.5 )		//Only one thing remains between us Demeter - the greatest concentration of IMC power on the Frontier.
	AddLobbyLine( scene, "diag_Lobby_AB901_03_01_mcor_macal", 	7.0 )		//If any attack on Demeter is to have a chance of success, this airbase must be destroyed. Bish has the details.
	AddLobbyWait( scene, 1.0 )
	AddLobbyLine( scene, "diag_Lobby_AB901_07_01_mcor_bish", 	5.25 )		//The airbase is defended from local wildlife by three towers, like the one we saw in our last mission.
	AddLobbyLine( scene, "diag_Lobby_AB901_08_01_mcor_bish", 	6.25 )		//Using the data from that mission, I’ve built a device that will take down the towers. I call it the “Icepick”
	AddLobbyLine( scene, "diag_Lobby_AB901_08a_01_mcor_bish", 	5.5 )		//Because every ship in the Militia fleet will be needed at Demeter, a full scale aerial assault is not an option.
	AddLobbyLine( scene, "diag_Lobby_AB901_08b_01_mcor_bish", 	4.0 )		//But if we take out the towers, the wildlife will finish the job. Sarah?
	AddLobbyWait( scene, 0.5 )
	AddLobbyLine( scene, "diag_Lobby_AB901_09_01_mcor_sarah", 	4.0 )		//Covert ops will handle the towers. Pilots, I am asking you to guard our backs.
	AddLobbyLine( scene, "diag_Lobby_AB901_11_01_mcor_sarah", 	0.0 )		//Our fleet at Demeter is counting on us to come through. Get to your dropships and ready up. Good luck.


	scene = AddLobbyScene( "mp_airbase", TEAM_IMC )			//58s
	AddLobbyMusic( scene, "Music_Lobby_IMC_3", 0.0, 4.0 )
	AddLobbyLine( scene, "diag_Lobby_AB902_01_01_imc_graves", 	3.5 )		//Attention on deck - this is Vice Admiral Graves.
	AddLobbyLine( scene, "diag_Lobby_AB902_02_01_imc_graves", 	7.25 )		//The entire Militia fleet is holding at a rally point beyond attack distance from the Demeter Gateway.
	AddLobbyLine( scene, "diag_Lobby_AB902_03_01_imc_graves", 	6.5 )		//They are still vastly outnumbered by the dedicated reserve fleet stationed at the airbase on the fourth moon.
	AddLobbyLine( scene, "diag_Lobby_AB902_04_01_imc_graves", 	4.0 )		//I believe this airbase will be their next target.  Sergeant Blisk?
	AddLobbyWait( scene, 1.0 )
	AddLobbyLine( scene, "diag_Lobby_AB902_05_01_imc_blisk", 	3.75 )		//The Militia First Fleet didn’t make the trek to the boneyard for a safari.
	AddLobbyLine( scene, "diag_Lobby_AB902_06a_01_imc_blisk", 	6.5 )		//They were trying to find a way to take down the 'dog whistle' towers. The airbase depends on these to keep the creatures out.
	AddLobbyLine( scene, "diag_Lobby_AB902_07a_01_imc_blisk", 	5.25 )		//Now despite the losses they took, we have to assume they found a way to take down the towers.
	AddLobbyLine( scene, "diag_Lobby_AB902_08a_01_imc_blisk", 	3.5 )		//if they did - that’s just the domino they’ll need.
	AddLobbyWait( scene, 0.5 )
	AddLobbyLine( scene, "diag_Lobby_AB902_09_01_imc_graves", 	5.75 )		//Sergeant Blisk will co-ordinate a protective force on the ground, assigned explicitly to the towers.
	AddLobbyLine( scene, "diag_Lobby_AB902_10_01_imc_graves", 	4.5 )		//All Pilots, you will engage any Militia infantry you encounter at the airbase.
	AddLobbyLine( scene, "diag_Lobby_AB902_11_01_imc_graves", 	0.0 )		//No one gets through. Graves out.


	//==============================
	// 	O2 ( DEMETER )
	//==============================
	scene = AddLobbyScene( "mp_o2", TEAM_MILITIA )			//56s
	AddLobbyMusic( scene, "Music_Lobby_Militia_O2", 0.0, 0.9 )
	AddLobbyLine( scene, "diag_Lobby_O2800_01_01_mcor_macal", 	2.0 )		//Pilots
	AddLobbyLine( scene, "diag_Lobby_O2800_01b_01_mcor_macal", 	6.0 )		//all of our fight, all of our sacrifice has bought us this one day.
	AddLobbyLine( scene, "diag_Lobby_O2800_04a_01_mcor_macal", 	4.65 )		//Every ship in the Militia's fleet is marshaling for the battle of Demeter.
	AddLobbyLine( scene, "diag_Lobby_O2800_04b_01_mcor_macal", 	8.5 )		//This is the IMC refueling station that connects the Frontier to the Core Systems, and its endless supply of enemy reinforcements.
	AddLobbyLine( scene, "diag_Lobby_O2800_09_01a_mcor_macal", 	4.5 )		//It falls to you, Pilots, to destroy the Demeter base.
	AddLobbyLine( scene, "diag_Lobby_O2800_13_01a_mcor_macal", 	7.9 )		//I swore I’d never climb back into one of these things.  I would never order you into the fire that I would not enter myself.
	AddLobbyLine( scene, "diag_Lobby_O2800_10_01_mcor_macal", 	7.5 )		//I will personally take command of Sarah’s covert assault squad and initiate a chain reaction of the IMC fuel cells.
	AddLobbyLine( scene, "diag_Lobby_O2800_11_01_mcor_macal", 	8.5 )		//I ask you Pilots to engage the IMC infantry. If you can win this battle on the ground, you will alter the course of history.
	AddLobbyLine( scene, "diag_Lobby_O2800_14a_01_mcor_macal", 	0.0 )		//Pilots. Prepare for Titanfall Macallan out.

	scene = AddLobbyScene( "mp_o2", TEAM_IMC )				//47s
	AddLobbyMusic( scene, "Music_Lobby_IMC_O2", 0, 4.0 )
	AddLobbyLine( scene, "diag_Lobby_O2801_01_01_imc_graves", 	5.5 )		//Attention, all Pilots, this is your commanding officer Vice Admiral Graves.
	AddLobbyLine( scene, "diag_Lobby_O2801_02_01_imc_graves", 	4.5 )		//Please standby for a transmission from your employer - Mr. Hammond.
	AddLobbyWait( scene, 0.5 )
	AddLobbyLine( scene, "diag_Lobby_O2801_03_01_imc_hammond", 	1.5 )		//Are you receiving me, Graves?
	AddLobbyLine( scene, "diag_Lobby_O2801_04_01_imc_graves", 	2.5 )		//Yes, sir. Proceed.
	AddLobbyLine( scene, "diag_Lobby_O2801_05_01_imc_hammond", 	8.0 )		//All loyal members of the IMC, I have been informed of the recent loss of our air support responsible for the security of Demeter.
	AddLobbyLine( scene, "diag_Lobby_O2801_06_01_imc_hammond", 	7.75 )		//Rest assured I am presently fueling reinforcements to be dispatched from the Core Systems on the long jump to the Frontier.
	AddLobbyLine( scene, "diag_Lobby_O2801_07_01_imc_hammond", 	12.0 )		//You will hold the port of Demeter this day, you will crush the terrorists’ last ditch attempt at disrupting our civilization and you will find yourselves relieved and rewarded tomorrow.
	AddLobbyLine( scene, "diag_Lobby_O2801_08_01_imc_hammond", 	3.5 )		//Vice Admiral Graves, our world is in your hands.
	AddLobbyWait( scene, 0.5 )
	AddLobbyLine( scene, "diag_Lobby_O2801_09a_01_imc_graves", 	0.0 )		//Yes, sir. All Pilots, prepare for battle.


	//==============================
	// 	CORPORATE
	//==============================
	scene = AddLobbyScene( "mp_corporate", TEAM_MILITIA )	//55.5s
	AddLobbyMusic( scene, "Music_Lobby_Militia_1", 0.0, 0.9 )
	AddLobbyLine( scene, "diag_Lobby_CR800_01_01_mcor_bish", 	4.4 )		//Listen up. Much has changed since we fought at Demeter three months ago.
	AddLobbyLine( scene, "diag_Lobby_CR800_02_01_mcor_bish", 	6.1 )		//With the destruction of Demeter, IMC reinforcements are now years from arriving on the Frontier. Sarah?
	AddLobbyWait( scene, 0.75 )
	AddLobbyLine( scene, "diag_Lobby_CR800_03_01_mcor_sarah", 	5.9 )		//As the Human numbers keep shifting in our favor, we’ve witnessed many defections from the IMC to our cause.
	AddLobbyLine( scene, "diag_Lobby_CR800_04_01_mcor_sarah", 	5.25 )		//Trust is earned, not given, and I know you are all wary of fighting alongside former foes.
	AddLobbyLine( scene, "diag_Lobby_CR800_05_01_mcor_sarah", 	3.0 )		//But this man comes with MacAllan’s own seal of approval.
	AddLobbyLine( scene, "diag_Lobby_CR800_06_01_mcor_sarah", 	2.75 )		//I give you Field Commander… Marcus Graves.
	AddLobbyWait( scene, 0.5 )
	AddLobbyLine( scene, "diag_Lobby_CR800_07_01_mcor_graves", 	8.2 )		//Pilots, this is a war. The Militia are not guerillas, we do not have to run, we do not have to hide.
	AddLobbyLine( scene, "diag_Lobby_CR800_08_01_mcor_graves", 	2.25 )		//We stand and fight.
	AddLobbyLine( scene, "diag_Lobby_CR800_09_01_mcor_graves", 	5.0 )		//Because for the first time, we are not trapped in their world - they are trapped in ours.
	AddLobbyLine( scene, "diag_Lobby_CR800_10_01_mcor_graves", 	4.5 )		//Today we strike at the first of many IMC robotics factories.
	AddLobbyLine( scene, "diag_Lobby_CR800_11_01_mcor_graves", 	0.0 )		//Check your loadouts and ready up. Graves out.


	scene = AddLobbyScene( "mp_corporate", TEAM_IMC )		//56s
	AddLobbyMusic( scene, "Music_Lobby_IMC_corporate", 0, 2.5 )
	AddLobbyLine( scene, "diag_Lobby_CR801_01_01_imc_blisk", 	4.65 )		//Attention all Pilots. Listen up, you bastards. This is Commander Blisk.
	AddLobbyLine( scene, "diag_Lobby_CR801_02_01_imc_blisk", 	3.0 )		//For three months we have been pursuing the traitor Graves.
	AddLobbyLine( scene, "diag_Lobby_CR801_03_01_imc_blisk", 	5.85 )		//We followed him into disaster and now we follow him to one of Hammond’s classified production facilities.
	AddLobbyLine( scene, "diag_Lobby_CR801_04_01_imc_blisk", 	3.25 )		//Please standby for your new Vice Admiral – Spyglass.
	AddLobbyWait( scene, 1.0 )
	AddLobbyLine( scene, "diag_Lobby_CR801_05_01_imc_spygl", 	8.0 )		//We are still two years from completion of the new Gateway at Demeter which will bring with it the arrival of reinforcements from the core systems.
	AddLobbyLine( scene, "diag_Lobby_CR801_06_01_imc_spygl", 	4.9 )		//At present, Spectre combat drones compose the bulk of our fighting force.
	AddLobbyLine( scene, "diag_Lobby_CR801_07_01_imc_spygl", 	6.7 )		//The location of drone production facilities therefore is of paramount importance to our survival here in the Frontier.
	AddLobbyLine( scene, "diag_Lobby_CR801_08_01_imc_spygl", 	5.15 )		//The traitor Graves has stolen racks of Spectres and the locations of the facilities.
	AddLobbyLine( scene, "diag_Lobby_CR801_09_01_imc_spygl", 	4.3 )		//He must be apprehended before he can lead the Militia to our destruction.
	AddLobbyWait( scene, 0.5 )
	AddLobbyLine( scene, "diag_Lobby_CR801_10_01_imc_blisk", 	0.0 )		//Prepare to deploy, Pilots. We’ve got a lot of killing to do.

}


/************************************************************************************************\

########  #######   #######  ##        ######
   ##    ##     ## ##     ## ##       ##    ##
   ##    ##     ## ##     ## ##       ##
   ##    ##     ## ##     ## ##        ######
   ##    ##     ## ##     ## ##             ##
   ##    ##     ## ##     ## ##       ##    ##
   ##     #######   #######  ########  ######

\************************************************************************************************/
function RegisterLobbyScene( mapName )
{
	local name = GetLobbySceneName( mapName )

	level.sceneIndex++
	if ( IsServer() )
		level.SceneToIndex[ name ] <- level.sceneIndex
	else
	{
		Assert( !( name in level.lobbyScenes[ TEAM_MILITIA ] ), "lobby scene for map " + mapName + " already exists." )
		level.IndexToScene[ level.sceneIndex ] <- name
		level.lobbyScenes[ TEAM_MILITIA ][ name ] <- CreateSceneRef()
		level.lobbyScenes[ TEAM_IMC ][ name ] <- CreateSceneRef()
	}
}

function CreateSceneRef()
{
	local sceneRef = {}
	sceneRef.lines <- []
	sceneRef.music <- {}
	sceneRef.music.alias <- null
	sceneRef.music.seek <- 0
	sceneRef.music.delay <- 0

	return sceneRef
}

function GetLobbySceneName( mapName )
{
	local name = "lobbyIntro_" + mapName
	return name
}

function LobbyScriptSetup()
{
	level.sceneIndex <- 0
	level.SceneToIndex <- {}
	level.IndexToScene <- {}
	Globalize( GetLobbySceneName )
	if ( IsServer() )
	{
		Globalize( PlayLobbyScene )
		return
	}

	if ( IsClient() )
	{
		level.lobbyScenes <- {}
		level.lobbyScenes[ TEAM_MILITIA ] <- {}
		level.lobbyScenes[ TEAM_IMC ] <- {}

		Globalize( ServerCallback_PlayLobbyScene )
		Globalize( DebugPlayLobbySceneClient )
	}
}

if ( IsServer() )
{
	function GetIndexFromLobbyScene( name )
	{
		return level.SceneToIndex[ name ]
	}

	function PlayLobbyScene( player, mapName, timeLeft )
	{
		Assert( IsValid( player ) )
		Assert( IsPlayer( player ) )

		local name = GetLobbySceneName( mapName )
		local index = GetIndexFromLobbyScene( name )

		Remote.CallFunction_Replay( player, "ServerCallback_PlayLobbyScene", index, timeLeft )
	}
}

if ( IsClient() )
{
	function AddLobbyScene( mapName, team )
	{
		local name = GetLobbySceneName( mapName )
		Assert( name in level.lobbyScenes[ team ], "lobby scene for map " + mapName + " not registered for team: " + team )
		local sceneRef = level.lobbyScenes[ team ][ name ]

		return sceneRef
	}

	function AddLobbyMusic( sceneRef, alias, seek = 0, delay = 0 )
	{
		sceneRef.music.alias = alias
		sceneRef.music.seek = seek
		sceneRef.music.delay = delay
	}

	function AddLobbySFX( sceneRef, alias, delay )
	{
		local sceneLine = {}
		sceneLine.alias <- alias
		sceneLine.time <- 0
		sceneLine.delay <- delay


		sceneRef.lines.append( sceneLine )
	}

	function AddLobbyLine( sceneRef, alias, time = 0.0 )
	{
		local sceneLine = {}
		sceneLine.alias <- alias
		sceneLine.time <- time
		sceneLine.delay <- 0

		sceneRef.lines.append( sceneLine )
	}

	function AddLobbyWait( sceneRef, time )
	{
		local sceneLine = {}
		sceneLine.alias <- null
		sceneLine.time <- time
		sceneLine.delay <- 0

		sceneRef.lines.append( sceneLine )
	}

	function GetLobbySceneNameFromIndex( index )
	{
		return level.IndexToScene[ index ]
	}

	function GetLobbyScene( name, team )
	{
		if ( name in level.lobbyScenes[ team ] )
			return level.lobbyScenes[ team ][ name ]

		return null
	}

	function ServerCallback_PlayLobbyScene( index, timeLeft )
	{
		if ( Flag( "LobbySceneStarted" ) )
			return

		local team = GetLocalClientPlayer().GetTeam()
		local name = GetLobbySceneNameFromIndex( index )

		local timeNeeded = GetSceneLength( name, team )
		local enoughTime = ( ( timeLeft - timeNeeded ) >= 0.0 )

		if ( !enoughTime )
			return

		FlagSet( "LobbySceneStarted" )
		thread PlayLobbySceneClient( name, team )
	}

	function PlayLobbySceneClient( name, team )
	{
		local player = GetLocalClientPlayer()

		local sceneRef = GetLobbyScene( name, team )
		if ( !sceneRef )
			return

		local delayTime = LOBBYSCENEDELAY
		thread PlayLobbySceneMusic( player, sceneRef, delayTime )

		wait delayTime

		foreach( line in sceneRef.lines )
		{
			if ( line.alias )
			{
				if ( line.delay )
					delaythread( line.delay ) ThreadEmitSoundOnEntity( player, line.alias )
				else
					EmitSoundOnEntity( player, line.alias )
			}
			if ( line.time > 0 )
				wait line.time
		}
	}

	function ThreadEmitSoundOnEntity( ent, alias )
	{
		if ( !IsValid( ent ) )
			return

		EmitSoundOnEntity( ent, alias )
	}

	function DebugPlayLobbySceneClient( mapName, team )
	{
		thread PlayLobbySceneClient( GetLobbySceneName( mapName ), team )
	}

	function PlayLobbySceneMusic( player, sceneRef, delayTime )
	{
		if ( !sceneRef.music.alias )
			return

		StopMusic( delayTime - 1.0 )

		level.ent.EndSignal( "MusicStopped" )
		player.EndSignal( "OnDestroy" )

		wait delayTime

		if ( sceneRef.music.delay )
			wait sceneRef.music.delay

		local lengthOfMusic
		if ( sceneRef.music.seek )
			lengthOfMusic = EmitSoundOnEntityWithSeek( player, sceneRef.music.alias, sceneRef.music.seek )
		else
			lengthOfMusic = EmitSoundOnEntity( player, sceneRef.music.alias )

		//printt( "Playing lobby scene music: " + sceneRef.music.alias )
		level.currentMusicPlaying = sceneRef.music.alias

		wait lengthOfMusic + 3.0

		level.currentMusicPlaying = null

		thread LoopLobbyMusic()
	}

	function GetSceneLength( name, team )
	{
		local sceneRef = GetLobbyScene( name, team )
		if ( !sceneRef )
			return 0

		local time = 0.0
		local max = sceneRef.lines.len()
		for ( local i = 0; i < max; i++ )
		{
			local line = sceneRef.lines[ i ]

			if ( i == max - 1 )
				time += GetSoundDuration( line.alias )
			else
				time += line.time
		}

		return time + LOBBYSCENEDELAY
	}
}

