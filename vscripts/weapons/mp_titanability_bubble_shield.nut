
const SHIELD_WALL_FX = "P_xo_shield_wall"
PrecacheParticleSystem( SHIELD_WALL_FX )
GetParticleSystemIndex( SHIELD_WALL_FX )

const SHIELD_WALL_HEALTH = 200
const SHIELD_WALL_DURATION = 8.0
const SHIELD_WALL_RADIUS = 180
const SHIELD_WALL_FOV = 120
const SHIELD_WALL_WIDTH = 156 // SHIELD_WALL_RADIUS * cos( SHIELD_WALL_FOV/2 )

RegisterSignal( "RegenAmmo" )

if( IsClient() )
{
	PrecacheHUDMaterial( "hud/dpad_bubble_shield_charge_0" )
	PrecacheHUDMaterial( "hud/dpad_bubble_shield_charge_1" )
	PrecacheHUDMaterial( "hud/dpad_bubble_shield_charge_2" )
}

function CreateShield( attackParams )
{
	if ( IsServer() )
	{
		local duration = SHIELD_WALL_DURATION

		local weaponOwner = self.GetWeaponOwner()
		local titanSoul = weaponOwner.GetTitanSoul()

		// JFS the weapon owner should always have a soul, at least on the server
		if ( !IsValid( titanSoul ) )
			return

		local origin = weaponOwner.GetOrigin()
		local safeSpot = origin;
		local angles
		local dir

		if ( weaponOwner.IsNPC() )
		{
			dir = attackParams.dir
			angles = VectorToAngles( attackParams.dir )
			origin = origin + (dir * 100)
		}
		else
		{
			angles = weaponOwner.CameraAngles()
			angles.x = 0
			dir = angles.AnglesToForward()
		}

		local vortexSphere = CreateEntity( "vortex_sphere" )

		vortexSphere.kv.spawnflags = 1 | 2 | 8 // SF_ABSORB_BULLETS | SF_BLOCK_OWNER_WEAPON | SF_ABSORB_CYLINDER
		vortexSphere.kv.enabled = 0
		vortexSphere.kv.radius = SHIELD_WALL_RADIUS
		vortexSphere.kv.bullet_fov = SHIELD_WALL_FOV
		vortexSphere.kv.physics_pull_strength = 25
		vortexSphere.kv.physics_side_dampening = 6
		vortexSphere.kv.physics_fov = 360
		vortexSphere.kv.physics_max_mass = 2
		vortexSphere.kv.physics_max_size = 6

		vortexSphere.SetAngles( angles ) // viewvec?
		vortexSphere.SetOrigin( origin + Vector( 0, 0, SHIELD_WALL_RADIUS - 64 ) )
		vortexSphere.SetMaxHealth( SHIELD_WALL_HEALTH )
		vortexSphere.SetHealth( SHIELD_WALL_HEALTH )

		Assert( weaponOwner.IsTitan() )
		Assert( titanSoul )

		local endTime = Time() + SHIELD_WALL_DURATION
		titanSoul.SetParticleWallData( endTime, SHIELD_WALL_WIDTH, safeSpot, dir )

		DispatchSpawn( vortexSphere, true )

		//vortexSphere.SetOwnerWeapon( self )

		vortexSphere.Fire( "Enable" )
		vortexSphere.Fire( "Kill", "", duration)

		// Shield wall fx control point
		local cpoint = CreateEntity( "info_placement_helper" )
		cpoint.SetName( UniqueString( "shield_wall_controlpoint" ) )
		DispatchSpawn( cpoint, false )

		// Shield wall fx
		local shieldWallFX = PlayFXWithControlPoint( SHIELD_WALL_FX, origin + Vector( 0, 0, -64 ), cpoint, null, null, angles )
		shieldWallFX.s.cpoint <- cpoint
		shieldWallFX.Fire( "StopPlayEndCap", "", duration )
		shieldWallFX.Fire( "Kill", "", duration )
		shieldWallFX.s.cpoint.Fire( "Kill", "", duration )

		vortexSphere.s.shieldWallFX <- shieldWallFX

		thread DrainHealthOverTime( vortexSphere, shieldWallFX, duration )
		thread TEMPDestroy( vortexSphere, shieldWallFX, self, duration ) // nuke it when our owner weapon disappears
	}
}

