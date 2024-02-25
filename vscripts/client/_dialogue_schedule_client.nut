function main()
{
	Globalize( AddConversation )
	Globalize( ReplaceConversation )
	Globalize( AddVDURadio )
	Globalize( AddVDUAnimWithEmbeddedAudio )
	Globalize( AddCustomVDUFunction )
	Globalize( AddVDULineForSpyglass )
	Globalize( AddVDULineForBlisk )
	Globalize( AddVDULineForGraves )
	Globalize( AddVDUAnimWithEmbeddedAudioForSpyglass )
	Globalize( AddVDUAnimWithEmbeddedAudioForBlisk )
	Globalize( AddVDUAnimWithEmbeddedAudioForGraves )
	Globalize( AddSceneExclusion )
	Globalize( AddWait )
	Globalize( AddMusic )
	Globalize( AddVDULineForSarah )
	Globalize( AddVDULineForBish )
	Globalize( AddVDULineForMacAllan )
	Globalize( AddVDULineForBarker )
	Globalize( AddVDUAnimWithEmbeddedAudioForSarah )
	Globalize( AddVDUAnimWithEmbeddedAudioForBish )
	Globalize( AddVDUAnimWithEmbeddedAudioForMacAllan )
	Globalize( AddVDUAnimWithEmbeddedAudioForBarker )
	Globalize( AddRadio )
	Globalize( AddVDUHide )

	Globalize( CreateScene )
	Globalize( AddSceneConversation )

	local actorsABCD = [ 1, 1, 1, 1 ]
	AddConversations( TEAM_MILITIA, actorsABCD )
	AddConversations( TEAM_IMC, actorsABCD )

	AddHardpointConversations( TEAM_IMC, actorsABCD )
	AddHardpointConversations( TEAM_MILITIA, actorsABCD )
	AddHardpointConversations_IMC( actorsABCD )
	AddHardpointConversations_Militia( actorsABCD )
	AddGlobalChatter( TEAM_IMC, actorsABCD )
	AddGlobalChatter( TEAM_MILITIA, actorsABCD )

	AddConversation_Militia( actorsABCD )
	AddConversation_IMC( actorsABCD )
}

