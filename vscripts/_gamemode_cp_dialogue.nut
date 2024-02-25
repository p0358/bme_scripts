function main()
{
	Globalize( RegisterHardpointConversations )
	SetupBaseDialog()
}

function SetupBaseDialog()
{
	dialogAliases <- { [TEAM_IMC] = {}, [TEAM_MILITIA]  = {} }
	level.dialogAliases <- dialogAliases
	level.whiteList <- { [TEAM_IMC] = {}, [TEAM_MILITIA]  = {} }

	/***************************************/
	/***************************************/
	/***********  TEAM MILITIA  ************/
	/***************************************/
	/***************************************/

	dialogAliases[TEAM_MILITIA]["hardpoint_capping_a"] <- "diag_hp_mcor_bish_statusupdates_takingAlpha"
	dialogAliases[TEAM_MILITIA]["hardpoint_engaging_a"] <- "diag_hp_mcor_bish_statusupdates_underAttackAlphaStopEm"
	dialogAliases[TEAM_MILITIA]["hardpoint_player_lost_a"] <- "diag_hp_mcor_bish_statusupdates_underAttackAlphaStopEm"

	dialogAliases[TEAM_MILITIA]["hardpoint_player_approach_ahead_a"] <- ["diag_hp_mcor_bish_hpalphacomp_01", "diag_hp_mcor_bish_hpalphacomp_02", "diag_hp_mcor_bish_hpalphacomp_03", "diag_hp_mcor_bish_closehpgeneral_01", "diag_hp_mcor_bish_closehpgeneral_02", "diag_hp_mcor_bish_closehpalpha_01", "diag_hp_mcor_bish_closehpalpha_02", "diag_hp_mcor_bish_closehpalpha_03"]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_approach_a"] <- ["diag_hp_mcor_bish_closehpcheckmap_01", "diag_hp_mcor_bish_closehpcheckhud_01", "diag_hp_mcor_bish_closehpgeneral_03", "diag_hp_mcor_bish_closehpgeneral_04"]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_approach_enemy_a"] <- ["diag_hp_mcor_bish_closehpgeneralalpha_01"]

	dialogAliases[TEAM_MILITIA]["hardpoint_player_engaging_a"] <- ""
	dialogAliases[TEAM_MILITIA]["hardpoint_player_outofrange_a"] <- ["diag_cmp_frac_mcor_bish_lostconnection_01", "diag_cmp_frac_mcor_bish_lostconnection_02"]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_contested_capture_a"] <- ["diag_hp_mcor_bish_hpcontestedlostsignal_03"]
	// contested
	dialogAliases[TEAM_MILITIA]["hardpoint_player_contested_a"] <- ["diag_hp_mcor_bish_hpcontestedlostsignal_01", "diag_hp_mcor_bish_hpcontestedlostsignal_02"]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_interference_a"] <- ["diag_hp_mcor_bish_hpcontested_01", "diag_hp_mcor_bish_hpcontested_02", "diag_hp_mcor_bish_hpcontested_03"]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_interference_again_a"] <- ["diag_hp_mcor_bish_hpcontestedagain_01", "diag_hp_mcor_bish_hpcontestedagain_02", "diag_hp_mcor_bish_hpcontestedagain_03"]
//	dialogAliases[TEAM_MILITIA]["hardpoint_player_interference_reduced_a"] <- ["diag_hp_mcor_bish_hpcontestedpartial_01", "diag_hp_mcor_bish_hpcontestedpartial_02", "diag_hp_mcor_bish_hpcontestedpartial_03"]

	dialogAliases[TEAM_MILITIA]["hardpoint_capping_b"] <- "diag_hp_mcor_bish_statusupdates_takingBravo"
	dialogAliases[TEAM_MILITIA]["hardpoint_engaging_b"] <- "diag_hp_mcor_bish_statusupdates_underAttackBravoStopEm"
	dialogAliases[TEAM_MILITIA]["hardpoint_player_lost_b"] <- "diag_hp_mcor_bish_statusupdates_underAttackBravoStopEm"

	dialogAliases[TEAM_MILITIA]["hardpoint_player_approach_ahead_b"] <- ["diag_hp_mcor_bish_hpbravocomp_02", "diag_hp_mcor_bish_hpbravocomp_03", "diag_hp_mcor_bish_closehpgeneral_01", "diag_hp_mcor_bish_closehpgeneral_02", "diag_hp_mcor_bish_closehpbravo_01", "diag_hp_mcor_bish_closehpbravo_02", "diag_hp_mcor_bish_closehpbravo_03"]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_approach_b"] <- ["diag_hp_mcor_bish_closehpcheckmap_02", "diag_hp_mcor_bish_closehpcheckhud_02", "diag_hp_mcor_bish_closehpgeneral_03", "diag_hp_mcor_bish_closehpgeneral_04"]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_approach_enemy_b"] <- ["diag_hp_mcor_bish_closehpgeneralbravo_01"]

	dialogAliases[TEAM_MILITIA]["hardpoint_player_engaging_b"] <- ""
	dialogAliases[TEAM_MILITIA]["hardpoint_player_outofrange_b"] <- ["diag_cmp_frac_mcor_bish_lostconnection_01", "diag_cmp_frac_mcor_bish_lostconnection_02"]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_contested_capture_b"] <- ["diag_hp_mcor_bish_hpcontestedlostsignal_03"]
	// contested
	dialogAliases[TEAM_MILITIA]["hardpoint_player_contested_b"] <- ["diag_hp_mcor_bish_hpcontestedlostsignal_01", "diag_hp_mcor_bish_hpcontestedlostsignal_02"]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_interference_b"] <- ["diag_hp_mcor_bish_hpcontested_01", "diag_hp_mcor_bish_hpcontested_02", "diag_hp_mcor_bish_hpcontested_03"]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_interference_again_b"] <- ["diag_hp_mcor_bish_hpcontestedagain_01", "diag_hp_mcor_bish_hpcontestedagain_02", "diag_hp_mcor_bish_hpcontestedagain_03"]
//	dialogAliases[TEAM_MILITIA]["hardpoint_player_interference_reduced_b"] <- ["diag_hp_mcor_bish_hpcontestedpartial_01", "diag_hp_mcor_bish_hpcontestedpartial_02", "diag_hp_mcor_bish_hpcontestedpartial_03"]

	dialogAliases[TEAM_MILITIA]["hardpoint_capping_c"] <- "diag_hp_mcor_bish_statusupdates_takingCharlie"
	dialogAliases[TEAM_MILITIA]["hardpoint_engaging_c"] <- "diag_hp_mcor_bish_statusupdates_underAttackCharlieStopEm"
	dialogAliases[TEAM_MILITIA]["hardpoint_player_lost_c"] <- "diag_hp_mcor_bish_statusupdates_underAttackCharlieStopEm"

	dialogAliases[TEAM_MILITIA]["hardpoint_player_approach_ahead_c"] <- ["diag_hp_mcor_bish_hpcharliecomp_01", "diag_hp_mcor_bish_hpcharliecomp_02", "diag_hp_mcor_bish_hpcharliecomp_03","diag_hp_mcor_bish_closehpgeneral_01", "diag_hp_mcor_bish_closehpgeneral_02", "diag_hp_mcor_bish_closehpcharlie_01", "diag_hp_mcor_bish_closehpcharlie_02", "diag_hp_mcor_bish_closehpcharlie_03"]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_approach_c"] <- ["diag_hp_mcor_bish_closehpcheckmap_03", "diag_hp_mcor_bish_closehpcheckhud_03", "diag_hp_mcor_bish_closehpgeneral_03", "diag_hp_mcor_bish_closehpgeneral_04"]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_approach_enemy_c"] <- ["diag_hp_mcor_bish_closehpgeneralcharlie_01"]

	dialogAliases[TEAM_MILITIA]["hardpoint_player_engaging_c"] <- ""
	dialogAliases[TEAM_MILITIA]["hardpoint_player_outofrange_c"] <- ["diag_cmp_frac_mcor_bish_lostconnection_01", "diag_cmp_frac_mcor_bish_lostconnection_02"]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_contested_capture_c"] <- ["diag_hp_mcor_bish_hpcontestedlostsignal_03"]
	// contested
	dialogAliases[TEAM_MILITIA]["hardpoint_player_contested_c"] <- ["diag_hp_mcor_bish_hpcontestedlostsignal_01", "diag_hp_mcor_bish_hpcontestedlostsignal_02"]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_interference_c"] <- ["diag_hp_mcor_bish_hpcontested_01", "diag_hp_mcor_bish_hpcontested_02", "diag_hp_mcor_bish_hpcontested_03"]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_interference_again_c" ] <- ["diag_hp_mcor_bish_hpcontestedagain_01", "diag_hp_mcor_bish_hpcontestedagain_02", "diag_hp_mcor_bish_hpcontestedagain_03"]
