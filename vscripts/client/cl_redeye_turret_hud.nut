const HEADINGOFFSETANG = 127//if you change this number also change it in redeye_conversations_flightturret
	
const NUM_PITCH_TICK_BARS = 20
const NUM_PITCH_NUMBERS = 4

const NUM_YAW_TICK_BARS = 10
const NUM_YAW_NUMBERS = 2

const MINTIMEONTARGET = 4

hudVisible <- false
hudVisibleEndSignal <- "hudVisibleEndSignal"
RegisterSignal( hudVisibleEndSignal )

allRedT_HudElems <- null

yawTickBars <- {}
yawTickNumbers <- {}
yawFrame <- {}
arrowMarkers <- {}

yawValue <- null

actualYawValue 	<- null
headingAng 		<- null
CompassDot		<- null
CompassBearing 	<- -1
FailState		<- false

hullIntegrity <- 1.0

staticText <- {}

healthBarNum <- null
healthBarTicks <- {}

yawTickBarMin <- null
yawTickBarMax <- null
yawTickBarGap <- null
yawTickBarCenter <- null
yawTickBarsTotalWidth <- null
yawTickNumberPosY <- null
yawTickNumberOffsetX <- null
yawTickNumberGap <- null

FailColorsTxt <- []
FailColorsTxt.append( StringToColors( "200 200 0 160" ) )
FailColorsTxt.append( StringToColors( "200 100 0 160" ) )
FailColorsTxt.append( StringToColors( "200 0 0 160" ) )
FailColorsTxt.append( StringToColors( "30 10 40 180" ) )

FailColorsImg <- []
FailColorsImg.append( StringToColors( "200 75 0 160" ) )
FailColorsImg.append( StringToColors( "200 25 0 160" ) )
FailColorsImg.append( StringToColors( "200 0 0 160" ) )
FailColorsImg.append( StringToColors( "30 10 40 180" ) )

function main()
{
	Globalize( ServerCallback_RedeyeTurretHud_Show )
	Globalize( ServerCallback_RedeyeTurretHud_Hide )
	Globalize( ServerCallback_RedeyeTurretHud_SetHealthFrac )
	Globalize( ServerCallback_RedeyeTurretHud_SetBearing )
	Globalize( ServerCallback_RedeyeTurretHud_ClearBearing )
	Globalize( ServerCallback_RedeyeTurretHud_Fail )
	Globalize( RedeyeTurretHud_AddPlayer )
}

function ServerCallback_RedeyeTurretHud_Fail()
{	
	thread FailHudThink()
}

function ServerCallback_RedeyeTurretHud_SetBearing( value )
{
	Assert( value <= 360 && value >= 0, "ServerCallback_RedeyeTurretHud_SetBearing got a value not between 0-360: " + value )
	CompassBearing = value
}

function ServerCallback_RedeyeTurretHud_ClearBearing()
{
	CompassBearing = -1
}

function RedeyeTurretHud_AddPlayer()
{
	Create_StaticText()
	Create_HealthBar1()
	Create_YawIndicator()
}

function ServerCallback_RedeyeTurretHud_SetHealthFrac( val )
{
	Assert( val <= 1.0, "ServerCallback_RedeyeTurretHud_SetHealthFrac should take a value between 0 and 1" )
	hullIntegrity = val
}

function ServerCallback_RedeyeTurretHud_Show()
{
	RedeyeTurretHud_Show()
}

function ServerCallback_RedeyeTurretHud_Hide()
{
	RedeyeTurretHud_Hide()
}

function RedeyeTurretHud_Show( delay = null )
{
	if ( hudVisible )
		return

	hudVisible = true

	local elems = allRedT_HudElems.GetElements()
	foreach( elem in elems )
		elem.Show()
			
	thread YawTickBarsThink()
	thread CompassBearingThink()
	thread HealthBarThink()
}

function RedeyeTurretHud_Hide()
{
	if ( !hudVisible )
		return
	
	hudVisible = false
	
	// Stop think functions
	Signal( GetLocalViewPlayer(), hudVisibleEndSignal )
	
	local elems = allRedT_HudElems.GetElements()
	foreach( elem in elems )
		elem.Hide()
}

