// function FlyPath
CAI_TrackPather.__FlyPath <- CAI_TrackPather.FlyPath
function CAI_TrackPather::FlyPath( handle )
{
	//DebugPrint( this + " FlyPath " + handle )
	this.EngineEffectsEnable()
	VehicleFlyingPath( this, handle, true )
	
	this.__FlyPath( handle )

	this.Signal( "OnFly" )
}

// function FlyToNodeViaPath
CAI_TrackPather.__FlyToNodeViaPath <- CAI_TrackPather.FlyToNodeViaPath
function CAI_TrackPather::FlyToNodeViaPath( handle )
{
//	if ( this.GetName() == "heli3" )
	//DebugPrint( this + " FlyToNodeViaPath " + handle )
//
	this.EngineEffectsEnable()
	this.__FlyToNodeViaPath( handle )

	this.Signal( "OnFly" )
}

// function FlyToPoint
CAI_TrackPather.__FlyToPoint <- CAI_TrackPather.FlyToPoint
function CAI_TrackPather::FlyToPoint( handle )
{
//	DebugPrint( this + " FlyToPoint " + handle )
	this.EngineEffectsEnable()
	this.__FlyToPoint( handle )

	this.Signal( "OnFly" )
}

// function FlyToNodeUseNodeSpeed
CAI_TrackPather.__FlyToNodeUseNodeSpeed <- CAI_TrackPather.FlyToNodeUseNodeSpeed
function CAI_TrackPather::FlyToNodeUseNodeSpeed( handle )
{
//	DebugPrint( this + " FlyToNodeUseNodeSpeed " + handle )
	this.EngineEffectsEnable()
	this.__FlyToNodeUseNodeSpeed( handle )

	this.Signal( "OnFly" )
}

// function FlyPathBackward
CAI_TrackPather.__FlyPathBackward <- CAI_TrackPather.FlyPathBackward
function CAI_TrackPather::FlyPathBackward( handle )
{
//	DebugPrint( this + " FlyPathBackward " + handle )
	this.EngineEffectsEnable()
	VehicleFlyingPath( this, handle, false )
	
	this.__FlyPathBackward( handle )

	this.Signal( "OnFly" )
}

// function FlyToPointToAnim
CAI_TrackPather.__FlyToPointToAnim <- CAI_TrackPather.FlyToPointToAnim
function CAI_TrackPather::FlyToPointToAnim( handle, anim )
{
//	DebugPrint( this + " FlyToPointToAnim " + handle )
	this.EngineEffectsEnable()
	this.__FlyToPointToAnim( handle, anim )

	this.Signal( "OnFly" )
}
