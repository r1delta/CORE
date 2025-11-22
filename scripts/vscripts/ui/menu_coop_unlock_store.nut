const COOP_MENU_UNLOCKS_PER_ROW = 2
const COOP_MENU_VISIBLE_ROWS = 6
const COOP_MENU_SCROLL_SPEED = 0.15
purchaseHistory <- {}

function main()
{
	Globalize( InitCoopUnlockStoreMenu )
	Globalize( OnOpenMenu_CoopUnlockStore )
	Globalize( OnCloseMenu_CoopUnlockStore )
	Globalize( ServerCallback_OnOpenCoopStore )
	Globalize( ResetCoopPurchaseHistory )
	Globalize( OnCoopUnlockStoreButton_Focused )

	Globalize( OnCoopUnlockStoreButton_Activate )
	Globalize( OnCoopUnlockStoreButton_LostFocus )
	Globalize( OnCoopUnlockButtonsScrollUp )
	Globalize( OnCoopUnlockButtonsScrollDown )
}

function ResetCoopPurchaseHistory()
{
	//Not deleting properly...need to handle when making resume in progress work.
	purchaseHistory = {}
}

function InitCoopUnlockStoreMenu( menu )
{
	uiGlobal.coopStoreScrollState <- 0
	uiGlobal.coopStoreIndex <- 0
}

function SendPickToServer( button )
{
	//ClientCommand( "BCActivateCard " + button.loadoutID + " notoggle" )
}

function OnOpenMenu_CoopUnlockStore()
{
	uiGlobal.coopStoreScrollState = 0
	local menu = GetMenu( "CoopUnlockStore" )
	local buttons = GetElementsByClassname( menu, "CoopSelectClass" )
	buttons[0].ReturnToBasePos()
	local coopStoreTables = GetCoopUnlockStoresTable()
	local unsortedUnlocks = coopStoreTables[ uiGlobal.coopStoreIndex ].unlockRefs

	// Sort the decals for the menu
	local unlockItems = []
	foreach( unlock in unsortedUnlocks )
	{
		unlockItems.append( unlock )
	}

	UpdateCoopUnlockButtons( buttons, unlockItems, 0, true )

	RegisterButtonPressedCallback( MOUSE_WHEEL_UP, OnCoopUnlockButtonsScrollUp )
	RegisterButtonPressedCallback( MOUSE_WHEEL_DOWN, OnCoopUnlockButtonsScrollDown )
}

function OnCloseMenu_CoopUnlockStore()
{
	DeregisterButtonPressedCallback( MOUSE_WHEEL_UP, OnCoopUnlockButtonsScrollUp )
	DeregisterButtonPressedCallback( MOUSE_WHEEL_DOWN, OnCoopUnlockButtonsScrollDown )
}

function OnCoopUnlockStoreButton_Activate( button )
{
	Assert( "ref" in button.s )
	Assert( button.s.ref != null )

	local unlockRef = button.s.ref
	local unlock = GetUnlockFromUnlockRef( unlockRef )

	if ( IsUnlockMaxed( unlock ) || IsUnlockLocked( unlock ) )
		return

	if ( unlockRef in purchaseHistory )
		purchaseHistory[ unlockRef ]++
	else
		purchaseHistory[ unlockRef ] <- 1

	ClientCommand( "TryToActivateCoopUnlock " + unlockRef )
	//Updating UI Point Total, ClientCommand needs to update server total.
	ServerCallback_COOP_AdjustUnlockPointTotal( -1 )

	local buttonID = button.GetScriptID().tointeger()
	local menu = GetMenu( "CoopUnlockStore" )
	local buttons = GetElementsByClassname( menu, "CoopSelectClass" )
	local coopStoreTables = GetCoopUnlockStoresTable()
	local unsortedUnlocks = coopStoreTables[ unlock.store ].unlockRefs
	local unlockItems = []
	foreach( unlock in unsortedUnlocks )
	{
		unlockItems.append( unlock )
	}

	UpdateCoopUnlockButtons( buttons, unlockItems, buttonID, true )

	local headerText = GetUnlockHeaderText( unlock )
	local reqTextElements = GetElementsByClassname( menu, "CoopUnlockReqClass" )
	foreach ( element in reqTextElements )
	{
		if ( headerText )
		{
			element.SetText( GetCoopPointTotal_UI().tostring() + " Unlock Point(s) Available" )//, unlock.unlockCost )
			element.Show()
		}
		else
			element.Hide()
	}

//	local callbackInfo = unlock.purchaseFunctionTable
//	callbackInfo.func.acall( [ callbackInfo.scope ] )
}

