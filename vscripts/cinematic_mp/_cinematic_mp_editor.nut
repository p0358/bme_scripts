const DEBUG_DRAW_ID = 0

nodeColorNormal <- { r = 50 , g = 200, b = 255, a = 255 }
nodeColorSelected <- { r = 255 , g = 0, b = 0, a = 255 }
nodeColorSelectedBorder <- { r = 255 , g = 255, b = 0, a = 200 }
nodeColorHighlight <- { r = 255 , g = 0, b = 0, a = 200 }
nodeConnectionNormal <- { r = 100 , g = 100, b = 150, a = 200 }
nodeConnectionSelected <- { r = 255 , g = 0, b = 0, a = 255 }
nodeMinsNormal <- Vector( -50, -50, -50 )
nodeMaxsNormal <- Vector( 50, 50, 50 )
nodeMinsSelected <- Vector( -51, -51, -51 )
nodeMaxsSelected <- Vector( 51, 51, 51 )
nodeMinsSelectedBorder <- Vector( -52, -52, -52 )
nodeMaxsSelectedBorder <- Vector( 52, 52, 52 )
nodeMinsHighlight <- Vector( -51, -51, -51 )
nodeMaxsHighlight <- Vector( 51, 51, 51 )

const SKYBOX_MODE_ENABLED = false
const SKYBOX_SCALER = 0.3

const NODE_SENSATIVITY_DIST_MIN = 100
const NODE_SENSATIVITY_DIST_MAX = 2000
const NODE_MOVE_SPEED_MIN = 10
const NODE_MOVE_SPEED_MAX = 1000
const NODE_ROTATE_SPEED = 80
const NODE_HIGHLIGHT_DISTANCE = 8000
const SIGNAL_STOP_MOVING_NODE = "signal_stop_moving_node"
const SIGNAL_STOP_EDITOR_THINK = "signal_stop_editor_think"
RegisterSignal( SIGNAL_STOP_MOVING_NODE )
RegisterSignal( SIGNAL_STOP_EDITOR_THINK )

function main()
{
	if ( IsClient() )
	{
		Globalize( StartCinematicNodeEditor_Client )
		Globalize( StopCinematicNodeEditor_Client )
		Globalize( ServerCallback_StartCinematicNodeEditor )

		Globalize( ButtonCallback_SelectHighlightedNode )
		Globalize( ButtonCallback_MoveNodeToView )
		Globalize( ButtonCallback_StopMoveNode )
		Globalize( ButtonCallback_MoveNodeForward )
		Globalize( ButtonCallback_MoveNodeBack )
		Globalize( ButtonCallback_MoveNodeRight )
		Globalize( ButtonCallback_MoveNodeLeft )
		Globalize( ButtonCallback_MoveNodeUp )
		Globalize( ButtonCallback_MoveNodeDown )
		Globalize( ButtonCallback_RotateNodeClockwise )
		Globalize( ButtonCallback_RotateNodeCounterClockwise )
		Globalize( ButtonCallback_DoSelectedNodeMoment )

		// Stuff to type in console
		Globalize( ExportNodes )
		Globalize( ChangeSkitType )
		Globalize( AddNewNode )
		Globalize( AddNewNode_FromCycleIdx )
		Globalize( DeleteSelectedNode )

		cycleSkitIdx <- 0
	}

	if ( IsServer() )
	{
		Globalize( ClientCallback_UpdateNodePosition )
		Globalize( ClientCallback_CreateNewNode )
		Globalize( ClientCallback_DeleteNode )

		if ( GetDeveloperLevel() > 0 )
		{
			AddClientCommandCallback( "UpdateNodePosition", ClientCallback_UpdateNodePosition )
			AddClientCommandCallback( "CreateNewNode", ClientCallback_CreateNewNode )
			AddClientCommandCallback( "DeleteNode", ClientCallback_DeleteNode )
		}
	}
}

function ServerCallback_StartCinematicNodeEditor()
{
	StartCinematicNodeEditor_Client()
}

