function main()
{
	IncludeFile( "_evac_shared" )
	Globalize( ServerCallback_EvacObit )
 	AddEvacObjectives()

 	PrecacheHUDMaterial( "HUD/minimap_evac_location_friendly" )
 	PrecacheHUDMaterial( "HUD/minimap_evac_location_enemy" )
}

function AddEvacObjectives()
{
	//Commented out defensively. See bug 66889
	/*if ( !EvacEnabled() )
		return*/

	//		AddObjective( "O2_noEvacEnding", "#HUD_O2_EPILOGUE_NO_EVAC_TITLE", "#HUD_O2_EPILOGUE_NO_EVAC_DESC" )

	AddObjectiveWithAutoTextAndObjectiveFunction( "EG_DropshipExtract",  	"#EVAC_OBJ_TITLE_GET_TO_SHIP", 				"HATT_CHECK_HUD_EVAC_ETA", 					Bind( CreateShipIconForEvacTeam )  )
	AddObjectiveWithAutoTextAndObjectiveFunction( "EG_DropshipExtract2", 	"#EVAC_OBJ_TITLE_GET_TO_SHIP", 				"HATT_FRIENDLY_EVAC_HERE_LEAVING_TIME", 	Bind( CreateShipLeavingIconForEvacTeam ) )
	AddObjective( "EG_DropshipExtractDropshipFlyingAway", 					"#EVAC_OBJ_TITLE_EVAC_STARTED", 			"#EVAC_OBJ_DESC_EVAC_STARTED" )
	AddObjective( "EG_DropshipExtractSuccessfulEscape", 					"#EVAC_OBJ_TITLE_EVAC_COMPLETE", 			"#EVAC_OBJ_DESC_EVAC_COMPLETE" )
	AddObjective( "EG_DropshipExtractFailedEscape", 						"#EVAC_OBJ_TITLE_EVAC_DENIED", 				"#EVAC_OBJ_DESC_EVAC_DENIED"  )
	AddObjective( "EG_DropshipExtractDropshipDestroyed", 					"#EVAC_OBJ_TITLE_EVAC_DENIED", 				"#EVAC_OBJ_DESC_DROPSHIP_DESTROYED" )
	AddObjective( "EG_DropshipExtractEvacPlayersKilled", 					"#EVAC_OBJ_TITLE_EVAC_DENIED", 				"#EVAC_OBJ_DESC_YOUR_TEAM_ELIMINATED" )
	AddObjective( "EG_DropshipExtractPursuitPlayersKilled", 				"#EVAC_OBJ_TITLE_EVAC_SECURE", 				"#EVAC_OBJ_DESC_ENEMY_TEAM_ELIMINATED"  )
	AddObjectiveWithObjectiveFunction( "EG_StopExtract", 					"#EVAC_OBJ_TITLE_PREVENT_EVAC", 			"#EVAC_OBJ_DESC_KILLED_ENEMY_PILOTS", 		Bind( CreateShipIconForPursuitTeam ) )
	AddObjectiveWithAutoTextAndObjectiveFunction( "EG_StopExtract2", 		"#EVAC_OBJ_TITLE_PREVENT_EVAC", 			"HATT_ENEMY_EVAC_HERE_LEAVING_TIME", 		Bind( CreateShipLeavingIconForPursuitTeam ) )
	AddObjectiveWithObjectiveFunction( "EG_StopExtractDropshipFlyingAway", 	"#EVAC_OBJ_TITLE_EVAC_STARTED", 			"#EVAC_OBJ_DESC_DESTROY_DROPSHIP", 		Bind( CreateShipLeavingIconForPursuitTeam ) )
	AddObjective( "EG_StopExtractDropshipSuccessfulEscape", 				"#EVAC_OBJ_TITLE_ENEMY_EVAC_COMPLETE", 		"#EVAC_OBJ_DESC_ENEMY_EVAC_COMPLETE" )
	AddObjective( "EG_StopExtractDropshipDestroyed", 						"#EVAC_OBJ_TITLE_ENEMY_DROPSHIP_DESTROYED", "#EVAC_OBJ_DESC_ENEMY_EVAC_DENIED" )
	AddObjective( "EG_StopExtractEvacPlayersKilled", 						"#EVAC_OBJ_TITLE_ENEMY_PILOTS_KILLED", 		"#EVAC_OBJ_DESC_ENEMY_EVAC_DENIED" )
	AddObjective( "EG_StopExtractPursuitPlayersKilled",						"#EVAC_OBJ_TITLE_ENEMY_SECURED_EVAC", 		"#EVAC_OBJ_DESC_YOUR_TEAM_ELIMINATED" )
}

