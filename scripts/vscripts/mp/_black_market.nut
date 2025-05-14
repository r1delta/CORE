function ClientCommand_ShopPurchaseRequest(player, ... ) {

	local string = vargv[0]

    // call ServerCallback_ShopOpenBurnCardPack

    // give a punch of 5 index cards
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
    }

    return true
}


function GenerateRandomBurnCardPack(pack_data)
{
    // Define which indices are rare cards
    local rareCardIndices = [50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65]

    // Get configuration from pack data
    local totalCards = pack_data.itemCount   // Total cards in this pack type
    local minRares = pack_data.rareCount     // Minimum guaranteed rare cards
    local packID = pack_data.itemID          // Package ID for special handling

    printt("Generating pack with " + totalCards + " cards, minimum " + minRares + " rare cards for " + packID)

    local packCards = []
    local raresAdded = 0

    // Special case for premium pack (all rares)
    if (packID == "shop_bc_pack_core_premium")
    {
        for (local i = 0; i < totalCards; i++)
        {
            local rareIndex = RandomInt(0,rareCardIndices.len())
            local cardIndex = rareCardIndices[rareIndex]
            packCards.append(cardIndex)
        }

        // Print results and return
        local cardList = ""
        foreach (card in packCards)
            cardList += card + " "
        printt("Generated premium pack with all rare cards: " + cardList)
        return packCards
    }

    // Special case handling for themed packs - using cardRef filtering
    local eligibleCommons = []
    local eligibleRares = []

    // Filter cards by type based on pack ID
    switch(packID)
    {
        case "shop_bc_ability_pack":
            // Filter for tactical ability cards (cloak, stim, sonar)
            eligibleRares = [50, 52, 54, 57, 58]  // Rare tactical-related cards
            eligibleCommons = [1, 2, 3, 39, 40, 41, 42, 43, 44]  // Common tactical-related cards
            break

        case "shop_bc_ordnance_pack":
            // Filter for ordnance cards (grenades, explosives)
            eligibleRares = []  // No rares for this pack (per pack definition)
            eligibleCommons = [8, 9, 10, 11]  // Ordnance cards
            break

        case "shop_bc_boost_pack":
            // Time boost related cards
            eligibleRares = []  // No rares for this pack (per pack definition)
            eligibleCommons = [34, 35, 36, 37, 38, 40]  // XP/Time boost cards
            break

        case "shop_bc_weapons_pack":
            // Weapon cards
            eligibleRares = [50, 51, 55, 56]  // Rare weapon cards
            eligibleCommons = [4, 5, 6, 7, 12, 13, 14, 16, 17, 20, 21, 22, 23, 26, 28, 30, 31, 32]  // Common weapons
            break

        case "shop_bc_intel_pack":
            // Intel-related cards
            eligibleRares = [44, 45]  // Rare intel cards
            eligibleCommons = [2, 42, 43, 49, 51]  // Common intel cards
            break

        case "shop_bc_pack_titan":
            // Titan-related cards
            eligibleRares = [54, 55, 56] // Titan rare cards
            eligibleCommons = [46, 59]   // Titan common cards
            break

        case "shop_bc_pack_team_defense":
            // Team defense cards
            eligibleRares = [52, 60]  // Team defense rares
            eligibleCommons = [41, 43, 60]  // Team defense commons
            break

        default:
            // Regular core pack - use all cards
            eligibleRares = rareCardIndices

            // Create array of all common indices (1-49)
            for (local i = 1; i <= 49; i++)
                eligibleCommons.append(i)
            break
    }

    // If we somehow ended up with no eligible cards for either category, use defaults
    if (eligibleRares.len() == 0 && minRares > 0)
        eligibleRares = rareCardIndices

    if (eligibleCommons.len() == 0)
        for (local i = 1; i <= 49; i++)
            eligibleCommons.append(i)

    // First, add the guaranteed rare cards if any
    for (local i = 0; i < minRares; i++)
    {
        if (eligibleRares.len() == 0)
            break

        // Pick a random rare card from eligible pool
        local rareIndex = RandomInt(eligibleRares.len())
        local cardIndex = eligibleRares[rareIndex]
        packCards.append(cardIndex)
        raresAdded++
    }

    // Then fill the rest with appropriate cards
    for (local i = raresAdded; i < totalCards; i++)
    {
        local cardIndex

        // For packs that can have rare cards, give a small chance for additional rares
        if (minRares > 0 && eligibleRares.len() > 0 && RandomFloat(0.15,1.0) <= 0.15)  // 15% chance for additional rare
        {
            // Pick a random rare card from eligible pool
            local rareIndex = RandomInt(eligibleRares.len())
            cardIndex = eligibleRares[rareIndex]
        }
        else
        {
            // Get a random index from eligible commons
            local commonIndex = RandomInt(eligibleCommons.len())
            cardIndex = eligibleCommons[commonIndex]
        }

        packCards.append(cardIndex)
    }

    // Print the results for debugging
    local cardList = ""
    foreach (card in packCards)
        cardList += card + " "
    printt("Generated cards for " + packID + ": " + cardList)

    return packCards
}

// ShopPurchaseRequest
function main()
{
    AddClientCommandCallback( "ShopPurchaseRequest", ClientCommand_ShopPurchaseRequest ) //

}