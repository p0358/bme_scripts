const OVERHEAD_ENEMY_AI_ICONS = 0
const MAXNUMBEROFHEALTHBLOCKS = 10
const MAXOVERHEADICONS = 25
const TEAMMATEICONS = 12
const DEATHICONS = 8
const MAX_SCALE_DIST_SQ = 64000000

function main()
{
	Globalize( PilotLauncher_ScreenUpdate )
	Globalize( HealthBarOverlayHUD_AddPlayer )
	Globalize( OutOfBoundsOverlayHUD_AddPlayer )
	Globalize( Display_Low_Ammo_Warning )
	Globalize( Low_Ammo_Warning_AddPlayer )
	Globalize( OutOfBoundsDeadTime_Changed )
	Globalize( UpdateOverheadIcons )
	Globalize( ServerCallback_UpdateOverheadIconForNPC )

	RegisterSignal( "OnSpotted" )
	RegisterSignal( "OnSniperCamSpotted" )
	RegisterSignal( "OnDetected" )

	AddCreateCallback( "player", PlayerIconAddEntity )
	AddCreateCallback( "npc_spectre", FriendIconAddEntity )
	AddCreateCallback( "npc_soldier", FriendIconAddEntity )
	AddCreateCallback( "npc_dropship", FriendIconAddEntity )

	// AddDestroyCallback( "npc_spectre", FriendIconRemoveEntity )
	// AddDestroyCallback( "npc_soldier", FriendIconRemoveEntity )
	// AddDestroyCallback( "npc_dropship", FriendIconRemoveEntity )

	file.overheadIcons <- []
	file.overheadIcons.resize( MAXOVERHEADICONS, null )

	PrecacheParticleSystem( "overhead_icon_ai_friendly" )

	RegisterSignal( "FriendIconAddEntity_Thread" )
	RegisterSignal( "OutOfBoundsDeadTimeChanged" )

	AddKillReplayEndedCallback( DeactivateOutOfBoundsIndicator )

	PrecacheHUDMaterial( "hud/sram/sram_targeting_inner_ring" )
	PrecacheHUDMaterial( "hud/sram/sram_targeting_outer_ring" )
	PrecacheHUDMaterial( "hud/sram/sram_targeting_inner_ring_reverse_rotate" )
	PrecacheHUDMaterial( "hud/sram/sram_targeting_outer_ring_reverse_rotate" )
}

function Display_Low_Ammo_Warning( player )
{
	player.hudElems.Low_Ammo_Status.SetAlpha(255)
	player.hudElems.Low_Ammo_Status.Show()

	player.hudElems.Low_Ammo_Status.HideOverTime( 1.5 )

	EmitSoundOnEntity( player, "titan_dryfire" )
}


function Low_Ammo_Warning_AddPlayer( player )
{
	if ( IsMultiplayer() )
	{
		player.InitHudElem( "Low_Ammo_Status" )
		player.hudElems.Low_Ammo_Status.SetColor( 255, 120, 120, 255 )
	}
}


function HealthBarOverlayHUD_AddPlayer( player )
{
	for ( local index = 0; index < MAXOVERHEADICONS ; index++ )
	{
		player.InitHudElem( "OverheadIcon" + index )
		player.hudElems["OverheadIcon" + index].SetColor( 49, 188, 204 )
	}

	player.s.freeWorldTeamMateIcons <- []
	for ( local index = 0; index < TEAMMATEICONS ; index++ )
	{
		player.InitHudElem( "WorldTeamMateIcon" + index )
		player.s.freeWorldTeamMateIcons.append( true )
	}

	player.s.nextFreeDeathIcon <- 0
	for ( local index = 0; index < DEATHICONS ; index++ )
	{
		player.InitHudElem( "WorldDeathIcon" + index )
	}
}

function PlayerIconAddEntity( player, isRecreate )
{
	if ( isRecreate )
		return

	if ( player == GetLocalViewPlayer() )
		return

	if ( player.GetTeam() != GetLocalViewPlayer().GetTeam() )
		return

	thread PlayerIconThink( GetLocalViewPlayer(), player )
}


