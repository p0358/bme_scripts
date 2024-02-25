const FX_MEGATURRET_TRACER 	= "weapon_tracers_megaturret_loop"

const MATCH_PROGRESS_MEGATURRETS = 75

const FX_EXP_BIRM_SML = "p_exp_redeye_sml"
const FIRE_TRAIL = "Rocket_Smoke_Swirl_LG"

const LARGE_REFUEL_SHIP_MODEL = "models/vehicle/redeye/redeye2.mdl"

const FX_REDEYE_WARPIN_SKYBOX = "veh_red_warp_in_full_SB_1000"
const FX_BIRMINGHAM_WARPIN_SKYBOX = "veh_birm_warp_in_full_SB_1000"

const FX_REFUEL_SHIP_WARPIN = "veh_redeye_warp_in_FULL"
const FX_SKYBOX_BERMINGHAM_WARP_IN = "veh_birm_warp_in_FULL"
const FX_HORNET_DEATH =  "P_veh_exp_hornet" // "veh_gunship_destroyed_FULL"

function main()
{
	level.endingShips <- []
	level.musicEnabled = true
	IncludeFile( "mp_angel_city_shared" )
	IncludeFileAllowMultipleLoads( "client/objects/cl_hornet_fighter" )
	IncludeFileAllowMultipleLoads( "client/objects/cl_phantom_fighter" )

	// include this file to do ship attacks on carriers
	IncludeFile( "client/cl_carrier" )

	Globalize( RedeyeAttack )

	Assert( !IsServer() )

	RegisterSignal( "ending_militia_attack" )

	PrecacheParticleSystem( FX_REDEYE_WARPIN_SKYBOX )
	PrecacheParticleSystem( FX_BIRMINGHAM_WARPIN_SKYBOX )

	PrecacheParticleSystem( FX_MEGATURRET_TRACER )
	PrecacheParticleSystem( FX_EXP_BIRM_SML )
	PrecacheParticleSystem( FIRE_TRAIL )

	PrecacheParticleSystem( FX_REFUEL_SHIP_WARPIN )
	PrecacheParticleSystem( FX_SKYBOX_BERMINGHAM_WARP_IN )
	PrecacheParticleSystem( FX_HORNET_DEATH )

	foreach ( fx in level.megaTurretImpactFX )
		PrecacheParticleSystem( fx )

	RegisterServerVarChangeCallback( "megaCarrier", MegaCarrier_Changed )
	RegisterSignal( "idling" )

	delaythread( 0.1 ) MegaCarrier_Changed()

	Globalize( ServerCallback_FractureLaptopFx )
	Globalize( MegaCarrierVDUFunc_Militia )
	Globalize( MegaCarrierVDUFunc_IMC )
	Globalize( ServerCallback_MilitiaFleetAttackMegaCarrier )
	Globalize( AC_EndingAttack )
	Globalize( ServerCallback_IMCIntroHornetExplosion )
	Globalize( ServerCallback_IMCVictoryCarrierMoves )

	FlagInit( "RedeyeArrives" )

	if( GetCinematicMode() )
		IntroScreen_Setup()

	SetFullscreenMinimapParameters( 2.8,-1000, 800, -180 )
	if ( GAMETYPE == COOPERATIVE )
		SetCustomMinimapZoom( 2.5 )
}

function IntroScreen_Setup()
{
	CinematicIntroScreen_SetText( TEAM_IMC, 	[ "#INTRO_SCREEN_ANGEL_CITY_LINE1", "#INTRO_SCREEN_ANGEL_CITY_LINE2", "#INTRO_SCREEN_ANGEL_CITY_LINE3" ] )
	CinematicIntroScreen_SetText( TEAM_MILITIA, [ "#INTRO_SCREEN_ANGEL_CITY_LINE1", "#INTRO_SCREEN_ANGEL_CITY_LINE2", "#INTRO_SCREEN_ANGEL_CITY_LINE3" ] )
	CinematicIntroScreen_SetTextFadeTimes( TEAM_IMC, 1.5, 2.0, 1.5 )
	CinematicIntroScreen_SetTeamLogoFadeTimes( TEAM_IMC, 0.0, 1.0, 2.0, 1.0 )
	CinematicIntroScreen_SetBlackscreenFadeTimes( TEAM_IMC, 4.5, 5.0 )
}

