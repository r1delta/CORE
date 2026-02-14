
function main()
{
	Globalize( InitHudSettingsR1DMenu )
	Globalize( OnOpenHudSettingsR1DMenu )
	Globalize( OnCloseHudSettingsR1DMenu )
}

function InitHudSettingsR1DMenu( menu )
{
	SetupButton( menu.GetChild( "SwchDamageNumbers" ), "Show TF2-style floating damage numbers on hit." )
	SetupButton( menu.GetChild( "SwchLegacyProgressbar" ), "Show the classic Source engine loading bar on loadscreen." )
	SetupButton( menu.GetChild( "SwchScriptNotification" ), "Show a notification whenever a script error occurs." )
	SetupButton( menu.GetChild( "SwchWatermark" ), "Show R1Delta watermark with version information." )

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