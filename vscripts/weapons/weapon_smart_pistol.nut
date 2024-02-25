
SetWeaponSound( "fire_suppressed_layer1", "Weapon_SmartPistol.SuppressedFire_Layer1" )
SetWeaponSound( "fire_suppressed_layer2", "Weapon_SmartPistol.SuppressedFire_Layer2" )
SetWeaponSound( "deployVO", "Weapon_SmartPistol.DeployVO" )

SetWeaponEffect( "muzzle_flash_fp", "wpn_muzzleflash_pistol_FP" )
SetWeaponEffect( "muzzle_flash", "wpn_muzzleflash_pistol" )
SetWeaponEffect( "shell_eject_fp", "wpn_shelleject_pistol_FP" )
SetWeaponEffect( "shell_eject", "wpn_shelleject_pistol" )

PrecacheWeaponAssets()

didFirstRaise <- false

if ( !( "_suppressSmartPistolVO" in level ) )
	level._suppressSmartPistolVO <- false

//==================================================================================================

function OnWeaponActivate( activateParams )
{
	// old usage
	//SmartAmmo_Start( self )
	
	if ( !IsClient() )
		return
	
	if ( !IsLocalViewPlayer( self.GetWeaponOwner() ) )
		return
	
	if ( !didFirstRaise )
	{
		if ( !level._suppressSmartPistolVO )
			PlayWeaponSound( "deployVO" )
		didFirstRaise = true
	}
}

function OnWeaponDeactivate( deactivateParams )
{
	SmartAmmo_Stop( self )
}

function OnClientAnimEvent( name )
{
	if ( name == "muzzle_flash" )
		PlayWeaponEffect_OnAttachment( "muzzle_flash_fp", "muzzle_flash", "muzzle_flash" )
	
	if ( name == "shell_eject" )
		PlayWeaponEffect_OnAttachment( "shell_eject_fp", "shell_eject", "shell" )
}

function OnWeaponPrimaryAttack( attackParams )
{
	return SmartAmmo_FireWeapon( self, attackParams, damageTypes.Instant )
}