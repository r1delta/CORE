
const ADVOCATE_LINE_FADE_IN_TIME 	= 3.0
const BACKGROUND_ALPHA				= 200

function main()
{
	Globalize( OnOpen_Advocate_Letter )
	Globalize( OnClose_Advocate_Letter )
	Globalize( InitAdvocateLetterMenu )
	Globalize( Advocate_Letter_FooterData )
	Globalize( OnCloseAdvocateLetterMenu )
	Globalize( OpenAdvocateLetter )

	buttonsRegistered <- false
	menu <- null

	file.advocateLineDelay <- null
	file.newAdvocateLineDelay <- false
	file.hasIcon <- false
	file.advocateLines <- []
	file.mailIcon <- null
	file.mailButton <- null
	file.blackBackground <- null
	file.textFadingIn <- true
	file.clickButtonFunc <- null
	file.declineButton <- null
	file.declineFunc <- null
	file.hasDeclineButton <- false

	file.mailLines <- []

	RegisterSignal( "StopCursorBlink" )
}

function InitAdvocateLetterMenu()
{
	menu = GetMenu( "Advocate_Letter" )
	Assert( menu != null )

	file.advocateLines <- GetElementsByClassname( menu, "AdvocateLine" )
	file.mailIcon = GetElem( menu, "NextGenIcon" )
	file.mailButton = GetElem( menu, "AcceptButton" )
	file.declineButton = GetElem( menu, "DeclineButton" )
	file.blackBackground = GetElem( menu, "blackBackground" )

	file.mailButton.AddEventHandler( UIE_CLICK, Bind( OnAdvocateLetterClick ) )
	file.declineButton.AddEventHandler( UIE_CLICK, Bind( OnDeclineButtonClick ) )

	AddMenuEventHandler(menu, R1DELTA_UIE_OPEN, OnOpen_Advocate_Letter)
	AddMenuEventHandler(menu, R1DELTA_UIE_CLOSE, OnClose_Advocate_Letter)
}

function OnAdvocateLetterClick( button )
{
	CloseTopMenu()
	if ( file.clickButtonFunc != null )
		file.clickButtonFunc()
	Signal( menu, "StopMenuAnimation" )
}

function OnDeclineButtonClick( button )
{
	CloseTopMenu()
	if ( file.declineFunc != null )
		file.declineFunc()
	Signal( menu, "StopMenuAnimation" )
}


function OpenAdvocateLetter( lines, buttonLabel, buttonFunc = null, declineLabel = null, declineFunc = null, lineDelayOverride = null, icon = null, postProcessFunc = null )
{
	file.mailLines = lines
	Assert( lines.len() <= file.advocateLines.len(), "Need to add more advocate lines" )

	foreach ( index, elem in file.advocateLines )
	{
		if ( index >= lines.len() )
			break

		elem.SetText( lines[index] )
	}

	if ( postProcessFunc )
	{
		postProcessFunc( lines, file.advocateLines )
	}

	if ( lineDelayOverride == null )
		file.newAdvocateLineDelay = null
	else
		file.newAdvocateLineDelay = lineDelayOverride

	file.hasIcon = ( icon != null )

	file.mailButton.SetText( buttonLabel )

	if ( buttonFunc && declineLabel != null && declineFunc != null )
	{
		file.hasDeclineButton = true
		file.declineButton.SetText( declineLabel )
		file.declineFunc = declineFunc
	}

	if ( file.hasIcon )
		file.mailIcon.SetImage( icon )

	file.clickButtonFunc = buttonFunc

	AdvanceMenu( menu )
}

