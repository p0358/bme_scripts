const CROSSHAIR_HIT_INDICATOR_SIGNAL = "CROSSHAIR_HIT_INDICATOR_SIGNAL"
const CROSSHAIR_HIT_INDICATOR_MATERIAL = "HUD/crosshairs/hit_indicator"
const CROSSHAIR_HIT_FAILURE_INDICATOR_MATERIAL = "HUD/crosshairs/titan_40mm_warning_shield"
RegisterSignal( CROSSHAIR_HIT_INDICATOR_SIGNAL )

function main()
{
	Globalize( Crosshair_AddPlayer )
	Globalize( UpdateCrosshair )
	Globalize( UpdateArcCannonCrosshair )
	Globalize( SetCrosshairSpread )
	Globalize( SetCrosshairMovement )

	ch <- {}
	ch.screenSize <- null
	ch.screenHalfSize <- null
	ch.crosshairScreenPos <- []
	ch.crosshairs <- []
	ch.weaponName <- null
	ch.texture <- null
	ch.spread <- [ 0, 0 ]
	ch.spreadOverrides <- {}
	ch.customMoveAmounts <- {}
	ch.color <- {}
	ch.color.r <- 10
	ch.color.g <- 200
	ch.color.b <- 10
	ch.color.a <- 250
	ch.hideAllCrosshairs <- false
}

function Crosshair_AddPlayer( player )
{
	ch.screenSize = Hud.GetScreenSize()
	ch.screenHalfSize = [ ch.screenSize[0] * 0.5, ch.screenSize[1] * 0.5 ]

	player.s.lastHideTime <- 0
	player.s.lastHideState <- false
}

function UpdateCrosshair()
{
	local player = GetLocalViewPlayer()
	Assert( IsValid( player ) )
	local crosshairData = player.GetCrosshairData()
	local weapon = player.GetActiveWeapon()

	if ( !crosshairData )
	{
		HideAllCrosshairs()
		return
	}

	if ( ch.weaponName != crosshairData.weaponName || ch.texture != crosshairData.texture )
	{
		CrosshairChanged( crosshairData )
	}


	if ( ch.hideAllCrosshairs )
	{
		HideAllCrosshairs()
		return
	}

	if ( !weapon || !IsValid( weapon ) )
	{
		HideAllCrosshairs()
		return
	}

	SetPerFrameVars( player, weapon )
	DrawCrosshairs( player, weapon )
}

function CrosshairChanged( crosshairData )
{
	HideAllCrosshairs()

	SetupCrosshairsFromTexture( crosshairData )
}

function SetupCrosshairsFromTexture( crosshairData )
{
	ch.texture = crosshairData.texture
	ch.spreadOverrides.clear()
	ch.customMoveAmounts.clear()
	ch.weaponName = crosshairData.weaponName
	ch.hideAllCrosshairs = true

	foreach ( crosshair in ch.crosshairs )
	{
		crosshair.hudElem.Destroy()
	}

	ch.crosshairs.clear()

	switch( crosshairData.texture )
	{
		case "hud/crosshairs/titan_mortar":
			ch.hideAllCrosshairs = false
			local pipSize = crosshairData.textureWidth * 0.25
			local pipStartingOffsetX = pipSize * 0.25
			local pipStartingOffsetY = crosshairData.textureHeight * 0.47

			Crosshair_Create( crosshairData.texture, 0, 0, crosshairData.textureWidth, crosshairData.textureHeight )
			Crosshair_Create( "hud/crosshairs/titan_mortar_pip", pipStartingOffsetX, pipStartingOffsetY, pipSize, pipSize )
				Crosshair_SetCustomMovement( 0, 0, -1, 0, pipStartingOffsetY * 2.0 )
			Crosshair_Create( "hud/crosshairs/titan_mortar_pip", pipStartingOffsetX, pipStartingOffsetY, pipSize, pipSize )
				Crosshair_SetCustomMovement( 1, 0, -1, 0, pipStartingOffsetY * 2.0 )
				Crosshair_SetColor( 150, 150, 150, 255 )
			Crosshair_Create( "hud/crosshairs/titan_mortar_pip", -pipStartingOffsetX, pipStartingOffsetY, pipSize, pipSize )
				Crosshair_SetCustomMovement( 2, 0, -1, 0, pipStartingOffsetY * 2.0 )
				Crosshair_SetColor( 255, 0, 0, 255 )
				Crosshair_SetRotation( 180 )
			break

		default:
			break
	}
}

