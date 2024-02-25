const DROP_MIN_X = 0.0
//const ANALYSIS_STEPS = 16.0 // the number of different yaw slices to create analysis on
//const ANALYSIS_YAW_STEP = 22.5 // 360.0 / 16. Update if ANALYSIS_STEPS changes
const ANALYSIS_STEPS = 8.0 // the number of different yaw slices to create analysis on
const ANALYSIS_YAW_STEP = 45.0 // 360.0 / 8. Update if ANALYSIS_STEPS changes

const FIRST_ONLY = false
const SPAWNPOINT_USE_TIME = 10.0 // stub for real usage

const MAX_ANALYSIS_COUNT = 64 // in-engine limit to amount of info stored into nodes that script can use

const DESCRIPTION_MULTIPLIER = 0.0006 // 1666 units per area


function main()
{
	FlagInit( "DisableDropships" )
	FlagInit( "DogFights" )
	FlagInit( "FlyerPickupAnalysis" )
	FlagInit( "StratonFullAttack" )

	level.activeNodeAnalysis <- false
	level.ainAnalysisIndices <- {}
	level.dropshipDropoffAnims <- []
	level.drawAnalysisPreview <- false

	level.testHardPoints <- []
	level.testFlagSpawnPoints <- []
	level.titanfallBlockers <- []

	level.superCallinOffset <- {}
	level.superCallinOffset[ DROPSHIP_MODEL ] <- 700

	level.originAttachmentNames <- {}
	level.originAttachmentNames[ ATLAS_MODEL ] <- "OFFSET"

	level.dropshipDropoffAnims.append( DROPSHIP_STRAFE )
	// angel is using all 8 ain slots so we can't add the extra zipline anim to it.
	level.dropshipDropoffAnims.append( DROPSHIP_VERTICAL )

	if ( IsMultiplayer() && !IsMenuLevel() )
	{
		for ( local i = 0; i < level.dropshipDropoffAnims.len(); i++ )
		{
			AddAinAnalysisIndex( DROPSHIP_MODEL, level.dropshipDropoffAnims[i] )
		}

		AddAinAnalysisIndex( ATLAS_MODEL, HOTDROP_TURBO_ANIM )
		AddAinAnalysisIndex( DROPPOD_MODEL, DROPPOD_DROP_ANIM )
	}

	IncludeFile( "_flightpath_shared_utility" )
	// the purpose of this script is to cache animation movement, to be able to check via traces whether or not it can be used
	Globalize( ShowAllTitanFallSpots )
	Globalize( GetAttachPoints )
	Globalize( CheckTime )
	Globalize( FlightMark )
	Globalize( AddFlightAnalysis )
	Globalize( GetPreviewPoint )
	Globalize( qt )
	Globalize( CodeCallback_AINFileBuilt )
	Globalize( GetAnalysisOffset )
	Globalize( CreateSimpleFlightAnalysis )
	Globalize( DebugReplacement )
	Globalize( DebugDropship )
	Globalize( GetDescriptionFromOrigin )
	Globalize( DogFightAnimsFromIndex )
	Globalize( AnaylsisFuncLegalFlightPath )
	Globalize( StratonHornetDogfights )
	Globalize( SpawnRandomDogFight )

	Globalize( GetTitanfallNodesInRadius )
	Globalize( DisableTitanfallForLifetimeOfEntityNearOrigin )
	Globalize( DisableTitanfallForNodes )
	Globalize( NearDisallowedTitanfall )

	FlagInit( "FlightAnalysisReady" )
	FlagInit( "StratonFlybys" )

	RegisterSignal( "StratonHornetDogfights" )
	RegisterSignal( "ClearDisableTitanfall" )

	// store all the possible flight paths
	level.flightAnalysis <- {}
	level.spawnPointsInUse <- {}

	level.disallowedTitanfalls <- {}
}

