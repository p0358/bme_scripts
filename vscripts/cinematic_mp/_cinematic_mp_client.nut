
const SKYBOX_TRACER_MAX_AIM_OFFSET = 75
const SKYBOX_TRACER_AIM_HEIGHT = 75
const SKYBOX_TRACER_FIRE_TIME_MIN = 3.0
const SKYBOX_TRACER_FIRE_TIME_MAX = 8.0
const SKYBOX_TRACER_RELOAD_TIME_MIN = 1.0
const SKYBOX_TRACER_RELOAD_TIME_MAX = 4.0
const SKYBOX_TRACER_MAX_UPDATES_PER_FRAME = 1

RegisterSignal( "SkyboxTracersStart" )

function main()
{
	Globalize( ServerCallback_DoClientSideCinematicMPMoment )
	Globalize( ServerCallback_Phantom_Scan )
	Globalize( FractureSkyboxTracer )
	Globalize( FractureSkyboxTracers_StartAll )
}

function ServerCallback_DoClientSideCinematicMPMoment( nodeIndex )
{
	local node = GetNodeByIndex( nodeIndex )
	Assert( node != null )
	Assert( node.type in level.momentClientFunc )
	local funcString = level.momentClientFunc[node.type]
	getroottable()[funcString](node)
}

function ServerCallback_Phantom_Scan( moverEHandle, shipEHandle, nodeIndex, scanNodeIndex )
{
	// Verify ents
	local mover = GetEntityFromEncodedEHandle( moverEHandle )
	if ( !IsValid( mover ) )
		return

	local ship = GetEntityFromEncodedEHandle( shipEHandle )
	if ( !IsValid( ship ) )
		return

	local node = GetNodeByIndex( nodeIndex )
	Assert( node != null )
	local scanNode = GetNodeByIndex( scanNodeIndex )
	Assert( scanNode != null )
	Assert( scanNode.type == CINEMATIC_TYPES.SEARCHSHIP_SEARCH_TARGET )

	local scanDuration = 6.0
	local effectName = "scan_laser_beam_mdl"
	if ( ship.GetModelName() == SEARCH_DRONE_MODEL )
		effectName = "scan_laser_beam_mdl_sm"

	thread Phantom_ScanSounds( ship, scanDuration )

	// SCAN EFFECT

	local effectIndex = GetParticleSystemIndex( effectName )
	local tagName = "CameraEye"
	local attachID = ship.LookupAttachment( tagName )
	if ( attachID <= 0 )
	{
		tagName = "spotlight"
		attachID = ship.LookupAttachment( tagName )
	}
	Assert( attachID > 0 )

	local attachOrigin = ship.GetAttachmentOrigin( attachID )
	local attachAngles = ship.GetAttachmentAngles( attachID )
	local scanVec = scanNode.pos - attachOrigin
	scanVec.Norm()
	local scanAngles = VectorToAngles( scanVec )

	if ( !( "effectAimer" in ship.s ) )
	{
		local effectAimer = CreatePropDynamic( "models/dev/empty_model.mdl", attachOrigin, scanAngles )
		effectAimer.DisableDraw()
		effectAimer.SetParent( ship, tagName, true, 0 )
		effectAimer.MarkAsNonMovingAttachment()
		ship.s.effectAimer <- effectAimer
		thread Phantom_Remove_EffectsAimer( ship )
	}

	local effectAimerAttachID = ship.s.effectAimer.LookupAttachment( "REF" )
	local effectHandle = StartParticleEffectOnEntity( ship.s.effectAimer, effectIndex, FX_PATTACH_POINT_FOLLOW, effectAimerAttachID )
	thread Phantom_Scan_Stop( ship, effectHandle, scanDuration )
}

function Phantom_Remove_EffectsAimer( ship )
{
	local effectAimer = ship.s.effectAimer
	WaitSignal( ship, "OnDestroy" )
	effectAimer.Kill()
}

function Phantom_Scan_Stop( ship, effectHandle, delay )
{
	OnThreadEnd(
		function () : ( effectHandle )
		{
			if ( EffectDoesExist( effectHandle ) )
				EffectStop( effectHandle, true, true )
		}
	)

	EndSignal( ship, "OnDeath" )
	wait delay
}

function Phantom_ScanSounds( ship, scanDuration )
{
	// scanning
	EmitSoundOnEntity( ship, "AngelCity_Scr_SearchLaserSweep" )

	wait scanDuration

	if ( !IsValid( ship ) )
		return

	// all done
	EmitSoundOnEntity( ship, "Weapon_R1_LaserMine.Deactivate" )
}

