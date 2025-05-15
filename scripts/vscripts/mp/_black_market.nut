function ClientCommand_ShopPurchaseRequest(player, ... ) {

	local string = vargv[0]
    printt("ClientCommand_ShopPurchaseRequest: " + string)

 // if the item is not in shopInventoryData, then its a perishable and we should let the user buy it
    if ( !( string in level.shopInventoryData ) )    {
        // this is a perishable
        local index = GetPlayerPerishableIndexFromRef( player, string )
        if ( index == -1 )
        {
            printt("ClientCommand_ShopPurchaseRequest: " + string + " not a perishable")
            return false
        }
        local perishable = GetPlayerPerishable( player, index )
        if ( perishable == null )
        {
            printt("ClientCommand_ShopPurchaseRequest: " + string + " not a perishable")
            return false
        }
        local coinCount = player.GetPersistentVar( "bm.coinCount" )
        local coinCost = perishable.coinCost
        if ( coinCount < coinCost )
        {
            printt("ClientCommand_ShopPurchaseRequest: " + string + " not enough coins")
            return false
        }
        player.SetPersistentVar( "bm.coinCount", coinCount - coinCost )
        local deck = GetPlayerBurnCardDeck( player )
        deck.append( { cardRef = perishable.cardRef, new = true } )
        FillBurnCardDeckFromArray( player, deck )
        local unixTimeNow = Daily_GetCurrentTime()
        player.SetPersistentVar( "bm.blackMarketPerishables[" + index + "].nextRestockDate", unixTimeNow + 86400 )
        player.SetPersistentVar( "bm.blackMarketPerishables[" + index + "].new", false )
        player.SetPersistentVar( "bm.blackMarketPerishables[" + index + "].cardRef", null )
        player.SetPersistentVar( "bm.blackMarketPerishables[" + index + "].coinCost", 0 )
        player.SetPersistentVar( "bm.blackMarketPerishables[" + index + "].perishableType", null )
        player.SetPersistentVar( "bm.blackMarketPerishables[" + index + "].nextRestockDate", 0 )
        Remote.CallFunction_UI(player,"ServerCallback_ShopPurchaseStatus", eShopResponseType.SUCCESS_PERISHABLE)
        return true
    }

    switch(level.shopInventoryData[ string ].itemType) {
        case eShopItemType.BURNCARD_PACK:
            local cards = GenerateRandomBurnCardPack(level.shopInventoryData[ string ])
            // server callback wants the index as a list of params
            // so we need to convert the array to a list of params
            // this is a bit of a hack, but it works
            switch (cards.len()) {
                case 1:
                    Remote.CallFunction_UI(player,"ServerCallback_ShopOpenBurnCardPack", null, cards[0] )
                    break
                case 2:
                    Remote.CallFunction_UI(player,"ServerCallback_ShopOpenBurnCardPack", null, cards[0], cards[1] )
                    break
                case 3:
                    Remote.CallFunction_UI(player,"ServerCallback_ShopOpenBurnCardPack", null, cards[0], cards[1], cards[2] )
                    break
                case 4:
                    Remote.CallFunction_UI(player,"ServerCallback_ShopOpenBurnCardPack", null, cards[0], cards[1], cards[2], cards[3] )
                    break
                case 5:
                    Remote.CallFunction_UI(player,"ServerCallback_ShopOpenBurnCardPack", null, cards[0], cards[1], cards[2], cards[3], cards[4] )
                    break
                case 6:
                    Remote.CallFunction_UI(player,"ServerCallback_ShopOpenBurnCardPack", null, cards[0], cards[1], cards[2], cards[3], cards[4], cards[5] )
                    break
            }
            local coinCount = player.GetPersistentVar( "bm.coinCount" )
            local coinCost = level.shopInventoryData[ string ].coinCost
            player.SetPersistentVar( "bm.coinCount", coinCount - coinCost )
            local deck = GetPlayerBurnCardDeck( player )

            foreach( card in cards ) {
                deck.append( { cardRef = level.indexToBurnCard[card], new = true } )
            }
            FillBurnCardDeckFromArray( player, deck )
            break
        case eShopItemType.PERISHABLE:
            local cardRef = level.indexToBurnCard[ level.shopInventoryData[ string ].itemID ]
            local deck = GetPlayerBurnCardDeck( player )
            deck.append( { cardRef = cardRef, new = true } )
            FillBurnCardDeckFromArray( player, deck )
            break
    }

    return true
}

