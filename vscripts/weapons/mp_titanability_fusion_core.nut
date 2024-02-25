const EMP_BLAST_EFFECT = "P_titan_core_atlas_blast"
const EMP_BLAST_CHARGE_EFFECT = "P_titan_core_atlas_charge"
const EMP_CORE_EFFECT = "P_titan_core_atlas_blast"
const EMP_BLAST_RADIUS = 512

PrecacheParticleSystem( EMP_BLAST_CHARGE_EFFECT )
PrecacheParticleSystem( EMP_BLAST_EFFECT )
PrecacheParticleSystem( EMP_CORE_EFFECT )

function OnWeaponPrimaryAttack( attackParams )
{
	local ownerPlayer = self.GetWeaponOwner()
	thread PlayerUsedTitanCore( ownerPlayer )
	return 1
}

function PlayerUsedTitanCore( player )
{
	// shouldn't be possible for a dead player to use core but evidence leads us to believe that it can happen.
	if ( !IsAlive( player ) )
		return
	Assert( IsValid( player ) && player.IsPlayer() && player.IsTitan() )
	local soul = player.GetTitanSoul()
	if ( !IsValid( soul.GetTitan() ) )
		return

	if ( Time() < soul.GetNextCoreChargeAvailable() || player.GetDoomedState() )
	{
		if ( Time() > soul.GetCoreChargeExpireTime() && IsClient() )
			TitanCockpit_PlayDialog( player, "core_denied" )
		return
	}

	if ( IsClient() )
	{
		thread CoreActivatedVO( player )
		return
	}

	player.EndSignal( "Disconnected" )
	soul.EndSignal( "OnDeath" )
	soul.EndSignal( "OnDestroy" )
	soul.EndSignal( "OnTitanDeath" )
	soul.EndSignal( "Doomed" )

	local marathon = PlayerHasPassive( player, PAS_MARATHON_CORE )

	local coreDuration = GetTitanCoreActiveTime( player )
	local coreWaitTime = coreDuration + TITAN_CORE_CHARGE_TIME
	soul.SetCoreChargeExpireTime( Time() + coreWaitTime )
	soul.SetNextCoreChargeAvailable( Time() + 1000 )

	local passive
	local startSoulFunc, startPlayerFunc
	local endSoulFunc, endPlayerFunc

	switch ( GetSoulTitanType( soul ) )
	{
		case "ogre":
			passive = PAS_SHIELD_BOOST
			startSoulFunc = StartShieldCore
			break

		case "atlas":
			passive = PAS_FUSION_CORE
			startSoulFunc = StartDamageCore
			endSoulFunc = EndDamageCore
			break

		case "stryder":
			passive = PAS_FUSION_CORE
			startPlayerFunc = StartDashCore
			endPlayerFunc = EndDashCore
			break
	}

	SetCoreEffect( player, CreateChargeEffect )

	OnThreadEnd(
		function() : ( player, soul, passive, startSoulFunc, startPlayerFunc, endSoulFunc, endPlayerFunc )
		{
			if ( IsValid( soul ) )
			{
				local coreBuildTime = GetCurrentPlaylistVarInt( "titan_core_build_time", TITAN_CORE_BUILD_TIME )
				soul.SetNextCoreChargeAvailable( Time() + coreBuildTime )

				if ( passive != null )
					TakePassive( soul, passive )

				if ( endSoulFunc != null )
					endSoulFunc( soul )


				if ( "coreEffect" in soul.s && IsValid( soul.s.coreEffect.ent ) )
				{
					soul.s.coreEffect.ent.Kill()
				}

				delete soul.s.coreEffect

				local titan = soul.GetTitan()
				if ( IsValid( titan ) )
				{
					StopSoundOnEntity( titan, "Titan_CoreAbility_Sustain_Long" )
					StopSoundOnEntity( titan, "Titan_CoreAbility_Sustain" )
				}
			}

			if ( IsValid( player ) )
			{
				StopSoundOnEntity( player, EMP_BLAST_CHARGE_SOUND )
				if ( endPlayerFunc != null )
					endPlayerFunc( player )
			}
		}
	)

	local titan = soul.GetTitan()
	EmitSoundOnEntity( titan, EMP_BLAST_CHARGE_SOUND )

	wait TITAN_CORE_CHARGE_TIME

	if ( IsValid( titan ) )
		StopSoundOnEntity( titan, EMP_BLAST_CHARGE_SOUND )

	titan = soul.GetTitan()
	if ( !IsAlive( titan ) )
		return

	if ( !titan.IsTitan() )
		return

	if ( marathon )
		EmitSoundOnEntity( titan, "Titan_CoreAbility_Sustain_Long" )
	else
		EmitSoundOnEntity( titan, "Titan_CoreAbility_Sustain" )

	PhysicsBlast( titan )
	BlastScreenShake( titan )
	//PushEverythingAway( titan )

	SetCoreEffect( titan, CreateCoreEffect )

	if ( passive != null )
		GivePassive( soul, passive )

	// Shields start charging right away
	soul.s.nextRegenTime = Time()

	if ( startSoulFunc != null && IsValid( soul ) )
		startSoulFunc( soul )

	if ( IsAlive( player ) )
	{
		if ( startPlayerFunc != null )
			startPlayerFunc( player )

		if ( player.IsTitan() )
			thread CoreColorCorrection( player, soul, coreDuration )
	}

	wait coreDuration
}

