const TITAN_CHASSIS_IMAGE = "TitanChassisImage"
const TITAN_PRIMARY_IMAGE = "TitanPrimaryImage"
const TITAN_SPECIAL_IMAGE = "TitanSpecialImage"
const TITAN_ORDNANCE_IMAGE = "TitanOrdnanceImage"
const TITAN_DECAL_IMAGE = "TitanDecalImage"

const TITAN_CHASSIS_NAME = "TitanChassisName"
const TITAN_CORE_NAME = "TitanCoreName"
const TITAN_PRIMARY_NAME = "TitanPrimaryName"
const TITAN_SPECIAL_NAME = "TitanSpecialName"
const TITAN_ORDNANCE_NAME = "TitanOrdnanceName"
const TITAN_PRIMARY_MOD_NAME = "TitanPrimaryModName"
const TITAN_PASSIVE1_NAME = "TitanPassive1Name"
const TITAN_PASSIVE2_NAME = "TitanPassive2Name"

const TITAN_PRIMARY_MOD_ICON = "TitanPrimaryModIcon"
const TITAN_SPECIAL_ICON = "TitanSpecialIcon"
const TITAN_ORDNANCE_ICON = "TitanOrdnanceIcon"
const TITAN_PASSIVE1_ICON = "TitanPassive1Icon"
const TITAN_PASSIVE2_ICON = "TitanPassive2Icon"

const TITAN_PRIMARY_DESC = "TitanPrimaryDesc"
const TITAN_SPECIAL_DESC = "TitanSpecialDesc"
const TITAN_ORDNANCE_DESC = "TitanOrdnanceDesc"
const TITAN_PASSIVE1_DESC = "TitanPassive1Desc"
const TITAN_PASSIVE2_DESC = "TitanPassive2Desc"

const TITAN_OS_VOICE_IMAGE = "TitanOSVoiceImage"

function InitTitanLoadoutsMenu( menu )
{
	uiGlobal.navigateBackCallbacks[ menu ] <- TitanLoadoutsNavigateBack

	uiGlobal.focusedTitanLoadoutID <- null
	uiGlobal.registeredTitanLoadoutsIngameEditCallbacks <- false

	local buttons = GetElementsByClassname( menu, "SelectLoadoutButtonClass" )
	foreach ( button in buttons )
	{
		button.SetParentMenu( menu ) // TMP: should be code

		button.AddEventHandler( UIE_GET_FOCUS, OnTitanLoadoutButton_Focused )
		button.AddEventHandler( UIE_CLICK, OnTitanLoadoutButton_Activate )
	}

	AddMenuElementsByClassname( menu, TITAN_CHASSIS_IMAGE )
	AddMenuElementsByClassname( menu, TITAN_PRIMARY_IMAGE )
	AddMenuElementsByClassname( menu, TITAN_SPECIAL_IMAGE )
	AddMenuElementsByClassname( menu, TITAN_ORDNANCE_IMAGE )
	AddMenuElementsByClassname( menu, TITAN_DECAL_IMAGE )

	AddMenuElementsByClassname( menu, TITAN_CHASSIS_NAME )
	AddMenuElementsByClassname( menu, TITAN_CORE_NAME )
	AddMenuElementsByClassname( menu, TITAN_PRIMARY_NAME )
	AddMenuElementsByClassname( menu, TITAN_SPECIAL_NAME )
	AddMenuElementsByClassname( menu, TITAN_ORDNANCE_NAME )
	AddMenuElementsByClassname( menu, TITAN_PRIMARY_MOD_NAME )
	AddMenuElementsByClassname( menu, TITAN_PASSIVE1_NAME )
	AddMenuElementsByClassname( menu, TITAN_PASSIVE2_NAME )

	AddMenuElementsByClassname( menu, TITAN_PRIMARY_MOD_ICON )
	AddMenuElementsByClassname( menu, TITAN_SPECIAL_ICON )
	AddMenuElementsByClassname( menu, TITAN_ORDNANCE_ICON )
	AddMenuElementsByClassname( menu, TITAN_PASSIVE1_ICON )
	AddMenuElementsByClassname( menu, TITAN_PASSIVE2_ICON )

	AddMenuElementsByClassname( menu, TITAN_PRIMARY_DESC )
	AddMenuElementsByClassname( menu, TITAN_SPECIAL_DESC )
	AddMenuElementsByClassname( menu, TITAN_ORDNANCE_DESC )
	AddMenuElementsByClassname( menu, TITAN_PASSIVE1_DESC )
	AddMenuElementsByClassname( menu, TITAN_PASSIVE2_DESC )

	AddMenuElementsByClassname( menu, TITAN_OS_VOICE_IMAGE )

	AddMenuEventHandler(menu, R1DELTA_UIE_OPEN, OnOpenTitanLoadoutsMenu)
}

