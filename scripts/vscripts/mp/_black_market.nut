
function ClientCommand_ShopPurchaseRequest(player, ... ) {
    
	local string = vargv[0]

    printt("ClientCommand_ShopPurchaseRequest", string)

    printt(player)
    // call ServerCallback_ShopOpenBurnCardPack

    // give a punch of 5 index cards
    local cards = [1, 2, 3, 4, 5]
    switch(level.shopInventoryData[ string ].itemType) {
        case eShopItemType.BURNCARD_PACK:
            Remote.CallFunction_UI(player,"ServerCallback_ShopOpenBurnCardPack", null,3,5,3,2)
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

// ShopPurchaseRequest
function main()
{
    AddClientCommandCallback( "ShopPurchaseRequest", ClientCommand_ShopPurchaseRequest ) //

}