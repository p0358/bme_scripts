
const STATS_DEBUG = false

const ENABLE_STATS_MOVEMENT = true
const ENABLE_STATS_FRAMERATE = true

const STATS_MOVEMENT_ACCURACY_SQRD = 256
const STATS_MOVEMENT_INTERVAL = 0.25

function main()
{
	Globalize( ReportDevStat_Death )
	Globalize( ReportDevStat_Spawn )
	Globalize( ReportDevStat_RoundEnd )
	Globalize( ReportDevStat_FrameRate )
	Globalize( ReportDevStat_TimeTillEngagement )
	Globalize( ReportDevStat_BurnCardEarned )
}

function ShouldReportStats()
{
	if ( IsSingleplayer() )
		return false

	if ( STATS_DEBUG )
		return true

	return ShouldSendDevStats()
}

function ReportDevStat( args )
{
	if ( !ShouldReportStats() )
		return

	Assert( args.len() >= 1 )
	Assert( typeof( args[0] ) == "integer" )
	local stat = args[0]

	local statName = null
	foreach( key, val in getconsttable().eDevStats )
	{
		if ( val != stat )
			continue
		statName = key
		break
	}
	Assert( statName != null )

	local statPrintLine = "#stat"
	if ( STATS_DEBUG )
		statPrintLine = "#debugstat"

	statPrintLine += DEVSTATS_SEPARATOR + "ver=" + DEVSTATS_VERSION
	statPrintLine += DEVSTATS_SEPARATOR + "map=" + GetMapName()
	statPrintLine += DEVSTATS_SEPARATOR + "mode=" + GameRules.GetGameMode()
	statPrintLine += DEVSTATS_SEPARATOR + "stat=" + statName
	if ( IsServer() )
	{
		local playingTime = level.nv.gameEndTime != null ? GameTime.PlayingTime().tofloat() : Time().tofloat()
		statPrintLine += DEVSTATS_SEPARATOR + "gameTime=" + playingTime
		statPrintLine += DEVSTATS_SEPARATOR + "matchID=" + lstrip(rstrip(GameRules.GetUniqueMatchID()))
	}
	for ( local i = 1 ; i < args.len() - 1 ; i += 2 )
		statPrintLine += DEVSTATS_SEPARATOR + args[i] + "=" + args[i+1]

	if ( STATS_DEBUG )
		printt( statPrintLine )
	else
		printl_spamLog( statPrintLine )
}

