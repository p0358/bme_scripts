const MUSEUM_TRIGGER_RANGE = 1500
const SPECTRE_ASSEMBLY_ANIM_DELTA = 98.424881
const SPECTRE_ASSEMBLY_ANIM_Z_OFFSET = 0
const SPECTRE_EXPLOSION_COOLDOWN = 1.5

//model swaps for factory blowing up
const INTACT_MODEL_ASSEMBLY = "models/levels_terrain/mp_corporate/assembly_tube_breaker_side_intact.mdl"
const BROKEN_MODEL_ASSEMBLY = "models/levels_terrain/mp_corporate/assembly_tube_breaker_side_broken.mdl"
const INTACT_MODEL_PARKING_01 = "models/levels_terrain/mp_corporate/corporate_parking_garage01_piece01_intact.mdl"
const BROKEN_MODEL_PARKING_01 = "models/levels_terrain/mp_corporate/corporate_parking_garage01_piece01_broken.mdl"
const INTACT_MODEL_PARKING_02 = "models/levels_terrain/mp_corporate/corporate_parking_garage01_piece02_intact.mdl"
const BROKEN_MODEL_PARKING_02 = "models/levels_terrain/mp_corporate/corporate_parking_garage01_piece02_broken.mdl"
const INTACT_MODEL_PARKING_03 = "models/levels_terrain/mp_corporate/corporate_parking_garage01_piece03_intact.mdl"
const BROKEN_MODEL_PARKING_03 = "models/levels_terrain/mp_corporate/corporate_parking_garage01_piece03_broken.mdl"
const INTACT_MODEL_PARKING_04 = "models/levels_terrain/mp_corporate/corporate_parking_garage01_piece04_intact.mdl"
const BROKEN_MODEL_PARKING_04 = "models/levels_terrain/mp_corporate/corporate_parking_garage01_piece04_broken.mdl"
const INTACT_MODEL_SMALLSTORAGE_01 = "models/levels_terrain/mp_corporate/corporate_parking_garage_small_piece01_intact.mdl"
const BROKEN_MODEL_SMALLSTORAGE_01 = "models/levels_terrain/mp_corporate/corporate_parking_garage_small_piece01_broken.mdl"
const INTACT_MODEL_SMALLSTORAGE_02 = "models/levels_terrain/mp_corporate/corporate_parking_garage_small_piece02_intact.mdl"
const BROKEN_MODEL_SMALLSTORAGE_02 = "models/levels_terrain/mp_corporate/corporate_parking_garage_small_piece02_broken.mdl"
const INTACT_MODEL_SMALLSTORAGE_03 = "models/levels_terrain/mp_corporate/corporate_parking_garage_small_piece03_intact.mdl"
const BROKEN_MODEL_SMALLSTORAGE_03 = "models/levels_terrain/mp_corporate/corporate_parking_garage_small_piece03_broken.mdl"
const INTACT_MODEL_SMALLSTORAGE_04 = "models/levels_terrain/mp_corporate/corporate_parking_garage_small_piece04_intact.mdl"
const BROKEN_MODEL_SMALLSTORAGE_04 = "models/levels_terrain/mp_corporate/corporate_parking_garage_small_piece04_broken.mdl"

const FX_SPECTRE_EXPLOSION	= "P_spectre_suicide"
const FX_GLASS_EXPLOSION_ASSEMBLY_TUBE = "P_env_glass_exp_tube"
const FX_EXP_ASSEMBLY_TUBE = "P_impact_exp_Xlarge_full"
const FX_FIRE_ASSEMBLY_TUBE = "P_fire_rooftop"
const FX_EXP_ASSEMBLY_TUBE_INT = "P_impact_exp_Xlarge_full"
const FX_FIRE_ASSEMBLY_TUBE_INT = "P_fire_med_FULL"
const FX_EXP_PARKING_ROOF = "P_impact_exp_Xlarge_full"
const FX_FIRE_PARKING_ROOF = "P_fire_wall"
const FX_EXP_UPPER_PARKING = "exp_redeye_med_CH_fire"
const FX_FIRE_UPPER_PARKING = "P_fire_wall"
const FX_EXP_UPPER_BG_BLDG = "P_exp_redeye_sml"
const FX_FIRE_UPPER_BG_BLDG = "P_fire_wall"
const FX_EXP_BG_BLDG_ROOF = "P_exp_building_med"
const FX_FIRE_BG_BLDG_ROOF = "P_fire_wall"
const FX_EXP_UPPER_SKYSCRAPER = "P_exp_building_med"
const FX_FIRE_UPPER_SKYSCRAPER = "P_fire_wall"
const FX_EXP_LOWER_SKYSCRAPER = "P_exp_redeye_sml"
const FX_FIRE_LOWER_SKYSCRAPER = "P_fire_wall"
const FX_EXP_OFFICE_ROOF = "P_exp_redeye_sml"
const FX_FIRE_OFFICE_ROOF = "P_fire_wall"
const FX_EXP_LAB_ROOF = "P_exp_building_med"
const FX_FIRE_LAB_ROOF = "P_fire_wall"
const FX_EXP_VENT_GENERIC = "P_exp_redeye_sml"
const FX_FIRE_VENT_GENERIC = "P_fire_med_FULL"

const SFX_SPECTRE_EXPLODE = "corporate_spectre_death_explode"
const SFX_TUBE_GLASS_SHATTER = "Glass.Break"
const SFX_EXP_LARGE = "corporate_building_explosion"
const SFX_EXP_SMALL = "corporate_building_explosion"
const SFX_FIRE_LOOP_LARGE = "amb_corporate_fire_large"
const SFX_FIRE_LOOP_MED = "amb_corporate_fire_medium"
const SFX_FIRE_LOOP_SMALL = "amb_corporate_fire_small"
const SFX_ASSEMBLY_LINE_MOVEMENT = "amb_corporate_emitter_SpectreConveyor"

PrecacheParticleSystem( FX_SPECTRE_EXPLOSION )
PrecacheParticleSystem( FX_GLASS_EXPLOSION_ASSEMBLY_TUBE )
PrecacheParticleSystem( FX_EXP_ASSEMBLY_TUBE )
PrecacheParticleSystem( FX_FIRE_ASSEMBLY_TUBE )
PrecacheParticleSystem( FX_EXP_ASSEMBLY_TUBE_INT )
PrecacheParticleSystem( FX_FIRE_ASSEMBLY_TUBE_INT )
PrecacheParticleSystem( FX_EXP_PARKING_ROOF )
PrecacheParticleSystem( FX_FIRE_PARKING_ROOF )
PrecacheParticleSystem( FX_EXP_UPPER_PARKING )
PrecacheParticleSystem( FX_FIRE_UPPER_PARKING )
PrecacheParticleSystem( FX_EXP_UPPER_BG_BLDG )
PrecacheParticleSystem( FX_FIRE_UPPER_BG_BLDG )
PrecacheParticleSystem( FX_EXP_BG_BLDG_ROOF )
PrecacheParticleSystem( FX_FIRE_BG_BLDG_ROOF )
PrecacheParticleSystem( FX_EXP_UPPER_SKYSCRAPER )
PrecacheParticleSystem( FX_FIRE_UPPER_SKYSCRAPER )
PrecacheParticleSystem( FX_EXP_LOWER_SKYSCRAPER )
PrecacheParticleSystem( FX_FIRE_LOWER_SKYSCRAPER )
PrecacheParticleSystem( FX_EXP_OFFICE_ROOF )
PrecacheParticleSystem( FX_FIRE_OFFICE_ROOF )
PrecacheParticleSystem( FX_EXP_LAB_ROOF )
PrecacheParticleSystem( FX_FIRE_LAB_ROOF )
PrecacheParticleSystem( FX_EXP_VENT_GENERIC )
PrecacheParticleSystem( FX_FIRE_VENT_GENERIC )

