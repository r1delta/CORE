
function main()
{
	Globalize( InitMainMenu )
	Globalize( OnOpenMainMenu )
	Globalize( DataCenterDialog )
}

function InitMainMenu( menu )
{
	file.menu <- menu

	file.errorMessage <- menu.GetChild( "ErrorMessage" )
	file.continueMessage <- menu.GetChild( "ContinueMessage" )
	file.continueMessage.EnableKeyBindingIcons()

	file.signInStatus <- menu.GetChild( "SignInStatus" )
	file.signInStatus.EnableKeyBindingIcons()

	file.menuButtons <- GetElementsByClassname( menu, "MainMenuButtonClass" )
	file.buttonData <- null

	AddEventHandlerToButtonClass( menu, "MainMenuButtonClass", UIE_CLICK, Bind( MainMenuButton_Activate ) )

	file.activeProfile <- menu.GetChild( "ActiveProfile" )
	file.versionDisplay <- menu.GetChild( "versionDisplay" )

	file.datacenterGamepad <- menu.GetChild( "DatacenterGamepad" )
	file.datacenterGamepad.EnableKeyBindingIcons()

	AddEventHandlerToButton( menu, "DatacenterPC", UIE_CLICK, Bind( DataCenterDialog ) )
	file.datacenterPC <- menu.GetChild( "DatacenterPC" )
	file.datacenterPC.EnableKeyBindingIcons()

	file.motdMessage <- menu.GetChild( "MOTDMessage" )
	file.motdTitle <- menu.GetChild( "MOTDTitle" )
	file.motdBox <- menu.GetChild( "MOTDBox" )
}

function OnOpenMainMenu()
{
	if ( !Durango_IsDurango() )
	{
		ShowMainMenu()
		return
	}

	local state
	local lastState

	HideError()
	HideSignInStatus()
	HideMainMenu()

	while ( uiGlobal.activeMenu == file.menu )
	{
		state = GetMainMenuState()

		if ( state != lastState )
		{
			if ( state == mainMenuState.SIGNED_IN && lastState != null )
				wait 0.1 // wait an extra frame so that old input from the newly activated controller doesn't activate the play button.

			HideError()
			HideSignInStatus()
			HideMainMenu()

			if ( state == mainMenuState.ERROR )
			{
				ShowError( Durango_GetErrorString() )
			}
			else if ( state == mainMenuState.SIGNED_OUT )
			{
				ShowSignInStatus( "#A_BUTTON_START" )

				if ( uiGlobal.activeDialog == GetMenu( "DataCenterDialog" ) )
					CloseDialog( true )
			}
			else if ( state == mainMenuState.SIGNING_IN )
			{
				ShowSignInStatus( "#SIGNING_IN" )
			}
			else if ( state == mainMenuState.SIGNED_IN )
			{
				ShowMainMenu()
			}

			UpdateFooterButtons()
		}

		lastState = state

		wait 0
	}
}

function GetMainMenuState()
{
	if ( Durango_InErrorScreen() )
		return mainMenuState.ERROR
	else if ( Durango_IsSigningIn() )
		return mainMenuState.SIGNING_IN
	else if ( !Durango_IsSignedIn() && !Durango_SkippedSignIn() )
		return mainMenuState.SIGNED_OUT
	else
	{
		Assert( Durango_IsSignedIn() || Durango_SkippedSignIn() )
		return mainMenuState.SIGNED_IN
	}
}

function ShowError( error )
{
	file.errorMessage.SetText( "#ERROR", error )
	file.errorMessage.Show()
	file.continueMessage.Show()
}

function ShowSignInStatus( status )
{
	file.signInStatus.SetText( status )
	file.signInStatus.Show()
}

function AllDLCIsInstalled()
{
	if ( !IsDLCMapGroupEnabledForLocalPlayer( 1 ) )
		return false;
	if ( !IsDLCMapGroupEnabledForLocalPlayer( 2 ) )
		return false;
	if ( !IsDLCMapGroupEnabledForLocalPlayer( 3 ) )
		return false;

	return true;
}

