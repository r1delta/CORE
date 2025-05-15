const ZOOM_DARKENS = 0
const BURNCARD_MAIL_INTRO = 1
const MAIL_TRANSITION_TIME = 0.20
const MAX_RANGE = 12 // 22 // cards to draw behind the selected card
const MIN_RANGE = 5 // 15 // cards to draw in front of selected card

function main()
{
	Globalize( OpenedBurncardMenu )
	Globalize( ThreadOpenedBurncardMenu )
	Globalize( BurnCards_AddLobbyClient )
	Globalize( MoveSelectedBurnCardToBack )
	Globalize( BurnCardPressedZoomStart   )
	Globalize( BurnCardPressedZoomEnd     )
	Globalize( BurnCardPressedSpreadStart )
	Globalize( BurnCardPressedSpreadEnd   )
	Globalize( BurnCardPushCard           )
	Globalize( BurnCardSelectCard         )
	Globalize( BurnCardReleasedA          )
	Globalize( BurnCardPressedRight       )
	Globalize( BurnCardPressedLeft        )
	Globalize( BurnCardPressedRightMany   )
	Globalize( BurnCardPressedLeftMany    )
	Globalize( BurnCardPressedUp )
	Globalize( BurnCardPressedDown )
	Globalize( DisplayAnyMail )
	Globalize( RefreshCards )

	Globalize( BurnCardActiveSlot_Focus )
	Globalize( BurnCardActiveSlot_Click )

	RegisterSignal( "NewBurncardTipDisplay" )
	RegisterSignal( "NewColorChange" )
	RegisterSignal( "StopBurnCardDisplay" )
	RegisterSignal( "HideOrShowBurnCards" )
	RegisterSignal( "DisplayAnyMail" )
	RegisterSignal( "NewCurrentOffset" )

	file.maxActiveBurnCards <- null
	file.mustDiscard <- false
	file.storedVguis <- []
	file.disableInput <- false

	local ratio = 1.46875
	file.width <- 8
	file.height <- 8 * ratio
	file.newSinTime <- 0
	file.updateDif <- 0

	file.discardedVGUIs <- []
}

function OpenedBurncardMenuInternal()
{
	if ( !file.registeredFunctions )
	{
		InitializePiles()
		file.heldDirection = 0

		file.zoomed = false
		file.spread = false
		file.buttonHeld = {}

		file.registeredFunctions = true
	}
}

function BurnCardMouseDown( player )
{
	TryFinishReadingLetter( player )
}
Globalize( BurnCardMouseDown )

function OpenedBurncardMenu()
{
	file.zoomed = false
	OpenedBurncardMenuInternal()

	local player = GetLocalViewPlayer()
	UpdateHelpButtons( player )

	if ( BurnCardFullyLoaded() )
	{
		thread DisplayAnyMail( player )
		thread RefreshCards( player )
		InstantUpdateOfAllCards()
	}

	SetCurrentPile( PILE_DECK )
	InstantUpdateOfAllCards()
}

function ThreadOpenedBurncardMenu()
{
	thread OpenedBurncardMenu()
}

function BurnCardReleasedA( player )
{
	if ( "a" in file.buttonHeld )
		delete file.buttonHeld[ "a" ]
}

function BurnCardPushCard( player )
{
	if ( !BurnCardFullyLoaded() )
		return
	MoveSelectedBurnCardToBack( player )
}

function BurnCardBack( player )
{
	if ( !BurnCardFullyLoaded() )
		return
	if ( Pile() == PileActive() )
	{
		SetCurrentPile( PILE_DECK )
		return
	}
//	player.ClientCommand( "script_ui CloseTopMenu()" )
	player.ClientCommand( "ExitBurnCardLobbyMenu" )
}
Globalize( BurnCardBack )

function BurnCardDiscard( player )
{
	if ( file.disableInput )
		return

	if ( !BurnCardFullyLoaded() )
		return
	SetCurrentPile( PILE_DECK )
	local pileDeck = PileDeck()
	RemoveSelectedNew( pileDeck )

	if ( pileDeck.offset >= pileDeck.burnCardTables.len() )
		return
	if ( pileDeck.offset < 0 )
		return

	// remove the discarded card
	local discarded = pileDeck.burnCardTables[ pileDeck.offset ]
	pileDeck.burnCardTables.remove( pileDeck.offset )

	// discarded vguis get destroyed later, so they can animate away
	file.discardedVGUIs.append( discarded.vgui )

	// discard animation
	discarded.vgui.s.moveType = 11
	discarded.vgui.s.startMoveTime = Time()
	//discarded.vgui.s.scaleDest = 0.5

	// destroy the discarded burn cards
	thread DestroyBurnCardVGUI( discarded )

	// discard on the server too
	player.ClientCommand( "BCDiscard " + pileDeck.offset + " " + GetBurnCardIndex( discarded.cardRef ) )

	EmitSoundOnEntity( player, "BurnCard_Sell" )

	//EmitSoundOnEntity( player, "Menu_BurnCard_SortToTop" )

	UpdateActiveSlotHint()
	UpdateBurnCardHighlight()

	if ( IsBlackMarketUnlocked( player ) )
		thread PulseSellValueLabel()

	return true
}
Globalize( BurnCardDiscard )

function DestroyBurnCardVGUI( discarded )
{
	wait 3.0
	foreach ( index, vgui in file.discardedVGUIs )
	{
		if ( vgui == discarded.vgui )
		{
			file.discardedVGUIs.remove( index )
			break
		}
	}

	if ( IsValid( discarded.vgui ) )
	{
		discarded.vgui.Destroy()
	}
}

function BurnCardMouseClickDeckCard( player )
{
	if ( !BurnCardFullyLoaded() )
		return
	if ( Pile() == PileActive() )
	{
		SetCurrentPile( PILE_DECK )
		return
	}
	BurnCardSelectCard( player )
}
Globalize( BurnCardMouseClickDeckCard )

function BurnCardSelectCard( player )
{
	if ( !BurnCardFullyLoaded() )
		return
	thread BurnCardSelectCardInternal( player )
}

function BurnCardSetActiveSlot( player, slot )
{
	if ( !BurnCardFullyLoaded() )
		return
	SetPileOffset( PileActive(), slot )
}
Globalize( BurnCardSetActiveSlot )

function GetPileCurrentBurncard( pile )
{
	if ( pile.offset >= pile.burnCardTables.len() )
		return null
	if ( pile.offset < 0 )
		return null

	return pile.burnCardTables[ pile.offset ]
}

function BurnCardPressedZoomStart( player )
{
	if ( !BurnCardFullyLoaded() )
		return
	if ( file.disableInput )
		return

	local freeSlots = GetPlayerMaxStoredBurnCards( player ) - GetPlayerTotalBurnCards( player )
	if ( freeSlots < 0 )
		return

	file.zoomed = true

	EmitSoundOnEntity( player, "Menu_BurnCard_InspectOneCard" )
	UpdateActiveSlotHint()
}

function BurnCardPressedZoomEnd( player )
{
	if ( !BurnCardFullyLoaded() )
		return
	file.zoomed = false

	//EmitSoundOnEntity( player, "Menu_BurnCard_InspectOneCard" )
	UpdateActiveSlotHint()
}

function BurnCardPressedSpreadStart( player )
{
}

function BurnCardPressedActiveButton( player, parm )
{
	if ( !BurnCardFullyLoaded() )
		return

	if ( Pile() == PileDeck() )
	{
		MoveSelectedBurnCardToBack( player, parm )
		return
	}

	MoveSelectedBurnCardToFront( player, parm )
	SetCurrentPile( PILE_DECK )
}
Globalize( BurnCardPressedActiveButton )

function BurnCardPressedActiveButtonBack( player, parm )
{
	if ( !BurnCardFullyLoaded() )
		return

	MoveSelectedBurnCardToBack( player, parm )
}
Globalize( BurnCardPressedActiveButtonBack )

function BurnCardPressedSpreadEnd( player )
{
}

function BurnCardPressedMoveRight( player )
{
}

function BurnCardPressedMoveLeft( player )
{
}

function BurnCardPressedLeft( player )
{
	if ( !BurnCardFullyLoaded() )
		return
	if ( file.disableInput )
		return
	local pile = Pile()
	if ( !pile.burnCardTables.len() )
		return

	if ( pile == PileDeck() )
	{
		//EmitSoundOnEntity( player, "Menu_BurnCard_MoveLeft" )
		SetPileOffset( pile, pile.offset + 1 )
	}
	else
	{
		SetPileOffset( pile, pile.offset - 1 )
		//SetPileOffsetWrap( pile, pile.offset - 1 )
	}

	UpdateHelpButtons( player )
}

function BurnCardWheelUp( player )
{
	if ( !BurnCardFullyLoaded() )
		return
	local pile = PileDeck()
	if ( Pile() != pile )
		return
	SetPileOffset( pile, pile.offset + 1 )
	//EmitSoundOnEntity( player, "Menu_BurnCard_MoveLeft" )
}
Globalize( BurnCardWheelUp )

function BurnCardWheelDown( player )
{
	if ( !BurnCardFullyLoaded() )
		return
	local pile = PileDeck()
	if ( Pile() != pile )
		return
	SetPileOffset( pile, pile.offset - 1 )
//	EmitSoundOnEntity( player, "Menu_BurnCard_MoveRight" )
}
Globalize( BurnCardWheelDown )

function BurnCardPressedRight( player )
{
	if ( !BurnCardFullyLoaded() )
		return
	if ( file.disableInput )
		return
	local pile = Pile()
	if ( !pile.burnCardTables.len() )
		return

	if ( pile == PileDeck() )
	{
		//if ( pile.offset == 0 )
		//{
		//	SetCurrentPile( PILE_ACTIVE )
		//}
		//else
		{
			SetPileOffset( pile, pile.offset - 1 )
			//EmitSoundOnEntity( player, "Menu_BurnCard_MoveRight" )
		}
	}
	else
	{
		SetPileOffset( pile, pile.offset + 1 )
//		SetPileOffsetWrap( pile, pile.offset + 1 )
	}

	UpdateHelpButtons( player )
}

function BurnCardPressedLeftMany( player )
{
	if ( !BurnCardFullyLoaded() )
		return
	if ( file.disableInput )
		return
	PressColorChangeLeft( player )
}

function BurnCardPressedRightMany( player )
{
	if ( !BurnCardFullyLoaded() )
		return
	if ( file.disableInput )
		return
	PressColorChangeRight( player )
}

function BurnCardMenuAnalogX( player, val )
{
	if ( file.disableInput )
		return
	if ( val < -0.5 )
	{
		if ( file.heldDirection > -1 )
		{
			BurnCardPressedLeft( player )
			file.heldDirection = -1
		}
	}
	else if ( val > 0.5 )
	{
		if ( file.heldDirection < 1 )
		{
			BurnCardPressedRight( player )
			file.heldDirection = 1
		}
	}
	else
	{
		file.heldDirection = 0
	}
}

function BurnCardMenuAnalogX2( player, val )
{
	if ( file.disableInput )
		return
	return
	if ( val < -0.5 )
	{
		if ( file.heldDirection2 > -1 )
		{
			BurnCardPressedMoveLeft( player )
			file.heldDirection2 = -1
		}
	}
	else if ( val > 0.5 )
	{
		if ( file.heldDirection2 < 1 )
		{
			BurnCardPressedMoveRight( player )
			file.heldDirection2 = 1
		}
	}
	else
	{
		file.heldDirection2 = 0
	}
}

function InitializePiles()
{
	file.piles <- []
	file.piles.append( CreatePile() ) // deck
	file.piles.append( CreatePile() ) // active
	PileActive().backgroundVGUIS <- []

	file.currentPileIndex <- 0
}

function CreatePile()
{
	local pile = {}
	pile.offset <- 0
	pile.burnCardTables <- []
	pile.index <- file.piles.len()
	Assert( file.piles.len() <= PersistenceGetArrayCount( "currentBurnCardOffset" ) - 1 )
	return pile
}

function BurnCards_AddLobbyClient()
{
	local player = GetLocalClientPlayer()
	InitializePiles()
	file.maxActiveBurnCards = GetPlayerMaxActiveBurnCards( player )


	local pile = Pile()
	file.heldDirection <- 0
	file.burncardOffset <- 0
	file.manySkip <- 0
	file.moveDir <- 0
	file.zoomed <- false
	file.spread <- false
	file.buttonHeld <- {}
	//file.envelope <- null

	file.registeredFunctions <- false

	file.hudElems <- {}
	file.hudElemsIntro <- {}

	file.burnCardCoinValue <- HudElement( "BurnCardCoinValueDisplay" )
	file.burnCardCoinValueIcon <- HudElement( "BurnCardCoinValueIcon" )
	file.burnCardTip <-	HudElement( "BurnCardTipDisplay" )
	file.burnCardWarning <-	HudElement( "BurnCardWarningDisplay" )
	file.BurnCardServerMessage  <-	HudElement( "BurnCardServerMessage" )
	file.BurnCardServerMessage.Show()

	file.hudElemsIntro.BurnCardIntroEnvelopeImage <- HudElement( "BurnCardIntroEnvelopeImage" )
	file.hudElemsIntro.BurnCardIntroEnvelopeImage.Hide()
	file.hudElemsIntro.BurnCardIntroEnvelopeImage.SetRotation( 10 )
	file.hudElemsIntro.BurnCardsMenuText1 <- HudElement( "BurnCardsMenuText1" )
	file.hudElemsIntro.BurnCardsMenuText2 <- HudElement( "BurnCardsMenuText2" )
	file.hudElemsIntro.BurnCardsMenuText3 <- HudElement( "BurnCardsMenuText3" )
	file.hudElemsIntro.BurnCardsMenuText4 <- HudElement( "BurnCardsMenuText4" )
	file.hudElemsIntro.BurnCardContinue <- HudElement( "BurnCardContinue" )
	file.hudElemsIntro.BurnCardContinue.EnableKeyBindingIcons()

	file.hudElems.BurnCardsStarterHelpText <- HudElement( "BurnCardsStarterHelpText" )
	//file.hudElems.BurnCardStarterHelpImage <- HudElement( "BurnCardStarterHelpImage" )
	file.hudElems.BurnCardsStarterHelpTextBackground <- HudElement( "BurnCardsStarterHelpTextBackground" )
	file.hudElems.BurnCardsStarterHelpText.EnableKeyBindingIcons()



	file.readingLetter <- null



	file.openingPack <- false

	OpenedBurncardMenuInternal()
	thread DrawLobbyBurnCards()
}