function StartCinematicNodeEditor_Client()
{
	Assert( IsClient() )

	// Select ( X )
	RegisterButtonPressedCallback( BUTTON_X, ButtonCallback_SelectHighlightedNode )

	// Move Node To View ( Y )
	RegisterButtonPressedCallback( BUTTON_Y, ButtonCallback_MoveNodeToView )

	// Move ( DPAD )
	RegisterButtonPressedCallback( BUTTON_DPAD_UP, ButtonCallback_MoveNodeForward )
	RegisterButtonReleasedCallback( BUTTON_DPAD_UP, ButtonCallback_StopMoveNode )
	RegisterButtonPressedCallback( BUTTON_DPAD_DOWN, ButtonCallback_MoveNodeBack )
	RegisterButtonReleasedCallback( BUTTON_DPAD_DOWN, ButtonCallback_StopMoveNode )
	RegisterButtonPressedCallback( BUTTON_DPAD_RIGHT, ButtonCallback_MoveNodeRight )
	RegisterButtonReleasedCallback( BUTTON_DPAD_RIGHT, ButtonCallback_StopMoveNode )
	RegisterButtonPressedCallback( BUTTON_DPAD_LEFT, ButtonCallback_MoveNodeLeft )
	RegisterButtonReleasedCallback( BUTTON_DPAD_LEFT, ButtonCallback_StopMoveNode )
	RegisterButtonPressedCallback( BUTTON_SHOULDER_LEFT, ButtonCallback_RotateNodeCounterClockwise )
	RegisterButtonReleasedCallback( BUTTON_SHOULDER_LEFT, ButtonCallback_StopMoveNode )
	RegisterButtonPressedCallback( BUTTON_SHOULDER_RIGHT, ButtonCallback_RotateNodeClockwise )
	RegisterButtonReleasedCallback( BUTTON_SHOULDER_RIGHT, ButtonCallback_StopMoveNode )
	RegisterButtonPressedCallback( BUTTON_TRIGGER_RIGHT, ButtonCallback_MoveNodeUp )
	RegisterButtonReleasedCallback( BUTTON_TRIGGER_RIGHT, ButtonCallback_StopMoveNode )
	RegisterButtonPressedCallback( BUTTON_TRIGGER_LEFT, ButtonCallback_MoveNodeDown )
	RegisterButtonReleasedCallback( BUTTON_TRIGGER_LEFT, ButtonCallback_StopMoveNode )
	RegisterButtonPressedCallback( BUTTON_STICK_LEFT, ButtonCallback_DoSelectedNodeMoment )

	level.highlightedNode <- null
	level.selectedNode <- null
	level.fullscreenMinimapEnabled = false

	thread EditorThink()
}

function StopCinematicNodeEditor_Client()
{
	Assert( IsClient() )

	// Select ( X )
	DeregisterButtonPressedCallback( BUTTON_X, ButtonCallback_SelectHighlightedNode )

	// Move Node To View ( Y )
	DeregisterButtonPressedCallback( BUTTON_Y, ButtonCallback_MoveNodeToView )

	// Move ( DPAD )
	DeregisterButtonPressedCallback( BUTTON_DPAD_UP, ButtonCallback_MoveNodeForward )
	DeregisterButtonReleasedCallback( BUTTON_DPAD_UP, ButtonCallback_StopMoveNode )
	DeregisterButtonPressedCallback( BUTTON_DPAD_DOWN, ButtonCallback_MoveNodeBack )
	DeregisterButtonReleasedCallback( BUTTON_DPAD_DOWN, ButtonCallback_StopMoveNode )
	DeregisterButtonPressedCallback( BUTTON_DPAD_RIGHT, ButtonCallback_MoveNodeRight )
	DeregisterButtonReleasedCallback( BUTTON_DPAD_RIGHT, ButtonCallback_StopMoveNode )
	DeregisterButtonPressedCallback( BUTTON_DPAD_LEFT, ButtonCallback_MoveNodeLeft )
	DeregisterButtonReleasedCallback( BUTTON_DPAD_LEFT, ButtonCallback_StopMoveNode )
	DeregisterButtonPressedCallback( BUTTON_SHOULDER_LEFT, ButtonCallback_RotateNodeCounterClockwise )
	DeregisterButtonReleasedCallback( BUTTON_SHOULDER_LEFT, ButtonCallback_StopMoveNode )
	DeregisterButtonPressedCallback( BUTTON_SHOULDER_RIGHT, ButtonCallback_RotateNodeClockwise )
	DeregisterButtonReleasedCallback( BUTTON_SHOULDER_RIGHT, ButtonCallback_StopMoveNode )
	DeregisterButtonPressedCallback( BUTTON_TRIGGER_RIGHT, ButtonCallback_MoveNodeUp )
	DeregisterButtonReleasedCallback( BUTTON_TRIGGER_RIGHT, ButtonCallback_StopMoveNode )
	DeregisterButtonPressedCallback( BUTTON_TRIGGER_LEFT, ButtonCallback_MoveNodeDown )
	DeregisterButtonReleasedCallback( BUTTON_TRIGGER_LEFT, ButtonCallback_StopMoveNode )
	DeregisterButtonPressedCallback( BUTTON_STICK_LEFT, ButtonCallback_DoSelectedNodeMoment )

	level.highlightedNode <- null
	level.selectedNode <- null

	Signal( level, SIGNAL_STOP_EDITOR_THINK )
}

