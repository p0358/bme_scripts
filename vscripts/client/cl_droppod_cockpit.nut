function DroppodFireteam_CockpitScreenUpdate( cockpit, cockpitScreenProxy )
{
	for ( local y = 0; y != COCKPIT_PANEL_SIDE; ++y )
	{
		for ( local x = 0; x != COCKPIT_PANEL_SIDE; ++x )
		{			
			cockpitScreenProxy.SetInfo( x, y, 0, 0, 0.5, 0.5 )
		}
	}
	
	cockpit.SetFOV( 70 )

	return 0
}

function DroppodFireteam_CockpitAnimUpdate( cockpit, isFinished )
{
	return 0
}
