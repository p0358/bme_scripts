const SCREENHEIGHT = 1080.0
const SCREENWIDTH = 1920.0

function main()
{
	file.zpos <- 0
	file.disableInput <- false

	PrecacheHUDMaterial( "end/imcwin_bg" )
	PrecacheHUDMaterial( "end/imcwin_ships" )
	PrecacheHUDMaterial( "end/imcwin_back" )
	PrecacheHUDMaterial( "end/imcwin_titan" )
	PrecacheHUDMaterial( "end/imcwin_hill" )
	PrecacheHUDMaterial( "end/imcwin_grime" )
	PrecacheHUDMaterial( "end/imcwin_flare" )
	PrecacheHUDMaterial( "end/imcwin_smoke" )

	PrecacheHUDMaterial( "end/mcorwin_sun" )
	PrecacheHUDMaterial( "end/mcorwin_bg" )
	PrecacheHUDMaterial( "end/mcorwin_titan" )
	PrecacheHUDMaterial( "end/mcorwin_flare" )
	PrecacheHUDMaterial( "end/mcorwin_bodies" )
	PrecacheHUDMaterial( "end/mcorwin_fog" )
	PrecacheHUDMaterial( "end/mcorwin_char" )
	PrecacheHUDMaterial( "end/mcorwin_fg" )
	PrecacheHUDMaterial( "end/mcorwin_dust" )
	PrecacheHUDMaterial( "end/mcorwin_debris" )

	RegisterSignal( "EndingDone" )
}

function EntitiesDidLoad()
{
	local player = GetLocalClientPlayer()

	if ( player.GetPersistentVar( "campaignFinishedIMCjustNow" ) )
		thread PlayIMCEnding()
	else if ( player.GetPersistentVar( "campaignFinishedMCORjustNow" ) )
		thread PlayMCOREnding()
}

function PlayMCOREnding()
{
	local player = GetLocalClientPlayer()
	player.Signal( "EndingDone" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "EndingDone" )

	Init( player )

	local img = {}
	img.sun		<- CreateImage( "end/mcorwin_sun" )
	img.sunspot	<- CreateImage( "end/mcorwin_sun" )
	img.bg 		<- CreateImage( "end/mcorwin_bg" )
	img.titan	<- CreateImage( "end/mcorwin_titan" )
	img.flare	<- CreateImage( "end/mcorwin_flare", 768, 1080, 576 )
	img.bodies	<- CreateImage( "end/mcorwin_bodies", 1920, 768 )
	img.fog 	<- CreateImage( "end/mcorwin_fog" )
	img.char  	<- CreateImage( "end/mcorwin_char", 512, 768, 677 )
	img.fg 		<- CreateImage( "end/mcorwin_fg" )
	img.dust 	<- CreateImage( "end/mcorwin_dust" )
	img.debris 	<- CreateImage( "end/mcorwin_debris" )

	foreach( cImage in img )
		cImage.elem.Hide()

	OnThreadEnd(
		function() : ( player, img )
		{
			if ( !IsValid( player ) )
				return
			player.Signal( "EndingDone" )
			ResetTonemapping( 0, 0 )

			foreach( cImage in img )
			{
				cImage.vgui.Kill()
				if ( cImage.mover )
					cImage.mover.Kill()
			}
		}
	)

	thread MCORToneMapping()

	img.sun.elem.Show()
	wait 3.0

	local time = 20
	local delay, x,y,z
	y = -750
	z = -80

	ShiftImageFrom( img.bg, time, 0, time, 0, -200, -90 )
	ColorImage( img.bg, time * 0.5, time * 0.5, 255, 255, 255, 200 )
	img.bg.elem.Show()

	delay = 3
	time -= delay
	wait delay
	ShiftImageFrom( img.titan, time, 0, time, 0, y, -70 )
	ShiftImageFrom( img.flare, time, 0, time, 0, y, -70 )
	img.titan.elem.Show()
	img.flare.elem.Show()
	ColorImage( img.flare, 0, 0, 0, 0, 0, 255 )
	ColorImage( img.flare, 3, delay * 1.5, 255, 255, 255, 255 )
	img.sunspot.elem.Show()
	ColorImage( img.sunspot, 0, 0, 255, 255, 255, 0 )
	ColorImage( img.sunspot, 3, 5, 255, 255, 255, 255 )

	delay = 3
	time -= delay
	wait delay
	ShiftImageFrom( img.bodies, time, 0, time, 0, -500, z )
	img.bodies.elem.Show()

	delay = 1.0
	time -= delay
	wait delay
	ShiftImageFrom( img.fog, time, 0, time, 0, 0, z )
	img.fog.elem.Show()
	ColorImage( img.fog, 0, 0, 0, 0, 0, 255 )
	ColorImage( img.fog, time, 0, 255, 255, 255, 255 )

	delay = 1.5
	time -= delay
	wait delay
	ShiftImageFrom( img.char, time, 0, time, 0, -500, z )
	img.char.elem.Show()

	delay = 3
	time -= delay
	wait delay
	ShiftImageFrom( img.fg, time, 0, time, 0, -200, z )
	img.fg.elem.Show()
	ShiftImageFrom( img.dust, time, 0, time, 0, 0, z )
	img.dust.elem.Show()
	ColorImage( img.dust, 0, 0, 0, 0, 0, 255 )
	ColorImage( img.dust, time * 0.5, 0, 255, 255, 255, 255 )
	ShiftImageFrom( img.debris, time, 0, time, 0, -201, z )

	img.debris.elem.Show()
	ColorImage( img.debris, 0, 0, 255, 255, 255, 0 )
	ColorImage( img.debris, 0.25, 0, 255, 255, 255, 255 )


	while( player.GetPersistentVar( "campaignFinishedMCORjustNow" ) )
		wait 0
}

