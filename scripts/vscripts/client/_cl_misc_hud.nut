debugFrontlinePos <- Vector( 0, 0, 0 )
debugFrontlineDir <- Vector( 0, 0, 0 )
const DEV_COUNTDOWNTIMER = 0//turn on to see the countdown timer to match starts - helps with lining up intros

function main()
{
	RegisterSignal( "ExitFireteamDroppod" )
	RegisterSignal( "PrematchCountdown" )
	RegisterSignal( "GameStateChanged" )

	Globalize( MiscHUD_AddClient )
	Globalize( MiscHUD_AddPlayer )

	RegisterServerVarChangeCallback( "gameState", GameState_Changed )
	RegisterServerVarChangeCallback( "badRepPresent", UpdateScoreboardBadRepPresentMessage )
	//RegisterServerVarChangeCallback( "switchingSides", SwitchingSides_Changed )
	//RegisterServerVarChangeCallback( "gameStartTime", GameStartTime_Changed )

	Globalize( GameState_Think )

	Globalize( UpdateDpadIcons )
	Globalize( ClearDpadIcon )
	Globalize( ClearDpadButtons )
	Globalize( HideDpadIcon )
	Globalize( ShowDpadIcon )
	Globalize( SetDpadIcon )
	Globalize( SetDpadDesc )
	Globalize( SetDpadTitle )
	Globalize( SetDpadIconColor )
	Globalize( SetDpadCooldown )
	Globalize( SetDpadProgress )
	Globalize( SetDpadProgressColor )
	Globalize( SetDpadProgressFlip )
	Globalize( AlertDpadIcon )

	Globalize( DebugDrawThink )
	Globalize( DebugSetFrontline )
	Globalize( DebugDrawCurrentFrontline )
	Globalize( ToggleDebugDrawFrontline )
	Globalize( ServerCallback_ScreenShake )

	Globalize( ServerCallback_AnnounceWinner )
	Globalize( ServerCallback_AnnounceRoundWinner )

	file.thirtySecondWarningDone <- false
}


function MiscHUD_AddClient( player )
{
	player.InitHudElem( "countdownText" )

	player.cv.gamescomWaitTillReady <- HudElement( "gamescomWaitTillReady" )

	player.cv.waitingForPlayersDesc <- HudElement( "waitingForPlayersText" )
	player.cv.waitingForPlayersLine <- HudElement( "waitingForPlayersLine" )
	player.cv.waitingForPlayersTimer <- HudElement( "waitingForPlayersTimer" )

	player.cv.loadoutButtonText <- HudElement( "LoadOutText" )
	player.cv.loadoutButtonText.SetText( "#MENU_PREMATCH_TEXT" )

	player.cv.loadoutButtonIcon <- HudElement( "LoadOutIcon" )
	player.cv.loadoutButtonIcon.EnableKeyBindingIcons()
	player.cv.loadoutButtonIcon.SetText( "#MENU_PREMATCH_ICON" )

	player.cv.vignette <- HudElement( "Vignette" )
	player.cv.topBar <- HudElement( "prematchTopBar" )
	player.cv.bottomBar <- HudElement( "prematchBottomBar" )
	player.cv.prematchDesc <- HudElement( "prematchCountdownDescText" )
	player.cv.prematchTimer <- HudElement( "prematchCountdownTimerText" )
	player.cv.prematchTimerGlow <- HudElement( "prematchCountdownTimerTextGlow" )
	player.cv.winnerText <- HudElement( "WinScreenText" )
	player.cv.loserText <- HudElement( "LoseScreenText" )

	player.cv.halfTimeText <- HudElement( "halfTimeText" )

	player.cv.spectatorNext <- HudElement( "SpectatorNextPlayer" )
	player.cv.spectatorPrev <- HudElement( "SpectatorPrevPlayer" )

	player.cv.spectatorNext.EnableKeyBindingIcons()
	player.cv.spectatorPrev.EnableKeyBindingIcons()


	local hudGroup 	= HudElementGroup( "timeLimit" )
	player.cv.timeLimitText <- hudGroup.CreateElement( "timeLimitText" )
	player.cv.timeCounterText <- hudGroup.CreateElement( "timeCounterText" )
	player.cv.timeHighlightBox <- hudGroup.CreateElement( "timeHighlightBox" )
	player.cv.timeLimitHud <- hudGroup

	player.cv.lastTimeRemaining <- 0
	player.cv.timeLimitPreviousSecond <- 0

	player.cv.scoreboardBadRepPresentMessage <- HudElement( "ScoreboardBadRepPresentMessage", HudElement( "Scoreboard" ) )
	if ( !Durango_IsDurango() )
		player.cv.scoreboardBadRepPresentMessage.SetText( "#ASTERISK_FAIRFIGHT_CHEATER" )
	else
		player.cv.scoreboardBadRepPresentMessage.SetText( "#ASTERISK_BAD_REPUTATION" )

	player.cv.hudCheaterMessage <- HudElement( "HudCheaterMessage" )
	if ( !Durango_IsDurango() && !IsLobby() && player.HasBadReputation() )
		player.cv.hudCheaterMessage.Show()
	else
		player.cv.hudCheaterMessage.Hide()
}


