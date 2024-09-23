
function main()
{
	Globalize( InitEditPilotLoadoutMenu )
	Globalize( OnOpenEditPilotLoadoutMenu )
	Globalize( OnCloseEditPilotLoadoutMenu )
	Globalize( OnNavigateBackEditPilotLoadoutMenu )
	Globalize( GetPilotLoadoutRenameText )
	Globalize( SetPilotLoadoutName )
	Globalize( SelectPilotLoadoutRenameText )
	Globalize( ToggleCurrentLoadoutGender )
}

function InitEditPilotLoadoutMenu()
{
	file.menu <- GetMenu( "EditPilotLoadoutMenu" )
	local menu = file.menu

	uiGlobal.navigateBackCallbacks[ menu ] <- Bind( OnNavigateBackEditPilotLoadoutMenu )

	local buttons = GetElementsByClassname( menu, "PilotPrimaryClass" )
	buttons.extend( GetElementsByClassname( menu, "PilotSecondaryClass" ) )
	buttons.extend( GetElementsByClassname( menu, "PilotSidearmClass" ) )
	buttons.extend( GetElementsByClassname( menu, "PilotAbilityClass" ) )
	buttons.extend( GetElementsByClassname( menu, "PilotOrdnanceClass" ) )
	buttons.extend( GetElementsByClassname( menu, "PilotPassiveClass" ) )
	foreach ( button in buttons )
	{
		button.SetParentMenu( menu )
		button.AddEventHandler( UIE_CLICK, OnEditPilotSlotButton_Activate )
	}

	file.menuTitle <- menu.GetChild( "MenuTitle" )
	file.renameEditBox <- menu.GetChild( "RenameEditBox" )
	file.cancellingRename <- false
	file.menuClosing <- false

	AddEventHandlerToButton( menu, "RenameEditBox", UIE_LOSE_FOCUS, Bind( OnRenameEditBox_LostFocus ) )
}

function OnOpenEditPilotLoadoutMenu()
{
	local menu = file.menu

	AddMenuElementsByClassname( menu, PILOT_BODY_IMAGE )
	AddMenuElementsByClassname( menu, PILOT_PRIMARY_IMAGE )
	AddMenuElementsByClassname( menu, PILOT_SECONDARY_IMAGE )
	AddMenuElementsByClassname( menu, PILOT_SIDEARM_IMAGE )

	AddMenuElementsByClassname( menu, PILOT_PRIMARY_NAME )
	AddMenuElementsByClassname( menu, PILOT_PRIMARY_ATTACHMENT_NAME )
	AddMenuElementsByClassname( menu, PILOT_PRIMARY_MOD_NAME )
	AddMenuElementsByClassname( menu, PILOT_SECONDARY_NAME )
	AddMenuElementsByClassname( menu, PILOT_SIDEARM_NAME )
	AddMenuElementsByClassname( menu, PILOT_SPECIAL_NAME )
	AddMenuElementsByClassname( menu, PILOT_ORDNANCE_NAME )
	AddMenuElementsByClassname( menu, PILOT_PASSIVE1_NAME )
	AddMenuElementsByClassname( menu, PILOT_PASSIVE2_NAME )
	AddMenuElementsByClassname( menu, PILOT_RACE_NAME )

	AddMenuElementsByClassname( menu, PILOT_PRIMARY_ATTACHMENT_ICON )
	AddMenuElementsByClassname( menu, PILOT_PRIMARY_MOD_ICON )
	AddMenuElementsByClassname( menu, PILOT_SPECIAL_ICON )
	AddMenuElementsByClassname( menu, PILOT_ORDNANCE_ICON )
	AddMenuElementsByClassname( menu, PILOT_PASSIVE1_ICON )
	AddMenuElementsByClassname( menu, PILOT_PASSIVE2_ICON )

	AddMenuElementsByClassname( menu, PILOT_PRIMARY_DESC )
	AddMenuElementsByClassname( menu, PILOT_SECONDARY_DESC )
	AddMenuElementsByClassname( menu, PILOT_SIDEARM_DESC )
	AddMenuElementsByClassname( menu, PILOT_SPECIAL_DESC )
	AddMenuElementsByClassname( menu, PILOT_ORDNANCE_DESC )
	AddMenuElementsByClassname( menu, PILOT_PASSIVE1_DESC )
	AddMenuElementsByClassname( menu, PILOT_PASSIVE2_DESC )

	local loadout = UI_GetCustomPilotLoadout( menu.loadoutIDBeingEdited )
	local loadoutName = GetLoadoutName( loadout )

	file.menuTitle.SetUTF8Text( loadoutName )
	file.renameEditBox.SetUTF8Text( loadoutName )
	file.menuClosing = false

	UpdatePilotLoadoutElems( menu, loadout )
	UpdateEditPilotLoadoutNewStatus()

	////////////////////////////////////////////////////////////////////// BME

	local isCustom = GetPersistentVar( "pilotSpawnLoadout.isCustom" )
	local selectedIndex = GetPersistentVar( "pilotSpawnLoadout.index" )

	if (IsFullyConnected() && GetActiveLevel() != "mp_lobby")
	{
		RegisterPilotLoadoutsIngameEditCallbacks()
		if (isCustom && menu.loadoutIDBeingEdited == selectedIndex)
		{
			// we are in-game and we just edited our currently selected loadout, change it to something else and back to refresh

			if (selectedIndex != 0) ClientCommand( "SetCustomPilotLoadout 0" )
			if (selectedIndex == 0) ClientCommand( "SetCustomPilotLoadout 1" )
			ClientCommand( "InGameMenuClosed" )

			ClientCommand( "SetCustomPilotLoadout " + selectedIndex )
			ClientCommand( "InGameMenuClosed" )
		}
	}
}

