const DEV_EDITOR = 0
const GUN_MODEL = "models/weapons/m1a1_hemlok/w_hemlok.mdl"
const FX_BLOOD_SQUIB = "death_pinkmist_blood1"
const FXVDU_DOOR_EXP 		= "P_impact_exp_med_metal"

function main()
{
	IncludeScript( "mp_outpost_207_shared" )

	if( GetCinematicMode() )
		IntroScreen_Setup()

	if ( reloadingScripts )
		return

	IncludeFileAllowMultipleLoads( "client/objects/cl_hornet_fighter" )
	IncludeFileAllowMultipleLoads( "client/objects/cl_phantom_fighter" )
	IncludeFileAllowMultipleLoads( "client/objects/cl_imc_carrier_207" )
	IncludeFileAllowMultipleLoads( "client/objects/cl_ai_turret" )

	RegisterSignal( "DecoyShipWarpsIn" )
	RegisterSignal( "DecoyShipFiredUpon" )
	RegisterSignal( "ResetCannonVDU" )
	RegisterSignal( "CannonThermalDrumSpinStart" )

	FlagInit( "CannonWarningVO_InProgress" )
	FlagInit( "TechTeamSequenceDone" )

	// TODO any way to get a reference to the skycamera on the client?
	level.skycameraOrg <- Vector( 11904, 11904, -11776 )

	// WORLDSPACE authored
	level.FX_DECOY_SHIP_WARP_IN 	<- PrecacheParticleSystem( "veh_birm_warp_in_decoy" )
	level.FX_WARNING_LIGHT 			<- PrecacheParticleSystem( "warning_light_orange_blink" )
	level.FX_WARNING_LIGHT_NOWALL 	<- PrecacheParticleSystem( "warning_light_orange_blink_nowall" )
	level.warningLightFXSpots 	<- []
	level.warningLightHandles 	<- []
	level.warningLightModels 	<- []

	level.FX_STEAM_SHOOT 		<- PrecacheParticleSystem( "env_steam_shoot_LG" )
	level.FX_STEAM_SHOOT_CHEAP 	<- PrecacheParticleSystem( "env_steam_shoot_LG_cheap" )
	level.FX_STEAM_SHOOT_LINGER <- PrecacheParticleSystem( "env_steam_shoot_linger_LG_1" )
	level.cannonSteamFXSpots 	<- []
	level.cannonSteamFXHandles 	<- []

	level.FX_CANNON_THERMAL_DRUM_GLOW <- PrecacheParticleSystem( "P_rail_thermal_drum_glow_1" )
	level.cannonThermalDrums 	<- []

	level.FX_LIFEBOAT			<- PrecacheParticleSystem( "P_SB_Escape_Pod" )
	level.FX_LIFEBOAT_L			<- PrecacheParticleSystem( "P_SB_Escape_Pod_L" )

	level.cannon 				<- null
	level.capitalShip 			<- null
	level.decoyShip 			<- null
	level.decoyShipFxHandles 	<- []
	level.cannonMonitors 		<- []
	level.skyboxCannonL 		<- null
	level.skyboxCannonR 		<- null
	level.skyboxCannonC 		<- null
	level.skyboxCamOrigin 		<- GetLevelSkycamOrigin()  // needed for util functions I'm using

	AddCreateCallback( "script_mover", 	Outpost_EntityCreateCallback )
	AddKillReplayStartedCallback( Outpost_CapitalShipThrustersChange )
	AddKillReplayEndedCallback( Outpost_CapitalShipThrustersChange )

	Globalize( VMTCallback_OutpostCapitalShipMaterialFade )
	Globalize( VMTCallback_OutpostSpaceStationMaterialFade )
	Globalize( ServerCallback_CannonWarningVO )
	Globalize( ServerCallback_DecoyShipWarpsIn )
	Globalize( ServerCallback_VDU_TechTeamSequence )
	Globalize( ServerCallback_VDU_JumpDriveSequence )
	Globalize( ServerCallback_ResetCannonVDU )
	Globalize( ServerCallback_VDU_WatchCapitalShip )
	Globalize( ServerCallback_VDU_WatchCapitalShip_Escape )
	Globalize( ServerCallback_VDU_GravesLifeboat )
	Globalize( ServerCallback_CapitalShip_FireLifeboats )
	Globalize( ServerCallback_PostEpilogue_IMC_IMCwon_ShipEscapeVO )

	Globalize( CE_VisualSettingOutpostIMC )
	Globalize( CE_VisualSettingOutpostMCOR )
	Globalize( CE_BloomOnRampOpenOutpostMCOR )
	Globalize( CE_BloomOnRampOpenOutpostIMC )

	Globalize( TechTeam_Defend1 )
	Globalize( TechTeam_Defend2 )
	Globalize( TechTeam_Attack1 )
	Globalize( TechTeam_Attack2 )
	Globalize( TechTeam_Attack3 )
	PrecacheParticleSystem( FX_BLOOD_SQUIB )
	PrecacheParticleSystem( FXVDU_DOOR_EXP )

	RegisterServerVarChangeCallback( "warningLightsOn", Outpost_WarningLightsChange )
	RegisterServerVarChangeCallback( "cannonVentingFXOn", Outpost_CannonVentingChange )
	RegisterServerVarChangeCallback( "cannonMonitorScreenStatus", Outpost_CannonMonitorScreensChange )
	RegisterServerVarChangeCallback( "cannonThermalDrumsSpin", Outpost_CannonDrumsSpinChange )
	RegisterServerVarChangeCallback( "capitalShipThrustersOn", Outpost_CapitalShipThrustersChange )
	SetFullscreenMinimapParameters( 2.7, 850, 2200, 180)
	if ( GAMETYPE == COOPERATIVE )
		SetCustomMinimapZoom( 2 )
}

function Outpost_CapitalShipThrustersChange()
{
	if ( !IsValid( level.capitalShip ) )
		return

	if ( level.nv.capitalShipThrustersOn )
		ModelFX_EnableGroup( level.capitalShip, "thrusters" )
	else
		ModelFX_DisableGroup( level.capitalShip, "thrusters" )
}

function Outpost_EntityCreateCallback( ent, isRecreate )
{
	local tname = ent.GetName()
	local recognized = true

	switch( tname )
	{
		case "outpost_cannon_barrel":
			level.cannon = ent
			break

		case "militia_decoy_ship":
			level.decoyShip = ent
			break

		case "imc_capital_ship":
			level.capitalShip = ent
			SetupLifeboats()
			break

		case "skybox_cannon_left":
			level.skyboxCannonL = ent
			break

		case "skybox_cannon_right":
			level.skyboxCannonR = ent
			break

		case "skybox_cannon_center":
			level.skyboxCannonC = ent
			break

		default:
			recognized = false
			break
	}

	if ( recognized )
		printt( "Entity Create Callback set up", tname )
}

// DEPRECATED - figure out what the "right" way is to do this setup
function EntitiesDidLoad()
{
	// these use clientside info_targets and prop_dynamics, which don't work with create callbacks
	WarningLightsSetup()
	CannonSteamFXSetup()
	CannonMonitorsSetup()
	CannonThermalDrumsSetup()
}


