/*
C_Titan_Cockpit.__SetFOV <- C_Titan_Cockpit.SetFOV
function C_Titan_Cockpit::SetFOV( fov )
{
	if ( fov != 75 )
		printt( "Set fov to " + fov )
	this.__SetFOV( fov )
}

*/

function C_Titan_Cockpit::GetMainVGUI()
{
	if ( !( "mainVGUI" in this.s ) )
		return null

	if ( !IsValid( this.s.mainVGUI ) )
		return null
				
	return this.s.mainVGUI
}
RegisterClassFunctionDesc( C_Titan_Cockpit, "GetMainVGUI", "Returns the mainVGUI" )
