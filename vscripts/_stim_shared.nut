PrecacheParticleSystem( "P_heal" )
PrecacheParticleSystem( "P_pilot_stim_hld" )


function main()
{
	Globalize( StimPlayer )
}

function StimPlayer( player, duration )
{
	if ( IsServer() )
	{
		SetHealUseTime( player, duration )
		thread StimThink( player, duration )
	}
	else
	{
		local cockpit = player.GetCockpit()
		if ( !IsValid( cockpit ) )
			return

		HealthHUD_ClearFX( player )
		local fxHandle = StartParticleEffectOnEntity( cockpit, GetParticleSystemIndex( "P_heal" ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
		thread StimScreenFXThink( player, fxHandle, duration, cockpit )
	}
}


if ( IsServer() )
{

	function StimThink( player, duration )
	{
		player.EndSignal( "OnDestroy" )
		player.EndSignal( "OnDeath" )
		player.EndSignal( "Disconnected" )
		player.EndSignal( "OnChangedPlayerClass" )

		GiveServerFlag( player, SFLAG_STIM_OFFHAND )

		// stim speed controlled by:
		// ABILITY_STIM_SPEED_MOD
		player.UpdateMoveSpeedScale()

		EmitSoundOnEntity( player, "Pilot_Stimpack_Loop" )

		local effect = CreateEntity( "info_particle_system" )
		effect.kv.effect_name = "P_pilot_stim_hld"
		effect.kv.start_active = 1
		effect.SetOwner( player )
		effect.SetParent( player, "CHESTFOCUS" )
		effect.kv.VisibilityFlags = 6 // not owner only
		effect.SetStopType( "destroyImmediately" )

		DispatchSpawn( effect, false )

		OnThreadEnd(
			function() : ( player, effect )
			{
				if ( !IsValid( player ) )
					return

				if ( IsValid( effect ) )
					effect.Destroy()

				StopSoundOnEntity( player, "Pilot_Stimpack_Loop" )

				TakeServerFlag( player, SFLAG_STIM_OFFHAND )
				player.UpdateMoveSpeedScale()
			}
		)

		if ( duration == USE_TIME_INFINITE )
			WaitForever()

		wait duration - 2.0

		EmitSoundOnEntity( player, "Pilot_Stimpack_Deactivate" )

		wait 2.0
	}
}
else
{
	function StimScreenFXThink( player, fxHandle, duration, cockpit )
	{
		player.EndSignal( "OnDeath" )
		player.EndSignal( "OnDestroy" )
		cockpit.EndSignal( "OnDestroy" )

		OnThreadEnd(
			function() : ( fxHandle )
			{
				if ( !EffectDoesExist( fxHandle ) )
					return

				EffectStop( fxHandle, false, true )
			}
		)

		if ( duration == USE_TIME_INFINITE )
		{
			for ( ;; )
			{
				local velocityX = player.GetVelocity().Length()

				if ( !EffectDoesExist( fxHandle ) )
					break

				velocityX = GraphCapped( velocityX, 0.0, 360, 5, 200 )
				EffectSetControlPointVector( fxHandle, 1, Vector( velocityX, 999, 0 ) )
				wait 0
			}
		}
		else
		{
			local startTime = Time()
			local endTime = startTime + duration

			while ( Time() <= endTime && EffectDoesExist( fxHandle ) )
			{
				local velocityX = player.GetVelocity().Length()

				if ( !EffectDoesExist( fxHandle ) )
					break

				velocityX = GraphCapped( velocityX, 0.0, 360, 5, 200 )
				EffectSetControlPointVector( fxHandle, 1, Vector( velocityX, duration, 0 ) )
				wait 0
			}
		}
	}
}