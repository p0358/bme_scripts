const FX_DLIGHT_RED 	= "veh_interior_Dlight_red"
const FX_DLIGHT_COCKPIT = "veh_interior_Dlight_cockpit_offset"
const FX_DLIGHT_BLUE 	= "interior_Dlight_blue_MED"
const FX_DLIGHT_COCKPIT_IMC = "veh_interior_Dlight_cockpit_offset_IMC"

const FX_CLOUDCOVER = "P_veh_gunship_cloudcover"

function main()
{
	Globalize( ServerCallback_CreateDropShipIntLighting )
	Globalize( ServerCallback_DropShipCloudCoverEffect )
	Globalize( CreateCallback_Dropship )
	Globalize( JetwakeFXChanged )

	PrecacheParticleSystem( FX_DLIGHT_RED )
	PrecacheParticleSystem( FX_DLIGHT_BLUE )
	PrecacheParticleSystem( FX_DLIGHT_COCKPIT )
	PrecacheParticleSystem( FX_DLIGHT_COCKPIT_IMC )

	PrecacheParticleSystem( FX_CLOUDCOVER )
}

function JetwakeFXChanged( dropship )
{
	if ( dropship.IsJetWakeFXEnabled() )
		dropship.SetGroundEffectTable( "dropship_dust" )
	else
		dropship.SetGroundEffectTable( "" )
}

function ServerCallback_DropShipCloudCoverEffect( eHandle )
{
	local dropship = GetEntityFromEncodedEHandle( eHandle )
	if ( !IsValid( dropship ) )
		return
	local index 		= dropship.LookupAttachment( "ORIGIN" )
	local effectIndex 	= GetParticleSystemIndex( FX_CLOUDCOVER )

	StartParticleEffectOnEntity( dropship, effectIndex, FX_PATTACH_POINT_FOLLOW, index )
}

function ServerCallback_CreateDropShipIntLighting( eHandle, team )
{
	local dropship = GetEntityFromEncodedEHandle( eHandle )
	if ( !IsValid( dropship ) )
		return
	local lights = {}
	local rampLightFX, cockpitLightFX

	switch( team )
	{
		case TEAM_MILITIA:
			rampLightFX = FX_DLIGHT_RED
			cockpitLightFX = FX_DLIGHT_COCKPIT
			break

		default:
			rampLightFX = FX_DLIGHT_BLUE
			cockpitLightFX = FX_DLIGHT_COCKPIT_IMC
			break
	}

	//ramp light L
	local index 	= dropship.LookupAttachment( "IntLightRampL" )
	local effectIndex 	= GetParticleSystemIndex( rampLightFX )
	lights.rampDLightL <- StartParticleEffectOnEntity( dropship, effectIndex, FX_PATTACH_POINT_FOLLOW, index )

	//cockpit light 1
	local index 	= dropship.LookupAttachment( "IntLightCockpit1" )
	local effectIndex 	= GetParticleSystemIndex( cockpitLightFX )
	lights.cockpitDLight <- StartParticleEffectOnEntity( dropship, effectIndex, FX_PATTACH_POINT_FOLLOW, index )

	thread IntLightingCleanup( lights )
}

function IntLightingCleanup( lights )
{
	local player = GetLocalViewPlayer()

	player.WaitSignal( "PlayerCinematicDone" )

	foreach ( index, light in lights )
	{
		if ( EffectDoesExist( light ) )
			EffectStop( light, true, false )
	}
}


/////////////////////////////////////////////
function CreateCallback_Dropship( entity, isRecreate )
{
	if ( isRecreate )
		return

	entity.SetGroundEffectTable( "dropship_dust" )
}