//	dialogAliases[TEAM_MILITIA]["hardpoint_player_interference_reduced_c"] <- ["diag_hp_mcor_bish_hpcontestedpartial_01", "diag_hp_mcor_bish_hpcontestedpartial_02", "diag_hp_mcor_bish_hpcontestedpartial_03"]


	// Loost hardpoint
	dialogAliases[TEAM_MILITIA]["hardpoint_lost_a"] <- ["diag_hp_mcor_bish_statusupdates_lostAlpha", "diag_hp_mcor_bish_statusupdates_lostAlphaRetake"]
	dialogAliases[TEAM_MILITIA]["hardpoint_lost_b"] <- ["diag_hp_mcor_bish_statusupdates_lostBravo", "diag_hp_mcor_bish_statusupdates_lostBravoRetake"]
	dialogAliases[TEAM_MILITIA]["hardpoint_lost_c"] <- ["diag_hp_mcor_bish_statusupdates_lostCharlie", "diag_hp_mcor_bish_statusupdates_lostCharlieRetake"]

	// Loosing hardpoint
	dialogAliases[TEAM_MILITIA]["hardpoint_losing_a"] <- ["diag_hp_mcor_bish_statusupdates_underAttackAlpha", "diag_hp_mcor_bish_statusupdates_losingAlpha"]
	dialogAliases[TEAM_MILITIA]["hardpoint_losing_b"] <- ["diag_hp_mcor_bish_statusupdates_underAttackBravo", "diag_hp_mcor_bish_statusupdates_losingBravo"]
	dialogAliases[TEAM_MILITIA]["hardpoint_losing_c"] <- ["diag_hp_mcor_bish_statusupdates_underAttackCharlie", "diag_hp_mcor_bish_statusupdates_losingCharlie"]

	// lost all hardpoint
	dialogAliases[TEAM_MILITIA]["hardpoint_lost_all"] <- [ "diag_cmp_mcor_bish_allPointsLost_01", "diag_cmp_mcor_bish_allPointsLost_02", "diag_cmp_mcor_bish_allPointsLost_03", "diag_cmp_mcor_bish_allPointsLost_04", "diag_cmp_mcor_bish_allPointsLost_05", "diag_cmp_mcor_bish_allPointsLost_06" ]

	//Nag player for not capping points
	dialogAliases[TEAM_MILITIA][ "hardpoint_nag" ] <- [ "diag_hp_mcor_bish_nag" ]

	// Starting cap from enemy controlled
	dialogAliases[TEAM_MILITIA]["hardpoint_status_0_a"] <- [ "diag_hp_mcor_bish_generalpurpose_01", "diag_hp_mcor_bish_neutralizingHp_01", "diag_hp_mcor_bish_neutralizingHp_02", "diag_hp_mcor_bish_neutralizingHp_03", "diag_hp_mcor_bish_neutralizingHp_04", "diag_hp_mcor_bish_neutralizingHp_05" ]
	dialogAliases[TEAM_MILITIA]["hardpoint_status_0_b"] <- [ "diag_hp_mcor_bish_generalpurpose_01", "diag_hp_mcor_bish_neutralizingHp_01", "diag_hp_mcor_bish_neutralizingHp_02", "diag_hp_mcor_bish_neutralizingHp_03", "diag_hp_mcor_bish_neutralizingHp_04", "diag_hp_mcor_bish_neutralizingHp_05" ]
	dialogAliases[TEAM_MILITIA]["hardpoint_status_0_c"] <- [ "diag_hp_mcor_bish_generalpurpose_01", "diag_hp_mcor_bish_neutralizingHp_01", "diag_hp_mcor_bish_neutralizingHp_02", "diag_hp_mcor_bish_neutralizingHp_03", "diag_hp_mcor_bish_neutralizingHp_04", "diag_hp_mcor_bish_neutralizingHp_05" ]
	dialogAliases[TEAM_MILITIA]["hardpoint_status_25"] <-  [ "diag_hp_mcor_bish_generalpurpose_noprefix_03", "diag_hp_mcor_bish_neutralizingHp_06", "diag_hp_mcor_bish_neutralizingHp_07" ]
	dialogAliases[TEAM_MILITIA]["hardpoint_status_50"] <-  [ "diag_hp_mcor_bish_generalpurpose_noprefix_02", "diag_hp_mcor_bish_neutralizingHp_08" ]
	dialogAliases[TEAM_MILITIA]["hardpoint_status_75"] <-  [ "diag_hp_mcor_bish_generalpurpose_noprefix_01", "diag_hp_mcor_bish_neutralizingHp_09" ]
	dialogAliases[TEAM_MILITIA]["hardpoint_status_100"] <- [ "diag_hp_mcor_bish_beginSecuringHp_01", "diag_hp_mcor_bish_beginSecuringHp_02", "diag_hp_mcor_bish_beginSecuringHp_03", "diag_hp_mcor_bish_beginSecuringHp_04", "diag_hp_mcor_bish_beginSecuringHp_05", "diag_hp_mcor_bish_beginSecuringHp_06", "diag_hp_mcor_bish_beginSecuringHp_07" ]

	// Continuing cap after neutralizing hardpoint
	dialogAliases[TEAM_MILITIA]["hardpoint_status_neutral_0_a"] <- [ "diag_hp_mcor_bish_beginSecuringHp_01", "diag_hp_mcor_bish_beginSecuringHp_02", "diag_hp_mcor_bish_beginSecuringHp_03", "diag_hp_mcor_bish_beginSecuringHp_04", "diag_hp_mcor_bish_beginSecuringHp_05", "diag_hp_mcor_bish_beginSecuringHp_06", "diag_hp_mcor_bish_beginSecuringHp_07" ]
	dialogAliases[TEAM_MILITIA]["hardpoint_status_neutral_0_b"] <- [ "diag_hp_mcor_bish_beginSecuringHp_01", "diag_hp_mcor_bish_beginSecuringHp_02", "diag_hp_mcor_bish_beginSecuringHp_03", "diag_hp_mcor_bish_beginSecuringHp_04", "diag_hp_mcor_bish_beginSecuringHp_05", "diag_hp_mcor_bish_beginSecuringHp_06", "diag_hp_mcor_bish_beginSecuringHp_07" ]
	dialogAliases[TEAM_MILITIA]["hardpoint_status_neutral_0_c"] <- [ "diag_hp_mcor_bish_beginSecuringHp_01", "diag_hp_mcor_bish_beginSecuringHp_02", "diag_hp_mcor_bish_beginSecuringHp_03", "diag_hp_mcor_bish_beginSecuringHp_04", "diag_hp_mcor_bish_beginSecuringHp_05", "diag_hp_mcor_bish_beginSecuringHp_06", "diag_hp_mcor_bish_beginSecuringHp_07" ]
	dialogAliases[TEAM_MILITIA]["hardpoint_status_neutral_25"] <-  [ "diag_hp_mcor_bish_beginSecuringHp_08" ]
	dialogAliases[TEAM_MILITIA]["hardpoint_status_neutral_50"] <-  [ "diag_hp_mcor_bish_beginSecuringHp_09", "diag_hp_mcor_bish_beginSecuringHp_10" ]
	dialogAliases[TEAM_MILITIA]["hardpoint_status_neutral_75"] <-  [ "diag_hp_mcor_bish_beginSecuringHp_11", "diag_hp_mcor_bish_beginSecuringHp_12", "diag_hp_mcor_bish_beginSecuringHp_13" ]
	dialogAliases[TEAM_MILITIA]["hardpoint_status_neutral_100"] <- [ "diag_hp_mcor_bish_SecuredHp_01", "diag_hp_mcor_bish_SecuredHp_02", "diag_hp_mcor_bish_SecuredHp_03", "diag_hp_mcor_bish_SecuredHp_04", "diag_hp_mcor_bish_SecuredHp_05" ]

	// Starting cap from neutral
	dialogAliases[TEAM_MILITIA]["hardpoint_player_capping_a"] <- ["diag_hp_mcor_bish_wifistayclose_01", "diag_hp_mcor_bish_wifistayclose_02", "diag_hp_mcor_bish_wifistayclose_03", "diag_hp_mcor_bish_wifistayclose_51", "diag_hp_mcor_bish_wifistayclose_52", "diag_hp_mcor_bish_wifistayclose_53", "diag_hp_mcor_bish_wifistayclose_54" ]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_capping_b"] <- ["diag_hp_mcor_bish_wifistayclose_01", "diag_hp_mcor_bish_wifistayclose_02", "diag_hp_mcor_bish_wifistayclose_03", "diag_hp_mcor_bish_wifistayclose_51", "diag_hp_mcor_bish_wifistayclose_52", "diag_hp_mcor_bish_wifistayclose_53", "diag_hp_mcor_bish_wifistayclose_54" ]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_capping_c"] <- ["diag_hp_mcor_bish_wifistayclose_01", "diag_hp_mcor_bish_wifistayclose_02", "diag_hp_mcor_bish_wifistayclose_03", "diag_hp_mcor_bish_wifistayclose_51", "diag_hp_mcor_bish_wifistayclose_52", "diag_hp_mcor_bish_wifistayclose_53", "diag_hp_mcor_bish_wifistayclose_54" ]

	// Capturing 1 of 3
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_get_ac"] <- [ "diag_hp_mcor_bish_generalpurposemove_05", "diag_hp_mcor_bish_generalpurposemove_55", "diag_hp_mcor_bish_generalpurposemove_56", "diag_hp_mcor_bish_generalpurposemove_57" ]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_get_bc"] <- [ "diag_hp_mcor_bish_generalpurposemove_04", "diag_hp_mcor_bish_generalpurposemove_51", "diag_hp_mcor_bish_generalpurposemove_52", "diag_hp_mcor_bish_generalpurposemove_53", "diag_hp_mcor_bish_generalpurposemove_54" ]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_get_ab"] <- [ "diag_hp_mcor_bish_generalpurposemove_06", "diag_hp_mcor_bish_generalpurposemove_58", "diag_hp_mcor_bish_generalpurposemove_59", "diag_hp_mcor_bish_generalpurposemove_60" ]

	// Capturing 2 of 3
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_get_a_b"] <- ["diag_hp_mcor_bish_generalpurposemove_01", "diag_hp_mcor_bish_generalpurposemove_61", "diag_hp_mcor_bish_generalpurposemove_62", "diag_hp_mcor_bish_generalpurposemove_63" ]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_get_a_c"] <- ["diag_hp_mcor_bish_generalpurposemove_01", "diag_hp_mcor_bish_generalpurposemove_61", "diag_hp_mcor_bish_generalpurposemove_62", "diag_hp_mcor_bish_generalpurposemove_63" ]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_get_b_a"] <- ["diag_hp_mcor_bish_generalpurposemove_02", "diag_hp_mcor_bish_generalpurposemove_64", "diag_hp_mcor_bish_generalpurposemove_65", "diag_hp_mcor_bish_generalpurposemove_66" ]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_get_b_c"] <- ["diag_hp_mcor_bish_generalpurposemove_02", "diag_hp_mcor_bish_generalpurposemove_64", "diag_hp_mcor_bish_generalpurposemove_65", "diag_hp_mcor_bish_generalpurposemove_66" ]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_get_c_a"] <- ["diag_hp_mcor_bish_generalpurposemove_03", "diag_hp_mcor_bish_generalpurposemove_67", "diag_hp_mcor_bish_generalpurposemove_68"]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_get_c_b"] <- ["diag_hp_mcor_bish_generalpurposemove_03", "diag_hp_mcor_bish_generalpurposemove_67", "diag_hp_mcor_bish_generalpurposemove_68"]
	// dummy lines for the registering to work // not good
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_get_a_a"] <- ["diag_hp_mcor_bish_statusupdates_tookAlpha"]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_get_b_b"] <- ["diag_hp_mcor_bish_statusupdates_tookBravo"]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_get_c_c"] <- ["diag_hp_mcor_bish_statusupdates_tookCharlie"]

	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_get_one"] <- ["diag_hp_mcor_bish_statusupdates_2outof3"]

	// Capturing 3 of 3
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_a"] <- ["diag_hp_mcor_bish_generalpurpose_05", "diag_hp_mcor_bish_datagrabprogress_04"]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_b"] <- ["diag_hp_mcor_bish_generalpurpose_05", "diag_hp_mcor_bish_datagrabprogress_04"]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_c"] <- ["diag_hp_mcor_bish_generalpurpose_05", "diag_hp_mcor_bish_datagrabprogress_04"]

	// Capturing with enemies close by
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_enemy_a"] <- ["diag_hp_mcor_bish_hpcapturedenemypresence_02", "diag_hp_mcor_bish_hpcapturedenemypresence_03", "diag_hp_mcor_bish_hpcapturedenemypresence_51", "diag_hp_mcor_bish_hpcapturedenemypresence_52", "diag_hp_mcor_bish_hpcapturedenemypresence_53" ]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_enemy_b"] <- ["diag_hp_mcor_bish_hpcapturedenemypresence_02", "diag_hp_mcor_bish_hpcapturedenemypresence_03", "diag_hp_mcor_bish_hpcapturedenemypresence_51", "diag_hp_mcor_bish_hpcapturedenemypresence_52", "diag_hp_mcor_bish_hpcapturedenemypresence_53" ]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_captured_enemy_c"] <- ["diag_hp_mcor_bish_hpcapturedenemypresence_02", "diag_hp_mcor_bish_hpcapturedenemypresence_03", "diag_hp_mcor_bish_hpcapturedenemypresence_51", "diag_hp_mcor_bish_hpcapturedenemypresence_52", "diag_hp_mcor_bish_hpcapturedenemypresence_53" ]

	// Capturing outside of scene
	dialogAliases[TEAM_MILITIA]["hardpoint_captured_a"] <- ["diag_hp_mcor_bish_statusupdates_tookAlpha", "diag_hp_mcor_bish_statusupdates_controlAlpha", "diag_hp_mcor_bish_statusupdates_gotAlpha"]
	dialogAliases[TEAM_MILITIA]["hardpoint_captured_b"] <- ["diag_hp_mcor_bish_statusupdates_tookBravo", "diag_hp_mcor_bish_statusupdates_controlBravo", "diag_hp_mcor_bish_statusupdates_gotBravo"]
	dialogAliases[TEAM_MILITIA]["hardpoint_captured_c"] <- ["diag_hp_mcor_bish_statusupdates_tookCharlie", "diag_hp_mcor_bish_statusupdates_controlCharlie", "diag_hp_mcor_bish_statusupdates_gotCharlie"]

	level.whiteList[TEAM_MILITIA][ "hardpoint_captured_a" ] <- "diag_hp_mcor_bish_statusupdates_30_a" //These animation names are confusing to be honest...
	level.whiteList[TEAM_MILITIA][ "hardpoint_captured_b" ] <- "diag_hp_mcor_bish_statusupdates_32_a" //These animation names are confusing to be honest...
	level.whiteList[TEAM_MILITIA][ "hardpoint_captured_c" ] <- "diag_hp_mcor_bish_statusupdates_34_a" //These animation names are confusing to be honest...
	level.whiteList[TEAM_MILITIA][ "hardpoint_lost_a" ] <- "diag_hp_mcor_bish_statusupdates_36_a" //These animation names are confusing to be honest...
	level.whiteList[TEAM_MILITIA][ "hardpoint_lost_b" ] <- "diag_hp_mcor_bish_statusupdates_38_a" //These animation names are confusing to be honest...
	level.whiteList[TEAM_MILITIA][ "hardpoint_lost_c" ] <- "diag_hp_mcor_bish_statusupdates_40_a" //These animation names are confusing to be honest...
	level.whiteList[TEAM_MILITIA][ "hardpoint_player_capping_a" ] <- "diag_hp_mcor_bish_wifistayclose_01"
	level.whiteList[TEAM_MILITIA][ "hardpoint_player_capping_b" ] <- "diag_hp_mcor_bish_wifistayclose_01"
	level.whiteList[TEAM_MILITIA][ "hardpoint_player_capping_c" ] <- "diag_hp_mcor_bish_wifistayclose_01"


	/***************************************/
	/***************************************/
	/*************  TEAM IMC  **************/
	/***************************************/
	/***************************************/

	dialogAliases[TEAM_IMC]["hardpoint_capping_a"] <- "diag_imc_blisk_hp_statusupdates_53"
	dialogAliases[TEAM_IMC]["hardpoint_engaging_a"] <- "diag_imc_blisk_hp_statusupdates_42"
	dialogAliases[TEAM_IMC]["hardpoint_player_lost_a"] <- "null_temp" // no in use

	dialogAliases[TEAM_IMC]["hardpoint_player_approach_ahead_a"] <- ["diag_imc_blisk_hp_closehpalpha_01", "diag_imc_blisk_hp_closehpalpha_02", "diag_imc_blisk_hp_closehpalpha_03", "diag_imc_blisk_hp_closehpgeneral_01", "diag_imc_blisk_hp_closehpgeneral_02", "diag_imc_blisk_hp_closehpalpha_51", "diag_imc_blisk_hp_closehpalpha_52"  ]
	dialogAliases[TEAM_IMC]["hardpoint_player_approach_a"] <- ["diag_imc_blisk_hp_closehpcheckmap_01", "diag_imc_blisk_hp_closehpcheckhud_01", "diag_imc_blisk_hp_closehpgeneral_03", "diag_imc_blisk_hp_closehpgeneral_04"]
	dialogAliases[TEAM_IMC]["hardpoint_player_approach_enemy_a"] <- ["diag_imc_blisk_hp_closehpgeneralalpha_01"]

	dialogAliases[TEAM_IMC]["hardpoint_player_engaging_a"] <- "null_temp" // not in use
	dialogAliases[TEAM_IMC]["hardpoint_player_outofrange_a"] <- ["diag_imc_blisk_hp_hpguidancelostconnection_01", "diag_imc_blisk_hp_hpguidancelostconnection_02"]
	dialogAliases[TEAM_IMC]["hardpoint_player_contested_capture_a"] <- ["diag_imc_blisk_hp_hpcontestedlostsignal_03"]
	// contested
	dialogAliases[TEAM_IMC]["hardpoint_player_contested_a"] <- ["diag_imc_blisk_hp_hpcontestedlostsignal_01", "diag_imc_blisk_hp_hpcontestedlostsignal_02"]
	dialogAliases[TEAM_IMC]["hardpoint_player_interference_a"] <- ["diag_imc_blisk_hp_hpcontested_01", "diag_imc_blisk_hp_hpcontested_02", "diag_imc_blisk_hp_hpcontested_03"]
	dialogAliases[TEAM_IMC]["hardpoint_player_interference_again_a"] <- ["diag_imc_blisk_hp_hpcontestedagain_01", "diag_imc_blisk_hp_hpcontestedagain_02", "diag_imc_blisk_hp_hpcontestedagain_03"]
