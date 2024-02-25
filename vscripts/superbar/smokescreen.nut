PrecacheParticleSystem( FX_SMOKESCREEN_HUMAN_BURST )
PrecacheParticleSystem( FX_ELECTRIC_SMOKESCREEN )
PrecacheParticleSystem( FX_ELECTRIC_SMOKESCREEN_BURN )

if ( IsServer() )
{
	PrecacheSprite( "sprites/physbeam.vmt" )
	PrecacheSprite( "sprites/glow01.vmt" )
}


function main()
{
	Globalize( Smokescreen )
	Globalize( ElectricSmokescreen )
}


function ElectricSmokescreen( ent, lifetime, weapon )
{
	Smokescreen( ent, lifetime, weapon, true )
}


function Smokescreen( ent, lifetime, weapon, isElectric = false )
{
	//Assert( ent.IsPlayer(), "Smokescreens can only be called on a player.  Tried to call on entity: " + ent )
	Assert( ent.IsTitan() )

	local smokescreen = CreateEntity( "info_target" )
	smokescreen.SetName( UniqueString( "smokescreen_ent" ) )
	DispatchSpawn( smokescreen )

	smokescreen.s.team <- ent.GetTeam()
	smokescreen.s.isElectric <- isElectric
	smokescreen.s.traceBlockerVol <- null
	smokescreen.s.controlPointHelper <- null

	smokescreen.s.fxOffset <- SMOKESCREEN_FX_OFFSET_TITAN
	smokescreen.s.fxRadius <- smokescreen.s.fxOffset * 2
	
	smokescreen.s.lifetime <- lifetime

	Smokescreen_SetPosition( smokescreen, ent )

	CreateNoSpawnArea( smokescreen.s.team, smokescreen.GetOrigin(), smokescreen.s.lifetime, smokescreen.s.fxRadius )

	OnThreadEnd(
		function () : ( smokescreen )
		{
			if ( IsValid_ThisFrame( smokescreen.s.traceBlockerVol ) )
				smokescreen.s.traceBlockerVol.Kill()

			if ( IsValid( smokescreen.s.controlPointHelper ) )
				smokescreen.s.controlPointHelper.Kill()

			smokescreen.Kill()
		}
	)

	Smokescreen_CreateTraceBlockerVol( smokescreen )

	thread SmokescreenSFX( smokescreen, lifetime )
	thread SmokescreenFX( smokescreen, SMOKESCREEN_FX_OFFSET_TITAN, lifetime )
	thread SmokescreenAffectsEntitiesInArea( smokescreen, ent, weapon )

	// thread lives until cleanup time
	Wait( smokescreen.s.lifetime + 0.1 )
}


function Smokescreen_SetPosition( smokescreen, ent )
{
	local ang = ent.GetAngles()
	// flat boxes are fine, players never rotate horizontally
	local flatang = Vector( 0, ang.y, 0 )
	smokescreen.SetAngles( flatang )

	local baseorg = ent.GetOrigin() + Vector( 0, 0, 20 )

	// scoot it into view of the player when we set the origin
	local forward = flatang.AnglesToForward()
	local diameter = smokescreen.s.fxRadius
	local scoochFrac = 0.6  // percentage of the total diameter to move it forward
	local scoochDist = smokescreen.s.fxRadius * scoochFrac

	local neworg = baseorg + ( forward * scoochDist )
	local trace = TraceLineSimple( ent.EyePosition(), neworg, ent )
	if ( trace == 1 )
		smokescreen.SetOrigin( neworg )
	else
		smokescreen.SetOrigin( baseorg )
}


function SmokescreenSFX( smokescreen, lifetime )
{
	local smokescreenPos = smokescreen.GetOrigin()
	local deploySound
	if ( lifetime > ELECTRIC_SMOKESCREEN_FX_LIFETIME_TITAN )
		deploySound = SFX_SMOKE_DEPLOY_BURN
	else
		deploySound = SFX_SMOKE_DEPLOY
	
	EmitSoundAtPosition ( smokescreenPos, deploySound )
	EmitSoundAtPosition ( smokescreenPos, SFX_SMOKE_LOOP )

	smokescreen.WaitSignal( "OnDestroy" )

	StopSoundAtPosition( smokescreenPos, SFX_SMOKE_LOOP )
	EmitSoundAtPosition ( smokescreenPos, SFX_SMOKE_DISPERSE )
}


