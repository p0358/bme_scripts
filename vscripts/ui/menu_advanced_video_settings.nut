
function main()
{
	Globalize( InitAdvancedVideoSettingsMenu )
	Globalize( OnOpenAdvancedVideoSettingsMenu )
	Globalize( OnCloseAdvancedVideoSettingsMenu )
	Globalize( ApplyVideoSettingsButton_Activate )
	Globalize( NavigateBackApplyVideoSettingsDialog )
	Globalize( UICodeCallback_ResolutionChanged )
	Globalize( RestoreRecommendedDialog )
	Globalize( RevertVideoSettingsThread )

	// This prevents a dev only issue. When a map is started with this menu active OnClose is never called which never deregisters this button.
	file.buttonXPressedRegistered <- false
	file.buttonYPressedRegistered <- false

	file.updateResolutionChangedCountdown <- false

	file.FOVLabel <- null
	file.FOVLabelMin <- null
	file.FOVScaleInitial <- null
	RegisterSignal( "OnCloseAdvancedVideoSettingsMenu" )
}

function InitAdvancedVideoSettingsMenu( menu )
{
	uiGlobal.videoSettingsChanged <- false


	AddEventHandlerToButtonClass( menu, "BrightnessSliderClass", UIE_GET_FOCUS, Brightness_Focused )
	AddEventHandlerToButtonClass( menu, "DisplayModeSwitchClass", UIE_GET_FOCUS, DisplayMode_Focused )
	AddEventHandlerToButtonClass( menu, "DisplayModeSwitchClass", UIE_CHANGE, DisplayMode_Changed )
	AddEventHandlerToButtonClass( menu, "AspectRatioButtonClass", UIE_GET_FOCUS, AspectRatio_Focused )
	AddEventHandlerToButtonClass( menu, "AspectRatioButtonClass", UIE_CHANGE, AspectRatio_Changed )
	AddEventHandlerToButtonClass( menu, "ResolutionSwitchClass", UIE_GET_FOCUS, Resolution_Focused )

	AddEventHandlerToButtonClass( menu, "ColorModeSwitchClass", UIE_GET_FOCUS, ColorMode_Focused )
	AddEventHandlerToButtonClass( menu, "AntialiasingSwitchClass", UIE_GET_FOCUS, Antialiasing_Focused )
	AddEventHandlerToButtonClass( menu, "VSyncButtonClass", UIE_GET_FOCUS, VSync_Focused )
	AddEventHandlerToButtonClass( menu, "FOVSliderClass", UIE_GET_FOCUS, FOV_Focused )
	AddEventHandlerToButtonClass( menu, "FOVSliderClass", UIE_LOSE_FOCUS, FOV_LostFocus )
	AddEventHandlerToButtonClass( menu, "TextureDetailSwitchClass", UIE_GET_FOCUS, TextureDetail_Focused )
	AddEventHandlerToButtonClass( menu, "FilteringModeSwitchClass", UIE_GET_FOCUS, FilteringMode_Focused )

	AddEventHandlerToButtonClass( menu, "LightingQualitySwitchClass", UIE_GET_FOCUS, LightingQuality_Focused )
	AddEventHandlerToButtonClass( menu, "ShaderDetailSwitchClass", UIE_GET_FOCUS, ShaderDetail_Focused )
	AddEventHandlerToButtonClass( menu, "ShadowDetailSwitchClass", UIE_GET_FOCUS, ShadowDetail_Focused )
	AddEventHandlerToButtonClass( menu, "AmbientOcclusionSwitchClass", UIE_GET_FOCUS, AmbientOcclusion_Focused )
	AddEventHandlerToButtonClass( menu, "EffectsDetailSwitchClass", UIE_GET_FOCUS, EffectsDetail_Focused )
	AddEventHandlerToButtonClass( menu, "WaterQualitySwitchClass", UIE_GET_FOCUS, WaterQuality_Focused )
	AddEventHandlerToButtonClass( menu, "ModelDetailSwitchClass", UIE_GET_FOCUS, ModelDetail_Focused )
	AddEventHandlerToButtonClass( menu, "ImpactMarksSwitchClass", UIE_GET_FOCUS, ImpactMarks_Focused )
	AddEventHandlerToButtonClass( menu, "RagdollsSwitchClass", UIE_GET_FOCUS, Ragdolls_Focused )

	AddEventHandlerToButtonClass( menu, "AdvancedVideoButtonClass", UIE_CHANGE, AdvancedVideoButton_Changed )

	AddEventHandlerToButtonClass( menu, "PCFooterButtonClass", UIE_GET_FOCUS, PCFooterButtonClass_Focused )

	file.FOVLabel = menu.GetChild( "LblFOVMax" )
	file.FOVLabelMin = menu.GetChild( "LblFOVMin" )
	uiGlobal.keepPlayingFOVVideo <- false
	uiGlobal.playingFOVVideo <- false
	uiGlobal.FOVFocusTime <- 0

	//uiGlobal.temp_fovfocuscount <- 0
	//uiGlobal.temp_fovunfocuscount <- 0
}