function EntitiesDidLoad()
{
	if ( !IsMultiplayer() )
		return

	if ( IsMenuLevel() )
		return

	if ( IsServer() )
	{

		if ( Flag( "StratonFlybys" ) )
			AddAinAnalysisIndex( STRATON_MODEL, STRATON_FLIGHT_ANIM )

		if ( Flag( "DogFights" ) )
		{
			AddAinAnalysisIndex( STRATON_MODEL, STRATON_DOGFIGHT_ANIM1 )
			AddAinAnalysisIndex( STRATON_MODEL, STRATON_DOGFIGHT_ANIM2 )
			AddAinAnalysisIndex( STRATON_MODEL, STRATON_DOGFIGHT_ANIM3 )
		}

		if ( Flag( "StratonFullAttack" ) )
		{
			// straton attacks a spot
			AddAinAnalysisIndex( STRATON_MODEL, STRATON_ATTACK_FULL )
		}

//		thread CompareDropshipModels( DROPSHIP_MODEL, CROW_MODEL, GetDropshipRopeAttachments() )

		CreateSimpleFlightAnalysis( TEAM_IMC_GRUNT_MDL, ZIPLINE_IDLE_ANIM )

		local event = "dropship_deploy"
		local analysis = CreateFlightAnalysis( DROPSHIP_MODEL, DROPSHIP_STRAFE, event, GetDropshipRopeAttachments() )
		AddBoundingMins( analysis, Vector( -325, -325, -96 ) )
		AddBoundingMaxs( analysis, Vector( 325, 325, 185 ) )
		AddAnalysisFunc( analysis, AnaylsisFuncDropshipFindDropNodes, HULL_HUMAN )
		AddAnalysisIterator( analysis, 2 ) // iterate every other node

		local analysis = CreateFlightAnalysis( DROPSHIP_MODEL, DROPSHIP_VERTICAL, event, GetDropshipRopeAttachments() )
		AddBoundingMins( analysis, Vector( -325, -325, -96 ) )
		AddBoundingMaxs( analysis, Vector( 325, 325, 185 ) )
		AddAnalysisFunc( analysis, AnaylsisFuncDropshipFindDropNodes, HULL_HUMAN )
		AddAnalysisIterator( analysis, 2 ) // iterate every other node

		if ( Flag( "StratonFlybys" ) )
		{
			local analysis = CreateFlightAnalysis( STRATON_MODEL, STRATON_FLIGHT_ANIM )
			AddFighterBounds( analysis )
			AddAnalysisFunc( analysis, AnaylsisFuncLegalFlightPath, HULL_HUMAN )
			AddAnalysisIterator( analysis, 1 )
		}

		if ( Flag( "DogFights" ) )
		{
			local analysis = CreateFlightAnalysis( STRATON_MODEL, STRATON_DOGFIGHT_ANIM1 )
			AddFighterBounds( analysis )
			AddAnalysisFunc( analysis, AnaylsisFuncLegalFlightPath, HULL_HUMAN )
			AddAnalysisIterator( analysis, 1 )

			local analysis = CreateFlightAnalysis( STRATON_MODEL, STRATON_DOGFIGHT_ANIM2 )
			AddFighterBounds( analysis )
			AddAnalysisFunc( analysis, AnaylsisFuncLegalFlightPath, HULL_HUMAN )
			AddAnalysisIterator( analysis, 1 )

			local analysis = CreateFlightAnalysis( STRATON_MODEL, STRATON_DOGFIGHT_ANIM3 )
			AddFighterBounds( analysis )
			AddAnalysisFunc( analysis, AnaylsisFuncLegalFlightPath, HULL_HUMAN )
			AddAnalysisIterator( analysis, 1 )
		}

		if ( Flag( "StratonFullAttack" ) )
		{
			local analysis = CreateFlightAnalysis( STRATON_MODEL, STRATON_ATTACK_FULL )
			AddFighterBounds( analysis )
			AddAnalysisFunc( analysis, AnaylsisFuncLegalFlightPath, HULL_HUMAN )
			AddAnalysisIterator( analysis, 1 )
		}

		local analysis = CreateFlightAnalysis( DROPSHIP_MODEL, "gd_flyin_A_left_localnodes", event, GetDropshipRopeAttachments() )
		AddBoundingMins( analysis, Vector( -325, -325, -96 ) )
		AddBoundingMaxs( analysis, Vector( 325, 325, 185 ) )
		AddAnalysisFunc( analysis, AnaylsisFuncDropshipFindDropNodes, HULL_HUMAN )
		AddAnalysisIterator( analysis, 2 ) // iterate every other node


		// buffer the height to account for ground plane abnormality
	//	AddAnalysisPoint( analysis, Vector( 13.915, 8.58578, 50 ), Vector( 0.00356261, 0.0105928, 0.00143976 ) )
	//	AddAnalysisPoint( analysis, Vector( 15.4668, 8.58606, 50 ), Vector( 0.00356261, 0.0105928, 0.00143976 ) )

		local analysis = CreateFlightAnalysis( ATLAS_MODEL, HOTDROP_TURBO_ANIM )
		AddBoundingMins( analysis, Vector( -65, -65, 0 ) )
		AddBoundingMaxs( analysis, Vector( 65, 65, 240 ) )
		AddAnalysisTraceMask( analysis, CONTENTS_SOLID | CONTENTS_WINDOW | CONTENTS_GRATE | CONTENTS_MOVEABLE | CONTENTS_TITANCLIP )

		AddIdleAnimation( analysis, "at_idle_2" )
		AddAnalysisFunc( analysis, TitanFindDropNodes, HULL_TITAN )
		//AddPrepSpawnpointFunc( analysis, TitanHulldropSpawnpoint )
		AddAnalysisIterator( analysis, 1 ) // iterate each node


		local analysis = CreateFlightAnalysis( DROPPOD_MODEL, DROPPOD_DROP_ANIM )
		AddBoundingMins( analysis, Vector( -64, -64, 0.0 ) )
		AddBoundingMaxs( analysis, Vector( 64, 64, 97.331 ) )
		AddAnalysisTraceMask( analysis, CONTENTS_TITANCLIP | TRACE_MASK_NPCWORLDSTATIC) //  | TRACE_MASK_PLAYERSOLID_BRUSHONLY )
		AddIdleAnimation( analysis, "idle" )
		AddAnalysisFunc( analysis, DropPodFindDropNodes, HULL_TITAN )
		AddPrepSpawnpointFunc( analysis, TitanHulldropSpawnpoint )
		AddAnalysisIterator( analysis, 1 ) // iterate each node

		if ( Flag( "FlyerPickupAnalysis" ) )
		{
			foreach( animation in level.FlyerPickupAnimations )
			{
				if ( !( "analysis" in animation ) )
					continue

				AddAinAnalysisIndex( FLYER_MODEL, animation.flyer )

				local analysis = CreateFlightAnalysis( FLYER_MODEL, animation.flyer )
				AddBoundingMins( analysis, Vector( -200, -200, 20 ) )
				AddBoundingMaxs( analysis, Vector( 200, 200, 100 ) )
				AddAnalysisTraceMask( analysis, TRACE_MASK_SHOT_HULL )
				AddAnalysisFunc( analysis, AnaylsisFuncLegalFlightPath, HULL_HUMAN )
				AddAnalysisIterator( analysis, 1 )

				animation.analysis <- analysis
			}
		}
	}
	else
	{
		local analysis = CreateFlightAnalysis( DROPPOD_MODEL, DROPPOD_DROP_ANIM )
		AddBoundingMins( analysis, Vector( -64, -64, 0.0 ) )
		AddBoundingMaxs( analysis, Vector( 64, 64, 97.331 ) )
	}

	//local event = "bomb_drop"
	//local analysis = CreateFlightAnalysis( "models/vehicle/imc_bomber/bomber.mdl", "bombing_run_1", event )
	//AddBoundingMins( analysis, Vector( -450, -450, -55.2101 ) )
	//AddBoundingMaxs( analysis, Vector( 450, 450, 262.475 ) )




	local analysis = CreateFlightAnalysis( ATLAS_MODEL, "at_hotdrop_medium_altitude" )
	AddBoundingMins( analysis, Vector( -65, -65, 0 ) )
	AddBoundingMaxs( analysis, Vector( 65, 65, 240 ) )
	AddAnalysisTraceMask( analysis, TRACE_MASK_TITANSOLID )
	AddIdleAnimation( analysis, "at_idle_2" )

	local analysis = CreateFlightAnalysis( ATLAS_MODEL, "at_hotdrop_low_altitude" )
	AddBoundingMins( analysis, Vector( -85, -85, 0 ) )
	AddBoundingMaxs( analysis, Vector( 85, 85, 240 ) )
	AddAnalysisTraceMask( analysis, TRACE_MASK_TITANSOLID )
	AddIdleAnimation( analysis, "at_idle_2" )

	if ( !IsServer() )
		return

	CreateFallbackNodes()

	FlagSet( "FlightAnalysisReady" )
}


function DrawAnalysis( analysis )
{
	FlagWait( "GamePlaying" )
	wait 3

	local points = analysis.points
	for ( local i = 1; i < points.len(); i++ )
	{
		local point1 = points[i-1]
		local point2 = points[i]
		DebugDrawLine( point1.origin, point2.origin, 255, 0, 0, true, 15 )
	}
}

function CreateFlightAnalysis( model, anim, event = null, attachments = null )
{
	if ( !( model in level.flightAnalysis ) )
	{
		level.flightAnalysis[ model ] <- {}
	}

	Assert( !( anim in level.flightAnalysis[ model ] ), "Already added " + anim + " to flight analysis for " + model )

	local table = {}

	table.preview <- null
	table.mins <- null
	table.maxs <- null
	table.traceMask <- TRACE_MASK_NPCWORLDSTATIC
	table.idleAnim <- null
	table.deployAttach <- {}
	table.deployAttach[ "left" ] <- []
	table.deployAttach[ "right" ] <- []
	table.nodes <- []
	table.model <- model
	table.anim <- anim
	table.iterator <- null

	local dropship = CreatePropDynamic( model, Vector(0,0,0), Vector(0,0,0) )

	table.points <- FillFlightAnaylsisPoints( dropship, anim )
	if ( table.points.len() )
		table.preview = clone table.points.top()

	if ( event )
	{
		FillDeployForAnalysisForEvent( dropship, anim, event, table, attachments )
	}

	/*
	local points = table.points
	for ( local i = 0; i + 1 < points.len(); i++ )
	{
		DebugDrawLine( points[i].origin, points[i+1].origin, 255, 0, 0, true, 20.0 )
	}
	*/

	dropship.Kill()

	//table.model <- model
	level.flightAnalysis[ model ][ anim ] <- table
	return table
}

function qt()
{
	thread qtwtf()
}

function qtwtf()
{
	level.ent.Signal( "NewFirstPersonSequence" )
	level.ent.EndSignal( "NewFirstPersonSequence" )
	local model = "models/vehicle/goblin_dropship/goblin_dropship.mdl"
	local anim = "gd_goblin_zipline_strafe"
	local dropship = CreatePropDynamic( model, Vector(0,0,0), Vector(0,0,0) )
	local array = FillFlightAnaylsisPoints( dropship, anim, 2.0 )
	DrawAnalysisArray( array )

}

function DrawAnalysisArray( array )
{
	local colors = []
	colors.append( { r = 255, g = 155, b = 10 } )
	colors.append( { r = 55, g = 55, b = 250 } )

	local index = 0
	local color
	for ( local i = 0; i + 1 < array.len(); i++ )
	{
		index++
		index %= colors.len()
		color = colors[ index ]
		DebugDrawLine( array[i].origin, array[i+1].origin, color.r, color.g, color.b, true, 15.0 )
	}
}

