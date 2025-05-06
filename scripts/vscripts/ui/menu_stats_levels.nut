
const MAX_LIST_ITEMS = 26
const SCROLL_START_TOP = 2
const LEVEL_LIST_VISIBLE = 6
const MENU_MOVE_TIME = 0.15
const BUTTON_POPOUT_FRACTION = 0.19

pls <- {}
pls.levelMenuInitComplete <- false

pls.allMaps <- []
pls.allModes <- []

pls.buttonElems <- []
pls.buttonSpacing <- null
pls.buttonPopOutDist <- null
pls.selectedIndex <- 0
pls.numListButtonsUsed <- MAX_LIST_ITEMS

pls.campaignElems <- {}
pls.starsPanelVisible <- false
pls.bindings <- false

function main()
{
	Globalize( OnOpenViewStatsLevels )
	Globalize( OnCloseViewStatsLevels )
	Globalize( InitStats_Levels )
}

function OnOpenViewStatsLevels()
{
	local menu = GetMenu( "ViewStats_Levels_Menu" )

	UpdateLevelButtons()
	UpdateLevelButtonsForSelection( 0, true )

	if ( !pls.bindings )
	{
		pls.bindings = true
		RegisterButtonPressedCallback( MOUSE_WHEEL_UP, LevelSelectNextUp )
		RegisterButtonPressedCallback( MOUSE_WHEEL_DOWN, LevelSelectNextDown )
		RegisterButtonPressedCallback( KEY_UP, LevelSelectNextUp )
		RegisterButtonPressedCallback( KEY_DOWN, LevelSelectNextDown )
		RegisterButtonPressedCallback( BUTTON_Y, ViewStarsToggle)
	}
}

function OnCloseViewStatsLevels()
{
	if ( pls.bindings )
	{
		DeregisterButtonPressedCallback( MOUSE_WHEEL_UP, LevelSelectNextUp )
		DeregisterButtonPressedCallback( MOUSE_WHEEL_DOWN, LevelSelectNextDown )
		DeregisterButtonPressedCallback( KEY_UP, LevelSelectNextUp )
		DeregisterButtonPressedCallback( KEY_DOWN, LevelSelectNextDown )
		DeregisterButtonPressedCallback( BUTTON_Y, ViewStarsToggle )
		pls.bindings = false
	}
}

function InitStats_Levels()
{
	if ( pls.levelMenuInitComplete )
		return

	local menu = GetMenu( "ViewStats_Levels_Menu" )
	local buttonPanel = GetElem( menu, "LevelButtonsNestedPanel" )
	for ( local i = 0 ; i < MAX_LIST_ITEMS ; i++ )
	{
		local button = buttonPanel.GetChild( "BtnLevel" + i )
		Assert( button != null )

		button.s.dimOverlay <- button.GetChild( "DimOverlay" )

		button.s.levelImageNormal <- button.GetChild( "LevelImageNormal" )
		button.s.levelImageFocused <- button.GetChild( "LevelImageFocused" )
		button.s.levelImageSelected <- button.GetChild( "LevelImageSelected" )

		button.s.ref <- null

		button.AddEventHandler( UIE_CLICK, LevelButtonClicked )
		button.AddEventHandler( UIE_GET_FOCUS, LevelButtonFocused )

		pls.buttonElems.append( button )
	}

	GetElem( menu, "BtnScrollUpPC" ).AddEventHandler( UIE_CLICK, LevelSelectNextUp )
	GetElem( menu, "BtnScrollDownPC" ).AddEventHandler( UIE_CLICK, LevelSelectNextDown )

	pls.buttonSpacing = pls.buttonElems[1].GetBasePos()[1] - pls.buttonElems[0].GetBasePos()[1]
	pls.buttonPopOutDist = pls.buttonElems[0].GetBaseWidth() * BUTTON_POPOUT_FRACTION

	// Get maps list
	local numMaps = PersistenceGetEnumCount( "maps" )
	local mapName
	pls.allMaps = []
	for ( local i = 0 ; i < numMaps ; i++ )
	{
		mapName = PersistenceGetEnumItemNameForIndex( "maps", i )
		if ( mapName != "mp_box" && mapName != "mp_test_engagement_range" )
			pls.allMaps.append( mapName )
	}

	// Get modes list
	local numModes = PersistenceGetEnumCount( "gameModes" )
	local modeName
	pls.allModes = []
	for ( local i = 0 ; i < numModes ; i++ )
	{
		modeName = PersistenceGetEnumItemNameForIndex( "gameModes", i )
		pls.allModes.append( modeName )
	}

	// Get campaign elems to update for each map
	pls.campaignElems.header <- GetElem( menu, "CampaignLabelClass" )
	pls.campaignElems.background <- GetElem( menu, "CampaignBackgroundBoxClass" )
	pls.campaignElems.finishedIMCImage <- GetElem( menu, "MapIMCCompleteClass" )
	pls.campaignElems.finishedMilitiaImage <- GetElem( menu, "MapMilitiaCompleteClass" )
	pls.campaignElems.wonIMCImage <- GetElem( menu, "MapIMCWonClass" )
	pls.campaignElems.wonMilitiaImage <- GetElem( menu, "MapMilitiaWonClass" )

	pls.levelMenuInitComplete = true

	pls.mapStarsPanel <- menu.GetChild( "MapStarsDetailsPanel" )
	pls.starsLabel <- menu.GetChild( "StarsLabelGamepad" )
	pls.starsLabel.EnableKeyBindingIcons()

	ToggleStarPanelState( 0, true )
}