function OnOpenAdvancedVideoSettingsMenu( menu )
{
	VideoOptions_FillInCurrent( menu )
	uiGlobal.videoSettingsChanged = false

	local buttons = GetElementsByClassname( menu, "TextureDetailSwitchClass" )
	buttons.extend( GetElementsByClassname( menu, "ShaderDetailSwitchClass" ) )
	//buttons.extend( GetElementsByClassname( menu, "DisplayModeSwitchClass" ) )
	buttons.extend( GetElementsByClassname( menu, "AspectRatioButtonClass" ) )
	buttons.extend( GetElementsByClassname( menu, "ResolutionSwitchClass" ) )

	local enable = true
	if ( IsConnected() )
		enable = false

	foreach ( button in buttons )
		button.SetEnabled( enable )

	if ( !file.buttonXPressedRegistered )
	{
		RegisterButtonPressedCallback( BUTTON_X, ApplyVideoSettingsButton_Activate )
		file.buttonXPressedRegistered = true
	}

	if ( !file.buttonYPressedRegistered )
	{
		if ( !IsConnected() )
		{
			RegisterButtonPressedCallback( BUTTON_Y, RestoreRecommendedDialog )
			file.buttonYPressedRegistered = true
		}
	}

	file.FOVScaleInitial = GetConVarString("cl_fovScale")
	thread UpdateAdvancedVideoSettingsSliderValues( menu )
}

function OnCloseAdvancedVideoSettingsMenu( menu )
{
	Signal( uiGlobal.signalDummy, "OnCloseAdvancedVideoSettingsMenu" )

	if ( file.buttonXPressedRegistered )
	{
		DeregisterButtonPressedCallback( BUTTON_X, ApplyVideoSettingsButton_Activate )
		file.buttonXPressedRegistered = false
	}

	if ( file.buttonYPressedRegistered )
	{
		DeregisterButtonPressedCallback( BUTTON_Y, RestoreRecommendedDialog )
		file.buttonYPressedRegistered = false
	}
}

function UpdateAdvancedVideoSettingsSliderValues( menu )
{
	EndSignal( uiGlobal.signalDummy, "OnCloseAdvancedVideoSettingsMenu" )

	while ( true )
	{
		//local fov_degrees = GetConVarFloat( "cl_fovScale" ) * 70
		local fov_degrees = GetConVarFloat( "sv_rcon_banpenalty" ) * 70
		//local fov_degrees_string = GetConVarString("cl_fovScale")
		//if (fov_degrees_string != file.FOVScaleInitial) {
			//ClientCommand("cl_fovScale " + file.FOVScaleInitial) // restore until we apply
		//}
		fov_degrees = RoundToNearestMultiplier( fov_degrees, 1.0 )
		file.FOVLabel.SetText( fov_degrees.tostring() ) // format( "%2.1f", timeLimit )
		file.FOVLabelMin.SetText( format( "scale: %f", GetConVarFloat( "sv_rcon_banpenalty" ) ) ) // format( "%2.1f", timeLimit )

		wait 0
	}
}

function AdvancedVideoButton_Changed( button )
{
	uiGlobal.videoSettingsChanged = true
}

function RestoreRecommendedDialog( button )
{
	if ( uiGlobal.activeDialog )
		return

	local buttonData = []
	buttonData.append( { name = "#RESTORE", func = DialogChoice_RestoreRecommendedSettings } )
	buttonData.append( { name = "#CANCEL", func = null } )

	local dialogData = {}
	dialogData.header <- "#RESTORE_RECOMMENDED_VIDEO_SETTINGS"
	dialogData.buttonData <- buttonData

	OpenChoiceDialog( dialogData )
}

