
function main()
{
	if ( !GetCinematicMode() )
		return

	if ( GAMETYPE != CAPTURE_POINT )
		return

	RegisterConversation( "fracture_redeye_75_percent_integrity",	VO_PRIORITY_GAMESTATE )
	RegisterConversation( "fracture_redeye_50_percent_integrity",	VO_PRIORITY_GAMESTATE )
	RegisterConversation( "fracture_redeye_25_percent_integrity",	VO_PRIORITY_GAMESTATE )
	//Fracture specific AI chatter
	RegisterConversation( "fracture_grunt_chatter",                 VO_PRIORITY_AI_CHATTER_LOW )

	RegisterConversation( "FractureLostAnnouncement", VO_PRIORITY_GAMESTATE )
	RegisterConversation( "FractureWonAnnouncement", VO_PRIORITY_GAMESTATE )

	RegisterConversation( "fracture_storyEnd", VO_PRIORITY_STORY )

	CapturePointDialogOverride()

	if ( IsServer() )
		return

	RegisterFractureAIChatter()

	local convRef

	//##################################
	//	 Blisk (IMC version of Bish)
	//##################################

	// Blisk: "The Redeye's at 75% hull integrity."
	convRef = AddConversation( "fracture_redeye_75_percent_integrity", TEAM_IMC )
	AddVDURadio( convRef, "blisk", "diag_imc_blisk_hp_frac_redeyedamage_01" )

	// Blisk: "The Redeye's at 50% hull integrity."
	convRef = AddConversation( "fracture_redeye_50_percent_integrity", TEAM_IMC )
	AddVDURadio( convRef, "blisk", "diag_imc_blisk_hp_frac_redeyedamage_02" )

	// Blisk: "The Redeye's now at 25% hull integrity."
	convRef = AddConversation( "fracture_redeye_25_percent_integrity", TEAM_IMC )
	AddVDURadio( convRef, "blisk", "diag_imc_blisk_hp_frac_redeyedamage_03" )

	// Blisk: "All units, be advised, mission accomplished, we have destroyed the Redeye. Fine work all around. Come on home."
	//Spyglass: Be advised. The militia forces have been defeated, but enemy units remain in your area. Do not allow them to escape
	convRef = AddConversation( "FractureWonAnnouncement", TEAM_IMC )
	AddVDURadio( convRef, "blisk", "diag_imc_blisk_hp_frac_redeyedamage_04" )
	AddVDURadio( convRef, "spyglass", "diag_imc_spyglass_cmp_frac_dustoff_won_1_1", "spy_VDU_think_fast" )

	//Use default lines from game_state_dialogue until we get rewritten ones
	local convRef = AddConversation( "FractureLostAnnouncement", TEAM_IMC )
	AddVDUAnimWithEmbeddedAudio( convRef, "blisk", "diag_imc_blisk_gs_gamelost_01" ) // Blisk: All units, return to HQ, we are terminating this mission effective immediately.
	AddVDURadio( convRef, "spyglass", "diag_imc_spyglass_gs_EvacAnnc_imcLoss_59", "spy_VDU_think_slow" ) //Spyglass: Mission Aborted. Proceed to nearest extraction point for evacuation.

    local convRef = AddConversation( "FractureLostAnnouncement", TEAM_IMC )
	AddVDUAnimWithEmbeddedAudio( convRef, "blisk", "diag_imc_blisk_gs_gamelost_02" ) // Blisk: All units, abort mission, I repeat, abort mission. We are out of here.
	AddVDURadio( convRef, "spyglass", "diag_imc_spyglass_gs_EvacAnnc_imcLoss_60", "spy_VDU_think_fast" ) //Spyglass: A tactical withdrawal has been ordered. Dropships deployed for evacuation. Proceed to nearest extraction point.

	local convRef = AddConversation( "FractureLostAnnouncement", TEAM_IMC )
	AddVDUAnimWithEmbeddedAudio( convRef, "blisk", "diag_imc_blisk_gs_gamelost_03" ) // Blisk: Tac Six to all units, we have been defeated. We're cutting our losses and getting the hell out of here.
	AddVDURadio( convRef, "spyglass", "diag_imc_spyglass_gs_EvacAnnc_imcLoss_59", "spy_VDU_think_slow" ) // //Spyglass: Mission Aborted. Proceed to nearest extraction point for evacuation.


	//##################################
	//	 Evac Post Epilogue Lines
	//##################################


	//Blisk: Hmph, we didn't even kill half their fleet. 54 ships destroyed. That's it.
	//Graves: And how many civilians?
	//Blisk: Today’s civilians are just tomorrow’s Militia, sir. What do you want me to do? Wait?
	//Graves: Start a search. I want that fleet found. Graves out.

	convRef = AddConversation( "fracture_storyEnd", TEAM_IMC )
	AddRadio( convRef, "diag_epPost_FR103_01_01_imc_blisk" )
	AddRadio( convRef, "diag_epPost_FR103_02_01_imc_graves" )
	AddRadio( convRef, "diag_epPost_FR103_03_01_imc_blisk" )
	AddRadio( convRef, "diag_epPost_FR103_04_01_imc_graves" )


	//##################################
	//	Redeye Comms & Bish (MILITIA)
	//##################################

	// RC1: "This is the Redeye! We're taking a lot of flak! Bish, we need those turrets offline a-sap!"
	// Bish: "We're on it! - Boss, get close to a hardpoint and patch me in so I can deal with the turrets!"
	convRef = AddConversation( "fracture_redeye_75_percent_integrity", TEAM_MILITIA )
	AddVDUAnimWithEmbeddedAudio( convRef, "barker", "diag_mcor_comms_hp_frac_redeyedmg_01" )
	AddVDUAnimWithEmbeddedAudio( convRef, "bish", "diag_hp_frac_mcor_bish_redeyedamage_01" )

	// RC1: "This is the Redeye! Bish, we're at 50% hull integrity and dropping fast!"
	// Bish: "Understood Redeye - buddy you gotta get me patched into another hardpoint, move!"
	convRef = AddConversation( "fracture_redeye_50_percent_integrity", TEAM_MILITIA )
	AddVDUAnimWithEmbeddedAudio( convRef, "barker", "diag_mcor_comms_hp_frac_redeyedmg_02" )
	AddVDUAnimWithEmbeddedAudio( convRef, "bish", "diag_hp_frac_mcor_bish_redeyedamage_03" )

	// RC1: "This is the Redeye! We're almost done for! Bish I need those turrets offline now!"
	// Bish: "Working on it Redeye! - Boss, you gotta patch me into a hardpoint, like now!"
	convRef = AddConversation( "fracture_redeye_25_percent_integrity", TEAM_MILITIA )
	AddVDUAnimWithEmbeddedAudio( convRef, "barker", "diag_mcor_comms_hp_frac_redeyedmg_03" )
	AddVDUAnimWithEmbeddedAudio( convRef, "bish", "diag_hp_frac_mcor_bish_redeyedamage_04" )

	// RC1: "Mayday! Mayday! This is the Redeye, we're going down, we're going downn!!!" (explodes)
	//Sarah: "We've lost this sector to the IMC. I'm sending in the dropships. Check your HUD and get to the nearest evac point!"
	convRef = AddConversation( "FractureLostAnnouncement", TEAM_MILITIA )
	AddVDURadio( convRef, "barker", null, "diag_mcor_comms_hp_frac_redeyegoingdown_01" )
	AddVDURadio( convRef, "sarah", null, "diag_mcor_sarah_bonus_frac_dustoff_lost_02"  )

	convRef = AddConversation( "FractureWonAnnouncement", TEAM_MILITIA )
	AddVDURadio( convRef, "bish", null, "diag_gs_mcor_bish_gamewon_02"  ) // Bish: All right, we got what we came for! Awesome work team, mission accomplished.
	AddVDURadio( convRef, "sarah", null, "diag_mcor_sarah_gs_EvacAnnc_mcorWin_74" ) // Sarah: We've beaten the IMC, but the battle's not over yet! Intercept any stragglers before they get away!

	//##################################
	//	 Evac Post Epilogue Lines
	//##################################

	//Bish: Well, the fleet’s got enough fuel to get through another month.
	//Sarah: That was chaos down there, Bish. Our tactics are a mess.
	//Bish: 	Sarah, Neither of us has any experience leading a force of this size. We gotta find ourselves a real field commander.
	//Sarah: Then we're gonna have to work with what we've got. We're outta options.
	convRef = AddConversation( "fracture_storyEnd", TEAM_MILITIA )
	AddRadio( convRef, "diag_epPost_FR104_01_01_mcor_bish" )
	AddRadio( convRef, "diag_epPost_FR104_02_01_mcor_sarah" )
	AddRadio( convRef, "diag_epPost_FR104_03_01_mcor_bish" )
	AddRadio( convRef, "diag_epPost_FR104_04_01_mcor_sarah" )

}

