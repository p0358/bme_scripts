weaponSounds <- {}
weaponSounds["fire"]	<- "Weapon_R1Slammer.Single"


weaponEffects <- {}
weaponEffects["muzzle_flash_fp"]	<- "wpn_muzzleflash_smg_FP"
weaponEffects["muzzle_flash"]		<- "wpn_muzzleflash_smg"
weaponEffects["shell_eject_fp"]		<- "wpn_shelleject_pistol_FP"
weaponEffects["shell_eject"]		<- "wpn_shelleject_pistol"

foreach( key, value in weaponEffects )
	PrecacheParticleSystem( value )


function OnWeaponActivate( deployParams )
{
	if ( IsServer() )
	{
		local weapon = self
		local player = self.GetWeaponOwner()
		if( !("SLAMMER_PHYSEXPLOSION_MAGNITUDE" in weapon.s) )
		{
			slammer_weapon_init( weapon )

			weapon.s.slammer_exploder <- CreateSlamExploder( weapon, player )

			//weapon.s.slammer_pusher <- CreateSlamPush( weapon )
			//weapon.s.slammer_pusher.Fire( "Disable" )

			weapon.s.slammer_slammerfx <- CreateSlammerfx()
			weapon.s.slammer_slammer_cc <- CreateSlammer_CC()
			//weapon.s.slammer_slammer_dust <- CreateSlammerDust( weapon, player )
		}
	}
}


function slammer_weapon_init( weapon )
{
	weapon.s.SLAMMER_PHYSEXPLOSION_MAGNITUDE <- 175
	//weapon.s.SLAMMER_PHYSEXPLOSION_MAGNITUDE <- 110
	//weapon.s.SLAMMER_PHYSEXPLOSION_INNER_RADIUS <- 100
	//weapon.s.SLAMMER_PHYSEXPLOSION_OUTER_RADIUS <- 500
	//weapon.s.SLAMMER_PUSH_MAGNITUDE <- 500
	weapon.s.SLAMMER_PUSH_RADIUS <- 500 //was 750

	local anims = []
	anims.append( "CQB_Flinch_chest_winded" )
	//anims.append( "CQB_Flinch_chest_multi_fall" )
		//anims.append( "CQB_Flinch_foot_stumble_r_violent" )
	anims.append( "CQB_Flinch_groin_check" )
	anims.append( "CQB_Flinch_groin_headshake" )
	anims.append( "CQB_Flinch_Head" )
		//anims.append( "CQB_Flinch_thigh" )
		//anims.append( "CQB_crouch_pain_shoulder_R" )
		//anims.append( "CQB_crouch_pain_shoulder_L" )

	ArrayRandomize( anims )
	weapon.s.human_anims <- anims
	weapon.s.human_anims_index <- 0


	//big shake for shot
	if( !( "slammer_fired_shake" in player.s ) )
	{
		local shake = CreateEntity( "env_shake" )
		shake.kv.spawnflags = 5 //global in air
		shake.kv.amplitude = 16
		shake.kv.duration = 0.5
		shake.kv.frequency = 100
		shake.kv.radius = 100
		DispatchSpawn( shake, false )
		player.s.slammer_fired_shake <- shake
	}
}


function OnWeaponPrimaryAttack( attackParams )
{
	local weapon = self
	local player = self.GetWeaponOwner()
	self.EmitWeaponSound( weaponSounds["fire"] )
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS, 8 )

	if ( IsServer() )
	{
		// pushes physics stuff
		self.s.slammer_exploder.Fire( "Explode" )
		// pushes stuff
		if( "slammer_pusher" in self.s )
		{
			self.s.slammer_pusher.Fire( "Enable" )
			self.s.slammer_pusher.Fire( "Disable", "", 0.5 )
		}
		// makes particles
		if( "slammer_slammerfx" in self.s )
		{
			self.s.slammer_slammerfx.Fire( "Start" )
			self.s.slammer_slammerfx.Fire( "Stop", "", 0.5 )
		}
		if( "slammer_slammer_dust" in self.s )
		{
			weapon.s.slammer_slammer_dust.Fire( "TurnOn" )
			weapon.s.slammer_slammer_dust.Fire( "TurnOff", "", 0.5 )
		}
		weapon.s.slammer_slammer_cc.Fire( "Enable" )
		weapon.s.slammer_slammer_cc.Fire( "Disable", "", 0.05 )

		// Get targets in the push radius
		local targetTable = Push_TargetEnemiesInRadius( self.s.SLAMMER_PUSH_RADIUS )


		// Make them animate on push
		foreach ( target in targetTable.pushTargets )
		{
			thread Push_Stun( target, weapon, player  )
		}

		//shake player
		if( ( "slammer_fired_shake" in player.s ) )
		{
			player.s.slammer_fired_shake.Fire( "StartShake" )
		}
	}
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