function DialogChoice_RestoreRecommendedSettings()
{
	VideoOptions_ResetToRecommended( GetMenu( "AdvancedVideoSettingsMenu" ) )
}

function ApplyVideoSettingsButton_Activate( button )
{
	if ( uiGlobal.activeDialog )
		return

	local buttonData = []
	buttonData.append( { name = "#APPLY", func = DialogChoice_ApplyVideoSettings } )
	buttonData.append( { name = "#CANCEL", func = null } )

	local footerData = []
	footerData.append( { label = "#A_BUTTON_SELECT" } )
	footerData.append( { label = "#B_BUTTON_CANCEL", func = null } )

	local dialogData = {}
	dialogData.header <- "#APPLY_CHANGES"
	dialogData.buttonData <- buttonData
	dialogData.footerData <- footerData

	OpenChoiceDialog( dialogData )
}

function NavigateBackApplyVideoSettingsDialog()
{
	if ( uiGlobal.activeDialog )
		return

	local buttonData = []
	buttonData.append( { name = "#APPLY", func = DialogChoice_ApplyVideoSettingsAndCloseMenu } )
	buttonData.append( { name = "#DISCARD", func = CloseTopMenu } )

	local footerData = []
	footerData.append( { label = "#A_BUTTON_SELECT" } )
	footerData.append( { label = "#B_BUTTON_DISCARD", func = null } )

	local dialogData = {}
	dialogData.header <- "#APPLY_CHANGES"
	dialogData.buttonData <- buttonData
	dialogData.footerData <- footerData

	OpenChoiceDialog( dialogData )
}

function DialogChoice_ApplyVideoSettings()
{
	VideoOptions_Apply( GetMenu( "AdvancedVideoSettingsMenu" ) )
	uiGlobal.videoSettingsChanged = false
}

function UICodeCallback_ResolutionChanged( askForConfirmation )
{
	// The resolution change does a uiscript_reset, so reopen the options menus.
	local mainMenu = GetMenu( "MainMenu" )
	if ( uiGlobal.activeMenu == mainMenu )
	{
		local optionsMenu = GetMenu( "OptionsMenu" )
		AdvanceMenu( optionsMenu )

		local advancedVideoSettingsMenu = GetMenu( "AdvancedVideoSettingsMenu" )
		AdvanceMenu( advancedVideoSettingsMenu )
	}

	if ( askForConfirmation )
	{
		local buttonData = []
		buttonData.append( { name = "#KEEP_VIDEO_SETTINGS", func = null } )
		buttonData.append( { name = "#REVERT", func = RevertVideoSettings } )

		local footerData = []
		footerData.append( { label = "#A_BUTTON_SELECT" } )
		footerData.append( { label = "#B_BUTTON_CANCEL" } )

		local dialogData = {}
		dialogData.header <- "#KEEP_VIDEO_SETTINGS_CONFIRM"
		dialogData.buttonData <- buttonData

		uiGlobal.dialogCloseCallback = StopResolutionChangedCountdown.bindenv( this )

		OpenChoiceDialog( dialogData )
		thread ResolutionChangedCountdown()
	}
}

function ResolutionChangedCountdown()
{
	local countDownSeconds = 15

	file.updateResolutionChangedCountdown = true

	for ( local i = countDownSeconds; i >= 0; i-- )
	{
		if ( !file.updateResolutionChangedCountdown || uiGlobal.activeDialog == null )
			return

		if ( i == 0 )
		{
			CloseDialog()
			RevertVideoSettings()
			return
		}

		uiGlobal.activeDialog.GetChild( "LblDetails" ).SetText( "#REVERTING_VIDEO_SETTINGS_TIMER", i )

		wait( 1.0 )
	}
}

function StopResolutionChangedCountdown( cancelled )
{
	file.updateResolutionChangedCountdown = false
	if ( cancelled )
		RevertVideoSettings()
}

function RevertVideoSettings()
{
	thread RevertVideoSettingsThread()
}

function RevertVideoSettingsThread()
{
	// make sure any ExecConfigs that UI script wants to run get run before we call RejectNewSettings.
	WaitEndFrame()

	local menu = GetMenu( "AdvancedVideoSettingsMenu" )
	VideoOptions_RejectNewSettings( menu )
	wait 0
	VideoOptions_FillInCurrent( menu )
	uiGlobal.videoSettingsChanged = false
}