function AddConversations( team, actors )
{
	/*
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_rumorplayer_02_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_rumorplayer_02_2", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_rumorplayer_02_3", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_rumorplayer_02_4", actors )]}
	]
	AddConversation( "blah", team, lines )



	Commands to help get context:
	GetNearestVisibleFriendlyPlayer
	CanSee
	CodeCallback_OnNPCLookAtHint
	GetSafeHint()

	schedules for context:
	enemy spotted   SCHED_SIGNAL_FORWARD
	acknowledge enemy spotted   SCHED_SIGNAL_ACKNOWLEDGE
	fan out to take cover   SCHED_MOVE_TO_SQUAD_ASSIGNED_NODE
	moving to squad leader   SCHED_MOVE_TO_SQUAD_LEADER_GOAL
	attacking
	reloading  SCHED_RELOAD
	grenade
	run away because squad died and out numbered  SCHED_RUN_FROM_ENEMY
	run away from titan  SCHED_RUN_FROM_ENEMY
	at safe spot from titan  SCHED_RUN_FROM_ENEMY_FALLBACK_COMPLETE
	salute   SCHED_SIGNAL_SALUTE



	// to do ( // means implemented )
	aichat_rumor_pilot
		"I heard Pilots undergo full metal skeletal replacements after training..."

	aichat_grenade_incoming // need code

//	aichat_address_pilot // need cansee
//		"We got a friendly Pilot comin' through."
//	aichat_titan_cheer // need cansee
//		"We got Titan support guys!"
//	grunt_flees_titan_building // goes with grunt_flees_titan, needs code for building logic
//	aichat_fan_out // needs code
//	aichat_death_enemy_titan
//	aichat_death_friendly_grunt
//	ally_titan_down
//	ally_eject_fail
//	aichat_killed_enemy_titan
//	aichat_rodeo_cheer
//	aichat_engage_pilot
//	grunt_group_flees_titan
//	aichat_hotspot_window
//	aichat_hotspot_door
//	aichat_hotspot_balcony
//	aichat_hotspot_second_floor_window
//	aichat_hotspot_corner
//	aichat_move_squadlead
//	aichat_reload
//	aichat_spot_titan_close
//	aichat_squad_deplete
	*/

	if ( IsServer() )
		return



	local conversation = "aichat_grenade_incoming"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0,
			choices =
			[
				Voices( team, "gs_grenadecall_01", 		actors )
				Voices( team, "gs_grenadecall_02", 		actors )
				Voices( team, "gs_grenadecall_03", 		actors )
				Voices( team, "gs_grenadecall_04", 		actors )
			]
		}
		{ dialogType = "speech", speakerIndex = 1,
			choices =
			[
				Voices( team, "gs_grenaderesponse_01", 		actors )
				Voices( team, "gs_grenaderesponse_02", 		actors )
				Voices( team, "gs_grenaderesponse_03", 		actors )
				Voices( team, "gs_grenaderesponse_04", 		actors )
			]
		}
	]
	AddConversation( conversation, team, lines )


	local conversation = "aichat_spot_titan_close"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0,
			choices =
			[
				Voices( team, "gs_spotclosetitancall_01", 		actors )
				Voices( team, "gs_spotclosetitancall_02", 		actors )
				Voices( team, "gs_spotclosetitancall_03", 		actors )
				Voices( team, "gs_spotclosetitancall_04", 		actors )
				Voices( team, "gs_spotclosetitancall_05", 		actors )
				Voices( team, "gs_spotclosetitancall_06", 		actors )
				Voices( team, "gs_spotclosetitancall_07", 		actors )
			]
		}
		{ dialogType = "speech", speakerIndex = 1,
			choices =
			[
				Voices( team, "gs_spotclosetitanresponse_01", 		actors )
				Voices( team, "gs_spotclosetitanresponse_02", 		actors )
				Voices( team, "gs_spotclosetitanresponse_03", 		actors )
				Voices( team, "gs_spotclosetitanresponse_04", 		actors )
				Voices( team, "gs_spotclosetitanresponse_05", 		actors )
				Voices( team, "gs_spotclosetitanresponse_06", 		actors )
				Voices( team, "gs_spotclosetitanresponse_07", 		actors )
				Voices( team, "gs_spotclosetitanresponse_08", 		actors )
			]
		}
	]
	AddConversation( conversation, team, lines )

	local conversation = "aichat_rumor_pilot"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_rumorplayer_01_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_rumorplayer_01_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_rumorplayer_02_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_rumorplayer_02_2", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_rumorplayer_02_3", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_rumorplayer_02_4", actors )]}
	]
	AddConversation( conversation, team, lines )


	local conversation = "aichat_reload"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0,
			choices =
			[
				Voices( team, "gs_reloadcall_01", 		actors )
				Voices( team, "gs_reloadcall_02", 		actors )
				Voices( team, "gs_reloadcall_03", 		actors )
				Voices( team, "gs_reloadcall_04", 		actors )
				Voices( team, "gs_reloadcall_05", 		actors )
				Voices( team, "gs_reloadcall_04", 		actors )
				Voices( team, "gs_reloadcall_05", 		actors )
			]
		}
		{ dialogType = "speech", speakerIndex = 1,
			choices =
			[
				Voices( team, "gs_reloadresponse_01", 		actors )
				Voices( team, "gs_reloadresponse_02", 		actors )
				Voices( team, "gs_reloadresponse_03", 		actors )
				Voices( team, "gs_reloadresponse_04", 		actors )
				Voices( team, "gs_reloadresponse_05", 		actors )
				Voices( team, "gs_reloadresponse_04", 		actors )
				Voices( team, "gs_reloadresponse_05", 		actors )
			]
		}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0,
			choices =
			[
				Voices( team, "gs_magswitchcall_01", 		actors )
				Voices( team, "gs_magswitchcall_02", 		actors )
			]
		}
		{ dialogType = "speech", speakerIndex = 1,
			choices =
			[
				Voices( team, "gs_magswitchresponse_01", 		actors )
				Voices( team, "gs_magswitchresponse_02", 		actors )
				Voices( team, "gs_magswitchresponse_03", 		actors )
				Voices( team, "gs_magswitchresponse_04", 		actors )
			]
		}
	]
	AddConversation( conversation, team, lines )


	local conversation = "aichat_move_squadlead"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_movesquadlead_01_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_movesquadlead_01_2a", actors )]}
		{ dialogType = "speech", speakerIndex = 2, choices = [Voices( team, "gs_movesquadlead_01_2b", actors )]}
		{ dialogType = "speech", speakerIndex = 3, choices = [Voices( team, "gs_movesquadlead_01_3c", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_movesquadlead_02_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_movesquadlead_02_2a", actors )]}
		{ dialogType = "speech", speakerIndex = 2, choices = [Voices( team, "gs_movesquadlead_02_2b", actors )]}
		{ dialogType = "speech", speakerIndex = 3, choices = [Voices( team, "gs_movesquadlead_02_3c", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_movesquadlead_03_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_movesquadlead_03_2a", actors )]}
		{ dialogType = "speech", speakerIndex = 2, choices = [Voices( team, "gs_movesquadlead_03_2b", actors )]}
		{ dialogType = "speech", speakerIndex = 3, choices = [Voices( team, "gs_movesquadlead_03_3c", actors )]}
	]
	AddConversation( conversation, team, lines )



	local conversation = "aichat_hotspot_window"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_hotspotcheck_01_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_hotspotcheck_01_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_hotspotcheck_07_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_hotspotcheck_07_2", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_hotspotcheck_07_3", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_hotspotcheck_07_4", actors )]}
	]
	AddConversation( conversation, team, lines )


	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_hotspotcheck_02_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_hotspotcheck_02_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local conversation = "aichat_hotspot_door"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_hotspotcheck_03_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_hotspotcheck_03_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_hotspotcheck_08_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_hotspotcheck_08_2", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_hotspotcheck_08_3", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_hotspotcheck_08_4", actors )]}
	]
	AddConversation( conversation, team, lines )


	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_hotspotcheck_04_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_hotspotcheck_04_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local conversation = "aichat_hotspot_balcony"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_hotspotcheck_05_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_hotspotcheck_05_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_hotspotcheck_09_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_hotspotcheck_09_2", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_hotspotcheck_09_3", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_hotspotcheck_09_4", actors )]}
	]
	AddConversation( conversation, team, lines )


	local conversation = "aichat_hotspot_second_floor_window"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_hotspotcheck_06_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_hotspotcheck_06_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_hotspotcheck_10_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_hotspotcheck_10_2", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_hotspotcheck_10_3", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_hotspotcheck_10_4", actors )]}
	]
	AddConversation( conversation, team, lines )




	local conversation = "aichat_hotspot_corner"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_hotspotcheck_11_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_hotspotcheck_11_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_hotspotcheck_12_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_hotspotcheck_12_2", actors )]}
	]
	AddConversation( conversation, team, lines )





	local conversation = "aichat_fan_out"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0,
			choices =
			[
				Voices( team, "gs_fanoutcall_01", 		actors )
				Voices( team, "gs_fanoutcall_02", 		actors )
				Voices( team, "gs_fanoutcall_03", 		actors )
				Voices( team, "gs_fanoutcall_04", 		actors )
				Voices( team, "gs_fanoutcall_05", 		actors )
			]
		}
		{ dialogType = "speech", speakerIndex = 1,
			choices =
			[
				Voices( team, "gs_fanoutresponse_01", 		actors )
				Voices( team, "gs_fanoutresponse_02", 		actors )
				Voices( team, "gs_fanoutresponse_03", 		actors )
				Voices( team, "gs_fanoutresponse_04", 		actors )
				Voices( team, "gs_fanoutresponse_05", 		actors )
			]
		}
		{ dialogType = "speech", speakerIndex = 2, choices = [Voices( team, "gs_fanoutcheckin_01_1", actors )]}
		{ dialogType = "speech", speakerIndex = 3, choices = [Voices( team, "gs_fanoutcheckin_01_2", actors )]}
	]
	AddConversation( conversation, team, lines )



	local conversation = "aichat_rodeo_cheer"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_rodeocheer_01", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_rodeocheer_02", actors )]}
	]
	AddConversation( conversation, team, lines )



	local conversation = "aichat_titan_cheer"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_titancheer_01_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_titancheer_01_2", actors )]}
		{ dialogType = "speech", speakerIndex = 2, choices = [Voices( team, "gs_titancheer_01_3", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_titancheer_02_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_titancheer_02_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_titancheer_03_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_titancheer_03_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_titancheer_04_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_titancheer_04_2", actors )]}
	]
	AddConversation( conversation, team, lines )


	local conversation = "aichat_killed_enemy_titan"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_gruntkillstitan_01_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_gruntkillstitan_01_2", actors )]}
	]
	AddConversation( conversation, team, lines )


	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_gruntkillstitan_03_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_gruntkillstitan_03_2", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_gruntkillstitan_03_3", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_gruntkillstitan_03_4", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_gruntkillstitan_04_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_gruntkillstitan_04_2", actors )]}
	]
	AddConversation( conversation, team, lines )


	local conversation = "aichat_address_pilot"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_addressplayer_01_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_addressplayer_01_2", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_addressplayer_01_3", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_addressplayer_02_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_addressplayer_02_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_addressplayer_03_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_addressplayer_03_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_pilotNear_04_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_pilotNear_04_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_pilotNear_05_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_pilotNear_05_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_pilotNear_06_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_pilotNear_06_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_pilotNear_07_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_pilotNear_07_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_pilotNear_08_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_pilotNear_08_02", actors )]}
	]
	AddConversation( conversation, team, lines )


	local conversation = "ally_eject_fail"

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_allyejectfail_02_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_allyejectfail_02_2", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_allyejectfail_02_3", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_allyejectfail_03_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_allyejectfail_03_2", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_allyejectfail_03_3", actors )]}
	]
	AddConversation( conversation, team, lines )



	local conversation = "aichat_death_enemy_titan"

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_enemytitandown_03_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_enemytitandown_03_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_enemytitandown_04_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_enemytitandown_04_2", actors )]}
	]
	AddConversation( conversation, team, lines )



	local conversation = "aichat_death_friendly_grunt"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_allygrundown_01_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_allygrundown_01_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_allygrundown_02_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_allygrundown_02_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_allygrundown_03_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_allygrundown_03_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_allygrundown_04_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_allygrundown_04_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_allygrundown_06_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_allygrundown_06_2", actors )]}
	]
	AddConversation( conversation, team, lines )



	local conversation = "aichat_killed_pilot"

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_killenemypilot_01_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_killenemypilot_01_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_killenemypilot_02_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_killenemypilot_02_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_killenemypilot_03_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_killenemypilot_03_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_killenemypilot_04_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_killenemypilot_04_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_killenemypilot_05_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_killenemypilot_05_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_killenemypilot_06_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_killenemypilot_06_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_killenemypilot_07_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_killenemypilot_07_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_killenemypilot_08_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_killenemypilot_08_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_killenemypilot_09_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_killenemypilot_09_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_killenemypilot_10_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_killenemypilot_10_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local conversation = "killed_enemy_grunt"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_killenemygrunt_01_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_killenemygrunt_01_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_killenemygrunt_02_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_killenemygrunt_02_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_killenemygrunt_03_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_killenemygrunt_03_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_killenemygrunt_04_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_killenemygrunt_04_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_killenemygrunt_05_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_killenemygrunt_05_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_killenemygrunt_06_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_killenemygrunt_06_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_killenemygrunt_07_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_killenemygrunt_07_2", actors )]}
	]
	AddConversation( conversation, team, lines )






	local conversation = "ally_titan_down"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_allytitandown_01_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_allytitandown_01_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_allytitandown_02_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_allytitandown_02_2", actors )]}
	]
	AddConversation( conversation, team, lines )


	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_allytitandown_04_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_allytitandown_04_2", actors )]}
	]
	AddConversation( conversation, team, lines )



	local conversation = "aichat_move_out"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_movefrontline_03_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_movefrontline_03_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_movefrontline_04_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_movefrontline_04_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_movefrontline_06_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_movefrontline_06_2", actors )]}
		{ dialogType = "speech", speakerIndex = 2, choices = [Voices( team, "gs_movefrontline_06_3", actors )]}
		{ dialogType = "speech", speakerIndex = 3, choices = [Voices( team, "gs_movefrontline_06_4", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_movefrontline_07_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_movefrontline_07_2", actors )]}
		{ dialogType = "speech", speakerIndex = 2, choices = [Voices( team, "gs_movefrontline_07_3", actors )]}
		{ dialogType = "speech", speakerIndex = 3, choices = [Voices( team, "gs_movefrontline_07_4", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_movefrontline_08_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_movefrontline_08_2", actors )]}
		{ dialogType = "speech", speakerIndex = 2, choices = [Voices( team, "gs_movefrontline_08_3", actors )]}
		{ dialogType = "speech", speakerIndex = 3, choices = [Voices( team, "gs_movefrontline_08_4", actors )]}
	]
	AddConversation( conversation, team, lines )



	local conversation = "aichat_callout_titan"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_spotfartitan_1_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_spotfartitan_1_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_spotfartitan_2_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_spotfartitan_2_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_spotfartitan_3_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_spotfartitan_3_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_spotfartitan_4_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_spotfartitan_4_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_spotfartitan_8_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_spotfartitan_8_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_spotfartitan_9_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_spotfartitan_9_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_spotfartitan_10_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_spotfartitan_10_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_spotfartitan_11_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_spotfartitan_11_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_spotfartitan_12_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_spotfartitan_12_2", actors )]}
	]
	AddConversation( conversation, team, lines )



	local conversation = "aichat_engage_pilot"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_engagepilotenemy_01_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_engagepilotenemy_01_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_engagepilotenemy_02_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_engagepilotenemy_02_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_engagepilotenemy_03_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_engagepilotenemy_03_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_engagepilotenemy_04_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_engagepilotenemy_04_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_engagepilotenemy_05_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_engagepilotenemy_05_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_engagepilotenemy_06_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_engagepilotenemy_06_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_engagepilotenemy_07_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_engagepilotenemy_07_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_engagepilotenemy_08_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_engagepilotenemy_08_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_engagepilotenemy_09_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_engagepilotenemy_09_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_engagepilotenemy_10_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_engagepilotenemy_10_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local conversation = "aichat_callout_pilot_dev"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_spotenemypilot_01_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_spotenemypilot_01_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	// swap lines until the aliases for this conversation are fixed
	local conversation = "aichat_callout_pilot_call_response"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_spotenemypilot_01_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_spotenemypilot_01_2", actors )]}
	]
//	local lines =
//	[
//		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_spotenemypilotcall", actors )]}
//		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_spotenemypilotrespond", actors )]}
//	]
	AddConversation( conversation, team, lines )

	local conversation = "aichat_callout_pilot"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_spotenemypilot_01_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_spotenemypilot_01_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_spotenemypilot_02_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_spotenemypilot_02_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_spotenemypilot_03_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_spotenemypilot_03_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_spotenemypilot_04_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_spotenemypilot_04_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_spotenemypilot_05_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_spotenemypilot_05_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_spotenemypilot_06_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_spotenemypilot_06_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_spotenemypilot_07_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_spotenemypilot_07_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_spotenemypilot_08_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_spotenemypilot_08_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_spotenemypilot_09_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_spotenemypilot_09_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_spotenemypilot_10_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_spotenemypilot_10_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_spotenemypilot_11_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_spotenemypilot_11_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local array =
	[
		{ dialogType = "speech", speakerIndex = 0,
			choices =
			[
				Voices( team, "gs_fleeplayertitancall_01", 		actors )
			]
		}

		{ dialogType = "speech", speakerIndex = 1,
			choices =
			[
				Voices( team, "gs_fleeplayertitanresponse_01", 		actors )
			]
		}
	]
	AddConversation( "grunt_flees_titan_dev", team, array )

	local array =
	[
		{ dialogType = "speech", speakerIndex = 0,
			choices =
			[
				Voices( team, "gs_fleeplayertitancall_01", 		actors )
				Voices( team, "gs_fleeplayertitancall_02", 		actors )
				Voices( team, "gs_fleeplayertitancall_03", 		actors )
				Voices( team, "gs_fleeplayertitancall_04", 		actors )
				Voices( team, "gs_fleeplayertitancall_05", 		actors )
				Voices( team, "gs_fleeplayertitancall_06", 		actors )
				Voices( team, "gs_fleeplayertitancall_07", 		actors )
			]
		}

		{ dialogType = "speech", speakerIndex = 1,
			choices =
			[
				Voices( team, "gs_fleeplayertitanresponse_01", 		actors )
				Voices( team, "gs_fleeplayertitanresponse_02", 		actors )
				Voices( team, "gs_fleeplayertitanresponse_03", 		actors )
				Voices( team, "gs_fleeplayertitanresponse_04", 		actors )
				Voices( team, "gs_fleeplayertitanresponse_05", 		actors )
				Voices( team, "gs_fleeplayertitanresponse_06", 		actors )
				Voices( team, "gs_fleeplayertitanresponse_07", 		actors )
			]
		}
	]
	AddConversation( "grunt_flees_titan", team, array )


	local array =
	[
		{ dialogType = "speech", speakerIndex = 0,
			choices =
			[
				Voices( team, "gs_fleeplayertitanbuildingcall_01", 		actors )
				Voices( team, "gs_fleeplayertitanbuildingcall_02", 		actors )
				Voices( team, "gs_fleeplayertitanbuildingcall_03", 		actors )
				Voices( team, "gs_fleeplayertitanbuildingcall_04", 		actors )
			]
		}

		{ dialogType = "speech", speakerIndex = 1,
			choices =
			[
				Voices( team, "gs_fleeplayertitanbuildingresponse_01", 		actors )
				Voices( team, "gs_fleeplayertitanbuildingresponse_02", 		actors )
				Voices( team, "gs_fleeplayertitanbuildingresponse_03", 		actors )
				Voices( team, "gs_fleeplayertitanbuildingresponse_04", 		actors )
				Voices( team, "gs_fleeplayertitanbuildingresponse_05", 		actors )
				Voices( team, "gs_fleeplayertitanbuildingresponse_06", 		actors )
			]
		}
	]
	AddConversation( "grunt_flees_titan_building", team, array )

	local array =
	[
		{ dialogType = "speech", speakerIndex = 0,
			choices =
			[
				Voices( team, "gs_fleeplayertitangroupcall_01", 		actors )
				Voices( team, "gs_fleeplayertitangroupcall_02", 		actors )
				Voices( team, "gs_fleeplayertitangroupcall_03", 		actors )
				Voices( team, "gs_fleeplayertitangroupcall_04", 		actors )
			]
		}

		{ dialogType = "speech", speakerIndex = 1,
			choices =
			[
				Voices( team, "gs_fleeplayertitangroupresponse_01", 		actors )
				Voices( team, "gs_fleeplayertitangroupresponse_02", 		actors )
				Voices( team, "gs_fleeplayertitangroupresponse_03", 		actors )
				Voices( team, "gs_fleeplayertitangroupresponse_04", 		actors )
			]
		}
	]
	AddConversation( "grunt_group_flees_titan", team, array )





	local array =
	[
		{ dialogType = "speech", 	speakerIndex = 0,
			choices =
			[
				Voices( team, "gs_fleeplayertitan_04", actors )
			]
		}
	]
	AddConversation( "grunt_flees_titan", team, array )

	local array =
	[
		{ dialogType = "speech", 	speakerIndex = 0,
			choices =
			[
				Voices( team, "gs_fleeplayertitan_05", actors )
			]
		}
	]
	AddConversation( "grunt_flees_titan", team, array )

	local conversation = "aichat_male_pilot_cloaked"

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_engageenemycloakedpilot_01_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_engageenemycloakedpilot_01_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_engageenemycloakedpilot_04_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_engageenemycloakedpilot_04_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local conversation = "aichat_female_pilot_cloaked"

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_engageenemycloakedpilot_02_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_engageenemycloakedpilot_02_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_engageenemycloakedpilot_05_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_engageenemycloakedpilot_05_1", actors )]}
	]
	AddConversation( conversation, team, lines )

	local conversation = "aichat_generic_pilot_cloaked"

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_engageenemycloakedpilot_03_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_engageenemycloakedpilot_03_2", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_engageenemycloakedpilot_06_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_engageenemycloakedpilot_06_1", actors )]}
	]
	AddConversation( conversation, team, lines )
}