function MiscHUD_AddPlayer( player )
{
	player.s.dpadIcons <- {}
	player.s.dpadIcons[BUTTON_DPAD_UP] <- "HUD/empty"
	player.s.dpadIcons[BUTTON_DPAD_DOWN] <- "HUD/empty"
	player.s.dpadIcons[BUTTON_DPAD_LEFT] <- "HUD/empty"
	player.s.dpadIcons[BUTTON_DPAD_RIGHT] <- "HUD/empty"

	player.s.dpadBGs <- {}
	player.s.dpadBGs[BUTTON_DPAD_UP] 		<- { progress = 0.0, goalProgress = null, duration = null }
	player.s.dpadBGs[BUTTON_DPAD_DOWN] 		<- { progress = 0.0, goalProgress = null, duration = null }
	player.s.dpadBGs[BUTTON_DPAD_LEFT] 		<- { progress = 0.0, goalProgress = null, duration = null }
	player.s.dpadBGs[BUTTON_DPAD_RIGHT] 	<- { progress = 0.0, goalProgress = null, duration = null }

	player.s.dpadProgressBars <- {}
	player.s.dpadProgressBars[BUTTON_DPAD_UP] 		<- { progress = 0.0, goalProgress = null, duration = null, progressSource = ProgressSource.PROGRESS_SOURCE_SCRIPTED, progressEnt = null, color = [132, 156, 175, 128], bgColor = [0, 0, 0, 0], flip = false }
	player.s.dpadProgressBars[BUTTON_DPAD_DOWN] 	<- { progress = 0.0, goalProgress = null, duration = null, progressSource = ProgressSource.PROGRESS_SOURCE_SCRIPTED, progressEnt = null, color = [132, 156, 175, 128], bgColor = [0, 0, 0, 0], flip = false }
	player.s.dpadProgressBars[BUTTON_DPAD_LEFT] 	<- { progress = 0.0, goalProgress = null, duration = null, progressSource = ProgressSource.PROGRESS_SOURCE_SCRIPTED, progressEnt = null, color = [132, 156, 175, 128], bgColor = [0, 0, 0, 0], flip = false }
	player.s.dpadProgressBars[BUTTON_DPAD_RIGHT] 	<- { progress = 0.0, goalProgress = null, duration = null, progressSource = ProgressSource.PROGRESS_SOURCE_SCRIPTED, progressEnt = null, color = [132, 156, 175, 128], bgColor = [0, 0, 0, 0], flip = false }

	player.s.dpadDescs <- {}
	player.s.dpadDescs[BUTTON_DPAD_UP] <- ""
	player.s.dpadDescs[BUTTON_DPAD_DOWN] <- ""
	player.s.dpadDescs[BUTTON_DPAD_LEFT] <- ""
	player.s.dpadDescs[BUTTON_DPAD_RIGHT] <- ""

	player.s.dpadDescsAuto <- {}
	player.s.dpadDescsAuto[BUTTON_DPAD_UP] <- null
	player.s.dpadDescsAuto[BUTTON_DPAD_DOWN] <- null
	player.s.dpadDescsAuto[BUTTON_DPAD_LEFT] <- null
	player.s.dpadDescsAuto[BUTTON_DPAD_RIGHT] <- null

	player.s.dpadTitles <- {}
	player.s.dpadTitles[BUTTON_DPAD_UP] <- ""
	player.s.dpadTitles[BUTTON_DPAD_DOWN] <- ""
	player.s.dpadTitles[BUTTON_DPAD_LEFT] <- ""
	player.s.dpadTitles[BUTTON_DPAD_RIGHT] <- ""

	player.s.dpadVis <- {}
	player.s.dpadVis[BUTTON_DPAD_UP] <- false
	player.s.dpadVis[BUTTON_DPAD_DOWN] <- false
	player.s.dpadVis[BUTTON_DPAD_LEFT] <- false
	player.s.dpadVis[BUTTON_DPAD_RIGHT] <- false

	player.s.dpadColors <- {}
	player.s.dpadColors[BUTTON_DPAD_UP] <- [255,255,255,255]
	player.s.dpadColors[BUTTON_DPAD_DOWN] <- [255,255,255,255]
	player.s.dpadColors[BUTTON_DPAD_LEFT] <- [255,255,255,255]
	player.s.dpadColors[BUTTON_DPAD_RIGHT] <- [255,255,255,255]

	//player.s.epilogue <- epilogue
	player.s.debugDrawFrontline <- false

	player.InitHudElem( "TitanShoulderTurretMissileLockReticle" )
}


function ClearDpadButtons( player )
{
	local dpadButtons = [BUTTON_DPAD_UP, BUTTON_DPAD_DOWN, BUTTON_DPAD_LEFT, BUTTON_DPAD_RIGHT]

	foreach ( dpadButton in dpadButtons )
	{
		SetDpadIcon( player, dpadButton, "hud/empty" )
		SetDpadTitle( player, dpadButton, "" )
		SetDpadDesc( player, dpadButton, "" )

		HideDpadIcon( player, dpadButton )
	}
}


function UpdateDpadIcons( player )
{
	if ( player != GetLocalViewPlayer() )
		return

	SetDpadIcon( player, BUTTON_DPAD_UP, player.s.dpadIcons[BUTTON_DPAD_UP] )
	SetDpadIcon( player, BUTTON_DPAD_DOWN, player.s.dpadIcons[BUTTON_DPAD_DOWN] )
	SetDpadIcon( player, BUTTON_DPAD_LEFT, player.s.dpadIcons[BUTTON_DPAD_LEFT] )
	SetDpadIcon( player, BUTTON_DPAD_RIGHT, player.s.dpadIcons[BUTTON_DPAD_RIGHT] )

	SetDpadCooldown( player, BUTTON_DPAD_DOWN, player.s.dpadBGs[BUTTON_DPAD_DOWN].progress, player.s.dpadBGs[BUTTON_DPAD_DOWN].goalProgress, player.s.dpadBGs[BUTTON_DPAD_DOWN].duration )
	SetDpadProgress( player, BUTTON_DPAD_DOWN, player.s.dpadProgressBars[BUTTON_DPAD_DOWN].progress, player.s.dpadProgressBars[BUTTON_DPAD_DOWN].goalProgress, player.s.dpadProgressBars[BUTTON_DPAD_DOWN].duration, player.s.dpadProgressBars[BUTTON_DPAD_DOWN].progressSource )
	SetDpadProgressColor( player, BUTTON_DPAD_DOWN, player.s.dpadProgressBars[BUTTON_DPAD_DOWN].color, player.s.dpadProgressBars[BUTTON_DPAD_DOWN].bgColor )
	SetDpadProgressFlip( player, BUTTON_DPAD_DOWN, player.s.dpadProgressBars[BUTTON_DPAD_DOWN].flip )

	SetDpadDesc( player, BUTTON_DPAD_UP, player.s.dpadDescs[BUTTON_DPAD_UP], player.s.dpadDescsAuto[BUTTON_DPAD_UP] )
	SetDpadDesc( player, BUTTON_DPAD_DOWN, player.s.dpadDescs[BUTTON_DPAD_DOWN], player.s.dpadDescsAuto[BUTTON_DPAD_DOWN] )
	SetDpadDesc( player, BUTTON_DPAD_LEFT, player.s.dpadDescs[BUTTON_DPAD_LEFT], player.s.dpadDescsAuto[BUTTON_DPAD_LEFT] )
	SetDpadDesc( player, BUTTON_DPAD_RIGHT, player.s.dpadDescs[BUTTON_DPAD_RIGHT], player.s.dpadDescsAuto[BUTTON_DPAD_RIGHT] )

	SetDpadTitle( player, BUTTON_DPAD_UP, player.s.dpadTitles[BUTTON_DPAD_UP] )
	SetDpadTitle( player, BUTTON_DPAD_DOWN, player.s.dpadTitles[BUTTON_DPAD_DOWN] )
	SetDpadTitle( player, BUTTON_DPAD_LEFT, player.s.dpadTitles[BUTTON_DPAD_LEFT] )
	SetDpadTitle( player, BUTTON_DPAD_RIGHT, player.s.dpadTitles[BUTTON_DPAD_RIGHT] )

	SetDpadIconColor( player, BUTTON_DPAD_UP, player.s.dpadColors[BUTTON_DPAD_UP] )
	SetDpadIconColor( player, BUTTON_DPAD_DOWN, player.s.dpadColors[BUTTON_DPAD_DOWN] )
	SetDpadIconColor( player, BUTTON_DPAD_LEFT, player.s.dpadColors[BUTTON_DPAD_LEFT] )
	SetDpadIconColor( player, BUTTON_DPAD_RIGHT, player.s.dpadColors[BUTTON_DPAD_RIGHT] )

	if ( IsWatchingKillReplay() )
		return

	foreach ( dpadButton, state in player.s.dpadVis )
	{
		if ( state )
			ShowDpadIcon( player, dpadButton )
		else
			HideDpadIcon( player, dpadButton )
	}
}


