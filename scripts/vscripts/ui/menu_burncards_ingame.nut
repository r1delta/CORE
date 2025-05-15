
function main()
{
	printt("MENU BURN CARDS IN GAME")
	Globalize( InitBurnCardInGameMenu )
	Globalize( OnCloseMenu_BurnCardsInGame )
	Globalize( OnOpenMenu_BurnCardsInGame )
	Globalize( ShowCoins )

	RegisterSignal( "StopBurnCardAnalogInput" )
	RegisterSignal( "ClosedBurnCardMenu" )

	file.bindings <- false

	RegisterSignal( "StopChangingPages" )
	file.scale <- 0
	file.nextMoveTime <- 0
	file.nextMoveTimeScale <- 0
	file.bindings <- false
	file.digitalInput <- 0
	file.openedMenuTime <- 0
	file.allButtons <- []
	file.lastCoinCount <- -1
}

function InitBurnCardInGameMenu( menu )
{
	local coinsPanel 	 = menu.GetChild( "PlayerCoinsPanel" )
	local cardStashPanel = menu.GetChild( "BurnCardStashPanel" )

	file.PlayerCoinAmountLabel 	 		<-	coinsPanel.GetChild( "PlayerCoinAmountLabel" )
//	file.CoinsAddedPopupText 	 		<-	coinsPanel.GetChild( "CoinsAddedPopupText" )
	file.BurnCardStashStatus 			<-	cardStashPanel.GetChild( "BurnCardStashStatus" )
	file.BurnCardStashStatus.s.lastBurnCardStashCount <- 0
	file.BurnCardStashStatus_Icon 		<-	cardStashPanel.GetChild( "BurnCardStashStatus_Icon" )

	// Hidden by default for reuse in other menus, so show it
	file.BurnCardStashStatus.Show()
  	file.BurnCardStashStatus_Icon.Show()

  	file.Label_BurnCardsAutofill <- menu.GetChild( "Label_BurnCardsAutofill" )
  	file.Label_BurnCardsAutofill.EnableKeyBindingIcons()

  	file.Image_BurnCardsAutofill_chicklet <- menu.GetChild( "Image_BurnCardsAutofill_chicklet" )

	file.Btn_BurnCardsAutofill		<- menu.GetChild( "Btn_BurnCardsAutofill" )
	file.Btn_BurnCardsAutofill.AddEventHandler( UIE_CLICK, Bind( OnClick_Btn_BurnCardsAutofill ) )

	file.autofillClassnameElements <- GetElementsByClassname( menu, "autofillClassname" )

	if ( !IsBlackMarketUnlocked() )
		coinsPanel.Hide()

	UpdateBurnCardDeckStatus( file.BurnCardStashStatus, 0 )

	file.menu <- menu
	file.currentPile <- 0

	uiGlobal.navigateBackCallbacks[ menu ] <- Bind( BurnCardsInGameNavigateBack )
	level.BurnCardsMenuTitle <- menu.GetChild( "BurnCardsMenuTitle" )
	file.nextMoveTime <- 0
	file.nextMoveBuffer <- 0
	file.moveStartTime <- 0
	file.subEnter <- false

	file.lastTriggerTimePressed <- []
	file.lastTriggerTimePressed.append( 0 )
	file.lastTriggerTimePressed.append( 0 )
	file.lastTriggerTimeReleased <- []
	file.lastTriggerTimeReleased.append( 0 )
	file.lastTriggerTimeReleased.append( 0 )
	file.triggerIsPressed <- []
	file.triggerIsPressed.append( false )
	file.triggerIsPressed.append( false )
	file.triggerPressedStage <- 0

	local buttons = GetElementsByClassname( menu, "BurnCardPickSlotClass" )
	file.burnCardSlotButtons <- []

	foreach ( index, button in buttons )
	{
		local table = {}
		table.button <- button
		table.button.SetText( "" )

		button.SetParentMenu( menu )
		local buttonID = button.GetScriptID().tointeger()
		button.loadoutID = buttonID

		file.burnCardSlotButtons.append( table )

		button.AddEventHandler( UIE_GET_FOCUS, Bind( OnBurnCardSlotButton_GetFocus ) )
	}

	//button.AddEventHandler( UIE_GET_FOCUS, Bind( OnStoredCenter_GetFocus ) )
	//button.AddEventHandler( UIE_LOSE_FOCUS, Bind( OnStoredCenter_LoseFocus ) )
	//button.AddEventHandler( UIE_CLICK, Bind( OnStoredCenter_Click ) )

	local buttons = GetElementsByClassname( menu, "BurnCardCenterButtonClass" )
	file.burnCardCenterButtons <- []

	foreach ( button in buttons )
	{
		local table = {}
		table.button <- button
		table.button.SetText( "" )

		local buttonID = button.GetScriptID().tointeger()
		button.loadoutID = buttonID

		button.SetParentMenu( menu )

		file.allButtons.append( button )

		file.burnCardCenterButtons.append( table )
	}


	//file.focusButton <- menu.GetChild( "focusButton" )

	//local buttons = GetElementsByClassname( menu, "BurnCardPickScrollClass" )
    //
	//foreach ( index, button in buttons )
	//{
	//	local table = {}
	//	table.button <- button
	//	table.button.SetText( "" )
	//
	//	button.SetParentMenu( menu )
	//	local buttonID = button.GetScriptID().tointeger()
	//	button.loadoutID = buttonID
	//	button.AddEventHandler( UIE_GET_FOCUS, Bind( OnStoredSlot_GetFocus ) )
	//	//button.AddEventHandler( UIE_LOSE_FOCUS, Bind( OnStoredSlot_LoseFocus ) )
	//	button.AddEventHandler( UIE_CLICK, Bind( OnStoredSlot_Click ) )
	//	file.allButtons.append( button )
	//}
}


