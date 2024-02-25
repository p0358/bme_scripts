//printl( "CPortal_Player" )

// onsettingschange
// onchangesettings
// onchangedsettings
// playersettingschanged
// changedplayersettings
// CPortal_Player.__SetPlayerSettings <- CPortal_Player.SetPlayerSettings
function CPortal_Player::SetPlayerSettings( settings )
{
	//printt( "SetPlayerSettings" )
	/*if ( this.GetPlayerSettings() == settings )
		return

	printt( "SetPlayerSettings - Diff Class" )*/

//	printt( this, " FAAR got player settings ", settings )
	local oldPlayerClass = CPortal_Player.GetPlayerClass()

	local mods = GetModsFromPlayerSettings( this, settings )

	if ( IsClassModAvailableForPlayerSetting( settings, "lock_jammer" ) )
		mods.append( "lock_jammer" )

	if ( PlayerHasServerFlag( this, SFLAG_BC_DASH_CAPACITY ) && IsClassModAvailableForPlayerSetting( settings, "sflag_bc_dash_capacity" )  )
		mods.append( "sflag_bc_dash_capacity" )


	CPortal_Player.SetPlayerSettingsWithMods( settings, mods )

	if ( IsAlive( this ) && GetCurrentPlaylistVarInt( "pilot_health", 0 ) != 0 )
	{
		local pilotHealth = GetCurrentPlaylistVarInt( "pilot_health", 0 )

		this.SetMaxHealth( pilotHealth )
		this.SetHealth( pilotHealth )
	}

	if ( this.IsTitan() )
	{
		local soul = this.GetTitanSoul()
		local index = GetPlayerSettingsNumFromString( settings )
		soul.SetPlayerSettingsNum( index )

		foreach ( name, func in level.soulSettingsChangeFuncs )
		{
			func( soul )
		}
	}

	this.OnChangedPlayerClass( oldPlayerClass )
}
