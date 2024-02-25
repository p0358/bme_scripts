function main()
{
	Globalize( CTF_AddPlayer )
	Globalize( GetFlagState )
	Globalize( ServerCallback_SetFlagHomeOrigin )

	AddCreateCallback( "item_healthcore", OnFlagCreated )
	AddCreateCallback( "prop_dynamic", OnFlagBaseCreated )
	RegisterServerVarChangeCallback( "gameState", CTF_GameStateChanged )

	RegisterSignal( "FlagUpdate" )

	level.teamFlags <- {}
	level.teamFlags[TEAM_IMC] <- null
	level.teamFlags[TEAM_MILITIA] <- null

	level.teamFlagBases <- {}
	level.teamFlagBases[TEAM_IMC] <- null
	level.teamFlagBases[TEAM_MILITIA] <- null

	level.flagSpawnPoints <- {}
	level.flagSpawnPoints[TEAM_IMC] <- null
	level.flagSpawnPoints[TEAM_MILITIA] <- null
}


function CTF_GameStateChanged()
{
	local player = GetLocalViewPlayer()

	if ( !("HomeBaseIcon" in player.hudElems) )
		return

	if ( !GamePlayingOrSuddenDeath() )
		player.hudElems.HomeBaseIcon.Hide()
}


function CTF_AddPlayer( player )
{
	player.InitHudElem( "FriendlyFlagArrow" )
	player.InitHudElem( "EnemyFlagArrow" )

	player.InitHudElem( "FriendlyFlagIcon" )
	player.InitHudElem( "EnemyFlagIcon" )

	player.InitHudElem( "FriendlyFlagLabel" )
	player.InitHudElem( "EnemyFlagLabel" )

	player.InitHudElem( "HomeBaseIcon" )
	player.InitHudElem( "HomeBaseArrow" )
	player.InitHudElem( "HomeBaseLabel" )

	player.InitHudElem( "EnemyBaseIcon" )
	player.InitHudElem( "EnemyBaseArrow" )
	player.InitHudElem( "EnemyBaseLabel" )

	player.InitHudElem( "FlagAnchor" )

	player.hudElems.FriendlyFlagArrow.SetOffscreenArrow( true )
	player.hudElems.FriendlyFlagArrow.SetClampToScreen( CLAMP_RECT )
	player.hudElems.FriendlyFlagArrow.SetClampBounds( CL_HIGHLIGHT_ARROW_X, CL_HIGHLIGHT_ARROW_Y )

	player.hudElems.EnemyFlagArrow.SetOffscreenArrow( true )
	player.hudElems.EnemyFlagArrow.SetClampToScreen( CLAMP_RECT )
	player.hudElems.EnemyFlagArrow.SetClampBounds( CL_HIGHLIGHT_ARROW_X, CL_HIGHLIGHT_ARROW_Y )

	player.hudElems.FriendlyFlagIcon.SetClampToScreen( CLAMP_RECT )
	player.hudElems.FriendlyFlagIcon.SetClampBounds( CL_HIGHLIGHT_ICON_X, CL_HIGHLIGHT_ICON_Y )
	//player.hudElems.FriendlyFlagIcon.SetADSFade( deg_cos( 5 ), deg_cos( 2 ), 0, 1 )

	player.hudElems.EnemyFlagIcon.SetClampToScreen( CLAMP_RECT )
	player.hudElems.EnemyFlagIcon.SetClampBounds( CL_HIGHLIGHT_ICON_X, CL_HIGHLIGHT_ICON_Y )
	//player.hudElems.EnemyFlagIcon.SetADSFade( deg_cos( 5 ), deg_cos( 2 ), 0, 1 )

	player.hudElems.FriendlyFlagLabel.SetClampToScreen( CLAMP_RECT )
	player.hudElems.FriendlyFlagLabel.SetClampBounds( CL_HIGHLIGHT_LABEL_X, CL_HIGHLIGHT_LABEL_Y )
	//player.hudElems.FriendlyFlagLabel.SetADSFade( deg_cos( 5 ), deg_cos( 2 ), 0, 1 )

	player.hudElems.EnemyFlagLabel.SetClampToScreen( CLAMP_RECT )
	player.hudElems.EnemyFlagLabel.SetClampBounds( CL_HIGHLIGHT_LABEL_X, CL_HIGHLIGHT_LABEL_Y )
	//player.hudElems.EnemyFlagLabel.SetADSFade( deg_cos( 5 ), deg_cos( 2 ), 0, 1 )


	player.hudElems.HomeBaseIcon.SetClampToScreen( CLAMP_RECT )
	player.hudElems.HomeBaseIcon.SetClampBounds( CL_HIGHLIGHT_ICON_X, CL_HIGHLIGHT_ICON_Y )
	player.hudElems.HomeBaseLabel.SetClampToScreen( CLAMP_RECT )
	player.hudElems.HomeBaseLabel.SetClampBounds( CL_HIGHLIGHT_LABEL_X, CL_HIGHLIGHT_LABEL_Y )
	player.hudElems.HomeBaseLabel.SetFOVFade( deg_cos( 15 ), deg_cos( 10 ), 0, 1 )
	//player.hudElems.HomeBaseLabel.SetADSFade( deg_cos( 5 ), deg_cos( 2 ), 0, 1 )

	player.hudElems.EnemyBaseIcon.SetClampToScreen( CLAMP_RECT )
	player.hudElems.EnemyBaseIcon.SetClampBounds( CL_HIGHLIGHT_ICON_X, CL_HIGHLIGHT_ICON_Y )
	player.hudElems.EnemyBaseLabel.SetClampToScreen( CLAMP_RECT )
	player.hudElems.EnemyBaseLabel.SetClampBounds( CL_HIGHLIGHT_LABEL_X, CL_HIGHLIGHT_LABEL_Y )
	player.hudElems.EnemyBaseLabel.SetFOVFade( deg_cos( 15 ), deg_cos( 10 ), 0, 1 )
	//player.hudElems.EnemyBaseLabel.SetADSFade( deg_cos( 5 ), deg_cos( 2 ), 0, 1 )

	if ( !GamePlayingOrSuddenDeath() )
		player.hudElems.HomeBaseIcon.Hide()

	player.s.friendlyFlagState <- null
	player.s.enemyFlagState <- null

	player.s.friendlyFlagCarrierName <- null
	player.s.enemyFlagCarrierName <- null

	thread CTFHudThink( player )
}


