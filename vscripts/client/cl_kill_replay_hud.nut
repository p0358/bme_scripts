function main()
{
	Globalize( KillReplayHud_AddClient )
	Globalize( KillReplayHud_Activate )
	Globalize( KillReplayHud_Deactivate )
	Globalize( UpdateKillReplayIconPosition )

	RegisterSignal( "DeactivateKillReplayHud" )

	AddKillReplayStartedCallback( KillReplayHud_Activate )
	AddKillReplayEndedCallback( KillReplayHud_Deactivate )
}

function EntitiesDidLoad()
{
	if ( !GetRoundWinningKillEnabled() ) //Need to check in EntitiesDidLoad as opposed to main() since the .nv isn't set yet in main()
		return

	AddKillReplayStartedCallback( RoundWinningKillReplayClientHudThink )
	AddKillReplayStartedCallback( HideSpectatorSelectOnReplayStart )
	AddKillReplayEndedCallback( RoundWinningKillReplayScreenBlack )
}

function KillReplayHud_AddClient()
{
	local player = GetLocalClientPlayer()
	local hudGroup 	= HudElementGroup( "KillReplayHudGroup" )
	local timeToKillTextGroup = HudElementGroup( "timeToKillTextGroup" )

	player.cv.KillReplayDeathIcon <- hudGroup.CreateElement( "KillReplayDeathIcon" )
	player.cv.KillReplayTimeToKillTimerText <- timeToKillTextGroup.CreateElement( "timeToKillTimerText" )
	player.cv.KillReplayWatching <- hudGroup.CreateElement( "KillReplayWatching" )

	hudGroup.AddGroup( timeToKillTextGroup  )

	player.cv.killReplayHudGroup <- hudGroup
	player.cv.KillReplayTimeToKillTextGroup <- timeToKillTextGroup

	player.cv.killReplayTimeOfDeath <- 0
}

function KillReplayHud_Activate()
{
	thread KillReplayHud_Activate_threaded()
}

function KillReplayHud_Activate_threaded()
{
	local player = GetLocalClientPlayer()

	player.cv.killReplayHudGroup.Show()
	//UpdateKillReplayIconPosition()
	thread KillReplayIconPosition_Think()

	while ( TimeAdjustmentForRemoteReplayCall() == 0 ) //Hacky. Reported as bug 37773 to code
	{
		//printt( "TimeAdjustmentForRemoteReplayCall() is returning 0" )
		wait 0
	}

	local timeToKill

	if ( IsReplayRoundWinning() )
	{
		//printt( "This is time: " + Time() + ", this is level.nv.gameStateChangeTime  : " +  level.nv.gameStateChangeTime  +", this is TimeAdjustmentForRemoteReplayCall()" + TimeAdjustmentForRemoteReplayCall())
		timeToKill = TimeAdjustmentForRemoteReplayCall() +  level.nv.gameStateChangeTime  //Somewhat hacky: Dependent on RoundWinningKillReplay taking place in WinnerDetermined, and assumes that a kill is the trigger for a round win.
	}
	else
	{
		//printt( "This is time: " + Time() + ", this is player.cv.killReplayTimeOfDeath : " +  player.cv.killReplayTimeOfDeath +", this is TimeAdjustmentForRemoteReplayCall()" + TimeAdjustmentForRemoteReplayCall())
		timeToKill = TimeAdjustmentForRemoteReplayCall() +  player.cv.killReplayTimeOfDeath
		ShowRespawnSelect()
	}

	thread UpdateTimeToKillText( timeToKill )
}

function UpdateKillReplayIconPosition()  //Old style Not used right now.
{
	local player = GetLocalClientPlayer()

	local icon = player.cv.KillReplayDeathIcon
	icon.SetClampToScreen( CLAMP_RECT )

	local zOffset

	 //zOffset = ( player.GetWorldSpaceCenter().z - player.GetOrigin().z ) * 2.2

	 //zOffset = player.GetAttachmentOrigin( headAttachmentID ).z -  ( player.GetOrigin().z )  + player.GetWorldSpaceCenter().z
	 //zOffset = player.GetAttachmentOrigin( headAttachmentID ).z //-  ( player.GetOrigin().z )  + player.GetWorldSpaceCenter().z
	 printt( "zOffset: " + zOffset  )

	/*if ( player.IsTitan() )
		zOffset = 270
	else
		zOffset = 90*/

	icon.SetEntity( player, Vector( 0, 0, zOffset ), 0.5, 0.5 )

}


