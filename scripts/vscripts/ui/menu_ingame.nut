const RANK_TOGGLE_IN_MATCH_GRACE_PERIOD = 60

enum eRankButtonStatus
{
	ENABLED
	DISABLED_TOO_LATE
	DISABLED_ALREADY_ACTIVE
}

function main()
{
	RegisterSignal( "OnCloseLobbyMenu" )
	RegisterSignal( "CancelRankButtonCooldown" )
	Globalize( UpdateRankButton )
	Globalize( InitRankGracePeriodEndTime )
	Globalize( SetRankedButtonEnabledText )

	file.rankGracePeriodEnds <- 0
	RegisterUIVarChangeCallback( "rankEnableMode", Bind( UpdateRankButton ) )
}

function InitRankGracePeriodEndTime()
{
	file.rankGracePeriodEnds = Time() + RANK_TOGGLE_IN_MATCH_GRACE_PERIOD
}

function InitMenuInGame( menu )
{
	local buttons = GetElementsByClassname( menu, "BurnCardMenuButtonClass" )
	file.BtnBurnCardMenu <- buttons[0] // GetChild gives a "already created" error sometimes

	local buttons = GetElementsByClassname( menu, "EndGameButtonClass" )
	file.BtnEndGame <- buttons[0] // GetChild gives a "already created" error sometimes

	file.BtnTrackedChallengeTitle <- GetElementsByClassname( menu, "ChallengeTrackerTitle" )[0]
	file.BtnTrackedChallengeBackground <- GetElementsByClassname( menu, "ChallengeTrackerBackground" )[0]

	file.trackedChallengeButtons <- []

	for ( local i = 0 ; i < MAX_TRACKED_CHALLENGES ; i++ )
	{
		local button = GetElementsByClassname( menu, "BtnTrackedChallenge_" + i )[0]
		button.s.challengeRef <- null
		button.s.challengeRefTier <- null
		button.s.index <- i
		button.s.dimOverlay <- button.GetChild( "DimOverlay" )
		button.s.dimOverlay.SetAlpha( 0 )
		button.s.trackedChallengeButton <- true

	 	file.trackedChallengeButtons.append( button )
	}

	local buttons = GetElementsByClassname( menu, "RankedButtonClass" )
	file.BtnRanked <- buttons[0]
}
Globalize( InitMenuInGame )

function OnOpenInGameMenu()
{
	if ( IsConnected() )
	{
		if ( ShouldShowBurnCardMenu() )
		{
			file.BtnBurnCardMenu.Show()
			file.BtnBurnCardMenu.SetEnabled( ShouldEnableBurnCardMenu() )
		}
		else
		{
			file.BtnBurnCardMenu.Hide()
		}

		if ( ShouldShowInGameRankedButton() )
		{
			file.BtnRanked.Show()

			UpdateRankButton()
		}
		else
		{
			file.BtnRanked.Hide()
		}

		if ( GetActiveLevel() == "mp_npe" )
		{
			local leaveGameButtons = GetElementsByClassname( GetMenu( "InGameMenu" ), "LeaveGameButtonClass" )
			foreach ( leaveGameButton in leaveGameButtons )
			{
				leaveGameButton.SetText( "#SKIP_TRAINING" );
			}
		}

		if ( IsPrivateMatch() && AmIPartyLeader() )
		{
			file.BtnEndGame.Show()
			file.BtnEndGame.SetEnabled( true )
		}
		else
		{
			file.BtnEndGame.Hide()
		}

		thread UpdateTrackedChallenges()

		ClientCommand( "InGameMenuOpened" )
		thread InitCustomLoadouts()
	}
}
Globalize( OnOpenInGameMenu )

function OnCloseInGameMenu()
{
	Signal( uiGlobal.signalDummy, "OnCloseLobbyMenu" )
	if ( IsConnected() )
		ClientCommand( "InGameMenuClosed" )
}
Globalize( OnCloseInGameMenu )

function OnClosePilotLoadoutsMenu()
{
	if ( IsConnected() )
		ClientCommand( "PilotLoadoutsMenuClosed" )
}
Globalize( OnClosePilotLoadoutsMenu )