function CTFHudThink( player )
{
	player.EndSignal( "OnDestroy" )

	local team = player.GetTeam()
	local otherTeam = GetOtherTeam( team )

	if ( GAMETYPE == CAPTURE_THE_FLAG_PRO )
	{

		//while ( GetFlagSpawnOriginForTeam( team ) || GetFlagSpawnOriginForTeam( otherTeam ) ) //This line should be equivalent to the bottom one, but it causes a script error if we use it instead
		while ( !GetFlagSpawnOriginForTeam( team ) && !GetFlagSpawnOriginForTeam( otherTeam ) )
			wait 0
	}
	else
	{
		while ( !GetFlagSpawnOriginForTeam( team ) )
			wait 0

		while ( !GetFlagSpawnOriginForTeam( otherTeam ) )
			wait 0
	}

	while ( GetGameState() < eGameState.Epilogue )
	{
		local flagEnt = GetFlagForTeam( team )
		local newFlagState = GetFlagState( flagEnt )
		local enemyFlagEnt = GetFlagForTeam( otherTeam )
		local newEnemyFlagState = GetFlagState( enemyFlagEnt )

		UpdateFriendlyFlag( player, flagEnt, newFlagState, newEnemyFlagState )

		UpdateEnemyFlag( player, enemyFlagEnt, newEnemyFlagState )

		wait 0
	}

	level.ent.Signal( "FlagUpdate" ) //To update loop in CaptureTheFlagThink()
}


