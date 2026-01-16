
const NUM_ADVOCATE_LINES 			= 7
const ADVOCATE_LINE_DELAY 			= 2.0
const ADVOCATE_LINE_FADE_IN_TIME 	= 3.0
const BACKGROUND_ALPHA				= 200

buttonsRegistered <- false

menu <- null
advocateLines <- []
genIcon <- null
warningText <- null
genButton <- null
blackBackground <- null
flare <- null
bootText <- ""
bootTextLabel <- null
bootLogo <- null
textFadingIn <- true
regenSequenceStarted <- false

function main()
{
	Globalize( OnOpen_Generation_Respawn )
	Globalize( OnClose_Generation_Respawn )
	Globalize( OnRegenButtonClick )

	Globalize( OnConfirmRegen0_Activate )
	Globalize( OnConfirmRegen1_Activate )
	Globalize( OnConfirmRegen2_Activate )

	Globalize( Generation_Respawn_FooterData )
	Globalize( OnCloseGenerationRespawnMenu )

	RegisterSignal( "StopCursorBlink" )
}

function InitMenu()
{
	Assert( menu != null )

	advocateLines = []
	for( local i = 0 ; i < NUM_ADVOCATE_LINES ; i++ )
	{
		local elem = GetElem( menu, "AdvocateLine" + i )
		elem.SetAlpha( 0 )
		elem.SetText( "#GENERATION_RESPAWN_ADVOCATE_LINE" + i, "#GENERATION_NUMERIC_" + (GetGen() + 2) )
		elem.Hide()

		advocateLines.append( elem )
	}

	genIcon = GetElem( menu, "NextGenIcon" )
	genIcon.SetAlpha( 0 )
	genIcon.SetImage( "../ui/menu/generation_icons/generation_" + ( GetGen() + 1 ) )
	genIcon.Hide()

	local xpRate = format( "%.0f", GetXPModifierForGen( GetGen() + 1 ) * 100.0 )

	warningText = GetElem( menu, "WarningText" )
	warningText.SetText( "#GENERATION_RESPAWN_CONFIRM_MESSAGE_0", xpRate, "#GENERATION_NUMERIC_" + (GetGen() + 2) )
	warningText.SetAlpha( 0 )
	warningText.Hide()

	genButton = GetElem( menu, "GenerationRespawnButtonClass" )
	genButton.SetText( "#GENERATION_RESPAWN_BUTTON_LABEL", GetGen() + 2 )
	genButton.SetEnabled( false )
	genButton.Hide()

	blackBackground = GetElem( menu, "blackBackground" )
	blackBackground.SetAlpha( BACKGROUND_ALPHA )
	blackBackground.Show()

	flare = GetElem( menu, "Flare" )
	flare.SetAlpha( 0 )
	flare.Hide()

	bootText = ""
	bootTextLabel = GetElem( menu, "BootText" )
	bootTextLabel.Hide()

	bootLogo = GetElem( menu, "BootLogo" )
	bootLogo.Hide()
}

function OnOpen_Generation_Respawn()
{
	menu = GetMenu( "Generation_Respawn" )

	Signal( menu, "StopMenuAnimation" )
	EndSignal( menu, "StopMenuAnimation" )

	InitMenu()
	thread OpenMenuAnimated()

	wait 0

	if ( !buttonsRegistered )
	{
		RegisterButtonPressedCallback( BUTTON_A, OpenMenuStatic )
		RegisterButtonPressedCallback( KEY_ENTER, OpenMenuStatic )
		RegisterButtonPressedCallback( KEY_SPACE, OpenMenuStatic )
		buttonsRegistered = true
	}
}

function OnClose_Generation_Respawn()
{
	if ( buttonsRegistered )
	{
		DeregisterButtonPressedCallback( BUTTON_A, OpenMenuStatic )
		DeregisterButtonPressedCallback( KEY_ENTER, OpenMenuStatic )
		DeregisterButtonPressedCallback( KEY_SPACE, OpenMenuStatic )
		buttonsRegistered = false
	}

	Signal( menu, "StopMenuAnimation" )
}

function OnCloseGenerationRespawnMenu()
{
	StopUISound( "UI_Pilot_Regenerate" )
	if ( regenSequenceStarted == false )
		CloseTopMenu()
	else
		Signal( menu, "StopMenuAnimation" )
}

