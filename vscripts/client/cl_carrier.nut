const FX_CARRIER_ATTACK 	= "P_weapon_tracers_megalaser"
const FX_REDEYE_ATTACKS_CARRIER 	= "P_Rocket_Phaser_Swirl"

const FX_EXP_BIRM_SML = "p_exp_redeye_sml"
const FIRE_TRAIL = "Rocket_Smoke_Swirl_LG"

const LARGE_REFUEL_SHIP_MODEL = "models/vehicle/redeye/redeye2.mdl"

const FX_REDEYE_WARPIN_SKYBOX = "veh_red_warp_in_full_SB_1000"
const FX_BIRMINGHAM_WARPIN_SKYBOX = "veh_birm_warp_in_full_SB_1000"

const FX_REFUEL_SHIP_WARPIN = "veh_redeye_warp_in_FULL"
const FX_SKYBOX_BERMINGHAM_WARP_IN = "veh_birm_warp_in_FULL"

const FX_ROCKET_LASER = "P_Rocket_Phaser_Swirl"
const FX_EXPLOSION_MED = "P_exp_redeye_sml_elec"

function main()
{
	IncludeFile( "_carrier_torpedo_points" )

	Globalize( SkyCameraToWorld )
	Globalize( WorldToSkyCamera )
	Globalize( HornetsSwarmCarrierFromOrigin )
	Globalize( HornetsPeriodicallyAttackCarrier )
	Globalize( ShipFiresFromOriginToTargetShip )
	Globalize( CarrierShipLauncherInit )
	Globalize( HornetsAttackCarrierAtIndex )
	Globalize( ServerCallback_DogFight )
	Globalize( MegaCarrierShips )
	Globalize( CreateStratonFromCarrier )
	Globalize( HornetMissilesForTime )


	level.megaCarrierDefenses <- [
		"GUN_FRONT"
		"GUN_BACK"
		"GUN_RIGHT"
		"GUN_LEFT"
	]

	level.megaTurretImpactFX <-
	[
		"impact_exp_bomber_smoke1"
		"impact_air_OS"
		"P_impact_exp_XLG_air"
	]

	// various hornet attack anims
	level.hornetAttackPatterns <- {}
	level.hornetAttackPatterns[ "curve" ] <- [ "ht_carrier_attack_1", "ht_carrier_launch_2", "ht_carrier_launch_3" ]
	level.hornetAttackPatterns[ "straight" ] <- [ "ht_carrier_Final_attack_1", "ht_carrier_Final_attack_2" ]
	level.hornetAttackPatterns[ "all" ] <- [ "ht_carrier_attack_1", "ht_carrier_launch_2", "ht_carrier_launch_3", "ht_carrier_Final_attack_1", "ht_carrier_Final_attack_2" ]

//	level.leftSideCarrierDoors <- [ "l_door1", "l_door2", "l_door3", "l_door4" ]
//	level.rightSideCarrierDoors <- [ "r_door1", "r_door2", "r_door3", "r_door4" ]
	level.leftSideCarrierDoors <- [ "l_door1", "l_door2", "l_door4" ]
	level.rightSideCarrierDoors <- [ "r_door1", "r_door2", "r_door4" ]

	PrecacheParticleSystem( FX_REDEYE_WARPIN_SKYBOX )
	PrecacheParticleSystem( FX_BIRMINGHAM_WARPIN_SKYBOX )
	PrecacheParticleSystem( FX_ROCKET_LASER )
	PrecacheParticleSystem( FX_REDEYE_ATTACKS_CARRIER )


	PrecacheParticleSystem( FX_CARRIER_ATTACK )
	PrecacheParticleSystem( FX_EXP_BIRM_SML )
	PrecacheParticleSystem( FIRE_TRAIL )

	PrecacheParticleSystem( FX_SKYBOX_BERMINGHAM_WARP_IN )
	PrecacheParticleSystem( FX_HORNET_DEATH )
	PrecacheParticleSystem( FX_EXPLOSION_MED )

	RegisterSignal( "stop_hornet_attacks" )
	RegisterSignal( "StopLaunching" )
	RegisterSignal( "StopFiring" )

	foreach ( fx in level.megaTurretImpactFX )
	{
		PrecacheParticleSystem( fx )
	}
}

function ServerCallback_DogFight( x, y, z, yaw, animIndex )
{
	thread PlayDogFightAtOrigin( x, y, z, yaw, animIndex )
}

