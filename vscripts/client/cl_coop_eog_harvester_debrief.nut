const MAX_NUMBER_WAVE_MARKERS = 12 //Supporting up to 10 waves + 2 retries.

function main()
{
	graphLinesWidth <- 0
	graphLinesHeight <- 0

	harvesterTimeDataPointsPlotted 				<- 0
	harvesterTimeDataPointWave 					<- 1
	harvesterTimeDataPointPreviousHealthRatio 	<- 1
	harvesterTimeDataPointTriesUsedUp			<- 0
	
	harvesterWaveDataPointLastWave 		<- 0	
	harvesterWaveDataPointsPlotted 		<- 0	
	harvesterWaveDataPointsTriesUsedUp  <- 0

	firstTryColor		<- [ 151, 227, 243, 255 ]
	secondTryColor		<- [ 151, 227, 243, 255 ]//[ 255, 223, 124, 255 ]
	thirdTryColor 		<- [ 151, 227, 243, 255 ]//[ 255, 72, 67, 255 ]
}

function InitCoopEOGHUD()
{
	level.coopEOGGroup <- HudElementGroup( "HarvesterDebrief" )
	level.coopEOGGroup.CreateElement( "HarvesterDebriefPanel" )
	level.coopEOGGroup.CreateElement( "HarvesterDebriefMainTitleBackground" )
	level.coopEOGGroup.CreateElement( "HarvesterDebriefMainTitle" )
	local graphLines = HudElement( "HarvesterDebriefGraphLines" )
	graphLinesWidth = graphLines.GetWidth()
	graphLinesHeight = graphLines.GetHeight()
	level.coopEOGGroup.AddElement( graphLines )
	local hudElement = HudElement( "HarvesterDebriefBottomTitle" )
	level.coopEOGHarvesterDebriefDamageTitle <- hudElement
	level.coopEOGGroup.AddElement( hudElement )
	//level.coopEOGGroup.CreateElement( "HarvesterDebrief_GraphLines_Vert_Label_0" )
	//level.coopEOGGroup.CreateElement( "HarvesterDebrief_GraphLines_Vert_Label_1" )
	//level.coopEOGGroup.CreateElement( "HarvesterDebrief_GraphLines_Vert_Label_2" )
	local xSpacing = graphLinesWidth.tofloat() / HARVESTER_GRAPH_DATA_POINTS.tofloat()
	level.coopEOGHarvesterGraphGroup <- HudElementGroup( "GraphGroup" )
	level.coopEOGHarvesterLines <- {}
	level.coopEOGHarvesterDots	<- {}
	level.coopEOGHarvesterLabels <- {}
	level.coopEOGHarvesterWaveMarkerText <- {}
	level.coopEOGHarvesterWaveMarkers	 <- {}
	for( local i = 0; i <= HARVESTER_GRAPH_DATA_POINTS; i++ )
	{
		local hudElement = HudElement( "HarvesterDebrief_Line_" + i )
		level.coopEOGHarvesterLines[i] <- hudElement
		level.coopEOGHarvesterGraphGroup.AddElement( hudElement )
		
		local hudElement = HudElement( "HarvesterDebrief_Dot_" + i )
		local basePos = hudElement.GetBasePos()
		hudElement.SetPos( -xSpacing * i + 4.0, basePos[1] )
		level.coopEOGHarvesterDots[i] <- hudElement
		level.coopEOGHarvesterGraphGroup.AddElement( hudElement )
		
		local hudElement = HudElement( "HarvesterDebrief_GraphLines_Horizontal_Label_" + i )
		local basePos = hudElement.GetBasePos()
		hudElement.SetPos( -xSpacing * i + 4.0, basePos[1] )
		level.coopEOGHarvesterLabels[i] <- hudElement
		level.coopEOGHarvesterGraphGroup.AddElement( hudElement )
		
		if ( i < MAX_NUMBER_WAVE_MARKERS )
		{
			local hudElement = HudElement( "HarvesterDebrief_WaveMarker_" + i )
			level.coopEOGHarvesterWaveMarkers[i] <- hudElement
			hudElement.Hide()
			
			local hudElement = HudElement( "HarvesterDebrief_WaveMarkerText_" + i )
			level.coopEOGHarvesterWaveMarkerText[i] <- hudElement
			hudElement.Hide()
		}
	}
	
	level.coopEOGDamageSources <- []
	local width = 0
	for( local i = 0; i < COOP_EOG_MAX_DAMAGE_SOURCES; i++ )
	{
		local elem = HudElement( "HarvesterDebrief_DamageSource_" + i )
		elem.s.bg <- elem.GetChild( "WaveEnemyType_info_box" )
		elem.s.count <- elem.GetChild( "WaveEnemyType_Count" )
		elem.s.image <- elem.GetChild( "WaveEnemyType_Image" )
		elem.s.name <- elem.GetChild( "WaveEnemyType_Name" )
		level.coopEOGDamageSources.append( elem )
		width = elem.GetWidth()
		HideDamageSourceElems( elem )
	}

	level.coopEOGGroup.Hide()
	level.coopEOGHarvesterGraphGroup.Hide()
}
Globalize( InitCoopEOGHUD )

