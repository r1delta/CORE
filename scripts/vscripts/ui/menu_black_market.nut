const MAX_SHOP_ITEMS = 9
const MAX_REWARD_ITEMS = 26
const MENU_MOVE_TIME = 0.2
const CENTER_REWARD_INDEX = 7
const LEFTMOST_REWARD_INDEX = 0
const RIGHTMOST_REWARD_INDEX = 7
const EXPENSIVE_ITEM_WARNING_THRESHOLD = 25000

function main()
{
	Globalize( InitBlackMarketMenu )
	Globalize( OnOpenBlackMarketMenu )
	Globalize( OnCloseBlackMarketMenu )
	Globalize( ServerCallback_ShopPurchaseStatus )
	Globalize( ServerCallback_ShopOpenBurnCardPack )
	Globalize( ServerCallback_ShopOpenGenericItem )
	Globalize( RequestShopPurchase )
	Globalize( UpdateBlackMarketButtonText )
	Globalize( RefreshBlackMarket )
	Globalize( RefreshItemInfo )
	Globalize( OnRewardsOKClick )
	Globalize( ClearRewardsCallback )
	Globalize( ClearRewards )
	Globalize( UpdateRewardButtonsForSelection )
	Globalize( OnPurchaseConfirm_Activate )
	Globalize( PopupConfirmBuyDialog )
	Globalize( PopupUnableToPurchaseDialog )
	Globalize( BlackMarket_FooterData )
	Globalize( ShopItemButtonClicked )
	Globalize( SkipRewardSequence )
	Globalize( CanUseBuyButtons )
	Globalize( ClearShopItemButtons )
	Globalize( SCB_RefreshBlackMarket )

	level.shopMenu 							<- {}
	level.shopMenu.menu 					<- null
	level.shopMenu.title 					<- null
	level.shopMenu.lastCoinCount 			<- -1
	level.shopMenu.itemName					<- null
	level.shopMenu.rewardName				<- null
	level.shopMenu.rewardRareLabel			<- null
	level.shopMenu.itemDesc					<- null
	level.shopMenu.itemDescRare				<- null
	level.shopMenu.itemCostIcon 			<- null
	level.shopMenu.itemImageLarge 			<- null
	level.shopMenu.burnCardElems 			<- null
	level.shopMenu.itemMenuPanel			<- null						// Panel on the left for all the items in the store & the current item's info
	level.shopMenu.rewardsPanel				<- null						// Reward carousel after you buy an item
	//mackey level.shopMenu.ItemBurnCardPreview		<- null
	level.shopMenu.shopMenUInitComplete 	<- false
	level.shopMenu.itemButtonElems 			<- []						// The buttons for the items you click to buy on the left menu
	level.shopMenu.rewardButtonElems 		<- []						// The reward buttons in the carousel after buying an item
	level.shopMenu.selectedItemButton		<- null
	level.shopMenu.rewardSelectedIndex 		<- 0
	level.shopMenu.numShopItemButtonsUsed	<- MAX_SHOP_ITEMS
	level.shopMenu.numRewardButtonsUsed 	<- MAX_REWARD_ITEMS
	level.shopMenu.rewardButtonBindings 	<- false
	level.shopMenu.burnCardStashStatus 		<- null
	level.shopMenu.burnCardStashStatusIcon	<- null
	level.shopMenu.lockedBack 				<- null
	level.shopMenu.lockedIcon 				<- null
	level.shopMenu.lockedLabel 				<- null
	level.shopMenu.decalBackground			<- null
	level.shopMenu.lastShopPurchaseRequestTime <- 0

	//level.shopMenu.flare 					<- null
	level.shopMenu.whiteBackground 			<- null
	level.shopShowingRewards 				<- false
	level.shopDoingRewardSequence			<- false
	level.itemMenuPanelStartX				<- 0
	level.itemMenuPanelStartY				<- 0
	level.itemImageStartX					<- 0
	level.itemImageStartY					<- 0
	level.canSendPurchaseRequest 			<- true
}

function InitBlackMarketMenu( menu )
{
	level.shopMenu.menu 			= menu
	level.shopMenu.itemMenuPanel    = menu.GetChild( "ItemMenuPanel" )
	level.shopMenu.title 			= menu.GetChild( "Title" )
	level.shopMenu.itemName			= menu.GetChild( "ItemName" )
	level.shopMenu.rewardName		= menu.GetChild( "RewardName" )
	level.shopMenu.rewardRareLabel	= menu.GetChild( "RewardRareLabel" )
	level.shopMenu.itemDesc			= menu.GetChild( "ItemDesc" )
	level.shopMenu.itemDescRare		= menu.GetChild( "ItemDescRare" )
	level.shopMenu.itemCostIcon		= menu.GetChild( "ItemCostIcon" )
	level.shopMenu.itemImageLarge	= menu.GetChild( "ItemImageLarge" )

	local BurnCardElems = menu.GetChild( "BurnCardElems" )
	level.shopMenu.BurnCardElems <- CreatePreviewCardFromStandardElements( BurnCardElems )

	//level.shopMenu.flare			= menu.GetChild( "Flare" )
	level.shopMenu.whiteBackground 	= menu.GetChild( "WhiteBackground" )
	level.shopMenu.lockedBack 		= menu.GetChild( "LockedItemBack" )
	level.shopMenu.lockedIcon 		= menu.GetChild( "LockIcon" )
	level.shopMenu.lockedLabel 		= menu.GetChild( "ErrorHint" )
	level.shopMenu.decalBackground	= menu.GetChild( "DecalBackgroundLarge" )

	uiGlobal.navigateBackCallbacks[ menu ] <- BlackMarketNavigateBack

	//mackey level.shopMenu.ItemBurnCardPreview = {}
	//mackey CreateBurnCardPanel( level.shopMenu.ItemBurnCardPreview, menu.GetChild( "ItemBurnCardPreview" ) )

	level.itemMenuPanelStartX = level.shopMenu.itemMenuPanel.GetBasePos()[0]
	level.itemMenuPanelStartY = level.shopMenu.itemMenuPanel.GetBasePos()[1]

	level.itemImageStartX = level.shopMenu.itemImageLarge.GetBasePos()[0]
	level.itemImageStartY = level.shopMenu.itemImageLarge.GetBasePos()[1]

	//level.shopMenu.flare.SetScale( 0, 0 )
	//level.shopMenu.flare.SetAlpha( 0 )
	//level.shopMenu.flare.Hide()

	local cardStashPanel = menu.GetChild( "BurnCardStashPanel" )
	level.shopMenu.burnCardStashStatus      = cardStashPanel.GetChild( "BurnCardStashStatus" )
	level.shopMenu.burnCardStashStatus.s.lastBurnCardStashCount <- 0
	level.shopMenu.burnCardStashStatusIcon  = cardStashPanel.GetChild( "BurnCardStashStatus_Icon" )
}