function RedT_HudElement( name )
{
	local elem = HudElement( name )
	
	if ( allRedT_HudElems == null )
	{
		allRedT_HudElems = CHudMenu( GetLocalViewPlayer(), "RedT_HudElems" )
		RegisterHudMenu( GetLocalViewPlayer(), allRedT_HudElems )
		allRedT_HudElems.Show()
	}
	allRedT_HudElems.AddElement( elem )
	
	return elem
}

function RedT_HudElementWithGlow( name, nameGlow )
{
	local elemGroup = HudElementGroup( name )
	elemGroup.AddElement( RedT_HudElement( name ) )
	elemGroup.AddElement( RedT_HudElement( nameGlow ) )
	
	return elemGroup
}

function Create_YawIndicator()
{
	//-----------------------------
	// moving numbers and tick bars
	//-----------------------------
	
	for( local i = 0 ; i < NUM_YAW_TICK_BARS ; i++ )
		yawTickBars[ i ] <- RedT_HudElement( "RedT_YawTicker" + i )
	
	for( local i = 0 ; i < NUM_YAW_NUMBERS ; i++ )
		yawTickNumbers[ i ] <- RedT_HudElementWithGlow( "RedT_YawTickerNum" + i, "RedT_YawTickerNumGlow" + i )
	
	
	//-----------------------------
	// 			boarder
	//-----------------------------
	
	yawFrame[0] <- RedT_HudElement( "RedT_YawTickerFrameTop" )
	yawFrame[1] <- RedT_HudElement( "RedT_YawTickerFrameLeft" )
	yawFrame[2] <- RedT_HudElement( "RedT_YawTickerFrameRight" )
	yawFrame[4] <- RedT_HudElement( "RedT_YawTickerFrameMarkerBot" )
	yawFrame[5] <- RedT_HudElement( "RedT_YawTickerFrameMarkerRight" )
	yawFrame[6] <- RedT_HudElement( "RedT_YawTickerFrameMarkerLeft" )	
	yawFrame[7] <- RedT_HudElement( "RedT_YawTickerFrameMarkerTop" )
	yawFrame[8] <- RedT_HudElement( "RedT_YawTickerFrameMarkerBG" )
	
	//-----------------------------
	// 		Arrows
	//-----------------------------
	arrowMarkers[0] <- RedT_HudElement( "RedT_BearingMarkerLeft" )
	arrowMarkers[1] <- RedT_HudElement( "RedT_BearingMarkerRight" )
	
	
	//-----------------------------
	// 		top readout number
	//-----------------------------
	yawValue = RedT_HudElementWithGlow( "RedT_YawTickerFrameTopText", "RedT_YawTickerFrameTopTextGlow" )
	
	
	//-----------------------------
	//set math values used in think
	//-----------------------------
	
	yawTickBarGap = yawTickBars[ 1 ].GetBasePos()[0] - yawTickBars[ 0 ].GetBasePos()[0]
	yawTickBarMin = yawTickBars[ 0 ].GetBasePos()
	yawTickBarMax = clone yawTickBarMin
	yawTickBarMax[0] += yawTickBarGap * NUM_YAW_TICK_BARS
	yawTickBarCenter = clone yawTickBarMax
	yawTickBarCenter[0] = ( yawTickBarMax[0] + yawTickBarMin[0] ) / 2.0
	yawTickBarCenter[1] = ( yawTickBarMax[1] + yawTickBarMin[1] ) / 2.0
	yawTickBarsTotalWidth = yawTickBarGap * NUM_YAW_TICK_BARS
	yawTickNumberPosY = yawTickNumbers[ 0 ].GetBasePos()[1]
	yawTickNumberOffsetX = yawTickNumbers[ 0 ].GetBaseWidth() / 2.5
	yawTickNumberGap = yawTickBarGap * 5
	
	//-----------------------------
	// 		Update positioning
	//-----------------------------
	
	for( local i = 0 ; i < NUM_YAW_TICK_BARS ; i++ )
		yawTickBars[ i ].SetPos( yawTickBarCenter[0], yawTickBarCenter[1] )
	
	for( local i = 0 ; i < NUM_YAW_NUMBERS ; i++ )
		yawTickNumbers[ i ].SetPos( yawTickBarCenter[0], yawTickNumberPosY )
}

