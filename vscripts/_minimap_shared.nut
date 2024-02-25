function main()
{
	level.minimapMaterials <- {}
	level.minimapMaterialsIndexes <- []
	level.allowRegisterMinimapMaterials <- true

	RegisterMinimapMaterial( "minimap_default", "vgui/hud/minimap_default" )

	RegisterMinimapMaterial( "hardpoint_neutral", "vgui/hud/hardpoint_neutral" )
	RegisterMinimapMaterial( "hardpoint_friendly", "vgui/hud/hardpoint_friendly" )
	RegisterMinimapMaterial( "hardpoint_enemy", "vgui/hud/hardpoint_enemy" )

	RegisterMinimapMaterial( "objective_a", "vgui/HUD/minimap_objective_a_neutral" )
	RegisterMinimapMaterial( "objective_a_friendly", "vgui/HUD/minimap_objective_a_friendly" )
	RegisterMinimapMaterial( "objective_a_enemy", "vgui/HUD/minimap_objective_a_enemy" )

	RegisterMinimapMaterial( "objective_b", "vgui/HUD/minimap_objective_b_neutral" )
	RegisterMinimapMaterial( "objective_b_friendly", "vgui/HUD/minimap_objective_b_friendly" )
	RegisterMinimapMaterial( "objective_b_enemy", "vgui/HUD/minimap_objective_b_enemy" )

	RegisterMinimapMaterial( "refuel_pump", "vgui/HUD/minimap_objective_a_neutral" )
	RegisterMinimapMaterial( "refuel_gush_friendly", "vgui/HUD/minimap_objective_a_friendly" )
	RegisterMinimapMaterial( "refuel_gush_enemy", "vgui/HUD/minimap_objective_a_enemy" )

	RegisterMinimapMaterial( "im_controlpanel_neutral", "vgui/hud/threathud_control_neutral" )
	RegisterMinimapMaterial( "im_controlpanel_friendly", "vgui/hud/threathud_control_friendly" )
	RegisterMinimapMaterial( "im_controlpanel_enemy", "vgui/hud/threathud_control_enemy" )

	RegisterMinimapMaterial( "turret_neutral", "vgui/hud/threathud_turret_neutral" )
	RegisterMinimapMaterial( "turret_friendly", "vgui/hud/threathud_turret_friendly" )
	RegisterMinimapMaterial( "turret_enemy", "vgui/hud/threathud_turret_enemy" )

	RegisterMinimapMaterial( "LZ_neutral", "vgui/HUD/minimap_objective_a_neutral" )
	RegisterMinimapMaterial( "LZ_friendly", "vgui/HUD/minimap_lz_friendly" )
	RegisterMinimapMaterial( "LZ_enemy", "vgui/HUD/minimap_lz_enemy" )

	RegisterMinimapMaterial( "dropship_neutral", "vgui/HUD/minimap_objective_a_neutral" )
	RegisterMinimapMaterial( "dropship_friendly", "vgui/HUD/threathud_bomber_friendly" )
	RegisterMinimapMaterial( "dropship_enemy", "vgui/HUD/threathud_bomber_enemy" )

	RegisterMinimapMaterial( "VIP_neutral", "vgui/hud/minimap_objective_a_neutral" )
	RegisterMinimapMaterial( "VIP_friendly", "vgui/HUD/minimap_vip_friendly" )
	RegisterMinimapMaterial( "VIP_enemy", "vgui/HUD/minimap_vip_enemy" )

	RegisterMinimapMaterial( "goal_neutral", "vgui/hud/minimap_objective_a_neutral" )
	RegisterMinimapMaterial( "goal_friendly", "vgui/HUD/minimap_goal_friendly" )
	RegisterMinimapMaterial( "goal_enemy", "vgui/HUD/minimap_goal_enemy" )

	RegisterMinimapMaterial( "hardpoint_neutral_a", "vgui/HUD/capture_point_minimap_neutral_a" )
	RegisterMinimapMaterial( "hardpoint_friendly_a", "vgui/HUD/capture_point_minimap_blue_a" )
	RegisterMinimapMaterial( "hardpoint_enemy_a", "vgui/HUD/capture_point_minimap_orange_a" )

	RegisterMinimapMaterial( "hardpoint_neutral_b", "vgui/HUD/capture_point_minimap_neutral_b" )
	RegisterMinimapMaterial( "hardpoint_friendly_b", "vgui/HUD/capture_point_minimap_blue_b" )
	RegisterMinimapMaterial( "hardpoint_enemy_b", "vgui/HUD/capture_point_minimap_orange_b" )

	RegisterMinimapMaterial( "hardpoint_neutral_c", "vgui/HUD/capture_point_minimap_neutral_c" )
	RegisterMinimapMaterial( "hardpoint_friendly_c", "vgui/HUD/capture_point_minimap_blue_c" )
	RegisterMinimapMaterial( "hardpoint_enemy_c", "vgui/HUD/capture_point_minimap_orange_c" )

	Globalize( GetMinimapMaterial )

	if ( IsServer() )
	{
		Globalize( UpdatePlayerMinimapMaterials )

		AddSpawnCallback( "npc_soldier", Minimap_OnNPCSpawn )
		AddSpawnCallback( "npc_spectre", Minimap_OnNPCSpawn )
		AddSpawnCallback( "npc_titan", Minimap_OnNPCSpawn )

		AddCallback_OnClientConnecting( Minimap_OnPlayerConnecting )

//		Minimap_PrecacheMaterial( "vgui/circle" )
		Minimap_PrecacheMaterial( "vgui/HUD/firingPing" )
		Minimap_PrecacheMaterial( "vgui/HUD/threathud_friendly_soldier" )
		Minimap_PrecacheMaterial( "vgui/HUD/threathud_enemy_soldier" )
		Minimap_PrecacheMaterial( "vgui/HUD/threathud_friendly_titan" )
		Minimap_PrecacheMaterial( "vgui/HUD/threathud_party_titan" )
		Minimap_PrecacheMaterial( "vgui/HUD/threathud_enemy_titan" )
		Minimap_PrecacheMaterial( "vgui/HUD/threathud_friendly_runner" )
		Minimap_PrecacheMaterial( "vgui/HUD/threathud_party_runner" )
		Minimap_PrecacheMaterial( "vgui/HUD/threathud_enemy_runner" )

		//Gamemode specific minimap icons. Long term need better way of doing this.
		Minimap_PrecacheMaterial( MFD_MINIMAP_PENDING_MARK_FRIENDLY_MATERIAL )
		Minimap_PrecacheMaterial( MFD_MINIMAP_FRIENDLY_MATERIAL )
		Minimap_PrecacheMaterial( MFD_MINIMAP_ENEMY_MATERIAL )

		// coop PreCaches
		Minimap_PrecacheMaterial( "vgui/HUD/titanFiringPing" )	// used in coop to mark the general area where enemies will spawn.
		Minimap_PrecacheMaterial( "vgui/HUD/coop/coop_harvester" )
		Minimap_PrecacheMaterial( "vgui/HUD/coop/minimap_coop_nuke_titan" )
		Minimap_PrecacheMaterial( "vgui/HUD/coop/minimap_coop_emp_titan" )
		Minimap_PrecacheMaterial( "vgui/HUD/coop/minimap_coop_mortar_titan" )
		Minimap_PrecacheMaterial( "vgui/HUD/coop/minimap_coop_titan" )
		Minimap_PrecacheMaterial( "vgui/hud/coop/coop_ammo_locker_icon" )
		Minimap_PrecacheMaterial( "vgui/HUD/cloak_drone_minimap_orange" )
		Minimap_PrecacheMaterial( "vgui/HUD/sniper_minimap_orange" )
		Minimap_PrecacheMaterial( "vgui/HUD/coop/minimap_coop_turret" )
		Minimap_PrecacheMaterial( "vgui/HUD/coop/minimap_coop_p1" )
		Minimap_PrecacheMaterial( "vgui/HUD/coop/minimap_coop_p2" )
		Minimap_PrecacheMaterial( "vgui/HUD/coop/minimap_coop_p3" )
		Minimap_PrecacheMaterial( "vgui/HUD/coop/minimap_coop_p4" )


		level.minimapEntityNames <- {}
	}

	level.allowRegisterMinimapMaterials = false
}