function CreateShipIconForEvacTeam( entity )
{
	local player = GetLocalClientPlayer()
	switch ( GameRules.GetGameMode() )
	{
		case "exfil":
		case HEIST:
			break

		case CAPTURE_THE_FLAG_PRO:
		{
			if ( PlayerHasEnemyFlag( player ) )
				AnnouncementMessage( player, "#CAPTURE_THE_FLAG_PRO_FLAG_TAKEN", "#CAPTURE_THE_FLAG_PRO_ESCAPE_TO_SHIP" )
			else
				AnnouncementMessage( player, "#CAPTURE_THE_FLAG_PRO_FLAG_TAKEN", "#CAPTURE_THE_FLAG_PRO_ESCORT_FLAG_TO_SHIP" )

			break
		}

		default:
			AnnouncementMessage( player, "#EOG_XPTYPE_CATEGORY_EPILOGUE", "#EVAC_OBJ_TITLE_GET_TO_SHIP" )
	}

	thread CreateEvacShipWorldFX( entity, 61, 211, 255 )
	CreateEvacShipIcon_Internal( entity,  61, 211, 255, 200, player.GetTeam() ) // blocking call...
}

function CreateShipIconForPursuitTeam( entity )
{
	local player = GetLocalClientPlayer()
	switch ( GameRules.GetGameMode() )
	{
		case "exfil":
		case HEIST:
			break

		case CAPTURE_THE_FLAG_PRO:
		{
			AnnouncementMessage( player, "#CAPTURE_THE_FLAG_PRO_FLAG_TAKEN", "#CAPTURE_THE_FLAG_PRO_ESCORT_STOP_FLAG" )
			break
		}

		default:
			AnnouncementMessage( player, "#EOG_XPTYPE_CATEGORY_EPILOGUE", "#EVAC_OBJ_DESC_KILLED_ENEMY_PILOTS" )
	}

	CreateEvacShipIcon_Internal( entity, 255, 128, 0, 200, GetOtherTeam( player.GetTeam() ) ) // blocking call...
}

