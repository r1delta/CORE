
function main()
{
	Globalize( OnOpenModesMenu )
	Globalize( OnCloseModesMenu )
	Globalize( InitModesMenu )

	Globalize( InitMatchSettingsMenu )
	Globalize( OnOpenMatchSettingsMenu )
	Globalize( OnCloseMatchSettingsMenu )

	Globalize( NavigateBackApplyMatchSettingsDialog )
    Globalize( GotoCampaignLobby )

	file.modeSettingsButton <- null
	file.scoreLimitButton <- null
		file.scoreLimitLabel <- null
	file.timeLimitButton <- null
		file.timeLimitLabel <- null
	file.burnCardSetButton <- null

	file.pilotHealthButton <- null
	file.pilotAmmoButton <- null
	file.minimapButton <- null
	file.pilotRespawnDelayButton <- null
		file.pilotRespawnDelayLabel <- null

	file.titanBuildButton <- null
		file.titanBuildLabel <- null
	file.titanRebuildButton <- null
		file.titanRebuildLabel <- null
	file.titanShieldCapacityButton <- null

	file.aiTypeButton <- null
	file.aiLethalityButton <- null

	file.gameModeLabel <- null

	file.matchSettingDescLabel <- null

	file.pmVarValues <- {}
	file.modeSettingsName <- null

	RegisterSignal( "OnCloseMatchSettingsMenu" )
}

function InitModesMenu( menu )
{
	AddEventHandlerToButtonClass( menu, "ModeButton", UIE_GET_FOCUS, ModeButton_GetFocus )
	AddEventHandlerToButtonClass( menu, "ModeButton", UIE_CLICK, ModeButton_Click )
}

function OnOpenModesMenu()
{
    ClientCommand( "loadPlaylists" )

	local modesArray = []
	modesArray.resize( getconsttable().ePrivateMatchModes.len() )
	foreach ( k, v in getconsttable().ePrivateMatchModes )
	{
		modesArray[v] = k
	}

	local menu = GetMenu( "ModesMenu" )
	local buttons = GetElementsByClassname( GetMenu( "ModesMenu" ), "ModeButton" )
    
	foreach ( button in buttons )
	{
		local buttonID = button.GetScriptID().tointeger()

		if ( buttonID >= 0 && buttonID < modesArray.len() )
		{
			button.SetText( GetGameModeDisplayName( modesArray[buttonID] ) )
			button.SetEnabled( true )
		}
		else
		{
            if( buttonID == getconsttable().ePrivateMatchModes.len() )
            {
                button.SetText( "#PL_campaign")
                button.SetEnabled( true )
            } else
            {
			    button.SetText( "" )
			    button.SetEnabled( false )
            }
		}

		if ( buttonID == level.ui.privatematch_mode )
		{
			button.SetFocused()
		}
	}
}

function OnCloseModesMenu()
{
}

function ModeButton_GetFocus( button )
{
	local mapID = button.GetScriptID().tointeger()

	local menu = GetMenu( "ModesMenu" )
	local nextModeImage = menu.GetChild( "NextModeImage" )
	local nextModeName = menu.GetChild( "NextModeName" )
	local nextModeDesc = menu.GetChild( "NextModeDesc" )

    if( mapID == getconsttable().ePrivateMatchModes.len() )
    {
        nextModeImage.SetImage( "../ui/menu/playlist/campaign" )
        nextModeName.SetText( "#PL_campaign" )
        nextModeDesc.SetText( "#PL_campaign_desc" )
        return
    }

	local modesArray = []
	modesArray.resize( getconsttable().ePrivateMatchModes.len() )
	foreach ( k, v in getconsttable().ePrivateMatchModes )
	{
		modesArray[v] = k
	}

	if ( mapID > modesArray.len() )
		return

	local modeName = modesArray[mapID]

	nextModeImage.SetImage( GetGameModeDisplayImage( modeName ) )
	nextModeName.SetText( GetGameModeDisplayName( modeName ) )
	nextModeDesc.SetText( GetGameModeDisplayDesc( modeName ) )
}

function GotoCampaignLobby()
{
    ClientCommand( "launchplaylist campaign_carousel; map mp_lobby" )
    CloseDialog()
}

