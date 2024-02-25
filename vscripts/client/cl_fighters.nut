
function main()
{
	Globalize( FighterWaveAttack )
	Globalize( CreateFighterTable )
	Globalize( CreateFighterTargetTable )
	Globalize( CreateFighterWaveTable )
	Globalize( CreateFighterRocketTable )
	Globalize( FighterFireRocket )
	Globalize( FighterGetAttackPositionsWithinDot )
	Globalize( FighterGetAttackPosForIndex )

	level.fighterAttackPatterns <- {}
	level.fighterAttackPatterns[ "curve" ] <- [ "ht_carrier_attack_1", "ht_carrier_launch_2", "ht_carrier_launch_3" ]
	level.fighterAttackPatterns[ "straight" ] <- [ "ht_carrier_Final_attack_1", "ht_carrier_Final_attack_2" ]
	level.fighterAttackPatterns[ "all" ] <- [ "ht_carrier_attack_1", "ht_carrier_launch_2", "ht_carrier_launch_3", "ht_carrier_Final_attack_1", "ht_carrier_Final_attack_2" ]

	RegisterSignal( "EndFighterWaveAttack" )
}

function CreateFighterTable()
{
	return	{
				model = null,
				attackPattern = "all",
				rocketInfo = null,
				distanceToTarget = 400.0,
				attackAngles = eFighterAngles.TARGET_ANGLES,
				fixedAngles = Vector( 0.0, 0.0, 0.0 ), // only used if attackAngles is set to FIXED_ANGLES
				fixedPoint = Vector( 0.0, 0.0, 0.0 ), // only used if attackAngles is set to FIXED_POINT
				dot = -1
			}
}

function CreateFighterTargetTable()
{
	return	{
				ent = null,
				attachments = [],
				offsets = [],
				staticPositions = []
			}
}

function CreateFighterWaveTable()
{
	return	{
				shipsPerWave = { min = 2, max = 3 },
				shipDelay = { min = 0.4, max = 0.6 },
				numClustersInWave = { min = 2, max = 3 },
				clusterDelay = { min = 1, max = 1.4 },
				waveDelay = { min = 8, max = 16 },
				numWaves = -1
			}
}

function CreateFighterRocketTable()
{
	return	{
				speed = { min = 6000.0, max = 25000.0 },
				fireDistance = { min = 1100, max = 20000 },
				refireDelay = { min = 0.2, max = 0.8 },
				spawnAtAttachments = [ "L_Turret", "R_Turret" ],
				attachmentIterator = 0,
				fxMuzzleFlash = null,
				fxRocket = null,
				fxExplosion = null,
				sndFire = null,
				sndImpact = null,
				inSkybox = false,
				skyboxScale = 0.001,
				attachFxToTarget = false
			}
}

function CreateAttackPosTable( org = Vector( 0.0, 0.0, 0.0 ), ang = ( 0.0, 0.0, 0.0 ) )
{
	return	{
				origin = org,
				angles = ang
			}
}

function FighterGetAttackPositionsWithinDot( fighter, fighterInfo, targetInfo )
{
	local fighterAngles = fighter.GetAngles()
	local fighterForward = fighterAngles.AnglesToForward()

	local attachmentsLen = targetInfo.attachments.len()
	local offsetsLen = targetInfo.offsets.len()
	local staticPositionsLen = targetInfo.staticPositions.len()

	if ( attachmentsLen > 0 )
	{
		local attachmentsInFov = []

		for ( local i = 0; i < attachmentsLen; i++ )
		{
			local attachment = FighterGetAttackPosForIndex( targetInfo, i )
			local attachmentForward = attachment.angles.AnglesToForward()

			local dot = fighterForward.Dot( attachmentForward ) * -1.0

			if ( dot > fighterInfo.dot )
			{
				attachmentsInFov.append( i )
				//DebugDrawLine( attachment.origin, attachment.origin + attachmentForward * 2.0, 255, 255 * ( -0.6 + ( dot * 1.6 ) ), 0, true, 10.0 )
			}

			//DebugDrawLine( attachment.origin, attachment.origin + attachmentForward * 2.0, 255, 255 * ( 0.5 + ( dot * 0.5 ) ), 0, true, 10.0 )
			//DebugDrawLine( fighter.GetOrigin(), fighter.GetOrigin() + fighterForward * 4.0, 255, 150, 255, true, 10.0 )
		}

		return attachmentsInFov
	}
	else if ( offsetsLen > 0 )
	{
		local offsetsInFov = []

		for ( local i = 0; i < offsetsLen; i++ )
		{
			local offset = FighterGetAttackPosForIndex( targetInfo, i )
			local offsetForward = offset.angles.AnglesToForward()

			local dot = fighterForward.Dot( offsetForward ) * -1.0

			if ( dot >= fighterInfo.dot )
			{
				offsetsInFov.append( i )
				//DebugDrawLine( offset.origin, offset.origin + offsetForward * 200.0, 255, 255 * ( 0.5 + ( dot * 0.5 ) ), 0, true, 10.0 )
			}
		}

		return offsetsInFov
	}
	else if ( staticPositionsLen > 0 )
	{
		local offsetsInFov = []

		for ( local i = 0; i < staticPositionsLen; i++ )
		{
			local offsetForward = targetInfo.staticPositions[ i ].forward

			local dot = fighterForward.Dot( offsetForward ) * -1.0

			if ( dot >= fighterInfo.dot )
			{
				offsetsInFov.append( i )
				//DebugDrawLine( targetInfo.staticPositions[ i ].origin, targetInfo.staticPositions[ i ].origin + offsetForward * 200.0, 255, 255 * ( 0.5 + ( dot * 0.5 ) ), 0, true, 10.0 )
			}
		}

		return offsetsInFov
	}
}