function GetFlagState( flagEnt )
{
	if ( !IsValid( flagEnt ) )
		return eFlagState.None

	if ( flagEnt.GetParent() )
		return eFlagState.Held

	if ( IsFlagHome( flagEnt ) )
		return eFlagState.Home

	return eFlagState.Away
}


function UpdateFriendlyFlag( player, flagEnt, newFlagState, newEnemyFlagState )
{
	if ( newFlagState == player.s.friendlyFlagState && newEnemyFlagState == player.s.enemyFlagState )
	{
		if ( newFlagState != eFlagState.Held )
			return

		if ( player.s.friendlyFlagCarrierName == flagEnt.GetParent().GetPlayerName() )
			return
	}

	switch ( newFlagState )
	{
		case eFlagState.None:
			player.hudElems.FriendlyFlagIcon.Hide()
			player.hudElems.FriendlyFlagArrow.Hide()
			player.hudElems.FriendlyFlagLabel.Hide()
			player.hudElems.FriendlyFlagLabel.SetText( "" )
			player.hudElems.HomeBaseIcon.Hide()
			player.hudElems.HomeBaseLabel.Hide()
			break
		case eFlagState.Home:
			player.hudElems.FriendlyFlagIcon.Show()
			player.hudElems.FriendlyFlagArrow.Show()
			player.hudElems.FriendlyFlagLabel.Show()
			player.hudElems.FriendlyFlagIcon.SetImage( "HUD/ctf_flag_friendly_notext" )
			player.hudElems.FriendlyFlagIcon.SetEntity( flagEnt, Vector( 0, 0, 64 ), 0.5, 1.0 )

			player.hudElems.FriendlyFlagLabel.SetText( "#GAMEMODE_FLAG_DEFEND" )
			player.hudElems.HomeBaseIcon.Hide()
			player.hudElems.HomeBaseLabel.Show()

			if ( PlayerHasEnemyFlag( player ) )
			{
				player.hudElems.FriendlyFlagLabel.SetText( "#GAMEMODE_FLAG_CAPTURE" )
			}
			break
		case eFlagState.Held:
			player.hudElems.FriendlyFlagIcon.Show()
			player.hudElems.FriendlyFlagArrow.Show()
			player.hudElems.FriendlyFlagLabel.Show()
			player.hudElems.FriendlyFlagIcon.SetImage( "HUD/ctf_flag_friendly_held" )
			player.hudElems.FriendlyFlagIcon.SetEntityOverhead( flagEnt.GetParent(), Vector( 0, 0, 0 ), 0.5, 1.0 )
			player.s.friendlyFlagCarrierName = flagEnt.GetParent().GetPlayerName()
			player.hudElems.FriendlyFlagLabel.SetText( "#GAMEMODE_FLAG_ATTACK" )
			player.hudElems.HomeBaseIcon.Hide()
			player.hudElems.HomeBaseLabel.Hide()

			if ( PlayerHasEnemyFlag( player ) )
			{
				player.hudElems.HomeBaseIcon.Show()
				player.hudElems.HomeBaseLabel.Show()
			}
			break
		case eFlagState.Away:
			player.hudElems.FriendlyFlagIcon.Show()
			player.hudElems.FriendlyFlagArrow.Show()
			player.hudElems.FriendlyFlagLabel.Show()
			player.hudElems.FriendlyFlagIcon.SetImage( "HUD/ctf_flag_friendly_away" )
			player.hudElems.FriendlyFlagIcon.SetEntity( flagEnt, Vector( 0, 0, 64 ), 0.5, 1.0 )
			player.hudElems.FriendlyFlagLabel.SetText( "#GAMEMODE_FLAG_RETURN" )
			player.hudElems.HomeBaseIcon.Hide()
			player.hudElems.HomeBaseLabel.Hide()

			if ( PlayerHasEnemyFlag( player ) )
			{
				player.hudElems.HomeBaseIcon.Show()
				player.hudElems.HomeBaseLabel.Show()
			}
			break
	}

	player.s.friendlyFlagState = newFlagState

	level.ent.Signal( "FlagUpdate" )
}


