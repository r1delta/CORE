const CHOICE2_VISIBLE_ROWS = 7

function InitDialogMenu( menu )
{
	if ( menu.GetName() == "ConfirmDialog" )
	{
		AddEventHandlerToButton( menu, "BtnConfirmQuitGame", UIE_CLICK, OnConfirmQuitGameButton_Activate )
		AddEventHandlerToButton( menu, "BtnCancel", UIE_CLICK, OnCancelButton_Activate )

		uiGlobal.ConfirmMenuDetails <- menu.GetChild( "LblDetails" )
		uiGlobal.ConfirmMenuErrorCode <- menu.GetChild( "LblErrorCode" )

		AddEventHandlerToButton( menu, "BtnConfirmRegen0", UIE_CLICK, OnConfirmRegen0_Activate )
		AddEventHandlerToButton( menu, "BtnConfirmRegen1", UIE_CLICK, OnConfirmRegen1_Activate )
		AddEventHandlerToButton( menu, "BtnConfirmRegen2", UIE_CLICK, OnConfirmRegen2_Activate )
	}
	else if ( menu.GetName() == "RankedSeasonEndDialog" )
	{
		AddEventHandlerToButton( menu, "BtnConfirm_Continue", UIE_CLICK, SeasonEndDialogClosed )
	}
	else if ( menu.GetName() == "PlaylistAnnounceDialog" )
	{
		AddEventHandlerToButton( menu, "BtnConfirm_Continue", UIE_CLICK, ClosePlaylistAnnounceDialog )
	}
}

function InitChoiceDialogMenu( menu )
{
	uiGlobal.choiceDialogData <- null
	uiGlobal.choice2DialogData <- null

	AddEventHandlerToButtonClass( menu, "ChoiceDialogButtonClass", UIE_CLICK, OnChoiceButton_Activate )
}

function InitChoiceDialog2Menu( menu )
{
	uiGlobal.choice2DialogData <- null
}

function OnChoice2ListScrollUp_Activate(...)
{
	uiGlobal.trainingListScrollState--
	if ( uiGlobal.trainingListScrollState < 0 )
	uiGlobal.trainingListScrollState = 0

	UpdateMapListScroll()
}

function OnChoice2ListScrollDown_Activate(...)
{
	uiGlobal.trainingListScrollState++
	if ( uiGlobal.trainingListScrollState > uiGlobal.numTrainingButtonsOffScreen )
		uiGlobal.trainingListScrollState = uiGlobal.numTrainingButtonsOffScreen

	UpdateMapListScroll()

	//ClientCommand("disconnect \"Scrolled down: "+file.mapListScrollState+"\"")

}

function Choice2Button_Focused( button )
{
	local buttonID = button.GetScriptID().tointeger()

	// Update window scrolling if we highlight a map not in view
	local minScrollState = clamp( buttonID - (CHOICE2_VISIBLE_ROWS - 1), 0, uiGlobal.numTrainingButtonsOffScreen )
	local maxScrollState = clamp( buttonID, 0, uiGlobal.numTrainingButtonsOffScreen )

	if ( uiGlobal.trainingListScrollState < minScrollState )
		uiGlobal.trainingListScrollState = minScrollState
	if ( uiGlobal.trainingListScrollState > maxScrollState )
		uiGlobal.trainingListScrollState = maxScrollState

	UpdateMapListScroll()
}

function OnButtonsPanel_Activate(button)
{
	local buttonID = button.GetScriptID().tointeger()
	ClientCommand("disconnect \"OnButtonsPanel_Activate: "+button.GetScriptID()+"\"")
}

function UpdateMapListScroll()
{
	local buttons = uiGlobal.choice2Buttons
	local basePos = buttons[0].GetBasePos()
	local offset = buttons[0].GetHeight() * uiGlobal.trainingListScrollState

	buttons[0].SetPos( basePos[0], basePos[1] - offset )
}

