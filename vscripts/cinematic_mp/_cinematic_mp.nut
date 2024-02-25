
enum CINEMATIC_TYPES
{
	CHILD,

	// Global zingers, automatically triggered throughout match
	FLYOVER_STRAIGHT,
	FLYOVER_STRAIGHT_MULTI,
	DROPSHIP_DROPOFF_NOAI,
	DROPSHIP_TAKEOFF,
	DROPSHIP_DROPOFF_AI_SIDE,
	DROPSHIP_TOUCH_AND_GO,
	DOGFIGHT_OVER_WATER_STRAIGHT,
	DOGFIGHT_OVER_WATER_LEFT,
	DOGFIGHT_OVER_WATER_RIGHT,

	//AIRBASE specfic - manually triggered
	AIRBASE_GRAVES_CREW_1,
	AIRBASE_GRAVES_CREW_2,
	AIRBASE_GRAVES_CREW_3,
	AIRBASE_GRAVES_CREW_4,
	AIRBASE_GRAVES_CREW_5,
	AIRBASE_GRAVES_CREW_6,
	AIRBASE_GRAVES_HIMSELF,

	// Fracture Specific - manually triggered
	FRACTURE_DOGFIGHT,
	FRACTURE_SKYBOX_AA_TRACER,
	FRACTURE_SKYBOX_STATIC_REFUEL,

	//o2 specifc - manually triggered
	O2_END_BAD_IDEA,
	O2_END_CONTACT_GRAVES,
	O2_END_CAMFEED,
	O2_END_AMBUSH,
	O2_END_SACRIFICE,
	O2_END_DEATH,
	OUTPOST_TECH_DEFEND1,
	OUTPOST_TECH_DEFEND2,
	OUTPOST_TECH_ATTACK1,
	OUTPOST_TECH_ATTACK2,
	OUTPOST_TECH_ATTACK3,

	// AI Skits, trigged manually from AI Skit script
	AI_SKIT_DYING_WALLSLIDE,
	AI_SKIT_FIGHT_KNOCKBACK,
	AI_SKIT_WOUNDED_DRAG,
	AI_SKIT_WOUNDED_CARRY,
	AI_SKIT_PRISONER_KILL,
	AI_SKIT_SHOTGUN_WALLSLAM,
	AI_SKIT_SPECTRE_SPEEDKILL,
	AI_SKIT_SPECTRE_NECK_SNAP,
	AI_SKIT_LOOT_CORPSE,
	AI_SKIT_BRAWL,
	AI_SKIT_SPECTRE_BLINDFIRE,
	AI_SKIT_SPECTRE_CHESTPUNCH,
	AI_SKIT_SPECTRE_CURBSTOMP,
	AI_SKIT_SPECTRE_CRAWL,
	AI_SKIT_SPECTRE_ZOMBIEDRAG,
	AI_SKIT_SPECTRE_RAILING_SMASH,
	AI_SKIT_SPECTRE_BAR_FIGHT,
	AI_SKIT_SPECTRE_WINDOW_THROW,
	AI_SKIT_MELEE_FLIP,
	AI_SKIT_SPECTRE_BODYSLAM

	// Generic idles and one offs - manually triggered by scripter
	PROP_SKIT_CASUAL_IDLE_A,
	PROP_SKIT_CASUAL_IDLE_B,
	PROP_SKIT_CASUAL_IDLE_CQB,
	PROP_SKIT_PATROL_WALK_BORED,
	PROP_SKIT_PATROL_WALK_HIGHPORT,
	PROP_SKIT_PATROL_WALK_LOWPORT,
	PROP_SKIT_RAILING_STAND_SALUTE,
	PROP_SKIT_STANDING_TALKERS,
	PROP_SKIT_SEARCH_HOLE,

	// Leviathan
	LEVIATHAN_SPAWN,	// will spawn in a leviathan and him walk a path of child nodes.
	LEVIATHAN_ROAR,		// will stop and do a roar (might be a random )
	LEVIATHAN_WAIT,		// will stop and wait at this point until the progression reaches 50, 75 or 90 percent.
	LEVIATHAN_PATH,		// path that you can force a leviathan to start using.
	LEVIATHAN_REMOVE,	// remove leviathan here if remove_at_path_end is false

