//Split this out into _objective_shared, _objective and cl_objective once QA gets a chance to hammer at it.
function main()
{
	Globalize( RegisterObjective )
	convIndex <- 0 //Note that objectiveIndex 0 is reserved by code to mean no objective active!

	level.objToIndex <- {}
	level.teamActiveObjective <- { [TEAM_IMC] = null, [TEAM_MILITIA] = null }

	Globalize( SetCurrentTeamObjectiveForPlayer )
	Globalize( SetTeamActiveObjective )
	Globalize( ClearTeamActiveObjective )

	Globalize( SetPlayerActiveObjective )
	Globalize( ClearPlayerActiveObjective )
}

function RegisterObjective( objectiveName )
{
	convIndex++
	level.objToIndex[ objectiveName ] <- convIndex
}

function CreateTeamActiveObjectiveTable( objectiveName, objectiveTimer = 0, objectiveEntity = null )
{
	local table = {}
	table.objectiveName <- objectiveName
	table.objectiveTimer <- objectiveTimer
	table.objectiveEntity <- objectiveEntity

	return table
}

function SetCurrentTeamObjectiveForPlayer( player )
{
	local team = player.GetTeam()
	local objectiveTable = GetTeamActiveObjective( team )

	if ( objectiveTable )
	{
		local objectiveName = objectiveTable.objectiveName
		local objectiveTimer = objectiveTable.objectiveTimer
		local objectiveEntity = objectiveTable.objectiveEntity
		SetPlayerActiveObjective( player, objectiveName, objectiveTimer, objectiveEntity )
	}
}

function GetTeamActiveObjective( team )
{
	Assert( team == TEAM_IMC || team == TEAM_MILITIA )
	return level.teamActiveObjective[ team ]
}

function SetTeamActiveObjective( team, objectiveName, objectiveTimer = 0, objectiveEntity = null )
{
	Assert( team == TEAM_IMC || team == TEAM_MILITIA )
	local players = GetPlayerArrayOfTeam( team )

	local objectiveIndex = level.objToIndex[ objectiveName ]

	foreach ( player in players )
	{
		SetPlayerActiveObjective_Internal( player, objectiveIndex, objectiveTimer, objectiveEntity )
	}

	level.teamActiveObjective[ team ] = CreateTeamActiveObjectiveTable( objectiveName, objectiveTimer, objectiveEntity )
}

function ClearTeamActiveObjective( team )
{
	Assert( team == TEAM_IMC || team == TEAM_MILITIA )
	local players = GetPlayerArrayOfTeam( team )
	foreach ( player in players )
	{
		ClearPlayerActiveObjective( player )
	}

	level.teamActiveObjective[ team ] = null

}

function SetPlayerActiveObjective( player, objectiveName, objectiveTimer = 0, objectiveEntity = null )
{
	local objectiveIndex = level.objToIndex[ objectiveName ]

	SetPlayerActiveObjective_Internal( player, objectiveIndex, objectiveTimer, objectiveEntity )
}

function SetPlayerActiveObjective_Internal( player, objectiveIndex, objectiveTimer, objectiveEntity  )
{
	player.SetObjectiveEndTime( objectiveTimer )
	player.SetObjectiveEntity( objectiveEntity )
	player.SetObjectiveIndex( objectiveIndex )
}

function ClearPlayerActiveObjective( player )
{
	player.SetObjectiveEndTime( 0 )
	player.SetObjectiveEntity( null )
	player.SetObjectiveIndex( 0 )
}

