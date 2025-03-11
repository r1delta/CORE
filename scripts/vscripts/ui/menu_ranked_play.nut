const CHIP_MUTE_TIME = 2 // Don't try to talk again for a few seconds

level.clickedJoinRankedButton <- false

function main()
{
	Globalize( OnOpenRankedPlayMenu )
	Globalize( OnCloseRankedPlayMenu )
	Globalize( InitRankedPlayMenu )
	Globalize( OpenRankedPlayAdvocateLetter )
	Globalize( SCB_UpdateRankedPlayMenu )
	Globalize( GetRankedPlayMenuTitle )

	file.size <- [ 0, 0 ]
	file.colDefault <- Vector( 163, 187, 204 )
	file.red <- Vector( 200, 127, 84 )
	file.green <- Vector( 163, 205, 173 )
	file.buttonsRegistered <- false
	file.displayRank <- null
	file.chipLastSpokeTime <- 0

	RegisterSignal( "OnCloseRankedPlayMenu" )
	RegisterSignal( "StopTips" )
}

function SCB_UpdateRankedPlayMenu()
{
	UpdateMenuRankedButton()
	UpdateSponsorButton()
}

function InitRankedPlayMenu()
{
	local menu = GetMenu( "RankedPlayMenu" )

	file.MenuCommon <- menu.GetChild( "MenuCommon" )
	file.RankedPlayDetails <- GetElementsByClassname( menu, "RankedPlayDetails" )

	local BtnRankedButton = menu.GetChild( "BtnRankedButton" )
	BtnRankedButton.AddEventHandler( UIE_CLICK, Bind( OnClick_BtnRankedButton ) )
	BtnRankedButton.SetParentMenu( menu )
	file.BtnRankedButton <- BtnRankedButton

	local MenuTitle = menu.GetChild( "MenuTitle" )
	MenuTitle.SetParentMenu( menu )
	file.MenuTitle <- MenuTitle

	local BtnRankedGameModes = menu.GetChild( "BtnRankedGameModes" )
	BtnRankedGameModes.AddEventHandler( UIE_CLICK, Bind( OnClick_BtnRankedGameModes ) )
	BtnRankedGameModes.SetParentMenu( menu )
	file.BtnRankedGameModes <- BtnRankedGameModes

	local BtnSponsorPlayer = menu.GetChild( "BtnSponsorPlayer" )
	BtnSponsorPlayer.AddEventHandler( UIE_CLICK, Bind( OnClick_BtnSponsorPlayer ) )
	BtnSponsorPlayer.SetParentMenu( menu )
	file.BtnSponsorPlayer <- BtnSponsorPlayer

	local BtnRanks = menu.GetChild( "BtnRanks" )
	BtnRanks.AddEventHandler( UIE_CLICK, Bind( OnClick_BtnRanks ) )
	BtnRanks.SetParentMenu( menu )
	file.BtnRanks <- BtnRanks

	local BtnSeasons = menu.GetChild( "BtnSeasons" )
	BtnSeasons.AddEventHandler( UIE_CLICK, Bind( OnClick_BtnSeasons ) )
	BtnSeasons.SetParentMenu( menu )
	file.BtnSeasons <- BtnSeasons

	file.header <- menu.GetChild( "ProgressHeader" )

	file.activeRankPanel <- menu.GetChild( "RankProgressPanel0" )
	file.nextRankPanel <- menu.GetChild( "RankProgressPanel1" )

	file.nextRankGamepadHint <- menu.GetChild( "NextPageGamepadHint" )
	file.nextRankGamepadHint.EnableKeyBindingIcons()
	file.prevRankGamepadHint <- menu.GetChild( "PrevPageGamepadHint" )
	file.prevRankGamepadHint.EnableKeyBindingIcons()
	file.nextRankBtn <- menu.GetChild( "BtnNextRank" )
	file.prevRankBtn <- menu.GetChild( "BtnPrevRank" )

	if ( !( "addedEventHandler" in file.nextRankBtn.s ) )
	{
		file.nextRankBtn.AddEventHandler( UIE_CLICK, Bind( RankProgressNavigateRight ) )
		file.nextRankBtn.s.addedEventHandler <- true
	}

	if ( !( "addedEventHandler" in file.prevRankBtn.s ) )
	{
		file.prevRankBtn.AddEventHandler( UIE_CLICK, Bind( RankProgressNavigateLeft ) )
		file.prevRankBtn.s.addedEventHandler <- true
	}

	file.tipLabels <- []
	file.tipLabels.append( menu.GetChild( "Tips0" ) )
	file.tipLabels.append( menu.GetChild( "Tips1" ) )
}

