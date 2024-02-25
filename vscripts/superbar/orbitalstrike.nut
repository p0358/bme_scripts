const STRIKE_MODEL = "models/containers/can_red_soda.mdl"
const ROCKET_START_HEIGHT = 2000
const LASER_START_HEIGHT = 1000 // TODO: Make this taller after making the trace go through sky
const LASER_TIME_LENGTH = 7 // Must match charge length in the weapon
const LASER_DAMAGE = 300
const LASER_DAMAGE_RADIUS = 300

const SPAWN_DELAY = 0.2

function main()
{
	PrecacheParticleSystem( "ar_rocket_strike_small_friend" )
	PrecacheParticleSystem( "ar_rocket_strike_small_foe" )
	PrecacheParticleSystem( "ar_rocket_strike_large_friend" )
	PrecacheParticleSystem( "ar_rocket_strike_large_foe" )
	PrecacheParticleSystem( "wpn_orbital_beam" )

	PrecacheWeapon( "mp_projectile_orbital_strike" )

	if ( IsServer() )
		file.impactEffectTable <- PrecacheImpactEffectTable( GetWeaponInfoFileKeyField_Global( "mp_projectile_orbital_strike", "impact_effect_table" ) )

	Globalize( OrbitalStrike )
	Globalize( CalculateStrikeDelay )

	RegisterSignal( "TargetDesignated" )
	RegisterSignal( "BeginLaser" )
	RegisterSignal( "MoveLaser" )
	RegisterSignal( "FreezeLaser" )
	RegisterSignal( "EndLaser" )
}


function CalculateStrikeDelay( index, stepCount, duration )
{
	local lastStepDelay = 0
	if ( index )
	{
		local stepFrac = (index - 1) / stepCount.tofloat()
		stepFrac = 1 - (1 - stepFrac) * (1 - stepFrac)
		lastStepDelay = stepFrac * (duration)
	}

	local stepFrac = index / stepCount.tofloat()
	stepFrac = 1 - (1 - stepFrac) * (1 - stepFrac)
	return (stepFrac * (duration)) - lastStepDelay
}


function OrbitalStrike( player, targetEnt, numRockets = 12, radius = 256, totalTime = 3, extraStartDelay = null )
{
	local team = player.GetTeam()

	local targetPos = targetEnt.GetOrigin()

	CreateNoSpawnArea( team, targetPos, totalTime, radius )

	if ( extraStartDelay != null )
		wait extraStartDelay

	if ( IsValid( targetEnt ) )
		targetPos = targetEnt.GetOrigin()

	// Trace down from max z height until we hit something
	// Trace through the sky brush if we hit one until we hit something again
	// Trace up from here to the desired rocket spawn height or until we hit something
	local downStartPos = Vector( targetPos.x, targetPos.y, 16384 )
	local downResult = TraceLine( downStartPos, targetPos, null, (TRACE_MASK_NPCSOLID_BRUSHONLY|TRACE_MASK_WATER), TRACE_COLLISION_GROUP_NONE )

	if ( downResult.hitSky ) // retrace because we hit a sky brush from outside the level, not the ground
	{
		downStartPos = downResult.endPos
		downStartPos.z -= 1
		downResult = TraceLine( downStartPos, targetPos, null, (TRACE_MASK_NPCSOLID_BRUSHONLY|TRACE_MASK_WATER), TRACE_COLLISION_GROUP_NONE )
	}
	//DebugDrawLine( downStartPos, downResult.endPos, 150, 150, 150, true, 5000.0 )

	local upEndPos = targetPos + Vector( 0, 0, ROCKET_START_HEIGHT )
	local upResult = TraceLine( downResult.endPos, upEndPos, null, (TRACE_MASK_NPCSOLID_BRUSHONLY|TRACE_MASK_WATER), TRACE_COLLISION_GROUP_NONE )
	local spawnPos = upResult.endPos

	local rocketPos
	local min = radius * -1
	local max = radius
	local rocket

	SpawnRocket( spawnPos, Vector( 90, 0, 0 ), player, team ) // First rocket hits center target

	for ( local i = 1; i < numRockets; i++  )
	{
		wait CalculateStrikeDelay( i, numRockets, totalTime )

		if ( IsValid( targetEnt ) )
			targetPos = targetEnt.GetOrigin()

		rocketPos = Vector( spawnPos.x, spawnPos.y, spawnPos.z )
		rocketPos.x += RandomFloat( min, max )
		rocketPos.y += RandomFloat( min, max )

		while ( Distance( spawnPos, rocketPos) > radius ) // Probably a better way, but rejection sampling for now
		{
			rocketPos = Vector( spawnPos.x, spawnPos.y, spawnPos.z )
			rocketPos.x += RandomFloat( min, max )
			rocketPos.y += RandomFloat( min, max )
		}

		rocket = SpawnRocket( rocketPos, Vector( 90, 0, 0 ), player, team )
	}
}


function SpawnRocket( spawnPos, spawnAng, owner, team )
{
	local rocket = CreateEntity( "rpg_missile" )
	rocket.SetOrigin( spawnPos )
	rocket.SetAngles( spawnAng )
	rocket.SetOwner( owner )
	rocket.SetTeam( team )
	rocket.SetModel( "models/weapons/bullets/projectile_rocket.mdl" )
	rocket.SetImpactEffectTable( file.impactEffectTable )
	rocket.SetWeaponClassName( "mp_projectile_orbital_strike" )
	rocket.kv.damageSourceId = eDamageSourceId.mp_titanweapon_orbital_strike
	DispatchSpawn( rocket )

	return rocket
}