function Crosshair_Create( texture, posX, posY, width, height )
{
	local hudElem = HudElement( "Crosshair" + ch.crosshairs.len() )
		hudElem.SetImage( texture )
		hudElem.SetSize( width, height )
		hudElem.SetPos( posX - ( width * 0.5 ), posY - ( height * 0.5 ) )
		hudElem.SetRotation( 0.0 )
	hudElem.Show()

	local crosshair = {}
	crosshair.hudElem <- hudElem
	crosshair.originalMaterial <- texture
	crosshair.currentMaterial <- texture
	crosshair.pos <- [ posX, posY ]
	crosshair.baseSize <- [ width, height ]
	crosshair.size <- [ width, height ]
	crosshair.rotation <- 0.0
	crosshair.drawADS <- true
	crosshair.drawHip <- true
	crosshair.drawZoom <- true
	crosshair.drawReload <- true
	crosshair.drawOnlyWhileLocked <- false
	crosshair.spreadEnabled <- false
	crosshair.alphaModifier <- 1.0
	crosshair.customMovementEnabled <- false
	crosshair.customMovementGroup <- 0
	crosshair.customMoveVec <- { x = 0, y = 0 }
	crosshair.customMoveMax <- { x = 0, y = 0 }
	crosshair.spreadGroup <- 0
	crosshair.spreadVec <- [ 0, 0 ]
	crosshair.stationary <- false
	crosshair.customColor <- []
	crosshair.colorByVortexCharge <- false
	crosshair.scaleByVortexCharge <- false
	crosshair.adsAlphaFrac <- 1.0
	crosshair.scaleADSMax <- 1.0

	ch.crosshairs.append( crosshair )
}

function GetLastCrosshair()
{
	Assert( ch.crosshairs.len() > 0 )
	return ch.crosshairs[ ch.crosshairs.len() - 1 ]
}

function Crosshair_DrawWhileHip( bDraw )
{
	local crosshair = GetLastCrosshair()
	crosshair.drawHip = bDraw
}

function Crosshair_DrawWhileZooming( bDraw )
{
	local crosshair = GetLastCrosshair()
	crosshair.drawZoom = bDraw
}

function Crosshair_DrawWhileReloading( bDraw )
{
	local crosshair = GetLastCrosshair()
	crosshair.drawReload = bDraw
}

function Crosshair_DrawOnlyWhileLocked( bDraw )
{
	local crosshair = GetLastCrosshair()
	crosshair.drawOnlyWhileLocked = bDraw
}

function Crosshair_DrawWhileADS( bDraw )
{
	local crosshair = GetLastCrosshair()
	crosshair.drawADS = bDraw
}

function Crosshair_SetScaleADSMax( newMax )
{
	local crosshair = GetLastCrosshair()
	crosshair.scaleADSMax = newMax
}

function Crosshair_SetRotation( degrees )
{
	local crosshair = GetLastCrosshair()
	crosshair.rotation = degrees
	crosshair.hudElem.SetRotation( degrees )
}

function Crosshair_SetSpread( spreadDirX, spreadDirY, spreadGroup = 0 )
{
	Assert( spreadDirX >= -1 && spreadDirX <= 1 )
	Assert( spreadDirY >= -1 && spreadDirY <= 1 )

	local crosshair = GetLastCrosshair()

	crosshair.spreadEnabled = true
	crosshair.spreadGroup = spreadGroup
	if ( !( spreadGroup in ch.spreadOverrides ) )
		ch.spreadOverrides[ spreadGroup ] <- []
	crosshair.spreadVec = [ spreadDirX, spreadDirY ]
}

function Crosshair_SetColor( r, g, b, a )
{
	Assert( r >= 0 && r <= 255 )
	Assert( g >= 0 && g <= 255 )
	Assert( b >= 0 && b <= 255 )
	Assert( a >= 0 && a <= 255 )

	local crosshair = GetLastCrosshair()
	crosshair.customColor = [ r, g, b, a ]
	crosshair.hudElem.SetColor( r, g, b, a )
}

function Crosshair_ColorByVortexCharge( doColorByVortexCharge )
{
	local crosshair = GetLastCrosshair()
	crosshair.colorByVortexCharge = doColorByVortexCharge
}

