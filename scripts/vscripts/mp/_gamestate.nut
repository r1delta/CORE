//********************************************************************************************
//	Game State
//********************************************************************************************
const PREMATCH_TIMER_INTRO_DEFAULT = 46
const PREMATCH_TIMER_NO_INTRO = 7	//shows 5 when fade from black
const WAITPLAYER_TIMER = 10
const WAITPLAYER_TIMER_CAMPAIGN = 25
const WAITPLAYER_TIMER_CAMPAIGN_1STLEVEL = 40
const SWITCHING_SIDES_DELAY = 8.0
const CLEAR_PLAYERS_BUFFER = 2.0

const ENDROUND_FREEZE = 0
const ENDROUND_MOVEONLY = 1
const ENDROUND_FREE = 3

function main()
{
	RegisterSignal( "RoundEnd" )
	RegisterSignal( "RoundStart" )

	FlagInit( "IntroDone" )
	FlagInit( "GamePlaying" )
	FlagInit( "DisableTimeLimit" )
	FlagInit( "AnnounceWinnerEnabled" )
	FlagSet( "AnnounceWinnerEnabled" )
	FlagInit( "AnnounceProgressEnabled" )
	FlagSet( "AnnounceProgressEnabled" )
	FlagInit( "DefendersWinDraw" )

	FlagInit( "ReadyToStartMatch" ) // past waiting for players, in prematch

	RegisterSignal( "GameEnd" )
	RegisterSignal( "GameStateChange" )
	RegisterSignal( "CatchUpFallBehindVO" )

	Globalize( InitGameState )
	Globalize( SetGameState )
	Globalize( WaittillGameStateOrHigher )

	Globalize( CodeCallback_GamerulesThink )
	Globalize( CheckMap )

	Globalize( SetRoundBased )
	Globalize( SetSwitchSidesBased )
	Globalize( SetAttackDefendBased )

	Globalize( GetGameWonAnnouncement )
	Globalize( SetGameWonAnnouncement )
	Globalize( GetGameLostAnnouncement )
	Globalize( SetGameLostAnnouncement )
	Globalize( GetGameModeAnnouncement )
	Globalize( SetGameModeAnnouncement )

	Globalize( GetEpilogueDuration )
	Globalize( GetCustomEpilogueDuration )
	Globalize( SetCustomEpilogueDuration )

	Globalize( CheckEliminationModeWinner )

	Globalize( GetMatchProgress_Score )
	Globalize( GetMatchProgress_Time )
	Globalize( GetMatchProgress )
	Globalize( DefaultMatchProgressionAnnouncement )
	Globalize( GetWinnerDeterminedWait )
	Globalize( RoundScoreLimit_Complete )

	Globalize( Announce_Progress )
	Globalize( SetWinner )
	Globalize( SetWinLossReasons )

	Globalize( PerfInitLabels )
	Globalize( ForceEpilogueEnd )

	Globalize( GameStateControlCheck )

	Globalize( ShouldDoScoreSwapVO )
	Globalize( ScoreSwapVO )

	Globalize( GetMatchHistory )
	Globalize( GetMatchHistoryWinner )
	Globalize( ForceEliminationModeWinner )

	Globalize( AddPilotEliminationDialogueCallback )

	level.devForcedWin <- false  //For dev purposes only. Used to check if we forced a win through dev command
	// functions in this array run when gamestate changes to Playing
	level.preMatchFuncTable <- {}
	// functions in this array run when gamestate changes to Prematch
	level.startRoundFuncTable <- {}
	// functions in this array run when gamestate changes to WinnerDetermined
	level.endRoundFuncTable <- {}

	level.timelimitCompleteFunc <- null

	level.lastTimeLeftSeconds <- null

	level.lastScoreSwapVOTime <- null

	level.winString <- null
	level.lossString <- null

	level.gameStateFunctions <- []
	level.gameStateFunctions.resize( eGameState._count_ )
	for ( local index = 0; index < level.gameStateFunctions.len(); index++ )
	{
		level.gameStateFunctions[index] = {}
	}
	//
	level.playingThinkFuncTable <- {}

	level.matchProgressAnnounceFunc <- null //Set this using GM_SetMatchProgressAnnounceFunc to override default match progress behavior

	level.observerFunc <- null

	level.gameWonAnnouncement <- null
	level.gameLostAnnouncement <- null
	level.gameModeAnnouncement <- null
	level.nextMatchProgressAnnouncementLevel <- MATCH_PROGRESS_EARLY //When we make a matchProgressAnnouncement, this variable is set

	level.endOfRoundPlayerState <- ENDROUND_FREEZE

	level._swapGameStateOnNextFrame <- false
	level.clearedPlayers <- false

	level.customEpilogueDuration <- null

	level.lastTeamTitans <- {}
	level.lastTeamTitans[TEAM_IMC] <- null
	level.lastTeamTitans[TEAM_MILITIA] <- null
	level.lastTeamPilots <- {}
	level.lastTeamPilots[TEAM_IMC] <- null
	level.lastTeamPilots[TEAM_MILITIA] <- null

	level.firstTitanfall <- false

	level.endingMatch <- false
	level.postMatchTimeComplete <- false

	level.lastPlayingEmptyTeamCheck <- 0
	file.teamProtectedFromElimination <- {}
	file.teamProtectedFromElimination[ TEAM_MILITIA ] <- false
	file.teamProtectedFromElimination[ TEAM_IMC ] <- false

	level.pilotEliminationDialogueCallbacks <- []

	level.watchingRoundWinningKillReplay <- false
	level.roundWinningKillReplayViewEnt <- null
	level.roundWinningKillReplayVictim <- null  //Note: We also store a .nv eHandle version of the victim so the client can tell who is going to die in RoundWinningKillReplay. We don't just store the eHandle because the server can't recover the entity from the EncodedEHandle

	level.doneWaitingForPlayersTimeout <- 0

	level.attackDefendBased <- false
}


// This function is meant to init stuff that _gamestate uses, as opposed
// to stuff that any particular gamestate like Playing uses
function InitGameState()
{
}

function EntitiesDidLoad()
{
	// try to set up classic MP intro
	if ( GetClassicMPMode() )
	{
		if ( level.classicMP_introLevelSetupFunc )
		{
			local result = ClassicMP_CallIntroLevelSetupFunc()

			if ( result != false )
				level.classicMP_levelSetupForIntro = true
		}

		// This ensures the intro won't happen if the level isn't set up correctly
		if ( ClassicMP_IsLevelSetupForIntro() )
			level.canStillSpawnIntoIntro = true
	}
}

function WaittillGameStateOrHigher( state )
{
	for ( ;; )
	{
		if ( GetGameState() >= state )
			return
		level.ent.WaitSignal( "GameStateChange" )
	}
}


function GameStateWait( gameState )
{
	while ( GetGameState() != gameState )
	{
		level.ent.WaitSignal( "GameStateChange" )
	}
}


function GameStateEnter_WaitingForCustomStart()
{
	FlagClear( "GamePlaying" )
	level.nv.gameStartTime = Time() + 980
}


function GameStateEnter_WaitingForPlayers()
{
	FlagClear( "GamePlaying" )

	level.nv.gameStartTime = Time() + 980
}


function GameStateEnter_PickLoadOut()
{
	if ( level.nv.minPickLoadOutTime == null )
	level.nv.minPickLoadOutTime = Time() + MIN_PICK_LOADOUT_TIME

	AllPlayersUnMuteSFX()
}


function GameStateEnter_Prematch()
{
	FlagSet( "ReadyToStartMatch" )
	FlagClear( "GamePlaying" )

	PerfInitLabels()

	SetPrematchStartTime()

	ClearWeapons()

	level.clearedPlayers = false
	level.lastTimeLeftSeconds = 0
	level.lastScoreSwapVOTime = 0
	level.firstTitanfall = false

	local players = GetPlayerArray()
	foreach ( player in players )
	{
		if ( !IsPlayerInCinematic( player ) )
			player.FreezeControlsOnServer( false )

		ClearPlayerEliminated( player )
		player.SetSkyCamera( SKYBOXLEVEL )

		TakeAllPassives( player )

		Prematch_PlayerScreenFade( player )

		UnMuteSFX( player )
	}

	if ( IsRoundBased() )
	{
		level.nv.roundScoreLimitComplete = false

		if ( GetRoundWinningKillEnabled() == true )
		ClearRoundWinningKillReplayEntities() // Clear here as opposed to at the end of roundwinningkillreplay to not change the time spent in WinnerDetermined state.
	}

	DoPrematchFunctions()

	if ( EvacEnabled() )
		level.playersOnDropship = {}

	thread GameStartSpawnPlayers()
}

function Prematch_PlayerScreenFade( player )
{
	if ( IsRoundBased() && level.nv.roundsPlayed )
	{
		if (ClassicMP_CanUseIntroStartSpawn() )
			ScreenFade( player, 2, 0, 0, 255, 2.0, 2.2, 0x0001 | 0x0010 )  // HACK need extra hold time on black so we don't see the spawn dropship door handle animate on its own
		else
			ScreenFade( player, 2, 0, 0, 255, 2.0, 0.5, 0x0001 | 0x0010 )
	}
	else if ( IsSwitchSidesBased() && level.nv.switchedSides )
	{
		ScreenFade( player, 2, 0, 1, 255, 2.0, 0.5, 0x0001 | 0x0010 )
	}
	else
	{
		ScreenFade( player, 2, 1, 1, 0, 0.0, 0.0, 0x0001 | 0x0010 )
	}
}


function GameStateEnter_Playing()
{
	FlagClear( "APlayerHasSpawned" )

	printt( "Enter Gamestate playing" )

	level.ui.showGameSummary = false

	level.canStillSpawnIntoIntro = false

	//1. 커스텀 룰에 필요한 값을 먼저 설정! - added by iskyfish
	//TitanCustomRule();

	//2. Reset Titan timers at the very start of match start, in case of late connects, intros, etc
	local players = GetPlayerArray()
	foreach ( player in players )
	{
		player.UnfreezeControlsOnServer()

		StartTitanBuildProgress( player )


		UnMuteSFX( player )
	}

	if ( IsRoundBased() )
	{
		if ( GetRoundTimeLimit_ForGameMode() )
		{
			local timeLimit = (GetRoundTimeLimit_ForGameMode() * 60.0).tointeger()

			if ( timeLimit > 0 )
				level.nv.roundEndTime = Time() + timeLimit
		}

		level.nv.roundStartTime = Time()
		thread DoStartRoundFunctions()
	}
	else
	{
		if ( GetTimeLimit_ForGameMode() )
		{
			local timeLimit = ( GetTimeLimit_ForGameMode() * 60.0 ).tointeger()

			if ( timeLimit > 0  )
				level.nv.gameEndTime = Time() + timeLimit
			else
				Assert( "TimeLimit is enabled but TimeLimitFromPlaylist is 0" )
		}
	}

	if ( IsEliminationBased() )
	{
		if ( Riff_EliminationMode() == eEliminationMode.Titans )
			level.nv.secondsTitanCheckTime = Time() + ELIM_TITAN_SPAWN_GRACE_PERIOD
	}

	FlagSet( "GamePlaying" )
}


function SetEndRoundPlayerState( endRoundType )
{
	level.endOfRoundPlayerState = endRoundType
}
Globalize( SetEndRoundPlayerState )


function PlayerEnterEndRoundState( player )
{
	switch ( level.endOfRoundPlayerState )
	{
		case ENDROUND_MOVEONLY:
			TakeAmmoFromPlayer( player )
			break

		case ENDROUND_FREE:
			break

		case ENDROUND_FREEZE:
			player.FreezeControlsOnServer( false )
			break

		default:
			player.FreezeControlsOnServer( false )
			break
	}
}
Globalize( PlayerEnterEndRoundState )


function GameStateEnter_SuddenDeath()
{
	level.nv.gameEndTime += ( GetSuddenDeathTimeLimit_ForGameMode() * 60.0 ).tointeger()

	switch ( GAMETYPE )
	{
		case CAPTURE_THE_FLAG:
			PlayConversationToAll( "GameModeAnnounce_CTF_SuddenDeath" )
			level.nv.eliminationMode = eEliminationMode.Pilots
			break

		case TEAM_DEATHMATCH:
			//PlayConversationToAll( "GameModeAnnounce_TDM_SuddenDeath" )
			AddDeathCallback( "player", SuddenDeathPlayerDied )
			break
	}
}