function InitDataCenterDialogMenu( menu )
{
	menu.GetChild( "ListDataCenters" ).SetParentMenu( menu )

	AddEventHandlerToButton( menu, "ListDataCenters", UIE_CLICK, OnDataCenterButton_Activate )
	AddEventHandlerToButtonClass( menu, "ChoiceDialogButtonClass", UIE_CLICK, OnChoiceButton_Activate )
}

function InitHashtagDialogMenu( menu )
{
	AddEventHandlerToButtonClass( menu, "ChoiceDialogButtonClass", UIE_CLICK, OnChoiceButton_Activate )
}

function OnChoiceButton_Activate( button )
{
	local buttonID = button.GetScriptID().tointeger()

	CloseDialog()

	Assert( uiGlobal.choiceDialogData )

	if ( uiGlobal.choiceDialogData[buttonID].func )
		uiGlobal.choiceDialogData[buttonID].func.call( this )
}

function OnChoice2Button_Activate( button )
{
	local buttonID = button.GetScriptID().tointeger()
	//ClientCommand("disconnect \"Callback works: "+buttonID+"\"")

	CloseDialog()

	Assert( uiGlobal.choice2DialogData )

	/*if ( "trainingResume" in uiGlobal.choice2DialogData[buttonID] && uiGlobal.choice2DialogData[buttonID].trainingResume ) {

		if (uiGlobal.choice2DialogData[buttonID].trainingResume == 2137) ClientCommand("disconnect \"shit: "+buttonID+"\"")

		SetPlayerTrainingResumeChoice( uiGlobal.choice2DialogData[buttonID].trainingResume );
		UI_DoTraining();
		return
	}*/

	//if ( "func" in uiGlobal.choice2DialogData[buttonID] && uiGlobal.choice2DialogData[buttonID].func && "call" in uiGlobal.choice2DialogData[buttonID].func )
		uiGlobal.choice2DialogData[buttonID].func.call( this )
}

function OnDataCenterButton_Activate( button )
{
	printt( "Chose a data center" )
	CloseDialog()
}

function OnConfirmQuitGameButton_Activate( button )
{
	CloseDialog()
}

function OnCancelButton_Activate( button )
{
	CloseDialog( true )
}

function OpenDialog( dialog, message, confirmButtonName = null, cancelButtonName = null, inputDisableTime = null )
{
	if ( uiGlobal.activeDialog == GetMenu( "RankedSeasonEndDialog" ) || uiGlobal.activeDialog == GetMenu( "PlaylistAnnounceDialog" ) )
		CloseDialog()
	Assert( !uiGlobal.activeDialog, "Tried to open dialog but dialog " + uiGlobal.activeDialog.GetName() + " was already open" )

	uiGlobal.forceDialogChoice = false

	if ( cancelButtonName == null )
		cancelButtonName = "BtnCancel"

	if ( inputDisableTime )
		uiGlobal.dialogInputEnableTime = Time() + inputDisableTime

	local messageElements = GetElementsByClassname( dialog, "DialogMessageClass" )
	foreach ( messageElement in messageElements )
		messageElement.SetText( message )

	local buttons = GetElementsByClassname( dialog, "ConfirmButtonClass" )
	buttons.extend( GetElementsByClassname( dialog, "CancelButtonClass" ) )
	foreach ( button in buttons )
	{
		if ( button.GetName() != confirmButtonName && button.GetName() != cancelButtonName )
			button.Hide()
		else
			button.Show()
	}

	uiGlobal.ConfirmMenuDetails.Hide()
	uiGlobal.ConfirmMenuErrorCode.Hide()

	//btnCancel.SetFocused()
	//FocusDefaultMenuItem( dialog ) // Neither of these seem to be reliable.

	uiGlobal.activeDialog = dialog
	if ( uiGlobal.activeMenu )
		uiGlobal.preDialogFocus = GetFocus()
	else
		uiGlobal.preDialogFocus = null

	OpenMenuWrapper( uiGlobal.activeDialog, false )
}

