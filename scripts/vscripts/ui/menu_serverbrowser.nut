function main()
{
    // Global functions
    Globalize( InitServerBrowserMenu )
    Globalize( OnOpenServerBrowserMenu )
    Globalize( OnCloseServerBrowserMenu )
    Globalize( RefreshServerList )
	Globalize( OpenDirectConnectDialog_Activate )
    Globalize( UpdateShownPage )
    Globalize( FilterAndUpdateList )
    Globalize( FilterServerList )
    Globalize( UpdateAndShowServerDescription )
    Globalize( HideServerDescription )
    Globalize( OnSearchBoxLooseFocus )
    Globalize( DeregisterMouseWheelCallbacks )

    // File-level variables
    file.menu <- null
    file.buttons <- null
    file.serversName <- null
    file.playerCountLabels <- null
    file.serversMap <- null
    file.serversGamemode <- null
    file.serverList <- []
    file.scrollOffset <- 0
    // uiGlobal.serversArrayFiltered <- []
    file.searchBox <- null

    // Search/filter state
    file.searchTerm <- ""
    file.useSearch <- false
    // Direction for sorting

}

function OpenDirectConnectDialog_Activate( button )
{
	if ( uiGlobal.activeDialog )
		return

	local dialogData = {}
	dialogData.header <- "#DIRECT_CONNECT_HEADER"
    dialogData.detailsMessage <- "#DIRECT_CONNECT_MESSAGE"

	OpenChoiceDialog( dialogData, GetMenu( "DirectConnectDialog" ) )
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
    file.passwordDialog <- GetMenu( "EnterPasswordDialog" )
    file.lblConnectTo <- file.dialog.GetChild( "LblConnectTo" )
    uiGlobal.lblEnterPswd <- file.passwordDialog.GetChild( "LblEnterPswd" )
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
    AddEventHandlerToButton( menu, "SwtBtnFilters", UIE_CLICK, FilterServerList_ )


    AddEventHandlerToButton( GetMenu( "DirectConnectDialog" ), "BtnConnect", UIE_CLICK, OnDirectConnectDialogButtonConnect_Activate )
    AddEventHandlerToButton( GetMenu( "DirectConnectDialog" ), "BtnCancel", UIE_CLICK, OnDirectConnectDialogButtonCancel_Activate )

    AddEventHandlerToButton( GetMenu( "EnterPasswordDialog" ), "BtnConnect", UIE_CLICK, OnEnterPasswordDialogButtonConnect_Activate )
    AddEventHandlerToButton( GetMenu( "EnterPasswordDialog" ), "BtnCancel", UIE_CLICK, OnEnterPasswordDialogButtonCancel_Activate )

    file.searchBox = menu.GetChild( "BtnServerSearch" )
	AddEventHandlerToButton( menu, "BtnServerSearch", UIE_LOSE_FOCUS, Bind( OnSearchBoxLooseFocus ) )

    // RegisterButtonPressedCallback( BUTTON_X, RefreshServerList)
    // RegisterButtonPressedCallback( BUTTON_Y, OpenDirectConnectDialog_Activate)

    // Initialize filter state
    RefreshServerList(null)

}

function OnSearchBoxLooseFocus(button)
{
    FilterAndUpdateList()
    UpdateShownPage()
}

function ClearPreviewPane()
{
    // // Update preview panel
    // local menu = file.menu

    // menu.GetChild( "NextMapName" ).SetText( "" )
    // menu.GetChild( "NextMapDesc" ).SetText( "" )
    // menu.GetChild( "StarsLabel" ).SetText( "" )
    // menu.GetChild( "VersionLabel" ).SetText( "" )
    // menu.GetChild( "StarsLabel" ).SetText( "" )
    // menu.GetChild( "VersionLabel" ).SetText( "" )
}

