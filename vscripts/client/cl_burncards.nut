const DRAW_CARD_EARNED = 1
const DRAW_CARD_USED = 2
const DRAW_CARD_FADEOUT = 3
const DRAW_CARD_BONUS_USED = 4

function main()
{
	Globalize( ServerCallback_PlayerUsesBurnCard )
	Globalize( ServerCallback_PlayerEarnedBurnCard )
	Globalize( ServerCallback_PlayerStoppedBurnCard )
	Globalize( BurnCardAnnouncementProcessQueue )
	Globalize( DisplayActiveBurnCards )
	Globalize( PlayerPressed_BurnCardRight )
	Globalize( PlayerPressed_BurnCardUp )
	Globalize( PlayerPressed_BurnCardLeft )
	Globalize( DisplayEarnedBurnCard )
	Globalize( PlayBurnCardEffects )
	Globalize( ClientCodeCallback_OnPlayerActiveBurnCardIndexChanged )
	Globalize( ShouldShowBurnCardSelection )

	RegisterSignal( "StopBurnCardDisplay" )
	RegisterSignal( "HideOrShowBurnCards" )

	file.burncardsEnabled <- false
	file.maxActiveBurnCards <- null
}

function BurnCardOwnerAlreadyAnnouncesThisCard( player, owner, card )
{
	foreach ( queue in player.cv.burnCardAnnouncementQueue )
	{
		if ( queue.owner != owner )
			continue

		if ( queue.card != card )
			continue

		return true
	}

	return false
}

function ServerCallback_PlayerEarnedBurnCard( card )
{
	local player = GetLocalViewPlayer()
	if ( !IsValid( player ) )
		return
	if ( card < 0 || card >= level.burnCards.len() )
		return
	local cardRef = level.burnCards[ card ]
	BurnCardAnnouncementMessage( player, player, cardRef, DRAW_CARD_EARNED )
}

function ServerCallback_PlayerStoppedBurnCard( card )
{
	local player = GetLocalViewPlayer()
	if ( !IsValid( player ) )
		return
	if ( card < 0 || card >= level.burnCards.len() )
		return
	local cardRef = level.burnCards[ card ]
	BurnCardAnnouncementMessage( player, player, cardRef, DRAW_CARD_EARNED )
}

function BurnCardAnnouncementMessage( player, owner, card, drawType = DRAW_CARD_USED )
{
	if ( !IsValid( player ) )
		return
	if ( player != GetLocalClientPlayer() )
		return

	if ( BurnCardOwnerAlreadyAnnouncesThisCard( player, owner, card ) )
		return

	player.cv.burnCardAnnouncementQueue.append( { owner = owner, card = card, drawType = drawType } )

	if ( player.cv.burnCardAnnouncementActive || !IsValid( player.GetCockpit() ) )
		return

	thread BurnCardAnnouncementMessage_Display( player, owner, card, drawType )
}
Globalize( BurnCardAnnouncementMessage )

function BurnCardAnnouncementProcessQueue( player )
{
	if ( !IsValid( player ) )
		return
	if ( player.cv.burnCardAnnouncementActive )
		return

	if ( !player.cv.burnCardAnnouncementQueue.len() )
		return

	local data = player.cv.burnCardAnnouncementQueue[0]

	thread BurnCardAnnouncementMessage_Display( player, data.owner, data.card, data.drawType )
}

function BurnCardAnnouncementMessage_Display( player, owner, card, drawType )
{
	if ( !IsValid( player ) )
		return
	local cockpit = player.GetCockpit()

	if ( !IsValid( cockpit ) )
		return

	local mainVGUI = cockpit.GetMainVGUI()
	if ( !mainVGUI )
		return

	if ( !IsValid( owner ) )
		return

	OnThreadEnd(
		function() : ( player )
		{
			player.cv.burnCardAnnouncementActive = false
			thread BurnCardAnnouncementProcessQueue( player )
		}
	)

	player.cv.burnCardAnnouncementActive = true

	local cockpit = player.GetCockpit()
	cockpit.EndSignal( "OnDestroy" )

	if ( drawType == DRAW_CARD_EARNED )
		waitthread DisplayEarnedBurnCard( owner, card )
	else if ( drawType == DRAW_CARD_BONUS_USED )
		waitthread DisplaySelectedBurnCard( owner, card, true )
	else
		waitthread DisplaySelectedBurnCard( owner, card )

	player.cv.burnCardAnnouncementQueue.remove( 0 )
}