function GameStateEnter_WinnerDetermined()
{
	if ( IsRoundBased() )
	{
		level.nv.roundsPlayed++
		level.nv.roundEndTime = Time()

		if ( !RoundScoreLimit_Complete() )
		{
			DoEndRoundFunctions() // TEMP, replace with gamestate functions

			if ( GAMETYPE != COOPERATIVE )
				AnnounceRoundWinner()

			local players = GetPlayerArray()
			foreach ( player in players )
			{
				if ( GAMETYPE == COOPERATIVE )
				{
					// Ideally would be some sort of custom screen fade function callback
					thread Coop_DelayedWinnerDetermined( player )
				}
				else
				{
					if (IsWinningTeam(player.GetTeam()))
						AddPlayerScore( player, "RoundVictory" )

					AddPlayerScore( player, "RoundComplete" )
					ScreenFade( player, 0, 2, 0, 255, GetWinnerDeterminedWait() - CLEAR_PLAYERS_BUFFER, CLEAR_PLAYERS_BUFFER, 0x0002 | 0x0008 )

					SetPlayerEliminated( player )
					PlayerEnterEndRoundState( player )

					if ( ShouldClearPlayersInWinnerDetermined() )
						MuteSFX( player )
				}
			}

			if ( WillShowRoundWinningKillReplay() )
				thread RoundWinningKillReplay()

			return
		}

		level.nv.roundScoreLimitComplete = true

		if ( GAMETYPE == COOPERATIVE )
		{
			DoEndRoundFunctions() // TEMP, replace with gamestate functions
	        level.nv.gameEndTime = Time() - level.nv.coopStartTime
        	//AwardEndOfMatchAwards is called in TowerDefense_WinnerDetermined_Threaded for timing purposes.

			return
		}
	}

	Assert( WinnerDeterminedAndMatchCompleted(), "WinnerDeterminedAndMatchCompleted() was false!" )

	DoEndRoundFunctions() // TEMP, replace with gamestate functions

	AnnounceWinner(GetTeamIndex(level.nv.winningTeam))

	level.nv.gameEndTime = Time()

	CreateLevelWinnerDeterminedMusicEvent()

	thread AwardEndOfMatchAwards()

	level.ui.penalizeDisconnect = false

	if ( WillShowRoundWinningKillReplay() )
	{
		local players = GetPlayerArray()
		foreach ( player in players )
			SetPlayerEliminated( player )

		thread RoundWinningKillReplay()
	}
	else if ( ShouldRunEvac() ) //RoundWinningKillReplay doesn't work with Evac!
		thread EvacMain( level.nv.winningTeam )

	if ( GetClassicMPMode() )
		level.ent.Signal( "StratonHornetDogfights" ) //Stop skyshow for classic MP

	CheckForEmptyTeamVictory()
}

function WinnerDeterminedAndMatchCompleted()
{
	if ( GetGameState() < eGameState.WinnerDetermined )
		return false

	if ( IsRoundBased() )
	{
		return RoundScoreLimit_Complete()
	}

	return true
}

function Coop_DelayedWinnerDetermined( player )
{
	player.EndSignal( "Disconnected" )

	local fadeTime = 0.35

	wait GetWinnerDeterminedWait() - fadeTime - CLEAR_PLAYERS_BUFFER

	ScreenFade( player, 0, 2, 0, 255, fadeTime, GetWinnerDeterminedWait(), 0x0002 | 0x0008 )  // the next fade up will cancel the long hold time

	SetPlayerEliminated( player )
	PlayerEnterEndRoundState( player )
}

function AwardEndOfMatchAwards( delayOverride = null )
{
	local waitTime
	if ( delayOverride != null )
		waitTime = delayOverride
	else
		waitTime = GetWinnerDeterminedWait() / 2

	wait waitTime

	local xpToLevel2 = GetXPForLevel( 2 )
	local players = GetPlayerArray()
	foreach ( player in players )
	{
		if (IsWinningTeam(player.GetTeam()))
		{
			AddPlayerScore( player, "MatchVictory" )
		}

		AddPlayerScore( player, "MatchComplete" )
	}
}
Globalize( AwardEndOfMatchAwards )

function GameStateEnter_SwitchingSides()
{
	if ( IsRoundBased() )
		level.nv.switchedSides = GetRoundsPlayed()
	else
		level.nv.switchedSides = 1

	if ( level.nv.attackingTeam )
		level.nv.attackingTeam = GetOtherTeam( level.nv.attackingTeam )

	local players = GetPlayerArray()
	foreach ( player in players )
	{
		player.s.respawnCount = 0
		SetPlayerEliminated( player )
		ScreenFade( player, 0, 0, 2, 255, SWITCHING_SIDES_DELAY - CLEAR_PLAYERS_BUFFER, CLEAR_PLAYERS_BUFFER, 0x0002 | 0x0008 )
		PlayerEnterEndRoundState( player )

		MuteSFX( player )
	}

	SwapSpawnpointTeams()

	local frontline = GetCurrentFrontline()

	if( frontline != null )
		SetFrontlineSides( frontline, TEAM_IMC )

	EmitSoundToTeamPlayers( "UI_InGame_SwitchingSides", TEAM_MILITIA )
	EmitSoundToTeamPlayers( "UI_InGame_SwitchingSides", TEAM_IMC )

	delaythread( 0.75 ) PlayConversationToTeam( "SwitchingSides", TEAM_MILITIA )
	delaythread( 0.75 ) PlayConversationToTeam( "SwitchingSides", TEAM_IMC )
}

function GameStateEnter_Postmatch()
{
	//Functions are set in CoopTD_Postmatch to control timing.
	if ( GAMETYPE == COOPERATIVE || GAMETYPE == DEVTEST)
		return

	FlagClear( "GamePlaying" )
	level.ent.Signal( "GameEnd" )

	GameRules.EnterPostMatch()

	local playersOnDropship

	if ( EvacEnabled() )
		playersOnDropship = level.playersOnDropship
	else
		playersOnDropship = {}

	ReportDevStat_RoundEnd( GetWinningTeam() )

	local xpToLevel2 = GetXPForLevel(2)
	local players = GetPlayerArray()
	foreach ( player in players )
	{
		FinalPlayerUpdate( player )
		ScreenFade( player, 0, 2, 1, 255, 1.0, 0.0, 0x0002 | 0x0008 )
		player.FreezeControlsOnServer( false )
		thread DelayedTakeAllWeapons( player )
		//Remote.CallFunction_Replay( player, "ServerCallback_GameStateEnter_Postmatch" )
		player.SetInvulnerable() //Don't let the player get killed when controls are frozen

		MuteSFX( player )
	}

	level.ui.showGameSummary = true

	local delay = GAME_POSTMATCH_LENGTH - 1.0 - MUTEALLFADEIN
	delaythread( delay ) AllPlayersMuteAll()
}

function DelayedTakeAllWeapons( player )
{
	player.EndSignal( "Disconnected" )
	player.EndSignal( "OnDeath" )

	wait 1.25

	if ( IsValid( player ) )
		TakeAllWeapons( player )
}

function SetGameState( newState )
{
	Assert( newState < eGameState._count_ )

	if ( newState == GetGameState() )
		return

	level.nv.gameStateChangeTime = Time()
	level.nv.gameState = newState
	SetServerVar( "gameState", newState )

	// Epilogue or later?  Don't let ranks be late enabled

	level.ent.Signal( "GameStateChange" )

	foreach ( callbackInfo in level.gameStateFunctions[newState] )
	{
		callbackInfo.func.acall( [callbackInfo.scope] )
	}

	switch ( newState )
	{
		case eGameState.WaitingForCustomStart:
			GameStateEnter_WaitingForCustomStart()
			break

		case eGameState.WaitingForPlayers:
			GameStateEnter_WaitingForPlayers()
			break

		case eGameState.PickLoadout:
			GameStateEnter_PickLoadOut()
			break

		case eGameState.Prematch:
			GameStateEnter_Prematch()
			break

		case eGameState.Playing:
			GameStateEnter_Playing()
			break

		case eGameState.SuddenDeath:
			GameStateEnter_SuddenDeath()
			break

		case eGameState.WinnerDetermined:
			GameStateEnter_WinnerDetermined()
			break

		case eGameState.SwitchingSides:
			GameStateEnter_SwitchingSides()
			break

		case eGameState.Epilogue:
			if ( /*!level.isTestmap &&*/ IsHighPerfDevServer() ) //Commenting out again before we make the real build
				delaythread( GAME_EPILOGUE_PLAYER_RESPAWN_LEEWAY + 5 ) DumpSpawnData()
			break

		case eGameState.Postmatch:
			GameStateEnter_Postmatch()
			break

		default:
			Assert( 0, "Unknown game state" )
	}
}


function DoStartRoundFunctions()
{
	foreach ( callbackInfo in level.startRoundFuncTable )
	{
		callbackInfo.func.acall( [callbackInfo.scope] )
	}
}


function DoPrematchFunctions()
{
	foreach ( callbackInfo in level.preMatchFuncTable )
	{
		callbackInfo.func.acall( [callbackInfo.scope] )
	}
}


function DoEndRoundFunctions()
{
	foreach ( callbackInfo in level.endRoundFuncTable )
	{
		callbackInfo.func.acall( [callbackInfo.scope] )
	}
}


function DoEpilogueFunctions()
{
	foreach ( callbackInfo in level.endRoundFuncTable )
	{
		callbackInfo.func.acall( [callbackInfo.scope] )
	}
}

function CodeCallback_GamerulesThink()
{
	switch ( GetGameState() )
	{
		case eGameState.WaitingForCustomStart:
//			printt( "STATE: waiting for custom start" )
			GameRulesThink_WaitingForCustomStart()
			break

		case eGameState.WaitingForPlayers:
//			printt( "STATE: waiting for players" )
			GameRulesThink_WaitingForPlayers()
			break

		case eGameState.PickLoadout:
//			printt( "STATE: Pick Loadout" )
			GameRulesThink_PickLoadout()
			break

		case eGameState.Prematch:
//			printt( "STATE: prematch" )
			GameRulesThink_Prematch()
			break

		case eGameState.Playing:
//			printt( "STATE: playing" )
			GameRulesThink_Playing()
			break

		case eGameState.SuddenDeath:
//			printt( "STATE: SuddenDeath" )
			GameRulesThink_SuddenDeath()
			break

		case eGameState.WinnerDetermined:
//			printt( "STATE: WinnerDetermined" )
			GameRulesThink_WinnerDetermined()
			break

		case eGameState.SwitchingSides:
//			printt( "STATE: SwitchingSides" )
			GameRulesThink_SwitchingSides()
			break

		case eGameState.Epilogue:
//			printt( "STATE: Epilogue" )
			if ( EvacEnabled() && level.dropship )
				EvacShipTriggerCheck( level.dropship )
			GameRulesThink_Epilogue()
			break

		case eGameState.Postmatch:
//			printt( "STATE: post" )
			GameRulesThink_Postmatch()
			break
	}

	UpdateMatchStateToCode()
}


function SetPrematchStartTime()
{
	if ( GetCinematicMode() )
	{
		if ( Flag( "CinematicIntro" ) )
		{
			if ( GetCustomIntroLength() != null )
			{
				level.nv.gameStartTime = Time() + GetCustomIntroLength()
			}
			else
			{
				level.nv.gameStartTime = Time() + PREMATCH_TIMER_INTRO_DEFAULT
			}
		}
		else
		{
			level.nv.gameStartTime = Time() + PREMATCH_TIMER_NO_INTRO
		}
	}
	else
	{
		if ( GetClassicMPMode() && GetCustomIntroLength() )
		{
			level.nv.gameStartTime = Time() + GetCustomIntroLength()
		}
		else
		{
			level.nv.gameStartTime = Time() + 3.0
		}
	}
}


function GetConnectedPlayers()
{
	local players = GetPlayerArray()
	local guys = []
	foreach ( player in players )
	{
		if ( !player.hasConnected )
			continue

		guys.append( player )
	}

	return guys
}

function BothTeamsConnected()
{
	local players = GetPlayerArray()

	local imcConnected = false
	local militiaConnected = false

	foreach ( player in players )
	{
		if ( !player.hasConnected )
			continue

		if ( player.GetTeam() == TEAM_IMC )
			imcConnected = true
		else if ( player.GetTeam() == TEAM_MILITIA )
			militiaConnected = true
	}

	return imcConnected && militiaConnected
}


function IsAnyPlayerMMDebug()
{
	local players = GetPlayerArray()
	foreach ( player in players )
	{
		if ( player.GetMMDbgFlags() > 0 )
			return true
	}

	return false
}