function KillReplayIconPosition_Think()
{
	local player = GetLocalClientPlayer()

	if ( IsReplayRoundWinning() )
	{
		// for now, this will also hide the death icon when AI get the round winning kill
		player.cv.KillReplayDeathIcon.Hide()
		return
	}

	player.EndSignal( "DeactivateKillReplayHud" )
	player.EndSignal( "OnDestroy" )

	local headFocusID = player.LookupAttachment( "headfocus" )

	local icon = player.cv.KillReplayDeathIcon
	icon.SetClampToScreen( CLAMP_RECT )

	local killPlayer = GetLocalViewPlayer()

	while( true )
	{
		local zOffset = 20

		local distSqr = ( killPlayer.GetOrigin() - player.GetOrigin() ).LengthSqr()

		//printt( "distSqr", distSqr )

		local multiplier = GraphCapped( distSqr, 0, 1000000, 1.0, 3.0 ) //Scale based on distance. TODO: Scale based on screen space instead of world space. Test case: Try using sniper scope on a far away guy

		icon.SetOrigin( player.GetAttachmentOrigin( headFocusID )  + Vector( 0, 0, zOffset * multiplier ) )
		wait 0
	}
}

function KillReplayHud_Deactivate()
{
	local player = GetLocalClientPlayer()

	player.cv.KillReplayWatching.Hide()
	player.cv.killReplayHudGroup.Hide()
	player.cv.vignette.Hide()

	player.Signal( "DeactivateKillReplayHud" )
}

function UpdateTimeToKillText( timeToKill )
{
	local player = GetLocalClientPlayer()

	player.cv.vignette.SetColor( 0, 32, 64, 255 )
	player.cv.vignette.Show()

	player.cv.KillReplayTimeToKillTextGroup.SetAlpha( 255 )
	player.cv.KillReplayTimeToKillTextGroup.Show()

	SetKillReplayDescriptionText( player, timeToKill )

	player.cv.KillReplayTimeToKillTimerText.SetAutoText( "#KILLREPLAY_COUNTDOWNTIME", HATT_GAME_COUNTDOWN_SECONDS_MILLISECONDS, timeToKill )
	player.cv.KillReplayTimeToKillTimerText.EnableAutoText()
	player.cv.KillReplayTimeToKillTimerText.SetAlpha( 0 )
	player.cv.KillReplayTimeToKillTimerText.FadeOverTime( 255, 0.5)

	wait 0.5
	timeToKill -= 0.5

	player.cv.KillReplayTimeToKillTextGroup.FadeOverTimeDelayed( 0, 1.0, timeToKill - Time() )
}

function SetKillReplayDescriptionText( player, timeToKill )
{
	if ( IsReplayRoundWinning() )
	{
		//Let announcement tell who you're watching etc
		player.cv.KillReplayWatching.Hide()
		return
	}

	if ( level.nameOfLastKiller )
	{
		local attackerName = level.nameOfLastKiller.attackerName
		local attackerPetName = level.nameOfLastKiller.attackerPetName

		if ( attackerPetName == "" )
			player.cv.KillReplayWatching.SetText( "#KILLREPLAY_WATCHING", attackerName )
		else
			player.cv.KillReplayWatching.SetText( "#KILLREPLAY_WATCHING_PET", attackerName, attackerPetName )

		player.cv.KillReplayWatching.SetAlpha( 0 )
		player.cv.KillReplayWatching.Show()
		player.cv.KillReplayWatching.FadeOverTime( 255, 0.5)
	}
}

function RoundWinningKillReplayClientHudThink()
{
	if ( GetRoundWinningKillEnabled() == false )
		return

	if ( IsReplayRoundWinning()  == false )
		return

	thread RoundWinningKillReplayClientHudThink_threaded()
}

