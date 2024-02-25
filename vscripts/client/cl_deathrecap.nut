const DEATHRECAP_SHOW_TIME = 9 // Respawn delay is 5 seconds
const DEATHRECAP_MOVE_TIME = 0.125
const DEATHRECAP_MOVE_HEIGHT = 148 // Height plus y offset
DEATHRECAP_WEAPON_HUD_COLOR <- [ 220, 220, 220, 255 ]
DEATHRECAP_LETHAL_WEAPON_HUD_COLOR <- [ 254, 93, 80, 255 ]

function main()
{
	Globalize( InitDeathRecap )
	Globalize( ShowDeathRecap )
	Globalize( DeathRecap )
	Globalize( DoomRecap )

	if ( developer() > 0 )
		Globalize( TestDeathRecap )

	level.nameOfLastKiller <- null

	RegisterSignal( "EndShowDeathRecap" )
	PrecacheHUDMaterial( "../ui/deathrecap_fg_one_source" )
	PrecacheHUDMaterial( "../ui/deathrecap_fg_two_sources" )
	PrecacheHUDMaterial( "../ui/deathrecap_fg_two_sources_two_ppl" )
	PrecacheHUDMaterial( "../ui/deathrecap_fg_three_sources" )
	PrecacheHUDMaterial( "../ui/deathrecap_bg_one_source" )
	PrecacheHUDMaterial( "../ui/deathrecap_bg_two_sources" )
	PrecacheHUDMaterial( "../ui/deathrecap_bg_two_sources_two_ppl" )
	PrecacheHUDMaterial( "../ui/deathrecap_bg_three_sources" )

	PrecacheHUDMaterial( "../ui/doomrecap_fg_one_source" )
	PrecacheHUDMaterial( "../ui/doomrecap_fg_two_sources" )
	PrecacheHUDMaterial( "../ui/doomrecap_fg_two_sources_two_ppl" )
	PrecacheHUDMaterial( "../ui/doomrecap_fg_three_sources" )

	AddKillReplayEndedCallback( HideDeathRecap )
}

function InitDeathRecap()
{
	file.deathRecapDisplay <- {}
	file.deathRecapDisplayGroup <- HudElementGroup( "DeathRecapDisplayGroup" )

	file.deathRecapDisplay.background <- HudElement( "deathRecapBackground" )
	file.deathRecapDisplay.foreground <- HudElement( "deathRecapForeground" )

	for ( local columnIndex = 1; columnIndex < 2; columnIndex++ )
	{
		for ( local rowIndex = 0; rowIndex < 8; rowIndex++ )
		{
			local offsetColumnIndex = columnIndex + 1
			local offsetRowIndex = rowIndex + 1
			local name = "column" + offsetColumnIndex + "_row" + offsetRowIndex

			file.deathRecapDisplay[name] <- HudElement( "deathRecap_" + name )
			file.deathRecapDisplayGroup.AddElement( file.deathRecapDisplay[name] )
		}
	}
	file.deathRecapDisplay["column1_row1"] <- HudElement( "deathRecap_" + "column1_row1" )
	file.deathRecapDisplayGroup.AddElement( file.deathRecapDisplay["column1_row1"] )

	file.deathRecapDisplay["column1_row6"] <- HudElement( "deathRecap_" + "column1_row6" )
	file.deathRecapDisplayGroup.AddElement( file.deathRecapDisplay["column1_row6"] )

	file.deathRecapDisplay["healthStatus_Killer"] <- HudElement( "deathRecap_" + "HealthStatus_Killer" )
	file.deathRecapDisplayGroup.AddElement( file.deathRecapDisplay["healthStatus_Killer"] )

	file.deathRecapDisplay["healthStatus_Assister"] <- HudElement( "deathRecap_" + "HealthStatus_Assister" )
	file.deathRecapDisplayGroup.AddElement( file.deathRecapDisplay["healthStatus_Assister"] )

	file.deathRecapWeaponIconGroup <- HudElementGroup( "DeathRecapWeaponIconGroup" )
	file.deathRecapDisplay.deathRecapWeaponIcon_0 <- HudElement( "deathRecapWeaponIcon_0" )
	file.deathRecapWeaponIconGroup.AddElement( file.deathRecapDisplay.deathRecapWeaponIcon_0 )
	file.deathRecapDisplay.deathRecapWeaponIcon_1 <- HudElement( "deathRecapWeaponIcon_1" )
	file.deathRecapWeaponIconGroup.AddElement( file.deathRecapDisplay.deathRecapWeaponIcon_1 )
	file.deathRecapDisplay.deathRecapWeaponIcon_2 <- HudElement( "deathRecapWeaponIcon_2" )
	file.deathRecapWeaponIconGroup.AddElement( file.deathRecapDisplay.deathRecapWeaponIcon_2 )

	ClearDeathRecap()
}

