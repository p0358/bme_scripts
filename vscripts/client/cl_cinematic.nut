const DEBUGHEADLOOK = 0

function main()
{
	FlagInit( "RetrievedEventStateFunctions" )

	Globalize( ServerCallback_PlayerCinematicDone )

	Globalize( AddCinematicEventClientFunc )
	Globalize( ServerCallback_AddCinematicEventClientFunc )
	Globalize( ServerCallback_CinematicFuncInitComplete )
	Globalize( ServerCallback_ResetRefSkyScale )
	Globalize( CE_SetSunLightAngles )
	Globalize( CE_ResetSunLightAngles )
	Globalize( CE_SetSunSkyLightScales )
	Globalize( CE_ResetSunSkyLightScales )
	Globalize( CE_VisualSettingsSpace )
	Globalize( CE_VisualSettingsDropshipInterior )
	Globalize( CE_ResetVisualSettings )
	Globalize( CE_BloomOnRampOpen )

	Globalize( CinematicTonemappingThread )
	Globalize( ClientCodeCallback_OnCinematicEventRefChanged )
	Globalize( ClientCodeCallback_OnDropShipCinematicEventStateChanged )

	RegisterSignal( "PlayerCinematicDone" )
	RegisterSignal( "KillLastEventClientCall" )

	AddCreateCallback( "player", InitPlayerEventStates )
}

function EntitiesDidLoad()
{

}

function InitPlayerEventStates( player, isRecreate )
{
	if ( "cinematicEventClientFuncs" in player.s )
		return

	player.s.cinematicEventClientFuncs <- {}
	player.s.executedEventStates <- []
}

function ClientCodeCallback_OnCinematicEventRefChanged( player )
{
	if ( !IsValid( player ) )
		return
	thread RunCinematicEventClientFuncs( player, player.GetCinematicEventRef() )
}

function ClientCodeCallback_OnDropShipCinematicEventStateChanged( npc_dropship )
{
	if ( !IsValid( npc_dropship ) )
		return
	thread RunCinematicEventClientFuncs( GetLocalViewPlayer(), npc_dropship )
}

function RunCinematicEventClientFuncs( player, ref )
{
	/*Do these before the endsignals so that bad refs don't kill the good ref call.*/
	//are both the player and ref valid
	if ( !IsValid( player ) )
		return
	if ( !IsValid( ref ) )
		return
	//is the players cinematicEventRef this ref
	if ( player.GetCinematicEventRef() != ref )
		return

	//this is really only for when the player first connects to insure he has all the data
	player.Signal( "KillLastEventClientCall" )
	player.EndSignal( "KillLastEventClientCall" )
	FlagWait( "RetrievedEventStateFunctions" )

	/*Do these checks again to make sure everything is still kosher.*/
	//are both the player and ref valid
	if ( !IsValid( player ) )
		return
	if ( !IsValid( ref ) )
		return
	//is the players cinematicEventRef this ref
	if ( player.GetCinematicEventRef() != ref )
		return

	local eventState = ref.GetCinematicEventState()

	/*
	have we run this state already? there are edge cases where we JUST got added to the
	ref which will run whatever state it's in, and then the ref also JUST experience a
	state change, so that will cause this to run again. Sometimes in the exact same frame.
	*/
	foreach ( executedState in player.s.executedEventStates )
	{
		if ( executedState == eventState )
			return
	}

	if ( eventState in player.s.cinematicEventClientFuncs )
	{
		foreach ( func in player.s.cinematicEventClientFuncs[ eventState ] )
			thread func( player, ref )

		player.s.executedEventStates.append( eventState )
	}
}

function ServerCallback_AddCinematicEventClientFunc( eventState, handle )
{
	thread ServerCallback_AddCinematicEventClientFuncThread( eventState, handle )
}

function ServerCallback_AddCinematicEventClientFuncThread( eventState, handle )
{
	FlagWait( "CinematicFunctionsRegistered" )

	local player = GetLocalClientPlayer()
	local func = GetClientFunctionFromHandle( handle )
	AddCinematicEventClientFunc( player, eventState, func )
}

function ServerCallback_CinematicFuncInitComplete()
{
	FlagSet( "RetrievedEventStateFunctions" )
}

