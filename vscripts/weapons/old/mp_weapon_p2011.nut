
//
// Weapon Sounds
//
weaponSounds <- {}
weaponSounds["fire"]	<- "Weapon_r1pistol.Single"
weaponSounds["empty"]	<- "Weapon_r1pistol.dryfire"
//weaponSounds["reload"]	<- "Weapon_R1Shotgun.Dryfire"
weaponSounds["double_shot"]	<- "Weapon_R1Shotgun.Double"
weaponSounds["reload_npc"]	<- "Weapon_Pistol.NPC_Reload"
weaponSounds["npc_fire"]	<- "ai_weapon_fire"
weaponSounds["casings"]	<- "Weapon_bulletCasings.Bounce"

	
//
// Weapon Effects
//
weaponEffects <- {}
weaponEffects["muzzle_flash_fp"]	<- "wpn_muzzleflash_pistol_FP"
weaponEffects["muzzle_flash"]		<- "wpn_muzzleflash_pistol"
weaponEffects["shell_eject_fp"]		<- "wpn_shelleject_pistol_FP"
weaponEffects["shell_eject"]		<- "wpn_shelleject_pistol"

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
	self.EmitWeaponSound( weaponSounds["casings"] )
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
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
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
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