FlagInit( "FactoryBlowingUp" )
FlagInit( "AssemblyLineMoving" )
FlagInit( "AssemblyLineSoundsPlaying" )
FlagInit( "epilogueStarted" )
FlagInit( "EndingScene" )

//spectreAssemblyCount <- 0




function main()
{
	level.playCinematicContent <- false
	if ( ( GetCinematicMode() ) && ( GAMETYPE == CAPTURE_POINT ) )
		level.playCinematicContent = true

	if ( level.playCinematicContent )
	{
		CinematicIntroScreen_SetText( TEAM_IMC, 	[ "#INTRO_SCREEN_CORPORATE_LINE1", "#INTRO_SCREEN_CORPORATE_LINE2", "#INTRO_SCREEN_CORPORATE_LINE3" ] )
		CinematicIntroScreen_SetText( TEAM_MILITIA, 	[ "#INTRO_SCREEN_CORPORATE_LINE1", "#INTRO_SCREEN_CORPORATE_LINE2", "#INTRO_SCREEN_CORPORATE_LINE3" ] )

		Globalize( ServerCallback_gameProgress )

		RegisterServerVarChangeCallback( "assemblyLineStops", AssemblyLineChange )
		RegisterServerVarChangeCallback( "doEnding", DoEnding )

		level.winners <- null
		level.screenShaking <- false
	}

	Globalize( CE_VisualSettingCorporateMCOR )
	Globalize( CE_VisualSettingCorporateIMC )
	Globalize( CE_BloomOnRampOpenCorporateIMC )

	level.assemblyTubeEnts <-[]	//need this for classic too so we can spawn the intact versions
	RegisterSignal( "AssemblyAnimsAtEnd" )
	level.soundPositionMuseum <- Vector( 1930, 758, -974 )
	SetFullscreenMinimapParameters( 2.5, 1650, 200, 180 )
	if ( GAMETYPE == COOPERATIVE )
		SetCustomMinimapZoom( 2 )
}

function EntitiesDidLoad()
{
	HideEndingArmada()

	if ( GameRules.GetGameMode() == COOPERATIVE )
		return

	level.lastTimeSpectreExploded <- Time()

	level.fxEnts <- GetClientEntArray( "info_target_clientside", "fx_explosion" )
	Assert( level.fxEnts.len() > 0, "CORPORATE: No fx entities found for end explosion sequence" )
	foreach( ent in level.fxEnts )
		FxEndExplosionSetup( ent )

	level.assemblylineSoundEnts <- GetClientEntArray( "info_target_clientside", "amb_corporate_emitter_SpectreConveyor" )
	Assert( level.assemblylineSoundEnts.len() > 0, "CORPORATE: No client sound entities found for assembly line" )

	level.spectreLoopingAnimDuration <- null
	level.assemblySpectres <- []
	SpectreAssemblyLineCreate( Vector( -2656, -2152, -752 ), Vector(-1632, -2152, -752) )
	SpectreAssemblyLineCreate( Vector( -1256, -1864, -752 ), Vector( -1256, 1576, -752 ) )
	SpectreAssemblyLineCreate( Vector( -904, 3608, -368 ), Vector( 3712, 3608, -368 ) )

	SpectreAssemblyLineStart()
	thread MuseumAnnouncer()
}

/*----------------------------------------------------------------------------------
/
/				SPECTRE ASSEMBLY LINE
/
/-----------------------------------------------------------------------------------*/
function SpectreAssemblyLineCreate( startPos, endPos )
{
	//DebugDrawLine( startPos, endPos, 255, 255, 0, true, 100 )

	local spectre
	local direction = endPos - startPos
	local spectrePos = startPos
	local spectreAng = VectorToAngles( direction )
	direction.Norm()
	local lineDistRemaining = Distance( startPos, endPos )
	//local tagOrg
	//local attach_id

	while( lineDistRemaining > SPECTRE_ASSEMBLY_ANIM_DELTA )
	{
		spectre = CreateClientSidePropDynamic( spectrePos + Vector( 0, 0, 0 ), spectreAng, NEUTRAL_SPECTRE_MODEL )
		spectre.s.isSpectre <- true
		if ( level.spectreLoopingAnimDuration == null )
			level.spectreLoopingAnimDuration = spectre.GetSequenceDuration( "sp_assembly_line" )
		//debug
//		spectreAssemblyCount++
//		printt( "CREATED SPECTRE NUMBER ", spectreAssemblyCount )
//		printt( "AT POS ", spectrePos + Vector( 0, 0, 0 ) )
//		printt( "AT ANGLES ", spectreAng )
//		printt( "******************************************************************" )
		//debug

		spectre.Anim_PlayWithRefPoint( "sp_assembly_line_idle", spectre.GetOrigin(), spectre.GetAngles(), 0 )

//		attach_id = spectre.LookupAttachment( "REF" )
//		tagOrg = spectre.GetAttachmentOrigin( attach_id )
//		printt( "startPos = ", startPos )
//		printt( "spectre pos = ", spectre.GetOrigin() )
//		printt( "tag ref pos = ", tagOrg )
		//DebugDrawLine( spectre.GetOrigin(), Vector( 0, 0, 0 ), 255, 0, 255, true, 100 )

		spectrePos += direction * SPECTRE_ASSEMBLY_ANIM_DELTA
		lineDistRemaining -= SPECTRE_ASSEMBLY_ANIM_DELTA
		level.assemblySpectres.append( spectre )
	}
}

//////////////////////////////////////////////////////////////////////////////////////
function SpectreAssemblyLineStart()
{

	//printl( "*********************CORPORATE: starting assembly line" )
	Assert( level.assemblySpectres.len() > 0, "Can't start the assembly line without any Spectres. Use SpectreAssemblyLineCreate" )
	local animTimerStarted = false

	foreach( spectre in level.assemblySpectres )
	{
		spectre.Anim_PlayWithRefPoint( "sp_assembly_line", spectre.GetOrigin() + Vector( 0, 0, SPECTRE_ASSEMBLY_ANIM_Z_OFFSET ), spectre.GetAngles(), 0 )
		spectre.s.animpos <- spectre.GetOrigin()
		if ( animTimerStarted == false )
		{
			animTimerStarted = true
			thread SpectreAssemblyLineNotifyWhenOkToStop()
		}
	}
	FlagSet( "AssemblyLineMoving" )

	thread SpectreAssemblyLineSoundsOn()
}
////////////////////////////////////////////////////////////////////////////////////////////////
function SpectreAssemblyLineSoundsOn()
{
	if ( Flag( "AssemblyLineSoundsPlaying" ) )
		return

	FlagSet( "AssemblyLineSoundsPlaying" )

	while ( Flag( "AssemblyLineSoundsPlaying" ) )
	{
		foreach( soundEnt in level.assemblylineSoundEnts )
			EmitSoundAtPosition( soundEnt.GetOrigin(), SFX_ASSEMBLY_LINE_MOVEMENT )
		wait level.spectreLoopingAnimDuration
	}
}

