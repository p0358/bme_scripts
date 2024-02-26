
function main()
{
	Globalize( InitMouseKeyboardControlsMenu )
	Globalize( OnOpenKeyboardControlsMenu )
	Globalize( OnCloseKeyboardControlsMenu )

	file.SensitivityLabel <- null
	RegisterSignal( "OnCloseKeyboardControlsMenu" )
}

function InitMouseKeyboardControlsMenu( menu )
{
	AddEventHandlerToButtonClass( menu, "MouseKeyboardBindingsButtonClass", UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "MouseKeyboardBindingsMenu" ) ) )

	AddEventHandlerToButtonClass( menu, "MouseKeyboardBindingsButtonClass", UIE_GET_FOCUS, MouseKeyboardBindings_Focused )
	AddEventHandlerToButtonClass( menu, "MouseSensitivitySliderClass", UIE_GET_FOCUS, MouseSensitivity_Focused )
	AddEventHandlerToButtonClass( menu, "MouseAccelerationSwitchClass", UIE_GET_FOCUS, MouseAcceleration_Focused )
	AddEventHandlerToButtonClass( menu, "MouseInvertSwitchClass", UIE_GET_FOCUS, MouseInvert_Focused )
	AddEventHandlerToButtonClass( menu, "PCFooterButtonClass", UIE_GET_FOCUS, PCFooterButtonClass_Focused )

	file.SensitivityLabel = menu.GetChild( "LblMouseSensitivity" )
}

function OnOpenKeyboardControlsMenu( menu )
{
	thread UpdateMouseKeyboardControlsSliderValues( menu )
}

function OnCloseKeyboardControlsMenu( menu )
{
	Signal( uiGlobal.signalDummy, "OnCloseKeyboardControlsMenu" )
}

function UpdateMouseKeyboardControlsSliderValues( menu )
{
	EndSignal( uiGlobal.signalDummy, "OnCloseKeyboardControlsMenu" )

	while ( true )
	{
		local m_sensitivity = GetConVarFloat( "m_sensitivity" )
		//m_sensitivity = RoundToNearestMultiplier( m_sensitivity, 1.0 )
		file.SensitivityLabel.SetText( m_sensitivity.tostring() ) // format( "%2.1f", timeLimit )

		wait 0
	}
}

function MouseKeyboardBindings_Focused( button )
{
	local menu = GetMenu( "MouseKeyboardControlsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#MOUSE_KEYBOARD_MENU_CONTROLS_DESC" )
}

function MouseSensitivity_Focused( button )
{
	local menu = GetMenu( "MouseKeyboardControlsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#MOUSE_KEYBOARD_MENU_SENSITIVITY_DESC" )
}

function MouseAcceleration_Focused( button )
{
	local menu = GetMenu( "MouseKeyboardControlsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#MOUSE_KEYBOARD_MENU_ACCELERATION_DESC" )
}

function MouseInvert_Focused( button )
{
	local menu = GetMenu( "MouseKeyboardControlsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#MOUSE_KEYBOARD_MENU_INVERT_DESC" )
}

function PCFooterButtonClass_Focused( button )
{
	local menu = GetMenu( "MouseKeyboardControlsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "" )
}