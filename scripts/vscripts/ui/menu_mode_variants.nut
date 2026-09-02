// Mode variant submenus for the Private Match "Set Game Mode" menu (ModesMenu).
// Opens from parent group buttons in menu_mode_select.nut; each submenu lists
// the individual modes of a group. Selection behaves exactly like a plain
// mode button (PrivateMatchSetMode) and returns to the Private Match lobby.

function main()
{
	Globalize( InitModeVariantMenus )
	Globalize( OnOpenModeVariantMenu )
	Globalize( OnCloseModeVariantMenus )
	Globalize( ModeVariantButton_Click )
	Globalize( ModeVariantButton_GetFocus )
	Globalize( SetModesMenuContentVisible )

	file.modeVariantConfig <- {}
	file.modeVariantConfig[ "ModeVariantCTFMenu" ] <- [ "ctf", "ctt" ]
	file.modeVariantConfig[ "ModeVariantMFDMenu" ] <- [ "mfd", "mfdp", "tmfd", "tmfdp" ]
	file.modeVariantConfig[ "ModeVariantPilotMenu" ] <- [ "tdm", "ps" ]
	file.modeVariantConfig[ "ModeVariantFFAMenu" ] <- [ "ffa", "gg" ]

	file.modeVariantButtons <- {}
	file.activeVariantMenu <- null
}

function InitModeVariantMenus()
{
	foreach ( menuName, modeNames in file.modeVariantConfig )
	{
		local menu = GetMenu( menuName )
		local buttons = GetElementsByClassname( menu, "ModeVariantButton" )
		file.modeVariantButtons[menuName] <- buttons

		foreach ( button in buttons )
		{
			button.AddEventHandler( UIE_CLICK, Bind( ModeVariantButton_Click ) )
			button.AddEventHandler( UIE_GET_FOCUS, Bind( ModeVariantButton_GetFocus ) )
			button.s.modeName <- null
		}
	}
}

function SetModesMenuContentVisible( visible )
{
	local parentMenu = GetMenu( "ModesMenu" )
	local parentButtons = GetElementsByClassname( parentMenu, "ModeButton" )

	foreach ( button in parentButtons )
	{
		if ( visible )
		{
			if ( "modeEntry" in button.s && button.s.modeEntry != null )
				button.Show()
		}
		else
		{
			button.Hide()
		}
	}

	foreach ( elementName in [
		"ImgPlaylistsSubheaderBackground",
		"LblPlaylistsSubheader",
		"ImgGamemodesSubheaderBackground",
		"LblGamemodesSubheader",
	] )
	{
		local element = parentMenu.GetChild( elementName )
		if ( visible )
			element.Show()
		else
			element.Hide()
	}
}

function OnOpenModeVariantMenu( menuName )
{
	file.activeVariantMenu = GetMenu( menuName )
	SetModesMenuContentVisible( false )

	local buttons = file.modeVariantButtons[menuName]
	local modes = file.modeVariantConfig[menuName]

	foreach ( index, modeName in modes )
	{
		local button = buttons[index]
		button.SetText( GetGameModeDisplayName( modeName ) )
		button.SetEnabled( true )
		button.s.modeName <- modeName
		button.Show()
	}

	local focusFound = false
	local currentModeName = GetModeNameForEnum( level.ui.privatematch_mode )
	foreach ( index, modeName in modes )
	{
		if ( modeName != currentModeName )
			continue

		buttons[index].SetFocused()
		focusFound = true
		break
	}

	if ( !focusFound )
		buttons[0].SetFocused()
}

function OnCloseModeVariantMenus()
{
	file.activeVariantMenu = null
	SetModesMenuContentVisible( true )
}

function ModeVariantButton_GetFocus( button )
{
	if ( button.s.modeName == null )
		return

	local modeName = button.s.modeName
	local parentMenu = GetMenu( "ModesMenu" )
	parentMenu.GetChild( "NextModeImage" ).SetImage( GetGameModeDisplayImage( modeName ) )
	parentMenu.GetChild( "NextModeName" ).SetText( GetGameModeDisplayName( modeName ) )
	parentMenu.GetChild( "NextModeDesc" ).SetText( GetGameModeDisplayDesc( modeName ) )
}

function ModeVariantButton_Click( button )
{
	if ( button.s.modeName == null )
		return

	local modeName = button.s.modeName
	ClientCommand( "PrivateMatchSetMode " + modeName )

	// Remove both the flyout and its parent ModesMenu from the stack so mode
	// selection returns directly to the Private Match lobby.
	CloseSubmenu( false )
	CloseTopMenu()
}