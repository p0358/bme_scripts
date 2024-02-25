const SHIP_LIGHT_ON_MODEL		= "models/IMC_base/light_wall_IMC_01_on.mdl"
const SHIP_LIGHT_OFF_MODEL		= "models/IMC_base/light_wall_IMC_01.mdl"
const WARNING_LIGHT_ON_MODEL	= "models/lamps/warning_light_ON_orange.mdl"
const WARNING_LIGHT_OFF_MODEL 	= "models/lamps/warning_light.mdl"

enum eFxType
{
	FX_ELECTRIC_ARC
	FX_ELECTRIC_ARC_LG
	FX_ELECTRIC_SPARK
	FX_SPARK_LOOP
	FX_PIPE_STEAM_MED
	FX_PIPE_STEAM
	FX_PIPE_FIRE
	FX_SHIP_LIGHT
	FX_WARNING_LIGHT
	FX_WARNING_LIGHT_DL
	FX_STEAM_TURB
}

function main()
{
	if ( IsServer() )
		return

	level.fxID <- {}
	level.fxID[ eFxType.FX_ELECTRIC_ARC ]		<- PrecacheParticleSystem( "P_elec_arc_loop_1" )
	level.fxID[ eFxType.FX_ELECTRIC_ARC_LG ]	<- PrecacheParticleSystem( "P_elec_arc_loop_LG_1" )
	level.fxID[ eFxType.FX_ELECTRIC_SPARK ]		<- PrecacheParticleSystem( "P_env_sparks_dir_1" )
	level.fxID[ eFxType.FX_SPARK_LOOP ]			<- PrecacheParticleSystem( "P_sparks_dir_MD_LOOP" )
	level.fxID[ eFxType.FX_PIPE_STEAM_MED ]		<- PrecacheParticleSystem( "P_veh_relic_steam_MD" )
	level.fxID[ eFxType.FX_PIPE_STEAM ]			<- PrecacheParticleSystem( "P_steam_leak_LG" )
	level.fxID[ eFxType.FX_PIPE_FIRE ]			<- PrecacheParticleSystem( "P_fire_jet_med" )
	level.fxID[ eFxType.FX_SHIP_LIGHT ]			<- PrecacheParticleSystem( "industrial_wall_light" )
	level.fxID[ eFxType.FX_WARNING_LIGHT ]		<- PrecacheParticleSystem( "warning_light_orange_blink" )
	level.fxID[ eFxType.FX_WARNING_LIGHT_DL ]	<- PrecacheParticleSystem( "warning_light_orange_blink_RT" )
	level.fxID[ eFxType.FX_STEAM_TURB ]			<- PrecacheParticleSystem( "P_relic_steam_turb" )

	level.fxOffset <- {}
	level.fxOffset[ eFxType.FX_ELECTRIC_ARC ] <- 0
	level.fxOffset[ eFxType.FX_ELECTRIC_ARC_LG ] <- 0
	level.fxOffset[ eFxType.FX_ELECTRIC_SPARK ] <- 0
	level.fxOffset[ eFxType.FX_SPARK_LOOP ] <- 0

	level.fxSoundTableStart <- {}
	level.fxSoundTableStart[ eFxType.FX_STEAM_TURB ]		<- "Relic_Scr_ShipVent_Start"

	level.fxSoundTable <- {}
	level.fxSoundTable[ eFxType.FX_SPARK_LOOP	 ]	<- [ "Amb_Relic_Emit_Electrical_Wire" ]
	level.fxSoundTable[ eFxType.FX_PIPE_STEAM_MED ]	<- [ "amb_boneyard_emitter_steam_medium",
														 "amb_boneyard_emitter_steam_small" ]
	level.fxSoundTable[ eFxType.FX_PIPE_STEAM ]		<- [ "amb_boneyard_emitter_steam_medium",
														 "amb_boneyard_emitter_steam_large" ]
	level.fxSoundTable[ eFxType.FX_STEAM_TURB ]		<- [ "Relic_Scr_ShipVent_Loop" ]

	level.uniqueIndex <- 0
	level.shipSpeakers <- []
	level.shipLightArray <- []
	level.warningLightArray <- []
	level.sparkFXArray <- []
	level.pipeFXArray <- []
	level.ventFXArray <- []
	level.exhaustFXArray <- []

	Globalize( AddGroupFx )

	// rough fx placement tool
	Globalize( CreateFxGroup )
	Globalize( EditorAddFx )
	Globalize( EditorPlayLastSet )
	Globalize( EditorPlayGroup )
	Globalize( EditorShowSets )
	Globalize( EditorDeleteSet )
	Globalize( EditorSaveFxGroups )
	Globalize( ShipElectricBurstFx )

	Globalize( CE_VisualSettingRelicIMC )
	Globalize( CE_VisualSettingRelicMCOR )

	RegisterSignal( "EndEditorShow" )
	level.currentfxGroup	<- "mid"
	level.currentSetindex	<- 1
	level.lastSetStartTime	<- Time()
	level.lastSetAddTime	<- Time()
	level.fxDelay			<- 0.33

	IncludeFile( "client/levels/cl_mp_relic_fx.nut" )

	RegisterServerVarChangeCallback( "shipSpeakers", UpdateShipSpeakers )
	RegisterServerVarChangeCallback( "shipLights", UpdateShipLights )
	RegisterServerVarChangeCallback( "shipFx", UpdateShipFx )

	RegisterSignal( "ResetVDU" )
	RegisterSignal( "EndElectricBurst" )
	RegisterSignal( "StopShipSpeakers" )

	level.leftEngine		<- null
	level.rightEngine		<- null
	level.povModel			<- null
	level.introDropship		<- null

	AddCreateCallback( "engine_front_left", LeftEngineCreated )
	AddCreateCallback( "engine_front_right", RightEngineCreated )
	AddCreateCallback( "pov_model", PovModelCreated )
	AddCreateCallback( "introDropship", IntroDropshipCreated )


	SetupRumble()
	SetFullscreenMinimapParameters( 3.7, 400, -3800, 180)
	if ( GAMETYPE == COOPERATIVE )
		SetCustomMinimapZoom( 2 )
	
	if ( !GetCinematicMode() )
		return

	IntroScreen_Setup()
}

