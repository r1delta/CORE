const PILOT_BODY_IMAGE = "PilotBodyImage"
const PILOT_PRIMARY_IMAGE = "PilotPrimaryImage"
const PILOT_SECONDARY_IMAGE = "PilotSecondaryImage"
const PILOT_SIDEARM_IMAGE = "PilotSidearmImage"

const PILOT_PRIMARY_NAME = "PilotPrimaryName"
const PILOT_PRIMARY_ATTACHMENT_NAME = "PilotPrimaryAttachmentName"
const PILOT_PRIMARY_MOD_NAME = "PilotPrimaryModName"
const PILOT_SECONDARY_NAME = "PilotSecondaryName"
const PILOT_SIDEARM_NAME = "PilotSidearmName"
const PILOT_SPECIAL_NAME = "PilotSpecialName"
const PILOT_ORDNANCE_NAME = "PilotOrdnanceName"
const PILOT_PASSIVE1_NAME = "PilotPassive1Name"
const PILOT_PASSIVE2_NAME = "PilotPassive2Name"
const PILOT_RACE_NAME = "PilotRace2Name"

const PILOT_PRIMARY_ATTACHMENT_ICON = "PilotPrimaryAttachmentIcon"
const PILOT_PRIMARY_MOD_ICON = "PilotPrimaryModIcon"
const PILOT_SPECIAL_ICON = "PilotSpecialIcon"
const PILOT_ORDNANCE_ICON = "PilotOrdnanceIcon"
const PILOT_PASSIVE1_ICON = "PilotPassive1Icon"
const PILOT_PASSIVE2_ICON = "PilotPassive2Icon"

const PILOT_PRIMARY_DESC = "PilotPrimaryDesc"
const PILOT_SECONDARY_DESC = "PilotSecondaryDesc"
const PILOT_SIDEARM_DESC = "PilotSidearmDesc"
const PILOT_SPECIAL_DESC = "PilotSpecialDesc"
const PILOT_ORDNANCE_DESC = "PilotOrdnanceDesc"
const PILOT_PASSIVE1_DESC = "PilotPassive1Desc"
const PILOT_PASSIVE2_DESC = "PilotPassive2Desc"

const PILOT_RACE_DESC = "PilotRace2Desc"

function InitPilotLoadoutsMenu( menu )
{
	uiGlobal.navigateBackCallbacks[ menu ] <- PilotLoadoutsNavigateBack

	local buttons = GetElementsByClassname( menu, "SelectLoadoutButtonClass" )
	foreach ( button in buttons )
	{
		button.SetParentMenu( menu ) // TMP: should be code

		button.AddEventHandler( UIE_GET_FOCUS, OnPilotLoadoutButton_Focused )
		button.AddEventHandler( UIE_CLICK, OnPilotLoadoutButton_Activate )
	}

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
}

function InitEditPilotLoadoutsMenu( menu )
{
	local buttons = GetElementsByClassname( menu, "SelectLoadoutButtonClass" )
	foreach ( button in buttons )
	{
		button.SetParentMenu( menu ) // TMP: should be code

		button.AddEventHandler( UIE_GET_FOCUS, OnEditPilotLoadoutButton_Focused )
		button.AddEventHandler( UIE_LOSE_FOCUS, OnEditPilotLoadoutButton_LostFocus )
		button.AddEventHandler( UIE_CLICK, OnEditPilotLoadoutButton_Activate )
	}

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
}

