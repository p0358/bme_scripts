IncludeFileAllowMultipleLoads( "client/objects/cl_ai_turret" )


function main()
{
	level.musicEnabled = false
}

function EntitiesDidLoad()
{
	EmitSoundOnEntity( GetLocalClientPlayer(), "Music_Colony_MCOR_Opening" )
}