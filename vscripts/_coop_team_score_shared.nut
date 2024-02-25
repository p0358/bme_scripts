//These effect Coop_GetMaxTeamScore(), but must be manually entered into COOP_STAR_SCORE_REQUIREMENT[ } on a per map basis.
const STAR_RATIO_FIRST						= 0.31
const STAR_RATIO_SECOND						= 0.62
const STAR_RATIO_THIRD						= 0.93

//If modifying SCORE_NOTIFICATIONS_MAX_NUM, update in vgui_fullscreen_titan.res and vgui_fullscreen_pilot.res
const SCORE_NOTIFICATIONS_MAX_NUM				= 2
const SCORE_NOTIFICATIONS_DURATION				= 3.5
const SCORE_NOTIFICATIONS_FADE_TIME				= 0.5
const SCORE_NOTIFICATIONS_TIME_INBETWEEN_EVENTS = 1

//PERSONAL SCORE VALUES
fireteamPointValues <- {}
fireteamPointValues[ "titan" ] 					<- COOP_ENEMY_POINT_VALUE_TITAN
fireteamPointValues[ "nukeTitan" ]				<- COOP_ENEMY_POINT_VALUE_NUKE_TITAN
fireteamPointValues[ "mortarTitan" ]			<- COOP_ENEMY_POINT_VALUE_MORTAR_TITAN
fireteamPointValues[ "empTitan" ] 				<- COOP_ENEMY_POINT_VALUE_EMP_TITAN
fireteamPointValues[ "suicideSpectre" ]			<- COOP_ENEMY_POINT_VALUE_SUICIDE_SPECTRE
fireteamPointValues[ "sniperSpectre" ]			<- COOP_ENEMY_POINT_VALUE_SNIPER_SPECTRE
fireteamPointValues[ "spectre" ] 				<- COOP_ENEMY_POINT_VALUE_SPECTRE
fireteamPointValues[ "bubbleShieldSpectre" ]	<- COOP_ENEMY_POINT_VALUE_BUBBLE_SHIELD_SPECTRE
fireteamPointValues[ "bubbleShieldGrunt" ] 		<- COOP_ENEMY_POINT_VALUE_BUBBLE_SHIELD_GRUNT
fireteamPointValues[ "cloakedDrone" ]			<- COOP_ENEMY_POINT_VALUE_CLOAKED_DRONE
fireteamPointValues[ "grunt" ] 					<- COOP_ENEMY_POINT_VALUE_GRUNT

