
function main()
{
	Globalize( InitIntroMenu )
	Globalize( PlayIntroVideo )

	RegisterSignal( "SkipIntroHoldReleased" )
}

function InitIntroMenu( menu )
{
	uiGlobal.playingIntro <- false

	file.holdInProgress <- false

	menu.GetChild( "GamepadSkipIntroInstruction" ).EnableKeyBindingIcons()
	menu.GetChild( "KeyboardSkipIntroInstruction" ).EnableKeyBindingIcons()
}

function PlayIntroVideo( skippable )
{
	AdvanceMenu( GetMenu( "IntroMenu" ) )
	RunAnimationScript( "IntroStart" )
	DisableBackgroundMovie()
	StopMusic()

	local forceUseCaptioning = false
	if ( GetLanguage() == "french" )
	{
		forceUseCaptioning = true
	}

	PlayVideo( "intro.bik", forceUseCaptioning )
	uiGlobal.playingIntro = true

	if ( skippable )
		thread WaitForSkipInput()

	WaitSignal( uiGlobal.signalDummy, "PlayVideoEnded" )

	StopVideo()
	uiGlobal.playingIntro = false

	if ( uiGlobal.activeMenu == GetMenu( "IntroMenu" ) )
		CloseTopMenu()
	EnableBackgroundMovie()
	PlayMusic()
	wait 0 // Need time to allow menu focus to be set or else cancelling the connect dialog will leave nothing focused
}

function WaitForSkipInput()
{
	EndSignal( uiGlobal.signalDummy, "PlayVideoEnded" )

	local inputs = []

	// Gamepad
	inputs.append( BUTTON_A )
	inputs.append( BUTTON_B )
	inputs.append( BUTTON_X )
	inputs.append( BUTTON_Y )
	inputs.append( BUTTON_SHOULDER_LEFT )
	inputs.append( BUTTON_SHOULDER_RIGHT )
	inputs.append( BUTTON_TRIGGER_LEFT )
	inputs.append( BUTTON_TRIGGER_RIGHT )
	inputs.append( BUTTON_BACK )
	inputs.append( BUTTON_START )

	// Keyboard/Mouse
	inputs.append( KEY_SPACE )
	inputs.append( KEY_ESCAPE )
	inputs.append( KEY_ENTER )
	inputs.append( KEY_PAD_ENTER )

	wait 0 // Without this the skip message would show instantly if you chose the main menu intro option with BUTTON_A or KEY_SPACE
	foreach ( input in inputs )
	{
		if ( input == BUTTON_A || input == KEY_SPACE )
		{
			RegisterButtonPressedCallback( input, ThreadSkipButton_Press )
			RegisterButtonReleasedCallback( input, SkipButton_Release )
		}
		else
		{
			RegisterButtonPressedCallback( input, NotifyButton_Press )
		}
	}

	OnThreadEnd(
		function() : ( inputs )
		{
			foreach ( input in inputs )
			{
				if ( input == BUTTON_A || input == KEY_SPACE )
				{
					DeregisterButtonPressedCallback( input, ThreadSkipButton_Press )
					DeregisterButtonReleasedCallback( input, SkipButton_Release )
				}
				else
				{
					DeregisterButtonPressedCallback( input, NotifyButton_Press )
				}
			}
		}
	)

	WaitSignal( uiGlobal.signalDummy, "PlayVideoEnded" )
}

function ThreadSkipButton_Press( button )
{
	thread SkipButton_Press()
}

function NotifyButton_Press( button )
{
	RunAnimationScript( "IntroButtonPress" )
}

function SkipButton_Press()
{
	if ( file.holdInProgress )
		return

	file.holdInProgress = true

	local holdStartTime = Time()
	local hold = {} // Table is needed to pass by reference
	hold.completed <- false

	EndSignal( uiGlobal.signalDummy, "SkipIntroHoldReleased" )
	EndSignal( uiGlobal.signalDummy, "PlayVideoEnded" )

	OnThreadEnd(
		function() : ( hold )
		{
			if ( hold.completed )
				Signal( uiGlobal.signalDummy, "PlayVideoEnded" )

			file.holdInProgress = false
		}
	)

	RunAnimationScript( "IntroButtonPress" )

	local holdDuration = 0
	while ( holdDuration < 1.5 )
	{
		wait 0
		holdDuration = Time() - holdStartTime
	}

	hold.completed = true
}

function SkipButton_Release( button )
{
	Signal( uiGlobal.signalDummy, "SkipIntroHoldReleased" )
}