function AddHardpointConversations( team, actors )
{
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "hp_capturinghp_01_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "hp_capturinghp_01_2", actors )]}
	]
	AddConversation( "aichat_capturing_hardpoint", team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "hp_capturinghp_02_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "hp_capturinghp_02_2", actors )]}
	]
	AddConversation( "aichat_capturing_hardpoint", team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "hp_capturinghp_03_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "hp_capturinghp_03_2", actors )]}
	]
	AddConversation( "aichat_capturing_hardpoint", team, lines )
}


function AddHardpointConversations_IMC( actors )
{
	// these should all be generic but there are sounds that are missing for militia.
	local team = TEAM_IMC

	// missing alias "diag_imc_grunt1_hp_capturinghp_04_2"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "hp_capturinghp_04_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "hp_capturinghp_04_2", actors )]}
	]
	AddConversation( "aichat_capturing_hardpoint", team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "hp_capturedhp_01_1", actors )]}
		{ dialogType = "dispatch",                 choices = [ "diag_imc_spyglass_hp_capturedhp_01" ]}
	]
	AddConversation( "aichat_captured_hardpoint", team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "hp_capturedhp_02_1", actors )]}
		{ dialogType = "dispatch",                 choices = ["diag_imc_spyglass_hp_capturedhp_02"]}
	]
	AddConversation( "aichat_captured_hardpoint", team, lines )
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "hp_capturedhp_03_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "hp_capturedhp_03_2", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "hp_capturedhp_03_3", actors )]}
	]
	AddConversation( "aichat_captured_hardpoint", team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "hp_capturedhp_04_1", actors )]}
		{ dialogType = "dispatch",                 choices = ["diag_imc_spyglass_hp_capturedhp_04_2"]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "hp_capturedhp_04_3", actors )]}
	]
	AddConversation( "aichat_captured_hardpoint", team, lines )
}