function OpenChoiceDialog( dialogData, menu = null )
{
	if ( uiGlobal.activeDialog == GetMenu( "RankedSeasonEndDialog" ) || uiGlobal.activeDialog == GetMenu( "PlaylistAnnounceDialog" ) )
		CloseDialog()
	Assert( !uiGlobal.activeDialog, "Tried to open choice dialog but dialog " + uiGlobal.activeDialog.GetName() + " was already open" )

	uiGlobal.forceDialogChoice = false

	if ( menu == null )
		menu = GetMenu( "ChoiceDialog" )

	local header = ""
	local detailsMessage = ""
	local detailsColor = [150, 180, 190, 255]
	local buttonData = []
	local spinner = false

	local footerData = []
	footerData.append( { label = "#A_BUTTON_SELECT" } )
	footerData.append( { label = "#B_BUTTON_CANCEL" } )

	if ( ("header" in dialogData) && dialogData.header != null )
		header = dialogData.header

	if ( ("detailsMessage" in dialogData) && dialogData.detailsMessage != null )
		detailsMessage = dialogData.detailsMessage

	if ( ("detailsColor" in dialogData) && dialogData.detailsColor != null )
		detailsColor = dialogData.detailsColor

	if ( ("buttonData" in dialogData) && dialogData.buttonData != null )
		buttonData = dialogData.buttonData

	if ( ("footerData" in dialogData) && dialogData.footerData != null )
		footerData = dialogData.footerData

	if ( ("spinner" in dialogData) && dialogData.spinner != null )
		spinner = dialogData.spinner

	foreach ( footer in footerData )
	{
		if ( "func" in footer && footer.func != null )
			menu.s.navBackFunc <- footer.func // Only needed for back button for now
	}

	//PrintTable( dialogData )

	local buttons = GetElementsByClassname( menu, "ChoiceDialogButtonClass" )
	local numChoices = buttonData.len()
	local numButtons = buttons.len()
	//printt( "numChoices:", numChoices, "numButtons:", numButtons )
	Assert( numButtons >= numChoices, "OpenChoiceDialog: can't have " + numChoices + " choices for only " + numButtons + " buttons." )

	local startButtonID = 0

	// To start in the middle of the button stack, we create a new dialog data array that matches the length of the button array
	local newButtonData = []
	local choiceIdx = 0
	if ( numButtons > numChoices && menu != GetMenu("ChoiceDialog2") ) // if things go south, comment "&& menu != GetMenu("ChoiceDialog2")"
	{
		startButtonID = ( numButtons / 2 ).tointeger() - 1

		if ( numButtons - startButtonID < numChoices )
			startButtonID = numButtons - numChoices - 1;

		if ( startButtonID == 0 )
			startButtonID++

		if (menu == GetMenu("ChoiceDialog2")) startButtonID = 0;

		for ( local i = 0; i < numButtons; i++ )
		{
			if ( i < startButtonID || choiceIdx >= numChoices )
			{
				newButtonData.append( { name = "BUTTONSKIP" } )
			}
			else
			{
				local name = buttonData[ choiceIdx ].name
				local func = buttonData[ choiceIdx ].func

				local nameData = null
				if ( "nameData" in buttonData[ choiceIdx ] )
					nameData = buttonData[ choiceIdx].nameData

				newButtonData.append( { name = name, func = func, nameData = nameData } )

				choiceIdx++
			}
		}
	}

	if ( newButtonData.len() )
		uiGlobal.choiceDialogData = newButtonData
	else
		uiGlobal.choiceDialogData = buttonData

	if (menu == GetMenu("ChoiceDialog2"))
		uiGlobal.choice2DialogData = uiGlobal.choiceDialogData

	// now set up each button: hide, or set text and show
	foreach ( idx, button in buttons )
	{
		button.Hide()

		local buttonID = button.GetScriptID().tointeger()
		Assert(buttonID != idx, "Mismatch between buttonID and idx: "+buttonID+", "+idx);
		if (buttonID != idx) ClientCommand("disconnect \"Mismatch between buttonID and idx: "+buttonID+", "+idx+"\"");
		if (!(idx in uiGlobal.choiceDialogData) || !("name" in uiGlobal.choiceDialogData[idx]))
			continue
		if ( uiGlobal.choiceDialogData[idx].name == "BUTTONSKIP" )
			continue

		if ( "nameData" in uiGlobal.choiceDialogData[idx] && uiGlobal.choiceDialogData[idx].nameData != null )
			button.SetText( uiGlobal.choiceDialogData[idx].name, uiGlobal.choiceDialogData[idx].nameData )
		else
			button.SetText( uiGlobal.choiceDialogData[idx].name )

		button.Show()
	}

	local headers = []
	if ( IsArray( header ) )
		headers = header
	else
		headers.append( header )

	for ( local i = headers.len() ; i < 5 ; i++ )
		headers.append( null )

	local detailsMessages = []
	if ( IsArray( detailsMessage ) )
		detailsMessages = detailsMessage
	else
		detailsMessages.append( detailsMessage )

	for ( local i = detailsMessages.len() ; i < 5 ; i++ )
		detailsMessages.append( null )

	menu.GetChild( "LblMessage" ).SetText( headers[0], headers[1], headers[2], headers[3], headers[4] )
	menu.GetChild( "LblDetails" ).SetText( detailsMessages[0], detailsMessages[1], detailsMessages[2], detailsMessages[3], detailsMessages[4] )
	menu.GetChild( "LblDetails" ).SetColor( detailsColor )

	uiGlobal.activeDialog = menu
	if ( uiGlobal.activeMenu )
		uiGlobal.preDialogFocus = GetFocus()
	else
		uiGlobal.preDialogFocus = null

	// Get footer elems and fill in with footerData
	local gamepadFooterButtons = GetElementsByClassname( menu, "GamepadFooterButtonClass" )
	foreach ( button in gamepadFooterButtons )
	{
		local index = button.GetScriptID().tointeger()

		if ( index < footerData.len() )
		{
			button.SetText( footerData[index].label )
			button.Show()
		}
		else
		{
			button.Hide()
			button.SetText( "" )
		}
	}

	local spinnerImgs = GetElementsByClassname( menu, "SpinningCircle" )
	foreach ( img in spinnerImgs )
		img.SetVisible( spinner )

	OpenMenuWrapper( uiGlobal.activeDialog, true )

	if (menu == GetMenu("ChoiceDialog2")) {
		// must be here, or we will get error for "file" from these funcs
		AddEventHandlerToButtonClass( menu, "ChoiceDialogButtonClass", UIE_CLICK, Bind( OnChoice2Button_Activate ) )
		AddEventHandlerToButtonClass( menu, "ChoiceDialogButtonClass", UIE_GET_FOCUS, Bind( Choice2Button_Focused ) )
		AddEventHandlerToButtonClass( menu, "Choice2ScrollUpClass", UIE_CLICK, Bind( OnChoice2ListScrollUp_Activate ) )
		AddEventHandlerToButtonClass( menu, "Choice2ScrollDownClass", UIE_CLICK, Bind( OnChoice2ListScrollDown_Activate ) )

		RegisterButtonPressedCallback( MOUSE_WHEEL_UP, OnChoice2ListScrollUp_Activate )
		RegisterButtonPressedCallback( MOUSE_WHEEL_DOWN, OnChoice2ListScrollDown_Activate )
		uiGlobal.trainingListScrollState <- 0
		uiGlobal.numTrainingButtonsOffScreen <- null
		uiGlobal.choice2Buttons <- GetElementsByClassname( menu, "ChoiceDialogButtonClass" )
		uiGlobal.numTrainingButtonsOffScreen = 14 + 1 - CHOICE2_VISIBLE_ROWS
	}
}

