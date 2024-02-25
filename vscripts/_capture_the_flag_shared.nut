function main()
{
	Globalize( IsFlagHome )
	Globalize( GetFlagForTeam )
	Globalize( GetFlagStateForTeam )
	Globalize( GetFlagSpawnOriginForTeam )
	Globalize( PlayerHasEnemyFlag )

	if ( IsServer() )
	{
		Minimap_PrecacheMaterial( "vgui/HUD/ctf_flag_friendly_minimap" )
		Minimap_PrecacheMaterial( "vgui/HUD/ctf_flag_friendly_missing" )
		Minimap_PrecacheMaterial( "vgui/HUD/ctf_flag_enemy_minimap" )
	}
}


function IsFlagHome( flag )
{
	local flagTeam = flag.GetTeam()

	if ( flag.GetParent() )
		return false

	if ( Distance( GetFlagSpawnOriginForTeam( flagTeam ), flag.GetOrigin() ) > 32 /*tmp*/ )
		return false

	return true
}


function GetFlagForTeam( team )
{
	return level.teamFlags[team]
}


function GetFlagStateForTeam( team )
{
	return GetFlagState( GetFlagForTeam( team ) )
}


function GetFlagSpawnOriginForTeam( team )
{
	if ( IsServer() )
		return level.flagSpawnPoints[team].GetOrigin()
	else
		return level.flagSpawnPoints[team]
}


function PlayerHasEnemyFlag( player )
{
	local otherTeam = GetOtherTeam( player.GetTeam() )
	local otherFlag = GetFlagForTeam( otherTeam )

	if ( !IsValid( otherFlag ) )
		return false

	if ( otherFlag.GetParent() == player )
		return true

	return false
}


