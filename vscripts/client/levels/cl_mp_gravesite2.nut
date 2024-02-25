RegisterSignal( "bird_burst_distant" )

function main()
{	
	
	PrecacheParticleSystem( "env_bird_burst_distant" )
	
}

function EntitiesDidLoad()
{
	thread BirdBurstDistant()
}

function BirdBurstDistant()
{	
	local fxID = GetParticleSystemIndex( "env_bird_burst_distant" )
	local bird_burst_distant_array = GetClientEntArray( "info_target", "target_birdburst" )

	foreach ( effect in bird_burst_distant_array )
	{
		thread PlayBirdBurstDistant( effect, fxID )
		//printt( "Found BirdBurst Positions" )	
	}
	
	for ( ;; )
	{
		level.ent.WaitSignal( "bird_burst_distant" )
	}
}

function PlayBirdBurstDistant( fxEnt, fxID )
{
	local origin = fxEnt.GetOrigin()
	local angles = fxEnt.GetAngles()
	
	while ( IsValid( fxEnt ) )
	{
		level.ent.WaitSignal( "bird_burst_distant" )
		//StartParticleEffectInWorld( fxID, origin, angles )

			//printt( "---------------" )
			//printt( "Q DA BIRDS" )
			//printt( "---------------" )

	}
}