function FighterGetAttackPosForIndex( targetInfo, index )
{
	Assert( targetInfo.ent )
	Assert( index >= 0 )

	if ( targetInfo.attachments.len() > 0 )
	{
		local attachment_id = targetInfo.ent.LookupAttachment( targetInfo.attachments[ index ] )
		local attachment_origin = targetInfo.ent.GetAttachmentOrigin( attachment_id )
		local attachment_angles = targetInfo.ent.GetAttachmentAngles( attachment_id )

		return { origin = attachment_origin, angles = attachment_angles }
	}
	else if ( targetInfo.offsets.len() > 0 )
	{
		local targetEntAngles = targetInfo.ent.GetAngles()
		local forward = targetEntAngles.AnglesToForward()
		local right = targetEntAngles.AnglesToRight()
		local up = targetEntAngles.AnglesToUp()

		local offset = targetInfo.offsets[ index ]
		right *= offset.origin.x
		forward *= offset.origin.y
		up *= offset.origin.z

		local offset_origin = targetInfo.ent.GetOrigin() + right + forward + up
		local offset_angles = offset.angles.AnglesCompose( targetInfo.ent.GetAngles() )

		return { origin = offset_origin, angles = offset_angles }
	}
	else if ( targetInfo.staticPositions.len() > 0 )
	{
		return { origin = targetInfo.staticPositions[ index ].origin, angles = targetInfo.staticPositions[ index ].angles }
	}
}

function FighterGetAttackPosCount( targetInfo )
{
	local numAttachments = targetInfo.attachments.len()
	if ( numAttachments > 0 )
		return numAttachments
	return targetInfo.offsets.len()
}

function FighterWaveAttack( fighterInfo, targetInfo, waveInfo )
{
	if ( !IsAlive( targetInfo.ent ) )
		return

	targetInfo.ent.EndSignal( "OnDestroy" )
	targetInfo.ent.EndSignal( "EndFighterWaveAttack" )

	local attackPosCount = FighterGetAttackPosCount( targetInfo )

	for ( local i = 0; ( waveInfo.numWaves == -1 ) || ( i < waveInfo.numWaves ); i++ )
	{
		// firstIndexToAttack determines which attachment the fighter flies towards, not necessarily which one they shoot at
		local firstIndexToAttack = RandomInt( attackPosCount )
		local numClusters = RandomInt( waveInfo.numClustersInWave.min, waveInfo.numClustersInWave.max + 1 )
		for ( local c = 0; c < numClusters; c++ )
		{
			local numShips = RandomInt( waveInfo.shipsPerWave.min, waveInfo.shipsPerWave.max + 1 )
			for ( local i = 0; i < numShips; i++ )
			{
				local index = ( firstIndexToAttack + i ) % attackPosCount
				thread SpawnFighterToAttack( fighterInfo, targetInfo, index )
				wait RandomFloat( waveInfo.shipDelay.min, waveInfo.shipDelay.max )
			}

			wait RandomFloat( waveInfo.clusterDelay.min, waveInfo.clusterDelay.max )
		}

		wait RandomFloat( waveInfo.waveDelay.min, waveInfo.waveDelay.max )
	}
}

