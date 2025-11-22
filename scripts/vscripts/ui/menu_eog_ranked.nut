const XP_BAR_FILL_DURATION	= 3.0
const XP_BAR_FILL_TIME_MIN = 0.3
const MAX_GEMS_PER_GOAL = 10
const EOG_PROGRESS_BAR_GROWS = true
const SHOW_GEM_INDICATOR = false

const EOG_RANK_MYTEAM_BARFILL_IMAGE = "../ui/menu/rank_menus/ranked_eog_bar_team"
const EOG_RANK_ENEMY_BARFILL_IMAGE = "../ui/menu/rank_menus/ranked_eog_bar_enemy"

PrecacheHUDMaterial( EOG_RANK_MYTEAM_BARFILL_IMAGE )
PrecacheHUDMaterial( EOG_RANK_ENEMY_BARFILL_IMAGE )

function main()
{
	menu <- null
	file.buttonsRegistered <- false
	file.menuAnimDone <- false
	file.rankProgressPanels <- []
	file.activeProgressPanel <- null
	file.nextProgressPanel <- null
	file.gemGoals <- []

	file.size <- [ 0, 0 ]
	file.pages <- [ eEOGRankPage.ALL_PLAYERS, eEOGRankPage.MY_TEAM, eEOGRankPage.ENEMY_TEAM ]
	file.currentPage <- file.pages.top()

	level.performanceGoals <- null
	file.elemGroup <- null
	file.introducedComparisonBars <- false

	RegisterSignal( "ElemFlash" )
	RegisterSignal( "RankChangeMessage" )

	Globalize( InitMenu_EOG_Ranked )
	Globalize( OnOpenEOG_Ranked )
	Globalize( OnCloseEOG_Ranked )
	Globalize( SizeX )
	Globalize( SizeY )
	Globalize( GetStringForContributionType )
	Globalize( GemWonText )
}

function InitMenu_EOG_Ranked( menu )
{
	Assert( menu != null )

	if ( IsFullyConnected() )
	{
		// Buttons & Background
		SetupEOGMenuCommon( menu )
	}

	level.performanceGoals = GetPreviousPlayerPerformanceGoals()

	local elemGroup = {}
	file.elemGroup = elemGroup
	file.RankedHud <- GetElem( menu, "RankedHud" )
	file.RankedHud.Hide()
	UpdatePageTitle()

	InitRankedPanelElems( file.elemGroup, file.RankedHud )

	elemGroup.RankedGoal_NoNumbersProgressBar.SetBarProgress( 0 )
	elemGroup.RankedGoal_NoNumbersProgressBar.Show()
	elemGroup.RankedLogo.Show()
	elemGroup.RankedLogo.SetAlpha( 255 )

	file.messageElem <- GetElem( menu, "InvalidMessage" )
	file.messageElem.SetText( "" )
	file.messageElem.Hide()
	file.contributionPanels <- GetElementsByClassname( menu, "ContributionPanel" )
	file.gemGoalPanels <- []

	local hideElems = []
	hideElems.append( GetElem( menu, "GoalGem0" ) )
	hideElems.append( GetElem( menu, "GoalGem1" ) )
	hideElems.append( GetElem( menu, "GoalGem2" ) )
	foreach ( elem in hideElems )
	{
		elem.Hide()
	}

	for ( local i = 0; i < MAX_GEMS_PER_GOAL; i++ )
	{
		local elem = GetElem( menu, "GoalGemNoNumbers" + i )
		file.gemGoalPanels.append( elem )
		elem.Hide()
		elem.SetImage( GetGemImageForState( "gem_undefeated" ) )
	}

	file.gemIndicator <- GetElem( menu, "GemIndicator" )

	foreach ( panel in file.contributionPanels )
	{
		panel.s.barBG <- panel.GetChild( "BarBG" )
		panel.s.barFill <- panel.GetChild( "BarFill" )
		panel.s.playerIcon <- panel.GetChild( "PlayerIcon" )
		panel.s.playerLevel <- panel.GetChild( "PlayerLevel" )
		panel.s.playerName <- panel.GetChild( "PlayerName" )
		panel.s.scoreDisplayed <- 0
	}

	file.pointsElems <- GetElementsByClassname( menu, "PointsPanel" )
	foreach ( nestedPanel in file.pointsElems )
	{
		nestedPanel.s.title <- nestedPanel.GetChild( "PointsTitle" )
		nestedPanel.s.amount <- nestedPanel.GetChild( "PointsAmount" )
	}

	// Rank progress panels
	for ( local i = 0 ; i < 2 ; i++ )
	{
		local panel = GetElem( menu, "RankProgressPanel" + i )
		Assert( panel != null )

		file.rankProgressPanels.append( panel )
	}

	RankPanel_ShowRank( menu, file.rankProgressPanels[0], GetPlayerOldRank(), true )
	file.rankProgressPanels[0].SetPanelAlpha(255)

	RankPanel_ShowRank( menu, file.rankProgressPanels[1], GetPlayerRank(), true )
	file.rankProgressPanels[1].SetPanelAlpha(0)
}

function OnOpenEOG_Ranked()
{
	menu = GetMenu( "EOG_Ranked" )
	level.currentEOGMenu = menu
	file.size = menu.GetSize()
	file.introducedComparisonBars = false

	Signal( menu, "StopMenuAnimation" )
	EndSignal( menu, "StopMenuAnimation" )
	Signal( level, "CancelEOGThreadedNavigation" )

	//-----------------------------------------------------
	// Clear previous unlocks/progress
	//-----------------------------------------------------

	if ( !IsFullyConnected() && uiGlobal.activeMenu == menu )
	{
		thread CloseTopMenu()
		return
	}

	//-----------------------------------------------------
	// We also get unlock and challenge info now, so we
	// can disable those menus if there is nothing to show
	//-----------------------------------------------------

	InitMenu_EOG_Ranked( menu )
	ResetMenuRanked()

	thread OpenMenuAnimatedRanked()

	EOGOpenGlobal()

	wait 0
	if ( !file.buttonsRegistered )
	{
		RegisterButtonPressedCallback( BUTTON_A, OpenRankedMenuStatic )
		RegisterButtonPressedCallback( KEY_SPACE, OpenRankedMenuStatic )
		RegisterButtonPressedCallback( BUTTON_Y, CycleRankPage )
		file.buttonsRegistered = true
	}

	if ( !level.doEOGAnimsRP )
		OpenRankedMenuStatic(false)
}

