const FADE_TIME 						= 5.0
const DEFAULT_PERF_GOAL					= 0.0
const FX_RANK_START  					= "P_RNK"
const PROGRESS_BAR_ALPHA 				= 60
const ANNOUNCE_DELAY_DEFAULT 			= 7.5
const ANNOUNCE_DELAY_ROUND_BASED_MOD 	= 0
const POOR_PERCENTAGE 					= 0.50 		// -50% below last score
const EXCELLENT_PERCENTAGE 				= 1.25 		// +25% above last score
const TEAM_ICON_SECRET_SOCIETY = "../ui/scoreboard_secret_logo"

// script Remote.CallFunction_NonReplay( gp()[0], "SCB_SetUserPerformance",

PrecacheHUDMaterial( "HUD/flare_announcement_green" )

enum ePerformanceLevel
{
	NONE,
	POOR,
	AVERAGE,
	EXCELLENT
}

function main()
{
	Globalize( SCB_SetUserPerformance )
	Globalize( RankedScoreSplash )
	Globalize( EventRewardsRankedPoints )
	Globalize( InitRankedPanel )
	Globalize( Ranked_WinnerDetermined )
	Globalize( RankedPlayAnnounce )
	Globalize( ServerCallback_ToggleRankedInGame )
	Globalize( GetRankAnnounceDelay )
	Globalize( GetRankEventData )
	Globalize( TryRankedHudHighlight )
	Globalize( RankAnnounced )

	file.hudRPDelta 			<- 0
	level.oldPerformance		<- 0

	level.performanceGoals 		<- []
	level.performanceGoals.append( DEFAULT_PERF_GOAL )
	level.lastRankScoreSplash  <- 0

	file.rankAnnounced						<- false
	file.rankAnnounceQueueTime				<- -900

	file.devAnnouncements					<- false

	PrecacheParticleSystem( FX_RANK_START )

	RegisterSignal( "NewScorePopup" )
	RegisterSignal( "GoalAnnouncement" )
	RegisterSignal( "RankAnnounce" )

	level.titanDamageEffectsRanked <- eRankedContributionType.DAMAGED_TITAN in GetContributionContTypes()
}


function InitRankedPanel( elemGroup, hudGroup, rankedPanel, cockpit = null )
{
	// if there is no icon, fill it null so other stuff doesn't try to access it
	elemGroup.name <- hudGroup.groupName
	rankedPanel.Show()

	InitRankedPanelElems( elemGroup, rankedPanel, hudGroup )

	local bar = elemGroup.RankedGoal_NoNumbersProgressBar
	bar.SetAlpha( PROGRESS_BAR_ALPHA )
	bar.SetBarProgress( 0 )
	bar.Show()

	if ( !file.rankAnnounced )
	{
		HideElemsUnannounced( elemGroup )
	}
	else
	{
		SetupGameInfoIcon( elemGroup )

		elemGroup.RankedLogo.Show()
		elemGroup.RankedLogo.SetImage( TEAM_ICON_SECRET_SOCIETY )

		thread UpdateProgressBarsOverTime( elemGroup, cockpit )
	}
}

function HideElemsUnannounced( elemGroup )
{
	elemGroup.RankedGoal_NoNumbersProgressBar.Hide()
	elemGroup.RankedLogo.Hide()
}

function DevGoalBark()
{
	printt("Setting devAnnouncements to:", !file.devAnnouncements )
	file.devAnnouncements = !file.devAnnouncements
}
Globalize( DevGoalBark )

function GetHudRPDelta()
{
	return file.hudRPDelta
}

function RankedAnnounced( announcement, vgui )
{
	thread RankedAnnouncedThread( announcement )
}

function RankedAnnouncedThread( announcement )
{
	file.rankAnnounced = true
	RankedOverrideSplashColors()

	InitPerformanceGoals()

	wait announcement.GetDuration() - 0.6
	thread ThreadOnAllRankedPanels( FlickerRankedHUDIn )

	RankChipAnnounceIntro()
}

function resetperfgoals()
{
	// for dev
	InitPerformanceGoals()
}
Globalize( resetperfgoals )

function InitPerformanceGoals()
{
	level.performanceGoals = GetPlayerPerformanceGoals( GetLocalClientPlayer() )
}