function EditorThink()
{
	local loopTime = 0.1
	local drawTime = 0.15
	local allNodes

	EndSignal( level, SIGNAL_STOP_EDITOR_THINK )

	for(;;)
	{
		allNodes = GetAllNodes()

		// Update node selection/highlight
		UpdateHighlightedNode( allNodes )

		// Draw all the nodes
		DrawNodes( allNodes, drawTime )

		wait loopTime
	}
}

function DrawNodes( nodes, drawTime )
{
	foreach( node in nodes )
		DrawSingleNode( node, drawTime )
}

function DrawSingleNode( node, drawTime )
{
	local nodeSizeScaler = GraphCapped( Distance( node.pos, GetLocalViewPlayer().CameraPosition() ), NODE_SENSATIVITY_DIST_MIN, NODE_SENSATIVITY_DIST_MAX, 0.02, 0.2 )
	if ( SKYBOX_MODE_ENABLED )
		nodeSizeScaler *= SKYBOX_SCALER

	// Selected
	if ( node.selected )
		DebugDrawBox( node.pos, nodeMinsSelected * nodeSizeScaler, nodeMaxsSelected * nodeSizeScaler, nodeColorSelected.r, nodeColorSelected.g, nodeColorSelected.b, nodeColorSelected.a, drawTime )

	// Normal
	DebugDrawBox( node.pos, nodeMinsNormal * nodeSizeScaler, nodeMaxsNormal * nodeSizeScaler, nodeColorNormal.r, nodeColorNormal.g, nodeColorNormal.b, nodeColorNormal.a, drawTime )

	// Highlight Border
	if ( node.highlighted )
		DebugDrawBox( node.pos, nodeMinsHighlight * nodeSizeScaler, nodeMaxsHighlight * nodeSizeScaler, nodeColorHighlight.r, nodeColorHighlight.g, nodeColorHighlight.b, nodeColorHighlight.a, drawTime )

	// Selected Border and Angles
	if ( node.selected )
	{
		DebugDrawBox( node.pos, nodeMinsSelectedBorder * nodeSizeScaler, nodeMaxsSelectedBorder * nodeSizeScaler, nodeColorSelectedBorder.r, nodeColorSelectedBorder.g, nodeColorSelectedBorder.b, nodeColorSelectedBorder.a, drawTime )
		DebugDrawLine( node.pos, node.pos + node.ang.AnglesToForward() * 1000 * nodeSizeScaler, nodeColorSelectedBorder.r, nodeColorSelectedBorder.g, nodeColorSelectedBorder.b, true, drawTime )
	}

	// Node Text
	DebugDrawText( node.pos, GetNodeTypeString( node ), true, 0.1 )
	if ( DEBUG_DRAW_ID )
		DebugDrawText( node.pos + Vector( 0, 0, 10 ), node.uniqueID, true, 0.1 )

	// Parenting Lines
	if ( node.parentNode )
	{
		if ( node.selected || node.parentNode.selected )
			DebugDrawLine( node.pos, node.parentNode.pos, nodeConnectionSelected.r, nodeConnectionSelected.g, nodeConnectionSelected.b, true, drawTime )
		else
			DebugDrawLine( node.pos, node.parentNode.pos, nodeConnectionNormal.r, nodeConnectionNormal.g, nodeConnectionNormal.b, true, drawTime )

	}
}

