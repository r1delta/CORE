coopBurnCardButton <- null
coopBlackMarketButton <- null

function main()
{
	Globalize( InitCoopPartyMenu )
	Globalize( OnOpenCoopPartyMenu )
	Globalize( OnCloseCoopPartyMenu )

	file.haveClickedCustomCoop <- false
}

function InitCoopPartyMenu( menu )
{
	AddEventHandlerToButton( menu, "CoopQuickMatchButton", UIE_CLICK, Bind( CoopQuickMatchButton_Activate ) )
	AddEventHandlerToButton( menu, "CoopCreateAMatchButton", UIE_CLICK, Bind( CoopCreateAMatchButton_Activate ) )
	AddEventHandlerToButton( menu, "BtnEditPilotLoadouts", UIE_CLICK, EditPilotLoadoutList_Activate )
	AddEventHandlerToButtonClass( menu, "EditPilotLoadoutsButtonClass", UIE_GET_FOCUS, LockedButtonGetFocusHandler )
	AddEventHandlerToButtonClass( menu, "EditPilotLoadoutsButtonClass", UIE_LOSE_FOCUS, LockedButtonLoseFocusHandler )
	AddEventHandlerToButtonClass( menu, "EditTitanLoadoutsButtonClass", UIE_CLICK, EditTitanLoadoutList_Activate )
	AddEventHandlerToButtonClass( menu, "EditTitanLoadoutsButtonClass", UIE_GET_FOCUS, LockedButtonGetFocusHandler )
	AddEventHandlerToButtonClass( menu, "EditTitanLoadoutsButtonClass", UIE_LOSE_FOCUS, LockedButtonLoseFocusHandler )
	local button = GetElem( menu, "BtnEditBurnCards" )
	coopBurnCardButton <- button
	button.AddEventHandler( UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "BurnCards_InGame" ) ) )
	local button = GetElem( menu, "BtnBlackMarket" )
	coopBlackMarketButton <- button
	button.AddEventHandler( UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "BlackMarketMainMenu" ) ) )
	AddEventHandlerToButtonClass( menu, "BtnGameSummaryClass", UIE_CLICK, OnClickGameSummaryButton )
	AddEventHandlerToButton( menu, "BtnChallenges", UIE_CLICK, ViewChallenges_Activate )
	AddEventHandlerToButton( menu, "BtnChallenges", UIE_GET_FOCUS, LockedButtonGetFocusHandler )
	AddEventHandlerToButton( menu, "BtnChallenges", UIE_LOSE_FOCUS, LockedButtonLoseFocusHandler )
	AddEventHandlerToButtonClass( menu, "OptionsButtonClass", UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "OptionsMenu" ) ) )
	AddEventHandlerToButton( menu, "BtnRegen", UIE_CLICK, RegenButton_Activate )

	local images = GetElementsByClassname( menu, "PlaylistImageClass" )
	foreach ( image in images )
		image.SetImage( "../ui/menu/playlist/coop" )

	local names = GetElementsByClassname( menu, "PlaylistNameClass" )
	foreach ( name in names )
		name.SetText( "#GAMEMODE_COOP" )

	local descriptions = GetElementsByClassname( menu, "PlaylistDescriptionClass" )
	foreach ( description in descriptions )
		description.SetText( "#COOP_DESC" )

	local cams = GetElementsByClassname( menu, "CoopCreateAMatchButtonClass" )
	if ( cams.len() > 0 )
	{
	 	cams[0].AddEventHandler( UIE_GET_FOCUS, Bind( LockedCoopCustomButtonGetFocusHandler ) )
	 	cams[0].AddEventHandler( UIE_LOSE_FOCUS, Bind( LockedCoopCustomButtonLoseFocusHandler ) )
	}
}

function LockedCoopCustomButtonGetFocusHandler( button )
{
	local menu = GetMenu( "CoopPartyMenu" )

	if ( button.IsLocked() )
	{
		local buttonTooltip = menu.GetChild( "ButtonTooltip" )
		local toolTipLabel = buttonTooltip.GetChild( "Label" )

		local playCount = GetCoopPlayCount()
		local remaining = (COOP_CUSTOMMATCH_UNLOCK_PLAYS - playCount)
		if ( remaining == 1 )
			toolTipLabel.SetText( "#COOP_CUSTOM_UNLOCK_HINT_ONELEFT" )
		else
			toolTipLabel.SetText( "#COOP_CUSTOM_UNLOCK_HINT", remaining )

		local buttonPos = button.GetAbsPos()
		local buttonHeight = button.GetHeight()
		local tooltipHeight = buttonTooltip.GetHeight()
		local yOffset = ( tooltipHeight - buttonHeight ) / 2.0

		buttonTooltip.SetPos( buttonPos[0] + button.GetWidth() * 0.9, buttonPos[1] - yOffset )
		buttonTooltip.Show()
	}
}

