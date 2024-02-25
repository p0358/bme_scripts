
PrecacheEffect( "wpn_laser_beam" )

const FLYBY_STRAIGHT_SPEED = 5000
const SEARCH_DRONE_MOVE_RATE = 800
const SEARCH_DRONE_HEALTH = 350

level.activeSearchShips <- []
level.activeSearchDrones <- []
level.leviathanCount <- 0

function main()
{
	Globalize( Moment_Flyover_Straight )
	Globalize( Moment_Flyover_Straight_Multi )
	Globalize( Moment_Dropship_TouchAndGo )
	Globalize( Moment_Dropship_Dropoff_NoAI )
	Globalize( Moment_Dropship_Takeoff )
	Globalize( Moment_Fracture_Dogfight )
	Globalize( Leviathan_Spawn )
	Globalize( SearchShip_Phantom_Spawn )
	Globalize( SearchShip_Drone_Spawn )
	Globalize( DoServerSideCinematicMPMoment )
	Globalize( PaulTestDogfight )
	Globalize( SetLeviathanLevelFunc )


	AddDamageCallback( "prop_dynamic", SearchShip_TookDamage )

	RegisterSignal( "DroneCrashing" )
	RegisterSignal( "LevelFuncDone" )
	RegisterSignal( "EndLeviathanThink" )

	file.leviathanAnimSets <- {}
	file.leviathanAnimSets.dotThresholds <- [ 0.94, 0.819, 0.342, -0.939, -1.0 ]
	file.leviathanAnimSets.slow <-	[
										[ "lev_walk_slow" ],
										[ "lev_walk_slow_left", "lev_walk_slow_right" ],
										[ "lev_walk_slow_left", "lev_walk_slow_right" ],
										[ "lev_walk_slow_left", "lev_walk_slow_right" ],
										[ "lev_walk_slow_left", "lev_walk_slow_right" ]
									]
	file.leviathanAnimSets.fast <-	[
										[ "leviathan_walk_fast" ],
										[ "leviathan_walk_fast_left", "leviathan_walk_fast_right" ],
										[ "leviathan_walk_fast_left_sharp", "leviathan_walk_fast_right_sharp" ],
										[ "leviathan_walk_90turn_left", "leviathan_walk_90turn_right"],
										[ "leviathan_walk_180turn_left", "leviathan_walk_180turn_right" ]
									]
}

function PaulTestDogfight()
{
	local node = level.cinematicNodesByType[ CINEMATIC_TYPES.FRACTURE_DOGFIGHT ][ 0 ]
	thread ShipPlayAnim( node, STRATON_MODEL, "st_gunship_dogfight_C" )
	thread ShipPlayAnim( node, HORNET_MODEL, "ht_gunship_dogfight_C" )
}

function DoServerSideCinematicMPMoment( node )
{
	Assert( node != null )
	Assert( node.type in level.momentServerFunc )
	local funcString = level.momentServerFunc[node.type]
	getroottable()[funcString](node)
}

function Moment_Flyover_Straight( node )
{
	thread FlyoverSingle( node, "fracture_scr_Smallship_Flyover_Single" )
}

function Moment_Flyover_Straight_Multi( node )
{
	local delay = 0.0
	local childNodes = clone node.childNodes
	ArrayRandomize( childNodes )
	local soundAlias
	foreach( index, childNode in childNodes )
	{
		soundAlias = index == 0 ? "fracture_scr_Smallship_Flyover_Group" : null
		wait 0.2
		thread FlyoverSingle( childNode, soundAlias )
	}
}