function UpdatePilotLoadoutElems( menu, loadout, button = null )
{
	if ( button )
	{
		if ( HandleLockedMenuItem( menu, button ) )
			return
	}

	local isFemale = loadout.race == RACE_HUMAN_FEMALE

	local setFile = GetSetFileFromPrimaryWeaponAndPersistentData( loadout.primary, isFemale )
	foreach ( element in menu.classElements[PILOT_BODY_IMAGE] )
		SetImageFromItemTeamImages( element, setFile, GetTeam() )

	foreach ( element in menu.classElements[PILOT_PRIMARY_IMAGE] )
		SetImageFromItemImage( element, loadout.primary )

	foreach ( element in menu.classElements[PILOT_SECONDARY_IMAGE] )
		SetImageFromItemImage( element, loadout.secondary )

	foreach ( element in menu.classElements[PILOT_SIDEARM_IMAGE] )
		SetImageFromItemImage( element, loadout.sidearm )


	foreach ( element in menu.classElements[PILOT_PRIMARY_NAME] )
		SetTextFromItemName( element, loadout.primary )

	foreach ( element in menu.classElements[PILOT_PRIMARY_ATTACHMENT_NAME] )
		SetTextFromSubitemName( element, loadout.primary, loadout.primaryAttachment, GetDefaultAttachmentName( loadout.primary ) )

	foreach ( element in menu.classElements[PILOT_PRIMARY_MOD_NAME] )
		SetTextFromSubitemName( element, loadout.primary, loadout.primaryMod, "#MOD_SELECT_STOCK" )

	foreach ( element in menu.classElements[PILOT_SECONDARY_NAME] )
		SetTextFromItemName( element, loadout.secondary )

	foreach ( element in menu.classElements[PILOT_SIDEARM_NAME] )
		SetTextFromItemName( element, loadout.sidearm )

	foreach ( element in menu.classElements[PILOT_SPECIAL_NAME] )
		SetTextFromItemName( element, loadout.special )

	foreach ( element in menu.classElements[PILOT_ORDNANCE_NAME] )
		SetTextFromItemName( element, loadout.ordnance )

	foreach ( element in menu.classElements[PILOT_PASSIVE1_NAME] )
		SetTextFromItemName( element, loadout.passive1 )

	foreach ( element in menu.classElements[PILOT_PASSIVE2_NAME] )
		SetTextFromItemName( element, loadout.passive2 )

	foreach ( element in menu.classElements[PILOT_RACE_NAME] )
		SetTextFromItemName( element, loadout.race )


	foreach ( element in menu.classElements[PILOT_PRIMARY_ATTACHMENT_ICON] )
		SetImageFromSubitemIcon( element, loadout.primary, loadout.primaryAttachment, GetDefaultAttachmentIcon( loadout.primary ) )

	foreach ( element in menu.classElements[PILOT_PRIMARY_MOD_ICON] )
		SetImageFromSubitemIcon( element, loadout.primary, loadout.primaryMod, MOD_ICON_NONE )

	foreach ( element in menu.classElements[PILOT_SPECIAL_ICON] )
		SetImageFromItemIcon( element, loadout.special )

	foreach ( element in menu.classElements[PILOT_ORDNANCE_ICON] )
		SetImageFromItemIcon( element, loadout.ordnance )

	foreach ( element in menu.classElements[PILOT_PASSIVE1_ICON] )
		SetImageFromItemIcon( element, loadout.passive1 )

	foreach ( element in menu.classElements[PILOT_PASSIVE2_ICON] )
		SetImageFromItemIcon( element, loadout.passive2 )


	foreach ( element in menu.classElements[PILOT_PRIMARY_DESC] )
		SetTextFromItemDescription( element, loadout.primary )

	foreach ( element in menu.classElements[PILOT_SECONDARY_DESC] )
		SetTextFromItemDescription( element, loadout.secondary )

	foreach ( element in menu.classElements[PILOT_SIDEARM_DESC] )
		SetTextFromItemDescription( element, loadout.sidearm )

	foreach ( element in menu.classElements[PILOT_SPECIAL_DESC] )
		SetTextFromItemDescription( element, loadout.special )

	foreach ( element in menu.classElements[PILOT_ORDNANCE_DESC] )
		SetTextFromItemDescription( element, loadout.ordnance )

	foreach ( element in menu.classElements[PILOT_PASSIVE1_DESC] )
		SetTextFromItemDescription( element, loadout.passive1 )

	foreach ( element in menu.classElements[PILOT_PASSIVE2_DESC] )
		SetTextFromItemDescription( element, loadout.passive2 )
}

function OnPilotLoadoutButton_Focused( button )
{
	local buttonID = button.GetScriptID().tointeger()
	local presetPilotLoadouts = UI_GetPresetPilotLoadouts()

	local loadout
	if ( buttonID < presetPilotLoadouts.len() )
		loadout = UI_GetPresetPilotLoadout( button.loadoutID )
	else if ( buttonID >= presetPilotLoadouts.len() )
		loadout = UI_GetCustomPilotLoadout( button.loadoutID )

	if ( !loadout )
		return

	local menu = button.GetParentMenu()

	UpdatePilotLoadoutElems( menu, loadout, button )
}

function OnEditPilotLoadoutButton_LostFocus( button )
{
	if ( !("ref" in button.s) )
		return

	ClearRefNew( button.s.ref )
	button.SetNew( false )
}

