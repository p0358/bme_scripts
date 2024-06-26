
function main()
{
	Globalize( InitClassicMenu )
	Globalize( UpdatePlaylistElements )

	Globalize( ServerCallback_UserCountsUpdated );
	Globalize( ServerCallback_PlaylistUserCountsUpdated );

	Globalize( OnPlaylistButton_Activate ) // BME: to run it from "Ignore" option callback on DLC missing notice
	Globalize( BME_PlaylistCountsUpdated )

	RegisterSignal( "ClosedClassicMenu" ) // BME

	file.playlistImages <- []
	file.playlistImages.append( "default" )
	file.playlistImages.append( "coop" )
	file.playlistImages.append( "at" )
	file.playlistImages.append( "lts" )
	file.playlistImages.append( "cp" )
	file.playlistImages.append( "ctf" )
	file.playlistImages.append( "tdm" )
	file.playlistImages.append( "wingman_lts" )
	file.playlistImages.append( "mfd" )
	file.playlistImages.append( "all" )
	file.playlistImages.append( "campaign" )
	file.playlistImages.append( "ps" )
	file.playlistImages.append( "floor_is_lava" )
	file.playlistImages.append( "mfd_pro" )

	foreach ( image in file.playlistImages )
		PrecacheHUDMaterial( "../ui/menu/playlist/" + image )
}

function InitClassicMenu( menu )
{
	uiGlobal.playlistList <- menu.GetChild( "PlaylistList" )
	uiGlobal.playlistList.SetParentMenu( menu )

	AddEventHandlerToButton( menu, "PlaylistList", UIE_CHANGE, OnPlaylistSelection_Changed )
	AddEventHandlerToButton( menu, "PlaylistList", UIE_CLICK, OnPlaylistButton_Activate )
}

function GetPlaylistCountDescForMonthly_( internalPlaylistName ) // BME
{
	local ret = GetPlaylistCountDescForMonthly( internalPlaylistName )
	if ( ret != "" ) return ret
	try {
		ret = GetPlaylistCountDescForMonthly_BME()
		return (ret == "") ? "" : ("^00FF0000" + ret)
	} catch (e) { printt( "GetPlaylistCountDescForMonthly: data not found for playlist", internalPlaylistName ) }
	return ""
}
function GetPlaylistCountDescForWorldTotal_( internalPlaylistName ) // BME
{
	local ret = GetPlaylistCountDescForWorldTotal( internalPlaylistName )
	if ( ret != "" && ret != "0" ) return ret
	try {
		ret = GetPlaylistCountDescForWorldTotal_BME()
		return (ret == "") ? "" : ("^00FF0000" + ret)
	} catch (e) { printt( "GetPlaylistCountDescForWorldTotal_: data not found for playlist", internalPlaylistName ) }
	return ""
}
function GetPlaylistCountDescForRegion_( internalPlaylistName ) // BME
{
	local ret = GetPlaylistCountDescForRegion( internalPlaylistName )
	if ( ret != "" ) return ret
	if ( StringContains( internalPlaylistName, " " ) ) return ""
	try {
		ret = GetPlaylistCountDescForRegion_BME( internalPlaylistName )
		return (ret == "") ? "" : ("^00FF0000" + ret)
	} catch (e) { printt( "GetPlaylistCountDescForRegion_: data not found for playlist", internalPlaylistName ) }
	return ""
}
function GetPlaylistCountDescForWorld_( internalPlaylistName ) // BME
{
	local ret = GetPlaylistCountDescForWorld( internalPlaylistName )
	if ( ret != "" ) return ret
	if ( StringContains( internalPlaylistName, " " ) ) return ""
	try {
		ret = GetPlaylistCountDescForWorld_BME( internalPlaylistName )
		return (ret == "") ? "" : ("^00FF0000" + ret)
	} catch (e) { printt( "GetPlaylistCountDescForWorld_: data not found for playlist", internalPlaylistName ) }
	return ""
}