function PlayIMCEnding()
{
	local player = GetLocalClientPlayer()
	player.Signal( "EndingDone" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "EndingDone" )

	Init( player )

	local img = {}
	img.bg 		<- CreateImage( "end/imcwin_bg" )
	img.ships 	<- CreateImage( "end/imcwin_ships", 1536, 480, 423, 491 )
	img.back 	<- CreateImage( "end/imcwin_back", 1920, 512 )
	img.glare	<- CreateImage( "end/imcwin_flare" )
	img.titan 	<- CreateImage( "end/imcwin_titan", 1024, 1024, 851, 11 )
	img.smoke1	<- CreateImage( "end/imcwin_smoke", 2764, 1296, -1000, -500 )
	img.hill 	<- CreateImage( "end/imcwin_hill", 2048, 1080, -128 )
	img.smoke2	<- CreateImage( "end/imcwin_smoke", 3000, 1400, -1000, -500 )
	img.grime	<- CreateImage( "end/imcwin_grime" )
	img.flare	<- CreateImage( "end/imcwin_flare" )

	OnThreadEnd(
		function() : ( player, img )
		{
			if ( !IsValid( player ) )
				return
			player.Signal( "EndingDone" )
			ResetTonemapping( 0, 0 )

			foreach( cImage in img )
			{
				cImage.vgui.Kill()
				if ( cImage.mover )
					cImage.mover.Kill()
			}
		}
	)

	thread IMCSmoke( img.smoke1, 130, 2000, 255, 225, 180, 150 )
	thread IMCSmoke( img.smoke2, 85, 1000, 230, 255, 255, 120 )

	local time = 30
	local dec = time * 0.1

	ShiftImageFrom( img.hill, time, 0, dec, 105 )
	ShiftImageFrom( img.titan, time, 0, dec, -90 )
	ShiftImageFrom( img.back, time, 0, dec, -60 )
	ShiftImageFrom( img.ships, time, 0, 0, 150, -50 )

	local delay = 13.5//time * 0.3
	ColorImage( img.flare, 0, 0, 0, 0, 0, 255 )
	ColorImage( img.flare, 0.2, delay, 255, 255, 255, 255 )
	ColorImage( img.glare, 0, 0, 150, 150, 150, 255 )
	ColorImage( img.glare, delay - 0.1, 0.1, 200, 200, 200, 255 )
	ColorImage( img.glare, 0.2, delay + 0.2, 0, 0, 0, 255 )
	thread IMCToneMapping( delay - 0.1 )

	while( player.GetPersistentVar( "campaignFinishedIMCjustNow" ) )
		wait 0
}