function SetupRankInfo()
{
	if ( !IsFullyConnected() )
		return
	local menu = GetMenu( "RankedPlayMenu" )

	local playerRank = GetPlayerRank()
	local playerNextRank = GetNextRank( playerRank )
	file.displayRank = playerRank

	// Rank progression
	local rank = GetPlayerRank()
	RankPanel_ShowRank( menu, file.activeRankPanel, rank, false )
	file.nextRankPanel.Hide()
	file.nextRankGamepadHint.Hide()
	file.nextRankBtn.Hide()
	if ( rank == 0 )
	{
		file.prevRankGamepadHint.Hide()
		file.prevRankBtn.Hide()
	}
	else
	{
		file.prevRankGamepadHint.Show()
		file.prevRankBtn.Show()
	}


	// Decay Timer
	local decayHeader = menu.GetChild( "GemDecayHeader" )
	local decayTimeLabel = menu.GetChild( "GemDecayTimeCounterLabel" )
	local secondsTillNextDecay = GetPlayerTimeTillNextGemDecay()
	local secondsTillSeasonEnd = GetCurrentSeasonEndTime() - Daily_GetCurrentTime()
	// Don't show decay info if the decay time is longer than season reset or player has no battlemarks to lose
	if ( GetPlayerTotalCompletedGems() == 0 )
	{
		decayTimeLabel.SetText( "#RANKED_NO_GEMS_DECAY_TIME" )
	}
	else if ( secondsTillNextDecay > secondsTillSeasonEnd )
	{
		decayTimeLabel.SetText( "#RANKED_DECAY_TIME_TOO_LONG" )
	}
	else
	{
		decayTimeLabel.SetColor( 200, 200, 200 )
		decayTimeLabel.SetAutoTextWithAlternates( "#HUDAUTOTEXT_RANKED_DAYS_HOURS", "#HUDAUTOTEXT_RANKED_HOURS_MINUTES", "#HUDAUTOTEXT_RANKED_MINUTES_SECONDS", HATT_UI_COUNTDOWN_DAYS_HOURS_MINUTES_SECONDS, Time() + secondsTillNextDecay )
		if ( secondsTillNextDecay <= SECONDS_PER_HOUR )
			decayTimeLabel.SetColor( 255, 0, 0 )
		else if ( secondsTillNextDecay <= SECONDS_PER_DAY  )
			decayTimeLabel.SetColor( 215, 121, 48 )
	}

	// Current Season
	local seasonLabel = menu.GetChild( "CurrentSeason" )
	local seasonEndHeader = menu.GetChild( "SeasonEndHeader" )
	local currentSeason = GetRankedSeason()
	if ( currentSeason < 1 )
	{
		seasonLabel.SetText( "#RANKED_BETA_SEASON" )
		seasonEndHeader.SetText( "#RANKED_SEASON_END_TIMER_HEADER_BETA" )
	}
	else
	{
		seasonLabel.SetText( "#RANKED_CURRENT_SEASON_NUMBER", currentSeason.tostring() )
		seasonEndHeader.SetText( "#RANKED_SEASON_END_TIMER_HEADER", currentSeason.tostring() )
	}

	// Season End Timer
	local seasonTimer = menu.GetChild( "SeasonEndTimer" )
	seasonTimer.SetAutoTextWithAlternates( "#HUDAUTOTEXT_RANKED_DAYS_HOURS", "#HUDAUTOTEXT_RANKED_HOURS_MINUTES", "#HUDAUTOTEXT_RANKED_MINUTES_SECONDS", HATT_UI_COUNTDOWN_DAYS_HOURS_MINUTES_SECONDS, Time() + secondsTillSeasonEnd )
	if ( secondsTillSeasonEnd <= SECONDS_PER_HOUR )
		seasonTimer.SetColor( 255, 0, 0 )
	else if ( secondsTillSeasonEnd <= SECONDS_PER_DAY  )
		seasonTimer.SetColor( 215, 121, 48 )
	else
		seasonTimer.SetColor( 200, 200, 200 )
}