function ShowDeathRecap( killer, killDamageSourceId, titanDoomed = false )
{
	if( IsWatchingKillReplay() )
		return

	OnThreadEnd(
		function ()
		{
			HideDeathRecap()
		}
	)


	file.deathRecapDisplayGroup.ReturnToBasePos()
	file.deathRecapWeaponIconGroup.ReturnToBasePos()
	local localPlayer = GetLocalViewPlayer()
	local killerName
	local killerPetName = ""
	local assisterName
	local assisterPetName = ""
	local damageSources
	local maxDamageSourcesKiller = 2
	local maxDamageSourcesAssister = 1
	level.nameOfLastKiller = null

	localPlayer.Signal( "EndShowDeathRecap" )
	localPlayer.EndSignal( "EndShowDeathRecap" )

	if ( titanDoomed || localPlayer.IsTitan() )
		damageSources = GetTopDamageSources( GetTitanDamageHistory(), maxDamageSourcesKiller, maxDamageSourcesAssister, titanDoomed, killer )
	else
		damageSources = GetTopDamageSources( GetPilotDamageHistory(), maxDamageSourcesKiller, maxDamageSourcesAssister, titanDoomed, killer )

	local killerDamageSources = damageSources.killerDamageSources
	local assisterDamageSources = damageSources.assisterDamageSources
	local assister

	local sourceOneHasMods
	local sourceTwoHasMods
	local sourceThreeHasMods

	if ( IsValid( killer ) )
	{
		local names = GetAttackerDisplayNamesFromClassname( killer )
		level.nameOfLastKiller = names

		killerName = names.attackerName
		killerPetName = names.attackerPetName
		local killerHealthInfo = GetDeathRecapHealthInfo( killer )

		if ( killer == localPlayer )
		{
			file.deathRecapDisplay.column2_row1.SetText( "#KILLCARD_NAME_DISPLAY", "#RECAP_YOURSELF" )
		}
		else
		{
			if( killerPetName == "" )
			{
				file.deathRecapDisplay.column2_row1.SetText( "#KILLCARD_NAME_DISPLAY", killerName )
			}
			else
			{
				//killerName = ResizePlayerNamesForKillCard( killerName, "...", 10 )
				file.deathRecapDisplay.column2_row1.SetText( "#KILLCARD_NAME_WITH_PET_DISPLAY", killerName, killerPetName )
			}
		}
		file.deathRecapDisplay.healthStatus_Killer.SetText( "#KILLCARD_DAMAGE_PERCENT_DISPLAY", killerHealthInfo.healthStatusText, killerHealthInfo.syntax )

		if ( killer.IsPlayer() )
			killerDamageSources = DisplayBurnCardInfoInKillCard( killer, killerDamageSources )
	}
	else
	{
		// if killer is invalid try to find the killer display name based on damage source.
		// it's unfurtunate that we have to do it this way. It's would be better if the data ...
		// the server sent didn't assume entities existing on the client.
		local killerName = GetAttackerDisplayNamesDamageSourceId( killDamageSourceId )
		if ( killerName != null )
			file.deathRecapDisplay.column2_row1.SetText( "#KILLCARD_NAME_DISPLAY", killerName )
	}

	local totalSources = killerDamageSources.len() + assisterDamageSources.len()
	if ( killerDamageSources.len() == 0 )
	{
		sourceOneHasMods = 0
		file.deathRecapDisplay.column2_row2.SetText( damageSourceStrings[ killDamageSourceId ] )
		totalSources += 1
	}

	if( killerDamageSources.len() >= 1 )
	{
		sourceOneHasMods = IsValid( killerDamageSources[0].weaponMods ) ? killerDamageSources[0].weaponMods.len() : 0

		if ( killerDamageSources[0].weaponIcon )
		{
			file.deathRecapDisplay.deathRecapWeaponIcon_0.SetImage( killerDamageSources[0].weaponIcon )
			file.deathRecapDisplay.deathRecapWeaponIcon_0.SetWidth( 12 * GetContentScaleFactor()[0] )
			file.deathRecapDisplay.deathRecapWeaponIcon_0.Show()
		}
		else
		{
			file.deathRecapDisplay.deathRecapWeaponIcon_0.SetWidth( 0 )
		}

		//file.deathRecapDisplay.column1_row2.SetText( "#RECAP_DAMAGE_PERCENT", filteredDamagePercent )
	  	file.deathRecapDisplay.column2_row2.SetText( damageSourceStrings[ killerDamageSources[0].damageSourceId ] )
	    file.deathRecapDisplay.column2_row3.SetText( GetModString( killerDamageSources[0].weaponMods ) )

		if ( killerDamageSources[0].wasLethalWeapon )
		{
	    	file.deathRecapDisplay.column2_row2.SetColor( DEATHRECAP_LETHAL_WEAPON_HUD_COLOR )
	    	file.deathRecapDisplay.column2_row3.SetColor( DEATHRECAP_LETHAL_WEAPON_HUD_COLOR )
		}
		else
		{
	    	file.deathRecapDisplay.column2_row2.SetColor( DEATHRECAP_WEAPON_HUD_COLOR )
			file.deathRecapDisplay.column2_row3.SetColor( DEATHRECAP_WEAPON_HUD_COLOR )
		}

	    if ( killerDamageSources[0].burnCardWeapon )
	    	file.deathRecapDisplay.column2_row3.SetColor( BURN_CARD_WEAPON_HUD_COLOR[0], BURN_CARD_WEAPON_HUD_COLOR[1], BURN_CARD_WEAPON_HUD_COLOR[2], 255 )
	}

	if( killerDamageSources.len() >= 2 )
	{
		if ( killerDamageSources[1].weaponIcon )
		{
			file.deathRecapDisplay.deathRecapWeaponIcon_1.SetImage( killerDamageSources[1].weaponIcon )
			file.deathRecapDisplay.deathRecapWeaponIcon_1.SetWidth( 12 * GetContentScaleFactor()[0] )
			file.deathRecapDisplay.deathRecapWeaponIcon_1.Show()
		}
		else
		{
			file.deathRecapDisplay.deathRecapWeaponIcon_1.SetWidth( 0 )
		}

	  	if ( killerDamageSources[1].burnCard )
	  	{
	  		file.deathRecapDisplay.column2_row4.SetText( killerDamageSources[1].burnCardTitle )
			file.deathRecapDisplay.column2_row4.SetColor( BURN_CARD_WEAPON_HUD_COLOR[0], BURN_CARD_WEAPON_HUD_COLOR[1], BURN_CARD_WEAPON_HUD_COLOR[2], 255 )
			file.deathRecapDisplay.deathRecapWeaponIcon_1.SetColor( BURN_CARD_WEAPON_HUD_COLOR[0], BURN_CARD_WEAPON_HUD_COLOR[1], BURN_CARD_WEAPON_HUD_COLOR[2], 255 )
	  		sourceTwoHasMods = false
	  	}
	  	else
	  	{
		  	file.deathRecapDisplay.column2_row4.SetText( damageSourceStrings[ killerDamageSources[1].damageSourceId ] )
			file.deathRecapDisplay.column2_row5.SetText( GetModString( killerDamageSources[1].weaponMods ) )

			sourceTwoHasMods = IsValid( killerDamageSources[1].weaponMods ) ? killerDamageSources[1].weaponMods.len() : 0

			if ( killerDamageSources[1].wasLethalWeapon )
			{
		    	file.deathRecapDisplay.column2_row4.SetColor( DEATHRECAP_LETHAL_WEAPON_HUD_COLOR )
		    	file.deathRecapDisplay.column2_row5.SetColor( DEATHRECAP_LETHAL_WEAPON_HUD_COLOR )
			}
			else
			{
		    	file.deathRecapDisplay.column2_row4.SetColor( DEATHRECAP_WEAPON_HUD_COLOR )
				file.deathRecapDisplay.column2_row5.SetColor( DEATHRECAP_WEAPON_HUD_COLOR )
			}

		    if ( killerDamageSources[1].burnCardWeapon )
				file.deathRecapDisplay.column2_row5.SetColor( BURN_CARD_WEAPON_HUD_COLOR[0], BURN_CARD_WEAPON_HUD_COLOR[1], BURN_CARD_WEAPON_HUD_COLOR[2], 255 )
		}
	}

	if( assisterDamageSources.len() >= 1 )
	{
		if ( assisterDamageSources[0].weaponIcon )
		{
			file.deathRecapDisplay.deathRecapWeaponIcon_2.SetImage( assisterDamageSources[0].weaponIcon )
			file.deathRecapDisplay.deathRecapWeaponIcon_2.SetWidth( 12 * GetContentScaleFactor()[0] )
			file.deathRecapDisplay.deathRecapWeaponIcon_2.Show()
		}
		else
		{
			file.deathRecapDisplay.deathRecapWeaponIcon_2.SetWidth( 0 )
		}

		file.deathRecapDisplay.column1_row6.SetText( "#RECAP_ASSIST" )

		assister = assisterDamageSources[0].attacker
		assisterName = assisterDamageSources[0].attackerName
		if ( assisterName == null )
			assisterName = GetAttackerDisplayNamesDamageSourceId( assisterDamageSources[0].damageSourceId )

		if ( assister || assisterName )
		{
			if ( assister == localPlayer )
				assisterName = "#RECAP_YOURSELF"
			else
				assisterPetName = assisterDamageSources[0].attackerPetName

			local assisterHealthInfo =	GetDeathRecapHealthInfo( assister )

			if( assisterPetName == "" || assisterPetName == null )
			{
				file.deathRecapDisplay.column2_row6.SetText( "#KILLCARD_NAME_DISPLAY", assisterName)
			}
			else
			{
				//assisterName = ResizePlayerNamesForKillCard( assisterPetName, "...", 10 )
				file.deathRecapDisplay.column2_row6.SetText( "#KILLCARD_NAME_WITH_PET_DISPLAY", assisterName, assisterPetName )
			}
			file.deathRecapDisplay.healthStatus_Assister.SetText( "#KILLCARD_DAMAGE_PERCENT_DISPLAY", assisterHealthInfo.healthStatusText, assisterHealthInfo.syntax )
		}
		else
		{
			file.deathRecapDisplay.column2_row6.SetText( "" )
		}

		file.deathRecapDisplay.column2_row7.SetText( damageSourceStrings[ assisterDamageSources[0].damageSourceId ] )
		file.deathRecapDisplay.column2_row8.SetText( GetModString( assisterDamageSources[0].weaponMods ) )

		sourceThreeHasMods = IsValid( assisterDamageSources[0].weaponMods ) ? assisterDamageSources[0].weaponMods.len() : 0

	    if ( assisterDamageSources[0].burnCardWeapon )
			file.deathRecapDisplay.column2_row8.SetColor( BURN_CARD_WEAPON_HUD_COLOR[0], BURN_CARD_WEAPON_HUD_COLOR[1], BURN_CARD_WEAPON_HUD_COLOR[2], 255 )
		else
			file.deathRecapDisplay.column2_row8.SetColor( DEATHRECAP_WEAPON_HUD_COLOR )
	}

	if ( titanDoomed )
	{
		file.deathRecapDisplay.column1_row1.SetText( "#RECAP_DOOMED_BY" )
		file.deathRecapDisplay.column2_row1.SetColor( 0, 0, 0, 255)
		file.deathRecapDisplay.healthStatus_Killer.SetColor( 0, 0, 0, 255)
		file.deathRecapDisplay.column2_row6.SetColor( 0, 0, 0, 255)
		file.deathRecapDisplay.healthStatus_Assister.SetColor( 0, 0, 0, 255)
	}
	else
	{
		file.deathRecapDisplay.column1_row1.SetText( "#RECAP_KILLER" )
		file.deathRecapDisplay.column2_row1.SetColor( 255, 255, 255, 255)
		file.deathRecapDisplay.healthStatus_Killer.SetColor( 255, 255, 255, 255)
		file.deathRecapDisplay.column2_row6.SetColor( 255, 255, 255, 255)
		file.deathRecapDisplay.healthStatus_Assister.SetColor( 255, 255, 255, 255)
	}
	//Sets Rows 2-8
	switch ( totalSources )
	{
		case 3:
			file.deathRecapDisplay.background.SetImage( "../ui/deathrecap_bg_three_sources" )
			if ( titanDoomed )
				file.deathRecapDisplay.foreground.SetImage( "../ui/doomrecap_fg_three_sources" )
			else
				file.deathRecapDisplay.foreground.SetImage( "../ui/deathrecap_fg_three_sources" )

			DeathRecap_Hide_Show_Settings_Three_Sources( sourceOneHasMods, sourceTwoHasMods, sourceThreeHasMods )
			break

		case 2:
			if( killerDamageSources.len() == 2 )
			{
				file.deathRecapDisplay.background.SetImage( "../ui/deathrecap_bg_two_sources" )
				if ( titanDoomed )
					file.deathRecapDisplay.foreground.SetImage( "../ui/doomrecap_fg_two_sources" )
				else
					file.deathRecapDisplay.foreground.SetImage( "../ui/deathrecap_fg_two_sources" )

				DeathRecap_Hide_Show_Settings_Two_Sources( sourceOneHasMods, sourceTwoHasMods )
			}
			else
			{
				file.deathRecapDisplay.background.SetImage( "../ui/deathrecap_bg_two_sources_two_ppl" )
				if ( titanDoomed )
					file.deathRecapDisplay.foreground.SetImage( "../ui/doomrecap_fg_two_sources_two_ppl" )
				else
					file.deathRecapDisplay.foreground.SetImage( "../ui/deathrecap_fg_two_sources_two_ppl" )

				sourceTwoHasMods = IsValid( assisterDamageSources[0].weaponMods ) ? assisterDamageSources[0].weaponMods.len() : 0
				DeathRecap_Hide_Show_Settings_Two_Sources_Two_People( sourceOneHasMods, sourceTwoHasMods )
			}
			break

		case 1:
			file.deathRecapDisplay.background.SetImage( "../ui/deathrecap_bg_one_source" )
			if ( titanDoomed )
				file.deathRecapDisplay.foreground.SetImage( "../ui/doomrecap_fg_one_source" )
			else
				file.deathRecapDisplay.foreground.SetImage( "../ui/deathrecap_fg_one_source" )

			DeathRecap_Hide_Show_Settings_One_Source( sourceOneHasMods )
			break

		default:
			printt("Invalid number of total damage sources in Death Recap" )
			break
	}

	file.deathRecapDisplay.background.Show()
	file.deathRecapDisplay.foreground.Show()

	//Moving Parts
	local basePos = file.deathRecapDisplay.background.GetBasePos()
	file.deathRecapDisplay.background.SetPos( basePos[0] + DEATHRECAP_MOVE_HEIGHT, basePos[1]  )
	file.deathRecapDisplay.background.MoveOverTime( basePos[0], basePos[1], DEATHRECAP_MOVE_TIME )

	wait DEATHRECAP_SHOW_TIME - (2 * DEATHRECAP_MOVE_TIME)
	file.deathRecapDisplay.background.MoveOverTime( basePos[0] + DEATHRECAP_MOVE_HEIGHT, basePos[1], DEATHRECAP_MOVE_TIME )

	wait DEATHRECAP_MOVE_TIME
}

