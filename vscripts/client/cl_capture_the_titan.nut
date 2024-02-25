const CTT_STATE_NONE = 0
const CTT_STATE_TITAN = 1
const CTT_STATE_RODEO = 2
const CTT_STATE_CAPPING = 3

function main()
{
	Globalize( CTT_AddPlayer )
	Globalize( ServerCallback_SetTitanFlagHomeOrigin )
	Globalize( GetTitanFlagState )

	AddCreateCallback( "titan_soul", OnTitanFlagCreated )
	AddCreateCallback( "prop_dynamic", OnFlagBaseCreated )
	RegisterServerVarChangeCallback( "gameState", CTT_GameStateChanged )
	RegisterServerVarChangeCallback( "cttTitanSoul", CTT_TitanSoulChanged )

	RegisterSignal( "FlagUpdate" )
	RegisterSignal( "UpdateTitanFlagThink" )

	level.teamFlag <- null

	level.flagSpawnPoint <- null
	level.flagReturnPoint <- null
}


function CTT_GameStateChanged()
{
	local player = GetLocalViewPlayer()

	if ( !("HomeIcon" in player.hudElems) )
		return

	if ( GetGameState() != eGameState.Playing )
		player.hudElems.HomeIcon.Hide()
}


function CTT_AddPlayer( player )
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
	player.hudElems.FlagArrow.SetClampBounds( CL_HIGHLIGHT_ARROW_X, CL_HIGHLIGHT_ARROW_Y )

	player.hudElems.FlagIcon.SetClampToScreen( CLAMP_RECT )
	player.hudElems.FlagIcon.SetClampBounds( CL_HIGHLIGHT_ICON_X, CL_HIGHLIGHT_ICON_Y )
	//player.hudElems.FlagIcon.SetADSFade( deg_cos( 5 ), deg_cos( 2 ), 0, 1 )

	player.hudElems.FlagLabel.SetClampToScreen( CLAMP_RECT )
	player.hudElems.FlagLabel.SetClampBounds( CL_HIGHLIGHT_LABEL_X, CL_HIGHLIGHT_LABEL_Y )
	//player.hudElems.FlagLabel.SetADSFade( deg_cos( 5 ), deg_cos( 2 ), 0, 1 )

	player.hudElems.HomeIcon.SetClampToScreen( CLAMP_RECT )
	player.hudElems.HomeIcon.SetClampBounds( CL_HIGHLIGHT_ICON_X, CL_HIGHLIGHT_ICON_Y )

	player.hudElems.HomeLabel.SetClampToScreen( CLAMP_RECT )
	player.hudElems.HomeLabel.SetClampBounds( CL_HIGHLIGHT_LABEL_X, CL_HIGHLIGHT_LABEL_Y )
	player.hudElems.HomeLabel.SetFOVFade( deg_cos( 45 ), deg_cos( 40 ), 0, 1 )

	//player.hudElems.HomeLabel.SetADSFade( deg_cos( 5 ), deg_cos( 2 ), 0, 1 )

	if ( GetGameState() != eGameState.Playing )
		player.hudElems.HomeIcon.Hide()

	player.s.friendlyFlagState <- null
	player.s.enemyFlagState <- null
	player.s.lastCTTRiderEnt <- null
	player.s.lastCTTCaptureEndTime <- 0
	player.s.lastCTTState <- CTT_STATE_NONE

	player.s.friendlyFlagCarrierName <- null
	player.s.enemyFlagCarrierName <- null

	thread CTTHudThink( player )
}

function CTTHudThink( player )
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

	if ( GetTitanFromFlag( flagEnt ).IsPlayer() )
		return eFlagState.Held

	if ( IsTitanFlagHome( flagEnt ) )
		return eFlagState.Home

	return eFlagState.Away
}