function DoneWaitingForPlayers()
{
	if ( IsTrainingLevel() )
		return true

	local connectedPlayers = GetConnectedPlayers()
	local connectedPlayersCount = connectedPlayers.len()

	// developer 1 skips the remaining script, we can test the rest in developer mode with developer > 1
	if ( GetDeveloperLevel() == 1 || ( IsAnyPlayerMMDebug() ) )
		return true

	// wait for one player to connect
	if ( connectedPlayersCount < 1 )
			return false

	// start failsafe timer
	if ( level.doneWaitingForPlayersTimeout == 0 )
		level.doneWaitingForPlayersTimeout = Time() + GetCurrentPlaylistVarInt( "waiting_for_players_timeout_seconds", 30 )

	local minPlayers = GetCurrentPlaylistVarInt( "min_players", 0 )
	local knownPlayersCount = GetConnectingAndConnectedPlayerArray().len() + GetPendingClientsCount()
	local expectedPlayers = max( minPlayers, knownPlayersCount )
	local bothTeamsConnected = BothTeamsConnected()

	// test that we haven't hit the failsafe timeout
	if ( Time() < level.doneWaitingForPlayersTimeout )
	{
		// need at least one player from each team connected
		if ( GAMETYPE != COOPERATIVE && !bothTeamsConnected )
			return false

		// wait for minPlayers to connect or a portion of all expectedPlayers, whichever is greater
		local playersDesiredForCountdownStart = max( minPlayers, ( expectedPlayers * GetCurrentPlaylistVarInt( "waiting_for_players_percentage_desired", 70 ) * 0.01 ).tointeger() )
		if ( connectedPlayersCount < playersDesiredForCountdownStart )
			return false
	}

	// all expectedPlayers are here, done waiting
	if ( connectedPlayersCount == expectedPlayers )
		return true

	local countdownSeconds = GetCurrentPlaylistVarInt( "waiting_for_players_countdown_seconds", 0 )

	// only wait X more seconds if the playlist var is greater than 0
	if ( countdownSeconds <= 0 )
		return true

	// start X second countdown
	if ( level.nv.connectionTimeout == null || level.nv.connectionTimeout == 0 )
		level.nv.connectionTimeout = Time() + countdownSeconds

	return Time() >= level.nv.connectionTimeout
}


function GameRulesThink_WaitingForCustomStart()
{
	SetGameState( eGameState.WaitingForPlayers )
}


function GameRulesThink_WaitingForPlayers()
{
	if ( !DoneWaitingForPlayers() )
		return

	if ( GetClassicMPMode() && ClassicMP_CanUseIntroStartSpawn() )
		SetGameState( eGameState.PickLoadout )
	else
		SetGameState( eGameState.Prematch )
}

function GameRulesThink_PickLoadout()
{
	local loadOutTime = level.nv.minPickLoadOutTime
	if ( loadOutTime == null )
		return
	if ( Time() < loadOutTime )
		return

	SetGameState( eGameState.Prematch )
}

function GameRulesThink_Prematch()
{
	if ( Time() < level.nv.gameStartTime )
		return

	SetGameState( eGameState.Playing )
	level.nv.winningTeam = null

	GameRules.MarkGameStatePrematchEnding()
}


function ClearPlayers()
{
	local players = GetPlayerArray()

	foreach ( player in players )
	{
		if ( !IsAlive( player ) )
			continue

		player.ClearInvulnerable()
		player.ClearParent()

		SetPlayerEliminated( player )
	}

	foreach ( player in players )
	{
		if ( !GetCinematicMode() && GetMapName() != "mp_o2" ) //Special case for O2 since it's the only place that calls ClearPlayers outside of gamestate stuff
			ScreenFade( player, 0, 0, 1, 255, 0.0, 0.0, 0x008 | 0x010 ) //Don't use the util ScreenFadeToBlack function because we don't want to purge the existing black screen fades that might be called from elsewhere. Also this combination of parameters allow instant screen black as opposed to fading


		if ( !IsAlive( player ) )
		{
			local petTitan = player.GetPetTitan()
			if ( IsAlive( petTitan ) )
			{
				InitTitanBuildRule( player )
				//TitanCustomRule_Update(player, 0) // 타이탄만 살아있을 수도.
			}

			continue
		}

		// kill off the living players
		if ( player.IsTitan() )
		{
			//TitanCustomRule_Update(player, 0)
			InitTitanBuildRule( player )

			player.Die( level.worldspawn, level.worldspawn, { damageSourceId = eDamageSourceId.round_end } )
			Assert( !IsAlive( player ), player.GetHealth() + " " + player.IsInvulnerable() + " " + player.IsBuddhaMode() + " " + player.IsGodMode() )
		}
		else
		{
			local petTitan = player.GetPetTitan()
			if ( IsAlive( petTitan ) )
			{
				//TitanCustomRule_Update(player, 0)
				InitTitanBuildRule( player )

				petTitan.Die( level.worldspawn, level.worldspawn, { damageSourceId = eDamageSourceId.round_end } )
			}

			if ( IsValid( petTitan ) )
				petTitan.Destroy()

			// seems possible that somehow killing the pet titan can kill the player
			if ( IsAlive( player ) )
				player.Die( level.worldspawn, level.worldspawn, { damageSourceId = eDamageSourceId.round_end } )

			Assert( !IsAlive( player ), player.GetHealth() + " " + player.IsInvulnerable() + " " + player.IsBuddhaMode() + " " + player.IsGodMode() )
		}
	}

	local turrets = GetNPCArrayByClass( "npc_turret_mega" )
	foreach ( turret in turrets )
	{
		if ( !IsAlive( turret ) )
			continue

		ReleaseTurret( turret, turret.GetControlPanel() )
	}

	local bbTurrets = GetNPCArrayByClass( "npc_turret_mega_bb" )
	foreach ( turret in bbTurrets )
	{
		if ( !IsAlive( turret ) )
			continue

		ReleaseBBTurret( turret, turret.GetControlPanel() )
	}

	ResetNPCs()

	// TODO: delete projectiles and lingering effects
}
Globalize( ClearPlayers )

function ClearWeapons()
{
	local weapons = GetWeaponArray( true )
	foreach ( weapon in weapons )
		weapon.Destroy()
}
Globalize( ClearWeapons )

function SetWinLossReasons( winString, lossString )
{
	level.winString = winString
	level.lossString = lossString
}


function SetWinner( winningTeam )
{
	Assert( GamePlayingOrSuddenDeath() )

	if ( IsRoundBased() && GAMETYPE != COOPERATIVE )
	{
		if ( winningTeam != TEAM_UNASSIGNED )
		{
			local roundWins = GameRules.GetTeamScore2( winningTeam )
			local newRoundWins = roundWins + 1
			GameRules.SetTeamScore2( winningTeam, newRoundWins )
			GameRules.SetTeamScore( winningTeam, newRoundWins ) // HACK; client scorebars don't know how to display TeamScore2

			local losingTeam = GetOtherTeam(winningTeam)
			local losingTeamScore = GameRules.GetTeamScore2( losingTeam )
			if ( ShouldDoScoreSwapVO( roundWins, newRoundWins, losingTeamScore ) )
				thread ScoreSwapVO( winningTeam, losingTeam )
		}
	}

	if ( ShouldEnterSuddenDeath( winningTeam ) )
	{
		SetGameState( eGameState.SuddenDeath )
		return
	}

	if (winningTeam != null)
		level.nv.winningTeam = winningTeam

	SetGameState( eGameState.WinnerDetermined )
}


function EliminationMode_Complete()
{
	if ( !IsEliminationBased() )
		return false

	if ( GameTime.PlayingTime() < ELIM_FIRST_SPAWN_GRACE_PERIOD )
		return false

	if ( IsPilotEliminationBased() )
	{
		local players = GetPlayerArray()
		foreach ( player in players )
		{
			if ( !IsPlayerEliminated( player ) && !player.s.respawnCount )
				SetPlayerEliminated( player )
		}
	}

	return (CheckEliminationModeWinner() != null)
}


function ForceEliminationModeWinner()
{
	switch ( Riff_EliminationMode() )
	{
		case eEliminationMode.Pilots:
			CheckEliminationPilotWinner( true )
			break

		case eEliminationMode.PilotsTitans:
		case eEliminationMode.Titans:
			CheckEliminationTitanWinner( true )
			break

		default:
			Assert( 0 )
	}
}


function CheckEliminationModeWinner()
{
	local isComplete

	switch ( Riff_EliminationMode() )
	{
		case eEliminationMode.Pilots:
			isComplete = CheckEliminationPilotWinner()
			break

		case eEliminationMode.PilotsTitans:
		case eEliminationMode.Titans:
			isComplete = CheckEliminationTitanWinner()
			break

		default:
			Assert( 0 )
	}

	return isComplete
}


function CheckEliminationPilotWinner( setWinner = false )
{
	// 빅브라더 모드 폭탄 설치 시 방어팀이 살아있으면 엘리 체크 안함.
	// 방어팀이 전멸인 경우 폭탄 설치와 상관없이 엘리 처리.
	if( GAMETYPE == BIG_BROTHER && IsBigBrotherPanelExplosion() )
	{
		return
	}

	local players = GetPlayerArray()
	local teams = {}
	teams[ TEAM_IMC ] <- 0
	teams[ TEAM_MILITIA ] <- 0

	foreach ( player in players )
	{
		if ( !IsAlive( player ) )
			continue

		teams[ player.GetTeam() ]++
	}

	foreach ( team, protected in file.teamProtectedFromElimination )
	{
		// this team can't be eliminated now
		if ( protected )
			teams[ team ]++
	}

	local winningTeam
	local winReason
	local lossReason

	if ( !teams[ TEAM_IMC ] && teams[ TEAM_MILITIA ] )
	{
		winReason = "#GAMEMODE_ENEMY_PILOTS_ELIMINATED"
		lossReason = "#GAMEMODE_FRIENDLY_PILOTS_ELIMINATED"
		winningTeam = TEAM_MILITIA

		setWinner = true
	}
	else if ( teams[ TEAM_IMC ] && !teams[ TEAM_MILITIA ] )
	{
		winReason = "#GAMEMODE_ENEMY_PILOTS_ELIMINATED"
		lossReason = "#GAMEMODE_FRIENDLY_PILOTS_ELIMINATED"
		winningTeam = TEAM_IMC

		setWinner = true
	}
	else if ( !teams[TEAM_IMC] && !teams[TEAM_MILITIA] )
	{
		if ( level.nv.attackingTeam && level.nv.attackingTeam != TEAM_UNASSIGNED )
		{
			if ( Flag( "DefendersWinDraw" ) )
			{
				winReason = "#GAMEMODE_DEFENDERS_WIN"
				lossReason = "#GAMEMODE_DEFENDERS_WIN"
				winningTeam = GetOtherTeam(level.nv.attackingTeam)
			}
			else
			{

				winReason = "#GAMEMODE_ATTACKERS_WIN"
				lossReason = "#GAMEMODE_ATTACKERS_WIN"
				winningTeam = level.nv.attackingTeam
			}
		}
		else
		{
			winningTeam = TEAM_UNASSIGNED
		}

		setWinner = true
	}
	else if ( setWinner )
	{
		if ( level.nv.attackingTeam && level.nv.attackingTeam != TEAM_UNASSIGNED )
		{
			if ( Flag( "DefendersWinDraw" ) )
			{
				winReason = "#GAMEMODE_DEFENDERS_WIN"
				lossReason = "#GAMEMODE_DEFENDERS_WIN"
				winningTeam = GetOtherTeam(level.nv.attackingTeam)
			}
			else
			{
				if( GAMETYPE != BIG_BROTHER )
				{
					winReason = "#GAMEMODE_ATTACKERS_WIN"
					lossReason = "#GAMEMODE_ATTACKERS_WIN"
					winningTeam = level.nv.attackingTeam
				}
				else
				{
					setWinner = false
				}
				//else
				//{
				//	winReason = "#BIG_BROTHER_ENEMY_PANEL_DESTROYED"
				//	lossReason = "#BIG_BROTHER_FRIENDLY_PANEL_DESTROYED"
				//}

				//winningTeam = level.nv.attackingTeam
			}
		}
		else
		{
			winningTeam = TEAM_UNASSIGNED
		}
	}

	if ( setWinner && level.nv.winningTeam == null )
	{
		SetWinLossReasons( winReason, lossReason )
		SetWinner( winningTeam )
		return winningTeam
	}
	else
	{
		local IMCPlayersAlive =  GetLivingPlayers( TEAM_IMC )
		local MilitiaPlayersAlive = GetLivingPlayers( TEAM_MILITIA )

		foreach ( callbackInfo in level.pilotEliminationDialogueCallbacks )
		{
			callbackInfo.func.acall( [callbackInfo.scope, TEAM_IMC, IMCPlayersAlive, TEAM_MILITIA, MilitiaPlayersAlive] )
			callbackInfo.func.acall( [callbackInfo.scope, TEAM_MILITIA, MilitiaPlayersAlive, TEAM_IMC, IMCPlayersAlive] )
		}

		if ( level.pilotEliminationDialogueCallbacks.len() == 0 )
		{
			PlayPilotEliminationDialogue( IMCPlayersAlive, MilitiaPlayersAlive )
		}

		level.lastTeamPilots[TEAM_MILITIA] = MilitiaPlayersAlive.len()
		level.lastTeamPilots[TEAM_IMC] = IMCPlayersAlive.len()
		return winningTeam
	}
}