function CloseDialog( cancelled = false )
{
	uiGlobal.dialogInputEnableTime = null

	if ( uiGlobal.activeDialog )
	{
		// This assert is meant to catch the case where we closed the lobby transition dialog before we were supposed to.
		Assert( !uiGlobal.lobbyMenusLeftOpen || uiGlobal.activeDialog != GetMenu( "LobbyTransition" ) )

		if (uiGlobal.activeDialog == GetMenu("ChoiceDialog2"))
		{
			DeregisterButtonPressedCallback( MOUSE_WHEEL_UP, OnChoice2ListScrollUp_Activate )
			DeregisterButtonPressedCallback( MOUSE_WHEEL_DOWN, OnChoice2ListScrollDown_Activate )
		}

		if ( uiGlobal.dialogCloseCallback )
		{
			uiGlobal.dialogCloseCallback( cancelled )
			uiGlobal.dialogCloseCallback = null
		}

		CloseMenuWrapper( uiGlobal.activeDialog )
		uiGlobal.activeDialog = null

		local focused = false
		if ( IsValid( uiGlobal.preDialogFocus ) )
		{
			focused = uiGlobal.preDialogFocus.SetFocused()
			printt( "Focused uiGlobal.preDialogFocus (" + uiGlobal.preDialogFocus.GetName() + "): " + focused )
		}

		if ( !focused && uiGlobal.activeMenu != null )
		{
			FocusDefaultMenuItem( uiGlobal.activeMenu )
			printt( "Focused default item in menu " + uiGlobal.activeMenu.GetName() )
		}

		uiGlobal.preDialogFocus = null
	}
}

