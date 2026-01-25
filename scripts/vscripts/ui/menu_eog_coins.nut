const NUM_COINS_BREAKDOWN_LINES = 9
const NUM_COINS_SUBCAT_LINES = 14

menu <- null
buttonsRegistered <- false
buttonEventsRegistered <- false
menuAnimDone <- false

//#############################
// Hud elems
//#############################
pilotImage <- null

coinsEarnedBreakdownButtons <- []
coinsEarnedTotalDesc <- null
coinsEarnedTotal <- null
coinsEarnedTotalVal <- 0

level.matchCoinsByType <- {}
level.matchCoinsCountByType <- {}
matchCoinsByCategory <- {}

subCatNameLabels <- []
subCatValueLabels <- []
previousCoinCount <- null
newCoinCount <- null
//#############################

level.coinTypeDescriptions <- {}
level.coinTypeDescriptions[ eCoinRewardType.MATCH_COMPLETION ]			<- "#COIN_REWARD_MATCH_COMPLETION_LABEL"
level.coinTypeDescriptions[ eCoinRewardType.MATCH_VICTORY ]				<- "#COIN_REWARD_MATCH_VICTORY_LABEL"
level.coinTypeDescriptions[ eCoinRewardType.FIRST_WIN_OF_DAY ]			<- "#COIN_REWARD_FIRST_WIN_OF_DAY_LABEL"
level.coinTypeDescriptions[ eCoinRewardType.DAILY_CHALLENGE ]			<- "#COIN_REWARD_DAILY_CHALLENGE_LABEL"
level.coinTypeDescriptions[ eCoinRewardType.DISCARD ]					<- "#COIN_REWARD_DISCARD"
level.coinTypeDescriptions[ eCoinRewardType.MAX_LEVEL_CONVERSION ]		<- "#COIN_REWARD_MAX_LEVEL_XP_LABEL"

coinCategoryDescriptions <- {}
coinCategoryDescriptions[ eCoinRewardCategory.MATCH_COMPLETION ]		<- "#COIN_REWARD_MATCH_COMPLETION_LABEL"
coinCategoryDescriptions[ eCoinRewardCategory.MATCH_VICTORY ]			<- "#COIN_REWARD_MATCH_VICTORY_LABEL"
coinCategoryDescriptions[ eCoinRewardCategory.DAILIES ]					<- "#COIN_REWARD_CATEGORY_DAILIES"
coinCategoryDescriptions[ eCoinRewardCategory.MISC ]					<- "#COIN_REWARD_CATEGORY_MISC"

level.coinCategory <- {}
level.coinCategory[ eCoinRewardType.MATCH_COMPLETION  ]					<- eCoinRewardCategory.MATCH_COMPLETION
level.coinCategory[ eCoinRewardType.MATCH_VICTORY  ]					<- eCoinRewardCategory.MATCH_VICTORY
level.coinCategory[ eCoinRewardType.FIRST_WIN_OF_DAY  ]					<- eCoinRewardCategory.DAILIES
level.coinCategory[ eCoinRewardType.DAILY_CHALLENGE  ]					<- eCoinRewardCategory.DAILIES
level.coinCategory[ eCoinRewardType.DISCARD  ]							<- eCoinRewardCategory.MISC
level.coinCategory[ eCoinRewardType.MAX_LEVEL_CONVERSION ]				<- eCoinRewardCategory.MISC

function main()
{
	Globalize( OnOpenEOG_Coins )
	Globalize( OnCloseEOG_Coins )
	Globalize( GetCoinsEarnedLastMatch )
}