function InitEditTitanLoadoutsMenu( menu )
{
	local buttons = GetElementsByClassname( menu, "SelectLoadoutButtonClass" )
	foreach ( button in buttons )
	{
		button.SetParentMenu( menu ) // TMP: should be code

		button.AddEventHandler( UIE_GET_FOCUS, OnEditTitanLoadoutButton_Focused )
		button.AddEventHandler( UIE_LOSE_FOCUS, OnEditTitanLoadoutButton_LostFocus )
		button.AddEventHandler( UIE_CLICK, OnEditTitanLoadoutButton_Activate )
	}

	AddMenuElementsByClassname( menu, TITAN_CHASSIS_IMAGE )
	AddMenuElementsByClassname( menu, TITAN_PRIMARY_IMAGE )
	AddMenuElementsByClassname( menu, TITAN_SPECIAL_IMAGE )
	AddMenuElementsByClassname( menu, TITAN_ORDNANCE_IMAGE )
	AddMenuElementsByClassname( menu, TITAN_DECAL_IMAGE )

	AddMenuElementsByClassname( menu, TITAN_CHASSIS_NAME )
	AddMenuElementsByClassname( menu, TITAN_CORE_NAME )
	AddMenuElementsByClassname( menu, TITAN_PRIMARY_NAME )
	AddMenuElementsByClassname( menu, TITAN_SPECIAL_NAME )
	AddMenuElementsByClassname( menu, TITAN_ORDNANCE_NAME )
	AddMenuElementsByClassname( menu, TITAN_PRIMARY_MOD_NAME )
	AddMenuElementsByClassname( menu, TITAN_PASSIVE1_NAME )
	AddMenuElementsByClassname( menu, TITAN_PASSIVE2_NAME )

	AddMenuElementsByClassname( menu, TITAN_PRIMARY_MOD_ICON )
	AddMenuElementsByClassname( menu, TITAN_SPECIAL_ICON )
	AddMenuElementsByClassname( menu, TITAN_ORDNANCE_ICON )
	AddMenuElementsByClassname( menu, TITAN_PASSIVE1_ICON )
	AddMenuElementsByClassname( menu, TITAN_PASSIVE2_ICON )

	AddMenuElementsByClassname( menu, TITAN_PRIMARY_DESC )
	AddMenuElementsByClassname( menu, TITAN_SPECIAL_DESC )
	AddMenuElementsByClassname( menu, TITAN_ORDNANCE_DESC )
	AddMenuElementsByClassname( menu, TITAN_PASSIVE1_DESC )
	AddMenuElementsByClassname( menu, TITAN_PASSIVE2_DESC )

	AddMenuElementsByClassname( menu, TITAN_OS_VOICE_IMAGE )

	AddMenuEventHandler(menu, R1DELTA_UIE_OPEN, OnOpenEditTitanLoadoutsMenu)
}

