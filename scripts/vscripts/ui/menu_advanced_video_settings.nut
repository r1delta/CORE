
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
}

function OnCloseAdvancedVideoSettingsMenu( menu )
{
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
	local menu = GetMenu( "AdvancedVideoSettingsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#ADVANCED_VIDEO_MENU_FOV_DESC" )
}

function PCFooterButtonClass_Focused( button )
{
	local menu = GetMenu( "AdvancedVideoSettingsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "" )
}
