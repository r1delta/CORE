
const MAP_LIST_VISIBLE_ROWS = 17
const MAP_LIST_SCROLL_SPEED = 0

function main()
{
	Globalize( InitVoteTargetMenu )

	RegisterSignal( "OnCloseVoteTargetMenu" )
}

function InitVoteTargetMenu( menu )
{
	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnOpenVoteTargetMenu )
	AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, OnCloseVoteTargetMenu )

	AddEventHandlerToButtonClass( menu, "MapButtonClass", UIE_GET_FOCUS, Bind( MapButton_Focused ) )
	AddEventHandlerToButtonClass( menu, "MapButtonClass", UIE_LOSE_FOCUS, Bind( MapButton_LostFocus ) )
	AddEventHandlerToButtonClass( menu, "MapButtonClass", UIE_CLICK, Bind( MapButton_Activate ) )
	AddEventHandlerToButtonClass( menu, "MapListScrollUpClass", UIE_CLICK, Bind( OnMapListScrollUp_Activate ) )
	AddEventHandlerToButtonClass( menu, "MapListScrollDownClass", UIE_CLICK, Bind( OnMapListScrollDown_Activate ) )
	AddEventHandlerToButtonClass( menu, "PCFooterButtonClass", UIE_GET_FOCUS, PCFooterButtonClass_Focused )

	file.buttons <- GetElementsByClassname( menu, "MapButtonClass" )
	file.numMapButtonsOffScreen <- null
	file.mapListScrollState <- 0
}

function OnOpenVoteTargetMenu()
{
	local menu = GetMenu( "VoteTargetMenu" )

	local buttons = file.buttons
	file.options <- GetVoteOptionsArray()
	local optionsArray = file.options
	if ( !optionsArray )
		return

	file.numMapButtonsOffScreen = optionsArray.len() - MAP_LIST_VISIBLE_ROWS
	Assert( file.numMapButtonsOffScreen >= 0 )

	foreach ( button in buttons )
	{
		button.s.voteOption <- null

		local buttonID = button.GetScriptID().tointeger()

		if ( buttonID >= 0 && buttonID < optionsArray.len() )
		{
			button.SetText( GetVoteOptionText( optionsArray, buttonID ) )
			button.s.voteOption = optionsArray[buttonID]
			button.SetEnabled( true )
		}
		else
		{
			button.SetText( "" )
			button.SetEnabled( false )
		}

		if ( buttonID == 0 )
			button.SetFocused()
	}

	thread SetVotetypeAvailability( menu )

	RegisterButtonPressedCallback( MOUSE_WHEEL_UP, OnMapListScrollUp_Activate )
	RegisterButtonPressedCallback( MOUSE_WHEEL_DOWN, OnMapListScrollDown_Activate )
}

function GetVoteOptionsArray()
{
	local optionsArray = null
	if ( !IsConnected() )
		return optionsArray

	local playlist = GetCurrentPlaylistName()

	switch ( uiGlobal.selectedVote )
	{
		case eVoteType.kickPlayer:
			break

		case eVoteType.mapChange:
		case eVoteType.nextMap:
			optionsArray = GetPlaylistUniqueMaps( playlist )

			if ( playlist != CAPTURE_POINT && playlist != COOPERATIVE && playlist != CAMPAIGN )
			{
				optionsArray.append( "mp_mia" )
				optionsArray.append( "mp_nest2" )
				optionsArray.append( "mp_box" )
				optionsArray.append( "mp_npe" )
			}
			break

		case eVoteType.nextMode:
			local modesArray = []
			modesArray.resize( getconsttable().ePrivateMatchModes.len() )
			foreach ( k, v in getconsttable().ePrivateMatchModes )
			{
				modesArray[v] = k
			}
			optionsArray = modesArray //GetPlaylistUniqueModes( playlist )
			break
	}

	return optionsArray
}

function GetVoteOptionText( optionsArray, buttonID )
{
	local text = ""
	switch ( uiGlobal.selectedVote )
	{
		case eVoteType.mapChange:
		case eVoteType.nextMap:
			if ( GetCurrentPlaylistName() == CAMPAIGN )
				text = GetCampaignMapDisplayName( optionsArray[buttonID] )
			else 
				text = GetMapDisplayName( optionsArray[buttonID] )
			break
		
		case eVoteType.nextMode:
			text = GetGameModeDisplayName( optionsArray[buttonID] )
			break
	}

	return text
}

function OnCloseVoteTargetMenu()
{
	Signal( uiGlobal.signalDummy, "OnCloseVoteTargetMenu" )

	DeregisterButtonPressedCallback( MOUSE_WHEEL_UP, OnMapListScrollUp_Activate )
	DeregisterButtonPressedCallback( MOUSE_WHEEL_DOWN, OnMapListScrollDown_Activate )
}