function OnCloseEOG_Ranked()
{
	thread EOGCloseGlobal()

	if ( file.buttonsRegistered )
	{
		DeregisterButtonPressedCallback( BUTTON_A, OpenRankedMenuStatic )
		DeregisterButtonPressedCallback( KEY_SPACE, OpenRankedMenuStatic )
		DeregisterButtonPressedCallback( BUTTON_Y, CycleRankPage )
		file.buttonsRegistered = false
	}

	level.doEOGAnimsRP = false
	file.menuAnimDone = false
	Signal( menu, "StopMenuAnimation" )
}

function OpenMenuAnimatedRanked()
{
	EndSignal( menu, "StopMenuAnimation" )

	EmitUISound( "UI_RankedSummary_ScreenStart" )

	// Slide in XP Bar
	if ( EOGIsPrivateMatch() )
	{
		file.activeProgressPanel.Hide()
		file.nextProgressPanel.Hide()
	}
	else
	{
		file.activeProgressPanel.Show()
		file.nextProgressPanel.Show()
		thread FancyLabelFadeIn( menu, file.activeProgressPanel, 0, 300, false, 0.15, true )
	}

	UpdatePageTitle()

	// show how my contribution breaks down and compares with other players
	waitthread ShowPerformanceBreakdown( false )

	// soak it in
	wait 0.5

	// next menu
	if ( level.doEOGAnimsRP && uiGlobal.EOGAutoAdvance )
		thread EOGNavigateRight( null, true )
}

function TotalContributionAnimates()
{
	local breakdownDelay = 0.01 // 0 means numbers disappear ><
	local delayOffset = 2.0

	wait breakdownDelay + delayOffset
	if ( level.doEOGAnimsRP )
		EmitUISound( "EOGSummary.XPTotalPopup" )
}


function UpdateGemLostText()
{
	if ( !IsFullyConnected() )
		return

	local gemCount = GetPersistentVar( "ranked.previousGemCount" )
	if ( !gemCount )
		return

	if ( gemCount >= GetMaxGems() )
		return

	if ( gemCount < GetPlayerTotalCompletedGems() )
		return

	local lastGemState = GetPlayerGemState( null, gemCount - 1, true )

	// has the gem changed?
	local currentGemState = GetPlayerGemState( null, gemCount - 1, false )
	if ( lastGemState == currentGemState )
		return

	if ( !MatchIsValid() )
		return

	if ( lastGemState == "gem_captured" )
	{
		if ( currentGemState == "gem_damaged" )
			DamagedMarkGemMessage()
		else if ( currentGemState == "gem_lost" )
			LostMarkGemMessage()
	}
	else if ( lastGemState == "gem_damaged" )
	{
		LostMarkGemMessage()
	}
	file.messageElem.Show()
}

function MatchIsValid()
{
	if ( !IsFullyConnected() )
		return false

	switch ( GetPersistentVar( "ranked.matchValid" ) )
	{
		case "low_player_count":
		case "low_time_played":
			return false
	}

	return true
}