function FillFlightAnaylsisPoints( dropship, anim )
{
	dropship.Hide()

// try to precompute the various flight paths. Disabled because angle info is coming in wrong.
	local attachName = "ORIGIN"
	local attachIndex = dropship.LookupAttachment( attachName )
	if ( attachIndex == 0 )
	{
		attachName = "OFFSET"
		attachIndex = dropship.LookupAttachment( attachName )
		if ( attachIndex == 0 )
			return []
	}

	local duration = dropship.GetSequenceDuration( anim )
	local steps = duration * 1.5
	steps = steps.tointeger()
	local time, ratio, result
	local array = []

	if ( !steps )
	{
		result = dropship.Anim_GetAttachmentAtTime( anim, attachName, 0.0 )

		local point = {}
		if ( result.position.z < DROP_MIN_X )
			result.position.z = DROP_MIN_X

		point.origin <- result.position
		point.angles <- result.angle

		array.append( point )
		return array
	}

	for ( local i = 0; i <= steps; i++ )
	{
		ratio = i.tofloat() / steps.tofloat()
		time = duration * ratio
		result = dropship.Anim_GetAttachmentAtTime( anim, attachName, time )

		local point = {}
		if ( result.position.z < DROP_MIN_X )
			result.position.z = DROP_MIN_X

		point.origin <- result.position
		point.angles <- result.angle

		array.append( point )
	}

	local removed = {}
	for ( local i = 1; i + 1 < array.len(); i++ )
	{
		local pR = array[ i - 1 ].origin
		local p = array[ i ].origin
		local pF = array[ i + 1 ].origin

		local vec1 = pR - pF
		local vec2 = pR - p

		vec1.Norm()
		vec2.Norm()

		local dot = vec1.Dot( vec2 )

		if ( dot > 0.998 )
			removed[ array[i] ] <- true
	}

	local smoothed = false

	for ( local i = 0; i < array.len(); i++ )
	{
		if ( array[i] in removed )
		{
			array.remove( i )
			i--
		}
	}

	return array
}



function AddIdleAnimation( analysis, anim )
{
	analysis.idleAnim = anim
}

function AddAnalysisTraceMask( analysis, mask )
{
	analysis.traceMask = mask
}

function AddBoundingMaxs( analysis, maxs )
{
	analysis.maxs = maxs
}

function AddBoundingMins( analysis, mins )
{
	analysis.mins = mins
}

function AddAnalysisIterator( analysis, iterator )
{
	analysis.iterator = iterator
}

function AddAnalysisFunc( analysis, func, hull )
{
	analysis.analysisFunc <- func
	analysis.hull <- hull
}

function AddPrepSpawnpointFunc( analysis, func )
{
	analysis.analysisPrepSpawnpointFunc <- func
}

function AddAttachPoint( table, side, name, org, ang )
{
	local point = {}
	point.origin <- org
	point.angles <- ang
	point.name <- name
	table.deployAttach[ side ].append( point )
}

function GetAttachPoints( analysis, side )
{
	return analysis.deployAttach[ side ]
}

function AddAnalysisPoint( table, org, ang )
{
	local point = {}
	if ( org.z < DROP_MIN_X )
		org.z = DROP_MIN_X
	point.origin <- org

	// bounding boxes currently ignore pitch and roll
//	ang.x = 0
//	ang.z = 0
	point.angles <- ang
	table.points.append( point )
}

function AddPreviewPoint( table, org, ang )
{
//	if ( org.z < DROP_MIN_X )
//		org.z = DROP_MIN_X
	local point = {}
	point.origin <- org
	point.angles <- ang
	table.preview = point
}

function GetPreviewPoint( analysis )
{
	return analysis.preview
}


function CheckTime()
{
	local time = Time() - level.startTime
	time *= 30
	time = time.tointeger()
	printt( "TIMR " + time )
}

function FlightMark( dropship, table )
{
	table.points.append( GetPointFromPosition( dropship ) )
}



function FillDeployForAnalysisForEvent( dropship, anim, event, table, attachments = null )
{
	local frac = dropship.GetScriptedAnimEventCycleFrac( anim, event )
	Assert( frac != -1, " event " + event + " does not exist in animation " + anim )
	if ( !frac )
		return

	local duration = dropship.GetSequenceDuration( anim )
	local time = duration * frac
	local result = dropship.Anim_GetAttachmentAtTime( anim, "ORIGIN", time )
	Assert( result )

	local point = {}
	point.origin <- result.position
	point.angles <- result.angle

	table.preview = point

	if ( attachments )
	{
		table.deployAttach <- {}

		foreach ( side, attachArray in attachments )
		{
			table.deployAttach[ side ] <- []
			for ( local i = 0; i < attachArray.len(); i++ )
			{
				local attach = attachArray[i]
				local result = dropship.Anim_GetAttachmentAtTime( anim, attach, time )
				local pos = {}
				pos.origin <- result.position
				pos.angles <- result.angle
				pos.name <- attach

				table.deployAttach[ side ].append( pos )
			}
		}
	}
}

function DropshipFlightDeploy( dropship, table )
{
	// Stores off the attachment positional info on the drop-frame.
	table.deploy <- GetPointFromPosition( dropship )
	table.deployAttach <- {}

//	table.deployVelocity <- dropship.GetVelocity()
	printt( "dropship origin " + dropship.GetOrigin() )

	foreach ( side, attachArray in GetDropshipRopeAttachments() )
	{
		table.deployAttach[ side ] <- {}
		foreach ( attach in attachArray )
		{
			local pos = {}
			local attach_id = dropship.LookupAttachment( attach )
			pos.origin <- dropship.GetAttachmentOrigin( attach_id )
			pos.angles <- dropship.GetAttachmentAngles( attach_id )
			//printt( "origin " + pos.origin )

			table.deployAttach[ side ][ attach ] <- pos
			//DrawArrow( pos.origin, pos.angles, 5.0, 150 )
		}
	}
}

function FlightDeploy( dropship, table )
{
	table.deploy <- GetPointFromPosition( dropship )
	//DebugDrawLine( Vector(0,0,0), dropship.GetOrigin(), 0, 255, 0, true, 20 )

}