function DisplayAnyMail( player )
{
	Signal( file, "DisplayAnyMail" )
	EndSignal( file, "DisplayAnyMail" )

	OnThreadEnd(
		function () : ()
		{
			file.disableInput = false
			foreach ( elem in file.hudElemsIntro )
			{
				elem.Hide()
			}

			file.hudElemsIntro.BurnCardsMenuText1.SetText( "" )
			file.hudElemsIntro.BurnCardsMenuText2.SetText( "" )
			file.hudElemsIntro.BurnCardsMenuText3.SetText( "" )
			file.hudElemsIntro.BurnCardsMenuText4.SetText( "" )
		}
	)

	local progress = player.GetPersistentVar( "burncardStoryProgress" )
	if ( UsingAlternateBurnCardPersistence() || IsPlayerEverythingUnlocked( player ) )
		progress = BURNCARD_STORY_PROGRESS_COMPLETE

	foreach ( elem in file.hudElemsIntro )
	{
		elem.Hide()
	}

	file.hudElemsIntro.BurnCardsMenuText1.SetText( "" )
	file.hudElemsIntro.BurnCardsMenuText2.SetText( "" )
	file.hudElemsIntro.BurnCardsMenuText3.SetText( "" )
	file.hudElemsIntro.BurnCardsMenuText4.SetText( "" )

	local msg = {}
	msg.title <- null
	msg.body <- null
	msg.sig <- null
	msg.ps <- null

	if ( progress == BURNCARD_STORY_PROGRESS_INTRO )
	{
		msg.title = { msg = "#BC_STORY_INTRO_TITLE", delay = 3.0 }
		msg.body  = { msg = "#BC_STORY_INTRO_BODY", delay = 5.0 }
		msg.sig   = { msg = "#BC_STORY_INTRO_SIGNATURE", delay = 1.0 }
	}
	else
	{
		SetReadingLetter( player, READING_DONE )
		return
	}

	file.disableInput = true
	DisableAllVGUIs()

	if ( msg.body != null )
	{
		SetPileOffset( file.piles[ PILE_DECK ], 0 )

		SetReadingLetter( player, READING_IN_PROGRESS )

		if ( BURNCARD_MAIL_INTRO )
		{
			file.hudElemsIntro.BurnCardIntroEnvelopeImage.Show()
			file.hudElemsIntro.BurnCardIntroEnvelopeImage.SetAlpha( 0 )
			file.hudElemsIntro.BurnCardIntroEnvelopeImage.FadeOverTime( 255, 2, INTERPOLATOR_LINEAR )

			if ( msg.title )
				waitthread UnveilMessage( file.hudElemsIntro.BurnCardsMenuText1, msg.title.msg, msg.title.delay )

			waitthread UnveilMessage( file.hudElemsIntro.BurnCardsMenuText2, msg.body.msg, msg.body.delay )

			if ( msg.sig )
				waitthread UnveilMessage( file.hudElemsIntro.BurnCardsMenuText3, msg.sig.msg, msg.sig.delay )

			if ( msg.ps )
				waitthread UnveilMessage( file.hudElemsIntro.BurnCardsMenuText4, msg.ps.msg, msg.ps.delay )
		}

		waitthread ButtonPressDelay( 1.0 )

		foreach ( elem in file.hudElemsIntro )
		{
			elem.Show()
		}
	}

	SetReadingLetter( player, READING_WAITING_TO_CONTINUE )

	WaitForever()
}

function ButtonPressDelay( delay )
{
	local endTime = Time() + delay
	for ( ;; )
	{
		if ( Time() >= endTime )
			break

		if ( ( "a" in file.buttonHeld ) )
			return

		wait 0
	}
}

function UpdateActiveSlotHint()
{
	local player = GetLocalClientPlayer()
	file.hudElems.BurnCardsStarterHelpText.SetColor( 204, 234, 255, 255)
	//file.hudElems.BurnCardStarterHelpImage.Hide()

	if ( file.readingLetter != READING_DONE )
	{
		file.hudElems.BurnCardsStarterHelpText.Hide()
		file.hudElems.BurnCardsStarterHelpTextBackground.Hide()
		return
	}

//	if ( GetPlayerMaxActiveBurnCards( player ) > 1 || PileNew().burnCardTables.len() > 0 || file.zoomed )
	{
		file.hudElems.BurnCardsStarterHelpText.Hide()
		file.hudElems.BurnCardsStarterHelpTextBackground.Hide()
		return
	}


	//local base = file.hudElems.BurnCardsStarterHelpText.GetBasePos()
	//file.hudElems.BurnCardsStarterHelpText.SetPos( base[0], base[1] )
	local total = GetPlayerTotalBurnCards( player )
	if ( total <= 0 )
		return

	//file.hudElems.BurnCardStarterHelpImage.Show()

	if ( FindEmptySlotInPile( PileActive() ) != null )
	{
		if ( Pile() == PileActive() )
			file.hudElems.BurnCardsStarterHelpText.SetText( "#BURNCARD_HINT_PICK" ) // "This is your active Burn Card slot." )
		else
		if ( Pile() == PileDeck() )
			file.hudElems.BurnCardsStarterHelpText.SetText( "#BURNCARD_HINT_EQUIP" ) // "This is a Burn Card. You can spend it during a match." )

		file.hudElems.BurnCardsStarterHelpText.Show()
		file.hudElems.BurnCardsStarterHelpTextBackground.Show()
	}
	else
	{
		if ( Pile() == PileActive() )
			file.hudElems.BurnCardsStarterHelpText.SetText( "#BURNCARD_HINT_READY" ) // "This is your active Burn Card slot." )
		else
		if ( Pile() == PileDeck() )
			file.hudElems.BurnCardsStarterHelpText.SetText( "#BURNCARD_HINT_EQUIP" ) // "This is a Burn Card. You can spend it during a match." )
//		if ( Pile() == PileActive() )
//			file.hudElems.BurnCardsStarterHelpText.SetText( "You can put this Burn Card back in your collection." )
//		else
//			file.hudElems.BurnCardsStarterHelpText.SetText( "This Burn Card is ready for use in your next match." )

		file.hudElems.BurnCardsStarterHelpText.Show()
		file.hudElems.BurnCardsStarterHelpTextBackground.Show()
		//file.hudElems.BurnCardsStarterHelpText.Hide()
		//file.hudElems.BurnCardsStarterHelpTextBackground.Hide()
	}
}

function SetReadingLetter( player, val )
{
	Signal( file, "NewBurncardTipDisplay" )

	local oldReadingLetter = file.readingLetter
	file.readingLetter = val

	switch ( file.readingLetter )
	{
		case READING_DONE:
			if ( oldReadingLetter == READING_WAITING_TO_CONTINUE )
			{
				// just finished the letter
				player.ClientCommand( "BCOpenDelivery" )
				player.ClientCommand( "script_ui ShowCoins()" )
				SetPileOffset( PileDeck(), 1 )
				SetCurrentPile( PILE_ACTIVE )
			}
			else
			{
				InstantUpdateOfAllCards()
			}

			foreach ( vgui in PileActive().backgroundVGUIS )
			{
				// show background
				vgui.Show()
			}

			file.burnCardRoomElem.ColorOverTime( 155, 155, 155, 255, 0.5, INTERPOLATOR_ACCEL  )
			file.slotbk.s.elem.ColorOverTime( 0, 0, 0, 180, 0.5, INTERPOLATOR_ACCEL  )
			thread BurnCardHintProgression()

			EnableAllVGUIs()

			UpdateActiveSlotHint()

			file.disableInput = false

			break

		default:
			file.slotbk.s.elem.SetColor( 0, 0, 0, 0 )

			SetPileOffset( PileDeck(), PileDeck().burnCardTables.len() - 1 )
			InstantUpdateOfAllCards()
			file.hudElems.BurnCardsStarterHelpText.Hide()
			file.hudElems.BurnCardsStarterHelpTextBackground.Hide()
			file.disableInput = true
			DisableAllVGUIs()
			if ( "backgroundVGUIS" in PileActive() )
			{
				foreach ( vgui in PileActive().backgroundVGUIS )
				{
					// hide background
					vgui.Hide()
				}
			}
			break
	}

	UpdateHelpButtons( player )
}

function BurnCardHintProgression()
{
	OnThreadEnd(
		function () : ()
		{
			file.burnCardTip.Hide()
			file.burnCardWarning.Hide()
		}
	)

	Signal( file, "NewBurncardTipDisplay" )
	EndSignal( file, "NewBurncardTipDisplay" )
	local elem = file.burnCardTip
	local warning = file.burnCardWarning

	local hints = GetBurnCardHints()
	ArrayRandomize( hints )

	elem.SetAlpha( 0 )
	elem.Show()
	warning.Hide()
	local index = hints.len()

	local player = GetLocalClientPlayer()
	for ( ;; )
	{
		warning.ClearPulsate()
		local freeSlots = GetPlayerMaxStoredBurnCards( player ) - GetPlayerTotalBurnCards( player )
		if ( freeSlots >= 0 )
		{
			index++
			index %= hints.len()
			wait RandomFloat( 2.0, 3.0 )
			elem.SetText( hints[index] )
			elem.FadeOverTime( 225, 1.5, INTERPOLATOR_ACCEL )
			wait 6.75
			elem.FadeOverTime( 0, 1.5, INTERPOLATOR_ACCEL )
			wait 1.5
			continue
		}

		elem.SetAlpha( 0 )
		warning.Show()
		warning.SetAlpha( 255 )

		local oldSlots = freeSlots
		warning.SetText( "#BC_HINT_DECK_FULL", ( freeSlots * -1 ) )
		warning.SetPulsate( 0.5, 1.0, 10 )

		while ( freeSlots < 0 )
		{
			freeSlots = GetPlayerMaxStoredBurnCards( player ) - GetPlayerTotalBurnCards( player )
			if ( freeSlots != oldSlots )
				break
			oldSlots = freeSlots
			wait 0.1
		}

		warning.Hide()
	}
}

function UnveilMessage( elem, msg, endWait )
{
	//elem.SetText( "" )
	//elem.Show()

	//local newString
	//local count = 1
	//local odd = 0
	//for ( ;; )
	//{
	//	newString = ""
	//	for ( local i = 0; i < count; i++ )
	//	{
	//		newString = msg.slice( 0, count )
	//	}
	//	for ( local i = count; i < msg.len(); i++ )
	//	{
//	//		newString = newString + " "
	//	}
	//
	//	elem.SetText( newString )
	//
	//	count++
	//	if ( count >= msg.len() )
	//		break
	//
	//
	//	if ( !( "a" in file.buttonHeld ) || odd == 0 )
	//		wait 0
	//	odd += 1
	//	odd %= 4
	//
	//	if ( !( "a" in file.buttonHeld ) )
	//		wait 0
	//}

	elem.SetText( msg )
	elem.SetAlpha( 0 )
	elem.Show()
	elem.FadeOverTime( 255, 2.0, INTERPOLATOR_LINEAR )

	ButtonPressDelay( endWait )
}

function ReadLetter( player )
{
	SetReadingLetter( player, READING_DONE )

	//foreach ( elem in file.hudElems )
	//{
	//	elem.Show()
	//}

	foreach ( elem in file.hudElemsIntro )
	{
		elem.Hide()
	}
	UpdateHelpButtons( player )
}


function EnableAllVGUIs()
{
	foreach ( pile in file.piles )
	{
		foreach ( burncard in pile.burnCardTables )
		{
			if ( burncard == null )
				continue
			burncard.vgui.Show()
		}
	}
}



