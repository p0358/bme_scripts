const TEAM_ICON_HAMMOND = "../vgui/HUD/hammond_icon"
PrecacheHUDMaterial( TEAM_ICON_HAMMOND )

function main()
{
	Globalize( CinematicIntroScreen_Init )
	Globalize( CinematicIntroScreen_SetText )
	Globalize( CinematicIntroScreen_SetTextFadeTimes )
	Globalize( CinematicIntroScreen_SetTextSpacingTimes )
	Globalize( CinematicIntroScreen_SetBlackscreenFadeTimes )
	Globalize( CinematicIntroScreen_SetTeamLogoFadeTimes )
	Globalize( CinematicIntroScreen_SetQuickIntro )
	Globalize( CinematicIntroScreen_SetClassicMPIntro )
	Globalize( CinematicIntroScreen_SetUseLoadingIcon )
	Globalize( CinematicIntroScreen )
	Globalize( BlackScreenFadeOut )

	RegisterSignal( "StartingIntroscreen" )
	RegisterSignal( "StopBlackscreenFade" )
}

function CinematicIntroScreen_Init()
{
	level.introScreen <- {}
	level.introScreen[ TEAM_IMC ] <- {}
	level.introScreen[ TEAM_MILITIA ] <- {}
	level.introScreen_doLoadingIcon <- true

	foreach( team, table in level.introScreen )
	{
		level.introScreen[ team ].textDisplayDuration <- 3.5
		level.introScreen[ team ].textFadeInTime <- 1.5
		level.introScreen[ team ].textFadeOutTime <- 1.5
		level.introScreen[ team ].textFadeInSpacingTime <- [ 0.0, 1.0, 0.0, 0.0, 0.0 ]
		level.introScreen[ team ].teamLogoFadeInDelay <- 0.5
		level.introScreen[ team ].teamLogoFadeInTime <- 2.0
		level.introScreen[ team ].teamLogoDisplayDuration <- 2.0
		level.introScreen[ team ].teamLogoFadeOutTime <- 2.0
		level.introScreen[ team ].blackscreenDisplayDuration <- 8.0
		level.introScreen[ team ].blackscreenFadeOutTime <- 2.0
		level.introScreen[ team ].text <- []
	}
}

function CinematicIntroScreen_SetText( team, textArray )
{
	level.introScreen[ team ].text = textArray
}

function CinematicIntroScreen_SetTextFadeTimes( team, fadein = null, displaytime = null, fadeout = null )
{
	if ( fadein != null )
		level.introScreen[ team ].textFadeInTime = fadein
	if ( displaytime != null )
		level.introScreen[ team ].textDisplayDuration = displaytime
	if ( fadeout != null )
		level.introScreen[ team ].textFadeOutTime = fadeout
}

function CinematicIntroScreen_SetTextSpacingTimes( team, line1 = null, line2 = null, line3 = null, line4 = null, line5 = null )
{
	if ( line1 != null )
		level.introScreen[ team ].textFadeInSpacingTime[ 0 ] = line1
	if ( line2 != null )
		level.introScreen[ team ].textFadeInSpacingTime[ 1 ] = line2
	if ( line3 != null )
		level.introScreen[ team ].textFadeInSpacingTime[ 2 ] = line3
	if ( line4 != null )
		level.introScreen[ team ].textFadeInSpacingTime[ 3 ] = line4
	if ( line5 != null )
		level.introScreen[ team ].textFadeInSpacingTime[ 4 ] = line5
}

function CinematicIntroScreen_SetBlackscreenFadeTimes( team, displaytime = null, fadeout = null )
{
	if ( displaytime != null )
		level.introScreen[ team ].blackscreenDisplayDuration = displaytime
	if ( fadeout != null )
		level.introScreen[ team ].blackscreenFadeOutTime = fadeout
}

