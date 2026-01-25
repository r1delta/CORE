
function main()
{
	Globalize( InitMouseKeyboardControlsMenu )
}

function InitMouseKeyboardControlsMenu( menu )
{
	AddEventHandlerToButtonClass( menu, "MouseKeyboardBindingsButtonClass", UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "MouseKeyboardBindingsMenu" ) ) )

	AddEventHandlerToButtonClass( menu, "MouseKeyboardBindingsButtonClass", UIE_GET_FOCUS, MouseKeyboardBindings_Focused )
	AddEventHandlerToButtonClass( menu, "MouseSensitivitySliderClass", UIE_GET_FOCUS, MouseSensitivity_Focused )
	AddEventHandlerToButtonClass( menu, "MouseAccelerationSwitchClass", UIE_GET_FOCUS, MouseAcceleration_Focused )
	AddEventHandlerToButtonClass( menu, "MouseInvertSwitchClass", UIE_GET_FOCUS, MouseInvert_Focused )
	AddEventHandlerToButtonClass( menu, "PCFooterButtonClass", UIE_GET_FOCUS, PCFooterButtonClass_Focused )
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