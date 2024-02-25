//********************************************************************************************
//	Lobby
//********************************************************************************************

function main()
{
	Globalize( Lobby_AddPlayer )

	Globalize( ClientCodeCallback_OnSelectedWeaponChanged )
	Globalize( ClientCodeCallback_ControllerModeChanged )
	Globalize( ClientCodeCallback_XPChanged )
	Globalize( ClientCodeCallback_ScoreboardSelectionInput )
	Globalize( ClientCodeCallback_ToggleScoreboard )
}

function ClientCodeCallback_OnSelectedWeaponChanged( selectedWeapon )
{
}

function ClientCodeCallback_ControllerModeChanged( controllerModeEnabled )
{
}

function ClientCodeCallback_XPChanged( player )
{
}

function ClientCodeCallback_ScoreboardSelectionInput( down )
{
}

function ClientCodeCallback_ToggleScoreboard()
{
}

function Lobby_AddPlayer( player )
{
	wait 0

	local localPlayer = GetLocalViewPlayer()
	localPlayer.FreezeControlsOnClient()
	localPlayer.HideCrosshairNames()

	thread LoopLobbyMusic()
}