function DialogChoice_ApplyVideoSettingsAndCloseMenu()
{
	VideoOptions_Apply( GetMenu( "AdvancedVideoSettingsMenu" ) )
	CloseTopMenu()
}

function Brightness_Focused( button )
{
	local menu = GetMenu( "AdvancedVideoSettingsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#ADVANCED_VIDEO_MENU_BRIGHTNESS_DESC" )
}

function ColorMode_Focused( button )
{
	local menu = GetMenu( "AdvancedVideoSettingsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#ADVANCED_VIDEO_MENU_COLORMODE_DESC" )
}

function DisplayMode_Focused( button )
{
	local menu = GetMenu( "AdvancedVideoSettingsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#ADVANCED_VIDEO_MENU_DISPLAYMODE_DESC" )
}

function DisplayMode_Changed( button )
{
	local menu = GetMenu( "AdvancedVideoSettingsMenu" )
	VideoOptions_ResetResolutionList( menu )			// Resetting the resolution list can reenable the follow elements, which can be bad

	if ( IsConnected() )
	{
		GetElementsByClassname( menu, "ResolutionSwitchClass" )[0].SetEnabled( false )
		GetElementsByClassname( menu, "AspectRatioButtonClass" )[0].SetEnabled( false )
	}
}

function AspectRatio_Focused( button )
{
	local menu = GetMenu( "AdvancedVideoSettingsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#ADVANCED_VIDEO_MENU_ASPECT_RATIO_DESC" )
}

function AspectRatio_Changed( button )
{
	local menu = GetMenu( "AdvancedVideoSettingsMenu" )
	VideoOptions_ResetResolutionList( menu )
}

function Resolution_Focused( button )
{
	local menu = GetMenu( "AdvancedVideoSettingsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#ADVANCED_VIDEO_MENU_RESOLUTION_DESC" )
}

function Antialiasing_Focused( button )
{
	local menu = GetMenu( "AdvancedVideoSettingsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#ADVANCED_VIDEO_MENU_ANTIALIASING_DESC" )
}

function TextureDetail_Focused( button )
{
	local menu = GetMenu( "AdvancedVideoSettingsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#ADVANCED_VIDEO_MENU_TEXTURE_DETAIL_DESC" )
}

function FilteringMode_Focused( button )
{
	local menu = GetMenu( "AdvancedVideoSettingsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#ADVANCED_VIDEO_MENU_FILTERING_MODE_DESC" )
}

function LightingQuality_Focused( button )
{
	local menu = GetMenu( "AdvancedVideoSettingsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#ADVANCED_VIDEO_MENU_LIGHTING_QUALITY_DESC" )
}

function ShadowDetail_Focused( button )
{
	local menu = GetMenu( "AdvancedVideoSettingsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#ADVANCED_VIDEO_MENU_SHADOW_DETAIL_DESC" )
}

function AmbientOcclusion_Focused( button )
{
	local menu = GetMenu( "AdvancedVideoSettingsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#ADVANCED_VIDEO_MENU_AMBIENT_OCCLUSION_DESC" )
}

function EffectsDetail_Focused( button )
{
	local menu = GetMenu( "AdvancedVideoSettingsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#ADVANCED_VIDEO_MENU_EFFECTS_DETAIL_DESC" )
}

function WaterQuality_Focused( button )
{
	local menu = GetMenu( "AdvancedVideoSettingsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#ADVANCED_VIDEO_MENU_WATER_QUALITY_DESC" )
}

function ImpactMarks_Focused( button )
{
	local menu = GetMenu( "AdvancedVideoSettingsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#ADVANCED_VIDEO_MENU_IMPACT_MARKS_DESC" )
}

function Ragdolls_Focused( button )
{
	local menu = GetMenu( "AdvancedVideoSettingsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#ADVANCED_VIDEO_MENU_RAGDOLLS_DESC" )
}

function ShaderDetail_Focused( button )
{
	local menu = GetMenu( "AdvancedVideoSettingsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#ADVANCED_VIDEO_MENU_SHADER_DETAIL_DESC" )
}

function ModelDetail_Focused( button )
{
	local menu = GetMenu( "AdvancedVideoSettingsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#ADVANCED_VIDEO_MENU_MODEL_DETAIL_DESC" )
}

