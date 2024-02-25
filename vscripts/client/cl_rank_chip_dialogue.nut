const RANK_CHIP_COMMS_DELAY 			= 30.0 		// Make sure he doesn't speek for 30 seconds unless forced
const RANK_CHIP_FIRST_COMMS_DELAY 		= 120.0 	// Don't say anything until this far into the match
const RANK_CHIP_INTRO_RETRY_DELAY		= 5
const RANK_CHIP_OUTRO_RETRY_DELAY		= 5
const RANK_CHIP_MAX_INTRO_RETRIES		= 5
const RANK_CHIP_MAX_OUTRO_RETRIES		= 5
const RANK_CHIP_COMPLEMENT_PERCENT		= 60

enum eDialogueEventType
{
	DEFAULT = 0
	INTRO = 1
	OUTRO = 2
}

function main()
{
	Globalize( RankChip_PlayDialog )
	Globalize( RankChipAnnounceIntro )
	Globalize( RankChipMatchOver )
	Globalize( ChipSpeakSuccess )
	Globalize( RankChipNotification_Increase )

	file.playedIntro 						<- false
	file.playedOutro						<- false
	file.lastRankChipCommTime				<- 0

	file.chip <- {}

	// Match start
	file.chip[ "CHIP_ACTIVE" ] 			<- "diag_rp_chipActive_neut_chipai"

	// Rating updates...combined with numbers below
	file.chip[ "RATING_INCREASED" ] <- "diag_rp_ratingChangedPrefix_04_01a_neut_chipai"			// Rating increased.

	// Complements
	file.chipComplements <- []
	file.chipComplements.append( "diag_rp_ratingComment_02_01_neut_chipai" )					// Good work.
	file.chipComplements.append( "diag_rp_ratingComment_03_01_neut_chipai" )					// Keep it up.
	file.chipComplements.append( "diag_rp_ratingComment_01_01_neut_chipai" )					// Nice.
	file.chipComplements.append( "diag_rp_ratingComment_08_01_neut_chipai" )					// Nicely done.
	file.chipComplements.append( "diag_rp_ratingComment_05_01_neut_chipai" )					// Very good.
	file.chipComplements.append( "diag_rp_ratingComment_09_01_neut_chipai" )					// Well done.
	file.chipComplements.append( "diag_rp_ratingComment_04_01_neut_chipai" )					// Excellent.

	file.matchOverComplements <- []
	file.matchOverComplements.append( "diag_rp_ratingComment_02_01_neut_chipai" )				// Good work.
	file.matchOverComplements.append( "diag_rp_ratingComment_08_01_neut_chipai" )				// Nicely done.
	file.matchOverComplements.append( "diag_rp_ratingComment_09_01_neut_chipai" )				// Well done.

	file.matchOverComplementsExcellent <- []
	file.matchOverComplementsExcellent.append( "diag_rp_ratingComment_06_01_neut_chipai" )		// Very impressive.
	file.matchOverComplementsExcellent.append( "diag_rp_ratingComment_05_01_neut_chipai" )		// Very good.
	file.matchOverComplementsExcellent.append( "diag_rp_ratingComment_09_01_neut_chipai" )		// Well done.


	// Match over, tell final goals
	file.chip[ "MATCH_OVER_CONGRATS" ] <- "diag_rp_ratingComment_07_01_neut_chipai"				// Congratulations.
	file.chip[ "MATCH_OVER_EXCELLENT" ] <- "diag_rp_endScoreComment_01_01_neut_chipai"			// Excellent work, Pilot.

	file.chip[ "GOALS_FINAL_YOU_GOT_0" ] <- "diag_rp_endScorePrefix_01_01_neut_chipai"			// You reached:
	file.chip[ "GOALS_FINAL_YOU_GOT_1" ] <- "diag_rp_endScorePrefix_02_01_neut_chipai"			// You achieved:
	file.chip[ "GOALS_FINAL_YOU_GOT_2" ] <- "diag_rp_endScorePrefix_03_01_neut_chipai"			// You completed:

	// Match over, Generic
	file.chip[ "GOALS_FINAL_MULTIPLE_0" ] <- "diag_rp_endScoreOutcome_10_01_neut_chipai"		// Several rating goals.
	file.chip[ "GOALS_FINAL_MULTIPLE_1" ] <- "diag_rp_endScoreOutcome_11_01_neut_chipai"		// Multiple rating goals.
	file.chip[ "GOALS_FINAL_GOT_ALL_GOALS_0" ] <- "diag_rp_endScoreOutcome_13_01_neut_chipai"	// Your rating goals.
	file.chip[ "GOALS_FINAL_GOT_ALL_GOALS_1" ] <- "diag_rp_endScoreOutcome_14_01_neut_chipai"	// All rating goals.
	file.chip[ "GOALS_FINAL_GOT_ALL_GOALS_2" ] <- "diag_rp_endScoreOutcome_15_01_neut_chipai"	// All of your rating goals.
	file.chip[ "GOALS_FINAL_GOT_SINGLE_GOAL" ] <- "diag_rp_endScoreOutcome_12_01_neut_chipai"	// Your rating goal.

	// Match over, Two goals
	file.chip[ "GOALS_FINAL_GOT_1_of_2" ] <- "diag_rp_endScoreOutcome_03_01_neut_chipai"		// One of two rating goals.
	file.chip[ "GOALS_FINAL_GOT_2_of_2" ] <- "diag_rp_endScoreOutcome_05_01_neut_chipai"		// Both of your rating goals.

	// Match over, Three goals
	file.chip[ "GOALS_FINAL_GOT_1_of_3" ] <- "diag_rp_endScoreOutcome_07_01_neut_chipai"		// One of three rating goals.
	file.chip[ "GOALS_FINAL_GOT_2_of_3" ] <- "diag_rp_endScoreOutcome_08_01_neut_chipai"		// Two of three rating goals.
	file.chip[ "GOALS_FINAL_GOT_3_of_3" ] <- "diag_rp_endScoreOutcome_09_01_neut_chipai"		// All three of your rating goals.

	VerifySoundAliases( file.chip )
	VerifySoundAliases( file.chipComplements )
	VerifySoundAliases( file.matchOverComplements )
	VerifySoundAliases( file.matchOverComplementsExcellent )

	// Setup the events
	file.events <- {}
	file.events[ "chip_active" ] <- { priority = 5.0, debounce = 0.1, alwaysAnnounce = true }

	file.events[ "rating_increased" ] <- { priority = 1.0, debounce = 3.0 }

	file.events[ "match_over" ] <- { priority = 1.0, debounce = 1.0 }

	//Add defaults for alwaysAnnounce
	foreach( event in file.events )
	{
		if ( !("alwaysAnnounce" in event ) )
			event.alwaysAnnounce <- false
	}

	RegisterSignal( "RankChip_PlayDialogInternal" )
}