function AlertDpadIcon( player, dpadButton, numPings = 3, numCycles = 1, colorOverride = null )
{
	local cockpit = player.GetCockpit()
	if ( !IsValid( cockpit ) || !("dpadIcons" in cockpit.s) )
		return

	thread AlertDpadIcon_Internal( player, cockpit, dpadButton, numPings, numCycles, colorOverride )
}

const ALERT_ICON_ANIMRATE = 0.35
const ALERT_ICON_SCALE = 3.0
function AlertDpadIcon_Internal( player, cockpit, dpadButton, numPings, numCycles, colorOverride )
{
	cockpit.EndSignal( "OnDestroy" )

	local alertIcon = cockpit.s.dpadAlerts[dpadButton]
	local dpadIcon = cockpit.s.dpadIcons[dpadButton]

	alertIcon.Show()

	alertIcon.SetImage( player.s.dpadIcons[dpadButton] )

	for ( local cycleId = 0; cycleId < numCycles; cycleId++ )
	{
		for ( local i = 0; i < numPings; i++ )
		{
			if ( colorOverride )
				alertIcon.SetColor( colorOverride[0], colorOverride[1], colorOverride[2], colorOverride[3] )
			else
				alertIcon.ReturnToBaseColor()
			alertIcon.ReturnToBaseSize()
			alertIcon.ColorOverTime( 0, 0, 0, 0, ALERT_ICON_ANIMRATE, INTERPOLATOR_DEACCEL )
			alertIcon.ScaleOverTime( ALERT_ICON_SCALE, ALERT_ICON_SCALE, ALERT_ICON_ANIMRATE, INTERPOLATOR_DEACCEL )
			//alertIcon.FadeOverTime( 0, ALERT_ICON_ANIMRATE, INTERPOLATOR_DEACCEL )

			dpadIcon.SetColor( 0, 0, 0, 0 )
			dpadIcon.ColorOverTime( 255, 255, 255, 255, ALERT_ICON_ANIMRATE, INTERPOLATOR_DEACCEL )

			wait ALERT_ICON_ANIMRATE + 0.1
		}
	}

	alertIcon.Hide()
}


function HideDpadIcon( player, dpadButton )
{
	player.s.dpadVis[dpadButton] = false

	local cockpit = player.GetCockpit()
	if ( !IsValid( cockpit ) || !("dpadIcons" in cockpit.s) )
		return

	cockpit.s.dpadIcons[dpadButton].Hide()
	cockpit.s.dpadDescs[dpadButton].Hide()
	cockpit.s.dpadTitles[dpadButton].Hide()
	cockpit.s.dpadHints[dpadButton].Hide()
	if ( cockpit.s.dpadBGs[dpadButton] )
		cockpit.s.dpadBGs[dpadButton].Hide()
}


function ShowDpadIcon( player, dpadButton )
{
	Assert( player == GetLocalViewPlayer(), "Not local view player!" )
	player.s.dpadVis[dpadButton] = true

	local cockpit = player.GetCockpit()
	if ( !IsValid( cockpit ) || !("dpadIcons" in cockpit.s) )
		return

	cockpit.s.dpadIcons[dpadButton].Show()
	cockpit.s.dpadDescs[dpadButton].Show()
	cockpit.s.dpadTitles[dpadButton].Show()
	cockpit.s.dpadHints[dpadButton].Show()

	if ( cockpit.s.dpadBGs[dpadButton] )
		cockpit.s.dpadBGs[dpadButton].Show()
}


function SetDpadIconColor( player, dpadButton, colorArray )
{
	Assert( dpadButton in player.s.dpadIcons )
	player.s.dpadColors[dpadButton] = colorArray

	local cockpit = player.GetCockpit()
	if ( IsValid( cockpit ) && "dpadIcons" in cockpit.s )
		cockpit.s.dpadIcons[dpadButton].SetColor( colorArray )
}


function ClearDpadIcon( player, dpadButton )
{
	Assert( dpadButton in player.s.dpadIcons )

	SetDpadIcon( player, dpadButton, null )
	SetDpadDesc( player, dpadButton, null )
}


function SetDpadIcon( player, dpadButton, image )
{
	Assert( dpadButton in player.s.dpadIcons )

	if ( !image )
		image = "HUD/empty"

	player.s.dpadIcons[dpadButton] = image

	local cockpit = player.GetCockpit()
	if ( IsValid( cockpit ) && "dpadIcons" in cockpit.s )
		cockpit.s.dpadIcons[dpadButton].SetImage( image )
}