function RegisterFractureAIChatter()
{
	FractureAddConversations( TEAM_MILITIA, level.actorsABCD )
	FractureAddConversations( TEAM_IMC, level.actorsABCD )
}

function FractureAddConversations( team, actors )
{

	//Fracture specific lines
	Assert ( GetMapName() == "mp_fracture" )
	local conversation = "fracture_grunt_chatter"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment2L_01_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_FR_comment2L_01_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment2L_02_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_FR_comment2L_02_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment2L_03_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_FR_comment2L_03_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment2L_04_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_FR_comment2L_04_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment2L_05_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_FR_comment2L_05_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment2L_06_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_FR_comment2L_06_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment2L_07_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_FR_comment2L_07_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment2L_08_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_FR_comment2L_08_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment2L_09_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_FR_comment2L_09_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment3L_01_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_FR_comment3L_01_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment3L_01_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment3L_02_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_FR_comment3L_02_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment3L_02_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment3L_03_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_FR_comment3L_03_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment3L_03_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment3L_04_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_FR_comment3L_04_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment3L_04_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment3L_05_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_FR_comment3L_05_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment3L_05_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment3L_06_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_FR_comment3L_06_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment3L_06_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment3L_07_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_FR_comment3L_07_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment3L_07_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment3L_08_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_FR_comment3L_08_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment3L_08_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment3L_09_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_FR_comment3L_09_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment3L_09_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment3L_10_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_FR_comment3L_10_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment3L_10_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment3L_11_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_FR_comment3L_11_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment3L_11_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment3L_12_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_FR_comment3L_12_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment3L_12_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment3L_13_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_FR_comment3L_13_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment3L_13_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment3L_14_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_FR_comment3L_14_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment3L_14_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment3L_15_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_FR_comment3L_15_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment3L_15_03", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment4L_01_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_FR_comment4L_01_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment4L_01_03", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_FR_comment4L_01_04", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment4L_02_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_FR_comment4L_02_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment4L_02_03", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_FR_comment4L_02_04", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment4L_03_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_FR_comment4L_03_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment4L_03_03", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_FR_comment4L_03_04", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment4L_04_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_FR_comment4L_04_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_FR_comment4L_04_03", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_FR_comment4L_04_04", actors )]}
	]
	AddConversation( conversation, team, lines )

}