function VerifySoundAliases( aliases )
{
	foreach ( soundAlias in aliases )
	{
		if ( !GetDeveloperLevel() )
			continue

		if ( !DoesAliasExist( soundAlias ) )
			CodeWarning( "Alias "  + soundAlias + " does not exist!" )
	}
}


function RankChip_PlayDialog( player, eventType, eventData, dialogType = eDialogueEventType.DEFAULT )
{
   printt( "RankChip_PlayDialog, eventType: " + eventType  )

	if ( !IsAlive( player ) )
		return

	if ( !RankAnnounced() )
		return

	if ( player != GetLocalClientPlayer() )
		return

	if ( IsWatchingKillReplay() )
		return

	if ( player != GetLocalViewPlayer() )
		return

	if ( file.events[eventType].alwaysAnnounce == false ) //events marked as alwaysAnnounce == true skip these checks.
	{
		if ( level.CurrentPriority > 0 ) //Conversation system is currently talking, don't talk over Sarah/Blisk etc
			return

		if ( IsForcedDialogueOnly( player ) )
			return

		//if ( !GamePlayingOrSuddenDeath() )
		//	return
	}

	if ( player.s.titanCockpitDialogActive ) // Don't talk over the TitanOS
		return

	thread RankChip_PlayDialogInternal( player, eventType, eventData, dialogType )
}


