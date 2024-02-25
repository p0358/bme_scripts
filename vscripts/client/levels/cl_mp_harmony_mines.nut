const FX_ENV_TRASH_TUBE_FAST_HLD = "P_mines_Elec_tube_ON"
const FX_ENV_TRASH_TUBE_SLOW_HLD = "P_mines_Elec_tube_OFF"
const FX_ENV_TRASH_SML_TUBE_FAST_HLD = "env_trash_tube_sml_fast_hld"
const FX_ENV_TRASH_SML_TUBE_SLOW_HLD = "env_trash_tube_sml_slow_hld"
const FX_DIGGER_ON 			= "P_digger_dirt_full_ON"
const FX_DIGGER_OFF 		= "P_digger_dirt_full_OFF"
const FX_DIGGER_POI_ON 		= "P_digger_dirt_poi_ON"
const FX_DIGGER_POI_OFF 	= "P_digger_dirt_poi_OFF"
const FX_DIGGER_PLATFORM_ON = "P_digger_dust_platform"

PrecacheParticleSystem( FX_ENV_TRASH_TUBE_FAST_HLD )
PrecacheParticleSystem( FX_ENV_TRASH_TUBE_SLOW_HLD )
PrecacheParticleSystem( FX_ENV_TRASH_SML_TUBE_FAST_HLD )
PrecacheParticleSystem( FX_ENV_TRASH_SML_TUBE_SLOW_HLD )
PrecacheParticleSystem( FX_DIGGER_ON )
PrecacheParticleSystem( FX_DIGGER_OFF )
PrecacheParticleSystem( FX_DIGGER_POI_ON )
PrecacheParticleSystem( FX_DIGGER_POI_OFF )
PrecacheParticleSystem( FX_DIGGER_PLATFORM_ON )

/*
function ScriptReload()
{
	if ( !reloadingScripts )
		return

	printt( "HARMONY MINES CLIENT SCRIPT RELOAD" )
}
*/

function main()
{
	IncludeFileAllowMultipleLoads( "client/cl_carrier" ) //Included for skyshow dogfights
	IncludeFileAllowMultipleLoads( "client/objects/cl_hornet_fighter" )
	IncludeFileAllowMultipleLoads( "client/objects/cl_phantom_fighter" )

	IncludeScript( "mp_harmony_mines_shared" )

	level.FX_WARNING_LIGHT 				<- PrecacheParticleSystem( "warning_light_orange_blink" )
	level.FX_WARNING_LIGHT_NOWALL 		<- PrecacheParticleSystem( "warning_light_orange_blink_nowall" )
	level.FX_DIGGER_LIGHT_SOLID 		<- PrecacheParticleSystem( "mines_light_orange_ON" )
	level.FX_DIGGER_LIGHT_BLINK 		<- PrecacheParticleSystem( "mines_light_orange_blink" )
	level.FX_LIGHT_ORANGE 				<- PrecacheParticleSystem( "runway_light_orange" )
	level.FX_LIGHT_GREEN 				<- PrecacheParticleSystem( "runway_light_green" )
	level.FX_LIGHT_AERIAL_WARNING 		<- PrecacheParticleSystem( "runway_light_red" )
	level.GRINDER_FX_DIRTFALL 			<- PrecacheParticleSystem( "P_rock_crusher_dirtfall_ON" )
	level.GRINDER_FX_DIRTFALL_REPLAY 	<- PrecacheParticleSystem( "P_rock_crusher_dirtfall_ON_replay" )
	level.GRINDER_FX_TOP 				<- PrecacheParticleSystem( "P_rock_crusher_ON" )
	level.GRINDER_FX_SIDE 				<- PrecacheParticleSystem( "P_rock_crusher_ON_side" )
	level.GRINDER_FX_FLOOR 				<- PrecacheParticleSystem( "P_rock_crusher_floor_ON" )

	level.thumper <- null

	level.grinderDoors <- []
	level.grinderDoorAnims <- {}
	level.grinderDoorsOpen <- null
	level.grinderRoller <- null
	level.grinderOn <- false

	level.scriptedFX <- {}

	level.diggerWheel <- null
	level.diggerGenerators <- []
	level.diggerWires <- []
	level.diggerWireAnims <- {}
	level.diggerGenerator_spindownAnimTime <- null
	level.diggerGenerator_spinupAnimTime <- null
	level.diggerDirtFX <- []

	level.pumps <- []

	level.screenShakes <- {}

	level.grinderRollerOrigin <- Vector( -2168, -4520, 400 )  // HACK roller model has a weird origin, can't use that

	AddCreateCallback( "info_hardpoint", HarmonyMines_HardpointCreated )
	AddCreateCallback( "player", HarmonyMines_PlayerCreated )

	RegisterSignal( "GrinderStateChange" )
	RegisterSignal( "GrinderStopThink" )
	RegisterSignal( "GrinderRollerRotationDone" )
	RegisterSignal( "GrinderRoller_SpinningIdle_Stop" )
	RegisterSignal( "DisablePumps" )
	RegisterSignal( "DiggerWheelRotationDone" )
	RegisterSignal( "StopDiggerThink" )
	RegisterSignal( "DiggerWires_StateChange_Starting" )
	RegisterSignal( "DiggerScreenShake_StateChange_Starting" )
	RegisterSignal( "DiggerGenerators_StateChange_Starting" )
	RegisterSignal( "DiggerFX_StateChange_Starting" )
	RegisterSignal( "ThumperStrike_ScreenShake_Starting" )

	FlagInit( "HarmonyMines_ClientSetupStarted" )
	FlagInit( "DiggerSetupDone" )
	FlagInit( "GrinderSetupDone" )

	RegisterServerVarChangeCallback( "diggerWiresState", DiggerWires_StateChange )
	RegisterServerVarChangeCallback( "diggerScreenShake", DiggerScreenShake_StateChange )
	RegisterServerVarChangeCallback( "diggerGeneratorsOn", DiggerGenerators_StateChange )
	RegisterServerVarChangeCallback( "diggerFXState", DiggerFX_StateChange )
	SetFullscreenMinimapParameters( 2.05, -1350, -1400, 180 )
	if ( GAMETYPE == COOPERATIVE )
		SetCustomMinimapZoom( 2 )
}

function EntitiesDidLoad()
{
	ThumperSetup()
	AerialWarningLightsSetup()

	DiggerSetup()
	GrinderSetup()
	PumpsSetup()
}


// ===== PLAYER CREATED INIT FUNCTIONS =====
// - Kill replay friendly.
function HarmonyMines_PlayerCreated( player, isRecreate )
{
	Assert( !isRecreate )

	if ( player != GetLocalClientPlayer() )
		return

	thread HarmonyMines_LocalClientPlayerCreated( player )
}

// happens every time client script is reset (like for kill replay)
function HarmonyMines_LocalClientPlayerCreated( player )
{
	//printt( "PlayerCreated_Threaded for player", player.GetName() )

	// player can spawn before entities are loaded
	FlagWait( "ClientInitComplete" )

	thread PlayerScreenShakeThink( player )

	thread PlayerCreated_InitGrinder()

	thread PlayerCreated_InitDigger()
}

