
function main()
{
	PrecacheHUDMaterial( "../ui/menu/campaign_menu/map_button_mp_fracture" )
	PrecacheHUDMaterial( "../ui/menu/campaign_menu/map_button_mp_colony" )
	PrecacheHUDMaterial( "../ui/menu/campaign_menu/map_button_mp_relic" )
	PrecacheHUDMaterial( "../ui/menu/campaign_menu/map_button_mp_angel_city" )
	PrecacheHUDMaterial( "../ui/menu/campaign_menu/map_button_mp_outpost_207" )
	PrecacheHUDMaterial( "../ui/menu/campaign_menu/map_button_mp_boneyard" )
	PrecacheHUDMaterial( "../ui/menu/campaign_menu/map_button_mp_airbase" )
	PrecacheHUDMaterial( "../ui/menu/campaign_menu/map_button_mp_o2" )
	PrecacheHUDMaterial( "../ui/menu/campaign_menu/map_button_mp_corporate" )

	Globalize( InitCampaignMenu )
	Globalize( PlayCampaignButton_Activate )
	Globalize( OnOpenCampaignMenu )
	Globalize( OnCloseCampaignMenu )
	Globalize( GetCampaignTeam )
	Globalize( SetCampaignTeam )
	Globalize( GetCampaignStarted )
	Globalize( SetCampaignStarted )
	Globalize( StartCampaignMatchmaking )
	Globalize( UpdateCampaignMenuFooter )
}

function InitCampaignMenu( menu )
{
	menu.GetChild( "AutoAssignButton" ).SetParentMenu( menu )
	menu.GetChild( "FocusDescription" ).SetParentMenu( menu )

	AddEventHandlerToButton( menu, "AutoAssignButton", UIE_CLICK, Bind( OnAutoAssignButton_Activate ) )
	AddEventHandlerToButton( menu, "AutoAssignButton", UIE_GET_FOCUS, Bind( OnAutoAssignButton_Focus ) )
	AddEventHandlerToButton( menu, "AutoAssignButton", UIE_LOSE_FOCUS, Bind( OnButton_LoseFocus ) )

	AddEventHandlerToButtonClass( menu, "MapButtonClass", UIE_CLICK, Bind( OnMapButton_Activate ) )
	AddEventHandlerToButtonClass( menu, "MapButtonClass", UIE_GET_FOCUS, Bind( OnMapButton_Focus ) )

	AddEventHandlerToButtonClass( menu, "CampaignCheatButton", UIE_CLICK, Bind( OnCheatButton_Click ) )

	if ( !developer() )
	{
		local cheatButtons = GetElementsByClassname( menu, "CampaignCheatButton" )
		foreach( button in cheatButtons )
			button.Hide()
	}

	file.campaignTeam <- null
	file.campaignLevelCount <- null
	file.campaign <- {}
	file.registeredCallbacks <- false

	local teams = [ TEAM_IMC, TEAM_MILITIA ]
	foreach ( team in teams )
	{
		file.campaign[ team ] <- {}
		file.campaign[ team ].highestAllowedMap <- null
		file.campaign[ team ].nextMapIndex <- null
	}
}

