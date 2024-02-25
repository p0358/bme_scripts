/*
	TRACE_MASK_SOLID				// everything that is normally solid
	TRACE_MASK_PLAYERSOLID			// everything that blocks player movement
	TRACE_MASK_TITANSOLID			// everything that blocks titan movement
	TRACE_MASK_NPCSOLID				// blocks npc movement
	TRACE_MASK_NPCFLUID				// blocks fluid movement
	TRACE_MASK_WATER				// water physics in these contents
	TRACE_MASK_OPAQUE				// everything that blocks lighting
	TRACE_MASK_OPAQUE_AND_NPCS		// everything that blocks lighting, but with monsters added.
	TRACE_MASK_BLOCKLOS				// everything that blocks line of sight for AI
	TRACE_MASK_BLOCKLOS_AND_NPCS	// everything that blocks line of sight for AI plus NPCs
	TRACE_MASK_VISIBLE				// everything that blocks line of sight for players
	TRACE_MASK_VISIBLE_AND_NPCS		// everything that blocks line of sight for players, but with monsters added.
	TRACE_MASK_SHOT					// bullets see these as solid
	TRACE_MASK_SHOT_BRUSHONLY		// bullets see these as solid, except monsters (world+brush only)
	TRACE_MASK_SHOT_HULL			// non-raycasted weapons see this as solid (includes grates)
	TRACE_MASK_SHOT_PORTAL			// hits solids (not grates) and passes through everything else
	TRACE_MASK_SOLID_BRUSHONLY		// everything normally solid, except monsters (world+brush only)
	TRACE_MASK_PLAYERSOLID_BRUSHONLY// everything normally solid for player movement, except monsters (world+brush only)
	TRACE_MASK_NPCSOLID_BRUSHONLY	// everything normally solid for npc movement, except monsters (world+brush only)
	TRACE_MASK_NPCWORLDSTATIC		// just the world, used for route rebuilding

	/// CollisionGroups
	TRACE_COLLISION_GROUP_NONE

	/// Hitgroups
	HITGROUP_GENERIC
	HITGROUP_HEAD
	HITGROUP_CHEST
	HITGROUP_STOMACH
	HITGROUP_LEFTARM
	HITGROUP_RIGHTARM
	HITGROUP_LEFTLEG
	HITGROUP_RIGHTLEG
	HITGROUP_GEAR
	HITGROUP_COUNT

	/// GetVisibleEntitiesInCone Flags
	VIS_CONE_ENTS_TEST_HITBOXES
	VIS_CONE_ENTS_IGNORE_VORTEX

	"hitEnt"			(entity)	entity the trace collided with (can be null)
	"endPos"			(vector)	xyz position where the trace ended
	"surfaceNormal"		(vector)	the normal of the surface this trace collided with (not accurate for traces that hit entities)
	"surfaceName"		(string)	Name of an entry in one of the surfaceproperties.txt files that the trace hit (.\game\r1\scripts\surfaceproperties_manifest.txt)
	"fraction"			(float)		fraction of the total length of the trace (1.0 == trace reached it's end point)
	"fractionLeftSolid"	(float)		fraction of the total length of the trace that occured inside of a solid
	"hitGroup"			(int)			hitgroup index that the trace hit
	"startSolid"		(bool)		true if the trace started inside of a solid
	"allSolid"			(bool)		true if the trace never left a solid
	"hitSky"			(bool)		Surface hit by the trace was the sky (sky flag SURF_SKY was set)

enum EntityVisibilityFlags ent.kv.VisibilityFlags
{
	ENTITY_VISIBLE_TO_NOBODY		= 0,
	ENTITY_VISIBLE_TO_OWNER			= 1,
	ENTITY_VISIBLE_TO_FRIENDLY		= 2,
	ENTITY_VISIBLE_TO_ENEMY			= 4,
};

//Code enum, pasted here for reference. To set, do entity.kv.CollisionGroup = 3 (for COLLISION_GROUP_INTERACTIVE_DEBRIS)
//Note that the descriptions are not accurate for the most part! Be warned.
enum Collision_Group_t
{
	COLLISION_GROUP_NONE  = 0,
	COLLISION_GROUP_DEBRIS,			// Collides with nothing but world and static stuff
	COLLISION_GROUP_DEBRIS_TRIGGER, // Same as debris, but hits triggers
	COLLISION_GROUP_INTERACTIVE_DEBRIS,	// Collides with everything except other interactive debris or debris
	COLLISION_GROUP_INTERACTIVE,	// Collides with everything except interactive debris or debris
	COLLISION_GROUP_PLAYER,
	COLLISION_GROUP_BREAKABLE_GLASS,
	COLLISION_GROUP_VEHICLE,
	COLLISION_GROUP_PLAYER_MOVEMENT,  // For HL2, same as Collision_Group_Player, for
										// TF2, this filters out other players and CBaseObjects
	COLLISION_GROUP_NPC,			// Generic NPC group
	COLLISION_GROUP_IN_VEHICLE,		// for any entity inside a vehicle
	COLLISION_GROUP_WEAPON,			// for any weapons that need collision detection
	COLLISION_GROUP_WEAPON_THROW,	// for any weapons that need collision with AI and players

	COLLISION_GROUP_VEHICLE_CLIP,	// vehicle clip brush to restrict vehicle movement
	COLLISION_GROUP_PROJECTILE,		// Projectiles!
	COLLISION_GROUP_DOOR_BLOCKER,	// Blocks entities not permitted to get near moving doors
	COLLISION_GROUP_PASSABLE_DOOR,	// Doors that the player shouldn't collide with
	COLLISION_GROUP_DISSOLVING,		// Things that are dissolving are in this group
	COLLISION_GROUP_PUSHAWAY,		// Nonsolid on client and server, pushaway in player code

	COLLISION_GROUP_NPC_ACTOR,		// Used so NPCs in scripts ignore the player.
	COLLISION_GROUP_NPC_SCRIPTED,	// USed for NPCs in scripts that should not collide with each other
	COLLISION_GROUP_PZ_CLIP,

#ifdef PORTAL2
	COLLISION_GROUP_CAMERA_SOLID,		// Solid only to the camera's test trace
	COLLISION_GROUP_PLACEMENT_SOLID,	// Solid only to the placement tool's test trace
	COLLISION_GROUP_PLAYER_HELD,		// Held objects that shouldn't collide with players
	COLLISION_GROUP_WEIGHTED_CUBE,		// Cubes need a collision group that acts roughly like COLLISION_GROUP_NONE but doesn't collide with debris or interactive
#endif // PORTAL2

	COLLISION_GROUP_DEBRIS_BLOCK_PROJECTILE, // Only collides with bullets

	COLLISION_GROUP_HL2_SPIT,
	COLLISION_GROUP_HL2_HOMING_MISSILE,
	COLLISION_GROUP_HL2_COMBINE_BALL,

	COLLISION_GROUP_HL2_FIRST_NPC,
	COLLISION_GROUP_HL2_HOUNDEYE,
	COLLISION_GROUP_HL2_CROW,
	COLLISION_GROUP_HL2_HEADCRAB,
	COLLISION_GROUP_HL2_STRIDER,
	COLLISION_GROUP_HL2_GUNSHIP,
	COLLISION_GROUP_HL2_ANTLION,
	COLLISION_GROUP_HL2_LAST_NORMAL_NPC,

	COLLISION_GROUP_MASSIVE_AI,
	COLLISION_GROUP_MASSIVE_AI_MOVEMENT,
	COLLISION_GROUP_HL2_LAST_NPC,

	COLLISION_GROUP_HL2_COMBINE_BALL_NPC,

	COLLISIONGROUPSTOTALCOUNT
};


	HATT_NONE,
	HATT_UPTIME,							// #HudAutoText_Uptime
	HATT_COUNTDOWN_TIME,					// #HudAutoText_CountdownTime
	HATT_FRIENDLY_TEAM_NAME,				// #HudAutoText_FriendlyTeamName
	HATT_ENEMY_TEAM_NAME,					// #HudAutoText_EnemyTeamName
	HATT_FRIENDLY_TEAM_SCORE,				// #HudAutoText_FriendlyTeamScore
	HATT_ENEMY_TEAM_SCORE,					// #HudAutoText_EnemyTeamScore
	HATT_FRIENDLY_VS_ENEMY_TEAM_SCORE,		// #HudAutoText_FriendlyVsEnemyTeamScore
	HATT_ACTIVE_WEAPON_NAME,
	HATT_ACTIVE_WEAPON_SHORT_NAME,
	HATT_ACTIVE_WEAPON_CLIP_AMMO,			// #HudAutoText_ActiveWeaponClipAmmo
	HATT_ACTIVE_WEAPON_MAX_AMMO,			// #HudAutoText_ActiveWeaponMaxAmmo
	HATT_ACTIVE_WEAPON_MAGAZINE_COUNT,		// #HudAutoText_ActiveWeaponMagazineCount
	HATT_OFFHAND_WEAPON_NAME_0,				// #HudAutoText_OffhandWeaponName0
	HATT_OFFHAND_WEAPON_NAME_1,				// #HudAutoText_OffhandWeaponName1
	HATT_OFFHAND_WEAPON_AMMO_0,				// #HudAutoText_OffhandWeaponAmmo0
	HATT_OFFHAND_WEAPON_AMMO_1,				// #HudAutoText_OffhandWeaponAmmo1
	HATT_CHECK_HUD_EVAC_ETA,				// #HudAutoText_CheckHudEvacEta
	HATT_FRIENDLY_EVAC_HERE_LEAVING_TIME,	// #HudAutoText_FriendlyEvacHereLeavingTime
	HATT_ENEMY_EVAC_HERE_LEAVING_TIME,		// #HudAutoText_EnemyEvacHereLeavingTime
	HATT_ETA_COUNTDOWN_TIME,				// #HudAutoText_EtaCountdownTime
	HATT_LEAVING_COUNTDOWN_TIME,			// #HudAutoText_LeavingCountdownTime

	HATT_GAME_COUNTDOWN_SECONDS,
	HATT_GAME_COUNTDOWN_MINUTES_SECONDS,
	HATT_GAME_COUNTDOWN_SECONDS_MILLISECONDS,

	HATT_DISTANCE_METERS,
	HATT_DISTANCE_METERS_PRECISE,

	HATT_MAX




	FFADE_IN			0x0001		// Just here so we don't pass 0 into the function
	FFADE_OUT			0x0002		// Fade out (not in)
	FFADE_MODULATE		0x0004		// Modulate (don't blend)
	FFADE_STAYOUT		0x0008		// ignores the duration, stays faded out until new ScreenFade message received
	FFADE_PURGE			0x0010		// Purges all other fades, replacing them with this one

*/