function Crosshair_ScaleByVortexCharge( vortexScaleChargeMin, vortexScaleChargeMax, vortexScaleMin, vortexScaleMax )
{
	local crosshair = GetLastCrosshair()
	crosshair.scaleByVortexCharge = true

	crosshair.vortexScaleChargeMin 	<- vortexScaleChargeMin
	crosshair.vortexScaleChargeMax 	<- vortexScaleChargeMax
	crosshair.vortexScaleMin 		<- vortexScaleMin
	crosshair.vortexScaleMax 		<- vortexScaleMax
}

function Crosshair_SetCustomMovement( group , directionX, directionY, maxX, maxY )
{
	Assert( directionX == -1 || directionX == 0 || directionX == 1 )
	Assert( directionY == -1 || directionY == 0 || directionY == 1 )

	local crosshair = GetLastCrosshair()

	crosshair.customMovementEnabled = true
	crosshair.customMovementGroup = group
	if ( !( group in ch.customMoveAmounts ) )
		ch.customMoveAmounts[ group ] <- {}
	crosshair.customMoveVec = { x = directionX, y = directionY }
	crosshair.customMoveMax = { x = maxX, y = maxY }
}

function Crosshair_SetStationary( bStationary )
{
	local crosshair = GetLastCrosshair()
	crosshair.stationary = bStationary
}

function Crosshair_SetADSAlpha( a )
{
	Assert( a >= 0 && a <= 255 )

	local crosshair = GetLastCrosshair()
	crosshair.adsAlphaFrac = a / 255
}

function SetPerFrameVars( player, weapon )
{
	local playerSpread = player.GetAttackSpread()
	if ( playerSpread < 0 )
		playerSpread = 0

	ch.spread[0] = playerSpread
	ch.spread[1] = playerSpread

	//printt( "Spread:", ch.spread[0], ",", ch.spread[1] )

	local crosshairTarget = GetValidCrosshairTarget( player );

 	if ( ( IsValid( crosshairTarget ) && (crosshairTarget.GetTeamNumber() != player.GetTeamNumber()) ) || RedCrosshairOverride( weapon ))
	{
		ch.color.r = ENEMY_CROSSHAIR_COLOR[0]
		ch.color.g = ENEMY_CROSSHAIR_COLOR[1]
		ch.color.b = ENEMY_CROSSHAIR_COLOR[2]
		ch.color.a = ENEMY_CROSSHAIR_COLOR[3]
	}
	else if ( IsValid( crosshairTarget ) && (crosshairTarget.GetTeamNumber() == player.GetTeamNumber()) )
	{
		ch.color.r = FRIENDLY_CROSSHAIR_COLOR[0]
		ch.color.g = FRIENDLY_CROSSHAIR_COLOR[1]
		ch.color.b = FRIENDLY_CROSSHAIR_COLOR[2]
		ch.color.a = FRIENDLY_CROSSHAIR_COLOR[3]
	}
	else
	{
		local color = level.baseColorElem.GetColor()

		ch.color.r = color[0]
		ch.color.g = color[1]
		ch.color.b = color[2]
		ch.color.a = 160
	}

	ch.crosshairScreenPos = player.GetCrosshairPos()

	// Add half a pixel to avoid landing on a pixel boundary, which can cause jitter
	ch.crosshairScreenPos[0] = ch.crosshairScreenPos[0] * ch.screenSize[0] + 0.5
	ch.crosshairScreenPos[1] = ch.crosshairScreenPos[1] * ch.screenSize[1] + 0.5

	local shouldHide = ( ( player.IsSprinting() && !CanWeaponShootWhileRunning( weapon ) )  || weapon.IsReloading())

	if ( shouldHide )
	{
		if ( player.s.lastHideState != shouldHide )
			player.s.lastHideTime = Time()

		local alphaFrac = GraphCapped( Time() - player.s.lastHideTime, 0.0, 0.15, 1.0, 0.15 )

		ch.color.a *= alphaFrac
	}
	else
	{
		if ( player.s.lastHideState != shouldHide )
			player.s.lastHideTime = Time()

		local alphaFrac = GraphCapped( Time() - player.s.lastHideTime, 0.0, 0.15, 0.15, 1.0 )

		ch.color.a *= alphaFrac
	}

	player.s.lastHideState = shouldHide
}

::g_sColor <- Vector( 0, 0, 0 )
::g_sAlpha <- 255

::g_cColor <- Vector( 200, 200, 200 )
::g_cAlpha <- 160

function SetCrosshairSpread( spreadX, spreadY, spreadGroup = 0 )
{
	Assert( spreadX >= 0 )
	Assert( spreadY >= 0 )

	if ( !( spreadGroup in ch.spreadOverrides ) )
		ch.spreadOverrides[ spreadGroup ] <- []
	ch.spreadOverrides[ spreadGroup ] = [ spreadX, spreadY ]
}