function CompassBearingThink()
{
	local off 	= StringToColors( "0 0 0 0" )
	local on 	= StringToColors( "255 200 0 255" )
	local timeontarget = 0
	local time = 0.1
	EndSignal( GetLocalViewPlayer(), hudVisibleEndSignal )
	
	while( 1 )
	{
		if( CompassBearing < 0 )
		{
			timeontarget = 0
			arrowMarkers[0].SetColor( off.r, off.g, off.b, off.a )
			arrowMarkers[1].SetColor( off.r, off.g, off.b, off.a )
		}
		else
		{
			if( CompassDot == 0 )
			{
				timeontarget += time
				arrowMarkers[0].SetColor( off.r, off.g, off.b, off.a )
				arrowMarkers[1].SetColor( off.r, off.g, off.b, off.a )
				
				if( timeontarget > MINTIMEONTARGET )
					CompassBearing = -1
			}
			else
			if( CompassDot < 0 )	
			{
				timeontarget = 0
				arrowMarkers[0].SetColor( off.r, off.g, off.b, off.a )
				arrowMarkers[1].SetColor( on.r, on.g, on.b, on.a )	
			}
			else
			if( CompassDot > 0 )	 
			{
				timeontarget = 0
				arrowMarkers[0].SetColor( on.r, on.g, on.b, on.a )
				arrowMarkers[1].SetColor( off.r, off.g, off.b, off.a )	
			}
		}
			
		wait time
	}
}

function DotToBearing()
{
	local currBearing = actualYawValue
	local goalBearing = CompassBearing
	
	local VecF 	= Vector( 0, currBearing, 0 ).AnglesToForward()
	local VecR 	= Vector( 0, currBearing, 0 ).AnglesToRight()
	local VecT 	= Vector( 0, goalBearing, 0 ).AnglesToForward()
	local FDot 	= VecF.Dot( VecT )
	local RDot	= VecR.Dot( VecT )
	local multiplier = 1
		
	if( FDot > 0.975 )
	{
		CompassDot = 0
		return
	}	
	
	if( FDot > 0.85 )
		multiplier = 2	
		
	if( RDot < 0 )
	{
		CompassDot = -1 * multiplier
		return
	}
	else
	{
		CompassDot = 1 * multiplier
		return
	}
}

function GetHeading()
{	
	local degrees
	local radians
	local vecPlayer
	
	vecPlayer = GetLocalViewPlayer().GetViewVector()
		
	//some of this math seems redundant but for some reason it works
	radians = atan2( vecPlayer.x, vecPlayer.y )
	degrees = radians * 180 / PI
	degrees += HEADINGOFFSETANG + 180
	if( degrees > 360 )
		degrees -= 360
	degrees -= 180
	
	return degrees * PI / 180
}

function GetYawValue( heading )
{
	local YValue 	= GetValueFromFraction( heading, -PI, PI, 0, 360 )
	YValue 			= YValue.tointeger()
	
	return YValue	
}