function PlaylistButtonsUpdate(list) // BME
{
	local count = list.GetListSize()
	for ( local i = 0; i < count; i++)
	{
		local button = list.GetListItem(i)
		//button.SetNew(true)

		local internalPlaylistName = button.GetScriptID()

		local monthlyCountText = GetPlaylistCountDescForMonthly_( internalPlaylistName )
		local worldTotalCountText = GetPlaylistCountDescForWorldTotal_( internalPlaylistName )
		local regionCountText = GetPlaylistCountDescForRegion_( internalPlaylistName )
		local worldCountText = GetPlaylistCountDescForWorld_( internalPlaylistName )

		local regionCount = regionCountText.tointeger()
		local worldCount = worldCountText.tointeger()

		local name = GetPlaylistVar( internalPlaylistName, "name" )

		if (worldCount == 0)
		{
			//button.SetColor(220, 220, 220, 255) // nothing
			//button.SetColorBG(220, 220, 220, 255) // nothing
			//button.SetText( name + "^DDDDDD00test^DDDDDDFFtest2") // not working
			//button.SetEnabled(false) // makes buttons non-clickable
			// locked would display lock icon, we don't want that either...
		}
		else
		{
			//button.SetColor(255, 255, 255, 255)
			//button.SetColorBG(255, 255, 255, 255)
			//button.SetEnabled(true)
		}

		if (internalPlaylistName != "at" && internalPlaylistName != "coop")
		{
			if (regionCount > 2 || worldCount > 4)
			{
				button.SetNew(true)
			}
			else
			{
				button.SetNew(false)
			}
		}
	}
}
Globalize( PlaylistButtonsUpdate )

function OnPlaylistSelection_Changed( list )
{
	local button = list.GetListSelectedItem()

	if ( button )
		UpdatePlaylistElements( list.GetParentMenu(), button.GetScriptID() )

	PlaylistButtonsUpdate(list)
}

function BME_KeepRefreshingPlaylistCounts()
{
	EndSignal( level, "ClosedClassicMenu" )
	for ( ;; )
	{
		if ( IsFullyConnected() )
		{
			BME_RefreshPlaylistCounts()
		}
		wait 20
	}
}

function OnOpenClassicMenu()
{
	//Work around for Frontier Defense Lobby issue. We put the classic menu back on the stack, but party members shouldn't be able to access the playlist page.
	if ( !AmIPartyLeader() )
	{
		CloseTopMenu()
		return
	}

	// Force a refresh:
	OnPlaylistSelection_Changed( uiGlobal.playlistList )

	if ( GetPlaylistCountDescForWorldTotal("") == "0" && GetPlaylistCountDescForWorld("at") == "" ) // if there's no data in game
	{
		thread BME_KeepRefreshingPlaylistCounts()
	}
}
Globalize( OnOpenClassicMenu )

function OnCloseClassicMenu() // BME
{
	Signal( level, "ClosedClassicMenu" )
}
Globalize( OnCloseClassicMenu )

function OnPlaylistButton_Activate( list, ignore_dlc = false )
{
	//Work around for Frontier Defense Lobby issue. We put the classic menu back on the stack, but party members shouldn't be able to access the playlist page.
	if ( !AmIPartyLeader() )
	{
		CloseTopMenu()
		return
	}
	Assert( !AreWeMatchmaking() )

	local playlist = ""
	Assert( IsValid( list ) )
	local button = list.GetListSelectedItem()
	Assert( IsValid( button ) )
	playlist = button.GetScriptID()
	Assert( playlist != "" )

	if ( !DoWeHaveRequiredDLCForPlaylist( playlist ) && !ignore_dlc )
	{
		if ( uiGlobal.activeDialog )
			return

		local playlistName = GetPlaylistVar( playlist, "name" )

		local buttonData = []
		buttonData.append( { name = "IGNORE", func = function() : ( list ) { OnPlaylistButton_Activate( list, true ) } } )
		buttonData.append( { name = "#DLC_GO_TO_STORE", func = function() { ShowDLCStore() } } )
		buttonData.append( { name = "#CLOSE", func = null } )

		local footerData = []
		footerData.append( { label = "#A_BUTTON_SELECT" } )
		footerData.append( { label = "#B_BUTTON_CLOSE" } )

		local dialogData = {}
		dialogData.header <- playlistName
		dialogData.detailsMessage <- "#PLAYLIST_NEED_DLC"
		dialogData.buttonData <- buttonData
		dialogData.footerData <- footerData

		OpenChoiceDialog( dialogData )
		return
	}

	if ( playlist == COOPERATIVE )
	{
		CoopMatchButton_Activate( button )
	}
	else
	{
		StartMatchmaking()
		CloseTopMenu()

		ShowMatchConnectDialog()
	}
}

