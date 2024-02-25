CHardPointEntity.__SetHardpointID <- CHardPointEntity.SetHardpointID
function CHardPointEntity::SetHardpointID( val )
{
	Assert( !( "storedID" in this.s ), "Already set hardpoint ID on " + this )
	Assert( val >= 0 )
	this.s.storedID <- val
	__SetHardpointID( val )
}

function CHardPointEntity::EnableHardpoint()
{
	Assert( "storedID" in this.s, this + " hardpoint has not run SetHardpointID()" )
	__SetHardpointID( this.s.storedID )

	this.Minimap_AlwaysShow( TEAM_IMC, null )
	this.Minimap_AlwaysShow( TEAM_MILITIA, null )
}
RegisterClassFunctionDesc( CHardPointEntity, "EnableHardpoint", "Enable this hardpoint" )

function CHardPointEntity::DisableHardpoint()
{
	Assert( "storedID" in this.s, this + " hardpoint has not run SetHardpointID()" )
	__SetHardpointID( -1 )

	this.Minimap_Hide( TEAM_IMC, null )
	this.Minimap_Hide( TEAM_MILITIA, null )
}
RegisterClassFunctionDesc( CHardPointEntity, "EnableHardpoint", "Enable this hardpoint" )

function CHardPointEntity::Enabled()
{
	return this.GetHardpointID() >= 0
}
RegisterClassFunctionDesc( CHardPointEntity, "Enabled", "Returns true if this hardpoint is enabled" )

