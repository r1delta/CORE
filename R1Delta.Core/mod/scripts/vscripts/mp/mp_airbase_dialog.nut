function main()
{
	Globalize( SarahAirbaseVDU )
	Globalize( AirbaseTowerFallVDU )
	Globalize( TowerMainFallIMCVDUDialog )

	RegisterConversation( "pre_alpha_tower", VO_PRIORITY_GAMESTATE )

	RegisterConversation( "alpha_tower_fall", VO_PRIORITY_GAMESTATE )

	RegisterConversation( "militia_alpha_tower_down", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "imc_alpha_tower_down_post", VO_PRIORITY_GAMESTATE )

	RegisterConversation( "militia_alpha_tower_down_post", VO_PRIORITY_GAMESTATE )

	RegisterConversation( "militia_charlie_tower_down", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "militia_charlie_tower_down2", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "imc_charlie_tower_down", VO_PRIORITY_GAMESTATE )

	RegisterConversation( "militia_near_match_over_winning", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "militia_near_match_over_losing", VO_PRIORITY_GAMESTATE )

	RegisterConversation( "militia_npc_titan_support", VO_PRIORITY_GAMESTATE )

	RegisterConversation( "airbase_won_announcement", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "airbase_lost_announcement", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "airbase_game_mode_announce_at", VO_PRIORITY_GAMESTATE )

	RegisterConversation( "airbase_pre_final_tower", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "airbase_pre_final_tower2", VO_PRIORITY_GAMESTATE )

	RegisterConversation( "airbase_main_tower_down", VO_PRIORITY_GAMESTATE )

	RegisterConversation( "airbase_grunt_chatter", VO_PRIORITY_AI_CHATTER_LOW )
	RegisterConversation( "ai_announce_flying_creatures", VO_PRIORITY_AI_CHATTER_LOW )
	RegisterConversation( "ai_announce_straton_attacks", VO_PRIORITY_AI_CHATTER_LOW )

	if ( IsServer() )
		return

	RegisterAirbaseAIChatter()

	local convRef

	/*----------------------------------------------------------------------------------
	/
	/				ALPHA TOWER
	/
	/-----------------------------------------------------------------------------------*/
	// SARAH: Bish, I’ve made it to the access point of the north tower. Light resistance, but the bulk of their forces are occupied.
	// BISH: Copy that, Sarah. Pilots, keep the IMC engaged right where you are.
	convRef = AddConversation( "pre_alpha_tower" )
	AddVDURadio( convRef, "sarah", "diag_story15_AB140_01_01_mcor_sarah" )
	AddVDURadio( convRef, "bish", "diag_story15_AB140_02a_01_mcor_bish" )

	// SARAH: The north tower is out of commission
	// BISH: Nice job Sarah, keep me updated on your position
	convRef = AddConversation( "alpha_tower_fall" )
	AddVDURadio( convRef, "sarah", "diag_story40_AB142_01a_01_mcor_sarah" )
	AddVDURadio( convRef, "bish", "diag_story40_AB142_01b_01_mcor_bish" )

	// SARAH: Bish, I'm headed to the East Tower! I've picked up a pursuit force over here but I should be able to lose them in the service tunnels.
	convRef = AddConversation( "militia_alpha_tower_down" )
	AddCustomVDUFunction( convRef, TowerAlphaFallMilitiaVDU )

	// SARAH: Bish, I'm headed to the East Tower! I've picked up a pursuit force over here but I should be able to lose them in the service tunnels.
	convRef = AddConversation( "militia_alpha_tower_down_post" )
	AddCustomVDUFunction( convRef, SarahHeadedToEastTower )

	// GRAVES: Blisk, have your intercept team cut hard to the East Tower and set up an ambush. Don’t let them pursue directly. All other Pilots, stay on the main invasion force in case they make an attempt on the main tower.
	convRef = AddConversation( "imc_alpha_tower_down_post", TEAM_IMC ) // only imc campaign mode only
	AddCustomVDUFunction( convRef, TowerAlphaFallIMCVDU )
	AddVDUHide( convRef )
	AddVDURadio( convRef, "graves", "diag_story40_AB143_02_01_imc_graves" )

	/*----------------------------------------------------------------------------------
	/
	/				CHARLIE TOWER
	/
	/-----------------------------------------------------------------------------------*/
	convRef = AddConversation( "militia_charlie_tower_down" )
	AddWait( convRef, 8.0 )
	AddCustomVDUFunction( convRef, TowerCharlieFallMilitiaVDU )

	// SARAH: Bish! We’ve ‘icepicked’ the East tower, but my team’s been wiped out down here, and my shooting arm’s useless.
	// BISH: Can you still move? Can you get outta there?
	// SARAH: They’ve blocked the path to the main tower! There’s no way I can get to it now!
	// SARAH: Copy that Bish, I’m heading for the surface! Have a Crow on standby for medevac!
	convRef = AddConversation( "militia_charlie_tower_down2" )
	AddCustomVDUFunction( convRef, SarahCharlieTowerDown1 )
	AddVDURadio( convRef, "bish", null, "diag_story60_AB144_02_01_mcor_bish" )
	AddCustomVDUFunction( convRef, SarahCharlieTowerDown2 )
	AddCustomVDUFunction( convRef, TowerCharlieFallMilitiaVDU2 )
	AddCustomVDUFunction( convRef, SarahCharlieTowerDown3 )

	// BLISK: We’re hammering the Militia covert team in the tunnels by the East Tower! One of them’s running for it! Female, she’s been hit in the arm, and leaving a hell of a blood trail! My men are in pursuit!
	// SPYGLASS: Sergeant Blisk, I’m detecting instability in the East Tower –
	convRef = AddConversation( "imc_charlie_tower_down", TEAM_IMC ) // only imc campaign mode only
	AddVDURadio( convRef, "blisk", "diag_story60_AB145_01_01_imc_blisk" )
	AddVDURadio( convRef, "spyglass", null, "diag_story60_AB145_02_01_imc_spygl" )
	AddCustomVDUFunction( convRef, TowerCharlieFallIMCVDU )

	/*----------------------------------------------------------------------------------
	/
	/				NEAR MATCH OVER
	/
	/-----------------------------------------------------------------------------------*/
	// Bish: You're doing great. Take out the remaining IMC forces.
	convRef = AddConversation( "militia_near_match_over_winning" )
	AddVDURadio( convRef, "bish", "diag_matchProg75_AB116_01_01_mcor_bish" )

	// Bish: You need to step it up, we can't send Sarah into a hot zone. Kill as many IMC as you can.
	convRef = AddConversation( "militia_near_match_over_losing" )
	AddVDURadio( convRef, "bish", "diag_matchProg75_AB116_01_02_mcor_bish" )

	/*----------------------------------------------------------------------------------
	/
	/				NPC TITAN SUPPORT
	/
	/-----------------------------------------------------------------------------------*/
	// Bish: Titan support incoming. You need to step it up down there.
	convRef = AddConversation( "militia_npc_titan_support" )
	AddVDURadio( convRef, "bish", "diag_milNpcTitan_AB123_01_01_mcor_bish" )

	/*----------------------------------------------------------------------------------
	/
	/				PRE FINAL TOWER
	/
	/-----------------------------------------------------------------------------------*/
	// SARAH: Bish! I’ve made it to the airfield! What do you need?
	convRef = AddConversation( "airbase_pre_final_tower" )
	AddCustomVDUFunction( convRef, SarahPreFinalTower )
	AddCustomVDUFunction( convRef, TowerMainPreFallMilitiaVDU )

	// SARAH: Ok Bish, I’ve ‘icepicked’ the console! I’m getting on the medevac and I’m outta here! Good luck!
	// MACALLAN: Can you make it happen, Bish?
	// BISH: It’ll come down to how much time we have left, but yeah, I think I got this, Mac.
	convRef = AddConversation( "airbase_pre_final_tower2" )
	AddCustomVDUFunction( convRef, SarahPreFinalTower2 )
	AddVDUHide( convRef )
	AddWait( convRef, 1.0 )
	AddVDURadio( convRef, "mac", "diag_story80_AB146_04_01_mcor_macal" )
	AddVDURadio( convRef, "bish", "diag_story80_AB146_05_01_mcor_bish" )

	/*----------------------------------------------------------------------------------
	/
	/				MILITIA WIN
	/
	/-----------------------------------------------------------------------------------*/
	// MACALLAN: Great work, people. We’ll head to Demeter within the hour. It’s time for the main event. MacAllan out.
	// MACALLAN: Bish, patch me into the IMC.
	// MACALLAN: You read me Graves? You know what’s coming. All-out assault. Doesn’t have to go down like this.
	// GRAVES: A lot’s changed in the 15 years since you wore this uniform, Mac. I won’t let you walk away this time.
	// MACALLAN: Have you really made a difference in the IMC, Marcus? Or did you just turn into another company man along the way? All I see is bloodshed. I don’t see any change.
	// GRAVES: Then let the endgame decide - who’s right, and who’s dead.
	convRef = AddConversation( "airbase_won_announcement" )
	AddCustomVDUFunction( convRef, TowerMainFallMilitiaVDU )
	AddVDUHide( convRef )
	AddWait( convRef, 0.3 )
	AddVDURadio( convRef, "mac", "diag_epMid_AB152_02_01_mcor_macal" )
	AddVDUHide( convRef )
	AddWait( convRef, 1.0 )
	AddVDURadio( convRef, "mac", "diag_eppost_ab156_01_01_both_macal" )
	AddWait( convRef, 3.0 )
	AddVDURadio( convRef, "mac", "diag_epPost_AB154_01_01_both_macal" )
	AddWait( convRef, 0.3 )
	AddVDURadio( convRef, "graves", "diag_epPost_AB154_02_01_both_graves" )
	AddVDURadio( convRef, "mac", "diag_epPost_AB154_03_01_both_macal" )
	AddWait( convRef, 0.2 )
	AddVDURadio( convRef, "graves", "diag_epPost_AB154_04_01_both_graves" )

	// SPYGLASS: All units be advised - The repulsor towers have been destroyed. Wildlife intrusions have been detected across the entire base perimeter, the facility is being overrun by indigenous life. Mission terminated. All Pilots head for the evac point.
	// SPYGLASS: Vice Admiral Graves, incoming transmission from James MacAllan. He’s asking for you.
	// MACALLAN: You read me Graves? You know what’s coming. All-out assault. Doesn’t have to go down like this.
	// GRAVES: A lot’s changed in the 15 years since you wore this uniform, Mac. I won’t let you walk away this time.
	// MACALLAN: Have you really made a difference in the IMC, Marcus? Or did you just turn into another company man along the way? All I see is bloodshed. I don’t see any change.
	// GRAVES: Then let the endgame decide - who’s right, and who’s dead.
	convRef = AddConversation( "airbase_main_tower_down", TEAM_IMC ) // only imc campaign mode only
	AddVDURadio( convRef, "spyglass", "diag_imcLoseAnnc_AB151_01_01_imc_spygl" )
	AddWait( convRef, 3.0 )
	AddVDURadio( convRef, "spyglass", "diag_hp_story22_O2504_01_01_imc_spygl" )
	AddVDURadio( convRef, "mac", "diag_epPost_AB154_01_01_both_macal" )
	AddWait( convRef, 0.3 )
	AddVDURadio( convRef, "graves", "diag_epPost_AB154_02_01_both_graves" )
	AddVDURadio( convRef, "mac", "diag_epPost_AB154_03_01_both_macal" )
	AddWait( convRef, 0.2 )
	AddVDURadio( convRef, "graves", "diag_epPost_AB154_04_01_both_graves" )

	/*----------------------------------------------------------------------------------
	/
	/				IMC WIN
	/
	/-----------------------------------------------------------------------------------*/
	// BISH: We gotta ditch the party early, people. What’s left of this fleet is flying the coop. We didn’t win this one, but we did a lot of damage – hopefully enough to make a difference.
	// MACALLAN: All ground forces, head for the evac point. This will have to be enough. We’re jumping to Demeter and regrouping with our main assault fleet. MacAllan out.
	// MACALLAN: You read me Graves? You know what’s coming. All-out assault. Doesn’t have to go down like this.
	// GRAVES: A lot’s changed in the 15 years since you wore this uniform, Mac. I won’t let you walk away this time.
	// MACALLAN: Have you really made a difference in the IMC, Marcus? Or did you just turn into another company man along the way? All I see is bloodshed. I don’t see any change.
	// GRAVES: Then let the endgame decide - who’s right, and who’s dead.
	convRef = AddConversation( "airbase_lost_announcement" )
	AddVDURadio( convRef, "bish", "diag_milLoseAnnc_AB148_01_01_mcor_bish" )
	AddVDURadio( convRef, "mac", "diag_milLoseAnnc_AB148_02_01_mcor_macal" )
	AddWait( convRef, 3.4 )
	AddVDURadio( convRef, "mac", "diag_eppost_ab156_01_01_both_macal" )
	AddWait( convRef, 3.0 )
	AddVDURadio( convRef, "mac", "diag_epPost_AB154_01_01_both_macal" )
	AddWait( convRef, 0.3 )
	AddVDURadio( convRef, "graves", "diag_epPost_AB154_02_01_both_graves" )
	AddVDURadio( convRef, "mac", "diag_epPost_AB154_03_01_both_macal" )
	AddWait( convRef, 0.2 )
	AddVDURadio( convRef, "graves", "diag_epPost_AB154_04_01_both_graves" )

	/*----------------------------------------------------------------------------------
	/
	/				GAME MODE ANNOUNCEMENT
	/
	/-----------------------------------------------------------------------------------*/
	// BISH: This is a battle of attrition. Take out all the IMC forces, while Sarah hits the towers with the Icepick. Good luck!
	// BARKER: Hey Pilots, Sarah can't be in two places at once, so you're stuck with me on this one.
	// BARKER: I'll be handling Titan production for this operation.  Don't screw with me, I got a hellava bad hangover.   Barker out.
	convRef = AddConversation( "airbase_game_mode_announce_at" )
	AddVDURadio( convRef, "bish", null, "diag_modeAnnc_AB110_01a_01_mcor_bish" )
	AddVDUHide( convRef )
	AddWait( convRef, 1.0 )
	AddVDURadio( convRef, "barker", "diag_titanSupport_AB201a_01_01_mcor_barker" )
	AddVDURadio( convRef, "barker", "diag_titanSupport_AB201a_02_01_mcor_barker" )

	/*----------------------------------------------------------------------------------
	/
	/				BARKER TITAN STATUS
	/
	/-----------------------------------------------------------------------------------*/
	if ( GetCinematicMode() )
	{
		convRef = ReplaceConversation( "FirstTitanETA120s" )
		AddVDURadio( convRef, "barker", "diag_replacement_eta_AB125_01_01_mcor_barker" )

		convRef = ReplaceConversation( "FirstTitanETA60s" )
		AddVDURadio( convRef, "barker", "diag_replacement_eta_AB126_01_01_mcor_barker" )

		convRef = ReplaceConversation( "FirstTitanETA30s" )
		AddVDURadio( convRef, "barker", "diag_replacement_eta_AB127_01_01_mcor_barker" )

		convRef = ReplaceConversation( "FirstTitanETA15s" )
		AddVDURadio( convRef, "barker", "diag_replacement_eta_AB128_01_01_mcor_barker" )

		convRef = ReplaceConversation( "FirstTitanReady" )
		AddVDURadio( convRef, "barker", "diag_titanReady_AB129_01_01_mcor_barker" )

		convRef = AddConversation( "FirstTitanReady" )
		AddVDURadio( convRef, "barker", "diag_titanReady_AB130_01_01_mcor_barker" )

		convRef = ReplaceConversation( "FirstTitanInbound" )
		AddVDURadio( convRef, "barker", "diag_titanFall_AB131_01_01_mcor_barker" )

		convRef = AddConversation( "FirstTitanInbound" )
		AddVDURadio( convRef, "barker", "diag_titanFall_AB132_01_01_mcor_barker" )

		convRef = ReplaceConversation( "TitanReplacementReady" )
		AddVDURadio( convRef, "barker", "diag_titanReady_AB133_01_01_mcor_barker" )

		convRef = AddConversation( "TitanReplacementReady" )
		AddVDURadio( convRef, "barker", "diag_titanReady_AB134_01_01_mcor_barker" )

		convRef = ReplaceConversation( "TitanReplacementETA120s" )
		AddVDURadio( convRef, "barker", "diag_replacement_eta_AB125_01_01_mcor_barker" )

		convRef = ReplaceConversation( "TitanReplacementETA60s" )
		AddVDURadio( convRef, "barker", "diag_replacement_eta_AB126_01_01_mcor_barker" )

		convRef = ReplaceConversation( "TitanReplacementETA30s" )
		AddVDURadio( convRef, "barker", "diag_replacement_eta_AB127_01_01_mcor_barker" )

		convRef = ReplaceConversation( "TitanReplacementETA15s" )
		AddVDURadio( convRef, "barker", "diag_replacement_eta_AB128_01_01_mcor_barker" )

		convRef = ReplaceConversation( "TitanReplacement" )
		AddVDURadio( convRef, "barker", "diag_titanFall_AB131_01_01_mcor_barker" )

		convRef = AddConversation( "TitanReplacement" )
		AddVDURadio( convRef, "barker", "diag_titanFall_AB132_01_01_mcor_barker" )

		convRef = ReplaceConversation( "AutoTitanDestroyed" )
		AddVDURadio( convRef, "barker", "diag_titanDestro_AB135_01_01_mcor_barker" )

		convRef = AddConversation( "AutoTitanDestroyed" )
		AddVDURadio( convRef, "barker", "diag_titanDestro_AB136_01_01_mcor_barker" )

		convRef = AddConversation( "AutoTitanDestroyed" )
		AddVDURadio( convRef, "barker", "diag_titanDestro_AB137_01_01_mcor_barker" )
	}
}