function PlayerCreated_InitGrinder()
{
	FlagWait( "GrinderSetupDone" )
	Grinder_SetStateBasedOnTimestamps()
	thread GrinderStateChange_Think()
}

function PlayerCreated_InitDigger()
{
	FlagWait( "DiggerSetupDone" )

	local state = null
	local instantChange = false

	if ( IsWatchingKillReplay() )
	{
		instantChange = true

		local onTime = level.nv.diggerStartTime
		local offTime = level.nv.diggerStopTime

		//printt( "Digger onTime  =", onTime )
		//printt( "Digger offTime =", offTime )

		local player = GetLocalClientPlayer()
		Assert( TimeAdjustmentForRemoteReplayCall() != 0 ) // as covered in bug 37773
		local killReplayStartTime = player.cv.killReplayTimeOfDeath - TimeAdjustmentForRemoteReplayCall()

		//printt( "Digger remote call time adjustment:", TimeAdjustmentForRemoteReplayCall() )
		//printt( "Digger player time of death:", killReplayStartTime, "| Current time:", Time() )

		state = eDiggerState.TWITCH
		if ( onTime > offTime )
			state = eDiggerState.SPIN

		local timeToStateChange = -1

		if ( state == eDiggerState.SPIN )
		{
			// see if we actually have to start in the twitch
			if ( killReplayStartTime >= offTime && killReplayStartTime < onTime )
			{
				timeToStateChange = onTime - killReplayStartTime
				//printt( "timeToStateChange:", timeToStateChange )

				local SPINUP_BUFFER = 2.5
				timeToStateChange -= SPINUP_BUFFER
				//printt( "timeToStateChange adjusted for spinup:", timeToStateChange )

				if ( timeToStateChange > 0 )
				{
					//printt( "Kill replay adjust: start TWITCH")
					state = eDiggerState.TWITCH
				}
				else
				{
					//printt( "Negative buffer time, kill replay state will not be adjusted." )
				}
			}
		}
		else
		{
			// see if we actually have to start in a spin
			if ( killReplayStartTime >= onTime && killReplayStartTime < offTime )
			{
				timeToStateChange = offTime - killReplayStartTime
				//printt( "timeToStateChange:", timeToStateChange )

				local SPINDOWN_BUFFER = 2.0  // rough time it takes the wheel to spin down enough for the fx to look right
				timeToStateChange -= SPINDOWN_BUFFER
				//printt( "timeToStateChange adjusted for spindown:", timeToStateChange )

				if ( timeToStateChange > 0 )
				{
					//printt( "Kill replay adjust: start SPIN" )
					state = eDiggerState.SPIN
				}
				else
				{
					//printt( "Negative buffer time, kill replay state will not be adjusted." )
				}

			}
		}

		if ( timeToStateChange > 0 )
		{
			local nextState = eDiggerState.TWITCH
			if ( state == nextState )
				nextState = eDiggerState.SPIN

			thread Digger_ChangeStateDuringKillReplay( timeToStateChange, nextState )
		}
	}

	/*
	local stateStr = "SPIN"
	if ( state == null )
		stateStr = "SERVER SYNC"
	else if ( state == eDiggerState.TWITCH )
		stateStr = "TWITCH"

	printt( "Player created, starting digger with state:", stateStr )
	*/

	Digger_SetState( state, instantChange )
}

function Digger_ChangeStateDuringKillReplay( delay, newState )
{
	Assert( IsWatchingKillReplay() )
	Assert( newState == eDiggerState.SPIN || newState == eDiggerState.TWITCH )

	local player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )

	wait delay

	local stateStr = "SPIN"
	if( newState == eDiggerState.TWITCH )
		stateStr = "TWITCH"

	//printt( "Digger waited", delay, "secs before changing state to:", stateStr )
	Digger_SetState( newState )
}

function Digger_SetState( state = null, instantChange = false )
{
	// If state is null, these functions will use NVs to sync to current server state
	DiggerWires_StateChange( state )
	DiggerScreenShake_StateChange( state )
	DiggerGenerators_StateChange( state, instantChange )
	DiggerFX_StateChange( state, instantChange )
}


// ===== THUMPER =====
function ThumperSetup()
{
	level.thumper = GetClientEnt_ByClassAndName( "prop_dynamic", "prop_static_9" )  // HACK bad name

	// screen shake
	local params = {}
	params.direction 	<- Vector( 0, 0, 0 )
	params.distClose 	<- 300
	params.distFar 		<- 900
	params.amplitudeMin <- 0.3
	params.amplitudeMax <- 0.8
	params.frequency 	<- 10
	params.duration 	<- 2.0
	params.waittime 	<- 1.5  // wait time before looping for another shake
	local shakeOrg = Vector( 754, 1026, 293 ) // thumper origin is off from where I want to measure from
	AddScreenShake_DistanceScaled( "ThumperShake", shakeOrg, params )

	AddAnimEvent( level.thumper, "thumper_strike", Thumper_AnimEvent_Strike )
}

function Thumper_AnimEvent_Strike( thumper )
{
	thread ThumperStrike_ScreenShake()
}

function ThumperStrike_ScreenShake()
{
	level.thumper.Signal( "ThumperStrike_ScreenShake_Starting" )
	level.thumper.EndSignal( "ThumperStrike_ScreenShake_Starting" )

	level.thumper.EndSignal( "OnDestroy" )

	local shakes = GetScreenShakesByAliasOrGroup( "ThumperShake" )
	Assert( shakes.len() == 1 )
	local shake = shakes[0]
	local waittime = shake.params.waittime

	EnableScreenShake( "ThumperShake" )
	wait waittime
	DisableScreenShake( "ThumperShake" )
}


// ===== AERIAL WARNING LIGHTS =====
// red warning lights up high
function AerialWarningLightsSetup()
{
	local fxSpots = GetEntArrayByClassAndTargetname( "info_target_clientside", "warning_light_smokestack_fx" )
	Assert( fxSpots.len() )

	foreach( fxSpot in fxSpots )
		AddScriptedFXSpot( "AerialWarning", fxSpot, level.FX_LIGHT_AERIAL_WARNING )

	ScriptedFXGroup_TurnOn( "AerialWarning" )
}


