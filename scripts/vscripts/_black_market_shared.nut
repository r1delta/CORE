function main()
{
	Globalize( GetSortedShopInventory )
	Globalize( CoinCostLowToHigh )
	Globalize( CoinCostHighToLow )
	Globalize( CanBuyItem )
	Globalize( GetItemCost )
	Globalize( GetShopItemType )
	Globalize( InitShopInventory )
	Globalize( CreateShopItem )
	Globalize( IsBlackMarketUnlocked )
	Globalize( GetCoinEarnModifier )
	Globalize( GetShopPriceModifier )
	Globalize( GetBurnCardSellAmountModifier )
	Globalize( GetShopItemQuantity )
	Globalize( GetItemByIndex )

	level.shopInventoryData <- null

	if ( !IsClient() )
		IncludeFile( "_black_market_perish_shared" )

	if ( !IsUI() )
	{
		InitShopInventory()
	}

	if ( !IsUI() )
	{
		PrecacheMaterial( "vgui/black_market/cardpack_standard" )
		PrecacheMaterial( "vgui/black_market/cardpack_premium" )
		PrecacheMaterial( "vgui/black_market/cardpack_tactical_ability" )
		PrecacheMaterial( "vgui/black_market/cardpack_ordnance" )
		PrecacheMaterial( "vgui/black_market/cardpack_time_boost" )
		PrecacheMaterial( "vgui/black_market/cardpack_weapons" )
		PrecacheMaterial( "vgui/black_market/cardpack_intel" )
		PrecacheMaterial( "vgui/black_market/cardpack_titan" )
		PrecacheMaterial( "vgui/black_market/cardpack_pilot" )
		PrecacheMaterial( "vgui/black_market/decal_keyart" )
		PrecacheMaterial( "vgui/black_market/os_voice_packs_keyart" )
		PrecacheMaterial( "vgui/burncards/special_items_art" )
		PrecacheMaterial( "vgui/burncards/burncard_art_62" )
		PrecacheMaterial( "vgui/black_market/forged_documents" )
		PrecacheMaterial( "vgui/black_market/forged_documents_object" )
	}
}

