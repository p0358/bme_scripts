function main()
{
	Globalize( IsTitanFlagHome )
	Globalize( GetTitanFlag )
	//Globalize( GetTitanFlagState )
	Globalize( GetTitanFlagSpawnOrigin )
	Globalize( GetTitanFlagReturnOrigin )
	Globalize( PlayerHasTitanFlag )
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
	local players = GetPlayerArray()
	foreach ( player in players )
	{
		if ( !player.IsTitan() )
			continue

		if ( player.GetTitanSoul() != flag )
			continue

		return player
	}

	local titans = GetNPCArrayByClass( "npc_titan" )
	foreach ( titan in titans )
	{
		if ( titan.GetTitanSoul() != flag )
			continue

		return titan
	}

	return null
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


function PlayerHasTitanFlag( player )
{
	local flagEnt = GetTitanFlag()

	if ( !IsValid( flagEnt ) )
		return false

	if ( flagEnt.GetBossPlayer() == player )
		return true

	return false
}
