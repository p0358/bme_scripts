
//
// Weapon Sounds
//
weaponSounds <- {}
weaponSounds["fire"]		<- "Weapon_r1Garand.Fire"
weaponSounds["npc_fire"]	<- "Weapon_r1pistol.Single"

	
//
// Weapon Effects
//
weaponEffects <- {}
weaponEffects["muzzle_flash_fp"]	<- "wpn_muzzleflash_smg_FP"
weaponEffects["muzzle_flash"]		<- "wpn_muzzleflash_smg"
weaponEffects["shell_eject_fp"]		<- "wpn_shelleject_rifle_assault_FP"
weaponEffects["shell_eject"]		<- "wpn_shelleject_rifle_assault"

foreach( key, value in weaponEffects )
	PrecacheParticleSystem( value )


function OnWeaponPrimaryAttack( attackParams )
{
/*
	printl( "OnWeaponPrimaryAttack():" )
	foreach( key, value in attackParams )
		printl( "  " + key + " = " + value )
*/
	
	self.EmitWeaponSound( weaponSounds["fire"] )
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS, 0.2 )

	self.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, 0 )
}


function OnWeaponNpcPrimaryAttack( attackParams )
{
/*
	printl( "OnWeaponNpcPrimaryAttack():" )
	foreach( key, value in attackParams )
		printl( "  " + key + " = " + value )
*/
	
	self.EmitWeaponSound( weaponSounds["npc_fire"] )
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS, 0.2 )

	self.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, 0 )
}


function OnClientAnimEvent( name )
{
	if ( name == "muzzle_flash" )
	{
		self.PlayWeaponEffect( weaponEffects["muzzle_flash_fp"], weaponEffects["muzzle_flash"] , "muzzle_flash" )
	}
	
	if ( name == "shell_eject" )
	{
		self.PlayWeaponEffect( weaponEffects["shell_eject_fp"], weaponEffects["shell_eject"] , "shell" )
	}
}
