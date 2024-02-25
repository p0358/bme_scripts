
level.animSkitData <- {}
level.animPropSkitData <- {}

function main()
{
	// Wall Slide - single character stumbles along a wall and dies
	local data = {}
	data.wait_anims <- [ "pt_dying_wallslide_zinger_idle" ]
	data.skit_anims <- [ "pt_dying_wallslide_zinger" ]
	data.sounds <- [ null ]
	data.teams <- [ 0 ]
	data.allowExecution <- [ 0 ]
	data.dieOnAbortion <- [ 0 ]
	data.weapons <- [ null ]
	data.aiType <- [ "grunt" ]
	data.silentDeath <- [ 0 ]
	level.animSkitData[ CINEMATIC_TYPES.AI_SKIT_DYING_WALLSLIDE ] <- data

	// Fight Knockback - two character fist fight. Character A dies at the end of the fight if not interrupted
	local data = {}
	data.wait_anims <- [ "pt_fight_knockback_zinger_A_idle", "pt_fight_knockback_zinger_B_idle" ]
	data.skit_anims <- [ "pt_fight_knockback_zinger_A", "pt_fight_knockback_zinger_B" ]
	data.sounds <- [ null, null ]
	data.teams <- [ 0, 1 ]
	data.allowExecution <- [ 1, 1 ]
	data.dieOnAbortion <- [ 0, 0 ]
	data.weapons <- [ null, null ]
	data.aiType <- [ "grunt", "grunt" ]
	data.silentDeath <- [ 0, 0 ]
	data.thankOnInterrupting <- [ true, true ]
	level.animSkitData[ CINEMATIC_TYPES.AI_SKIT_FIGHT_KNOCKBACK ] <- data

	// Wounded Drag - two characters. B drags A. A always dies at the end
	local data = {}
	data.wait_anims <- [ "pt_wounded_drag_zinger_A_idle", "pt_wounded_drag_zinger_B_idle" ]
	data.skit_anims <- [ "pt_wounded_drag_zinger_A", "pt_wounded_drag_zinger_B" ]
	data.sounds <- [ null, null ]
	data.teams <- [ 0, 0 ]
	data.allowExecution <- [ 0, 1 ]
	data.dieOnAbortion <- [ 1, 0 ]
	data.weapons <- [ null, null ]
	data.aiType <- [ "grunt", "grunt" ]
	data.silentDeath <- [ 0, 0 ]
	level.animSkitData[ CINEMATIC_TYPES.AI_SKIT_WOUNDED_DRAG ] <- data

	// Wounded Carry - two character. B carries A. A always dies
	local data = {}
	data.wait_anims <- [ "pt_wounded_carry_zinger_A_idle", "pt_wounded_carry_zinger_B_idle" ]
	data.skit_anims <- [ "pt_wounded_carry_zinger_A", "pt_wounded_carry_zinger_B" ]
	data.sounds <- [ null, null ]
	data.teams <- [ 0, 0 ]
	data.allowExecution <- [ 0, 1 ]
	data.dieOnAbortion <- [ 1, 0 ]
	data.weapons <- [ null, null ]
	data.aiType <- [ "grunt", "grunt" ]
	data.silentDeath <- [ 0, 0 ]
	level.animSkitData[ CINEMATIC_TYPES.AI_SKIT_WOUNDED_CARRY ] <- data

	// Prisoner Kill - two characters. A is dead prisoner, B pats down guy A
	local data = {}
	data.wait_anims <- [ "pt_prisoner_kill_zinger_A_idle", "pt_prisoner_kill_zinger_B_idle" ]
	data.skit_anims <- [ "pt_prisoner_kill_zinger_A", "pt_prisoner_kill_zinger_B" ]
	data.sounds <- [ null, null ]
	data.teams <- [ 0, 1 ]
	data.allowExecution <- [ 0, 1 ]
	data.dieOnAbortion <- [ 1, 0 ]
	data.weapons <- [ null, null ]
	data.aiType <- [ "grunt", "grunt" ]
	data.silentDeath <- [ 0, 0 ]
	level.animSkitData[ CINEMATIC_TYPES.AI_SKIT_PRISONER_KILL ] <- data

	// Shotgun Wallslam - two characters. A gets shotgun blasted into the wall and dies, B shoots A
	local data = {}
	data.wait_anims <- [ "pt_shotgun_wallslam_skit_A_idle", "pt_shotgun_wallslam_skit_B_idle" ]
	data.skit_anims <- [ "pt_shotgun_wallslam_skit_A", "pt_shotgun_wallslam_skit_B" ]
	data.sounds <- [ "ai_skit_pt_shotgun_wallslam_Victim_comp", "ai_skit_pt_shotgun_wallslam_Shooter_comp" ]
	data.teams <- [ 0, 1 ]
	data.allowExecution <- [ 1, 1 ]
	data.dieOnAbortion <- [ 0, 0 ]
	data.weapons <- [ null, "mp_weapon_shotgun" ]
	data.aiType <- [ "grunt", "grunt" ]
	data.silentDeath <- [ 0, 0 ]
	data.thankOnInterrupting <- [ true, false ]
	level.animSkitData[ CINEMATIC_TYPES.AI_SKIT_SHOTGUN_WALLSLAM ] <- data

	// Spectre Speed Kill - three characters. Spectre kills 2 grunts
	local data = {}
	data.wait_anims <- [ "sp_spectre_speedkill_skit_idle", "pt_spectre_speedkill_skit_A_idle", "pt_spectre_speedkill_skit_B_idle" ]
	data.skit_anims <- [ "sp_spectre_speedkill_skit", "pt_spectre_speedkill_skit_A", "pt_spectre_speedkill_skit_B" ]
	data.sounds <- [ "ai_skit_spectre_speedkill_Spectre_comp", "ai_skit_spectre_speedkill_Soldier1_comp", "ai_skit_spectre_speedkill_Soldier2_comp" ]
	data.teams <- [ 0, 1, 1 ]
	data.allowExecution <- [ 1, 1, 1 ]
	data.dieOnAbortion <- [ 0, 0, 0 ]
	data.weapons <- [ null, null, null ]
	data.aiType <- [ "spectre", "grunt", "grunt" ]
	data.silentDeath <- [ 0, 0, 0 ]
	data.thankOnInterrupting <- [ false, true, true ]
	level.animSkitData[ CINEMATIC_TYPES.AI_SKIT_SPECTRE_SPEEDKILL ] <- data

	// Spectre Neck Snap - two characters. Spectre lifts grunt, breaks his neck, and tosses him away
	local data = {}
	data.wait_anims <- [ "sp_spectre_kill_skit_idle", "pt_spectre_kill_skit_idle" ]
	data.skit_anims <- [ "sp_spectre_kill_skit", "pt_spectre_kill_skit" ]
	data.sounds <- [ "ai_skit_spectre_kill_Spectre_comp", "ai_skit_spectre_kill_Soldier_comp" ]
	data.teams <- [ 0, 1 ]
	data.allowExecution <- [ 1, 0 ]
	data.dieOnAbortion <- [ 0, 1 ]
	data.weapons <- [ null, null ]
	data.aiType <- [ "spectre", "grunt" ]
	data.silentDeath <- [ 0, 1 ]
	data.thankOnInterrupting <- [ false, true ]
	level.animSkitData[ CINEMATIC_TYPES.AI_SKIT_SPECTRE_NECK_SNAP ] <- data

	// Loot Corpse - three characters. One guy loots a corpse while the other guy covers him
	local data = {}
	data.wait_anims <- [ "pt_loot_corpse_skit_idle", "pt_loot_corpse_skit_A_idle", "pt_loot_corpse_skit_B_idle" ]
	data.skit_anims <- [ "pt_loot_corpse_skit", "pt_loot_corpse_skit_A", "pt_loot_corpse_skit_B" ]
	data.sounds <- [ "ai_skit_pt_loot_corpse_Corpse_comp", "ai_skit_pt_loot_corpse_Soldier1_comp", "ai_skit_pt_loot_corpse_Soldier2_comp" ]
	data.teams <- [ 0, 1, 1 ]
	data.allowExecution <- [ 0, 0, 1 ]
	data.dieOnAbortion <- [ 1, 0, 0 ]
	data.weapons <- [ null, null, null ]
	data.aiType <- [ "grunt", "grunt", "grunt" ]
	data.silentDeath <- [ 0, 0, 0 ]
	level.animSkitData[ CINEMATIC_TYPES.AI_SKIT_LOOT_CORPSE ] <- data

	// Brawl - three characters. One guy fights 2 guys and wins
	local data = {}
	data.wait_anims <- [ "pt_brawl_A_skit_idle", "pt_brawl_B_skit_idle", "pt_brawl_C_skit_idle" ]
	data.skit_anims <- [ "pt_brawl_A_skit", "pt_brawl_B_skit", "pt_brawl_C_skit" ]
	data.sounds <- [ "ai_skit_pt_brawl_Soldier3_comp", "ai_skit_pt_brawl_Soldier2_comp", "ai_skit_pt_brawl_Soldier1_comp" ]
	data.teams <- [ 0, 1, 0 ]
	data.allowExecution <- [ 1, 1, 1 ]
	data.dieOnAbortion <- [ 0, 0, 0 ]
	data.weapons <- [ null, null, null ]
	data.aiType <- [ "grunt", "grunt", "grunt" ]
	data.silentDeath <- [ 0, 0, 0 ]
	data.thankOnInterrupting <- [ true, true, true ]
	level.animSkitData[ CINEMATIC_TYPES.AI_SKIT_BRAWL ] <- data

	// Spectre knocks a soldier down, walks away a little, then notices the soldier getting up and blindfire kills him
	local data = {}
	data.wait_anims <- [ "sp_blindfire_idle_skit", "pt_blindfire_idle_skit" ]
	data.skit_anims <- [ "sp_blindfire_skit", "pt_blindfire_skit" ]
	data.sounds <- [ null, null ]
	data.teams <- [ 0, 1 ]
	data.allowExecution <- [ 1, 0 ]
	data.dieOnAbortion <- [ 0, 1 ]
	data.weapons <- [ "mp_weapon_rspn101", "mp_weapon_hemlok" ]
	data.aiType <- [ "spectre", "grunt" ]
	data.silentDeath <- [ 0, 0 ]
	level.animSkitData[ CINEMATIC_TYPES.AI_SKIT_SPECTRE_BLINDFIRE ] <- data

	// Spectre holds a soldier up and punches him in the chest, ripping some guts out
	local data = {}
	data.wait_anims <- [ "sp_spectre_chestpunch_idle", "pt_spectre_chestpunch_idle" ]
	data.skit_anims <- [ "sp_spectre_chestpunch", "pt_spectre_chestpunch" ]
	data.sounds <- [ null, null ]
	data.teams <- [ 0, 1 ]
	data.allowExecution <- [ 1, 0 ]
	data.dieOnAbortion <- [ 0, 1 ]
	data.weapons <- [ null, null ]
	data.aiType <- [ "spectre", "grunt" ]
	data.silentDeath <- [ 0, 1 ]
	data.thankOnInterrupting <- [ false, true ]
	level.animSkitData[ CINEMATIC_TYPES.AI_SKIT_SPECTRE_CHESTPUNCH ] <- data

	// Spectre throws a soldier down and stomps his head
	local data = {}
	data.wait_anims <- [ "sp_curbstomp_idle_skit", "pt_curbstomp_idle_skit" ]
	data.skit_anims <- [ "sp_curbstomp_skit", "pt_curbstomp_skit" ]
	data.sounds <- [ null, null ]
	data.teams <- [ 0, 1 ]
	data.allowExecution <- [ 1, 0 ]
	data.dieOnAbortion <- [ 0, 1 ]
	data.weapons <- [ null, "mp_weapon_rspn101" ]
	data.aiType <- [ "spectre", "grunt" ]
	data.silentDeath <- [ 0, 0 ]
	level.animSkitData[ CINEMATIC_TYPES.AI_SKIT_SPECTRE_CURBSTOMP ] <- data

	// Spectre smashes a grunts head repeatedly into a waist-high railing
	local data = {}
	data.wait_anims <- [ "sp_spectre_railing_smash_idle", "pt_spectre_railing_smash_idle" ]
	data.skit_anims <- [ "sp_spectre_railing_smash", "pt_spectre_railing_smash" ]
	data.sounds <- [ null, null ]
	data.teams <- [ 0, 1 ]
	data.allowExecution <- [ 0, 0 ]
	data.dieOnAbortion <- [ 0, 1 ]
	data.weapons <- [ "mp_weapon_r97", null ]
	data.aiType <- [ "spectre", "grunt" ]
	data.silentDeath <- [ 0, 1 ]
	level.animSkitData[ CINEMATIC_TYPES.AI_SKIT_SPECTRE_RAILING_SMASH ] <- data

	// Spectre hold grunt over his head, slams him down on a counter then slides him across it
	local data = {}
	data.wait_anims <- [ "sp_barslam_skit_loop", "pt_barslam_skit_loop" ]
	data.skit_anims <- [ "sp_barslam_skit_end", "pt_barslam_skit_end" ]
	data.sounds <- [ null, null ]
	data.teams <- [ 0, 1 ]
	data.allowExecution <- [ 1, 0 ]
	data.dieOnAbortion <- [ 1, 1 ]
	data.weapons <- [ null, null ]
	data.aiType <- [ "spectre", "grunt" ]
	data.silentDeath <- [ 0, 1 ]
	level.animSkitData[ CINEMATIC_TYPES.AI_SKIT_SPECTRE_BAR_FIGHT ] <- data


	// Spectre throws a grunt through a window
	local data = {}
	data.wait_anims <- [ "sp_spectre_windowtoss_idle", "pt_spectre_windowtoss_idle" ]
	data.skit_anims <- [ "sp_spectre_windowtoss", "pt_spectre_windowtoss" ]
	data.sounds <- [ null, null ]
	data.teams <- [ 0, 1 ]
	data.allowExecution <- [ 0, 0 ]
	data.dieOnAbortion <- [ 1, 1 ]
	data.weapons <- [ null, null ]
	data.aiType <- [ "spectre", "grunt" ]
	data.silentDeath <- [ 0, 1 ]
	data.thankOnInterrupting <- [ false, true ]
	level.animSkitData[ CINEMATIC_TYPES.AI_SKIT_SPECTRE_WINDOW_THROW ] <- data


	// Dying Spectre crawling towards a soldier, who eventually kills it
	local data = {}
	data.wait_anims <- [ "sp_spectre_crawl_idle", "pt_spectre_crawl_idle" ]
	data.skit_anims <- [ "sp_spectre_crawl", "pt_spectre_crawl" ]
	data.sounds <- [ null, null ]
	data.teams <- [ 0, 1 ]
	data.allowExecution <- [ 0, 1 ]
	data.dieOnAbortion <- [ 1, 0 ]
	data.weapons <- [ null, "mp_weapon_rspn101" ]
	data.aiType <- [ "spectre", "grunt" ]
	data.silentDeath <- [ 0, 0 ]
	data.thankOnInterrupting <- [ false, true ]
	level.animSkitData[ CINEMATIC_TYPES.AI_SKIT_SPECTRE_CRAWL ] <- data

	// Soldier struggles to finish off a Spectre who keeps coming at him, eventually kills it
	local data = {}
	data.wait_anims <- [ "sp_spectre_zombiedrag_idle", "pt_spectre_zombiedrag_idle" ]
	data.skit_anims <- [ "sp_spectre_zombiedrag", "pt_spectre_zombiedrag" ]
	data.sounds <- [ null, null ]
	data.teams <- [ 0, 1 ]
	data.allowExecution <- [ 0, 0 ]
	data.dieOnAbortion <- [ 1, 0 ]
	data.weapons <- [ null, "mp_weapon_shotgun" ]
	data.aiType <- [ "spectre", "grunt" ]
	data.silentDeath <- [ 0, 0 ]
	data.thankOnInterrupting <- [ false, true ]
	level.animSkitData[ CINEMATIC_TYPES.AI_SKIT_SPECTRE_ZOMBIEDRAG ] <- data

	// Two soldiers melee fighting, one flips the other over his shoulder onto the ground and finishes with a rifle shot
	// A is the victim, B is the winner
	local data = {}
	data.wait_anims <- [ "pt_fight_flip_skit_A_idle", "pt_fight_flip_skit_B_idle" ]
	data.skit_anims <- [ "pt_fight_flip_skit_A", "pt_fight_flip_skit_B" ]
	data.sounds <- [ null, null ]
	data.teams <- [ 0, 1 ]
	data.allowExecution <- [ 0, 1 ]
	data.dieOnAbortion <- [ 1, 0 ]
	data.weapons <- [ null, "mp_weapon_rspn101" ]
	data.aiType <- [ "grunt", "grunt" ]
	data.silentDeath <- [ 0, 0 ]
	data.thankOnInterrupting <- [ true, true ]
	level.animSkitData[ CINEMATIC_TYPES.AI_SKIT_MELEE_FLIP ] <- data

	// Spectre bodyslams an grunt TO THE GROUND
	local data = {}
	data.wait_anims <- [ "sp_tablesmash_skit_loop", "pt_tablesmash_skit_loop" ]
	data.skit_anims <- [ "sp_tablesmash_skit_end", "pt_tablesmash_skit_end" ]
	data.sounds <- [ null, null ]
	data.teams <- [ 0, 1 ]
	data.allowExecution <- [ 0, 0 ]
	data.dieOnAbortion <- [ 0, 1 ]
	data.weapons <- [ null, null ]
	data.aiType <- [ "spectre", "grunt" ]
	data.silentDeath <- [ 0, 1 ]
	level.animSkitData[ CINEMATIC_TYPES.AI_SKIT_SPECTRE_BODYSLAM ] <- data

	LoadDataPropSkits()
}