function Menu_ToggleLookInvert()
{
	printt( "toggling look invert" )
	ClientCommand( "lookInverted" )
	ToggleLookInvert()
}

function Menu_ToggleLookInvert_Repeat()
{
	printt( "toggling look invert" )
	ClientCommand( "noButtonClicked" )
	ToggleLookInvert()
}

function SendConCommand_ConfirmInvertSettings()
{
	ClientCommand( "confirmInvertSettings" )
}

function SendConCommand_NoButtonClicked()
{
	ClientCommand( "noButtonClicked" )
}

function ServerCallback_OpenPilotLoadoutMenu()
{
	if ( uiGlobal.activeMenu == null)
	{
		AdvanceMenu( GetMenu( "PilotLoadoutsMenu" ) )
	}
}

function ServerCallback_DevOpenTitanLoadoutMenu()
{
	if ( uiGlobal.activeMenu == null)
	{
		AdvanceMenu( GetMenu( "TitanLoadoutsMenu" ) )
	}
}

function ServerCallback_ShowInvertLookMenu( isConfirming = false )
{
	thread ShowInvertLookMenu( isConfirming )
}

function SCBUI_PlayerConnectedOrDisconnected( joinSound )
{
	if ( joinSound )
	{
		EmitUISound( "PlayerJoinedLobby" )
	}

	local menu = uiGlobal.activeMenu
	if ( menu == null )
		return

	local menuName = menu.GetName()
	switch ( menuName )
	{
		case "CoopPartyCustomMenu":
			OnPlayerConnectOrLeave_CoopPartyCustomMenu( menu )
			break;

		default:
			break
	}
}