function SmokescreenAffectsEntitiesInArea( smokescreen, owner, weapon )
{
	local start = Time()
	local tickRate = 0.1

	smokescreen.EndSignal( "OnDestroy" )

	local smokeScreenDamage = CreateEntity( "env_explosion" )
	smokeScreenDamage.kv.spawnflags = (SF_ENVEXPLOSION_NOSOUND|SF_ENVEXPLOSION_NO_DAMAGEOWNER|SF_ENVEXPLOSION_NODECAL|SF_ENVEXPLOSION_REPEATABLE|SF_ENVEXPLOSION_NOFIREBALL|SF_ENVEXPLOSION_NOSMOKE|SF_ENVEXPLOSION_NOSPARKS|SF_ENVEXPLOSION_NOPARTICLES|SF_ENVEXPLOSION_NOFIREBALLSMOKE|SF_ENVEXPLOSION_NODLIGHTS|SF_ENVEXPLOSION_MASK_BRUSHONLY)
	smokeScreenDamage.kv.damageSourceId = eDamageSourceId.mp_titanability_smoke
	smokeScreenDamage.SetOrigin( smokescreen.GetOrigin() )
	smokeScreenDamage.kv.iMagnitude = ELECTRIC_SMOKESCREEN_DAMAGE_PER_SEC_HUMAN * tickRate
	smokeScreenDamage.kv.iMagnitudeHeavyArmor = ELECTRIC_SMOKESCREEN_DAMAGE_PER_SEC_TITAN * tickRate
	smokeScreenDamage.kv.iInnerRadius = SMOKESCREEN_DAMAGE_INNER_RADIUS
	smokeScreenDamage.kv.iRadiusOverride = SMOKESCREEN_DAMAGE_OUTER_RADIUS
	smokeScreenDamage.kv.scriptDamageType = DF_ELECTRICAL | DF_NO_HITBEEP

	smokeScreenDamage.SetOwner( owner )
	smokeScreenDamage.SetTeam( owner.GetTeam() )
	
	smokeScreenDamage.s.weaponMods <- weapon.GetMods()

	DispatchSpawn( smokeScreenDamage, false )

	wait 2.0

	while ( Time() - start <= smokescreen.s.lifetime )
	{
		smokeScreenDamage.Fire( "Explode" )
		wait tickRate
	}
}


function ElectricDamageColorCorrection( player )
{
	if ( IsClient() )
		return

	local colorCorrection = GetColorCorrectionByFileName( player, ELECTRIC_SMOKESCREEN_DAMAGE_COLORCORRECTION )

	if ( !colorCorrection )
		return null

	local fadeInDuration = 0.2
	local fadeOutDuration = 0.2
	local colorTime = 0.4
	local isMaster = 1

	colorCorrection.kv.fadeInDuration = fadeInDuration
	colorCorrection.kv.fadeOutDuration = fadeOutDuration
	colorCorrection.kv.spawnflags = isMaster

	colorCorrection.Fire( "Enable" )
	colorCorrection.Fire( "Disable", "", colorTime + fadeInDuration )
}


function Smokescreen_ShouldAffect( ent )
{
	// titan_driveables
	if ( ent.IsTitan() )
		return true

	if ( ent.IsHuman() )
		return true

	if ( ent.IsNPC() )
		return true

	return false
}


function Smokescreen_CreateTraceBlockerVol( smokescreen )
{
	local fxOffset = smokescreen.s.fxOffset

	local height = SMOKESCREEN_TRACEVOL_HEIGHT_TITAN

	// we can define the box corners as if we're starting at world default origin & angles,
	//  then pass that to SetBox, then use SetOrigin/Angles to place & rotate the box how we want
	local mins = Vector( ( 0 - fxOffset ), ( 0 - fxOffset ), 0 )
	local maxs = Vector( fxOffset, fxOffset, height )

	//printt( "traceblocker min/max: " + mins + ", " + maxs )

	local newVol = CreateEntity( "trace_volume" )
	newVol.SetName( UniqueString( "smokescreen_traceblocker_vol" ) )
	newVol.SetBox( mins, maxs )
	newVol.SetOrigin( smokescreen.GetOrigin() )
	newVol.SetAngles( smokescreen.GetAngles() )

	smokescreen.s.traceBlockerVol = newVol
	smokescreen.s.traceBlockerVol.Kill( smokescreen.s.lifetime )
}


function SmokescreenFX( smokescreen, fxOffset, lifetime )
{
	local facingDir = smokescreen.GetForwardVector()
	local rightDir = smokescreen.GetRightVector()

	local fxOrg = smokescreen.GetOrigin()
	local titanHeightOffset = Vector( 0, 0, 128 )

	local offsets = []

	// behind the player
	offsets.append( fxOrg - ( facingDir * fxOffset ) )

	// Titan extra points
	offsets.append( fxOrg + ( rightDir * fxOffset ) )
	offsets.append( fxOrg - ( rightDir * fxOffset ) )

	offsets.append( fxOrg + titanHeightOffset )

	// behind the player and up
	offsets.append( ( fxOrg - ( facingDir * fxOffset ) ) + titanHeightOffset )

	local controlPointHelper = CreateEntity( "info_placement_helper" )
	controlPointHelper.SetName( UniqueString( "smokescreen_controlpoint_helper" ) )
	// control points have to be ents and their origin vector's X value will be the controlling number
	local cpointVec = Vector( lifetime.tofloat(), 0, 0 )
	controlPointHelper.SetOrigin( cpointVec )
	DispatchSpawn( controlPointHelper, false )

	smokescreen.s.controlPointHelper = controlPointHelper
	
	local smokescreenFx
	if ( lifetime > ELECTRIC_SMOKESCREEN_FX_LIFETIME_TITAN )
		smokescreenFx = FX_ELECTRIC_SMOKESCREEN_BURN
	else
		smokescreenFx = FX_ELECTRIC_SMOKESCREEN

	// play FX for each spot
	foreach ( offset in offsets )
	{
		PlayFXWithControlPoint( smokescreenFx, offset, controlPointHelper )
	}
}
