const STICK_DEFLECTION_TRIGGER = 0.35
const STICK_DEFLECTION_DEBOUNCE = 0.3

function main()
{
	level.EOG_DEBUG <- false
	level.currentEOGMenu <- null

	level.doEOGAnimsXP <- null
	level.doEOGAnimsCoins <- null
	level.doEOGAnimsMapStars <- null
	level.doEOGAnimsUnlocks <- null
	level.doEOGAnimsChallenges <- null
	level.doEOGAnimsRP <- null

	level.eog_coins_done <- false

	RegisterSignal( "ElemFlash" )
	RegisterSignal( "StopMenuAnimation" )
	RegisterSignal( "PanelAlphaOverTime" )
	RegisterSignal( "StopLoopUISound" )
	RegisterSignal( "CancelEOGThreadedNavigation" )
	RegisterSignal( "EOGGlobalOpen" )

	Globalize( GetElem )
	Globalize( FlashElement )
	Globalize( FancyLabelFadeIn )
	Globalize( FancyLabelFadeOut )
	Globalize( SetTextCountUp )
	Globalize( LoopSoundForDuration )
	Globalize( SetPanelAlphaOverTime )
	Globalize( GetEOGChallenges )
	Globalize( SetupEOGMenuCommon )
	Globalize( EOGNavigateLeft )
	Globalize( EOGNavigateRight )
	Globalize( InitEOGMenus )
	Globalize( SetImagesByClassname )
	Globalize( ShowElementsByClassname )
	Globalize( HideElementsByClassname )
	Globalize( SetElementsTextByClassname )
	Globalize( ClearEOGData )
	Globalize( EOGHasChallengesToShow )
	Globalize( EOGHasCoinsToShow )
	Globalize( EOGIsPrivateMatch )
	Globalize( UpdateBurnCardDeckStatus )
	Globalize( EOGOpenGlobal )
	Globalize( EOGCloseGlobal )
	Globalize( RankedPlayAvailable )
	Globalize( PulsateElem )
	Globalize( PlotPointsOnGraph )
}

function GetElem( menu, name )
{
	local elem = GetElementsByClassname( menu, name )
	if ( elem.len() == 0 )
	{
		elem = menu.GetChild( name )
	}
	else
	{
		Assert( elem.len() == 1, "Tried to use GetElem for 1 elem but " + elem.len().tostring() + " were found" )
		elem = elem[0]
	}
	Assert( elem != null, "Could not find elem with name " + name + " on menu " + menu )

	return elem
}

function FlashElement( menu, element, numberFlashes = 4, speedScale = 1.0, maxAlpha = 255, delay = 0.0 )
{
	EndSignal( menu, "StopMenuAnimation" )

	Assert( element != null )

	Signal( element, "ElemFlash" )
	EndSignal( element, "ElemFlash" )

	local startAlpha = element.GetAlpha()
	local flashInTime = 0.2 / speedScale.tofloat()
	local flashOutTime = 0.4 / speedScale.tofloat()

	OnThreadEnd(
		function() : ( element, startAlpha )
		{
			element.SetAlpha( startAlpha )
		}
	)

	if ( delay > 0 )
		wait delay

	while( numberFlashes >= 0 )
	{
		element.FadeOverTime( maxAlpha, flashInTime )
		wait flashInTime

		if ( numberFlashes == 0 )
			flashOutTime = 1.0	// slower fadeout on last flash

		element.FadeOverTime( 25, flashOutTime )
		numberFlashes--

		if ( numberFlashes > 0 )
			wait flashOutTime
	}

	element.FadeOverTime( startAlpha, flashInTime )
	wait flashInTime
}

function FancyLabelFadeIn( menu, label, xOffset = 0, yOffset = 300, flicker = true, duration = 0.15, isPanel = false, delay = 0.0, soundAlias = null )
{
	EndSignal( menu, "StopMenuAnimation" )

	local basePos = label.GetBasePos()

	OnThreadEnd(
		function() : ( label )
		{
			label.ReturnToBasePos()
			label.Show()
			label.ReturnToBaseColor()
		}
	)

	if ( delay > 0 )
		wait delay

	// init
	label.SetPos( basePos[0] + xOffset, basePos[1] + yOffset )
	label.SetAlpha( 0 )
	label.Show()

	if ( soundAlias != null )
		EmitUISound( soundAlias )

	local goalAlpha = label.GetBaseAlpha()
	// animate
	if ( isPanel )
		thread SetPanelAlphaOverTime( label, goalAlpha, duration )
	else
		label.FadeOverTime( goalAlpha, duration, INTERPOLATOR_ACCEL )

	label.MoveOverTime( basePos[0], basePos[1], duration )

	wait 0.2

	if ( flicker )
		thread FlashElement( menu, label, 3, 3.0 )

	if ( duration - 0.2 > 0 )
		wait duration - 0.2
}