function ShowMainMenu()
{
	file.buttonData = []
	file.buttonData.append( { name = "#PLAY", activateFunc = Bind( ThreadOnPlayButton_Activate ), updateFunc = Bind( ThreadUpdatePlayButton ) } )

	if ( !AllDLCIsInstalled() )
		file.buttonData.append( { name = "#DLC_STORE", activateFunc = Bind( OnStoreButton_Activate ), updateFunc = Bind( ThreadUpdateStoreButton ), isNew = true } )

	if ( IsIntroViewed() )
		file.buttonData.append( { name = "#INTRO", activateFunc = Bind( ThreadOnIntroButton_Activate ) } )
	file.buttonData.append( { name = "#OPTIONS", activateFunc = Bind( OnOptionsButton_Activate ) } )
	file.buttonData.append( { name = "#CREDITS", activateFunc = Bind( ThreadOnCreditsButton_Activate ) } )
	if ( !Durango_IsDurango() )
		file.buttonData.append( { name = "#QUIT", activateFunc = Bind( OnQuitButton_Activate ) } )

	foreach ( button in file.menuButtons )
	{
		local buttonID = button.GetScriptID().tointeger()

		if ( buttonID < file.buttonData.len() )
		{
			if ( "updateFunc" in file.buttonData[buttonID] )
			{
				file.buttonData[buttonID].updateFunc.call( this, button )
			}
			else
			{
				button.SetEnabled( true )
			}

			if ( "isNew" in file.buttonData[buttonID] && file.buttonData[buttonID].isNew )
				button.SetNew( true )
			else
				button.SetNew( false )

			button.SetText( file.buttonData[buttonID].name )
			button.Show()
		}
		else
		{
			button.Hide()
		}
	}

	local name = ""
	if ( Durango_IsDurango() )
		name = Durango_GetGameDisplayName()
	//else
	//	name = "Slapfight McGillicutty"

	file.activeProfile.SetText( name )
	file.activeProfile.Show()

	file.versionDisplay.SetText( GetPublicGameVersion() + " + R1Delta" )
	file.versionDisplay.Show()

	thread UpdateDatacenterInfo()
	thread UpdateMOTD()

	ExecCurrentGamepadButtonConfig()
	ExecCurrentGamepadStickConfig()

	thread EULA_Dialog()

	local focus = GetFocus()
	local validFocus = false

	foreach ( button in file.menuButtons )
	{
		if ( button == focus && button.IsVisible() )
			validFocus = true
	}

	if ( !validFocus )
	{
		FocusDefault( file.menu )
		focus = GetFocus()
	}

	uiGlobal.mainMenuFocus = focus
}

function ShowMOTD()
{
	file.motdMessage.Show()
	file.motdTitle.Show()
	file.motdBox.Show()
}

function HideMOTD()
{
	file.motdMessage.Hide()
	file.motdTitle.Hide()
	file.motdBox.Hide()
}

function HideError()
{
	file.errorMessage.Hide()
	file.continueMessage.Hide()
}

function HideSignInStatus()
{
	file.signInStatus.Hide()
}

function HideMainMenu()
{
	foreach ( elem in file.menuButtons )
		elem.Hide()

	file.activeProfile.Hide()
	file.versionDisplay.Hide()

	uiGlobal.mainMenuFocus = null
}

function ThreadUpdatePlayButton( button )
{
	if ( Durango_IsDurango() )
		thread UpdateXboxPlayButton( button )
	else
		thread UpdatePCPlayButton( button )
}

function UpdateXboxPlayButton( button )
{
	Assert( Durango_IsDurango() )

	local buttonMessage = button.GetChild( "ButtonMessage" )
	local isOnline
	local playEnabled
	local lastResult
	local isGuest
	local lastIsGuest

	while ( uiGlobal.activeMenu == file.menu )
	{
		isOnline = Durango_IsOnline()
		playEnabled = ( isOnline && Durango_HasPermissionToPlayMultiplayer() )
		isGuest = ( isOnline && Durango_IsGuest() )

		if ( playEnabled != lastResult || isGuest != lastIsGuest )
		{
			button.SetEnabled( playEnabled )

			if ( isOnline )
			{
				if ( playEnabled )
				{
					buttonMessage.SetText( "" )
					file.menu.RunAnimationScript( "HidePlayButtonMessage" )
				}
				else if ( isGuest )
				{
					buttonMessage.SetText( "#GUESTS_NOT_SUPPORTED" )
					file.menu.RunAnimationScript( "ShowPlayButtonMessage" )
				}
				else
				{
					buttonMessage.SetText( "#MULTIPLAYER_NOT_AVAILABLE" )
					file.menu.RunAnimationScript( "ShowPlayButtonMessage" )
				}
			}
			else
			{
				buttonMessage.SetText( "#INTERNET_NOT_FOUND" )
				file.menu.RunAnimationScript( "ShowPlayButtonMessage" )
			}
		}

		lastResult = playEnabled
		lastIsGuest = isGuest

		wait 0
	}
}

