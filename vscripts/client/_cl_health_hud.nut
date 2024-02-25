const HEALTHDMGSTATE1_MP = 0.75
const HEALTHDMGSTATE2_MP = 0.50
const HEALTHDMGSTATE3_MP = 0.375

const SHOW_HEALTH_THRESHOLD_SP = 90  // don't show nearby health items if player health is above this value (100 health max)
const SHOW_HEALTH_MAXDIST_SP = 2048
const SHOW_HEALTH_VIEWDOT_SP = 0.5
const SHOW_HEALTH_SPRITESCALE_SP = 0.125

const SHOW_HEALTH_THRESHOLD_MP = 90
const SHOW_HEALTH_MAXDIST_MP = 2048
const SHOW_HEALTH_VIEWDOT_MP = 0.5
const SHOW_HEALTH_SPRITESCALE_MP = 0.125

const SHOW_HEALTH_REFRESHWAIT = 1.0

function main()
{
	Globalize( HealthHUD_AddPlayer )
	Globalize( HealthHUD_Update )
	Globalize( ServerCallback_PilotEMP )
	Globalize( PilotEMP_Internal )
	Globalize( HealthHUD_ClearFX )
	Globalize( ServerCallback_SpiderSense )

	file.colorCorrection <- ColorCorrection_Register( "materials/correction/bw_super_constrast.raw" )
	ColorCorrection_SetExclusive( file.colorCorrection, false )

	PrecacheParticleSystem( "P_health_hex" )
	file.healthFX <- GetParticleSystemIndex( "P_health_hex" )

	RegisterSignal( "End_HealthHUD_Update" )
	RegisterSignal( "EMPScreenFX" )

	AddKillReplayStartedCallback( KillReplayHealthUpdate )
}


function ServerCallback_PilotEMP( maxValue, duration, fadeTime, doFlash = true, doSound = true )
{
	thread PilotEMP_Internal( maxValue, duration, fadeTime, doFlash, doSound )
}


function PilotEMP_Internal( maxValue, duration, fadeTime, doFlash = true, doSound = true )
{
	local player = GetLocalViewPlayer()

	player.EndSignal( "OnDeath" )
	player.Signal( "EMPScreenFX", { maxValue = maxValue, duration = duration, fadeTime = fadeTime } )

	OnThreadEnd(
		function() : ( player )
		{
			//player.hudElems.EMPScreenFX.Hide()
		}
	)

	//player.hudElems.EMPScreenFX.Show()
	player.hudElems.EMPScreenFX.SetAlpha( maxValue * 255 )
	player.hudElems.EMPScreenFX.FadeOverTimeDelayed( 0, fadeTime, duration )

	if ( doFlash )
	{
		player.hudElems.EMPScreenFlash.Show()
		player.hudElems.EMPScreenFlash.SetAlpha( 255 )
		player.hudElems.EMPScreenFlash.FadeOverTimeDelayed( 0, min( 0.5, duration ), 0 )
	}

	if ( doSound )
	{
		EmitSoundOnEntity( player, EMP_IMPARED_SOUND )
		wait duration
		FadeOutSoundOnEntity( player, EMP_IMPARED_SOUND, fadeTime )
		wait fadeTime
	}
}


function FlashBang_Update( player, origin, maxValue, duration )
{
	local totalDuration = duration
	while ( duration > 0 )
	{
		local dist = Distance( player.GetOrigin(), origin )

		local fadeValue = GraphCapped( dist, 0.0, 768, maxValue, 0.0 )
		player.hudElems.EMPScreenFX.SetAlpha( fadeValue * 255 )

		wait 0
		duration -= FrameTime()
	}
}