function IntroScreen_Setup()
{
	CinematicIntroScreen_SetText( TEAM_IMC, 	[ "#INTRO_SCREEN_OUTPOST_LINE1", "#INTRO_SCREEN_OUTPOST_LINE2", "#INTRO_SCREEN_OUTPOST_LINE3" ] )
	CinematicIntroScreen_SetText( TEAM_MILITIA, [ "#INTRO_SCREEN_OUTPOST_LINE1", "#INTRO_SCREEN_OUTPOST_LINE2", "#INTRO_SCREEN_OUTPOST_LINE3" ] )

	local fadeInTime = 1.2
	local displayTime = 9.0
	local fadeOutTime = 1.2
	CinematicIntroScreen_SetTextFadeTimes( TEAM_IMC, fadeInTime, displayTime, fadeOutTime )
	CinematicIntroScreen_SetTextFadeTimes( TEAM_MILITIA, fadeInTime, displayTime, fadeOutTime )

	//local totalFadeDelay = ( fadeInTime * 3 ) + displayTime  // 3 = number of lines to print
	local totalFadeDelay = fadeInTime + displayTime

	local delay_line1 = 0.2
	//local delay_line2 = 3
	//local delay_line3 = 3
	//CinematicIntroScreen_SetTextSpacingTimes( TEAM_IMC,  delay_line1, delay_line2, delay_line3 )
	//CinematicIntroScreen_SetTextSpacingTimes( TEAM_MILITIA,  delay_line1, delay_line2, delay_line3 )
	CinematicIntroScreen_SetTextSpacingTimes( TEAM_IMC,  delay_line1 )
	CinematicIntroScreen_SetTextSpacingTimes( TEAM_MILITIA,  delay_line1 )

	local totalLineDelay = delay_line1 //+ delay_line2 + delay_line3

	local logoFadeInDelay 		= 0.5
	local logoFadeInTime 		= 2.0
	local logoDisplayDuration 	= 4.5
	local logoFadeOutTime 		= 2.0
	CinematicIntroScreen_SetTeamLogoFadeTimes( TEAM_IMC, logoFadeInDelay, logoFadeInTime, logoDisplayDuration, logoFadeOutTime )

	local logoDelay = logoFadeInTime + logoDisplayDuration + logoFadeOutTime

	//local delay_beforeFadeOut = 4
	//local blackscreenDuration = totalFadeDelay + totalLineDelay + delay_beforeFadeOut
	local blackscreenDuration = totalFadeDelay + totalLineDelay + logoDelay
	local blackscreenFadeOutTime = 2.0
	CinematicIntroScreen_SetBlackscreenFadeTimes( TEAM_IMC, blackscreenDuration, blackscreenFadeOutTime )
	CinematicIntroScreen_SetBlackscreenFadeTimes( TEAM_MILITIA, blackscreenDuration, blackscreenFadeOutTime )
}

function ServerCallback_VDU_TechTeamSequence()
{
	thread VDU_TechTeamSequence()
}

function VDU_TechTeamSequence()
{
	FlagClear( "TechTeamSequenceDone" )

	level.ent.Signal( "ResetCannonVDU" )
	level.ent.EndSignal( "ResetCannonVDU" )

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

	thread TechTeam_Cam( player )

	// turn the VDU on
	SetNextVDUWideScreen( player )
	ShowVDU()

	// TOTAL SEQUENCE TIME = 10 secs!
	// - if this changes, don't forget to also change the wait time in mp_outpost_207::TechTeamSequence

	TechTeam_Defend1( GetNodeByUniqueID( "cinematic_mp_node_TechTeam_Defend1" ) )
	TechTeam_Defend2( GetNodeByUniqueID( "cinematic_mp_node_TechTeam_Defend2" ) )
	delaythread( 4.25 ) TechTeam_Attack1( GetNodeByUniqueID( "cinematic_mp_node_TechTeam_Attack1" ) )
	delaythread( 4.25 ) TechTeam_Attack2( GetNodeByUniqueID( "cinematic_mp_node_TechTeam_Attack2" ) )
	delaythread( 5.0 ) TechTeam_Attack3( GetNodeByUniqueID( "cinematic_mp_node_TechTeam_Attack3" ) )

	thread TechTeam_VO( player )

	wait 10.25
	delaythread( 0.5 ) FlagSet( "TechTeamSequenceDone" )
}

function TechTeam_Cam( player )
{
	FlagEnd( "TechTeamSequenceDone" )
	level.ent.EndSignal( "ResetCannonVDU" )
	player.EndSignal( "OnDestroy" )

	// set up the scene
	local camOrg = Vector( -3099, 4838, -80 )
	local camAng = Vector( 5, -110, 0 )
	local startFOV = 30

	level.camera.SetOrigin( camOrg )
	level.camera.SetAngles( camAng )
	level.camera.SetFOV( startFOV )

	//zoom camera slowly over the calm
	local startAng = camAng
	local finalAng = Vector( 5, -105, 0 )
	local time = 2.5
	local ease = time * 0.5
	thread RotateCameraOverTime( player, startAng, finalAng, time, 0, 0 )

	wait time

	//zoom and pan after the first hit
	local endFOV = 15
	local startAng = finalAng
	local finalAng = Vector( 7, -115, 0 )
	local time = 0.5
	local ease = 0.1
	thread ZoomCameraOverTime( player, startFOV, endFOV, time, ease, 0.0 )
	thread RotateCameraOverTime( player, startAng, finalAng, time, ease, ease )

	wait 1.5
	//zoom out slowly
	local startFOV = endFOV
	local endFOV = 25
	local startAng = camAng
	local finalAng = Vector( 5, -120, 0 )
	local time = 7.0
	local ease = 3.0
	thread ZoomCameraOverTime( player, startFOV, endFOV, time, ease, ease )
}

function TechTeam_VO( player )
	{
	player.EndSignal( "OnDestroy" )

	wait 1.5
	EmitSoundOnEntity( player, "VDU_Outpost_CannonRoom" )

	wait 1
	// 	"They're inside! They're inside Fire Control! They're---"
	EmitSoundOnEntity( player, "diag_at_matchIntro_OP204_03ba_01_imc_grunt1" )

	if ( player.GetTeam() == TEAM_IMC )
	{
		wait 5.75
		// 	"Blisk, what the hell is going on down there - we're being targeted by our own guns!"
		EmitSoundOnEntity( player, "diag_at_matchIntro_OP204_04_01_imc_graves" )
	}
	else
	{
		wait 6.25
		// "We're inside! We got the gun!"
		EmitSoundOnEntity( player, "diag_at_sitFlavor_OP152_01_01_mcor_grunt1" )
	}
}

function TechTeam_Defend1( node )
{
	thread __TechTeam_Defend1Thread( node )
}

function __TechTeam_Defend1Thread( node )
{
	NodeCleanUp( node )

	local guy 		= CreatePropDynamic( IMC_MALE_BR, node.pos, node.ang )
	local weapon 	= CreatePropDynamic( GUN_MODEL )
	Cl_SetParent( weapon, guy, "PROPGUN" )

	node.ents.append( guy )
	node.ents.append( weapon )

	OnThreadEnd(
		function() : ( node )
		{
			foreach ( ent in node.ents )
			{
				if ( IsValid( ent ) )
					ent.Kill()
			}
		}
	)

	thread PlayAnimTeleport( guy, "pt_console_idle", node.pos, node.ang )

	wait 1.5
	local effectIndex 	= GetParticleSystemIndex( FXVDU_DOOR_EXP )
	local fxorigin 		= Vector( -3095.161865, 4427.335938, -143.968712 )
	local fxangles 		= Vector( 0, 0, 0 )
	StartParticleEffectInWorld( effectIndex, fxorigin, fxangles )
	thread GunShotFX( fxorigin, 1 )

	wait 0.5
	thread GunShotFX( fxorigin, 2 )

	HeadShotFX( guy, Vector( 0, 90, 0 ) )
	waitthread PlayAnim( guy, "pt_console_death_slideright", node.pos, node.ang )

	FlagWait( "TechTeamSequenceDone" )
}

function TechTeam_Defend2( node )
{
	thread __TechTeam_Defend2Thread( node )
}

function __TechTeam_Defend2Thread( node )
{
	NodeCleanUp( node )

	local guy 		= CreatePropDynamic( IMC_MALE_CQ, node.pos, node.ang )
	local weapon 	= CreatePropDynamic( GUN_MODEL )
	Cl_SetParent( weapon, guy, "PROPGUN" )

	node.ents.append( guy )
	node.ents.append( weapon )

	OnThreadEnd(
		function() : ( node )
		{
			foreach ( ent in node.ents )
			{
				if ( IsValid( ent ) )
					ent.Kill()
			}
		}
	)

	thread PlayAnimTeleport( guy, "pt_console_idle", node.pos, node.ang )

	wait 2.5

	thread PlayAnim( guy, "pt_console_react_L_alt", node.pos, node.ang )
	delaythread( 1.8 ) GunShotFX( Vector( -3095.161865, 4427.335938, -143.968712 ), 5 )
	wait 2.1
	local anim = "CQB_Death_spinleft_arms"
	local origin = HackGetDeltaToRef( guy.GetOrigin(), guy.GetAngles(), guy, anim )

	HeadShotFX( guy, Vector( 0, -90, 0 ))
	waitthread PlayAnim( guy, anim, origin, guy.GetAngles() )

	FlagWait( "TechTeamSequenceDone" )
}

function TechTeam_Attack1( node )
{
	thread __TechTeam_Attack1Thread( node )
}

