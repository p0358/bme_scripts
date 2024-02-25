
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

	local duration = self.GetWeaponModSetting( "fire_duration" )

	ActivateSonar( self, duration )

	return 1
}