function SpawnFighterToAttack( fighterInfo, targetInfo, index )
{
	local fighter = CreatePropDynamic( fighterInfo.model, Vector( 0.0, 0.0, 0.0 ), Vector( 0.0, 0.0, 0.0 ) )

	fighter.EndSignal( "OnDestroy" )
	fighter.SetFadeDistance( 36000.0 )
	fighter.EnableRenderAlways()

	local attackPosInfo = FighterGetAttackPosForIndex( targetInfo, index )

	if ( fighterInfo.attackAngles == eFighterAngles.FACE_ORIGIN )
	{
		local diff = attackPosInfo.origin - targetInfo.ent.GetOrigin()
		local angles = VectorToAngles( diff )
		attackPosInfo.angles = angles
	}
	else if ( fighterInfo.attackAngles == eFighterAngles.FACE_ORIGIN_2D )
	{
		local diff = attackPosInfo.origin - targetInfo.ent.GetOrigin()
		diff.z = 0.0
		local angles = VectorToAngles( diff )
		attackPosInfo.angles = angles
	}
	else if ( fighterInfo.attackAngles == eFighterAngles.FIXED_ANGLES )
	{
		attackPosInfo.angles = fighterInfo.fixedAngles
	}
	else if ( fighterInfo.attackAngles == eFighterAngles.FIXED_POINT )
	{
		local diff = fighterInfo.fixedPoint - attackPosInfo.origin
		local angles = VectorToAngles( diff )
		attackPosInfo.angles = VectorToAngles( angles )
	}
	else if ( fighterInfo.attackAngles == eFighterAngles.FIXED_POINT_2D )
	{
		local diff = fighterInfo.fixedPoint - attackPosInfo.origin
		diff.z = 0.0
		local angles = VectorToAngles( diff )
		attackPosInfo.angles = angles
	}

	if ( fighterInfo.distanceToTarget > 0.0 )
	{
		local original = attackPosInfo.origin

		local forward = attackPosInfo.angles.AnglesToForward()
		attackPosInfo.origin = attackPosInfo.origin + ( forward * fighterInfo.distanceToTarget )
	}

	fighter.SetOrigin( attackPosInfo.origin )
	fighter.SetAngles( attackPosInfo.angles )

	thread FighterShootRockets( fighter, fighterInfo, targetInfo, attackPosInfo, index )

	//thread DebugDrawOriginMovement( fighter, 0.0, 0.0, 255.0, 9999.0, 2.0 )

	local anims = level.fighterAttackPatterns[ fighterInfo.attackPattern ]
	local anim = Random( anims )
	waitthread PlayAnimTeleport( fighter, anim, attackPosInfo.origin, attackPosInfo.angles )

	fighter.Destroy()
}

function FighterShootRockets( fighter, fighterInfo, targetInfo, attackPosInfo, index )
{
	Assert( IsValid( fighter ) )
	Assert( IsValid( fighterInfo.rocketInfo ) )

	fighter.EndSignal( "OnDestroy" )
	targetInfo.ent.EndSignal( "OnDestroy" )

	wait( 0.5 ) // wait for anim to start

	local fireDistanceMinSqr = fighterInfo.rocketInfo.fireDistance.min * fighterInfo.rocketInfo.fireDistance.min
	local fireDistanceMaxSqr = fighterInfo.rocketInfo.fireDistance.max * fighterInfo.rocketInfo.fireDistance.max

	attackPosInfo = FighterGetAttackPosForIndex( targetInfo, index ) // need to update here for distSqr to be accurate
	local distSqr = DistanceSqr( fighter.GetOrigin(), attackPosInfo.origin )
	local oldDistSqr = distSqr + ( fireDistanceMinSqr * 0.1 )

	local firstShot = true
	local attackPositions = []
	local attackPositionsIndex = RandomInt( 100 )

	while ( true )
	{
		if ( distSqr > fireDistanceMaxSqr )
		{
			wait( 0.1 )
			continue
		}
		if ( distSqr < fireDistanceMinSqr )
			break
		if ( distSqr < oldDistSqr )
		{
			// fudge oldDistSqr so the thread doesn't end due to anim moving away slightly from attack position
			oldDistSqr = distSqr + ( fireDistanceMinSqr * 0.1 )
		}
		else if ( distSqr > oldDistSqr )
			break // fighter moving away from attack position

		if ( firstShot )
		{
			if ( fighterInfo.dot > -1.0 )
				attackPositions = FighterGetAttackPositionsWithinDot( fighter, fighterInfo, targetInfo )
			else
			{
				local numAttachments = targetInfo.attachments.len()
				if ( numAttachments > 0 )
					attackPositions = targetInfo.attachments
				else
					attackPositions = targetInfo.offsets
			}

			if ( attackPositions.len() <= 0 )
			{
				wait( 0.1 )
				continue
			}

			firstShot = false
		}

		attackPositionsIndex = ( attackPositionsIndex + 1 ) % attackPositions.len()
		thread FighterFireRocket( fighter, fighterInfo.rocketInfo, targetInfo, attackPosInfo, attackPositions[ attackPositionsIndex ] )

		wait RandomFloat( fighterInfo.rocketInfo.refireDelay.min, fighterInfo.rocketInfo.refireDelay.max )

		attackPosInfo = FighterGetAttackPosForIndex( targetInfo, index )
		distSqr = DistanceSqr( fighter.GetOrigin(), attackPosInfo.origin )
	}
}

