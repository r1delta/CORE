function main()
{
	Globalize( InitPickCardMenu )
	Globalize( OnOpenMenu_BurnCardsPickCard )
	Globalize( OnCloseMenu_BurnCardPickCard )
}

function InitPickCardMenu( menu )
{
	file.onOpenTime <- null
	file.menu <- menu
	file.bindings <- false

	local previewCardElem = menu.GetChild( "PreviewCard_NestedPanel" )
	file.burnCardPreviewCard <- CreatePreviewCardFromStandardElements( previewCardElem )
	HidePreviewCard( file.burnCardPreviewCard )

	uiGlobal.navigateBackCallbacks[ menu ] <- BurnCardsNavigateBack

	// new burn card stuff
	file.NewBurnCardDialog	<- menu.GetChild( "NewBurnCardDialog" )
	file.NewBurnCardTitle <- menu.GetChild( "NewBurnCardTitle" )

	local buttons = GetElementsByClassname( menu, "BurnCardPickCardClass" )
	local panels = GetElementsByClassname( menu, "BurnCardPickCardPanelClass" )

	file.onDeckBurnCardSlot <- null // for client prediction

	file.burnCardButtons <- []
	file.burnCardButtons.resize( buttons.len() )
	foreach ( index, button in buttons )
	{
		local table = {}
		table.button <- button
		table.active <- true

		table.button.SetText( "" )

		button.SetParentMenu( menu )
		local buttonID = button.GetScriptID().tointeger()
		button.loadoutID = buttonID
		button.AddEventHandler( UIE_GET_FOCUS, Bind( OnPickCard_Focus ) )
		button.AddEventHandler( UIE_CLICK, Bind( OnPickCard_Click ) )

		CreateBurnCardPanel( table, panels[ button.loadoutID ] )
		file.burnCardButtons[ buttonID ] = table
	}

	UpdatePickCard()
}

function SCB_RefreshBurnCardSelector()
{
	InstantUpdatePickCard()
}
Globalize( SCB_RefreshBurnCardSelector )

function BurnCardsNavigateBack()
{
	if ( uiGlobal.loadoutSelectionFinished )
		return true

	if ( GetConVarString( "mp_gamemode" ) != "ps" ) //JFS. For R2 maybe try checking against Riff settings to see if Titans are disabled or not.
		AdvanceMenu( GetMenu( "TitanLoadoutsMenu" ) )
	else
		AdvanceMenu( GetMenu( "PilotLoadoutsMenu" ) )
}

function OnOpenMenu_BurnCardsPickCard()
{
	InstantUpdatePickCard()

	foreach ( index, table in file.burnCardButtons )
	{
		local button = table.button
		if ( button.IsEnabled() )
		{
			button.SetFocused()
			break
		}
	}

	file.onOpenTime = Time()
	if ( !HasActiveBurnCard() && !ShouldEnableBurnCardMenu() )
	{
		CloseAllMenus()
		return
	}

	if ( !file.bindings )
	{
		file.bindings = true
		RegisterButtonPressedCallback( BUTTON_X, BurnCardPickCard_SkipClear )
		//RegisterButtonPressedCallback( BUTTON_Y, BurnCardPickCard_ExitMenu )
		//RegisterButtonPressedCallback( KEY_B, BurnCardPickCard_ExitMenu )
	}

	//file.onDeckBurnCardSlot = GetBurnCardOnDeckIndex()

	UpdateOnDeckCard()
	UpdatePickCard()

	local onDeckIndex = GetBurnCardOnDeckIndex()
	if ( onDeckIndex != null )
	{
		file.burnCardButtons[ onDeckIndex ].button.SetFocused()
	}

	//printt( "	file.onDeckBurnCardSlot " + file.onDeckBurnCardSlot  )
	//if ( file.onDeckBurnCardSlot != null )
	//{
	//	file.burnCardButtons[ file.onDeckBurnCardSlot ].button.SetFocused()
	//	printt( "set focused " + file.onDeckBurnCardSlot )
	//}
}