function SetDpadCooldown( player, dpadButton, progress, goalProgress = null, duration = null )
{
	Assert( dpadButton in player.s.dpadIcons )

	player.s.dpadBGs[dpadButton] = { progress = progress, goalProgress = goalProgress, duration = duration }

	local cockpit = player.GetCockpit()
	if ( IsValid( cockpit ) && "dpadIcons" in cockpit.s )
	{
		if ( goalProgress == null && duration == null )
			cockpit.s.dpadBGs[dpadButton].SetBarProgress( progress )
		else if ( duration == null )
			cockpit.s.dpadBGs[dpadButton].SetBarProgressAndRate( 1 - progress, 1 - goalProgress )
		else
			cockpit.s.dpadBGs[dpadButton].SetBarProgressOverTime( 1 - progress, 1 - goalProgress, duration )
	}
}


function SetDpadProgress( player, dpadButton, progress, goalProgress = null, duration = null, progressSource = ProgressSource.PROGRESS_SOURCE_SCRIPTED, progressEnt = null )
{
	Assert( dpadButton in player.s.dpadIcons )

	local color = player.s.dpadProgressBars[dpadButton].color
	local bgColor = player.s.dpadProgressBars[dpadButton].bgColor
	local flip = player.s.dpadProgressBars[dpadButton].flip
	player.s.dpadProgressBars[dpadButton] = { progress = progress, goalProgress = goalProgress, duration = duration, progressSource = progressSource, progressEnt = progressEnt, color = color, bgColor = bgColor, flip = flip }

	local cockpit = player.GetCockpit()
	if ( IsValid( cockpit ) && "dpadIcons" in cockpit.s )
	{
		if ( progressSource != ProgressSource.PROGRESS_SOURCE_SCRIPTED )
		{
			cockpit.s.dpadProgressBars[dpadButton].SetBarProgressSourceEntity( progressEnt )
			cockpit.s.dpadProgressBars[dpadButton].SetBarProgressSource( progressSource )
		}
		else
		{
			cockpit.s.dpadProgressBars[dpadButton].SetBarProgressSourceEntity( null )
			cockpit.s.dpadProgressBars[dpadButton].SetBarProgressSource( progressSource )

			if ( goalProgress == null && duration == null )
				cockpit.s.dpadProgressBars[dpadButton].SetBarProgress( progress )
			else if ( duration == null )
				cockpit.s.dpadProgressBars[dpadButton].SetBarProgressAndRate( progress, goalProgress )
			else
				cockpit.s.dpadProgressBars[dpadButton].SetBarProgressOverTime( progress, goalProgress, duration )
		}
	}
}



function SetDpadProgressColor( player, dpadButton, color, bgColor )
{
	Assert( dpadButton in player.s.dpadIcons )

	player.s.dpadProgressBars[dpadButton].color = color
	player.s.dpadProgressBars[dpadButton].bgColor = bgColor

	local cockpit = player.GetCockpit()
	if ( IsValid( cockpit ) && "dpadIcons" in cockpit.s )
	{
		cockpit.s.dpadProgressBars[dpadButton].SetColor( color[0], color[1], color[2], color[3] )
		cockpit.s.dpadProgressBars[dpadButton].SetColorBG( bgColor[0], bgColor[1], bgColor[2], bgColor[3] )
	}
}


function SetDpadProgressFlip( player, dpadButton, state )
{
	Assert( dpadButton in player.s.dpadIcons )

	player.s.dpadProgressBars[dpadButton].flip = state

	local cockpit = player.GetCockpit()
	if ( IsValid( cockpit ) && "dpadIcons" in cockpit.s )
	{
		if ( state )
			cockpit.s.dpadProgressBars[dpadButton].SetBarProgressRemap( 0.0, 1.0, 1.0, 0.0 )
		else
			cockpit.s.dpadProgressBars[dpadButton].SetBarProgressRemap( 0.0, 1.0, 0.0, 1.0 )
	}
}


function SetDpadTitle( player, dpadButton, text )
{
	Assert( dpadButton in player.s.dpadTitles )

	if ( !text )
		text = ""

	player.s.dpadTitles[dpadButton] = text

	local cockpit = player.GetCockpit()
	if ( IsValid( cockpit ) && "dpadIcons" in cockpit.s )
		cockpit.s.dpadTitles[dpadButton].SetText( text )
}

function ServerCallback_ScreenShake( amplitude, frequency, duration, direction = Vector( 0,0,0 ) )
{
	ClientScreenShake( amplitude, frequency, duration, direction )
}

function SetDpadDesc( player, dpadButton, text, autoTime = null )
{
	Assert( dpadButton in player.s.dpadDescs )

	if ( !text )
		text = ""

	player.s.dpadDescs[dpadButton] = text

	player.s.dpadDescsAuto[dpadButton] = autoTime

	local cockpit = player.GetCockpit()
	if ( IsValid( cockpit ) && "dpadIcons" in cockpit.s )
	{
		if ( player.s.dpadDescsAuto[dpadButton] )
		{
			Assert( type( autoTime ) == "integer" || type( autoTime ) == "float" )
			cockpit.s.dpadDescs[dpadButton].SetAutoText( "", HATT_COUNTDOWN_TIME, player.s.dpadDescsAuto[dpadButton] )
		}
		else
		{
			// HACK; this thing doesn't like having DisableAutoText called on it unless auto text was enabled
			cockpit.s.dpadDescs[dpadButton].SetAutoText( "", HATT_COUNTDOWN_TIME, 0.0 )
			cockpit.s.dpadDescs[dpadButton].DisableAutoText()
			cockpit.s.dpadDescs[dpadButton].SetText( text )
		}
	}
}


function GameState_Think()
{
	local player = GetLocalClientPlayer()

	switch( GetGameState() )
	{
		case eGameState.WaitingForPlayers:
			GameStateThink_WaitingForPlayers( player )
			break

		case eGameState.PickLoadout:
			GameStateThink_PickLoadOut( player )
			break

		case eGameState.Prematch:
			GameStateThink_Prematch( player )
			break

		case eGameState.Playing:
			GameStateThink_Playing( player )
			break

		case eGameState.SwitchingSides:
			GameStateThink_SwitchingSides( player )
			break

		case eGameState.Postmatch:
			GameStateThink_Postmatch( player )
			break
	}
}