function SarahAirbaseVDU( player, anim, org, ang )
{
	player.EndSignal( "OnDestroy" )
	local cam = level.camera
	cam.EndSignal( "OnDestroy" )

	cam.SetFOV( 60 )

	local sarah = CreateClientSidePropDynamic( org, ang, SARAH_MODEL );
	sarah.EndSignal( "OnDestroy" )

	local attachID = sarah.LookupAttachment( "VDU" )
	Assert( attachID > 0, sarah + " has no VDU attachment!" )

	local vduOrigin = sarah.GetAttachmentOrigin( attachID )
	local vduAngles = sarah.GetAttachmentAngles( attachID )

	cam.SetOrigin( vduOrigin )
	cam.SetAngles( vduAngles )
	cam.SetParent( sarah, "VDU" )

	sarah.Anim_NonScriptedPlay( anim )

	wait( sarah.GetSequenceDuration( anim ) )

	sarah.Destroy()
}

function SarahHeadedToEastTower( player )
{
	SarahAirbaseVDU( player, "diag_story40_AB142_02_01_mcor_sarah", Vector( -7696.0, 6732.0, -1056.0 ), Vector( 0.0, -20.0, 0.0 ) )
}

function SarahCharlieTowerDown1( player )
{
	SarahAirbaseVDU( player, "diag_story60_AB144_01_01_mcor_sarah", Vector( -7676.0, 7320.0, -1056.0 ), Vector( 0.0, -100.0.0, 0.0 ) )
}

