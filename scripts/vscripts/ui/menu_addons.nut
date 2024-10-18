const MAP_LIST_VISIBLE_ROWS = 17
const MAP_LIST_SCROLL_SPEED = 0
function main()
{
	Globalize( InitAddonsMenu )
	Globalize( UpdateAddonPaths )
	Globalize( ResetUIScript )
}

function InitAddonsMenu( menu )
{
	file.menu <- menu
	file.mapListScrollState <- 0
	file.numMapButtonsOffScreen <- null
	uiGlobal.menu <- menu
	file.menu.GetChild("NextMapImage").SetImage( "ui/menu/lobby/map_star_empty" )

	file.menu.GetChild("MapButtonsPanel").GetChild("MapButton0").SetText( "ui/menu/lobby/map_star_empty" )
	
	file.menu.GetChild("MapButtonsPanel").SetVisible( true )
	AddEventHandlerToButtonClass( menu, "MapListScrollUpClass", UIE_CLICK, Bind( OnMapListScrollUp_Activate ) )
	AddEventHandlerToButtonClass( menu, "MapListScrollDownClass", UIE_CLICK, Bind( OnMapListScrollDown_Activate ) )
	file.buttons <- GetElementsByClassname( menu, "MapButtonClass" )
	foreach ( i,button in GetElementsByClassname( file.menu, "MapButtonClass" ) )
	{
		button.SetText( "Hello " + i )
		button.SetVisible( true )
		button.SetEnabled( true )
		
		button.AddEventHandler( UIE_CLICK, OnAddonsMenu )
		button.AddEventHandler( UIE_GET_FOCUS, ChangePreviewUI )
		
	}
	file.menu.GetChild("MapButtonsPanel").GetChild("MapButton0").SetEnabled( true )
	file.menu.GetChild("MapButtonsPanel").GetChild("MapButton0").SetVisible( true )
	file.menu.GetChild("NextMapImage").SetImage( "ui/menu/lobby/map_star_empty" )
	file.menu.GetChild("NextMapImage").SetVisible( true )
	file.menu.GetChild("NextMapName").SetText( "hi" )
	file.numMapButtonsOffScreen = 32 - MAP_LIST_VISIBLE_ROWS

	RegisterButtonPressedCallback( MOUSE_WHEEL_UP, OnMapListScrollUp_Activate )
	RegisterButtonPressedCallback( MOUSE_WHEEL_DOWN, OnMapListScrollDown_Activate )
}	

function ScrollDown( button )
{
	local scrollPanel = button.GetParent().GetChild("MapButtonsPanel")
	scrollPanel.ScrollDown( 1 )
}

function ChangePreviewUI( button )
{

	local script_id = button.GetScriptID().tointeger()
	
	button.SetText( "Hello " + script_id  )

	uiGlobal.menu.GetChild("NextMapName").SetText( "Hello: " + script_id)
	ClientCommand("echo")
}

function OnAddonsMenu( button )
{
	
	if ( button.IsSelected() )
	{
		button.SetSelected( false )
	}
	else
	{
		button.SetSelected( true )
	}

	// update the preview image
	uiGlobal.menu.GetChild("NextMapImage").SetImage( "ui/menu/lobby/map_star_empty" )

}

function UpdateAddonPaths( button )
{
    ClientCommand( "update_addon_paths" )
}

function ResetUIScript( button )
{
	ClientCommand( "uiscript_reset" )
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