function SetCoreEffect( titan, func )
{
	Assert( IsAlive( titan ) )
	Assert( titan.IsTitan() )
	local soul = titan.GetTitanSoul()
	local chargeEffect = func( titan )
	if ( "coreEffect" in soul.s )
	{
		soul.s.coreEffect.ent.Kill()
	}
	else
	{
		soul.s.coreEffect <- null
	}

	soul.s.coreEffect = { ent = chargeEffect, func = func }
}

////////////////////////////////////////////////////////////////////////
// custom core functions
////////////////////////////////////////////////////////////////////////

function StartShieldCore( soul )
{
	local health = soul.GetShieldHealthMax()
	soul.SetShieldHealth( health )
}

function StartDamageCore( soul )
{
	AddToTitanDamageScaling( soul, 1.4 )
}

function EndDamageCore( soul )
{
	ClearTitanDamageScaling( soul )
}

function EndDashCore( player )
{
	player.SetDodgePowerDelayScale( 1.0 )
	player.SetPowerRegenRateScale( 1.0 )
}

function StartDashCore( player )
{
	// Dash recharges fast
	player.SetDodgePowerDelayScale( 0.05 )
	player.SetPowerRegenRateScale( 16.0 )
}


////////////////////////////////////////////////////////////////////////
// core fx and color correction
////////////////////////////////////////////////////////////////////////
function CreateCoreEffect( player )
{
	Assert( player.IsTitan() )

	local chargeEffect = CreateEntity( "info_particle_system" )
	chargeEffect.kv.start_active = 1
	chargeEffect.kv.VisibilityFlags = 6 // everyone but owner
	chargeEffect.kv.effect_name = EMP_CORE_EFFECT
	chargeEffect.SetName( UniqueString() )
	chargeEffect.SetParent( player, "hijack", false, 0 )
	chargeEffect.SetOwner( player )
	DispatchSpawn( chargeEffect, false )
	return chargeEffect
}


function CreateChargeEffect( player )
{
	Assert( player.IsTitan() )

	local chargeEffect = CreateEntity( "info_particle_system" )
	chargeEffect.kv.start_active = 1
	chargeEffect.kv.VisibilityFlags = 6 // everyone but owner
	chargeEffect.kv.effect_name = EMP_BLAST_CHARGE_EFFECT
	chargeEffect.SetName( UniqueString() )
	chargeEffect.SetParent( player, "hijack", false, 0 )
	chargeEffect.SetOwner( player )
	DispatchSpawn( chargeEffect, false )
	return chargeEffect
}

