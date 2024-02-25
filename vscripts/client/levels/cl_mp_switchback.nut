const FX_AOE_ELEC_SPARK = "P_Swtch_Elec_Pole"
const FX_AOE_ELEC = "P_Swtch_Elec_Ring_P"
const FX_AOE_SMOKE = "P_Swtch_Elec_Hazard_HLD"
const FX_AOE_SMOKE_WALL = "P_Swtch_Elec_Wall_HLD"
const FX_AOE_GRATE_EXPLOSION = "P_Swtch_Gen_Exp"
const SHIP_LIGHT = "tower_light_red"
const FX_SKYBOX_REDEYE_WARP_IN = "veh_red_warp_in_full_SB"
const FX_SKYBOX_REDEYE_WARP_OUT = "veh_red_warp_out_full_SB"
const FX_SKYBOX_BERMINGHAM_WARP_IN = "veh_birm_warp_in_full_SB"
const FX_SKYBOX_BERMINGHAM_WARP_OUT = "veh_birm_warp_out_full_SB"

const LIFT_MODEL = "models/props/lift/lift.mdl"
const LIFT_SHIP_MODEL = "models/props/supply_barge/lift_ship.mdl"
const GREENHOUSE_FAN_BLADE_MODEL = "models/props/greenhouse_fan_blade/greenhouse_fan_blade_animated.mdl"
const AOE_AR_CYLINDER = "models/test/ar_cylinder.mdl"

PrecacheParticleSystem( FX_AOE_ELEC_SPARK )
PrecacheParticleSystem( FX_AOE_ELEC )
PrecacheParticleSystem( FX_AOE_SMOKE )
PrecacheParticleSystem( FX_AOE_SMOKE_WALL )
PrecacheParticleSystem( FX_AOE_GRATE_EXPLOSION )
PrecacheParticleSystem( SHIP_LIGHT )
PrecacheParticleSystem( FX_SKYBOX_REDEYE_WARP_IN )
PrecacheParticleSystem( FX_SKYBOX_REDEYE_WARP_OUT )
PrecacheParticleSystem( FX_SKYBOX_BERMINGHAM_WARP_IN )
PrecacheParticleSystem( FX_SKYBOX_BERMINGHAM_WARP_OUT )

level.AOEElecSparkPositions <- [ Vector( -47.0, -654.0, 555.0 ),
								 Vector( -83.0, -656.0, 792.0 ),
								 Vector( -83.0, -656.0, 925.0 ) ]

level.AOEArcPositions <- [ Vector( -48.0,	-654.0,		1212.0 ),
						   Vector( -46.875,	-603.61,	1221.79	),
						   Vector( -47.0,	-369.86,	1270.36	),
						   Vector( -46.75,	224.89,		1394.34	),
						   Vector( -46.875,	458.64,		1442.91	),
						   Vector( -46.75,	702.89,		1493.64	),
						   Vector( -46.875,	1090.15,	1574.09	),
						   Vector( -46.875,	1414.66,	1641.5	),
						   Vector( -46.875,	1937.17,	1750.5	),
						   Vector( -46.875,	2293.99,	1824.63	),
						   Vector( -46.875,	2624.59,	1893.3	),
						   Vector( -46.875,	3000.47,	1971.38	) ]

level.AOEPositions <- [ Vector( -43.393,	3122.45,	1642.74 ),
						Vector( -222.393,	3122.58,	1491.49 ),
						Vector( 292.467,	3192.31,	1491.51 ),
						Vector( -709.134,	3167.91,	1438.67 ),
						Vector( 755.045,	3344.52,	1491.76 ) ]

level.AOEWallPositions <- [ { org = Vector( 71.085,		2910.91,	1505.63 ), ang = Vector( 0.0,	90.0,	0.0 ) },
							{ org = Vector( -391.04,	2920.28,	1505.63 ), ang = Vector( 0.0,	90.0,	0.0 ) },
							{ org = Vector( 508.738,	3034.82,	1505.63 ), ang = Vector( 0.0,	114.5263,	0.0 ) } ]

level.AOEExplosionPosition <- Vector( -41.0, 3365.0, 2113.0 )

