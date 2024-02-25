//PrecacheParticleSystem( FX_FLYERDEATH ) -> taking out temporarily, robot deleting old fx
const FLYER_PATH_MODEL = "models/unique/redeye/redeye_flyer_path.mdl"
const FLYER_PATH_500X_MODEL = "models/unique/redeye/redeye_flyer_path_500x.mdl"
const FLYER_PATH_1000X_MODEL = "models/unique/redeye/redeye_flyer_path_1000x.mdl"

PrecacheModel( FLYER_PATH_MODEL )
PrecacheModel( FLYER_PATH_500X_MODEL )
PrecacheModel( FLYER_PATH_1000X_MODEL )
PrecacheModel( FLYER_MODEL_STATIC )
PrecacheModel( FLYER_MODEL )
PrecacheModel( FLYER_500X_MODEL )
PrecacheModel( FLYER_1000X_MODEL )
//PrecacheModel( "models/creatures/flyer/flyer_optimized.mdl" )

RegisterSignal( "FlyerNewPath" )
RegisterSignal( "KillFlyer" )

enum flyerState
{
	idle,
	takeOff
	takeOffFast
}

function main()
{
	RegisterSignal( "FlyerDeath" )
	RegisterSignal( "StopPerchedIdle" )
	RegisterSignal( "PickupAborted" )
	RegisterSignal( "EndAddToSequence" )

		//HACK FOR NOW
	if( IsClient() )
	{
		RegisterSignal( "OnDeath" )
		RegisterSignal( "OnBreak" )
	}

	level.flyer_cheap_mix_count	<- 0
	level.flyer_cheap_mix_value	<- 0
	level.flyer_swarm_mix_value	<- 0
	level.circlingFlyers		<- {}

	level.XWING_GROUP_ANIM_VARIATIONS <- []
	level.XWING_GROUP_ANIM_VARIATIONS.append( "a" )
	level.XWING_GROUP_ANIM_VARIATIONS.append( "b" )
	level.XWING_GROUP_ANIM_VARIATIONS.append( "c" )
	level.XWING_GROUP_ANIM_VARIATIONS.append( "d" )
	level.XWING_GROUP_ANIM_VARIATIONS.append( "e" )
	level.XWING_GROUP_ANIM_VARIATIONS.append( "f" )
	level.XWING_GROUP_ANIM_VARIATIONS.append( "g" )
	level.XWING_GROUP_ANIM_VARIATIONS.append( "h" )
	level.XWING_GROUP_ANIM_VARIATIONS.append( "i" )
	level.XWING_GROUP_ANIM_VARIATIONS.append( "j" )
	level.XWING_GROUP_ANIM_VARIATIONS.append( "k" )
	level.XWING_GROUP_ANIM_VARIATIONS.append( "l" )
	level.XWING_GROUP_ANIM_VARIATIONS.append( "m" )
	level.XWING_GROUP_ANIM_VARIATIONS.append( "n" )
	level.XWING_GROUP_ANIM_VARIATIONS.append( "o" )
	level.XWING_GROUP_ANIM_VARIATIONS.append( "p" )
	level.XWING_GROUP_ANIM_VARIATIONS.append( "q" )
	level.XWING_GROUP_ANIM_VARIATIONS.append( "r" )
	level.XWING_GROUP_ANIM_VARIATIONS.append( "s" )
	level.XWING_GROUP_ANIM_VARIATIONS.append( "t" )
	level.XWING_GROUP_ANIM_VARIATIONS.append( "u" )
	level.XWING_GROUP_ANIM_VARIATIONS.append( "v" )
	level.XWING_GROUP_ANIM_VARIATIONS.append( "w" )
	level.XWING_GROUP_ANIM_VARIATIONS.append( "x" )
	level.XWING_GROUP_ANIM_VARIATIONS.append( "y" )
	level.XWING_GROUP_ANIM_VARIATIONS.append( "z" )

	level.XWING_FLYING_ANIMS <- []
	level.XWING_FLYING_ANIMS.append( { anim = "fly2", repeat = 6 } )
	level.XWING_FLYING_ANIMS.append( { anim = "flap", repeat = 3 } )
	level.XWING_FLYING_ANIMS.append( { anim = "glide", repeat = 1 } )

	level.DevFlyerCountReal 	<- 0
	level.DevFlyerCountCheap 	<- 0
	level.DevFlyerCountStatic 	<- 0

	level.FlyerPickupAnimations <- [
									 {
									 	name = "normalDive"
									 	flyer = "flyer_PicksUp_Soldier",
									 	npc = "pt_flyer_PicksUp_Soldier",
									 	spectre = "pt_flyer_PicksUp_Spectre",
									 },
									 {
									 	name = "steepDive"
									 	flyer = "flyer_PickingUp_Soldier_dive",
									 	npc = "pt_flyer_pickingup_soldier_dive",
									 	spectre = "pt_flyer_pickingup_spectre_dive",
									 	analysis = null
									 },
									 {
									 	name = "intro"
									 	flyer = "flyer_PicksUp_Soldier_intro",
									 	npc = "pt_flyer_PicksUp_Soldier_intro",
									 	spectre = "pt_flyer_PicksUp_Soldier_intro",
									 }
								   ]

	level.FlyerPickupNodes 	<- {}

	level.dropshipAttackAnims <- {}
	level.dropshipAttackAnims[ DROPSHIP_STRAFE ] <- {
														shipAnim = DROPSHIP_FLYER_ATTACK_ANIM
														flyerArray = [ "flyer_dropshipattack_top", "flyer_dropshipattack_right", "flyer_dropshipattack_cockpit" ]
													}
	level.dropshipAttackAnims[ DROPSHIP_VERTICAL ] <- {
														shipAnim = DROPSHIP_FLYER_ATTACK_ANIM_VERTICAL
														flyerArray = [ "flyer_dropshipattack_vertical_top", "flyer_dropshipattack_vertical_right", "flyer_dropshipattack_vertical_cockpit" ]
													}

	Globalize( CreateFlyerSequence )
	Globalize( AddFlyersToSequence )
	Globalize( DevFlyerPrintCount )
	Globalize( FlyerFlyToPath )
	Globalize( GetCirclingFlyers )

	if ( IsServer() )
	{
		Globalize( NpcFlyerPickupThink )
		Globalize( CreateServerFlyer )
		Globalize( FlyerPickupNpc )
		Globalize( FlyerCrawl )
		Globalize( GetPickupAnimation )
		Globalize( CreatePerchedFlyer )
		Globalize( FlyersAttackDropship )
		Globalize( NextDropshipAttackedByFlyers )

		AddDamageCallback( "script_mover", Flyer_TookDamage )

		// used to replace the animation used for dropships dropping off soldiers by zipline
		// only works with RunDropshipDropoff( ... ) in _goblin_dropship.nut
		level.nextDropshipAttackedByFlyers <- false
	}
	if ( IsClient() )
	{
		AddCreateCallback( "script_mover", FlyerCreationCallback )
	}
}