function ModeButton_Click( button )
{
	local mapID = button.GetScriptID().tointeger()

    if( mapID == getconsttable().ePrivateMatchModes.len() )
    {
		local buttonData = []
		buttonData.append( { name = "#YES", func = GotoCampaignLobby } )
		buttonData.append( { name = "#CANCEL", func = null } )

        local dialogData = {}
        dialogData.header <- "Create Campaign Lobby?"
        dialogData.detailsMessage <- "You will leave the current Private Match."
        dialogData.buttonData <- buttonData

        OpenChoiceDialog( dialogData )
        return
    }

	local menu = GetMenu( "MapsMenu" )

	local modesArray = []
	modesArray.resize( getconsttable().ePrivateMatchModes.len() )
	foreach ( k, v in getconsttable().ePrivateMatchModes )
	{
		modesArray[v] = k
	}
	local modeName = modesArray[mapID]

	// set it
	ClientCommand( "PrivateMatchSetMode " + modeName )
	CloseTopMenu()
}


function InitMatchSettingsMenu( menu )
{
	file.scoreLimitButton = menu.GetChild( "BtnScoreLimit" )
		file.scoreLimitLabel = menu.GetChild( "LblScoreLimitMax" )
	file.timeLimitButton = menu.GetChild( "BtnTimeLimit" )
		file.timeLimitLabel = menu.GetChild( "LblTimeLimitMax" )
	file.burnCardSetButton = menu.GetChild( "BtnBurnCardSettings" )

	file.pilotHealthButton = menu.GetChild( "BtnPilotHealth" )
	file.pilotAmmoButton = menu.GetChild( "BtnPilotAmmo" )
	file.minimapButton = menu.GetChild( "BtnPilotMinimap" )
	file.pilotRespawnDelayButton = menu.GetChild( "BtnPilotRespawnDelay" )
		file.pilotRespawnDelayLabel = menu.GetChild( "LblPilotRespawnDelayMax" )

	file.titanBuildButton = menu.GetChild( "BtnTitanInitialBuild" )
		file.titanBuildLabel = menu.GetChild( "LblTitanInitialBuildMax" )
	file.titanRebuildButton = menu.GetChild( "BtnTitanRebuild" )
		file.titanRebuildLabel = menu.GetChild( "LblTitanRebuildMax" )
	file.titanShieldCapacityButton = menu.GetChild( "BtnTitanShieldCapacity" )

	file.aiTypeButton = menu.GetChild( "BtnAIType" )
	file.aiLethalityButton = menu.GetChild( "BtnAILethality" )

	file.gameModeLabel = menu.GetChild( "LblSubheader1Text" )

	file.matchSettingDescLabel = menu.GetChild( "LblMenuItemDescription" )

	AddDescFocusHandler( file.scoreLimitButton, "#PM_DESC_SCORE_LIMIT" )
	AddDescFocusHandler( file.timeLimitButton, "#PM_DESC_TIME_LIMIT" )
	AddDescFocusHandler( file.pilotHealthButton, "#PM_DESC_PILOT_HEALTH" )
	AddDescFocusHandler( file.pilotAmmoButton, "#PM_DESC_PILOT_AMMO" )
	AddDescFocusHandler( file.minimapButton, "#PM_DESC_PILOT_MINIMAP" )
	AddDescFocusHandler( file.pilotRespawnDelayButton, "#PM_DESC_PILOT_RESPAWN_DELAY" )
	AddDescFocusHandler( file.titanBuildButton, "#PM_DESC_TITAN_BUILD" )
	AddDescFocusHandler( file.titanRebuildButton, "#PM_DESC_TITAN_REBUILD" )
	AddDescFocusHandler( file.titanShieldCapacityButton, "#PM_DESC_TITAN_SHIELD_CAPACITY" )
	AddDescFocusHandler( file.aiTypeButton, "#PM_DESC_AI_TYPE" )
	AddDescFocusHandler( file.aiLethalityButton, "#PM_DESC_AI_LETHALITY" )
	AddDescFocusHandler( file.burnCardSetButton, "#PM_DESC_BURN_CARDS" )

	uiGlobal.matchSettingsChanged <- false
}


