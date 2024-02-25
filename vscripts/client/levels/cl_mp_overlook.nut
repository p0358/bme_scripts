EMERGENCY_LIGHT_FX <- PrecacheParticleSystem( "warning_light_orange_blink" )
//level.warningLightFXSpots 	<- []
//level.warningLightHandles 	<- []

emergencyLights <- []

function main()
{
	IncludeFile( "client/cl_carrier" ) //Included for skyshow dogfights
	RegisterServerVarChangeCallback( "emergencyLightsState", EmergencyLightsStateChange )
	SetFullscreenMinimapParameters( 2.85, 550, -1200, 180 )
	if ( GAMETYPE == COOPERATIVE )
		SetCustomMinimapZoom( 2 )
}

function EntitiesDidLoad()
{
	//emergencyLights = GetEntArrayByClassAndTargetname( "info_target", "prison_warning_light_fx" )
	//Assert( emergencyLights.len() )
}

function EmergencyLightsStateChange()
{
	if ( level.nv.emergencyLightsState == 1 )
	{
		foreach( light in emergencyLights )
			delaythread( RandomFloat( 0, 0.1 ) ) EmergencyLightEffectOn( light )
	}
}

function EmergencyLightEffectOn( light )
{
	local handle = StartParticleEffectInWorldWithHandle( EMERGENCY_LIGHT_FX, light.GetOrigin(), light.GetAngles() )
}