function DrawLobbyBurnCards()
{
	file.disableInput = true
	local player = GetLocalClientPlayer()
	player.Signal( "StopBurnCardDisplay" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "StopBurnCardDisplay" )

	local cockpit
	for ( ;; )
	{
		cockpit = player.GetCockpit()
		if ( IsValid( cockpit ) )
			break
		wait 0
	}

	file.BurnCardServerMessage.Hide()
	file.disableInput = false
	//file.envelope = null

	local origin = Vector(0,0,0)
	local angles = Vector(0,0,0)

	Assert( file.storedVguis.len() == 0 )

	OnThreadEnd(
		function () : ()
		{
			foreach ( index, vgui in file.storedVguis )
			{
				if ( IsValid( vgui ) )
					vgui.Destroy()
			}

			file.storedVguis = []
		}
	)

	local vgui
	local burnCardElem

	local width = file.width
	local height = file.height

	local rotater = 120

	local right
	local forward
	local up

    if ( IsLobby() )
    {
        // IMPORTANT: In optimized lobby the player model is not loaded
        // So we cannot look up the attachment for the cockpit camera.
        // Luckily, it resolves to (0,0,0)!
    	origin = Vector(0,0,0)
    	angles = Vector(0,0,0)
    }
    else
    {
	    local attachment = "camera"
	    local attachmentID = cockpit.LookupAttachment( attachment )

    	origin = cockpit.GetAttachmentOrigin( attachmentID )
    	angles = cockpit.GetAttachmentAngles( attachmentID )
    }

	right = angles.AnglesToRight()
	forward = angles.AnglesToForward()
	up = angles.AnglesToUp()

	file.loaded <- true
	//file.inputTime <- 50
	file.bcWidth <- width
	file.bcHeight <- height

	origin += right * 0.0 * width
	origin += up * 0.0 * width
	origin += forward * 6.5 * width

	angles = angles.AnglesCompose( Vector(-90,0,0) )
	angles = angles.AnglesCompose( Vector(0,-90,0) )
	angles = angles.AnglesCompose( Vector(0,0,0) )

	file.origin <- origin
	file.angles <- angles

	file.right <- right
	file.forward <- forward
	file.up <- up


	local deckPile = file.piles[ PILE_DECK ]
	deckPile.burnCardTables = GetBurnCardsTableFromArray( GetPlayerBurnCardDeck( player ) )

	local activePile = file.piles[ PILE_ACTIVE ]

	local activeCards = GetPlayerActiveBurnCards( player )
	for ( local slotID = GetPlayerMaxActiveBurnCards( player ); slotID < GetMaxActiveBurnCardSlots(); slotID++ )
	{
		activeCards.append( null )
	}

	// translate it to the kind of array we want
	local activeCardArray = []
	for ( local i = 0; i < activeCards.len(); i++ )
	{
		activeCardArray.append( { cardRef = activeCards[i], new = false } )
	}
	activePile.burnCardTables = GetBurnCardsTableFromArray( activeCardArray )

	local scale = 200
	file.roomWidth <- 1.777778 * scale
	file.roomHeight <- 1.0 * scale

	local roomOrg = VectorCopy( origin )
	file.roomBaseOrg <- VectorCopy( origin )

	roomOrg += file.right * file.roomWidth * ( -0.5 + 0.01 )
	roomOrg += file.up * file.roomHeight * ( -0.5 + 0.075 )
	roomOrg += file.forward * 133

	local room = CreateClientsideVGuiScreen( "vgui_burn_card_room", VGUI_SCREEN_PASS_WORLD, roomOrg, file.angles, file.roomWidth, file.roomHeight )
	file.room <- room
	file.storedVguis.append( room )
	//file.room.SetOrigin( roomOrg )
	//file.room.SetSize( file.roomWidth, file.roomHeight )
	local elem = HudElement( "burncard_room", room.GetPanel() )
	file.burnCardRoomElem <- elem
	elem.SetColor( 55, 55, 55, 255 )

	local slotbk = CreateClientsideVGuiScreen( "vgui_burn_card_room", VGUI_SCREEN_PASS_WORLD, roomOrg, file.angles, file.roomWidth, file.roomHeight )
	local elem = HudElement( "burncard_room", slotbk.GetPanel() )
	slotbk.s.elem <- elem
	file.storedVguis.append( slotbk )
	file.slotbk <- slotbk
	CreateBaseVgui( slotbk )
	slotbk.s.origin = Vector(0,0,0)
	slotbk.s.angles = Vector(0,0,0)
	file.slotbk.s.elem.SetImage( "HUD/white" )
	file.slotbk.s.elem.SetColor( 0, 0, 0, 0 )



	//file.hintIcon <- CreateClientsideVGuiScreen( "vgui_binding", VGUI_SCREEN_PASS_WORLD, Vector(0,0,0), Vector(0,0,0), 100, 100 )
	//file.hintIcon.s.panel <- file.hintIcon.GetPanel()
	//file.hintIcon.s.BindingText <- HudElement( "BindingText", file.hintIcon.s.panel )
	//file.hintIcon.s.BindingText.SetText( "A" )


	local readingLetter = file.readingLetter != READING_DONE

	local offset = 0
	local unlockReqs = []
	unlockReqs.append( GetUnlockLevelReq( "burn_card_slot_1") )
	unlockReqs.append( GetUnlockLevelReq( "burn_card_slot_2") )
	unlockReqs.append( GetUnlockLevelReq( "burn_card_slot_3") )

	foreach ( pile in file.piles )
	{
		local isActivePile = pile == activePile
		foreach ( index, burncard in pile.burnCardTables )
		{
			local org = VectorCopy( origin )
			org += right * -10
			org += forward * 100 // -300
			org += forward * offset * 20
			org += up * 20

			if ( burncard != null )
			{
				local vgui = CreateBurnCardVGUI( burncard.cardRef, org, Vector(0,0,0) )
				burncard.vgui = vgui

				if ( readingLetter )
				{
					vgui.Hide()
				}
			}

			if ( isActivePile )
			{
				local vgui = CreateBackgroundVGUI( org, Vector(0,0,0) )
				local elemTable = vgui.s.elemTable
				if ( index >= GetPlayerMaxActiveBurnCards( player ) )
				{
//					elemTable.PreviewCard_title.SetText( "#BC_LOCKED_SLOT" )
					SetSlotText( elemTable, "#BC_UNLOCK_SLOT", unlockReqs[ index ] )
					elemTable.PreviewCard_slot.Show()
				}
				else
				{
					//SetSlotText( elemTable, "#BC_PICK_A_CARD" )
					elemTable.PreviewCard_slot.Hide()

					if ( pile.burnCardTables.len() == 1 )
					{
						elemTable.PreviewCard_title.SetText( "#BC_ACTIVE_SLOT" )
					}
					else
					{
						elemTable.PreviewCard_title.SetText( "#BC_ACTIVE_SLOT_NUMBER", ( index + 1 ) )
					}
				}
				elemTable.PreviewCard_title.Hide()


				pile.backgroundVGUIS.append( vgui )

				if ( readingLetter )
				{
					vgui.Hide()
				}
			}

			offset++
		}
	}

	UpdateBurnCardHighlight()

	//file.origin += file.up * 5.5
	//file.origin += file.right * -5.5
	//file.origin += file.forward * -34.0

//	file.origin += file.right * ( -5.5 + 1.05 )
	file.origin += file.right * ( -5.5 + 1.50 )
	file.origin += file.up * ( 5.5 + 2.7 )
	file.origin += file.forward * ( -34.0 + -1.2 )


	//BurnCardPressedLeft( player )
	//SetPileOffset( Pile(), Pile().offset )


	local count = PileDeck().burnCardTables.len() - 1
	count *= 0.5
	count = count.tointeger()
	SetPileOffset( PileDeck(), count )



	thread DisplayAnyMail( player )
	UpdateViewSettingsFromPersistentData( player )
	InstantUpdateOfAllCards()

	UpdateCardHighlightText( player )

	for ( ;; )
	{
		wait 0
		file.mustDiscard = GetPlayerMaxStoredBurnCards( player ) - GetPlayerTotalBurnCards( player ) < 0
		if ( file.mustDiscard )
		{
			file.zoomed = false
			if ( Pile() == PileActive() )
				SetCurrentPile( PILE_DECK )
		}

		file.maxActiveBurnCards = GetPlayerMaxActiveBurnCards( player )
		RedrawAllPiles()
	}
}

function setroom( num )
{
	local roomOrg = VectorCopy( file.roomBaseOrg )

	roomOrg += file.right * file.roomWidth * ( -0.5 + 0.01 )
	roomOrg += file.up * file.roomHeight * ( -0.5 + 0.075 )
	roomOrg += file.forward * num
	file.room.SetOrigin( roomOrg )
}
Globalize( setroom )

function InstantUpdateOfAllCards()
{
	if ( !BurnCardFullyLoaded() )
		return

	foreach ( pile in file.piles )
	{
		foreach ( burncard in pile.burnCardTables )
		{
			if ( burncard == null )
				continue
			burncard.vgui.s.startMoveTime = null
		}
	}

	SetUpdateDif( 1.0 )
	RedrawAllPiles()
	RedrawAllPiles( true )

	HideAllDeckVGUIS()
	if (file.readingLetter >= READING_DONE )
		ShowInRangeDeckVGUIS()

	SetUpdateDif( 0.22 )
}

function SetUpdateDif( dif )
{
	file.updateDif = dif
}

function HideAllDeckVGUIS()
{
	local pile = PileDeck()
	for ( local i = 0; i < pile.burnCardTables.len(); i++ )
	{
		local burncard = pile.burnCardTables[ i ]
		local vgui = burncard.vgui
		vgui.Hide()
	}
}

function ShowInRangeDeckVGUIS()
{
	local pile = PileDeck()
	local viewRange = MAX_RANGE
	local start = pile.offset + 1
	local max = pile.burnCardTables.len()
	if ( max > start + viewRange )
		max = start + viewRange

	local viewRange = MIN_RANGE
	local start = pile.offset - 1
	local min = 0
	if ( min < start - viewRange )
		min = start - viewRange

	for ( local i = min; i < max; i++ )
	{
		local burncard = pile.burnCardTables[ i ]
		local vgui = burncard.vgui
		vgui.Show()
	}
}


function GetBurnCardsTableFromArray( array )
{
	local newArray = []
	foreach ( index, bcard in array )
	{
		if ( bcard.cardRef != null )
			newArray.append( { cardRef = bcard.cardRef, vgui = null, new = bcard.new } )
		else
			newArray.append( null )
	}
	return newArray
}

function UpdateViewSettingsFromPersistentData( player )
{
	for ( local i = 0; i < file.piles.len(); i++ )
	{
		local pile = file.piles[i]
		local currentPileOffset = player.GetPersistentVar( "currentBurnCardOffset[" + i + "]" )

		if ( currentPileOffset >= 0 && currentPileOffset < pile.burnCardTables.len() )
		{
			SetPileOffset( pile, currentPileOffset )
		}
	}

	SetCurrentPile( player.GetPersistentVar( "currentBurnCardPile" ) )
}


function RedrawAllPiles( forceDraw = false )
{
	file.newSinTime = fabs( sin( Time() * 3.0 ) ) * 0.5 + 0.5
	foreach ( pile in file.piles )
	{
		if ( pile.offset >= pile.burnCardTables.len() )
		{
			SetPileOffset( pile, pile.burnCardTables.len() - 1 )
			continue
		}
	}

	local x = -1.75
	local y = -2.7
	local z = 1.2

	local player = GetLocalClientPlayer()
	if ( file.mustDiscard )
	{
		x -= 6.0
	}

	if ( forceDraw )
	{
		//RedrawBurnCardDeckNoZoomAll( file.piles[0], 0.0 + x, 1.6 + y, -5.0 + z )
		RedrawBurnCardDeckNoZoom( file.piles[0], 0.0 + x, 1.6 + y, -5.0 + z )
		return
	}

	//file.hintIcon.Hide()
	local pile = Pile()
	if ( pile == PileDeck() )
	{
		//RedrawBurnCardDeck( file.piles[0], -3.0, -1.7, 0.0 )
		//RedrawActiveBurnCards( file.piles[1], 0, 7.0, 0.0 )
		RedrawBurnCardDeck( file.piles[0], 0.0 + x, 1.6 + y, -5.0 + z )
		x += 0.2
		if ( file.mustDiscard )
			x -= 10.0

		RedrawActiveBurnCards( file.piles[1], 0 + x, 0.4 + y, -5.0 + z )
	}
	else
	if ( pile == PileActive() )
	{
		//RedrawBurnCardDeck( file.piles[0], -3.0, -1.7, 0.0 )
		//RedrawActiveBurnCards( file.piles[1], 0, 7.0, 0.0 )
		RedrawBurnCardDeck( file.piles[0], 0.0 + x, 1.6 + y, -5.0 + z )
		x += 0.2
		RedrawActiveBurnCards( file.piles[1], 0 + x, 0.4 + y, -5.0 + z )
	}

	foreach ( vgui in file.discardedVGUIs )
	{
		UpdateBurnCardPosition( vgui, 0, 0, 0, 0, 0, 0 )
	}
}

function RedrawFloatingCard( )
{
	file.newSinTime = fabs( sin( Time() * 3.0 ) ) * 0.5 + 0.5
	foreach ( pile in file.piles )
	{
		if ( pile.offset >= pile.burnCardTables.len() )
		{
			SetPileOffset( pile, pile.burnCardTables.len() - 1 )
			continue
		}
	}

	local x = -1.75
	local y = -2.7
	local z = 1.2

	local pile = Pile()
	if ( pile == PileActive() )
	{
		x += 0.2
		RedrawActiveBurnCards( file.piles[1], 0 + x, 0.4 + y, -5.0 + z )
	}

	foreach ( vgui in file.discardedVGUIs )
	{
		UpdateBurnCardPosition( vgui, 0, 0, 0, 0, 0, 0 )
	}
}


