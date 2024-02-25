
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

	self.FireWeaponGrenade( attackParams.pos, velocity, angularVelocity, fuseTime, scriptDamageType, PROJECTILE_PREDICTED, true, false )
}