function GetModString( modArray )
{
	local combinedModString = ""
	if( modArray == null )
		return combinedModString

	local limit = modArray.len()
	foreach ( weaponMod in modArray )
	{
		local modString = weaponMod

		if( limit > 1 )
			combinedModString += modString + ", "
		else
			combinedModString += modString

		limit -= 1
	}

	return combinedModString
}

function HideDeathRecap()
{
	file.deathRecapDisplay.background.Hide()
	file.deathRecapDisplay.foreground.Hide()
	file.deathRecapDisplayGroup.Hide()
	file.deathRecapWeaponIconGroup.Hide()

	ClearDeathRecap()
}

function ClearDeathRecap()
{
	file.deathRecapDisplayGroup.SetText( "" )
}

function CompareDamageSources( a, b )
{
	if ( b.wasLethalWeapon > a.wasLethalWeapon )
		return 1
	else if ( a.wasLethalWeapon > b.wasLethalWeapon )
		return -1

	if ( a.damageAmount < b.damageAmount )
		return 1
	else if ( a.damageAmount > b.damageAmount )
		return -1

	return 0
}

function DeathRecap( attacker, damageSourceId )
{
	if ( DamageSourceIsValid( attacker, damageSourceId ) )
	    thread ShowDeathRecap( attacker, damageSourceId )
}