function EntitiesDidLoad()
{
	if ( GetBugReproNum() != 31536 )
		return

	local model = HORNET_MODEL
	local origin = Vector(0,-13200,2000)
	local angles = Vector(0,0,0)
	local hornet = CreatePropDynamic( model, origin, Vector(0,0,0) )
	local anim = "ht_carrier_attack_1"
	hornet.EndSignal( "OnDeath" )
	hornet.EndSignal( "OnDestroy" )
	hornet.SetFadeDistance( 36000 )
	hornet.EnableRenderAlways()

	for ( ;; )
	{
		//DrawArrow( origin, angles, 30, 600 )
		//DebugDrawLine( origin, Vector(0,0,0), 255, 0, 0, true, 35.0 )
		//printt( "origin " + origin )
		waitthread PlayAnimTeleport( hornet, anim, origin, angles )
	}
}

function MegaCarrier_Changed()
{
	local carrier = level.nv.megaCarrier
	if ( carrier == null )
		return

	CarrierShipLauncherInit( carrier )

	if ( GetGameState() == eGameState.Playing )
	{
		local player = GetLocalViewPlayer()
		if ( player.GetTeam() == TEAM_MILITIA )
			thread MegaCarrierVDUFunc_Militia( carrier )
		else
		if ( player.GetTeam() == TEAM_IMC )
			thread MegaCarrierVDUFunc_IMC( carrier )

		thread MegaCarrierShips( carrier )
	}

	ClearEndingShips()
}



//Copied from cl_mp_fracture. Should remove if after we do angel city intro we realize it's not needed
function ServerCallback_FractureLaptopFx( eHandle )
{
	local laptop = GetEntityFromEncodedEHandle( eHandle )
	if ( !IsValid( laptop ) )
		return

	local fxID = GetParticleSystemIndex( "bish_comp_glow_01" )
	local attachID = laptop.LookupAttachment( "REF" )

	// blinking light FX
	StartParticleEffectOnEntity( laptop, fxID, FX_PATTACH_POINT_FOLLOW, attachID )
}

function RedeyeSpawnSky( worldOrigin )
{
	local origin = WorldToSkyCamera( worldOrigin )
//	printt( "sky origin for " + worldOrigin + " is " + origin )

	while ( !IsValid( level.nv.megaCarrier ) )
	{
		wait 1.0 //Shouldn't really happen unless we're triggering the epilogue manually.
	}
	local vec = level.nv.megaCarrier.GetOrigin() - worldOrigin
	local angles = VectorToAngles( vec )

	EmitSoundAtPosition( worldOrigin, "AngelCity_Scr_RedeyeWarpIn" )
	wait 2.0

	// Used by function CBaseEntity::ParentToMover()
	local model
	local fxName

	if ( RandomInt( 100 ) > 60 )
	{
		model = SKYBOX_REDEYE
		fxName = FX_REDEYE_WARPIN_SKYBOX
	}
	else
	{
		model = SKYBOX_BIRMINGHAM
		fxName = FX_BIRMINGHAM_WARPIN_SKYBOX
	}

	local fxid = GetParticleSystemIndex( fxName )
	StartParticleEffectInWorld( fxid, origin, angles )
	wait 0.8

	local ship = CreateClientsideScriptMover( model, origin, angles )
	ship.EndSignal( "OnDestroy" )

	level.endingShips.append( ship )
	ship.SetFadeDistance( -1 )
	ship.EnableRenderAlways()

	local forward = VectorCopy( vec )
	forward.Norm()

	local dist = RandomFloat( 7000, 10000 )
	local dest = origin + forward * ( dist / level.skyCameraScale )
	wait 2.0

	ship.NonPhysicsMoveTo( dest, 10.0, 0.0, 8.0 )

	wait RandomFloat( 19, 22 )

	local forward = GetFlyVec()
	local angles = VectorToAngles( forward )

	local dist = RandomFloat( 3500, 5000 )
	local time = Graph( dist, 0, 5500, 0, 10.0 )
	dist /= level.skyCameraScale

	local dest = ship.GetOrigin() + forward * dist
	ship.NonPhysicsMoveTo( dest, time, 0.0, time * 0.8 )
	ship.NonPhysicsRotateTo( angles, 4.0, 1.2, 1.2 )

	//DebugDrawLine( worldOrigin, level.nv.megaCarrier.GetOrigin(), 255, 0, 0, true, 15.0 )
	//DebugDrawLine( origin, level.nv.megaCarrier.GetOrigin(), 255, 255, 0, true, 15.0 )
	//wait 2.0



}