function OnWeaponPrimaryAttack( attackParams )
{
	local hasBurnMod = self.HasMod( "burn_mod_titan_bubble_shield" )
	//if ( hasBurnMod && !( "useHudIconCharges" in self.s ) )
	//{
	//	self.s.useHudIconCharges <- true
	//}

	CreateShield( attackParams )

	if ( hasBurnMod )
	{
		local weaponOwner = self.GetWeaponOwner()
		local ammo = weaponOwner.GetWeaponAmmoLoaded( self )

		if ( ammo == 2 )
		{
			thread RegenerateOffhandAmmoOverTime( self, SHIELD_WALL_CHARGE_TIME, SHIELD_WALL_MAX_CHARGES, OFFHAND_LEFT )
		}
		else if ( ammo == 1 )
		{
			//Reset Progress Source To Default:
			if ( IsClient() && "nextChargeTime" in self.s )
			{
				local weaponOwner = self.GetWeaponOwner()
				if ( IsValid( weaponOwner ) )
				{
					local cockpit = weaponOwner.GetCockpit()
					if ( IsValid( cockpit ) )
					{
						cockpit.s.offhandHud[OFFHAND_LEFT].bar.SetBarProgressSource( ProgressSource.PROGRESS_SOURCE_SCRIPTED )
						cockpit.s.offhandHud[OFFHAND_LEFT].bar.SetBarProgressRemap( 0.0, 1.0, 0.0, 1.0 )
						local rechargeTime = SHIELD_WALL_CHARGE_TIME
						local remainingTime = self.s.nextChargeTime - Time()
						local currentTime = rechargeTime - remainingTime
						cockpit.s.offhandHud[OFFHAND_LEFT].bar.SetBarProgressAndRate( GraphCapped( currentTime, 0, rechargeTime, 0, 1.0 / SHIELD_WALL_MAX_CHARGES ), 1 / ( rechargeTime * SHIELD_WALL_MAX_CHARGES )  )
					}
				}
			}
		}
	}

	PlayWeaponSound_1p3p( "ShieldWall_Deploy", "ShieldWall_Deploy" )
}

function OnWeaponNpcPrimaryAttack( attackParams )
{
	CreateShield( attackParams )
}

function TEMPDestroy( vortexSphere, shieldWallFX, owner, duration )
{
	vortexSphere.EndSignal( "OnDestroy" )
	shieldWallFX.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( vortexSphere, shieldWallFX )
		{
			if ( IsValid( shieldWallFX ) )
			{
				shieldWallFX.Fire( "StopPlayEndCap" )
				shieldWallFX.Fire( "Kill", "", 1.0 )
				shieldWallFX.s.cpoint.Fire( "Kill", "", 1.0 )
			}
		}
	)

	wait duration * 1.5
}

function DrainHealthOverTime( vortexSphere, shieldWallFX, duration )
{
	vortexSphere.EndSignal( "OnDestroy" )
	shieldWallFX.EndSignal( "OnDestroy" )

	local startTime = Time()
	local endTime = startTime + duration

	local tickRate = 0.1
	local DPS = (vortexSphere.GetMaxHealth() / duration)
	local dmgAmount = DPS * tickRate

	EmitSoundOnEntity( vortexSphere, "ShieldWall_Loop" )

	local endSoundTime = endTime - 3.0
	local playedEndSound = false
	local vortexOrigin = vortexSphere.GetOrigin()

	OnThreadEnd(
		function() : ( vortexSphere, vortexOrigin, endTime )
		{
			if ( endTime - Time() < 1.0 )
				return

			if ( IsValid_ThisFrame( vortexSphere ) )
			{
				StopSoundOnEntity( vortexSphere, "ShieldWall_Loop" )
				StopSoundOnEntity( vortexSphere, "ShieldWall_End" )
			}

			EmitSoundAtPosition( vortexOrigin, "ShieldWall_Destroyed" )
		}
	)

	while ( Time() < endTime )
	{
		if ( Time() > endSoundTime && !playedEndSound )
		{
			EmitSoundOnEntity( vortexSphere, "ShieldWall_End" )
			playedEndSound = true
		}

		vortexSphere.SetHealth( vortexSphere.GetHealth() - dmgAmount )
		UpdateShieldWallColorForFrac( shieldWallFX, GetHealthFrac( vortexSphere ) )
		wait tickRate
	}

	StopSoundOnEntity( vortexSphere, "ShieldWall_Loop" )
}

function OnWeaponActivate( activateParams )
{
	//On Weapon Activate doesn't work for offhand weapons, if that ever changes we can change some of the bar segment functions in cl_main_hud.nut to be more generic.

	//if ( self.HasMod( "burn_mod_titan_bubble_shield" ) && !( "useHudIconCharges" in self.s ) )
	//	self.s.useHudIconCharges <- true
	//	player.Signal( "UpdateWeapons" )

	if ( !( "maxAmmoCharges" in self.s ) )
		self.s.maxAmmoCharges <- SHIELD_WALL_MAX_CHARGES
}