function DoomRecap( attacker, damageSourceId )
{
	if ( DamageSourceIsValid( attacker, damageSourceId ) )
	    thread ShowDeathRecap( attacker, damageSourceId, true )
}

function DamageSourceIsValid( attacker, damageSourceId )
{
	// Player killed self with a console command or script forced death
	if ( damageSourceId == eDamageSourceId.suicide )
		return false

	// Script forced death with Die()
	if ( attacker != null && attacker.IsWorld() )
		return false

	// Undefined damage source
	if ( damageSourceId == -1 )
	{
		if ( attacker )
		{
			local names = GetAttackerDisplayNamesFromClassname( attacker )
			printt( "Death recap encountered an invalid damage source. attacker: " + attacker + " attackerName: " + names.attackerName )
		}
		else // Should be environmental hazards only (trigger_hurt)
		{
			printt( "Death recap encountered an invalid damage source. attacker: " + attacker )
		}

		return false
	}


	return true
}

function GetPilotDamageHistory()
{
	local localPlayer = GetLocalViewPlayer()
	local damageHistory = []

	foreach ( damageRecord in localPlayer.s.recentDamageHistory )
	{
		if ( !damageRecord.victimIsTitan )
			damageHistory.append( damageRecord )
	}

	return damageHistory
}

function GetTitanDamageHistory()
{
	local localPlayer = GetLocalViewPlayer()
	local damageHistory = []

	foreach ( damageRecord in localPlayer.s.recentDamageHistory )
	{
		if ( damageRecord.victimIsTitan )
			damageHistory.append( damageRecord )
	}

	return damageHistory
}