function FighterFireRocket( fighter, rocketInfo, targetInfo, attackPosInfo, index )
{
	Assert( fighter )
	Assert( targetInfo.ent )

	// create the rocket
	Assert( rocketInfo.spawnAtAttachments.len() > 0 )

	local attachmentIndex = rocketInfo.attachmentIterator++ % rocketInfo.spawnAtAttachments.len()
	local rocketOrgID = fighter.LookupAttachment( rocketInfo.spawnAtAttachments[ attachmentIndex ] )
	Assert( rocketOrgID > 0, "Invalid attachment ( " + rocketInfo.spawnAtAttachments[ attachmentIndex ] + " ) specified for fighter" )

	local rocketOrg = fighter.GetAttachmentOrigin( rocketOrgID )

	local targetOrg = attackPosInfo.origin
	local vecToTarget = rocketOrg - targetOrg
	local anglesToTarget = VectorToAngles( vecToTarget )

	local rocket = CreateClientsideScriptMover( "models/dev/empty_model.mdl", rocketOrg, anglesToTarget )

	// muzzle FX
	if ( rocketInfo.fxMuzzleFlash )
	{
		local muzzleFlashID = GetParticleSystemIndex( rocketInfo.fxMuzzleFlash )
		StartParticleEffectOnEntity( fighter, muzzleFlashID, FX_PATTACH_POINT_FOLLOW, rocketOrgID )
	}

	wait( 0.0 ) // staggers StartParticleEffectOnEntity from rocketInfo.fxMuzzleFlash and rocketInfo.fxRocket

	// rocket FX
	local particleFX = null
	if ( rocketInfo.fxRocket )
	{
		local fxID = GetParticleSystemIndex( rocketInfo.fxRocket )
		local attachID = rocket.LookupAttachment( "REF" )
		particleFX = StartParticleEffectOnEntity( rocket, fxID, FX_PATTACH_POINT_FOLLOW, attachID )
	}

	if ( rocketInfo.sndFire )
	{
		local shipOrg = fighter.GetOrigin()
		if ( rocketInfo.inSkybox )
			EmitSkyboxSoundAtPosition( shipOrg, rocketInfo.sndFire, rocketInfo.skyboxScale )
		else
			EmitSoundAtPosition( shipOrg, rocketInfo.sndFire )
	}

	//thread DebugDrawOriginMovement( rocket, 0.0, 255.0, 255.0, 9999.0, 2.0 )

	local dist
	local travelTime
	local speed = RandomFloat( rocketInfo.speed.min, rocketInfo.speed.max )

	while ( true )
	{
		if ( !IsValid( targetInfo.ent ) )
			break

		attackPosInfo = FighterGetAttackPosForIndex( targetInfo, index )

		dist = Distance( rocket.GetOrigin(), attackPosInfo.origin )
		if ( dist <= 0 )
			break

		travelTime = Graph( dist, 0, speed, 0, 1.0 )

		rocket.NonPhysicsMoveTo( attackPosInfo.origin, travelTime, 0, 0 )

		if ( travelTime < 0.1 )
		{
			wait( travelTime )
			break
		}

		wait( 0.1 )
	}

	if ( particleFX )
		EffectStop( particleFX, false, true )

	if ( IsValid( targetInfo.ent ) )
	{
		attackPosInfo = FighterGetAttackPosForIndex( targetInfo, index )

		if ( rocketInfo.sndImpact )
		{
			if ( rocketInfo.inSkybox )
				EmitSkyboxSoundAtPosition( attackPosInfo.origin, rocketInfo.sndImpact, rocketInfo.skyboxScale )
			else
				EmitSoundAtPosition( attackPosInfo.origin, rocketInfo.sndImpact )
		}

		if ( rocketInfo.fxExplosion )
		{
			local explosionID = GetParticleSystemIndex( rocketInfo.fxExplosion )
			local offset = attackPosInfo.origin - targetInfo.ent.GetOrigin()

			if ( rocketInfo.attachFxToTarget )
				StartParticleEffectOnEntityWithPos( targetInfo.ent, explosionID, FX_PATTACH_ABSORIGIN_FOLLOW, -1, offset, attackPosInfo.angles )
			else
				StartParticleEffectInWorld( explosionID, attackPosInfo.origin, attackPosInfo.angles )
		}

	}

	rocket.Destroy()
}