function AddFlightAnalysis( model, anim )
{
	if ( !( "startTime" in level ) )
		level.startTime <- Time()

	//local dropship = SpawnAnimatedDropship( Vector(0,0,0), 1 )
	local dropship = CreatePropDynamic( model, Vector(0,0,0), Vector(0,0,0) ) // 1 )
//	local dropship = CreateEntity( "npc_dropship" )
//	dropship.kv.spawnflags = 0
//	dropship.kv.vehiclescript = "scripts/vehicles/airvehicle_default.txt"
//	dropship.kv.skin = 1
//	dropship.SetModel( model )
//	DispatchSpawn( dropship, true )
//	dropship.kv.rendermode = 3
//	dropship.kv.rendercolor = "0 255 0"
//	dropship.kv.renderamt = 55

	local ref = CreateScriptRef()
	ref.SetOrigin( Vector(0,0,0) )
	ref.SetAngles( Vector(0,0,0) )

	local table = {}
	table.points <- []

	AddAnimEvent( dropship, "flightmark", FlightMark, table )
	AddAnimEvent( dropship, "dropship_deploy", DropshipFlightDeploy, table )
	AddAnimEvent( dropship, "bomb_drop", FlightDeploy, table )

	if ( anim.find( "loop" ) != null )
	{
		thread PlayAnimTeleport( dropship, anim, ref )
		wait 2
		dropship.Anim_Stop()
	}
	else
	{
		waitthread PlayAnimTeleport( dropship, anim, ref )
	}

	if ( !( "deploy" in table ) )
	{
		// no manually set deploy means save last frame as the deploy frame
		FlightMark( dropship, table )
		FlightDeploy( dropship, table )
	}

	local mins = dropship.GetBoundingMins()
	local maxs = dropship.GetBoundingMaxs()
	printl( " " )
	printl( " " )
	printl( " " )
	printl( " " )
	printl( " " )

	local points = table.points
	printl( "	local analysis = CreateFlightAnalysis( \"" + model + "\", \"" + anim + "\" )" )
	for ( local i = 0; i < points.len(); i++ )
	{
		local org = points[i].origin
		local ang = points[i].angles
		printl( "	AddAnalysisPoint( analysis, Vector( " + org.x + ", " + org.y + ", " + org.z + " ), Vector( " + ang.x + ", " + ang.y + ", " + ang.z + " ) )" )
	}

	if ( "deploy" in table )
	{
		local org = table.deploy.origin
		local ang = table.deploy.angles
		printl( "	AddPreviewPoint( analysis, Vector( " + org.x + ", " + org.y + ", " + org.z + " ), Vector( " + ang.x + ", " + ang.y + ", " + ang.z + " ) )" )
		if ( "deployAttach" in table )
		{
			foreach ( side, tab in table.deployAttach )
			{
				foreach ( name, attach in tab )
				{
					local org = attach.origin
					local ang = attach.angles
					printl( "	AddAttachPoint( analysis, \"" + side + "\", \"" + name + "\", Vector( " + org.x + ", " + org.y + ", " + org.z + " ), Vector( " + ang.x + ", " + ang.y + ", " + ang.z + " ) )" )
				}
			}
		}

//		local org = table.deployVelocity
//		printl( "	AddDeployVelocity( analysis, Vector( " + org.x + ", " + org.y + ", " + org.z + " ) )" )

	}

	printl( "	AddBoundingMins( analysis, Vector( " + mins.x + ", " + mins.y + ", " + mins.z + " ) )" )
	printl( "	AddBoundingMaxs( analysis, Vector( " + maxs.x + ", " + maxs.y + ", " + maxs.z + " ) )" )



	printl( " " )
	printl( " " )
	printl( " " )
	printl( " " )
	printl( " " )
}


/*
function LegalFlightPath( analysis, origin, angles )
{

}
*/

function GetAnalysisOffset( analysis )
{
	if ( analysis.model in level.superCallinOffset )
		return Vector( 0,0,level.superCallinOffset[ analysis.model ] )

	return Vector( 0, 0, 0 )
}


function MaskTester( mask )
{
	printt( "called from " + DumpPreviousFunction() )
	local array = {}
	array[" CONTENTS_EMPTY				"] <- CONTENTS_EMPTY
	array[" CONTENTS_SOLID				"] <- CONTENTS_SOLID
	array[" CONTENTS_WINDOW				"] <- CONTENTS_WINDOW
	array[" CONTENTS_AUX					"] <- CONTENTS_AUX
	array[" CONTENTS_GRATE				"] <- CONTENTS_GRATE
	array[" CONTENTS_SLIME				"] <- CONTENTS_SLIME
	array[" CONTENTS_WATER				"] <- CONTENTS_WATER
	array[" CONTENTS_WINDOW_NOCOLLIDE		"] <- CONTENTS_WINDOW_NOCOLLIDE
	array[" CONTENTS_OPAQUE				"] <- CONTENTS_OPAQUE
	array[" CONTENTS_TESTFOGVOLUME		"] <- CONTENTS_TESTFOGVOLUME
	array[" CONTENTS_UNUSED				"] <- CONTENTS_UNUSED
	array[" CONTENTS_BLOCKLIGHT			"] <- CONTENTS_BLOCKLIGHT
	array[" CONTENTS_TEAM1				"] <- CONTENTS_TEAM1
	array[" CONTENTS_TEAM2				"] <- CONTENTS_TEAM2
	array[" CONTENTS_IGNORE_NODRAW_OPAQUE	"] <- CONTENTS_IGNORE_NODRAW_OPAQUE
	array[" CONTENTS_MOVEABLE				"] <- CONTENTS_MOVEABLE
	array[" CONTENTS_PLAYERCLIP			"] <- CONTENTS_PLAYERCLIP
	array[" CONTENTS_MONSTERCLIP			"] <- CONTENTS_MONSTERCLIP
	array[" CONTENTS_BRUSH_PAINT			"] <- CONTENTS_BRUSH_PAINT
	array[" CONTENTS_BLOCKLOS				"] <- CONTENTS_BLOCKLOS
	array[" CONTENTS_NOCLIMB				"] <- CONTENTS_NOCLIMB
	array[" CONTENTS_TITANCLIP			"] <- CONTENTS_TITANCLIP
	array[" CONTENTS_BULLETCLIP			"] <- CONTENTS_BULLETCLIP
	array[" CONTENTS_UNUSED5				"] <- CONTENTS_UNUSED5
	array[" CONTENTS_ORIGIN				"] <- CONTENTS_ORIGIN
	array[" CONTENTS_MONSTER				"] <- CONTENTS_MONSTER
	array[" CONTENTS_DEBRIS				"] <- CONTENTS_DEBRIS
	array[" CONTENTS_DETAIL				"] <- CONTENTS_DETAIL
	array[" CONTENTS_TRANSLUCENT			"] <- CONTENTS_TRANSLUCENT
	array[" CONTENTS_LADDER				"] <- CONTENTS_LADDER
	array[" CONTENTS_HITBOX				"] <- CONTENTS_HITBOX

	foreach ( key, val in array )
	{
		if ( val & mask )
			printt( "found " + key )
	}
}
Globalize( MaskTester )


function AddNewAnalysis( model, anim, nodeIndex = null )
{
	printt( "Writing Analysis for " + model + " " + anim )

	local nodeCount = GetNodeCount()
	local analysis = GetAnalysisForModel( model, anim )

	local offset = GetAnalysisOffset( analysis )

	local iterator = analysis.iterator
	Assert( iterator, "Iterator not set!" )

	local func

	if ( level.activeNodeAnalysis )
		func = NodeAnalysis
	else
		func = NodeAnalysisPreview

	local total = 0
	local dataIndex = GetAnalysisDataIndex( analysis )
	printt( "dataIndex: " + dataIndex )

	if ( nodeIndex != null )
	{
		total += func( analysis, nodeIndex, offset )
	}
	else
	{
		for ( local index = 0; index < nodeCount; index += iterator )
		{
			//printt( "Node " + index + " / " + nodeCount )
			total += func( analysis, index, offset )
		}
	}

	return total
}


