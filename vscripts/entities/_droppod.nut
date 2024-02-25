const DP_COLL_MODEL = "models/vehicle/droppod_fireteam/droppod_fireteam_collision.mdl"

function main()
{
	file.soundLaunch3rd <- "droppod_launch_3rd"

	Globalize( CreateMoverDropPod )
	Globalize( LaunchMoverDropPod )
	Globalize( CreateDropPodSmokeTrail )
	Globalize( CreateTitanSmokeTrail )

	Globalize( CreateAnimDropPod )
	Globalize( LaunchAnimDropPod )
	Globalize( GetDropPodAnimDuration )

	Globalize( CheckPlayersIntersectingPod )
	Globalize( CreateDropPodCollision )
	Globalize( PushPlayerAndCreateDropPodCollision )

	RegisterSignal( "OnLaunch" )
	RegisterSignal( "OnImpact" )

	PrecacheModelPhysics( DP_COLL_MODEL )

	PrecacheEffect( "droppod_trail" )
	PrecacheEffect( "droppod_impact" )
}


function GetDropPodAnimDuration()
{
	local dropPod = CreatePropDynamic( DROPPOD_MODEL )

	local animDuration = dropPod.GetSequenceDuration( "pod_testpath" )
	dropPod.Destroy()

	return animDuration
}


function CreateMoverDropPod( owner )
{
	local dropPod = CreateEntity( "script_mover" )

	dropPod.SetModel( DEFAULT_DROPPOD_MODEL )
	dropPod.kv.SpawnAsPhysicsMover = false
	//dropPod.kv.solid = 6

	dropPod.s.trail <- CreateDropPodSmokeTrail( dropPod )
	dropPod.s.owner <- owner

	DispatchSpawn( dropPod, true )

	return dropPod
}


function LaunchMoverDropPod( dropPod, targetOrigin )
{
	local travelSpeed = 2000

	local dist = (dropPod.GetOrigin() - targetOrigin).Length()
	local travelTime = dist / travelSpeed
	local travelVec = targetOrigin - dropPod.GetOrigin()

	if ( travelVec.x != 0 || travelVec.y != 0 )
	{
		local up = Vector( 0, 0, 1 )
		local right = travelVec.Cross( up )
		local forward = right.Cross( travelVec )
		dropPod.SetForwardVector( forward )
	}
	/*
	// alternate version respecting the droppod yaw, not needed for vertical travelVec
	else
	{
		local forward = dropPod.GetForwardVector();
		local up = Vector( -travelVec.x, -travelVec.y, -travelVec.z )
		local right = up.Cross( forward )

		// recalc forward assuming original forward pitch was not right
		forward = right.Cross( travelVec )
		dropPod.SetForwardVector( forward )
	}
	*/

	MoverDropPodOnLaunch( dropPod )

	dropPod.MoveTo( targetOrigin, travelTime, 0, 0 )

	thread MoverDropPodOnImpact( dropPod )

	dropPod.Fire( "RunScriptCode", "self.Signal( \"OnImpact\" )", travelTime )
}


function CreateAnimDropPod( owner )
{
	local dropPod = CreatePropDynamic( DROPPOD_MODEL )
	dropPod.s.owner <- owner

	return dropPod
}