function OnCoopUnlockStoreButton_Focused( button )
{
	Assert( "ref" in button.s )
	Assert( button.s.ref != null )

	local menu = GetMenu( "CoopUnlockStore" )
	local buttonID = button.GetScriptID().tointeger()
	local unlockRef = button.s.ref
	local unlock = GetUnlockFromUnlockRef( unlockRef )

	// Update window scrolling if we highlight a decal not in view
	local row = buttonID / COOP_MENU_UNLOCKS_PER_ROW
	local numberOfDecals = GetAllRefsOfType( itemType.TITAN_DECAL ).len()
	local maxRows = floor( ( numberOfDecals + COOP_MENU_UNLOCKS_PER_ROW - 1 ) / COOP_MENU_UNLOCKS_PER_ROW )
	local minScrollState = clamp( row - (COOP_MENU_VISIBLE_ROWS - 1), 0, 4 )
	local maxScrollState = clamp( row, 0, 4 )
	if ( uiGlobal.coopStoreScrollState < minScrollState )
		uiGlobal.coopStoreScrollState = minScrollState
	if ( uiGlobal.coopStoreScrollState > maxScrollState )
		uiGlobal.coopStoreScrollState = maxScrollState
	CoopUnlockButtonsScrollUpdate()

	local elements = GetElementsByClassname( menu, "CoopUnlockNameClass" )
	foreach ( element in elements )
		element.SetText( unlock.name )

	local elements = GetElementsByClassname( menu, "CoopUnlockDescClass" )
	foreach ( element in elements )
		element.SetText( unlock.desc )

	local elements = GetElementsByClassname( menu, "CoopUnlockIconClass" )
	foreach ( element in elements )
		element.SetImage( unlock.image )
	// unlock header, requirements, and progress
	local headerText = GetUnlockHeaderText( unlock )
	local headerElements = GetElementsByClassname( menu, "CoopUnlockReqHeaderClass" )
	local reqTextElements = GetElementsByClassname( menu, "CoopUnlockReqClass" )
	foreach ( element in headerElements )
	{
		if ( headerText )
		{
			element.SetText( "Requires " + unlock.unlockCost + " Unlock Point(s)" )
			element.Show()
		}
		else
			element.Hide()
	}
	foreach ( element in reqTextElements )
	{
		if ( headerText )
		{
			element.SetText( GetCoopPointTotal_UI().tostring() + " Unlock Point(s) Available" )//, unlock.unlockCost )
			element.Show()
		}
		else
			element.Hide()
	}
}

function GetUnlockHeaderText( unlock )
{
	//Need to add custom header text
	return IsUnlockLocked( unlock ) ? "#COOP_UNLOCK_REQUIREMENT_UNLOCKED_HEADER" : "#COOP_UNLOCK_REQUIREMENT_HEADER"
}


function OnCoopUnlockStoreButton_LostFocus( button )
{
	local menu = GetMenu( "CoopUnlockStore" )
	local buttonID = button.GetScriptID().tointeger()
	if ( !( "ref" in button.s ) || button.s.ref == null )
		return

//	ClearRefNew( button.s.ref )

//	UpdateNewElements( button, button.s.ref )
}


function OnCoopUnlockButtonsScrollUp(...)
{
	uiGlobal.coopStoreScrollState--
	if ( uiGlobal.coopStoreScrollState < 0 )
		uiGlobal.coopStoreScrollState = 0

	CoopUnlockButtonsScrollUpdate()
}

function OnCoopUnlockButtonsScrollDown(...)
{
	uiGlobal.coopStoreScrollState++
	if ( uiGlobal.coopStoreScrollState > 4 )
		uiGlobal.coopStoreScrollState = 4

	CoopUnlockButtonsScrollUpdate()
}

function CoopUnlockButtonsScrollUpdate()
{
	local menu = GetMenu( "CoopUnlockStore" )
	local buttons = GetElementsByClassname( menu, "CoopSelectClass" )
	local basePos = buttons[0].GetBasePos()
	local offset = ( buttons[0].GetHeight() - (4 * GetContentScaleFactor( menu )[0]) ) * uiGlobal.coopStoreScrollState

	buttons[0].MoveOverTime( basePos[0], basePos[1] - offset, COOP_MENU_SCROLL_SPEED )
}

function UpdateCoopUnlockButtons( buttons, items, currentItem, focusSelected )
{
	foreach ( button in buttons )
	{
		local buttonID = button.GetScriptID().tointeger()
		if ( buttonID < 0 )
		{
			button.SetNew( false )
			continue
		}

		if ( buttonID >= items.len() )
		{
			if ( button.IsFocused() )
				focusSelected = true

			button.s.ref <- null
			button.SetNew( false )
			button.SetEnabled( false )
			button.SetLocked( false )
			button.SetSelected( false )
			button.Hide()
		}
	}

	local buttonHasFocus = false
	local firstButton = null
	foreach ( button in buttons )
	{
		local buttonID = button.GetScriptID().tointeger()
		if ( buttonID < 0 )
			continue

		if ( buttonID == 0 )
			firstButton = button

		if ( buttonID < items.len() )
		{
			local itemRef = items[buttonID]
			local item = GetUnlockFromUnlockRef( itemRef )
			button.SetEnabled( true )
			button.Show()

			local isMaxed = IsUnlockMaxed( item )
			button.SetNew( isMaxed )

			local isLocked = IsUnlockLocked( item )
			button.SetLocked( isLocked )

			button.s.ref <- item.ref

			local buttonImage = button.GetChild( "UnlockNormal" )
			buttonImage.SetImage( item.image )
			local alpha
			if ( isLocked || isMaxed )
				alpha = 100
			else
				alpha = 255

			buttonImage.SetAlpha( alpha )

			if ( item.ref == currentItem )
			{
				button.SetSelected( true )
				if ( focusSelected )
				{
					button.SetFocused()
					buttonHasFocus = true
				}
			}
			else
			{
				button.SetSelected( false )
			}
		}
	}

	if ( !buttonHasFocus && firstButton != null )
		firstButton.SetFocused()
}

function IsUnlockMaxed( unlock )
{
	local unlockRef = unlock.ref
	local maxRanks = unlock.amountOfTimesPurchasable

	if ( maxRanks == -1 )
		return false

	if ( ( unlockRef in purchaseHistory ) && maxRanks <= purchaseHistory[ unlockRef ] )
		return true

	return false
}

function IsUnlockLocked( unlock )
{
	if ( IsUnlockMaxed( unlock ) )
		return false

	local points = GetCoopPointTotal_UI()
	local cost = unlock.unlockCost

	if ( cost > points )
		return true

	return false
}

function ServerCallback_OnOpenCoopStore( storeType )
{
	if ( !IsConnected() )
		return

	uiGlobal.coopStoreIndex = storeType
	local menu = GetMenu( "CoopUnlockStore" )
	AdvanceMenu( menu, false, false )
}