function FancyLabelFadeOut( menu, label, xOffset = 0, yOffset = -300, duration = 0.15, isPanel = false )
{
	EndSignal( menu, "StopMenuAnimation" )

	local currentPos = label.GetPos()

	OnThreadEnd(
		function() : ( label, currentPos, xOffset, yOffset )
		{
			label.SetPos( currentPos[0] + xOffset, currentPos[1] + yOffset )
			label.Hide()
		}
	)

	// animate
	if ( isPanel )
		thread SetPanelAlphaOverTime( label, 0, duration )
	else
		label.FadeOverTime( 0, duration, INTERPOLATOR_ACCEL )

	label.MoveOverTime( currentPos[0] + xOffset, currentPos[1] + yOffset, duration )
	wait duration
}

function SetTextCountUp( menu, label, value, tickAlias = null, delay = 0.2, formatString = null, duration = 0.5, locString = null, startValue = 0 )
{
	EndSignal( menu, "StopMenuAnimation" )

	OnThreadEnd(
		function() : ( formatString, locString, label, value )
		{
			local str
			if ( formatString != null )
				str = format( formatString, value ).tostring()
			else
				str = value.tostring()

			if ( locString != null )
				label.SetText( locString, str )
			else
				label.SetText( str )
		}
	)

	local str = startValue.tostring()
	if ( formatString != null )
		str = format( formatString, startValue ).tostring()

	if ( locString != null )
		label.SetText( locString, str )
	else
		label.SetText( str )

	if ( delay > 0 )
		wait delay

	local currentTime = Time()
	local startTime = currentTime
	local endTime = Time() + duration

	if ( tickAlias != null )
		thread LoopSoundForDuration( menu, tickAlias, duration )

	while( currentTime <= endTime )
	{
		local val = GraphCapped( currentTime, startTime, endTime, startValue, value ).tointeger()
		if ( formatString != null )
			str = format( formatString, val ).tostring()
		else
			str = val.tostring()

		if ( locString != null )
			label.SetText( locString, str )
		else
			label.SetText( str )

		wait 0
		currentTime = Time()
	}
}

function LoopSoundForDuration( menu, alias, duration )
{
	local signaler = {}
	EndSignal( signaler, "StopLoopUISound" )
	EndSignal( menu, "StopMenuAnimation" )

	thread StopSoundDelayed( signaler, alias, duration )
	while(1)
	{
		local soundLength = EmitUISound( alias )
		wait soundLength
	}
}

function StopSoundDelayed( signaler, alias, delay )
{
	wait delay
	Signal( signaler, "StopLoopUISound" )
	StopUISound( alias )
}

function SetPanelAlphaOverTime( panel, alpha, duration )
{
	Signal( panel, "PanelAlphaOverTime" )
	EndSignal( panel, "PanelAlphaOverTime" )

	local startTime = Time()
	local endTime = startTime + duration
	local startAlpha = panel.GetPanelAlpha()

	while( Time() <= endTime )
	{
		local a = GraphCapped( Time(), startTime, endTime, startAlpha, alpha )
		panel.SetPanelAlpha( a )
		wait 0
	}

	panel.SetPanelAlpha( alpha )
}

function ClearEOGData()
{
	if ( !( "eog_challengesToShow" in uiGlobal ) )
		uiGlobal.eog_challengesToShow <- null
	uiGlobal.eog_challengesToShow = {}
	uiGlobal.eog_challengesToShow["most_progress"] <- []
	uiGlobal.eog_challengesToShow["complete"] <- []
	uiGlobal.eog_challengesToShow["almost_complete"] <- []
	uiGlobal.eog_challengesToShow["tracked"] <- []

	if ( !( "eog_unlocks" in uiGlobal ) )
		uiGlobal.eog_unlocks <- null
	uiGlobal.eog_unlocks = {}
	uiGlobal.eog_unlocks[ "items" ] <- []
	uiGlobal.eog_unlocks[ "nonItems" ] <- []
}