function RegisterMinimapMaterial( materialRef, material )
{
	Assert( !( materialRef in level.minimapMaterials ) )
	Assert( level.allowRegisterMinimapMaterials )

	level.minimapMaterials[ materialRef ] <- material

	if( IsServer() )
		Minimap_PrecacheMaterial( material )
	/*
	if ( IsClient() )
		PrecacheMinimapMaterial( material )
	*/
}

function GetMinimapMaterial( materialRef )
{
	return level.minimapMaterials[ materialRef ]
}


function Minimap_OnPlayerConnecting( player )
{
}

const MINIMAP_TITAN_SCALE = 0.15
const MINIMAP_PILOT_SCALE = 0.075
//coop = x * 0.572
const MINIMAP_TITAN_SCALE_COOP 		= 0.065
const MINIMAP_PILOT_SCALE_COOP		= 0.065
function UpdatePlayerMinimapMaterials( player )
{
	local titanscale = MINIMAP_TITAN_SCALE
	local pilotscale = MINIMAP_PILOT_SCALE
	local friendlyTitanMaterial = "vgui/HUD/threathud_friendly_titan"
	local friendlyPilotMaterial = "vgui/HUD/threathud_friendly_runner"
	local partyTitanMaterial = "vgui/HUD/threathud_party_titan"
	local partyPilotMaterial = "vgui/HUD/threathud_party_runner"
	local enemyTitanMaterial = "vgui/HUD/threathud_enemy_titan"

	player.Minimap_SetClampToEdge( true )
	player.Minimap_SetAlignUpright( false )

	if ( GAMETYPE == COOPERATIVE )
	{
		local playerIndex = player.GetEntIndex()
		Assert( playerIndex > 0 && playerIndex <= COOP_MAX_PLAYER_COUNT )
		local minimapMaterial = "vgui/hud/coop/minimap_coop_p" + playerIndex
		friendlyTitanMaterial = minimapMaterial
		friendlyPilotMaterial = minimapMaterial
		partyTitanMaterial = minimapMaterial
		partyPilotMaterial = minimapMaterial
		enemyTitanMaterial = "vgui/HUD/coop/minimap_coop_titan"

		titanscale = MINIMAP_TITAN_SCALE_COOP
		pilotscale = MINIMAP_PILOT_SCALE_COOP
		player.Minimap_SetAlignUpright( true )
	}
	if ( player.IsTitan() )
	{
		player.Minimap_SetFriendlyMaterial( friendlyTitanMaterial )
		player.Minimap_SetPartyMemberMaterial( partyTitanMaterial )
		player.Minimap_SetEnemyMaterial( enemyTitanMaterial )
		player.Minimap_SetObjectScale( titanscale )
		player.Minimap_SetZOrder( 100 )
	}
	else
	{
		player.Minimap_SetFriendlyMaterial( friendlyPilotMaterial )
		player.Minimap_SetPartyMemberMaterial( partyPilotMaterial )
		player.Minimap_SetEnemyMaterial( "vgui/HUD/threathud_enemy_runner" )
		player.Minimap_SetObjectScale( pilotscale )
		player.Minimap_SetZOrder( 200 )
	}
}