function OnPilotLoadoutButton_Activate( button )
{
	if ( !IsConnected() )
		return

	if ( button.IsLocked() )
		return

	Assert( GetActiveLevel() != "mp_lobby" ) // update this later to handle loadout pre-selection in the lobby

	local presetPilotLoadouts = UI_GetPresetPilotLoadouts()
	local customPilotLoadouts = UI_GetCustomPilotLoadouts()

	local buttonID = button.GetScriptID().tointeger()

	if ( buttonID < presetPilotLoadouts.len() )
	{
		local loadoutID = button.loadoutID
		Assert( loadoutID != null && loadoutID < presetPilotLoadouts.len() )
		ClientCommand( "SetPresetPilotLoadout " + loadoutID )
	}
	else if ( buttonID >= presetPilotLoadouts.len() )
	{
		local loadoutID = button.loadoutID
		Assert( loadoutID != null  && loadoutID < customPilotLoadouts.len() )
		ClientCommand( "SetCustomPilotLoadout " + loadoutID )
	}

	if ( GetConVarString( "mp_gamemode" ) == "ps" ) //JFS. For R2 maybe try checking against Riff settings to see if Titans are disabled or not.
		SetLoadoutSelectionFinished()

	if ( !uiGlobal.loadoutSelectionFinished )
		CloseTopMenu()
	else
		CloseAllInGameMenus()
}

function OnEditPilotLoadoutButton_Focused( button )
{
	printt( "2. OnEditPilotLoadoutButton_Focused() running" )

	local isCustom = ("isCustom" in button.s) && button.s.isCustom
	local loadout

	Assert( button.loadoutID != null, "isCustom: " + isCustom + " button: " + button.GetName() )

	if ( isCustom )
		loadout = UI_GetCustomPilotLoadout( button.loadoutID )
	else
		loadout = UI_GetPresetPilotLoadout( button.loadoutID )

	if ( !loadout )
		return

	local menu = button.GetParentMenu()

	UpdatePilotLoadoutElems( menu, loadout, button )
}

function OnEditPilotLoadoutButton_Activate( button )
{
	if ( !IsConnected() )
		return

	if ( button.IsLocked() )
		return

	Assert( GetActiveLevel() == "mp_lobby" )

	local isCustom = ("isCustom" in button.s) && button.s.isCustom

	if ( isCustom )
	{
		local loadoutID = button.loadoutID
		local customPilotLoadouts = UI_GetCustomPilotLoadouts()

		Assert( loadoutID != null && loadoutID < customPilotLoadouts.len() )

		local editMenu = GetMenu( "EditPilotLoadoutMenu" )
		editMenu.loadoutIDBeingEdited = loadoutID
		uiGlobal.loadoutBeingEdited = customPilotLoadouts[ loadoutID ]

		AdvanceMenu( editMenu )
	}
}

function PilotLoadoutsNavigateBack()
{
	if ( uiGlobal.loadoutSelectionFinished )
		return true

	SetLoadoutSelectionFinished()
	CloseAllInGameMenus()
	return false
}