function UpdateHighlightedNode( nodes )
{
	local maxSearchDistSq = NODE_HIGHLIGHT_DISTANCE * NODE_HIGHLIGHT_DISTANCE
	local eyePos = GetFreecamPos()
	local viewVec = GetFreecamAngles().AnglesToForward()
	local dist
	local vecToNode
	local dot

	local highlightedNode = null
	local highlightedNodeDist

	// Clear current highlight
	foreach( node in nodes )
		node.highlighted = false

	// Make new highlight
	foreach( node in nodes )
	{
		// Check distance
		dist = DistanceSqr( eyePos, node.pos )
		if ( dist > maxSearchDistSq )
			continue

		// Check dot
		vecToNode = ( node.pos - eyePos )
		vecToNode.Norm()
		dot = vecToNode.Dot( viewVec )
		if ( dot < 0.994 )
			continue

		// Pick closest one
		if ( !highlightedNode || dist < highlightedNodeDist )
		{
			highlightedNode = node
			highlightedNodeDist = dist
		}
	}

	// Highlight the node we are looking at
	if ( highlightedNode )
		highlightedNode.highlighted = true
	level.highlightedNode = highlightedNode
}

function ButtonCallback_SelectHighlightedNode( player )
{
	Signal( player, SIGNAL_STOP_MOVING_NODE )
	SelectNode( level.highlightedNode )
	if ( IsValid( level.highlightedNode ) )
		printt( "Selected " + level.highlightedNode.uniqueID )
}

function SelectNode( node )
{
	level.selectedNode = node
	local allNodes = GetAllNodes()
	foreach( n in allNodes )
		n.selected = ( n == level.selectedNode )
}

function ButtonCallback_MoveNodeToView( player )
{
	if ( level.selectedNode == null )
		return

	local pos = player.CameraPosition() + ( player.GetViewVector() * 100 )
	if ( SKYBOX_MODE_ENABLED )
		pos = player.CameraPosition() + ( player.GetViewVector() * 100 * SKYBOX_SCALER )

	level.selectedNode.pos = pos
	if ( "skitRef" in level.selectedNode )
		level.selectedNode.skitRef.SetOrigin( pos )
	ButtonCallback_StopMoveNode( player )
}

function ButtonCallback_MoveNodeForward( player )
{
	thread MoveSelectedNodeInDirection( player, Vector( 0, GetLocalViewPlayer().CameraAngles().y, 0 ).AnglesToForward() )
}

function ButtonCallback_MoveNodeBack( player )
{
	thread MoveSelectedNodeInDirection( player, Vector( 0, GetLocalViewPlayer().CameraAngles().y, 0 ).AnglesToForward() * -1 )
}

function ButtonCallback_MoveNodeRight( player )
{
	thread MoveSelectedNodeInDirection( player, Vector( 0, GetLocalViewPlayer().CameraAngles().y, 0 ).AnglesToRight() )
}

function ButtonCallback_MoveNodeLeft( player )
{
	thread MoveSelectedNodeInDirection( player, Vector( 0, GetLocalViewPlayer().CameraAngles().y, 0 ).AnglesToRight() * -1 )
}

function ButtonCallback_MoveNodeUp( player )
{
	thread MoveSelectedNodeInDirection( player, Vector( 0, 0, 1 ) )
}

function ButtonCallback_MoveNodeDown( player )
{
	thread MoveSelectedNodeInDirection( player, Vector( 0, 0, -1 ) )
}

function ButtonCallback_RotateNodeClockwise( player )
{
	thread MoveSelectedNodeInDirection( player, null, -1 )
}

function ButtonCallback_RotateNodeCounterClockwise( player )
{
	thread MoveSelectedNodeInDirection( player, null, 1 )
}

function ButtonCallback_StopMoveNode( player )
{
	Signal( player, SIGNAL_STOP_MOVING_NODE )
	if ( level.selectedNode )
		UpdatePositionOfNodeOnServer( level.selectedNode )
}

function UpdatePositionOfNodeOnServer( node )
{
	Assert( IsClient() )

	local commandString = "UpdateNodePosition"
		commandString += " " + level.selectedNode.uniqueID
		commandString += " " + level.selectedNode.pos.x
		commandString += " " + level.selectedNode.pos.y
		commandString += " " + level.selectedNode.pos.z
		commandString += " " + level.selectedNode.ang.x
		commandString += " " + level.selectedNode.ang.y
		commandString += " " + level.selectedNode.ang.z

	//printt( "commandString:", commandString )

	GetLocalViewPlayer().ClientCommand( commandString )
}