function main()
{
	IncludeFile( "mp_switchback_shared" )
	IncludeFile( "client/cl_carrier" )

	level.ships <- [ { model = LiftCreateShip(), attachNum = null, moving = false },
					 { model = LiftCreateShip(), attachNum = null, moving = false },
					 { model = LiftCreateShip(), attachNum = null, moving = false },
					 { model = LiftCreateShip(), attachNum = null, moving = false },
					 { model = LiftCreateShip(), attachNum = null, moving = false } ]

	AddCreateCallback( "prop_dynamic", CreateCallback_PropDynamic )

	file.shipLightFXID <- GetParticleSystemIndex( SHIP_LIGHT )

	file.eventIndex <- 0
	file.aoeTrapEvents <- []
	file.aoeTrapActiveEvents <- []
	file.aoeTrapEndTime <- []

	RegisterServerVarChangeCallback( "aoeTrapStartTime", AOETrapResetFX )
	AddKillReplayStartedCallback( AOETrapResetFX )
	AddKillReplayEndedCallback( AOETrapResetFX )
	SetFullscreenMinimapParameters( 5.1, 550, 800, 180 )
	if ( GAMETYPE == COOPERATIVE )
		SetCustomMinimapZoom( 3.25 )
}

function EntitiesDidLoad()
{
	thread LiftAnimate()
	thread GreenhouseFansAnimate()
	thread AOETrapInit()
	thread AOETrapThink()
}

function CreateCallback_PropDynamic( self, isRecreate )
{
	local name = self.GetName()

	switch ( name )
	{
		case "prop_ar_glow":
			self.s.showWeakpoints <- true
			break
	}
}

function LiftAnimate()
{
	level.lift <- CreateClientSidePropDynamic( Vector( -53.906242, -3933.999512, 818.499878 ), Vector( 0.0, 90.0, 0.0 ), LIFT_MODEL )

	AddAnimEvent( level.lift, "LiftAttachShip1", LiftAttachShip1 )
	AddAnimEvent( level.lift, "LiftDetachShip1", LiftDetachShip1 )

	AddAnimEvent( level.lift, "LiftAttachShip2", LiftAttachShip2 )
	AddAnimEvent( level.lift, "LiftDetachShip2", LiftDetachShip2 )

	AddAnimEvent( level.lift, "LiftAttachShip3", LiftAttachShip3 )
	AddAnimEvent( level.lift, "LiftDetachShip3", LiftDetachShip3 )

	AddAnimEvent( level.lift, "LiftPlaySplashUpSound", LiftPlaySplashUpSound )
	AddAnimEvent( level.lift, "LiftPlaySplashDownSound", LiftPlaySplashDownSound )

	level.lift.Anim_Play( "lift_cycle" )
	level.lift.Anim_SetInitialTime( Time() )
	level.lift.clWaittillAnimDone()

	while ( true )
	{
		level.lift.Anim_Play( "lift_cycle" )
		level.lift.clWaittillAnimDone()
	}
}

function GreenhouseFansAnimate()
{
	local greenhouseFanBlade1 = CreateClientSidePropDynamic( Vector( 1400.0, 1792.0, 1110.0 ), Vector( 0.0, 0.0, 0.0 ), GREENHOUSE_FAN_BLADE_MODEL )
	greenhouseFanBlade1.Anim_Play( "fan_cycle_slow" )

	local greenhouseFanBlade2 = CreateClientSidePropDynamic( Vector( 1400.0, 1792.0, 1058.0 ), Vector( 0.0, 0.0, 0.0 ), GREENHOUSE_FAN_BLADE_MODEL )
	greenhouseFanBlade2.Anim_Play( "fan_cycle_slow" )
	greenhouseFanBlade2.Anim_SetInitialTime( greenhouseFanBlade2.GetSequenceDuration( "fan_cycle_slow" ) * 0.125 )
}

function LiftPlaySplashUpSound( lift )
{
	//DebugDrawBox( Vector( -1582.0, -3526.0, 345.0 ), Vector( -32.0, -32.0, -32.0 ), Vector( 32.0, 32.0, 32.0 ), 255, 255, 0, 1, 2.0 )
	EmitSoundAtPosition( Vector( -1582.0, -3526.0, 45.0 ), "Switchback_BoatWheel_Splash" )
}