function RankProgressNavigateLeft(...)
{
	if ( uiGlobal.activeMenu == null || uiGlobal.activeMenu.GetName() != "RankedPlayMenu" )
		return

	local previousRank = GetPreviousRank( file.displayRank )
	if ( previousRank < file.displayRank )
	{
		local menu = GetMenu( "RankedPlayMenu" )
		file.displayRank = previousRank
		RankPanel_ShowRank( menu, file.nextRankPanel, file.displayRank, false )
		thread SwapProgressPanels( menu, -1, file.displayRank )
	}
}

function RankProgressNavigateRight(...)
{
	if ( uiGlobal.activeMenu == null || uiGlobal.activeMenu.GetName() != "RankedPlayMenu" )
		return

	local nextRank = GetNextRank( file.displayRank )
	if ( nextRank > file.displayRank && nextRank <= GetPlayerRank() )
	{
		local menu = GetMenu( "RankedPlayMenu" )
		file.displayRank = nextRank
		RankPanel_ShowRank( menu, file.nextRankPanel, file.displayRank, false )
		thread SwapProgressPanels( menu, 1, file.displayRank )
	}
}

function SwapProgressPanels( menu, direction, rank = null )
{
	// Update buttons
	file.nextRankGamepadHint.Show()
	file.prevRankGamepadHint.Show()
	file.nextRankBtn.Show()
	file.prevRankBtn.Show()
	if ( rank <= 0 )
	{
		file.prevRankGamepadHint.Hide()
		file.prevRankBtn.Hide()
	}
	else if ( rank >= GetPlayerRank() )
	{
		file.nextRankGamepadHint.Hide()
		file.nextRankBtn.Hide()
	}

	// Swap the panels
	local tmpPanel = file.activeRankPanel
	file.activeRankPanel = file.nextRankPanel
	file.nextRankPanel = tmpPanel

	local duration = 0.15

	// Move the old panel away
	local xOffset = file.activeRankPanel.GetWidth() * direction

	file.nextRankPanel.ReturnToBasePos()
	file.activeRankPanel.ReturnToBasePos()
	wait 0.05
	thread FancyLabelFadeOut( menu, file.nextRankPanel, -xOffset, 0, duration, true )
	thread FancyLabelFadeIn( menu, file.activeRankPanel, xOffset, 0, false, duration, true, 0.0, "Menu_GameSummary_ScreenSlideIn" )

	wait duration
}

function ClearRankedPlayDetails()
{
	foreach ( label in file.RankedPlayDetails )
	{
		label.SetText( "" )
	}
}

function OnClick_BtnRanks( button )
{
	Signal( uiGlobal.signalDummy, "StopTips" )
	AdvanceMenu( GetMenu( "RankedTiersMenu" ) )
}

function OnClick_BtnSeasons( button )
{
	Signal( uiGlobal.signalDummy, "StopTips" )
	AdvanceMenu( GetMenu( "RankedSeasonsMenu" ) )
}

function OnClick_BtnSponsorPlayer( button )
{
//	AdvanceMenu( GetMenu( "RankedInviteMenu" ) )

	Signal( uiGlobal.signalDummy, "StopTips" )

	local menuName = "RankedInviteMenu"
	local imageMenu = GetMenu( menuName )
	OpenSubmenu( imageMenu, false )
	UpdateFooterButtons( menuName )
}