function UpdatePCPlayButton( button )
{
	local buttonMessage = button.GetChild( "ButtonMessage" )
	local playEnabled
	local lastResult

	while ( uiGlobal.activeMenu == file.menu )
	{
		if ( Origin_IsEnabled() )
			playEnabled = Origin_IsOnline()
		else
			playEnabled = true

		if ( playEnabled != lastResult )
		{
			button.SetEnabled( playEnabled )

			if ( playEnabled )
			{
				buttonMessage.SetText( "" )
				file.menu.RunAnimationScript( "HidePlayButtonMessage" )
			}
			else
			{
				buttonMessage.SetText( "#ORIGIN_IS_OFFLINE" )
				file.menu.RunAnimationScript( "ShowPlayButtonMessage" )
			}
		}

		lastResult = playEnabled

		wait 0
	}
}

function ThreadUpdateStoreButton( button )
{
	if ( !Durango_IsDurango() )
		thread UpdatePCStoreButton( button )
}

function UpdatePCStoreButton( button )
{
	local buttonMessage = button.GetChild( "ButtonMessage" )
	local buttonState
	local lastResult

	while ( uiGlobal.activeMenu == file.menu )
	{
		if ( Origin_IsEnabled() && Origin_IsOnline() )
		{
			if ( Origin_IsOverlayAvailable() )
				buttonState = 0
			else
				buttonState = 2
		}
		else
		{
			buttonState = 1
		}

		if ( buttonState != lastResult )
		{
			switch ( buttonState )
			{
				case 0: // Normal
					button.SetEnabled( true )
					buttonMessage.SetText( "" )
					file.menu.RunAnimationScript( "HideStoreButtonMessage" )
					break

				case 1: // Disabled (dev or offline)
					button.SetEnabled( false )
					buttonMessage.SetText( "" )
					file.menu.RunAnimationScript( "HideStoreButtonMessage" )
					break

				case 2: // Disabled with message
					button.SetEnabled( false )
					buttonMessage.SetText( "#ORIGIN_OVERLAY_DISABLED" )
					file.menu.RunAnimationScript( "ShowStoreButtonMessage" )
					break

				default:
					break
			}
		}

		lastResult = buttonState

		wait 0
	}
}

function UpdateDatacenterInfo()
{
	OnThreadEnd(
		function() : ()
		{
			file.datacenterGamepad.Hide()
			file.datacenterPC.Hide()
		}
	)

	local ping
	local name

	file.datacenterGamepad.Show()
	file.datacenterPC.Show()

	while ( uiGlobal.activeMenu == file.menu && ( !Durango_IsDurango() || GetMainMenuState() == mainMenuState.SIGNED_IN ) )
	{
		ping = GetDatacenterPing()
		name = GetDatacenterName()

		if ( ping > 0 )
		{
			file.datacenterGamepad.SetText( "#X_BUTTON_DATACENTER_INFO", name, ping )
			file.datacenterPC.SetText( "#DATACENTER_INFO", name, ping )
		}
		else
		{
			file.datacenterGamepad.SetText( "#X_BUTTON_DATACENTER_CALCULATING" )
			file.datacenterPC.SetText( "#DATACENTER_CALCULATING" )
		}

		wait 0
	}
}

function UpdateMOTD()
{
	OnThreadEnd(
		function() : ()
		{
			HideMOTD()
		}
	)

	file.motdMessage.SetText( "R1Delta release just a week away!" )
	ShowMOTD()
}

function MainMenuButton_Activate( button )
{
	local buttonID = button.GetScriptID().tointeger()

	Assert( file.buttonData )

	file.mainMenuButtonBeingActivated <- button

	if ( file.buttonData[buttonID].activateFunc )
		file.buttonData[buttonID].activateFunc.call( this )
}

function ThreadOnPlayButton_Activate()
{
	thread OnPlayButton_Activate()
}

function OnPlayButton_Activate()
{
	if ( !IsIntroViewed() )
		PlayIntroVideo( true )

	if ( !Durango_IsDurango() || Durango_IsSignedIn() ) // Check user is still signed in
		thread StartMatchmakingIntoEmptyServer( "" )
}

function ThreadOnIntroButton_Activate()
{
	thread OnIntroButton_Activate()
}