function Threaded_GetServerList()
{
	local retries = 0

    file.serverList = []

	while(file.serverList.len() <= 0 && retries < 15) {

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

    ClearPreviewPane()

    FilterAndUpdateList()
}

function FilterAndUpdateList()
{
    file.searchTerm = file.searchBox.GetTextEntryUTF8Text()
    file.useSearch = file.searchTerm != ""

    file.scrollOffset = 0
    FilterServerList()

    UpdateShownPage()
}

function FilterServerList_( button )
{
    FilterAndUpdateList()
}

function ShouldHideFull()
{
    if( ( GetConVarInt("delta_ui_server_filter") == 2 ) || ( GetConVarInt("delta_ui_server_filter") == 3 ) )
        return true

    return false
}

function ShouldHideEmpty()
{
    if( ( GetConVarInt("delta_ui_server_filter") == 1 ) || ( GetConVarInt("delta_ui_server_filter") == 3 ) )
        return true

    return false
}

function CompareSemver(versionA, versionB)
{
    local partsA = split( versionA, "." )
    local partsB = split( versionB, "." )

    for (local i = 0; i < max(partsA.len(), partsB.len()); i++)
    {
        local numA = (i < partsA.len()) ? partsA[i].tointeger() : 0
        local numB = (i < partsB.len()) ? partsB[i].tointeger() : 0

        if (numA < numB) return -1
        if (numA > numB) return 1
    }
    return 0
}

function FilterServerList()
{
    uiGlobal.serversArrayFiltered.clear()
    foreach ( server in uiGlobal.serverList )
    {
        if ( ShouldHideEmpty() && server.players.len() == 0)
            continue

        if ( ShouldHideFull() && server.players.len() >= server.max_players)
            continue

        if ( server.version == "" )
            continue

        local r1dVersion = GetMinimumR1DVersion()

        if( CompareSemver( server.version, r1dVersion ) < 0 )
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
    local BUTTONS_PER_PAGE = 15

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
    local endIndex = uiGlobal.serversArrayFiltered.len() > 15 ? 15 : uiGlobal.serversArrayFiltered.len()

    for ( local i = 0; i < endIndex; i++ )
    {
        local buttonIndex = file.scrollOffset + i

        if ( buttonIndex >= uiGlobal.serversArrayFiltered.len() )
            break

        local server = uiGlobal.serversArrayFiltered[buttonIndex]

        local trimmed_hostname = server.host_name

        // if ( server.host_name.len() > 42 )
        //     trimmed_hostname = server.host_name.slice(0, 42) + "..."

        if ( StringContains( server.host_name, "#" ) )
        {
            local result = ""
            for (local i = 0; i < trimmed_hostname.len(); i++)
            {
                if (trimmed_hostname.slice(i, i + 1) != "#")
                    result += trimmed_hostname.slice(i, i + 1)
            }

            trimmed_hostname = result;
        }

        file.buttons[i].Show()
        file.buttons[i].SetEnabled(true)
        file.serversName[i].SetText( trimmed_hostname )
        file.playerCountLabels[i].SetText( format( "%i/%i", server.players.len(), server.max_players ) )
        file.serversGamemode[i].SetText( "#GAMEMODE_" + server.game_mode )
        if( StringContains( server.map_name, "mp_lobby" ) )
        {
            local playlistName = Localize( "#" + server.playlist_display_name )

            if (playlistName.len() == 0 )
                file.serversGamemode[i].SetText(server.playlist_display_name)
            else
                file.serversGamemode[i].SetText(playlistName)

            file.serversMap[i].SetText("Lobby")
        } else
            file.serversMap[i].SetText("#" +  server.map_name )

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

    uiGlobal.currentServerChoice <- serverIndex

	local dialogData = {}
	dialogData.header <- "#ENTER_PASSWORD_HEADER"
    dialogData.detailsMessage <- "#ENTER_PASSWORD_MESSAGE"
    // DeregisterButtonPressedCallback( BUTTON_X, RefreshServerList)
    // DeregisterButtonPressedCallback( BUTTON_Y, OpenDirectConnectDialog_Activate)
    if( server.has_password )
        OpenChoiceDialog( dialogData, GetMenu( "EnterPasswordDialog" ) )
    else {
        try {
            DeregisterMouseWheelCallbacks()
        } catch(e) { }

        if ( server.map_name == "mp_lobby" )
            AdvanceMenu( GetMenu( "LobbyMenu" ) )

        ClientCommand( "connect " + server.ip + ":" + server.port )
    }
}

function OnScrollDown()
{
    if (uiGlobal.serversArrayFiltered.len() <= 15) return
    file.scrollOffset += 1
    if (file.scrollOffset >= uiGlobal.serversArrayFiltered.len())
        file.scrollOffset = uiGlobal.serversArrayFiltered.len() - 1
    // if (file.scrollOffset + 15 > uiGlobal.serversArrayFiltered.len())
        // file.scrollOffset = uiGlobal.serversArrayFiltered.len() - 15

    uiGlobal.scrollOffset = file.scrollOffset
    UpdateShownPage()
}

function OnScrollUp()
{
    file.scrollOffset -= 1
    if (file.scrollOffset < 0)
        file.scrollOffset = 0

    uiGlobal.scrollOffset <- file.scrollOffset

    UpdateShownPage()
}
// Add these functions to the previous server browser code:

function OnServerButtonFocused(button)
{
    local scriptID =  button.GetScriptID()
    if(!scriptID) return
    scriptID = scriptID.tointeger()
    if (scriptID == 15) return
    local serverIndex = uiGlobal.scrollOffset + scriptID
    local menu = uiGlobal.menu
    if(serverIndex >= uiGlobal.serversArrayFiltered.len())
        return
    local server = uiGlobal.serversArrayFiltered[serverIndex]


    if(server.map_name == "mp_lobby") {
        menu.GetChild("StarsLabel").SetText( "#LOBBY" )
		menu.GetChild("NextMapImage").SetImage("../ui/menu/common/menu_background_neutral")
    }
    else if (server.map_name == "mp_mia" || server.map_name == "mp_nest2" || server.map_name == "mp_box") {
        menu.GetChild("StarsLabel").SetText( "#" + server.map_name )
        menu.GetChild("NextMapImage").SetImage("../loadscreens/" + server.map_name + "_widescreen")
    }
     else {
        menu.GetChild("StarsLabel").SetText( "#" + server.map_name )
        menu.GetChild("NextMapImage").SetImage("../ui/menu/lobby/lobby_image_" + server.map_name)
    }

    // Update preview panel
    if( server.description.len() )
        UpdateAndShowServerDescription( server.description )
    else
        HideServerDescription()

    local trimmed_hostname = server.host_name

    if ( StringContains( server.host_name, "#" ) )
    {
        local result = ""

        for (local i = 0; i < trimmed_hostname.len(); i++)
        {
            if (trimmed_hostname.slice(i, i + 1) != "#")
            {
                result += trimmed_hostname.slice(i, i + 1);
            }
        }
        trimmed_hostname = result;
    }


    menu.GetChild( "NextMapName" ).SetText( trimmed_hostname )
    menu.GetChild( "NextMapName" ).Show()
    menu.GetChild( "NextMapDesc" ).SetText( "#GAMEMODE_" + server.game_mode )

    local players = server.players
    local maxPlayers = server.max_players || 12
    menu.GetChild("VersionLabel").SetText( players.len() + "/" + maxPlayers +  " players")

    // Player info
    local playerCount = server.players.len()
    local maxPlayers = server.max_players
    menu.GetChild( "VersionLabel" ).SetText( playerCount + "/" + maxPlayers + " players" )
}

function UpdateAndShowServerDescription( description )
{
    local menu = uiGlobal.menu

    local trimmed_description = description

    if ( StringContains( description, "#" ) )
    {
        local result = ""

        for (local i = 0; i < trimmed_description.len(); i++)
        {
            if (trimmed_description.slice(i, i + 1) != "#")
            {
                result += trimmed_description.slice(i, i + 1);
            }
        }

        trimmed_description = result;
    }

    menu.GetChild( "DescriptionMessage" ).SetText( description )
    menu.GetChild( "DescriptionBox" ).SetVisible( true )
    menu.GetChild( "DescriptionTitle" ).SetVisible( true )
    menu.GetChild( "DescriptionMessage" ).SetVisible( true )

}

function HideServerDescription()
{
    local menu = uiGlobal.menu
    menu.GetChild( "DescriptionMessage" ).SetText( "" )
    menu.GetChild( "DescriptionBox" ).SetVisible( false )
    menu.GetChild( "DescriptionTitle" ).SetVisible( false )
    menu.GetChild( "DescriptionMessage" ).SetVisible( false )
}

function OnOpenServerBrowserMenu(menu)
{
    // Called when the menu is opened
    if ( !( "menu" in file ) )
        return

    RefreshServerList( null )

    uiGlobal.menu <- menu
    file.menu = menu

    // Reset scroll and current selection
    file.scrollOffset = 0
    uiGlobal.scrollOffset <- 0
    uiGlobal.currentServerChoice <- 0
    // Clear any previous filter settings
    file.searchTerm = ""
    // printt(file.searchBox.GetTextEntryUTF8Text())
    if ( file.searchBox != null )
        file.searchBox.SetUTF8Text( "" )

    // local panel = menu.GetPanel()
    // HudElement( "LobbyEnemyTeamBackground",panel ).SetVisible( false )


    try {
        DeregisterButtonPressedCallback( KEY_ENTER, OnSearchBoxLooseFocus )
        DeregisterButtonPressedCallback( BUTTON_X, RefreshServerList)
        DeregisterButtonPressedCallback( BUTTON_Y, OpenDirectConnectDialog_Activate)
        DeregisterMouseWheelCallbacks()
    } catch ( e )
    { }

    // Initialize mouse wheel handlers
    RegisterMouseWheelCallbacks()
    RegisterButtonPressedCallback( KEY_ENTER, OnSearchBoxLooseFocus )
    RegisterButtonPressedCallback( BUTTON_X, RefreshServerList)
    // RegisterButtonPressedCallback( BUTTON_Y, OpenDirectConnectDialog_Activate)
}

function OnCloseServerBrowserMenu( menu )
{
    try {
        DeregisterButtonPressedCallback( BUTTON_X, RefreshServerList)
        DeregisterButtonPressedCallback( BUTTON_Y, OpenDirectConnectDialog_Activate)
        DeregisterButtonPressedCallback( KEY_ENTER, OnSearchBoxLooseFocus )
        DeregisterMouseWheelCallbacks()
    } catch ( e )
    { }
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
    try {
        RegisterButtonPressedCallback( MOUSE_WHEEL_UP, OnMouseWheelUp )
        RegisterButtonPressedCallback( MOUSE_WHEEL_DOWN, OnMouseWheelDown )
    } catch ( e )
    {
        DeregisterMouseWheelCallbacks()
        RegisterMouseWheelCallbacks()
    }
}

function DeregisterMouseWheelCallbacks()
{
    try {
        DeregisterButtonPressedCallback( MOUSE_WHEEL_UP, OnMouseWheelUp )
        DeregisterButtonPressedCallback( MOUSE_WHEEL_DOWN, OnMouseWheelDown )
    } catch ( e )
    { }
}

//

function OnDirectConnectDialogButtonConnect_Activate( button )
{
    local str = button.GetParent().GetChild( "LblConnectTo" ).GetTextEntryUTF8Text()

	if(str == "")
		return

    if ( !regexp( "^[0-9a-zA-Z:._\\-]+$" ).match( str ) )
        return

    DeregisterMouseWheelCallbacks()

    AdvanceMenu( GetMenu( "LobbyMenu" ) )

    ClientCommand( "connect " + str )
	CloseDialog( true )
}

function OnDirectConnectDialogButtonCancel_Activate( button )
{
    CloseDialog( true )
}

function OnEnterPasswordDialogButtonConnect_Activate( button )
{
     if ( uiGlobal.activeDialog == null )
        return

    local str = uiGlobal.lblEnterPswd.GetTextEntryUTF8Text()

    if ( str == null )
        return
    if(str == "")
        return

    local server = uiGlobal.serversArrayFiltered[uiGlobal.currentServerChoice]

    try {
        DeregisterButtonPressedCallback( KEY_ENTER, OnSearchBoxLooseFocus )
        RegisterButtonPressedCallback( KEY_ENTER, OnSearchBoxLooseFocus )
        DeregisterMouseWheelCallbacks()
    } catch ( e )
    { }

    if ( server.map_name == "mp_lobby" )
        AdvanceMenu( GetMenu( "LobbyMenu" ) )

    ClientCommand( "password " + str )
    ClientCommand( "connect " + server.ip + ":" + server.port )
    CloseDialog( true )
}

function OnEnterPasswordDialogButtonCancel_Activate( button )
{
    CloseDialog( true )
}