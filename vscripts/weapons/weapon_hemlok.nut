SetWeaponSound( "fire", "Weapon_hemlok.Single" )
SetWeaponSound( "fire_alt", "Weapon_hemlok.Single2" )
SetWeaponSound( "single_casing", "Weapon_bulletCasing.Single" )
SetWeaponSound( "npc_fire", "ai_hemlok_fire" )
SetWeaponEffect( "muzzle_flash_fp", "wpn_muzzleflash_smg_FP" )
SetWeaponEffect( "muzzle_flash", "wpn_muzzleflash_smg" )
weaponEffects["shell_eject_fp"]		<- "wpn_shelleject_rifle_assault_FP"
weaponEffects["shell_eject"]		<- "wpn_shelleject_rifle_assault"

PrecacheWeaponAssets()


function OnWeaponPrimaryAttack( attackParams )
{
	//PlayWeaponSound( "fire" )
	PlayWeaponSound( "fire_alt" )
	PlayWeaponSound( "single_casing" )
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS, 0.2 )
	
	self.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, 0 )
}


function OnWeaponNpcPrimaryAttack( attackParams )
{
	PlayWeaponSound( "npc_fire" )
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS, 0.2 )
	
	self.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, 0 )
}


function OnClientAnimEvent( name )
{
	if ( name == "muzzle_flash" )
		PlayWeaponEffect_OnAttachment( "muzzle_flash_fp", "muzzle_flash", "muzzle_flash" )
	
	if ( name == "shell_eject" )
		PlayWeaponEffect_OnAttachment( "shell_eject_fp", "shell_eject", "shell" )
}