function GameStateThink_Prematch( player )
{
	//removing countdown timer all together
	if ( !DEV_COUNTDOWNTIMER )
		return

	local timeRemaining = ceil( level.nv.gameStartTime - Time() )

	player.cv.prematchTimer.Show()
	player.cv.prematchTimerGlow.Show()
	player.cv.prematchDesc.Show()

	player.cv.prematchTimer.SetText( timeRemaining.tostring() )
	player.cv.prematchTimerGlow.SetText( timeRemaining.tostring() )

	// NO MORE SOUND OF COUNTDOWN DURING AWESOME INTROS
	//	if ( player.s.lastTimeRemaining && timeRemaining != player.s.lastTimeRemaining )
	//		EmitSoundOnEntity( player, WAITING_FOR_PLAYERS_COUNTDOWN_SOUND )
	//	player.s.lastTimeRemaining = timeRemaining
}

function GameStateThink_WaitingForPlayers( player )
{
	local reservedCount = GetTeamPendingPlayersReserved( TEAM_MILITIA ) + GetTeamPendingPlayersReserved( TEAM_IMC )
	local connectingCount = GetTeamPendingPlayersConnecting( TEAM_MILITIA ) + GetTeamPendingPlayersConnecting( TEAM_IMC )
	local loadingCount = GetTeamPendingPlayersLoading( TEAM_MILITIA ) + GetTeamPendingPlayersLoading( TEAM_IMC )
	local connectedCount = GetPlayerArray().len()
	local allKnownPlayersCount = reservedCount + connectingCount + loadingCount + connectedCount

	local minPlayers = GetCurrentPlaylistVarInt( "min_players", 0 )

	local expectedPlayers = max( minPlayers, allKnownPlayersCount )

	if ( Time() <= level.nv.connectionTimeout )
	{
		local timeRemainingFloat = level.nv.connectionTimeout - Time()
		local timeRemaining = ceil( timeRemainingFloat )

		player.cv.waitingForPlayersDesc.SetText( "#HUD_WAITING_FOR_PLAYERS", connectedCount, expectedPlayers, timeRemaining )
		player.cv.waitingForPlayersDesc.Show()

		if ( player.cv.lastTimeRemaining && timeRemaining != player.cv.lastTimeRemaining )
			EmitSoundOnEntity( player, WAITING_FOR_PLAYERS_COUNTDOWN_SOUND )

		player.cv.lastTimeRemaining = timeRemaining
	}
	else
	{
		player.cv.waitingForPlayersDesc.SetText( "#HUD_WAITING_FOR_PLAYERS", connectedCount, expectedPlayers, "" )
		player.cv.waitingForPlayersDesc.Show()
	}
}

function GameStateThink_PickLoadOut( player )
{
	if ( GetClassicMPMode() && level.classicMP_Client_GameStateThinkFunc_PickLoadOut )
		ClassicMP_Client_CallGameStateThinkFunc_PickLoadOut( player )
}

function GameStateThink_Playing( player )
{
	local endTime
	if ( IsRoundBased() )
		endTime = level.nv.roundEndTime
	else
		endTime = level.nv.gameEndTime

	if ( !endTime )
		return

	if ( Time() > endTime )
		return

	if ( endTime - Time() > 30.0 )
		return

	if ( file.thirtySecondWarningDone )
		return

	if ( IsTrainingLevel() )
		return

	if ( IsRoundBased() )
		SetTimedEventNotificationHATT( 4.0, "#GAMEMODE_ROUND_END_IN_N_SECONDS", HATT_GAME_COUNTDOWN_SECONDS_MILLISECONDS, endTime )
	else if ( IsSwitchSidesBased() && !HasSwitchedSides() )
		SetTimedEventNotificationHATT( 4.0, "#GAMEMODE_HALFTIME_IN_N_SECONDS", HATT_GAME_COUNTDOWN_SECONDS_MILLISECONDS, endTime )
	else
		SetTimedEventNotificationHATT( 4.0, "#GAMEMODE_END_IN_N_SECONDS", HATT_GAME_COUNTDOWN_SECONDS_MILLISECONDS, endTime )

	file.thirtySecondWarningDone = true
}

function GameStateThink_Postmatch( player )
{
	player.cv.topBar.Show()
	player.cv.bottomBar.Show()
}

function GameStateThink_SwitchingSides( player )
{
	player.cv.vignette.SetColor( 0, 0, 0, 255 )
	player.cv.vignette.Show()
}