	// Angel City Search Phantoms
	SEARCHSHIP_PHANTOM_SPAWN,
	SEARCHSHIP_DRONE_SPAWN,
	SEARCHSHIP_SEARCH,
	SEARCHSHIP_SEARCH_TARGET,
	SEARCHSHIP_DELETE,

	TOTAL_COUNT
}

level.UsingCinematicNodeEditor <- false

// Anything in this table will be triggered automatically in the level. If you want to manually trigger them off, dont put them in here
level.autoTriggeredCinematicTypes <- {}
level.autoTriggeredCinematicTypes[ CINEMATIC_TYPES.FLYOVER_STRAIGHT ] <- true
level.autoTriggeredCinematicTypes[ CINEMATIC_TYPES.FLYOVER_STRAIGHT_MULTI ] <- true
level.autoTriggeredCinematicTypes[ CINEMATIC_TYPES.DROPSHIP_DROPOFF_NOAI ] <- true
level.autoTriggeredCinematicTypes[ CINEMATIC_TYPES.FRACTURE_DOGFIGHT ] <- true
level.autoTriggeredCinematicTypes[ CINEMATIC_TYPES.DOGFIGHT_OVER_WATER_STRAIGHT ] <- true
level.autoTriggeredCinematicTypes[ CINEMATIC_TYPES.DOGFIGHT_OVER_WATER_LEFT ] <- true
level.autoTriggeredCinematicTypes[ CINEMATIC_TYPES.DOGFIGHT_OVER_WATER_RIGHT ] <- true


// cinematic types that are child nodes
level.childNodes <- {}
level.childNodes[ CINEMATIC_TYPES.CHILD ] <- true
level.childNodes[ CINEMATIC_TYPES.LEVIATHAN_ROAR ] <- true
level.childNodes[ CINEMATIC_TYPES.LEVIATHAN_WAIT ] <- true
level.childNodes[ CINEMATIC_TYPES.LEVIATHAN_REMOVE ] <- true
level.childNodes[ CINEMATIC_TYPES.SEARCHSHIP_SEARCH ] <- true
level.childNodes[ CINEMATIC_TYPES.SEARCHSHIP_SEARCH_TARGET ] <- true
level.childNodes[ CINEMATIC_TYPES.SEARCHSHIP_DELETE ] <- true

//################################################################
// Functions to run on client for specified types, when triggered
//################################################################

level.momentClientFunc <- {}
level.momentClientFunc[ CINEMATIC_TYPES.FRACTURE_SKYBOX_AA_TRACER ] 	<- "FractureSkyboxTracer"
level.momentClientFunc[ CINEMATIC_TYPES.FRACTURE_SKYBOX_STATIC_REFUEL ] <- "SkyBoxStaticRefuelRod_Think"
level.momentClientFunc[ CINEMATIC_TYPES.O2_END_BAD_IDEA ] 				<- "EndVDUMoment_BadIdea"
level.momentClientFunc[ CINEMATIC_TYPES.O2_END_CONTACT_GRAVES ] 		<- "EndVDUMoment_ContactGraves"
level.momentClientFunc[ CINEMATIC_TYPES.O2_END_CAMFEED ] 				<- "EndVDUMoment_CamFeedMilitia"
level.momentClientFunc[ CINEMATIC_TYPES.O2_END_AMBUSH ] 				<- "EndVDUMoment_Ambush"
level.momentClientFunc[ CINEMATIC_TYPES.O2_END_SACRIFICE ] 				<- "EndVDUMoment_Sacrifice"
level.momentClientFunc[ CINEMATIC_TYPES.O2_END_DEATH ] 					<- "EndVDUMoment_Death"
level.momentClientFunc[ CINEMATIC_TYPES.OUTPOST_TECH_DEFEND1 ] 			<- "TechTeam_Defend1"
level.momentClientFunc[ CINEMATIC_TYPES.OUTPOST_TECH_DEFEND2 ] 			<- "TechTeam_Defend2"
level.momentClientFunc[ CINEMATIC_TYPES.OUTPOST_TECH_ATTACK1 ] 			<- "TechTeam_Attack1"
level.momentClientFunc[ CINEMATIC_TYPES.OUTPOST_TECH_ATTACK2 ] 			<- "TechTeam_Attack2"
level.momentClientFunc[ CINEMATIC_TYPES.OUTPOST_TECH_ATTACK3 ] 			<- "TechTeam_Attack3"
level.momentClientFunc[ CINEMATIC_TYPES.DOGFIGHT_OVER_WATER_STRAIGHT ]	<- "Moment_HavenWaterDogFight"
level.momentClientFunc[ CINEMATIC_TYPES.DOGFIGHT_OVER_WATER_LEFT ]		<- "Moment_HavenWaterDogFight"
level.momentClientFunc[ CINEMATIC_TYPES.DOGFIGHT_OVER_WATER_RIGHT ] 	<- "Moment_HavenWaterDogFight"