function SetCrosshairMovement( group, movementX, movementY )
{
	Assert( movementX >= 0 && movementX <= 1 )
	Assert( movementY >= 0 && movementY <= 1 )

	if ( !( group in ch.customMoveAmounts ) )
		ch.customMoveAmounts[ group ] <- {}
	ch.customMoveAmounts[ group ] = { x = movementX, y = movementY }
}

function GetValidCrosshairTarget( player )
{
	local target = player.GetTargetInCrosshairRange()
	if ( !target )
		return null

	if ( target.IsIgnoredByAimAssist() )
		return null

	return target
}

function DrawCrosshairs( player, weapon )
{
	Assert( IsValid( player ) )
	Assert( IsValid( weapon ) )
	local playerADSFrac = player.GetAdsFraction()

	foreach ( crosshair in ch.crosshairs )
	{
		SetCrosshairVisibility( crosshair, playerADSFrac, player, weapon )
		SetCrosshairColor( crosshair, ch.color, weapon )
		SetCrosshairAlpha( crosshair, ch.color, playerADSFrac, weapon )
		SetCrosshairScale( crosshair, playerADSFrac, weapon )
		PositionCrosshair( crosshair )
	}
}

function HideAllCrosshairs()
{
	foreach ( crosshair in ch.crosshairs )
	{
		crosshair.hudElem.Hide()
	}
}

function SetCrosshairVisibility( crosshair, playerADSFrac, player, weapon )
{
	local bShow = true

	while ( bShow )
	{
		if ( weapon.GetClassname() == "mp_titanweapon_vortex_shield" && weapon.GetWeaponChargeFraction() >= 1.0 )
		{
			bShow = false
			break
		}

		if ( playerADSFrac == 1.0 && !crosshair.drawADS )
		{
			bShow = false
			break
		}

		if ( playerADSFrac == 0.0 && !crosshair.drawHip )
		{
			bShow = false
			break
		}

		if ( playerADSFrac > 0 && playerADSFrac < 1.0 && !crosshair.drawZoom )
		{
			bShow = false
			break
		}

		if ( weapon.IsReloading() && !crosshair.drawReload )
		{
			bShow = false
			break
		}

		if ( crosshair.drawOnlyWhileLocked && !HasLockedTarget( weapon ) )
		{
			bShow = false
			break
		}

		break
	}

	if ( bShow )
	{
		crosshair.hudElem.Show()
	}
	else
	{
		crosshair.hudElem.Hide()
	}

	return bShow
}

function SetCrosshairScale( crosshair, playerADSFrac, weapon)
{
	local scaleSize = null

	if( crosshair.scaleADSMax > 1.0 )
	{
		if ( weapon.IsWeaponAdsButtonPressed() )
			scaleSize = GraphCapped( playerADSFrac, 0, 0.5 , 1.0 , crosshair.scaleADSMax )
		else
			scaleSize = GraphCapped( playerADSFrac, 0.25, 1.0 , 1.0 , crosshair.scaleADSMax )
	}
	else if ( crosshair.scaleByVortexCharge )
	{
		local frac = weapon.GetWeaponChargeFraction()
		scaleSize = GraphCapped( frac, crosshair.vortexScaleChargeMin, crosshair.vortexScaleChargeMax, crosshair.vortexScaleMin, crosshair.vortexScaleMax )
	}

	if ( !scaleSize )
		return

	crosshair.size[0] = scaleSize * crosshair.baseSize[0]
	crosshair.size[1] = scaleSize * crosshair.baseSize[1]
	crosshair.hudElem.SetSize( crosshair.size[0], crosshair.size[1] )
}

function SetCrosshairColor( crosshair, color, weapon )
{
	if ( crosshair.colorByVortexCharge )
	{
		local colorVec = GetVortexSphereCurrentColor( weapon )
		crosshair.hudElem.SetColor( colorVec.x, colorVec.y, colorVec.z, 255 )
	}
	else if ( crosshair.customColor.len() == 0 )
		crosshair.hudElem.SetColor( color.r, color.g, color.b, color.a )
}

