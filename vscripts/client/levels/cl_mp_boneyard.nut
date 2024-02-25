const FX_EXP_GENERIC		= "P_exp_blowout_md"
const FX_FIRE_GENERIC		= "P_fire_loop_MD"

const FX_EXP_WIN_LOW		= "P_exp_blowout_md"
const FX_FIRE_WIN_LOW		= "P_fire_loop_sm"

const FX_EXP_HATCH			= "P_exp_blowout_md"
const FX_FIRE_HATCH			= "P_fire_loop_MD"

const FX_EXP_LARGE_WIDE			= "P_exp_blowout_md"
const FX_FIRE_LARGE_WIDE			= "P_fire_loop_LG_wide_1"

const FX_EXP_LARGE			= "P_exp_blowout_md"
const FX_FIRE_LARGE			= "P_fire_loop_LG_1"

const FX_EXP_HUGE			= "P_exp_dw_building_med"
const FX_FIRE_HUGE			= "P_fire_loop_XL" //"env_smoke_plume_LG"

const SFX_EXP_LARGE			= "corporate_building_explosion"
const SFX_EXP_SMALL			= "corporate_building_explosion"
const SFX_FIRE_LOOP_LARGE	= "amb_o2_fire_large"
const SFX_FIRE_LOOP_SMALL	= "amb_o2_fire_medium"
const SFX_FIRE_LOOP_MEDIUM	= "amb_o2_fire_small"

const FX_FIRE_LEAK_MD		= "P_fire_jet_med_nomdl"

const FX_FIRE_HATCH_ROUND		= "P_fire_hatch_01"

PrecacheParticleSystem( FX_EXP_GENERIC )
PrecacheParticleSystem( FX_FIRE_GENERIC )
PrecacheParticleSystem( FX_EXP_WIN_LOW )
PrecacheParticleSystem( FX_FIRE_WIN_LOW )
PrecacheParticleSystem( FX_EXP_HATCH )
PrecacheParticleSystem( FX_FIRE_HATCH )
PrecacheParticleSystem( FX_EXP_LARGE )
PrecacheParticleSystem( FX_FIRE_LARGE )
PrecacheParticleSystem( FX_EXP_LARGE_WIDE )
PrecacheParticleSystem( FX_FIRE_LARGE_WIDE )
PrecacheParticleSystem( FX_EXP_HUGE )
PrecacheParticleSystem( FX_FIRE_HUGE )
PrecacheParticleSystem( FX_FIRE_LEAK_MD )
PrecacheParticleSystem( FX_FIRE_HATCH_ROUND )

const WARNING_LIGHT_ON_MODEL	= "models/lamps/warning_light_ON_orange.mdl"
const WARNING_LIGHT_OFF_MODEL 	= "models/lamps/warning_light.mdl"

const FX_PIPE_STEAM			= "P_steam_leak_LG"
const FX_FAN_STEAM			= "env_steam_fan_1"
const FX_PIPE_FIRE			= "P_fire_jet_med"
const FX_ELECTRIC_ARC		= "P_elec_arc_loop_1"
const FX_ELECTRIC_ARC_LG	= "P_elec_arc_loop_LG_1"
const FX_ELECTRIC_SPARK		= "P_env_sparks_dir_1"

enum eFxType
{
	FX_ELECTRIC_ARC
	FX_ELECTRIC_ARC_LG
	FX_ELECTRIC_SPARK
	FX_FAN_STEAM
	FX_PIPE_STEAM
	FX_PIPE_FIRE
}

enum eSoundType
{
	SOUND_GENERATOR_SMALL
	SOUND_GENERATOR_MEDIUM
	SOUND_GENERATOR_LARGE
	SOUND_VENT_SMALL
	SOUND_CONSOLE
	SOUND_TECH_PANEL
	SOUND_FAN
	SOUND_PIPE_STEAM
}

function main()
{
	if ( IsServer() )
		return

	IncludeFile( "_flyers_shared" )
	IncludeFileAllowMultipleLoads( "client/objects/cl_ai_turret" )

	Globalize( ServerCallback_TowerExplosion )
	Globalize( ServerCallback_HardpointPowerBurst )
	Globalize( FlyerReactToPulse )
	Globalize( FlyerPulseReaction )

	Globalize( HardpointElectricBurst )
	Globalize( AddFlyers )

	Globalize( CE_VisualSettingBoneyardMCOR )
	Globalize( CE_VisualSettingBoneyardIMC )
	Globalize( CE_BloomOnRampOpenBoneyardMCOR )
	Globalize( CE_BloomOnRampOpenBoneyardIMC )

	Globalize( AddHardpointFx )

	// rough fx placement tool
	Globalize( EditorHardpointID )
	Globalize( EditorAddFx )
	Globalize( EditorPlayLastSet )
	Globalize( EditorPlayHardpoint )
	Globalize( EditorShowSets )
	Globalize( EditorDeleteSet )
	Globalize( EditorSaveHardpointFx )
	RegisterSignal( "EndEditorShow" )
	level.currentHardpointID <- 0
	level.currentSetindex <- 1
	level.lastSetStartTime <- Time()
	level.lastSetAddTime <- Time()
	level.skyboxCamOrigin <- Vector( -3584.0, 12032.0, -12032.0 )

	// Dev Globalize
	Globalize( DevHardpointElectricBurst )

	IncludeFile( "client/levels/cl_mp_boneyard_fx.nut" )

	level.fxID <- {}
	level.fxID[ eFxType.FX_ELECTRIC_ARC ] <- PrecacheParticleSystem( FX_ELECTRIC_ARC )
	level.fxID[ eFxType.FX_ELECTRIC_ARC_LG ] <- PrecacheParticleSystem( FX_ELECTRIC_ARC_LG )
	level.fxID[ eFxType.FX_ELECTRIC_SPARK ] <- PrecacheParticleSystem( FX_ELECTRIC_SPARK )
	level.fxID[ eFxType.FX_FAN_STEAM ] <- PrecacheParticleSystem( FX_FAN_STEAM )
	level.fxID[ eFxType.FX_PIPE_STEAM ] <- PrecacheParticleSystem( FX_PIPE_STEAM )
	level.fxID[ eFxType.FX_PIPE_FIRE ] <- PrecacheParticleSystem( FX_PIPE_FIRE )

	level.fxOffset <- {}
	level.fxOffset[ eFxType.FX_ELECTRIC_ARC ] <- 0
	level.fxOffset[ eFxType.FX_ELECTRIC_ARC_LG ] <- 0
	level.fxOffset[ eFxType.FX_ELECTRIC_SPARK ] <- 0

	level.soundTable <- {}
	level.soundTable[ eSoundType.SOUND_GENERATOR_SMALL ]	<- [ "amb_boneyard_emitter_generator_small" ]
	level.soundTable[ eSoundType.SOUND_GENERATOR_MEDIUM ]	<- [ "amb_boneyard_emitter_generator_medium",
																 "amb_boneyard_emitter_generator_hum",
																 "amb_boneyard_emitter_generator_scifi" ]
	level.soundTable[ eSoundType.SOUND_GENERATOR_LARGE ]	<- [ "amb_boneyard_emitter_generator_huge" ]
	level.soundTable[ eSoundType.SOUND_VENT_SMALL ]			<- [ "amb_boneyard_emitter_industrial_vent",
																 "amb_boneyard_emitter_industrial_vent2",
																 "amb_boneyard_emitter_computerfans" ]
	level.soundTable[ eSoundType.SOUND_CONSOLE ]			<- [ "amb_boneyard_emitter_console" ]
	level.soundTable[ eSoundType.SOUND_TECH_PANEL ]			<- [ "amb_boneyard_emitter_computerfans" ]
	level.soundTable[ eSoundType.SOUND_FAN ]				<- [ "amb_boneyard_emitter_fan_antique",
																 "amb_boneyard_emitter_fan_blade",
																 "amb_boneyard_emitter_fan_scifi" ]
	level.soundTable[ eSoundType.SOUND_PIPE_STEAM ]			<- [ "amb_boneyard_emitter_steam_tiny",
																 "amb_boneyard_emitter_steam_small",
																 "amb_boneyard_emitter_steam_medium",
																 "amb_boneyard_emitter_steam_large" ]

	AddCreateCallback( "dog_whistle", DogWhistleCreated )
	AddCreateCallback( "info_hardpoint", BoneyardHardpointCreated )
	AddCreateCallback( "prop_dynamic", CreateCallback_PropDynamic )

	level.propDynamicCreateCallbacks	<- {	leviathan1 =	LeviathanMiscCreated,
												leviathan2 =	LeviathanMiscCreated,
												leviathan3 =	LeviathanMiscCreated,
												leviathan4 =	LeviathanMiscCreated }

	level.progressFuncArray <- []
	RegisterServerVarChangeCallback( "matchProgress", MatchProgressChanged )
	RegisterServerVarChangeCallback( "pulseImminent", PulseImminent )

	level.FX_WARNING_LIGHT_DLIGHT	<- PrecacheParticleSystem( "warning_light_orange_blink_RT" )
	level.FX_WARNING_LIGHT 			<- PrecacheParticleSystem( "warning_light_orange_blink" )
	level.BLUE_LIGHT				<- PrecacheParticleSystem( "interior_Dlight_blue_MED" )

	level.screenShaking 			<- false
	level.sequenceArray 			<- []
	level.dogWhistle				<- null
	level.dogWhistleOrigin			<- Vector( 0, 0, 0 )
	level.lastPulseCount			<- 0

	level.previousHardpointOwner	<- [ TEAM_UNASSIGNED, TEAM_UNASSIGNED, TEAM_UNASSIGNED ]
	level.hardpointArray			<- [ null, null, null ]
	level.fxPairingDone				<- false
	level.uniqueIndex				<- 0

	RegisterSignal( "HardpointNeutralized" )
	RegisterSignal( "ResetTowerVDU" )

	if( GetCinematicMode() )
		IntroScreen_Setup()
	SetupRumble()

	thread FlyersMain()
	SetFullscreenMinimapParameters( 3.1, -1150, -1400, -180 )
	if ( GAMETYPE == COOPERATIVE )
		SetCustomMinimapZoom( 2 )
}