// ===== DIGGER ARM / WHEEL =====
function DiggerSetup()
{
	// digger wheel
	local prop = GetClientEnt_ByClassAndName( "prop_dynamic", "digger_model_scoop" )
	level.diggerWheel = prop

	// generators
	local gennynames = []
	gennynames.append( "generator_excavator_01" )
	gennynames.append( "generator_excavator_02" )
	gennynames.append( "generator_excavator_03" )
	gennynames.append( "generator_excavator_04" )
	foreach ( idx, name in gennynames )
	{
		local generator = GetClientEnt_ByClassAndName( "prop_dynamic", name )
		generator.s.isOn <- false
		level.diggerGenerators.append( generator )
	}

	level.diggerGenerator_spindownAnimTime 	= level.diggerGenerators[0].GetSequenceDuration( "spindown" )
	level.diggerGenerator_spinupAnimTime 	= level.diggerGenerators[0].GetSequenceDuration( "spinup" )

	// wires
	level.diggerWireAnims[ "harmony_wire_set1_animated" ] <- { shake_loop = "cable1_shake", shake_twitch = "cable1_shake_twitch" }
	level.diggerWireAnims[ "harmony_wire_set2_animated" ] <- { shake_loop = "cable2_shake", shake_twitch = "cable2_shake_twitch" }

	local wirenames = []
	wirenames.append( "wire_long_01" )
	wirenames.append( "wire_long_02" )
	wirenames.append( "wire_long_03" )
	wirenames.append( "wire_long_04" )
	wirenames.append( "wire_short_01" )
	wirenames.append( "wire_short_02" )
	foreach ( idx, name in wirenames )
	{
		local wire = GetClientEnt_ByClassAndName( "prop_dynamic", name )
		wire.s.anims <- GetAnimsForDiggerWireModel( wire )
		level.diggerWires.append( wire )
	}

	// lights
	local blinkSpots = GetEntArrayByClassAndTargetname( "info_target_clientside", "warning_light_excavate_fx_blink" )
	Assert( blinkSpots.len() )
	local solidSpots = GetEntArrayByClassAndTargetname( "info_target_clientside", "warning_light_excavate_fx" )
	Assert( solidSpots.len() )

	local models = GetEntArrayByClassAndTargetname( "prop_dynamic", "warning_light_excavate_ON" )

	foreach ( fxSpot in blinkSpots )
	{
		// hacky - associate models with fxSpots so we don't have to link them in leveled
		local model = FXSpot_FindNearbyModel( fxSpot, models )

		AddScriptedFXSpot( "digger", fxSpot, level.FX_DIGGER_LIGHT_BLINK, true, model, level.WARNING_LIGHT_ON_MODEL, level.WARNING_LIGHT_OFF_MODEL )
	}

	foreach ( fxSpot in solidSpots )
	{
		// hacky - associate models with fxSpots so we don't have to link them in leveled
		local model = FXSpot_FindNearbyModel( fxSpot, models )

		AddScriptedFXSpot( "digger_solid", fxSpot, level.FX_DIGGER_LIGHT_SOLID, true, model, level.WARNING_LIGHT_ON_MODEL, level.WARNING_LIGHT_OFF_MODEL )
	}

	// FX
	AddDiggerDirtFXEnt( "info_particle_system_digger_ON", FX_DIGGER_OFF, FX_DIGGER_ON )
	AddDiggerDirtFXEnt( "info_particle_system_digger_ON_poi", FX_DIGGER_POI_OFF, FX_DIGGER_POI_ON )
	AddDiggerDirtFXEnt( "info_particle_system_digger_ON_platform", FX_DIGGER_PLATFORM_ON, FX_DIGGER_PLATFORM_ON )  // use same particle for both states

	// screen shake: digger wheel
	local params = {}
	params.direction 	<- Vector( 0, 0, 0 )
	params.distClose 	<- 500 	// anything within this radius will get max amplitude
	params.distFar 		<- 1024 // anything beyond this radius gets zero amplitude
	params.amplitudeMin <- 0.4
	params.amplitudeMax <- 0.5
	params.frequency 	<- 16
	params.duration 	<- 1.0
	params.waittime 	<- 0.5  // wait time before looping for another shake
	AddScreenShake_DistanceScaled( "DiggerShake_Wheel", level.diggerWheel.GetOrigin(), params, "DiggerShake" )

	// screen shake: along the digger arm
	local armParams = clone params
	armParams.distClose <- 500
	armParams.distFar 	<- 500
	armParams.amplitudeMin <- 0.2
	armParams.amplitudeMax <- 0.3

	local armShakeSpots = []
	armShakeSpots.append( Vector( -3061.88, -3046.03, 742.246 ) )
	armShakeSpots.append( Vector( -2778.1, -2771.97, 744.789 ) )
	foreach ( idx, spot in armShakeSpots )
		AddScreenShake_DistanceScaled( "DiggerShake_Arm_" + idx, spot, armParams, "DiggerShake" )

	FlagSet( "DiggerSetupDone" )
}

function FXSpot_FindNearbyModel( fxSpot, models )
{
	local thismodel = null
		foreach ( model in models )
		{
			if ( Distance( model.GetOrigin(), fxSpot.GetOrigin() ) <= 5 )
			{
				thismodel = model
				break
			}
		}
		Assert( thismodel, "Couldn't find warning light model near origin " + fxSpot.GetOrigin() )
}

function GetAnimsForDiggerWireModel( wire )
{
	local wireModelDirPath = wire.GetModelName()
	local anims = null

	foreach ( modelname, animtable in level.diggerWireAnims )
	{
		if ( !StringContains( wireModelDirPath, modelname ) )
			continue

		anims = animtable
		break
	}

	Assert( anims != null, "Couldn't find digger wire anims for model: " + wiremodel )
	return anims
}

function DiggerWiresPlayAnim( animtype )
{
	//printt( "DiggerWiresPlayAnim:", animtype )

	foreach ( wire in level.diggerWires )
	{
		Assert( wire.s.anims.len() )
		Assert( animtype in wire.s.anims )

		local animname = wire.s.anims[ animtype ]
		wire.Anim_Play( animname )
	}
}

function DiggerWires_StateChange( nvOverride = null )
{
	// if null, we know the callback is trying to change the state
	if ( nvOverride == null && IsWatchingKillReplay() )
		return

	level.ent.Signal( "DiggerWires_StateChange_Starting" )
	level.ent.EndSignal( "DiggerWires_StateChange_Starting" )

	FlagWait( "DiggerSetupDone" )

	local state = level.nv.diggerWiresState
	if ( nvOverride != null )
		state = nvOverride

	// Note: wire shaking anims are synced to match the wheel anims
	if ( state == eDiggerState.SPIN )
		DiggerWiresPlayAnim( "shake_loop" )
	else
		DiggerWiresPlayAnim( "shake_twitch" )
}
Globalize( DiggerWires_StateChange )


function DiggerScreenShake_StateChange( nvOverride = null )
{
	if ( nvOverride == null && IsWatchingKillReplay() )
		return

	level.ent.Signal( "DiggerScreenShake_StateChange_Starting" )
	level.ent.EndSignal( "DiggerScreenShake_StateChange_Starting" )

	FlagWait( "DiggerSetupDone" )

	local state = level.nv.diggerScreenShake
	if ( nvOverride != null )
		state = nvOverride

	local shakegroup = "DiggerShake"

	if ( state == eDiggerState.SPIN )
		EnableScreenShake( shakegroup )
	else
		DisableScreenShake( shakegroup )
}
Globalize( DiggerScreenShake_StateChange )


function DiggerGenerators_StateChange( nvOverride = null, doImmediateChange = false )
{
	if ( nvOverride == null && IsWatchingKillReplay() )
		return

	level.ent.Signal( "DiggerGenerators_StateChange_Starting" )
	level.ent.EndSignal( "DiggerGenerators_StateChange_Starting" )

	FlagWait( "DiggerSetupDone" )

	local state = level.nv.diggerGeneratorsOn
	if ( nvOverride != null )
		state = nvOverride

	if ( state == eDiggerState.SPIN )
	{
		//printt( "Generators START, immediate change?", doImmediateChange )
		thread DiggerGenerators_Start( doImmediateChange )
	}
	else
	{
		//printt( "Generators STOP, immediate change?", doImmediateChange )
		thread DiggerGenerators_Stop( doImmediateChange )
	}
}
Globalize( DiggerGenerators_StateChange )