function UpdateFlag( player, flagEnt )
{
	local newFlagState = GetTitanFlagState( flagEnt )

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

	player.hudElems.HomeIcon.SetEntityOverhead( level.flagReturnPoint, Vector( 0, 0, 64 ), 0.5, 1.0 )
	player.hudElems.HomeLabel.SetEntityOverhead( level.flagReturnPoint, Vector( 0, 0, 64 ), 0.5, 0.25 )

	local isPlayerTitanFlag = PlayerIsTitanFlag( player )
	local newCTTSTate = CTT_STATE_NONE

	if ( isPlayerTitanFlag )
	{
		local hasEnemyRider = HasEnemyRiderEnt( player )
		local isCapturing = level.nv.cttPlayerCaptureEndTime < 90000 && level.nv.cttPlayerCaptureEndTime > Time()

		if ( hasEnemyRider )
			newCTTSTate = CTT_STATE_RODEO
		else if ( isCapturing )
			newCTTSTate = CTT_STATE_CAPPING
		else
			newCTTSTate = CTT_STATE_TITAN

		if ( newCTTSTate != player.s.lastCTTState )
		{
			if ( newCTTSTate == CTT_STATE_RODEO )
				SetEventNotification( "#GAMEMODE_YOU_HAVE_THE_TITAN_RODEO" )
			else if ( newCTTSTate == CTT_STATE_CAPPING )
				SetTimedEventNotificationHATT( level.nv.cttPlayerCaptureEndTime, "#GAMEMODE_CAPTURING_IN", HATT_GAME_COUNTDOWN_SECONDS_MILLISECONDS, level.nv.cttPlayerCaptureEndTime )
			else
				SetEventNotification( "#GAMEMODE_YOU_HAVE_THE_TITAN" )
		}
	}

	player.s.lastCTTState = newCTTSTate

	switch ( newFlagState )
	{
		case eFlagState.None:
			player.hudElems.FlagIcon.Hide()
			player.hudElems.FlagArrow.Hide()
			player.hudElems.FlagLabel.Hide()
			player.hudElems.FlagLabel.SetText( "" )
			player.hudElems.HomeIcon.Hide()
			player.hudElems.HomeLabel.Hide()
			break

		case eFlagState.Home:
			if ( isFriendlyTeam )
			{
				player.hudElems.FlagIcon.SetImage( "HUD/ctf_flag_friendly_notext" )
				player.hudElems.FlagLabel.SetText( "#GAMEMODE_FLAG_CAPTURE" )

				player.hudElems.HomeIcon.SetImage( "HUD/ctf_flag_enemy_away" )
				player.hudElems.HomeIcon.Show()

				player.hudElems.HomeLabel.SetAutoTextVector( "#HUD_DISTANCE_METERS", HATT_DISTANCE_METERS, level.flagReturnPoint.GetOrigin() )
				player.hudElems.HomeLabel.Show()
			}
			else
			{
				player.hudElems.FlagIcon.SetImage( "HUD/ctf_flag_enemy_notext" )
				player.hudElems.FlagLabel.SetText( "#GAMEMODE_FLAG_ATTACK" )

				player.hudElems.HomeIcon.SetImage( "HUD/ctf_flag_enemy_away" )
				player.hudElems.HomeIcon.Show()
				player.hudElems.HomeLabel.SetText( "#GAMEMODE_FLAG_GUARD" )
				player.hudElems.HomeLabel.Show()
			}
			break

		case eFlagState.Held:
			if ( isFriendlyTeam )
			{
				if ( PlayerIsTitanFlag( player ) )
				{
					player.hudElems.HomeLabel.SetText( "#GAMEMODE_FLAG_CAPTURE" )
					player.hudElems.HomeIcon.SetImage( "HUD/ctf_flag_friendly_missing" )
					player.hudElems.FlagArrow.Hide()
					player.hudElems.FlagIcon.Hide()
					player.hudElems.FlagLabel.Hide()
				}
				else
				{
					player.hudElems.FlagIcon.SetImage( "HUD/ctf_flag_friendly_notext" )
					player.hudElems.FlagLabel.SetText( "#GAMEMODE_FLAG_ESCORT" )
				}
			}
			else
			{
				player.hudElems.FlagIcon.SetImage( "HUD/ctf_flag_enemy_notext" )
				player.hudElems.FlagLabel.SetText( "#GAMEMODE_FLAG_ATTACK" )

				player.hudElems.HomeIcon.SetImage( "HUD/ctf_flag_enemy_away" )
				player.hudElems.HomeIcon.Show()
				player.hudElems.HomeLabel.SetText( "#GAMEMODE_FLAG_GUARD" )
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


function CTT_TitanSoulChanged()
{
	if ( !level.nv.cttTitanSoul )
	{
		printt( "CTT_TitanSoulChanged NO SOUL" )
		return
	}

	local soul = GetEntityFromEncodedEHandle( level.nv.cttTitanSoul )
	if ( !IsValid( soul ) )
	{
		printt( "CTT_TitanSoulChanged NO VALID SOUL" )
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