/****************************************************************************************************\
/*
|*										FLIGHT PATHS
\*
\****************************************************************************************************/

function AddFlyersToSequence( sequence, count = 1, spacing = 0 )
{
	sequence.ref.Signal( "EndAddToSequence" )
	sequence.ref.EndSignal( "EndAddToSequence" )

	local ref = sequence.ref
	local currentCount = sequence.numFlyers
	local xanim

	Assert( sequence.singleAnimName || sequence.groupAnimName )

	for( local i = 0; i < sequence.groupAnimMax; i++ )
	{
		if ( sequence.numFlyers >= sequence.num )
			break

		if ( sequence.groupAnimName )
		{
			if ( ArrayContains( sequence.invalidArray, level.XWING_GROUP_ANIM_VARIATIONS[ i ] ) )
				continue

			xanim = sequence.groupAnimName + level.XWING_GROUP_ANIM_VARIATIONS[ i ]
			if ( xanim in sequence.pathsInUse )
				continue
		}
		else
		{
			xanim = sequence.singleAnimName
		}

		count--
		if ( count < 0 )
			break

		sequence.pathsInUse[ xanim ] <- true
		thread _FlyerSingleAnim( sequence, xanim, ref )
		wait spacing
	}

	return sequence.groupAnimMax - sequence.numFlyers
}

function _FlyerSingleAnim( sequence, xanim, ref )
{
	//increment flyers on the ref
	sequence.numFlyers++

	// Spawn path
	local path = _CreatePath( sequence )

	//spawn flyer
	local flyer = _CreateProperFlyer( sequence, path, ref )

	flyer.EndSignal( "OnBreak" )
	flyer.EndSignal( "OnDestroy" )
	flyer.EndSignal( "OnDeath" )
	flyer.EndSignal( "KillFlyer" )

	if ( IsServer() )
		flyer.Hide()
	else
	if ( IsClient() )
		flyer.clHide()

	delaythread( 0.2 ) ShowEnt( flyer )

	flyer.s.endFunc <- sequence.endFunc
	flyer.s.xanim <- xanim

	flyer.s.initialPathTime <- -1.0
	if ( sequence.startDirection )
		flyer.s.initialPathTime = GetBestStartTimeForDirection( path, xanim, sequence.startDirection )

	//want this flyer to run a special func?
	if ( sequence.runFunc )
		if ( sequence.runFuncOptionalVar != null )
			waitthread sequence.runFunc( flyer, sequence.runFuncOptionalVar )
		else
			waitthread sequence.runFunc( flyer )

	//play the flapping wing animation on the animation path
	thread _LoopFlyerAnimOnPath( flyer, path )

	if ( flyer.s.initialPathTime > 0.0 )
		PlayAnimTeleport( path, xanim, ref, "ref", flyer.s.initialPathTime )
	else
		PlayAnimTeleport( path, xanim, ref, "ref" )

	flyer.Signal( "KillFlyer" )
}

function _LoopFlyerAnimOnPath( flyer, path )
{
	flyer.Signal( "FlyerNewPath" )

	flyer.EndSignal( "FlyerNewPath" )
	flyer.EndSignal( "OnBreak" )
	flyer.EndSignal( "OnDestroy" )
	flyer.EndSignal( "OnDeath" )

	local id = path.LookupAttachment( "ATTACH" )
	local origin = path.GetAttachmentOrigin( id )
	local angles = path.GetAttachmentAngles( id )

	// seems like flyer_static_flying doesn't have a REF attachment so SetPartent doesn't move it.
	flyer.SetOrigin( origin )
	flyer.SetAngles( angles )

	flyer.SetParent( path, "ATTACH" )

	if ( flyer.s.flyerType == eFlyerType.Static )
		return

	thread PlayAnim( flyer, "glide", path, "ATTACH", 0 )

	wait RandomFloat( 0.0, 1.0 )

	while( 1 )
	{
		local table = Random( level.XWING_FLYING_ANIMS )
		local repeat = RandomInt( table.repeat, ( table.repeat * 2 ) + 1 )
		for( local i = 0; i < repeat; i++ )
			PlayAnim( flyer, table.anim, path, "ATTACH", 0.5 )
	}
}

function DrawPath( ent, xanim )
{
	local id = ent.LookupAttachment( "ATTACH" )
	local duration = ent.GetSequenceDuration( xanim )
	local time = 0.0
	local color = Vector( RandomInt( 0, 8 ) * 30, RandomInt( 0, 8 ) * 30, RandomInt( 0, 8 ) * 30 )
	local prev = ent.Anim_GetAttachmentAtTime( xanim, "ATTACH", 0.0 )
	DebugDrawLine( ent.GetOrigin(), prev.position, color.x, color.y, color.z, false, 100.0 )

	while ( time < duration )
	{
		time += 0.5
		local current = ent.Anim_GetAttachmentAtTime( xanim, "ATTACH", time )
		DebugDrawLine( current.position, prev.position, color.x, color.y, color.z, false, 100.0 )
		prev = current
	}
}

