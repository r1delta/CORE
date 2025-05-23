
function main()
{
	Globalize( InitFooterButtons )
	Globalize( UpdateFooterButtons )
	Globalize( XboxInviteFriends )
	Globalize( XboxOpenPartyApp )
	Globalize( OriginInviteFriends )
	Globalize( AppendPCInviteLabels )
	Globalize( AppendGamepadInviteLabels )
	Globalize( UpdateFooters )
	Globalize( DelayedTryUpdateFooterButtonsWhy )
	Globalize( SendProgressionChoice )
}

function InitFooterButtons()
{
	uiGlobal.footerData <- null
	uiGlobal.canXBoxInvite <- false
	uiGlobal.canXBoxOpenPartyApp <- false
	uiGlobal.canOriginInvite <- false
	uiGlobal.playerListFocused <- false
	uiGlobal.canSetDataCenter <- false

	foreach ( menu in uiGlobal.allMenus )
		InitFooterButtonsForMenu( menu )

	thread MonitorMenuChange()

	if ( Durango_IsDurango() )
	{
		thread UpdateXboxCanInvite()
		thread UpdateXboxCanOpenPartyApp()
	}
	else if ( Origin_IsEnabled() )
	{
		thread UpdateOriginInvite()
	}

	thread UpdatePrivateMatchSwitchTeams()

	thread UpdatePlayerlistFocused()
	thread UpdateCanSetDataCenter()
}

function InitFooterButtonsForMenu( menu )
{
	local gamepadButtons = GetElementsByClassname( menu, "GamepadFooterButtonClass" )
	local pcButtons = GetElementsByClassname( menu, "PCFooterButtonClass" )

	foreach ( button in gamepadButtons )
	{
		button.AddEventHandler( UIE_CLICK, OnFooterButton_Activate )
		button.EnableKeyBindingIcons()
	}

	foreach ( button in pcButtons )
		button.AddEventHandler( UIE_CLICK, OnFooterButton_Activate )
}

function OnFooterButton_Activate( button )
{
	Assert( uiGlobal.footerData.pc )

	local index = button.GetScriptID().tointeger()

	if ( (index < uiGlobal.footerData.pc.len()) && ("func" in uiGlobal.footerData.pc[index]) )
	{
		local func = uiGlobal.footerData.pc[index].func

		if ( func != null )
			func.call( this, button )
	}
}