function DetermineCampaignState()
{
	local campaignMapFinished = {}
	local teams = [TEAM_IMC, TEAM_MILITIA]

	foreach ( team in teams )
	{
		campaignMapFinished[team] <- {}
		file.campaign[team].highestAllowedMap = file.campaignLevelCount
	}

	file.campaign[TEAM_IMC].nextMapIndex = GetPersistentVar( "desiredCampaignMapIndex[0]" )
	file.campaign[TEAM_MILITIA].nextMapIndex = GetPersistentVar( "desiredCampaignMapIndex[1]" )

	// We loop backwards to easily find the earliest level they haven't completed.
	for ( local i = file.campaignLevelCount - 1; i >= 0; i-- )
	{
		campaignMapFinished[TEAM_IMC] = GetPersistentVar( "campaignMapFinishedIMC[" + i + "]" )
		campaignMapFinished[TEAM_MILITIA] = GetPersistentVar( "campaignMapFinishedMCOR[" + i + "]" )

		// Set next map for each team
		foreach ( team in teams )
		{
			if ( !campaignMapFinished[team] )
			{
				file.campaign[team].highestAllowedMap = i
				//if ( i < file.campaign[team].nextMapIndex || file.campaign[team].nextMapIndex == 0 )
					file.campaign[team].nextMapIndex = i
			}
		}
	}

	file.campaignTeam = GetCampaignTeam()
	//printt( "CampaignTeam before update:", file.campaignTeam )

	if ( file.campaignTeam == TEAM_UNASSIGNED )
	{
		SetCampaignTeam( Random( [ TEAM_IMC, TEAM_MILITIA ] ) )
		//printt( "CampaignTeam after random assignment:", file.campaignTeam )
	}
	else if ( file.campaignTeam != TEAM_ANY )
	{
		local enemyTeam = GetEnemyTeam( file.campaignTeam )

		if ( FinishedCampaignTeam( file.campaignTeam ) )
		{
			if ( !FinishedCampaignTeam( enemyTeam ) )
				SetCampaignTeam( enemyTeam )
			else
				SetCampaignTeam( TEAM_ANY )

			//printt( "CampaignTeam after existing team update:", file.campaignTeam )
		}
	}
	else
	{
		if ( !FinishedCampaignTeam( TEAM_IMC ) )
			SetCampaignTeam( TEAM_IMC )
		else if ( !FinishedCampaignTeam( TEAM_MILITIA ) )
			SetCampaignTeam( TEAM_MILITIA )
	}
}

function PlayCampaignButton_Activate( button )
{
	file.campaignLevelCount = GetMapCountForPlaylist( "Campaign" )

	DetermineCampaignState()

	// Skip menu if you've never completed map 0
	if ( GetNextMapIndex() == 0 && !FinishedCampaignTeam( GetEnemyTeam( file.campaignTeam ) ) && (!developer() || !InputIsButtonDown( BUTTON_TRIGGER_LEFT )) )
		StartCampaignMatchmaking( 0, 0, 0, file.campaignTeam )
	else
		AdvanceMenu( GetMenu( "CampaignMenu" ) )
}