function OpenMenuAnimated()
{
	OnThreadEnd(
		function() : ()
		{
			foreach( elem in advocateLines )
			{
				elem.SetAlpha( 255 )
				elem.Show()
			}

			genIcon.SetAlpha( 255 )
			genIcon.Show()

			warningText.SetAlpha( 255 )
			warningText.Show()

			genButton.SetEnabled( true )
			genButton.Show()
			genButton.SetFocused()

			blackBackground.SetAlpha( BACKGROUND_ALPHA )

			textFadingIn = false
			UpdateFooterButtons()
		}
	)

	blackBackground.SetAlpha( BACKGROUND_ALPHA )

	EndSignal( menu, "StopMenuAnimation" )

	Assert( advocateLines.len() == NUM_ADVOCATE_LINES )

	for( local i = 0 ; i < advocateLines.len() ; i++ )
	{
		advocateLines[i].Show()
		advocateLines[i].FadeOverTimeDelayed( 255, ADVOCATE_LINE_FADE_IN_TIME, ADVOCATE_LINE_DELAY * i, INTERPOLATOR_ACCEL )
	}

	wait ADVOCATE_LINE_DELAY * advocateLines.len()

	genIcon.SetAlpha(0)
	genIcon.Show()
	genIcon.FadeOverTimeDelayed( 255, ADVOCATE_LINE_FADE_IN_TIME, 0.0, INTERPOLATOR_ACCEL )

	warningText.SetAlpha(0)
	warningText.Show()
	warningText.FadeOverTimeDelayed( 255, ADVOCATE_LINE_FADE_IN_TIME, 0.0, INTERPOLATOR_ACCEL )

	wait ADVOCATE_LINE_FADE_IN_TIME

	genButton.SetEnabled( true )
	genButton.Show()
	genButton.SetFocused()
}

function OpenMenuStatic(...)
{
	Signal( menu, "StopMenuAnimation" )
	StopUISound( "UI_Pilot_Regenerate" )
}

function Generation_Respawn_FooterData( footerData )
{
	if ( textFadingIn )
	{
		footerData.gamepad.append( { label = "#A_BUTTON_SKIP" } )
	}
	else if ( !regenSequenceStarted )
	{
		footerData.gamepad.append( { label = "#A_BUTTON_SELECT" } )

		footerData.gamepad.append( { label = "#B_BUTTON_BACK" } )
		footerData.pc.append( { label = "#BACK", func = PCBackButton_Activate } )
	}
	/*
	else
	{
		footerData.gamepad.append( { label = "#A_BUTTON_SKIP" } )
		footerData.pc.append( { label = "#SKIP", func = PCBackButton_Activate } )
	}
	*/
}

function OnRegenButtonClick(...)
{
	if ( buttonsRegistered )
	{
		DeregisterButtonPressedCallback( BUTTON_A, OpenMenuStatic )
		DeregisterButtonPressedCallback( KEY_ENTER, OpenMenuStatic )
		DeregisterButtonPressedCallback( KEY_SPACE, OpenMenuStatic )
		buttonsRegistered = false
	}

	OpenDialog( GetMenu( "ConfirmDialog" ), "#GENERATION_RESPAWN_CONFIRM_MESSAGE_1", "BtnConfirmRegen0", "BtnCancel" )
	uiGlobal.preDialogFocus = genButton
}

function OnConfirmRegen0_Activate(...)
{
	CloseDialog()
	OpenDialog( GetMenu( "ConfirmDialog" ), "#GENERATION_RESPAWN_CONFIRM_MESSAGE_2", "BtnConfirmRegen1", "BtnCancel" )
	uiGlobal.preDialogFocus = genButton
}

function OnConfirmRegen1_Activate(...)
{
	CloseDialog()
	OpenDialog( GetMenu( "ConfirmDialog" ), "#GENERATION_RESPAWN_CONFIRM_MESSAGE_3", "BtnConfirmRegen2", "BtnCancel" )
	uiGlobal.preDialogFocus = genButton
}

function OnConfirmRegen2_Activate(...)
{
	CloseDialog()
	GenUp()
}

function GenUp()
{
	local currentGen = GetGen()

	// Notify the server to gen up this player
	ClientCommand( "GenUp" )

	// Show visuals
	thread RebootScreen( currentGen )
}

