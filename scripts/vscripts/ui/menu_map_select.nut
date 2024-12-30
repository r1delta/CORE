
const MAP_LIST_VISIBLE_ROWS = 17
const MAP_LIST_SCROLL_SPEED = 0

function main()
{
	Globalize( InitMapsMenu )
	Globalize( OnOpenMapsMenu )
	Globalize( OnCloseMapsMenu )

	RegisterSignal( "OnCloseMapsMenu" )
}

function InitMapsMenu()
{
	file.menu <- GetMenu( "MapsMenu" )
	local menu = file.menu

	AddEventHandlerToButtonClass( menu, "MapButtonClass", UIE_GET_FOCUS, Bind( MapButton_Focused ) )
	AddEventHandlerToButtonClass( menu, "MapButtonClass", UIE_LOSE_FOCUS, Bind( MapButton_LostFocus ) )
	AddEventHandlerToButtonClass( menu, "MapButtonClass", UIE_CLICK, Bind( MapButton_Activate ) )
	AddEventHandlerToButtonClass( menu, "MapListScrollUpClass", UIE_CLICK, Bind( OnMapListScrollUp_Activate ) )
	AddEventHandlerToButtonClass( menu, "MapListScrollDownClass", UIE_CLICK, Bind( OnMapListScrollDown_Activate ) )

	file.starsLabel <- menu.GetChild( "StarsLabel" )
	file.star1 <- menu.GetChild( "MapStar0" )
	file.star2 <- menu.GetChild( "MapStar1" )
	file.star3 <- menu.GetChild( "MapStar2" )

	file.buttons <- GetElementsByClassname( menu, "MapButtonClass" )
	foreach ( button in file.buttons )
		button.s.dlcGroup <- null

	file.numMapButtonsOffScreen <- null
	file.mapListScrollState <- 0
}

function OnOpenMapsMenu()
{
	local buttons = file.buttons
	local mapsArray = GetPrivateMatchMaps()

	file.numMapButtonsOffScreen = mapsArray.len() - MAP_LIST_VISIBLE_ROWS
	Assert( file.numMapButtonsOffScreen >= 0 )

	foreach ( button in buttons )
	{
		local buttonID = button.GetScriptID().tointeger()

		if ( buttonID >= 0 && buttonID < GetPrivateMatchMaps().len() )
		{
			if (GetModeNameForEnum(level.ui.privatematch_mode) == "campaign_carousel") {
				button.SetText( GetCampaignMapDisplayName( mapsArray[buttonID] ) )
			} else {
				button.SetText( GetMapDisplayName( mapsArray[buttonID] ) )
			}

			button.SetEnabled( true )
			button.s.dlcGroup = GetDLCMapGroupForMap( mapsArray[buttonID] )
		}
		else
		{
			button.SetText( "" )
			button.SetEnabled( false )
		}

		if ( buttonID == level.ui.privatematch_map )
		{
			printt( buttonID, mapsArray[buttonID] )
			button.SetFocused()
		}
	}

	file.starsLabel.Hide()
	file.star1.Hide()
	file.star2.Hide()
	file.star3.Hide()

	RegisterButtonPressedCallback( MOUSE_WHEEL_UP, OnMapListScrollUp_Activate )
	RegisterButtonPressedCallback( MOUSE_WHEEL_DOWN, OnMapListScrollDown_Activate )

	UpdateDLCMapButtons()

	thread MonitorDLCAvailability()
}

function UpdateDLCMapButtons()
{
	local buttons = file.buttons

	foreach ( button in buttons )
	{
		if ( button.s.dlcGroup == null || button.s.dlcGroup < 1 )
			continue

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

function OnCloseMapsMenu()
{
	DeregisterButtonPressedCallback( MOUSE_WHEEL_UP, OnMapListScrollUp_Activate )
	DeregisterButtonPressedCallback( MOUSE_WHEEL_DOWN, OnMapListScrollDown_Activate )

	Signal( uiGlobal.signalDummy, "OnCloseMapsMenu" )
}

function MapButton_Focused( button )
{
	local buttonID = button.GetScriptID().tointeger()

	local menu = file.menu
	local nextMapImage = menu.GetChild( "NextMapImage" )
	local nextMapName = menu.GetChild( "NextMapName" )
	local nextMapDesc = menu.GetChild( "NextMapDesc" )

	local mapsArray = GetPrivateMatchMaps()
	local mapName = mapsArray[buttonID]

	local mapImage = "../ui/menu/lobby/lobby_image_" + mapName
	nextMapImage.SetImage( mapImage )
	if (GetModeNameForEnum(level.ui.privatematch_mode) == "campaign_carousel") {
		nextMapName.SetText( GetCampaignMapDisplayName( mapName ) )
	} else {
		nextMapName.SetText( GetMapDisplayName( mapName ) )
	}
	nextMapDesc.SetText( GetMapDisplayDesc( mapName ) )

	if ( !IsPrivateMatch() )
	{
		file.starsLabel.Show()
		UpdateSelectedMapStarData( menu, mapName, "coop" )
	}

	// Update window scrolling if we highlight a map not in view
	local minScrollState = clamp( buttonID - (MAP_LIST_VISIBLE_ROWS - 1), 0, file.numMapButtonsOffScreen )
	local maxScrollState = clamp( buttonID, 0, file.numMapButtonsOffScreen )

	if ( file.mapListScrollState < minScrollState )
		file.mapListScrollState = minScrollState
	if ( file.mapListScrollState > maxScrollState )
		file.mapListScrollState = maxScrollState

	UpdateMapListScroll()
	delaythread( 0.02 ) UpdateMapButtonTooltip( button ) // Hacky delay needed or tooltip position will use the button position prior to scroll offset
}

function MapButton_LostFocus( button )
{
	HandleLockedCustomMenuItem( file.menu, button, [], true )
}

function MapButton_Activate( button )
{
	if ( button.IsLocked() )
	{
		if ( !IsDLCMapGroupEnabledForLocalPlayer( button.s.dlcGroup ) )
			ShowDLCStore()

		return
	}

	local mapsArray = GetPrivateMatchMaps()
	local mapID = button.GetScriptID().tointeger()
	local mapName = mapsArray[mapID]

	printt( mapName, mapID )

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

function GetPrivateMatchMaps()
{
	if (GetModeNameForEnum(level.ui.privatematch_mode) == "campaign_carousel") {
		local campaignMaps = ["mp_fracture","mp_colony","mp_relic","mp_angel_city","mp_outpost_207","mp_boneyard","mp_airbase","mp_corporate"]
		return campaignMaps
	}
	local mapsArray = []
	mapsArray.resize( getconsttable().ePrivateMatchMaps.len() )

	foreach ( k, v in getconsttable().ePrivateMatchMaps )
		mapsArray[v] = k

	return mapsArray
}

function OnMapListScrollUp_Activate(...)
{
	file.mapListScrollState--
	if ( file.mapListScrollState < 0 )
		file.mapListScrollState = 0

	UpdateMapListScroll()
}

function OnMapListScrollDown_Activate(...)
{
	file.mapListScrollState++
	if ( file.mapListScrollState > file.numMapButtonsOffScreen )
		file.mapListScrollState = file.numMapButtonsOffScreen

	UpdateMapListScroll()
}

function UpdateMapListScroll()
{
	local buttons = file.buttons
	local basePos = buttons[0].GetBasePos()
	local offset = buttons[0].GetHeight() * file.mapListScrollState

	buttons[0].SetPos( basePos[0], basePos[1] - offset )
}