function Moment_Dropship_TouchAndGo( node )
{
	//printt( "Moment_Dropship_TouchAndGo" )

	if ( "active" in node )
		return
	node.active <- true

	// Spawn a dropship
	local dropship = SpawnAnimatedDropship( node.pos, TEAM_MILITIA, null, null, null, CROW_MODEL )
	dropship.EndSignal( "OnDestroy" )

	dropship.SetOrigin( node.pos )
	dropship.SetAngles( node.ang )
	dropship.SetNoTarget( true )
	dropship.SetNoTargetSmartAmmo( true )

	local pos = node.pos + Vector( 0, 0, -640 )
	local ang = node.ang

	OnThreadEnd(
		function() : ( node, dropship )
		{
			delete node.active
			if ( IsValid( dropship ) )
				dropship.Destroy()
		}
	)

	// Play anim
	waitthread PlayAnimTeleport( dropship, "refueling_sequence_start", pos, ang )
	thread PlayAnimTeleport( dropship, "refueling_sequence_idle", pos, ang )
	wait RandomFloat( 5, 15 )
	waitthread PlayAnimTeleport( dropship, "refueling_sequence_end", pos, ang )
}

function Moment_Dropship_Dropoff_NoAI( node, sfx = null )
{
	thread ShipPlayAnim( node, DROPSHIP_MODEL, "gd_goblin_zipline_strafe", sfx )
}

function Moment_Dropship_Takeoff( node, model = DROPSHIP_MODEL, sfx = null )
{
	// Spawn a dropship
	local dropship
	switch( model )
	{
		case DROPSHIP_MODEL:
			dropship = SpawnAnimatedGunship( node.pos, TEAM_IMC, null, null, null, model )
			break

		case CROW_MODEL:
			dropship = SpawnAnimatedDropship( node.pos, TEAM_MILITIA, null, null, null, model )
			break

		default:
			Assert( 0 )
			break
	}

	dropship.SetOrigin( node.pos )
	dropship.SetAngles( node.ang )
	dropship.SetNoTarget( true )
	dropship.SetNoTargetSmartAmmo( true )

	OnThreadEnd(
		function() : ( dropship )
		{
			if ( IsValid( dropship ) )
				dropship.Kill()
		}
	)

	dropship.EndSignal( "OnDeath" )

	// Play anim
	thread PlayAnimTeleport( dropship, "test_runway_idle", node.pos, node.ang )

	wait 3.0
	if ( sfx != null )
		EmitSoundOnEntity( dropship, sfx )
	waitthread PlayAnim( dropship, "test_takeoff", node.pos, node.ang )

	local anim = "refueling_sequence_end"
	local origin = HackGetDeltaToRef( dropship.GetOrigin(), dropship.GetAngles(), dropship, anim )

	waitthread PlayAnim( dropship, anim, origin, dropship.GetAngles(), 1.0 )

	wait 0.1 // give it a chance to play warp out
}

function Moment_Fracture_Dogfight( node )
{
	local anim1 = null
	local anim2 = null
	//if ( CoinFlip() )
	//{
		anim1 = "st_gunship_dogfight_C"
		anim2 = "ht_gunship_dogfight_C"
	//}
	//else
	//{
	//	anim1 = "st_gunship_dogfight_B_atk"
	//	anim2 = "st_gunship_dogfight_B_def"
	//}
	Assert( anim1 != null )
	Assert( anim2 != null )

	thread ShipPlayAnim( node, STRATON_MODEL, anim1 )
	thread ShipPlayAnim( node, HORNET_MODEL, anim2 )
}