function ReportDevStat_Death( victim, damageInfo )
{
	if ( !ShouldReportStats() || IsClient() )
		return

	PerfStart( PerfIndexServer.ReportDevStat_Death )

	//-------------
	// Victim Info
	//-------------
	local victimName = null
	local victimIsTitan = null
	local victimIsNPC = null
	local victimTeam = null
	if ( IsValid( victim ) )
	{
		victimIsTitan = victim.IsTitan() ? "1" : "0"
		victimTeam = victim.GetTeam()
		if ( victim.IsPlayer() )
		{
			victimName = victim.GetPlayerName()
			victimIsNPC = "0"
		}
		else
			victimIsNPC = "1"
	}

	//---------------
	// Attacker Info
	//---------------
	local attacker = damageInfo.GetAttacker()
	local attackerName = null
	local attackerIsTitan = null
	local attackerIsNPC = null
	local attackerTeam = null
	local killDist = -1
	if ( IsValid( attacker ) )
	{
		attackerIsTitan = attacker.IsTitan() ? "1" : "0"
		attackerTeam = attacker.GetTeam()
		if ( attacker.IsPlayer() )
		{
			attackerName = attacker.GetPlayerName()
			attackerIsNPC = "0"
		}
		else
			attackerIsNPC = "1"
	}

	//-------------
	// Weapon Info
	//-------------
	local weaponName = damageInfo.GetWeapon()
	if ( weaponName != null )
		weaponName = weaponName.GetClassname()
	if ( weaponName == null )
		weaponName = GetNameFromDamageSourceID( damageInfo.GetDamageSourceIdentifier() )
	if ( IsValid( attacker ) && IsValid( victim ) )
		killDist = floor( damageInfo.GetDistFromAttackOrigin() )
	local isHeadShot = IsValidHeadShot( damageInfo, victim )

	//-------------
	// Common args
	//-------------
	local commonArgs = []

	local victimPos = victim.GetOrigin()
	commonArgs.append( "posx" )
	commonArgs.append( floor(victimPos.x + 0.5) )
	commonArgs.append( "posy" )
	commonArgs.append( floor(victimPos.y + 0.5) )

	if ( victimName != null )
	{
		commonArgs.append( "victim" )
		commonArgs.append( victimName )
	}

	if ( victimIsTitan != null )
	{
		commonArgs.append( "victimIsTitan" )
		commonArgs.append( victimIsTitan )
	}

	if ( victimTeam != null )
	{
		commonArgs.append( "victimTeam" )
		commonArgs.append( victimTeam )
	}

	if ( victimIsNPC != null )
	{
		commonArgs.append( "victimIsNPC" )
		commonArgs.append( victimIsNPC )
	}

	if ( attackerName != null )
	{
		commonArgs.append( "attacker" )
		commonArgs.append( attackerName )
	}

	if ( attackerIsTitan != null )
	{
		commonArgs.append( "attackerIsTitan" )
		commonArgs.append( attackerIsTitan )
	}

	if ( attackerTeam != null )
	{
		commonArgs.append( "attackerTeam" )
		commonArgs.append( attackerTeam )
	}

	if ( attackerIsNPC != null )
	{
		commonArgs.append( "attackerIsNPC" )
		commonArgs.append( attackerIsNPC )
	}

	if ( IsValid( attacker ) )
	{
		local attackerPos = attacker.GetOrigin()

		commonArgs.append( "attackposx" )
		commonArgs.append( floor(attackerPos.x + 0.5) )

		commonArgs.append( "attackposy" )
		commonArgs.append( floor(attackerPos.y + 0.5) )
	}

	if ( weaponName != null )
	{
		commonArgs.append( "weapon" )
		commonArgs.append( weaponName )
	}

	if ( killDist >= 0 )
	{
		commonArgs.append( "range" )
		commonArgs.append( killDist )
	}

	if ( isHeadShot )
	{
		commonArgs.append( "headshot" )
		commonArgs.append( "1" )
	}

	if ( "secondsAsPilot" in victim.s )
	{
		commonArgs.append( "timeAsPilot" )
		commonArgs.append( victim.s.secondsAsPilot )
	}

	if ( "secondsAsTitan" in victim.s )
	{
		commonArgs.append( "timeAsTitan" )
		commonArgs.append( victim.s.secondsAsTitan )
	}

	if ( "secondsAsPilotWithTitanAvailable" in victim.s )
	{
		commonArgs.append( "timeAsPilotWithTitanAvailable" )
		commonArgs.append( victim.s.secondsAsPilotWithTitanAvailable )
	}

	if ( "secondsAsPilotWithPetTitan" in victim.s )
	{
		commonArgs.append( "timeAsPilotWithPetTitan" )
		commonArgs.append( victim.s.secondsAsPilotWithPetTitan )
	}

	// Time Till Death ( Time it took to go from full health to death )
	if ( "lastFullHealthTime" in victim.s )
	{
		local timeTillDeath = Time() - victim.s.lastFullHealthTime
		commonArgs.append( "timeTillDeath" )
		commonArgs.append( timeTillDeath )
	}

	// Damage History ( 3 top means of death )
	local history = GetDamageTakenSinceFullHealth( victim )
	//PrintTable( history )

	commonArgs.append( "attackersTillDeath" )
	commonArgs.append( history.numAttackers )

	local count = min( history.table.len(), 3 )
	for( local i = 0 ; i < count ; i++ )
	{
		commonArgs.append( "DamageHistoryWeapon" + ( i + 1 ) )
		commonArgs.append( history.table[i].source )

		commonArgs.append( "DamageHistoryAmount" + ( i + 1 ) )
		commonArgs.append( history.table[i].amount )
	}

	//--------------
	// Report Death
	//--------------
	local deathArgs = []
	deathArgs.append( eDevStats.DEATH )
	foreach( arg in commonArgs )
		deathArgs.append( arg )

	ReportDevStat( deathArgs )

	PerfEnd( PerfIndexServer.ReportDevStat_Death )
}