function AddHardpointConversations_Militia( actors )
{
	// these should all be generic but a bunch of sounds are missing for militia, mostly dispatch (Bish?)
	local team = TEAM_MILITIA

	// missing a response form Bish or whom ever is the militia dispatch voice
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "hp_capturedhp_01_1", actors )]}
	]
	AddConversation( "aichat_captured_hardpoint", team, lines )

	// missing a response form Bish or whom ever is the militia dispatch voice
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "hp_capturedhp_02_1", actors )]}
	]
	AddConversation( "aichat_captured_hardpoint", team, lines )

	// missing a initial line from line in the middle form Bish or whom ever is the militia dispatch voice
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "hp_capturedhp_03_2", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "hp_capturedhp_03_3", actors )]}
	]
	AddConversation( "aichat_captured_hardpoint", team, lines )

	// missing a line in the middle form Bish or whom ever is the militia dispatch voice
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "hp_capturedhp_04_1", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "hp_capturedhp_04_3", actors )]}
	]
	AddConversation( "aichat_captured_hardpoint", team, lines )

}

function AddConversation_IMC( actors )
{
	local team = TEAM_IMC
	// imc has a disaptcher, so lets copy paste!
	local conversation = "aichat_squad_deplete"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_squaddeplete_01_1", actors )]}
		{ dialogType = "dispatch",                 choices = [Dispatch( team, "gs_squaddeplete_01_2" )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_squaddeplete_02_1", actors )]}
		{ dialogType = "dispatch",                 choices = [Dispatch( team, "gs_squaddeplete_02_2" )]}
	]
	AddConversation( conversation, team, lines )


	local conversation = "aichat_killed_enemy_titan"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_gruntkillstitan_02_1", actors )]}
		{ dialogType = "dispatch",                 choices = [Dispatch( team, "gs_gruntkillstitan_02_2" )]}
	]
	AddConversation( conversation, team, lines )

	local conversation = "ally_eject_fail"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_allyejectfail_01_1", actors )]}
		{ dialogType = "dispatch",                 choices = [Dispatch( team, "gs_allyejectfail_01_2" )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_allyejectfail_01_3", actors )]}
	]
	AddConversation( conversation, team, lines )


	local conversation = "ally_eject_fail"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_allyejectfail_04_1", actors )]}
		{ dialogType = "dispatch",                 choices = [Dispatch( team, "gs_allyejectfail_04_2" )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_allyejectfail_04_3", actors )]}
	]
	AddConversation( conversation, team, lines )

	local conversation = "aichat_death_enemy_titan"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_enemytitandown_01_1", actors )]}
		{ dialogType = "dispatch",                 choices = [Dispatch( team, "gs_enemytitandown_01_2" )]}
	]
	AddConversation( conversation, team, lines )



	local conversation = "aichat_death_friendly_grunt"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_allygrundown_05_1", actors )]}
		{ dialogType = "dispatch",                 choices = [Dispatch( team, "gs_allygrundown_05_2" )]}
	]
	AddConversation( conversation, team, lines )


	local conversation = "ally_pilot_down"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_allypilotdown_01_1", actors )]}
		{ dialogType = "dispatch", 				   choices = [Dispatch( team, "gs_allypilotdown_01_2" )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_allypilotdown_02_1", actors )]}
		{ dialogType = "dispatch", 				   choices = [Dispatch( team, "gs_allypilotdown_02_2" )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_allypilotdown_03_1", actors )]}
		{ dialogType = "dispatch", 				   choices = [Dispatch( team, "gs_allypilotdown_03_2" )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_allypilotdown_04_1", actors )]}
		{ dialogType = "dispatch", 				   choices = [Dispatch( team, "gs_allypilotdown_04_2" )]}
	]
	AddConversation( conversation, team, lines )


	local conversation = "ally_titan_down"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_allytitandown_03_1", actors )]}
		{ dialogType = "dispatch", 				   choices = [Dispatch( team, "gs_allytitandown_03_2" )]}
	]
	AddConversation( conversation, team, lines )


	local conversation = "aichat_move_out"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_movefrontline_01_1", actors )]}
		{ dialogType = "dispatch", 				   choices = [Dispatch( team, "gs_movefrontline_01_2" )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_movefrontline_02_1", actors )]}
		{ dialogType = "dispatch", 				   choices = [Dispatch( team, "gs_movefrontline_02_2" )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_movefrontline_05_1", actors )]}
		{ dialogType = "dispatch", 				   choices = [Dispatch( team, "gs_movefrontline_05_2" )]}
	]
	AddConversation( conversation, team, lines )




	local conversation = "aichat_callout_titan"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_spotfartitan_5_1", actors )]}
		{ dialogType = "dispatch",				   choices = [Dispatch( team, "gs_spotfartitan_5_2" )       ]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_spotfartitan_5_3", actors )]}
	]
	AddConversation( conversation, team, lines )



	local array =
	[
		{ dialogType = "speech", 	speakerIndex = 0,
			choices =
			[
				Voices( team, "gs_fleeplayertitan_02_1", actors )
			]
		}

		{ dialogType = "dispatch", choices = [ Dispatch( team, "gs_fleeplayertitan_02_2" ) ] }

		{ dialogType = "speech", 	speakerIndex = 0,
			choices =
			[
				Voices( team, "gs_fleeplayertitan_02_3", actors )
			]
		}
	]
	AddConversation( "grunt_flees_titan", team, array )


	local array =
	[
		{ dialogType = "speech", 	speakerIndex = 0,
			choices =
			[
				Voices( team, "gs_fleeplayertitan_03_1", actors )
				Voices( team, "gs_fleeplayertitan_03_3", actors )
			]
		}

		{ dialogType = "dispatch", choices = [ Dispatch( team, "gs_fleeplayertitan_03_2" ) ] }
	]
	AddConversation( "grunt_flees_titan", team, array )

	local conversation = "aichat_callout_titan"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_spotfartitan_6_1", actors )]}
		{ dialogType = "dispatch", 		           choices = [Dispatch( team, "gs_spotfartitan_6_2" )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_spotfartitan_7_1", actors )]}
		{ dialogType = "dispatch",				   choices = [Dispatch( team, "gs_spotfartitan_7_2" )]}
	]
	AddConversation( conversation, team, lines )

}

function AddConversation_Militia( actors )
{
	local team = TEAM_MILITIA
	// imc has a disaptcher, so lets copy paste!
	local conversation = "aichat_squad_deplete"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_squaddeplete_01_1", actors )]}
//		{ dialogType = "dispatch",                 choices = [Dispatch( team, "gs_squaddeplete_01_2" )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_squaddeplete_02_1", actors )]}
//		{ dialogType = "dispatch",                 choices = [Dispatch( team, "gs_squaddeplete_02_2" )]}
	]
	AddConversation( conversation, team, lines )


	local conversation = "aichat_killed_enemy_titan"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_gruntkillstitan_02_1", actors )]}
//		{ dialogType = "dispatch",                 choices = [Dispatch( team, "gs_gruntkillstitan_02_2" )]}
	]
	AddConversation( conversation, team, lines )

	local conversation = "ally_eject_fail"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_allyejectfail_01_1", actors )]}
//		{ dialogType = "dispatch",                 choices = [Dispatch( team, "gs_allyejectfail_01_2" )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_allyejectfail_01_3", actors )]}
	]
	AddConversation( conversation, team, lines )


	local conversation = "ally_eject_fail"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_allyejectfail_04_1", actors )]}
//		{ dialogType = "dispatch",                 choices = [Dispatch( team, "gs_allyejectfail_04_2" )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_allyejectfail_04_3", actors )]}
	]
	AddConversation( conversation, team, lines )

	local conversation = "aichat_death_enemy_titan"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_enemytitandown_01_1", actors )]}
//		{ dialogType = "dispatch",                 choices = [Dispatch( team, "gs_enemytitandown_01_2" )]}
	]
	AddConversation( conversation, team, lines )



	local conversation = "aichat_death_friendly_grunt"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_allygrundown_05_1", actors )]}
//		{ dialogType = "dispatch",                 choices = [Dispatch( team, "gs_allygrundown_05_2" )]}
	]
	AddConversation( conversation, team, lines )


	local conversation = "ally_pilot_down"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_allypilotdown_01_1", actors )]}
//		{ dialogType = "dispatch", 				   choices = [Dispatch( team, "gs_allypilotdown_01_2" )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_allypilotdown_02_1", actors )]}
//		{ dialogType = "dispatch", 				   choices = [Dispatch( team, "gs_allypilotdown_02_2" )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_allypilotdown_03_1", actors )]}
//		{ dialogType = "dispatch", 				   choices = [Dispatch( team, "gs_allypilotdown_03_2" )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_allypilotdown_04_1", actors )]}
//		{ dialogType = "dispatch", 				   choices = [Dispatch( team, "gs_allypilotdown_04_2" )]}
	]
	AddConversation( conversation, team, lines )


	local conversation = "ally_titan_down"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_allytitandown_03_1", actors )]}
//		{ dialogType = "dispatch", 				   choices = [Dispatch( team, "gs_allytitandown_03_2" )]}
	]
	AddConversation( conversation, team, lines )


	local conversation = "aichat_move_out"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_movefrontline_01_1", actors )]}
//		{ dialogType = "dispatch", 				   choices = [Dispatch( team, "gs_movefrontline_01_2" )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_movefrontline_02_1", actors )]}
//		{ dialogType = "dispatch", 				   choices = [Dispatch( team, "gs_movefrontline_02_2" )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_movefrontline_05_1", actors )]}
//		{ dialogType = "dispatch", 				   choices = [Dispatch( team, "gs_movefrontline_05_2" )]}
	]
	AddConversation( conversation, team, lines )




	local conversation = "aichat_callout_titan"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_spotfartitan_5_1", actors )]}