function GetEOGChallenges( maxNum = -1 )
{
	// Update challenge progress table from persistence
	uiGlobal.EOGChallengeFilter = null
	UI_GetAllChallengesProgress()

	local allChallenges = GetLocalChallengeTable()

	if ( !( "eog_challengesToShow" in uiGlobal ) )
		uiGlobal.eog_challengesToShow <- null
	uiGlobal.eog_challengesToShow = {}
	uiGlobal.eog_challengesToShow[ "most_progress" ] <- []
	uiGlobal.eog_challengesToShow[ "complete" ] <- []
	uiGlobal.eog_challengesToShow[ "almost_complete" ] <- []
	uiGlobal.eog_challengesToShow[ "tracked" ] <- []

	foreach( challengeRef, val in allChallenges )
	{
		local startProgress = GetMatchStartChallengeProgress( challengeRef )
		local finalProgress = GetCurrentChallengeProgress( challengeRef )
		local startTier = GetChallengeTierForProgress( challengeRef, startProgress )
		local finalTier = GetChallengeTierForProgress( challengeRef, finalProgress )
		local startGoal = GetGoalForChallengeTier( challengeRef, startTier )
		local finalGoal = GetGoalForChallengeTier( challengeRef, finalTier )
		local startFrac = clamp( startProgress / startGoal, 0.0, 1.0 ).tofloat()
		local finalFrac = clamp( finalProgress / finalGoal, 0.0, 1.0 ).tofloat()
		local category 	= GetChallengeCategory( challengeRef )

		local data = {}
		data.ref <- challengeRef
		data.startProgress <- startProgress
		data.finalProgress <- finalProgress
		data.increase <- data.finalProgress - data.startProgress
		data.startTier <- startTier
		data.finalTier <- finalTier
		data.startGoal <- startGoal
		data.finalGoal <- finalGoal
		data.startFrac <- startFrac
		data.finalFrac <- finalFrac

		// Array of tiers completed
		data.tiersCompleted <- []
		for ( local i = startTier ; i < finalTier ; i++ )
			data.tiersCompleted.append( i )
		if ( IsChallengeTierComplete( challengeRef, finalTier ) )
			data.tiersCompleted.append( finalTier )

		// Challenge made progress this match
		if ( finalProgress > startProgress )
		{
			uiGlobal.eog_challengesToShow[ "most_progress" ].append( data )

			// Challenge tier was completed this match
			if ( data.tiersCompleted.len() > 0 )
				uiGlobal.eog_challengesToShow[ "complete" ].append( data )
		}

		// If challenge is not complete we add it to this list
		if ( data.finalProgress < data.finalGoal )
		{
			local weaponRef = level.challengeData[ data.ref ].weaponRef
			local challengeAvailable = true
			if ( weaponRef != null && ItemDefined( weaponRef ) && IsItemLocked( weaponRef ) )
				challengeAvailable = false
			if ( challengeAvailable && data.startFrac > 0.0 )
				uiGlobal.eog_challengesToShow[ "almost_complete" ].append( data )
		}

		local EOGTrackedChallenges = []
		for ( local i = 0; i < MAX_TRACKED_CHALLENGES; i++ )
		{
			EOGTrackedChallenges.append( GetPersistentVar( "EOGTrackedChallengeRefs[" + i + "]" ) )
		}

		foreach ( cRef in EOGTrackedChallenges )
		{
			if ( cRef == data.ref )
				uiGlobal.eog_challengesToShow[ "tracked" ].append( data )
		}
	}

	// Sort the list so the EOG screen will show the top ones. We still return the rest because it's used to see what items became unlocked
	uiGlobal.eog_challengesToShow[ "most_progress" ].sort( ChallengeSort_MostComplete )
	uiGlobal.eog_challengesToShow[ "complete" ].sort( ChallengeSort_MostComplete )
	uiGlobal.eog_challengesToShow[ "almost_complete" ].sort( ChallengeSort_AlmostComplete )

	//printt( "challenges progressed last match:", uiGlobal.eog_challengesToShow[ "most_progress" ].len() )
	//printt( "challenges completed last match:", uiGlobal.eog_challengesToShow[ "complete" ].len() )
	//printt( "challenges not complete:", uiGlobal.eog_challengesToShow[ "almost_complete" ].len() )
}

function ChallengeSort_Completion( a, b )
{
	if ( a.tiersCompleted.len() > 0 && b.tiersCompleted.len() == 0 )
		return -1
	else if ( a.tiersCompleted.len() == 0 && b.tiersCompleted.len() > 0 )
		return 1
	return 0
}
Globalize( ChallengeSort_Completion )

function ChallengeSort_MostBarFill( a, b )
{
	local frac_increase_a = fabs( a.finalFrac - a.startFrac )
	local frac_increase_b = fabs( b.finalFrac - b.startFrac )
	if ( frac_increase_a > frac_increase_b )
		return -1
	else if ( frac_increase_b > frac_increase_a )
		return 1
	return 0
}
Globalize( ChallengeSort_MostBarFill )

function ChallengeSort_MostProgressIncrease( a, b )
{
	if ( a.increase > b.increase )
		return -1
	else if ( a.increase < b.increase )
		return 1
	return 0
}
Globalize( ChallengeSort_MostProgressIncrease )

function ChallengeSort_HighestFraction( a, b )
{
	if ( a.finalFrac > b.finalFrac )
		return -1
	else if ( a.finalFrac < b.finalFrac )
		return 1
	return 0
}
Globalize( ChallengeSort_HighestFraction )

