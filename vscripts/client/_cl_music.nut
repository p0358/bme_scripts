const DEFAULT_FADE_TIME = 2.0
const DEFAULT_MUSIC_GAP_TIME = 4.0
const ACTION_MUSIC_DEBOUNCE_TIME = 30
const MATCH_PROGRESS_ACTION_MUSIC_SHIFT_THRESHOLD = 50

function main()
{
	level.musicForTeam <- {}
	level.musicForTeam[ TEAM_IMC ] <- {}
	level.musicForTeam[ TEAM_MILITIA ] <- {}

	level.currentMusicPlaying <- null
	level.currentLoopingMusic <- null
	Globalize( PlayMusic )
	Globalize( ForcePlayMusic )
	Globalize( ForcePlayMusicToCompletion )
	Globalize( StopMusic )

	Globalize( DecidePilotMusicToPlay )
	Globalize( DecideTitanMusicToPlay )
	Globalize( PlayActionMusic )
	Globalize( LoopLobbyMusic )
	Globalize( SetForcedMusicOnly )
	Globalize( ForceLoopMusic )
	Globalize( StopLoopMusic )
	Globalize( RegisterCinematicMusic )
	Globalize( RegisterClassicMPMusic )
	Globalize( SetClassMusicEnabled )
	Globalize( GetClassMusicEnabled )
	Globalize( SetGameStateMusicEnabled )
	Globalize( GetGameStateMusicEnabled )

	Globalize( ServerCallback_PlayTeamMusicEvent )
	Globalize( RegisterLevelMusicForTeam )

	level.forcedMusicOnly <- false
	level.musicEnabled <- true
	level.lastTimeActionMusicPlayed <- 0
	level.pilotMusicAttemptCount <- 0
	level.titanMusicAttemptCount <- 0
	level.currentClassMusicType <- null
	level.classMusicEnabled <- true
	level.gameStateMusicEnabled <- true
	//level.debugCount <- 0

	RegisterSignal( "MusicPlayed" )
	RegisterSignal( "MusicStopped" )
	RegisterSignal( "ForceMusicPlayed" )
	RegisterSignal( "ForceLoopMusic" )
	RegisterSignal( "StopLoopMusic" )

	InitDefaultMusic()
	RegisterServerVarChangeCallback( "gameState", GameStateChanged )
}

