
function main()
{
	PrecacheHUDMaterial( "../ui/menu/common/menu_background_neutral" )
	PrecacheHUDMaterial( "../ui/menu/common/menu_background_imc" )
	PrecacheHUDMaterial( "../ui/menu/common/menu_background_militia" )
	PrecacheHUDMaterial( "../ui/menu/common/menu_background_imc_blur" )
	PrecacheHUDMaterial( "../ui/menu/common/menu_background_militia_blur" )
	PrecacheHUDMaterial( "../ui/menu/common/menu_background_neutral_blur" )
	PrecacheHUDMaterial( "../ui/menu/common/menu_background_blackMarket" )
	PrecacheHUDMaterial( "../ui/menu/rank_menus/ranked_FE_background" )

	PrecacheHUDMaterial( "../ui/menu/lobby/friendly_slot" )
	PrecacheHUDMaterial( "../ui/menu/lobby/friendly_player" )
	PrecacheHUDMaterial( "../ui/menu/lobby/enemy_slot" )
	PrecacheHUDMaterial( "../ui/menu/lobby/enemy_player" )
	PrecacheHUDMaterial( "../ui/menu/lobby/neutral_slot" )
	PrecacheHUDMaterial( "../ui/menu/lobby/neutral_player" )
	PrecacheHUDMaterial( "../ui/menu/lobby/player_hover" )

	PrecacheHUDMaterial( "../ui/menu/lobby/lobby_image_mp_fracture" )
	PrecacheHUDMaterial( "../ui/menu/lobby/lobby_image_mp_colony" )
	PrecacheHUDMaterial( "../ui/menu/lobby/lobby_image_mp_relic" )
	PrecacheHUDMaterial( "../ui/menu/lobby/lobby_image_mp_angel_city" )
	PrecacheHUDMaterial( "../ui/menu/lobby/lobby_image_mp_outpost_207" )
	PrecacheHUDMaterial( "../ui/menu/lobby/lobby_image_mp_boneyard" )
	PrecacheHUDMaterial( "../ui/menu/lobby/lobby_image_mp_airbase" )
	PrecacheHUDMaterial( "../ui/menu/lobby/lobby_image_mp_o2" )
	PrecacheHUDMaterial( "../ui/menu/lobby/lobby_image_mp_corporate" )
	PrecacheHUDMaterial( "../ui/menu/lobby/lobby_image_mp_lagoon" )
	PrecacheHUDMaterial( "../ui/menu/lobby/lobby_image_mp_overlook" )
	PrecacheHUDMaterial( "../ui/menu/lobby/lobby_image_mp_nexus" )
	PrecacheHUDMaterial( "../ui/menu/lobby/lobby_image_mp_rise" )
	PrecacheHUDMaterial( "../ui/menu/lobby/lobby_image_mp_smugglers_cove" )
	PrecacheHUDMaterial( "../ui/menu/lobby/lobby_image_mp_training_ground" )
	PrecacheHUDMaterial( "../ui/menu/lobby/lobby_image_mp_wargames" )
	PrecacheHUDMaterial( "../ui/menu/lobby/lobby_image_mp_runoff" )
	PrecacheHUDMaterial( "../ui/menu/lobby/lobby_image_mp_swampland" )
	PrecacheHUDMaterial( "../ui/menu/lobby/lobby_image_mp_harmony_mines" )
	PrecacheHUDMaterial( "../ui/menu/lobby/lobby_image_mp_switchback" )
	PrecacheHUDMaterial( "../ui/menu/lobby/lobby_image_mp_haven" )
	PrecacheHUDMaterial( "../ui/menu/lobby/lobby_image_mp_backwater" )
	PrecacheHUDMaterial( "../ui/menu/lobby/lobby_image_mp_sandtrap" )
	PrecacheHUDMaterial( "../ui/menu/lobby/lobby_image_mp_zone_18" )

	PrecacheHUDMaterial( "../ui/menu/dlc_menu_grid/dlc_menu_grid_1_installed" )
	PrecacheHUDMaterial( "../ui/menu/dlc_menu_grid/dlc_menu_grid_1_not_installed" )
	PrecacheHUDMaterial( "../ui/menu/dlc_menu_grid/dlc_menu_grid_2_installed" )
	PrecacheHUDMaterial( "../ui/menu/dlc_menu_grid/dlc_menu_grid_2_not_installed" )
	PrecacheHUDMaterial( "../ui/menu/dlc_menu_grid/dlc_menu_grid_3_installed" )
	PrecacheHUDMaterial( "../ui/menu/dlc_menu_grid/dlc_menu_grid_3_not_installed" )

	PrecacheHUDMaterial( MAP_STARS_IMAGE_EMPTY )
	PrecacheHUDMaterial( MAP_STARS_IMAGE_FULL )

	Globalize( InitLobbyMenu )
	Globalize( OnOpenLobbyMenu )
	Globalize( OnCloseLobbyMenu )
	Globalize( GetLobbyTypeScript )
	Globalize( UpdateEditLoadoutButtons )
	Globalize( UpdateGameSummaryButton )
	Globalize( UpdateChallengesButton )
	Globalize( UpdateRegenButton )
	Globalize( DialogChoice_Regen_ViewChallenges )
	Globalize( UI_DoTraining )
	Globalize( GetTrainingNameForResumeChoice )
	Globalize( DialogChoice_RestartTraining )
	Globalize( DialogChoice_TrainPilotOnly )
	Globalize( DialogChoice_TrainTitanOnly )
	Globalize( ServerCallback_DoTraining )
	Globalize( ServerCallback_EndTraining )
	Globalize( PrivateMatchSwitchTeams )
	Globalize( UICodeCallback_SetupPlayerListGenElements )
	Globalize( UpdateTeamInfo )
	Globalize( ViewStarsButton_Activated )
	Globalize( UpdateLobbyAnnounceDialog )
	Globalize( OnClickGameSummaryButton )
	Globalize( OnPrivateMatchButtonThreaded )
	Globalize( LaunchTraining )
	Globalize( LocalDialogChoice_Training_New )
	Globalize( LocalDialogChoice_Training_Custom )
	Globalize( LocalDialogChoice_RestartTraining )
	Globalize( LocalDialogChoice_TrainPilotOnly )
	Globalize( LocalDialogChoice_TrainTitanOnly )
}