function OnCloseMenu_BurnCardsInGame()
{
	Signal( level, "StopBurnCardAnalogInput" )
	Signal( level, "ClosedBurnCardMenu" )
	file.digitalInput = 0

	if ( file.bindings )
	{
		file.bindings = false
		Signal( file, "StopChangingPages" )

		DeregisterButtonPressedCallback( BUTTON_TRIGGER_LEFT, BurnCardPressedTriggerLeftStart )
		DeregisterButtonReleasedCallback( BUTTON_TRIGGER_LEFT, BurnCardPressedTriggerLeftEnd )
		DeregisterButtonPressedCallback( BUTTON_TRIGGER_RIGHT, BurnCardPressedTriggerRightStart )
		DeregisterButtonReleasedCallback( BUTTON_TRIGGER_RIGHT, BurnCardPressedTriggerRightEnd )
		DeregisterButtonPressedCallback( BUTTON_Y, BurnCardAutoFill )
		DeregisterButtonPressedCallback( BUTTON_X, BurnCardPushCard )
		DeregisterButtonPressedCallback( BUTTON_A, BurnCardSelectCard )
		DeregisterButtonPressedCallback( KEY_ENTER, BurnCardSelectCard )
		DeregisterButtonPressedCallback( KEY_SPACE, BurnCardSelectCard )
		DeregisterButtonReleasedCallback( BUTTON_A, BurnCardReleasedA )
		DeregisterButtonPressedCallback( BUTTON_B, BurnCardBack )
		DeregisterButtonPressedCallback( KEY_ESCAPE, BurnCardBack )
		DeregisterButtonPressedCallback( MOUSE_LEFT, BurnCardMouseDown )
		DeregisterButtonPressedCallback( MOUSE_MIDDLE, BurnCardZoomStart )
		DeregisterButtonReleasedCallback( MOUSE_MIDDLE, BurnCardZoomEnd )
		DeregisterButtonReleasedCallback( MOUSE_LEFT, BurnCardMouseUp )
		DeregisterButtonPressedCallback( MOUSE_RIGHT, BurnCardMouseDownRIGHT )
		DeregisterButtonPressedCallback( MOUSE_WHEEL_UP, BurnCardWheelUp )
		DeregisterButtonPressedCallback( MOUSE_WHEEL_DOWN, BurnCardWheelDown )
		DeregisterButtonPressedCallback( BUTTON_DPAD_RIGHT, BurnCardStartRight )
		DeregisterButtonPressedCallback( KEY_RIGHT, BurnCardStartRight )
		DeregisterButtonPressedCallback( BUTTON_DPAD_LEFT, BurnCardStartLeft )
		DeregisterButtonPressedCallback( KEY_LEFT, BurnCardStartLeft )
		DeregisterButtonReleasedCallback( BUTTON_DPAD_RIGHT, BurnCardEndRight )
		DeregisterButtonReleasedCallback( KEY_RIGHT, BurnCardEndRight )
		DeregisterButtonReleasedCallback( BUTTON_DPAD_LEFT, BurnCardEndLeft )
		DeregisterButtonReleasedCallback( KEY_LEFT, BurnCardEndLeft )
		DeregisterButtonPressedCallback( BUTTON_SHOULDER_RIGHT, BurnCardPressedRightMany )
		DeregisterButtonPressedCallback( BUTTON_SHOULDER_LEFT, BurnCardPressedLeftMany )
	}
}