function LevelButtonClicked( button )
{
	local id = button.GetScriptID().tointeger()
	if ( !IsControllerModeActive() )
		UpdateLevelButtonsForSelection( id )
}

function LevelButtonFocused( button )
{
	local id = button.GetScriptID().tointeger()
	if ( IsControllerModeActive() )
		UpdateLevelButtonsForSelection( id )
}

function LevelSelectNextUp( button )
{
	if ( pls.selectedIndex == 0 )
		return
	UpdateLevelButtonsForSelection( pls.selectedIndex - 1 )
}

function LevelSelectNextDown( button )
{
	if ( pls.selectedIndex + 1 >= pls.numListButtonsUsed )
		return
	UpdateLevelButtonsForSelection( pls.selectedIndex + 1 )
}

function UpdateLevelButtons()
{
	Assert( pls.allMaps.len() > 0 && pls.allMaps.len() < MAX_LIST_ITEMS )
	pls.numListButtonsUsed = 0
	local image
	foreach( index, mapName in pls.allMaps )
	{
		local button = pls.buttonElems[ index ]
		button.SetEnabled( true )
		button.Show()

		button.s.ref = mapName
		image = "../loadscreens/" + mapName + "_widescreen"

		button.s.levelImageNormal.SetImage( image )
		button.s.levelImageFocused.SetImage( image )
		button.s.levelImageSelected.SetImage( image )

		local haveMap = IsDLCMapGroupEnabledForLocalPlayer( GetDLCMapGroupForMap( mapName ) )
		if ( !haveMap )
		{
			button.s.levelImageNormal.SetAlpha( 200 )
			button.s.levelImageFocused.SetAlpha( 200 )
			button.s.levelImageSelected.SetAlpha( 200 )
		}
		else
		{
			button.s.levelImageNormal.SetAlpha( 255 )
			button.s.levelImageFocused.SetAlpha( 255 )
			button.s.levelImageSelected.SetAlpha( 255 )
		}

		pls.numListButtonsUsed++
	}

	// Hide / Disable buttons we wont be using
	for ( local i = pls.numListButtonsUsed ; i < MAX_LIST_ITEMS ; i++ )
	{
		local button = pls.buttonElems[ i ]
		button.SetEnabled( false )
		button.Hide()
	}
}