function GetFlyVec()
{
	local vec1 = Vector( 3644, 736, 8312 )
	local vec2 = Vector( 19833, -7944, 9361 )

	local vec = vec1 - vec2
	vec.Norm()
	return vec
}

function RedeyeSpawn( mdl, warpfx, origin, laterForwardDist )
{
	while ( !IsValid( level.nv.megaCarrier ) )
	{
		wait 1.0 //Shouldn't really happen unless we're triggering the epilogue manually.
	}
	local vec = level.nv.megaCarrier.GetOrigin() - origin
	local angles = VectorToAngles( vec )

	EmitSoundAtPosition( origin, "AngelCity_Scr_RedeyeWarpIn" )
	wait 2.0
//	local fx = PlayFX( FX_REFUEL_SHIP_WARPIN, origin, angles )
	local fxid = GetParticleSystemIndex( warpfx )
	StartParticleEffectInWorld( fxid, origin, angles )

	wait 0.8

	// Used by function CBaseEntity::ParentToMover()
	local ship = CreateClientsideScriptMover( mdl, origin, angles )
	ship.EndSignal( "OnDestroy" )

	level.endingShips.append( ship )
	ship.SetFadeDistance( -1 )

	local carrier = level.nv.megaCarrier
	if ( IsValid( carrier ) )
		delaythread( 3.0 ) ShipFiresFromOriginToTargetShip( ship, carrier )

	ship.EnableRenderAlways()
	if ( !Flag( "RedeyeArrives" ) )
	{
		EmitSoundOnEntity( ship, "AngelCity_Scr_RedeyeFlyIn" )
		FlagSet( "RedeyeArrives" )
	}

	local forward = VectorCopy( vec )
	forward.Norm()

	local dest = origin + forward * 7500
	ship.NonPhysicsMoveTo( dest, 10.0, 0.0, 8.0 )

	//wait 2.0
	local anim = "flight_to_hover"
	if ( ship.Anim_HasSequence( anim ) )
	{
		local duration = ship.GetSequenceDuration( anim )
		ship.Anim_Play( anim )
		wait duration
	}
	else
	{
		wait 10
	}

	wait RandomFloat( 12, 14 )

	local forward = GetFlyVec()
	local angles = VectorToAngles( forward )

	local dist = laterForwardDist
	local dest = ship.GetOrigin() + forward * dist
	local time = Graph( dist, 0, 5500, 0, 10.0 )
	ship.NonPhysicsMoveTo( dest, time, 0.0, time * 0.8 )
	ship.NonPhysicsRotateTo( angles, 4.0, 1.2, 1.2 )

}

function ServerCallback_MilitiaFleetAttackMegaCarrier()
{
	thread AC_EndingAttack()
}

function ServerCallback_IMCVictoryCarrierMoves()
{
	local carrier = level.nv.megaCarrier
	if ( !IsValid( carrier ) )
		return

	carrier.Signal( "stop_hornet_attacks" )
	switch ( GetLocalViewPlayer().GetTeam() )
	{
		case TEAM_MILITIA:
			thread IMCVictoryVDU_Militia( carrier )
			break

		case TEAM_IMC:
			thread IMCVictoryVDU_IMC( carrier )
			break
	}
}

function AC_EndingAttack()
{
	local carrier = level.nv.megaCarrier
	if ( !IsValid( carrier ) )
		return

	switch ( GetLocalViewPlayer().GetTeam() )
	{
		case TEAM_MILITIA:
			thread MilitiaVictoryVDU_Militia( carrier )
			break

		case TEAM_IMC:
			thread MilitiaVictoryVDU_IMC( carrier )
			break
	}

	carrier.Signal( "stop_hornet_attacks" )
	level.ent.Signal( "ending_militia_attack" )
	ClearEndingShips()

	wait 3.0
	thread RedeyeAttack()

	local skyVec = Vector( 7855, -3593, 3372 )
	delaythread( 3.0 ) HornetsSwarmCarrierFromOrigin( carrier, skyVec )
}