function ReportDevStat_Spawn( player )
{
	if ( !ShouldReportStats() || IsClient() )
		return

	if ( !IsValid_ThisFrame( player ) || !player.IsPlayer() )
		return

	local loadoutItems = []
	local gotPilot = false
	local gotTitan = false
	for( local i = 0 ; i < 2 ; i++ )
	{
		if ( !IsValid_ThisFrame( player ) || !player.IsPlayer() )
			break;

		if ( player.IsTitan() && gotTitan )
			continue
		if ( !player.IsTitan() && gotPilot )
			continue

		// Pilot / Titan loadout items
		local weapons = player.GetMainWeapons()

		if ( weapons.len() > 0 )
			loadoutItems.append( weapons[0].GetClassname() )

		if ( weapons.len() > 1 )
			loadoutItems.append( weapons[1].GetClassname() )

		local offhand0 = player.GetOffhandWeapon(0)
		if ( offhand0 != null )
			loadoutItems.append( offhand0.GetClassname() )

		local offhand1 = player.GetOffhandWeapon(1)
		if ( offhand1 != null )
			loadoutItems.append( offhand1.GetClassname() )

		if ( player.IsTitan() )
			gotTitan = true
		else
			gotPilot = true

		wait 0
	}

	if ( !IsValid_ThisFrame( player ) )
		return

	// Used to keep track of time till engagement
	//----------------------------------------------
	if ( !( "spawnTime" in player.s ) )
		player.s.spawnTime <- null
	player.s.spawnTime = Time()
	if ( !( "reportedEngagementTime" in player.s ) )
		player.s.reportedEngagementTime <- null
	player.s.reportedEngagementTime = false
	//----------------------------------------------

	thread ReportDevStat_TrackTimeAsClass( player )

	if ( ENABLE_STATS_MOVEMENT )
		thread ReportDevStat_MovementPosition( player )

	local playerName = player.GetPlayerName()
	local playerIsTitan = player.IsTitan() ? "1" : "0"
	local playerTeam = player.GetTeam()

	local args = []
	args.append( eDevStats.SPAWN )
	local playerPos = player.GetOrigin()
	args.append( "posx" )
	args.append( floor(playerPos.x + 0.5) )
	args.append( "posy" )
	args.append( floor(playerPos.y + 0.5) )
	args.append( "player" )
	args.append( playerName )
	args.append( "playerIsTitan" )
	args.append( playerIsTitan )
	args.append( "victimTeam" )
	args.append( playerTeam )

	foreach( item in loadoutItems )
	{
		args.append( "loadout" )
		args.append( item )
	}

	ReportDevStat( args )
}

function ReportDevStat_TrackTimeAsClass( player )
{
	player.EndSignal( "OnDeath" )

	if ( !( "secondsAsPilot" in player.s ) )
		player.s.secondsAsPilot <- null
	if ( !( "secondsAsTitan" in player.s ) )
		player.s.secondsAsTitan <- null
	if ( !( "secondsAsPilotWithTitanAvailable" in player.s ) )
		player.s.secondsAsPilotWithTitanAvailable <- null
	if ( !( "secondsAsPilotWithPetTitan" in player.s ) )
		player.s.secondsAsPilotWithPetTitan <- null

	player.s.secondsAsPilot = 0
	player.s.secondsAsTitan = 0
	player.s.secondsAsPilotWithTitanAvailable = 0
	player.s.secondsAsPilotWithPetTitan = 0

	while( IsValid( player ) && IsAlive( player ) )
	{
		if ( player.IsTitan() )
		{
			player.s.secondsAsTitan++
		}
		else
		{
			player.s.secondsAsPilot++

			if ( IsReplacementTitanAvailable( player ) )
				player.s.secondsAsPilotWithTitanAvailable++

			if ( player.GetPetTitan() != null )
				player.s.secondsAsPilotWithPetTitan++
		}

		wait 1
	}
}