function BurnCardAutoFill( button )
{
	if ( !IsFullyConnected() )
		return

	if ( UsingAlternateBurnCardPersistence() ) // TODO: should maybe be cued on private match
		return

	ToggleAutoFill()
}

function BurnCardPushCard( button )
{
	if ( file.menu == uiGlobal.activeMenu )
	{
		RunClientBurnCardCommand( "BurnCardPushCard" )
	}
}

function RemoveBlurDelayed()
{
	WaitEndFrame()
	SetBlurEnabled( false )
}


function OnOpenMenu_BurnCardsInGame( menu )
{
	if ( !IsFullyConnected() )
		return

	UpdateBurnCardDeckStatus( file.BurnCardStashStatus, 0 )
	UpdateAutofill()

	file.BurnCardStashStatus.s.lastBurnCardStashCount = GetTotalBurnCards()
	Signal( level, "StopBurnCardAnalogInput" )
	file.digitalInput = 0

	if ( !file.bindings )
	{
		file.bindings = true
		file.openedMenuTime = Time()
		file.bindings = true

		RegisterButtonPressedCallback( BUTTON_TRIGGER_LEFT, BurnCardPressedTriggerLeftStart )
		RegisterButtonReleasedCallback( BUTTON_TRIGGER_LEFT, BurnCardPressedTriggerLeftEnd )
		RegisterButtonPressedCallback( BUTTON_TRIGGER_RIGHT, BurnCardPressedTriggerRightStart )
		RegisterButtonReleasedCallback( BUTTON_TRIGGER_RIGHT, BurnCardPressedTriggerRightEnd )
		RegisterButtonPressedCallback( BUTTON_Y, BurnCardAutoFill )
		RegisterButtonPressedCallback( BUTTON_X, BurnCardPushCard )
		RegisterButtonPressedCallback( BUTTON_A, BurnCardSelectCard )
		RegisterButtonPressedCallback( KEY_ENTER, BurnCardSelectCard )
		RegisterButtonPressedCallback( KEY_SPACE, BurnCardSelectCard )
		RegisterButtonReleasedCallback( BUTTON_A, BurnCardReleasedA )
		RegisterButtonPressedCallback( BUTTON_B, BurnCardBack )
		RegisterButtonPressedCallback( KEY_ESCAPE, BurnCardBack )
		RegisterButtonPressedCallback( MOUSE_LEFT, BurnCardMouseDown )
		RegisterButtonPressedCallback( MOUSE_MIDDLE, BurnCardZoomStart )
		RegisterButtonReleasedCallback( MOUSE_MIDDLE, BurnCardZoomEnd )
		RegisterButtonReleasedCallback( MOUSE_LEFT, BurnCardMouseUp )
		RegisterButtonPressedCallback( MOUSE_RIGHT, BurnCardMouseDownRIGHT )
		RegisterButtonPressedCallback( MOUSE_WHEEL_UP, BurnCardWheelUp )
		RegisterButtonPressedCallback( MOUSE_WHEEL_DOWN, BurnCardWheelDown )
		RegisterButtonPressedCallback( BUTTON_DPAD_RIGHT, BurnCardStartRight )
		RegisterButtonPressedCallback( KEY_RIGHT, BurnCardStartRight )
		RegisterButtonPressedCallback( BUTTON_DPAD_LEFT, BurnCardStartLeft )
		RegisterButtonPressedCallback( KEY_LEFT, BurnCardStartLeft )
		RegisterButtonReleasedCallback( BUTTON_DPAD_RIGHT, BurnCardEndRight )
		RegisterButtonReleasedCallback( KEY_RIGHT, BurnCardEndRight )
		RegisterButtonReleasedCallback( BUTTON_DPAD_LEFT, BurnCardEndLeft )
		RegisterButtonReleasedCallback( KEY_LEFT, BurnCardEndLeft )
		RegisterButtonPressedCallback( BUTTON_SHOULDER_RIGHT, BurnCardPressedRightMany )
		RegisterButtonPressedCallback( BUTTON_SHOULDER_LEFT, BurnCardPressedLeftMany )

		thread FakeAnalogMenuInput( GamepadStickXAxisInput )
		thread FakeAnalogMenuInput( Bind( GetKeyboardInput ) )
	}

	//menu.SetFocused()
	thread RemoveBlurDelayed()

	if ( IsLobby() )
		RunClientScript0( "ThreadOpenedBurncardMenu", false )

	local coinCount = GetPersistentVar( "bm.coinCount" )
	file.PlayerCoinAmountLabel.SetText( "#CASH_AMOUNT_LABEL", coinCount )
	file.lastCoinCount = coinCount
}