function __TechTeam_Attack1Thread( node )
{
	NodeCleanUp( node )

	local guy 		= CreatePropDynamic( TEAM_MILITIA_GRUNT_MDL, node.pos, node.ang )
	local weapon 	= CreatePropDynamic( GUN_MODEL )
	Cl_SetParent( weapon, guy, "PROPGUN" )

	node.ents.append( guy )
	node.ents.append( weapon )

	OnThreadEnd(
		function() : ( node )
		{
			foreach ( ent in node.ents )
			{
				if ( IsValid( ent ) )
					ent.Kill()
			}
		}
	)

	local inAnim 	= "pt_console_runin_L"
	local attach 	= guy.Anim_GetAttachmentAtTime( inAnim, "ORIGIN", 0 )
	local startOrigin 	= attach.position
	local startAngles 	= attach.angle

	guy.SetAngles( startAngles + Vector( 0, 20, 0 ) )
	guy.SetOrigin( startOrigin )
	local anim 			= "CQB_traverse_corner_L"
	local position = HackGetPositionToStart( guy, anim )

	waitthread PlayAnimTeleport( guy, anim, position.pos, position.ang )
	waitthread PlayAnim( guy, inAnim, node.pos, node.ang )
	thread PlayAnim( guy, "pt_console_idle", node.pos, node.ang )

	FlagWait( "TechTeamSequenceDone" )
}

function TechTeam_Attack2( node )
{
	thread __TechTeam_Attack2Thread( node )
}

function __TechTeam_Attack2Thread( node )
{
	NodeCleanUp( node )

	local guy 		= CreatePropDynamic( MILITIA_MALE_BR, node.pos, node.ang )
	local weapon 	= CreatePropDynamic( GUN_MODEL )
	Cl_SetParent( weapon, guy, "PROPGUN" )

	node.ents.append( guy )
	node.ents.append( weapon )

	OnThreadEnd(
		function() : ( node )
		{
			foreach ( ent in node.ents )
			{
				if ( IsValid( ent ) )
					ent.Kill()
			}
		}
	)
	local inAnim 	= "pt_console_runin_L"
	local attach 	= guy.Anim_GetAttachmentAtTime( inAnim, "ORIGIN", 0 )
	local startOrigin 	= attach.position
	local startAngles 	= attach.angle
	guy.SetAngles( startAngles + Vector( 0, 45, 0 ) )
	guy.SetOrigin( startOrigin )

	local anim 			= "CQB_traverse_corner_L"
	local position = HackGetPositionToStart( guy, anim )

	guy.SetAngles( position.ang )
	guy.SetOrigin( position.pos )
	local attach 	= guy.Anim_GetAttachmentAtTime( anim, "ORIGIN", 0 )
	local startOrigin 	= attach.position
	local startAngles 	= attach.angle
	guy.SetAngles( startAngles )
	guy.SetOrigin( startOrigin )

	local animPre 		= "CQB_bound_forward"
	local posPre = HackGetPositionToStart( guy, animPre )


	waitthread PlayAnimTeleport( guy, animPre, posPre.pos, posPre.ang )
	waitthread PlayAnim( guy, anim, position.pos, position.ang )
	waitthread PlayAnim( guy, inAnim, node.pos, node.ang )
	thread PlayAnim( guy, "pt_console_idle", node.pos, node.ang )

	FlagWait( "TechTeamSequenceDone" )
}

function TechTeam_Attack3( node )
{
	thread __TechTeam_Attack3Thread( node )
}

function __TechTeam_Attack3Thread( node )
{
	NodeCleanUp( node )

	local guy 		= CreatePropDynamic( MILITIA_MALE_CQ, node.pos, node.ang )
	local weapon 	= CreatePropDynamic( GUN_MODEL )
	Cl_SetParent( weapon, guy, "PROPGUN" )

	node.ents.append( guy )
	node.ents.append( weapon )

	OnThreadEnd(
		function() : ( node )
		{
			foreach ( ent in node.ents )
			{
				if ( IsValid( ent ) )
					ent.Kill()
			}
		}
	)

	local inAnim 	= "React_spot_radio2"
	local attach 	= guy.Anim_GetAttachmentAtTime( inAnim, "ORIGIN", 0 )
	local startOrigin 	= attach.position
	local startAngles 	= attach.angle
	guy.SetAngles( startAngles )
	guy.SetOrigin( startOrigin )

	local anim 			= "CQB_bound_forward"
	local position = HackGetPositionToStart( guy, anim )

	waitthread PlayAnimTeleport( guy, anim, position.pos, position.ang )
	local origin = HackGetDeltaToRef( guy.GetOrigin(), guy.GetAngles(), guy, "React_signal_thatway" )
	waitthread PlayAnim( guy, "React_signal_thatway", origin, node.ang )
	waitthread PlayAnim( guy, "React_spot_radio1", node.pos, node.ang )
	waitthread PlayAnim( guy, "pt_crouch_2_stand_nodelta", node.pos, node.ang )
	thread PlayAnim( guy, "React_spot_radio2", node.pos, node.ang )

	FlagWait( "TechTeamSequenceDone" )
}

function HackGetPositionToStart( guy, anim )
{
	local startOrigin 	= guy.GetOrigin()
	local startAngles 	= guy.GetAngles()

	//get the angle he needs to start in to end at the angle for the run in anim
	local time 			= guy.GetSequenceDuration( anim )
	local attach 		= guy.Anim_GetAttachmentAtTime( anim, "ORIGIN", time )
	local angleDelta 	= Vector( 0, startAngles.y - attach.angle.y, 0 )
	local angles 		= startAngles + angleDelta
	guy.SetAngles( angles )

	//get the position he needs to start in to end at the start of the run in anim
	local attach 		= guy.Anim_GetAttachmentAtTime( anim, "ORIGIN", time )
	local originDelta 	= startOrigin - attach.position
	local origin 		= startOrigin + originDelta

	guy.SetAngles( startAngles )

	local result = {}
	result.pos <- origin
	result.ang <- angles

	return result
}

function HeadShotFX( guy, offset = Vector( 0, 0, 0 ) )
	{
	local idx = GetParticleSystemIndex( FX_BLOOD_SQUIB )
	local attachID = guy.LookupAttachment( "HEADSHOT" )
	local fxPos = guy.GetAttachmentOrigin( attachID ) + Vector( 0, 0, -20 )
	local fxAng = guy.GetAttachmentAngles( attachID )

	StartParticleEffectInWorld( idx, fxPos, fxAng )
	}

function GunShotFX( fxorigin, num = 1 )
{
	local fxangles = Vector( 0, 0, 0 )
	local fxcolor = Vector( 1, 0.8, 0.5 )
	local fxradius = 3000

	while( num )
	{
		local fxLight = CreateClientSideDynamicLight( fxorigin, fxangles, fxcolor, fxradius )
		wait 0.1
		fxLight.Kill()

		num--
	}
}

function ServerCallback_VDU_JumpDriveSequence()
{
	thread VDU_JumpDriveSequence_Think()
}

// skippedTo is for DEV ONLY
// TODO can I make it play nice with the conversations? Turn on/off automatically to show conversations while the VDU cam is running?
function VDU_JumpDriveSequence_Think()
{
	local player = GetLocalClientPlayer()

	if ( player != GetLocalViewPlayer() )
		return
	if ( IsWatchingKillReplay() )
		return

	level.ent.Signal( "ResetCannonVDU" )
	level.ent.EndSignal( "ResetCannonVDU" )
	player.EndSignal( "OnDestroy" )

	// terminate camera movements
	player.Signal( "ZoomCameraOverTime" )
	player.Signal( "RotateCameraOverTime" )
	player.Signal( "MoveCameraOverTime" )

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

	SetNextVDUWideScreen( player )
	ShowVDU()

	local cameraOrg = Vector( -1352, 1477, 126 )
	level.camera.SetOrigin( cameraOrg )

	local ang1 = Vector( -25, -75, 0 ) //Vector( -25, -66, 0 )
	local fov1 = 50

	local ang2 = Vector( -27, -73, 0 ) //Vector( -34, -65, 0 )
	local fov2 = 25

	// TEMP for testing
	// script_client level.camera.SetAngles( Vector( -20, -70, 0 ) )
	// script_client level.camera.SetFOV( 25 )

	// first view
	level.camera.SetAngles( ang1 )
	level.camera.SetFOV( fov1 )

	local waitBeforeMovingFrame = 3

	local waitBeforeZoom 	= waitBeforeMovingFrame + 0
	local zoomTime 			= 7

	local waitBeforeRotate 	= waitBeforeMovingFrame + ( zoomTime * 0.65 ) //2.5
	local rotateTime 		= 2.8

	// final view
	thread Delayed_ZoomCameraOverTime( waitBeforeZoom, player, fov1, fov2, zoomTime, 0, zoomTime )
	thread Delayed_RotateCameraOverTime( waitBeforeRotate, player, ang1, ang2, rotateTime, 0, rotateTime )

	local zoomTotal = waitBeforeZoom + zoomTime
	local rotateTotal = waitBeforeRotate + rotateTime

	local longestWait = ( zoomTotal > rotateTotal ) ? zoomTotal : rotateTotal
	wait longestWait + 4
}