function UpdateFooterButtons( menuName = null )
{
	local footerData = {}
	footerData.gamepad <- []
	footerData.pc <- []

	if ( uiGlobal.activeMenu != null )
	{
		if ( menuName == null )
			menuName = uiGlobal.activeMenu.GetName()
	}

	switch ( menuName )
	{
		case "MainMenu":
			if ( !Durango_IsDurango() || Durango_IsSignedIn() )
				footerData.gamepad.append( { label = "#A_BUTTON_SELECT" } )

			if ( Durango_IsDurango() && Durango_IsSignedIn() )
				footerData.gamepad.append( { label = "#B_BUTTON_SWITCH_PROFILE" } )


            footerData.pc.append( { label = "#ADDONS", func = OnAddonButton_Activate } )
			footerData.gamepad.append( { label = "#GAMEPAD_ADDONS", func = OnAddonButton_Activate } )

			if ( !Origin_IsEnabled() && !Origin_IsOnline() )
			{
				footerData.pc.append( { label = "#GAMEUI_DATACENTERNAME", func = OpenOfflineNameDialogButton_Activate } )
				footerData.gamepad.append( { label = "#EDIT_USERNAME", func = OpenOfflineNameDialogButton_Activate } )
			}
            footerData.pc.append( { label = "#DISCORD", func = OpenDiscordLink })
			footerData.gamepad.append( { label = "#GAMEPAD_DISCORD", func = OpenDiscordLink })
			footerData.gamepad = AppendGamepadInviteLabels( footerData.gamepad )
			break

		case "RankedModesMenu":
			footerData.gamepad.append( { label = "#B_BUTTON_BACK" } )
			footerData.pc.append( { label = "#BACK", func = PCBackButton_Activate } )
			break
		case "MapsMenu":
		case "ModesMenu":
			footerData.gamepad.append( { label = "#A_BUTTON_SELECT" } )
			footerData.gamepad.append( { label = "#B_BUTTON_BACK" } )
			footerData.pc.append( { label = "#BACK", func = PCBackButton_Activate } )
			break

		case "MatchSettingsMenu":
			footerData.gamepad.append( { label = "#A_BUTTON_SELECT" } )

			footerData.gamepad.append( { label = "#B_BUTTON_BACK" } )
			footerData.pc.append( { label = "#BACK", func = PCBackButton_Activate } )

			footerData.gamepad.append( { label = "#X_BUTTON_APPLY", func = ApplyMatchSettings } )
			footerData.pc.append( { label = "#APPLY", func = ApplyMatchSettings } )

			footerData.gamepad.append( { label = "#Y_BUTTON_RESTORE_DEFAULTS", func = ResetMatchSettingsToDefaultDialog } )
			footerData.pc.append( { label = "#RESTORE_DEFAULTS", func = ResetMatchSettingsToDefaultDialog } )
			break

		case "ViewStats_Overview_Menu":
		case "ViewStats_Kills_Menu":
		case "ViewStats_Time_Menu":
		case "ViewStats_Distance_Menu":
		case "ViewStats_Weapons_Menu":
		case "ViewStats_Misc_Menu":
			footerData.gamepad.append( { label = "#B_BUTTON_BACK" } )
			footerData.pc.append( { label = "#BACK", func = PCBackButton_Activate } )

			footerData.gamepad = AppendGamepadInviteLabels( footerData.gamepad )
			footerData.pc = AppendPCInviteLabels( footerData.pc )
			break
		case "EOG_XP":
		case "EOG_Coins":
		case "EOG_MapStars":
		case "EOG_Unlocks":
			footerData.gamepad.append( { label = "#B_BUTTON_BACK" } )
			footerData.pc.append( { label = "#BACK", func = PCBackButton_Activate } )

			EOGCoop_QuickMatchFooter( footerData )
			break

		case "ViewStats_Levels_Menu":
			ViewStatsLevels_FooterData( footerData )
			break

		case "EOG_Ranked":
			EOGRanked_FooterData( footerData )
			EOGCoop_QuickMatchFooter( footerData )
			break

		case "EOG_Challenges":
			EOGChallenges_FooterData( footerData )
			EOGCoop_QuickMatchFooter( footerData )
			break

		case "EOG_Coop":
			EOGCoop_FooterData( footerData )
			EOGCoop_QuickMatchFooter( footerData )
			break

		case "EOG_Scoreboard":
			EOGScoreboard_FooterData( footerData )
			break

		case "ChallengesMenuDetails":
			Challenges_FooterData( footerData )
			break

		case "LobbyMenu":
		case "ClassicMenu":
		case "CoopPartyMenu":
		case "CoopPartyCustomMenu":
			if ( uiGlobal.playerListFocused )
			{
				if ( Durango_IsDurango() )
					footerData.gamepad.append( { label = "#A_BUTTON_GAMERCARD" } )
				else
					footerData.gamepad.append( { label = "#A_BUTTON_PLAYER_PROFILE" } )
			}
			else
			{
				footerData.gamepad.append( { label = "#A_BUTTON_SELECT" } )
			}

			if ( menuName == "LobbyMenu" )
			{
				footerData.gamepad.append( { label = "#B_BUTTON_LEAVE" } )
				footerData.pc.append( { label = "#LEAVE", func = PCBackButton_Activate } )

				if ( IsFullyConnected() && !IsPrivateMatch() && level.ui.nextMapModeComboIndex != null )
				{
					local gameMode = GetCurrentPlaylistGamemodeByIndex( level.ui.nextMapModeComboIndex )
					if (  PersistenceEnumValueIsValid( "gameModesWithStars", gameMode ) )
					{
						if ( uiGlobal.starsPanelVisible )
						{
							footerData.gamepad.append( { label = "#Y_BUTTON_HIDE_STARS" } )
							footerData.pc.append( { label = "#HIDE_STARS", func = ViewStarsButton_Activated } )
						}
						else
						{
							footerData.gamepad.append( { label = "#Y_BUTTON_VIEW_STARS" } )
							footerData.pc.append( { label = "#VIEW_STARS", func = ViewStarsButton_Activated } )
						}
					}
				}
			}
			else
			{
				footerData.gamepad.append( { label = "#B_BUTTON_BACK" } )
				footerData.pc.append( { label = "#BACK", func = PCBackButton_Activate } )
			}

			if ( IsPrivateMatch() && level.ui.privatematch_starting != ePrivateMatchStartState.STARTING )
			{
				footerData.gamepad.append( { label = "#XBOX_SWITCH_TEAMS" } )
				footerData.pc.append( { label = "#SWITCH_TEAMS", func = PCSwitchTeamsButton_Activate } )

				if ( GetConVarBool( "hide_server" ) && AmIPartyLeader() )
					footerData.pc.append( { label = "#HIDE_SERVER", func = ToggleHideServer } )
				else if ( AmIPartyLeader() )
					footerData.pc.append( { label = "#SHOW_SERVER", func = ToggleHideServer } )
			} else if ( GetConVarInt( "sv_lobbyType" ) == 0 )
			{
				if ( GetPersistentVar( "delta.everythingUnlocked") )
				    footerData.pc.append( { label = "#DISABLE_EVERYTHINGUNLOCKED", func = ToggleProgression } )
				else
				    footerData.pc.append( { label = "#ENABLE_EVERYTHINGUNLOCKED", func = ToggleProgression } )
			}

			footerData.pc = AppendPCInviteLabels( footerData.pc )

			if ( uiGlobal.playerListFocused )
			{
				footerData.gamepad.append( { label = "#X_BUTTON_MUTE" } )
				footerData.pc.append( { label = "#MOUSE1_MUTE" } )

				// footerData.pc.append( { label = "#MOUSE2_VIEW_PLAYER_PROFILE" } )
			}

			footerData.gamepad = AppendGamepadInviteLabels( footerData.gamepad )
			break

		case "ImageWalkThroughMenu":
			ImageWalkThroughMenu_FooterUpdate( footerData )
			break


		case "DevMenu":
		case "DevLevelMenu":
		case "WeaponSelectMenu":
		case "TitanSelectMenu":
		case "AbilitySelectMenu":
		case "PassiveSelectMenu":
		case "DecalSelectMenu":
		case "TitanOSSelectMenu":

			footerData.gamepad.append( { label = "#A_BUTTON_SELECT" } )

			footerData.gamepad.append( { label = "#B_BUTTON_BACK" } )
			footerData.pc.append( { label = "#BACK", func = PCBackButton_Activate } )
			break

		case "RankedInviteMenu":
			if ( HasPlayersToInvite() )
				footerData.gamepad.append( { label = "#A_BUTTON_SELECT" } )

			footerData.gamepad.append( { label = "#B_BUTTON_BACK" } )
			footerData.pc.append( { label = "#BACK", func = PCBackButton_Activate } )
			break

		case "RankedTiersMenu":
		case "RankedSeasonsMenu":
			footerData.gamepad.append( { label = "#B_BUTTON_BACK" } )
			footerData.pc.append( { label = "#BACK", func = PCBackButton_Activate } )
			break

		case "Generation_Respawn":
			Generation_Respawn_FooterData( footerData )
			break

		case "Advocate_Letter":
			Advocate_Letter_FooterData( footerData )
			break

		case "BlackMarketMenu":
			BlackMarket_FooterData( footerData )
			break

		case "BlackMarketMainMenu":
			BlackMarketMain_FooterData( footerData )
			break

        case "ServerBrowserMenu":
		    footerData.gamepad.append( { label = "#A_BUTTON_SELECT" } )

			footerData.gamepad.append( { label = "#B_BUTTON_BACK" } )
			footerData.pc.append( { label = "#BACK", func = PCBackButton_Activate } )

			footerData.gamepad.append( { label = "#FOOTER_DIRECT_CONNECT_GAMEPAD"   })
            footerData.pc.append( { label = "#FOOTER_DIRECT_CONNECT",func = OpenDirectConnectDialog_Activate } )

			footerData.gamepad.append( { label = "%[X_BUTTON]% ^798B9800 Refresh" } )
			footerData.pc.append( { label = "#FOOTER_REFRESH", func = RefreshServerList } )


            break

		case "Addons":
			footerData.gamepad.append( { label = "#B_BUTTON_BACK" } )
			footerData.pc.append( { label = "#BACK", func = PCBackButton_Activate } )

            footerData.gamepad.append( { label = "#RELOAD_ADDON_PATHS_GAMEPAD" } )
            footerData.pc.append( { label = "#RELOAD", func = UpdateAddonPaths } )

			footerData.gamepad.append( { label = "#OPEN_ADDONS_FOLDER_GAMEPAD" } )
			footerData.pc.append( { label = "#OPEN_ADDONS_FOLDER", func = OpenAddonFolder } )

			break

		case "OptionsMenu":
		case "GamepadControlsMenu":
		case "GamepadLayoutMenu":
		case "MouseKeyboardControlsMenu":
		case "AudioSettingsMenu":
		case "EditPilotLoadoutMenu":
		case "EditTitanLoadoutMenu":
		case "PilotLoadoutsMenu":
		case "TitanLoadoutsMenu":
		case "RankedPlayMenu":
		case "RankedInviteMenu":
		case "RankedSeasonsMenu":
		case "ViewStatsMenu":
		case "ChallengesMenu":
			footerData.gamepad.append( { label = "#A_BUTTON_SELECT" } )

			footerData.gamepad.append( { label = "#B_BUTTON_BACK" } )
			footerData.pc.append( { label = "#BACK", func = PCBackButton_Activate } )

			footerData.gamepad = AppendGamepadInviteLabels( footerData.gamepad )
			footerData.pc = AppendPCInviteLabels( footerData.pc )

			if (IsFullyConnected() && GetActiveLevel() != "mp_lobby") // BME
			{
				// gamepad default = ^798B9800, pc default = nothing
				// #6EEB6A = light green
				if ( menuName == "PilotLoadoutsMenu" && !IsItemLocked( "pilot_custom_loadout_1" ) )
				{
					footerData.gamepad.append( { label = "%[Y_BUTTON]% ^6EEB6A00Edit" } )
					footerData.pc.append( { label = "(Mouse 2) Edit", func = LoadoutEditMouseclickNotice } )
				}
				else if ( menuName == "TitanLoadoutsMenu" && !IsItemLocked( "titan_custom_loadout_1" ) )
				{
					footerData.gamepad.append( { label = "%[Y_BUTTON]% ^6EEB6A00Edit" } )
					footerData.pc.append( { label = "(Mouse 2) Edit", func = LoadoutEditMouseclickNotice } )
				}
			}

			break

		case "EditPilotLoadoutsMenu":
		case "EditTitanLoadoutsMenu":
			local focusedItem = GetFocus()
			if ( focusedItem != null )
			{
				local isCustom = ("isCustom" in focusedItem.s) && focusedItem.s.isCustom
				if ( isCustom )
					footerData.gamepad.append( { label = "#A_BUTTON_EDIT" } )
				else
					footerData.gamepad.append( { label = "#A_BUTTON_SELECT" } )
			}

			footerData.gamepad.append( { label = "#B_BUTTON_BACK" } )
			footerData.pc.append( { label = "#BACK", func = PCBackButton_Activate } )

			footerData.gamepad = AppendGamepadInviteLabels( footerData.gamepad )
			footerData.pc = AppendPCInviteLabels( footerData.pc )

			if ( IsFullyConnected() && level.ui.nextMapModeComboIndex == null )
			{
				if ( menuName == "EditPilotLoadoutsMenu" && !IsItemLocked( "pilot_custom_loadout_1" ) )
				{
					footerData.gamepad.append( { label = "#Y_BUTTON_CHANGE_LOADOUT_GAMEMODE" } )
					footerData.pc.append( { label = "#CHANGE_LOADOUT_GAMEMODE", func = ToggleLoadoutGamemode } )
				}
				else if ( menuName == "EditTitanLoadoutsMenu" && !IsItemLocked( "titan_custom_loadout_1" ) )
				{
					footerData.gamepad.append( { label = "#Y_BUTTON_CHANGE_LOADOUT_GAMEMODE" } )
					footerData.pc.append( { label = "#CHANGE_LOADOUT_GAMEMODE", func = ToggleLoadoutGamemode } )
				}
			}

			break

		case "MouseKeyboardBindingsMenu":
			footerData.gamepad.append( { label = "#B_BUTTON_BACK" } )
			footerData.pc.append( { label = "#BACK", func = PCBackButton_Activate } )

			footerData.gamepad.append( { label = "#X_BUTTON_APPLY", func = ApplyKeyBindingsButton_Activate } )
			footerData.pc.append( { label = "#APPLY", func = ApplyKeyBindingsButton_Activate } )

			footerData.gamepad.append( { label = "#Y_BUTTON_RESTORE_DEFAULTS", func = DefaultKeyBindingsDialog } )
			footerData.pc.append( { label = "#RESTORE_DEFAULTS", func = DefaultKeyBindingsDialog } )

			footerData.gamepad = AppendGamepadInviteLabels( footerData.gamepad )
			footerData.pc = AppendPCInviteLabels( footerData.pc )
			break

		case "AdvancedVideoSettingsMenu":
			footerData.gamepad.append( { label = "#A_BUTTON_SELECT" } )

			footerData.gamepad.append( { label = "#B_BUTTON_BACK" } )
			footerData.pc.append( { label = "#BACK", func = PCBackButton_Activate } )

			footerData.gamepad.append( { label = "#X_BUTTON_APPLY", func = ApplyVideoSettingsButton_Activate } )
			footerData.pc.append( { label = "#APPLY", func = ApplyVideoSettingsButton_Activate } )

			if ( !IsFullyConnected() )
				footerData.gamepad.append( { label = "#Y_BUTTON_RESTORE_SETTINGS", func = RestoreRecommendedDialog } )
			footerData.pc.append( { label = "#MENU_RESTORE_SETTINGS", func = RestoreRecommendedDialog, enabled = IsFullyConnected() ? false : true } )

			footerData.gamepad = AppendGamepadInviteLabels( footerData.gamepad )
			footerData.pc = AppendPCInviteLabels( footerData.pc )
			break

		case "BurnCards_pickcard":
			BurnCards_PickCard_FooterData( footerData )
			break

		case "BurnCards_InGame":
			BurnCards_InGame_FooterData( footerData )
			break

		case "InGameMenu":
		case "InGameSPMenu":
			footerData.gamepad.append( { label = "#A_BUTTON_SELECT" } )

			footerData.gamepad.append( { label = "#B_BUTTON_CLOSE" } )
			footerData.pc.append( { label = "#CLOSE", func = PCBackButton_Activate } )

			footerData.gamepad = AppendGamepadInviteLabels( footerData.gamepad )
			footerData.pc = AppendPCInviteLabels( footerData.pc )
			break

		case "CampaignRewardMenu":
			footerData.gamepad.append( { label = "#B_BUTTON_CLOSE" } )
			footerData.pc.append( { label = "#CLOSE", func = PCBackButton_Activate } )
			break

		default:
			break
	}

	UpdateFooters( footerData )
}

