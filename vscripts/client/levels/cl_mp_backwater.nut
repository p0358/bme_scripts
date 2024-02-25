
function main()
{
	IncludeFile( "client/cl_carrier" )

	IncludeFileAllowMultipleLoads( "client/objects/cl_ai_turret" )
	SetFullscreenMinimapParameters( 2.8, 1750, -2000, -180 )
	if ( GAMETYPE == COOPERATIVE )
		SetCustomMinimapZoom( 2 )
}

function EntitiesDidLoad()
{

}