function AddPilotEliminationDialogueCallback( callbackFunc )
{
	Assert( "pilotEliminationDialogueCallbacks" in level )
	Assert( type( this ) == "table", "AddPilotEliminationDialogueCallback can only be added on a table. " + type( this ) )
	AssertParameters( callbackFunc, 4, "team1, team1PlayersAlive, team2, team2PlayersAlive" )

	local callbackInfo = {}
	callbackInfo.func <- callbackFunc
	callbackInfo.scope <- this

	level.pilotEliminationDialogueCallbacks.append( callbackInfo )
}

function PlayPilotEliminationDialogue( IMCPlayersAlive, MilitiaPlayersAlive )
{
	if ( level.nv.winningTeam != null )
		return

	switch( GAMETYPE )
	{
		//LTS and Wingman LTS are both Pilot and Titan Elimination, but Titan elimination should take priority
		case WINGMAN_LAST_TITAN_STANDING:
		case LAST_TITAN_STANDING:
			return
	}

	local numIMCPlayersAlive = IMCPlayersAlive.len()
	local numMilitiaPlayersAlive = MilitiaPlayersAlive.len()

	if ( level.lastTeamPilots[TEAM_MILITIA] != numMilitiaPlayersAlive && level.nv.winningTeam == null )
	{
		if ( numMilitiaPlayersAlive == 2 )
		{
			if ( GetCurrentPlaylistVarInt( "max_players", 16 ) > 4 )
			{
				foreach( aliveIMCPlayer in IMCPlayersAlive )
					PlayConversationToPlayer("EnemyPilotsLeftTwo", aliveIMCPlayer )

				foreach( aliveMilitiaPlayer in MilitiaPlayersAlive )
					PlayConversationToPlayer( "FriendlyPilotsLeftTwo", aliveMilitiaPlayer )
			}
		}
		else if ( numMilitiaPlayersAlive == 1  )
		{
			foreach( aliveIMCPlayer in IMCPlayersAlive )
				PlayConversationToPlayer("EnemyPilotsLeftOne", aliveIMCPlayer )

			local player = MilitiaPlayersAlive[ 0 ]
			Assert( IsAlive( player ) ) //Just in case!
			PlayConversationToPlayer( "YouAreTheLastPilot", player )
		}
	}

	if ( level.lastTeamPilots[TEAM_IMC] != numIMCPlayersAlive )
	{
		if ( numIMCPlayersAlive == 2 )
		{
			if ( GetCurrentPlaylistVarInt( "max_players", 16 ) > 4 )
			{
				foreach( aliveIMCPlayer in IMCPlayersAlive )
					PlayConversationToPlayer("FriendlyPilotsLeftTwo", aliveIMCPlayer )

				foreach( aliveMilitiaPlayer in MilitiaPlayersAlive )
					PlayConversationToPlayer( "EnemyPilotsLeftTwo", aliveMilitiaPlayer )
			}
		}
		else if ( numIMCPlayersAlive == 1 )
		{
			foreach( aliveMilitiaPlayer in MilitiaPlayersAlive )
				PlayConversationToPlayer( "EnemyPilotsLeftOne", aliveMilitiaPlayer )

			local player = IMCPlayersAlive[ 0 ]
			Assert( IsAlive( player ) ) //Just in case!
			PlayConversationToPlayer( "YouAreTheLastPilot", player )
		}
	}
}


function CheckEliminationTitanWinner( setWinner = false )
{
	local players = GetPlayerArray()

	local teamPlayers = {}
	teamPlayers[TEAM_IMC] <- 0
	teamPlayers[TEAM_MILITIA] <- 0

	local teamTitans = {}
	teamTitans[TEAM_IMC] <- []
	teamTitans[TEAM_MILITIA] <- []

	local teamTitansAvailable = {}
	teamTitansAvailable[TEAM_IMC] <- 0
	teamTitansAvailable[TEAM_MILITIA] <- 0

	local teamPlayerTitans = {}
	teamPlayerTitans[TEAM_IMC] <- 0
	teamPlayerTitans[TEAM_MILITIA] <- 0

	local isPilotEliminationBased = IsPilotEliminationBased()

	if ( isPilotEliminationBased )
	{
		foreach ( player in players )
		{
			if ( !IsValid( player ) )
				continue

			local petTitan = player.GetPetTitan()
			local team = player.GetTeam()

			if ( IsAlive( player ) )
				teamPlayers[team]++

			if ( IsAlive( petTitan ) && !("noLongerCountsForLTS" in petTitan.s ) )
			{
				teamTitans[team].append( petTitan )
			}
			else if ( (IsAlive( player ) && player.IsTitan() ) )
			{
				teamTitans[team].append( player )
				teamPlayerTitans[team]++
			}
			else if ( IsAlive( player ) && IsReplacementTitanAvailable( player ) )
			{
				teamTitansAvailable[team]++
			}
		}
	}
	else
	{
		foreach ( player in players )
		{
			if ( !IsValid( player ) )
				continue

			teamPlayers[team]++
			local petTitan = player.GetPetTitan()
			local team = player.GetTeam()

			if ( IsAlive( petTitan ) && !("noLongerCountsForLTS" in petTitan.s ) )
			{
				teamTitans[team].append( petTitan )
			}
			else if ( (IsAlive( player ) && player.IsTitan() ) )
			{
				teamTitans[team].append( player )
			}
			else if ( !IsPlayerEliminated( player ) && IsReplacementTitanAvailable( player ) )
			{
				teamTitansAvailable[team]++
			}
		}
	}

	foreach ( team, protected in file.teamProtectedFromElimination )
	{
		// this team can't be eliminated now
		if ( protected )
			teamPlayers[ team ]++
	}

	local winningTeam
	local winReason
	local lossReason

	if ( GameTime.PlayingTime() < ELIM_TITAN_SPAWN_GRACE_PERIOD )
	{
		if ( (teamTitansAvailable[TEAM_IMC] || teamTitans[TEAM_IMC].len()) && (teamTitansAvailable[TEAM_MILITIA] || teamTitans[TEAM_MILITIA].len()) )
			return false
	}

	if ( !teamTitans[TEAM_IMC].len() && teamTitans[TEAM_MILITIA].len() )
	{
		winReason = "#GAMEMODE_ENEMY_TITANS_DESTROYED"
		lossReason = "#GAMEMODE_FRIENDLY_TITANS_DESTROYED"
		winningTeam = TEAM_MILITIA

		setWinner = true
	}
	else if ( !teamTitans[TEAM_MILITIA].len() && teamTitans[TEAM_IMC].len() )
	{
		winReason = "#GAMEMODE_ENEMY_TITANS_DESTROYED"
		lossReason = "#GAMEMODE_FRIENDLY_TITANS_DESTROYED"
		winningTeam = TEAM_IMC

		setWinner = true
	}
	else if ( !teamTitans[TEAM_IMC].len() && !teamTitans[TEAM_MILITIA].len() )
	{
		if ( isPilotEliminationBased )
		{
			if ( CheckEliminationPilotWinner() != TEAM_UNASSIGNED )
				return
		}

		winReason = "#GAMEMODE_NO_TITANS_REMAINING"
		lossReason = "#GAMEMODE_NO_TITANS_REMAINING"
		winningTeam = TEAM_UNASSIGNED

		setWinner = true
	}
	else if ( isPilotEliminationBased && !teamPlayers[TEAM_IMC] && teamPlayers[TEAM_MILITIA] )
	{
		winReason = "#GAMEMODE_ENEMY_PILOTS_ELIMINATED"
		lossReason = "#GAMEMODE_FRIENDLY_PILOTS_ELIMINATED"
		winningTeam = TEAM_MILITIA

		setWinner = true
	}
	else if ( isPilotEliminationBased && !teamPlayers[TEAM_MILITIA] && teamPlayers[TEAM_IMC] )
	{
		winReason = "#GAMEMODE_ENEMY_PILOTS_ELIMINATED"
		lossReason = "#GAMEMODE_FRIENDLY_PILOTS_ELIMINATED"
		winningTeam = TEAM_IMC

		setWinner = true
	}
	else if ( isPilotEliminationBased && !teamPlayerTitans[TEAM_IMC] && !teamPlayerTitans[TEAM_MILITIA] && !setWinner )
	{
		local players = GetPlayerArray()
		local teams = {}
		teams[ TEAM_IMC ] <- 0
		teams[ TEAM_MILITIA ] <- 0

		foreach ( player in players )
		{
			if ( !IsAlive( player ) )
				continue

			teams[ player.GetTeam() ]++
		}

		if ( !teams[TEAM_IMC] && !teams[TEAM_MILITIA] )
		{
			winReason = "#GAMEMODE_NO_TITANS_REMAINING"
			lossReason = "#GAMEMODE_NO_TITANS_REMAINING"
			winningTeam = TEAM_UNASSIGNED

			setWinner = true
		}
	}
	else if ( setWinner )
	{
		if ( teamTitans[TEAM_IMC].len() > teamTitans[TEAM_MILITIA].len() )
		{
			winReason = "#GAMEMODE_TITAN_TITAN_ADVANTAGE"
			lossReason = "#GAMEMODE_TITAN_TITAN_DISADVANTAGE"
			winningTeam = TEAM_IMC
		}
		else if ( teamTitans[TEAM_MILITIA].len() > teamTitans[TEAM_IMC].len() )
		{
			winReason = "#GAMEMODE_TITAN_TITAN_ADVANTAGE"
			lossReason = "#GAMEMODE_TITAN_TITAN_DISADVANTAGE"
			winningTeam = TEAM_MILITIA
		}
		else
		{
			local teamTitanHealth = {}
			teamTitanHealth[TEAM_IMC] <- 0
			teamTitanHealth[TEAM_MILITIA] <- 0

			foreach ( titan in teamTitans[TEAM_IMC] )
			{
				if ( titan.GetDoomedState() )
					continue

				local titanTime = Time() - titan.GetTitanSoul().createTime
				teamTitanHealth[TEAM_IMC] += GetHealthFrac( titan )
			}

			foreach ( titan in teamTitans[TEAM_MILITIA] )
			{
				if ( titan.GetDoomedState() )
					continue

				local titanTime = Time() - titan.GetTitanSoul().createTime
				teamTitanHealth[TEAM_MILITIA] += GetHealthFrac( titan )
			}

			if ( teamTitanHealth[TEAM_IMC] > teamTitanHealth[TEAM_MILITIA] )
			{
				winReason = "#GAMEMODE_TITAN_DAMAGE_ADVANTAGE"
				lossReason = "#GAMEMODE_TITAN_DAMAGE_DISADVANTAGE"
				winningTeam = TEAM_IMC
			}
			else if ( teamTitanHealth[TEAM_MILITIA] > teamTitanHealth[TEAM_IMC] )
			{
				winReason = "#GAMEMODE_TITAN_DAMAGE_ADVANTAGE"
				lossReason = "#GAMEMODE_TITAN_DAMAGE_DISADVANTAGE"
				winningTeam = TEAM_MILITIA
			}
			else
			{
				winReason = "#GAMEMODE_TIME_LIMIT_REACHED"
				lossReason = "#GAMEMODE_TIME_LIMIT_REACHED"
				winningTeam = TEAM_UNASSIGNED
			}
		}
	}

	if ( setWinner && level.nv.winningTeam == null )
	{
		SetWinLossReasons( winReason, lossReason )
		SetWinner( winningTeam )
		return winningTeam
	}
	else
	{
		PlayLastTitanStandingDialogue( teamTitans )
		level.lastTeamTitans[TEAM_MILITIA] = teamTitans[TEAM_MILITIA].len()
		level.lastTeamTitans[TEAM_IMC] = teamTitans[TEAM_IMC].len()

		return winningTeam
	}
}

