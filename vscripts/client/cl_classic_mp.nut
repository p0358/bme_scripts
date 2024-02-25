const CLASSIC_MP_COUNTDOWN_TIME = 6

function main()
{
	level.classicMP_doCustomIntro <- false
	level.classicMP_Client_GameStateThinkFunc_PickLoadOut <- null
	level.classicMP_Client_GameStateEnterFunc_PickLoadOut <- null

	RegisterServerVarChangeCallback( "gameState", StartPlayerCountdown )
	RegisterServerVarChangeCallback( "gameStartTime", StartPlayerCountdown )
	Globalize( ServerCallback_SetClassicSkyScale )
	Globalize( ServerCallback_ResetClassicSkyScale )
}

function ClassicMP_AddClient()
{
	if ( !GetClassicMPMode() )
		return

	local player = GetLocalClientPlayer()

	thread RegisterClassicMPMusic()

	local hudGroup 	= HudElementGroup( "classicMPCountdownGroup" )

	player.cv.classicMPDesc <- hudGroup.CreateElement( "classicMPCountdownDescText" )

	player.cv.classicMPCountdownGroup <- hudGroup

	//Hard code lengths for classic MP. Make sure they are the same for IMC and Militia!
	CinematicIntroScreen_SetClassicMPIntro( TEAM_IMC )
	CinematicIntroScreen_SetClassicMPIntro( TEAM_MILITIA )

	if ( ClassicMP_ShouldDoDefaultIntro() )
		ClassicMP_Client_DropshipIntroSetup()
}
Globalize( ClassicMP_AddClient )


function ClassicMP_Client_DropshipIntroSetup()
{
	// check if both of these are null, if so, we should fall back to default
	ClassicMP_Client_SetGameStateEnterFunc_PickLoadOut( ClassicMP_Dropship_GameStateEnterFunc_PickLoadOut )
	ClassicMP_Client_SetGameStateThinkFunc_PickLoadOut( ClassicMP_Dropship_GameStateThinkFunc_PickLoadOut )
}

// gamestate ENTER
function ClassicMP_Dropship_GameStateEnterFunc_PickLoadOut( player )
{
	player.cv.waitingForPlayersDesc.SetText( "#HUD_WARPJUMPIN1" )
	player.cv.waitingForPlayersDesc.Show()
	player.cv.waitingForPlayersLine.Show()
	player.cv.waitingForPlayersTimer.Show()

	if ( GameRules.GetGameMode() != LAST_TITAN_STANDING || GameRules.GetGameMode() != WINGMAN_LAST_TITAN_STANDING  )  // sounds weird to play the dropship SFX before seeing the Titan drop in
		thread ClassicMP_Dropship_GameStateEnter_PickLoadOutSFX()
}

function ClassicMP_Dropship_GameStateEnter_PickLoadOutSFX()
{
	while( level.nv.minPickLoadOutTime == null )
	{
		wait 0

		//defensive check recommended by mackey
		if ( GetGameState() != eGameState.PickLoadout )
			return
	}

	local seekTime = MIN_PICK_LOADOUT_TIME - ( level.nv.minPickLoadOutTime - Time() )

	if ( seekTime < 0.2 )
		seekTime = 0.0
	else if ( seekTime > MIN_PICK_LOADOUT_TIME )
		seekTime = MIN_PICK_LOADOUT_TIME

	local player = GetLocalClientPlayer()
	local warpJumpSeek = 3.0

	EmitSoundOnEntityWithSeek( player, "ClassicMP_WarpJump", warpJumpSeek + seekTime )

	switch( player.GetTeam() )
	{
		case TEAM_IMC:
			EmitSoundOnEntityWithSeek( player, "ClassicMP_Jump_Countdown_IMC", seekTime )
			break

		case TEAM_MILITIA:
			EmitSoundOnEntityWithSeek( player, "ClassicMP_Jump_Countdown_MCOR", seekTime )
			break
	}

	local delay = MIN_PICK_LOADOUT_TIME - seekTime
	if ( delay > 0.0 )
		wait delay

	FadeOutSoundOnEntity( player, "ClassicMP_WarpJump", 2.0 )
}