function GetTopDamageSources( damageHistory, maxSourcesKiller, maxSourcesAssister, titanDoomed = false, killer = null)
{
	local localPlayer = GetLocalViewPlayer()
	local damageTotal = 0
	local damageInfo
	local killerDamageSources = []
	local otherDamageSources = []
	local lethalWeapon

	foreach ( damageRecord in damageHistory )
	{
		if( "lastDeathRecapTime" in localPlayer.s && damageRecord.time <= localPlayer.s.lastDeathRecapTime)
			continue
		local attacker = damageRecord.attackerWeakRef
		if( lethalWeapon == null )
			lethalWeapon = true
		else
			lethalWeapon = false

		local damageInfo = {}
		damageInfo.damageSourceId <- damageRecord.damageSourceId
		damageInfo.damageAmount <- damageRecord.damage
		damageInfo.attacker <- attacker
		damageInfo.attackerName <- damageRecord.attackerName
		damageInfo.attackerPetName <- damageRecord.attackerPetName
		damageInfo.wasLethalWeapon <- lethalWeapon
		damageInfo.weaponMods <- damageRecord.weaponMods
		damageInfo.burnCard <- false
		damageInfo.weaponIcon <- null
		damageInfo.burnCardWeapon <- damageRecord.damageType & DF_BURN_CARD_WEAPON

		if( killer == attacker )
		{
			if ( !UpdateExistingDamageSource( killerDamageSources, damageInfo ) )
				killerDamageSources.append( damageInfo )
		}
		else
		{
			if ( !UpdateExistingDamageSource( otherDamageSources, damageInfo ) )
				otherDamageSources.append( damageInfo )
		}

		damageTotal += damageRecord.damage
	}

	killerDamageSources.sort( CompareDamageSources )
	otherDamageSources.sort( CompareDamageSources )

	if ( killerDamageSources.len() >= maxSourcesKiller )
		killerDamageSources.resize( maxSourcesKiller )

	if ( otherDamageSources.len() >= maxSourcesAssister )
		otherDamageSources.resize( maxSourcesAssister )

	//local killerDamagePercent = AddDamagePercents( killerDamageSources, damageTotal )
	//AddDamagePercents( otherDamageSources, damageTotal )

	if ( titanDoomed == false )
	{
		if( "lastDeathRecapTime" in localPlayer.s )
			localPlayer.s.lastDeathRecapTime = Time()
		else
			localPlayer.s.lastDeathRecapTime <- Time()
	}


	local results = {}
	results.killerDamageSources <- killerDamageSources
	//results.killerDamagePercent <- killerDamagePercent
	results.assisterDamageSources <- otherDamageSources

	return results
}

