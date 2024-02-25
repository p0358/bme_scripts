
SetWeaponSound( "fire", "Weapon_Vortex_Gun.Fire" )
SetWeaponSound( "bullet_absorb", "Weapon_Vortex_Gun.BulletAbsorb" )
SetWeaponSound( "blocking", "Weapon_R1sonargrenade.Effect" )

SetWeaponEffect( "charging_fp", "wpn_vortex_shield_charging_titan_fp" )
SetWeaponEffect( "charging", "wpn_vortex_shield_charging_titan" )
SetWeaponEffect( "bullet_hit", "wpn_vortex_shield_impact_titan" )
SetWeaponEffect( "vortex_bullet_FP", "wpn_vortex_projectile_rifle_FP" )
SetWeaponEffect( "muzzle_flash_fp", "wpn_muzzleflash_vortex_titan_fp" )
SetWeaponEffect( "muzzle_flash", "wpn_muzzleflash_vortex_titan" )

PrecacheWeaponAssets()

function OnWeaponActivate( activateParams )
{
	CreateVortexSphere( self, false, true, 120 )
	EnableVortexSphere( self )
	
	local weapon = self
	local player = self.GetWeaponOwner()
	local magnitude = 175
}

function OnWeaponDeactivate( deactivateParams )
{
	DestroyVortexSphere( self )
}


function OnClientAnimEvent( name )
{
	if ( name == "muzzle_flash" )
		PlayWeaponEffect_OnAttachment( "muzzle_flash_fp", "muzzle_flash", "vortex_center" )
}

function OnWeaponPrimaryAttack( attackParams )
{
	VortexPrimaryAttack( self, attackParams )
}
