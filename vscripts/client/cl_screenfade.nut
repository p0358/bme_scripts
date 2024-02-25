function main()
{
	Globalize( ScreenFade_AddClient )

	Globalize( ClientScreenFadeToBlack )
	Globalize( ClientScreenFadeFromBlack )
	Globalize( ClientSetScreenColor )
	RegisterSignal( "NewScreenFade" )
}

function ScreenFade_AddClient()
{
	level.screenFadeElement <- HudElement( "ScreenFade_Background" )
	if ( IsLobby() )
	{
		level.screenFadeElement.Hide()
		return
	}

	thread ClientScreenStartsBlack()
}


function ClientSetScreenColor( r, g, b, a )
{
	local player = GetLocalViewPlayer()
	player.Signal( "NewScreenFade" )
	level.screenFadeElement.SetColor( r, g, b, a )
	level.screenFadeElement.Show()
}

function ClientScreenFadeToBlack( fadeTime = 2.0 )
{
	thread ClientScreenFadesToColor( 0, 0, 0, 255, fadeTime )
}

function ClientScreenFadesToColor( r, g, b, a, fadeTime )
{
	local player = GetLocalViewPlayer()
	player.Signal( "NewScreenFade" )
	player.EndSignal( "NewScreenFade" )

	level.screenFadeElement.Show()
	level.screenFadeElement.SetColor( r, g, b, 0 )
	level.screenFadeElement.FadeOverTime( a, fadeTime, INTERPOLATOR_LINEAR )
}

function ClientScreenFadeFromBlack( fadeTime = 2.0, durationTime = 2.0 )
{
	thread ClientScreenFadesFromColor( 0, 0, 0, 255, fadeTime, durationTime )
}

function ClientScreenFadesFromColor( r, g, b, a, fadeTime, durationTime )
{
	local player = GetLocalViewPlayer()
	player.Signal( "NewScreenFade" )
	player.EndSignal( "NewScreenFade" )

	level.screenFadeElement.Show()
	level.screenFadeElement.SetColor( r, g, b, a )

	wait durationTime

	level.screenFadeElement.HideOverTime( fadeTime )
}

function ClientScreenStartsBlack()
{
	local player = GetLocalViewPlayer()
	player.Signal( "NewScreenFade" )
	player.EndSignal( "NewScreenFade" )
	waitthread WaitForGameStateOrTimeout( player )
	level.screenFadeElement.HideOverTime( 0.8 )
}
Globalize( ClientScreenStartsBlack )

function WaitForGameStateOrTimeout( player )
{
	player.EndSignal( "GameStateChanged" )
	player.EndSignal( "OnDestroy" )
	wait 10 // failsafe
}