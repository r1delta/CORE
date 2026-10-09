
const MAP_GRID_COLUMNS = 3
const MAP_GRID_ROWS = 3
const MAP_GRID_TILES = 9 // MAP_GRID_COLUMNS * MAP_GRID_ROWS
const MAP_GRID_PAGE_ROWS = 3 // one page = the rows visible at once

// Map preview column (thumbnail, name, description), in menu units (see MapInfoBackground / NextMapDesc in map_select.menu)
const MAP_INFO_MIN_HEIGHT = 108
const MAP_INFO_DESC_OFFSET = 35 // description top relative to the backdrop top
const MAP_INFO_PADDING = 8 // space below the description
const MAP_INFO_PACK_SHIFT = 10 // how far the description moves down when the pack line is shown
const MAP_INFO_TEXT_INSET = 7 // map name / description left edge relative to the backdrop left edge
const MAP_INFO_TEXT_MARGIN = 3 // space kept free to the right of the map name

const MAP_GRID_REPEAT_DELAY = 0.4 // seconds before a held stick / d-pad direction starts repeating scrolls
const MAP_GRID_REPEAT_RATE = 0.1 // seconds between repeated scrolls

function main()
{
	Globalize( InitMapsMenu )
	Globalize( OnOpenMapsMenu )
	Globalize( OnCloseMapsMenu )
	Globalize( OpenMapVoteMenu )

	RegisterSignal( "OnCloseMapsMenu" )
}

function InitMapsMenu()
{
	file.menu <- GetMenu( "MapsMenu" )
	local menu = file.menu

	AddEventHandlerToButtonClass( menu, "MapButtonClass", UIE_GET_FOCUS, Bind( MapButton_Focused ) )
	AddEventHandlerToButtonClass( menu, "MapButtonClass", UIE_LOSE_FOCUS, Bind( MapButton_LostFocus ) )
	AddEventHandlerToButtonClass( menu, "MapButtonClass", UIE_CLICK, Bind( MapButton_Activate ) )
	AddEventHandlerToButtonClass( menu, "MapPageUpClass", UIE_CLICK, Bind( OnMapListPageUp_Activate ) )
	AddEventHandlerToButtonClass( menu, "MapPageDownClass", UIE_CLICK, Bind( OnMapListPageDown_Activate ) )
	AddEventHandlerToButtonClass( menu, "MapRandomClass", UIE_CLICK, Bind( OnRandomMapButton_Activate ) )

	file.starsLabel <- menu.GetChild( "StarsLabel" )
	file.star1 <- menu.GetChild( "MapStar0" )
	file.star2 <- menu.GetChild( "MapStar1" )
	file.star3 <- menu.GetChild( "MapStar2" )
	file.infoDesc <- menu.GetChild( "NextMapDesc" )
	file.packLabel <- menu.GetChild( "NextMapPack" )
	file.descBasePos <- file.infoDesc.GetBasePos()
	file.descShift <- 0 // menu units
	// The same name in three fonts, largest first; FitMapName() shows the largest one that fits the box
	file.nameLabels <- [ menu.GetChild( "NextMapName" ), menu.GetChild( "NextMapNameMed" ), menu.GetChild( "NextMapNameSmall" ) ]
	file.infoBackdrop <- menu.GetChild( "MapInfoBackground" )

	// Buttons that got an event handler above are already created as elements; GetChild() on them throws.
	// Look them up by classname instead.
	file.pagingElems <- []
	foreach ( className in [ "MapPageUpClass", "MapPageDownClass" ] )
		file.pagingElems.extend( GetElementsByClassname( menu, className ) )

	// Page glyphs: mouse wheel images for mouse and keyboard, shoulder button glyphs while a controller is in use
	file.mouseGlyphs <- GetElementsByClassname( menu, "MapPagingGlyphClass" )
	file.padGlyphs <- GetElementsByClassname( menu, "MapPagingGamepadGlyphClass" )
	foreach ( elem in file.padGlyphs )
		elem.EnableKeyBindingIcons() // Without this the glyph tokens in the label text are drawn literally
	file.controllerGlyphs <- null
	file.randomHint <- menu.GetChild( "RandomMapGamepadHint" )
	file.randomHint.EnableKeyBindingIcons()
	file.randomPending <- false

	file.pageLabel <- menu.GetChild( "PageLabel" )
	file.pagingElems.append( file.pageLabel )

	// file.tiles is indexed by scriptID: slot 0 is the top-left tile, slots run left to right, then top to bottom
	file.tiles <- []
	file.tiles.resize( MAP_GRID_TILES )
	foreach ( button in GetElementsByClassname( menu, "MapButtonClass" ) )
	{
		button.s.mapName <- null
		button.s.dlcGroup <- 0
		file.tiles[ button.GetScriptID().tointeger() ] = button
	}

	file.mapsArray <- []
	file.scrollRow <- 0
	file.maxScrollRow <- 0
	file.focusSlot <- 0
	file.voteType <- null // eVoteType while this menu is picking a map to vote for; null for Private Match
	file.pendingVoteType <- null
	file.voteAllowed <- true
	file.randomButton <- GetElementsByClassname( menu, "MapRandomClass" )[0]
}

