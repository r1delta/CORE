function main()
{
    // Global functions
    Globalize( InitServerBrowserMenu )
    Globalize( OnServerBrowserMenu )
    Globalize( RefreshServerList )
	Globalize( OpenDirectConnectDialog_Activate )
    Globalize(UpdateShownPage)
    Globalize(FilterAndUpdateList)
    Globalize(FilterServerList)

    // File-level variables
    file.menu <- null
    file.buttons <- null
    file.serversName <- null
    file.playerCountLabels <- null
    file.serversMap <- null
    file.serversGamemode <- null
    file.currentChoice <- 0
    file.serverList <- []
    file.scrollOffset <- 0
    // uiGlobal.serversArrayFiltered <- []
    file.searchBox <- null
    file.hideFullBox <- null
    file.hideEmptyBox <- null

    // Search/filter state
    file.searchTerm <- ""
    file.useSearch <- false
    file.hideFull <- false
    file.hideEmpty <- false

    // Direction for sorting

}

function OpenDirectConnectDialog_Activate( button )
{
	if ( uiGlobal.activeDialog )
		return

	local dialogData = {}
	dialogData.header <- "Connect To Address..."
    dialogData.detailsMessage <- "Enter a server IP address to connect to it."

	OpenChoiceDialog( dialogData, GetMenu( "DirectConnectDialog" ) )
	// local inputs = []
	// 	// Gamepad
	// inputs.append( BUTTON_A )
	// inputs.append( BUTTON_START )

	// // Keyboard/Mouse
	// inputs.append( KEY_ENTER )

	// foreach ( input in inputs )
	// 	RegisterButtonPressedCallback( input, ConnectToDirectServer )
}

function ConnectToDirectServer( button )
{
	if ( !uiGlobal.activeDialog )
		return

    local str = uiGlobal.activeDialog.GetChild( "LblConnectTo" ).GetTextEntryUTF8Text()

	if(str == "")
		return

	ClientCommand( "connect " + str )
	CloseDialog( true )
}

function InitServerBrowserMenu( menu )
{
    uiGlobal.sortDirection <- {
        serverName = true,
        serverPlayers = true,
        serverMap = true,
        serverGamemode = true
    }
    file.menu = menu
    uiGlobal.menu <- menu
    file.dialog <- GetMenu( "DirectConnectDialog" )
    file.lblConnectTo <- file.dialog.GetChild( "LblConnectTo" )
    // Get menu elements
    file.buttons = GetElementsByClassname( menu, "ServerButton" )
    file.serversName = GetElementsByClassname( menu, "ServerName" )
    file.playerCountLabels = GetElementsByClassname( menu, "PlayerCount" )
    file.serversMap = GetElementsByClassname( menu, "ServerMap" )
    file.serversGamemode = GetElementsByClassname( menu, "ServerGamemode" )
   	file.serverList <- []
	uiGlobal.serverList <- []
    uiGlobal.serversArrayFiltered <- []
    // Setup buttons
    AddEventHandlerToButtonClass( menu, "ServerButton", UIE_CLICK, OnServerButtonClicked )
    AddEventHandlerToButtonClass( menu, "ServerButton", UIE_GET_FOCUS, OnServerButtonFocused )

    // Add handlers for filtering
    AddEventHandlerToButtonClass( menu, "BtnServerNameTab", UIE_CLICK, SortServerListByName )
    AddEventHandlerToButtonClass( menu, "BtnServerPlayersTab", UIE_CLICK, SortServerListByPlayers )
    AddEventHandlerToButtonClass( menu, "BtnServerMapTab", UIE_CLICK, SortServerListByMap )
    AddEventHandlerToButtonClass( menu, "BtnServerGamemodeTab", UIE_CLICK, SortServerListByGamemode )

    // Scroll buttons
    AddEventHandlerToButtonClass( menu, "BtnServerListUpArrow", UIE_CLICK, OnScrollUp )
    AddEventHandlerToButtonClass( menu, "BtnServerListDownArrow", UIE_CLICK, OnScrollDown )
    // Get other UI elements
    // In InitServerBrowserMenu:
    file.hideFullBox = menu.GetChild( "SwtBtnHideFull" )
    file.hideEmptyBox = menu.GetChild( "SwtBtnHideEmpty" )
    AddEventHandlerToButtonClass(menu , "SwtBtnHideFull",UIE_CLICK, HideFullHandler )
    AddEventHandlerToButtonClass(menu , "SwtBtnHideEmpty",UIE_CLICK, HideEmptyHandler )

    AddEventHandlerToButton( GetMenu( "DirectConnectDialog" ), "BtnConnect", UIE_CLICK, OnDirectConnectDialogButtonConnect_Activate )
    AddEventHandlerToButton( GetMenu( "DirectConnectDialog" ), "BtnCancel", UIE_CLICK, OnDirectConnectDialogButtonCancel_Activate )

    file.searchBox = menu.GetChild( "BtnServerSearch" )
	AddEventHandlerToButton( menu, "BtnServerSearch", UIE_LOSE_FOCUS, Bind( OnSearchBoxLooseFocus ) )

    // Initialize mouse wheel handlers
    RegisterButtonPressedCallback( MOUSE_WHEEL_UP, OnMouseWheelUp )
    RegisterButtonPressedCallback( MOUSE_WHEEL_DOWN, OnMouseWheelDown )
    // Initialize filter state
    RefreshServerList(null)

}