function CinematicIntroScreen_SetTeamLogoFadeTimes( team, fadeinDelay = null, fadein = null, displaytime = null, fadeout = null )
{
	if ( fadeinDelay != null )
		level.introScreen[ team ].teamLogoFadeInDelay = fadeinDelay
	if ( fadein != null )
		level.introScreen[ team ].teamLogoFadeInTime = fadein
	if ( displaytime != null )
		level.introScreen[ team ].teamLogoDisplayDuration = displaytime
	if ( fadeout != null )
		level.introScreen[ team ].teamLogoFadeOutTime = fadeout
}

function CinematicIntroScreen_SetQuickIntro( team )
{
	//CinematicIntroScreen_SetTextFadeTimes( team, 1.25, 2.5, 1.25 )
	CinematicIntroScreen_SetTextSpacingTimes( team, 0, 0.5, 0, 0, 0 )
	CinematicIntroScreen_SetBlackscreenFadeTimes( team, 4.0, 3.0 )
}

function CinematicIntroScreen_SetClassicMPIntro( team )
{
	CinematicIntroScreen_SetTeamLogoFadeTimes( team, 0.0, 0.5, 1.5, 2.0 )
	CinematicIntroScreen_SetBlackscreenFadeTimes( team, 2.0, 1.5 )
}

function CinematicIntroScreen_SetUseLoadingIcon( doUseIcon )
{
	Assert( type( doUseIcon ) == "bool", "Argument must be a bool." )
	level.introScreen_doLoadingIcon = doUseIcon
}