function EntitiesDidLoad()
{
	SetupShipLights()
	SetupClientSideFx()
	SetupShipSpeakers()
}

/*--------------------------------------------------------------------------------------------------------*\
|
|													INTRO
|
\*--------------------------------------------------------------------------------------------------------*/

function IntroScreen_Setup()
{
	local imc_line_1 = "#INTRO_SCREEN_RELIC_LINE1"
	local imc_line_2 = "#INTRO_SCREEN_RELIC_LINE2"

	local mcor_line_1 = imc_line_1
	local mcor_line_2 = imc_line_2

	CinematicIntroScreen_SetText( TEAM_IMC, [ imc_line_1, imc_line_2 ] )
	CinematicIntroScreen_SetText( TEAM_MILITIA, [ mcor_line_1, mcor_line_2 ] )
}

/*--------------------------------------------------------------------------------------------------------*\
|
|													SHIP
|
\*--------------------------------------------------------------------------------------------------------*/

function SetupShipLights()
{
	level.shipLightArray = GetClientEntArray( "prop_dynamic", "ship_light" )
	local shipLightFxArray = GetClientEntArray( "info_target_clientside", "ship_light_fx" )

	level.warningLightArray = GetClientEntArray( "prop_dynamic", "warning_light" )
	local warningLightFxArray = GetClientEntArray( "info_target_clientside", "warning_light_fx" )

	foreach ( model in level.shipLightArray )
		model.SetFadeDistance( 2500 )

	foreach ( model in level.warningLightArray )
		model.SetFadeDistance( 1500 )

	local lightArray = clone level.shipLightArray
	lightArray.extend( level.warningLightArray )
	local center = Vector( 0, -5920, 800 )
	foreach( ent in lightArray )
	{
		local dist = Distance( center, ent.GetOrigin() )
		ent.s.delay <- Graph( dist, 1000, 5500, 0, 8 )
	}

	PairFxWithEntity( level.shipLightArray, shipLightFxArray, level.fxID[ eFxType.FX_SHIP_LIGHT ] )
	PairFxWithEntity( level.warningLightArray, warningLightFxArray, level.fxID[ eFxType.FX_WARNING_LIGHT ] )

	AssignModels( level.shipLightArray, SHIP_LIGHT_ON_MODEL, SHIP_LIGHT_OFF_MODEL )
	AssignModels( level.warningLightArray, WARNING_LIGHT_ON_MODEL, WARNING_LIGHT_OFF_MODEL )

	UpdateShipLights()
}