function UpdateLevelButtonsForSelection( index, instant = false )
{
	if ( !IsFullyConnected() )
		return

	Assert( pls.selectedIndex < pls.buttonElems.len() )
	EmitUISound( "EOGSummary.XPBreakdownPopup" )

	//pls.buttonElems[ pls.selectedIndex ].s.selectOverlay.Hide()
	//pls.buttonElems[ index ].s.selectOverlay.Show()
	pls.selectedIndex = index

	pls.buttonElems[ pls.selectedIndex ].SetScale( 1.5, 1.5 )

	foreach( index, button in pls.buttonElems )
	{
		local distFromSelection = abs( index - pls.selectedIndex )

		local isSelected = index == pls.selectedIndex ? true : false
		button.SetSelected( isSelected )

		// Button dim
		local dimAlpha = GraphCapped( distFromSelection, 0, 5, 0, 150 )
		button.s.dimOverlay.SetAlpha( dimAlpha )

		// Figure out button positioning
		local baseX = pls.buttonElems[0].GetBasePos()[0]
		local topY = pls.buttonElems[0].GetBasePos()[1]
		local shiftCount = max( 0, pls.selectedIndex - SCROLL_START_TOP )
		local maxShiftCount = pls.numListButtonsUsed - LEVEL_LIST_VISIBLE
		shiftCount = clamp( shiftCount, 0, maxShiftCount )
		local shiftDist = pls.buttonSpacing * shiftCount
		if ( index < pls.selectedIndex )
			shiftDist += pls.buttonSpacing * 0.25
		else if ( index > pls.selectedIndex )
			shiftDist -= pls.buttonSpacing * 0.25

		// Button popout
		local goalPosX = baseX
		if ( distFromSelection == 0 )
			goalPosX += pls.buttonPopOutDist
		else if ( distFromSelection == 1 )
			goalPosX += pls.buttonPopOutDist * 0.2

		// Button scroll pos
		local baseY = topY + ( pls.buttonSpacing * index )
		local goalPosY = baseY - shiftDist

		if ( instant )
			button.SetPos( goalPosX, goalPosY )
		else
			button.MoveOverTime( goalPosX, goalPosY, MENU_MOVE_TIME, INTERPOLATOR_DEACCEL )
	}

	// Update stats pane to match the button ref item
	local mapName = pls.buttonElems[ pls.selectedIndex ].s.ref
	UpdateStatsForLevel( mapName )
	UpdateStarPanelData( pls.mapStarsPanel, mapName, null )
}

function UpdateCampaignElements( mapName, duration = 0.0 )
{
	local campaignIndex = GetCampaignLevelIndex( mapName )
	if ( campaignIndex == null || pls.starsPanelVisible )
	{
		pls.campaignElems.header.FadeOverTime( 0, duration, INTERPOLATOR_ACCEL )
		pls.campaignElems.background.FadeOverTime( 0, duration, INTERPOLATOR_ACCEL )
		pls.campaignElems.finishedIMCImage.FadeOverTime( 0, duration, INTERPOLATOR_ACCEL )
		pls.campaignElems.finishedMilitiaImage.FadeOverTime( 0, duration, INTERPOLATOR_ACCEL )
		pls.campaignElems.wonIMCImage.FadeOverTime( 0, duration, INTERPOLATOR_ACCEL )
		pls.campaignElems.wonMilitiaImage.FadeOverTime( 0, duration, INTERPOLATOR_ACCEL )
	}
	else
	{
		pls.campaignElems.header.FadeOverTime( 255, duration, INTERPOLATOR_ACCEL )
		pls.campaignElems.background.FadeOverTime( 255, duration, INTERPOLATOR_ACCEL )
		pls.campaignElems.header.Show()
		pls.campaignElems.background.Show()
		local alpha

		alpha = GetPersistentVar( "campaignMapFinishedIMC[" + campaignIndex + "]" ) == true ? 255 : 20

		pls.campaignElems.finishedIMCImage.FadeOverTime( alpha, duration, INTERPOLATOR_ACCEL )
		pls.campaignElems.finishedIMCImage.Show()

		alpha = GetPersistentVar( "campaignMapFinishedMCOR[" + campaignIndex + "]" ) == true ? 255 : 20
		pls.campaignElems.finishedMilitiaImage.FadeOverTime( alpha, duration, INTERPOLATOR_ACCEL )
		pls.campaignElems.finishedMilitiaImage.Show()

		alpha = GetPersistentVar( "campaignMapWonIMC[" + campaignIndex + "]" ) == true ? 255 : 20
		pls.campaignElems.wonIMCImage.FadeOverTime( alpha, duration, INTERPOLATOR_ACCEL )
		pls.campaignElems.wonIMCImage.Show()

		alpha = GetPersistentVar( "campaignMapWonMCOR[" + campaignIndex + "]" ) == true ? 255 : 20
		pls.campaignElems.wonMilitiaImage.FadeOverTime( alpha, duration, INTERPOLATOR_ACCEL )
		pls.campaignElems.wonMilitiaImage.Show()
	}
}