function CapturePointDialogOverride()
{
	local dialogAliases = level.dialogAliases

	// this clears the VDU whitelist
	level.whiteList[ TEAM_MILITIA ] = {}
	level.whiteList[ TEAM_IMC ] = {}

	/**************************************
	/***************************************/
	/***********  TEAM MILITIA  ************/
	/***************************************/
	/***************************************/

	// lost all hardpoint
	dialogAliases[TEAM_MILITIA]["hardpoint_lost_all"] = ["diag_hp_frac_mcor_bish_allpumpsdown_03", "diag_hp_frac_mcor_bish_allpumpsdown_04", "diag_hp_frac_mcor_bish_allpumpsdown_05", "diag_hp_frac_mcor_bish_pumpsdownturretsup_01", "diag_hp_frac_mcor_bish_pumpsdownturretsup_02", "diag_hp_frac_mcor_bish_pumpsdownturretsup_03"]

	// Starting cap from enemy controlled
	dialogAliases[TEAM_MILITIA]["hardpoint_status_0_a"] = ["diag_cmp_frac_mcor_bish_deactivatedef_01", "diag_cmp_frac_mcor_bish_deactivatedef_02", "diag_hp_frac_mcor_bish_deactivateairturret_01", "diag_hp_frac_mcor_bish_deactivateairturret_02", "diag_hp_frac_mcor_bish_deactivateairturret_stay_01", "diag_hp_frac_mcor_bish_deactivateairturret_stay_02", "diag_hp_frac_mcor_bish_deactivateturret_01", "diag_hp_frac_mcor_bish_deactivateturret_02"]
	dialogAliases[TEAM_MILITIA]["hardpoint_status_0_b"] = ["diag_cmp_frac_mcor_bish_deactivatedef_01", "diag_cmp_frac_mcor_bish_deactivatedef_03", "diag_hp_frac_mcor_bish_deactivateairturret_01", "diag_hp_frac_mcor_bish_deactivateairturret_03", "diag_hp_frac_mcor_bish_deactivateairturret_stay_01", "diag_hp_frac_mcor_bish_deactivateairturret_stay_03", "diag_hp_frac_mcor_bish_deactivateturret_01", "diag_hp_frac_mcor_bish_deactivateturret_03"]
	dialogAliases[TEAM_MILITIA]["hardpoint_status_0_c"] = ["diag_cmp_frac_mcor_bish_deactivatedef_01", "diag_cmp_frac_mcor_bish_deactivatedef_04", "diag_hp_frac_mcor_bish_deactivateairturret_01", "diag_hp_frac_mcor_bish_deactivateairturret_04", "diag_hp_frac_mcor_bish_deactivateairturret_stay_01", "diag_hp_frac_mcor_bish_deactivateairturret_stay_04", "diag_hp_frac_mcor_bish_deactivateturret_01", "diag_hp_frac_mcor_bish_deactivateturret_04"]
	dialogAliases[TEAM_MILITIA]["hardpoint_status_25"] = ["diag_hp_frac_mcor_bish_airdefdeactivate_01", "diag_hp_frac_mcor_bish_turretdeactivate_01", "diag_hp_mcor_bish_generalpurpose_noprefix_03"]
	dialogAliases[TEAM_MILITIA]["hardpoint_status_50"] = ["diag_hp_frac_mcor_bish_airdefdeactivate_02", "diag_hp_frac_mcor_bish_turretdeactivate_02", "diag_hp_mcor_bish_generalpurpose_noprefix_02"]
	dialogAliases[TEAM_MILITIA]["hardpoint_status_75"] = ["diag_hp_frac_mcor_bish_airdefdeactivate_03", "diag_hp_frac_mcor_bish_turretdeactivate_03" ,"diag_hp_mcor_bish_generalpurpose_noprefix_01"]
	dialogAliases[TEAM_MILITIA]["hardpoint_status_100"] = ["diag_hp_frac_mcor_bish_airdefdeactivate_04", "diag_hp_frac_mcor_bish_turretdeactivate_04"]

	// Continuing cap after neutralizing hardpoint
	dialogAliases[TEAM_MILITIA]["hardpoint_status_neutral_0_a"] = ["diag_cmp_frac_mcor_bish_activatefuel_01", "diag_cmp_frac_mcor_bish_activatefuel_02", "diag_hp_frac_mcor_bish_activatefuel_05", "diag_hp_frac_mcor_bish_activatefuel_06"]
	dialogAliases[TEAM_MILITIA]["hardpoint_status_neutral_0_b"] = ["diag_cmp_frac_mcor_bish_activatefuel_01", "diag_cmp_frac_mcor_bish_activatefuel_03", "diag_hp_frac_mcor_bish_activatefuel_05", "diag_hp_frac_mcor_bish_activatefuel_07"]
	dialogAliases[TEAM_MILITIA]["hardpoint_status_neutral_0_c"] = ["diag_cmp_frac_mcor_bish_activatefuel_01", "diag_cmp_frac_mcor_bish_activatefuel_04", "diag_hp_frac_mcor_bish_activatefuel_05", "diag_hp_frac_mcor_bish_activatefuel_08"]
	dialogAliases[TEAM_MILITIA]["hardpoint_status_neutral_25"] = ["diag_hp_frac_mcor_bish_fuelpumphack_02", "diag_hp_frac_mcor_bish_fuelsystemsroute_02", "diag_hp_mcor_bish_generalpurpose_noprefix_03"]
	dialogAliases[TEAM_MILITIA]["hardpoint_status_neutral_50"] = ["diag_hp_frac_mcor_bish_fuelpumphack_03", "diag_hp_frac_mcor_bish_fuelsystemsroute_03", "diag_hp_mcor_bish_generalpurpose_noprefix_02"]
	dialogAliases[TEAM_MILITIA]["hardpoint_status_neutral_75"] = ["diag_hp_frac_mcor_bish_fuelpumphack_04", "diag_hp_frac_mcor_bish_fuelsystemsroute_04", "diag_hp_mcor_bish_generalpurpose_noprefix_01"]
	dialogAliases[TEAM_MILITIA]["hardpoint_status_neutral_100"] =["diag_hp_frac_mcor_bish_fuelpumphack_05", "diag_hp_frac_mcor_bish_fuelsystemsroute_05"]

	// Starting cap from neutral
	dialogAliases[TEAM_MILITIA]["hardpoint_player_capping_a"] = ["diag_hp_frac_mcor_bish_fuelpumphack_01", "diag_hp_frac_mcor_bish_fuelsystemsroute_01"]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_capping_b"] = ["diag_hp_frac_mcor_bish_fuelpumphack_01", "diag_hp_frac_mcor_bish_fuelsystemsroute_01"]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_capping_c"] = ["diag_hp_frac_mcor_bish_fuelpumphack_01", "diag_hp_frac_mcor_bish_fuelsystemsroute_01"]

	// Capturing 1 of 3
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_get_ac"] = "diag_hp_frac_mcor_bish_progressdonemove_02"
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_get_bc"] = "diag_hp_frac_mcor_bish_progressdonemove_01"
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_get_ab"] = "diag_hp_frac_mcor_bish_progressdonemove_03"

	// Capturing 2 of 3
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_get_a_b"] = ["diag_cmp_frac_mcor_bish_pumponline_01", "diag_cmp_frac_mcor_bish_pumponline_03"]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_get_a_c"] = ["diag_cmp_frac_mcor_bish_pumponline_01"]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_get_b_a"] = ["diag_cmp_frac_mcor_bish_pumponline_01", "diag_cmp_frac_mcor_bish_pumponline_02"]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_get_b_c"] = ["diag_cmp_frac_mcor_bish_pumponline_01"]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_get_c_a"] = ["diag_cmp_frac_mcor_bish_pumponline_01", "diag_cmp_frac_mcor_bish_pumponline_02"]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_get_c_b"] = ["diag_cmp_frac_mcor_bish_pumponline_01", "diag_cmp_frac_mcor_bish_pumponline_03"]
	// dummy lines for the registering to work // not good
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_get_a_a"] = ["diag_cmp_frac_mcor_bish_pumponline_01"]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_get_b_b"] = ["diag_cmp_frac_mcor_bish_pumponline_01"]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_get_c_c"] = ["diag_cmp_frac_mcor_bish_pumponline_01"]
	// alt lines
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_get_one"] = ["diag_hp_frac_mcor_bish_fuelsystemsroute_05", "diag_hp_frac_mcor_bish_fuelpumphack_05"]

	// Capturing 3 of 3
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_a"] = ["diag_hp_frac_mcor_bish_allpointscontrolled_01", "diag_hp_frac_mcor_bish_allpointscontrolled_02", "diag_hp_frac_mcor_bish_fuelpumphack_05", "diag_hp_frac_mcor_bish_fuelsystemsroute_05"]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_b"] = ["diag_hp_frac_mcor_bish_allpointscontrolled_01", "diag_hp_frac_mcor_bish_allpointscontrolled_02", "diag_hp_frac_mcor_bish_fuelpumphack_05", "diag_hp_frac_mcor_bish_fuelsystemsroute_05"]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_c"] = ["diag_hp_frac_mcor_bish_allpointscontrolled_01", "diag_hp_frac_mcor_bish_allpointscontrolled_02", "diag_hp_frac_mcor_bish_fuelpumphack_05", "diag_hp_frac_mcor_bish_fuelsystemsroute_05"]

	// Capturing with enemies close by
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_enemy_a"] = ["diag_cmp_frac_mcor_bish_pumponline_01"]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_enemy_b"] = ["diag_cmp_frac_mcor_bish_pumponline_01"]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_enemy_c"] = ["diag_cmp_frac_mcor_bish_pumponline_01"]

	// Capturing outside of scene
	dialogAliases[TEAM_MILITIA]["hardpoint_captured_a"] = ["diag_cmp_frac_mcor_bish_pumponline_02"]
	dialogAliases[TEAM_MILITIA]["hardpoint_captured_b"] = ["diag_cmp_frac_mcor_bish_pumponline_03"]
	dialogAliases[TEAM_MILITIA]["hardpoint_captured_c"] = ["diag_cmp_frac_mcor_bish_pumponline_04"]


	/***************************************/
	/***************************************/
	/*************  TEAM IMC  **************/
	/***************************************/
	/***************************************/

	// finishing capturing a hardpoint
