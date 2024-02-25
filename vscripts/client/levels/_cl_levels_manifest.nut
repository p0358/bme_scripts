function main()
{
	local mapScriptName = "client/levels/cl_" + GetMapName()
	
	if ( !ScriptExists( mapScriptName ) )
		return

	IncludeFile( mapScriptName )
}