function OnOpenMapsMenu()
{
	// OpenMapVoteMenu() queues the vote type; a plain re-open of an already voting menu keeps it
	if ( file.pendingVoteType != null )
		file.voteType = file.pendingVoteType
	file.pendingVoteType = null

	// Votes only exist inside a match; the lobby always shows the Private Match map list, whatever state was left behind
	if ( IsLobby() )
		file.voteType = null
	file.voteAllowed = true
	file.randomPending = false

	file.mapsArray = GetPrivateMatchMaps()

	local totalRows = ( file.mapsArray.len() + MAP_GRID_COLUMNS - 1 ) / MAP_GRID_COLUMNS
	file.maxScrollRow = totalRows - MAP_GRID_ROWS
	if ( file.maxScrollRow < 0 )
		file.maxScrollRow = 0

	// Open with the currently selected map in the middle row so there is context above and below it
	file.scrollRow = 0
	file.focusSlot = 0
	local currentMap = GetCurrentMapName()
	local currentIndex = null
	foreach ( index, mapName in file.mapsArray )
	{
		if ( mapName == currentMap )
		{
			currentIndex = index
			break
		}
	}

	if ( currentIndex != null )
	{
		file.scrollRow = clamp( currentIndex / MAP_GRID_COLUMNS - 1, 0, file.maxScrollRow )
		file.focusSlot = currentIndex - file.scrollRow * MAP_GRID_COLUMNS
	}

	local paged = file.maxScrollRow > 0
	foreach ( elem in file.pagingElems )
		elem.SetVisible( paged )

	file.controllerGlyphs = null
	UpdatePagingGlyphs()

	RefreshMapTiles()
	file.tiles[ file.focusSlot ].SetFocused()

	file.starsLabel.Hide()
	file.star1.Hide()
	file.star2.Hide()
	file.star3.Hide()

	RegisterMapGridInput()

	UpdateDLCMapButtons()

	if ( IsMapVoteMode() )
		thread MonitorVoteAvailability()
	else
		thread MonitorDLCAvailability()

	thread MonitorControllerMode()
}

function OnCloseMapsMenu()
{
	Signal( uiGlobal.signalDummy, "OnCloseMapsMenu" )

	DeregisterMapGridInput()

	file.voteType = null
}

// The engine throws when a callback is registered twice or deregistered when it is not registered.
// Menus can be left without OnClose running (level change, disconnect), so both directions are guarded.
function RegisterMapGridInput()
{
	foreach ( binding in GetMapGridInputBindings() )
	{
		try
		{
			RegisterButtonPressedCallback( binding[0], binding[1] )
		}
		catch ( e )
		{
		}
	}
}

function DeregisterMapGridInput()
{
	foreach ( binding in GetMapGridInputBindings() )
	{
		try
		{
			DeregisterButtonPressedCallback( binding[0], binding[1] )
		}
		catch ( e )
		{
		}
	}
}

function GetMapGridInputBindings()
{
	return [
		[ MOUSE_WHEEL_UP, OnMapListScrollUp_Activate ],
		[ MOUSE_WHEEL_DOWN, OnMapListScrollDown_Activate ],
		[ KEY_UP, OnMapGridNavUp ],
		[ KEY_DOWN, OnMapGridNavDown ],
		[ KEY_PAGEUP, OnMapListPageUp_Activate ],
		[ KEY_PAGEDOWN, OnMapListPageDown_Activate ],
	]
}