function UpdateTrackedChallenges()
{
	EndSignal( uiGlobal.signalDummy, "OnCloseLobbyMenu" )

	local trackedChallengeLen = GetNumberOfTrackedChallenges()
	switch ( trackedChallengeLen )
	{
		case 0:
			file.BtnTrackedChallengeTitle.Hide()
			file.BtnTrackedChallengeBackground.Hide()
			break

		case 1:
			file.BtnTrackedChallengeBackground.SetImage( "../ui/menu/challenges/challengeTrackerIngameBack_1")
			file.BtnTrackedChallengeBackground.SetHeight( GetContentScaleFactor( uiGlobal.activeMenu )[1] * 91 )
			file.BtnTrackedChallengeBackground.Show()
			file.BtnTrackedChallengeTitle.Show()
			break

		case 2:
			file.BtnTrackedChallengeBackground.SetImage( "../ui/menu/challenges/challengeTrackerIngameBack_2")
			file.BtnTrackedChallengeBackground.SetHeight( GetContentScaleFactor( uiGlobal.activeMenu )[1] * 153 )
			file.BtnTrackedChallengeBackground.Show()
			file.BtnTrackedChallengeTitle.Show()
			break

		case 3:
			file.BtnTrackedChallengeBackground.SetImage( "../ui/menu/challenges/challengeTrackerIngameBack_3")
			file.BtnTrackedChallengeBackground.SetHeight( GetContentScaleFactor( uiGlobal.activeMenu )[1] * 214 )
			file.BtnTrackedChallengeBackground.Show()
			file.BtnTrackedChallengeTitle.Show()
			break
	}

	local trackedChallenges = GetTrackedChallenges()
	while( IsFullyConnected() )
	{
		for ( local i = 0 ; i < MAX_TRACKED_CHALLENGES ; i ++ )
		{
			local challengeRef = trackedChallenges[i]
			if ( challengeRef != "" )
			{
				UI_GetSpecificChallengeProgress( challengeRef )
				local tier = GetCurrentChallengeTier( challengeRef )
				UpdateChallengeButton( file.trackedChallengeButtons[ i ], challengeRef, tier, true )
				file.trackedChallengeButtons[ i ].Show()
			}
			else
			{
				file.trackedChallengeButtons[ i ].Hide()
			}
		}

		wait 1.0
	}
}

function GetNumberOfTrackedChallenges()
{
	local numberOfTrackedChallenges = 0
	for ( local i = 0; i < MAX_TRACKED_CHALLENGES; i++ )
	{
		if ( GetPersistentVar( "trackedChallengeRefs[" + i + "]" ) != "" )
			numberOfTrackedChallenges++
	}
	return numberOfTrackedChallenges
}


function UpdateRankButtonAfterDelay( timeRemaining )
{
	EndSignal( uiGlobal.signalDummy, "OnCloseLobbyMenu" )
	Assert( timeRemaining >= 0 )
	wait timeRemaining
	UpdateRankButton()  // Force a text update in case the player has the menu open when it times out
}


function ShouldShowInGameRankedButton()
{
	if ( !MatchSupportsRankedPlay() )
		return false

	if ( !PlayerAcceptedRankInvite() )
		return false

	return true
}
Globalize( ShouldShowInGameRankedButton )

function GetRankButtonStatus()
{
	if ( GetPersistentVar( "ranked.isPlayingRanked" ) )
		return eRankButtonStatus.DISABLED_ALREADY_ACTIVE

	if ( level.ui.rankEnableMode == eRankEnabledModes.TOO_LATE )
		return eRankButtonStatus.DISABLED_TOO_LATE

	if ( Time() < file.rankGracePeriodEnds )
		return eRankButtonStatus.ENABLED

	return eRankButtonStatus.DISABLED_TOO_LATE
}
Globalize( GetRankButtonStatus )

function UpdateRankButton()
{
	if ( !IsFullyConnected() )
		return

	switch ( GetRankButtonStatus() )
	{
		case eRankButtonStatus.ENABLED:
			file.BtnRanked.SetEnabled( true )
			local timeRemaining = file.rankGracePeriodEnds - Time()
			file.BtnRanked.SetAutoText( "#RANKED_GAME_MENU_ENABLE_TIMER", HATT_UI_COUNTDOWN_SECONDS, file.rankGracePeriodEnds - 1 )
			thread UpdateRankButtonAfterDelay( timeRemaining )
			return

		case eRankButtonStatus.DISABLED_ALREADY_ACTIVE:

			file.BtnRanked.SetEnabled( false )
			SetRankedButtonEnabledText( file.BtnRanked )
			break

		case eRankButtonStatus.DISABLED_TOO_LATE:
			file.BtnRanked.SetEnabled( false )
			file.BtnRanked.SetText( "#RANKED_GAME_MENU_ENABLED_TOO_LATE" )
			break
	}

	if ( file.BtnRanked.IsAutoText() )
		file.BtnRanked.DisableAutoText()
}

function SetRankedButtonEnabledText( button )
{
	if ( level.ui.rankEnableMode == eRankEnabledModes.NOT_ENOUGH_PEOPLE )
		button.SetText( "#RANKED_GAME_MENU_DISABLED_NOT_ENOUGH_PLAYERS" )
	else
		button.SetText( "#RANKED_GAME_MENU_ENABLED_ALREADY" )

	button.SetEnabled( false )
	if ( button.IsAutoText() )
		button.DisableAutoText()
}