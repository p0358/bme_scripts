
const WARN_ABOUT_SKIT_COLLISIONS	= true
const DISPLAY_SKIT_COLLISIONS		= false

const DEBUG_OVERLAY					= false
const DEBUG_ANIMS 					= false
const DEBUG_DONT_START_SKIT 		= false
const DEBUG_PRINTS_LOGIC 			= false
const DEBUG_PRINTS_SKIT 			= false
const DEBUG_PRINTS_PERF				= false
const DEBUG_NIGHTLY_CHAD_ONLY 		= false
const DEBUG_NIGHTLY_CHAD_NAME		= "MeatGrinder (CHAD-RE)"

const MAX_NPC_FOR_SKITS 			= 6			// Max number of AI that can be alive at any given time that are spawned for skits
const MAX_NPC_FOR_SKITS_DURANGO 	= 4			// Max number of AI that can be alive at any given time that are spawned for skits
const SKIT_TIMEOUT 					= 120.0		// Skits will wait to be seen for this amount of time before they abort and try at a new location
const SKIT_START_MIN_DIST			= 640000	// 800^2	Skits wont start if the player the node is visible to isn't within this distance
const SKIT_NO_SPAWN_RADIUS			= 400
const SKIT_VIS_TRIGGER_TIME			= 0.0
const SKIT_VIS_CHECKS_PER_FRAME 	= 2
const SKIT_NODE_INIT_PER_FRAME		= 10
const SKIT_MIN_DISTANCE_APART			= 1000000 	// Skits will not happen within this distance of each other. Dist squared
const SKIT_MIN_DISTANCE_APART_HEIGHT	= 120		// If skits are this far apart on Z axis, the max distance above will be ignored. This allows for 2 skits close together but on seperate floors of a building.
const SKIT_DISTANCE_FORCE_START		= 160000 // 400 ^2

// Performance optimizations
const SKIT_CREATION_MAX_NODE_CHECKS_PER_FRAME = 1	// When looking for a new node to place a skit we have to check it's visibility against all players. This limits the number of nodes that check each server frame. They will all get checked, just not all in 1 frame

traceOffsetsClose <- []
traceOffsetsClose.append( [ Vector( 0, 0, 0 ), Vector( 0, 40, 0 ) ] )		// center
traceOffsetsClose.append( [ Vector( 25, 25, 0 ), Vector( 20, 55, 0 ) ] )	// top left
traceOffsetsClose.append( [ Vector( -25, 25, 0 ), Vector( -20, 55, 0 ) ] )	// top right
traceOffsetsClose.append( [ Vector( 25, -25, 0 ), Vector( 20, 5, 0 ) ] )	// bottom left
traceOffsetsClose.append( [ Vector( -25, -25, 0 ), Vector( -20, 5, 0 ) ] )	// bottom right

traceOffsetsNormal <- []
traceOffsetsNormal.append( [ Vector( 0, 0, 0 ), Vector( 0, 40, 0 ) ] )		// center
traceOffsetsNormal.append( [ Vector( 0, 0, 0 ), Vector( 0, 68, 0 ) ] )		// head
traceOffsetsNormal.append( [ Vector( 0, 0, 0 ), Vector( 0, 3, 0 ) ] )		// feet

traceOffsetsFar <- []
traceOffsetsFar.append( [ Vector( 0, 0, 0 ), Vector( 0, 40, 0 ) ] )			// center

collisionTestGuys <- {}

const TRACE_DISTANCE_CLOSE	= 1210000	// 1100^2	Do more trace checks if within this range
const TRACE_DISTANCE_FAR	= 6250000	// 2500^2	If beyond this distance we do cheaper than normal trace checks

level.aiSkitSlotsUsed <- 0
level.activeSkitRefs <- []
max_npcs_for_skits <- null

RegisterSignal( "StartSkit" )
RegisterSignal( "SkitFinished" )
RegisterSignal( "StopSkit" )
RegisterSignal( "AbortSkit" )
RegisterSignal( "GuysInSkitUpdated" )
RegisterSignal( "DoAISkit" )

// Signals sent from animation
RegisterSignal( "aiskit_doomed" )				// signalled by animation - tells script this guy is "doomed" and about to die. His death no longer stops the anims of other guys in the AI skit
RegisterSignal( "aiskit_dontbreakout" )			// signalled by animation - tells script this guy will continue the animation even if another AI in the skit tells the skit to end
RegisterSignal( "aiskit_alertbreakout" )		// signalled by animation - tells script this guy should break out of the animation if he spots an enemy player
RegisterSignal( "aiskit_forcedeathonskitend" )	// signalled by animation - tells script this guy should just die if the skit ends prematurely

RegisterSignal( "StopDebugSphere" )

function main()
{
	FlagInit( "DisableSkits" )

	Globalize( DoAISkit )
	Globalize( DoPropSkit )
	Globalize( DoPropSkitSearchHole )
	Globalize( AI_Skits_RunSkit )
	Globalize( DropSkitNodeRefToGround )
	Globalize( IsNodeVisibleToAnyone )
	Globalize( GetAllSkitNodes )
	Globalize( CheckForSkitInCollision )
	Globalize( DeleteCollisionTestGuys )
	Globalize( IsInSkit )

	Globalize( DevRunAllSkits )

	level.skitTypes <- []
	level.skitTypes.append( CINEMATIC_TYPES.AI_SKIT_DYING_WALLSLIDE )
	level.skitTypes.append( CINEMATIC_TYPES.AI_SKIT_FIGHT_KNOCKBACK )
	level.skitTypes.append( CINEMATIC_TYPES.AI_SKIT_WOUNDED_DRAG )
	level.skitTypes.append( CINEMATIC_TYPES.AI_SKIT_WOUNDED_CARRY )
	level.skitTypes.append( CINEMATIC_TYPES.AI_SKIT_PRISONER_KILL )
	level.skitTypes.append( CINEMATIC_TYPES.AI_SKIT_SHOTGUN_WALLSLAM )
	level.skitTypes.append( CINEMATIC_TYPES.AI_SKIT_SPECTRE_SPEEDKILL )
	level.skitTypes.append( CINEMATIC_TYPES.AI_SKIT_SPECTRE_NECK_SNAP )
	level.skitTypes.append( CINEMATIC_TYPES.AI_SKIT_LOOT_CORPSE )
	level.skitTypes.append( CINEMATIC_TYPES.AI_SKIT_BRAWL )
	level.skitTypes.append( CINEMATIC_TYPES.AI_SKIT_SPECTRE_BLINDFIRE )
	level.skitTypes.append( CINEMATIC_TYPES.AI_SKIT_SPECTRE_CHESTPUNCH )
	level.skitTypes.append( CINEMATIC_TYPES.AI_SKIT_SPECTRE_CURBSTOMP )
	level.skitTypes.append( CINEMATIC_TYPES.AI_SKIT_SPECTRE_RAILING_SMASH )
	level.skitTypes.append( CINEMATIC_TYPES.AI_SKIT_SPECTRE_BAR_FIGHT )
	level.skitTypes.append( CINEMATIC_TYPES.AI_SKIT_SPECTRE_WINDOW_THROW )
	level.skitTypes.append( CINEMATIC_TYPES.AI_SKIT_SPECTRE_CRAWL )
	level.skitTypes.append( CINEMATIC_TYPES.AI_SKIT_SPECTRE_ZOMBIEDRAG )
	level.skitTypes.append( CINEMATIC_TYPES.AI_SKIT_MELEE_FLIP )
	level.skitTypes.append( CINEMATIC_TYPES.AI_SKIT_SPECTRE_BODYSLAM )

	max_npcs_for_skits = GetCPULevelWrapper() == CPU_LEVEL_DURANGO ? MAX_NPC_FOR_SKITS_DURANGO : MAX_NPC_FOR_SKITS
}

