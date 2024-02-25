
const FX_SKYBOX_REFUEL_SHIP_EXPLOSION = "P_exp_refuelship_SBox"

const FX_SKYBOX_REDEYE_WARP_IN = "veh_red_warp_in_full_SB"
const FX_SKYBOX_REDEYE_WARP_OUT = "veh_red_warp_out_full_SB"
const FX_SKYBOX_BERMINGHAM_WARP_IN = "veh_birm_warp_in_full_SB"
const FX_SKYBOX_BERMINGHAM_WARP_OUT = "veh_birm_warp_out_full_SB"

function main()
{
	PrecacheParticleSystem( FX_SKYBOX_REFUEL_SHIP_EXPLOSION )
	PrecacheParticleSystem( FX_SKYBOX_REDEYE_WARP_IN )
	PrecacheParticleSystem( FX_SKYBOX_REDEYE_WARP_OUT )
	PrecacheParticleSystem( FX_SKYBOX_BERMINGHAM_WARP_IN )
	PrecacheParticleSystem( FX_SKYBOX_BERMINGHAM_WARP_OUT )

	skyboxCenter <- Vector( -12285, -12291, -9701 )
	level.refuelShipDirection <- Vector( -0.813501, 0.580235, -0.039295 )

	level.mainTracerLocations <- []
	level.mainTracerLocations.append( Vector( -657, 4204, 943 ) )
	level.mainTracerLocations.append( Vector( -3820, 3138, 676 ) )
	level.mainTracerLocations.append( Vector( -8568, -995, 2096 ) )
	level.mainTracerLocations.append( Vector( -7577, -2701, 1993 ) )
	level.mainTracerLocations.append( Vector( 4255, 7825, 541 ) )
	level.mainTracerLocations.append( Vector( -11412, -5045, 2909 ) )
	level.mainTracerLocations.append( Vector( -10839, -2659, 2036 ) )
	level.mainTracerLocations.append( Vector( -9615, -1201, 1983 ) )

	startedArmada <- false

	level.slowFlybyShips <- []

	RegisterSignal( "megathumper_impact" )

	FlagInit( "SkyboxRefuelShipsEnabled" )


	IncludeFileAllowMultipleLoads( "client/objects/cl_hornet_fighter" )
	IncludeFileAllowMultipleLoads( "client/objects/cl_phantom_fighter" )
	IncludeFileAllowMultipleLoads( "client/objects/cl_redeye" )
	IncludeFileAllowMultipleLoads( "client/objects/cl_annapolis" )
	IncludeFileAllowMultipleLoads( "client/objects/cl_birmingham" )
	IncludeFileAllowMultipleLoads( "client/objects/cl_ai_turret" )

	Globalize( SkyBoxStaticRefuelRod_Think )
	Globalize( MatchProgressChanged )
	Globalize( ServerCallback_RedeyeHideEffects )
	Globalize( ServerCallback_FractureLaptopFx )
	Globalize( ServerCallback_IMCSeesFleetInvade )
	Globalize( CE_FractureVisualSettingsSpace )
	Globalize( CE_VisualSettingsDropshipIMC )
	Globalize( CE_FractureIMCIntroBogies )

	FlagInit( "bogieFlyby" )

	PrecacheParticleSystem( "xo_spark_med" )
	PrecacheParticleSystem( "env_megathumper_dust_crack" )

	PrecacheWeapon( "mp_weapon_mega_turret_aa" )

	RegisterServerVarChangeCallback( "matchProgress", MatchProgressChanged )

	if( GetCinematicMode() )
		IntroScreen_Setup()
	SetFullscreenMinimapParameters( 4.0, 1500, 0, 180 )
	if ( GAMETYPE == COOPERATIVE )
		SetCustomMinimapZoom( 2.5 )
}