function ServerCallback_ResetCannonVDU()
{
	level.ent.Signal( "ResetCannonVDU" )
}

function ServerCallback_VDU_WatchCapitalShip( vduActiveTime, finalFOV = null, skippedTo = null )
{
	thread VDU_WatchCapitalShip_Think( vduActiveTime, finalFOV, skippedTo )
}

function VDU_WatchCapitalShip_Think( vduActiveTime, finalFOV = null, skippedTo = null )
{
	local player = GetLocalClientPlayer()

	if ( player != GetLocalViewPlayer() )
		return
	if ( IsWatchingKillReplay() )
		return

	level.ent.Signal( "ResetCannonVDU" )
	level.ent.EndSignal( "ResetCannonVDU" )
	player.EndSignal( "OnDestroy" )

	// terminate camera movements
	player.Signal( "ZoomCameraOverTime" )
	player.Signal( "RotateCameraOverTime" )
	player.Signal( "MoveCameraOverTime" )

	if ( IsLockedVDU() )
	{
		printt( "VDU_WatchCapitalShip_Think: VDU is locked, can't proceed!" )
		return
	}

	OnThreadEnd(
		function () : ()
		{
			UnlockVDU()
			HideVDU()

			printt( "VDU_WatchCapitalShip done" )
		}
	)

	// take over the vdu screen
	LockVDU()

	SetNextVDUWideScreen( player )
	ShowVDU()

	local cam = level.camera

	local cameraOrg = Vector( -652, -75, 273 )
	cam.SetOrigin( cameraOrg )

	local attach = level.capitalShip.LookupAttachment( "Impact_1" )
	local attachOrg = level.capitalShip.GetAttachmentOrigin( attach )
	attachOrg += Vector( -3, 0, 3 )  // raise the aimpoint origin slightly so the ship is more centered in the frame

	local vecToShip = GetVectorFromWorldPosToSkyboxPos( cameraOrg, attachOrg )
	local finalAng = VectorToAngles( vecToShip ) * -1

	// figure out a "badly aimed" start camera to lerp from
	local startAng = Vector( finalAng.x + RandomFloat( -10, 10 ), finalAng.y + RandomFloat( -10, 10 ), 0 )

	wait 0.1

	local startFOV = 60
	if ( !finalFOV )
		finalFOV = 25

	cam.SetAngles( startAng )
	cam.SetFOV( startFOV )

	local waitBeforeZoom = vduActiveTime * 0.3
	local zoomHoldTime = vduActiveTime * 0.2
	local zoomDuration = vduActiveTime - waitBeforeZoom - zoomHoldTime
	//printt( "zoominfo:", waitBeforeZoom, zoomDuration, zoomHoldTime )

	local waitBeforeRotate = vduActiveTime * 0.45
	local rotateHoldTime = vduActiveTime * 0.1
	local rotateDuration = vduActiveTime - waitBeforeRotate - rotateHoldTime
	//printt( "rotateinfo:", waitBeforeRotate, rotateDuration, rotateHoldTime )

	//printt( "waiting for zoom and rotate on VDU cam" )

	thread Delayed_ZoomCameraOverTime( waitBeforeZoom, player, startFOV, finalFOV, zoomDuration, 0, zoomDuration )
	thread Delayed_RotateCameraOverTime( waitBeforeRotate, player, startAng, finalAng, rotateDuration, 0, rotateDuration )

	if ( skippedTo )
	{
		// for testing
		wait 10000
	}
	else
	{
		wait vduActiveTime
	}
}

function ServerCallback_VDU_WatchCapitalShip_Escape( watchTime, finalFOV )
{
	thread VDU_WatchCapitalShip_Escape( watchTime, finalFOV )
}

function VDU_WatchCapitalShip_Escape( watchTime, finalFOV )
{
	local startTime = Time()

	local player = GetLocalClientPlayer()

	if ( player != GetLocalViewPlayer() )
		return
	if ( IsWatchingKillReplay() )
		return

	local capitalShip = level.capitalShip

	level.ent.Signal( "ResetCannonVDU" )
	level.ent.EndSignal( "ResetCannonVDU" )
	player.EndSignal( "OnDestroy" )

	if ( IsLockedVDU() )
		return

	local camOrg = Vector( 5283, 2409, 3663 )
	local camAng = Vector( -20, -130, 0 )
	local startFOV = 40

	level.camera.SetOrigin( camOrg )
	level.camera.SetAngles( camAng )
	level.camera.SetFOV( startFOV )

	OnThreadEnd(
		function () : ()
		{
			UnlockVDU()
			HideVDU()
		}
	)

	LockVDU()

	local camEntAttach = "broken02"
	thread CameraFollowsShipOverTime( player, capitalShip, camEntAttach, camOrg, watchTime, 2 )  // worldspace camera to the skybox ship
	thread ZoomCameraOverTime( player, startFOV, finalFOV, watchTime, 0.5, 0.5 )

	SetNextVDUWideScreen( player )
	ShowVDU()

	wait watchTime
}

// NOTE verticalOffset is in SKYBOX scale (aka very small units)
function CameraFollowsShipOverTime( player, capitalShip, attachName, camOrg, watchTime, verticalOffset = 0 )
{
	level.ent.EndSignal( "ResetCannonVDU" )
	capitalShip.EndSignal( "OnDeath" )

	local attachID = capitalShip.LookupAttachment( attachName )
	local skyOrg
	local worldOrg
	local shipOrg

	local endTime = Time() + watchTime
	while ( Time() < endTime )
	{
		skyOrg = capitalShip.GetAttachmentOrigin( attachID )
		skyOrg += Vector( 0, 0, verticalOffset )
		worldOrg = SkyboxToWorldPosition( skyOrg )
		shipOrg = camOrg + ClampVectorToCube( camOrg, worldOrg - camOrg, Vector( 0, 0, 0 ), 32000.0 )

		local vecToShipOrg = shipOrg - camOrg
		local angToPos = VectorToAngles( vecToShipOrg )

		level.camera.SetAngles( angToPos )

		wait 0
	}
}

function ServerCallback_VDU_GravesLifeboat()
{
	thread VDU_GravesLifeboat()
}