function EntitiesDidLoad()
{
	if ( IsMultiplayer() && IsServer() )
	{
		if ( FlagExists( "GamePlaying" ) && !Flag( "GamePlaying" ) )
			FlagWait( "GamePlaying" )

		if ( GAMETYPE == CAPTURE_POINT )
			SkitSetDistancesToClosestHarpoints()

		wait 1
		thread AI_Skits_Think()
	}
}

function SkitsDisabled()
{
	if ( GetMapName() == "mp_ai_skits" )
		return false

	if ( Riff_AllowNPCs() != eAllowNPCs.Default )
		return true

	return Flag( "DisableSkits" ) || Flag( "disable_npcs" ) || level.UsingCinematicNodeEditor
}

function DebugOverlay()
{
	while( GetPlayerArray().len() == 0 )
		wait 0.5

	local overlayPlayer = null
	if ( DEBUG_NIGHTLY_CHAD_ONLY )
	{
		local players = GetPlayerArray()
		foreach( player in players )
		{
			if ( player.GetPlayerName() == DEBUG_NIGHTLY_CHAD_NAME )
			{
				overlayPlayer = player
				break
			}
		}
	}
	else
		overlayPlayer = GetPlayerArray()[0]

	if ( overlayPlayer == null )
		return

	Hud.Show( overlayPlayer, "aiskit_reserve" )

	while( IsValid( overlayPlayer ) )
	{
		Hud.LabelSetText( overlayPlayer, "aiskit_reserve", "USED SKIT SLOTS: " + level.aiSkitSlotsUsed + "/" + max_npcs_for_skits )
		wait 0
	}
}

function InitNodeForPropSkit( node )
{
	local skitRef = InitRefForNode( node )

	// Drop the ref node to the ground since in the editor it was hovering
	DropSkitNodeRefToGround( skitRef )

	// Store off anim start pos and ang so we dont have to calculate them later
	if ( !( "animStartOrigin" in skitRef.s ) )
		skitRef.s.animStartOrigin <- null
	skitRef.s.animStartOrigin = []

	if ( !( "animStartAngles" in skitRef.s ) )
		skitRef.s.animStartAngles <- null
	skitRef.s.animStartAngles = []

	local nodeSkitAnims = level.animPropSkitData[ skitRef.s.skitType ].skit_anims
	Assert( nodeSkitAnims.len() > 0 )

	DoAnalysisForNode( nodeSkitAnims, node, skitRef )
}

function InitRefForNode( node )
{
	// Create ref node for anim to play on
	if ( !( "skitRef" in node ) )
	{
		local ent = CreateEntity( "ai_skit_node" )
		ent.SetOrigin( node.pos )
		ent.SetAngles( node.ang )
		DispatchSpawn( ent )

		node.skitRef <- ent
		node.skitRef.s.guysInSkitCount <- null
		node.skitRef.s.guysSpawnedForSkit <- null
		node.skitRef.s.guysSpawnedForSkitCount <- null
		node.skitRef.s.skitType <- node.type
	}

	local skitRef = node.skitRef

	skitRef.s.guysInSkitCount = 0
	skitRef.s.guysSpawnedForSkit = []
	skitRef.s.guysSpawnedForSkitCount = 0

	if ( !( "node" in node.skitRef.s ) )
		node.skitRef.s.node <- node

	return node.skitRef
}

function InitNodeForSkit( node )
{
	local skitRef = InitRefForNode( node )

	// Drop the ref node to the ground since in the editor it was hovering
	DropSkitNodeRefToGround( skitRef )

	// Create node vars used in this script
	if ( !( "visibilityDurationsByPlayer" in skitRef.s ) )
		skitRef.s.visibilityDurationsByPlayer <- null
	skitRef.s.visibilityDurationsByPlayer = {}

	if ( !( "nextPlayerIndexForVisibleCheck" in skitRef.s ) )
		skitRef.s.nextPlayerIndexForVisibleCheck <- null
	skitRef.s.nextPlayerIndexForVisibleCheck = 0

	// Store off anim start pos and ang so we dont have to calculate them later
	if ( !( "animStartOrigin" in skitRef.s ) )
		skitRef.s.animStartOrigin <- null
	skitRef.s.animStartOrigin = []

	if ( !( "animStartAngles" in skitRef.s ) )
		skitRef.s.animStartAngles <- null
	skitRef.s.animStartAngles = []

	if ( !( "lastCollisionCheckResult" in skitRef.s ) )
		skitRef.s.lastCollisionCheckResult <- true

	local nodeWaitAnims = level.animSkitData[ skitRef.s.skitType ].wait_anims
	Assert( nodeWaitAnims.len() > 0 )

	DoAnalysisForNode( nodeWaitAnims, node, skitRef )

	if ( IsHighPerfDevServer() )
		CheckForSkitInCollision( skitRef )
}

function DoAnalysisForNode( anims, node, skitRef )
{
	foreach( anim in anims )
	{
		//DebugDrawLine( GetPlayerArray()[0].GetOrigin(), node.pos, 255, 0, 0, true, 30 )
		local offsetAnalysis = GetAnalysisForModel( TEAM_IMC_GRUNT_MDL, anim )
		local animDelta = GetPreviewPoint( offsetAnalysis )
		skitRef.s.animStartOrigin.append( GetOriginFromPoint( animDelta, skitRef.GetOrigin(), node.forward, node.right ) )
		skitRef.s.animStartAngles.append( GetAnglesFromPoint( animDelta, skitRef.GetAngles() ) )
	}
}

function DropSkitNodeRefToGround( skitRef )
{
	local traceResult = TraceLine( skitRef.GetOrigin() + Vector( 0, 0, 32 ), skitRef.GetOrigin() - Vector( 0, 0, 64 ), null, TRACE_MASK_NPCSOLID, TRACE_COLLISION_GROUP_NONE )
	skitRef.SetOrigin( traceResult.endPos + Vector( 0, 0, 1.0 ) )
}

function GetAllSkitNodes()
{
	local allNodes = []
	foreach( type in level.skitTypes )
		ArrayAppend( allNodes, level.cinematicNodesByType[type] )
	return allNodes
}

function DeleteCollisionTestGuys()
{
	foreach( key, guy in collisionTestGuys )
	{
		if ( IsValid( guy ) )
			guy.Kill()
	}
}