function LockedCoopCustomButtonLoseFocusHandler( button )
{
	local menu = GetMenu( "CoopPartyMenu" )
	local buttonTooltip = menu.GetChild( "ButtonTooltip" )
	buttonTooltip.Hide()
}

function GetCoopPlayCount()
{
	if ( !IsConnected() )
		return 0
	local result = GetPersistentVar( "gamestats.modesplayed[coop]" )
	return result
}

function OnOpenCoopPartyMenu( menu )
{
	local menu = GetMenu( "CoopPartyMenu" )
	uiGlobal.gamemodeLoadoutBeingEdited = "coop"
	UpdateButtons( menu )
	UpdateTeamInfo( menu, GetTeam() )
	UpdateCoopLobbyButtons( menu, GetLobbyTypeScript() )

	local coopPlayCount = GetCoopPlayCount()

	local haveSeenCustomCoop = GetPersistentVar( "haveSeenCustomCoop" )
	local isLocked = (coopPlayCount < COOP_CUSTOMMATCH_UNLOCK_PLAYS )
	if ( DevEverythingUnlocked() )
		isLocked = false
	local cams = GetElementsByClassname( menu, "CoopCreateAMatchButtonClass" )
	if ( cams.len() > 0 )
	{
		cams[0].SetLocked( false )
		cams[0].SetNew( false )

		if ( isLocked )
		{
			cams[0].SetLocked( true )
		}
		else
		{
			if ( !haveSeenCustomCoop && !file.haveClickedCustomCoop )
				cams[0].SetNew( true )
		}
	}
}

function CoopQuickMatchButton_Activate( button )
{
	local partySize = GetPartyMembers().len()
	if ( partySize > 4 )
	{
		CloseTopMenu()
		return
	}

	if ( WaitingForLeader() || !AmIPartyLeader() )
	{
		EmitUISound( "Menu.Deny" )
		return
	}

	ClientCommand( "match_playlist coop" )
	ClientCommand( "StartCoopMatchSearch" )
	CloseTopMenu()
	ShowMatchConnectDialog()
}
Globalize ( CoopQuickMatchButton_Activate )

function CoopCreateAMatchButton_Activate( button )
{
	local partySize = GetPartyMembers().len()
	if ( partySize > 4 )
	{
		CloseTopMenu()
		return
	}

	if ( button.IsLocked() )
		return

	if ( WaitingForLeader() || !AmIPartyLeader() )
	{
		EmitUISound( "Menu.Deny" )
		return
	}

	file.haveClickedCustomCoop = true
	ClientCommand( "ClickedCoopCustomMatch" )
	local handlerFunc = AdvanceMenuEventHandler( GetMenu( "CoopPartyCustomMenu" ) )
	handlerFunc( button )
}

function UpdateButtons( menu )
{
	PopulateNewUnlockTables()

	UpdateEditBurnCardButtonText( coopBurnCardButton )
	UpdateBlackMarketButtonText( coopBlackMarketButton )
	UpdateEditLoadoutButtons( "CoopPartyMenu" )
	UpdateGameSummaryButton( "CoopPartyMenu" )
	UpdateChallengesButton( "CoopPartyMenu" )
	UpdateRegenButton( false, "CoopPartyMenu" )
}

function OnCloseCoopPartyMenu( menu )
{
	if ( IsConnected() )
		UpdateTeamInfo( GetMenu( "LobbyMenu" ), GetTeam() )
}

function UpdateCoopLobbyButtons( menu, lobbyType = null )
{
	local button1 = GetElem( menu, "CoopQuickMatchButton" )
	local button2 = GetElem( menu, "CoopCreateAMatchButtonClass" )
	if ( button1 != null )
	{
		if ( lobbyType == eLobbyType.PARTY_MEMBER )
		{
			button1.SetEnabled( false )
			button1.Hide()
			button2.SetEnabled( false )
			button2.Hide()
			GetElem( menu, "BtnEditPilotLoadouts" ).SetFocused()
		}
		else
		{
			button1.SetEnabled( true )
			button1.Show()
			button2.SetEnabled( true )
			button2.Show()
		}
	}
}
Globalize( UpdateCoopLobbyButtons )