function FillFlightAnaylsisPoints2( dropship, anim )
{
	dropship.Hide()

// try to precompute the various flight paths. Disabled because angle info is coming in wrong.
	local attachIndex = dropship.LookupAttachment( "ORIGIN" )
	if ( attachIndex == 0 )
		return []

	local duration = dropship.GetSequenceDuration( anim )
	local steps = duration * 15.0 // 100.0
	local time, ratio, result
	local array = []

	local stepper = ( steps * 0.98 ).tointeger()
	printt ("stepper " + stepper )

	for ( local i = 0; i <= steps; i++ )
	{
		ratio = i / steps
		time = duration * ratio
		result = dropship.Anim_GetAttachmentAtTime( anim, "ORIGIN", time )

		local point = {}
		if ( result.position.z < DROP_MIN_X )
			result.position.z = DROP_MIN_X

		//result.angle.z = 0
		point.origin <- result.position
		point.angles <- result.angle
		point.skip <- stepper > 0 && i % stepper == 0

		array.append( point )
	}

	for ( ;; )
	{
		local smoothed = false
		for ( local i = 1; i + 1 < array.len(); i++ )
		{
			if ( array[i].skip )
				continue
			local pR = array[ i - 1 ].origin
			local p = array[ i ].origin
			local pF = array[ i + 1 ].origin

			local vec1 = p - pR
			local vec2 = p - pF
			local length = vec1.Length() + vec2.Length()

			vec1.Norm()
			vec2.Norm()

			local dot = vec1.Dot( vec2 )

	//		if ( dot < 0.99999
			if ( length < 100 )
			{
				if ( dot < -0.8 )
				{
//					printt( "dot " + dot )
					array.remove( i )
					i--
					smoothed = true
					continue
				}
			}
			else
			if ( length < 1000 )
			{
				if ( dot < -0.99 )
				{
//					printt( "dot " + dot )
					array.remove( i )
					i--
					smoothed = true
					continue
				}
			}
			else
			if ( length < 4000 )
			{
				if ( dot < -0.995 )
				{
//					printt( "dot " + dot )
					array.remove( i )
					i--
					smoothed = true
					continue
				}
			}
			else
			{
				if ( dot < -0.999 )
				{
//					printt( "dot " + dot )
					array.remove( i )
					i--
					smoothed = true
					continue
				}
			}
		}

		if ( !smoothed )
			break
	}

/*
	for ( local i = 0; i <= steps; i++ )
	{
		if ( timer )
			wait timer
		ratio = i / steps
		time = duration * ratio
		result = dropship.Anim_GetAttachmentAtTime( anim, "ORIGIN", time )

		local point = {}
		if ( result.position.z < DROP_MIN_X )
			result.position.z = DROP_MIN_X


		if ( array.len() >= 2 )
		{
			if ( i < steps - 1 )
			{
				local p1 = array[ array.len() - 2 ].origin
				local p2 =  array.top().origin
				local vec1 = p2 - p1
				vec1.Norm()

				local vec2 = result.position - p1
				vec2.Norm()

				if ( timer )
				{
					DebugDrawLine( p1, p2, 255, 255, 0, true, timer )
					DebugDrawLine( p1, result.position, 0, 255, 255, true, timer )
				}

				local dot = vec1.Dot( vec2 )
				if ( dot >= 0.997 )
				{
					if ( timer )
						DebugDrawText( result.position, "" + dot, true, timer )

					local vec3 = result.position - p2
					vec3.Norm()
					dot = vec2.Dot( vec3 )
					if ( dot >= 0.9999 )
					{
						continue
					}
				}

				if ( timer )
					DebugDrawText( result.position, "" + dot, true, 5.0 )
			}
		}

		if ( array.len() && Distance( result.position, array.top().origin ) < 1000 )
		{
			if ( i < steps - 1 )
				continue
		}

		if ( array.len() )
		{
			DebugDrawLine( result.position, array.top().origin, 255, 0, 0, true, 5.0 )
		}
		//result.angle.z = 0
		point.origin <- result.position
		point.angles <- result.angle

		array.append( point )
	}

	printt( "Steps " + array.len() )
*/
	/*
	local dropship2 = CreatePropDynamic( dropship.GetModelName(), Vector(0,0,0), Vector(0,0,0) )
	time = duration.tofloat() / steps

	for ( local i = 1; i < array.len(); i++ )
	{
		local p1 = array[i-1]
		local p2 = array[i]

		//if ( abs( p1.origin.x ) < 16000 && abs( p1.origin.y ) < 16000 && abs( p1.origin.z ) < 16000 )
		//	dropship.SetOrigin( p1.origin )
        //
		//dropship.SetAngles( p1.angles )
        //
		local origin = dropship.GetAttachmentOrigin( attachIndex )
		local angles = dropship.GetAttachmentAngles( attachIndex )
		DrawArrow( p1.origin, p1.angles, 0.2, 100 )

		ClampToWorldspace( p1.origin )

		dropship2.SetOrigin( p1.origin )
		dropship2.SetAngles( p1.angles )

		DebugDrawLine( p1.origin, p2.origin, 255, 0, 0, true, 20 )
		printt( "angles :" + p1.angles )
		wait time
	}
	*/

	return array
}

function CodeCallback_AINFileBuilt()
{
	if ( !IsMultiplayer() )
		return

	level.ainTestTitan <- CreateNPCTitanFromSettings( "titan_atlas", TEAM_IMC, Vector(0,0,0), Vector(0,0,0) )
	level.testHardPoints = GetEntArrayByClass_Expensive( "info_hardpoint" )
	level.testFlagSpawnPoints = GetEntArrayByClass_Expensive( "info_spawnpoint_flag" )

	SetAINScriptVersion( AIN_REV )

	printt( "Building AIN file" )
	level.activeNodeAnalysis = true
	local totals = []

	foreach ( model, table in level.ainAnalysisIndices )
	{
		foreach ( anim, offset in table )
		{
			if ( Flag( "DisableDropships" ) && model == DROPSHIP_MODEL )
				continue

			printt( "Prebuilding node info for " + model + " / " + anim + "." )
			local count = AddNewAnalysis( model, anim )
			local table = {}
			table.count <- count
			table.anim <- anim
			table.model <- model
			totals.append( table )
		}
	}

	level.ainTestTitan.Destroy()
	local foundZero = false

	foreach ( total in totals )
	{
		printt( "Found " + total.count + " cases of " + total.model + " " + total.anim )
		if ( total.count == 0 )
			foundZero = true
	}

	Assert( !foundZero, "Found zero of an expected anim path. Make sure spectre nodes didn't leak!" )

	if ( GetCurrentPlaylistName() != "buildain" )
		return

	local count = GetMapCountForCurrentPlaylist()
	local currentMap = GetMapName()

	local mapIndex = 0
	for ( local index = 0; index < count; index++ )
	{
		local map = GetCurrentPlaylistMapByIndex( index )
		if ( map == currentMap )
		{
			mapIndex = index + 1
			break
		}
	}

	if ( mapIndex >= count )
		return

	local map = GetCurrentPlaylistMapByIndex( mapIndex )
	GameRules.ChangeMap( map, "tdm" )
}

function DebugReplacement()
{
	local player = GetPlayerArray()[0]
	local angles = player.EyeAngles()
	local forward = angles.AnglesToForward()
	local origin = player.EyePosition()

	local start = origin
	local end = origin + forward * 5000
	local result = TraceLine( start, end )
	local node = GetNearestNodeToPos( result.endPos )
	if ( node == -1 )
		return

	AddNewAnalysis( ATLAS_MODEL, HOTDROP_TURBO_ANIM, node )
}

function AnalysisPreview()
{
	level.drawAnalysisPreview = true
	local nodes = GetNodeCount()
	for ( local i = 0; i < nodes; i++ )
	{
		AddNewAnalysis( DROPSHIP_MODEL, DROPSHIP_VERTICAL, i )
		wait 0.25
	}
	level.drawAnalysisPreview = false
}
Globalize( AnalysisPreview )


function AddAinAnalysisIndex( model, anim )
{
	local count = 0
	foreach ( key, value in level.ainAnalysisIndices )
	{
		foreach ( item in value )
		{
			count++
		}
	}

	if ( !( model in level.ainAnalysisIndices ) )
	{
		level.ainAnalysisIndices[ model ] <- {}
	}

	level.ainAnalysisIndices[ model ][ anim ] <- count
	Assert( count + ANALYSIS_STEPS <= MAX_ANALYSIS_COUNT )
}


function CreateFallbackNodes()
{
	Assert( GetSpectreNodeCount().tofloat() / GetNodeCount() < 0.666, "Over 2/3rds of the nodes are Spectre Nodes. This means a spectre node likely leaked into the level!" )

	// fallback nodes are call in locations in case all else fails
	level.fallbackNodes <- {}

	foreach ( model, table in level.ainAnalysisIndices )
	{
		foreach ( anim, offset in table )
		{
			local analysis = GetAnalysisForModel( model, anim )
			local index = GetAnalysisDataIndex( analysis )
			FillFallbackNodesForAnalysis( index, analysis.hull )
		}
	}

	if ( AINFileIsUpToDate() )
		thread VerifyMapWorks()
}