// This is where design adds items to the shop
function InitShopInventory()
{
	level.shopInventoryData = {}

	// Burn Card Packs
	CreateShopItem( "shop_bc_pack_core",			eShopItemType.BURNCARD_PACK, 		"#SHOP_ITEM_BC_PACK_CORE",					"#SHOP_ITEM_BC_PACK_CORE_DESC",				"#SHOP_ITEM_BC_MIN_RARE_MAYBE", 	6,	 	1, 		"black_market/cardpack_standard",				10000 )
	CreateShopItem( "shop_bc_pack_core_premium",	eShopItemType.BURNCARD_PACK, 		"#SHOP_ITEM_BC_PACK_CORE_PREMIUM",			"#SHOP_ITEM_BC_PACK_CORE_PREMIUM_DESC",		"#SHOP_ITEM_BC_ALL_RARES", 			5,		1, 		"black_market/cardpack_premium",				50000 )
	CreateShopItem( "shop_bc_ability_pack",			eShopItemType.BURNCARD_PACK, 		"#SHOP_ITEM_BC_PACK_ABILITIES",				"#SHOP_ITEM_BC_PACK_ABILITIES_DESC",		"#SHOP_ITEM_BC_MIN_RARE_MAYBE", 	6,		1,		"black_market/cardpack_tactical_ability",		20000 )
	CreateShopItem( "shop_bc_ordnance_pack",		eShopItemType.BURNCARD_PACK, 		"#SHOP_ITEM_BC_PACK_ORDNANCE",				"#SHOP_ITEM_BC_PACK_ORDNANCE_DESC",			"#SHOP_ITEM_BC_NO_RARES", 			6,		0, 		"black_market/cardpack_ordnance",				20000 )
	CreateShopItem( "shop_bc_boost_pack",			eShopItemType.BURNCARD_PACK, 		"#SHOP_ITEM_BC_PACK_TIMEBOOST",				"#SHOP_ITEM_BC_PACK_TIMEBOOST_DESC",		"#SHOP_ITEM_BC_NO_RARES", 			6,		0, 		"black_market/cardpack_time_boost",				20000 )
	CreateShopItem( "shop_bc_weapons_pack",			eShopItemType.BURNCARD_PACK, 		"#SHOP_ITEM_BC_PACK_WEAPONS",				"#SHOP_ITEM_BC_PACK_WEAPONS_DESC",			"#SHOP_ITEM_BC_MIN_RARE_MAYBE", 	6,		1, 		"black_market/cardpack_weapons",				20000 )
	CreateShopItem( "shop_bc_intel_pack",			eShopItemType.BURNCARD_PACK, 		"#SHOP_ITEM_BC_PACK_INTEL",					"#SHOP_ITEM_BC_PACK_INTEL_DESC",			"#SHOP_ITEM_BC_MIN_RARE_MAYBE", 	6,		1, 		"black_market/cardpack_intel",					20000 )
	CreateShopItem( "shop_bc_pack_titan",			eShopItemType.BURNCARD_PACK, 		"#SHOP_ITEM_BC_PACK_TITAN_SMALL", 			"#SHOP_ITEM_BC_PACK_TITAN_SMALL_DESC", 		"#SHOP_ITEM_BC_MIN_RARE_MAYBE",		3,		1,		"black_market/cardpack_titan",					30000 )
	// is this even real?
	//CreateShopItem( "shop_bc_pack_team_defense",	eShopItemType.BURNCARD_PACK, 		"#SHOP_ITEM_BC_PACK_TEAM_DEFENSE", 			"#SHOP_ITEM_BC_PACK_TEAM_DEFENSE_DESC", 	"#SHOP_ITEM_BC_MIN_RARE_MAYBE",		6,		1,		"black_market/cardpack_pilot",					20000 )

	// Titan Insignias
	CreateShopItem( "titan_decals_blackmarket01",	eShopItemType.TITAN_DECAL, 			"#TITAN_DECAL_BLACKMARKET01_NAME",		"#TITAN_DECAL_BLACKMARKET01_DESC",			"", 	1,		0, 		"../models/titans/custom_decals/decal_pack_01/titan_decals_blackmarket01_menu",		5000 )
	CreateShopItem( "titan_decals_blackmarket02",	eShopItemType.TITAN_DECAL, 			"#TITAN_DECAL_BLACKMARKET02_NAME",		"#TITAN_DECAL_BLACKMARKET02_DESC",			"", 	1,		0, 		"../models/titans/custom_decals/decal_pack_01/titan_decals_blackmarket02_menu",		10000 )
	CreateShopItem( "titan_decals_blackmarket03",	eShopItemType.TITAN_DECAL, 			"#TITAN_DECAL_BLACKMARKET03_NAME",		"#TITAN_DECAL_BLACKMARKET03_DESC",			"", 	1,		0, 		"../models/titans/custom_decals/decal_pack_01/titan_decals_blackmarket03_menu",		15000 )
	CreateShopItem( "titan_decals_blackmarket04",	eShopItemType.TITAN_DECAL, 			"#TITAN_DECAL_BLACKMARKET04_NAME",		"#TITAN_DECAL_BLACKMARKET04_DESC",			"", 	1,		0, 		"../models/titans/custom_decals/decal_pack_01/titan_decals_blackmarket04_menu",		20000 )
	CreateShopItem( "titan_decals_blackmarket05",	eShopItemType.TITAN_DECAL, 			"#TITAN_DECAL_BLACKMARKET05_NAME",		"#TITAN_DECAL_BLACKMARKET05_DESC",			"", 	1,		0, 		"../models/titans/custom_decals/decal_pack_01/titan_decals_blackmarket05_menu",		25000 )
	CreateShopItem( "titan_decals_blackmarket06",	eShopItemType.TITAN_DECAL, 			"#TITAN_DECAL_BLACKMARKET06_NAME",		"#TITAN_DECAL_BLACKMARKET06_DESC",			"", 	1,		0, 		"../models/titans/custom_decals/decal_pack_01/titan_decals_blackmarket06_menu",		30000 )
	CreateShopItem( "titan_decals_blackmarket07",	eShopItemType.TITAN_DECAL, 			"#TITAN_DECAL_BLACKMARKET07_NAME",		"#TITAN_DECAL_BLACKMARKET07_DESC",			"", 	1,		0, 		"../models/titans/custom_decals/decal_pack_01/titan_decals_blackmarket07_menu",		40000 )
	CreateShopItem( "titan_decals_blackmarket08",	eShopItemType.TITAN_DECAL, 			"#TITAN_DECAL_BLACKMARKET08_NAME",		"#TITAN_DECAL_BLACKMARKET08_DESC",			"", 	1,		0, 		"../models/titans/custom_decals/decal_pack_01/titan_decals_blackmarket08_menu",		35000 )

	CreateShopItem( "titanos_maleintimidator",	eShopItemType.TITAN_OS_VOICE_PACK, 		"#TITAN_OS_MALE_INTIMIDATOR_NAME",		"#TITAN_OS_MALE_INTIMIDATOR_BLACK_MARKET_DESC",			"", 	1,		0, 		"../ui/menu/voice_personality_icons/syd_voice_icon",			30000 )
	CreateShopItem( "titanos_femaleassistant",	eShopItemType.TITAN_OS_VOICE_PACK, 		"#TITAN_OS_FEMALE_ASSISTANT_NAME",		"#TITAN_OS_FEMALE_ASSISTANT_BLACK_MARKET_DESC",			"", 	1,		0, 		"../ui/menu/voice_personality_icons/jessica_voice_icon",		30000 )
	CreateShopItem( "titanos_bettyde",			eShopItemType.TITAN_OS_VOICE_PACK, 		"#TITAN_OS_BETTYDE_NAME",				"#TITAN_OS_BETTYDE_LONGDESC",							"", 	1,		0, 		"../ui/menu/voice_personality_icons/betty_de_voice_icon",		20000 )
	CreateShopItem( "titanos_bettyen",			eShopItemType.TITAN_OS_VOICE_PACK, 		"#TITAN_OS_BETTYEN_NAME",				"#TITAN_OS_BETTYEN_LONGDESC",							"", 	1,		0, 		"../ui/menu/voice_personality_icons/betty_en_voice_icon",		20000 )
	CreateShopItem( "titanos_bettyes",			eShopItemType.TITAN_OS_VOICE_PACK, 		"#TITAN_OS_BETTYES_NAME",				"#TITAN_OS_BETTYES_LONGDESC",							"", 	1,		0, 		"../ui/menu/voice_personality_icons/betty_es_voice_icon",		20000 )
	CreateShopItem( "titanos_bettyfr",			eShopItemType.TITAN_OS_VOICE_PACK, 		"#TITAN_OS_BETTYFR_NAME",				"#TITAN_OS_BETTYFR_LONGDESC",							"", 	1,		0, 		"../ui/menu/voice_personality_icons/betty_fr_voice_icon",		20000 )
	CreateShopItem( "titanos_bettyit",			eShopItemType.TITAN_OS_VOICE_PACK, 		"#TITAN_OS_BETTYIT_NAME",				"#TITAN_OS_BETTYIT_LONGDESC",							"", 	1,		0, 		"../ui/menu/voice_personality_icons/betty_it_voice_icon",		20000 )
	CreateShopItem( "titanos_bettyjp",			eShopItemType.TITAN_OS_VOICE_PACK, 		"#TITAN_OS_BETTYJP_NAME",				"#TITAN_OS_BETTYJP_LONGDESC",							"", 	1,		0, 		"../ui/menu/voice_personality_icons/betty_jp_voice_icon",		20000 )
	CreateShopItem( "titanos_bettyru",			eShopItemType.TITAN_OS_VOICE_PACK, 		"#TITAN_OS_BETTYRU_NAME",				"#TITAN_OS_BETTYRU_LONGDESC",							"", 	1,		0, 		"../ui/menu/voice_personality_icons/betty_ru_voice_icon",		20000 )

	CreateShopItem( "challenge_skip", eShopItemType.CHALLENGE_SKIP, "#SHOP_ITEM_CHALLENGE_SKIP_NAME", "#SHOP_ITEM_CHALLENGE_SKIP_DESC", "", 1, 0, "black_market/forged_documents_object", 100000 )

	if ( IsUI() )
	{
		CreatePerishableItems()
	}
}