function ShowPerformanceBreakdown( instant = true, playerSubset = null )
{
	if ( !IsFullyConnected() )
		return

	local e = {}
	e.viewingSkillComparison <- false
	OnThreadEnd(
		function() : ( e )
		{
			StopUISound( "UI_League_PointBar_Loop" )
			file.menuAnimDone = true

			if ( !e.viewingSkillComparison )
			{
				thread UpdateProgressBarsOverTime( file.elemGroup, menu, true )
				UpdateGemLostText()
			}
		}
	)

	ClearPerformanceBars()

	//################################################################
	// MAKE SURE IT WAS A VALID MATCH, OTHERWISE SHOW MESSAGE WHY NOT
	//################################################################

	foreach ( panel in file.gemGoalPanels )
		panel.Hide()
	file.gemIndicator.Hide()

	local matchValid = GetPersistentVar( "ranked.matchValid" )
	local pageTitleElem = GetElem( menu, "PageTitle" )
	local matchValidText

	switch ( matchValid )
	{
		case "low_player_count":
			matchValidText = "#EOG_RANKED_MATCH_LOW_PLAYER_COUNT"
			break

		case "low_time_played":
			matchValidText = "#EOG_RANKED_MATCH_LOW_TIME_PLAYED"
			break
	}

	if ( matchValidText )
	{
		file.messageElem.SetText( matchValidText )
		file.messageElem.Show()
		file.RankedHud.Show()
		if ( IsFullyConnected() )
			RankPanel_ShowRank( menu, file.activeProgressPanel, GetPlayerRank(), false )

		pageTitleElem.Hide()

		if ( !instant )
			wait 3

		return
	}

	//#################################################################
	// GET DATA USED
	//#################################################################

	local matchData = GetRankedMatchData()
	local displayData = GetDisplayData( matchData, playerSubset )
	local myDisplayIndex = GetMyDisplayIndex( displayData )
	if ( myDisplayIndex == null )
		return

	local myPlayerData = displayData[myDisplayIndex]
	level.currentPerformance = myPlayerData.matchPerformance

	local myTeam = displayData[ myDisplayIndex ].team
	local myNameBarColor = [ 140, 140, 140, 255 ]
	local myTeamNameBarColor = [ 0, 117, 140, 100 ]
	local enemyNameBarColor = [ 128, 61, 13, 100 ]
	local oldGemCount = GetPersistentVar( "ranked.previousGemCount" )
	local oldRank = GetGemsToRank( oldGemCount )

	file.gemGoals = GetPerformanceReqForGem( oldGemCount )
	local gameModeIndex = GetPersistentVar( "savedScoreboardData.gameMode" )
	local gameMode = PersistenceGetEnumItemNameForIndex( "gameModes", gameModeIndex )
	local pointCategories = GetContributionMappingForGamemode( gameMode ).mapping // needs to come from persistence when we add support for more modes
	Assert( pointCategories.len() <= PersistenceGetArrayCount( "ranked.contributionPoints" ) )

	local contributions = []
	contributions.resize( pointCategories.len() )
	local pointsPerCategory = []
	pointsPerCategory.resize( pointCategories.len() )
	local totalPositivePoints = 0.0
	for ( local i = 0 ; i < pointCategories.len() ; i++ )
	{
		local points = GetPersistentVar( "ranked.contributionPoints[" + i + "]" )
		pointsPerCategory[i] = points
		if ( points > 0 )
			totalPositivePoints += points
	}

	local gemsWon = 0
	foreach ( goal in file.gemGoals )
	{
		if ( goal <= myPlayerData.matchPerformance )
			gemsWon++
	}

	local basePos = file.RankedHud.GetBasePos()
	if ( instant )
	{
		file.RankedHud.ReturnToBasePos()
		file.RankedHud.Hide()
		file.messageElem.Hide()
	}
	else
	{
		if ( level.doEOGAnimsRP )
		{
			file.RankedHud.SetPos( basePos[0], basePos[1] + 800 )
			file.RankedHud.ReturnToBasePosOverTime( 0.2, INTERPOLATOR_DEACCEL )
			file.messageElem.Hide()
			file.RankedHud.Show()
			file.introducedComparisonBars = false
		}
		else
		{
			file.RankedHud.ReturnToBasePos()
			file.RankedHud.Show()
			file.messageElem.Show()
		}
	}

	UpdatePageTitle()
	GemTransition( file.elemGroup, 0, 0 )

	if ( EOG_PROGRESS_BAR_GROWS )
		file.elemGroup.RankedGoal_NoNumbersProgressBar.SetBarProgress( 0 )
	else
		file.elemGroup.RankedGoal_NoNumbersProgressBar.SetBarProgress( myPlayerData.matchPerformance )

	//#################################################################
	// INIT THE PERFORMANCE BARS. ONLY THE PLAYERS IS VISIBLE AT FIRST
	//#################################################################

	// Loop through all the panels
	local panelsToShow = []
	foreach ( i, panel in file.contributionPanels )
	{
		local barBGElem = panel.s.barBG
		local playerIconElem = panel.s.playerIcon
		local playerLevelElem = panel.s.playerLevel
		local playerNameElem = panel.s.playerName
		local progressBarFill = panel.s.barFill

		if ( i >= displayData.len() )
		{
			// No player data for this panel, hide it
			panel.Hide()
			continue
		}

		// Show player data on panel
		panel.Show()
		panelsToShow.append( panel )
		local playerData = displayData[i]

		// Gen or Rank icon
		local playerIcon
		if ( playerData.playingRanked )
			playerIcon = GetRankImage( playerData.rank )
		else
			playerIcon = "../ui/menu/generation_icons/generation_" + playerData.gen
		playerIconElem.SetImage( playerIcon )
		playerIconElem.Show()

		// Player level
		playerLevelElem.SetText( playerData.lvl.tostring() )
		playerLevelElem.Show()

		// Bar
		barBGElem.Show()
		UpdateContributionProgressBar( menu, panel, 0 )

		// Player Name
		playerNameElem.SetText( playerData.name )
		if ( i == myDisplayIndex )
		{
			playerNameElem.SetColor( LOCALPLAYER_NAME_COLOR, 255 )
			panel.SetY( file.contributionPanels[1].GetY() )
		}
		else
		{
			playerNameElem.SetColor( 255, 255, 255, 255 )
		}

		panel.SetPanelAlpha( 0 )

		// Player name background color
		if ( i == myDisplayIndex || displayData[ i ].team == myTeam )
			playerNameElem.SetColorBG( myTeamNameBarColor )
		else
			playerNameElem.SetColorBG( enemyNameBarColor )
		playerNameElem.Show()

		// Set progress bar color
		if ( i == myDisplayIndex || displayData[ i ].team == myTeam )
			progressBarFill.SetImage( EOG_RANK_MYTEAM_BARFILL_IMAGE )
		else
			progressBarFill.SetImage( EOG_RANK_ENEMY_BARFILL_IMAGE )
	}

	//#################################################################
	// HIDE ALL CONTRIBUTION LINES SO WE CAN REVEAL THEM WITH ANIMATION
	//#################################################################

	if ( !instant )
	{
		foreach ( i, category in pointCategories )
		{
			local panel = file.pointsElems[i]
			local desc = GetStringForContributionType( pointCategories[i], gameMode )
			UpdateContributionCategory( menu, panel, desc, pointsPerCategory[i] )
			if ( pointsPerCategory[i] > 0 )
				panel.s.amount.SetText( "0" )
			panel.Hide()
		}
	}

	//#################################################################
	// WHEN THE THREAD IS DONE OR ENDS EARLY THE MENU SHOULD STOP
	// ANIMATING AND GO TO STATIC STATE
	//#################################################################

	EndSignal( menu, "StopMenuAnimation" )

	OnThreadEnd(
		function() : ( menu, displayData, pointCategories, pointsPerCategory, gameMode, panelsToShow )
		{
			StopUISound( "UI_RankedSummary_CircleFill" )
			StopUISound( "UI_League_PointBar_Loop" )

			// Show score breakdowns
			foreach ( i, category in pointCategories )
			{
				local panel = file.pointsElems[i]
				local desc = GetStringForContributionType( category, gameMode )
				UpdateContributionCategory( menu, panel, desc, pointsPerCategory[i] )
				panel.ReturnToBasePos()
				panel.SetPanelAlpha( 255 )
				panel.Show()
			}

			if ( file.introducedComparisonBars )
			{
				// Show player progress bars
				foreach ( i, panel in panelsToShow )
				{
					panel.ReturnToBasePos()
					panel.SetPanelAlpha( 255 )
					panel.Show()

					UpdateContributionProgressBar( menu, panel, displayData[ i ].matchPerformance )
				}
			}

			if ( IsFullyConnected() )
			{
				// Show latest rank info
				RankPanel_ShowRank( menu, file.activeProgressPanel, GetPlayerRank(), false )
			}

			// Hide gem goal panels
			foreach ( panel in file.gemGoalPanels )
				panel.Hide()
			file.gemIndicator.Hide()
		}
	)

	if ( !instant )
	{
		//#################################################################
		// SHOW GEM GOALS ON THE PROGRESS BAR
		//#################################################################

		Assert( file.gemGoals.len() <= file.gemGoalPanels.len() )
		local currentPanel = file.contributionPanels[ myDisplayIndex ]
		local barFill = currentPanel.s.barFill
		local basePos = barFill.GetAbsPos()
		local baseWidth = barFill.GetBaseWidth()
		local baseHeight = barFill.GetBaseHeight()
		local gemGoalPosX_min = basePos[0]
		local gemGoalPosX_max = basePos[0] + baseWidth
		local baseY = currentPanel.GetAbsPos()[1]
		 //+ baseHeight * 0.5

		local gem = file.gemGoalPanels[0]
		local gemWidth = gem.GetBaseWidth()
		local gemHeight = gem.GetBaseHeight()

		foreach ( i, panel in file.gemGoalPanels )
		{
			panel.Hide()
			continue
		}

		//#################################################################
		// SHOW GEM INDICATOR WHERE THE NEXT AWARDED GEM WILL GO
		//#################################################################

		local nextGemWinIndex = oldGemCount - GetMinGemsForRank( oldRank )
		local indicatorPos = GetGemIndicatorPos( nextGemWinIndex )
		file.gemIndicator.ReturnToBasePos()
		file.gemIndicator.ReturnToBaseColor()
		file.gemIndicator.ReturnToBaseSize()
		file.gemIndicator.SetPos( indicatorPos[0], indicatorPos[1] )
		if ( SHOW_GEM_INDICATOR )
			file.gemIndicator.Show()
		thread PulsateElem( menu, file.gemIndicator )

		//#################################################################
		// SHOW SCORE CONTRIBUTION CATEGORIES
		// THIS ALSO PROGRESSES THE LOCAL PLAYERS PROGRESS BAR
		//#################################################################

		local totalAnimateDuration = 1.0
		local playerProgressPanel = file.contributionPanels[ myDisplayIndex ]
		local positiveScoreSoFar = 0
		local lastBarScore = 0
		local currentBarScore = 0

		foreach ( i, category in pointCategories )
		{
			// Reveal the contribution description
			local panel = file.pointsElems[i]
			local points = pointsPerCategory[i].tofloat()
			thread FancyLabelFadeIn( menu, panel, 0, -300, true, 0.2, true, 0.0, "Menu_GameSummary_XPBonusesSlideIn" )

			// Make the score tick up
			local tickDuration = 0.0
			UpdateContributionCategory( menu, panel, null, pointsPerCategory[i], tickDuration )
		}

		wait 1.25

		//#################################################################
		// SHOW GEM AND RANK CHANGE
		//#################################################################

		waitthread ShowGemChanges( gemsWon, myPlayerData )

		foreach ( elem in file.gemGoalPanels )
		{
			elem.Hide()
		}

		RankPanel_ShowRank( menu, file.activeProgressPanel, GetPlayerRank(), false )

		//#################################################################
		// MOVE PLAYER PROGRESS BAR INTO POSITION AND REVEAL OTHER PLAYERS
		//#################################################################

		local basePos = playerProgressPanel.GetBasePos()
		playerProgressPanel.MoveOverTime( basePos[0], basePos[1], 0.2, INTERPOLATOR_DEACCEL )

		if ( uiGlobal.EOGAutoAdvance )
		{
			file.RankedHud.Hide()
			EmitUISound( "UI_RankedSummary_CircleFadeout" )
			wait 0.5
		}
		return
	}

	e.viewingSkillComparison = true

	if ( file.introducedComparisonBars )
		return

	file.RankedHud.Hide()
	file.introducedComparisonBars = true
	file.messageElem.Hide()
	UpdatePageTitle()

	EmitUISound( "UI_RankedSummary_GraphSliderSweetener" )
	for ( local i = 0; i < displayData.len(); i++ )
	{
		local panel = file.contributionPanels[i]
		thread FancyLabelFadeIn( menu, panel, 300, 0, false, 0.2, true, 0.0, "Menu_GameSummary_XPBonusesSlideIn" )
		EmitUISound( "UI_RankedSummary_GraphSliderIndividual" )
		wait 0.1
	}

	//#################################################################
	// FILL UP OTHER PLAYER BARS
	//#################################################################

	pageTitleElem.Show()
	local timePerBar = 0.5 / displayData.len()
	EmitUISound( "UI_League_PointBar_Loop" )

	local playerProgressPanel = file.contributionPanels[ myDisplayIndex ]

	for ( local i = 0; i < displayData.len(); i++ )
	{
		local panel = file.contributionPanels[i]

		local playerData = displayData[i]
		thread UpdateContributionProgressBar( menu, panel, playerData.matchPerformance, timePerBar )
		wait timePerBar
	}

	StopUISound( "UI_League_PointBar_Loop" )
}