function EntitiesDidLoad()
{
	// Turn all monitors off
	local monitorArray = GetClientEntArray( "prop_dynamic", "monitor_on" )
	foreach( model in monitorArray )
	{
		model.Hide()
		model.SetFadeDistance( 3000 )	// tiny monitors would fade out too early.
	}

	// prime all clientside sound ents
	PrimeSoundEnts( TEAM_MILITIA, "sound_generator_small",	eSoundType.SOUND_GENERATOR_SMALL )
	PrimeSoundEnts( TEAM_MILITIA, "sound_generator_medium",	eSoundType.SOUND_GENERATOR_MEDIUM )
	PrimeSoundEnts( TEAM_MILITIA, "sound_generator_large",	eSoundType.SOUND_GENERATOR_LARGE )
	PrimeSoundEnts( TEAM_MILITIA, "sound_vent_small",		eSoundType.SOUND_VENT_SMALL )
	PrimeSoundEnts( TEAM_MILITIA, "sound_console",			eSoundType.SOUND_CONSOLE )
	PrimeSoundEnts( TEAM_MILITIA, "sound_tech_panel",		eSoundType.SOUND_TECH_PANEL )

	if ( !GetCinematicMode() )
		return

	Assert( level.dogWhistle )

	// setup tower explosion fx
	level.fxEnts <- GetClientEntArray( "info_target_clientside", "fx_explosion" )
	Assert( level.fxEnts.len() > 0, "BONEAYRD: No fx entities found for end explosion sequence" )
	foreach( ent in level.fxEnts )
		FxEndExplosionSetup( ent )
}

function CreateCallback_PropDynamic( self, isRecreate )
{
	local name = self.GetName()

	if ( name == "" )
		return

	if ( name in level.propDynamicCreateCallbacks )
	{
		local funcToCall = level.propDynamicCreateCallbacks[ name ]
		if ( funcToCall != null )
		{
			thread funcToCall( self )
		}
	}
}

/*--------------------------------------------------------------------------------------------------------*\
|
|											LEVIATHANS
|
\*--------------------------------------------------------------------------------------------------------*/

function LeviathanMiscCreated( ent )
{
	AddAnimEvent( ent, "LeviathanFootstep", LeviathanFootstep )
	AddAnimEvent( ent, "LeviathanReactionSmall", LeviathanReactionSmall )
	AddAnimEvent( ent, "LeviathanReactionBig", LeviathanReactionBig )
	AddAnimEvent( ent, "LeviathanDeathVocal", LeviathanDeathVocal )
	AddAnimEvent( ent, "LeviathanBodyfall", LeviathanBodyfall )
	AddAnimEvent( ent, "LeviathanDeathImpact", LeviathanDeathImpact )
}

function LeviathanFootstep( leviathan )
{
	EmitSkyboxSoundAtPosition( leviathan.GetOrigin(), "Leviathan_Footstep" )
}

function LeviathanDeathVocal( leviathan )
{
	EmitSkyboxSoundAtPosition( leviathan.GetOrigin(), "Leviathan_DeathVocal" )
}

function LeviathanBodyfall( leviathan )
{
	EmitSkyboxSoundAtPosition( leviathan.GetOrigin(), "Leviathan_DeathVocal" )
}

function LeviathanReactionSmall( leviathan )
{
	EmitSkyboxSoundAtPosition( leviathan.GetOrigin(), "Leviathan_Reaction_Small" )
}

function LeviathanReactionBig( leviathan )
{
	EmitSkyboxSoundAtPosition( leviathan.GetOrigin(), "Leviathan_Reaction_Big" )
}

function LeviathanDeathImpact( leviathan )
{
	ClientScreenShake( 0.5, 10.0, 5.0, Vector( 0.0, 0.0, 0.0 ) )
}

/*--------------------------------------------------------------------------------------------------------*\
|
|											MATCH PROGRESS
|
\*--------------------------------------------------------------------------------------------------------*/

function MatchProgressChanged()
{
	thread MatchProgressChangedThread()
}

function MatchProgressChangedThread()
{
	thread ManageFlyerCount()
}

function ManageFlyerCount()
{
	// don't add flyers if the match is over.
	if ( level.nv.matchProgress >= 100  )
	{
		foreach( sequence in level.sequenceArray )
			sequence.ref.Signal( "EndAddToSequence" )
		return
	}

	// don't add flyers if a pulse will happen soon
	if ( level.nv.pulseImminent )
		return

	local progress = level.nv.matchProgress / 100.0
	progress = ( progress * progress + progress ) / 2.0

	foreach( index, sequence in level.sequenceArray )
	{
		local goalCount = ceil( sequence.num * progress )
		// printt( "aiming for", index, goalCount, sequence.num )
		local count = goalCount - sequence.numFlyers
		if ( count > 0 )
			thread AddFlyersToSequence( sequence, count, 3 )	// add one flyer every 3 seconds
	}
}

/*--------------------------------------------------------------------------------------------------------*\
|
|												TOWER EVENTS
|
\*--------------------------------------------------------------------------------------------------------*/

function DogWhistleCreated( entity, isRecreate )
{
	if ( isRecreate )	// does this ever happen anymore?
		return

	level.dogWhistle = entity
	level.dogWhistleOrigin = level.dogWhistle.GetOrigin()

	AddAnimEvent( level.dogWhistle, "tower_pulse_fail", FlyerPulseReaction )
	AddAnimEvent( level.dogWhistle, "tower_pulse_success", FlyerPulseReaction )
}

function ServerCallback_TowerExplosion( delay )
{
	thread TowerExplosionThread( delay )
}

function TowerExplosionThread( delay )
{
	wait delay	// delay until the explosion happens

	// have the flyers fly away
	FlyerPulseReaction()

	if ( !( "fxEnts" in level) )
		return

	// printt( "start client side explosions" )
	foreach ( fxEnt in level.fxEnts )
		thread TriggerFx( fxEnt )

}