function PlayDogFightAtOrigin( x, y, z, yaw, animIndex )
{
	local anims = DogFightAnimsFromIndex( animIndex )
	local anim1 = anims.anim1
	local anim2 = anims.anim2

	local model = STRATON_MODEL
	local otherModel = HORNET_MODEL
	if ( CoinFlip() )
	{
		otherModel = STRATON_MODEL
		model = HORNET_MODEL
	}

	local origin = Vector( x, y, z )
	local angles = Vector( 0, yaw, 0 )
	local ship1 = CreatePropDynamic( model, origin, angles )

	ship1.SetFadeDistance( 36000 )

	ship1.s.hitsRemaining <- 1
	thread PlayAnimTeleport( ship1, anim1, origin, angles )

	local waitTime = RandomFloat( 0.7, 1.5 )
	wait waitTime
	local duration = ship1.GetSequenceDuration( anim1 )
	local time = duration - 4.0


	if ( RandomInt( 100 ) > 80 )
		thread ExtraShipChases( otherModel, origin, angles, anim2 )

	local ship2 = CreatePropDynamic( otherModel, origin, angles )
	thread HornetMissilesForTime( ship2, ship1, time )
	ship2.SetFadeDistance( 36000 )
	waitthread PlayAnimTeleport( ship2, anim2, origin, angles )
	wait waitTime
	// can be destroyed
	if ( IsValid( ship1 ) )
		ship1.Destroy()

	ship2.Destroy()
}

function ExtraShipChases( model, origin, angles, anim )
{
//	wait RandomFloat( 0.6, 0.8 )
	wait RandomFloat( 0.8, 1.1 )
	local ship = CreatePropDynamic( model, angles )
	ship.SetFadeDistance( 36000 )
	waitthread PlayAnimTeleport( ship, anim, origin, angles )
	ship.Destroy()
}

function ShipFiresFromOriginToTargetShip( attackingShip, targetShip, targetType = "carrier" )
{
	if ( !IsValid( attackingShip ) )
		return

	if ( !IsAlive( targetShip ) )
		return

	attackingShip.EndSignal( "OnDestroy" )
	attackingShip.EndSignal( "OnDeath" )
	attackingShip.EndSignal( "StopFiring" )
	targetShip.EndSignal( "OnDestroy" )
	targetShip.EndSignal( "OnDeath" )

	local table = CreateCarrierRocketTable()
	table.attackingShip = attackingShip
	table.targetShip = targetShip
	table.fx = FX_REDEYE_ATTACKS_CARRIER
	table.explosionFX = FX_EXPLOSION_MED
	table.minSpeed = 24000
	table.maxSpeed = 28000
	table.fireSound = "AngelCity_Scr_RedeyeWeaponFire"
	table.impactSound = "AngelCity_Scr_RedeyeWeaponExplos"

	local torpedoPoints = []
	if( targetType == "redeye" )
		torpedoPoints = level.redeyeTorpedoPoints
	else
		torpedoPoints = level.carrierTorpedoPoints

	local timeBetweenShots = 1.2
	for ( ;; )
	{
		local points = GetScriptAttachPointsWithinDot( targetShip, torpedoPoints, attackingShip.GetOrigin(), 0.2 )

		table.index = Random( points )

		if( !IsValid( table.index ) )
		{
			wait timeBetweenShots
			continue
		}

		for ( local i = 0; i < 6; i++ )
		{
			thread FireHomingRocketAtTargetShip( table, torpedoPoints )
			table.index++

			wait RandomFloat( 0.2, 0.8 )
		}

		wait timeBetweenShots
	}
}

function CreateCarrierRocketTable()
{
	local table = {}
	table.attackingShip <- null
	table.targetShip <- null
	table.index <- null
	table.fx <- null
	table.explosionFX <- null
	table.minSpeed <- null
	table.maxSpeed <- null
	table.fireSound <- null
	table.impactSound <- null
	return table
}


function HornetsPeriodicallyAttackCarrier( carrier, minTime = 8, maxTime = 16 )
{
	// hornets attack from time to time
	if ( !IsAlive( carrier ) )
		return
	carrier.EndSignal( "OnDeath" )
	carrier.EndSignal( "OnDestroy" )

	carrier.Signal( "stop_hornet_attacks" )
	carrier.EndSignal( "stop_hornet_attacks" )

	for ( ;; )
	{
		local num = RandomInt( level.carrierTorpedoPoints.len() )
		local waves = RandomInt( 2, 3 )
		for ( local p = 0; p < waves; p++ )
		{
			local count = RandomInt( 2, 3 )
			for ( local i = 0; i < count; i++ )
			{
				thread SpawnHornetToAttackLocation( carrier, num + i, "curve" )
				wait RandomFloat( 0.4, 0.6 )
			}

			wait RandomFloat( 1.0, 1.4 )
		}

		wait RandomFloat( minTime, maxTime )
	}
}

