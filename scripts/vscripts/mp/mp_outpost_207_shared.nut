// mp_outpost_207_shared

function main()
{
	if ( reloadingScripts )
		return

	level.WARNING_LIGHT_ON_MODEL		<- "models/lamps/warning_light_ON_orange.mdl"
	level.WARNING_LIGHT_OFF_MODEL 		<- "models/lamps/warning_light.mdl"
	level.CANNON_SCREEN_IDLE_MODEL 		<- "models/IMC_base/monitor_outpost207_imc_screen_01.mdl"
	level.CANNON_SCREEN_COOLING_MODEL	<- "models/IMC_base/monitor_outpost207_imc_screen_02.mdl"
	level.CANNON_SCREEN_FIRING_MODEL 	<- "models/IMC_base/monitor_outpost207_imc_screen_03.mdl"

	// Precaching models for clientside model swaps only works on the server
	if ( IsServer() )
	{
		PrecacheModel( level.WARNING_LIGHT_ON_MODEL )
		PrecacheModel( level.WARNING_LIGHT_OFF_MODEL )

		PrecacheModel( level.CANNON_SCREEN_IDLE_MODEL )
		PrecacheModel( level.CANNON_SCREEN_COOLING_MODEL )
		PrecacheModel( level.CANNON_SCREEN_FIRING_MODEL )
	}

	level.CANNON_SCREEN_IDLE 	<- 0
	level.CANNON_SCREEN_FIRING 	<- 1
	level.CANNON_SCREEN_COOLING <- 2

	level.SKYCAMERA_REF	 		<- "skybox_cam_level"
	level.SKYCAMERASPACE_MCOR 	<- "skybox_cam_intro"
	level.SKYCAMERASPACE_IMC	<- "skybox_cam_intro2"

	Outpost_RegisterConversations()
	//Outpost_RegisterTestConversations()

}

// ================ SHARED FUNCS ================
function GetLevelSkycamOrigin()
{
	if ( IsServer() )
		return level.skycamera.GetOrigin()
	else
		return level.skycameraOrg
}

function GetEntityWorldPos_ForCannonFX( ent, entLocation, entAttachAlias = null )
{
	Assert( entLocation == "skybox" || entLocation == "world" )
	local entInSkybox = false
	if ( entLocation == "skybox" )
		entInSkybox = true

	local cannonAttach = level.cannon.LookupAttachment( "rail_flap_01" )
	local cannonAttachOrg = level.cannon.GetAttachmentOrigin( cannonAttach )

	local beamLength
	local fwd
	local targetOrg = GetTargetPosForEntity( ent, entAttachAlias )

	if ( entInSkybox )
	{
		fwd = GetVectorFromWorldPosToSkyboxPos( cannonAttachOrg, targetOrg )
		//printt( "cannon fwd vec:", fwd )

		local skycameraOrg = GetLevelSkycamOrigin()
		local skyEntDistFromSkycam = Distance( skycameraOrg, targetOrg )

		local distanceScaled = skyEntDistFromSkycam * 1000
		//printt( "sky distance:", skyEntDistFromSkycam, "world distance:", distanceScaled )

		local worldPos = cannonAttachOrg + ( fwd * distanceScaled )
		beamLength = Distance( cannonAttachOrg, worldPos )
		//printt( "beamLength:", beamLength )
	}
	else
	{
		beamLength = Distance( cannonAttachOrg, targetOrg )
		fwd = cannonAttachOrg - targetOrg
		fwd.Normalize()
	}

	local worldPos = cannonAttachOrg + ( fwd * beamLength )
	//printt( "worldPos", worldPos )

	return worldPos
}

function GetTargetPosForEntity( ent, entAttachAlias = null )
{
	local targetOrg = ent.GetOrigin()
	local attachOrg = null
	if ( entAttachAlias && entAttachAlias != "" )
	{
		local attachID = ent.LookupAttachment( entAttachAlias )
		attachOrg = ent.GetAttachmentOrigin( attachID )
		targetOrg = attachOrg
	}

	// if ent has a move target, aim at that instead
	if ( "moveTarget" in ent.s && ent.s.moveTarget != null )
	{
		//printt( "using moveTarget, which is", ent.s.moveTarget )
		local moveTargetOrg = ent.s.moveTarget

		// if aiming at attachment, offset appropriately
		if ( attachOrg )
		{
			//printt( "entOrg", ent.GetOrigin(), "attachOrg", ent.GetOrigin() )

			local offsetDelta = ent.GetOrigin() - attachOrg
			//printt( "offsetDelta", offsetDelta )
			moveTargetOrg -= offsetDelta
		}

		targetOrg = moveTargetOrg
	}

	return targetOrg
}

function GetVectorFromWorldPosToSkyboxPos( worldPos, skyboxPos )
{
	local skycameraOrg = GetLevelSkycamOrigin()

	local deltaScaled = worldPos * 0.0001 // multiply by skybox scale factor
	worldPos = skycameraOrg + deltaScaled

	local vecDif = worldPos - skyboxPos
	vecDif.Normalize()

	return vecDif
}

function GetWorldVectorToOrg_ForCannonFX( org )
{
	local cannonAttach = level.cannon.LookupAttachment( "rail_flap_01" )
	local cannonAttachOrg = level.cannon.GetAttachmentOrigin( cannonAttach )

	local vec = cannonAttachOrg - org
	vec.Normalize()
	return vec
}