function UpdateExistingDamageSource( damageInfoArray, damageInfo )
{
	foreach ( storedDamageInfo in damageInfoArray )
	{
		if ( damageInfo.damageSourceId == storedDamageInfo.damageSourceId && damageInfo.attacker == storedDamageInfo.attacker )
		{
			storedDamageInfo.damageAmount += damageInfo.damageAmount
			if ( damageInfo.wasLethalWeapon == true )
				storedDamageInfo.wasLethalWeapon = true
			return true
		}
	}

	return false
}

function AddDamagePercents( damageArray, damageTotal )
{
	local damageSource
	local roundedPercent
	local percentTotal = 0

	for ( local i = 0; i < damageArray.len(); )
	{
		damageSource = damageArray[i]
		roundedPercent = RoundToNearestInt( damageSource.damageAmount / damageTotal * 100 )

		//If NPC assister doesn't do a minimum threshold of damage, don't display his contribution to keep visual spam down on Death Recap.
		if ( IsValid( damageSource.attacker ) )
		{
			if ( !damageSource.wasLethalWeapon && roundedPercent <= 5 )
			{
				damageArray.remove( i )
				continue
			}
		}

		percentTotal += roundedPercent
		damageSource.damagePercent <- roundedPercent
		i++
	}

	return percentTotal
}

function DeathRecap_Hide_Show_Settings_Three_Sources( sourceOneHasMod, sourceTwoHasMod, sourceThreeHasMod )
{
	file.deathRecapDisplayGroup.Show()
	local scaleY = GetContentScaleFactor()[1] / 1.5

	local col2_row2_offset = 0
	local col2_row4_offset = 0
	local col2_row6_offset = 0
	local col2_row7_offset = 0

	if( !sourceOneHasMod )
	{
		col2_row2_offset += 6
		col2_row4_offset += -6

  		file.deathRecapDisplay.column2_row3.Hide()
	}

	if( !sourceTwoHasMod )
	{
		col2_row4_offset += 6
		col2_row6_offset += -6

		file.deathRecapDisplay.column2_row5.Hide()
	}

	if( !sourceThreeHasMod )
	{
		col2_row7_offset += 10

		file.deathRecapDisplay.column2_row8.Hide()
	}

    local basePos = file.deathRecapDisplay.deathRecapWeaponIcon_0.GetBasePos()
    file.deathRecapDisplay.deathRecapWeaponIcon_0.SetPos( basePos[0], basePos[1] + col2_row2_offset * scaleY )
 	local basePos = file.deathRecapDisplay.deathRecapWeaponIcon_1.GetBasePos()
    file.deathRecapDisplay.deathRecapWeaponIcon_1.SetPos( basePos[0], basePos[1] + col2_row4_offset * scaleY )
    local basePos = file.deathRecapDisplay.column2_row6.GetBasePos()
    file.deathRecapDisplay.column2_row6.SetPos( basePos[0], basePos[1] + col2_row6_offset * scaleY )
    local basePos = file.deathRecapDisplay.deathRecapWeaponIcon_2.GetBasePos()
    file.deathRecapDisplay.deathRecapWeaponIcon_2.SetPos( basePos[0], basePos[1] + col2_row7_offset * scaleY )
}

function DeathRecap_Hide_Show_Settings_Two_Sources( sourceOneHasMod, sourceTwoHasMod )
{
	local scaleY = GetContentScaleFactor()[1] / 1.5
	file.deathRecapDisplayGroup.Show()
	file.deathRecapDisplay.column1_row6.Hide()
	file.deathRecapDisplay.column2_row6.Hide()
	file.deathRecapDisplay.column2_row7.Hide()
	file.deathRecapDisplay.column2_row8.Hide()

	local col2_row2_offset = 0
	local col2_row4_offset = 0


	if ( !sourceOneHasMod )
	{
		col2_row2_offset += 6
		col2_row4_offset += -6

	    file.deathRecapDisplay.column2_row3.Hide()
	}

	if ( !sourceTwoHasMod )
	{
		col2_row4_offset += 6

		file.deathRecapDisplay.column2_row5.Hide()
	}

	local basePos = file.deathRecapDisplay.deathRecapWeaponIcon_0.GetBasePos()
    file.deathRecapDisplay.deathRecapWeaponIcon_0.SetPos( basePos[0], basePos[1] + col2_row2_offset * scaleY )
    local basePos = file.deathRecapDisplay.deathRecapWeaponIcon_1.GetBasePos()
    file.deathRecapDisplay.deathRecapWeaponIcon_1.SetPos( basePos[0], basePos[1] + col2_row4_offset * scaleY )
}

