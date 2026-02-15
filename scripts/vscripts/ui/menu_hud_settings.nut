
function main()
{
	Globalize( InitHudSettingsMenu )
	Globalize( OnOpenHudSettingsMenu )
	Globalize( OnCloseHudSettingsMenu )
	Globalize( RestoreDefaultHUDDialog )
}

function InitHudSettingsMenu( menu )
{
	// TODO: keybind icons, grenade style, objective marker opacity
	SetupButton( menu.GetChild( "BtnHudSettingsR1D" ), "Change options for R1Delta specific HUD elemens." )

	SetupButton( menu.GetChild( "SwchColorBlindMode" ), "#OPTIONS_MENU_COLORBLIND_TYPE_DESC" )
	SetupButton( menu.GetChild( "SwchExtendedColorBlind" ), "#OPTIONS_MENU_EXTENDED_COLORBLIND_DESC" )
	SetupButton( menu.GetChild( "SwchGrenadeIndicator" ), "Change grenade indicator style. \n\n0: 2D Texture. \n\n1: 3D Model." )

	SetupButton( menu.GetChild( "SwchATHint" ), "Show anti-titan weapon hint." )
	SetupButton( menu.GetChild( "SwchChatMessages" ), "Show chat messages." )
	SetupButton( menu.GetChild( "SwchCrosshair" ), "Show crosshair. Note: disabling this will also hide all hitmarkers." )
	SetupButton( menu.GetChild( "SwchHitmarkers" ), "Show hitmarkers. Note: disabling the crosshair will also hide all hitmarkers." )
	SetupButton( menu.GetChild( "SwchFlyout" ), "Show information about your weapons when you switch between them." )
	SetupButton( menu.GetChild( "SwchKeybindIcons" ), "Show persistent button prompts for your weapons and abilities on the HUD." )
	SetupButton( menu.GetChild( "SwchChallengeCompleted" ), "Show challenge completed notifications." )
	SetupButton( menu.GetChild( "SwchLevelup" ), "Show level up notifications." )
	SetupButton( menu.GetChild( "SwchObituaries" ), "Show obituaries for player kills and deaths." )
	SetupButton( menu.GetChild( "SwchTitanEarnings" ), "Show titan timer earnings below the crosshair." )
	SetupButton( menu.GetChild( "SwchVDU" ), "Show character VDUs on the top right." )
	SetupButton( menu.GetChild( "SwchXPBar" ), "Show XP Bar." )
	SetupButton( menu.GetChild( "SwchHudWarp" ), "Enable spherical warp distortion for the HUD. Disabling it may help performance." )
	SetupButton( menu.GetChild( "SwchSafeArea" ), "#OPTIONS_MENU_SAFE_AREA_DESC" )

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