function InitMenu()
{
	Assert( menu != null )

	// Buttons & Background
	SetupEOGMenuCommon( menu )

	// Pilot image
	pilotImage = GetElem( menu, "PilotImage" )
	if ( IsConnected() && GetTeam() == TEAM_IMC )
		pilotImage.SetImage( "../ui/menu/loadouts/pilot_character_female_battle_rifle_imc" )
	else
		pilotImage.SetImage( "../ui/menu/loadouts/pilot_character_female_battle_rifle_militia" )

	// Coins earned elems
	for( local i = 0 ; i < NUM_COINS_BREAKDOWN_LINES ; i++ )
	{
		local button = GetElem( menu, "BtnCoinsEarned" + i )
		coinsEarnedBreakdownButtons.append( button )
		if ( !buttonEventsRegistered )
		{
			button.AddEventHandler( UIE_GET_FOCUS, Bind(BreakdownButton_Get_Focus) )
			button.AddEventHandler( UIE_LOSE_FOCUS, Bind(BreakdownButton_Lose_Focus) )
		}
	}
	buttonEventsRegistered = true

	coinsEarnedTotalDesc 	= GetElem( menu, "CoinsEarned_TotalDesc" )
	coinsEarnedTotal		= GetElem( menu, "CoinsEarned_TotalValue" )

	// Coins Earned Category Breakdown elems
	for( local i = 0 ; i < NUM_COINS_SUBCAT_LINES ; i++ )
	{
		local label = GetElem( menu, "SubCatDesc" + i )
		label.Hide()
		subCatNameLabels.append( label )

		label = GetElem( menu, "SubCatValue" + i )
		label.Hide()
		subCatValueLabels.append( label )
	}
}

function OnOpenEOG_Coins()
{
	menu = GetMenu( "EOG_Coins" )
	level.currentEOGMenu = menu
	Signal( menu, "StopMenuAnimation" )
	EndSignal( menu, "StopMenuAnimation" )
	Signal( level, "CancelEOGThreadedNavigation" )

	if ( !IsFullyConnected() && uiGlobal.activeMenu == menu )
	{
		printt( "Not connected, cant show EOG screen" )
		thread CloseTopMenu()
		return
	}

	// Set initial coins for this screen to not include the coins earned in the last match so we can count up
	InitCoinLabel()

	GetCoinsEarned()

	InitMenu()
	ResetMenu()

	thread OpenMenuAnimated()

	EOGOpenGlobal()

	wait 0
	if ( !buttonsRegistered )
	{
		RegisterButtonPressedCallback( BUTTON_A, OpenMenuStatic )
		RegisterButtonPressedCallback( KEY_SPACE, OpenMenuStatic )
		buttonsRegistered = true
	}

	if ( !level.doEOGAnimsCoins )
		OpenMenuStatic(false)
}

function InitCoinLabel()
{
	if ( !IsFullyConnected() )
		return

	local coinCount = GetPersistentVar( "bm.coinCount" )
	local coinsEarnedLastMatch = GetCoinsEarnedLastMatch()

	previousCoinCount = coinCount - coinsEarnedLastMatch
}

function GetCoinsEarnedLastMatch()
{
	local coinsEarnedLastMatch = 0

	for( local i = 0 ; i < eCoinRewardType._NUM_TYPES ; i++ )
	{
		local rewardedCoins = GetPersistentVar( "bm.coin_rewards[" + i + "]")
		if ( rewardedCoins > 0 )
			coinsEarnedLastMatch += rewardedCoins
	}

	return coinsEarnedLastMatch
}


function OnCloseEOG_Coins()
{
	thread EOGCloseGlobal()

	if ( buttonsRegistered )
	{
		DeregisterButtonPressedCallback( BUTTON_A, OpenMenuStatic )
		DeregisterButtonPressedCallback( KEY_SPACE, OpenMenuStatic )
		buttonsRegistered = false
	}

	level.doEOGAnimsCoins = false
	menuAnimDone = false
	level.eog_coins_done = true
	Signal( menu, "StopMenuAnimation" )
}

function OpenMenuAnimated()
{
	EndSignal( menu, "StopMenuAnimation" )

	if ( level.doEOGAnimsCoins )
		EmitUISound( "Menu_GameSummary_ScreenSlideIn" )
	else
		EmitUISound( "EOGSummary.XPBreakdownPopup" )

	// Slide in pilot image
	thread FancyLabelFadeIn( menu, pilotImage, 300, 0, false )

	// Show coins Earned breakdown and bar fill
	waitthread ShowCoinsEarned()

	if ( level.doEOGAnimsCoins && uiGlobal.EOGAutoAdvance )
		thread EOGNavigateRight( null, true )
}

