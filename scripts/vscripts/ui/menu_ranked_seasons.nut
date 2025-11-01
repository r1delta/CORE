
const MAX_SEASON_BUTTONS = 26
const SEASON_BUTTON_POPOUT_FRACTION = 0.17

function main()
{
	Globalize( OnOpenRankedSeasonsMenu )
	Globalize( OnCloseRankedSeasonsMenu )

	file.menuInitComplete <- false

	file.SCROLL_START_TOP <- 2
	file.SEASONS_LIST_VISIBLE <- 5
	file.MENU_MOVE_TIME <- 0.15

	file.seasonButtons <- []
	file.buttonSpacing <- null
	file.buttonPopOutDist <- null
	file.selectedIndex <- 0
	file.numListButtonsUsed <- 0
	file.bindings <- false
}

function OnOpenRankedSeasonsMenu()
{
	if ( !IsFullyConnected() )
		return

	local menu = GetMenu( "RankedSeasonsMenu" )
	InitSeasonsMenu( menu )
	PopulateButtons()
	UpdateSelection( 0, true )

	if ( !file.bindings )
	{
		file.bindings = true
		RegisterButtonPressedCallback( MOUSE_WHEEL_UP, SeasonSelectNextUp )
		RegisterButtonPressedCallback( MOUSE_WHEEL_DOWN, SeasonSelectNextDown )
		RegisterButtonPressedCallback( KEY_UP, SeasonSelectNextUp )
		RegisterButtonPressedCallback( KEY_DOWN, SeasonSelectNextDown )
	}
}

function OnCloseRankedSeasonsMenu()
{
	if ( file.bindings )
	{
		DeregisterButtonPressedCallback( MOUSE_WHEEL_UP, SeasonSelectNextUp )
		DeregisterButtonPressedCallback( MOUSE_WHEEL_DOWN, SeasonSelectNextDown )
		DeregisterButtonPressedCallback( KEY_UP, SeasonSelectNextUp )
		DeregisterButtonPressedCallback( KEY_DOWN, SeasonSelectNextDown )
		file.bindings = false
	}
}

function InitSeasonsMenu( menu )
{
	if ( file.menuInitComplete )
		return

	local buttonPanel = GetElem( menu, "ButtonsNestedPanel" )
	for ( local i = 0 ; i < MAX_SEASON_BUTTONS ; i++ )
	{
		local button = buttonPanel.GetChild( "BtnSeason" + i )
		Assert( button != null )

		button.s.rankIcon <- button.GetChild( "RankIcon" )
		button.s.seasonLabel <- button.GetChild( "Season" )
		button.s.divisionLabel <- button.GetChild( "Division" )
		button.s.tierLabel <- button.GetChild( "Tier" )
		button.s.seasonIndex <- null

		button.AddEventHandler( UIE_CLICK, Bind( SeasonButtonClicked ) )
		button.AddEventHandler( UIE_GET_FOCUS, Bind( SeasonButtonFocused ) )

		file.seasonButtons.append( button )
	}

	GetElem( menu, "BtnScrollUpPC" ).AddEventHandler( UIE_CLICK, Bind(SeasonSelectNextUp) )
	GetElem( menu, "BtnScrollDownPC" ).AddEventHandler( UIE_CLICK, Bind(SeasonSelectNextDown) )

	file.buttonSpacing = file.seasonButtons[1].GetBasePos()[1] - file.seasonButtons[0].GetBasePos()[1]
	file.buttonPopOutDist = file.seasonButtons[0].GetBaseWidth() * SEASON_BUTTON_POPOUT_FRACTION

	file.menuInitComplete = true
}

function PopulateButtons()
{
	file.numListButtonsUsed = 0

	local maxHistroySize = PersistenceGetArrayCount( "ranked.seasonHistory" )

	for ( local i = 0 ; i < MAX_SEASON_BUTTONS ; i++ )
	{
		local button = file.seasonButtons[ i ]

		local showSeasonOnButton = i < maxHistroySize && GetPersistentVar( "ranked.seasonHistory[" + i + "].season" ) > RANKED_INVALID_SEASON

		if ( showSeasonOnButton )
		{
			button.SetEnabled( true )
			button.Show()

			button.s.seasonIndex = i

			// Rank Icon
			local rank = GetPersistentVar( "ranked.seasonHistory[" + i + "].rank" )
			button.s.rankIcon.SetImage( GetRankImage( rank ) )

			// Season, Division, Tier
			local season = GetPersistentVar( "ranked.seasonHistory[" + i + "].season" )
			if ( season < 1 )
				button.s.seasonLabel.SetText( "#RANKED_BETA_SEASON" )
			else
				button.s.seasonLabel.SetText( "#RANKED_CURRENT_SEASON_NUMBER", season )

			button.s.divisionLabel.SetText( GetDivisionName( rank ) )
			button.s.tierLabel.SetText( GetTierName( rank ) )

			file.numListButtonsUsed++
		}
		else
		{
			button.SetEnabled( false )
			button.Hide()
		}
	}
}