function UpdateFooters( footerData )
{
	uiGlobal.footerData = footerData

	if ( uiGlobal.activeMenu )
	{
		local activeGamepadFooterButtons = GetElementsByClassname( uiGlobal.activeMenu, "GamepadFooterButtonClass" )
		foreach ( button in activeGamepadFooterButtons )
		{
                        if (typeof(button) == "string") { continue; }
 			local index = button.GetScriptID().tointeger()

			if ( index < footerData.gamepad.len() )
			{
				Assert( "label" in footerData.gamepad[index] )

				local s1 = ""
				if ( "s1" in footerData.gamepad[index] )
					s1 = footerData.gamepad[index].s1

				button.SetText( footerData.gamepad[index].label, s1 )
				button.Show()
				//printt( "button name:", button.GetName(), "set to label index:", index, "which is:", footerData.gamepad[index].label )
			}
			else
			{
				button.Hide()
				button.SetText( "" )
			}
		}

		local activePCFooterButtons = GetElementsByClassname( uiGlobal.activeMenu, "PCFooterButtonClass" )
		foreach ( button in activePCFooterButtons )
		{
                        if (typeof(button) == "string") { continue; }
			local index = button.GetScriptID().tointeger()

			if ( index < footerData.pc.len() )
			{
				Assert( "label" in footerData.pc[index] )

				local s1 = ""
				if ( "s1" in footerData.gamepad[index] )
					s1 = footerData.gamepad[index].s1

				button.SetText( footerData.pc[index].label, s1 )
				if ( "enabled" in footerData.pc[index] )
					button.SetEnabled( footerData.pc[index].enabled )
				button.Show()
				//printt( "button name:", button.GetName(), "set to label index:", index, "which is:", footerData.pc[index].label )
			}
			else
			{
				button.Hide()
				button.SetText( "" )
			}
		}

		// Clear previous menu footers when showing submenus
		if ( uiGlobal.activeMenu.GetType() == "submenu" )
		{
			local previousMenu = null
			if ( uiGlobal.menuStack.len() > 1 )
				previousMenu = uiGlobal.menuStack[uiGlobal.menuStack.len()-2]

			if ( previousMenu )
			{
				local previousMenuFooterButtons = GetElementsByClassname( previousMenu, "GamepadFooterButtonClass" )
				previousMenuFooterButtons.extend( GetElementsByClassname( previousMenu, "PCFooterButtonClass" ) )

				foreach ( button in previousMenuFooterButtons )
					button.Hide()
			}
		}
	}
}