function UpdateTitanLoadoutElems( menu, loadout, button = null )
{
	if ( button )
	{
		if ( HandleLockedMenuItem( menu, button ) )
			return
	}

	foreach ( element in menu.classElements[TITAN_PRIMARY_MOD_NAME] )
		SetTextFromSubitemName( element, loadout.primary, loadout.primaryMod, "#MOD_SELECT_STOCK" )

	foreach ( element in menu.classElements[TITAN_CHASSIS_IMAGE] )
		SetImageFromItemTeamImages( element, loadout.setFile, GetTeam() )


	foreach ( element in menu.classElements[TITAN_PRIMARY_IMAGE] )
		SetImageFromItemImage( element, loadout.primary )

	foreach ( element in menu.classElements[TITAN_SPECIAL_IMAGE] )
		SetImageFromItemImage( element, loadout.special )

	foreach ( element in menu.classElements[TITAN_ORDNANCE_IMAGE] )
		SetImageFromItemImage( element, loadout.ordnance )

	foreach ( element in menu.classElements[TITAN_DECAL_IMAGE] )
		SetImageFromItemImage( element, loadout.decal )


	foreach ( element in menu.classElements[TITAN_CHASSIS_NAME] )
		SetTextFromItemName( element, loadout.setFile )

	foreach ( element in menu.classElements[TITAN_CORE_NAME] )
		SetTextFromItemAdditionalName( element, loadout.setFile )

	foreach ( element in menu.classElements[TITAN_PRIMARY_NAME] )
		SetTextFromItemName( element, loadout.primary )

	foreach ( element in menu.classElements[TITAN_SPECIAL_NAME] )
		SetTextFromItemName( element, loadout.special )

	foreach ( element in menu.classElements[TITAN_ORDNANCE_NAME] )
		SetTextFromItemName( element, loadout.ordnance )

	foreach ( element in menu.classElements[TITAN_PASSIVE1_NAME] )
		SetTextFromItemName( element, loadout.passive1 )

	foreach ( element in menu.classElements[TITAN_PASSIVE2_NAME] )
		SetTextFromItemName( element, loadout.passive2 )


	foreach ( element in menu.classElements[TITAN_PRIMARY_MOD_ICON] )
		SetImageFromSubitemIcon( element, loadout.primary, loadout.primaryMod, MOD_ICON_NONE )

	foreach ( element in menu.classElements[TITAN_SPECIAL_ICON] )
		SetImageFromItemIcon( element, loadout.special )

	foreach ( element in menu.classElements[TITAN_ORDNANCE_ICON] )
		SetImageFromItemIcon( element, loadout.ordnance )

	foreach ( element in menu.classElements[TITAN_PASSIVE1_ICON] )
		SetImageFromItemIcon( element, loadout.passive1 )

	foreach ( element in menu.classElements[TITAN_PASSIVE2_ICON] )
		SetImageFromItemIcon( element, loadout.passive2 )


	foreach ( element in menu.classElements[TITAN_PRIMARY_DESC] )
		SetTextFromItemDescription( element, loadout.primary )

	foreach ( element in menu.classElements[TITAN_SPECIAL_DESC] )
		SetTextFromItemDescription( element, loadout.special )

	foreach ( element in menu.classElements[TITAN_ORDNANCE_DESC] )
		SetTextFromItemDescription( element, loadout.ordnance )

	foreach ( element in menu.classElements[TITAN_PASSIVE1_DESC] )
		SetTextFromItemDescription( element, loadout.passive1 )

	foreach ( element in menu.classElements[TITAN_PASSIVE2_DESC] )
		SetTextFromItemDescription( element, loadout.passive2 )

	foreach ( element in menu.classElements[TITAN_OS_VOICE_IMAGE] )
		SetImageFromItemIcon( element, loadout.voiceChoice )
}

function OnTitanLoadoutButton_Focused( button )
{
	local buttonID = button.GetScriptID().tointeger()
	local presetTitanLoadouts = UI_GetPresetTitanLoadouts()

	uiGlobal.focusedTitanLoadoutID = null

	local loadout
	if ( buttonID < presetTitanLoadouts.len() )
		loadout = UI_GetPresetTitanLoadout( button.loadoutID )
	else if ( buttonID >= presetTitanLoadouts.len() )
	{
		loadout = UI_GetCustomTitanLoadout( button.loadoutID )
		if ( !button.IsLocked() )
			uiGlobal.focusedTitanLoadoutID = button.loadoutID
	}

	if ( !loadout )
		return

	local menu = button.GetParentMenu()

	UpdateTitanLoadoutElems( menu, loadout, button )
}

function OnEditTitanLoadoutButton_LostFocus( button )
{
	if ( !("ref" in button.s) )
		return

	ClearRefNew( button.s.ref )
	button.SetNew( false )
}

function OnTitanLoadoutButton_Activate( button )
{
	DeregisterTitanLoadoutsIngameEditCallbacks()

	if ( !IsConnected() )
		return

	if ( button.IsLocked() )
		return

	Assert( GetActiveLevel() != "mp_lobby" ) // update this later to handle loadout pre-selection in the lobby

	local presetTitanLoadouts = UI_GetPresetTitanLoadouts()
	local customTitanLoadouts = UI_GetCustomTitanLoadouts()

	local buttonID = button.GetScriptID().tointeger()

	if ( buttonID < presetTitanLoadouts.len() )
	{
		local loadoutID = button.loadoutID
		Assert( loadoutID != null  && loadoutID < presetTitanLoadouts.len() )
		ClientCommand( "SetPresetTitanLoadout " + loadoutID )
	}
	else if ( buttonID >= presetTitanLoadouts.len() )
	{
		local loadoutID = button.loadoutID
		Assert( loadoutID != null  && loadoutID < customTitanLoadouts.len() )
		ClientCommand( "SetCustomTitanLoadout " + loadoutID )
	}

	//if ( !ShouldShowBurnCardMenu() )
		SetLoadoutSelectionFinished()

	if ( !uiGlobal.loadoutSelectionFinished )
		CloseTopMenu()
	else
		CloseAllInGameMenus()
}