function RankChip_PlayDialogInternal( player, eventType, eventData, dialogType )
{
	if ( player.s.rankChipDialogActive && file.events[eventType].priority <= file.events[player.s.rankChipDialogActive].priority )
	{
		printt( "Returning from RankChip_PlayDialogInternal because another higher priority dialog is taking place" )
		return
	}

	if ( Time() - player.s.lastDialogTime <= file.events[eventType].debounce )
	{
		local timeSince = Time() - player.s.lastDialogTime
		printt( "Returning from RankChip_PlayDialogInternal because debounce time for event" + eventType + " has not reached yet" )
		printt( "Debounce: " + file.events[eventType].debounce + ", Time since last dialogue: " + timeSince )
		return
	}

	player.Signal( "RankChip_PlayDialogInternal" )
	player.EndSignal( "RankChip_PlayDialogInternal" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )

	switch ( eventType )
	{
		case "chip_active":
			if ( ShouldPlayIntroVO() )
				player.s.rankChipDialogAliasList.append( file.chip[ "CHIP_ACTIVE" ] )
			break

		case "rating_increased":
			player.s.rankChipDialogAliasList.append( file.chip[ "RATING_INCREASED" ] )

			// Complement most of the time, but not always
			local diceRoll = RandomInt( 100 )
			printt("diceRoll:",diceRoll)
			if ( diceRoll <= RANK_CHIP_COMPLEMENT_PERCENT )
			{
				local index = RandomInt( file.chipComplements.len() )
				player.s.rankChipDialogAliasList.append( file.chipComplements[ index ] )
			}

			break

		case "match_over":

			if ( eventData.goalCount <= 0 )
				return

			// Did really well? Congratulate!
			if ( eventData.finalGoalsReached >= eventData.goalCount )
			{
				if ( CoinFlip() )
					player.s.rankChipDialogAliasList.append( file.chip[ "MATCH_OVER_CONGRATS" ] )
				else
					player.s.rankChipDialogAliasList.append( file.chip[ "MATCH_OVER_EXCELLENT" ] )
			}


			// Store an intro to use later
			local finalGoalIntroAlias = ""
			local num = RandomInt( 3 )
			finalGoalIntroAlias = file.chip[ "GOALS_FINAL_YOU_GOT_" + num ]

			// Customize the dialog based on how many goals player achieved
			if ( ( eventData.goalCount == 2 ) || ( eventData.goalCount == 3 ) )			// We have sepcial VO lines for 2 or 3 goals, so use them to add variety
			{
				if( eventData.finalGoalsReached > 0 )
				{
					player.s.rankChipDialogAliasList.append( finalGoalIntroAlias )

					local alias = "GOALS_FINAL_GOT_" + eventData.finalGoalsReached + "_of_" + eventData.goalCount
					if ( alias in file.chip )
					{
						player.s.rankChipDialogAliasList.append( file.chip[ alias ] )
					}
					else
					{
						if ( CoinFlip() )
							player.s.rankChipDialogAliasList.append( file.chip[ "GOALS_FINAL_MULTIPLE_0" ] )
						else
							player.s.rankChipDialogAliasList.append( file.chip[ "GOALS_FINAL_MULTIPLE_1" ] )
					}
				}
			}
			else if ( eventData.finalGoalsReached == eventData.goalCount ) 					// Player got all goals
			{
				local num = RandomInt( 3 )
				player.s.rankChipDialogAliasList.append( finalGoalIntroAlias )
				player.s.rankChipDialogAliasList.append( file.chip[ "GOALS_FINAL_GOT_ALL_GOALS_" + num ] )
			}
			else  																			// There are multiple goals and they player got multiple
			{
				// We don't have a VO line for "1 of X goals" so just play "...your rating goal" even for "1 of 2" for example
				if ( eventData.finalGoalsReached == 1 )
				{
					player.s.rankChipDialogAliasList.append( finalGoalIntroAlias )
					player.s.rankChipDialogAliasList.append( file.chip[ "GOALS_FINAL_GOT_SINGLE_GOAL" ] )
				}
				else if ( eventData.finalGoalsReached > 1 )
				{
					player.s.rankChipDialogAliasList.append( finalGoalIntroAlias )

					if ( CoinFlip() )
						player.s.rankChipDialogAliasList.append( file.chip[ "GOALS_FINAL_MULTIPLE_0" ] )
					else
						player.s.rankChipDialogAliasList.append( file.chip[ "GOALS_FINAL_MULTIPLE_1" ] )
				}
			}

			// Add a complement
			if( eventData.finalGoalsReached >= eventData.goalCount )
			{
				local index = RandomInt( file.matchOverComplementsExcellent.len() )
				player.s.rankChipDialogAliasList.append( file.matchOverComplementsExcellent[ index ] )
			}
			else if ( eventData.finalGoalsReached > 0 )
			{
				local index = RandomInt( file.matchOverComplements.len() )
				player.s.rankChipDialogAliasList.append( file.matchOverComplements[ index ] )
			}

			break

		default:
			Assert( eventType in file.chip, eventType + " is not setup for event playback" )

			// direct add if it is in both
			player.s.rankChipDialogAliasList = [ file.chip[ eventType ] ]
	}


	player.s.lastDialogTime = Time()
	player.s.rankChipDialogActive = eventType


	OnThreadEnd(
		function() : ( player )
		{
			if ( !IsConnected() )  //Temp fix for SRE on disconnecting, real fix is to get a code variable instead of using persistent variable
				return

			foreach ( soundAlias in player.s.rankChipDialogAliasList )
			{
				StopSoundOnEntity( player, soundAlias )
			}

			player.s.rankChipDialogAliasList = []
			player.s.rankChipDialogActive = null
		}
	)


	// Play the sound aliases one after the other
	foreach ( soundAlias in player.s.rankChipDialogAliasList )
	{
		wait EmitSoundOnEntity( player, soundAlias )
		wait 0.1
	}


	if ( player.s.rankChipDialogAliasList.len() > 0 )
		ChipSpeakSuccess( dialogType )
}


