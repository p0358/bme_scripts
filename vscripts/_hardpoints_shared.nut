function main()
{
	level.hardpointStrings <- {}
	level.hardpointStrings[0] <- "#CP_ALPHA"
	level.hardpointStrings[1] <- "#CP_BRAVO"
	level.hardpointStrings[2] <- "#CP_CHARLIE"
	level.hardpointStringIDs <- {}
	level.nextHardpointStringIdx <- 0

	level.capPointPilotScoring 		<- eCapPointPilotScoring.GRADUAL_RISE
	level.capPointAIScoring 		<- eCapPointAIScoring.PLAYERS_CAP_AI


	Globalize( GetHardpointByID )
	Globalize( GetHardpointName )
	Globalize( GetHardpointIcon )
	Globalize( GetHardpointStringID )
	Globalize( GetCapPower )
	Globalize( GetCapPowerFromTables )
	Globalize( GetEnemyCount )
	Globalize( GetFriendlyCount )
	Globalize( GetEnemyPlayerCount )
	Globalize( GetFriendlyPlayerCount )

	RegisterHardpointString( "a",			"#CP_ALPHA",				"a" )
	RegisterHardpointString( "b",			"#CP_BRAVO",				"b" )
	RegisterHardpointString( "c",			"#CP_CHARLIE",				"c" )
	RegisterHardpointString( "dogwhistle",	"Dogwhistle",		"HUD/hardpoint" )
	RegisterHardpointString( "market",		"Market",			"HUD/hardpoint" )
	RegisterHardpointString( "powerplant",	"Power Plant",		"HUD/hardpoint" )
	RegisterHardpointString( "titangarage",	"Titan Garage",		"HUD/hardpoint" )
	RegisterHardpointString( "workshop",	"Workshop",			"HUD/hardpoint" )
	RegisterHardpointString( "watermill",	"Water Mill",		"HUD/hardpoint" )
	RegisterHardpointString( "mayorshouse",	"Mayor's House",	"HUD/hardpoint" )
	RegisterHardpointString( "bar",				"Bar",					"HUD/hardpoint" )
	RegisterHardpointString( "commarray",		"Communications Array",	"HUD/hardpoint" )
	RegisterHardpointString( "watertower",		"Water Tower",			"HUD/hardpoint" )
	RegisterHardpointString( "garage",			"Garage",				"HUD/hardpoint" )
	RegisterHardpointString( "mausoleum",		"Mausoleum",			"HUD/hardpoint" )
	RegisterHardpointString( "temple",			"Temple",				"HUD/hardpoint" )
	RegisterHardpointString( "opstower",		"Operations Tower",		"HUD/hardpoint" )
	RegisterHardpointString( "laboratory",		"Laboratory",			"HUD/hardpoint" )
	RegisterHardpointString( "armory",			"Armory",				"HUD/hardpoint" )
	RegisterHardpointString( "landingpad",		"Landing Pad",			"HUD/hardpoint" )
	RegisterHardpointString( "cargobays",		"Cargo Bays",			"HUD/hardpoint" )
	RegisterHardpointString( "hangar",			"Hangar",				"HUD/hardpoint" )
	RegisterHardpointString( "marvinrepair",	"Marvin Repair Bay",	"HUD/hardpoint" )
	RegisterHardpointString( "construction",	"Construction Site",	"HUD/hardpoint" )
	RegisterHardpointString( "warehouse",		"Warehouse",			"HUD/hardpoint" )
	RegisterHardpointString( "refinery",		"Refinery",				"HUD/hardpoint" )
	RegisterHardpointString( "turretcontrol",	"Turret Control",		"HUD/hardpoint" )
	RegisterHardpointString( "elevatorcontrol",	"Elevator Control",		"HUD/hardpoint" )

	PrecacheHardpointVO()
}

function RegisterHardpointString( stringID, stringName, iconName )
{
	local hardpointData = { stringName = stringName, iconName = iconName  }

	if ( IsServer() )
		level.hardpointStrings[ stringName ] <- level.nextHardpointStringIdx
	else
		level.hardpointStrings[ level.nextHardpointStringIdx ] <- hardpointData

	level.hardpointStringIDs[ level.nextHardpointStringIdx ] <- stringID

	level.nextHardpointStringIdx++
}