/////////////////////////////////////////////////////////////////////////////////////////
function SpectreAssemblyLineSoundsOff()
{
	FlagClear( "AssemblyLineSoundsPlaying" )
}

//////////////////////////////////////////////////////////////////////////////////////
function SpectreAssemblyLineStop()
{
	printl( "*********************CORPORATE: stopping assembly line" )

	level.ent.WaitSignal( "AssemblyAnimsAtEnd" )

	SpectreAssemblyLineSoundsOff()

	foreach( spectre in level.assemblySpectres )
		spectre.Anim_PlayWithRefPoint( "sp_assembly_line_idle", spectre.s.animpos, spectre.GetAngles(), 0 )

	FlagClear( "AssemblyLineMoving" )
}

//////////////////////////////////////////////////////////////////////////////////////
function SpectreAssemblyLineNotifyWhenOkToStop()
{
	//-------------------------
	// Need to know when anims are in a position to be paused
	//-------------------------
	while( true )
	{
		wait level.spectreLoopingAnimDuration
		level.ent.Signal( "AssemblyAnimsAtEnd" )
	}
}

//////////////////////////////////////////////////////////////////////////////////////
function AssemblyLineChange()
{
	//-------------------------
	// Server telling assembly line to stop
	//-------------------------
	if ( level.nv.assemblyLineStops == 1 )
		thread SpectreAssemblyLineStop()

	//-------------------------
	// Server telling assembly line to start
	//-------------------------
	else if ( level.nv.assemblyLineStops == 0 )
		thread SpectreAssemblyLineStart()
}

/*----------------------------------------------------------------------------------
/
/				GAME STATE
/
/-----------------------------------------------------------------------------------*/

//////////////////////////////////////////////////////////////////////////////////////
function ServerCallback_gameProgress( winningTeam, percentComplete )
{
	//--------------------------------------------------
	// Server telling us who is ahead at 25%, 50%, 75%, 100%
	//--------------------------------------------------
	local alias
	if ( winningTeam == TEAM_MILITIA )
	{
		switch ( percentComplete )
		{
			case 25:
				//Female Computer Voice	"Unauthorized access to A.I. mainframe at 25%. Local control over stored synthetic combat assets compromised. Shutting down production line (plays over PA system for both sides whenever 25% is reached and Militia is winning)"
				alias = "diag_hp_MatchProg_MIL25_CR110_01_01_ntrl_bgpa"
				break
			case 50:
				//Female Computer Voice	Unauthorized access to A.I. mainframe at 50%. Shutting down production line. (plays over PA system for both sides whenever 50% is reached and Militia is winning)
				alias = "diag_hp_MatchProg_MIL50_CR115_01_01_ntrl_bgpa"
				break
			case 75:
				//Female Computer Voice	Warning: 75% corruption reached. Shutting down production line. Complete security breach imminent. Unknown users attempting to activate all dormant synthetic combat troops. (plays over PA system for both sides whenever 75% is reached and Militia is winning)
				alias = "diag_hp_MatchProg_MIL75_CR121_01_01_ntrl_bgpa"
				break
			case 100:
				EpilogueStart( winningTeam )
				return
			default:
				Assert( 0, "CORPORATE: Invalid percentComplete: " + percentComplete )
		}
	}
	else if ( winningTeam == TEAM_IMC )
	{
		switch ( percentComplete )
		{
			case 25:
				//Female Computer Voice	Unauthorized access to A.I. mainframe reduced. Reinitialization at 25%. Production line resuming. (plays over PA system for both sides whenever 25% is reached and IMC is winning)
				alias = "diag_hp_MatchProg_IMC25_CR111_01_01_ntrl_bgpa"
				break
			case 50:
				//Female Computer Voice	Unauthorized access to A.I. mainframe reduced. Reinitialization at 50%. Production line resuming. (plays for both sides whenever 50% is reached and IMC is winning)
				alias = "diag_hp_MatchProg_IMC50_CR116_01_01_ntrl_bgpa"
				break
			case 75:
				//Female Computer Voice	Reinitialization at 75%. Removing unauthorized users from A.I. mainframe. Resuming production line (plays over PA system for both sides whenever 75% is reached and IMC is winning)
				alias = "diag_hp_MatchProg_IMC75_CR122_01_01_ntrl_bgpa"
				break
			case 100:
				EpilogueStart( winningTeam )
				return
			default:
				Assert( 0, "CORPORATE: Invalid percentComplete: " + percentComplete )
		}
	}
	else
		Assert( 0, "CORPORATE: Invalid winningTeam: " + winningTeam )

	//------------------------------------------------
	//Unless it's match over, play loudspeaker dialogue
	//------------------------------------------------

	local pos = GetBestLoudspeakerOrgForPlayer()
	EmitSoundAtPosition( pos, alias )
}



//////////////////////////////////////////////////////////////////////////////////////
function EpilogueStart( winningTeam )
{
	FlagSet( "epilogueStarted" )
	level.winners = winningTeam
	//---------------------------------------
	// Server telling us who is ahead at 100%
	//---------------------------------------
	if ( winningTeam == TEAM_MILITIA )
	{
		thread EpilogueWinnersMilitia()
	}
	else
	{
		thread EpilogueWinnersIMC()
	}
}
//////////////////////////////////////////////////////////////////////////////////////
function EpilogueWinnersIMC()
{
	delaythread ( 7.5 ) LoudspeakerEpilogue( TEAM_IMC )

	wait 12
	//---------------------------------------
	// Open assembly line tubes
	//---------------------------------------
	foreach ( ent in level.assemblyTubeEnts )
	{
		EmitSoundAtPosition( ent.s.intactModel.GetOrigin(), SFX_TUBE_GLASS_SHATTER )
		StartParticleEffectInWorld( GetParticleSystemIndex( FX_GLASS_EXPLOSION_ASSEMBLY_TUBE ), ent.s.intactModel.GetOrigin(), ent.s.intactModel.GetAngles() + Vector( 0, 0, 0 ) )
		ent.s.intactModel.SetModel( ent.s.brokenModelName )
	}

}
//////////////////////////////////////////////////////////////////////////////////////
function EpilogueWinnersMilitia()
{
	thread SpectreAssemblyLineStop()
	delaythread ( 15.5 ) FactoryBlowsUp()
	delaythread ( 9 ) LoudspeakerEpilogue( TEAM_MILITIA )
}


/*----------------------------------------------------------------------------------
/
/				FACTORY BLOWS UP IF MILITIA WINS
/
/-----------------------------------------------------------------------------------*/
//////////////////////////////////////////////////////////////////////////////////////
function FactoryBlowsUp()
{
	thread SpectreChainReaction()

	//wait 5

	foreach ( fxEnt in level.fxEnts )
		thread WaitToExplode( fxEnt )

	wait 5

	FlagSet( "FactoryBlowingUp" )

}