function UpdateStatsForLevel( mapName )
{
	local menu = GetMenu( "ViewStats_Levels_Menu" )

	// Name
	menu.GetChild( "LevelName" ).SetText( GetMapDisplayName( mapName ) )

	// Image
	local image = "../ui/menu/lobby/lobby_image_" + mapName
	local levelImageElem = menu.GetChild( "LevelImageLarge" )
	levelImageElem.SetImage( image )
	levelImageElem.SetAlpha( 255 )

	// Locked?
	local lockLabel = GetElementsByClassname( menu, "LblLevelLocked" )[0]
	lockLabel.Hide()
	local haveMap = IsDLCMapGroupEnabledForLocalPlayer( GetDLCMapGroupForMap( mapName ) )
	if ( !haveMap )
	{
		levelImageElem.SetAlpha( 200 )
		lockLabel.Show()
	}

	// Desc
	menu.GetChild( "LevelDesc" ).SetText( GetMapDisplayDesc( mapName ) )

	// Campaign stats
	UpdateCampaignElements( mapName )

	// Get required data needed for some calculations
	local hoursPlayed = 0
	local timesPlayed = 0
	local timesWon = 0
	local timesLost = 0
	local timesMVP = 0
	local timesTop3 = 0

	local timesPlayedPerMode = { other = 0 }
	local timesWonPerMode = { other = 0 }
	local timesMVPPerMode = { other = 0 }
	local basicModes = [ "tdm", "cp", "at", "lts", "ctf" ]

	foreach( modeName in pls.allModes )
	{
		if( modeName == COOPERATIVE )
			continue

		hoursPlayed += GetPersistentVar( "mapStats[" + mapName + "].hoursPlayed[" + modeName + "]" )
		timesPlayed += GetPersistentVar( "mapStats[" + mapName + "].gamesCompleted[" + modeName + "]" ).tointeger()
		timesWon += GetPersistentVar( "mapStats[" + mapName + "].gamesWon[" + modeName + "]" ).tointeger()
		timesLost += GetPersistentVar( "mapStats[" + mapName + "].gamesLost[" + modeName + "]" ).tointeger()
		timesMVP += GetPersistentVar( "mapStats[" + mapName + "].topPlayerOnTeam[" + modeName + "]" ).tointeger()
		timesTop3 += GetPersistentVar( "mapStats[" + mapName + "].top3OnTeam[" + modeName + "]" ).tointeger()

		local playedCount = GetPersistentVar( "mapStats[" + mapName + "].gamesCompleted[" + modeName + "]" )
		local wonCount = GetPersistentVar( "mapStats[" + mapName + "].gamesWon[" + modeName + "]" )
		local mvpCount = GetPersistentVar( "mapStats[" + mapName + "].topPlayerOnTeam[" + modeName + "]" )
		if ( ArrayContains( basicModes, modeName ) )
		{
			timesPlayedPerMode[ modeName ] <- playedCount
			timesWonPerMode[ modeName ] <- wonCount
			timesMVPPerMode[ modeName ] <- mvpCount
		}
		else
		{
			timesPlayedPerMode[ "other" ] += playedCount
			timesWonPerMode[ "other" ] += wonCount
			timesMVPPerMode[ "other" ] += mvpCount
		}
	}

	SetStatsLabelValue( menu, "TimePlayed", HoursToTimeString( hoursPlayed ) )
	SetStatsLabelValue( menu, "TimesPlayed", timesPlayed )
	SetStatsLabelValue( menu, "TimesWon", timesWon )
	SetStatsLabelValue( menu, "TimesLost", timesLost )
	SetStatsLabelValue( menu, "WinRate", [ "#STATS_PERCENTAGE", GetPercent( timesWon, timesPlayed, 0 ) ] )
	SetStatsLabelValue( menu, "TimesMVP", timesMVP )
	SetStatsLabelValue( menu, "TimesTop3", timesTop3 )

	// Times played
	SetStatsLabelValue( menu, "Column0Value0", timesPlayedPerMode["tdm"] )
	SetStatsLabelValue( menu, "Column0Value1", timesPlayedPerMode["cp"] )
	SetStatsLabelValue( menu, "Column0Value2", timesPlayedPerMode["at"] )
	SetStatsLabelValue( menu, "Column0Value3", timesPlayedPerMode["lts"] )
	SetStatsLabelValue( menu, "Column0Value4", timesPlayedPerMode["ctf"] )
	SetStatsLabelValue( menu, "Column0Value5", timesPlayedPerMode["other"] )

	// Times won
	SetStatsLabelValue( menu, "Column1Value0", timesWonPerMode["tdm"] )
	SetStatsLabelValue( menu, "Column1Value1", timesWonPerMode["cp"] )
	SetStatsLabelValue( menu, "Column1Value2", timesWonPerMode["at"] )
	SetStatsLabelValue( menu, "Column1Value3", timesWonPerMode["lts"] )
	SetStatsLabelValue( menu, "Column1Value4", timesWonPerMode["ctf"] )
	SetStatsLabelValue( menu, "Column1Value5", timesWonPerMode["other"] )

	// Times MVP
	SetStatsLabelValue( menu, "Column2Value0", timesMVPPerMode["tdm"] )
	SetStatsLabelValue( menu, "Column2Value1", timesMVPPerMode["cp"] )
	SetStatsLabelValue( menu, "Column2Value2", timesMVPPerMode["at"] )
	SetStatsLabelValue( menu, "Column2Value3", timesMVPPerMode["lts"] )
	SetStatsLabelValue( menu, "Column2Value4", timesMVPPerMode["ctf"] )
	SetStatsLabelValue( menu, "Column2Value5", timesMVPPerMode["other"] )
}