function SetCrosshairAlpha( crosshair, color, playerADSFrac, weapon )
{
	local alpha = 255

	local player = GetLocalViewPlayer()

	local alphaFrac = GraphCapped( playerADSFrac, 0.0, 1.0, 1.0, crosshair.adsAlphaFrac )

	if ( crosshair.drawADS && !crosshair.drawHip )
		alphaFrac *= playerADSFrac
	else if ( !crosshair.drawADS && crosshair.drawHip )
		alphaFrac *= (1 - playerADSFrac)

	crosshair.hudElem.SetAlpha( color.a * alphaFrac * crosshair.alphaModifier )
}

function PositionCrosshair( crosshair )
{
	if ( crosshair.stationary )
	{
		crosshair.hudElem.SetPos( ch.screenHalfSize[0] - crosshair.size[0] * 0.5, ch.screenHalfSize[1] - crosshair.size[1] * 0.5 )
		return
	}

	local posX = crosshair.pos[0] - crosshair.size[0] * 0.5
	local posY = crosshair.pos[1] - crosshair.size[1] * 0.5

	if ( crosshair.spreadEnabled )
	{
		local elemSpredVec = Vector( crosshair.spreadVec[0], crosshair.spreadVec[1], 0 )
		elemSpredVec.Norm()

		local spreadX = ch.spread[0]
		local spreadY = ch.spread[1]

		if ( crosshair.spreadGroup in ch.spreadOverrides )
		{
			if ( ch.spreadOverrides[ crosshair.spreadGroup ].len() > 0 )
			{
				spreadX = ch.spreadOverrides[ crosshair.spreadGroup ][0]
				spreadY = ch.spreadOverrides[ crosshair.spreadGroup ][1]
			}
		}
		ch.spreadOverrides[ crosshair.spreadGroup ]

		posX += spreadX * elemSpredVec.x
		posY += spreadY * elemSpredVec.y
	}

	if ( crosshair.customMovementEnabled )
	{
		if ( crosshair.customMovementGroup in ch.customMoveAmounts )
		{
			if ( ch.customMoveAmounts[ crosshair.customMovementGroup ].len() > 0 )
			{
				local elemMoveVec = Vector( crosshair.customMoveVec.x, crosshair.customMoveVec.y, 0 )
				elemMoveVec.Norm()

				posX += ch.customMoveAmounts[ crosshair.customMovementGroup ].x * elemMoveVec.x * crosshair.customMoveMax.x
				posY += ch.customMoveAmounts[ crosshair.customMovementGroup ].y * elemMoveVec.y * crosshair.customMoveMax.y
			}
		}
	}

	crosshair.hudElem.SetPos( ch.crosshairScreenPos[0] + posX, ch.crosshairScreenPos[1] + posY )
}

function RedCrosshairOverride( weapon )
{
	if( HasLockedTarget( weapon ) )
		return true

	return false
}

function UpdateArcCannonCrosshair( player, weapon )
{
	//Hack - There is a window between KillReplayEnd and respawning where the game thinks you still have your old weapons from before you died.
	//Ideally the progress bar is a crosshair option and uses the normal code path for crosshairs.	
	if ( !( "arcChargeBar" in player.s ) )
		return

	local playerADSFrac = player.GetZoomFrac()
	local scale = GraphCapped( playerADSFrac, 0, 1.0, 1.0, 1.5 )
	player.s.arcChargeBar.SetScale( scale, scale )
	local crosshairTarget = player.GetTargetInCrosshairRange()
 	if ( IsValid( crosshairTarget ) && ( crosshairTarget.GetTeamNumber() == GetOtherTeam( player ) ) )
		player.s.arcChargeBar.SetColor( ENEMY_CROSSHAIR_COLOR[0], ENEMY_CROSSHAIR_COLOR[1], ENEMY_CROSSHAIR_COLOR[2], ENEMY_CROSSHAIR_COLOR[3] )
	else if ( IsValid( crosshairTarget ) && ( crosshairTarget.GetTeamNumber() == player.GetTeamNumber()) )
		player.s.arcChargeBar.SetColor( FRIENDLY_CROSSHAIR_COLOR[0], FRIENDLY_CROSSHAIR_COLOR[1], FRIENDLY_CROSSHAIR_COLOR[2], FRIENDLY_CROSSHAIR_COLOR[3] )
	else if ( weapon.HasMod( "burn_mod_titan_arc_cannon" ) )
		player.s.arcChargeBar.SetColor( BURN_CARD_WEAPON_HUD_COLOR[0], BURN_CARD_WEAPON_HUD_COLOR[1], BURN_CARD_WEAPON_HUD_COLOR[2], BURN_CARD_WEAPON_HUD_COLOR[3] )
	else
		player.s.arcChargeBar.ReturnToBaseColor()
}