function UpdateContributionCategory( menu, panel, desc, score, tickDuration = 0.0 )
{
	if ( desc != null )
		panel.s.title.SetText( desc )

	if ( tickDuration <= 0.0 )
		panel.s.amount.SetText( score.tostring() )
	else
		thread SetTextCountUp( menu, panel.s.amount, score, null, 0.0, null, tickDuration )

	if ( score > 0 )
	{
		panel.s.title.SetColor( 255, 255, 255 )
		panel.s.amount.SetColor( 255, 255, 255 )
	}
	else if ( score == 0 )
	{
		panel.s.title.SetColor( 127, 127, 127 )
		panel.s.amount.SetColor( 127, 127, 127 )
	}
	else
	{
		panel.s.title.SetColor( 255, 0, 0 )
		panel.s.amount.SetColor( 255, 0, 0 )
	}

	panel.Show()
}

function UpdateContributionProgressBar( menu, panel, score, tickDuration = 0.0, soundAlias = null )
{
	local bar = panel.s.barFill

	if ( tickDuration > 0 && soundAlias != null )
		EmitUISound( soundAlias )

	// Bar
	if ( tickDuration > 0 )
		bar.ScaleOverTime( score / 100.0, 1, tickDuration, INTERPOLATOR_LINEAR )
	else
		bar.SetScale( score / 100.0, 1 )

	bar.Show()

	panel.s.scoreDisplayed = score
	if ( tickDuration > 0 )
	{
		wait tickDuration
		if ( soundAlias != null )
			StopUISound( soundAlias )
	}
}

function GetGemWonMsgFromCount( gemCount )
{
	if ( gemCount + 1 >= file.gemGoals.len() )
	{
		switch ( gemCount )
		{
			case 0:
				return "#EOG_RANKED_EARNED_MARK_1_all"
			case 1:
				return "#EOG_RANKED_EARNED_MARK_2_all"
			case 2:
				return "#EOG_RANKED_EARNED_MARK_3_all"
			case 3:
				return "#EOG_RANKED_EARNED_MARK_4_all"
			case 4:
				return "#EOG_RANKED_EARNED_MARK_5_all"
		}
	}
	else
	{
		switch ( gemCount )
		{
			case 0:
				return "#EOG_RANKED_EARNED_MARK_1"
			case 1:
				return "#EOG_RANKED_EARNED_MARK_2"
			case 2:
				return "#EOG_RANKED_EARNED_MARK_3"
			case 3:
				return "#EOG_RANKED_EARNED_MARK_4"
		}
	}
}

function GemWonText( gemCount )
{
	if ( !MatchIsValid() )
		return

	local msg = GetGemWonMsgFromCount( gemCount )
	if ( msg )
	{
		GemMessage( msg )
		file.messageElem.Show()
	}
}

function GemMessage( msg )
{
	if ( MatchIsValid() )
		file.messageElem.SetText( msg )
}