//////////////////////////////////////////////////////////////////////////////////////
function TriggerFx( fxEnt )
{
	local fxEntPos = fxEnt.GetOrigin()
	local fxEntAng = fxEnt.GetAngles()

	wait fxEnt.s.delay

	if ( "fxExplode" in fxEnt.s )
	{
		StartParticleEffectInWorld( fxEnt.s.fxExplode, fxEntPos, fxEntAng )
		EmitSoundAtPosition( fxEntPos, fxEnt.s.sfxExplode )
		thread ScreenShake( fxEntPos )
	}

	// this is the effect that lingers on after the blast.
	local fxHandle = StartParticleEffectInWorldWithHandle( fxEnt.s.fxFire, fxEntPos, fxEntAng )
	EffectSetDontKillForReplay( fxHandle )
	EmitSoundAtPosition( fxEntPos, fxEnt.s.sfxFire )
	thread DebugDrawSoundName( fxEnt, fxEnt.s.sfxFire )
}

//////////////////////////////////////////////////////////////////////////////////////
function FxEndExplosionSetup( fxEnt )
{
	//-----------------------------------------
	// Fx entities for end destruct sequence
	//-----------------------------------------
	local fxName = fxEnt.GetName()
	local fxExplode
	local sfxExplode
	local fxFire
	local sfxFire
	local dist = Distance( level.dogWhistleOrigin, fxEnt.GetOrigin() )
	local distPerSec = 1500.0

	fxEnt.s.delay <- dist / distPerSec
	if ( fxName.find( "door_wide" ) != null )
	{
		fxEnt.s.fxExplode <- GetParticleSystemIndex( FX_EXP_GENERIC )
		fxEnt.s.fxFire <- GetParticleSystemIndex( FX_FIRE_GENERIC )
		fxEnt.s.sfxExplode <- SFX_EXP_LARGE
		fxEnt.s.sfxFire <- SFX_FIRE_LOOP_SMALL
	}
	else if ( fxName.find( "spot_fire" ) != null )
	{
		fxEnt.s.fxFire <- GetParticleSystemIndex( FX_FIRE_HATCH_ROUND )
		fxEnt.s.sfxExplode <- SFX_EXP_LARGE
		fxEnt.s.sfxFire <- SFX_FIRE_LOOP_SMALL
	}
	else if ( fxName.find( "fire_leak" ) != null )
	{
		fxEnt.s.fxFire <- GetParticleSystemIndex( FX_FIRE_LEAK_MD )
		fxEnt.s.sfxExplode <- SFX_EXP_LARGE
		fxEnt.s.sfxFire <- SFX_FIRE_LOOP_MEDIUM
	}
	else if ( fxName.find( "window_low" ) != null )
	{
		fxEnt.s.fxExplode <- GetParticleSystemIndex( FX_EXP_WIN_LOW )
		fxEnt.s.fxFire <- GetParticleSystemIndex( FX_FIRE_WIN_LOW )
		fxEnt.s.sfxExplode <- SFX_EXP_LARGE
		fxEnt.s.sfxFire <- SFX_FIRE_LOOP_SMALL
	}
	else if ( fxName.find( "hatch" ) != null )
	{
		fxEnt.s.fxExplode <- GetParticleSystemIndex( FX_EXP_HATCH )
		fxEnt.s.fxFire <- GetParticleSystemIndex( FX_FIRE_HATCH )
		fxEnt.s.sfxExplode <- SFX_EXP_LARGE
		fxEnt.s.sfxFire <- SFX_FIRE_LOOP_MEDIUM
	}
	else if ( fxName.find( "opening_large" ) != null )
	{
		fxEnt.s.fxExplode <- GetParticleSystemIndex( FX_EXP_LARGE )
		fxEnt.s.fxFire <- GetParticleSystemIndex( FX_FIRE_LARGE )
		fxEnt.s.sfxExplode <- SFX_EXP_LARGE
		fxEnt.s.sfxFire <- SFX_FIRE_LOOP_LARGE
	}
	else if ( fxName.find( "door_large" ) != null )
	{
		fxEnt.s.fxExplode <- GetParticleSystemIndex( FX_EXP_LARGE_WIDE )
		fxEnt.s.fxFire <- GetParticleSystemIndex( FX_FIRE_LARGE_WIDE )
		fxEnt.s.sfxExplode <- SFX_EXP_LARGE
		fxEnt.s.sfxFire <- SFX_FIRE_LOOP_LARGE
	}
	else if ( fxName.find( "opening_huge" ) != null )
	{
		fxEnt.s.fxExplode <- GetParticleSystemIndex( FX_EXP_HUGE )
		fxEnt.s.fxFire <- GetParticleSystemIndex( FX_FIRE_HUGE )
		fxEnt.s.sfxExplode <- SFX_EXP_LARGE
		fxEnt.s.sfxFire <- SFX_FIRE_LOOP_LARGE
	}
	else
		Assert( 0, "BONEYARD: No case for fx dummy: " + dummyName )

}

/////////////////////////////////////////////////////////////////////////
// Generic shake, no way to specify position of shake and have falloff
function ScreenShake( pos )
{
	if ( level.screenShaking )
		return
	local player = GetLocalViewPlayer()

	if ( !IsAlive( player ) )
		return

	level.screenShaking = true

	local size = "large"
	local distSq = DistanceSqr( pos, player.GetOrigin() )
	local maxShakeDist = 3000 * 3000
	if ( distSq > maxShakeDist )
		size = "small"

	local amplitude
	local frequency
	local duration
	switch ( size )
	{
		case "small":
			amplitude = RandomFloat( 2, 3 )
			frequency = RandomFloat( 1, 2 )
			duration = RandomFloat( 0.25, 0.5 )
			break
		case "large":
			amplitude = RandomFloat( 5, 8 )
			frequency = RandomFloat( 3, 6 )
			duration = RandomFloat( 0.5, 1 )
			break
		default:
			Assert( 0, "Corporate: no ScreenShake size: " + size )
	}

	ClientScreenShake( amplitude, frequency, duration, RandomVec( 1 ) )

	wait duration + 1
	level.screenShaking = false
}

//////////////////////////////////////////////////////////////////////////////////////
function SetupRumble()
{
	local left = [  Vector( 4.2, 1.0 ), Vector( 4.7, 0.0 ) ]
	local right = [ Vector( 0.0, 0.0 ), Vector( 4.2, 0.25 ), Vector( 6.3, 0.0 ) ]
	local leftTrigger = []
	local rightTrigger = []

	Rumble_CreateGraph( "TowerGraphFail", left, right, leftTrigger, rightTrigger )
	Rumble_CreatePlayParams( "TowerRumbleFail", { name = "TowerGraphFail" } )

	local left = [  Vector( 4.2, 1.0 ), Vector( 5.2, 0.15 ), Vector( 8.0, 0.0 ) ]
	local right = [ Vector( 0.0, 0.0 ), Vector( 4.2, 0.30 ), Vector( 9.0, 0.0 ) ]
	leftTrigger = []
	rightTrigger = []

	Rumble_CreateGraph( "TowerGraphSuccess", left, right, leftTrigger, rightTrigger )
	Rumble_CreatePlayParams( "TowerRumbleSuccess", { name = "TowerGraphSuccess" } )
}

/*--------------------------------------------------------------------------------------------------------*\
|
|													CAPTUREPOINT
|
\*--------------------------------------------------------------------------------------------------------*/

function BoneyardHardpointCreated( entity, isRecreate )
{
	if ( isRecreate )	// does this ever happen
		return

	if ( GameRules.GetGameMode() != CAPTURE_POINT )
		return

	thread BoneyardHardpointSetup( entity )
}

