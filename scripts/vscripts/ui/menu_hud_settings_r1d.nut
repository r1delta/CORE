
function main()
{
	Globalize( InitHudSettingsR1DMenu )
	Globalize( OnOpenHudSettingsR1DMenu )
	Globalize( OnCloseHudSettingsR1DMenu )
}

function InitHudSettingsR1DMenu( menu )
{
	SetupButton( menu.GetChild( "SwchDamageNumbers" ), "#OPTIONS_MENU_DAMAGE_NUMBERS_DESC" )
	SetupButton( menu.GetChild( "SwchLegacyProgressbar" ), "#OPTIONS_MENU_OLD_PROGRESS_DESC" )
	SetupButton( menu.GetChild( "SwchScriptNotification" ), "#OPTIONS_MENU_ERROR_NOTIFICATION_DESC" )
	SetupButton( menu.GetChild( "SwchWatermark" ), "#OPTIONS_MENU_DELTA_WATERMARK_DESC" )

	AddEventHandlerToButtonClass( menu, "PCFooterButtonClass", UIE_GET_FOCUS, PCFooterButtonClass_Focused )
}

function OnOpenHudSettingsR1DMenu( menu )
{
}

function OnCloseHudSettingsR1DMenu( menu )
{
}

function PCFooterButtonClass_Focused( button )
{
	local menu = GetMenu( "HudSettingsR1DMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "" )
}