function main()
{
	file.coopTeamScoreEvents <- {}
	level.coopScoreEventsPointsEarned <- {}
	level.coopEOGScoreEventMaxValues <- {}

	CreateCoopTeamScoreEvent( eCoopTeamScoreEvents.wave_complete, 			"#COOP_TEAM_SCORE_EVENT_WAVE_COMPLETE",			COOP_WAVE_COMPLETED_BONUS )
	CreateCoopTeamScoreEvent( eCoopTeamScoreEvents.final_wave_complete, 	"#COOP_TEAM_SCORE_EVENT_FINAL_WAVE_COMPLETE", 	COOP_FINAL_WAVE_COMPLETED_BONUS )
	CreateCoopTeamScoreEvent( eCoopTeamScoreEvents.harvester_health, 		"#COOP_TEAM_SCORE_EVENT_HARVESTER_HEALTH", 		COOP_MAX_HARVESTER_HEALTH_BONUS )
	CreateCoopTeamScoreEvent( eCoopTeamScoreEvents.first_try, 				"#COOP_TEAM_SCORE_EVENT_FIRST_TRY", 			COOP_FIRST_TRY_BONUS )
	CreateCoopTeamScoreEvent( eCoopTeamScoreEvents.difficulty_bonus,		"#COOP_TEAM_SCORE_EVENT_DIFFICULTY_BONUS", 		COOP_DIFFICULTY_BONUS )
	CreateCoopTeamScoreEvent( eCoopTeamScoreEvents.star_reward,				"#COOP_TEAM_SCORE_EVENT_STAR_REWARD", 			0,									 "../ui/menu/lobby/map_star_small" )
	CreateCoopTeamScoreEvent( eCoopTeamScoreEvents.star_reward,				"#COOP_TEAM_SCORE_EVENT_STAR_REWARD", 			0,									 "../ui/menu/lobby/map_star_small" )
	CreateCoopTeamScoreEvent( eCoopTeamScoreEvents.retry_bonus,				"#COOP_TEAM_SCORE_EVENT_RETRY_BONUS", 			COOP_RETRY_BONUS )
	CreateCoopTeamScoreEvent( eCoopTeamScoreEvents.retries_bonus,			"#COOP_TEAM_SCORE_EVENT_RETRIES_BONUS", 		COOP_RETRIES_BONUS )
	CreateCoopTeamScoreEvent( eCoopTeamScoreEvents.enemies_killed,			"#COOP_TEAM_SCORE_EVENT_ENEMIES_KILLED", 		0 )
	CreateCoopTeamScoreEvent( eCoopTeamScoreEvents.flawless_wave,			"#COOP_TEAM_SCORE_EVENT_FLAWLESS_WAVE", 		COOP_FLAWLESS_WAVE_BONUS )

	if ( IsServer() )
	{
		AddCallback_PlayerOrNPCKilled( Coop_OnPlayerOrNPCKilled )
		AddCallback_OnTitanDoomed( Coop_OnTitanDoomed )
		AddCallback_NPCLeeched( Coop_OnNPCLeeched )
	}
	else
	{
		AddCreatePilotCockpitCallback( Coop_InitTeamScoreNotifications )
		AddCreateTitanCockpitCallback( Coop_InitTeamScoreNotifications )

		teamScoreNotificationGroups					<- {}
		teamScoreNotificationGroups[0]				<- null
		teamScoreNotificationGroups[1]				<- null
		teamScoreNotificationElems					<- {}
		teamScoreDisplayEndTime						<- {}
		for( local i = 0; i < SCORE_NOTIFICATIONS_MAX_NUM; i++ )
			teamScoreDisplayEndTime[i]				<- 0
		teamScoreNotificationBasePositions			<- {}
		teamScoreNotificationBasePositions[0]		<- null
		teamScoreNotificationBasePositions[1]		<- null
		nextNotificationIndex						<- 0
		teamScoreNotificationQueue					<- []
		teamScoreLastStartTime						<- 0
		teamScoreLastQueueTime						<- 0
		storedNotifications							<- []
	}
}

function CreateCoopTeamScoreEvent( scoreEvent, displayName, pointValue, icon = null )
{
	local table = {}
	table.displayName	 <- displayName
	table.pointValue	 <- pointValue
	table.icon			 <- icon

	file.coopTeamScoreEvents[ scoreEvent ] <- table
	level.coopScoreEventsPointsEarned[ scoreEvent ] <- 0

	if( IsClient() && icon != null )
		PrecacheHUDMaterial( icon )
}

