
/*
// moved to code
// This function is called by code every frame.
// It returns the new velocity of the projectile.
// timeElapsed is how long the projectile has lived, and timeStep is how long since the previous update.
function GetProjectileVelocity( timeElapsed, timeStep )
{
	if ( !( "flightData" in self.s ) )
		return ApplyMissileControlledDrift( self, timeElapsed, timeStep )
		//return self.ApplyMissileControlledDrift( timeElapsed, timeStep )

	if ( timeElapsed < self.s.flightData.launchOutTime )
	{
		// Should travel outward
		return self.s.flightData.launchOutVec * self.GetSpeed()
	}
	else if ( timeElapsed < self.s.flightData.launchOutTime + self.s.flightData.launchInLerpTime )
	{
		// Should be lerping to inward angle
		local startTime = self.s.flightData.launchOutTime
		local endTime = startTime + self.s.flightData.launchInLerpTime
		local x = GraphCapped( timeElapsed, startTime, endTime, self.s.flightData.launchOutVec.x, self.s.flightData.launchInVec.x )
		local y = GraphCapped( timeElapsed, startTime, endTime, self.s.flightData.launchOutVec.y, self.s.flightData.launchInVec.y )
		local z = GraphCapped( timeElapsed, startTime, endTime, self.s.flightData.launchOutVec.z, self.s.flightData.launchInVec.z )
		return Vector( x, y, z ) * self.GetSpeed()
	}
	else if ( timeElapsed < self.s.flightData.launchOutTime + self.s.flightData.launchInLerpTime + self.s.flightData.launchInTime )
	{
		// Should travel back inward
		return self.s.flightData.launchInVec * self.GetSpeed()
	}
	else if ( timeElapsed < self.s.flightData.launchOutTime + self.s.flightData.launchInLerpTime + self.s.flightData.launchInTime + self.s.flightData.launchStraightLerpTime )
	{
		// Should be lerping to target angle
		local startTime = self.s.flightData.launchOutTime + self.s.flightData.launchInLerpTime + self.s.flightData.launchInTime
		local endTime = startTime + self.s.flightData.launchStraightLerpTime
		local targetVec = self.s.flightData.endPos - self.GetOrigin()
		targetVec.Norm()
		local x = GraphCapped( timeElapsed, startTime, endTime, self.s.flightData.launchInVec.x, targetVec.x )
		local y = GraphCapped( timeElapsed, startTime, endTime, self.s.flightData.launchInVec.y, targetVec.y )
		local z = GraphCapped( timeElapsed, startTime, endTime, self.s.flightData.launchInVec.z, targetVec.z )
		return Vector( x, y, z ) * self.GetSpeed()
	}
	else if ( timeElapsed < self.s.flightData.launchOutTime + self.s.flightData.launchInLerpTime + self.s.flightData.launchInTime + self.s.flightData.launchStraightLerpTime + 0.25 )
	{
		// Should travel towards target
		local vec = self.s.flightData.endPos - self.GetOrigin()
		vec.Norm()
		return vec * self.GetSpeed()
	}
	else
	{
		// Toward target with randomness
		if ( self.s.flightData.applyRandSpread )
		{
			local elapsedTime = timeElapsed - self.s.flightData.launchOutTime - self.s.flightData.launchInLerpTime - self.s.flightData.launchInTime - self.s.flightData.launchStraightLerpTime - 0.25
			return ApplyMissileControlledDrift( self, elapsedTime, timeStep )
			//return self.ApplyMissileControlledDrift( elapsedTime, timeStep )
		}

		// Should travel towards target
		local vec = self.s.flightData.endPos - self.GetOrigin()
		vec.Norm()
		return vec * self.GetSpeed()
	}
}
*/