function DiggerFX_StateChange( nvOverride = null, instakill = false )
{
	if ( nvOverride == null && IsWatchingKillReplay() )
		return

	level.ent.Signal( "DiggerFX_StateChange_Starting" )
	level.ent.EndSignal( "DiggerFX_StateChange_Starting" )

	FlagWait( "DiggerSetupDone" )

	local state = level.nv.diggerFXState
	if ( nvOverride != null )
		state = nvOverride

	// Warning lights change
	if ( state == eDiggerState.SPIN )
		thread ScriptedFXGroup_SwapOnFX( "digger", level.FX_DIGGER_LIGHT_BLINK )
	else
		thread ScriptedFXGroup_SwapOnFX( "digger", level.FX_DIGGER_LIGHT_SOLID )

	// Dirt FX change
	DiggerDirtFX_StateChange( state, instakill )
}
Globalize( DiggerFX_StateChange )


function AddDiggerDirtFXEnt( tn, fxOff, fxOn )
{
	local fxEnt = GetClientEnt_ByClassAndName( "info_target_clientside", tn )

	local t = {}
	t[ eDiggerState.TWITCH ] <- fxOff
	t[ eDiggerState.SPIN ] <- fxOn
	fxEnt.s.fx <- t

	fxEnt.s.activeFX <- null
	fxEnt.s.fxHandle <- null

	level.diggerDirtFX.append( fxEnt )
}

function DiggerDirtFX_StateChange( state, instakill = false )
{
	foreach ( fxEnt in level.diggerDirtFX )
	{
		local newFX = fxEnt.s.fx[ state ]

		// don't play if already playing
		if ( fxEnt.s.activeFX && newFX == fxEnt.s.activeFX )
			continue

		if ( fxEnt.s.activeFX )
		{
			Assert( fxEnt.s.fxHandle )

			if ( EffectDoesExist( fxEnt.s.fxHandle ) )
			{
				if ( instakill )
					EffectStop( fxEnt.s.fxHandle, true, false )
				else
					EffectStop( fxEnt.s.fxHandle, false, true )
			}

			fxEnt.s.fxHandle = null
			fxEnt.s.activeFX = null
		}

		fxEnt.s.activeFX = newFX
		local fxIdx = GetParticleSystemIndex( fxEnt.s.activeFX )
		Assert( fxIdx != null )

		//printt( "DiggerFX_StateChange: playing FX", fxEnt.s.activeFX )
		fxEnt.s.fxHandle = StartParticleEffectInWorldWithHandle( fxIdx, fxEnt.GetOrigin(), fxEnt.GetAngles() )
		EffectSetDontKillForReplay( fxEnt.s.fxHandle )
	}
}


function DiggerGenerators_Start( doImmediateChange = false )
{
	level.ent.EndSignal( "StopDiggerThink" )

	foreach ( generator in level.diggerGenerators )
		thread DiggerGenerator_Start( generator, doImmediateChange )

	wait level.diggerGenerator_spinupAnimTime
}

function DiggerGenerators_Stop( doImmediateChange = false )
{
	level.ent.EndSignal( "StopDiggerThink" )

	foreach ( generator in level.diggerGenerators )
		thread DiggerGenerator_Stop( generator, doImmediateChange )

	wait level.diggerGenerator_spindownAnimTime
}

function DiggerGenerator_Start( generator, immediateChange = false )
{
	if ( generator.s.isOn )
		return

	generator.s.isOn = true

	local player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )
	generator.EndSignal( "OnDestroy" )

 	if ( !immediateChange )
 	{
		EmitSoundOnEntity( generator, "DigSite_Scr_Generator_SpinUp" )
		DiggerGenerator_PlayAnim( generator, "spinup" )
	}

	thread DiggerGenerator_PlayAnim( generator, "spinning_idle" )
	EmitSoundOnEntity( generator, "DigSite_Scr_Generator_LP" )
}

function DiggerGenerator_Stop( generator, immediateChange = false )
{
	if ( !generator.s.isOn )
		return

	generator.s.isOn = false

	local player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )
	generator.EndSignal( "OnDestroy" )

	FadeOutSoundOnEntity( generator, "DigSite_Scr_Generator_LP", 0.25 )

	if ( !immediateChange )
	{
		EmitSoundOnEntity( generator, "DigSite_Scr_Generator_SpinDown" )
		DiggerGenerator_PlayAnim( generator, "spindown" )
	}

	thread DiggerGenerator_PlayAnim( generator, "stopped_idle" )
}

function DiggerGenerator_PlayAnim( generator, animAlias )
{
	local player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )

	// Note, using PlayAnim caused weird blend pop on slightly rotated versions of the generator model
	local duration = generator.GetSequenceDuration( animAlias )

	generator.Anim_Play( animAlias )

	wait duration
}