function VerifyMapWorks()
{
	WaitEndFrame()
	if ( !IsNPCSpawningEnabled() )
		return

	foreach ( model, table in level.ainAnalysisIndices )
	{
		if ( model == DROPSHIP_MODEL && Flag( "DisableDropships" ) )
			continue

		foreach ( anim, offset in table )
		{
			local analysis = GetAnalysisForModel( model, anim )
			local dataIndex = GetAnalysisDataIndex( analysis )
			local array = level.fallbackNodes[ dataIndex ]
			Assert( array.len(), "Couldn't find place to play animation " + anim + ", set ai_ainRebuildOnMapStart to 1, and then reload level." )
		}
	}
}

function FillFallbackNodesForAnalysis( dataIndex, hull )
{
//	wait 3
	local table = {}

	local origin

	local max = ( 16500.0 * DESCRIPTION_MULTIPLIER ).tointeger()
	local min = max * -1
	local msg, x, y, z, foundIndex


	local storedOrigins = {} // for building the table only

	local minX = max
	local maxX = min
	local minY = max
	local maxY = min
	local minZ = max
	local maxZ = min

	for ( local i = 0; i < GetNodeCount(); i++ )
	{
		if ( !NodeHasCallInForDataIndex( i, dataIndex ) )
			continue

		origin = GetNodePos( i, hull )
		storedOrigins[ i ] <- origin
		x = ( origin.x * DESCRIPTION_MULTIPLIER ).tointeger()
		y = ( origin.y * DESCRIPTION_MULTIPLIER ).tointeger()
		z = ( origin.z * DESCRIPTION_MULTIPLIER ).tointeger()

		if ( !( x in table ) )
			table[x] <- {}

		if ( !( y in table[x] ) )
			table[x][y] <- {}

		if ( !( z in table[x][y] ) )
			table[x][y][z] <- null

		if ( table[x][y][z] != null ) // already filled this space
			continue

		table[x][y][z] = i

		if ( x < minX )
			minX = x
		if ( x > maxX )
			maxX = x
		if ( y < minY )
			minY = y
		if ( y > maxY )
			maxY = y
		if ( z < minZ )
			minZ = z
		if ( z > maxZ )
			maxZ = z
	}

	// fill in the holes
	for ( x = minX; x <= maxX; x++ )
	{
		if ( !( x in table ) )
			table[x] <- {}

		for ( y = minY; y <= maxY; y++ )
		{
			if ( !( y in table[x] ) )
				table[x][y] <- {}

			for ( z = minZ; z <= maxZ; z++ )
			{
				if ( !( z in table[x][y] ) )
					table[x][y][z] <- null

				if ( table[ x ][ y ][ z ] != null )
					continue

				foundIndex = GetClosestFromTable( x, y, z, storedOrigins )
				table[x][y][z] <- foundIndex
//				printt( "Filled " + x + "," + y + "," + z + " with " + foundIndex )
			}
		}
	}

	table.minX <- minX
	table.maxX <- maxX
	table.minY <- minY
	table.maxY <- maxY
	table.minZ <- minZ
	table.maxZ <- maxZ
	level.fallbackNodes[ dataIndex ] <- table
}

function GetClosestFromTable( x, y, z, storedOrigins )
{
	local vec = Vector( x / DESCRIPTION_MULTIPLIER, y / DESCRIPTION_MULTIPLIER, z / DESCRIPTION_MULTIPLIER )
	local dist = 999999
	local foundNode = null
	foreach ( index, origin in storedOrigins )
	{
		local newDist = Distance( origin, vec )
		if ( newDist > dist )
			continue
		foundNode = index
		dist = newDist
	}

	Assert( foundNode != null )
	return foundNode
}

function GetDescriptionFromOrigin( origin )
{
	// create a string out of the node's origin.
	// Each 1666 square unit space gets a max of one node

	local x = origin.x
	x *= DESCRIPTION_MULTIPLIER
	x = x.tointeger()

	local y = origin.y
	y *= DESCRIPTION_MULTIPLIER
	y = y.tointeger()

	local z = origin.z
	z *= DESCRIPTION_MULTIPLIER
	z = z.tointeger()

	local msg = x + " " + y + " " + z
	return msg
}

function NodeHasCallInForDataIndex( nodeIndex, dataIndex )
{
	for ( local i = dataIndex; i < dataIndex + ANALYSIS_STEPS; i++ )
	{
		if ( GetNodeScriptData_Boolean( nodeIndex, i ) )
			return true
	}

	return false
}

function CreateSimpleFlightAnalysis( model, anim )
{
	local attachName
	if ( model in level.originAttachmentNames )
		attachName = level.originAttachmentNames[ model ]
	else
		attachName = "ORIGIN"
	// need this to find the difference between ref and origin for the zipline slide
	local pete = CreatePropDynamic( model )
	local result = pete.Anim_GetAttachmentAtTime( anim, attachName, 0.0 )
	local analysis = CreateFlightAnalysis( model, anim )
	AddPreviewPoint( analysis, result.position, result.angle )
	pete.Kill()
}

function CompareDropshipModels( mdl1, mdl2, attachments )
{
	wait 3

	local model2 = CreatePropDynamic( mdl2, Vector(0,0,0), Vector(0,0,0) )

	local attachment = "RopeAttachRightC"
	local attachid2 = model2.LookupAttachment( attachment )
	local origin2 = model1.GetAttachmentOrigin( attachid2 )
	local angles2 = model1.GetAttachmentAngles( attachid2 )

	DrawArrow( origin2, angles2, 30, 100 )
	DebugDrawText( origin2 + Vector(0,0,20), mdl2, true, 30 )

/*
	return
	local model1 = CreatePropDynamic( mdl1, Vector(0,0,0), Vector(0,0,0) )
	local model2 = CreatePropDynamic( mdl2, Vector(0,0,0), Vector(0,0,0) )

//	attachments.origin <- [ "origin" ]
	local Orgattachid1 = model1.LookupAttachment( "origin" )
	local Orgattachid2 = model2.LookupAttachment( "origin" )
	local Orgorigin1 = model1.GetAttachmentOrigin( Orgattachid1 )
	local Orgorigin2 = model1.GetAttachmentOrigin( Orgattachid2 )

	foreach ( array in attachments )
	{
		foreach ( attachment in array )
		{
			local ent1 = CreateScriptMover( model1 )
			local ent2 = CreateScriptMover( model2 )
			ent1.SetParent( model1, attachment )
			ent2.SetParent( model2, attachment )
			printt( ent1.GetOrigin() )
			printt( ent2.GetOrigin() )
			printt( Distance( ent1.GetOrigin() )
//			local attachid1 = model1.LookupAttachment( attachment )
//			local attachid2 = model2.LookupAttachment( attachment )
//			local origin1 = model1.GetAttachmentOrigin( attachid1 )
//			local origin2 = model1.GetAttachmentOrigin( attachid2 )
//			local angles1 = model2.GetAttachmentAngles( attachid1 )
//			local angles2 = model2.GetAttachmentAngles( attachid2 )

//			DrawArrow( origin1, angles1, 30, 100 )
//			DrawArrow( origin2, angles2, 30, 100 )
//			DebugDrawText( origin1 + Vector(0,0,20), mdl1, true, 30 )
//			DebugDrawText( origin2 + Vector(0,0,20), mdl2, true, 30 )
//
//			DebugDrawText( origin1, attachment, true, 30 )
//			DebugDrawText( origin2, attachment, true, 30 )
//			printt( "Attach " + attachment )
//			printt( "Origin dist " + Distance( origin1, origin2 ) )
//			printt( "dist from origin1 " + Distance( Orgorigin1, origin1 ) )
//			printt( "dist from origin2 " + Distance( Orgorigin2, origin2 ) )
//			printt( "angles1 " + angles1 )
//			printt( "angles2 " + angles2 )
//			printt( " " )
		}
	}
	*/
}

