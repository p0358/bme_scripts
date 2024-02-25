
targetingGrenadeExplodeCorrection <- "materials/correction/bw_super_constrast.raw"

//
// Weapon Sounds
//
weaponSounds <- {}


//
// Weapon Effects
//
weaponEffects <- {}

foreach( key, value in weaponEffects )
	PrecacheParticleSystem( value )


function OnWeaponPrimaryAttackAnimEvent( attackParams )
{
	if ( !IsServer() && !self.ShouldPredictProjectiles() )
		return

	local velocity = (attackParams.dir + Vector( 0, 0, 0.1 )) * 16200
	local angularVelocity = Vector( 3600, RandomFloat( -1200, 1200 ), 0 )
	local fuseTime = 2.5
	local scriptDamageType = 0

	local nade = self.FireWeaponGrenade( attackParams.pos, velocity, angularVelocity, fuseTime, scriptDamageType, PROJECTILE_PREDICTED, true, false )
	if ( nade )
	{
		if ( IsServer() )
			thread GrenadeThrown( nade )
	}
}

function GrenadeThrown( grenade )
{
	grenade.EndSignal( "OnDeath" )

	//thread GrenadeInventoryThink( grenade )

	local fuseTime = 2
	grenade.Fire( "SetTimer", fuseTime + 10 )
	delaythread( fuseTime ) GrenadeTargeting( grenade )

	/*
	while ( IsAlive( grenade ) )
	{
		grenade.Fire( "SetTimer", 100 )
		wait( 99 )
	}
	*/
}

function GrenadeTargeting( grenade )
{
	if ( IsServer() )
	{
		GrenadeFlash( grenade )

		player = grenade.GetOwner()
		if ( !IsAlive( player ) )
			return

		if ( VectorDot_EntToEnt( player, grenade ) > 0.7 )
			DoColorCorrection( player, targetingGrenadeExplodeCorrection, 0, 0, 0.5 )

		local range = 768
		local duration = 5.0
		local targets = GetSmartPistolTargets()

		foreach( target in targets )
		{
			if ( IsValid_ThisFrame( target ) )
				thread SmartAmmo_EnableInstantLock( player, target, duration )
		}

		GrenadeKill( grenade )
	}
}

function GrenadeFlash( grenade )
{
	local env_explosion = CreateEntity( "env_explosion" )
	env_explosion.kv.spawnflags = 1  // No Damage
	env_explosion.SetName( "flash_explosion_" + UniqueString() )
	env_explosion.SetOrigin( grenade.GetOrigin() )
	env_explosion.kv.iMagnitude = 0
	env_explosion.kv.fireballsprite = "sprites/zerogxplode.spr"
	env_explosion.kv.rendermode = 5
	env_explosion.SetOwner( grenade )
	DispatchSpawn( env_explosion, false )

	env_explosion.Fire( "Explode" )
	env_explosion.Kill( 5 )
}

function GrenadeKill( grenade )
{
	grenade.Kill()
}

/*
function GrenadeInventoryThink( grenade )
{
	local owner = grenade.GetOwner()

	if ( !( "activeGrenades" in owner.s ) )
		owner.s.activeGrenades <- []

	Assert( "activeGrenades" in owner.s )
	Assert( !ArrayContains( owner.s.activeGrenades, grenade ), "Tried to add a grenade twice to the owner's activeGrenades array: " + owner )
	owner.s.activeGrenades.append( grenade )

	printl( owner.GetName() + " has " + owner.s.activeGrenades.len() + " grenades active." )

	thread GrenadeDeathWait( grenade )
}

function GrenadeDeathWait( grenade )
{
	local owner = grenade.GetOwner()
	local gname = grenade.GetName()

	while ( IsAlive( grenade ) )
		wait 0

	printl( "hello! I am dead" )
	ArrayRemove( owner.s.activeGrenades, grenade )
	printl( owner.GetName() + " has " + owner.s.activeGrenades.len() + " grenades active." )
}
*/