// ===== GRINDER DOORS =====
function GrinderSetup()
{
	// DOORS
	local doornames = []
	doornames.append( "grinder_door_01" )
	doornames.append( "grinder_door_02" )
	foreach ( name in doornames )
	{
		local door = GetClientEnt_ByClassAndName( "prop_dynamic", name )
		level.grinderDoors.append( door )
	}

	level.grinderDoorAnims.open 		<- "open"
	level.grinderDoorAnims.openidle 	<- "open_idle"
	level.grinderDoorAnims.close 		<- "close"
	level.grinderDoorAnims.closedidle 	<- "close_idle"
	level.grinderDoorAnims.openTime 	<- level.grinderDoors[0].GetSequenceDuration( level.grinderDoorAnims.open )
	level.grinderDoorAnims.closedTime 	<- level.grinderDoors[0].GetSequenceDuration( level.grinderDoorAnims.close )

	level.grinderDoorsOpen = false
	thread GrinderDoors_Close( true )

	// ROLLERS
	level.grinderRoller = GetClientEnt_ByClassAndName( "prop_dynamic", "grinder_group_01" )
	level.grinderRoller.s.isOn <- false
	level.grinderRoller.s.sfxEnt <- CreateClientsideScriptMover( "models/dev/empty_model.mdl", level.grinderRollerOrigin, Vector( 0, 0, 0 ) )

	// WARNING LIGHTS
	local fxSpots = GetEntArrayByClassAndTargetname( "info_target_clientside", "warning_light_fx" )
	Assert( fxSpots.len() )
	local models = GetEntArrayByClassAndTargetname( "prop_dynamic", "warning_light_ON" )
	Assert( models.len() )
	// hacky - associate models with fxSpots so we don't have to link them in leveled
	foreach ( fxSpot in fxSpots )
	{
		local thismodel = null
		foreach ( model in models )
		{
			if ( Distance( model.GetOrigin(), fxSpot.GetOrigin() ) <= 5 )
			{
				thismodel = model
				break
			}
		}
		Assert( thismodel, "Couldn't find warning light model near origin " + fxSpot.GetOrigin() )

		AddScriptedFXSpot( "GrinderLights", fxSpot, level.FX_WARNING_LIGHT, false, thismodel, level.WARNING_LIGHT_ON_MODEL, level.WARNING_LIGHT_OFF_MODEL )
	}

	// Dirt FX
	local fxMap = []
	fxMap.append( { fxGroup = "GrinderFX_Dirtfall", tn = "info_particle_system_clientside_crusher_dirtfall_1", 	onFX = level.GRINDER_FX_DIRTFALL } )
	fxMap.append( { fxGroup = "GrinderFX_Dirtfall", tn = "info_particle_system_clientside_crusher_dirtfall_2", 	onFX = level.GRINDER_FX_DIRTFALL } )
	fxMap.append( { fxGroup = "GrinderFX_Rollers", 	tn = "info_particle_system_clientside_crusher_top", 		onFX = level.GRINDER_FX_TOP } )
	fxMap.append( { fxGroup = "GrinderFX_Rollers", 	tn = "info_particle_system_clientside_crusher_side_1", 		onFX = level.GRINDER_FX_SIDE } )
	fxMap.append( { fxGroup = "GrinderFX_Rollers", 	tn = "info_particle_system_clientside_crusher_side_2", 		onFX = level.GRINDER_FX_SIDE } )
	fxMap.append( { fxGroup = "GrinderFX_Rollers", 	tn = "info_particle_system_clientside_crusher_floor_1", 	onFX = level.GRINDER_FX_FLOOR } )
	local fxSpots = []
	foreach ( t in fxMap )
	{
		local fxSpot = GetClientEnt_ByClassAndName( "info_target_clientside", t.tn )
		AddScriptedFXSpot( t.fxGroup, fxSpot, t.onFX, false )  //Grinder_DirtFX
	}

	// screen shake
	local params = {}
	params.direction 	<- Vector( 0, 0, 0 )
	params.distClose 	<- 150
	params.distFar 		<- 280
	params.amplitudeMin <- 0.1  // if inside the radius at all it'll never be lower than this
	params.amplitudeMax <- 0.25
	params.frequency 	<- 16
	params.duration 	<- 1.0
	params.waittime 	<- 0.25
	local shakeOrg = level.grinderRollerOrigin
	AddScreenShake_DistanceScaled( "GrinderShake", shakeOrg, params )

	FlagSet( "GrinderSetupDone" )

	// now that we are setup, register var change callback and start thinking about state changes
	RegisterServerVarChangeCallback( "grinderOnTime", GrinderStateChangeCallback )
	RegisterServerVarChangeCallback( "grinderOffTime", GrinderStateChangeCallback )
}

function GrinderStateChangeCallback()
{
	if ( !Flag( "GrinderSetupDone" ) )
		return

	if ( IsWatchingKillReplay() )
		return

	Grinder_SetStateBasedOnTimestamps()
}
Globalize( GrinderStateChangeCallback )


function Grinder_SetStateBasedOnTimestamps()
{
	local onTime = level.nv.grinderOnTime
	local offTime = level.nv.grinderOffTime

	//printt( "Grinder on time:", onTime )
	//printt( "Grinder off time:", offTime )
	//printt( "Local view client CURR TIME:", Time() )

	local isOn = false
	if ( onTime > offTime )
		isOn = true

	// during kill replay, adjust for time of death
	if ( IsWatchingKillReplay() )
	{
		local player = GetLocalClientPlayer()
		Assert( TimeAdjustmentForRemoteReplayCall() != 0 ) // as covered in bug 37773
		local killReplayStartTime = player.cv.killReplayTimeOfDeath - TimeAdjustmentForRemoteReplayCall()

		//printt( "Kill replay remote call time adjustment:", TimeAdjustmentForRemoteReplayCall() )
		//printt( "Kill replay local player time of death:", killReplayStartTime )

		local timeToStateChange = -1

		if ( isOn )
		{
			// see if we actually have to start turned off
			if ( killReplayStartTime >= offTime && killReplayStartTime < onTime )
			{
				//printt( "Kill replay adjust: start turned OFF")
				isOn = false
				timeToStateChange = onTime - killReplayStartTime
			}
		}
		else
		{
			// see if we actually have to start turned on
			if ( killReplayStartTime >= onTime && killReplayStartTime < offTime )
			{
				//printt( "Kill replay adjust: start turned ON" )
				isOn = true
				timeToStateChange = offTime - killReplayStartTime
			}
		}

		if ( timeToStateChange > 0 )
			thread Grinder_ChangeStateDuringKillReplay( timeToStateChange, !isOn )
	}

	Grinder_SetState( isOn )
	//printt( "Grinder state set based on times:", level.grinderOn )
}

function Grinder_SetState( newState )
{
	Assert( type( newState ) == "bool" )

	if ( level.grinderOn == newState )
		return

	//printt( "Grinder state set:", newState )

	level.grinderOn = newState
	level.ent.Signal( "GrinderStateChange" )
}

function Grinder_ChangeStateDuringKillReplay( delay, newState )
{
	Assert( IsWatchingKillReplay() )

	local player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )

	wait delay

	//printt( "Grinder waited", delay, "secs before changing state to:", newState )
	Grinder_SetState( newState )
}

function GrinderStateChange_Think()
{
	level.grinderRoller.EndSignal( "OnDestroy" )

	local player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )

	level.ent.Signal( "GrinderStopThink" )
	level.ent.EndSignal( "GrinderStopThink" )

	//printt( "GrinderStateChange_Think: grinder starting on?", level.grinderOn )

	local doImmediateChange = true  // first state change is immediate, so we can be in that state ASAP for kill replay start

	// don't turn off the FX before the first on state if they're already turned on
	if ( !level.grinderOn )
	{
		ScriptedFXGroup_TurnOff( "GrinderLights", null, null, false )
		ScriptedFXGroup_TurnOff( "GrinderFX_Dirtfall", null, null, false )
		ScriptedFXGroup_TurnOff( "GrinderFX_Rollers", null, null, false )
	}

	local lastState = null

	while ( 1 )
	{
		lastState = level.grinderOn

		if ( level.grinderOn )
		{
			//printt( "Client grinder START, immediate change?", doImmediateChange )
			waitthread GrinderStart( doImmediateChange )
		}
		else
		{
			//printt( "Client grinder STOP, immediate change?", doImmediateChange )
			waitthread GrinderStop( doImmediateChange )
		}

		doImmediateChange = false

		// make sure state didn't change while waiting for spinup or spindown
		if ( lastState == level.grinderOn )
			level.ent.WaitSignal( "GrinderStateChange" )
	}
}

