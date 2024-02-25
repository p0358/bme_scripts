function main()
{
	Globalize( TE_AddPlayer )
	Globalize( ServerCallback_SetTitanFlagHomeOrigin )
	Globalize( GetTitanFlagState )

	AddCallback_OnInitPlayerScripts( TE_AddPlayer )

	AddCreateCallback( "titan_soul", OnTitanFlagCreated )
	AddCreateCallback( "prop_dynamic", OnFlagBaseCreated )
	RegisterServerVarChangeCallback( "gameState", TE_GameStateChanged )
	RegisterServerVarChangeCallback( "cttTitanSoul", TE_TitanSoulChanged )

	RegisterSignal( "FlagUpdate" )
	RegisterSignal( "UpdateTitanFlagThink" )

	level.teamFlag <- null

	level.flagSpawnPoint <- null
	level.flagReturnPoint <- null
}


function TE_GameStateChanged()
{
	local player = GetLocalViewPlayer()

	if ( !("HomeIcon" in player.hudElems) )
		return

	if ( GetGameState() != eGameState.Playing )
		player.hudElems.HomeIcon.Hide()
}


function TE_AddPlayer( player )
{
	player.InitHudElem( "FlagArrow" )
	player.InitHudElem( "FlagIcon" )
	player.InitHudElem( "FlagLabel" )

	player.InitHudElem( "HomeIcon" )
	player.InitHudElem( "HomeArrow" )
	player.InitHudElem( "HomeLabel" )

	player.InitHudElem( "FlagAnchor" )

	player.hudElems.FlagArrow.SetOffscreenArrow( true )
	player.hudElems.FlagArrow.SetClampToScreen( CLAMP_RECT )
	player.hudElems.FlagArrow.SetClampBounds( 0.85, 0.80 )

	player.hudElems.FlagIcon.SetClampToScreen( CLAMP_RECT )
	player.hudElems.FlagIcon.SetClampBounds( 0.80, 0.75 )
	//player.hudElems.FlagIcon.SetADSFade( deg_cos( 5 ), deg_cos( 2 ), 0, 1 )

	player.hudElems.FlagLabel.SetClampToScreen( CLAMP_RECT )
	player.hudElems.FlagLabel.SetClampBounds( 0.80, 0.75 )
	//player.hudElems.FlagLabel.SetADSFade( deg_cos( 5 ), deg_cos( 2 ), 0, 1 )

	player.hudElems.HomeIcon.SetClampToScreen( CLAMP_RECT )
	player.hudElems.HomeIcon.SetClampBounds( 0.80, 0.75 )

	player.hudElems.HomeLabel.SetClampToScreen( CLAMP_RECT )
	player.hudElems.HomeLabel.SetClampBounds( 0.80, 0.75 )
	player.hudElems.HomeLabel.SetFOVFade( deg_cos( 15 ), deg_cos( 10 ), 0, 1 )

	//player.hudElems.HomeLabel.SetADSFade( deg_cos( 5 ), deg_cos( 2 ), 0, 1 )

	if ( GetGameState() != eGameState.Playing )
		player.hudElems.HomeIcon.Hide()

	player.s.friendlyFlagState <- null
	player.s.enemyFlagState <- null
	player.s.lastCTTRiderEnt <- null

	player.s.friendlyFlagCarrierName <- null
	player.s.enemyFlagCarrierName <- null

	thread TEHudThink( player )
}


function TEHudThink( player )
{
	player.EndSignal( "OnDestroy" )

	local team = player.GetTeam()

	while ( !GetTitanFlagSpawnOrigin() )
		wait 0

	while ( !GetTitanFlagReturnOrigin() )
		wait 0

	while ( true )
	{
		if ( IsValid( level.flagSpawnPoint ) && IsValid( level.flagReturnPoint ) )
		{
			local flagEnt = GetTitanFlag()
			UpdateFlag( player, flagEnt )
		}

		wait 0
	}
}