function DisplayGemProgressOverTime( e )
{
	EndSignal( level, "CompletedProgressTally" )
	local gemCount = GetPersistentVar( "ranked.previousGemCount" )
	local oldRank = GetGemsToRank( gemCount )
	local rank = oldRank
	local gemsForRank = GetGemsForRank( rank )
	local minTotalGemsForRank = GetMinGemsForRank( rank )
	local firstRun = true
	local gemsCapturedThisTime = 0


	thread UpdateProgressBarsOverTime( file.elemGroup, menu )
	for ( ;; )
	{
		local gemIndex = gemCount - minTotalGemsForRank
		local indicatorPos = GetGemIndicatorPos( gemIndex )
		if ( SHOW_GEM_INDICATOR )
			file.gemIndicator.Show()

		if ( firstRun || gemIndex == 0 )
		{
			file.gemIndicator.SetPos( indicatorPos[0], indicatorPos[1] )
		}
		else
		{
			file.gemIndicator.MoveOverTime( indicatorPos[0], indicatorPos[1], 0.2, INTERPOLATOR_ACCEL )
			//EmitUISound( "EOGSummary.XPBreakdownPopup" )
			wait 0.35
		}

		firstRun = false

		WaitSignal( level, "CapturedGem" )

		thread PulsateElem( menu, file.gemIndicator )
		thread YouCaptureGem( gemIndex, gemsForRank, gemsCapturedThisTime )
		thread MoveGemIndicator( gemIndex, gemsForRank )

		gemCount++
		gemsCapturedThisTime++
		rank = GetGemsToRank( gemCount )
		gemsForRank = GetGemsForRank( rank )
		minTotalGemsForRank = GetMinGemsForRank( rank )
		e.wonGems = true

		if ( rank > oldRank )
		{
			oldRank = rank
			file.elemGroup.paused = true
			wait 1
			waitthread SwapProgressPanels()
			waitthread RankUpMessage( rank )
			wait 0.9
			file.elemGroup.paused = false
			Signal( level, "NewPerformanceUpdate" )
		}

		oldRank = rank
	}
}

function ShowGemChanges( gemsWon, myPlayerData )
{
	EndSignal( menu, "StopMenuAnimation" )
	OnThreadEnd(
		function() : (  )
		{
			StopUISound( "UI_RankedSummary_CircleFill" )
			file.elemGroup.RankedGoal_NoNumbersProgressBar.SetBarProgress( 0 )
		}
	)

	local goals = level.performanceGoals
	local steps = []
	local totalSize = 0

	local e = {}
	e.wonGems <- false
	if ( level.currentPerformance )
		waitthread DisplayGemProgressOverTime( e )

	if ( e.wonGems )
	{
		wait 1.15
	}
	else
	{
		local gemCount = GetPersistentVar( "ranked.previousGemCount" )
		local rank = GetGemsToRank( gemCount )
		local gemsForRank = GetGemsForRank( rank )
		local minTotalGemsForRank = GetMinGemsForRank( rank )
		local oldGemCount = GetPersistentVar( "ranked.previousGemCount" )
		local oldRank = GetGemsToRank( oldGemCount )
		// Player didn't win any gems, they lose one or crack one
//		for ( local i = gemsWon ; i < 3 ; i++ )
//			DontWinGem( i )

		if ( gemCount > 0 )
		{
			local lastGemState = GetPlayerGemState( null, gemCount - 1, true )
			local currentGemState = GetPlayerGemState( null, gemCount - 1, false )

			// has the gem changed?
			if ( lastGemState != currentGemState )
			{
				local gemIndex = gemCount - minTotalGemsForRank - 1

				if ( currentGemState == "gem_damaged" )
				{
					thread DamageGem( gemIndex )
				}
				else if ( currentGemState == "gem_lost" )
				{
					rank = GetGemsToRank( gemCount - 1 )
					if ( oldRank > rank )
					{
						file.gemIndicator.Hide()
						waitthread SwapProgressPanels(-1)
						thread RankDownMessage( rank )
					}
					thread LoseGem( gemIndex )
				}
				else
					Assert( 0, "Trying to lose a gem that wasn't captured or damaged. This shouldn't happen." )
				wait 1.5
			}
		}
		wait 1.5
	}

	file.gemIndicator.Hide()
}

function YouCaptureGem( gemIndex, gemsForRank, gemsCapturedThisTime )
{
	thread GemWonText( gemsCapturedThisTime )
	local gemPanel = file.activeProgressPanel.GetChild( "Gem" + gemIndex )
	thread DoWinGem( gemIndex, gemsForRank, gemPanel )

	local gemElem = gemPanel.GetChild( "GemImage" )
	local newStateImage = GetGemImageForState( "gem_captured" )
	gemElem.SetImage( newStateImage )

	for ( local i = 0; i < 5; i++ )
	{
		gemElem.SetColor( 255, 255, 255, 255 )
		gemElem.ColorOverTime( 0, 0, 0, 255, 0.2, INTERPOLATOR_LINEAR )

		wait 0.2
	}

	gemElem.SetColor( 255, 255, 255, 255 )
}

function DoWinGem( index, gemsForRank, gemPanel )
{
	local newStateImage = GetGemImageForState( "gem_captured" )

	local gemElem = gemPanel.GetChild( "GemImage" )
	gemPanel.SetZ( 117 )

	local previousGemElem = null
	// If there is a gem before this index we need to make sure it's no longer damaged
	if ( index > 0 )
	{
		local previousGemPanel = file.activeProgressPanel.GetChild( "Gem" + (index - 1) )
		previousGemElem = previousGemPanel.GetChild( "GemImage" )
	}

	// Hide the award gem and lines and put the transition image in it's place

	OnThreadEnd(
		function() : ( index, gemsForRank, gemPanel, gemElem, previousGemElem, newStateImage )
		{
			gemPanel.SetZ( 116 )
			gemElem.SetImage( newStateImage )

			if ( previousGemElem != null )
				previousGemElem.SetImage( newStateImage )

			// Update battlemarks display
			local gemHeaderLabel = file.activeProgressPanel.GetChild( "GemsHeader" )
			gemHeaderLabel.SetText( "#RANKED_PROGRESS_PANEL_GEM_HEADER", index + 1, gemsForRank )
		}
	)

	// Update battlemarks display
	local gemHeaderLabel = file.activeProgressPanel.GetChild( "GemsHeader" )
	gemHeaderLabel.SetText( "#RANKED_PROGRESS_PANEL_GEM_HEADER", index + 1, gemsForRank )

	// If there is a gem before this index we need to make sure it's no longer damaged
	if ( previousGemElem != null )
		previousGemElem.SetImage( newStateImage )

	gemElem.SetImage( newStateImage )
}

function MoveGemIndicator( index, gemsForRank )
{
	// Move indicator to the gem
	local indicatorPos = GetGemIndicatorPos( index )
	if ( SHOW_GEM_INDICATOR )
		file.gemIndicator.Show()

	if ( index == 0 )
	{
		file.gemIndicator.SetPos( indicatorPos[0], indicatorPos[1] )
	}
	else
	{
		file.gemIndicator.MoveOverTime( indicatorPos[0], indicatorPos[1], 0.2, INTERPOLATOR_ACCEL )
		//EmitUISound( "EOGSummary.XPBreakdownPopup" )
		wait 0.35
	}

	//EmitUISound( "UI_InGame_BurnCardFlyin" )
	wait 0.15

	// Update battlemarks display
	local gemHeaderLabel = file.activeProgressPanel.GetChild( "GemsHeader" )
	gemHeaderLabel.SetText( "#RANKED_PROGRESS_PANEL_GEM_HEADER", index + 1, gemsForRank )

//	EmitUISound( "UI_InGame_CoOp_WaveSurvived" )
}