if ( IsUI() )
{
	function CreateMatchLongUpgradeShopItemFromPersistence( index )
	{
		local cardRef = GetBlackMarketMatchLongUpgradeShopItem( index )
		if ( cardRef != null )
			CreateMatchLongUpgradeShopItem( cardRef )
	}
}

function CreateShopItem( itemID, itemType, name, description, rareDescription, itemCount, rareCount, image, coinCost )
{
	Assert( !( itemID in level.shopInventoryData ), "Shop itemID already created" )
	Assert( coinCost > 0, "Shop item must cost more than 0" )

	local priceModifier = GetShopPriceModifier()

	local table 			= {}
	table.name 				<- name
	table.itemIndex			<- level.shopInventoryData.len()
	table.itemID			<- itemID
	table.itemType			<- itemType
	table.description 		<- description
	table.itemCount			<- itemCount
	table.rareCount			<- rareCount
	table.rareDescription 	<- rareDescription
	table.coinCost 			<- coinCost * priceModifier
	table.image 			<- image
	table.perishable		<- null

	level.shopInventoryData[ itemID ] <- table

	return table
}

function CanBuyItem( itemID, player = null )
{
	if ( IsPrivateMatch() && !IsDelta() )
		return eShopResponseType.FAIL_PRIVATE_MATCH

	local playerCoins = 0

	if ( IsUI() )
	{
		// Invalid itemID?
		if ( !( itemID in level.shopInventoryData ) )
			return eShopResponseType.FAIL_UNKNOWN_ERROR

	    if ( !IsFullyConnected() )
		    return eShopResponseType.FAIL_UNKNOWN_ERROR

		switch ( level.shopInventoryData[ itemID ].itemType )
		{
			case eShopItemType.BURNCARD_PACK:
				// Too many burn cards in the deck?
				local freeSlots = GetMaxStoredBurnCards() - GetTotalBurnCards()
				local rewardCount = GetShopItemQuantity( itemID )

				if ( rewardCount > freeSlots )
					return eShopResponseType.FAIL_BURN_CARDS_FULL
				break
			case eShopItemType.TITAN_OS_VOICE_PACK:
			case eShopItemType.TITAN_DECAL:
				if ( !IsItemLocked( itemID, null, player ) )
					return eShopResponseType.FAIL_ALREADY_UNLOCKED
				break

			case eShopItemType.PERISHABLE:

				// Too many burn cards in the deck?
				local freeSlots = GetMaxStoredBurnCards() - GetTotalBurnCards()

				if ( freeSlots <= 0 )
					return eShopResponseType.FAIL_BURN_CARDS_FULL
				break

			case eShopItemType.CHALLENGE_SKIP:
				break

			default:
				Assert(0, "invalid " + level.shopInventoryData[ itemID ].itemType.tostring() )
				break
		}

		playerCoins = GetPersistentVar( "bm.coinCount" )
	}
	else if ( IsServer() )
	{
		Assert ( player != null )

		if ( !( itemID in level.shopInventoryData ) )
		{
			local perishableTable = GetItemInPlayerPerishables( player, itemID )
			if ( perishableTable == null )
				return eShopResponseType.FAIL_UNKNOWN_ERROR

			local perishable = perishableTable.perishable
			if ( perishable != null )
			{
				return CanBuyPerishable( player, perishable )
			}

			// Invalid itemID
			return eShopResponseType.FAIL_UNKNOWN_ERROR
		}

		playerCoins = player.GetPersistentVar( "bm.coinCount" )

		switch ( level.shopInventoryData[ itemID ].itemType )
		{
			case eShopItemType.BURNCARD_PACK:
				if ( !itemID in level.shopLootTable )
					return eShopResponseType.FAIL_UNKNOWN_ERROR

				// Too many burn cards in the deck?
				local freeSlots = GetPlayerMaxStoredBurnCards( player ) - GetPlayerTotalBurnCards( player )
				local rewardCount = GetShopItemQuantity( itemID )
				if ( rewardCount > freeSlots )
					return eShopResponseType.FAIL_BURN_CARDS_FULL

				break
			case eShopItemType.TITAN_OS_VOICE_PACK:
			case eShopItemType.TITAN_DECAL:
				if ( !IsItemLocked( itemID, null, player ) )
					return eShopResponseType.FAIL_ALREADY_UNLOCKED
				break

			case eShopItemType.CHALLENGE_SKIP:
				break

			default:
				Assert(0, "invalid " + level.shopInventoryData[ itemID ].itemType.tostring() )
				break
		}
	}

	local itemCost = GetItemCost( itemID )

	// Check if player has enough coins
	if ( itemCost > playerCoins )
		return eShopResponseType.FAIL_NOT_ENOUGH_COINS

	// TODO: Additional checks go in here ( item level locked?  etc.)

	return eShopResponseType.SUCCESS
}


