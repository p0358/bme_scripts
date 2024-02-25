PrecacheParticleSystem( "P_heal" )

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

	local cardRef = GetPlayerActiveBurnCard( ownerPlayer )
	if ( cardRef == "bc_stim_forever" )
		return 0

	//		if ( ownerPlayer.stimmedForever )

	if ( IsClient() )
	{
		if ( InPrediction() && !IsFirstTimePredicted() ) //Prevent client side effect from being created more than once due to prediction
		{
			return 1
		}
	}

	local duration = self.GetWeaponModSetting( "fire_duration" )
	StimPlayer( ownerPlayer, duration )

	PlayWeaponSound_1p3p( "Pilot_Stimpack_Activate", "Pilot_Stimpack_Activate" )

	return 1
}