function IntroScreen_Setup()
{
	CinematicIntroScreen_SetText( TEAM_IMC, 	[ "#INTRO_SCREEN_FRACTURE_LINE1", "#INTRO_SCREEN_FRACTURE_LINE2", "#INTRO_SCREEN_FRACTURE_LINE3" ] )
	CinematicIntroScreen_SetText( TEAM_MILITIA, [ "#INTRO_SCREEN_FRACTURE_LINE1", "#INTRO_SCREEN_FRACTURE_LINE2", "#INTRO_SCREEN_FRACTURE_LINE3" ] )
	//CinematicIntroScreen_SetQuickIntro( TEAM_IMC )
	CinematicIntroScreen_SetQuickIntro( TEAM_MILITIA )
}

function EntitiesDidLoad()
{
	printt( "EntitiesDidLoad" )
	thread MegaThumperDust()
	thread RandomSparks()
	thread SkyBoxStaticRefuelRods()
	thread SetupMegaTurrets()
}

function SetupMegaTurrets()
{
	local turrets = GetNPCArrayByClass( "npc_turret_mega" )
	foreach ( turret in turrets )
		SetHealthBarVisibilityOnEntity( turret, false )
}

function MatchProgressChanged()
{
	//######################
	// SKYBOX ARMADA BEGINS
	//######################

	if ( level.nv.matchProgress >= MATCH_PROGRESS_RED_EYE_AND_ARMADA )
	{
		if ( !startedArmada )
		{
			printt( "---------------" )
			printt( "STARTING ARMADA" )
			printt( "---------------" )

			startedArmada = true
			thread StartArmada()
		}
	}
}

function RandomSparks()
{
	local fxID = GetParticleSystemIndex( "xo_spark_med" )
	local sparks = GetClientEntArray( "info_target", "fx_spark_random" )

	foreach ( spark in sparks )
	{
		thread PlaySparks( spark, fxID, "titan_damage_spark" )
	}
}

function PlaySparks( fxEnt, fxID, soundName )
{
	local origin = fxEnt.GetOrigin()
	local angles = fxEnt.GetAngles()

	local minDelay = 1.0
	local maxDelay = 6.0

	fxEnt.EndSignal( "OnDestroy" )

	while ( IsValid( fxEnt ) )
	{
		wait RandomFloat( minDelay, maxDelay )
		StartParticleEffectInWorld( fxID, origin, angles )
		EmitSoundOnEntity( fxEnt, soundName )
	}
}

function MegaThumperDust()
{
	local fxID = GetParticleSystemIndex( "env_megathumper_dust_crack" )
	local mega_thumper_dust = GetClientEntArray( "info_target", "fx_thumper_dust" )

	foreach ( effect in mega_thumper_dust )
	{
		thread PlayMegaThumperDust( effect, fxID )
	}
}

function PlayMegaThumperDust( fxEnt, fxID )
{
	local origin = fxEnt.GetOrigin()
	local angles = fxEnt.GetAngles()

	fxEnt.EndSignal( "OnDestroy" )
	for ( ;; )
	{
		level.ent.WaitSignal( "megathumper_impact" )
		StartParticleEffectInWorld( fxID, origin, angles )
		EmitSoundOnEntity( fxEnt, "Fracture_RockShower" )
	}
}

function StartArmada()
{
	wait 4.0
	thread SkyboxSlowFlybys()
	wait 1.0
	FlagSet( "SkyboxRefuelShipsEnabled" )
	wait 7.0
	thread FractureSkyboxTracers_StartAll()
}

function SkyBoxStaticRefuelRods()
{
	local nodes = level.cinematicNodesByType[CINEMATIC_TYPES.FRACTURE_SKYBOX_STATIC_REFUEL]
	ArrayRandomize( nodes )
	foreach( node in nodes )
		thread SkyBoxStaticRefuelRod_Think( node )
}