//	dialogAliases[TEAM_IMC]["hardpoint_status_neutral_100"] =["diag_hp_mcor_bish_datanouns_05"]
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_get_one"] =["diag_imc_blisk_SecuredHp_05"]

	// Capturing 3 of 3
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_a"] <- ["diag_imc_blisk_hp_frac_allhpundercontrol_01", "diag_imc_blisk_hp_frac_allhpundercontrol_02"]
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_b"] <- ["diag_imc_blisk_hp_frac_allhpundercontrol_01", "diag_imc_blisk_hp_frac_allhpundercontrol_02"]
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_c"] <- ["diag_imc_blisk_hp_frac_allhpundercontrol_01", "diag_imc_blisk_hp_frac_allhpundercontrol_02"]

	// lost all hardpoint
	dialogAliases[TEAM_IMC]["hardpoint_lost_all"] = ["diag_imc_blisk_hp_frac_turretsdown_01",
													 "diag_imc_blisk_hp_frac_turretsdown_02",
													 "diag_imc_blisk_hp_frac_turretsdown_03",
													 "diag_imc_blisk_hp_frac_turretsdown_04",
													 "diag_imc_blisk_hp_frac_turretsdown_05",
													 "diag_imc_blisk_hp_frac_turretsdownpumpsfull_01",
													 "diag_imc_blisk_hp_frac_turretsdownpumpsfull_02",
													 "diag_imc_blisk_hp_frac_turretsdownpumpsfull_03"]

	// Starting cap from enemy controlled
	dialogAliases[TEAM_IMC]["hardpoint_status_0_a"] = ["diag_imc_blisk_hp_frac_deactivatingfuelpumps_01", "diag_imc_blisk_hp_frac_deactivatingfuelpumps_02", "diag_imc_blisk_hp_frac_deactivatingfuelstayclose_01", "diag_imc_blisk_hp_frac_deactivatingfuelstayclose_02"]
	dialogAliases[TEAM_IMC]["hardpoint_status_0_b"] = ["diag_imc_blisk_hp_frac_deactivatingfuelpumps_01", "diag_imc_blisk_hp_frac_deactivatingfuelpumps_03", "diag_imc_blisk_hp_frac_deactivatingfuelstayclose_01", "diag_imc_blisk_hp_frac_deactivatingfuelstayclose_03"]
	dialogAliases[TEAM_IMC]["hardpoint_status_0_c"] = ["diag_imc_blisk_hp_frac_deactivatingfuelpumps_01", "diag_imc_blisk_hp_frac_deactivatingfuelpumps_04", "diag_imc_blisk_hp_frac_deactivatingfuelstayclose_01", "diag_imc_blisk_hp_frac_deactivatingfuelstayclose_04"]
	dialogAliases[TEAM_IMC]["hardpoint_status_25"] = ["diag_imc_blisk_hp_frac_pumpdeactivate_01"]
	dialogAliases[TEAM_IMC]["hardpoint_status_50"] = ["diag_imc_blisk_hp_frac_pumpdeactivate_02"]
	dialogAliases[TEAM_IMC]["hardpoint_status_75"] = ["diag_imc_blisk_hp_frac_pumpdeactivate_03"]
	dialogAliases[TEAM_IMC]["hardpoint_status_100"] = ["diag_imc_blisk_hp_frac_pumpdeactivate_04"]

	// Continuing cap after neutralizing hardpoint
	dialogAliases[TEAM_IMC]["hardpoint_status_neutral_0_a"] = ["diag_imc_blisk_hp_frac_pumpdeactivate_04", "diag_imc_blisk_hp_frac_fueldownactivateturrets_01", "diag_imc_blisk_hp_frac_fueldownactivateturrets_02"]
	dialogAliases[TEAM_IMC]["hardpoint_status_neutral_0_b"] = ["diag_imc_blisk_hp_frac_pumpdeactivate_04", "diag_imc_blisk_hp_frac_fueldownactivateturrets_01", "diag_imc_blisk_hp_frac_fueldownactivateturrets_03"]
	dialogAliases[TEAM_IMC]["hardpoint_status_neutral_0_c"] = ["diag_imc_blisk_hp_frac_pumpdeactivate_04", "diag_imc_blisk_hp_frac_fueldownactivateturrets_01", "diag_imc_blisk_hp_frac_fueldownactivateturrets_04"]
	dialogAliases[TEAM_IMC]["hardpoint_status_neutral_25"] = ["diag_imc_blisk_hp_frac_turrethack_02"]
	dialogAliases[TEAM_IMC]["hardpoint_status_neutral_50"] = ["diag_imc_blisk_hp_frac_turrethack_03"]
	dialogAliases[TEAM_IMC]["hardpoint_status_neutral_75"] = ["diag_imc_blisk_hp_frac_turrethack_04"]

	// Starting cap from neutral
	dialogAliases[TEAM_IMC]["hardpoint_player_capping_a"] = ["diag_imc_blisk_hp_frac_turrethack_01"]
	dialogAliases[TEAM_IMC]["hardpoint_player_capping_b"] = ["diag_imc_blisk_hp_frac_turrethack_01"]
	dialogAliases[TEAM_IMC]["hardpoint_player_capping_c"] = ["diag_imc_blisk_hp_frac_turrethack_01"]

	// Capturing 1 of 3
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_get_ac"] = "diag_imc_blisk_hp_frac_progressdonemove_02"
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_get_bc"] = "diag_imc_blisk_hp_frac_progressdonemove_01"
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_get_ab"] = "diag_imc_blisk_hp_frac_progressdonemove_03"

	// Capturing 2 of 3
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_get_a_b"] = ["diag_imc_blisk_hp_frac_turretsonline_01", "diag_imc_blisk_hp_frac_turrethack_05", "diag_imc_blisk_hp_frac_turretsonline_03"]
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_get_a_c"] = ["diag_imc_blisk_hp_frac_turretsonline_01", "diag_imc_blisk_hp_frac_turrethack_05", "diag_imc_blisk_hp_frac_turretsonline_04"]
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_get_b_a"] = ["diag_imc_blisk_hp_frac_turretsonline_01", "diag_imc_blisk_hp_frac_turrethack_05", "diag_imc_blisk_hp_frac_turretsonline_02"]
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_get_b_c"] = ["diag_imc_blisk_hp_frac_turretsonline_01", "diag_imc_blisk_hp_frac_turrethack_05", "diag_imc_blisk_hp_frac_turretsonline_04"]
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_get_c_a"] = ["diag_imc_blisk_hp_frac_turretsonline_01", "diag_imc_blisk_hp_frac_turrethack_05", "diag_imc_blisk_hp_frac_turretsonline_02"]
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_get_c_b"] = ["diag_imc_blisk_hp_frac_turretsonline_01", "diag_imc_blisk_hp_frac_turrethack_05", "diag_imc_blisk_hp_frac_turretsonline_03"]
	// dummy lines for the registering to work // not good
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_get_a_a"] = ["null_temp"]	// dummy lines for the registering to work
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_get_b_b"] = ["null_temp"]	// dummy lines for the registering to work
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_get_c_c"] = ["null_temp"]	// dummy lines for the registering to work
	// alt lines
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_get_one"] = ["diag_imc_blisk_hp_frac_turrethack_05", "diag_imc_blisk_hp_frac_turretsonline_01"]

	// Capturing with enemies close by
//	dialogAliases[TEAM_IMC]["hardpoint_player_captured_enemy_a"] = ["null_temp"] // no fracture lines
//	dialogAliases[TEAM_IMC]["hardpoint_player_captured_enemy_b"] = ["null_temp"] // no fracture lines
//	dialogAliases[TEAM_IMC]["hardpoint_player_captured_enemy_c"] = ["null_temp"] // no fracture lines

	// Capturing outside of scene
	dialogAliases[TEAM_IMC]["hardpoint_captured_a"] = ["diag_imc_blisk_hp_frac_turretsonline_02"]
	dialogAliases[TEAM_IMC]["hardpoint_captured_b"] = ["diag_imc_blisk_hp_frac_turretsonline_03"]
	dialogAliases[TEAM_IMC]["hardpoint_captured_c"] = ["diag_imc_blisk_hp_frac_turretsonline_04"]
}