////////////////////////////////////////////////

function CreateSlamExploder( weapon, player )
{
	local exploder = CreateEntity( "env_physexplosion" )
	exploder.SetOwner( self )
	exploder.SetTeam( self.GetTeam() )
	exploder.SetName( UniqueString() )
	exploder.kv.magnitude = weapon.s.SLAMMER_PHYSEXPLOSION_MAGNITUDE.tostring()
	if( ("SLAMMER_PHYSEXPLOSION_INNER_RADIUS" in weapon.s) )
		exploder.kv.inner_radius = weapon.s.SLAMMER_PHYSEXPLOSION_INNER_RADIUS.tostring()
	if( ("SLAMMER_PHYSEXPLOSION_OUTER_RADIUS" in weapon.s) )
		exploder.kv.radius = weapon.s.SLAMMER_PHYSEXPLOSION_OUTER_RADIUS.tostring()
	exploder.kv.spawnflags = 2  // push player
	DispatchSpawn( exploder, false )

	local endorg = player.GetOrigin() + ( player.GetForwardVector() * 7 )  // 7 units in front of the player
	exploder.SetOrigin( endorg )
	exploder.SetParent( player )

	return exploder
}

/*
function CreateSlamPush( weapon ) //this is used to push enemies away that dont happen to get killed by the slammer
{
	local pusher = CreateEntity( "point_push" )
	pusher.SetName( UniqueString() )
	pusher.kv.spawnflags = 19 // test los before pushing, push physics, use angles
	pusher.kv.enabled = 1
	pusher.kv.magnitude = weapon.s.SLAMMER_PUSH_MAGNITUDE.tostring()
	pusher.kv.radius = weapon.s.SLAMMER_PUSH_RADIUS
	pusher.kv.inner_radius = weapon.s.SLAMMER_PUSH_RADIUS.tostring()
	pusher.kv.influence_cone = 40
	DispatchSpawn( pusher, false )

	local endorg = self.GetOrigin() + ( self.GetForwardVector() * 7 )  // 7 units in front of the player
	pusher.SetOrigin( endorg )
	pusher.SetParent( self )

	return pusher
}
*/

function CreateSlammerfx() //creating the fx on the ground when the slammer is fired
{

	local slammerfx = CreateEntity( "info_particle_system" )
	slammerfx.SetName( "blahfx" )
	slammerfx.kv.effect_name = SLAMMER_EFFECTRANGE_FX
	DispatchSpawn( slammerfx, false )

	local endorg = self.GetOrigin() + ( self.GetForwardVector() * 7 )  // 7 units in front of the player
	slammerfx.SetAngles( self.GetAngles() )
	slammerfx.SetOrigin( endorg )
	slammerfx.SetParent( self )

	return slammerfx
}


function CreateSlammer_CC()
{
		local color_correction = CreateEntity( "color_correction" )
		color_correction.SetName( "at_rifle_color_correction" )
		color_correction.kv.StartDisabled = 1
		color_correction.kv.minfalloff = -1
		color_correction.kv.maxfalloff = -1
		color_correction.kv.maxweight = 1.0
		color_correction.kv.filename = "materials/correction/bw_super_constrast.raw"
		color_correction.kv.fadeInDuration = 0.0
		color_correction.kv.fadeOutDuration = 0.0
		color_correction.kv.spawnflags = 1  // Master
		DispatchSpawn( color_correction, false )

	return color_correction
}

