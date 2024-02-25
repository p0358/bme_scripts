// Modifiers for hit location ( all players and NPCs, human/titan )
const LOCATION_DAMAGE_MOD_NORMAL = 1.0
const LOCATION_DAMAGE_MOD_HEADSHOT = 1.5
const LOCATION_DAMAGE_MOD_LEGS = 1.0
const LOCATION_DAMAGE_MOD_HEADSHOT_NPC = 2.0
const LOCATION_DAMAGE_MOD_NON_CRITICAL = 0.6
const LOCATION_DAMAGE_MOD_GEAR = 0.5

function main()
{
	file.locationDamageScale <- {}

	// --- defs and precaches for impact effect tables ---

	if ( IsServer() )
	{
		ROCKET_IMPACT_FX_TABLE			<- PrecacheImpactEffectTable( "orbital_strike" )
	}

	Globalize( IsValidRankedKill )
	Globalize( IsValidHeadShot )
	Globalize( IsInstantDeath )
	Globalize( GetCriticalScaler )
	Globalize( IsTitanCrushDamage )
	Globalize( IsMaxRangeShot )
	Globalize( UseLocationDamageScale )
	Globalize( GetLocationDamageScale )
	Globalize( IsSuicide )
	Globalize( CritWeaponInDamageInfo )
}

function GetLocationDamageScale( weapon, location )
{
	local weaponName = weapon.GetClassname()

	return file.locationDamageScale[weaponName][location]
}

function UseLocationDamageScale( weapon )
{
	if ( !weapon )
		return false

	local weaponName = weapon.GetClassname()

	if ( "weapon" in file.locationDamageScale )
		return true

	file.locationDamageScale[weaponName] <- {}
	file.locationDamageScale[weaponName][ HITGROUP_GENERIC ] 	<- LOCATION_DAMAGE_MOD_NORMAL
	file.locationDamageScale[weaponName][ HITGROUP_HEAD ] 		<- LOCATION_DAMAGE_MOD_HEADSHOT
	file.locationDamageScale[weaponName][ HITGROUP_CHEST ] 		<- LOCATION_DAMAGE_MOD_NORMAL
	file.locationDamageScale[weaponName][ HITGROUP_STOMACH ] 	<- LOCATION_DAMAGE_MOD_NORMAL
	file.locationDamageScale[weaponName][ HITGROUP_LEFTARM ] 	<- LOCATION_DAMAGE_MOD_NORMAL
	file.locationDamageScale[weaponName][ HITGROUP_RIGHTARM ] 	<- LOCATION_DAMAGE_MOD_NORMAL
	file.locationDamageScale[weaponName][ HITGROUP_LEFTLEG ] 	<- LOCATION_DAMAGE_MOD_LEGS
	file.locationDamageScale[weaponName][ HITGROUP_RIGHTLEG ] 	<- LOCATION_DAMAGE_MOD_LEGS
	file.locationDamageScale[weaponName][ HITGROUP_GEAR ] 		<- LOCATION_DAMAGE_MOD_GEAR

	local weaponVal

	weaponVal = weapon.GetWeaponInfoFileKeyField( "damage_headshot_scale" )
	if ( weaponVal != null )
	{
		file.locationDamageScale[weaponName][ HITGROUP_HEAD ] = weaponVal
	}

	weaponVal = weapon.GetWeaponInfoFileKeyField( "damage_torso_scale" )
	if ( weaponVal != null )
	{
		file.locationDamageScale[weaponName][ HITGROUP_CHEST ] = weaponVal
		file.locationDamageScale[weaponName][ HITGROUP_STOMACH ] = weaponVal
	}

	weaponVal = weapon.GetWeaponInfoFileKeyField( "damage_arm_scale" )
	if ( weaponVal != null )
	{
		file.locationDamageScale[weaponName][ HITGROUP_LEFTARM ] = weaponVal
		file.locationDamageScale[weaponName][ HITGROUP_RIGHTARM ] = weaponVal
	}

	weaponVal = weapon.GetWeaponInfoFileKeyField( "damage_leg_scale" )
	if ( weaponVal != null )
	{
		file.locationDamageScale[weaponName][ HITGROUP_LEFTLEG ] = weaponVal
		file.locationDamageScale[weaponName][ HITGROUP_RIGHTLEG ] = weaponVal
	}

	return true
}


function CritWeaponInDamageInfo( damageInfo )
{
	if ( damageInfo.GetWeapon() )
		return damageInfo.GetWeapon().IsCriticalHitWeapon()

	if ( !damageInfo.GetInflictor() )
		return false

	if ( !(damageInfo.GetInflictor() instanceof CProjectile) )
		return false

	local weaponRef = damageInfo.GetInflictor().GetWeaponClassName()

	return GetWeaponInfoFileKeyField_Global( weaponRef, "critical_hit" )
}