function InitCoins()
{
	if ( !IsFullyConnected() )
		return

	local coinCount = GetPersistentVar( "bm.coinCount" )
	local coinsPanel = level.shopMenu.menu.GetChild( "PlayerCoinsPanel" )
	local playerCoinLabel =	coinsPanel.GetChild( "PlayerCoinAmountLabel" )
	playerCoinLabel.SetText( "#CASH_AMOUNT_LABEL", coinCount )
	level.shopMenu.lastCoinCount = coinCount
}


function OnOpenBlackMarketMenu( menu )
{
	if ( !IsFullyConnected() )
	{
		CloseTopMenu()
		return
	}

	level.shopMenu.burnCardStashStatus.s.lastBurnCardStashCount = GetTotalBurnCards()
	level.shopMenu.decalBackground.Hide()

	// Decide which shop category we are using and show that title.
	switch ( uiGlobal.blackMarketItemType )
	{
		case eShopItemType.BURNCARD_PACK:
			level.shopMenu.title.SetText( "#SHOP_TITLE_BURN_CARD_PACKS" )
			level.shopMenu.burnCardStashStatus.Show()
			level.shopMenu.burnCardStashStatusIcon.Show()
			break
		case eShopItemType.PERISHABLE:
			level.shopMenu.itemImageLarge.Hide()
			level.shopMenu.title.SetText( "#SHOP_TITLE_PERISHABLES" )
			level.shopMenu.burnCardStashStatus.Show()
			level.shopMenu.burnCardStashStatusIcon.Show()
			break
		case eShopItemType.TITAN_OS_VOICE_PACK:
			level.shopMenu.title.SetText( "#SHOP_TITLE_TITAN_OS_VOICES" )
			level.shopMenu.decalBackground.Show()
			level.shopMenu.burnCardStashStatus.Hide()
			level.shopMenu.burnCardStashStatusIcon.Hide()
			break
		case eShopItemType.TITAN_DECAL:
			level.shopMenu.title.SetText( "#SHOP_TITLE_TITAN_DECALS" )
			level.shopMenu.decalBackground.Show()
			level.shopMenu.burnCardStashStatus.Hide()
			level.shopMenu.burnCardStashStatusIcon.Hide()
			break
		case eShopItemType.CHALLENGE_SKIP:
			level.shopMenu.title.SetText( "#SHOP_TITLE_CHALLENGE_SKIP" )
			level.shopMenu.decalBackground.Show()
			level.shopMenu.burnCardStashStatus.Hide()
			level.shopMenu.burnCardStashStatusIcon.Hide()
			break
		default:
			Assert(0, "invalid " + uiGlobal.blackMarketItemType )
			break
	}



	RefreshBlackMarket()

	ClientCommand( "NewBlackMarketItemsViewed" )
}


function OnCloseBlackMarketMenu()
{
	if ( !IsFullyConnected() )
		return
	SkipRewardSequence( true )
	ClearRewards()

 	level.shopShowingRewards = false
 	level.shopDoingRewardSequence = false

 	ClearShopItemButtons()
}


function BlackMarketNavigateBack()
{
	SkipRewardSequence( true )

	if ( level.shopShowingRewards )
		ClearRewards()
	else
		CloseTopMenu()
}


function BlackMarket_FooterData( footerData )
{
	if ( level.shopShowingRewards )
	{
		footerData.gamepad.append( { label = "#SHOP_A_BUTTON_CONTINUE", func = Bind( OnRewardsOKClick ) } )
		footerData.pc.append( { label = "#SHOP_BUTTON_CONTINUE", func = OnRewardsOKClick } )
	}
	else
	{
		// Don't show the buy button if no items in store
		if( level.shopMenu.numShopItemButtonsUsed > 0 )
			footerData.gamepad.append( { label = "#SHOP_A_BUTTON_BUY" } )

		footerData.gamepad.append( { label = "#B_BUTTON_BACK" } )
		footerData.pc.append( { label = "#BACK", func = PCBackButton_Activate } )
	}
}

function RefreshBlackMarket()
{
	InitCoins()
	InitShopInventory()
	InitShopRewardButtons()
	InitShopItemButtons()
	level.shopMenu.shopMenUInitComplete = true

	if ( uiGlobal.blackMarketItemType == null )
		return

	if ( !level.shopDoingRewardSequence )
	{
		level.shopMenu.rewardRareLabel.Hide()
		level.shopMenu.rewardName.Hide()
		level.shopMenu.rewardsPanel.Hide()

		UpdateShopItemButtons()

		ShowShopMenu()

		// Special case itemImageLarge presentation for different item types
		SetupItemImage()

		// Move the item back onto the sreen
		level.shopMenu.itemImageLarge.Show()

		EnableShopButtons()
	}

	RefreshShopUI()
}


function SetupItemImage()
{
	local screenSize = level.shopMenu.menu.GetSize()
	local imageSize  = level.shopMenu.itemImageLarge.GetSize()
	HidePreviewCard( level.shopMenu.BurnCardElems ) // this is in the same spot

	switch ( uiGlobal.blackMarketItemType )
	{
		case eShopItemType.BURNCARD_PACK:
			local rot = RandomInt( -6, 2 )
			level.shopMenu.itemImageLarge.SetRotation( rot )
			level.shopMenu.itemImageLarge.SetScale( 1, 1 )
			level.shopMenu.itemImageLarge.SetPos( level.itemImageStartX, level.itemImageStartY )
			break

		case eShopItemType.TITAN_DECAL:
			level.shopMenu.itemImageLarge.SetRotation( 0 )
			level.shopMenu.itemImageLarge.SetScale( 0.48, 0.35 )
			level.shopMenu.itemImageLarge.SetPos( level.itemImageStartX + 125, ( screenSize[1] / 2) - ( imageSize[1] / 2 ) )
			break

		case eShopItemType.PERISHABLE:
			level.shopMenu.itemImageLarge.Hide()
			break

		case eShopItemType.TITAN_OS_VOICE_PACK:
			level.shopMenu.itemImageLarge.SetRotation( 0 )
			level.shopMenu.itemImageLarge.SetScale( 0.48, 0.35 )
			level.shopMenu.itemImageLarge.SetPos( level.itemImageStartX + 125, ( screenSize[1] / 2) - ( imageSize[1] / 2 ) )
			break

		case eShopItemType.CHALLENGE_SKIP:
			level.shopMenu.itemImageLarge.SetRotation( 0 )
			level.shopMenu.itemImageLarge.SetScale( 0.48, 0.35 )
			level.shopMenu.itemImageLarge.SetPos( level.itemImageStartX + 125, ( screenSize[1] / 2) - ( imageSize[1] / 2 ) )
			break

		default:
			Assert(0, "invalid " + uiGlobal.blackMarketItemType )
			break
	}

	level.shopMenu.itemImageLarge.SetAlpha( 255 )
}