const MINIMAP_MINION_SCALE = 0.035
const MINIMAP_MINION_SCALE_COOP = 0.021
function Minimap_OnNPCSpawn( npc )
{
	local friendlyMaterial = "vgui/HUD/threathud_friendly_soldier"
	local enemyMaterial = "vgui/HUD/threathud_enemy_soldier"
	local minionscale = MINIMAP_MINION_SCALE
	local titanscale = MINIMAP_TITAN_SCALE

	if ( GAMETYPE == COOPERATIVE )
	{
		minionscale = MINIMAP_MINION_SCALE_COOP
		titanscale = MINIMAP_TITAN_SCALE_COOP
	}

	local scale = minionscale
	if ( npc.IsTitan() )
	{
		friendlyMaterial = "vgui/HUD/threathud_friendly_titan"
		npc.Minimap_SetPartyMemberMaterial( "vgui/HUD/threathud_party_titan" )
		if ( GAMETYPE == COOPERATIVE )
		{
			enemyMaterial = "vgui/HUD/coop/minimap_coop_titan"
			npc.Minimap_SetAlignUpright( true )
		}
		else
			enemyMaterial = "vgui/HUD/threathud_enemy_titan"
		scale = titanscale
	}

	npc.Minimap_SetFriendlyMaterial( friendlyMaterial )
	npc.Minimap_SetBossPlayerMaterial( friendlyMaterial )
	npc.Minimap_SetEnemyMaterial( enemyMaterial )
	npc.Minimap_SetObjectScale( scale )
	npc.Minimap_SetClampToEdge( true )
	npc.Minimap_SetZOrder( 10 )
}
