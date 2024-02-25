
function main()
{
	IncludeFile( "client/cl_carrier" ) //Included for skyshow dogfights
	SetFullscreenMinimapParameters( 4.2, -3000, 3250, 180 )
	if ( GAMETYPE == COOPERATIVE )
		SetCustomMinimapZoom( 2.5 )
}

function EntitiesDidLoad()
{
}