function DontWinGem( flyinIndex )
{
	file.gemGoalPanels[flyinIndex].Hide()
}

function DamagedMarkGemMessage()
{
	if ( GetPersistentVar( "ranked.matchValid" ) == "quit_early" )
		GemMessage( "#EOG_RANKED_DAMAGED_MARK_QUIT" )
	else
		GemMessage( "#EOG_RANKED_DAMAGED_MARK" )
}

function LostMarkGemMessage()
{
	if ( RankedAlwaysLoseGem() )
	{
		if ( GetPersistentVar( "ranked.matchValid" ) == "quit_early" )
			GemMessage( "#EOG_RANKED_LOST_MARK_QUIT_NO_DAMAGE" )
		else
			GemMessage( "#EOG_RANKED_LOST_MARK_NO_DAMAGE" )
	}
	else
	{
		if ( GetPersistentVar( "ranked.matchValid" ) == "quit_early" )
			GemMessage( "#EOG_RANKED_LOST_MARK_QUIT" )
		else
			GemMessage( "#EOG_RANKED_LOST_MARK" )
	}
}

function DamageGem( index )
{
	// Move indicator to the gem
	if ( index >= 0 )
	{
		local indicatorPos = GetGemIndicatorPos( index )
		file.gemIndicator.MoveOverTime( indicatorPos[0], indicatorPos[1], 0.2, INTERPOLATOR_ACCEL )
		//EmitUISound( "EOGSummary.XPBreakdownPopup" )
		if ( SHOW_GEM_INDICATOR )
			file.gemIndicator.Show()
		wait 0.5
	}

	if ( MatchIsValid() )
	{
		DamagedMarkGemMessage()
		file.messageElem.Show()
	}

	if ( index >= 0 )
	{
		local newStateImage = GetGemImageForState( "gem_damaged" )
		local gemPanel = file.activeProgressPanel.GetChild( "Gem" + index )
		local gemElem = gemPanel.GetChild( "GemImage" )

		gemElem.SetImage( newStateImage )
	}

	EmitUISound( "UI_RankedSummary_BattleMark_Break" )

	wait 0.4
}

// TODO: Fade not working
function LoseGem( index )
{
	if ( SHOW_GEM_INDICATOR )
	{
		if ( index >= 0 )
		{
			local indicatorPos = GetGemIndicatorPos( index )
			file.gemIndicator.MoveOverTime( indicatorPos[0], indicatorPos[1], 0.2, INTERPOLATOR_ACCEL )
			//EmitUISound( "EOGSummary.XPBreakdownPopup" )
			file.gemIndicator.Show()
			wait 0.5
		}
	}
	else
	{
		wait 0.5
	}


	if ( MatchIsValid() )
	{
		LostMarkGemMessage()
		file.messageElem.Show()
	}

	if ( index >= 0 )
	{
		local newStateImage = GetGemImageForState( "gem_lost" )
		local gemPanel = file.activeProgressPanel.GetChild( "Gem" + index )
		local gemElem = gemPanel.GetChild( "GemImage" )

		gemElem.SetImage( newStateImage )
	}

	EmitUISound( "UI_RankedSummary_BattleMark_Lost" )

	wait 0.4
}

function PerformanceSort( a, b )
{
	if ( a.matchPerformance > b.matchPerformance )
		return -1
	if ( a.matchPerformance < b.matchPerformance )
		return 1
	return 0
}

function GetRankedMatchData()
{
	local playerData = []

	local numPlayers = {}
	numPlayers[ TEAM_IMC ] <- GetPersistentVar( "savedScoreboardData.numPlayersIMC" )
	numPlayers[ TEAM_MILITIA ] <- GetPersistentVar( "savedScoreboardData.numPlayersMCOR" )

	local maxPlayers = PersistenceGetArrayCount( "savedScoreboardData.playersMCOR" )

	foreach ( teamIndex, playerCount in numPlayers )
	{
		if ( playerCount > maxPlayers )
			numPlayers[ teamIndex ] = maxPlayers
	}

	local playerDataVars = {}
	playerDataVars[ TEAM_IMC ] <- "playersIMC"
	playerDataVars[ TEAM_MILITIA ] <- "playersMCOR"

	local total = 0
	foreach ( team, teamVar in playerDataVars )
	{
		local playerIndex
		if ( GetPersistentVar( "savedScoreboardData.playerTeam" ) == team )
			playerIndex = GetPersistentVar( "savedScoreboardData.playerIndex" )

		for ( local i = 0 ; i < numPlayers[ team ]; i++ )
		{
			local name = GetPersistentVar( "savedScoreboardData." + teamVar + "[" + i + "].name" )
			local gen = GetPersistentVar( "savedScoreboardData." + teamVar + "[" + i + "].gen" )
			local playingRanked = GetPersistentVar( "savedScoreboardData." + teamVar + "[" + i + "].playingRanked" )
			local rank = GetPersistentVar( "savedScoreboardData." + teamVar + "[" + i + "].rank" )
			local lvl = GetPersistentVar( "savedScoreboardData." + teamVar + "[" + i + "].level" )
			local matchPerformance = GetPersistentVar( "savedScoreboardData." + teamVar + "[" + i + "].matchPerformance" )

			local isPlayer = playerIndex != null && playerIndex == i

			playerData.append( { name = name, gen = gen, playingRanked = playingRanked, rank = rank, team = team, isPlayer = isPlayer, lvl = lvl, matchPerformance = matchPerformance } )
			total += matchPerformance
		}
	}

	playerData.sort( PerformanceSort )

	local highestPerformance = 0
	local myIndex
	foreach ( index, table in playerData )
	{
		if ( table.matchPerformance > highestPerformance )
			highestPerformance = table.matchPerformance
		if ( table.isPlayer )
		{
			myIndex = index
			break
		}
	}

	return { playerData = playerData, total = total, myIndex = myIndex, highestPerformance = highestPerformance }
}
Globalize( GetRankedMatchData )