function SarahCharlieTowerDown2( player )
{
	SarahAirbaseVDU( player, "diag_story60_AB144_03_01_mcor_sarah", Vector( -7676.0, 7320.0, -1056.0 ), Vector( 0.0, -100.0, 0.0 ) )
}

function SarahCharlieTowerDown3( player )
{
	SarahAirbaseVDU( player, "diag_story60_AB144_05_01_mcor_sarah", Vector( -7676.0, 7320.0, -1056.0 ), Vector( 0.0, -100.0, 0.0 ) )
}

function SarahPreFinalTower( player )
{
	SarahAirbaseVDU( player, "diag_story80_AB146_01_01_mcor_sarah", Vector( 1772.0, 6770.0, -896.0 ), Vector( 0.0, 275.0, 0.0 ) )
}

function SarahPreFinalTower2( player )
{
	SarahAirbaseVDU( player, "diag_story80_AB146_03_01_mcor_sarah", Vector( 1772.0, 6770.0, -896.0 ), Vector( 0.0, 275.0, 0.0 ) )
}

function AirbaseTowerFallVDU( player, cam, camOrg, camAng, fov, camRotate, camRotateTime )
{
	player.EndSignal( "OnDestroy" )
	cam.EndSignal( "OnDestroy" )

	cam.SetOrigin( camOrg )
	cam.SetFOV( fov )

	local currentTime = Time()
	local startTime = currentTime
	local endTime = startTime + camRotateTime

	while ( endTime > currentTime )
	{
		local frac = GraphCapped( currentTime, startTime, endTime, 0.0, 1.0 )

		cam.SetAngles( Vector( camAng.x + ( frac * camRotate.x ), camAng.y + ( frac * camRotate.y ), camAng.z + ( sin( currentTime ) * 1.25 ) ) )
		wait( 0.0 )
		currentTime = Time()
	}
}

