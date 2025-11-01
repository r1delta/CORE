function main()
{
	Globalize( InitNewBurnCardMenu )
	Globalize( OnOpenBurnCards_NewCards )
}

function InitNewBurnCardMenu( menu )
{
	file.buttonLastFocus <- null
	local previewCardElem = menu.GetChild( "PreviewCard_NestedPanel" )
	file.burnCardPreviewCard <- CreatePreviewCardFromStandardElements( previewCardElem )
	HidePreviewCard( file.burnCardPreviewCard )

	// new burn card stuff
	level.newBurnCardsArray <- []
	level.newBurnCardCurrentPage <- 0
	level.NewBurnCardBackground	<- menu.GetChild( "NewBurnCardBackground" )
	level.NewBurnCardDialog	<- menu.GetChild( "NewBurnCardDialog" )
	level.NewBurnCardTitle <- menu.GetChild( "NewBurnCardTitle" )


	level.newBurncard_ArrowLeft <- menu.GetChild( "NewBurncard_ArrowLeft" )
	level.newBurncard_ArrowRight <- menu.GetChild( "NewBurncard_ArrowRight" )

	level.newBurnCardChangePageButtons <- GetElementsByClassname( menu, "NewBurnCardChangePageClass" )
	foreach ( index, button in level.newBurnCardChangePageButtons )
	{
		local table = {}
		table.button <- button

		button.SetParentMenu( menu ) // TMP: should be code
		local buttonID = button.GetScriptID().tointeger()
		button.loadoutID = buttonID
		button.AddEventHandler( UIE_GET_FOCUS, Bind( OnNewBurnCardChangePage_Focus ) )
	}


	local buttons = GetElementsByClassname( menu, "BurnCardNewCardClass" )
	local panels = GetElementsByClassname( menu, "BurnCardNewCardPanelClass" )

	level.newBurnCardButtons <- []
	level.newBurnCardButtons.resize( buttons.len() )
	NEW_CARDS_PER_PAGE <- buttons.len()
	foreach ( index, button in buttons )
	{
		local table = {}
		table.button <- button
		table.active <- true

		table.button.SetText( "" )

		button.SetParentMenu( menu )
		local buttonID = button.GetScriptID().tointeger()
		button.loadoutID = buttonID
		button.AddEventHandler( UIE_GET_FOCUS, Bind( OnNewBurnCard_Focus ) )
		button.AddEventHandler( UIE_LOSE_FOCUS, Bind( OnNewBurnCardButton_LoseFocus ) )

		CreateBurnCardPanel( table, panels[ button.loadoutID ] )
		level.newBurnCardButtons[ buttonID ] = table
	}



	level.newBurnCardArrowButtons <- []
	local buttons = GetElementsByClassname( menu, "MenuArrowButtonClass_NewBurnCard" )
	foreach ( index, button in buttons )
	{
		local table = {}
		table.button <- button

		button.SetParentMenu( menu ) // TMP: should be code
		local buttonID = button.GetScriptID().tointeger()
		button.loadoutID = buttonID
		button.Hide()
		button.AddEventHandler( UIE_CLICK, Bind( OnNewBurnCardArrowButton_Activate ) )
		level.newBurnCardArrowButtons.append( button )
	}

	level.newBurnCardPageIndicators <- GetElementsByClassname( menu, "NewBurnCard_PageIndicatorImageClass" )
	local maxPages = GetMaxNewBurnCardPages()
	for ( local i = 0; i < level.newBurnCardPageIndicators.len(); i++ )
	{
		local page = level.newBurnCardPageIndicators[i]
		if ( i > maxPages )
			page.Hide()
	}

	// offset the dots
	local firstPage = level.newBurnCardPageIndicators[0]
	local basePos = firstPage.GetBasePos()
	local width = firstPage.GetWidth()
	local offset = ( maxPages + 1 ) * width * 0.5
	offset -= width * 0.5
	firstPage.SetPos( basePos[0] - offset, basePos[1] )


	NewBurnCardIncrementPage(0)

}


function OnNewBurnCard_Focus( button )
{
	local id = button.loadoutID
	id += level.newBurnCardCurrentPage * NEW_CARDS_PER_PAGE
	if ( id >= level.newBurnCardsArray.len() )
		return

	local cardRef = level.newBurnCardsArray[ id ]

	if ( cardRef != null )
	{
		ShowPreviewCard( file.burnCardPreviewCard )
		SetPreviewCard( cardRef, file.burnCardPreviewCard )

	}

	thread DelayedUpdateNewBurnCardButtonText()
}

function OnNewBurnCardButton_LoseFocus( button )
{
	file.buttonLastFocus = button
}

