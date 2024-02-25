
function main()
{
	Globalize( InitTitanDropPod )

	PrecacheEffect( "fire_jet_01_flame" )
}


function InitTitanDropPod( pod )
{
	pod.s.camera <- CreateDropPodViewController( pod )
	pod.s.fireTrail <- CreateDropPodFireTrail( pod )
	
	thread DropPodIdleThink( pod )
}



function DropPodIdleThink( pod )
{
	pod.EndSignal( "OnDestroy" )
	
	pod.WaitSignal( "OnLaunch" )
	pod.s.fireTrail.Fire( "Start" )
	
	pod.WaitSignal( "OnImpact" )
	pod.s.fireTrail.Fire( "Stop" )

	if ( IsValid( pod.s.owner ) && pod.s.owner.IsPlayer() )
		pod.s.owner.ClearSpawnPoint()

	thread CleanupPod( pod, 0.0 )
}


function CreateDropPodFireTrail( pod )
{
	local fireTrail = CreateEntity( "info_particle_system" )
	fireTrail.SetOrigin( pod.GetOrigin() + Vector( 0, 0, 152 ) )
	fireTrail.SetAngles( pod.GetAngles() + Vector( 90, 0, 0 ) )
	fireTrail.kv.effect_name = "fire_jet_01_flame"
	fireTrail.kv.start_active = 0
	DispatchSpawn( fireTrail, false )

	fireTrail.SetParent( pod )
	
	return fireTrail
}


function CleanupPod( pod, delay )
{	
	wait delay	
	pod.Dissolve( ENTITY_DISSOLVE_NORMAL, Vector( 0, 0, 0 ), 0 )
}