function TowerAlphaFallMilitiaVDU( player )
{
	player.EndSignal( "OnDestroy" )
	local cam = level.camera
	cam.EndSignal( "OnDestroy" )

	cam.SetOrigin( Vector( 2297.0, 6946.0, -810.0 ) )
	cam.SetAngles( Vector( 0.0, 227.0, 0.0 ) )
	cam.SetFOV( 30.0 )

	local animRef = CreateScriptRef( Vector( 2265.0, 6906.0, -860.0 ), Vector( 0.0, 44.0, 0.0 ) )
	local animOrigin = animRef.GetOrigin()
	local animAngles = animRef.GetAngles()

	local sarah = CreatePropDynamic( SARAH_MODEL, animOrigin, animAngles )
	local grunt = CreatePropDynamic( TEAM_IMC_GRUNT_MDL, animOrigin, animAngles )

	thread PlayAnimTeleport( sarah, "sarah_VDU_necksnap", animRef )
	thread PlayAnimTeleport( grunt, "pt_VDU_necksnap", animRef )

	wait( 8.0 )

	grunt.Destroy()

	local camOrg = Vector( -10707.48, 7581.62, -6403.14 )
	local camAng = Vector( -38.54, 145.98, 0.0 )

	AirbaseTowerFallVDU( player, cam, camOrg, camAng, 45.0, Vector( 0.0, 29.0, 0.0 ), 15.0 )

	sarah.Destroy()
}

