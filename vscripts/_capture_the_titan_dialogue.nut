
function main()
{
	RegisterCTTDialogue()
}

// Will be called from game_state_dialog.nut
function RegisterCTTDialogue()
{
	RegisterConversation( "GameModeAnnounce_CTT_Attack",		VO_PRIORITY_GAMEMODE )
	RegisterConversation( "GameModeAnnounce_CTT_Defend",		VO_PRIORITY_GAMEMODE )

	RegisterConversation( "CTT_TitanEmbarked",					VO_PRIORITY_GAMEMODE )
	RegisterConversation( "CTT_TitanHalfway_TitanPilotUpdate",					VO_PRIORITY_GAMEMODE )
	RegisterConversation( "CTT_TitanThreeQuarterMark_TitanPilotUpdate",					VO_PRIORITY_GAMEMODE )
	RegisterConversation( "CTT_TitanAtPoint_TitanPilotUpdate",					VO_PRIORITY_GAMEMODE )

	RegisterConversation( "CTT_TitanHalfway_AttackTeamUpdate",					VO_PRIORITY_GAMEMODE )
	RegisterConversation( "CTT_TitanThreeQuarterMark_AttackTeamUpdate",					VO_PRIORITY_GAMEMODE )
	RegisterConversation( "CTT_TitanAtPoint_AttackTeamUpdate",					VO_PRIORITY_GAMEMODE )

	RegisterConversation( "CTT_TitanHalfway_DefendTeamUpdate",					VO_PRIORITY_GAMEMODE )
	RegisterConversation( "CTT_TitanThreeQuarterMark_DefendTeamUpdate",					VO_PRIORITY_GAMEMODE )
	RegisterConversation( "CTT_TitanAtPoint_DefendTeamUpdate",					VO_PRIORITY_GAMEMODE )

	RegisterConversation( "CTT_TitanHalfHealth_AttackTeamAnnouncement",			VO_PRIORITY_GAMEMODE )
	RegisterConversation( "CTT_TitanHalfHealth_DefendTeamAnnouncement",			VO_PRIORITY_GAMEMODE )
 
	RegisterConversation( "CTT_TitanQuarterHealth_AttackTeamAnnouncement",			VO_PRIORITY_GAMEMODE )
	RegisterConversation( "CTT_TitanQuarterHealth_DefendTeamAnnouncement",			VO_PRIORITY_GAMEMODE )
 
	RegisterConversation( "CTT_TitanDestroyed_AttackTeamAnnouncement",			VO_PRIORITY_GAMEMODE )
	RegisterConversation( "CTT_TitanDestroyed_DefendTeamAnnouncement",			VO_PRIORITY_GAMEMODE )
 
	RegisterConversation( "CTT_TitanDestroyedByPlayer",			VO_PRIORITY_GAMEMODE )

	if ( IsServer() )
		return


	local convRef

	/*
	*
	*  Militia lines
	*
	*/

	//Not sure which option we'll do yet, so hook all the lines to the same alias. Adjust later once we decide
	//Bish: This is a Titan Capture Mission. Get our Titan to the Extraction Zone!
	//Bish: This is a Titan Capture Mission. Get our Titan to the Hardpoint!
	//Bish: This is a Titan Capture Mission. Get our Titan to a Hardpoint!
	convRef = AddConversation( "GameModeAnnounce_CTT_Attack", TEAM_MILITIA )
	AddRadio( convRef, "diag_gm_ctt_modeAnncEscort_mcor_Bish" )


	//Bish: Listen up people. Take out the enemy Titan. Do not let it approach the Extraction Zone!
	//Bish: Pilots, take out the enemy Titan. Do not let it reach the Hardpoint!
	//Bish: Pilots, take out the enemy Titan. Do not let it reach a Hardpoint!
	convRef = AddConversation( "GameModeAnnounce_CTT_Defend", TEAM_MILITIA )
	AddRadio( convRef, "diag_gm_ctt_modeAnncBlock_mcor_Bish" )

	//Bish: Alright Boss, bring that Titan to the Extraction Zone. Make sure it gets there in one piece!
	//Bish: Alright Boss, bring that Titan to the Hardpoint. Make sure it gets there in one piece!
	//Bish: Alright Boss, bring that Titan to a Hardpoint. Make sure it gets there in one piece!
	convRef = AddConversation( "CTT_TitanEmbarked", TEAM_MILITIA )
	AddRadio( convRef, "diag_gm_ctt_playerEnterTitan_mcor_Bish" )

	//Bish: All right team, our Titan's halfway to the Hardpoint. Pilots, keep defending out Titan from the IMC!
	//Bish: All right team, our Titan's halfway to the Extraction Zone. Pilots, keep defending out Titan from the IMC!
	convRef = AddConversation( "CTT_TitanHalfway_AttackTeamUpdate", TEAM_MILITIA )
	AddRadio( convRef, "diag_gm_ctt_halfwayGoalTeamTitan_mcor_Bish" )

	//Bish:Pilots, our Titan is almost at the Hardpoint. Clear the area ahead of IMC units!
	//Bish:Pilots, our Titan is almost at the Extraction Zone. Clear the area ahead of IMC units!
	convRef = AddConversation( "CTT_TitanThreeQuarterMark_AttackTeamUpdate", TEAM_MILITIA )
	AddRadio( convRef, "diag_gm_ctt_nearGoalTeamTitan_mcor_Bish" )

	//Bish:Our Titan is at the Extraction Point! Defend it until it escapes!
	//Bish:You're at the Hardpoint! Make sure the Titan stays alive while we capture the point!
	convRef = AddConversation( "CTT_TitanAtPoint_AttackTeamUpdate", TEAM_MILITIA )
	AddRadio( convRef, "diag_gm_ctt_arriveAtGoalMyTitan_mcor_Bish" )

	//Bish: Boss, you're halfway to the Extraction Zone. Keep pushing forward!
	//Bish: Boss, you're halfway to the Hardpoint. Keep pushing forward!
	convRef = AddConversation( "CTT_TitanHalfway_TitanPilotUpdate", TEAM_MILITIA )
	AddRadio( convRef, "diag_gm_ctt_halfwayGoalMyTitan_mcor_Bish" )

	//Bish: Pilot, you're almost at the Extraction Zone. Don't let up now!
	//Bish: Boss, you're almost at the Hardpoint. Don't let up now!
	convRef = AddConversation( "CTT_TitanThreeQuarterMark_TitanPilotUpdate", TEAM_MILITIA )
	AddRadio( convRef, "diag_gm_ctt_nearGoalMyTitan_mcor_Bish" )

	//Bish: You're at the Hardpoint! Make sure the Titan stays alive while we capture the point!
	//Bish: You're at the Extraction Zone! Make sure the Titan stays alive until we can get it out of here!
	convRef = AddConversation( "CTT_TitanAtPoint_TitanPilotUpdate", TEAM_MILITIA )
	AddRadio( convRef, "diag_gm_ctt_arriveAtGoalMyTitan_mcor_Bish" )

	//Bish: Boss, the Enemy Titan is halfway to the Hardpoint. Don't let it get any closer!
	//Bish: Boss, the Enemy Titan is halfway to the Extraction Zone. Don't let it get any closer!
	convRef = AddConversation( "CTT_TitanHalfway_DefendTeamUpdate", TEAM_MILITIA )
	AddRadio( convRef, "diag_gm_ctt_halfwayGoalEnemyTitan_mcor_Bish" )

	//Bish: The Enemy Titan is almost at the Hardpoint. You need to take it out right now!
	//Bish: The Enemy Titan is almost at the Extraction Zone. You need to take it out right now!
	convRef = AddConversation( "CTT_TitanThreeQuarterMark_DefendTeamUpdate", TEAM_MILITIA )
	AddRadio( convRef, "diag_gm_ctt_nearGoalEnemyTitan_mcor_Bish" )

	//Bish: The Enemy Titan is at the Hardpoint! We need to take it out right now people!
	//Bish: The Enemy Titan is at the Extraction Zone! We need to take it out right now people!
	convRef = AddConversation( "CTT_TitanAtPoint_DefendTeamUpdate", TEAM_MILITIA )
	AddRadio( convRef, "diag_gm_ctt_arriveAtGoalEnemyTitan_mcor_Bish" )

	//Bish: All Units, our Titan has taken heavy damage. You need to defend it from those Militia terrorists!
	convRef = AddConversation( "CTT_TitanHalfHealth_AttackTeamAnnouncement", TEAM_MILITIA )
	AddRadio( convRef, "diag_gm_ctt_halfHealthTeamTitan_mcor_Bish" )

	//Bish: Our Titan is nearly destroyed! Pilots, you need to defend the Titan now!
	convRef = AddConversation( "CTT_TitanQuarterHealth_AttackTeamAnnouncement", TEAM_MILITIA )
	AddRadio( convRef, "diag_gm_ctt_lowHealthTeamTitan_mcor_Bish" )

	//Bish: Our Titan has been destroyed!
	convRef = AddConversation( "CTT_TitanDestroyed_AttackTeamAnnouncement", TEAM_MILITIA )
	AddRadio( convRef, "diag_gm_ctt_ourTitanKilled_mcor_Bish" )

	//Bish: All Units, be advised. The Militia Titan has taken heavy damage. Keep it up Pilots!
	convRef = AddConversation( "CTT_TitanHalfHealth_DefendTeamAnnouncement", TEAM_MILITIA )
	AddRadio( convRef, "diag_gm_ctt_halfHealthEnemyTitan_mcor_Bish" )

	//Bish: The Militia Titan is nearly destroyed. Don't let up!
	convRef = AddConversation( "CTT_TitanQuarterHealth_DefendTeamAnnouncement", TEAM_MILITIA )
	AddRadio( convRef, "diag_gm_ctt_lowHealthEnemyTitan_mcor_Bish" )

	//Bish: The Militia Titan is destroyed! Good job Pilots.
	convRef = AddConversation( "CTT_TitanDestroyed_DefendTeamAnnouncement", TEAM_MILITIA )
	AddRadio( convRef, "diag_gm_ctt_enemyTitanTeamKill_mcor_Bish" )

	//Bish: You took down the IMC Titan! Great job Boss!
	convRef = AddConversation( "CTT_TitanDestroyedByPlayer", TEAM_MILITIA )
	AddRadio( convRef, "diag_gm_ctt_enemyTitanPlayerKill_mcor_Bish" )


	/*
	*
	*  IMC lines
	*
	*/
	//Not sure which option we'll do yet, so hook all the lines to the same alias. Adjust later once we decide
	//Blisk: This is a Titan Capture Mission. Get our Titan to the Extraction Zone!
	//Blisk: This is a Titan Capture Mission. Get our Titan to the Hardpoint!
	//Blisk: This is a Titan Capture Mission. Get our Titan to a Hardpoint!
	convRef = AddConversation( "GameModeAnnounce_CTT_Attack", TEAM_IMC )
	AddRadio( convRef, "diag_gm_ctt_modeAnncEscort_imc_Blisk" )

	//Blisk: All Units, be advised. Take out the enemy Titan. Do not let them approach the Extraction Zone!
	//Blisk: Pilots, take out the enemy Titan. Do not let it reach the Hardpoint!
	//Blisk: Pilots, take out the enemy Titan. Do not let it reach a Hardpoint!
	convRef = AddConversation( "GameModeAnnounce_CTT_Defend", TEAM_IMC )
	AddRadio( convRef, "diag_gm_ctt_modeAnncBlock_imc_Blisk" )


	//Blisk: Pilot, bring that Titan to the Extraction Zone. Make sure it gets there in one piece!
	//Blisk: Pilot, bring that Titan to the Hardpoint. Make sure it gets there in one piece!
	//Blisk: Pilot, bring that Titan to a Hardpoint. Make sure it gets there in one piece!
	convRef = AddConversation( "CTT_TitanEmbarked", TEAM_IMC )
	AddRadio( convRef, "diag_gm_ctt_playerEnterTitan_imc_Blisk" )

	//Blisk: Our Titan's halfway to the Hardpoint. Pilots, keep defending our Titan from the Militia.
	//Blisk: Our Titan's halfway to the Extraction Zone. Pilots, keep defending our Titan from the Militia.
	convRef = AddConversation( "CTT_TitanHalfway_AttackTeamUpdate", TEAM_IMC )
	AddRadio( convRef, "diag_gm_ctt_halfwayGoalTeamTitan_imc_Blisk" )

	//Blisk: Pilots, our Titan is almost at the Hardpoint. Clear the area ahead of hostiles!
	//Blisk: Pilots, our Titan is almost at the Extraction Zone. Clear the area ahead of hostiles!
	convRef = AddConversation( "CTT_TitanThreeQuarterMark_AttackTeamUpdate", TEAM_IMC )
	AddRadio( convRef, "diag_gm_ctt_nearGoalTeamTitan_imc_Blisk" )

	//Blisk: Our Titan is at the Hardpoint! Defend it while it's capping the point!
	//Blisk: Our Titan is at the Extraction Point! Defend it until it escapes!
	convRef = AddConversation( "CTT_TitanAtPoint_AttackTeamUpdate", TEAM_IMC )
	AddRadio( convRef, "diag_gm_ctt_arriveAtGoalMyTitan_imc_Blisk" )

	//Blisk: Pilot, you're halfway to the Extraction Zone. Keep pushing forward!
	//Blisk: Pilot, you're halfway to the Hardpoint. Keep pushing forward!
	convRef = AddConversation( "CTT_TitanHalfway_TitanPilotUpdate", TEAM_IMC )
	AddRadio( convRef, "diag_gm_ctt_halfwayGoalMyTitan_imc_Blisk" )

	//Blisk: Pilot, you're almost at the Extraction Zone. Don't let up now!
	//Blisk: Pilot, you're almost at the Hardpoint. Don't let up now!
	convRef = AddConversation( "CTT_TitanThreeQuarterMark_TitanPilotUpdate", TEAM_IMC )
	AddRadio( convRef, "diag_gm_ctt_nearGoalMyTitan_imc_Blisk" )

	//Blisk: You're at the Hardpoint! Make sure the Titan stays alive while we capture the point!
	//Blisk: You're at the Extraction Zone! Make sure the Titan stays alive until we can get it out of here!
	convRef = AddConversation( "CTT_TitanAtPoint_TitanPilotUpdate", TEAM_IMC )
	AddRadio( convRef, "diag_gm_ctt_arriveAtGoalMyTitan_imc_Blisk" )

	//Blisk: Pilots, the Enemy Titan is halfway to the Hardpoint. Do not let it get any closer!
	//Blisk: Pilots, the Enemy Titan is halfway to the Extraction Zone. Do not let it get any closer!
	convRef = AddConversation( "CTT_TitanHalfway_DefendTeamUpdate", TEAM_IMC )
	AddRadio( convRef, "diag_gm_ctt_halfwayGoalEnemyTitan_imc_Blisk" )

	//Blisk: Pilots, the Enemy Titan is almost at the Hardpoint. Take it out immediately!
	//Blisk: Pilots, the Enemy Titan is almost at the Extraction Zone. Do not let it get any closer!
	convRef = AddConversation( "CTT_TitanThreeQuarterMark_DefendTeamUpdate", TEAM_IMC )
	AddRadio( convRef, "diag_gm_ctt_nearGoalEnemyTitan_imc_Blisk" )

	//Blisk: The Enemy Titan is at the Hardpoint! This is our last chance. Bring it down now!
	//Blisk: The Enemy Titan is at the Extraction Zone! This is our last chance. Bring it down now!
	convRef = AddConversation( "CTT_TitanAtPoint_DefendTeamUpdate", TEAM_IMC )
	AddRadio( convRef, "diag_gm_ctt_arriveAtGoalEnemyTitan_imc_Blisk" )

	//Blisk: All Units, our Titan has taken heavy damage. You need to defend it from those Militia terrorists!
	convRef = AddConversation( "CTT_TitanHalfHealth_AttackTeamAnnouncement", TEAM_IMC )
	AddRadio( convRef, "diag_gm_ctt_halfHealthTeamTitan_imc_Blisk" )

	//Blisk: Our Titan is nearly destroyed! Pilots, you need to defend the Titan now!
	convRef = AddConversation( "CTT_TitanQuarterHealth_AttackTeamAnnouncement", TEAM_IMC )
	AddRadio( convRef, "diag_gm_ctt_lowHealthTeamTitan_imc_Blisk" )

	//Blisk: Our Titan has been destroyed!
	convRef = AddConversation( "CTT_TitanDestroyed_AttackTeamAnnouncement", TEAM_IMC )
	AddRadio( convRef, "diag_gm_ctt_ourTitanKilled_imc_Blisk" )

	//Blisk: All Units, be advised. The Militia Titan has taken heavy damage. Keep it up Pilots!
	convRef = AddConversation( "CTT_TitanHalfHealth_DefendTeamAnnouncement", TEAM_IMC )
	AddRadio( convRef, "diag_gm_ctt_halfHealthEnemyTitan_imc_Blisk" )

	//Blisk: The Militia Titan is nearly destroyed. Don't let up!
	convRef = AddConversation( "CTT_TitanQuarterHealth_DefendTeamAnnouncement", TEAM_IMC )
	AddRadio( convRef, "diag_gm_ctt_lowHealthEnemyTitan_imc_Blisk" )

	//Blisk: The Militia Titan is destroyed! Good job Pilots.
	convRef = AddConversation( "CTT_TitanDestroyed_DefendTeamAnnouncement", TEAM_IMC )
	AddRadio( convRef, "diag_gm_ctt_enemyTitanTeamKill_imc_Blisk" )

	//Blisk: You took down the Militia Titan! Well done Pilot.
	convRef = AddConversation( "CTT_TitanDestroyedByPlayer", TEAM_IMC )
	AddRadio( convRef, "diag_gm_ctt_enemyTitanPlayerKill_imc_Blisk" )





}
