
function main()
{

	RegisterConversation( "OverlookWonAnnouncement",	    VO_PRIORITY_GAMESTATE )
	RegisterConversation( "OverlookLostAnnouncement",	    VO_PRIORITY_GAMESTATE )

	if ( IsServer() )
		return

	local convRef

	// RC1: "Mayday! Mayday! This is the Redeye, we're going down, we're going downn!!!" (explodes)
	//Sarah: "We've lost this sector to the IMC. I'm sending in the dropships. Check your HUD and get to the nearest evac point!"
	convRef = AddConversation( "OverlookLostAnnouncement" )
	AddVDURadio( convRef, "barker", null, "diag_mcor_comms_hp_frac_redeyegoingdown_01" )
	AddVDURadio( convRef, "sarah", null, "diag_mcor_sarah_bonus_frac_dustoff_lost_02"  )

	convRef = AddConversation( "OverlookWonAnnouncement" )
	AddVDURadio( convRef, "bish", null, "diag_gs_mcor_bish_gamewon_02"  ) // Bish: All right, we got what we came for! Awesome work team, mission accomplished.
	AddVDURadio( convRef, "sarah", null, "diag_mcor_sarah_bonus_frac_dustoff_won_01"  ) // Sarah: "We've done our part, and now it's time to get you outta there! Check your HUD and get to the nearest evac point!"

}