function ShouldPlayRankChipDialogue( highPriority = false )
{
	if ( highPriority )
		return true

	if ( Time() < RANK_CHIP_FIRST_COMMS_DELAY )
		return false

	local timeSinceLastComm = Time() - file.lastRankChipCommTime
	if ( timeSinceLastComm >= RANK_CHIP_COMMS_DELAY )
		return true
	else
		return false

	// Don't play in kill replay
	if ( !GamePlaying() )
		return false
}

function ShouldPlayIntroVO()
{
	local gameMode = GameRules.GetGameMode()

	if ( gameMode == MARKED_FOR_DEATH )
		return false

	if ( gameMode == MARKED_FOR_DEATH_PRO )
		return false

	// INFO : Add more game modes if necessary

	return true
}

// Called when chip actually gets to speak so that we try again with the next rating update if overtalked by someone
function ChipSpeakSuccess( dialogType )
{
	switch ( dialogType )
	{
		case eDialogueEventType.INTRO:
			printt("ChipSpeakSuccess: INTRO")
			file.playedIntro = true
			break

		case eDialogueEventType.OUTRO:
			printt("ChipSpeakSuccess: OUTRO")
			file.playedOutro = true
			break

		default:
			printt("ChipSpeakSuccess: default")
			break
	}

	file.lastRankChipCommTime = Time()
}


function RankChipNotification_Increase( delay = 0 )
{
	if ( !ShouldPlayRankChipDialogue() )
		return

	local player = GetLocalClientPlayer()

	if ( !IsValid( player ) )
		return

	wait delay   // Let it breath a little before commenting

	RankChip_PlayDialog( player, "rating_increased", GetRankEventData() )
}

function RankChipAnnounceIntro()
{
	for ( local i = 0; i < RANK_CHIP_MAX_INTRO_RETRIES; i++ )
	{
		if ( file.playedIntro )
			return

		local player = GetLocalClientPlayer()
		if ( !IsValid( player ) )
			return

		if ( ShouldPlayRankChipDialogue( true ) )
			RankChip_PlayDialog( player, "chip_active", GetRankEventData(), eDialogueEventType.INTRO )

		wait RANK_CHIP_INTRO_RETRY_DELAY
	}
}

function RankChipMatchOver()
{
	for ( local i = 0; i < RANK_CHIP_MAX_OUTRO_RETRIES; i++ )
	{
		if ( file.playedOutro )
			return

		local player = GetLocalClientPlayer()
		if ( !IsValid( player ) )
			return

		if ( ShouldPlayRankChipDialogue( true ) )
			RankChip_PlayDialog( player, "match_over", GetRankEventData(), eDialogueEventType.OUTRO )

		wait RANK_CHIP_OUTRO_RETRY_DELAY
	}
}


function dev_testMatchOverVO( goalCount, goalsReached )
{
	local data = {}

	data.goalCount				<- goalCount
	data.finalGoalsReached		<- goalsReached
	data.oldPerformance			<- 0
	data.currentPerformance 	<- 0

	local player = GetLocalClientPlayer()
	RankChip_PlayDialog( player, "match_over", data, eDialogueEventType.OUTRO )

}

function dev_autoTestMatchOverVO()
{
	for(local i = 1; i < 5; i++ )
		for( local j = 0; j < 5; j++)
		{
			printt("Completed", j, "of", i, "rating goals." )

			dev_testMatchOverVO( i, j )

			wait 5
		}
}
Globalize( dev_autoTestMatchOverVO )