function SkyBoxStaticRefuelRod_Think( node )
{
	if ( GetGameState() > eGameState.SuddenDeath )
		return

	local travelDist = 800
	local travelTime = 30
	local hoverTime = [ 10, 20 ]

	// Not creating the boom model on client anymore, it's not in the level geo as optimization
	//local refuelBoom = CreateClientSidePropDynamic( node.pos, node.ang, SKYBOX_REFUEL_SPRITE_MODEL )

	local hoverOrg = node.pos + Vector( 0, 0, 25 )
	local spawnOrg = node.pos + ( level.refuelShipDirection * -travelDist ) + Vector( 0, 0, 70 )
	local exitOrg = node.pos + ( level.refuelShipDirection * travelDist ) + Vector( 0, 0, 50 )

	if ( !Flag( "SkyboxRefuelShipsEnabled" ) )
	{
		FlagWait( "SkyboxRefuelShipsEnabled" )
		wait RandomFloat( 0.0, 4.0 )
	}

	local hoverTime = RandomFloat( hoverTime[0], hoverTime[1] )
	local timeTillNextShip = hoverTime + RandomFloat( 10.0, 30.0 )
	delaythread( timeTillNextShip ) SkyBoxStaticRefuelRod_Think( node )

	// Spawn the ship
	local ship = CreateClientsideScriptMover( SKYBOX_REFUEL_SHIP_MODEL, spawnOrg, VectorToAngles( level.refuelShipDirection ) )
	thread SkyboxShipWarpIn( ship )

	// Fly the ship to the refuel boom
	ship.NonPhysicsMoveTo( hoverOrg, travelTime, 0, travelTime * 0.5 )
	wait travelTime

	// Ship waits at the boom for a while
	local shipExplodes = RandomInt( 0, 3 ) == 0
	if ( shipExplodes )
	{
		thread SkyboxRefuelShipExplodes( ship, 3.0 )
		return
	}

	wait hoverTime

	// Ship flies away
	ship.NonPhysicsMoveTo( exitOrg, travelTime, travelTime * 0.5, 0 )
	wait travelTime

	// Delete the ship at end of path
	SkyboxShipWarpOut( ship )
	ship.Kill()
}

//exp_fracture_refuelship_skybox_death
function SkyboxRefuelShipExplodes( ship, delay )
{
	ship.EndSignal( "OnDestroy")
	// Settings
	local maxEffectOffset = 10
	local crashOffsetDown = -30
	local crashOffsetAway = 50
	local crashOffsetForward = 30
	local crashRotationAwayMin = 60
	local crashRotationAwayMax = 85
	local crashDuration = 10.0

	// Figure out where to crash to and how much to rotate while crashing
	local randVec
	local effectLocation
	local vecAwayFromCenter = ship.GetOrigin() - skyboxCenter
	vecAwayFromCenter.Norm()

	local crashPoint = ship.GetOrigin() + Vector( 0, 0, crashOffsetDown ) + ( vecAwayFromCenter * crashOffsetAway )
	local crashRotation = Vector( 0, 0, 0 )
	local crashOffset = level.refuelShipDirection * crashOffsetForward
	local crashRotationAway = RandomFloat( crashRotationAwayMin, crashRotationAwayMax )

	// Random - crashes forward, or backward for variety
	local crashForward = CoinFlip()
	if ( crashForward )
	{
		crashPoint += crashOffset
		crashRotation.x += crashRotationAway
	}
	else
	{
		crashPoint -= crashOffset
		crashRotation.x -= crashRotationAway
	}

	// Move and Rotate the ship to make it look like it's crashing
	ship.NonPhysicsMoveTo( crashPoint, crashDuration, crashDuration * 0.9, 0 )
	ship.NonPhysicsRotateTo( crashRotation, crashDuration, crashDuration * 0.9, 0 )

	local effectIndex = GetParticleSystemIndex( FX_SKYBOX_REFUEL_SHIP_EXPLOSION )
	local attachIdx = ship.LookupAttachment( "ORIGIN" )
	local effect = StartParticleEffectOnEntity( ship, effectIndex, FX_PATTACH_POINT_FOLLOW, attachIdx )

	// Ship crash done, big explosion
	wait crashDuration
	if ( EffectDoesExist( effect ) )
		EffectStop( effect, false, true )	// id, stop all particles, play end cap
	//give time for the endcap effect to play
	wait 0.01
	ship.Kill()
}

