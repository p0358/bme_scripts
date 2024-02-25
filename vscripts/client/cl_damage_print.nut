
const NUM_DAMAGE_DEBUG_LINES			= 10		// cant change arbitrarily, need to have matching entries in the .res file
const DAMAGE_DEBUG_POS_Y				= -75
const DAMAGE_DEBUG_PRINT_DURATION		= 15.0

damageDebugElemSegments <- {}
damageDebugElemSegments = [
	"Part1"
	"Part2"
	"Part3"
]

DamageDebugLines <- {}
nextDamageDebugLineIndexToUse <- 0
damageDebugTextBoxWidth <- 500
damageDebugTextBoxHeight <- 20
finishedDamageDebugInit <- false
damageDebugMasterGroup <- null

function InitDamageDebug()
{
	if ( finishedDamageDebugInit )
		return
	
	local screenSize = Hud.GetScreenSize()
	local screenCenterX = screenSize[ 0 ] / 2.0
	local screenCenterY = screenSize[ 1 ] / 2.0
	local defaultPosX = 10 * GetContentScaleFactor()[0]
	local defaultPosY = screenCenterY + ( DAMAGE_DEBUG_POS_Y * GetContentScaleFactor()[1] )
	local elem
	
	// Damage Print Lines
	for ( local i = 0 ; i < NUM_DAMAGE_DEBUG_LINES ; i++ )
	{
		// Create class instance
		DamageDebugLines[ i ] <- HUDSplashLine( "HUDSplashDamageDebugLine" + i )
		
		// Master group containing all elements
		damageDebugMasterGroup = HudElementGroup( "HUDDamageDebugLine" + i )
		
		foreach( segmentName in damageDebugElemSegments )
		{	
			local group = HudElementGroup( "HUDDamageDebugLine" + segmentName + i )
			
			elem = group.CreateElement( "DamageDebug" + segmentName + "_" + i )
			//elem = group.CreateElement( "DamageDebug" + segmentName + "_glow_" + i )
			
			group.SetBaseSize( damageDebugTextBoxWidth, damageDebugTextBoxHeight )
			group.SetBasePos( defaultPosX, defaultPosY )
			
			damageDebugMasterGroup.AddGroup( group )
			DamageDebugLines[ i ].AddSplashGroup( segmentName, group )
		}
		
		DamageDebugLines[ i ].SetDuration( DAMAGE_DEBUG_PRINT_DURATION, OBITUARY_FADE_OUT_DURATION )
		DamageDebugLines[ i ].SetScroll( OBITUARY_SPACING, OBITUARY_SCROLL_TIME )
		DamageDebugLines[ i ].SetTypeDuration( OBITUARY_TYPEWRITER_TIME )
		DamageDebugLines[ i ].SetMasterGroup( damageDebugMasterGroup )
	}
	
	finishedDamageDebugInit = true
}

