function main()
{
	Globalize( StoreDamageHistoryAndUpdate )
	Globalize( WasRecentlyHitForDamage )
	Globalize( WasRecentlyHitByEntity )
	Globalize( WasRecentlyHitByDamageSourceId )
	Globalize( GetLatestAssistingPlayerInfo )
	Globalize( GetTotalDamageTakenInTime )
	Globalize( GetTotalDamageTakenByPlayer )
	Globalize( GetDamageSortedByAttacker )
	Globalize( GetDamageTakenSinceFullHealth )
	Globalize( GetTitansHitMeInTime )
	Globalize( GetLastDamageTime )
	Globalize( GetDamageEventsForTime )
	Globalize( WasRecentlyHitForDamageType )
	Globalize( GetRodeoAttacksByPlayer )
}

function StoreDamageHistoryAndUpdate( player, maxTime, damage, damageOrigin, damageType, damageSourceId = null, attacker = null, weaponMods = null )
{
	if ( !( "recentDamageHistory" in player.s ) )
		player.s.recentDamageHistory <- []
//	printt( "stored hit for " + player )
	local table = {}
	local time = Time()

	if ( IsServer() )
	{
		if ( !attacker.IsPlayer() )
		{
			local newAttacker = GetPlayerFromEntity( attacker )
			if ( IsValid_ThisFrame( newAttacker ) )
				attacker = newAttacker
		}
	}

	if ( damageType & DF_VORTEX_REFIRE )
		damageSourceId = eDamageSourceId.mp_titanweapon_vortex_shield

	table.attackerName <- null
	table.attackerPetName  <- null
	local attackerWeakRef = null
	if ( IsValid( attacker ) )
	{
		attackerWeakRef = attacker.weakref()
		if ( IsClient() )
		{
			local names = GetAttackerDisplayNamesFromClassname( attacker )
			table.attackerName = names.attackerName
			table.attackerPetName = names.attackerPetName
		}
	}
	table.origin <- damageOrigin
	table.damage <- damage
	table.damageType <- damageType
	table.damageSourceId <- damageSourceId
	table.attackerWeakRef <- attackerWeakRef
	table.time <- time
	table.weaponMods <- weaponMods

	if ( player.IsTitan() )
		table.victimIsTitan <- true
	else
		table.victimIsTitan <- false

	UpdateDamageHistory( player, maxTime, time )

	player.s.recentDamageHistory.insert( 0, table )

	return table
}

function GetLastDamageTime( player )
{
	if ( !player.s.recentDamageHistory.len() )
		return -1

	return player.s.recentDamageHistory[0].time
}

function GetDamageEventsForTime( player, hitTime )
{
	local time = Time() - hitTime

	local events = []

	foreach ( event in player.s.recentDamageHistory )
	{
		if ( event.time < time )
			return events

		events.insert( 0, event )
	}

	return events
}

function UpdateDamageHistory( player, maxTime, time )
{
	// remove old damage history entries
	local i
	local history
	local removeTime = time - maxTime
	for ( i = player.s.recentDamageHistory.len() - 1; i >= 0; i-- )
	{
		history = player.s.recentDamageHistory[i]
		if ( history.time > removeTime )
			return

		player.s.recentDamageHistory.remove(i)
	}
}

function WasRecentlyHitByEntity( player, entity, hitTime )
{
	local time = Time() - hitTime
	// remove old damage history entries
	local i
	local history

	for ( i = 0; i < player.s.recentDamageHistory.len(); i++ )
	{
		history = player.s.recentDamageHistory[i]
		if ( history.time < time )
			continue

		if ( history.attackerWeakRef == entity.weakref() )
			return true
	}

	return false
}

function WasRecentlyHitForDamage( player, damageAmount, hitTime )
{
	local time = Time() - hitTime
	// remove old damage history entries
	local i
	local history

	for ( i = 0; i < player.s.recentDamageHistory.len(); i++ )
	{
		history = player.s.recentDamageHistory[i]
		if ( history.time < time )
			continue

		if ( history.damage >= damageAmount )
			return true
	}

	return false
}

function WasRecentlyHitForDamageType( player, damageType, hitTime )
{
	local time = Time() - hitTime
	// remove old damage history entries
	local i
	local history

	for ( i = 0; i < player.s.recentDamageHistory.len(); i++ )
	{
		history = player.s.recentDamageHistory[i]
		if ( history.time < time )
			continue

		if ( history.damageType == damageType )
			return true
	}

	return false
}

function GetTotalDamageTakenInTime( player, hitTime )
{
	local time = Time() - hitTime
	// remove old damage history entries
	local i
	local history

	local total = 0
	for ( i = 0; i < player.s.recentDamageHistory.len(); i++ )
	{
		history = player.s.recentDamageHistory[i]
		if ( history.time < time )
			continue

		total += history.damage
	}

	return total
}

function GetTitansHitMeInTime( player, hitTime )
{
	local time = Time() - hitTime
	// remove old damage history entries
	local i
	local history
	local titans = {}

	for ( i = 0; i < player.s.recentDamageHistory.len(); i++ )
	{
		history = player.s.recentDamageHistory[i]
		if ( history.time < time )
			continue

		if ( !IsValid( history.attackerWeakRef ) )
			continue
		if ( !history.attackerWeakRef.IsTitan() )
			continue
		if ( history.attackerWeakRef in titans )
			continue

		titans[ history.attackerWeakRef ] <- history.attackerWeakRef
	}

	return titans
}