function YawTickBarsThink()
{			
	local green 	= StringToColors( "164 233 108 160" )
	local red		= StringToColors( "255 0 0 200" )
	local orange	= StringToColors( "255 200 0 200" )
	local screenSize = Hud.GetScreenSize()
	local playerFOV = 70.0
	local pixelsFor180 = ( ( 360.0 / playerFOV ) * screenSize[0] ) / 2.0
	local barRatio = ( yawTickBarsTotalWidth * 2.0 ) / pixelsFor180
	local unclippedMin = -pixelsFor180
	local unclippedMax = pixelsFor180
	local zeroXPos
	local elemPosX
	local numberBase
	local alpha
	local alphamax = 160
	local centerline 
	local distToCenter
	local distToCenterMax = 25
	local distToCenterMin = 20
	local distToCenterOffset = -8
				
	EndSignal( GetLocalViewPlayer(), hudVisibleEndSignal )
	
	while(1)
	{		
		headingAng = GetHeading()
		zeroXPos = GetValueFromFraction( headingAng, PI, -PI, unclippedMin, unclippedMax )
		zeroXPos *= barRatio
		zeroXPos += yawTickBarCenter[0]
				
		// update position of the tick marks
		for( local i = 0 ; i < NUM_YAW_TICK_BARS ; i++ )
		{
			elemPosX = zeroXPos - ( yawTickBarGap * i )
			
			// Clip the mins/maxs so it loops around and stays within the bounds
			if ( elemPosX < yawTickBarMin[0] )
			{
				while( elemPosX < yawTickBarMin[0] )
					elemPosX += yawTickBarsTotalWidth
			}
			else if ( elemPosX > yawTickBarMax[0] )
			{
				while( elemPosX > yawTickBarMax[0] )
					elemPosX -= yawTickBarsTotalWidth
			}
			
			yawTickBars[ i ].SetX( elemPosX )
		}
				
		// update position of the numbers
		for( local i = 0 ; i < NUM_YAW_NUMBERS ; i++ )
		{
			elemPosX = zeroXPos - ( yawTickNumberGap * i )
			numberBase = 180 + ( 45 * i )
		
			// Clip the mins/maxs so it loops around and stays within the bounds
			if ( elemPosX < yawTickBarMin[0] )
			{
				while( elemPosX < yawTickBarMin[0] )
				{
					elemPosX += yawTickBarsTotalWidth
					numberBase -= 90
				}
			}
			else if ( elemPosX > yawTickBarMax[0] )
			{
				while( elemPosX > yawTickBarMax[0] )
				{
					elemPosX -= yawTickBarsTotalWidth
					numberBase += 90
				}
			}
			
			if ( numberBase == 360 )
				numberBase = 0
			
				
			if( !FailState )
			{
				if ( numberBase == 0 )
					numberBase = "N"
				else if ( numberBase == 45 )
					numberBase = "NW"
				else if ( numberBase == 90 )
					numberBase = "W"
				else if ( numberBase == 135 )
					numberBase = "SW"
				else if ( numberBase == 180 )
					numberBase = "S"
				else if ( numberBase == 225 )
					numberBase = "SE"
				else if ( numberBase == 270 )
					numberBase = "E"
				else if ( numberBase == 315 )
					numberBase = "NE"
			}
			else
				numberBase = ""	
											
			yawTickNumbers[ i ].SetX( elemPosX - yawTickNumberOffsetX )
			yawTickNumbers[ i ].SetText( numberBase.tostring() )
		/*	
			centerline = yawTickBarMin[0] + ( yawTickBarsTotalWidth * 0.5 )
			distToCenter = ( elemPosX - centerline )
			
			if( distToCenter < 0 )
				distToCenter = fabs( distToCenter )	+ distToCenterOffset
			
			distToCenter -= distToCenterMin
						
			if( distToCenter < 0 )
				distToCenter = 0
			else
			if( distToCenter > distToCenterMax )
				distToCenter = distToCenterMax
			
			alpha = ( alphamax * distToCenter )	/ distToCenterMax
			yawTickNumbers[ i ].SetAlpha( alpha.tointeger() )
		*/
		
		}
				
		// update yaw value actual readout		
		actualYawValue 	= GetYawValue( headingAng )
		
		if( !FailState )
		{
			yawValue.SetText( actualYawValue.tostring() )
			yawValue.SetColor( green.r, green.g, green.b, green.a )
			
			if( CompassBearing > 0 )
			{
				DotToBearing()
				
				if( CompassDot == 0 )
					yawValue.SetColor( red.r, red.g, red.b, red.a )
				else if( fabs( CompassDot ) > 1 )
					yawValue.SetColor( orange.r, orange.g, orange.b, orange.a )
				else	
					yawValue.SetColor( green.r, green.g, green.b, green.a )				
			}
			else
				yawValue.SetColor( green.r, green.g, green.b, green.a )
		}
		else
		{
			if( actualYawValue < 10 ) 
				yawValue.SetText( "" )
			else
			if( actualYawValue < 100 ) 
				yawValue.SetText( "" + "   " + "" )
			else
				yawValue.SetText( "" + "   " + "" + "   " + "" )
			
			staticText[0].SetText( "" + "   " + "" + "   " + "" )	
			staticText[1].SetText( "" + "   " + "" + "   " + "" )
			staticText[2].SetText( "" + "   " + "" + "   " + "" )
			staticText[3].SetText( "" + "   " + "" + "   " + "" )
		}
		
		Wait(0)
	}
}

