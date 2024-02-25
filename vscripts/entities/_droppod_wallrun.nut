
function main()
{
	RegisterSignal( "OnPlayerExit" )
	
	Globalize( InitWallrunDropPod )
}


function InitWallrunDropPod( pod, player )
{
	pod.SetModel( "models/vehicle/droppod_marvin/droppod_marvin.mdl" )	
	pod.s.camera <- CreateDropPodViewController( pod )
	
	thread DropPodIdleThink( pod, player )

	CreateDoors( pod )
}


function CreateDoors( ent )
{
	ent.s.phys <- []
	
	AttachDoor( ent, "DOOR_L_FRONT", 0 )
	AttachDoor( ent, "DOOR_L_REAR", 0 )
	AttachDoor( ent, "DOOR_R_REAR", 0 )
}


function AttachDoor( ent, attachment, fallTime )
{
	local prop_physics = CreateEntity( "prop_physics" )
	prop_physics.SetName( "door" + UniqueString() )
	prop_physics.kv.model = "models/vehicle/droppod_marvin/droppod_marvin_door.mdl"
	prop_physics.kv.spawnflags = 260 // added debris nocollide, 256 // generate output on +use
	prop_physics.kv.fadedist = -1
	prop_physics.kv.physdamagescale = 0.1
	prop_physics.kv.inertiaScale = 1.0
	prop_physics.kv.renderamt = 255
	prop_physics.kv.rendercolor = "255 255 255"
	prop_physics.SetParent( ent, attachment, false )
	DispatchSpawn( prop_physics, false )
	
	// cleanup
	prop_physics.Kill( RandomInt( 10, 20 ) )
	
	ent.s.phys.append( prop_physics.weakref() )
}


function DropPodIdleThink( pod, player )
{
	pod.EndSignal( "OnDestroy" )
	
	pod.WaitSignal( "OnLaunch" )
	
	thread WaitForPlayerExit( player, pod )	
	
	pod.WaitSignal( "OnImpact" )

	if ( IsValid( pod.s.owner ) && pod.s.owner.IsPlayer() )
		pod.s.owner.ClearSpawnPoint()

	EjectDoors( pod )

	pod.Signal( "OnPlayerExit", { impact = true } )

	thread CleanupPod( pod, 0.0 )
}


function CleanupPod( pod, delay )
{	
	wait delay	
	pod.Dissolve( ENTITY_DISSOLVE_CORE, Vector( 0, 0, 0 ), 0 )
}


function WaitForPlayerExit( player, pod )
{
	pod.EndSignal( "OnDestroy" )
	pod.EndSignal( "OnImpact" )

	wait 0.5

	WaitForever()
	
	EjectDoors( pod, true )
	
	pod.Signal( "OnPlayerExit", { impact = false } )	
}


function EjectDoors( pod, inFlight = false )
{
	foreach ( ent in pod.s.phys )
	{
		ent.ClearParent()
		ent.SetOwner( pod )
		
		local ejectAngles = (ent.GetOrigin() - pod.GetOrigin()).GetAngles()
		local force

		if ( inFlight )
		{
			ejectAngles.x = RandomFloat( 45, 75 )
			force = RandomFloat( 600, 1600 )
		}
		else
		{
			ejectAngles.x = RandomFloat( -5, -25 )
			force = RandomFloat( 200, 600 )
		}
		
		local vec = ejectAngles.AnglesToForward()
		ent.SetVelocity( vec * force )
		ent.SetAngularVelocity( RandomInt( 60, 70 ), RandomInt( -35, 35 ), RandomInt( 60, 70 ) )
		ent.Kill( 10 )
	}
	
	pod.s.phys = []
}