function DamageDebugPrint( damage, attackerEHandle, damageType, damageSourceId )
{
	if ( !level.DAMAGE_DEBUG_PRINTS )
		return
	
	if ( damage <= 0 )
		return
	
	//----------------------------------------
	// GET ENTS FROM EHANDLES AND VERIFY DATA
	//----------------------------------------
	
	if ( attackerEHandle == null )
	{
		printt( "DAMAGE DEBUG PRINT ERROR: attackerEHandle is null" )
		return
	}
	
	local attacker = null
	
	attacker = GetEntityFromEncodedEHandle( attackerEHandle )

	if ( !IsValid( attacker ) )
	{
		printt( "DAMAGE DEBUG PRINT ERROR: Invalid Attacker" )
		return
	}
	
	local sourceDisplayName = damageSourceStrings[ eDamageSourceId.unknown ]
	if ( damageSourceId in damageSourceStrings )
		sourceDisplayName = damageSourceStrings[ damageSourceId ]
	
	local attackerInfo = Obituary_GetEntityInfo( attacker )
	if ( attackerInfo.displayName == null )
		attackerInfo.displayName = damageSourceStrings[ eDamageSourceId.unknown ]
	
	local timeString = Time().tostring()
	local healthAfter = GetLocalViewPlayer().GetHealth()
	local healthBefore = healthAfter + damage
	
	//-----------------------------------------------------------
	// SET THE 3 PART STRING TO WHATEVER INFO WE WANT TO DISPLAY
	//-----------------------------------------------------------
	
	if ( !level.DAMAGE_DEBUG_PRINTS )
		return

	local PART1_STRING
	
	if ( attacker.IsPlayer() )
	{
		local nameStrings = split( attackerInfo.displayName, " " )		
		
		PART1_STRING = "(" + timeString.tointeger() + ") " + nameStrings.top()
	}
	else
	{
		PART1_STRING = "(" + timeString.tointeger() + ") " + attackerInfo.displayName
	}
	local PART1_COLOR = attackerInfo.displayColor
	
	local PART2_STRING = sourceDisplayName
	local PART2_COLOR = OBITUARY_COLOR_WEAPON
	
	local PART3_STRING 

	if ( level.DAMAGE_DEBUG_PRINTS >= DAMAGE_DEBUG_PRINTS_BOTH )
	{
		PART3_STRING = damage.tostring() // + " (" + healthBefore.tostring() + "->" + healthAfter.tostring() + ")"
	}
	else
	{
		PART3_STRING = damage.tostring() + " (" + healthBefore.tostring() + "->" + healthAfter.tostring() + ")"
	}

	local PART3_COLOR = OBITUARY_COLOR_ENEMY
	
	
	//-----------------------------
	// PRINT THE DAMAGE DEBUG LINE
	//-----------------------------
	
		
	if ( level.DAMAGE_DEBUG_PRINTS <= DAMAGE_DEBUG_PRINTS_BOTH )
		printt( PART1_STRING, "[" + PART2_STRING + "]", PART3_STRING )
	
	if ( level.DAMAGE_DEBUG_PRINTS >= DAMAGE_DEBUG_PRINTS_BOTH )
	{
		InitDamageDebug()
		local next = nextDamageDebugLineIndexToUse
		BumpDownExistingDamageDebugPrints()
		
		DamageDebugLines[ next ].SetTextForGroup( damageDebugElemSegments[0], PART1_STRING )
		DamageDebugLines[ next ].SetColorForGroup( damageDebugElemSegments[0], PART1_COLOR )
		DamageDebugLines[ next ].SetTextForGroup( damageDebugElemSegments[1], PART2_STRING )
		DamageDebugLines[ next ].SetColorForGroup( damageDebugElemSegments[1], PART2_COLOR )
		DamageDebugLines[ next ].SetTextForGroup( damageDebugElemSegments[2], PART3_STRING )
		DamageDebugLines[ next ].SetColorForGroup( damageDebugElemSegments[2], PART3_COLOR )
		DamageDebugLines[ next ].SetBracketsForGroup( damageDebugElemSegments[1], true )
		DamageDebugLines[ next ].DisplayLeft( damageDebugElemSegments[0], damageDebugElemSegments[1], damageDebugElemSegments[2] )
		
		nextDamageDebugLineIndexToUse++
		if ( nextDamageDebugLineIndexToUse >= NUM_DAMAGE_DEBUG_LINES )
			nextDamageDebugLineIndexToUse = 0
	}
}

function BumpDownExistingDamageDebugPrints()
{
	foreach( index, line in DamageDebugLines )
	{
		local numLinesAway = GetDamageDebugLineDistanceFromTop( index )
		line.Scroll( numLinesAway )
	}
}

function GetDamageDebugLineDistanceFromTop( index )
{
	if ( index <= nextDamageDebugLineIndexToUse )
		return nextDamageDebugLineIndexToUse - index
	else
		return NUM_DAMAGE_DEBUG_LINES - ( index - nextDamageDebugLineIndexToUse )
}