function CoreColorCorrection( player, soul, duration )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "Disconnected" )
	player.EndSignal( "TitanEjectionStarted" )
	player.EndSignal( "SettingsChanged" )
	soul.EndSignal( "Doomed" )
	soul.EndSignal( "OnDestroy" )

	local colorCorrection	= GetColorCorrectionByFileName( player, "materials/correction/overdrive1.raw" )

	if ( !colorCorrection )
		return null

	local fadeInDuration = 0.5
	local fadeOutDuration = 0.5
	local colorTime = duration
	local maxweight = 1
	local isMaster = 0

	colorCorrection.kv.fadeInDuration = fadeInDuration
	colorCorrection.kv.fadeOutDuration = fadeOutDuration
	colorCorrection.kv.maxweight = maxweight
	colorCorrection.kv.spawnflags = isMaster

	colorCorrection.Fire( "Enable" )
	colorCorrection.Fire( "Disable", "", colorTime + fadeInDuration )

	OnThreadEnd(
		function() : ( colorCorrection )
		{
			if ( !IsValid( colorCorrection ) )
				return

			colorCorrection.Fire( "Disable" )
		}
	)

	wait duration + fadeInDuration + fadeOutDuration + 1.0
}


////////////////////////////////////////////////////////////////////////
// Core-start effect functions
////////////////////////////////////////////////////////////////////////


function PhysicsBlast( titan )
{
	// Physics explosion
	local knockback = CreateEntity( "env_physexplosion" )
	knockback.kv.magnitude = 2500
	knockback.kv.radius = EMP_BLAST_RADIUS
	knockback.kv.spawnflags = 3 //11 // No Damage - Only Force, Push Players, Test LOS
	knockback.SetName( UniqueString() )
	knockback.SetOrigin( titan.GetOrigin() + Vector( 0, 0, 32 ) )
	knockback.SetTeam( titan.GetTeam() )
	DispatchSpawn( knockback, false )
	knockback.Fire( "Explode" )
	knockback.Kill( 2.0 )
}

function BlastScreenShake( titan )
{
	// Screen shake
	local amplitude = 16
	local frequency = 5.0
	local duration = 2.0
	local radius = 1500
	local shake = CreateShake( titan.GetOrigin(), amplitude, frequency, duration, radius )
	shake.SetParent( titan, "CHESTFOCUS" )
	shake.Kill( 3.0 )
}

function PushEverythingAway( titan )
{
	// Push everything away
	local pushableEnts = []
	pushableEnts.extend( GetPlayerArray() )
	pushableEnts.extend( GetNPCArray() )

	local radiusSq = EMP_BLAST_RADIUS * EMP_BLAST_RADIUS
	local dist
	local maxPushBackScale
	local upVel
	local targetVelocity
	local directionVec

	local team = titan.GetTeam()
	local soul = titan.GetTitanSoul()

	foreach ( ent in pushableEnts )
	{
		if ( ent.GetTeam() == team )
			continue

		dist = DistanceSqr( ent.GetOrigin(), titan.GetOrigin() )
		if ( dist >= radiusSq )
			continue

		upVel = ent.IsTitan() ? 100 : 50

		if ( IsPilot( ent ) )
		{
			if ( ent.GetPetTitan() == titan )
				continue

			maxPushBackScale = 250
			if ( ent.GetTitanSoulBeingRodeoed() == soul )
			{
				ent.Signal( "RodeoOver" )
				ent.ClearParent()
			}
		}
		else if ( ent.IsTitan() )
		{
			maxPushBackScale = GetSettingsForClass_MeleeTable( ent.GetPlayerSettings() ).meleePushback * TITAN_CORE_PUSHBACK_MULTIPLIER_VS_TITANS
		}
		else
		{
			maxPushBackScale = 400
		}

		if ( ent.GetTeam() == titan.GetTeam() )
			maxPushBackScale *= 0.2

		maxPushBackScale = GraphCapped( dist, 0, radiusSq, maxPushBackScale * 2.0, maxPushBackScale * 0.5 )

		directionVec = ( ent.GetOrigin() + Vector( 0, 0, upVel ) ) - titan.GetOrigin()
		directionVec.Norm()

		targetVelocity = ent.GetVelocity()
		targetVelocity += directionVec * maxPushBackScale

		//targetVelocity = ClampVerticalVelocity( targetVelocity, TITAN_MELEE_MAX_VERTICAL_PUSHBACK  )
		ent.SetVelocity( targetVelocity )
	}
}


