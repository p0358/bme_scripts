function main()
{
	Globalize( IsTitanFlagHome )
	Globalize( GetTitanFlag )
	//Globalize( GetTitanFlagState )
	Globalize( GetTitanFlagSpawnOrigin )
	Globalize( GetTitanFlagReturnOrigin )
	Globalize( PlayerIsTitanFlag )
	Globalize( GetTitanFromFlag )

	if ( IsServer() )
	{
		Minimap_PrecacheMaterial( "vgui/HUD/ctf_flag_friendly_minimap" )
		Minimap_PrecacheMaterial( "vgui/HUD/ctf_flag_friendly_missing" )
		Minimap_PrecacheMaterial( "vgui/HUD/ctf_flag_enemy_minimap" )
	}
}

function GetTitanFromFlag( flag )
{
	if ( !flag.HasValidTitan() )
		return null

	return flag.GetTitan()
}


function IsTitanFlagHome( flag )
{
	if ( !IsValid( GetTitanFromFlag( flag ) ) )
		return false

	if ( GetTitanFromFlag( flag ).IsPlayer() )
		return false

	if ( Distance( GetTitanFlagSpawnOrigin(), GetTitanFromFlag( flag ).GetOrigin() ) > 64 /*tmp*/ )
		return false

	return true
}


function GetTitanFlag()
{
	return level.teamFlag
}


function GetTitanFlagStateForTeam()
{
	return GetTitanFlagState( GetTitanFlag() )
}


function GetTitanFlagSpawnOrigin()
{
	if ( !IsValid( level.flagSpawnPoint ) )
		return null

	return level.flagSpawnPoint.GetOrigin()
}

function GetTitanFlagReturnOrigin()
{
	if ( !IsValid( level.flagReturnPoint ) )
		return null

	return level.flagReturnPoint.GetOrigin()
}


function PlayerIsTitanFlag( player )
{
	local flagEnt = GetTitanFlag()

	if ( !player.IsTitan() )
		return

	if ( !IsValid( flagEnt ) )
		return false

	if ( flagEnt == player.GetTitanSoul() )
		return true

	return false
}