function ToggleHideServer( button )
{
	local value = GetConVarBool( "hide_server" )
	value = !value

	if ( value )
	    ClientCommand( "hide_server 1" )
	else
		ClientCommand( "hide_server 0" )

	UpdateFooterButtons()

	thread DelayedTryUpdateFooterButtonsWhy()
}

function ToggleProgression( button )
{
	local value = GetPersistentVar( "delta.everythingUnlocked") ? 0 : 1

	if ( value == 1 )
	{
		local buttonData = []
		buttonData.append( { name = "#YES", func = SendProgressionChoice } )
		buttonData.append( { name = "#NO", func = null } )

		local footerData = []
		footerData.append( { label = "#A_BUTTON_SELECT" } )
		footerData.append( { label = "#B_BUTTON_CLOSE" } )

		local dialogData = {}
		dialogData.header <- "#PROGRESSIONCHOICE_HEADER"
		dialogData.detailsMessage <- "#PROGRESSIONCHOICE_DESC"
		dialogData.buttonData <- buttonData
		dialogData.footerData <- footerData
		OpenChoiceDialog( dialogData )
	} else
	{
		SendProgressionChoice()
	}
}

function SendProgressionChoice()
{
	local value = GetPersistentVar( "delta.everythingUnlocked") ? 0 : 1

	ClientCommand( "UpdateProgressionOption " + value )

	thread DelayedTryUpdateFooterButtonsWhy()
}