function RefreshShopUI()
{
	if ( !IsFullyConnected() )
		return

	local coinCount = GetPersistentVar( "bm.coinCount" )
	local coinsPanel = level.shopMenu.menu.GetChild( "PlayerCoinsPanel" )
	local playerCoinLabel =	coinsPanel.GetChild( "PlayerCoinAmountLabel" )
	local lastCoinCount = level.shopMenu.lastCoinCount
 	local countUpDuration = 0.5

	thread SetTextCountUp( level.shopMenu.menu, playerCoinLabel, coinCount, null, 0.2, null, countUpDuration, "#CASH_AMOUNT_LABEL", lastCoinCount )
	thread FlashElement( level.shopMenu.menu, playerCoinLabel, 4, 1.5, 255, 0 )

	level.shopMenu.lastCoinCount = coinCount

	UpdateBurnCardDeckStatus( level.shopMenu.burnCardStashStatus )
	UpdateFooterButtons()

	// certain menus dont use itemImageLarge and others assume it to be on
	switch ( uiGlobal.blackMarketItemType )
	{
		case eShopItemType.PERISHABLE:
			level.shopMenu.itemImageLarge.Hide()
			break
		default:
			level.shopMenu.itemImageLarge.Show()
			break
	}

	// Show sold out messages if shop is empty (Daily Deals)
	if( level.shopMenu.numShopItemButtonsUsed <= 0 )
	{
		level.shopMenu.itemName.SetText( "#SHOP_SOLD_OUT" )
		level.shopMenu.itemDesc.SetText( "#SHOP_DAILY_DEALS_SOLD_OUT" )
		level.shopMenu.itemDescRare.SetText( "" )

		HideLockedPanel()
	}
}


// ------------------------------------------------------------------------------------------------------------------------------------
// Main menu of items on the left (items for sale)
// ------------------------------------------------------------------------------------------------------------------------------------
// Initializes the menu on the left panel with the items for sale
function InitShopItemButtons()
{
	local buttons = GetElementsByClassname( level.shopMenu.menu, "BtnItemClass" )
	local priceLabels = GetElementsByClassname( level.shopMenu.menu, "PriceItemClass" )
	Assert( buttons.len() == PersistenceGetArrayCount( "bm.blackMarketPerishables" ), "persistence should match button count" )

	if ( level.shopMenu.shopMenUInitComplete )
	{
		for ( local i = 0 ; i < MAX_SHOP_ITEMS ; i++ )
		{
			local button = buttons[ i ]
			Assert( button != null )
			button.Hide()
			button.s.priceLabel.Hide()
		}

		return
	}

	for ( local i = 0 ; i < MAX_SHOP_ITEMS ; i++ )
	{
		local button = buttons[ i ]
		Assert( button != null )

		button.s.itemRef 	<- null
		button.s.priceLabel <- priceLabels[ i ]

		button.SetText( "Button" +i )
		button.s.priceLabel.SetText( i.tostring())

		button.Hide()
		button.s.priceLabel.Hide()

		button.AddEventHandler( UIE_CLICK, ShopItemButtonClicked )
		button.AddEventHandler( UIE_GET_FOCUS, ShopItemButtonFocused )
		button.AddEventHandler( UIE_LOSE_FOCUS, ShopItemButtonLostFocus )

		level.shopMenu.itemButtonElems.append( button )
	}
}

function ClearShopItemButtons()
{
	foreach ( button in level.shopMenu.itemButtonElems )
	{
		button.SetEnabled( false )
		button.Hide()
		button.s.priceLabel.Hide()
		button.s.itemRef = null
	}
}

function RefreshItemInfo( button )
{
	if ( level.shopShowingRewards )
		return

	local itemID = button.s.itemRef.itemID
	local item = level.shopInventoryData[ itemID ]

	level.shopMenu.rewardName.SetText( item.name )
	level.shopMenu.itemName.SetText( item.name )
	level.shopMenu.itemDesc.SetText( item.description, item.itemCount )

	if ( item.itemType == uiGlobal.blackMarketItemType )
		level.shopMenu.itemDescRare.SetText( item.rareDescription, item.rareCount.tostring() )
	else
		level.shopMenu.itemDescRare.Hide()

	// Special case itemImageLarge presentation for item types
	SetupItemImage()
	if ( item.itemType == eShopItemType.PERISHABLE )
	{
		ShowPerishableItemImage( level.shopMenu.BurnCardElems, item.perishable )
		level.shopMenu.itemImageLarge.Hide()
	}
	else
	{
		HidePerishableItemImage( level.shopMenu.BurnCardElems )

		level.shopMenu.itemImageLarge.Show()
		level.shopMenu.itemImageLarge.SetImage( button.s.itemArt )
	}

	// Should this item have a locked icon & message?
	local lockedInfo = GetLockedPanelInfo( button )
	UpdateLockedPanel( lockedInfo.locked, lockedInfo.hintText )
}

function DisableShopButtons()
{
	foreach ( button in level.shopMenu.itemButtonElems )
		button.SetEnabled( false )
}

function EnableShopButtons()
{
	foreach ( button in level.shopMenu.itemButtonElems )
		button.SetEnabled( true )

	if( level.shopMenu.itemButtonElems.len() > 0 )
		level.shopMenu.itemButtonElems[0].SetFocused()
}


