::levelUpCardPacks <- {}

function main()
{
    Globalize( AddBurnCardLevelingPack )
    Globalize( TryBurnCardRewardForLevel )
    Globalize( InitBurncardPackLevels )
}

function AddBurnCardLevelingPack( cardPackName, cardPackArray )
{
    levelUpCardPacks[cardPackName] <- cardPackArray
}

function TryBurnCardRewardForLevel( player, newLevel )
{
    local deck = GetPlayerBurnCardDeck( player )
    local cardPack = []

    switch( newLevel )
    {
        case 25:
            cardPack = levelUpCardPacks["burn_card_pack_1"]
            break
        case 30:
            cardPack = levelUpCardPacks["burn_card_pack_2"]
            break
        case 40:
            cardPack = levelUpCardPacks["burn_card_pack_3"]
            break
        case 45:
            cardPack = levelUpCardPacks["burn_card_pack_4"]
            break
        case 50:
            cardPack = levelUpCardPacks["burn_card_pack_5"]
            break
        default:
            return
    }

    foreach( card in cardPack )
        deck.append( { cardRef = card, new = true } )

    FillBurnCardDeckFromArray( player, deck )
}

// don't think this does anything considering the rewards are static
function InitBurncardPackLevels( a1, a2 )
{
    // printt( "Hit stubbed call to InitBurncardPackLevels" );
}