function VDU_GravesLifeboat()
{
	local startTime = Time()

	local player = GetLocalClientPlayer()

	if ( player != GetLocalViewPlayer() )
		return
	if ( IsWatchingKillReplay() )
		return

	local capitalShip = level.capitalShip

	level.ent.Signal( "ResetCannonVDU" )
	level.ent.EndSignal( "ResetCannonVDU" )
	player.EndSignal( "OnDestroy" )

	if ( !( "lifeboatsFired" in level ) )
		level.lifeboatsFired <- null

	level.lifeboatsFired = 0

	// camera point at ship and track lifeboat
	if ( IsLockedVDU() )
		return

	local camOrg = Vector( 5283, 2409, 3663 )
	local camAng = Vector( -20, -130, 0 )
	local startFOV = 55
	local firstZoomEndFOV = 45

	level.camera.SetOrigin( camOrg )
	level.camera.SetAngles( camAng )
	level.camera.SetFOV( startFOV )

	local attachStartSweep = "R_escape_pod_1"
	local startSweep = SkyboxToWorldPosition( level.capitalShip.GetAttachmentOrigin( level.capitalShip.LookupAttachment( attachStartSweep ) ) )
	startSweep = camOrg + ClampVectorToCube( camOrg, startSweep - camOrg, Vector( 0, 0, 0 ), 32000.0 )

	local trackEnt = CreateClientsideScriptMover( "models/dev/empty_model.mdl", startSweep, Vector( 0, 0, 0 ) )

	OnThreadEnd(
		function () : ( trackEnt )
		{
			UnlockVDU()
			HideVDU()

			if ( IsValid( trackEnt ) )
				trackEnt.Kill()
		}
	)

	// take over the vdu screen
	LockVDU()

	// CAMERA MOVE 1:  Start with a wide shot of the ship that slowly zooms in to see the lifeboats
	local firstVOTime = 3
	local wideShotZoomTime = 2.8
	thread TrackEntityWithCamera( player, camOrg, trackEnt, firstVOTime, 0, 0, 0 )  // for easy aiming at the ship
	thread ZoomCameraOverTime( player, startFOV, firstZoomEndFOV, wideShotZoomTime, 0.2, 0 )

	SetNextVDUWideScreen( player )
	ShowVDU()

	thread FireLifeboats( 1 )

	// "Deploy all lifeboats!"
	EmitSoundOnEntity( player, "diag_at_milWinAnnc_OP220_06_01_imc_graves" )
	wait firstVOTime

	// "Sir! Are you there? Sir! Do you read me!"
	EmitSoundOnEntity( player, "diag_at_milWinAnnc_OP220_07_01_imc_blisk" )

	// find the end position that our camera tracked entity will move to
	local attachEndSweep = "l_thruster2"
	local endSweep = SkyboxToWorldPosition( level.capitalShip.GetAttachmentOrigin( level.capitalShip.LookupAttachment( attachEndSweep ) ) )
	endSweep = camOrg + ClampVectorToCube( camOrg, endSweep - camOrg, Vector( 0, 0, 0 ), 32000.0 )
	endSweep += Vector( 0, 0, 3000 ) // so the camera has more of the ship in frame

	// CAMERA MOVE 2: sweep the camera along the ship from nose to tail while doing ragged zooms ("searching")
	local sweepTime_1 = 3.0
	local sweepEndFOV_1 = 35
	local sweepEndFOV_1a = 25

	local sweepTime_2 = 1.8

	// First sweep: nose to tail
	//local totalTime = sweepTime_1 + sweepTime_2
	local trackingTime = 30 // longer than the whole sequence; cleans up when VDU opens again
	thread TrackEntityWithCamera( player, camOrg, trackEnt, trackingTime, 0, 0, 0 )

	trackEnt.NonPhysicsMoveTo( endSweep, sweepTime_1, 0.15, 0.08 )
	local startZoomDelay_1 = 1.2
	local zoomTime_1 = 0.7
	local startZoomDelay_1a = 0.25 + startZoomDelay_1 + zoomTime_1
	local zoomTime_1a = 0.25
	thread Delayed_ZoomCameraOverTime( startZoomDelay_1, player, firstZoomEndFOV, sweepEndFOV_1, zoomTime_1, 0, 0 )
	thread Delayed_ZoomCameraOverTime( startZoomDelay_1a, player, sweepEndFOV_1, sweepEndFOV_1a, zoomTime_1a, 0, 0 )
	wait sweepTime_1

	// CAMERA PAUSE AND ZOOM OUT A BIT
	local sweepEndFOV_1b = 30
	local zoomTime_1b = 0.4
	thread ZoomCameraOverTime( player, sweepEndFOV_1a, sweepEndFOV_1b, zoomTime_1b, 0, 0 )
	wait 0.8

	// CAMERA SWEEP BACK TO THE NOSE OF THE SHIP

	// Get the start attach position again in case the ship is moving
	local shipNosePos = level.capitalShip.GetAttachmentOrigin( level.capitalShip.LookupAttachment( attachStartSweep ) )
	local shipVec = level.capitalShip.GetAngles().AnglesToForward()
	shipNosePos += ( shipVec * 5 )  // offset more forward so we can see the nose of the ship in the frame. (units = SKYBOX SCALE aka small)
	local startSweep = SkyboxToWorldPosition( shipNosePos )
	startSweep = camOrg + ClampVectorToCube( camOrg, startSweep - camOrg, Vector( 0, 0, 0 ), 32000.0 )

	trackEnt.NonPhysicsMoveTo( startSweep, sweepTime_2, 0.15, 0.5 )
	local sweepEndFOV_2 = 30
	local startZoomDelay_2 = 0.3
	thread Delayed_ZoomCameraOverTime( startZoomDelay_2, player, sweepEndFOV_1b, sweepEndFOV_2, sweepTime_2, 0, 0 )

	wait 1.6

	// CAMERA WATCHES GRAVES' LIFEBOAT ESCAPE

	local gravesLifeboatData = CreateLifeboatEscapeData( "P_SB_Escape_Pod_attach", "broken01" )
	local angToAdd = Vector( -27, 0, 0 )
	thread LifeboatEscapes( gravesLifeboatData, angToAdd )

	local trackLifeboatTime = 3.0  // the shorter the time, the faster the camera moves
	local trackLifeboat_zoomTime = 2.5
	local trackLifeboat_endFOV = 10
	//local lifeboatSweep = shipNosePos += ( shipVec * 20 )
	//lifeboatSweep += Vector( 20, 0, 0 )
	//lifeboatSweep = SkyboxToWorldPosition( lifeboatSweep )
	//trackEnt.NonPhysicsMoveTo( lifeboatSweep, trackLifeboatTime, 0.2, 0.75 )

	local shipNoseAng = level.capitalShip.GetAttachmentAngles( level.capitalShip.LookupAttachment( attachStartSweep ) )
	// NOTE: this tag was created to play FX so its axes don't get adjusted in a normal way.
	angToAdd += Vector( 0, 0, 60 )  // tilt up a bit more
	local shipNoseFwd = ( shipNoseAng.AnglesToRight() + angToAdd.AnglesToRight() ) * -1  // FX angles are weird so we use inverted angles to right to match the FX direction of travel
	local lifeboatSweep = shipNosePos + ( shipNoseFwd * 6 )
	lifeboatSweep = SkyboxToWorldPosition( lifeboatSweep )
	trackEnt.NonPhysicsMoveTo( lifeboatSweep, trackLifeboatTime, 0.2, 0.75 )

	thread TrackEntityWithCamera( player, camOrg, trackEnt, 10, 400, 1.0, 0 )
	thread ZoomCameraOverTime( player, sweepEndFOV_2, trackLifeboat_endFOV, trackLifeboat_zoomTime, 0, 0.3 )

	local preVOWait = 0.5
	wait preVOWait

	// "Copy that. I'm clear."
	EmitSoundOnEntity( player, "diag_at_milWinAnnc_OP220_09_01_imc_graves" )
	wait trackLifeboatTime - preVOWait

	wait 2

	printt( "Graves Lifeboat VDU Sequence Time:", Time() - startTime )
}