// ============== NORMAL CONVERSATIONS ================
function Outpost_RegisterConversations()
{
	RegisterConversation( "Intro_FlyIn_MCOR", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "Intro_FlyIn_MCOR_pt2", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "Intro_FlyIn_IMC", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "Intro_FlyIn_IMC_pt2", VO_PRIORITY_GAMESTATE )

	RegisterConversation( "Intro_PostFlyIn_MCOR", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "Intro_PostFlyIn_MCOR_pt2", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "Intro_PostFlyIn_IMC", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "Intro_PostFlyIn_IMC_pt2", VO_PRIORITY_GAMESTATE )

	RegisterConversation( "JumpDrivesDisabled", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "JumpDrivesDisabled_pt2", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "JumpDrivesDisabled_pt2_mcorWinning", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "JumpDrivesDisabled_pt2_imcWinning", VO_PRIORITY_GAMESTATE )

	RegisterConversation( "Gamestate_QuarterScore_MCOR_ReachedScore", 				VO_PRIORITY_GAMESTATE )
	RegisterConversation( "Gamestate_QuarterScore_MCOR_ReachedScore_AfterIMC", 		VO_PRIORITY_GAMESTATE )
	RegisterConversation( "Gamestate_QuarterScore_MCOR_ReachedScore_pt2", 			VO_PRIORITY_GAMESTATE )
	RegisterConversation( "Gamestate_QuarterScore_MCOR_ReachedScore_AfterIMC_pt2", 	VO_PRIORITY_GAMESTATE )
	RegisterConversation( "Gamestate_QuarterScore_IMC_ReachedScore", 				VO_PRIORITY_GAMESTATE )

	RegisterConversation( "Gamestate_HalfScore_MCOR_ReachedScore", 				VO_PRIORITY_GAMESTATE )
	RegisterConversation( "Gamestate_HalfScore_MCOR_ReachedScore_AfterIMC", 		VO_PRIORITY_GAMESTATE )
	RegisterConversation( "Gamestate_HalfScore_MCOR_ReachedScore_pt2", 			VO_PRIORITY_GAMESTATE )
	RegisterConversation( "Gamestate_HalfScore_MCOR_ReachedScore_AfterIMC_pt2", 	VO_PRIORITY_GAMESTATE )
	RegisterConversation( "Gamestate_HalfScore_IMC_ReachedScore", 				VO_PRIORITY_GAMESTATE )

	RegisterConversation( "Gamestate_ThreeQuarterScore_MCOR_ReachedScore", 				VO_PRIORITY_GAMESTATE )
	RegisterConversation( "Gamestate_ThreeQuarterScore_MCOR_ReachedScore_AfterIMC", 		VO_PRIORITY_GAMESTATE )
	RegisterConversation( "Gamestate_ThreeQuarterScore_MCOR_ReachedScore_pt2", 			VO_PRIORITY_GAMESTATE )
	RegisterConversation( "Gamestate_ThreeQuarterScore_MCOR_ReachedScore_AfterIMC_pt2", 	VO_PRIORITY_GAMESTATE )
	RegisterConversation( "Gamestate_ThreeQuarterScore_IMC_ReachedScore", 				VO_PRIORITY_GAMESTATE )

	RegisterConversation( "Epilogue_MatchWon", 		VO_PRIORITY_GAMESTATE )
	RegisterConversation( "Epilogue_MatchWon_pt2", 	VO_PRIORITY_GAMESTATE )
	RegisterConversation( "Epilogue_MatchLost", 	VO_PRIORITY_GAMESTATE )

	RegisterConversation( "PostEpilogue", VO_PRIORITY_GAMESTATE )

	RegisterConversation( "Epilogue_Lifeboat1", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "Epilogue_Lifeboat2", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "Epilogue_Lifeboat3", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "Epilogue_Lifeboat4", VO_PRIORITY_GAMESTATE )

    RegisterConversation( "outpost_207_grunt_chatter", VO_PRIORITY_AI_CHATTER_LOW )

	//RegisterTempConversation( "TestScreenPrint" )

	if ( IsServer() )
		return

	Outpost207AIChatter()

	local convRef


	// ================================================ NEW STUFF ======================================== //

	/*
	=============================
	INTRO FLY-IN
	<NOTE: These lines play during the dropship intro sequence>
	=============================
	*/

	/*
	BISH "Okay Boss, decoy's ready."
	MAC "Here we go, team. Bish, send it."
	BISH "Decoy warping in 3, 2, 1... mark." <warp sound>
	SARAH "Pilot dropships, that's our cue! Hit it!"
	<warp in>
	SARAH "We can see the decoy- it's working! The cannon's powering up!" <looking over her shoulder as the dropship back door opens>
	MAC "Dropships, stay clear of the blast zone!"

	<pilots hit the ground>
	*/

	convRef = AddConversation( "Intro_FlyIn_MCOR" )
	// Okay Boss, decoy's ready.
	AddWait( convRef, 0.75 )
	AddVDURadio( convRef, "bish", "diag_at_matchIntro_OP201_01_02_mcor_bish" )
	AddWait( convRef, 0.8 )
	// Here we go, team. Bish, send it.
	AddVDURadio( convRef, "mac", "diag_at_matchIntro_OP201_02_02_mcor_macal" )
	// Decoy warping in 3, 2, 1... mark.
	AddVDURadio( convRef, "bish", "diag_at_matchIntro_OP201_03_01_mcor_bish" )
	// Pilot dropships, that's our cue! Hit it!
	AddVDURadio( convRef, "sarah", "diag_at_matchIntro_OP201_04_01_mcor_sarah" )

	convRef = AddConversation( "Intro_FlyIn_MCOR_pt2" )
	// We can see the decoy- it's working! The cannon's powering up!
	//AddVDURadio( convRef, "sarah", "diag_at_matchIntro_OP201_05_02_mcor_sarah" )
	AddWait( convRef, 4.2 )
	// Dropships, stay clear of the blast zone!
	AddVDURadio( convRef, "mac", "diag_at_matchIntro_OP201_07_02_mcor_macal" )


	convRef = AddConversation( "Intro_FlyIn_IMC", TEAM_IMC ) // only imc campaign mode only
	// "There's a Militia ship coming into our airspace sir!"
	AddVDURadio( convRef, "grunt", "diag_at_matchIntro_OP202_02a_02_imc_grunt1" )
	AddWait( convRef, 1 )
	// The Militia's never been desperate enough to attack us here... So they want to get rid of the Sentinel that bad, eh?
	AddVDURadio( convRef, "blisk", "diag_at_matchIntro_OP202_02b_02_imc_blisk" )
	// Doesn't matter- we're ready for them. Spyglass, get our pilots to the outpost.
	AddVDURadio( convRef, "graves", "diag_at_matchIntro_OP202_03_02_imc_graves" )
	AddWait( convRef, 0.5 )
	// Jumping in now, Vice Admiral.
	AddVDURadio( convRef, "spyglass", "diag_at_matchIntro_OP202_04_02_imc_spygl" )
	AddWait( convRef, 4.5 )
	// Blisk! Charge the cannons!
	AddVDURadio( convRef, "graves", "diag_at_matchIntro_OP202_03a_03_imc_graves" )


	convRef = AddConversation( "Intro_FlyIn_IMC_pt2", TEAM_IMC ) // only imc campaign mode only
	// There's the target! Firing now!
	AddVDURadio( convRef, "blisk", "diag_at_matchIntro_OP202_06_02_imc_blisk" )


	/*
	=============================
	POST FLY IN
	<NOTE: these lines play just as players touch down from dropship fly-in>
	=============================
	*/

	convRef = AddConversation( "Intro_PostFlyIn_MCOR" )
	// "They took the bait, we're in!"
	AddVDURadio_WithAnim( convRef, "sarah", null, "diag_at_matchIntro_OP203_01_01_mcor_sarah" )

	convRef = AddConversation( "Intro_PostFlyIn_MCOR_pt2" )
	// "Clear out the IMC on the Outpost so the tech teams can get me remote access to the cannon."
	AddVDURadio_WithAnim( convRef, "bish", null, "diag_at_matchIntro_OP224_03_01_mcor_bish" )
	AddWait( convRef, 0.25 )
	// "You heard him team, this is a battle of ATTRITION. Kill every IMC soldier you can find, so the tech teams can get Bish a clear signal."
	AddVDURadio_WithAnim( convRef, "mac", null, "diag_at_matchIntro_OP224_05_01_mcor_macal" )

	/*
	<pilots hit the ground>
	BLISK "Colonel, that ship- it had no life signs, no shields."
	GRAVES "Of course- it's a decoy!" <angry with himself, it seems obvious now>
	OFFSCREEN GUY 1 "Militia just landed on Outpost 210!"
	OFFSCREEN GUY 2 "Outpost 197 here, we're under attack!"
	BLISK "Sir, if they control the cannon array, the Sentinel's got no chance."
	*/

	convRef = AddConversation( "Intro_PostFlyIn_IMC", TEAM_IMC ) // only imc campaign mode only
	// Colonel, that ship- it had no life signs, no shields.
	AddVDURadio_WithAnim( convRef, "blisk", null, "diag_at_matchIntro_OP204_02_02_imc_blisk" )
	AddWait( convRef, 0.25 )
	// Of course- it's a decoy!
	AddVDURadio_WithAnim( convRef, "graves", null, "diag_at_matchIntro_OP204_03_02_imc_graves" )
	AddWait( convRef, 0.25 )
	AddVDUHide( convRef )
	// Militia just landed on Outpost 210!
	AddVDURadio( convRef, "grunt", "diag_at_matchIntro_OP204_03a_01_imc_grunt1" )
	// Outpost 197 here, we're under attack!
	AddVDURadio( convRef, "grunt", "diag_at_matchIntro_OP204_03b_01_imc_grunt1" )

	convRef = AddConversation( "Intro_PostFlyIn_IMC_pt2", TEAM_IMC ) // only imc campaign mode only
	// Sir, if they control the cannon array, the Sentinel's got no chance.
	AddVDURadio_WithAnim( convRef, "blisk", null, "diag_at_matchIntro_OP204_03c_01_imc_blisk" )
	AddWait( convRef, 0.25 )
	// "Pilots, this'll be a battle of ATTRITION. Clear the Outposts of ALL Militia forces!"
	AddVDURadio_WithAnim( convRef, "graves", null, "diag_at_matchIntro_OP204_06_01_imc_graves" )


	/*
	=============================
	JUMP DRIVES DISABLED
	Note: this is a sequence that always happens, pretty early in the match.
	=============================
	*/

	convRef = AddConversation( "JumpDrivesDisabled" )
	// "Mac- the Sentinel's moving! They're trying to make a warp jump!"
	AddVDURadio( convRef, "sarah", "diag_at_JumpDrivesDisabled_OP205_01_01_mcor_sarah" )
	// "Bish, we gotta take out the jump drives!"
	AddVDURadio( convRef, "mac", "diag_at_JumpDrivesDisabled_OP205_02_01_mcor_macal" )
	// Working... got it! Firing now!"
	AddVDURadio( convRef, "bish", "diag_at_JumpDrivesDisabled_OP205_03_01_mcor_bish" )

	convRef = AddConversation( "JumpDrivesDisabled_pt2" )
	// "Impact confirmed. The Sentinel's jump drives are down."
	AddVDURadio( convRef, "sarah", "diag_at_JumpDrivesDisabled_OP205_04_01_mcor_sarah" )

	convRef = AddConversation( "JumpDrivesDisabled_pt2_mcorWinning" )
	// "Keep it up, team. We'll need a LOT more firepower to take out the Sentinel."
	AddVDURadio( convRef, "mac", "diag_at_JumpDrivesDisabled_OP205_05_01_mcor_macal" )

	convRef = AddConversation( "JumpDrivesDisabled_pt2_imcWinning" )
	// "Boss, I just lost my signal."
	AddVDURadio( convRef, "bish", "diag_at_JumpDrivesDisabled_OP205_06_01_mcor_bish" )
	// "Pilots, let's go! Spectres get in your way, try the data knife. Bish isn't the only one who can hack."
	AddVDURadio( convRef, "sarah", "diag_at_JumpDrivesDisabled_OP226_02_01_mcor_sarah" )


	/* =============================
	Game State VO NOTES:
	Game state updates on this level are driven by score thresholds - 25%/50%/75% of score to win
	- If the MCOR reach a game state threshold score before the IMC, we only hear the dialogue for that case, and the cannon fires.

	- If the IMC reach a game state score threshold before the MCOR, we play a short conversation explaining that the IMC are winning.
	  Subsequently, if/when the MCOR reach the same game state score threshold, we will still play a sequence that tells players that
	  the MCOR reached that game state score threshold, and then fire the cannon.  In these cases we'll need to play some alternate
	  dialogue since it'll feel more like the tide of the battle is swinging back and forth.
	============================= */

	/*
	=============================
	QUARTER SCORE
	=============================
	MCOR Quarter Score Reached - MCOR conv

	<if IMC 1/4 score hasn't been reached yet>
	MAC "Quarter of the way through, what's our status?"
	SARAH "Our Pilots are controlling the Outpost Mac."
	BISH "I got a clean signal!"
	MAC "What're you waiting for Bish, take the shot!"

	<if IMC 1/4 score was already reached>
	SARAH "The Pilots are fighting hard down here Bish, check your signal again!"
	BISH "Signal's clear again! I've got control of the cannon!"
	MAC "Hit it while we can!"

	BISH "On it! Firing now."
	<cannon fires at the Sentinel>
	SARAH "Oh yeah, good effect on target."

	<if IMC 1/4 score was already reached>
	MAC "Keep pushing, team. We can do this. Clear the Outposts!"

	<if IMC 1/4 score hasn't been already reached>
	MAC "Nice job down there Pilots. Keep it up."

	-----------------------------
	IMC Quarter Score Reached - MCOR conv

	MAC "25% on the mission timer, gimme an update!"
	SARAH "Mac, our Pilots are taking lotsa casualties."
	BISH "My signal's jammed, Boss! If the Outposts aren't cleared I can't control the cannons!"
	MAC "Hey Pilots, let's go! Clear the Outposts! This op is riding on you now!"
	*/

	// <if IMC 1/4 score hasn't been reached yet>
	convRef = AddConversation( "Gamestate_QuarterScore_MCOR_ReachedScore" )
	// "Quarter of the way through, what's our status?"
	AddVDURadio( convRef, "mac", "diag_at_MatchProg_MIL25_sideMIL_OP207_01_01_mcor_macal" )
	// "Our Pilots are keeping the IMC busy and the underground tech teams are transmitting to Bish."
	AddVDURadio( convRef, "sarah", "diag_at_MatchProg_MIL25_sideMIL_OP207_02a_01_mcor_sarah" )
	// "I got a clean signal!"
	AddVDURadio( convRef, "bish", "diag_at_MatchProg_MIL25_sideMIL_OP207_03_01_mcor_bish" )
	// "What're you waiting for Bish, take the shot!"
	AddVDURadio( convRef, "mac", "diag_at_MatchProg_MIL25_sideMIL_OP207_04_01_mcor_macal" )
	// "On it! Firing now."
	AddVDURadio( convRef, "bish", "diag_at_MatchProg_MIL25_sideMIL_OP207_08_01_mcor_bish" )


	// <if IMC 1/4 score was already reached>
	convRef = AddConversation( "Gamestate_QuarterScore_MCOR_ReachedScore_AfterIMC" )
	// "The Pilots are fighting hard down here Bish, check your signal again!"
	AddVDURadio( convRef, "sarah", "diag_at_MatchProg_MIL25_sideMIL_OP207_05_01_mcor_sarah" )
	// "Signal's clear again! I've got control of the cannon!"
	AddVDURadio( convRef, "bish", "diag_at_MatchProg_MIL25_sideMIL_OP207_06_01_mcor_bish" )
	// "Hit it while we can!"
	AddVDURadio( convRef, "mac", "diag_at_MatchProg_MIL25_sideMIL_OP207_07_01_mcor_macal" )
	// "On it! Firing now."
	AddVDURadio( convRef, "bish", "diag_at_MatchProg_MIL25_sideMIL_OP207_08_01_mcor_bish" )


	// <cannon fires at the Sentinel>


	// <if IMC 1/4 score hasn't been reached yet>
	convRef = AddConversation( "Gamestate_QuarterScore_MCOR_ReachedScore_pt2" )
	// "Oh yeah, good effect on target."
	AddVDURadio( convRef, "sarah", "diag_at_MatchProg_MIL25_sideMIL_OP207_09_01_mcor_sarah" )
	// "Nice job down there Pilots. Keep it up."
	AddVDURadio( convRef, "mac", "diag_at_MatchProg_MIL25_sideMIL_OP207_11_01_mcor_macal" )


	// <if IMC 1/4 score was already reached>
	convRef = AddConversation( "Gamestate_QuarterScore_MCOR_ReachedScore_AfterIMC_pt2" )
	// "Oh yeah, good effect on target."
	AddVDURadio( convRef, "sarah", "diag_at_MatchProg_MIL25_sideMIL_OP207_09_01_mcor_sarah" )
	// "Keep pushing, team. We can do this. Clear the Outposts!"
	AddVDURadio( convRef, "mac", "diag_at_MatchProg_MIL25_sideMIL_OP207_10_01_mcor_macal" )


	// <MCOR reacting to IMC hitting their 1/4 score first>
	convRef = AddConversation( "Gamestate_QuarterScore_IMC_ReachedScore" )
	// "25% on the mission timer, gimme an update!"
	AddVDURadio( convRef, "mac", "diag_at_MatchProg_IMC25_sideMIL_OP209_01_01_mcor_macal" )
	// "Mac, our Pilots are taking lotsa casualties."
	AddVDURadio( convRef, "sarah", "diag_at_MatchProg_IMC25_sideMIL_OP209_02_01_mcor_sarah" )
	// "My signal's jammed, Boss. The Pilots need to wipe out the opposition so the tech teams can get through and patch me in."
	AddVDURadio( convRef, "bish", "diag_at_MatchProg_IMC25_sideMIL_OP209_03a_01_mcor_bish" )
	// "Pilots, our tech teams can't keep Bish patched in if they're under fire. Eliminate as many hostiles as you can so the IMC divert more forces to the outpost!"
	AddVDURadio( convRef, "mac", "diag_at_MatchProg_IMC25_sideMIL_OP209_04a_01_mcor_macal" )


	/*
	MCOR Quarter Score Reached - IMC conv

	BLISK "Colonel! Hull shielding on the Sentinel is down 25%!"
	GRAVES "Damn. Spyglass, ground status?"
	SPYGLASS "Pilots have lost control of the Outposts, the Sentinel is being targeted."
	GRAVES "Ah s*bzz*t - Sentinel crew, brace for impact!"

	<if IMC hit quarter score mark before this>
	GRAVES "Pilots, focus up, you need to re-establish control down there."

	<otherwise>
	GRAVES "Pilots, get those Outposts under control or the Sentinel won't stand a chance!"


	IMC Quarter Score Reached - IMC conv

	GRAVES "Blisk, status?"
	BLISK "MCOR warp signatures have dropped by 25%."
	SPYGLASS "The Outposts are under control Colonel."
	GRAVES "Good work so far, Pilots. Keep killing 'em, they'll crawl back into their holes soon enough."
	*/


	// <cannon fires>


	


	/*
	=============================
	HALF SCORE
	=============================
	MCOR Half Score Reached - MCOR conv

	<if IMC 1/2 score hasn't been reached yet>
	MAC "Halfway through, team, what's going on?"
	SARAH "Our Pilots are taking care of business down here. Bish, how's the signal?"
	BISH "Nice and clean. Cannon just cooled down enough to refire, here we go again."
	<cannon fires at the Sentinel>
	MAC "Great job, team! Keep it up, we're taking this ship DOWN today!"

	<if IMC 1/2 score was already reached>
	MAC "Bish, we're running out of time..."
	BISH "Whoa, we're okay, my signal just cleared up! I'm firing again!"
	<cannon fires at the Sentinel>
	SARAH "Nice comeback Pilots. Keep pushing to keep those Outposts clear!"

	-----------------------------
	IMC Half Score Reached - MCOR conv

	MAC "Team, mission timer's at 50%. We're falling behind schedule."
	BISH "My signal's jammed Boss, I can't fire the cannon."
	SARAH "Pilots! Fight harder, we have to clear the Outposts!"
	*/

	/*
	RegisterConversation( "Gamestate_HalfScore_MCOR_ReachedScore", 				VO_PRIORITY_GAMESTATE )
	RegisterConversation( "Gamestate_HalfScore_MCOR_ReachedScore_AfterIMC", 		VO_PRIORITY_GAMESTATE )
	RegisterConversation( "Gamestate_HalfScore_MCOR_ReachedScore_pt2", 			VO_PRIORITY_GAMESTATE )
	RegisterConversation( "Gamestate_HalfScore_MCOR_ReachedScore_AfterIMC_pt2", 	VO_PRIORITY_GAMESTATE )
	RegisterConversation( "Gamestate_HalfScore_IMC_ReachedScore", 				VO_PRIORITY_GAMESTATE )
	*/

	// <if IMC 1/4 score wasn't already reached>
	convRef = AddConversation( "Gamestate_HalfScore_MCOR_ReachedScore" )
	// "Halfway through, team, what's going on?"
	AddVDURadio( convRef, "mac", "diag_at_MatchProg_MIL50_sideMIL_OP211_01_01_mcor_macal" )
	// "Our Pilots are taking care of business down here. Bish, how's the signal?"
	AddVDURadio( convRef, "sarah", "diag_at_MatchProg_MIL50_sideMIL_OP211_02_01_mcor_sarah" )
	// "Nice and clean. Cannon just cooled down enough to refire, here we go again."
	AddVDURadio( convRef, "bish", "diag_at_MatchProg_MIL50_sideMIL_OP211_03_01_mcor_bish" )


	// <if IMC 1/2 score was already reached>
	convRef = AddConversation( "Gamestate_HalfScore_MCOR_ReachedScore_AfterIMC" )
	// "Bish, we're running out of time..."
	AddVDURadio( convRef, "mac", "diag_at_MatchProg_MIL50_sideMIL_OP211_05_01_mcor_macal" )
	// "Whoa, we're okay, my signal just cleared up! Tech teams got the uplink back on! I'm firing again!"
	AddVDURadio( convRef, "bish", "diag_at_MatchProg_MIL50_sideMIL_OP211_06a_01_mcor_bish" )


	// <cannon fires at the Sentinel>


	// <if Militia reached their 1/2 score before IMC>
	convRef = AddConversation( "Gamestate_HalfScore_MCOR_ReachedScore_pt2" )
	// "Great job, team! Keep it up, we're taking this ship DOWN today!"
	AddVDURadio( convRef, "mac", "diag_at_MatchProg_MIL50_sideMIL_OP211_04_01_mcor_macal" )


	// <if IMC 1/2 score was already reached>
	convRef = AddConversation( "Gamestate_HalfScore_MCOR_ReachedScore_AfterIMC_pt2" )
	// "Nice comeback Pilots. Keep pushing to keep those Outposts clear!"
	AddVDURadio( convRef, "sarah", "diag_at_MatchProg_MIL50_sideMIL_OP211_07_01_mcor_sarah" )


	// <MCOR reacting to IMC hitting their 1/2 score first>
	convRef = AddConversation( "Gamestate_HalfScore_IMC_ReachedScore" )
	// "Team, mission timer's at 50%. We're falling behind schedule."
	AddVDURadio( convRef, "mac", "diag_at_MatchProg_IMC50_sideMIL_OP213_01_01_mcor_macal" )
	// "My signal's jammed Boss, I can't fire the cannon."
	AddVDURadio( convRef, "bish", "diag_at_MatchProg_IMC50_sideMIL_OP213_02_01_mcor_bish" )
	// "Pilots! Fight harder, we have to clear the Outposts!"
	AddVDURadio( convRef, "sarah", "diag_at_MatchProg_IMC50_sideMIL_OP213_03_01_mcor_sarah" )


	/*
	MCOR Half Score Reached - IMC conv

	<if MCOR 1/2 score mark wasn't reached yet>
	GRAVES "Blisk, how're we holding up?"
	BLISK "Shields are at 50%- [cuts himself off] Sir! They're targeting the Sentinel again!"

	<otherwise>
	BLISK "Colonel! We just lost cannon control again! They're targeting the Sentinel for another shot!"

	GRAVES "All hands! Brace for impact!"
	<cannon fires at the Sentinel>
	BLISK "We've got fires on decks 25 through 29!"
	SPYGLASS "Fire control Marvins have been dispatched."

	<if IMC hit half score mark before this>
	GRAVES "Keep fighting, Pilots. We can still pull out of this."

	<otherwise>
	GRAVES "Pilots, we're taking some huge shots up here! Get focused and CLEAR THE OUTPOSTS!"

	-----------------------------
	IMC Half Score Reached - IMC conv

	BLISK "Militia warp jump rate is down 50 percent, Colonel Graves."
	GRAVES "They're running out of resources. Keep the pressure up, Pilots."
	*/


	// <cannon fires at the Sentinel>


	/*
	=============================
	THREE QUARTER SCORE
	=============================
	MCOR ThreeQuarter Score Reached - MCOR conv

	<if IMC 3/4 score hasn't been reached yet>
	MAC "Bish! 75% on the mission timer, how we lookin?"
	BISH "Looking great Boss. Spinning up the cannons for another shot."
	<cannon fires at the Sentinel>
	MAC "We're too close to fail now, team- just need ONE MORE SHOT to kill the Sentinel!"
	SARAH "You heard him, Pilots! Finish it!"

	<if IMC 3/4 score was already reached>
	SARAH "We're pushing 'em back Bish! Try the cannon again!"
	BISH "It's not- oh, there it is! Signal's clear, here we go!"
	<cannon fires at the Sentinel>
	MAC "Keep pushing everyone! We just need ONE MORE SHOT to take down the Sentinel!"


	-----------------------------
	IMC ThreeQuarter Score Reached - MCOR conv

	MAC "Mission timer's at 75%. Why'd the cannon stop firing?"
	BISH "I got no signal, Boss!"
	SARAH "Our Pilots are losing ground, Mac."
	MAC "Hey Pilots- we're gonna lose it! Get those Outposts under control!"
	*/


	// <if IMC 3/4 score wasn't reached before MCOR reached their 3/4 score>
	convRef = AddConversation( "Gamestate_ThreeQuarterScore_MCOR_ReachedScore" )
	// "Bish! 75% on the mission timer, how we lookin?"
	AddVDURadio( convRef, "mac", "diag_at_MatchProg_MIL75_sideMIL_OP215_01_01_mcor_macal" )
	// "Looking great Boss. Spinning up the cannons for another shot."
	AddVDURadio( convRef, "bish", "diag_at_MatchProg_MIL75_sideMIL_OP215_02_01_mcor_bish" )


	// <if IMC 3/4 score was already reached before MCOR 3/4 score update>
	convRef = AddConversation( "Gamestate_ThreeQuarterScore_MCOR_ReachedScore_AfterIMC" )
	// "We're pushing 'em back Bish! Try the cannon again!"
	AddVDURadio( convRef, "sarah", "diag_at_MatchProg_MIL75_sideMIL_OP215_05_01_mcor_sarah" )
	// "It's not- oh, there it is! Signal's clear, here we go!"
	AddVDURadio( convRef, "bish", "diag_at_MatchProg_MIL75_sideMIL_OP215_06_01_mcor_bish" )


	// <cannon fires at the Sentinel>


	// <if IMC 3/4 score wasn't reached before MCOR reached their 3/4 score>
	convRef = AddConversation( "Gamestate_ThreeQuarterScore_MCOR_ReachedScore_pt2" )
	// "We're too close to fail now, team- just need ONE MORE SHOT to kill the Sentinel!"
	AddVDURadio( convRef, "mac", "diag_at_MatchProg_MIL75_sideMIL_OP215_03_01_mcor_macal" )
	// "You heard him, Pilots! Finish it!"
	AddVDURadio( convRef, "sarah", "diag_at_MatchProg_MIL75_sideMIL_OP215_04_01_mcor_sarah" )


	// <if IMC 3/4 score was already reached before MCOR 3/4 score update>
	convRef = AddConversation( "Gamestate_ThreeQuarterScore_MCOR_ReachedScore_AfterIMC_pt2" )
	// "Keep pushing everyone! We just need ONE MORE SHOT to take down the Sentinel!"
	AddVDURadio( convRef, "mac", "diag_at_MatchProg_MIL75_sideMIL_OP215_07_01_mcor_macal" )


	// <IMC reacting to hitting their 3/4 score before MCOR>
	convRef = AddConversation( "Gamestate_ThreeQuarterScore_IMC_ReachedScore" )
	// "Mission timer's at 75%. Why'd the cannon stop firing?"
	AddVDURadio( convRef, "mac", "diag_at_MatchProg_IMC75_sideMIL_OP217_01_01_mcor_macal" )
	// "I got no signal, Boss!"
	AddVDURadio( convRef, "bish", "diag_at_MatchProg_IMC75_sideMIL_OP217_02_01_mcor_bish" )
	// "Our Pilots are losing ground, Mac."
	AddVDURadio( convRef, "sarah", "diag_at_MatchProg_IMC75_sideMIL_OP217_03_01_mcor_sarah" )
	// "Hey Pilots- we're gonna lose it! Get those Outposts under control!"
	AddVDURadio( convRef, "mac", "diag_at_MatchProg_IMC75_sideMIL_OP217_04_01_mcor_macal" )


	/*
	MCOR ThreeQuarter Score Reached - IMC conv

	<if IMC 3/4 score hasn't been reached yet>
	BLISK "Colonel, hull shielding reduced by 75%. The cannon array is targeting the Sentinel again."
	GRAVES "Starboard decks, get to your lifeboats! All hands, brace for impact!"

	<if IMC 3/4 score was already reached>
	GRAVES "Blisk?! We're being targeted again!"
	BLISK "Yes sir! My targeting controls just went offline."
	SPYGLASS "Militia forces are rallying on the Outposts. The cannon array is targeting the Sentinel."
	GRAVES "All hands, brace for impact!"

	<cannon fires at the Sentinel>
	BLISK "Our shields are almost gone sir. We can't take another shot like that!"
	GRAVES "Pilots, I need your best right now. You WILL give me a chance to land this ship!"

	-----------------------------
	IMC ThreeQuarter Score Reached - IMC conv

	GRAVES "Blisk! Spyglass! Report."
	BLISK "Militia warp rate has dropped by 75%, sir."
	SPYGLASS "Our Pilots are effectively defending the Outposts, Colonel Graves."
	GRAVES "Good. We're wearing them out. Pilots, stay focused and finish the job."
	*/



	// <cannon fires at the Sentinel>



	/* ----------- copy paste ---------------
	convRef = AddConversation( "", TEAM_IMC )
	//
	AddVDURadio( convRef, "", "" )
	*/


	/*
	=============================
	EPILOGUE / EVAC
	=============================
	<NOTE: during the epilogue, the losing team has to evacuate on the dropship.>

	Epilogue MCOR Won - MCOR conv

	MAC "We've got the Outposts, the Sentinel's going down- Bish, hit it with everything we've got!"
	BISH "Taking the shot, Boss, this oughta do it-"

	<cannon shoots at the Sentinel, breaking it into pieces with a huge flash of light>

	MAC "That's it! The Sentinel's dead!"
	SARAH "Pilots, that's a nice piece of work. Sweep the Outposts again - make sure those Pilots don't escape."


	Epilogue MCOR Won - IMC conv

	SPYGLASS "Colonel, Militia forces have taken the Outposts."
	BLISK "The Sentinel can't survive another shot, sir."
	GRAVES "All hands, get to the lifeboats! GO!"
	SPYGLASS "Colonel Graves, Marvins are en route to the bridge to extract you-"

	<cannon shoots at the Sentinel, breaking it into pieces with a huge flash of light>

	-----------------------------
	Epilogue IMC Won - MCOR conv

	MAC "Militia, we're outta time! Rendezvous at the evac point and wait for pickup!"
	SARAH "But the Sentinel's still in the air!"
	BISH "Not for long. They're going down."
	SARAH "Roger. Pilots, get to the evac point!"


	Epilogue IMC Won - IMC conv

	SPYGLASS "Colonel, Pilots have secured the Outposts. Militia forces are falling back."
	GRAVES "Good work, Pilots. Non-essential crew, get to your lifeboats! Everyone else, strap in and prep for emergency landing."
	BLISK "Sir, the Sentinel has critical structural damage. Crash-landing will ground her forever."
	GRAVES "She's still valuable, Blisk. We'll strip her weapons, armor, and drive systems."
	BLISK "Understood. sir. Prepping lifeboats for launch."

	<these play during the epilogue>
	BLISK "Lifeboats launching, decks 4 through 20!"
	BLISK "Decks 23 through 35, lifeboats away!"
	BLISK "Hangar and Motor Pool, lifeboats away!"
	BLISK "Engineering, lifeboats clear!"
	*/

	convRef = AddConversation( "Epilogue_MatchWon" )
	// We've got the Outposts, the Sentinel's going down, Bish, hit it with everything we've got!
	AddVDURadio( convRef, "mac", "diag_at_milWinAnnc_OP219_01_01_mcor_macal" )
	// Taking the shot, Boss, this oughta do it-
	AddVDURadio( convRef, "bish", "diag_at_milWinAnnc_OP219_02_01_mcor_bish" )

	//<Sentinel blows up>

	convRef = AddConversation( "Epilogue_MatchWon_pt2" )
	// That's it! The Sentinel's dead!
	AddVDURadio( convRef, "mac", "diag_at_milWinAnnc_OP219_03_01_mcor_macal" )
	// Pilots, that's a nice piece of work. Sweep the Outposts again - make sure those Pilots don't escape.
	AddVDURadio_WithAnim( convRef, "sarah", null, "diag_at_milWinAnnc_OP219_04_01_mcor_sarah" )


	convRef = AddConversation( "Epilogue_MatchLost" )
	// Militia, we're outta time! Rendezvous at the evac point and wait for pickup!
	AddVDURadio( convRef, "mac", "diag_at_imcWinAnnc_OP221_02_01_mcor_macal" )
	// But the Sentinel's still in the air!
	AddVDURadio( convRef, "sarah", "diag_at_imcWinAnnc_OP221_03_01_mcor_sarah" )
	// Not for long. They're going down.
	AddVDURadio( convRef, "bish", "diag_at_imcWinAnnc_OP221_04_01_mcor_bish" )
	// We've lost enough lives today already.
	AddVDURadio( convRef, "mac", "diag_at_imcWinAnnc_OP221_06a_01_mcor_macal" )
	// Roger. Pilots, get to the evac point!
	AddVDURadio( convRef, "sarah", "diag_at_imcWinAnnc_OP221_05_01_mcor_sarah" )


	convRef = AddConversation( "Epilogue_Lifeboat1", TEAM_IMC ) // only imc campaign mode only
	// Lifeboats launching, decks 4 through 20!
	AddVDURadio( convRef, "blisk", "diag_at_EpFlavor_OP223_01_01_imc_blisk" )

	convRef = AddConversation( "Epilogue_Lifeboat2", TEAM_IMC ) // only imc campaign mode only
	// Decks 23 through 35, lifeboats away!
	AddVDURadio( convRef, "blisk", "diag_at_EpFlavor_OP223_02_01_imc_blisk" )

	convRef = AddConversation( "Epilogue_Lifeboat3", TEAM_IMC ) // only imc campaign mode only
	// Hangar and Motor Pool, lifeboats away!
	AddVDURadio( convRef, "blisk", "diag_at_EpFlavor_OP223_03_01_imc_blisk" )

	convRef = AddConversation( "Epilogue_Lifeboat4", TEAM_IMC ) // only imc campaign mode only
	// Engineering, lifeboats clear!
	AddVDURadio( convRef, "blisk", "diag_at_EpFlavor_OP223_04_01_imc_blisk" )


	/*
	=============================
	POST EPILOGUE VO
	=============================
	*/

	convRef = AddConversation( "PostEpilogue" )
	// Bish, this is MacAllan. You got Barker on the line?
	AddVDURadio( convRef, "mac", "diag_epPost_OP229_01_01_mcor_macal" )
	// He's standing by, Mac.
	AddVDURadio( convRef, "bish", "diag_epPost_OP229_02_01_mcor_bish" )
	// Nice fireball, Mac. Seems to be your specialty.
	AddVDURadio( convRef, "barker", "diag_epPost_OP229_03_01_mcor_barker" )
	// You didn't think we could do it.
	AddVDURadio( convRef, "mac", "diag_epPost_OP229_04_01_mcor_macal" )
	// No, I just didn't care.
	AddVDURadio( convRef, "barker", "diag_epPost_OP229_05_01_mcor_barker" )
	// Time to care, Barker. Time to do your part. Show Bish how to plot a course to the "Boneyard."
	AddVDURadio( convRef, "mac", "diag_epPost_OP229_06_01_mcor_macal" )
	// You gotta be kidding me. I said I'd never go back there.
	AddVDURadio( convRef, "barker", "diag_epPost_OP229_07_01_mcor_barker" )
	// I know the feeling, man. This world makes liars of us all.
	AddVDURadio( convRef, "mac", "diag_epPost_OP229_08_01_mcor_macal" )



	/* ----------- copy paste ---------------
	convRef = AddConversation( "", TEAM_IMC )
	//
	AddVDURadio_WithAnim( convRef, "", "" )
	*/
}