//		{ dialogType = "dispatch",				   choices = [Dispatch( team, "gs_spotfartitan_5_2" )       ]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_spotfartitan_5_3", actors )]}
	]
	AddConversation( conversation, team, lines )



	local array =
	[
		{ dialogType = "speech", 	speakerIndex = 0,
			choices =
			[
				Voices( team, "gs_fleeplayertitan_02_1", actors )
			]
		}

//		{ dialogType = "dispatch", choices = [ Dispatch( team, "gs_fleeplayertitan_02_2" ) ] }

		{ dialogType = "speech", 	speakerIndex = 0,
			choices =
			[
				Voices( team, "gs_fleeplayertitan_02_3", actors )
			]
		}
	]
	AddConversation( "grunt_flees_titan", team, array )

	local array =
	[
		{ dialogType = "speech", 	speakerIndex = 0,
			choices =
			[
				Voices( team, "gs_fleeplayertitan_03_1", actors )
				Voices( team, "gs_fleeplayertitan_03_3", actors )
			]
		}

//		{ dialogType = "dispatch", choices = [ Dispatch( team, "gs_fleeplayertitan_03_2" ) ] }
	]
	AddConversation( "grunt_flees_titan", team, array )

	local conversation = "aichat_callout_titan"
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_spotfartitan_6_1", actors )]}
//		{ dialogType = "dispatch", 		           choices = [Dispatch( team, "gs_spotfartitan_6_2" )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_spotfartitan_7_1", actors )]}
//		{ dialogType = "dispatch",				   choices = [Dispatch( team, "gs_spotfartitan_7_2" )]}
	]
	AddConversation( conversation, team, lines )
}