function InitDefaultMusic()
{
	//Action music. These will be replaced later when the game passes the halfway progression point.
	level.musicForTeam[ TEAM_IMC ][ eMusicPieceID.TITAN_ACTION_LOW_1 ] <- "Music_AngelCity_IMC_TitanAction1_LOW"
	level.musicForTeam[ TEAM_IMC ][ eMusicPieceID.TITAN_ACTION_LOW_2 ] <- "Music_AngelCity_IMC_TitanAction2_LOW"
	level.musicForTeam[ TEAM_IMC ][ eMusicPieceID.PILOT_ACTION_LOW_1 ] <- "Music_AngelCity_IMC_PilotAction1_LOW"
	level.musicForTeam[ TEAM_IMC ][ eMusicPieceID.PILOT_ACTION_LOW_2 ] <- "Music_AngelCity_IMC_PilotAction2_LOW"

	level.musicForTeam[ TEAM_MILITIA ][ eMusicPieceID.TITAN_ACTION_LOW_1 ] <- "Music_AngelCity_MCOR_TitanAction1_LOW"
	level.musicForTeam[ TEAM_MILITIA ][ eMusicPieceID.TITAN_ACTION_LOW_2 ] <- "Music_AngelCity_MCOR_TitanAction2_LOW"
	level.musicForTeam[ TEAM_MILITIA ][ eMusicPieceID.PILOT_ACTION_LOW_1 ] <- "Music_AngelCity_MCOR_PilotAction1_LOW"
	level.musicForTeam[ TEAM_MILITIA ][ eMusicPieceID.PILOT_ACTION_LOW_2 ] <- "Music_AngelCity_MCOR_PilotAction2_LOW"

	level.musicForTeam[ TEAM_IMC ][ eMusicPieceID.TITAN_ACTION_HIGH_1 ] <- "Music_AngelCity_IMC_TitanAction1_HIGH"
	level.musicForTeam[ TEAM_IMC ][ eMusicPieceID.TITAN_ACTION_HIGH_2 ] <- "Music_AngelCity_IMC_TitanAction2_HIGH"
	level.musicForTeam[ TEAM_IMC ][ eMusicPieceID.PILOT_ACTION_HIGH_1 ] <- "Music_AngelCity_IMC_PilotAction1_HIGH"
	level.musicForTeam[ TEAM_IMC ][ eMusicPieceID.PILOT_ACTION_HIGH_2 ] <- "Music_AngelCity_IMC_PilotAction2_HIGH"

	level.musicForTeam[ TEAM_MILITIA ][ eMusicPieceID.TITAN_ACTION_HIGH_1 ] <- "Music_AngelCity_MCOR_TitanAction1_HIGH"
	level.musicForTeam[ TEAM_MILITIA ][ eMusicPieceID.TITAN_ACTION_HIGH_2 ] <- "Music_AngelCity_MCOR_TitanAction2_HIGH"
	level.musicForTeam[ TEAM_MILITIA ][ eMusicPieceID.PILOT_ACTION_HIGH_1 ] <- "Music_AngelCity_MCOR_PilotAction1_HIGH"
	level.musicForTeam[ TEAM_MILITIA ][ eMusicPieceID.PILOT_ACTION_HIGH_2 ] <- "Music_AngelCity_MCOR_PilotAction2_HIGH"

	//to start playing at the beginning of the 10 second countdown and playing through the intro
	level.musicForTeam[ TEAM_IMC ][ eMusicPieceID.LEVEL_INTRO ] <- "Music_AngelCity_IMC_Opening"
	level.musicForTeam[ TEAM_MILITIA ][ eMusicPieceID.LEVEL_INTRO ] <- "Music_AngelCity_MCOR_Opening"

	//- To be played starting at the Epilogue when your team wins
	level.musicForTeam[ TEAM_IMC ][ eMusicPieceID.LEVEL_WIN ] <- "Music_AngelCity_IMC_Win"
	level.musicForTeam[ TEAM_MILITIA ][ eMusicPieceID.LEVEL_WIN ] <- "Music_AngelCity_MCOR_Win"

	//To be played starting at the Epilogue when your team loses
	level.musicForTeam[ TEAM_IMC ][ eMusicPieceID.LEVEL_LOSS ] <- "Music_AngelCity_IMC_Lose"
	level.musicForTeam[ TEAM_MILITIA ][ eMusicPieceID.LEVEL_LOSS ] <- "Music_AngelCity_MCOR_Lose"

	//To be played starting at the Epilogue when it is a draw. Right now just use loss music
	level.musicForTeam[ TEAM_IMC ][ eMusicPieceID.LEVEL_DRAW ] <- "Music_AngelCity_IMC_Lose"
	level.musicForTeam[ TEAM_MILITIA ][ eMusicPieceID.LEVEL_DRAW ] <- "Music_AngelCity_MCOR_Lose"

	//To be played when Sudden Death starts
	level.musicForTeam[ TEAM_IMC ][ eMusicPieceID.LEVEL_SUDDEN_DEATH ] <- "Music_SuddenDeath_IMC"
	level.musicForTeam[ TEAM_MILITIA ][ eMusicPieceID.LEVEL_SUDDEN_DEATH ] <- "Music_SuddenDeath_MCOR"

	level.musicForTeam[ TEAM_IMC ][ eMusicPieceID.LOBBY_EARLY_CAMPAIGN ] <- "Music_Lobby_IMC"
	level.musicForTeam[ TEAM_MILITIA ][ eMusicPieceID.LOBBY_EARLY_CAMPAIGN ] <- "Music_Lobby_Militia"

	level.musicForTeam[ TEAM_IMC ][ eMusicPieceID.LEVEL_CINEMATIC_1 ] <- "Music_AngelCity_IMC_Opening"
	level.musicForTeam[ TEAM_MILITIA ][ eMusicPieceID.LEVEL_CINEMATIC_1 ] <- "Music_AngelCity_MCOR_Opening"

	level.musicForTeam[ TEAM_IMC ][ eMusicPieceID.LEVEL_CINEMATIC_2 ] <- "Music_AngelCity_IMC_Win"
	level.musicForTeam[ TEAM_MILITIA ][ eMusicPieceID.LEVEL_CINEMATIC_2 ] <- "Music_AngelCity_MCOR_Lose"

	level.musicForTeam[ TEAM_IMC ][ eMusicPieceID.LEVEL_CINEMATIC_3 ] <- "Music_AngelCity_IMC_Opening"
	level.musicForTeam[ TEAM_MILITIA ][ eMusicPieceID.LEVEL_CINEMATIC_3 ] <- "Music_AngelCity_MCOR_Opening"

	level.musicForTeam[ TEAM_IMC ][ eMusicPieceID.LEVEL_CINEMATIC_4 ] <- "Music_AngelCity_IMC_Win"
	level.musicForTeam[ TEAM_MILITIA ][ eMusicPieceID.LEVEL_CINEMATIC_4 ] <- "Music_AngelCity_MCOR_Lose"

	level.musicForTeam[ TEAM_IMC ][ eMusicPieceID.GAMEMODE_1 ] <- "Music_MarkedForDeath_IMC_YouAreMarked"
	level.musicForTeam[ TEAM_MILITIA ][ eMusicPieceID.GAMEMODE_1 ] <- "Music_MarkedForDeath_MCOR_YouAreMarked"
	level.musicForTeam[ TEAM_IMC ][ eMusicPieceID.GAMEMODE_2 ] <- "Music_MarkedForDeath_IMC_YouAreMarked"
	level.musicForTeam[ TEAM_MILITIA ][ eMusicPieceID.GAMEMODE_2 ] <- "Music_MarkedForDeath_MCOR_YouAreMarked"

	//Play a different music piece based on winning/losing final round as opposed to yet another round. No difference between IMC or Milita
	level.musicForTeam[ TEAM_MILITIA ][ eMusicPieceID.ROUND_BASED_GAME_WON ]  <- "Music_SuddenDeath_GameWon"
	level.musicForTeam[ TEAM_IMC ][ eMusicPieceID.ROUND_BASED_GAME_WON ]  <- "Music_SuddenDeath_GameWon"

	level.musicForTeam[ TEAM_MILITIA ][ eMusicPieceID.ROUND_BASED_GAME_LOST ]  <- "Music_SuddenDeath_GameLost"
	level.musicForTeam[ TEAM_IMC ][ eMusicPieceID.ROUND_BASED_GAME_LOST ]  <- "Music_SuddenDeath_GameLost"

	RegisterCinematicMusic() //Register Cinematic Music by default. Probably not ideal but this late in development minimal changes are probably best
	RegisterGameModeMusic()
}