// Happens on match start
function FlickerRankedHUDIn( elemGroup, cockpit = null )
{
	if ( cockpit )
		cockpit.EndSignal( "OnDestroy" )

	HideElemsUnannounced( elemGroup )

	local state 					= false
	local flickerCountToSwitchIcon 	= 10
	local flickers 					= 25 // always an odd number

	FadeBGToBlack( elemGroup )

	local flickerElem = elemGroup.GameInfo_Icon

	for ( local i = 0; i < flickers; i++ )
	{
		if ( !state )
		{
			if ( i == flickerCountToSwitchIcon )
			{
				if ( flickerElem )
					flickerElem.Hide()

				flickerElem = elemGroup.RankedLogo
				flickerElem.SetImage( TEAM_ICON_SECRET_SOCIETY )
			}

			if ( flickerElem )
				flickerElem.Show()

			state = true
		}
		else
		{
			if ( flickerElem )
				flickerElem.Hide()
			state = false
		}

		local flickerWait = RandomFloat( 0, 0.15 )

		if ( flickerElem )
			flickerElem.FadeOverTime( 0, flickerWait )

		wait flickerWait

		if ( flickerElem )
			flickerElem.SetAlpha( SECRET_SOCIETY_ICON_ALPHA )
	}

	flickerElem.SetAlpha( SECRET_SOCIETY_ICON_ALPHA )

	local fadeInTime = 0.25
	local fadeOutTime = 0.5

	wait fadeOutTime

	local bar = elemGroup.RankedGoal_NoNumbersProgressBar
	bar.Show()
	bar.SetAlpha( 0 )
	bar.FadeOverTime( PROGRESS_BAR_ALPHA, 0.5 )

	wait 2.5
	thread UpdateProgressBarsOverTime( elemGroup, cockpit )
	SetupGameInfoIcon( elemGroup )

	elemGroup.inElem = elemGroup.GameInfo_Icon
	elemGroup.outElem = elemGroup.RankedLogo
	BlendInCurrentLogo( elemGroup )

}

function SetupGameInfoIcon( elemGroup )
{
	local icon = GetTeamIcon( GetLocalClientPlayer().GetTeam() )
	local elem = elemGroup.GameInfo_Icon
	if ( elem )
		elem.SetScale( 0.7, 0.7 )
	elem.SetImage( icon )
	elem.Show()
	elem.ReturnToBaseColor()
	elem.SetAlpha( 0 )
}

function GetTeamIcon( team )
{
	switch ( team )
	{
		case TEAM_IMC:
			return TEAM_ICON_IMC
		case TEAM_MILITIA:
			return TEAM_ICON_MILITIA
		default:
			Assert( 0 )
	}
}

function GetFirstPerformanceGoal()
{
	return level.performanceGoals[0]
}

function SCB_SetUserPerformance( performance )
{
	// Only play this once per match.  Round base modes call this again at halftime.
	if ( !file.rankAnnounced )
	{
		if ( Time() > file.rankAnnounceQueueTime + 8 )
		{
			thread RankedPlayAnnounce( 4.0 )
		}
	}

	level.oldPerformance = level.currentPerformance
	level.currentPerformance = performance
	Signal( level, "NewPerformanceUpdate" )
}

function devperf( perf )
{
	level.currentPerformance = perf
	Signal( level, "NewPerformanceUpdate" )
}
Globalize( devperf )

function ThreadOnAllRankedPanels( updateFunc )
{
	local player = GetLocalClientPlayer()

	if ( !IsValid( player ) )
		return

	// on main hud
	thread updateFunc( player.cv.clientHud.s.mainVGUI.s.scoreboardProgressBars )

	local cockpit = player.GetCockpit()
	if ( !IsValid( cockpit ) )
		return

	local mainVGUI = cockpit.GetMainVGUI()
	if ( !mainVGUI )
		return

	local elemGroup = mainVGUI.s.scoreboardProgressBars
	if ( !( "name" in elemGroup ) )
		return

	// on cockpit
	thread updateFunc( elemGroup, cockpit )
}

function RankedScoreSplash()
{
	if ( !file.rankAnnounced )
		return
	thread ThreadOnAllRankedPanels( HighlightRankedHUD )

	local eventData = GetRankEventData()
	if ( eventData.finalGoalsReached < eventData.goalCount )
		thread RankChipNotification_Increase( 1.0 )
}

function HighlightRankedHUD( elemGroup, cockpit = null )
{
	if ( cockpit != null )
	{
		Assert( IsValid( cockpit ) )
		cockpit.EndSignal( "OnDestroy" )
	}

	Signal( elemGroup, "NewScorePopup" )
	EndSignal( elemGroup, "NewScorePopup" )

	level.lastRankScoreSplash = Time()
	local pulseRate = 15
	elemGroup.RankedBG.SetPulsate( 0.5, 1.0, pulseRate )
	elemGroup.RankedBG.SetColor( RANKED_SPLASH_COLORS_MAIN )

	//elemGroup.RankedLogo.SetAlpha( 255 )
	elemGroup.RankedGoal_NoNumbersProgressBar.SetAlpha( 145 )
	elemGroup.RankedGoal_NoNumbersProgressBar.SetPulsate( 0.5, 1.0, pulseRate )

	elemGroup.inElem = elemGroup.RankedLogo
	elemGroup.outElem = elemGroup.GameInfo_Icon
	BlendInCurrentLogo( elemGroup )

	elemGroup.RankedBG.SetAlpha( 130 )

	wait RANKED_RECALC_TIMESLICE + 1.0

	FadeBGToBlack( elemGroup )

	//elemGroup.RankedLogo.FadeOverTime( 						SECRET_SOCIETY_ICON_ALPHA, 	1.0, INTERPOLATOR_ACCEL )
	elemGroup.RankedGoal_NoNumbersProgressBar.FadeOverTime( PROGRESS_BAR_ALPHA, 		1.0, INTERPOLATOR_ACCEL )

	elemGroup.outElem = elemGroup.RankedLogo
	elemGroup.inElem = elemGroup.GameInfo_Icon

	BlendInCurrentLogo( elemGroup )

	wait 1.0
	elemGroup.RankedBG.ClearPulsate()
	elemGroup.RankedGoal_NoNumbersProgressBar.ClearPulsate()

}

