
//
// Weapon Sounds
//
weaponSounds <- {}
weaponSounds["fire"]	<- "Weapon_R1Shotgun.Single"
weaponSounds["empty"]	<- "Weapon_R1Shotgun.Dryfire"
weaponSounds["reload"]	<- "Weapon_R1Shotgun.Dryfire"
weaponSounds["special1"]	<- "Weapon_R1Shotgun.Special1"
weaponSounds["double_shot"]	<- "Weapon_R1Shotgun.Double"
weaponSounds["reload_npc"]	<- "Weapon_Shotgun.NPC_Reload"
weaponSounds["npc_fire"]	<- "ai_weapon_fire"


//
// Weapon Effects
//
weaponEffects <- {}
weaponEffects["muzzle_flash_fp"]	<- "env_sparks_directional"
weaponEffects["muzzle_flash"]		<- "wpn_muzzleflash_xo"
weaponEffects["shell_eject_fp"]		<- "wpn_shelleject_pistol_FP"
weaponEffects["shell_eject"]		<- "wpn_shelleject_pistol"

foreach( key, value in weaponEffects )
	PrecacheParticleSystem( value )


self.SetWeaponSkin(1)


function OnWeaponPrimaryAttack( attackParams )
{
/*
	printl( "OnWeaponPrimaryAttack():" )
	foreach( key, value in attackParams )
		printl( "  " + key + " = " + value )
*/
	
	self.EmitWeaponSound( weaponSounds["double_shot"] )
	self.EmitWeaponSound( weaponSounds["fire"] )
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS, 0.2 )
	
	FireWeaponOffset( attackParams, 0, 3 )
	FireWeaponOffset( attackParams, 0, -3 )
	FireWeaponOffset( attackParams, 3, 3 )
	FireWeaponOffset( attackParams, -3, 3 )
	FireWeaponOffset( attackParams, -3, -3 )
	FireWeaponOffset( attackParams, 3, -3 )
	FireWeaponOffset( attackParams, -3, 0 )
	FireWeaponOffset( attackParams, 3, 0 )
	FireWeaponOffset( attackParams, 0, 0 )

}

function FireWeaponOffset( attackParams, pitch, yaw )
{			
	local angles = attackParams.dir.GetAngles()
	angles.x += pitch
	angles.y += yaw
	self.FireWeaponBullet( attackParams.pos, angles.AnglesToForward(), 1, damageTypes.PinkMist )
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

	FireWeaponOffset( attackParams, 0, 3 )
	FireWeaponOffset( attackParams, 0, -3 )
	FireWeaponOffset( attackParams, 3, 3 )
	FireWeaponOffset( attackParams, -3, 3 )
	FireWeaponOffset( attackParams, -3, -3 )
	FireWeaponOffset( attackParams, 3, -3 )
	FireWeaponOffset( attackParams, -3, 0 )
	FireWeaponOffset( attackParams, 3, 0 )
	FireWeaponOffset( attackParams, 0, 0 )
}


function OnWeaponReload( reloadParams )
{
	self.EmitWeaponSound( weaponSounds["reload"] )
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
