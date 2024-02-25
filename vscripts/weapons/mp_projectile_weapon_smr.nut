
/*
function GetProjectileVelocity( timeElapsed, timeStep )
{
	return ApplyMissileControlledDrift( self, timeElapsed, timeStep )
}
*/

function OnProjectileCollision( collisionParams )
{
	local plantedMissile = false
	if ( IsClient() )
		return

	if ( !( "weaponRef" in self.s ) || !IsValid( self.s.weaponRef ) )
		return

	local weapon = self.s.weaponRef

	if ( !( weapon.HasMod("tank_buster" ) ) )
		return

	if ( !IsValid( weapon.GetWeaponOwner() ) )
		return

	if ( !EntityCanHaveStickyEnts( collisionParams.hitent ) )
		return

	local nade = self.s.weaponRef.FireWeaponGrenade( collisionParams.pos, Vector( 0, 180, 0 ), Vector( 0, 0, 0 ), TANK_MISSILE_DELAY, damageTypes.LargeCaliberExp, damageTypes.LargeCaliberExp, PROJECTILE_NOT_PREDICTED, true, true )
	if ( nade )
	{
		nade.ForceAdjustToGunBarrelDisabled( true )
		if ( EntityShouldStick( nade, collisionParams.hitent ) )
		{
			nade.s.planted <- false
			nade.s.preventOwnerDamage <- true
			local bounceDot = 1.0
			if ( PlantStickyEntity( nade, collisionParams, bounceDot ) )
			{
				EmitSoundOnEntity( self, "Weapon_Vortex_Gun.ExplosiveWarningBeep" )
				plantedMissile = true
			}
	  	}
	}

	if ( plantedMissile )
		return false
	else
		return true
}