function GetVelocityOfAnim( ent, anim, tag )
{
	local id = ent.LookupAttachment( tag )
	local first = ent.Anim_GetAttachmentAtTime( anim, tag, 0.0 )
	local second = ent.Anim_GetAttachmentAtTime( anim, tag, 1.0 )

	local dist = Distance( first.position, second.position )
	return dist
}

function GetBestStartTimeForDirection( ent, xanim, start_direction )
{
	local id = ent.LookupAttachment( "ATTACH" )
	local duration = ent.GetSequenceDuration( xanim )
	local time = 0.0
	local prev = ent.Anim_GetAttachmentAtTime( xanim, "ATTACH", 0.0 )
	local bestDot = -1.0
	local bestTime = 0.0

	start_direction.Normalize()

	while ( time < duration )
	{
		time += 1.0
		local current = ent.Anim_GetAttachmentAtTime( xanim, "ATTACH", time )

		local diff = current.position - prev.position
		diff.Normalize()

		local dot = start_direction.Dot( diff )
		if ( dot > bestDot )
		{
			bestDot = dot
			bestTime = time

			if ( dot > 0.95 )
			{
				//DebugDrawLine( current.position, current.position + start_direction * 5.0, 255,255,255, false, 999.0 )
				return time
			}
		}

		prev = current
	}

	local best = ent.Anim_GetAttachmentAtTime( xanim, "ATTACH", bestTime )
	//DebugDrawLine( best.position, best.position + start_direction * 5.0, 255,0,0, false, 999.0 )
	return time
}

function FlyerFlyToPath( flyer, start_offset = Vector( -12000.0, 0.0, 4000.0 ) )
{
	local path = flyer.s.path
	local ref = flyer.s.sequence.ref
	local xanim = flyer.s.xanim

	//DrawPath( path, xanim )

	flyer.EndSignal( "KillFlyer" )
	flyer.EndSignal( "OnDestroy" )
	local animStart = null

	if ( flyer.s.initialPathTime > 0.0 )
	{
		local attachmentAtTime = path.Anim_GetAttachmentAtTime( xanim, "ATTACH", flyer.s.initialPathTime )
		animStart = { origin = attachmentAtTime.position, angles = attachmentAtTime.angle }
	}
	else
		animStart = path.Anim_GetStartForRefEntity( xanim, ref, "ref" )


	local animStartOrg = animStart.origin
	local animStartAng = animStart.angles
	local animStartForward = animStartAng.AnglesToForward()

	local flyerStartOrg = animStartOrg + ( animStartForward * start_offset.x ) + Vector( 0, 0, start_offset.z )
	ClampToWorldspace( flyerStartOrg )

	local dist = Distance( flyerStartOrg, animStartOrg )
	local speed = GetVelocityOfAnim( path, xanim, "ATTACH" )
	local moveTime = dist / speed

	local mover = CreateClientsideScriptMover( "models/dev/empty_model.mdl", flyerStartOrg, animStartAng )
	mover.clHide()

	OnThreadEnd(
		function() : ( flyer, mover )
		{
			local origin
			if ( IsValid( flyer ) )
			{
				if ( GetBugReproNum() != 54905 )
					origin = flyer.GetOrigin()
				flyer.clClearParent()
			}

			if ( IsValid( mover ) )
				mover.Destroy()

			if ( IsValid( flyer ) )
			{
				if ( GetBugReproNum() != 54905 )
					flyer.SetOrigin( origin )
			}
		}
	)

	if ( flyer.s.flyerType != eFlyerType.Static )
	{
		// don't animate if flyerType is eFlyerType.Static
		flyer.Anim_Play( "fly2_loop" )
		flyer.Anim_SetInitialTime( flyer.GetSequenceDuration( "fly2_loop" ) * RandomFloat( 0, 1 ) )
	}

	flyer.SetOrigin( flyerStartOrg )
	flyer.SetAngles( animStartAng )

	flyer.SetParent( mover, "ref" )

	mover.NonPhysicsMoveTo( animStartOrg, moveTime, 0, 0 )

	wait moveTime
}

/****************************************************************************************************\
/*
|*											SPAWNING
\*
\****************************************************************************************************/
function _CreatePath( sequence )
{
	local modelname = FLYER_PATH_MODEL
	if ( sequence.animPaths == eFlyerPathScale.x500 )
	{
		modelname = FLYER_PATH_500X_MODEL
	}
	else if ( sequence.animPaths == eFlyerPathScale.x1000 )
	{
		modelname = FLYER_PATH_1000X_MODEL
	}
	local path = CreatePropDynamic( modelname, sequence.origin, sequence.angles )

	if ( IsServer() )
	{
		path.Hide()
		path.NotSolid()
	}
	else
	if ( IsClient() )
	{
		path.clHide()
	//	path.NotSolid()
	}

	//**********		CODE FEATURE		***********
	//path.kv.spawnflags = 64 //use hitboxes as renderbox

	return path
}

function _CreateProperFlyer( sequence, path, ref )
{
	local flyer
	local flyerType = sequence.flyerType

	switch( flyerType )
	{
		case eFlyerType.Real:
			break
		case eFlyerType.Cheap:
			break
		case eFlyerType.Static:
			break
		case eFlyerType.CheapMix:
			// all odd flyers should be static
			if ( level.flyer_cheap_mix_count % 2 )
				flyerType = eFlyerType.Static
			else
				flyerType = eFlyerType.Cheap
			level.flyer_cheap_mix_count++
			break
	}

	flyer = _CreateFlyer( flyerType, path, ref )

	//ANIM STUFF
	flyer.s.sequence	<- sequence
	flyer.s.flyerType	<- flyerType
	flyer.s.path 		<- path

	level.circlingFlyers[ flyer ] <- flyer

	return flyer
}