function ViewStarsToggle( button )
{
	EmitUISound( "EOGSummary.XPBreakdownPopup" )
	ToggleStarPanelState( !pls.starsPanelVisible )
	UpdateFooterButtons()
}

function ToggleStarPanelState( visible, instant = false )
{
	local background = pls.mapStarsPanel.GetChild( "Background" )

	local duration = instant ? 0.0 : 0.25
	local basePos = background.GetBasePos()
	local xOffset = visible ? 0 : pls.mapStarsPanel.GetWidth()
	pls.starsPanelVisible = visible

	if ( instant )
		background.SetPos( basePos[0] + xOffset, basePos[1] )
	else
		background.MoveOverTime( basePos[0] + xOffset, basePos[1], duration, INTERPOLATOR_ACCEL )

	// Hide or show other map info
	local labelsAlpha = visible ? 0 : 255

	local mapName = pls.buttonElems[ pls.selectedIndex ].s.ref
	UpdateCampaignElements( mapName, duration )

	pls.starsLabel.FadeOverTime( labelsAlpha, duration, INTERPOLATOR_ACCEL )
}

function ViewStatsLevels_FooterData( footerData )
{
	footerData.gamepad.append( { label = "#B_BUTTON_BACK" } )
	footerData.pc.append( { label = "#BACK", func = PCBackButton_Activate } )

	footerData.gamepad = AppendGamepadInviteLabels( footerData.gamepad )
	footerData.pc = AppendPCInviteLabels( footerData.pc )


	if ( pls.starsPanelVisible )
	{
		footerData.gamepad.append( { label = "#Y_BUTTON_HIDE_STARS" } )
		footerData.pc.append( { label = "#HIDE_STARS", func = ViewStarsToggle } )
	}
	else
	{
		footerData.gamepad.append( { label = "#Y_BUTTON_VIEW_STARS" } )
		footerData.pc.append( { label = "#VIEW_STARS", func = ViewStarsToggle } )
	}
}