//################################################################
// Functions to run on server for specified types, when triggered
//################################################################

level.momentServerFunc <- {}
level.momentServerFunc[ CINEMATIC_TYPES.FLYOVER_STRAIGHT ] 				<- "Moment_Flyover_Straight"
level.momentServerFunc[ CINEMATIC_TYPES.FLYOVER_STRAIGHT_MULTI ] 		<- "Moment_Flyover_Straight_Multi"
level.momentServerFunc[ CINEMATIC_TYPES.DROPSHIP_DROPOFF_NOAI ] 		<- "Moment_Dropship_Dropoff_NoAI"
level.momentServerFunc[ CINEMATIC_TYPES.DROPSHIP_TOUCH_AND_GO ] 		<- "Moment_Dropship_TouchAndGo"
level.momentServerFunc[ CINEMATIC_TYPES.DROPSHIP_TAKEOFF ] 				<- "Moment_Dropship_Takeoff"
level.momentServerFunc[ CINEMATIC_TYPES.DROPSHIP_DROPOFF_AI_SIDE ]		<- "Moment_Dropship_DropOffAISide"
level.momentServerFunc[ CINEMATIC_TYPES.FRACTURE_DOGFIGHT ] 			<- "Moment_Fracture_Dogfight"
level.momentServerFunc[ CINEMATIC_TYPES.AI_SKIT_DYING_WALLSLIDE ] 		<- "DoAISkit"
level.momentServerFunc[ CINEMATIC_TYPES.AI_SKIT_FIGHT_KNOCKBACK ] 		<- "DoAISkit"
level.momentServerFunc[ CINEMATIC_TYPES.AI_SKIT_WOUNDED_DRAG ] 			<- "DoAISkit"
level.momentServerFunc[ CINEMATIC_TYPES.AI_SKIT_WOUNDED_CARRY ] 		<- "DoAISkit"
level.momentServerFunc[ CINEMATIC_TYPES.AI_SKIT_PRISONER_KILL ] 		<- "DoAISkit"
level.momentServerFunc[ CINEMATIC_TYPES.AI_SKIT_SHOTGUN_WALLSLAM ] 		<- "DoAISkit"
level.momentServerFunc[ CINEMATIC_TYPES.AI_SKIT_SPECTRE_SPEEDKILL ] 	<- "DoAISkit"
level.momentServerFunc[ CINEMATIC_TYPES.AI_SKIT_SPECTRE_NECK_SNAP ]		<- "DoAISkit"
level.momentServerFunc[ CINEMATIC_TYPES.AI_SKIT_LOOT_CORPSE ]			<- "DoAISkit"
level.momentServerFunc[ CINEMATIC_TYPES.AI_SKIT_BRAWL ]					<- "DoAISkit"
level.momentServerFunc[ CINEMATIC_TYPES.AI_SKIT_SPECTRE_BLINDFIRE ]		<- "DoAISkit"
level.momentServerFunc[ CINEMATIC_TYPES.AI_SKIT_SPECTRE_CHESTPUNCH ]	<- "DoAISkit"
level.momentServerFunc[ CINEMATIC_TYPES.AI_SKIT_SPECTRE_CURBSTOMP ]		<- "DoAISkit"
level.momentServerFunc[ CINEMATIC_TYPES.AI_SKIT_SPECTRE_RAILING_SMASH ]	<- "DoAISkit"
level.momentServerFunc[ CINEMATIC_TYPES.AI_SKIT_SPECTRE_BAR_FIGHT ]		<- "DoAISkit"
level.momentServerFunc[ CINEMATIC_TYPES.AI_SKIT_SPECTRE_WINDOW_THROW ]	<- "DoAISkit"
level.momentServerFunc[ CINEMATIC_TYPES.AI_SKIT_SPECTRE_CRAWL ]			<- "DoAISkit"
level.momentServerFunc[ CINEMATIC_TYPES.AI_SKIT_SPECTRE_ZOMBIEDRAG ]	<- "DoAISkit"
level.momentServerFunc[ CINEMATIC_TYPES.AI_SKIT_MELEE_FLIP ] 			<- "DoAISkit"
level.momentServerFunc[ CINEMATIC_TYPES.AI_SKIT_SPECTRE_BODYSLAM ] 			<- "DoAISkit"
level.momentServerFunc[ CINEMATIC_TYPES.LEVIATHAN_SPAWN ] 				<- "Leviathan_Spawn"
level.momentServerFunc[ CINEMATIC_TYPES.LEVIATHAN_PATH ] 				<- "Leviathan_Spawn"
level.momentServerFunc[ CINEMATIC_TYPES.SEARCHSHIP_PHANTOM_SPAWN ] 		<- "SearchShip_Phantom_Spawn"
level.momentServerFunc[ CINEMATIC_TYPES.SEARCHSHIP_DRONE_SPAWN ]		<- "SearchShip_Drone_Spawn"