function RebootScreen( lastGen )
{
	foreach( elem in advocateLines )
		elem.Hide()
	genIcon.Hide()
	warningText.Hide()
	genButton.SetEnabled( false )
	genButton.Hide()
	blackBackground.SetAlpha( 255 )

	local cancelButtons = GetElementsByClassname( menu, "cancelbuttons" )
	foreach( elem in cancelButtons )
	{
		elem.SetEnabled( false )
		elem.Hide()
	}

	EmitUISound( "UI_Pilot_Regenerate" )

	OnThreadEnd(
		function() : ()
		{
			blackBackground.Hide()
			bootLogo.Hide()
			flare.Hide()
			bootTextLabel.Hide()
			if ( uiGlobal.loadingLevel == null && IsConnected() )
				CloseTopMenu()
		}
	)
	regenSequenceStarted = true
	UpdateFooterButtons()
	EndSignal( menu, "StopMenuAnimation" )

	//###################
	// Fade in the flare
	//###################

	flare.SetScale( 10.0, 10.0 )
	flare.Show()
	flare.FadeOverTime( 255, 1.0, INTERPOLATOR_ACCEL )
	wait 1.0
	blackBackground.Show()

	//#####################################################
	// Allow skipping of this reboot sequence
	//#####################################################

	if ( !buttonsRegistered )
	{
		RegisterButtonPressedCallback( BUTTON_A, OpenMenuStatic )
		RegisterButtonPressedCallback( KEY_ENTER, OpenMenuStatic )
		RegisterButtonPressedCallback( KEY_SPACE, OpenMenuStatic )
		buttonsRegistered = true
	}

	//#####################################################
	// Shrink flare to simulate old school tv shutting off
	//#####################################################

	flare.ScaleOverTime( 1.5, 0.05, 0.4, INTERPOLATOR_ACCEL )
	wait 0.4
	flare.ScaleOverTime( 0.2, 0.05, 0.15, INTERPOLATOR_LINEAR )
	flare.FadeOverTimeDelayed( 0, 0.05, 0.1, INTERPOLATOR_ACCEL )
	wait 1.15

	//###################
	// Cursor blink
	//###################

	bootTextLabel.SetText( "_" )
	bootTextLabel.Show()
	bootLogo.Show()

	thread BlinkCursor()
	wait 2.5

	//###################
	// Boot text
	//###################

	AddTextLine( "RSPN Modular BIOS v" + ( lastGen + 1 ) + "." + CodeRandomInt( 10, 999 ) )
	AddTextLine( "Copyright (C) Hammond Robotics" )
	AddTextLine( "" )
	AddTextLine( "GT52-UH7-C" )

	wait 0.5

	AddTextLine( "" )
	AddTextLine( "" )
	AddTextLine( "" )
	AddTextLine( "Hammond Robotics Bootloader v832.42.007b" )
	AddTextLine( "Verifying Consistency" )
	for ( local i = 0 ; i < 15 ; i++ )
	{
		wait 0.12
		AddText( "." )
	}
	AddTextLine( "Done." )
	AddTextLine( "" )
	thread BlinkCursor()
	wait 1.0
	AddTypeLine( "exec regen_respawn.cfg -loopback 255 -verbose" )
	AddTextLine( "" )
	AddTextLine( "Execing config: regen_respawn.cfg" )
	wait 0.5
	AddTextLine( "" )
	AddTextLine( "Hunk_OnRegenStart: 67108864" )
	wait 0.2
	AddTextLine( "Validating Operator Credentials..." )
	wait 0.5
	AddTextLine( "OVERRIDE!! Auth code BISH-FU" )
	wait 0.4
	AddTextLine( "Flashing BIOS version " + ( lastGen + 2 ) + ".0" )
	for ( local i = 0 ; i < 15 ; i++ )
	{
		wait 0.15
		AddText( "." )
	}
	AddTextLine( "Done." )
	AddTextLine( "" )
	thread BlinkCursor()

	wait 0.5
	AddTypeLine( "cl_reboot -soft -remote" )
	AddTextLine( "" )
	AddTextLine( "Reinitializing software, please wait..." )
	wait 3.5
}

function AddTextLine( text )
{
	Signal( bootTextLabel, "StopCursorBlink" )

	if ( bootText != "" )
		bootText += "\n"
	bootText += text
	bootTextLabel.SetText( bootText )
}

function AddText( text )
{
	Signal( bootTextLabel, "StopCursorBlink" )

	bootText += text
	bootTextLabel.SetText( bootText )
}

function AddTypeLine( text )
{
	if ( bootText != "" )
		bootText += "\n"
	for( local i = 1 ; i < text.len() + 1 ; i++ )
	{
		AddText( text.slice( i - 1, i ) )
		wait 0.02
	}
}

function BlinkCursor()
{
	EndSignal( bootTextLabel, "StopCursorBlink" )

	local oldText = bootText

	while(1)
	{
		bootTextLabel.SetText( bootText + "\n_" )
		wait 0.25
		bootTextLabel.SetText( bootText + "\n")
		wait 0.25
	}
}