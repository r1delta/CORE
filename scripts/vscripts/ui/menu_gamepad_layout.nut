
function main()
{
	PrecacheHUDMaterial( "../ui/menu/controls_menu/horizontal_move" )
	PrecacheHUDMaterial( "../ui/menu/controls_menu/horizontal_turn" )
	PrecacheHUDMaterial( "../ui/menu/controls_menu/vertical_move" )
	PrecacheHUDMaterial( "../ui/menu/controls_menu/vertical_turn" )

	Globalize( ExecCurrentGamepadButtonConfig )
	Globalize( ExecCurrentGamepadStickConfig )
	Globalize( InitGamepadLayoutMenu )
	Globalize( ButtonLayoutButton_Focused )
	Globalize( SouthpawButton_Focused )
	Globalize( StickLayoutButton_Focused )

	file.gamepadButtonLayoutImage <- null
	file.gamepadStickLayoutImage <- null
	if ( Durango_IsDurango() )
	{
		file.gamepadButtonLayoutImage = "../ui/menu/controls_menu/xboxone_gamepad_button_layout"
		file.gamepadStickLayoutImage = "../ui/menu/controls_menu/xboxone_gamepad_stick_layout"
	}
	else
	{
		file.gamepadButtonLayoutImage = "../ui/menu/controls_menu/xbox360_gamepad_button_layout"
		file.gamepadStickLayoutImage = "../ui/menu/controls_menu/xbox360_gamepad_stick_layout"
	}
}

function GetGamepadButtonLayout()
{
	local gamepadButtonLayout = GetConVarInt( "gamepad_button_layout" )
	assert( gamepadButtonLayout >= 0 && gamepadButtonLayout < uiGlobal.buttonConfigs.len() )

	if ( gamepadButtonLayout < 0 || gamepadButtonLayout >= uiGlobal.buttonConfigs.len() )
		gamepadButtonLayout = 0

	return gamepadButtonLayout
}

function GetGamepadStickLayout()
{
	local gamepadStickLayout = GetConVarInt( "gamepad_stick_layout" )
	assert( gamepadStickLayout >= 0 && gamepadStickLayout < uiGlobal.stickConfigs.len() )

	if ( gamepadStickLayout < 0 || gamepadStickLayout >= uiGlobal.stickConfigs.len() )
		gamepadStickLayout = 0

	return gamepadStickLayout
}

function GetButtonStance()
{
	local stance = "orthodox"
	if ( GetConVarInt( "gamepad_buttons_are_southpaw" ) != 0 )
		stance = "southpaw"

	return stance
}

function ExecCurrentGamepadButtonConfig()
{
	ExecConfig( uiGlobal.buttonConfigs[ GetGamepadButtonLayout() ][ GetButtonStance() ] )
}

function ExecCurrentGamepadStickConfig()
{
	ExecConfig( uiGlobal.stickConfigs[ GetGamepadStickLayout() ] )
}

function InitGamepadLayoutMenu( menu )
{
	AddEventHandlerToButtonClass( menu, "ButtonLayoutSwitchClass", UIE_GET_FOCUS, ThreadButtonLayoutButton_Focused )
	AddEventHandlerToButtonClass( menu, "SouthpawSwitchClass", UIE_GET_FOCUS, ThreadSouthpawButton_Focused )
	AddEventHandlerToButtonClass( menu, "StickLayoutSwitchClass", UIE_GET_FOCUS, ThreadStickLayoutButton_Focused )

	local elements = GetElementsByClassname( menu, "ButtonLayoutDescriptionClass" )
	foreach ( element in elements )
		element.EnableKeyBindingIcons()
}

function ThreadButtonLayoutButton_Focused( button )
{
	thread ButtonLayoutButton_Focused( button )
}

function ThreadSouthpawButton_Focused( button )
{
	thread SouthpawButton_Focused( button )
}

function ThreadStickLayoutButton_Focused( button )
{
	thread StickLayoutButton_Focused( button )
}