function GetTitanFlagState( flagEnt )
{
	if ( GetGameState() != eGameState.Playing )
		return eFlagState.None

	if ( !IsValid( flagEnt ) )
		return eFlagState.None

	if ( !IsValid( GetTitanFromFlag( flagEnt ) ) )
		return eFlagState.None

	if ( GetTitanFromFlag( flagEnt ).GetBossPlayer() != null )
		return eFlagState.Held

	if ( IsTitanFlagHome( flagEnt ) )
		return eFlagState.Home

	return eFlagState.Away
}


function UpdateFlag( player, flagEnt )
{
	local newFlagState = GetTitanFlagState( flagEnt )

	/*
	if ( newFlagState == player.s.friendlyFlagState )
	{
		if ( newFlagState != eFlagState.Held )
			return

		if ( player.s.friendlyFlagCarrierName == flagEnt.GetParent().GetPlayerName() )
			return
	}
	*/

	local isFriendlyTeam = false
	local titan = null

	if ( IsValid( flagEnt ) )
	{
		titan = GetTitanFromFlag( flagEnt )

		if ( IsValid( titan ) && player.GetTeam() == titan.GetTeam() )
			isFriendlyTeam = true
	}

	if ( newFlagState == eFlagState.None )
	{
			player.hudElems.FlagIcon.Hide()
			player.hudElems.FlagArrow.Hide()
			player.hudElems.FlagLabel.Hide()
			player.hudElems.FlagLabel.SetText( "" )
			player.hudElems.HomeIcon.Hide()
			player.hudElems.HomeLabel.Hide()
	}
	else
	{
			player.hudElems.FlagIcon.Show()
			player.hudElems.FlagArrow.Show()
			player.hudElems.FlagLabel.Show()
			player.hudElems.FlagIcon.SetEntityOverhead( titan, Vector( 0, 0, 0 ), 0.5, 1.1 )
			player.hudElems.FlagArrow.SetEntityOverhead( titan, Vector( 0, 0, 0 ), 0.5, 1.1 )
			player.hudElems.FlagLabel.SetEntityOverhead( titan, Vector( 0, 0, 0 ), 0.5, 1.75 )
	}

	if ( PlayerHasTitanFlag( player ) )
	{
		player.hudElems.HomeIcon.SetEntityOverhead( level.flagReturnPoint, Vector( 0, 0, 64 ), 0.5, 1.0 )
		player.hudElems.HomeLabel.SetEntityOverhead( level.flagReturnPoint, Vector( 0, 0, 64 ), 0.5, 0.25 )
		player.hudElems.HomeLabel.SetAutoTextVector( "#HUD_DISTANCE_METERS", HATT_DISTANCE_METERS, level.flagReturnPoint.GetOrigin() )
		player.hudElems.HomeIcon.SetImage( "HUD/ctf_flag_friendly_missing" )
		player.hudElems.HomeIcon.Show()
		player.hudElems.HomeLabel.Show()

		newFlagState = eFlagState.None
	}
	else
	{
		player.hudElems.HomeIcon.Hide()
		player.hudElems.HomeLabel.Hide()
	}

	switch ( newFlagState )
	{
		case eFlagState.None:
			player.hudElems.FlagIcon.Hide()
			player.hudElems.FlagArrow.Hide()
			player.hudElems.FlagLabel.Hide()
			player.hudElems.FlagLabel.SetText( "" )
			break

		case eFlagState.Home:
			if ( isFriendlyTeam )
			{
				player.hudElems.FlagIcon.SetImage( "HUD/ctf_flag_friendly_notext" )
				player.hudElems.FlagLabel.SetText( "#GAMEMODE_FLAG_CAPTURE" )
			}
			else
			{
				player.hudElems.FlagIcon.SetImage( "HUD/ctf_flag_enemy_notext" )
				player.hudElems.FlagLabel.SetText( "#GAMEMODE_FLAG_GUARD" )
			}
			break

		case eFlagState.Held:
			//player.s.friendlyFlagCarrierName = titan.GetPlayerName()
			if ( isFriendlyTeam )
			{
				player.hudElems.FlagIcon.SetImage( "HUD/ctf_flag_friendly_notext" )
				player.hudElems.FlagLabel.SetText( "#GAMEMODE_FLAG_ESCORT" )
			}
			else
			{
				player.hudElems.FlagIcon.SetImage( "HUD/ctf_flag_enemy_notext" )
				player.hudElems.FlagLabel.SetText( "#GAMEMODE_FLAG_ATTACK" )

				player.hudElems.HomeIcon.SetImage( "HUD/ctf_flag_enemy_away" )
				player.hudElems.HomeIcon.Show()
				player.hudElems.HomeLabel.Show()

				player.hudElems.HomeIcon.SetEntityOverhead( level.flagReturnPoint, Vector( 0, 0, 64 ), 0.5, 1.0 )
				player.hudElems.HomeLabel.SetEntityOverhead( level.flagReturnPoint, Vector( 0, 0, 64 ), 0.5, 0.25 )
				player.hudElems.HomeLabel.SetText( "#GAMEMODE_FLAG_INTERCEPT" )
				player.hudElems.HomeIcon.SetImage( "HUD/ctf_flag_enemy_away" )
				player.hudElems.HomeIcon.Show()
				player.hudElems.HomeLabel.Show()
			}
			break

		case eFlagState.Away:

			if ( isFriendlyTeam )
			{
				player.hudElems.FlagIcon.SetImage( "HUD/ctf_flag_friendly_notext" )
				player.hudElems.FlagLabel.SetText( "#GAMEMODE_FLAG_CAPTURE" )
			}
			else
			{
				player.hudElems.FlagIcon.SetImage( "HUD/ctf_flag_enemy_notext" )
				player.hudElems.FlagLabel.SetText( "#GAMEMODE_FLAG_ATTACK" )
			}
			break
	}

	player.s.friendlyFlagState = newFlagState

	level.ent.Signal( "FlagUpdate" )
}