function OnClick_BtnRankedGameModes( button )
{
	Signal( uiGlobal.signalDummy, "StopTips" )
	AdvanceMenu( GetMenu( "RankedModesMenu" ) )
}

function OnClick_BtnRankedButton( button )
{
	UpdateMenuRankedButton()
	if ( GetPersistentVar( "ranked.isPlayingRanked" ) )
	{
		ClientCommand( "SetPlayRankedOff" )

		EmitUISound( "UI_Lobby_RankChip_Disable" )

		// Stop tips, replace the header & tips with disabled info
		Signal( uiGlobal.signalDummy, "StopTips" )
		ShowDisabledHeader()
		ShowDisabledTip()
		file.BtnRankedButton.SetText( "#RANKED_GAME_MENU_ENABLE" )
	}
	else
	{
		file.BtnRankedButton.SetText( "#RANKED_GAME_MENU_DISABLE" )
		ClientCommand( "SetPlayRankedOn" )

		// Show the normal header & tips
		ShowEnabledHeader()
		Signal( uiGlobal.signalDummy, "StopTips" )
		thread RankedTips()

		EmitUISound( "UI_Lobby_RankChip_Enable" )

		thread SayChipActive()
	}
}

function OnCloseRankedPlayMenu()
{
	local menu = GetMenu( "RankedPlayMenu" )
	Signal( menu, "StopMenuAnimation" )

	Signal( uiGlobal.signalDummy, "OnCloseRankedPlayMenu" )

	if ( file.buttonsRegistered )
	{
		DeregisterButtonPressedCallback( BUTTON_SHOULDER_LEFT, RankProgressNavigateLeft )
		DeregisterButtonPressedCallback( BUTTON_SHOULDER_RIGHT, RankProgressNavigateRight )
		file.buttonsRegistered = false
	}
}

function UpdateSponsorButton()
{
	local sponsorsRemaining = GetPlayerSponsorshipsRemaining()
	file.BtnSponsorPlayer.SetText( "#RANKED_PLAY_INVITE_BUTTON", sponsorsRemaining )
	file.BtnSponsorPlayer.SetEnabled( sponsorsRemaining > 0 )

	if ( IsQualifiedToSponsor() )
		file.BtnSponsorPlayer.Show()
	else
		file.BtnSponsorPlayer.Hide()
}

function IsQualifiedToSponsor()
{
	switch ( GetRankInviteMode() )
	{
		case "gen10":
			if ( GetPersistentVar( "gen" ) >= MAX_GEN )
				return true
			return false

		case "any":
			return true

		default:
			return false
	}
}

function OnOpenRankedPlayMenu()
{
	if ( !IsFullyConnected() )
		return

	file.BtnSeasons.SetEnabled( GetPreviousSeasonHistorySize() > 0 )

	UpdateSponsorButton()

	local menu = GetMenu( "RankedPlayMenu" )
	file.size = menu.GetSize()
	menu.SetDisplayName( GetRankedPlayMenuTitle() )
	file.MenuTitle.SetText( GetRankedPlayMenuTitle() )

	InitLobbyRankedButton()
	UpdateLobbyRankedButton()
	UpdateMenuRankedButton()
	UpdateTeamInfo( GetMenu( "RankedPlayMenu" ), GetTeam() )
	SetupRankInfo()

	if ( GetPersistentVar( "ranked.isPlayingRanked" ) || level.clickedJoinRankedButton )
	{
		level.clickedJoinRankedButton = false
		ShowEnabledHeader()
		thread RankedTips()
	}
	else
	{
		ShowDisabledHeader()
		ShowDisabledTip()
	}

	if ( !file.buttonsRegistered )
	{
		RegisterButtonPressedCallback( BUTTON_SHOULDER_LEFT, RankProgressNavigateLeft )
		RegisterButtonPressedCallback( BUTTON_SHOULDER_RIGHT, RankProgressNavigateRight )
		file.buttonsRegistered = true
	}
}