function UpdateShipLights()
{
//	printt( "UpdateShipLights", level.nv.shipLights )
	local active = level.nv.shipLights

	local lightArray = clone level.shipLightArray
	lightArray.extend( level.warningLightArray )

	if ( active )
	{
		foreach( light in lightArray )
			thread TurnLightOn( light )
	}
	else
	{
		foreach( light in lightArray )
			thread TurnLightOff( light )
	}

	// spark fx starting when the power is turned on
	local fxEntArray = level.sparkFXArray
	foreach( fxEnt in fxEntArray )
		thread AmbientFxOnOff( fxEnt, active, false )

	if  ( active )
	{
		thread ShipElectricBurstFx( "aft" )
		delaythread( 3 ) ShipElectricBurstFx( "mid" )
		delaythread( 6 ) ShipElectricBurstFx( "fore" )

		delaythread( 10 ) ShipElectricBurstThink()
	}
	else
	{
		level.ent.Signal( "EndElectricBurst" )
	}

}

function TurnLightOff( lightModel, instant = false )
{
	local player = GetLocalViewPlayer()
	if ( !IsWatchingKillReplay() && !instant )
		wait RandomFloat( 0, 2.0 )

	lightModel.SetModel( lightModel.s.offModel )
	if ( lightModel.s.fxHandle )
	{
		EffectStop( lightModel.s.fxHandle, false, true )
		lightModel.s.fxHandle = null
	}
}

function TurnLightOn( lightModel, instant = false )
{
	// dsync the lights a bit
	if ( !IsWatchingKillReplay() && !instant )
		wait lightModel.s.delay

	lightModel.SetModel( lightModel.s.onModel )

	local origin = lightModel.s.fxEnt.GetOrigin()
	local angles = lightModel.s.fxEnt.GetAngles()

	lightModel.s.fxHandle = StartParticleEffectInWorldWithHandle( lightModel.s.fxID, origin, angles )
	EffectSetDontKillForReplay( lightModel.s.fxHandle )
}

function LeftEngineCreated( entity, isRecreate )
{
	AddAnimEvent( entity, "relic_screen_rumble", EngineScreenRumble )
	AddAnimEvent( entity, "relic_screen_shake_minor", EngineScreenShake, 0.5 )
	AddAnimEvent( entity, "relic_screen_shake_medium", EngineScreenShake, 1.0 )
	AddAnimEvent( entity, "relic_screen_shake_major", EngineScreenShake, 3.0 )

	AddAnimEvent( entity, "relic_controller_rumble", EngineControllerRumble )

	level.leftEngine = entity
}

function RightEngineCreated( entity, isRecreate )
{
	AddAnimEvent( entity, "relic_screen_rumble", EngineScreenRumble )
	AddAnimEvent( entity, "relic_screen_shake_minor", EngineScreenShake, 0.5 )
	AddAnimEvent( entity, "relic_screen_shake_medium", EngineScreenShake, 1.0 )
	AddAnimEvent( entity, "relic_screen_shake_major", EngineScreenShake, 3.0 )

	AddAnimEvent( entity, "relic_controller_rumble", EngineControllerRumble )

	level.rightEngine = entity
}

function SetupShipSpeakers()
{
	level.shipSpeakers = GetClientEntArray( "info_target_clientside", "ship_speaker" )
	thread UpdateShipSpeakers()
}

function UpdateShipSpeakers()
{
	thread UpdateShipSpeakersThread()
}