function ClientCodeCallback_OnPlayerActiveBurnCardIndexChanged( player, _ )
{
	if ( player == GetLocalClientPlayer() )
	{
		local table = GetBurnCardOnDeckOrActive( player )
		UpdateBurnCardOnDeckOrActiveCard( table )
		UpdateBurnCardSelectors( player )
	}

	if ( GetLocalViewPlayer() == player )
	{
		PlayBurnCardEffects( player )
	}
}

function ServerCallback_PlayerUsesBurnCard( ownerEHandle, index, isBonus )
{
	local player = GetEntityFromEncodedEHandle( ownerEHandle )
	if ( !IsValid( player ) )
		return

	if ( index < 0 || index >= level.burnCards.len() )
		return

	local cardRef = level.burnCards[ index ]

	local localPlayer = GetLocalClientPlayer()

	if ( level.ent )
		UpdatePlayerStatusCounts()

	// We only segment the bars during HUD initialization. This fixes activating the Burn Card in the grace period.
	if ( player == GetLocalViewPlayer() )
	{
		if ( cardRef == "bc_titan_shield_wall_m2" )
		{
			local cockpit = player.GetCockpit()
			if ( IsValid( cockpit ) )
				UpdateAmmoChargesBarSegments( player.GetOffhandWeapon( OFFHAND_LEFT ), cockpit.s.offhandHud[OFFHAND_LEFT].bar, player )
		}
	}

	if ( player == localPlayer )
	{
		if ( isBonus )
			BurnCardAnnouncementMessage( player, player, cardRef, DRAW_CARD_BONUS_USED )
		else
			BurnCardAnnouncementMessage( player, player, cardRef )
		return
	}

	if ( isBonus )
		return

	local playerName = player.GetPlayerName()

	if ( playerName != "" )
	{
		///////////////////////
		// dev only - remove (machinename-re)
		local index = playerName.find( " (", 1 )
		if ( index != null )
			playerName = playerName.slice( 0, index )

		local title = GetBurnCardTitle( cardRef )

		local playerNameColor
		if ( player.GetTeam() == localPlayer.GetTeam() )
			playerNameColor = OBITUARY_COLOR_FRIENDLY
		else
			playerNameColor = OBITUARY_COLOR_ENEMY

		local burnCardIcon = "hud/obituary_burncard"
		Obituary_Print( playerName, title, "", playerNameColor, BURN_CARD_WEAPON_HUD_COLOR_STRING, OBITUARY_COLOR_WEAPON, burnCardIcon ) // BURN_CARD_WEAPON_HUD_COLOR_STRING )
	}
}

function HideBurnCardCockpitIcon( player )
{
	local cockpit = player.GetCockpit()
	if ( !cockpit )
		return

	local mainVGUI = cockpit.GetMainVGUI()
	if ( !mainVGUI )
		return

	cockpit.s.burnCardIcon.Hide()
	cockpit.s.burnCardIconShadow.Hide()
	cockpit.s.burnCardTitle.Hide()
}

function PlayBurnCardEffects( player )
{
	local cardRef = GetPlayerActiveBurnCard( player )
	if ( cardRef == null )
	{
		HideBurnCardCockpitIcon( player )
		return
	}

	switch ( cardRef )
	{
		case "bc_stim_forever":
			if ( player.IsHuman() )
				StimPlayer( player, USE_TIME_INFINITE )
			break
	}
}

function ShouldHideBurnCardSelectionText( player )
{
	if ( player != GetLocalClientPlayer() )
		return false
	if ( player.GetPlayerClass() != "spectator" )
		return false
	if ( IsWatchingKillReplay() )
		return false

	return true
}
Globalize( ShouldHideBurnCardSelectionText )