function ServerCallback_SetHarvesterWaveDataPoints( time = null, wave = null, healthRatio = null )
{
	local hudElement = level.coopEOGHarvesterWaveMarkerText[ harvesterWaveDataPointsPlotted ]
	local borderElement = level.coopEOGHarvesterWaveMarkers[ harvesterWaveDataPointsPlotted ]

	local timeSinceEndOfGame
	if( level.nv.winningTeam == GetLocalClientPlayer().GetTeam() )
		timeSinceEndOfGame = COOP_VICTORY_ANNOUNCEMENT_LENGTH
	else
		timeSinceEndOfGame = COOP_DEFEAT_ANNOUNCEMENT_LENGTH

	local timeRatio = time.tofloat() / ( Time() - level.nv.coopStartTime - timeSinceEndOfGame )
	
	local harvesterWaveText = "#COOP_EOG_WAVE"
	if ( harvesterWaveDataPointLastWave == wave )
	{
		harvesterWaveDataPointsTriesUsedUp++
		harvesterWaveText = "#COOP_EOG_WAVE_RETRY"
	}
	
	local color = GetHarvesterGraphColor( harvesterWaveDataPointsTriesUsedUp )
	
	hudElement.SetColor( color )
	hudElement.SetText( harvesterWaveText, wave )
	
	local hudElementPos = hudElement.GetPos()
	hudElement.SetPos( timeRatio * -graphLinesWidth, hudElementPos[1] )
	borderElement.SetColor( color )
	
	harvesterWaveDataPointsPlotted++
	harvesterWaveDataPointLastWave = wave
}
Globalize( ServerCallback_SetHarvesterWaveDataPoints )

function ServerCallback_SetHarvesterTimeDataPoints( time = null, wave = null, healthRatio = null )
{
	local dot = level.coopEOGHarvesterDots[harvesterTimeDataPointsPlotted]
	local label = level.coopEOGHarvesterLabels[harvesterTimeDataPointsPlotted]
	
	if ( wave == null )
		wave = harvesterTimeDataPointWave
	
	local retryDetected = DidRetryOccur( wave, healthRatio )
	if ( retryDetected )
		harvesterTimeDataPointTriesUsedUp++
	
	if ( wave > harvesterTimeDataPointWave )
		harvesterTimeDataPointWave = wave
	
	local currentPos = dot.GetPos()
	local color = GetHarvesterGraphColor( harvesterTimeDataPointTriesUsedUp )
	dot.SetColor( color )
	local heightAdjustment = -healthRatio * graphLinesHeight + dot.GetHeight() / 2.0
	dot.SetPos( currentPos[0], heightAdjustment )
	if ( harvesterTimeDataPointsPlotted % 2 == 0)
	{
		local minutes = time / 60
		local seconds = time % 60
		if ( seconds < 10 )
			label.SetText( minutes + ":0" + time % 60 )
		else
			label.SetText( minutes + ":" + time % 60 )
	}
	if ( retryDetected )
	{
		//When there is a retry, we fake the line down to zero instead of using the average.
		color = GetHarvesterGraphColor( harvesterTimeDataPointTriesUsedUp - 1 )
		ConnectLineToPreviousDot( color, heightAdjustment )
	}
	else
	{
		ConnectLineToPreviousDot( color )
	}

	
	harvesterTimeDataPointPreviousHealthRatio = healthRatio
	harvesterTimeDataPointsPlotted++
}
Globalize( ServerCallback_SetHarvesterTimeDataPoints )

function DidRetryOccur( wave, healthRatio )
{
	//Note: This is fragile, if we add something that increases Harvester Health then this fails.
	if( wave == harvesterTimeDataPointWave && healthRatio > harvesterTimeDataPointPreviousHealthRatio )
		return true
	
	return false
}

function ConnectLineToPreviousDot( color, heightAdjustmentOverride = null )
{
	if ( harvesterTimeDataPointsPlotted == 0 )
		return
	
	local dot = level.coopEOGHarvesterDots[ harvesterTimeDataPointsPlotted ]
	local previousDot = level.coopEOGHarvesterDots[ harvesterTimeDataPointsPlotted - 1 ]
	
	local line = level.coopEOGHarvesterLines[ harvesterTimeDataPointsPlotted - 1 ]
	// Get angle from previous dot to this dot
	local endPos = dot.GetPos()
	local startPos = previousDot.GetPos()
	if ( heightAdjustmentOverride != null )
		endPos = [ endPos[0], dot.GetHeight() / 2.0 ]

	local offsetX = endPos[0] - startPos[0]
	local offsetY = endPos[1] - startPos[1]
	local angle = ( atan2( offsetY, offsetX ) * ( 180 / PI ) )

	// Get line length
	local length = sqrt( offsetX * offsetX + offsetY * offsetY )

	// Calculate where the line should be positioned
	local posX = startPos[0] + ( offsetX / 2.0 ) + ( length / 2.0 ) - dot.GetWidth() / 2.0
	local posY = startPos[1] + ( offsetY / 2.0 )
	
	line.SetWidth( length )
	line.SetRotation( angle )
	line.SetPos( posX, posY )
	line.SetColor( color )
}

