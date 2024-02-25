const ON_DECK_CARDS = 3
const DRAW_CARD_ALWAYS = 1
function main()
{
	level.nextSelectBurnCardTime <- 0
}


function InitBurnCardSelector()
{
	file.HudBurnCard_Selectors <- []
	for ( local i = 0; i < ON_DECK_CARDS; i++ )
	{
		local elemTable = {}
		elemTable.activeIndex <- i
		file.HudBurnCard_Selectors.append( elemTable )

		local hudElement = HudElement( "HudBurnCard_Selector" + ( i + 1 ) )
		CreateBurnCardPanel( elemTable, hudElement )

		elemTable.selectButton <- HudElement( "HudBurnCard_Selector" + ( i + 1 ) + "_button" )
		elemTable.selectButton.EnableKeyBindingIcons()
	}

	HideBurnCardSelectorDisplay()
}
Globalize( InitBurnCardSelector )


function HideBurnCardSelectorDisplay()
{
	foreach ( elemTable in file.HudBurnCard_Selectors )
	{
		HideBurnCardSelector( elemTable )
	}
}
Globalize( HideBurnCardSelectorDisplay )


function UpdateBurnCardSelector( player, elemTable )
{
	local activeIndex = elemTable.activeIndex
	local cardRef = GetPlayerActiveBurnCardSlotContents( player, activeIndex )
	local activeSlotIsActiveIndex = GetPlayerBurnCardActiveSlotID( player ) == activeIndex

	local activeSlotMessage
	local selected

	local stashCardRef = GetPlayerStashedCardRef( player, activeIndex )
	local stashCardTime
	if ( stashCardRef != null && IsDiceCard( stashCardRef ) )
	{
		stashCardTime = GetPlayerStashedCardTime( player, activeIndex ) - 1.5 // so it hangs on zero for a moment
	}

	local slot = GetPlayerBurnCardOnDeckIndex( player )

	if ( activeSlotIsActiveIndex )
	{
		if ( cardRef == null )
		{
			cardRef = GetPlayerActiveBurnCard( player )
			activeSlotMessage = "#BC_ACTIVE_SLOT"
			selected = true
		}
		else
		{
			activeSlotMessage = ""
			selected = false
		}
	}
	else
	{
		selected = activeIndex == slot
	}

	if ( cardRef == null || cardRef == -1 )
	{
		if ( stashCardTime != null )
		{
			// temp
			// show stash card
			SetBurnCardToCard( elemTable, selected, stashCardRef )
			elemTable.BurnCardMid_BottomText.SetColor( 255, 255, 255, 255 )
			elemTable.BurnCardMid_BottomText.SetAutoText( "", HATT_COUNTDOWN_TIME, stashCardTime )
			return DRAW_CARD_ALWAYS
		}

		return
	}

	SetBurnCardToCard( elemTable, selected, cardRef )


	if ( activeSlotIsActiveIndex )
	{
		UpdateBurnCardSelectorPreviewText( elemTable, cardRef, activeSlotMessage, 55, 205, 55, 255, selected )
		return
	}
	else if ( slot != null && slot == activeIndex )
	{
		UpdateBurnCardSelectorPreviewText( elemTable, cardRef, "#BC_ON_DECK", 255, 205, 35, 255, selected )
		return
	}

	// red if its clear-on-load
	if ( GetPlayerActiveBurnCardSlotClearOnStart( player, activeIndex ) )
	{
		local r = 255
		local g = 220
		local b = 170
		elemTable.image.SetColor( r, g, b, 255 )
		elemTable.background.SetColor( r, g, b, 255 )
		elemTable.title.SetColor( r, g, b, 255 )
		elemTable.BurnCardMid_star.SetColor( r, g, b, 35 )
	}

	// BC_NEXTLOAD

	//if ( ACTIVE_BURN_CARD_PREVIEW && !IsWatchingKillReplay() )
	//{
	//	// not trying to draw on deck preview, so draw the active card if there is one active
	//	local cardRef = GetPlayerActiveBurnCard( player )
//
//	//	if ( cardRef != null )
//	//	{
//	//		return { cardRef = cardRef, msg = "#BC_ACTIVE_SLOT", r = 55, g = 205, b = 55, a = 255, active = true }
//	//	}
	//}

	if ( stashCardTime != null )
	{
		//UpdateBurnCardSelectorPreviewText( elemTable, cardRef, "#BC_ON_DECK", 255, 205, 35, 255, selected )
		elemTable.BurnCardMid_BottomText.SetColor( 255, 255, 255, 255 )
		elemTable.BurnCardMid_BottomText.SetAutoText( "", HATT_COUNTDOWN_TIME, stashCardTime )
	}
	else
	{
		if ( elemTable.BurnCardMid_BottomText.IsAutoText() )
			elemTable.BurnCardMid_BottomText.DisableAutoText()

		elemTable.BurnCardMid_BottomText.SetText( "" )
	}
}
Globalize( UpdateBurnCardSelector )

