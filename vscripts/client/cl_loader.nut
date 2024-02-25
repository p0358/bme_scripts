
function PrecacheRes( resFile )
{
	local vgui = CreateClientsideVGuiScreen( resFile, VGUI_SCREEN_PASS_WORLD, Vector(0,0,0), Vector(0,0,0), 4, 4 )
	Assert( vgui != null, "Failed to precache res file " + resFile )
	vgui.Destroy()
}

//PrecacheRes( "vgui_titan_topcenter" )

if ( !IsLobby() )
{
	PrecacheRes( "vgui_dpad" )
	PrecacheRes( "vgui_icon" )
    PrecacheRes( "vgui_binding" )
	PrecacheRes( "vgui_jump_quest" )
}

PrecacheRes( "vgui_burn_card" )
PrecacheRes( "vgui_burn_card_header" )
PrecacheRes( "vgui_burn_card_slot" )
PrecacheRes( "vgui_burn_card_room" )
PrecacheRes( "vgui_burn_card_mid" )

if ( !IsLobby() )
{
	PrecacheRes( "vgui_enemy_tracker" )
	PrecacheRes( "vgui_titan_ammo" )
	PrecacheRes( "vgui_xpbar" )
	PrecacheRes( "vgui_titan_threat" )
	PrecacheRes( "vgui_titan_vdu" )
	PrecacheRes( "vgui_fullscreen_titan" )
	PrecacheRes( "vgui_fullscreen_pilot" )
	PrecacheRes( "vgui_pilot_launcher_screen" )
	PrecacheRes( "vgui_titan_emp" )
	PrecacheRes( "vgui_sniper" )
    PrecacheRes( "vgui_enemy_announce" )
    PrecacheRes( "Coop_TeamScoreEventNotification" )
}

function main()
{
	if ( IsLobby() )
		Globalize( IsInScoreboard )
}

if ( IsLobby() )
{
	function IsInScoreboard( player )
	{
		return false
	}
}