function ResetMoveTime()
{
	file.nextMoveBuffer = 0.4
	file.nextMoveTime = Time() + file.nextMoveBuffer
	file.moveStartTime = Time()
}
Globalize( ResetMoveTime )


function FakeAnalogMenuInput( inputFunc )
{
	EndSignal( level, "StopBurnCardAnalogInput" )
	local val
	local heldDirection = 0
	//local heldDirectionY = 0

	local odd = true

	for ( ;; )
	{
		wait 0

		if ( !CanRunClientScript() )
			continue

		//if ( !file.inSubMenu )
		//	continue
		val = inputFunc()

		if ( val < -0.5 )
		{
			if ( heldDirection > -1 )
			{
				RunClientBurnCardCommand( "BurnCardPressedLeft" )
				heldDirection = -1
				ResetMoveTime()
			}
		}
		else if ( val > 0.5 )
		{
			if ( heldDirection < 1 )
			{
				RunClientBurnCardCommand( "BurnCardPressedRight" )
				heldDirection = 1
				ResetMoveTime()
			}
		}
		else
		{
			heldDirection = 0
		}

		if ( heldDirection != 0 )
		{
			if ( Time() > file.nextMoveTime )
			{
				if ( heldDirection == 1 )
					RunClientBurnCardCommand( "BurnCardPressedRight" )
				else
					RunClientBurnCardCommand( "BurnCardPressedLeft" )

				file.nextMoveBuffer *= 0.4
				local moveTime = Time() - file.moveStartTime
				local minMoveTime = GraphCapped( moveTime, 0, 2.5, 0.05, 0.005 )
				if ( file.nextMoveBuffer < minMoveTime )
					file.nextMoveBuffer = minMoveTime

				file.nextMoveTime = Time() + file.nextMoveBuffer
			}
		}

		odd = !odd
	}
}
Globalize( FakeAnalogMenuInput )

function RunClientBurnCardCommand( cmd, parm = null )
{
	if ( !IsFullyConnected() )
		return

	if ( !IsLobby() )
		return

	if ( CanRunClientScript() )
	{
		if ( parm == null )
			RunClientScript0( cmd, true )
		else
			RunClientScript1( cmd, true, parm )
	}
}
Globalize( RunClientBurnCardCommand )


function EditBurnCardText( msg, num = null )
{
	level.BurnCardsMenuTitle.SetText( msg, num )
}
Globalize( EditBurnCardText )




function OnStoredSlot_GetFocus( button )
{
	file.scale = button.loadoutID
	file.nextMoveTime -= 0.1
	file.nextMoveTimeScale = Graph( abs( file.scale ), 1, 15, 0.8, 0 )
	//file.centerButton.SetFocused()
}

function OnStoredSlot_LoseFocus( button )
{
	file.scale = 0
}