function MoveSelectedNodeInDirection( player, direction = null, rotation = null )
{
	Assert( direction != null || rotation != null )

	Signal( player, SIGNAL_STOP_MOVING_NODE )
	EndSignal( player, SIGNAL_STOP_MOVING_NODE )

	if ( !level.selectedNode )
		return

	local nodeMoveSpeed = GraphCapped( Distance( level.selectedNode.pos, player.CameraPosition() ), NODE_SENSATIVITY_DIST_MIN, NODE_SENSATIVITY_DIST_MAX, NODE_MOVE_SPEED_MIN, NODE_MOVE_SPEED_MAX )
	if ( SKYBOX_MODE_ENABLED )
		nodeMoveSpeed *= SKYBOX_SCALER

	while( level.selectedNode != null )
	{
		if ( direction != null )
			level.selectedNode.pos += direction * nodeMoveSpeed * IntervalPerTick()
		if ( rotation != null )
			level.selectedNode.ang += Vector( 0, rotation * NODE_ROTATE_SPEED * IntervalPerTick(), 0 )
		wait IntervalPerTick()
	}
}

function ClampAngle( ang )
{
	while( ang >= 360 )
		ang -= 360

	while( ang <= -360 )
		ang += 360

	Assert( ang >= -360 && ang <= 360 )

	return ang
}

function ClientCallback_UpdateNodePosition( player, uniqueID, posX, posY, posZ, angX, angY, angZ )
{
	Assert( IsServer() )

	//printt( "ClientCallback_UpdateNodePosition", uniqueID, posX, posY, posZ, angX, angY, angZ )

	local node = GetNodeByUniqueID( uniqueID )
	Assert( node )

	local newPos = Vector( posX.tofloat(), posY.tofloat(), posZ.tofloat() )
	//DebugDrawLine( player.GetOrigin(), newPos, 0, 255, 0, true, 30 )
	node.pos = newPos

	angX = ClampAngle( angX.tofloat() )
	angY = ClampAngle( angY.tofloat() )
	angZ = ClampAngle( angZ.tofloat() )

	local newAng = Vector( angX, angY, angZ )
	node.ang = newAng

	if ( "skitRef" in node )
	{
		node.skitRef.SetAngles( newAng )
		node.skitRef.SetOrigin( newPos )
		DropSkitNodeRefToGround( node.skitRef )
	}
}

function ButtonCallback_DoSelectedNodeMoment( player )
{
	if ( !level.selectedNode )
		return

	if ( level.selectedNode.type )
		GetLocalViewPlayer().ClientCommand( "DoCinematicMPMoment " + level.selectedNode.index )
}

function AddNewNode( type = CINEMATIC_TYPES.CHILD )
{
	Assert( IsClient() )

	if ( type == CINEMATIC_TYPES.CHILD && level.selectedNode == null )
	{
		printt( "Must have node selected to create a child node" )
		return
	}

	if ( !( type in level.childNodes ) )
		SelectNode( null )

	local pos = GetLocalViewPlayer().CameraPosition() + ( GetLocalViewPlayer().GetViewVector() * 100 )
	if ( SKYBOX_MODE_ENABLED )
		pos = GetLocalViewPlayer().CameraPosition() + ( GetLocalViewPlayer().GetViewVector() * ( 100 * SKYBOX_SCALER ) )

	local ang = Vector( 0, 0, 0 )
	local newNode

	// Create a new node as a parent where we are looking
	local parentNodeName = null
	if ( level.selectedNode != null )
		parentNodeName = level.selectedNode.uniqueID
	local newNodeName = UniqueString("cinematic_mp_node")
	while( GetNodeByUniqueID( newNodeName ) != null )
		newNodeName = UniqueString("cinematic_mp_node")
	printt( "CREATING NODE WITH NAME:", newNodeName )
	newNode = CreateCinematicMPNode( newNodeName, pos, ang, type, parentNodeName )

	// Tell the server about the new node
	local commandString = "CreateNewNode"
		commandString += " " + newNode.uniqueID
		commandString += " " + newNode.pos.x
		commandString += " " + newNode.pos.y
		commandString += " " + newNode.pos.z
		commandString += " " + newNode.ang.x
		commandString += " " + newNode.ang.y
		commandString += " " + newNode.ang.z
		commandString += " " + newNode.type
		if ( newNode.parentNode != null )
			commandString += " " + newNode.parentNode.uniqueID
		else
			commandString += " null" // We will have to handle null being a string in ClientCallback_CreateNewNode

	GetLocalViewPlayer().ClientCommand( commandString )

	// Select the new node
	level.highlightedNode = null
	SelectNode( newNode )
	UpdatePositionOfNodeOnServer( newNode )
}