function SpectreChainReaction()
{
	//-----------------------------------------
	// Find out which end of the assembly line player is closest to
	//-----------------------------------------
	local spectre1 = level.assemblySpectres[ 0 ]
	local spectre2 = level.assemblySpectres[ level.assemblySpectres.len() - 1 ]


	//-----------------------------------------
	// Early out if kill replay deleted Spectres
	//-----------------------------------------
	printt( "CORPORATE: number of spectres in the assembly line tube: ", level.assemblySpectres.len() )
	printt( "CORPORATE: closest and furthest spectres in assembly line: ", spectre1, " and ", spectre2 )
	if ( !IsValid( spectre1 ) )
		return
	if ( !IsValid( spectre2 ) )
		return

	//-----------------------------------------
	// Blow up spectres in order, from closest to furthest
	//-----------------------------------------
	local player = GetLocalViewPlayer()
	local playerPos = player.GetOrigin()
	if ( ( DistanceSqr( spectre1.GetOrigin(), playerPos ) ) > ( DistanceSqr( spectre2.GetOrigin(), playerPos ) ) )
		level.assemblySpectres.reverse()

	foreach ( spectre in level.assemblySpectres )
	{
		thread SpectreExplodingDeath ( spectre )
		wait 0.25
	}
}


//////////////////////////////////////////////////////////////////////////////////////
function FxEndExplosionSetup( fxEnt )
{
	//-----------------------------------------
	// Fx entities for end destruct sequence
	//-----------------------------------------
	local fxName = fxEnt.GetName()
	local triggerDistSq
	local fxExplode
	local sfxExplode
	local fxFire
	local sfxFire

	local distClose = 2500 * 2500
	local distMed = 4000 * 4000
	local distFar = 8000 * 8000

	//-----------------------------------------
	// If it's an assembly line fx ent, spawn the glass tube
	//-----------------------------------------
	if ( fxName.find( "assembly_tube_int" ) != null )
	{
		fxEnt.s.triggerDistSq <- distMed
		fxEnt.s.fxExplode <- GetParticleSystemIndex( FX_EXP_ASSEMBLY_TUBE_INT )
		fxEnt.s.fxFire <- GetParticleSystemIndex( FX_FIRE_ASSEMBLY_TUBE_INT )
		fxEnt.s.sfxExplode <- SFX_EXP_LARGE
		fxEnt.s.sfxFire <- SFX_FIRE_LOOP_LARGE
		fxEnt.s.intactModel <- CreateClientSidePropDynamic( fxEnt.GetOrigin(), fxEnt.GetAngles() + Vector( 0, 90, 0 ), INTACT_MODEL_ASSEMBLY )
		//fxEnt.s.intactModel.NotSolid()
		fxEnt.s.brokenModelName <- BROKEN_MODEL_ASSEMBLY
		level.assemblyTubeEnts.append( fxEnt )
	}
	else if ( fxName.find( "assembly_tube_ext" ) != null )
	{
		fxEnt.s.triggerDistSq <- distMed
		fxEnt.s.fxExplode <- GetParticleSystemIndex( FX_EXP_ASSEMBLY_TUBE )
		fxEnt.s.fxFire <- GetParticleSystemIndex( FX_FIRE_ASSEMBLY_TUBE )
		fxEnt.s.sfxExplode <- SFX_EXP_LARGE
		fxEnt.s.sfxFire <- SFX_FIRE_LOOP_LARGE
		fxEnt.s.intactModel <- CreateClientSidePropDynamic( fxEnt.GetOrigin(), fxEnt.GetAngles() + Vector( 0, 90, 0 ), INTACT_MODEL_ASSEMBLY )
		//fxEnt.s.intactModel.NotSolid()
		fxEnt.s.brokenModelName <- BROKEN_MODEL_ASSEMBLY
		level.assemblyTubeEnts.append( fxEnt )
	}
	//-----------------------------------------
	// If it's a model swapper
	//-----------------------------------------
	else if ( fxName.find( "fx_explosion_modelswap_smallstorage_01" ) != null )
	{
		local buildingPosEnt = GetClientEnt( "info_target_clientside", "pos_breakable_smallstorage" )
		Assert( buildingPosEnt != null )
		fxEnt.s.triggerDistSq <- distMed
		fxEnt.s.fxExplode <- GetParticleSystemIndex( FX_EXP_UPPER_PARKING )
		fxEnt.s.fxFire <- GetParticleSystemIndex( FX_FIRE_UPPER_PARKING )
		fxEnt.s.sfxExplode <- SFX_EXP_LARGE
		fxEnt.s.sfxFire <- SFX_FIRE_LOOP_LARGE
		fxEnt.s.intactModel <- CreateClientSidePropDynamic( buildingPosEnt.GetOrigin(), buildingPosEnt.GetAngles(), INTACT_MODEL_SMALLSTORAGE_01 )
		fxEnt.s.brokenModelName <- BROKEN_MODEL_SMALLSTORAGE_01
	}
	else if ( fxName.find( "fx_explosion_modelswap_smallstorage_02" ) != null )
	{
		local buildingPosEnt = GetClientEnt( "info_target_clientside", "pos_breakable_smallstorage" )
		Assert( buildingPosEnt != null )
		fxEnt.s.triggerDistSq <- distMed
		fxEnt.s.fxExplode <- GetParticleSystemIndex( FX_EXP_UPPER_PARKING )
		fxEnt.s.fxFire <- GetParticleSystemIndex( FX_FIRE_UPPER_PARKING )
		fxEnt.s.sfxExplode <- SFX_EXP_LARGE
		fxEnt.s.sfxFire <- SFX_FIRE_LOOP_LARGE
		fxEnt.s.intactModel <- CreateClientSidePropDynamic( buildingPosEnt.GetOrigin(), buildingPosEnt.GetAngles(), INTACT_MODEL_SMALLSTORAGE_02 )
		fxEnt.s.brokenModelName <- BROKEN_MODEL_SMALLSTORAGE_02
	}
	else if ( fxName.find( "fx_explosion_modelswap_smallstorage_03" ) != null )
	{
		local buildingPosEnt = GetClientEnt( "info_target_clientside", "pos_breakable_smallstorage" )
		Assert( buildingPosEnt != null )
		fxEnt.s.triggerDistSq <- distMed
		fxEnt.s.fxExplode <- GetParticleSystemIndex( FX_EXP_UPPER_PARKING )
		fxEnt.s.fxFire <- GetParticleSystemIndex( FX_FIRE_UPPER_PARKING )
		fxEnt.s.sfxExplode <- SFX_EXP_LARGE
		fxEnt.s.sfxFire <- SFX_FIRE_LOOP_LARGE
		fxEnt.s.intactModel <- CreateClientSidePropDynamic( buildingPosEnt.GetOrigin(), buildingPosEnt.GetAngles(), INTACT_MODEL_SMALLSTORAGE_03 )
		fxEnt.s.brokenModelName <- BROKEN_MODEL_SMALLSTORAGE_03
	}
	else if ( fxName.find( "fx_explosion_modelswap_smallstorage_04" ) != null )
	{
		local buildingPosEnt = GetClientEnt( "info_target_clientside", "pos_breakable_smallstorage" )
		Assert( buildingPosEnt != null )
		fxEnt.s.triggerDistSq <- distMed
		fxEnt.s.fxExplode <- GetParticleSystemIndex( FX_EXP_UPPER_PARKING )
		fxEnt.s.fxFire <- GetParticleSystemIndex( FX_FIRE_UPPER_PARKING )
		fxEnt.s.sfxExplode <- SFX_EXP_LARGE
		fxEnt.s.sfxFire <- SFX_FIRE_LOOP_LARGE
		fxEnt.s.intactModel <- CreateClientSidePropDynamic( buildingPosEnt.GetOrigin(), buildingPosEnt.GetAngles(), INTACT_MODEL_SMALLSTORAGE_04 )
		fxEnt.s.brokenModelName <- BROKEN_MODEL_SMALLSTORAGE_04
	}
	else if ( fxName.find( "fx_explosion_modelswap_parking_01" ) != null )
	{
		local buildingPosEnt = GetClientEnt( "info_target_clientside", "pos_breakable_parking" )
		Assert( buildingPosEnt != null )
		fxEnt.s.triggerDistSq <- distMed
		fxEnt.s.fxExplode <- GetParticleSystemIndex( FX_EXP_UPPER_PARKING )
		fxEnt.s.fxFire <- GetParticleSystemIndex( FX_FIRE_UPPER_PARKING )
		fxEnt.s.sfxExplode <- SFX_EXP_LARGE
		fxEnt.s.sfxFire <- SFX_FIRE_LOOP_LARGE
		fxEnt.s.intactModel <- CreateClientSidePropDynamic( buildingPosEnt.GetOrigin(), buildingPosEnt.GetAngles(), INTACT_MODEL_PARKING_01 )
		fxEnt.s.brokenModelName <- BROKEN_MODEL_PARKING_01
	}
	else if ( fxName.find( "fx_explosion_modelswap_parking_02" ) != null )
	{
		local buildingPosEnt = GetClientEnt( "info_target_clientside", "pos_breakable_parking" )
		Assert( buildingPosEnt != null )
		fxEnt.s.triggerDistSq <- distMed
		fxEnt.s.fxExplode <- GetParticleSystemIndex( FX_EXP_UPPER_PARKING )
		fxEnt.s.fxFire <- GetParticleSystemIndex( FX_FIRE_UPPER_PARKING )
		fxEnt.s.sfxExplode <- SFX_EXP_LARGE
		fxEnt.s.sfxFire <- SFX_FIRE_LOOP_LARGE
		fxEnt.s.intactModel <- CreateClientSidePropDynamic( buildingPosEnt.GetOrigin(), buildingPosEnt.GetAngles(), INTACT_MODEL_PARKING_02 )
		fxEnt.s.brokenModelName <- BROKEN_MODEL_PARKING_02
	}
	else if ( fxName.find( "fx_explosion_modelswap_parking_03" ) != null )
	{
		local buildingPosEnt = GetClientEnt( "info_target_clientside", "pos_breakable_parking" )
		Assert( buildingPosEnt != null )
		fxEnt.s.triggerDistSq <- distMed
		fxEnt.s.fxExplode <- GetParticleSystemIndex( FX_EXP_UPPER_PARKING )
		fxEnt.s.fxFire <- GetParticleSystemIndex( FX_FIRE_UPPER_PARKING )
		fxEnt.s.sfxExplode <- SFX_EXP_LARGE
		fxEnt.s.sfxFire <- SFX_FIRE_LOOP_LARGE
		fxEnt.s.intactModel <- CreateClientSidePropDynamic( buildingPosEnt.GetOrigin(), buildingPosEnt.GetAngles(), INTACT_MODEL_PARKING_03 )
		fxEnt.s.brokenModelName <- BROKEN_MODEL_PARKING_03
	}
	else if ( fxName.find( "fx_explosion_modelswap_parking_04" ) != null )
	{
		local buildingPosEnt = GetClientEnt( "info_target_clientside", "pos_breakable_parking" )
		Assert( buildingPosEnt != null )
		fxEnt.s.triggerDistSq <- distMed
		fxEnt.s.fxExplode <- GetParticleSystemIndex( FX_EXP_UPPER_PARKING )
		fxEnt.s.fxFire <- GetParticleSystemIndex( FX_FIRE_UPPER_PARKING )
		fxEnt.s.sfxExplode <- SFX_EXP_LARGE
		fxEnt.s.sfxFire <- SFX_FIRE_LOOP_LARGE
		fxEnt.s.intactModel <- CreateClientSidePropDynamic( buildingPosEnt.GetOrigin(), buildingPosEnt.GetAngles(), INTACT_MODEL_PARKING_04 )
		fxEnt.s.brokenModelName <- BROKEN_MODEL_PARKING_04
	}
	//-----------------------------------------
	// All other fx entities get regular properties set up
	//-----------------------------------------
	else if ( fxName.find( "parking_roof" ) != null )
	{
		fxEnt.s.triggerDistSq <- distFar
		fxEnt.s.fxExplode <- GetParticleSystemIndex( FX_EXP_PARKING_ROOF )
		fxEnt.s.fxFire <- GetParticleSystemIndex( FX_FIRE_PARKING_ROOF )
		fxEnt.s.sfxExplode <- SFX_EXP_LARGE
		fxEnt.s.sfxFire <- SFX_FIRE_LOOP_LARGE
	}
	else if ( fxName.find( "upper_parking" ) != null )
	{
		fxEnt.s.triggerDistSq <- distMed
		fxEnt.s.fxExplode <- GetParticleSystemIndex( FX_EXP_UPPER_PARKING )
		fxEnt.s.fxFire <- GetParticleSystemIndex( FX_FIRE_UPPER_PARKING )
		fxEnt.s.sfxExplode <- SFX_EXP_LARGE
		fxEnt.s.sfxFire <- SFX_FIRE_LOOP_LARGE
	}
	else if ( fxName.find( "upper_bg_bldg" ) != null )
	{
		fxEnt.s.triggerDistSq <- distFar
		fxEnt.s.fxExplode <- GetParticleSystemIndex( FX_EXP_UPPER_BG_BLDG )
		fxEnt.s.fxFire <- GetParticleSystemIndex( FX_FIRE_UPPER_BG_BLDG )
		fxEnt.s.sfxExplode <- SFX_EXP_LARGE
		fxEnt.s.sfxFire <- SFX_FIRE_LOOP_LARGE
	}
	else if ( fxName.find( "bg_bldg_roof" ) != null )
	{
		fxEnt.s.triggerDistSq <- distFar
		fxEnt.s.fxExplode <- GetParticleSystemIndex( FX_EXP_BG_BLDG_ROOF )
		fxEnt.s.fxFire <- GetParticleSystemIndex( FX_FIRE_BG_BLDG_ROOF )
		fxEnt.s.sfxExplode <- SFX_EXP_LARGE
		fxEnt.s.sfxFire <- SFX_FIRE_LOOP_LARGE
	}
	else if ( fxName.find( "upper_skyscraper" ) != null )
	{
		fxEnt.s.triggerDistSq <- distFar
		fxEnt.s.fxExplode <- GetParticleSystemIndex( FX_EXP_UPPER_SKYSCRAPER )
		fxEnt.s.fxFire <- GetParticleSystemIndex( FX_FIRE_UPPER_SKYSCRAPER )
		fxEnt.s.sfxExplode <- SFX_EXP_LARGE
		fxEnt.s.sfxFire <- SFX_FIRE_LOOP_LARGE
	}
	else if ( fxName.find( "lower_skyscraper" ) != null )
	{
		fxEnt.s.triggerDistSq <- distFar
		fxEnt.s.fxExplode <- GetParticleSystemIndex( FX_EXP_LOWER_SKYSCRAPER )
		fxEnt.s.fxFire <- GetParticleSystemIndex( FX_FIRE_LOWER_SKYSCRAPER )
		fxEnt.s.sfxExplode <- SFX_EXP_LARGE
		fxEnt.s.sfxFire <- SFX_FIRE_LOOP_LARGE
	}
	else if ( fxName.find( "office_roof" ) != null )
	{
		fxEnt.s.triggerDistSq <- distFar
		fxEnt.s.fxExplode <- GetParticleSystemIndex( FX_EXP_OFFICE_ROOF )
		fxEnt.s.fxFire <- GetParticleSystemIndex( FX_FIRE_OFFICE_ROOF )
		fxEnt.s.sfxExplode <- SFX_EXP_LARGE
		fxEnt.s.sfxFire <- SFX_FIRE_LOOP_LARGE
	}
	else if ( fxName.find( "lab_roof" ) != null )
	{
		fxEnt.s.triggerDistSq <- distFar
		fxEnt.s.fxExplode <- GetParticleSystemIndex( FX_EXP_LAB_ROOF )
		fxEnt.s.fxFire <- GetParticleSystemIndex( FX_FIRE_LAB_ROOF )
		fxEnt.s.sfxExplode <- SFX_EXP_LARGE
		fxEnt.s.sfxFire <- SFX_FIRE_LOOP_LARGE
	}
	else if ( fxName.find( "vent_generic" ) != null )
	{
		fxEnt.s.triggerDistSq <- distMed
		fxEnt.s.fxExplode <- GetParticleSystemIndex( FX_EXP_VENT_GENERIC )
		fxEnt.s.fxFire <- GetParticleSystemIndex( FX_FIRE_VENT_GENERIC )
		fxEnt.s.sfxExplode <- SFX_EXP_SMALL
		fxEnt.s.sfxFire <- SFX_FIRE_LOOP_SMALL
	}
	else
		Assert( 0, "CORPORATE: No case for fx dummy: " + dummyName )

}
//////////////////////////////////////////////////////////////////////////////////////
function WaitToExplode( fxEnt )
{

	//-------------------------
	// Wait for player to get close
	//-------------------------
	local oneShotExplosion = false
	local player
	local distSq
	local fxEntPos = fxEnt.GetOrigin()
	local fxEntAng = fxEnt.GetAngles()
	local alreadyOnFire = false
	local explodeCount = 0

	if ( IsSpectreModel( fxEnt ) )
		oneShotExplosion = true

	//while( explodeCount < 3 )
	while( !Flag( "EndingScene" ) )
	{
		wait RandomFloat( 0.5, 1.5 )

		player = GetLocalViewPlayer()
		if ( !IsAlive( player ) )
			continue

		if ( ( IsSpectreModel( fxEnt ) ) && ( Time() - level.lastTimeSpectreExploded < SPECTRE_EXPLOSION_COOLDOWN ) )
			continue


		local distSq = DistanceSqr( fxEntPos, player.GetOrigin() )
		if ( distSq <fxEnt.s.triggerDistSq )
		{
			PlayExplosionAndFire( fxEnt, fxEntPos, fxEntAng, alreadyOnFire, explodeCount )
			if ( oneShotExplosion )
				break
			if ( !alreadyOnFire )
				EndExplosionModelSwap( fxEnt )
			alreadyOnFire = true
			explodeCount++
			wait RandomFloat( 6, 12 )
		}
	}
}