function GetTotalDamageTakenByPlayer( player, attacker )
{
	Assert( IsValid( attacker ) )
	// remove old damage history entries
	local i
	local history

	local total = 0
	for ( i = 0; i < player.s.recentDamageHistory.len(); i++ )
	{
		history = player.s.recentDamageHistory[i]
		if ( history.attackerWeakRef != attacker )
			continue

		total += history.damage
	}

	return total
}

function GetDamageSortedByAttacker( player )
{
	// remove old damage history entries
	local i
	local history

	local table = {}

	for ( i = 0; i < player.s.recentDamageHistory.len(); i++ )
	{
		history = player.s.recentDamageHistory[i]
		if ( !history.attackerWeakRef )
			continue
		if ( !( history.attackerWeakRef in table ) )
		{
			table[ history.attackerWeakRef ] <- 0
		}

		table[ history.attackerWeakRef ] += history.damage
	}

	return table
}

function WasRecentlyHitByDamageSourceId( player, damageSourceId, hitTime )
{
	local time = Time() - hitTime
	// remove old damage history entries
	local i
	local history

	for ( i = 0; i < player.s.recentDamageHistory.len(); i++ )
	{
		history = player.s.recentDamageHistory[i]
		if ( history.time < time )
			continue

		if ( history.damageSourceId == damageSourceId )
			return true
	}

	return false
}

// Used to get the player that did the last damage in cases where an NPC, not associated with a player, gives the killing blow.
// at this point not every entity uses s.recentDamageHistory so some entities won't give assist points when they die ( soldiers, turrets etc. )
function GetLatestAssistingPlayerInfo( entity )
{
	local lastTime = 0
	local currentTime = Time()
	local assistingPlayer = null
	assistingPlayerInfo <- {}
	assistingPlayerInfo.player <- null
	assistingPlayerInfo.damageSourceId <- null
	assistingPlayerInfo.assistTime <- null

	if ( "recentDamageHistory" in entity.s )
	{
		foreach ( damageTable in entity.s.recentDamageHistory )
		{
			if ( !IsValid( damageTable.attackerWeakRef ) || !damageTable.attackerWeakRef.IsPlayer() )
				continue

			if ( damageTable.time <= lastTime )
				continue

			if ( currentTime - damageTable.time >= MAX_NPC_KILL_STEAL_PREVENTION_TIME )
				continue

			lastTime = damageTable.time
			assistingPlayerInfo.player = damageTable.attackerWeakRef
			assistingPlayerInfo.damageSourceId = damageTable.damageSourceId
			assistingPlayerInfo.assistTime = damageTable.time
		}
	}

	return assistingPlayerInfo
}

function GetDamageTakenSinceFullHealth( player )
{
	if ( !( "lastFullHealthTime" in player.s ) )
		player.s.lastFullHealthTime <- Time()

	if ( !( "recentDamageHistory" in player.s ) )
		player.s.recentDamageHistory <- []

	local history
	local attackers = {}
	local returnData = {}
	returnData.numAttackers <- 0
	returnData.table <- []
	local compareTime = player.s.lastFullHealthTime - 0.1

	//PrintTable( player.s.recentDamageHistory )

	for ( local i = 0; i < player.s.recentDamageHistory.len(); i++ )
	{
		history = player.s.recentDamageHistory[i]
		if ( history.time < compareTime )
			continue

		local source = GetNameFromDamageSourceID( history.damageSourceId )
		if ( !source )
			continue
		local amount = history.damage
		if ( !amount )
			continue

		local sourceTable = null
		foreach( data in returnData.table )
		{
			if ( source == data.source )
			{
				sourceTable = data
				break
			}
		}

		if ( sourceTable == null )
		{
			sourceTable = {}
			sourceTable.source <- source
			sourceTable.amount <- 0
			returnData.table.append( sourceTable )
		}

		sourceTable.amount += amount
		if ( history.attackerWeakRef == null )
			continue

		if ( !( history.attackerWeakRef in attackers ) )
			attackers[ history.attackerWeakRef ] <- 0
		attackers[ history.attackerWeakRef ]++
	}

	returnData.table.sort( DamageHistoryCompare )
	returnData.numAttackers = attackers.len()

	return returnData
}

function DamageHistoryCompare( a, b )
{
	if ( a.amount < b.amount )
		return 1
	if ( a.amount > b.amount )
		return -1
	return 0
}

function GetRodeoAttacksByPlayer( player, attacker, time )
{
	local validTime = Time() - time
	local history
	local events = []

	if ( !IsValid( player ) )
		return events

	if ( !player.IsTitan() )
		return events

	if ( !IsValid( attacker ) )
		return events

	local soul = player.GetTitanSoul()
	if ( !IsValid( soul ) )
		return events

	for ( local i = 0 ; i < soul.s.recentDamageHistory.len() ; i++ )
	{
		history = soul.s.recentDamageHistory[ i ]

		if ( history.time < validTime )
			continue

		if ( history.attackerWeakRef != attacker.weakref() && history.attackerWeakRef != attacker )
			continue

		if ( !( history.damageType & DF_RODEO ) )
			continue

		events.append( history )
	}

	return events
}