function OnStoredSlot_Click( button )
{
	RunClientBurnCardCommand( "BurnCardSelectCard" )

//	thread NewButtonCommand( button.loadoutID )
//}
//
}

function NewButtonCommand( loadoutID )
{
	if ( loadoutID == 0 )
	{
		return
	}

	Signal( file, "StopChangingPages" )
	EndSignal( file, "StopChangingPages" )
	local command
	if ( loadoutID < 0 )
		command = "BurnCardPressedLeft"
	else
		command = "BurnCardPressedRight"

//	file.centerButton.SetFocused()

	for ( local i = 0; i < abs( loadoutID ); i++ )
	{
		if ( !IsFullyConnected() )
			break
		RunClientBurnCardCommand( command )
		wait 0.1
	}
}

function OnBurnCardSlotButton_GetFocus( button )
{
	RunClientBurnCardCommand( "BurnCardSetActiveSlot", button.loadoutID )
}

function OnStoredCenter_Click( button )
{
	RunClientBurnCardCommand( "BurnCardSelectCard" )
}

function ChangeBurnCardPage()
{
	EndSignal( file, "StopChangingPages" )
	local nextMoveTime
	for ( ;; )
	{
		if ( Time() > file.nextMoveTime )
		{
			if ( file.scale > 0 )
				RunClientBurnCardCommand( "BurnCardPressedRight" )
			else
			if ( file.scale < 0 )
				RunClientBurnCardCommand( "BurnCardPressedLeft" )

			file.nextMoveTime = Time() + file.nextMoveTimeScale
		}

		wait 0
	}
}

function StopBurnCardPageChange( scale )
{
}

function GetMouseInputDirection()
{
	return file.scale
}

function BurnCardPushCard           ( player )
{
	RunClientBurnCardCommand( "BurnCardPushCard" )
}

function BurnCardSelectCard         ( player )
{
	if ( Time() - file.openedMenuTime <= 0.1 )
		return

	RunClientBurnCardCommand( "BurnCardSelectCard" )
}

function BurnCardReleasedA          ( player )
{
	RunClientBurnCardCommand( "BurnCardReleasedA" )
}

function BurnCardWheelUp( player )
{
	RunClientBurnCardCommand( "BurnCardWheelUp" )
}

function BurnCardWheelDown( player )
{
	RunClientBurnCardCommand( "BurnCardWheelDown" )
}

function BurnCardPressedRight( player )
{
	RunClientBurnCardCommand( "BurnCardPressedRight" )
}

function BurnCardPressedLeft( player )
{
	RunClientBurnCardCommand( "BurnCardPressedLeft" )
}

function BurnCardPressedUp( player )
{
	RunClientBurnCardCommand( "BurnCardPressedUp" )
}

function BurnCardBack( player )
{
	RunClientBurnCardCommand( "BurnCardBack" )
}

function BurnCardPressedRightMany   ( player )
{
	RunClientBurnCardCommand( "BurnCardPressedRightMany" )
}

function BurnCardPressedLeftMany    ( player )
{
	RunClientBurnCardCommand( "BurnCardPressedLeftMany" )
}

function BurnCardMouseDownRIGHT( player )
{
	file.digitalInput = 0

	local focus = GetFocus()
	foreach ( table in file.burnCardSlotButtons )
	{
		if ( table.button == focus )
		{
			RunClientBurnCardCommand( "BurnCardPressedActiveButtonBack", table.button.loadoutID )
			return
		}
	}
}

function BurnCardMouseDown( player )
{
	file.digitalInput = 0

	if ( Time() - file.openedMenuTime <= 0.1 )
		return

	RunClientBurnCardCommand( "BurnCardMouseDown" )

	local focus = GetFocus()
	foreach ( table in file.burnCardSlotButtons )
	{
		if ( table.button == focus )
		{
			RunClientBurnCardCommand( "BurnCardPressedActiveButton", table.button.loadoutID )
			return
		}
	}

	foreach ( table in file.burnCardCenterButtons )
	{
		if ( table.button == focus )
		{
			file.digitalInput = table.button.loadoutID
			if ( file.digitalInput == 0 )
			{
				RunClientBurnCardCommand( "BurnCardMouseClickDeckCard" )
			}
			return
		}
	}
}