function DelayedTryUpdateFooterButtonsWhy()
{
	wait 0.15

	UpdateFooterButtons( uiGlobal.activeMenu.GetName() )
}

function AppendGamepadInviteLabels( footerData )
{
	if ( Durango_IsDurango() )
	{
		if ( uiGlobal.canXBoxOpenPartyApp )
			footerData.append( { label = "#XBOX_OPEN_PARTY_APP" } ) // XboxOpenPartyApp
		if ( uiGlobal.canXBoxInvite )
			footerData.append( { label = "#XBOX_INVITE_FRIENDS" } )	// XboxInviteFriends
	}
	else if ( Origin_IsEnabled() )
	{
		if ( uiGlobal.canOriginInvite )
			footerData.append( { label = "#XBOX_INVITE_FRIENDS" } ) // OriginInviteFriends
	}

	return footerData
}

function AppendPCInviteLabels( footerData )
{
	if ( Origin_IsEnabled() && !IsDelta() )
	{
		if ( uiGlobal.canOriginInvite )
			footerData.append( { label = "#INVITE_FRIENDS", func = OriginInviteFriends } )
	}

	return footerData
}

function MonitorMenuChange()
{
	while ( 1 )
	{
		WaitSignal( uiGlobal.signalDummy, "ActiveMenuChanged" )

		if ( uiGlobal.activeMenu != null )
			UpdateFooterButtons()
	}
}