function DebugDropship()
{
	thread DebugDropshipThread()
}

function DebugDropshipThread()
{
	local event = "dropship_deploy"
	local attaches = GetDropshipRopeAttachments()
	foreach ( anim in level.dropshipDropoffAnims )
	{
		printt( "testing anim " + anim )
		local analysis = GetAnalysisForModel( DROPSHIP_MODEL, anim )
		waitthread TestDropshipAnalysis( analysis )
	}
}

function TestDropshipAnalysis( analysis )
{
	local nodeCount = GetNodeCount()
	local offset = GetAnalysisOffset( analysis )
	local iterator = analysis.iterator
	Assert( iterator, "Iterator not set!" )

	local dataIndex = GetAnalysisDataIndex( analysis )
	printt( "dataIndex: " + dataIndex )

	//for ( local index = 0; index < nodeCount; index += iterator )
	local index = 24
	{
		//printt( "Node " + index + " / " + nodeCount )
		TestDropshipAnalysisFunc( analysis, index, offset )
	}
}


function TestDropshipSquad( guys, nodeIndex, yawIndex )
{
	printt( "Guys dropped: " + guys.len() )
	//Assert( guys.len() == 6 )

	wait 8

	foreach ( guy in guys )
	{
		if ( IsAlive( guy ) )
		{
			local nearestNode = GetNearestNodeToPosForNPC( guy, guy.GetOrigin() )
			printt( "Nearestnode was " + nearestNode )
			if ( nearestNode < 0 )
			{
				CodeWarning( "No node for guy from dropship node: " + nodeIndex + " with yaw index " + yawIndex )
				DrawArrow( guy.GetOrigin(), Vector(0,0,0), 10, 150 )
				continue
			}
			guy.Die()
		}
	}
}

function TestDropshipAnalysisFunc( analysis, index, offset )
{
	local origin = GetNodePos( index, analysis.hull )
	origin = origin + offset

	local dataIndex = GetAnalysisDataIndex( analysis )

//	for ( local p = 0; p < ANALYSIS_STEPS; p++ )
	local p = 0
	{
		if ( GetNodeScriptData_Boolean( index, p + dataIndex ) )
		{

	//		if ( !array[ p ] )
	//		{
	////			printt( ( p + dataIndex ) + ": False" )
	//			continue
	//		}
	//
	////		printt( ( p + dataIndex ) + ": True" )

			local yaw = p * ANALYSIS_YAW_STEP
			local angles = Vector( 0, yaw, 0 )
			local forward = angles.AnglesToForward()
			DebugDrawLine( origin, origin + forward * 80, 255, 100, 0, true, 5.0 )

			local drop 		= CreateDropshipDropoff()
			drop.origin 	= origin // GetNodePos( p, analysis.hull )
			drop.yaw 		= yaw
			drop.anim		= analysis.anim
			drop.team 		= TEAM_MILITIA
			drop.side 		= "both"
			drop.count 		= 6
			drop.style 		= eDropStyle.FORCED

			thread RunDropshipDropoff( drop )
			WaitSignal( drop, "WarpedIn" )

			thread DebugDropshipLine( origin, drop.dropship )
			local result = WaitSignal( drop, "OnDropoff" )
			thread TestDropshipSquad( result.guys, index, p )

			drop.dropship.WaitSignal( "OnDeath" )
		}
	}
}

function DebugDropshipLine( origin, dropship )
{
	dropship.EndSignal( "OnDeath" )
	for ( ;; )
	{
		DebugDrawLine( origin, dropship.GetOrigin(), 255, 0, 0, true, 0.15 )
		wait 0
	}
}


function ShowAllTitanFallSpots()
{
	wait 0.5
//	local analysis = GetAnalysisForModel( DROPPOD_MODEL, DROPPOD_DROP_ANIM )
//	local analysis = GetAnalysisForModel( STRATON_MODEL, STRATON_FLIGHT_ANIM )
//	local analysis = GetAnalysisForModel( STRATON_MODEL, STRATON_DOGFIGHT_ANIM1 )
	//
	//local analysis = GetAnalysisForModel( ATLAS_MODEL, HOTDROP_TURBO_ANIM )
//	local analysis = GetAnalysisForModel( STRATON_MODEL, STRATON_ATTACK_FULL )
//	local analysis = GetAnalysisForModel( FLYER_MODEL, "flyer_PickingUp_Soldier_dive" )
//	local analysis = GetAnalysisForModel( DROPSHIP_MODEL, DROPSHIP_VERTICAL )
	local analysis = GetAnalysisForModel( ATLAS_MODEL, HOTDROP_TURBO_ANIM )

	local nodeCount = GetNodeCount()
	local offset = GetAnalysisOffset( analysis )
	local iterator = analysis.iterator
	local dataIndex = GetAnalysisDataIndex( analysis )

	local up = Vector(0,0,10)
	local down = Vector(0,0,-10)
	local right = Vector(0,10,0)
	local left = Vector(0,-10,0)
	local forward = Vector(10,0,0)
	local back = Vector(-10,0,0)

	local origin
	local drawThrough = true
	local time = 120

	local yawVecs = []
	for ( local i = 0; i < ANALYSIS_STEPS; i++ )
	{
		local yaw = i * ANALYSIS_YAW_STEP
		local forward = Vector( 0, yaw, 0 ).AnglesToForward()
		yawVecs.append( forward * 20.0 )
	}

	printt( "checking dataIndex " + dataIndex )

	local hits = 0
	for ( local i = 0; i < nodeCount; i++ )
	{
//		i = 2414
		origin = GetNodePos( i, analysis.hull )
		for ( local p = 0; p < ANALYSIS_STEPS; p++ )
		{
			if ( GetNodeScriptData_Boolean( i, p + dataIndex ) )
			{
				DebugDrawLine( origin, origin + yawVecs[p], 0, 255, 0, drawThrough, time )
				hits++
			}
			else
			{
				DebugDrawLine( origin, origin + yawVecs[p], 255, 0, 0, drawThrough, time )
			}
		}
		//return

/*
		if ( NodeHasFlightPath( dataIndex, i ) )
		{
			DebugDrawLine( origin + down, origin + up, 0, 255, 0, drawThrough, time )
			DebugDrawLine( origin + right, origin + left, 0, 255, 0, drawThrough, time )
			DebugDrawLine( origin + forward, origin + back, 0, 255, 0, drawThrough, time )
		}
		else
		{
			DebugDrawLine( origin + down, origin + up, 255, 0, 0, drawThrough, time )
			DebugDrawLine( origin + right, origin + left, 255, 0, 0, drawThrough, time )
			DebugDrawLine( origin + forward, origin + back, 255, 0, 0, drawThrough, time )
		}
*/
	}

	printt( "Found " + hits + " uses of this sequence." )
}

function AnaylsisFuncLegalFlightPath( analysis, origin, yaw )
{
	// find nodes that are legal for a simple flight path
	local angles = Vector( 0, yaw, 0 )
	local forward = angles.AnglesToForward()
	local right = angles.AnglesToRight()
	local legal = IsLegalFlightPath( analysis, origin, forward, right, !level.activeNodeAnalysis && PREVIEW_DEBUG )

	return legal
}


function AddFighterBounds( analysis )
{
	//AddBoundingMins( analysis, Vector( -378, -160, 0 ) )
	//AddBoundingMaxs( analysis, Vector( 256, 160, 208 ) )

	// tracehull requires square x/y for now..
	AddBoundingMins( analysis, Vector( -325, -325, 0 ) )
	AddBoundingMaxs( analysis, Vector( 325, 325, 208 ) )
}