function OnOpenCampaignMenu( menu )
{
	Assert( !AreWeMatchmaking() )

	local autoAssignButton = menu.GetChild( "AutoAssignButton" )
	local mapButtons = GetElementsByClassname( menu, "MapButtonClass" )
	local combinedHighestAllowed = GetCombinedHighestAllowed()
	local completedLevel = {}
	completedLevel[ TEAM_IMC ] <- []
	completedLevel[ TEAM_MILITIA ] <- []
	local wonLevel = {}
	wonLevel[ TEAM_IMC ] <- []
	wonLevel[ TEAM_MILITIA ] <- []

	foreach ( button in mapButtons )
	{
		local index = button.GetScriptID().tointeger()
		local mapName = button.GetChild( "MapName" )
		local mapImage = button.GetChild( "MapImage" )
		local darkenOverlay = button.GetChild( "DarkenOverlay" )
		local finishedIMCImage = button.GetChild( "FinishedIMCImage" )
		local finishedMilitiaImage = button.GetChild( "FinishedMilitiaImage" )
		local wonIMCImage = button.GetChild( "WonIMCImage" )
		local wonMilitiaImage = button.GetChild( "WonMilitiaImage" )

		mapName.SetText( GetMapDisplayName( index ) )
		mapImage.SetImage( "../ui/menu/campaign_menu/map_button_" + GetPlaylistMapByIndex( "Campaign", index ) )

		if ( index > combinedHighestAllowed )
			darkenOverlay.Show()
		else
			darkenOverlay.Hide()

		completedLevel[ TEAM_IMC ].append( GetPersistentVar( "campaignMapFinishedIMC[" + index + "]" ) )
		completedLevel[ TEAM_MILITIA ].append( GetPersistentVar( "campaignMapFinishedMCOR[" + index + "]" ) )

		finishedIMCImage.SetVisible( completedLevel[ TEAM_IMC ][index] )
		finishedMilitiaImage.SetVisible( completedLevel[ TEAM_MILITIA ][index] )

		wonLevel[ TEAM_IMC ].append( GetPersistentVar( "campaignMapWonIMC[" + index + "]" ) )
		wonLevel[ TEAM_MILITIA ].append( GetPersistentVar( "campaignMapWonMCOR[" + index + "]" ) )

		wonIMCImage.SetVisible( wonLevel[ TEAM_IMC ][index] )
		wonMilitiaImage.SetVisible( wonLevel[ TEAM_MILITIA ][index] )
	}

	local myTeamLogo = menu.GetChild( "MyTeamLogo" )
	local myTeamName = menu.GetChild( "MyTeamName" )

	printt( "file.campaignTeam:", file.campaignTeam )
	if ( file.campaignTeam == TEAM_ANY )
	{
		autoAssignButton.SetText( "#QUICK_PLAY" )

		foreach ( button in mapButtons )
		{
			local mapNameBG = button.GetChild( "MapNameBG" )
			mapNameBG.SetVisible( true )
			mapNameBG.Hide()

			local mapName = button.GetChild( "MapName" )
			mapName.SetVisible( true )
			mapName.Hide()

			button.SetEnabled( true )
		}

		myTeamLogo.Hide()
		myTeamName.Hide()
	}
	else
	{
		Assert( file.campaignTeam == TEAM_IMC || file.campaignTeam == TEAM_MILITIA )

		if ( GetCampaignStarted() )
			autoAssignButton.SetText( "#RESUME_CAMPAIGN" )
		else
			autoAssignButton.SetText( "#START_CAMPAIGN" )

		foreach ( button in mapButtons )
		{
			local index = button.GetScriptID().tointeger()
			if ( completedLevel[ TEAM_IMC ][index] || completedLevel[ TEAM_MILITIA ][index] || index == GetNextMapIndex() )
				button.SetEnabled( true )
			else
				button.SetEnabled( false )
		}

		myTeamLogo.SetImage( GetTeamImage( file.campaignTeam ) )
		myTeamLogo.Show()

		myTeamName.SetText( GetTeamName( file.campaignTeam ) )
		myTeamName.Show()
	}

	if ( developer() && !file.registeredCallbacks )
	{
		RegisterButtonPressedCallback( BUTTON_X, OnCampaignPressX )
		RegisterButtonPressedCallback( BUTTON_STICK_LEFT, OnCampaignPressLS )
		RegisterButtonPressedCallback( BUTTON_SHOULDER_LEFT, OnCampaignPressLB )
		RegisterButtonPressedCallback( BUTTON_SHOULDER_RIGHT, OnCampaignPressRB )
		file.registeredCallbacks = true
	}
}

function OnCloseCampaignMenu()
{
	if ( file.registeredCallbacks )
	{
		DeregisterButtonPressedCallback( BUTTON_X, OnCampaignPressX )
		DeregisterButtonPressedCallback( BUTTON_STICK_LEFT, OnCampaignPressLS )
		DeregisterButtonPressedCallback( BUTTON_SHOULDER_LEFT, OnCampaignPressLB )
		DeregisterButtonPressedCallback( BUTTON_SHOULDER_RIGHT, OnCampaignPressRB )
		file.registeredCallbacks = false
	}
}