function RegisterCinematicMusic()
{
	local mapName =  GetMapName()

	switch ( mapName )
	{
		case "mp_airbase":
		{
			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_INTRO, "Music_airbase_IMC_Opening", TEAM_IMC )
			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_INTRO, "Music_airbase_MCOR_Opening", TEAM_MILITIA )

			break
		}

		case "mp_angel_city":
		{
			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_INTRO, "Music_AngelCity_IMC_Opening", TEAM_IMC )
			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_INTRO, "Music_AngelCity_MCOR_Opening", TEAM_MILITIA )

			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_WIN, "Music_AngelCity_IMC_Win", TEAM_IMC )
			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_WIN, "Music_AngelCity_MCOR_Win", TEAM_MILITIA )

			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_LOSS, "Music_AngelCity_IMC_Lose", TEAM_IMC )
			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_LOSS, "Music_AngelCity_MCOR_Lose", TEAM_MILITIA )

			break
		}

		case "mp_corporate":
		{

			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_INTRO, "Music_corporate_IMC_Opening", TEAM_IMC )
			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_INTRO, "Music_corporate_Militia_Opening", TEAM_MILITIA )

			break
		}

		case "mp_fracture":
		{
			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_INTRO, "Music_FR_Militia_Opening", TEAM_MILITIA )
			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_INTRO, "Music_FR_IMC_Opening", TEAM_IMC )

			break
		}

		case "mp_o2":
		{
			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_INTRO, "Music_o2_IMC_Opening", TEAM_IMC )
			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_INTRO, "Music_o2_Militia_Opening", TEAM_MILITIA )
			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_CINEMATIC_1, "Music_o2_Sacrifice", TEAM_IMC )
			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_CINEMATIC_1, "Music_o2_Sacrifice", TEAM_MILITIA )
			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_CINEMATIC_2, "Music_o2_LateGameMusic_1", TEAM_IMC )
			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_CINEMATIC_2, "Music_o2_LateGameMusic_1", TEAM_MILITIA )
			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_CINEMATIC_3, "Music_o2_LateGameMusic_2", TEAM_IMC )
			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_CINEMATIC_3, "Music_o2_LateGameMusic_2", TEAM_MILITIA )
			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_CINEMATIC_4, "Music_o2_LateGameMusic_3", TEAM_IMC )
			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_CINEMATIC_4, "Music_o2_LateGameMusic_3", TEAM_MILITIA )
			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_WIN, "Music_o2_Ending", TEAM_MILITIA )
			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_WIN, "Music_o2_Ending", TEAM_IMC )
			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_LOSS, "Music_o2_Ending", TEAM_MILITIA )
			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_LOSS, "Music_o2_Ending", TEAM_IMC )
			break
		}

		case "mp_outpost_207":
		{
			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_INTRO, "Music_Outpost_Intro_IMC", TEAM_IMC )
			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_INTRO, "Music_Outpost_Intro_MCOR", TEAM_MILITIA )
			break
		}
		case "mp_colony":
		{
			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_INTRO, "Music_Colony_IMC_Opening", TEAM_IMC )
			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_INTRO, "Music_Colony_MCOR_Opening", TEAM_MILITIA )

			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_WIN, "Music_Colony_IMC_Win", TEAM_IMC )
			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_WIN, "Music_Colony_MCOR_Win", TEAM_MILITIA )

			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_LOSS, "Music_Colony_IMC_Lose", TEAM_IMC )
			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_LOSS, "Music_Colony_MCOR_Lose", TEAM_MILITIA )
			break
		}
		case "mp_relic":
		{
			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_INTRO, "Music_Relic_Intro_IMC", TEAM_IMC )
			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_INTRO, "Music_Relic_Intro_MCOR", TEAM_MILITIA )
			break
		}
		case "mp_boneyard":
		{
			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_INTRO, "Music_Boneyard_IMC_Opening", TEAM_IMC )
			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_INTRO, "Music_Boneyard_Militia_Opening", TEAM_MILITIA )
			break
		}
	}
}