function AI_Skits_Think()
{
	if ( DEBUG_OVERLAY || DEBUG_NIGHTLY_CHAD_ONLY )
		thread DebugOverlay()

	local allNodes = GetAllSkitNodes()
	if ( DEBUG_PRINTS_LOGIC )
		printt( "FOUND", allNodes.len(), "SKIT NODES" )
	if ( allNodes.len() == 0 )
		return

	// Spawn a ref for each node and drop it to the ground
	local initCount = 0

	foreach( node in allNodes )
	{
		InitNodeForSkit( node )

		initCount++
		if ( initCount == SKIT_NODE_INIT_PER_FRAME )
		{
			initCount = 0
			wait 0
		}
	}

	DeleteCollisionTestGuys()

	while(1)
	{
		if ( SkitsDisabled() )
			return

		if ( level.UsingCinematicNodeEditor )
			return

		// Get the next node to do a skit on, based on visibility and location
		if ( DEBUG_PRINTS_LOGIC )
			printt( "Looking for new AI Skit node" )

		//print( "\n\n\n\n\n******************skit*************\n\n\n\n\n" )

		local validSkitRefs
		if ( GAMETYPE == CAPTURE_POINT )
			validSkitRefs = GetSkitNodeArray_NearHardpoints()
		else
			validSkitRefs = GetSkitNodeArray_NearPlayers()

		if ( DEBUG_PRINTS_LOGIC )
			printt( validSkitRefs.len(), "valid skit refs - before array removal" )

		//remove any skits that aren't in  ( because those are the only ones that should be called through this system )
		AI_Skits_RemoveNonAutoSkits( validSkitRefs )

		if ( DEBUG_PRINTS_LOGIC )
			printt( validSkitRefs.len(), "valid skit refs - after array removal" )

		local skitNode = GetNextSkitNode_Finalize( validSkitRefs )

		if ( skitNode == null )
		{
			wait 1.0
			continue
		}

		wait 0
		thread AI_Skits_RunSkit( skitNode )

		// Wait till skit is over
		WaitTillSkitSlotsFree( 2 )

		wait 2
	}
}

function AI_Skits_RemoveNonAutoSkits( validSkitRefs )
{
	local nonAuto = []
	foreach ( skit in validSkitRefs )
	{
		if ( !ArrayContains( level.skitTypes, skit.s.node.type ) )
			nonAuto.append( skit )
	}

	foreach( remove in nonAuto )
		ArrayRemove( validSkitRefs, remove )

}

function AI_Skits_RunSkit( skitRef )
{
	if ( level.UsingCinematicNodeEditor )
		return

	// Trigger the skit
	if ( DEBUG_PRINTS_LOGIC )
		printt( "Found AI Skit node - starting" )

	thread DoAISkit( skitRef.s.node )

	if ( DEBUG_DONT_START_SKIT && !level.UsingCinematicNodeEditor )
	{
		while(1)
		{
			if ( AreSkitGuysDead( skitRef ) )
				break
			IsNodeVisibleToAnyone( skitRef )
			wait 0
		}
	}

	// Wait till skit is visible to someone before playing
	local interval = 0.1
	skitRef.s.visibilityDurationsByPlayer = {}
	skitRef.s.nextPlayerIndexForVisibleCheck = 0
	while( !NodeVisibleForTriggerTime( skitRef, interval ) && !AreSkitGuysDead( skitRef ) )
	{
		if ( SkitsDisabled() )
			break

		if ( DEBUG_PRINTS_LOGIC )
			printt( "Waiting for player to see skit" )
		wait interval
	}

	// Signal so skit function can play out
	Signal( skitRef, "StartSkit" )
}

function WaitTillSkitSlotsFree( slotCount )
{
	local freeSlots
	while(1)
	{
		freeSlots = max_npcs_for_skits - level.aiSkitSlotsUsed
		if ( freeSlots >= slotCount )
			break

		if ( DEBUG_PRINTS_LOGIC )
			printt( "Waiting for", slotCount, "free skit slots.", freeSlots, "free now." )
		wait 1
	}

	if ( DEBUG_PRINTS_LOGIC )
		printt( slotCount, "skit slots now free" )
}

function AreSkitGuysDead( skitRef )
{
	ArrayRemoveDead( skitRef.s.guysSpawnedForSkit )
	return skitRef.s.guysSpawnedForSkit.len() != skitRef.s.guysSpawnedForSkitCount
}

function IsSkitGuyNotInterruptableOrParented( skitRef )
{
	foreach( guy in skitRef.s.guysSpawnedForSkit )
	{
		if ( IsValid( guy ) )
		{
			if ( !guy.IsInterruptable() )
				return true
			if ( guy.GetParent() )
				return true
		}
	}
	return false
}

function GetNextSkitNode_Finalize( validSkitRefs )
{
	//###################################################################
	// Loop through all the nodes till we find one not visible to anyone
	//###################################################################

	local nodesCheckedThisFrame = 0
	local totalRefsChecked = 0
	local framesPassed = 1
	local returnRef = null
	foreach( skitRef in validSkitRefs )
	{
		// Don't use test nodes for auto-selection. We control test nodes manually
		if ( skitRef.s.node.testNode == true )
			continue

		// Make sure we aren't going to put a skit nearby another skit
		if ( IsNodeTooCloseToActiveSkit( skitRef ) )
			continue

		totalRefsChecked++
		nodesCheckedThisFrame++

		if ( !IsNodeVisibleToAnyone( skitRef ) )
		{
			returnRef = skitRef
			break
		}

		if ( nodesCheckedThisFrame >= SKIT_CREATION_MAX_NODE_CHECKS_PER_FRAME )
		{
			nodesCheckedThisFrame = 0
			framesPassed++
			wait 0
		}
	}

	if ( DEBUG_PRINTS_PERF )
	{
		printt( "###############################################################" )
		printt( "###############################################################" )
		printt( "FOUND NEXT REF AFTER CHECKING", totalRefsChecked, "REFS OVER", framesPassed, "FRAMES" )
		printt( "###############################################################" )
		printt( "###############################################################" )
	}

	if ( DEBUG_PRINTS_LOGIC )
		printt( "Next skit ref:", returnRef )

	return returnRef
}

function IsNodeTooCloseToActiveSkit( skitRef )
{
	foreach( activeRef in level.activeSkitRefs )
	{
		local zDist = abs( skitRef.GetOrigin().z - activeRef.GetOrigin().z )
		if ( zDist > SKIT_MIN_DISTANCE_APART_HEIGHT )
			continue

		if ( DistanceSqr( skitRef.GetOrigin(), activeRef.GetOrigin() ) < SKIT_MIN_DISTANCE_APART )
			return true
	}

	return false
}

function IsNodeVisibleToAnyone( skitRef )
{
	local players = GetPlayerArray()
	foreach( player in players )
	{
		if ( IsNodeVisibleToPlayer( skitRef, player ) )
			return true
	}
	return false
}