function OnEditTitanLoadoutButton_Focused( button )
{
	local isCustom = ("isCustom" in button.s) && button.s.isCustom
	local loadout

	if ( isCustom )
		loadout = UI_GetCustomTitanLoadout( button.loadoutID )
	else
		loadout = UI_GetPresetTitanLoadout( button.loadoutID )

	if ( !loadout )
		return

	local menu = button.GetParentMenu()

	UpdateTitanLoadoutElems( menu, loadout, button )
}

function OnEditTitanLoadoutButton_Activate( button )
{
	if ( !IsConnected() )
		return

	if ( button.IsLocked() )
		return

	//Assert( GetActiveLevel() == "mp_lobby" )

	local isCustom = ("isCustom" in button.s) && button.s.isCustom

	if ( isCustom )
	{
		local loadoutID = button.loadoutID
		local customTitanLoadouts = UI_GetCustomTitanLoadouts()

		Assert( loadoutID != null && loadoutID < customTitanLoadouts.len() )

		local editMenu = GetMenu( "EditTitanLoadoutMenu" )
		editMenu.loadoutIDBeingEdited = loadoutID
		uiGlobal.loadoutBeingEdited = customTitanLoadouts[ loadoutID ]

		AdvanceMenu( editMenu )
	}
}

function RegisterTitanLoadoutsIngameEditCallbacks()
{
	if (!uiGlobal.registeredTitanLoadoutsIngameEditCallbacks)
	{
		RegisterButtonPressedCallback(BUTTON_Y, TitanLoadoutsIngameEditClick)
		RegisterButtonPressedCallback(MOUSE_RIGHT, TitanLoadoutsIngameEditClick)
		uiGlobal.registeredTitanLoadoutsIngameEditCallbacks = true;
	}
}
Globalize(RegisterTitanLoadoutsIngameEditCallbacks)

function DeregisterTitanLoadoutsIngameEditCallbacks()
{
	if (uiGlobal.registeredTitanLoadoutsIngameEditCallbacks)
	{
		DeregisterButtonPressedCallback(BUTTON_Y, TitanLoadoutsIngameEditClick)
		DeregisterButtonPressedCallback(MOUSE_RIGHT, TitanLoadoutsIngameEditClick)
		uiGlobal.registeredTitanLoadoutsIngameEditCallbacks = false;
	}
}
Globalize(DeregisterTitanLoadoutsIngameEditCallbacks)

function TitanLoadoutsNavigateBack()
{
	DeregisterTitanLoadoutsIngameEditCallbacks()

	if ( uiGlobal.loadoutSelectionFinished )
		return true

	AdvanceMenu( GetMenu( "PilotLoadoutsMenu" ) )
}

function TitanLoadoutsIngameEditClick(player)
{
	if (uiGlobal.focusedTitanLoadoutID == null) return

	DeregisterTitanLoadoutsIngameEditCallbacks()

	if ( !IsConnected() ) return

	if ( IsItemLocked( "titan_custom_loadout_" + (uiGlobal.focusedTitanLoadoutID + 1) ) )
		return

	local loadoutID = uiGlobal.focusedTitanLoadoutID
	local customTitanLoadouts = UI_GetCustomTitanLoadouts()

	Assert( loadoutID != null && loadoutID < customTitanLoadouts.len() )

	local editMenu = GetMenu( "EditTitanLoadoutMenu" )
	editMenu.loadoutIDBeingEdited = loadoutID
	uiGlobal.loadoutBeingEdited = customTitanLoadouts[ loadoutID ]

	AdvanceMenu( editMenu )
}