function BoneyardHardpointSetup( hardpoint )
{
	FlagWait( "ClientInitComplete" )

	local hardpointID = hardpoint.GetHardpointID()
	level.hardpointArray[ hardpointID ] = hardpoint

	local hardpointIDString = [ "a", "b", "c" ]
	local idString = hardpointIDString[ hardpointID ]

	// warning lights
	local warningLightModelArray = GetClientEntArray( "prop_dynamic", "warning_light" )
	hardpoint.s.warningLightModelArray <- ArrayWithin( warningLightModelArray, hardpoint.GetOrigin(), 1500 )

	// monitors
	local monitorModelArray = GetClientEntArray( "prop_dynamic", "monitor_on" )
	hardpoint.s.monitorModelArray <- ArrayWithin( monitorModelArray, hardpoint.GetOrigin(), 1500 )
	hardpoint.s.monitorOn <- false

	// fans
	hardpoint.s.fanArray <- GetClientEntArray( "prop_dynamic", "hardpoint_" + idString + "_fan" )

	//  stand alone fx
	local steamFXArray 	= GetClientEntArray( "info_target_clientside", "hardpoint_steam_fx" )
	local fireFXArray 	= GetClientEntArray( "info_target_clientside", "hardpoint_fire_fx" )
	hardpoint.s.steamFXArray <- ArrayWithin( steamFXArray, hardpoint.GetOrigin(), 1500 )
	hardpoint.s.fireFXArray <- ArrayWithin( fireFXArray, hardpoint.GetOrigin(), 1500 )

	// sound ents
	hardpoint.s.soundEntArray <- []
	PairSoundWithHardpoint( hardpoint, "sound_generator_small" )
	PairSoundWithHardpoint( hardpoint, "sound_generator_medium" )
	PairSoundWithHardpoint( hardpoint, "sound_generator_large" )
	PairSoundWithHardpoint( hardpoint, "sound_vent_small" )
	PairSoundWithHardpoint( hardpoint, "sound_console" )
	PairSoundWithHardpoint( hardpoint, "sound_tech_panel" )

	// fx pairing
	if ( !level.fxPairingDone )
	{
		// lights
		local lightFxArray = GetClientEntArray( "info_target_clientside", "warning_light_fx" )
		PairFxWithEntity( warningLightModelArray, lightFxArray, level.FX_WARNING_LIGHT, 32 )
		local dLightFxArray = GetClientEntArray( "info_target_clientside", "warning_light_dlight_fx" )
		PairFxWithEntity( warningLightModelArray, dLightFxArray, level.FX_WARNING_LIGHT_DLIGHT, 32 )

		// fans
		local fanFXArray  = GetClientEntArray( "info_target_clientside", "hardpoint_fan_fx" )
		local fanEntArray = GetClientEntArray( "prop_dynamic", "hardpoint_a_fan" )
		fanEntArray.extend( GetClientEntArray( "prop_dynamic", "hardpoint_b_fan" ) )
		fanEntArray.extend( GetClientEntArray( "prop_dynamic", "hardpoint_c_fan" ) )
		PairFxWithEntity( fanEntArray, fanFXArray, level.fxID[ eFxType.FX_FAN_STEAM ], 32, eSoundType.SOUND_FAN )

		PrimeClientsideFxEnts( steamFXArray, eFxType.FX_PIPE_STEAM, eSoundType.SOUND_PIPE_STEAM  )
		PrimeClientsideFxEnts( fireFXArray, eFxType.FX_PIPE_FIRE )
		level.fxPairingDone = true
	}

	local soundEntArray = clone hardpoint.s.soundEntArray
	soundEntArray.extend( hardpoint.s.steamFXArray )
	soundEntArray.extend( hardpoint.s.fanArray )
	thread AmbientSoundThink( soundEntArray )

	hardpoint.Signal( "HardpointStateChanged" )
	BoneyardHardpointUpdateState( hardpoint, true )
	thread BoneyardHardpointThink( hardpoint )
}

function GetHardpointFromID( hardpointID )
{
	Assert( IsValid( level.hardpointArray[ hardpointID ] ) )
	return level.hardpointArray[ hardpointID ]
}

function PrimeSoundEnts( team, targetname, soundTypeID )
{
	local soundEntArray = GetClientEntArray( "info_target_clientside", targetname )
	foreach( soundEnt in soundEntArray )
	{
		local uniqueIndex = level.uniqueIndex++
		local sound = null

		local soundArray = level.soundTable[ soundTypeID ]
		sound = soundArray[ uniqueIndex % soundArray.len() ]

		soundEnt.s.sound		<- sound
		soundEnt.s.team			<- team
		soundEnt.s.active		<- false
		soundEnt.s.playing		<- false
		soundEnt.s.index		<- uniqueIndex
	}
}

function PairSoundWithHardpoint( hardpoint, targetname )
{
	local soundEntArray = GetClientEntArray( "info_target_clientside", targetname )
	hardpoint.s.soundEntArray.extend( ArrayWithin( soundEntArray, hardpoint.GetOrigin(), 1500 ) )
}

function HardpointAmbientSound( hardpoint, team, instant )
{
	foreach( soundEnt in hardpoint.s.soundEntArray )
		thread HardpointAmbientSoundThread( hardpoint, team, soundEnt, instant )
}

function HardpointAmbientSoundThread( hardpoint, team, soundEnt, instant )
{
	hardpoint.EndSignal( "OnDestroy" )
	hardpoint.EndSignal( "HardpointNeutralized" )

	if ( !instant )
		wait RandomFloatCurve( 0, 4 )

	if ( soundEnt.s.team == team && !soundEnt.s.active )
	{
		soundEnt.s.active = true
	}
	else if ( soundEnt.s.team != team && soundEnt.s.active )
	{
		// stop sound belonging to the other team
		StopSoundOnEntity( soundEnt, soundEnt.s.sound )
		soundEnt.s.active = false
		soundEnt.s.playing = false
		soundEnt.Signal( "stop_sound" )
	}
}

function AmbientSoundThink( soundEntArray )
{
	local player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )

	while( true )
	{
		foreach( soundEnt in soundEntArray )
		{
			wait 0	// check one sound each frame

			if ( !soundEnt.s.active )
				continue

			local dist = DistanceSqr( soundEnt.GetOrigin(), player.GetOrigin() )
			local cap = pow( GetSoundRadius( soundEnt.s.sound ), 2 )
			if ( dist < cap )
			{
				if ( soundEnt.s.playing )
					continue

				EmitSoundOnEntity( soundEnt, soundEnt.s.sound )
				soundEnt.s.playing = true
				thread DebugDrawSoundName( soundEnt, soundEnt.s.sound )
			}
			else if ( soundEnt.s.playing )
			{
				StopSoundOnEntity( soundEnt, soundEnt.s.sound )
				soundEnt.s.playing = false
				soundEnt.Signal( "stop_sound" )
			}
		}
	}
}

function PairFxWithEntity( entityArray, fxArray, fxID, maxDist = 32, soundTypeID = null )
{
	local maxDist = pow( maxDist, 2 )

	// find the closest fx to an entity and pair them up
	foreach( entity in entityArray )
	{
		local origin = entity.GetOrigin()
		foreach( index, fxEnt in fxArray )
		{
			if ( DistanceSqr( fxEnt.GetOrigin(), origin ) < maxDist )
			{
				Assert( !( "fxEnt" in entity.s ), "tried to add an fx to a entity that already had one paired with it." )
				local uniqueIndex = level.uniqueIndex++
				local sound = null
				if ( soundTypeID )
				{
					local soundArray = level.soundTable[ soundTypeID ]
					sound = soundArray[ uniqueIndex % soundArray.len() ]
				}

				entity.s.fxEnt			<- fxEnt
				entity.s.fxID			<- fxID
				entity.s.fxHandle	 	<- null
				entity.s.index			<- uniqueIndex
				entity.s.sound			<- sound
				entity.s.active			<- false
				entity.s.playing		<- false

				fxArray.remove( index )
				break
			}
		}
	}
}

function PrimeClientsideFxEnts( FxEntArray, fxTypeID, soundTypeID = null )
{
	foreach( fxEnt in FxEntArray )
	{
		local uniqueIndex = level.uniqueIndex++
		local sound = null
		if ( soundTypeID )
		{
			local soundArray = level.soundTable[ soundTypeID ]
			sound = soundArray[ uniqueIndex % soundArray.len() ]
		}

		fxEnt.s.fxID		<- level.fxID[ fxTypeID ]
		fxEnt.s.fxHandle	<- null
		fxEnt.s.index		<- uniqueIndex
		fxEnt.s.sound		<- sound
		fxEnt.s.active		<- false
		fxEnt.s.playing		<- false
	}
}