function PlayerIconThink( localPlayer, otherPlayer )
{
	localPlayer.EndSignal( "OnDestroy" )
	otherPlayer.EndSignal( "OnDestroy" )

	local worldIconIndex = -1

	WaitEndFrame() // temp fix to let player get made after AI get made.

	while ( !level.clientScriptInitialized )
		wait 0

	foreach ( iconIndex, isIconFree in localPlayer.s.freeWorldTeamMateIcons )
	{
		if ( !isIconFree )
			continue

		localPlayer.s.freeWorldTeamMateIcons[iconIndex] = false
		worldIconIndex = iconIndex
		break
	}

	//Assert( worldIconIndex >= 0 )
	if ( worldIconIndex < 0 ) // defensive
		return

	local overheadIcon = localPlayer.hudElems["WorldTeamMateIcon" + worldIconIndex ]
	overheadIcon.SetADSFade( deg_cos( 8 ), deg_cos( 4 ), 0, 1 )
	//overheadIcon.SetFOVFade( deg_cos( 25 ), deg_cos( 4 ), 1, 0 )

	OnThreadEnd(
		function() : ( localPlayer, overheadIcon, worldIconIndex )
		{
			if ( !IsValid( localPlayer ) )
				return

			localPlayer.s.freeWorldTeamMateIcons[worldIconIndex] = true
			overheadIcon.Hide()
		}
	)

	local wasAlive = IsAlive( otherPlayer )
	local doFlash = false
	local deathIcon = null

	while ( 1 )
	{
		if ( PlayerMustRevive( otherPlayer ) )
		{
			UpdateTeamMateOverheadIcon( localPlayer, otherPlayer, overheadIcon )
			overheadIcon.SetClampToScreen( CLAMP_RECT )
			overheadIcon.SetClampBounds( CL_HIGHLIGHT_ARROW_X, CL_HIGHLIGHT_ARROW_Y )
			overheadIcon.SetAlpha( 255 )
			overheadIcon.SetSize( 48, 48 )
		}

		if ( !IsAlive( otherPlayer ) )
			thread TrackPlayerRespawn( otherPlayer )

		local results = WaitSignal( otherPlayer, "OnDeath", "OnModelChanged", "HealthChanged" )
		doFlash = false

		if ( IsAlive( otherPlayer ) )
		{
			if ( deathIcon )
			{
				deathIcon.Hide()
				deathIcon = null
			}
		}
		else if ( wasAlive && GamePlayingOrSuddenDeath() )
		{
			deathIcon = localPlayer.hudElems["WorldDeathIcon" + (localPlayer.s.nextFreeDeathIcon++ % DEATHICONS)]
			deathIcon.Show()
			deathIcon.SetAlpha( 255 )
			if ( PlayerMustRevive( otherPlayer ) )
			{
				deathIcon.SetSize( 48, 48 )
				deathIcon.SetClampToScreen( CLAMP_RECT )
				deathIcon.SetClampBounds( CL_HIGHLIGHT_ARROW_X, CL_HIGHLIGHT_ARROW_Y )
				deathIcon.SetEntity( otherPlayer, Vector( 0, 0, 32 ), 0.5, 0.5 )
			}
			else
			{
				deathIcon.FadeOverTimeDelayed( 0, 4.0, 2.0 )
				deathIcon.SetOrigin( otherPlayer.GetWorldSpaceCenter() )
			}

			overheadIcon.Hide()
		}

		wasAlive = IsAlive( otherPlayer )
		/*
		if ( results.signal == "HealthChanged" && IsAlive( otherPlayer ) )
			doFlash = true

		while ( !IsAlive( otherPlayer ) )
		{
			overheadIcon.Hide()

			wait 0.5; // poll for now, since we don't know when a player respawns on the client
		}

		UpdateTeamMateOverheadIcon( localPlayer, otherPlayer, overheadIcon, doFlash )
		*/
	}
}

function TrackPlayerRespawn( player )
{
	player.EndSignal( "OnDestroy" )
	for ( ;; )
	{
		if ( IsAlive( player ) )
			break

		wait 0.15
	}

	player.Signal( "HealthChanged" )
}


function UpdateTeamMateOverheadIcon( player, teamMate, overheadIcon, doFlash = false )
{
	if ( !IsAlive( teamMate ) )
	{
		overheadIcon.Hide()
		return
	}

	overheadIcon.Show()
	local zOffset = (teamMate.GetWorldSpaceCenter().z - teamMate.GetOrigin().z) * 2.0 + 10
	overheadIcon.SetEntity( teamMate, Vector( 0, 0, zOffset ), 0.5, 0.5 )

	if ( teamMate.IsTitan() )
		overheadIcon.SetImage( "hud/overhead_icon_titan" )
	else
		overheadIcon.SetImage( "hud/overhead_icon_pilot" )


	if ( doFlash )
	{
		overheadIcon.SetAlpha( 255 )
	}
	else
	{
		overheadIcon.SetAlpha( 128 )
	}
}