function RegisterClassicMPMusic()
{
	if ( !GetClassicMPMode() )
		return

	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_INTRO, "Music_ClassicMP_IMC_Opening", TEAM_IMC )
	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_INTRO, "Music_ClassicMP_MCOR_Opening", TEAM_MILITIA )

	FlagWait( "EntitiesDidLoad" ) //Have to do this because the nv that determines if RoundBased or not might not get set yet

	if ( IsRoundBased() )
	{
		thread RandomizeClassicMPRoundBasedWinLoss()
		return
	}
	else
	{
		RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_WIN, "Music_AngelCity_IMC_Win", TEAM_IMC )
		RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_WIN, "Music_AngelCity_MCOR_Win", TEAM_MILITIA )

		RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_LOSS, "Music_AngelCity_IMC_Lose", TEAM_IMC )
		RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_LOSS, "Music_AngelCity_MCOR_Lose", TEAM_MILITIA )

		RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_DRAW, "Music_AngelCity_IMC_Lose", TEAM_IMC )
		RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_DRAW, "Music_AngelCity_MCOR_Lose", TEAM_MILITIA )
	}
}

function RegisterGameModeMusic()
{
	switch ( GAMETYPE )
	{
		case MARKED_FOR_DEATH:
		case MARKED_FOR_DEATH_PRO:
		{
			RegisterLevelMusicForTeam( eMusicPieceID.GAMEMODE_1, "Music_MarkedForDeath_IMC_YouAreMarked", TEAM_IMC )
			RegisterLevelMusicForTeam( eMusicPieceID.GAMEMODE_1, "Music_MarkedForDeath_MCOR_YouAreMarked", TEAM_MILITIA )
			break
		}

		case COOPERATIVE:
		{
			// coop cues (players are only militia in this mode)
			level.musicForTeam[ TEAM_MILITIA ][ eMusicPieceID.COOP_OPENING ] 				<- "Music_Coop_Opening"
			level.musicForTeam[ TEAM_MILITIA ][ eMusicPieceID.COOP_GAMEWON ] 				<- "Music_Coop_GameWon"
			level.musicForTeam[ TEAM_MILITIA ][ eMusicPieceID.COOP_GAMELOST ] 				<- "Music_Coop_GameLost"
			level.musicForTeam[ TEAM_MILITIA ][ eMusicPieceID.COOP_WAVEWON ] 				<- "Music_Coop_WaveWon"
			level.musicForTeam[ TEAM_MILITIA ][ eMusicPieceID.COOP_WAVELOST ] 				<- "Music_Coop_WaveLost"
			level.musicForTeam[ TEAM_MILITIA ][ eMusicPieceID.COOP_WAITINGFORWAVE ] 		<- "Music_Coop_WaitingForWave"
			level.musicForTeam[ TEAM_MILITIA ][ eMusicPieceID.COOP_WAITINGFORFIRSTWAVE ] 	<- "Music_Coop_WaitingForFirstWave"
			level.musicForTeam[ TEAM_MILITIA ][ eMusicPieceID.COOP_WAITINGFORFINALWAVE ] 	<- "Music_Coop_WaitingForFinalWave"
			level.musicForTeam[ TEAM_MILITIA ][ eMusicPieceID.COOP_ACTIONMUSIC_LOW ] 		<- "Music_Coop_ActionMusic_LOW"
			level.musicForTeam[ TEAM_MILITIA ][ eMusicPieceID.COOP_ACTIONMUSIC_MED ] 		<- "Music_Coop_ActionMusic_MED"
			level.musicForTeam[ TEAM_MILITIA ][ eMusicPieceID.COOP_ACTIONMUSIC_HIGH ] 		<- "Music_Coop_ActionMusic_HIGH"
			level.musicForTeam[ TEAM_MILITIA ][ eMusicPieceID.COOP_FINALWAVE_BEGIN ] 		<- "Music_Coop_FinalWave_Begin"
			break
		}

		default:
		{
			break
		}
	}

}

