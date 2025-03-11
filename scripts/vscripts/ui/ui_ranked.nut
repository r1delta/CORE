::MAX_GEMS_PER_PANEL <- 10

function main()
{
	Globalize( GetGemImageForState )
	Globalize( RankPanel_ShowRank )
	Globalize( GetPreviousSeasonHistorySize )
	Globalize( GetTierName )
	Globalize( GetRankName )
	Globalize( GetDivisionName )
}

function GetRankName( division )
{
	local nameString = "#RANK_NAME_" + division.tostring()
	return nameString.tostring()
}

function GetTierName( rank )
{
	local nameString = "#TIER_NAME_" + ((rank % 5).tointeger())
	return nameString.tostring()
}

function GetDivisionName( rank )
{
	local nameString = "#DIVISION_NAME_" + ((rank / 5).tointeger())
	return nameString.tostring()
}

function RankPanel_ShowRank( menu, panel, rank, usePreviousData = false )
{
	Assert( IsUI() )
	local nextRank = GetNextRank( rank )

	// Current Rank Icon
	local currentRankIcon = panel.GetChild( "CurrentRankIcon" )
	Assert( currentRankIcon != null )
	currentRankIcon.SetImage( GetRankImage( rank ) )
	currentRankIcon.Show()

	// Current Rank Name
	panel.GetChild( "CurrentDivision" ).SetText( GetDivisionName( rank ) )
	panel.GetChild( "CurrentTier" ).SetText( GetTierName( rank ) )

	// Next Rank Icon
	local nextRankIcon = panel.GetChild( "NextRankIcon" )
	Assert( nextRankIcon != null )
	if ( rank == MAX_RANK )
	{
		nextRankIcon.Hide()
	}
	else
	{
		nextRankIcon.SetImage( GetRankImage( nextRank ) )
		nextRankIcon.Show()
	}

	// Next Rank Name
	local nextRankHeader = panel.GetChild( "NextRankHeader" )
	local nextRankDivisionName = panel.GetChild( "NextDivision" )
	local nextRankTierName = panel.GetChild( "NextTier" )
	nextRankDivisionName.SetText( GetDivisionName( nextRank ) )
	nextRankTierName.SetText( GetTierName( nextRank ) )

	if ( rank == MAX_RANK )
	{
		nextRankIcon.Hide()
		nextRankHeader.Hide()
		nextRankDivisionName.Hide()
		nextRankTierName.Hide()
	}
	else
	{
		nextRankIcon.Show()
		nextRankHeader.Show()
		nextRankDivisionName.Show()
		nextRankTierName.Show()
	}

	// Gem status
	local gemsForRank = GetGemsForRank( rank )
	local min = GetMinGemsForRank( rank )
	local lastGemState = null
	local gemsCapturedAtRank = 0
	local gemPanels = []

	for ( local i = 0 ; i < MAX_GEMS_PER_PANEL ; i++ )
		gemPanels.append( panel.GetChild( "Gem" + i ) )

	// Get position information so we can space the visible gems evenly
	local minX = gemPanels[0].GetBasePos()[0]
	local maxX = gemPanels[MAX_GEMS_PER_PANEL - 1].GetBasePos()[0]
	local totalWidth = maxX - minX
	local spacing = totalWidth / ( gemsForRank - 1 )

	for ( local i = 0 ; i < gemsForRank ; i++ )
	{
		local gemIndex = min + i
		local gemPanel = gemPanels[i]
		gemPanel.Show()
		local gemState = GetPlayerGemState( null, gemIndex, usePreviousData )
		local gemScore = null

		if ( gemState == "gem_captured" || gemState == "gem_damaged" )
		{
			gemsCapturedAtRank++
			gemScore = GetPlayerGemScore( null, gemIndex, usePreviousData )
		}

		RankPanel_SetGemState( gemPanel, gemState, gemScore )

		// Space gems appropriately
		gemPanels[i].SetX( minX + ( spacing * i ) )

		// Next match goal and header
		local gemGoal = gemPanel.GetChild( "GemGoal" )
		gemGoal.Hide()
		local nextMatchHeader = gemPanel.GetChild( "NextMatchHeader" )
		nextMatchHeader.Hide()

		lastGemState = gemState
	}

	// Hide remaining gems
	for ( local i = gemsForRank; i < MAX_GEMS_PER_PANEL; i++ )
	{
		local gemPanel = gemPanels[i]
		gemPanel.Hide()
	}

	// Gem Header
	local gemHeaderLabel = panel.GetChild( "GemsHeader" )
	gemHeaderLabel.SetText( "#RANKED_PROGRESS_PANEL_GEM_HEADER", gemsCapturedAtRank, gemsForRank )

	// Gem goals
	local gemGoals = GetPerformanceReqForGem( GetPlayerTotalCompletedGems() )
	for ( local i = 0; i < gemsForRank; i++ )
	{
		local gemPanel = gemPanels[i]
		local goalLabel = gemPanel.GetChild( "GemGoal" )
		local nextMatchLabel = gemPanel.GetChild( "NextMatchHeader" )
		local gemImageElem = gemPanel.GetChild( "GemImage" )

		goalLabel.Hide()
		nextMatchLabel.Hide()
	}
}

function RankPanel_SetGemState( gemPanel, gemState, gemScore = null )
{
	Assert( gemPanel != null )
	printt( gemPanel )
	printt( gemState )
	printt( gemScore )
	local gemImageElem = gemPanel.GetChild( "GemImage" )
	local gemImage = GetGemImageForState( gemState )
	if(!gemImage)
	{
		return
	}
	gemImageElem.SetImage( gemImage )
	gemImageElem.Show()
}

function GetGemImageForState( gemState )
{
	local gemImage = null
	switch( gemState )
	{
		case "gem_undefeated":
		case "gem_lost":
			gemImage = "../ui/menu/rank_menus/ranked_game_icon_next"
			break
		case "gem_damaged":
			gemImage = "../ui/menu/rank_menus/ranked_game_icon_damaged"
			break
		case "gem_captured":
			gemImage = "../ui/menu/rank_menus/ranked_game_icon_success"
			break
	}
	Assert( gemImage != null )

	return gemImage
}

function GetPreviousSeasonHistorySize()
{
	Assert( IsUI() )

	local maxHistroySize = PersistenceGetArrayCount( "ranked.seasonHistory" )

	local historyCount = 0
	for ( local i = 0 ; i < maxHistroySize ; i++ )
	{
		if ( GetPersistentVar( "ranked.seasonHistory[" + i + "].season" ) > RANKED_INVALID_SEASON )
			historyCount++
	}

	return historyCount
}