function BurnCardMouseUp( player )
{
	file.digitalInput = 0


//	foreach ( button in file.allButtons	)
//	{
//		if ( button == focus )
//		{
//			thread NewButtonCommand( button.loadoutID )
//			return
//		}
//	}
}

function BurnCardEndLeft( player )
{
	file.digitalInput = 0
}

function BurnCardStartLeft( player )
{
	file.digitalInput = -1
}

function BurnCardEndRight( player )
{
	file.digitalInput = 0
}

function BurnCardStartRight( player )
{
	file.digitalInput = 1
}

function GetKeyboardInput()
{
	return file.digitalInput
}

function GamepadStickXAxisInput()
{
	local inputX = InputGetAxis(0)
	local inputY = InputGetAxis(2)
	if ( fabs( inputX ) > fabs( inputY ) )
		return inputX
	return inputY
}

function BurnCards_InGame_FooterData( footerData )
{
	if ( !IsFullyConnected() )
		return

	local progress = GetPersistentVar( "burncardStoryProgress" )
	if ( UsingAlternateBurnCardPersistence() || IsPlayerEverythingUnlocked() )
		progress = BURNCARD_STORY_PROGRESS_COMPLETE

	if ( progress == BURNCARD_STORY_PROGRESS_INTRO )
	{
		footerData.gamepad.append( { label = "#B_BUTTON_BACK" } )
		footerData.pc.append( { label = "#BACK", func = Bind( CloseTopMenuButton ) }  )
		thread TrackStoryProgressFooterChange()
		return
	}

	if ( GetTotalBurnCards() <= GetMaxStoredBurnCards() )
	{
		footerData.gamepad.append( { label = "#BURNCARD_EQUIP" } )
		footerData.gamepad.append( { label = "#B_BUTTON_BACK" } )
		footerData.gamepad.append( { label = "#BURNCARD_PUT_BACK" } )
	}
	else
	{
		footerData.gamepad.append( { label = "#B_BUTTON_BACK" } )
	}

	footerData.pc.append( { label = "#BACK", func = Bind( CloseTopMenuButton ) }  )

	if ( UsingAlternateBurnCardPersistence() )
		return

	local deckSize = GetBurnCardDeck().len()
	if ( deckSize > 0 )
	{
		if ( IsBlackMarketUnlocked() )
		{
			footerData.gamepad.append( { label = "#BURNCARD_SELL_GAMEPAD" } )
			footerData.pc.append( { label = "#BURNCARD_SELL_MOUSE", 	func = Bind( BurncardButton_Discard )	} )
		}
		else
		{
			footerData.gamepad.append( { label = "#BURNCARD_DISCARD_GAMEPAD" } )
			footerData.pc.append( { label = "#BURNCARD_DISCARD_MOUSE", 	func = Bind( BurncardButton_Discard )	} )
		}
	}
}
Globalize( BurnCards_InGame_FooterData )

function TrackStoryProgressFooterChange()
{
	EndSignal( level, "ClosedBurnCardMenu" )
	local progress
	for ( ;; )
	{
		if ( IsFullyConnected() )
		{
			progress = GetPersistentVar( "burncardStoryProgress" )
			if ( UsingAlternateBurnCardPersistence() || IsPlayerEverythingUnlocked() )
				progress = BURNCARD_STORY_PROGRESS_COMPLETE

			if ( progress > BURNCARD_STORY_PROGRESS_INTRO )
				break
		}
		wait 0
	}

	UpdateFooterButtons()
	UpdateAutofill()
}

function BurncardButton_Discard( button )
{
	if ( UsingAlternateBurnCardPersistence() )
		return

	RunClientBurnCardCommand( "BurnCardDiscard" )
}

function CloseTopMenuButton( button )
{
	CloseTopMenu()
}

function StartTriggerPress( trig )
{
	file.triggerIsPressed[ trig ] = true
	file.lastTriggerTimePressed[ trig ] = Time()
	local dif = fabs( file.lastTriggerTimePressed[ 0 ] - file.lastTriggerTimePressed[ 1 ] )
	if ( dif < 0.1 )
		file.triggerPressedStage = 1
	else
		file.triggerPressedStage = 0

	if ( trig == 1 )
		thread DelayedZoomStart()
}

