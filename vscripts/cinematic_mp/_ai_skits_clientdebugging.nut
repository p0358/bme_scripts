
RegisterSignal( "StopDrawingAISkitSphere" )

function main()
{
	Globalize( ServerCallback_AISkitDebugMessage )
}

function ServerCallback_AISkitDebugMessage( nodeIndex, state )
{	
	nodeIndex = nodeIndex.tointeger()
	state = state.tointeger()
	
	Assert( nodeIndex >= 0 && nodeIndex < level.cinematicNodes.len() )
	local node = level.cinematicNodes[ nodeIndex ]
	
	if ( state == 1 )
		thread DrawSphereOnNode( node )
	else
		Signal( node, "StopDrawingAISkitSphere" )
}

function DrawSphereOnNode( node )
{
	Signal( node, "StopDrawingAISkitSphere" )
	EndSignal( node, "StopDrawingAISkitSphere" )
	while(1)
	{
		DebugDrawSphere( node.pos, 128, 255, 255, 255, 0.22 )
		wait 0.2
	}
}