function ReportDevStat_MovementPosition( player )
{
	player.EndSignal( "OnDeath" )

	local currentPos = player.GetOrigin()
	local lastPos = currentPos

	while( IsValid( player ) && IsAlive( player ) )
	{
		wait STATS_MOVEMENT_INTERVAL

		if ( !IsValid( player ) && !IsAlive( player ) )
			return

		currentPos = player.GetOrigin()
		if ( DistanceSqr( currentPos, lastPos ) < STATS_MOVEMENT_ACCURACY_SQRD )
			continue

		local args = []
		args.append( eDevStats.MOVE )
		args.append( "posx" )
		args.append( floor(currentPos.x + 0.5) )
		args.append( "posy" )
		args.append( floor(currentPos.y + 0.5) )
		args.append( "victim" )
		args.append( player.GetPlayerName() )
		args.append( "victimIsTitan" )
		args.append( player.IsTitan() ? "1" : "0" )
		args.append( "playerIsWallrunning" )
		args.append( player.IsWallHanging() || player.IsWallRunning() ? "1" : "0" )
		args.append( "victimTeam" )
		args.append( player.GetTeam() )

		ReportDevStat( args )

		lastPos = currentPos
	}
}

function ReportDevStat_TimeTillEngagement( player1, player2, damageInfo )
{
	ReportDevStat_TimeTillEngagement_Internal( player1, player2, damageInfo )
	ReportDevStat_TimeTillEngagement_Internal( player2, player1, damageInfo )
}

function ReportDevStat_TimeTillEngagement_Internal( player1, player2, damageInfo )
{
	if ( !ShouldReportStats() )
		return

	if ( !IsValid( player1 ) || !IsValid( player2 ) )
		return

	if ( !IsPlayer( player1 ) )
		return

	// Stats may have been turned on mid-match and people who were alive when it was turned on wont have these yet
	if ( !( "spawnTime" in player1.s ) )
		return
	if ( !( "reportedEngagementTime" in player1.s ) )
		return

	Assert( player1.s.spawnTime != null )

	// Only report the first engagement after spawning
	if ( "reportedEngagementTime" in player1.s && player1.s.reportedEngagementTime == true )
		return
	player1.s.reportedEngagementTime = true

	// Amount of time passed since spawning. This is the engagement time
	local timePassedSinceSpawn = Time() - player1.s.spawnTime

	// Build the array of arguments to report
	local commonArgs = []

	local victimPos = player1.GetOrigin()
	commonArgs.append( "posx" )
	commonArgs.append( floor(victimPos.x + 0.5) )
	commonArgs.append( "posy" )
	commonArgs.append( floor(victimPos.y + 0.5) )

	if ( player1.IsPlayer() )
	{
		commonArgs.append( "victim" )
		commonArgs.append( player1.GetPlayerName() )
	}

	commonArgs.append( "victimIsTitan" )
	commonArgs.append( player1.IsTitan() ? "1" : "0" )

	commonArgs.append( "victimTeam" )
	commonArgs.append( player1.GetTeam() )

	commonArgs.append( "victimIsNPC" )
	commonArgs.append( player1.IsPlayer() ? "0" : "1" )

	if ( player2.IsPlayer() )
	{
		commonArgs.append( "attacker" )
		commonArgs.append( player2.GetPlayerName() )
	}

	commonArgs.append( "attackerIsTitan" )
	commonArgs.append( player2.IsTitan() ? "1" : "0" )

	commonArgs.append( "attackerTeam" )
	commonArgs.append( player2.GetTeam() )

	commonArgs.append( "attackerIsNPC" )
	commonArgs.append( player2.IsPlayer() ? "0" : "1" )

	local attackerPos = player2.GetOrigin()
	commonArgs.append( "attackposx" )
	commonArgs.append( floor(attackerPos.x + 0.5) )
	commonArgs.append( "attackposy" )
	commonArgs.append( floor(attackerPos.y + 0.5) )

	local weaponName = damageInfo.GetWeapon()
	if ( weaponName != null )
		weaponName = weaponName.GetClassname()
	if ( weaponName == null )
		weaponName = GetNameFromDamageSourceID( damageInfo.GetDamageSourceIdentifier() )
	local attackDist = floor( Distance( player1.GetOrigin(), player2.GetOrigin() ) )

	if ( weaponName != null )
	{
		commonArgs.append( "weapon" )
		commonArgs.append( weaponName )
	}

	if ( attackDist >= 0 )
	{
		commonArgs.append( "range" )
		commonArgs.append( attackDist )
	}

	// Time Till Death ( Time it took to go from full health to death )
	commonArgs.append( "timePassedSinceSpawn" )
	commonArgs.append( timePassedSinceSpawn )

	//-------------------
	// Report Engagement
	//-------------------
	local allArgs = []
	allArgs.append( eDevStats.ENGAGEMENT )
	foreach( arg in commonArgs )
		allArgs.append( arg )

	ReportDevStat( allArgs )
}