function IsNodeVisibleToPlayer( skitRef, player )
{
	if ( DEBUG_NIGHTLY_CHAD_ONLY && player.GetPlayerName() == DEBUG_NIGHTLY_CHAD_NAME )
		return false

	local isSkitWaitingToStart = skitRef.IsReserved()

	local playerEye = player.EyePosition()
	local vec = skitRef.GetOrigin() - playerEye
	vec.Norm()
	local distanceToNode = DistanceSqr( playerEye, skitRef.GetOrigin() )

	// Forst start the skit if the player is within the force start distance
	if ( distanceToNode <= SKIT_DISTANCE_FORCE_START )
		return true

	// Early out if the node is off screen ( dot check )
	if ( distanceToNode > TRACE_DISTANCE_CLOSE )
	{
		if ( vec.Dot( player.GetViewVector() ) < 0.65 )
			return false
	}

	// If the player is using sonar we act like the skit is visible all the time
	if ( "sonarEndTime" in player.s && player.s.sonarEndTime > Time() )
		return true

	// Node was in view, must do traces to see if visible
	local angles = VectorToAngles( vec )
	local forward = angles.AnglesToForward()
	local right = angles.AnglesToRight()
	local up = angles.AnglesToUp()

	local traceOffsets
	if ( distanceToNode <= TRACE_DISTANCE_CLOSE )//&& !isSkitWaitingToStart )
		traceOffsets = traceOffsetsClose
	else if ( distanceToNode > TRACE_DISTANCE_FAR )
		traceOffsets = traceOffsetsFar
	else
		traceOffsets = traceOffsetsNormal

	// We want to check for each animation that can play on this node since multiple animations have different starting deltas.
	// Doesn't matter if we can see the node or not, what's important is if we can or cant see any of the animation starting points.
	Assert( "skitType" in skitRef.s )
	Assert( skitRef.s.skitType in level.animSkitData, "skitRef.s.skitType index " + skitRef.s.skitType + " is not in level.animSkitData" )
	local nodeWaitAnims = level.animSkitData[ skitRef.s.skitType ].wait_anims
	Assert( nodeWaitAnims.len() > 0 )

	if ( DEBUG_ANIMS )
	{
		DebugDrawLine( skitRef.GetOrigin(), skitRef.GetOrigin() + ( skitRef.s.node.forward * 20 ), 0, 255, 0, true, 0.1 )
		DebugDrawLine( skitRef.GetOrigin(), skitRef.GetOrigin() + ( skitRef.s.node.right * 20), 255, 0, 0, true, 0.1 )
		DebugDrawLine( skitRef.GetOrigin(), skitRef.GetOrigin() + ( skitRef.s.node.up * 20), 0, 0, 255, true, 0.1 )

		foreach( index, anim in nodeWaitAnims )
		{
			DebugDrawLine( skitRef.GetOrigin(), skitRef.s.animStartOrigin[index], 255, 255, 0, true, 0.1 )
			thread DebugDrawCircle( skitRef.s.animStartOrigin[index], Vector( 0, 0, 0 ), 3, 255, 255, 255, 0.1 )
		}
	}

	local traceStart
	local tracePassed
	local traceEnd = null

	local startVecs = []
	local endVecs = []

	foreach ( offset in traceOffsets )
	{
		traceStart = playerEye + ( right * offset[0].x ) + ( up * offset[0].y ) + ( forward * offset[0].z )

		// Not a min/max trace, do it once per AI
		foreach( index, anim in nodeWaitAnims )
		{
			traceEnd = skitRef.s.animStartOrigin[index] + ( right * offset[1].x ) + ( up * offset[1].y ) + ( forward * offset[1].z )

			startVecs.append( traceStart )
			endVecs.append( traceEnd )
		}
	}

	local isVisible = TraceLOSMultiple( startVecs, endVecs, player, TRACE_MASK_BLOCKLOS, TRACE_COLLISION_GROUP_NONE )

	return isVisible
}

function NodeVisibleForTriggerTime( skitRef, interval )
{
	EndSignal( skitRef, "StartSkit" )

	if ( SkitsDisabled() )
		return true

	local players = GetPlayerArray()
	local player

	// Check the maximum number of players allowed this frame
	local numChecks = min( players.len(), SKIT_VIS_CHECKS_PER_FRAME )
	for( local i = 0 ; i < numChecks ; i++ )
	{
		// Get the next player to check
		if ( skitRef.s.nextPlayerIndexForVisibleCheck >= players.len() )
			skitRef.s.nextPlayerIndexForVisibleCheck = 0
		player = players[skitRef.s.nextPlayerIndexForVisibleCheck]
		skitRef.s.nextPlayerIndexForVisibleCheck++

		if ( !( player in skitRef.s.visibilityDurationsByPlayer ) )
			skitRef.s.visibilityDurationsByPlayer[ player ] <- 0.0

		if ( IsNodeVisibleToPlayer( skitRef, player ) )
		{
			skitRef.s.visibilityDurationsByPlayer[ player ] += interval
			if ( skitRef.s.visibilityDurationsByPlayer[ player ] >= SKIT_VIS_TRIGGER_TIME )
				return true
		}
		else
			skitRef.s.visibilityDurationsByPlayer[ player ] = 0.0
	}

	// Debug print table
	if ( DEBUG_PRINTS_LOGIC )
		PrintTable( skitRef.s.visibilityDurationsByPlayer )

	return false
}


