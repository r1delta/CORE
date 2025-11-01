function main()
{
	Globalize( CreatePerishableItems )
	Globalize( HidePerishableItemImage )
	Globalize( ShowPerishableItemImage )
}

function CreatePerishableItems()
{
	if ( !IsFullyConnected() )
		return

	local max = PersistenceGetArrayCount( "bm.blackMarketPerishables" )

	for ( local i = 0; i < max; i++ )
	{
		local perishable = GetPerishable( i )
		if ( perishable.perishableType == null )
			continue

		switch ( perishable.perishableType )
		{
			case "perishable_burncard":

				CreatePerishableBurnCard( perishable )
				break
		}
	}
}

function CreatePerishableBurnCard( perishable )
{
	local cardRef = perishable.cardRef

	// persistence has two of same item for some reason
	if ( cardRef in level.shopInventoryData )
		return

	local itemCount = 1
	local rareCount = 0

	local rarity = GetBurnCardRarity( cardRef )

	if ( rarity == BURNCARD_RARE )
		rareCount++

	local description = GetBurnCardDescription( cardRef )
	local image = GetBurnCardImage( cardRef )
	local coinCost = perishable.coinCost
	local name = GetBurnCardTitle( cardRef )

	local table = CreateShopItem( cardRef, eShopItemType.PERISHABLE, name, description, "", itemCount, rareCount, image, coinCost )
	table.perishable = perishable
}


function ShowPerishableItemImage( elem, perishable )
{
	switch ( perishable.perishableType )
	{
		case "perishable_burncard":
			ShowPreviewCard( elem )
			SetPreviewCard( perishable.cardRef, elem )
			break
	}
}

function HidePerishableItemImage( elem )
{
	HidePreviewCard( elem )
}