function LiftPlaySplashDownSound( lift )
{
	//DebugDrawBox( Vector( 1461.0, -3356.0, 345.0 ), Vector( -32.0, -32.0, -32.0 ), Vector( 32.0, 32.0, 32.0 ), 255, 255, 0, 1, 2.0 )
	EmitSoundAtPosition( Vector( 1461.0, -3356.0, 45.0 ), "Switchback_BoatWheel_Splash" )
}

function LiftAttachShip1( lift )
{
	LiftAttachShip( "SHIP_1", 1 )
}

function LiftDetachShip1( lift )
{
	LiftDetachShip( 1 )
}

function LiftAttachShip2( lift )
{
	LiftAttachShip( "SHIP_2", 2 )
}

function LiftDetachShip2( lift )
{
	LiftDetachShip( 2 )
}

function LiftAttachShip3( lift )
{
	LiftAttachShip( "SHIP_3", 3 )
}

function LiftDetachShip3( lift )
{
	LiftDetachShip( 3 )
}

function LiftCreateShip()
{
	local ship = CreateClientsideScriptMover( LIFT_SHIP_MODEL, Vector( 0.0, 0.0, -1000.0 ), Vector( 0.0, 0.0, 0.0 ) )
	ship.DisableDraw()

	ship.s.lightFX1 <- 0
	ship.s.lightFX2 <- 0

	return ship
}

function LiftAttachShip( attachment, attachNum )
{
	local shipToAttach = null

	foreach ( ship in level.ships )
	{
		if ( ship.attachNum == attachNum )
		{
			return
		}

		if ( shipToAttach == null && ship.attachNum == null && !ship.moving )
		{
			shipToAttach = ship
		}
	}

	Assert( shipToAttach != null )

	if ( shipToAttach != null )
	{
		shipToAttach.attachNum = attachNum
		local attachmentID = level.lift.LookupAttachment( attachment )
		shipToAttach.model.SetOrigin( level.lift.GetAttachmentOrigin( attachmentID ) )
		shipToAttach.model.SetAngles( level.lift.GetAttachmentAngles( attachmentID ) )
		shipToAttach.model.SetParent( level.lift, attachment, false, 0.0 )
		shipToAttach.model.EnableDraw()

		shipToAttach.model.s.lightFX1 = StartParticleEffectOnEntity( shipToAttach.model, file.shipLightFXID, FX_PATTACH_POINT_FOLLOW, shipToAttach.model.LookupAttachment( "light_attach_3" ) )

		EffectSetDontKillForReplay( shipToAttach.model.s.lightFX1 )
	}
}

function LiftDetachShip( attachNum )
{
	local shipToDetach = null

	foreach ( ship in level.ships )
	{
		if ( ship.attachNum == attachNum )
		{
			shipToDetach = ship
			break
		}
	}

	if ( shipToDetach != null )
	{
		shipToDetach.attachNum = null
		shipToDetach.model.ClearParent()
		thread LiftMoveShip( shipToDetach )
	}
}

function LiftMoveShip( ship )
{
	ship.moving = true

	ship.model.NonPhysicsMoveTo( Vector( -53.0, -2419.0, 2580.0 ), 5.0, 2.0, 3.0 )
	ship.model.NonPhysicsRotateTo( Vector( 0.0, -90.0, 0.0 ), 5.0, 2.0, 3.0 )
	wait( 5.0 )
	ship.model.NonPhysicsMoveTo( Vector( -53.0, 5581.0, 2580.0 ), 24.0, 3.0, 0 )
	wait( 24.0 )
	ship.model.DisableDraw()

	EffectStop( ship.model.s.lightFX1, true, false )

	ship.moving = false
}

const FX = 0
const SOUND = 1