function BoneyardHardpointThink( hardpoint )
{
	hardpoint.EndSignal( "OnDestroy" )

	while( true )
	{
		hardpoint.WaitSignal( "HardpointStateChanged" )

		BoneyardHardpointUpdateState( hardpoint )
	}
}

function BoneyardHardpointUpdateState( hardpoint, instant = false )
{
	local team = hardpoint.GetTeam()
	local hardpointID = hardpoint.GetHardpointID()

	if ( level.previousHardpointOwner[ hardpoint.GetHardpointID() ] == team && !instant )
	{
		//printt( "hardpoint didn't change team" )
		return
	}

	HardpointLights( hardpointID, false, true )

	switch( team )
	{
		case TEAM_IMC:
			// turn on IMC FX for this hardpoint
			HardpointLights( hardpointID, true, instant )
			// fire of small electric bursts with no buildup as long as it's in IMC control
			thread HardpointRandomElectricBurst( hardpointID )
			break

		case TEAM_MILITIA:
			// turn on fans for this hardpoint
			HardpointFans( hardpointID, true, instant )
			// turn on monitor screens for this hardpoint
			HardpointScreens( hardpointID, true, instant )
			// turn on steam, fan, and vent effects etc.
			HardpointAmbientFx( hardpoint.s.steamFXArray, true, instant )
			HardpointAmbientFx( hardpoint.s.fireFXArray, true, instant )
			break

		default:
			// interrupt hardpoint power bouildup
			hardpoint.Signal( "HardpointNeutralized" )

			// fire of an electric burst with no buildup
			if ( !instant )
				thread HardpointElectricBurstFx( hardpointID, 0.50 )

			// turn off IMC FX for this hardpoint
			HardpointLights( hardpointID, false, instant )
			// turn off fans for this hardpoint
			HardpointFans( hardpointID, false, instant )
			// turn off monitor screens for this hardpoint
			HardpointScreens( hardpointID, false, instant )
			// turn off steam, fan, and vent effects etc.
			HardpointAmbientFx( hardpoint.s.steamFXArray, false, instant )
			HardpointAmbientFx( hardpoint.s.fireFXArray, false, instant )
	}

	HardpointAmbientSound( hardpoint, team, instant )

	level.previousHardpointOwner[ hardpointID ] = team
}

function HardpointLights( hardpointID, active, instant )
{
	local hardpoint = GetHardpointFromID( hardpointID )

	if ( active )
	{
		foreach( lightModel in hardpoint.s.warningLightModelArray )
			thread TurnLightOn( lightModel, instant )
	}
	else
	{
		foreach( lightModel in hardpoint.s.warningLightModelArray )
			thread TurnLightOff( lightModel, instant )
	}
}

function TurnLightOff( lightModel, instant )
{
	lightModel.EndSignal( "OnDestroy" )

	local player = GetLocalViewPlayer()
	if ( !IsWatchingKillReplay() && !instant )
		wait RandomFloat( 0, 2.0 )

	if ( !IsValid( lightModel ) )
		return

	lightModel.SetModel( WARNING_LIGHT_OFF_MODEL )
	if ( lightModel.s.fxHandle )
	{
		EffectStop( lightModel.s.fxHandle, false, true )
		lightModel.s.fxHandle = null
	}
}

function TurnLightOn( lightModel, instant )
{
	lightModel.EndSignal( "OnDestroy" )

	// dsync the lights a bit
	if ( !IsWatchingKillReplay() )
		wait RandomFloat( 0, 2.0 )

	if ( !IsValid( lightModel ) )
		return

	lightModel.SetModel( WARNING_LIGHT_ON_MODEL )

	local origin = lightModel.s.fxEnt.GetOrigin()
	local angles = lightModel.s.fxEnt.GetAngles()

	lightModel.s.fxHandle = StartParticleEffectInWorldWithHandle( lightModel.s.fxID, origin, angles )
	EffectSetDontKillForReplay( lightModel.s.fxHandle )
}

function HardpointAmbientFx( fxEntArray, active, instant )
{
	foreach( fxEnt in fxEntArray )
	{
		fxEnt.Signal( "HardpointStateChanged" )
		thread HardpointAmbientFxOnOff( fxEnt, active, instant )
	}
}

function HardpointAmbientFxOnOff( fxEnt, active, instant )
{
	fxEnt.EndSignal( "HardpointStateChanged" )

	if ( !instant )
	{
		if ( active )
			wait RandomFloatCurve( 0, 8 )
		else
			wait RandomFloatCurve( 0, 4 )
	}

	if ( active )
	{
		if ( fxEnt.s.fxHandle )
			return
		local origin = fxEnt.GetOrigin()
		local angles = fxEnt.GetAngles()
		fxEnt.s.fxHandle <- StartParticleEffectInWorldWithHandle( fxEnt.s.fxID, origin, angles )
		EffectSetDontKillForReplay( fxEnt.s.fxHandle )

		fxEnt.s.active = true
	}
	else
	{
		if ( !fxEnt.s.fxHandle )
			return

		EffectStop( fxEnt.s.fxHandle, false, true )
		fxEnt.s.fxHandle = null
		if ( fxEnt.s.active && fxEnt.s.sound )
		{
			StopSoundOnEntity( fxEnt, fxEnt.s.sound )
			fxEnt.s.active = false
			fxEnt.s.playing = false
			fxEnt.Signal( "stop_sound" )
		}
	}
}

function HardpointFans( hardpointID, active, instant )
{
	local hardpoint = GetHardpointFromID( hardpointID )

	foreach( fan in hardpoint.s.fanArray )
	{
		fan.Signal( "HardpointStateChanged" )
		if ( !( "fxHandle" in fan.s ) )
		{
			CodeWarning( "dynamic fan with no fx paired to it at" + fan.GetOrigin() )
			continue
		}
		thread HardpointFanOnOff( fan, active, instant )
	}
}

function HardpointFanOnOff( fan, active, instant )
{
	fan.EndSignal( "OnDestroy" )
	fan.EndSignal( "HardpointStateChanged" )

	if ( !instant )
	{
		if ( active )
			wait RandomFloatCurve( 0, 8 )
		else
			wait RandomFloatCurve( 0, 4 )
	}

	if ( active )
	{
		fan.Anim_Play( "fast_spin" )
		if ( fan.s.fxHandle )
			return

		fan.s.active = true
		local origin = fan.s.fxEnt.GetOrigin()
		local angles = fan.s.fxEnt.GetAngles()
		fan.s.fxHandle <- StartParticleEffectInWorldWithHandle( level.fxID[ eFxType.FX_FAN_STEAM ], origin, angles )
		EffectSetDontKillForReplay( fan.s.fxHandle )
	}
	else
	{
		fan.Anim_Play( "ref" )

		StopSoundOnEntity( fan, fan.s.sound )
		fan.s.active = false
		fan.s.playing = false
		fan.Signal( "stop_sound" )

		if ( !fan.s.fxHandle )
			return

		EffectStop( fan.s.fxHandle, false, true )
		fan.s.fxHandle = null
	}
}

function HardpointScreens( hardpointID, active, instant )
{
	local hardpoint = GetHardpointFromID( hardpointID )

	if ( hardpoint.s.monitorOn == active && !instant )
		return

	foreach( monitor in hardpoint.s.monitorModelArray )
	{
		if ( instant )
		{
			if ( active )
				monitor.Show()
			else
				monitor.Hide()
		}
		else
		{
			thread MonitorFlicker( monitor, active )
		}
	}

	hardpoint.s.monitorOn = active
}

function MonitorFlicker( monitor, active )
{
	local player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )

	local flickers = RandomInt( 2, 6 ) * 2 + 1// always an odd number
	local state = !active

	wait RandomFloat( 0, 1.5 )	// longer initial wait so that not every screen powers on at the same time.

	for( local i = 0; i < flickers; i++ )
	{
		if ( !state )
		{
			monitor.Show()
			state = true
		}
		else
		{
			monitor.Hide()
			state = false
		}
		wait RandomFloat( 0, 0.2 )
	}
}

