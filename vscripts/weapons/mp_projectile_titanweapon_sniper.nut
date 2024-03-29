function OnProjectileCollision( hitParams )
{
	if ( IsClient() )
		return

	if ( !IsValid( hitParams.hitent ) )
		return

	if( hitParams.hitent == level.worldspawn )
		return

	if ( !( "bulletsToFire" in self.s ) )
		return

	if ( !( "extraDamagePerBullet" in self.s ) )
		return

	if ( !( "extraDamagePerBullet_Titan" in self.s ) )
		return

	local damagePerBullet = 0
	if ( hitParams.hitent.IsTitan() )
		damagePerBullet = self.s.extraDamagePerBullet_Titan
	else
		damagePerBullet = self.s.extraDamagePerBullet

	local extraDamage = ( self.s.bulletsToFire - 1 ) * damagePerBullet
	if ( extraDamage <= 0 )
		return

	hitParams.hitent.TakeDamage( extraDamage, self.GetOwner(), self, { scriptType = (DF_GIB | DF_BULLET | DF_ELECTRICAL), damageSourceId=eDamageSourceId.mp_titanweapon_sniper, hitbox = hitParams.hitbox } )
	//printt( "HIT WITH", self.s.bulletsToFire, "BULLETS FOR", extraDamage, "ADDITIONAL DAMAGE" )
}