function GameState_Changed()
{
	local player = GetLocalClientPlayer()
	player.Signal( "GameStateChanged" )

	switch ( GetGameState() )
	{
		case eGameState.WaitingForCustomStart:
			player.cv.gamescomWaitTillReady.Show()
			break

		case eGameState.WaitingForPlayers:
			player.cv.gamescomWaitTillReady.Hide()
			ClientSetScreenColor( 0, 0, 0, 255 )  //Set screen to black

			player.cv.waitingForPlayersDesc.SetText( "#HUD_WAITING_FOR_PLAYERS_BASIC" )
			player.cv.waitingForPlayersDesc.Show()
			player.cv.waitingForPlayersLine.Show()
			player.cv.waitingForPlayersTimer.Show()
			break

		case eGameState.PickLoadout:
			ClientSetScreenColor( 0, 0, 0, 255 )  //Set screen to black

			if ( GetClassicMPMode() && level.classicMP_Client_GameStateEnterFunc_PickLoadOut )
				ClassicMP_Client_CallGameStateEnterFunc_PickLoadOut( player )

			break

		case eGameState.Prematch:
			RemoveAllRagdolls()
			ClearEventNotification()

			SetCrosshairPriorityState( crosshairPriorityLevel.PREMATCH, CROSSHAIR_STATE_HIDE_ALL )

			if ( !( player.GetCinematicEventFlags() & CE_FLAG_INTRO ) )
				ClientScreenFadeFromBlack( 1.0, 0 )
			else
				ClientScreenFadeFromBlack() //Default, fade out over 2 seconds

			player.cv.waitingForPlayersDesc.HideOverTime( 0.25 )
			player.cv.waitingForPlayersLine.HideOverTime( 0.25 )
			player.cv.waitingForPlayersTimer.HideOverTime( 0.25 )

			player.cv.topBar.SetAlpha( 255 )
			player.cv.bottomBar.SetAlpha( 255 )
			player.cv.topBar.Show()
			player.cv.bottomBar.Show()

			player.cv.loadoutButtonText.SetAlpha( 255 )
			player.cv.loadoutButtonIcon.SetAlpha( 255 )
			player.cv.loadoutButtonText.Show()
			player.cv.loadoutButtonIcon.Show()

			player.cv.prematchTimer.SetAlpha( 255 )
			player.cv.prematchTimerGlow.SetAlpha( 255 )
			player.cv.prematchDesc.SetAlpha( 255 )

			HideSpectatorSelectButtons( player )

			file.thirtySecondWarningDone = false

			level.ent.Signal( "AnnoucementPurge" )
			break

		case eGameState.Playing:
			ClearCrosshairPriority( crosshairPriorityLevel.PREMATCH )
			player.cv.vignette.HideOverTime( 0.25 )
			player.cv.topBar.HideOverTime( 0.25 )
			player.cv.bottomBar.HideOverTime( 0.25 )
			player.cv.prematchTimer.HideOverTime( 0.25 )
			player.cv.prematchTimerGlow.HideOverTime( 0.25 )
			player.cv.prematchDesc.HideOverTime( 0.25 )

			player.cv.loadoutButtonText.HideOverTime( 0.25 )
			player.cv.loadoutButtonIcon.HideOverTime( 0.25 )

			ShowScriptHUD( player )
			break

		case eGameState.SuddenDeath:
			local announcement = CAnnouncement( "#GAMEMODE_ANNOUNCEMENT_SUDDEN_DEATH" )

			switch ( GAMETYPE )
			{
				case CAPTURE_THE_FLAG:
					announcement.SetSubText( "#GAMEMODE_ANNOUNCEMENT_SUDDEN_DEATH_CTF" )
					break

				case TEAM_DEATHMATCH:
					announcement.SetSubText( "#GAMEMODE_ANNOUNCEMENT_SUDDEN_DEATH_TDM" )
					break

				default:
					announcement.SetSubText( "" )
			}

			announcement.SetHideOnDeath( false )
			announcement.SetDuration( 7.0 )
			announcement.SetPurge( true )
			AnnouncementFromClass( player, announcement )
			SmartGlass_SendEvent( "SuddenDeath", "", "", "" )
			break

		case eGameState.WinnerDetermined:
			player.cv.topBar.SetAlpha( 0 )
			player.cv.bottomBar.SetAlpha( 0 )
			break

		case eGameState.Epilogue:
			player.cv.topBar.HideOverTime( 0.25 )
			player.cv.bottomBar.HideOverTime( 0.25 )

			player.cv.winnerText.HideOverTime( 0.25 )
			player.cv.loserText.HideOverTime( 0.25 )

			thread MainHud_Outro( level.nv.winningTeam )
			break

		case eGameState.SwitchingSides:
			local announcement = CAnnouncement( "#GAMESTATE_HALFTIME" )
			announcement.SetSubText( "#GAMESTATE_SWITCHING_SIDES" )
			announcement.SetHideOnDeath( false )
			announcement.SetDuration( 7.0 )
			announcement.SetPurge( true )

			local friendlyTeam = player.GetTeam()
			local enemyTeam = friendlyTeam == TEAM_IMC ? TEAM_MILITIA : TEAM_IMC

			if ( friendlyTeam == TEAM_IMC )
			{
				announcement.SetLeftIcon( TEAM_ICON_IMC )
				announcement.SetRightIcon( TEAM_ICON_MILITIA )
			}
			else
			{
				announcement.SetLeftIcon( TEAM_ICON_MILITIA )
				announcement.SetRightIcon( TEAM_ICON_IMC )
			}

			if ( IsRoundBased() )
			{
				announcement.SetSubText2( "#GAMEMODE_ROUND_WIN_CONDITION", GetRoundScoreLimit_FromPlaylist() )
				// should be GetTeamScore2, but there are UI bugs so we just dupe round score to score.
				announcement.SetLeftText( "#GAMEMODE_JUST_THE_SCORE", GameRules.GetTeamScore( friendlyTeam ) )
				announcement.SetRightText( "#GAMEMODE_JUST_THE_SCORE", GameRules.GetTeamScore( enemyTeam ) )
			}
			else
			{
				announcement.SetLeftText( "#GAMEMODE_JUST_THE_SCORE", GameRules.GetTeamScore( friendlyTeam ) )
				announcement.SetRightText( "#GAMEMODE_JUST_THE_SCORE", GameRules.GetTeamScore( enemyTeam ) )
			}

			AnnouncementFromClass( player, announcement )

			SmartGlass_SendEvent( "SwitchingSides", "", "", "" )

			break

		case eGameState.Postmatch:
			//HACK - shouldn't have to do this - but then again, shouldn't be setting cvar's in script
			//wait for scoreboard to be up
			delaythread( 1.5 ) CE_ResetVisualSettings( GetLocalViewPlayer() )
			break
	}
}

function ShouldHideTimeLimitHudElements()
{
	if ( GetGameState() > eGameState.WinnerDetermined )
		return true

	if ( IsRoundBased() && !GetRoundTimeLimit_ForGameMode() )
		return true

	if ( !IsRoundBased() && !GetTimeLimit_ForGameMode() )
		return true

	return false
}




function SwitchingSides_Changed()
{
	if ( IsMenuLevel() )
		return

	thread SwitchingSides_Changed_threaded()
}

function SwitchingSides_Changed_threaded()
{
	local player = GetLocalViewPlayer()

	if ( level.nv.switchingSides )
	{
		player.cv.halfTimeText.SetText( "Test - Switching Sides" )
		player.cv.halfTimeText.Show()
		wait 1.5
	}
	else
	{
		player.cv.halfTimeText.Hide()

	}

}