level.momentServerFunc[ CINEMATIC_TYPES.PROP_SKIT_CASUAL_IDLE_A ]		<- "DoPropSkit"
level.momentServerFunc[ CINEMATIC_TYPES.PROP_SKIT_CASUAL_IDLE_B ]		<- "DoPropSkit"
level.momentServerFunc[ CINEMATIC_TYPES.PROP_SKIT_CASUAL_IDLE_CQB ]		<- "DoPropSkit"
level.momentServerFunc[ CINEMATIC_TYPES.PROP_SKIT_PATROL_WALK_BORED ]	<- "DoPropSkit"
level.momentServerFunc[ CINEMATIC_TYPES.PROP_SKIT_PATROL_WALK_HIGHPORT ]<- "DoPropSkit"
level.momentServerFunc[ CINEMATIC_TYPES.PROP_SKIT_PATROL_WALK_LOWPORT ]	<- "DoPropSkit"
level.momentServerFunc[ CINEMATIC_TYPES.PROP_SKIT_RAILING_STAND_SALUTE ]<- "DoPropSkit"
level.momentServerFunc[ CINEMATIC_TYPES.PROP_SKIT_STANDING_TALKERS ]	<- "DoPropSkit"
level.momentServerFunc[ CINEMATIC_TYPES.PROP_SKIT_SEARCH_HOLE ]			<- "DoPropSkitSearchHole"

level.momentServerFunc[ CINEMATIC_TYPES.AIRBASE_GRAVES_CREW_1 ]	<- "IntroIMCGravesCrew_1"
level.momentServerFunc[ CINEMATIC_TYPES.AIRBASE_GRAVES_CREW_2 ]	<- "IntroIMCGravesCrew_2"
level.momentServerFunc[ CINEMATIC_TYPES.AIRBASE_GRAVES_CREW_3 ]	<- "IntroIMCGravesCrew_3"
level.momentServerFunc[ CINEMATIC_TYPES.AIRBASE_GRAVES_CREW_4 ]	<- "IntroIMCGravesCrew_4"
level.momentServerFunc[ CINEMATIC_TYPES.AIRBASE_GRAVES_CREW_5 ]	<- "IntroIMCGravesCrew_5"
level.momentServerFunc[ CINEMATIC_TYPES.AIRBASE_GRAVES_CREW_6 ]	<- "IntroIMCGravesCrew_6"
level.momentServerFunc[ CINEMATIC_TYPES.AIRBASE_GRAVES_HIMSELF ] <- "IntroIMCGravesCrewHimself"


