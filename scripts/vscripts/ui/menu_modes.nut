
function main()
{
	Globalize( InitModesMenu )
	Globalize( OnOpenModesMenu )
	Globalize( OnCloseModesMenu )

	file.modeChoices <- []
	file.modeChoices.append( "random" )
	file.modeChoices.append( "at" )
	file.modeChoices.append( "ctf" )
	file.modeChoices.append( "cp" )
	file.modeChoices.append( "lts" )
	file.modeChoices.append( "tdm" )
}

function InitModesMenu( menu )
{
	file.menu <- menu
	file.currentChoice <- 0

	AddEventHandlerToButtonClass( menu, "ModeClass", UIE_CLICK, Bind( OnModeButton_Activate ) )
	AddEventHandlerToButtonClass( menu, "ModeClass", UIE_GET_FOCUS, Bind( OnModeButton_Focused ) )
}

function OnOpenModesMenu()
{
	local buttons = GetElementsByClassname( file.menu, "ModeClass" )
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

function OnCloseModesMenu()
{
}

function OnModeButton_Focused( button )
{
	/*local mapName = GetModeChoiceFromIndex( button.GetScriptID().tointeger() )
	local mapImage = "../ui/menu/lobby/lobby_image_" + mapName

	local mapImageElem = file.menu.GetChild( "ModeImage" )
	local mapNameElem = file.menu.GetChild( "ModeName" )

	mapImageElem.SetImage( mapImage )
	mapNameElem.SetText( GetMapDisplayName( mapName ) )*/
}

function OnModeButton_Activate( button )
{
	/*local mapName = GetModeChoiceFromIndex( button.GetScriptID().tointeger() )

	printt( "Chose map:", mapName )

	// TODO: Set something to record the map chosen
	file.currentChoice = button.GetScriptID().tointeger()

	CloseTopMenu()*/
}

function GetModeChoiceFromIndex( index )
{
	return file.modeChoices[index]
}