function PlayLastTitanStandingDialogue( teamTitans )
{
	if ( GAMETYPE == WINGMAN_LAST_TITAN_STANDING ) //Wingman LTS has its own custom dialogue
	{
		return
	}

	if ( level.nv.winningTeam != null )
		return

	if ( level.lastTeamTitans[TEAM_MILITIA] != teamTitans[TEAM_MILITIA].len() )
	{
		if ( teamTitans[TEAM_MILITIA].len() == 2 )
		{
			if ( GetCurrentPlaylistVarInt( "max_players", 12 ) > 4 )
				PlayConversationToTeam( "EnemyTitansLeftTwo", TEAM_IMC )
		}
		else if ( teamTitans[TEAM_MILITIA].len() == 1 && teamTitans[TEAM_IMC].len() == 1 )
		{
			local player = GetTitanPlayer( teamTitans[TEAM_MILITIA][0] )
				PlayConversationToPlayer( "TitanVsTitan", player )

			local player = GetTitanPlayer( teamTitans[TEAM_IMC][0] )
				PlayConversationToPlayer( "TitanVsTitan", player )
		}
		else if ( teamTitans[TEAM_MILITIA].len() == 1  )
		{
			PlayConversationToTeam( "EnemyTitansLeftOne", TEAM_IMC )

			local player = GetTitanPlayer( teamTitans[TEAM_MILITIA][0] )
			if ( player )
				PlayConversationToPlayer( "YouAreTheLastTitan", player )
		}
	}

	if ( level.lastTeamTitans[TEAM_IMC] != teamTitans[TEAM_IMC].len() )
	{
		if ( teamTitans[TEAM_IMC].len() == 2 )
		{
			if ( GetCurrentPlaylistVarInt( "max_players", 12 ) > 4 )
				PlayConversationToTeam( "EnemyTitansLeftTwo", TEAM_MILITIA )
		}
		else if ( teamTitans[TEAM_IMC].len() == 1 && teamTitans[TEAM_MILITIA].len() == 1 )
		{
			local player = GetTitanPlayer( teamTitans[TEAM_MILITIA][0] )
				PlayConversationToPlayer( "TitanVsTitan", player )

			local player = GetTitanPlayer( teamTitans[TEAM_IMC][0] )
				PlayConversationToPlayer( "TitanVsTitan", player )
		}
		else if ( teamTitans[TEAM_IMC].len() == 1 )
		{
			PlayConversationToTeam( "EnemyTitansLeftOne", TEAM_MILITIA )

			local player = GetTitanPlayer( teamTitans[TEAM_IMC][0] )
			if ( player )
				PlayConversationToPlayer( "YouAreTheLastTitan", player )
		}
	}
}


function GetTitanPlayer( titan )
{
	local player
	if ( titan.IsPlayer() )
		return titan
	else
		return titan.GetBossPlayer()
}


function ScoreLimit_Complete()
{
	local scoreLimit = GetScoreLimit_FromPlaylist()
	if ( !scoreLimit )
		return false

	if ( !GameRules.AllowMatchEnd() )
		return false

	local militiaScore = GameRules.GetTeamScore( TEAM_MILITIA )
	local imcScore = GameRules.GetTeamScore( TEAM_IMC )

	if ( ( militiaScore >= scoreLimit ) || ( imcScore >= scoreLimit ) )
	{
		local winningTeam = null
		if ( imcScore > militiaScore )
		{
			winningTeam = TEAM_IMC
		}
		else
		if ( imcScore < militiaScore )
		{
			winningTeam = TEAM_MILITIA
		}

		SetWinLossReasons( "#GAMEMODE_SCORE_LIMIT_REACHED", "#GAMEMODE_SCORE_LIMIT_REACHED" )
		SetWinner( winningTeam )
		return true
	}

	if ( IsSwitchSidesBased() && !HasSwitchedSides() )
	{
		if( level.nv.roundsPlayed == (scoreLimit - 1) )
		{
			SetGameState( eGameState.SwitchingSides )
			return true
		}
		/*
		if ( militiaScore >= (scoreLimit * 0.5) )
		{
			SetGameState( eGameState.SwitchingSides )
			return true
		}
		else if ( imcScore >= (scoreLimit * 0.5) )
		{
			SetGameState( eGameState.SwitchingSides )
			return true
		}
		*/
	}

	return false
}


function RoundScoreLimit_Complete()
{
	if ( !GameRules.AllowMatchEnd() )
		return false

	local roundLimit = GetRoundScoreLimit_FromPlaylist()

	if ( !roundLimit )
		return false

	if ( GAMETYPE == COOPERATIVE )
	{
		if ( Coop_PlayersHaveRestartsLeft() && !Flag( "ObjectiveComplete" ) )
			return false
		else
			return true
	}

	//TODO: Reexamine this next game? RoundScoreLimit_Complete shouldn't have side effect of setting winner sometimes
	local militiaScore = GameRules.GetTeamScore2( TEAM_MILITIA )
	local imcScore = GameRules.GetTeamScore2( TEAM_IMC )

	if ( ( militiaScore >= roundLimit ) || ( imcScore >= roundLimit ) || level.nv.roundsPlayed >= (roundLimit * 2) || level.privateMatchForcedEnd )
	{
		local winningTeam = TEAM_UNASSIGNED

		if ( imcScore > militiaScore )
			winningTeam = TEAM_IMC
		else if ( imcScore < militiaScore )
			winningTeam = TEAM_MILITIA

		if ( level.nv.winningTeam == null )
		{
			if ( level.privateMatchForcedEnd )
				SetWinLossReasons( "#GAMEMODE_HOST_ENDED_MATCH", "#GAMEMODE_HOST_ENDED_MATCH" )
			else if ( winningTeam == TEAM_UNASSIGNED )
				SetWinLossReasons( "#GAMEMODE_ROUND_LIMIT_REACHED", "#GAMEMODE_ROUND_LIMIT_REACHED" )
			else
				SetWinLossReasons( "#GAMEMODE_SCORE_LIMIT_REACHED", "#GAMEMODE_SCORE_LIMIT_REACHED" )
			SetWinner( winningTeam )
		}
		return true
	}

	return false
}


function TimeLimit_Complete()
{
	//Need to check with code how to set mp_enabletimelimit
	//and mp_timelimit
	if ( !GameRules.TimeLimitEnabled() )
		return false

	if ( !GameRules.AllowMatchEnd() )
		return false

	if ( Flag( "DisableTimeLimit" ) )
		return false

	local timeLimit

	if ( GetGameState() == eGameState.SuddenDeath )
		timeLimit = ( GetSuddenDeathTimeLimit_ForGameMode() * 60.0 ).tointeger()
	else if ( IsRoundBased() )
		timeLimit = ( GetRoundTimeLimit_ForGameMode() * 60.0 ).tointeger()
	else
		timeLimit = ( GetTimeLimit_ForGameMode() * 60.0 ).tointeger()

	if ( !timeLimit )
		return false

	// if (level.onCheckGameResult)
	// 	return level.onCheckGameResult.func.acall([level.onCheckGameResult.scope])

	if ( !GetCinematicMode() )
	{
		local timeLeftSeconds = GameTime.TimeLeftSeconds()

		if( GAMETYPE != BIG_BROTHER || !IsBigBrotherPanelHacked() )
		{
			if ( timeLeftSeconds < 15 && timeLeftSeconds != level.lastTimeLeftSeconds )
			{
				local players = GetPlayerArray()

				foreach ( player in players )
				{
					EmitSoundOnEntity( player, "Menu_Match_Countdown" )

					if ( timeLeftSeconds < 5 && timeLeftSeconds >= 0 )
						EmitSoundOnEntityAfterDelay( player, "Menu_Match_Countdown", 0.5 )
				}
			}
		}
		else // 폭파미션 폭탄 설치시 비프음.
		{
			if( IsBigBrotherPanelHacked() && timeLeftSeconds < 45 && timeLeftSeconds != level.lastTimeLeftSeconds)
			{
				local players = GetPlayerArray()

				foreach ( player in players )
				{
					EmitSoundOnEntity( player, "Menu_Match_Countdown" )

					if ( timeLeftSeconds < 30 && timeLeftSeconds >= 15 )
						EmitSoundOnEntityAfterDelay( player, "Menu_Match_Countdown", 0.5 )

					else if ( timeLeftSeconds < 15 && timeLeftSeconds >= 0 )
					{
						EmitSoundOnEntityAfterDelay( player, "Menu_Match_Countdown", 0.2 )
						EmitSoundOnEntityAfterDelay( player, "Menu_Match_Countdown", 0.4 )
						EmitSoundOnEntityAfterDelay( player, "Menu_Match_Countdown", 0.6 )
						EmitSoundOnEntityAfterDelay( player, "Menu_Match_Countdown", 0.8 )
					}
				}
			}
		}

		if ( IsSwitchSidesBased() && !HasSwitchedSides() && !IsRoundBased() ) // TODO: fix LTS switching sides announcement
		{
			if ( timeLeftSeconds == 30 && timeLeftSeconds != level.lastTimeLeftSeconds )
			{
				PlayConversationToTeam( "SwitchingSidesSoon", TEAM_MILITIA )
				PlayConversationToTeam( "SwitchingSidesSoon", TEAM_IMC )
			}
		}

		level.lastTimeLeftSeconds = timeLeftSeconds
	}

	if ( GameTime.TimeSpentInCurrentState() > timeLimit )
	{
		if ( IsSwitchSidesBased() && !HasSwitchedSides() && !IsRoundBased() )
		{
			SetGameState( eGameState.SwitchingSides )
			return true
		}
		else if ( IsEliminationBased() )
		{
			ForceEliminationModeWinner()
			return true
		}

		local winningTeam = TEAM_UNASSIGNED


			local militiaScore = GameRules.GetTeamScore( TEAM_MILITIA )
			local imcScore = GameRules.GetTeamScore( TEAM_IMC )

			if ( imcScore > militiaScore )
				winningTeam = TEAM_IMC
			else if ( imcScore < militiaScore )
				winningTeam = TEAM_MILITIA


		SetWinLossReasons( "#GAMEMODE_TIME_LIMIT_REACHED", "#GAMEMODE_TIME_LIMIT_REACHED" )
		SetWinner( winningTeam )
		return true
	}
}


function GameRulesThink_Playing()
{
	UpdateMatchProgress()

	if ( GameTime.PlayingTime() >= START_SPAWN_GRACE_PERIOD )
	{
		if ( (Time() - level.lastPlayingEmptyTeamCheck) > 1.0 )
		{
			CheckForEmptyTeamVictory()
			level.lastPlayingEmptyTeamCheck = Time()
		}
	}

	if ( EliminationMode_Complete() )
		return

	if ( !IsRoundBased() && ScoreLimit_Complete() )
		return

	if ( TimeLimit_Complete() )
		return

	foreach ( callbackInfo in level.playingThinkFuncTable )
	{
		callbackInfo.func.acall( [callbackInfo.scope] )
	}
}


function GameRulesThink_WinnerDetermined()
{
	if ( GameTime.TimeSpentInCurrentState() < GetWinnerDeterminedWait() )
	{
		if ( ShouldClearPlayersInWinnerDetermined() )
		{
			if ( GameTime.TimeSpentInCurrentState() > GetWinnerDeterminedWait() - CLEAR_PLAYERS_BUFFER && !level.clearedPlayers )
			{
				ClearPlayers()
				level.clearedPlayers = true
			}

			if ( GAMETYPE == COOPERATIVE )
			{
				if ( !Flag( "ClassicMP_UsingCustomIntro" ) )
				{
					local players = GetPlayerArray()
					foreach ( player in players )
						AddPlayerToDropshipSpawnPlayerList( player )  // lets them use the normal intro spawn path for retry instead of the spawn-in-progress path
				}
			}
		}

		return
	}

	level.clearedPlayers = false

	if ( GAMETYPE == COOPERATIVE )
	{
		if ( !Coop_IsGameOver() )
			SetGameState( eGameState.Prematch )
		return
	}

	if ( !IsRoundBased() ) //Should probably do a check for ShouldRunEvac() here. One annoying thing though is that for O2 cinematic, ShouldRunEvac() will return false but it should still run an epilogue
	{
		SetGameState( eGameState.Epilogue )
		return
	}

	// maybe no players left on enemy team
	local defaultWinner = TEAM_UNASSIGNED
	if ( GetTeamPlayerCount( TEAM_MILITIA ) == 0 )
		defaultWinner = TEAM_IMC
	else if ( GetTeamPlayerCount( TEAM_IMC ) == 0 )
		defaultWinner = TEAM_MILITIA

	if ( IsRoundBasedGameOver() )
	{
		if ( !ShouldRunEvac() )
			SetGameState( eGameState.Postmatch )
		else
			SetGameState( eGameState.Epilogue )
		return
	}

	local roundLimit = GetRoundScoreLimit_FromPlaylist()

	//local idealMinSwitchSides = roundLimit * 0.5
	//local idealMaxSwitchSides = ( ( roundLimit * 2 ) - 1 ) * 0.5
	//local idealSwitchSides = floor( ( ( idealMinSwitchSides + idealMaxSwitchSides ) * 0.5 ) + 0.49 ) // average, round to closest (1.5 rounds to 1.0, 1.6 to 2.0)

	if ( roundLimit && level.nv.roundsPlayed == (roundLimit-1) && IsSwitchSidesBased() )
	{
		SetGameState( eGameState.SwitchingSides )
		return
	}

	SetGameState( eGameState.Prematch )
}

function ShouldClearPlayersInWinnerDetermined()
{
	if ( !IsRoundBased() )
		return false

	if ( WillShowRoundWinningKillReplay() )
	{
		if ( RoundScoreLimit_Complete() ) //Don't do clear players in final round to avoid a bug with not consuming Titan Burn Cards
			return false
		else
			return true
	}

	if ( GAMETYPE == COOPERATIVE && (Flag( "ObjectiveComplete" ) || Flag( "ObjectiveFailed")) )
		return false  // we don't want to clear the players now: coop game is over, so we're switching maps instead of checkpoint restarting

	if ( !RoundScoreLimit_Complete() )
		return true

	return false

}
Globalize( ShouldClearPlayersInWinnerDetermined )