function OpenMenuStatic( userInitiated = true )
{
	if ( menuAnimDone && userInitiated )
		thread EOGNavigateRight( null )
	else
		Signal( menu, "StopMenuAnimation" )
}

function ResetMenu()
{
	foreach( button in coinsEarnedBreakdownButtons )
	{
		button.SetEnabled( false )
		button.Hide()
	}

	coinsEarnedTotalDesc.Hide()
	coinsEarnedTotal.Hide()
}

function GetCoinsEarned()
{
	// Update coin vars, they may have changed
	previousCoinCount = GetPersistentVar( "bm.previousCoinCount" )
	local coinCount = GetPersistentVar( "bm.coinCount" )

	newCoinCount = null
	if ( level.EOG_DEBUG )
		newCoinCount = RandomInt( 5000, 15000 )

	// Get how many coins we earned for each type last round
	for( local i = 0 ; i < eCoinRewardCategory._NUM_CATEGORIES ; i++ )
		matchCoinsByCategory[i] <- 0

	coinsEarnedTotalVal = 0
	for( local i = 0 ; i < eCoinRewardType._NUM_TYPES ; i++ )
	{
		level.matchCoinsByType[ i ] <- GetPersistentVar( "bm.coin_rewards[" + i + "]" )
		level.matchCoinsCountByType[ i ] <- GetPersistentVar( "bm.coin_reward_counts[" + i + "]")
		if ( level.EOG_DEBUG )
		{
			level.matchCoinsByType[ i ] = RandomInt( 50, 1500 )
			level.matchCoinsCountByType[ i ] = RandomInt( 1, 20 )
		}
		coinsEarnedTotalVal += level.matchCoinsByType[ i ]

		local category = level.coinCategory[ i ]
		matchCoinsByCategory[ category ] += level.matchCoinsByType[ i ]
	}

	if ( !level.EOG_DEBUG )
		newCoinCount = coinsEarnedTotalVal
	Assert( newCoinCount != null )

	if ( !level.EOG_DEBUG )
		Assert( coinsEarnedTotalVal == newCoinCount, "Unaccounted for coins earned. Coins given without a reason" )
}

function ShowCoinsEarned()
{
	EndSignal( menu, "StopMenuAnimation" )

	OnThreadEnd(
		function() : ()
		{
			menuAnimDone = true
		}
	)

	if ( !IsFullyConnected() )
		return

	if ( newCoinCount > 0 )
	{
		waitthread ShowCoinsEarnedBreakdown()
	}
	wait 1.0
}

function ShowCoinsEarnedBreakdown()
{
	EndSignal( menu, "StopMenuAnimation" )

	//########################################################
	// DISPLAY BREAKDOWNS
	//########################################################
	local numLineItemsUsed = 0
	local breakdownDelay = 1.0

	foreach( coinCategory, coinSumVal in matchCoinsByCategory )
	{
		local button = coinsEarnedBreakdownButtons[numLineItemsUsed]
		local categoryText = coinCategoryDescriptions[ coinCategory ]
		UpdateCoinEarnedBreakdownButton( button, coinCategory, categoryText, coinSumVal, breakdownDelay )

		numLineItemsUsed++
		breakdownDelay += 0.25

		if ( numLineItemsUsed >= coinsEarnedBreakdownButtons.len() )
			break
	}

	//########################################################
	// DISPLAY TOTAL VALUE
	//########################################################
	thread SetTextCountUp( menu, coinsEarnedTotal, coinsEarnedTotalVal, "EOGSummary.XPTotalNumberTick", breakdownDelay + 0.2, null, 0.5, "#EOG_COIN_VALUE" )
	thread FancyLabelFadeIn( menu, coinsEarnedTotalDesc, 300, 0, false, 0.15, false, breakdownDelay )
	thread FancyLabelFadeIn( menu, coinsEarnedTotal, 300, 0, true, 0.15, false, breakdownDelay )
	thread FlashElement( menu, coinsEarnedTotal, 4, 1.5, 255, breakdownDelay + 0.5 )

	wait breakdownDelay
	if ( level.doEOGAnimsCoins )
		EmitUISound( "EOGSummary.XPTotalPopup" )

	wait 1.0
}

