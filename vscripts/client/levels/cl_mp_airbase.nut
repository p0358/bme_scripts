
const MUZZLEFLASH_FX = "wpn_muzzleflash_redeye_turret"
const ROCKET_EXPLOSION_FX = "P_dog_w_impact_1"
const ROCKET_FX = "Rocket_Smoke_Swirl_MD"
const ROCKET_EXPLOSION_SKYBOX_FX = "P_exp_leviathon_SB"
const ROCKET_SKYBOX_FX = "Rocket_Smoke_Swirl_SB"
const SHIP_CRUSH_FX = "P_veh_gunship_exp_SB"
const LEVIATHAN_SPOTLIGHT_FX = "P_lev_spotlight"
const LEVIATHAN_SPOTLIGHT_LARGE_FX = "P_lev_spotlight_LG"

const TOWER_LIGHT = "tower_light_red"

enum eRadarState
{
	IDLE_ROTATE,
	DECEL,
	BLEND_TO_ATTACHMENT,
	DONE
}

function main()
{
	Globalize( VMTCallback_AirbaseGetCarrierAlpha )
	Globalize( ServerCallback_FightersKillLeviathan )
	Globalize( CE_VisualSettingAirbaseMCOR )

	IncludeFile( "_flyers_shared" )
	IncludeFile( "client/cl_fighters" )
	IncludeFileAllowMultipleLoads( "client/objects/cl_phantom_fighter" )
	IncludeFileAllowMultipleLoads( "client/objects/cl_bomber" )
	IncludeFileAllowMultipleLoads( "client/objects/cl_ai_turret" )
	IncludeFileAllowMultipleLoads( "client/objects/cl_hologram_projector" )

	PrecacheParticleSystem( MUZZLEFLASH_FX )
	PrecacheParticleSystem( ROCKET_EXPLOSION_FX )
	PrecacheParticleSystem( ROCKET_FX )
	PrecacheParticleSystem( ROCKET_EXPLOSION_SKYBOX_FX )
	PrecacheParticleSystem( ROCKET_SKYBOX_FX )
	PrecacheParticleSystem( LEVIATHAN_SPOTLIGHT_FX )
	PrecacheParticleSystem( LEVIATHAN_SPOTLIGHT_LARGE_FX )
	PrecacheParticleSystem( SHIP_CRUSH_FX )
	PrecacheParticleSystem( FX_GUNSHIP_CRASH_EXPLOSION_EXIT )
	PrecacheParticleSystem( FX_GUNSHIP_CRASH_EXPLOSION_ENTRANCE )
	PrecacheParticleSystem( TOWER_LIGHT )

	RegisterSignal( "tower_down" )
	RegisterSignal( "leviathan_spotlight_stop" )
	RegisterSignal( "fighters_attack_leviathan" )

	level.sequenceArray					<- []
	level.runAnimNum					<- 0

	level.skyboxCamOrigin <- Vector( -10688.0, 7584.0, -6400.0 )

	level.cpuIsHighEnd <- GetCPULevel() == CPU_LEVEL_HIGHEND

	level.towerMain <- null
	level.towerAlpha <- null
	level.towerCharlie <- null
	level.leviathanMapStart1 <- null
	level.leviathanMapStart2 <- null
	level.leviathanMapStart3 <- null
	level.leviathanAlphaDown1 <- null
	level.leviathanAlphaDown1ShouldSpotlight <- true
	level.leviathanAlphaDown2 <- null
	level.leviathanAlphaDown2ShouldSpotlight <- true
	level.leviathanAlphaDown3 <- null
	level.leviathanAlphaDown3ShouldSpotlight <- true
	level.leviathanCharlieDown1 <- null
	level.leviathanCharlieDown1ShouldSpotlight <- true
	level.carrier <- null

	level.leviathanAlphaDown1CrushShips <- []
	level.leviathanCharlieDown1CrushShips <- []

	level.crush_leviathans <- []

	level.propDynamicCreateCallbacks	<- {	militiaWinDropship1 =			MilitiaWinShipCreated,
												militiaWinDropship2 =			MilitiaWinShipCreated,
												militiaWinStraton1 =			MilitiaWinShipCreated,
												militiaWinStraton2 =			MilitiaWinShipCreated,
												militiaWinBomber =				MilitiaWinBomberCreated,
												prop_airbase_tower_main =		PropAirbaseTowerMainCreated,
												prop_airbase_tower_alpha =		PropAirbaseTowerAlphaCreated,
												prop_airbase_tower_charlie = 	PropAirbaseTowerCharlieCreated,
												leviathan_map_start_1 = 		LeviathanMapStart1Created,
												leviathan_map_start_2 =			LeviathanMapStart2Created,
												leviathan_map_start_3 =			LeviathanMapStart3Created,
												leviathan_map_start_4 =			LeviathanMiscCreated,
												leviathan_map_start_5 =			LeviathanMiscCreated,
												leviathan_map_start_6 =			LeviathanMiscCreated,
												leviathan_alpha_down_1 =		LeviathanAlphaDown1Created,
												leviathan_alpha_down_2 =		LeviathanAlphaDown2Created,
												leviathan_alpha_down_3 =		LeviathanAlphaDown3Created,
												leviathan_charlie_down_1 = 		LeviathanCharlieDown1Created,
												carrier1 =						IMCWinCarrierCreated,
												wallace2 =						IMCWinWallaceCreated,
												wallace3 =						IMCWinWallaceCreated,
												wallace4 =						IMCWinWallaceCreated,
												wallace5 =						IMCWinWallaceCreated,
												wallace6 =						IMCWinWallaceCreated,
												wallace7 =						IMCWinWallaceCreated,
												wallace8 =						IMCWinWallaceCreated,
												wallace9 =						IMCWinWallaceCreated,
												wallace10 =						IMCWinWallaceCreated }

	level.militiaWinTowerRocketPositions <- [
		{ origin = Vector( -2791.0, 3334.0, 1731.0 ),	angles = Vector( -16.0, -141.0, 0.0 ),	forward = Vector( -0.747041, -0.604942, 0.275637 ) },
		{ origin = Vector( -2099.0, 3372.0, 1758.0 ),	angles = Vector( -16.0, -53.0, 0.0 ),	forward = Vector( 0.578502, -0.767698, 0.275637 ) },
		{ origin = Vector( -2770.0, 3656.0, 1777.0 ),	angles = Vector( -16.0, 135.0, 0.0 ),	forward = Vector( -0.679715, 0.679715, 0.275637 ) },
		{ origin = Vector( -2086.0, 3671.0, 1727.0 ),	angles = Vector( -16.0, 45.0, 0.0 ),	forward = Vector( 0.679715, 0.679715, 0.275637 ) },
		{ origin = Vector( -2547.0, 3626.0, 2142.0 ),	angles = Vector( -10.0, 135.0, 0.0 ),	forward = Vector( -0.696364, 0.696364, 0.173648 ) },
		{ origin = Vector( -2274.0, 3372.0, 2323.0 ),	angles = Vector( -3.9, -52.0, 0.0 ),	forward = Vector( 0.614236, -0.786186, 0.068015 ) },
		{ origin = Vector( -2433.0, 3126.0, 1337.0 ),	angles = Vector( -15.9, -105.0, 0.0 ),	forward = Vector( -0.248917, -0.928971, 0.273959 ) },
		{ origin = Vector( -2439.0, 3807.0, 1497.0 ),	angles = Vector( -6.5, 86.0, 0.0 ),		forward = Vector( 0.069308, 0.991152, 0.113203 ) },
		{ origin = Vector( -2334.0, 3677.0, 2507.0 ),	angles = Vector( -10.0, 60.0, 0.0 ),	forward = Vector( 0.492404, 0.852869, 0.173648 ) },
		{ origin = Vector( -2353.0, 3307.0, 2015.0 ),	angles = Vector( -10.0, -60.0, 0.0 ),	forward = Vector( 0.492404, -0.852869, 0.173648 ) },
		{ origin = Vector( -1959.0, 3503.0, 1150.0 ),	angles = Vector( -15.0, -4.0, 0.0 ),	forward = Vector( 0.963573, -0.067380, 0.258819 ) },
		{ origin = Vector( -2994.0, 3197.0, 1361.0 ),	angles = Vector( -20.0, -143.0, 0.0 ),	forward = Vector( -0.750472, -0.565521, 0.342020 ) },
		{ origin = Vector( -2936.0, 3806.0, 1443.0 ),	angles = Vector( 0.0, -180.0, 0.0 ),	forward = Vector( -1.000000, 0.000000, -0.000000 ) },
		{ origin = Vector( -2047.0, 3463.0, 1782.0 ),	angles = Vector( -20.0, 2.0, 0.0 ),		forward = Vector( 0.939120, 0.032795, 0.342020 ) },
		{ origin = Vector( -1825.0, 3907.0, 1167.0 ),	angles = Vector( 0.0, -320.0, 0.0 ),	forward = Vector( 0.766044, 0.642788, -0.000000 ) },
		{ origin = Vector( -1965.0, 3582.0, 1167.0 ),	angles = Vector( 1.0, 41.0, 0.0 ),		forward = Vector( 0.754595, 0.655959, -0.017452 ) },
		{ origin = Vector( -1902.0, 3764.0, 1569.0 ),	angles = Vector( 7.0, 36.0, 0.0 ),		forward = Vector( 0.802987, 0.583404, -0.121869 ) },
		{ origin = Vector( -2760.0, 3551.0, 1369.0 ),	angles = Vector( -14.0, 197.0, 0.0 ),	forward = Vector( -0.927898, -0.283687, 0.241922 ) },
		{ origin = Vector( -2794.0, 3534.0, 1707.0 ),	angles = Vector( -8.0, 194.0, 0.0 ),	forward = Vector( -0.960853, -0.239567, 0.139173 ) },
		{ origin = Vector( -1854.0, 3877.0, 1295.0 ),	angles = Vector( -8.0, 42.0, 0.0 ),		forward = Vector( 0.735913, 0.662619, 0.139173 ) },
		{ origin = Vector( -2285.0, 3738.0, 1263.0 ),	angles = Vector( -10.0, 44.0, 0.0 ),	forward = Vector( 0.708411, 0.684105, 0.173648 ) },
		{ origin = Vector( -2339.0, 3812.0, 1465.0 ),	angles = Vector( -10.0, 48.0, 0.0 ),	forward = Vector( 0.658965, 0.731855, 0.173648 ) },
		{ origin = Vector( -2336.0, 3661.0, 1437.0 ),	angles = Vector( -4.0, -317.0, 0.0 ),	forward = Vector( 0.729572, 0.680337, 0.069756 ) },
		{ origin = Vector( -2425.0, 3883.0, 1437.0 ),	angles = Vector( -12.0, -291.0, 0.0 ),	forward = Vector( 0.350537, 0.913180, 0.207912 ) },
		{ origin = Vector( -2407.0, 3840.0, 1560.0 ),	angles = Vector( -14.0, -280.0, 0.0 ),	forward = Vector( 0.168490, 0.955555, 0.241922 ) }
	]

	RegisterSignal( "TowerAlphaDown" )
	RegisterSignal( "TowerCharlieDown" )

	RegisterServerVarChangeCallback( "MCORClientTiming", MCORClientTimingEvents )
	RegisterServerVarChangeCallback( "towerMainAttackStarted", ServerCallback_TowerMainAttackStarted )
	RegisterServerVarChangeCallback( "towerMainFalling", ServerCallback_TowerMainFalling )
	RegisterServerVarChangeCallback( "towerMainDown", ServerCallback_TowerMainDown )
	RegisterServerVarChangeCallback( "towerCharlieFalling", ServerCallback_TowerCharlieFalling )
	RegisterServerVarChangeCallback( "towerCharlieDown", ServerCallback_TowerCharlieDown )
	RegisterServerVarChangeCallback( "towerAlphaFalling", ServerCallback_TowerAlphaFalling )
	RegisterServerVarChangeCallback( "towerAlphaDown", ServerCallback_TowerAlphaDown )
	RegisterServerVarChangeCallback( "fightersAttackLevStage", ServerCallback_FightersAttackLevStage )
	RegisterServerVarChangeCallback( "imcWinShipsTakeOff", ServerCallback_IMCWinShipsTakeOff )
	RegisterServerVarChangeCallback( "leviathanAlphaCrush", ServerCallback_LeviathanAlphaCrush )
	RegisterServerVarChangeCallback( "leviathanCharlieCrush", ServerCallback_LeviathanCharlieCrush )

	AddCreateCallback( "prop_dynamic", CreateCallback_PropDynamic )

	FlagInit( "flyers_initialized" )

	if ( GetCinematicMode() )
	{
		CinematicIntroScreen_SetText( TEAM_IMC, 	[ "#INTRO_SCREEN_AIRBASE_LINE1", "#INTRO_SCREEN_AIRBASE_LINE2", "#INTRO_SCREEN_AIRBASE_LINE3" ] )
		CinematicIntroScreen_SetText( TEAM_MILITIA, [ "#INTRO_SCREEN_AIRBASE_LINE1", "#INTRO_SCREEN_AIRBASE_LINE2", "#INTRO_SCREEN_AIRBASE_LINE3" ] )
	}

	if ( !IsCaptureMode() )
		CinematicIntroScreen_SetQuickIntro( TEAM_MILITIA )

	//SetDialogueDebugLevel( 3 )

	thread LeviathanCrusherThink()
	
	SetFullscreenMinimapParameters( 2.6, -1500, -400, -180 )
	if ( GAMETYPE == COOPERATIVE )
		SetCustomMinimapZoom( 2 )
}