function Create_StaticText()
{
	//-----------------------------
	// static text along the top
	//-----------------------------
	
	staticText[0] <- RedT_HudElementWithGlow( "RedT_TopText0", "RedT_TopTextGlow0" )
	staticText[1] <- RedT_HudElementWithGlow( "RedT_TopText1", "RedT_TopTextGlow1" )
	staticText[2] <- RedT_HudElementWithGlow( "RedT_TopText2", "RedT_TopTextGlow2" )
	staticText[3] <- RedT_HudElementWithGlow( "RedT_TopText3", "RedT_TopTextGlow3" )
	
//	staticText[6] <- RedT_HudElementWithGlow( "RedT_BottomText0", "RedT_BottomTextGlow0" )
//	staticText[7] <- RedT_HudElementWithGlow( "RedT_BottomText1", "RedT_BottomTextGlow1" )
//	staticText[8] <- RedT_HudElementWithGlow( "RedT_BottomText2", "RedT_BottomTextGlow2" )
	staticText[9] <- RedT_HudElement( "RedT_BGBar" ) 
}

function Create_HealthBar1()
{
	healthBarNum = RedT_HudElementWithGlow( "RedT_HealthTickBarNum", "RedT_HealthTickBarNumGlow" )
	for ( local i = 0 ; i < 10 ; i++ )
		healthBarTicks[i] <- RedT_HudElement( "RedT_HealthTickBar" + i )
}

function HealthBarThink()
{
	local healthFrac
	local healthPercent
	local numBarsToShow
	local titanVehicle
	local yellow = StringToColors( "200 200 0 160" )
	local yellowbar = StringToColors( "200 75 0 160" )
	local orange = StringToColors( "200 100 0 160" )
	local orangebar = StringToColors( "200 25 0 160" )
	local red = StringToColors( "200 0 0 160" )
	local black = StringToColors( "30 10 40 180" )
	
	EndSignal( GetLocalViewPlayer(), hudVisibleEndSignal )
	
	while(1)
	{
		if( !FailState )
		{
			healthFrac = hullIntegrity.tofloat()
			healthPercent = clamp( ( healthFrac * 100.0 ), 1.0, 100.0 ).tointeger()
			healthBarNum.SetText( healthPercent.tostring() + "%" )
			
			numBarsToShow = ( healthFrac * 10.0 )
			
			for ( local i = 0 ; i < 10 ; i++ )
			{
				healthBarTicks[i].Show()
				
				if ( i >= numBarsToShow )
					healthBarTicks[i].SetColor( black.r, black.g, black.b, black.a )//healthBarTicks[i].Hide()
				else
				if( healthFrac < 0.25 )
					healthBarTicks[i].SetColor( red.r, red.g, red.b, red.a )
				else
				if( healthFrac < 0.5 )
					healthBarTicks[i].SetColor( orangebar.r, orangebar.g, orangebar.b, orangebar.a )	
				else
				if( healthFrac < 0.75 )
					healthBarTicks[i].SetColor( yellowbar.r, yellowbar.g, yellowbar.b, yellowbar.a )
			}
			
			if( healthFrac < 0.25 )
				healthBarNum.SetColor( red.r, red.g, red.b, red.a )
			else
			if( healthFrac < 0.5 )
				healthBarNum.SetColor( orange.r, orange.g, orange.b, orange.a )
			else
			if( healthFrac < 0.75 )
				healthBarNum.SetColor( yellow.r, yellow.g, yellow.b, yellow.a )
		}
		else
		{
			for ( local i = 0 ; i < 10 ; i++ )
				healthBarTicks[i].Show()
			
			healthBarNum.SetText( "" + "   " + "" + "   " + "" + "   " + "" )	
		}
				
		Wait(0)
	}
}

function FailHudThink()
{
	EndSignal( GetLocalViewPlayer(), hudVisibleEndSignal )
	
	local green 	= StringToColors( "164 233 108 160" )
	local color
	local element
	local elems = allRedT_HudElems.GetElements()
	foreach( elem in elems )
	
	FailState = true
	
	while( 1 )
	{			
		if( FailState )
		{
			foreach( element in elems )
			{
				color = Random( FailColorsTxt )
				element.SetColor( color.r, color.g, color.b, color.a )
			}
		}
		else
		{
			foreach( element in elems )
				element.SetColor( green.r, green.g, green.b, green.a )
		}
		
		wait RandomFloat( 0.1, 0.75 )
		
		if( RandomInt( 100 ) > 40 )
			FailState = true
		else
			FailState = false
	}		
}
	