////////////////////////////////////////////////////////////////////////////////////////
function IsSpectreModel( ent )
{
	if ( "isSpectre" in ent.s )
		return true
	else
		return false
}

////////////////////////////////////////////////////////////////////////////////////////
function EndExplosionModelSwap( fxEnt )
{
	if ( !( "intactModel" in fxEnt.s ) )
		return
	fxEnt.s.intactModel.SetModel( fxEnt.s.brokenModelName )

}

/////////////////////////////////////////////////////////////////////////////////////////
function PlayExplosionAndFire( fxEnt, fxEntPos, fxEntAng, alreadyOnFire, explodeCount )
{
	local fxHandle
	local fxHandle2

	if ( IsSpectreModel( fxEnt ) )
	{
		SpectreExplodingDeath ( fxEnt )
		return
	}
	fxHandle = StartParticleEffectInWorldWithHandle( fxEnt.s.fxExplode, fxEntPos, fxEntAng )
	EffectSetDontKillForReplay( fxHandle )
	EmitSoundAtPosition( fxEntPos, fxEnt.s.sfxExplode )
	thread ScreenShake( fxEntPos )

	if ( !alreadyOnFire )
	{
		fxHandle2 = StartParticleEffectInWorldWithHandle( fxEnt.s.fxFire, fxEntPos, fxEntAng )
		EffectSetDontKillForReplay( fxHandle2 )
		EmitSoundAtPosition( fxEntPos, fxEnt.s.sfxFire )
	}
}