function EntitiesDidLoad()
{
	FlyersInit()
	IMCWinShipsInit()
	TowerInit()
	SkyboxShipsInit()
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

function MilitiaWinShipCreated( ent )
{
	EndSignal( ent, "OnDestroy" )
	wait( 1.0 )
	ModelFX_DisableAllGroups( ent )
	AddAnimEvent( ent, "StartIdleFX", MilitiaWinShipFX )
	AddAnimEvent( ent, "StopIdleFX", MilitiaWinShipFXStop )
	AddAnimEvent( ent, "TowerAttackRockets", MilitiaWinShipShootRocket )
}

function MilitiaWinBomberCreated( ent )
{
	EndSignal( ent, "OnDestroy" )
	wait( 1.0 )
	ModelFX_DisableAllGroups( ent )
	AddAnimEvent( ent, "StartIdleFX", MilitiaWinBomberFX )
	AddAnimEvent( ent, "StopIdleFX", MilitiaWinShipFXStop )
	AddAnimEvent( ent, "TowerAttackRockets", MilitiaWinShipShootRocket )
}

function PropAirbaseTowerMainCreated( ent )
{
	level.towerMain = ent
}

function PropAirbaseTowerAlphaCreated( ent )
{
	level.towerAlpha = ent
}

function PropAirbaseTowerCharlieCreated( ent )
{
	level.towerCharlie = ent
}

function LeviathanMapStart1Created( ent )
{
	level.leviathanMapStart1 = ent

	thread FightersAttackLeviathanStartup( { ent = level.leviathanMapStart1,
											stageNum = 1,
											fixedPointX = -10693.0,
											fixedPointY = 7614.0,
											shipsPerWave = { min = level.cpuIsHighEnd ? 2 : 1, max = level.cpuIsHighEnd ? 3 : 2 } } )

	AddAnimEvent( ent, "LeviathanFootstep", LeviathanFootstep )
	AddAnimEvent( ent, "LeviathanReactionSmall", LeviathanReactionSmall )
	AddAnimEvent( ent, "LeviathanReactionBig", LeviathanReactionBig )
}

function LeviathanMapStart2Created( ent )
{
	level.leviathanMapStart2 = ent

	AddAnimEvent( ent, "LeviathanFootstep", LeviathanFootstep )
	AddAnimEvent( ent, "LeviathanReactionSmall", LeviathanReactionSmall )
	AddAnimEvent( ent, "LeviathanReactionBig", LeviathanReactionBig )
}

function LeviathanMapStart3Created( ent )
{
	level.leviathanMapStart3 = ent

	if ( level.cpuIsHighEnd )
	{
		thread FightersAttackLeviathanStartup( { ent = level.leviathanMapStart3,
												 stageNum = 3,
												 fixedPointX = -10658.15,
												 fixedPointY = 7618.46,
												 shipsPerWave = { min = 2, max = 3 } } )
	}

	AddAnimEvent( ent, "LeviathanFootstep", LeviathanFootstep )
	AddAnimEvent( ent, "LeviathanReactionSmall", LeviathanReactionSmall )
	AddAnimEvent( ent, "LeviathanReactionBig", LeviathanReactionBig )
	AddAnimEvent( ent, "LeviathanDeathVocal", LeviathanDeathVocal )
	AddAnimEvent( ent, "LeviathanBodyfall", LeviathanBodyfall )
	AddAnimEvent( ent, "LeviathanDeathImpact", LeviathanDeathImpact )
}

function LeviathanMiscCreated( ent )
{
	AddAnimEvent( ent, "LeviathanFootstep", LeviathanFootstep )
}

function LeviathanAlphaDown1Created( ent )
{
	level.leviathanAlphaDown1 = ent

	thread FightersAttackLeviathanStartup( { ent = level.leviathanAlphaDown1,
											stageNum = 1,
											fixedPointX = -10693.0,
											fixedPointY = 7604.0,
											shipsPerWave = { min = level.cpuIsHighEnd ? 2 : 2, max = level.cpuIsHighEnd ? 3 : 2 } } )

	thread LeviathanSpotlightAlphaStartup( {	ent = level.leviathanAlphaDown1,
												fxString = LEVIATHAN_SPOTLIGHT_FX,
												sourcePos = Vector( -10717.05, 7607.77, -6399.99 ),
												offset = Vector( 1.0, 1.0, -1.0 ),
												bob = Vector( 0.0, 0.6, 0.6 ),
												spotlightAttachments = [ "def_c_head", "def_c_neckE", "def_c_neckD", "def_c_neckC", "def_c_neckB", "def_c_neckA", "def_r_thighA" ],
												delay = 34.0
											} )

	thread LeviathanCrusherInitAlphaDown1()

	AddAnimEvent( ent, "LeviathanFootstep", LeviathanFootstep )
	AddAnimEvent( ent, "LeviathanReactionSmall", LeviathanReactionSmall )
	AddAnimEvent( ent, "LeviathanReactionBig", LeviathanReactionBig )
	AddAnimEvent( ent, "LeviathanDeathVocal", LeviathanDeathVocal )
	AddAnimEvent( ent, "LeviathanBodyfall", LeviathanBodyfall )
	AddAnimEvent( ent, "LeviathanDeathImpact", LeviathanDeathImpact )
}

function GetLeviathanAlphaDown1()
{
	return level.leviathanAlphaDown1
}

function LeviathanAlphaDown2Created( ent )
{
	level.leviathanAlphaDown2 = ent

	thread FightersAttackLeviathanStartup( { ent = level.leviathanAlphaDown2,
											stageNum = 2,
											fixedPointX = -10701.0,
											fixedPointY = 7568.0,
											shipsPerWave = { min = level.cpuIsHighEnd ? 2 : 1, max = level.cpuIsHighEnd ? 3 : 2 } } )

	thread LeviathanSpotlightAlphaStartup( {	ent = level.leviathanAlphaDown2,
												fxString = LEVIATHAN_SPOTLIGHT_LARGE_FX,
												sourcePos = Vector( -10717.05, 7607.77, -6399.99 ),
												offset = Vector( 3.0, 1.0, -1.0 ),
												bob = Vector( 0.0, 0.6, 0.6 ),
												spotlightAttachments = [ "def_c_head" ],
												delay = 150.0
											} )

	AddAnimEvent( level.leviathanAlphaDown2, "LeviathanFootstep", LeviathanFootstep )
}

function LeviathanAlphaDown3Created( ent )
{
	level.leviathanAlphaDown3 = ent

	if ( level.cpuIsHighEnd )
	{
		thread FightersAttackLeviathanStartup( { ent = level.leviathanAlphaDown3,
												 stageNum = 1,
												 fixedPointX = -10693.0,
												 fixedPointY = 7614.0,
												 shipsPerWave = { min = 2, max = 3 } } )
	}

	/*thread LeviathanSpotlightAlphaStartup( {	ent = level.leviathanAlphaDown3,
												fxString = LEVIATHAN_SPOTLIGHT_LARGE_FX,
												sourcePos = Vector( -10738.38, 7566.52, -6399.99 ),
												offset = Vector( 3.0, -1.0, -1.0 ),
												bob = Vector( 0.0, 0.6, 0.6 ),
												spotlightAttachments = [ "def_c_head", "def_c_neckE", "def_c_neckD", "def_c_neckC", "def_c_neckB", "def_c_neckA", "def_r_thighA" ],
												delay = 206.0
											} )*/

	AddAnimEvent( ent, "LeviathanFootstep", LeviathanFootstep )
	AddAnimEvent( ent, "LeviathanReactionSmall", LeviathanReactionSmall )
	AddAnimEvent( ent, "LeviathanReactionBig", LeviathanReactionBig )
}

function LeviathanCharlieDown1Created( ent )
{
	level.leviathanCharlieDown1 = ent

	thread FightersAttackLeviathanStartup( { ent = level.leviathanCharlieDown1,
											stageNum = 3,
											fixedPointX = -10658.15,
											fixedPointY = 7618.46,
											shipsPerWave = { min = level.cpuIsHighEnd ? 2 : 1, max = level.cpuIsHighEnd ? 3 : 2 } } )

	thread LeviathanSpotlightCharlieStartup ( {	ent = level.leviathanCharlieDown1,
												fxString = LEVIATHAN_SPOTLIGHT_FX,
												sourcePos = Vector( -10683.72, 7605.14, -6399.99 ),
												offset = Vector( 1.0, -1.5, -0.5 ),
												bob = Vector( 0.6, 0.0, 0.6 ),
												spotlightAttachments = [ "def_c_head" ],
												delay = 40.0
											} )

	thread LeviathanCrusherInitCharlieDown1()

	AddAnimEvent( ent, "LeviathanFootstep", LeviathanFootstep )
	AddAnimEvent( ent, "LeviathanReactionSmall", LeviathanReactionSmall )
	AddAnimEvent( ent, "LeviathanReactionBig", LeviathanReactionBig )
}

function GetLeviathanCharlieDown1()
{
	return level.leviathanCharlieDown1
}

function IMCWinCarrierCreated( ent )
{
	level.carrier = ent
}

function IMCWinWallaceCreated( ent )
{
	if ( level.nv.imcWinShipsTakeOff > 0.0 )
		EmitSoundOnAttachment( ent, "REF", "airbase_scr_imc_largeship_takeoff", true )
}

function ServerCallback_FightersAttackLevStage()
{
	if ( level.nv.fightersAttackLevStage >= 1 && level.nv.fightersAttackLevStage < 4 )
	{
		if ( IsValid( level.leviathanAlphaDown1 ) )
			Signal( level.leviathanAlphaDown1, "fighters_attack_leviathan" )
	}
	if ( level.nv.fightersAttackLevStage >= 2 ) // intentionally not else if
	{
		if ( IsValid( level.leviathanAlphaDown2 ) )
			Signal( level.leviathanAlphaDown2, "fighters_attack_leviathan" )

		if ( IsValid( level.leviathanAlphaDown3 ) )
			Signal( level.leviathanAlphaDown3, "fighters_attack_leviathan" )
	}
	if ( level.nv.fightersAttackLevStage >= 3 ) // intentionally not else if
	{
		if ( IsValid( level.leviathanMapStart3 ) && level.nv.fightersAttackLevStage < 4 )
			Signal( level.leviathanMapStart3, "fighters_attack_leviathan" )

		if ( IsValid( level.leviathanCharlieDown1 ) )
			Signal( level.leviathanCharlieDown1, "fighters_attack_leviathan" )
	}
}

function FightersAttackLeviathanStartup( leviathanInfo )
{
	EndSignal( leviathanInfo.ent, "OnDestroy" )

	if ( level.nv.fightersAttackLevStage < leviathanInfo.stageNum )
		WaitSignal( leviathanInfo.ent, "fighters_attack_leviathan" )

	while ( !IsValid( leviathanInfo.ent ) )
		wait( 0.0 )

	FightersAttackLeviathan( leviathanInfo.ent, leviathanInfo.fixedPointX, leviathanInfo.fixedPointY, { min = 1, max = 2 }, -1, leviathanInfo.shipsPerWave )
}

function FightersAttackLeviathan( leviathan, fixedPointX, fixedPointY, numClustersInWave, numWaves, shipsPerWave )
{
	local rocket = CreateFighterRocketTable()
	rocket.speed = { min = 12.0, max = 14.0 }
	rocket.fireDistance = { min = 1.1, max = 2000.0 }
	rocket.refireDelay = { min = level.cpuIsHighEnd ? 1.2 : 1.6, max = level.cpuIsHighEnd ? 1.6 : 2.0 }
	rocket.fxRocket = ROCKET_SKYBOX_FX
	rocket.fxExplosion = ROCKET_EXPLOSION_SKYBOX_FX
	rocket.inSkybox = true

	local fighter = CreateFighterTable()
	fighter.model = STRATON_SKYBOX_MODEL
	fighter.attackPattern = "straight"
	fighter.rocketInfo = rocket
	fighter.distanceToTarget = 12.0
	fighter.attackAngles = eFighterAngles.FIXED_POINT_2D
	fighter.fixedPoint = Vector( fixedPointX, fixedPointY, 0.0 )
	fighter.dot = 0.6

	local target = CreateFighterTargetTable()
	target.ent = leviathan

	target.attachments =	[
								"def_rocket_impact_1",  "def_rocket_impact_2", "def_rocket_impact_3", "def_rocket_impact_4", "def_rocket_impact_5",
								"def_rocket_impact_10", "def_rocket_impact_11", "def_rocket_impact_12", "def_rocket_impact_13", "def_rocket_impact_14",
								"def_rocket_impact_20", "def_rocket_impact_21", "def_rocket_impact_22", "def_rocket_impact_23",
								"def_rocket_impact_30", "def_rocket_impact_31", "def_rocket_impact_32", "def_rocket_impact_33",
								"def_rocket_impact_34", "def_rocket_impact_35", "def_rocket_impact_36", "def_rocket_impact_37", "def_rocket_impact_38"
							]

	local wave = CreateFighterWaveTable()
	wave.numClustersInWave = numClustersInWave
	wave.clusterDelay = { min = 2, max = 3 }
	wave.shipsPerWave = shipsPerWave
	wave.numWaves = numWaves

	thread FighterWaveAttack( fighter, target, wave )
}

function ServerCallback_FightersKillLeviathan( leviathanEHandle, fixedPointX, fixedPointY )
{
	local leviathan = GetEntityFromEncodedEHandle( leviathanEHandle )
	if ( !IsValid( leviathan ) )
		return
	Signal( leviathan, "EndFighterWaveAttack" ) // end previous waves to start one last wave

	FightersAttackLeviathan( leviathan, fixedPointX, fixedPointY, { min = 1, max = 1 }, 1, { min = level.cpuIsHighEnd ? 6 : 4, max = level.cpuIsHighEnd ? 6 : 4 } )
}

function LeviathanFootstep( leviathan )
{
	EmitSkyboxSoundAtPosition( leviathan.GetOrigin(), "Leviathan_Footstep" )

	if ( !level.nv.leviathanFootstepsShake )
		return
	local player = GetLocalViewPlayer()
	Assert( player )
	local dist = Distance( player.GetOrigin(), SkyboxToWorldPosition( leviathan.GetOrigin(), 0.001, false ) )
	local frac = GraphCapped( dist, 10000.0, 30000.0, 1.0, 0.0 )
	ClientScreenShake( 3.0 * frac, 10.0, 1.0, Vector( 0.0, 0.0, 0.0 ) )
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

function MilitiaWinShipFX( ship )
{
	ModelFX_EnableGroup( ship, "friend_lights" )
	ModelFX_EnableGroup( ship, "foe_lights" )
	ModelFX_EnableGroup( ship, "thrusters" )
}

function MilitiaWinBomberFX( ship )
{
	ModelFX_EnableGroup( ship, "thrusters" )
}

function MilitiaWinShipFXStop( ent )
{
	ModelFX_DisableAllGroups( ent )
}

function MilitiaWinShipShootRocket( ship )
{
	thread MilitiaWinShipShootRocketThread( ship )
}

function MilitiaWinShipShootRocketThread( ship )
{
	EndSignal( ship, "OnDestroy" )

	while ( !IsValid( level.towerMain ) )
		wait( 0.0 )
	EndSignal( level.towerMain, "OnDestroy" )

	local rocket = CreateFighterRocketTable()
	rocket.fxRocket = ROCKET_FX
	rocket.fxExplosion = ROCKET_EXPLOSION_FX
	rocket.fxMuzzleFlash = MUZZLEFLASH_FX
	rocket.speed = { min = 5000.0, max = 5000.0 }

	local fighterInfo = CreateFighterTable()
	fighterInfo.dot = 0.9

	local targetInfo = CreateFighterTargetTable()

	targetInfo.ent = level.towerMain
	targetInfo.staticPositions = level.militiaWinTowerRocketPositions

	local attackPositionsIndex = 0
	local attackPositions = FighterGetAttackPositionsWithinDot( ship, fighterInfo, targetInfo )

	if ( attackPositions.len() > 0 )
	{
		local attackPosInfo = FighterGetAttackPosForIndex( targetInfo, attackPositions[ attackPositionsIndex ] )

		for ( local i = 0; i < 6; i++ )
		{
			thread FighterFireRocket( ship, rocket, targetInfo, attackPosInfo, attackPositions[ attackPositionsIndex ] )
			attackPositionsIndex = ( attackPositionsIndex + 1 ) % attackPositions.len()
			wait( 0.16 )
		}
	}
}

function MCORClientTimingEvents()
{
	if ( GetLocalViewPlayer().GetTeam() == TEAM_IMC )
		return

	if ( level.nv.MCORClientTiming < 0 )
		return

	local serverTime = level.nv.MCORClientTiming

	thread IntroBomberFlyby( serverTime )
	thread IntroRunners( serverTime )
}

function TowerInit()
{
	while ( !IsValid( level.towerMain ) || !IsValid( level.towerAlpha ) || !IsValid( level.towerCharlie ) )
		wait( 0.0 )

	local radar_lights = [ "light1", "light2", "light3" ]

	local tower_info = {
		tower = level.towerMain,
		towerID = 0,
		radars = [
			{ state = eRadarState.IDLE_ROTATE, model = RADAR_A_MODEL, attachment = "def_radar_a", lights = radar_lights, rotate_time = 120.0, rotation_offset = Vector( 0.0, -90.0, 0.0 ), reversed_rotation = false },
			{ state = eRadarState.IDLE_ROTATE, model = RADAR_B_MODEL, attachment = "def_radar_b", lights = radar_lights, rotate_time = 84.0, rotation_offset = Vector( 0.0, 90.0, 0.0 ), reversed_rotation = false },
			{ state = eRadarState.IDLE_ROTATE, model = RADAR_C_MODEL, attachment = "def_radar_c", lights = radar_lights, rotate_time = 48.0, rotation_offset = Vector( 0.0, -90.0, 0.0 ), reversed_rotation = true },
			{ state = eRadarState.IDLE_ROTATE, model = RADAR_D_MODEL, attachment = "def_radar_d", lights = radar_lights, rotate_time = 86.0, rotation_offset = Vector( 0.0, 90.0, 0.0 ), reversed_rotation = false },
			{ state = eRadarState.IDLE_ROTATE, model = RADAR_E_MODEL, attachment = "def_radar_e", lights = radar_lights, rotate_time = 72.0, rotation_offset = Vector( 0.0, 90.0, 0.0 ), reversed_rotation = true },
			{ state = eRadarState.IDLE_ROTATE, model = RADAR_F_MODEL, attachment = "def_radar_f", lights = radar_lights, rotate_time = 54.0, rotation_offset = Vector( 0.0, -90.0, 0.0 ), reversed_rotation = false },
			{ state = eRadarState.IDLE_ROTATE, model = RADAR_G_MODEL, attachment = "def_radar_g", lights = radar_lights, rotate_time = 51.0, rotation_offset = Vector( 0.0, 90.0, 0.0 ), reversed_rotation = true },
			{ state = eRadarState.IDLE_ROTATE, model = RADAR_H_MODEL, attachment = "def_radar_h", lights = radar_lights, rotate_time = 96.0, rotation_offset = Vector( 0.0, -90.0, 0.0 ), reversed_rotation = true },
			{ state = eRadarState.IDLE_ROTATE, model = RADAR_I_MODEL, attachment = "def_radar_i", lights = radar_lights, rotate_time = 84.0, rotation_offset = Vector( 0.0, 90.0, 0.0 ), reversed_rotation = false }
		]
	}

	thread TowerSpawnAndRotateRadars( tower_info )

	local tower_alpha_info = {
		tower = level.towerAlpha,
		towerID = 1,
		radars = [
			{ state = eRadarState.IDLE_ROTATE, model = RADAR_A_SKYBOX_MODEL, attachment = "def_radar_a", lights = [], rotate_time = 120.0, rotation_offset = Vector( 0.0, -90.0, 0.0 ), reversed_rotation = false },
			{ state = eRadarState.IDLE_ROTATE, model = RADAR_B_SKYBOX_MODEL, attachment = "def_radar_b", lights = [], rotate_time = 84.0, rotation_offset = Vector( 0.0, 90.0, 0.0 ), reversed_rotation = false },
			{ state = eRadarState.IDLE_ROTATE, model = RADAR_C_SKYBOX_MODEL, attachment = "def_radar_c", lights = [], rotate_time = 48.0, rotation_offset = Vector( 0.0, -90.0, 0.0 ), reversed_rotation = true },
			{ state = eRadarState.IDLE_ROTATE, model = RADAR_D_SKYBOX_MODEL, attachment = "def_radar_d", lights = [], rotate_time = 86.0, rotation_offset = Vector( 0.0, 90.0, 0.0 ), reversed_rotation = false },
			{ state = eRadarState.IDLE_ROTATE, model = RADAR_E_SKYBOX_MODEL, attachment = "def_radar_e", lights = [], rotate_time = 72.0, rotation_offset = Vector( 0.0, 90.0, 0.0 ), reversed_rotation = true },
			{ state = eRadarState.IDLE_ROTATE, model = RADAR_F_SKYBOX_MODEL, attachment = "def_radar_f", lights = [], rotate_time = 54.0, rotation_offset = Vector( 0.0, -90.0, 0.0 ), reversed_rotation = false },
			{ state = eRadarState.IDLE_ROTATE, model = RADAR_G_SKYBOX_MODEL, attachment = "def_radar_g", lights = [], rotate_time = 51.0, rotation_offset = Vector( 0.0, 90.0, 0.0 ), reversed_rotation = true },
			{ state = eRadarState.IDLE_ROTATE, model = RADAR_H_SKYBOX_MODEL, attachment = "def_radar_h", lights = [], rotate_time = 96.0, rotation_offset = Vector( 0.0, -90.0, 0.0 ), reversed_rotation = true },
			{ state = eRadarState.IDLE_ROTATE, model = RADAR_I_SKYBOX_MODEL, attachment = "def_radar_i", lights = [], rotate_time = 84.0, rotation_offset = Vector( 0.0, 90.0, 0.0 ), reversed_rotation = false }
		]
	}
	thread TowerSpawnAndRotateRadars( tower_alpha_info )

	local tower_charlie_info = {
		tower = level.towerCharlie,
		towerID = 2,
		radars = [
			{ state = eRadarState.IDLE_ROTATE, model = RADAR_A_SKYBOX_MODEL, attachment = "def_radar_a", lights = [], rotate_time = 120.0, rotation_offset = Vector( 0.0, -90.0, 0.0 ), reversed_rotation = false },
			{ state = eRadarState.IDLE_ROTATE, model = RADAR_B_SKYBOX_MODEL, attachment = "def_radar_b", lights = [], rotate_time = 84.0, rotation_offset = Vector( 0.0, 90.0, 0.0 ), reversed_rotation = false },
			{ state = eRadarState.IDLE_ROTATE, model = RADAR_C_SKYBOX_MODEL, attachment = "def_radar_c", lights = [], rotate_time = 48.0, rotation_offset = Vector( 0.0, -90.0, 0.0 ), reversed_rotation = true },
			{ state = eRadarState.IDLE_ROTATE, model = RADAR_D_SKYBOX_MODEL, attachment = "def_radar_d", lights = [], rotate_time = 86.0, rotation_offset = Vector( 0.0, 90.0, 0.0 ), reversed_rotation = false },
			{ state = eRadarState.IDLE_ROTATE, model = RADAR_E_SKYBOX_MODEL, attachment = "def_radar_e", lights = [], rotate_time = 72.0, rotation_offset = Vector( 0.0, 90.0, 0.0 ), reversed_rotation = true },
			{ state = eRadarState.IDLE_ROTATE, model = RADAR_F_SKYBOX_MODEL, attachment = "def_radar_f", lights = [], rotate_time = 54.0, rotation_offset = Vector( 0.0, -90.0, 0.0 ), reversed_rotation = false },
			{ state = eRadarState.IDLE_ROTATE, model = RADAR_G_SKYBOX_MODEL, attachment = "def_radar_g", lights = [], rotate_time = 51.0, rotation_offset = Vector( 0.0, 90.0, 0.0 ), reversed_rotation = true },
			{ state = eRadarState.IDLE_ROTATE, model = RADAR_H_SKYBOX_MODEL, attachment = "def_radar_h", lights = [], rotate_time = 96.0, rotation_offset = Vector( 0.0, -90.0, 0.0 ), reversed_rotation = true },
			{ state = eRadarState.IDLE_ROTATE, model = RADAR_I_SKYBOX_MODEL, attachment = "def_radar_i", lights = [], rotate_time = 84.0, rotation_offset = Vector( 0.0, 90.0, 0.0 ), reversed_rotation = false }
		]
	}
	thread TowerSpawnAndRotateRadars( tower_charlie_info )
}

function TowerRadarSpawnLight( script_mover, attachment )
{
	local fxID = GetParticleSystemIndex( TOWER_LIGHT )
	local attachID = script_mover.LookupAttachment( attachment )
	local fx = StartParticleEffectOnEntity( script_mover, fxID, FX_PATTACH_POINT_FOLLOW, attachID )
	return fx
}

function TowerSpawnAndRotateRadars( tower_info )
{
	local tower = tower_info.tower
	tower.s.spawnedFX <- []

	// SPAWN
	foreach ( radar in tower_info.radars )
	{
		Assert( radar.rotate_time > 0, "rotate_time must be greater than 0" )

		radar.is_rotating <- false
		radar.degrees_per_second <- 360.0 / radar.rotate_time
		if ( radar.reversed_rotation )
			radar.degrees_per_second *= -1.0
		radar.rotation_end_time <- 0.0

		radar.attachment_id <- tower.LookupAttachment( radar.attachment )
		radar.attachment_angles <- tower.GetAttachmentAngles( radar.attachment_id )

		radar.rotation_angles <- Vector( 0.0, 0.0, 0.0 )

		radar.decel_start_time <- 0.0
		radar.decel_time <- 0.0
		radar.blend_start_time <- 0.0
		radar.blend_time <- 0.0
		radar.blend_accel_decel_time <- 0.0

		radar.script_mover <- CreateClientsideScriptMover( radar.model, Vector( 0.0, 0.0, 0.0 ), Vector( 0.0, 0.0, 0.0 ) )
		radar.script_mover.NonPhysicsSetRotateModeLocal( true )

		local attachmentID = tower.LookupAttachment( radar.attachment )

		radar.script_mover.SetOrigin( tower.GetAttachmentOrigin( attachmentID ) )
		radar.script_mover.SetParent( tower, radar.attachment, true, 0 )
		radar.script_mover.MarkAsNonMovingAttachment()
		radar.script_mover.NonPhysicsRotateTo( radar.rotation_offset.AnglesCompose( radar.rotation_angles ), 0.016, 0.0, 0.0 )

		foreach ( light in radar.lights )
			tower.s.spawnedFX.append( TowerRadarSpawnLight( radar.script_mover, light ) )
	}

	wait( 0.0 )

	while ( true )
	{
		foreach ( radar in tower_info.radars )
		{
			// IDLE
			if ( radar.state == eRadarState.IDLE_ROTATE )
			{
				if ( tower_info.towerID == 0 && level.nv.towerMainFalling > 0.0 ||
					 tower_info.towerID == 1 && level.nv.towerAlphaFalling > 0.0 ||
					 tower_info.towerID == 2 && level.nv.towerCharlieFalling > 0.0 )
				{
					radar.is_rotating = false
					radar.state = eRadarState.DECEL
					radar.decel_start_time = Time()
					radar.decel_time = abs( radar.degrees_per_second ) * 0.25
				}
				else
				{
					if ( Time() >= radar.rotation_end_time )
						radar.is_rotating = false

					if ( !radar.is_rotating )
					{
						radar.is_rotating = true
						radar.rotation_end_time = Time() + 1.0
						radar.rotation_angles.y = AngleNormalize( radar.rotation_angles.y + radar.degrees_per_second )
						radar.script_mover.NonPhysicsRotateTo( radar.rotation_offset.AnglesCompose( radar.rotation_angles ), 1.0, 0.0, 0.0 )
					}
				}
			}

			// DECEL
			if ( radar.state == eRadarState.DECEL )
			{
				if ( Time() > radar.decel_start_time + radar.decel_time )
				{
					thread TowerLightsOff( tower )

					radar.is_rotating = false
					radar.state = eRadarState.BLEND_TO_ATTACHMENT
					radar.blend_start_time = Time()
					radar.blend_time = 12.0
					radar.blend_accel_decel_time = radar.blend_time * 0.4
				}
				else if ( !radar.is_rotating )
				{
					radar.is_rotating = true

					radar.rotation_angles.y = AngleNormalize( radar.rotation_angles.y + radar.degrees_per_second * 0.1 )

					radar.script_mover.NonPhysicsRotateTo( radar.rotation_offset.AnglesCompose( radar.rotation_angles ), radar.decel_time, 0.0, radar.decel_time )
				}
			}

			// BLEND
			if ( radar.state == eRadarState.BLEND_TO_ATTACHMENT )
			{
				if ( Time() > radar.blend_start_time + radar.blend_time )
				{
					radar.state = eRadarState.DONE
				}

				if ( !radar.is_rotating )
				{
					radar.is_rotating = true

					radar.rotation_angles.y = 0.0
					radar.script_mover.NonPhysicsRotateTo( radar.rotation_offset.AnglesCompose( radar.rotation_angles ), radar.blend_time, radar.blend_accel_decel_time, radar.blend_accel_decel_time )
				}
			}
		}

		wait( 0.0 )
	}
}

function TowerLightsOff( tower )
{
	foreach ( fx in tower.s.spawnedFX )
		EffectStop( fx, true, false )
}

function FlyersInit()
{
	level.flyerSequence1 <- CreateFlyerSequence( level.skyboxCamOrigin + Vector( -23.0, 2.0, 3.5 ), Vector( 0.0, 0.0, 0.0 ) )
	level.flyerSequence1.groupAnimName 		= "boneyard_flyer_circle_1"
	level.flyerSequence1.flyerType	 		= eFlyerType.Cheap500x
	level.flyerSequence1.runFunc	 		= FlyerFlyToPath
	level.flyerSequence1.runFuncOptionalVar	= Vector( -40.0, 0.0, 20.0 )
	level.flyerSequence1.animPaths 			= eFlyerPathScale.x500
	level.flyerSequence1.startDirection		= Vector( 1.0, 0.0, 0.0 )

	level.flyerSequence2 <- CreateFlyerSequence( level.skyboxCamOrigin + Vector( -23.0, 12.0, 1.5 ), Vector( 0.0, 90.0, 0.0 ) )
	level.flyerSequence2.groupAnimName 		= "boneyard_flyer_circle_1"
	level.flyerSequence2.flyerType	 		= eFlyerType.Cheap500x
	level.flyerSequence2.runFunc	 		= FlyerFlyToPath
	level.flyerSequence2.runFuncOptionalVar	= Vector( -40.0, 0.0, 20.0 )
	level.flyerSequence2.animPaths 			= eFlyerPathScale.x500
	level.flyerSequence2.startDirection		= Vector( 1.0, 0.0, 0.0 )

	level.flyerSequence2b <- CreateFlyerSequence( level.skyboxCamOrigin + Vector( -30.0, 2.0, 10.5 ), Vector( 0.0, 270.0, 0.0 ) )
	level.flyerSequence2b.groupAnimName 		= "boneyard_flyer_circle_1"
	level.flyerSequence2b.flyerType	 		= eFlyerType.Cheap500x
	level.flyerSequence2b.runFunc	 		= FlyerFlyToPath
	level.flyerSequence2b.runFuncOptionalVar	= Vector( -40.0, 0.0, 20.0 )
	level.flyerSequence2b.animPaths 			= eFlyerPathScale.x500
	level.flyerSequence2b.startDirection		= Vector( 0.91, 0.42, 0.0 )

	level.flyerSequence3 <- CreateFlyerSequence( level.skyboxCamOrigin + Vector( 0.0, 22.0, 5.5 ), Vector( 0.0, 0.0, 0.0 ) )
	level.flyerSequence3.groupAnimName 		= "boneyard_flyer_circle_1"
	level.flyerSequence3.flyerType	 		= eFlyerType.Cheap500x
	level.flyerSequence3.runFunc	 		= FlyerFlyToPath
	level.flyerSequence3.runFuncOptionalVar	= Vector( -40.0, 0.0, 8.0 )
	level.flyerSequence3.animPaths 			= eFlyerPathScale.x500
	level.flyerSequence3.startDirection		= Vector( -0.56, -0.83, 0.0 )

	level.flyerSequence4 <- CreateFlyerSequence( level.skyboxCamOrigin + Vector( -7.0, 22.0, 10.5 ), Vector( 0.0, 270.0, 0.0 ) )
	level.flyerSequence4.groupAnimName 		= "boneyard_flyer_circle_1"
	level.flyerSequence4.flyerType	 		= eFlyerType.Cheap500x
	level.flyerSequence4.runFunc	 		= FlyerFlyToPath
	level.flyerSequence4.runFuncOptionalVar	= Vector( -40.0, 0.0, 0.0 )
	level.flyerSequence4.animPaths 			= eFlyerPathScale.x500
	level.flyerSequence4.startDirection		= Vector( 0.0, -1.0, 0.0 )

	level.flyerSequence4b <- CreateFlyerSequence( level.skyboxCamOrigin + Vector( 7.0, 22.0, 15.5 ), Vector( 0.0, 270.0, 0.0 ) )
	level.flyerSequence4b.groupAnimName 		= "boneyard_flyer_circle_1"
	level.flyerSequence4b.flyerType	 		= eFlyerType.Cheap500x
	level.flyerSequence4b.runFunc	 		= FlyerFlyToPath
	level.flyerSequence4b.runFuncOptionalVar	= Vector( -40.0, 0.0, 15.0 )
	level.flyerSequence4b.animPaths 			= eFlyerPathScale.x500
	level.flyerSequence4b.startDirection		= Vector( -0.98, -0.17, 0.0 )

	level.flyerSequence5 <- CreateFlyerSequence( Vector( 0.0, 0.0, 2000.0 ), Vector( 0.0, 0.0, 0.0 ) )
	level.flyerSequence5.groupAnimName 		= "boneyard_flyer_circle_1"
	level.flyerSequence5.flyerType	 		= eFlyerType.Cheap
	level.flyerSequence5.runFunc	 		= FlyerFlyToPath

	level.flyerSequence6 <- CreateFlyerSequence( Vector( 758.0, -2035.0, 2800.0 ), Vector( 0.0, 180.0, 0.0 ) )
	level.flyerSequence6.groupAnimName 		= "boneyard_flyer_circle_1"
	level.flyerSequence6.flyerType	 		= eFlyerType.Cheap
	level.flyerSequence6.runFunc	 		= FlyerFlyToPath

	level.flyerSequence7 <- CreateFlyerSequence( Vector( -5981.0, -3476.0, 3600.0 ), Vector( 0.0, 270.0, 0.0 ) )
	level.flyerSequence7.groupAnimName 		= "boneyard_flyer_circle_1"
	level.flyerSequence7.flyerType	 		= eFlyerType.Cheap
	level.flyerSequence7.runFunc	 		= FlyerFlyToPath

	level.sequenceArray.append( level.flyerSequence1 )
	level.sequenceArray.append( level.flyerSequence2 )
	level.sequenceArray.append( level.flyerSequence3 )
	level.sequenceArray.append( level.flyerSequence4 )
	level.sequenceArray.append( level.flyerSequence5 )
	level.sequenceArray.append( level.flyerSequence6 )

	FlagSet( "flyers_initialized" )
}

function ServerCallback_TowerAlphaFalling()
{
	if ( level.nv.towerAlphaFalling < 0.0 )
		return

	local duration = GetSoundDuration( "airbase_scr_dogwhistle_overload" )

	if ( level.nv.towerAlphaFalling + duration > Time() )
	{
		local pos = SkyboxToWorldPosition( level.towerAlpha.GetOrigin() )
		local ref = CreateScriptRef( pos )
		EmitSoundOnEntityWithSeek( ref, "airbase_scr_dogwhistle_overload", max( Time() - level.nv.towerAlphaFalling, 0.0 ) )
	}
}

function ServerCallback_TowerAlphaDown()
{
	if ( level.nv.towerAlphaDown < 0.0 )
		return

	if ( IsValid( level.leviathanAlphaDown1 ) )
		Signal( level.leviathanAlphaDown1, "TowerAlphaDown" )
	if ( IsValid( level.leviathanAlphaDown2 ) )
		Signal( level.leviathanAlphaDown2, "TowerAlphaDown" )
	if ( IsValid( level.leviathanAlphaDown3 ) )
		Signal( level.leviathanAlphaDown3, "TowerAlphaDown" )

	FlagWait( "flyers_initialized" )

	thread AddFlyersToSequence( level.flyerSequence1, level.cpuIsHighEnd ? 4 : 2 )
	thread AddFlyersToSequence( level.flyerSequence2, level.cpuIsHighEnd ? 3 : 2 )
	thread AddFlyersToSequence( level.flyerSequence2b, level.cpuIsHighEnd ? 3 : 2 )

	if ( Time() < level.nv.towerAlphaDown + 1.5 )
		thread TowerDistantShake()
}

function ServerCallback_LeviathanAlphaCrush()
{
	if ( !level.nv.leviathanAlphaCrush )
		return

	thread LeviathanCrusherInitAlphaDown1()
}

function ServerCallback_TowerCharlieFalling()
{
	if ( level.nv.towerCharlieFalling < 0.0 )
		return

	local duration = GetSoundDuration( "airbase_scr_dogwhistle_overload" )

	if ( level.nv.towerCharlieFalling + duration > Time() )
	{
		local pos = SkyboxToWorldPosition( level.towerCharlie.GetOrigin() )
		local ref = CreateScriptRef( pos )
		EmitSoundOnEntityWithSeek( ref, "airbase_scr_dogwhistle_overload", max( Time() - level.nv.towerCharlieFalling, 0.0 ) )
	}
}

function ServerCallback_TowerCharlieDown()
{
	if ( level.nv.towerCharlieDown < 0.0 )
		return

	if ( IsValid( level.leviathanCharlieDown1 ) )
		Signal( level.leviathanCharlieDown1, "TowerCharlieDown" )

	FlagWait( "flyers_initialized" )

	thread AddFlyersToSequence( level.flyerSequence3, level.cpuIsHighEnd ? 4 : 3 )
	thread AddFlyersToSequence( level.flyerSequence4, level.cpuIsHighEnd ? 3 : 2 )
	thread AddFlyersToSequence( level.flyerSequence4b, 3 )

	if ( Time() < level.nv.towerCharlieDown + 1.5 )
		thread TowerDistantShake()
}

function ServerCallback_LeviathanCharlieCrush()
{
	if ( !level.nv.leviathanCharlieCrush )
		return

	thread LeviathanCrusherInitCharlieDown1()
}

function ServerCallback_TowerMainAttackStarted()
{
	if ( level.nv.towerMainAttackStarted < 0.0 )
		return

	local delay = 4.0
	local duration = GetSoundDuration( "airbase_scr_dogwhistle_shotdown" )

	local time = Time()
	local soundStartTime = level.nv.towerMainAttackStarted + delay
	local soundStopTime = soundStartTime + duration

	if ( time < soundStartTime )
		wait( soundStartTime - time )

	time = Time()
	if ( time < soundStopTime )
		EmitSoundOnEntityWithSeek( level.towerMain, "airbase_scr_dogwhistle_shotdown", max( time - soundStartTime, 0.0 ) )
}

function ServerCallback_TowerMainFalling()
{
	if ( level.nv.towerMainFalling < 0.0 )
		return

	while ( !IsValid( level.towerMain ) )
		wait( 0.0 )

	local time = Time()
	local timeDiff = level.nv.towerMainFalling - time

	delaythread( timeDiff + 7.0 ) TowerMainFalling()

	if ( time < level.nv.towerMainFalling + 1.5 )
		thread TowerMainShake()
}

function ServerCallback_TowerMainDown()
{
	if ( level.nv.towerMainDown < 0.0 )
		return

	local timeDiff = level.nv.towerMainDown - Time()

	thread LeviathanSpotlightStopAlphaDown1( timeDiff + 2.0 )
	thread LeviathanSpotlightStopCharlieDown1( timeDiff + 4.0 )
	thread LeviathanSpotlightStopAlphaDown2( timeDiff + 14.0 )
	//thread LeviathanSpotlightStopAlphaDown3( timeDiff + 17.0 )
}

function TowerMainFalling()
{
	FlagWait( "flyers_initialized" )
	thread AddFlyersToSequence( level.flyerSequence5, level.cpuIsHighEnd ? 5 : 4 )
	thread AddFlyersToSequence( level.flyerSequence6, level.cpuIsHighEnd ? 5 : 4 )
	thread AddFlyersToSequence( level.flyerSequence7, level.cpuIsHighEnd ? 3 : 2 )
}

function TowerMainShake()
{
	local player = GetLocalViewPlayer()
	Assert( player )
	local dist = Distance( player.GetOrigin(), Vector( -2496.0, 3448.0, 1306.0 ) )
	local frac = GraphCapped( dist, 400.0, 10000.0, 1.0, 0.0 )

	ClientScreenShake( 3.0 * frac, 10.0, 3.0, Vector( 0.0, 0.0, 0.0 ) )
	level.towerMain.WaitSignal( "tower_down" )

	dist = Distance( player.GetOrigin(), Vector( -7893.0, 3934.0, 411.0 ) )
	frac = GraphCapped( dist, 400.0, 10000.0, 1.0, 0.0 )
	ClientScreenShake( 6.0 * frac, 10.0, 6.0, Vector( 0.0, 0.0, 0.0 ) )
}

function TowerDistantShake()
{
	ClientScreenShake( 0.5, 10.0, 3.0, Vector( 0.0, 0.0, 0.0 ) )
}

function SkyboxShipsInit()
{
	level.leviathanAlphaDown1CrushShips.append( ShipCrushInit( CreatePropDynamic( STRATON_SKYBOX_PARKED_MODEL, Vector( -10719.18, 7579.05, -6399.90 ), Vector( 0.0, 90.0, 0.0 ) ) ) )
	level.leviathanAlphaDown1CrushShips.append( ShipCrushInit( CreatePropDynamic( STRATON_SKYBOX_PARKED_MODEL, Vector( -10712.46, 7582.05, -6399.90 ), Vector( 0.0, 90.0, 0.0 ) ) ) )
	level.leviathanAlphaDown1CrushShips.append( ShipCrushInit( CreatePropDynamic( STRATON_SKYBOX_PARKED_MODEL, Vector( -10712.18, 7586.81, -6399.90 ), Vector( 0.0, 90.0, 0.0 ) ) ) )
	level.leviathanAlphaDown1CrushShips.append( ShipCrushInit( CreatePropDynamic( STRATON_SKYBOX_PARKED_MODEL, Vector( -10705.46, 7586.81, -6399.90 ), Vector( 0.0, 90.0, 0.0 ) ) ) )
	level.leviathanAlphaDown1CrushShips.append( ShipCrushInit( CreatePropDynamic( STRATON_SKYBOX_PARKED_MODEL, Vector( -10722.54, 7579.05, -6399.90 ), Vector( 0.0, 90.0, 0.0 ) ) ) )
	level.leviathanAlphaDown1CrushShips.append( ShipCrushInit( CreatePropDynamic( STRATON_SKYBOX_PARKED_MODEL, Vector( -10719.18, 7582.05, -6399.90 ), Vector( 0.0, 90.0, 0.0 ) ) ) )
	level.leviathanAlphaDown1CrushShips.append( ShipCrushInit( CreatePropDynamic( STRATON_SKYBOX_PARKED_MODEL, Vector( -10715.82, 7579.05, -6399.90 ), Vector( 0.0, 90.0, 0.0 ) ) ) )
	level.leviathanAlphaDown1CrushShips.append( ShipCrushInit( CreatePropDynamic( STRATON_SKYBOX_PARKED_MODEL, Vector( -10708.82, 7586.81, -6399.90 ), Vector( 0.0, 90.0, 0.0 ) ) ) )
	level.leviathanAlphaDown1CrushShips.append( ShipCrushInit( CreatePropDynamic( STRATON_SKYBOX_PARKED_MODEL, Vector( -10715.54, 7586.81, -6399.90 ), Vector( 0.0, 90.0, 0.0 ) ) ) )
	level.leviathanAlphaDown1CrushShips.append( ShipCrushInit( CreatePropDynamic( STRATON_SKYBOX_PARKED_MODEL, Vector( -10705.74, 7583.24, -6399.90 ), Vector( 0.0, 90.0, 0.0 ) ) ) )

	level.leviathanCharlieDown1CrushShips.append( ShipCrushInit( CreatePropDynamic( STRATON_SKYBOX_PARKED_MODEL, Vector( -10695.00, 7607.02, -6399.90 ), Vector( 0.0, 0.0, 0.0 ) ) ) )
	level.leviathanCharlieDown1CrushShips.append( ShipCrushInit( CreatePropDynamic( STRATON_SKYBOX_PARKED_MODEL, Vector( -10695.00, 7604.55, -6399.90 ), Vector( 0.0, 0.0, 0.0 ) ) ) )
	level.leviathanCharlieDown1CrushShips.append( ShipCrushInit( CreatePropDynamic( STRATON_SKYBOX_PARKED_MODEL, Vector( -10690.62, 7605.20, -6399.90 ), Vector( 0.0, 0.0, 0.0 ) ) ) )
	level.leviathanCharlieDown1CrushShips.append( ShipCrushInit( CreatePropDynamic( STRATON_SKYBOX_PARKED_MODEL, Vector( -10692.22, 7605.20, -6399.90 ), Vector( 0.0, 0.0, 0.0 ) ) ) )
	level.leviathanCharlieDown1CrushShips.append( ShipCrushInit( CreatePropDynamic( STRATON_SKYBOX_PARKED_MODEL, Vector( -10690.62, 7601.40, -6399.90 ), Vector( 0.0, 0.0, 0.0 ) ) ) )
}

///////////////////////////////////////////////////////////////////////
//
//								CRUSHER
//
///////////////////////////////////////////////////////////////////////

function LeviathanCrusherInitAlphaDown1()
{
	if ( !level.nv.leviathanAlphaCrush )
		return

	FlagWait( "EntitiesDidLoad" ) // level.leviathanAlphaDown1CrushShips is initialized in EntitiesDidLoad
	while ( !IsValid( level.leviathanAlphaDown1 ) )
		wait( 0.0 )
	LeviathanCrusherInit( GetLeviathanAlphaDown1, 1.5, level.leviathanAlphaDown1CrushShips )
}

function LeviathanCrusherInitCharlieDown1()
{
	if ( !level.nv.leviathanCharlieCrush )
		return

	FlagWait( "EntitiesDidLoad" ) // level.leviathanAlphaDown1CrushShips is initialized in EntitiesDidLoad
	while ( !IsValid( level.leviathanCharlieDown1 ) )
		wait( 0.0 )
	LeviathanCrusherInit( GetLeviathanCharlieDown1, 1.45, level.leviathanCharlieDown1CrushShips )
}

function LeviathanCrusherInit( getLeviathanFunc, leviathan_scale, crushable_ships )
{
	local leviathan_prop = getLeviathanFunc()
	local lev_initial_sphere = CreateSphere( leviathan_prop.GetOrigin(), 5.0 * leviathan_scale )

	local attachment_indices = []
	attachment_indices.append( leviathan_prop.LookupAttachment( "def_r_footA_center" ) )
	attachment_indices.append( leviathan_prop.LookupAttachment( "def_r_footB_center" ) )
	attachment_indices.append( leviathan_prop.LookupAttachment( "def_l_footA_center" ) )
	attachment_indices.append( leviathan_prop.LookupAttachment( "def_l_footB_center" ) )

	//local footSphereSize = 0.39 * leviathan_scale
	local footSphereSize = 0.6 * leviathan_scale

	local spheres = []
	spheres.append( CreateSphere( leviathan_prop.GetAttachmentOrigin( attachment_indices[ 0 ] ), footSphereSize ) )
	spheres.append( CreateSphere( leviathan_prop.GetAttachmentOrigin( attachment_indices[ 1 ] ), footSphereSize ) )
	spheres.append( CreateSphere( leviathan_prop.GetAttachmentOrigin( attachment_indices[ 2 ] ), footSphereSize ) )
	spheres.append( CreateSphere( leviathan_prop.GetAttachmentOrigin( attachment_indices[ 3 ] ), footSphereSize ) )

	level.crush_leviathans.append( {
		getLeviathanFunc = getLeviathanFunc,
		initial_sphere = lev_initial_sphere,
		crush_spheres = [
			{ attachment = attachment_indices[ 0 ], sphere = spheres[ 0 ] },
			{ attachment = attachment_indices[ 1 ], sphere = spheres[ 1 ] },
			{ attachment = attachment_indices[ 2 ], sphere = spheres[ 2 ] },
			{ attachment = attachment_indices[ 3 ], sphere = spheres[ 3 ] }
		],
		ships = crushable_ships
	} )
}

function ShipCrushInit( ship_prop )
{
	local ship_initial_sphere = CreateSphere( ship_prop.GetOrigin(), 1.0 )

	local ship_angles = ship_prop.GetAngles()
	local ship_forward = ship_angles.AnglesToRight() // Using AngleToRight, model orientation is incorrect
	local ship_up = ship_angles.AnglesToUp()

	local ship_sphere_1_offset = ( ship_forward * 0.05 ) + ( ship_up * -0.15 )
	local ship_sphere_2_offset = ( ship_forward * -0.5 ) + ( ship_up * 0.21 )

	local spheres = []
	spheres.append( CreateSphere( ship_prop.GetOrigin() + ship_sphere_1_offset, 0.5 ) )
	spheres.append( CreateSphere( ship_prop.GetOrigin() + ship_sphere_2_offset, 0.3 ) )

	return {
		ship = ship_prop,
		crushed = false,
		initial_sphere = ship_initial_sphere,
		crush_spheres = [
			spheres[ 0 ],
			spheres[ 1 ]
		]
	}
}

function LeviathanCrusherThink()
{
	while ( true )
	{
		for ( local i = 0; i < level.crush_leviathans.len(); i++ )
		{
			local lev = level.crush_leviathans[ i ]
			local levModel = lev.getLeviathanFunc()
			if ( !IsValid( levModel ) )
			{
				level.crush_leviathans.remove( i )
				i--
				continue
			}
			lev.initial_sphere.org = levModel.GetOrigin()
			for ( local j = 0; j < lev.ships.len(); j++ )
			{
				if ( !IsValid( lev.ships[ j ].ship ) )
				{
					wait( 0.1 )
					continue
				}

				if ( DistanceSqr( lev.initial_sphere.org, lev.ships[ j ].initial_sphere.org ) < ( lev.initial_sphere.radiusSqr + lev.ships[ j ].initial_sphere.radiusSqr ) )
				{
					foreach ( levSphere in lev.crush_spheres )
					{
						if ( lev.ships[ j ].crushed )
							break

						levSphere.sphere.org = levModel.GetAttachmentOrigin( levSphere.attachment )
						foreach ( shipSphere in lev.ships[ j ].crush_spheres )
						{
							if ( DistanceSqr( levSphere.sphere.org, shipSphere.org ) < ( levSphere.sphere.radiusSqr + shipSphere.radiusSqr ) )
							{
								lev.ships[ j ].crushed = true
								break
							}
						}
					}

					if ( lev.ships[ j ].crushed )
					{
						ShipCrushExplode( lev.ships[ j ].ship )
						lev.ships.remove( j )
						j--
					}
				}
			}

			wait( 0.1 )
		}

		if ( level.crush_leviathans.len() <= 0 )
			wait( 1.0 )
	}
}

function CreateSphere( org, radius )
{
	local sphere = {}
	sphere.org <- org
	sphere.radius <- radius
	sphere.radiusSqr <- radius * radius
	return sphere
}

function ShipCrushExplode( ship )
{
	ship.Hide()
	local origin = ship.GetOrigin()
	local angles = ship.GetAngles()
	EmitSkyboxSoundAtPosition( origin, "Leviathon_Ship_Crush" )
	local fxIndex = GetParticleSystemIndex( SHIP_CRUSH_FX )
	StartParticleEffectInWorld( fxIndex, origin, Vector( 0.0, 0.0, 0.0 ) )
}

function LeviathanSpotlightAlphaStartup( leviathanInfo )
{
	EndSignal( leviathanInfo.ent, "OnDestroy" )

	if ( level.nv.towerAlphaDown < 0.0 )
		WaitSignal( leviathanInfo.ent, "TowerAlphaDown" )

	local timeDiff = level.nv.towerAlphaDown - Time()
	thread LeviathanSpotlight( leviathanInfo.fxString, leviathanInfo.sourcePos, leviathanInfo.offset, leviathanInfo.bob, leviathanInfo.spotlightAttachments, leviathanInfo.ent, timeDiff + leviathanInfo.delay )
}

function LeviathanSpotlightCharlieStartup( leviathanInfo )
{
	EndSignal( leviathanInfo.ent, "OnDestroy" )

	if ( level.nv.towerCharlieDown < 0.0 )
		WaitSignal( leviathanInfo.ent, "TowerCharlieDown" )

	local timeDiff = level.nv.towerCharlieDown - Time()
	thread LeviathanSpotlight( leviathanInfo.fxString, leviathanInfo.sourcePos, leviathanInfo.offset, leviathanInfo.bob, leviathanInfo.spotlightAttachments, leviathanInfo.ent, timeDiff + leviathanInfo.delay )
}

function LeviathanSpotlightStopAlphaDown1( delay )
{
	if ( delay > 0.0 )
		wait( delay )

	level.leviathanAlphaDown1ShouldSpotlight = false

	while ( !IsValid( level.leviathanAlphaDown1 ) )
		wait( 0.0 )

	Signal( level.leviathanAlphaDown1, "leviathan_spotlight_stop" )
}

function LeviathanSpotlightStopAlphaDown2( delay )
{
	if ( delay > 0.0 )
		wait( delay )

	level.leviathanAlphaDown2ShouldSpotlight = false

	while ( !IsValid( level.leviathanAlphaDown2 ) )
		wait( 0.0 )

	Signal( level.leviathanAlphaDown2, "leviathan_spotlight_stop" )
}

function LeviathanSpotlightStopAlphaDown3( delay )
{
	if ( delay > 0.0 )
		wait( delay )

	level.leviathanAlphaDown3ShouldSpotlight = false

	while ( !IsValid( level.leviathanAlphaDown3 ) )
		wait( 0.0 )

	Signal( level.leviathanAlphaDown3, "leviathan_spotlight_stop" )
}

function LeviathanSpotlightStopCharlieDown1( delay )
{
	if ( delay > 0.0 )
		wait( delay )

	level.leviathanCharlieDown1ShouldSpotlight = false

	while ( !IsValid( level.leviathanCharlieDown1 ) )
		wait( 0.0 )

	Signal( level.leviathanCharlieDown1, "leviathan_spotlight_stop" )
}

function LeviathanSpotlight( fxString, sourcePos, offset, bob, spotlightAttachments, leviathan, delay = 0.0 )
{
	EndSignal( leviathan, "OnDestroy" )
	EndSignal( leviathan, "leviathan_spotlight_stop" )

	if ( delay > 0.0 )
		wait( delay ) // using this instead of delaythread because delaythread could possibly be passing in an invalid leviathan

	if ( ( !level.leviathanAlphaDown1ShouldSpotlight && ( leviathan == level.leviathanAlphaDown1 ) ) ||
		 ( !level.leviathanAlphaDown2ShouldSpotlight && ( leviathan == level.leviathanAlphaDown2 ) ) ||
		 ( !level.leviathanAlphaDown3ShouldSpotlight && ( leviathan == level.leviathanAlphaDown3 ) ) ||
		 ( !level.leviathanCharlieDown1ShouldSpotlight && ( leviathan == level.leviathanCharlieDown1 ) ) )
		 return

	local attachIDs = []

	foreach ( attachment in spotlightAttachments )
	{
		attachIDs.append( leviathan.LookupAttachment( attachment ) )
	}

	local attachIDsLen = attachIDs.len()

	Assert ( attachIDsLen > 0 )

	local fxIndex = GetParticleSystemIndex( fxString )
	local fxHandle = StartParticleEffectInWorldWithHandle( fxIndex, sourcePos, Vector( 0.0, 0.0, 0.0 ) )
	EffectSetDontKillForReplay( fxHandle )

	OnThreadEnd(
		function() : ( fxHandle )
		{
			EffectStop( fxHandle, true, false )
		}
	)

	local attachOrg = Vector( 0.0, 0.0, 0.0 )
	local nextAttachOrg = Vector( 0.0, 0.0, 0.0 )
	local effectPos = Vector( 0.0, 0.0, 0.0 )
	local time = 0.0

	local jitter = Vector( 0.035, 0.035, 0.035 )

	local attachment = attachIDs[ 0 ]
	local nextAttachment = attachment
	if ( attachIDsLen > 1 )
		attachIDs[ 1 + RandomInt( attachIDsLen - 1 ) ]

	local moveStartTime = Time()
	local frac = 0.0
	local nextMoveTime = moveStartTime + 5.0
	local moving = false
	local firstMove = true

	while ( true )
	{
		local time = Time()

		if ( attachIDsLen > 1 && time >= nextMoveTime )
		{
			if ( !moving )
				moveStartTime = time

			moving = true

			if ( frac >= 1.0 )
			{
				if ( attachment == attachIDs[ 0 ] )
				{
					attachment = nextAttachment
					nextAttachment = attachIDs[ 0 ]

					if ( firstMove )
					{
						nextAttachment = attachIDs[ 1 + RandomInt( attachIDsLen - 1 ) ]
						firstMove = false
					}

					moveStartTime = time
					frac = Interpolate( moveStartTime, 8.0, 2.0, 2.0 )
				}
				else
				{
					moving = false
					attachment = attachIDs[ 0 ]
					nextAttachment = attachIDs[ 1 + RandomInt( attachIDsLen - 1 ) ]
					nextMoveTime = time + 5.0
					frac = 0.0
				}
			}
			else
			{
				frac = Interpolate( moveStartTime, 5.0, 2.0, 2.0 )
			}
		}

		attachOrg = leviathan.GetAttachmentOrigin( attachment )
		nextAttachOrg = leviathan.GetAttachmentOrigin( nextAttachment )
		local diff = nextAttachOrg - attachOrg

		effectPos = attachOrg + diff * frac + offset + Vector( bob.x * sin( time * 1.2 ) + jitter.x * RandomFloat( -1.0, 1.0 ), bob.y * sin( time * 0.8 ) + jitter.y * RandomFloat( -1.0, 1.0 ), bob.z * sin( time * 1.6 ) + jitter.z * RandomFloat( -1.0, 1.0 ) )

		//DebugDrawSphere( effectPos, 0.05, 255, 0, 0, 0.2 )
		EffectSetControlPointVector( fxHandle, 1, effectPos )
		wait( 0.0 )
	}
}

function IMCWinShipsTakeOffCarrierSound()
{
	local delay = 12.0
	local duration = GetSoundDuration( "airbase_scr_imc_megacarrier_takeoff" )

	local time = Time()
	local soundStartTime = level.nv.imcWinShipsTakeOff + delay
	local soundStopTime = soundStartTime + duration

	if ( time < soundStartTime )
		wait( soundStartTime - time )

	time = Time()
	if ( time < soundStopTime )
	{
		local pos = SkyboxToWorldPosition( level.carrier.GetOrigin() )
		local ref = CreateScriptRef( pos )
		EmitSoundOnEntityWithSeek( ref, "airbase_scr_imc_megacarrier_takeoff", max( time - soundStartTime, 0.0 ) )
	}
}

function IMCWinShipsWallace1Sound()
{
	local wallace1 = GetClientEnt( "prop_dynamic", "wallace1" )
	Assert( wallace1 )
	EmitSoundOnAttachment( wallace1, "REF", "airbase_scr_imc_largeship_takeoff", true )
}

function ServerCallback_IMCWinShipsTakeOff()
{
	if ( level.nv.imcWinShipsTakeOff < 0.0 )
		return

	thread IMCWinShipsTakeOffCarrierSound()
	thread IMCWinShipsWallace1Sound()

	local timeDiff = level.nv.imcWinShipsTakeOff - Time()

	thread IMCWinShipsTakeOff()

	thread LeviathanSpotlightStopAlphaDown2( timeDiff + 22.0 )
	thread LeviathanSpotlightStopAlphaDown3( timeDiff + 16.0 )

	if ( IsValid( level.leviathanMapStart1 ) )
		Signal( level.leviathanMapStart1, "EndFighterWaveAttack" )

	if ( IsValid( level.leviathanMapStart3 ) )
		Signal( level.leviathanMapStart3, "EndFighterWaveAttack" )

	if ( IsValid( level.leviathanAlphaDown2 ) )
		Signal( level.leviathanAlphaDown2, "EndFighterWaveAttack" )

	if ( IsValid( level.leviathanAlphaDown3 ) )
		Signal( level.leviathanAlphaDown3, "EndFighterWaveAttack" )

	if ( IsValid( level.leviathanCharlieDown1 ) )
		Signal( level.leviathanCharlieDown1, "EndFighterWaveAttack" )
}

function IMCWinShipsInit()
{
	local straton_anim_1 = "st_straton_airbase_takeoff1"
	local straton_anim_2 = "st_straton_airbase_takeoff2"
	local straton_anim_left = "st_straton_airbase_takeoff_converge_left"
	local straton_anim_right = "st_straton_airbase_takeoff_converge_right"
	local goblin_anim_1 = "airbase_dropship_takeoff1"
	local goblin_anim_2 = "airbase_dropship_takeoff2"
	local goblin_anim_left = "airbase_dropship_takeoff_converge_left"
	local goblin_anim_right = "airbase_dropship_takeoff_converge_right"
	local bomber_anim_1 = "airbase_bomber1_takeoff"
	local bomber_anim_2 = "airbase_bomber2_takeoff"
	local bomber_anim_left = "airbase_bomber1_takeoff_converge_left"
	local bomber_anim_right = "airbase_bomber2_takeoff_converge_right"

	level.warpShips <- [
		[
			[
				// Bomber 1
				{ label = "bomber1", model = BOMBER_MODEL, anim = bomber_anim_1, org = Vector( 8441.78, -3604.99, -1005.03 ), ang = Vector( 0.0, -180.0, 0.0 ) },
				{ label = "bomber2", model = BOMBER_MODEL, anim = bomber_anim_1, org = Vector( 7441.78, -6300.99, -1805.03 ), ang = Vector( 0.0, -180.0, 0.0 ) },
				{ label = "bomber3", model = BOMBER_MODEL, anim = bomber_anim_1, org = Vector( 8441.78, -4504.99, -500.03 ), ang = Vector( 0.0, -180.0, 0.0 ) },
				{ label = "bomber4", model = BOMBER_MODEL, anim = bomber_anim_1, org = Vector( 6800.78, -7004.99, -100.03 ), ang = Vector( 0.0, -180.0, 0.0 ) },
				{ label = "bomber5", model = BOMBER_MODEL, anim = bomber_anim_1, org = Vector( 7841.78, -4000.99, -1600.03 ), ang = Vector( 0.0, -180.0, 0.0 ) },
				{ label = "bomber6", model = BOMBER_MODEL, anim = bomber_anim_1, org = Vector( 7441.78, -5504.99, 0.03 ), ang = Vector( 0.0, -180.0, 0.0 ) }
			],
			[
				// Straton 1
				{ label = "straton1", model = STRATON_MODEL, anim = straton_anim_1, org = Vector( 7241.78, -2004.99, -3000.03 ), ang = Vector( 0.0, -180.0, 0.0 ) },
				{ label = "straton2", model = STRATON_MODEL, anim = straton_anim_1, org = Vector( 6841.78, -7004.99, -2205.03 ), ang = Vector( 0.0, -180.0, 0.0 ) },
				{ label = "straton3", model = STRATON_MODEL, anim = straton_anim_1, org = Vector( 7000.78, -3200.99, -3205.03 ), ang = Vector( 0.0, -180.0, 0.0 ) },
				{ label = "straton4", model = STRATON_MODEL, anim = straton_anim_1, org = Vector( 6800.78, -6004.99, -2505.03 ), ang = Vector( 0.0, -180.0, 0.0 ) },
				{ label = "straton5", model = STRATON_MODEL, anim = straton_anim_1, org = Vector( 7241.78, -1004.99, -3000.03 ), ang = Vector( 0.0, -180.0, 0.0 ) },
				{ label = "straton6", model = STRATON_MODEL, anim = straton_anim_1, org = Vector( 6841.78, -3004.99, -3500.03 ), ang = Vector( 0.0, -180.0, 0.0 ) },

				// Straton 2
				{ label = "straton7", model = STRATON_MODEL, anim = straton_anim_2, org = Vector( 8641.78, -2504.99, -1700.03 ), ang = Vector( 0.0, -180.0, 0.0 ) },
				{ label = "straton8", model = STRATON_MODEL, anim = straton_anim_2, org = Vector( 8241.78, -7504.99, -2700.03 ), ang = Vector( 0.0, -180.0, 0.0 ) },
				{ label = "straton9", model = STRATON_MODEL, anim = straton_anim_2, org = Vector( 8700.78, -4504.99, -2705.03 ), ang = Vector( 0.0, -180.0, 0.0 ) },
				{ label = "straton10", model = STRATON_MODEL, anim = straton_anim_2, org = Vector( 8200.78, -6504.99, -2205.03 ), ang = Vector( 0.0, -180.0, 0.0 ) },
				{ label = "straton11", model = STRATON_MODEL, anim = straton_anim_2, org = Vector( 8641.78, -1504.99, -2500.03 ), ang = Vector( 0.0, -180.0, 0.0 ) },
				{ label = "straton12", model = STRATON_MODEL, anim = straton_anim_2, org = Vector( 8441.78, -3504.99, -2600.03 ), ang = Vector( 0.0, -180.0, 0.0 ) }
			],
			[
				// Goblin 1
				{ label = "goblin1", model = GOBLIN_MODEL, anim = goblin_anim_1, org = Vector( 7241.78, -5804.0, -105.0 ), ang = Vector( 0.0, -180.0, 0.0 ) },
				{ label = "goblin2", model = GOBLIN_MODEL, anim = goblin_anim_1, org = Vector( 7241.78, -5000.0, -505.0 ), ang = Vector( 0.0, -180.0, 0.0 ) },
				{ label = "goblin3", model = GOBLIN_MODEL, anim = goblin_anim_1, org = Vector( 6841.78, -7000.0, -2000.0 ), ang = Vector( 0.0, -180.0, 0.0 ) },
				{ label = "goblin4", model = GOBLIN_MODEL, anim = goblin_anim_1, org = Vector( 7241.78, -4500.0, -1005.0 ), ang = Vector( 0.0, -180.0, 0.0 ) },
				{ label = "goblin5", model = GOBLIN_MODEL, anim = goblin_anim_1, org = Vector( 7241.78, -2800.0, -250.0 ), ang = Vector( 0.0, -180.0, 0.0 ) },
				{ label = "goblin6", model = GOBLIN_MODEL, anim = goblin_anim_1, org = Vector( 6841.78, -7004.0, -800.0 ), ang = Vector( 0.0, -180.0, 0.0 ) }

				// Goblin 2
				{ label = "goblin7", model = GOBLIN_MODEL, anim = goblin_anim_2, org = Vector( 7241.78, -5504.0, 1000.0 ), ang = Vector( 0.0, -180.0, 0.0 ) },
				{ label = "goblin8", model = GOBLIN_MODEL, anim = goblin_anim_2, org = Vector( 7241.78, -3800.0, -605.0 ), ang = Vector( 0.0, -180.0, 0.0 ) },
				{ label = "goblin9", model = GOBLIN_MODEL, anim = goblin_anim_2, org = Vector( 6841.78, -6000.0, -1405.0 ), ang = Vector( 0.0, -180.0, 0.0 ) },
				{ label = "goblin10", model = GOBLIN_MODEL, anim = goblin_anim_2, org = Vector( 7241.78, -4500.0, -1005.0 ), ang = Vector( 0.0, -180.0, 0.0 ) },
				{ label = "goblin11", model = GOBLIN_MODEL, anim = goblin_anim_2, org = Vector( 7241.78, -2800.0, 200.0 ), ang = Vector( 0.0, -180.0, 0.0 ) },
				{ label = "goblin12", model = GOBLIN_MODEL, anim = goblin_anim_2, org = Vector( 6841.78, -7004.0, -400.0 ), ang = Vector( 0.0, -180.0, 0.0 ) }
			]
		],
		[
			[
				// Bomber right
				{ label = "bomberRight1", model = BOMBER_MODEL, anim = bomber_anim_right, org = Vector( 14610.76, 14253.97, 0.0 ), ang = Vector( 0.0, -135.0, 0.0 ) },
				{ label = "bomberRight2", model = BOMBER_MODEL, anim = bomber_anim_right, org = Vector( 14610.76, 14600.97, -1000.0 ), ang = Vector( 0.0, -135.0, 0.0 ) },
				{ label = "bomberRight3", model = BOMBER_MODEL, anim = bomber_anim_right, org = Vector( 14610.76, 15800.97, -100.0 ), ang = Vector( 0.0, -135.0, 0.0 ) },
				{ label = "bomberRight4", model = BOMBER_MODEL, anim = bomber_anim_right, org = Vector( 14610.76, 12020.97, -600.0 ), ang = Vector( 0.0, -135.0, 0.0 ) },
				{ label = "bomberRight5", model = BOMBER_MODEL, anim = bomber_anim_right, org = Vector( 14610.76, 14500.97, -400.0 ), ang = Vector( 0.0, -135.0, 0.0 ) },
				{ label = "bomberRight6", model = BOMBER_MODEL, anim = bomber_anim_right, org = Vector( 14610.76, 11500.97, -750.0 ), ang = Vector( 0.0, -135.0, 0.0 ) }
			],
			[
				// Straton right
				{ label = "stratonRight1", model = STRATON_MODEL, anim = straton_anim_right, org = Vector( 15410.76, 13840.97, -7005.0 ), ang = Vector( 0.0, -120.0, 0.0 ) },
				{ label = "stratonRight2", model = STRATON_MODEL, anim = straton_anim_right, org = Vector( 15610.76, 15953.97, -5505.0 ), ang = Vector( 0.0, -120.0, 0.0 ) },
				{ label = "stratonRight3", model = STRATON_MODEL, anim = straton_anim_right, org = Vector( 15210.76, 14000.97, -6505.0 ), ang = Vector( 0.0, -120.0, 0.0 ) },
				{ label = "stratonRight4", model = STRATON_MODEL, anim = straton_anim_right, org = Vector( 15900.76, 12680.97, -6005.0 ), ang = Vector( 0.0, -120.0, 0.0 ) },
				{ label = "stratonRight5", model = STRATON_MODEL, anim = straton_anim_right, org = Vector( 15210.76, 15000.97, -5005.0 ), ang = Vector( 0.0, -120.0, 0.0 ) },
				{ label = "stratonRight6", model = STRATON_MODEL, anim = straton_anim_right, org = Vector( 15010.76, 13000.97, -5805.0 ), ang = Vector( 0.0, -120.0, 0.0 ) }
			],
			[
				// Goblin right
				{ label = "goblinRight1", model = GOBLIN_MODEL, anim = goblin_anim_right, org = Vector( 14610.76, 13953.97, -3805.0 ), ang = Vector( 0.0, -120.0, 0.0 ) },
				{ label = "goblinRight2", model = GOBLIN_MODEL, anim = goblin_anim_right, org = Vector( 15610.76, 13953.97, -3005.0 ), ang = Vector( 0.0, -120.0, 0.0 ) },
				{ label = "goblinRight3", model = GOBLIN_MODEL, anim = goblin_anim_right, org = Vector( 13610.76, 13953.97, -2005.0 ), ang = Vector( 0.0, -120.0, 0.0 ) },
				{ label = "goblinRight4", model = GOBLIN_MODEL, anim = goblin_anim_right, org = Vector( 14010.76, 13953.97, -3605.0 ), ang = Vector( 0.0, -120.0, 0.0 ) },
				{ label = "goblinRight5", model = GOBLIN_MODEL, anim = goblin_anim_right, org = Vector( 12610.76, 13953.97, -1005.0 ), ang = Vector( 0.0, -120.0, 0.0 ) },
				{ label = "goblinRight6", model = GOBLIN_MODEL, anim = goblin_anim_right, org = Vector( 12010.76, 13953.97, -1505.0 ), ang = Vector( 0.0, -120.0, 0.0 ) }
			]
		],
		[
			[
				// Goblin left from back
				{ label = "goblinLeft1", model = GOBLIN_MODEL, anim = goblin_anim_left, org = Vector( 7241.78, -5200.0, -1800.0 ), ang = Vector( 0.0, 116.0, 0.0 ) },
				{ label = "goblinLeft2", model = GOBLIN_MODEL, anim = goblin_anim_left, org = Vector( 7241.78, -5400.0, -2000.0 ), ang = Vector( 0.0, 116.0, 0.0 ) },
				{ label = "goblinLeft3", model = GOBLIN_MODEL, anim = goblin_anim_left, org = Vector( 6841.78, -6000.0, -1805.0 ), ang = Vector( 0.0, 116.0, 0.0 ) },
				{ label = "goblinLeft4", model = GOBLIN_MODEL, anim = goblin_anim_left, org = Vector( 7241.78, -6000.0, -1800.0 ), ang = Vector( 0.0, 116.0, 0.0 ) },
				{ label = "goblinLeft5", model = GOBLIN_MODEL, anim = goblin_anim_left, org = Vector( 7241.78, -5200.0, -1600.0 ), ang = Vector( 0.0, 116.0, 0.0 ) },
				{ label = "goblinLeft6", model = GOBLIN_MODEL, anim = goblin_anim_left, org = Vector( 6841.78, -5400.0, -800.0 ), ang = Vector( 0.0, 116.0, 0.0 ) }
			],
		],
		[
			[
				// Straton left
				{ label = "stratonLeft1", model = STRATON_MODEL, anim = straton_anim_left, org = Vector( 0.0, -11308.77, -5005.0 ), ang = Vector( 0.0, 120.0, 0.0 ) },
				{ label = "stratonLeft2", model = STRATON_MODEL, anim = straton_anim_left, org = Vector( -400.0, -12308.77, -6005.0 ), ang = Vector( 0.0, 120.0, 0.0 ) },
				{ label = "stratonLeft3", model = STRATON_MODEL, anim = straton_anim_left, org = Vector( -6000.0, -11308.77, -7005.0 ), ang = Vector( 0.0, 120.0, 0.0 ) },
				{ label = "stratonLeft4", model = STRATON_MODEL, anim = straton_anim_left, org = Vector( 5200.0, -11308.77, -5505.0 ), ang = Vector( 0.0, 120.0, 0.0 ) },
				{ label = "stratonLeft5", model = STRATON_MODEL, anim = straton_anim_left, org = Vector( 8000.0, -12308.77, -6505.0 ), ang = Vector( 0.0, 120.0, 0.0 ) },
				{ label = "stratonLeft6", model = STRATON_MODEL, anim = straton_anim_left, org = Vector( -3200.0, -11308.77, -7505.0 ), ang = Vector( 0.0, 120.0, 0.0 ) }
			],
			[
				// Goblin left
				{ label = "goblinLeft1", model = GOBLIN_MODEL, anim = goblin_anim_left, org = Vector( 3026.55, -10500.0, -4005.0 ), ang = Vector( 0.0, 116.0, 0.0 ) },
				{ label = "goblinLeft2", model = GOBLIN_MODEL, anim = goblin_anim_left, org = Vector( 3026.55, -12000.0, -3005.0 ), ang = Vector( 0.0, 116.0, 0.0 ) },
				{ label = "goblinLeft3", model = GOBLIN_MODEL, anim = goblin_anim_left, org = Vector( 3026.55, -11500.0, -3505.0 ), ang = Vector( 0.0, 116.0, 0.0 ) },
				{ label = "goblinLeft4", model = GOBLIN_MODEL, anim = goblin_anim_left, org = Vector( 3026.55, -10750.0, -2505.0 ), ang = Vector( 0.0, 116.0, 0.0 ) },
				{ label = "goblinLeft5", model = GOBLIN_MODEL, anim = goblin_anim_left, org = Vector( 3026.55, -11000.0, -1005.0 ), ang = Vector( 0.0, 116.0, 0.0 ) },
				{ label = "goblinLeft6", model = GOBLIN_MODEL, anim = goblin_anim_left, org = Vector( 3026.55, -11250.0, -2005.0 ), ang = Vector( 0.0, 116.0, 0.0 ) }
			]
		]
	]
}

function IMCWinShipsTakeOff()
{
	FlagWait( "EntitiesDidLoad" )

	//thread IMCWinShipCol()

	local counter = 0
	local ship = 0

	local shipDelay
	for ( local i = 0; i < 20; i++ )
	{
		foreach ( spawnArea in level.warpShips )
		{
			local shipNum = 0
			foreach ( shipType in spawnArea )
			{
				ship = counter % shipType.len()
				local sound = ""
				if ( shipNum % 3 == 0 )
					sound = "airbase_scr_imc_smallship_takeoff"
				thread IMCWinSpawnWarpShip( shipType[ ship ], sound )
				wait( level.cpuIsHighEnd ? 0.4 : 0.6 )
				shipNum++
			}
		}
		counter++
		wait( level.cpuIsHighEnd ? 2.0 : 2.5 )
	}
}

//level.shipships <- []

/*function IMCWinShipCol()
{
	while ( true )
	{
		foreach( ship in level.shipships )
		{
			local shipOrg = ship.shp.GetAttachmentOrigin( ship.shp.LookupAttachment( "ORIGIN" ) )

			foreach( ship2 in level.shipships )
			{
				if ( ship.shp == ship2.shp )
					continue

				local ship2Org = ship2.shp.GetAttachmentOrigin( ship2.shp.LookupAttachment( "ORIGIN" ) )
				if ( Distance( shipOrg, ship2Org ) < 700.0 )
				{
					printt( "COLLISION between " + ship.lbl + " and " + ship2.lbl )
					//DebugDrawBox( shipOrg, Vector(-256,-256,-256), Vector(256,256,256), 0, 255, 0, 1, 9999.0 )
					//DebugDrawBox( ship2Org, Vector(-256,-256,-256), Vector(256,256,256), 0, 255, 255, 1, 9999.0 )

					DebugDrawSphere( shipOrg, 384, 0, 255, 0, 9999.0 )
					DebugDrawSphere( ship2Org, 384, 0, 255, 255, 9999.0 )
				}
			}
		}
		wait( 0.5 )
	}
}*/

function EmitSoundOnAttachment( ent, attachment, sound, inSkybox = false, skyboxScale = 0.001 )
{
	thread EmitSoundOnAttachmentThread( ent, attachment, sound, inSkybox, skyboxScale )
}

function EmitSoundOnAttachmentThread( ent, attachment, sound, inSkybox, skyboxScale )
{
	Assert( IsValid( ent ) )

	local attachID = ent.LookupAttachment( attachment )
	local mover = null

	if ( IsClient() )
		mover = CreateClientsideScriptMover( "models/dev/empty_model.mdl", ent.GetAttachmentOrigin( attachID ), Vector( 0.0, 0.0, 0.0 ) )
	else
		mover = CreateScriptMover( "models/dev/empty_model.mdl", ent.GetAttachmentOrigin( attachID ), Vector( 0.0, 0.0, 0.0 ) )
	mover.EndSignal( "OnDestroy" )

	EmitSoundOnEntity( mover, sound )

	while ( IsValid( ent ) )
	{
		local entOrg = ent.GetAttachmentOrigin( attachID )
		local localViewPlayer = GetLocalViewPlayer()
		Assert( localViewPlayer )
		local localViewPlayerOrg = localViewPlayer.GetOrigin()

		if ( inSkybox )
			entOrg = SkyboxToWorldPosition( entOrg )

		entOrg = localViewPlayerOrg + ClampVectorToCube( localViewPlayerOrg, entOrg - localViewPlayerOrg, Vector( 0.0, 0.0, 0.0 ), 32000.0 )
		//DebugDrawLine( mover.GetOrigin(), entOrg, 255.0, 0.0, 0.0, true, 2.0 )
		//DebugDrawLine( localViewPlayerOrg, entOrg, 0.0, 255.0, 0.0, true, 2.0 )
		mover.NonPhysicsMoveTo( entOrg, 1.0, 0.0, 0.0 )

		wait( 1.0 )
	}

	mover.Destroy()
}

function IMCWinSpawnWarpShip( warpShipInfo, sound = "" )
{
	local ship = CreatePropDynamic( warpShipInfo.model, warpShipInfo.org, warpShipInfo.ang )

	//level.shipships.append( { lbl = warpShipInfo.label, shp = ship, org = warpShipInfo.org } )

	if ( sound != "" )
		EmitSoundOnAttachment( ship, "ORIGIN", sound )

	local attachedFX = []

	if ( warpShipInfo.model == STRATON_MODEL )
	{
		if ( level.cpuIsHighEnd )
		{
			local redLightFX = GetParticleSystemIndex( "acl_light_red" )
			local attachLightID = ship.LookupAttachment( "Light_Red1" )
			attachedFX.append( StartParticleEffectOnEntity( ship, redLightFX, FX_PATTACH_POINT_FOLLOW, attachLightID ) )
			attachLightID = ship.LookupAttachment( "Light_Green1" )
			attachedFX.append( StartParticleEffectOnEntity( ship, redLightFX, FX_PATTACH_POINT_FOLLOW, attachLightID ) )
			attachLightID = ship.LookupAttachment( "light_white" )
			attachedFX.append( StartParticleEffectOnEntity( ship, redLightFX, FX_PATTACH_POINT_FOLLOW, attachLightID ) )
		}

		local jetFullFX = GetParticleSystemIndex( "veh_gunship_jet_full" )
		local attachID = ship.LookupAttachment( "L_exhaust_rear_1" )
		attachedFX.append( StartParticleEffectOnEntity( ship, jetFullFX, FX_PATTACH_POINT_FOLLOW, attachID ) )
		attachID = ship.LookupAttachment( "L_exhaust_front_1" )
		attachedFX.append( StartParticleEffectOnEntity( ship, jetFullFX, FX_PATTACH_POINT_FOLLOW, attachID ) )
		attachID = ship.LookupAttachment( "R_exhaust_rear_1" )
		attachedFX.append( StartParticleEffectOnEntity( ship, jetFullFX, FX_PATTACH_POINT_FOLLOW, attachID ) )
		attachID = ship.LookupAttachment( "R_exhaust_front_1" )
		attachedFX.append( StartParticleEffectOnEntity( ship, jetFullFX, FX_PATTACH_POINT_FOLLOW, attachID ) )
	}
	else if ( warpShipInfo.model == GOBLIN_MODEL )
	{
		if ( level.cpuIsHighEnd )
		{
			local redLightFX = GetParticleSystemIndex( "acl_light_red" )
			local attachLightID = ship.LookupAttachment( "Light_Red1" )
			attachedFX.append( StartParticleEffectOnEntity( ship, redLightFX, FX_PATTACH_POINT_FOLLOW, attachLightID ) )
			attachLightID = ship.LookupAttachment( "light_Green1" )
			attachedFX.append( StartParticleEffectOnEntity( ship, redLightFX, FX_PATTACH_POINT_FOLLOW, attachLightID ) )
		}

		local jetFullFX = GetParticleSystemIndex( "veh_gunship_jet_full" )
		local attachID = ship.LookupAttachment( "L_exhaust_rear_1" )
		attachedFX.append( StartParticleEffectOnEntity( ship, jetFullFX, FX_PATTACH_POINT_FOLLOW, attachID ) )
		attachID = ship.LookupAttachment( "L_exhaust_rear_2" )
		attachedFX.append( StartParticleEffectOnEntity( ship, jetFullFX, FX_PATTACH_POINT_FOLLOW, attachID ) )
		attachID = ship.LookupAttachment( "L_exhaust_front_1" )
		attachedFX.append( StartParticleEffectOnEntity( ship, jetFullFX, FX_PATTACH_POINT_FOLLOW, attachID ) )
		attachID = ship.LookupAttachment( "R_exhaust_rear_1" )
		attachedFX.append( StartParticleEffectOnEntity( ship, jetFullFX, FX_PATTACH_POINT_FOLLOW, attachID ) )
		attachID = ship.LookupAttachment( "R_exhaust_rear_2" )
		attachedFX.append( StartParticleEffectOnEntity( ship, jetFullFX, FX_PATTACH_POINT_FOLLOW, attachID ) )
		attachID = ship.LookupAttachment( "R_exhaust_front_1" )
		attachedFX.append( StartParticleEffectOnEntity( ship, jetFullFX, FX_PATTACH_POINT_FOLLOW, attachID ) )

	}
	else if ( warpShipInfo.model == BOMBER_MODEL )
	{
		local bomberJetLFFX = GetParticleSystemIndex( "P_veh_bomber_jet_LF" )
		local bomberJetLRFX = GetParticleSystemIndex( "P_veh_bomber_jet_LR" )
		local bomberJetRFFX = GetParticleSystemIndex( "P_veh_bomber_jet_RF" )
		local bomberJetRRFX = GetParticleSystemIndex( "P_veh_bomber_jet_RR" )
		local bomberJetRearFX = GetParticleSystemIndex( "P_veh_bomber_jet_rear" )

		local attachID = ship.LookupAttachment( "L_exhaust_side_1" )
		attachedFX.append( StartParticleEffectOnEntity( ship, bomberJetLFFX, FX_PATTACH_POINT_FOLLOW, attachID ) )
		attachID = ship.LookupAttachment( "L_exhaust_side_2" )
		attachedFX.append( StartParticleEffectOnEntity( ship, bomberJetLRFX, FX_PATTACH_POINT_FOLLOW, attachID ) )
		attachID = ship.LookupAttachment( "R_exhaust_side_1" )
		attachedFX.append( StartParticleEffectOnEntity( ship, bomberJetRFFX, FX_PATTACH_POINT_FOLLOW, attachID ) )
		attachID = ship.LookupAttachment( "R_exhaust_side_2" )
		attachedFX.append( StartParticleEffectOnEntity( ship, bomberJetRRFX, FX_PATTACH_POINT_FOLLOW, attachID ) )

		attachID = ship.LookupAttachment( "L_exhaust_rear_1" )
		attachedFX.append( StartParticleEffectOnEntity( ship, bomberJetRearFX, FX_PATTACH_POINT_FOLLOW, attachID ) )
		attachID = ship.LookupAttachment( "L_exhaust_rear_2" )
		attachedFX.append( StartParticleEffectOnEntity( ship, bomberJetRearFX, FX_PATTACH_POINT_FOLLOW, attachID ) )
		attachID = ship.LookupAttachment( "L_exhaust_rear_3" )
		attachedFX.append( StartParticleEffectOnEntity( ship, bomberJetRearFX, FX_PATTACH_POINT_FOLLOW, attachID ) )
		attachID = ship.LookupAttachment( "L_exhaust_rear_4" )
		attachedFX.append( StartParticleEffectOnEntity( ship, bomberJetRearFX, FX_PATTACH_POINT_FOLLOW, attachID ) )
		attachID = ship.LookupAttachment( "R_exhaust_rear_1" )
		attachedFX.append( StartParticleEffectOnEntity( ship, bomberJetRearFX, FX_PATTACH_POINT_FOLLOW, attachID ) )
		attachID = ship.LookupAttachment( "R_exhaust_rear_2" )
		attachedFX.append( StartParticleEffectOnEntity( ship, bomberJetRearFX, FX_PATTACH_POINT_FOLLOW, attachID ) )
		attachID = ship.LookupAttachment( "R_exhaust_rear_3" )
		attachedFX.append( StartParticleEffectOnEntity( ship, bomberJetRearFX, FX_PATTACH_POINT_FOLLOW, attachID ) )
		attachID = ship.LookupAttachment( "R_exhaust_rear_4" )
		attachedFX.append( StartParticleEffectOnEntity( ship, bomberJetRearFX, FX_PATTACH_POINT_FOLLOW, attachID ) )
	}

	thread PlayAnim( ship, warpShipInfo.anim )
	local animDuration = ship.GetSequenceDuration( warpShipInfo.anim )
	wait( animDuration - 0.15 )

	thread CLWarpoutEffect( ship )
	ship.WaitSignal( "OnDestroy" )

	foreach ( fxID in attachedFX )
		EffectStop( fxID, true, false )
}

function VMTCallback_AirbaseGetCarrierAlpha( ent )
{
	if ( level.nv.imcCarrierAlphaFadeStartTime == 0.0 )
		return 0.0
	return GraphCapped( Time(), level.nv.imcCarrierAlphaFadeStartTime, level.nv.imcCarrierAlphaFadeStartTime + 12.0, 0.0, 1.0 )
}

///////////////////////////////////////////////////////////////////////
//
//						MILITIA INTRO EXTRAS
//
///////////////////////////////////////////////////////////////////////
function IntroBomberFlyby( serverTime )
{
	local goal = 9.0
	local give = -2.0
	local time = WaitForTimeDifference( goal, give, serverTime )
	if ( time == null )
		return

	local angles = Vector( 0, -90, 0 )

	delaythread( 0.0 ) IntroBomberFlybySkit( BOMBER_MODEL, Vector( -5700, 15500, 2220 ), angles )
	delaythread( 0.25 ) IntroBomberFlybySkit( DROPSHIP_MODEL, Vector( -7000, 15500, 2100 ), angles )
	delaythread( 0.75 ) IntroBomberFlybySkit( DROPSHIP_MODEL, Vector( -4500, 15500, 2000 ), angles )
}

function IntroBomberFlybySkit( model, origin, angles )
{
	thread CLWarpinEffect( model, "test_fly_idle", origin, angles )

	wait WARPINFXTIME - 0.2

	local dist = -31000
	local time = 5.0 + RandomFloat( 0, 1.5 )
	local ship = CreateClientsideScriptMover( model, origin, angles )

	thread PlayAnim( ship, "test_fly_idle" )
	ship.NonPhysicsMoveTo( ship.GetOrigin() + Vector( 0, dist, 0 ), time, 0, 0 )

	wait time - 0.2

	CLWarpoutEffect( ship )
}

function IntroRunners( serverTime )
{
	local height = 100

	for ( local i=0; i < 3; i ++ )
	{
		local baseTime = 3.5 + ( i * 1.0 )
		local x = i * 2
		local y = i * 6
		thread CLIntroGuyRun( Vector( 1629.736816 + x, 3368.842529 + y, height ), Vector(	0, -160.243011, 0 ), baseTime, serverTime )
		thread CLIntroGuyRun( Vector( 1553.838867 + x, 3155.699707 + y, height ), Vector(	0, -164.182266, 0 ), baseTime, serverTime )
		thread CLIntroGuyRun( Vector( 1831.324219 + x, 3242.379639 + y, height ), Vector( 	0, -162.713013, 0 ), baseTime, serverTime )
		thread CLIntroGuyRun( Vector( 1767.733276 + x, 3523.167480 + y, height ), Vector(	0, -156.868652, 0 ), baseTime, serverTime )
		thread CLIntroGuyRun( Vector( 1544.293945 + x, 3662.579102 + y, height ), Vector( 	0, -168.557083, 0 ), baseTime, serverTime )
		thread CLIntroGuyRun( Vector( 1907.425903 + x, 3557.534424 + y, height ), Vector(	0, -161.082016, 0 ), baseTime, serverTime )
		thread CLIntroGuyRun( Vector( 2118.855469 + x, 3361.809326 + y, height ), Vector(	0, -163.962921, 0 ), baseTime, serverTime )

		thread CLIntroGuyRun( Vector( 1316.324219 + x, 2098.478760 + y, height ), Vector( 	0, -175.417435, 0 ), baseTime, serverTime )
		thread CLIntroGuyRun( Vector( 1149.433350 + x, 2255.547852 + y, height ), Vector( 	0, -169.689148, 0 ), baseTime, serverTime )
		thread CLIntroGuyRun( Vector( 1409.456177 + x, 2319.833496 + y, height ), Vector( 	0, -166.563751, 0 ), baseTime, serverTime )

		local baseTime = 14.0 + ( i * 0.75 )
		local x = i * 50
		local y = i * -12
		thread CLIntroGuyRun( Vector( -2900.496826 + x, -3260.921387 + y, height ), Vector(	0, 90.303917, 0 ), baseTime, serverTime )
		thread CLIntroGuyRun( Vector( -2820.977539 + x, -3200.826172 + y, height ), Vector(	0, 90.030548, 0 ), baseTime, serverTime )
		thread CLIntroGuyRun( Vector( -3019.747070 + x, -3100.878174 + y, height ), Vector(	0, 89.425064, 0 ), baseTime, serverTime )
	}
}

function WaitForTimeDifference( goaltime, giveTime, serverTime )
{
	local deltaTime = serverTime - Time()
	local diffTime = goaltime - deltaTime

	if ( diffTime < giveTime )
		return null

	if ( diffTime > 0 )
		wait diffTime

	return diffTime
}

function CLIntroGuyRun( origin, angles, baseTime, serverTime )
{
	local goal = 9.0
	local give = 0.0
	local time = WaitForTimeDifference( baseTime, give, serverTime )
	if ( time == null )
		return

	local anim 	= GetRunAnim()
	local speed = GetRunSpeed( anim ) //units per second
	local drone = CLSpawnDrone( TEAM_IMC, origin, angles )
	local mover = CreateClientsideScriptMover( "models/dev/editor_ref.mdl", origin, angles )
	drone.SetParent( mover, "REF" )
	mover.clHide()
	drone.clShow()

	drone.EndSignal( "OnDeath" )

	thread PlayAnim( drone, anim, mover, "REF" )

	local forward 	= drone.GetForwardVector()
	local time 		= 10
	local dist 		= time * speed
	local endGoal 	= origin + ( forward * dist )

	mover.NonPhysicsMoveTo( endGoal, time, 0, 0 )

	wait time

	drone.Kill()
	mover.Kill()
}

function GetRunSpeed( anim )
{
	switch( anim )
	{
		case "drone_a_SprintN":
			return 175

		case "drone_a_SprintN2":
			return 170

		case "drone_a_SprintN3":
			return 165
	}
}

function GetRunAnim()
{
	local anims = []
	anims.append( "drone_a_SprintN" )
	anims.append( "drone_a_SprintN2" )
	anims.append( "drone_a_SprintN3" )

	level.runAnimNum++
	if ( level.runAnimNum >= anims.len() )
		level.runAnimNum = 0

	return anims[ level.runAnimNum ]
}

function GetDeathAnim()
{
	local anims = []
	anims.append( "MP_run_death_flip" )
	anims.append( "MP_run_death_kickup" )
	anims.append( "MP_run_death_roll" )
	anims.append( "MP_run_death_shoulder_stumble" )
	anims.append( "MP_run_death_stumble_left" )
	anims.append( "MP_run_death_stumble_right" )
	anims.append( "MP_run_death_stumble_swerve" )

	return Random( anims )
}

function CLSpawnDrone( team, origin, angles )
{
	local model

	if ( typeof team == "string" )
		team = team.tointeger()

	if ( team == TEAM_IMC )
		model = TEAM_IMC_GRUNT_MDL

	local soldier = CreateClientSidePropDynamic( origin, angles, model )
	soldier.EnableRenderAlways()
	return soldier
}

function CE_VisualSettingAirbaseMCOR( player, ref )
{
	CE_ResetVisualSettings( player )

	ref.LerpSkyScale( SKYSCALE_AIRBASE_MCOR_SHIP, 0.01 )
}