function ServerCallback_IMCSeesFleetInvade()
{
	local angles = Vector( 0, 144.5 ,0  )

	delaythread( 0.35 ) __IMCSeesFleetShip( Vector( -12298.5, -12156.4, -9687.23 ), angles, SKYBOX_ARMADA_SHIP_MODEL_REDEYE )
	delaythread( 0.7 ) 	__IMCSeesFleetShip( Vector( -12178.5, -11637.2, -9525.23 ), angles, SKYBOX_ARMADA_SHIP_MODEL_BERMINGHAM )
	delaythread( 1.25 )	__IMCSeesFleetShip( Vector( -12286.3, -12105.8, -9675.98 ), angles, SKYBOX_ARMADA_SHIP_MODEL_REDEYE )

	delaythread( 3.0 ) 	__IMCSeesFleetShip( Vector( -12199.3, -12063.8, -9657.98 ), angles, SKYBOX_ARMADA_SHIP_MODEL_REDEYE )
	delaythread( 3.35 ) __IMCSeesFleetShip( Vector( -11931.5, -11611.2, -9516.23 ), angles, SKYBOX_ARMADA_SHIP_MODEL_BERMINGHAM )
	delaythread( 3.7 )	__IMCSeesFleetShip( Vector( -12198.5, -12137.4, -9677.23 ), angles, SKYBOX_ARMADA_SHIP_MODEL_REDEYE )
}

function __IMCSeesFleetShip( origin, angles, model )
{
	local dist = RandomFloat( 80, 100 )
	local time = RandomFloat( 10, 12 )

	local moveToPos = origin + ( angles.AnglesToForward() * dist )

	local ship = CreateClientsideScriptMover( model, origin, angles )

	thread SkyboxShipWarpIn( ship )
	ship.NonPhysicsMoveTo( moveToPos, time, 0, 0 )
	thread WarpOutFlybyShipWithDelay( ship, time )
}

function SkyboxSlowFlybys()
{
	local skyboxWidth = { min = -350, max = 350 }
	local skyboxLength = { min = -800, max = 800 }
	local skyboxHeight = { min = 100, max = 200 }
	local moveDuration = { min = 100.0, max = 200.0 }

	local spawnAng = VectorToAngles( level.refuelShipDirection )
	local right = spawnAng.AnglesToRight()

	local numShipsAcross = 8
	local shipSpacing = abs( skyboxWidth.min - skyboxWidth.max ) / numShipsAcross

	local spawnOrder = [ 1, 6, 4, 0, 5, 3, 7, 2 ]
	local shipModels = [ 1, 1, 1, 0, 0, 0, 0, 0 ]
	Assert( spawnOrder.len() == numShipsAcross )
	Assert( shipModels.len() == numShipsAcross )

	while ( GetGameState() <= eGameState.SuddenDeath )
	{
		foreach( index, val in spawnOrder )
		{
			local shipMoveDuration = RandomFloat( moveDuration.min, moveDuration.max )

			local offsetForward = skyboxLength.min
			offsetForward += RandomFloat( 0, 500 )

			local offsetRight = skyboxWidth.min + ( shipSpacing / 2.0 ) + ( shipSpacing * val )
			offsetRight += RandomFloat( -shipSpacing * 0.4, shipSpacing * 0.4 )

			local offsetHeight = RandomFloat( skyboxHeight.min, skyboxHeight.max )

			local spawnPos = skyboxCenter + ( level.refuelShipDirection * offsetForward ) + ( right * offsetRight ) + Vector( 0, 0, offsetHeight )
			local moveToPos = spawnPos + ( level.refuelShipDirection * abs( skyboxLength.min - skyboxLength.max ) )

			local model = shipModels[ index ] == 0 ? SKYBOX_ARMADA_SHIP_MODEL_REDEYE : SKYBOX_ARMADA_SHIP_MODEL_BERMINGHAM
			local ship = CreateClientsideScriptMover( model, spawnPos, spawnAng )
			level.slowFlybyShips.append( ship )

			thread SkyboxShipWarpIn( ship )
			ship.NonPhysicsMoveTo( moveToPos, shipMoveDuration, 0, 0 )
			thread WarpOutFlybyShipWithDelay( ship, shipMoveDuration )

			wait 0.35
		}

		wait moveDuration.min * 0.25
		ArrayRandomize( spawnOrder )
		ArrayRandomize( shipModels )
	}

	// Make some of the remaining ships warp out during the epilogue
	foreach( ship in level.slowFlybyShips )
	{
		if ( IsValid( ship ) && "warpinComplete" in ship.s )
			thread WarpOutFlybyShipWithDelay( ship, RandomFloat( 0.0, 30.0 ) )
	}
}

