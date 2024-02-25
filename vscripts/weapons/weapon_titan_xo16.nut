SetWeaponSound( "fire", "Weapon_XO16.Single" )
SetWeaponSound( "npc_fire", "Weapon_XO16.Single" )

SetWeaponEffect( "muzzle_flash_fp", "wpn_muzzleflash_xo_fp" )
SetWeaponEffect( "muzzle_flash", "wpn_muzzleflash_xo" )
SetWeaponEffect( "shell_eject_fp", "wpn_shelleject_20mm_FP" )
SetWeaponEffect( "shell_eject", "wpn_shelleject_20mm" )
SetWeaponEffect( "env_fire_very_tiny", "env_fire_very_tiny" )
//SetWeaponEffect( "garand_trail", "garand_trail" )

PrecacheWeaponAssets()


function OnWeaponPrimaryAttack( attackParams )
{
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS, 0.2 )
	
	self.EmitWeaponSound( weaponSounds["fire"] )
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
	//self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS, 0.2 )
	
	
	self.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, 0 )
	/*
	if ( IsServer() )
	{
		local bolt = self.FireWeaponBolt( attackParams["pos"], attackParams["dir"], 9000, 0 )
		AttachWeaponTrailEffect( bolt, "garand_trail" )
	}
	*/
}

function OnWeaponBulletHit( hitParams )
{
	if ( IsServer() )
	{
		local owner = self.GetWeaponOwner()
			//printl( owner )
		local myTeam = owner.GetTeam()

		local env_explosion = CreateEntity( "env_explosion" )
		if( owner.IsPlayer() )
		{
			//printl( "here" )
			env_explosion.kv.iMagnitude = 105    //10 damage at center
			env_explosion.kv.iRadiusOverride = 120    //120 radius
		}
		else
		{
			if ( player.IsTitan() )
			{
				//printl( "in titan" )
				env_explosion.kv.iMagnitude = 100    //was 55
				env_explosion.kv.iRadiusOverride = 120   
			}
			else
			{
				//printl( "not titan" )
				env_explosion.kv.iMagnitude = 12    //10 damage at center
				env_explosion.kv.iRadiusOverride = 60    //120 radius
			}
		}
		env_explosion.kv.fireballsprite = "sprites/zerogxplode.spr"
		env_explosion.kv.rendermode = 5   //additive
		//env_explosion.kv.spawnflags = 84 //nosound no fireball no decal
		//env_explosion.kv.spawnflags = 112 //no sound no sparks no decal
		//env_explosion.kv.spawnflags = 1648 //no sound no sparks no decal no particles no dlights
		//env_explosion.kv.spawnflags = 1652 //no sound no sparks no decal no particles no dlights no fireball
		//env_explosion.kv.spawnflags = 1620 //no sound no decal no particles no dlights no fireball
		
		env_explosion.kv.scriptDamageType = damageTypes.FlamingGibs
		
		env_explosion.SetOrigin( hitParams.hitPos )
		env_explosion.SetTeam( myTeam )
		env_explosion.SetOwner( owner )
		DispatchSpawn( env_explosion, false )
		
		env_explosion.Fire( "Explode" )
		
		if( hitParams.hitEnt == player )
			return
		local impactSpark = CreateEntity( "info_particle_system" )
		impactSpark.SetOrigin( hitParams.hitPos )
		//impactSpark.SetOwner( self.GetWeaponOwner() )
		impactSpark.kv.effect_name = "env_fire_very_tiny"
		impactSpark.kv.start_active = 1
		impactSpark.kv.VisibilityFlags = 7
		DispatchSpawn( impactSpark, false )
					
		impactSpark.Kill( 1.5 )
		
		//printl( "shake" )
		local shake = CreateEntity( "env_shake" )
		shake.SetOrigin( hitParams.hitPos )
		shake.kv.amplitude = 8
		shake.kv.duration = 0.2
		shake.kv.frequency = 0.1
		shake.kv.radius = 500
		shake.kv.spawnflags = 4 //in air
		DispatchSpawn( shake, false )
		
		shake.Fire( "StartShake" )
		 
					
		shake.Kill( 1 )
	}
}


function OnClientAnimEvent( name )
{
	if ( name == "muzzle_flash" )
	{
		PlayWeaponEffect_OnAttachment( "muzzle_flash_fp", "muzzle_flash", "muzzle_flash" )
	}
	
	if ( name == "shell_eject" )
	{
		PlayWeaponEffect_OnAttachment( "shell_eject_fp", "shell_eject", "shell" )
	}
}