function GetLockedPanelInfo( button )
{
	local info    = {}
	info.locked   <- false
	info.hintText <- ""

	local canBuyResponse = CanBuyItem( button.s.itemRef.itemID )
	switch ( canBuyResponse )
	{
		case eShopResponseType.SUCCESS:
		case eShopResponseType.SUCCESS_PERISHABLE:
			info.locked = false
			break

		case eShopResponseType.FAIL_UNKNOWN_ERROR:
			info.locked = true
			info.hintText = "#SHOP_PURCHASE_UNKNOWN_ERROR"
			break

		case eShopResponseType.FAIL_NOT_ENOUGH_COINS:
			info.locked = true
			info.hintText = "#SHOP_PURCHASE_NOT_ENOUGH_COINS_SHORT"
			break

		case eShopResponseType.FAIL_BURN_CARDS_FULL:
			info.locked = true
			info.hintText = "#SHOP_PURCHASE_CARDS_FULL_SHORT"
			break

		case eShopResponseType.FAIL_ITEM_LEVEL_LOCKED:
			info.locked = true
			info.hintText = "#SHOP_PURCHASE_ITEM_LEVEL_LOCKED_SHORT"
			break

		default:
			info.locked = false
			break
	}

	return info
}

function UpdateLockedPanel( locked, hintText = "" )
{
	if ( level.shopShowingRewards )
		return

	if ( locked )
	{
		ShowLockedPanel()
		level.shopMenu.lockedLabel.SetText( hintText )
		level.shopMenu.itemImageLarge.SetAlpha( 185 )
	}
	else
	{
		HideLockedPanel()
		level.shopMenu.itemImageLarge.SetAlpha( 255 )
	}
}

function HideLockedPanel()
{
	level.shopMenu.lockedBack.Hide()
	level.shopMenu.lockedIcon.Hide()
	level.shopMenu.lockedLabel.Hide()
}

function ShowLockedPanel()
{
	level.shopMenu.lockedBack.Show()
	level.shopMenu.lockedIcon.Show()
	level.shopMenu.lockedLabel.Show()
}

function UpdateShopItemButtons()
{
	Assert( level.shopInventoryData.len() > 0 )

	local buttonsUsedCount = 0
	local buttonEnabled = true
	local shopItems = GetSortedShopInventory( CoinCostLowToHigh )

	level.shopMenu.numShopItemButtonsUsed = 0

	for ( local i = 0; i < level.shopInventoryData.len(); i++ )
	{
		Assert( buttonsUsedCount <= MAX_SHOP_ITEMS )

		// Defensive fix since patching client is hard
		if ( buttonsUsedCount >= MAX_SHOP_ITEMS )
			return

		// Not enough actual items to show? Bail early
		if ( i >= shopItems.len() )
			return

		// Skip any items that are not what we are currently loading in the store (burn card packs, voice packs, decals, etc.)
		if ( shopItems[ i ].itemType != uiGlobal.blackMarketItemType )
			continue

		buttonsUsedCount++

		local button = level.shopMenu.itemButtonElems[ level.shopMenu.numShopItemButtonsUsed ]
		button.s.itemRef = shopItems[ i ]

		// Setup the item's price label & show it
		local canBuyResponse = CanBuyItem( shopItems[ i ].itemID )
		if ( canBuyResponse == eShopResponseType.SUCCESS )
		{
			button.s.priceLabel.SetColor( [204, 234, 255, 255] ) // light blue
			button.s.priceLabel.SetText( shopItems[ i ].coinCost.tostring() )
		}
		else
		{
			if ( canBuyResponse == eShopResponseType.FAIL_ALREADY_UNLOCKED )
			{
				button.s.priceLabel.SetText( "#SHOP_PURCHASE_ITEM_ALREADY_UNLOCKED_SUPERSHORT" )
				button.s.priceLabel.SetColor( [180, 246, 85, 255] ) // green
				buttonEnabled = false
			}
			else
			{
				button.s.priceLabel.SetColor( [ 255, 0, 0 ] ) // red
				button.s.priceLabel.SetText( shopItems[ i ].coinCost.tostring() )
			}
		}

		button.s.priceLabel.Show()

		button.s.itemArt <-  shopItems[ i ].image

		// Setup & show the button itself
		button.SetText( shopItems[ i ].name )
		button.SetEnabled( buttonEnabled )
		button.Show()

		level.shopMenu.numShopItemButtonsUsed++
	}
}

// ------------------------------------------------------------------------------------------------------------------------------------
// Rewards Section - For the carousel of items that appears after buying an item
// ------------------------------------------------------------------------------------------------------------------------------------
// Initializes the buttons for the rewards panel (the carousel of items)
function InitShopRewardButtons()
{
	if ( level.shopMenu.shopMenUInitComplete )
		return

	level.shopMenu.rewardsPanel = GetElem( level.shopMenu.menu, "BurnCardPackButtonsPanel" )
	for ( local i = 0 ; i < MAX_REWARD_ITEMS ; i++ )
	{
		local button = level.shopMenu.rewardsPanel.GetChild( "BtnPack" + i )
		Assert( button != null )

		local previewElem 			= button.GetChild( "BurnCardRewardPanel" )
		button.s.itemPreview 		<- CreatePreviewCardFromStandardElements( previewElem )
		HidePreviewCard( button.s.itemPreview )

		button.s.itemRef <- null

   		button.s.dimOverlay <- button.GetChild( "DimOverlay" )

		button.AddEventHandler( UIE_CLICK, RewardButtonClicked )
		button.AddEventHandler( UIE_GET_FOCUS, RewardButtonFocused )

		level.shopMenu.rewardButtonElems.append( button )
	}

	GetElem( level.shopMenu.menu, "BtnScrollUpPC" ).AddEventHandler( UIE_CLICK, RewardSelectNextLeft )
	GetElem( level.shopMenu.menu, "BtnScrollDownPC" ).AddEventHandler( UIE_CLICK, RewardSelectNextRight )

	//mackey HideBurnCard( level.shopMenu.ItemBurnCardPreview )
}


function ClearRewardsCallback( userInitiated = true )
{
	ClearRewards()
}


