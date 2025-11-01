
function main()
{
	Globalize( InitGamepadControlsMenu )
}

function InitGamepadControlsMenu( menu )
{
	AddEventHandlerToButtonClass( menu, "GamepadLayoutButtonClass", UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "GamepadLayoutMenu" ) ) )

	AddEventHandlerToButtonClass( menu, "GamepadLayoutButtonClass", UIE_GET_FOCUS, GamepadLayout_Focused )
	AddEventHandlerToButtonClass( menu, "LookSensitivitySwitchClass", UIE_GET_FOCUS, LookSensitivity_Focused )
	AddEventHandlerToButtonClass( menu, "LookInvertSwitchClass", UIE_GET_FOCUS, LookInvert_Focused )
	AddEventHandlerToButtonClass( menu, "LookDeadzoneSwitchClass", UIE_GET_FOCUS, LookDeadzone_Focused )
	AddEventHandlerToButtonClass( menu, "MoveDeadzoneSwitchClass", UIE_GET_FOCUS, MoveDeadzone_Focused )
	AddEventHandlerToButtonClass( menu, "VibrationSwitchClass", UIE_GET_FOCUS, Vibration_Focused )
	AddEventHandlerToButtonClass( menu, "PCFooterButtonClass", UIE_GET_FOCUS, PCFooterButtonClass_Focused )
}

function GamepadLayout_Focused( button )
{
	local menu = GetMenu( "GamepadControlsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#GAMEPAD_MENU_CONTROLS_DESC" )
}

function LookSensitivity_Focused( button )
{
	local menu = GetMenu( "GamepadControlsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#GAMEPAD_MENU_SENSITIVITY_DESC" )
}

function LookInvert_Focused( button )
{
	local menu = GetMenu( "GamepadControlsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#GAMEPAD_MENU_INVERT_DESC" )
}

function LookDeadzone_Focused( button )
{
	local menu = GetMenu( "GamepadControlsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#GAMEPAD_MENU_DRIFT_GUARD_DESC" )
}

function MoveDeadzone_Focused( button )
{
	local menu = GetMenu( "GamepadControlsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#GAMEPAD_MENU_MOVE_DRIFT_GUARD_DESC" )
}

function Vibration_Focused( button )
{
	local menu = GetMenu( "GamepadControlsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#GAMEPAD_MENU_VIBRATION_DESC" )
}

function PCFooterButtonClass_Focused( button )
{
	local menu = GetMenu( "GamepadControlsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "" )
}