
function main()
{
	ModelFX_BeginData( "friend_lights", "models/vehicle/goblin_dropship/goblin_dropship.mdl", "friend", true )
		//----------------------
		// ACL Lights - Friend
		//----------------------
		ModelFX_AddTagSpawnFX( "light_Red0",		"acl_light_blue" )
		ModelFX_AddTagSpawnFX( "light_Red1",		"acl_light_blue" )
		ModelFX_AddTagSpawnFX( "light_Red2",		"acl_light_blue" )
		ModelFX_AddTagSpawnFX( "light_Red3",		"acl_light_blue" )
		ModelFX_AddTagSpawnFX( "light_Green0",		"acl_light_blue" )
		ModelFX_AddTagSpawnFX( "light_Green1",		"acl_light_blue" )
		ModelFX_AddTagSpawnFX( "light_Green2",		"acl_light_blue" )
		ModelFX_AddTagSpawnFX( "light_Green3",		"acl_light_blue" )
	ModelFX_EndData()

	ModelFX_BeginData( "foe_lights", "models/vehicle/goblin_dropship/goblin_dropship.mdl", "foe", true )
		//----------------------
		// ACL Lights - Foe
		//----------------------
		ModelFX_AddTagSpawnFX( "light_Red0",		"acl_light_red" )
		ModelFX_AddTagSpawnFX( "light_Red1",		"acl_light_red" )
		ModelFX_AddTagSpawnFX( "light_Red2",		"acl_light_red" )
		ModelFX_AddTagSpawnFX( "light_Red3",		"acl_light_red" )
		ModelFX_AddTagSpawnFX( "light_Green0",		"acl_light_red" )
		ModelFX_AddTagSpawnFX( "light_Green1",		"acl_light_red" )
		ModelFX_AddTagSpawnFX( "light_Green2",		"acl_light_red" )
		ModelFX_AddTagSpawnFX( "light_Green3",		"acl_light_red" )
	ModelFX_EndData()

	/*
	ModelFX_BeginData( "cargo_lights", "models/vehicle/goblin_dropship/goblin_dropship.mdl", "all", true )
		//----------------------
		// Cargo Lights
		//----------------------
		ModelFX_AddTagSpawnFX( "HeadlightRight",	"acl_light_white" )
		ModelFX_AddTagSpawnFX( "HeadlightLeft",		"acl_light_white" )
		ModelFX_AddTagSpawnFX( "Spotlight",			"acl_light_white" )
	ModelFX_EndData()
	*/

	ModelFX_BeginData( "thrusters", "models/vehicle/goblin_dropship/goblin_dropship.mdl", "all", true )
		//----------------------
		// Thrusters
		//----------------------
		ModelFX_AddTagSpawnFX( "L_exhaust_rear_1", "veh_gunship_jet_full" )
		ModelFX_AddTagSpawnFX( "L_exhaust_rear_2", "veh_gunship_jet_full" )
		ModelFX_AddTagSpawnFX( "L_exhaust_front_1", "veh_gunship_jet_full" )

		ModelFX_AddTagSpawnFX( "R_exhaust_rear_1", "veh_gunship_jet_full" )
		ModelFX_AddTagSpawnFX( "R_exhaust_rear_2", "veh_gunship_jet_full" )
		ModelFX_AddTagSpawnFX( "R_exhaust_front_1", "veh_gunship_jet_full" )
	ModelFX_EndData()

	ModelFX_BeginData( "dropshipDamage", "models/vehicle/goblin_dropship/goblin_dropship.mdl", "all", true )
		//----------------------
		// Health effects
		//----------------------
		ModelFX_AddTagHealthFX( 0.80, "L_exhaust_rear_1", "xo_health_smoke_white", false )
		ModelFX_AddTagHealthFX( 0.60, "R_exhaust_rear_2", "xo_health_smoke_white", false )
		ModelFX_AddTagHealthFX( 0.40, "L_exhaust_rear_1", "xo_health_smoke_black", false )
		ModelFX_AddTagHealthFX( 0.20, "R_exhaust_rear_2", "xo_health_smoke_black", false )
	ModelFX_EndData()

	ModelFX_BeginData( "dropshipCrash", "models/vehicle/goblin_dropship/goblin_dropship_dest_center.mdl", "all", true )
		//----------------------
		// Trailing smoke and fire
		//----------------------
		ModelFX_AddTagSpawnFX( "tag1", "veh_fire_trail_large" )
		ModelFX_AddTagSpawnFX( "tag2", "veh_fire_trail_large" )
		ModelFX_AddTagSpawnFX( "tag3", "veh_fire_trail_large" )
		ModelFX_AddTagSpawnFX( "tag4", "veh_fire_trail_large" )
	ModelFX_EndData()

	ModelFX_BeginData( "dropshipCrash", "models/vehicle/goblin_dropship/goblin_dropship_dest_wing_l.mdl", "all", true )
		//----------------------
		// Trailing smoke and fire
		//----------------------
		ModelFX_AddTagSpawnFX( "tag1", "veh_fire_trail_large" )
		ModelFX_AddTagSpawnFX( "tag2", "veh_fire_trail_large" )
		ModelFX_AddTagSpawnFX( "tag3", "veh_fire_trail_large" )
	ModelFX_EndData()

	ModelFX_BeginData( "dropshipCrash", "models/vehicle/goblin_dropship/goblin_dropship_dest_wing_r.mdl", "all", true )
		//----------------------
		// Trailing smoke and fire
		//----------------------
		ModelFX_AddTagSpawnFX( "tag1", "veh_fire_trail_large" )
		ModelFX_AddTagSpawnFX( "tag2", "veh_fire_trail_large" )
		ModelFX_AddTagSpawnFX( "tag3", "veh_fire_trail_large" )
		ModelFX_AddTagSpawnFX( "tag4", "veh_fire_trail_large" )
	ModelFX_EndData()

	ModelFX_BeginData( "dropshipCrash", "models/vehicle/goblin_dropship/goblin_dropship_dest_cockpit.mdl", "all", true )
		//----------------------
		// Trailing smoke and fire
		//----------------------
		ModelFX_AddTagSpawnFX( "tag1", "veh_fire_trail_large" )
	ModelFX_EndData()
}