
function main()
{
	Globalize( InitServerBrowserMenu )
	Globalize( OnServerBrowserMenu )
	Globalize( OpenDirectConnectDialog_Activate )

    file.dialog <- null
    file.lblConnectTo <- null
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
    file.dialog <- GetMenu( "DirectConnectDialog" )
    file.lblConnectTo <- file.dialog.GetChild( "LblConnectTo" )
	file.currentChoice <- 0

    AddEventHandlerToButton( GetMenu( "DirectConnectDialog" ), "BtnConnect", UIE_CLICK, OnDirectConnectDialogButtonConnect_Activate )
    AddEventHandlerToButton( GetMenu( "DirectConnectDialog" ), "BtnCancel", UIE_CLICK, OnDirectConnectDialogButtonCancel_Activate )
}

function OnServerBrowserMenu()
{
	local buttons = GetElementsByClassname( file.menu, "MapClass" )
	local buttonID

	foreach( button in buttons )
	{

		button.SetText( "" )
		button.SetEnabled( false )
		button.SetSelected( false )
	}
}

function OnDirectConnectDialogButtonConnect_Activate( button )
{
    local str = button.GetParent().GetChild( "LblConnectTo" ).GetTextEntryUTF8Text()

	if(str == "")
		return

    ClientCommand( "connect " + str )
}

function OnDirectConnectDialogButtonCancel_Activate( button )
{
    CloseDialog( true )
}