//################################################################

level.cinematicNodes <- []  //Child nodes aren't stored in here
level.cinematicNodesByType <- {} //Child nodes do get stored here
level.cinematicUniqueIndexCount <- 0
level.allCinematicNodesByIndex <- {}
level.allCinematicNodesByUniqueID <- {}

const SIGNAL_STOP_RANDOM_CINEMATIC_EVENTS = "signal_stop_random_cinematic_events"
RegisterSignal( SIGNAL_STOP_RANDOM_CINEMATIC_EVENTS )

FlagInit( "AutoCinematicsEnabled", true )

function main()
{
	Globalize( CreateCinematicMPNode )
	Globalize( VerifyCinematicMPNodes )
	Globalize( GetNodeTypeString )
	Globalize( GetAllNodes )
	Globalize( GetNodeByUniqueID )
	Globalize( GetNodeByIndex )
	Globalize( ClientCallback_NodeDoMoment )
	Globalize( NodeDoMoment )
	Globalize( StartCinematicNodeEditor )

	for( local i = 0 ; i < CINEMATIC_TYPES.TOTAL_COUNT ; i++ )
		level.cinematicNodesByType[i] <- []

	if ( IsServer() )
	{
		if ( GetDeveloperLevel() > 0 )
			AddClientCommandCallback( "DoCinematicMPMoment", ClientCallback_NodeDoMoment )

		thread NodeMomentsThink()
	}
}

function CreateCinematicMPNode( name, pos, ang, type, parentNodeName = null, testNode = false )
{
	if ( !( type in level.childNodes ) )
		Assert( type in level.momentClientFunc || type in level.momentServerFunc )

	// Clamp angles
	ang.x = AngleNormalize( ang.x )
	ang.y = AngleNormalize( ang.y )
	ang.z = AngleNormalize( ang.z )

	local node = {}
	node.selected <- false
	node.highlighted <- false
	node.parentNode <- null
	node.childNodes <- []
	node.pos <- pos
	node.ang <- ang
	node.type <- type

	node.index <- level.cinematicUniqueIndexCount
	level.cinematicUniqueIndexCount++

	node.uniqueID <- name
	node.testNode <- testNode

	// pre-calculate forward, right, up
	node.forward <- node.ang.AnglesToForward()
	node.right <- node.ang.AnglesToRight()
	node.up <- node.ang.AnglesToUp()

	level.cinematicNodesByType[ node.type ].append( node )
	level.allCinematicNodesByIndex[ node.index ] <- node
	level.allCinematicNodesByUniqueID[ node.uniqueID ] <- node

	if ( parentNodeName != null )
	{
		local parentNode = GetNodeByUniqueID( parentNodeName )
		Assert( parentNode != null )
		node.parentNode = parentNode
		parentNode.childNodes.append( node )
		return node
	}

	level.cinematicNodes.append( node )
	return node
}