function HideNewBurnCardMenu()
{
	//CloseMenu( GetMenu( "BurnCards_newcards" ) )
	CloseTopMenu()
}



function OnOpenBurnCards_NewCards()
{

	level.newBurnCardCurrentPage = 0
	level.newBurnCardsArray = GetUnopenedCards()

	local rares = 0
	foreach ( card in level.newBurnCardsArray )
	{
		if ( GetBurnCardRarity( card ) >= BURNCARD_RARE )
			rares++
	}

	if ( rares > 1 )
		level.NewBurnCardTitle.SetText( "*RARE PACK*" )
	else
		level.NewBurnCardTitle.SetText( "" )

//	ClientCommand( "BCOpenCards" )
	UpdateNewBurnCardButtonText()
	thread FadeInCards()
}

function DelayedUpdateNewBurnCardButtonText()
{
	WaitEndFrame() // for IsFocused()
	if ( !IsConnected() )
		return

	UpdateNewBurnCardButtonText()
}

function FadeInCards()
{
	for ( local i = 0; i < NEW_CARDS_PER_PAGE; i++ )
	{
		local table = level.newBurnCardButtons[ i ]

		thread FadeElemIn( table.count )
		thread FadeElemIn( table.title )
		thread FadeElemIn( table.image )
		thread FadeElemIn( table.background )
	}
}

function FadeElemIn( elem )
{
//	elem.Show()
	elem.SetAlpha( 0 )
	wait 0
	elem.SetAlpha( 0 )
	elem.FadeOverTime( 255, 0.3, INTERPOLATOR_ACCEL )
}

function UpdateNewBurnCardButtonText()
{
	if ( level.newBurnCardCurrentPage >= GetMaxNewBurnCardPages() )
		level.newBurncard_ArrowRight.Hide()
	else
		level.newBurncard_ArrowRight.Show()

	if ( level.newBurnCardCurrentPage <= 0 )
		level.newBurncard_ArrowLeft.Hide()
	else
		level.newBurncard_ArrowLeft.Show()

	for ( local i = 0; i < NEW_CARDS_PER_PAGE; i++ )
	{
		local index = i + level.newBurnCardCurrentPage * NEW_CARDS_PER_PAGE
		local table = level.newBurnCardButtons[ i ]
		if ( index >= level.newBurnCardsArray.len() )
		{
			table.count.Hide()
			table.title.Hide()
			table.image.Hide()
			table.background.Hide()
			table.button.SetEnabled( false )
			continue
		}

		local cardRef = level.newBurnCardsArray[ index ]
		//UpdateButtonFromTable( table, cardRef, 0 )
		local isSelected = table.button.IsFocused()
		DrawBurnCard( table, isSelected, true, cardRef )
		table.button.SetEnabled( true )
	}
}

function GetMaxNewBurnCardPages()
{
	local unopenedCards = level.newBurnCardsArray
	return ( unopenedCards.len() / NEW_CARDS_PER_PAGE ).tointeger() - 1
}

function NewBurnCardIncrementPage( val )
{
	level.newBurnCardCurrentPage += val
	local maxPages = GetMaxNewBurnCardPages()

	if ( level.newBurnCardCurrentPage > maxPages )
	{
		level.newBurnCardCurrentPage = maxPages
		return false
	}

	if ( level.newBurnCardCurrentPage < 0 )
	{
		level.newBurnCardCurrentPage = 0
		return false
	}

	for ( local i = 0; i <= maxPages; i++ )
	{
		local pageIndicator = level.newBurnCardPageIndicators[i]

		if ( i == level.newBurnCardCurrentPage )
			pageIndicator.SetImage( "../vgui/burncards/burncard_page_indicator_on" )
		else
			pageIndicator.SetImage( "../vgui/burncards/burncard_page_indicator_off" )
	}

	thread DelayedUpdateNewBurnCardButtonText()

	return true
}

function OnNewBurnCardChangePage_Focus( button )
{
	local index = button.loadoutID

	// changes the page when it gains focus
	if ( NewBurnCardIncrementPage( index ) )
	{
		if ( index == 1 )
		{
			level.newBurnCardButtons[ 0 ].button.SetFocused()
		}
		else
		{
			level.newBurnCardButtons[ level.newBurnCardButtons.len() - 1 ].button.SetFocused()
		}
		return
	}

	if ( file.buttonLastFocus )
	{
		file.buttonLastFocus.SetFocused()
	}
}


function OnNewBurnCardArrowButton_Activate( button )
{
	if ( !IsConnected() )
		return

	if ( button.loadoutID )
	{
		NewBurnCardIncrementPage( 1 )
	}
	else
	{
		NewBurnCardIncrementPage( -1 )
	}
}