function UpdateEnemyFlag( player, flagEnt, newFlagState )
{
	if ( newFlagState == player.s.enemyFlagState )
	{
		if ( newFlagState != eFlagState.Held )
			return

		if ( player.s.enemyFlagCarrierName == flagEnt.GetParent().GetPlayerName() )
			return
	}

	switch ( newFlagState )
	{
		case eFlagState.None:
			player.hudElems.EnemyFlagIcon.Hide()
			player.hudElems.EnemyFlagArrow.Hide()
			player.hudElems.EnemyFlagLabel.Hide()
			player.hudElems.EnemyBaseIcon.Hide()
			player.hudElems.EnemyBaseLabel.Hide()
			break
		case eFlagState.Home:
			player.hudElems.EnemyFlagIcon.Show()
			player.hudElems.EnemyFlagArrow.Show()
			player.hudElems.EnemyFlagLabel.Show()
			player.hudElems.EnemyFlagIcon.SetImage( "HUD/ctf_flag_enemy_notext" )
			player.hudElems.EnemyFlagIcon.SetEntity( flagEnt, Vector( 0, 0, 64 ), 0.5, 1.0 )
			player.hudElems.EnemyFlagLabel.SetText( "#GAMEMODE_FLAG_CAPTURE" )
			player.hudElems.EnemyBaseIcon.Hide()
			player.hudElems.EnemyBaseLabel.Show()
			break
		case eFlagState.Away:
			player.hudElems.EnemyFlagIcon.Show()
			player.hudElems.EnemyFlagArrow.Show()
			player.hudElems.EnemyFlagLabel.Show()
			player.hudElems.EnemyFlagIcon.SetImage( "HUD/ctf_flag_enemy_away" )
			player.hudElems.EnemyFlagIcon.SetEntity( flagEnt, Vector( 0, 0, 64 ), 0.5, 1.0 )
			player.hudElems.EnemyFlagLabel.SetText( "#GAMEMODE_FLAG_CAPTURE" )
			player.hudElems.EnemyBaseIcon.Hide()
			player.hudElems.EnemyBaseLabel.Hide()
			break
		case eFlagState.Held:
			if ( flagEnt.GetParent() == player )
			{
				player.hudElems.EnemyFlagIcon.Hide()
				player.hudElems.EnemyFlagLabel.Hide()
				player.hudElems.EnemyFlagIcon.SetEntity( null, Vector( 0, 0, 0 ), 0.5, 0.5 )
				local xPos = player.hudElems.FlagAnchor.GetAbsX() - (player.hudElems.EnemyFlagIcon.GetWidth() / 2)
				local yPos = player.hudElems.FlagAnchor.GetAbsY()
				player.hudElems.EnemyFlagIcon.MoveOverTime( xPos, yPos, 0.15, INTERPOLATOR_DEACCEL )
				player.hudElems.EnemyFlagArrow.Hide()
				player.hudElems.EnemyBaseIcon.Hide()
				player.hudElems.EnemyBaseLabel.Hide()

				switch ( GetFlagStateForTeam( player.GetTeam() ) )
				{
					case eFlagState.Home:
						player.hudElems.FriendlyFlagLabel.SetText( "#GAMEMODE_FLAG_CAPTURE" )
						break
					case eFlagState.Held:
						player.hudElems.FriendlyFlagLabel.SetText( "#GAMEMODE_FLAG_ATTACK" )
						break
					case eFlagState.Away:
						player.hudElems.FriendlyFlagLabel.SetText( "#GAMEMODE_FLAG_RETURN" )
						break
				}
			}
			else
			{
				player.hudElems.EnemyFlagIcon.Show()
				player.hudElems.EnemyFlagArrow.Show()
				player.hudElems.EnemyFlagLabel.Show()
				player.hudElems.EnemyFlagIcon.SetImage( "HUD/ctf_flag_enemy_held" )
				player.hudElems.EnemyFlagIcon.SetEntityOverhead( flagEnt.GetParent(), Vector( 0, 0, 0 ), 0.5, 1.0 )
				player.hudElems.EnemyFlagLabel.SetText( "#GAMEMODE_FLAG_ESCORT" )
				player.hudElems.EnemyBaseIcon.Hide()
				player.hudElems.EnemyBaseLabel.Hide()
			}
			player.s.enemyFlagCarrierName = flagEnt.GetParent().GetPlayerName()
			break
	}

	player.s.enemyFlagState = newFlagState

	level.ent.Signal( "FlagUpdate" )
}