function UpdateBurnCardSelectorPreviewText( elemTable, cardRef, msg, r, g, b, a, selected )
{
	SetBurnCardToCard( elemTable, selected, cardRef )
	//elemTable.BurnCardMid_BottomText.Show()
	if ( elemTable.BurnCardMid_BottomText.IsAutoText() )
		elemTable.BurnCardMid_BottomText.DisableAutoText()

	elemTable.BurnCardMid_BottomText.SetText( msg )
	elemTable.BurnCardMid_BottomText.SetColor( r, g, b, a )
}

function HideBurnCardSelector( elemTable )
{
	HideBurnCard( elemTable )
	//elemTable.panel.Hide()
	elemTable.selectButton.Hide()
	elemTable.BurnCardMid_BottomText.Hide()
}

function ShowBurnCardSelector( elemTable )
{
	ShowBurnCard( elemTable )
	elemTable.BurnCardMid_BottomText.Show()
	elemTable.panel.Show()
	elemTable.selectButton.Show()
}

function UpdateAndShowBurnCardSelectors( player )
{
	if ( ShouldShowBurnCardSelectors( player ) )
	{
		foreach ( elemTable in file.HudBurnCard_Selectors )
		{
			local updateInfo = UpdateBurnCardSelector( player, elemTable )

			if ( updateInfo == DRAW_CARD_ALWAYS )
			{
				ShowBurnCardSelector( elemTable )
				elemTable.selectButton.Hide()
			}
			else
			{
				//GetPlayerActiveBurnCardSlotContents returns null for non-matchlong active cards ( problem in TryActivatingCard() ).
				//There are secondary effects to fixing the bug. Titan Burn cards aren't consumed if you pass in cardRef instead of null into SetPersistentVar.
				local activeSlotID = GetPlayerBurnCardActiveSlotID( player )
				if ( GetPlayerActiveBurnCardSlotContents( player, elemTable.activeIndex ) == null && activeSlotID != elemTable.activeIndex )
				{
					HideBurnCardSelector( elemTable )
				}
				else
				{
					ShowBurnCardSelector( elemTable )
				}
			}
		}
		return
	}

	foreach ( elemTable in file.HudBurnCard_Selectors )
	{
		UpdateBurnCardSelector( player, elemTable )
		HideBurnCardSelector( elemTable )
	}
}
Globalize( UpdateAndShowBurnCardSelectors )

function UpdateBurnCardSelectors( player )
{
	foreach ( elemTable in file.HudBurnCard_Selectors )
	{
		UpdateBurnCardSelector( player, elemTable )
	}
}
Globalize( UpdateBurnCardSelectors )

function ShouldShowBurnCardSelectors( player )
{
	if ( PlayerMustRevive( player ) )
		return

	local inPrematch = level.nv.gameState == eGameState.Prematch
	if ( IsAlive( player ) && !IsWatchingKillReplay() && !inPrematch )
		return false

	if ( BurnCardSelectionMethod() != "three" )
		return false


	return true
}
Globalize( ShouldShowBurnCardSelectors )



function PlayerPressed_SelectActiveBurnCard1( player )
{
	PlayerPressed_SelectActiveBurnCardSlot( player, 0 )
}
Globalize( PlayerPressed_SelectActiveBurnCard1 )

function PlayerPressed_SelectActiveBurnCard2( player )
{
	PlayerPressed_SelectActiveBurnCardSlot( player, 1 )
}
Globalize( PlayerPressed_SelectActiveBurnCard2 )

function PlayerPressed_SelectActiveBurnCard3( player )
{
	PlayerPressed_SelectActiveBurnCardSlot( player, 2 )
}
Globalize( PlayerPressed_SelectActiveBurnCard3 )

function PlayerPressed_SelectActiveBurnCardSlot( player, slot )
{
	if ( Time() < level.nextSelectBurnCardTime )
		return

	if ( !PlayerAllowedToSelectActiveCard( player ) )
		return
	player.ClientCommand( "BCActivateCard " + slot + " toggle" )
}
Globalize( PlayerPressed_SelectActiveBurnCardSlot )