function OnSearchBoxLooseFocus(button)
{
    FilterAndUpdateList()
    UpdateShownPage()
}

function Threaded_GetServerList()
{
	local retries = 0

    file.serverList = []

	while(file.serverList.len() <= 0 && retries < 5) {

		local list = PollServerList()

		if(list == null)
		{
			wait 0.1
			continue
		}

		file.serverList <- list
		retries += 1
        wait 0.1
	}


	uiGlobal.serverList <- file.serverList
}


function RefreshServerList(_button)
{
    if (file.serverList == null)
        file.serverList = []

    DispatchServerListReq()
    thread Threaded_GetServerList()

    foreach(names in file.serversName)
    {
        names.SetVisible(false)
    }

    foreach(playerCount in file.playerCountLabels)
    {
        playerCount.SetVisible(false)
    }

    foreach(map in file.serversMap)
    {
        map.SetVisible(false)
    }

    foreach(gamemode in file.serversGamemode)
    {
        gamemode.SetVisible(false)
    }

    FilterAndUpdateList()
}

function FilterAndUpdateList()
{
    file.searchTerm = file.searchBox.GetTextEntryUTF8Text()
    file.useSearch = file.searchTerm != ""
    file.hideFull = file.hideFullBox.IsSelected() //file.hideFullBox.IsSelected()
    file.hideEmpty = file.hideEmptyBox.IsSelected()

    file.scrollOffset = 0
    FilterServerList()

    UpdateShownPage()
}

function FilterServerList()
{
    uiGlobal.serversArrayFiltered.clear()
    uiGlobal.serversArrayFiltered.clear()
    foreach ( server in file.serverList )
    {
        // Skip if filters don't match
        if (file.hideEmpty && server.players.len() == 0)
            continue

        if (file.hideFull && server.players.len() >= server.max_players)
            continue

        if (file.useSearch)
        {
            if (server.host_name.tolower().find(file.searchTerm.tolower()) == null)
                continue
        }

        uiGlobal.serversArrayFiltered.append(server)
    }

}

function UpdateShownPage()
{
    // uiGlobal.serversArrayFiltered.clear()
    local BUTTONS_PER_PAGE = 10

    // Reset all buttons first
    for ( local i = 0; i < BUTTONS_PER_PAGE; i++ )
    {
        file.buttons[i].Hide()
        file.serversName[i].SetVisible(false)
        file.playerCountLabels[i].SetVisible(false)
        file.serversMap[i].SetVisible(false)
        file.serversGamemode[i].SetVisible(false)
    }

    // Show server info for current page
    local endIndex = uiGlobal.serversArrayFiltered.len() > 10 ? 10 : uiGlobal.serversArrayFiltered.len()

    for ( local i = 0; i < endIndex; i++ )
    {
        local buttonIndex = file.scrollOffset + i

        local server = uiGlobal.serversArrayFiltered[buttonIndex]
        file.buttons[i].Show()
        file.buttons[i].SetEnabled(true)
        file.serversName[i].SetText( server.host_name )
        file.playerCountLabels[i].SetText( format( "%i/%i", server.players.len(), server.max_players ) )
        if(server.map_name == "mp_lobby") {
            file.serversMap[i].SetText("Lobby")
        } else {
        file.serversMap[i].SetText("#" +  server.map_name )
        }
        file.serversGamemode[i].SetText( "#GAMEMODE_" + server.game_mode )
        file.serversName[i].SetVisible(true)
        file.playerCountLabels[i].SetVisible(true)
        file.serversMap[i].SetVisible(true)
        file.serversGamemode[i].SetVisible(true)
    }
}