//	dialogAliases[TEAM_IMC]["hardpoint_player_interference_reduced_a"] <- ["null_temp"]

	dialogAliases[TEAM_IMC]["hardpoint_capping_b"] <- "diag_imc_blisk_hp_statusupdates_54"
	dialogAliases[TEAM_IMC]["hardpoint_engaging_b"] <- "diag_imc_blisk_hp_statusupdates_44"
	dialogAliases[TEAM_IMC]["hardpoint_player_lost_b"] <- "null_temp" // no in use

	dialogAliases[TEAM_IMC]["hardpoint_player_approach_ahead_b"] <- ["diag_imc_blisk_hp_closehpbravo_01", "diag_imc_blisk_hp_closehpbravo_02", "diag_imc_blisk_hp_closehpbravo_03", "diag_imc_blisk_hp_closehpgeneral_01", "diag_imc_blisk_hp_closehpgeneral_02", "diag_imc_blisk_hp_closehpbravo_51", "diag_imc_blisk_hp_closehpbravo_52"]
	dialogAliases[TEAM_IMC]["hardpoint_player_approach_b"] <- ["diag_imc_blisk_hp_closehpcheckmap_02", "diag_imc_blisk_hp_closehpcheckhud_02", "diag_imc_blisk_hp_closehpgeneral_03", "diag_imc_blisk_hp_closehpgeneral_04"]
	dialogAliases[TEAM_IMC]["hardpoint_player_approach_enemy_b"] <- ["diag_imc_blisk_hp_closehpgeneralbravo_01"]

	dialogAliases[TEAM_IMC]["hardpoint_player_engaging_b"] <- "null_temp" // not in use
	dialogAliases[TEAM_IMC]["hardpoint_player_outofrange_b"] <- ["diag_imc_blisk_hp_hpguidancelostconnection_01", "diag_imc_blisk_hp_hpguidancelostconnection_02"]
	dialogAliases[TEAM_IMC]["hardpoint_player_contested_capture_b"] <- ["diag_imc_blisk_hp_hpcontestedlostsignal_03"]
	// contested
	dialogAliases[TEAM_IMC]["hardpoint_player_contested_b"] <- ["diag_imc_blisk_hp_hpcontestedlostsignal_01", "diag_imc_blisk_hp_hpcontestedlostsignal_02"]
	dialogAliases[TEAM_IMC]["hardpoint_player_interference_b"] <- ["diag_imc_blisk_hp_hpcontested_01", "diag_imc_blisk_hp_hpcontested_02", "diag_imc_blisk_hp_hpcontested_03"]
	dialogAliases[TEAM_IMC]["hardpoint_player_interference_again_b"] <- ["diag_imc_blisk_hp_hpcontestedagain_01", "diag_imc_blisk_hp_hpcontestedagain_02", "diag_imc_blisk_hp_hpcontestedagain_03"]