function ButtonLayoutButton_Focused( button )
{
	local menu = GetMenu( "GamepadLayoutMenu" )

	wait 0 // Needed for focus to actually take effect

	SetImagesByClassname( menu, "GamepadImageClass", file.gamepadButtonLayoutImage )
	ShowElementsByClassname( menu, "GamepadButtonLayoutClass" )
	HideElementsByClassname( menu, "GamepadStickLayoutClass" )
	ShowElementsByClassname( menu, "ButtonLayoutDescriptionClass" )
	HideElementsByClassname( menu, "ButtonSouthpawDescriptionClass" )
	HideElementsByClassname( menu, "StickLayoutDescriptionClass" )
	ShowElementsByClassname( menu, "GamepadButtonLayoutLegend" )

	local currentButtonConfig
	local lastButtonConfig

	while ( button.IsFocused() )
	{
		currentButtonConfig = GetGamepadButtonLayout()

		if ( currentButtonConfig != lastButtonConfig )
		{
			ExecCurrentGamepadButtonConfig()
			UpdateButtonDisplay()
			UpdateButtonLayoutDescription()
			lastButtonConfig = currentButtonConfig
		}

		wait 0
	}
}

function SouthpawButton_Focused( button )
{
	local menu = GetMenu( "GamepadLayoutMenu" )

	wait 0 // Needed for focus to actually take effect

	SetImagesByClassname( menu, "GamepadImageClass", file.gamepadButtonLayoutImage )
	ShowElementsByClassname( menu, "GamepadButtonLayoutClass" )
	HideElementsByClassname( menu, "GamepadStickLayoutClass" )
	HideElementsByClassname( menu, "ButtonLayoutDescriptionClass" )
	ShowElementsByClassname( menu, "ButtonSouthpawDescriptionClass" )
	HideElementsByClassname( menu, "StickLayoutDescriptionClass" )
	ShowElementsByClassname( menu, "GamepadButtonLayoutLegend" )

	local currentButtonStance
	local lastButtonStance

	while ( button.IsFocused() )
	{
		currentButtonStance = GetButtonStance()

		if ( currentButtonStance != lastButtonStance )
		{
			ExecCurrentGamepadButtonConfig()
			UpdateButtonDisplay()
			UpdateButtonSouthpawDescription()
			lastButtonStance = currentButtonStance
		}

		wait 0
	}
}

function StickLayoutButton_Focused( button )
{
	local menu = GetMenu( "GamepadLayoutMenu" )

	wait 0 // Needed for focus to actually take effect

	SetImagesByClassname( menu, "GamepadImageClass", file.gamepadStickLayoutImage )
	HideElementsByClassname( menu, "GamepadButtonLayoutClass" )
	ShowElementsByClassname( menu, "GamepadStickLayoutClass" )
	HideElementsByClassname( menu, "ButtonLayoutDescriptionClass" )
	HideElementsByClassname( menu, "ButtonSouthpawDescriptionClass" )
	ShowElementsByClassname( menu, "StickLayoutDescriptionClass" )
	HideElementsByClassname( menu, "LblDiffImgClass" )
	HideElementsByClassname( menu, "GamepadButtonLayoutLegend" )

	local currentStickConfig
	local lastStickConfig

	while ( button.IsFocused() )
	{
		currentStickConfig = GetGamepadStickLayout()

		if ( currentStickConfig != lastStickConfig )
		{
			ExecCurrentGamepadStickConfig()
			UpdateStickDisplay()
			UpdateStickLayoutDescription()
			lastStickConfig = currentStickConfig
		}

		wait 0
	}
}