function SCB_ClientDebug( eHandle, skill, contribution, matchSkill )
{
	local player = GetEntityFromEncodedEHandle( eHandle )
	printt( "Player: " + player.GetPlayerName() )
	printt( "Contribution " + format( "%.2f", contribution ) )
	printt( "Skill from history: " + format( "%.2f", skill ) )
	printt( "Skill from this match: " + format( "%.2f", matchSkill ) )
	printt( " " )
}
Globalize( SCB_ClientDebug )

function EventRewardsRankedPoints( event )
{
	switch ( event.GetType() )
	{
		case scoreEventType.ASSAULT:
		case scoreEventType.DEFENSE:
			return true

		case scoreEventType.GAMEMODE:
			return event.GetName() in GetContributionScoreNames()
	}

	return event.GetXPType() in GetContributionXpTypes()
}

function RankAnnounced()
{
	return file.rankAnnounced
}

function Ranked_WinnerDetermined()
{
	if ( !RankAnnounced() )
		return

	thread RankChipMatchOver()
}

function GetRankEventData()
{
	local data = {}

	data.goalCount				<- level.performanceGoals.len()
	data.finalGoalsReached		<- 0
	data.oldPerformance			<- level.oldPerformance
	data.currentPerformance 	<- level.currentPerformance

	foreach ( goal in level.performanceGoals )
	{
		if ( level.currentPerformance >= goal )
			data.finalGoalsReached++
	}

	return data
}


function GetRankAnnounceDelay( roundBased = false )
{
	local delay = ANNOUNCE_DELAY_DEFAULT

	if ( IsRoundBased() )
		delay += ANNOUNCE_DELAY_ROUND_BASED_MOD

	// TODO Add more modifiers here like floor is lava, etc.
	return delay
}

function RankedPlayAnnounce( announcementDuration )
{
	Signal( file, "RankAnnounce" )
	EndSignal( file, "RankAnnounce" )

	Assert( IsNewThread(), "Must be threaded off" )

	file.rankAnnounceQueueTime = Time()

	local player
	for ( ;; )
	{
		player = GetLocalClientPlayer()
		if ( !IsWatchingKillReplay() && IsAlive( player ) )
			break
		wait 0
	}

	local delay = GetRankAnnounceDelay()
	if ( delay > 0 )
		wait delay

	local announcement = CAnnouncement( "#RANKED_ANNOUNCE_INTRO" )
	announcement.SetSubText( GetContributionHint() )
	announcement.SetDuration( announcementDuration )
	announcement.SetCockpitFX( FX_RANK_START )
	announcement.SetMoveDestFadeOut( -0.54, -0.84, 0.6, INTERPOLATOR_SIMPLESPLINE )
	announcement.SetTitleColor( [ 220, 255, 195 ] )
	announcement.SetIcon( GAMETYPE_ICON[ RANKED_PLAY ] )
	announcement.SetSoundAlias( "UI_InGame_League_PromotionalTourMatch" )
	announcement.SetOptionalFunc( { scope = this, func = RankedAnnounced } )
	announcement.SetScanImage( "HUD/flare_announcement_green" )

 	AnnouncementFromClass( player, announcement )
}

function devrankbark()
{
	thread RankedPlayAnnounce( 4 )
}
Globalize( devrankbark )


function DevSetSkills( old, new )
{
	level.currentPerformance = new
}
Globalize( DevSetSkills )


function ServerCallback_ToggleRankedInGame( enabled )
{
	local player = GetLocalClientPlayer()
	if ( !IsValid( player ) )
		return

	if ( enabled )
	{
		// Setup a scoreboard/non-cockpit HUD component
		local scoreGroup = HudElementGroup( "scoreboardProgress" )
		local rankedHud = HudElement( "RankedHud", player.cv.clientHud )
		InitRankedPanel( player.cv.clientHud.s.mainVGUI.s.scoreboardProgressBars, scoreGroup, rankedHud )
		UpdateClientHudVisibility( player )

		// Setup a cockpit HUD component
		local cockpit = player.GetCockpit()
		if ( !IsValid( cockpit ) )
			return

		local mainVGUI = cockpit.GetMainVGUI()
		if ( !mainVGUI )
			return

		local scoreGroup = HudElementGroup( "scoreboardProgress" )
		local panel = mainVGUI.s.panel
		local rankedPanel = scoreGroup.CreateElement( "RankedHud", panel )
		InitRankedPanel( mainVGUI.s.scoreboardProgressBars, scoreGroup, rankedPanel )
	}
}

function TryRankedHudHighlight( player, victimIsTitan )
{
	if ( IsWatchingKillReplay() )
		return

	if ( !PlayerPlayingRanked( player ) )
		return

	if ( victimIsTitan && level.titanDamageEffectsRanked )
	{
		RankedScoreSplash()
		return
	}
}