function DeathRecap_Hide_Show_Settings_Two_Sources_Two_People( sourceOneHasMod, sourceTwoHasMod )
{
	local scaleY = GetContentScaleFactor()[1] / 1.5
	local basePos = file.deathRecapDisplay.column1_row6.GetBasePos()
    file.deathRecapDisplay.column1_row6.SetPos( basePos[0], basePos[1] + 36 * scaleY )
    basePos = file.deathRecapDisplay.column2_row6.GetBasePos()
    file.deathRecapDisplay.column2_row6.SetPos( basePos[0], basePos[1] - 36 * scaleY )

 	file.deathRecapDisplayGroup.Show()
    file.deathRecapDisplay.column2_row4.Hide()
	file.deathRecapDisplay.column2_row5.Hide()

	if( !sourceOneHasMod )
	{
		local basePos = file.deathRecapDisplay.column1_row6.GetBasePos()
	    file.deathRecapDisplay.column1_row6.SetPos( basePos[0], basePos[1] + 36 * scaleY )
	    basePos = file.deathRecapDisplay.column2_row6.GetBasePos()
	    file.deathRecapDisplay.column2_row6.SetPos( basePos[0], basePos[1] - 42 * scaleY )
	    local basePos = file.deathRecapDisplay.deathRecapWeaponIcon_0.GetBasePos()
	    file.deathRecapDisplay.deathRecapWeaponIcon_0.SetPos( basePos[0], basePos[1] + 6 * scaleY )

	    file.deathRecapDisplay.column2_row3.Hide()
	}
	if( !sourceTwoHasMod )
	{
	    local basePos = file.deathRecapDisplay.deathRecapWeaponIcon_2.GetBasePos()
	    file.deathRecapDisplay.deathRecapWeaponIcon_2.SetPos( basePos[0], basePos[1] + 6 * scaleY )

		file.deathRecapDisplay.column2_row8.Hide()
	}
}

function DeathRecap_Hide_Show_Settings_One_Source( sourceOneHasMod )
{
	local scaleY = GetContentScaleFactor()[1]  / 1.5
 	file.deathRecapDisplayGroup.Hide()
    file.deathRecapDisplay.column1_row1.Show()
    file.deathRecapDisplay.healthStatus_Killer.Show()
    file.deathRecapDisplay.column2_row1.Show()
    file.deathRecapDisplay.column2_row2.Show()
    file.deathRecapDisplay.column2_row3.Show()

	if( !sourceOneHasMod )
	{
	    local basePos = file.deathRecapDisplay.deathRecapWeaponIcon_0.GetBasePos()
	    file.deathRecapDisplay.deathRecapWeaponIcon_0.SetPos( basePos[0], basePos[1] + 6 * scaleY )
	    file.deathRecapDisplay.column2_row3.Hide()
	}
}

function DisplayBurnCardInfoInKillCard( killer, killerDamageSources )
{
	local activeBurnCard = GetPlayerActiveBurnCard( killer )
	if( activeBurnCard )
	{
		local burnCardHudIcon = GetBurnCardHudIcon( activeBurnCard )
		local burnCardTitle = GetBurnCardTitle( GetPlayerActiveBurnCard( killer ) )

		if ( killerDamageSources.len() == 1 )
		{
			local damageInfo = {}
			damageInfo.damageSourceId <- null
			damageInfo.damageAmount <- null
			damageInfo.attacker <- null
			damageInfo.attackerName <- null
			damageInfo.wasLethalWeapon <- false
			damageInfo.weaponMods <- []
			damageInfo.burnCard <- true
			damageInfo.burnCardTitle <- burnCardTitle
			damageInfo.weaponIcon <- burnCardHudIcon
			damageInfo.burnCardWeapon <- false
			killerDamageSources.append( damageInfo )
		}
		else if ( killerDamageSources.len() == 2 )
		{
			killerDamageSources[1].weaponIcon = burnCardHudIcon
			killerDamageSources[1].burnCard = true
			killerDamageSources[1].burnCardTitle <- burnCardTitle
		}
	}

	return killerDamageSources
}