function TowerAlphaFallIMCVDU( player )
{
	player.EndSignal( "OnDestroy" )
	local cam = level.camera
	cam.EndSignal( "OnDestroy" )

	// BLISK: Sir, the Militia have taken out the north tower! Whoever’s out there is good.
	EmitSoundOnEntity( player, "diag_story40_AB143_01_01_imc_blisk" )

	local tower = GetClientEnt( "prop_dynamic", "prop_airbase_tower_alpha" )
	tower.EndSignal( "OnDestroy" )

	local camOrg = Vector( -10702.65, 7586.13, -6396.75 )
	thread CamFollowEnt( cam, tower, 6.0, Vector( 0.0, 0.0, 0.0 ), "dw_tower_pc_2" )
	thread CamBlendFromPosToPos( cam, camOrg, camOrg + Vector( 0.0, -2.0, 0.0 ), 6.0, 0.0, 0.0 )
	thread CamBlendFov( cam, 60.0, 28.0, 1.0, 0.7, 0.2 )
	wait( 1.0 )

	CamBlendFov( cam, 28.0, 32.0, 0.15, 0.04, 0.04 )
	CamBlendFov( cam, 32.0, 29.0, 0.6, 0.29, 0.29 )
	thread CamBlendFov( cam, 29.0, 30.0, 1.0, 0.4, 0.4 )

	wait( 4.25 )
}