function _CreateFlyer( flyerType, path, ref )
{
	local modelname	= null

	switch( flyerType )
	{
		case eFlyerType.Real:
			modelname =  FLYER_MODEL
			level.DevFlyerCountReal++
			break
		case eFlyerType.Cheap:
			modelname =  FLYER_MODEL
//			removed by request from animation. Should we need it we'll re add it later.
//			modelname =  "models/creatures/flyer/flyer_optimized.mdl"
			level.DevFlyerCountCheap++
			break
		case eFlyerType.Static:
			modelname =  FLYER_MODEL_STATIC
			level.DevFlyerCountStatic++
			break
		case eFlyerType.Cheap500x:
			modelname = FLYER_500X_MODEL
			level.DevFlyerCountCheap++
			break
		case eFlyerType.Cheap1000x:
			modelname = FLYER_1000X_MODEL
			level.DevFlyerCountCheap++
			break
	}

	local flyer	= CreatePropDynamic( modelname, path.GetOrigin(), path.GetAngles() )

	local modelscale = RandomFloat( 0.85, 1.1 )
	local r = RandomInt( 215, 256 )
	local g = RandomInt( 215, 256 )
	local b = RandomInt( 215, 256 )


	//**********		CODE FEATURE		***********
	flyer.kv.fadedist = 14000
	flyer.kv.rendercolor = "" + r + " " + g + " " + b//"255 255 255"
	flyer.kv.modelscale = modelscale
	flyer.kv.solid = 2 // Hitboxes only

	if ( IsServer() )
		flyer.SetHealth( CONSTFLYERHEALTHZERO + CONSTFLYERHEALTH )
//	else
//	if ( IsClient() )
//		flyer.SetHealth( CONSTFLYERHEALTHZERO + CONSTFLYERHEALTH )

	//CLEANUP
	thread _Death( flyer )
	thread _DeathHandlerHax( flyer )
	thread _FlyerCleanUp( flyer )

	return flyer
}

function GetCirclingFlyers()
{
	return level.circlingFlyers
}

/****************************************************************************************************\
/*
|*										CREATE FLYER FUNC
\*
\****************************************************************************************************/

// Mo wrote a create function that does a ton of extra stuff I don't need yet.
// Might merge them eventually.
function CreateServerFlyer( origin, angles, health = 1500, fadeDist = 7000 )
{
	Assert( IsServer() )

	local flyer = CreateEntity( "script_mover" )
	flyer.kv.SpawnAsPhysicsMover = false
	flyer.kv.model = FLYER_MODEL
	flyer.kv.solid = 8  // 0 = no collision, 2 = bounding box, 6 = use vPhysics, 8 = hitboxes only
	flyer.kv.DisableBoneFollowers = 1
	flyer.kv.fadedist = fadeDist
	DispatchSpawn( flyer )

	flyer.SetOrigin( origin )
	flyer.SetAngles( angles )

	flyer.s.isFlyer <- true
	flyer.s.health <- health
	flyer.s.startHealth <- flyer.s.health

	SetVisibleEntitiesInConeQueriableEnabled( flyer, true )
	return flyer
}

function Flyer_TookDamage( flyer, damageInfo )
{
	thread Flyer_TookDamageThread( flyer, damageInfo )
}

function Flyer_TookDamageThread( flyer, damageInfo )
{
	if ( !( "isFlyer" in flyer.s ) )
		return

	if ( flyer.s.health <= 0 )
		return

	local damageAmount = damageInfo.GetDamage()
	local attacker = damageInfo.GetAttacker()

	// adjust damage
	if ( damageAmount >= 500 )
		damageAmount = flyer.s.health
	else if ( attacker && attacker.IsTitan() )
		damageAmount *= 2.5

	if ( IsValid( attacker ) && IsPlayer( attacker ) && IsAlive( attacker ) )
		attacker.NotifyDidDamage( flyer, damageInfo.GetHitBox(), damageInfo.GetDamagePosition(), damageInfo.GetCustomDamageType(), damageAmount, damageInfo.GetDamageFlags(), damageInfo.GetHitGroup(), damageInfo.GetWeapon(), damageInfo.GetDistFromAttackOrigin() )

	flyer.s.health -= damageAmount

	// return if flyer is still alive
	if ( flyer.s.health > 0 )
		return

	// Give points to player for killing it
	if ( IsValid( attacker ) && IsPlayer( attacker ) )
	{
		AddPlayerScore( attacker, "FlyerKill", flyer )
		UpdatePlayerStat( attacker, "kills_stats", "flyers", 1 )
	}

	flyer.Anim_Stop()
	flyer.Signal( "FlyerDeath" )

	if ( attacker && attacker.IsTitan() && damageAmount > 150 )
	{
		// Gib
		local gibModel = "models/gibs/human_gibs.mdl"
		local forceVec = attacker.GetOrigin() - flyer.GetOrigin()
		forceVec.Norm()
		forceVec *= 50.0 // seems like a good number
		flyer.Gib( gibModel, forceVec, false )
	}
	else
	{
		if ( "perched" in flyer.s && flyer.s.perched )
		{
			local duration = flyer.GetSequenceDuration( "flyer_perched_death" )
			thread PlayAnim( flyer, "flyer_perched_death" )
			wait duration - 0.2
		}
		if ( IsValid( flyer) )
			flyer.BecomeRagdoll( flyer.GetVelocity() )
	}
}

function FlyerCreationCallback( entity, isRecreate )
{
	Assert( IsClient() )

	if ( entity.GetModelName() == FLYER_MODEL )
		entity.s.gibDist <- 5120
}

/****************************************************************************************************\
/*
|*										FLYER ATTACK DROPSHIP
\*
\****************************************************************************************************/