function TakeAmmoFromPlayer( player )
{
	local mainWeapons = player.GetMainWeapons()
	local offhandWeapons = player.GetOffhandWeapons()

	foreach ( weapon in mainWeapons )
	{
		weapon.SetWeaponPrimaryAmmoCount( 0 )
		weapon.SetWeaponPrimaryClipCount( 0 )
		printt( weapon )
	}

	foreach ( weapon in offhandWeapons )
	{
		weapon.SetWeaponPrimaryAmmoCount( 0 )
		weapon.SetWeaponPrimaryClipCount( 0 )
		printt( weapon )
	}
}


function IsRoundBasedGameOver()
{
	// maybe no players left on enemy team
	local defaultWinner = TEAM_UNASSIGNED
	if ( GetTeamPlayerCount( TEAM_MILITIA ) == 0 )
		defaultWinner = TEAM_IMC
	else if ( GetTeamPlayerCount( TEAM_IMC ) == 0 )
		defaultWinner = TEAM_MILITIA

	if ( RoundScoreLimit_Complete() || (defaultWinner != TEAM_UNASSIGNED && level.nv.roundsPlayed > 1) )
		return true

	return false
}
Globalize( IsRoundBasedGameOver )

function GameRulesThink_SwitchingSides()
{
	if ( GameTime.TimeSpentInCurrentState() < SWITCHING_SIDES_DELAY )
	{
		if ( GameTime.TimeSpentInCurrentState() > SWITCHING_SIDES_DELAY - CLEAR_PLAYERS_BUFFER && !level.clearedPlayers )
		{
			ClearPlayers()
			level.clearedPlayers = true
		}
		return
	}

	level.clearedPlayers = false

	// iskyfish - 공수 전환 시에도 기존 타이탄 룰 유지. 모드마다 다르게 하고 싶다면 여기서 분기 타던가 따로 타입을 만들어서 설정해야 한다.
	//local players = GetPlayerArray()
	//foreach ( player in players )
	//{
	//	player.titansBuilt = 0
	//}

	SetGameState( eGameState.Prematch )
}

function GameRulesThink_SuddenDeath()
{
	if ( GAMETYPE == CAPTURE_THE_FLAG )
	{
		if ( EliminationMode_Complete() )
		{
			level.evacEnabled = false
			ForceEliminationModeWinner()
			return
		}

		local militiaScore = GameRules.GetTeamScore( TEAM_MILITIA )
		local imcScore = GameRules.GetTeamScore( TEAM_IMC )

		if ( militiaScore != imcScore )
		{
			SetWinner( militiaScore > imcScore ? TEAM_MILITIA : TEAM_IMC )
			return
		}
	}

	if ( TimeLimit_Complete() )
		return
}

function SuddenDeathPlayerDied( player, damageInfo )
{
	local attacker = damageInfo.GetAttacker()
	if ( IsValid( attacker ) && attacker.IsPlayer() )
		SetWinner( attacker.GetTeam() )
}

function GameRulesThink_Epilogue()
{
	local epilogueRespawnTimeLimit = level.nv.gameEndTime + GAME_EPILOGUE_PLAYER_RESPAWN_LEEWAY
	if ( Time() > epilogueRespawnTimeLimit )
	{
		local players = GetPlayerArray()
		foreach ( player in players )
		{
			// allow players who died before the game ended and may still be watching kill replay a chance to respawn
			if ( !IsAlive( player ) && player.s.postDeathThreadStartTime < epilogueRespawnTimeLimit )
				continue

			if ( GetCinematicMode() && GetMapName() == "mp_o2" )
				continue

			if ( !IsPlayerEliminated( player ) )
				SetPlayerEliminated( player )
		}
	}

	if ( GameTime.TimeSpentInCurrentState() > GetEpilogueDuration() )
		SetGameState( eGameState.Postmatch )
}


function GameRulesThink_Postmatch()
{
	if ( GameTime.TimeSpentInCurrentState() < GAME_POSTMATCH_LENGTH )
		return

	level.postMatchTimeComplete = true

	if ( level.endingMatch )
		return

	GameRules_EndMatch()
}

enum eGameCloseness
{
	VeryClose,
	Close,
	BadGame,
	Blowout,
}

function GetMatchCloseness( scores )
{
	local highScore = (scores[TEAM_IMC] > scores[TEAM_MILITIA] ? scores[TEAM_IMC] : scores[TEAM_MILITIA]).tofloat()
	local lowScore = (scores[TEAM_IMC] > scores[TEAM_MILITIA] ? scores[TEAM_MILITIA] : scores[TEAM_IMC]).tofloat()

	if ( !highScore )
		return eGameCloseness.VeryClose

	local closeFrac = lowScore / highScore

	if ( closeFrac <= 0.49 )
		return eGameCloseness.Blowout
	else if ( closeFrac <= 0.74 )
		return eGameCloseness.BadGame
	else if ( closeFrac <= 0.85 )
		return eGameCloseness.Close
	else
		return eGameCloseness.VeryClose
}

function GetMatchHistory( num )
{
	local matchHistory = []
	local maxMapIndex = num * 2
	local mapName
	local teams = [ TEAM_IMC, TEAM_MILITIA ]

	local scores = {}
	scores[TEAM_IMC] <- null
	scores[TEAM_MILITIA] <- null

	local scoresValid
	local winner

	for ( local i = 0; i < maxMapIndex; i++ )  // 0 is the just finished match I'm in
	{
		mapName = GameRules.GetRecentMap( i )

		foreach ( team in teams )
		{
			if ( i == 0 )
				scores[team] = GameRules.GetTeamScore( team )
			else
				scores[team] = GameRules.GetRecentTeamScore( team, i )

			if ( scores[team] == -1 )
			{
				scoresValid = false
				//printt( "mapName:", mapName, "team:", team, "scoresValid = false" )
				//printt( "mapName:", mapName, "breaking" )
				break
			}

			scoresValid = true
			//printt( "mapName:", mapName, "team:", team, "scoresValid = true" )
		}

		if ( ( /*mapName != "mp_lobby" &&*/ mapName != "") && scoresValid )
		{
			if ( scores[TEAM_IMC] == scores[TEAM_MILITIA] )
				winner = null
			else if ( scores[TEAM_IMC] > scores[TEAM_MILITIA] )
				winner = TEAM_IMC
			else
				winner = TEAM_MILITIA

			matchHistory.append( { map = mapName, scores = clone( scores ), winner = winner, closeness = GetMatchCloseness( scores ) } )
			//printt( "Appending to matchHistory, mapName:", mapName, "scores:" )
			//PrintTable( scores )
		}
	}

	return matchHistory
}

function GetMatchHistoryWinner( matchHistory )
{
	local wins = {}
	wins[TEAM_IMC] <- 0
	wins[TEAM_MILITIA] <- 0

	foreach ( match in matchHistory )
	{
		if ( match.winner )
			wins[match.winner]++
	}

	local winningTeam

	if ( wins[TEAM_IMC] == wins[TEAM_MILITIA] )
		winningTeam = null
	else if ( wins[TEAM_IMC] > wins[TEAM_MILITIA] )
		winningTeam = TEAM_IMC
	else
		winningTeam = TEAM_MILITIA

	return winningTeam
}

function GetWinnerDeterminedWait()
{
	if ( IsRoundBased() )
	{
		if ( GAMETYPE == COOPERATIVE )
		{
			if ( Flag( "TDGeneratorDestroyed" ) )
			{
				if ( Coop_PlayersHaveRestartsLeft() )
					return GAME_WINNER_DETERMINED_RETRY_WAIT_COOP
				else
					return GAME_WINNER_DETERMINED_GAME_OVER_WAIT_COOP
			}
			else
			{
				return GAME_WINNER_DETERMINED_GAME_OVER_WAIT_COOP
			}
		}
		else
		{
			if ( WillShowRoundWinningKillReplay() )
			{
				if ( RoundScoreLimit_Complete() )
					return GAME_WINNER_DETERMINED_FINAL_ROUND_WITH_ROUND_WINNING_KILL_REPLAY_WAIT
				else
					return GAME_WINNER_DETERMINED_ROUND_WAIT_WITH_ROUND_WINNING_KILL_REPLAY_WAIT
			}
			else if ( RoundScoreLimit_Complete() )
			{
				return GAME_WINNER_DETERMINED_FINAL_ROUND_WAIT
			}
			else
			{
				return GAME_WINNER_DETERMINED_ROUND_WAIT
			}
		}
	}
	else
	{
		return GAME_WINNER_DETERMINED_WAIT
	}
}

function GetCodeMatchPhaseForGameState()
{
	local gameState = GetGameState()
	switch( gameState )
	{
		case eGameState.WaitingForPlayers:
		case eGameState.PickLoadout:
		case eGameState.Prematch:
			return MATCHPHASE_PREMATCH

		case eGameState.Playing:
		case eGameState.SwitchingSides:
			return MATCHPHASE_MATCH

		case eGameState.SuddenDeath:
		case eGameState.WinnerDetermined:
		case eGameState.Epilogue:
		case eGameState.Postmatch:
			return MATCHPHASE_EPILOGUE

		case null:
			return MATCHPHASE_UNSPECIFIED
		default:
			printt( " ** Warning: GetCodeMatchPhaseForGameState() - Unhandeled eGameState", gameState )
			return MATCHPHASE_UNSPECIFIED
	}
}

function UpdateMatchStateToCode()
{
	local maxRounds
	local roundsIMC
	local roundsMilitia
	local scoreLimit
	local scoreIMC
	local scoreMilitia
	if ( IsCoopMatch() && GAMETYPE == COOPERATIVE )
	{
		maxRounds = GetRoundScoreLimit_FromPlaylist()							// continues allowed
		roundsIMC = 0
		roundsMilitia = (maxRounds - level.nv.coopRestartsAllowed)				// continues used
		scoreLimit = (level.nv.TDNumWaves != null ? level.nv.TDNumWaves : 0)	// # of waves
		scoreIMC = 0
		//TDCurrWave is null during the prematch phase and we rely on null meaning stuff for the HUD.
		if ( GetGameState() <= eGameState.Prematch && roundsMilitia == 0 )
			scoreMilitia = 1
		else
			scoreMilitia = (level.nv.TDCurrWave != null ? level.nv.TDCurrWave : 0)	// current wave
	}
	else if ( IsRoundBased() )
	{
		maxRounds = GetRoundScoreLimit_FromPlaylist()
		roundsIMC = GameRules.GetTeamScore2( TEAM_IMC )
		roundsMilitia = GameRules.GetTeamScore2( TEAM_MILITIA )
		scoreLimit = GetRoundScoreLimit_FromPlaylist()
		scoreIMC = GameRules.GetTeamScore2( TEAM_IMC )
		scoreMilitia = GameRules.GetTeamScore2( TEAM_MILITIA )
	}
	else
	{
		maxRounds = 1
		roundsIMC = 0
		roundsMilitia = 0
		scoreLimit = GetScoreLimit_FromPlaylist()
		scoreIMC = GameRules.GetTeamScore( TEAM_IMC )
		scoreMilitia = GameRules.GetTeamScore( TEAM_MILITIA )
	}

	local timeLimit
	local timePassed
	if ( GameRules.TimeLimitEnabled() )
	{
		timeLimit = ( GetTimeLimit_ForGameMode() * 60.0 ).tointeger()
		timePassed = GameTime.PlayingTime().tointeger()
	}
	else
	{
		timeLimit = 0
		timePassed = GameTime.PlayingTime().tointeger()
	}

	local phase = GetCodeMatchPhaseForGameState()
	//printt( "NoteMatchState:", phase, maxRounds, roundsIMC, roundsMilitia, timeLimit, timePassed, scoreLimit, scoreIMC, scoreMilitia )
	NoteMatchState( phase, maxRounds, roundsIMC, roundsMilitia, timeLimit, timePassed, scoreLimit, scoreIMC, scoreMilitia )
}

function UpdateMatchProgress()
{
	local progress_score = GetMatchProgress_Score()
	local progress_time = GetMatchProgress_Time()

	if ( IsSwitchSidesBased() && !IsRoundBased() )
	{
		progress_time *= 0.5

		if ( HasSwitchedSides() )
			progress_time += 50.0
	}

	local progress = max( progress_score, progress_time )

	progress = floor( progress ).tointeger()

	if ( level.nv.matchProgress != progress )
	{
		level.nv.matchProgress = progress
		//printt( "Match Progress: " + progress + "%" )
		Announce_Progress( progress )
	}
}