function CinematicIntroScreen( forced = null )
{
	level.ent.Signal( "StartingIntroscreen" )
	level.ent.EndSignal( "StartingIntroscreen" )

	local player = GetLocalViewPlayer()
	local team = player.GetTeam()
	player.EndSignal( "OnDestroy" )
	Assert( IsValid( player ) )

	while ( GetGameState() < eGameState.Prematch )
	{
		wait 0
	}

	if ( !forced && !IsTrainingLevel() )
	{
		//wait here instead of later - give time for flags to be set
		wait 0.4
	}

	// Cinematics must be turned on for this player
	if ( !forced && !( player.GetCinematicEventFlags() & CE_FLAG_INTRO ) )
	{
		//printt( "Returning from GetCinematicEventFlags" )
		return
	}

	local textLines = level.introScreen[ team ].text
	Assert( textLines.len() <= 5 )

	// Make sure intro screen isn't over with
	local roughTotalTimeRequired = level.introScreen[ team ].textDisplayDuration + level.introScreen[ team ].textFadeInTime + level.introScreen[ team ].textFadeOutTime + level.introScreen[ team ].teamLogoFadeInDelay + level.introScreen[ team ].teamLogoFadeInTime + level.introScreen[ team ].teamLogoDisplayDuration + level.introScreen[ team ].teamLogoFadeOutTime
	local introScreenEndTime = Time() + roughTotalTimeRequired

	//printt( "CinematicIntroScreen" + "forced:" + forced + "Time()" + Time() + "time check greater than: " + (level.nv.gameStateChangeTime + roughTotalTimeRequired) )

	if ( !forced && SkipCinematicStart() ) //Hack hack hack. temp fix for npe until we figure a more elegant fix
	{
		return
	}


	if ( !forced && ( Time() >= level.nv.gameStateChangeTime + roughTotalTimeRequired ) )
		return

	//##################
	// Do Intro Screen!
	//##################

	local allElems = HudElementGroup( "IntroScreen" )
	local background = allElems.CreateElement( "IntroScreenBackground" )

	background.SetColor( 0, 0, 0, 255 )
	background.Show()
	player.FreezeControlsOnClient()

	thread BlackScreenFadeOut( background, level.introScreen[ team ].blackscreenDisplayDuration, level.introScreen[ team ].blackscreenFadeOutTime )
	if ( textLines.len() > 0 )
	{
		local textLineElems = []
		local fadeInDelay = 0
		for ( local i = 0 ; i < textLines.len() ; i++ )
		{
			if ( i > 0 && !IsTrainingLevel() )
				break

			local line = allElems.CreateElement( "IntroScreenTextLine" + i )
			line.SetText( textLines[i] )
			line.SetColor( 255, 255, 255, 0 )
			line.SetAlpha( 0 )
			line.Show()
			fadeInDelay += level.introScreen[ team ].textFadeInSpacingTime[ i ]
			line.FadeOverTimeDelayed( 255, level.introScreen[ team ].textFadeInTime, fadeInDelay )
			textLineElems.append( line )
		}

		// Once all text is displayed, we show it for the specified duration
		wait fadeInDelay + level.introScreen[ team ].textDisplayDuration

		// Fade out the text
		foreach( textLine in textLineElems )
			textLine.ColorOverTime( 0, 0, 0, 0, level.introScreen[ team ].textFadeOutTime, INTERPOLATOR_LINEAR )
		//	textLine.FadeOverTime( 0, level.introScreen[ team ].textFadeOutTime )
	}

	if ( level.introScreen[ team ].teamLogoFadeInDelay > 0 )
		wait level.introScreen[ team ].teamLogoFadeInDelay

	if ( !level.introScreen_doLoadingIcon )
	{
		local factionLogo = allElems.CreateElement( "IntroScreenFactionLogo" )
		factionLogo.Hide()
	}
	else
	{
		local factionLogo = allElems.CreateElement( "IntroScreenFactionLogo" )
		if ( IsTrainingLevel() )
		{
			factionLogo.SetImage( TEAM_ICON_HAMMOND )

			// want it to be larger than the faction logos so it looks more like branding
			local baseSize = factionLogo.GetWidth()
			local newSize = 340
			local newOffset = ( newSize - baseSize ) * 0.5
			factionLogo.SetSize( newSize, newSize )
			factionLogo.SetX( factionLogo.GetX() - newOffset )
			factionLogo.SetY( factionLogo.GetY() - newOffset )
		}
		else if ( player.GetTeam() == TEAM_IMC )
		{
			factionLogo.SetImage( "../ui/scoreboard_imc_logo" )
		}
		else
		{
			factionLogo.SetImage( "../ui/scoreboard_mcorp_logo" )
		}
		local factionLogoFlare = allElems.CreateElement( "IntroScreenFactionLogoFlare" )

		// Fade in the faction logo
		factionLogo.SetAlpha( 0 )
		factionLogoFlare.SetColor( 0, 0, 0, 0 )
		factionLogo.Show()
		factionLogoFlare.Show()
		factionLogo.ColorOverTime( 255, 255, 255, 255, level.introScreen[ team ].teamLogoFadeInTime, INTERPOLATOR_ACCEL )

		// Bling the logo with the flare material
		factionLogoFlare.ColorOverTime( 100, 100, 100, 50, level.introScreen[ team ].teamLogoFadeInTime, INTERPOLATOR_ACCEL )
		wait level.introScreen[ team ].teamLogoFadeInTime

		// Fade out bling
		factionLogoFlare.ColorOverTime( 0, 0, 0, 0, level.introScreen[ team ].teamLogoFadeInTime, INTERPOLATOR_LINEAR )

		// Show the logo for specified amount of time
		wait level.introScreen[ team ].teamLogoDisplayDuration

		// Fade out logo
		factionLogo.ColorOverTime( 0, 0, 0, 0, level.introScreen[ team ].teamLogoFadeOutTime, INTERPOLATOR_LINEAR )

		// Wait till faded out completely
		wait level.introScreen[ team ].teamLogoFadeOutTime
	}

	wait 5

	// Nothing visible anymore ( all alphas at 0 ), hide all elems
	allElems.Hide()

	// Flicker Logo
	//factionLogo.RunAnimationCommand( "FgColor", 0, 2.5, 0.5, INTERPOLATOR_FLICKER, 0.15 )
}

function BlackScreenFadeOut( background, delay, fadeOutTime )
{
	level.ent.Signal( "StopBlackscreenFade" )
	level.ent.EndSignal( "StopBlackscreenFade" )

	local player = GetLocalViewPlayer()

	wait delay

	// Fade everything out and return controls to the player
	background.ColorOverTime( 0, 0, 0, 0, fadeOutTime, INTERPOLATOR_LINEAR )

	if ( IsValid( player ) )
		player.UnfreezeControlsOnClient()
}
