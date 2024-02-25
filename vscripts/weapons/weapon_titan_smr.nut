
//
// Weapon Sounds
//
/*
weaponSounds <- {}
weaponSounds["fire"]		<- "Weapon_r1SMR.Single"
weaponSounds["npc_fire"]	<- "Weapon_RPG.NPC_Single"
weaponSounds["ready"]		<- "Weapon_r1SMR.Ready"
	
weaponEffects <- {}
weaponEffects["muzzle_flash"]	<- "wpn_muzzleflash_smg"
	
foreach( key, value in weaponEffects )
	PrecacheParticleSystem( value )
*/


SetWeaponSound( "fire", "Weapon_r1SMR.Single" )
SetWeaponSound( "npc_fire", "Weapon_RPG.NPC_Single" )
SetWeaponSound( "ready", "Weapon_r1SMR.WeaponReady" )

SetWeaponEffect( "muzzle_flash", "wpn_muzzleflash_smg" )

PrecacheWeaponAssets()


function OnWeaponPrimaryAttack( attackParams )
{
/*
	printl( "OnWeaponPrimaryAttack():" )
	foreach( key, value in attackParams )
		printl( "  " + key + " = " + value )
*/
	
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS, 0.2 )

	if ( IsServer() || self.ShouldPredictProjectiles() )
	{
		local owner = self.GetWeaponOwner();
		//thread fire_burst_of_four( attackParams, owner )
		//thread ready_sound()
		
		//shake player
		if ( IsServer() ) // This should really be predicted!
			owner.s.smr_fired_shake.Fire( "StartShake" )
		
		/*
		local attackPos = owner.OffsetPositionFromView( attackParams[ "pos" ], Vector( 12.0, 4.0, -4.0 ) );
		local angles = attackParams.dir.GetAngles()
		angles.x += RandomFloat(-2,2)
		angles.y += RandomFloat(-2,2)
		angles = angles.AnglesToForward()
		*/
		
		self.EmitWeaponSound( weaponSounds["fire"] )
		
		
		local attackPos = self.GetAttackPosition();
		local angles = self.GetAttackDirection();
		local missile = self.FireWeaponMissile( attackPos, angles, 2500, damageTypes.ATRocket, true, PROJECTILE_PREDICTED )
	}
}

/*
function ready_sound()
{
	wait 2
	self.EmitWeaponSound( weaponSounds["ready"] )
}
*/

/*
function fire_burst_of_four( attackParams, owner )
{
	local fired = 0
	while( fired < 4 )
	{
		
		//local attackPos = self.GetAttackPosition();
		//local angles = self.GetAttackDirection();
		
		local attackPos = owner.OffsetPositionFromView( attackParams[ "pos" ], Vector( 12.0, 4.0, -4.0 ) );
		local angles = attackParams.dir.GetAngles()
		
		angles.x += RandomFloat(-2,2)
		angles.y += RandomFloat(-2,2)
		angles = angles.AnglesToForward()
		
		self.EmitWeaponSound( weaponSounds["fire"] )
		local missile = self.FireWeaponMissile( attackPos, angles, 2500, 0, true, PROJECTILE_NOT_PREDICTED )
		fired++
		
		wait 0.1
	}
}
*/

/*
function npc_fire_burst_of_four( attackParams, owner )
{
	local owner = self.GetOwner()
	local fired = 0
	while( fired < 4 )
	{
		local owner = self.GetOwner()
		local enemy = owner.GetEnemy()
		local attachIdx = self.LookupAttachment( "PROPGUN" )
		Assert( attachIdx != null )
		local attackPos = self.GetAttachmentOrigin( attachIdx )
		Assert( attackPos != null )
		local projectileDirection = attackParams["dir"]
		
		//----------------------------------------------------------------------------------------
		//If firing at a soldier, we want dead-on accuracy because otherwise missiles get nudged by the animation
		//-----------------------------------------------------------------------------------------
		if ( ( enemy != null ) && enemy.GetClassname() == "npc_soldier" )
		{
			local enemyTargetPos = enemy.GetWorldSpaceCenter()	//we want to fire at center mass in case behind cover
			local projectileDirectionNew = ( enemyTargetPos - attackPos )	//new vector between the gun bone and the enemy
			projectileDirectionNew.Normalize()	//normalize it to all ones
			
			local dot = projectileDirection.Dot( projectileDirectionNew )	//get the difference between the two vectors to make sure it isn't too great...don't want to fire if the gun is pointing up or something
			local angleDiff = DotToAngle( dot )	//"dot" will just return a fraction of 1..we want the actual angle difference
			if ( angleDiff < 5 )	//use the new vector as long as it's not whack
				projectileDirection = projectileDirectionNew
		}
	
		//printl( projectileDirection )
		//local angles = projectileDirection
		//angles.x += RandomFloat(-0.02,0.02)
		//angles.y += RandomFloat(-0.02,0.02)
		//angles = angles.AnglesToForward()
		
		
		local angles = projectileDirection.GetAngles()
		angles.x += RandomFloat(-1,1)
		angles.y += RandomFloat(-1,1)
		angles = angles.AnglesToForward()
		
		//printl( angles )
	
		self.EmitWeaponSound( weaponSounds["fire"] )
		local missile = self.FireWeaponMissile( attackPos, angles, 2500, 0, true, PROJECTILE_NOT_PREDICTED )
		fired++
		
		wait 0.1
	}
}
*/


function OnWeaponNpcPrimaryAttack( attackParams )
{
	if ( IsServer() )
	{
		self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS, 0.2 )
		self.EmitWeaponSound( weaponSounds["fire"] )
		
		local attachIdx = self.LookupAttachment( "flashlight" )
		Assert( attachIdx != null )
		local attackPos = self.GetAttachmentOrigin( attachIdx )
		self.FireWeaponMissile( attackPos, attackParams.dir, 2500, damageTypes.ATRocket, true, PROJECTILE_NOT_PREDICTED )
		
		//local owner = self.GetOwner()
		//thread npc_fire_burst_of_four( attackParams, owner )
	}
	else
	{
		self.PlayWeaponEffect( weaponEffects["muzzle_flash"], weaponEffects["muzzle_flash"] , "PROPGUN" )
	}
}


function OnClientAnimEvent( name )
{
}

function OnWeaponActivate( activateParams )
{
	//happens on server and client when you get the weapon and switch to it.
	setup_smr()
}


function setup_smr()
{
	if ( !IsServer() )
		return
	local player = self.GetWeaponOwner()
	if ( !player )
		return
	if ( !player.IsPlayer() )
		return
	
	
	//big shake for shot
	if( !( "smr_fired_shake" in player.s ) )
	{
		local shake = CreateEntity( "env_shake" )
		shake.kv.spawnflags = 5 //global in air
		shake.kv.amplitude = 16
		shake.kv.duration = 0.2
		shake.kv.frequency = 50
		shake.kv.radius = 100
		DispatchSpawn( shake, false )
	
		player.s.smr_fired_shake <- shake
		
		//set parent
	}
}