function SetupLifeboats()
{
	if ( !( "lifeboatsFired" in level ) )
		level.lifeboatsFired <- null

	level.lifeboatsFired = 0

	if ( !( "lifeboatData" in level ) )
		level.lifeboatData <- null

	level.lifeboatData = []
	// copied from the QC, where we already had lifeboats escaping when the IMC win
	AddLifeboatEscapeData( 600, "P_SB_Escape_Pod_L", "L_escape_pod_1" )
	AddLifeboatEscapeData( 610, "P_SB_Escape_Pod_L", "L_escape_pod_5" )
	AddLifeboatEscapeData( 620, "P_SB_Escape_Pod_L", "L_escape_pod_3" )
	AddLifeboatEscapeData( 630, "P_SB_Escape_Pod_L", "L_escape_pod_7" )
	AddLifeboatEscapeData( 640, "P_SB_Escape_Pod_L", "L_escape_pod_4" )
	AddLifeboatEscapeData( 650, "P_SB_Escape_Pod_L", "L_escape_pod_2" )
	AddLifeboatEscapeData( 660, "P_SB_Escape_Pod_L", "L_escape_pod_6" )
	AddLifeboatEscapeData( 685, "P_SB_Escape_Pod_L", "L_escape_pod_2" )
	AddLifeboatEscapeData( 700, "P_SB_Escape_Pod_L", "L_escape_pod_1" )
	AddLifeboatEscapeData( 725, "P_SB_Escape_Pod_L", "L_escape_pod_6" )
	AddLifeboatEscapeData( 735, "P_SB_Escape_Pod_L", "L_escape_pod_5" )
	AddLifeboatEscapeData( 745, "P_SB_Escape_Pod_L", "L_escape_pod_3" )
	AddLifeboatEscapeData( 755, "P_SB_Escape_Pod_L", "L_escape_pod_4" )
	AddLifeboatEscapeData( 765, "P_SB_Escape_Pod_L", "L_escape_pod_7" )
	AddLifeboatEscapeData( 600, "P_SB_Escape_Pod", "R_escape_pod_1" )
	AddLifeboatEscapeData( 610, "P_SB_Escape_Pod", "R_escape_pod_5" )
	AddLifeboatEscapeData( 620, "P_SB_Escape_Pod", "R_escape_pod_3" )
	AddLifeboatEscapeData( 630, "P_SB_Escape_Pod", "R_escape_pod_7" )
	AddLifeboatEscapeData( 640, "P_SB_Escape_Pod", "R_escape_pod_4" )
	AddLifeboatEscapeData( 650, "P_SB_Escape_Pod", "R_escape_pod_2" )
	AddLifeboatEscapeData( 660, "P_SB_Escape_Pod", "R_escape_pod_6" )
	AddLifeboatEscapeData( 685, "P_SB_Escape_Pod", "R_escape_pod_2" )
	AddLifeboatEscapeData( 700, "P_SB_Escape_Pod", "R_escape_pod_1" )
	AddLifeboatEscapeData( 725, "P_SB_Escape_Pod", "R_escape_pod_6" )
	AddLifeboatEscapeData( 735, "P_SB_Escape_Pod", "R_escape_pod_5" )
	AddLifeboatEscapeData( 745, "P_SB_Escape_Pod", "R_escape_pod_3" )
	AddLifeboatEscapeData( 755, "P_SB_Escape_Pod", "R_escape_pod_4" )
	AddLifeboatEscapeData( 765, "P_SB_Escape_Pod", "R_escape_pod_7" )
	AddLifeboatEscapeData( 800, "P_SB_Escape_Pod_L", "L_escape_pod_1" )
	AddLifeboatEscapeData( 810, "P_SB_Escape_Pod_L", "L_escape_pod_5" )
	AddLifeboatEscapeData( 820, "P_SB_Escape_Pod_L", "L_escape_pod_3" )
	AddLifeboatEscapeData( 830, "P_SB_Escape_Pod_L", "L_escape_pod_7" )
	AddLifeboatEscapeData( 840, "P_SB_Escape_Pod_L", "L_escape_pod_4" )
	AddLifeboatEscapeData( 850, "P_SB_Escape_Pod_L", "L_escape_pod_2" )
	AddLifeboatEscapeData( 860, "P_SB_Escape_Pod_L", "L_escape_pod_6" )
	AddLifeboatEscapeData( 885, "P_SB_Escape_Pod_L", "L_escape_pod_2" )
	AddLifeboatEscapeData( 900, "P_SB_Escape_Pod_L", "L_escape_pod_1" )
	AddLifeboatEscapeData( 925, "P_SB_Escape_Pod_L", "L_escape_pod_6" )
	AddLifeboatEscapeData( 935, "P_SB_Escape_Pod_L", "L_escape_pod_5" )
	AddLifeboatEscapeData( 945, "P_SB_Escape_Pod_L", "L_escape_pod_3" )
	AddLifeboatEscapeData( 955, "P_SB_Escape_Pod_L", "L_escape_pod_4" )
	AddLifeboatEscapeData( 965, "P_SB_Escape_Pod_L", "L_escape_pod_7" )
	AddLifeboatEscapeData( 700, "P_SB_Escape_Pod", "R_escape_pod_1" )
	AddLifeboatEscapeData( 810, "P_SB_Escape_Pod", "R_escape_pod_5" )
	AddLifeboatEscapeData( 820, "P_SB_Escape_Pod", "R_escape_pod_3" )
	AddLifeboatEscapeData( 830, "P_SB_Escape_Pod", "R_escape_pod_7" )
	AddLifeboatEscapeData( 840, "P_SB_Escape_Pod", "R_escape_pod_4" )
	AddLifeboatEscapeData( 850, "P_SB_Escape_Pod", "R_escape_pod_2" )
	AddLifeboatEscapeData( 860, "P_SB_Escape_Pod", "R_escape_pod_6" )
	AddLifeboatEscapeData( 885, "P_SB_Escape_Pod", "R_escape_pod_2" )
	AddLifeboatEscapeData( 900, "P_SB_Escape_Pod", "R_escape_pod_1" )
	AddLifeboatEscapeData( 925, "P_SB_Escape_Pod", "R_escape_pod_6" )
	AddLifeboatEscapeData( 935, "P_SB_Escape_Pod", "R_escape_pod_5" )
	AddLifeboatEscapeData( 945, "P_SB_Escape_Pod", "R_escape_pod_3" )
	AddLifeboatEscapeData( 955, "P_SB_Escape_Pod", "R_escape_pod_4" )
	AddLifeboatEscapeData( 965, "P_SB_Escape_Pod", "R_escape_pod_7" )
}

function AddLifeboatEscapeData( ogFrameNum, fxAlias, attachName )
{
	local data = CreateLifeboatEscapeData( fxAlias, attachName, ogFrameNum )
	level.lifeboatData.append( data )
}

function CreateLifeboatEscapeData( fxAlias, attachName, ogFrameNum = null )
{
	Assert( IsValid( level.capitalShip ) )

	local delay = 0
	if ( ogFrameNum )
	{
		local frameDelay = ( ogFrameNum - 600 ).tofloat()  // frames before trigger
		delay = frameDelay / 60.0

		if ( delay < 0 )
			delay = 0
	}

	local attachID = level.capitalShip.LookupAttachment( attachName )

	local fxID = level.FX_LIFEBOAT
	if ( fxAlias == "P_SB_Escape_Pod_L" )
		fxID = level.FX_LIFEBOAT_L

	local data = { delay = delay, fxID = fxID, attachID = attachID }
	return data
}

function FireLifeboats( startDelay = 0 )
{
	local player = GetLocalClientPlayer()

	if ( player != GetLocalViewPlayer() )
		return
	if ( IsWatchingKillReplay() )
		return

	player.EndSignal( "OnDestroy" )
	level.capitalShip.EndSignal( "OnDestroy" )

	if ( startDelay > 0 )
		wait startDelay

	local lifeboatsFired = 0
	foreach ( data in level.lifeboatData )
	{
		lifeboatsFired++
		thread LifeboatEscapes( data )
	}
}

function LifeboatEscapes( escapeData, addAngles = null )
{
	Assert( IsValid( level.capitalShip ) )

	local player = GetLocalClientPlayer()
	if ( player != GetLocalViewPlayer() )
		return
	if ( IsWatchingKillReplay() )
		return

	player.EndSignal( "OnDestroy" )
	level.capitalShip.EndSignal( "OnDestroy" )

	if ( escapeData.delay > 0 )
		wait escapeData.delay

	level.lifeboatsFired++

	local fxID = escapeData.fxID
	local attachID = escapeData.attachID

	local startOrg = level.capitalShip.GetAttachmentOrigin( attachID )
	local startAng = level.capitalShip.GetAttachmentAngles( attachID )

	if ( addAngles )
		startAng += addAngles

	local playerOrg = player.GetOrigin()
	local audioPos = SkyboxToWorldPosition( level.capitalShip.GetAttachmentOrigin( level.capitalShip.LookupAttachment( "broken02" ) ) )
	audioPos = playerOrg + ClampVectorToCube( playerOrg, audioPos - playerOrg, Vector( 0, 0, 0 ), 32000.0 )
	EmitSoundAtPosition( audioPos, "outpost207_Sentinel_Lifeboat_Launch" )

	StartParticleEffectInWorld( fxID, startOrg, startAng )
	//printt( "starting lifeboat particle" )
}

function ServerCallback_CapitalShip_FireLifeboats( startdelay = 0 )
{
	thread FireLifeboats( startdelay )
}

function ServerCallback_PostEpilogue_IMC_IMCwon_ShipEscapeVO()
{
	thread PostEpilogue_IMC_IMCwon_ShipEscapeVO()
}

