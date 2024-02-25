// all soul-specific vars should be created here
C_TitanSoul.lastOwner <- null
C_TitanSoul.titanEyeVisibility <- null
C_TitanSoul.lastShieldHealth <- null

function C_TitanSoul::constructor()
{
	::C_BaseEntity.constructor()

	this.titanEyeVisibility = EYE_VISIBLE
}