function TestDeathRecap( bool1, bool2, bool3 )
{
    local localPlayer = GetLocalViewPlayer()
	file.deathRecapDisplay.column1_row1.SetText( "KILLER" )
	file.deathRecapDisplay.column1_row6.SetText( "ASSIST" )

    file.deathRecapDisplay.column2_row1.SetText( "CORONACH( STEVEND-RE-1) - 100%" )
 	file.deathRecapDisplay.column2_row1.SetColor( 255, 255, 255, 255)
    file.deathRecapDisplay.column2_row2.SetText( "Longbow-DMR Sniper (Extended Mag)" )
    file.deathRecapDisplay.column2_row3.SetText( "" )
    file.deathRecapDisplay.column2_row3.SetColor( BURN_CARD_WEAPON_HUD_COLOR[0], BURN_CARD_WEAPON_HUD_COLOR[1], BURN_CARD_WEAPON_HUD_COLOR[2], 255 )
    file.deathRecapDisplay.column2_row4.SetText( "XO-16 (Accelerator)" )
    file.deathRecapDisplay.column2_row4.SetColor( 220, 220, 220, 255)
	file.deathRecapDisplay.column2_row5.SetColor( 220, 220, 220, 255)
	file.deathRecapDisplay.column2_row5.SetText( "" )
	file.deathRecapDisplay.column2_row6.SetColor( 255, 255, 255, 255)
	file.deathRecapDisplay.column2_row6.SetText( "Player 2 - 43%" )
	file.deathRecapDisplay.column2_row7.SetText( "R-97 (Silencer)" )
	file.deathRecapDisplay.column2_row7.SetColor( 220, 220, 220, 255)
	file.deathRecapDisplay.column2_row8.SetText( "" )
	file.deathRecapDisplay.column2_row8.SetColor( 220, 220, 220, 255)
	file.deathRecapDisplayGroup.ReturnToBasePos()
    file.deathRecapDisplayGroup.Show()
    file.deathRecapWeaponIconGroup.ReturnToBasePos()

	if ( bool1 != null && bool2 != null && bool3 != null )
	{
		DeathRecap_Hide_Show_Settings_Three_Sources( bool1, bool2, bool3 )
		file.deathRecapDisplay.foreground.SetImage( "../ui/deathrecap_fg_three_sources" )
		file.deathRecapDisplay.background.SetImage( "../ui/deathrecap_bg_three_sources" )
	}
	else if ( bool1 != null && bool2 != null )
	{
		DeathRecap_Hide_Show_Settings_Two_Sources( bool1, bool2 )
		file.deathRecapDisplay.foreground.SetImage( "../ui/deathrecap_fg_two_sources" )
		file.deathRecapDisplay.background.SetImage( "../ui/deathrecap_bg_two_sources" )
	}
	else if ( bool1 != null && bool2 == null && bool3 != null )
	{
		DeathRecap_Hide_Show_Settings_Two_Sources_Two_People( bool1, bool3 )
		file.deathRecapDisplay.foreground.SetImage( "../ui/deathrecap_fg_two_sources_two_ppl" )
		file.deathRecapDisplay.background.SetImage( "../ui/deathrecap_bg_two_sources_two_ppl" )
	}
	else if ( bool1 != null )
	{
		DeathRecap_Hide_Show_Settings_One_Source ( bool1 )
		file.deathRecapDisplay.foreground.SetImage( "../ui/deathrecap_fg_one_source" )
		file.deathRecapDisplay.background.SetImage( "../ui/deathrecap_bg_one_source" )
	}

    file.deathRecapDisplay.background.Show()
    file.deathRecapDisplay.foreground.Show()

	local basePos = file.deathRecapDisplay.background.GetBasePos()
	file.deathRecapDisplay.background.SetPos( basePos[0] + DEATHRECAP_MOVE_HEIGHT, basePos[1]  )
	file.deathRecapDisplay.background.MoveOverTime( basePos[0], basePos[1], DEATHRECAP_MOVE_TIME )

	//file.deathRecapDisplay.background.MoveOverTime( basePos[0] + DEATHRECAP_MOVE_HEIGHT, basePos[1], DEATHRECAP_MOVE_TIME )
}

function ResizePlayerNamesForKillCard( playerName, maxSizeSuffix, sizeReduction = 0 )
{
	local nameLength = playerName.len()

	local reducedSize = 17 - sizeReduction
	if ( nameLength <= ( reducedSize ) )
		return playerName
	else
		return playerName.slice( 0, reducedSize ) + maxSizeSuffix
}

function GetDeathRecapHealthInfo( entity )
{
	results <- {}
	results.healthStatusText <- ""
	results.syntax <- ""

	if( !IsValid( entity ) )
		return results

	if ( !IsAlive( entity ) )
	{
		results.healthStatusText = "#RECAP_DEAD"
	}
	else if ( entity.IsTitan() && entity.GetDoomedState() )
	{
		results.healthStatusText = "#RECAP_DOOMED"
	}
	else if ( IsAlive( entity ) )
	{
		if ( entity.GetHealth() == 0 )  //Special case for env triggers that kill you through damage e.g. floor is lava fog
			return results

		results.healthStatusText = ceil( 100 * entity.GetHealth().tofloat() / entity.GetMaxHealth().tofloat()  )
		results.syntax = "#RECAP_PERCENT"
	}

	return results
}