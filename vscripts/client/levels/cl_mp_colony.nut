//const FX_DLIGHT_SPECTRE_PALETTE = "P_fire_rooftop"
const FX_DLIGHT_SPECTRE_PALETTE = "DLight_spectre_palette"
const FX_FIRE_FIELDS = "P_fire_grass"
const FX_FIRE_VENT_SMALL = "P_fire_small_FULL"
const FX_FIRE_VENT_LARGE = "P_fire_med_FULL"
const FX_FIRE_ROOF_SMALL = "fire_med_smoke"
//const FX_RAIN_COCKPIT = "P_dropship_rain"
const FX_RAIN_COCKPIT = "P_dropship_rain_CP"
const FX_LIGHTING_INTRO = "P_env_lightning_intro"


PrecacheParticleSystem( FX_DLIGHT_SPECTRE_PALETTE )
PrecacheParticleSystem( FX_FIRE_FIELDS )
PrecacheParticleSystem( FX_FIRE_VENT_SMALL )
PrecacheParticleSystem( FX_FIRE_VENT_LARGE )
PrecacheParticleSystem( FX_FIRE_ROOF_SMALL )
PrecacheParticleSystem( FX_RAIN_COCKPIT )
PrecacheParticleSystem( FX_LIGHTING_INTRO )

const SFX_SPECTRE_PALETTE_LIGHTS_ACTIVATE = "spectre_palette_lights_activate"
const SFX_FIRE_FIELDS = "amb_colony_fire_large"
const SFX_FIRE_VENT_SMALL = "amb_colony_fire_small"
const SFX_FIRE_VENT_LARGE = "amb_colony_fire_medium"
const SFX_FIRE_ROOF_SMALL = "amb_colony_fire_small"
const SFX_THUNDER = "Colony_DistantThunder_IntroBeat1"

function main()
{
	FlagInit( "IntroRideStart" )
	FlagInit( "IntroRideOver" )

	IncludeFileAllowMultipleLoads( "client/objects/cl_phantom_fighter" )

	RegisterServerVarChangeCallback( "ClientTiming", ClientTimingFlags )
	Globalize( ServerCallback_CreateSpectrePaletteLighting )
	Globalize( CE_VisualSettingColonyIMC )
	Globalize( CE_VisualSettingColonyMCOR )

	if( GetCinematicMode() )
		IntroScreen_Setup()

	SetFullscreenMinimapParameters( 2.7, -1600, 1500, -180 )
	if ( GAMETYPE == COOPERATIVE )
		SetCustomMinimapZoom( 2 )
}

function IntroScreen_Setup()
{
	local delay_line1 = 0.5
	local delay_line2 = 1
	local delay_line3 = 0

	CinematicIntroScreen_SetTextSpacingTimes( TEAM_IMC,  delay_line1, delay_line2, delay_line3 )
	CinematicIntroScreen_SetTextSpacingTimes( TEAM_MILITIA,  delay_line1, delay_line2, delay_line3 )
	CinematicIntroScreen_SetText( TEAM_IMC, 	[ "#INTRO_SCREEN_COLONY_LINE1", "#INTRO_SCREEN_COLONY_LINE2_IMC", "#INTRO_SCREEN_COLONY_LINE3_IMC" ] )
	CinematicIntroScreen_SetText( TEAM_MILITIA, 	[ "#INTRO_SCREEN_COLONY_LINE1", "#INTRO_SCREEN_COLONY_LINE2_MCOR", "#INTRO_SCREEN_COLONY_LINE3_MCOR" ] )
}
/////////////////////////////////////////////////////////////////////////////////////////////
function EntitiesDidLoad()
{
	//EmitSoundAtPosition( Vector( 0, 0, 0 ), "amb_colony_EXT_global" )	//temp till compile works to get audio ents in

	local fxAftermathEnts = GetClientEntArray( "info_target_clientside", "fx_" )
	Assert( fxAftermathEnts.len() > 0, "COLONY: No fx entities found for village aftermath" )
	foreach( fxEnt in fxAftermathEnts )
		FxMassacreAftermath( fxEnt )

	thread IntroExperience()

//	if ( GetLocalClientPlayer().GetCinematicEventRef() != null )
//		printt( "Player in dropship" )

}