function ServerCallback_AnnounceWinner( teamIndex, subStringIndex, winnerDeterminedWait )
{
	local player = GetLocalClientPlayer()

	local subString = ""
	if ( subStringIndex )
		subString = GetStringFromID( subStringIndex )

	if ( !level.nv.winningTeam )
	{
		local outcomeAnnouncement = CAnnouncement( "#GAMEMODE_DRAW" )
		outcomeAnnouncement.SetSubText( subString )
		outcomeAnnouncement.SetTitleColor( [255, 255, 100] )
		outcomeAnnouncement.SetHideOnDeath( false )
		outcomeAnnouncement.SetDuration( winnerDeterminedWait )
		outcomeAnnouncement.SetPurge( true )
		AnnouncementFromClass( player, outcomeAnnouncement )

		SmartGlass_SendEvent( "MatchDraw", "", "", "" )
	}
	else if ( player.GetTeam() == level.nv.winningTeam )
	{
		local outcomeAnnouncement = CAnnouncement( "#GAMEMODE_VICTORY" )
		outcomeAnnouncement.SetSubText( subString )
		outcomeAnnouncement.SetTitleColor( [100, 255, 100] )
		outcomeAnnouncement.SetHideOnDeath( false )
		outcomeAnnouncement.SetDuration( winnerDeterminedWait )
		outcomeAnnouncement.SetPurge( true )
		AnnouncementFromClass( player, outcomeAnnouncement )

		SmartGlass_SendEvent( "MatchVictory", "", "", "" )
	}
	else if ( level.nv.winningTeam != TEAM_UNASSIGNED )
	{
		local outcomeAnnouncement = CAnnouncement( "#GAMEMODE_DEFEATED" )
		outcomeAnnouncement.SetSubText( subString )
		outcomeAnnouncement.SetTitleColor( [255, 100, 100] )
		outcomeAnnouncement.SetHideOnDeath( false )
		outcomeAnnouncement.SetDuration( winnerDeterminedWait )
		outcomeAnnouncement.SetPurge( true )
		AnnouncementFromClass( player, outcomeAnnouncement )

		SmartGlass_SendEvent( "MatchDefeat", "", "", "" )
	}

	if( PlayerPlayingRanked( player ) )
	{
		Ranked_WinnerDetermined()
	}
}

function ServerCallback_AnnounceRoundWinner( teamIndex, subStringIndex, winnerDeterminedWait, imcTeamScore2, militiaTeamScore2 )
{
	local subString = ""
	if ( subStringIndex )
		subString = GetStringFromID( subStringIndex )

	local player = GetLocalClientPlayer()

	// ANNOUNCEMENT_FLICKER_BUFFER Ensures that the INTERPOLATOR_FLICKER animation is played before the message is hidden in
	// AnnouncementMessage_DisplayOnHud(). I'm not certain why this is needed. There may be a delay before
	// ServerCallback_AnnounceRoundWinner is actually received and/or the hud fades may be framerate
	// dependent (they don't seem to play nice with timescale), or it could be something much more simple that I'm missing.
	const ANNOUNCEMENT_FLICKER_BUFFER = 0.2

	local announcementDuration = winnerDeterminedWait - ANNOUNCEMENT_FLICKER_BUFFER
	local subtext2IconDelay = winnerDeterminedWait - 4.5
	local conversationDelay = subtext2IconDelay + 1.5 // Bit of time to give it to breathe, and to let RoundWinningKillReplay be fully over before starting the conversation.

	if ( !level.nv.winningTeam )
	{
		local outcomeAnnouncement = CAnnouncement( "#GAMEMODE_ROUND_DRAW" )
		outcomeAnnouncement.SetSubText( subString )
		outcomeAnnouncement.SetTitleColor( [255, 255, 100] )
		outcomeAnnouncement.SetHideOnDeath( false )
		outcomeAnnouncement.SetPurge( true )
		outcomeAnnouncement.SetDuration( announcementDuration)

		ShowRoundScoresInAnnouncement( outcomeAnnouncement, subtext2IconDelay, imcTeamScore2, militiaTeamScore2 )
		AnnouncementFromClass( player, outcomeAnnouncement )

		SmartGlass_SendEvent( "RoundDraw", "", "", "" )
	}
	else if ( player.GetTeam() == level.nv.winningTeam )
	{
		local outcomeAnnouncement = CAnnouncement( "#GAMEMODE_ROUND_WIN" )
		outcomeAnnouncement.SetSubText( subString )
		outcomeAnnouncement.SetTitleColor( [100, 255, 100] )
		outcomeAnnouncement.SetHideOnDeath( false )
		outcomeAnnouncement.SetPurge( true )
		outcomeAnnouncement.SetDuration( announcementDuration)

		ShowRoundScoresInAnnouncement( outcomeAnnouncement, subtext2IconDelay, imcTeamScore2, militiaTeamScore2 )
		thread PlayRoundWonConversationWithAnnouncementDelay( conversationDelay )

		AnnouncementFromClass( player, outcomeAnnouncement )

		SmartGlass_SendEvent( "RoundVictory", "", "", "" )
	}
	else if ( level.nv.winningTeam != TEAM_UNASSIGNED )
	{
		local outcomeAnnouncement = CAnnouncement( "#GAMEMODE_ROUND_LOSS" )
		outcomeAnnouncement.SetSubText( subString )
		outcomeAnnouncement.SetTitleColor( [255, 100, 100] )
		outcomeAnnouncement.SetHideOnDeath( false )
		outcomeAnnouncement.SetPurge( true )
		outcomeAnnouncement.SetDuration( announcementDuration)

		ShowRoundScoresInAnnouncement( outcomeAnnouncement, subtext2IconDelay, imcTeamScore2, militiaTeamScore2 )
		thread PlayRoundWonConversationWithAnnouncementDelay( conversationDelay )

		AnnouncementFromClass( player, outcomeAnnouncement )

		SmartGlass_SendEvent( "RoundDefeat", "", "", "" )
	}
}