function DoAISkit( node )
{
	ResetSkit( node )

	if ( level.UsingCinematicNodeEditor )
	{
		wait 0
		InitNodeForSkit( node )
		wait 0
	}

	Assert( "skitRef" in node )
	local skitRef = node.skitRef

	OnThreadEnd(
		function() : ( skitRef )
		{
			Signal( skitRef, "SkitFinished" )
			if ( DEBUG_PRINTS_SKIT )
				printt( "SKIT FINISHED" )

			skitRef.SetReserved( false )
			ArrayRemove( level.activeSkitRefs, skitRef )

			// Re-allow players to spawn near where the skit was
			if ( "noSpawnAreaIDs" in skitRef.s )
			{
				foreach( id in skitRef.s.noSpawnAreaIDs )
					DeleteNoSpawnArea( id )
			}

			// Re-enable neck snap execution on guy if we previously disabled it
			foreach( guy in skitRef.s.guysSpawnedForSkit )
			{
				if ( IsValid( guy ) && IsAlive( guy ) )
				{
					guy.Anim_Stop()
					guy.SetNoTarget(false)
					guy.SetEfficientMode(false)
					guy.Minimap_DisplayDefault( TEAM_IMC, null )
					guy.Minimap_DisplayDefault( TEAM_MILITIA, null )

					delete guy.s.isInSkit

					SetSilentDeath( guy, false )
					if ( guy.ContextAction_IsBusy() )
						guy.ContextAction_ClearBusy()
				}
			}
		}
	)

	Signal( skitRef, "DoAISkit" )
	EndSignal( skitRef, "DoAISkit" )

	if ( DEBUG_NIGHTLY_CHAD_ONLY )
	{
		local players = GetPlayerArray()
		foreach( player in players )
		{
			if ( player.GetPlayerName() == DEBUG_NIGHTLY_CHAD_NAME )
			{
				Remote.CallFunction_Replay( player, "ServerCallback_AISkitDebugMessage", skitRef.s.node.index, 1 )
				break
			}
		}
	}

	local data = level.animSkitData[ skitRef.s.skitType ]
	if ( !level.UsingCinematicNodeEditor )
		Assert( !skitRef.IsReserved() )

	// Assign teams. Randomly swap the team assignments
	local hasIMC = false
	local hasMilitia = false
	local swapTeams 		= CoinFlip()
	local teamAssignments 	= AssignTeams( data, swapTeams )
	for ( local i = 0 ; i < teamAssignments.len() ; i++ )
	{
		if ( teamAssignments[ i ] == TEAM_IMC )
			hasIMC = true
		else
			hasMilitia = true
	}

	Assert( skitRef.s.guysInSkitCount == 0 )
	skitRef.s.guysSpawnedForSkit = []
	skitRef.s.guysSpawnedForSkitCount = data.wait_anims.len()

	// Reserve the AI slots to be used
	if ( skitRef.s.node.testNode == false )
		level.aiSkitSlotsUsed +=  data.wait_anims.len()

	// Reserve and keep track of active nodes
	skitRef.SetReserved( true )
	level.activeSkitRefs.append( skitRef )

	// Don't let people spawn right by the skit if a guy in the skit is on the opposing team
	if ( !( "noSpawnAreaIDs" in skitRef.s ) )
		skitRef.s.noSpawnAreaIDs <- null
	skitRef.s.noSpawnAreaIDs = []
	if ( hasIMC )
		skitRef.s.noSpawnAreaIDs.append( CreateNoSpawnArea( TEAM_MILITIA, skitRef.GetOrigin(), 9999, SKIT_NO_SPAWN_RADIUS ) )
	if ( hasMilitia )
		skitRef.s.noSpawnAreaIDs.append( CreateNoSpawnArea( TEAM_IMC, skitRef.GetOrigin(), 9999, SKIT_NO_SPAWN_RADIUS ) )

	// Spawn the guys
	for ( local i = 0 ; i < data.wait_anims.len() ; i++ )
	{
		//DebugDrawLine( GetPlayerArray()[0].GetOrigin(), node.animStartOrigin[i], 255, 255, 0, true, 30 )

		local guy = null
		switch( data.aiType[i] )
		{
			case "grunt":
				guy = SpawnGrunt( teamAssignments[i], "", skitRef.s.animStartOrigin[i], skitRef.s.animStartAngles[i], true, data.weapons[i] )
				break
			case "spectre":
				guy = SpawnSpectre( teamAssignments[i], "", skitRef.s.animStartOrigin[i], skitRef.s.animStartAngles[i], true, data.weapons[i] )
				break
			default:
				Assert(0)
		}
		Assert( IsValid( guy ) )

		guy.s.isInSkit <- true

		if ( !( "forceRagdollDeath" in guy.s ) )
			guy.s.forceRagdollDeath <- null
		guy.s.forceRagdollDeath = true

		local healthVal = guy.IsSpectre() ? 150 : 50
		guy.SetHealth( healthVal )

		// Unreserve AI slots
		thread UnreserveAISlotOnDeath( guy )

		// Make other AI not shoot this guy while he's idling
		guy.SetNoTarget( true )
		guy.SetEfficientMode( true )
		guy.Minimap_Hide( TEAM_IMC, null )
		guy.Minimap_Hide( TEAM_MILITIA, null )

		// Make guy not scream when dying if silentDeath set to true
		if ( data.silentDeath[i] == 1 )
			SetSilentDeath( guy, true )

		// Disable neck snap execution on guy if supposed to
		if ( data.allowExecution[i] == 0 )
			guy.ContextAction_SetBusy()

		// Add the guy to system so it waits till he is dead before thinking this skit is finished, and also to the data table
		skitRef.s.guysSpawnedForSkit.append( guy )

		// Play the idle anim until he is visible by someone
		thread PlayAnim( guy, data.wait_anims[i], skitRef )
		//thread StartSkitOnDamage( node, guy )
		thread AbortSkitOnDeath( skitRef, guy )
		//thread AbortSkitOnTimeout( node.ref )
		thread HandleSkitAbortion( skitRef, data.dieOnAbortion[i], guy )
	}

	// Wait till visible by a player
	if ( !level.UsingCinematicNodeEditor )
	{
		WaitSignal( skitRef, "StartSkit" )
	}
	wait 0	// wait 0 sometimes some functions will get ended before completing the frame
	Signal( skitRef, "StartSkit" )

	if ( DEBUG_PRINTS_SKIT )
		printt( "SKIT STARTING" )

	// Make sure everyone is still alive
	if ( IsSkitGuyNotInterruptableOrParented( skitRef ) )
	{
		if ( DEBUG_PRINTS_SKIT )
			printt( "SKIT ABORTED - SOMEONE IS NON-INTERRUPTABLE" )
		return
	}
	else if ( AreSkitGuysDead( skitRef ) )
	{
		if ( DEBUG_PRINTS_SKIT )
			printt( "SKIT ABORTED - NOT EVERYONE ALIVE" )
	}
	else
	{
		// Play out the sequence
		foreach( index, guy in skitRef.s.guysSpawnedForSkit )
		{
			local soundAlias = data.sounds[index]
			if ( soundAlias != null )
			{
				//DebugDrawLine( GetPlayerArray()[0].GetOrigin(), guy.GetOrigin(), 255, 255, 0, true, 10 )
				EmitSoundOnEntity( guy, soundAlias )
			}

			guy.SetNoTarget( false )
			guy.SetEfficientMode( false )
			guy.Minimap_AlwaysShow( TEAM_IMC, null )
			guy.Minimap_AlwaysShow( TEAM_MILITIA, null )
			thread PlayAnim( guy, data.skit_anims[index], skitRef )
			thread WaittillAnimDoneOrDeath( skitRef, guy )
			thread EndSkitEarlyOnDeath( skitRef, guy )
			thread WaitForSkitEarlyEnd( skitRef, guy, soundAlias )
			thread WaitForForceDeathSignal( skitRef, guy )
			thread EndSkitEarlyOnFoundEnemy( skitRef, guy )

			if ( DEBUG_PRINTS_SKIT )
				thread Test_WaitForSignal_DontBreakout( guy )
		}

		while( skitRef.s.guysInSkitCount > 0 )
			WaitSignal( skitRef, "GuysInSkitUpdated" )
	}

	if ( DEBUG_NIGHTLY_CHAD_ONLY )
	{
		local players = GetPlayerArray()
		foreach( player in players )
		{
			if ( player.GetPlayerName() == DEBUG_NIGHTLY_CHAD_NAME )
			{
				Remote.CallFunction_Replay( player, "ServerCallback_AISkitDebugMessage", skitRef.s.node.index, 0 )
				break
			}
		}
	}

	if ( level.UsingCinematicNodeEditor || skitRef.s.node.testNode == true )
	{
		if ( skitRef.s.node.testNode == true )
			wait 3

		foreach( index, guy in skitRef.s.guysSpawnedForSkit )
		{
			if ( IsAlive( guy ) )
				guy.Kill()
		}
	}
}

function IsInSkit( guy )
{
	if ( !IsValid( guy ) )
		return false
	return ( "isInSkit" in guy.s )
}

function ResetSkit( node )
{
	if ( !level.UsingCinematicNodeEditor )
		return

	if ( !( "skitRef" in node ) )
		return

	local skitRef = node.skitRef
	if ( "guysSpawnedForSkit" in skitRef.s )
	{
		foreach( guy in skitRef.s.guysSpawnedForSkit )
		{
			if ( IsAlive( guy ) )
				guy.Kill()
			else if ( IsValid( guy ) && !( guy.IsNPC() ) )//non AI
				guy.Kill()
		}
	}
}

function AssignTeams( data, swapTeams )
{
	// Assign teams.
	local teamAssignments = []

	for ( local i = 0 ; i < data.teams.len() ; i++ )
	{
		if ( swapTeams )
			teamAssignments.append( data.teams[i] == 0 ? TEAM_IMC : TEAM_MILITIA )
		else
			teamAssignments.append( data.teams[i] == 0 ? TEAM_MILITIA : TEAM_IMC )
	}

	return teamAssignments
}

