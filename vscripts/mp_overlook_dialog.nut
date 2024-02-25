
function main()
{

	RegisterConversation( "OverlookWonAnnouncement",	    VO_PRIORITY_GAMESTATE )
	RegisterConversation( "OverlookLostAnnouncement",	    VO_PRIORITY_GAMESTATE )

	if ( IsServer() )
		return

	local convRef

	//Taking from fracture for now
	// Blisk: "All units, be advised, mission accomplished, we have destroyed the Redeye. Fine work all around. Come on home."
	convRef = AddConversation( "OverlookWonAnnouncement", TEAM_IMC )
	AddVDURadio( convRef, "blisk", "diag_imc_blisk_hp_frac_redeyedamage_04" )
	AddVDURadio( convRef, "spyglass", "diag_imc_spyglass_cmp_frac_dustoff_won_1_1", "spy_VDU_think_fast" )

	//Spyglass: Be advised, the Militia fleet has completed refueling and are extracting all remaining ground forces. Do not allow them to escape.
	AddVDULineForSpyglass( "OverlookLostAnnouncement", "diag_imc_spyglass_cmp_frac_dustoff_lost_1_1", "spy_VDU_think_slow" )

	// RC1: "Mayday! Mayday! This is the Redeye, we're going down, we're going downn!!!" (explodes)
	//Sarah: "We've lost this sector to the IMC. I'm sending in the dropships. Check your HUD and get to the nearest evac point!"
	convRef = AddConversation( "OverlookLostAnnouncement", TEAM_MILITIA )
	AddVDURadio( convRef, "barker", null, "diag_mcor_comms_hp_frac_redeyegoingdown_01" )
	AddVDURadio( convRef, "sarah", null, "diag_mcor_sarah_bonus_frac_dustoff_lost_02"  )

	convRef = AddConversation( "OverlookWonAnnouncement", TEAM_MILITIA )
	AddVDURadio( convRef, "bish", null, "diag_gs_mcor_bish_gamewon_02"  ) // Bish: All right, we got what we came for! Awesome work team, mission accomplished.
	AddVDURadio( convRef, "sarah", null, "diag_mcor_sarah_bonus_frac_dustoff_won_01"  ) // Sarah: "We've done our part, and now it's time to get you outta there! Check your HUD and get to the nearest evac point!"

}