// only works with RunDropshipDropoff( ... ) in _goblin_dropship.nut
function NextDropshipAttackedByFlyers( countOverride = 3 )
{
	level.nextDropshipAttackedByFlyers = countOverride
}

function FlyersAttackDropship( ref, animation )
{
	if ( !( animation in level.dropshipAttackAnims ) )
		return animation

	local animTable = level.dropshipAttackAnims[ animation ]

	local count = level.nextDropshipAttackedByFlyers
	level.nextDropshipAttackedByFlyers = false
	thread FlyersAttackDropshipInternal( ref, count, animTable )

	return animTable.shipAnim
}

function FlyersAttackDropshipInternal( ref, flyerCount, animTable )
{
	ref.EndSignal( "OnDestroy" )

	// wait for dropship to warp in.
	ref.WaitSignal( "WarpedIn" )
	wait 0	// have to wait a frame for the animations to line up.

	local animArray = animTable.flyerArray
	local flyerArray = []

	for( local i = 0; i < flyerCount; i++ )
	{
		flyerArray.append( CreateServerFlyer( Vector(0,0,0), Vector(0,0,0), 100000 ) )
	}

	if ( CoinFlip() && flyerCount < 3 )
		animArray[ 1 ] = "flyer_dropshipattack_cockpit"

	OnThreadEnd(
		function() : ( flyerArray )
		{
			local gibModel = "models/gibs/human_gibs.mdl"
			foreach( flyer in flyerArray )
			{
				if ( IsValid( flyer ) )
					flyer.Gib( gibModel, Vector( 0, 0, 0 ), false )
			}
		}
	)

	for( local i = 0; i < flyerCount; i++ )
	{
		thread PlayAnimTeleport( flyerArray[ i ], animArray[ i ], ref )
	}

	flyerArray[0].WaittillAnimDone()
}

/****************************************************************************************************\
/*
|*										FLYER CRAWL
\*
\****************************************************************************************************/

function FlyerCrawl( flyer, path, debugTime = 0 )
{
	Assert( IsServer() )
	Assert( path.len() > 1 )
	flyer.EndSignal( "FlyerDeath" )
	flyer.EndSignal( "OnDestroy" )

	local speed = 100		// units per second
	local moveTime = 0.5 	// 0.2

	flyer.SetOrigin( path[0] )
	flyer.SetAngles( ( path[1] - path[0] ).GetAngles() )
	flyer.Anim_Play( "walk_low" )

	local angles = flyer.GetAngles()

	for( local i = 1; i < path.len(); i++ )
	{
		local dist = Distance( path[ i - 1 ], path[ i ] )
		local vector = angles.AnglesToForward()
		local midPoint = path[ i - 1 ] + vector * dist * 0.5

		dist = Distance( path[ i - 1 ], midPoint )
		dist += Distance( midPoint, path[ i ] )

		if ( debugTime )
		{
			DebugDrawLine( path[ i ] , path[ i ] + Vector( 0,0,50), 255, 0, 255, true, debugTime )
			DebugDrawLine( midPoint, midPoint + Vector( 0,0,50), 0, 255, 255, true, debugTime )
		}

		local steps = dist / ( speed * moveTime )
		steps = format( "%.0f", steps ).tointeger()

		local points = [ path[ i - 1 ], midPoint, path[ i ] ]
		local curvePoints = GetAllPointsOnBezier( points, steps, debugTime )

		for( local cpIndex = 1; cpIndex < curvePoints.len(); cpIndex++ )
		{
			angles = ( curvePoints[ cpIndex ] - curvePoints[ cpIndex - 1 ] ).GetAngles()
			if ( debugTime )
				DebugDrawLine( curvePoints[ cpIndex -1 ], curvePoints[ cpIndex ], 250, 0, 0, true, debugTime )

			flyer.MoveTo( curvePoints[ cpIndex ], moveTime + 0.1, 0, 0 )
			flyer.RotateTo( angles, moveTime + 0.1, 0, 0 )

			wait moveTime
		}
	}

	flyer.BecomeRagdoll( Vector( 0,0,0 ) )
}

/****************************************************************************************************\
/*
|*										FLYER PICKS UP NPC
\*
\****************************************************************************************************/
function GetPickupAnimation( name )
{
	foreach( animation in level.FlyerPickupAnimations )
	{
		if ( animation.name == name )
			return animation
	}
	Assert( false, "The pickup animation you where looking for didn't exist!" )
}

function NpcFlyerPickupThink( frequency )
{
	Assert( IsServer() )

	level.ent.EndSignal( "GameEnd" )

	FlagWait( "FlightAnalysisReady" )
	FlagWait( "IntroDone" )

	local animation = GetPickupAnimation( "steepDive" )
	local analysis = GetAnalysisForModel( FLYER_MODEL, animation.flyer )
	local pickup = CreateCallinTable()
	pickup.style = eDropStyle.FLYER_PICKUP	// make this one not care about yaw
	pickup.dist = 600

	while( true )
	{
		// flyer pickups are more frequent later on in the match.
		local waitMin = GraphCapped( level.nv.matchProgress, 1, 100, frequency.minStart, frequency.minEnd )
		local waitMax = GraphCapped( level.nv.matchProgress, 1, 100, frequency.maxStart, frequency.maxEnd )

		if ( level.isTestmap )
			wait 5
		else
			wait RandomFloat( waitMin, waitMax )

		local npcArray = GetNPCArrayByClass( "npc_soldier" )
		npcArray.extend( GetNPCArrayByClass( "npc_spectre" ) )
		ArrayRandomize( npcArray )

		local spawnpoint = null
		pickup.yaw = RandomInt( 0, 360 )	// I'll make a eDropStyle that doesn't care about yaw

		foreach( npc in npcArray )
		{
			if ( GameModeHasCapturePoints() )
			{
				// can't use NPCs that are using hardpoint terminals
				if (  NPCBusyAtHardpoint( npc ) )
					continue
			}

			// can't use NPCs that are already being picked up
			if ( "flyerPickup" in npc.s )
				continue

			// can't use parented NPCs or ones that are playing animations
			if ( npc.GetParent() || npc.Anim_IsActive() || !IsAlive( npc ) )
				continue

			pickup.origin = npc.GetOrigin()
		 	spawnpoint = GetSpawnPointForStyle( analysis, pickup )
		 	if ( spawnpoint && !( spawnpoint.node in level.FlyerPickupNodes ) )
		 	{
		 		thread RunToPickupPoint( npc, spawnpoint, animation )
			 	break
		 	}
		}
	}
}

