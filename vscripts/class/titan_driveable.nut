Titan_Driveable.supportsXRay <- null

function Titan_Driveable::HasXRaySupport()
{
	return ( this.supportsXRay != null )
}

function Titan_Driveable::EnableXRay( teamNumber, playerIndex )
{
	Assert( this.HasXRaySupport() )
	this.scope().EnableXRayRenderMode( teamNumber, playerIndex )
}

function Titan_Driveable::DisableXRay( teamNumber, playerIndex )
{
	Assert( this.HasXRaySupport() )
	this.scope().DisableXRayRenderMode( teamNumber, playerIndex )
}

