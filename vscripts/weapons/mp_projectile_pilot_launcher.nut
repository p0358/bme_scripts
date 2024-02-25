//const HARDCODED_DROP_TIME = 0.3

// This function is called by code every frame.
// It returns the new velocity of the projectile.
// timeElapsed is how long the projectile has lived, and timeStep is how long since the previous update.

/*
// moved to code
function GetProjectileVelocity( timeElapsed, timeStep )
{
	return ApplyMissileControlledDrift( self, timeElapsed, timeStep )
}

function ApplyMissileControlledDrift( missile, timeElapsed, timeStep )
{
	// If we have a target, don't do anything fancy; just let code do the homing behavior
	if ( missile.GetTarget() )
		return missile.GetVelocity()

	local s = missile.s
	return MissileControlledDrift( timeElapsed, timeStep, s.drift_windiness, s.drift_intensity, s.straight_time_min, s.straight_time_max, s.straight_radius_min, s.straight_radius_max )
}
*/

/*
function GuidedMissileVelocity( missile, timeElapsed, timeStep )
{
	local player = missile.GetOwner()
	local missileSpeed = 1200
	local oldMissileVelocity = missile.GetVelocity()
	if ( IsValid( player ) && player.s.guidedLaserPoint != null )
	{
		local vec = player.s.guidedLaserPoint - missile.GetOrigin()
		local angles = VectorToAngles( vec )
		angles = angles.AnglesLerp( missile.GetAngles(), 0.4 )
		missile.SetAngles( angles )
		local forward = angles.AnglesToForward()
		return forward * missileSpeed
	}
	else
	{
		return oldMissileVelocity
	}
}
*/