function OnFlagCreated( flagEnt, isRecreate )
{
	level.teamFlags[flagEnt.GetTeam()] = flagEnt

	local player = GetLocalViewPlayer()

	if ( flagEnt.GetTeam() == player.GetTeam() )
	{
		player.hudElems.FriendlyFlagIcon.Show()
		player.hudElems.FriendlyFlagIcon.SetEntity( flagEnt, Vector( 0, 0, 64 ), 0.5, 1.0 )

		player.hudElems.FriendlyFlagArrow.Show()
		player.hudElems.FriendlyFlagArrow.SetEntity( flagEnt, Vector( 0, 0, 64 ), 0.5, 1.0 )
	}
	else
	{
		player.hudElems.EnemyFlagIcon.Show()
		player.hudElems.EnemyFlagIcon.SetEntity( flagEnt, Vector( 0, 0, 64 ), 0.5, 1.0 )

		player.hudElems.EnemyFlagArrow.Show()
		player.hudElems.EnemyFlagArrow.SetEntity( flagEnt, Vector( 0, 0, 64 ), 0.5, 1.0 )

		player.s.friendlyFlagState = null
	}
}


function OnFlagBaseCreated( flagBaseEnt, isRecreate )
{
	if ( flagBaseEnt.GetModelName() != CTF_FLAG_BASE_MODEL )
		return

	level.teamFlagBases[flagBaseEnt.GetTeam()] = flagBaseEnt

	local player = GetLocalViewPlayer()

	if ( flagBaseEnt.GetTeam() == player.GetTeam() )
	{
		player.hudElems.HomeBaseIcon.SetEntityOverhead( flagBaseEnt, Vector( 0, 0, 64 ), 0.5, 1.0 )
		player.hudElems.HomeBaseLabel.SetEntityOverhead( flagBaseEnt, Vector( 0, 0, 64 ), 0.5, 0.25 )
		player.hudElems.HomeBaseLabel.Show()
		player.hudElems.HomeBaseLabel.SetAutoTextVector( "#HUD_DISTANCE_METERS", HATT_DISTANCE_METERS, flagBaseEnt.GetOrigin() )
	}
	else
	{
		player.hudElems.EnemyBaseIcon.SetEntityOverhead( flagBaseEnt, Vector( 0, 0, 64 ), 0.5, 1.0 )
		player.hudElems.EnemyBaseLabel.SetEntityOverhead( flagBaseEnt, Vector( 0, 0, 64 ), 0.5, 0.25 )
		player.hudElems.EnemyBaseLabel.Show()
		player.hudElems.EnemyBaseLabel.SetAutoTextVector( "#HUD_DISTANCE_METERS", HATT_DISTANCE_METERS, flagBaseEnt.GetOrigin() )
	}
}


function ServerCallback_SetFlagHomeOrigin( team, x, y, z )
{
	local player = GetLocalViewPlayer()
	level.flagSpawnPoints[team] = Vector( x, y, z )

	if ( team == player.GetTeam() )
	{
		player.hudElems.HomeBaseLabel.SetAutoTextVector( "#HUD_DISTANCE_METERS", HATT_DISTANCE_METERS, level.flagSpawnPoints[team] )
	}
	else
	{
		player.hudElems.EnemyBaseLabel.SetAutoTextVector( "#HUD_DISTANCE_METERS", HATT_DISTANCE_METERS, level.flagSpawnPoints[team] )
	}
}