function UpdateButtonDisplay()
{
	local buttonLayoutBinds = []
	buttonLayoutBinds.append( BUTTON_A )
	buttonLayoutBinds.append( BUTTON_B )
	buttonLayoutBinds.append( BUTTON_X )
	buttonLayoutBinds.append( BUTTON_Y )
	buttonLayoutBinds.append( BUTTON_TRIGGER_LEFT )
	buttonLayoutBinds.append( BUTTON_TRIGGER_RIGHT )
	buttonLayoutBinds.append( BUTTON_SHOULDER_LEFT )
	buttonLayoutBinds.append( BUTTON_SHOULDER_RIGHT )
	buttonLayoutBinds.append( BUTTON_DPAD_UP )
	buttonLayoutBinds.append( BUTTON_DPAD_DOWN )
	buttonLayoutBinds.append( BUTTON_DPAD_LEFT )
	buttonLayoutBinds.append( BUTTON_DPAD_RIGHT )
	buttonLayoutBinds.append( BUTTON_STICK_LEFT )
	buttonLayoutBinds.append( BUTTON_STICK_RIGHT )
	buttonLayoutBinds.append( BUTTON_BACK )
	buttonLayoutBinds.append( BUTTON_START )

	local binds = {}
	foreach( bindName in buttonLayoutBinds )
		binds[ bindName ] <- GetKeyBinding( bindName ).tolower()

	local stickInfo = GetStickInfo()
	local menu = GetMenu( "GamepadLayoutMenu" )

	HideElementsByClassname( GetMenu( "GamepadLayoutMenu" ), "LblDiffImgClass" )

	foreach( key, val in binds )
	{
		//printt( "key:", key, "val:", val )

		local bindDisplayName
		local stickVertical
		local stickText
		local leftText = null
		local rightText = null

		if ( key == BUTTON_STICK_LEFT || key == BUTTON_STICK_RIGHT )
		{
			if ( key == BUTTON_STICK_LEFT )
				stickVertical = stickInfo.ANALOG_LEFT_Y
			else
				stickVertical = stickInfo.ANALOG_RIGHT_Y

			if ( stickVertical == "move" )
				leftText = "#MOVE"
			else
				leftText = "#LOOK"

			bindDisplayName = "#STICK_TEXT"
			rightText = GetBindDisplayName( val )
		}
		else
		{
			bindDisplayName = GetBindDisplayName( val )
		}

		local elements = GetElementsByClassname( menu, GetButtonIndexName( key ) )
		foreach ( element in elements )
		{
			element.SetText( bindDisplayName, leftText, rightText )
			//printt( "Setting text on element:", element.GetName(), "to", bindDisplayName )
		}

		// This would ideally be read from the default config file so this doesn't have to stay in sync here
		local bindsDefault = {}
		bindsDefault[ BUTTON_A ] <- "+ability 3",
		bindsDefault[ BUTTON_B ] <- "+toggle_duck",
		bindsDefault[ BUTTON_X ] <- "+useandreload",
		bindsDefault[ BUTTON_Y ] <- "+weaponpickupandcycle",
		bindsDefault[ BUTTON_TRIGGER_LEFT ] <- "+zoom",
		bindsDefault[ BUTTON_TRIGGER_RIGHT ] <- "+attack",
		bindsDefault[ BUTTON_SHOULDER_LEFT ] <- "+offhand2",
		bindsDefault[ BUTTON_SHOULDER_RIGHT ] <- "+offhand1",
		bindsDefault[ BUTTON_DPAD_UP ] <- "+scriptcommand1",
		bindsDefault[ BUTTON_DPAD_DOWN ] <- "+ability 1",
		bindsDefault[ BUTTON_DPAD_LEFT ] <- "weaponselectordnance",
		bindsDefault[ BUTTON_DPAD_RIGHT ] <- "+displayFullscreenMap",
		bindsDefault[ BUTTON_STICK_LEFT ] <- "+speed",
		bindsDefault[ BUTTON_STICK_RIGHT ] <- "+melee",
		bindsDefault[ BUTTON_BACK ] <- "+showscores",
		bindsDefault[ BUTTON_START ] <- "ingamemenu_activate"

		if ( GetButtonStance() == "southpaw" )
		{
			bindsDefault[ BUTTON_TRIGGER_LEFT ] = "+attack"
			bindsDefault[ BUTTON_TRIGGER_RIGHT ] = "+zoom"
			bindsDefault[ BUTTON_SHOULDER_LEFT ] = "+offhand1"
			bindsDefault[ BUTTON_SHOULDER_RIGHT ] = "+offhand2"
			bindsDefault[ BUTTON_STICK_LEFT ] = "+melee"
			bindsDefault[ BUTTON_STICK_RIGHT ] = "+speed"
		}

		foreach( keyDefault, valDefault in bindsDefault )
		{
			if ( key == keyDefault && val != valDefault )
				ShowButtonDiffArrow( key )
		}
	}
}