function InitLobbyMenu( menu )
{
	uiGlobal.updatingLobbyUI <- false

	AddEventHandlerToButton( menu, "BigPlayButton1", UIE_CLICK, BigPlayButton1_Activate )
	AddEventHandlerToButton( menu, "CoopMatchButton", UIE_CLICK, CoopMatchButton_Activate )
	AddEventHandlerToButton( menu, "PrivateMatchButton", UIE_CLICK, OnPrivateMatchButton_Activate )
	AddEventHandlerToButton( menu, "TrainingButton", UIE_CLICK, TrainingButton_ActivateOrStartDialog )

	AddEventHandlerToButton( menu, "StartMatchButton", UIE_CLICK, OnStartMatchButton_Activate )
	AddEventHandlerToButton( menu, "StartMatchButton", UIE_GET_FOCUS, OnStartMatchButton_GetFocus )
	AddEventHandlerToButton( menu, "StartMatchButton", UIE_LOSE_FOCUS, OnStartMatchButton_LoseFocus )

	AddEventHandlerToButton( menu, "MapsButton", UIE_CLICK, OnMapsButton_Activate )
	AddEventHandlerToButton( menu, "ModesButton", UIE_CLICK, OnModesButton_Activate )
	AddEventHandlerToButton( menu, "SettingsButton", UIE_CLICK, OnSettingsButton_Activate )

	AddEventHandlerToButton( menu, "BtnEditPilotLoadouts", UIE_CLICK, EditPilotLoadoutList_Activate )
	AddEventHandlerToButtonClass( menu, "EditPilotLoadoutsButtonClass", UIE_GET_FOCUS, LockedButtonGetFocusHandler )
	AddEventHandlerToButtonClass( menu, "EditPilotLoadoutsButtonClass", UIE_LOSE_FOCUS, LockedButtonLoseFocusHandler )
	AddEventHandlerToButtonClass( menu, "EditTitanLoadoutsButtonClass", UIE_CLICK, EditTitanLoadoutList_Activate )
	AddEventHandlerToButtonClass( menu, "EditTitanLoadoutsButtonClass", UIE_GET_FOCUS, LockedButtonGetFocusHandler )
	AddEventHandlerToButtonClass( menu, "EditTitanLoadoutsButtonClass", UIE_LOSE_FOCUS, LockedButtonLoseFocusHandler )
	AddEventHandlerToButtonClass( menu, "EditBurnCardsButtonClass", UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "BurnCards_InGame" ) ) )
	AddEventHandlerToButtonClass( menu, "BtnBlackMarketClass", UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "BlackMarketMainMenu" ) ) )
	AddEventHandlerToButton( menu, "BtnStats", UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "ViewStatsMenu" ) ) )
	AddEventHandlerToButtonClass( menu, "BtnGameSummaryClass", UIE_CLICK, OnClickGameSummaryButton )
	AddEventHandlerToButton( menu, "BtnChallenges", UIE_CLICK, ViewChallenges_Activate )
	AddEventHandlerToButton( menu, "BtnChallenges", UIE_GET_FOCUS, LockedButtonGetFocusHandler )
	AddEventHandlerToButton( menu, "BtnChallenges", UIE_LOSE_FOCUS, LockedButtonLoseFocusHandler )
	AddEventHandlerToButtonClass( menu, "OptionsButtonClass", UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "OptionsMenu" ) ) )
	AddEventHandlerToButtonClass( menu, "LeaveGameButtonClass", UIE_CLICK, OnLeaveGameButton_Activate )
	AddEventHandlerToButton( menu, "BtnRegen", UIE_CLICK, RegenButton_Activate )
	AddEventHandlerToButton( menu, "RankedButton", UIE_CLICK, OnClickRankedButton )

	RegisterUIVarChangeCallback( "badRepPresent", UpdateLobbyBadRepPresentMessage )

	RegisterUIVarChangeCallback( "nextMapModeComboIndex", NextMapModeComboIndex_Changed )
	RegisterUIVarChangeCallback( "privatematch_map", Privatematch_map_Changed )
	RegisterUIVarChangeCallback( "privatematch_mode", Privatematch_mode_Changed )
	RegisterUIVarChangeCallback( "privatematch_starting", Privatematch_starting_Changed )
	RegisterUIVarChangeCallback( "gameStartTime", GameStartTime_Changed )

	RegisterUIVarChangeCallback( "coopLobbyMap", CoopLobbyMap_Changed )

	RegisterUIVarChangeCallback( "listenHostUsernameHash", ListenHostUsernameHash_Changed )

	file.searchIconElems <- GetElementsByClassnameForMenus( "SearchIconClass", uiGlobal.allMenus )
	file.searchTextElems <- GetElementsByClassnameForMenus( "SearchTextClass", uiGlobal.allMenus )
	file.matchStartCountdownElems <- GetElementsByClassnameForMenus( "MatchStartCountdownClass", uiGlobal.allMenus )
	file.MMDevStringElems <- GetElementsByClassnameForMenus( "MMDevStringClass", uiGlobal.allMenus )
	file.myTeamLogoElems <- GetElementsByClassnameForMenus( "MyTeamLogoClass", uiGlobal.allMenus )
	file.myTeamNameElems <- GetElementsByClassnameForMenus( "MyTeamNameClass", uiGlobal.allMenus )
	file.enemyTeamLogoElems <- GetElementsByClassnameForMenus( "EnemyTeamLogoClass", uiGlobal.allMenus )
	file.enemyTeamNameElems <- GetElementsByClassnameForMenus( "EnemyTeamNameClass", uiGlobal.allMenus )

	file.enemyTeamBackgroundPanel <- menu.GetChild( "LobbyEnemyTeamBackground" )
	file.friendlyTeamBackgroundPanel <- menu.GetChild( "LobbyFriendlyTeamBackground" )

	file.enemyTeamBackground <- file.enemyTeamBackgroundPanel.GetChild( "TeamBackground" )
	file.friendlyTeamBackground <- file.friendlyTeamBackgroundPanel.GetChild( "TeamBackground" )

	file.enemyPlayerList <- menu.GetChild( "ListEnemies" )
	file.friendlyPlayerList <- menu.GetChild( "ListFriendlies" )

	file.teamSlotBackgrounds <- GetElementsByClassnameForMenus( "LobbyTeamSlotBackgroundClass", uiGlobal.allMenus )
	file.teamSlotBackgroundsNeutral <- GetElementsByClassnameForMenus( "LobbyTeamSlotBackgroundNeutralClass", uiGlobal.allMenus )

	file.displayedMap <- null
	file.displayedMode <- null
	uiGlobal.cancelledPrivateMatch <- false

	file.nextMapNameLabel <- menu.GetChild( "NextMapName" )
	file.nextGameModeLabel <- menu.GetChild( "NextGameModeName" )
	file.starsLabelGamepad <- menu.GetChild( "StarsLabelGamepad" )
	file.starsLabelGamepad.EnableKeyBindingIcons()
	file.starsLabelKeyboard <- menu.GetChild( "StarsLabelKeyboard" )
	file.starsLabelKeyboard.EnableKeyBindingIcons()
	file.star1 <- menu.GetChild( "MapStar0" )
	file.star2 <- menu.GetChild( "MapStar1" )
	file.star3 <- menu.GetChild( "MapStar2" )
	file.winStreakHeader <- menu.GetChild( "WinStreakHeader" )
	file.lastTenLabel <- menu.GetChild( "LastTenLabel" )
	file.winStreakLabel <- menu.GetChild( "WinStreakLabel" )
	file.mapStarsPanel <- menu.GetChild( "MapStarsDetailsPanel" )
	file.starsButtonRegistered <- false

	file.dlcButton1 <- menu.GetChild( "DLCButton1" )
	file.dlcButton2 <- menu.GetChild( "DLCButton2" )
	file.dlcButton3 <- menu.GetChild( "DLCButton3" )
	AddEventHandlerToButton( menu, "DLCButton1", UIE_CLICK, DLCButton_Activate )
	AddEventHandlerToButton( menu, "DLCButton2", UIE_CLICK, DLCButton_Activate )
	AddEventHandlerToButton( menu, "DLCButton3", UIE_CLICK, DLCButton_Activate )

	file.haveShownDLCAnnounce <- false
}

function SetDLCHaveLabel( parentButton, haveDLC )
{
	local label = parentButton.GetChild( "InstalledLabel" )

	if ( haveDLC )
	{
		label.SetText( "#DLC_INSTALLED" )
		label.SetColor( 147, 147, 147, 255 )
	}
	else
	{
		label.SetText( "#DLC_NOT_INSTALLED" )
		label.SetColor( 255, 255, 255, 255 )
	}
}

function SetDLCBackground( parentButton, haveDLC, haveImage, dontHaveImage )
{
	local background = parentButton.GetChild( "Background" )

	if ( haveDLC )
		background.SetImage( haveImage )
	else
		background.SetImage( dontHaveImage )

	local label = parentButton.GetChild( "TitleLabel" )

	if ( haveDLC )
		label.SetColor( 255, 255, 255, 255 )
	else
		label.SetColor( 147, 147, 147, 255 )
}

function DLCButton_Activate( button )
{
	ShowDLCStore()
}

function SetupDLCPartyWarnings()
{
	local disabled1 = IsDLCMapGroupEnabledForLocalPlayer( 1 ) && !ServerHasDLCMapGroupEnabled( 1 )
	local disabled2 = IsDLCMapGroupEnabledForLocalPlayer( 2 ) && !ServerHasDLCMapGroupEnabled( 2 )
	local disabled3 = IsDLCMapGroupEnabledForLocalPlayer( 3 ) && !ServerHasDLCMapGroupEnabled( 3 )

	file.dlcButton1.GetChild( "PartyDisabledImage" ).SetVisible( disabled1 )
	file.dlcButton2.GetChild( "PartyDisabledImage" ).SetVisible( disabled2 )
	file.dlcButton3.GetChild( "PartyDisabledImage" ).SetVisible( disabled3 )

	file.dlcButton1.GetChild( "PartyDisabledLabel" ).SetVisible( disabled1 )
	file.dlcButton2.GetChild( "PartyDisabledLabel" ).SetVisible( disabled2 )
	file.dlcButton3.GetChild( "PartyDisabledLabel" ).SetVisible( disabled3 )
}

function SetupDLCPromoPrompt( button, enabled )
{
	local bg = button.GetChild( "PromoTextImage" )
	local tx = button.GetChild( "PromoTextLabel" )

	if ( enabled )
	{
		bg.SetVisible( true )
		tx.SetVisible( true )
		tx.SetText( "#dlc_promo_text" )
	}
	else
	{
		bg.SetVisible( false )
		tx.SetVisible( false )
	}
}

function SetupDLCPromoPrompts()
{
	local promoEnabledText = GetPlaylistVarOrUseValue( "at", "dlc_promo", "0" )
	local promoEnabled = (promoEnabledText == "1" )

	SetupDLCPromoPrompt( file.dlcButton1, (promoEnabled && !IsDLCMapGroupEnabledForLocalPlayer( 1 )) )
	SetupDLCPromoPrompt( file.dlcButton2, (promoEnabled && !IsDLCMapGroupEnabledForLocalPlayer( 2 )) )
	SetupDLCPromoPrompt( file.dlcButton3, (promoEnabled && !IsDLCMapGroupEnabledForLocalPlayer( 3 )) )
}

function SetDLCButtonsEnabled( doEnable )
{
	file.dlcButton1.SetVisible( doEnable )
	file.dlcButton1.SetEnabled( doEnable )
	file.dlcButton2.SetVisible( doEnable )
	file.dlcButton2.SetEnabled( doEnable )
	file.dlcButton3.SetVisible( doEnable )
	file.dlcButton3.SetEnabled( doEnable )
}

function SetupDLCButtons()
{
	local lobbyType = GetLobbyTypeScript()
	if ( (lobbyType == eLobbyType.MATCH) || (lobbyType == eLobbyType.PRIVATE_MATCH) )
	{
		SetDLCButtonsEnabled( false )
		return
	}

	SetDLCButtonsEnabled( true )

	local have1 = IsDLCMapGroupEnabledForLocalPlayer( 1 )
	SetDLCBackground( file.dlcButton1, have1, "../ui/menu/dlc_menu_grid/dlc_menu_grid_1_installed", "../ui/menu/dlc_menu_grid/dlc_menu_grid_1_not_installed" )
	SetDLCHaveLabel( file.dlcButton1, have1 )
	local tx1 = file.dlcButton1.GetChild( "TitleLabel" )
	tx1.SetText( "#DLC_TITLE_1" )

	local have2 = IsDLCMapGroupEnabledForLocalPlayer( 2 )
	SetDLCBackground( file.dlcButton2, have2, "../ui/menu/dlc_menu_grid/dlc_menu_grid_2_installed", "../ui/menu/dlc_menu_grid/dlc_menu_grid_2_not_installed" )
	SetDLCHaveLabel( file.dlcButton2, have2 )
	local tx2 = file.dlcButton2.GetChild( "TitleLabel" )
	tx2.SetText( "#DLC_TITLE_2" )

	local have3 = IsDLCMapGroupEnabledForLocalPlayer( 3 )
	SetDLCBackground( file.dlcButton3, have3, "../ui/menu/dlc_menu_grid/dlc_menu_grid_3_installed", "../ui/menu/dlc_menu_grid/dlc_menu_grid_3_not_installed" )
	SetDLCHaveLabel( file.dlcButton3, have3 )
	local tx3 = file.dlcButton3.GetChild( "TitleLabel" )
	tx3.SetText( "#DLC_TITLE_3" )

	SetupDLCPartyWarnings()
	SetupDLCPromoPrompts()
}