function SkyboxShipWarpIn( ship )
{
	ship.EndSignal( "OnDestroy" )
	local fxID = null
	switch( ship.GetModelName() )
	{
		case SKYBOX_ARMADA_SHIP_MODEL_REDEYE:
			fxID = GetParticleSystemIndex( FX_SKYBOX_REDEYE_WARP_IN )
			break
		case SKYBOX_ARMADA_SHIP_MODEL_BERMINGHAM:
			fxID = GetParticleSystemIndex( FX_SKYBOX_BERMINGHAM_WARP_IN )
			break
		default:
			Assert( 0, "Invalid model for skybox warp in effect for " + ship.GetModelName() )
	}
	Assert( fxID != null )

	ship.Hide()
	local sndOrigin = CalcSkyboxSoundOrigin( ship.GetOrigin() )
	EmitSoundAtPosition( sndOrigin, "largeship_warpin" )
	local fx = StartParticleEffectInWorldWithHandle( fxID, ship.GetOrigin(), ship.GetAngles() )
	wait 0.25
	ship.Show()
	ship.s.warpinComplete <- true
}

function CalcSkyboxSoundOrigin( origin )
{
	local center = Vector( -12288, -12288, -9728 )
	local delta = ( origin - center ) * 15

	return GetLocalViewPlayer().GetOrigin() + delta
}

function SkyboxShipWarpOut( ship )
{
	local fxID = null
	switch( ship.GetModelName() )
	{
		case SKYBOX_ARMADA_SHIP_MODEL_REDEYE:
			fxID = GetParticleSystemIndex( FX_SKYBOX_REDEYE_WARP_OUT )
			break
		case SKYBOX_ARMADA_SHIP_MODEL_BERMINGHAM:
			fxID = GetParticleSystemIndex( FX_SKYBOX_BERMINGHAM_WARP_OUT )
			break
		default:
			Assert( 0, "Invalid model for skybox warp out effect" )
	}
	Assert( fxID != null )
	local fx = StartParticleEffectInWorldWithHandle( fxID, ship.GetOrigin(), ship.GetAngles() )
}

function WarpOutFlybyShipWithDelay( ship, delay = 0 )
{
	wait delay
	if ( !IsValid( ship ) )
		return

	SkyboxShipWarpOut( ship )
	ship.Kill()
}

function ServerCallback_RedeyeHideEffects()
{
	if ( !IsValid( level.nv.RefuelShip ) )
		return

	ModelFX_DisableGroup( level.nv.RefuelShip, "thrusters" )
	ModelFX_DisableGroup( level.nv.RefuelShip, "running_lights" )
}

function ServerCallback_FractureLaptopFx( eHandle )
{
	local laptop = GetEntityFromEncodedEHandle( eHandle )
	if ( !IsValid( laptop ) )
		return

	local fxID = GetParticleSystemIndex( "bish_comp_glow_01" )
	local attachID = laptop.LookupAttachment( "REF" )

	// blinking light FX
	local fx = StartParticleEffectOnEntity( laptop, fxID, FX_PATTACH_POINT_FOLLOW, attachID )
}