function UpdatePlayerlistFocused()
{
	local lastResult = false

	while( 1 )
	{
		// make sure this isn't running during gameplay and hurting framerate
		while ( !uiGlobal.activeMenu )
			WaitSignal( uiGlobal.signalDummy, "ActiveMenuChanged" )

		local focusedItem = GetFocus()

		// The check for GetScriptID existing isn't ideal, but if the text chat text output element has focus it will script error otherwise
		uiGlobal.playerListFocused = ( (focusedItem != null) && ("GetScriptID" in focusedItem) && (focusedItem.GetScriptID() == "PlayerListButton") )

		if ( uiGlobal.playerListFocused != lastResult )
		{
			UpdateFooterButtons()
			lastResult = uiGlobal.playerListFocused
		}

		wait 0
	}
}

function UpdateXboxCanInvite()
{
	Assert( Durango_IsDurango() )

	local lastResult = false

	while ( 1 )
	{
		while ( !uiGlobal.activeMenu )
			WaitSignal( uiGlobal.signalDummy, "ActiveMenuChanged" )

		uiGlobal.canXBoxInvite = ( uiGlobal.installComplete && IsFooterMenu() && IsConnected() && Durango_CanInviteFriends() && Durango_IsJoinable() )

		if ( uiGlobal.canXBoxInvite != lastResult )
		{
			if ( uiGlobal.canXBoxInvite ) { } //RegisterButtonPressedCallback( BUTTON_TRIGGER_RIGHT, XboxInviteFriends )
			else {}
				//DeregisterButtonPressedCallback( BUTTON_TRIGGER_RIGHT, XboxInviteFriends )

			UpdateFooterButtons()
		}

		lastResult = uiGlobal.canXBoxInvite

		wait 0
	}
}