function FlyoverSingle( node, soundAlias = null )
{
	local delay_soundLead = 2.1
	local delay_effectLead = 0.85
	local delay_shipVisible = 0.5

	local dropshipAngles = VectorToAngles( node.childNodes[0].pos - node.pos )
	//DebugDrawAngles( node.pos, dropshipAngles )

	// Warp in effect and sound
	EmitSoundAtPosition( node.pos, "dropship_warpin" )
	wait delay_soundLead
	local fx = PlayFX( "veh_gunship_warp_FULL", node.pos, dropshipAngles )
	fx.EnableRenderAlways()
	wait delay_effectLead

	// Spawn a dropship
	local dropship = SpawnAnimatedDropship( node.pos, TEAM_MILITIA )
	dropship.SetOrigin( node.pos )
	dropship.SetAngles( dropshipAngles )
	dropship.SetNoTarget( true )
	dropship.SetNoTargetSmartAmmo( true )
	//dropship.Hide()

	// Play sound
	if ( soundAlias != null )
		EmitSoundOnEntity( dropship, soundAlias )

	// Spawn a script mover and parent ship to it
	local mover = CreateScriptMover( dropship )
	mover.SetOrigin( node.pos )
	dropship.SetParent( mover )

	// Get the distance it will travel so we can calulate move time
	local dist = Distance( node.pos, node.childNodes[0].pos )
	local duration = dist / FLYBY_STRAIGHT_SPEED

	// Move the dropship to the end node over time
	mover.MoveTo( node.childNodes[0].pos, duration, 0, 0 )

	// Delete the ship when it gets to the end of it's path
	dropship.EndSignal( "OnDeath" )
	wait duration
	AssertNoPlayerChildren( mover )
	mover.Kill()
	if ( IsAlive( dropship ) )
		WarpoutEffect( dropship )
}

function ShipPlayAnim( node, model, anim, sfx = null )
{
	// Spawn a ref
	local ref = CreateEntity( "info_target" )
	ref.SetOrigin( node.pos )
	ref.SetAngles( node.ang )
	DispatchSpawn( ref, false )

	// Spawn a dropship
	local dropship
	if ( model == STRATON_MODEL || model == HORNET_MODEL )
			dropship = SpawnAnimatedGunship( node.pos, TEAM_MILITIA, null, null, null, model )
	else
			dropship = SpawnAnimatedDropship( node.pos, TEAM_MILITIA, null, null, null, model )

	dropship.SetOrigin( node.pos )
	dropship.SetAngles( node.ang )
	dropship.SetNoTarget( true )
	dropship.SetNoTargetSmartAmmo( true )

	if ( sfx != null )
		EmitSoundOnEntity( dropship, sfx )
	// Play anim
	waitthread PlayAnimTeleport( dropship, anim, ref, 0 )

	// Delete the ref after the anim is done so we dont leak entities
	if ( IsValid( dropship ) )
		dropship.Kill()
	AssertNoPlayerChildren( ref )
	ref.Kill()
}


function Leviathan_Spawn( node )
{
	if ( "leviathan" in node )
	{
		if ( IsValid( node.leviathan ) )
			node.leviathan.Destroy()
		delete node.leviathan
	}

	// spawn a prop_dynamic with the leviathan model
	local origin = node.pos
	local angles = node.ang

	local model = "models/Creatures/leviathan/leviathan_brown_background.mdl"

	if ( "model" in node && node.model != "" )
		model = node.model

	local leviathan = CreatePropDynamic( model, origin, angles )
	leviathan.SetOrigin( origin )	// spawning seems to round origin to closest integer
	leviathan.s.walking <- false
	leviathan.s.first_walk <- true
	leviathan.s.walk_fast <- false
	leviathan.s.Waits <- 0
	leviathan.s.remove_at_path_end <- true
	leviathan.s.use_sharp_turns <- false

	node.leviathan <- leviathan

	// delaythread( 0.1 ) allows us to set .s variables before the think occurs
	delaythread( 0.1 ) Leviathan_Think( leviathan, node )
}

// the level func should set resultTable.resultVar to change the return value
function SetLeviathanLevelFunc( leviathan, func )
{
	Assert( !( "funcTable"  in leviathan.s ) )
	leviathan.s.funcTable <- {}
	leviathan.s.funcTable.func	<- func
	leviathan.s.funcTable.scope	<- this
}

// the level func should set resultTable.resultVar to change the return value
function CallLeviathanLevelFunc( leviathan, var )
{
	if ( !( "funcTable"  in leviathan.s ) )
		return var

	local funcToCall = leviathan.s.funcTable.func
	funcToCall.bindenv( leviathan.s.funcTable.scope )

	local resultTable = { resultVar = var }
	waitthread funcToCall( leviathan, var, resultTable )
	return resultTable.resultVar
}