function ClearRewards()
{
	level.shopShowingRewards = false

	foreach( index, button in level.shopMenu.rewardButtonElems )
	{
		HidePreviewCard( button.s.itemPreview )
	}

	if ( level.shopMenu.rewardButtonBindings )
	{
		DeregisterButtonPressedCallback( BUTTON_A, ClearRewardsCallback )
		DeregisterButtonPressedCallback( MOUSE_WHEEL_UP, RewardSelectNextLeft )
		DeregisterButtonPressedCallback( MOUSE_WHEEL_DOWN, RewardSelectNextRight )
		DeregisterButtonPressedCallback( KEY_LEFT, RewardSelectNextLeft )
		DeregisterButtonPressedCallback( KEY_RIGHT, RewardSelectNextRight )
		level.shopMenu.rewardButtonBindings = false
	}

	RefreshBlackMarket()

	// Hax? - Select the last button so we can slide the cards in from left to right every time
	thread UpdateRewardButtonsForSelection( level.shopMenu.rewardButtonElems.len() - 1 )
}


function SkipRewardSequence( userInitiated = true )
{
	Signal( uiGlobal.signalDummy, "StopMenuAnimation" )
}


function BurnCardPackOpenSequence( cardIndices )
{
	level.shopShowingRewards = false
	level.shopDoingRewardSequence = true

	Signal( uiGlobal.signalDummy, "StopMenuAnimation" )
	EndSignal( uiGlobal.signalDummy, "StopMenuAnimation" )

	RegisterButtonPressedCallback( BUTTON_A, SkipRewardSequence )

	OnThreadEnd(
		function() : ( cardIndices )
		{
			level.shopShowingRewards = true
			level.shopDoingRewardSequence = false

			DeregisterButtonPressedCallback( BUTTON_A, SkipRewardSequence )
			level.shopMenu.itemMenuPanel.Hide()

			level.shopMenu.itemImageLarge.SetAlpha( 255 )
			level.shopMenu.itemImageLarge.SetScale( 1, 1 )
			level.shopMenu.itemImageLarge.Hide()

			// Show the rewards panel
			level.shopMenu.rewardsPanel.Show()
			UpdateRewardButtonsWithRewards( cardIndices )

			level.shopMenu.rewardName.Show()
			level.shopMenu.whiteBackground.Hide()

			UpdateFooterButtons()
		}
	)

	if ( !level.shopMenu.rewardButtonBindings )
	{
		level.shopMenu.rewardButtonBindings = true
		RegisterButtonPressedCallback( BUTTON_A, ClearRewardsCallback )
		RegisterButtonPressedCallback( MOUSE_WHEEL_UP, RewardSelectNextLeft )
		RegisterButtonPressedCallback( MOUSE_WHEEL_DOWN, RewardSelectNextRight )
		RegisterButtonPressedCallback( KEY_LEFT, RewardSelectNextLeft )
		RegisterButtonPressedCallback( KEY_RIGHT, RewardSelectNextRight )
	}

	HideShopMenu()

	EmitUISound( "BlackMarket_CardPack_Open" )

	level.shopMenu.itemImageLarge.MoveOverTime( level.itemImageStartX -150 , level.itemImageStartY + 150, 0.5, INTERPOLATOR_DEACCEL )
	level.shopMenu.itemImageLarge.ScaleOverTime( 0.25, 0.25, 0.5, INTERPOLATOR_LINEAR )
	level.shopMenu.itemImageLarge.FadeOverTime( 0, 0.5 )

	wait 0.75
}

function GenericItemRewardSequence( itemID )
{
	level.shopShowingRewards = false
	level.shopDoingRewardSequence = true

	Signal( uiGlobal.signalDummy, "StopMenuAnimation" )
	Signal( uiGlobal.signalDummy, "PlayOSVoiceRandomSample" ) //Kills sound played in PlayOSVoiceRandomSample
	EndSignal( uiGlobal.signalDummy, "StopMenuAnimation" )

	RegisterButtonPressedCallback( BUTTON_A, SkipRewardSequence )

	OnThreadEnd(
		function() : ( itemID )
		{
			level.shopShowingRewards = true
			level.shopDoingRewardSequence = false

			DeregisterButtonPressedCallback( BUTTON_A, SkipRewardSequence )

			level.shopMenu.itemMenuPanel.Hide()

			level.shopMenu.rewardName.Show()

			UpdateFooterButtons()
		}
	)

	DisableShopButtons()

	if ( !level.shopMenu.rewardButtonBindings )
	{
		level.shopMenu.rewardButtonBindings = true
		RegisterButtonPressedCallback( BUTTON_A, ClearRewardsCallback )
		RegisterButtonPressedCallback( MOUSE_WHEEL_UP, RewardSelectNextLeft )
		RegisterButtonPressedCallback( MOUSE_WHEEL_DOWN, RewardSelectNextRight )
		RegisterButtonPressedCallback( KEY_LEFT, RewardSelectNextLeft )
		RegisterButtonPressedCallback( KEY_RIGHT, RewardSelectNextRight )
	}

	HideShopMenu()

	// Move the item to the center of the screen
	local screenSize = level.shopMenu.menu.GetSize()
	local imageSize = level.shopMenu.itemImageLarge.GetSize()
	level.shopMenu.itemImageLarge.MoveOverTime( (screenSize[0] / 2) - ( imageSize[0] / 2), (screenSize[1] / 2) - ( imageSize[1] / 2 ), 0.5, INTERPOLATOR_DEACCEL )
}


function HideShopMenu()
{
	// Move the item menu off the screen
	level.shopMenu.itemMenuPanel.MoveOverTime( level.itemMenuPanelStartX - 750, level.itemMenuPanelStartY, 0.2, INTERPOLATOR_DEACCEL )
}


function ShowShopMenu()
{
	// Move the item menu back on the screen
	level.shopMenu.itemMenuPanel.MoveOverTime( level.itemMenuPanelStartX, level.itemMenuPanelStartY, 0.2, INTERPOLATOR_DEACCEL )
}


function CanUseBuyButtons()
{
	if ( level.shopDoingRewardSequence )
		return false

	if ( level.shopShowingRewards )
		return false

	if ( !level.canSendPurchaseRequest )
		return false

	// can't spam buy
	if ( Time() - level.shopMenu.lastShopPurchaseRequestTime < 0.35 )
		return false

	return true
}

function ShopItemButtonClicked( button )
{
	if ( !CanUseBuyButtons() )
		return

	if ( level.shopShowingRewards )
	{
		// With controller, we want the A button to continue back to the shop.  On PC, there is a button for it.
		if ( IsControllerModeActive() )
			ClearRewards()

		return
	}

	local canBuyResponse = CanBuyItem( button.s.itemRef.itemID )
	if ( canBuyResponse == eShopResponseType.SUCCESS )
	{
		if ( button.s.itemRef.coinCost >= EXPENSIVE_ITEM_WARNING_THRESHOLD )
			PopupConfirmBuyDialog()
		else
			RequestShopPurchase( button.s.itemRef.itemID )
	}
	else
	{
		PopupUnableToPurchaseDialog( canBuyResponse )
	}
}