function UpdateShipSpeakersThread()
{
	level.ent.Signal( "StopShipSpeakers" )
	level.ent.EndSignal( "StopShipSpeakers" )

	local active = level.nv.shipSpeakers

	if ( !active )
		return

	local aliasList = []
	aliasList.append( { alias = "diag_relicDiagnostics_RC201_02_01_neut_relicos", weight = 1 } )
	aliasList.append( { alias = "diag_relicDiagnostics_RC201_03_01_neut_relicos", weight = 1 } )
	aliasList.append( { alias = "diag_relicDiagnostics_RC201_04_01_neut_relicos", weight = 1 } )
	aliasList.append( { alias = "diag_relicDiagnostics_RC201_05_01_neut_relicos", weight = 1 } )
	aliasList.append( { alias = "diag_relicDiagnostics_RC201_06_01_neut_relicos", weight = 1 } )
	aliasList.append( { alias = "diag_relicDiagnostics_RC201_07_01_neut_relicos", weight = 1 } )
	aliasList.append( { alias = "diag_relicDiagnostics_RC201_08_01_neut_relicos", weight = 1 } )
	aliasList.append( { alias = "diag_relicDiagnostics_RC201_09_01_neut_relicos", weight = 1 } )

	local totalWeight = 0.0
	foreach( aliasTable in aliasList )
		totalWeight += aliasTable.weight

	local alias
	while( true )
	{
		local roll = RandomFloat( 0, 1 )
		local weight = 0

		foreach( aliasTable in aliasList )
		{
			weight += aliasTable.weight
			if ( roll > ( weight.tofloat() / totalWeight ) )
				continue

			alias = aliasTable.alias
			break
		}

		foreach( speaker in level.shipSpeakers )
		{
			if ( GetBugReproNum() == 1970 )
				DebugDrawText( speaker.GetOrigin(), alias, false, GetSoundDuration( alias ) )
			EmitSoundOnEntity( speaker, alias )
		}

		local duration = GetSoundDuration( alias )
		wait duration
		wait RandomFloat( 10, 30 )
	}
}
/*--------------------------------------------------------------------------------------------------------*\
|
|												FX
|
\*--------------------------------------------------------------------------------------------------------*/


function SetupClientSideFx()
{
	level.sparkFXArray	 = GetClientEntArray( "info_target_clientside", "ship_sparks" )
	level.pipeFXArray	 = GetClientEntArray( "info_target_clientside", "ship_pipe" )
	level.ventFXArray	 = GetClientEntArray( "info_target_clientside", "ship_vent" )
	level.exhaustFXArray = GetClientEntArray( "info_target_clientside", "ship_exhaust" )

	PrimeClientsideFxEnts( level.sparkFXArray, eFxType.FX_SPARK_LOOP , true )
	PrimeClientsideFxEnts( level.pipeFXArray, eFxType.FX_PIPE_STEAM_MED , true )
	PrimeClientsideFxEnts( level.ventFXArray, eFxType.FX_PIPE_STEAM , true )
	PrimeClientsideFxEnts( level.exhaustFXArray, eFxType.FX_STEAM_TURB, true )

	UpdateShipFx()
}

function PrimeClientsideFxEnts( FxEntArray, fxTypeID, persistent )
{
	foreach( fxEnt in FxEntArray )
	{
		fxEnt.s.fxID		<- level.fxID[ fxTypeID ]
		fxEnt.s.fxHandle	<- null
		fxEnt.s.index		<- level.uniqueIndex++
		fxEnt.s.startSound	<- null
		fxEnt.s.sound		<- null
		fxEnt.s.soundActive	<- false
		fxEnt.s.persistent	<- persistent

		level.fxSoundTableStart

		if ( fxTypeID in level.fxSoundTableStart )
		{
			local startSound = level.fxSoundTableStart[ fxTypeID ]
			fxEnt.s.startSound = startSound
		}

		if ( fxTypeID in level.fxSoundTable )
		{
			local soundArray = level.fxSoundTable[ fxTypeID ]
			local sound = soundArray[ fxEnt.s.index % soundArray.len() ]
			fxEnt.s.sound = sound
		}
	}
}

function UpdateShipFx()
{
//	printt( "UpdateShipFx", level.nv.shipFx )

	local active = level.nv.shipFx

	// vent, pipe and exhaust fx starting when the engines are turned on
	local fxEntArray = clone level.ventFXArray
	fxEntArray.extend( level.pipeFXArray )
	fxEntArray.extend( level.exhaustFXArray )

	foreach( fxEnt in fxEntArray )
		thread AmbientFxOnOff( fxEnt, active, false )
}