function CreateEvacShipIcon_Internal( entity, r, g, b, a, team )
{
	local player = GetLocalClientPlayer()
	Assert( !( "rescueIcon" in player.s ) )
	local icon 	= HudElementGroup( "RescueIconHUD_0" )

	icon.CreateElement( "RescueShipIcon_0" )
	icon.GetElement( "RescueShipIcon_0"  ).SetClampToScreen( CLAMP_ELLIPSE )
	icon.GetElement( "RescueShipIcon_0" ).SetOrigin( entity.GetOrigin() )
	icon.GetElement( "RescueShipIcon_0"  ).SetClampBounds( CL_HIGHLIGHT_ICON_X, CL_HIGHLIGHT_ICON_Y )

	icon.CreateElement( "RescueShipArrow_0" )
	icon.GetElement( "RescueShipArrow_0"  ).SetClampToScreen( CLAMP_ELLIPSE )
	icon.GetElement( "RescueShipArrow_0" ).SetOrigin( entity.GetOrigin() )
	icon.GetElement( "RescueShipArrow_0"  ).SetClampBounds( CL_HIGHLIGHT_ARROW_X, CL_HIGHLIGHT_ARROW_Y )
	icon.GetElement( "RescueShipArrow_0"  ).SetOffscreenArrow( true )

	icon.CreateElement( "RescueShipText_0"  )
	icon.GetElement( "RescueShipText_0" ).SetColor( 192, 192, 192, 255 )

	icon.CreateElement( "RescueShipLabel_0"  )
	icon.Show()

	player.s.rescueIcon <- icon

	OnThreadEnd(
		function() : ( player )
		{
			player.s.rescueIcon.Hide() //Just let garbage collection handle it. No other way to explicitly delete an instance of a class
			delete player.s.rescueIcon
		}
	)

	player.EndSignal( "ObjectiveChanged" )
	player.EndSignal( "OnDestroy" )

	local endTime = player.GetObjectiveEndTime()
	local timeToWait = endTime - Time()

	if ( team == player.GetTeam() )
	{
		icon.GetElement( "RescueShipLabel_0" ).SetAutoText( "#EVAC_ARRIVAL", HATT_GAME_COUNTDOWN_SECONDS, endTime )
		icon.GetElement( "RescueShipIcon_0"  ).SetImage( "HUD/minimap_evac_location_friendly" )
		icon.GetElement( "RescueShipText_0"  ).SetAutoTextVector( "#HUD_DISTANCE_METERS", HATT_DISTANCE_METERS, entity.GetOrigin() )
		icon.GetElement( "RescueShipText_0"  ).EnableAutoText()
	}
	else
	{
		icon.GetElement( "RescueShipLabel_0" ).SetAutoText( "#EVAC_ENEMY_LZ", HATT_GAME_COUNTDOWN_SECONDS, endTime )
		icon.GetElement( "RescueShipIcon_0"  ).SetImage( "HUD/minimap_evac_location_enemy" )
		icon.GetElement( "RescueShipText_0"  ).SetAutoTextVector( "#HUD_DISTANCE_METERS", HATT_DISTANCE_METERS, entity.GetOrigin() )
		icon.GetElement( "RescueShipText_0"  ).EnableAutoText()
		/* // the good version... commented out.
		icon.GetElement( "RescueShipLabel_0" ).SetText( "ENEMY LZ" )
		icon.GetElement( "RescueShipIcon_0"  ).SetImage( "HUD/minimap_evac_location_enemy" )

		icon.GetElement( "RescueShipText_0"  ).SetAutoTextVector( "#HUD_DISTANCE_METERS", HATT_DISTANCE_METERS, entity.GetOrigin() )
		icon.GetElement( "RescueShipText_0"  ).EnableAutoText()
		*/
	}

	wait timeToWait
}

function CreateEvacShipWorldFX( entity, r, g, b )
{
	local player = GetLocalClientPlayer()

	local fxId = GetParticleSystemIndex( "ar_titan_droppoint" )
	player.s.rescueWorldFx <- StartParticleEffectInWorldWithHandle( fxId, entity.GetOrigin(), Vector( 0,0,1 ) )
	EffectSetControlPointVector( player.s.rescueWorldFx, 1, Vector( r, g, b ) )

	player.EndSignal( "ObjectiveChanged" )
	player.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( player )
		{
			StopEvacWorldFX( player )
		}
	)

	//Kill the titanfall AR effect 2 seconds before the dropship actually gets to the point
	local endTime = player.GetObjectiveEndTime() - 2.0
	local timeToWait = endTime - Time()

	wait timeToWait

	StopEvacWorldFX( player )
}



function CreateShipLeavingIconForEvacTeam( entity )
{
	local player = GetLocalClientPlayer()

	CreateShipLeavingIcon_Internal( entity,  61, 211, 255, 200, player.GetTeam() )
}

function CreateShipLeavingIconForPursuitTeam( entity )
{
	local player = GetLocalClientPlayer()

	CreateShipLeavingIcon_Internal( entity, 255, 128, 0, 200, GetOtherTeam( player.GetTeam() ) )
}