function ServerCallback_HardpointPowerBurst()
{
	Assert( GameRules.GetGameMode() == CAPTURE_POINT )

	foreach( hardpoint in level.hardpointArray )
	{
		if ( !hardpoint || hardpoint.GetTeam() != TEAM_IMC )
			continue

		thread  HardpointElectricBurst( hardpoint.GetHardpointID(), 1.0 )
	}
}

function DevHardpointElectricBurst()
{
	if ( GameRules.GetGameMode() != CAPTURE_POINT )
		printt( "Hardpoint Electric Burst only work in Hardpoint Mode" )

	foreach( hardpoint in level.hardpointArray )
	{
		if ( !hardpoint )
			continue

		thread HardpointElectricBurst( hardpoint.GetHardpointID(), RandomFloat( 0.5, 1.0 ) )
	}
}

function HardpointElectricBurst( hardpointID, maxCharge )
{
	Assert( maxCharge <= 1 )

	local hardpoint = GetHardpointFromID( hardpointID )
	local player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )
	hardpoint.EndSignal( "OnDestroy" )
	hardpoint.EndSignal( "HardpointNeutralized" )

	local startTime = Time()
	local timeTillBurst = 24.0 // timed by hand

	OnThreadEnd(
		function() : ( player, hardpoint, startTime, timeTillBurst, maxCharge )
		{
			if ( !IsValid( player ) )
				return

			// if the player is too far away don't bother doing a burst
			local dist = DistanceSqr( hardpoint.GetOrigin(), player.GetOrigin() )
			if ( dist > ( 1500 * 1500 ) )
				return

			if ( hardpoint.GetTeam() != TEAM_IMC )
			{
				StopSoundOnEntity( hardpoint, "boneyard_hardpoint_imc_overload_buildup" )
				EmitSoundOnEntityWithSeek( hardpoint, "boneyard_hardpoint_imc_overload_buildup", timeTillBurst )
			}
			// turn off warning lights
			HardpointLights( hardpoint.GetHardpointID(), false, true )

			local elapsedTime = Time() - startTime
			local charge = min( elapsedTime / timeTillBurst, maxCharge )

			thread HardpointElectricBurstFx( hardpoint.GetHardpointID(), charge )

			// turn on warning lights after a few seconds
			if ( hardpoint.GetTeam() == TEAM_IMC )
				delaythread( 5.0 * charge ) HardpointLights( hardpoint.GetHardpointID(), true, false )
		}
	)

	local duration = EmitSoundOnEntity( hardpoint, "boneyard_hardpoint_imc_overload_buildup" )
	wait timeTillBurst // timed by hand
	// the fx and burst sound is fired of in the OnThreadEnd thread
	// so that it can fire when a point get's neutralized
}

function HardpointRandomElectricBurst( hardpointID )
{
	local hardpoint = GetHardpointFromID( hardpointID )
	local player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )
	hardpoint.EndSignal( "OnDestroy" )
	hardpoint.EndSignal( "HardpointNeutralized" )

	while( true )
	{
		wait RandomFloat( 5, 25 )
		// if the player is too far away don't bother doing a burst
		local dist = DistanceSqr( hardpoint.GetOrigin(), player.GetOrigin() )
		if ( dist > ( 1500 * 1500 ) )
				continue
		thread HardpointElectricBurstFx( hardpointID, 0.20 )
	}
}

function HardpointElectricBurstFx( hardpointID, charge )
{
	Assert( charge <= 1 )
	Assert( hardpointID in level.hardpointFx )

	local setList = level.hardpointFx[ hardpointID ]
	local size = ceil( setList.len() * charge )
	local setIDArray = GetRandomSetIDArray( setList, size )
	local maxDelay = 4.0 * charge

	foreach ( index, setID in setIDArray )
	{
		local delay = pow( index, 2 ).tofloat() / pow( size, 2 ).tofloat() * maxDelay
		local origin = GetHardpointFxSetOrigin( hardpointID, setID )
		delaythread( delay ) EmitSoundAtPosition( origin, "boneyard_hardpoint_imc_overload_electricity" )
		delaythread( delay ) PlayHardpointFxSet( hardpointID, setID )
	}
}

function GetRandomSetIDArray( setList, size )
{
	Assert( size <= setList.len() )

	local setArray = []
	local stepSize = size / setList.len().tofloat()
	local index = RandomInt( setList.len() )
	local lastHit = ( index * stepSize ).tointeger()

	foreach ( setID, setData in setList )
	{
		index++
		local hit = lastHit < ( index * stepSize ).tointeger()
		if ( !hit )
			continue

		lastHit++
		setArray.append( setID )
	}

	ArrayRandomize( setArray )
	return setArray
}

/*--------------------------------------------------------------------------------------------------------*\
|
|													INTRO
|
\*--------------------------------------------------------------------------------------------------------*/

function IntroScreen_Setup()
{

	local imc_line_1 = "#INTRO_SCREEN_BONEYARD_LINE1"
	local imc_line_2 = "#INTRO_SCREEN_BONEYARD_LINE2"

	local mcor_line_1 = imc_line_1
	local mcor_line_2 = imc_line_2

	CinematicIntroScreen_SetText( TEAM_IMC, [ imc_line_1, imc_line_2 ] )
	CinematicIntroScreen_SetText( TEAM_MILITIA, [ mcor_line_1, mcor_line_2 ] )
	CinematicIntroScreen_SetBlackscreenFadeTimes( TEAM_IMC, 13.0, 2.0 )
	CinematicIntroScreen_SetBlackscreenFadeTimes( TEAM_MILITIA, 13.0, 2.0 )
	CinematicIntroScreen_SetTextFadeTimes( TEAM_IMC, 1.5, 6.5, 1.5 )
	CinematicIntroScreen_SetTextFadeTimes( TEAM_MILITIA, 1.5, 6.5, 1.5 )
	CinematicIntroScreen_SetTeamLogoFadeTimes( TEAM_IMC, 2.5 )
	CinematicIntroScreen_SetTeamLogoFadeTimes( TEAM_MILITIA, 2.5 )
}

/*--------------------------------------------------------------------------------------------------------*\
|
|													FLYERS
|
\*--------------------------------------------------------------------------------------------------------*/
function FlyersMain()
{
	thread ForTheSwarmMain()
}

function ForTheSwarmMain()
{
	wait 1	// for some reason if I don't wait the flyers get deleted?
	local highend = GetCPULevelWrapper() == CPU_LEVEL_HIGHEND

	local sequence1 = CreateFlyerSequence( Vector( 0, 0, 800 ), Vector( 0, 90, 0 ) )
	sequence1.groupAnimName = "boneyard_flyer_circle_1"
	sequence1.num			= highend ? 16 : 10		// less flyers on mid and min spec machines
	sequence1.flyerType	 	= eFlyerType.Cheap
	sequence1.runFunc	 	= FlyerFlyToPath
	sequence1.endFunc	 	= FlyerReactToPulse

	local sequence2 = CreateFlyerSequence( Vector( 1800, 3586, 2000 ), Vector( 0, -90, 0 ) )
	sequence2.groupAnimName = "boneyard_flyer_circle_1"
	sequence2.num			= highend ? 22 : 10		// less flyers on mid and min spec machines
	sequence2.flyerType	 	= eFlyerType.CheapMix
	sequence2.runFunc	 	= FlyerFlyToPath
	sequence2.endFunc	 	= FlyerReactToPulse

	local sequence3 = CreateFlyerSequence( Vector( -416, 1993, 4000 ), Vector( 0, 0, 0 ) )
	sequence3.groupAnimName = "boneyard_flyer_circle_1"
	sequence3.invalidArray 	= [ "g", "v", "s", "o", "e", "k", "c", "a", "m", "n", "p", "q" ]
	sequence3.num			= highend ? 10 : 8		// less flyers on mid and min spec machines
	sequence3.flyerType	 	= highend ? eFlyerType.CheapMix : eFlyerType.Static
	sequence3.runFunc	 	= FlyerFlyToPath
	sequence3.endFunc	 	= FlyerReactToPulse

	local sequence4 = CreateFlyerSequence( Vector( 3122, 1450, 6750 ), Vector( 0, 180, 0 ) )
	sequence4.groupAnimName = "boneyard_flyer_circle_1"
	sequence4.invalidArray 	= [ "p", "m", "n", "a" ]
	sequence4.num			= highend ? 18 : 8		// less flyers on mid and min spec machines
	sequence4.flyerType	 	= eFlyerType.Static
	sequence4.runFunc	 	= FlyerFlyToPath
	sequence4.endFunc	 	= FlyerReactToPulse

	level.sequenceArray.append( sequence1 )
	level.sequenceArray.append( sequence2 )
	level.sequenceArray.append( sequence3 )
	level.sequenceArray.append( sequence4 )

	thread AddFlyersToSequence( sequence1, 3 )
	thread AddFlyersToSequence( sequence2, 2 )
}