function GetHardpointName( id )
{
	Assert( IsClient() )
	return level.hardpointStrings[ id ].stringName
}

function GetHardpointIcon( id )
{
	Assert( IsClient() )
	return level.hardpointStrings[ id ].iconName
}

function GetHardpointStringID( id )
{
	return level.hardpointStringIDs[ id ]
}

function GetHardpointByID( id )
{
	Assert( IsServer() )

	local hardpoint = null

	foreach ( hardpoint in level.hardpoints )
	{
		if ( hardpoint.GetHardpointID() == id )
			return hardpoint
	}

	return hardpoint
}

function GetEnemyCount( hardpointEnt, player )
{
	local enemyCount
	if ( player.GetTeam() == TEAM_IMC )
		enemyCount = hardpointEnt.GetHardpointAICount( TEAM_MILITIA ) + hardpointEnt.GetHardpointPlayerCount( TEAM_MILITIA )
	else if ( player.GetTeam() == TEAM_MILITIA )
		enemyCount = hardpointEnt.GetHardpointAICount( TEAM_IMC ) + hardpointEnt.GetHardpointPlayerCount( TEAM_IMC )
	return enemyCount
}

function GetFriendlyCount( hardpointEnt, player )
{
	local friendlyCount
	if ( player.GetTeam() == TEAM_IMC )
		friendlyCount = hardpointEnt.GetHardpointAICount( TEAM_IMC ) + hardpointEnt.GetHardpointPlayerCount( TEAM_IMC )
	else if ( player.GetTeam() == TEAM_MILITIA )
		friendlyCount = hardpointEnt.GetHardpointAICount( TEAM_MILITIA ) + hardpointEnt.GetHardpointPlayerCount( TEAM_MILITIA )
	return friendlyCount
}

function GetEnemyPlayerCount( hardpointEnt, player )
{
	local enemyCount
	if ( player.GetTeam() == TEAM_IMC )
		enemyCount = hardpointEnt.GetHardpointPlayerCount( TEAM_MILITIA )
	else if ( player.GetTeam() == TEAM_MILITIA )
		enemyCount = hardpointEnt.GetHardpointPlayerCount( TEAM_IMC )
	return enemyCount
}

function GetFriendlyPlayerCount( hardpointEnt, player )
{
	local friendlyCount
	if ( player.GetTeam() == TEAM_IMC )
		friendlyCount = hardpointEnt.GetHardpointPlayerCount( TEAM_IMC )
	else if ( player.GetTeam() == TEAM_MILITIA )
		friendlyCount = hardpointEnt.GetHardpointPlayerCount( TEAM_MILITIA )
	return friendlyCount
}


function GetCapPower( hardpointEnt )
{
	local teamPilots = {}
	teamPilots[ TEAM_IMC ] <- hardpointEnt.GetHardpointPlayerCount( TEAM_IMC )
	teamPilots[ TEAM_MILITIA ] <- hardpointEnt.GetHardpointPlayerCount( TEAM_MILITIA )

	local teamTitans = {}
	teamTitans[ TEAM_IMC ] <- hardpointEnt.GetHardpointPlayerTitanCount( TEAM_IMC )
	teamTitans[ TEAM_MILITIA ] <- hardpointEnt.GetHardpointPlayerTitanCount( TEAM_MILITIA )

	local teamAI = {}
	teamAI[ TEAM_IMC ] <- hardpointEnt.GetHardpointAICount( TEAM_IMC )
	teamAI[ TEAM_MILITIA ] <- hardpointEnt.GetHardpointAICount( TEAM_MILITIA )

	return GetCapPowerFromTables( hardpointEnt, teamPilots, teamTitans, teamAI )
}


