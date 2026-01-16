
function main()
{
	Globalize( InitMapsMenu )
	Globalize( OnOpenMapsMenu )
	Globalize( OnCloseMapsMenu )

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
}

function InitMapsMenu( menu )
{
	file.menu <- menu
	file.currentChoice <- 0

	AddEventHandlerToButtonClass( menu, "MapClass", UIE_CLICK, Bind( OnMapButton_Activate ) )
	AddEventHandlerToButtonClass( menu, "MapClass", UIE_GET_FOCUS, Bind( OnMapButton_Focused ) )
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