function HornetsAttackCarrierAtIndex( carrier, wave, minTime = 8, maxTime = 16 )
{
	// hornets attack from time to time
	if ( !IsAlive( carrier ) )
		return

	carrier.EndSignal( "OnDeath" )
	carrier.EndSignal( "OnDestroy" )
	carrier.Signal( "stop_hornet_attacks" )
	carrier.EndSignal( "stop_hornet_attacks" )

	for ( ;; )
	{
		local num = wave + RandomInt( 4 )

		local waves = RandomInt( 2, 3 )
		for ( local p = 0; p < waves; p++ )
		{
			local count = RandomInt( 2, 3 )
			for ( local i = 0; i < count; i++ )
			{
				thread SpawnHornetToAttackLocation( carrier, num + i, "straight" )
				wait RandomFloat( 0.4, 0.6 )
			}

			wait RandomFloat( 1.0, 1.4 )
		}

		wait RandomFloat( minTime, maxTime )
	}
}

function MegaCarrierFiresAtShip( carrier, ship )
{
	carrier.EndSignal( "OnDeath" )
	carrier.EndSignal( "OnDestroy" )

	ship.EndSignal( "OnDestroy" )
	ship.EndSignal( "OnDeath" )
	wait 0.8

	local start = carrier.GetOrigin()
	local angles = ship.GetAngles()

	//draw a tracer
	local fxid			= GetParticleSystemIndex( FX_CARRIER_ATTACK )
	//local effect 		= StartParticleEffectInWorldWithHandle( effectIndex, start, Vector( 0, 0, 1 ) )
//	local effect 		= StartParticleEffectOnEntityWithPos( ship, fxid, FX_PATTACH_POINT_FOLLOW, -1, origin, angles )


	local shipOrigin = ship.GetOrigin()
	local dist
	local foundAttach

	foreach ( attach in level.megaCarrierDefenses )
	{
		local attachIndex = carrier.LookupAttachment( attach )
		local org = carrier.GetAttachmentOrigin( attachIndex )

		local newdist = Distance( org, shipOrigin )
		if ( dist && newdist >= dist )
			continue

		foundAttach = attachIndex
		dist = newdist
	}
	Assert( foundAttach != null )

	local effect 		= StartParticleEffectOnEntity( carrier, fxid, FX_PATTACH_POINT_FOLLOW, foundAttach )
//	local effect = StartParticleEffectOnEntity( weapon, GetParticleSystemIndex("wpn_arc_cannon_electricity"), FX_PATTACH_POINT_FOLLOW, attachIdx )

	OnThreadEnd(
		function () : ( effect )
		{
			if ( EffectDoesExist( effect ) )
				EffectStop( effect, false, true ) // stop particles, play end cap
		}
	)

	local locForward 	= RandomInt( -10, 10 ) * 500
	local locRight		= RandomFloat( -100, 100 )
	local locUp			= RandomFloat( 0, 400 )

	local destroyTime = Time() + RandomFloat( 1.2, 1.8 )

	while ( 1 )
	{
		local start = ship.GetOrigin()
		start.z += 3200

		local end = ship.GetOrigin()

		//trace for impact
		local vec = end - start

		//update tracer
		EffectSetControlPointVector( effect, 1, end )


		if ( Time() > destroyTime )
		{
			// blew up the ship!
			FighterExplodes( ship )

			ship.Destroy()
			mover.Destroy()
			return
		}

		wait 0.1
	}
}