function SetVotetypeAvailability( menu )
{
	EndSignal( uiGlobal.signalDummy, "OnCloseVoteTargetMenu" )

	local buttons = file.buttons
	while ( 1 )
	{
		foreach ( button in buttons )
		{
			local buttonID = button.GetScriptID().tointeger()

			if ( buttonID >= 0 && buttonID < file.options.len() )
			{
				if ( !CanCreateVoteOfType( uiGlobal.selectedVote, null ) )
					button.SetLocked( true )
				else
					button.SetLocked( false )
			}
		}

		wait 1.0
	}
}

function MapButton_Focused( button )
{
	local buttonID = button.GetScriptID().tointeger()

	local menu = GetMenu( "VoteTargetMenu" )
	local nextMapName = menu.GetChild( "NextMapName" )
	local nextMapDesc = menu.GetChild( "NextMapDesc" )
	local nextMapImage = menu.GetChild( "NextMapImage" )

	local nextModeImageBackground = menu.GetChild( "NextModeImageBackground" )
	local nextModeImage = menu.GetChild( "NextModeImage" )

	local optionsArray = file.options
	local option = optionsArray[buttonID]

	local optionName
	local optionDesc
	local optionImage = "../dev/empty"

	switch( uiGlobal.selectedVote )
	{
		case eVoteType.mapChange:
		case eVoteType.nextMap:
			if ( GetCurrentPlaylistName() == CAMPAIGN )
			{
				optionName = GetCampaignMapDisplayName( option )
				optionDesc = "#" + option + "_CAMPAIGN_MENU_DESC"
			}
			else
			{
				optionName = GetMapDisplayName( option )
				optionDesc = GetMapDisplayDesc( option )
			}

			if ( option == "mp_mia" || option == "mp_nest2" || option == "mp_box" || option == "mp_npe" )
				optionImage = "../loadscreens/" + option + "_widescreen"
			else
				optionImage = "../ui/menu/lobby/lobby_image_" + option
			break
		
		case eVoteType.nextMode:
			optionName = GetGameModeDisplayName( option )
			optionDesc = GetGameModeDisplayDesc( option )
			optionImage = GetGameModeDisplayImage( option )
			break
	}

	if ( uiGlobal.selectedVote == eVoteType.mapChange || uiGlobal.selectedVote == eVoteType.nextMap )
	{
		nextMapImage.SetImage( optionImage )
	

		nextModeImage.Hide()
		nextModeImageBackground.Hide()
	}
	else
	{
		nextMapImage.SetImage( "../dev/empty" )

		nextModeImage.Show()
		nextModeImage.SetImage( optionImage )
		nextModeImageBackground.Show()
	}

	nextMapName.SetText( optionName )
	nextMapDesc.SetText( optionDesc )

	// Update window scrolling if we highlight a map not in view
	local minScrollState = clamp( buttonID - (MAP_LIST_VISIBLE_ROWS - 1), 0, file.numMapButtonsOffScreen )
	local maxScrollState = clamp( buttonID, 0, file.numMapButtonsOffScreen )

	if ( file.mapListScrollState < minScrollState )
		file.mapListScrollState = minScrollState
	if ( file.mapListScrollState > maxScrollState )
		file.mapListScrollState = maxScrollState

	UpdateMapListScroll()
}

function MapButton_LostFocus( button )
{
	return

	HandleLockedCustomMenuItem( GetMenu( "VoteTargetMenu" ), button, [], true )
}

function MapButton_Activate( button )
{
	if ( button.IsLocked() )
		return

	if ( !button.s.voteOption )
		return

	if ( true )
	{
		ClientCommand( "StartVote " + uiGlobal.selectedVote + " " + button.s.voteOption )
		CloseAllInGameMenus()
	}
}

function OnMapListScrollUp_Activate(...)
{
	if ( file.options.len() <= 17 )
		return

	file.mapListScrollState--
	if ( file.mapListScrollState < 0 )
		file.mapListScrollState = 0

	UpdateMapListScroll()
}

function OnMapListScrollDown_Activate(...)
{
	if ( file.options.len() <= 17 )
		return

	file.mapListScrollState++
	if ( file.mapListScrollState > file.numMapButtonsOffScreen )
		file.mapListScrollState = file.numMapButtonsOffScreen

	UpdateMapListScroll()
}

function UpdateMapListScroll()
{
	local buttons = file.buttons
	local basePos = buttons[0].GetBasePos()
	local offset = buttons[0].GetHeight() * file.mapListScrollState

	buttons[0].SetPos( basePos[0], basePos[1] - offset )
}

function PrintVoteOptions()
{
	PrintTable( file.options )
}
Globalize( PrintVoteOptions )

function PCFooterButtonClass_Focused( button )
{
	local menu = GetMenu( "VoteTargetMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "" )
}