//******** This stuff is meant mainly for intros, these will spawn props, not AI
function LoadDataPropSkits()
{
	// casual standing idle A
	local data = CreatePropSkitTable()
	data.skit_anims = [ "CASUAL_idleA" ]
	data.wait_anims = []
	data.sounds = [ null ]
	data.teams = [ 0 ]
	data.weapons = [ null ]
	data.aiType = [ "grunt" ]
	level.animPropSkitData[ CINEMATIC_TYPES.PROP_SKIT_CASUAL_IDLE_A ] <- data

	// casual standing idle B
	local data = CreatePropSkitTable()
	data.skit_anims = [ "CASUAL_idleB" ]
	data.wait_anims = []
	data.sounds = [ null ]
	data.teams = [ 0 ]
	data.weapons = [ null ]
	data.aiType = [ "grunt" ]
	level.animPropSkitData[ CINEMATIC_TYPES.PROP_SKIT_CASUAL_IDLE_B ] <- data

	// casual standing idle cqb
	local data = CreatePropSkitTable()
	data.skit_anims = [ "CQB_Idle_Casual_noloop" ]
	data.wait_anims = []
	data.sounds = [ null ]
	data.teams = [ 0 ]
	data.weapons = [ null ]
	data.aiType = [ "grunt" ]
	level.animPropSkitData[ CINEMATIC_TYPES.PROP_SKIT_CASUAL_IDLE_CQB ] <- data

	// Patrol walk bored - a short distance - not looping
	local data = CreatePropSkitTable()
	data.skit_anims = [ "patrol_walk_bored_scripted" ]
	data.wait_anims = [ "patrol_walk_bored_scripted_startidle" ]
	data.end_anims = [ "patrol_walk_bored_scripted_endidle" ]
	data.sounds = [ null ]
	data.teams = [ 0 ]
	data.weapons = [ null ]
	data.aiType = [ "grunt" ]
	level.animPropSkitData[ CINEMATIC_TYPES.PROP_SKIT_PATROL_WALK_BORED ] <- data

	// Patrol walk high port - a short distance - not looping
	local data = CreatePropSkitTable()
	data.skit_anims = [ "patrol_walk_highport_scripted" ]
	data.wait_anims = [ "patrol_walk_highport_scripted_startidle" ]
	data.end_anims = [ "patrol_walk_highport_scripted_endidle" ]
	data.sounds = [ null ]
	data.teams = [ 0 ]
	data.weapons = [ null ]
	data.aiType = [ "grunt" ]
	level.animPropSkitData[ CINEMATIC_TYPES.PROP_SKIT_PATROL_WALK_HIGHPORT ] <- data

	// Patrol walk low port - a short distance - not looping
	local data = CreatePropSkitTable()
	data.skit_anims = [ "patrol_walk_lowport_scripted" ]
	data.wait_anims = [ "patrol_walk_lowport_scripted_startidle" ]
	data.end_anims = [ "patrol_walk_lowport_scripted_endidle" ]
	data.sounds = [ null ]
	data.teams = [ 0 ]
	data.weapons = [ null ]
	data.aiType = [ "grunt" ]
	level.animPropSkitData[ CINEMATIC_TYPES.PROP_SKIT_PATROL_WALK_LOWPORT ] <- data

	// Guy stands at railing, turns and salutes - not looping
	local data = CreatePropSkitTable()
	data.skit_anims = [ "pt_O2_briefing_crew_L" ]
	data.wait_anims = []
	data.sounds = [ null ]
	data.teams = [ 0 ]
	data.weapons = [ null ]
	data.aiType = [ "grunt" ]
	level.animPropSkitData[ CINEMATIC_TYPES.PROP_SKIT_RAILING_STAND_SALUTE ] <- data

	// 2 Guy standing around talking - not looping
	local data = CreatePropSkitTable()
	data.skit_anims = [ "pt_bored_stand_talker_A_noloop", "pt_bored_stand_talker_B_noloop" ]
	data.wait_anims = [ "pt_bored_stand_talker_A_noloop", "pt_bored_stand_talker_B_noloop" ]
	data.sounds = [ null, null ]
	data.teams = [ 0, 0 ]
	data.weapons = [ null, null ]
	data.aiType = [ "grunt", "grunt" ]
	level.animPropSkitData[ CINEMATIC_TYPES.PROP_SKIT_STANDING_TALKERS ] <- data

	//2 guys searching a hole
	local data = CreatePropSkitTable()
	data.wait_anims = 	[ "pt_search_hole_wait_A", 		"pt_search_hole_wait_B" ]
	data.skit_anims = 	[ "pt_search_hole_walkup_A", 	"pt_search_hole_walkup_B" ]
	data.idle_anims <- 	[ "pt_search_hole_idle_A", 		"pt_search_hole_idle_B" ]
	data.end_anims = 	[ "pt_search_hole_walkback_A", 	"pt_search_hole_walkback_B" ]
	data.idle_length <- 13
	data.sounds = [ null, null ]
	data.teams = [ 0, 0 ]
	data.weapons = [ null, null ]
	data.aiType = [ "grunt", "grunt" ]
	level.animPropSkitData[ CINEMATIC_TYPES.PROP_SKIT_SEARCH_HOLE ] <- data
}