function RedrawBurnCardNew( pile, pileXOffset = 0, pileYOffset = 0, pileZOffset = 0 )
{
	//pileXOffset += -6.0
	local selectedPile = pile == Pile()
	local offset = pile.offset
	local zoomed = file.zoomed && Pile() == pile

	local scale = 0.75
	local width = file.width * scale

	local x = 0 + pileXOffset -= width * 2.5
	local y = 0 + pileYOffset
	local z = 0 + pileZOffset
	local pitch = -10
	local yaw = 0
	local roll = 0

	if ( zoomed )
		z += 15

	for ( local i = 0; i < pile.burnCardTables.len(); i++ )
	{
		local burncard = pile.burnCardTables[i]
		local vgui = burncard.vgui
		local selectedCard = i == pile.offset
		x += width

		if ( selectedCard )
		{
			SetPreviewCardColorDestination( burncard, 255, 255, 255 )
		}
		else
		{
			SetPreviewCardColorDestination( burncard, 190, 190, 190 )
		}

		if ( zoomed && selectedCard )
		{
			vgui.s.scaleDest = 1.0
			UpdateBurnCardPosition( vgui, 0, 0, 0, 0, 0, 0 )
			continue
		}
		else
		{
			vgui.s.scaleDest = 0.75
		}

		UpdateBurnCardPosition( vgui, x, y, z, pitch, yaw, roll )
	}
}


/*
function RedrawBurnCards()
{
	local vguis = file.vguis

	local x = 0
	local y = 0
	local z = 0
	local roll = 5
	if ( file.offset >= 0 && file.burncards.len() > 0 )
	{
		local vgui = vguis[ file.offset ]
		UpdateBurnCardPosition( vgui, x, y, z, roll )
		SetPreviewCardColor( vgui.s.elemTable, 255, 255, 255, 255 )
	}

	local drewPack = false

	if ( file.offset == -1 )
	{
		drewPack = true
		UpdateBurnCardPosition( file.pack, x + 10, 5, 0, 0, 0 )
		file.pack.s.elem.SetColor( 255, 255, 255, 255 )
	}
	else
	{
		file.pack.s.elem.SetColor( 105, 105, 105, 255 )
	}

	x = 2
	y = 1
	roll = 20

	local xOff = -1.0
	local yOff = 1.0
	local zOff = 0.5
	local rollOff = 3.0
	local extraYOffset = -0.2

	for ( local i = file.offset + 1; i < vguis.len(); i++ )
	{
		SetPreviewCardColor( vguis[i].s.elemTable, 190, 190, 190, 255 )
		x += xOff
		y += yOff
		z += zOff
		roll += rollOff
		xOff *= 0.8
		yOff *= 0.8
		yOff += extraYOffset
		zOff *= 0.8
		rollOff *= 0.8
		extraYOffset *= 0.8
		UpdateBurnCardPosition( vguis[ i ], x, y, z, roll )
	}

	x = 5.8
	y = 0
	z = 0
	roll = 0

	//local extra = 4 - ( vguis.len() - file.offset )
	//y += extra * 5.0

	local xOff = 1.0
	local yOff = 1.0
	local zOff = -0.5
	local rollOff = -5.0

	local pitch = 0
	local pitchOff = -5.5

	for ( local i = file.offset - 1; i >= 0; i-- )
	{
		SetPreviewCardColor( vguis[i].s.elemTable, 190, 190, 190, 255 )
		x += xOff
		y += yOff

		if ( i < 2 )
		{
			if ( file.offset > i + 1 )
			{
	//			y -= 2.2
				y -= 2.8
				z += -0.5
				roll += 4.0
			}
		}

		z += zOff
		roll += rollOff
		xOff *= 0.5
		yOff *= 0.8
//		yOff += extraYOffset
		zOff *= 0.8
		rollOff *= 0.8
//		extraYOffset *= 0.9

		pitch += pitchOff
		pitchOff *= 0.9

		pitch = 0
		if ( i == file.offset + 1 )
			UpdateBurnCardPosition( vguis[ i ], x, y, z, roll + 3, pitch )
		else
			UpdateBurnCardPosition( vguis[ i ], x, y, z, roll, pitch )

	}

	if ( !drewPack )
		UpdateBurnCardPosition( file.pack, x + 5, 5, 0, 0, 0 )
}
*/

function RedrawBurnCardDeck( pile, pileXOffset = 0, pileYOffset = 0, pileZOffset = 0 )
{
	if ( file.readingLetter != READING_DONE )
		return

	if ( file.zoomed )
	{
		RedrawBurnCardDeckZoomed( pile, pileXOffset, pileYOffset, pileZOffset )
	}
	else
	{
		RedrawBurnCardDeckNoZoom( pile, pileXOffset, pileYOffset, pileZOffset )
	}
}

function RedrawBurnCardDeckMustDiscard( pile, pileXOffset, pileYOffset, pileZOffset )
{
	local selectedPile = pile == Pile()
	pileXOffset += file.width * 0.5 - 1.96
	pileXOffset += 5.5

	pileZOffset += 4.5
	pileYOffset += -0.5

	//if ( file.zoomed )
	//{
	//	pileZOffset += -7.0
	//	pileXOffset += 6.3
	//	pileYOffset += -2.7
	//}


	foreach ( burncard in pile.burnCardTables )
	{
		burncard.vgui.s.scaleDest = 1.0
	}

	local x = pileXOffset
	local y = pileYOffset
	local z = pileZOffset

	local pitch = 0
	local yaw = 0
	local roll = 5
	if ( pile.offset >= 0 && pile.burnCardTables.len() > 0 )
	{
		local burncard = pile.burnCardTables[ pile.offset ]
		local vgui = burncard.vgui

		if ( file.zoomed )
		{
			SetPreviewCardColorDestination( burncard, 50, 50, 50 )
		}
		else
		{
			if ( selectedPile )
				SetPreviewCardColorDestination( burncard, 255, 255, 255 )
			else
				SetPreviewCardColorDestination( burncard, 185, 185, 185 )
		}

		local pileActive = PileActive()
		if ( Pile() == pileActive )
		{
			local scale = 0.5
			local offset = pileActive.offset
			x = -8.4 + offset * file.width * scale * 1.2
			y = 0
			z = -6
			pitch = -60
			yaw = 20
			roll = 20

			pitch += sin( Time() * 5 ) * 2.0
			roll += sin( Time() * 3 ) * 2.0
			//local rollChange = -10
			//roll = rollChange * ( offset - 1 )
			vgui.s.scaleDest = scale
		}

		vgui.Show()
		UpdateBurnCardPosition( vgui, x, y, z, pitch, yaw, roll )
	}


	local drewPack = false

	local minCol = 60
	x = 2 + pileXOffset
	y = -1.0 + pileYOffset
	z = pileZOffset
	roll = 20
	pitch = 0
	yaw = 0

	local xOff = -1.25
	local yOff = 1.0
	local zOff = 0.5
	local rollOff = 3.0
	local extraYOffset = -0.2
	local col

	if ( file.zoomed || !selectedPile )
		col = 50
	else
		col = 150


	local max = pile.offset + 1 + MAX_RANGE

	for ( local i = pile.offset + 1; i < pile.burnCardTables.len(); i++ )
	{
		local burncard = pile.burnCardTables[ i ]
		local vgui = burncard.vgui

		SetPreviewCardColorDestination( burncard, col, col, col )

		x += xOff
		y += yOff
		z += zOff
		roll += rollOff
		xOff *= 1.0
		yOff *= 0.8
		yOff += extraYOffset
		zOff *= 0.8
		rollOff *= 0.8
		extraYOffset *= 0.88
		vgui.Show()
		UpdateBurnCardPosition( vgui, x, y, z, pitch, yaw, roll, i > max )

		col -= 10
		if ( col < minCol )
			col = minCol
	}

	x = 5.2 + pileXOffset
	y = 0 + pileYOffset
	z = -1 + pileZOffset
	roll = 0

	//local extra = 4 - ( vguis.len() - file.offset )
	//y += extra * 5.0

	local xOff = 1.8
	local yOff = 0.2
	local zOff = -1.2
	local rollOff = -5.0
	local extraYOffset = 0.5

	local pitch = 0
	local pitchOff = -5.5

	if ( file.zoomed || !selectedPile )
		col = 50
	else
		col = 150


	local min = ( pile.offset - 1 ) - MIN_RANGE
	for ( local i = pile.offset - 1; i >= 0 && i < pile.burnCardTables.len(); i-- )
	{
		local burncard = pile.burnCardTables[ i ]
		local vgui = burncard.vgui
		SetPreviewCardColorDestination( burncard, col, col, col )


		col -= 10
		if ( col < minCol )
			col = minCol

		x += xOff
		y -= yOff

		//if ( i < 2 )
		//{
		//	if ( pile.offset > i + 1 )
		//	{
	//	//		y -= 2.2
		//		y -= 2.8
		//		z += -0.5
		//		roll += 4.0
		//	}
		//}

		z += zOff
		roll += rollOff
		xOff *= 0.75
		yOff *= 0.8
		yOff += extraYOffset
		zOff *= 0.9
		rollOff *= 0.8
		extraYOffset = 0

		pitch += pitchOff
		pitchOff *= 0.9

		pitch = 0
		vgui.Show()

		if ( i == pile.offset + 1 )
			UpdateBurnCardPosition( vgui, x, y, z, pitch, yaw, roll + 3, i < min )
		else
			UpdateBurnCardPosition( vgui, x, y, z, pitch, yaw, roll, i < min )
	}
}

function RedrawBurnCardDeckNoZoom( pile, pileXOffset, pileYOffset, pileZOffset )
{
	if ( file.mustDiscard )
	{
		RedrawBurnCardDeckMustDiscard( pile, pileXOffset, pileYOffset, pileZOffset )
		return
	}

	local selectedPile = pile == Pile()
	pileXOffset += file.width * 0.5 - 1.96
	pileXOffset += 5.5

	pileZOffset += 4.5
	pileYOffset += -0.5

	//if ( file.zoomed )
	//{
	//	pileZOffset += -7.0
	//	pileXOffset += 6.3
	//	pileYOffset += -2.7
	//}


	foreach ( burncard in pile.burnCardTables )
	{
		burncard.vgui.s.scaleDest = 1.0
	}

	local x = pileXOffset
	local y = pileYOffset
	local z = pileZOffset

	local pitch = 0
	local yaw = 0
	local roll = 5
	if ( pile.offset >= 0 && pile.burnCardTables.len() > 0 )
	{
		local burncard = pile.burnCardTables[ pile.offset ]
		local vgui = burncard.vgui

		if ( file.zoomed )
		{
			SetPreviewCardColorDestination( burncard, 50, 50, 50 )
		}
		else
		{
			if ( selectedPile )
				SetPreviewCardColorDestination( burncard, 255, 255, 255 )
			else
				SetPreviewCardColorDestination( burncard, 185, 185, 185 )
		}

		local pileActive = PileActive()
		if ( Pile() == pileActive )
		{
			local scale = 0.5
			local offset = pileActive.offset
			x = -8.4 + offset * file.width * scale * 1.2
			y = 0
			z = -6
			pitch = -60
			yaw = 20
			roll = 20

			pitch += sin( Time() * 5 ) * 2.0
			roll += sin( Time() * 3 ) * 2.0
			//local rollChange = -10
			//roll = rollChange * ( offset - 1 )
			vgui.s.scaleDest = scale
		}

		vgui.Show()
		UpdateBurnCardPosition( vgui, x, y, z, pitch, yaw, roll )
	}


	local drewPack = false

	local minCol = 60
	x = 2 + pileXOffset
	y = -0.2 + pileYOffset
	z = pileZOffset
	roll = 20
	pitch = 0
	yaw = 0

	local xOff = -1.0
	local yOff = 1.0
	local zOff = 0.5
	local rollOff = 3.0
	local extraYOffset = -0.2
	local col

	if ( file.zoomed || !selectedPile )
		col = 50
	else
		col = 150


	local max = pile.offset + 1 + MAX_RANGE

	for ( local i = pile.offset + 1; i < pile.burnCardTables.len(); i++ )
	{
		local burncard = pile.burnCardTables[ i ]
		local vgui = burncard.vgui

		SetPreviewCardColorDestination( burncard, col, col, col )

		x += xOff
		y += yOff
		z += zOff
		roll += rollOff
		xOff *= 0.8
		yOff *= 0.8
		yOff += extraYOffset
		zOff *= 0.8
		rollOff *= 0.8
		extraYOffset *= 0.88
		vgui.Show()
		UpdateBurnCardPosition( vgui, x, y, z, pitch, yaw, roll, i > max )

		col -= 10
		if ( col < minCol )
			col = minCol
	}

	x = 4.4 + pileXOffset
	y = 0 + pileYOffset
	z = -2 + pileZOffset
	roll = 0

	//local extra = 4 - ( vguis.len() - file.offset )
	//y += extra * 5.0

	local xOff = 1.0
	local yOff = 1.0
	local zOff = -0.5
	local rollOff = -5.0
	local extraYOffset = 0.5

	local pitch = 0
	local pitchOff = -5.5

	if ( file.zoomed || !selectedPile )
		col = 50
	else
		col = 150


	local min = ( pile.offset - 1 ) - MIN_RANGE
	for ( local i = pile.offset - 1; i >= 0 && i < pile.burnCardTables.len(); i-- )
	{
		local burncard = pile.burnCardTables[ i ]
		local vgui = burncard.vgui
		SetPreviewCardColorDestination( burncard, col, col, col )


		col -= 10
		if ( col < minCol )
			col = minCol

		x += xOff
		y -= yOff

		//if ( i < 2 )
		//{
		//	if ( pile.offset > i + 1 )
		//	{
	//	//		y -= 2.2
		//		y -= 2.8
		//		z += -0.5
		//		roll += 4.0
		//	}
		//}

		z += zOff
		roll += rollOff
		xOff *= 0.75
		yOff *= 0.8
		yOff += extraYOffset
		zOff *= 0.9
		rollOff *= 0.8
		extraYOffset = 0

		pitch += pitchOff
		pitchOff *= 0.9

		pitch = 0
		vgui.Show()

		if ( i == pile.offset + 1 )
			UpdateBurnCardPosition( vgui, x, y, z, pitch, yaw, roll + 3, i < min )
		else
			UpdateBurnCardPosition( vgui, x, y, z, pitch, yaw, roll, i < min )
	}
}


