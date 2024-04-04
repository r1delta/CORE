
function main()
{
	Globalize( InitServerBrowserMenu )
	Globalize( OnOpenMapsMenu )
	Globalize( OnCloseMapsMenu )
    Globalize( OpenDirectConnectDialog_Activate )

	file.mapChoices <- []
	//file.mapChoices.append( "random" )
	file.mapChoices.append( "mp_airbase" )
	file.mapChoices.append( "mp_angel_city" )
	file.mapChoices.append( "mp_boneyard" )
	file.mapChoices.append( "mp_colony" )
	file.mapChoices.append( "mp_corporate" )
	file.mapChoices.append( "mp_o2" )
	file.mapChoices.append( "mp_fracture" )
	file.mapChoices.append( "mp_lagoon" )
	file.mapChoices.append( "mp_nexus" )
	file.mapChoices.append( "mp_outpost_207" )
	file.mapChoices.append( "mp_overlook" )
	file.mapChoices.append( "mp_relic" )
	file.mapChoices.append( "mp_rise" )
	file.mapChoices.append( "mp_smugglers_cove" )
	file.mapChoices.append( "mp_training_ground" )

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

	AddEventHandlerToButtonClass( menu, "MapClass", UIE_CLICK, Bind( OnMapButton_Activate ) )
	AddEventHandlerToButtonClass( menu, "MapClass", UIE_GET_FOCUS, Bind( OnMapButton_Focused ) )

    AddEventHandlerToButton( GetMenu( "DirectConnectDialog" ), "BtnConnect", UIE_CLICK, OnDirectConnectDialogButtonConnect_Activate )
    AddEventHandlerToButton( GetMenu( "DirectConnectDialog" ), "BtnCancel", UIE_CLICK, OnDirectConnectDialogButtonCancel_Activate )
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

function OnOpenMapsMenu()
{
	local buttons = GetElementsByClassname( file.menu, "MapClass" )
	local buttonID

	foreach( button in buttons )
	{
		buttonID = button.GetScriptID().tointeger()

		if ( buttonID < file.mapChoices.len() )
		{
			button.SetText( GetMapDisplayName( file.mapChoices[buttonID] ) )
			button.SetEnabled( true )

			if ( buttonID == file.currentChoice )
			{
				button.SetSelected( true )

				if ( IsControllerModeActive() )
					button.SetFocused()
			}
			else
				button.SetSelected( false )
		}
		else
		{
			button.SetText( "" )
			button.SetEnabled( false )
			button.SetSelected( false )
		}
	}
}

function OnCloseMapsMenu()
{
}

function OnMapButton_Focused( button )
{
	/*local mapName = GetMapChoiceFromIndex( button.GetScriptID().tointeger() )
	local mapImage = "../ui/menu/lobby/lobby_image_" + mapName

	local mapImageElem = file.menu.GetChild( "MapImage" )
	local mapNameElem = file.menu.GetChild( "MapName" )

	mapImageElem.SetImage( mapImage )
	mapNameElem.SetText( GetMapDisplayName( mapName ) )*/
}

function OnMapButton_Activate( button )
{
	local mapName = GetMapChoiceFromIndex( button.GetScriptID().tointeger() )

	printt( "Chose map:", mapName )
	ClientCommand( "PrivateMatchSetMap " + mapName )

	// UPDATE: Update the map chosen. level.ui.privatematch_map already is holding the map enum for the current setting
	file.currentChoice = button.GetScriptID().tointeger()

	CloseTopMenu()
}

function GetMapChoiceFromIndex( index )
{
	return file.mapChoices[index]
}

function GetButtonIndexFromMapName( mapName )
{
	for ( local i = 0 ; i < file.mapChoices.len() ; i++ )
	{
		if ( file.mapChoices[i] == mapName )
			return i
	}

	return null
}