function VerifyCinematicMPNodes()
{
	foreach( node in level.cinematicNodes )
	{
		// These nodes shouldn't be a child
		if ( !( type in level.childNodes ) )
			Assert( node.parentNode == null )

		switch( node.type )
		{
			case CINEMATIC_TYPES.FLYOVER_STRAIGHT:
			case CINEMATIC_TYPES.O2_END_SACRIFICE:
				// This moment requires the node to have exactly one child node
				Assert( node.childNodes.len() == 1 )
				break

			case CINEMATIC_TYPES.FLYOVER_STRAIGHT_MULTI:
				// This moment requires the node has children, and all children have exactly one child node
				Assert( node.childNodes.len() > 0 )
				foreach( childNode in node.childNodes )
					Assert( childNode.childNodes.len() == 1 )
				break

			case CINEMATIC_TYPES.DROPSHIP_DROPOFF_NOAI:
			case CINEMATIC_TYPES.DROPSHIP_TOUCH_AND_GO:
			case CINEMATIC_TYPES.DROPSHIP_TAKEOFF:
			case CINEMATIC_TYPES.DROPSHIP_DROPOFF_AI_SIDE:
			case CINEMATIC_TYPES.AI_SKIT_DYING_WALLSLIDE:
			case CINEMATIC_TYPES.AI_SKIT_FIGHT_KNOCKBACK:
			case CINEMATIC_TYPES.AI_SKIT_WOUNDED_DRAG:
			case CINEMATIC_TYPES.AI_SKIT_WOUNDED_CARRY:
			case CINEMATIC_TYPES.AI_SKIT_PRISONER_KILL:
			case CINEMATIC_TYPES.AI_SKIT_SHOTGUN_WALLSLAM:
			case CINEMATIC_TYPES.AI_SKIT_SPECTRE_SPEEDKILL:
			case CINEMATIC_TYPES.AI_SKIT_SPECTRE_NECK_SNAP:
			case CINEMATIC_TYPES.AI_SKIT_LOOT_CORPSE:
			case CINEMATIC_TYPES.AI_SKIT_BRAWL:
			case CINEMATIC_TYPES.AI_SKIT_SPECTRE_BLINDFIRE:
			case CINEMATIC_TYPES.AI_SKIT_SPECTRE_CHESTPUNCH:
			case CINEMATIC_TYPES.AI_SKIT_SPECTRE_CURBSTOMP:
			case CINEMATIC_TYPES.AI_SKIT_SPECTRE_RAILING_SMASH:
			case CINEMATIC_TYPES.AI_SKIT_SPECTRE_BAR_FIGHT:
			case CINEMATIC_TYPES.AI_SKIT_SPECTRE_WINDOW_THROW:
			case CINEMATIC_TYPES.AI_SKIT_SPECTRE_CRAWL:
			case CINEMATIC_TYPES.AI_SKIT_SPECTRE_ZOMBIEDRAG:
			case CINEMATIC_TYPES.AI_SKIT_MELEE_FLIP:
			case CINEMATIC_TYPES.AI_SKIT_SPECTRE_BODYSLAM:
			case CINEMATIC_TYPES.FRACTURE_DOGFIGHT:
			case CINEMATIC_TYPES.FRACTURE_SKYBOX_STATIC_REFUEL:
			case CINEMATIC_TYPES.PROP_SKIT_CASUAL_IDLE_A:
			case CINEMATIC_TYPES.PROP_SKIT_CASUAL_IDLE_B:
			case CINEMATIC_TYPES.PROP_SKIT_CASUAL_IDLE_CQB:
			case CINEMATIC_TYPES.PROP_SKIT_PATROL_WALK_BORED:
			case CINEMATIC_TYPES.PROP_SKIT_PATROL_WALK_HIGHPORT:
			case CINEMATIC_TYPES.PROP_SKIT_PATROL_WALK_LOWPORT:
			case CINEMATIC_TYPES.PROP_SKIT_RAILING_STAND_SALUTE:
			case CINEMATIC_TYPES.PROP_SKIT_STANDING_TALKERS:
			case CINEMATIC_TYPES.PROP_SKIT_SEARCH_HOLE:
			case CINEMATIC_TYPES.DOGFIGHT_OVER_WATER_STRAIGHT:
			case CINEMATIC_TYPES.DOGFIGHT_OVER_WATER_LEFT:
			case CINEMATIC_TYPES.DOGFIGHT_OVER_WATER_RIGHT:
				// This moment requires exactly one parent node with no children
				Assert( node.childNodes.len() == 0 )
				break

			case CINEMATIC_TYPES.CHILD:
				// Make sure this child node has a parent
				Assert( node.parentNode != null )
				break

			case CINEMATIC_TYPES.FRACTURE_SKYBOX_AA_TRACER:
				Assert( node.childNodes.len() == 0 )
				PrecacheParticleSystem( "P_tracers_loop_SBox" )
				break

			case CINEMATIC_TYPES.LEVIATHAN_SPAWN:
			case CINEMATIC_TYPES.LEVIATHAN_PATH:
			case CINEMATIC_TYPES.LEVIATHAN_ROAR:
			case CINEMATIC_TYPES.LEVIATHAN_WAIT:
			case CINEMATIC_TYPES.LEVIATHAN_REMOVE:
				// Make sure this node has a parent
				Assert( node.childNodes.len() > 0 )
				break

			case CINEMATIC_TYPES.SEARCHSHIP_PHANTOM_SPAWN:
			case CINEMATIC_TYPES.SEARCHSHIP_DRONE_SPAWN:
				// Make sure this node has a parent
				Assert( node.childNodes.len() > 0 )

				// Precache things these types require
				PrecacheParticleSystem( "scan_laser_beam_mdl" )
				PrecacheParticleSystem( "scan_laser_beam_mdl_sm" )
				PrecacheParticleSystem( "P_drone_dam_smoke" )
				PrecacheParticleSystem( "P_drone_exp_md" )
				PrecacheModel( "models/dev/empty_model.mdl" )
				break

			case CINEMATIC_TYPES.AIRBASE_GRAVES_CREW_1:
			case CINEMATIC_TYPES.AIRBASE_GRAVES_CREW_2:
			case CINEMATIC_TYPES.AIRBASE_GRAVES_CREW_3:
			case CINEMATIC_TYPES.AIRBASE_GRAVES_CREW_4:
			case CINEMATIC_TYPES.AIRBASE_GRAVES_CREW_5:
			case CINEMATIC_TYPES.AIRBASE_GRAVES_CREW_6:
			case CINEMATIC_TYPES.AIRBASE_GRAVES_HIMSELF:
			case CINEMATIC_TYPES.O2_END_CONTACT_GRAVES:
			case CINEMATIC_TYPES.O2_END_BAD_IDEA:
			case CINEMATIC_TYPES.O2_END_CAMFEED:
			case CINEMATIC_TYPES.O2_END_AMBUSH:
			case CINEMATIC_TYPES.O2_END_DEATH:
			case CINEMATIC_TYPES.OUTPOST_TECH_DEFEND1:
			case CINEMATIC_TYPES.OUTPOST_TECH_DEFEND2:
			case CINEMATIC_TYPES.OUTPOST_TECH_ATTACK1:
			case CINEMATIC_TYPES.OUTPOST_TECH_ATTACK2:
			case CINEMATIC_TYPES.OUTPOST_TECH_ATTACK3:
				//do nothing
				break

			default:
				Assert( 0 )
				break
		}
	}
}

