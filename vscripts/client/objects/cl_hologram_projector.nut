//cl_hologram_projector

function main()
{
	BeginModelFXData( "hologram_spidertank", "models/holo_screens/holo_projector_imc_open.mdl" )



	if ( 1 )
	{
		AddTagSpawnFX( "emitter_main",		"holocase_spiderturret_friend" )
	}
	else
	{
		AddTagSpawnFX( "emitter_main",		"holocase_spiderturret_foe" )
	}

	//AddTagSpawnLoopFX( "emitter_main", "test_angles", 0.25, 0.25 )

	EndModelFXData()


}