function OnCloseMenu_BurnCardPickCard()
{
	if ( file.bindings )
	{
		file.bindings = false
		DeregisterButtonPressedCallback( BUTTON_X, BurnCardPickCard_SkipClear )
		//DeregisterButtonPressedCallback( BUTTON_Y, BurnCardPickCard_ExitMenu )
		//DeregisterButtonPressedCallback( KEY_B, BurnCardPickCard_ExitMenu )
	}

	if ( IsConnected() )
		RunClientScript1( "SetRespawnSelectIgnoreTime", false, 0.1 )
}

function BurnCardPickCard_ExitMenu( _ )
{
	if ( Time() - file.onOpenTime < 0.05 )
		return

	if ( uiGlobal.activeMenu != file.menu )
		return

	if ( IsConnected() )
		RunClientScript1( "SetRespawnSelectIgnoreTime", false, 0.1 )

	CloseTopMenu()
}

function CreateMenuBurnCard( card )
{
	file[ card ] <- {}
	file[ card ].active <- true
	local elemPanel = file.menu.GetChild( card )
	CreateBurnCardPanel( file[ card ], elemPanel )
	HideBurnCard( file[ card ] )
}

function OnPickCardNone_Focus( button )
{
	UpdatePickCard()
}

function OnPickCardNone_Click( button )
{
	SetLoadoutSelectionFinished()
	CloseAllMenus()
	ClientCommand( "BCDeActivateCard" )
	SetOnDeckCardFromSlot( null )
}

function OnPickCard_Focus( button )
{
	UpdatePickCard()
}

function OnPickCard_Click( button )
{
	local cardRef = GetActiveBurnCardFromSlot( button.loadoutID )
	if ( cardRef == null )
		return

	SetLoadoutSelectionFinished()
	CloseAllMenus()
	SendPickToServer( button )
}

function SendPickToServer( button )
{
	if ( file.onDeckBurnCardSlot == null || file.onDeckBurnCardSlot != button.loadoutID )
	{
		local cardRef = GetActiveBurnCardFromSlot( button.loadoutID )
		if ( cardRef != null )
		{
			ClientCommand( "BCActivateCard " + button.loadoutID + " notoggle" )

			SetOnDeckCardFromSlot( button.loadoutID )
			return
		}
	}
}

function UpdatePickCard()
{
	thread DelayedUpdatePickCard()
}

function GetFocusedCardTable()
{
	for ( local i = 0; i < GetMaxActiveBurnCards(); i++ )
	{
		local table = file.burnCardButtons[ i ]

		local cardRef = GetActiveBurnCardFromSlot( i )

		if ( cardRef == null )
			continue

		if ( table.button.IsFocused() )
			return table
	}

	return null
}

function UpdateOnDeckCard()
{
	file.onDeckBurnCardSlot = GetBurnCardOnDeckIndex()
}

function SetOnDeckCardFromSlot( slot )
{
	file.onDeckBurnCardSlot = slot
}

function DelayedUpdatePickCard()
{
	WaitEndFrame()
	if ( !IsConnected() )
		return

	InstantUpdatePickCard()
}



function InstantUpdatePickCard()
{
	if ( IsLobby() )
		return
	UpdateFooterButtons()

	HidePreviewCard( file.burnCardPreviewCard )

	local onDeckSlotID = GetBurnCardOnDeckIndex()	
	local activeSlotID = GetBurnCardActiveSlotID()
	local activeCardRef = UIGetActiveBurnCard()
	local max = GetMaxActiveBurnCards()
	for ( local slotID = 0; slotID < INGAME_BURN_CARDS; slotID++ )
	{
		local elemTable = file.burnCardButtons[ slotID ]
		elemTable.BurnCardMid_BottomText.Hide()

		local cardRef = GetActiveBurnCardFromSlot( slotID )
		local isSelected = elemTable.button.IsFocused()

		local stashedCardRef = GetStashedCardRef( slotID )
		local stashedCardTime = GetStashedCardTime( slotID )

		UpdateActiveSlotCardImage( elemTable, isSelected, activeSlotID, activeCardRef, slotID, max, cardRef )

		UpdateActiveSlotBurnCardBottomText( elemTable, isSelected, slotID, onDeckSlotID, activeSlotID, cardRef, stashedCardRef, stashedCardTime )
	}

//	local onDeckIndex = GetBurnCardOnDeckIndex()
//	if ( onDeckIndex != null )
//	{
//		local cardRef = GetActiveBurnCardFromSlot( onDeckIndex )
//		if ( cardRef != null )
//		{
//			local elemTable = file.burnCardButtons[ onDeckIndex ]
//			elemTable.BurnCardMid_BottomText.SetText( "#BC_SELECTED" )
//			elemTable.BurnCardMid_BottomText.Show()
//		}
//	}
}