function PostEpilogue_IMC_IMCwon_ShipEscapeVO()
{
	local player = GetLocalClientPlayer()
	player.EndSignal( "OnDestroy" )

	// Sir, the Sentinel has critical structural damage. Crash-landing will ground her forever.
	EmitSoundOnEntity( player, "diag_at_imcWinAnnc_OP222_03_01_imc_blisk" )
	wait 5.5

	// She's still valuable, Blisk. We'll strip her weapons, armor, and drive systems.
	EmitSoundOnEntity( player, "diag_at_imcWinAnnc_OP222_04_01_imc_graves" )
	wait 4.8

	// Understood. sir. Prepping lifeboats for launch.
	EmitSoundOnEntity( player, "diag_at_imcWinAnnc_OP222_05_01_imc_blisk" )
}

function Delayed_ZoomCameraOverTime( delay, player, startFOV, finalFOV, zoomDuration, easeIn, easeOut )
{
	level.ent.EndSignal( "ResetCannonVDU" )
	player.EndSignal( "OnDestroy" )

	wait delay

	thread ZoomCameraOverTime( player, startFOV, finalFOV, zoomDuration, easeIn, easeOut )
}

function Delayed_RotateCameraOverTime( delay, player, startAng, finalAng, rotateDuration, easeIn, easeOut )
{
	level.ent.EndSignal( "ResetCannonVDU" )
	player.EndSignal( "OnDestroy" )

	wait delay

	thread RotateCameraOverTime( player, startAng, finalAng, rotateDuration, easeIn, easeOut )
}

function ServerCallback_DecoyShipWarpsIn()
{
	thread ServerCallback_DecoyShipWarpsIn_Think()
}

function ServerCallback_DecoyShipWarpsIn_Think()
{
	local player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )

	if ( !IsValid( level.decoyShip ) )
		return

	level.ent.Signal( "DecoyShipWarpsIn" )

	local org = level.decoyShip.GetOrigin()
	local ang = level.decoyShip.GetAngles()

	EmitSoundAtPosition( org, "dropship_warpin" )
	wait 2.0
	StartParticleEffectInWorld( level.FX_DECOY_SHIP_WARP_IN, org, ang )
}

function EffectStopAfterTime( delay, fxHandle, doRemoveAllParticlesNow = false, doPlayEndCap = true )
{
	wait delay
	EffectStop( fxHandle, doRemoveAllParticlesNow, doPlayEndCap )
}

// ---- CAPITAL SHIP/ SPACE STATION FACADE FADE ----
function VMTCallback_OutpostCapitalShipMaterialFade( ent )
{
	//printt( "megaship material fade:", level.nv.capitalShipLightingFacadeAlpha )
	return level.nv.capitalShipLightingFacadeAlpha
}

function VMTCallback_OutpostSpaceStationMaterialFade( ent )
{
	//printt( "space station material fade:", level.nv.spaceStationLightingFacadeAlpha )
	return level.nv.spaceStationLightingFacadeAlpha
}


// ---- CANNON VENT STEAM ----
function CannonSteamFXSetup()
{
	level.cannonSteamFXSpots = GetEntArrayByClassAndTargetname( "info_target_clientside", "steam_shoot_fx_small" )
	Assert( level.cannonSteamFXSpots.len() )
	level.cannonSteamFXSpots.extend( GetEntArrayByClassAndTargetname( "info_target_clientside", "steam_shoot_fx_small_cheap" ) )
	level.cannonSteamFXSpots.extend( GetEntArrayByClassAndTargetname( "info_target_clientside", "steam_shoot_fx_linger" ) )
}

function Outpost_CannonVentingChange()
{
	if ( level.nv.cannonVentingFXOn )
		CannonVentingFXStart()
	else
		CannonVentingFXStop()
}

function CannonVentingFXStart()
{
	foreach ( fxSpot in level.cannonSteamFXSpots )
	{
		local fxAlias = level.FX_STEAM_SHOOT
		local soundAlias = "amb_outpost207_emitter_steam_large"

		if ( fxSpot.GetName() == "steam_shoot_fx_small_cheap" )
		{
			fxAlias = level.FX_STEAM_SHOOT_CHEAP
			soundAlias = "amb_outpost207_emitter_steam_small"
		}
		else if ( fxSpot.GetName() == "steam_shoot_fx_linger" )
		{
			fxAlias = level.FX_STEAM_SHOOT_LINGER
			soundAlias = "amb_outpost207_emitter_steam_medium"
		}

		thread CannonSteamStartFX( fxAlias, fxSpot, soundAlias, RandomFloat( 0, 0.1 ) )
	}
}

function CannonSteamStartFX( fxAlias, fxSpot, soundAlias, delay )
{
	local player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )

	if ( delay > 0 )
		wait delay

	local handle = StartParticleEffectInWorldWithHandle( fxAlias, fxSpot.GetOrigin(), fxSpot.GetAngles() )
	level.cannonSteamFXHandles.append( handle )

	EmitSoundOnEntity( fxSpot, soundAlias )
}

function CannonVentingFXStop()
{
	StopFXArray( level.cannonSteamFXHandles )
	level.cannonSteamFXHandles = []

	thread CannonVentingSFXStop()
}

function CannonVentingSFXStop()
{
	local player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )

	local shutoffSoundPos = Vector( -88, -800, -460 )  // inside the center of the cannon room
	EmitSoundAtPosition( shutoffSoundPos, "amb_outpost207_emitter_steam_shutoff" )

	wait 1.0  // this is so the shutoff sound can cover the steam emitter loop sounds turning off

	foreach ( fxSpot in level.cannonSteamFXSpots )
	{
		StopSoundOnEntity( fxSpot, "amb_outpost207_emitter_steam_small" )
		StopSoundOnEntity( fxSpot, "amb_outpost207_emitter_steam_medium" )
		StopSoundOnEntity( fxSpot, "amb_outpost207_emitter_steam_large" )
	}
}

function ServerCallback_CannonWarningVO()
{
	thread CannonWarningVO_Think()
}

function CannonWarningVO_Think()
{
	if ( Flag( "CannonWarningVO_InProgress" ) )
		return

	FlagSet( "CannonWarningVO_InProgress" )

	OnThreadEnd(
		function () : ()
		{
			FlagClear( "CannonWarningVO_InProgress" )
		}
	)

	local openers = []
	// "Warning."
	openers.append( "diag_rgPrefire_OP128_01_01_neut_rgunpa" )
	// "Alert."
	openers.append( "diag_rgPrefire_OP128_01_02_neut_rgunpa" )
	// "Danger."
	openers.append( "diag_rgPrefire_OP128_01_03_neut_rgunpa" )

	local allcalls = []
	// "All outpost personnel..."
	allcalls.append( "diag_rgPrefire_OP129_01_01_neut_rgunpa" )
	// "All hands..."
	allcalls.append( "diag_rgPrefire_OP129_01_02_neut_rgunpa" )

	local orders = []
	// "Railgun prefire sequence initialized."
	orders.append( "diag_rgPrefire_OP130_01_01_neut_rgunpa" )
	// "Diverting power to railgun."
	orders.append( "diag_rgPrefire_OP130_01_02_neut_rgunpa" )
	// "Railgun failsafes have been disabled. Use caution."
	orders.append( "diag_rgPrefire_OP130_01_03_neut_rgunpa" )
	// "Clear the cannon building..."
	orders.append( "diag_rgPrefire_OP129_01_04_neut_rgunpa" )

	local linesToPlay = []

	// put the lines together semirandomly
	local opener = openers[ RandomInt( openers.len() ) ]
	linesToPlay.append( opener )

	local allcall = allcalls[ RandomInt( allcalls.len() ) ]
	linesToPlay.append( allcall )

	local order = orders[ RandomInt( orders.len() ) ]
	linesToPlay.append( order )

	local duration = 0
	foreach ( line in linesToPlay )
	{
		//printt( "playing line", line )
		duration = EmitSoundOnEntity( GetLocalViewPlayer(), line )
		wait ( duration * 0.7 )  // HACK all the lines have a bit of extra time at the end
	}
}

// ---- CANNON THERMAL DRUMS ----
function CannonThermalDrumsSetup()
{
	local props = GetEntArrayByClassAndTargetname( "prop_dynamic", "cannon_rotating_drum" )
	Assert( props.len() )

	// convert to script_movers so we can rotate them
	foreach ( prop in props )
		CannonThermalDrumSetup( prop )
}

function CannonThermalDrumSetup( prop )
	{
		local modelname = prop.GetModelName()

		local drum = CreateClientsideScriptMover( modelname, prop.GetOrigin(), prop.GetAngles() )
		drum.s.ogAng <- drum.GetAngles()
		level.cannonThermalDrums.append( drum )
		prop.Kill()
	}