function AddGlobalChatter( team, actors )
{
	//2 line dialogues
	local conversation = "aichat_global_chatter"

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment2L_01_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment2L_01_02", actors )]}
	]
	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment2L_02_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment2L_02_02", actors )]}
	]

	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment2L_03_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment2L_03_02", actors )]}
	]

	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment2L_04_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment2L_04_02", actors )]}
	]

	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment2L_05_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment2L_05_02", actors )]}
	]

	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment2L_06_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment2L_06_02", actors )]}
	]

	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment2L_07_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment2L_07_02", actors )]}
	]

	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment2L_08_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment2L_08_02", actors )]}
	]

	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment2L_09_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment2L_09_02", actors )]}
	]

	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment2L_10_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment2L_10_02", actors )]}
	]

	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment2L_11_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment2L_11_02", actors )]}
	]

	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment2L_12_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment2L_12_02", actors )]}
	]

	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment2L_13_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment2L_13_02", actors )]}
	]

	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment2L_14_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment2L_14_02", actors )]}
	]

	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment2L_15_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment2L_15_02", actors )]}
	]

	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment2L_16_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment2L_16_02", actors )]}
	]

	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment2L_17_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment2L_17_02", actors )]}
	]

	AddConversation( conversation, team, lines )


	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment2L_18_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment2L_18_02", actors )]}
	]

	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment2L_19_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment2L_19_02", actors )]}
	]

	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment2L_20_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment2L_20_02", actors )]}
	]

	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment2L_21_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment2L_21_02", actors )]}
	]

	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment2L_22_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment2L_22_02", actors )]}
	]

	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment2L_23_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment2L_23_02", actors )]}
	]

	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment2L_24_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment2L_24_02", actors )]}
	]

	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment2L_25_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment2L_25_02", actors )]}
	]

	AddConversation( conversation, team, lines )

	//3 Line dialogues
	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment3L_01_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment3L_01_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment3L_01_03", actors )]}
	]

	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment3L_02_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment3L_02_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment3L_02_03", actors )]}
	]

	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment3L_03_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment3L_03_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment3L_03_03", actors )]}
	]

	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment3L_04_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment3L_04_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment3L_04_03", actors )]}
	]

	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment3L_05_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment3L_05_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment3L_05_03", actors )]}
	]

	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment3L_06_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment3L_06_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment3L_06_03", actors )]}
	]

	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment3L_07_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment3L_07_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment3L_07_03", actors )]}
	]

	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment3L_08_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment3L_08_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment3L_08_03", actors )]}
	]

	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment3L_09_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment3L_09_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment3L_09_03", actors )]}
	]

	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment3L_10_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment3L_10_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment3L_10_03", actors )]}
	]

	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment3L_11_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment3L_11_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment3L_11_03", actors )]}
	]

	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment3L_12_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment3L_12_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment3L_12_03", actors )]}
	]

	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment3L_13_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment3L_13_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment3L_13_03", actors )]}
	]

	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment3L_14_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment3L_14_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment3L_14_03", actors )]}
	]

	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment3L_15_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment3L_15_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment3L_15_03", actors )]}
	]

	AddConversation( conversation, team, lines )

	//4 Line dialogues

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment4L_01_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment4L_01_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment4L_01_03", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment4L_01_04", actors )]}
	]

	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment4L_02_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment4L_02_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment4L_02_03", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment4L_02_04", actors )]}
	]

	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment4L_03_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment4L_03_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment4L_03_03", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment4L_03_04", actors )]}
	]

	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment4L_04_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment4L_04_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment4L_04_03", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment4L_04_04", actors )]}
	]

	AddConversation( conversation, team, lines )

	local lines =
	[
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment4L_05_01", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment4L_05_02", actors )]}
		{ dialogType = "speech", speakerIndex = 0, choices = [Voices( team, "gs_GL_comment4L_05_03", actors )]}
		{ dialogType = "speech", speakerIndex = 1, choices = [Voices( team, "gs_GL_comment4L_05_04", actors )]}
	]

	AddConversation( conversation, team, lines )
}