function AddFlyers()
{
	wait 0
	// dev command function to add flyers to the level
	thread AddFlyersToSequence( level.sequenceArray[ 0 ], 16, 2 )
	thread AddFlyersToSequence( level.sequenceArray[ 1 ], 22, 2 )
	thread AddFlyersToSequence( level.sequenceArray[ 2 ], 10, 2 )
	thread AddFlyersToSequence( level.sequenceArray[ 3 ], 18, 2 )
}

function PulseImminent()
{
	if ( !level.nv.pulseImminent || GetBugReproNum() == 54905 )
		return

	// stop adding flyers
	foreach( sequence in level.sequenceArray )
		sequence.ref.Signal( "EndAddToSequence" )
}

function FlyerPulseReaction( entity = null )
{
	// sending the signal will make them run the end func added to the sequence above
	local flyerArray = GetCirclingFlyers()

	foreach( flyer in flyerArray )
		thread SendPulseSignalToFlyer( flyer, "KillFlyer", RandomFloat( 0, 3 ) )
}

function SendPulseSignalToFlyer( flyer, signalToSend, delay )
{
	flyer.EndSignal( "OnDestroy" )
	flyer.EndSignal( "OnDeath" )

	// sad way to find the velocity of the flyer
	local origin = flyer.GetOrigin()
	wait 0.1
	local vector = flyer.GetOrigin() - origin
	local speed = fabs( vector.x ) + fabs( vector.y ) + fabs( vector.z )
	speed *= 10
	flyer.s.speed <- speed

	wait delay
	flyer.Signal( signalToSend )
}

function FlyerReactToPulse( flyer )
{
	local forwardVector = flyer.GetForwardVector()
	local rightVector = flyer.GetRightVector()
	local towerVector = flyer.GetOrigin() - level.dogWhistleOrigin
	local dist = towerVector.Norm()
	local forwardDot = forwardVector.Dot( towerVector )
	local rightDot = rightVector.Dot( towerVector )

	// stop path idle
	flyer.Signal( "FlyerNewPath" )

	WaitEndFrame()

	local origin = flyer.GetOrigin()
	if ( ( fabs( origin.x ) + fabs( origin.y ) + fabs( origin.z ) ) < 10 && GetBugReproNum() != 54905 )
	{
		printt( "destroyed flyer due to bad origin" )
		flyer.Destroy()
		return
	}

	if ( flyer.s.flyerType != eFlyerType.Static )
	{
		if ( ( forwardDot * -1 ) > fabs( rightDot ) )
		{
	//		DebugDrawLine( flyer.GetOrigin(), flyer.GetOrigin() + forwardVector * 512 * forwardDot, 0, 0, 255, true, 5.0 )
			PlayAnim( flyer, "flyer_pulsereaction_back" )
		}
		else if ( rightDot > 0 )
		{
	//		DebugDrawLine( flyer.GetOrigin(), flyer.GetOrigin() + rightVector * 512 * rightDot, 255, 0, 0, true, 5.0 )
			PlayAnim( flyer, "flyer_pulsereaction_right" )
		}
		else
		{
	//		DebugDrawLine( flyer.GetOrigin(), flyer.GetOrigin() + rightVector * 512 * rightDot, 255, 255, 0, true, 5.0 )
			PlayAnim( flyer, "flyer_pulsereaction_left" )
		}
	}
	else
	{
		// static flyers continue forward and up
		local forward = 8000.0
		local up = 3000.0
		local dist = sqrt( forward * forward + up * up )
		local speed = flyer.s.speed
		local moveTime = dist / speed
		local destination = flyer.GetOrigin() + forwardVector * forward + Vector( 0, 0, up )

		ClampToWorldspace( destination )
		local mover = CreateClientsideScriptMover( "models/dev/empty_model.mdl", flyer.GetOrigin(), flyer.GetAngles() )
		mover.DisableDraw()
		flyer.SetParent( mover, "ref" )

		mover.NonPhysicsMoveTo( destination , moveTime, 0, 0 )

		wait moveTime
		mover.Destroy()
	}
}

/*--------------------------------------------------------------------------------------------------------*\
|
|												Utility/Misc
|
\*--------------------------------------------------------------------------------------------------------*/

function RandomFloatCurve( minValue, maxValue )
{
	// return more lower number then higher with a nice curve falloff
	local rnd = RandomFloat( 0, 1 ) * RandomFloat( 0, 1 )
	local result = Graph( rnd, 0, 1, minValue, maxValue )
	return result
}

function CreateDialog()
{
	local table = { [TEAM_IMC] = [], [TEAM_MILITIA] = [] }
	return table
}

function AddDialogLine( dialog, team, character, alias, anim = null )
{
	local table = {}
	table.character <- character
	table.anim <- anim
	table.alias <- alias
	dialog[ team ].append( table )
}

function AddDialogWait( dialog, team, waitTime )
{
	local table = {}
	table.waitTime <- waitTime
	dialog[ team ].append( table )
}

function CL_PlayDialog( dialogTable )
{
	local player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )

	local duration = 0
	local dialog = dialogTable[ player.GetTeam() ]
	foreach( line in dialog )
	{
		if ( "waitTime" in line )
		{
			wait line.waitTime
			continue
		}

		if ( line.character && line.anim )
			duration = DisplayVDU( player, line.character, line.anim )
		else if ( line.alias )
			duration = EmitSoundOnEntity( player, line.alias )

		wait duration
	}
}

/*--------------------------------------------------------------------------------------------------------*\
|
|										HARDPOINT FX PLACEMENT EDITOR
|
\*--------------------------------------------------------------------------------------------------------*/

function EditorHardpointID( hardpointID )
{
	level.currentHardpointID = hardpointID
	printt( "HardpointID", level.currentHardpointID )
}

function EditorDeleteSet( setID = null )
{
	if ( !setID )
		setID = format( "fxSet%03d", level.currentSetindex )

	if ( "hardpointFx" in level )
	{
		// remove old data set
		if ( setID in level.hardpointFx[ level.currentHardpointID ] )
		{
			printt( "removing", setID )
			delete level.hardpointFx[ level.currentHardpointID ][ setID ]
			level.currentSetindex = max( 1, level.currentSetindex - 1 )
		}
	}
}

function EditorAddFx( fxTypeID )
{
	local time = Time()
	local delay = time - level.lastSetStartTime
	local gap = time - level.lastSetAddTime
	level.lastSetAddTime = Time()

	if ( gap > 3.0 )
	{
		// create a new set name
		if ( "hardpointFx" in level )
		{
			level.currentSetindex = level.hardpointFx[ level.currentHardpointID ].len() + 1
		}

		level.lastSetStartTime = Time()
		delay = 0.0
	}

	local setID = format( "fxSet%03d", level.currentSetindex )

	local player = GetLocalViewPlayer()
	local viewVector = player.GetViewVector()
	local start = player.EyePosition()
	local end = start + viewVector * 512

	local result = TraceLine( start, end, player, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )

	// target too far away
	if ( result.fraction == 1 )
		return

	local offset = level.fxOffset[ fxTypeID ]
	local angles = result.surfaceNormal.GetAngles()
	local vector = angles.AnglesToForward()
	local origin = result.endPos + vector * offset

	delay *= 0.25	// play back at four times the speed
	delay = format( "%1.3f", delay ).tofloat()
	origin = Vector( format( "%1.3f", origin.x ).tofloat(), format( "%1.3f", origin.y ).tofloat(), format( "%1.3f", origin.z ).tofloat() )

	local origin2  = origin + vector * 64
//	DebugDrawLine( origin, origin + Vector( 0,0,32 ), 255, 0, 0, true, 5.0 )
//	DebugDrawLine( origin, origin2, 255, 0, 255, true, 5.0 )

	AddHardpointFx( level.currentHardpointID, setID, fxTypeID, origin, angles, delay )
	StartParticleEffectInWorld( level.fxID[ fxTypeID ], origin, angles )
}