function ShouldShowBurnCardSelection( player )
{
	if ( IsRoundBased() )
	{

		if ( IsMatchOver() )
			return false
	}

	if ( !IsRoundBased() && IsPlayerEliminated( player ) )
		return false

	if ( GetBurnCardOnDeckOrActive( player ) )
		return true

	local max = GetPlayerMaxActiveBurnCards( player )

	for ( local slotID = 0; slotID < max; slotID++ )
	{
		local cardRef = GetPlayerActiveBurnCardSlotContents( player, slotID )
		if ( cardRef != null )
			return true
	}

	local max = PersistenceGetArrayCount( _GetBurnCardPersPlayerDataPrefix() + ".stashedCardRef" )
	for ( local slotID = 0; slotID < max; slotID++ )
	{
		if ( GetPlayerStashedCardRef( player, slotID ) != null )
			return true
	}

	return false
}

function DisplayActiveBurnCards( player )
{
	player.ClientCommand( "OpenBurnCardMenu" )
}

function PlayerPressed_BurnCardLeft( player )
{
}

function PlayerPressed_BurnCardUp( player )
{
}

function PlayerPressed_BurnCardRight( player )
{
}

function WaitUntilDisplayBurnCard( player )
{
	local checkFlags = []
	checkFlags.append( CE_FLAG_EMBARK )
	checkFlags.append( CE_FLAG_DISEMBARK )
	checkFlags.append( CE_FLAG_INTRO )
	checkFlags.append( CE_FLAG_CLASSIC_MP_SPAWNING )
	checkFlags.append( CE_FLAG_TITAN_HOT_DROP )

	for ( ;; )
	{
		local ceFlags = player.GetCinematicEventFlags()
		local hasFlag = false

		foreach ( flag in checkFlags )
		{
			if ( ceFlags & flag )
			{
				hasFlag = true
				wait 0
				break
			}
		}

		if ( !hasFlag )
			return
	}
}
Globalize( WaitUntilDisplayBurnCard )