function ClearEndingShips()
{
	foreach ( ship in clone	level.endingShips )
	{
		if ( IsValid( ship ) )
			ship.Destroy()
	}

	level.endingShips = []
}

function ServerCallback_IMCIntroHornetExplosion( hornetEHandle )
{
	local hornet = GetEntityFromEncodedEHandle( hornetEHandle )
	if ( !IsValid( hornet ) )
		return

	thread IMCIntroHornetExplosion( hornet )
}

function IMCIntroHornetExplosion( hornet )
{
	Assert( IsValid( hornet ) )

	ModelFX_DisableGroup( hornet, "thrusters" )
	ModelFX_DisableGroup( hornet, "foe_lights" )
	ModelFX_DisableGroup( hornet, "friend_lights" )
}

function SetVDU_MilitiaWarpIn( player )
{
	local org = Vector( -2645, 4932, 392 )
 	local ang = Vector( -30, -42, 0 )
	level.camera.SetOrigin( org )
	level.camera.SetAngles( ang )
	level.camera.SetFOV( 24 )
}

function MilitiaVictoryVDU_IMC( megaCarrier )
{
	Assert( IsAlive( megaCarrier ) )
	local player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )

	if ( IsLockedVDU() )
		return

	OnThreadEnd(
		function () : ()
		{
			thread DelayedUnlockVDU( 4 )
		}
	)

	// take over the vdu screen
	LockVDU()
	ShowVDU()

	level.camera.SetFOV( 50 )
	//AddMusic( convRef, "mp.music.won" )

	//	Spyglass: Warning! Mass jump signatures detected! Enemy fleet incoming!
	local duration = DisplayVDU( player, "spyglass", "diag_cmp_angc_imc_spyglass_imcloseannc_21_1" )
	wait duration

	SetVDU_MilitiaWarpIn( player )
	wait 5.0

	local org = Vector( 2981, -1095, 3520 )
	local org = Vector( -1535, -1179, 201 )

	local startFov = 80
	local endFov = 30
	level.camera.SetFOV( startFov )

	if ( !IsAlive( megaCarrier ) )
		return
	waitthread TrackEntityWithCamera( player, org, megaCarrier, 1.0, 0, 1000 )

	if ( !IsAlive( megaCarrier ) )
		return

	local sceneTime = 4.3
	thread TrackEntityWithCamera( player, org, megaCarrier, sceneTime, 0, 1000 )
	thread ZoomCameraOverTime( player, startFov, endFov, 0.5, 0, 0.5 )
	wait sceneTime

	HideVDU()
	wait 0.4

	//	Graves: All forces, brace for impact! (Explosion) Blisk, they just took out the flight deck, I'm cancelling the operation. Get your forces to the evac point, we're jumping out!
	local duration = DisplayVDU( player, "graves", "diag_cmp_angc_imc_graves_imcloseannc_21_2" ) //Note that the animation plays the sound alias diag_cmp_angc_imc_graves_imcloseannc_21_2_all
	wait duration

	HideVDU()
	wait 0.4

	//	Blisk: The dropships aren't going to wait for you. Get to the evac point, now!
	local duration = DisplayVDU( player, "blisk", "diag_cmp_angc_imc_blisk_imcloseannc_21_3" )
	wait duration

	HideVDU()
	wait 0.9
}