function SpawnHornetToAttackLocation( carrier, index, attackPattern )
{
	local offset = GetTorpedoOffset( carrier.GetOrigin(), carrier.GetAngles(), index, level.carrierTorpedoPoints )
	local refOrigin = offset.refOrigin
	local pointAngles = offset.angles
	local pointOrigin = offset.origin

	if ( fabs( refOrigin.x ) >= 16384 )
		return
	if ( fabs( refOrigin.y ) >= 16384 )
		return
	if ( fabs( refOrigin.z ) >= 16384 )
		return

	local model = HORNET_MODEL
	local anims = level.hornetAttackPatterns[ attackPattern ]
	local anim = Random( anims )

	local hornet = CreatePropDynamic( model, Vector(0,0,0), Vector(0,0,0) )
	//local hornet = CreateClientsideScriptMover( model, Vector(0,0,0), Vector(0,0,0) )
	if ( RandomInt( 100 ) > 72 )
		thread MegaCarrierFiresAtShip( carrier, hornet )

	hornet.EndSignal( "OnDestroy" )
	hornet.SetFadeDistance( 36000 )
	hornet.EnableRenderAlways()

	hornet.SetOrigin( refOrigin )
	hornet.SetAngles( pointAngles )
	//hornet.SetParent( carrier, "", true )
	thread HornetMissilesVsCarrier( hornet, carrier, offset.index )

	waitthread PlayAnimTeleport( hornet, anim, refOrigin, pointAngles )

	hornet.Destroy()
}

function HornetMissilesForTime( hornet, carrier, time, minSpeed = 8000, maxSpeed = 10000 )
{
	Assert( IsValid, hornet )

	hornet.EndSignal( "OnDestroy" )
	carrier.EndSignal( "OnDestroy" )

	local endTime = Time() + time

	wait 0.5 // wait for anim to start

	local origin
	for ( ;; )
	{
		origin = hornet.GetOrigin()
		if ( LegalOrigin( origin ) )
			break

		wait 0
	}


	for ( ;; )
	{
		for ( local i = 0; i < 3; i++ )
		{
			if ( Time() > endTime )
				return

			if ( RandomInt( 100 ) > 75 )
				thread FireHomingRocket( hornet, carrier, FIRE_TRAIL, FX_EXP_BIRM_SML, minSpeed, maxSpeed )
			else
				thread FireHomingRocketMiss( hornet, carrier, FIRE_TRAIL, FX_EXP_BIRM_SML, minSpeed, maxSpeed )

			wait RandomFloat( 0.2, 0.3 )
		}

		wait RandomFloat( 0.5, 1.5 )
	}
}

function HornetMissilesVsCarrier( hornet, carrier, index )
{
	Assert( IsValid, hornet )

	hornet.EndSignal( "OnDestroy" )
	carrier.EndSignal( "OnDestroy" )
	local endTime = Time() + 1.75

	wait 0.5 // wait for anim to start

	local origin
	for ( ;; )
	{
		origin = hornet.GetOrigin()
		if ( LegalOrigin( origin ) )
			break

		wait 0
	}

	local startTime = Time()
	local oldDist = Distance( hornet.GetOrigin(), carrier.GetOrigin() )

	local table = CreateCarrierRocketTable()
	table.attackingShip = hornet
	table.targetShip = carrier
	table.index = index
	table.fx = FIRE_TRAIL
	table.explosionFX = FX_EXP_BIRM_SML
	table.minSpeed = 6000
	table.maxSpeed = 25000
	table.impactSound = "AngelCity_Scr_RedeyeWeaponExplos"
//	table.fireSound = "AngelCity_Scr_RedeyeWeaponFire"

	local dist
	for ( ;; )
	{
		// various conditions to stop firing missiles
		dist = Distance( hornet.GetOrigin(), carrier.GetOrigin() )
		if ( dist < 1100 )
		{
			break
		}

		if ( dist < oldDist )
		{
			oldDist = dist + 200
		}
		else
		if ( dist > oldDist )
		{
			break
		}

		thread FireHomingRocketAtTargetShip( table, level.carrierTorpedoPoints )
		table.index++
		wait RandomFloat( 0.2, 0.8 )
	}
}

function RocketFliesToTarget( rocket, carrier, speed )
{
	rocket.EndSignal( "OnDestroy" )
	local dist
	local origin
	local travelTime
	local destroyTime = 0


	for ( ;; )
	{
		// keep re-moving to target
		if ( !IsAlive( carrier ) )
			break

		origin = carrier.GetOrigin()
		dist = Distance( rocket.GetOrigin(), origin )
		travelTime = Graph( dist, 0, speed, 0, 1.0 )

		destroyTime = Time() + travelTime

		if ( travelTime <= 0 )
			break

		rocket.NonPhysicsMoveTo( origin, travelTime, 0, 0 )

		// getting close?
		if ( travelTime < 0.1 )
		{
			wait travelTime
			return
		}

		wait 0.1
	}

	// still travel time left? carrier may have left
	if ( Time() < destroyTime )
	{
		wait destroyTime - Time()
	}
}