//Note that RoundWinningKillReplay doesn't send imcTeamScore2 and militiaTeamScore2 overrides.
function ShowRoundScoresInAnnouncement( outcomeAnnouncement, subtext2IconDelay, imcTeamScore2 = null, militiaTeamScore2 = null )
{
	local player = GetLocalClientPlayer()

	local friendlyTeam = player.GetTeam()
	local enemyTeam = friendlyTeam == TEAM_IMC ? TEAM_MILITIA : TEAM_IMC

	local leftIcon
	local rightIcon

	if ( friendlyTeam == TEAM_IMC )
	{
		leftIcon = TEAM_ICON_IMC
		rightIcon = TEAM_ICON_MILITIA
	}
	else
	{
		leftIcon = TEAM_ICON_MILITIA
		rightIcon = TEAM_ICON_IMC
	}

	if ( level.nv.roundScoreLimitComplete == true ) //Generally this is never true except for modes with RoundWinningKillReplay enabled
	{
		if ( friendlyTeam == level.nv.winningTeam )
		{
			outcomeAnnouncement.SetSubText( "#GAMEMODE_MATCH_WON_BY_FRIENDLY_TEAM" )
			local friendlyTeamString = friendlyTeam == TEAM_IMC ? "#TEAM_IMC" : "#TEAM_MCOR"
			outcomeAnnouncement.SetOptionalSubTextArgsArray( [ friendlyTeamString ] )
		}
		else if ( enemyTeam == level.nv.winningTeam )
		{
			outcomeAnnouncement.SetSubText( "#GAMEMODE_MATCH_WON_BY_ENEMY_TEAM" )
			local enemyTeamString = enemyTeam == TEAM_IMC ? "#TEAM_IMC" : "#TEAM_MCOR"
			outcomeAnnouncement.SetOptionalSubTextArgsArray( [ enemyTeamString ] )
		}

	}
	else
	{
		outcomeAnnouncement.SetSubText2( "#GAMEMODE_ROUND_WIN_CONDITION", GetRoundScoreLimit_FromPlaylist() )
		outcomeAnnouncement.SetSubText2AndIconDelay( subtext2IconDelay )
	}

	//Hack: GetTeamScore2 doesn't work mid-kill replay because we get the rewound values as opposed to the current values.
	//Fix for R2 when we get the ability to flag certain values as "use current value instead of rewound value"
	if ( imcTeamScore2 == null && militiaTeamScore2 == null  )
	{
		outcomeAnnouncement.SetLeftText( "#GAMEMODE_JUST_THE_SCORE", GameRules.GetTeamScore2( friendlyTeam ) )
		outcomeAnnouncement.SetRightText( "#GAMEMODE_JUST_THE_SCORE", GameRules.GetTeamScore2( enemyTeam ) )
	}
	else
	{
		Assert( imcTeamScore2 != null && militiaTeamScore2 != null ) //Don't have only one team with teamScore2 override
		if ( friendlyTeam == TEAM_IMC )
		{
			outcomeAnnouncement.SetLeftText( "#GAMEMODE_JUST_THE_SCORE", imcTeamScore2 )
			outcomeAnnouncement.SetRightText( "#GAMEMODE_JUST_THE_SCORE", militiaTeamScore2 )

		}
		else
		{
			outcomeAnnouncement.SetLeftText( "#GAMEMODE_JUST_THE_SCORE", militiaTeamScore2 )
			outcomeAnnouncement.SetRightText( "#GAMEMODE_JUST_THE_SCORE", imcTeamScore2 )
		}
	}

	outcomeAnnouncement.SetLeftIcon( leftIcon )
	outcomeAnnouncement.SetRightIcon( rightIcon )
}
Globalize( ShowRoundScoresInAnnouncement )

function PlayRoundWonConversationWithAnnouncementDelay( conversationDelay )
{
	WaitEndFrame() //Necessary so we don't get the AnnouncementPurge signal from the same announcement we are originating from
	level.ent.EndSignal( "AnnoucementPurge" )

	if ( conversationDelay != 0 )
		wait conversationDelay

	if ( level.nv.winningTeam == null )
		return

	local player = GetLocalClientPlayer()
	if ( player.GetTeam() == level.nv.winningTeam )
		PlayConversationToLocalClient( "RoundWonAnnouncement" )
	else if ( level.nv.winningTeam != TEAM_UNASSIGNED )
		PlayConversationToLocalClient( "RoundLostAnnouncement" )
}
Globalize( PlayRoundWonConversationWithAnnouncementDelay )

function UpdateScoreboardBadRepPresentMessage()
{
	if ( IsLobby() )
		return

	local player = GetLocalClientPlayer()

	if ( level.nv.badRepPresent )
		player.cv.scoreboardBadRepPresentMessage.Show()
	else
		player.cv.scoreboardBadRepPresentMessage.Hide()
}


function DebugDrawThink( player )
{
	if ( player.s.debugDrawFrontline )
		DebugDrawCurrentFrontline()
}

function DebugSetFrontline( posx, posy, posz, dirx, diry )
{
	//printl( "********DebugSetFrontline*********\n" )
	debugFrontlinePos = Vector( posx, posy, posz )
	debugFrontlineDir = Vector( dirx, diry, 0 )
}

function DebugDrawCurrentFrontline()
{
	local sideDir = Vector( debugFrontlineDir.y, -debugFrontlineDir.x, 0 )

	DebugDrawLine( debugFrontlinePos, debugFrontlinePos + sideDir * 2000, 255, 255, 255, true, 0.1 )
	DebugDrawLine( debugFrontlinePos, debugFrontlinePos + sideDir * -2000, 255, 255, 255, true, 0.1 )

	local combatDir
	if ( GetLocalViewPlayer().GetTeam() == TEAM_IMC )
	{
		combatDir = debugFrontlineDir
		DebugDrawText( debugFrontlinePos, "FrontLine IMC", false, 0.1 )
	}
	else
	{
		combatDir = debugFrontlineDir * -1
		DebugDrawText( debugFrontlinePos, "FrontLine Militia", false, 0.1 )
	}

	local endPos = debugFrontlinePos + combatDir * 200

	DebugDrawLine( debugFrontlinePos, endPos, 0, 255, 0, true, 0.1 )

	local arrowSize = 20
	DebugDrawLine( endPos, endPos - combatDir * arrowSize + sideDir * arrowSize, 0, 255, 0, true, 0.1 )
	DebugDrawLine( endPos, endPos - combatDir * arrowSize - sideDir * arrowSize, 0, 255, 0, true, 0.1 )
}


function ToggleDebugDrawFrontline()
{
	local player = GetLocalViewPlayer()
	player.s.debugDrawFrontline = !player.s.debugDrawFrontline
}