function RunToPickupPoint( npc, spawnpoint, animation )
{
	npc.EndSignal( "OnDeath" )
	npc.EndSignal( "OnDestroy" )
	npc.EndSignal( "OnFailedToPath" )

//	thread tempTrack( npc, spawnpoint.origin, spawnpoint.angles )

	level.FlyerPickupNodes[ spawnpoint.node ] <- true

	// remove the npc from his current squad
	SetSquad( npc, UniqueString( "pickup_guy" ) )

	npc.AllowFlee( false )
	npc.AllowHandSignals( false )
	npc.CrouchCombat( false )

	OnThreadEnd(
		function() : ( npc, spawnpoint )
		{
			delete level.FlyerPickupNodes[ spawnpoint.node ]

			if ( !IsValid( npc ) )
				return

			npc.AllowFlee( true )
			npc.AllowHandSignals( true )
			npc.CrouchCombat( true )
			npc.DisableBehavior( "Assault" )
			delete npc.s.flyerPickup
		}
	)

	npc.s.flyerPickup <- true

	Assert( "assaultPoint" in npc.s )

	local assaultPoint = npc.s.assaultPoint
	SetAssaultPointValues( assaultPoint, spawnpoint.origin, spawnpoint.angles )
	npc.AssaultPointEnt( assaultPoint )
	npc.WaitSignal( "OnFinishedAssault" ) // "OnEnterAssaultTolerance"

	thread FlyerPickupNpc( npc, spawnpoint.origin, spawnpoint.angles, animation )
}

function SetAssaultPointValues( assaultPoint, origin, angles )
{
	assaultPoint.kv.stopToFightEnemyRadius = 0
	assaultPoint.kv.allowdiversionradius = 0
	assaultPoint.kv.allowdiversion = 0
	assaultPoint.kv.faceAssaultPointAngles = 1
	assaultPoint.kv.assaulttolerance = 0
	assaultPoint.kv.nevertimeout = 1	// set to 0 to clear assault on reaching assaultpoint
	assaultPoint.kv.strict = 1
	assaultPoint.kv.forcecrouch = 0
	assaultPoint.kv.spawnflags = 0
	assaultPoint.kv.clearoncontact = 0
	assaultPoint.kv.assaulttimeout = 3.0
	assaultPoint.kv.arrivaltolerance = 32
	assaultPoint.SetOrigin( origin )
	assaultPoint.SetAngles( angles )
}

function tempTrack( npc, origin, angles )
{
	npc.EndSignal( "OnFailedToPath" )

	while( IsValid( npc ) )
	{
		DebugDrawLine( origin, origin + Vector( 0,0,100), 255, 0, 0, true, 0.1 )
		DebugDrawLine( npc.GetOrigin(), origin, 0, 255, 0, true, 0.1 )
		DebugDrawLine( origin, origin + angles.AnglesToForward() * 32, 0, 0, 255, true, 0.1 )
		wait 0.1
	}
}

function FlyerPickupNpc( npc, origin, angles, animation, healthOverride = false )
{
	Assert( IsServer() )

	npc.EndSignal( "OnDeath" )
	npc.EndSignal( "OnDestroy" )
	npc.EndSignal( "PickupAborted" )

	if ( npc.ContextAction_IsActive() || npc.ContextAction_IsBusy() )	// not sure how they differ
		return

	if ( !npc.IsInterruptable() )
		return

	OnThreadEnd(
		function() : ( npc )
		{
			if ( IsAlive( npc ) )
			{
				npc.Anim_Stop()
				if ( npc.IsInvulnerable() )
				{
					if ( IsValid( npc.s.dummy) )
					{
						npc.s.dummy.BecomeRagdoll( Vector( 0, 0, 0 ) )
						if ( "weapon" in npc.s.dummy )
							npc.s.dummy.s.weapon.Destroy()
					}
					npc.Destroy()
					return
				}

				npc.ClearInvulnerable()
				npc.SetNoTarget( false )
				npc.SetNoTargetSmartAmmo( false )
				if ( npc.ContextAction_IsBusy() )
					npc.ContextAction_ClearBusy()

				DeleteAnimEvent( npc, "flyer_pickup", PickupEvent )
			}

			if ( IsValid( npc ) )
			{
				npc.Anim_Stop()
				if ( IsValid( npc.s.dummy) )
				{
					RemoveDummy( npc )
				}
			}
		}
	)

	AddAnimEvent( npc, "flyer_pickup", PickupEvent )

	npc.SetNoTarget( true )
	npc.SetNoTargetSmartAmmo( true )
	npc.ContextAction_SetBusy()

	local origin = origin
	local angles = angles

	local animEnt = CreateScriptRef( origin, angles )

	thread Moment_FlyerPickupFlyer( npc, animEnt, animation, healthOverride )

	// NOTE: Idealy we wouldn't ship it this way. Mackey said he would set up a test map and see if he can figure something out.
	local dummy = ReplaceWithDummy( npc )

	if ( npc.IsSpectre() )
	{
		thread PlayAnimTeleport( dummy, animation.spectre, animEnt )
		thread PlayAnimTeleport( npc, animation.spectre, animEnt )
	}
	else
	{
		thread PlayAnimTeleport( dummy, animation.npc, animEnt )
		thread PlayAnimTeleport( npc, animation.npc, animEnt )
	}

	npc.WaittillAnimDone()
}