function ChallengeSort_MostComplete( a, b )
{
	local result

	// Priority 1 - Completed challenges rank highest
	result = ChallengeSort_Completion( a, b )
	if ( result != 0 )
		return result

	// Priority 2 - Highest fraction bar fill
	result = ChallengeSort_HighestFraction( a, b )
	if ( result != 0 )
		return result

	// Priority 3 - Most bar fill
	result = ChallengeSort_MostBarFill( a, b )
	if ( result != 0 )
		return result

	// Priority 4 - Most Progress
	result = ChallengeSort_MostProgressIncrease( a, b )
	if ( result != 0 )
		return result

	return 0
}

function ChallengeSort_AlmostComplete( a, b )
{
	local result

	// Priority 2 - Highest fraction bar fill
	result = ChallengeSort_HighestFraction( a, b )
	if ( result != 0 )
		return result

	// Priority 4 - Most Progress
	result = ChallengeSort_MostProgressIncrease( a, b )
	if ( result != 0 )
		return result

	return 0
}

function EOGHasCoinsToShow()
{
	local rewards = []
	local rewardCounts = []

	for( local i = 0 ; i < eCoinRewardType._NUM_TYPES ; i++ )
	{
		local reward = GetPersistentVar( "bm.coin_rewards[" + i + "]" )
		local rewardCount = GetPersistentVar( "bm.coin_reward_counts[" + i + "]")


		rewards.append(reward)
		rewardCounts.append(rewardCount)

		if ( ( reward > 0 ) && ( rewardCount > 0 ) )
			return true
	}

	return false
}

function EOGIsPrivateMatch()
{
	return GetPersistentVar( "savedScoreboardData.privateMatch" ) && !IsDelta()
}

function EOGHasChallengesToShow()
{
	if ( IsItemLocked( "challenges" ) )
		return false

	if ( EOGIsPrivateMatch() )
		return false

	return ( uiGlobal.eog_challengesToShow["most_progress"].len() > 0 || uiGlobal.eog_challengesToShow["complete"].len() > 0 || uiGlobal.eog_challengesToShow["almost_complete"].len() > 0 || uiGlobal.eog_challengesToShow["tracked"].len() > 0 )
}