function CreateShipLeavingIcon_Internal( entity, r, g, b, a, team )
{
	local player = GetLocalClientPlayer()
	Assert( !( "rescueIcon" in player.s ) )
	local icon 	= HudElementGroup( "RescueIconHUD_0" )

	icon.CreateElement( "RescueShipIcon_0" )
	icon.GetElement( "RescueShipIcon_0"  ).SetClampToScreen( CLAMP_ELLIPSE )
	icon.GetElement( "RescueShipIcon_0" ).SetOrigin( entity.GetOrigin() )
	icon.GetElement( "RescueShipIcon_0"  ).SetClampBounds( CL_HIGHLIGHT_ICON_X, CL_HIGHLIGHT_ICON_Y )

	icon.CreateElement( "RescueShipArrow_0" )
	icon.GetElement( "RescueShipArrow_0"  ).SetClampToScreen( CLAMP_ELLIPSE )
	icon.GetElement( "RescueShipArrow_0" ).SetOrigin( entity.GetOrigin() )
	icon.GetElement( "RescueShipArrow_0"  ).SetClampBounds( CL_HIGHLIGHT_ARROW_X, CL_HIGHLIGHT_ARROW_Y )
	icon.GetElement( "RescueShipArrow_0"  ).SetOffscreenArrow( true )

	icon.CreateElement( "RescueShipText_0"  )
	icon.GetElement( "RescueShipText_0" ).SetColor( 192, 192, 192, 255 )

	icon.CreateElement( "RescueShipLabel_0"  )
	icon.Show()

	player.s.rescueIcon <- icon

	OnThreadEnd(
		function() : ( player )
		{
			player.s.rescueIcon.Hide() //Just let garbage collection handle it. No other way to explicitly delete an instance of a class
			delete player.s.rescueIcon
		}
	)

	player.EndSignal( "OnDestroy" )
	player.EndSignal( "ObjectiveChanged" )

	local endTime = player.GetObjectiveEndTime()
	local timeToWait = endTime - Time()

	if ( team == player.GetTeam() )
	{
		icon.GetElement( "RescueShipLabel_0" ).SetAutoText( "", HATT_LEAVING_COUNTDOWN_TIME, endTime )
		icon.GetElement( "RescueShipIcon_0"  ).SetImage( "HUD/minimap_evac_location_friendly" )
		icon.GetElement( "RescueShipText_0"  ).SetAutoTextVector( "#HUD_DISTANCE_METERS", HATT_DISTANCE_METERS, entity.GetOrigin() )
		icon.GetElement( "RescueShipText_0"  ).EnableAutoText()
	}
	else
	{
		if ( icon.GetElement( "RescueShipLabel_0" ).IsAutoText() )
			icon.GetElement( "RescueShipLabel_0" ).DisableAutoText()
		icon.GetElement( "RescueShipLabel_0" ).SetText( "#HUD_DESTROY" )
		icon.GetElement( "RescueShipIcon_0"  ).SetImage( "HUD/minimap_evac_location_enemy" )
		icon.GetElement( "RescueShipIcon_0" ).SetEntityOverhead( entity, Vector( 0, 0, 0 ), 0.5, 1.0 )
		icon.GetElement( "RescueShipArrow_0" ).SetEntityOverhead( entity, Vector( 0, 0, 0 ), 0.5, 1.0 )

		icon.GetElement( "RescueShipText_0"  ).SetText( "" )
		timeToWait += 3.0 // arbitrary time... as the dropship flies off

		entity.EndSignal( "OnDeath" )
	}

	wait timeToWait
	icon.GetElement( "RescueShipLabel_0" ).Hide()
	//wait 1.0
	player.s.rescueIcon.Hide()
}

function StopEvacWorldFX( player )
{
	if ( "rescueWorldFx" in player.s )
	{
		if ( EffectDoesExist( player.s.rescueWorldFx ) )
			EffectStop( player.s.rescueWorldFx, true, false )
	}

}

function ServerCallback_EvacObit( playerEHandle )
{
	local pilot = GetEntityFromEncodedEHandle( playerEHandle )

	if ( !IsValid( pilot ) )
		return

	if ( !pilot.IsPlayer() )
		return

	local pilotName = pilot.GetPlayerName()
	local pilotNameColor = OBITUARY_COLOR_ENEMY
	if ( pilot.GetTeam() == GetLocalViewPlayer().GetTeam() )
		pilotNameColor = OBITUARY_COLOR_FRIENDLY
	Obituary_Print( pilotName, "#EVAC_OBIT", "", pilotNameColor, OBITUARY_COLOR_WEAPON, OBITUARY_COLOR_WEAPON  )
}