/**********************************************************************

	The following function are for Creating Conversations.

	Example 1:	this will create a conversation of one line but with four choices for that line. the choices will be selected randomly
		local convRef = AddConversation( "TitanReplacement", TEAM_MILITIA )
		AddVDU( convRef, "sarah" )
		AddRadio( convRef, "diag_mp_priv_19_1", "diag_mp_priv_19_2", "diag_mp_priv_19_3", "diag_mp_priv_19_4" )

	Example 2: this will create a conversation between MacAllan and Sarah
		local convRef = AddConversation( "StartAnnouncement", TEAM_MILITIA )
		AddVDU( convRef, "mac" )
		AddRadio( convRef, "diag_mp_priv_10_1" )
		AddVDU( convRef, "sarah" )
		AddRadio( convRef, "diag_mp_priv_10_2", "diag_mp_priv_10_13" )
		AddVDUHide( convRef, 1 )	// only needed if you want to delay the closing of the VDU after the previous line is spoken.

	Example 3: there are some wrappers for simple VDU conversations
		AddVDULineForSarah( "TitanReplacement", "diag_mp_priv_19_1" )	// this adds a new conversation to the TitanReplacement type


	See mp/game_state_dialog.nut for a working example.

**********************************************************************/

function Dialogue_AliasRadio( alias )
{
	return alias
}

function CreateScene( sceneName )
{
	Assert( !(sceneName in level.scenes) )

	level.scenes[sceneName] <- {}
	level.scenes[sceneName].indices <- {}
	level.scenes[sceneName].indices["neutral"] <- 0
	level.scenes[sceneName].indices[TEAM_MILITIA] <- 0
	level.scenes[sceneName].indices[TEAM_IMC] <- 0
	level.scenes[sceneName].conversations <- {}
	level.scenes[sceneName].conversations["neutral"] <- {}
	level.scenes[sceneName].conversations[TEAM_MILITIA] <- {}
	level.scenes[sceneName].conversations[TEAM_IMC] <- {}
	level.scenes[sceneName].exclusions <- {}
	level.scenes[sceneName].exclusions["neutral"] <- {}
	level.scenes[sceneName].exclusions[TEAM_MILITIA] <- {}
	level.scenes[sceneName].exclusions[TEAM_IMC] <- {}

	return sceneName // silly typo prevention when used
}

const CONVFLAG_STARTPOINT 	= 0x0001 // players can enter a scene at this point and still understand the context
const CONVFLAG_UNORDERED 	= 0x0002 // this dialog can happen at any time during the scene, it's only context is the scene itself
const CONVFLAG_ENDPOINT 	= 0x0004 // this ends the scene
const CONVFLAG_GROUP 		= 0x0008 // this groups the conversation with the previous conversation


function AddSceneConversation( sceneName, conversationName, team = "neutral", convFlags = 0 )
{
	Assert( sceneName in level.scenes )

	local scene = level.scenes[sceneName]

	Assert( !(conversationName in scene.conversations[team]), "Scene already contains conversation " + conversationName )
	Assert( conversationName in level.Conversations, "Conversation " + conversationName + " not registered" )

	Assert( !level.Conversations[conversationName].scene[team], "Conversation " + conversationName + " already part of scene " + level.Conversations[conversationName].scene[team] )

	level.Conversations[conversationName].scene[team] = sceneName

	// first line is always a start point
	if ( !scene.indices[team] )
		convFlags = convFlags | CONVFLAG_STARTPOINT

	local useIndex = scene.indices[team]

	if ( convFlags & CONVFLAG_UNORDERED )
	{
		useIndex = -1
	}
	else if ( convFlags & CONVFLAG_GROUP )
	{
		useIndex--
 		Assert( useIndex >= 0 )
 	}

	scene.conversations[team][conversationName] <- {
		index = useIndex
		flags = convFlags
	}

	if ( !(convFlags & ( CONVFLAG_UNORDERED | CONVFLAG_GROUP ) ) )
		scene.indices[team]++
}

function AddSceneExclusion( sceneName, conversationName, team = "neutral" )
{
	Assert( sceneName in level.scenes )

	local scene = level.scenes[sceneName]

	Assert( !(conversationName in scene.conversations[team]), "Scene contains conversation " + conversationName )
	Assert( conversationName in level.Conversations, "Conversation " + conversationName + " not registered" )
	Assert( !(conversationName in scene.exclusions[team]), "Conversation " + conversationName + " already excluded." )

	scene.exclusions[team][conversationName] <- {}
}


function AddConversation( conversationType, team = "neutral", lineArr = null )
{
	Assert( conversationType in level.Conversations, "Conversation " + conversationType + " not registered." )

	if ( lineArr == null )
		lineArr = []

	level.Conversations[ conversationType ][ team ].append( lineArr )

	return lineArr
}

function ReplaceConversation( conversationType, team = "neutral", lineArr = null )
{
	Assert( conversationType in level.Conversations, "Conversation " + conversationType + " not registered." )
	level.Conversations[ conversationType ][ team ].clear()
	return AddConversation( conversationType, team , lineArr )
}