function AOETrapInit()
{
	local time = 0.0

	// alarm sound
	while ( time < level.AOEArcDuration + level.AOESmokeDuration + 3.0 )
	{
		file.aoeTrapEvents.append( { eventType = SOUND, id = "Switchback_Electrical_Alarm", origin = Vector( -49.75, 3352.17, 1856.85 ), angles = Vector( 0.0, 0.0, 0.0 ), startTime = time, endTime = time + 2.0, hasPlayed = false, stopWhenDone = false, handle = -1 } )
		time += 2.0
	}

	// initial column sparks
	time = 0.0

	//file.aoeTrapEvents.append( { eventType = SOUND, id = "Switchback_Terminal_Activate", origin = Vector( -47.0, -656.0, 616.0 ), angles = Vector( 0.0, 0.0, 0.0 ), startTime = time, endTime = time + 2.0, hasPlayed = false, stopWhenDone = false, handle = -1 } )

	foreach ( pos in level.AOEElecSparkPositions )
	{
		file.aoeTrapEvents.append( { eventType = FX, id = GetParticleSystemIndex( FX_AOE_ELEC_SPARK ), origin = pos, angles = Vector( 0.0, 0.0, 0.0 ), startTime = time, endTime = time + level.AOEArcDuration + level.AOESmokeDuration, hasPlayed = false, stopWhenDone = true, handle = -1 } )
	}

	local soundDelay = 0.7
	for ( local i = 0; i < 17; i++ )
	{
		file.aoeTrapEvents.append( { eventType = SOUND, id = "Switchback_Terminal_Small_Arcs", origin = level.AOEElecSparkPositions[ 0 ], angles = Vector( 0.0, 0.0, 0.0 ), startTime = time + ( soundDelay * i ) + RandomFloat( 0.0, 0.1 ), endTime = time + level.AOEArcDuration + level.AOESmokeDuration, hasPlayed = false, stopWhenDone = false, handle = -1 } )
	}

	// electrical arc traveling down pipes
	time = 0.25

	foreach ( pos in level.AOEArcPositions )
	{
		file.aoeTrapEvents.append( { eventType = FX, id = GetParticleSystemIndex( FX_AOE_ELEC ), origin = pos, angles = Vector( 0.0, 0.0, 0.0 ), startTime = time, endTime = time + 2.0, hasPlayed = false, stopWhenDone = false, handle = -1 } )
		file.aoeTrapEvents.append( { eventType = SOUND, id = "Switchback_Killer_Electrical_Arc", origin = pos, angles = Vector( 0.0, 0.0, 0.0 ), startTime = time, endTime = time + 2.0, hasPlayed = false, stopWhenDone = false, handle = -1 } )

		time += 0.15 // 0.125 // 12 poses
	}

	// explosion near trap damage area
	time = 2.0

	file.aoeTrapEvents.append( { eventType = FX, id = GetParticleSystemIndex( FX_AOE_GRATE_EXPLOSION ), origin = level.AOEExplosionPosition, angles = Vector( 0.0, 0.0, 0.0 ), startTime = time, endTime = time + 2.0, hasPlayed = false, stopWhenDone = false, handle = -1 } )
	file.aoeTrapEvents.append( { eventType = SOUND, id = "Switchback_building_explosion", origin = level.AOEExplosionPosition, angles = Vector( 0.0, 0.0, 0.0 ), startTime = time, endTime = time + 2.0, hasPlayed = false, stopWhenDone = false, handle = -1 } )

	// electrical arcs covering damage area
	time = 2.2

	foreach ( pos in level.AOEPositions )
	{
		file.aoeTrapEvents.append( { eventType = FX, id = GetParticleSystemIndex( FX_AOE_SMOKE ), origin = pos, angles = Vector( 0.0, 0.0, 0.0 ), startTime = time, endTime = time + level.AOESmokeDuration - 0.2, hasPlayed = false, stopWhenDone = true, handle = -1 } )
	}

	while ( time < level.AOEArcDuration + level.AOESmokeDuration )
	{
		file.aoeTrapEvents.append( { eventType = SOUND, id = "Switchback_Electrical_DamageArea", origin = level.AOEPositions[ RandomInt( level.AOEPositions.len() ) ], angles = Vector( 0.0, 0.0, 0.0 ), startTime = time, endTime = time + 2.0, hasPlayed = false, stopWhenDone = true, handle = -1 } )
		time += 0.5
	}

	// electrical arcs on fence in front of damage area
	time = 2.2

	foreach ( wallPos in level.AOEWallPositions )
	{
		file.aoeTrapEvents.append( { eventType = FX, id = GetParticleSystemIndex( FX_AOE_SMOKE_WALL ), origin = wallPos.org, angles = wallPos.ang, startTime = time, endTime = time + level.AOESmokeDuration - 0.2, hasPlayed = false, stopWhenDone = true, handle = -1 } )
	}

	foreach ( res in level.AOEResiduals )
	{
		local pos = level.AOEArcPositions[ res.index ]
		file.aoeTrapEvents.append( { eventType = FX, id = GetParticleSystemIndex( FX_AOE_ELEC ), origin = pos, angles = Vector( 0.0, 0.0, 0.0 ), startTime = res.time, endTime = res.time + 2.0, hasPlayed = false, stopWhenDone = false, handle = -1 } )
		file.aoeTrapEvents.append( { eventType = SOUND, id = "Switchback_Killer_Electrical_Arc", origin = pos, angles = Vector( 0.0, 0.0, 0.0 ), startTime = res.time, endTime = res.time + 2.0, hasPlayed = false, stopWhenDone = false, handle = -1 } )
	}

	// sort by startTime
	file.aoeTrapEvents.sort( AOETrapFXSort )

	// spread out events so only one exists on a frame
	local lastStartTime = -1.0
	foreach ( event in file.aoeTrapEvents )
	{
		if ( event.startTime <= lastStartTime )
			event.startTime = lastStartTime + 0.016

		lastStartTime = event.startTime
	}

	// calc trap end time
	file.aoeTrapEndTime = 0.0

	foreach ( event in file.aoeTrapEvents )
	{
		if ( event.endTime > file.aoeTrapEndTime )
			file.aoeTrapEndTime = event.endTime
	}
}