function OnOpenTitanLoadoutsMenu( menu )
{
	if ( !IsConnected() )
		return

	local isCustom = GetPersistentVar( "titanSpawnLoadout.isCustom" )
	local selectedIndex = GetPersistentVar( "titanSpawnLoadout.index" )
	local presetTitanLoadouts = UI_GetPresetTitanLoadouts()
	local customTitanLoadouts = UI_GetCustomTitanLoadouts()
	local buttons = GetElementsByClassname( menu, "SelectLoadoutButtonClass" )

	RegisterTitanLoadoutsIngameEditCallbacks()

	if ( IsItemLocked( "titan_custom_loadout_1" ) )
	{
		HideGamemodeLoadouts( menu )
		HideCustomLoadoutHeader( menu )
	}
	else
	{
		ShowCustomLoadoutHeader( menu )
		UpdateGamemodeLoadoutHeader( menu )
	}

	local gamemodeLoadoutsShown = 0
	foreach ( index, button in buttons )
	{
		if ( "ref" in button.s )
			delete button.s.ref

		local buttonID = button.GetScriptID().tointeger()

		if ( buttonID < presetTitanLoadouts.len() )
		{
			button.loadoutID = buttonID
			button.s.ref <- "titan_preset_loadout_" + (button.loadoutID + 1)

			local loadout = UI_GetPresetTitanLoadout( button.loadoutID )
			if ( !loadout )
			{
				ClearButton( button )
				continue
			}

			button.SetText( GetLoadoutName( loadout ) )
			button.SetEnabled( true )
			button.SetLocked( IsItemLocked( button.s.ref ) )
			//button.SetNew( HasAnyNewItem( button.s.ref ) )

			if ( !isCustom && buttonID == selectedIndex )
			{
				button.SetSelected( true )

				//if ( IsControllerModeActive() )
					thread DelayedFocus( button )
			}
			else
			{
				button.SetSelected( false )
			}
		}
		else if ( buttonID < presetTitanLoadouts.len() + customTitanLoadouts.len() )
		{
			if ( IsItemLocked( "titan_custom_loadout_1" ) )
			{
				ClearButton( button )
				continue
			}

			if ( buttonID < presetTitanLoadouts.len() + NUM_CUSTOM_LOADOUTS )
			{
				// common loadout slot
				button.loadoutID = buttonID - presetTitanLoadouts.len()
			}
			else if ( PersistenceEnumValueIsValid( "gameModesWithLoadouts", GetLoadoutGamemode() ) )
			{
				// gamemode specific slot. Offset loadout ID for the game mode
				local currentModeIndex = PersistenceGetEnumIndexForItemName( "gameModesWithLoadouts", GetLoadoutGamemode() )
				button.loadoutID = buttonID - presetTitanLoadouts.len() + (currentModeIndex * NUM_GAMEMODE_LOADOUTS)

				gamemodeLoadoutsShown++
			}
			else
			{
				ClearButton( button )
				continue
			}

			button.s.ref <- "titan_custom_loadout_" + (button.loadoutID + 1)

			local loadout = UI_GetCustomTitanLoadout( button.loadoutID )
			if ( !loadout || gamemodeLoadoutsShown > NUM_GAMEMODE_LOADOUTS )
			{
				ClearButton( button )
				continue
			}

			button.SetUTF8Text( GetLoadoutName( loadout ) )
			button.SetEnabled( true )
			button.SetLocked( IsItemLocked( button.s.ref ) )
			//button.SetNew( HasAnyNewItem( button.s.ref ) )

			if ( isCustom && button.loadoutID == selectedIndex )
			{
				button.SetSelected( true )

				//if ( IsControllerModeActive() )
					thread DelayedFocus( button )
			}
			else
			{
				button.SetSelected( false )
			}
		}
		else
		{
			ClearButton( button )
		}
	}
}

function ClearButton( button )
{
	button.SetText( "" )
	button.SetEnabled( false )
	button.SetLocked( false )
	button.SetNew( false )
	button.SetSelected( false )
}

function OnOpenEditTitanLoadoutsMenu( menu )
{
	if ( level.ui.nextMapModeComboIndex == null && !uiGlobal.toggleLoadoutGameModeButtonRegistered && !IsItemLocked( "titan_custom_loadout_1" ) )
	{
		RegisterButtonPressedCallback( BUTTON_Y, ToggleLoadoutGamemode )
		uiGlobal.toggleLoadoutGameModeButtonRegistered = true
	}

	uiGlobal.currentEditLoadoutMenuName = menu.GetName()
	local buttons = GetElementsByClassname( menu, "SelectLoadoutButtonClass" )

	if ( IsItemLocked( "titan_custom_loadout_1" ) )
		ShowOnlyPresetTitanButtons( menu, buttons )
	else
		ShowOnlyCustomTitanButtons( menu, buttons )

	if ( uiGlobal.loadoutBeingEdited != null )
		UpdateTitanLoadoutElems( menu, uiGlobal.loadoutBeingEdited )
}