//	dialogAliases[TEAM_IMC]["hardpoint_player_interference_reduced_b"] <- ["null_temp"]

	dialogAliases[TEAM_IMC]["hardpoint_capping_c"] <- "diag_imc_blisk_hp_statusupdates_55"
	dialogAliases[TEAM_IMC]["hardpoint_engaging_c"] <- "diag_imc_blisk_hp_statusupdates_46"
	dialogAliases[TEAM_IMC]["hardpoint_player_lost_c"] <- "null_temp" // no in use

	dialogAliases[TEAM_IMC]["hardpoint_player_approach_ahead_c"] <- ["diag_imc_blisk_hp_closehpcharlie_01", "diag_imc_blisk_hp_closehpcharlie_02", "diag_imc_blisk_hp_closehpcharlie_03", "diag_imc_blisk_hp_closehpgeneral_01", "diag_imc_blisk_hp_closehpgeneral_02", "diag_imc_blisk_hp_closehpcharlie_51", "diag_imc_blisk_hp_closehpcharlie_52" ]
	dialogAliases[TEAM_IMC]["hardpoint_player_approach_c"] <- ["diag_imc_blisk_hp_closehpcheckmap_03", "diag_imc_blisk_hp_closehpcheckhud_03", "diag_imc_blisk_hp_closehpgeneral_03", "diag_imc_blisk_hp_closehpgeneral_04"]
	dialogAliases[TEAM_IMC]["hardpoint_player_approach_enemy_c"] <- ["diag_imc_blisk_hp_closehpgeneralcharlie_01"]

	dialogAliases[TEAM_IMC]["hardpoint_player_engaging_c"] <- "null_temp" // not in use
	dialogAliases[TEAM_IMC]["hardpoint_player_outofrange_c"] <- ["diag_imc_blisk_hp_hpguidancelostconnection_01", "diag_imc_blisk_hp_hpguidancelostconnection_02"]
	dialogAliases[TEAM_IMC]["hardpoint_player_contested_capture_c"] <- ["diag_imc_blisk_hp_hpcontestedlostsignal_03"]
	// contested
	dialogAliases[TEAM_IMC]["hardpoint_player_contested_c"] <- ["diag_imc_blisk_hp_hpcontestedlostsignal_01", "diag_imc_blisk_hp_hpcontestedlostsignal_02"]
	dialogAliases[TEAM_IMC]["hardpoint_player_interference_c"] <- ["diag_imc_blisk_hp_hpcontested_01", "diag_imc_blisk_hp_hpcontested_02", "diag_imc_blisk_hp_hpcontested_03"]
	dialogAliases[TEAM_IMC]["hardpoint_player_interference_again_c" ] <- ["diag_imc_blisk_hp_hpcontestedagain_01", "diag_imc_blisk_hp_hpcontestedagain_02", "diag_imc_blisk_hp_hpcontestedagain_03"]