function ReplaceWithDummy( npc )
{
	npc.Hide()

	local dummy = CreatePropDynamic( npc.GetModelName(), npc.GetOrigin(), npc.GetAngles() )
	npc.s.dummy <- dummy

	local weapon = npc.GetActiveWeapon()
	if ( weapon )
	{
		weapon.Hide()
		local weaponModel = CreatePropPhysics( weapon.GetModelName(), weapon.GetOrigin(), weapon.GetAngles() )
		weaponModel.SetParent( dummy, "PROPGUN", false, 0.0 )
		dummy.s.weapon <- weaponModel
	}

	return dummy
}

function RemoveDummy( npc )
{
	npc.s.dummy.Destroy()
	delete npc.s.dummy

	npc.Show()
	local weapon = npc.GetActiveWeapon()
	if ( weapon )
		weapon.Show()
}

function PickupEvent( npc )
{
	// it is ok for the AI to die before this event but not after.
	npc.SetInvulnerable()
}

function Moment_FlyerPickupFlyer( npc, animEnt, animation, healthOverride )
{
	local origin = animEnt.GetOrigin()
	local angles = animEnt.GetAngles()
	local vector = angles.AnglesToForward()

	local flyerAngles = Vector( angles.x, (angles.y + 180 ) % 360, angles.z )

	local flyer
	if ( healthOverride )
		flyer = CreateServerFlyer( origin, flyerAngles, healthOverride )
	else
		flyer = CreateServerFlyer( origin, flyerAngles )

	local otherTeam = ( npc.GetTeam() == TEAM_IMC ) ? TEAM_MILITIA : TEAM_IMC
	local bullseye = SpawnBullseye( otherTeam, flyer )
	bullseye.ClearParent()
	bullseye.SetParent( flyer, "OFFSET" )
	bullseye.NotSolid()

	flyer.EndSignal( "FlyerDeath" )
	flyer.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( flyer, npc, animEnt )
		{
			if ( IsValid( animEnt ) )
				animEnt.Destroy()

			if ( IsAlive( npc ) )
				npc.Signal( "PickupAborted" )

			if ( IsValid( flyer ) && flyer.s.health > 0)
				flyer.Destroy()
		}
	)

	waitthread PlayAnimTeleport( flyer, animation.flyer, animEnt )
}


/****************************************************************************************************\
/*
|*										FLYER LAND AND PERCH
\*
\****************************************************************************************************/


function CreatePerchedFlyer( origin, angles, land = true, scream = true )
{
	local flyer	= CreateServerFlyer( origin, angles )
	flyer.s.perched <- false

	thread FlyerPerchedThink( flyer, land, scream )
	return flyer
}

function FlyerPerchedThink( flyer, land, scream )
{
	flyer.EndSignal( "FlyerDeath" )
	flyer.EndSignal( "OnDestroy" )

	if ( land )
		waitthread FlyerLand( flyer, flyer.GetOrigin(), flyer.GetAngles() )

	flyer.s.lastScream <- 0
	local prevState
	local state = -1

	while( true )
	{
		prevState = state
		state = CalcFlyerState( flyer )

		switch( state )
		{
			case flyerState.takeOff:
				// flyer flies away
				flyer.s.perched = false
				thread FlyerTakeOff( flyer, false )
				return	// think ends
			case flyerState.takeOffFast:
				// flyer flies away
				flyer.s.perched = false
				thread FlyerTakeOff( flyer, true )
				return	// think ends
			case flyerState.idle:
				flyer.s.perched = true
				if ( prevState != flyerState.idle )
					thread FlyerPerchedIdle( flyer, scream )
				// wait here when the flyer is idling
				waitthread PerchedFlyerWait( flyer, 1.0 )
				WaitEndFrame()	// insures Flyer_TookDamage is run before we loop
				break
		}
	}
}

function PerchedFlyerWait( flyer, waitTime )
{
	flyer.EndSignal( "OnTakeDamage" )
	wait waitTime
}

function CalcFlyerState( flyer )
{
	local players = GetPlayerArray()
	local reactionDistSqr = 1024 * 1024
	local reactionDistFastSqr = 512 * 512

	if ( flyer.s.health != flyer.s.startHealth )
		return flyerState.takeOffFast

	foreach( player in players )
	{
		local distSqr = DistanceSqr( flyer.GetOrigin(), player.GetOrigin() )

		if ( distSqr < reactionDistFastSqr )
			return flyerState.takeOffFast
		if ( distSqr < reactionDistSqr )
			return flyerState.takeOff
	}

	return flyerState.idle
}

function FlyerLand( flyer, origin, angles )
{
	flyer.EndSignal( "FlyerDeath" )
	flyer.EndSignal( "OnDestroy" )

	local animEnt = CreateScriptRef( origin, angles )

	OnThreadEnd(
		function() : ( animEnt )
		{
			// clean up
			IsValid( animEnt )
				animEnt.Destroy()
		}
	)

	waitthread PlayAnimTeleport( flyer, "land_flat", animEnt )
}

