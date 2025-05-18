
function main()
{
	Globalize( InitMainMenu )
	Globalize( OnOpenMainMenu )
	Globalize( DataCenterDialog )
	Globalize( Threaded_CreateLocalServer )
	Globalize( OpenOfflineNameDialogButton_Activate )
	Globalize( OnAddonButton_Activate )
	Globalize( OpenDiscordLink )
	Globalize( CloseMenuWhenAuthed)

	PrecacheHUDMaterial( "../ui/menu/r1delta/icon" )
}

function InitMainMenu( menu )
{
	file.menu <- menu
    file.dialog <- GetMenu( "UsernameDialog" )
    file.lblTextIn <- file.dialog.GetChild( "LblSetName" )

	file.errorMessage <- menu.GetChild( "ErrorMessage" )
	file.continueMessage <- menu.GetChild( "ContinueMessage" )
	file.continueMessage.EnableKeyBindingIcons()

	file.signInStatus <- menu.GetChild( "SignInStatus" )
	file.signInStatus.EnableKeyBindingIcons()

	file.menuButtons <- GetElementsByClassname( menu, "MainMenuButtonClass" )
	file.buttonData <- null

	AddEventHandlerToButtonClass( menu, "MainMenuButtonClass", UIE_CLICK, Bind( MainMenuButton_Activate ) )

	uiGlobal.activeProfile <- menu.GetChild( "ActiveProfile" )
	file.activeProfile <- menu.GetChild( "ActiveProfile" )
	file.versionDisplay <- menu.GetChild( "versionDisplay" )
	file.r1DeltaVersion <- menu.GetChild("versionDisplay2")

	file.datacenterGamepad <- menu.GetChild( "DatacenterGamepad" )
	file.datacenterGamepad.EnableKeyBindingIcons()

	AddEventHandlerToButton( menu, "DatacenterPC", UIE_CLICK, Bind( DataCenterDialog ) )
	file.datacenterPC <- menu.GetChild( "DatacenterPC" )
	file.datacenterPC.EnableKeyBindingIcons()

	file.motdMessage <- menu.GetChild( "MOTDMessage" )
	file.motdTitle <- menu.GetChild( "MOTDTitle" )
	file.motdBox <- menu.GetChild( "MOTDBox" )

	// AddEventHandlerToButton( GetMenu( "AuthDialog" ), "BtnAuth", UIE_CLICK, OnAuthButtonConnect_Activate )
    // AddEventHandlerToButton( GetMenu( "AuthDialog" ), "BtnCancel", UIE_CLICK, OnAuthButtonCancel_Activate )


	AddEventHandlerToButton( GetMenu( "UsernameDialog" ), "BtnAccept", UIE_CLICK, OpenOfflineNameDialogButtonOk_Activate )
    AddEventHandlerToButton( GetMenu( "UsernameDialog" ), "BtnCancel", UIE_CLICK, OpenOfflineNameDialogButtonCancel_Activate )
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

function OpenOfflineNameDialogButton_Activate( button )
{
	if ( uiGlobal.activeDialog )
		return

	local dialogData = {}
	dialogData.header <- "#ENTER_USERNAME_HEADER"
    dialogData.detailsMessage <- "#ENTER_USERNAME_DIALOG"

	OpenChoiceDialog( dialogData, GetMenu( "UsernameDialog" ) )
}


function OpenOfflineNameDialogButtonOk_Activate( button )
{
    local str = button.GetParent().GetChild( "LblSetName" ).GetTextEntryUTF8Text()

	if(str == "")
		return

    ClientCommand( "name " + str )
	ClientCommand("hostname \""+GetConVarString("name")+"'s R1Delta Server\"")

	uiGlobal.activeProfile.SetText( str )
	uiGlobal.activeProfile.Show()

	CloseDialog( true )
}

function OpenOfflineNameDialogButtonCancel_Activate( button )
{
    CloseDialog( true )
}

function ShowMainMenu()
{
	file.buttonData = []
	if ( Origin_IsEnabled() )
		file.buttonData.append( { name = "#PLAY", activateFunc = Bind( ThreadOnPlayButton_Activate ), updateFunc = Bind( ThreadUpdatePlayButton ) } )

	// if ( !AllDLCIsInstalled() )
	// 	file.buttonData.append( { name = "#DLC_STORE", activateFunc = Bind( OnStoreButton_Activate ), updateFunc = Bind( ThreadUpdateStoreButton ), isNew = true } )

	file.buttonData.append( { name = "#PLAY", activateFunc = Bind( OnHostButtonActivate ) } )
	file.buttonData.append( { name = "#INTRO", activateFunc = Bind( ThreadOnIntroButton_Activate ) } )
	// file.buttonData.append( { name = "CHANGELOG", activateFunc = Bind( function() { thread OnTrainingButtonActivate() } ) } )
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

	local name = GetConVarString("name")
	// if ( Durango_IsDurango() )
	// 	name = Durango_GetGameDisplayName()
	// //else
	// //	name = "Slapfight McGillicutty"

	file.activeProfile.SetText( name )
	file.activeProfile.Show()

	// we don't ship gameversion.txt
	file.versionDisplay.SetText( "v1.0.10.1" )
	file.versionDisplay.Show()

	file.r1DeltaVersion.SetText( GetR1DVersion() )
	file.r1DeltaVersion.Show()

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

    local username = GetConVarString( "name" )

	if ( username == "unnamed" )
		OpenOfflineNameDialogButton_Activate( null )

	uiGlobal.mainMenuFocus = focus
	AuthDialog()
	if ( !Origin_IsEnabled() )
	{
		local randomID = RandomInt( 0, 999999999 ).tostring()
		ClientCommand( "platform_user_id " + randomID )
	}
	ClientCommand("hostname \"" + username + "'s R1Delta Server\"")
	ClientCommand("loadPlaylists")

	SendDiscordUI(null)
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
			playEnabled = false

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

	if ( Origin_IsEnabled() ) {
		file.datacenterGamepad.Show()
		file.datacenterPC.Show()
	}

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
	local motd = ""
	file.motdTitle.SetText( "#DELTA_PATCH_HEADER" )
	while ( uiGlobal.activeMenu == file.menu && ( !Durango_IsDurango() || GetMainMenuState() == mainMenuState.SIGNED_IN ) )
	{
		motd = GetConVarString( "motd" )

		if ( motd != "" )
		{
			file.motdMessage.SetText( motd )
			ShowMOTD()
		}
		else
		{
			HideMOTD()
		}

		wait 0
	}
}

function MainMenuButton_Activate( button )
{
	local buttonID = button.GetScriptID().tointeger()

	Assert( file.buttonData )

	file.mainMenuButtonBeingActivated <- button

	if ( file.buttonData[buttonID].activateFunc )
		file.buttonData[buttonID].activateFunc.call( this )
}

function ThreadOnIntroButton_Activate()
{
	thread OnIntroButton_Activate()
}

function PlayIntroVideoAndHideWatermark()
{
	thread HideWatermarkForIntro()
	PlayIntroVideo( true )
}

function OnIntroButton_Activate()
{
	PlayIntroVideoAndHideWatermark()
}

function HideWatermarkForIntro()
{
	local watermarkEnabled = GetConVarInt( "delta_watermark" ) == 1

	if( watermarkEnabled )
		ClientCommand( "delta_watermark 0" )

	WaitSignal( uiGlobal.signalDummy, "PlayVideoEnded" )

	if ( watermarkEnabled )
		ClientCommand( "delta_watermark 1" )
}

function ThreadOnPlayButton_Activate()
{
	thread OnPlayButton_Activate()
}

function OnPlayButton_Activate()
{
	if ( !IsIntroViewed() )
		PlayIntroVideoAndHideWatermark()

	if ( !Durango_IsDurango() || Durango_IsSignedIn() ) // Check user is still signed in
		thread StartMatchmakingIntoEmptyServer( "" )
}

function OnHostButtonActivate()
{
	// local desc 			= "Are you sure?"
	// local confirmText 	= "#YES"

	// local buttonData = []
	// buttonData.append( { name = confirmText, func = OnHostButtonDialogActivate } )
	// buttonData.append( { name = "#NO", func = null } )

	// local dialogData = {}
	// dialogData.header <- "Create Lobby"
	// dialogData.detailsMessage <- desc
	// dialogData.buttonData <- buttonData

	// OpenChoiceDialog( dialogData )
	thread Threaded_CreateLocalServer()
}

function OnHostButtonDialogActivate()
{
	thread Threaded_CreateLocalServer()
}

function Threaded_CreateLocalServer()
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

	// Play the intro video at all costs if the user never saw it before (intended vanilla behavior)
	if(!IsIntroViewed())
		PlayIntroVideoAndHideWatermark()

	Signal( uiGlobal.signalDummy, "OnCancelConnect" )
	EndSignal( uiGlobal.signalDummy, "OnCancelConnect" )

	uiGlobal.dialogCloseCallback =
		function( canceled )
		{
			Signal( uiGlobal.signalDummy, "OnCancelConnect" )

			uiGlobal.matchmaking = false
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

	uiGlobal.matchmaking = true

	uiGlobal.ConfirmMenuDetails.SetText( "#LOADING_SERVER" )

	wait 0.65 // artificial wait so people can cancel

	ClientCommand("playlist private_match; map mp_lobby")

	thread TryChangeLobbyType()
}

function TryChangeLobbyType()
{
	while ( uiGlobal.activeMenu != GetMenu( "LobbyMenu" ) )
		wait 0.1

	if( GetConVarInt("hide_server") == 0 )
	{
		ClientCommand( "hide_server 1" )
		uiGlobal.setServerPublicNextPrivateLobby <- true
	}

	ClientCommand( "RequestServerChangeToLobbyType0" )
	ClientCommand( "TryKickPlayersForPersonalLobby" )
}

function Threaded_LaunchTraining()
{
	ShowTrainingConnectDialog()

	wait 2

	if(uiGlobal.doTraining)
	{
		uiGlobal.doTraining = false // Just in case...
		CloseDialog()
		// respawn launches training on tdm gamemode in the vanilla game
		ClientCommand("playlist tdm; mp_gamemode tdm; map mp_npe")
	}
	return
}

function OnAuthButtonConnect_Activate() {
	ClientCommand("delta_start_discord_auth")
	thread CloseMenuWhenAuthed()
}

function CloseMenuWhenAuthed() {
	while ( GetConVarString( "delta_persistent_master_auth_token" ) == "" ) {
		wait(0.1)
		if(GetConVarString("delta_persistent_master_auth_token_failed_reason") != "") {
			EmitUISound( "BlackMarket_Purchase_Fail" )

			local buttonData = []
			buttonData.append( { name = "Join the discord", func = OpenDiscordURL } )
			buttonData.append( { name = "#CLOSE", func = OnAuthButtonCancel_Activate  } )
			local dialogData = {}

			dialogData.header <- "Authentication Failed"
			dialogData.buttonData <- buttonData
			dialogData.detailsMessage <- GetConVarString("delta_persistent_master_auth_token_failed_reason") + " =)"
			dialogData.spinner <- false
			dialogData.detailsColor <- [ 255, 0, 0, 255 ]
			OpenChoiceDialog( dialogData)
			return
		}
	}
	CloseDialog(false)
}

function OnAuthButtonCancel_Activate() {
	CloseDialog(false)
}

function AuthDialog() {

	// check if the delta_persisant_master_token is set
	if ( GetConVarString( "delta_persistent_master_auth_token" ) != "" )
		return

	if(GetConvarInt("delta_online_auth_enable") != 1)
		return

	local buttonData = []
	buttonData.append( { name = "Login with Discord", func = OnAuthButtonConnect_Activate } )
	buttonData.append( { name = "#CLOSE", func = OnAuthButtonCancel_Activate  } )

	local footerData = []
	footerData.append( { label = "#A_BUTTON_SELECT" , func = OnAuthButtonConnect_Activate } )

	local dialogData = {}
	dialogData.header <- "Authenticate with Discord"
    dialogData.detailsMessage <- "R1Delta uses Discord for authentication. Click the button below to authenticate with Discord."
	dialogData.buttonData <- buttonData
	dialogData.footerData <- footerData
	dialogData.spinner <- false

	OpenChoiceDialog( dialogData )

}



function LaunchTraining() {
	thread Threaded_LaunchTraining()
}

function OnTrainingButtonActivate()
{
	local buttonData = []
	local everStarted = GetTrainingHasEverBeenStartedUI()
	local everFinished = GetTrainingHasEverFinished()
	local resumeChoice = GetPlayerTrainingResumeChoiceUI()
	local header = null
	local desc = null
	printt( "training everStarted?", everStarted, "everFinished?", everFinished, "resumeChoice=", resumeChoice )
	if ( !everStarted || ( everStarted && !everFinished && resumeChoice < 0 ) )
	{
		printt( "TRAINING STARTING, player has never finished it." )
		if(!IsIntroViewed())
			PlayIntroVideoAndHideWatermark()
		LaunchTraining()
		return
	}
	else if ( everStarted && !everFinished && resumeChoice >= 0 )
	{
		buttonData.append( { name = "#TRAINING_CONTINUE", func = Bind( LaunchTraining ), nameData = GetTrainingNameForResumeChoice( resumeChoice ) } )
		buttonData.append( { name = "#TRAINING_START_OVER", func = Bind( LocalDialogChoice_RestartTraining ) } )
		buttonData.append( { name = "#CANCEL", func = null } )
		header = "#TRAINING_CONTINUE_PROMPT"
		desc = "#TRAINING_CONTINUE_PROMPT_DESC"
	}
	else
	{
		buttonData.append( { name = "#VIDEO_INTRO", func = function() { thread PlayIntroVideoAndHideWatermark() } } )
		buttonData.append( { name = "#TRAINING_CONTINUE_CLASSIC", func = Bind( LocalDialogChoice_Training_New ) } )
		buttonData.append( { name = "#TRAINING_CONTINUE_CUSTOM", func = Bind( LocalDialogChoice_Training_Custom ) } )
		buttonData.append( { name = "#CANCEL", func = null } )
		header = "#TRAINING_PLAYAGAIN_PROMPT"
		desc = TranslateTokenToUTF8("#TRAINING_PLAYAGAIN_PROMPT_DESC") + " \n" + TranslateTokenToUTF8("#TRAINING_PLAYAGAIN_PROMPT_DESC2")
	}
	local dialogData = {}
	dialogData.header <- header
	dialogData.detailsMessage <- desc
	dialogData.buttonData <- buttonData

	OpenChoiceDialog( dialogData, GetMenu( "TrainingDialog" ) )
}

function OnOptionsButton_Activate()
{
	AdvanceMenu( GetMenu( "OptionsMenu" ) )
}

function OnFindMatchButton_Activate()
{
	AdvanceMenu( GetMenu( "ServerBrowserMenu" ) )
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

function OnAddonButton_Activate( button )
{
	AdvanceMenu( GetMenu( "Addons" ) )
}

function OpenDiscordLink(button) {
	OpenDiscordURL()
}