function OnCloseEditPilotLoadoutMenu()
{
	file.menuClosing = true
}

function OnNavigateBackEditPilotLoadoutMenu()
{
	local menu = file.menu

	////////////////////////////////////////////////////////////////////// BME
	local isCustom = GetPersistentVar( "pilotSpawnLoadout.isCustom" )
	local selectedIndex = GetPersistentVar( "pilotSpawnLoadout.index" )

	if (IsFullyConnected() && GetActiveLevel() != "mp_lobby")
	{
		RegisterPilotLoadoutsIngameEditCallbacks()
		if (isCustom && menu.loadoutIDBeingEdited == selectedIndex)
		{
			// we are in-game and we just edited our currently selected loadout, change it to something else and back to refresh

			if (selectedIndex != 0) ClientCommand( "SetCustomPilotLoadout 0" )
			if (selectedIndex == 0) ClientCommand( "SetCustomPilotLoadout 1" )
			ClientCommand( "InGameMenuClosed" )

			ClientCommand( "SetCustomPilotLoadout " + selectedIndex )
			ClientCommand( "InGameMenuClosed" )
		}
	}
	//////////////////////////////////////////////////////////////////////

	if ( !Durango_IsDurango() && GetFocus() == file.renameEditBox )
	{
		file.cancellingRename = true
		FocusDefault( menu )

		return
}

	if ( uiGlobal.activeMenu == menu )
		CloseTopMenu()
}

function UpdateEditPilotLoadoutNewStatus()
{
	local menu = file.menu
	local buttons

	buttons = GetElementsByClassname( menu, "PilotPrimaryClass" )
	foreach( button in buttons )
	{
		button.SetNew( HasAnyNewItem( itemType.PILOT_PRIMARY ) )
	}

	buttons = GetElementsByClassname( menu, "PilotSecondaryClass" )
	foreach( button in buttons )
	{
		button.SetNew( HasAnyNewItem( itemType.PILOT_SECONDARY ) )
	}

	buttons = GetElementsByClassname( menu, "PilotSidearmClass" )
	foreach( button in buttons )
	{
		button.SetNew( HasAnyNewItem( itemType.PILOT_SIDEARM ) )
	}

	buttons = GetElementsByClassname( menu, "PilotAbilityClass" )
	foreach( button in buttons )
	{
		button.SetNew( HasAnyNewItem( itemType.PILOT_SPECIAL ) )
	}

	buttons = GetElementsByClassname( menu, "PilotOrdnanceClass" )
	foreach( button in buttons )
	{
		button.SetNew( HasAnyNewItem( itemType.PILOT_ORDNANCE ) )
	}

	buttons = GetElementsByClassname( menu, "PilotPassiveClass" )
	foreach( button in buttons )
	{
		local buttonID = button.GetScriptID().tointeger()

		if ( buttonID == 5 )
			button.SetNew( HasAnyNewItem( itemType.PILOT_PASSIVE1 ) )
		else if ( buttonID == 6 )
			button.SetNew( HasAnyNewItem( itemType.PILOT_PASSIVE2 ) )
	}
}