function Leviathan_Think( leviathan, node )
{
	leviathan.EndSignal( "OnDeath" )
	leviathan.EndSignal( "EndLeviathanThink" )

	while( IsValid( leviathan ) )
	{
		local childNode = Random( node.childNodes )	// return a random child node
		childNode = CallLeviathanLevelFunc( leviathan, childNode )

		if ( !childNode )
			break

		switch( childNode.type )
		{
			case CINEMATIC_TYPES.CHILD:
			case CINEMATIC_TYPES.LEVIATHAN_PATH:
				Leviathan_Walk( leviathan, childNode )
				break
			case CINEMATIC_TYPES.LEVIATHAN_ROAR:
				Leviathan_Walk( leviathan, childNode )	// walk to the node
				Leviathan_Roar( leviathan, childNode )	// do the roar
				break
			case CINEMATIC_TYPES.LEVIATHAN_WAIT:
				Leviathan_Walk( leviathan, childNode )	// walk to the node
				Leviathan_Wait( leviathan, childNode )	// wait
				break
			case CINEMATIC_TYPES.LEVIATHAN_REMOVE:
				Leviathan_Walk( leviathan, childNode )	// walk to the node
				leviathan.Destroy()
				break
			default:
				Assert( false, "Not a valid child node" )
				break
		}

		node = childNode
	}

	if ( IsValid( leviathan ) )
		if ( leviathan.s.remove_at_path_end )
			leviathan.Destroy()
		else
			Leviathan_Wait( leviathan, node )
}

function Leviathan_Walk( leviathan, node )
{
	//printt( " Leviathan_Walk" )
	if ( !leviathan.s.first_walk && !leviathan.s.walking )
	{
		leviathan.s.walking = true
		if ( leviathan.s.walk_fast )
			waitthread PlayAnim( leviathan, "leviathan_trans_2_walk_fast" )
		else
			waitthread PlayAnim( leviathan, "lev_trans_2_walk_slow" )
	}

	local destOrigin = node.pos
	local startOrigin = leviathan.GetOrigin()

	while( IsValid( leviathan ) )
	{
		if ( CallLeviathanLevelFunc( leviathan, false ) )
			break // we are interrupted

		local origin = leviathan.GetOrigin()
		local forward = leviathan.GetForwardVector()
		local right = leviathan.GetRightVector()
		local vectorToDest = destOrigin - origin
		vectorToDest = Vector( vectorToDest.x, vectorToDest.y, 0 )
		local dist = vectorToDest.Norm()	// 2D dist
		local fDot = forward.Dot( vectorToDest )
		local rDot = right.Dot( vectorToDest )

		local anim = ""
		local animSet = file.leviathanAnimSets.slow

		if ( leviathan.s.walk_fast )
			animSet = file.leviathanAnimSets.fast

		foreach ( i, threshold in file.leviathanAnimSets.dotThresholds )
		{
			if ( fDot >= threshold )
			{
				if ( animSet[ i ].len() <= 1 || rDot < 0 )
					anim = animSet[ i ][ 0 ] // straight or left
				else
					anim = animSet[ i ][ 1 ] // right

				break
			}

		}

		local index = leviathan.LookupSequence( anim )
		local endPos = leviathan.GetAnimEndPos( index, 0, 1 )	// whats the 0 and 1 mean?
		local endDist = Distance2D( destOrigin, endPos )
		local startDist = Distance2D( startOrigin, origin )

		local walkCycleDist = Distance2D( origin, endPos ) // the distance the walk cycle moves the leviathan

		// if the walk would get us inside walkCycleDist we are close enough.
		// if the walk will move us farther away from the destination we are also as close as we will get.
		// the leviathan must be closer to the destination then the start
		if ( startDist > dist && ( endDist < walkCycleDist || endDist > dist ) )
			break

		//DebugDrawLine( origin, endPos, 255, 0, 0, true, 500 )
		//DebugDrawText( origin, Time().tostring(), true, 500 )

		if ( leviathan.s.first_walk )
		{
			leviathan.s.first_walk = false
			leviathan.s.walking = true

			// staggers the walk animation
			local anim_start_time = ( leviathan.GetSequenceDuration( anim ) * 0.25 ) * ( level.leviathanCount % 4 )
			level.leviathanCount++
			waitthread PlayAnim( leviathan, anim, null, null, DEFAULT_SCRIPTED_ANIMATION_BLEND_TIME, anim_start_time )
		}
		else
		{
			waitthread PlayAnim( leviathan, anim )
		}
	}
	// printt( "Destination reached" )
}