function Outpost_CannonDrumsSpinChange()
{
	if ( level.nv.cannonThermalDrumsSpin )
		CannonThermalDrumsStart()
}

function CannonThermalDrumsStart()
{
	foreach ( drum in level.cannonThermalDrums )
		thread CannonThermalDrumSpin( drum )
}

function CannonThermalDrumSpin( drum )
{
	drum.Signal( "CannonThermalDrumSpinStart" )
	drum.EndSignal( "CannonThermalDrumSpinStart")

	local halfRotationTime = 0.35
	local halfRotationRoll = 180

	drum.SetAngles( drum.s.ogAng )

	if ( !( "glowFxHandle" in drum.s ) )
		drum.s.glowFxHandle <- null

	local offsetVec = drum.GetAngles().AnglesToRight() * -1
	local glowOrg = drum.GetOrigin() + ( offsetVec * 40 )
	local glowAng = drum.GetAngles() + Vector( 0, -90, 0 )

	drum.s.glowFxHandle = StartParticleEffectInWorldWithHandle( level.FX_CANNON_THERMAL_DRUM_GLOW, glowOrg, glowAng )

	OnThreadEnd(
		function() : ( drum )
		{
			if ( EffectDoesExist( drum.s.glowFxHandle ) )
				EffectStop( drum.s.glowFxHandle, false, true )

			drum.s.glowFxHandle = null
		}
	)

	while ( level.nv.cannonThermalDrumsSpin )
	{
		local newAng = drum.GetAngles() + Vector( 0, 0, halfRotationRoll )
		if ( newAng.z >= 360 )
		{
			drum.SetAngles( drum.s.ogAng )
			continue
		}

		drum.NonPhysicsRotateTo( newAng, halfRotationTime, 0, 0 )
		wait halfRotationTime
		//drum.SetAngles( Vector( 0, 0, 0 ) )
	}

	// slow down before stopping
	local lastAng = drum.GetAngles() + Vector( 0, 0, halfRotationRoll )
	if ( lastAng.z >= 360 )
	{
		drum.SetAngles( drum.s.ogAng )
		lastAng = drum.GetAngles() + Vector( 0, 0, halfRotationRoll )
	}

	local lastRotateTime = 5.0
	local decelTime = lastRotateTime * 0.9
	drum.NonPhysicsRotateTo( lastAng, lastRotateTime, 0, decelTime )
}

// ---- CANNON MONITOR SCREENS ----
function CannonMonitorsSetup()
{
	level.cannonMonitors = GetEntArrayByClassAndTargetname( "prop_dynamic", "screen_cannon_status" )
	Assert( level.cannonMonitors.len() )
}

// level.CANNON_SCREEN_IDLE, level.CANNON_SCREEN_FIRING, level.CANNON_SCREEN_COOLING
function Outpost_CannonMonitorScreensChange()
{
	local modelname = null

	switch ( level.nv.cannonMonitorScreenStatus )
	{
		case level.CANNON_SCREEN_IDLE:
			modelname = level.CANNON_SCREEN_IDLE_MODEL
			break

		case level.CANNON_SCREEN_FIRING:
			modelname = level.CANNON_SCREEN_FIRING_MODEL
			break

		case level.CANNON_SCREEN_COOLING:
			modelname = level.CANNON_SCREEN_COOLING_MODEL
			break
	}

	foreach ( screen in level.cannonMonitors )
		thread Delayed_MonitorFlickerAndChange( RandomFloat( 0, 0.8 ), screen, modelname )
}

function Delayed_MonitorFlickerAndChange( delay, screen, modelname )
{
	local player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )

	wait delay

	thread MonitorFlickerAndChange( screen, modelname )
}

// ---- WARNING LIGHTS ----
function WarningLightsSetup()
{
	level.warningLightFXSpots = GetEntArrayByClassAndTargetname( "info_target_clientside", "warning_light_fx" )
	Assert( level.warningLightFXSpots.len() )
	level.warningLightFXSpots.extend( GetEntArrayByClassAndTargetname( "info_target_clientside", "warning_light_fx_nowall" ) )

	level.warningLightModels = GetEntArrayByClassAndTargetname( "prop_dynamic", "warning_light_ON" )
	Assert( level.warningLightModels.len() )

	foreach ( model in level.warningLightModels )
		model.SetModel( level.WARNING_LIGHT_OFF_MODEL )
}

function Outpost_WarningLightsChange()
{
	if ( level.nv.warningLightsOn )
		WarningLightsStart()
	else
		WarningLightsStop()
}

function WarningLightsStart()
{
	foreach ( fxSpot in level.warningLightFXSpots )
		thread WarningLightStartFX( fxSpot, RandomFloat( 0, 0.1 ) )

	thread WarningLightsModelSwap( "on", 0.1 )
}

function WarningLightStartFX( fxSpot, delay = 0 )
{
	local player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )

	if ( delay > 0)
		wait delay

	local fxAlias = level.FX_WARNING_LIGHT
	if ( fxSpot.GetName() == "warning_light_fx_nowall" )
		fxAlias = level.FX_WARNING_LIGHT_NOWALL

	local handle = StartParticleEffectInWorldWithHandle( fxAlias, fxSpot.GetOrigin(), fxSpot.GetAngles() )
	level.warningLightHandles.append( handle )
}

function WarningLightsStop()
{
	WarningLightsModelSwap( "off" )

	StopFXArray( level.warningLightHandles )

	level.warningLightHandles = []
}

function WarningLightsModelSwap( state, delay = 0 )
{
	local player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )

	if ( delay > 0 )
		wait delay

	local swapModel = level.WARNING_LIGHT_ON_MODEL
	if ( state == "off" )
		swapModel = level.WARNING_LIGHT_OFF_MODEL

	foreach ( model in level.warningLightModels )
		model.SetModel( swapModel )
}


function StopFXArray( fxArrayToStop )
{
	foreach ( handle in fxArrayToStop )
	{
		//  handle, doRemoveAllParticlesNow, doPlayEndCap
		if ( EffectDoesExist( handle ) )
			EffectStop( handle, false, true )
	}
}

function CE_VisualSettingOutpostIMC( player, ref )
{
	CE_ResetVisualSettings( player )

	ref.LerpSkyScale( SKYSCALE_OUTPOST_IMC_SHIP, 0.01 )
}

function CE_VisualSettingOutpostMCOR( player, ref )
{
	CE_ResetVisualSettings( player )

	ref.LerpSkyScale( SKYSCALE_OUTPOST_MCOR_SHIP, 0.01 )
}

function CE_BloomOnRampOpenOutpostMCOR( player, ref )
{
	AddAnimEvent( ref, "cl_ramp_open", TonemappingOnDoorOpenOutpost, SKYSCALE_OUTPOST_DOOROPEN_MCOR_SHIP )
}

function CE_BloomOnRampOpenOutpostIMC( player, ref )
{
	AddAnimEvent( ref, "cl_ramp_open", TonemappingOnDoorOpenOutpost, SKYSCALE_OUTPOST_DOOROPEN_IMC_SHIP )
}

function TonemappingOnDoorOpenOutpost( ref, scale )
{
	ref.LerpSkyScale( scale, 1.0 )
	thread CinematicTonemappingThread()
}

//=========================================================
//			NODE TOOLS
//=========================================================
function NodeCleanUp( node )
{
	if ( DEV_EDITOR )
	{
		node.pos += Vector( 0,0,20 )
		local result = TraceLine( node.pos, node.pos + Vector( 0,0,-200 ), null, TRACE_MASK_NPCWORLDSTATIC, TRACE_COLLISION_GROUP_NONE )
		node.pos = result.endPos
	}

	if ( !( "ents" in node ) )
		node.ents <- []

	foreach ( ent in node.ents )
	{
		if ( IsValid( ent ) )
			ent.Kill()
	}

	node.ents = []
}

function Cl_SetParent( ent, _parent, tag = "", keepOffset = false, time = 0.0 )
{
	ent.SetParent( _parent, tag, keepOffset, time )

	if ( ( tag != "" ) && !keepOffset )
	{
		ent.SetAttachOffsetAngles( Vector( 0, 0, 0 ) )
		ent.SetAttachOffsetOrigin( Vector( 0, 0, 0 ) )
	}
}