function GetCoinEarnModifier()
{
	if ( IsUI() )
	{
		if ( !IsFullyConnected() )
   			return 1.0

		local var = GetCurrentPlaylistVar( "coins_earn_modifier" ) //returns empty string "" if not found
		return var != "" ? var.tofloat() : 1.0
	}
	else
		return GetCurrentPlaylistVarFloat( "coins_earn_modifier", 1.0 )
}

function GetShopPriceModifier()
{
	if ( IsUI() )
	{
		if ( !IsFullyConnected() )
   			return 1.0

		local var = GetCurrentPlaylistVar( "shop_price_modifier" ) //returns empty string "" if not found
		return var != "" ? var.tofloat() : 1.0
	}
	else
		return GetCurrentPlaylistVarFloat( "shop_price_modifier", 1.0 )
}

function GetBurnCardSellAmountModifier()
{
	if ( IsUI() )
	{
		if ( !IsFullyConnected() )
   			return 1.0

		local var = GetCurrentPlaylistVar( "coins_bc_sale_modifier" ) //returns empty string "" if not found
		return var != "" ? var.tofloat() : 1.0
	}
	else
		return GetCurrentPlaylistVarFloat( "coins_bc_sale_modifier", 1.0 )
}

function GetItemCost( itemID )
{
	Assert( itemID in level.shopInventoryData )
	return level.shopInventoryData[ itemID ].coinCost
}