function RocketLaunchesFromHornet( hornet, rocket, speed, dist )
{
	local start = hornet.GetOrigin()
	local angles = hornet.GetAngles()
	local forward = angles.AnglesToForward()

	local end = start + forward * dist

	local time = Graph( dist, 0, speed, 0, 1.0 )
	rocket.NonPhysicsMoveTo( end, time, 0, 0 )
	wait time
}

function RocketMissesTarget( rocket, carrier, speed )
{
	rocket.EndSignal( "OnDestroy" )

	local dist
	local start, end
	local travelTime
	local destroyTime = 0

	local vec, angles, up, right, forward

	for ( ;; )
	{
		// keep re-moving to target
		if ( !IsAlive( carrier ) )
			break

		start = rocket.GetOrigin()
		end = carrier.GetOrigin()
		vec = end - start
		angles = VectorToAngles( vec )
		up = angles.AnglesToUp()
		right = angles.AnglesToRight()
		forward = angles.AnglesToForward()

		end += up * 400
		end += right * 400

		//DebugDrawLine( 		carrier.GetOrigin(), end,255, 0, 0, true, 5.0 )
		dist = Distance( start, end )
		travelTime = Graph( dist, 0, speed, 0, 1.0 )

		destroyTime = Time() + travelTime

		if ( travelTime <= 0.25 )
			break

		rocket.NonPhysicsMoveTo( end, travelTime, 0, 0 )

		wait 0.1
	}

	local forward
	if ( IsAlive( carrier ) )
	{
		start = rocket.GetOrigin()
		end = carrier.GetOrigin()
		vec = end - start
		local angles = VectorToAngles( vec )
		forward = angles.AnglesToForward()
	}
	else
	{
		local angles = rocket.GetAngles()
		forward = angles.AnglesToForward()
	}

	local endTime = Time() + 6.0

	//local vec1 = Vector( -1789, -7578, 2455 )
	//local vec2 = Vector( 3369, -10889, 2455 )
	//local result = TraceLine( vec1, vec2, rocket, TRACE_MASK_NPCWORLDSTATIC, TRACE_COLLISION_GROUP_NONE )
	//DebugDrawLine( vec1, result.endPos, 0, 255, 0, true, 1.0 )
	//DebugDrawLine( result.endPos, vec2, 255, 0, 0, true, 1.0 )
	//printt( "hit " + result.surfaceName )

	for ( ;; )
	{
		if ( Time() > endTime )
			return

		start = rocket.GetOrigin()
		end = start + forward * 7500
		if ( !LegalOrigin( end ) )
			return

		local result = TraceLine( start, end, rocket, TRACE_MASK_NPCWORLDSTATIC, TRACE_COLLISION_GROUP_NONE )
		if ( result.fraction < 1.0 && !result.startSolid && result.surfaceName ) // != "default_silent" )
		{
//	printt( "hit " + result.surfaceName )
			local time = 0.75 * result.fraction
			if ( time > 0 )
			{
				rocket.NonPhysicsMoveTo( result.endPos, time, 0, 0 )
				//DrawArrow( result.endPos, Vector(0,0,0), 30, 350 )
				wait time
			}
			return
		}

		rocket.NonPhysicsMoveTo( end, 0.75, 0, 0 )

		wait 0.75
	}
}


function RocketFliesToCarrierTorpedoPoint( rocket, carrier, ref, minSpeed, maxSpeed )
{
	rocket.EndSignal( "OnDestroy" )
	local dist
	local origin
	local travelTime
	local destroyTime = 0

	local speed = RandomFloat( minSpeed, maxSpeed )

	//local start = rocket.GetOrigin()
	//local vec = rocket.GetOrigin() - ref.GetOrigin()
	//vec.Norm()
	//local end = ref.GetOrigin() + vec * -2500
	//local result = TraceLine( start, end, rocket, TRACE_MASK_SHOT_HULL, TRACE_COLLISION_GROUP_NONE )
	//DebugDrawLine( start, result.endPos, 0, 255, 0, true, 10.0 )
	//DebugDrawLine( result.endPos, end, 255, 0, 0, true, 10.0 )
	//if ( result.fraction < 1 )
	//{
	//	printt( "hit " + result.hitEnt.GetClassname() )
	//}

	for ( ;; )
	{
		// keep re-moving to target
		if ( !IsAlive( carrier ) )
			break

		Assert( IsValid( ref ) )
		origin = ref.GetOrigin()
		dist = Distance( rocket.GetOrigin(), origin )
		travelTime = Graph( dist, 0, speed, 0, 1.0 )

		destroyTime = Time() + travelTime

		if ( travelTime <= 0 )
			break
		//if ( dist < 500 )
		//	travelTime = 0.05
		//else
		//	printt( "dist " + dist + " time " + travelTime )

		rocket.NonPhysicsMoveTo( origin, travelTime, 0, 0 )

		// getting close?
		if ( travelTime < 0.1 )
		{
			wait travelTime
			return
		}

		wait 0.1
	}

	// still travel time left? carrier may have left
	if ( Time() < destroyTime )
	{
		wait destroyTime - Time()
	}
}

