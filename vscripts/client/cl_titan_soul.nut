function main()
{
	Globalize( CodeCallback_TitanSoulChanged )
	Globalize( CodeCallback_TitanVarChanged )
	Globalize( ClientCallback_DoomedStateChanged )
}

function CodeCallback_TitanVarChanged( soul )
{
	if ( !soul )
		return
	local titan = soul.GetTitan()
	if ( soul.lastOwner != titan )
	{
		if ( IsValid( soul.lastOwner ) )
			soul.lastOwner.Signal( "OnTitanLost" )
	}

	soul.lastOwner = titan
	soul.Signal( "OnSoulTransfer" )
}

function ClientCallback_DoomedStateChanged( soul )
{
	//Defensive fix temporarily. Code probably shouldn't just pass us null. Remove when bug 36591 is resolved. Should also get this function renamed to CodeClientCallback_ClientCallback_DoomedStateChanged for consistency
	if ( !IsValid( soul ) )
		return

	local titan = soul.GetTitan()
	if ( !IsValid( titan ) )
		return

	if ( !soul.IsDoomed() )
		return

	ModelFX_DisableGroup( titan, "titanHealth" )
	ModelFX_EnableGroup( titan, "titanDoomed" )

	local localPlayer = GetLocalViewPlayer()
	if ( titan == localPlayer )
	{
		UpdateTitanModeHUD( localPlayer )
	}

	HideTitanEye( titan )
}

function CodeCallback_TitanSoulChanged( ent )
{
	if ( !IsValid( ent ) )
		return

	local soul = ent.GetTitanSoul() //JFS Defensive Fix
	if ( !IsValid( soul ) )
		return

	if ( soul.titanEyeVisibility >= EYE_HIDDEN )
	{
		HideTitanEye( ent )
		return
	}
}