//function UpdateBurnCardHighlight_Selected( vgui )
//{
//	local elemTable = vgui.s.elemTable
//	local alpha = sin( Time() * 1.5 ) * 255 + 120
//	if ( alpha > 250 )
//		alpha = 250
//	if ( alpha < 0 )
//		alpha = 0
//	//printt( "alpha " + alpha )
//	elemTable.PreviewCard_outline.SetColor( 255, 205, 0, alpha )
//}

function RedrawBurnCardDeckZoomed( pile, pileXOffset, pileYOffset, pileZOffset )
{
	local selectedPile = pile == Pile()
	pileXOffset += file.width * 0.5 - 1.96
	pileXOffset += 13.5

	pileZOffset += 4.5
	pileYOffset += 0.5

	//if ( file.zoomed )
	//{
	//	pileZOffset += -7.0
	//	pileXOffset += 6.3
	//	pileYOffset += -2.7
	//}

	foreach ( burncard in pile.burnCardTables )
	{
		burncard.vgui.s.scaleDest = 0.6
	}

	local x = pileXOffset
	local y = pileYOffset
	local z = pileZOffset

	local pitch = 0
	local yaw = 0
	local roll = 5
	if ( pile.offset >= 0 && pile.burnCardTables.len() > 0 )
	{
		local burncard = pile.burnCardTables[ pile.offset ]
		local vgui = burncard.vgui

		if ( selectedPile )
			SetPreviewCardColorDestination( burncard, 255, 255, 255 )
		else
			SetPreviewCardColorDestination( burncard, 185, 185, 185 )

		local pileActive = PileActive()
		if ( Pile() == pileActive )
		{
			local scale = 0.75
			local offset = pileActive.offset
			x = -8.7 + offset * file.width * scale * 1.3
			y = 0.3
			z = -8
			pitch = -70
			yaw = 20
			roll = 20

			pitch += sin( Time() * 5 ) * 2.0
			roll += sin( Time() * 3 ) * 2.0
			//local rollChange = -10
			//roll = rollChange * ( offset - 1 )
			vgui.s.scaleDest = scale
		}

		vgui.Show()
		UpdateBurnCardPosition( vgui, x, y, z, pitch, yaw, roll )
	}


	local drewPack = false

	local minCol = 60
	x = 0 + pileXOffset
	y = -0.2 + pileYOffset
	z = pileZOffset + 1
	roll = 10
	pitch = 0
	yaw = 0

	local xOff = -0.2
	local yOff = 1.0
	local zOff = 0.5
	local rollOff = 1.5
	local extraYOffset = -0.2
	local col

	if ( !selectedPile )
		col = 50
	else
		col = 150

	local max = pile.offset + 1 + MAX_RANGE

	for ( local i = pile.offset + 1; i < pile.burnCardTables.len(); i++ )
	{
		local burncard = pile.burnCardTables[ i ]
		local vgui = burncard.vgui
		SetPreviewCardColorDestination( burncard, col, col, col )


		x += xOff
		y += yOff
		z += zOff
		roll += rollOff
		xOff *= 0.8
		yOff *= 0.8
		yOff += extraYOffset
		zOff *= 0.8
		rollOff *= 0.8
		extraYOffset *= 0.8
		vgui.Show()
		UpdateBurnCardPosition( vgui, x, y, z, pitch, yaw, roll, i > max )
		col -= 10
		if ( col < minCol )
			col = minCol
	}


	x = 1.5 + pileXOffset
	y = 0 + pileYOffset
	z = -2 + pileZOffset
	roll = 0

	//local extra = 4 - ( vguis.len() - file.offset )
	//y += extra * 5.0

	local xOff = 0.3
	local yOff = 1.0
	local zOff = -0.5
	local rollOff = -5.0

	local pitch = 0
	local pitchOff = -5.5

	if ( !selectedPile )
		col = 50
	else
		col = 150

	local min = ( pile.offset - 1 ) - MIN_RANGE
	for ( local i = pile.offset - 1; i >= 0 && i < pile.burnCardTables.len(); i-- )
	{
		local burncard = pile.burnCardTables[ i ]
		local vgui = burncard.vgui
		SetPreviewCardColorDestination( burncard, col, col, col )


		col -= 10
		if ( col < minCol )
			col = minCol

		x += xOff
		y -= yOff

		//if ( i < 2 )
		//{
		//	if ( pile.offset > i + 1 )
		//	{
	//	//		y -= 2.2
		//		y -= 2.8
		//		z += -0.5
		//		roll += 4.0
		//	}
		//}

		z += -0.5
		roll += rollOff
		xOff *= 0.5
		yOff *= 0.8
//		yOff += extraYOffset
		zOff *= 0.8
		rollOff *= 0.8
//		extraYOffset *= 0.9

		pitch += pitchOff
		pitchOff *= 0.9

		vgui.Show()
		pitch = 0
		if ( i == pile.offset + 1 )
			UpdateBurnCardPosition( vgui, x, y, z, pitch, yaw, roll + 3, i < min )
		else
			UpdateBurnCardPosition( vgui, x, y, z, pitch, yaw, roll, i < min )
	}
}


function RedrawActiveBurnCards( pile, pileXOffset = 0, pileYOffset = 0, pileZOffset = 0 )
{
	local zoomed = file.zoomed && Pile() == pile
	local selectedPile = pile == Pile()
	//pileXOffset += -6.0
	pileXOffset += -0.3
	pileZOffset += 1.5
	pileYOffset += 5.9

	pileXOffset += -6.3
	pileYOffset += -2.2

	local scale = 0.5
	if ( file.zoomed )
	{
		//pileZOffset += -5.0
		scale = 1.0
		pileXOffset += -3.3
		pileYOffset += -2.2
		pileZOffset += 4.0
	}

	local isDeckPile = pile == file.piles[ PILE_DECK ]
	local selectedPile = pile == Pile()
	local offset = pile.offset

	local backgroundVGUIS = pile.backgroundVGUIS
	foreach ( burncard in pile.burnCardTables )
	{
		if ( burncard != null )
			burncard.vgui.s.scaleDest = scale
	}

	local width = file.width * scale
	local height = file.height * scale
	foreach ( vgui in backgroundVGUIS )
	{
		//vgui.SetSize( width, height )
		vgui.s.scaleDest = scale
	}

	local x = 0 + pileXOffset
	local y = 0 + pileYOffset
	local z = 0 + pileZOffset
	local pitch = 10
	local yaw = 0
	local roll = 0
	local xOff = 0
	local yOff = 0
	local zOff = 0
	local rollOff = 0
	local extraXOffset = 0
	local extraYOffset = 0

	pitch = 0
	yaw = 0

	if ( file.zoomed )
	{
		file.slotbk.s.scaleDest = 28.3
		UpdateBurnCardPosition( file.slotbk, x - 2.50, y + -0.8, z + 2.8, pitch, yaw, roll )
	}
	else
	{
		file.slotbk.s.scaleDest = 15.0
		UpdateBurnCardPosition( file.slotbk, x - 2.50, y + -0.8, z + 2.8, pitch, yaw, roll )
	}
	local currentScale = file.slotbk.s.currentScale
	file.slotbk.SetSize( currentScale, currentScale * 0.48 )

	for ( local i = 0; i < pile.burnCardTables.len(); i++ )
	{
		roll = 0
		x = pileXOffset + i * ( width + 0.15 )
		y = pileYOffset
		z = 0 + pileZOffset

		pitch = 0
		yaw = 0
		//z += 1.0
		//if ( i != pile.offset )
		//	z += 1


		if ( i < backgroundVGUIS.len() )
		{
			local vgui = backgroundVGUIS[ i ]
			UpdateBurnCardPosition( vgui, x , y, z + 0.05, pitch, yaw, roll )

			//SetBurnCardSlotTitleColor( vgui, i, pile )
		}

		//x += 0.4
		//y += 0.5

		//if ( selectedPile && !zoomed )
		//{
		//	x += ( i - 1 ) * -0.1
		//}
		//else
		//{
		//	x += ( i - 1 ) * -0.2
		//	z -= 0.2
		//	y += 0.2
		//}

		local count = 0
		local col = 105

		if ( pile.burnCardTables[i] == null )
			continue

		local burncard = pile.burnCardTables[i]
		local vgui = burncard.vgui
		if ( vgui == null )
			continue

		vgui.Show()
		if ( selectedPile )
		{
			if ( i == pile.offset )
				SetPreviewCardColorDestination( burncard, 255, 255, 255 )
			else
				SetPreviewCardColorDestination( burncard, 155, 155, 155 )
		}
		else
		{
			if ( i == pile.offset )
				SetPreviewCardColorDestination( burncard, 230, 230, 230 )
			else
				SetPreviewCardColorDestination( burncard, 205, 205, 205 )
		}

		UpdateBurnCardPosition( vgui, x, y, z - 0.01, pitch, yaw, roll )
	}
}

function SetBurnCardSlotTitleColor( vgui, i, pile )
{
	local elemTable = vgui.s.elemTable

	if ( i >= file.maxActiveBurnCards )
	{
		if ( i == pile.offset )
			SetSlotTitleColor( elemTable, 95, 95, 175 )
		else
			SetSlotTitleColor( elemTable, 75, 75, 155 )
	}
	else
	{
		if ( pile.burnCardTables[i] == null )
		{
			if ( i == pile.offset )
				SetSlotTitleColor( elemTable, 235, 85, 70 )
			else
				SetSlotTitleColor( elemTable, 220, 65, 50 )
		}
		else
		{
			if ( i == pile.offset )
				SetSlotTitleColor( elemTable, 190, 245, 190 )
			else
				SetSlotTitleColor( elemTable, 150, 220, 150 )
		}
	}

	if ( i == pile.offset )
	{
		SetSlotColor( elemTable, 255, 220, 200, 255 )
		SetSlotTitleAlpha( elemTable, 255 )
	}
	else
	{
		SetSlotColor( elemTable, 120, 120, 150, 255 )
		SetSlotTitleAlpha( elemTable, 150 )
	}
}