function IMCSmoke( smoke, time, x, r, g, b, a )
{
	local player = GetLocalClientPlayer()
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "EndingDone" )

	local fade = 5
	ColorImage( smoke, 0, 0, r, g, b, a )

	while( 1 )
	{
		ColorImage( smoke, fade, 0, r, g, b, a )
		ColorImage( smoke, fade, time - fade, r, g, b, 0 )
		ShiftImageFrom( smoke, time, 0, 0, x )
		wait time
		x = 2000
	}
}

function IMCToneMapping( delay )
{
	local player = GetLocalClientPlayer()
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "EndingDone" )

	wait delay

	local max = 0.9
	local cycles = 50
	local inc = max / cycles.tofloat()

	for( local i = 0; i < cycles; i++ )
	{
		local value = i * inc
		if ( value > 0.6 )
			ResetTonemapping( 0, value )
		wait 0
	}

	while( 1 )
	{
		ResetTonemapping( 0, max )
		wait  0
	}
}

function MCORToneMapping()
{
	local player = GetLocalClientPlayer()
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "EndingDone" )

	while( 1 )
	{
		ResetTonemapping( 0, 1.0 )
		wait  0
	}
}

function ShiftImageFrom( cImage, time, acc = 0, dec = 0, x = 0, y = 0, z = 0 )
{
	if ( !cImage.mover )
		CreateImageMover( cImage )

	local mover = cImage.mover

	mover.SetOrigin( mover.s.BaseOrigin + Vector( z, -x * file.xScalar, y * file.yScalar ) )
	mover.NonPhysicsMoveTo( mover.s.BaseOrigin, time, acc, dec )
}

function MoveImage( cImage, time, acc = 0, dec = 0, x = 0, y = 0 )
{
	if ( !cImage.mover )
		CreateImageMover( cImage )

	local mover = cImage.mover

	local pos = mover.s.BaseOrigin + Vector( 0, -x * file.xScalar, y * file.yScalar )

	if ( time )
		mover.NonPhysicsMoveTo( pos, time, acc, dec )
	else
		mover.SetOrigin( pos )
}

function ColorImage( cImage, time, delay, r, g, b, a )
{
	thread __ColorImage( cImage, time, delay, r, g, b, a )
}

function __ColorImage( cImage, time, delay, r, g, b, a )
{
	local player = GetLocalClientPlayer()
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "EndingDone" )

	if ( delay )
		wait delay
	if ( time )
		cImage.elem.ColorOverTime( r, g, b, a, time, INTERPOLATOR_ACCEL )
	else
		cImage.elem.SetColor( r, g, b, a )
}

function CreateImage( image, wide = SCREENWIDTH, tall = SCREENHEIGHT, xpos = 0, ypos = 0, zpos = null )
{
	local x = xpos * file.xScalar
	local y = ypos * file.yScalar
	local z = file.zpos
	if ( zpos )
		z = zpos
	else
		file.zpos += 0.5

	local origin 	= file.origin + Vector( -z, -x, y )
	local width 	= wide * file.xScalar
	local height 	= tall * file.yScalar

	local vgui = CreateClientsideVGuiScreen( "vgui_icon", VGUI_SCREEN_PASS_WORLD, origin, file.angles, width, height )
	local elem = HudElement( "CenterIcon", vgui.GetPanel() )
	elem.SetImage( image )
	elem.SetColor( 255,255,255,255 )

	local cImage = {}
	cImage.vgui <- vgui
	cImage.elem <- elem
	cImage.mover <- null

	return cImage
}

function CreateImageMover( cImage )
{
	local origin = cImage.vgui.GetOrigin()
	cImage.mover = CreateClientsideScriptMover( "models/dev/empty_model.mdl", origin, cImage.vgui.GetAngles() )
	cImage.mover.s.BaseOrigin <- origin
	cImage.vgui.SetParent( cImage.mover, "", false, 0.0 )
}


function Init( player )
{
	file.disableInput = true
	player.EndSignal( "OnDestroy" )

	local cockpit
	for ( ;; )
	{
		cockpit = player.GetCockpit()
		if ( IsValid( cockpit ) )
			break
		wait 0
	}

	file.disableInput = false

	file.width <- 355.0
	file.height <- 200.0
	file.xScalar <- file.width / SCREENWIDTH
	file.yScalar <- file.height / SCREENHEIGHT
	file.origin <- Vector( 187.001, 174.221, -85 )
	file.angles <- Vector( 0, -90, 90 )
}