function OnOpenMatchSettingsMenu()
{
	local menu = GetMenu( "MatchSettingsMenu" )

	local modeName = GetModeNameForEnum( level.ui.privatematch_mode )
	file.modeSettingsName = modeName

	file.gameModeLabel.SetText( GAMETYPE_TEXT[ modeName ] )

	uiGlobal.matchSettingsChanged = false

	UpdateGametypeConVarsFromPlaylist()

	UpdateMappedConVarFromPlaylist( "pm_pilot_health" )
	UpdateMappedConVarFromPlaylist( "pm_pilot_ammo" )
	UpdateMappedConVarFromPlaylist( "pm_pilot_minimap" )
	UpdateFloatConVarFromPlaylist( "pm_pilot_respawn_delay" )

	UpdateSecondsConVarFromPlaylist( "pm_titan_build" )
	UpdateSecondsConVarFromPlaylist( "pm_titan_rebuild" )
	UpdateMappedConVarFromPlaylist( "pm_titan_shields" )

	UpdateMappedConVarFromPlaylist( "pm_ai_type" )
	UpdateMappedConVarFromPlaylist( "pm_ai_lethality" )
	UpdateMappedConVarFromPlaylist( "pm_burn_cards" )

	thread UpdateMatchSettingsSliderValues( menu )

	RegisterButtonPressedCallback( BUTTON_X, ApplyMatchSettings )
	RegisterButtonPressedCallback( BUTTON_Y, ResetMatchSettingsToDefaultDialog )

	file.scoreLimitButton.SetFocused()
}


function OnCloseMatchSettingsMenu()
{
	Signal( uiGlobal.signalDummy, "OnCloseMatchSettingsMenu" )

	DeregisterButtonPressedCallback( BUTTON_X, ApplyMatchSettings )
	DeregisterButtonPressedCallback( BUTTON_Y, ResetMatchSettingsToDefaultDialog )
}



function ConVarValueChanged( conVarName )
{
	if ( file.pmVarValues[conVarName] != GetConVarFloat( conVarName ) )
		printt( conVarName, file.pmVarValues[conVarName], GetConVarFloat( conVarName ) )
	return RoundToNearestMultiplier( file.pmVarValues[conVarName], 0.05 ) != RoundToNearestMultiplier( GetConVarFloat( conVarName ), 0.05 )
	//file.pmVarValues[conVarName] != GetConVarFloat( conVarName )
}


function UpdateGametypeConVarsFromPlaylist( useBase = false )
{
	local playlistScoreLimitName
	local playlistTimeLimitName

	if ( file.modeSettingsName == "lts" )
	{
		playlistScoreLimitName = "lts_roundscorelimit"
		playlistTimeLimitName = "lts_roundtimelimit"
	}
	else
	{
		playlistScoreLimitName = file.modeSettingsName + "_scorelimit"
		playlistTimeLimitName = file.modeSettingsName + "_timelimit"
	}

	local playlistScoreLimitValue = GetCurrentPlaylistVarInt( playlistScoreLimitName, 0 )
	local playlistTimeLimitValue = GetCurrentPlaylistVarInt( playlistTimeLimitName, 0 )

	if ( useBase )
	{
		playlistScoreLimitValue = GetCurrentPlaylistVarOrUseValueOriginal( playlistScoreLimitName, "" + 0 ).tointeger()
		playlistTimeLimitValue = GetCurrentPlaylistVarOrUseValueOriginal( playlistTimeLimitName, "" + 0 ).tointeger()
	}

	local pmSetting = 0 // zero equals default
	foreach ( index, value in pmSettingsMap["pm_score_limit"][file.modeSettingsName] )
	{
		if ( value != playlistScoreLimitValue )
			continue

		printt( "found match for:", file.modeSettingsName, value, playlistScoreLimitValue )
		pmSetting = index
		break
	}

	ClientCommand( "pm_score_limit " + pmSetting )
	file.pmVarValues["pm_score_limit"] <- pmSetting.tofloat()

	ClientCommand( "pm_time_limit " + playlistTimeLimitValue )
	file.pmVarValues["pm_time_limit"] <- playlistTimeLimitValue.tofloat()
}