function FlashBang_TonemappingUpdate()
{
	const START_DURATION = 4.0
	const TONEMAP_MAX = 50//25
	const TONEMAP_MIN = 5

	while ( 1 )
 	{
 		if ( !GetLocalViewPlayer().s.inTitanCockpit )
 			break;
 		wait 0
 	}

	//SetCockpitLightingEnabled( 0, false );
	ResetTonemapping( 0, TONEMAP_MAX )

	wait 0.15

//	TitanDisembarkDSP( 0.5 )

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


function HealthHUD_AddPlayer( player )
{
	player.InitHudElem( "damageOverlayRedBloom" )
	player.InitHudElem( "damageOverlayOrangeBloom" )
	player.InitHudElem( "damageOverlayLightLines" )
	player.InitHudElem( "damageOverlaySpiderSense" )
	player.hudElems.damageOverlaySpiderSense.Hide()

	player.InitHudElem( "EMPScreenFX" )
	player.InitHudElem( "EMPScreenFlash" )

	player.s.healthFX <- []

	player.EnableHealthChangedCallback()

	thread SettingsChange_Update( player )
}

function SettingsChange_Update( player )
{
	player.EndSignal( "OnDestroy" )

	player.hudElems.damageOverlayRedBloom.Hide()
	player.hudElems.damageOverlayOrangeBloom.Hide()
	player.hudElems.damageOverlayLightLines.Hide()

	while ( true )
	{
		switch( player.GetPlayerClass() )
		{
			case level.pilotClass:
				thread HealthHUD_Update( player )
				break
			default:
				player.Signal( "End_HealthHUD_Update" )
				player.hudElems.damageOverlayRedBloom.Hide()
				player.hudElems.damageOverlayOrangeBloom.Hide()
				player.hudElems.damageOverlayLightLines.Hide()
		}

		player.WaitSignal( "SettingsChanged" )
	}
}


function HealthHUD_Update( player )
{
	player.EndSignal( "End_HealthHUD_Update" )

	local healthFrac = GetHealthFrac( player )
	if ( healthFrac < 1.0 )
		DamageOverlayUpdate( player, healthFrac, 1.0 )

	local lastHealthFrac = GetHealthFrac( player )
	while ( true )
	{
		player.WaitSignal( "HealthChanged" )

		if ( IsWatchingKillReplay() && GetLocalViewPlayer() == GetLocalClientPlayer() )
			continue

		local healthFrac = GetHealthFrac( player )
		DamageOverlayUpdate( player, healthFrac, lastHealthFrac )
		lastHealthFrac = healthFrac
	}
}

function KillReplayHealthUpdate()
{
	local player = GetLocalClientPlayer()

	if ( GetLocalClientPlayer() != GetLocalViewPlayer() )
		return

	player.hudElems.damageOverlayRedBloom.Hide()
	player.hudElems.damageOverlayOrangeBloom.Hide()
	player.hudElems.damageOverlayLightLines.Hide()
}


function HealthHUD_ClearFX( player )
{
	if ( !( "healthFX" in player.s ) )
		return

	for ( local index = player.s.healthFX.len(); index > 0; index-- )
	{
		local fxHandle = player.s.healthFX[index - 1]

		if ( EffectDoesExist( fxHandle ) )
			EffectStop( fxHandle, false, true )

		player.s.healthFX.remove( index - 1 )
	}
}


function DamageOverlayUpdate( player, healthFrac, lastHealthFrac )
{
	if ( healthFrac <= 0 )
	{
		if ( lastHealthFrac > 0 )
		{
			local bloomFracR = GraphCapped( healthFrac, 1.0, 0.5, 0, 160 ).tointeger()
			local bloomFracGB = GraphCapped( healthFrac, 0.5, 0.0, bloomFracR, 48 ).tointeger()
			player.hudElems.damageOverlayRedBloom.ColorOverTime( bloomFracR, bloomFracGB, bloomFracGB, 255, 0.25 )
			player.hudElems.damageOverlayOrangeBloom.ColorOverTime( bloomFracR, bloomFracGB, bloomFracGB, 255, 0.25 )

			local lightLinesFrac = GraphCapped( healthFrac, 0.65, 0.35, 0, 255 ).tointeger()
			player.hudElems.damageOverlayLightLines.ColorOverTime( lightLinesFrac, lightLinesFrac, lightLinesFrac, 255, 0.25 )

			player.hudElems.damageOverlayRedBloom.Show()
			player.hudElems.damageOverlayOrangeBloom.Show()
			player.hudElems.damageOverlayLightLines.Show()
		}
		HealthHUD_ClearFX( player )
		return
	}
	else if ( healthFrac == 1.0 )
	{
		player.hudElems.damageOverlayRedBloom.Hide()
		player.hudElems.damageOverlayOrangeBloom.Hide()
		player.hudElems.damageOverlayLightLines.Hide()
	}
	else if ( lastHealthFrac == 1.0 )
	{
		player.hudElems.damageOverlayRedBloom.SetColor( 0, 0, 0 )
		player.hudElems.damageOverlayOrangeBloom.SetColor( 0, 0, 0 )
		player.hudElems.damageOverlayLightLines.SetColor( 0, 0, 0 )

		player.hudElems.damageOverlayRedBloom.Show()
		player.hudElems.damageOverlayOrangeBloom.Show()
		player.hudElems.damageOverlayLightLines.Show()
	}

	for ( local index = player.s.healthFX.len(); index > 0; index-- )
	{
		if ( !EffectDoesExist( player.s.healthFX[index - 1] ) )
		{
			player.s.healthFX.remove( index - 1 )
		}
	}

	while ( player.s.healthFX.len() > 10 )
	{
		local fxHandle = player.s.healthFX.remove( 0 )

		if ( EffectDoesExist( fxHandle ) )
			EffectStop( fxHandle, false, false )
	}

	local cockpit = player.GetCockpit()
	if ( healthFrac < 0.9 && healthFrac < lastHealthFrac && cockpit )
	{
		local fxHandle = StartParticleEffectOnEntity( cockpit, file.healthFX, FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
		player.s.healthFX.append( fxHandle )

		local extraFx = abs( (lastHealthFrac - healthFrac) * 8 )
		for ( local index = 0; index < extraFx; index++ )
		{
			local fxHandle = StartParticleEffectOnEntity( cockpit, file.healthFX, FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
			player.s.healthFX.append( fxHandle )
		}
	}

	local bloomFracR = GraphCapped( healthFrac, 1.0, 0.7, 0, 220 ).tointeger()
	local bloomFracGB = GraphCapped( healthFrac, 0.7, 0.0, bloomFracR, 48 ).tointeger()
	player.hudElems.damageOverlayRedBloom.ColorOverTime( bloomFracR, bloomFracGB, bloomFracGB, 255, 0.25 )
	player.hudElems.damageOverlayOrangeBloom.ColorOverTime( bloomFracR, bloomFracGB, bloomFracGB, 255, 0.25 )

	local lightLinesFrac = GraphCapped( healthFrac, 0.99, 0.84, 0, 255 ).tointeger()
	player.hudElems.damageOverlayLightLines.ColorOverTime( lightLinesFrac, lightLinesFrac, lightLinesFrac, 255, 0.25 )
}

function ServerCallback_SpiderSense()
{
	local player = GetLocalViewPlayer()
	
	if ( !IsValid( player ) )
		return

	player.hudElems.damageOverlaySpiderSense.ReturnToBaseColor()
	player.hudElems.damageOverlaySpiderSense.ColorOverTime( 0, 0, 0, 255, 0.75 )
	player.hudElems.damageOverlaySpiderSense.Show()
}