function SetupEOGMenuCommon( menu )
{
	//#################################################################
	// Get EOG Common Navigation Elements
	//#################################################################

	local pages = GetEOGPages()
	local selectedIndex
	foreach ( index, page in pages )
	{
		if ( menu == page )
		{
			selectedIndex = index
			break
		}
	}
	Assert( selectedIndex != null )

	local menuTitles = GetEOGMenuTitles()

	local eogCommonPanel = GetElem( menu, "eog_common_panel" )

	local pageTitleLabel = eogCommonPanel.GetChild( "EOGPageTitle" )

	local prevPageButton = eogCommonPanel.GetChild( "BtnPrevPage" )
	local prevPageTitleHint = eogCommonPanel.GetChild( "EOGPrevPageGamepadHint" )
	prevPageTitleHint.EnableKeyBindingIcons()
	local prevPageTitleLabel = eogCommonPanel.GetChild( "EOGPrevPageTitle" )

	local nextPageButton = eogCommonPanel.GetChild( "BtnNextPage" )
	local nextPageTitleHint = eogCommonPanel.GetChild( "EOGNextPageGamepadHint" )
	nextPageTitleHint.EnableKeyBindingIcons()
	local nextPageTitleLabel = eogCommonPanel.GetChild( "EOGNextPageTitle" )

	// Update menu title
	pageTitleLabel.SetText( menuTitles[ menu ] )

	// Update prev/next menu titles
	local prevMenu = EOGGetNavigationMenuLeft()
	if ( prevMenu != null )
		prevPageTitleLabel.SetText( menuTitles[ prevMenu ] )
	else
		prevPageTitleLabel.SetText( "" )

	local nextMenu = EOGGetNavigationMenuRight()
	if ( nextMenu != null )
		nextPageTitleLabel.SetText( menuTitles[ nextMenu ] )
	else
		nextPageTitleLabel.SetText( "" )

	//#################################################################
	// Set up the navigation buttons
	//#################################################################

	if ( !( "addedEventHandler" in prevPageButton.s ) )
	{
		prevPageButton.AddEventHandler( UIE_CLICK, Bind( EOGNavigateLeft ) )
		prevPageButton.s.addedEventHandler <- true
	}

	if ( !( "addedEventHandler" in nextPageButton.s ) )
	{
		nextPageButton.AddEventHandler( UIE_CLICK, Bind( EOGNavigateRight ) )
		nextPageButton.s.addedEventHandler <- true
	}

	local enabledButtons = []
	local buttonWidth = null
	for ( local i = 0 ; i < pages.len(); i++ )
	{
		local button = GetElem( menu, "BtnEOGPage" + i )
		Assert( button != null )
		local selected = i == selectedIndex ? true : false
		button.SetSelected( selected )
		if ( IsControllerModeActive() )
		{
			local dummyButton = GetElementsByClassname( menu, "DummyFocusButton" )
			if ( dummyButton.len() > 0 )
				dummyButton[0].SetFocused()
		}
		button.Show()

		local page = pages[i]

		if ( IsLobby() )
			UpdateEOGButton( button, page )

		// Enable buttons if we have something to show
		local enabled = EOGPageEnabled( page )
		button.SetEnabled( enabled )

		if ( button.IsEnabled() )
		{
			enabledButtons.append( button )
			buttonWidth = button.GetBaseWidth()
			button.SetWidth( buttonWidth )
		}
		else
		{
			button.SetWidth( 0 )
		}
	}

	local buttonOffset = enabledButtons[0].GetBaseWidth() * enabledButtons.len() / 2.0
	local buttonPos = enabledButtons[0].GetBasePos()
	enabledButtons[0].SetPos( buttonPos[0] - buttonOffset, buttonPos[1] )

	//#################################################################
	// Update Top Navigation Elements
	// ( tital, next/prev text, and position navigation buttons )
	//#################################################################

	if ( buttonWidth != null && enabledButtons.len() > 0 )
	{
		// position pc buttons
		prevPageButton.SetEnabled( prevMenu != null )
		prevPageButton.Show()

		nextPageButton.SetEnabled( nextMenu != null )
		nextPageButton.Show()

		// position hint label for gamepad
		if ( prevMenu != null )
		{
			prevPageTitleHint.Show()
			prevPageTitleLabel.Show()
		}
		else
		{
			prevPageTitleHint.Hide()
			prevPageTitleLabel.Hide()
		}

		if ( nextMenu != null )
		{
			nextPageTitleHint.Show()
			nextPageTitleLabel.Show()
		}
		else
		{
			nextPageTitleHint.Hide()
			nextPageTitleLabel.Hide()
		}
	}
	else
	{
		// reset buttons
		prevPageButton.SetEnabled( false )
		prevPageTitleHint.Hide()
		nextPageButton.SetEnabled( false )
		nextPageTitleHint.Hide()
		prevPageTitleLabel.Hide()
		nextPageTitleLabel.Hide()
	}
}

function UpdateEOGButton( button, page )
{
	local handler = EOGReplaceMenuEventHandler( page )
	if ( !( "addedEventHandler" in button.s ) )
	{
		button.AddEventHandler( UIE_CLICK, handler )
		button.s.addedEventHandler <- true
		button.s.eventHandler <- handler
	}
	else
	{
		button.RemoveEventHandler( UIE_CLICK, button.s.eventHandler )
		button.AddEventHandler( UIE_CLICK, handler )
		button.s.eventHandler = handler
	}
}

function EOGCoopHasData()
{
	if ( GetPersistentVar( "savedCoopData.totalWaves" ) == 0 )
		return false
	return true
}

function EOGScoreboardHasData()
{
	if ( GetPersistentVar( "savedScoreboardData.playerTeam" ) != TEAM_IMC && GetPersistentVar( "savedScoreboardData.playerTeam" ) != TEAM_MILITIA )
		return false
	if ( GetPersistentVar( "savedScoreboardData.map" ) < 0 )
		return false
	return ( GetPersistentVar( "savedScoreboardData.numPlayersIMC" ) > 0 || GetPersistentVar( "savedScoreboardData.numPlayersMCOR" ) > 0 )
}

