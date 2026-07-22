const MAP_LIST_VISIBLE_ROWS = 17
const MAP_LIST_SCROLL_SPEED = 0
function main()
{
	Globalize( InitAddonsMenu )
	Globalize( UpdateAddonPaths )
	Globalize( ResetUIScript )
	Globalize( OpenAddonFolder )
}


function OnOpenAddonsMenu() {

	file.numMapButtonsOffScreen = 32 - MAP_LIST_VISIBLE_ROWS
	file.addons = GetMods()

	RegisterButtonPressedCallback( BUTTON_X, UpdateAddonPaths )
	RegisterButtonPressedCallback( BUTTON_SHOULDER_RIGHT, OpenAddonFolder ) // BUTTON_Y

	RegisterButtonPressedCallback( MOUSE_WHEEL_UP, OnMapListScrollUp_Activate )
	RegisterButtonPressedCallback( MOUSE_WHEEL_DOWN, OnMapListScrollDown_Activate )
}

function OnCloseAddonsMenu()
{
	DeregisterButtonPressedCallback( BUTTON_X, UpdateAddonPaths )
	DeregisterButtonPressedCallback( BUTTON_SHOULDER_RIGHT, OpenAddonFolder ) // BUTTON_Y

	DeregisterButtonPressedCallback( MOUSE_WHEEL_UP, OnMapListScrollUp_Activate )
	DeregisterButtonPressedCallback( MOUSE_WHEEL_DOWN, OnMapListScrollDown_Activate )
}

function InitAddonsMenu( menu )
{
	file.menu <- menu
	file.mapListScrollState <- 0
	file.numMapButtonsOffScreen <- null

	local var = GetMods()
	file.addons <- {}
	file.addons = var

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnOpenAddonsMenu )
	AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, OnCloseAddonsMenu )

	file.menu.GetChild("MapButtonsPanel").SetVisible( true )
	AddEventHandlerToButtonClass( menu, "MapListScrollUpClass", UIE_CLICK, Bind( OnMapListScrollUp_Activate ) )
	AddEventHandlerToButtonClass( menu, "MapListScrollDownClass", UIE_CLICK, Bind( OnMapListScrollDown_Activate ) )
	file.buttons <- GetElementsByClassname( menu, "MapButtonClass" )

	foreach(i,button in file.buttons) {
		button.SetVisible( false )
	}
	foreach(i,table in var) {
		file.buttons[i].SetText( table["name"] )
		file.buttons[i].SetVisible( true )
		// file.buttons[i].SetScriptID( i )
		file.buttons[i].SetSelected(table["enabled"])
		file.buttons[i].AddEventHandler( UIE_CLICK, OnAddonsMenu )
		file.buttons[i].AddEventHandler( UIE_GET_FOCUS, Bind( ChangePreviewUI ) )
	}
	file.numMapButtonsOffScreen = 32 - MAP_LIST_VISIBLE_ROWS
}	

function ScrollDown( button )
{
	local scrollPanel = button.GetParent().GetChild("MapButtonsPanel")
	scrollPanel.ScrollDown( 1 )
}

function ChangePreviewUI( button )
{

	local script_id = button.GetScriptID().tointeger()
	local table = file.addons[script_id]
	local name = table["name"]
	local desc = table["description"]
	local author = table["author"]
	local version = table["version"]

	file.menu.GetChild( "AddonImage" ).SetVisible( true )
	file.menu.GetChild( "AddonImageFrame" ).SetVisible( true )

	if(table["image"] != "common/l4d_spinner") {
		file.menu.GetChild("AddonImage").SetImage( table["image"] )
		file.menu.GetChild("AddonImage").SetColor( 255, 255, 255 )
	}
	else {
		file.menu.GetChild("AddonImage").SetImage("white")
		file.menu.GetChild("AddonImage").ReturnToBaseColor()
	}

	if( desc == "Description_Here" )
		desc = "No Description"
	
	if( author == "Author_Name_Here" )
		author = "No Author"

	if( version == "Version_Here" )
		version = "No Version"

	file.menu.GetChild("AddonName").SetVisible( true)
	file.menu.GetChild("AddonName").SetText( name)

	file.menu.GetChild("AddonDesc").SetVisible( true )
	file.menu.GetChild("AddonDesc").SetText( desc )

	file.menu.GetChild("StarsLabel").SetText(author)
	file.menu.GetChild("VersionLabel").SetVisible( true )
	file.menu.GetChild("VersionLabel").SetText( version )

}

function OnAddonsMenu( button )
{
	local script_id = button.GetScriptID().tointeger()
	print("script_id: " + script_id)
	if ( button.IsSelected() )
	{
		button.SetSelected( false )
		UpdateAddons(script_id,false)
	}
	else
	{
		button.SetSelected( true )
		UpdateAddons(script_id ,true)
	}
	ClientCommand( "update_addon_paths" )
}

function UpdateAddonPaths( button )
{
    ClientCommand( "update_addon_paths" )
	ClientCommand( "uiscript_reset" )
	ClientCommand( "reload_localization")
	ClientCommand( "loadPlaylists" )
	ClientCommand( "hud_reloadscheme" )
}

function OpenAddonFolder( button )
{
	GetAddonsPath(button)
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