function UpdateActiveSlotCardImage( elemTable, isSelected, activeSlotID, activeCardRef, slotID, max, cardRef )
{
	if ( slotID >= max )
	{
		DrawCardSlot( elemTable, isSelected, false )
		elemTable.slotText.SetText( "#BC_LOCKED_SLOT" )

		if ( isSelected )
		{
			HidePreviewCard( file.burnCardPreviewCard )
		}

		elemTable.button.SetEnabled( false )

		return
	}

	if ( cardRef == null )
	{
		DrawCardSlot( elemTable, isSelected, false )

		if ( isSelected )
		{
			HidePreviewCard( file.burnCardPreviewCard )
		}

		elemTable.button.SetEnabled( false )

		if ( slotID == activeSlotID && activeCardRef != null )
			DrawBurnCard( elemTable, isSelected, true, activeCardRef )

		return
	}

	DrawBurnCard( elemTable, isSelected, true, cardRef )
	elemTable.button.SetEnabled( true )

	if ( isSelected )
	{
		ShowPreviewCard( file.burnCardPreviewCard )
		SetPreviewCard( cardRef, file.burnCardPreviewCard )
	}
}

function HasActiveBurnCard()
{
	local foundCard = false
	for ( local i = 0; i < GetMaxActiveBurnCards(); i++ )
	{
		local cardRef = GetActiveBurnCardFromSlot( i )

		if ( cardRef != null )
			return true
	}

	return false
}

function BurnCards_PickCard_Clear( button )
{
	if ( uiGlobal.activeMenu != file.menu )
		return
	ClientCommand( "BCDeActivateCard" )
	CloseAllMenus()
}

function BurnCards_PickCard_Skip( button )
{
	if ( uiGlobal.activeMenu != file.menu )
		return
	SetLoadoutSelectionFinished()
	CloseAllMenus()
}

function BurnCards_PickCard_FooterData( footerData )
{
	footerData.gamepad.append( { label = "#A_BUTTON_SELECT" } )

	footerData.gamepad.append( { label = "#B_BUTTON_BACK" } )
	footerData.pc.append( { label = "#BACK", func = PCBackButton_Activate } )

	if ( GetBurnCardOnDeckIndex() != null )
	{
		footerData.gamepad.append( { label = "#X_BUTTON_CLEAR" } )
		local func = Bind( BurnCards_PickCard_Clear )
		footerData.pc.append( { label = "#CLEAR_SELECTION", func = func } )
	}
	else
	{
		footerData.gamepad.append( { label = "#X_BUTTON_SKIP" } )
		local func = Bind( BurnCards_PickCard_Skip )
		footerData.pc.append( { label = "#SKIP", func = func } )
	}
}
Globalize( BurnCards_PickCard_FooterData )

function BurnCardPickCard_SkipClear( button )
{
	if ( !IsFullyConnected() )
		return

	if ( GetBurnCardOnDeckIndex() != null )
		BurnCards_PickCard_Clear( button )
	else
		BurnCards_PickCard_Skip( button )
}

function ServerCallback_OpenBurnCardMenu()
{
	if ( !IsConnected() )
		return

	local menu = GetMenu( "BurnCards_pickcard" )
//	if ( uiGlobal.activeMenu == menu )
//		CloseTopMenu()
//	else
	AdvanceMenu( menu )
}
Globalize( ServerCallback_OpenBurnCardMenu )