function UpdatePlaylistFromConVar( conVarName )
{
	local conVarValue = GetConVarString( conVarName )

	ClientCommand( "UpdatePrivateMatchSetting " + file.modeSettingsName + " " + conVarName + " " + conVarValue )
	printt( "UpdatePrivateMatchSetting " + file.modeSettingsName + " " + conVarName + " " + conVarValue )
	file.pmVarValues[conVarName] <- conVarValue.tofloat()
}


function UpdateSecondsConVarFromPlaylist( conVarName, useBase = false  )
{
	local playlistVarName = playlistVarMap[conVarName]
	local playlistVarValue = GetCurrentPlaylistVarInt( playlistVarName, 0 )

	if ( useBase )
		playlistVarValue = GetCurrentPlaylistVarOrUseValueOriginal( playlistVarName, "" + 0 ).tointeger()

	if ( conVarName == "pm_titan_build" && playlistVarValue < 30 )
		playlistVarValue = 0
	else if ( conVarName == "pm_titan_rebuild" && playlistVarValue == 0 )
		playlistVarValue = 400
	else if ( conVarName == "pm_titan_rebuild" && playlistVarValue < 30 )
		playlistVarValue = 0

	printt( "ClientCommand", (playlistVarValue / 60.0) )
	ClientCommand( conVarName + " " + (playlistVarValue / 60.0) )
	file.pmVarValues[conVarName] <- (playlistVarValue / 60.0).tofloat()
}


function UpdateFloatConVarFromPlaylist( conVarName, useBase = false  )
{
	local playlistVarName = playlistVarMap[conVarName]
	local playlistVarValue = GetCurrentPlaylistVarOrUseValue( playlistVarName, "3.0" ).tofloat()

	if ( useBase )
		playlistVarValue = GetCurrentPlaylistVarOrUseValueOriginal( playlistVarName, "3.0" ).tofloat()

	ClientCommand( conVarName + " " + playlistVarValue )
	file.pmVarValues[conVarName] <- playlistVarValue
}


function UpdateMappedConVarFromPlaylist( conVarName, useBase = false  )
{
	local playlistVarName = playlistVarMap[conVarName]
	local playlistVarValue = GetCurrentPlaylistVarInt( playlistVarName, "" + 0 )

	if ( useBase )
		playlistVarValue = GetCurrentPlaylistVarOrUseValueOriginal( playlistVarName, "" + 0 ).tointeger()

	local pmSetting = 0 // zero equals default
	foreach ( index, value in pmSettingsMap[conVarName] )
	{
		if ( value != playlistVarValue )
			continue

		printt( "found match for:", file.modeSettingsName, value, playlistVarValue )

		pmSetting = index
		break
	}

	ClientCommand( conVarName + " " + pmSetting )
	file.pmVarValues[conVarName] <- pmSetting.tofloat()
}


function UpdateMatchSettingsSliderValues( menu )
{
	EndSignal( uiGlobal.signalDummy, "OnCloseMatchSettingsMenu" )

	local modeName = GetModeNameForEnum( level.ui.privatematch_mode )

	while ( true )
	{
		SetScoreLimitText( file.scoreLimitLabel, GetScoreLimitFromConVar() )
		SetTimeLimitText( file.timeLimitLabel, GetTimeLimitFromConVar() )
		SetPilotRespawnDelay( file.pilotRespawnDelayLabel, GetPilotRespawnDelayFromConVar() )
		SetTitanBuildTimeText( file.titanBuildLabel, GetTitanBuildFromConVar() )
		SetTitanRebuildTimeText( file.titanRebuildLabel, GetTitanRebuildFromConVar() )

		wait 0
	}
}


function GetScoreLimitFromConVar()
{
	local conVarVal = GetConVarInt( "pm_score_limit" )
	conVarVal = clamp( conVarVal, 0, pmSettingsMap["pm_score_limit"][file.modeSettingsName].len() - 1 )

	return pmSettingsMap["pm_score_limit"][file.modeSettingsName][conVarVal]
}


function GetTimeLimitFromConVar()
{
	local conVarVal = GetConVarInt( "pm_time_limit" )
	conVarVal = RoundToNearestMultiplier( conVarVal, 1.0 )

	return conVarVal
}