function RandomizeClassicMPRoundBasedWinLoss()
{
	FlagWait( "EntitiesDidLoad" ) //Have to do this because the nv that determines if RoundBased or not might not get set yet

	if ( !IsRoundBased() )//HACK: Making assumption that Round Based modes don't have evac. Intended usage is that on round end, we play these shorter pieces. If there is an evac, play the longer ones.
	{
		//printt( "Not registering shorter win/loss cues because not round based" )
		return

	}

	if ( GetRoundWinningKillEnabled() == true ) //HACK: When Kill replay happens, sounds less than 15seconds in length get cut off in code. These round winning music pieces have 15seconds of silence at the end to get around the problem
	{
		//printt( "Registering RoundWinningKillEnabled win/loss themes" )
		if ( CoinFlip() ) //Randomize Win/Loss themes separately. No need to randomize amongst teams since you'll never be on both teams simultaneously
		{
			//printt( "Pick Round_Won1" )
			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_WIN, "Music_RoundWinningKillReplay_IMC_RoundWon_1", TEAM_IMC )
			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_WIN, "Music_RoundWinningKillReplay_MCOR_RoundWon_1", TEAM_MILITIA )
		}
		else
		{
			//printt( "Pick Round_Won2" )
			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_WIN, "Music_RoundWinningKillReplay_IMC_RoundWon_2", TEAM_IMC )
			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_WIN, "Music_RoundWinningKillReplay_MCOR_RoundWon_2", TEAM_MILITIA )

		}

		if ( CoinFlip() ) //Randomize Win/Loss themes separately. No need to randomize amongst teams since you'll never be on both teams simultaneously
		{
			//printt( "Pick Round_Lost1" )
			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_LOSS, "Music_RoundWinningKillReplay_IMC_RoundLost_1", TEAM_IMC )
			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_LOSS, "Music_RoundWinningKillReplay_MCOR_RoundLost_1", TEAM_MILITIA )

			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_DRAW, "Music_RoundWinningKillReplay_IMC_RoundLost_1", TEAM_IMC )
			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_DRAW, "Music_RoundWinningKillReplay_MCOR_RoundLost_1", TEAM_MILITIA )
		}
		else
		{
			//printt( "Pick Round_Lost2" )
			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_LOSS, "Music_RoundWinningKillReplay_IMC_RoundLost_2", TEAM_IMC )
			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_LOSS, "Music_RoundWinningKillReplay_MCOR_RoundLost_2", TEAM_MILITIA )

			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_DRAW, "Music_RoundWinningKillReplay_IMC_RoundLost_2", TEAM_IMC )
			RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_DRAW, "Music_RoundWinningKillReplay_MCOR_RoundLost_2", TEAM_MILITIA )
		}

		return
	}

	//printt( "Registering shorter win/loss" )
	//Register Short Win/Loss music pieces for round based modes.
	//Can't randomize in the sound alias because we need to know the duration of the music piece later on to ensure it doesn't get interrupted

	if ( CoinFlip() ) //Randomize Win/Loss themes separately. No need to randomize amongst teams since you'll never be on both teams simultaneously
	{
		//printt( "Pick Round_Won1" )
		RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_WIN, "Music_ClassicMP_IMC_RoundWon_1", TEAM_IMC )
		RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_WIN, "Music_ClassicMP_MCOR_RoundWon_1", TEAM_MILITIA )
	}
	else
	{
		//printt( "Pick Round_Won2" )
		RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_WIN, "Music_ClassicMP_IMC_RoundWon_2", TEAM_IMC )
		RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_WIN, "Music_ClassicMP_MCOR_RoundWon_2", TEAM_MILITIA )

	}

	if ( CoinFlip() ) //Randomize Win/Loss themes separately. No need to randomize amongst teams since you'll never be on both teams simultaneously
	{
		//printt( "Pick Round_Lost1" )
		RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_LOSS, "Music_ClassicMP_IMC_RoundLost_1", TEAM_IMC )
		RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_LOSS, "Music_ClassicMP_MCOR_RoundLost_1", TEAM_MILITIA )

		RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_DRAW, "Music_ClassicMP_IMC_RoundLost_1", TEAM_IMC )
		RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_DRAW, "Music_ClassicMP_MCOR_RoundLost_1", TEAM_MILITIA )
	}
	else
	{
		//printt( "Pick Round_Lost2" )
		RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_LOSS, "Music_ClassicMP_IMC_RoundLost_2", TEAM_IMC )
		RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_LOSS, "Music_ClassicMP_MCOR_RoundLost_2", TEAM_MILITIA )

		RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_DRAW, "Music_ClassicMP_IMC_RoundLost_2", TEAM_IMC )
		RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_DRAW, "Music_ClassicMP_MCOR_RoundLost_2", TEAM_MILITIA )
	}
}

function RegisterLevelMusicForTeam( musicPieceID, soundAlias, team )
{
	level.musicForTeam[ team ][ musicPieceID ] = soundAlias
}

function IsForcedMusicOnly( player )
{
	return  level.forcedMusicOnly
}

function GameStateChanged()
{
	if ( !level.musicEnabled ) //So music can be selectively turned off per level
		return

	if ( level.gameStateMusicEnabled == false )
	{
		//printt( "GameStateMusicEnabled Set to false, returning" )
		return
	}

	switch ( GetGameState() )
	{
		//****** Watch out for using gameteam score. Check to see after epilogue if score still increases
		case eGameState.Prematch:
			thread ForcePlayMusicToCompletion( eMusicPieceID.LEVEL_INTRO )
			break

		case eGameState.SuddenDeath:
			thread ForcePlayMusicToCompletion( eMusicPieceID.LEVEL_SUDDEN_DEATH )
			break

		case eGameState.WinnerDetermined:
			local player = GetLocalClientPlayer()
			local playerTeam = player.GetTeam()

			local winningTeam = level.nv.winningTeam

			thread PlayWinnerDeterminedMusic( playerTeam, winningTeam )

			if ( IsRoundBased() )
				thread RandomizeClassicMPRoundBasedWinLoss() // Randomize music for next round}

			break
	}
}