function MonitorPartyDLCWarnings()
{
	EndSignal( uiGlobal.signalDummy, "OnCloseLobbyMenu" )
	EndSignal( uiGlobal.signalDummy, "CleanupInGameMenus" )

	local lobbyType = null
	local lobbyTypePrev = null
	local serverHas = [ null, null, null ]
	local serverHasPrev = clone serverHas
	local localHas = [ null, null, null ]
	local localHasPrev = clone localHas

	while ( 1 )
	{
		local doUpdate = false
		for ( local i = 0; i < 3; i++ )
		{
			lobbyType = GetLobbyTypeScript()
			if ( lobbyType != lobbyTypePrev )
			{
				lobbyTypePrev = lobbyType
				doUpdate = true
			}

			serverHas[i] = ServerHasDLCMapGroupEnabled( i + 1 ) // 1-3
			if ( serverHas[i] != serverHasPrev[i] )
			{
				serverHasPrev[i] = serverHas[i]
				doUpdate = true
			}

			localHas[i] = IsDLCMapGroupEnabledForLocalPlayer( i + 1 ) // 1-3
			if ( localHas[i] != localHasPrev[i] )
			{
				localHasPrev[i] = localHas[i]
				doUpdate = true
			}
		}

		if ( doUpdate )
			SetupDLCButtons()

		WaitFrameOrUntilLevelLoaded()
	}
}

function LockedButtonGetFocusHandler( button )
{
	if ( !IsFullyConnected() )
		return

	Assert( "ref" in button.s )
	local menu = GetMenu( "LobbyMenu" )
	HandleLockedMenuItem( menu, button )
}
Globalize( LockedButtonGetFocusHandler )

function LockedButtonLoseFocusHandler( button )
{
	if ( !IsFullyConnected() )
		return

	Assert( "ref" in button.s )
	local menu = GetMenu( "LobbyMenu" )

	UpdateEditLoadoutButtons()
	UpdateGameSummaryButton()
	UpdateChallengesButton()
	UpdateRegenButton()
	UpdateLobbyAnnounceDialog()

	HandleLockedMenuItem( menu, button, true )
}
Globalize( LockedButtonLoseFocusHandler )

function OnOpenLobbyMenu()
{
	Assert( IsConnected() )

	PopulateNewUnlockTables()

	UpdateBlackMarketButtonText()
	UpdateEditBurnCardButtonText()
	UpdateEditLoadoutButtons()
	UpdateGameSummaryButton()
	UpdateChallengesButton()
	UpdateRegenButton()
	thread UpdateLobbyAnnounceDialog( true )

	InitLobbyRankedButton()
	UpdateLobbyRankedButton()

	Privatematch_map_Changed()
	Privatematch_mode_Changed()
	CoopLobbyMap_Changed()
	ListenHostUsernameHash_Changed()

	thread UpdateLobbyUI()
}

function SCB_RefreshLobby()
{
	if ( uiGlobal.activeMenu != GetMenu( "LobbyMenu" ) )
		return
	OnOpenLobbyMenu()
}
Globalize( SCB_RefreshLobby )

function OnCloseLobbyMenu()
{
	//RegisterButtonPressedCallback( BUTTON_SHOULDER_LEFT, ButtonCallback_RotateNodeCounterClockwise )
	SetStarInfo( null, null )
}

function EditPilotLoadoutList_Activate( button )
{
	if ( button.s.ref )
		ClearRefNew( button.s.ref )

	if ( !button.IsLocked() )
		AdvanceMenu( GetMenu( "EditPilotLoadoutsMenu" ) )
}
Globalize( EditPilotLoadoutList_Activate )

function EditTitanLoadoutList_Activate( button )
{
	if ( button.s.ref )
		ClearRefNew( button.s.ref )

	if ( !button.IsLocked() )
		AdvanceMenu( GetMenu( "EditTitanLoadoutsMenu" ) )
}
Globalize( EditTitanLoadoutList_Activate )

function ViewChallenges_Activate( button )
{
	ClearRefNew( button.s.ref )

	if ( !button.IsLocked() )
		AdvanceMenu( GetMenu( "ChallengesMenu" ) )
}
Globalize( ViewChallenges_Activate )

function ServerCallback_DoTraining()
{
	printt( "Server is asking us to do training" )
	UI_DoTraining()
}