function UpdateBurnCardPosition( vgui, x = 0, y = 0, z = 0, pitch = 0, yaw = 0, roll = 0, hidePostMove = false )
{
	//x = 0
	//y = 0
	//z = 0
	//pitch = 0
	//yaw = 0
	//roll = 0
	//vgui.s.scaleDest = 1
	local origin = VectorCopy( file.origin )
	local angles = VectorCopy( file.angles )

	origin += file.up * y
	origin += file.right * x
	origin += file.forward * z

	angles = angles.AnglesCompose( Vector( 0, roll, 0 ) )
	angles = angles.AnglesCompose( Vector( 0, 0, pitch ) )
	angles = angles.AnglesCompose( Vector( yaw, 0, 0 ) )

	local dif = file.updateDif
	local newAngles = vgui.s.angles.AnglesLerp( angles, dif )
	local newOrigin = vgui.s.origin * ( 1.0 - dif ) + origin * dif

	vgui.s.origin = newOrigin
	vgui.s.angles = newAngles


	if ( vgui.s.colorDest != null )
	{
		local same = true
		foreach ( index, color in vgui.s.colorDest )
		{
			if ( vgui.s.currentColor[ index ] != color )
				same = false
			//local col1 = vgui.s.currentColor[ index ] * ( 1.0 - dif )
			//local col2 = color * dif
			//printt( col1, col2 )
			vgui.s.currentColor[ index ] = ( vgui.s.currentColor[ index ].tofloat() * ( 1.0 - dif ) + color * dif )
			//printt(  vgui.s.currentColor[ index ] )
	//		printt( "set color to ", vgui.s.currentColor[0], vgui.s.currentColor[1], vgui.s.currentColor[2], 255 )
		}

		SetPreviewCardColor( vgui.s.elemTable, vgui.s.currentColor[0], vgui.s.currentColor[1], vgui.s.currentColor[2], 255 )

		if ( same )
			vgui.s.colorDest = null
	}

	//if ( "child" in vgui.s )
	//{
	//	vgui.s.child.SetOrigin( newOrigin + file.up * file.height * vgui.s.currentScale )
	//	vgui.s.child.SetAngles( newAngles )
	//	//printt( "child" )
	//}

	if ( vgui.s.scaleDest != null )
	{
		vgui.s.currentScale = vgui.s.currentScale * ( 1.0 - dif ) + vgui.s.scaleDest * dif
		if ( fabs( vgui.s.currentScale - vgui.s.scaleDest )  < 0.001 )
		{
			vgui.s.currentScale = vgui.s.scaleDest
			vgui.s.scaleDest = null
		}

		local scale = vgui.s.currentScale
		vgui.SetSize( file.width * scale, file.height * scale )
	}

	if ( vgui.s.startMoveTime == null )
	{
		vgui.SetOrigin( newOrigin )
		vgui.SetAngles( newAngles )
		if ( hidePostMove )
		{
			vgui.Hide()
		}
	}
	else
	{
		local maxTime
		switch ( vgui.s.moveType )
		{
			case 5: // new card
				maxTime = 0.6
				break
			case 9: // new card
				maxTime = 0.35
				break
			case 11: // discard
				maxTime = 3.05
				break
			default:
				maxTime = 0.30
				break
		}

		local timePassed = Time() - vgui.s.startMoveTime
		if ( timePassed >= maxTime )
		{
			vgui.s.startMoveTime = null
			newOrigin = origin
			newAngles = angles
			vgui.SetOrigin( newOrigin )
			vgui.SetAngles( newAngles )
			vgui.s.origin = newOrigin
			vgui.s.angles = newAngles

			if ( hidePostMove )
			{
				vgui.Hide()
			}
			return
		}

		switch ( vgui.s.moveType )
		{
			case 0: // card
				local progress = GraphCapped( timePassed, 0, maxTime, 0, 3.13 )
				local dif = sin( progress )


				local difVec = file.right * 0 + file.forward * -1 + file.up * 3
				difVec *= dif

				local viewAngles = Vector( 23, -79, 94 )
				viewAngles = viewAngles.AnglesCompose( Vector( -20, 30, -10 ) )
				local newAngles = viewAngles.AnglesLerp( newAngles, 1.0 - dif )

				vgui.SetOrigin( newOrigin + difVec )
				vgui.SetAngles( newAngles )
				break

			case 9: // card
				local progress = GraphCapped( timePassed, 0, maxTime, 0, 3.13 )
				local dif = sin( progress )


				local difVec = file.right * -10 + file.forward * 0 + file.up * 10
				difVec *= dif

				local viewAngles = Vector( 23, -79, 94 )
				viewAngles = viewAngles.AnglesCompose( Vector( -20, 30, -10 ) )
				local newAngles = viewAngles.AnglesLerp( newAngles, 1.0 - dif )

				vgui.SetOrigin( newOrigin + difVec )
				vgui.SetAngles( newAngles )
				break

			case 11: // discard
				local dif = GraphCapped( timePassed, 0, maxTime, 0, 3.13 )
				local extraDif = dif - 0.5
				if ( extraDif < 0 )
					extraDif = 0

				local difVec = file.right * ( -140 + extraDif * 0 ) + file.forward * 185 + file.up * ( 100 + extraDif * 50 )
				difVec *= dif

				//local viewAngles = Vector( 23, -79, 94 )
				//viewAngles = viewAngles.AnglesCompose( Vector( -20, 30, -10 ) )
				//local newAngles = viewAngles.AnglesLerp( newAngles, 1.0 - dif )

				vgui.SetOrigin( newOrigin + difVec )
				//vgui.SetAngles( newAngles )
				break

			case 5: // new card
				local dif = GraphCapped( timePassed, 0, maxTime, 1.0, 0.0 )
				local difVec = file.right * 50 //+ file.forward * 0 + file.up * 3
				difVec *= dif
				vgui.SetOrigin( newOrigin + difVec )
				break

			case 4: // card
				local progress = GraphCapped( timePassed, 0, maxTime, 0, 3.13 )
				local dif = sin( progress )
				if ( timePassed >= maxTime )
					vgui.s.startMoveTime = null

				local difVec = file.right * 0 + file.forward * -1 + file.up * 8
				difVec *= dif

				local viewAngles = Vector( 23, -79, 94 )
				viewAngles = viewAngles.AnglesCompose( Vector( -20, 30, -10 ) )
				local newAngles = viewAngles.AnglesLerp( newAngles, 1.0 - dif )

				vgui.SetOrigin( newOrigin + difVec )
				vgui.SetAngles( newAngles )
				break

			case 1: // pack
				local maxTime = 0.6
				local dif = GraphCapped( timePassed, 0, maxTime, 0, 1.0 )

				if ( timePassed >= maxTime )
					vgui.s.startMoveTime = null

				local origin = Vector(0,0,0) + file.right * -5 + file.up * -30  + file.forward * -20

				local viewAngles = Vector( 23, -79, 94 )
				viewAngles = viewAngles.AnglesCompose( Vector( -20, 30, -10 ) )
				local newAngles = viewAngles.AnglesLerp( newAngles, 1.0 - dif )
				local newOrigin = vgui.s.origin * ( 1.0 - dif ) + origin * dif

				vgui.SetOrigin( newOrigin ) // + difVec )
				vgui.SetAngles( newAngles )
				break

			case 2: // card
				local progress = GraphCapped( timePassed, 0, maxTime, 0, 3.13 )
				local dif = sin( progress )
				if ( timePassed >= maxTime )
					vgui.s.startMoveTime = null

				local difVec = file.right * 0 + file.forward * -1 + file.up * 10
				difVec *= dif

				local viewAngles = Vector( 23, -79, 94 )
				viewAngles = viewAngles.AnglesCompose( Vector( -20, 30, -10 ) )
				local newAngles = viewAngles.AnglesLerp( newAngles, 1.0 - dif )

				vgui.SetOrigin( newOrigin + difVec )
				vgui.SetAngles( newAngles )
				break


			//case 2: // card
			//	local progress = GraphCapped( timePassed, 0, maxTime, 0, 3.13 )
			//	local dif = sin( progress )
			//	if ( timePassed >= maxTime )
			//		vgui.s.startMoveTime = null
			//
			//	local difVec = file.right * -3.9 + file.forward * 0 + file.up * 0
			//	difVec *= dif
			//
			//	//local viewAngles = Vector( 23, -79, 94 )
			//	local viewAngles = Vector( 0, -79, 94 )
			//	//viewAngles = viewAngles.AnglesCompose( Vector( -20, 30, -10 ) )
			//	viewAngles = viewAngles.AnglesCompose( Vector( 0, 0, 0 ) )
			//	local newAngles = viewAngles.AnglesLerp( newAngles, 1.0 - dif )
			//
			//	vgui.SetOrigin( newOrigin + difVec )
			//	vgui.SetAngles( newAngles )
			//	break

			case 3: // mail
				local maxTime = 0.3

				local progress = GraphCapped( timePassed, 0, maxTime, 0, 3.13 )

				local dif = sin( progress )
				if ( timePassed >= maxTime )
				{
					vgui.s.startMoveTime = null
					vgui.s.currentScale = 0.3
				}
				else
				{
					vgui.s.currentScale = GraphCapped( timePassed, 0, maxTime, 1.0, 0.3 )
				}

				vgui.SetSize( file.width * vgui.s.currentScale, file.height * vgui.s.currentScale )

				local difVec = file.right * -3.0 + file.forward * 0 + file.up * 1.5
				difVec *= dif

				//local viewAngles = Vector( 23, -79, 94 )
				local viewAngles = Vector( 0, -79, 94 )
				//viewAngles = viewAngles.AnglesCompose( Vector( -20, 30, -10 ) )
				viewAngles = viewAngles.AnglesCompose( Vector( 0, 0, 0 ) )
				local newAngles = viewAngles.AnglesLerp( newAngles, 1.0 - dif )


				vgui.SetOrigin( newOrigin + difVec )
				vgui.SetAngles( newAngles )
				break

		}
	}
}

function SetPreviewCardColorDestination( burncard, r, g, b )
{
	if ( burncard.new )
	{
		r += file.newSinTime * 20
		g += file.newSinTime * 100
		b += file.newSinTime * 20
		if ( g > 255 )
			g = 255
		if ( r > 255 )
			r = 255
		if ( b > 255 )
			b = 255
	}

	burncard.vgui.s.colorDest = [ r.tofloat(), g.tofloat(), b.tofloat() ]
}



function PileActive()
{
	return file.piles[ PILE_ACTIVE ]
}

function FindEmptySlotInPile( pile )
{
	for ( local i = pile.burnCardTables.len() - 1; i >= 0; i-- )
	{
		local burncard = pile.burnCardTables[i]
		if ( burncard == null )
			return i
	}

	return null
}

function SetPileOffsetToOccupiedOffset( pile )
{
	for ( local i = 0; i < pile.burnCardTables.len(); i++ )
	{
		local index = i + pile.offset
		index %= pile.burnCardTables.len()

		if ( pile.burnCardTables[ index ] != null )
		{
			SetPileOffset( pile, index )
			return true
		}
	}

	return false
}

function MoveSelectedBurnCardToBack( player, offset = null )
{
	local pileActive = PileActive()

	if ( Pile() == pileActive )
	{
		SetCurrentPile( PILE_DECK )
		return
	}

	if ( offset == null )
	{
		offset = pileActive.offset
		SetPileOffsetToOccupiedOffset( pileActive )
	}

	if ( pileActive.burnCardTables[ offset ] == null )
		return

	if ( offset >= pileActive.burnCardTables.len() )
		return

	if ( offset < 0 )
		return

//	if ( pileActive.burnCardTables[ offset ] == null )
//	{
//		//PressColorChangeRight( player )
//		//PressColorChangeRight( player )
//		BurnCardPressedUp( player )
//		return
//	}

	local deckPile = PileDeck()
	if ( deckPile.burnCardTables.len() >= PersistenceGetArrayCount( _GetBurnCardDeckPersDataPrefix() ) )
		return

	local burncard = pileActive.burnCardTables[ offset ]
	pileActive.burnCardTables[ offset ] = null

	AddBurnCardToTables( burncard, deckPile.burnCardTables )

	player.ClientCommand( "MoveCardToDeck " + GetBurnCardIndex( burncard.cardRef ) + " " + offset )
	UpdateBurnCardHighlight()

	EmitSoundOnEntity( player, "Menu_BurnCard_SortToBottom" )

	burncard.vgui.s.startMoveTime = Time()
	burncard.vgui.s.moveType = 4
	UpdateActiveSlotHint()
}

function FindEmptyActiveBurnCardSlot( player )
{
	local pileActive = PileActive()
	for ( local i = GetPlayerMaxActiveBurnCards( player )-1; i >= 0; i-- )
	{
		if ( pileActive.burnCardTables[i] == null )
			return i
	}

	return null
}

function MoveSelectedBurnCardToFront( player, slotForCard )
{
	local pileDeck = PileDeck()

	local pileActive = PileActive()

	if ( slotForCard < 0 )
		return
	if ( slotForCard >= pileActive.burnCardTables.len() )
		return

	// can't put cards in your active slots if your deck is more than full
	if ( GetPlayerTotalBurnCards( player ) > GetPlayerMaxStoredBurnCards( player ) )
		return

	SetPileOffset( pileActive, slotForCard )

	if ( pileActive.offset >= GetPlayerMaxActiveBurnCards( player ) )
		return
//	printt( "offset" + offset )
//	printt( "GetPlayerMaxActiveBurnCards( player ) ) " + GetPlayerMaxActiveBurnCards( player ) )

	if ( pileDeck.offset < 0 || pileDeck.offset >= pileDeck.burnCardTables.len() )
		return false

	if ( pileActive.offset < 0 || pileActive.offset >= pileActive.burnCardTables.len() )
		return false

	local pileActiveBurncard = pileActive.burnCardTables[ pileActive.offset ]

	local burncard = pileDeck.burnCardTables[ pileDeck.offset ]
	pileActive.burnCardTables[ pileActive.offset ] = burncard
	pileDeck.burnCardTables.remove( pileDeck.offset )

	if ( pileActiveBurncard )
	{
		AddBurnCardToTables( pileActiveBurncard, pileDeck.burnCardTables )
		pileActiveBurncard.vgui.s.moveType = 9
		pileActiveBurncard.vgui.s.startMoveTime = Time()
	}

	player.ClientCommand( "MoveCardToActiveSlot " + GetBurnCardIndex( burncard.cardRef ) + " " + pileDeck.offset + " " + pileActive.offset )

	EmitSoundOnEntity( player, "Menu_BurnCard_SortToTop" )
	burncard.vgui.s.startMoveTime = Time()
	burncard.vgui.s.moveType = 0

	UpdateActiveSlotHint()

	if ( pileDeck.offset < 0 || pileDeck.offset >= pileDeck.burnCardTables.len() )
		BurnCardPressedRight( player )
	UpdateBurnCardHighlight()
	return true
}

function BurnCardNumericSort( card1, card2 )
{
	local index1 = GetBurnCardIndex( card1.cardRef )
	local index2 = GetBurnCardIndex( card2.cardRef )
	if ( index1 > index2 )
		return 1
	if ( index1 < index2 )
		return -1

	return 0
}

function BurnCardGroupSort( card1, card2 )
{
	local group1 = GetBurnCardGroup( card1.cardRef )
	local group2 = GetBurnCardGroup( card2.cardRef )

	if ( group1 > group2 )
		return -1
	if ( group1 < group2 )
		return 1

	if ( group1 == group2 )
	{
		local index1 = GetBurnCardIndex( card1.cardRef )
		local index2 = GetBurnCardIndex( card2.cardRef )
		if ( index1 > index2 )
			return -1
		if ( index1 < index2 )
			return 1
	}

	return 0
}