function PlayWinnerDeterminedMusic( playerTeam, winningTeam )
{
	local winningMusic
	local losingMusic
	local drawingMusic

	/*printt( "roundScoreLimitComplete: " + level.nv.roundScoreLimitComplete )
	printt( "HasRoundScoreLimitBeenReached(): " + HasRoundScoreLimitBeenReached() )*/

	if ( IsRoundBased() && HasRoundScoreLimitBeenReached() == true )
	{
		winningMusic = eMusicPieceID.ROUND_BASED_GAME_WON
		losingMusic = eMusicPieceID.ROUND_BASED_GAME_LOST
		drawingMusic = eMusicPieceID.ROUND_BASED_GAME_LOST

	}
	else
	{
		winningMusic = eMusicPieceID.LEVEL_WIN
		losingMusic = eMusicPieceID.LEVEL_LOSS
		drawingMusic = eMusicPieceID.LEVEL_DRAW
	}

	if ( playerTeam ==  winningTeam )
		thread ForcePlayMusicToCompletion( winningMusic )
	else if ( winningTeam == TEAM_UNASSIGNED )
		thread ForcePlayMusicToCompletion( drawingMusic )
	else
		thread ForcePlayMusicToCompletion( losingMusic )
}

function ServerCallback_PlayTeamMusicEvent( musicPieceID, timeMusicStarted, shouldSeek )
{
	if ( shouldSeek == false )
	{
		thread ForcePlayMusicToCompletion( musicPieceID, 0 )
		return
	}

	local seekTime = Time() - timeMusicStarted
	if ( seekTime < 0  ) //Defensive fix. Couldn't find repro.
		seekTime = 0

	//Handle case where we join late after the intro music has finished playing
	if ( shouldSeek == true && IntroMusicHasFinishedPlaying( musicPieceID, timeMusicStarted, seekTime ) )
		delaythread ( 1.0 ) PlayActionMusic() //Delaythread to give rest of game time to init itself correctly when we join late
	else
		thread ForcePlayMusicToCompletion( musicPieceID, seekTime )
}

function IntroMusicHasFinishedPlaying( musicPieceID, timeMusicStarted, seekTime )
{
	//Warning: This will not work correctly for soundAliases for music with multiple wav files
	local soundAlias = GetSoundAliasFromMusicPieceID( musicPieceID )

	if ( !soundAlias )
	{
		//printt( "No valid musicpieceID found, just start action music" )
		return true
	}

	local timeLeftForMusicToPlay = GetSoundDuration( soundAlias ) - seekTime

	if ( timeLeftForMusicToPlay <= 0 )
	{
		//printt( "Intro music should have finished, start action music" )
		return true
	}

	return false

}

function SetForcedMusicOnly( value )
{
	level.forcedMusicOnly = value
}

function PlayMusic( musicPieceID, seek = 0 )
{
	local player = GetLocalClientPlayer()

	if ( IsForcedMusicOnly( player ) )
	{
		//printt( "Forced Music is on, not playing music" )
		return
	}

	return PlayMusic_Internal( musicPieceID, seek )
}

function ForcePlayMusic( musicPieceID, seek = 0 )
{
	level.ent.Signal( "ForceMusicPlayed" )
	level.lastTimeActionMusicPlayed = 0 // Just to get past the PlayActionMusic debounce check
	return PlayMusic_Internal( musicPieceID, seek )
}

function ForcePlayMusicToCompletion( musicPieceID, seek = 0 )
{
	//Warning: This will not work correctly for soundAliases for music with multiple wav files
	local soundAlias = GetSoundAliasFromMusicPieceID( musicPieceID )

	if ( !soundAlias )
		return

	if ( level.currentMusicPlaying == soundAlias ){
		//printt( "current music already playing, returning" )
		return
	}

	local player = GetLocalClientPlayer()

	SetForcedMusicOnly( true )
	local lengthOfMusic = ForcePlayMusic( musicPieceID, seek )

	if ( lengthOfMusic == null )
	{
		//printt ("No length of music, returning from ForcePlayMusicToCompletion" )
		SetForcedMusicOnly( false )
		return
	}

	level.ent.EndSignal( "ForceMusicPlayed" )
	level.ent.EndSignal( "ForceLoopMusic" )
	level.ent.EndSignal( "MusicStopped" )
	level.ent.EndSignal( "StopLoopMusic" )

	wait lengthOfMusic
	SetForcedMusicOnly( false )
}

function PlayMusic_Internal( musicPieceID, seek = 0 )
{
	if ( IsWatchingKillReplay() )
		return null

	if ( !level.musicEnabled ) //No music ever plays when musicEnabled is set to false
		return null

	local player = GetLocalClientPlayer()
	local soundAlias = GetSoundAliasFromMusicPieceID( musicPieceID )

	if ( !soundAlias )
		return null

	if ( level.currentMusicPlaying == soundAlias )
		return null

	//printt( "Trying to play music: " + soundAlias )

	local lengthOfMusic = 0
	lengthOfMusic = EmitSoundOnEntityWithSeek( player, soundAlias, seek )

	if ( !lengthOfMusic  ) //We seeked pass the length of the music. EmitSoundOnEntityWithSeek will not actually do anything, so we shouldn't do anything either
		return null

	if ( level.currentMusicPlaying )
	{
		//printt( "Stopping current sound: " + level.currentMusicPlaying )
		FadeOutSoundOnEntity( player, level.currentMusicPlaying, DEFAULT_FADE_TIME )
	}

	level.currentMusicPlaying = soundAlias

	//printt( "PlayNextActionMusicWhenDone threaded for soundAlias: " + soundAlias)
	thread PlayNextActionMusicWhenDone( lengthOfMusic )
	//printt( "Done with PlayMusic_Internal for soundAlias: " + soundAlias )
	return lengthOfMusic
}