function DisplaySelectedBurnCard( player, card, isBonus = false )
{
	player.Signal( "StopBurnCardDisplay" )
	player.EndSignal( "StopBurnCardDisplay" )

	local viewPlayer = GetLocalViewPlayer()
	local vguis = []

	OnThreadEnd(
		function () : ( vguis, player )
		{
			if ( IsValid( player ) )
				StopSoundOnEntity( player, "UI_InGame_BurnCardFlyin" )

			foreach ( vgui in vguis )
			{
				vgui.Destroy()
			}
		}
	)

	local cockpit = viewPlayer.GetCockpit()
	for ( ;; )
	{
		cockpit = viewPlayer.GetCockpit()
		if ( IsValid( cockpit ) )
			break

		wait 0
	}

	local isTitanCockpit = IsTitanCockpitModelName( cockpit.GetModelName() )

	player.EndSignal( "OnDestroy" )

	cockpit.EndSignal( "OnDestroy" )
	if ( !isBonus )
	{
		cockpit.s.burnCardIcon.Hide()
		cockpit.s.burnCardIconShadow.Hide()
		cockpit.s.burnCardTitle.Hide()
	}

	waitthread WaitUntilDisplayBurnCard( player )

	if ( !isBonus )
	{
		local icon = GetBurnCardHudIcon( card )
		cockpit.s.burnCardIcon.SetImage( icon )
		cockpit.s.burnCardIconShadow.SetImage( icon )

		local title = GetBurnCardTitle( card )
		cockpit.s.burnCardTitle.SetText( title )
	}

	local origin = Vector(0,0,0)
	local angles = Vector(0,0,0)

	local vgui
	local burnCardElem
	local width, height
	local ratio = 1.46875
	local rotater = 120

	local right
	local forward
	local up

	local attachment = "CAMERA_BASE"
	local attachmentID = cockpit.LookupAttachment( attachment )

	width = 8
	height = width * ratio

	local moveTime = 0.35
	local startScale = 0.0
	local midScale = 0.8

	moveTime = 0.7

	EmitSoundOnEntity( player, "UI_InGame_BurnCardFlyin" )

	local origin = Vector(0,0,0) // cockpit.GetAttachmentOrigin( attachmentID )
	local angles = Vector(0,0,0)
	local forward = angles.AnglesToForward()
	local right = angles.AnglesToRight()
	local up = angles.AnglesToUp()

	origin += forward * 22
	origin += right * (-width / 2)
	origin += up * (-height / 2)

	if ( isBonus )
		origin += up * -1.0

	angles = angles.AnglesCompose( Vector( 0, -90, 90 ) )
	angles = angles.AnglesCompose( Vector( -20, 0, 0 ) )


	local startOrigin = VectorCopy( origin )
	local midOrigin = VectorCopy( origin )
	startOrigin += up * -2.7
	startOrigin += right * 21

	midOrigin += right * 13
	midOrigin += up * 1

	if ( !isTitanCockpit )
	{
		midOrigin += forward * -2
		startOrigin += right * 1.0
		startOrigin += up * 0.5
	}

	if ( isBonus )
		vgui = CreateClientsideVGuiScreen( "vgui_burn_card_header", VGUI_SCREEN_PASS_HUD, startOrigin, angles, width, height )
	else
		vgui = CreateClientsideVGuiScreen( "vgui_burn_card", VGUI_SCREEN_PASS_HUD, startOrigin, angles, width, height )
	vgui.SetParent( cockpit, attachment )
	vgui.SetAttachOffsetOrigin( startOrigin )
	vgui.SetAttachOffsetAngles( angles )

	vguis.append( vgui )

	local burnCardVGUI = CreatePreviewCardFromStandardElements( vgui )
	ShowPreviewCard( burnCardVGUI )
	SetPreviewCard( card, burnCardVGUI )

	if ( isBonus )
	{
		burnCardVGUI.PreviewCard_header <- HudElement( "PreviewCard_header", burnCardVGUI.hudElement.GetPanel() )
		burnCardVGUI.PreviewCard_header.Show()
	}

	local total = 0
	local rate = 1
	local startTime = Time()
	local endTime = startTime + moveTime

	for ( ;; )
	{
		if ( Time() >= endTime )
			break
		local result = Interpolate( startTime, moveTime, 0, moveTime )
		InterpolateBurnCard( vgui, result, startTime, moveTime, startOrigin, midOrigin, startScale, midScale, width, height )
		wait 0
	}

	wait 1.0

	local lastsUntil = GetBurnCardLastsUntil( card )
	switch ( lastsUntil )
	{
		case BC_NEXTSPAWN:
		case BC_FOREVER:
		case BC_NEXTTITANDROP:
		case BC_NEXTTITAN:
			// just fade away
			local fadeTime = 0.5
			FadePreviewCard( burnCardVGUI, 0, fadeTime, INTERPOLATOR_LINEAR )
			wait fadeTime
			return
	}


	vgui.SetAttachOffsetOrigin( midOrigin )
	vgui.SetSize( width * midScale, height * midScale )

	wait 1.0
	local fadeTime = 0.5
	FadePreviewCard( burnCardVGUI, 0, fadeTime, INTERPOLATOR_LINEAR )
	moveTime = fadeTime

	local startTime = Time()
	local endTime = startTime + moveTime

	if ( !isBonus )
		thread DisplayBurnCardIcon( cockpit, card )

	for ( ;; )
	{
		if ( Time() >= endTime )
			break
		local result = Interpolate( startTime, moveTime, 0, moveTime )
		result = 1.0 - result
		// goes backwards
		InterpolateBurnCard( vgui, result, startTime, moveTime, startOrigin, midOrigin, startScale, midScale, width, height )
		wait 0
	}
}