function DoPropSkit( node, swapTeams = false )
{
	InitNodeForPropSkit( node )

	Assert( "skitRef" in node )
	local skitRef = node.skitRef

	Signal( skitRef, "DoAISkit" )
	EndSignal( skitRef, "DoAISkit" )

	ResetSkit( node )

	local data 				= level.animPropSkitData[ skitRef.s.skitType ]
	local teamAssignments 	= AssignTeams( data, swapTeams )

	Assert( skitRef.s.guysInSkitCount == 0 )
	skitRef.s.guysSpawnedForSkit = []
	skitRef.s.guysSpawnedForSkitCount = data.skit_anims.len()

	// Spawn the guys
	for ( local i = 0 ; i < data.skit_anims.len() ; i++ )
	{
		local guy = null
		switch( data.aiType[i] )
		{
			case "grunt":
				guy = SpawnGruntPropDynamic( teamAssignments[i], "", skitRef.s.animStartOrigin[i], skitRef.s.animStartAngles[i], true, data.weapons[i] )
				break

		//	case "spectre":
		//		guy = SpawnSpectre( teamAssignments[i], "", skitRef.s.animStartOrigin[i], skitRef.s.animStartAngles[i], true, data.weapons[i] )
		//		break

			default:
				Assert(0)
		}
		Assert( IsValid( guy ) )

		if ( !( "forceRagdollDeath" in guy.s ) )
			guy.s.forceRagdollDeath <- null
		guy.s.forceRagdollDeath = true

		// Add the guy to system so it waits till he is dead before thinking this skit is finished, and also to the data table
		skitRef.s.guysSpawnedForSkit.append( guy )
	}

	if ( data.wait_anims.len() )
	{
		foreach ( index, guy in skitRef.s.guysSpawnedForSkit )
			thread PlayAnim( guy, data.wait_anims[index], skitRef )

		wait data.wait_length
	}

	// Play out the sequence
	foreach( index, guy in skitRef.s.guysSpawnedForSkit )
	{
		local soundAlias = data.sounds[index]
		if ( soundAlias != null )
			EmitSoundOnEntity( guy, soundAlias )

		thread PlayAnim( guy, data.skit_anims[index], skitRef )
		thread WaittillAnimDoneOrDeath( skitRef, guy )
	}

	while( skitRef.s.guysInSkitCount > 0 )
		WaitSignal( skitRef, "GuysInSkitUpdated" )

	if ( data.end_anims.len() )
	{
		foreach ( index, guy in skitRef.s.guysSpawnedForSkit )
			thread PlayAnim( guy, data.end_anims[index], skitRef )

		wait data.end_length
	}

	foreach( index, guy in skitRef.s.guysSpawnedForSkit )
	{
		if ( IsValid( guy ) )
			guy.Kill()
	}
}

function DoPropSkitSearchHole( node, swapTeams = false, extraWait = 0  )
{
	InitNodeForPropSkit( node )

	Assert( "skitRef" in node )
	local skitRef = node.skitRef

	Signal( skitRef, "DoAISkit" )
	EndSignal( skitRef, "DoAISkit" )

	ResetSkit( node )

	local data 				= level.animPropSkitData[ skitRef.s.skitType ]
	local teamAssignments 	= AssignTeams( data, swapTeams )

	Assert( skitRef.s.guysInSkitCount == 0 )
	skitRef.s.guysSpawnedForSkit = []
	skitRef.s.guysSpawnedForSkitCount = data.skit_anims.len()

	// Spawn the guys
	for ( local i = 0 ; i < data.skit_anims.len() ; i++ )
	{
		local guy = SpawnGruntPropDynamic( teamAssignments[i], "", skitRef.s.animStartOrigin[i], skitRef.s.animStartAngles[i], true, data.weapons[i] )

		Assert( IsValid( guy ) )

		if ( !( "forceRagdollDeath" in guy.s ) )
			guy.s.forceRagdollDeath <- null
		guy.s.forceRagdollDeath = true

		// Add the guy to system so it waits till he is dead before thinking this skit is finished, and also to the data table
		skitRef.s.guysSpawnedForSkit.append( guy )

		thread DoPropSkitSearchHoleGuy( guy, i, skitRef, data, extraWait )
	}
}

function DoPropSkitSearchHoleGuy( guy, index, skitRef, data, extraWait )
{
	guy.EndSignal( "OnDeath" )
	EndSignal( skitRef, "DoAISkit" )

	//wait a bit
	thread PlayAnim( guy, data.wait_anims[index], skitRef )
	wait data.wait_length + extraWait

	// walk up
	local soundAlias = data.sounds[index]
	if ( soundAlias != null )
		EmitSoundOnEntity( guy, soundAlias )

	waitthread PlayAnim( guy, data.skit_anims[index], skitRef )

	//idle
	thread PlayAnim( guy, data.idle_anims[index], skitRef )
	wait data.idle_length

	//walk away
	waitthread PlayAnim( guy, data.end_anims[index], skitRef )

	guy.Kill()
}



/*
function StartSkitOnDamage( node, guy )
{
	EndSignal( node.ref, "StartSkit" )

	WaitSignal( guy, "OnDamaged" )

	Signal( node, "StartSkit" )
}
*/
function AbortSkitOnDeath( ref, guy )
{
	EndSignal( ref, "StartSkit" )
	WaitSignal( guy, "OnDeath" )

	Signal( ref, "AbortSkit" )

	if ( DEBUG_PRINTS_SKIT )
		printt( "GUY DIED - ABORTING SKIT" )
}
/*
function AbortSkitOnTimeout( ref )
{
	if ( SKIT_TIMEOUT == 0 )
		return

	EndSignal( ref, "StartSkit" )
	wait SKIT_TIMEOUT
	Signal( ref, "AbortSkit" )
	if ( DEBUG_PRINTS_SKIT )
		printt( "TIMED OUT - ABORTING SKIT" )
}
*/
function HandleSkitAbortion( ref, dieOnAbortion, guy )
{
	EndSignal( ref, "StartSkit" )
	WaitSignal( ref, "AbortSkit" )

	if ( !IsValid( guy ) || !IsAlive( guy ) )
		return

	if ( dieOnAbortion == 1 )
	{
		if ( DEBUG_PRINTS_SKIT )
			printt( "SKIT WAS ABORTED - KILLING AI" )
		guy.Die()
	}
	else
	{
		if ( DEBUG_PRINTS_SKIT )
			printt( "SKIT WAS ABORTED - STOPPING ANIM ON AI" )
		guy.Anim_Stop()
	}
}

function WaittillAnimDoneOrDeath( ref, guy )
{
	Assert( IsValid( guy ) )
	if ( guy.IsNPC() )
		Assert( IsAlive( guy ) )

	ref.s.guysInSkitCount++
	OnThreadEnd(
		function() : ( guy, ref )
		{
			// If the guy survived the skit, disable ragdoll death & use death anims
			if ( IsAlive( guy ) )
			{
				if ( "forceRagdollDeath" in guy.s )
					delete guy.s.forceRagdollDeath
			}
			ref.s.guysInSkitCount--
			Signal( ref, "GuysInSkitUpdated" )
		}
	)

	EndSignal( ref, "SkitFinished" )
	EndSignal( guy, "OnDeath" )

	guy.WaittillAnimDone()
	Signal( ref, "GuysInSkitUpdated" )
}

function EndSkitEarlyOnDeath( ref, guy )
{
	// When the guy is killed it signals for the other guys involved in the skit to stop the sequence prematurely

	Assert( IsValid( guy ) )
	Assert( IsAlive( guy ) )

	EndSignal( guy, "AnimEventKill" )	// Stops the skit from breaking when the guys "kill" anim event is triggered
	EndSignal( guy, "aiskit_doomed" )	// Signaled via the animation. Once the animation has reached this point this guys death no longer will break the sequence
	EndSignal( ref, "SkitFinished" )
	WaitSignal( guy, "OnDeath" )

	Signal( ref, "StopSkit" )
	if ( DEBUG_PRINTS_SKIT )
		printt( "GUY DIED - INTERRUPTING SKIT" )

	thread ThankForInterruptingSkit( ref )
}

