function main()
{
	AddClientCommandCallback( "BCStoreActive", BCStoreActive ) //
	AddClientCommandCallback( "BCActivateStored", BCActivateStored ) ///
	AddClientCommandCallback( "BCOpenDelivery", BCOpenDelivery ) //
	AddClientCommandCallback( "BCDiscard", BCDiscard ) //
	AddClientCommandCallback( "OpenedBurnCardMenu", OpenedBurnCardMenu ) //
	AddClientCommandCallback( "MoveCardToActiveSlot", MoveCardToActiveSlot ) //
	AddClientCommandCallback( "MoveCardToDeck", MoveCardToDeck )
	AddClientCommandCallback( "BCSetCurrentPile", BCSetCurrentPile )
	AddClientCommandCallback( "BCSetCurrentOffset", BCSetCurrentOffset )
	AddClientCommandCallback( "BCClearNew", BCClearNew )
	AddClientCommandCallback( "ToggleAutofill", ToggleAutofill )

	RegisterSignal( "NewDiscard" )
}

function ToggleAutofill( player )
{
	local var = _GetBurnCardPersPlayerDataPrefix() + ".autofill"
	local autofill = player.GetPersistentVar( var )
	autofill = !autofill
	player.SetPersistentVar( var, autofill )
	Remote.CallFunction_UI( player, "SCB_UpdateBC" )

	return true
}

function OpenedBurnCardMenu( player )
{
	Remote.CallFunction_NonReplay( player, "ServerCallback_OpenedBurncardMenu" )
	return true
}

function BCStoreActive( player, slotID )
{
	if ( !IsLobby() )
		return true

	slotID = slotID.tointeger()

	if ( slotID < 0 || slotID >= GetPlayerMaxActiveBurnCards( player ) )
		return true

	// no card in this slot
	if ( !GetPlayerActiveBurnCardSlotContents( player, slotID ) )
		return true

	// trading out a card that is activeCard
	StoreActiveCard( player, slotID )
	return true
}


function ClientCommand_ClearDeckNew( player, deckSlotID )
{
	if ( !IsLobby() )
		return true

	return true
}


function BCDiscard( player, index, burnCardIndex )
{
	index = index.tointeger()
	burnCardIndex = burnCardIndex.tointeger()
	local deck = GetPlayerBurnCardDeck( player )
	if ( index < 0 )
		return true
	if ( index >= deck.len() )
		return true

	if ( burnCardIndex < 0 )
		return true
	if ( burnCardIndex >= level.indexToBurnCard.len() )
		return true
	local burnCardRef = level.indexToBurnCard[ burnCardIndex ]

	printt( "discarding " + index + " " + burnCardRef )

	local bcard = deck[ index ]
	if ( bcard.cardRef != burnCardRef )
	{
		printt( "	Wrong, cardref was actually " + bcard.cardRef )
		return true
	}
	deck.remove( index )
	GiveDiscardReward( player, bcard.cardRef )

	FillBurnCardDeckFromArray( player, deck )
	Remote.CallFunction_UI( player, "SCB_UpdateBC" )


	return true
}

function BCOpenDelivery( player )
{
	player.SetPersistentVar( "burncardStoryProgress", BURNCARD_STORY_PROGRESS_COMPLETE )
	return true
}

function BCClearNew( player, index )
{
	index = index.tointeger()
	if ( index < 0 || index >= PersistenceGetArrayCount( _GetBurnCardDeckPersDataPrefix() ) )
		return true

	player.SetPersistentVar( _GetBurnCardPersPlayerDataPrefix() + ".burnCardIsNew[" + index + "]", false )
	return true
}


function BCActivateStored( player, slotID )
{
	if ( !IsLobby() )
		return true

	if ( !GetPlayerStoredBurnCardCount( player, slotID ) )
		return true

	local activeSlotID = FindPlayerFirstEmptyActiveSlot( player )

	if ( activeSlotID == null )
		activeSlotID = (GetPlayerMaxActiveBurnCards( player ) - 1) // last slot for now

	if ( GetPlayerActiveBurnCardSlotContents( player, activeSlotID ) )
		StoreActiveCard( player, activeSlotID )

	MoveStoredSlotToActive( player, slotID, activeSlotID )

	return true
}


function MoveStoredSlotToActive( player, slotID, activeSlotID )
{
	local count = GetPlayerStoredBurnCardCount( player, slotID )
	Assert( count )

	local cardRef = GetPlayerStoredBurnCardRef( player, slotID )
	count--
	SetPlayerStoredBurnCardCount( player, slotID, count )
	if ( count == 0 )
	{
		SetPlayerStoredBurnCardRef( player, slotID, null )
	}
	SetPlayerActiveBurnCardSlotContents( player, activeSlotID, cardRef, false )
}