function GrinderStart( doImmediateChange )
{
	ScriptedFXGroup_TurnOn( "GrinderLights" )
	GrinderRollerStart( doImmediateChange )

	if ( !doImmediateChange )
	wait 0.4

	if ( doImmediateChange )
		ScriptedFXGroup_SwapOnFX( "GrinderFX_Dirtfall", level.GRINDER_FX_DIRTFALL_REPLAY )
	else
		ScriptedFXGroup_SwapOnFX( "GrinderFX_Dirtfall", level.GRINDER_FX_DIRTFALL )

	if ( !doImmediateChange )
	wait 0.1

	GrinderDoors_Open( doImmediateChange )

	if ( !doImmediateChange )
	wait 0.3

	ScriptedFXGroup_TurnOn( "GrinderFX_Rollers" )
}


function GrinderStop( doImmediateChange )
{
	thread GrinderRollerStop( doImmediateChange )

	// wait for the grinder to start the spindown animation
	while ( level.grinderRoller.s.isOn )
		wait 0.05

	thread GrinderDoors_Close( doImmediateChange )

	if ( !doImmediateChange )
		wait 0.3

	local useEndcap = true
	if ( doImmediateChange )
		useEndcap = false

	ScriptedFXGroup_TurnOff( "GrinderFX_Dirtfall", null, null, useEndcap )

	if ( !doImmediateChange )
	wait 0.7

	local shakeDelay = 0.5
	if ( doImmediateChange )
		shakeDelay = 0.0

	thread DisableScreenShake( "GrinderShake", shakeDelay )

	ScriptedFXGroup_TurnOff( "GrinderFX_Rollers", null, null, useEndcap )

	if ( !doImmediateChange )
	wait 1.0

	local lightsDelay = 1.0
	if ( doImmediateChange )
		lightsDelay = 0.0

	thread ScriptedFXGroup_TurnOff( "GrinderLights", lightsDelay, null, useEndcap )
}


// ===== GRINDER DOORS =====
function GrinderDoors_Open( doImmediateChange = false )
{
	if ( level.grinderDoorsOpen == true )
		return

	GrinderDoors_AnimStop()

	foreach ( door in level.grinderDoors )
		door.EndSignal( "OnDestroy" )

	//printt( "grinder doors opening" )

	if ( !doImmediateChange )
	{
	GrinderDoors_PlayAnim( "open", true, "DigSite_Scr_Grinder_DoorOpen" )
	wait level.grinderDoorAnims.openTime
	}

	level.grinderDoorsOpen = true

	GrinderDoors_PlayAnim( "openidle" )
}
Globalize( GrinderDoors_Open )


function GrinderDoors_Close( doImmediateChange = false )
{
	if ( level.grinderDoorsOpen == false )
		return

	GrinderDoors_AnimStop()

	foreach ( door in level.grinderDoors )
		door.EndSignal( "OnDestroy" )

	//printt( "grinder doors closing, immediate change?", doImmediateChange )

	if ( !doImmediateChange )
	{
		GrinderDoors_PlayAnim( "close", true, "DigSite_Scr_Grinder_DoorClose" )
		wait level.grinderDoorAnims.closedTime
	}

	level.grinderDoorsOpen = false

	GrinderDoors_PlayAnim( "closedidle" )
}
Globalize( GrinderDoors_Close )


function GrinderDoors_PlayAnim( animTableIdx, offsetStartTimes = false, sfx = null )
{
	Assert( animTableIdx in level.grinderDoorAnims )

	foreach ( idx, door in level.grinderDoors )
	{
		if ( offsetStartTimes && idx != 0 )
			wait RandomFloat( 0.08, 0.125 )

		thread PlayAnim( door, level.grinderDoorAnims[ animTableIdx ] )

		if ( sfx )
			EmitSoundOnEntity( door, sfx )
	}
}

function GrinderDoors_AnimStop()
{
	foreach ( door in level.grinderDoors )
		if ( IsValid( door ) )
			door.Anim_Stop()
}


// ===== GRINDER ROLLERS =====
function GrinderRollerStart( doImmediateChange = false )
{
	local player = GetLocalClientPlayer()
	player.EndSignal( "OnDestroy" )

	if ( level.grinderRoller.s.isOn )
		return

	level.grinderRoller.s.isOn = true

	//printt( "STARTING GRINDER ROLLER" )

	if ( doImmediateChange )
	{
		//local spinupTime = level.grinderRoller.GetSequenceDuration( "spinup" )
		local spinupTime = 3.333  // optimization- this anim isn't changing
		EmitSoundOnEntityWithSeek( level.grinderRoller.s.sfxEnt, "DigSite_Scr_Grinder_SpinUp", spinupTime )
	}
	if ( !doImmediateChange )
	{
		// Note- this sound has the spinup and the rolling sound (no idle loop, it is a one-shot)
		EmitSoundOnEntity( level.grinderRoller.s.sfxEnt, "DigSite_Scr_Grinder_SpinUp" )
		PlayAnim( level.grinderRoller, "spinup" )
	}

	EnableScreenShake( "GrinderShake" )

	thread GrinderRoller_SpinningIdle()
}

// do this so we can start the spindown animation without seeing a big pop
function GrinderRoller_SpinningIdle()
{
	level.grinderRoller.EndSignal( "OnDestroy" )

	level.ent.Signal( "GrinderRoller_SpinningIdle_Stop" )
	level.ent.EndSignal( "GrinderRoller_SpinningIdle_Stop" )

	while ( level.grinderRoller.s.isOn )
	{
		//printt( "spin start")
		PlayAnim( level.grinderRoller, "single_spin" )
		//printt( "spin done")

		level.grinderRoller.Signal( "GrinderRollerRotationDone" )
	}
}

function GrinderRollerStop( doInstantStop = false )
{
	local player = GetLocalClientPlayer()
	player.EndSignal( "OnDestroy" )

	if ( !level.grinderRoller.s.isOn )
		return

	level.grinderRoller.s.isOn = false

	if ( doInstantStop )
	{
		StopSoundOnEntity( level.grinderRoller.s.sfxEnt, "DigSite_Scr_Grinder_LP" )
	}
	else
	{
		//printt( "WAITING TO STOP GRINDER ROLLER" )
		level.grinderRoller.WaitSignal( "GrinderRollerRotationDone" )  // wait before flipping isOn
		//printt( "STOPPING GRINDER ROLLER" )

		FadeOutSoundOnEntity( level.grinderRoller.s.sfxEnt, "DigSite_Scr_Grinder_LP", 0.25 )
		EmitSoundOnEntity( level.grinderRoller.s.sfxEnt, "DigSite_Scr_Grinder_SpinDown" )
		PlayAnim( level.grinderRoller, "spindown" )
	}

	thread PlayAnim( level.grinderRoller, "stopped_idle" )
}
Globalize( GrinderRollerStop )


// ===== GOO PUMPS =====
function HarmonyMines_HardpointCreated( hardpoint, isRecreate )
{
	if ( isRecreate || GameRules.GetGameMode() != CAPTURE_POINT )
		return

	thread HarmonyMines_HardpointThink( hardpoint )
}