function FlyerPerchedIdle( flyer, scream )
{
	flyer.EndSignal( "FlyerDeath" )
	flyer.EndSignal( "OnDestroy" )
	flyer.EndSignal( "StopPerchedIdle" )

	OnThreadEnd(
		function() : ( flyer )
		{
			// clean up
			IsValid( flyer )
				flyer.Anim_Stop()
		}
	)

	local idleArray = []
	idleArray.append( { anim = "flyer_perched_idle",	 weight = 5 } )
	idleArray.append( { anim = "flyer_perched_idlelook", weight = 2 } )
	if ( scream )
		idleArray.append( { anim = "flyer_perched_scream",	 weight = 1 } )

	local result = TraceLine( flyer.GetOrigin() + Vector( 0,0,32 ), flyer.GetOrigin() + Vector( 0,0,-32 ), flyer, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )
	if ( result.surfaceName == "flesh" )
		idleArray.append( { anim = "flyer_perched_feed", weight = 3 } )

	local totalWeight = 0.0
	foreach( idle in idleArray )
		totalWeight += idle.weight

	local anim
	local roll = 0	// start with flyer_perched_idle

	while( IsValid( flyer ) )
	{
		local weight = 0

		foreach( idle in idleArray )
		{
			weight += idle.weight
			if ( roll > ( weight.tofloat() / totalWeight ) )
				continue

			anim = idle.anim
			break
		}

		Assert( anim )
		waitthread PlayAnim( flyer, anim, flyer, "", 1.0 )
		roll = RandomFloat( 0, 1 )
	}
}

function FlyerTakeOff( flyer, fast = false )
{
	flyer.Signal( "StopPerchedIdle" )
	flyer.EndSignal( "FlyerDeath" )
	flyer.EndSignal( "OnDestroy" )

	local takeoffAnim = "flyer_perched_takeoff"
	if ( fast )
		takeoffAnim = "flyer_perched_takeoff_attacked"

	OnThreadEnd(
		function() : ( flyer )
		{
			// clean up
			if ( IsValid( flyer ) && flyer.s.health > 0 )
			{
				flyer.Destroy()
			}
		}
	)

	waitthread PlayAnim( flyer, takeoffAnim, flyer, "", 1.0 )
}

/****************************************************************************************************\
/*
|*											DEATH / CLEANUP
\*
\****************************************************************************************************/
function _Death( flyer )
{
	flyer.EndSignal( "OnDeath" )
	flyer.EndSignal( "OnDestroy" )
	flyer.WaitSignal( "OnBreak" )

	flyer.BecomeRagdoll( Vector( 0, 0, 0 ) )

	flyer.Signal( "KillFlyer" )
}

function _FlyerCleanUp( flyer )
{
	flyer.EndSignal( "OnDeath" )
	flyer.EndSignal( "OnDestroy" )
	flyer.WaitSignal( "KillFlyer" )

	local sequence = flyer.s.sequence

	// release path for this sequence
	delete sequence.pathsInUse[ flyer.s.xanim ]

	// remove flyer from table
	delete level.circlingFlyers[ flyer ]

	// need two get origin here for some strange reason.
	if ( GetBugReproNum() != 54905 )
	{
		flyer.GetOrigin()
		flyer.GetOrigin()
	}

	if ( flyer.Anim_IsActive() )
		flyer.Anim_Stop()

	if ( flyer.s.path )
		flyer.s.path.Anim_Stop()

	if ( IsServer() )
		flyer.ClearParent()
	else
	if ( IsClient() )
		flyer.clClearParent()

	if ( flyer.s.path )
	{
		if ( IsServer() )
			flyer.s.path.Kill()
		else
		if ( IsClient() )
			flyer.s.path.clKill()
	}

	sequence.numFlyers--
	Assert( sequence.numFlyers >= 0 )

	switch( sequence.flyerType )
	{
		case eFlyerType.Real:
			level.DevFlyerCountReal--
			break
		case eFlyerType.Cheap:
			level.DevFlyerCountCheap--
			break
		case eFlyerType.Static:
			level.DevFlyerCountStatic--
			break
		case eFlyerType.CheapMix:
			level.flyer_cheap_mix_count--
			break
	}


	if ( flyer.s.endFunc )
		waitthread flyer.s.endFunc( flyer )

	if ( IsServer() )
		flyer.Kill()
	else if ( IsClient() )
		flyer.clKill()
}

function _DeathHandlerHax( flyer )
{
	flyer.EndSignal( "OnDestroy" )

	local results

	while( flyer.GetHealth() > CONSTFLYERHEALTHZERO )
	{
		results = flyer.WaitSignal( "OnTakeDamage" )
	}

	//flyer.Signal( "OnBreak" )
}


/****************************************************************************************************\
/*
|*											UTILITY
\*
\****************************************************************************************************/
function CreateFlyerSequence( origin, vector )
{
	local sequence = {}
	sequence.num					<- 22
	sequence.groupAnimName			<- null
	sequence.invalidArray			<- []
	sequence.singleAnimName			<- null
	sequence.flyerType				<- null
	sequence.runFunc 				<- null
	sequence.runFuncOptionalVar		<- null
	sequence.runFuncOptionalVar2	<- null
	sequence.endFunc 				<- null
	sequence.origin 				<- origin
	sequence.angles 				<- vector
	sequence.groupAnimMax			<- 22
	sequence.pathsInUse				<- {}
	sequence.ref 					<- CreateRef( sequence )
	sequence.numFlyers				<- 0
	sequence.animPaths 				<- eFlyerPathScale.x1
	sequence.startDirection			<- null

	return sequence
}

function CreateRef( sequence )
{
	local modelname = "models/dev/empty_model.mdl"
	local ref	= CreatePropDynamic( modelname, sequence.origin, sequence.angles )

	if ( IsServer() )
	{
		ref.Hide()
		ref.NotSolid()
	}
	else
	if ( IsClient() )
	{
		ref.clHide()
		//ref.NotSolid()
	}

	return ref
}

function ShowEnt( model )
{
	if ( !IsValid_ThisFrame( model ) )
		return

	if ( IsServer() )
		model.Show()
	else
	if ( IsClient() )
		model.clShow()
}

function DevFlyerPrintCount()
{
	local total

	while( 1 )
	{
		total = ( level.DevFlyerCountReal + level.DevFlyerCountCheap + level.DevFlyerCountStatic )
		printl( "Flyers [T]: " + total + ", [R]: " + level.DevFlyerCountReal + ", [C]: " + level.DevFlyerCountCheap + ", [S]: " + level.DevFlyerCountStatic )
		wait 1
	}
}