function OnAutoAssignButton_Focus( button )
{
	local menu = button.GetParentMenu()

	if ( file.campaignTeam == TEAM_ANY )
	{
		menu.GetChild( "FocusDescription" ).SetText( "#JOIN_ANY_CAMPAIGN_MATCH" )
	}
	else
	{
		if ( GetCampaignStarted() )
			menu.GetChild( "FocusDescription" ).SetText( "#CONTINUE_WHERE_YOU_LAST" )
		else
			menu.GetChild( "FocusDescription" ).SetText( "#START_AT_THE_BEGINNING" )
	}

	UpdateCampaignMenuFooter()
}

function OnAutoAssignButton_Activate( button )
{
	local menu = button.GetParentMenu()
	local mapIndex = GetNextMapIndex()

	StartCampaignMatchmaking( mapIndex, file.campaign[ TEAM_IMC ].highestAllowedMap, file.campaign[ TEAM_MILITIA ].highestAllowedMap, file.campaignTeam )
	//printt( "StartCampaignMatchmaking(", mapIndex, file.campaign[ TEAM_IMC ].highestAllowedMap, file.campaign[ TEAM_MILITIA ].highestAllowedMap, file.campaignTeam, ")" )

	CloseTopMenu()
}

function OnMapButton_Focus( button )
{
	local menu = button.GetParentMenu()
	local focusDescription = menu.GetChild( "FocusDescription" )
	local index = button.GetScriptID().tointeger()

	if ( FinishedCampaignTeam( TEAM_IMC ) && FinishedCampaignTeam( TEAM_MILITIA ) )
		focusDescription.SetText( "#REPLAY_A_SPECIFIC_MISSION" )
	else
		focusDescription.SetText( GetMapDescription( index ) )

	UpdateCampaignMenuFooter()
}

function UpdateCampaignMenuFooter()
{
	local footerData = {}
	footerData.gamepad <- []
	footerData.pc <- []

	if ( uiGlobal.playerListFocused )
	{
		if ( Durango_IsDurango() )
			footerData.gamepad.append( { label = "#A_BUTTON_GAMERCARD" } )
		else
			footerData.gamepad.append( { label = "#A_BUTTON_PLAYER_PROFILE" } )
	}
	else if ( FinishedCampaignTeam( TEAM_IMC ) && FinishedCampaignTeam( TEAM_MILITIA ) )
	{
		footerData.gamepad.append( { label = "#A_BUTTON_SELECT" } )
	}

	footerData.gamepad.append( { label = "#B_BUTTON_BACK" } )
	footerData.pc.append( { label = "#BACK", func = PCBackButton_Activate } )

	footerData.pc = AppendPCInviteLabels( footerData.pc )

	if ( uiGlobal.playerListFocused )
	{
		footerData.gamepad.append( { label = "#X_BUTTON_MUTE" } )
		footerData.pc.append( { label = "#MOUSE1_MUTE" } )

		footerData.pc.append( { label = "#MOUSE2_VIEW_PLAYER_PROFILE" } )
	}

	footerData.gamepad = AppendGamepadInviteLabels( footerData.gamepad )

	UpdateFooters( footerData )
}

function OnMapButton_Activate( button )
{
	local mapIndex = button.GetScriptID().tointeger()

	if ( FinishedCampaignTeam( TEAM_IMC ) && FinishedCampaignTeam( TEAM_MILITIA ) )
	{
		StartCampaignMatchmaking( mapIndex, file.campaign[ TEAM_IMC ].highestAllowedMap, file.campaign[ TEAM_MILITIA ].highestAllowedMap, TEAM_ANY )
		//printt( "StartCampaignMatchmaking(", mapIndex, file.campaign[ TEAM_IMC ].highestAllowedMap, file.campaign[ TEAM_MILITIA ].highestAllowedMap, TEAM_ANY, ")" )

		CloseTopMenu()
	}
}

function OnButton_LoseFocus( button )
{
	local menu = button.GetParentMenu()

	menu.GetChild( "FocusDescription" ).SetText( "" )
}