function OnOpenPilotLoadoutsMenu( menu )
{
	printt( "OnOpenPilotLoadoutsMenu" )

	if ( !IsConnected() )
		return

	local isCustom = GetPersistentVar( "pilotSpawnLoadout.isCustom" )
	local selectedIndex = GetPersistentVar( "pilotSpawnLoadout.index" )
	local presetPilotLoadouts = UI_GetPresetPilotLoadouts()
	local customPilotLoadouts = UI_GetCustomPilotLoadouts()
	local buttons = GetElementsByClassname( menu, "SelectLoadoutButtonClass" )

	if ( IsItemLocked( "pilot_custom_loadout_1" ) )
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

		if ( buttonID < presetPilotLoadouts.len() )
		{
			button.loadoutID = buttonID
			button.s.ref <- "pilot_preset_loadout_" + (button.loadoutID + 1)

			local loadout = UI_GetPresetPilotLoadout( button.loadoutID )
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

				if ( IsControllerModeActive() )
					thread PilotDelayedFocus( button )
			}
			else
			{
				button.SetSelected( false )
			}
		}
		else if ( buttonID < presetPilotLoadouts.len() + customPilotLoadouts.len() )
		{
			if ( IsItemLocked( "pilot_custom_loadout_1" ) )
			{
				ClearButton( button )
				continue
			}

			if ( buttonID < presetPilotLoadouts.len() + NUM_CUSTOM_LOADOUTS )
			{
				// common loadout slot
				button.loadoutID = buttonID - presetPilotLoadouts.len()
			}
			else if ( PersistenceEnumValueIsValid( "gameModesWithLoadouts", GetLoadoutGamemode() ) )
			{
				// gamemode specific slot. Offset loadout ID for the game mode
				gamemodeLoadoutsShown++
				local currentModeIndex = PersistenceGetEnumIndexForItemName( "gameModesWithLoadouts", GetLoadoutGamemode() )
				button.loadoutID = buttonID - presetPilotLoadouts.len() + (currentModeIndex * NUM_GAMEMODE_LOADOUTS)
			}
			else
			{
				ClearButton( button )
				continue
			}

			button.s.ref <- "pilot_custom_loadout_" + (button.loadoutID + 1)

			local loadout = UI_GetCustomPilotLoadout( button.loadoutID )
			if ( !loadout || gamemodeLoadoutsShown > NUM_GAMEMODE_LOADOUTS )
			{
				ClearButton( button )
				continue
			}

			button.SetUTF8Text( GetLoadoutName( loadout ) )
			button.SetEnabled( true )
			button.SetLocked( IsItemLocked( button.s.ref ) )
			//button.SetNew( HasAnyNewItem( button.s.ref ) )

			if ( isCustom && (buttonID - presetPilotLoadouts.len() == selectedIndex ) )
			{
				button.SetSelected( true )

				if ( IsControllerModeActive() )
					thread PilotDelayedFocus( button )
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

function OnOpenEditPilotLoadoutsMenu( menu )
{
	printt( "1. OnOpenEditPilotLoadoutsMenu() running" )

	if ( level.ui.nextMapModeComboIndex == null && !uiGlobal.toggleLoadoutGameModeButtonRegistered && !IsItemLocked( "pilot_custom_loadout_1" ) )
	{
		RegisterButtonPressedCallback( BUTTON_Y, ToggleLoadoutGamemode )
		uiGlobal.toggleLoadoutGameModeButtonRegistered = true
	}

	uiGlobal.currentEditLoadoutMenuName = menu.GetName()
	local buttons = GetElementsByClassname( menu, "SelectLoadoutButtonClass" )

	if ( IsItemLocked( "pilot_custom_loadout_1" ) )
		ShowOnlyPresetPilotButtons( menu, buttons )
	else
		ShowOnlyCustomPilotButtons( menu, buttons )

	if ( uiGlobal.loadoutBeingEdited != null )
		UpdatePilotLoadoutElems( menu, uiGlobal.loadoutBeingEdited )
}

function OnCloseEditPilotLoadoutsMenu()
{
	if ( uiGlobal.toggleLoadoutGameModeButtonRegistered )
	{
		DeregisterButtonPressedCallback( BUTTON_Y, ToggleLoadoutGamemode )
		uiGlobal.toggleLoadoutGameModeButtonRegistered = false
	}
	uiGlobal.loadoutBeingEdited = null
}

function ShowOnlyPresetPilotButtons( menu, buttons )
{
	local presetPilotLoadouts = UI_GetPresetPilotLoadouts()
	local customPilotLoadouts = UI_GetCustomPilotLoadouts()

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

		if ( buttonID < presetPilotLoadouts.len() )
		{
			button.loadoutID = buttonID
			button.s.ref <- "pilot_preset_loadout_" + (button.loadoutID + 1)

			local loadout = UI_GetPresetPilotLoadout( button.loadoutID )
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

function ShowOnlyCustomPilotButtons( menu, buttons )
{
	local customPilotLoadouts = UI_GetCustomPilotLoadouts()

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

		if ( buttonID < customPilotLoadouts.len() )
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

			button.s.ref <- "pilot_custom_loadout_" + (button.loadoutID + 1)
			button.s.isCustom <- true

			local loadout = UI_GetCustomPilotLoadout( button.loadoutID )
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

function PilotDelayedFocus( button )
{
	wait 0
	wait 0
	button.SetFocused()
}

// hax
function ServerCallback_LoadoutsUpdated()
{
	thread InitCustomLoadouts()

	printt( "preRESETTING" )

	if ( !uiGlobal.activeMenu )
		return

	printt( "RESETTING" )
	PrintMenuStack()

	local buttonData = []
	buttonData.append( { name = "#CLOSE", func = null } )

	local footerData = []
	footerData.append( { label = "#A_BUTTON_SELECT" } )
	footerData.append( { label = "#B_BUTTON_CLOSE" } )

	local dialogData = {}
	dialogData.header <- "#INVALID_LOADOUT"
	dialogData.detailsMessage <- "#RESETTING_LOADOUT"
	dialogData.buttonData <- buttonData
	dialogData.footerData <- footerData

	OpenChoiceDialog( dialogData )
}