function StartCinematicNodeEditor()
{
	level.UsingCinematicNodeEditor = true
	Signal( level, SIGNAL_STOP_RANDOM_CINEMATIC_EVENTS )
	Riff_ForceTitanAvailability( eTitanAvailability.Never )

	if ( IsServer() )
	{
		disable_npcs()
		local allNPCs = GetNPCArray()
		foreach( guy in allNPCs )
		{
			if ( IsAlive( guy ) )
				guy.Kill()
		}
		TakeAllWeapons( GetPlayerArray()[0] )

		// Re-Init all skit nodes to see diag
		local allSkitNodes = GetAllSkitNodes()
		foreach( node in allSkitNodes )
		{
			//if ( "lastCollisionCheckResult" in node && node.lastCollisionCheckResult == false )
			CheckForSkitInCollision( node.skitRef )
		}
		DeleteCollisionTestGuys()

		// Turn on skit anim debug lines
		local players = GetPlayerArray()
		foreach( player in players )
		{
			ClientCommand( player, "ai_debug_test_anim_path 1" )
			ClientCommand( player, "mp_enabletimelimit 0" )
			ClientCommand( player, "fatal_script_errors 0" )
		}
	}

	if ( IsClient() )
		StartCinematicNodeEditor_Client()
	else
		Remote.CallFunction_Replay( GetPlayerArray()[0], "ServerCallback_StartCinematicNodeEditor" )
}

