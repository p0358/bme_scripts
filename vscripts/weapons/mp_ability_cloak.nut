
function OnWeaponPrimaryAttack( attackParams )
{
	local ownerPlayer = self.GetWeaponOwner()

	Assert( IsValid( ownerPlayer) && ownerPlayer.IsPlayer() )
	if ( IsValid( ownerPlayer ) && ownerPlayer.IsPlayer() )
	{
		if ( ownerPlayer.GetCinematicEventFlags() & CE_FLAG_CLASSIC_MP_SPAWNING )
			return false

		if ( ownerPlayer.GetCinematicEventFlags() & CE_FLAG_INTRO )
			return false
	}

	if ( IsServer() )
	{
		local duration = self.GetWeaponModSetting( "fire_duration" )
		EnableCloak( self.GetWeaponOwner(), duration )
	}
	else
	{
		//printt( ownerPlayer.GetCloakEndTime() )
		//ownerPlayer.Signal( "PlayerUsedAbility" )
	}

	return 1
}
