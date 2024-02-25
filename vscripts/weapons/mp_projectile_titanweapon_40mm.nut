function OnProjectileCollision( collisionParams )
{
	local hitEnt = collisionParams.hitent
	
	if( !IsValid( hitEnt ) || !( "planted" in self.s ) )
		return

	if ( !EntityCanHaveStickyEnts( hitEnt) )
	{		
		self.Explode( Vector(0,0,0) )
		return
	}

	if ( IsServer() )
	{		
		local bounceDot = 1.0	
		if ( PlantStickyEntity( self, collisionParams, bounceDot, null, true ) )
		{
			EmitSoundOnEntity( self, TANK_BUSTER_40MM_SFX_LOOP )
			self.Fire( "SetTimer", TANK_MISSILE_DELAY )
		}
	}
}