function DogFightAnimsFromIndex( animIndex )
{
	local anim1
	local anim2

	switch ( animIndex )
	{
		case 0:
			anim1 = STRATON_DOGFIGHT_ANIM1
			anim2 = STRATON_DOGFIGHT_ANIM1_PERSUER
			break
		case 1:
			anim1 = STRATON_DOGFIGHT_ANIM2
			anim2 = STRATON_DOGFIGHT_ANIM2_PERSUER
			break
		case 2:
			anim1 = STRATON_DOGFIGHT_ANIM3
			anim2 = STRATON_DOGFIGHT_ANIM3_PERSUER
			break
	}

	return { anim1 = anim1, anim2 = anim2 }
}

function StratonHornetDogfights()
{
	//PrintFunc()
	level.ent.Signal( "StratonHornetDogfights" )
	level.ent.EndSignal( "StratonHornetDogfights" )

	for ( ;; )
	{
		for ( local i = 0; i < 20; i++ )
		{
			local yaw = RandomInt( 360 )
			thread SpawnRandomDogFight( yaw )

			wait RandomFloat( 4, 6 )
		}

		wait 20

		for ( local i = 0; i < 20; i++ )
		{
			local yaw = RandomInt( 360 )
			thread SpawnRandomDogFight( yaw )

			wait RandomFloat( 8, 20 )
		}

		wait 40
	}
}

function SpawnRandomDogFight( yaw )
{
	//PrintFunc()
	local animIndex = RandomInt( 3 )

	local anims = DogFightAnimsFromIndex( animIndex )
	local anim1 = anims.anim1

	local model = STRATON_MODEL
	local analysis = GetAnalysisForModel( model, anim1 )

	local drop = CreateCallinTable()
	drop.style = eDropStyle.RANDOM_FROM_YAW // spawn at a random node that points the right direction
	drop.yaw = yaw
 	local spawnPoint = GetSpawnPointForStyle( analysis, drop )
 	if ( !spawnPoint )
 		return

	local x = spawnPoint.origin.x.tointeger()
	local y = spawnPoint.origin.y.tointeger()
	local z = spawnPoint.origin.z.tointeger()
	local yaw = spawnPoint.angles.y.tointeger()

	local players = GetPlayerArray()
	foreach ( player in players )
	{
		Remote.CallFunction_NonReplay( player, "ServerCallback_DogFight", x, y, z, yaw, animIndex )
	}
}


function GetTitanfallNodesInRadius( nodeTable, titanfallOrigin, radius )
{
	Assert( type( nodeTable ) == "table" )
	Assert( nodeTable.len() == 0 )

	local analysis = GetAnalysisForModel( ATLAS_MODEL, HOTDROP_TURBO_ANIM )
	local dataIndex = GetAnalysisDataIndex( analysis )
	//wait 0

	local checkNodes = []
	checkNodes.append( GetNearestNodeToPos( titanfallOrigin + Vector( radius, 0, 0 ) ) )
	//wait 0
	checkNodes.append( GetNearestNodeToPos( titanfallOrigin + Vector( -radius, 0, 0 ) ) )
	//wait 0
	checkNodes.append( GetNearestNodeToPos( titanfallOrigin + Vector( 0, radius, 0 ) ) )
	//wait 0
	checkNodes.append( GetNearestNodeToPos( titanfallOrigin + Vector( 0, -radius, 0 ) ) )
	//wait 0

	local minDistSqr = (radius * radius)

	foreach ( startNode in checkNodes )
	{
		if ( startNode < 0 )
			continue

		local neighborNodes = GetNeighborNodes( startNode, 10, analysis.hull )
		foreach ( node in neighborNodes )
		{
			local nodeOrigin = GetNodePos( node, analysis.hull )
			local distSqr = DistanceSqr( titanfallOrigin, nodeOrigin )

			if ( distSqr < minDistSqr )
				nodeTable[node] <- []

			//wait 0
		}
	}
}

function DisableTitanfallForLifetimeOfEntityNearOrigin( ownerEntity, origin, radius = TITANHOTDROP_DISABLE_ENEMY_TITANFALL_RADIUS  )
{
	local nodeTable = {}
	GetTitanfallNodesInRadius( nodeTable, origin, radius )
	thread DisableTitanfallForNodes( nodeTable, ownerEntity, origin, radius )
}


function DisableTitanfallForNodes( nodeTable, ownerEntity, origin, radius )
{
	EndSignal( ownerEntity, "OnDestroy" )
	EndSignal( ownerEntity, "ClearDisableTitanfall" )

	local analysis = GetAnalysisForModel( ATLAS_MODEL, HOTDROP_TURBO_ANIM )
	local dataIndex = GetAnalysisDataIndex( analysis )

	local titanfallID = UniqueString()

	level.disallowedTitanfalls[ titanfallID ] <- { origin = origin, radius = radius }

	foreach ( node, nodeData in nodeTable )
	{
		Assert( nodeData.len() == 0 )
		nodeData.resize( ANALYSIS_STEPS )
		for ( local p = 0; p < ANALYSIS_STEPS; p++ )
		{
			nodeData[p] = GetNodeScriptData_Boolean( node, dataIndex + p )
			if ( nodeData[p] == true )
				SetNodeScriptData_Boolean( node, dataIndex + p, false )
		}
	}

	OnThreadEnd(
		function() : ( nodeTable, dataIndex, titanfallID )
		{
			delete level.disallowedTitanfalls[ titanfallID ]

			foreach ( node, nodeData in nodeTable )
			{
				Assert( nodeData.len() == ANALYSIS_STEPS )
				nodeData.resize( ANALYSIS_STEPS )
				for ( local p = 0; p < ANALYSIS_STEPS; p++ )
				{
					if ( nodeData[p] == true )
						SetNodeScriptData_Boolean( node, dataIndex + p, nodeData[p] )
				}
			}
		}
	)

	WaitSignal( ownerEntity, "OnDeath" )
}


function NearDisallowedTitanfall( origin )
{
	foreach ( titanfallData in level.disallowedTitanfalls )
	{
		if ( Distance( origin, titanfallData.origin ) > titanfallData.radius )
			continue

		return true
	}

	return false
}

function TestNodeForTitanDrop( node = 2414, yaw = 0 )
{
	local model = ATLAS_MODEL
	local animation = HOTDROP_TURBO_ANIM
	local analysis = GetAnalysisForModel( model, animation )

	local origin = GetNodePos( node, 0 )
	local angles = Vector(0,yaw,0)
	//local titan = CreatePropDynamic( model, origin, Vector(0,0,0) )
	local titan = CreateNPCTitanFromSettings( "titan_atlas", TEAM_IMC, origin, angles )
	local impactTime = GetHotDropImpactTime( titan, animation )

	local result = titan.Anim_GetAttachmentAtTime( animation, "OFFSET", impactTime )
	local resultPos = result.position

	local maxs = titan.GetBoundingMaxs()
	local mins = titan.GetBoundingMins()
	local trace = TraceHull( resultPos + Vector(0,0,20), resultPos + Vector(0,0,-20), mins, maxs, null, titan.GetPhysicsSolidMask(), TRACE_COLLISION_GROUP_NONE )
	local zDif = trace.endPos.z - result.position.z
	origin.z += zDif
	origin.z += 3.0

	titan.SetOrigin( origin )
	local canStand = TitanCanStand( titan )
	titan.Kill()
	//DebugDrawLine( origin, origin + Vector(0,0,16), 255, 0, 0, true, 5.0 )
	return canStand
}
Globalize( TestNodeForTitanDrop )

function AddTitanfallBlocker( origin, radius, height )
{
	local maxHeight = origin.z + height

	local table = { origin = origin, radius = radius, maxHeight = maxHeight }
	level.titanfallBlockers.append( table )
}
Globalize( AddTitanfallBlocker )