function TowerCharlieFallMilitiaVDU( player )
{
	player.EndSignal( "OnDestroy" )
	local cam = level.camera
	cam.EndSignal( "OnDestroy" )

	local camOrg = Vector( -10686.7, 7629.09, -6401.20 )
	local camAng = Vector( -26.76, -110.36, 0.0 )

	thread AirbaseTowerFallVDU( player, cam, camOrg, camAng, 45.0, Vector( 0.0, -24.0, 0.0 ), 16.0 )

	wait( 2.0 )
	//Sarah: East Tower coming down! Only one more remaining.
	EmitSoundOnEntity( player, "diag_matchProg60_AB114_01_01_mcor_sarah" )
	wait( 16.0 )
}

function TowerCharlieFallMilitiaVDU2( player )
{
	player.EndSignal( "OnDestroy" )
	local cam = level.camera
	cam.EndSignal( "OnDestroy" )

	//BISH: Sarah, I’m sending you the coordinates of one of the airfields. It should take you away from the IMC pursuit team. If you can ‘icepick’ an IMC access console, we’ll still have a chance to take out the last tower!
	EmitSoundOnEntity( player, "diag_story60_AB144_04_01_mcor_bish" )

	cam.SetFOV( 40.0 )

	local camOrg = Vector( -9152.0, 7758.72, -728.88 )
	local camAng = Vector( 4.95, 65.8, -0.0 )

	local forward = camAng.AnglesToForward()
	cam.SetOrigin( camOrg )
	cam.SetAngles( camAng )
	thread CamFacePos( cam, camOrg + forward * 128.0, 3.0 )
	CamBlendFromPosToPos( cam, camOrg, camOrg + Vector( 50.0, 40.0, -5.0 ), 3.0, 0.0, 0.0 )

	cam.SetFOV( 60.0 )

 	camOrg = Vector( -5700.0, -2018.94, 582.85 )
	camAng = Vector( 10.37, 123.09, 0.0 )
	cam.SetOrigin( camOrg )
	cam.SetAngles( camAng )

	thread CamBlendFromAngToAng( cam, camAng, Vector( 45.19, -158.5, 0.0 ), 8.0, 0.0, 0.0 )
	CamBlendFromPosToPos( cam, camOrg, Vector( -5700.0, 3000.5, 1600.58 ), 8.0, 0.0, 0.0 )
}

function TowerCharlieFallIMCVDU( player )
{
	player.EndSignal( "OnDestroy" )
	local cam = level.camera
	cam.EndSignal( "OnDestroy" )

	// BLISK: The damn thing’s coming down, Spyglass! They have some kind of device, somehow it destabilizes the tower… (static)
	EmitSoundOnEntity( player, "diag_story60_AB145_03_01_imc_blisk" )

	local camOrg = Vector( -10686.7, 7629.09, -6401.20 )
	local camAng = Vector( -26.76, -110.36, 0.0 )

	thread AirbaseTowerFallVDU( player, cam, camOrg, camAng, 45.0, Vector( 0.0, -24.0, 0.0 ), 8.0 )

	wait( 11.0 )
}