function EngineScreenRumble( engine = null )
{
	thread EngineScreenRumbleThread( engine )
}

function EngineScreenRumbleThread( engine )
{
	local player = GetLocalViewPlayer()

	if ( !IsAlive( player ) )
		return

	local minDist = 512
	local maxDist = 2048
	local amplitude	= 1
	local frequency	= 10
	local duration	= 3.0

	local id = engine.LookupAttachment( "R_exhaust_side_1" )
	local origin = engine.GetAttachmentOrigin( id )

	local dist = Distance( origin, player.GetOrigin() )
	local frac = GraphCapped( dist, minDist, maxDist, 1, 0 )
	frac = pow( frac, 2 )

	ClientScreenShake( amplitude * frac, frequency, duration, Vector( 0,0,0 ) )
//	printt( "rumble", frac, dist )
}

function EngineScreenShake( engine, strength )
{
	EngineScreenShakeThread( engine, strength )
}

function EngineScreenShakeThread( engine, strength )
{
	// meant to fire of whenever the engine shakes significantly.
	// should be accompanied by fx and sound
	local player = GetLocalViewPlayer()

	if ( !IsAlive( player ) )
		return

	local minDist = 512
	local maxDist = 2048
	local amplitude	= 10
	local frequency	= 13
	local duration	= 2.5

	local id = engine.LookupAttachment( "R_exhaust_side_1" )
	local origin = engine.GetAttachmentOrigin( id )

	local dist = Distance( origin, player.GetOrigin() )
	local frac = GraphCapped( dist, minDist, maxDist, 1, 0 )
	frac = pow( frac, 2 ) * strength

	ClientScreenShake( amplitude * frac, frequency, duration, Vector( 0, 0, 0 ) )
//	printt( "shake", strength, frac )
}

function EngineControllerRumble( engine )
{
	local id = engine.LookupAttachment( "R_exhaust_side_1" )
	local origin = engine.GetAttachmentOrigin( id )
//	printt( "Rumble controller at location", origin )

	Rumble_Play( "EngineIdleRumble" , { position = origin } )
}

function SetupRumble()
{
	local low = [  Vector( 0.0, 0.0 ), Vector( 4.3, 0.0 ) ]
	local high = [ Vector( 0.0, 0.2 ), Vector( 4.3, 0.2 ) ]
	local leftTrigger = []
	local rightTrigger = []

	Rumble_CreateGraph( "EngineIdleGraph", low, high, leftTrigger, rightTrigger )

	local params		= {}
	params.name			<- "EngineIdleGraph"
	params.position		<- Vector( 0, 0, 0 )
	params.scaleMin		<- 1	// min is max, probably wrong in code. Need to Bug
	params.scaleMax		<- 0	// max is min
	params.distanceMin	<- 256
	params.distanceMax	<- 2048
//	params.loop			<- 1

	Rumble_CreatePlayParams( "EngineIdleRumble", params )
}

function PairFxWithEntity( entityArray, fxArray, fxID, maxDist = 32 )
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
				entity.s.fxEnt		<- fxEnt
				entity.s.fxID		<- fxID
				entity.s.fxHandle 	<- null
				entity.s.index		<- level.uniqueIndex++
				fxArray.remove( index )
				break
			}
		}
	}
}

function AssignModels( entArray, onModel, offModel )
{
	foreach( ent in entArray )
	{
		ent.s.onModel <- onModel
		ent.s.offModel <- offModel
	}
}