function OnEditPilotSlotButton_Activate( button )
{
	local buttonID = button.GetScriptID().tointeger()
	uiGlobal.loadoutTypeBeingEdited = "pilot"

	switch ( buttonID )
	{
		case 0:
			uiGlobal.itemTypeBeingEdited = itemType.PILOT_PRIMARY
			OpenSubmenu( GetMenu( "WeaponSelectMenu" ) )
			break

		case 1:
			uiGlobal.itemTypeBeingEdited = itemType.PILOT_SECONDARY
			OpenSubmenu( GetMenu( "WeaponSelectMenu" ) )
			break

		case 2:
			uiGlobal.itemTypeBeingEdited = itemType.PILOT_SIDEARM
			OpenSubmenu( GetMenu( "WeaponSelectMenu" ) )
			break

		case 3:
			uiGlobal.itemTypeBeingEdited = itemType.PILOT_SPECIAL
			OpenSubmenu( GetMenu( "AbilitySelectMenu" ) )
			break

		case 4:
			uiGlobal.itemTypeBeingEdited = itemType.PILOT_ORDNANCE
			OpenSubmenu( GetMenu( "AbilitySelectMenu" ) )
			break

		case 5:
			uiGlobal.itemTypeBeingEdited = itemType.PILOT_PASSIVE1
			OpenSubmenu( GetMenu( "PassiveSelectMenu" ) )
			break

		case 6:
			uiGlobal.itemTypeBeingEdited = itemType.PILOT_PASSIVE2
			OpenSubmenu( GetMenu( "PassiveSelectMenu" ) )
			break

		case 7:
			ToggleCurrentLoadoutGender()
			break

		default:
			break
	}
}


function ToggleCurrentLoadoutGender()
{
	Assert( uiGlobal.loadoutTypeBeingEdited == "pilot" )

	local menu = file.menu
	local loadoutIndex = menu.loadoutIDBeingEdited
	local loadout = UI_GetCustomPilotLoadout( loadoutIndex )
	local count = PersistenceGetEnumCount( "pilotRace" )
	local race = loadout.race

	if ( race == null )
		race = PersistenceGetEnumItemNameForIndex( "pilotRace", 0 )

	local index = PersistenceGetEnumIndexForItemName( "pilotRace", race )

	// cycle through the options
	index++
	index %= count
	race = PersistenceGetEnumItemNameForIndex( "pilotRace", index )

	UI_SetLoadoutProperty( uiGlobal.loadoutTypeBeingEdited, loadoutIndex, "race", race )
	UpdatePilotLoadoutElems( menu, loadout, null)
}


function OnRenameEditBox_LostFocus( elem )
{
	if ( file.menuClosing )
		return

	local menu = file.menu
	local oldName = GetLoadoutName( UI_GetCustomPilotLoadout( menu.loadoutIDBeingEdited ) )
	local newName = GetPilotLoadoutRenameText()

	// If all whitespace entered reset to previous name
	newName = strip( newName )
	if ( newName == "" || file.cancellingRename )
		newName = oldName

	file.cancellingRename = false

	SetPilotLoadoutName( newName )

	if ( newName != oldName )
		EmitUISound( "Menu.Accept" )
}


function GetPilotLoadoutRenameText()
{
	return file.renameEditBox.GetTextEntryUTF8Text()
}


function SetPilotLoadoutName( name )
{
	local menu = file.menu

	if ( LoadoutNameIsToken( name ) )
		name = TranslateTokenToUTF8( name )

	name = strip(name)
	if (name == "")
		return

	file.menuTitle.SetUTF8Text( name )
	file.renameEditBox.SetUTF8Text( name )

	if ( IsConnected() )
	{
		UI_SetLoadoutProperty( "pilot", menu.loadoutIDBeingEdited, "name", name )
	}
}


function SelectPilotLoadoutRenameText()
{
	file.renameEditBox.SelectAll()
}