function OnOpen_Advocate_Letter()
{
	Signal( menu, "StopMenuAnimation" )
	EndSignal( menu, "StopMenuAnimation" )

	file.mailIcon.SetAlpha( 0 )
	file.mailIcon.Hide()

	file.mailButton.SetEnabled( false )
	file.mailButton.Hide()

	file.declineButton.Hide()

	file.blackBackground.SetAlpha( BACKGROUND_ALPHA )
	file.blackBackground.Show()

	if ( file.newAdvocateLineDelay != null )
		file.advocateLineDelay = file.newAdvocateLineDelay
	else
		file.advocateLineDelay = 2.0

	foreach ( index, elem in file.advocateLines )
	{
		elem.SetAlpha( 0 )
		elem.Hide()
	}

	thread OpenAnimatedAdvocateMail()

	wait 0

	if ( !buttonsRegistered )
	{
		RegisterButtonPressedCallback( BUTTON_A, StopMenuAnimation )
		RegisterButtonPressedCallback( KEY_ENTER, StopMenuAnimation )
		RegisterButtonPressedCallback( KEY_SPACE, StopMenuAnimation )
		buttonsRegistered = true
	}
}

function OnClose_Advocate_Letter()
{
	if ( buttonsRegistered )
	{
		DeregisterButtonPressedCallback( BUTTON_A, StopMenuAnimation )
		DeregisterButtonPressedCallback( KEY_ENTER, StopMenuAnimation )
		DeregisterButtonPressedCallback( KEY_SPACE, StopMenuAnimation )
		buttonsRegistered = false
	}

	Signal( menu, "StopMenuAnimation" )
}

function OnCloseAdvocateLetterMenu()
{
	CloseTopMenu()
	Signal( menu, "StopMenuAnimation" )
}

function OpenAnimatedAdvocateMail()
{
	OnThreadEnd(
		function() : ()
		{
			foreach( index, elem in file.advocateLines )
			{
				if ( index < file.mailLines.len() )
				{
					elem.SetAlpha( 255 )
					elem.Show()
				}
			}

			if ( file.hasIcon )
			{
				file.mailIcon.SetAlpha( 255 )
				file.mailIcon.Show()
			}

			if ( file.clickButtonFunc != null )
			{
				file.mailButton.SetEnabled( true )
				file.mailButton.Show()
				file.mailButton.SetFocused()

				if ( file.hasDeclineButton )
				{
					file.declineButton.SetAlpha( 255 )
					file.declineButton.Show()
				}
			}
			file.blackBackground.SetAlpha( BACKGROUND_ALPHA )

			file.textFadingIn = false
			UpdateFooterButtons()
		}
	)

	file.blackBackground.SetAlpha( BACKGROUND_ALPHA )

	EndSignal( menu, "StopMenuAnimation" )

	for ( local i = 0 ; i < file.advocateLines.len() ; i++ )
	{
		if ( i < file.mailLines.len() )
		{
			file.advocateLines[i].Show()
			file.advocateLines[i].FadeOverTimeDelayed( 255, ADVOCATE_LINE_FADE_IN_TIME, file.advocateLineDelay * i, INTERPOLATOR_ACCEL )
		}
	}

	wait file.advocateLineDelay * file.mailLines.len()

	if ( file.hasIcon )
	{
		file.mailIcon.SetAlpha(0)
		file.mailIcon.Show()
		file.mailIcon.FadeOverTimeDelayed( 255, ADVOCATE_LINE_FADE_IN_TIME, 0.0, INTERPOLATOR_ACCEL )
	}

	wait ADVOCATE_LINE_FADE_IN_TIME
}

function StopMenuAnimation(...)
{
	Signal( menu, "StopMenuAnimation" )
}

function Advocate_Letter_FooterData( footerData )
{
	if ( file.textFadingIn )
	{
		footerData.gamepad.append( { label = "#A_BUTTON_SKIP" } )
	}
	else
	{
		footerData.gamepad.append( { label = "#A_BUTTON_SELECT" } )

		footerData.gamepad.append( { label = "#B_BUTTON_BACK" } )
		footerData.pc.append( { label = "#BACK", func = PCBackButton_Activate } )
	}
}