// gamestate THINK
function ClassicMP_Dropship_GameStateThinkFunc_PickLoadOut( player )
{
	local loadOutTime = level.nv.minPickLoadOutTime

	local text = [
		"#HUD_WARPJUMPIN1",
		"#HUD_WARPJUMPIN2",
		"#HUD_WARPJUMPIN3"
	]

	if ( Time() <= loadOutTime )
	{
		local timeRemainingFloat = loadOutTime - Time()
		local timeRemaining = ceil( timeRemainingFloat * 2.0 )
		local index = timeRemaining % 3

		player.cv.waitingForPlayersDesc.SetText( text[ index ] )
		player.cv.waitingForPlayersDesc.Show()
	}
}

function StartPlayerCountdown()
{
	if ( !GetClassicMPMode() )
		return

	local player = GetLocalClientPlayer()

	if ( GetGameState() != eGameState.Prematch )
		return

	if ( !level.nv.gameStartTime )
		return

	player.cv.classicMPCountdownGroup.SetAlpha( 255 )
	player.cv.classicMPCountdownGroup.Show()

	player.cv.classicMPDesc.SetAutoText( "#STARTING_IN", HATT_GAME_COUNTDOWN_MINUTES_SECONDS, level.nv.gameStartTime )
	player.cv.classicMPDesc.EnableAutoText()

	player.cv.classicMPCountdownGroup.FadeOverTimeDelayed( 0, 1.0, level.nv.gameStartTime - Time() )
}

function ServerCallback_SetClassicSkyScale( handle, scale )
{
	local ref = GetEntityFromEncodedEHandle( handle )
	if ( !IsValid( ref ) )
		return
	ref.LerpSkyScale( scale, 0.1 )
}

function ServerCallback_ResetClassicSkyScale( handle )
{
	local ref = GetEntityFromEncodedEHandle( handle )
	if ( !IsValid( ref ) )
		return
	ref.LerpSkyScale( SKYSCALE_DEFAULT, 1.0 )
}

// ========== CLASSIC MP INTRO CALLBACKS ==========
// "think" funcs happen every tick during the game state
function ClassicMP_Client_CallGameStateThinkFunc_PickLoadOut( player )
{
	Assert( GetClassicMPMode() )

	local callbackInfo = level.classicMP_Client_GameStateThinkFunc_PickLoadOut
	return callbackInfo.func.acall( [ callbackInfo.scope, player ] )
}
Globalize( ClassicMP_Client_CallGameStateThinkFunc_PickLoadOut )


//"enter" funcs only happen once upon entering that gamestate
function ClassicMP_Client_CallGameStateEnterFunc_PickLoadOut( player )
{
	Assert( GetClassicMPMode() )

	local callbackInfo = level.classicMP_Client_GameStateEnterFunc_PickLoadOut
	return callbackInfo.func.acall( [ callbackInfo.scope, player ] )
}
Globalize( ClassicMP_Client_CallGameStateEnterFunc_PickLoadOut )


function ClassicMP_Client_SetGameStateThinkFunc_PickLoadOut( func )
{
	Assert( GetClassicMPMode() )

	level.classicMP_Client_GameStateThinkFunc_PickLoadOut = ClassicMP_CreateCallbackTable( func )
}
Globalize( ClassicMP_Client_SetGameStateThinkFunc_PickLoadOut )


function ClassicMP_Client_SetGameStateEnterFunc_PickLoadOut( func )
{
	Assert( GetClassicMPMode() )

	level.classicMP_Client_GameStateEnterFunc_PickLoadOut = ClassicMP_CreateCallbackTable( func )
}
Globalize( ClassicMP_Client_SetGameStateEnterFunc_PickLoadOut )


function ClassicMP_ShouldDoDefaultIntro()
{
	if ( level.classicMP_Client_GameStateThinkFunc_PickLoadOut )
		return false

	if ( level.classicMP_Client_GameStateEnterFunc_PickLoadOut )
		return false

	return true
}