function GetHarvesterGraphColor( triesUsedUp )
{
	switch( triesUsedUp )
	{
		case 0:
			return firstTryColor
		case 1:
			return secondTryColor
		case 2:
			return thirdTryColor
		default:
			Assert( "Add more colors to represent different retries" )
	}	
}

function ServerCallback_HarvesterDebrief( enemyIndex0 = null, damageRatio0 = null, enemyIndex1 = null, damageRatio1 = null,  enemyIndex2 = null, damageRatio2 = null, enemyIndex3 = null, damageRatio3 = null )
{
	ResetCurrentStarState()
	SetTopDamageSources( enemyIndex0, damageRatio0, enemyIndex1, damageRatio1, enemyIndex2, damageRatio2, enemyIndex3, damageRatio3 )
	DisplayHarvesterDebrief()
	thread ShowScoreboard()
}
Globalize( ServerCallback_HarvesterDebrief )

function DisplayHarvesterDebrief()
{
	for( local i = 0; i < harvesterTimeDataPointsPlotted; i++ )
	{
		level.coopEOGHarvesterDots[ i ].Show()
		if ( i < ( harvesterTimeDataPointsPlotted - 1 ) )
			level.coopEOGHarvesterLines[ i ].Show()	
		if ( i % 2 == 0 )
			level.coopEOGHarvesterLabels[i].Show()
	}
	
	for( local i = 0; i < harvesterWaveDataPointsPlotted; i++ )
	{
		level.coopEOGHarvesterWaveMarkerText[ i ].Show()
		level.coopEOGHarvesterWaveMarkers[ i ].Show()
	}
	
	level.coopEOGGroup.Show()
}

/*===================================
	TOP DAMAGE SOURCES
/===================================*/
function SetTopDamageSources( enemyIndex0, damageRatio0, enemyIndex1, damageRatio1, enemyIndex2, damageRatio2, enemyIndex3, damageRatio3 )
{
	local validSources = 0
	for( local i = 0; i < COOP_EOG_MAX_DAMAGE_SOURCES; i++ )
	{
		local enemyIndex
		local damageRatio
		if( i == 0 )
		{
			enemyIndex = enemyIndex0
			damageRatio = damageRatio0
		}
		else if ( i == 1 )
		{
			enemyIndex = enemyIndex1
			damageRatio = damageRatio1	
		}
		else if ( i == 2 )
		{
			enemyIndex = enemyIndex2
			damageRatio = damageRatio2	
		}
		else if ( i == 3 )
		{
			enemyIndex = enemyIndex3
			damageRatio = damageRatio3
		}
	
		if ( damageRatio > 0 )
		{	
			local enemyInfo = level.enemyAnnounceCardInfos[ enemyIndex ]
			local elem = level.coopEOGDamageSources[i]
			elem.s.count.SetText( damageRatio + "%" )
			elem.s.image.SetImage( enemyInfo.icon )
			elem.s.name.SetText( enemyInfo.title )
			validSources++
		}
	}

	for( local i = 0; i < validSources; i++ )
	{
		local elem = level.coopEOGDamageSources[i]
		ShowDamageSourceElems( elem )
	}
	
	if ( validSources == 0 )
		level.coopEOGHarvesterDebriefDamageTitle.SetText( "#COOP_EOG_BOTTOM_TITLE_NO_DAMAMGE" )
	else
		level.coopEOGHarvesterDebriefDamageTitle.SetText( "#COOP_EOG_BOTTOM_TITLE" )
}

function HideDamageSourceElems( elem )
{
	elem.Hide()
	elem.s.bg.Hide()
	elem.s.count.Hide()
	elem.s.image.Hide()
	elem.s.name.Hide()
}

function ShowDamageSourceElems( elem )
{
	local elemScaleSize = 1.0
	elem.SetScale( elemScaleSize, elemScaleSize )
	elem.s.bg.SetScale( elemScaleSize, elemScaleSize )
	elem.s.count.SetScale( elemScaleSize, elemScaleSize )
	elem.s.image.SetScale( elemScaleSize, elemScaleSize )
	elem.s.name.SetScale( elemScaleSize, elemScaleSize )
	elem.Show()
	elem.s.bg.Show()
	elem.s.count.Show()
	elem.s.image.Show()
	elem.s.name.Show()
}