function LaunchAnimDropPod( dropPod, anim, targetOrigin, targetAngles, options = null)
{
	dropPod.EndSignal( "OnDestroy" )
	dropPod.EnableRenderAlways()

	dropPod.s.launchAnim <- anim

	local incomingEffect
	local onImpactFunc = DropPodOnImpact

	local team = dropPod.GetTeam()
	local dealDamage = false

	if ( options )
	{
		if( "incomingEffect" in options && options.incomingEffect )
			incomingEffect = CreateIncomingEffect( targetOrigin, 128, team )
		if ( "dealDamage" in options && options.dealDamage )
			dealDamage = options.dealDamage
		if ( "onImpactFunc" in options && IsFunction( options.onImpactFunc ) )
			onImpactFunc = options.onImpactFunc
	}

	local ref = CreateScriptMover( dropPod )
    ref.SetOrigin( targetOrigin )
    ref.SetAngles( targetAngles )

	OnThreadEnd(
		function () : ( dropPod, targetOrigin, incomingEffect, ref, dealDamage )
		{
			if ( incomingEffect )
				DestroyIncomingEffect( incomingEffect )

			if ( IsValid( dropPod ) )
			{
				dropPod.ClearParent()
			}

			if ( IsValid( ref ) )
				ref.Kill()
		}
	)


	local e = {}
	e.dealDamage <- dealDamage
	e.targetOrigin <- targetOrigin
	e.targetAngles <- targetAngles
	AddAnimEvent( dropPod, "OnImpact", onImpactFunc, e )

	EmitSoundAtPosition( targetOrigin, "spectre_drop_pod" )

	local sequence = CreateFirstPersonSequence()
	sequence.thirdPersonAnim 		= "pod_testpath"
	//sequence.thirdPersonAnimIdle 	= "pod_testpath_loop"

	sequence.blendTime 			= 0.0
	sequence.attachment 		= "ref"
	sequence.useAnimatedRefAttachment		= true
	//DrawArrow( ref.GetOrigin(), ref.GetAngles(), 5, 100 )
	waitthread FirstPersonSequence( sequence, dropPod, ref )
	dropPod.DisableRenderAlways()
//	wait 0
}

function CheckPlayersIntersectingPod( pod, targetOrigin )
{
	local playerList = GetPlayerArray()

	// Multiplying the bounds by 1.42 to ensure this encloses the droppod when it's rotated 45 degrees
	local mins = pod.GetBoundingMins() * 1.42 + targetOrigin
	local maxs = pod.GetBoundingMaxs() * 1.42 + targetOrigin
	local safeRadiusSqr = 250 * 250

	foreach ( player in playerList )
	{
		local playerOrigin = player.GetOrigin()

		if ( DistanceSqr( targetOrigin, playerOrigin ) > safeRadiusSqr )
			continue

		local playerMins = player.GetBoundingMins() + playerOrigin
		local playerMaxs = player.GetBoundingMaxs() + playerOrigin

		if ( BoxIntersectsBox( mins, maxs, playerMins, playerMaxs ) )
			return true
	}

	return false
}

function CreateDropPodCollision( pod )
{
	local prop_physics = CreateEntity( "prop_physics" )

	prop_physics.SetName( "droppod_solid" )
	prop_physics.kv.model = DP_COLL_MODEL
	prop_physics.kv.fadedist = -1
	prop_physics.kv.physdamagescale = 0.1
	prop_physics.kv.inertiaScale = 1.0
	prop_physics.kv.renderamt = 255
	prop_physics.kv.rendercolor = "255 255 255"
	prop_physics.kv.rendermode = 10 // dont render

	DispatchSpawn( prop_physics, false )

	prop_physics.SetParent( pod, "ATTACH", false )
}

function PushPlayerAndCreateDropPodCollision( pod, targetOrigin )
{
	pod.EndSignal( "OnDestroy" )

	local point_push = CreateEntity( "point_push" )
	point_push.kv.spawnflags = 8
	point_push.kv.enabled = 1
	point_push.kv.magnitude = 250.0
	point_push.kv.radius = 192.0
	point_push.SetOrigin( targetOrigin + Vector( 0.0, 0.0, 32.0 ) )
	DispatchSpawn( point_push, false )

	OnThreadEnd(
		function() : ( point_push )
		{
			point_push.Fire( "Kill", "", 0.0 )
		}
	)

	while ( CheckPlayersIntersectingPod( pod, targetOrigin ) )
		wait( 0.1 )

	CreateDropPodCollision( pod )
}