function ShowEnabledHeader()
{
	file.header.SetText( "#RANKED_PROGRESS_HEADER" )
	file.header.SetColor( [ 133, 183, 81 ] )
}

function ShowDisabledHeader()
{
	file.header.SetText( "#RANKED_PROGRESS_HEADER_DISABLED" )
	file.header.SetColor( [ 255, 0, 0 ] )
}

function ShowDisabledTip()
{
	file.tipLabels[0].SetText( "#RANKED_PROGRESS_DISABLED_TIP" )
	file.tipLabels[0].SetColor( [ 210, 170, 0 ] )
	file.tipLabels[0].Show()
	file.tipLabels[1].Hide()
}

function SayChipActive()
{
	EndSignal( uiGlobal.signalDummy, "OnCloseRankedPlayMenu" )

	wait 1 // Let the rank chip disable sound breath before speaking

	if ( ( file.chipLastSpokeTime + CHIP_MUTE_TIME ) <= Time() )
	{
		if ( GetPersistentVar( "ranked.isPlayingRanked" ) )
		{
			file.chipLastSpokeTime = Time()
			EmitUISound( "diag_rp_chipEnable_neut_chipai" )
		}
	}
}

function UpdateLobbyRankedButton()
{
	local menu = GetMenu( "LobbyMenu" )
	local button = menu.GetChild( "RankedButton" )

	if ( !PlayerQualifiedForRanked() || !MatchSupportsRankedPlay() )
	{
		button.Hide()
		return
	}

	button.Show()
	button.SetEnabled( true )
	UpdateMenuRankedButton()

	if ( GetPersistentVar( "ranked.joinedRankedPlay" ) )
	{
		button.SetText( GetRankedPlayMenuTitle() )
		button.SetNew( false )
	}
	else
	{
		button.SetNew( !GetPersistentVar( "ranked.viewedRankedPlayIntro" ) )
		button.SetText( "#BC_YOU_HAVE_MAIL" )
	}
}
Globalize( UpdateLobbyRankedButton )

function GetRankedPlayMenuTitle()
{
	if ( !IsFullyConnected() )
		return "#RANKED_MENU_TITLE"

	switch ( GetRankInviteMode() )
	{
		case "gen10":
		case "any":
			return "#RANKED_MENU_TITLE_BETA"
	}

	return "#RANKED_MENU_TITLE"
}

function InitLobbyRankedButton()
{
	UpdateLobbyRankedButton()
}
Globalize( InitLobbyRankedButton )


function UpdateMenuRankedButton()
{
	if ( GetPersistentVar( "ranked.isPlayingRanked" ) )
		file.BtnRankedButton.SetText( "#RANKED_GAME_MENU_DISABLE" )
	else
		file.BtnRankedButton.SetText( "#RANKED_GAME_MENU_ENABLE" )

	file.BtnRankedButton.Show()
}

function ClickedJoinRankedPlay()
{
	level.clickedJoinRankedButton = true
	ClientCommand( "JoinRankedPlay" )
	AdvanceMenu( GetMenu( "RankedPlayMenu" ) )
}
Globalize( ClickedJoinRankedPlay )


function GetAdvocateIntroLines()
{
	if ( GetSponsorName() == null )
	{
		if ( GetGen() >= MAX_GEN )
			return [
				"#RANKED_PLAY_ADVOCATE_LINE0"
				"#RANKED_PLAY_ADVOCATE_LINE1"
				"#RANKED_PLAY_ADVOCATE_LINE2"
				"#RANKED_PLAY_ADVOCATE_LINE3"
				"#GENERATION_RESPAWN_ADVOCATE_LINE6"
				]
		else
			return [
				"#RANKED_PLAY_ADVOCATE_LVL32_LINE0"
				"#RANKED_PLAY_ADVOCATE_LVL32_LINE1"
				"#RANKED_PLAY_ADVOCATE_LVL32_LINE2"
				"#RANKED_PLAY_ADVOCATE_LVL32_LINE3"
				"#GENERATION_RESPAWN_ADVOCATE_LINE6"
				]
	}

	return [
		"#RANKED_PLAY_INVITE_LINE0"
		"#RANKED_PLAY_INVITE_LINE1"
		"#RANKED_PLAY_INVITE_LINE2"
		"#RANKED_PLAY_INVITE_LINE3"
		"#GENERATION_RESPAWN_ADVOCATE_LINE6"
		]
}

