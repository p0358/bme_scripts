// moved to code
/*
const MISSILE_ROTATE_RATE = 400 // degrees per second
const MISSILE_ROTATE_FIRST_RADIUS = 35
const MISSILE_ROTATE_FINAL_RADIUS = 15
const MISSILE_ROTATE_FIRST_RADIUS_TIME = 0.1
const MISSILE_ROTATE_FINAL_RADIUS_TIME = 4.0

// scripted_projectile_position weapon setting makes this function control the projectile.
function GetProjectilePosition( timeElapsed )
{
	if ( "spiralMissiles" in self.s )
	{
		timeElapsed *= self.s.timescale
	
		local radius
		local speed = self.s.missileSpeed
	
		local firstRadius = MISSILE_ROTATE_FIRST_RADIUS
		local finalRadius = MISSILE_ROTATE_FINAL_RADIUS
		if ( self.s.adsPressed == true )
		{
			if ( "afterburn" in self.s && self.s.afterburn == true )
			{
				speed *= 2.0
			}
			else
			{
				speed *= 0.3
				firstRadius = MISSILE_ROTATE_FINAL_RADIUS
				finalRadius = MISSILE_ROTATE_FIRST_RADIUS * 5.0
			}
		}
		local player = self.GetOwner()
	
		if ( timeElapsed < MISSILE_ROTATE_FIRST_RADIUS_TIME )
		{
			local frac = timeElapsed / MISSILE_ROTATE_FIRST_RADIUS_TIME
			frac = Smooth( frac )
			radius = frac * firstRadius
		}
		else if ( timeElapsed < MISSILE_ROTATE_FINAL_RADIUS_TIME )
		{
			local frac = (timeElapsed - MISSILE_ROTATE_FIRST_RADIUS_TIME) / (MISSILE_ROTATE_FINAL_RADIUS_TIME - MISSILE_ROTATE_FIRST_RADIUS_TIME)
			frac = Smooth( frac )
			radius = firstRadius + (finalRadius - firstRadius) * frac
		}
		else
		{
			radius = finalRadius
		}
	
		local angle = self.s.index * 90 + MISSILE_ROTATE_RATE * timeElapsed
		local angleRadians = angle * (PI / 180)
		local forward = self.s.startDir
	
		local pos = self.s.startPos + self.s.startDir * (timeElapsed * speed)
	
		pos += self.s.right * cos( angleRadians ) * radius
		pos += self.s.up    * sin( angleRadians ) * radius
	
		return pos
	}
	else
	{
		return self.s.startPos + self.s.startDir * ( timeElapsed * self.s.speed )			
	}
		
}

function Smooth( x )
{
	// smooths interpolation between 0 and 1
	return x * x * (3 - 2 * x)
}
*/


function OnProjectileCollision( collisionParams )
{
	if ( IsServer() )
	{
		if ( "initializedClusterExplosions" in self.s )
		{
			local owner = self.GetOwner()
			if ( IsValid( owner ) )
			{
				popcornInfo <- {}
				popcornInfo.weaponName <- "mp_titanweapon_rocket_launcher"
				popcornInfo.weaponMods <- self.GetMods()
				popcornInfo.damageSourceId <- eDamageSourceId.mp_titanweapon_rocket_launcher
				popcornInfo.count <- 2 //(groupSize is the minimum number of explosions )
				popcornInfo.delay <- 0.5
				popcornInfo.offset <- 0.3
				popcornInfo.range <- 250
				popcornInfo.normal <- collisionParams.normal
				popcornInfo.duration <- 1.0
				popcornInfo.groupSize <- 2 //Total explosions = groupSize * count
	
				thread StartClusterExplosions( self, owner, popcornInfo, CLUSTER_ROCKET_FX_TABLE )
			}
		}	
	}

	if( "spiralMissiles" in self.s )
	{
		local hitEnt = collisionParams.hitent
		if ( !IsAlive( hitEnt ) )
			return
		if ( !hitEnt.IsTitan() )
			return

		if ( Time() - self.s.launchTime < 0.02 )
			return
	
		foreach ( missile in self.s.spiralMissiles )
		{
			if ( !IsValid( missile ) )
				continue
	
			if ( missile == self )
				continue
	
			missile.s.spiralMissiles = []
			missile.Explode()
		}
	}
}