function FractureSkyboxTracer( node )
{
	thread FractureSkyboxTracers_StartAll()
}

function FractureSkyboxTracers_StartAll()
{
	level.ent.Signal( "SkyboxTracersStart" )
	level.ent.EndSignal( "SkyboxTracersStart" )

	local nodes = level.cinematicNodesByType[CINEMATIC_TYPES.FRACTURE_SKYBOX_AA_TRACER]

	// Set up the effects
	foreach( node in nodes )
	{
		if ( "tracersInit" in node )
			continue

		node.aimPointBase <- (node.pos + Vector( 0, 0, SKYBOX_TRACER_AIM_HEIGHT ))
		node.nextAimPoint <- node.aimPointBase
		node.lastAimPoint <- node.aimPointBase

		node.moveProgress <- 1.0
		node.moveStartTime <- null
		node.moveDuration <- null

		node.lastUpdateTime <- Time()
		node.fireTimeRemaining <- RandomFloat( SKYBOX_TRACER_FIRE_TIME_MIN, SKYBOX_TRACER_FIRE_TIME_MAX )
		node.reloadTimeRemaining <- RandomFloat( SKYBOX_TRACER_RELOAD_TIME_MIN, SKYBOX_TRACER_RELOAD_TIME_MAX )

		node.effectIndex <- GetParticleSystemIndex( "P_tracers_loop_SBox" )
		node.effect <- StartParticleEffectInWorldWithHandle( node.effectIndex, node.pos, Vector( 0, 0, 1 ) )
		EffectSetDontKillForReplay( node.effect )

		node.tracersInit <- true
	}

	// Update the control point for each effect over time to make tracers arc accross the sky
	local nextUpdateIndex = 0
	local nodeCount = nodes.len()
	while ( GetGameState() <= eGameState.SuddenDeath )
	{
		wait IntervalPerTick()

		SkyboxTracer_Update( nodes[nextUpdateIndex] )

		nextUpdateIndex++
		if ( nextUpdateIndex >= nodeCount )
			nextUpdateIndex = 0
	}

	ArrayRandomize( nodes )
	foreach( node in nodes )
	{
		wait RandomFloat( 1.0, 3.0 )
		EffectSleep( node.effect )
	}
}

function SkyboxTracer_Update( node )
{
	local timeNow = Time()
	local timeElapsedSinceUpdate = (timeNow - node.lastUpdateTime)
	node.lastUpdateTime = timeNow

	//-------------------
	// Update burst fire
	//-------------------
	if ( node.fireTimeRemaining > 0.0 )
	{
		node.fireTimeRemaining -= timeElapsedSinceUpdate
		if ( node.fireTimeRemaining <= 0.0 )
		{
			// Start reload
			EffectSleep( node.effect )
			node.reloadTimeRemaining = RandomFloat( SKYBOX_TRACER_RELOAD_TIME_MIN, SKYBOX_TRACER_RELOAD_TIME_MAX )
			return;
		}
	}
	else if ( node.reloadTimeRemaining > 0.0 )
	{
		node.reloadTimeRemaining -= timeElapsedSinceUpdate
		if ( node.reloadTimeRemaining <= 0.0 )
		{
			// Start firing
			EffectWake( node.effect )
			node.fireTimeRemaining = RandomFloat( SKYBOX_TRACER_FIRE_TIME_MIN, SKYBOX_TRACER_FIRE_TIME_MAX )
		}
		else
		{
			return;
		}
	}

	//------------------
	// Update aim point
	//------------------
	if ( node.moveProgress >= 1.0 )
	{
		// Get a new aim spot:
		node.lastAimPoint = node.nextAimPoint
		node.nextAimPoint = GetRandom3DPointIn2DCircle( SKYBOX_TRACER_MAX_AIM_OFFSET, node.aimPointBase )
		node.moveProgress = 0.0
		node.moveStartTime = timeNow
		node.moveDuration = (node.nextAimPoint - node.lastAimPoint).Length() / 50
		EffectSetControlPointVector( node.effect, 1, node.lastAimPoint )
	}
	else
	{
		// Move aim closer to target:
		local easeAmount = (node.moveDuration * 0.25)
		node.moveProgress = Interpolate( node.moveStartTime, node.moveDuration, easeAmount, easeAmount )
		local currentAimPoint = LerpVector( node.lastAimPoint, node.nextAimPoint, node.moveProgress )
		EffectSetControlPointVector( node.effect, 1, currentAimPoint )
	}
}