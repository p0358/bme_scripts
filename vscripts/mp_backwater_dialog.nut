
function main()
{
	if ( GAMETYPE != CAPTURE_POINT )
		return

	CapturePointDialogOverride()

	if ( IsServer() )
		return
}

function CapturePointDialogOverride()
{
	//Backwater's B is not in a building, so only use these ones.
	local dialogAliases = level.dialogAliases

	dialogAliases[TEAM_MILITIA]["hardpoint_player_approach_ahead_b"] = [ "diag_hp_mcor_bish_closehpcheckmap_02", "diag_hp_mcor_bish_closehpcheckhud_02" ]
	dialogAliases[TEAM_MILITIA]["hardpoint_player_approach_b"] = [ "diag_hp_mcor_bish_closehpcheckmap_02", "diag_hp_mcor_bish_closehpcheckhud_02" ]

	dialogAliases[TEAM_IMC]["hardpoint_player_approach_ahead_b"] = [ "diag_imc_blisk_hp_closehpcheckmap_02", "diag_imc_blisk_hp_closehpcheckhud_02" ]
	dialogAliases[TEAM_IMC]["hardpoint_player_approach_b"] = [ "diag_imc_blisk_hp_closehpcheckmap_02", "diag_imc_blisk_hp_closehpcheckhud_02" ]

}