function ShopItemButtonFocused( button )
{
	if ( level.shopShowingRewards )
		return

	RefreshItemInfo( button )

	if ( button.s.itemRef.itemType == eShopItemType.TITAN_OS_VOICE_PACK )
		thread PlayOSVoiceRandomSample( button.s.itemRef.itemID )

	if ( !CanUseBuyButtons() )
		return

	level.shopMenu.selectedItemButton = button
}


function ShopItemButtonLostFocus( button )
{
	Signal( uiGlobal.signalDummy, "PlayOSVoiceRandomSample" ) //Kills sound played in PlayOSVoiceRandomSample
}


function RewardButtonClicked( button )
{
	local id = button.GetScriptID().tointeger()

	if ( IsControllerModeActive() )
		ClearRewards()
	else
		thread UpdateRewardButtonsForSelection( id )
}


function RewardButtonFocused( button )
{
	local id = button.GetScriptID().tointeger()

	if ( IsControllerModeActive() )
		thread UpdateRewardButtonsForSelection( id )
}


function RewardSelectNextLeft( button )
{
	if ( level.shopMenu.rewardSelectedIndex == 0 )
		return
	thread UpdateRewardButtonsForSelection( level.shopMenu.rewardSelectedIndex - 1 )
}


function RewardSelectNextRight( button )
{
	if ( level.shopMenu.rewardSelectedIndex + 1 >= level.shopMenu.numRewardButtonsUsed )
		return
	thread UpdateRewardButtonsForSelection( level.shopMenu.rewardSelectedIndex + 1 )
}

/*
function UpdateRewardButtons()
{
	Assert( level.shopInventoryData.len() > 0 && level.shopInventoryData.len() < MAX_REWARD_ITEMS )

	local shopItems = GetSortedShopInventory( CoinCostLowToHigh )

	level.shopMenu.numRewardButtonsUsed = 0
	for ( local i = 0; i < shopItems.len(); i++ )
	{
		// Skip any items that are not what we are currently loading in the store
		if ( shopItems[ i ].itemType != uiGlobal.blackMarketItemType )
			continue

		local button = level.shopMenu.rewardButtonElems[ level.shopMenu.numRewardButtonsUsed ]
		button.SetEnabled( true )
		button.Show()
		button.s.itemRef = shopItems[ i ]
		level.shopMenu.numRewardButtonsUsed++
	}

	HideUnusedRewardButtons()

	// Pick the first item so we start all the way to the left
	thread UpdateRewardButtonsForSelection( 0 )
}
*/

function UpdateRewardButtonsWithRewards( cardIndices )
{
	level.shopMenu.numRewardButtonsUsed = 0
	for ( local i = 0; i < cardIndices.len(); i++ )
	{
		local cardIndex = cardIndices[ i ]
		local cardRef = level.indexToBurnCard[ cardIndex ]
		local button = level.shopMenu.rewardButtonElems[ i ]
		button.s.cardRef <- cardRef
		button.SetEnabled( true )
		button.Show()

		ShowPreviewCard( button.s.itemPreview )
		SetPreviewCard( cardRef, button.s.itemPreview )

		level.shopMenu.numRewardButtonsUsed++
	}

	HideUnusedRewardButtons()

	// Pick the first item so we start all the way to the left
	thread UpdateRewardButtonsForSelection( 0 )
}