function GetShopItemType( itemID )
{
	Assert( itemID in level.shopInventoryData )
	return level.shopInventoryData[ itemID ].itemType
}

function GetShopItemQuantity( itemID )
{
	if ( IsUI() )
		return ( itemID in level.shopInventoryData ) ? level.shopInventoryData[ itemID ].itemCount : 0
	else
		return ( itemID in level.shopLootTable ) ? level.shopLootTable[ itemID ].itemCount : 0
}

function GetItemByIndex( itemIndex )
{
	foreach ( item in level.shopInventoryData )
	{
		if ( item.itemIndex == itemIndex )
			return item
	}

	return null
}

function GetSortedShopInventory( sortFunc )
{
	local sortedInventory = []
	foreach ( key, value in level.shopInventoryData )
	{
		sortedInventory.append( value )
	}

	sortedInventory.sort( sortFunc )

	return sortedInventory
}


function CoinCostLowToHigh( a, b )
{
	if ( a.coinCost > b.coinCost )
		return 1
	if ( a.coinCost < b.coinCost )
		return -1
	if ( a.coinCost == b.coinCost )
	{
		if ( a.itemIndex > b.itemIndex )
			return 1
		if ( a.itemIndex < b.itemIndex )
			return -1
	}
	return 0
}


function CoinCostHighToLow( a, b )
{
	if ( a.coinCost < b.coinCost )
		return 1
	if ( a.coinCost > b.coinCost )
		return -1
	if ( a.coinCost == b.coinCost )
	{
		if ( a.itemIndex > b.itemIndex )
			return 1
		if ( a.itemIndex < b.itemIndex )
			return -1
	}
	return 0
}

function IsBlackMarketUnlocked( player = null )
{
	local level = null
	local gen   = null
	local completedBurnCardStory = false

	if ( UsingAlternateBurnCardPersistence() )
		return false

	if ( IsUI() )
	{
		if ( !IsFullyConnected() )
			return false

		level = GetLevel()
		gen   = GetGen()
		completedBurnCardStory = GetPersistentVar( "burncardStoryProgress" )
	}
	else
	{
		Assert( player != null )

		level = GetLevel( player )
		gen   = player.GetGen()
		completedBurnCardStory = player.GetPersistentVar( "burncardStoryProgress" )
	}

	Assert ( level != null )
	Assert ( gen != null )

	if ( completedBurnCardStory >= BURNCARD_STORY_PROGRESS_COMPLETE && !IsPlayerEverythingUnlocked( player ) )
	{
		if ( level >= GetUnlockLevelReq( "burn_card_slot_3" ) )
			return true

		if ( gen > 0 )
			return true
	}

	if ( IsPlayerEverythingUnlocked( player ) )
		return true

	return false
}
