
function main()
{
	IncludeFile( "client/cl_carrier" ) //Included for skyshow dogfights
	IncludeFileAllowMultipleLoads( "client/objects/cl_ai_turret" )
	SetFullscreenMinimapParameters( 3.9, -1000, -2000, 180 )
	if ( GAMETYPE == COOPERATIVE )
		SetCustomMinimapZoom( 2.5 )
}

function EntitiesDidLoad()
{
}