function UpdateCoinEarnedBreakdownButton( button, coinCategory, categoryText, valueTotal, delay, isGenBonus = false )
{
	local descElems = []
	descElems.append( button.GetChild( "DescNormal" ) )
	descElems.append( button.GetChild( "DescFocused" ) )
	descElems.append( button.GetChild( "DescSelected" ) )
	descElems.append( button.GetChild( "DescDisabled" ) )

	local valueElems = []
	valueElems.append( button.GetChild( "ValueNormal" ) )
	valueElems.append( button.GetChild( "ValueFocused" ) )
	valueElems.append( button.GetChild( "ValueSelected" ) )
	valueElems.append( button.GetChild( "ValueDisabled" ) )

	if ( level.doEOGAnimsCoins )
		EmitUISound( "Menu_GameSummary_XPBonusesSlideIn" )

	foreach( elem in descElems )
	{
		Assert( elem != null )
		if ( isGenBonus )
			elem.SetText( categoryText, ( GetGen() + 1 ) )
		else
			elem.SetText( categoryText )
	}

	foreach( elem in valueElems )
	{
		Assert( elem != null )
		thread SetTextCountUp( menu, elem, valueTotal, "Menu_GameSummary_XPBar", delay + 0.2, null, 0.5, "#EOG_COIN_VALUE" )
	}

	descElems[ descElems.len() - 1 ].SetColor( 100, 100, 100, 255 )
	valueElems[ valueElems.len() - 1 ].SetColor( 100, 100, 100, 255 )

	if ( !( "coinCategory" in button.s ) )
		button.s.coinCategory <- null
	button.s.coinCategory = coinCategory

	button.SetEnabled( valueTotal > 0 )
	button.SetLocked( false )

	thread FancyLabelFadeIn( menu, button, 300, 0, true, 0.15, false, delay, "Menu_GameSummary_XPBonusesSlideIn" )
}

function BreakdownButton_Get_Focus( button )
{
	Assert( "coinCategory" in button.s )

	local menu = GetMenu( "EOG_Coins" )

	local pilotImage = GetElem( menu, "PilotImage" )
	//pilotImage.SetAlpha( 100 )
	pilotImage.FadeOverTime( 100, 0.15 )

	// Find all xp types in this category
	local typesToDisplay = []
	for( local i = 0 ; i < eCoinRewardType._NUM_TYPES ; i++ )
	{
		if ( level.coinCategory[ i ] == button.s.coinCategory )
			typesToDisplay.append( i )
	}

	local elemIndex = 0
	foreach( subCat in typesToDisplay )
	{
		local xpCountForType = level.matchCoinsCountByType[ subCat ]
		if ( xpCountForType <= 0 )
			continue

		local label = GetElem( menu, "SubCatDesc" + elemIndex )
		label.SetText( "#EOG_COIN_CATEGORY_NAME_AND_COUNT", level.coinTypeDescriptions[ subCat ], xpCountForType.tostring() )
		label.FadeOverTime( 255, 0.15 )
		label.Show()

		label = GetElem( menu, "SubCatValue" + elemIndex )
		label.SetText( "#EOG_COIN_VALUE", level.matchCoinsByType[ subCat ].tostring() )
		label.FadeOverTime( 255, 0.15 )
		label.Show()

		elemIndex++
	}

	for( local i = typesToDisplay.len() ; i < NUM_COINS_SUBCAT_LINES ; i++ )
	{
		GetElem( menu, "SubCatDesc" + i ).Hide()
		GetElem( menu, "SubCatValue" + i ).Hide()
	}
}

function BreakdownButton_Lose_Focus( button )
{
	local menu = GetMenu( "EOG_Coins" )

	local pilotImage = GetElem( menu, "PilotImage" )
	//pilotImage.SetAlpha( 255 )
	pilotImage.FadeOverTime( 255, 0.15 )

	for( local i = 0 ; i < NUM_COINS_SUBCAT_LINES ; i++ )
	{
		local label = GetElem( menu, "SubCatDesc" + i )
		label.FadeOverTime( 0, 0.15 )

		label = GetElem( menu, "SubCatValue" + i )
		label.FadeOverTime( 0, 0.15 )
	}
}