function UpdatePlaylistElements( menu, internalPlaylistName )
{
	local name = GetPlaylistVar( internalPlaylistName, "name" )
	local nameElements = GetElementsByClassname( menu, "PlaylistNameClass" )

	local desc = GetPlaylistVar( internalPlaylistName, "description" )
	local descElements = GetElementsByClassname( menu, "PlaylistDescriptionClass" )

	local image = GetPlaylistVar( internalPlaylistName, "image" )
	if ( !ArrayContains( file.playlistImages, image ) )
		image = "default"
	local imageElements = GetElementsByClassname( menu, "PlaylistImageClass" )

	foreach ( element in nameElements )
		element.SetText( name )

	foreach ( element in descElements )
		element.SetText( desc )

	foreach ( element in imageElements )
		element.SetImage( "../ui/menu/playlist/" + image )

	local monthlyCountElems = GetElementsByClassname( menu, "PlaylistPlayercountMonthlyText" )
	local worldTotalCountElems = GetElementsByClassname( menu, "PlaylistPlayercountTotalText" )
	local regionCountElems = GetElementsByClassname( menu, "PlaylistPlayercountRegionText" )
	local worldCountElems = GetElementsByClassname( menu, "PlaylistPlayercountWorldwideText" )

	local monthlyCountText = GetPlaylistCountDescForMonthly_( internalPlaylistName )
	local worldTotalCountText = GetPlaylistCountDescForWorldTotal_( internalPlaylistName )
	local regionCountText = GetPlaylistCountDescForRegion_( internalPlaylistName )
	local worldCountText = GetPlaylistCountDescForWorld_( internalPlaylistName )


	local monthlyLabelText = (monthlyCountText == "") ? "" : "#PLAYLIST_PLAYERCOUNT_THIS_MONTH"
	foreach ( elem in monthlyCountElems )
		elem.SetText( monthlyLabelText, monthlyCountText )

	local worldTotalLabelText = (worldTotalCountText == "") ? "" : "#PLAYLIST_PLAYERCOUNT_ALL_WORLDWIDE"
	foreach ( elem in worldTotalCountElems )
		elem.SetText( worldTotalLabelText, worldTotalCountText )

	local regionLabelText = (regionCountText == "") ? "" : "#PLAYLIST_PLAYERCOUNT_REGION"
	foreach ( elem in regionCountElems )
		elem.SetText( regionLabelText, regionCountText )

	local worldLabelText = (worldCountText == "") ? "" : "#PLAYLIST_PLAYERCOUNT_WORLDWIDE"
	foreach ( elem in worldCountElems )
		elem.SetText( worldLabelText, worldCountText )

	// Testing:
	//local debugElems = GetElementsByClassname( menu, "PlaylistPlayercountDebugText" )
	//local debugDesc = GetPlaylistDebugDesc()
	//foreach ( elem in debugElems )
	//	elem.SetText( debugDesc )
}

function ServerCallback_UserCountsUpdated( team, regionHashtagCount )
{
	local hashtag = GetTeamHashtag( team )
	printl( "regional user count updated for team " + team + " - hashtag '" + hashtag + "': " + regionHashtagCount )

	uiGlobal.playerCounts <- {}
	uiGlobal.playlistUserCounts <- {}
	uiGlobal.playerCounts.hashtag <- regionHashtagCount

	// Force a refresh: (not sure if this ever gets triggered actually xd)
	PlaylistButtonsUpdate( uiGlobal.playlistList )
}

function ServerCallback_PlaylistUserCountsUpdated( team, playlist0, playlist0Count, playlist1, playlist1Count, playlist2, playlist2Count, playlist3, playlist3Count )
{
	local hashtag = GetTeamHashtag( team )
	printl( "per-playlist user count updated for hashtag '" + hashtag + "'" )

	if ( !( hashtag in uiGlobal.playlistUserCounts ) )
		uiGlobal.playlistUserCounts[hashtag] <- {}

	local playlist0Name = GetPlaylistName( playlist0 )
	printl( "playlist " + playlist0Name + " has " + playlist0Count + " players using your hashtag" )
	uiGlobal.playlistUserCounts[hashtag][playlist0Name] <- playlist0Count
	local playlist1Name = GetPlaylistName( playlist1 )
	printl( "playlist " + playlist1Name + " has " + playlist1Count + " players using your hashtag" )
	uiGlobal.playlistUserCounts[hashtag][playlist1Name] <- playlist1Count
	local playlist2Name = GetPlaylistName( playlist2 )
	printl( "playlist " + playlist2Name + " has " + playlist2Count + " players using your hashtag" )
	uiGlobal.playlistUserCounts[hashtag][playlist2Name] <- playlist2Count
	local playlist3Name = GetPlaylistName( playlist3 )
	printl( "playlist " + playlist3Name + " has " + playlist3Count + " players using your hashtag" )
	uiGlobal.playlistUserCounts[hashtag][playlist3Name] <- playlist3Count

	// Force a refresh: (not sure if this ever gets triggered actually xd)
	PlaylistButtonsUpdate( uiGlobal.playlistList )
}

function BME_PlaylistCountsUpdated()
{
	printt( "[BME] Playlist counts were updated from HTTP, refreshing UI" )
	OnPlaylistSelection_Changed( uiGlobal.playlistList )
}
