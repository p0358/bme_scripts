function main()
{
    // We cannot listen for gameState change, as WinnerDetermined state is used for both final winner and round winner
    // Instead we will call out callback in ServerCallback_AnnounceWinner (separate from ServerCallback_AnnounceRoundWinner)
    //RegisterServerVarChangeCallback( "gameState", GameStateChanged )
    Globalize( BME_ScoreboardSave )
}

function BME_ScoreboardSave()
{
    if ( GetConVarInt( "bme_cl_save_scoreboards" ) == 0 )
        return

    wait 0.1

    local localPlayer = GetLocalClientPlayer()
	local myTeam = localPlayer.GetTeam()
	local enemyTeam = GetEnemyTeam( myTeam )

    local out = {}

    out.playlist <- GetCurrentPlaylistName()
    out.gamemode <- GameRules.GetGameMode()
    out.map <- GetMapName()

    out.winningTeam <- level.nv.winningTeam
    out.draw <- !level.nv.winningTeam

    out.scoreIMC <- GameRules.GetTeamScore( TEAM_IMC )
    out.scoreMILITIA <- GameRules.GetTeamScore( TEAM_MILITIA )
    out.scoreWinners <- GameRules.GetTeamScore( level.nv.winningTeam )
    out.scoreLosers <- GameRules.GetTeamScore( GetEnemyTeam( level.nv.winningTeam ) )

    out.maxTeamPlayers <- level.maxTeamSize
    out.numPlayersIMC <- GetTeamPlayerCount( TEAM_IMC )
    out.numPlayersMILITIA <- GetTeamPlayerCount( TEAM_MILITIA )

    out.privateMatch <- IsPrivateMatch()
    out.ranked <- PlayerPlayingRanked( localPlayer )
    out.hadMatchLossProtection <- level.hasMatchLossProtection

    out.players <- []

    local teamPlayers = {}
	teamPlayers[myTeam] <- []
	teamPlayers[enemyTeam] <- []

    local compareFunc = GetScoreboardCompareFunc( localPlayer )
    teamPlayers[myTeam] = GetSortedPlayers( compareFunc, myTeam )
	teamPlayers[enemyTeam] = GetSortedPlayers( compareFunc, enemyTeam )

    foreach ( team, players in teamPlayers )
    {
        foreach ( p in players )
        {
            local player = {}
            player.team <- p.GetTeam()
            player.name <- p.GetPlayerName()
            player.xuid <- GetPlayerPlatformUserId( p )
            player.level <- p.GetLevel()
            player.gen <- p.GetGen()
            player.score_assault <- p.GetAssaultScore()
            player.score_defense <- p.GetDefenseScore()
            player.score_kills <- p.GetKills()
            player.score_deaths <- p.GetDeaths()
            player.score_titanKills <- p.GetTitanKills()
            player.score_npcKills <- p.GetNPCKills()
            player.score_assists <- p.GetAssists()
            player.playingRanked <- p.IsPlayingRanked()
            player.rank <- p.GetRank() // 0?
            //player.matchPerformance <- ?
            out.players.append( player )
        }
    }

    local filename = "-" + out.playlist + "-" + out.gamemode + "-" + out.map + "-" + out.numPlayersIMC + "v" + out.numPlayersMILITIA
    SaveScoreboard( filename, out )
}