function AmbientFxOnOff( fxEnt, active, instant )
{
	if  ( !instant )
	{
		if ( active )
			wait RandomFloatCurve( 0, 8 )
		else
			wait RandomFloatCurve( 0, 4 )
	}

	// don't activate one-off fx when instant is true
	if ( instant && !fxEnt.persistent )
			return

	if ( active )
	{
		if ( fxEnt.s.fxHandle )
			return
		local origin = fxEnt.GetOrigin()
		local angles = fxEnt.GetAngles()
		fxEnt.s.fxHandle <- StartParticleEffectInWorldWithHandle( fxEnt.s.fxID, origin, angles )
		EffectSetDontKillForReplay( fxEnt.s.fxHandle )

		if ( fxEnt.s.startSound && !fxEnt.s.soundActive )
			EmitSoundOnEntity( fxEnt, fxEnt.s.startSound )

		if ( fxEnt.s.sound && !fxEnt.s.soundActive )
		{
			EmitSoundOnEntity( fxEnt, fxEnt.s.sound )
			thread DebugDrawSoundName( fxEnt, fxEnt.s.sound )
			fxEnt.s.soundActive = true
		}
	}
	else
	{
		if ( !fxEnt.s.fxHandle )
			return

		EffectStop( fxEnt.s.fxHandle, false, true )
		fxEnt.s.fxHandle = null
		if ( fxEnt.s.sound && fxEnt.s.soundActive )
		{
			StopSoundOnEntity( fxEnt, fxEnt.s.sound )
			fxEnt.s.soundActive = false
			fxEnt.Signal( "stop_sound" )
		}
	}
}

function ShipElectricBurstThink()
{
	level.ent.Signal( "EndElectricBurst" )
	level.ent.EndSignal( "EndElectricBurst" )

	while( true )
	{
		wait RandomFloat( 10.0, 10.0 )
		local charge = GraphCapped( level.nv.matchProgress, 30, 80, 0.25, 1.0 )
		charge = pow( charge, 1.5 )

		thread ShipElectricBurstFx( "aft", charge )
		delaythread( 3 ) ShipElectricBurstFx( "mid", charge )
		delaythread( 6 ) ShipElectricBurstFx( "fore", charge )
	}
}

