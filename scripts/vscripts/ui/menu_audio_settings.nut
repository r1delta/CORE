
function main()
{
	Globalize( InitAudioSettingsMenu )
}

function InitAudioSettingsMenu( menu )
{
	AddEventHandlerToButtonClass( menu, "MusicSettingClassicMPSwitchClass", UIE_GET_FOCUS, MusicSettingClassicMP_Focused )
	AddEventHandlerToButtonClass( menu, "SubtitlesSwitchClass", UIE_GET_FOCUS, Subtitles_Focused )
	AddEventHandlerToButtonClass( menu, "SpeakerConfigSwitchClass", UIE_GET_FOCUS, SpeakerConfig_Focused )
	AddEventHandlerToButtonClass( menu, "CalculateOcclusionSwitchClass", UIE_GET_FOCUS, CalculateOcclusion_Focused )
	AddEventHandlerToButtonClass( menu, "EmitterLimitSwitchClass", UIE_GET_FOCUS, EmitterLimit_Focused )
	AddEventHandlerToButtonClass( menu, "PCFooterButtonClass", UIE_GET_FOCUS, PCFooterButtonClass_Focused )
}

function MusicSettingClassicMP_Focused( button )
{
	local menu = GetMenu( "AudioSettingsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#OPTIONS_MENU_MUSIC_SETTING_DESC" )
}

function Subtitles_Focused( button )
{
	local menu = GetMenu( "AudioSettingsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#OPTIONS_MENU_SUBTITLES_DESC" )
}

function SpeakerConfig_Focused( button )
{
	local menu = GetMenu( "AudioSettingsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#OPTIONS_MENU_SPEAKER_CONFIG_DESC" )
}

function CalculateOcclusion_Focused( button )
{
	local menu = GetMenu( "AudioSettingsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#OPTIONS_MENU_CALCULATE_OCCLUSION_DESC" )
}

function EmitterLimit_Focused( button )
{
	local menu = GetMenu( "AudioSettingsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "#OPTIONS_MENU_EMITTER_LIMIT_DESC" )
}

function PCFooterButtonClass_Focused( button )
{
	local menu = GetMenu( "AudioSettingsMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "" )
}