function GetDisplayData( matchData, playerSubset = null )
{
	local playerData = matchData.playerData

	local myData
	foreach ( table in playerData )
	{
		if ( table.isPlayer )
			myData = table
	}

	local teamToShow
	if ( playerSubset == eEOGRankPage.MY_TEAM )
		teamToShow = myData.team
	else if ( playerSubset == eEOGRankPage.ENEMY_TEAM )
		teamToShow = GetEnemyTeam( myData.team )

	local displayData = []

	if ( teamToShow )
	{
		foreach ( table in playerData )
		{
			if ( table.team == teamToShow || table.isPlayer )
				displayData.append( table )
		}
	}
	else
	{
		displayData = playerData
	}

	if ( displayData.len() > 8 )
		displayData = playerData.slice( 0, 8 )

	local found = false
	foreach ( table in displayData )
	{
		if ( table.isPlayer )
		{
			found = true
			break
		}
	}

	if ( !found )
	{
		displayData.pop()
		displayData.append( myData )
	}

	return displayData
}
Globalize( GetDisplayData )

function GetMyDisplayIndex( displayData )
{
	local myIndex
	foreach ( index, table in displayData )
	{
		if ( table.isPlayer )
		{
			myIndex = index
			break
		}
	}

	return myIndex
}

function OpenRankedMenuStatic( userInitiated = true )
{
	if ( file.menuAnimDone && userInitiated )
		thread EOGNavigateRight( null )
	else
		Signal( menu, "StopMenuAnimation" )
}

function ResetMenuRanked()
{
	ClearPerformanceBars()

	foreach ( nestedPanel in file.pointsElems )
		nestedPanel.Hide()

	// Reset progress panel positions
	foreach ( panel in file.rankProgressPanels )
		panel.ReturnToBasePos()

	file.activeProgressPanel = file.rankProgressPanels[0]
	file.nextProgressPanel = file.rankProgressPanels[1]
}

function ClearPerformanceBars()
{
	foreach ( panel in file.contributionPanels )
	{
		panel.s.barBG.Hide()
		panel.s.barFill.Hide()
		panel.s.playerIcon.Hide()
		panel.s.playerLevel.Hide()
		panel.s.playerName.Hide()
	}
}

function SwapProgressPanels( direction = 1 )
{
	// Swap what the active panel
	if ( file.activeProgressPanel == file.rankProgressPanels[0] )
	{
		// in case we level up twice, we need to update the gems
		if ( direction > 0 )
			RankPanel_ShowRank( menu, file.rankProgressPanels[1], GetPlayerRank(), true )

		file.activeProgressPanel = file.rankProgressPanels[1]
		file.nextProgressPanel = file.rankProgressPanels[0]
	}
	else
	{
		// in case we level up twice, we need to update the gems
		if ( direction > 0 )
			RankPanel_ShowRank( menu, file.rankProgressPanels[0], GetPlayerRank(), true )

		file.activeProgressPanel = file.rankProgressPanels[0]
		file.nextProgressPanel = file.rankProgressPanels[1]
	}

	file.gemIndicator.Hide()

	// Move the old panel down
	local duration = 0.3
	local xOffset = file.activeProgressPanel.GetWidth() * direction

	thread FancyLabelFadeOut( menu, file.nextProgressPanel, 0, 300, duration, true )
	thread FancyLabelFadeIn( menu, file.activeProgressPanel, xOffset, 0, false, duration, true )
	wait duration
}

function RankUpMessage( newRank )
{
	EndSignal( menu, "StopMenuAnimation" )

	local text = GetElem( menu, "RankChangeText" )
	local scan = GetElem( menu, "RankChangeTextScan" )

	Signal( text, "RankChangeMessage" )
	EndSignal( text, "RankChangeMessage" )

	OnThreadEnd(
		function() : ( text, scan )
		{
			text.Hide()
			scan.Hide()
		}
	)

	text.SetText( GetRankName( newRank ) )

	local size = text.GetSize()

	thread RankUpMessage_Text( text )

	// Animate the text scan
	scan.Show()
	scan.ReturnToBasePos()
	scan.ReturnToBaseSize()
	scan.SetBaseSize( size[0], size[1] )
	scan.SetSize( 0, 0 )
	scan.SetColor( 255, 255, 255, 0 )
	scan.FadeOverTime( 255, 0.5, INTERPOLATOR_ACCEL )
	scan.ScaleOverTime( 2.0, 3.0, 0.25, INTERPOLATOR_ACCEL )
	wait 0.25
	scan.ScaleOverTime( 0.5, 1.0, 0.25, INTERPOLATOR_DEACCEL )
	scan.ColorOverTime( 0, 0, 0, 0, 0.5, INTERPOLATOR_ACCEL )
	wait 0.5
	scan.ColorOverTime( 255, 255, 255, 255, 1.75, INTERPOLATOR_ACCEL )
	wait 1.75
	scan.FadeOverTime( 0, 1.5, INTERPOLATOR_ACCEL )
	scan.OffsetOverTime( -size[0], 0, 0.75, INTERPOLATOR_ACCEL )
	scan.ScaleOverTime( 0.0, 3.0, 0.75, INTERPOLATOR_ACCEL )
	wait 0.7
	scan.Hide()
	wait 0.1
}

function RankUpMessage_Text( textLabel )
{
	// Animate the text label
	EndSignal( menu, "StopMenuAnimation" )
	EndSignal( textLabel, "RankChangeMessage" )

	OnThreadEnd(
		function() : ( textLabel )
		{
			textLabel.Hide()
		}
	)

	local color = [ 210, 170, 0 ]
	local basePos = textLabel.GetBasePos()
	local yOffset1 = 65
	local yOffset2 = 10
	local yOffset3 = -10
	local yOffset4 = -400

	textLabel.Show()
	textLabel.SetColor( color[0], color[1], color[2], 0 )
	textLabel.SetPos( basePos[0], basePos[1] + SizeY( file.size, yOffset1 ) )
	textLabel.FadeOverTime( 255, 0.15, INTERPOLATOR_ACCEL )
	textLabel.MoveOverTime( basePos[0], basePos[1] + yOffset2, 0.2 )
	wait 0.2

	if ( level.doEOGAnimsRP )
		EmitUISound( "UI_RankedSummary_Promotion" )

	textLabel.MoveOverTime( basePos[0], basePos[1] + yOffset3, 3.0 )
	textLabel.RunAnimationCommand( "FgColor", 0, 2.5, 0.5, INTERPOLATOR_FLICKER, 0.15 )
	wait 3.0
	textLabel.MoveOverTime( basePos[0], basePos[1] + yOffset4, 0.2 )
	wait 0.2
}