function IsMapVoteMode()
{
	return file.voteType != null
}

// Opens this menu to pick the target of a "Change Level" / "Next Level" vote instead of a Private Match map
function OpenMapVoteMenu( voteType )
{
	file.pendingVoteType = voteType
	AdvanceMenu( file.menu )
}

function GetCurrentMapName()
{
	if ( IsMapVoteMode() )
		return GetActiveLevel()

	return GetPrivateMatchMapNameForEnum( level.ui.privatematch_map )
}

function IsCampaignMapList()
{
	if ( IsMapVoteMode() )
		return GetCurrentPlaylistName() == CAMPAIGN

	return GetModeNameForEnum( level.ui.privatematch_mode ) == "campaign_carousel"
}

function GetMapListDisplayName( mapName )
{
	if ( IsCampaignMapList() )
		return GetCampaignMapDisplayName( mapName )

	return GetMapDisplayName( mapName )
}

function GetMapListImage( mapName )
{
	return "../loadscreens/" + mapName + "_widescreen"
}

// Fills every tile from the window of file.mapsArray starting at file.scrollRow
function RefreshMapTiles()
{
	local firstIndex = file.scrollRow * MAP_GRID_COLUMNS

	for ( local slot = 0; slot < MAP_GRID_TILES; slot++ )
	{
		local button = file.tiles[ slot ]
		local index = firstIndex + slot

		if ( index >= file.mapsArray.len() )
		{
			button.s.mapName = null
			button.s.dlcGroup = 0
			button.SetLocked( false )
			button.SetEnabled( false )
			button.SetVisible( false )
			continue
		}

		local mapName = file.mapsArray[ index ]
		local displayName = GetMapListDisplayName( mapName )

		button.s.mapName = mapName
		button.s.dlcGroup = IsMapVoteMode() ? 0 : GetDLCMapGroupForMap( mapName )

		button.GetChild( "MapImage" ).SetImage( GetMapListImage( mapName ) )

		button.GetChild( "MapName" ).SetText( displayName )
		ShowTileName( button )

		button.SetEnabled( true )
		button.SetVisible( true )
	}

	UpdateDLCMapButtons()

	local lastIndex = min( firstIndex + MAP_GRID_TILES, file.mapsArray.len() )
	file.pageLabel.SetText( "MAPS " + ( firstIndex + 1 ) + "-" + lastIndex + " OF " + file.mapsArray.len() )
}

function UpdateDLCMapButtons()
{
	foreach ( button in file.tiles )
	{
		if ( IsMapVoteMode() )
		{
			button.SetLocked( !file.voteAllowed )
			continue
		}

		if ( button.s.dlcGroup < 1 )
		{
			button.SetLocked( false )
			continue
		}

		if ( ServerHasDLCMapGroupEnabled( button.s.dlcGroup ) )
			button.SetLocked( false )
		else
			button.SetLocked( true )

		if ( button.IsFocused() )
			UpdateMapButtonTooltip( button )
	}
}

function UpdateMapButtonTooltip( button )
{
	local menu = file.menu

	if ( button.s.dlcGroup > 0 )
	{
		if ( !IsDLCMapGroupEnabledForLocalPlayer( button.s.dlcGroup ) )
			HandleLockedCustomMenuItem( menu, button, ["#DLC_REQUIRED"] )
		else if ( !ServerHasDLCMapGroupEnabled( button.s.dlcGroup ) )
			HandleLockedCustomMenuItem( menu, button, ["#NOT_OWNED_BY_ALL_PLAYERS"] )
		else
			HandleLockedCustomMenuItem( menu, button, [], true )
	}
}