function EditorPlayLastSet()
{
	if ( !( "hardpointFx" in level ) )
		return

	thread PlayHardpointFxSet( level.currentHardpointID, format( "fxSet%03d", level.currentSetindex ) )
}

function EditorPlayHardpoint( hardpointID = null )
{
	if ( !( "hardpointFx" in level ) )
		return

	if ( !hardpointID )
		hardpointID = level.currentHardpointID

	foreach( setID, setData in level.hardpointFx[ hardpointID ] )
	{
		local duration = PlayHardpointFxSet( hardpointID, setID )
		wait duration
	}
}

function EditorShowSets()
{
	Signal( level, "EndEditorShow" )
	EndSignal( level, "EndEditorShow" )

	if ( !( "showSets" in level ) )
	{
		level.showSets <- true
	}
	else
	{
		delete level.showSets
		return
	}

	if ( !( "hardpointFx" in level ) )
		return

	local hardpointID = level.currentHardpointID

	while( true )
	{
		foreach( setID, setData in level.hardpointFx[ hardpointID ] )
		{
			local fx = level.hardpointFx[ hardpointID ][ setID ][0]
			DebugDrawText( fx.origin, setID, true, 0.15 )
			DrawLineBox( fx.origin, fx.angles, Vector( 4, 4, 4 ), 96, 0, 0, 0.15 )
		}
		wait 0.1
	}
}

function DrawLineBox( origin, angles, size, r, g, b, time )
{
	local fVector = angles.AnglesToForward()
	local rVector = angles.AnglesToRight()
	local uVector = angles.AnglesToUp()

	local lfr  = origin + ( fVector * size.x ) + ( rVector * size.y ) + ( uVector * -size.z )
	local lfl  = origin + ( fVector * size.x ) + ( rVector * -size.y ) + ( uVector * -size.z )
	local lrr  = origin + ( fVector * -size.x ) + ( rVector * size.y ) + ( uVector * -size.z )
	local lrl  = origin + ( fVector * -size.x ) + ( rVector * -size.y ) + ( uVector * -size.z )

	local ufr  = lfr + ( uVector * size.z * 2 )
	local ufl  = lfl + ( uVector * size.z * 2 )
	local urr  = lrr + ( uVector * size.z * 2 )
	local url  = lrl + ( uVector * size.z * 2 )

	local dirStart = origin
	local dirEnd = origin + fVector * 32

	DebugDrawLine( dirStart, dirEnd  , r, g, b, false, time )

	DebugDrawLine( lfr, lfl, r, g, b, false, time )
	DebugDrawLine( lfl, lrl, r, g, b, false, time )
	DebugDrawLine( lrl, lrr, r, g, b, false, time )
	DebugDrawLine( lrr, lfr, r, g, b, false, time )

	DebugDrawLine( lfr, ufr, r, g, b, false, time )
	DebugDrawLine( lfl, ufl, r, g, b, false, time )
	DebugDrawLine( lrl, url, r, g, b, false, time )
	DebugDrawLine( lrr, urr, r, g, b, false, time )

	DebugDrawLine( ufr, ufl, r, g, b, false, time )
	DebugDrawLine( ufl, url, r, g, b, false, time )
	DebugDrawLine( url, urr, r, g, b, false, time )
	DebugDrawLine( urr, ufr, r, g, b, false, time )
}

function PlayHardpointFxSet( hardpointID, setID )
{
	if ( !( setID in level.hardpointFx[ hardpointID ] ) )
		return 0.0

	local startOrigin = null
	local duration = 0
	local setData = level.hardpointFx[ hardpointID ][ setID ]
	foreach( fx in setData )
	{
		local fxID = level.fxID[ fx.fxTypeID ]

		delaythread( fx.delay ) StartParticleEffectInWorld( fxID, fx.origin, fx.angles )

		if ( fx.delay > duration )
			duration = fx.delay

		if ( !startOrigin )
			startOrigin = fx.origin
	}

	return duration
}

function GetHardpointFxSetOrigin( hardpointID, setID )
{
	Assert( setID in level.hardpointFx[ hardpointID ] )
	local setData = level.hardpointFx[ hardpointID ][ setID ]
	Assert( setData.len() )
	return setData[0].origin
}

function AddHardpointFx( hardpointID, setID, fxTypeID, origin, angles, delay )
{
	if ( !( "hardpointFx" in level ) )
		level.hardpointFx <- [ {}, {}, {} ]

	if ( !( setID in level.hardpointFx[ hardpointID ] ) )
		level.hardpointFx[ hardpointID ][ setID ] <- []

	local setFxArray = level.hardpointFx[ hardpointID ][ setID ]

	setFxArray.append( { fxTypeID = fxTypeID, origin = origin, angles = angles, delay = delay } )
}

function EditorSaveHardpointFx()
{
	if ( !( "hardpointFx" in level ) )
		return

	DevTextBufferClear()
	DevTextBufferWrite( "// Auto generated file, edit at own risk!\n\n" )
	DevTextBufferWrite( "function main()\n{\n" )

	foreach( hardpointID, fxSetArray in level.hardpointFx )
	{
		foreach( SetID, SetData in fxSetArray )
		{
			foreach( fx in SetData )
			{
				local pos = fx.origin
				local ang = fx.angles

				local printString =	"\tAddHardpointFx( " + hardpointID + ", \"" + SetID + "\", "
				printString +=		"eFxType." + GetFxTypeName( fx.fxTypeID ) + ", "
				printString +=		"Vector( " + pos.x + ", " + pos.y + ", " + pos.z + " ), "
				printString +=		"Vector( " + ang.x + ", " + ang.y + ", " + ang.z + " ), "
				printString +=		fx.delay + " )\n"
				DevTextBufferWrite( printString )
			}
		}
	}

	// Write function close
	DevTextBufferWrite( "}\n" )
	DevTextBufferDumpToFile( "scripts/vscripts/client/levels/cl_" + GetMapName() + "_fx.nut" )

	printt( "#####################################" )
	printt( "############# FX SAVED! #############" )
	printt( "#####################################" )
}

function GetFxTypeName( id )
{
	local table = getconsttable().eFxType
	foreach( key, val in table )
	{
		if ( val == id )
			return key
	}
	return null
}


RegisterSignal( "stop_sound" )
function DebugDrawSoundName( ent, soundString )
{
	if ( GetBugReproNum() != 1970 )
		return

	ent.EndSignal( "OnDestroy" )
	ent.EndSignal( "stop_sound" )
	while( true )
	{
		DebugDrawText( ent.GetOrigin(), soundString, false, 0.5 )
		wait 0.5
	}
}


function CE_VisualSettingBoneyardIMC( player, ref )
{
	CE_ResetVisualSettings( player )

	ref.LerpSkyScale( SKYSCALE_BONEYARD_IMC_SHIP, 0.01 )
}

function CE_VisualSettingBoneyardMCOR( player, ref )
{
	CE_ResetVisualSettings( player )

	ref.LerpSkyScale( SKYSCALE_BONEYARD_MCOR_SHIP, 0.01 )
}

function CE_BloomOnRampOpenBoneyardMCOR( player, ref )
{
	AddAnimEvent( ref, "cl_ramp_open", TonemappingOnDoorOpenBoneyard, SKYSCALE_BONEYARD_DOOROPEN_MCOR_SHIP )
}

function CE_BloomOnRampOpenBoneyardIMC( player, ref )
{
	AddAnimEvent( ref, "cl_ramp_open", TonemappingOnDoorOpenBoneyard, SKYSCALE_BONEYARD_DOOROPEN_IMC_SHIP )
}

function TonemappingOnDoorOpenBoneyard( ref, scale )
{
	ref.LerpSkyScale( scale, 1.0 )
	thread CinematicTonemappingThread()
}

