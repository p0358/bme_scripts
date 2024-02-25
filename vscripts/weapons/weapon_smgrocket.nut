
//
// Weapon Sounds
//
weaponSounds <- {}
weaponSounds["fire"]		<- "Weapon_r1SMR.Single"
weaponSounds["npc_fire"]	<- "Weapon_RPG.NPC_Single"


function OnWeaponPrimaryAttack( attackParams )
{
/*
	printl( "OnWeaponPrimaryAttack():" )
	foreach( key, value in attackParams )
		printl( "  " + key + " = " + value )
*/
	
	self.EmitWeaponSound( weaponSounds["fire"] )
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS, 0.2 )

	if ( IsServer() )
	{
		local owner = self.GetWeaponOwner();
		local attackPos = owner.OffsetPositionFromView( attackParams[ "pos" ], Vector( 12.0, 4.0, -4.0 ) );
		local missile = self.FireWeaponMissile( attackPos, attackParams["dir"], 2500, 0, true, PROJECTILE_NOT_PREDICTED )
	}
}


function OnWeaponNpcPrimaryAttack( attackParams )
{
/*
	printl( "OnWeaponNpcPrimaryAttack():" )
	foreach( key, value in attackParams )
		printl( "  " + key + " = " + value )
*/
	self.EmitWeaponSound( weaponSounds["fire"] )
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS, 0.2 )

	if ( IsServer() )
	{
		local bolt = self.FireWeaponMissile( attackParams["pos"], attackParams["dir"], 2500, 0, true, PROJECTILE_NOT_PREDICTED )
	}
}


function OnClientAnimEvent( name )
{
}