function GetMatchProgress_Score( team = null )
{
	// Returns a percent of progress for score 0.0 - 100.0%
	// Uses the team with higher score as returned progress

	local scoreLimit
	local militiaScore
	local imcScore

	if ( IsRoundBased() )
	{
		scoreLimit = GetRoundScoreLimit_FromPlaylist()
		militiaScore = GameRules.GetTeamScore2( TEAM_MILITIA )
		imcScore = GameRules.GetTeamScore2( TEAM_IMC )
	}
	else
	{
		scoreLimit = GetScoreLimit_FromPlaylist()
		militiaScore = GameRules.GetTeamScore( TEAM_MILITIA )
		imcScore = GameRules.GetTeamScore( TEAM_IMC )
	}

	if ( !scoreLimit )
		return 0.0

	local militiaProgress = ( militiaScore.tofloat() / scoreLimit.tofloat() ) * 100.0
	local imcProgress = ( imcScore.tofloat() / scoreLimit.tofloat() ) * 100.0

	if ( team == TEAM_MILITIA )
		return militiaProgress
	else if ( team == TEAM_IMC )
		return imcProgress

	return max( militiaProgress, imcProgress )
}


function GetMatchProgress_Time()
{
	// Returns a percent of progress for time limit 0.0 - 100.0%

	if ( !GameRules.TimeLimitEnabled() )
		return 0.0

	if ( IsRoundBased() )
		return 0.0

	if ( !GetTimeLimit_ForGameMode() )
		return 0.0

	if ( Flag( "DisableTimeLimit" ) )
		return 0.0

	local timeLimit = ( GetTimeLimit_ForGameMode() * 60.0 ).tointeger()

	if ( !timeLimit )
		return 0.0

	return ( GameTime.PlayingTime().tofloat() / timeLimit.tofloat() ) * 100.0
}


function GetMatchProgress()
{
	return level.nv.matchProgress
}



function ForceEpilogueEnd()
{
	if ( GetGameState() >= eGameState.WinnerDetermined )
		SetGameState( eGameState.Postmatch )
}


function HaveCrossedHalfPointInGameScore( totalScore, scoreLimit )
{
	return ( totalScore == scoreLimit - 1 ) || ( totalScore == (scoreLimit - 1 ) * 2 )
}


function Announce_Progress( progression )
{
	if ( !Flag( "AnnounceProgressEnabled" ) )
		return

	//Call custom match progress announcement function if it exists
	if ( level.matchProgressAnnounceFunc )
	{
		local callbackInfo = level.matchProgressAnnounceFunc
		callbackInfo.func.acall( [callbackInfo.scope, progression ] )
		return
	}

	DefaultMatchProgressionAnnouncement( progression )
}


function DefaultMatchProgressionAnnouncement( progression )
{
	local winningTeam = GetWinningTeam()

	if ( !GetTeamIndex(winningTeam) )
		return

	if ( progression < level.nextMatchProgressAnnouncementLevel  )
		return

	local announcements = {}
    announcements.winningAnnouncement <- null
    announcements.losingAnnouncement <- null
	SetMatchProgressAnnouncements( progression, announcements )

	Assert( announcements.winningAnnouncement!= null )
	Assert( announcements.losingAnnouncement!= null )

	PlayConversationToTeam( announcements.winningAnnouncement, GetTeamIndex(winningTeam) )
	local losingTeam = GetOtherTeam(winningTeam)
	PlayConversationToTeam( announcements.losingAnnouncement, GetTeamIndex(losingTeam) )


	//Set the nextMatchProgressAnnouncementLevel
	foreach( matchProgressThreshold in MATCH_PROGRESS_THRESHOLDS )
	{
		if ( level.nextMatchProgressAnnouncementLevel < matchProgressThreshold )
		{
			level.nextMatchProgressAnnouncementLevel = matchProgressThreshold
			//printt( "Setting match progressThreshold to :" + matchProgressThreshold )
			break
		}

	}
}

function SetMatchProgressAnnouncements( progression, announcements )
{
	local matchProgressState

	if ( progression >= MATCH_PROGRESS_LATE )
		matchProgressState = "MatchLate"
	else if ( progression >= MATCH_PROGRESS_MID )
		matchProgressState = "MatchMid"
	else
		matchProgressState = "MatchEarly"

	local scoreRatio = max( GameScore.GS_GetScoreRatio(), GameScore.GS_GetScoreNeededRatio() )
    //printt( "scoreRatio: " + scoreRatio )
	if ( scoreRatio >= 0.95 )
	{
		announcements.winningAnnouncement = "CloseScore" + matchProgressState
		announcements.losingAnnouncement = "CloseScore" + matchProgressState
		//printt( "CloseScore, playing to both teams announcement: " + announcements.winningAnnouncement )
		return
	}

	local isBigMargin = scoreRatio <= 0.75
	if ( isBigMargin )
	{
			announcements.winningAnnouncement = "WinningScoreBigMargin" + matchProgressState
			announcements.losingAnnouncement = "LosingScoreBigMargin" + matchProgressState
			//printt( "BigMarginScore, playing to winner: " + announcements.winningAnnouncement + ", playing to loser: " +  announcements.losingAnnouncement )
			return
	}
	else
	{
			announcements.winningAnnouncement = "WinningScoreSmallMargin" + matchProgressState
			announcements.losingAnnouncement = "LosingScoreSmallMargin" + matchProgressState
			//printt( "BigMarginScore, playing to winner: " + announcements.winningAnnouncement + ", playing to loser: " +  announcements.losingAnnouncement )
			return
	}

}

function AnnounceWinner( winningTeam )
{
	if ( winningTeam ) //No announcement if draw
	{
		local losingTeam = GetOtherTeam( GetWinningTeam() )

		local teamPlayers = {}
		teamPlayers[winningTeam] <- []
		teamPlayers[losingTeam] <- []

		local compareFunc = GetScoreboardCompareFunc()
		teamPlayers[winningTeam] = GetSortedPlayers( compareFunc, winningTeam )
		teamPlayers[losingTeam] = GetSortedPlayers( compareFunc, losingTeam )

		foreach ( rank, player in teamPlayers[winningTeam] )
		{
			player.SetRank( rank+1 );
		}

		foreach ( rank, player in teamPlayers[losingTeam] )
		{
			player.SetRank( rank+1 );
		}

		GameRules.MarkGameStateWinnerDetermined(winningTeam)

		if ( GetGameWonAnnouncement() == null ) //If a custom announcement is set already, use that
		{
			if ( ShouldRunEvac()  )
				SetGameWonAnnouncement( "WonAnnouncementWithEvac" )
			else
				SetGameWonAnnouncement( "WonAnnouncement" )
		}

		if ( GetGameLostAnnouncement() == null ) //If a custom announcement is set already, use that
		{
			if ( ShouldRunEvac()  )
				SetGameLostAnnouncement( "LostAnnouncementWithEvac" )
			else
				SetGameLostAnnouncement( "LostAnnouncement" )
		}

		printt( "Winners " + winningTeam + " " + TEAM_IMC + " " + TEAM_MILITIA )

		PlayConversationToTeam( GetGameWonAnnouncement(), winningTeam )
		PlayConversationToTeam( GetGameLostAnnouncement(), losingTeam )
	}
	else
		GameRules.MarkGameStateWinnerDetermined(0)

	local players = GetPlayerArray()
	foreach ( player in players )
	{
		if ( ShouldRunEvac() )
			SetWinLossReasons( "#GAMEMODE_AWAIT_INSTRUCTIONS", "#GAMEMODE_PREPARE_FOR_EVAC" ) // TODO: set these accurately elsewhere, there might not always be an evac
		else if ( !IsRoundBased() )
			SetWinLossReasons( null, null ) // TODO: set these accurately elsewhere, there might not always be an evac

		local subString

		if (IsWinningTeam(player.GetTeam()))
			subString = level.winString
		else
			subString = level.lossString

		local subStringIndex
		if ( subString )
			subStringIndex = GetStringID( subString )

		Remote.CallFunction_NonReplay( player, "ServerCallback_AnnounceWinner", 0, subStringIndex, GetWinnerDeterminedWait()  )
	}
}

function AnnounceRoundWinner()
{
	local players = GetPlayerArray()
	foreach ( player in players )
	{
		local subString

		// HACK: swap the loss/win strings due to how nexon handles teams
		if (IsWinningTeam(player.GetTeam()))
			subString = level.winString
		else
			subString = level.lossString

		local subStringIndex
		if ( subString )
			subStringIndex = GetStringID( subString )

		local imcTeamScore2 = GameRules.GetTeamScore2( TEAM_IMC )
		local militiaTeamScore2 = GameRules.GetTeamScore2( TEAM_MILITIA )

		Remote.CallFunction_NonReplay( player, "ServerCallback_AnnounceRoundWinner", player.GetTeam(), subStringIndex, GetWinnerDeterminedWait(), imcTeamScore2, militiaTeamScore2 )
	}

	GameRules.AnnounceRoundWinner(level.nv.winningTeam)
}


function CheckMap()
{
	//look for titan starts
	//check if there are 6 of the militia team, 6 imc team
	local titan_starts_array = GetEntArrayByClass_Expensive( "info_spawnpoint_titan_start" )
	local titan_starts = titan_starts_array.len()
	printl( titan_starts + " (12 min) info_spawnpoint_titan_start entities" )

	local militia_starts = 0
	local imc_starts = 0
	foreach( start in titan_starts_array )
	{
		if ( start.GetTeam() == TEAM_MILITIA )
			militia_starts++
		if ( start.GetTeam() == TEAM_IMC )
			imc_starts++
	}
	printl( militia_starts + " (6 min) info_spawnpoint_titan_start entities for team MILITIA" )
	printl( imc_starts + " (6 min) info_spawnpoint_titan_start entities for team IMC" )


	//look for titan spawns
	local titan_spawns = GetEntArrayByClass_Expensive( "info_spawnpoint_titan" ).len()
	printl( titan_spawns + " (6 min) info_spawnpoint_titan entities" )

	//look for human spawns
	local human_spawns = GetEntArrayByClass_Expensive( "info_spawnpoint_human" ).len()
	printl( human_spawns + " (6 min) info_spawnpoint_human entities" )


	//look for NPC starts
	//check if there are 6 of the militia team, 6 imc team
	local npc_starts_array = SpawnPoints_GetDropPodStart( TEAM_ANY )
	local npc_starts = npc_starts_array.len()
	printl( npc_starts + " (12 min) info_spawnpoint_droppod_start entities" )

	local militia_npc_starts = 0
	local imc_npc_starts = 0
	foreach( start in npc_starts_array )
	{
		if ( start.GetTeam() == TEAM_MILITIA )
			militia_npc_starts++
		if ( start.GetTeam() == TEAM_IMC )
			imc_npc_starts++
	}
	printl( militia_npc_starts + " (6 min) info_spawnpoint_droppod_start entities for team MILITIA " )
	printl( imc_npc_starts + " (6 min) info_spawnpoint_droppod_start entities for team IMC" )

	//look for NPC spawns
	local npc_spawns = SpawnPoints_GetDropPod().len()
	printl( npc_spawns + " (6 min) info_spawnpoint_droppod entities" )


	Assert( titan_starts >= 12, "Less than 12 info_spawnpoint_titan_start entities" )
	Assert( militia_starts >= 6, "Less than 6 info_spawnpoint_titan_start entities for team MILITIA" )
	Assert( imc_starts >= 6, "Less than 6 info_spawnpoint_titan_start entities for team IMC" )
	Assert( titan_spawns >= 6, "Less than 6 info_spawnpoint_titan entities" )
	Assert( human_spawns >= 6, "Less than 6 info_spawnpoint_human entities" )
	Assert( npc_starts >= 12, "Less than 12 info_spawnpoint_droppod_start entities" )
	Assert( militia_npc_starts >= 6, "Less than 6 info_spawnpoint_droppod_start entities for team MILITIA" )
	Assert( imc_npc_starts >= 6, "Less than 6 info_spawnpoint_droppod_start entities for team IMC" )
	Assert( npc_spawns >= 6, "Less than 6 info_spawnpoint_droppod entities" )
}


function GetGameWonAnnouncement()
{
	return level.gameWonAnnouncement
}


function SetGameWonAnnouncement( announcement )
{
	level.gameWonAnnouncement = announcement
}


function GetGameLostAnnouncement()
{
	return level.gameLostAnnouncement
}


function SetGameLostAnnouncement( announcement )
{
	level.gameLostAnnouncement = announcement
}


function GetGameModeAnnouncement()
{
	if ( GameMode_IsDefined( GAMETYPE )  && !GetCinematicMode() ) //New style of game mode scripts
		return GameMode_GetGameModeAnnouncement( GAMETYPE )
	else //Old style of game mode scripts
		return level.gameModeAnnouncement
}


function SetGameModeAnnouncement( announcement ) //TODO: Old style of game mode scripts, remove when we eventually convert all modes to new styles
{
	level.gameModeAnnouncement = announcement
}

