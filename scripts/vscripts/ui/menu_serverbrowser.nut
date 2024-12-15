
function main()
{
	Globalize( InitServerBrowserMenu )
	Globalize( OnServerBrowserMenu )
	Globalize( OpenDirectConnectDialog_Activate )
	Globalize( RefreshServerList )

    file.dialog <- null
    file.lblConnectTo <- null
	file.buttons <- null
	file.currentChoice <- 0
	file.serverList <- []
}

function OpenDirectConnectDialog_Activate( button )
{
	if ( uiGlobal.activeDialog )
		return

	local dialogData = {}
	dialogData.header <- "Connect To Address..."
    dialogData.detailsMessage <- "R1Delta multiplayer is currently not finished, but there is some buggy early testing going on.\n ^1 Do not connect to servers you do not trust."

	OpenChoiceDialog( dialogData, GetMenu( "DirectConnectDialog" ) )
	local inputs = []
		// Gamepad
	inputs.append( BUTTON_A )
	inputs.append( BUTTON_START )

	// Keyboard/Mouse
	inputs.append( KEY_ENTER )

	foreach ( input in inputs )
		RegisterButtonPressedCallback( input, ConnectToDirectServer )
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
	file.menu <- menu
	uiGlobal.server_menu <- menu
    file.dialog <- GetMenu( "DirectConnectDialog" )
    file.lblConnectTo <- file.dialog.GetChild( "LblConnectTo" )
	file.menu.GetChild("MapButtonsPanel").SetVisible( true )
	file.buttons <- GetElementsByClassname( file.menu, "MapButtonClass" )
	file.currentChoice <- 0
	file.menu.GetChild("ServerNextMapImage").SetVisible( true )
	file.serverList <- []
	uiGlobal.serverList <- []
	foreach(i,button in file.buttons) {
		button.SetVisible( false )
	}
	AddEventHandlerToButton( GetMenu( "DirectConnectDialog" ), "BtnConnect", UIE_CLICK, OnDirectConnectDialogButtonConnect_Activate )
    AddEventHandlerToButton( GetMenu( "DirectConnectDialog" ), "BtnCancel", UIE_CLICK, OnDirectConnectDialogButtonCancel_Activate )

	file.menu.GetChild("ServerNextMapName").SetText( "No servers found" )

	// foreach(i, serv in file.serverList)
	// {
	// 	printt("index: " + i + " host_name: " + serv)
	// 	file.buttons[i].SetText(serv.host_name )
	// 	file.buttons[i].SetEnabled( true )
	// 	file.buttons[i].SetSelected( false )
	// 	if( serv.host_name == "No servers found" && num_servers > 0  )
	// 		file.buttons[i].SetVisible( false )
	// 	file.buttons[i].SetVisible( true )
	// 	file.buttons[i].AddEventHandler( UIE_CLICK, ConnectToServer )
	// 	file.buttons[i].AddEventHandler( UIE_GET_FOCUS, ChangePreviewUI )
	// }

  }


function RefreshServerList(button) {
	thread Threaded_GetServerList()
	
	if (file.serverList == null)
		return

	local num_servers = file.serverList.len()
	foreach(i, serv in file.serverList)
	{
		printt("index: " + i + " host_name: " + serv.host_name)
		file.buttons[i].SetText(serv.host_name )
		file.buttons[i].SetEnabled( true )
		file.buttons[i].SetSelected( false )
		file.buttons[i].SetVisible( true )
		if( serv.host_name == "No servers found" && num_servers > 0  )
			file.buttons[i].SetVisible( false )
		file.buttons[i].AddEventHandler( UIE_CLICK, ConnectToServer )
		file.buttons[i].AddEventHandler( UIE_GET_FOCUS, ChangePreviewUI )
	}
}

function Threaded_GetServerList()
{
	local retries = 0

	while(file.serverList.len() <= 0 && retries < 5) {

		local list = GetServerList()

		if(list == null)
		{
			WaitFrame()
			continue
		}

		file.serverList <- GetServerList()
		retries += 1
		wait 1
	}

	uiGlobal.serverList <- file.serverList
}

function ConnectToServer(button) {
	local script_id = button.GetScriptID().tointeger()
	local serverList = uiGlobal.serverList
	local server = serverList[script_id]
	ClientCommand( "connect " + server.ip + ":" + server.port )
}

function OnServerBrowserMenu()
{
	thread Threaded_GetServerList()
}

function ChangePreviewUI(button) {
	local script_id = button.GetScriptID().tointeger()
	local table = uiGlobal.serverList[script_id]
	local host_name = table["host_name"]
	local ip = table["ip"]
	local map = table["map_name"]
	local gm = table["game_mode"]
	local port = table["port"]
	local players = table["players"]
	local maxPlayers = table["max_players"] || 12;

	
	uiGlobal.server_menu.GetChild("ServerNextMapName").SetVisible(true)
	uiGlobal.server_menu.GetChild("ServerNextMapName").SetText( host_name )
	uiGlobal.server_menu.GetChild("ServerNextMapDesc").SetVisible( true )
	uiGlobal.server_menu.GetChild("ServerNextMapDesc").SetText( "#GAMEMODE_" + gm )

	uiGlobal.server_menu.GetChild("StarsLabel").SetText( "#"+ map)
	uiGlobal.server_menu.GetChild("VersionLabel").SetVisible( true )
	uiGlobal.server_menu.GetChild("VersionLabel").SetText( players.len() + "/" + maxPlayers +  " players")
	uiGlobal.server_menu.GetChild("ServerNextMapImage").SetImage("../ui/menu/lobby/lobby_image_" + map)

	
	if(map == "mp_lobby") {
		uiGlobal.server_menu.GetChild("StarsLabel").SetText( "Lobby")
		uiGlobal.server_menu.GetChild("ServerNextMapImage").SetImage("../ui/menu/common/menu_background_neutral")
	}

}

function OnDirectConnectDialogButtonConnect_Activate( button )
{
    local str = button.GetParent().GetChild( "LblConnectTo" ).GetTextEntryUTF8Text()

	if(str == "")
		return

    ClientCommand( "connect " + str )
	local input = []



	CloseDialog( true )
}

function OnDirectConnectDialogButtonCancel_Activate( button )
{
    CloseDialog( true )
}