function UpdateSelection( index, instant = false )
{
	if ( !IsFullyConnected() )
		return

	if ( file.numListButtonsUsed == 0 )
		return

	Assert( index < file.numListButtonsUsed )
	EmitUISound( "EOGSummary.XPBreakdownPopup" )

	file.selectedIndex = index

	foreach( index, button in file.seasonButtons )
	{
		local isSelected = index == file.selectedIndex ? true : false
		button.SetSelected( isSelected )

		// Button dim
		local alpha = isSelected ? 255 : 50
		button.SetPanelAlpha( alpha )

		// Figure out button positioning
		local baseX = file.seasonButtons[0].GetBasePos()[0]
		local topY = file.seasonButtons[0].GetBasePos()[1]
		local shiftCount = max( 0, file.selectedIndex - file.SCROLL_START_TOP )
		local maxShiftCount = file.numListButtonsUsed - file.SEASONS_LIST_VISIBLE
		shiftCount = clamp( shiftCount, 0, maxShiftCount )

		// Button popout
		local goalPosX = baseX
		if ( isSelected )
			goalPosX += file.buttonPopOutDist

		// Button scroll pos
		local baseY = topY + ( file.buttonSpacing * index )
		local goalPosY = baseY - file.buttonSpacing * shiftCount

		if ( instant )
			button.SetPos( goalPosX, goalPosY )
		else
			button.MoveOverTime( goalPosX, goalPosY, file.MENU_MOVE_TIME, INTERPOLATOR_DEACCEL )
	}

	// Update stats pane to match the button ref item
	UpdateSeasonDetails( file.seasonButtons[ file.selectedIndex ].s.seasonIndex )

}

function SeasonButtonClicked( button )
{
	local id = button.GetScriptID().tointeger()
	if ( !IsControllerModeActive() )
		UpdateSelection( id )
}

function SeasonButtonFocused( button )
{
	local id = button.GetScriptID().tointeger()
	if ( IsControllerModeActive() )
		UpdateSelection( id )
}

function SeasonSelectNextUp( button )
{
	if ( file.selectedIndex == 0 )
		return
	UpdateSelection( file.selectedIndex - 1 )
}

function SeasonSelectNextDown( button )
{
	if ( file.selectedIndex + 1 >= file.numListButtonsUsed )
		return
	UpdateSelection( file.selectedIndex + 1 )
}

function UpdateSeasonDetails( index )
{
	// index is the index in persistent history array
	local menu = GetMenu( "RankedSeasonsMenu" )

	// Season
	local season = GetHistoryValue( index, "season" )
	if ( season < 1 )
		GetElem( menu, "SeasonHeader" ).SetText( "#RANKED_BETA_SEASON" )
	else
		GetElem( menu, "SeasonHeader" ).SetText( "#RANKED_CURRENT_SEASON_NUMBER", season )

	// Rank
	local rank = GetHistoryValue( index, "rank" )
	GetElem( menu, "RankIcon" ).SetImage( GetRankImage( rank ) )
	GetElem( menu, "Division" ).SetText( GetDivisionName( rank ) )
	GetElem( menu, "Tier" ).SetText( GetTierName( rank ) )

	// Season Start
	local seasonStartTime = GetHistoryValue( index, "seasonStartTime" )
	local seasonStartTimeParts = GetUnixTimeParts( seasonStartTime )
	GetElem( menu, "SeasonStart" ).SetText( "#RANKED_DATE_FORMAT", "#MONTH_" + seasonStartTimeParts["month"], seasonStartTimeParts["day"], seasonStartTimeParts["year"] )

	// Season End
	local seasonEndTime = GetHistoryValue( index, "seasonEndTime" ) - 1
	local seasonEndTimeParts = GetUnixTimeParts( seasonEndTime )
	GetElem( menu, "SeasonEnd" ).SetText( "#RANKED_DATE_FORMAT", "#MONTH_" + seasonEndTimeParts["month"], seasonEndTimeParts["day"], seasonEndTimeParts["year"] )

	// Games Played
	local gamesPlayed = GetHistoryValue( index, "gamesPlayed" )
	GetElem( menu, "GamesPlayed" ).SetText( gamesPlayed.tostring() )

	// Best Score
	//local bestRating = format( "%.1f", GetHistoryValue( index, "bestRating" ) )
	//GetElem( menu, "BestScore" ).SetText( bestRating.tostring() )

	// Highest Rank Achieved
	local highestRank = GetHistoryValue( index, "bestRank" )
	if ( highestRank == 0 && rank > highestRank )
		highestRank = rank
	local rankDisplayName = GetRankName( highestRank )
	GetElem( menu, "BestRank" ).SetText( rankDisplayName )

	local dataPoints = PersistenceGetArrayCount( "ranked.currentSeason.rankGraph" )
	local maxGems = GetMinGemsForRank( MAX_RANK ) + GetGemsForRank( MAX_RANK )
	local graphBounds = [ 0, maxGems ]
	local dataValues = []
	for ( local i = 0 ; i < dataPoints ; i++ )
	{
		local var = "rankGraph[" + i + "]"
		local value = GetHistoryValue( index, var )
		dataValues.append( value )
	}

	PlotPointsOnGraph( menu, dataPoints, "GraphDot", "GraphLine", dataValues, graphBounds )
}

function GetHistoryValue( index, var )
{
	return GetPersistentVar( "ranked.seasonHistory[" + index + "]." + var )
}