function AOETrapFXSort( fx1, fx2 )
{
	if ( fx1.startTime > fx2.startTime )
		return 1
	else if ( fx1.startTime < fx2.startTime )
		return -1

	return 0
}

function AOETrapThink()
{
	local startTime = -1.0
	local viewTime = -1.0
	local i = 0
	local event = null
	local activeEvent = null
	local actualEventStartTime = -1
	local actualEventEndTime = -1

	while ( true )
	{
		startTime = level.nv.aoeTrapStartTime
		if ( startTime < 0.0 )
		{
			wait( 0.0 )
			continue
		}

		viewTime = Time() - TimeAdjustmentForRemoteReplayCall()

		if ( viewTime >= startTime && viewTime <= startTime + file.aoeTrapEndTime )
		{
			// add events to aoeTrapActiveEvents if we are past their start time
			while ( file.eventIndex < file.aoeTrapEvents.len() )
			{
				event = file.aoeTrapEvents[ file.eventIndex ]
				actualEventStartTime = startTime + event.startTime

				if ( viewTime >= actualEventStartTime )
				{
					file.aoeTrapActiveEvents.append( event )
					file.eventIndex++
				}
				else
				{
					break
				}
			}

			// remove events from aoeTrapActiveEvents if we're past their endTime
			for ( i = 0; i < file.aoeTrapActiveEvents.len(); i++ )
			{
				activeEvent = file.aoeTrapActiveEvents[ i ]

				actualEventEndTime = startTime + activeEvent.endTime
				if ( viewTime >= actualEventEndTime )
				{
					if ( activeEvent.eventType == FX && activeEvent.stopWhenDone && activeEvent.handle != -1 )
					{
						EffectStop( activeEvent.handle, false, true )
						activeEvent.handle = -1
					}

					file.aoeTrapActiveEvents.remove( i )
					i--
				}
			}

			// start effect in aoeTrapActiveEvents if they haven't yet played
			foreach ( activeEvent in file.aoeTrapActiveEvents )
			{
				if ( !activeEvent.hasPlayed )
				{
					activeEvent.hasPlayed = true

					switch ( activeEvent.eventType )
					{
						case FX:
							if ( activeEvent.stopWhenDone )
								activeEvent.handle = StartParticleEffectInWorldWithHandle( activeEvent.id, activeEvent.origin, activeEvent.angles )
							else
								StartParticleEffectInWorld( activeEvent.id, activeEvent.origin, activeEvent.angles )
							break

						case SOUND:
							EmitSoundAtPosition( activeEvent.origin, activeEvent.id )
							break
					}

				}
			}
		}

		wait( 0.0 )
	}
}

function AOETrapResetFX()
{
	file.eventIndex = 0
	foreach ( fx in file.aoeTrapEvents )
		fx.hasPlayed = false

	foreach ( activeEvent in file.aoeTrapActiveEvents )
	{
		if ( activeEvent.stopWhenDone && activeEvent.handle != -1 )
		{
			EffectStop( activeEvent.handle, false, true )
			activeEvent.handle = -1
		}
	}

	file.aoeTrapActiveEvents.clear()
}