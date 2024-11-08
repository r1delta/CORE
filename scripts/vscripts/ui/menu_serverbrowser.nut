
function main()
{
	Globalize( InitServerBrowserMenu )
	Globalize( OnServerBrowserMenu )
	Globalize( OpenDirectConnectDialog_Activate )

    file.dialog <- null
    file.lblConnectTo <- null
	file.buttons <- null
	file.currentChoice <- 0
	file.serverList <- null
}

function OpenDirectConnectDialog_Activate( button )
{
	if ( uiGlobal.activeDialog )
		return

	local dialogData = {}
	dialogData.header <- "Connect To Address..."
    dialogData.detailsMessage <- "R1Delta multiplayer is currently not finished, but there is some buggy early testing going on.\n ^1 Do not connect to servers you do not trust."

	OpenChoiceDialog( dialogData, GetMenu( "DirectConnectDialog" ) )
}

function InitServerBrowserMenu( menu )
{
	file.menu <- menu
	uiGlobal.menu <- menu
	file.serverList <- GetServerList()
	uiGlobal.serverList <- file.serverList
    file.dialog <- GetMenu( "DirectConnectDialog" )
    file.lblConnectTo <- file.dialog.GetChild( "LblConnectTo" )
	file.buttons <- GetElementsByClassname( file.menu, "MapButtonClass" )
	uiGlobal.buttons <- file.buttons
	file.currentChoice <- 0
	uiGlobal.menu.GetChild("NextMapImage").SetImage("../ui/menu/lobby/map_image_frame")
	file.menu.GetChild("NextMapImage").SetVisible( true )
	foreach( i, button in file.buttons ) {
		button.SetVisible( false )
	}

    AddEventHandlerToButton( GetMenu( "DirectConnectDialog" ), "BtnConnect", UIE_CLICK, OnDirectConnectDialogButtonConnect_Activate )
    AddEventHandlerToButton( GetMenu( "DirectConnectDialog" ), "BtnCancel", UIE_CLICK, OnDirectConnectDialogButtonCancel_Activate )
}

function ConnectToServer(button) {
	local script_id = button.GetScriptID().tointeger()
	local serverList = GetServerList()
	local server = serverList[script_id]
	ClientCommand( "connect " + server.ip + ":" + server.port )
}

function OnServerBrowserMenu()
{
	local buttonID

	print( "Server list: " + file.serverList)
	printt("Server length: " + file.serverList.len())
	foreach(i, serv in file.serverList)
	{
		printt( "Server: " + serv.host_name )
		if ( i >= file.buttons.len() )
			break

		buttonID = file.buttons[i]
		buttonID.SetText( serv.ip )
		buttonID.SetEnabled( true )
		buttonID.SetSelected( false )
		buttonID.SetVisible( true )
		buttonID.AddEventHandler( UIE_CLICK, ConnectToServer )
		file.buttons[i].AddEventHandler( UIE_GET_FOCUS, ChangePreviewUI )

	}
}

function ChangePreviewUI(button) {
	local script_id = button.GetScriptID().tointeger()
	local table = uiGlobal.serverList[script_id]

	local name = table["host_name"]
	local desc = table["map_name"]
	local author = table["game_mode"]
	local version = table["port"]

	printt( "Name: " + name )
	printt( "Desc: " + desc )
	printt( "Author: " + author )
	printt( "Version: " + version )

	if( desc == "Description_Here" )
		desc = "No Description"
	
	if( author == "Author_Name_Here" )
		author = "No Author"

	if( version == "Version_Here" )
		version = "No Version"

	uiGlobal.menu.GetChild("NextMapName").SetVisible( true)
	uiGlobal.menu.GetChild("NextMapName").SetText( name)

	uiGlobal.menu.GetChild("NextMapDesc").SetVisible( true )
	uiGlobal.menu.GetChild("NextMapDesc").SetText( desc )

	uiGlobal.menu.GetChild("StarsLabel").SetText(author)
	uiGlobal.menu.GetChild("VersionLabel").SetVisible( true )
	uiGlobal.menu.GetChild("VersionLabel").SetText( version )

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
