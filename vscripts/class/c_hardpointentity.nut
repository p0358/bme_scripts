function C_HardPointEntity::Enabled()
{
	return this.GetHardpointID() >= 0
}
RegisterClassFunctionDesc( C_HardPointEntity, "Enabled", "Returns true if this hardpoint is enabled" )