function GetPilotRespawnDelayFromConVar()
{
	local conVarVal = GetConVarFloat( "pm_pilot_respawn_delay" )
	conVarVal = RoundToNearestMultiplier( conVarVal, 0.5 )

	return conVarVal
}


function GetTitanBuildFromConVar()
{
	local conVarVal = GetConVarFloat( "pm_titan_build" )
	conVarVal = RoundToNearestMultiplier( conVarVal, 0.5 )

	return conVarVal * 60
}


function GetTitanRebuildFromConVar()
{
	local conVarVal = GetConVarFloat( "pm_titan_rebuild" )
	conVarVal = RoundToNearestMultiplier( conVarVal, 0.5 )

	return conVarVal * 60
}


function SetTitanBuildTimeText( textElem, titanBuildTime )
{
	if ( titanBuildTime < 1 )
	{
		textElem.SetText( "#SETTING_INSTANT" )
	}
	else if ( titanBuildTime / 60 == 1 )
	{
		textElem.SetText( "#N_MINUTE", format( "%2.1f", titanBuildTime / 60.0 ) )
	}
	else
	{
		textElem.SetText( "#N_MINUTES", format( "%2.1f", titanBuildTime / 60.0 ) )
	}
}


function SetTitanRebuildTimeText( textElem, titanBuildTime )
{
	if ( titanBuildTime < 1 )
	{
		textElem.SetText( "#SETTING_INSTANT" )
	}
	else if ( titanBuildTime / 60 == 1 )
	{
		textElem.SetText( "#N_MINUTE", format( "%2.1f", titanBuildTime / 60.0 ) )
	}
	else if ( titanBuildTime > 300 )
	{
		textElem.SetText( "#SETTING_DISABLED" )
	}
	else
	{
		textElem.SetText( "#N_MINUTES", format( "%2.1f", titanBuildTime / 60.0 ) )
	}
}


function SetScoreLimitText( textElem, scoreLimit )
{
	if ( file.modeSettingsName == "lts" )
		textElem.SetText( "#N_ROUND_WINS", scoreLimit )
	else
		textElem.SetText( "#N_POINTS", scoreLimit )
}


function SetTimeLimitText( textElem, timeLimit )
{
	textElem.SetText( "#N_MINUTES", format( "%2.1f", timeLimit ) )
}


function SetPilotRespawnDelay( textElem, respawnDelay )
{
	textElem.SetText( "#N_SECONDS", format( "%2.1f", respawnDelay ) )
}


function NavigateBackApplyMatchSettingsDialog()
{
	if ( uiGlobal.activeDialog )
		return false

	if ( ConVarValueChanged( "pm_time_limit" ) )
		uiGlobal.matchSettingsChanged = true
	else if ( ConVarValueChanged( "pm_score_limit" ) )
		uiGlobal.matchSettingsChanged = true
	else if ( ConVarValueChanged( "pm_pilot_health" ) )
		uiGlobal.matchSettingsChanged = true
	else if ( ConVarValueChanged( "pm_pilot_ammo" ) )
		uiGlobal.matchSettingsChanged = true
	else if ( ConVarValueChanged( "pm_pilot_minimap" ) )
		uiGlobal.matchSettingsChanged = true
	else if ( ConVarValueChanged( "pm_pilot_respawn_delay" ) )
		uiGlobal.matchSettingsChanged = true
	else if ( ConVarValueChanged( "pm_titan_build" ) )
		uiGlobal.matchSettingsChanged = true
	else if ( ConVarValueChanged( "pm_titan_rebuild" ) )
		uiGlobal.matchSettingsChanged = true
	else if ( ConVarValueChanged( "pm_titan_shields" ) )
		uiGlobal.matchSettingsChanged = true
	else if ( ConVarValueChanged( "pm_ai_type" ) )
		uiGlobal.matchSettingsChanged = true
	else if ( ConVarValueChanged( "pm_ai_lethality" ) )
		uiGlobal.matchSettingsChanged = true
	else if ( ConVarValueChanged( "pm_burn_cards" ) )
		uiGlobal.matchSettingsChanged = true

	if ( !uiGlobal.matchSettingsChanged )
		return false

	local buttonData = []
	buttonData.append( { name = "#APPLY", func = Bind( DialogChoice_ApplyMatchSettings ) } )
	buttonData.append( { name = "#DISCARD", func = CloseTopMenu } )

	local footerData = []
	footerData.append( { label = "#A_BUTTON_SELECT" } )
	footerData.append( { label = "#B_BUTTON_DISCARD", func = null } )

	local dialogData = {}
	dialogData.header <- "#APPLY_CHANGES"
	dialogData.buttonData <- buttonData
	dialogData.footerData <- footerData

	OpenChoiceDialog( dialogData )

	return true
}