function RankDownMessage( newRank )
{
	local text = GetElem( menu, "RankChangeText" )

	Signal( text, "RankChangeMessage" )
	EndSignal( text, "RankChangeMessage" )
	EndSignal( menu, "StopMenuAnimation" )

	OnThreadEnd(
		function() : ( text )
		{
			text.Hide()
		}
	)

	text.SetText( GetRankName( newRank ) )

	local color = [ 255, 255, 255 ]
	local basePos = text.GetBasePos()
	local yOffset1 = 4

	text.Show()
	text.SetColor( color[0], color[1], color[2], 0 )
	text.SetPos( basePos[0], basePos[1] + SizeY( file.size, yOffset1 ) )
	text.FadeOverTime( 255, 0.15, INTERPOLATOR_ACCEL )
	wait 0.2

	if ( level.doEOGAnimsRP )
		EmitUISound( "UI_RankedSummary_Demotion" )

	wait 3
	text.FadeOverTime( 0, 2, INTERPOLATOR_LINEAR )
	wait 2
}

function GetStringForContributionType( contType, gameMode )
{
	switch ( contType )
	{
		case eRankedContributionType.ASSAULT_PLUS_DEFENSE:
			return GameModeAssaultDefenseDescription( gameMode )

		case eRankedContributionType.ASSAULT:
			return GameModeAssaultDescription( gameMode )

		case eRankedContributionType.DEFENSE:
			return GameModeDefenseDescription( gameMode )

		case eRankedContributionType.CTF_FLAG_CAPTURES:
			return "#RANKED_POINT_DESC_FLAG_CAPTURES"

		case eRankedContributionType.CTF_FLAG_RETURNS:
			return "#RANKED_POINT_DESC_FLAG_RETURNS"

		case eRankedContributionType.CTF_FLAG_ASSISTS:
			return "#RANKED_POINT_DESC_FLAG_ASSISTS"

		case eRankedContributionType.CTF_FLAG_CARRIER_KILLS:
			return "#RANKED_POINT_DESC_FLAG_CARRIER_KILLS"

		case eRankedContributionType.KILLS_PILOT:
		case eRankedContributionType.LTS_PILOT_KILL:
			return "#RANKED_POINT_DESC_KILLS_PILOTS"

		case eRankedContributionType.KILLS_TITAN:
			return "#RANKED_POINT_DESC_KILLS_TITANS"

		case eRankedContributionType.DAMAGED_TITAN:
			return "#RANKED_POINT_DESC_TITANS"

		case eRankedContributionType.DAMAGED_PILOT:
			return "#RANKED_POINT_DESC_PILOTS"

		case eRankedContributionType.DAMAGED_SPECTRE:
			return "#RANKED_POINT_DESC_SPECTRES"

		case eRankedContributionType.DAMAGED_GRUNT:
			return "#RANKED_POINT_DESC_GRUNTS"

		case eRankedContributionType.TDM_PILOT_KILLS:
			return "#RANKED_POINT_DESC_TDM_PILOT_KILLS"

		case eRankedContributionType.TDM_PILOT_ASSISTS:
			return "#RANKED_POINT_DESC_TDM_PILOT_ASSISTS"

		case eRankedContributionType.LOSS_PILOT_DEATH:
			return "#RANKED_POINT_DESC_DEATHS"

		case eRankedContributionType.LOSS_TITAN_DEATH:
			return "#RANKED_POINT_DESC_TITAN_DEATHS"

		case eRankedContributionType.MarkedSurvival:
			return "#RANKED_POINT_DESC_MARKED_SURVIVAL"

		case eRankedContributionType.MarkedKilledMarked:
			return "#RANKED_POINT_DESC_MARKED_KILLED_MARKED"

		case eRankedContributionType.MarkedOutlastedEnemyMarked:
			return "#RANKED_POINT_DESC_MARKED_OUTLASTED_ENEMY_MARKED"

		case eRankedContributionType.MarkedTargetKilled:
			return "#RANKED_POINT_DESC_MARKED_TARGET_KILLED"

		case eRankedContributionType.MarkedEscort:
			return "#RANKED_POINT_DESC_MARKED_ESCORT"
	}
}

function InitRankIcon( rankElem )
{
	rankElem.s.artImage 		<- rankElem.GetChild( "ArtImage" )
}

function SizeX( menuSize, val )
{
	return val * menuSize[0] / 1280
}

function SizeY( menuSize, val )
{
	return val * menuSize[1] / 768
}

function EOGRanked_FooterData( footerData )
{
	footerData.gamepad.append( { label = "#B_BUTTON_BACK" } )
	footerData.pc.append( { label = "#BACK", func = PCBackButton_Activate } )

	if ( IsFullyConnected() && GetPersistentVar( "ranked.matchValid" ) == "true" )
	{
		footerData.gamepad.append( { label = "#Y_BUTTON_CHANGE_COMPARISON" } )
		footerData.pc.append( { label = "#CHANGE_COMPARISON", func = Bind(CycleRankPage) } )
	}
}
Globalize( EOGRanked_FooterData )

function GetNextRankPage()
{
	if ( file.currentPage + 1 < file.pages.len() )
		file.currentPage++
	else
		file.currentPage = 0

	return file.pages[ file.currentPage ]
}
Globalize( GetNextRankPage )

function CycleRankPage(...)
{
	CycleRankPageInternal()
}
Globalize( CycleRankPage )

function CycleRankPageInternal()
{
	if ( !IsFullyConnected() )
		return

	if ( !file.menuAnimDone )
		OpenRankedMenuStatic()

	Signal( menu, "StopMenuAnimation" )
	file.currentPage = GetNextRankPage()

	UpdatePageTitle()
	thread ShowPerformanceBreakdown( true, file.currentPage )
	UpdateFooterButtons()
}
Globalize( CycleRankPageInternal )

function UpdatePageTitle()
{
	local pageTitleElem = GetElem( menu, "PageTitle" )

	local msg
	if ( file.RankedHud.IsVisible() )
	{
		msg = "#PAGE_TITLE_MATCH_RESULTS"
	}
	else
	{
		switch ( file.currentPage )
		{
			case eEOGRankPage.ALL_PLAYERS:
				msg = "#PAGE_TITLE_ALL_PLAYERS"
				break

			case eEOGRankPage.MY_TEAM:
				msg = "#PAGE_TITLE_TEAMMATES"
				break

			case eEOGRankPage.ENEMY_TEAM:
				msg = "#PAGE_TITLE_OPPONENTS"
				break
		}
	}

	pageTitleElem.SetText( msg )

	pageTitleElem.Show()
}

function GetGemIndicatorPos( gemIndex )
{
	local nextGemPanel = file.activeProgressPanel.GetChild( "Gem" + gemIndex )
	local panelPos = nextGemPanel.GetAbsPos()

	local gemIcon = nextGemPanel.GetChild( "GemImage" )
	local gemIconPos = gemIcon.GetPos()
	local gemIconHeight = gemIcon.GetHeight()

	local indicatorPos = panelPos
	indicatorPos[0] += gemIconPos[0]
	indicatorPos[1] += gemIconPos[1] + (gemIconHeight * 0.7)

	return indicatorPos
}