function OnServerButtonClicked(button)
{
    local scriptID = button.GetScriptID().tointeger()
    local serverIndex = scriptID + uiGlobal.scrollOffset

    if (serverIndex >= uiGlobal.serversArrayFiltered.len())
        return

    local server = uiGlobal.serversArrayFiltered[serverIndex]

    ClientCommand( "connect " + server.ip + ":" + server.port )

}


function OnServerSelected()
{
    ConnectToServer()
}

function ConnectToServer()
{
    if (file.currentChoice >= uiGlobal.serversArrayFiltered.len())
        return

    local server = uiGlobal.serversArrayFiltered[file.currentChoice]
    ClientCommand( "connect " + server.ip + ":" + server.port )
}

function OnScrollDown()
{
    if (uiGlobal.serversArrayFiltered.len() <= 10) return
    file.scrollOffset += 1
    if (file.scrollOffset + 10 > uiGlobal.serversArrayFiltered.len())
        file.scrollOffset = uiGlobal.serversArrayFiltered.len() - 10

    file.scrollOffset = file.scrollOffset
    UpdateShownPage()
}

function OnScrollUp()
{
    file.scrollOffset -= 1
    if (file.scrollOffset < 0)
        file.scrollOffset = 0

    file.scrollOffset = file.scrollOffset

    UpdateShownPage()
}
// Add these functions to the previous server browser code:

function OnServerButtonFocused(button)
{
    local scriptID =  button.GetScriptID()
    if(!scriptID) return
    printt(scriptID)
    scriptID = scriptID.tointeger()
    if (scriptID == 10) return
    local serverIndex = uiGlobal.scrollOffset + scriptID

    local menu = uiGlobal.menu
    if(serverIndex >= uiGlobal.serversArrayFiltered.len())
        return
    local server = uiGlobal.serversArrayFiltered[serverIndex]

    // Update preview panel
    menu.GetChild( "NextMapName" ).SetText( server.host_name )
    menu.GetChild( "NextMapDesc" ).SetText( "#GAMEMODE_" + server.game_mode )
    menu.GetChild( "StarsLabel" ).SetText( "#"+ server.map_name  )
    local players = server.players
    local maxPlayers = server.max_players || 12
    menu.GetChild("VersionLabel").SetText( players.len() + "/" + maxPlayers +  " players")

    menu.GetChild( "NextMapImage" ).SetImage( "../ui/menu/lobby/lobby_image_" + server.map_name )
    if(server.map_name == "mp_lobby") {
        menu.GetChild("StarsLabel").SetText( "Lobby")
		menu.GetChild("NextMapImage").SetImage("../ui/menu/common/menu_background_neutral")
    }
    // Player info
    local playerCount = server.players.len()
    local maxPlayers = server.max_players
    menu.GetChild( "VersionLabel" ).SetText( playerCount + "/" + maxPlayers + " players" )
}

function OnServerBrowserMenu(menu)
{
    // Called when the menu is opened
    if ( !( "menu" in file ) )
        return

    DispatchServerListReq()
    thread Threaded_GetServerList()

    uiGlobal.menu <- menu
    file.menu = menu

    // Reset scroll and current selection
    file.scrollOffset = 0
    uiGlobal.scrollOffset <- 0
    file.currentChoice = 0

    // Clear any previous filter settings
    file.searchTerm = ""
    // printt(file.searchBox.GetTextEntryUTF8Text())
    if ( file.searchBox != null )
        file.searchBox.SetUTF8Text( "" )

    // local panel = menu.GetPanel()
    // HudElement( "LobbyEnemyTeamBackground",panel ).SetVisible( false )


    // Update UI
    FilterAndUpdateList()
}