function ShowButtonDiffArrow( key )
{
	local className = ""

	switch ( key )
	{
		case BUTTON_A:
			className = "LblButtonADiffImgClass"
			break

		case BUTTON_B:
			className = "LblButtonBDiffImgClass"
			break

		case BUTTON_X:
			className = "LblButtonXDiffImgClass"
			break

		case BUTTON_Y:
			className = "LblButtonYDiffImgClass"
			break

		case BUTTON_TRIGGER_LEFT:
			className = "LblButtonLTDiffImgClass"
			break

		case BUTTON_TRIGGER_RIGHT:
			className = "LblButtonRTDiffImgClass"
			break

		case BUTTON_SHOULDER_LEFT:
			className = "LblButtonLBDiffImgClass"
			break

		case BUTTON_SHOULDER_RIGHT:
			className = "LblButtonRBDiffImgClass"
			break

		case BUTTON_DPAD_UP:
			className = "LblButtonUpDiffImgClass"
			break

		case BUTTON_DPAD_DOWN:
			className = "LblButtonDownDiffImgClass"
			break

		case BUTTON_DPAD_LEFT:
			className = "LblButtonLeftDiffImgClass"
			break

		case BUTTON_DPAD_RIGHT:
			className = "BUTTON_DPAD_RIGHT"
			break

		case BUTTON_STICK_LEFT:
			className = "LblButtonLSDiffImgClass"
			break

		case BUTTON_STICK_RIGHT:
			className = "LblButtonRSDiffImgClass"
			break

		case BUTTON_BACK:
			className = "LblButtonBackDiffImgClass"
			break

		case BUTTON_START:
			className = "LblButtonStartDiffImgClass"
			break

		default:
			assert( 0 )
			break
	}

	ShowElementsByClassname( GetMenu( "GamepadLayoutMenu" ), className )

}

function UpdateButtonLayoutDescription()
{
	local cfg = uiGlobal.buttonConfigs[ GetGamepadButtonLayout() ][ GetButtonStance() ]
	local description = ""

	switch ( cfg )
	{
		case "gamepad_button_layout_default.cfg":
		case "gamepad_button_layout_default_southpaw.cfg":
			description = "#BUTTON_LAYOUT_DEFAULT_DESC"
			break

		case "gamepad_button_layout_bumper_jumper.cfg":
			description = "#BUTTON_LAYOUT_BUMPER_JUMPER_DESC"
			break

		case "gamepad_button_layout_bumper_jumper_southpaw.cfg":
			description = "#BUTTON_LAYOUT_BUMPER_JUMPER_SOUTHPAW_DESC"
			break

		case "gamepad_button_layout_bumper_jumper_alt.cfg":
			description = "#BUTTON_LAYOUT_BUMPER_JUMPER_ALT_DESC"
			break

		case "gamepad_button_layout_bumper_jumper_alt_southpaw.cfg":
			description = "#BUTTON_LAYOUT_BUMPER_JUMPER_ALT_SOUTHPAW_DESC"
			break

		case "gamepad_button_layout_pogo_stick.cfg":
			description = "#BUTTON_LAYOUT_POGO_STICK_DESC"
			break

		case "gamepad_button_layout_pogo_stick_southpaw.cfg":
			description = "#BUTTON_LAYOUT_POGO_STICK_SOUTHPAW_DESC"
			break

		case "gamepad_button_layout_button_kicker.cfg":
			description = "#BUTTON_LAYOUT_BUTTON_KICKER_DESC"
			break
		case "gamepad_button_layout_button_kicker_southpaw.cfg":
			description = "#BUTTON_LAYOUT_BUTTON_KICKER_SOUTHPAW_DESC"
			break

		case "gamepad_button_layout_circle.cfg":
			description = "#BUTTON_LAYOUT_CIRCLE_DESC"
			break

		case "gamepad_button_layout_circle_southpaw.cfg":
			description = "#BUTTON_LAYOUT_CIRCLE_SOUTHPAW_DESC"
			break

		default:
			assert( 0, "Add a hint for the config" )
			break
	}

	local menu = GetMenu( "GamepadLayoutMenu" )
	local elements = GetElementsByClassname( menu, "ButtonLayoutDescriptionClass" )
	foreach ( element in elements )
		element.SetText( description )
}

function UpdateButtonSouthpawDescription()
{
	local description = "#BUTTON_SOUTHPAW_DISABLED_DESC"
	if ( GetConVarInt( "gamepad_buttons_are_southpaw" ) != 0 )
		description = "#BUTTON_SOUTHPAW_ENABLED_DESC"

	SetElementsTextByClassname( GetMenu( "GamepadLayoutMenu" ), "ButtonSouthpawDescriptionClass", description )
}