function VSync_Focused( button )
{
	local menu = GetMenu( "AdvancedVideoSettingsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#ADVANCED_VIDEO_MENU_VSYNC_DESC" )
}

function FOV_Focused( button )
{
	//uiGlobal.temp_fovfocuscount++;
	uiGlobal.FOVFocusTime = Time()
	local menu = GetMenu( "AdvancedVideoSettingsMenu" )
	//SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#ADVANCED_VIDEO_MENU_FOV_DESC" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass",
		//"Field of View controls how wide you can see. Turning this up may increase CPU and GPU load."
		TranslateTokenToUTF8("#ADVANCED_VIDEO_MENU_FOV_DESC")
		+ "\nHigher values may let skilled pilots see more on the battlefield. Lower values are better if you sit far from your screen."
		//+ "\nDefault value is 70.\nValue frequently used by PC players is 90. (scale: 1.300000)" // and the default max
		+ "\nDefault value is 70.\nValue frequently used by PC players and the default max is 90. (scale: 1.3)"
		//+ "\nFocus: " + uiGlobal.temp_fovfocuscount + ", disfocus: " + uiGlobal.temp_fovunfocuscount
		+ (!IsConnected()     ? "\nThe video played in background should help you in sensing the difference."
		: " ^F4D5A600Open these settings on main menu to see a video that could help you see the difference.")
		)

	if (!IsConnected() && !uiGlobal.keepPlayingFOVVideo)
	{
		uiGlobal.keepPlayingFOVVideo = true
		thread PlayFOVVideo()
	}
}

// with current approach it's going to reset video playback on each click,
// because it fires 2 events of focus gain and 2 of focus lost (most likely: lost, gain, lost, gain)
// if we want to do something about it, we might wire lost focus function to other elements' focus gain events
function FOV_LostFocus( button )
{
	//uiGlobal.temp_fovunfocuscount++;
	if ( uiGlobal.playingIntro && uiGlobal.playingFOVVideo && uiGlobal.keepPlayingFOVVideo && !IsConnected()
		&& uiGlobal.FOVFocusTime + 0.2 < Time() )
	{
		Signal( uiGlobal.signalDummy, "PlayVideoEnded" )
	}
	uiGlobal.keepPlayingFOVVideo = false
}

// In case we still wanted to play the vid in UI
// https://steamcommunity.com/discussions/forum/20/882966056829269381/
// https://www.moddb.com/forum/thread/source-playing-video-files-in-game
// https://github.com/RubberWar/Portal-2/blob/master/src/game/client/vgui_hudvideo.cpp
// https://github.com/InfoSmart/InSource/blob/master/game/client/vgui_video.cpp (VideoBIKMaterial%i is in Titanfall too)
// http://hlssmod.net/he_code/game/client/vgui_video.cpp (old?)
// https://github.com/scen/ionlib/blob/master/src/sdk/hl2_csgo/game/client/vgui_movie_display.cpp (prop, not interesting to us)
// https://github.com/ValveSoftware/source-sdk-2013/blob/master/sp/src/game/client/vgui_video.cpp
/* so create your main panel
after that create the videopanel with that
xpos
ypos
wide
tall
filename
command
i think that now you got all you need to realize this addition :) */
// but we went with background video playing for now:

function PlayFOVVideo()
{
	if (uiGlobal.playingFOVVideo)
		return
	uiGlobal.playingFOVVideo = true
	local mainMenu = GetMenu("MainMenu")
	//if (uiGlobal.activeMenu == mainMenu)
		DisableBackgroundMovie()

	uiGlobal.playingIntro = true
	while ( uiGlobal.keepPlayingFOVVideo )
	{
		PlayVideo( "15ms_480x400.bik", false )

		WaitSignal( uiGlobal.signalDummy, "PlayVideoEnded" )
		StopVideo()
	}

	uiGlobal.playingIntro = false
	uiGlobal.keepPlayingFOVVideo = false

	//if (uiGlobal.activeMenu == mainMenu)
		EnableBackgroundMovie()

	uiGlobal.playingFOVVideo = false
	wait 0 // not sure why? xd
}
Globalize( PlayFOVVideo )

function PCFooterButtonClass_Focused( button )
{
	local menu = GetMenu( "AdvancedVideoSettingsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "" )
}
