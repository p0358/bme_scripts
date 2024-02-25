function OnProjectileCollision( collisionParams )
{
	local hitEnt = collisionParams.hitent
	if ( !IsValid( hitEnt ) )
		return

	if ( IsMagneticTarget( hitEnt ) )
	{
		if ( hitEnt.GetTeam() != self.GetTeam() )
		{
			self.ExplodeForCollisionCallback( collisionParams.normal )
		}
	}
}