function Leviathan_Roar( leviathan, node )
{
	if ( CallLeviathanLevelFunc( leviathan, false ) )
		return // we are interrupted

	// come to a stop and play a roar animation
	if ( leviathan.s.walking )
	{
		leviathan.s.walking = false

		if ( leviathan.s.walk_fast )
			waitthread PlayAnim( leviathan, "leviathan_trans_2_idle_fast" )
		else
			waitthread PlayAnim( leviathan, "lev_trans_2_idle" )
	}

	if ( CallLeviathanLevelFunc( leviathan, false ) )
		return // we are interrupted

	local anims = [ "lev_idle_lookup_noloop", "leviathan_reaction_howl" ]
	waitthread PlayAnim( leviathan, Random( anims ) )
}

function Leviathan_Wait( leviathan, node )
{
	if ( CallLeviathanLevelFunc( leviathan, false ) )
		return // we are interrupted

	// Leviathan will stop and wait at this point until the progression reaches 50, 75 or 90 percent or match end.
	local anims = [ "lev_idle_noloop", "lev_idle_lookup_noloop", "leviathan_reaction_small", "leviathan_reaction_howl" ]
	local done = false

	if ( leviathan.s.walking )
	{
		leviathan.s.walking = false

		if ( leviathan.s.walk_fast )
			waitthread PlayAnim( leviathan, "leviathan_trans_2_idle_fast" )
		else
			waitthread PlayAnim( leviathan, "lev_trans_2_idle" )
	}
	if ( CallLeviathanLevelFunc( leviathan, false ) )
		return // we are interrupted

	// always do one idle or the paths might get out of sync.
	waitthread PlayAnim( leviathan, Random( anims ) )

	while( !LeviathanWaitDone( leviathan ) )
	{
		waitthread PlayAnim( leviathan, Random( anims ) )
	}

//	printt( "Leviathan_Wait done" )
	leviathan.s.Waits++
}

function LeviathanWaitDone( leviathan )
{
	local done = false
	local progress = level.nv.matchProgress
	if ( !GameRules.TimeLimitEnabled() )
		progress = max( progress, ( GameTime.PlayingTime() / ( GetTimeLimit_ForGameMode() * 60 ).tofloat() * 100 ).tointeger() )

	if ( leviathan.s.Waits == 0 )
		done = progress > 50
	if ( leviathan.s.Waits == 1 )
		done = progress > 80
	if ( leviathan.s.Waits == 2 )
		done = progress >= 100

	done = CallLeviathanLevelFunc( leviathan, done )

	return done
}

function SearchShip_Phantom_Spawn( node )
{
	local searchShipMover = SearchShip_CreateMover( node, STRATON_MODEL, 6 )

	//##########
	// Dropship
	//##########

	local searchShip = SpawnAnimatedGunship( node.pos, TEAM_IMC, null, null, null, STRATON_MODEL )
	searchShip.s.searchShipMover <- searchShipMover
	searchShip.SetOrigin( searchShipMover.GetOrigin() )
	searchShip.SetAngles( searchShipMover.GetAngles() )
	searchShip.SetNoTarget( true )
	searchShip.SetNoTargetSmartAmmo( true )
	searchShip.SetInvulnerable()
	searchShip.Solid()
	searchShip.SetParent( searchShipMover, "", true, 0 )

	searchShip.Anim_Play( "st_idle_gears_up" )

	EmitSoundOnEntity( searchShip, "AngelCity_Scr_StratonSearchHover" )

	level.activeSearchShips.append( searchShip )

	thread SearchShip_Think( node, searchShipMover, searchShip )
}

