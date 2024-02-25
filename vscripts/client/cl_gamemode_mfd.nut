
function main()
{
	RegisterSignal( "UpdateMFDVGUI" )

	level.teamFlags <- {}
	level.teamFlags[TEAM_IMC] <- null
	level.teamFlags[TEAM_MILITIA] <- null

	level.flagSpawnPoints <- {}
	level.flagSpawnPoints[TEAM_IMC] <- null
	level.flagSpawnPoints[TEAM_MILITIA] <- null

	level.overheadIconShouldPing <- false
	RegisterServerVarChangeCallback( "mfdOverheadPingDelay", mfdOverheadPingDelay_Changed )

	RegisterSignal( "MFDChanged" )
	RegisterSignal( "TargetUnmarked"  )
	RegisterSignal( "PingEnemyFlag" )

	AddCallback_OnInitPlayerScripts( MARKED_FOR_DEATH_InitPlayerScripts )

	AddCreateCallback( MARKER_ENT_CLASSNAME, OnMarkedCreated )
}


function mfdOverheadPingDelay_Changed()
{
	level.overheadIconShouldPing = level.nv.mfdOverheadPingDelay != 0 ? true : false
}


function SCB_MarkedChanged()
{
	//printt( "SCB_MarkedChanged" )
	thread MFDChanged()
}
Globalize( SCB_MarkedChanged )


function OnMarkedCreated( ent, isRecreate )
{
	//printt( "OnMarkedCreated" )
	FillMFDMarkers( ent )

}

function DelayedSelfNotification( player )
{
	player.EndSignal( "OnDestroy" )
/*	if ( TargetsMarkedImmediately() )
		return*/

	local team = player.GetTeam()
	local friendlyMarked = GetMarked( team )

	if ( !IsAlive( player ) )
		return

	if ( player != friendlyMarked )
		return

	SetEventNotification( "#MARKED_FOR_DEATH_YOU_ARE_MARKED_REMINDER" )
}

function DelayMarkedForDeathProReminder() //Used only in MFD Pro, targets marked immediately
{
	wait 7.5
	SetEventNotification( "#MARKED_FOR_DEATH_YOU_ARE_MARKED_REMINDER" )
}
Globalize( DelayMarkedForDeathProReminder )

function DelayMarkedForDeathProTargetsMarked() //Used only in MFD Pro, targets marked immediately
{
	wait 4
	local player = GetLocalViewPlayer()
	local team = player.GetTeam()
	local enemyTeam = GetOtherTeam( team )

	local friendlyMarked = GetMarked( team )
	local enemyMarked = GetMarked( enemyTeam )

	if ( IsValid( friendlyMarked ) && IsValid( enemyMarked ) )
		SetTimedEventNotification( 6.0, "#MARKED_FOR_DEATH_ARE_MARKED", friendlyMarked.GetPlayerName(), enemyMarked.GetPlayerName() )
}
Globalize( DelayMarkedForDeathProTargetsMarked )