function PlayNextActionMusicWhenDone( lengthOfMusic )
{
	//printt( "Signalling music played" )
	level.ent.Signal( "MusicPlayed" )
	level.ent.EndSignal( "MusicPlayed" )
	level.ent.EndSignal( "MusicStopped" )

	/*printt( "level.debugCount: " + level.debugCount )
	local debugCount = level.debugCount

	OnThreadEnd(
		function() : ( debugCount )
		{
			printt( "Play NextActionMusicWhenDone ended with debugCount:" + debugCount )

		}
	)

	++level.debugCount*/

	wait ( lengthOfMusic + DEFAULT_MUSIC_GAP_TIME )

	//JFS. When a player goes into XBox menus the audio is stopped, but the client script is not. This can result in music pieces overlapping. This fix results in music stopping without finishing, but at least it doesn't overlap
	local player = GetLocalClientPlayer()
	if ( !IsValid( player ) )
		return

	if ( level.currentMusicPlaying )
		FadeOutSoundOnEntity( player, level.currentMusicPlaying, DEFAULT_FADE_TIME )

	//printt( "Setting currentClassMusicType to null" )
	level.currentClassMusicType = null
	level.currentMusicPlaying = null

	thread PlayActionMusic()
}


function LoopLobbyMusic()
{
	local soundAlias = GetSoundAliasFromMusicPieceID( eMusicPieceID.LOBBY_EARLY_CAMPAIGN ) //Hard code to one particular lobby piece for now. Long run this will be determined by how far we are in the campaign

	if ( !soundAlias )
		return

	if ( level.currentMusicPlaying == soundAlias )
	{
		//printt( "Current music " + level.currentMusicPlaying + " already playing in lobby, returning from StartLobbyMusic" )
		return
	}

	level.ent.Signal( "MusicPlayed" )
	level.ent.EndSignal( "MusicPlayed" )
	level.ent.EndSignal( "MusicStopped" )

	while( true )
	{
		wait 2.0 //Hack. Make music restarting in lobbies slightly less bad.

		local player = GetLocalClientPlayer()
		if ( !IsValid( player ) )
			return

		local lengthOfMusic = EmitSoundOnEntity( player, soundAlias )
		//printt( "Playing music : " + soundAlias + " , length of music is: " + lengthOfMusic )
		if ( level.currentMusicPlaying )
		{
			//printt( "Stopping current sound: " + level.currentMusicPlaying )
			FadeOutSoundOnEntity( player, level.currentMusicPlaying, DEFAULT_FADE_TIME )
		}


		level.currentMusicPlaying = soundAlias

		wait ( lengthOfMusic + DEFAULT_MUSIC_GAP_TIME )

		local player = GetLocalClientPlayer()
		if ( !IsValid( player ) )
			return

		FadeOutSoundOnEntity( player, level.currentMusicPlaying, DEFAULT_FADE_TIME ) //JFS. When a player goes into XBox menus the audio is stopped, but the client script is not. This can result in music pieces overlapping. This fix results in music stopping without finishing, but at least it doesn't overlap

		level.currentMusicPlaying = null
	}

}

function ForceLoopMusic( musicPieceID ) //Needs a corresponding call to StopLoopMusic() or StopMusic() to actually stop the music. Other ForcePlayMusic calls will play and force the loop to start over without stopping the loop. Not ideal, but we can live with it.
{
	//Warning: This will not work correctly for soundAliases for music with multiple wav files
	local soundAlias = GetSoundAliasFromMusicPieceID( musicPieceID )

	level.ent.Signal( "ForceLoopMusic" )
	level.ent.EndSignal( "ForceLoopMusic" )
	level.ent.EndSignal( "MusicStopped" )
	level.ent.EndSignal( "StopLoopMusic" )

	OnThreadEnd(
		function() : (  )
		{
			StopLoopMusic()

		}
	)

	while( true )
	{
		//printt( "Pre ForcePlayMusicToCompletion" )
		level.currentLoopingMusic = soundAlias
		waitthread ForcePlayMusicToCompletion( musicPieceID )
		if ( level.currentMusicPlaying != level.currentLoopingMusic ) //Check to see if we got interrupted by other forcemusic calls
			return
		level.currentMusicPlaying = null //Somewhat of a hack to get the same music to loop immediately.
		//printt( "Post ForcePlayMusicToCompletion" )
	}

}

function StopLoopMusic()
{
	if ( level.currentLoopingMusic != level.currentMusicPlaying )
	{
		//printt( "No current looping music!" )
		level.currentLoopingMusic = null
		return
	}

	level.ent.Signal( "StopLoopMusic" )
	StopMusic()
	//PlayActionMusic() //Responsibility of calling script to call PlayActionMusic() if they need it

}

