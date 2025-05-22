
function main()
{
	Globalize( InitOptionsMenu )
	Globalize( OnCloseOptionsMenu )
	Globalize( OnOpenOptionsMenu )
	Globalize( OnXboxHelp_Activate )
}

function InitOptionsMenu( menu )
{
	AddEventHandlerToButtonClass( menu, "MouseKeyboardControlsButtonClass", UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "MouseKeyboardControlsMenu" ) ) )
	AddEventHandlerToButtonClass( menu, "GamepadControlsButtonClass", UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "GamepadControlsMenu" ) ) )
	AddEventHandlerToButtonClass( menu, "AudioSettingsButtonClass", UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "AudioSettingsMenu" ) ) )
	AddEventHandlerToButtonClass( menu, "AdvancedVideoSettingsButtonClass", UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "AdvancedVideoSettingsMenu" ) ) )
	AddEventHandlerToButtonClass( menu, "HelpAndSupportButtonClass", UIE_CLICK, OnXboxHelp_Activate )

	AddEventHandlerToButtonClass( menu, "MouseKeyboardControlsButtonClass", UIE_GET_FOCUS, MouseKeyboardControls_Focused )
	AddEventHandlerToButtonClass( menu, "GamepadControlsButtonClass", UIE_GET_FOCUS, GamepadControls_Focused )
	AddEventHandlerToButtonClass( menu, "AutoSprintSwitchClass", UIE_GET_FOCUS, AutoSprint_Focused )
	AddEventHandlerToButtonClass( menu, "MasterVolumeSliderClass", UIE_GET_FOCUS, MasterVolume_Focused )
	AddEventHandlerToButtonClass( menu, "VoiceChatSliderClass", UIE_GET_FOCUS, VoiceChat_Focused )
	AddEventHandlerToButtonClass( menu, "MusicVolumeSliderClass", UIE_GET_FOCUS, MusicVolume_Focused )
	AddEventHandlerToButtonClass( menu, "LobbyMusicVolumeSliderClass", UIE_GET_FOCUS, LobbyMusicVolume_Focused )
	AddEventHandlerToButtonClass( menu, "MusicSettingClassicMPSwitchClass", UIE_GET_FOCUS, MusicSettingClassicMP_Focused )
	AddEventHandlerToButtonClass( menu, "SubtitlesSwitchClass", UIE_GET_FOCUS, Subtitles_Focused )
	AddEventHandlerToButtonClass( menu, "SafeAreaSwitchClass", UIE_GET_FOCUS, SafeArea_Focused )
	AddEventHandlerToButtonClass( menu, "ColorBlindModeClass", UIE_GET_FOCUS, ColorBlindMode_Focused )
	AddEventHandlerToButtonClass( menu, "AdvancedVideoSettingsButtonClass", UIE_GET_FOCUS, AdvancedVideoSettings_Focused )
	AddEventHandlerToButtonClass( menu, "HelpAndSupportButtonClass", UIE_GET_FOCUS, HelpAndSupportButton_Focused )
	AddEventHandlerToButtonClass( menu, "PCFooterButtonClass", UIE_GET_FOCUS, PCFooterButtonClass_Focused )
}

function OnOpenOptionsMenu( menu )
{
	local buttons = GetElementsByClassname( menu, "SafeAreaSwitchClass" )

	local enable = true
	if ( IsConnected() )
		enable = false

	foreach ( button in buttons )
		button.SetEnabled( enable )
}

function OnCloseOptionsMenu()
{
	SavePlayerSettings()
}

function MouseKeyboardControls_Focused( button )
{
	local menu = GetMenu( "OptionsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#OPTIONS_MENU_MOUSE_KEYBOARD_SETTINGS_DESC" )
}

function GamepadControls_Focused( button )
{
	local menu = GetMenu( "OptionsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#OPTIONS_MENU_CONTROLLER_SETTINGS_DESC" )
}

function AutoSprint_Focused( button )
{
	local menu = GetMenu( "OptionsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#OPTIONS_MENU_AUTOSPRINT_DESC" )
}

function MasterVolume_Focused( button )
{
	local menu = GetMenu( "OptionsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#OPTIONS_MENU_MASTER_VOLUME_DESC" )
}

function VoiceChat_Focused( button )
{
	local menu = GetMenu( "OptionsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#OPTIONS_MENU_VOICE_CHAT_DESC" )
}

function MusicVolume_Focused( button )
{
	local menu = GetMenu( "OptionsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#OPTIONS_MENU_MUSIC_VOLUME_DESC" )
}

function LobbyMusicVolume_Focused( button )
{
	local menu = GetMenu( "OptionsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#OPTIONS_MENU_LOBBY_MUSIC_VOLUME_DESC" )
}

function MusicSettingClassicMP_Focused( button )
{
	local menu = GetMenu( "OptionsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#OPTIONS_MENU_MUSIC_SETTING_DESC" )
}

function Subtitles_Focused( button )
{
	local menu = GetMenu( "OptionsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#OPTIONS_MENU_SUBTITLES_DESC" )
}

function SafeArea_Focused( button )
{
	local menu = GetMenu( "OptionsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#OPTIONS_MENU_SAFE_AREA_DESC" )
}

function ColorBlindMode_Focused( button )
{
	local menu = GetMenu( "OptionsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#OPTIONS_MENU_COLORBLIND_TYPE_DESC" )
}

function AdvancedVideoSettings_Focused( button )
{
	local menu = GetMenu( "OptionsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#OPTIONS_MENU_ADVANCED_VIDEO_SETTINGS_DESC" )
}

function HelpAndSupportButton_Focused( button )
{
	local menu = GetMenu( "OptionsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#OPTIONS_MENU_HELP_AND_SUPPORT" )
}

function OnXboxHelp_Activate( button )
{
	Durango_ShowHelpWindow()
}

function PCFooterButtonClass_Focused( button )
{
	local menu = GetMenu( "OptionsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "" )
}
