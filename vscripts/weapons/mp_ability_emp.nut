
damage <- self.GetWeaponInfoFileKeyField( "explosion_damage" ).tointeger()
innerRadius <- self.GetWeaponInfoFileKeyField( "explosion_inner_radius" ).tointeger()
outerRadius <- self.GetWeaponInfoFileKeyField( "explosionradius" ).tointeger()
impactFX <- self.GetWeaponInfoFileKeyField( "impact_effect_table" )

function OnWeaponPrimaryAttack( attackParams )
{
	//local frag = weapon.FireWeaponGrenade( attackParams.pos, Vector( 0, 0, 0 ), Vector( 0, 0, 0 ), 0.0, damageTypes.Explosive, damageTypes.Explosive, PROJECTILE_PREDICTED, true, true )
	//frag.Explode( Vector( 0, 0, 0 ) )

	if ( IsServer() )
	{
		local player = self.GetWeaponOwner()

		local explosion = CreateExplosion( attackParams.pos, damage, damage,
			innerRadius,  // inner rad
			outerRadius,  // outer rad
			player,  // owner
			1.0,  // delay
			null,  // sound
			eDamageSourceId.mp_ability_emp,  // damage source
			false,  // self damage
			impactFX  // fx
			)

		explosion.SetParent( player )
	}

	return 1
}