function DrawDetectedThink()
{
	// debounce on the server for now, since color correction happens there
	//if ( Time() - player.s.lastDetectedTime < 10.0 )
	//	return

	local player = GetLocalViewPlayer()

	player.s.lastDetectedTime = Time()

	Signal( player, "OnDetected" )
	EndSignal( player, "OnDetected" )

//	player.hudElems.AlertDetected.SetAlpha( 255 )
//	player.hudElems.AlertDetectedGlow.SetAlpha( 255 )

	player.hudElems.AlertDetected.SetText( "#HUD_SPOTTED" )
	player.hudElems.AlertDetectedGlow.SetText( "#HUD_SPOTTED" )

	player.hudElems.AlertDetected.SetColor( 255, 255, 255, 255 )
	player.hudElems.AlertDetectedGlow.SetColor( 255, 255, 255, 255 )

	player.hudElems.AlertDetected.Show()
	player.hudElems.AlertDetectedGlow.Show()
	player.hudElems.AlertDetectedBackground.Show()

	printl( "SOUND" )
	EmitSoundOnEntity( player, DETECTED_ALARM_SOUND )

	wait DETECTED_TEXT_DURATION

	player.hudElems.AlertDetected.HideOverTime( 0.25 )
	player.hudElems.AlertDetectedGlow.HideOverTime( 0.25 )
	player.hudElems.AlertDetectedBackground.Hide()

}

function UpdateOverheadIcons( player )
{

}

function GetFreeOverheadIcon()
{
	foreach ( iconIndex, iconEnt in file.overheadIcons )
	{
		if ( iconEnt )
			continue

		return iconIndex
	}

	return null
}


function ServerCallback_UpdateOverheadIconForNPC( guyEhandle )
{
	local player = GetLocalViewPlayer()
	local guy = GetEntityFromEncodedEHandle( guyEhandle )
	if ( !IsAlive( guy ) )
		return

	thread FriendIconAddEntity_Thread( guy )
}


function FriendIconAddEntity( entity, isRecreate )
{
	entity.s.fxHandle <- null
	thread FriendIconAddEntity_Thread( entity )
}


