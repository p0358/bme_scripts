
function OnWeaponPrimaryAttack( attackParams )
{
	local ownerPlayer = self.GetWeaponOwner()

	Assert( IsValid( ownerPlayer) && ownerPlayer.IsPlayer() )

	if ( ownerPlayer.GetHealth() == ownerPlayer.GetMaxHealth() )
		return 0

	if ( IsServer() )
	{
	}
	else
	{
	}

	return 1
}