function GetPlayerPerishableIndexFromRef(player,cardRef) {
    local prefix = "bm.blackMarketPerishables"
    for (local i = 0; i < 9; i++)
    {
        local perishableRef = player.GetPersistentVar( prefix + "[" + i + "].cardRef" )
        if (perishableRef == cardRef)
        {
            return i
        }
    }
    return -1
}

function MakeCardArrayForPack( minimumRares, totalCards, flags, allRare = false )
{
    local pack = []

    local currentRareCount = 0
    local passedFlag = false

    if ( allRare )
        minimumRares = totalCards

    for( local i = 0; i < totalCards; i++ )
    {
        passedFlag = false

        local cardRef = GetRandomBurnCard()
        local rarity = GetBurnCardRarity( cardRef )
        local cardFlags = GetBurnCardFlags( cardRef )

        if ( minimumRares == 0 && rarity == BURNCARD_RARE )
        {
            i--
            continue
        }

        if ( currentRareCount < minimumRares && rarity == BURNCARD_RARE )
            currentRareCount++
        else if ( currentRareCount < minimumRares )
        {
            i--
            continue
        }

        if ( flags.len() > 0 )
        {
            foreach ( flag in flags )
            {
                if ( cardFlags & flag )
                    passedFlag = true
            }

            if ( !passedFlag )
            {
                i--
                continue
            }
        }

        local cardIndex = GetBurnCardIndex( cardRef )
        pack.append( cardIndex )
    }

    return pack
}

function GenerateRandomBurnCardPack( pack_data )
{
    local totalCards = pack_data.itemCount   // Total cards in this pack type
    local minRares = pack_data.rareCount     // Minimum guaranteed rare cards
    local packID = pack_data.itemID

    local cardPack = []

    local minRaresFulfilled = minRares

    // Filter cards by type based on pack ID
    switch( packID )
    {
        case "shop_bc_pack_core":
            cardPack = MakeCardArrayForPack( minRares, totalCards, [] )
            break
        case "shop_bc_pack_core_premium":
            cardPack = MakeCardArrayForPack( minRares, totalCards, [], true )
            break
        case "shop_bc_ability_pack":
            cardPack = MakeCardArrayForPack( minRares, totalCards, [ CT_SPECIAL, CT_TACTICAL ] )
            break
        case "shop_bc_ordnance_pack":
            cardPack = MakeCardArrayForPack( minRares, totalCards, [ CT_ORDNANCE ] )
            break
        case "shop_bc_boost_pack":
            cardPack = MakeCardArrayForPack( minRares, totalCards, [ CT_BUILDTIME ] )
            break
        case "shop_bc_weapons_pack":
            cardPack = MakeCardArrayForPack( minRares, totalCards, [ CT_WEAPON, CT_TITAN_WPN ] )
            break
        case "shop_bc_intel_pack":
            cardPack = MakeCardArrayForPack( minRares, totalCards, [ CT_INTEL ] )
            break
        case "shop_bc_pack_titan":
            cardPack = MakeCardArrayForPack( minRares, totalCards, [ CT_TITAN, CT_TITAN_WPN ] )
            break
        case "shop_bc_pack_team_defense":
            break

        default:
            break
    }

    return cardPack
}


function MakeBlackMarketPerishable( player, cardRef, coinCost,i )
{
    local perishable = {}
    perishable.nextRestockDate <- 0
    perishable.perishableType <- "perishable_burncard"
    perishable.cardRef <- cardRef
    perishable.coinCost <- coinCost
    perishable.new <- true
    player.SetPersistentVar( "bm.blackMarketPerishables[" + i + "]", perishable )
    player.SetPersistentVar( "bm.blackMarketPerishables[" + i + "].nextRestockDate", perishable.nextRestockDate )
    player.SetPersistentVar( "bm.blackMarketPerishables[" + i + "].perishableType", perishable.perishableType )
    player.SetPersistentVar( "bm.blackMarketPerishables[" + i + "].cardRef", perishable.cardRef )
    player.SetPersistentVar( "bm.blackMarketPerishables[" + i + "].coinCost", perishable.coinCost )
    player.SetPersistentVar( "bm.blackMarketPerishables[" + i + "].new", perishable.new )

}

function OnBlackMarketConnect(player) {
    // for(local i = 0; i < 9; i++)
    // {
    //     local cardRef = GetRandomBurnCard()
    //     printt("OnBlackMarketConnect: " + cardRef)
       
    //     MakeBlackMarketPerishable( player, cardRef, 1000, i )
    // }
}

// ShopPurchaseRequest
function main()
{
    AddClientCommandCallback( "ShopPurchaseRequest", ClientCommand_ShopPurchaseRequest ) //
    AddCallback_OnClientConnected( OnBlackMarketConnect ) //
}