//	dialogAliases[TEAM_IMC]["hardpoint_player_interference_reduced_c"] <- ["null_temp"]


	// Loost hardpoint
	dialogAliases[TEAM_IMC]["hardpoint_lost_a"] <- ["diag_imc_blisk_hp_statusupdates_24", "diag_imc_blisk_hp_statusupdates_36"]
	dialogAliases[TEAM_IMC]["hardpoint_lost_b"] <- ["diag_imc_blisk_hp_statusupdates_26", "diag_imc_blisk_hp_statusupdates_38"]
	dialogAliases[TEAM_IMC]["hardpoint_lost_c"] <- ["diag_imc_blisk_hp_statusupdates_28", "diag_imc_blisk_hp_statusupdates_40"]

	// Loosing hardpoint
	dialogAliases[TEAM_IMC]["hardpoint_losing_a"] <- ["diag_imc_blisk_hp_statusupdates_48", "diag_imc_blisk_hp_statusupdates_56"]
	dialogAliases[TEAM_IMC]["hardpoint_losing_b"] <- ["diag_imc_blisk_hp_statusupdates_50", "diag_imc_blisk_hp_statusupdates_57"]
	dialogAliases[TEAM_IMC]["hardpoint_losing_c"] <- ["diag_imc_blisk_hp_statusupdates_52", "diag_imc_blisk_hp_statusupdates_58"]

	// lost all hardpoint
	dialogAliases[TEAM_IMC]["hardpoint_lost_all"] <- [ "diag_imc_blisk_hp_allPointsLost_01", "diag_imc_blisk_hp_allPointsLost_02", "diag_imc_blisk_hp_allPointsLost_03", "diag_imc_blisk_hp_allPointsLost_04", "diag_imc_blisk_hp_allPointsLost_05" ]	// missing

	//Nag player for not capping points
	dialogAliases[TEAM_IMC][ "hardpoint_nag" ] <- [ "diag_imc_blisk_hp_nag" ]

	// Starting cap from enemy controlled
	dialogAliases[TEAM_IMC]["hardpoint_status_0_a"] <- [ "diag_imc_blisk_hp_neutralizingHp_01", "diag_imc_blisk_hp_neutralizingHp_02", "diag_imc_blisk_hp_neutralizingHp_03", "diag_imc_blisk_hp_neutralizingHp_04", "diag_imc_blisk_hp_neutralizingHp_05" ]
	dialogAliases[TEAM_IMC]["hardpoint_status_0_b"] <- [ "diag_imc_blisk_hp_neutralizingHp_01", "diag_imc_blisk_hp_neutralizingHp_02", "diag_imc_blisk_hp_neutralizingHp_03", "diag_imc_blisk_hp_neutralizingHp_04", "diag_imc_blisk_hp_neutralizingHp_05" ]
	dialogAliases[TEAM_IMC]["hardpoint_status_0_c"] <- [ "diag_imc_blisk_hp_neutralizingHp_01", "diag_imc_blisk_hp_neutralizingHp_02", "diag_imc_blisk_hp_neutralizingHp_03", "diag_imc_blisk_hp_neutralizingHp_04", "diag_imc_blisk_hp_neutralizingHp_05" ]
	dialogAliases[TEAM_IMC]["hardpoint_status_25"] <- [ "diag_imc_blisk_neutralizingHp_01", "diag_imc_blisk_neutralizingHp_02", "diag_imc_blisk_neutralizingHp_03" ]
	dialogAliases[TEAM_IMC]["hardpoint_status_50"] <- [ "diag_imc_blisk_neutralizingHp_04", "diag_imc_blisk_neutralizingHp_05" ]
	dialogAliases[TEAM_IMC]["hardpoint_status_75"] <- [ "diag_imc_blisk_neutralizingHp_06", "diag_imc_blisk_neutralizingHp_07", "diag_imc_blisk_neutralizingHp_08" ]
	dialogAliases[TEAM_IMC]["hardpoint_status_100"] <- [ "diag_imc_blisk_beginSecuringHp_01", "diag_imc_blisk_beginSecuringHp_02", "diag_imc_blisk_beginSecuringHp_03", "diag_imc_blisk_beginSecuringHp_04", "diag_imc_blisk_beginSecuringHp_05", "diag_imc_blisk_beginSecuringHp_06", "diag_imc_blisk_beginSecuringHp_07", "diag_imc_blisk_beginSecuringHp_08" ]

	// Continuing cap after neutralizing hardpoint
	dialogAliases[TEAM_IMC]["hardpoint_status_neutral_0_a"] <- [ "diag_imc_blisk_beginSecuringHp_01", "diag_imc_blisk_beginSecuringHp_02", "diag_imc_blisk_beginSecuringHp_03", "diag_imc_blisk_beginSecuringHp_04", "diag_imc_blisk_beginSecuringHp_05", "diag_imc_blisk_beginSecuringHp_06", "diag_imc_blisk_beginSecuringHp_07", "diag_imc_blisk_beginSecuringHp_08" ]
	dialogAliases[TEAM_IMC]["hardpoint_status_neutral_0_b"] <- [ "diag_imc_blisk_beginSecuringHp_01", "diag_imc_blisk_beginSecuringHp_02", "diag_imc_blisk_beginSecuringHp_03", "diag_imc_blisk_beginSecuringHp_04", "diag_imc_blisk_beginSecuringHp_05", "diag_imc_blisk_beginSecuringHp_06", "diag_imc_blisk_beginSecuringHp_07", "diag_imc_blisk_beginSecuringHp_08" ]
	dialogAliases[TEAM_IMC]["hardpoint_status_neutral_0_c"] <- [ "diag_imc_blisk_beginSecuringHp_01", "diag_imc_blisk_beginSecuringHp_02", "diag_imc_blisk_beginSecuringHp_03", "diag_imc_blisk_beginSecuringHp_04", "diag_imc_blisk_beginSecuringHp_05", "diag_imc_blisk_beginSecuringHp_06", "diag_imc_blisk_beginSecuringHp_07", "diag_imc_blisk_beginSecuringHp_08" ]
	dialogAliases[TEAM_IMC]["hardpoint_status_neutral_25"] <- [ "diag_imc_blisk_beginSecuringHp_09"]
	dialogAliases[TEAM_IMC]["hardpoint_status_neutral_50"] <- [ "diag_imc_blisk_beginSecuringHp_10", "diag_imc_blisk_beginSecuringHp_11"]
	dialogAliases[TEAM_IMC]["hardpoint_status_neutral_75"] <- [ "diag_imc_blisk_beginSecuringHp_12", "diag_imc_blisk_beginSecuringHp_13", "diag_imc_blisk_beginSecuringHp_14" ]
	dialogAliases[TEAM_IMC]["hardpoint_status_neutral_100"] <- [ "diag_imc_blisk_SecuredHp_01", "diag_imc_blisk_SecuredHp_02", "diag_imc_blisk_SecuredHp_03", "diag_imc_blisk_SecuredHp_04", "diag_imc_blisk_SecuredHp_05" ]

	// Starting cap from neutral
	dialogAliases[TEAM_IMC]["hardpoint_player_capping_a"] <- ["diag_imc_blisk_hp_wifistayclose_01", "diag_imc_blisk_hp_wifistayclose_02", "diag_imc_blisk_hp_wifistayclose_03"]
	dialogAliases[TEAM_IMC]["hardpoint_player_capping_b"] <- ["diag_imc_blisk_hp_wifistayclose_01", "diag_imc_blisk_hp_wifistayclose_02", "diag_imc_blisk_hp_wifistayclose_03"]
	dialogAliases[TEAM_IMC]["hardpoint_player_capping_c"] <- ["diag_imc_blisk_hp_wifistayclose_01", "diag_imc_blisk_hp_wifistayclose_02", "diag_imc_blisk_hp_wifistayclose_03"]

	// Capturing 1 of 3
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_get_ac"] <- [ "diag_imc_blisk_hp_generalpurposemove_05", "diag_imc_blisk_hp_generalpurposemove_55", "diag_imc_blisk_hp_generalpurposemove_56", "diag_imc_blisk_hp_generalpurposemove_57" ]
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_get_bc"] <- [ "diag_imc_blisk_hp_generalpurposemove_04", "diag_imc_blisk_hp_generalpurposemove_51", "diag_imc_blisk_hp_generalpurposemove_52", "diag_imc_blisk_hp_generalpurposemove_53", "diag_imc_blisk_hp_generalpurposemove_54" ]
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_get_ab"] <- [ "diag_imc_blisk_hp_generalpurposemove_06", "diag_imc_blisk_hp_generalpurposemove_58", "diag_imc_blisk_hp_generalpurposemove_59", "diag_imc_blisk_hp_generalpurposemove_60" ]

	// Capturing 2 of 3
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_get_a_b"] <- [ "diag_imc_blisk_hp_generalpurposemove_01", "diag_imc_blisk_hp_generalpurposemove_61", "diag_imc_blisk_hp_generalpurposemove_62", "diag_imc_blisk_hp_generalpurposemove_63" ]
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_get_a_c"] <- [ "diag_imc_blisk_hp_generalpurposemove_01", "diag_imc_blisk_hp_generalpurposemove_61", "diag_imc_blisk_hp_generalpurposemove_62", "diag_imc_blisk_hp_generalpurposemove_63" ]
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_get_b_a"] <- [ "diag_imc_blisk_hp_generalpurposemove_02", "diag_imc_blisk_hp_generalpurposemove_64", "diag_imc_blisk_hp_generalpurposemove_65", "diag_imc_blisk_hp_generalpurposemove_66" ]
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_get_b_c"] <- [ "diag_imc_blisk_hp_generalpurposemove_02", "diag_imc_blisk_hp_generalpurposemove_64", "diag_imc_blisk_hp_generalpurposemove_65", "diag_imc_blisk_hp_generalpurposemove_66" ]
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_get_c_a"] <- [ "diag_imc_blisk_hp_generalpurposemove_03", "diag_imc_blisk_hp_generalpurposemove_67", "diag_imc_blisk_hp_generalpurposemove_68" ]
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_get_c_b"] <- [ "diag_imc_blisk_hp_generalpurposemove_03", "diag_imc_blisk_hp_generalpurposemove_67", "diag_imc_blisk_hp_generalpurposemove_68" ]
	// dummy lines for the registering to work // not good
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_get_a_a"] <- ["diag_imc_blisk_hp_statusupdates_30"]
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_get_b_b"] <- ["diag_imc_blisk_hp_statusupdates_32"]
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_get_c_c"] <- ["diag_imc_blisk_hp_statusupdates_34"]

	dialogAliases[TEAM_IMC]["hardpoint_player_captured_get_one"] <- ["diag_imc_blisk_hp_statusupdates_16"]

	// Capturing 3 of 3
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_a"] <- ["diag_imc_blisk_hp_allhpundercontrol_01", "diag_imc_blisk_hp_allhpundercontrol_03", "diag_imc_blisk_hp_allhpundercontrol_03"]
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_b"] <- ["diag_imc_blisk_hp_allhpundercontrol_01", "diag_imc_blisk_hp_allhpundercontrol_03", "diag_imc_blisk_hp_allhpundercontrol_03"]
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_c"] <- ["diag_imc_blisk_hp_allhpundercontrol_01", "diag_imc_blisk_hp_allhpundercontrol_03", "diag_imc_blisk_hp_allhpundercontrol_03"]

	// Capturing with enemies close by
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_enemy_a"] <- ["diag_imc_blisk_hp_hpcapturedenemypresence_02", "diag_imc_blisk_hp_hpcapturedenemypresence_03", "diag_imc_blisk_hp_hpcapturedenemypresence_51", "diag_imc_blisk_hp_hpcapturedenemypresence_52", "diag_imc_blisk_hp_hpcapturedenemypresence_53" ]
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_enemy_b"] <- ["diag_imc_blisk_hp_hpcapturedenemypresence_02", "diag_imc_blisk_hp_hpcapturedenemypresence_03", "diag_imc_blisk_hp_hpcapturedenemypresence_51", "diag_imc_blisk_hp_hpcapturedenemypresence_52", "diag_imc_blisk_hp_hpcapturedenemypresence_53" ]
	dialogAliases[TEAM_IMC]["hardpoint_player_captured_enemy_c"] <- ["diag_imc_blisk_hp_hpcapturedenemypresence_02", "diag_imc_blisk_hp_hpcapturedenemypresence_03", "diag_imc_blisk_hp_hpcapturedenemypresence_51", "diag_imc_blisk_hp_hpcapturedenemypresence_52", "diag_imc_blisk_hp_hpcapturedenemypresence_53" ]

	// Capturing outside of scene
	dialogAliases[TEAM_IMC]["hardpoint_captured_a"] <- ["diag_imc_blisk_hp_statusupdates_30", "diag_imc_blisk_hp_statusupdates_04", "diag_imc_blisk_hp_statusupdates_10"]
	dialogAliases[TEAM_IMC]["hardpoint_captured_b"] <- ["diag_imc_blisk_hp_statusupdates_32", "diag_imc_blisk_hp_statusupdates_06", "diag_imc_blisk_hp_statusupdates_12"]
	dialogAliases[TEAM_IMC]["hardpoint_captured_c"] <- ["diag_imc_blisk_hp_statusupdates_34", "diag_imc_blisk_hp_statusupdates_08", "diag_imc_blisk_hp_statusupdates_14"]
}