function FriendIconAddEntity_Thread( entity )
{
	entity.Signal( "FriendIconAddEntity_Thread" )
	entity.EndSignal( "FriendIconAddEntity_Thread" )
	entity.EndSignal( "OnDestroy" )

	WaitEndFrame() // returning from/entering kill replay seems to kill the effects too late in the frame?

	if ( !IsAlive( entity ) )
		return

	local player = GetLocalViewPlayer()

	if ( entity.GetTeam() != player.GetTeam() )
		return

	local attachIdx = entity.LookupAttachment( "HEADSHOT" )

	if ( attachIdx == 0 )
		entity.s.fxHandle = StartParticleEffectOnEntity( entity, GetParticleSystemIndex( "overhead_icon_ai_friendly" ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
	else
		entity.s.fxHandle = StartParticleEffectOnEntity( entity, GetParticleSystemIndex( "overhead_icon_ai_friendly" ), FX_PATTACH_POINT_FOLLOW, attachIdx )

	OnThreadEnd(
		function() : ( entity )
		{
			local fxHandle = entity.s.fxHandle

			if ( !EffectDoesExist( fxHandle ) )
				return

			EffectStop( fxHandle, false, true )
		}
	)

	while ( IsAlive( entity ) )
	{
		// effects aren't playing in the correct position on parented entities sometimes
		if ( entity.GetParent() )
		{
			if ( EffectDoesExist( entity.s.fxHandle ) )
				EffectStop( entity.s.fxHandle, false, true )

			if ( attachIdx == 0 )
				entity.s.fxHandle = StartParticleEffectOnEntity( entity, GetParticleSystemIndex( "overhead_icon_ai_friendly" ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
			else
				entity.s.fxHandle = StartParticleEffectOnEntity( entity, GetParticleSystemIndex( "overhead_icon_ai_friendly" ), FX_PATTACH_POINT_FOLLOW, attachIdx )
		}

		wait 1.0
	}
}


function PilotLauncher_ScreenUpdate()
{
	if ( GetConVarBool( "smart_ammo_fast_hud" ) == true )
		return

	local player = GetLocalViewPlayer()

	local launcher = player.GetActiveWeapon()

	if  ( !launcher || launcher.GetClassname() != "mp_weapon_rocket_launcher" )
		return

	if ( !( "pilotLauncherHUD" in player.s ) )
		return

	local totalAmmo = player.GetWeaponAmmoStockpile( launcher )
	local loadedAmmo = player.GetWeaponAmmoLoaded( launcher )
	totalAmmo += loadedAmmo
	//printt( "totalAmmo", totalAmmo )

	/* DEPRECATED print the # of rounds (using icons instead)
	local displayStr = totalAmmo.tostring()

	if ( totalAmmo < 10 )
		displayStr = "0" + displayStr

	player.s.pilotLauncherAmmo.SetText( displayStr )
	*/

	local adsFrac = player.GetAdsFraction()

	if ( adsFrac == 0 )
		return

	local colorUnlocked = [ 177, 213, 227 ]
	local colorOrange	= [ 238, 146, 8 ]
	local colorRed	 	= [ 205, 72, 59 ]
	local colorWhite	= [ 225, 225, 225 ]

	player.s.pilotLauncherHUD.Show()
	player.s.pilotLauncherTargetingRings.Hide()

	// ammo icons
	player.s.pilotLauncherAmmoLabel.Hide()
	player.s.pilotLauncherAmmoIcons.Hide()

	local MAX_LAUNCHER_AMMO_ICONS = 6  // match to the number of hudelems we have
	local iconElems = player.s.pilotLauncherAmmoIcons

	if ( totalAmmo > 0 )
	{
		local numToShow = totalAmmo
		if ( totalAmmo > MAX_LAUNCHER_AMMO_ICONS )
			numToShow = MAX_LAUNCHER_AMMO_ICONS

		for ( local i = ( MAX_LAUNCHER_AMMO_ICONS - 1 ); i >= ( MAX_LAUNCHER_AMMO_ICONS - numToShow ); i-- )
		{
			local elem = iconElems.GetElement( "VGUI_PilotLauncher_AmmoIcon" + i )
			elem.Show()
		}
	}
	else
	{
		player.s.pilotLauncherAmmoLabel.Show()
		player.s.pilotLauncherAmmoLabel.SetText( "#HUD_NO_AMMO" )
		player.s.pilotLauncherAmmoLabel.SetColor( 200, 50, 50 )
	}

	local eyeOrigin = player.CameraPosition()
	local targetOrigin = null

	local outerTargetingRing = player.s.pilotLauncherTargetingRings.GetElement( "VGUI_PilotLauncher_TargetingRing_Outer" )
	local innerTargetingRing = player.s.pilotLauncherTargetingRings.GetElement( "VGUI_PilotLauncher_TargetingRing_Inner" )

	local vguiWidth = 624
	local vguiHeight = 444

	local screenCenterX = vguiWidth / 2
	local screenCenterY = vguiHeight / 2

	local screenCenterScaledX = screenCenterX * GetContentScaleFactor()[0]
	local screenCenterScaledY = screenCenterY * GetContentScaleFactor()[1]


	if ( launcher.SmartAmmo_IsEnabled() )
	{
		local lockFrac 			= 0
		local bestTarget 		= null
		local previousFrac 		= null
		local visible			= null
		local nearestPosition 	= null

		local lockTargets = launcher.SmartAmmo_GetTargets()
		foreach( targ in lockTargets )
		{
			if ( IsValid( targ.entity ) && targ.fraction > lockFrac )
			{
				lockFrac = targ.fraction
				bestTarget = targ.entity
				previousFrac = targ.prevFraction
				visible = targ.visible

				if ( !( "smartAmmoLastEntity" in launcher.s ) )
				{
					launcher.s.smartAmmoLastEntity <- null
				}

				if ( !( "smartAmmoLastLockIdx" in launcher.s ) )
				{
					launcher.s.smartAmmoLastLockIdx <- -1
				}

				local params = {}
				params.entity <- bestTarget
				params.lastEntity <- launcher.s.smartAmmoLastEntity
				params.lastLockIdx <- launcher.s.smartAmmoLastLockIdx
				params.stickiness <- 2.0

				local result = launcher.SmartAmmo_FindNearestVisiblePosition( params )

				nearestPosition = result.position
				launcher.s.smartAmmoLastEntity = bestTarget
				launcher.s.smartAmmoLastLockIdx = result.lockIdx

				break // Break once at the first valid target we find
			}
		}
		if ( bestTarget )
		{
			local lockingOn = true
			if ( lockFrac < previousFrac)
				lockingOn = false

			if ( lockingOn )
			{
				innerTargetingRing.SetImage( "hud/sram/sram_targeting_inner_ring" )
				outerTargetingRing.SetImage( "hud/sram/sram_targeting_outer_ring" )
			}
			else
			{
				innerTargetingRing.SetImage( "hud/sram/sram_targeting_inner_ring_reverse_rotate" )
				outerTargetingRing.SetImage( "hud/sram/sram_targeting_outer_ring_reverse_rotate" )
			}

			player.s.pilotLauncherTargetingRings.Show()

			local modelEnt		= player.GetViewModelEntity()
			local bottomLeft 	= "SCR_BL"
			local topRight 		= "SCR_TR"

			if ( visible )
			{
				targetOrigin = nearestPosition
			}
			else
			{
				targetOrigin = bestTarget.GetWorldSpaceCenter()
			}

			if ( !player.s.lastTargetOrigin )
			{
				player.s.lastTargetOrigin = targetOrigin - bestTarget.GetWorldSpaceCenter();
			}

			local smoothRv = SmoothCDVector( player.s.lastTargetOrigin, targetOrigin - bestTarget.GetWorldSpaceCenter(), player.s.lastTargetVel, 0.2, FrameTime() )
			player.s.lastTargetOrigin = smoothRv.smoothedValue
			player.s.lastTargetVel = smoothRv.velocity

			targetOrigin = player.s.lastTargetOrigin + bestTarget.GetWorldSpaceCenter()

			local blOrigin = modelEnt.GetAttachmentOrigin( modelEnt.LookupAttachment( "SCR_BL" ) )
			local blAngles = modelEnt.GetAttachmentAngles( modelEnt.LookupAttachment( "SCR_BL" ) )
			local blScreen = Hud.ToScreenSpace( blOrigin )

			local trOrigin = modelEnt.GetAttachmentOrigin( modelEnt.LookupAttachment( "SCR_TR" ) )
			local trAngles = modelEnt.GetAttachmentAngles( modelEnt.LookupAttachment( "SCR_TR" ) )
			local trScreen = Hud.ToScreenSpace( trOrigin )

			local screenSize = Hud.GetScreenSize()
			local targetScreen = Hud.ToScreenSpaceClamped( targetOrigin )
			targetScreen = Hud.ClipScreenPositionToBox( targetScreen[0], targetScreen[1], 0, screenSize[0], 0, screenSize[1] )
			targetScreen[0] = Graph( targetScreen[0], blScreen[0], trScreen[0], 0.0, 1.0 ) * ( 624 * GetContentScaleFactor()[0] )
			targetScreen[1] = Graph( targetScreen[1], trScreen[1], blScreen[1], 0.0, 1.0 ) * ( 444 * GetContentScaleFactor()[1] )

			local xPos = Graph( lockFrac, 0, 1, screenCenterScaledX, targetScreen[0] )
			local yPos = Graph( lockFrac, 0, 1, screenCenterScaledY, targetScreen[1] )

			xPos = clamp( xPos, -32000, 32000 )
			yPos = clamp( yPos, -32000, 32000 )

			local lockScale = 1 + ( (1 - lockFrac) * 2.0 )
			player.s.pilotLauncherTargetingRings.SetScale( lockScale, lockScale )

			local targetingRingX = xPos - player.s.pilotLauncherTargetingRings.GetWidth() * 0.5
			local targetingRingY = yPos - player.s.pilotLauncherTargetingRings.GetHeight() * 0.5
			player.s.pilotLauncherTargetingRings.SetPos( targetingRingX, targetingRingY )

			local targetingCircleX = xPos - player.s.pilotLauncherTargetingCircle.GetWidth() * 0.5
			local targetingCircleY = yPos - player.s.pilotLauncherTargetingCircle.GetHeight() * 0.5
			player.s.pilotLauncherTargetingCircle.SetPos( targetingCircleX, targetingCircleY )

			// BUG - when we use SetRotation the vgui screen clipping breaks
			//     - just using built-in VMT rotation for now
			//local outerRotation = Graph( lockFrac, 0.0, 1.0, -90, 90 )
			//local innerRotation = Graph( lockFrac, 0.0, 1.0, 180, -180 )
			//outerTargetingRing.SetRotation( outerRotation )
			//innerTargetingRing.SetRotation( innerRotation )
		}
		else
		{
			player.s.lastTargetOrigin = null
			player.s.lastTargetVel = Vector( 0, 0, 0 )

			player.s.pilotLauncherTargetName.Hide()
			player.s.pilotLauncherRange.Hide()

			local targetingCircleX = screenCenterScaledX - ( player.s.pilotLauncherTargetingCircle.GetWidth() * 0.5 )
			local targetingCircleY = screenCenterScaledY - ( player.s.pilotLauncherTargetingCircle.GetHeight() * 0.5 )
			player.s.pilotLauncherTargetingCircle.SetPos( targetingCircleX, targetingCircleY )

			player.s.pilotLauncherTargetingRings.Hide()
		}

		if ( lockFrac == 0 )
		{
			player.s.pilotLauncherLockStatus.SetColor( colorUnlocked )
			player.s.pilotLauncherTickers.SetColor( colorUnlocked )
			player.s.pilotLauncherTargetingCircle.SetColor( colorUnlocked )
			player.s.pilotLauncherAmmoIcons.SetColor( colorUnlocked )

			local totalAmmoLeft = player.GetWeaponAmmoStockpile( launcher ) + player.GetWeaponAmmoLoaded( launcher )
			if ( totalAmmoLeft > 0 )
				player.s.pilotLauncherLockStatus.SetText( "#HUD_NO_TARGET_IN_RANGE" )
			else
				player.s.pilotLauncherLockStatus.SetText( "#HUD_OFFLINE" )
		}
		else if ( lockFrac == 1.0 )
		{
			player.s.pilotLauncherTargetName.Show()

			local targetStrArray = PilotLauncher_GetTargetDisplayName( bestTarget )
			player.s.pilotLauncherTargetName.SetText( "#HUD_ARCHER_TARGET", targetStrArray[0], targetStrArray[1] )

			player.s.pilotLauncherRange.Show()

			local rangeStr = PilotLauncher_GetRangeDisplayStr( eyeOrigin, targetOrigin )
			player.s.pilotLauncherRange.SetText( "#HUD_DISTANCE_METERS", rangeStr )

			player.s.pilotLauncherTickers.SetColor( colorRed )
			player.s.pilotLauncherTargetingCircle.SetColor( colorRed )

			player.s.pilotLauncherLockStatus.SetText( "#HUD_LOCKED")

			innerTargetingRing.SetImage( "hud/sram/sram_targeting_inner_ring_static" )
			outerTargetingRing.SetImage( "hud/sram/sram_targeting_outer_ring_static" )

			local blinkWait = 0.4
			if ( player.s.lastLockBlinkColor == null || player.s.lastLockBlinkColor == "blinkColor2" )
				blinkWait *= 0.35

			local blinkColor1 = colorRed
			local blinkColor2 = colorWhite
			if ( player.s.lastLockBlinkTime == -1 || Time() - player.s.lastLockBlinkTime >= blinkWait )
			{
				player.s.lastLockBlinkTime = Time()

				if ( player.s.lastLockBlinkColor == null || player.s.lastLockBlinkColor == "blinkColor2" )
				{
					//player.s.pilotLauncherTargetingRings.SetColor( blinkColor1 )
					outerTargetingRing.SetColor( blinkColor1 )
					innerTargetingRing.SetColor( blinkColor2 )
					player.s.pilotLauncherRange.SetColor( blinkColor1 )
					player.s.pilotLauncherTargetName.SetColor( blinkColor1 )
					player.s.pilotLauncherLockStatus.SetColor( blinkColor1 )
					player.s.pilotLauncherAmmoIcons.SetColor( blinkColor1 )
					player.s.pilotLauncherAmmoIcons.SetColor( blinkColor1 )
					player.s.lastLockBlinkColor = "blinkColor1"
				}
				else
				{
					//player.s.pilotLauncherTargetingRings.SetColor( blinkColor2 )
					outerTargetingRing.SetColor( blinkColor2 )
					innerTargetingRing.SetColor( blinkColor1 )
					player.s.pilotLauncherRange.SetColor( blinkColor2 )
					player.s.pilotLauncherTargetName.SetColor( blinkColor2 )
					player.s.pilotLauncherLockStatus.SetColor( blinkColor2 )
					player.s.pilotLauncherAmmoIcons.SetColor( blinkColor2 )
					player.s.pilotLauncherAmmoIcons.SetColor( blinkColor2 )
					player.s.lastLockBlinkColor = "blinkColor2"
				}
			}
		}
		else
		{

			local lockingColor = colorRed
			local displayStr

			lockingColor = colorOrange
			player.s.pilotLauncherLockStatus.SetText( "#HUD_LOCKING")
			player.s.pilotLauncherTargetName.SetText( "#HUD_SCANNING" )
			displayStr = PilotLauncher_GetRandomRangeDisplayStr()//PilotLauncher_GetRangeDisplayStr( eyeOrigin, targetOrigin )

			player.s.pilotLauncherLockStatus.SetColor( lockingColor )
			player.s.pilotLauncherTickers.SetColor( lockingColor )
			player.s.pilotLauncherRange.SetColor( lockingColor )
			player.s.pilotLauncherTargetName.SetColor( lockingColor )
			player.s.pilotLauncherTargetingCircle.SetColor( lockingColor )
			player.s.pilotLauncherTargetingRings.SetColor( lockingColor )
			player.s.pilotLauncherAmmoIcons.SetColor( lockingColor )

			player.s.pilotLauncherTargetName.Show()
			player.s.pilotLauncherRange.SetText( "#HUD_DISTANCE_METERS", displayStr )
			player.s.pilotLauncherRange.Show()
		}
	}
	else
	{
		if ( !( "guidedLaserPoint" in player.s ) || player.s.guidedLaserPoint == null )
			return

		player.s.pilotLauncherTargetName.SetText( "#HUD_GUIDED_MISSILES" )

		local distance = DistanceSqr( eyeOrigin, player.s.guidedLaserPoint )
		local rangeStr = PilotLauncher_GetRangeDisplayStr( eyeOrigin, player.s.guidedLaserPoint )
		player.s.pilotLauncherRange.SetText( "#HUD_DISTANCE_METERS", rangeStr )

		if( "missileInFlight" in player.s && player.s.missileInFlight == true )
		{
			//Limiting the difference in scale so it smoothly transitions instead of jumps.
            local imageScale = GraphCapped( distance, MAX_SCALE_DIST_SQ, 0, 0.2, 1.0 )
			if( "oldTargetingRingScale" in player.s )
			{
				if( imageScale < player.s.oldTargetingRingScale - 0.02 )
					imageScale = player.s.oldTargetingRingScale - 0.02
				else if ( imageScale > player.s.oldTargetingRingScale + 0.02 )
					imageScale = player.s.oldTargetingRingScale + 0.02
				player.s.oldTargetingRingScale = imageScale
			}
			else
			{
				player.s.oldTargetingRingScale <- imageScale
			}
			player.s.pilotLauncherTargetingRings.SetScale( imageScale, imageScale )

			local targetingCircleX = screenCenterScaledX - ( player.s.pilotLauncherTargetingRings.GetWidth() * 0.5 )
			local targetingCircleY = screenCenterScaledY - ( player.s.pilotLauncherTargetingRings.GetHeight() * 0.5 )
			player.s.pilotLauncherTargetingRings.SetPos( targetingCircleX, targetingCircleY )
			player.s.pilotLauncherHUD.SetColor( colorOrange )
			player.s.pilotLauncherLockStatus.SetText( "#HUD_TRACKING" )
			player.s.pilotLauncherTargetingCircle.Hide()
			player.s.pilotLauncherTargetingRings.Show()
		}
		else
		{
			local targetingCircleX = screenCenterScaledX - player.s.pilotLauncherTargetingCircle.GetWidth() * 0.5
			local targetingCircleY = screenCenterScaledY - player.s.pilotLauncherTargetingCircle.GetHeight() * 0.5
			player.s.pilotLauncherTargetingCircle.SetPos( targetingCircleX, targetingCircleY )
			player.s.pilotLauncherHUD.SetColor( colorUnlocked )
			player.s.pilotLauncherLockStatus.SetText( "#HUD_ARMED" )
			player.s.pilotLauncherTargetingCircle.Show()
			player.s.pilotLauncherTargetingRings.Hide()
		}
	}
	// display elems to fade in/out only during a small part of the ADS up/down anims
	local alpha = GraphCapped( adsFrac, 0.65, 0.99, 0, 255 )

	foreach( elem in player.s.pilotLauncherHUD.elements )
		elem.SetAlpha( alpha )
}

function PilotLauncher_GetTargetDisplayName( target )
{
	local sigName = target.GetSignifierName()
	//printt( "launcher target:", sigName )  // TEMP for testing

	local tnStrArray = [null, null]

	if ( target.IsTitan() && HasSoul( target ) )
	{
		tnStrArray[0] = "#NPC_TITAN"

		local soul = target.GetTitanSoul()
		Assert( IsValid( soul ), "Soul is invalid despite HasSoul returning true for entity " + target )
		local titanType = GetSoulTitanType( soul )

		switch ( titanType )
		{
			case "atlas":
				tnStrArray[1] = "#CHASSIS_ATLAS_NAME"
				break

			case "ogre":
				tnStrArray[1] = "#CHASSIS_OGRE_NAME"
				break

			case "stryder":
				tnStrArray[1] = "#CHASSIS_STRYDER_NAME"
				break

			default:
				tnStrArray[1] = "#HUD_UNKNOWN"
				break
		}
	}
	else if ( target.IsTurret() )
	{
		tnStrArray[0] = "#NPC_TURRET"

		switch ( sigName )
		{
			case "npc_turret_mega":
				tnStrArray[1] = "#HEAVY"
				break

			case "npc_turret_sentry":
				tnStrArray[1] = "#LIGHT"
				break

			default:
				tnStrArray[1] = "#HUD_UNKNOWN"
				break
		}
	}
	else if ( sigName == "npc_dropship" || sigName == "npc_gunship" )
	{
		if ( target.GetTeam() == TEAM_IMC )
		{
			tnStrArray[0] = "#TEAM_IMC"

			if ( sigName == "npc_dropship" )
				tnStrArray[1] = "#NPC_GOBLIN"
			else
				tnStrArray[1] = "#NPC_PHANTOM"
		}
		else if ( target.GetTeam() == TEAM_MILITIA )
		{
			tnStrArray[0] = "#TEAM_MCOR"

			if ( sigName == "npc_dropship" )
				tnStrArray[1] = "#NPC_CROW"
			else
				tnStrArray[1] = "#NPC_HORNET"
		}
		else
		{
			tnStrArray[0] = "#TEAM_NEUTRAL"

			if ( sigName == "npc_dropship" )
				tnStrArray[1] = "#NPC_DROPSHIP"
			else
				tnStrArray[1] = "#NPC_GUNSHIP"
		}
	}
	else
	{
		printt( "WARNING pilot rocket launcher encountered unknown target type", tnStrArray )
	}

	return tnStrArray
}


function PilotLauncher_GetRangeDisplayStr( eyeOrigin, targetOrigin )
{
	local range = Distance( eyeOrigin, targetOrigin )
	range *= 0.0254  // convert to meters
	range = ( range + 0.5 ).tointeger()

	local zeroesToPrefix = 0
	if ( range > 9999 )
		range = 9999
	else if ( range < 1000 && range >= 100)
		zeroesToPrefix = 1
	else if ( range < 100 && range >= 10 )
		zeroesToPrefix = 2
	else if ( range < 10 && range >= 0 )
		zeroesToPrefix = 3

	local rangeStr = range.tostring()

	for ( local i = 0; i < zeroesToPrefix; i++ )
		rangeStr = "0" + rangeStr

	return rangeStr
}


function PilotLauncher_GetRandomRangeDisplayStr()
{
	// range gets set to something random while scanning the target
	local min = 0
	local max = 9

	local displayStr = RandomInt( min, max ).tostring() + RandomInt( min, max ).tostring() + RandomInt( min, max ).tostring() + RandomInt( min, max ).tostring()
	return displayStr
}

function OutOfBoundsOverlayHUD_AddPlayer( player )
{
	if ( IsMultiplayer() )
	{
		player.InitHudElem( "OutOfBoundsWarning_Anchor" )
		player.InitHudElem( "OutOfBoundsWarning_Message" )
		player.InitHudElem( "OutOfBoundsWarning_Timer" )

		DeactivateOutOfBoundsIndicator()
	}
}

function OutOfBoundsDeadTime_Changed( player )
{
	if ( player != GetLocalViewPlayer() ) //Looks like there's lag to when GetLocalViewPlayer is set. WatchingKillReplay() can be false and LocalViewPlayer can be not equal to LocalClientPlayer
	{
		//printt( "IsWatchingKillReplay?" + IsWatchingKillReplay() )
		//printt( "Returning because not local view player" )
		return
	}

	if ( GetGameState() < eGameState.Playing )
		return

	player.Signal( "OutOfBoundsDeadTimeChanged" )

	if ( player.GetOutOfBoundsDeadTime() == 0 )
		thread DeactivateOutOfBoundsIndicator()
	else if ( IsAlive( player ) )
		thread ActivateOutOfBoundsIndicator()
}

function DeactivateOutOfBoundsIndicator( )
{
	local player = GetLocalViewPlayer()
	StopSoundOnEntity( player, "Boundary_Warning_Loop" )

	player.hudElems.OutOfBoundsWarning_Message.Hide()
	player.hudElems.OutOfBoundsWarning_Message.ClearPulsate()

	player.hudElems.OutOfBoundsWarning_Timer.Hide()
	player.hudElems.OutOfBoundsWarning_Timer.ClearPulsate()

	player.hudElems.OutOfBoundsWarning_Anchor.Hide()
}

function ActivateOutOfBoundsIndicator()
{
	local player = GetLocalViewPlayer()
	EmitSoundOnEntity( player, "Boundary_Warning_Loop" )

	player.hudElems.OutOfBoundsWarning_Anchor.Show()

	player.hudElems.OutOfBoundsWarning_Message.Show()
	player.hudElems.OutOfBoundsWarning_Message.SetPulsate( 0.5, 1.0, 10 )

	player.hudElems.OutOfBoundsWarning_Timer.Show()
	player.hudElems.OutOfBoundsWarning_Timer.SetPulsate( 0.5, 1.0, 10 )
	player.hudElems.OutOfBoundsWarning_Timer.SetAutoText( "#HUDAUTOTEXT_PLAINCOUNTDOWNTIMEPRECISE", HATT_GAME_COUNTDOWN_SECONDS_MILLISECONDS, player.GetOutOfBoundsDeadTime() )

	thread OutOfBoundsDeadTime_ColorChange( player, player.hudElems.OutOfBoundsWarning_Message, player.hudElems.OutOfBoundsWarning_Timer )

	//Note: Currently looping sounds aren't stopped on entities that are detroyed in kill replay. Eric is going to fix this. Get rid of the below block once he does.
	if ( IsWatchingKillReplay() ) //HACK. Need to do this because of kill replay stuff. This sound is played on the player who killed you if you're watching a kill replay. When kill replay ends, we have no way to get a handle to this player to stop the sound there.
	{
		player.EndSignal( "OnDestroy" )
		OnThreadEnd(
			function() : ( player )
			{
				StopSoundOnEntity( player, "Boundary_Warning_Loop" )

			}
		)

		WaitForever()

	}
}

function OutOfBoundsDeadTime_ColorChange( player, elem1, elem2 )
{
	player.EndSignal( "OutOfBoundsDeadTimeChanged" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )

	OnThreadEnd(
		function() : ( elem1, elem2 )
		{
			elem1.SetColor( 255, 255, 0, 255 )
			elem2.SetColor( 255, 255, 0, 255 )
		}
	)

	local timeLeft = max( 0, player.GetOutOfBoundsDeadTime() - Time() )

	while( IsValid( player ) )
	{
		elem1.ColorOverTime( 255, 0, 0, 255, 0.5 )
		elem2.ColorOverTime( 255, 0, 0, 255, 0.5 )
		wait 0.5
		elem1.ColorOverTime( 255, 255, 0, 255, 0.5 )
		elem2.ColorOverTime( 255, 255, 0, 255, 0.5 )
		wait 0.5
	}
}