function AddCinematicEventClientFunc( player, eventState, func )
{
	if ( !( eventState in player.s.cinematicEventClientFuncs ) )
		player.s.cinematicEventClientFuncs[ eventState ] <- []

	foreach ( value in player.s.cinematicEventClientFuncs[ eventState ] )
	{
		//don't add duplicates
		if ( value == func )
			return
	}

	player.s.cinematicEventClientFuncs[ eventState ].append( func )
}

function ServerCallback_PlayerCinematicDone()
{
	local player = GetLocalViewPlayer()

	player.Signal( "PlayerCinematicDone" )
}

function CE_SetSunSkyLightScales( sunScale, skyScale )
{
	local clight = GetLightEnvironmentEntity()
	if ( clight )
		clight.ScaleSunSkyIntensity( sunScale, skyScale )
}

function CE_ResetSunSkyLightScales()
{
	local clight = GetLightEnvironmentEntity()
	if ( clight )
		clight.ScaleSunSkyIntensity( 1.0, 1.0 )
}

function CE_SetSunLightAngles( x, y )
{
	local clight = GetLightEnvironmentEntity()
	if ( clight )
		clight.OverrideAngles( x, y )
}

function CE_ResetSunLightAngles()
{
	local clight = GetLightEnvironmentEntity()
	if ( clight )
		clight.UseServerAngles()
}

function CE_VisualSettingsSpace( player, ref )
{
	SetMapSetting_BloomScale( 4.0 )
	SetMapSetting_FogEnabled( false )

	SetMapSetting_CsmTexelScale( 0.4, 0.125 )

	ref.LerpSkyScale( SKYSCALE_SPACE, 0.01 )
}

function CE_VisualSettingsDropshipInterior( player, ref )
{
	CE_ResetVisualSettings( player )

	ref.LerpSkyScale( SKYSCALE_FRACTURE_WARP, 0.01 )
}

function CE_ResetVisualSettings( player, ref = null )
{
	SetMapSetting_BloomScale( 1.0 )
	SetMapSetting_FogEnabled( true )

	SetMapSetting_CsmTexelScale( 1.0, 1.0 )

	CE_ResetSunLightAngles()
	CE_ResetSunSkyLightScales()
}

function ServerCallback_ResetRefSkyScale( handle )
{
	local ref = GetEntityFromEncodedEHandle( handle )
	if ( !IsValid( ref ) )
		return
	ref.LerpSkyScale( SKYSCALE_DEFAULT, 1.0 )
}

function CE_BloomOnRampOpen( player, ref )
{
	AddAnimEvent( ref, "cl_ramp_open", TonemappingOnDoorOpen )
}

function TonemappingOnDoorOpen( ref )
{
	ref.LerpSkyScale( SKYSCALE_DEFAULT, 1.0 )
	thread CinematicTonemappingThread()
}

function CinematicTonemappingThread( toneMax = 20, toneMin = 2, rampUp = 0.1, rampDown = 0.75 )
{
	wait 0.2

	local START_DURATION = rampUp
	local TONEMAP_MAX = toneMin
	local TONEMAP_MIN = toneMax

	local startTime = Time()
	while( 1 )
	{
		local time = Time() - startTime
		local factor = GraphCapped( time, 0, START_DURATION, 1, 0 )
		factor = factor * factor * factor
		local toneMapScale = TONEMAP_MIN + (TONEMAP_MAX - TONEMAP_MIN) * factor
		ResetTonemapping( 0, toneMapScale )

		if ( factor == 0 )
			break;
		wait  0
	}

	local START_DURATION = rampDown
	local TONEMAP_MAX = toneMax
	local TONEMAP_MIN = toneMin

	local startTime = Time()
	while( 1 )
	{
		local time = Time() - startTime
		local factor = GraphCapped( time, 0, START_DURATION, 1, 0 )
		factor = factor * factor * factor
		local toneMapScale = TONEMAP_MIN + (TONEMAP_MAX - TONEMAP_MIN) * factor
		ResetTonemapping( 0, toneMapScale )

		if ( factor == 0 )
			break;
		wait  0
	}
}