function SearchShip_Drone_Spawn( node )
{
	local maxSearchDrones = GetMaxSearchDrones()

	// dont have lots of them in classic
	ArrayRemoveInvalid( level.activeSearchDrones )
	if ( level.activeSearchDrones.len() >= maxSearchDrones )
		return

	local searchShipMover = SearchShip_CreateMover( node, SEARCH_DRONE_MODEL, 6 )
	searchShipMover.SetYawRate( 100 )
	//searchShipMover.Solid()

	//#########
	//  Drone
	//#########

	local searchShip = CreatePropDynamic( SEARCH_DRONE_MODEL, searchShipMover.GetOrigin(), searchShipMover.GetAngles(), 2, 8000 )
	searchShip.s.searchShipMover <- searchShipMover
	searchShip.s.isSearchDrone <- true
	searchShip.s.fakeHealth <- SEARCH_DRONE_HEALTH
	searchShip.s.fakeMaxHealth <- SEARCH_DRONE_HEALTH

	searchShip.SetTeam( TEAM_UNASSIGNED )
	searchShip.SetName( "IMCSearchDrone" )
	searchShip.SetNoTarget( true )
	searchShip.SetNoTargetSmartAmmo( true )
	searchShip.Fire( "SetAnimation", "idle" )
	searchShip.SetHealth( searchShip.s.fakeHealth )
	searchShip.SetDamageNotifications( true )
	searchShip.Solid()
	searchShip.Show()
	searchShip.SetParent( searchShipMover, "", true, 0 )
	searchShip.MarkAsNonMovingAttachment()

	SetObjectCanBeMeleed( searchShip, true )
	SetVisibleEntitiesInConeQueriableEnabled( searchShip, true )

	// Hover sound effect
	EmitSoundOnEntity( searchShip, "AngelCity_Scr_DroneSearchHover" )

	level.activeSearchDrones.append( searchShip )

	thread SearchShip_Think( node, searchShipMover, searchShip )
}

function GetMaxSearchDrones()
{
	local max = 2
	if ( GetCinematicMode() || GetMapName() == "mp_wargames" )
		max = 4

	return max
}
Globalize( GetMaxSearchDrones )