function StartCampaignMatchmaking( levelIndex, maxLevelIndexIMC, maxLevelIndexMilitia, team )
{
	Assert( AmIPartyLeader() )
	Assert( !AreWeMatchmaking() )

	ClientCommand( "match_playlist Campaign" )
	ClientCommand( "match_myhashtag \"\"" )
	SetCampaignStarted( true )
	SetCampaignMatchmakingSettings( levelIndex, maxLevelIndexIMC, maxLevelIndexMilitia, team )
	StartMatchmaking()
}

function GetCampaignTeam()
{
	return GetPersistentVarAsInt( "campaignTeam" )
}

function SetCampaignTeam( team )
{
	file.campaignTeam = team
	ClientCommand( "SetCampaignTeam " + team )
}

function FinishedCampaignTeam( team )
{
	Assert( team == TEAM_IMC || team == TEAM_MILITIA )

	local persistentVarName
	if ( team == TEAM_IMC )
		persistentVarName = "campaignMapFinishedIMC"
	else
		persistentVarName = "campaignMapFinishedMCOR"

	for ( local i = 0; i < file.campaignLevelCount; i++ )
	{
		local levelCompleted = GetPersistentVar( persistentVarName + "[" + i + "]" )
		//printt( "Team:", team, "levelCompleted[" + i + "]:", levelCompleted )

		if ( !levelCompleted )
			return false
	}

	return true
}

function GetCampaignStarted()
{
	return GetPersistentVarAsInt( "campaignStarted" )
}

function SetCampaignStarted( value )
{
	ClientCommand( "SetCampaignStarted " + value )
}

function GetNextMapIndex()
{
	local nextMapIndex
	if ( file.campaignTeam == TEAM_ANY )
		nextMapIndex = -1
	else
		nextMapIndex = file.campaign[ file.campaignTeam ].nextMapIndex

	return nextMapIndex
}

function GetMapDisplayName( index )
{
	local mapName = GetPlaylistMapByIndex( "Campaign", index )

	return GetCampaignMapDisplayName( mapName )
}

function GetMapDescription( index )
{
	local mapName = GetPlaylistMapByIndex( "Campaign", index )

	return "#" + mapName + "_CAMPAIGN_MENU_DESC"
}

function GetCombinedHighestAllowed()
{
	local highestAllowed = file.campaign[ TEAM_IMC ].highestAllowedMap

	if ( file.campaign[ TEAM_MILITIA ].highestAllowedMap > file.campaign[ TEAM_IMC ].highestAllowedMap )
		highestAllowed = file.campaign[ TEAM_MILITIA ].highestAllowedMap

	if ( highestAllowed >= file.campaignLevelCount )
		highestAllowed = file.campaignLevelCount - 1

	//printt( "highestAllowed:", highestAllowed )

	return highestAllowed
}


function OnCampaignPressX( player )
{
	printt( "X" )
	local focused = GetFocus()
	if ( focused && focused.GetScriptID() != "" )
	{
		printt( focused.GetScriptID() )
		ClientCommand( "CampaignCheat " + focused.GetScriptID() )
		thread UpdateCampaignMenu()
	}
}

function OnCampaignPressLS( player )
{
	ClientCommand( "CampaignCheat 9" )
	thread UpdateCampaignMenu()
}

function OnCampaignPressLB( player )
{
	ClientCommand( "CampaignCheat imc" )
	thread UpdateCampaignMenu()
}

function OnCampaignPressRB( player )
{
	ClientCommand( "CampaignCheat militia" )
	thread UpdateCampaignMenu()
}


function OnCheatButton_Click( button )
{
	ClientCommand( "CampaignCheat " + button.GetScriptID() )
	thread UpdateCampaignMenu()
}

function UpdateCampaignMenu()
{
	for ( local i = 0; i < 5; i++ )
	{
		wait 0.2
		if ( !GetMenu( "CampaignMenu" ).IsVisible() )
			break
		DetermineCampaignState()
		OnOpenCampaignMenu( GetMenu( "CampaignMenu" ) )
	}
}