function FireHomingRocketAtTargetShip( e, torpedoPoints )
{
	if ( !IsAlive( e.targetShip ) )
		return

	local result = GetTorpedoOffset( e.targetShip.GetOrigin(), e.targetShip.GetAngles(), e.index, torpedoPoints )

	if ( !LegalOrigin( result.origin ) )
		return

	// create the rocket
	local origin = e.attackingShip.GetOrigin()
	local vec = origin - e.targetShip.GetOrigin()
	local angles = VectorToAngles( vec )

	local rocket = CreateClientsideScriptMover( "models/dev/empty_model.mdl", origin, angles )
	rocket.DisableDraw()

	// rocket FX
	local fxid = GetParticleSystemIndex( e.fx )
	local attachID = rocket.LookupAttachment( "REF" )
	local particleFX = StartParticleEffectOnEntity( rocket, fxid, FX_PATTACH_POINT_FOLLOW, attachID )

	// create a ref that maintains an offset from the carrier so we dont have to recalc it
	local ref = CreateScriptRef( result.origin, result.angles )

	if ( e.fireSound )
		EmitSoundAtPosition( origin, e.fireSound )

	ref.SetParent( e.targetShip, "", true )

	OnThreadEnd(
		function () : ( e, rocket, ref, attachID, result, particleFX )
		{
			EffectStop( particleFX, false, true )

			if ( IsAlive( e.targetShip ) )
			{
				if ( e.impactSound )
					EmitSoundAtPosition( result.origin, e.impactSound )

				// the hits look weird if there is no carrier
				// explosion
				local explosionID = GetParticleSystemIndex( e.explosionFX )
				local offset = result.origin - e.targetShip.GetOrigin()
				StartParticleEffectOnEntityWithPos( e.targetShip, explosionID, FX_PATTACH_ABSORIGIN_FOLLOW, -1, offset, result.sourceAngles )
			}

			rocket.Destroy()

			if ( IsValid( ref ) )
				ref.Destroy()
		}
	)

	// fly the rocket
	waitthread RocketFliesToCarrierTorpedoPoint( rocket, e.targetShip, ref, e.minSpeed, e.maxSpeed )
}

function FireHomingRocket( hornet, carrier, fxName, explosionFX, minSpeed, maxSpeed )
{
	FireHomingRocketLogic( hornet, carrier, RocketFliesToTarget, fxName, explosionFX, minSpeed, maxSpeed )
}

function FireHomingRocketMiss( hornet, carrier, fxName, explosionFX, minSpeed, maxSpeed )
{
	FireHomingRocketLogic( hornet, carrier, RocketMissesTarget, fxName, explosionFX, minSpeed, maxSpeed )
}

