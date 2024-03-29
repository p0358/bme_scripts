
function main()
{
	ModelFX_BeginData( "titanHealth", ATLAS_MODEL, "notLocalPlayer", true )
		ModelFX_AddTagHealthFXAndSound( TITAN_DAMAGE_STAGE_1, "dam_vents", "xo_health_smoke_white", false, "titan_damage_steam_loop", "titan_damage_steam_start" )
		ModelFX_AddTagHealthFX( TITAN_DAMAGE_STAGE_1, "dam_vent_right", "xo_health_exhaust_white_1", false )
		ModelFX_AddTagHealthFX( TITAN_DAMAGE_STAGE_1, "dam_vent_left", "xo_health_exhaust_white_1", false )
		ModelFX_AddTagHealthFXAndSound( TITAN_DAMAGE_STAGE_2, "dam_vent_right", "xo_health_dam_exhaust_fire_1", false, "titan_damage_smoke_loop", "titan_damage_smoke_start" )
		ModelFX_AddTagHealthFX( TITAN_DAMAGE_STAGE_2, "dam_vent_left", "xo_health_dam_exhaust_fire_1", false )
		ModelFX_AddTagHealthFXAndSound( TITAN_DAMAGE_STAGE_3, "dam_vents", "xo_health_fire_vent", false, "titan_damage_small_fire_loop", "titan_damage_small_fire_start" )
	ModelFX_EndData()

	ModelFX_BeginData( "titanDoomed", ATLAS_MODEL, "notLocalPlayer", false )
		ModelFX_AddTagHealthFXAndSound( 1.0, "dam_vents", "P_titan_doom_stage_1", false, "titan_damage_large_fire_loop", "titan_damage_large_fire_start" )
		ModelFX_AddTagHealthFX( 0.5, "dam_vents", "P_titan_doom_stage_2", false )
		ModelFX_AddTagHealthFX( 0.05, "dam_vents", "P_titan_doom_stage_3", false )
	ModelFX_EndData()

	ModelFX_BeginData( "titanDamage", ATLAS_MODEL, "notLocalPlayer", true )

		//Left Shoulder Damage
		ModelFX_AddTagBreakFX( 1, "exp_L_shoulder", "xo_damage_exp_1", "titan_armor_damage" )
		ModelFX_AddTagHealthDamageFX( 1, 0.85, "exp_L_shoulder", "xo_damage_lvl_1_elec", 0.5, 2.0 )
		ModelFX_AddTagHealthDamageFXLoop( 1, 0.0, "exp_L_shoulder", "P_xo_damage_fire_2_alt" )
		ModelFX_AddTagBreakGib( 1, "exp_L_shoulder", "models/gibs/titan_gibs/at_gib9_l_bicep1.mdl", GIBTYPE_DEATH, 400, 500 )

		//Left Elbow Damage
		ModelFX_AddTagBreakFX( 1, "exp_L_elbow", "xo_damage_exp_2", "titan_armor_damage"  )
		//ModelFX_AddTagBreakGib( 1, "exp_L_elbow", "models/gibs/titan_gibs/at_gib_l_arm2_d.mdl", GIBTYPE_DEATH, 400, 500 )

		//Right Shoulder Damage
		ModelFX_AddTagDamageFX( 1, "dam_R_arm_upper", "xo_spark_med", 1.5, 6.0, "titan_damage_spark" )
		ModelFX_AddTagBreakFX( 1, "exp_R_shoulder", "xo_damage_exp_2", "titan_armor_damage"  )

		//Right Elbow Damage
		ModelFX_AddTagBreakFX( 1, "exp_R_elbow", "xo_damage_exp_1", "titan_armor_damage"  )
		ModelFX_AddTagHealthDamageFX( 1, 0.75, "exp_R_elbow", "xo_damage_lvl_1_elec", 0.5, 2.0 )
		ModelFX_AddTagHealthDamageFXLoop( 1, 0.0, "exp_R_elbow", "P_xo_damage_fire_2_alt" )
		ModelFX_AddTagBreakGib( 1, "exp_R_elbow", "models/gibs/titan_gibs/at_gib9_l_bicep1.mdl", GIBTYPE_DEATH, 400, 500 )

		//Torso
		ModelFX_AddTagBreakFX( 1, "exp_torso_front", "xo_damage_exp_1", "titan_armor_damage"  )
		ModelFX_AddTagBreakFX( 1, "exp_torso_back", "xo_damage_exp_1", "titan_armor_damage"  )
		ModelFX_AddTagDamageFX( 1, "dam_L_camera", "xo_spark_med", 1.5, 6.0, "titan_damage_spark" )


		//Left Thigh
		ModelFX_AddTagBreakFX( 1, "exp_L_thigh", "xo_damage_exp_2", "titan_armor_damage"  )
		ModelFX_AddTagDamageFX( 1, "dam_L_thigh_front", "xo_spark_med", 1.5, 6.0, "titan_damage_spark" )
		ModelFX_AddTagBreakGib( 1, "dam_L_thigh_front", "models/gibs/titan_gibs/at_gib8_l_thigh1.mdl", GIBTYPE_NORMAL, 400, 500 )

		ModelFX_AddTagDamageFX( 1, "dam_L_thigh_side", "xo_spark_med", 1.5, 6.0, "titan_damage_spark" )
		ModelFX_AddTagBreakGib( 1, "dam_L_thigh_side", "models/gibs/titan_gibs/at_gib8_l_thigh2.mdl", GIBTYPE_NORMAL, 400, 500 )

		ModelFX_AddTagDamageFX( 1, "dam_L_thigh_back", "xo_spark_med", 1.5, 6.0, "titan_damage_spark" )
		ModelFX_AddTagBreakGib( 1, "dam_L_thigh_back", "models/gibs/titan_gibs/at_gib1.mdl", GIBTYPE_NORMAL, 400, 500 )

		//Left Knee
		ModelFX_AddTagBreakFX( 1, "exp_L_knee", "xo_damage_exp_1", "titan_armor_damage"  )
		ModelFX_AddTagHealthDamageFX( 1, 0.80, "exp_L_knee", "xo_damage_lvl_1_elec", 0.5, 2.0 )
		ModelFX_AddTagHealthDamageFXLoop( 1, 0.0, "exp_L_knee", "P_xo_damage_fire_2" )

		//Right Thigh
		ModelFX_AddTagBreakFX( 1, "exp_R_thigh", "xo_damage_exp_1", "titan_armor_damage" )
		ModelFX_AddTagHealthDamageFX( 1, 0.75, "exp_R_thigh", "xo_damage_lvl_1_elec", 0.5, 2.0 )
		ModelFX_AddTagHealthDamageFXLoop( 1, 0.0, "exp_R_thigh", "P_xo_damage_fire_1" )

		ModelFX_AddTagBreakGib( 1, "exp_R_thigh", "models/gibs/titan_gibs/at_gib8_l_thigh1.mdl", GIBTYPE_NORMAL, 400, 500 )

		//Right Knee
		ModelFX_AddTagBreakFX( 1, "exp_R_knee", "xo_damage_exp_1", "titan_armor_damage"  )
		ModelFX_AddTagHealthDamageFX( 1, 0.65, "exp_R_knee", "xo_damage_lvl_1_elec", 0.5, 2.0 )
		ModelFX_AddTagHealthDamageFXLoop( 1, 0.25, "exp_R_knee", "P_xo_damage_fire_1" )

		ModelFX_AddTagBreakGib( 1, "exp_R_knee", "models/gibs/titan_gibs/at_gib7_r_shin.mdl", GIBTYPE_DEATH, 400, 500 )

		//Death Explosion FX
//		ModelFX_AddTagBreakFX( null, "exp_torso_main", "xo_exp_death", "titan_death_explode" )

		ModelFX_AddTagBreakGib( 2, "exp_torso_front", "models/gibs/titan_gibs/at_gib_hatch_d.mdl", GIBTYPE_DEATH, 600, 800 )
		ModelFX_AddTagBreakGib( 2, "exp_L_shoulder", "models/gibs/titan_gibs/at_gib_l_arm1_d.mdl", GIBTYPE_DEATH, 600, 800 )
		ModelFX_AddTagBreakGib( 2, "exp_L_elbow", "models/gibs/titan_gibs/at_gib_l_arm2_d.mdl", GIBTYPE_DEATH, 600, 800 )
		ModelFX_AddTagBreakGib( 2, "exp_R_shoulder", "models/gibs/titan_gibs/at_gib_r_arm1_d.mdl", GIBTYPE_DEATH, 600, 800 )
		ModelFX_AddTagBreakGib( 2, "exp_R_elbow", "models/gibs/titan_gibs/at_gib_r_arm2_d.mdl", GIBTYPE_DEATH, 600, 800 )

		ModelFX_AddTagBreakFX( 1, "exp_L_shoulder", "xo_dmg_gibs", "" )
		ModelFX_AddTagBreakFX( 2, "exp_L_shoulder", "xo_dmg_gibs", "" )
		ModelFX_AddTagBreakFX( 1, "exp_L_elbow", "xo_dmg_gibs", "" )
		ModelFX_AddTagBreakFX( 1, "exp_R_shoulder", "xo_dmg_gibs", "" )
		ModelFX_AddTagBreakFX( 1, "exp_R_elbow", "xo_dmg_gibs", "" )
		ModelFX_AddTagBreakFX( 2, "exp_R_elbow", "xo_dmg_gibs", "" )
		ModelFX_AddTagBreakFX( 1, "exp_torso_front", "xo_dmg_gibs", "" )
		ModelFX_AddTagBreakFX( 2, "exp_torso_front", "xo_dmg_gibs", "" )
		ModelFX_AddTagBreakFX( 1, "exp_torso_back", "xo_dmg_gibs", "" )
		ModelFX_AddTagBreakFX( 1, "exp_torso_base", "xo_dmg_gibs", "" )
		ModelFX_AddTagBreakFX( 1, "exp_R_thigh", "xo_dmg_gibs", "" )
		ModelFX_AddTagBreakFX( 1, "exp_R_knee", "xo_dmg_gibs", "" )
		ModelFX_AddTagBreakFX( 2, "exp_R_knee", "xo_dmg_gibs", "" )
		ModelFX_AddTagBreakFX( 1, "exp_L_thigh", "xo_dmg_gibs", "" )
		ModelFX_AddTagBreakFX( 2, "exp_L_thigh", "xo_dmg_gibs", "" )
		ModelFX_AddTagBreakFX( 1, "exp_L_knee", "xo_dmg_gibs", "" )

	ModelFX_EndData()
}