function ShipElectricBurstFx( fxGroup, charge = 1.0 )
{
	Assert( charge <= 1 )
	Assert( fxGroup in level.fxGroups )

	local setList = level.fxGroups[ fxGroup ]
	local size = ceil( setList.len() * charge )
	local setIDArray = GetRandomSetIDArray( setList, size )
	local maxDelay = 6.0 * charge

	foreach ( index, setID in setIDArray )
	{
		local delay = pow( index, 2 ).tofloat() / pow( size, 2 ).tofloat() * maxDelay
		local origin = GetFxGroupSetOrigin( fxGroup, setID )
		delaythread( delay ) EmitSoundAtPosition( origin, "boneyard_hardpoint_imc_overload_electricity" )
		delaythread( delay ) PlayFxGroupSet( fxGroup, setID )
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
|												VDU Events
|
\*--------------------------------------------------------------------------------------------------------*/

function PovModelCreated( entity, isRecreate )
{
	level.povModel = entity
}

function IntroDropshipCreated( entity, isRecreate )
{
	level.introDropship = entity
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

/*--------------------------------------------------------------------------------------------------------*\
|
|										FX PLACEMENT EDITOR
|
\*--------------------------------------------------------------------------------------------------------*/

function CreateFxGroup( fxGroup )
{
	level.currentfxGroup = fxGroup
}

function EditorDeleteSet( setID = null )
{
	if ( !setID )
		setID = format( "fxSet%03d", level.currentSetindex )

	if ( "fxGroups" in level )
	{
		// remove old data set
		if ( setID in level.fxGroups[ level.currentfxGroup ] )
		{
			printt( "removing", setID )
			delete level.fxGroups[ level.currentfxGroup ][ setID ]
			level.currentSetindex = max( 1, level.currentSetindex - 1 )
		}
	}
}

function EditorAddFx( fxTypeID )
{
	if ( !level.currentfxGroup )
	{
		printt( "No fx group selected" )
		return
	}

	local time = Time()
	local delay = time - level.lastSetStartTime
	local gap = time - level.lastSetAddTime
	level.lastSetAddTime = Time()

	if ( gap > 3.0 )
	{
		// create a new set name
		if ( "fxGroups" in level && level.currentfxGroup in level.fxGroups )
			level.currentSetindex = level.fxGroups[ level.currentfxGroup ].len() + 1
		else
			level.currentSetindex = 1

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

	delay *= level.fxDelay // play back at a faster speed
	delay = format( "%1.3f", delay ).tofloat()
	origin = Vector( format( "%1.3f", origin.x ).tofloat(), format( "%1.3f", origin.y ).tofloat(), format( "%1.3f", origin.z ).tofloat() )

	local origin2  = origin + vector * 64
//	DebugDrawLine( origin, origin + Vector( 0,0,32 ), 255, 0, 0, true, 5.0 )
//	DebugDrawLine( origin, origin2, 255, 0, 255, true, 5.0 )

	AddGroupFx( level.currentfxGroup, setID, fxTypeID, origin, angles, delay )
	StartParticleEffectInWorld( level.fxID[ fxTypeID ], origin, angles )
}

function EditorPlayLastSet()
{
	if ( !( "fxGroups" in level ) )
		return

	thread PlayFxGroupSet( level.currentfxGroup, format( "fxSet%03d", level.currentSetindex ) )
}

function EditorPlayGroup( fxGroup = null )
{
	if ( !( "fxGroups" in level ) )
		return

	if ( !fxGroup )
		fxGroup = level.currentfxGroup

	foreach( setID, setData in level.fxGroups[ fxGroup ] )
	{
		local duration = PlayFxGroupSet( fxGroup, setID )
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

	if ( !( "fxGroups" in level ) )
		return

	while( true )
	{
		foreach( name, fxGroup  in level.fxGroups )
		{
			foreach( setID, setData in fxGroup )
			{
				local fx = level.fxGroups[ name ][ setID ][0]
				if ( name == level.currentfxGroup )
				{
					DebugDrawText( fx.origin, setID, false, 0.15 )
					DrawLineBox( fx.origin, fx.angles, Vector( 4, 4, 4 ), 96, 0, 0, 0.15 )
				}
				else
				{
					DrawLineBox( fx.origin, fx.angles, Vector( 4, 4, 4 ), 0, 196, 196, 0.15 )
				}
			}
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

function PlayFxGroupSet( fxGroup, setID )
{
	if ( !( setID in level.fxGroups[ fxGroup ] ) )
		return 0.0

	local startOrigin = null
	local duration = 0
	local setData = level.fxGroups[ fxGroup ][ setID ]
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

function GetFxGroupSetOrigin( fxGroup, setID )
{
	Assert( setID in level.fxGroups[ fxGroup ] )
	local setData = level.fxGroups[ fxGroup ][ setID ]
	Assert( setData.len() )
	return setData[0].origin
}

function AddGroupFx( fxGroup, setID, fxTypeID, origin, angles, delay )
{
	if ( !( "fxGroups" in level ) )
		level.fxGroups <- {}

	if ( !( fxGroup in level.fxGroups ) )
		level.fxGroups[ fxGroup ] <- {}

	if ( !( setID in level.fxGroups[ fxGroup ] ) )
		level.fxGroups[ fxGroup ][ setID ] <- []

	local setFxArray = level.fxGroups[ fxGroup ][ setID ]

	setFxArray.append( { fxTypeID = fxTypeID, origin = origin, angles = angles, delay = delay } )
}

function EditorSaveFxGroups()
{
	if ( !( "fxGroups" in level ) )
		return

	DevTextBufferClear()
	DevTextBufferWrite( "// Auto generated file, edit at own risk!\n\n" )
	DevTextBufferWrite( "function main()\n{\n" )

	foreach( fxGroup, fxSetArray in level.fxGroups )
	{
		foreach( SetID, SetData in fxSetArray )
		{
			foreach( fx in SetData )
			{
				local pos = fx.origin
				local ang = fx.angles

				local printString =	"\tAddGroupFx( \"" + fxGroup + "\", \"" + SetID + "\", "
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

function CE_VisualSettingRelicIMC( player, ref )
{
	CE_ResetVisualSettings( player )

	ref.LerpSkyScale( SKYSCALE_COLONY_IMC_SHIP, 0.01 )
}

function CE_VisualSettingRelicMCOR( player, ref )
{
	CE_ResetVisualSettings( player )

	ref.LerpSkyScale( SKYSCALE_COLONY_MCOR_SHIP, 0.01 )
}