function GetCriticalScaler( ent, damageInfo, attacker )
{
	local attacker = damageInfo.GetAttacker()
	local hitBox = damageInfo.GetHitBox()
	local damageAmount = damageInfo.GetDamage()

	if ( !CritWeaponInDamageInfo( damageInfo ) )
		return 1.0

	if ( !IsCriticalHit( attacker, ent, hitBox, damageAmount, damageInfo.GetDamageType() ) )
		return 1.0

	return damageInfo.GetDamageCriticalHitScale()
}

function IsValidRankedKill( attacker, victim )
{
	if ( !attacker )
		return false

	if ( !attacker.IsPlayer() )
		return false

	if ( !PlayerPlayingRanked( attacker ) )
		return false

//	if ( !PlayerPlayingRanked( victim ) )
//		return false

//	if ( victim == attacker )
//		return false

	return true
}

function IsValidHeadShot( damageInfo = null, victim = null, attacker = null, weapon = null, hitGroup = null, attackDist = null, inflictor = null )
{
	// Pass this function damageInfo if you can, otherwise you'll have to fill out all the other params. If using damageInfo you dont need to.
	local inflictor
	if ( damageInfo != null )
	{
		if ( damageInfo.GetCustomDamageType() & DF_HEADSHOT )
			return true

		attacker = damageInfo.GetAttacker()
		weapon = damageInfo.GetWeapon()
		hitGroup = damageInfo.GetHitGroup()
		local hitBox = damageInfo.GetHitBox()
		//Some models can be shot that don't have models. Adding victim.GetModelName() check to prevent script error.
		if ( IsValid( victim ) && hitGroup <= HITGROUP_GENERIC && hitBox >= 0 )
			hitGroup =  GetHitgroupForHitboxOnEntity( victim, damageInfo.GetHitBox() )
		attackDist = damageInfo.GetDistFromAttackOrigin()
		inflictor = damageInfo.GetInflictor()
	}

	if ( hitGroup != HITGROUP_HEAD )
		return false

	if ( !IsValid( attacker ) || !attacker.IsPlayer() )
		return false

	local entity
	if ( IsValid( weapon ) )
		entity = weapon
	else if ( IsValid( inflictor ) && inflictor.IsProjectile() )
		entity = inflictor

	if ( entity )
	{
		if ( !( "headshotDistance" in entity.s ) )
			entity.s.headshotDistance <- entity.GetWeaponInfoFileKeyField( "damage_far_distance" )

		if ( attackDist != null && attackDist > entity.s.headshotDistance )
			return false

		if ( !( "allowHeadShots" in entity.s ) )
			entity.s.allowHeadShots <- entity.GetWeaponInfoFileKeyField( "allow_headshots" )

		if ( entity.s.allowHeadShots != null )
			return entity.s.allowHeadShots == 1
	}
	return false
}

function IsMaxRangeShot( damageInfo )
{
	local weapon = damageInfo.GetWeapon()
	local inflictor = damageInfo.GetInflictor()

	if ( !IsValid( weapon ) )
	{
		weapon = inflictor
		if ( !IsValid( weapon ) || !weapon.IsProjectile() )
			return false
	}

	if ( !( "headshotDistance" in weapon.s ) )
		weapon.s.headshotDistance <- weapon.GetWeaponInfoFileKeyField( "damage_far_distance" )

	if ( damageInfo.GetDistFromAttackOrigin() > weapon.s.headshotDistance )
		return true

	return false
}


function IsInstantDeath( damageSourceId )
{
	switch( damageSourceId )
	{
		case eDamageSourceId.titan_execution:
		case eDamageSourceId.human_execution:
		case eDamageSourceId.fall:
		case eDamageSourceId.splat:
		case eDamageSourceId.indoor_inferno:
			return true

		default:
			return false
	}
}

function IsTitanCrushDamage( damageInfo )
{
	// legacy - for titan arm swipe damage which uses a env_explosion with custom damage type set
	if ( damageInfo.GetCustomDamageType() == damageTypes.TitanStepCrush )
		return true

	// code detected footstep damage gives this damage source ID
	if ( damageInfo.GetDamageSourceIdentifier() == eDamageSourceId.titan_step )
		return true

	return false
}

function IsSuicide( attacker, victim, damageSourceId )
{
	if ( attacker == victim )
		return true

	if ( damageSourceId == eDamageSourceId.suicide )
		return true

	if ( damageSourceId == eDamageSourceId.outOfBounds )
		return true

	return false
}