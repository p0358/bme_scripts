
function main()
{
	IncludeFile( "client/cl_carrier" )

	SetFullscreenMinimapParameters( 4.8, -1000, -2000, 180 )
	if ( GAMETYPE == COOPERATIVE )
		SetCustomMinimapZoom( 2 )
}

function EntitiesDidLoad()
{

}