function MapButton_Focused( button )
{
	file.focusSlot = button.GetScriptID().tointeger()

	local mapName = button.s.mapName
	if ( mapName == null )
		return

	local menu = file.menu
	local nextMapImage = menu.GetChild( "NextMapImage" )
	local nextMapDesc = menu.GetChild( "NextMapDesc" )

	nextMapImage.SetImage( GetMapListImage( mapName ) )
	local displayName = GetMapListDisplayName( mapName )
	foreach ( label in file.nameLabels )
		label.SetText( displayName )
	// Pick the font now, in this frame, so the title is never blank; FitMapName() corrects it if the width changes once laid out
	ApplyMapNameFit()
	thread FitMapName()
	UpdateMapPackLine( mapName )
	if ( IsCampaignMapList() )
		nextMapDesc.SetText( "#" + mapName + "_CAMPAIGN_MENU_DESC" )
	else
		nextMapDesc.SetText( GetMapDisplayDesc( mapName ) )

	thread ResizeMapInfoBackdrop()

	if ( !IsPrivateMatch() && !IsMapVoteMode() )
	{
		file.starsLabel.Show()
		UpdateSelectedMapStarData( menu, mapName, "coop" )
	}

	UpdateMapButtonTooltip( button )
}

function MapButton_LostFocus( button )
{
	HandleLockedCustomMenuItem( file.menu, button, [], true )

	// The engine hides the focus group's children (including the name) as focus leaves; the names should always show.
	// Re-show them once the engine is done with the focus change.
	delaythread( 0.05 ) ShowTileName( button )
}

function ShowTileName( button )
{
	button.GetChild( "MapNameBG" ).SetVisible( true )
	button.GetChild( "MapName" ).SetVisible( true )
}

function MapButton_Activate( button )
{
	if ( button.IsLocked() )
	{
		if ( !IsMapVoteMode() && !IsDLCMapGroupEnabledForLocalPlayer( button.s.dlcGroup ) )
			ShowDLCStore()

		return
	}

	ChooseMap( button.s.mapName )
}

// Picks a random map from the current list, skipping the special maps (Box, M.I.A, Certification, Nest), DLC maps the
// server can't use, and the map that is already selected. They can still be picked by hand.
function OnRandomMapButton_Activate( button )
{
	local currentMap = GetCurrentMapName()
	local skipMaps = { mp_box = true, mp_mia = true, mp_npe = true, mp_nest2 = true }
	local candidates = []

	foreach ( mapName in file.mapsArray )
	{
		if ( mapName in skipMaps )
			continue

		local dlcGroup = GetDLCMapGroupForMap( mapName )
		if ( dlcGroup > 0 && !ServerHasDLCMapGroupEnabled( dlcGroup ) )
			continue

		if ( mapName != currentMap )
			candidates.append( mapName )
	}

	if ( candidates.len() == 0 )
		return

	ChooseMap( Random( candidates ) )
}

function ChooseMap( mapName )
{
	printt( "Selected map: " + mapName )

	if ( IsMapVoteMode() )
	{
		ClientCommand( "StartVote " + file.voteType + " " + mapName )
		CloseAllInGameMenus()
		return
	}

	SetCoopCreateAMatchMapname( mapName )

	ClientCommand( "SetCustomMap " + mapName )
	CloseTopMenu()
}

function MonitorDLCAvailability()
{
	EndSignal( uiGlobal.signalDummy, "OnCloseMapsMenu" )

	local available = [ null, null, null ]
	local lastAvailable = clone available
	local doUpdate

	while ( 1 )
	{
		doUpdate = false

		for ( local i = 0; i < 3; i++ )
		{
			available[i] = ServerHasDLCMapGroupEnabled( i + 1 ) // 1-3

			if ( available[i] != lastAvailable[i] )
			{
				lastAvailable[i] = available[i]
				doUpdate = true
			}
		}

		if ( doUpdate )
			UpdateDLCMapButtons()

		WaitFrameOrUntilLevelLoaded()
	}
}

// Votes can only be started when the server allows it; lock the tiles while it doesn't
function MonitorVoteAvailability()
{
	EndSignal( uiGlobal.signalDummy, "OnCloseMapsMenu" )

	while ( 1 )
	{
		local allowed = CanCreateVoteOfType( file.voteType, null )
		if ( allowed != file.voteAllowed )
		{
			file.voteAllowed = allowed
			UpdateDLCMapButtons()
		}

		wait 1.0
	}
}

// The nine maps the Campaign missions are played on, in mission order
function GetCampaignMaps()
{
	return [
		"mp_fracture",
		"mp_colony",
		"mp_relic",
		"mp_angel_city",
		"mp_outpost_207",
		"mp_boneyard",
		"mp_airbase",
		"mp_o2",
		"mp_corporate",
	]
}