function UpdateStickLayoutDescription()
{
	local description = ""

	local movementStick = GetConVarInt( "joy_movement_stick" )
	local legacy = GetConVarInt( "joy_legacy" )

	if ( movementStick == 0 )
		if ( legacy == 0 )
			description = "#STICK_LAYOUT_DEFAULT_DESC"
		else
			description = "#STICK_LAYOUT_LEGACY_DESC"
	else
		if ( legacy == 0 )
			description = "#STICK_LAYOUT_SOUTHPAW_DESC"
		else
			description = "#STICK_LAYOUT_LEGACY_SOUTHPAW_DESC"

	SetElementsTextByClassname( GetMenu( "GamepadLayoutMenu" ), "StickLayoutDescriptionClass", description )
}

function UpdateStickDisplay()
{
	local stickInfo = GetStickInfo()

	local leftHorizontalImage = "../ui/menu/controls_menu/horizontal_" + stickInfo.ANALOG_LEFT_X
	local leftVerticalImage = "../ui/menu/controls_menu/vertical_" + stickInfo.ANALOG_LEFT_Y
	local rightHorizontalImage = "../ui/menu/controls_menu/horizontal_" + stickInfo.ANALOG_RIGHT_X
	local rightVerticalImage = "../ui/menu/controls_menu/vertical_" + stickInfo.ANALOG_RIGHT_Y
	local leftHorizontalDesc
	local leftVerticalDesc
	local rightHorizontalDesc
	local rightVerticalDesc

	if ( stickInfo.ANALOG_LEFT_X == "move" )
		leftHorizontalDesc = "#MOVE_LEFT_RIGHT"
	else
		leftHorizontalDesc = "#TURN_LEFT_RIGHT"

	if ( stickInfo.ANALOG_LEFT_Y == "move" )
		leftVerticalDesc = "#MOVE_FORWARD_BACKWARD"
	else
		leftVerticalDesc = "#LOOK_UP_DOWN"

	if ( stickInfo.ANALOG_RIGHT_X == "move" )
		rightHorizontalDesc = "#MOVE_LEFT_RIGHT"
	else
		rightHorizontalDesc = "#TURN_LEFT_RIGHT"

	if ( stickInfo.ANALOG_RIGHT_Y == "move" )
		rightVerticalDesc = "#MOVE_FORWARD_BACKWARD"
	else
		rightVerticalDesc = "#LOOK_UP_DOWN"

	local menu = GetMenu( "GamepadLayoutMenu" )

	local elements = GetElementsByClassname( menu, "LeftHorizontalImageClass" )
	foreach ( element in elements )
		element.SetImage( leftHorizontalImage )

	local elements = GetElementsByClassname( menu, "LeftVerticalImageClass" )
	foreach ( element in elements )
		element.SetImage( leftVerticalImage )

	local elements = GetElementsByClassname( menu, "RightHorizontalImageClass" )
	foreach ( element in elements )
		element.SetImage( rightHorizontalImage )

	local elements = GetElementsByClassname( menu, "RightVerticalImageClass" )
	foreach ( element in elements )
		element.SetImage( rightVerticalImage )

	local elements = GetElementsByClassname( menu, "LeftHorizontalDescClass" )
	foreach ( element in elements )
		element.SetText( leftHorizontalDesc )

	local elements = GetElementsByClassname( menu, "LeftVerticalDescClass" )
	foreach ( element in elements )
		element.SetText( leftVerticalDesc )

	local elements = GetElementsByClassname( menu, "RightHorizontalDescClass" )
	foreach ( element in elements )
		element.SetText( rightHorizontalDesc )

	local elements = GetElementsByClassname( menu, "RightVerticalDescClass" )
	foreach ( element in elements )
		element.SetText( rightVerticalDesc )
}