if ( IsServer() )
{
	function PlayTeamScoreEvent( scoreEvent )
	{
		local table = file.coopTeamScoreEvents[ scoreEvent ]
		local pointsToAdd = table.pointValue
		if ( scoreEvent == eCoopTeamScoreEvents.harvester_health )
		{
			pointsToAdd = pointsToAdd * Generator_GetHealthRatio()
			pointsToAdd = pointsToAdd.tointeger()
		}

		if ( scoreEvent == eCoopTeamScoreEvents.enemies_killed )
		{
			pointsToAdd += level.nv.TDStoredTeamScore
			level.nv.TDStoredTeamScore = 0
		}
		else
		{
			level.nv.TDCurrentTeamScore += pointsToAdd
		}
		level.coopScoreEventsPointsEarned[ scoreEvent ] += pointsToAdd
		local playerArray = GetPlayerArray()
		foreach ( player in playerArray )
			Remote.CallFunction_NonReplay( player, "ServerCallback_DisplayCoopNotification", scoreEvent, pointsToAdd )
	}
	Globalize( PlayTeamScoreEvent )

	function Coop_OnPlayerOrNPCKilled( victim, attacker, damageInfo )
	{
		if ( !IsValid( attacker ) || !attacker.IsPlayer() )
			return

		local attackerTeam = attacker.GetTeam()
		local victimTeam = victim.GetTeam()

		if ( victim.GetTeam() == attackerTeam )
			return

		if ( GetGameState() != eGameState.Playing )
			return

		if ( victim.IsTitan() && !victim.IsPlayer() )
			return

		if ( victim.IsMarvin() )
			return

		if ( victim.IsDropship() )
			return

		local damageSourceId = damageInfo.GetDamageSourceIdentifier()
		if ( damageSourceId == eDamageSourceId.stuck )
			return	// score is assigned where the npc is killed by script

	 	local scoreVal = GetCoopScoreValue( victim )
		level.nv.TDStoredTeamScore += scoreVal
		level.nv.TDCurrentTeamScore += scoreVal

		attacker.SetAssaultScore( attacker.GetAssaultScore() + scoreVal )
		local inflictor = damageInfo.GetInflictor()
		local inflictorIsTurret = false
		if ( IsValid( inflictor ) && inflictor.IsTurret() )
			inflictorIsTurret = true

		UpdatePlayerKillHistory( attacker, victim, inflictorIsTurret )
	}
	Globalize( Coop_OnPlayerOrNPCKilled )

	function Coop_OnTitanDoomed( victim, damageInfo )
	{
		if ( !GamePlaying() )
			return

		local attacker = GetAttackerOrLastAttacker( victim, damageInfo )
		if ( !IsValid( attacker ) )
			return

		local attackerIsTurret = attacker.IsTurret()

		attacker = GetAttackerPlayerOrBossPlayer( attacker )

		if ( !IsValid( attacker ) )
			return

		if ( attacker.GetTeam() == victim.GetTeam() )
			return

		local damageSourceId = damageInfo.GetDamageSourceIdentifier()
		if ( damageSourceId == eDamageSourceId.stuck )
			return	// score is assigned where the npc is killed by script

	 	local scoreVal = GetCoopScoreValue( victim )
		level.nv.TDStoredTeamScore += scoreVal
		level.nv.TDCurrentTeamScore += scoreVal

		attacker.SetAssaultScore( attacker.GetAssaultScore() + scoreVal )
		UpdatePlayerKillHistory( attacker, victim, attackerIsTurret )
	}
	Globalize( Coop_OnTitanDoomed )

	function GetCoopScoreValue( npc )
	{
		local npcClass = npc.GetClassname()
		local npcSubclass = null
		if ( npcClass != "prop_dynamic" )
			npcSubclass = npc.GetSubclass()

		local aiTypeID = Coop_GetAITypeID_ByClassAndSubclass( npcClass, npcSubclass )

		local aiTypeString = GetCoopAITypeString_ByID( aiTypeID )

		//Hack fix for infrequent phone home error. Should assert and get more debug info.
		if ( aiTypeString == null )
			return 0
		else
			return fireteamPointValues[ aiTypeString ]
	}
	Globalize( GetCoopScoreValue )

	function Coop_GetTeamScore()
	{
		local scoreFromKills = 0
		local waveTotal = 0
		foreach ( waveInfo in level.TowerDefenseWaves )
		{
			foreach ( key, value in fireteamPointValues )
			{
				scoreFromKills += value * max( 0, GetAICountFromWave( waveInfo, key ) )
			}
			waveTotal++
		}
		local waveBonuses = ( waveTotal - 1 ) * COOP_WAVE_COMPLETED_BONUS
		local finalWaveBonus = COOP_FINAL_WAVE_COMPLETED_BONUS
		local flawlessWaveBonuses = waveTotal * COOP_FLAWLESS_WAVE_BONUS
		local maxHarvesterHealthBonus = COOP_MAX_HARVESTER_HEALTH_BONUS
		local maxAllowedRestarts = Coop_GetMaxAllowedRestarts()
		Assert( maxAllowedRestarts != null )  // # of restarts set at start of wave spawning (for Rise etc)
		local retriesBonus = COOP_RETRIES_BONUS
		if ( maxAllowedRestarts == 1 )
			retriesBonus = COOP_RETRY_BONUS
		else if ( maxAllowedRestarts == 0 )
			retriesBonus = 0
		local total = scoreFromKills + waveBonuses + finalWaveBonus + flawlessWaveBonuses + maxHarvesterHealthBonus + retriesBonus

		level.coopEOGScoreEventMaxValues[ eCoopTeamScoreEvents.enemies_killed ] 		<- scoreFromKills
		level.coopEOGScoreEventMaxValues[ eCoopTeamScoreEvents.wave_complete ]			<- waveBonuses
		level.coopEOGScoreEventMaxValues[ eCoopTeamScoreEvents.final_wave_complete ]	<- finalWaveBonus
		level.coopEOGScoreEventMaxValues[ eCoopTeamScoreEvents.flawless_wave ] 			<- flawlessWaveBonuses
		level.coopEOGScoreEventMaxValues[ eCoopTeamScoreEvents.harvester_health ] 		<- maxHarvesterHealthBonus
		level.coopEOGScoreEventMaxValues[ eCoopTeamScoreEvents.retry_bonus ] 			<- retriesBonus

		printt( "=======================" )
		printt( "TOTAL SCORE = ", total )
		printt( "STAR 1: ", total * STAR_RATIO_FIRST - ( total * STAR_RATIO_FIRST ) % 5 )
		printt( "STAR 2 : ", total * STAR_RATIO_SECOND - ( total * STAR_RATIO_SECOND ) % 5 )
		local thirdStarValue = total * STAR_RATIO_THIRD - ( total * STAR_RATIO_THIRD ) % 5
		printt( "STAR 3 : ", thirdStarValue )
		return thirdStarValue
	}
	Globalize( Coop_GetTeamScore )

	function Coop_ResetTeamScores()
	{
		level.nv.TDStoredTeamScore = 0
		level.nv.TDCurrentTeamScore = level.teamScoreWaveStart
		local playerArray = GetPlayerArray()
		foreach ( player in playerArray )
			player.SetAssaultScore( level.playerTeamScoreWaveStart[ player.GetEntIndex() ] )
	}
	Globalize( Coop_ResetTeamScores )


	function TestScoreEvents()
	{
			PlayTeamScoreEvent( eCoopTeamScoreEvents.final_wave_complete )
			PlayTeamScoreEvent( eCoopTeamScoreEvents.wave_complete )
			PlayTeamScoreEvent( eCoopTeamScoreEvents.first_try )
			PlayTeamScoreEvent(	eCoopTeamScoreEvents.harvester_health )
			PlayTeamScoreEvent( eCoopTeamScoreEvents.difficulty_bonus )
			//PlayTeamScoreEvent( eCoopTeamScoreEvents.star_reward )
	}
	Globalize( TestScoreEvents )

	function Coop_OnNPCLeeched( npc, player )
	{
		if ( !npc.IsSpectre() )
			return

		local scoreVal = COOP_ENEMY_POINT_VALUE_SPECTRE
		level.nv.TDStoredTeamScore += scoreVal
		level.nv.TDCurrentTeamScore += scoreVal
		player.SetAssaultScore( player.GetAssaultScore() + scoreVal )
		UpdatePlayerKillHistory( player, npc )
	}
	Globalize( Coop_OnNPCLeeched )
}
else //client
{
	function ServerCallback_DisplayCoopNotification( scoreEvent, modifiedPointValue = 0 )
	{
		local player = GetLocalClientPlayer()
		local cockpit = player.GetCockpit()
		local vgui = null
		if ( IsValid( cockpit ) )
			vgui = cockpit.GetMainVGUI()

		if( IsValid( vgui ) )
		{
			if ( teamScoreDisplayEndTime[ 0 ] < Time() && teamScoreDisplayEndTime[ 1 ] < Time() )
			{
				DisplayNotification( player, scoreEvent, 0, modifiedPointValue, vgui )
			}
			else
			{
				thread DisplayNotification_Delayed( player, scoreEvent, modifiedPointValue, vgui )
			}
		}
		else
		{
			StoreNotificationInformation( player, scoreEvent, modifiedPointValue )
		}
	}
	Globalize( ServerCallback_DisplayCoopNotification )

	function DisplayNotification_Delayed( player, scoreEvent, modifiedPointValue, vgui )
	{
		vgui.EndSignal( "OnDestroy" )
		player.EndSignal( "OnDestroy" )

		StoreNotificationInformation( player, scoreEvent, modifiedPointValue )

		teamScoreNotificationQueue.append( scoreEvent )
		local currentTime = Time()
		local timeSinceLastEventDisplayed = currentTime - teamScoreLastStartTime
		local delay
		local queueLength = teamScoreNotificationQueue.len()
		if ( queueLength > 1 )
		{
			delay = ( queueLength / SCORE_NOTIFICATIONS_MAX_NUM ) * SCORE_NOTIFICATIONS_DURATION + 0.1
			local timeBetweenQueuedEvents = currentTime + delay - teamScoreLastQueueTime
			delay = delay + max( SCORE_NOTIFICATIONS_TIME_INBETWEEN_EVENTS - timeBetweenQueuedEvents, 0 )


			teamScoreLastQueueTime = currentTime + delay
		}
		else
		{
			delay = max( SCORE_NOTIFICATIONS_TIME_INBETWEEN_EVENTS - timeSinceLastEventDisplayed, 0 )
		}
		wait delay

		if ( teamScoreNotificationQueue.len() <= 0 )
			return

		if ( !IsValid( player ) )
			return

		local scoreEvent = teamScoreNotificationQueue[ 0 ]
		teamScoreNotificationQueue.remove( 0 )

		local basePosIndex
		if ( teamScoreDisplayEndTime[ 0 ] < Time() && teamScoreDisplayEndTime[ 1 ] < Time() )
			basePosIndex = 0
		else
			basePosIndex = 1

		DisplayNotification( player, scoreEvent, basePosIndex, modifiedPointValue, vgui )
		RemoveOldestStoredNotification()
	}

    function RemoveOldestStoredNotification()
    {
	    storedNotifications.remove( 0 )
    }

	function DisplayNotification( player, scoreEvent, basePosIndex, modifiedPointValue, vgui )
	{
		//Move Functions
		local baseX = teamScoreNotificationBasePositions[basePosIndex][0]
		local baseY = teamScoreNotificationBasePositions[basePosIndex][1]
		local moveTime = 0.15
		local xOffset = 400 * GetContentScaleFactor()[0]
		teamScoreNotificationElems[ "Coop_TeamScoreEventNotification_Panel_" + nextNotificationIndex ].SetPos( xOffset, baseY )
		teamScoreNotificationElems[ "Coop_TeamScoreEventNotification_Panel_" + nextNotificationIndex ].MoveOverTime( baseX, baseY, moveTime )
		teamScoreNotificationElems[ "Coop_TeamScoreEventNotification_BG_" + nextNotificationIndex ].Show()
		teamScoreNotificationElems[ "Coop_TeamScoreEventNotification_FG_" + nextNotificationIndex ].Show()

		teamScoreNotificationGroups[ nextNotificationIndex ].SetAlpha( 255 )

		teamScoreNotificationElems[ "Coop_TeamScoreEventNotification_EventName_" + nextNotificationIndex ].SetText( file.coopTeamScoreEvents[ scoreEvent ].displayName )
		teamScoreNotificationElems[ "Coop_TeamScoreEventNotification_EventName_" + nextNotificationIndex ].Show()
		//The intent is to use the icon to display when stars are acheived in replacement of a point value.
		local icon = file.coopTeamScoreEvents[ scoreEvent ].icon
		if ( icon == null )
		{
			teamScoreNotificationElems[ "Coop_TeamScoreEventNotification_EventValue_" + nextNotificationIndex ].SetText( "+ " + modifiedPointValue )
			teamScoreNotificationElems[ "Coop_TeamScoreEventNotification_EventValue_" + nextNotificationIndex ].Show()
			teamScoreNotificationElems[ "Coop_TeamScoreEventNotification_Icon_" + nextNotificationIndex ].Hide()

			teamScoreNotificationElems[ "Coop_TeamScoreEventNotification_EventName_" + nextNotificationIndex ].SetColor( 230, 230, 230, 255 )
			teamScoreNotificationElems[ "Coop_TeamScoreEventNotification_EventValue_" + nextNotificationIndex ].SetColor( 230, 230, 230, 255 )
		}
		else
		{
			teamScoreNotificationElems[ "Coop_TeamScoreEventNotification_Icon_" + nextNotificationIndex ].SetImage( icon )
			teamScoreNotificationElems[ "Coop_TeamScoreEventNotification_Icon_" + nextNotificationIndex ].Show()
			teamScoreNotificationElems[ "Coop_TeamScoreEventNotification_EventValue_" + nextNotificationIndex ].Hide()

			teamScoreNotificationElems[ "Coop_TeamScoreEventNotification_EventName_" + nextNotificationIndex ].SetColor( 255, 200, 50, 255 )
		//	teamScoreNotificationElems[ "Coop_TeamScoreEventNotification_Icon_" + nextNotificationIndex ].SetColor( 255, 200, 50, 255 )
		}

		teamScoreDisplayEndTime[ nextNotificationIndex ] = Time() + SCORE_NOTIFICATIONS_DURATION
		teamScoreLastStartTime = Time()
		teamScoreNotificationGroups[ nextNotificationIndex ].FadeOverTimeDelayed( 0, SCORE_NOTIFICATIONS_FADE_TIME, SCORE_NOTIFICATIONS_DURATION - SCORE_NOTIFICATIONS_FADE_TIME )
		thread DoFlareDelayed( teamScoreNotificationElems[ "Coop_TeamScoreEventNotification_Flare_" + nextNotificationIndex ], moveTime, vgui )
		nextNotificationIndex = GetNextIndex( nextNotificationIndex )

		if ( scoreEvent == eCoopTeamScoreEvents.star_reward )
		{
			EmitSoundOnEntity( player, COOP_STAR_NOTIFICATION_SOUND_FIRST )
			thread FlashTeamScoreProgressBar( vgui )
		}
		else
		{
			EmitSoundOnEntity( player, "UI_InGame_CoOp_PointSlider" )
		}
		thread MoveOtherNotificationDown( player, nextNotificationIndex, vgui )
	}

	function FlashTeamScoreProgressBar( vgui )
	{
		vgui.EndSignal( "OnDestroy" )

		vgui.s.scoreboardProgressBars.ScoreBarCoop.SetPulsate( 0.4, 0.95, 10.0 )
		vgui.s.scoreboardProgressBars.StoredScoreBarCoop.SetPulsate( 0.4, 0.95, 10.0 )
		vgui.s.scoreboardProgressBars.ScoreBarText.SetColor( 255, 200, 50, 255 )
		vgui.s.scoreboardProgressBars.ScoreCountCoop.SetColor( 255, 200, 50, 255 )
		wait 3.5

		vgui.s.scoreboardProgressBars.StoredScoreBarCoop.ClearPulsate()
		vgui.s.scoreboardProgressBars.ScoreBarCoop.ClearPulsate()
		//vgui.s.scoreboardProgressBars.ScoreBarCoop.ReturnToBaseColor()

		vgui.s.scoreboardProgressBars.ScoreBarText.ReturnToBaseColor()
		vgui.s.scoreboardProgressBars.ScoreCountCoop.ReturnToBaseColor()
	}

	function MoveOtherNotificationDown( player, nextNotificationIndex, vgui )
	{
		player.EndSignal( "OnDestroy" )
		vgui.EndSignal( "OnDestroy" )

		wait SCORE_NOTIFICATIONS_DURATION - 0.1

		if( teamScoreDisplayEndTime[ nextNotificationIndex ] > Time() - SCORE_NOTIFICATIONS_DURATION )
		{
			local baseX = teamScoreNotificationBasePositions[0][0]
			local baseY = teamScoreNotificationBasePositions[0][1]
			teamScoreNotificationElems[ "Coop_TeamScoreEventNotification_Panel_" + nextNotificationIndex ].MoveOverTime( baseX, baseY, 0.1 )
		}
	}

	function Coop_InitTeamScoreNotifications( cockpit, player )
	{
		local vgui = cockpit.GetMainVGUI()
		local panel = vgui.GetPanel()

		for ( local i = 0; i < SCORE_NOTIFICATIONS_MAX_NUM; i++ )
		{
			local hudElement = HudElement( "Coop_TeamScoreEventNotification_" + i, panel )
			teamScoreNotificationBasePositions[ i ] = hudElement.GetBasePos()
			teamScoreNotificationGroups[ i ] = HudElementGroup( "notificationGroup_" + i )

			teamScoreNotificationElems[ "Coop_TeamScoreEventNotification_Panel_" + i ]		<- hudElement

			local child = hudElement.GetChild( "Coop_TeamScoreEventNotification_BG" )
			teamScoreNotificationElems[ "Coop_TeamScoreEventNotification_BG_" + i ] 		<- child
			teamScoreNotificationGroups[ i ].AddElement( child )

			local child = hudElement.GetChild( "Coop_TeamScoreEventNotification_FG" )
			teamScoreNotificationElems[ "Coop_TeamScoreEventNotification_FG_" + i ] 		<- child
			teamScoreNotificationGroups[ i ].AddElement( child )

			local child = hudElement.GetChild( "Coop_TeamScoreEventNotification_EventName" )
			teamScoreNotificationElems[ "Coop_TeamScoreEventNotification_EventName_" + i ] 	<- child
			teamScoreNotificationGroups[ i ].AddElement( child )

			local child = hudElement.GetChild( "Coop_TeamScoreEventNotification_EventValue" )
			teamScoreNotificationElems[ "Coop_TeamScoreEventNotification_EventValue_" + i ] <- child
			teamScoreNotificationGroups[ i ].AddElement( child )

			local child = hudElement.GetChild( "Coop_TeamScoreEventNotification_Icon" )
			teamScoreNotificationElems[ "Coop_TeamScoreEventNotification_Icon_" + i ] 		<- child
			teamScoreNotificationGroups[ i ].AddElement( child )

			local child = hudElement.GetChild( "Coop_TeamScoreEventNotification_Flare" )
			teamScoreNotificationElems[ "Coop_TeamScoreEventNotification_Flare_" + i ] 		<- child
			teamScoreNotificationGroups[ i ].AddElement( child )

			teamScoreDisplayEndTime[i]				= 0
		}
		nextNotificationIndex						= 0
		teamScoreNotificationQueue					= []
		teamScoreLastStartTime						= 0
		teamScoreLastQueueTime						= 0

		local numStored = storedNotifications.len()
		while( numStored > 0 )
		{
			ServerCallback_DisplayCoopNotification( storedNotifications[0].scoreEvent, storedNotifications[0].modifiedPointValue )
			storedNotifications.remove( 0 )
			numStored--
		}
	}

	function GetNextIndex( index )
	{
		return ( nextNotificationIndex + 1 ) % SCORE_NOTIFICATIONS_MAX_NUM
	}

	function DoFlareDelayed( flare, time, vgui )
	{
		vgui.EndSignal( "OnDestroy" )

		flare.SetAlpha( 0 )

		wait time
		flare.Show()

		flare.FadeOverTime( 200, 0.2 )
		wait 0.25

		// normal size and brightness
		flare.FadeOverTime( 0, 0.2 )
	}

	function StoreNotificationInformation( player, scoreEvent, modifiedPointValue )
	{
		notificationInformation <- {}
		notificationInformation.scoreEvent <- scoreEvent
		notificationInformation.modifiedPointValue <- modifiedPointValue
		storedNotifications.append( notificationInformation )
	}
}
