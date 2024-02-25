
function main()
{
	//Removing Skyshow from Nexus since we're ovebudget
	//IncludeFile( "client/cl_carrier" ) //Included for skyshow dogfights
	IncludeFileAllowMultipleLoads( "client/objects/cl_ai_turret" )
	SetFullscreenMinimapParameters( 4.2, -500, 1100, 180 )
	if ( GAMETYPE == COOPERATIVE )
		SetCustomMinimapZoom( 2.2 )
}

function EntitiesDidLoad()
{
}

