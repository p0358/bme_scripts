
function main()
{
	IncludeFile( "_riff_floor_is_lava_shared" )
	IncludeFile( "_riff_floor_is_lava_dialogue" )

	PrecacheParticleSystem( "P_inlava_pilot" )
	PrecacheParticleSystem( "P_inlava_xo" )
	PrecacheParticleSystem( "P_inlava_xo_screen" )

	AddCreateCallback( "player", FloorIsLavaPlayerCreated )
	AddCreateCallback( "npc_titan", FloorIsLavaTitanCreated )
	AddDestroyCallback( "npc_titan", FloorIsLavaTitanDestroyed )

	file.lethalFogHeight <- GetFogHeight()
	file.lethalFogTopTitan <- GetLethalFogTopTitan()
	file.lethalFogTop <- GetLethalFogTop()

	file.players <- []
	file.titans <- {}
	file.fxProps <- []

	file.voLastPlayedTime <- { pilot = -999.0, titan = -999.0 }
	file.voDebounceTime <- { pilot = [ 0.0, 30.0, 60.0, 120.0 ], titan = [ 0.0, 30.0, 60.0, 120.0 ] }
	file.voNumPlays <- { pilot = 0, titan = 0 }

	file.inLavaSizzle1P_Pilot <- "Flesh.LavaFog.Sizzle_1P"
	file.inLavaSizzle3P_Pilot <- "Flesh.LavaFog.Sizzle_3P"
	file.inLavaSizzleEnd1P_Pilot <- "Flesh.LavaFog.Sizzle_End_1P"
	file.inLavaSizzleEnd3P_Pilot <- "Flesh.LavaFog.Sizzle_End_3P"
	file.inLavaZap1P_Pilot <- "Flesh.LavaFog.Zap_1P"
	file.inLavaZap3P_Pilot <- "Flesh.LavaFog.Zap_3P"
	file.inLavaDeathZap1P_Pilot <- "Flesh.LavaFog.DeathZap_1P"
	file.inLavaDeathZap3P_Pilot <- "Flesh.LavaFog.DeathZap_3P"

	file.inLavaSizzle1P_Titan <- "Titan.LavaFog.Sizzle_1P"
	file.inLavaSizzle3P_Titan <- "Titan.LavaFog.Sizzle_3P"
	file.inLavaSizzleEnd1P_Titan <- "Titan.LavaFog.Sizzle_End_1P"
	file.inLavaSizzleEnd3P_Titan <- "Titan.LavaFog.Sizzle_End_3P"
	file.inLavaZap3P_Titan <- "Titan.LavaFog.Zap_3P"
	file.inLavaDeathZap1P_Titan <- "Titan.LavaFog.DeathZap_1P"
	file.inLavaDeathZap3P_Titan <- "Titan.LavaFog.DeathZap_3P"

	RegisterServerVarChangeCallback( "gameStartTime", PlayLavaAnnouncement )
}

function EntitiesDidLoad()
{
	InitFXProps()
	thread FogFXThink()
	file.voFirstPlayDelay <- Time() + 60.0
}

function FloorIsLavaPlayerCreated( player, isRecreate )
{
	player.s.inLavaFog <- false
}

function FloorIsLavaTitanCreated( titan, isRecreate )
{
	titan.s.inLavaFog <- false
	file.titans[ titan ] <- titan
}

function FloorIsLavaTitanDestroyed( titan )
{
	delete file.titans[ titan ]
}

function InitFXProps()
{
	for ( local i = 0; i < 32; i++ )
	{
		local prop = CreateClientSidePropDynamic( Vector( 0.0, 0.0, 0.0 ), Vector( 0.0, 0.0, 0.0 ), "models/dev/empty_model.mdl" )
		prop.s.inUse <- false
		prop.s.fx <- null
		prop.s.fxCockpit <- null
		file.fxProps.append( prop )
	}
}

function GetFXProp()
{
	local prop = null

	foreach ( prop in file.fxProps )
	{
		if ( !prop.s.inUse )
		{
			prop.s.inUse = true
			return prop
		}
	}

	Assert( prop != null )

	return prop
}