function SortServerListByName( button )
{
    uiGlobal.sortDirection.serverName = !uiGlobal.sortDirection.serverName
    uiGlobal.serversArrayFiltered.sort(function(a, b) {
        if ( uiGlobal.sortDirection.serverName )
            {
                if(a.host_name > b.host_name) return 1
                if(a.host_name < b.host_name) return -1
                return 0
            }
        else
            {
                if(a.host_name < b.host_name) return 1
                if(a.host_name > b.host_name) return -1
                return 0
            }
    })

    UpdateShownPage()
}

function SortServerListByPlayers( button )
{
    uiGlobal.sortDirection.serverPlayers = !uiGlobal.sortDirection.serverPlayers

    uiGlobal.serversArrayFiltered.sort(function(a, b) {
        if(uiGlobal.sortDirection.serverPlayers)
        {
            if(a.players.len() > b.players.len()) return 1
            if(a.players.len() < b.players.len()) return -1
            return 0
        }
        else
        {
            if(a.players.len() < b.players.len()) return 1
            if(a.players.len() > b.players.len()) return -1
            return 0
        }
    })

    UpdateShownPage()
}

function SortServerListByMap( button )
{
    uiGlobal.sortDirection.serverMap = !uiGlobal.sortDirection.serverMap

    uiGlobal.serversArrayFiltered.sort(function(a, b) {
        if ( uiGlobal.sortDirection.serverMap )
            {
                if(a.map_name > b.map_name) return 1
                if(a.map_name < b.map_name) return -1
                return 0
            }
        else
            {
                if(a.map_name < b.map_name) return 1
                if(a.map_name > b.map_name) return -1
                return 0
            }
    })

    UpdateShownPage()
}

function SortServerListByGamemode( button )
{
    uiGlobal.sortDirection.serverGamemode = !uiGlobal.sortDirection.serverGamemode

    uiGlobal.serversArrayFiltered.sort(function(a, b) {
        if ( uiGlobal.sortDirection.serverGamemode )
            {
                if(a.game_mode > b.game_mode) return 1
                if(a.game_mode < b.game_mode) return -1
                return 0
            }
        else
            {
                if(a.game_mode < b.game_mode) return 1
                if(a.game_mode > b.game_mode) return -1
                return 0
            }
    })

    UpdateShownPage()
}

// Utility functions for mouse wheel scrolling
function OnMouseWheelUp(...)
{
    OnScrollUp()
}

function OnMouseWheelDown(...)
{
    OnScrollDown()
}

// Register/deregister mouse wheel callbacks when menu opens/closes
function RegisterMouseWheelCallbacks()
{
    RegisterButtonPressedCallback( MOUSE_WHEEL_UP, OnMouseWheelUp )
    RegisterButtonPressedCallback( MOUSE_WHEEL_DOWN, OnMouseWheelDown )
}

function DeregisterMouseWheelCallbacks()
{
    DeregisterButtonPressedCallback( MOUSE_WHEEL_UP, OnMouseWheelUp )
    DeregisterButtonPressedCallback( MOUSE_WHEEL_DOWN, OnMouseWheelDown )
}

function HideFullHandler(button) {

    button.SetSelected( !button.IsSelected() )
    button.SetText( button.IsSelected() ? "ON" : "OFF" )
    FilterAndUpdateList()
    UpdateShownPage()
}

function HideEmptyHandler(button) {

    button.SetSelected( !button.IsSelected() )
    button.SetText( button.IsSelected() ? "ON" : "OFF" )
    FilterAndUpdateList()
    UpdateShownPage()
}

function OnDirectConnectDialogButtonConnect_Activate( button )
{
    local str = button.GetParent().GetChild( "LblConnectTo" ).GetTextEntryUTF8Text()

	if(str == "")
		return

    ClientCommand( "connect " + str )
	CloseDialog( true )
}

function OnDirectConnectDialogButtonCancel_Activate( button )
{
    CloseDialog( true )
}