function HarmonyMines_HardpointThink( hardpoint )
{
	EndSignal( hardpoint, "OnDestroy" )
	FlagWait( "ClientInitComplete" )

	local hardpointID = hardpoint.GetHardpointID()

	while ( 1 )
	{
		local team = hardpoint.GetTeam()

		switch ( hardpointID )
		{
			// ALPHA- GOO PIPES ROOM
			case 0:
				switch ( team )
				{
					case level.HOME_TEAM:
						break

					case level.AWAY_TEAM:
						PumpGroupTurnOff( hardpointID )
						break

					default:
						PumpGroupTurnOn( hardpointID )
				}
				break

			case 1:
				break

			case 2:
				break

			default:
				Assert( true )
		}

		hardpoint.WaitSignal( "HardpointStateChanged" )
	}
}

function PumpsSetup()
{
	// for dev iteration
	//TryPumpsReset()

	local pump = {}
	pump.id 			<- 0  // hardpoint ID
	pump.fxOrg 			<- Vector( -2370, 768, 310 )
	pump.fxAng 			<- Vector( 0, 0, 0 )
	level.pumps.append( pump )

	local pump = {}
	pump.id 			<- 0  // hardpoint ID
	pump.fxOrg 			<- Vector( -2370, 321, 310 )
	pump.fxAng 			<- Vector( 0, 0, 0 )
	level.pumps.append( pump )

	foreach ( pump in level.pumps )
	{
		// TEMP for testing
		//DebugDrawAngles( pump.fxOrg, pump.fxAng, 10 )

		pump.fxOnStr 		<- FX_ENV_TRASH_TUBE_FAST_HLD
		pump.fxOffStr 		<- FX_ENV_TRASH_TUBE_SLOW_HLD
		pump.sndStart 		<- "DigSite_Scr_RockEnergyCylinder_Start"
		pump.sndLoop 		<- "DigSite_Scr_RockEnergyCylinder_Loop"
		pump.sndStop 		<- "DigSite_Scr_RockEnergyCylinder_Stop"
		pump.sndStopLoop 	<- "DigSite_Scr_RockEnergyCylinder_Diffuse_Loop"

		pump.on <- false

		pump.sndEnt <- CreateScriptRef( pump.fxOrg )

		pump.fxOn <- GetParticleSystemIndex( pump.fxOnStr )
		pump.fxOff <- GetParticleSystemIndex( pump.fxOffStr )

		if ( pump.on )
			pump.fx <- StartParticleEffectInWorldWithHandle( pump.fxOn, pump.fxOrg, pump.fxAng )
		else
			pump.fx <- StartParticleEffectInWorldWithHandle( pump.fxOff, pump.fxOrg, pump.fxAng )

		EffectSetDontKillForReplay( pump.fx )
	}

	if ( !IsCaptureMode() )
		thread PumpsCycle()
}
Globalize( PumpsSetup )


/*
function TryPumpsReset()
{
	if ( !level.pumps.len() )
		return

	foreach ( pump in level.pumps )
	{
		EffectStop( pump.fx, true, false )
		pump.sndEnt.Kill()
	}

	level.pumps = []
}
*/

function PumpGroupTurnOn( id )
{
	Assert( level.pumps.len() )

	foreach ( pump in level.pumps )
	{
		if ( pump.id != id )
			continue

		PumpTurnOn( pump )
	}
}

function PumpGroupTurnOff( id )
{
	Assert( level.pumps.len() )

	foreach ( pump in level.pumps )
	{
		if ( pump.id != id )
			continue

		PumpTurnOff( pump )
	}
}

function PumpTurnOn( pump )
{
	if ( pump.on )
		return

	pump.on = true
	EffectStop( pump.fx, false, true )
	pump.fx = StartParticleEffectInWorldWithHandle( pump.fxOn, pump.fxOrg, pump.fxAng )
	EffectSetDontKillForReplay( pump.fx )
	if ( "sndEnt" in pump )
	{
		if ( IsValid( pump.sndEnt ) )
		{
			StopSoundOnEntity( pump.sndEnt, pump.sndStopLoop )
			EmitSoundOnEntity( pump.sndEnt, pump.sndStart )
			EmitSoundOnEntity( pump.sndEnt, pump.sndLoop )
		}
	}
}

function PumpTurnOff( pump )
{
	if ( !pump.on )
		return

	//printt( "TURNING OFF PUMP", pump.id )

	pump.on = false
	EffectStop( pump.fx, false, true )
	pump.fx = StartParticleEffectInWorldWithHandle( pump.fxOff, pump.fxOrg, pump.fxAng )
	EffectSetDontKillForReplay( pump.fx )

	if ( "sndEnt" in pump )
	{
		if ( IsValid( pump.sndEnt ) )
		{
			StopSoundOnEntity( pump.sndEnt, pump.sndLoop )
			EmitSoundOnEntity( pump.sndEnt, pump.sndStop )
			EmitSoundOnEntity( pump.sndEnt, pump.sndStopLoop )
		}
	}
}

function PumpsCycle()
{
	level.ent.EndSignal( "DisablePumps" )

	while ( 1 )
	{
		PumpGroupTurnOn( 0 )
		wait( 40.0 )

		PumpGroupTurnOff( 0 )
		wait( 10.0 )
	}
}


// ===== WARNING LIGHTS =====
// NOTE consider genericizing
function AddScriptedFXSpot( fxGroup, fxSpot, onFX, startOn = false, prop = null, onModel = null, offModel = null )
{
	if ( !( fxGroup in level.scriptedFX ) )
		level.scriptedFX[ fxGroup ] <- []

	local t 		= {}
	t.fxSpot 		<- fxSpot
	t.prop 			<- prop
	t.fxGroup 		<- fxGroup

	t.onFX 			<- onFX
	t.modelname_ON 	<- onModel
	t.modelname_OFF <- offModel

	t.fxHandle 		<- null
	t.isOn 			<- !( startOn )

	level.scriptedFX[ fxGroup ].append( t )

	if ( startOn )
		ScriptedFX_TurnOn( t )
	else
		ScriptedFX_TurnOff( t )
}

function GetScriptedFXGroup( fxGroup )
{
	Assert( fxGroup in level.scriptedFX )

	return level.scriptedFX[ fxGroup ]
}
Globalize( GetScriptedFXGroup )


function ScriptedFXGroup_TurnOn( fxGroup, delayMin = null, delayMax = null )
{
	local arr = GetScriptedFXGroup( fxGroup )

	foreach ( light in arr )
		thread ScriptedFX_TurnOn( light, delayMin, delayMax )
}
Globalize( ScriptedFXGroup_TurnOn )


function ScriptedFXGroup_TurnOff( fxGroup, delayMin = null, delayMax = null, useEndcap = true )
{
	local arr = GetScriptedFXGroup( fxGroup )

	foreach ( light in arr )
		ScriptedFX_TurnOff( light, delayMin, delayMax, useEndcap )
}
Globalize( ScriptedFXGroup_TurnOff )


function ScriptedFXGroup_SwapOnFX( fxGroup, newFX, delayMin = null, delayMax = null )
{
	local arr = GetScriptedFXGroup( fxGroup )

	foreach ( light in arr )
		ScriptedFX_SwapFX( light, newFX, delayMin, delayMax )
}
Globalize( ScriptedFXGroup_SwapOnFX )


function ScriptedFX_SwapFX( light, newFX, delayMin = null, delayMax = null )
{
	light.isOn = false
	light.onFX = newFX
	ScriptedFX_TurnOn( light, delayMin, delayMax )
}

