
//
// Weapon Sounds
//
weaponSounds <- {}
//weaponSounds["fire"]		<- "Weapon_r1Garand.Fire"
weaponSounds["fire"]	<- "Weapon_r1357.Single"
weaponSounds["npc_fire"]	<- "Weapon_r1357.Single"

	
//
// Weapon Effects
//
weaponEffects <- {}
weaponEffects["muzzle_flash_fp"]	<- "wpn_muzzleflash_xo_fp"
weaponEffects["muzzle_flash"]		<- "wpn_muzzleflash_xo"
weaponEffects["shell_eject_fp"]		<- "wpn_shelleject_pistol_FP"
weaponEffects["shell_eject"]		<- "wpn_shelleject_pistol"
weaponEffects["garand_trail"]		<- "garand_trail"

foreach( key, value in weaponEffects )
	PrecacheParticleSystem( value )

PROJECTILE_SPEED <- 4000

function OnWeaponPrimaryAttack( attackParams )
{
/*
	printl( "OnWeaponPrimaryAttack():" )
	foreach( key, value in attackParams )
		printl( "  " + key + " = " + value )
*/		

	local angles = attackParams.dir.GetAngles()
	angles.x += RandomFloat(-2,2)
	angles.y += RandomFloat(-2,2)
	angles = angles.AnglesToForward()
	
	self.EmitWeaponSound( weaponSounds["fire"] )
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS, 0.2 )

	self.FireWeaponBullet( attackParams.pos, angles, 1, damageTypes.Gibs  )
	//local bolt = self.FireWeaponBolt( attackParams.pos, angles PROJECTILE_SPEED, 0 )
	//AttachWeaponTrailEffect( bolt, "garand_trail" )
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

	self.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, damageTypes.Gibs )
	//local bolt = self.FireWeaponBolt( attackParams.pos, attackParams.dir, PROJECTILE_SPEED, 0 )
	//AttachWeaponTrailEffect( bolt, "garand_trail" )
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