function UpdateXboxCanOpenPartyApp()
{
	Assert( Durango_IsDurango() )

	local lastResult = false

	while ( 1 )
	{
		while ( !uiGlobal.activeMenu )
			WaitSignal( uiGlobal.signalDummy, "ActiveMenuChanged" )

		uiGlobal.canXBoxOpenPartyApp = ( uiGlobal.installComplete && IsFooterMenu() && IsConnected() && Durango_IsSignedIn() )

		if ( uiGlobal.canXBoxOpenPartyApp != lastResult )
		{
			if ( uiGlobal.canXBoxOpenPartyApp ) { } //RegisterButtonPressedCallback( BUTTON_TRIGGER_LEFT, XboxOpenPartyApp )
			else {}
				//DeregisterButtonPressedCallback( BUTTON_TRIGGER_LEFT, XboxOpenPartyApp )

			UpdateFooterButtons()
		}

		lastResult = uiGlobal.canXBoxOpenPartyApp

		wait 0
	}
}

function UpdateOriginInvite()
{
	Assert( Origin_IsEnabled() )

	local lastResult = false

	while ( 1 )
	{
		while ( !uiGlobal.activeMenu )
			WaitSignal( uiGlobal.signalDummy, "ActiveMenuChanged" )

		uiGlobal.canOriginInvite = ( IsFooterMenu() && (uiGlobal.activeMenu != GetMenu( "MouseKeyboardBindingsMenu") ) && IsConnected() && AmIPartyLeader() && Origin_IsJoinable() )

		if ( uiGlobal.canOriginInvite != lastResult )
		{
			if ( uiGlobal.canOriginInvite )
			{
		//		RegisterButtonPressedCallback( BUTTON_TRIGGER_RIGHT, OriginInviteFriends )
			}
			else
			{
				//DeregisterButtonPressedCallback( BUTTON_TRIGGER_RIGHT, OriginInviteFriends )
			}

			UpdateFooterButtons()
		}

		lastResult = uiGlobal.canOriginInvite

		wait 0
	}
}