function DialogChoice_ApplyMatchSettings()
{
	ApplyMatchSettings( null )
	CloseTopMenu()
}
Globalize( DialogChoice_ApplyMatchSettings )


function AddDescFocusHandler( button, descText )
{
	button.s.descText <- descText
	button.AddEventHandler( UIE_GET_FOCUS, Bind( MatchSettingsFocusUpdate ) )
	if ( !button.HasChild( "BtnDropButton" ) )
		return

	local child = button.GetChild( "BtnDropButton" )
	child.s.descText <- descText
	child.AddEventHandler( UIE_GET_FOCUS, Bind( MatchSettingsFocusUpdate ) )

	local child = button.GetChild( "PnlDefaultMark" )
	child.SetColor( [0,0,0,0] )
	child.Hide()
}


function MatchSettingsFocusUpdate( button )
{
	file.matchSettingDescLabel.SetText( button.s.descText )
}


function ApplyMatchSettings( button )
{
	ClientCommand( "ResetMatchSettingsToDefault" )

	UpdatePlaylistFromConVar( "pm_time_limit" )
	UpdatePlaylistFromConVar( "pm_score_limit" )

	UpdatePlaylistFromConVar( "pm_pilot_health" )
	UpdatePlaylistFromConVar( "pm_pilot_ammo" )
	UpdatePlaylistFromConVar( "pm_pilot_minimap" )
	UpdatePlaylistFromConVar( "pm_pilot_respawn_delay" )

	UpdatePlaylistFromConVar( "pm_titan_build" )
	UpdatePlaylistFromConVar( "pm_titan_rebuild" )
	UpdatePlaylistFromConVar( "pm_titan_shields" )

	UpdatePlaylistFromConVar( "pm_ai_type" )
	UpdatePlaylistFromConVar( "pm_ai_lethality" )
	UpdatePlaylistFromConVar( "pm_burn_cards" )

	uiGlobal.matchSettingsChanged = false
}
Globalize( ApplyMatchSettings )

function ResetMatchSettingsToDefaultDialog( button )
{
	UpdateGametypeConVarsFromPlaylist( true )

	UpdateMappedConVarFromPlaylist( "pm_pilot_health", true )
	UpdateMappedConVarFromPlaylist( "pm_pilot_ammo", true )
	UpdateMappedConVarFromPlaylist( "pm_pilot_minimap", true )
	UpdateFloatConVarFromPlaylist( "pm_pilot_respawn_delay", true )

	UpdateSecondsConVarFromPlaylist( "pm_titan_build", true )
	UpdateSecondsConVarFromPlaylist( "pm_titan_rebuild", true )
	UpdateMappedConVarFromPlaylist( "pm_titan_shields", true )

	UpdateMappedConVarFromPlaylist( "pm_ai_type", true )
	UpdateMappedConVarFromPlaylist( "pm_ai_lethality", true )
	UpdateMappedConVarFromPlaylist( "pm_burn_cards", true )

	ClientCommand( "ResetMatchSettingsToDefault" )
}
Globalize( ResetMatchSettingsToDefaultDialog )


function OnSettingsButton_GetFocus( button )
{
	local menu = GetMenu( "MatchSettingsMenu" )
	HandleLockedCustomMenuItem( menu, button, ["#PRIVATE_MATCH_COMING_SOON"] )
}

function OnSettingsButton_LoseFocus( button )
{
	local menu = GetMenu( "MatchSettingsMenu" )
	HandleLockedCustomMenuItem( menu, button, [], true )
}