function EOGRankedHasData()
{
	if ( GetPersistentVar( "savedScoreboardData.ranked" ) == false || (GetPersistentVar( "savedScoreboardData.playerTeam" ) != TEAM_IMC && GetPersistentVar( "savedScoreboardData.playerTeam" ) != TEAM_MILITIA ))
		return false
	return ( GetPersistentVar( "savedScoreboardData.numPlayersIMC" ) > 0 || GetPersistentVar( "savedScoreboardData.numPlayersMCOR" ) > 0 )
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//
//	These functions must have each available EOG menu included
//
////////////////////////////////////////////////////////////////////////////////////////////////////

function EOGPageEnabled( menu )
{
	local lastModeName = PersistenceGetEnumItemNameForIndex( "gameModes", GetPersistentVar( "savedScoreboardData.gameMode" ) )
	switch ( menu )
	{
		case GetMenu( "EOG_XP" ):
			return true
		case GetMenu( "EOG_Ranked" ):
			return EOGRankedHasData() && !EOGIsPrivateMatch()
		case GetMenu( "EOG_Coins" ):
			return ( IsBlackMarketUnlocked() && EOGHasCoinsToShow() && !EOGIsPrivateMatch() )
		case GetMenu( "EOG_MapStars" ):
			return ShouldShowEOGMapStars()
		case GetMenu( "EOG_Unlocks" ):
			return ( uiGlobal.eog_unlocks.items.len() + uiGlobal.eog_unlocks.nonItems.len() > 0 ) && !EOGIsPrivateMatch() && !GetConVarBool("everything_unlocked")
		case GetMenu( "EOG_Challenges" ):
			return EOGHasChallengesToShow() && !EOGIsPrivateMatch()
		case GetMenu( "EOG_Scoreboard" ):
			printt( "EOG SCOREBOARD PAGE ENABLED" )
			return EOGScoreboardHasData() && lastModeName != COOPERATIVE
		case GetMenu( "EOG_Coop" ):
			printt( "EOG_COOP PAGE ENABLED")
			return EOGCoopHasData() && lastModeName == COOPERATIVE
	}
	Assert( 0, "Unhandled EOG page" )
}

function GetEOGMenuTitles()
{
	local menuTitles = {}
	menuTitles[ GetMenu( "EOG_XP" ) ] <- EOGIsPrivateMatch() ? "#EOG_BUTTON_TITLE_0_PRIVATE_MATCH" : "#EOG_BUTTON_TITLE_0"
	menuTitles[ GetMenu( "EOG_Ranked" ) ] <- "#EOG_RANKED_TITLE"
	menuTitles[ GetMenu( "EOG_Coins" ) ] <- "#EOG_BUTTON_TITLE_COINS"
	menuTitles[ GetMenu( "EOG_MapStars" ) ] <- "#EOG_BUTTON_TITLE_MAP_STARS"
	menuTitles[ GetMenu( "EOG_Unlocks" ) ] <- "#EOG_BUTTON_TITLE_1"
	menuTitles[ GetMenu( "EOG_Challenges" ) ] <- "#EOG_BUTTON_TITLE_2"
	menuTitles[ GetMenu( "EOG_Scoreboard" ) ] <- "#SCOREBOARD"
	menuTitles[ GetMenu( "EOG_Coop" ) ] <- "#EOG_COOP_TITLE"
	return menuTitles
}

function GetEOGPages()
{
	local pages = []
	pages.append( GetMenu( "EOG_XP" ) )
	pages.append( GetMenu( "EOG_Ranked" ) )
	pages.append( GetMenu( "EOG_Coins" ) )
	pages.append( GetMenu( "EOG_MapStars" ) )
	pages.append( GetMenu( "EOG_Unlocks" ) )
	pages.append( GetMenu( "EOG_Challenges" ) )
	local lastGameMode = PersistenceGetEnumItemNameForIndex( "gameModes", GetPersistentVar( "savedScoreboardData.gameMode" ) )
	if ( COOPERATIVE == lastGameMode )
	{
		pages.append( GetMenu( "EOG_Coop" ) )
		printt( " EOG PAGES COOP")
	}
	else
	{
		pages.append( GetMenu( "EOG_Scoreboard" ) )
		printt( " EOG PAGES SCOREBOARD")
	}
	return pages
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//
//
//
////////////////////////////////////////////////////////////////////////////////////////////////////


function EOGGetNavigationMenuLeft()
{
	if ( level.currentEOGMenu == null || !IsLobby() )
		return null

	return EOG_IncrementNavigation( -1 )
}

function EOGGetNavigationMenuRight()
{
	if ( level.currentEOGMenu == null || !IsLobby() )
		return null

	return EOG_IncrementNavigation( 1 )
}

function EOG_IncrementNavigation( val )
{
	local pages = GetEOGPages()
	for ( local i = 0; i < pages.len(); i++ )
	{
		local page = pages[i]
		if ( level.currentEOGMenu != page )
			continue

		local offset = 0
		for ( ;; )
		{
			offset += val
			local nextPageIndex = i + offset
			if ( nextPageIndex < 0 )
				nextPageIndex += pages.len()
			nextPageIndex %= pages.len()

			local nextPage = pages[ nextPageIndex ]
			if ( nextPage == page )
				return null

			printt( "nextPageIndex =", nextPageIndex )

			// found an open page?
			if ( EOGPageEnabled( nextPage ) )
				return nextPage
		}

		Assert( 0 )
	}

	return null
}

function EOGNavigateLeft(...)
{
	if ( level.currentEOGMenu != uiGlobal.activeMenu )
		return

	if ( level.currentEOGMenu == null || !IsLobby() )
		return

	uiGlobal.EOGAutoAdvance = false

	local prevMenu = EOGGetNavigationMenuLeft()
	if ( prevMenu != null )
		AdvanceMenu( prevMenu, true )
}

function EOGNavigateRight( button, autoAdvance = false )
{
	if ( level.currentEOGMenu != uiGlobal.activeMenu )
		return

	if ( level.currentEOGMenu == null || !IsLobby() )
		return

	if ( !autoAdvance )
		uiGlobal.EOGAutoAdvance = false

	local nextMenu = EOGGetNavigationMenuRight()
	if ( nextMenu != null )
		AdvanceMenu( nextMenu, true )
}

function InitEOGMenus()
{
	level.doEOGAnimsXP = true
	level.doEOGAnimsCoins = true
	level.doEOGAnimsMapStars = true
	level.doEOGAnimsUnlocks = true
	level.doEOGAnimsChallenges = true
	level.doEOGAnimsRP = true
}

function EOGOpenGlobal()
{
	Assert( level.currentEOGMenu != null )
	Signal( level, "EOGGlobalOpen" )
	if ( uiGlobal.eogNavigationButtonsRegistered == false )
	{
		RegisterButtonPressedCallback( BUTTON_SHOULDER_LEFT, EOGNavigateLeft )
		RegisterButtonPressedCallback( BUTTON_SHOULDER_RIGHT, EOGNavigateRight )
		uiGlobal.eogNavigationButtonsRegistered = true
	}
	if ( ShouldDisplayQuickMatchButton() && uiGlobal.eogCoopQuickMatchButtonRegistered == false )
	{
		RegisterButtonPressedCallback( BUTTON_START, AdvanceToQuickMatchMenu )
		uiGlobal.eogCoopQuickMatchButtonRegistered = true
	}
}

function EOGCloseGlobal()
{
	level.currentEOGMenu == null
	EndSignal( level, "EOGGlobalOpen" )
	wait 0.1
	if ( uiGlobal.eogNavigationButtonsRegistered == true )
	{
		DeregisterButtonPressedCallback( BUTTON_SHOULDER_LEFT, EOGNavigateLeft )
		DeregisterButtonPressedCallback( BUTTON_SHOULDER_RIGHT, EOGNavigateRight )
		uiGlobal.eogNavigationButtonsRegistered = false
	}
	if ( uiGlobal.eogCoopQuickMatchButtonRegistered == true )
	{
		DeregisterButtonPressedCallback( BUTTON_START, AdvanceToQuickMatchMenu )
		uiGlobal.eogCoopQuickMatchButtonRegistered = false
	}
}

function SetImagesByClassname( menu, className, filename )
{
	local images = GetElementsByClassname( menu, className )
	foreach ( img in images )
		img.SetImage( filename )
}

function ShowElementsByClassname( menu, className )
{
	local elements = GetElementsByClassname( menu, className )
	foreach ( elem in elements )
		elem.Show()
}

function HideElementsByClassname( menu, className )
{
	local elements = GetElementsByClassname( menu, className )
	foreach ( elem in elements )
		elem.Hide()
}

function SetElementsTextByClassname( menu, className, text )
{
	local elements = GetElementsByClassname( menu, className )
	foreach ( element in elements )
		element.SetText( text )
}

function UpdateBurnCardDeckStatus( textLabel, time = 2.0 )
{
	local accel = INTERPOLATOR_DEACCEL
	local count = GetTotalBurnCards()
	local max = GetMaxStoredBurnCards()
	textLabel.SetText( "#EOG_CHALLENGE_PROGRESS", count, max )

	if ( count > max )
	{
		textLabel.SetColor( 255, 45, 0, 255 )
		return
	}

	textLabel.ClearPulsate()

	if ( count != textLabel.s.lastBurnCardStashCount )
	{
		textLabel.SetColor( 255, 255, 45, 255 )
		textLabel.s.lastBurnCardStashCount = count
	}

	textLabel.ColorOverTime( 204, 234, 255, 255, time, accel )
}

function RankedPlayAvailable()
{
	if ( IsPrivateMatch() && !IsDelta() )
		return false

	return PlaylistSupportsRankedPlay() && GameModeSupportsRankedPlay()
}

function PulsateElem( menu, element, startAlpha = 255, endAlpha = 50, rate = 1.0 )
{
	EndSignal( menu, "StopMenuAnimation" )

	Assert( element != null )

	Signal( element, "ElemFlash" )
	EndSignal( element, "ElemFlash" )

	local duration = rate * 0.5
	element.SetAlpha( startAlpha )
	while(1)
	{
		element.FadeOverTime( endAlpha, duration, INTERPOLATOR_ACCEL )
		wait duration
		element.FadeOverTime( startAlpha, duration, INTERPOLATOR_ACCEL )
		wait duration
	}
}

function PlotPointsOnGraph( menu, maxPoints, dotNames, lineNames, values, graphBounds = null )
{
	local pointCount = min( maxPoints, values.len() )
	Assert( pointCount >= 2 )

	//printt( "Plotting graph with", pointCount, "points:" )
	//PrintTable( values )

	// Get the dot elems
	local dots = []
	local lines = []
	for ( local i = 0 ; i < maxPoints ; i++ )
	{
		dots.append( GetElem( menu, dotNames + i ) )
		lines.append( GetElem( menu, lineNames + i ) )
	}

	// Calculate bounds
	// Assumes dot 0 is at bottom left, and dot 1 is at top right. If not, your bounds of the graph will be wrong
	local graphWidth = dots[1].GetBasePos()[0] - dots[0].GetBasePos()[0]
	local graphHeight = dots[0].GetBasePos()[1] - dots[1].GetBasePos()[1]
	local graphOrigin = dots[0].GetBasePos()
	graphOrigin[0] += dots[0].GetBaseWidth() * 0.5
	graphOrigin[1] += dots[0].GetBaseHeight() * 0.5
	local dotSpacing = graphWidth / ( pointCount - 1 ).tofloat()

	//printt( "graphWidth:", graphWidth )
	//printt( "dotSpacing:", dotSpacing )

	// Calculate min/max for the graph
	/*
	if ( graphBounds == null )
	{
		graphBounds = []
		graphBounds.append( 0.0 )
		graphBounds.append( max( dottedAverage, 1.0 ) )
		foreach( value in values )
		{
			if ( value > graphBounds[1] )
				graphBounds[1] = value
		}
		graphBounds[1] += graphBounds[1] * 0.1
	}
	*/

	/*
	local maxLabel = GetElem( menu, "Graph" + graphIndex + "ValueMax" )
	local maxValueString = format( "%.1f", graphMax )
	maxLabel.SetText( maxValueString )
	*/

	// Plot the dots
	local dotPositions = []
	for ( local i = 0 ; i < maxPoints ; i++ )
	{
		local dot = dots[i]
		if ( i >= pointCount )
		{
			dot.Hide()
			continue
		}

		local dotOffset = GraphCapped( values[i], graphBounds[0], graphBounds[1], 0, graphHeight )

		local posX = graphOrigin[0] - ( dot.GetBaseWidth() * 0.5 ) + ( dotSpacing * i )
		local posY = graphOrigin[1] - ( dot.GetBaseHeight() * 0.5 ) - dotOffset
		dot.SetPos( posX, posY )
		dot.Show()

		dotPositions.append( [ posX + ( dot.GetBaseWidth() * 0.5 ), posY + ( dot.GetBaseHeight() * 0.5 ) ] )
	}

	/*
	// Place the dotted lifetime average line
	local dottedLine = GetElem( menu, "KDRatioLast10Graph" + graphIndex + "DottedLine0" )
	local dottedLineOffset = GraphCapped( dottedAverage, graphMin, graphMax, 0, graphHeight )
	local posX = graphOrigin[0]
	local posY = graphOrigin[1] - ( dottedLine.GetBaseHeight() * 0.5 ) - dottedLineOffset
	dottedLine.SetPos( posX, posY )
	dottedLine.Show()

	// Place the dotted zero line
	local dottedLine = GetElem( menu, "KDRatioLast10Graph" + graphIndex + "DottedLine1" )
	local dottedLineOffset = GraphCapped( 0.0, graphMin, graphMax, 0, graphHeight )
	local posX = graphOrigin[0]
	local posY = graphOrigin[1] - ( dottedLine.GetBaseHeight() * 0.5 ) - dottedLineOffset
	dottedLine.SetPos( posX, posY )
	dottedLine.Show()
	*/

	// Connect the dots with lines
	for ( local i = 1 ; i < maxPoints ; i++ )
	{
		local line = lines[i]

		if ( i >= pointCount )
		{
			line.Hide()
			continue
		}

		// Get angle from previous dot to this dot
		local startPos = dotPositions[i-1]
		local endPos = dotPositions[i]
		local offsetX = endPos[0] - startPos[0]
		local offsetY = endPos[1] - startPos[1]
		local angle = ( atan( offsetX / offsetY ) * ( 180 / PI ) )

		// Get line length
		local length = sqrt( offsetX * offsetX + offsetY * offsetY )

		// Calculate where the line should be positioned
		local posX = endPos[0] - ( offsetX / 2.0 ) - ( length / 2.0 )
		local posY = endPos[1] - ( offsetY / 2.0 ) - ( line.GetBaseHeight() / 2.0 )

		//line.SetHeight( 2.0 )
		line.SetWidth( length )
		line.SetRotation( angle + 90.0 )
		line.SetPos( posX, posY )
		line.Show()
	}
}