function UpdateRewardButtonsForSelection( index, instant = false )
{
	if ( !IsFullyConnected() )
		return

	Assert( level.shopMenu.rewardSelectedIndex < level.shopMenu.rewardButtonElems.len() )

	level.shopMenu.rewardSelectedIndex = index

	foreach( index, button in level.shopMenu.rewardButtonElems )
	{
		local distFromSelection = abs( index - level.shopMenu.rewardSelectedIndex )

		local isSelected = index == level.shopMenu.rewardSelectedIndex ? true : false
		button.SetSelected( isSelected )


		// Figure out button positioning ( Curved )
		distFromSelection = index - level.shopMenu.rewardSelectedIndex
		local goalPosX
		local goalPosY
		local goalPosZ = 999  // always on top
		if ( isSelected )
		{

			// Is this one in the enter slot?  If so, then check rarity & display a "RARE!" if needed
			if ( "cardRef" in button.s )
			{
				if ( GetBurnCardRarity( button.s.cardRef ) == BURNCARD_RARE )
					level.shopMenu.rewardRareLabel.Show()
				else
					level.shopMenu.rewardRareLabel.Hide()
			}

			PlayCustomSelectSoundOnButton( eShopItemType.BURNCARD_PACK )
			button.SetFocused()
			button.s.dimOverlay.SetAlpha( 0 )
		}
		else
		{
			button.s.dimOverlay.SetAlpha( 150 )
		}

		local moveTime = MENU_MOVE_TIME

		if ( distFromSelection == 0 )
		{
			goalPosX = level.shopMenu.rewardButtonElems[7].GetBasePos()[0]
			goalPosY = level.shopMenu.rewardButtonElems[7].GetBasePos()[1]
			goalPosZ = 999
		}
		else if ( distFromSelection == -1 )
		{
			goalPosX = level.shopMenu.rewardButtonElems[6].GetBasePos()[0]
			goalPosY = level.shopMenu.rewardButtonElems[6].GetBasePos()[1]
			goalPosZ = 998
		}
		else if ( distFromSelection == -2 )
		{
			goalPosX = level.shopMenu.rewardButtonElems[5].GetBasePos()[0]
			goalPosY = level.shopMenu.rewardButtonElems[5].GetBasePos()[1]
			goalPosZ = 997
		}
		else if ( distFromSelection == -3 )
		{
			goalPosX = level.shopMenu.rewardButtonElems[4].GetBasePos()[0]
			goalPosY = level.shopMenu.rewardButtonElems[4].GetBasePos()[1]
			goalPosZ = 996
		}
		else if ( distFromSelection == -4 )
		{
			goalPosX = level.shopMenu.rewardButtonElems[3].GetBasePos()[0]
			goalPosY = level.shopMenu.rewardButtonElems[3].GetBasePos()[1]
			goalPosZ = 995
		}
		else if ( distFromSelection == -5 )
		{
			goalPosX = level.shopMenu.rewardButtonElems[2].GetBasePos()[0]
			goalPosY = level.shopMenu.rewardButtonElems[2].GetBasePos()[1]
			goalPosZ = 994
		}
		else if ( distFromSelection == -6 )
		{
			goalPosX = level.shopMenu.rewardButtonElems[1].GetBasePos()[0]
			goalPosY = level.shopMenu.rewardButtonElems[1].GetBasePos()[1]
			goalPosZ = 993
		}
		else if ( distFromSelection <= -7 )
		{
			goalPosX = level.shopMenu.rewardButtonElems[0].GetBasePos()[0]
			goalPosY = level.shopMenu.rewardButtonElems[0].GetBasePos()[1]
			goalPosZ = 992
		}
		else if ( distFromSelection == 1 )
		{
			goalPosX = level.shopMenu.rewardButtonElems[8].GetBasePos()[0]
			goalPosY = level.shopMenu.rewardButtonElems[8].GetBasePos()[1]
			goalPosZ = 998
		}
		else if ( distFromSelection == 2 )
		{
			goalPosX = level.shopMenu.rewardButtonElems[9].GetBasePos()[0]
			goalPosY = level.shopMenu.rewardButtonElems[9].GetBasePos()[1]
			goalPosZ = 997
		}
		else if ( distFromSelection == 3 )
		{
			goalPosX = level.shopMenu.rewardButtonElems[10].GetBasePos()[0]
			goalPosY = level.shopMenu.rewardButtonElems[10].GetBasePos()[1]
			goalPosZ = 996
		}
		else if ( distFromSelection == 4 )
		{
			goalPosX = level.shopMenu.rewardButtonElems[11].GetBasePos()[0]
			goalPosY = level.shopMenu.rewardButtonElems[11].GetBasePos()[1]
			goalPosZ = 995
		}
		else if ( distFromSelection == 5 )
		{
			goalPosX = level.shopMenu.rewardButtonElems[12].GetBasePos()[0]
			goalPosY = level.shopMenu.rewardButtonElems[12].GetBasePos()[1]
			goalPosZ = 994
		}
		else if ( distFromSelection == 6 )
		{
			goalPosX = level.shopMenu.rewardButtonElems[13].GetBasePos()[0]
			goalPosY = level.shopMenu.rewardButtonElems[13].GetBasePos()[1]
			goalPosZ = 993
		}
		else if ( distFromSelection >= 7 )
		{
			goalPosX = level.shopMenu.rewardButtonElems[14].GetBasePos()[0]
			goalPosY = level.shopMenu.rewardButtonElems[14].GetBasePos()[1]
			goalPosZ = 992
		}

		if ( instant )
			button.SetPos( goalPosX, goalPosY )
		else
		{	button.SetZ( goalPosZ )
			button.MoveOverTime( goalPosX, goalPosY, moveTime, INTERPOLATOR_DEACCEL )
		}
	}
}


function HideUnusedRewardButtons()
{
	// Hide / Disable buttons we wont be using
	for ( local i = level.shopMenu.numRewardButtonsUsed ; i < MAX_REWARD_ITEMS ; i++ )
	{
		local button = level.shopMenu.rewardButtonElems[ i ]
		button.SetEnabled( false )
		button.Hide()
	}
}


// Override UI sounds based on what we are seeing in the store
function PlayCustomSelectSoundOnButton( itemType )
{
	if ( itemType == eShopItemType.BURNCARD_PACK )
	{
		EmitUISound( "Menu_BurnCard_MoveRight" )
	}
}


// ------------------------------------------------------------------------------------------------------------------------------------
// Client/Server Communication
// ------------------------------------------------------------------------------------------------------------------------------------

// This disables purchase requests so players can't spam the A button and send multiple requests and cause issues.
// We can't just disable the buttons because it resets focus on the wrong button and causes presentation issues.
function SetPurchaseRequestTimer()
{
	level.canSendPurchaseRequest = false
	wait 2.0
	level.canSendPurchaseRequest = true
}

function RequestShopPurchase( itemID )
{
	if ( !level.canSendPurchaseRequest )
		return false

	switch ( uiGlobal.blackMarketItemType )
	{
		case eShopItemType.PERISHABLE:
			level.shopMenu.lastShopPurchaseRequestTime = Time()
			break

		case eShopItemType.TITAN_OS_VOICE_PACK: //TODO: Need to change this?
			level.shopMenu.lastShopPurchaseRequestTime = Time()
			break

		default:
			// purchase types with an animation effect have a delay period
			thread SetPurchaseRequestTimer()
			break
	}

	ClientCommand( "ShopPurchaseRequest " + itemID )
	return true
}

function SCB_RefreshBlackMarket()
{
	RefreshBlackMarket()
}

function ServerCallback_ShopOpenBurnCardPack(...)
{
	Assert( vargc >= 1 )
	if ( vargc <= 0 ) // defensive, since patching the client is hard.
		return false
	local cardIndices = []
	for ( local i = 0; i < vargc; i++ )
	{
        printt( vargv[i] )
		// The server fills in unused params with null so skip them
		if ( vargv[i] != null )
		{
			cardIndices.append( vargv[i].tointeger() )
		}
	}

	thread BurnCardPackOpenSequence( cardIndices )
}

// Used for generic items that need a small celebration sequence (item moves to center of screen, etc)
function ServerCallback_ShopOpenGenericItem(...)
{
	Assert( vargc >= 1 )
	if ( vargc <= 0 ) // defensive, since patching the client is hard.
		return false

	local itemIndex = vargv[0].tointeger()
	local item = GetItemByIndex( itemIndex )
	thread GenericItemRewardSequence( item )
}


// success = true/false. If false, msg = error code to display to player
function ServerCallback_ShopPurchaseStatus( response = eShopResponseType.FAIL_UNKNOWN_ERROR )
{
	switch ( response )
	{
		case eShopResponseType.SUCCESS:
			EmitUISound( "BlackMarket_Purchase_Success" )
			break

		case eShopResponseType.SUCCESS_PERISHABLE:
			EmitUISound( "BlackMarket_Purchase_Success" )
			RefreshBlackMarket()
			UpdateSelectedItemImageFromFocus()
			return

		default:
			PopupUnableToPurchaseDialog( response )
			EmitUISound( "BlackMarket_Purchase_Fail" )
			break
	}

	RefreshShopUI()
}