//pointOrigin + RandomVec( 300 ) )
function FireHomingRocketLogic( hornet, carrier, rocketMoveFunc, fxName, explosionFX, minSpeed, maxSpeed )
{
	if ( !IsValid( hornet ) )
		return
	if ( !IsAlive( carrier ) )
		return

	local origin = hornet.GetOrigin()
	local angles = hornet.GetAngles()
	if ( !LegalOrigin( origin ) )
		return

	local carrierOrigin = carrier.GetOrigin()
	local carrierAngles = carrier.GetAngles()

	// create the rocket
	local vec = origin - carrier.GetOrigin()

	local rocket = CreateClientsideScriptMover( "models/dev/empty_model.mdl", origin, angles )
	rocket.DisableDraw()

	// rocket FX
	local fxid = GetParticleSystemIndex( fxName )
	local attachID = rocket.LookupAttachment( "REF" )
	local particleFX = StartParticleEffectOnEntity( rocket, fxid, FX_PATTACH_POINT_FOLLOW, attachID )

	OnThreadEnd(
		function () : ( carrier, rocket, attachID, explosionFX, particleFX )
		{
			if ( EffectDoesExist( particleFX ) )
				EffectStop( particleFX, false, true )

			if ( IsAlive( carrier ) )
			{
				local explosionID = GetParticleSystemIndex( explosionFX )
				local dist = Distance( rocket.GetOrigin(), carrier.GetOrigin() )
				//printt( "dist " + dist )
				if ( dist < 750 )
				{
					// the hits look weird if there is no carrier
					// explosion
					local attachIdx = carrier.LookupAttachment( "ORIGIN" )
					StartParticleEffectOnEntity( carrier, explosionID, FX_PATTACH_ABSORIGIN_FOLLOW, attachIdx )
					carrier.s.hitsRemaining--
					//printt( "hits remaining " + carrier.s.hitsRemaining )
					if ( carrier.s.hitsRemaining <= 0 )
					{
						FighterExplodes( carrier )
						carrier.Destroy()
					}
				}
				else
				{
					StartParticleEffectInWorld( explosionID, rocket.GetOrigin(), rocket.GetAngles() )
				}
			}

			rocket.Destroy()
		}
	)

	local speed = RandomFloat( minSpeed, maxSpeed )

	waitthread RocketLaunchesFromHornet( hornet, rocket, speed, 1500 )

	// fly the rocket
	waitthread rocketMoveFunc( rocket, carrier, speed )
}

function SkyCameraToWorld( origin )
{
	local org = VectorCopy( origin )
	local scale = level.skyCameraScale
	org -= level.skyCameraOrg
	org *= scale
	return org
}

function WorldToSkyCamera( origin )
{
	local scale = level.skyCameraScale
	local org = VectorCopy( origin )
	org.x /= scale
	org.y /= scale
	org.z /= scale
	org += level.skyCameraOrg
	return org
}

function GetScriptAttachPointsWithinDot( carrier, torpedoPoints, skyVec, dotVal )
{
	local points = []
	foreach ( index, point in torpedoPoints )
	{
		local result = GetTorpedoOffset( carrier.GetOrigin(), carrier.GetAngles(), index, torpedoPoints )
		local forward = result.angles.AnglesToForward()
		local vec = skyVec - result.origin
		vec.Norm()
		local dot = vec.Dot( forward )
		if ( dot > dotVal )
			points.append( index )
	}

	return points
}

function HornetsSwarmCarrierFromOrigin( carrier, skyVec )
{
	if ( !IsAlive( carrier ) )
		return

	local points = GetScriptAttachPointsWithinDot( carrier, level.carrierTorpedoPoints, skyVec, 0.2 )

	local e = {}
	e.origin <- carrier.GetOrigin()
	e.angles <- carrier.GetAngles()
	waitthread HornetSwarmUntilCarrierLeaves( carrier, skyVec, points, e )

	local startTime = Time()
	local endTime = Time() + 20.0

	for ( ;; )
	{
		if ( Time() > endTime )
			break
		thread HornetSwarmCarrier( e.origin, e.angles, null, Random( points ), skyVec )

		local delay = Graph( Time(), startTime, endTime, 0.5, 2.5 )
		wait delay
	}
}

function HornetSwarmUntilCarrierLeaves( carrier, skyVec, points, e )
{
	carrier.EndSignal( "OnDestroy" )
	for ( ;; )
	{
		e.origin = carrier.GetOrigin()
		e.angles = carrier.GetAngles()
		thread HornetSwarmCarrier( e.origin, e.angles, carrier, Random( points ), skyVec )
		wait RandomFloat( 0.4, 1.6 )
	}
}

function HornetSwarmCarrier( carrierOrigin, carrierAngles, carrier, index, skyVec )
{
	local result = GetTorpedoOffset( carrierOrigin, carrierAngles, index, level.carrierTorpedoPoints )

	local vec = skyVec - result.origin
	vec.Norm()
	local origin = result.refOrigin
	local angles = VectorToAngles( vec )
	angles.x = 0
	angles.z = 0
//	DrawArrow( origin, angles, 35, 500 )

	local model = HORNET_MODEL
	local hornet = CreatePropDynamic( model, origin, Vector(0,0,0) )
	local anims

	if ( RandomInt( 100 ) > 33 )
		anims = level.hornetAttackPatterns[ "straight" ]
	else
		anims = level.hornetAttackPatterns[ "curve" ]

	local anim = Random( anims )

	hornet.EndSignal( "OnDestroy" )
	hornet.SetFadeDistance( 36000 )
	hornet.EnableRenderAlways()

	if ( IsAlive( carrier ) )
		thread HornetMissilesVsCarrier( hornet, carrier, result.index )

	waitthread PlayAnimTeleport( hornet, anim, origin, angles )
	hornet.Kill()
}