function DelayedZoomStart()
{
	if ( file.triggerIsPressed[ 0 ] == false )
	{
		wait 0.1
		WaitEndFrame()
	}

	// discarding?
	if ( fabs( file.lastTriggerTimePressed[ 0 ] - Time() ) < 0.1 )
		return

	RunClientBurnCardCommand( "BurnCardPressedZoomStart" )
}

function EndTriggerPress( trig )
{
	file.triggerIsPressed[ trig ] = false
	if ( file.triggerPressedStage != 1 )
		return

	file.lastTriggerTimeReleased[ trig ] = Time()
	local dif = fabs( file.lastTriggerTimeReleased[ 0 ] - file.lastTriggerTimeReleased[ 1 ] )
	if ( dif < 0.1 )
		BurncardButton_Discard( null )
}

function BurnCardZoomStart( button )
{
	RunClientBurnCardCommand( "BurnCardPressedZoomStart" )
}

function BurnCardZoomEnd( button )
{
	RunClientBurnCardCommand( "BurnCardPressedZoomEnd" )
}

function BurnCardPressedTriggerLeftStart( button )
{
	StartTriggerPress( 1 )
}

function BurnCardPressedTriggerLeftEnd( button )
{
	RunClientBurnCardCommand( "BurnCardPressedZoomEnd" )

	EndTriggerPress( 1 )
}

function BurnCardPressedTriggerRightStart( button )
{
	StartTriggerPress( 0 )
}

function BurnCardPressedTriggerRightEnd( button )
{
	EndTriggerPress( 0 )
}

function ServerCallback_ExitBurnCardMenu()
{
	if ( !IsConnected() )
		return

	local menu = GetMenu( "BurnCards_InGame" )
	if ( uiGlobal.activeMenu != menu )
		return

	CloseTopMenu()
}
Globalize( ServerCallback_ExitBurnCardMenu )


function BurnCardsInGameNavigateBack()
{
	if ( GetPersistentVar( "currentBurnCardPile" ) == 0 )
		CloseTopMenu()
}


function SCB_UpdateEmptySlots()
{
	UpdateBurnCardDeckStatus( file.BurnCardStashStatus, 0 )
	UpdateAutofill()
	UpdateEditBurnCardButtonText()
}
Globalize( SCB_UpdateEmptySlots )

function SCB_UpdateBCFooter()
{
	UpdateFooterButtons()
}
Globalize( SCB_UpdateBCFooter )

function UpdateEditBurnCardButtonText( buttonOverride = null )
{
	local button = level.BtnEditBurnCards
	printt("UpdateEditBurnCardButtonText")
	if ( buttonOverride != null )
		button = buttonOverride

	//UpdateAvailableStoredBurnCards()
	local cards = GetTotalBurnCards()

	local progress = GetPersistentVar( "burncardStoryProgress" )
	if ( UsingAlternateBurnCardPersistence() || IsPlayerEverythingUnlocked() )
		progress = BURNCARD_STORY_PROGRESS_COMPLETE

	switch ( progress )
	{
		case BURNCARD_STORY_PROGRESS_NONE:
			button.Hide()
			break

		case BURNCARD_STORY_PROGRESS_INTRO:
			button.SetEnabled( true )
			button.Show()
			button.SetNew( true )

			button.SetText( "#BC_YOU_HAVE_MAIL" )
			break

		case BURNCARD_STORY_PROGRESS_COMPLETE:

			button.SetEnabled( true )
			button.Show()
			button.SetNew( false )

			button.ClearPulsate()
			if ( GetTotalBurnCards() > GetMaxStoredBurnCards() )
			{
				button.SetText( "#BC_EXCEEDED_DECK" )
				button.SetNew( true )
				return
			}

			if ( HasNewBurnCards() )
			{
				button.SetNew( true )
			}

			local slots = GetUsableUnusedBurnCardSlots()
			if ( slots == 0 )
			{
				button.SetText( "#BC_CARDS_WITH_COUNT", cards )
			}
			else if ( slots == 1 )
			{
				button.SetText( "#BC_OPEN_SLOT_SINGULAR" )
				//level.BtnEditBurnCards.SetNew( true )
			}
			else
			{
				button.SetText( "#BC_OPEN_SLOT_PLURAL", slots )
				//level.BtnEditBurnCards.SetNew( true )
			}

			break
	}
}
Globalize( UpdateEditBurnCardButtonText )