function GetPrivateMatchMaps()
{
	if ( IsMapVoteMode() )
		return GetMapVoteOptions()

	local modeName = GetModeNameForEnum( level.ui.privatematch_mode )
	if ( modeName == "campaign_carousel" )
		return GetCampaignMaps()

	local mapsArray = []
	mapsArray.resize( getconsttable().ePrivateMatchMaps.len() )

	foreach ( mapName, mapID in getconsttable().ePrivateMatchMaps )
		mapsArray[mapID] = mapName

	if ( modeName != VARIETY_PACK && modeName != "all_mini" )
		return mapsArray

	local supportedMaps = {}
	foreach ( combo in GetPlaylistCombos( modeName ) )
	{
		if ( !( combo.mapName in supportedMaps ) )
			supportedMaps[combo.mapName] <- true
	}

	local filteredMaps = []
	foreach ( mapName in mapsArray )
	{
		if ( mapName in supportedMaps )
			filteredMaps.append( mapName )
	}

	return filteredMaps
}

// Returns the grid slot of the focused map tile, or null when focus is elsewhere (scroll arrows, page buttons, footer)
function GetFocusedSlot()
{
	foreach ( slot, button in file.tiles )
	{
		if ( button.IsFocused() )
			return slot
	}

	return null
}

// Moves the visible window by rowDelta rows. Keeps focus on the same column when a tile is focused.
function ScrollMapGrid( rowDelta )
{
	if ( uiGlobal.activeMenu != file.menu )
		return

	local newRow = clamp( file.scrollRow + rowDelta, 0, file.maxScrollRow )
	if ( newRow == file.scrollRow )
		return

	local focusedSlot = GetFocusedSlot()

	file.scrollRow = newRow
	RefreshMapTiles()

	if ( focusedSlot == null )
		return

	// The last page can have empty tiles; fall back to the last map that is still shown
	local shownTiles = min( file.mapsArray.len() - file.scrollRow * MAP_GRID_COLUMNS, MAP_GRID_TILES )
	local targetSlot = min( focusedSlot, shownTiles - 1 )
	local target = file.tiles[ targetSlot ]

	if ( target.IsFocused() )
		MapButton_Focused( target ) // Same tile, new map: refresh the preview
	else
		target.SetFocused()
}

function OnMapListScrollUp_Activate(...)
{
	ScrollMapGrid( -1 )
}

function OnMapListScrollDown_Activate(...)
{
	ScrollMapGrid( 1 )
}

function OnMapListPageUp_Activate(...)
{
	ScrollMapGrid( -MAP_GRID_PAGE_ROWS )
}

function OnMapListPageDown_Activate(...)
{
	ScrollMapGrid( MAP_GRID_PAGE_ROWS )
}

// Up on the top row / down on the bottom row scrolls the grid instead of leaving it
function OnMapGridNavUp(...)
{
	local slot = GetFocusedSlot()
	if ( slot != null && slot < MAP_GRID_COLUMNS )
		ScrollMapGrid( -1 )
}

function OnMapGridNavDown(...)
{
	local slot = GetFocusedSlot()
	if ( slot != null && slot >= MAP_GRID_TILES - MAP_GRID_COLUMNS )
		ScrollMapGrid( 1 )
}

// Where a map comes from, if it is not a plain multiplayer map: the map packs, the Titanfall Online maps, the maps that
// only exist in R1Delta, and the maps the Titanfall Campaign is played on. Returns a localization token, or null.
function GetMapPackToken( mapName )
{
	switch ( GetDLCMapGroupForMap( mapName ) )
	{
		case 1:
			return "#MAP_PACK_1"
		case 2:
			return "#MAP_PACK_2"
		case 3:
			return "#MAP_PACK_3"
	}

	switch ( mapName )
	{
		case "mp_box":
		case "mp_nest2":
		case "mp_mia":
			return "#MAP_PACK_TFO"
		case "mp_npe":
			return "#MAP_PACK_R1DELTA"
	}

	foreach ( campaignMap in GetCampaignMaps() )
	{
		if ( campaignMap == mapName )
			return "#MAP_PACK_CAMPAIGN"
	}

	return null
}