function StratonLauncher( carrier, doors )
{
	carrier.EndSignal( "StopLaunching" )
	// move to client event on door open animation when we get it
	carrier.EndSignal( "OnDestroy" )

	for ( ;; )
	{
		local count
		if ( carrier.s.flowHigh )
			count = RandomInt( 11, 18 )
		else
			count = RandomInt( 6, 9 )

		for ( local i = 0; i < count; i++ )
		{
			thread CreateStratonFromCarrier( carrier, doors )
			wait RandomFloat( 0.3, 0.5 )
		}

		if ( carrier.s.flowHigh )
			wait RandomFloat( 3, 4.5 )
		else
			wait RandomFloat( 14, 20 )
	}
}

// makes the carrier launch ships when certain events are hit in animation
function CarrierShipLauncherInit( carrier )
{
	AddAnimEvent( carrier, "high_flow_both_sides", SetCarrierFlow,  "high_flow_both_sides"  )
	AddAnimEvent( carrier, "low_flow_both_sides", SetCarrierFlow,  "low_flow_both_sides"  )
	AddAnimEvent( carrier, "low_flow_right", 	   SetCarrierFlow,  "low_flow_right" 	    )
	AddAnimEvent( carrier, "low_flow_left", 	   SetCarrierFlow,  "low_flow_left" 	    )
	AddAnimEvent( carrier, "high_flow_right", 	   SetCarrierFlow,  "high_flow_right" 	    )
	AddAnimEvent( carrier, "high_flow_left", 	   SetCarrierFlow,  "high_flow_left" 	    )
	AddAnimEvent( carrier, "no_flow", 	           SetCarrierFlow,  "no_flow" 				)

	carrier.s.flowState <- "no_flow"
	carrier.s.flowHigh <- false
}

function SetCarrierFlow( carrier, state )
{
	if ( carrier.s.flowState == state )
		return

	carrier.s.flowState = state

	carrier.Signal( "StopLaunching" )

	switch ( state )
	{
		case "high_flow_both_sides":
		case "high_flow_left":
		case "high_flow_right":
			carrier.s.flowHigh = true
			break

		case "low_flow_both_sides":
		case "low_flow_right":
		case "low_flow_left":
		case "no_flow":
			carrier.s.flowHigh = false
			break
	}

	switch ( state )
	{
		case "high_flow_both_sides":
		case "low_flow_both_sides":
			thread StratonLauncher( carrier, level.leftSideCarrierDoors )
		case "low_flow_right":
		case "high_flow_right":
			thread StratonLauncher( carrier, level.rightSideCarrierDoors )
			break

		case "low_flow_left":
		case "high_flow_left":
			thread StratonLauncher( carrier, level.leftSideCarrierDoors )
			break
	}
}

function CreateStratonFromCarrier( carrier, doors )
{
	local model = STRATON_MODEL
	local anim = "st_carrier_launch_" + ( RandomInt( 8 ) + 1 )
	// st_carrier_launch_1
	// st_carrier_launch_2
	// st_carrier_launch_3
	// st_carrier_launch_4
	// st_carrier_launch_5
	// st_carrier_launch_6
	// st_carrier_launch_7
	// st_carrier_launch_8

	local dropship = CreatePropDynamic( model, Vector(0,0,0), Vector(0,0,0) )
	local door = Random( doors )
	waitthread PlayAnimTeleport( dropship, anim, carrier, door )
	if ( IsValid( dropship ) )
		dropship.Kill()
}

function drawdoor( door, dropship )
{
	dropship.EndSignal( "OnDestroy" )
	for ( ;; )
	{
		DebugDrawText( dropship.GetOrigin(), door, true, 0.1 )
		wait 0
	}
}

function MegaCarrierShips( carrier )
{
	carrier.EndSignal( "OnDeath" )
	carrier.EndSignal( "OnDestroy" )
	carrier.EndSignal( "idling" )
	OnThreadEnd(

		function () : ( carrier )
		{
			if ( IsValid( carrier ) )
			{
				thread HornetsPeriodicallyAttackCarrier( carrier )
			}
		}
	)

	wait 38.0

	thread HornetsAttackCarrierAtIndex( carrier, 25, 2, 3 )
	wait 15.0
	carrier.Signal( "stop_hornet_attacks" )
	wait 1.5
}