function OnTitanFlagCreated( titanFlagEnt, isRecreate )
{
	if ( !level.nv.cttTitanSoul )
	{
		printt( "OnTitanFlagCreated NO SOUL" )
		return
	}

	local soul = GetEntityFromEncodedEHandle( level.nv.cttTitanSoul )
	if ( !IsValid( soul ) )
	{
		printt( "OnTitanFlagCreated NO VALID SOUL" )
		return
	}

	if ( soul != titanFlagEnt )
	{
		printt( "OnTitanFlagCreated NOT EQUAL" )
		return
	}

	level.teamFlag = soul
}


function TE_TitanSoulChanged()
{
	if ( !level.nv.cttTitanSoul )
	{
		printt( "TE_TitanSoulChanged NO SOUL" )
		return
	}

	local soul = GetEntityFromEncodedEHandle( level.nv.cttTitanSoul )
	if ( !IsValid( soul ) )
	{
		printt( "TE_TitanSoulChanged NO VALID SOUL" )
		return
	}

	level.teamFlag = soul
}


function OnFlagBaseCreated( flagBaseEnt, isRecreate )
{
	if ( flagBaseEnt.GetModelName() != CTF_FLAG_BASE_MODEL )
		return

	thread InitFlagBase( flagBaseEnt )
}


function InitFlagBase( flagBaseEnt )
{
	flagBaseEnt.EndSignal( "OnDestroy" )

	while ( !level.clientScriptInitialized )
		wait 0

	printt( "CREATED", flagBaseEnt, level.nv.attackingTeam )

	if ( flagBaseEnt.GetTeam() == level.nv.attackingTeam )
		level.flagReturnPoint = flagBaseEnt
	else
		level.flagSpawnPoint = flagBaseEnt
}


function ServerCallback_SetTitanFlagHomeOrigin( team, x, y, z )
{
}