function PerfInitLabels()
{
	PerfClearAll()

	local table = getconsttable().PerfIndexServer
    foreach( string, int in table )
         PerfInitLabel( int, string.tostring() )

	local sharedTable = getconsttable().PerfIndexShared
    foreach( string, int in sharedTable )
         PerfInitLabel( int + SharedPerfIndexStart, string.tostring() )
}


function GameStartSpawnPlayers()
{
	printt( "GameStartSpawnPlayers" )
	// cinematic is responsible for start spawn
	if ( Flag( "CinematicIntro" ) )
	{
		printt( "hitting cinematic ret ")
		return
	}

	local players = GetPlayerArray()

	if ( GetClassicMPMode() && ClassicMP_CanUseIntroStartSpawn() && level.classicMP_prematchSpawnPlayersFunc )
	{
		printt( "ClassicMP_CallPrematchSpawnPlayersFunc" )
		ClassicMP_CallPrematchSpawnPlayersFunc( players )
	}

	if ( ShouldIntroSpawnAsTitan() )
		{
			printt( "ShouldIntroSpawnAsTitan == true" )
			foreach ( player in players )
			{
				if ( IsAlive( player ) )
					continue

				if ( IsValid( player.isSpawning ) )
					continue

				player.SetPlayerSettings( "spectator" )
				SetPlayerToDefaultViewPoint( player )
			}

			WaittillGameStateOrHigher( eGameState.Playing )
		}

	foreach ( player in players )
	{
		if ( !IsValid( player ) )
		{
				printt( "Player is not valid" )
				continue
		}

		if ( IsAlive( player ) )
		{
			// printt( "Player " + player.name + " is already alive" )
			continue
		}

		if ( IsValid( player.isSpawning ) )
		{
			// printt( "Player " + player.name + " is already spawning" )
			continue
		}

		DecideRespawnPlayer( player )
	}
}

function SetSwitchSidesBased( state )
{
	level.nv.switchedSides = state ? 0 : null
}

function SetRoundBased( state )
{
	level.nv.roundBased = state
}

function SetAttackDefendBased( state )
{
	level.attackDefendBased = state
}

function GameStateControlCheck( player )
{
	if ( GetGameState() <= eGameState.Prematch )
	{
		if ( Flag( "CinematicIntro" ) )
			return

		if ( GetClassicMPMode() && ClassicMP_CanUseIntroStartSpawn() )
			return

		player.FreezeControlsOnServer( false )
	}
}


function GetEpilogueDuration()
{
	if ( GetCustomEpilogueDuration() != null )
		return GetCustomEpilogueDuration()

	if ( ShouldRunEvac() )
	{
		local totalWaitTime = GetWinnerDeterminedWait() + Evac_GetDropshipArrivalWaitTime() + EVAC_SHIP_IDLE_TIME +  Evac_GetPostEvacDialogueTime() +  EVAC_BUFFER_TIME //8 seconds of buffer time to allow for assorted waits here and there in the evac system.
		//printt( "Total epilogue evac time: " + totalWaitTime )
		return totalWaitTime
	}

	return 2.0
}

function SetCustomEpilogueDuration( time )
{
	level.customEpilogueDuration = time
}

function GetCustomEpilogueDuration()
{
	return level.customEpilogueDuration
}

function ShouldDoScoreSwapVO( currentTeamScore, newTeamScore, enemyTeamScore )
{
	Assert( newTeamScore > currentTeamScore  )

	if ( GameScore.GetFirstToScoreLimit() )
		return false

	if ( newTeamScore <= enemyTeamScore )
		return false

	if ( currentTeamScore > enemyTeamScore )
		return false

	//printt( "ShouldDoScoreSwapVO is true" )

	return true
}

function ScoreSwapVO( aheadTeam, behindTeam )
{
	thread CatchUpFallBehindVO( aheadTeam, behindTeam )

	local progressFrac = GetMatchProgress()

	if ( progressFrac < 25 )
		return

	if ( Time() - level.lastScoreSwapVOTime < 10.0 )
		return

	level.lastScoreSwapVOTime = Time()

	PlayConversationToTeam( "PullAhead", aheadTeam )
	PlayConversationToTeam( "FallBehind", behindTeam )
}

function CatchUpFallBehindVO( aheadTeam, behindTeam ) //Thread is started every time lead swaps, and previous thread is killed
{
	level.ent.Signal( "CatchUpFallBehindVO" )
	level.ent.EndSignal( "CatchUpFallBehindVO" )

	while( GetMatchProgress() < 25 ) //Don't comment if it's too early in the game
		wait 5.0

	local randomWaitTime = RandomFloat( 60.0, 90.0 )
	local previousScoreRatio = max( GameScore.GS_GetScoreRatio(), GameScore.GS_GetScoreNeededRatio() )
	//printt( "Waiting randomTime: " + randomWaitTime + " before loop" )

	wait randomWaitTime

	while ( true )
	{
		//printt( "Waiting 3s in loop" )
		wait 3.0
		if ( !GamePlaying() )
			continue

		local currentAheadTeamScore = GameRules.GetTeamScore( aheadTeam )
		local currentBehindTeamScore =  GameRules.GetTeamScore( behindTeam )
		Assert( currentAheadTeamScore >=  currentBehindTeamScore) //Should have exited out from this loop if the score had swapped

		if ( currentAheadTeamScore ==  currentBehindTeamScore ) //Dead even, so wait a short amount of time and see if it's still dead even
			continue

		local currentScoreRatio = max( GameScore.GS_GetScoreRatio(), GameScore.GS_GetScoreNeededRatio() )

		local scoreRatioDifference = currentScoreRatio - previousScoreRatio

		//printt( "currentScoreRatio: " + currentScoreRatio + ". previousScoreRatio: " + previousScoreRatio + " scoreRatioDifference :" + scoreRatioDifference  )

		if ( scoreRatioDifference > 0.065 ) //Team is catching up. Threshold is purposefully on the low end for now.
		{
			PlayConversationToTeam( "FriendlyTeamCatchingUp", behindTeam )
			PlayConversationToTeam( "EnemyTeamCatchingUp", aheadTeam )

		}
		else if ( scoreRatioDifference < -0.065 ) //Team is fallen behind further. PThreshold is purposefully on the low end for now.
		{
			PlayConversationToTeam( "FriendlyTeamFallingBehindFurther", behindTeam )
			PlayConversationToTeam( "EnemyTeamFallingBehindFurther", aheadTeam )
		}
		else
		{
			continue //No significant change in lead, so wait a short amount of time.
		}

		//We've made some announcement about the lead, so now wait another bunch of time
		previousScoreRatio = currentScoreRatio
		randomWaitTime = RandomFloat( 60.0, 90.0 )
		//printt( "Waiting randomTime: " + randomWaitTime + " in loop" )
		wait randomWaitTime
	}
}

function ProtectTeamFromElimination( team )
{
	file.teamProtectedFromElimination[ team ] = true
}
Globalize( ProtectTeamFromElimination )

function ClearTeamEliminationProtection()
{
	foreach ( team, protected in file.teamProtectedFromElimination )
	{
		file.teamProtectedFromElimination[ team ] = false
	}
}
Globalize( ClearTeamEliminationProtection )

function SetRoundWinningKillEnabled( value )
{
	Assert( typeof value == "bool" )
	level.nv.roundWinningKillReplayEnabled = value
}
Globalize( SetRoundWinningKillEnabled ) //Get is defined in utility_shared since we need it on the client too

function SetRoundWinningKillReplayEntities( viewEnt, victim )
{
	level.roundWinningKillReplayViewEnt = viewEnt
	level.roundWinningKillReplayVictim = victim
	level.nv.roundWinningKillReplayVictimEHandle = victim.GetEncodedEHandle()
}
Globalize( SetRoundWinningKillReplayEntities )

function ClearRoundWinningKillReplayEntities( )
{
	level.roundWinningKillReplayViewEnt = null
	level.roundWinningKillReplayVictim = null
	level.nv.roundWinningKillReplayVictimEHandle = null
}
Globalize( ClearRoundWinningKillReplayEntities )

function RoundWinningKillReplay() //Only Tested in MFD Pro for now! SHould be minimal work to make sure it works for other game modes too though
{
	local viewEntity = level.roundWinningKillReplayViewEnt
	local victim = level.roundWinningKillReplayVictim

	Assert( IsValid( viewEntity ) )
	Assert( IsValid( victim ) )
	Assert( IsRoundBased() )

	local playersWatchingRoundWinningKillReplay = []
	local playersAlreadyWatchingOwnKillReplay = []


	OnThreadEnd(
		function() : ( playersWatchingRoundWinningKillReplay )
		{
			foreach ( player in playersWatchingRoundWinningKillReplay )
			{
				if ( !IsValid( player ) )
					continue

				player.SetKillReplayDelay(0, true)
				player.ClearViewEntity()
			}

			level.nv.replayDisabled = false
			level.watchingRoundWinningKillReplay = false
			//ClearRoundWinningKillReplayEntities isn't done here, but instead in prematch instead to not change the time spent in winnerdetermined
		}
	)

	level.watchingRoundWinningKillReplay = true

	level.nv.replayDisabled = true
	local players = GetPlayerArray()
	foreach ( player in players )
	{
		if ( IsPlayerWatchingKillReplay( player ) )
		{
			playersAlreadyWatchingOwnKillReplay.append( player )
			continue
		}
		ScreenFade( player, 0, 0, 1, 255, ROUND_WINNING_KILL_REPLAY_STARTUP_WAIT - 1.5, 0.0, 0x002 | 0x008 ) //Don't use the util ScreenFadeToBlack function because we don't want to purge the existing black screen fades that might be called from elsewhere
	}

	wait ROUND_WINNING_KILL_REPLAY_STARTUP_WAIT //Delay before we start kill replay proper

	if ( !IsValid( viewEntity ) || !IsValid( victim ) )
	{
		MessageToAll( eEventNotifications.RoundWinningKillReplayCancelled )
		return
	}

	local viewEntityViewIndex = viewEntity.GetIndexForEntity()
	players = GetListOfPlayersToWatchRoundWinningKillReplay( playersAlreadyWatchingOwnKillReplay )
	foreach ( player in players )
	{
		UnMuteSFX( player )
		player.SetViewIndex( viewEntityViewIndex )
		player.SetKillReplayDelay( ROUND_WINNING_KILL_REPLAY_LENGTH_OF_REPLAY, true )
		player.SetKillReplayVictim( victim )
		player.SetIsReplayRoundWinning( true )
		playersWatchingRoundWinningKillReplay.append( player )
	}

	wait ROUND_WINNING_KILL_REPLAY_LENGTH_OF_REPLAY

}
Globalize( RoundWinningKillReplay )

function GetListOfPlayersToWatchRoundWinningKillReplay( ignoreList )
{
	local resultArray = []

	local allPlayers = GetPlayerArray()

	foreach( player in allPlayers )  //Double for loop, on arrays that contain at most 16 elements. Should be fine.
	{
		if ( IsPlayerWatchingKillReplay( player ) )
			continue

		if ( !MinimumTimePassedBetweenKillReplays( player ) )
			continue

		if ( player.s.clientScriptInitialized == false ) //Don't do RoundWinningKillReplay() on players who haven't finished initializing client script yet
			continue

		local addPlayer = true
		foreach( playerInIgnoreList in ignoreList )
		{
			if ( !IsValid( playerInIgnoreList ) )
				continue

			if ( player == playerInIgnoreList )
			{
				addPlayer = false
				break
			}
		}

		if ( addPlayer == true )
			resultArray.append( player )
	}

	return resultArray
}

function MinimumTimePassedBetweenKillReplays( player )
{
	local lastKillReplayChangedTime = player.GetLastTimeReplayDelayChanged()
	local timePassed = Time() - lastKillReplayChangedTime
	//printt( "player: " + player + ", lastKillReplayChangedTime: " + lastKillReplayChangedTime + ", timePassed: " + timePassed + ", minTimePassed: " + ( timePassed > GetConVarFloat( "replay_minWaitBetweenTransitions" ) )   )
	return timePassed > GetConVarFloat( "replay_minWaitBetweenTransitions" )
}

function IsWatchingRoundWinningKillReplay()
{
	return level.watchingRoundWinningKillReplay
}
Globalize( IsWatchingRoundWinningKillReplay )

function IsPlayerWatchingKillReplay( player )
{
	return player.GetReplayDelay() != 0
}
Globalize( IsPlayerWatchingKillReplay )


function WillShowRoundWinningKillReplay()
{
	if ( !IsRoundBased() )
		return false

	if ( GetRoundWinningKillEnabled() != true )
		return false

	if ( level.roundWinningKillReplayViewEnt == null ) //Check for null specifically instead of IsValid because players can disconnect and become invalid, and we only want this to be false because we set it to null explicitly
		return false

	return true

}