// The pack line sits between the map name and its description; the description makes room for it. Campaign missions
// are not maps from a pack, so they never show it.
function UpdateMapPackLine( mapName )
{
	local token = IsCampaignMapList() ? null : GetMapPackToken( mapName )

	file.descShift = token == null ? 0 : MAP_INFO_PACK_SHIFT
	file.packLabel.SetVisible( token != null )
	if ( token != null )
		file.packLabel.SetText( token )

	local scale = GetContentScaleFactor( file.menu )[1]
	file.infoDesc.SetPos( file.descBasePos[0], file.descBasePos[1] + file.descShift * scale )
}

// Long names (some Campaign missions) would be cut off at the default size, so show the largest font whose text fits.
// The labels size themselves to their text, so their width is the true text width.
function ApplyMapNameFit()
{
	local scale = GetContentScaleFactor( file.menu )[0]
	local available = file.infoBackdrop.GetWidth() - ( MAP_INFO_TEXT_INSET + MAP_INFO_TEXT_MARGIN ) * scale
	local chosen = file.nameLabels.len() - 1 // nothing fits: use the smallest
	foreach ( index, label in file.nameLabels )
	{
		if ( label.GetWidth() <= available )
		{
			chosen = index
			break
		}
	}

	foreach ( index, label in file.nameLabels )
		label.SetAlpha( index == chosen ? 255 : 0 )
}

// ApplyMapNameFit() already ran in the frame the name was set. A label can report its new width a few frames after SetText,
// so wait at least three frames, then until the reading stops changing, and fit again. The title stays visible throughout.
function FitMapName()
{
	EndSignal( uiGlobal.signalDummy, "OnCloseMapsMenu" )

	local lastWidth = -1
	for ( local i = 0; i < 10; i++ )
	{
		WaitFrame()
		local width = file.nameLabels[0].GetWidth()
		if ( i >= 2 && width == lastWidth )
			break
		lastWidth = width
	}

	ApplyMapNameFit()
}

// The description label sizes itself to its text; stretch the backdrop to match (never below its base height)
function ResizeMapInfoBackdrop()
{
	EndSignal( uiGlobal.signalDummy, "OnCloseMapsMenu" )

	WaitFrame() // The label is only re-measured after the text change has been laid out

	local scale = GetContentScaleFactor( file.menu )[1]
	local contentHeight = ( MAP_INFO_DESC_OFFSET + file.descShift + MAP_INFO_PADDING ) * scale + file.infoDesc.GetHeight()
	file.infoBackdrop.SetHeight( max( MAP_INFO_MIN_HEIGHT * scale, contentHeight ) )
}

function GetMapVoteOptions()
{
	local playlist = GetCurrentPlaylistName()
	local mapsArray = GetPlaylistUniqueMaps( playlist )

	if ( playlist != CAPTURE_POINT && playlist != COOPERATIVE && playlist != CAMPAIGN )
	{
		mapsArray.append( "mp_mia" )
		mapsArray.append( "mp_nest2" )
		mapsArray.append( "mp_box" )
		mapsArray.append( "mp_npe" )
	}

	return mapsArray
}

// Shows the wheel or the shoulder button glyphs (next to PREVIOUS PAGE / NEXT PAGE) for the active input device
function UpdatePagingGlyphs()
{
	local controller = IsControllerModeActive()
	if ( controller == file.controllerGlyphs )
		return

	file.controllerGlyphs = controller

	local paged = file.maxScrollRow > 0
	foreach ( elem in file.mouseGlyphs )
		elem.SetVisible( paged && !controller )
	foreach ( elem in file.padGlyphs )
		elem.SetVisible( paged && controller )

	// RANDOM MAP: a button for mouse and keyboard, a "Y  Random Map" footer-style hint for controllers (Y presses it).
	// Neither is offered when voting for a map.
	local randomAllowed = !IsMapVoteMode()
	file.randomButton.SetVisible( randomAllowed && !controller )
	file.randomHint.SetVisible( randomAllowed && controller )
	if ( controller )
		file.randomHint.SetText( "#MAP_RANDOM_GLYPH" ) // Glyph tokens only resolve when the text is set while a controller is active
}