function GetBindDisplayName( bind )
{
	local displayName

	switch ( bind )
	{
		case "+zoom":
			displayName = "#AIM_MODIFIER"
			break

		case "+toggle_zoom":
			displayName = "#AIM_MODIFIER"
			break

		case "+attack":
			displayName = "#FIRE"
			break

		case "+ability 3":
			displayName = "#JUMP_PILOT_DASH_TITAN"
			break

		case "+ability 4":
			displayName = "#JUMP_PILOT_SPECIAL_ABILITY_TITAN"
			break

		case "+ability 5":
			displayName = "#SPECIAL_ABILITY_PILOT_DASH_TITAN"
			break

		case "+toggle_duck":
			displayName = "#CROUCH"
			break

		case "+useandreload":
			displayName = "#USE_RELOAD"
			break

		case "+weaponpickupandcycle":
			displayName = "#SWITCH_PICKUP_WEAPONS_PILOT"
			break

		case "+offhand1":
			displayName = "#ORDNANCE_GRENADE"
			break

		case "+offhand2":
			displayName = "#SPECIAL_ABILITY"
			break

		case "+showscores":
			displayName = "#SCOREBOARD"
			break

		case "+displayfullscreenmap":
			displayName = "#DISPLAY_FULLSCREEN_MINIMAP"
			break

		case "ingamemenu_activate":
			displayName = "#LOADOUTS_SETTINGS"
			break

		case "+speed":
			displayName = "#SPRINT"
			break

		case "+melee":
			displayName = "#MELEE"
			break

		case "+scriptcommand1":
			displayName = "#DISABLE_EJECT_SAFETY_TITAN"
			break

		case "+ability 1":
			displayName = "#SWITCH_TITAN_AI_MODE_PILOT"
			break

		case "weaponselectordnance":
			displayName = "#EQUIP_ANTITITAN_WEAPON_PILOT"
			break

		default:
			displayName = bind
			break
	}

	return displayName
}

function GetButtonIndexName( index )
{
	local name

	switch ( index )
	{
		case BUTTON_A:
			name = "BUTTON_A"
			break

		case BUTTON_B:
			name = "BUTTON_B"
			break

		case BUTTON_X:
			name = "BUTTON_X"
			break

		case BUTTON_Y:
			name = "BUTTON_Y"
			break

		case BUTTON_TRIGGER_LEFT:
			name = "BUTTON_TRIGGER_LEFT"
			break

		case BUTTON_TRIGGER_RIGHT:
			name = "BUTTON_TRIGGER_RIGHT"
			break

		case BUTTON_SHOULDER_LEFT:
			name = "BUTTON_SHOULDER_LEFT"
			break

		case BUTTON_SHOULDER_RIGHT:
			name = "BUTTON_SHOULDER_RIGHT"
			break

		case BUTTON_DPAD_UP:
			name = "BUTTON_DPAD_UP"
			break

		case BUTTON_DPAD_DOWN:
			name = "BUTTON_DPAD_DOWN"
			break

		case BUTTON_DPAD_LEFT:
			name = "BUTTON_DPAD_LEFT"
			break

		case BUTTON_DPAD_RIGHT:
			name = "BUTTON_DPAD_RIGHT"
			break

		case BUTTON_STICK_LEFT:
			name = "BUTTON_STICK_LEFT"
			break

		case BUTTON_STICK_RIGHT:
			name = "BUTTON_STICK_RIGHT"
			break

		case BUTTON_BACK:
			name = "BUTTON_BACK"
			break

		case BUTTON_START:
			name = "BUTTON_START"
			break

		default:
			name = "Unknown button index: " + index
			break
	}

	return name
}

function GetStickInfo()
{
	local stickInfo = {}
	stickInfo.ANALOG_LEFT_X <- null
	stickInfo.ANALOG_LEFT_Y <- null
	stickInfo.ANALOG_RIGHT_X <- null
	stickInfo.ANALOG_RIGHT_Y <- null

	local movementStick = GetConVarInt( "joy_movement_stick" )
	local legacy = GetConVarInt( "joy_legacy" )

	if ( movementStick == 0 )
	{
		if ( legacy == 0 )
		{
			stickInfo.ANALOG_LEFT_X = "move"
			stickInfo.ANALOG_LEFT_Y = "move"

			stickInfo.ANALOG_RIGHT_X = "turn"
			stickInfo.ANALOG_RIGHT_Y = "turn"
		}
		else
		{
			stickInfo.ANALOG_LEFT_X = "turn"
			stickInfo.ANALOG_LEFT_Y = "move"

			stickInfo.ANALOG_RIGHT_X = "move"
			stickInfo.ANALOG_RIGHT_Y = "turn"
		}
	}
	else
	{
		if ( legacy == 0 )
		{
			stickInfo.ANALOG_LEFT_X = "turn"
			stickInfo.ANALOG_LEFT_Y = "turn"

			stickInfo.ANALOG_RIGHT_X = "move"
			stickInfo.ANALOG_RIGHT_Y = "move"
		}
		else
		{
			stickInfo.ANALOG_LEFT_X = "move"
			stickInfo.ANALOG_LEFT_Y = "turn"

			stickInfo.ANALOG_RIGHT_X = "turn"
			stickInfo.ANALOG_RIGHT_Y = "move"
		}
	}

	return stickInfo
}
