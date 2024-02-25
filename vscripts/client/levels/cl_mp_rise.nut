
function main()
{
	IncludeFile( "client/cl_carrier" ) //Included for skyshow dogfights
	SetFullscreenMinimapParameters( 3.05, -1450, 1300, 180 )
	if ( GAMETYPE == COOPERATIVE )
		SetCustomMinimapZoom( 2 )
}

function EntitiesDidLoad()
{
}