// Controller buttons are polled rather than registered with RegisterButtonPressedCallback: gamepad buttons never reach
// those callbacks while this menu is open (the menu consumes them), but InputIsButtonDown still sees them.
//
// With a controller the grid is a closed list: focus never leaves the 3x3 tiles (no arrows, page buttons or RANDOM MAP),
// and pushing the stick or d-pad past the top or bottom row scrolls like the mouse wheel. LB / RB page.
function MonitorControllerMode()
{
	EndSignal( uiGlobal.signalDummy, "OnCloseMapsMenu" )

	local pageButtons = [ BUTTON_SHOULDER_LEFT, BUTTON_SHOULDER_RIGHT, BUTTON_Y ]
	local scrollButtons = [ BUTTON_DPAD_UP, BUTTON_DPAD_DOWN, STICK1_UP, STICK1_DOWN ] // repeat while held

	local wasDown = {}
	local nextRepeat = {}
	foreach ( button in pageButtons )
		wasDown[ button ] <- InputIsButtonDown( button ) // Whatever opened the menu may still be held
	foreach ( button in scrollButtons )
	{
		wasDown[ button ] <- InputIsButtonDown( button )
		nextRepeat[ button ] <- 0
	}

	local prevSlot = GetFocusedSlot()

	while ( 1 )
	{
		UpdatePagingGlyphs()

		if ( IsControllerModeActive() && uiGlobal.activeMenu == file.menu )
		{
			foreach ( button in pageButtons )
			{
				local isDown = InputIsButtonDown( button )
				if ( isDown && !wasDown[ button ] )
				{
					if ( button == BUTTON_SHOULDER_LEFT )
						OnMapListPageUp_Activate() // LB = previous page
					else if ( button == BUTTON_SHOULDER_RIGHT )
						OnMapListPageDown_Activate() // RB = next page
					else if ( !IsMapVoteMode() )
						thread RandomMapAfterYRelease() // Y = random map (not offered when voting)
				}

				wasDown[ button ] = isDown
			}

			foreach ( button in scrollButtons )
			{
				local isDown = InputIsButtonDown( button )
				local fire = false

				if ( isDown && !wasDown[ button ] )
				{
					fire = true
					nextRepeat[ button ] = Time() + MAP_GRID_REPEAT_DELAY
				}
				else if ( isDown && Time() >= nextRepeat[ button ] )
				{
					fire = true
					nextRepeat[ button ] = Time() + MAP_GRID_REPEAT_RATE
				}

				wasDown[ button ] = isDown

				// The engine may already have moved focus this frame, so judge the edge by where focus was before the press
				if ( fire && prevSlot != null )
				{
					if ( button == BUTTON_DPAD_UP || button == STICK1_UP )
						ScrollMapGridFromSlot( -1, prevSlot )
					else
						ScrollMapGridFromSlot( 1, prevSlot )
				}
			}

			KeepFocusInMapGrid()
		}

		prevSlot = GetFocusedSlot()
		WaitFrame()
	}
}

// Scrolls one row when the focused tile is on the edge row in the direction of travel
function ScrollMapGridFromSlot( rowDelta, slot )
{
	if ( rowDelta < 0 && slot < MAP_GRID_COLUMNS )
		ScrollMapGrid( -1 )
	else if ( rowDelta > 0 && slot >= MAP_GRID_TILES - MAP_GRID_COLUMNS )
		ScrollMapGrid( 1 )
}

// Puts focus back on a tile if the engine's stick navigation moved it onto the arrows, page buttons or RANDOM MAP
function KeepFocusInMapGrid()
{
	if ( GetFocusedSlot() != null )
		return

	local shownTiles = min( file.mapsArray.len() - file.scrollRow * MAP_GRID_COLUMNS, MAP_GRID_TILES )
	if ( shownTiles < 1 )
		return

	file.tiles[ min( file.focusSlot, shownTiles - 1 ) ].SetFocused()
}


// Y picks a random map. Choosing a map closes this menu, which fires "OnCloseMapsMenu"; any thread that registered
// EndSignal on it is killed mid-close, before the menu underneath is reopened. So this runs in its own thread with no
// EndSignal. It also waits for Y to be released so the lobby's own Y shortcuts don't see the same press.
function RandomMapAfterYRelease()
{
	if ( file.randomPending )
		return

	file.randomPending = true

	while ( InputIsButtonDown( BUTTON_Y ) )
		WaitFrame()

	file.randomPending = false

	if ( uiGlobal.activeMenu == file.menu && !IsMapVoteMode() )
		OnRandomMapButton_Activate( null )
}