function EntEnteredFog( ent )
{
	ent.EndSignal( "OnDestroy" )
	ent.EndSignal( "OnDeath" )
	ent.EndSignal( "SettingsChanged" )

	local prop = GetFXProp()
	local isTitan = ent.IsTitan()
	local titanSoul = null
	local isLocalViewPlayer = ( ent == GetLocalViewPlayer() )
	local controlPointOffset = Vector( 0.0, 0.0, 0.0 )

	thread TryToPlayWarningVO( ent )

	OnThreadEnd(
		function() : ( ent, prop, isLocalViewPlayer, isTitan )
		{
			prop.s.inUse = false

			if ( prop.s.fx != null )
				EffectStop( prop.s.fx, false, true )
			prop.s.fx = null

			if ( prop.s.fxCockpit != null )
				EffectStop( prop.s.fxCockpit, false, true )
			prop.s.fxCockpit = null

			if ( isLocalViewPlayer )
			{
				StopSoundOnEntity( ent, isTitan ? file.inLavaSizzle1P_Titan : file.inLavaSizzle1P_Pilot )
				EmitSoundOnEntity( ent, isTitan ? file.inLavaSizzleEnd1P_Titan : file.inLavaSizzleEnd1P_Pilot )

				if ( !IsAlive( ent ) && IsValid( ent ) )
					EmitSoundOnEntity( ent, file.inLavaDeathZap1P_Pilot )
			}
			else
			{
				StopSoundOnEntity( ent, isTitan ? file.inLavaSizzle3P_Titan : file.inLavaSizzle3P_Pilot )
				EmitSoundOnEntity( ent, isTitan ? file.inLavaSizzleEnd3P_Titan : file.inLavaSizzleEnd3P_Pilot )

				if ( !IsAlive( ent ) && IsValid( ent ) )
					EmitSoundOnEntity( ent, isTitan ? file.inLavaDeathZap3P_Titan : file.inLavaDeathZap3P_Pilot )
			}

			ent.s.inLavaFog = false
		}
	)

	if ( isLocalViewPlayer )
		EmitSoundOnEntity( ent, isTitan ? file.inLavaSizzle1P_Titan : file.inLavaSizzle1P_Pilot )
	else
		EmitSoundOnEntity( ent, isTitan ? file.inLavaSizzle3P_Titan : file.inLavaSizzle3P_Pilot )

	local entOrg = ent.GetOrigin()
	local fx = isTitan ? "P_inlava_xo" : "P_inlava_pilot"

	prop.s.fx = StartParticleEffectOnEntity( prop, GetParticleSystemIndex( fx ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
	if ( isTitan && isLocalViewPlayer )
		prop.s.fxCockpit = StartParticleEffectOnEntity( GetLocalViewPlayer().GetCockpit(), GetParticleSystemIndex( "P_inlava_xo_screen" ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )

	local lastZapTime = Time()
	local nextZapDelay = 0.67

	while ( true )
	{
		entOrg = ent.GetOrigin()
		if ( IsInLava( ent ) != true )
			return

		if ( isTitan )
		{
			if ( ent.IsPlayer() )
			{
				controlPointOffset = ent.IsCrouched() ? Vector( 0.0, 0.0, 100.0 ) : Vector( 0.0, 0.0, 160.0 )
			}
			else
			{
				controlPointOffset = Vector( 0.0, 0.0, 160.0 )

				titanSoul = ent.GetTitanSoul()
				if ( IsValid( titanSoul ) && titanSoul.GetStance() < 2 )
					controlPointOffset = Vector( 0.0, 0.0, 100.0 )
			}

			if ( prop.s.fx != null && prop.s.fx > 0 )
				EffectSetControlPointVector( prop.s.fx, 1, entOrg + controlPointOffset )
		}
		else
		{
			controlPointOffset = ent.IsCrouched() ? Vector( 0.0, 0.0, 15.0 ) : Vector( 0.0, 0.0, 30.0 )
			if ( prop.s.fx != null && prop.s.fx > 0 )
				EffectSetControlPointVector( prop.s.fx, 1, entOrg + controlPointOffset )
		}

		prop.SetOrigin( Vector( entOrg.x, entOrg.y, file.lethalFogHeight ) )

		if ( Time() - lastZapTime > nextZapDelay )
		{
			nextZapDelay = isTitan ? RandomFloat( 0.67, 4.0 ) : 0.67

			if ( isLocalViewPlayer )
		{
			if ( !isTitan )
					EmitSoundOnEntity( ent, file.inLavaZap1P_Pilot )
			}
			else
			{
					EmitSoundOnEntity( ent, isTitan ? file.inLavaZap3P_Titan : file.inLavaZap3P_Pilot )
			}

			lastZapTime = Time()
		}

		wait( 0.0 )
	}
}

function FogFXThink()
{
	while( GetGameState() < eGameState.Playing )
	{
		wait 0.0
	}

	while ( true )
	{
		file.players = GetPlayerArray()

		foreach ( player in file.players )
		{
			if ( ShouldStartFogFXAndVO( player ) )
			{
				player.s.inLavaFog = true
				thread EntEnteredFog( player )
			}
		}

		foreach ( titan in file.titans )
		{
			if ( ShouldStartFogFXAndVO( titan ) )
			{
				titan.s.inLavaFog = true
				thread EntEnteredFog( titan )
			}
		}
		wait( 0.0 )
	}
}

function ShouldStartFogFXAndVO( ent )
{
	if ( !IsAlive( ent ) )
		return false

	if ( ent.s.inLavaFog )
		return false

	return IsInLava( ent )
}

function IsInLava( ent )
{
	if ( IsEntInSafeVolume( ent ) == true )
		return false

	if ( IsEntInLethalVolume( ent ) == true )
		return true

	if ( ent.IsTitan() )
	{
		if ( ent.GetOrigin().z > file.lethalFogTopTitan )
			return false
	}
	else
	{
		if ( ent.GetOrigin().z > file.lethalFogTop )
			return false
	}

	//Don't play effect if ent is inside evac dropship. Somewhat hacky way of checking it
	local entParent = ent.GetParent()

	if ( IsValid ( entParent ) && entParent.IsDropship() )
		return false

	return true
}

function TryToPlayWarningVO( ent )
{
	ent.EndSignal( "OnDestroy" )
	ent.EndSignal( "OnDeath" )
	ent.EndSignal( "SettingsChanged" )

	wait 1.0 //Give it slight delay before telling you you are in lava

	local isTitan = ent.IsTitan()

	if ( ent == GetLocalClientPlayer() && ShouldPlayWarningVO( ent ) )
	{
		local idx = isTitan ? "titan" : "pilot"

		if ( file.voNumPlays[ idx ] < 3 )
			file.voNumPlays[ idx ]++
		file.voLastPlayedTime[ idx ] = Time()

		local conv = isTitan ? "floor_is_laval_titan_in_lava" : "floor_is_laval_pilot_in_lava"
		PlayConversationToLocalClient( conv )
	}
}


function ShouldPlayWarningVO( player )
{
	if ( IsForcedDialogueOnly( player ) )
		return false

	local time = Time()
	local idx = player.IsTitan() ? "titan" : "pilot"

	if ( time < file.voFirstPlayDelay )
		return false

	if ( time < file.voLastPlayedTime[ idx ] + file.voDebounceTime[ idx ][ file.voNumPlays[ idx ] ] )
		return false


	return true

}

function PlayLavaAnnouncement()
{
	if ( !GetClassicMPMode() )
		return

	if ( GetGameState() != eGameState.Prematch )
		return

	if ( !level.nv.gameStartTime )
		return

	local player = GetLocalClientPlayer()

	local announcement = CAnnouncement( "#GAMEMODE_FLOOR_IS_LAVA" )
	announcement.SetSubText( "#GAMEMODE_FLOOR_IS_LAVA_SUBTEXT" )
	local announcementDuration = 7.5
	announcement.SetDuration( announcementDuration )
	AnnouncementFromClass( player, announcement )
}