function ShowInvertLookMenu( isConfirming )
{
	local promptText
	local descText
	local confirmText
	local confirmFunc
	local noText
	local noFunc
	local swapButtons = false

	//printt( "SERVER CALLBACK SHOW INVERT LOOK MENU")

	waitthread WaitForNoDialog()
	if ( GetActiveLevel() != "mp_npe" )
		return

	// confirming the settings (second menu)
	if ( isConfirming )
	{
		promptText = "#MENU_VERTICAL_LOOK_INPUT_COMFY_HEADER"
		descText = "#MENU_VERTICAL_LOOK_INPUT_COMFY"

		confirmText = "#MENU_KEEP_SETTINGS"
		confirmFunc = SendConCommand_ConfirmInvertSettings

		noText = "#MENU_REVERSE_SETTINGS"
		noFunc = Menu_ToggleLookInvert_Repeat

		swapButtons = true
	}
	// first time asking about the settings (first menu)
	else
	{
		promptText = "#MENU_REVERSE_VERTICAL_LOOK_INPUT_HEADER"
		descText = "#MENU_REVERSE_VERTICAL_LOOK_INPUT"

		confirmText =  "#YES"
		confirmFunc = Menu_ToggleLookInvert

		noText =  "#NO"
		noFunc = SendConCommand_NoButtonClicked
	}

	local buttonData = []
	if ( !swapButtons )
	{
		buttonData.append( { name = noText, func = noFunc } )
		buttonData.append( { name = confirmText, func = confirmFunc } )
	}
	else
	{
		//printt( "swapping buttons" )
		buttonData.append( { name = confirmText, func = confirmFunc } )
		buttonData.append( { name = noText, func = noFunc } )
	}

	local footerData = []
	footerData.append( { label = "#A_BUTTON_SELECT" } )
	//footerData.append( { label = "#B_BUTTON_CANCEL", func = null } )

	local dialogData = {}
	dialogData.header <- promptText
	dialogData.detailsMessage <- descText
	dialogData.buttonData <- buttonData
	dialogData.footerData <- footerData

	OpenChoiceDialog( dialogData )
	uiGlobal.forceDialogChoice = true
}

function WaitForNoDialog()
{
	while( uiGlobal.activeDialog && GetActiveLevel() == "mp_npe" )
	{
		wait 0
	}
}

// when you want to force players to click a menu button to close the menu (not press ESC)
function OpenDialog_ForceChoice( dialog, message, confirmButtonName = null, cancelButtonName = null )
{
	OpenDialog( dialog, message, confirmButtonName, cancelButtonName )
	uiGlobal.forceDialogChoice = true
}

function LeaveDialog()
{
	local buttonData = []
	local type = GetLobbyTypeScript()
	local isCoopMenu = uiGlobal.activeMenu == GetMenu( "CoopPartyMenu" )
	//// If we want to prevent people from backing out when the match is about to start:
	//if ( (IsLobby() && (type == eLobbyType.MATCH)) && GetLobbyTeamsShowAsBalanced() )
	//	return

	if ( IsLobby() && (type != eLobbyType.MATCH) ) // SOLO, PARTY_LEADER, PARTY_MEMBER, PRIVATE_MATCH
	{
		if ( IsPrivateMatch() )
		{
			buttonData.append( { name = "#YES_LEAVE_LOBBY", func = LeaveMatchSolo } )
		}
		else if ( isCoopMenu )
		{
			buttonData.append( { name = "#YES_LEAVE_LOBBY", func = CloseTopMenu } )
		}
		else
		{
			buttonData.append( { name = "#YES_RETURN_TO_TITLE_MENU", func = Disconnect } )
		}
	}
	else // This is a match or a match lobby
	{
		if ( PartyHasMembers() )
		{
			if ( AmIPartyLeader() && !IsPrivateMatch() )
				buttonData.append( { name = "#YES_LEAVE_WITH_PARTY", func = LeaveMatchWithParty } )

			if ( IsLobby() )
			{
				if ( isCoopMenu )
					buttonData.append( { name = "#YES_LEAVE_LOBBY", func = CloseTopMenu } )
				else
					buttonData.append( { name = "#YES_LEAVE_LOBBY", func = LeaveMatchSolo } )
			}
			else
			{
				buttonData.append( { name = "#YES_LEAVE_MATCH", func = LeaveMatchSolo } )
			}
		}
		else
		{
			if ( IsLobby() )
			{
				if ( isCoopMenu )
					buttonData.append( { name = "#YES_LEAVE_LOBBY", func = CloseTopMenu } )
				else
					buttonData.append( { name = "#YES_LEAVE_LOBBY", func = LeaveMatchSolo } )
			}
			else
			{
				buttonData.append( { name = "#YES_LEAVE_MATCH", func = LeaveMatchSolo } )
			}
		}
	}

	buttonData.append( { name = "#CANCEL", func = null } )

	local dialogData = {}
	dialogData.header <- "#ARE_YOU_SURE_YOU_WANT_TO_LEAVE"

	if ( !IsLobby() && !IsPrivateMatch() && !IsCoopMatch() )
	{
		dialogData.detailsMessage <- GetDisconnectPenaltyMessage()
		dialogData.detailsColor <- [255, 0, 0, 255]
	}

	dialogData.buttonData <- buttonData

	OpenChoiceDialog( dialogData )
}