function SearchShip_TookDamage( ship, damageInfo )
{
	if ( !( "isSearchDrone" in ship.s ) )
		return

	if ( ship.s.fakeHealth <= 0 )
		return

	local attacker = damageInfo.GetAttacker()
	if ( IsValid( attacker ) && IsPlayer( attacker ) && IsAlive( attacker ) )
		attacker.NotifyDidDamage( ship, damageInfo.GetHitBox(), damageInfo.GetDamagePosition(), damageInfo.GetCustomDamageType(), damageInfo.GetDamage(), damageInfo.GetDamageFlags(), damageInfo.GetHitGroup(), damageInfo.GetWeapon(), damageInfo.GetDistFromAttackOrigin() )

	// adjust damage for smart pistol
	if ( IsCloakedDrone( ship ) )
	{
		local damageSourceId = damageInfo.GetDamageSourceIdentifier()
		switch( damageSourceId )
		{
			case eDamageSourceId.mp_weapon_smart_pistol:
				local damage = damageInfo.GetDamage()
				damageInfo.SetDamage( damage * 2 ) 	// magic number that make the drones die after a full lockon with the smart pistol.
				break
			default:
				break
		}
	}

	local damageAmount = damageInfo.GetDamage()

	// calculate build time credit
	if ( IsCloakedDrone( ship ) && attacker.IsPlayer() )
	{
		local timerCredit = CalculateBuildTimeCredit( attacker, ship, damageAmount, ship.s.fakeHealth, ship.s.fakeMaxHealth, "cloak_drone_kill_credit", 9 )
		if ( timerCredit )
			DecrementBuildTimer( attacker, timerCredit )
	}

	ship.s.fakeHealth -= damageAmount

	// Smoke effect
	if ( !( "smokeEffect" in ship.s ) && ship.s.fakeHealth <= SEARCH_DRONE_HEALTH * 0.8 )
	{
		ship.s.smokeEffect <- CreateEntity( "info_particle_system" )
		ship.s.smokeEffect.SetOrigin( ship.GetOrigin() + Vector( 0, 0, 40 ) )
		ship.s.smokeEffect.SetAngles( Vector( 0, 0, 0 ) )
		ship.s.smokeEffect.kv.effect_name = "P_drone_dam_smoke"
		ship.s.smokeEffect.kv.start_active = 1
		DispatchSpawn( ship.s.smokeEffect, false )
		ship.s.smokeEffect.SetParent( ship, "", true, 0 )
	}

	//printt( "SEARCH DRONE TOOK", damageAmount, "DAMAGE. NEW HEALTH:", ship.s.fakeHealth )
	if ( ship.s.fakeHealth <= 0 )
	{
		Assert( "searchShipMover" in ship.s )
		local mover = ship.s.searchShipMover
		Assert( IsValid( mover ) )
		thread SearchShip_Drone_Explode( mover, ship )

		// Give points to player for killing it
		local inflictor = damageInfo.GetInflictor()
		local scoreEvent
		if ( IsValid( attacker ) && IsPlayer( attacker ) )
		{
			if ( IsCloakedDrone( ship ) )
			{
				Coop_OnPlayerOrNPCKilled( ship, attacker, damageInfo )
				scoreEvent = "Killed_Cloaking_Drone"
				if ( IsValid( inflictor ) )
				{
					if ( IsTitanNPC( inflictor ) )
						scoreEvent = "Auto_Titan_Killed_Cloaking_Drone"
					else if ( IsPlayerControlledSpectre( inflictor) )
						scoreEvent = "Flipped_Spectre_Killed_Cloaking_Drone"
					else if ( IsPlayerControlledTurret( inflictor ) )
						scoreEvent = "Auto_Turret_Killed_Cloaking_Drone"
				}
			}
			else if ( attacker.GetTeam() == TEAM_MILITIA )
			{
				scoreEvent = "AngelCity_SearchDroneKill"
			}
		}
		if ( scoreEvent != null )
			AddPlayerScore( attacker, scoreEvent, ship )
	}
}

function SearchShip_Drone_Explode( mover, drone )
{
	// Explosion effect
	local explosion = CreateEntity( "info_particle_system" )
	explosion.SetOrigin( drone.GetWorldSpaceCenter() )
	explosion.SetAngles( drone.GetAngles() )
	explosion.kv.effect_name = "P_drone_exp_md"
	explosion.kv.start_active = 1
	DispatchSpawn( explosion, false )

	if ( IsCloakedDrone( drone ) )
		EmitSoundAtPosition( drone.GetOrigin(), "CloakDrone_Explode" )
	else
		EmitSoundAtPosition( drone.GetOrigin(), "AngelCity_Scr_DroneExplodes" )

	// Delete the drone and mover
	if ( "smokeEffect" in drone.s )
		drone.s.smokeEffect.Kill()
	explosion.Kill( 3 )
	SearchShip_Delete( mover, drone )
}