function MFDChanged()
{
	//PrintFunc()
	level.ent.Signal( "MFDChanged" ) //Only want this called once per frame
	level.ent.EndSignal( "MFDChanged" )
	FlagWait( "ClientInitComplete" )
	WaitEndFrame() //Necessary to get MFD effect to play upon spawning
	//printt( "Done waiting for MFD Changed" )
	local player = GetLocalViewPlayer()


	local team = player.GetTeam()
	local enemyTeam = GetOtherTeam( team )

	local friendlyMarked = GetMarked( team )
	local enemyMarked = GetMarked( enemyTeam )

	local pendingFriendlyMarked = GetPendingMarked( team )
	local pendingEnemyMarked = GetPendingMarked( enemyTeam )

	if ( player == friendlyMarked )
	{
		//printt( "Player is friendly marked" )
		if ( !IsWatchingKillReplay() )
		{
			local cockpit = player.GetCockpit()

			if ( !cockpit )
				return

		 	StartParticleEffectOnEntity( cockpit, GetParticleSystemIndex( "P_MFD" ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
		 	EmitSoundOnEntity( player, "UI_InGame_MarkedForDeath_PlayerMarked"  )
		 	thread PlayMarkedForDeathMusic( player )
		 	thread DelayPlayingUnmarkedEffect( player )

		 	ClearEventNotification()
			local announcement = CAnnouncement( "#MARKED_FOR_DEATH_YOU_ARE_MARKED_ANNOUNCEMENT" )
			announcement.SetSubText( "#MARKED_FOR_DEATH_STAY_ALIVE" )
			announcement.SetPurge( true )
			announcement.SetDuration( 4.5 )
			AnnouncementFromClass( player, announcement )
			thread DelayedSelfNotification( player )
		}

	}
	else
	{
		if ( !IsWatchingKillReplay() )
		{
			if ( IsAlive( friendlyMarked ) && IsAlive( enemyMarked ) )
				SetTimedEventNotification( 6.0, "#MARKED_FOR_DEATH_ARE_MARKED", friendlyMarked.GetPlayerName(), enemyMarked.GetPlayerName() )
		}
	}

	if ( IsAlive( friendlyMarked ) )
	{
		if ( friendlyMarked != player )
		{
			player.hudElems.FriendlyFlagIcon.Show()
			player.hudElems.FriendlyFlagLabel.Show()
			player.hudElems.FriendlyFlagLabel.SetText( "#MARKED_FOR_DEATH_GUARD_PLAYER", friendlyMarked.GetPlayerName() )
			player.hudElems.FriendlyFlagIcon.SetImage( "HUD/mfd_friendly" )
			player.hudElems.FriendlyFlagIcon.SetEntityOverhead( friendlyMarked, Vector( 0, 0, 0 ), 0.5, 1.25 )
		}
		else
		{
			player.hudElems.FriendlyFlagIcon.Hide()
			player.hudElems.FriendlyFlagLabel.Hide()
		}
	}
	else if ( IsAlive( pendingFriendlyMarked ) )
	{
		if ( pendingFriendlyMarked != player )
		{
			player.hudElems.FriendlyFlagIcon.Show()
			player.hudElems.FriendlyFlagLabel.Show()
			player.hudElems.FriendlyFlagLabel.SetText( "#MARKED_FOR_DEATH_GUARD_PLAYER", pendingFriendlyMarked.GetPlayerName() )
			player.hudElems.FriendlyFlagIcon.SetImage( "HUD/mfd_pre_friendly" )
			player.hudElems.FriendlyFlagIcon.SetEntityOverhead( pendingFriendlyMarked, Vector( 0, 0, 0 ), 0.5, 1.25 )
		}
		else
		{
			player.hudElems.FriendlyFlagIcon.Hide()
			player.hudElems.FriendlyFlagLabel.Hide()
		}
	}
	else
	{
		player.Signal( "TargetUnmarked" )
		player.hudElems.FriendlyFlagIcon.Hide()
		player.hudElems.FriendlyFlagLabel.Hide()
	}

	if ( IsAlive( enemyMarked ) )
	{
		player.hudElems.EnemyFlagIcon.Show()
		if ( level.overheadIconShouldPing )
		{
			player.hudElems.EnemyFlagPingIcon.Show()
			player.hudElems.EnemyFlagPing2Icon.Show()
		}
		player.hudElems.EnemyFlagLabel.Show()
		player.hudElems.EnemyFlagLabel.SetText( "#MARKED_FOR_DEATH_KILL_PLAYER", enemyMarked.GetPlayerName() )
		player.hudElems.EnemyFlagIcon.SetImage( "HUD/mfd_enemy" )

		player.hudElems.EnemyFlagIcon.SetEntityOverhead( enemyMarked, Vector( 0, 0, 0 ), 0.5, 1.25 )
		if ( level.overheadIconShouldPing )
			thread PingEnemyFlag( player, enemyMarked )
	}
	else
	{
		player.Signal( "TargetUnmarked" )
		player.hudElems.EnemyFlagIcon.Hide()
		if ( level.overheadIconShouldPing )
		{
			player.hudElems.EnemyFlagPingIcon.Hide()
			player.hudElems.EnemyFlagPing2Icon.Hide()
		}
		player.hudElems.EnemyFlagLabel.Hide()
	}

	if ( !GamePlaying() )
		ClearEventNotification()

	//UpdateMFDVGUI regardless
	UpdateMFDVGUI()

}
Globalize( MFDChanged )


function PingEnemyFlag( player, enemyMarked )
{
	enemyMarked.EndSignal( "OnDeath" )
	enemyMarked.EndSignal( "OnDestroy" )
	player.EndSignal( "TargetUnmarked" )

	player.Signal( "PingEnemyFlag" )
	player.EndSignal( "PingEnemyFlag" )

	const MFD_DISPLAY_FRACS = 5.0
	local delayFrac = level.nv.mfdOverheadPingDelay / MFD_DISPLAY_FRACS

	while ( IsAlive( enemyMarked ) )
	{
		local centerPoint = enemyMarked.GetWorldSpaceCenter()
		local origin = enemyMarked.GetOrigin()

		player.hudElems.EnemyFlagIcon.SetAlpha( 255 )
		if ( level.overheadIconShouldPing )
		{
			player.hudElems.EnemyFlagPingIcon.SetAlpha( 255 )
			player.hudElems.EnemyFlagPingIcon.SetScale( 0.5, 0.5 )
			player.hudElems.EnemyFlagPingIcon.ScaleOverTime( 1.45, 1.45, delayFrac, INTERPOLATOR_DEACCEL )
			player.hudElems.EnemyFlagPingIcon.SetColor( 255, 229, 215, 190 )
			player.hudElems.EnemyFlagPingIcon.ColorOverTime( 255, 177, 134, 0, delayFrac, INTERPOLATOR_ACCEL )
		}
		player.hudElems.EnemyFlagLabel.SetAlpha( 255 )

		wait delayFrac * 0.25

		if ( level.overheadIconShouldPing )
		{
			player.hudElems.EnemyFlagPing2Icon.SetAlpha( 175 )
			player.hudElems.EnemyFlagPing2Icon.SetScale( 0.5, 0.5 )
			player.hudElems.EnemyFlagPing2Icon.ScaleOverTime( 1.15, 1.15, delayFrac, INTERPOLATOR_DEACCEL )
			player.hudElems.EnemyFlagPing2Icon.SetColor( 255, 229, 215, 190 )
			player.hudElems.EnemyFlagPing2Icon.ColorOverTime( 255, 177, 134, 0, delayFrac, INTERPOLATOR_ACCEL )
		}

		wait delayFrac * 0.75

		player.hudElems.EnemyFlagIcon.FadeOverTime( 0, delayFrac, INTERPOLATOR_DEACCEL )
		player.hudElems.EnemyFlagLabel.FadeOverTime( 0, delayFrac, INTERPOLATOR_DEACCEL )
		wait delayFrac * (MFD_DISPLAY_FRACS - delayFrac)
	}
}


function UpdateMFDVGUI()
{
	level.ent.Signal( "UpdateMFDVGUI" )
}

function MARKED_FOR_DEATH_InitPlayerScripts( player )
{
	player.InitHudElem( "FriendlyFlagIcon" )
	player.InitHudElem( "EnemyFlagIcon" )
	player.InitHudElem( "EnemyFlagPingIcon" )
	player.InitHudElem( "EnemyFlagPing2Icon" )

	player.InitHudElem( "FriendlyFlagLabel" )
	player.InitHudElem( "EnemyFlagLabel" )

	player.hudElems.FriendlyFlagIcon.SetClampToScreen( CLAMP_RECT )
	player.hudElems.FriendlyFlagIcon.SetClampBounds( CL_HIGHLIGHT_ICON_X, CL_HIGHLIGHT_ICON_Y )

	player.hudElems.EnemyFlagIcon.SetClampToScreen( CLAMP_RECT )
	player.hudElems.EnemyFlagIcon.SetClampBounds( CL_HIGHLIGHT_ICON_X, CL_HIGHLIGHT_ICON_Y )

	if ( level.overheadIconShouldPing )
	{
		player.hudElems.EnemyFlagPingIcon.SetClampToScreen( CLAMP_RECT )
		player.hudElems.EnemyFlagPingIcon.SetClampBounds( CL_HIGHLIGHT_ICON_X, CL_HIGHLIGHT_ICON_Y )
	}

	player.hudElems.EnemyFlagPing2Icon.SetClampToScreen( CLAMP_RECT )
	player.hudElems.EnemyFlagPing2Icon.SetClampBounds( CL_HIGHLIGHT_ICON_X, CL_HIGHLIGHT_ICON_Y )

	player.hudElems.FriendlyFlagLabel.SetClampToScreen( CLAMP_RECT )
	player.hudElems.FriendlyFlagLabel.SetClampBounds( CL_HIGHLIGHT_LABEL_X, CL_HIGHLIGHT_LABEL_Y )

	player.hudElems.EnemyFlagLabel.SetClampToScreen( CLAMP_RECT )
	player.hudElems.EnemyFlagLabel.SetClampBounds( CL_HIGHLIGHT_LABEL_X, CL_HIGHLIGHT_LABEL_Y )

	player.hudElems.FriendlyFlagLabel.SetText( "#GAMEMODE_FLAG_GUARD" )
	player.hudElems.EnemyFlagLabel.SetText( "#GAMEMODE_FLAG_ATTACK" )

	thread MFDChanged()
}

function MarkedForDeathHudThink( vgui, player, scoreGroup )
{
	vgui.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDestroy" )

	local panel = vgui.GetPanel()
	local flags = {}
	local flagLabels = {}

	local team = player.GetTeam()
	if ( team == TEAM_UNASSIGNED )
		return

	local otherTeam = GetOtherTeam( team )
	flags[ team ] <- scoreGroup.CreateElement( "MFDFriendlyMark", panel )
	flagLabels[ team ] <- scoreGroup.CreateElement( "FriendlyFlagLabel", panel )
	flags[ otherTeam ] <- scoreGroup.CreateElement( "MFDEnemyMark", panel )
	flagLabels[ otherTeam ] <- scoreGroup.CreateElement( "EnemyFlagLabel", panel )

	local teams = [ TEAM_IMC, TEAM_MILITIA ]

	for ( ;; )
	{
		foreach ( team in teams )
		{
			local marked = GetMarked( team )
			local label = flagLabels[team]
			local flag = flags[team]

			if ( !IsAlive( marked ) )
			{
				label.Hide()
				flag.Hide()
				continue
			}

			label.SetText( "#GAMEMODE_JUST_THE_SCORE", marked.GetPlayerName() )

			label.Show()
			flag.Show()
		}

		level.ent.WaitSignal( "UpdateMFDVGUI" )

		WaitEndFrame() // not sure if this is nec
	}
}
Globalize( MarkedForDeathHudThink )

function PlayMarkedForDeathMusic( player ) //Long term should look into API-ing some of this so it isn't hard for game modes to play their own music
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "TargetUnmarked" )

	if ( GetMusicReducedSetting() )
		return

	OnThreadEnd(
		function() : (  )
		{
			StopLoopMusic()
			PlayActionMusic()
		}
	)

	waitthread ForceLoopMusic( eMusicPieceID.GAMEMODE_1 ) 	//Is looping music, so doesn't return from this until the end signals kick in
}

function MarkedForDeathCountdownSound( endCountdownTime, soundAlias = "UI_InGame_MarkedForDeath_CountdownToMarked" )
{
	//player.EndSignal( "OnDestroy" ) //Don't end signal on destroy because if you are watching kill replay while counting down to marked, we don't want this thread to end

	while( endCountdownTime - Time() > 0 )
	{
		local player = GetLocalClientPlayer() //Keep getting handle to local player because we want to keep playing this sound throughout kill replay
		EmitSoundOnEntity( player, soundAlias )
		wait 1.0
	}
}
Globalize ( MarkedForDeathCountdownSound )

function DelayPlayingUnmarkedEffect( player )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )

	player.WaitSignal( "TargetUnmarked" )

	if ( !IsAlive( player ) )
		return

	local cockpit = player.GetCockpit()

	if ( !cockpit )
		return

 	StartParticleEffectOnEntity( cockpit, GetParticleSystemIndex( "P_MFD_unmark" ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
}
