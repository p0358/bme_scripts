const TRACK_ENEMY_TIME = 7.0

function main()
{
	Globalize( Tracker_GetNumTitans )
}

function PlayerShouldTrackTarget( player, attacker )
{
	if ( !player.IsTitan() )
		return false

	if ( attacker == player )
		return false

	if ( !IsAlive( attacker ) )
		return false

	if ( attacker.IsTitan() )
		return true

	if ( !attacker.IsPlayer() )
		return false

		return true
}

function Tracker_CleanupAttackers( player )
{
	local table = {}
	table.numTitans <- 0
	table.numPilots <- 0

	foreach ( attacker, attackerInfo in clone player.s.trackedAttackers )
	{
		if ( !IsAlive( attacker ) || ( Time() > attackerInfo.lastAttackTime + TRACK_ENEMY_TIME ) )
		{
			delete player.s.trackedAttackers[ attacker ]
			continue
		}

		if ( attacker.IsTitan() )
			table.numTitans++
		else if ( attacker.IsHuman() )
			table.numPilots++
	}

	return table
}

function Tracker_AddTarget( player, attacker )
{
	local newlyAdded = false

	if ( !( attacker in player.s.trackedAttackers ) )
	{
		//printt( "Added attacker " + attacker + " " + attacker.GetClassname() + " " + attacker.GetEntIndex() )
		newlyAdded = true

		local attackerInfo = {}
		attackerInfo.lastAttackTime <- null

		player.s.trackedAttackers[ attacker ] <- attackerInfo
	}

	player.s.trackedAttackers[ attacker ].lastAttackTime = Time()

	return newlyAdded
}

function Tracker_PlayerAttackedTarget( player, victim )
{
	if ( !PlayerShouldTrackTarget( player, victim ) )
		return

	local previous = Tracker_CleanupAttackers( player )
	local curTitans = previous.numTitans
	local curPilots = previous.numPilots

	if ( Tracker_AddTarget( player, victim ) )
	{
		if ( victim.IsTitan() )
			curTitans++
	}

	if ( PlayTitanAddVO( player, curTitans, previous.numTitans ) )
		return
}
Globalize( Tracker_PlayerAttackedTarget )

function Tracker_PlayerAttackedByTarget( player, attacker )
{
	if ( !PlayerShouldTrackTarget( player, attacker ) )
		return

	local previous = Tracker_CleanupAttackers( player )
	local curTitans = previous.numTitans
	local curPilots = previous.numPilots

	if ( Tracker_AddTarget( player, attacker ) )
	{
		if ( attacker.IsTitan() )
			curTitans++
		else if ( attacker.IsHuman() )
			curPilots++
	}

	if ( PlayTitanAddVO( player, curTitans, previous.numTitans ) )
		return

	if ( curPilots > previous.numPilots )
	{
		if ( curPilots == 1 )
			TitanCockpit_PlayDialog( player, "ENEMY_PILOT_ATTACKING" )
		else
			TitanCockpit_PlayDialog( player, "MULTIPLE_ENEMY_PILOTS_ATTACKING" )
	}
}
Globalize( Tracker_PlayerAttackedByTarget )

function PlayTitanAddVO( player, curTitans, prevTitans )
{
	if ( curTitans == 2 && curTitans > prevTitans )
	{
		TitanCockpit_PlayDialog( player, "adds" )
		return true
	}
	else if ( curTitans >= 2 )
	{
		local friendlyTitanCount = GetNearbyFriendlyTitanCount( player )
		if ( friendlyTitanCount > 0 )
			TitanCockpit_PlayDialog( player, "multi_titan_engagement" )
		else
			TitanCockpit_PlayDialog( player, "outnumbered" )
		return true
	}
	return false
}

function GetNearbyFriendlyTitanCount( player )
{
	local playerTeam = player.GetTeam()
	local maxDistance = 2000
	local maxDistanceSqr = maxDistance * maxDistance
	local playerOrigin = player.GetOrigin()
	local titanCount = GetNPCArrayEx( "npc_titan", playerTeam, playerOrigin, maxDistance ).len()
	local playerArray = GetPlayerArray()

	foreach ( person in playerArray )
	{
		if ( !IsValid( person ) )
			continue

		if ( person == player )
			continue

		if ( person.GetTeam() != playerTeam )
			continue

		if ( person.IsTitan() && DistanceSqr( person.GetOrigin(), playerOrigin ) < maxDistanceSqr )
			titanCount++
	}

	return titanCount
}

function Tracker_GetNumTitans( player )
{
	Tracker_CleanupAttackers( player )

	local curTitans = 0
	foreach ( attacker, attackerInfo in player.s.trackedAttackers )
	{
		if ( IsAlive( attacker ) && attacker.IsTitan() )
			curTitans++
	}

	return curTitans
}