function AddElement( convRef, elem )
{
	convRef.append( elem )
}

function AddVDU( convRef, vduName, vduAnim = null )
{
	Assert( vduName in level.vduModels, vduName + " isn't a valid vduName." )

	local elem = {}

	elem.dialogType <- "vdu"
	elem.vduName <- vduName
	elem.vduAnim <- vduAnim

	convRef.append( elem )
}

function AddThreadVDU( convRef, vduName, vduAnim = null )
{
	Assert( vduName in level.vduModels, vduName + " isn't a valid vduName." )

	local elem = {}

	elem.dialogType <- "vdu_thread"
	elem.vduName <- vduName
	elem.vduAnim <- vduAnim

	convRef.append( elem )
}

function AddVDUHide( convRef, delay = 0 )
{
	local elem = {}

	elem.dialogType <- "vdu"
	elem.hide <- true
	elem.vduAnim <- null
	if ( delay )
		elem.delay <- delay

	convRef.append( elem )
}

//AddRadio( convRef, alias_choice_1, alias_choice_2, ..., alias_choice_xx, delay )		// delay is optional but has to be the last argument passed
function AddRadio( ... )
{
	Assert( IsArray( vargv[0] ) )

	local convRef = vargv[0]
	local elem = {}

	elem.dialogType <- "radio"
	elem.choices <- []

	local count = vargc
	if ( IsNumber( vargv[ vargc - 1 ] ) )
	{
		count--
		elem.delay <- vargv[ vargc - 1 ]
	}

	for( local i = 1; i < count; i++ )
	{
		if ( IsArray( vargv[ i ])  )
		{
			foreach ( aliasName in vargv[ i ] )
			{
				Assert( IsString( aliasName ) )
				Assert( DoesAliasExist( aliasName ), aliasName + " doesn't exist!" )
				elem.choices.append( Dialogue_AliasRadio( aliasName ) )
			}
		}
		else
		{
			Assert( IsString( vargv[ i ] ) )
			Assert( DoesAliasExist( vargv[ i ] ), vargv[ i ] + " doesn't exist!" )
			elem.choices.append( Dialogue_AliasRadio( vargv[ i ] ) )
		}
	}

	convRef.append( elem )
}

function AddMusic( convRef, musicAlias, background = true )
{
	Assert( IsArray( convRef ) )

	local elem = {}
	elem.dialogType <- "music"
	elem.alias 		<- Dialogue_AliasRadio( musicAlias )

	if ( !background )
		elem.halt_conversation <- true

	convRef.append( elem )
}

function AddWait( convRef, minWait, maxWait = 0 )
{
	Assert( IsArray( convRef ) )

	if ( maxWait < minWait )
		maxWait = minWait
	Assert( minWait > 0 )
	Assert( minWait <= maxWait )

	local elem = {}
	elem.dialogType <- "wait"
	elem.durationMin <- minWait
	elem.durationMax <- maxWait

	convRef.append( elem )
}

function AddVDURadio( convRef, vduName, alias, vduAnim = null )
{
	if ( alias && vduAnim )
	{
		AddThreadVDU( convRef, vduName, vduAnim )
		AddRadio( convRef, alias )
		return
	}

	if ( vduAnim )
	{
		AddVDU( convRef, vduName, vduAnim )
		return
	}

	if ( alias )
	{
		AddRadio( convRef, alias )
		return
	}
}

function AddCustomVDUFunction( convRef, func )
{
	local elem = {}

	elem.dialogType <- "custom_vdu"
	elem.custom_vdu_func <- func
	convRef.append( elem )

}

function AddVDUAnimWithEmbeddedAudio( convRef, vduName, animName )
{
	AddVDURadio( convRef, vduName, null, animName )
}

function AddVDULineForSarah( convType, alias, vduAnim = null )
{
	local convRef = AddConversation( convType, TEAM_MILITIA )	// Sarah is militia
	AddVDURadio( convRef, "sarah", alias, vduAnim )
}

function AddVDULineForMacAllan( convType, alias, vduAnim = null )
{
	local convRef = AddConversation( convType, TEAM_MILITIA )	// MacAllan is militia
	AddVDURadio( convRef, "mac", alias, vduAnim )
}

function AddVDULineForBarker( convType, alias, vduAnim = null )
{
	local convRef = AddConversation( convType, TEAM_MILITIA )	// Barker is militia
	AddVDURadio( convRef, "barker", alias, vduAnim )
}

function AddVDULineForGrunt( convType, alias, vduAnim = null )
{
	local convRef = AddConversation( convType, TEAM_MILITIA )	// Grunt is militia
	AddVDURadio( convRef, "grunt", alias, vduAnim )
}

function AddVDULineForGruntAT( convType, alias, vduAnim = null )
{
	local convRef = AddConversation( convType, TEAM_MILITIA )	// Grunt_AntiTitan is militia
	AddVDURadio( convRef, "grunt_at", alias, vduAnim )
}

function AddVDULineForBish( convType, alias, vduAnim = null )
{
	local convRef = AddConversation( convType, TEAM_MILITIA )	// Bish is militia
	AddVDURadio( convRef, "bish", alias, vduAnim )
}

function AddVDULineForSpyglass( convType, alias, vduAnim = null )
{
	local convRef = AddConversation( convType, TEAM_IMC )	// IMC_soldier is IMC
	AddVDURadio( convRef, "spyglass", alias, vduAnim )
}

function AddVDULineForBlisk( convType, alias, vduAnim = null )
{
	local convRef = AddConversation( convType, TEAM_IMC )	// IMC_commander is IMC
	AddVDURadio( convRef, "blisk", alias, vduAnim )
}

function AddVDULineForGraves( convType, alias, vduAnim = null )
{
	local convRef = AddConversation( convType, TEAM_IMC )
	AddVDURadio( convRef, "graves", alias, vduAnim )
}

function AddVDUAnimWithEmbeddedAudioForSarah( convType, animName )
{
	AddVDULineForSarah( convType, null, animName )
}

function AddVDUAnimWithEmbeddedAudioForMacAllan( convType, animName )
{
	AddVDULineForMacAllan( convType, null, animName )
}

function AddVDUAnimWithEmbeddedAudioForBarker( convType, animName )
{
	AddVDULineForBarker( convType, null, animName )
}

function AddVDUAnimWithEmbeddedAudioForBish( convType, animName )
{
	AddVDULineForBish( convType, null, animName )
}

function AddVDUAnimWithEmbeddedAudioForSpyglass( convType, animName )
{
	AddVDULineForSpyglass( convType, null, animName )
}

function AddVDUAnimWithEmbeddedAudioForBlisk( convType, animName )
{
	AddVDULineForBlisk( convType, null, animName )
}

function AddVDUAnimWithEmbeddedAudioForGraves( convType, animName )
{
	AddVDULineForGraves( convType, null, animName )
}