function OnCloseEditTitanLoadoutsMenu()
{
	if ( uiGlobal.toggleLoadoutGameModeButtonRegistered )
	{
		DeregisterButtonPressedCallback( BUTTON_Y, ToggleLoadoutGamemode )
		uiGlobal.toggleLoadoutGameModeButtonRegistered = false
	}
	uiGlobal.loadoutBeingEdited = null
}

function ShowOnlyPresetTitanButtons( menu, buttons )
{
	local presetTitanLoadouts = UI_GetPresetTitanLoadouts()
	local customTitanLoadouts = UI_GetCustomTitanLoadouts()

	local cat1Labels = GetElementsByClassname( menu, "LblCommonLoadoutSubheaderText" )
	foreach( label in cat1Labels )
		label.SetText( "#MENU_PILOT_LOADOUTS_SUBCAT_PRESET" )

	HideGamemodeLoadouts( menu )

	foreach ( index, button in buttons )
	{
		if ( "ref" in button.s )
			delete button.s.ref

		if ( "isCustom" in button.s )
			delete button.s.isCustom

		local buttonID = button.GetScriptID().tointeger()

		if ( buttonID < presetTitanLoadouts.len() )
		{
			button.loadoutID = buttonID
			button.s.ref <- "titan_preset_loadout_" + (button.loadoutID + 1)

			local loadout = UI_GetPresetTitanLoadout( button.loadoutID )
			if ( !loadout )
			{
				ClearButton( button )
				continue
			}

			button.SetText( GetLoadoutName( loadout ) )
			button.SetEnabled( true )
			button.SetLocked( IsItemLocked( button.s.ref ) )
			button.SetNew( HasAnyNewItem( button.s.ref ) )
		}
		else
		{
			ClearButton( button )
		}
	}
}

function ShowOnlyCustomTitanButtons( menu, buttons )
{
	local customTitanLoadouts = UI_GetCustomTitanLoadouts()

	local cat1Labels = GetElementsByClassname( menu, "LblCommonLoadoutSubheaderText" )
	foreach( label in cat1Labels )
		label.SetText( "#MENU_PILOT_LOADOUTS_SUBCAT_COMMON" )

	UpdateGamemodeLoadoutHeader( menu )

	local gamemodeLoadoutsShown = 0
	foreach ( index, button in buttons )
	{
		if ( "ref" in button.s )
			delete button.s.ref

		if ( "isCustom" in button.s )
			delete button.s.isCustom

		local buttonID = button.GetScriptID().tointeger()

		if ( buttonID < customTitanLoadouts.len() )
		{
			if ( buttonID < NUM_CUSTOM_LOADOUTS )
			{
				// common loadout slot
				button.loadoutID = buttonID
			}
			else if ( PersistenceEnumValueIsValid( "gameModesWithLoadouts", GetLoadoutGamemode() ) )
			{
				// gamemode specific slot. Offset loadout ID for the game mode
				gamemodeLoadoutsShown++
				local currentModeIndex = PersistenceGetEnumIndexForItemName( "gameModesWithLoadouts", GetLoadoutGamemode() )
				button.loadoutID = buttonID + (currentModeIndex * NUM_GAMEMODE_LOADOUTS)
			}
			else
			{
				ClearButton( button )
				continue
			}

			button.s.ref <- "titan_custom_loadout_" + (button.loadoutID + 1)
			button.s.isCustom <- true

			local loadout = UI_GetCustomTitanLoadout( button.loadoutID )
			if ( !loadout || gamemodeLoadoutsShown > NUM_GAMEMODE_LOADOUTS )
			{
				ClearButton( button )
				continue
			}

			button.SetUTF8Text( GetLoadoutName( loadout ) )
			button.SetEnabled( true )
			button.SetLocked( IsItemLocked( button.s.ref ) )
			button.SetNew( HasAnyNewItem( button.s.ref ) )
		}
		else
		{
			ClearButton( button )
		}
	}
}

function DelayedFocus( button )
{
	WaitEndFrame()

	button.SetFocused()
}