///////////////////////////////////////////////////////////////////////////////////////////
function SpectreExplodingDeath ( spectre )
{
	//level.lastTimeSpectreExploded = Time()
	local pos = spectre.GetOrigin()
	local ang = spectre.GetAngles()
	StartParticleEffectInWorld( GetParticleSystemIndex( FX_SPECTRE_EXPLOSION ), pos, ang )
	EmitSoundAtPosition( pos, SFX_SPECTRE_EXPLODE )
	spectre.Kill()
	thread ScreenShake( pos )
	//spectre.Die( level.worldspawn, level.worldspawn, { force = Vector( 0.4, 0.2, 0.3 ), scriptType = DF_SPECTRE_GIB, damageSourceId=eDamageSourceId.mp_titanweapon_40mm } )
}


///////////////////////////////////////////////////////////////////////////////////////
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
////////////////////////////////////////////////////////////////////////////////////////////////////
function LoudspeakerEpilogue( winners )
{
	local pos
	local announcements = []
	if ( winners == TEAM_MILITIA )
	{

		//Female Computer Voice	Command confirmed. All stored Spectre combat assets set to self destruct. Standby.
		announcements.append( "diag_hp_milWinAnnc_CR140_01_02_ntrl_bgpa" )

		//Female Computer Voice	Repeat. All stored Spectre combat assets set to self destruct. Approach with caution.
		announcements.append( "diag_hp_milWinAnnc_CR140_02_01_ntrl_bgpa" )

		//Female Computer Voice	Warning: all dormant Spectres executing self-destruct sequence. Evacuation recommended.
		announcements.append( "diag_hp_milWinAnnc_CR140_01_03_ntrl_bgpa" )
	}
	else
	{
		//Female Computer Voice	Command confirmed. All dormant combat Spectres activated in suicide mode.
		announcements.append( "diag_hp_milLoseAnnc_CR139_01_02_ntrl_bgpa" )

		//Female Computer Voice	All stored Spectre combat assets set to target hostile forces in suicide mode. Recommend maintaining 10 meter distance.
		announcements.append( "diag_hp_milLoseAnnc_CR139_01_03_ntrl_bgpa" )

		//Female Computer Voice	Repeat. All dormant combat Spectres activated in suicide mode against hostile personnel. Approach with caution.
		announcements.append( "diag_hp_milLoseAnnc_CR139_02_01_ntrl_bgpa" )

	}

	foreach( alias in announcements )
	{
		pos = GetBestLoudspeakerOrgForPlayer()
		EmitSoundAtPosition( pos, alias )
		wait 18
	}
}
////////////////////////////////////////////////////////////////////////////////////////////////////
function GetBestLoudspeakerOrgForPlayer()
{
	//-------------------------------------------------------------
	// Better to just play at a pos above player than use fixed locations
	//-------------------------------------------------------------
	local bestPos
	local player = GetLocalViewPlayer()

	if ( IsValid( player ) )
		bestPos = player.GetOrigin() + Vector( 0, 0, 512 )
	else
		bestPos = Vector( 1752, -1400, -184 )

	return bestPos
}