function MilitiaVictoryVDU_Militia( megaCarrier )
{
	Assert( IsAlive( megaCarrier ) )
	local player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )

	if ( IsLockedVDU() )
		return

	OnThreadEnd(
		function () : ()
		{
			thread DelayedUnlockVDU( 4 )
		}
	)


	// take over the vdu screen
	LockVDU()
	wait 4.0
	ShowVDU()



	SetVDU_MilitiaWarpIn( player )
	wait 3.0

	//Grunt:  All Militia forces, this is the Dakota. 3rd Merchant Fleet at your service. We'll take it from here.
	local duration = EmitSoundOnEntity( player, "diag_cmp_angc_mcor_mcru1_milWinAnnc_126_1a" )

	wait 6.0


	local org = Vector( 2981, -1095, 3520 )
	local org = Vector( -1535, -1179, 201 )

	local startFov = 80
	local endFov = 30
	level.camera.SetFOV( startFov )

	if ( !IsAlive( megaCarrier ) )
		return
	waitthread TrackEntityWithCamera( player, org, megaCarrier, 1.0, 0, 1000 )

	if ( !IsAlive( megaCarrier ) )
		return

	local sceneTime = 4.3
	thread TrackEntityWithCamera( player, org, megaCarrier, sceneTime, 0, 1000 )
	thread ZoomCameraOverTime( player, startFov, endFov, 0.5, 0, 0.5 )
	wait sceneTime

	HideVDU()
	wait 0.4


	//Bish: Ok pilots, our little diversion - and by diversion, I mean total ass whoopin' - was a complete success. Mac, you clear?
	local duration = DisplayVDU( player, "bish", "diag_cmp_angc_mcor_bish1_milWinAnnc_126_2" )
	wait duration

	HideVDU()
	wait 0.4

	//Mac: Roger that! The package is secure, we'll see you back at base! MacAllan out.
	local duration = DisplayVDU( player, "mac", "diag_cmp_angc_mcor_macal_milWinAnnc_126_3" )
	wait duration

	HideVDU()
	wait 0.9

	//Sarah: // Well done guys! The IMC are attempting to escape by dropship, but I've marked their extraction points for you. Don't let them get away!
	local duration = DisplayVDU( player, "sarah", "diag_mcor_sarah_gs_EvacAnnc_mcorWin_73" )
	wait duration


	//local org = Vector( 10733, 1738, 5805 )
	//level.camera.SetFOV( 40 )
	//waitthread TrackEntityWithCamera( player, org, megaCarrier, 10.0, 0, 1000 )

}



function RedeyeAttack()
{
	FlagClear( "RedeyeArrives" ) // set by first redeye

	delaythread( 0.1 ) RedeyeSpawn( LARGE_REFUEL_SHIP_MODEL, FX_REFUEL_SHIP_WARPIN, Vector(13160.546875, -11739.704102, 11090.295898), 12000 )
	delaythread( 1.2 ) RedeyeSpawn( CAPSHIP_BIRM_MODEL, FX_SKYBOX_BERMINGHAM_WARP_IN, Vector(12620.750000, -5219.692383, 10962.765625), 9000 )
	delaythread( 2.5 ) RedeyeSpawn( CAPSHIP_BIRM_MODEL, FX_SKYBOX_BERMINGHAM_WARP_IN, Vector(13916.974609, 1728.861084, 6689.084961), 10000 )

//	wait 4.5
	wait 1.2
	delaythread( 0.1 ) RedeyeSpawnSky( Vector(14653.737305, -21257.986328, 9047.285156))
	delaythread( 0.1 ) RedeyeSpawnSky( Vector(13166.470703, -32261.943359, 21986.433594))
	delaythread( 1.5 ) RedeyeSpawnSky( Vector(18271.558594, -15423.095703, 21986.433594))
	delaythread( 0.6 ) RedeyeSpawnSky( Vector(20377.906250, -16153.795898, 10801.251953))

	wait 2.5

	delaythread( 1.3 ) RedeyeSpawnSky( Vector(22151.320313, 296.948822, 18456.525391))
	delaythread( 0.5 ) RedeyeSpawnSky( Vector(24308.724609, 1417.489746, 8624.309570))
	delaythread( 1.7 ) RedeyeSpawnSky( Vector(26698.083984, -5997.737305, 13649.455078))
	delaythread( 0.5 ) RedeyeSpawnSky( Vector(24789.458984, -32289.388672, 15550.090820))

	wait 2.4

	delaythread( 0.4 ) RedeyeSpawnSky( Vector(30979.833984, 14131.179688, 5128.991211))
	delaythread( 1.3 ) RedeyeSpawnSky( Vector(29145.902344, 19969.970703, 9236.230469))
	delaythread( 0.1 ) RedeyeSpawnSky( Vector(40624.398438, -15658.500000, 21698.574219))
	delaythread( 1.5 ) RedeyeSpawnSky( Vector(40797.582031, 5850.094727, 14404.196289))
}