function DisplayEarnedBurnCard( player, card )
{
	player.Signal( "StopBurnCardDisplay" )
	player.EndSignal( "StopBurnCardDisplay" )

	local viewPlayer = GetLocalViewPlayer()
	local vguis = []

	OnThreadEnd(
		function () : ( vguis )
		{
			foreach ( vgui in vguis )
			{
				vgui.Destroy()
			}
		}
	)

	local cockpit = viewPlayer.GetCockpit()
	if ( !IsValid( cockpit ) )
		return

	player.EndSignal( "OnDestroy" )
	cockpit.EndSignal( "OnDestroy" )

	waitthread WaitUntilDisplayBurnCard( player )

	local origin = Vector(0,0,0)
	local angles = Vector(0,0,0)

	local vgui
	local burnCardElem
	local width, height
	local ratio = 1.46875
	local rotater = 120

	local right
	local forward
	local up

	local attachment = "CAMERA_BASE"
	local attachmentID = cockpit.LookupAttachment( attachment )

	width = 8
	height = width * ratio

	local moveTime = 0.35
	local startScale = 0.0
	local midScale = 1.0

	midScale = 0.45
	moveTime = 0.7

	EmitSoundOnEntity( player, "UI_InGame_BurnCardEarned" )

	local origin = Vector(0,0,0) // cockpit.GetAttachmentOrigin( attachmentID )
	local angles = Vector(0,0,0)
	local forward = angles.AnglesToForward()
	local right = angles.AnglesToRight()
	local up = angles.AnglesToUp()

	origin += forward * 22
	origin += right * (-width / 2)
	origin += up * (-height / 2)
	angles = angles.AnglesCompose( Vector( 0, -90, 90 ) )
	angles = angles.AnglesCompose( Vector( 20, 0, 0 ) )

	local startOrigin = VectorCopy( origin )
	local midOrigin = VectorCopy( origin )
	startOrigin += up * -3
	startOrigin += right * 5
	midOrigin += right * -3
	midOrigin += up * 4

	vgui = CreateClientsideVGuiScreen( "vgui_burn_card_mid", VGUI_SCREEN_PASS_HUD, startOrigin, angles, width, height )
	vgui.SetParent( cockpit, attachment )
	vgui.SetAttachOffsetOrigin( startOrigin )
	vgui.SetAttachOffsetAngles( angles )

	vguis.append( vgui )

	local burnCardVGUI = {}
	CreateBurnCardPanel( burnCardVGUI, vgui )
	DrawBurnCard( burnCardVGUI, true, true, card )

	local total = 0
	local rate = 1
	local startTime = Time()
	local endTime = startTime + moveTime

	for ( ;; )
	{
		if ( Time() >= endTime )
			break
		local result = Interpolate( startTime, moveTime, 0, moveTime )
		InterpolateBurnCard( vgui, result, startTime, moveTime, startOrigin, midOrigin, startScale, midScale, width, height )
		wait 0
	}

	vgui.SetAttachOffsetOrigin( midOrigin )
	vgui.SetSize( width * midScale, height * midScale )

	wait 1.0
	local fadeTime = 0.5
	FadeBurnCard( burnCardVGUI, 0, fadeTime, INTERPOLATOR_LINEAR )
	wait fadeTime
}

//function InterpolateBurnCard( vgui, result, startTime, moveTime, origin, right, forward, up, width, height, boostRight, boostUp )
function InterpolateBurnCard( vgui, result, startTime, moveTime, startOrigin, endOrigin, startScale, endScale, width, height )
{
	local newOrigin = startOrigin * ( 1.0 - result ) + endOrigin * result
	local scale = startScale * ( 1.0 - result ) + endScale * result
	local newHeight = height * scale
	local newWidth = width * scale

	vgui.SetSize( newWidth, newHeight )
	vgui.SetAttachOffsetOrigin( newOrigin )
}
Globalize( InterpolateBurnCard )


function DisplayBurnCardIcon( cockpit, card )
{
	cockpit.EndSignal( "OnDestroy" )
	wait 0.3
	cockpit.s.burnCardIcon.Show()
	cockpit.s.burnCardIconShadow.Show()
	cockpit.s.burnCardTitle.Show()

//	cockpit.s.burnCardIcon.SetColor( 255, 255, 255, 255 )
//	return

	cockpit.s.burnCardIcon.SetAlpha( 0 )
	cockpit.s.burnCardIconShadow.SetAlpha( 0 )
	cockpit.s.burnCardTitle.SetAlpha( 0 )

	wait 0.2
	cockpit.s.burnCardIcon.FadeOverTime( 255, 0.2, INTERPOLATOR_DEACCEL )
	cockpit.s.burnCardTitle.FadeOverTime( 255, 0.2, INTERPOLATOR_DEACCEL )
	cockpit.s.burnCardIconShadow.FadeOverTime( 255, 0.2, INTERPOLATOR_DEACCEL )

	//wait 0.5

	//cockpit.s.burnCardIcon.FadeOverTime( 205, 2.0, INTERPOLATOR_LINEAR )
	cockpit.s.burnCardIconShadow.FadeOverTime( 155, 2.0, INTERPOLATOR_LINEAR )
}
