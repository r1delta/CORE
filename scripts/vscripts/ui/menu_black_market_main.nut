
function main()
{
	Globalize( InitBlackMarketMainMenu )
	Globalize( OnOpenBlackMarketMainMenu )
	Globalize( BlackMarketMain_FooterData )

	level.shopMainMenu						<- {}
	level.shopMainMenu.menu 				<- null
	level.shopMainMenu.categoryKeyArt 		<- null
	level.shopMainMenu.categoryDesc 		<- null
}


function InitBlackMarketMainMenu( menu )
{
	level.shopMainMenu.menu = menu
	level.shopMainMenu.categoryKeyArt = level.shopMainMenu.menu.GetChild( "CategoryKeyArt" )
	level.shopMainMenu.categoryDesc = level.shopMainMenu.menu.GetChild( "CategoryInfoLabel" )

	InitCategoryItemButtons()

	local marketMenu = GetMenu( "BlackMarketMenu" )
	InitBlackMarketMenu( marketMenu )
}


function OnOpenBlackMarketMainMenu()
{
	// Hide the Insignias if you can't make custom titans for some reason
	local titanDecalsBtns = GetElementsByClassname( level.shopMainMenu.menu, "BtnTitanDecals" )

	// If players have regen'd, override the IsItemLocked()
	if ( GetGen() > 0 )
		titanDecalsBtns[0].Show()
	else if ( IsItemLocked( "edit_titans" ) )
		titanDecalsBtns[0].Hide()
	else
		titanDecalsBtns[0].Show()

	InitCoins()
}


function InitCoins()
{
	if ( !IsFullyConnected() )
		return

	local coinCount = GetPersistentVar( "bm.coinCount" )
	local coinsPanel = level.shopMainMenu.menu.GetChild( "PlayerCoinsPanel" )
	local playerCoinLabel = coinsPanel.GetChild( "PlayerCoinAmountLabel" )
	playerCoinLabel.SetText( "#CASH_AMOUNT_LABEL", coinCount )
}


function InitCategoryItemButtons()
{
	local burnCardPacksBtns = GetElementsByClassname( level.shopMainMenu.menu, "BtnBurnCardPacks" )
	burnCardPacksBtns[0].s.itemType <- eShopItemType.BURNCARD_PACK
	burnCardPacksBtns[0].AddEventHandler( UIE_GET_FOCUS, ShopCategoryButtonFocused )

	local perishablesBtns = GetElementsByClassname( level.shopMainMenu.menu, "BtnPerishables" )
	perishablesBtns[0].s.itemType <- eShopItemType.PERISHABLE
	perishablesBtns[0].AddEventHandler( UIE_GET_FOCUS, ShopCategoryButtonFocused )

	local titanDecalsBtns = GetElementsByClassname( level.shopMainMenu.menu, "BtnTitanDecals" )
	titanDecalsBtns[0].s.itemType <- eShopItemType.TITAN_DECAL
	titanDecalsBtns[0].AddEventHandler( UIE_GET_FOCUS, ShopCategoryButtonFocused )

	local titanOSVoicesBtns = GetElementsByClassname( level.shopMainMenu.menu, "BtnTitanOSVoices" )
	titanOSVoicesBtns[0].s.itemType <- eShopItemType.TITAN_OS_VOICE_PACK
	titanOSVoicesBtns[0].AddEventHandler( UIE_GET_FOCUS, ShopCategoryButtonFocused )

	local challengeSkipBtns = GetElementsByClassname( level.shopMainMenu.menu, "BtnChallengeSkips" )
	challengeSkipBtns[0].s.itemType <- eShopItemType.CHALLENGE_SKIP
	challengeSkipBtns[0].AddEventHandler( UIE_GET_FOCUS, ShopCategoryButtonFocused )



	//burnCardPacksBtns[0].AddEventHandler( UIE_LOSE_FOCUS, ShopCategoryButtonLoseFocus )
}


function ShopCategoryButtonFocused( button )
{
	Assert( "itemType" in button.s )

	switch ( button.s.itemType )
	{
		case eShopItemType.BURNCARD_PACK:
			level.shopMainMenu.categoryKeyArt.SetImage( "burncards/burncard_art_62" )
			level.shopMainMenu.categoryDesc.SetText( "#SHOP_ITEM_DESC_BURN_CARDS" )
			level.shopMainMenu.categoryKeyArt.Show()
			level.shopMainMenu.categoryDesc.Show()
			break

		case eShopItemType.TITAN_DECAL:
			level.shopMainMenu.categoryKeyArt.SetImage( "black_market/decal_keyart" )
			level.shopMainMenu.categoryDesc.SetText( "#SHOP_ITEM_DESC_TITAN_DECALS" )
			level.shopMainMenu.categoryKeyArt.Show()
			level.shopMainMenu.categoryDesc.Show()
			break

		case eShopItemType.PERISHABLE:
			level.shopMainMenu.categoryKeyArt.SetImage( "burncards/special_items_art" )
			level.shopMainMenu.categoryDesc.SetText( "#SHOP_ITEM_DESC_PERISHABLES" )
			level.shopMainMenu.categoryKeyArt.Show()
			level.shopMainMenu.categoryDesc.Show()
			break

		case eShopItemType.TITAN_OS_VOICE_PACK:
			level.shopMainMenu.categoryKeyArt.SetImage( "black_market/os_voice_packs_keyart" )
			level.shopMainMenu.categoryDesc.SetText( "#SHOP_ITEM_DESC_TITAN_VO_PACKS" )
			level.shopMainMenu.categoryKeyArt.Show()
			level.shopMainMenu.categoryDesc.Show()
			break

		case eShopItemType.CHALLENGE_SKIP:
			level.shopMainMenu.categoryKeyArt.SetImage( "black_market/forged_documents" )
			level.shopMainMenu.categoryDesc.SetText( "#SHOP_ITEM_DESC_CHALLENGE_SKIP" )
			level.shopMainMenu.categoryKeyArt.Show()
			level.shopMainMenu.categoryDesc.Show()
			break

		case eShopItemType.BURNCARD_UPGRADE:
		default:
			level.shopMainMenu.categoryKeyArt.Hide()
			level.shopMainMenu.categoryDesc.Hide()
			break
	}
}

function ShopCategoryButtonLoseFocus( button )
{
	level.shopMainMenu.categoryKeyArt.Hide()
	level.shopMainMenu.categoryDesc.Hide()
}

function BlackMarketMain_FooterData( footerData )
{
	footerData.gamepad.append( { label = "#A_BUTTON_SELECT" } )

	footerData.gamepad.append( { label = "#B_BUTTON_BACK" } )
	footerData.pc.append( { label = "#BACK", func = PCBackButton_Activate } )
}