function PlayActionMusic()
{
	if ( !level.musicEnabled ) //So music isn't turned on by default for all levels
	{
		//printt( "Music not enabled, returning" )
		return
	}

	if ( level.classMusicEnabled == false )
	{
		//printt( "Class Music not enabled, returning" )
		return
	}

	if ( IsWatchingKillReplay() )
		return

	local currentGameState = GetGameState()

	//Assuming we don't ever add another game state that we want action music to play in
	if ( currentGameState != eGameState.Playing )
	{
		//printt( "current game state is " + currentGameState + " != playing " )
		return
	}

	if ( !EnoughTimePassedForActionMusic() )
	{
		//printt( "Not enough time passed for action music!" )
		return
	}

	local player = GetLocalClientPlayer()

	if ( IsForcedMusicOnly( player ) )
	{
		//printt( "Forced Music is on, not playing action music" )
		return
	}

	if ( GetClassicMPMode() && GetMusicReducedSetting() )
		return

	local playerClass = player.GetPlayerClass()

	if ( playerClass == level.pilotClass )
		DecidePilotMusicToPlay( player )

	else if ( playerClass == "titan" )
		DecideTitanMusicToPlay( player )

}

function EnoughTimePassedForActionMusic()
{
	if (!level.lastTimeActionMusicPlayed )
		return true
	return ( Time() - level.lastTimeActionMusicPlayed >= ACTION_MUSIC_DEBOUNCE_TIME )

}

function GetSoundAliasFromMusicPieceID( musicPieceID )
{
	local player = GetLocalClientPlayer()
	return level.musicForTeam[ player.GetTeam() ][ musicPieceID ]
}

function StopMusic( fadeOutTime = DEFAULT_FADE_TIME ) //Stops current music. Also stops automatic action music playing until another piece of music is played manually
{
	//No current music playing, return
	if ( !level.currentMusicPlaying )
		return

	local player = GetLocalClientPlayer()

	//printt( "Stopping current music for player: " + player )

	FadeOutSoundOnEntity( player, level.currentMusicPlaying, fadeOutTime )

	level.currentMusicPlaying = null

	level.currentLoopingMusic = null

	level.currentClassMusicType = null

	level.lastTimeActionMusicPlayed = 0 // Reset the PlayActionMusic debounce check

	SetForcedMusicOnly( false )

	level.ent.Signal( "MusicStopped" )
}

//Very similar to DecidePilotMusicToPlay
function DecideTitanMusicToPlay( player )
{
	//printt( "level.currentClassMusicType: " + level.currentClassMusicType )
	if ( level.currentClassMusicType == "titan" )  // Don't try to switch music if we're already playing titan music
		return

	++level.titanMusicAttemptCount

	if ( level.nv.matchProgress <  MATCH_PROGRESS_ACTION_MUSIC_SHIFT_THRESHOLD )
	{
		if ( level.titanMusicAttemptCount % 2  == 0 )
			PlayMusic( eMusicPieceID.TITAN_ACTION_LOW_2 )
		else
			PlayMusic( eMusicPieceID.TITAN_ACTION_LOW_1 )
	}
	else
	{
		if ( level.titanMusicAttemptCount % 2  == 0 )
			PlayMusic( eMusicPieceID.TITAN_ACTION_HIGH_2 )
		else
			PlayMusic( eMusicPieceID.TITAN_ACTION_HIGH_1 )

	}
	//printt( "Setting level.currentClassMusicType to titan" )

	level.currentClassMusicType = "titan"

	level.lastTimeActionMusicPlayed = Time()
}

//Very similar to DecideTitanMusicToPlay
function DecidePilotMusicToPlay( player )
{
	//printt( "level.currentClassMusicType: " + level.currentClassMusicType )
	if ( level.currentClassMusicType == "pilot" ) //Don't try to switch music if we're already playing pilot music
		return

	++level.pilotMusicAttemptCount

	if ( level.nv.matchProgress <  MATCH_PROGRESS_ACTION_MUSIC_SHIFT_THRESHOLD )
	{
		if ( level.pilotMusicAttemptCount % 2  == 0 )
			PlayMusic( eMusicPieceID.PILOT_ACTION_LOW_2 )
		else
			PlayMusic( eMusicPieceID.PILOT_ACTION_LOW_1 )
	}
	else
	{
		if ( level.pilotMusicAttemptCount % 2  == 0 )
			PlayMusic( eMusicPieceID.PILOT_ACTION_HIGH_2 )
		else
			PlayMusic( eMusicPieceID.PILOT_ACTION_HIGH_1 )

	}

	//printt( "Setting level.currentClassMusicType to pilot" )

	level.currentClassMusicType = "pilot"

	level.lastTimeActionMusicPlayed = Time()
}

function SetClassMusicEnabled( value )
{
	level.classMusicEnabled = value
}

function GetClassMusicEnabled()
{
	return level.classMusicEnabled
}

function SetGameStateMusicEnabled( value )
{
	level.gameStateMusicEnabled = value
}

function GetGameStateMusicEnabled()
{
	return level.gameStateMusicEnabled
}