function GetSponsorName()
{
	local name = GetPersistentVar( "ranked.mySponsorName" )
	if ( name == "" )
		return null

	return name
}
Globalize( GetSponsorName )

function OpenRankedPlayAdvocateLetter()
{
	local lines = GetAdvocateIntroLines()

	// remove "new"
	ClientCommand( "ViewRankedIntro" )

	// read the intro letter
	if ( GetSponsorName() != null )
	{
		OpenAdvocateLetter( lines, "#RANKED_PLAY_BUTTON_LABEL", ClickedJoinRankedPlay, null, null, 2.5, "../ui/menu/rank_icons/tier_1_1", AddSponsorName )
	}
	else
	{
		OpenAdvocateLetter( lines, "#RANKED_PLAY_BUTTON_LABEL", ClickedJoinRankedPlay, null, null, 2.5, "../ui/menu/rank_icons/tier_1_1" )
	}
}

function AddSponsorName( lines, lineElems )
{
	local sponsor = GetSponsorName()
	if ( sponsor == null )
		return

	local changeLine = 0
	lineElems[changeLine].SetText( lines[changeLine], sponsor )
}

function RankedTips()
{
	EndSignal( uiGlobal.signalDummy, "OnCloseRankedPlayMenu" )
	EndSignal( uiGlobal.signalDummy, "StopTips" )

	local lastTip = null
	foreach( label in file.tipLabels )
	{
		label.ReturnToBasePos()
		label.ReturnToBaseColor()
		label.Hide()
	}

	local moveDist = 0//500
	local moveTime = 0.3
	local displayTime = 10.0

	local menu = GetMenu( "RankedPlayMenu" )
	local currentTipLabel = file.tipLabels[0]
	local nextTipLabel = file.tipLabels[1]


	local tips = []
	tips.append( "#RANKED_TIP_0" )
	tips.append( "#RANKED_TIP_1" )
	tips.append( "#RANKED_TIP_2" )
	tips.append( "#RANKED_TIP_3" )
	if ( RankedAlwaysLoseGem() )
		tips.append( "#RANKED_TIP_4_NO_DAMAGE" )
	else
		tips.append( "#RANKED_TIP_4" )

	tips.append( "#RANKED_TIP_5" )
	tips.append( "#RANKED_TIP_6" )
	tips.append( "#RANKED_TIP_7" )
	tips.append( "#RANKED_TIP_8" )
	tips.append( "#RANKED_TIP_9" )
	tips.append( "#RANKED_TIP_10" )

	if ( IsQualifiedToSponsor() )
	{
		tips.append( "#RANKED_TIP_11" )
	}

	while ( 1 )
	{
		ArrayRandomize( tips )
		for ( local i = 0 ; i < tips.len() ; i++ )
		{
			if ( i == 0 && tips[i] == lastTip )
				continue

			currentTipLabel.SetText( tips[i] )

			thread FancyLabelFadeOut( menu, nextTipLabel, -moveDist, 0, moveTime )
			wait 1
			thread FancyLabelFadeIn( menu, currentTipLabel, moveDist, 0, true, moveTime )
			wait 1
			currentTipLabel.SetAlpha( currentTipLabel.GetBaseAlpha() )

			lastTip = tips[i]
			local tmp = currentTipLabel
			currentTipLabel = nextTipLabel
			nextTipLabel = tmp

			wait displayTime
		}
		wait 0
	}
}