function CreatePropSkitTable()
{
	local data = {}
	data.skit_anims <- []
	data.wait_anims <- []
	data.end_anims 	<- []
	data.wait_length <- 3
	data.end_length <- 4
	data.sounds 	<- []
	data.teams 		<- []
	data.weapons 	<- []
	data.aiType 	<- []

	return data
}

function EntitiesDidLoad()
{
	Assert ( IsServer() )
	if ( !IsMultiplayer() )
		return

	foreach( type, data in level.animSkitData )
	{
		Assert( "wait_anims" in data )
		Assert( data.wait_anims.len() > 0 )

		Assert( "skit_anims" in data )
		Assert( data.skit_anims.len() > 0 )

		Assert( "sounds" in data )
		Assert( data.sounds.len() == data.skit_anims.len() )

		Assert( "teams" in data )
		Assert( data.teams.len() == data.skit_anims.len() )

		Assert( "allowExecution" in data )
		Assert( data.allowExecution.len() == data.skit_anims.len() )

		Assert( "dieOnAbortion" in data )
		Assert( data.dieOnAbortion.len() == data.skit_anims.len() )

		Assert( "weapons" in data )
		Assert( data.weapons.len() == data.skit_anims.len() )

		Assert( "aiType" in data )
		Assert( data.aiType.len() == data.skit_anims.len() )
		foreach( val in data.aiType )
			Assert( val == "grunt" || val == "spectre" )

		foreach( anim in data.wait_anims )
			CreateSimpleFlightAnalysis( TEAM_IMC_GRUNT_MDL, anim )

		foreach( anim in data.skit_anims )
			CreateSimpleFlightAnalysis( TEAM_IMC_GRUNT_MDL, anim )
	}

	foreach( type, data in level.animPropSkitData )
	{
		Assert( "wait_anims" in data )

		Assert( "skit_anims" in data )
		Assert( data.skit_anims.len() > 0 )

		Assert( "sounds" in data )
		Assert( data.sounds.len() == data.skit_anims.len() )

		Assert( "teams" in data )
		Assert( data.teams.len() == data.skit_anims.len() )

		Assert( "weapons" in data )
		Assert( data.weapons.len() == data.skit_anims.len() )

		Assert( "aiType" in data )
		Assert( data.aiType.len() == data.skit_anims.len() )
		foreach( val in data.aiType )
			Assert( val == "grunt" )

		foreach( anim in data.skit_anims )
			CreateSimpleFlightAnalysis( TEAM_IMC_GRUNT_MDL, anim )
	}
}