function TowerMainFallMilitiaVDU( player )
{
	player.EndSignal( "OnDestroy" )
	local cam = level.camera
	cam.EndSignal( "OnDestroy" )

	// BISH: Mac, it's working! I've got remote control of the IMC ships! I'm gonna use 'em to cut down the tower.
	EmitSoundOnEntity( player, "diag_milWinAnnc_AB150_01a_01_mcor_bish" )

	cam.SetFOV( 45.0 )

	local dropship2 = GetClientEnt( "prop_dynamic", "militiaWinDropship2" )
	local dropship2AttachmentId = dropship2.LookupAttachment( "ORIGIN" )

	local camOrg = dropship2.GetAttachmentOrigin( dropship2AttachmentId )
	local camAng = dropship2.GetAttachmentAngles( dropship2AttachmentId )

	cam.SetOrigin( PositionOffsetFromOriginAngles( camOrg, camAng, -512.0, -180.0, 180.0 ) )
	cam.SetAngles( camAng )
	cam.SetParent( dropship2, "ORIGIN" )

	wait( 6.0 )

	local straton2 = GetClientEnt( "prop_dynamic", "militiaWinStraton2" )
	local straton2AttachmentId = straton2.LookupAttachment( "ORIGIN" )

	camOrg = straton2.GetAttachmentOrigin( straton2AttachmentId )
	camAng = straton2.GetAttachmentAngles( straton2AttachmentId )

	cam.SetOrigin( PositionOffsetFromOriginAngles( camOrg, camAng, -512.0, -180.0, 128.0 ) )
	cam.SetAngles( camAng )
	cam.SetParent( straton2, "ORIGIN" )

	wait( 5.0 )

	camOrg = dropship2.GetAttachmentOrigin( dropship2AttachmentId )
	camAng = dropship2.GetAttachmentAngles( dropship2AttachmentId )

	cam.SetOrigin( PositionOffsetFromOriginAngles( camOrg, camAng, -512.0, -180.0, 190.0 ) )
	cam.SetAngles( camAng )
	cam.SetParent( dropship2, "ORIGIN" )
	wait( 6.5 )

	local ref = CreateScriptRef()
	cam.SetParent( ref )

	cam.SetOrigin( Vector( -7557.0, 4720.0, 150.0 ) )

	local tower = GetClientEnt( "prop_dynamic", "prop_airbase_tower_main" )
	tower.EndSignal( "OnDestroy" )
	thread CamFollowEnt( cam, tower, 8.0, Vector( 0.0, 0.0, 0.0 ), "dw_tower_pc_2" )
	wait( 6.0 )
	// BISH: Timber!!
	EmitSoundOnEntity( player, "diag_milWinAnnc_AB150_01b_01_mcor_bish" )
	wait( 2.0 )

	cam.SetOrigin( Vector( -2833.0, 24.0, 7276.0 ) )
	thread CamFollowEnt( cam, tower, 12.5, Vector( 0.0, 0.0, 0.0 ), "dw_tower_pc_2" )
	wait( 5.5 )

	// BISH: Pilots, all towers are down, I repeat, all towers are down. Watch out for the incoming wildlife – they won’t play favorites between you and the IMC.
	EmitSoundOnEntity( player, "diag_milWinAnnc_AB150_01_01_mcor_bish" )
	cam.clClearParent()
	wait( 8.0 )
}

function TowerMainPreFallMilitiaVDU( player )
{
	player.EndSignal( "OnDestroy" )
	local cam = level.camera
	cam.EndSignal( "OnDestroy" )

	//BISH: Locate a fighter launch console. I can configure the system for remote activation with the Icepick.
	EmitSoundOnEntity( player, "diag_story80_AB146_02_01_mcor_bish" )

	local camOrg = Vector( 948.45, 5835.63, 569.93 )

	thread CamFacePos( cam, Vector( 2005.0, 5715.0, 160.0 ), 7.0 )
	CamBlendFromPosToPos( cam, camOrg, Vector( 2714.5, 5043.78, 438.0 ), 7.0, 0.0, 0.0 )
}

function TowerMainFallIMCVDUDialog( player )
{
	player.EndSignal( "OnDestroy" )

	// BLISK: Spyglass! There's a Phantom lifting off right now! She's got to be on board!
	// SPYGLASS: Negative. That fighter is operating on an unknown autopilot protocol
	// GRAVES: Spyglass, decrypt and expedite - the fighters are attacking main tower!
	EmitSoundOnEntity( player, "diag_story80_AB147_03_01_imc_blisk" )
	wait( 4.1 )
	EmitSoundOnEntity( player, "diag_story80_AB147_04_01_imc_spygl" )
	wait( 4.5 )
	EmitSoundOnEntity( player, "diag_story80_AB147_05_01_imc_graves" )
}

function TowerMainFallIMCVDU( player )
{
	player.EndSignal( "OnDestroy" )
	local cam = level.camera
	cam.EndSignal( "OnDestroy" )

	thread TowerMainFallIMCVDUDialog( player )

	local camOrg = Vector( 4147.88, 1740.26, 1533.16 )

	cam.SetOrigin( camOrg )
	cam.SetFOV( 6.0 )

	thread CamBlendFov( cam, 6.0, 12.0, 4.0, 1.9, 1.9 )

	local straton1 = GetClientEnt( "prop_dynamic", "militiaWinStraton1" )

	delaythread( 4.0 ) CamBlendFov( cam, 12.0, 35.0, 9.0, 2.7, 2.7 )
	CamFollowEnt( cam, straton1, 9.5, Vector( 0.0, 0.0, 0.0 ) )

	CamBlendFromFollowToAng( cam, straton1, Vector( -15.0, 165.2, 0.0 ), 4.5, 1.35, 1.35 )

	CamBlendFromAngToAng( cam,  cam.GetAngles(), Vector( -3.0, 145.2, 0.0 ), 2.5, 0.75, 0.75 )

	thread CamBlendFov( cam, 35.0, 55.0, 18.0, 5.4, 5.4 )
	CamBlendFromAngToAng( cam, cam.GetAngles(), Vector( -15.0, 165.2, 0.0 ), 8.0, 2.4, 2.4 )

	wait( 10.0 )
}