function MegaCarrierVDUFunc_Militia( megaCarrier )
{
	megaCarrier.EndSignal( "idling" )
	//// if we're at some other start point, carrier wont be there
	//if ( Distance( megaCarrier.GetOrigin(), Vector(13867, -13010, 7549) ) > 100 )
	//	return

	Assert( IsAlive( megaCarrier ) )
	megaCarrier.EndSignal( "OnDeath" )
	megaCarrier.EndSignal( "OnDestroy" )


	local player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )

	if ( IsLockedVDU() )
		return

	OnThreadEnd(
		function () : ()
		{
			level.camera.SetFogEnable( false )
			UnlockVDU()
			HideVDU()
		}
	)


	// take over the vdu screen
	LockVDU()
	wait 1.5 // imc vdu starts earlier
	ShowVDU()

	//Sarah: Bish, I'm picking up a massive jump signature over the city. I don't know what it is, but it's big, and... woah, head's up!
	local duration = DisplayVDU( player, "sarah", "diag_cmp_angc_mcor_sarah_megacarrierwarp_423_1" )
	wait duration

	local camOrg

	local startFov = 70
	local endFov = 25
	delaythread( 1.0 ) ZoomCameraOverTime( player, startFov, endFov, 0.45, 0, 0.45 )

	local org = Vector( -3160, 3424, 390 )
	level.camera.SetFOV( startFov )
	thread TrackEntityWithCamera( player, org, megaCarrier, 1000, 800 )

	wait 1.2

	//Bish: Oh great. Mac, an IMC carrier just jumped in. You better get Barker outta there, quick
	local duration = EmitSoundOnEntity( player, "diag_cmp_angc_mcor_bish1_megacarrierwarp_423_2" )
	local endTime = Time() + duration
	wait 4.0

	level.camera.SetFOV( 40 )
	local org = Vector( -8728, -8060, 3155 )
	level.camera.SetFogEnable( true )
	thread TrackEntityWithCamera( player, org, megaCarrier, 1000, 2900 )


	local remainingTime = endTime - Time()
	if ( remainingTime > 0 )
		wait remainingTime + 0.3

	//Mac: Copy that. We’re moving out!  Advise fighters to target the MegaCarrier’s aft stabilizer.
	local duration = EmitSoundOnEntity( player, "diag_cmp_angc_mcor_macal_MegaPreArrv_38_3" )
	wait duration + 0.3

  HideVDU() //TODO: Come back and do more work on changing the angles on the megacarrier etc.

	//Sarah: MacAllan, our fighters can’t take the Sentinel down. There's no way.
	local duration = EmitSoundOnEntity( player, "diag_cmp_angc_mcor_sarah_MegaPreArrv_38_4" )
	wait duration + 0.3

    //Mac: Maybe. But they don’t have to take her down. Just hurt her.
	local duration = EmitSoundOnEntity( player, "diag_cmp_angc_mcor_macal_MegaPreArrv_38_5" )
	wait duration + 0.3

	//Sarah: It's a suicide mission!
	local duration = EmitSoundOnEntity( player, "diag_cmp_angc_mcor_sarah_MegaPreArrv_38_6" )
	wait duration + 0.3

	//Mac: Trust me - launch the fighters.
	local duration = EmitSoundOnEntity( player, "diag_cmp_angc_mcor_macal_MegaPreArrv_38_7" )
	wait duration + 0.3

	//Bish: Sarah, he's in command now. I'm launching the fighters. Hornets, target the Sentinel's aft stabilizer.
	local duration = EmitSoundOnEntity( player, "diag_cmp_angc_mcor_bish_MegaPreArrv_38_8" )
	wait duration + 0.3


//	AddVDURadio( convRef, "sarah", null, "diag_cmp_angc_mcor_sarah_megacarrierwarp_423_4" )


//	level.camera.SetFOV( 60 )
//	//local org = Vector( 14416, 7760, 2219 )
//	local org = Vector( -1372, 5104, 317 )
//	waitthread TrackEntityWithCamera( player, org, megaCarrier, 8.0, 2500 )

//	//local org = Vector( 2030, -2100, 518 )
//	//local org = Vector( 1919, -1782, 457 )
//	local org = Vector( 1779, -1639, 457 )
//	waitthread TrackEntityWithCamera( player, org, megaCarrier, 8.0, 0 )
}