function UpdatePrivateMatchSwitchTeams()
{
	local lastResult = false

	while ( 1 )
	{
		while ( !uiGlobal.activeMenu )
			WaitSignal( uiGlobal.signalDummy, "ActiveMenuChanged" )

		local isPrivateMatch = IsPrivateMatch()

		if ( isPrivateMatch != lastResult )
		{
			if ( IsPrivateMatch() )
			{
				RegisterButtonPressedCallback( BUTTON_Y, PrivateMatchSwitchTeams )
			}
			else
			{
				DeregisterButtonPressedCallback( BUTTON_Y, PrivateMatchSwitchTeams )
			}

			UpdateFooterButtons()
		}

		lastResult = isPrivateMatch

		wait 0
	}

}

function UpdateCanSetDataCenter()
{
	local lastResult = false
	local mainMenu = GetMenu( "MainMenu")

	while ( 1 )
	{
		while ( !uiGlobal.activeMenu )
			WaitSignal( uiGlobal.signalDummy, "ActiveMenuChanged" )

		uiGlobal.canSetDataCenter = uiGlobal.activeMenu == mainMenu && uiGlobal.mainMenuFocus != null && uiGlobal.activeDialog == null && ( !Durango_IsDurango() || (Durango_IsOnline() && Durango_IsSignedIn()) )

		if ( uiGlobal.canSetDataCenter != lastResult )
		{
			if ( uiGlobal.canSetDataCenter )
			{
				RegisterButtonPressedCallback(BUTTON_X, OpenDiscordLink )
				RegisterButtonPressedCallback(BUTTON_Y, OnAddonButton_Activate )
				// RegisterButtonPressedCallback(BUTTON_DPAD_UP, OpenOfflineNameDialogButton_Activate )
			}
			else
			{
				DeregisterButtonPressedCallback(BUTTON_X, OpenDiscordLink )
				DeregisterButtonPressedCallback(BUTTON_Y, OnAddonButton_Activate )
				// DeregisterButtonPressedCallback( BUTTON_DPAD_UP, OpenOfflineNameDialogButton_Activate )
			}
		}

		lastResult = uiGlobal.canSetDataCenter

		wait 0
	}
}

function IsFooterMenu()
{
	if ( uiGlobal.activeMenu == null )
		return false

	if ( uiGlobal.activeMenu.GetType() == "submenu" )
		return false

	if ( uiGlobal.activeDialog != null )
		return false

	// these menus don't support inviting on durango
	switch ( uiGlobal.activeMenu.GetName() )
	{
		case "RankedPlayMenu":
		case "RankedInviteMenu":
		case "BurnCards_InGame":
		case "BurnCards_pickcard":
		case "Generation_Respawn":
		case "ChallengesMenu":
		case "BlackMarketMenu":
		case "BlackMarketMainMenu":
		case "EOG_XP":
		case "EOG_Coins":
		case "EOG_MapStars":
		case "EOG_Unlocks":
		case "EOG_Ranked":
		case "EOG_Challenges":
		case "EOG_Coop":
		case "EOG_Scoreboard":
			return false
	}

	return true
}

function XboxInviteFriends( button )
{
	Assert( Durango_IsDurango() )
	Durango_InviteFriends()
}

function XboxOpenPartyApp( button )
{
	Assert( Durango_IsDurango() )
	Durango_OpenPartyApp()
}

function OriginInviteFriends( button )
{
	Assert( Origin_IsEnabled() )
	Assert( Origin_IsJoinable() )

	Origin_ShowInviteFriendsDialog()
}

function LoadoutEditMouseclickNotice( button ) // BME
{
	local buttonData = []
	buttonData.append( { name = "#CLOSE", func = null } )
	local footerData = []
	//footerData.append( { label = "#A_BUTTON_SELECT" } )
	footerData.append( { label = "#B_BUTTON_CLOSE" } )
	local dialogData = {}
	dialogData.header <- "Not like this!"
	dialogData.detailsMessage <- "To edit loadouts, you need to hover over one and right-click it."
	dialogData.buttonData <- buttonData
	dialogData.footerData <- footerData
	OpenChoiceDialog( dialogData )
}