function StoreActiveCard( player, activeSlotID )
{
	local cardRef = GetPlayerActiveBurnCardSlotContents( player, activeSlotID )
	Assert( cardRef )

	local slotID = GetPlayerBestSlotForBurnCard_PreferStack( player, cardRef )
	local count = GetPlayerStoredBurnCardCount( player, slotID )
	SetPlayerStoredBurnCardCount( player, slotID, count + 1 )
	SetPlayerStoredBurnCardRef( player, slotID, cardRef )
	SetPlayerActiveBurnCardSlotContents( player, activeSlotID, null, false )
	return true
}

function BCSetCurrentPile( player, index )
{
	index = index.tointeger()
	if ( index == null )
		return

	player.SetPersistentVar( "currentBurnCardPile", index )
	return true
}

function BCSetCurrentOffset( player, index, index2 )
{
	index = index.tointeger()
	index2 = index2.tointeger()

	if ( index == null || index2 == null )
		return

	if ( index >= 0 && index <= PersistenceGetArrayCount( "currentBurnCardOffset" ) )
		player.SetPersistentVar( "currentBurnCardOffset[" + index + "]", index2 )
	return true
}


function MoveCardToActiveSlot( player, burnCardIndex, index, activeSlot )
{
	printt( "MoveCardToActiveSlot " + burnCardIndex + " " + index + " " + activeSlot )

	burnCardIndex = burnCardIndex.tointeger()
	if ( burnCardIndex < 0 )
		return true
	if ( burnCardIndex >= level.indexToBurnCard.len() )
		return true
	local burnCardRef = level.indexToBurnCard[ burnCardIndex ]

	index = index.tointeger()
	activeSlot = activeSlot.tointeger()
	local deck = GetPlayerBurnCardDeck( player )
	if ( index < 0 )
		return true
	if ( index >= deck.len() )
		return true

	local cardRef = deck[ index ].cardRef
	if ( cardRef == null )
		return true

	if ( burnCardRef != cardRef )
	{
		printt( "MoveCardToDeck failed, tried to move " + burnCardRef + " but found " + cardRef )
		return true
	}

	if ( activeSlot < 0 )
		return true
	if ( activeSlot >= GetPlayerMaxActiveBurnCards( player ) )
		return true

	local pileActiveBurncard = GetPlayerActiveBurnCardSlotContents( player, activeSlot )
	SetPlayerActiveBurnCardSlotContents( player, activeSlot, cardRef, false )
	deck.remove( index )

	if ( pileActiveBurncard != null )
	{
		deck.append( { cardRef = pileActiveBurncard, new = false } )
	}

	FillBurnCardDeckFromArray( player, deck )

	Remote.CallFunction_UI( player, "SCB_UpdateBCFooter" )

	return true
}

function MoveCardToDeck( player, burnCardIndex, index )
{
	burnCardIndex = burnCardIndex.tointeger()
	if ( burnCardIndex < 0 )
		return true
	if ( burnCardIndex >= level.indexToBurnCard.len() )
		return true
	local burnCardRef = level.indexToBurnCard[ burnCardIndex ]

	index = index.tointeger()
	local burncards = GetPlayerActiveBurnCards( player )
	if ( index >= burncards.len() )
		return true
	if ( index < 0 )
		return true

	if ( burncards[ index ] == null )
		return true

	local cardRef
	cardRef = burncards[ index ]
	if ( burnCardRef != cardRef )
	{
		printt( "MoveCardToDeck failed, tried to move " + burnCardRef + " but found " + cardRef )
		return
	}

	SetPlayerActiveBurnCardSlotContents( player, index, null, false )

	local deck = GetPlayerBurnCardDeck( player )
	FillBurnCardDeckFromArray( player, deck )

	Remote.CallFunction_UI( player, "SCB_UpdateBCFooter" )

	return true
}

function GiveDiscardReward( player, cardRef )
{
	local rarity = GetBurnCardRarity( cardRef )
	local newCoins = GetSellCostOfRarity( rarity )

	local coinModifier = GetBurnCardSellAmountModifier()
	local playerCoins = player.GetPersistentVar( "bm.coinCount" )
	AddCoins( player, newCoins * coinModifier, eCoinRewardType.DISCARD )

	local discardLifetimeTotal = player.GetPersistentVar( "cu8achievement.ach_burncardsDiscarded" )
	player.SetPersistentVar( "cu8achievement.ach_burncardsDiscarded", discardLifetimeTotal + 1 )
}