function SearchShip_CreateMover( node, model, solidValue = 0, fadeDist = null, custom_health = null )
{
	local searchShipMover = CreateEntity( "script_mover" )
	searchShipMover.kv.solid = solidValue
	searchShipMover.kv.model = model
	searchShipMover.kv.SpawnAsPhysicsMover = 1
	if ( fadeDist != null )
		searchShipMover.kv.fadedist = fadeDist
	if ( custom_health != null )
		searchShipMover.kv.custom_health = custom_health
	searchShipMover.SetOrigin( node.pos )
	searchShipMover.SetAngles( node.ang )
	DispatchSpawn( searchShipMover, true )
	searchShipMover.Hide()
	searchShipMover.NotSolid()

	searchShipMover.SetMaxSpeed( SEARCH_DRONE_MOVE_RATE )
	searchShipMover.SetYawRate( 20 )
	searchShipMover.SetDesiredYaw( node.ang.y )
	searchShipMover.SetMoveToPosition( node.pos )
	searchShipMover.SetAccelScale( 1.5 )

	return searchShipMover
}

function SearchShip_Think( node, mover, ship )
{
	Assert( IsValid( mover ) )
	Assert( IsValid( ship ) )
	Assert( mover.GetClassname() == "script_mover" )

	mover.EndSignal( "OnDeath" )
	ship.EndSignal( "OnDeath" )
	mover.EndSignal( "DroneCrashing" )
	ship.EndSignal( "DroneCrashing" )

	while( IsValid( mover ) && IsValid( ship ) )
	{
		local pathNodes = []
		foreach( childNode in node.childNodes )
		{
			if ( childNode.type != CINEMATIC_TYPES.SEARCHSHIP_SEARCH_TARGET )
				pathNodes.append( childNode )
		}
		if ( pathNodes.len() == 0 )
			return
		local childNode = Random( pathNodes )

		switch( childNode.type )
		{
			case CINEMATIC_TYPES.CHILD:
				SearchShip_Move( childNode, mover, ship )
				break
			case CINEMATIC_TYPES.SEARCHSHIP_SEARCH:
				SearchShip_Move( childNode, mover, ship )
				SearchShip_Search( childNode, mover, ship )
				break
			case CINEMATIC_TYPES.SEARCHSHIP_DELETE:
				SearchShip_Move( childNode, mover, ship )
				SearchShip_Delete( mover, ship )
				break
			default:
				Assert( false, "Not a valid child node" )
				break
		}

		node = childNode
	}
}

function SearchShip_Move( node, mover, ship )
{
	mover.EndSignal( "OnDeath" )
	ship.EndSignal( "OnDeath" )
	mover.EndSignal( "DroneCrashing" )
	ship.EndSignal( "DroneCrashing" )

	mover.SetDesiredYaw( node.ang.y )
	mover.SetMoveToPosition( node.pos )

	if ( "isSearchDrone" in ship.s )
		EmitSoundOnEntity( ship, "AngelCity_Scr_DroneSearchMove" )

	local goalRadius = 64 * 64
	while( IsValid( mover ) && DistanceSqr( mover.GetOrigin(), node.pos ) > goalRadius )
		wait 0.5

	if ( IsValid( mover ) )
		wait 1.0
}

function SearchShip_Search( node, mover, ship )
{
	if ( !IsValid( mover ) || !IsValid( ship ) )
		return

	// Determine which scan node to use
	Assert( node.childNodes.len() > 0 )
	local scanNodes = []
	foreach( childNode in node.childNodes )
	{
		if ( childNode.type == CINEMATIC_TYPES.SEARCHSHIP_SEARCH_TARGET )
			scanNodes.append( childNode )
	}
	Assert( scanNodes.len() > 0 )
	local scanNode = Random( scanNodes )

	// Tell client scan effects to play
	local players = GetPlayerArray()
	foreach( player in players )
		Remote.CallFunction_Replay( player, "ServerCallback_Phantom_Scan", mover.GetEncodedEHandle(), ship.GetEncodedEHandle(), node.index, scanNode.index )

	wait 6.5
}

function SearchShip_Delete( mover, ship )
{
	if ( IsValid( mover ) )
		mover.Destroy()

	if ( IsValid( ship ) )
	{
		ArrayRemove( level.activeSearchShips, ship )
		ArrayRemove( level.activeSearchDrones, ship )
		ship.Destroy()
	}
}