function ThankForInterruptingSkit( ref )
{
	local skitAnimData = level.animSkitData[ ref.s.skitType ]
	if ( ! ( "thankOnInterrupting" in skitAnimData ) ) //Skit not set up to thank on interruption, just early out
		return

	local thankOnInterruptingArray = skitAnimData.thankOnInterrupting

	local killer = null

	local skitActors = ref.s.guysSpawnedForSkit

	foreach( skitActor in skitActors )
	{
		if ( IsAlive( skitActor ) )
			continue

		if (  !("lastAttacker" in skitActor.s ) ) //Some skit actors can die as part of the skit so they won't have a lastAttacker. We want to find the guy who was killed by someone external to the skit
			continue

		killer = skitActor.s.lastAttacker
	}

	if ( killer == null )
		return //No idea who the killer is

	wait 0.75 //For a beat

	if ( !IsAlive( killer ) ) //Need to check again since we waited
			return

	//We found the killer, now let's see if anyone wants to thank him

	for ( local i = 0; i < skitActors.len(); ++i )
	{
		local skitActor = skitActors[ i ]

		if ( !IsAlive( skitActor )  )
			continue

		if ( skitActor.GetTeam() != killer.GetTeam() )
			continue

		if ( !thankOnInterruptingArray[ i ] )
			continue

		//printt( "Guy: " + skitActor + " wants to thank: " + killer )
		local conversation = DecideThanksDialogue( skitActor )
		EmitSoundOnEntity( skitActor, conversation )
		return //Just have one guy thank instead of everyone involved thanking so we don't have to coordinate with who to thank, etc
	}
}

function DecideThanksDialogue( skitActor )
{
	local teamString

	if ( skitActor.GetTeam() == TEAM_IMC )
		teamString = "imc"
	else if ( skitActor.GetTeam() == TEAM_MILITIA )
		teamString = "mcor"
	else Assert( false, "Unsupported team!" )

	local gruntNumber = RandomInt( 1, 5 )
	local lineNumber = RandomInt( 1, 6 )

	//printt( " result string: diag_" + teamString + "_grunt" + gruntNumber + "_gs_skitthanks_01_" + lineNumber )

	return ( "diag_" + teamString + "_grunt" + gruntNumber + "_gs_skitthanks_01_" + lineNumber )

}

function EndSkitEarlyOnFoundEnemy( ref, guy )
{
	// When the guy find an enemy player he should break out of the skit

	Assert( IsValid( guy ) )
	Assert( IsAlive( guy ) )

	EndSignal( guy, "AnimEventKill" )	// Stops the skit from breaking when the guys "kill" anim event is triggered
	EndSignal( guy, "aiskit_doomed" )	// Signaled via the animation. Once the animation has reached this point this guys death no longer will break the sequence
	EndSignal( guy, "OnDeath" )
	EndSignal( ref, "SkitFinished" )

	// Wait for the anim to say hes allowed to breakout by spotting an enemy player
	WaitSignal( guy, "aiskit_alertbreakout" )
	if ( DEBUG_PRINTS_SKIT )
		printt( "GUY NOW ALLOWED TO BREAK SKIT FROM ENEMY" )

	// Wait till he has a player enemy
	local enemy = guy.GetEnemy()
	if ( enemy == null || !IsValid( enemy ) || !enemy.IsPlayer() )
		WaitSignal( guy, "OnFoundPlayer" )

	Signal( ref, "StopSkit" )
	if ( DEBUG_PRINTS_SKIT )
		printt( "GUY FOUND ENEMY PLAYER - INTERRUPTING SKIT" )
}

function WaitForForceDeathSignal( ref, guy )
{
	EndSignal( ref, "SkitFinished" )
	EndSignal( guy, "OnDeath" )

	WaitSignal( guy, "aiskit_forcedeathonskitend" )

	guy.s.forceDeathOnSkitEnd <- true	//this guy should just die if the skit ends prematurely
}

function WaitForSkitEarlyEnd( ref, guy, soundAlias )
{
	// Waits for the event to be prematurely ended by another guy in the sequence because he died

	Assert( IsValid( guy ) )
	Assert( IsAlive( guy ) )

	EndSignal( guy, "AnimEventKill" )
	EndSignal( guy, "aiskit_dontbreakout" )
	EndSignal( ref, "SkitFinished" )
	EndSignal( guy, "OnDeath" )

	OnThreadEnd(
		function() : ( guy, soundAlias )
		{
			if ( IsValid( guy ) )
			{
				if( soundAlias != null )
					StopSoundOnEntity( guy, soundAlias )
			}
		}
	)

	WaitSignal( ref, "StopSkit" )

	if ( DEBUG_PRINTS_SKIT )
		printt( "SKIT INTERRUPTED - STOPPING ANIMATION on guy", guy )

	if ( "forceDeathOnSkitEnd" in guy.s )
		guy.Die()
	else
		guy.Anim_Stop()

}

function Test_WaitForSignal_DontBreakout( guy )
{
	WaitSignal( guy, "aiskit_dontbreakout" )
	printt( "ANIM SIGNAL: DONT BREAKOUT on guy", guy )
}

function UnreserveAISlotOnDeath( guy )
{
	WaitSignal( guy, "OnDeath" )
	level.aiSkitSlotsUsed--
}