function ServerCallback_EndTraining()
{
	printt( "Server is asking us to end training" )
	if ( uiGlobal.activeDialog )
		CloseDialog()
	LeaveMatchWithParty()
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

function LaunchTraining() {
	thread Threaded_LaunchTraining()
}

function LocalDialogChoice_Training_New()
{
	local buttonData = []
	buttonData.append( { name = "#TRAINING_FULL", func = Bind( LocalDialogChoice_RestartTraining ) } )
	buttonData.append( { name = "#TRAINING_PILOT_ONLY", func = Bind( LocalDialogChoice_TrainPilotOnly ) } )
	buttonData.append( { name = "#TRAINING_TITAN_ONLY", func = Bind( LocalDialogChoice_TrainTitanOnly ) } )
	buttonData.append( { name = "#CANCEL", func = null } )

	local header = "#TRAINING_PLAYAGAIN_PROMPT"
	local desc = "#TRAINING_PLAYAGAIN_PROMPT_DESC"

	local dialogData = {}
	dialogData.header <- header
	dialogData.detailsMessage <- desc
	dialogData.buttonData <- buttonData

	OpenChoiceDialog( dialogData, GetMenu( "TrainingDialog" ) )
}

function LocalDialogChoice_RestartTraining()
{
	SetPlayerTrainingResumeChoice( -1 )
	LaunchTraining()
}

function LocalDialogChoice_TrainPilotOnly()
{
	SetPlayerTrainingResumeChoice( -3 )
	LaunchTraining()
}

function LocalDialogChoice_TrainTitanOnly()
{
	SetPlayerTrainingResumeChoice( -4 )
	LaunchTraining()
}

function TrainingButton_ActivateOrStartDialog( button )
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

function LocalDialogChoice_Training_Custom()
{
	CloseDialog(false)

	local buttonData = []
	buttonData.append( { name = "#NPE_MODULE_MENU_DESC_1", func = Bind( function() { SetPlayerTrainingResumeChoice( 0 ); LaunchTraining() } ) } )
	buttonData.append( { name = "#NPE_MODULE_MENU_DESC_2", func = Bind( function() { SetPlayerTrainingResumeChoice( 1 ); LaunchTraining() } ) } )
	buttonData.append( { name = "#NPE_MODULE_MENU_DESC_3", func = Bind( function() { SetPlayerTrainingResumeChoice( 2 ); LaunchTraining() } ) } )
	buttonData.append( { name = "#NPE_MODULE_MENU_DESC_4", func = Bind( function() { SetPlayerTrainingResumeChoice( 3 ); LaunchTraining() } ) } )
	buttonData.append( { name = "#NPE_MODULE_MENU_DESC_5", func = Bind( function() { SetPlayerTrainingResumeChoice( 4 ); LaunchTraining() } ) } )
	buttonData.append( { name = "#NPE_MODULE_MENU_DESC_6", func = Bind( function() { SetPlayerTrainingResumeChoice( 5 ); LaunchTraining() } ) } )
	buttonData.append( { name = "#NPE_MODULE_MENU_DESC_7", func = Bind( function() { SetPlayerTrainingResumeChoice( 6 ); LaunchTraining() } ) } )
	buttonData.append( { name = "#NPE_MODULE_MENU_DESC_8", func = Bind( function() { SetPlayerTrainingResumeChoice( 7 ); LaunchTraining() } ) } )
	buttonData.append( { name = "#NPE_MODULE_MENU_DESC_9", func = Bind( function() { SetPlayerTrainingResumeChoice( 8 ); LaunchTraining() } ) } )
	buttonData.append( { name = "#NPE_MODULE_MENU_DESC_10", func = Bind( function() { SetPlayerTrainingResumeChoice( 9 ); LaunchTraining() } ) } )
	buttonData.append( { name = "#NPE_MODULE_MENU_DESC_11", func = Bind( function() { SetPlayerTrainingResumeChoice( 10 ); LaunchTraining() } ) } )
	buttonData.append( { name = "#NPE_MODULE_MENU_DESC_12", func = Bind( function() { SetPlayerTrainingResumeChoice( 11 ); LaunchTraining() } ) } )
	buttonData.append( { name = "#NPE_MODULE_MENU_DESC_13", func = Bind( function() { SetPlayerTrainingResumeChoice( 12 ); LaunchTraining() } ) } )
	buttonData.append( { name = "#NPE_MODULE_MENU_DESC_14", func = Bind( function() { SetPlayerTrainingResumeChoice( 13 ); LaunchTraining() } ) } )

	buttonData.append( { name = "#CANCEL", func = function() {} } )

	local header = "#TRAINING_PLAYAGAIN_PROMPT_ADV_TITLE"
	local desc = ""

	local dialogData = {}
	dialogData.header <- header
	dialogData.detailsMessage <- desc
	dialogData.buttonData <- buttonData

	OpenChoiceDialog( dialogData, GetMenu( "ChoiceDialog2" ) )
}

function GetTrainingNameForResumeChoice( resumeChoice )
{
	local textMappings = []
	textMappings.append( "#NPE_MODULE_MENU_DESC_1" )
	textMappings.append( "#NPE_MODULE_MENU_DESC_2" )
	textMappings.append( "#NPE_MODULE_MENU_DESC_3" )
	textMappings.append( "#NPE_MODULE_MENU_DESC_4" )
	textMappings.append( "#NPE_MODULE_MENU_DESC_5" )
	textMappings.append( "#NPE_MODULE_MENU_DESC_6" )
	textMappings.append( "#NPE_MODULE_MENU_DESC_7" )
	textMappings.append( "#NPE_MODULE_MENU_DESC_8" )
	textMappings.append( "#NPE_MODULE_MENU_DESC_9" )
	textMappings.append( "#NPE_MODULE_MENU_DESC_10" )
	textMappings.append( "#NPE_MODULE_MENU_DESC_11" )
	textMappings.append( "#NPE_MODULE_MENU_DESC_12" )
	textMappings.append( "#NPE_MODULE_MENU_DESC_13" )
	textMappings.append( "#NPE_MODULE_MENU_DESC_14" )

	Assert( resumeChoice >= 0 && resumeChoice < textMappings.len() )
	return textMappings[ resumeChoice ]
}

function UI_DoTraining()
{
	ShowTrainingConnectDialog()
	ClientCommand( "DoTraining" )
}

function DialogChoice_RestartTraining()
{
	SetPlayerTrainingResumeChoice( -1 )
	UI_DoTraining()
}

function DialogChoice_TrainPilotOnly()
{
	SetPlayerTrainingResumeChoice( -3 )
	UI_DoTraining()
}

function DialogChoice_TrainTitanOnly()
{
	SetPlayerTrainingResumeChoice( -4 )
	UI_DoTraining()
}

function RegenButton_Activate( button )
{
	if ( button.IsLocked() )
		return

	ClientCommand( "RegenMenuViewed" )
	UpdateRegenButton( true )

	local challengesRemaining = GetNumberRegenChallengesRemaining()
	if ( challengesRemaining > 0 )
	{
		local buttonData = []
		buttonData.append( { name = "#REGEN_DIALOG_VIEW_CHALLENGES", func = DialogChoice_Regen_ViewChallenges } )
		buttonData.append( { name = "#REGEN_DIALOG_CLOSE", func = null } )

		local footerData = []
		footerData.append( { label = "#A_BUTTON_SELECT" } )
		footerData.append( { label = "#B_BUTTON_CLOSE" } )

		local dialogData = {}
		dialogData.header <- [ "#REGEN_DIALOG_CHALLENGES_REMAINING_TITLE", challengesRemaining ]
		dialogData.detailsMessage <- [ "#REGEN_DIALOG_CHALLENGES_REMAINING", challengesRemaining ]
		dialogData.buttonData <- buttonData
		dialogData.footerData <- footerData

		OpenChoiceDialog( dialogData )
		return
	}

	Assert( CanGenUp() )
	AdvanceMenu( GetMenu( "Generation_Respawn" ) )
}
Globalize( RegenButton_Activate )

function DialogChoice_Regen_ViewChallenges()
{
	Assert( !( "goToRegenChallengeMenu" in uiGlobal ) )
	uiGlobal.goToRegenChallengeMenu <- true
	AdvanceMenu( GetMenu( "ChallengesMenu" ) )
}

function GameStartTime_Changed()
{
	UpdateGameStartTimeCounter()
}

function UpdateGameStartTimeCounter()
{
	if ( level.ui.gameStartTime == null )
		return

	foreach ( elem in file.searchTextElems )
		elem.SetText( "#STARTING_IN_LOBBY" )

	foreach ( elem in file.matchStartCountdownElems )
		elem.SetAutoText( "#HUDAUTOTEXT_SECONDS", HATT_GAME_COUNTDOWN_SECONDS, level.ui.gameStartTime )

	SmartGlass_StartCountdown( "lobby", level.ui.gameStartTime )

	HideMatchmakingStatusIcons( file.searchIconElems )
}

function UpdateDebugStatus()
{
	EndSignal( uiGlobal.signalDummy, "CleanupInGameMenus" )

	OnThreadEnd(
		function() : ()
		{
			foreach ( elem in file.MMDevStringElems )
				elem.Hide()
		}
	)

	foreach ( elem in file.MMDevStringElems )
		elem.Show()

	while ( 1 )
	{
		local strstr = GetLobbyDevString()
		foreach ( elem in file.MMDevStringElems )
			elem.SetText( strstr )

		WaitFrameOrUntilLevelLoaded()
	}
}

function UpdateMatchmakingStatus()
{
	EndSignal( uiGlobal.signalDummy, "CleanupInGameMenus" )

	OnThreadEnd(
		function() : ()
		{
			printt( "Hiding all matchmaking elems due to UpdateMatchmakingStatus thread ending" )

			HideMatchmakingStatusIcons( file.searchIconElems )

			foreach ( elem in file.searchTextElems )
				elem.Hide()

			foreach ( elem in file.matchStartCountdownElems )
				elem.Hide()
		}
	)

	foreach ( elem in file.searchTextElems )
		elem.Show()

	foreach ( elem in file.matchStartCountdownElems )
		elem.Show()

	while ( 1 )
	{
		if ( level.ui.gameStartTime != null )
		{
			if ( level.ui.gameStartTimerComplete )
			{
				foreach ( elem in file.searchTextElems )
					elem.SetText( GetMyTeamMatchmakingStatus(), GetMyTeamMatchmakingParam(1), GetMyTeamMatchmakingParam(2), GetMyTeamMatchmakingParam(3), GetMyTeamMatchmakingParam(4) )
			}
		}
		else if ( level.ui.gameStartTime == null )
		{
			SmartGlass_StopCountdown( "lobby" )

			foreach ( elem in file.matchStartCountdownElems )
			{
				elem.SetAutoText( "", HATT_NONE, 0 )
				elem.SetText( "" ) // Not sure why this is needed but text isn't cleared by the line above
			}

			if ( IsConnected() && GetLobbyTypeScript() == eLobbyType.MATCH )
			{
				ShowMatchmakingStatusIcons( file.searchIconElems )

				local matchmakingStatus = GetMyTeamMatchmakingStatus()
				if ( matchmakingStatus != "#MATCH_NOTHING" )
				{
					foreach ( elem in file.searchTextElems )
						elem.SetText( GetMyTeamMatchmakingStatus(), GetMyTeamMatchmakingParam(1), GetMyTeamMatchmakingParam(2), GetMyTeamMatchmakingParam(3), GetMyTeamMatchmakingParam(4) )
				}
				else
				{
					if ( IsCoopMatch() )
					{
						local maxPlayers = GetCurrentPlaylistVarInt( "max players", 12 )
						foreach ( elem in file.searchTextElems )
							elem.SetText( "#PRIVATE_MATCH_WAITING_FOR_PLAYERS", GetTeamSize( TEAM_IMC ) + GetTeamSize( TEAM_MILITIA ), maxPlayers )
					}
					else
					{
						foreach ( elem in file.searchTextElems )
							elem.SetText( "#HUD_WAITING_FOR_PLAYERS_BASIC" )
					}
				}
			}
			else if ( IsConnected() && GetLobbyTypeScript() == eLobbyType.PRIVATE_MATCH )
			{
				ShowMatchmakingStatusIcons( file.searchIconElems )

				local minPlayers = GetCurrentPlaylistVarInt( "min_players", 2 )
				local maxPlayers = GetCurrentPlaylistVarInt( "max players", 12 )

				if ( minPlayers > maxPlayers )
					minPlayers = maxPlayers

				// TODO: needs clamping?  What happens when maxPlayers == 5?
				local maxTeamSize = maxPlayers / 2

				foreach ( elem in file.searchTextElems )
				{
					if ( level.ui.privatematch_starting == ePrivateMatchStartState.READY )
						elem.SetText( "#PRIVATE_MATCH_WAITING_FOR_START" )
					else if ( GetTeamSize( TEAM_IMC ) + GetTeamSize( TEAM_MILITIA ) < minPlayers )
						elem.SetText( "#PRIVATE_MATCH_WAITING_FOR_PLAYERS", GetTeamSize( TEAM_IMC ) + GetTeamSize( TEAM_MILITIA ), minPlayers )
					else if ( GetTeamSize( TEAM_IMC ) > maxTeamSize || GetTeamSize( TEAM_MILITIA ) > maxTeamSize )
						elem.SetText( "#PRIVATE_MATCH_WAITING_FOR_BALANCE", GetTeamSize( TEAM_IMC ), GetTeamSize( TEAM_MILITIA ) )
					else if ( GetTeamSize( TEAM_IMC ) == 0 || GetTeamSize( TEAM_MILITIA ) == 0 )
						elem.SetText( "#PRIVATE_MATCH_WAITING_FOR_BALANCE", GetTeamSize( TEAM_IMC ), GetTeamSize( TEAM_MILITIA ) )
				}
			}
			else
			{
				foreach ( elem in file.searchTextElems )
					elem.SetText( "" )

				HideMatchmakingStatusIcons( file.searchIconElems )
			}
		}

		WaitFrameOrUntilLevelLoaded()
	}
}

function NextMapModeComboIndex_Changed()
{
	if ( IsPrivateMatch() )
		return
	if ( IsCoopMatch() )
	{
		UpdateFooterButtons()
		return
	}
	printt( "NextMapModeComboIndex_Changed(), level.ui.nextMapModeComboIndex =", level.ui.nextMapModeComboIndex )

	SetDisplayedMapByComboIndex( level.ui.nextMapModeComboIndex )
}

function CoopLobbyMap_Changed()
{
	if ( !IsCoopMatch() )
		return

	if ( level.ui.coopLobbyMap == null )
	{
		ClearDisplayedMapAndMode()
	}
	else
	{
		local mapName = GetPrivateMatchMapNameForEnum( level.ui.coopLobbyMap )
		SetDisplayedMapAndMode( mapName, "coop" )
	}
}

function ListenHostUsernameHash_Changed()
{
	if ( level.ui.listenHostUsernameHash == null )
		return

	UpdateFooterButtons()
}

function SetMapInfo( mapName )
{
	local menu = GetMenu( "LobbyMenu" )
	local nextMapImage = menu.GetChild( "NextMapImage" )
	local nextMapImageFrame = menu.GetChild( "NextMapImageFrame" )

	if ( mapName == null )
	{
		nextMapImage.Hide()
		nextMapImageFrame.Hide()
		file.nextMapNameLabel.Hide()
		return
	}

	local dlcGroup = GetDLCMapGroupForMap( mapName )
	if ( IsDLCMapGroupEnabledForLocalPlayer( dlcGroup )  )
		ClientMountVPK( mapName, true )

	SmartGlass_SetGameStateProperty( SMARTGLASS_PROP_NEXTLEVEL, mapName )

	local mapImage = "../ui/menu/lobby/lobby_image_" + mapName
	nextMapImage.SetImage( mapImage )
	nextMapImage.Show()

	nextMapImageFrame.Show()

	if ( GetModeNameForEnum(level.ui.privatematch_mode) == "campaign_carousel" || GetCinematicMode() ) {
		file.nextMapNameLabel.SetText( GetCampaignMapDisplayName( mapName ) )
	} else {
		file.nextMapNameLabel.SetText( GetMapDisplayName( mapName ) )
	}
	file.nextMapNameLabel.Show()
}

function SetModeInfo( gameMode )
{
	if ( gameMode == null )
	{
		file.nextGameModeLabel.Hide()
		return
	}

	SmartGlass_SetGlobalProperty( SMARTGLASS_PROP_GAMEMODE, gameMode )
	file.nextGameModeLabel.SetText( GAMETYPE_TEXT[ gameMode ] )
	file.nextGameModeLabel.Show()
}

function ShouldShowRankInfo( mapName, gameMode )
{
	if ( mapName == null )
		return false

	if ( gameMode == null )
		return false

	if ( IsPrivateMatch() && !IsDelta() )
		return false

	if ( !GameModeSupportsRankedPlay() )
		return false

	if( !PlaylistSupportsRankedPlay() )
		return false

	if ( !PlayerPlayingRanked() )
		return false

	return true
}

function SetStarInfo( mapName, gameMode )
{
	local shouldShowMapStars = true
	if ( mapName == null || gameMode == null || IsPrivateMatch() )
		shouldShowMapStars = false
	else if ( gameMode != null )
	{
		if ( !IsFullyConnected() || !PersistenceEnumValueIsValid( "gameModesWithStars", gameMode ) )
			shouldShowMapStars = false
	}

	if ( !shouldShowMapStars )
	{
		file.starsLabelGamepad.Hide()
		file.starsLabelKeyboard.Hide()
		file.star1.Hide()
		file.star2.Hide()
		file.star3.Hide()
		file.mapStarsPanel.Hide()

		if ( file.starsButtonRegistered )
		{
			DeregisterButtonPressedCallback( BUTTON_Y, ViewStarsButton_Activated )
			file.starsButtonRegistered = false
		}

		return
	}

	// Reset the background position to be slid in and update the star panel data
	uiGlobal.starsPanelVisible = false
	ChangeStarPanelState( 0, true )
	UpdateStarPanelData( file.mapStarsPanel, mapName, gameMode )

	file.starsLabelGamepad.Show()
	file.starsLabelKeyboard.Show()
	file.mapStarsPanel.Show()

	local menu = file.starsLabelGamepad.GetParent()
	UpdateSelectedMapStarData( menu, mapName, gameMode )

	if ( !file.starsButtonRegistered && !IsPrivateMatch() )
	{
		RegisterButtonPressedCallback( BUTTON_Y, ViewStarsButton_Activated )
		file.starsButtonRegistered = true
	}
}

function ViewStarsButton_Activated( button )
{
	if ( uiGlobal.activeMenu != GetMenu( "LobbyMenu" ) )
		return

	if ( level.ui.nextMapModeComboIndex == null )
		return
	local gameMode = GetCurrentPlaylistGamemodeByIndex( level.ui.nextMapModeComboIndex )
	if ( !IsFullyConnected() || !PersistenceEnumValueIsValid( "gameModesWithStars", gameMode ) )
		return

	EmitUISound( "EOGSummary.XPBreakdownPopup" )
	ChangeStarPanelState( !uiGlobal.starsPanelVisible )
	UpdateFooterButtons()
}

function ChangeStarPanelState( visible, instant = false )
{
	local background = file.mapStarsPanel.GetChild( "Background" )

	local duration = instant ? 0.0 : 0.25
	local basePos = background.GetBasePos()
	local xOffset = visible ? 0 : file.mapStarsPanel.GetWidth()
	uiGlobal.starsPanelVisible = visible

	if ( instant )
		background.SetPos( basePos[0] + xOffset, basePos[1] )
	else
		background.MoveOverTime( basePos[0] + xOffset, basePos[1], duration, INTERPOLATOR_ACCEL )

	// Hide or show other map info
	local labelsAlpha = visible ? 0 : 255

	file.nextGameModeLabel.FadeOverTime( labelsAlpha, duration, INTERPOLATOR_ACCEL )
	file.starsLabelGamepad.FadeOverTime( labelsAlpha, duration, INTERPOLATOR_ACCEL )
	file.starsLabelKeyboard.FadeOverTime( labelsAlpha, duration, INTERPOLATOR_ACCEL )
	file.star1.FadeOverTime( labelsAlpha, duration, INTERPOLATOR_ACCEL )
	file.star2.FadeOverTime( labelsAlpha, duration, INTERPOLATOR_ACCEL )
	file.star3.FadeOverTime( labelsAlpha, duration, INTERPOLATOR_ACCEL )
	file.winStreakHeader.FadeOverTime( labelsAlpha, duration, INTERPOLATOR_ACCEL )
	file.lastTenLabel.FadeOverTime( labelsAlpha, duration, INTERPOLATOR_ACCEL )
	file.winStreakLabel.FadeOverTime( labelsAlpha, duration, INTERPOLATOR_ACCEL )
}

function SetStreakInfo( bShow )
{
	if ( !bShow )
	{
		file.winStreakHeader.Hide()
		file.lastTenLabel.Hide()
		file.winStreakLabel.Hide()
		return
	}

	// Record for last 10
	local winCount = 0
	local lossCount = 0
	local drawCount = 0
	local historyCount = min( GetPersistentVar( "winLossHistorySize" ), NUM_GAMES_TRACK_WINLOSS_HISTORY )
	for ( local i = 0 ; i < historyCount ; i++ )
	{
		local value = GetPersistentVar( "winLossHistory[" + i + "]" )
		if ( value == 1 )
			winCount++
		else if ( value == -1 )
			lossCount++
		else if ( value == 0 )
			drawCount++
	}

	file.winStreakHeader.Show()

	if ( drawCount > 0 )
		file.lastTenLabel.SetText( "#WIN_STREAK_LAST_10_WLD", winCount, lossCount, drawCount )
	else
		file.lastTenLabel.SetText( "#WIN_STREAK_LAST_10_WL", winCount, lossCount )
	file.lastTenLabel.Show()

	// Current streak
	local streak = GetPersistentVar( "winStreak" )
	local winStreakIsDraws = GetPersistentVar( "winStreakIsDraws" )
	if ( streak > 0 && winStreakIsDraws )
		file.winStreakLabel.SetText( "#WIN_STREAK_RUNNING_D", streak )
	else if ( streak > 0 )
		file.winStreakLabel.SetText( "#WIN_STREAK_RUNNING_W", streak )
	else
		file.winStreakLabel.SetText( "#WIN_STREAK_RUNNING_L", abs(streak) )
	if ( historyCount > 0 )
		file.winStreakLabel.Show()
	else
		file.winStreakLabel.Hide()
}


function ClearDisplayedMapAndMode()
{
	file.displayedMap = null
	file.displayedMode = null

	SetMapInfo( null )
	SetModeInfo( null )
	SetStarInfo( null, null )
	SetStreakInfo( false )
	UpdateFooterButtons()
}

function SetDisplayedMapAndMode( mapName, gameMode )
{
	file.displayedMap = mapName
	file.displayedMode = gameMode

	SetMapInfo( mapName )
	SetModeInfo( gameMode )
	SetStarInfo( mapName, gameMode )

	local bShow = true
	if ( gameMode == "coop" )
		bShow = false

	SetStreakInfo( bShow )
	UpdateFooterButtons()
}


function SetDisplayedMapByComboIndex( index )
{
	if ( index == null )
	{
		ClearDisplayedMapAndMode()
		return
	}

	local mapName = GetCurrentPlaylistMapByIndex( index )
	local gameMode = GetCurrentPlaylistGamemodeByIndex( index )
	SetDisplayedMapAndMode( mapName, gameMode )
}


function GetPrivateMatchMapNameForEnum( enumVal )
{
	foreach ( name, id in getconsttable().ePrivateMatchMaps )
	{
		if ( id == enumVal )
			return name
	}

	return null
}
Globalize( GetPrivateMatchMapNameForEnum )

function Privatematch_map_Changed()
{
	if ( !IsPrivateMatch() )
		return
	if ( GetLobbyTypeScript() != eLobbyType.PRIVATE_MATCH )
		return
	if ( !IsLobby() )
		return

	local mapName = GetPrivateMatchMapNameForEnum( level.ui.privatematch_map )
	SetMapInfo( mapName )
}


function GetModeNameForEnum( enumVal )
{
	foreach ( name, id in getconsttable().ePrivateMatchModes )
	{
		if ( id == enumVal )
			return name
	}

	return null
}
Globalize( GetModeNameForEnum )

function Privatematch_mode_Changed()
{
	if ( !IsPrivateMatch() )
		return
	if ( GetLobbyTypeScript() != eLobbyType.PRIVATE_MATCH )
		return
	if ( !IsLobby() )
		return

	local modeName = GetModeNameForEnum( level.ui.privatematch_mode )
	SetModeInfo( modeName )

	UpdatePrivateMatchButtons()
}


function Privatematch_starting_Changed()
{
	if ( !IsPrivateMatch() )
		return
	if ( GetLobbyTypeScript() != eLobbyType.PRIVATE_MATCH )
		return
	if ( !IsLobby() )
		return

	UpdatePrivateMatchButtons()
	UpdateFooterButtons()
}


function UpdatePrivateMatchButtons()
{
	local menu = GetMenu( "LobbyMenu" )
	local startMatchButton = menu.GetChild( "StartMatchButton" )
	local mapsButton = menu.GetChild( "MapsButton" )
	local modesButton = menu.GetChild( "ModesButton" )
	local settingsButton = menu.GetChild( "SettingsButton" )
        if (GetConVarString("host_map") != "mp_lobby.bsp") {
		startMatchButton.SetLocked( true )
		mapsButton.SetLocked( true )
		modesButton.SetLocked( true )
		settingsButton.SetLocked( true )
		mapsButton.SetEnabled( false )
		modesButton.SetEnabled( false )
		settingsButton.SetEnabled( false )
                startMatchButton.SetEnabled( false)
	}
else {
    startMatchButton.SetLocked( false )
    mapsButton.SetLocked( false )
    modesButton.SetLocked( false )
    settingsButton.SetLocked( false )
    mapsButton.SetEnabled( true )
    modesButton.SetEnabled( true )
    settingsButton.SetEnabled( true )
    startMatchButton.SetEnabled( true )
}

	if ( level.ui.privatematch_starting == ePrivateMatchStartState.STARTING )
	{
		startMatchButton.SetText( "#STOP_MATCH" )
		mapsButton.SetEnabled( false )
		modesButton.SetEnabled( false )
		mapsButton.SetEnabled( false )
		settingsButton.SetEnabled( false )
	}
	else
	{
		startMatchButton.SetText( "#START_MATCH" )
		mapsButton.SetEnabled( true )
		modesButton.SetEnabled( true )
		mapsButton.SetEnabled( true )
		settingsButton.SetEnabled( true )
	}

	if ( level.ui.privatematch_starting == ePrivateMatchStartState.NOT_READY )
		startMatchButton.SetLocked( true )
	else
		startMatchButton.SetLocked( false )

}

function HideMatchmakingStatusIcons( elements )
{
	foreach ( element in elements )
		element.Hide()
}

function ShowMatchmakingStatusIcons( elements )
{
	foreach ( element in elements )
		element.Show()
}

function UpdateGameSummaryButton( menu = "LobbyMenu" )
{
	local button = GetElementsByClassname( GetMenu( menu ), "BtnGameSummaryClass" )[0]
	if ( GetXP() > 0 )
	{
		button.SetEnabled( true )
		button.Show()
	}
	else
	{
		button.SetEnabled( false )
		button.Hide()
	}
}

function UpdateChallengesButton( menu = "LobbyMenu" )
{
	local menu = GetMenu( menu )
	local button = menu.GetChild( "BtnChallenges" )

	button.s.ref <- "challenges"
	local isLocked = IsItemLocked( button.s.ref )
	button.SetLocked( isLocked )
	button.SetText( "#MENU_CHALLENGES" )

	if ( !isLocked )
	{
		local newChallenges = HasAnyNewItem( "challenges" )

		if ( GetPersistentVar( "newRegenChallenges" ) )
			newChallenges = true

		if ( GetPersistentVar( "newDailyChallenges" ) )
		{
			button.SetText( "#MENU_CHALLENGES_NEW_DAILIES" )
			if ( !newChallenges )
				newChallenges = true
		}

		button.SetNew( newChallenges )
	}
	else
	{
		button.SetNew( false )
	}
}

function UpdateRegenButton( forceClearNew = false, menu = "LobbyMenu" )
{
	local menu = GetMenu( menu )
	local button = menu.GetChild( "BtnRegen" )

	if ( CanGenUp() && GetLobbyTypeScript() != eLobbyType.PRIVATE_MATCH )
	{
		button.Show()
		button.SetEnabled( true )
		if ( forceClearNew )
			button.SetNew( false )
		else
			button.SetNew( GetPersistentVar( "regenShowNew" ) )
	}
	else
	{
		button.Hide()
		button.SetEnabled( false )
		button.SetNew( false )
	}
}

function UpdateLobbyAnnounceDialog( bRetry = false )
{
	if ( bRetry )
	{
		local endTime = Time() + 1.0
		while( Time() <= endTime )
		{
			if ( IsFullyConnected() && (GetPersistentVar( "ranked.showSeasonEndDialog" ) == true || GetPersistentVar( "playlistAnnouncementSeen" ) == false) )
				break
			wait 0.05
		}
	}

	if ( !IsFullyConnected() )
		return

	if ( uiGlobal.activeMenu == null || uiGlobal.activeMenu.GetName() != "LobbyMenu" )
		return

	if ( uiGlobal.activeDialog )
		return

	if ( ShouldShowEOGSummary() )
		return

	if ( ShouldShowDLCAnnounceDialog() )
		ShowDLCAnnounceDialog();
	else if ( ShouldShowSeasonEndDialog() )
		ShowSeasonEndDialog()
	// else if ( GetPersistentVar( "playlistAnnouncementSeen" ) == false  )
	// 	ShowPlaylistAnnounceDialog()
}

function ShouldShowSeasonEndDialog()
{
	if( !PlayerAcceptedRankInvite() )
		return false

	if ( GetPersistentVar( "ranked.showSeasonEndDialog" ) == false )
		return false

	return true
}

function ShowSeasonEndDialog()
{
	local rank = GetPersistentVar( "ranked.seasonHistory[0].rank" )

	local season = GetPersistentVar( "ranked.seasonHistory[0].season" )
	if ( season < 1 )
		season = "#BETA"
	local currentSeason = GetRankedSeason()
	if ( currentSeason < 1 )
		currentSeason = "#BETA"
	local currentRank = GetPlayerRank()

	local dialog = GetMenu( "RankedSeasonEndDialog" )

	dialog.GetChild( "LblDetails" ).SetText( "#SEASON_END_DIALOG_MESSAGE_PART1", season )
	dialog.GetChild( "RankIcon" ).SetImage( GetRankImage( rank ) )
	dialog.GetChild( "Division" ).SetText( GetDivisionName( rank ) )
	dialog.GetChild( "Tier" ).SetText( GetTierName( rank ) )
	dialog.GetChild( "LblSeasonHeader" ).SetText( "#RANKED_CURRENT_SEASON_NUMBER", currentSeason )
	dialog.GetChild( "LblSeasonDetails" ).SetText( "#SEASON_END_DIALOG_MESSAGE_PART2", currentSeason )

	dialog.GetChild( "PlacementRankIcon" ).SetImage( GetRankImage( currentRank ) )
	dialog.GetChild( "PlacementDivision" ).SetText( GetDivisionName( currentRank ) )
	dialog.GetChild( "PlacementTier" ).SetText( GetTierName( currentRank ) )

	uiGlobal.preDialogFocus = dialog.GetChild( "BtnConfirm_Continue" )

	OpenDialog( dialog, "#RANKED_CURRENT_SEASON_CONGRATS", "BtnConfirmRegen0", null )

	if ( IsConnected() )
		ClientCommand( "SeasonEndDialogClosed" )
}

function ShowPlaylistAnnounceDialog()
{
	local dialog = GetMenu( "PlaylistAnnounceDialog" )

	dialog.GetChild( "Header1" ).SetText( "#PLAYLIST_ANNOUNCEMENT_HEADER1" )
	dialog.GetChild( "Header2" ).SetText( "#PLAYLIST_ANNOUNCEMENT_HEADER2" )
	dialog.GetChild( "Description" ).SetText( "#PLAYLIST_ANNOUNCEMENT_DESC" )

	OpenDialog( dialog, null, null, null, 1 )

	if ( IsConnected() )
		ClientCommand( "SetPlaylistAnnouncementSeen" )
}


function ShouldShowDLCAnnounceDialog()
{
	if ( file.haveShownDLCAnnounce )
		return false;

	if ( !IsDLCMapGroupEnabledForLocalPlayer( 1 ) )
		return true;
	if ( !IsDLCMapGroupEnabledForLocalPlayer( 2 ) )
		return true;
	if ( !IsDLCMapGroupEnabledForLocalPlayer( 3 ) )
		return true;

	return false;
}

function ShowDLCAnnounceDialog()
{
	local dialog = GetMenu( "PlaylistAnnounceDialog" )

	dialog.GetChild( "Header1" ).SetText( "#dlc_popup_header1" )
	dialog.GetChild( "Header2" ).SetText( "#dlc_popup_header2" )
	dialog.GetChild( "Description" ).SetText( "#dlc_popup_desc" )

	OpenDialog( dialog, null, null, null, 1 )

	file.haveShownDLCAnnounce = true;
}

function UpdateEditLoadoutButtons( menu = "LobbyMenu" )
{
	local menu = GetMenu( menu )
	local buttons

	buttons = GetElementsByClassname( menu, "EditPilotLoadoutsButtonClass" )
	foreach( button in buttons )
	{
		button.SetLocked( false )
		if ( IsItemLocked( "edit_pilots" ) )
		{
			button.s.ref <- null
			button.SetNew( HasAnyNewItem( "pilot_preset_loadout_1" ) || HasAnyNewItem( "pilot_preset_loadout_2" ) || HasAnyNewItem( "pilot_preset_loadout_3" ) )
		}
		else
		{
			button.s.ref <- "edit_pilots"
			button.SetNew( HasAnyNewItem( "edit_pilots" ) )
		}
	}

	buttons = GetElementsByClassname( menu, "EditTitanLoadoutsButtonClass" )
	foreach( button in buttons )
	{
		button.SetLocked( false )
		if ( IsItemLocked( "edit_titans" ) )
		{
			button.s.ref <- null
			button.SetNew( HasAnyNewItem( "titan_preset_loadout_1" ) || HasAnyNewItem( "titan_preset_loadout_2" ) || HasAnyNewItem( "titan_preset_loadout_3" ) )
		}
		else
		{
			button.s.ref <- "edit_titans"
			button.SetNew( HasAnyNewItem( "edit_titans" ) )
		}
	}
}

function GetLobbyTypeScript()
{
	if ( GetLobbyType() == "game" )
	{
		if ( IsPrivateMatch() )
			return eLobbyType.PRIVATE_MATCH
		else
			return eLobbyType.MATCH
	}
	else
	{
		if ( !IsDelta() )
		{
			if ( AmIPartyLeader() )
			{
				if ( IsPlayerAlone() )
					return eLobbyType.SOLO
				else
					return eLobbyType.PARTY_LEADER
			}
			else
			{
				return eLobbyType.PARTY_MEMBER
			}
		}
		else
			return eLobbyType.SOLO
	}
}

function UpdateLobbyTitle()
{
	EndSignal( uiGlobal.signalDummy, "OnCloseLobbyMenu" )
	EndSignal( uiGlobal.signalDummy, "CleanupInGameMenus" )

	local menu = GetMenu( "LobbyMenu" )
	local elements = GetElementsByClassname( menu, "LobbyTitleClass" )
	local text
	local lastText

	while ( 1 )
	{
		if ( GetLobbyTypeScript() == eLobbyType.MATCH )
			text = GetCurrentPlaylistVar( "lobbytitle" )
		else if ( GetLobbyTypeScript() == eLobbyType.PRIVATE_MATCH )
			text = "#PRIVATE_MATCH"
		else
			text = "#PRIVATE_LOBBY"

		if ( text != lastText )
		{
			foreach ( element in elements )
				element.SetText( text )
		}

		lastText = text

		WaitFrameOrUntilLevelLoaded()
	}
}

function BigPlayButton1_Activate( button )
{
	local handlerFunc = AdvanceMenuEventHandler( GetMenu( "ServerBrowserMenu" ) )
	handlerFunc( button )
}

function CoopMatchButton_Activate( button )
{
	local handlerFunc = AdvanceMenuEventHandler( GetMenu( "CoopPartyMenu" ) )
	handlerFunc( button )
}
Globalize( CoopMatchButton_Activate )


// Handles turning on/off buttons when we switch lobby types
// Also, Any button we disable needs to set a new focus if they are focused when we disable them
function UpdateLobbyTypeButtons( menu, type )
{
	local bigPlayButton1 = menu.GetChild( "BigPlayButton1" )
	local CoopMatchButton = menu.GetChild( "CoopMatchButton" )
	local privateMatchButton = menu.GetChild( "PrivateMatchButton" )
	local startMatchButton = menu.GetChild( "StartMatchButton" )
	local mapsButton = menu.GetChild( "MapsButton" )
	local modesButton = menu.GetChild( "ModesButton" )
	local settingsButton = menu.GetChild( "SettingsButton" )
	local trainingButton = menu.GetChild( "TrainingButton" )
	local statsButton = menu.GetChild( "BtnStats" )
	local challengesButton = menu.GetChild( "BtnChallenges" )
	local regenButton = menu.GetChild( "BtnRegen" )
	local rankedButton = menu.GetChild( "RankedButton" )
	local editPilotLoadoutsButton = menu.GetChild( "BtnEditPilotLoadouts" ) // Not in lobbyTypeButtons, because we never need to disable, just focus


	local lobbyTypeButtons = [ bigPlayButton1, privateMatchButton, startMatchButton, mapsButton, modesButton, settingsButton, trainingButton, statsButton, challengesButton, regenButton, rankedButton ]

	local enableList = {}
	enableList[eLobbyType.SOLO] <- [ bigPlayButton1, privateMatchButton, trainingButton, statsButton, challengesButton, regenButton, rankedButton ]
	enableList[eLobbyType.PARTY_LEADER] <- [ bigPlayButton1, privateMatchButton, statsButton, challengesButton, regenButton, rankedButton ]
	enableList[eLobbyType.MATCH] <- [ editPilotLoadoutsButton, statsButton, challengesButton, regenButton, rankedButton ]
	enableList[eLobbyType.PARTY_MEMBER] <- [ editPilotLoadoutsButton, statsButton, challengesButton, regenButton, rankedButton ]
	enableList[eLobbyType.PRIVATE_MATCH] <- [ editPilotLoadoutsButton, startMatchButton, mapsButton, modesButton, settingsButton ]

	local disableList = []

	if ( uiGlobal.activeDialog == GetMenu( "TrainingDialog" ) )
		CloseDialog( true )

	local partySize = GetPartyMembers().len()
	foreach ( button in lobbyTypeButtons )
	{
		if ( ArrayContains( enableList[type], button ) )
		{
			if ( button == regenButton )
				UpdateRegenButton()
			else
				EnableButton( button )

			if ( partySize > 4 )
			{
				if ( (button == CoopMatchButton) )
					button.SetEnabled( false )
			}
		}
		else
		{
			disableList.append( button )
		}
	}

	foreach ( button in disableList )
	{
		if ( button.IsFocused() )
			enableList[type][0].SetFocused()

		DisableButton( button )
	}

	if ( IsPrivateMatch() )
		UpdatePrivateMatchButtons()

	// Hide black market if in private lobby, show if not
	UpdateBlackMarketButtonText()

	UpdateLobbyRankedButton()
}

function EnableButton( button )
{
	//printt( "Enabling:", button.GetName() )

	button.SetEnabled( true )
	button.Show()
}

function DisableButton( button )
{
	//printt( "Disabling:", button.GetName() )

	button.SetEnabled( false )
	button.Hide()
}

function UpdateLobbyUI()
{
	if ( uiGlobal.updatingLobbyUI )
		return
	uiGlobal.updatingLobbyUI = true

	thread UpdateLobbyType()
	thread UpdateMatchmakingStatus()
	thread UpdateDebugStatus()
	thread UpdateLobbyTitle()
	thread MonitorTeamChange()
	thread MonitorPlaylistChange()
	thread MonitorPartyDLCWarnings()

	if ( Durango_IsDurango() )
		thread EnableButtonsOnInstallComplete()

	WaitSignal( uiGlobal.signalDummy, "CleanupInGameMenus" )
	uiGlobal.updatingLobbyUI = false
}

function EnableButtonsOnInstallComplete()
{
	EndSignal( uiGlobal.signalDummy, "CleanupInGameMenus" )

	while( !uiGlobal.installComplete )
		wait 0

	UpdateLobbyTypeButtons( GetMenu( "LobbyMenu" ), GetLobbyTypeScript() )
}

function UpdateLobbyType()
{
	EndSignal( uiGlobal.signalDummy, "CleanupInGameMenus" )

	local menu = GetMenu( "LobbyMenu" )
	local rankedMenu = GetMenu( "RankedPlayMenu" )
	local lobbyType
	local lastType
	local partySize
	local lastPartySize
	local debugArray = [ "SOLO", "PARTY_LEADER", "PARTY_MEMBER", "MATCH", "PRIVATE_MATCH" ] // Must match enum

	WaitFrameOrUntilLevelLoaded()

	while ( 1 )
	{
		lobbyType = GetLobbyTypeScript()
		partySize = GetPartyMembers().len()

		if ( IsConnected() && ((lobbyType != lastType) || (partySize != lastPartySize))  )
		{
			if ( lastType == null )
				printt( "Lobby lobbyType changing from:", lastType, "to:", debugArray[lobbyType] )
			else
				printt( "Lobby lobbyType changing from:", debugArray[lastType], "to:", debugArray[lobbyType] )

			if ( lobbyType != lastType)
				ClearDisplayedMapAndMode()
			CoopLobbyMap_Changed()
			if ( menu == GetMenu( "CoopPartyMenu" ) )
				UpdateCoopLobbyButtons( menu, lobbyType )
			UpdateMatchLobbyBackgroundSelection( lobbyType )
			UpdateLobbyTypeButtons( menu, lobbyType )
			UpdateSmartGlassLobbyState( lobbyType )
			UpdateEditBurnCardButtonText()

			local animation = null

			switch ( lobbyType )
			{
				case eLobbyType.SOLO:
					animation = "SoloLobby"
					break

				case eLobbyType.PARTY_LEADER:
					animation = "PartyLeaderLobby"
					break

				case eLobbyType.PARTY_MEMBER:
					animation = "PartyMemberLobby"
					break

				case eLobbyType.MATCH:
					animation = "MatchLobby"
					break

				case eLobbyType.PRIVATE_MATCH:
					animation = "PrivateMatchLobby"
					break
			}

			if ( animation != null )
			{
				menu.RunAnimationScript( animation )
				rankedMenu.RunAnimationScript( animation )
			}

			// Force the animation scripts (which have zero duration) to complete before anything can cancel them.
			ForceUpdateHUDAnimations()

			UpdateTeamInfo( menu, GetTeam() )

			lastType = lobbyType
			lastPartySize = partySize
		}

		WaitFrameOrUntilLevelLoaded()
	}
}

function MonitorTeamChange()
{
	EndSignal( uiGlobal.signalDummy, "CleanupInGameMenus" )

	local myTeam
	local lastMyTeam = 0
	local showBalanced
	local lastShowBalanced

	while ( 1 )
	{
		myTeam = GetTeam()
		showBalanced = GetLobbyTeamsShowAsBalanced()

		if ( (myTeam != lastMyTeam) || (showBalanced != lastShowBalanced) || IsPrivateMatch() )
		{
			UpdateTeamInfo( GetMenu( "LobbyMenu" ), myTeam )
			UpdateTeamInfo( GetMenu( "RankedPlayMenu" ), myTeam )

			lastMyTeam = myTeam
			lastShowBalanced = showBalanced
		}

		WaitFrameOrUntilLevelLoaded()
	}
}

function UpdateTeamInfo( menu, myTeam )
{
	local backgroundElements = GetElementsByClassname( menu, "BackgroundImageClass" )
	local background = GetLobbyBackgroundImage()

	local maxPlayers = GetCurrentPlaylistVarInt( "max players", 12 )
	local maxTeams = GetCurrentPlaylistVarInt( "max teams", 2 )
	if ( maxTeams <= 0 )
		maxTeams = 2
	local maxTeamSize = (maxPlayers / maxTeams)

	local show8v8 = false
	if ( maxTeamSize > 6 && GetLobbyTypeScript() == eLobbyType.MATCH )
		show8v8 = true

	if ( GetLobbyTypeScript() != eLobbyType.MATCH && GetLobbyTypeScript() != eLobbyType.PRIVATE_MATCH )
	{
		if ( menu == GetMenu( "CoopPartyMenu" ) || menu == GetMenu( "CoopPartyCustomMenu" ) )
			maxTeamSize = 4
		else
			maxTeamSize = 6
	}

	if ( maxTeams == 1 )
		file.enemyTeamBackground.Hide()
	else
		file.enemyTeamBackground.Show()

	if ( show8v8 )
	{
		file.friendlyTeamBackground.SetColor( 0, 0, 0, 255 )
		file.enemyTeamBackground.SetColor( 0, 0, 0, 255 )
		file.enemyPlayerList.SetY( ContentScaledY( 0 ) )
		file.friendlyPlayerList.SetY( ContentScaledY( 0 ) )
	}
	else
	{
		file.friendlyTeamBackground.SetColor( 255, 255, 255, 255 )
		file.enemyTeamBackground.SetColor( 255, 255, 255, 255 )
		file.enemyPlayerList.SetY( file.enemyPlayerList.GetBaseY() )
		file.friendlyPlayerList.SetY( file.enemyPlayerList.GetBaseY() )
	}

	foreach ( element in backgroundElements )
	{
		element.SetImage( background )
		element.Show()
	}

	local showAsBalanced = (GetLobbyTeamsShowAsBalanced() && !IsCoopMatch())
	foreach ( elem in file.teamSlotBackgrounds )
	{
		local slotIDRaw = elem.GetScriptID().tointeger()
		local slotID = slotIDRaw & ~0xF0
		local isEnemy = (slotIDRaw & 0xF0) ? true : false
		local hideEnemy = (isEnemy && (maxTeams == 1))

		if ( showAsBalanced && (slotID < maxTeamSize) && !hideEnemy )
			elem.Show()
		else
			elem.Hide()

		if ( show8v8 && slotID == 0 )
			elem.SetY( ContentScaledY( 0 ) )
		else if ( slotID == 0 )
			elem.SetY( elem.GetBaseY() )
	}
	foreach ( elem in file.teamSlotBackgroundsNeutral )
	{
		local slotIDRaw = elem.GetScriptID().tointeger()
		local slotID = slotIDRaw & ~0xF0
		local isEnemy = (slotIDRaw & 0xF0) ? true : false
		local hideEnemy = (isEnemy && (maxTeams == 1))

		if ( !showAsBalanced && (slotID < maxTeamSize) && !hideEnemy )
			elem.Show()
		else
			elem.Hide()

		if ( show8v8 && slotID == 0 )
			elem.SetY( ContentScaledY( 0 ) )
		else if ( slotID == 0 )
			elem.SetY( elem.GetBaseY() )
	}

	local myTeamImage = GetLobbyTeamImage( myTeam )
	foreach ( elem in file.myTeamLogoElems )
	{
		if ( myTeamImage && !show8v8 )
		{
			elem.SetImage( myTeamImage )
			elem.Show()
		}
		else
			elem.Hide()
	}

	local enemyTeam = GetEnemyTeam( myTeam )
	local enemyTeamImage = GetLobbyTeamImage( enemyTeam )
	foreach ( elem in file.enemyTeamLogoElems )
	{
		if ( enemyTeamImage && !show8v8 && (maxTeams > 1) )
		{
			elem.SetImage( enemyTeamImage )
			elem.Show()
		}
		else
			elem.Hide()
	}

	local myTeamName = GetLobbyTeamName( myTeam )
	foreach ( elem in file.myTeamNameElems )
	{
		if ( myTeamName && !show8v8 )
		{
			if ( IsPrivateMatch() && GetTeamSize( myTeam ) > maxTeamSize )
				elem.SetText( "#PRIVATE_MATCH_TEAM", myTeamName, GetTeamSize( myTeam ), maxTeamSize )
			else
				elem.SetText( myTeamName )
		}
		else
		{
			elem.SetText( "" )
		}
	}

	local enemyTeamName = GetLobbyTeamName( enemyTeam )
	foreach ( elem in file.enemyTeamNameElems )
	{
		if ( enemyTeamName && !show8v8 && (maxTeams > 1) )
		{
			if ( IsPrivateMatch() && GetTeamSize( enemyTeam ) > maxTeamSize )
				elem.SetText( "#PRIVATE_MATCH_TEAM", enemyTeamName, GetTeamSize( enemyTeam ), maxTeamSize )
			else
				elem.SetText( enemyTeamName )
		}
		else
		{
			elem.SetText( "" )
		}
	}
}

function UpdateSmartGlassLobbyState( type )
{
	local smartGlassGameType = GetCinematicMode() ? "campaign" : "classic"
	if ( IsPrivateMatch() )
		smartGlassGameType = "private"
	SmartGlass_SetGlobalProperty( SMARTGLASS_PROP_GAMETYPE, smartGlassGameType )

	local state = null
	switch( type )
	{
		case eLobbyType.SOLO:
		case eLobbyType.PARTY_LEADER:
		case eLobbyType.PARTY_MEMBER:
			SmartGlass_SetGameState( "PartyLobby" )
			SmartGlass_SetGlobalProperty( SMARTGLASS_PROP_PLAYLIST, "" )
			return

		case eLobbyType.MATCH:
			SmartGlass_SetGameState( "Lobby" )
			SmartGlass_SetGlobalProperty( SMARTGLASS_PROP_PLAYLIST, GetCurrentPlaylistVar( "name" ) )
			return

		 // TODO: Needs update from Chad for private match
		case eLobbyType.PRIVATE_MATCH:
			SmartGlass_SetGameState( "PrivateMatch" )
			SmartGlass_SetGlobalProperty( SMARTGLASS_PROP_PLAYLIST, GetCurrentPlaylistVar( "name" ) )
			return

		default:
			Assert(0, "Smartglass: Invalid lobby type" )
			return
	}
}

function UpdateLobbyBadRepPresentMessage()
{
	local menu = GetMenu( "LobbyMenu" )
	local message = menu.GetChild( "LobbyBadRepPresentMessage" )

	if ( level.ui.badRepPresent )
	{
		if ( !Durango_IsDurango() )
			message.SetText( "#ASTERISK_FAIRFIGHT_CHEATER" )
		else
			message.SetText( "#ASTERISK_BAD_REPUTATION" )

		message.Show()
	}
	else
	{
		message.Hide()
	}
}

function OnMapsButton_Activate( button )
{
	if ( level.ui.privatematch_starting == ePrivateMatchStartState.STARTING )
		return

	AdvanceMenu( GetMenu( "MapsMenu" ) )
}

function OnModesButton_Activate( button )
{
	if ( level.ui.privatematch_starting == ePrivateMatchStartState.STARTING )
		return

	AdvanceMenu( GetMenu( "ModesMenu" ) )
}

function OnSettingsButton_Activate( button )
{
	if ( level.ui.privatematch_starting == ePrivateMatchStartState.STARTING )
		return

	AdvanceMenu( GetMenu( "MatchSettingsMenu" ) )
}

function OnPrivateMatchButtonThreaded()
{
	wait 1

	if ( uiGlobal.cancelledPrivateMatch )
	{
		uiGlobal.cancelledPrivateMatch = false
		return
	}

	ClientCommand( "playlist private_match" )
	ClientCommand( "reload" )
}

function OnPrivateMatchButton_Activate( button )
{
	ShowPrivateMatchConnectDialog()
	thread OnPrivateMatchButtonThreaded()
}

function OnStartMatchButton_Activate( button )
{
	ClientCommand( "PrivateMatchLaunch" )
}

function OnStartMatchButton_GetFocus( button )
{
	local menu = GetMenu( "LobbyMenu" )
	//HandleLockedCustomMenuItem( menu, button, ["#FOO"] )
}

function OnStartMatchButton_LoseFocus( button )
{
	local menu = GetMenu( "LobbyMenu" )
	//HandleLockedCustomMenuItem( menu, button, [], true )
}

function HandleLockedCustomMenuItem( menu, button, tipInfo, hideTip = false )
{
	local elements = GetElementsByClassname( menu, "HideWhenLocked" )
	local buttonTooltip = menu.GetChild( "ButtonTooltip" )
	local toolTipLabel = buttonTooltip.GetChild( "Label" )

	if ( button.IsLocked() && !hideTip )
	{
		foreach( elem in elements )
			elem.Hide()

		local tipArray = clone tipInfo
		tipInfo.resize( 6, null )

		toolTipLabel.SetText( tipInfo[0], tipInfo[1], tipInfo[2], tipInfo[3], tipInfo[4], tipInfo[5] )

		local buttonPos = button.GetAbsPos()
		local buttonHeight = button.GetHeight()
		local tooltipHeight = buttonTooltip.GetHeight()
		local yOffset = ( tooltipHeight - buttonHeight ) / 2.0

		buttonTooltip.SetPos( buttonPos[0] + button.GetWidth() * 0.9, buttonPos[1] - yOffset )
		buttonTooltip.Show()

		return true
	}
	else
	{
		foreach( elem in elements )
			elem.Show()
		buttonTooltip.Hide()
	}
	return false
}
Globalize( HandleLockedCustomMenuItem )

function PrivateMatchSwitchTeams( button )
{
	if ( !IsPrivateMatch() )
		return

	if ( !IsConnected() )
		return

	if ( uiGlobal.activeMenu != GetMenu( "LobbyMenu" ) )
		return

	EmitUISound( "Menu_GameSummary_ScreenSlideIn" )

	ClientCommand( "PrivateMatchSwitchTeams" )
}

function MonitorPlaylistChange()
{
	EndSignal( uiGlobal.signalDummy, "CleanupInGameMenus" )

	local playlist
	local lastPlaylist

	while ( 1 )
	{
		playlist = GetCurrentPlaylistName()

		if ( playlist != lastPlaylist )
		{
			UpdateLobbyRankedButton()

			lastPlaylist = playlist
		}

		WaitFrameOrUntilLevelLoaded()
	}
}


function OnClickRankedButton( button )
{
	if ( !PlayerQualifiedForRanked() )
		return

	if ( GetPersistentVar( "ranked.joinedRankedPlay" ) )
	{
		// already viewwed intro letter
		AdvanceMenu( GetMenu( "RankedPlayMenu" ) )
		return
	}

	OpenRankedPlayAdvocateLetter()
}

function UICodeCallback_SetupPlayerListGenElements( params, gen, rank, isPlayingRanked )
{
	if ( !RankedPlayAvailable() )
		return false

	// can only see rank icons if you have entered into ranks
	if ( !GetPersistentVar( "ranked.joinedRankedPlay" ) )
		return false
	if ( !GetPersistentVar( "ranked.isPlayingRanked" ) )
		return false

	// is this player playing ranked?
	if ( !isPlayingRanked )
		return false

	local rankImage = GetRankImage( rank )
	params.image = rankImage
	params.imageOverlay = ""
}

function OnClickGameSummaryButton( button )
{
	uiGlobal.playerOpenedEOG = true
	AdvanceMenu( GetMenu( "EOG_XP" ) )
}