function OnIntroButton_Activate()
{
	PlayIntroVideo( true )
}

function OnOptionsButton_Activate()
{
	AdvanceMenu( GetMenu( "OptionsMenu" ) )
}

function ThreadOnCreditsButton_Activate()
{
	thread OnCreditsButton_Activate()
}

function OnStoreButton_Activate()
{
	file.mainMenuButtonBeingActivated.SetNew( false )
	ShowDLCStore()
}

function OnCreditsButton_Activate()
{
	PlayCredits( true )
}

function OnQuitButton_Activate()
{
	OpenDialog( GetMenu( "ConfirmDialog" ), "#MENU_QUIT_GAME_CONFIRM", "BtnConfirmQuitGame" )
}

function StartMatchmakingIntoEmptyServer( playlist )
{
	// IMPORTANT: As a safety measure leave any party view we are in at this point.
	// Otherwise, if you are unlucky enough to get stuck in a party view, you will
	// trash its state by pointing it to your private lobby.
	if ( Durango_IsDurango() )
		Durango_LeaveParty()

	// IMPORTANT: It's possible that you have permission to play multiplayer
	// because your friend is signed in with his gold account on your machine,
	// but once that guy signs out, you shouldn't be able to play like you have
	// xboxlive gold anymore. To fix this, we need to check permissions periodically.
	// One of the places where we do this periodic check is when you press "PLAY"
	if ( Durango_IsDurango() )
		Durango_CheckPermissions()

	Signal( uiGlobal.signalDummy, "OnCancelConnect" )
	EndSignal( uiGlobal.signalDummy, "OnCancelConnect" )

	uiGlobal.dialogCloseCallback =
		function( canceled )
		{
			Signal( uiGlobal.signalDummy, "OnCancelConnect" )

			uiGlobal.matchmaking = false
			if ( canceled )
				MatchmakingCancel()
		}

	OpenDialog( GetMenu( "ConfirmDialog" ), "#MATCHMAKING_TITLE_CONNECTING" )

	uiGlobal.ConfirmMenuDetails.SetText( "" )
	uiGlobal.ConfirmMenuErrorCode.SetText( "" )

	uiGlobal.ConfirmMenuDetails.Show()
	uiGlobal.ConfirmMenuErrorCode.Show()

	if ( Origin_IsEnabled() )
	{
		Origin_RequestTicket()
		uiGlobal.ConfirmMenuDetails.SetText( "#WAITING_FOR_ORIGIN" )

		while ( !Origin_IsReady() )
			wait 0
	}

	MatchmakingBegin( playlist )
	uiGlobal.matchmaking = true

	uiGlobal.ConfirmMenuDetails.SetAutoText( "", HATT_MATCHMAKING_EMPTY_SERVER_SEARCH_STATE, 0 )
	uiGlobal.ConfirmMenuErrorCode.SetAutoText( "", HATT_MATCHMAKING_EMPTY_SERVER_SEARCH_ERROR, 0 )
}

function DataCenterDialog( button )
{
	if ( uiGlobal.activeMenu == file.menu )
		OpenDataCenterDialog()
}

function EULA_Dialog()
{
	if ( !Durango_IsDurango() || GetMainMenuState() != mainMenuState.SIGNED_IN )
		return

	if ( GetEULAVersionAccepted() >= 1 )
		return

	local buttonData = []
	buttonData.append( { name = "#EULA_ACCEPT", func = EULA_Accept } )
	buttonData.append( { name = "#EULA_DECLINE", func = EULA_Decline } )

	local footerData = []
	footerData.append( { label = "#A_BUTTON_SELECT" } )

	local dialogData = {}
	dialogData.header <- "#EULA_HEADER"
	dialogData.detailsMessage <- "#EULA_MESSAGE"
	dialogData.buttonData <- buttonData
	dialogData.footerData <- footerData

	OpenChoiceDialog( dialogData )
	uiGlobal.forceDialogChoice = true

	uiGlobal.showingEULA = true

	wait 0
	local dialogMenu = GetMenu( "ChoiceDialog" )
	if ( uiGlobal.activeDialog == dialogMenu )
		FocusDefaultMenuItem( dialogMenu )
}

function EULA_Accept()
{
	SetEULAVersionAccepted( 1 )
	uiGlobal.showingEULA = false
}

function EULA_Decline()
{
	Durango_GoToSplashScreen()
	uiGlobal.showingEULA = false
}