function CheckForSkitInCollision( skitRef )
{
	if ( !IsHighPerfDevServer() )
		return

	if ( !level.UsingCinematicNodeEditor )
	{
		if ( !WARN_ABOUT_SKIT_COLLISIONS && !DISPLAY_SKIT_COLLISIONS )
			return
	}

	// CHAD TODO: These skits can intersect geo even if placed correctly. Until that's fixed we skip the check on them.
	if ( skitRef.s.skitType == CINEMATIC_TYPES.AI_SKIT_DYING_WALLSLIDE )
		return	// The bbox needs to be pulled away from the wall a bit. If you make the guy line up with the wall his bbox intersects it.

	Signal( skitRef, "StopDebugSphere" )

	//convar: ai_debug_test_anim_path
	if ( !level.UsingCinematicNodeEditor )
	{
		if ( "checkedForCollision" in skitRef.s )
			return
		skitRef.s.checkedForCollision <- true
	}

	local data = level.animSkitData[ skitRef.s.skitType ]
	for ( local i = 0 ; i < data.skit_anims.len() ; i++ )
	{
		local guy = null
		if ( !( data.aiType[i] in collisionTestGuys ) )
			collisionTestGuys[ data.aiType[i] ] <- null
		switch( data.aiType[i] )
		{
			case "grunt":
				if ( !IsAlive( collisionTestGuys[ "grunt" ] ) )
					collisionTestGuys[ "grunt" ] = SpawnGrunt( TEAM_IMC, "", skitRef.s.animStartOrigin[i], skitRef.s.animStartAngles[i], true, data.weapons[i] )
				guy = collisionTestGuys[ "grunt" ]
				break
			case "spectre":
				if ( !IsAlive( collisionTestGuys[ "spectre" ] ) )
					collisionTestGuys[ "spectre" ] = SpawnSpectre( TEAM_IMC, "", skitRef.s.animStartOrigin[i], skitRef.s.animStartAngles[i], true, data.weapons[i] )
				guy = collisionTestGuys[ "spectre" ]
				break
			default:
				Assert(0)
		}
		Assert( IsValid( guy ) )

		local index = guy.LookupSequence( data.skit_anims[i] )
		local animStart = guy.Anim_GetStartForRefPoint( data.skit_anims[i], skitRef.GetOrigin() + Vector( 0, 0, 10 ), skitRef.GetAngles() )
		local pathCheck
		skitRef.s.lastCollisionCheckResult = true

		// Check if the anim is starting below ground
		local groundTrace = TraceLine( animStart.origin + Vector( 0, 0, 50 ), animStart.origin, guy, TRACE_MASK_NPCSOLID, TRACE_COLLISION_GROUP_NONE )
		local groundCheck = true
		if ( groundTrace.fraction < 1.0 )
		{
			CodeWarning( "AI SKIT ON NODE '" + skitRef.s.node.uniqueID + "' AT POS " + skitRef.GetOrigin() + " CAUSES AI TO START ANIM INSIDE GEO" )
			if ( DISPLAY_SKIT_COLLISIONS || level.UsingCinematicNodeEditor )
			{
				Signal( skitRef, "StopDebugSphere" )
				thread DebugDrawCircleTillSignal( skitRef, "StopDebugSphere", skitRef.GetOrigin(), 16, 255, 0, 175 )
			}
			continue
		}


		local maxFracToCheck = 1.0
		local fracKill = guy.GetScriptedAnimEventCycleFrac( data.skit_anims[i], "kill" )
		if ( fracKill >= 0 && fracKill < maxFracToCheck )
			maxFracToCheck = fracKill
		Assert( maxFracToCheck >= 0 )
		Assert( maxFracToCheck <= 1.0 )
		local geoIntersectBegin = guy.GetScriptedAnimEventCycleFrac( data.skit_anims[i], "geo_intersect_begin" )
		local geoIntersectEnd = guy.GetScriptedAnimEventCycleFrac( data.skit_anims[i], "geo_intersect_end" )

		local max_range_size = 0.25
		local rangeStart = 0.0
		local rangeEnd
		local geo_intersect = false

		local count = 0
		while(1)
		{
			// CALCULATE NEXT SEGMENT TO TEST


			// Default next range end
			rangeEnd = rangeStart + max_range_size

			// Don't check past max frac which is 1.0 or when entity is killed via animation
			if ( rangeEnd > maxFracToCheck )
				rangeEnd = maxFracToCheck
			if ( rangeStart >= maxFracToCheck )
				break

			// If we are entering a geo intersection then stop checking where that begins
			if ( !geo_intersect && geoIntersectBegin >= 0 && rangeEnd > geoIntersectBegin )
			{
				geo_intersect = true
				rangeEnd = geoIntersectBegin
			}

			//printt( "#######################" )
			//printt( "CHECKING NODE", skitRef.s.node.uniqueID, "GUY", i, "START POS", animStart.origin, "ANIM", data.skit_anims[i], "RANGE", rangeStart, "-", rangeEnd )
			//printt( "    geoIntersectBegin:", geoIntersectBegin )
			//printt( "    geoIntersectEnd:", geoIntersectEnd )
			//printt( "#######################" )

			// Check if the anim puts the guy into solid
			pathCheck = guy.TestAnimPathFrom( animStart.origin, animStart.angles.y, index, rangeStart, rangeEnd, true )
			if ( !pathCheck )
			{
				if ( WARN_ABOUT_SKIT_COLLISIONS || level.UsingCinematicNodeEditor )
					CodeWarning( "AI skit " + GetNodeTypeString( skitRef.s.node ) + " on node '" + skitRef.s.node.uniqueID + "' at " + skitRef.GetOrigin() + " causes AI to clip into geo during animation" )

				if ( DISPLAY_SKIT_COLLISIONS || level.UsingCinematicNodeEditor )
				{
					Signal( skitRef, "StopDebugSphere" )
					thread DebugDrawCircleTillSignal( skitRef, "StopDebugSphere", skitRef.GetOrigin(), 16, 255, 0, 0 )
				}

				skitRef.s.lastCollisionCheckResult = false
				if ( level.UsingCinematicNodeEditor )
					guy.Kill()
				return
			}

			if ( geo_intersect && geoIntersectEnd > rangeEnd )
				rangeStart = geoIntersectEnd
			else
				rangeStart = rangeEnd

			count++
			if ( count > 10 )
				break
		}

		if ( level.UsingCinematicNodeEditor )
			guy.Kill()
	}
}

function DevRunAllSkits()
{
	thread DevRunAllSkits_threaded()
}

function DevRunAllSkits_threaded()
{
	Flag( "DisableSkits" )

	local skitViewDist = 200
	local diagFac = 0.707107
	local timePerSkit = 3.0

	local viewOffsets = []
	viewOffsets.append( Vector( skitViewDist, 0, 32 ) )
	viewOffsets.append( Vector( -skitViewDist, 0, 32 ) )
	viewOffsets.append( Vector( 0, skitViewDist, 32 ) )
	viewOffsets.append( Vector( 0, -skitViewDist, 32 ) )
	viewOffsets.append( Vector( skitViewDist * diagFac, skitViewDist * diagFac, 32 ) )
	viewOffsets.append( Vector( -skitViewDist * diagFac, -skitViewDist * diagFac, 32 ) )
	viewOffsets.append( Vector( skitViewDist * diagFac, -skitViewDist * diagFac, 32 ) )
	viewOffsets.append( Vector( -skitViewDist * diagFac, skitViewDist * diagFac, 32 ) )

	local allNodes = GetAllSkitNodes()
	local allRefs = []
	foreach( node in allNodes )
	{
		Assert( "skitRef" in node )
		allRefs.append( node.skitRef )
	}

	local allRefsSorted = []
	local testOrg = Vector( 16000, 16000, 0 )
	local remainingBeforeWait = 10
	while( allRefs.len() > 0 )
	{
		local closest = GetClosest( allRefs, testOrg )
		Assert( closest != null )
		allRefsSorted.append( closest )
		ArrayRemove( allRefs, closest )
		testOrg = closest.GetOrigin()

		remainingBeforeWait--
		if ( remainingBeforeWait == 0 )
		{
			remainingBeforeWait = 10
			wait 0
		}
	}

	local player = GetPlayerArray()[0]

	ClientCommand( player, "noclip" )
	ClientCommand( player, "god" )
	ClientCommand( player, "notarget" )

	local allNPCs = GetNPCArray()
	foreach( npc in allNPCs )
	{
		if ( IsAlive( npc ) )
			npc.Die()
	}

	foreach( i, skitRef in allRefsSorted )
	{
		printt( "SKIT", i + 1, "OF", allRefsSorted.len(), "      id:", skitRef.s.node.uniqueID )
		Assert( IsValid( skitRef ) )

		local nodeOrg = skitRef.GetOrigin()
		local playerPos
		local playerEyePos
		local trace
		foreach( i, offset in viewOffsets )
		{
			// See if we can see the skit from this offset
			playerPos = nodeOrg + viewOffsets[i]
			playerEyePos = playerPos + Vector( 0, 0, 60 )
			trace = TraceLine( playerEyePos, nodeOrg + Vector( 0, 0, 16 ), player, TRACE_MASK_VISIBLE, TRACE_COLLISION_GROUP_NONE )

			if ( trace.fractionLeftSolid == 1 )
				continue
			if ( trace.startSolid || trace.allSolid )
				continue
			if ( trace.fraction < 1 )
				continue

			player.SetOrigin( playerPos )
			local viewVec = ( nodeOrg - Vector( 0, 0, 32 ) ) - ( nodeOrg + viewOffsets[i] )
			player.SetAngles( VectorToAngles( viewVec ) )

			//DebugDrawLine( playerEyePos, nodeOrg + Vector( 0, 0, 16 ), 255, 255, 0, true, timePerSkit )
		}

		skitRef.SetReserved( false )
		thread AI_Skits_RunSkit( skitRef )

		WaitSignal( skitRef, "SkitFinished" )
		wait 1.0

		local allNPCs = GetNPCArray()
		foreach( npc in allNPCs )
		{
			if ( IsAlive( npc ) )
				npc.Die()
		}

		if ( level.UsingCinematicNodeEditor )
			break
	}

	printt( "DONE" )
}