function RoundWinningKillReplayClientHudThink_threaded()
{
	local clientPlayer = GetLocalClientPlayer()
	clientPlayer.EndSignal( "OnDestroy" )

	local outcomeAnnouncement = CAnnouncement( "#KILL_REPLAY_ROUND_WINNING_KILL_ANNOUNCEMENT" )
	outcomeAnnouncement.SetTitleColor( [255, 255, 100] )
	outcomeAnnouncement.SetHideOnDeath( false )
	outcomeAnnouncement.SetDuration( ROUND_WINNING_KILL_REPLAY_LENGTH_OF_REPLAY - ROUND_WINNING_KILL_REPLAY_POST_DEATH_TIME  )
	outcomeAnnouncement.SetPurge( true )
	outcomeAnnouncement.SetSoundAlias( "UI_InGame_TransitionToKillReplay" )
	DecideSubTextForRoundWinningKillReplay( outcomeAnnouncement, clientPlayer )
	AnnouncementFromClass( clientPlayer, outcomeAnnouncement )

	local fadeStartDelay = ROUND_WINNING_KILL_REPLAY_LENGTH_OF_REPLAY - ROUND_WINNING_KILL_REPLAY_SCREEN_FADE_TIME
	wait fadeStartDelay

	ClientScreenFadeToBlack( ROUND_WINNING_KILL_REPLAY_SCREEN_FADE_TIME )

	wait( ROUND_WINNING_KILL_REPLAY_LENGTH_OF_REPLAY - fadeStartDelay - ROUND_WINNING_KILL_REPLAY_POST_DEATH_TIME )
	SetCrosshairPriorityState( crosshairPriorityLevel.ROUND_WINNING_KILL_REPLAY, CROSSHAIR_STATE_HIDE_ALL )

	wait 2.0

	Assert( level.nv.winningTeam != null ) //We just did a round winning kill replay,that means someone won the round!

	local announcementDuration
	local subtext2IconDelay
	local conversationDelay
	local wonAnnouncementString
	local lostAnnouncementString

	if ( level.nv.roundScoreLimitComplete == true )
	{
		announcementDuration = 6.0
		subtext2IconDelay = 0.5
		conversationDelay = 1.5
		wonAnnouncementString = "#GAMEMODE_VICTORY"
		lostAnnouncementString = "#GAMEMODE_DEFEATED"
	}
	else
	{
		announcementDuration = 4.0
		subtext2IconDelay = 0.5
		conversationDelay = 1.5
		wonAnnouncementString = "#GAMEMODE_ROUND_WIN"
		lostAnnouncementString = "#GAMEMODE_ROUND_LOSS"
	}



	if ( clientPlayer.GetTeam() == level.nv.winningTeam )
	{
		local outcomeAnnouncement = CAnnouncement( wonAnnouncementString )
		outcomeAnnouncement.SetTitleColor( [100, 255, 100] )
		outcomeAnnouncement.SetHideOnDeath( false )
		outcomeAnnouncement.SetPurge( true )
		outcomeAnnouncement.SetDuration( announcementDuration)

		ShowRoundScoresInAnnouncement( outcomeAnnouncement, subtext2IconDelay )
		if ( level.nv.roundScoreLimitComplete == false )
			thread PlayRoundWonConversationWithAnnouncementDelay( conversationDelay )

		AnnouncementFromClass( clientPlayer, outcomeAnnouncement )

	}
	else if ( level.nv.winningTeam != TEAM_UNASSIGNED )
	{
		local outcomeAnnouncement = CAnnouncement( lostAnnouncementString )
		outcomeAnnouncement.SetTitleColor( [255, 100, 100] )
		outcomeAnnouncement.SetHideOnDeath( false )
		outcomeAnnouncement.SetPurge( true )
		outcomeAnnouncement.SetDuration( announcementDuration)

		ShowRoundScoresInAnnouncement( outcomeAnnouncement, subtext2IconDelay )
		if ( level.nv.roundScoreLimitComplete == false )
			thread PlayRoundWonConversationWithAnnouncementDelay( conversationDelay )

		AnnouncementFromClass( clientPlayer, outcomeAnnouncement )
	}
}

function DecideSubTextForRoundWinningKillReplay( outcomeAnnouncement, clientPlayer )
{
	local viewEntity = GetViewEntity()
	Assert ( viewEntity != null ) //Think this assumption is broken sometimes, would like repro

	local names = GetAttackerDisplayNamesFromClassname( viewEntity )
	local attackerName = names.attackerName
	local attackerPetName = names.attackerPetName

	local victimPlayer = GetEntityFromEncodedEHandle( level.nv.roundWinningKillReplayVictimEHandle )
	//printt( "victimPlayer: "  + victimPlayer)
	Assert( IsValid( victimPlayer ) )
	local victimPlayerName =  victimPlayer.GetPlayerName()

	local viewEntityIsSameTeam = viewEntity.GetTeam() == clientPlayer.GetTeam()
	local wasKilledByPet = attackerPetName == "" ? false: true

	local subString
	local subStringArgs
	if ( viewEntity == victimPlayer ) //This is a suicide
	{
		subString = viewEntityIsSameTeam ? "#KILL_REPLAY_ROUND_WINNING_KILL_WATCHING_FRIENDLY_SUICIDE" : "#KILL_REPLAY_ROUND_WINNING_KILL_WATCHING_ENEMY_SUICIDE"
		subStringArgs = [ victimPlayerName ]

}
	else if ( wasKilledByPet )
	{
		subString = viewEntityIsSameTeam ? "#KILL_REPLAY_ROUND_WINNING_KILL_WATCHING_FRIENDLY_PET_KILL" : "#KILL_REPLAY_ROUND_WINNING_KILL_WATCHING_ENEMY_PET_KILL"
		subStringArgs =  [ attackerName, attackerPetName, victimPlayerName ]
	}
	else
	{
		subString = viewEntityIsSameTeam ? "#KILL_REPLAY_ROUND_WINNING_KILL_WATCHING_FRIENDLY_KILL" : "#KILL_REPLAY_ROUND_WINNING_KILL_WATCHING_ENEMY_KILL"
		subStringArgs = [ attackerName, victimPlayerName ]
	}

	outcomeAnnouncement.SetSubText( subString )
	outcomeAnnouncement.SetOptionalSubTextArgsArray( subStringArgs )
}

function RoundWinningKillReplayScreenBlack()
{
	if ( GetRoundWinningKillEnabled() == false )
		return

	if ( IsReplayRoundWinning()  == false )
		return

	ClientSetScreenColor( 0, 0, 2, 255 )
}

function HideSpectatorSelectOnReplayStart()
{
	local clientPlayer = GetLocalClientPlayer()
	HideSpectatorSelectButtons( clientPlayer )
}