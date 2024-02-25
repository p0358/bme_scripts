
function main()
{

	ModelFX_BeginData( "friend_lights", "models/vehicle/crow_dropship/crow_dropship_hero.mdl", "friend", true )
		//----------------------
		// ACL Lights - Friend
		//----------------------
		ModelFX_AddTagSpawnFX( "light_Red0",		"acl_light_blue" )
		ModelFX_AddTagSpawnFX( "light_Red1",		"acl_light_blue" )
		ModelFX_AddTagSpawnFX( "light_Red2",		"acl_light_blue" )
		ModelFX_AddTagSpawnFX( "light_Red3",		"acl_light_blue" )
		ModelFX_AddTagSpawnFX( "light_Red4",		"acl_light_blue" )
		ModelFX_AddTagSpawnFX( "light_Red5",		"acl_light_blue" )
		ModelFX_AddTagSpawnFX( "light_Red6",		"acl_light_blue" )
		ModelFX_AddTagSpawnFX( "light_Green0",		"acl_light_blue" )
		ModelFX_AddTagSpawnFX( "light_Green1",		"acl_light_blue" )
		ModelFX_AddTagSpawnFX( "light_Green2",		"acl_light_blue" )
		ModelFX_AddTagSpawnFX( "light_Green3",		"acl_light_blue" )
		ModelFX_AddTagSpawnFX( "light_Green4",		"acl_light_blue" )
		ModelFX_AddTagSpawnFX( "light_Green5",		"acl_light_blue" )
		ModelFX_AddTagSpawnFX( "light_Green6",		"acl_light_blue" )
	ModelFX_EndData()


	ModelFX_BeginData( "foe_lights", "models/vehicle/crow_dropship/crow_dropship_hero.mdl", "foe", true )
		//----------------------
		// ACL Lights - Foe
		//----------------------
		ModelFX_AddTagSpawnFX( "light_Red0",		"acl_light_red" )
		ModelFX_AddTagSpawnFX( "light_Red1",		"acl_light_red" )
		ModelFX_AddTagSpawnFX( "light_Red2",		"acl_light_red" )
		ModelFX_AddTagSpawnFX( "light_Red3",		"acl_light_red" )
		ModelFX_AddTagSpawnFX( "light_Red4",		"acl_light_red" )
		ModelFX_AddTagSpawnFX( "light_Red5",		"acl_light_red" )
		ModelFX_AddTagSpawnFX( "light_Red6",		"acl_light_red" )
		ModelFX_AddTagSpawnFX( "light_Green0",		"acl_light_red" )
		ModelFX_AddTagSpawnFX( "light_Green1",		"acl_light_red" )
		ModelFX_AddTagSpawnFX( "light_Green2",		"acl_light_red" )
		ModelFX_AddTagSpawnFX( "light_Green3",		"acl_light_red" )
		ModelFX_AddTagSpawnFX( "light_Green4",		"acl_light_red" )
		ModelFX_AddTagSpawnFX( "light_Green5",		"acl_light_red" )
		ModelFX_AddTagSpawnFX( "light_Green6",		"acl_light_red" )
	ModelFX_EndData()

	ModelFX_BeginData( "interior_lights", "models/vehicle/crow_dropship/crow_dropship_hero.mdl", "friend", true )
		//----------------------
		// Interior Lights -
		//----------------------
		ModelFX_AddTagSpawnFX( "int_light_glow01",		"veh_int_light_red" )
		ModelFX_AddTagSpawnFX( "int_light_glow02",		"veh_int_light_red" )
		ModelFX_AddTagSpawnFX( "int_light_glow03",		"veh_int_light_red" )
		ModelFX_AddTagSpawnFX( "int_light_glow04",		"veh_int_light_red" )
		ModelFX_AddTagSpawnFX( "int_light_glow05",		"veh_int_light_red" )
		ModelFX_AddTagSpawnFX( "int_light_glow06",		"veh_int_light_red" )
		ModelFX_AddTagSpawnFX( "int_light_glow07",		"veh_int_light_red" )
		ModelFX_AddTagSpawnFX( "int_light_glow08",		"veh_int_light_red" )
		ModelFX_AddTagSpawnFX( "int_light_glow09",		"veh_int_light_red" )
		ModelFX_AddTagSpawnFX( "int_light_glow10",		"veh_int_light_red" )
	ModelFX_EndData()

/*
	ModelFX_BeginData( "cargo_lights", "models/vehicle/crow_dropship/crow_dropship_hero.mdl", "friend", true )
		//----------------------
		// Cargo Lights
		//----------------------
		ModelFX_AddTagSpawnFX( "HeadlightRight",	"acl_light_white" )
		ModelFX_AddTagSpawnFX( "HeadlightLeft",		"acl_light_white" )
		ModelFX_AddTagSpawnFX( "Spotlight",			"acl_light_white" )
	ModelFX_EndData()
*/

	ModelFX_BeginData( "thrusters", "models/vehicle/crow_dropship/crow_dropship_hero.mdl", "all", true )
		//----------------------
		// Thrusters
		//----------------------
		ModelFX_AddTagSpawnFX( "L_exhaust_rear_1", "veh_crow_jet1_full" )
		ModelFX_AddTagSpawnFX( "L_exhaust_rear_2", "veh_crow_jet2_full" )

		ModelFX_AddTagSpawnFX( "R_exhaust_rear_1", "veh_crow_jet1_full" )
		ModelFX_AddTagSpawnFX( "R_exhaust_rear_2", "veh_crow_jet2_full" )
	ModelFX_EndData()

	ModelFX_BeginData( "dropshipDamage", "models/vehicle/crow_dropship/crow_dropship_hero.mdl", "all", true )
		//----------------------
		// Health effects
		//----------------------
		ModelFX_AddTagHealthFX( 0.80, "L_exhaust_rear_1", "P_veh_crow_exp_sml", true )
		ModelFX_AddTagHealthFX( 0.80, "L_exhaust_rear_2", "xo_health_smoke_white", false )

		ModelFX_AddTagHealthFX( 0.60, "R_exhaust_rear_1", "P_veh_crow_exp_sml", true )
		ModelFX_AddTagHealthFX( 0.60, "R_exhaust_rear_2", "xo_health_smoke_white", false )

		ModelFX_AddTagHealthFX( 0.40, "L_exhaust_rear_1", "P_veh_crow_exp_sml", true )
		ModelFX_AddTagHealthFX( 0.40, "L_exhaust_rear_2", "veh_chunk_trail", false )

		ModelFX_AddTagHealthFX( 0.20, "R_exhaust_rear_1", "P_veh_crow_exp_sml", true )
		ModelFX_AddTagHealthFX( 0.20, "R_exhaust_rear_2", "veh_chunk_trail", false )
	ModelFX_EndData()
}