function AddVDURadio_WithAnim( convRef, character, soundalias, anim = "diag_vdu_default" )
{
	if ( anim != "diag_vdu_default" )
		soundalias = null

	AddVDURadio( convRef, character, soundalias, anim )
}

function Outpost207AIChatter()
{
	AddOutpost207AIConversations( TEAM_MILITIA, level.actorsABCD )
	AddOutpost207AIConversations( TEAM_IMC, level.actorsABCD )

}

function AddOutpost207AIConversations( team, actors )
{
	//Outpost207 specific lines
	Assert ( GetMapName() == "mp_outpost_207" )
	local conversation = "outpost_207_grunt_chatter"

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_OP_comment2L_01_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_OP_comment2L_01_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_OP_comment2L_02_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_OP_comment2L_02_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_OP_comment2L_03_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_OP_comment2L_03_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_OP_comment2L_04_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_OP_comment2L_04_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_OP_comment2L_05_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_OP_comment2L_05_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_OP_comment2L_06_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_OP_comment2L_06_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_OP_comment2L_07_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_OP_comment2L_07_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_OP_comment2L_08_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_OP_comment2L_08_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_OP_comment2L_09_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_OP_comment2L_09_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_OP_comment2L_10_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_OP_comment2L_10_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_OP_comment2L_11_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_OP_comment2L_11_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_OP_comment3L_01_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_OP_comment3L_01_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_OP_comment3L_01_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_OP_comment3L_02_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_OP_comment3L_02_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_OP_comment3L_02_03", actors )]}
	]
	AddConversation( conversation, team, lines )


	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_OP_comment3L_03_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_OP_comment3L_03_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_OP_comment3L_03_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_OP_comment3L_04_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_OP_comment3L_04_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_OP_comment3L_04_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_OP_comment3L_05_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_OP_comment3L_05_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_OP_comment3L_05_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_OP_comment3L_06_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_OP_comment3L_06_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_OP_comment3L_06_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_OP_comment3L_07_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_OP_comment3L_07_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_OP_comment3L_07_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_OP_comment3L_08_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_OP_comment3L_08_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_OP_comment3L_08_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_OP_comment3L_09_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_OP_comment3L_09_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_OP_comment3L_09_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_OP_comment3L_10_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_OP_comment3L_10_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_OP_comment3L_10_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_OP_comment3L_11_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_OP_comment3L_11_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_OP_comment3L_11_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_OP_comment4L_01_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_OP_comment4L_01_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_OP_comment4L_01_03", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_OP_comment4L_01_04", actors )]}
	]
	AddConversation( conversation, team, lines )
}


main()
