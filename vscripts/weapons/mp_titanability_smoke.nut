
function OnWeaponPrimaryAttack( attackParams )
{
	//PlayWeaponSound( "fire" )

	if ( IsServer() )
	{
		self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

		local player = self.GetWeaponOwner()
		if ( IsAlive( player ) )
		{
			local lifetime
			if ( self.HasModDefined( "burn_mod_titan_smoke" ) && self.HasMod( "burn_mod_titan_smoke" ) )
				lifetime = ELECTRIC_SMOKESCREEN_FX_EXTRA_BURN_CARD_LIFETIME + ELECTRIC_SMOKESCREEN_FX_LIFETIME_TITAN
			else
				lifetime = ELECTRIC_SMOKESCREEN_FX_LIFETIME_TITAN
			thread ElectricSmokescreen( player, lifetime, self )
		}
	}
	return
}

function OnWeaponNpcPrimaryAttack( attackParams )
{
	Assert( IsServer() )

	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	local npc = self.GetWeaponOwner()
	if ( IsAlive( npc ) )
		thread ElectricSmokescreen( npc, ELECTRIC_SMOKESCREEN_FX_LIFETIME_TITAN, self )
}

function CooldownBarFracFunc()
{
	if ( !IsValid( self ) )
		return 0

	if ( IsValid( self ) )
		return 1.0 - ( self.GetWeaponChargeFraction() * 1.0 )
	return 0
}

/*

	local shouldPredict = self.ShouldPredictProjectiles()
	if ( IsClient() && !shouldPredict )
		return 1

	// Get missile firing information
	local player = self.GetWeaponOwner()
	local rocketPodInfo = GetNextRocketPodFiringInfo( self, attackParams )
	local attackPos = rocketPodInfo.tagPos
	local attackDir = GetVectorFromPositionToCrosshair( player, attackPos )
	local missileSpeed = 4000
	local doPopup = false

	local missile = self.FireWeaponMissile( attackPos, attackDir, missileSpeed, damageTypes.ATRocket, damageTypes.ATRocket, doPopup, shouldPredict )

	if ( missile )
	{
		if ( IsClient() )
		{
			local owner = self.GetWeaponOwner()

			local origin = owner.OffsetPositionFromView( Vector( 0, 0, 0 ), Vector( 25, -25, 15 ) )
			local angles = owner.CameraAngles()

			StartParticleEffectOnEntityWithPos( owner, GetParticleSystemIndex( "wpn_mflash_xo_rocket_shoulder_FP" ), FX_PATTACH_EYES_FOLLOW, -1, origin, angles )
		}

		if ( IsServer() &&  IsValid( rocketPodInfo.podModel ) )
		{
			local overrideAngle = VectorToAngles( attackDir )
			PlayFXOnEntity( self.GetScriptScope().GetWeaponEffect( "rocket_flash" ), rocketPodInfo.podModel, rocketPodInfo.tagName, null, null, 6, player, overrideAngle )
			EmitSoundOnEntity( missile, CLUSTER_SFX_LOOP )
		}
	}

	return 1
}

*/