function AddBurnCardToTables( burncard, burnCardTables )
{
	foreach ( index, card in burnCardTables )
	{
		if ( BurnCardNumericSort( burncard, card ) <= 0 )
		{
			//local group1 = GetBurnCardGroup( burncard.cardRef )
			//local group2 = GetBurnCardGroup( card.cardRef )
			//local index1 = GetBurnCardIndex( burncard.cardRef )
			//local index2 = GetBurnCardIndex( card.cardRef )
			//printt( "group1 " + group1 )
			//printt( "group2 " + group2 )
			//printt( "index1 " + index1 )
			//printt( "index2 " + index2 )
			burnCardTables.insert( index, burncard )
			return
		}
	}
	burnCardTables.append( burncard )
	burnCardTables.sort( BurnCardNumericSort )
}


function RefreshCards( player )
{
	if ( !BurnCardFullyLoaded() )
		return

	RefreshActiveCards( player )
	RefreshDeckCards( player )

	//if ( PileDeck().burnCardTables.len() == 0 )
		SetCurrentPile( PILE_DECK )

	UpdateBurnCardHighlight()
	UpdateHelpButtons( player )

	InstantUpdateOfAllCards()
	UpdateCardHighlightText( player )
}

function RefreshActiveCards( player )
{
	local readingLetter = file.readingLetter != READING_DONE

	local clientPile = PileActive()
	if ( clientPile.len() == 0 )
	{
		// have not opened menu yet.
		return
	}

	local serverActiveCards = GetPlayerActiveBurnCards( player )
	local origin = Vector(0,0,0)
	local count = 0

	local max = min( GetPlayerMaxActiveBurnCards( player ), clientPile.burnCardTables.len() )
	for ( local i = 0; i < max; i++ )
	{
		local clientCardTable = clientPile.burnCardTables[i]
		local serverActiveCard = serverActiveCards[i]

		if ( clientCardTable == null )
		{
			// there is no vgui on the client

			if ( serverActiveCard == null )
			{
				// there is also no card on the server
				continue
			}

			// the server has a card but the client doesn't, so add the card to the client
			local newOrigin = origin + file.forward * count * -30
			local vgui = CreateBurnCardVGUI( null, newOrigin, Vector(0,0,0) )
			if ( readingLetter )
				vgui.Hide()

			clientPile.burnCardTables[i] = { cardRef = null, vgui = vgui, new = false }
			count++
		}
		else
		{
			// the client has a card

			if ( serverActiveCard != null )
			{
				// the server has a card too.
				continue
			}

			// the server has no card, so delete this card

			if ( IsValid( clientPile.burnCardTables[i].vgui ) )
				clientPile.burnCardTables[i].vgui.Destroy()

			clientPile.burnCardTables[i] = null
		}
	}

	foreach ( index, cardRef in serverActiveCards )
	{
		if ( index >= clientPile.burnCardTables.len() )
			continue

		local clientCardTable = clientPile.burnCardTables[ index ]
		if ( clientCardTable == null )
			continue

		clientCardTable.cardRef = cardRef
		SetPreviewCard( clientCardTable.cardRef, clientCardTable.vgui.s.elemTable )
	}
}

function RefreshDeckCards( player )
{
	local readingLetter = file.readingLetter != READING_DONE

	local pile = PileDeck()
	local deck = GetPlayerBurnCardDeck( player )

	for ( local i = 0; i < pile.burnCardTables.len(); i++ )
	{
		Assert( pile.burnCardTables[i] != null )
		Assert( pile.burnCardTables[i].vgui != null )
	}

	if ( deck.len() < pile.burnCardTables.len() )
	{
		// remove dead vguis
		for ( local i = deck.len(); i < pile.burnCardTables.len(); i++ )
		{
			if ( IsValid( pile.burnCardTables[i].vgui ) )
				pile.burnCardTables[i].vgui.Destroy()

			pile.burnCardTables.remove(i)
			i--
		}
	}
	else if ( deck.len() > pile.burnCardTables.len() )
	{
		local origin = Vector(0,0,0)

		// add new vguis
		local count = 0

		// add new tables/vguis
		for ( local i = pile.burnCardTables.len(); i < deck.len(); i++ )
		{
			local newOrigin = origin + file.forward * count * -30
			local vgui = CreateBurnCardVGUI( null, newOrigin, Vector(0,0,0) )
			if ( readingLetter )
				vgui.Hide()

			pile.burnCardTables.append( { cardRef = null, vgui = vgui, new = false } )
			count++
		}
	}

	foreach ( index, bcard in deck )
	{
		local burncard = pile.burnCardTables[ index ]
		burncard.cardRef = bcard.cardRef
		burncard.new = bcard.new
		SetPreviewCard( burncard.cardRef, burncard.vgui.s.elemTable )
	}
}

function UpdateCardHighlightText( player )
{
	UpdateNewCards( player )
}

function UpdateNewCards( player )
{
	local pile = PileDeck()

	foreach ( burncard in pile.burnCardTables )
	{
		if ( burncard.new )
		{
			burncard.vgui.s.elemTable.PreviewCard_new.Show()
			burncard.vgui.s.elemTable.PreviewCard_new.SetText( "#NEW" )
			burncard.vgui.s.elemTable.PreviewCard_new.SetColor( 100, 255, 100, 255 )
		}
		else
		{
			burncard.vgui.s.elemTable.PreviewCard_new.Hide()
		}
	}
}

//function AddNewVGUI( parentVGUI )
//{
//	local vgui = CreateClientsideVGuiScreen( "vgui_burn_card_slot", VGUI_SCREEN_PASS_WORLD, Vector(0,0,0), Vector(0,0,0), file.width, file.height )
//	file.storedVguis.append( vgui )
//
//	parentVGUI.s.child <- vgui
//}
//
//function RemoveNewVGUI( parentVGUI )
//{
//	foreach ( index, vgui in file.storedVguis )
//	{
//		if ( vgui == parentVGUI.s.child )
//		{
//			file.storedVguis.remove( index )
//			break
//		}
//	}
//
//	parentVGUI.s.child.Destroy()
//	delete parentVGUI.s.child
//}

function CreateBaseVgui( vgui )
{
	vgui.s.origin <- null
	vgui.s.angles <- null
	vgui.s.startMoveTime <- null
	vgui.s.scaleDest <- null
	vgui.s.currentScale <- 1.0
	vgui.s.colorDest <- null
	vgui.s.currentColor <- [ 255, 255, 255 ]
	vgui.s.moveType <- 0
	vgui.s.panel <- vgui.GetPanel()
	vgui.s.elemTable <- null
}

function CreateBackgroundVGUI( org, angles )
{
	local vgui = CreateClientsideVGuiScreen( "vgui_burn_card_slot", VGUI_SCREEN_PASS_WORLD, org, angles, file.width, file.height )
	file.storedVguis.append( vgui )

	local burnCardVGUI = CreateBurnCardSlotVGUI( vgui )
	//ShowPreviewCard( burnCardVGUI )
	//SetPreviewCardColor( burnCardVGUI, 150, 150, 150, 255 )
	//burnCardVGUI.PreviewCard_background.SetImage( "burncards/burncard_mid_blank" )
	PreviewCardOutline_Hide( burnCardVGUI )
	CreateBaseVgui( vgui )
	vgui.s.origin = org
	vgui.s.angles = Vector(0,0,0)
	vgui.s.elemTable = burnCardVGUI

	return vgui
}

function CreateBurnCardVGUI( cardRef, org, angles )
{
	local vgui = CreateClientsideVGuiScreen( "vgui_burn_card", VGUI_SCREEN_PASS_WORLD, org, angles, file.width, file.height )
	file.storedVguis.append( vgui )

	local burnCardVGUI = CreatePreviewCardFromStandardElements( vgui )
	ShowPreviewCard( burnCardVGUI )
	if ( cardRef != null )
		SetPreviewCard( cardRef, burnCardVGUI )

	CreateBaseVgui( vgui )
	vgui.s.origin = org
	vgui.s.angles = Vector(0,0,0)
	vgui.s.elemTable = burnCardVGUI

	return vgui
}



function PressColorChangeRight( player )
{
	local pileActive = PileActive()
	SetPileOffsetWrap( pileActive, pileActive.offset + 1 )
	return

	Signal( file, "NewColorChange" )
	EndSignal( file, "NewColorChange" )
	local pile = Pile()
	if ( pile != PileDeck() )
		return
	if ( pile.offset - 1 <= 0 )
	{
		BurnCardPressedRight( player )
		return
	}

	if ( pile.offset < 0 )
		return
	if ( pile.offset >= pile.burnCardTables.len() )
		return

	PressRightUntilNewGroup( player )
	//PressRightUntilLastOfCurrentGroup( player )
}

function PressRightUntilNewGroup( player )
{
	local pile = Pile()
	local offset = pile.offset
	if ( file.zoomed )
		offset--

	if ( offset < 0 )
		return
	if ( offset >= pile.burnCardTables.len() )
		return

	local cardRef = pile.burnCardTables[ offset ].cardRef
	local group = GetBurnCardGroup( cardRef )
	local oldOffset = offset

	for ( ;; )
	{
		BurnCardPressedRight( player )
		if ( oldOffset == pile.offset )
			break

		if ( pile.offset - 1 == -1 )
			break
		oldOffset = pile.offset

		offset = pile.offset
		if ( file.zoomed )
			offset--

		cardRef = pile.burnCardTables[ offset ].cardRef
		if ( GetBurnCardGroup( cardRef ) != group )
			break
		wait 0
	}
}

function PressRightUntilLastOfCurrentGroup( player )
{
	local pile = Pile()
	if ( pile.offset < 0 )
		return
	if ( pile.offset >= pile.burnCardTables.len() )
		return
	local cardRef = pile.burnCardTables[ pile.offset ].cardRef
	local group = GetBurnCardGroup( cardRef )
	local oldOffset = pile.offset

	for ( ;; )
	{
		if ( pile.offset - 1 < 0 )
			break

		local nextCard = pile.burnCardTables[ pile.offset - 1 ].cardRef
		local nextGroup = GetBurnCardGroup( nextCard )

		if ( nextGroup != group )
			return

		BurnCardPressedRight( player )
		wait 0
		if ( pile.offset == -1 )
			break

		if ( oldOffset == pile.offset )
			break

		oldOffset = pile.offset
	}
}

function PressColorChangeLeft( player )
{
	local pileActive = PileActive()
	SetPileOffsetWrap( pileActive, pileActive.offset - 1 )
	return

	Signal( file, "NewColorChange" )
	EndSignal( file, "NewColorChange" )
	local pile = Pile()
	local pile = Pile()
	if ( pile != PileDeck() )
		return

	if ( pile.offset + 1 >= pile.burnCardTables.len() )
	{
		BurnCardPressedLeft( player )
		return
	}

	local cardRef = pile.burnCardTables[ pile.offset ].cardRef
	local group = GetBurnCardGroup( cardRef )
	local newGroup

	for ( ;; )
	{
		SetPileOffset( pile, pile.offset + 1 )
		wait 0
		if ( pile.offset >= pile.burnCardTables.len() - 1 )
			return

		cardRef = pile.burnCardTables[ pile.offset ].cardRef
		newGroup = GetBurnCardGroup( cardRef )

		if ( newGroup != group )
			break
	}

}


function Pile()
{
	return file.piles[ GetCurrentPileIndex() ]
}

function PileDeck()
{
	return file.piles[ PILE_DECK ]
}


function SetPileOffsetWrap( pile, val )
{
	local max = pile.burnCardTables.len()

	if ( pile == PileActive() )
	{
		max = file.maxActiveBurnCards
	}

	if ( val < 0 )
	{
		val = max - 1
	}

	if ( val >= max )
	{
		val = 0
	}

	SetPileInternal( pile, val )
}

function ClearBurnCardNew( index )
{
	GetLocalClientPlayer().ClientCommand( "BCClearNew " + index )
}

function RemoveSelectedNew( pile )
{
	if ( pile.offset >= pile.burnCardTables.len() )
		return
	if ( pile.offset < 0 )
		return
	local selectedCard = pile.burnCardTables[ pile.offset ]
	if ( selectedCard == null )
		return

	if ( !selectedCard.new )
		return

	ClearBurnCardNew( pile.offset )
	local elemTable = selectedCard.vgui.s.elemTable
	elemTable.PreviewCard_new.Hide()

	PreviewCardOutline_Hide( elemTable )
	selectedCard.new = false
}

function SetPileOffset( pile, val )
{
	if ( pile.offset >= 0 && pile.offset < pile.burnCardTables.len() )
	{
		// remove new from the card we're moving away from
		RemoveSelectedNew( pile )
	}

	if ( val < 0 )
	{
		val = 0
	}

	local max = pile.burnCardTables.len()
	if ( pile == PileActive() )
	{
		max = file.maxActiveBurnCards
	}

	if ( val >= max )
	{
		val = max - 1
		if ( val < 0 )
			return
	}

	local player = GetLocalClientPlayer()
	if ( pile.offset < val )
		EmitSoundOnEntity( player, "Menu_BurnCard_MoveLeft" )
	else if ( pile.offset > val )
		EmitSoundOnEntity( player, "Menu_BurnCard_MoveRight" )

	SetPileInternal( pile, val )
}

