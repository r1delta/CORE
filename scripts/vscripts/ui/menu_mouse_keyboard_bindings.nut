
function main()
{
	Globalize( InitMouseKeyboardMenu )
	Globalize( OnOpenKeyboardBindingsMenu )
	Globalize( OnCloseKeyboardBindingsMenu )
	Globalize( NavigateBackApplyKeyBindingsDialog )
	Globalize( DefaultKeyBindingsDialog )
	Globalize( ApplyKeyBindingsButton_Activate )
}

function InitMouseKeyboardMenu( menu )
{
	AddMenuEventHandler(menu, R1DELTA_UIE_OPEN, OnOpenKeyboardBindingsMenu)
	AddMenuEventHandler(menu, R1DELTA_UIE_CLOSE, OnCloseKeyboardBindingsMenu)
}

function OnOpenKeyboardBindingsMenu( menu )
{
	KeyBindings_FillInCurrent( menu )

	RegisterButtonPressedCallback( BUTTON_X, ApplyKeyBindingsButton_Activate )
	RegisterButtonPressedCallback( BUTTON_Y, DefaultKeyBindingsDialog )
}

function OnCloseKeyboardBindingsMenu( menu )
{
	DeregisterButtonPressedCallback( BUTTON_X, ApplyKeyBindingsButton_Activate )
	DeregisterButtonPressedCallback( BUTTON_Y, DefaultKeyBindingsDialog )
}

function DefaultKeyBindingsDialog( button)
{
	if ( uiGlobal.activeDialog )
		return

	local buttonData = []
	buttonData.append( { name = "#RESTORE", func = DialogChoice_ApplyDefaultBindings } )
	buttonData.append( { name = "#CANCEL", func = null } )

	local dialogData = {}
	dialogData.header <- "#RESTORE_DEFAULT_KEY_BINDINGS"
	dialogData.buttonData <- buttonData

	OpenChoiceDialog( dialogData )
}

function DialogChoice_ApplyDefaultBindings()
{
	local menu = GetMenu( "MouseKeyboardBindingsMenu" )

	KeyBindings_ResetToDefault( menu )
}

function ApplyKeyBindingsButton_Activate( button )
{
	if ( uiGlobal.activeDialog )
		return

	local buttonData = []
	buttonData.append( { name = "#APPLY", func = DialogChoice_ApplyKeyBindings } )
	buttonData.append( { name = "#CANCEL", func = null } )

	local footerData = []
	footerData.append( { label = "#A_BUTTON_SELECT" } )
	footerData.append( { label = "#B_BUTTON_CANCEL", func = null } )

	local dialogData = {}
	dialogData.header <- "#APPLY_CHANGES"
	dialogData.buttonData <- buttonData
	dialogData.footerData <- footerData

	OpenChoiceDialog( dialogData )
}

function NavigateBackApplyKeyBindingsDialog()
{
	local buttonData = []
	buttonData.append( { name = "#APPLY", func = DialogChoice_ApplyKeyBindingsAndCloseMenu } )
	buttonData.append( { name = "#DISCARD", func = CloseTopMenu } )

	local footerData = []
	footerData.append( { label = "#A_BUTTON_SELECT" } )
	footerData.append( { label = "#B_BUTTON_DISCARD", func = null } )

	local dialogData = {}
	dialogData.header <- "#APPLY_CHANGES"
	dialogData.buttonData <- buttonData
	dialogData.footerData <- footerData

	OpenChoiceDialog( dialogData )
}

function DialogChoice_ApplyKeyBindings()
{
	KeyBindings_Apply( GetMenu( "MouseKeyboardBindingsMenu" ) )
}

function DialogChoice_ApplyKeyBindingsAndCloseMenu()
{
	KeyBindings_Apply( GetMenu( "MouseKeyboardBindingsMenu" ) )
	CloseTopMenu()
}