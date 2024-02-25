// This function is called by code every frame.
// It returns the new velocity of the projectile.
// timeElapsed is how long the projectile has lived, and timeStep is how long since the previous update.

/*
// moved to code
function GetProjectileVelocity( timeElapsed, timeStep )
{
	return ApplyMissileControlledDrift( self, timeElapsed, timeStep )
}
*/

function OnProjectileCollision( collisionParams )
{
	ClusterRocket_Detonate( self, collisionParams.normal )
	if( IsServer() )
		CreateNoSpawnArea( self.GetTeam(), collisionParams.pos, ( CLUSTER_ROCKET_BURST_COUNT / 5.0 ) * 0.5 + 1.0, CLUSTER_ROCKET_BURST_RANGE + 100 )
}