/************************************************************************************************\

##     ## ####  ######  ##     ##    ###    ##             ######## ##     ## ##    ##  ######   ######
##     ##  ##  ##    ## ##     ##   ## ##   ##             ##       ##     ## ###   ## ##    ## ##    ##
##     ##  ##  ##       ##     ##  ##   ##  ##             ##       ##     ## ####  ## ##       ##
##     ##  ##   ######  ##     ## ##     ## ##             ######   ##     ## ## ## ## ##        ######
 ##   ##   ##        ## ##     ## ######### ##             ##       ##     ## ##  #### ##             ##
  ## ##    ##  ##    ## ##     ## ##     ## ##             ##       ##     ## ##   ### ##    ## ##    ##
   ###    ####  ######   #######  ##     ## ########       ##        #######  ##    ##  ######   ######

\************************************************************************************************/
function CE_FractureVisualSettingsSpace( player, ref )
{
	CE_VisualSettingsSpace( player, ref )

	CE_SetSunLightAngles( 13, 137.5 )

	CE_SetSunSkyLightScales( 0.5, 0.25 )
}

function CE_VisualSettingsDropshipIMC( player, ref )
{
	CE_ResetVisualSettings( player )

	ref.LerpSkyScale( SKYSCALE_FRACTURE_IMC_SHIP, 0.01 )
}

/************************************************************************************************\

#### ##     ##  ######        #### ##    ## ######## ########   #######
 ##  ###   ### ##    ##        ##  ###   ##    ##    ##     ## ##     ##
 ##  #### #### ##              ##  ####  ##    ##    ##     ## ##     ##
 ##  ## ### ## ##              ##  ## ## ##    ##    ########  ##     ##
 ##  ##     ## ##              ##  ##  ####    ##    ##   ##   ##     ##
 ##  ##     ## ##    ##        ##  ##   ###    ##    ##    ##  ##     ##
#### ##     ##  ######        #### ##    ##    ##    ##     ##  #######

\************************************************************************************************/

function CE_FractureIMCIntroBogies( player, ref )
{
	AddAnimEvent( ref, "cl_introBogie1", FractureIMCIntroHandleBogies, "gd_fracture_flyin_mcor_warp1" )
	AddAnimEvent( ref, "cl_introBogie2", FractureIMCIntroHandleBogies, "gd_fracture_flyin_mcor_warp2" )
}

function FractureIMCIntroHandleBogies( ref, anim )
{
	if ( !Flag( "bogieFlyby" ) )
		delaythread( 1.5 ) EmitSoundOnEntity( GetLocalViewPlayer(), "Fracture_Scr_IMCIntro_CrowsFlyBy" )
	FlagSet( "bogieFlyby" )

	thread FractureIMCIntroCreateBogie( Vector( 3916.63, -728.074, 336 ), Vector( 0, 0, 0 ), anim )

	delaythread( WARPINFXTIME ) FractureIMCIntroBogiesShake()
}

function FractureIMCIntroBogiesShake()
{
	local amplitude, frequency, duration
	local direction = Vector( 0,0,0 )
	amplitude 	= 15
	frequency 	= 50
	duration 	= 2.0
	ClientScreenShake( amplitude, frequency, duration, direction )
}

function FractureIMCIntroCreateBogie( origin, angles, anim )
{
	waitthread CLWarpinEffect( CROW_MODEL, anim, origin, angles, "Fracture_bogie_warpin" )

	local ship 	= CreatePropDynamic( CROW_MODEL, origin, angles )

	OnThreadEnd(
		function() : ( ship )
		{
			if ( IsValid( ship ) )
				ship.Kill()
		}
	)

	waitthread PlayAnimTeleport( ship, anim, origin, angles )
	CLWarpoutEffect( ship )

	wait 0.25
}
