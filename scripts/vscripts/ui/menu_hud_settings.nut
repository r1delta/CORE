
function main()
{
	Globalize( InitHudSettingsMenu )
	Globalize( OnOpenHudSettingsMenu )
	Globalize( OnCloseHudSettingsMenu )
	Globalize( RestoreDefaultHUDDialog )
}

function InitHudSettingsMenu( menu )
{
	// TODO: keybind icons, objective marker opacity
	SetupButton( menu.GetChild( "BtnHudSettingsR1D" ), "#OPTIONS_MENU_HUD_R1D_DESC" )

	SetupButton( menu.GetChild( "SwchColorBlindMode" ), "#OPTIONS_MENU_COLORBLIND_TYPE_DESC" )
	SetupButton( menu.GetChild( "SwchExtendedColorBlind" ), "#OPTIONS_MENU_EXTENDED_COLORBLIND_DESC" )
	SetupButton( menu.GetChild( "SwchGrenadeIndicator" ), "#OPTIONS_MENU_GRENADE_INDICATOR_DESC" )

	SetupButton( menu.GetChild( "SwchATHint" ), "#OPTIONS_MENU_AT_HINT_DESC" )
	SetupButton( menu.GetChild( "SwchChatMessages" ), "#OPTIONS_MENU_CHAT_MESSAGES_DESC" )
	SetupButton( menu.GetChild( "SwchCrosshair" ), "#OPTIONS_MENU_CROSSHAIR_DESC" )
	SetupButton( menu.GetChild( "SwchHitmarkers" ), "#OPTIONS_MENU_HITMARKERS_DESC" )
	SetupButton( menu.GetChild( "SwchFlyout" ), "#OPTIONS_MENU_WEAPON_FLYOUTS_DESC" )
	SetupButton( menu.GetChild( "SwchKeybindIcons" ), "#OPTIONS_MENU_KEYBIND_ICONS_DESC" )
	SetupButton( menu.GetChild( "SwchChallengeCompleted" ), "#OPTIONS_MENU_CHALLENGE_COMP_DESC" )
	SetupButton( menu.GetChild( "SwchLevelup" ), "#OPTIONS_MENU_LEVELUP_DESC" )
	SetupButton( menu.GetChild( "SwchObituaries" ), "#OPTIONS_MENU_OBITUARIES_DESC" )
	SetupButton( menu.GetChild( "SwchTitanEarnings" ), "#OPTIONS_MENU_TITAN_EARNINGS_DESC" )
	SetupButton( menu.GetChild( "SwchVDU" ), "#OPTIONS_MENU_CHARACTER_VDU_DESC" )
	SetupButton( menu.GetChild( "SwchXPBar" ), "#OPTIONS_MENU_XP_BAR_DESC" )
	SetupButton( menu.GetChild( "SwchHudWarp" ), "#OPTIONS_MENU_HUD_WARPING_DESC" )
	SetupButton( menu.GetChild( "SwchSafeArea" ), "#OPTIONS_MENU_SAFE_AREA_DESC" )

	// Convar currently doesnt do anything
	menu.GetChild( "SwchHudWarp" ).SetLocked( true )
	menu.GetChild( "SwchHudWarp" ).SetEnabled( false )

	AddEventHandlerToButtonClass( menu, "HudSettingsR1DButtonClass", UIE_CLICK, ReplaceMenuEventHandlerNoPop( GetMenu( "HudSettingsR1DMenu" ) ) ) //AdvanceMenuEventHandler
	AddEventHandlerToButtonClass( menu, "ObjectiveOpacityClass", UIE_GET_FOCUS, ObjectiveOpacityClass_Focused )
	AddEventHandlerToButtonClass( menu, "PCFooterButtonClass", UIE_GET_FOCUS, PCFooterButtonClass_Focused )
}

function OnOpenHudSettingsMenu( menu )
{
	local buttons = GetElementsByClassname( menu, "SafeAreaSwitchClass" )

	local enable = true
	if ( IsConnected() )
		enable = false

	foreach ( button in buttons )
		button.SetEnabled( enable )

	RegisterButtonPressedCallback( BUTTON_Y, RestoreDefaultHUDDialog )
}

function OnCloseHudSettingsMenu( menu )
{
	if ( IsConnected() && CanRunClientScript() )
	{
		RunClientScript0( "ToggleChatVisibility", false )
		RunClientScript0( "ToggleCockpitElementsVisibility", false )
	}

	DeregisterButtonPressedCallback( BUTTON_Y, RestoreDefaultHUDDialog )
}

function RestoreDefaultHUDDialog( button )
{
	if ( uiGlobal.activeDialog )
		return

	local buttonData = []
	buttonData.append( { name = "#RESTORE", func = DialogChoice_RestoreDefaultSettings } )
	buttonData.append( { name = "#CANCEL", func = null } )

	local dialogData = {}
	dialogData.header <- "#RESTORE_RECOMMENDED_VIDEO_SETTINGS"
	dialogData.buttonData <- buttonData

	OpenChoiceDialog( dialogData )
}

function DialogChoice_RestoreDefaultSettings()
{
	ClientCommand( "colorblind_mode 0" )
	ClientCommand( "delta_improved_colorblind 0" )
	ClientCommand( "delta_hud_grenade_style 0" )
	ClientCommand( "delta_hud_objective_opacity 255" )

	ClientCommand( "delta_hud_show_AT_hint 1" )
	ClientCommand( "delta_hud_show_chat 1" )
	ClientCommand( "delta_hud_show_flyout 1" )
	ClientCommand( "crosshair_enabled 1" )
	ClientCommand( "delta_hud_show_hitmarkers 1" )
	ClientCommand( "delta_hud_show_keybind_icons 1" )
	ClientCommand( "delta_hud_show_challenge_completed 1" )
	ClientCommand( "delta_hud_show_levelup 1" )
	ClientCommand( "delta_hud_show_obituaries 1" )
	ClientCommand( "delta_hud_show_titan_earnings 1" )
	ClientCommand( "delta_hud_show_vdu 1" )
	ClientCommand( "delta_hud_show_xpbar 1" )
	ClientCommand( "hudwarp_disable 0" )

	if ( !IsConnected() )
	{
		ClientCommand( "cl_safearea 0" )
	}
}

function ObjectiveOpacityClass_Focused( button )
{
	local menu = GetMenu( "HudSettingsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "Opacity for objective markers on the hud (CTF Flags, Hardpoint control points, etc)." )
}

function PCFooterButtonClass_Focused( button )
{
	local menu = GetMenu( "HudSettingsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "" )
}