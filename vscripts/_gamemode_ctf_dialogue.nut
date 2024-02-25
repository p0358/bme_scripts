
function main()
{
	RegisterCTFConversations()
}

// Will be called from game_state_dialog.nut
function RegisterCTFConversations()
{
	RegisterConversation( "enemy_took_flag",		VO_PRIORITY_GAMEMODE )
	RegisterConversation( "friendly_took_flag",		VO_PRIORITY_GAMEMODE )
	RegisterConversation( "enemy_captured_flag",	VO_PRIORITY_GAMEMODE )
	RegisterConversation( "friendly_captured_flag",	VO_PRIORITY_GAMEMODE )
	RegisterConversation( "enemy_returned_flag",	VO_PRIORITY_GAMEMODE )
	RegisterConversation( "friendly_returned_flag",	VO_PRIORITY_GAMEMODE )
	RegisterConversation( "enemy_dropped_flag",		VO_PRIORITY_GAMEMODE )
	RegisterConversation( "friendly_dropped_flag",	VO_PRIORITY_GAMEMODE )

	RegisterConversation( "player_took_flag",		VO_PRIORITY_GAMEMODE )
	RegisterConversation( "player_missing_flag",	VO_PRIORITY_GAMEMODE )

	if ( IsServer() )
		return

	local convRef
	convRef = AddConversation( "enemy_took_flag", TEAM_MILITIA )
	AddRadio( convRef, "diag_mcor_bish_ctf_enemyHasOurFlag_grp" )

	convRef = AddConversation( "friendly_took_flag", TEAM_MILITIA )
	AddRadio( convRef, "diag_mcor_bish_ctf_weTookEnemyFlag_grp" )

	convRef = AddConversation( "enemy_captured_flag", TEAM_MILITIA )
	AddRadio( convRef, "diag_mcor_bish_ctf_enemyCapturedOurFlag_grp" )

	convRef = AddConversation( "friendly_captured_flag", TEAM_MILITIA )
	AddRadio( convRef, "diag_mcor_bish_ctf_weCapturedEnemyFlag_grp" )

	convRef = AddConversation( "enemy_dropped_flag", TEAM_MILITIA )
	AddRadio( convRef, "diag_mcor_bish_ctf_enemyDroppedOurFlag_grp" )

	convRef = AddConversation( "friendly_dropped_flag", TEAM_MILITIA )
	AddRadio( convRef, "diag_mcor_bish_ctf_weDroppedEnemyFlag_grp" )

	convRef = AddConversation( "enemy_returned_flag", TEAM_MILITIA )
	AddRadio( convRef, "diag_mcor_bish_ctf_enemyFlagReturned_grp" )

	convRef = AddConversation( "friendly_returned_flag", TEAM_MILITIA )
	AddRadio( convRef, "diag_mcor_bish_ctf_ourFlagReturned_grp" )


	convRef = AddConversation( "player_took_flag", TEAM_MILITIA )
	AddRadio( convRef, "diag_mcor_bish_ctf_playerTookEnemyFlag_grp" )

	convRef = AddConversation( "player_missing_flag", TEAM_MILITIA )
	AddRadio( convRef, "diag_mcor_bish_ctf_flagReturnRemind_grp" )



	convRef = AddConversation( "enemy_took_flag", TEAM_IMC )
	AddRadio( convRef, "diag_imc_blisk_ctf_enemyHasOurFlag_grp" )

	convRef = AddConversation( "friendly_took_flag", TEAM_IMC )
	AddRadio( convRef, "diag_imc_blisk_ctf_weTookEnemyFlag_grp" )

	convRef = AddConversation( "enemy_captured_flag", TEAM_IMC )
	AddRadio( convRef, "diag_imc_blisk_ctf_enemyCapturedOurFlag_grp" )

	convRef = AddConversation( "friendly_captured_flag", TEAM_IMC )
	AddRadio( convRef, "diag_imc_blisk_ctf_weCapturedEnemyFlag_grp" )

	convRef = AddConversation( "enemy_dropped_flag", TEAM_IMC )
	AddRadio( convRef, "diag_imc_blisk_ctf_enemyDroppedOurFlag_grp" )

	convRef = AddConversation( "friendly_dropped_flag", TEAM_IMC )
	AddRadio( convRef, "diag_imc_blisk_ctf_weDroppedEnemyFlag_grp" )

	convRef = AddConversation( "enemy_returned_flag", TEAM_IMC )
	AddRadio( convRef, "diag_imc_blisk_ctf_enemyFlagReturned_grp" )

	convRef = AddConversation( "friendly_returned_flag", TEAM_IMC )
	AddRadio( convRef, "diag_imc_blisk_ctf_ourFlagReturned_grp" )


	convRef = AddConversation( "player_took_flag", TEAM_IMC )
	AddRadio( convRef, "diag_imc_blisk_ctf_playerTookEnemyFlag_grp" )

	convRef = AddConversation( "player_missing_flag", TEAM_IMC )
	AddRadio( convRef, "diag_imc_blisk_ctf_flagReturnRemind_grp" )

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

if ( GAMETYPE == CAPTURE_THE_FLAG )
	main()