/////////////////////////////////////////////////////////////////////////////////////////////
function ClientTimingFlags()
{
	if ( level.nv.ClientTiming > 0 )
		FlagSet( "IntroRideStart" )

	if ( level.nv.ClientTiming < 0 )
		FlagSet( "IntroRideOver" )
}
/////////////////////////////////////////////////////////////////////////////////////////////
function ServerCallback_CreateSpectrePaletteLighting( eHandle, flyby = true, sound = true )
{
	local palette = GetEntityFromEncodedEHandle( eHandle )
	if ( !IsValid( palette ) )
		return
	local lights = []
	local lightTags = []
	local index

	local effectIndex = GetParticleSystemIndex( FX_DLIGHT_SPECTRE_PALETTE )

	if ( flyby )
	{
		lightTags.append( "spectre_4_light" )
		lightTags.append( "spectre_5_light" )
		lightTags.append( "spectre_6_light" )
	}
	else
	{
		lightTags.append( "spectre_1_light" )
		lightTags.append( "spectre_2_light" )
		lightTags.append( "spectre_3_light" )
	}

	if ( sound )
		EmitSoundOnEntity( palette, SFX_SPECTRE_PALETTE_LIGHTS_ACTIVATE )

	foreach( tag in lightTags )
	{
		index = palette.LookupAttachment( tag )
		lights.append( StartParticleEffectOnEntity( palette, effectIndex, FX_PATTACH_POINT_FOLLOW, index ) )
	}

	thread SpectrePaletteLightingCleanup( lights, flyby )
}
/////////////////////////////////////////////////////////////////////////////////////////////
function SpectrePaletteLightingCleanup( lights, flyby )
{
	if ( flyby )
		wait 20
	else
		wait 35

	foreach ( light in lights )
	{
		if ( EffectDoesExist( light ) )
			EffectStop( light, true, false )
	}
}
/////////////////////////////////////////////////////////////////////////////////////////////
function IntroExperience()
{
	if ( Flag( "IntroRideOver" ) )
		return

	FlagWait( "IntroRideStart" )

	local player = GetLocalViewPlayer()
	local team = player.GetTeam()
	local dropship = player.GetParent()
	if ( ( !dropship ) || ( dropship.GetClassname() != "npc_dropship" ) )
	{
		FlagSet( "IntroRideOver" )
		return
	}

	//-----------------------------------------
	// Team-specific client stuff goes here
	//-----------------------------------------
	switch ( team )
	{
		case TEAM_IMC:
			break
		case TEAM_MILITIA:
			break
	}

	//-----------------------------------------
	// See how far out of sync we are with server
	//-----------------------------------------
	local deltaTime = Time() - level.nv.ClientTiming
	printt( "Time = ", Time() )
	printt( "level.nv.ClientTiming = ", level.nv.ClientTiming )
	printt( "deltaTime = ", deltaTime )


	//-------------
	// Start rain
	//-------------
	thread IntroRain( dropship, deltaTime )

}

///////////////////////////////////////////////////////////////////////////////////////
function IntroRain( dropship, deltaTime )
{
	local rainBaseTime = 25
	local rainAdjustedTime = rainBaseTime - deltaTime

	printt( "rainAdjustedTime = ", rainAdjustedTime )

	if ( rainAdjustedTime < 1 )
		return

	//-----------------------------------------
	// Rain FX over dropship door
	//-----------------------------------------
	local fxID = StartParticleEffectOnEntity( dropship, GetParticleSystemIndex( FX_RAIN_COCKPIT ), FX_PATTACH_POINT_FOLLOW, dropship.LookupAttachment( "RopeAttachRightA" ) )
	//local fxID = StartParticleEffectOnEntity( dropship, GetParticleSystemIndex( FX_RAIN_COCKPIT ), FX_PATTACH_POINT_FOLLOW, dropship.LookupAttachment( "RopeAttachLeftA" ) )
	EffectSetControlPointVector( fxID, 1, Vector( 1, 0, 0 ) )


	wait rainAdjustedTime / 2

	StartParticleEffectInWorld( GetParticleSystemIndex( FX_LIGHTING_INTRO ), Vector( -11776 -11776 -6016 ), Vector( 0, 0, 0 ) )
	EmitSoundAtPosition( Vector( 0, 0, 0 ), SFX_THUNDER )

	wait rainAdjustedTime / 2

	//-----------------------------------------
	// Start to fade out rain as dropoff nears
	//-----------------------------------------
	local timeToFade = 10
	local startTime = Time()
	local endTime = startTime + timeToFade
	local fadeFraction = ( 1 / ( timeToFade / 0.05 ) )
	local fadeValue = 1
	while ( Time() <= endTime && EffectDoesExist( fxID ) )
	{
		fadeValue = fadeValue - fadeFraction
		//printt( "fadeValue = ", fadeValue )
		if ( fadeValue < 0 )
			break
		EffectSetControlPointVector( fxID, 1, Vector( fadeValue, 0, 0 ) )
		wait 0.05
	}

	//-----------------------------------------
	// End
	//-----------------------------------------
	if ( EffectDoesExist( fxID ) )
		EffectStop( fxID, false, true )

}

///////////////////////////////////////////////////////////////////////////////////////
function FxMassacreAftermath( fxEnt )
{
	//-----------------------------------------
	// Fx entities for burning aftermath
	//-----------------------------------------
	local fxName = fxEnt.GetName()
	local fx
	local sfx
	local pos = fxEnt.GetOrigin()
	local ang = fxEnt.GetAngles()

	if ( fxName.find( "fx_fireFields" ) != null )
	{
		fx = FX_FIRE_FIELDS
		sfx = SFX_FIRE_FIELDS
	}
	else if ( fxName.find( "fx_fireVentSmall" ) != null )
	{
		fx = FX_FIRE_VENT_SMALL
		sfx = SFX_FIRE_VENT_SMALL
	}
	else if ( fxName.find( "fx_fireVentLarge" ) != null )
	{
		fx = FX_FIRE_VENT_LARGE
		sfx = SFX_FIRE_VENT_LARGE
	}
	else if ( fxName.find( "fx_fireRoofSmall" ) != null )
	{
		fx = FX_FIRE_ROOF_SMALL
		sfx = SFX_FIRE_ROOF_SMALL
	}

	local fxHandle = StartParticleEffectInWorldWithHandle( GetParticleSystemIndex( fx ), pos, ang )
	EffectSetDontKillForReplay( fxHandle )
	//Don't play sound in script, use ambient_generics in LevelEd instead
	//EmitSoundAtPosition( pos, sfx )
}

function CE_VisualSettingColonyIMC( player, ref )
{
	CE_ResetVisualSettings( player )

	ref.LerpSkyScale( SKYSCALE_COLONY_IMC_SHIP, 0.01 )
}

function CE_VisualSettingColonyMCOR( player, ref )
{
	CE_ResetVisualSettings( player )

	ref.LerpSkyScale( SKYSCALE_COLONY_MCOR_SHIP, 0.01 )
}