/*
function CreateSlammerDust( weapon, player ) //creating the fx on the ground when the slammer is fired
{
	env_smokestack <- CreateEntity( "env_smokestack" )
	env_smokestack.kv.BaseSpread = 20
	env_smokestack.kv.SpreadSpeed = 25
	env_smokestack.kv.Speed = 800
	env_smokestack.kv.StartSize = 35
	env_smokestack.kv.EndSize = 60
	env_smokestack.kv.Rate = 20
	env_smokestack.kv.JetLength = 180
	env_smokestack.kv.SmokeMaterial = "particle/particle_smokegrenade.vmt"
	env_smokestack.kv.rendercolor = "255 255 255"
	env_smokestack.kv.renderamt = 200

	env_smokestack.kv.Angles = player.GetAngles()
	env_smokestack.SetOrigin( weapon.GetOrigin() )
	env_smokestack.SetParent( player )

	DispatchSpawn( env_smokestack, false )
	return env_smokestack
}
*/

function Push_TargetEnemiesInRadius( pushrange ) //get enemies to be stunned by the slammer
{
	local npcs = GetNPCArray()
	local pushTargets = []
	local returnTable = {}

	local origin = self.GetOrigin()

	foreach ( npc in npcs )
	{
		if ( npc.GetClassname() == "npc_bullseye" )
			continue

		if ( IsMultiplayer() && npc.GetTeam() == self.GetTeam() )
			continue

		if ( !self.CanSee( npc ) )
			continue

		local distToTarget = ( origin - npc.GetOrigin() ).Length()
		if ( distToTarget < pushrange )
		{
			pushTargets.append( npc )
		}
	}

	if ( IsMultiplayer() )
	{
	    local players = GetPlayerArray()
	    foreach ( player in players )
	    {
		    if ( player == self )
			    continue

		    if ( IsMultiplayer() && player.GetTeam() == self.GetTeam() )
			    continue

		    if ( !self.CanSee( player ) )
		    {
			    continue
		    }

		    local distToTarget = ( origin - player.GetOrigin() ).Length()
		    if ( distToTarget < pushrange )
		    {
			    pushTargets.append( player )
		    }
	    }
	}

	returnTable.pushTargets <- pushTargets
	return returnTable
}

function Push_Stun( target, weapon, player  ) //plays the "stunned" animation when enemies are hit by the slammer
{

	//if ( target.GetClassname() == "npc_soldier" )
	//	thread PlayAnim(target, "CQB_Flinch_chest_winded" )
	//if ( target.GetClassname() == "npc_soldier" )
	//	thread PlayAnimGravity(target, "CQB_Flinch_chest_winded" )


	if ( target && target.IsNPC() && target.GetBodyType() == "human" )
	{
		if( !target.GetName() )
			target.SetName( UniqueString( "slammer_target" ) )

		local anim = GetNextHumanAnim( weapon )
		printl( anim + " " + target )
		//target.Anim_Play( anim )
		//target.Anim_PlayWithRefPoint( anim, target.GetOrigin(), target.GetAngles(), 0.2 )
		thread PlayAnimGravity( target, anim )

		/*
		local sequence = CreateEntity( "scripted_sequence" )
		sequence.kv.m_iszPlay = anim
		sequence.kv.m_iszEntity = target.GetName()
		sequence.kv.m_startFromOffset = 1
		sequence.kv.model = "models/editor/scriptedsequence.mdl"
		sequence.kv.spawnflags = 4336  // Start on Spawn, No Interruptions, Override AI, Allow actor death, dont teleport on end
		DispatchSpawn( sequence, false )
		sequence.Fire( "Kill", "", 10 )
		*/

	}
	//wait 0.1

	local flingVec = (target.GetOrigin() - player.GetOrigin())
	local dist = flingVec.Length()

	flingVec.Normalize()
	//local velocity = GraphCapped( dist, 200, 600, 450, 350 )
	local velocity = GraphCapped( dist, 200, 750, 450, 300 )

	local velVec = flingVec * velocity

	local isTitan = target.kv.model.find( "titan" )
	if ( isTitan )
	{
		velocity *= 0.3
		if ( velVec.z < 200 )
			velVec.z = 200
	}
	else
	{
		if ( velVec.z < 150 )
			velVec.z = 150
	}
	target.SetVelocity( velVec )
}


function GetNextHumanAnim( weapon )
{
	weapon.s.human_anims_index = (weapon.s.human_anims_index + 1) % weapon.s.human_anims.len()

	return weapon.s.human_anims[ weapon.s.human_anims_index ]
}