////////////////////////////////////////////////////////////////////////////////////////////////////
function PlayerInRange( pos, dist )
{
	local player = GetLocalViewPlayer()
	if ( !IsValid( player ) )
		return false

	local distSq = DistanceSqr( pos, player.GetOrigin() )
	dist = dist * dist
	if ( distSq < dist )
		return true
	else
		return false
}

////////////////////////////////////////////////////////////////////////////////////////////////////
function MuseumAnnouncer()
{
	//-------------------
	// PR Schpiel #1
	//-------------------
	local speechArray1 = []
	//What does the future hold? The Research and Development department at Hammond Robotics has the answer.
	MuseumAddLinesToSpeech( speechArray1, "diag_museumAnncClean_CR169_01_01_ntrl_museum1", "diag_brokenHammond_ntrl_museum1" )

	//Neural Actuation, Synthetic Biology and Advanced Cybernetics
	//are just a few of the exciting challenges on the horizon,
	//and the progress we've made might just surprise you!
	MuseumAddLinesToSpeech( speechArray1, "diag_museumAnncClean_CR169_02_01_ntrl_museum1", "diag_brokenHammond_ntrl_museum1" )

	//Meet our team of talented engineers and designers
	//on the Applied Robotics tour, leaving every hour at the front security desk.
	MuseumAddLinesToSpeech( speechArray1, "diag_museumAnncClean_CR169_03_01_ntrl_museum1", "diag_brokenHammond_ntrl_museum1" )

	//-------------------
	// PR Schpiel #2
	//-------------------
	local speechArray2 = []
	//Hammond Robotics: Keeping the frontier safe.
	//Advanced Titan chassis and synthetic combat troops are just the beginning!
	MuseumAddLinesToSpeech( speechArray2, "diag_museumAnncClean_CR170_01_01_ntrl_museum1", "diag_brokenHammond_ntrl_museum1" )

	//Mannex Defense Grids and Lockwood SE-Series peacekeepers
	//have served on the front lines in several recent, high-profile conflicts.
	MuseumAddLinesToSpeech( speechArray2, "diag_museumAnncClean_CR170_02_01_ntrl_museum1", "diag_brokenHammond_ntrl_museum1" )

	//At Hammond, we pride ourselves on collaborative innovation
	//with top military leaders as well as boots-on-the-ground combat personnel.
	MuseumAddLinesToSpeech( speechArray2, "diag_museumAnncClean_CR170_03_01_ntrl_museum1", "diag_brokenHammond_ntrl_museum1" )

	//This might be why Hammond has been the proud recipient of the
	//annual Haggerty Prize for Military Innovation 7 years in a row.
	MuseumAddLinesToSpeech( speechArray2, "diag_museumAnncClean_CR170_04_01_ntrl_museum1", "diag_brokenHammond_ntrl_museum1" )

	//-------------------
	// PR Schpiel #3
	//-------------------
	local speechArray3 = []
	//Witness the Evolution of a Revolution in these very display cases.
	//From early prototypes to the state-of-the-art, Hammond Robotics has been
	//pushing the envelope to make your world a better place.
	MuseumAddLinesToSpeech( speechArray3, "diag_museumAnncClean_CR171_01_01_ntrl_museum1", "diag_brokenHammond_ntrl_museum1" )

	//A world-class developer of industrial, personal and peacekeeping synthetic solutions
	//for over 4 decades, Hammond Industries has an install base of over 17.7 billion units.
	MuseumAddLinesToSpeech( speechArray3, "diag_museumAnncClean_CR171_02_01_ntrl_museum1", "diag_brokenHammond_ntrl_museum1" )

	//Take a tour through our proud history and see why Hammond Robotics has the right solution for your needs.
	MuseumAddLinesToSpeech( speechArray3, "diag_museumAnncClean_CR171_03_01_ntrl_museum1", "diag_brokenHammond_ntrl_museum1" )

	local DirtyLinePlayed = false
	local MuseumSpeeches = []
	MuseumSpeeches.append( speechArray1 )
	MuseumSpeeches.append( speechArray2 )
	MuseumSpeeches.append( speechArray3 )

	local randomInt
	local speechArray
	local alias
	local tempArray = []
	local duration
	local speechCount = 0

	ArrayRandomize( MuseumSpeeches )

	while( true )
	{
		Assert( MuseumSpeeches.len() == 3 )

		//-------------------
		// Pick a random speech
		//-------------------
		if ( speechCount == 3 )
			speechCount = 0
		speechArray = MuseumSpeeches[ speechCount ]
		speechCount++

		Assert( MuseumSpeeches.len() == 3 )
		//-------------------
		// Play speech when in range
		//-------------------
		waitthread WaitForPlayerInRange()

		foreach( table in speechArray )
		{
			if ( Flag( "FactoryBlowingUp" ) )
			{
				alias = table.dirtyLine
				EmitSoundAtPosition( level.soundPositionMuseum, alias )
				DirtyLinePlayed = true
				break
				//printt( "CORPORATE: Playing distorted museum dialogue" )
			}
			else
			{
				alias = table.cleanLine
				//printt( "CORPORATE: Playing normal museum dialogue" )
			}
			EmitSoundAtPosition( level.soundPositionMuseum, alias )
			duration = GetSoundDuration( alias )
			wait duration
		}

		if ( DirtyLinePlayed )
			break

		wait RandomFloat( 5, 10 )

	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
function WaitForPlayerInRange()
{
	while( true )
	{
		if ( PlayerInRange( level.soundPositionMuseum, MUSEUM_TRIGGER_RANGE ) )
		{
			//printt( "CORPORATE: Player in range to play museum dialogue" )
			break
		}
		else
		{
			//printt( "CORPORATE: Player out of range of museum" )
			wait RandomFloat( 1, 4 )
		}
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
function MuseumAddLinesToSpeech( speechArray, cleanLine, dirtyLine )
{
	local table = {}
	table.cleanLine <- cleanLine
	table.dirtyLine <- dirtyLine
	speechArray.append( table )
}


/*----------------------------------------------------------------------------------
/
/				ENDING
/
/-----------------------------------------------------------------------------------*/
function DoEnding()
{
	if ( level.nv.doEnding != 1 )
		return

	//fade to black and back out
	local holdTime = 5.0
	local fadeTime = 2.0
	thread ClientScreenFadeToBlack( fadeTime )
	delaythread( fadeTime + holdTime ) ClientScreenFadeFromBlack( 8.0, 0.0 )

	//change music
	thread DoEndingMusic( fadeTime )

	//wait for blackscreen
	FlagSet( "EndingScene" )
	wait fadeTime + 0.5 + 2.0

	//change skycam and settings
	GetLocalViewPlayer().ClientCommand( "SetEndingSkyCamOnServer" )

	SetMapSetting_BloomScale( 4.0 )
	SetMapSetting_FogEnabled( false )

	local clientPlayer = GetLocalClientPlayer()
	HideSpectatorSelectButtons( clientPlayer )

	//do the armada based on team
	local team = GetLocalViewPlayer().GetTeam()
	thread DoEndingArmada( team )
	thread DoEndingVO( team )
}

function DoEndingMusic( fadeTime )
{
	StopMusic( fadeTime )
	level.musicEnabled = false

	local player = GetLocalViewPlayer()
	local music = null
	if ( player.GetTeam() == TEAM_MILITIA )
		music = "Music_corporate_MCOR_Ending"
	else
		music = "Music_corporate_IMC_Ending"

	EmitSoundOnEntity( player, music )
}

function HideEndingArmada()
{
	level.endingArmadaData <- {}
	level.endingArmadaData[ TEAM_MILITIA ] <- []
	level.endingArmadaData[ TEAM_IMC ] <- []

	local armadaMCOR = GetClientEntArray( "prop_dynamic", "sunset_ending_ships_MCOR" )
	local armadaIMC = GetClientEntArray( "prop_dynamic", "sunset_ending_ships_IMC" )

	foreach ( ship in armadaMCOR )
		level.endingArmadaData[ TEAM_MILITIA ].append( GetEndingArmadaData( ship ) )
	foreach ( ship in armadaIMC )
		level.endingArmadaData[ TEAM_IMC ].append( GetEndingArmadaData( ship ) )

	foreach ( ship in armadaMCOR )
		ship.Kill()
	foreach ( ship in armadaIMC )
		ship.Kill()
}

function GetEndingArmadaData( ship )
{
	local data = {}
	data.origin 	<- ship.GetOrigin()
	data.angles 	<- ship.GetAngles()
	data.model 		<- ship.GetModelName()

	return data
}

function DoEndingArmada( team )
{
	local armada = []

	foreach ( data in level.endingArmadaData[ team ] )
	{
		local ship = CreateClientsideScriptMover( data.model, data.origin, data.angles )
		armada.append( ship )
	}

	CalcEndingArmada( armada )

	local time = 90
	foreach ( ship in armada )
		ship.NonPhysicsMoveTo( ship.s.movePos, time, 0, 0 )
}

function CalcEndingArmada( armada )
{
	foreach( ship in armada )
	{
		ship.s.moveAng <- ship.GetAngles()
		local name = ship.GetModelName().tolower()

		switch( name )
		{
			case FLEET_MCOR_ANNAPOLIS_1000X:
			case FLEET_CAPITAL_SHIP_ARGO_1000X:
				ship.s.movePos <- ( ship.GetOrigin() + ship.GetForwardVector() * 75 )
				break

			case FLEET_MCOR_BIRMINGHAM_1000X:
			case FLEET_MCOR_BIRMINGHAM_1000X_CLUSTERA:
				ship.s.movePos <- ( ship.GetOrigin() + ship.GetForwardVector() * 90 )
				break

			case FLEET_MCOR_REDEYE_1000X:
			case FLEET_MCOR_REDEYE_1000X_CLUSTERA:
			case FLEET_MCOR_REDEYE_1000X_CLUSTERB:
			case FLEET_MCOR_REDEYE_1000X_CLUSTERC:
			case FLEET_IMC_CARRIER_1000X:
			case FLEET_IMC_CARRIER_1000X_CLUSTERA:
			case FLEET_IMC_CARRIER_1000X_CLUSTERB:
			case FLEET_IMC_CARRIER_1000X_CLUSTERC:
				ship.s.movePos <- ( ship.GetOrigin() + ship.GetForwardVector() * 85 )
				break

			case FLEET_MCOR_CROW_1000X_CLUSTERA:
			case FLEET_MCOR_CROW_1000X_CLUSTERB:
			case FLEET_IMC_GOBLIN_1000X:
				ship.s.movePos <- ( ship.GetOrigin() + ship.GetForwardVector() * 100 )
				break

			default:
				Assert( 0, "didn't handle " + name )
				break
		}
	}
}

function DoEndingVO( team )
{
	if ( team == TEAM_MILITIA )
	{
		EmitSoundOnEntity( GetLocalViewPlayer(), "Corporate_Scr_Ending_Fleet_Militia_POV" )

		wait 3.5

		PlaySoundAndWait( "diag_endingStmt_macallan_01", 0.75 )		//This is james macallan, if you're hearing this, I'm already dead
		PlaySoundAndWait( "diag_endingStmt_macallan_02", 0.5 )		//The frontier is our land. And now the tide has turned
		PlaySoundAndWait( "diag_endingStmt_macallan_03", 0.25 )		//Each day more IMC garassons will fall to uprisings, their call to reinforcements, unanswered
		PlaySoundAndWait( "diag_endingStmt_macallan_04", 0.75 )		//And though the IMC will remain a force to be recond with, each day more and more will rally to our cause
		PlaySoundAndWait( "diag_endingStmt_macallan_07" )			//This is our land, and we will fight for it.
	}
	else
	{
		EmitSoundOnEntity( GetLocalViewPlayer(), "Corporate_Scr_Ending_Fleet_IMC_POV" )

		wait 3.0

		PlaySoundAndWait( "diag_endingStmt_spyglass_01", 0.5 )		//All IMC forces, this is your Vice admiral. Designation, SpyGlass
		PlaySoundAndWait( "diag_endingStmt_spyglass_02", 0.5 )		//The destruction of Demeter and the loss of many robotics factories has put us on a defensive footing
		PlaySoundAndWait( "diag_endingStmt_spyglass_03", 0.5 )		//Although reinforcements from the core system are unable to reach us, battle projections indicate we are still and effective fighting force
		PlaySoundAndWait( "diag_endingStmt_spyglass_04", 0.25 )		//Our garisons continue to maintain order on the frontier
		PlaySoundAndWait( "diag_endingStmt_spyglass_05", 0.5 )		//until we are relieved, we will remain vigilant
		PlaySoundAndWait( "diag_endingStmt_spyglass_06" )			//we will adapt, and we will prevail.
	}
}

function PlaySoundAndWait( alias, extraWait = 0 )
{
	local duration = EmitSoundOnEntity( GetLocalViewPlayer(), alias )
	wait duration + extraWait
}


function CE_VisualSettingCorporateIMC( player, ref )
{
	CE_ResetVisualSettings( player )

	ref.LerpSkyScale( SKYSCALE_CORPORATE_IMC_SHIP, 0.01 )
}

function CE_VisualSettingCorporateMCOR( player, ref )
{
	CE_ResetVisualSettings( player )

	ref.LerpSkyScale( SKYSCALE_CORPORATE_MCOR_SHIP, 0.01 )
}

function CE_BloomOnRampOpenCorporateIMC( player, ref )
{
	AddAnimEvent( ref, "cl_ramp_open", TonemappingOnDoorOpenCorporate, SKYSCALE_CORPORATE_DOOROPEN_IMC_SHIP )
}

function TonemappingOnDoorOpenCorporate( ref, scale )
{
	ref.LerpSkyScale( scale, 1.0 )
	thread CinematicTonemappingThread()
}