function GetCapPowerFromTables( hardpointEnt, teamPilots, teamTitans, teamAI )
{
	local teams = [ TEAM_IMC, TEAM_MILITIA ]

	if ( !CAPTURE_POINT_TITANS_BREAK_CONTEST )
	{
		teamTitans[ TEAM_IMC ] = 0
		teamTitans[ TEAM_MILITIA ] = 0
	}

	local teamPower = {}
	foreach ( team in teams )
	{
		teamPower[ team ] <- 0
	}

	foreach ( team in teams )
	{
		teamPower[ team ] += GetTeamPowerFromPilots( team, teamPilots )
	}

	// do these in order because ai power can care about pilot power
	foreach ( team in teams )
	{
		teamPower[ team ] += GetTeamPowerFromAI( team, teamAI, teamPower )
	}


	local powerTable = {}

	powerTable.contested <- false

	if ( CAPTURE_POINT_TITANS_BREAK_CONTEST )
	{
		if ( teamTitans[ TEAM_IMC ] && !teamTitans[ TEAM_MILITIA ] )
		{
			powerTable.contested = false
			teamPower[ TEAM_MILITIA ] = 0
		}
		else if ( teamTitans[ TEAM_MILITIA ] && !teamTitans[ TEAM_IMC ] )
		{
			powerTable.contested = false
			teamPower[ TEAM_IMC ] = 0
		}
		else if ( teamPower[ TEAM_IMC ] && teamPower[ TEAM_MILITIA ] )
		{
			powerTable.contested = true
		}
	}
	else if ( teamPower[ TEAM_IMC ] && teamPower[ TEAM_MILITIA ] )
	{
		powerTable.contested = true
	}

	powerTable.strongerTeam <- TEAM_UNASSIGNED
	if ( !powerTable.contested )
	{
		// there is no stronger team when both teams are present
		if ( teamPower[ TEAM_IMC ] > teamPower[ TEAM_MILITIA ] )
			powerTable.strongerTeam = TEAM_IMC
		else if ( teamPower[ TEAM_MILITIA ] > teamPower[ TEAM_IMC ])
			powerTable.strongerTeam = TEAM_MILITIA
	}

	local powerDif = fabs( teamPower[ TEAM_IMC ] - teamPower[ TEAM_MILITIA ] )
	powerTable.power <- min( powerDif, CAPTURE_POINT_MAX_CAP_POWER )

	return powerTable
}


function GetTeamPowerFromPilots( team, teamPilots )
{
	switch ( level.capPointPilotScoring )
	{
		case eCapPointPilotScoring.REWARD_MORE_PLAYERS:

			// reward progressively more points per player that is in the hardpoint
			local pilots = teamPilots[ team ]
			local power = pilots * pilots * CAPTURE_POINT_PLAYER_CAP_POWER
			return power

		case eCapPointPilotScoring.GRADUAL_RISE:
		default:

			// reward a max of 2x CAPTURE_POINT_PLAYER_CAP_POWER if you have 2 or more players in the hardpoint
			local pilots = teamPilots[ team ]
			local power = min( CAPTURE_POINT_PLAYER_CAP_POWER * 2, pilots )

			if ( pilots )
			{
				// give an additional CAPTURE_POINT_PLAYER_CAP_POWER for each player you have in the hard point, past the first one
				pilots--
				power += pilots * CAPTURE_POINT_PLAYER_CAP_POWER
			}
			return power
	}
}

function GetTeamPowerFromAI( team, teamAI, teamPower )
{
	switch ( level.capPointAIScoring )
	{
		case eCapPointAIScoring.CONTEST_ALWAYS:
			local power = teamAI[ team ] * CAPTURE_POINT_AI_CAP_POWER
			return power

		case eCapPointAIScoring.PLAYERS_CAP_AI:
		default:

			local power = teamAI[ team ] * CAPTURE_POINT_AI_CAP_POWER
			local otherTeamPower = teamPower[ GetOtherTeam( team ) ]

			if ( otherTeamPower )
			{
				// AI can't cap on their own when an enemy player is around.
				power = min( otherTeamPower, power )
			}
			return power
	}
}

function PrecacheHardpointVO()
{
}
