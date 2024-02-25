const DOGFIGHT_WATER_WAKE_FX = "veh_jetwash_water_LG"

function main()
{
	if ( reloadingScripts )
		return

	PrecacheParticleSystem( DOGFIGHT_WATER_WAKE_FX )

	IncludeFile( "client/cl_carrier" )
	Globalize( Moment_HavenWaterDogFight )

	level.endingShips <- []
	level.megaCarrier <- null

	RegisterSignal( "idling" )	// signaled from carrier animation

	RegisterServerVarChangeCallback( "megaCarrierSpawnTime", CarrierSpawnTimeChanged )
	AddCreateCallback( "megaCarrier", MegaCarrierCreated )
	SetFullscreenMinimapParameters( 3.5, 750, -700, 180 )
	if ( GAMETYPE == COOPERATIVE )
		SetCustomMinimapZoom( 2 )
}

function CarrierSpawnTimeChanged()
{
	if ( IsValid( level.megaCarrier ) && level.nv.megaCarrierSpawnTime != null )
		thread MegaCarrierClientside()
}

function MegaCarrierCreated( carrier, isRecreate )
{
	if ( carrier == null )
		return

	level.megaCarrier = carrier

	if ( level.nv.megaCarrierSpawnTime == null )
		return

	thread MegaCarrierClientside()
}

function MegaCarrierClientside()
{
	local adjustedTime = Time()
	if ( IsWatchingKillReplay() )
		adjustedTime = Time() - TimeAdjustmentForRemoteReplayCall()

	local lifetime = adjustedTime - level.nv.megaCarrierSpawnTime

	level.megaCarrier.EndSignal( "OnDestroy" )

	// if we've been in the level for 30 seconds don't do any clientside stuff it's to late.
	if ( lifetime > 30 )
		return

	local carrier = level.megaCarrier
	carrier.s.flowState <- "no_flow"
	carrier.s.flowHigh <- false

	local delay = RandomFloat( 8, 18 ) - lifetime
	delay = max( 0, delay )

	delaythread( delay ) CarrierLanchingShips( carrier )

	local minTime = 8
	local maxTime = 14
	if ( level.nv.matchProgress > 75 )
	{
		minTime = 4
		maxTime = 10
	}

	delay = 10 - lifetime
	delay = max( 0, delay )

	delaythread( delay ) HornetsPeriodicallyAttackCarrier( carrier, minTime, maxTime )
}

function CarrierLanchingShips( carrier )
{
	if ( !IsAlive( carrier ) )
		return

	carrier.EndSignal( "OnDeath" )
	carrier.EndSignal( "OnDestroy" )

	local min_wait = 20
	local max_wait = 30

	while( true )
	{
		local count = RandomInt( 6, 18 )
		for ( local i = 0; i < count; i++ )
		{
			thread CreateStratonFromCarrier( carrier, level.rightSideCarrierDoors )
			wait RandomFloat( 0.3, 0.5 )
		}

		local rnd = pow( RandomFloat( 0, 1 ), 2 )
		local waitTime = Graph( rnd, 0, 1, max_wait, min_wait )
		wait waitTime
	}
}

function Moment_HavenWaterDogFight( node )
{
	// let's not start with flybys until we are 5% into the match.
	if ( level.nv.matchProgress < 5 )
		return

	local animPack = {}
	animPack[ CINEMATIC_TYPES.DOGFIGHT_OVER_WATER_STRAIGHT ]	<- [ "ht_Haven_FlyBy_Victim_1", "ht_Haven_FlyBy_Attacker_1" ]
	animPack[ CINEMATIC_TYPES.DOGFIGHT_OVER_WATER_LEFT ]		<- [ "ht_Haven_FlyBy_Victim_3", "ht_Haven_FlyBy_Attacker_3" ]
	animPack[ CINEMATIC_TYPES.DOGFIGHT_OVER_WATER_RIGHT ]		<- [ "ht_Haven_FlyBy_Victim_2", "ht_Haven_FlyBy_Attacker_2" ]

	if ( !( node.type in animPack ) )
		return

	local anim1 = animPack[ node.type ][0]
	local anim2 = animPack[ node.type ][1]

	local model1 = STRATON_MODEL
	local model2 = HORNET_MODEL
	if ( CoinFlip() )
	{
		model1 = HORNET_MODEL
		model2 = STRATON_MODEL
	}

	local fighter1 = CreatePropDynamic( model1, node.pos, node.ang )
	fighter1.s.hitsRemaining <- 1
	fighter1.SetFadeDistance( 36000 )
	thread WaterWake( fighter1, node )
	thread PlayAnimTeleport( fighter1, anim1, node.pos, node.ang )
	thread DestroyAtAnimEnd( fighter1 )

	if ( RandomInt( 100 ) > 80 )
		return	// just one fighter

	local fighter2 = CreatePropDynamic( model2, node.pos, node.ang )
	fighter2.SetFadeDistance( 36000 )
	thread WaterWake( fighter2, node )
	local offset = CoinFlip() ? RandomInt( 5, 10 ) : RandomInt( -5, -10 )
	thread PlayAnimTeleport( fighter2, anim2, node.pos, node.ang + Vector( 0, offset, 0 ) )
	thread DestroyAtAnimEnd( fighter2 )

	local delay = RandomFloat( 1.5, 3 )
	local duration = max( 1, fighter2.GetSequenceDuration( anim2 ) - delay - 2.0 )
	delaythread( delay ) HornetMissilesForTime( fighter2, fighter1, duration, 12000, 15000 )
}

function DestroyAtAnimEnd( ent )
{
	ent.EndSignal( "OnDestroy" )

	ent.clWaittillAnimDone()

	if ( IsValid( ent ) )
		ent.Kill()
}

function WaterWake( fighter, node )
{
	fighter.EndSignal( "OnDestroy" )
	local particleIndex = GetParticleSystemIndex( DOGFIGHT_WATER_WAKE_FX )

	// only do water sprouts if the node is placed over water.
	if ( !ShouldDoWaterWake( node ) )
		return

	wait 1.5 // wait a while before starting to trace since we know the fighter is nowhere near water yet.

	local soundPlaying = false
	local vector = Vector( 0, 0, -1000 )
	local mask = TRACE_MASK_SOLID_BRUSHONLY | TRACE_MASK_WATER

	while( true )
	{
		local origin = fighter.GetOrigin()
		local angles = Vector( 0, fighter.GetAngles().x, 0 )

		local id = DeferredTraceLine( origin, origin + vector, fighter, mask, TRACE_COLLISION_GROUP_NONE )

		// wait 0.0 caused the effects to spawn every frame even if the game was paused.
		wait 0.016

		if ( !IsDeferredTraceValid( id ) )
			continue

		local result = GetDeferredTraceResult( id )

		if ( result.fraction < 1 && result.surfaceName == "water")
		{
			if ( !soundPlaying )
			{
				EmitSoundOnEntity( fighter, "Haven_Scr_FlybyWaterSpray" )
				soundPlaying = true
			}

			local heightOffset = GraphCapped( result.fraction, 1, 0.75, 256, 0 )
			local fxOrigin = result.endPos - Vector( 0, 0, heightOffset )
			StartParticleEffectInWorld( particleIndex, fxOrigin, angles )
		}
	}
}

function ShouldDoWaterWake( node )
{
	local result = TraceLine( node.pos, node.pos + Vector( 0, 0, -1000 ), null, TRACE_MASK_SOLID_BRUSHONLY | TRACE_MASK_WATER, TRACE_COLLISION_GROUP_NONE )
	if ( result.fraction < 1 && result.surfaceName == "water")
		return true
	else
		return false
}