function AirbaseWonIMCVDU( player )
{
	player.EndSignal( "OnDestroy" )
	local cam = level.camera
	cam.EndSignal( "OnDestroy" )

	local camOrg = Vector( -10708.01, 7619.72, -6395.0 )
	cam.SetOrigin( camOrg )

	cam.SetFOV( 70.0 )

	local carrier = GetClientEnt( "prop_dynamic", "carrier1" )
	carrier.EndSignal( "OnDestroy" )

	CamFollowEnt( cam, carrier, 14.0, Vector( -19.0, 0.0, 0.0 ), "L_Exhaust_rear_2" )

	camOrg = Vector( 1596.66, -5981.33, 2536.90 )
	cam.SetFOV( 55.0 )

	cam.SetOrigin( camOrg )

	local wallace = GetClientEnt( "prop_dynamic", "wallace1" )

	thread CamFollowEnt( cam, wallace, 13.4, Vector( 1400.0, 0.0, -3000.0 ), "REF", true )

	// SPYGLASS: Vice Admiral Graves, incoming transmission from James MacAllan. He’s asking for you.
	// MACALLAN: You read me Graves? You know what’s coming. All-out assault. Doesn’t have to go down like this.
	// GRAVES: A lot’s changed in the 15 years since you wore this uniform, Mac. I won’t let you walk away this time.
	// MACALLAN: Have you really made a difference in the IMC, Marcus? Or did you just turn into another company man along the way? All I see is bloodshed. I don’t see any change.
	// GRAVES: Then let the endgame decide - who’s right, and who’s dead.
	EmitSoundOnEntity( player, "diag_hp_story22_O2504_01_01_imc_spygl" )
	wait( 6.7 )
	EmitSoundOnEntity( player, "diag_epPost_AB154_01_01_both_macal" )
	wait( 7.0 )
	thread HideVDU()
	EmitSoundOnEntity( player, "diag_epPost_AB154_02_01_both_graves" )
	wait( 5.9 )
	EmitSoundOnEntity( player, "diag_epPost_AB154_03_01_both_macal" )
	wait( 9.1 )
	EmitSoundOnEntity( player, "diag_epPost_AB154_04_01_both_graves" )
	wait( 3.64 )
}

function RegisterAirbaseAIChatter()
{
	AirbaseAddConversations( TEAM_MILITIA, level.actorsABCD )
	AirbaseAddConversations( TEAM_IMC, level.actorsABCD )
}

function AirbaseAddConversations( team, actors )
{
	Assert ( GetMapName() == "mp_airbase" )
	local conversation = "airbase_grunt_chatter"

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AB_comment2L_01_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AB_comment2L_01_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AB_comment2L_02_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AB_comment2L_02_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AB_comment2L_03_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AB_comment2L_03_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AB_comment2L_05_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AB_comment2L_05_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AB_comment2L_06_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AB_comment2L_06_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AB_comment2L_07_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AB_comment2L_07_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AB_comment2L_08_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AB_comment2L_08_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AB_comment2L_09_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AB_comment2L_09_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AB_comment2L_10_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AB_comment2L_10_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AB_comment2L_11_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AB_comment2L_11_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AB_comment2L_12_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AB_comment2L_12_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AB_comment2L_14_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AB_comment2L_14_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AB_comment2L_15_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AB_comment2L_15_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AB_comment2L_16_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AB_comment2L_16_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AB_comment3L_01_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AB_comment3L_01_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AB_comment3L_01_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AB_comment3L_02_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AB_comment3L_02_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AB_comment3L_02_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AB_comment3L_03_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AB_comment3L_03_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AB_comment3L_03_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AB_comment3L_04_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AB_comment3L_04_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AB_comment3L_04_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AB_comment3L_05_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AB_comment3L_05_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AB_comment3L_05_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AB_comment3L_06_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AB_comment3L_06_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AB_comment3L_06_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AB_comment3L_07_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AB_comment3L_07_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AB_comment3L_07_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AB_comment3L_08_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AB_comment3L_08_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AB_comment3L_08_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AB_comment3L_09_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AB_comment3L_09_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AB_comment3L_09_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AB_comment3L_10_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AB_comment3L_10_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AB_comment3L_10_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local conversation = "ai_announce_flying_creatures"

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AB_comment2L_04_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AB_comment2L_04_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local conversation = "ai_announce_straton_attacks"

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_AB_comment2L_13_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_AB_comment2L_13_02", actors )]}
	]
	AddConversation( conversation, team, lines )
}