function MegaCarrierVDUFunc_IMC( megaCarrier )
{
	megaCarrier.EndSignal( "idling" )
	GetLocalViewPlayer().Signal( "vdu_open" )

	//// if we're at some other start point, carrier wont be there
	//if ( Distance( megaCarrier.GetOrigin(), Vector(13867, -13010, 7549) ) > 100 )
	//	return

	Assert( IsAlive( megaCarrier ) )
	megaCarrier.EndSignal( "OnDeath" )
	megaCarrier.EndSignal( "OnDestroy" )

	local player = GetLocalClientPlayer()

	if ( player != GetLocalViewPlayer() )
		return
	if ( IsWatchingKillReplay() )
		return

	player.EndSignal( "OnDestroy" )

	if ( IsLockedVDU() )
		return

	OnThreadEnd(
		function () : ()
		{
			level.camera.SetFogEnable( false )
			UnlockVDU()
			HideVDU()
		}
	)


	// take over the vdu screen
	LockVDU()
	ShowVDU()

	local duration = DisplayVDU( player, "spyglass", "diag_cmp_angc_imc_spygl_megacarrierwarp_424_1" )
	wait duration

	local camOrg

	local startFov = 70
	local endFov = 25
	delaythread( 1.0 ) ZoomCameraOverTime( player, startFov, endFov, 0.45, 0, 0.45 )

	local org = Vector( -3160, 3424, 390 )
	level.camera.SetFOV( startFov )
	thread TrackEntityWithCamera( player, org, megaCarrier, 1000, 800 )

	wait 5.0

	level.camera.SetFOV( 40 )
	//local org = Vector(-7600, -7336, 7616 )
	local org = Vector( -8728, -8060, 3155 )
	level.camera.SetFogEnable( true )
	waitthread TrackEntityWithCamera( player, org, megaCarrier, 4.0, 2900 )

	HideVDU()
	wait 0.4

	local duration = DisplayVDU( player, "graves", "diag_cmp_angc_imc_grave_megacarrierwarp_424_2" )
	wait duration
	HideVDU()
	wait 0.4
//	local endTime = Time() + duration
//	wait 4.0
//
//	local remainingTime = endTime - Time()
//	if ( remainingTime > 0 )
//		wait remainingTime + 0.3

	local duration = DisplayVDU( player, "blisk", "diag_cmp_angc_imc_blisk_megacarrierwarp_424_3" )
	wait duration

	level.camera.SetFOV( 40 )
	local org = Vector( -8728, -8060, 3155 )
	thread TrackEntityWithCamera( player, org, megaCarrier, 1000, 2900 )

	player.Signal( "vdu_open" )



//	AddVDURadio( convRef, "sarah", null, "diag_cmp_angc_mcor_sarah_megacarrierwarp_423_4" )


//	level.camera.SetFOV( 60 )
//	//local org = Vector( 14416, 7760, 2219 )
//	local org = Vector( -1372, 5104, 317 )
//	waitthread TrackEntityWithCamera( player, org, megaCarrier, 8.0, 2500 )

//	//local org = Vector( 2030, -2100, 518 )
//	//local org = Vector( 1919, -1782, 457 )
//	local org = Vector( 1779, -1639, 457 )
//	waitthread TrackEntityWithCamera( player, org, megaCarrier, 8.0, 0 )
}