function GetAllNodes()
{
	local allNodes = []
	foreach( node in level.cinematicNodes )
		AddNodeAndChildrenToArray( node, allNodes )

	return allNodes
}

function GetNodeByUniqueID( id )
{
	if ( !( id in level.allCinematicNodesByUniqueID ) )
		return null

	return level.allCinematicNodesByUniqueID[ id ]
}

function GetNodeByIndex( index )
{
	if ( !( index in level.allCinematicNodesByIndex ) )
		return null

	return level.allCinematicNodesByIndex[ index ]
}

function AddNodeAndChildrenToArray( node, array )
{
	array.append( node )
	foreach( childNode in node.childNodes )
		thread AddNodeAndChildrenToArray( childNode, array )
}

function GetNodeTypeString( node )
{
	local table = getconsttable().CINEMATIC_TYPES
	foreach( key, val in table )
	{
		if ( val == node.type )
			return key.tostring()
	}
	return null
}

function ClientCallback_NodeDoMoment( player, nodeIndex )
{
	nodeIndex = nodeIndex.tointeger()
	Assert( nodeIndex >= 0 )
	local node = GetNodeByIndex( nodeIndex )
	Assert( node != null )
	NodeDoMoment( node )
	return true
}

function NodeDoMoment( node )
{
	Assert( IsServer() )
	Assert( node != null )
	Assert( node.type )

	if ( node.type in level.momentServerFunc )
	{
		thread DoServerSideCinematicMPMoment( node )
	}

	if ( node.type in level.momentClientFunc )
	{
		local players = GetPlayerArray()
		foreach( player in players )
			Remote.CallFunction_Replay( player, "ServerCallback_DoClientSideCinematicMPMoment", node.index )
	}
}

function NodeMomentsThink()
{
	EndSignal( level, SIGNAL_STOP_RANDOM_CINEMATIC_EVENTS )

	wait 0 // Give other scripts chance to initiate and run their main() functions

	// Don't do moments on levels that have no nodes
	local hasAutoTriggeredNodes = false
	foreach( node in level.cinematicNodes )
	{
		if ( node.type in level.autoTriggeredCinematicTypes )
		{
			hasAutoTriggeredNodes = true
			break
		}
	}
	if ( !hasAutoTriggeredNodes )
		return

	wait 15

	// Random wait time at start of match ( less often )
	local frequencyMinStart = 10.0
	local frequencyMaxStart = 20.0

	// Random wait time at end of match ( more often )
	local frequencyMinEnd = 3.0
	local frequencyMaxEnd = 9.0

	local waitMin
	local waitMax
	local randomizedNodes

	while ( GetGameState() <= eGameState.SuddenDeath )
	{
		// Get all nodes in the level that should be auto triggered
		randomizedNodes = []
		foreach( node in level.cinematicNodes )
		{
			if ( node.type in level.autoTriggeredCinematicTypes )
				randomizedNodes.append( node )
		}

		// Randomize the order they will trigger
		ArrayRandomize( randomizedNodes )

		// Trigger them off with random spacing
		foreach( node in randomizedNodes )
		{
			// Figure out wait time between zingers based on match progress. More frequent towards end of match
			waitMin = GraphCapped( level.nv.matchProgress, 1, 100, frequencyMinStart, frequencyMinEnd )
			waitMax = GraphCapped( level.nv.matchProgress, 1, 100, frequencyMaxStart, frequencyMaxEnd )

			if ( !Flag( "AutoCinematicsEnabled" ) )
				FlagWait( "AutoCinematicsEnabled" )

			NodeDoMoment( node )


			wait RandomFloat( waitMin, waitMax )
		}
	}
}