function UpdateSelectedItemImageFromFocus()
{
	local focus = GetFocus()
	if ( !IsValid( focus ) )
		return

	if ( !focus.IsVisible() )
		return

	if ( !focus.IsEnabled() )
		return

	if ( "itemRef" in focus.s )
		RefreshItemInfo( focus )
}



// ------------------------------------------------------------------------------------------------------------------------------------
// Input & Callbacks
// ------------------------------------------------------------------------------------------------------------------------------------
function OnRewardsOKClick(...)
{
	if ( level.shopDoingRewardSequence )
		return

	ClearRewards()
}


function OnPurchaseConfirm_Activate(...)
{
	CloseDialog()
	RequestShopPurchase( level.shopMenu.selectedItemButton.s.itemRef.itemID )
}


function OnUnableToPurchaseConfirm_Activate(...)
{
	CloseDialog()
	RefreshBlackMarket()
}


function PCBuyButton_Activate( button )
{
	Assert( level.shopMenu.selectedItemButton in level.shopMenu.itemButtonElems )

	local button = level.shopMenu.itemButtonElems[ level.shopMenu.selectedItemButton ]
	ShopItemButtonClicked( button )
}

// ------------------------------------------------------------------------------------------------------------------------------------
// Popup Confirmation Boxes
// ------------------------------------------------------------------------------------------------------------------------------------
function PopupConfirmBuyDialog()
{
	if ( uiGlobal.activeDialog )
		return

	local buttonData = []
	buttonData.append( { name = "#SHOP_BUTTON_BUY_ITEM", func = OnPurchaseConfirm_Activate } )
	buttonData.append( { name = "#CANCEL", func = null } )

	local footerData = []
	footerData.append( { label = "#A_BUTTON_SELECT" } )
	footerData.append( { label = "#B_BUTTON_CANCEL", func = null } )

	local dialogData = {}
	dialogData.header <- "#SHOP_PURCHASE_CONFIRM"
	dialogData.buttonData <- buttonData
	dialogData.footerData <- footerData

	OpenChoiceDialog( dialogData )
}


function PopupUnableToPurchaseDialog( reason )
{
	if ( uiGlobal.activeDialog )
		return

	local buttonData = []
	buttonData.append( { name = "#SHOP_BUTTON_CONTINUE", func = OnUnableToPurchaseConfirm_Activate } )

	local footerData = []
	footerData.append( { label = "#A_BUTTON_SELECT" } )

	local dialogData = {}
	dialogData.header <- "#SHOP_PURCHASE_UNKNOWN_ERROR"
	dialogData.detailsMessage <- []
	dialogData.buttonData <- buttonData
	dialogData.footerData <- footerData

	switch ( reason )
	{
		case eShopResponseType.FAIL_UNKNOWN_ERROR:
			dialogData.header = "#SHOP_PURCHASE_UNKNOWN_ERROR"
			dialogData.detailsMessage.append( "#SHOP_PURCHASE_UNKNOWN_ERROR" )
			EmitUISound( "BlackMarket_Purchase_Fail" )
			break

		case eShopResponseType.FAIL_NOT_ENOUGH_COINS:
			local coinCount = GetPersistentVar( "bm.coinCount" )
			local requiredCoins = level.shopMenu.selectedItemButton.s.itemRef.coinCost - coinCount
			dialogData.header = "#SHOP_PURCHASE_FAIL_HEADER"
			dialogData.detailsMessage.append( "#SHOP_PURCHASE_NOT_ENOUGH_COINS" )
			dialogData.detailsMessage.append( requiredCoins )
			EmitUISound( "BlackMarket_Purchase_Fail" )
			break

		case eShopResponseType.FAIL_BURN_CARDS_FULL:
			dialogData.header = "#SHOP_PURCHASE_FAIL_HEADER"
			dialogData.detailsMessage.append( "#SHOP_PURCHASE_CARDS_FULL" )
			EmitUISound( "BlackMarket_Purchase_Fail" )
			break

		case eShopResponseType.FAIL_ITEM_LEVEL_LOCKED:
			dialogData.header = "#SHOP_PURCHASE_FAIL_HEADER"
			dialogData.detailsMessage.append( "#SHOP_PURCHASE_ITEM_LEVEL_LOCKED" )
			EmitUISound( "BlackMarket_Purchase_Fail" )
			break

		case eShopResponseType.FAIL_ALREADY_UNLOCKED:
			dialogData.header = "#SHOP_PURCHASE_FAIL_HEADER"
			dialogData.detailsMessage.append( "#SHOP_PURCHASE_ITEM_ALREADY_UNLOCKED" )
			EmitUISound( "BlackMarket_Purchase_Fail" )
			break

		case eShopResponseType.FAIL_PRIVATE_MATCH:
			dialogData.header = "#SHOP_PURCHASE_FAIL_HEADER"
			dialogData.detailsMessage.append( "#SHOP_PURCHASE_FAIL_PRIVATE_LOBBY" )
			EmitUISound( "BlackMarket_Purchase_Fail" )
			break

		default:
			dialogData.header = "#SHOP_PURCHASE_FAIL_HEADER"
			dialogData.detailsMessage.append( "#SHOP_PURCHASE_UNKNOWN_ERROR" )
			EmitUISound( "BlackMarket_Purchase_Fail" )
			break
	}

	OpenChoiceDialog( dialogData )
}


// ------------------------------------------------------------------------------------------------------------------------------------
// This updates the Black Market button in the lobby
// ------------------------------------------------------------------------------------------------------------------------------------
function UpdateBlackMarketButtonText( buttonOverride = null )
{
	if ( !IsFullyConnected() )
		return

	local button = level.BtnBlackMarket
	if ( buttonOverride != null )
		button = buttonOverride

	if ( IsBlackMarketUnlocked() )
	{
		local coinCount = GetPersistentVar( "bm.coinCount" )
		button.SetText( "#SHOP_LOBBY_BUTTON", coinCount )

		button.Show()
		button.SetEnabled( true )

		button.SetNew( GetPersistentVar( "bm.newBlackMarketItems" ) )
	}
	else
	{
		button.Hide()
		button.SetEnabled( false )
	}

	if ( IsPrivateMatch() && !IsDelta() )
	{
		button.Hide()
		button.SetEnabled( false )
	}
}