function ScriptedFX_TurnOn( light, delayMin = null, delayMax = null )
{
	if ( light.isOn )
	{
		// make sure the effect is really playing like we think it is
		if ( light.fxHandle == null || !EffectDoesExist( light.fxHandle ) )
			light.isOn = false
		else
			return
	}

	if ( delayMin != null && delayMin >= 0 )
	{
		local waittime = delayMin
		if ( delayMax > delayMin )
			waittime = RandomFloat( delayMin, delayMax )

		if ( waittime > 0 )
		{
			wait waittime

			if ( !IsValid( light.fxSpot ) )
				return
		}
	}

	ScriptedFX_StopFX( light )  // stop any existing fx here before we play another one

	light.isOn = true
	light.fxHandle = StartParticleEffectInWorldWithHandle( light.onFX, light.fxSpot.GetOrigin(), light.fxSpot.GetAngles() )

	EffectSetDontKillForReplay( light.fxHandle )

	if ( IsValid( light.prop ) )
	{
		//printt( "swapping model on light prop to ON" )
		light.prop.SetModel( light.modelname_ON )
	}
}

function ScriptedFX_TurnOff( light, delayMin = null, delayMax = null, useEndcap = true )
{
	if ( !light.isOn )
		return

	if ( delayMin != null && delayMin >= 0 )
	{
		local waittime = delayMin
		if ( delayMax > delayMin )
			waittime = RandomFloat( delayMin, delayMax )

		if ( waittime > 0 )
		{
			wait waittime

			if ( !IsValid( light.fxSpot ) )
				return
		}
	}

	light.isOn = false

	ScriptedFX_StopFX( light, useEndcap )

	if ( IsValid( light.prop ) )
	{
		//printt( "swapping model on light prop to OFF:", light.modelname_OFF )
		light.prop.SetModel( light.modelname_OFF )
	}
}

function ScriptedFX_StopFX( light, useEndcap = true )
{
	if ( light.fxHandle != null )
	{
		if ( EffectDoesExist( light.fxHandle ) )
		{
			if ( useEndcap )
				EffectStop( light.fxHandle, false, true )  // effect, doRemoveAllParticlesNow, doPlayEndCap
			else
				EffectStop( light.fxHandle, true, false )
		}

		light.fxHandle = null
	}
}


// ===== SCREEN SHAKE =====
// Does screen shake that scales based on distance to a static location
// Handles multiple spots - if overlapping, spot that would create highest amplitude at that location wins
//
// NOTE consider genericizing
function PlayerScreenShakeThink( player )
{
	local player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )

	local defaultWait = 0.1

	while ( 1 )
	{
		if ( !PlayerScreenCanShake( player ) )
		{
			wait defaultWait
			continue
		}

		local result = ScreenShake_GetStrongestEnabled( player )
		if ( !result )
		{
			wait defaultWait
			continue
		}

		local shakeTable = result.shakeTable
		local direction = shakeTable.params.direction

		//printt( shakeTable.alias, "amplitude", result.amplitude, "distance", result.dist )
		//DebugDrawAngles( shakeTable.org, direction, shakeTable.params.waittime )

		ClientScreenShake( result.amplitude, shakeTable.params.frequency, shakeTable.params.duration, direction )

		wait shakeTable.params.waittime
	}
}

function PlayerScreenCanShake( player )
{
	if ( !IsAlive( player ) )
		return false

	// only do it on pilots
	if ( player.IsTitan() )
		return false

	// flights past it can be smooth
	if ( !player.IsOnGround() )
		return false

	return true
}

function ScreenShake_GetStrongestEnabled( player )
{
	local shakeTable = null
	local highestAmp = null
	local distToShake = null
	local playerOrg = player.EyePosition()

	foreach( t in level.screenShakes )
	{
		if ( !t.enabled )
			continue

		local params = t.params
		local dist = Distance( t.org, playerOrg )

		if ( dist > params.distFar )
			continue

		local amp = GraphCapped( dist, t.params.distClose, t.params.distFar, t.params.amplitudeMax, t.params.amplitudeMin )

		if ( highestAmp == null || amp > highestAmp )
		{
			shakeTable = t
			highestAmp = amp
			distToShake = dist
		}
	}

	if ( !shakeTable )
		return null

	// send along some values so we don't have to calculate them again
	local rt = { shakeTable = shakeTable, dist = distToShake, amplitude = highestAmp }
	return rt
}

function AddScreenShake_DistanceScaled( alias, shakeOrg, params, group = null )
{
	Assert( !ScreenShakeExists( alias ), "Tried to set up screen shake alias twice, alias: " + alias )
	Assert( alias != group, "Shouldn't name alias the same as the group: " + alias )
	foreach ( t in level.screenShakes )
		Assert( t.group != alias, "Tried to use alias " + alias + " that was already the name of a group.")

	local shakeTable = { alias = alias, org = shakeOrg, params = params, enabled = false, group = group }
	level.screenShakes[ alias ] <- shakeTable
}

function ScreenShakeExists( alias )
{
	return ( alias in level.screenShakes )
}

function EnableScreenShake( alias )
{
	ScreenShake_SetEnabled( alias, true )
}
Globalize( EnableScreenShake )


function DisableScreenShake( alias, delay = null )
{
	local player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( player, alias )
		{
			if ( IsValid( player ) )
				ScreenShake_SetEnabled( alias, false )
		}
	)

	if ( delay )
		wait delay
}
Globalize( DisableScreenShake )


// can set enabled by alias name or group name
function ScreenShake_SetEnabled( alias, isEnabled )
{
	local matchingShakes = GetScreenShakesByAliasOrGroup( alias )

	foreach ( t in matchingShakes )
	{
		if ( t.enabled != isEnabled )
		{
			t.enabled = isEnabled
			//printt( "shake", t.alias, "set enabled:", t.enabled )
		}
	}
}

function GetScreenShakesByAliasOrGroup( alias )
{
	local matchingShakes = []

	if ( alias in level.screenShakes )
	{
		// first try to match alias
		matchingShakes.append( level.screenShakes[ alias ] )
	}
	else
	{
		// try to find by group
		foreach ( shake in level.screenShakes )
		{
			if ( shake.group == alias )
				matchingShakes.append( shake )
		}
	}

	Assert( matchingShakes.len(), "Couldn't match screen shake by alias or group, tried: " + alias )

	return matchingShakes
}

// --------------------
// 	    MISC STUFF
// --------------------
function StopFXArray( fxArrayToStop )
{
	foreach ( handle in fxArrayToStop )
	{
		//  handle, doRemoveAllParticlesNow, doPlayEndCap
		if ( EffectDoesExist( handle ) )
			EffectStop( handle, false, true )
	}
}

function GetClientEnt_ByClassAndName( classname, name )
{
	local arr = GetEntArrayByClassAndTargetname( classname, name )
	Assert( arr.len() == 1, "Couldn't find 1 ent with classname " + classname + " named " + name + ". Instead found " + arr.len() )

	return arr[0]
}
Globalize( GetClientEnt_ByClassAndName )


//ScriptReload()