function AddNewNode_FromCycleIdx()
{
	AddNewNode( level.skitTypes[ cycleSkitIdx ] )
}

function DeleteSelectedNode( uniqueID = null )
{
	local node
	local parentNode

	if ( IsClient() )
	{
		Assert( uniqueID == null )

		if ( level.selectedNode == null )
		{
			printt( "NO NODE SELECTED TO DELETE" )
			return
		}
		node = level.selectedNode
	}

	if ( IsServer() )
	{
		Assert( uniqueID != null )
		node = GetNodeByUniqueID( uniqueID )
	}

	Assert( node != null )

	// Remove node
	ArrayRemove( level.cinematicNodesByType[ node.type ], node )
	ArrayRemove( level.cinematicNodes, node )
	if ( node.parentNode )
	{
		// remove node from it's parents childNode array
		parentNode = node.parentNode
		ArrayRemove( node.parentNode.childNodes, node )

		// add any children of the deleted node to it's parents childNode array
		foreach( childNode in node.childNodes )
		{
			childNode.parentNode = parentNode
			node.parentNode.childNodes.append( childNode )
		}
	}
	if ( IsClient() )
	{
		// Tell the server to delete the node also
		local commandString = "DeleteNode"
			commandString += " " + node.uniqueID
		GetLocalViewPlayer().ClientCommand( commandString )

		// Clear selection
		SelectNode( parentNode )
	}
}

function ClientCallback_DeleteNode( player, nodeName )
{
	DeleteSelectedNode( nodeName )
}

function ClientCallback_CreateNewNode( player, nodeName, posX, posY, posZ, angX, angY, angZ, type, parentName )
{
	if ( parentName == "null" )
		parentName = null

	CreateCinematicMPNode( nodeName, Vector( posX.tofloat(), posY.tofloat(), posZ.tofloat() ), Vector( angX.tofloat(), angY.tofloat(), angZ.tofloat() ), type.tointeger(), parentName )
}

function ExportNodes()
{
	Assert( IsClient() )

	local allNodes = GetAllNodes()

	// Write function open
	DevTextBufferClear()
	DevTextBufferWrite( "function main()\n{\n" )

	// Export the parent nodes first
	foreach( node in allNodes )
	{
		if ( node.parentNode != null )
			continue
		ExportNode(node)
	}

	// Export the child nodes
	foreach( node in allNodes )
	{
		if ( node.parentNode == null )
			continue
		ExportNode(node)
	}

	// Write function close
	DevTextBufferWrite( "}\n" )

	// Write to the file
	local result = DevTextBufferDumpToFile( "scripts/vscripts/cinematic_mp/level_data/" + GetMapName() + ".nut" )
	printt( "########################################" )
	if ( result == true )
		printt( "############# NODES SAVED! #############" )
	else
		printt( "NODES FAILED TO SAVE! MAKE SURE " + "scripts/vscripts/cinematic_mp/level_data/" + GetMapName() + ".nut" + " IS OPEN FOR EDIT IN PERFORCE!" )
	printt( "########################################" )
}

function ExportNode(node)
{
	node.ang.x = AngleNormalize( node.ang.x )
	node.ang.y = AngleNormalize( node.ang.y )
	node.ang.z = AngleNormalize( node.ang.z )

	local printString = "\tCreateCinematicMPNode( \"" + node.uniqueID + "\", Vector( " + node.pos.x + ", " + node.pos.y + ", " + node.pos.z + " ), Vector( " + node.ang.x + ", " + node.ang.y + ", " + node.ang.z + " ), CINEMATIC_TYPES." + GetNodeTypeName(node.type)
	if ( node.parentNode != null )
		printString += ", \"" + node.parentNode.uniqueID + "\""
	printString += " )\n"
	DevTextBufferWrite( printString )
}

function GetNodeTypeName( type )
{
	local table = getconsttable().CINEMATIC_TYPES
	foreach( key, val in table )
	{
		if ( val == type )
			return key
	}
	return -1
}

function ChangeSkitType()
{
	cycleSkitIdx++
	if ( cycleSkitIdx > ( level.skitTypes.len() - 1 ) )
		cycleSkitIdx = 0

	printt( "CURRENT SKIT:", GetNodeTypeName( level.skitTypes[ cycleSkitIdx ] ) )
}