function GetUsableUnusedBurnCardSlots()
{
	local cards = GetBurnCardDeck().len()
	local slots = GetMaxActiveBurnCards()

	local active = 0
	for ( local i = 0; i < GetMaxActiveBurnCards(); i++ )
	{
		if ( GetActiveBurnCardFromSlot( i ) != null )
			active++
	}

	local unusedSlots = slots - active

	return unusedSlots
}

function SCB_UpdateBC()
{
	UpdateBurnCardDeckStatus( file.BurnCardStashStatus )
	UpdateFooterButtons()
	UpdateAutofill()

	if ( IsBlackMarketUnlocked() )
		UpdateCoinCount()
}
Globalize( SCB_UpdateBC )

function UpdateCoinCount()
{
	local coinCount = GetPersistentVar( "bm.coinCount" )
	if ( file.lastCoinCount == coinCount )
		return

	local menu = GetMenu( "BurnCards_InGame" )
	local lastCoinCount = file.lastCoinCount
 	local countUpDuration = 0.5

	file.lastCoinCount = coinCount

	// Because this menu is always loaded and buying/awarding cards also calls this, only animate if showing
	if ( file.menu == uiGlobal.activeMenu )
	{
		// Flash & tick the coin count
		thread SetTextCountUp( menu, file.PlayerCoinAmountLabel, coinCount, "Shop.CoinNumbersTick", 0.2, null, countUpDuration, "#CASH_AMOUNT_LABEL", lastCoinCount )
		thread FlashElement( menu, file.PlayerCoinAmountLabel, 4, 1.5, 255, 0 )

		// Show popup coin amount that's added to the total
		//local newCoins = max( 0, ( coinCount - lastCoinCount ) )
		//file.CoinsAddedPopupText.SetText(  "#CASH_AMOUNT_LABEL_PLUS", newCoins.tointeger() )
		//thread FancyLabelFadeIn( menu, file.CoinsAddedPopupText, 0, -50, true, 0.25, true )
	}
	else
	{
		file.PlayerCoinAmountLabel.SetText( "#CASH_AMOUNT_LABEL", coinCount )
	}
}

function ShowCoins()
{
	local coinsPanel = file.menu.GetChild( "PlayerCoinsPanel" )
	coinsPanel.Show()
}

function UpdateAutofill( forced = null )
{
	local progress = GetPersistentVar( "burncardStoryProgress" )
	if ( UsingAlternateBurnCardPersistence() || IsPlayerEverythingUnlocked() )
		progress = BURNCARD_STORY_PROGRESS_COMPLETE

	if ( UsingAlternateBurnCardPersistence() )
	{
		foreach ( elem in file.autofillClassnameElements )
		{
			elem.Hide()
		}

		return
	}

	switch ( progress )
	{
		case BURNCARD_STORY_PROGRESS_NONE:
		case BURNCARD_STORY_PROGRESS_INTRO:
			foreach ( elem in file.autofillClassnameElements )
			{
				elem.Hide()
			}
			break

		case BURNCARD_STORY_PROGRESS_COMPLETE:
			foreach ( elem in file.autofillClassnameElements )
			{
				elem.Show()
			}
			break
	}

	if ( forced != null )
	{
		file.Image_BurnCardsAutofill_chicklet.SetVisible( forced )
		return
	}

	local autofill = GetPersistentVar( _GetBurnCardPersPlayerDataPrefix() + ".autofill" )
	file.Image_BurnCardsAutofill_chicklet.SetVisible( autofill )
}

function OnClick_Btn_BurnCardsAutofill( button )
{
	ToggleAutoFill()
}

function ToggleAutoFill()
{
//	if ( GetPersistentVar( "currentBurnCardPile" ) != PILE_DECK )
//		return

	local autofill = GetPersistentVar( _GetBurnCardPersPlayerDataPrefix() + ".autofill" )
	UpdateAutofill( !autofill ) // client prediction
	ClientCommand( "ToggleAutofill" )
}