function ReportDevStat_RoundEnd( winningTeam )
{
	if ( !ShouldReportStats() || IsClient() )
		return

	local players = GetPlayerArray()
	foreach ( player in players )
	{
		local team = player.GetTeam()
		if ( team != TEAM_IMC && team != TEAM_MILITIA )
			continue

		local args = []
		args.append( eDevStats.ROUND_END )
		args.append( "player" )
		args.append( player.GetPlayerName() )

		args.append( "team" )
		args.append( team )

		local won = team == winningTeam ? "1" : "0"
		args.append( "winner" )
		args.append( won )

		local newXP = player.GetPersistentVar( "xp" ) - player.GetPersistentVar( "previousXP" )
		args.append( "xp" )
		args.append( newXP )

		ReportDevStat( args )
	}


	// New match end stuff. Eventually replaces above which will become purely player win/loss tracking

	local args2 = []

	args2.append( eDevStats.MATCH_END )
	args2.append( "winning_team" )
	args2.append( winningTeam )
	args2.append( "score_imc" )
	args2.append( GameRules.GetTeamScore( TEAM_IMC ) )
	args2.append( "score_militia" )
	args2.append( GameRules.GetTeamScore( TEAM_MILITIA ) )
	args2.append( "time_limit" )
	args2.append( ( GetTimeLimit_ForGameMode() * 60.0 ).tointeger() )
	args2.append( "score_limit" )
	args2.append( GetScoreLimit_FromPlaylist() )
	args2.append( "players_in_game" )
	args2.append( GetPlayerArray().len() )
	ReportDevStat( args2 )
}

function ReportDevStat_FrameRate( player )
{
	if ( !ShouldReportStats() )
		return

	Assert( IsClient() )

	if ( !ENABLE_STATS_FRAMERATE )
		return

	while( IsValid( player ) )
	{
		if ( IsAlive( player ) )
		{
			local fps = GetClientFPS()
			local currentPos = player.GetOrigin()

			local args = []
			args.append( eDevStats.FPS )
			args.append( "posx" )
			args.append( floor(currentPos.x + 0.5) )
			args.append( "posy" )
			args.append( floor(currentPos.y + 0.5) )
			args.append( "victimIsTitan" )
			args.append( player.IsTitan() ? "1" : "0" )
			args.append( "fps" )
			args.append( fps )

			ReportDevStat( args )
		}

		wait 2
	}
}

function ReportDevStat_BurnCardEarned( player, earnMsg, rarity )
{
	if ( !ShouldReportStats() || IsClient() )
		return

	if ( !IsValid_ThisFrame( player ) || !player.IsPlayer() )
		return

	local earnType
	switch ( earnMsg )
	{
		case "EarnedBurnCard_Challenge":
			earnType = 1
			break

		case "EarnedBurnCard_Victory":
			earnType = 2
			break

		case "EarnedBurnCard_Evac":
			earnType = 3
			break

		case "EarnedBurnCard_Titan":
			earnType = 4
			break

		case "EarnedBurnCard_Pack":
			earnType = 5
			break

		case "EarnedBurnCard_Pilot":
			earnType = 6
			break

		case "EarnedBurnCard_Marvin":
			earnType = 7
			break

		case "EarnedBurnCard_Spectre":
			earnType = 8
			break

		case "EarnedBurnCard_Grunt":
			earnType = 9
			break

		case "EarnedBurnCard":
			earnType = 10
			break

		default:
			earnType = 0
	}

	if ( rarity == BURNCARD_RARE )
		earnType += 100

	local playerName = player.GetPlayerName()
	local playerIsTitan = player.IsTitan() ? "1" : "0"
	local playerTeam = player.GetTeam()

	local args = []
	args.append( eDevStats.BURN_CARD_EARNED )
	args.append( "player" )
	args.append( playerName )

	args.append( "burnCardEarnType" )
	args.append( earnType )

	ReportDevStat( args )
}