function GetDisconnectPenaltyMessage()
{
	if ( level.ui.penalizeDisconnect )
	{
		if ( PenalizeRankedDisconnect() )
			return "#LEAVING_MATCH_LOSS_AND_RANKED_WARNING"

		return "#LEAVING_MATCH_LOSS_WARNING"
	}

	if ( PenalizeRankedDisconnect() )
		return "#LEAVING_A_RANKED_MATCH"

	return null
}

function PenalizeRankedDisconnect()
{
	if ( !PlayerPlayingRanked() )
		return false

	if ( !level.ui.rankedPenalizeDisconnect )
		return false

	return GetPlayerTotalCompletedGems() > 0
}

function LeaveMatchWithParty()
{
	LeaveMatchSolo()

}

function LeaveMatchSolo()
{
	// IMPORTANT: It's very important to always leave the party view if you back out
	// otherwise you risk trashing the party view for remaining players and pointing
	// it back to your private lobby.
	if ( Durango_IsDurango() )
		Durango_LeaveParty()

	if ( IsTrainingLevel() )
	    Disconnect()

	thread TryGoToPersonalLobby()

	ShowLeavingDialog()
}

function TryGoToPersonalLobby()
{
	EndSignal( uiGlobal.signalDummy, "OnCancelConnect" )

	uiGlobal.dialogCloseCallback =
		function( canceled )
		{
			Signal( uiGlobal.signalDummy, "OnCancelConnect" )
		}

	wait 0.65

	ClientCommand( "TryKickPlayersForPersonalLobby" )

	thread TryChangeLobbyType()

	ClientCommand("playlist private_match; map mp_lobby")
}

function TryChangeLobbyType()
{
	WaitSignal( uiGlobal.signalDummy, "LevelFinishedLoading" )

	if( GetConVarInt("hide_server") == 0 )
	{
		ClientCommand( "hide_server 1" )
		uiGlobal.setServerPublicNextPrivateLobby <- true
	}

	ClientCommand( "RequestServerChangeToLobbyType0" )
	ClientCommand( "TryKickPlayersForPersonalLobby" )
}

function ShowLeavingDialog()
{
	local buttonData = []
	buttonData.append( { name = "#CANCEL_AND_QUIT_TO_MAIN_MENU", func = Disconnect } )

	local footerData = []
	footerData.append( { label = "#A_BUTTON_SELECT" } )

	local dialogData = {}
	dialogData.header <- "#FINDING_EMPTY_PARTY_SERVER"
	dialogData.buttonData <- buttonData
	dialogData.footerData <- footerData
	dialogData.spinner <- true

	OpenChoiceDialog( dialogData )
	uiGlobal.forceDialogChoice = true
}

function ShowTrainingConnectDialog()
{
	local buttonData = []
	buttonData.append( { name = "#CANCEL", func = CancelTrainingConnect } )

	local footerData = []
	footerData.append( { label = "#A_BUTTON_SELECT" } )

	local dialogData = {}
	dialogData.header <- "#CONNECTING_TRAINING"
	dialogData.buttonData <- buttonData
	dialogData.footerData <- footerData
	dialogData.spinner <- true

	OpenChoiceDialog( dialogData )
	uiGlobal.forceDialogChoice = true
	uiGlobal.doTraining = true
}

function CancelTrainingConnect()
{
	//ClientCommand( "CancelTraining" )
	uiGlobal.doTraining = false
	CloseDialog()
}