function IMCVictoryVDU_Militia( megaCarrier )
{
	//megaCarrier.EndSignal( "idling" )
	//// if we're at some other start point, carrier wont be there
	//if ( Distance( megaCarrier.GetOrigin(), Vector(13867, -13010, 7549) ) > 100 )
	//	return

	Assert( IsAlive( megaCarrier ) )
	megaCarrier.EndSignal( "OnDeath" )
	megaCarrier.EndSignal( "OnDestroy" )

	local player = GetLocalClientPlayer()

	if ( player != GetLocalViewPlayer() )
		return
	if ( IsWatchingKillReplay() )
		return

	player.EndSignal( "OnDestroy" )

	if ( IsLockedVDU() )
		return

	OnThreadEnd(
		function () : ()
		{
			UnlockVDU()
			HideVDU()
		}
	)


	// take over the vdu screen
	LockVDU()

	// Bish: Pilots, the battle's over - we've taken too many losses. Fall back and secure the evac point for extraction. Mac, what's your status!
	local duration = DisplayVDU( player, "bish", "diag_cmp_angc_mcor_bish1_milLoseAnnc_129_1" )
	wait duration

	HideVDU()
	wait 1.4

	// Mac: We got Barker and we're clear - but just barely. See you back on the Redeye.
	local duration = DisplayVDU( player, "mac", "diag_cmp_angc_mcor_macal_milLoseAnnc_129_2" )
	wait duration

	HideVDU()
	wait 1.0


	local camOrg
	local endTime



	ShowVDU()
	level.camera.SetFOV( 46 )
	local org = Vector( -2036, 749, 531 )
	//local org = Vector( -8728, -8060, 3155 )
	waitthread TrackEntityWithCamera( player, org, megaCarrier, 7.0, 2900 )


	local startFov = 67
	local endFov = 36

	level.camera.SetFOV( startFov )
	delaythread( 1.4 ) ZoomCameraOverTime( player, startFov, endFov, 0.45, 0, 0.45 )

	local org = Vector( -8728, -8060, 3155 )
	waitthread TrackEntityWithCamera( player, org, megaCarrier, 6.0, 2900 )


	HideVDU()
	wait 0.4

	//Sarah: "We've lost this sector to the IMC. I'm sending in the dropships. Check your HUD and get to the nearest evac point!"
	local duration = DisplayVDU( player, "sarah", "diag_mcor_sarah_bonus_frac_dustoff_lost_02" )
	wait duration

//	level.camera.SetFOV( 60 )
//	//local org = Vector( 14416, 7760, 2219 )
//	local org = Vector( -1372, 5104, 317 )
//	waitthread TrackEntityWithCamera( player, org, megaCarrier, 8.0, 2500 )

//	//local org = Vector( 2030, -2100, 518 )
//	//local org = Vector( 1919, -1782, 457 )
//	local org = Vector( 1779, -1639, 457 )
//	waitthread TrackEntityWithCamera( player, org, megaCarrier, 8.0, 0 )
}


function IMCVictoryVDU_IMC( megaCarrier )
{
	Assert( IsAlive( megaCarrier ) )
	megaCarrier.EndSignal( "OnDeath" )
	megaCarrier.EndSignal( "OnDestroy" )
	//megaCarrier.EndSignal( "idling" )

	local player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )

	if ( IsLockedVDU() )
		return

	OnThreadEnd(
		function () : ()
		{
			UnlockVDU()
			HideVDU()
		}
	)


	// take over the vdu screen
	LockVDU()

	wait 4.5
	// Blisk: That’s it, we've got them on the run.  Sir, we've established control of the Harbor District.
	local duration = DisplayVDU( player, "blisk", "diag_cmp_angc_imc_blisk_imcwinannc_14_2a" )
	wait duration

	local camOrg
	local endTime

	local startFov = 80
	local endFov = 50
	level.camera.SetFOV( startFov )
	delaythread( 2.5 ) ZoomCameraOverTime( player, startFov, endFov, 0.45, 0, 0.45 )


	local org = Vector( 4184, 3312, 958 )
	thread TrackEntityWithCamera( player, org, megaCarrier, 999, 2500 )
	wait 1.0

//	player.Signal( "vdu_open" )
	// Graves: Copy that, good work everyone. Now let's finish off the stragglers.
	local duration = EmitSoundOnEntity( player, "diag_cmp_angc_imc_graves_imcwinannc_14_3" )
	wait duration

	// Spyblass: Be advised, the Militia forces have been defeated, but enemy survivors remain in your area. Do not allow them to escape.
	local duration = EmitSoundOnEntity( player, "diag_imc_spyglass_cmp_frac_dustoff_won_1_1" )

	level.camera.SetFOV( 33 )
	//local org = Vector(-7600, -7336, 7616 )
	local org = Vector( -8728, -8060, 3155 )
	waitthread TrackEntityWithCamera( player, org, megaCarrier, 6.0, 2900 )


//	level.camera.SetFOV( 60 )
//	//local org = Vector( 14416, 7760, 2219 )
//	local org = Vector( -1372, 5104, 317 )
//	waitthread TrackEntityWithCamera( player, org, megaCarrier, 8.0, 2500 )

//	//local org = Vector( 2030, -2100, 518 )
//	//local org = Vector( 1919, -1782, 457 )
//	local org = Vector( 1779, -1639, 457 )
//	waitthread TrackEntityWithCamera( player, org, megaCarrier, 8.0, 0 )
}
