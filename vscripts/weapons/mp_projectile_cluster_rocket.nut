function OnProjectileCollision( collisionParams )
{
	local duration
	if ( "burnMod" in self.s )
		duration = CLUSTER_ROCKET_DURATION_BURN
	else
		duration = CLUSTER_ROCKET_DURATION


	ClusterRocket_Detonate( self, collisionParams.normal )
	if( IsServer() )
		CreateNoSpawnArea( self.GetTeam(), collisionParams.pos, ( duration ) * 0.5 + 1.0, CLUSTER_ROCKET_BURST_RANGE + 100 )
}

/*
// moved to code
function GetProjectileVelocity( timeElapsed, timeStep )
{
	return ApplyMissileControlledDrift( self, timeElapsed, timeStep )
}
*/