function DropPodOnImpact( dropPod, e )
{
	PlayFX( HOTDROP_IMPACT_FX_TABLE, e.targetOrigin, e.targetAngles )
	CreateShake( e.targetOrigin, 7, 0.15, 1.75, 768 )

	// 1 - No Damage - Only Force
	// 2 - Push players
	// 8 - Test LOS before pushing
	local flags = 11
	local impactOrigin = e.targetOrigin + Vector( 0,0,10 )
	local impactRadius = 192
	thread PushPlayerAndCreateDropPodCollision( dropPod, e.targetOrigin )

	if ( e.dealDamage )
		RadiusDamage( impactOrigin,	// origin
			3500,			// titan damage
			3500,			// pilot damage
			impactRadius,	// radiusFalloffMax
			0,				// radiusFullDamage
			dropPod, 		// owner
			eDamageSourceId.droppod_impact, // damage source id
			false,			// alive only
			false,			// self damage
			null,			// team
			null )			// script flags
}


function MoverDropPodOnLaunch( dropPod )
{
	dropPod.Signal( "OnLaunch" )

	EmitSoundOnEntity( dropPod, file.soundLaunch3rd )
	dropPod.s.trail.Fire( "Start" )
}


function MoverDropPodOnImpact( dropPod )
{
	dropPod.EndSignal( "OnDestroy" )

	dropPod.WaitSignal( "OnImpact" )

	dropPod.s.trail.Fire( "Stop" )

	local impactFX = CreateDropPodImpactFX( dropPod )
	local impactExplode = CreateDropPodImactExplode( dropPod )

	impactFX.Fire( "Start" )
	impactFX.Kill( 3.0 )

	if ( "owner" in dropPod.s && IsValid_ThisFrame( dropPod.s.owner ) )
	{
		impactExplode.SetOwner( dropPod.s.owner )
		impactExplode.SetTeam( dropPod.s.owner.GetTeam() )
	}

	// MP damage callbacks don't check for MakeInvincible so don't bother
	if ( IsSingleplayer() )
	{
		// do this so the impactExplode explosion doesn't do damage to the hot dropper
		MakeInvincible( dropPod )

		// bad use of delay thread, puts onus on function to check validity of ent
		delaythread( 0.15 ) ClearInvincible( dropPod )
	}

	impactExplode.Fire( "Explode" )
	impactExplode.Kill( 3.0 )
}


function CreateDropPodSmokeTrail( pod )
{
	local smokeTrail = CreateHotDropSmokeTrail( pod )
	smokeTrail.SetOrigin( pod.GetOrigin() + Vector( 0, 0, 152 ) )
	smokeTrail.SetParent( pod )

	return smokeTrail
}

function CreateTitanSmokeTrail( titan )
{
	local smokeTrail = CreateHotDropSmokeTrail( titan )
	//smokeTrail.SetOrigin( titan.GetOrigin() )
	smokeTrail.SetParent( titan, "HATCH_HEAD" )

	return smokeTrail
}

function CreateHotDropSmokeTrail( ent )
{
	local smokeTrail = CreateEntity( "info_particle_system" )
	smokeTrail.kv.effect_name = "droppod_trail"
	smokeTrail.kv.start_active = 0
	DispatchSpawn( smokeTrail, false )

	return smokeTrail
}


function CreateDropPodImpactFX( pod )
{
	local impactFX = CreateEntity( "info_particle_system" )
	impactFX.SetName( "DropPodImpactFX" )
	impactFX.SetOrigin( pod.GetOrigin() )
	impactFX.SetAngles( Vector( 0, 0, 0 ) )
	impactFX.kv.effect_name = "droppod_impact"
	impactFX.kv.start_active = 0

	DispatchSpawn( impactFX, false )

	return impactFX
}


function CreateDropPodImactExplode( pod )
{
	local impactExplode = CreateEntity( "env_explosion" )
	impactExplode.SetOrigin( pod.GetOrigin() )
	impactExplode.kv.iRadiusOverride = 250
	impactExplode.kv.iInnerRadius = 80
	impactExplode.kv.iMagnitude = 150
	impactExplode.SetOwner( pod )
	impactExplode.kv.spawnflags = 1900
	impactExplode.kv.damageSourceId = eDamageSourceId.droppod_impact

	DispatchSpawn( impactExplode, false )

	return impactExplode
}