// Will be called from game_state_dialog.nut
function RegisterHardpointConversations()
{
	RegisterConversation( "hardpoint_match_progress_25_percent", VO_PRIORITY_GAMEMODE )
	RegisterConversation( "hardpoint_match_progress_50_percent", VO_PRIORITY_GAMEMODE )
	RegisterConversation( "hardpoint_match_progress_75_percent", VO_PRIORITY_GAMEMODE )

	foreach ( convName, aliases in dialogAliases[TEAM_MILITIA] )
	{
		RegisterConversation( convName, VO_PRIORITY_GAMEMODE )
	}

	local hardPointData = { a = "02", b = "03", c = "04" }

	foreach ( stringID, convID in hardPointData )
	{
		RegisterConversation( "hardpoint_player_status_0_" + stringID, VO_PRIORITY_GAMEMODE )
		RegisterConversation( "hardpoint_player_status_25_" + stringID, VO_PRIORITY_GAMEMODE )
		RegisterConversation( "hardpoint_player_status_50_" + stringID, VO_PRIORITY_GAMEMODE )
		RegisterConversation( "hardpoint_player_status_75_" + stringID, VO_PRIORITY_GAMEMODE )
		RegisterConversation( "hardpoint_player_status_100_" + stringID, VO_PRIORITY_GAMEMODE )

		RegisterConversation( "hardpoint_player_status_neutral_0_" + stringID, VO_PRIORITY_GAMEMODE )
		RegisterConversation( "hardpoint_player_status_neutral_25_" + stringID, VO_PRIORITY_GAMEMODE )
		RegisterConversation( "hardpoint_player_status_neutral_50_" + stringID, VO_PRIORITY_GAMEMODE )
		RegisterConversation( "hardpoint_player_status_neutral_75_" + stringID, VO_PRIORITY_GAMEMODE )
		RegisterConversation( "hardpoint_player_status_neutral_100_" + stringID, VO_PRIORITY_GAMEMODE )

		RegisterConversation( "hardpoint_player_captured_get_a_" + stringID, VO_PRIORITY_GAMEMODE )
		RegisterConversation( "hardpoint_player_captured_get_b_" + stringID, VO_PRIORITY_GAMEMODE )
		RegisterConversation( "hardpoint_player_captured_get_c_" + stringID, VO_PRIORITY_GAMEMODE )
		RegisterConversation( "hardpoint_player_captured_get_one_" + stringID, VO_PRIORITY_GAMEMODE )

		RegisterConversation( "hardpoint_player_captured_get_ab_" + stringID, VO_PRIORITY_GAMEMODE )
		RegisterConversation( "hardpoint_player_captured_get_ac_" + stringID, VO_PRIORITY_GAMEMODE )
		RegisterConversation( "hardpoint_player_captured_get_bc_" + stringID, VO_PRIORITY_GAMEMODE )
	}

	if ( IsServer() )
		return

	local convRef
	local sceneRef
	local teamArray = [ TEAM_IMC, TEAM_MILITIA ]
	foreach ( stringID, convID in hardPointData )
	{
		foreach( team in teamArray )
		{
			// Point Lost
			convRef = AddConversation( "hardpoint_lost_" + stringID, team )
			AddVDUIfWhiteListed( convRef, "hardpoint_lost_" + stringID, team, "bish" )

			// Point Losing
			convRef = AddConversation( "hardpoint_losing_" + stringID, team )
			AddVDUIfWhiteListed( convRef, "hardpoint_losing_" + stringID, team )

			// Point Captured
			convRef = AddConversation( "hardpoint_captured_" + stringID, team )
			AddVDUIfWhiteListed( convRef, "hardpoint_captured_" + stringID, team, "bish" )

			// Point Capping
			convRef = AddConversation( "hardpoint_capping_" + stringID, team )
			AddVDUIfWhiteListed( convRef, "hardpoint_capping_" + stringID, team )

			// Point Capping
			convRef = AddConversation( "hardpoint_engaging_" + stringID, team )
			AddVDUIfWhiteListed( convRef, "hardpoint_engaging_" + stringID, team )

			// Player Point Capping
			convRef = AddConversation( "hardpoint_player_capping_" + stringID, team )
			AddVDUIfWhiteListed( convRef, "hardpoint_player_capping_" + stringID, team, "bish" )

			// Player Lost
			convRef = AddConversation( "hardpoint_player_lost_" + stringID, team )
			AddVDUIfWhiteListed( convRef, "hardpoint_player_lost_" + stringID, team )

			// Player Point Captured
			convRef = AddConversation( "hardpoint_player_captured_" + stringID, team )
			AddVDUIfWhiteListed( convRef, "hardpoint_player_captured_" + stringID, team )

			// Player Point Captured enemy close
			convRef = AddConversation( "hardpoint_player_captured_enemy_" + stringID, team )
			AddVDUIfWhiteListed( convRef, "hardpoint_player_captured_enemy_" + stringID, team )

			// Player Point Approach
			convRef = AddConversation( "hardpoint_player_approach_ahead_" + stringID, team )
			AddVDUIfWhiteListed( convRef, "hardpoint_player_approach_ahead_" + stringID, team )
			convRef = AddConversation( "hardpoint_player_approach_enemy_" + stringID, team )
			AddVDUIfWhiteListed( convRef, "hardpoint_player_approach_enemy_" + stringID, team )
			convRef = AddConversation( "hardpoint_player_approach_" + stringID, team )
			AddVDUIfWhiteListed( convRef, "hardpoint_player_approach_" + stringID, team )

			// Player Point OOR
			convRef = AddConversation( "hardpoint_player_outofrange_" + stringID, team )
			AddVDUIfWhiteListed( convRef, "hardpoint_player_outofrange_" + stringID, team )

			// Player Point Contested
			convRef = AddConversation( "hardpoint_player_contested_" + stringID, team )
			AddVDUIfWhiteListed( convRef, "hardpoint_player_contested_" + stringID, team )
			convRef = AddConversation( "hardpoint_player_contested_capture_" + stringID, team )
			AddVDUIfWhiteListed( convRef, "hardpoint_player_contested_capture_" + stringID, team )

			// Player Point interference
			convRef = AddConversation( "hardpoint_player_interference_" + stringID, team )
			AddVDUIfWhiteListed( convRef, "hardpoint_player_interference_" + stringID, team )
			convRef = AddConversation( "hardpoint_player_interference_again_" + stringID, team )
			AddVDUIfWhiteListed( convRef, "hardpoint_player_interference_again_" + stringID, team )
//			convRef = AddConversation( "hardpoint_player_interference_reduced_" + stringID, team )
//			AddVDUIfWhiteListed( convRef, "hardpoint_player_interference_reduced_" + stringID, team )

			// Player Captured Get
			convRef = AddConversation( "hardpoint_player_captured_get_a_" + stringID, team )
			AddVDUIfWhiteListed( convRef, "hardpoint_player_captured_get_a_" + stringID, team )
			convRef = AddConversation( "hardpoint_player_captured_get_b_" + stringID, team )
			AddVDUIfWhiteListed( convRef, "hardpoint_player_captured_get_b_" + stringID, team )
			convRef = AddConversation( "hardpoint_player_captured_get_c_" + stringID, team )
			AddVDUIfWhiteListed( convRef, "hardpoint_player_captured_get_c_" + stringID, team )
			convRef = AddConversation( "hardpoint_player_captured_get_one_" + stringID, team )
			AddVDUIfWhiteListed( convRef, "hardpoint_player_captured_get_one", team )
			convRef = AddConversation( "hardpoint_player_captured_get_ab_" + stringID, team )
			AddVDUIfWhiteListed( convRef, "hardpoint_player_captured_get_ab", team )
			convRef = AddConversation( "hardpoint_player_captured_get_ac_" + stringID, team )
			AddVDUIfWhiteListed( convRef, "hardpoint_player_captured_get_ac", team )
			convRef = AddConversation( "hardpoint_player_captured_get_bc_" + stringID, team )
			AddVDUIfWhiteListed( convRef, "hardpoint_player_captured_get_bc", team )

			// Hardpoint Capture Status
			convRef = AddConversation( "hardpoint_player_status_0_" + stringID, team )
			AddVDUIfWhiteListed( convRef, "hardpoint_status_0_" + stringID, team )
			convRef = AddConversation( "hardpoint_player_status_25_" + stringID, team )
			AddVDUIfWhiteListed( convRef, "hardpoint_status_25", team )
			convRef = AddConversation( "hardpoint_player_status_50_" + stringID, team )
			AddVDUIfWhiteListed( convRef, "hardpoint_status_50", team )
			convRef = AddConversation( "hardpoint_player_status_75_" + stringID, team )
			AddVDUIfWhiteListed( convRef, "hardpoint_status_75", team )
			convRef = AddConversation( "hardpoint_player_status_100_" + stringID, team )
			AddVDUIfWhiteListed( convRef, "hardpoint_status_100", team )

			// Hardpoint Capture Status (Neutral)
			convRef = AddConversation( "hardpoint_player_status_neutral_0_" + stringID, team )
			AddVDUIfWhiteListed( convRef, "hardpoint_status_neutral_0_" + stringID, team )
			convRef = AddConversation( "hardpoint_player_status_neutral_25_" + stringID, team )
			AddVDUIfWhiteListed( convRef, "hardpoint_status_neutral_25", team  )
			convRef = AddConversation( "hardpoint_player_status_neutral_50_" + stringID, team )
			AddVDUIfWhiteListed( convRef, "hardpoint_status_neutral_50", team )
			convRef = AddConversation( "hardpoint_player_status_neutral_75_" + stringID, team )
			AddVDUIfWhiteListed( convRef, "hardpoint_status_neutral_75", team )
			convRef = AddConversation( "hardpoint_player_status_neutral_100_" + stringID, team )
			AddVDUIfWhiteListed( convRef, "hardpoint_status_neutral_100", team )
		}

		// Hardpoint Capture Scene, from approach to captured and lost etc.
		sceneRef = CreateScene( "hardpoint_player_" + stringID )
		foreach( team in teamArray )
		{
			AddSceneConversation( sceneRef, "hardpoint_player_approach_ahead_" + stringID, team, CONVFLAG_STARTPOINT )
			AddSceneConversation( sceneRef, "hardpoint_player_approach_enemy_" + stringID, team, CONVFLAG_STARTPOINT | CONVFLAG_GROUP )
			AddSceneConversation( sceneRef, "hardpoint_player_approach_" + stringID, team, CONVFLAG_STARTPOINT | CONVFLAG_GROUP )
			AddSceneConversation( sceneRef, "hardpoint_player_capping_" + stringID, team )
			AddSceneConversation( sceneRef, "hardpoint_player_captured_" + stringID, team, CONVFLAG_STARTPOINT | CONVFLAG_UNORDERED | CONVFLAG_ENDPOINT )
			AddSceneConversation( sceneRef, "hardpoint_player_captured_get_a_" + stringID, team, CONVFLAG_STARTPOINT | CONVFLAG_UNORDERED | CONVFLAG_ENDPOINT )
			AddSceneConversation( sceneRef, "hardpoint_player_captured_get_b_" + stringID, team, CONVFLAG_STARTPOINT | CONVFLAG_UNORDERED | CONVFLAG_ENDPOINT )
			AddSceneConversation( sceneRef, "hardpoint_player_captured_get_c_" + stringID, team, CONVFLAG_STARTPOINT | CONVFLAG_UNORDERED | CONVFLAG_ENDPOINT )
			AddSceneConversation( sceneRef, "hardpoint_player_captured_get_ac_" + stringID, team, CONVFLAG_STARTPOINT | CONVFLAG_UNORDERED | CONVFLAG_ENDPOINT )
			AddSceneConversation( sceneRef, "hardpoint_player_captured_get_bc_" + stringID, team, CONVFLAG_STARTPOINT | CONVFLAG_UNORDERED | CONVFLAG_ENDPOINT )
			AddSceneConversation( sceneRef, "hardpoint_player_captured_get_ab_" + stringID, team, CONVFLAG_STARTPOINT | CONVFLAG_UNORDERED | CONVFLAG_ENDPOINT )
			AddSceneConversation( sceneRef, "hardpoint_player_captured_enemy_" + stringID, team, CONVFLAG_STARTPOINT | CONVFLAG_UNORDERED | CONVFLAG_ENDPOINT )
			AddSceneConversation( sceneRef, "hardpoint_player_outofrange_" + stringID, team, CONVFLAG_UNORDERED )
			AddSceneConversation( sceneRef, "hardpoint_player_contested_capture_" + stringID, team, CONVFLAG_UNORDERED )

			// contested
			AddSceneConversation( sceneRef, "hardpoint_player_contested_" + stringID, team, CONVFLAG_UNORDERED )
			AddSceneConversation( sceneRef, "hardpoint_player_interference_" + stringID, team, CONVFLAG_UNORDERED )
			AddSceneConversation( sceneRef, "hardpoint_player_interference_again_" + stringID, team, CONVFLAG_UNORDERED )
//			AddSceneConversation( sceneRef, "hardpoint_player_interference_reduced_" + stringID, team, CONVFLAG_UNORDERED )

			AddSceneConversation( sceneRef, "hardpoint_player_status_0_" + stringID, team, CONVFLAG_UNORDERED )
			AddSceneConversation( sceneRef, "hardpoint_player_status_25_" + stringID, team, CONVFLAG_UNORDERED )
			AddSceneConversation( sceneRef, "hardpoint_player_status_75_" + stringID, team, CONVFLAG_UNORDERED )
			AddSceneConversation( sceneRef, "hardpoint_player_status_50_" + stringID, team, CONVFLAG_UNORDERED )
			AddSceneConversation( sceneRef, "hardpoint_player_status_100_" + stringID, team, CONVFLAG_UNORDERED )
			AddSceneConversation( sceneRef, "hardpoint_player_status_neutral_0_" + stringID, team, CONVFLAG_UNORDERED )
			AddSceneConversation( sceneRef, "hardpoint_player_status_neutral_25_" + stringID, team, CONVFLAG_UNORDERED )
			AddSceneConversation( sceneRef, "hardpoint_player_status_neutral_50_" + stringID, team, CONVFLAG_UNORDERED )
			AddSceneConversation( sceneRef, "hardpoint_player_status_neutral_75_" + stringID, team, CONVFLAG_UNORDERED )
			AddSceneConversation( sceneRef, "hardpoint_player_status_neutral_100_" + stringID, team, CONVFLAG_UNORDERED )

			AddSceneExclusion( sceneRef, "hardpoint_lost_" + stringID, team )
			AddSceneExclusion( sceneRef, "hardpoint_losing_" + stringID, team )
			AddSceneExclusion( sceneRef, "hardpoint_captured_" + stringID, team )
			AddSceneExclusion( sceneRef, "hardpoint_capping_" + stringID, team )
		}
	}

	// strings that the conversation system uses to display the correct character on the VDU
	local spyglass = "spyglass"
	local imc_commander = "blisk"  // use this guy for the male dispatcher until we get a non female dispatcher as well
	local imc_dispatch = "graves"
	local militia_soldier = "grunt"
	local militia_mac = "mac"
	local militia_sarah = "sarah"

	// All Points Lost MILITIA
	convRef = AddConversation( "hardpoint_lost_all", TEAM_MILITIA )
	AddRadio( convRef, dialogAliases[TEAM_MILITIA]["hardpoint_lost_all"] )

	// All Points Lost IMC
	convRef = AddConversation( "hardpoint_lost_all", TEAM_IMC )
	AddRadio( convRef, dialogAliases[TEAM_IMC]["hardpoint_lost_all"] )

	//Nag player to cap point, MILITIA
	/* One of 2 choices:
	Bish: "Ok boss, the more hardpoints you can connect me to, the sooner we win."
	Bish: "Remember buddy, the more hardpoints you patch me into, the faster we can finish the job." */
	convRef = AddConversation( "hardpoint_nag", TEAM_MILITIA )
	AddRadio( convRef, dialogAliases[TEAM_MILITIA][ "hardpoint_nag" ] )

	//Nag player to cap point, IMC
	/*One of 3 choices:
	Blisk: Pilot, I need you to secure the hardpoints. Eyes up! Check your map.
	Blisk: We're here for the hardpoints, Pilot, not the kills.
	Blisk: Hey! Your objectives are the hardpoints, not a bodycount. */
	convRef = AddConversation( "hardpoint_nag", TEAM_IMC )
	AddRadio( convRef, dialogAliases[TEAM_IMC][ "hardpoint_nag" ] )

	//CP Match Progress Announcement//
	AddVDULineForBish( "hardpoint_match_progress_25_percent", "diag_hp_mcor_bish_matchprogress_51" ) //Bish: All right, we're twenty-five percent of the way through the mission. Keep control of the hardpoints!
	AddVDULineForBish( "hardpoint_match_progress_25_percent", "diag_hp_mcor_bish_matchprogress_52" ) //Bish: We're at twenty-five percent of our mission goal. Let's keep it rollin'!
	AddVDULineForBish( "hardpoint_match_progress_25_percent", "diag_hp_mcor_bish_matchprogress_53" ) //Bish: Hey we've got about twenty-five percent of what we need. Keep it coming!

	AddVDULineForBish( "hardpoint_match_progress_50_percent", "diag_hp_mcor_bish_matchprogress_54" ) //Bish: We've got about half of what we need to finish the mission.  Keep the pressure on those hardpoints!
	AddVDULineForBish( "hardpoint_match_progress_50_percent", "diag_hp_mcor_bish_matchprogress_55" ) //Bish: We're halfway to our mission goal. Keep the pressure on!
	AddVDULineForBish( "hardpoint_match_progress_50_percent", "diag_hp_mcor_bish_matchprogress_56" ) //Bish: Alright we are about half-way through. Don't let up.

	AddVDULineForBish( "hardpoint_match_progress_75_percent",  "diag_hp_mcor_bish_matchprogress_57" ) //Bish: We got about seventy-five percent of what we need to complete the mission. Don't let up on those hardpoints!
	AddVDULineForBish( "hardpoint_match_progress_75_percent",  "diag_hp_mcor_bish_matchprogress_58" ) //Bish: We're seventy-five percent to our mission goal. Don't let upoints!


	AddVDULineForBlisk( "hardpoint_match_progress_25_percent", "diag_imc_blisk_hp_matchprogress_51" ) //Blisk: Alright, we're twenty-five percent through the mission. Keep control of the hardpoints!
	AddVDULineForBlisk( "hardpoint_match_progress_25_percent", "diag_imc_blisk_hp_matchprogress_52" ) //Blisk: We're at twenty-five percent of our mission goals. Keep at it!

	AddVDULineForBlisk( "hardpoint_match_progress_50_percent", "diag_imc_blisk_hp_matchprogress_53" ) //Blisk: We've got about half of what we need to finish the mission.  Keep the pressure on those hardpoints!
	AddVDULineForBlisk( "hardpoint_match_progress_50_percent", "diag_imc_blisk_hp_matchprogress_54" ) //Blisk: We're halfway to our mission goal. Keep the pressure on!

	AddVDULineForBlisk( "hardpoint_match_progress_75_percent", "diag_imc_blisk_hp_matchprogress_55" ) //Blisk: We got about seventy-five percent of what we need to complete the mission. Don't let up on those hardpoints!
	AddVDULineForBlisk( "hardpoint_match_progress_75_percent", "diag_imc_blisk_hp_matchprogress_56" ) //Blisk: We're seventy-five percent to our mission goal. Don't let up on those hardpoints!

}

function AddVDUIfWhiteListed( convRef, convName, team, VDUCharacter = null )
{
	if ( !VDUCharacter )
	{
		AddRadio( convRef, dialogAliases[ team ][ convName ] )
		return
	}

	if ( convName in level.whiteList[ team ] )
	{
		if ( convName in level.Conversations )
		{
			if ( level.Conversations[ convName ][team].len() > 1 )
			{
				//printt( "Conversation " + convName + " already registered previously as WhiteListedVDU, skipping re-registering" )
				return
			}
			else
			{
				local animName = level.whiteList[ team ][ convName ]
				//printt( "This is anim name: " + animName + " for convName: " + convName + " and character" + VDUCharacter + " and team: " + team )
				AddVDURadio( convRef, VDUCharacter, null, animName )
			}
		}
		else
		{

			Assert( false, ( "Had convName " + convName + " in whiteListTable, but not in level.conversation!" ) )

		}

	}
	else
	{
		//printt( "Had VDUCharacter " + VDUCharacter + ", but not conv " + convName + " not in whiteListTable! Defaulting back to adding as radio" )
		AddRadio( convRef, dialogAliases[ team ][ convName ] )
	}
}

main()