function SetPileInternal( pile, val )
{
	pile.offset = val
	local player = GetLocalClientPlayer()
	if ( pile == Pile() )
	{
		thread UpdateCurrentCardOnServer_Delayed( player, pile.index, val )
	}

	UpdateBurnCardHighlight()
}

function UpdateCurrentCardOnServer_Delayed( player, index, val )
{
	player.EndSignal( "OnDestroy" )
	player.Signal( "NewCurrentOffset" )
	player.EndSignal( "NewCurrentOffset" )

	// don't spawm this client command
	wait 1.5

	player.ClientCommand( "BCSetCurrentOffset " + index + " " + val )
}

function DisableAllVGUIs()
{
	local below = Vector(0,0,0) + file.forward * 30
	foreach ( pile in file.piles )
	{
		foreach ( index, burncard in pile.burnCardTables )
		{
			if ( burncard == null )
				continue
			local vgui = burncard.vgui
			//vgui.s.origin = below + file.forward * ( index * 2.0 )
			//vgui.SetOrigin( vgui.s.origin )
			//vgui.s.enabled = false
			vgui.Hide()
		}
	}
}

function UpdateBurnCardHighlight()
{
	local pileActive = PileActive()
	foreach ( burncard in pileActive.backgroundVGUIS )
	{
		PreviewCardOutline_Hide( burncard.s.elemTable )
	}

	foreach ( index, burncard in pileActive.burnCardTables )
	{
		if ( burncard == null )
			continue

		local vgui = burncard.vgui
		PreviewCardOutline_Hide( vgui.s.elemTable )
	}

	local pileDeck = PileDeck()
	foreach ( burncard in pileDeck.burnCardTables )
	{
		PreviewCardOutline_Hide( burncard.vgui.s.elemTable )
	}

	local pileActive = PileActive()
	foreach ( index, burncard in pileActive.burnCardTables )
	{
		if ( index != pileActive.offset )
			continue

		if ( burncard == null )
		{
			local elemTable = pileActive.backgroundVGUIS[ index ].s.elemTable
			PreviewCardOutline_Show( elemTable )
			elemTable.PreviewCard_outline.SetColor( 120, 180, 200, 50 )
			continue
		}

		local elemTable = burncard.vgui.s.elemTable
		PreviewCardOutline_Show( elemTable )
		elemTable.PreviewCard_outline.SetColor( 120, 180, 200, 50 )
	}

	local pile = Pile()
	ToggleSellValueLabel( pile.burnCardTables.len() )
	if ( pile.offset < 0 )
		return
	if ( pile.offset >= pile.burnCardTables.len() )
		return

	if ( "backgroundVGUIS" in pile )
	{
		PreviewCardOutline_Show( pile.backgroundVGUIS[ pile.offset ].s.elemTable )
		pile.backgroundVGUIS[ pile.offset ].s.elemTable.PreviewCard_outline.SetColor( 255, 205, 0, 250 )

		if ( pile.burnCardTables[ pile.offset ] != null )
		{
			local elemTable = pile.burnCardTables[ pile.offset ].vgui.s.elemTable
			PreviewCardOutline_Show( elemTable )
			elemTable.PreviewCard_outline.SetColor( 255, 205, 0, 250 )
			return
		}
		return
	}

	local cardRef = pile.burnCardTables[ pile.offset ].cardRef
	OnBurnCardHighlight( cardRef )

	local elemTable = pile.burnCardTables[ pile.offset ].vgui.s.elemTable
	PreviewCardOutline_Show( elemTable )

	if ( pile == PileDeck() )
		elemTable.PreviewCard_outline.SetColor( 255, 205, 0, 250 )
}
Globalize( UpdateBurnCardHighlight )


function GetCurrentPileIndex()
{
	// unhelpful guard, needs more testing but should prevent catastrophic ui explosions
	if ( file.currentPileIndex >= 100 )
		return 0

	return file.currentPileIndex
}
Globalize( GetCurrentPileIndex )


function UpdateHelpButtons( player )
{
	local pile = Pile()
	local count = pile.burnCardTables.len()
	local readingLetter = file.readingLetter
	local currentPileIndex = file.currentPileIndex

	local msg
	if ( pile == PileDeck() )
	{
		msg = "#BC_EQUIP"
	}
	else
	if ( pile == PileActive() )
	{
		msg = "#BC_SELECT"
	}
	msg = "\"" + msg + "\""

	if ( file.readingLetter != READING_DONE )
	{
		file.hudElemsIntro.BurnCardContinue.Show()
		return
	}

}


function TryFinishReadingLetter( player )
{
	file.buttonHeld[ "a" ] <- true
	if ( file.readingLetter == READING_WAITING_TO_CONTINUE )
	{
		ReadLetter( player )
		SetCurrentPile( PILE_DECK )
		return true
	}
	return false
}

function BurnCardSelectCardInternal( player )
{
//	if ( file.zoomed )
//		return
	local pile = Pile()

	if ( TryFinishReadingLetter( player ) )
		return

	if ( file.disableInput )
		return

	if ( file.readingLetter >= READING_DONE )
	{
		if ( pile == PileDeck() )
		{
			// can't put cards in your active slots if your deck is more than full
			if ( GetPlayerTotalBurnCards( player ) > GetPlayerMaxStoredBurnCards( player ) )
				return

			local slotForCard = FindEmptyActiveBurnCardSlot( player )
			if ( slotForCard != null )
				SetPileOffset( PileActive(), slotForCard )

			SetCurrentPile( PILE_ACTIVE )
			RemoveSelectedNew( pile )
		}
		else
		if ( pile == PileActive() )
		{
			//return
			MoveSelectedBurnCardToFront( player, pile.offset )
			//if ( pile.offset < GetPlayerMaxActiveBurnCards( player ) )
			//{
			//	if ( PileDeck().burnCardTables.len() )
			//}

			SetCurrentPile( PILE_DECK )
		}
	}
}

function BurnCardPressedUp( player )
{
}

function BurnCardPressedDown( player )
{
}

function SetCurrentPile( pileName )
{
	Assert( typeof pileName == "integer" )
//	if ( GetCurrentPileIndex() == pileName )
//		return

	//if ( pileName == PILE_ACTIVE )
	//{
	//	if ( FindEmptySlotInPile( PileActive() ) != null )
	//		return
	//}

	local player = GetLocalClientPlayer()
	//player.ClientCommand( "script_ui ResetMoveTime()" )
	printt( "SetCurrentPile " + pileName )
	player.ClientCommand( "BCSetCurrentPile " + pileName )
	file.currentPileIndex = pileName
	UpdateBurnCardHighlight()
	UpdateActiveSlotHint()
	UpdateHelpButtons( player )
}

function BurnCardActiveSlot_Click( player, offset )
{
	//BurnCardSelectCard( player )
	MoveSelectedBurnCardToFront( player, offset )
	//player.ClientCommand( "script_ui BurnCardSetPile(0)" )
}

function BurnCardActiveSlot_Focus( player, offset )
{
	local activePile = PileActive()
	if ( Pile() != activePile )
		return

	SetPileOffset( activePile, offset )
}

function BurnCardFullyLoaded()
{
	local player = GetLocalViewPlayer()
	if ( !IsValid( player ) )
		return false

	if ( !IsConnected() )
		return false

	return "loaded" in file
}

function RedrawBurnCardDeckNoZoomAll( pile, pileXOffset, pileYOffset, pileZOffset )
{
	local selectedPile = pile == Pile()
	pileXOffset += file.width * 0.5 - 1.96
	pileXOffset += 5.5

	pileZOffset += 4.5
	pileYOffset += -0.5

	//if ( file.zoomed )
	//{
	//	pileZOffset += -7.0
	//	pileXOffset += 6.3
	//	pileYOffset += -2.7
	//}


	foreach ( burncard in pile.burnCardTables )
	{
		burncard.vgui.s.scaleDest = 1.0
	}

	local x = pileXOffset
	local y = pileYOffset
	local z = pileZOffset

	local pitch = 0
	local yaw = 0
	local roll = 5
	if ( pile.offset >= 0 && pile.burnCardTables.len() > 0 )
	{
		local burncard = pile.burnCardTables[ pile.offset ]
		local vgui = burncard.vgui

		if ( file.zoomed )
		{
			SetPreviewCardColorDestination( burncard, 50, 50, 50 )
		}
		else
		{
			if ( selectedPile )
				SetPreviewCardColorDestination( burncard, 255, 255, 255 )
			else
				SetPreviewCardColorDestination( burncard, 185, 185, 185 )
		}

		local pileActive = PileActive()
		if ( Pile() == pileActive )
		{
			local scale = 0.5
			local offset = pileActive.offset
			x = -8.4 + offset * file.width * scale * 1.2
			y = 0
			z = -6
			pitch = -60
			yaw = 20
			roll = 20

			pitch += sin( Time() * 5 ) * 2.0
			roll += sin( Time() * 3 ) * 2.0
			//local rollChange = -10
			//roll = rollChange * ( offset - 1 )
			vgui.s.scaleDest = scale
		}

		vgui.Show()
		UpdateBurnCardPosition( vgui, x, y, z, pitch, yaw, roll )
	}

	local drewPack = false

	local minCol = 60
	x = 2 + pileXOffset
	y = -0.2 + pileYOffset
	z = pileZOffset
	roll = 20
	pitch = 0
	yaw = 0

	local xOff = -1.0
	local yOff = 1.0
	local zOff = 0.5
	local rollOff = 3.0
	local extraYOffset = -0.2
	local col

	if ( file.zoomed || !selectedPile )
		col = 50
	else
		col = 150

	for ( local i = pile.offset + 1; i < pile.burnCardTables.len(); i++ )
	{
		local burncard = pile.burnCardTables[ i ]
		local vgui = burncard.vgui

		SetPreviewCardColorDestination( burncard, col, col, col )

		x += xOff
		y += yOff
		z += zOff
		roll += rollOff
		xOff *= 0.8
		yOff *= 0.8
		yOff += extraYOffset
		zOff *= 0.8
		rollOff *= 0.8
		extraYOffset *= 0.88
		UpdateBurnCardPosition( vgui, x, y, z, pitch, yaw, roll )
		col -= 10
		if ( col < minCol )
			col = minCol
	}

	x = 4.4 + pileXOffset
	y = 0 + pileYOffset
	z = -2 + pileZOffset
	roll = 0

	//local extra = 4 - ( vguis.len() - file.offset )
	//y += extra * 5.0

	local xOff = 1.0
	local yOff = 1.0
	local zOff = -0.5
	local rollOff = -5.0
	local extraYOffset = 0.5

	local pitch = 0
	local pitchOff = -5.5

	if ( file.zoomed || !selectedPile )
		col = 50
	else
		col = 150

	for ( local i = pile.offset - 1; i >= 0 && i < pile.burnCardTables.len(); i-- )
	{
		local burncard = pile.burnCardTables[ i ]
		local vgui = burncard.vgui
		SetPreviewCardColorDestination( burncard, col, col, col )


		col -= 10
		if ( col < minCol )
			col = minCol

		x += xOff
		y -= yOff

		//if ( i < 2 )
		//{
		//	if ( pile.offset > i + 1 )
		//	{
	//	//		y -= 2.2
		//		y -= 2.8
		//		z += -0.5
		//		roll += 4.0
		//	}
		//}

		z += zOff
		roll += rollOff
		xOff *= 0.75
		yOff *= 0.8
		yOff += extraYOffset
		zOff *= 0.9
		rollOff *= 0.8
		extraYOffset = 0.0

		pitch += pitchOff
		pitchOff *= 0.9

		pitch = 0
		if ( i == pile.offset + 1 )
			UpdateBurnCardPosition( vgui, x, y, z, pitch, yaw, roll + 3 )
		else
			UpdateBurnCardPosition( vgui, x, y, z, pitch, yaw, roll )
	}
}

function OnBurnCardHighlight( cardRef )
{
	local player = GetLocalViewPlayer()
	local progress = player.GetPersistentVar( "burncardStoryProgress" )
	if ( UsingAlternateBurnCardPersistence() || IsDelta() )
		progress = BURNCARD_STORY_PROGRESS_COMPLETE
	local rarity = GetBurnCardRarity( cardRef )

	local coinCost = GetSellCostOfRarity( rarity )

	if ( progress != BURNCARD_STORY_PROGRESS_INTRO )
	{
		if ( IsBlackMarketUnlocked( player ) )
		{
			local coinModifier = GetBurnCardSellAmountModifier()
			file.burnCardCoinValue.Show()
			file.burnCardCoinValueIcon.Show()
			file.burnCardCoinValue.SetText( "#BC_COIN_VALUE", coinCost * coinModifier )
		}
	}
}

function PulseSellValueLabel()
{
	file.burnCardCoinValue.SetPulsate( 0.1, 1.0, 12 )
	file.burnCardCoinValueIcon.SetPulsate( 0.1, 1.0, 12)
	wait 1
	file.burnCardCoinValue.ClearPulsate()
	file.burnCardCoinValueIcon.ClearPulsate()
}

function ToggleSellValueLabel( pileLength )
{
	if ( pileLength <= 0 )
	{
		file.burnCardCoinValue.Hide()
		file.burnCardCoinValueIcon.Hide()
	}
}

function SCB_RefreshCards()
{
	RefreshCards( GetLocalClientPlayer() )
}
Globalize( SCB_RefreshCards )