function ShowPrivateMatchConnectDialog()
{
	local buttonData = []
	buttonData.append( { name = "#CANCEL", func = CancelPrivateMatchSearch } )

	local footerData = []
	footerData.append( { label = "#A_BUTTON_SELECT" } )

	local dialogData = {}
	dialogData.header <- "#CONNECTING_PRIVATEMATCH"
	dialogData.buttonData <- buttonData
	dialogData.footerData <- footerData
	dialogData.spinner <- true

	OpenChoiceDialog( dialogData )
	uiGlobal.forceDialogChoice = true
}

function CancelPrivateMatchSearch()
{
	uiGlobal.cancelledPrivateMatch <- true
	ClientCommand( "CancelPrivateMatchSearch" )
	CloseDialog()
}

function ShowMatchConnectDialog()
{
	local buttonData = []
	buttonData.append( { name = "#CANCEL", func = CancelMatchSearch } )

	local footerData = []
	footerData.append( { label = "#A_BUTTON_SELECT" } )

	local dialogData = {}
	dialogData.header <- "#CONNECTING_SEARCHING"
	dialogData.buttonData <- buttonData
	dialogData.footerData <- footerData
	dialogData.spinner <- true

	OpenChoiceDialog( dialogData )
	uiGlobal.forceDialogChoice = true
}

function CancelMatchSearch()
{
	StopMatchmaking()
	ClientCommand( "CancelMatchSearch" )
	CloseDialog()
}

function Disconnect()
{
	StopMatchmaking()
	ClientCommand( "disconnect" )

	// Have to do this here, not in UICodeCallback_LevelShutdown because that is called all the time
	// when levels change. We don't want smart glass thinking you're in the main menu between level loads
	SmartGlass_SetGameState( "MainMenu" )
}

function OpenDataCenterDialog()
{
	if ( uiGlobal.activeDialog )
		return

	local menu = GetMenu( "DataCenterDialog" )

	local buttonData = []
	if ( !Durango_IsDurango() )
		buttonData.append( { name = "#CANCEL", func = null } )

	local dialogData = {}
	dialogData.header <- "#DATA_CENTERS"
	dialogData.buttonData <- buttonData

	OpenChoiceDialog( dialogData, menu )
}

function OpenHashtagDialog()
{
	if ( uiGlobal.activeDialog )
		return

	local menu = GetMenu( "HashtagDialog" )

	local buttonData = []
	if ( !Durango_IsDurango() )
		buttonData.append( { name = "#CLOSE", func = null } )

	local footerData = []
	if ( Durango_IsDurango() )
		footerData.append( { label = "#A_BUTTON_EDIT" } )
	footerData.append( { label = "#B_BUTTON_CLOSE" } )

	local dialogData = {}
	dialogData.header <- "#MATCHMAKING_HASHTAG"
	dialogData.detailsMessage <- "#HASHTAG_DESC"
	dialogData.buttonData <- buttonData
	dialogData.footerData <- footerData

	OpenChoiceDialog( dialogData, menu )
}

// Esc or gamepad B button will close as normal. Using the dialog "close" button will ignore input until time has passed.
function ClosePlaylistAnnounceDialog( button )
{
	if ( uiGlobal.dialogInputEnableTime && Time() < uiGlobal.dialogInputEnableTime )
		return

	CloseDialog()
}

function ShowPortForwardWarning( port = 27015 )
{
	if ( GetActiveLevel() == "mp_npe" ) // do not show this on training, we aren't expecting more than one player to join.
		return
    local isDefaultPort = (port == 27015)
    local message = isDefaultPort ?
        "#PORT_FORWARD_WARNING_DEFAULT" :
        ["#PORT_FORWARD_WARNING_CUSTOMPORT", format("%d", port)]

    local buttonData = []
    buttonData.append( { name = "OK", func = null } )

    local dialogData = {}
    dialogData.header <- "#PORT_FORWARD_WARNING_HEADER"
    dialogData.detailsMessage <- message
    dialogData.buttonData <- buttonData

    OpenChoiceDialog( dialogData )
}

Globalize(ShowPortForwardWarning)