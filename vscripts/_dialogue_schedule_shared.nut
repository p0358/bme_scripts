function main()
{
	local array =
	[
		"aichat_hotspot_window"
		"aichat_hotspot_door"
		"aichat_hotspot_balcony"
		"aichat_hotspot_second_floor_window"
		"aichat_hotspot_corner"
		"aichat_reload"
		"aichat_move_out"
		"aichat_fan_out"
	]

	foreach ( conversation in array )
	{
		RegisterConversation( conversation, VO_PRIORITY_AI_CHATTER_LOWEST )
	}

	local array =
	[
		"killed_enemy_grunt"
		"aichat_death_friendly_grunt"
		"aichat_move_squadlead"
		"aichat_rumor_pilot"
	]

	foreach ( conversation in array )
	{
		RegisterConversation( conversation, VO_PRIORITY_AI_CHATTER_LOW )
	}

	local array =
	[
		"aichat_global_chatter"
		"aichat_squad_deplete"
		"aichat_callout_titan"
		"aichat_callout_pilot"
		"aichat_callout_pilot_dev"
		"aichat_callout_pilot_call_response"
		"aichat_engage_pilot"
		"aichat_address_pilot"
		"aichat_capturing_hardpoint"
		"aichat_captured_hardpoint"
	]

	foreach ( conversation in array )
	{
		RegisterConversation( conversation, VO_PRIORITY_AI_CHATTER )
	}

	// higher priority
	local array =
	[
		"grunt_flees_titan_building"
		"grunt_group_flees_titan"
		"grunt_flees_titan"
		"grunt_flees_titan_dev"
		"ally_pilot_down"
		"aichat_death_enemy_titan"
		"ally_titan_down"
		"ally_eject_fail"
		"aichat_titan_cheer"
		"aichat_rodeo_cheer"
		"aichat_death_enemy_titan"
		"aichat_killed_pilot"
		"aichat_spot_titan_close"
		"aichat_killed_enemy_titan"
		"aichat_grenade_incoming"
		"aichat_male_pilot_cloaked"
		"aichat_female_pilot_cloaked"
		"aichat_generic_pilot_cloaked"
	]

	foreach ( conversation in array )
	{
		RegisterConversation( conversation, VO_PRIORITY_AI_CHATTER_HIGH )
	}

}