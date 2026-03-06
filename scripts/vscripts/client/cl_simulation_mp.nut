
function main()
{
	SimulationClient_MusicInit()
	RegisterServerVarChangeCallback( "gameState", GamestateChange_TryEnableMusic )

	ClassicMP_Client_SetGameStateEnterFunc_PickLoadOut( ClassicMP_Simulation_GameStateEnterFunc_PickLoadOut )

	level.FX_POD_SCREEN_IN	<- PrecacheParticleSystem( "P_pod_screen_lasers_IN" )

	thread Simulation_ClientPlayerSetup()
}

function ClassicMP_Simulation_GameStateEnterFunc_PickLoadOut( player )
{
	player.cv.waitingForPlayersDesc.SetText( "#HUD_WAITING_FOR_PLAYERS_BASIC" ) //#HUD_WARPJUMPIN1  // #HUD_WAITING_FOR_PLAYERS_BASIC  // #CONNECTING_TRAINING
	player.cv.waitingForPlayersDesc.Show()
	player.cv.waitingForPlayersLine.Show()
	player.cv.waitingForPlayersTimer.Show()
}

function Simulation_ClientPlayerSetup()
{
	local startTime = Time()
	local player = GetLocalClientPlayer()
	while ( player == null )
	{
		wait 0
		player = GetLocalClientPlayer()
	}
	//printt( "Simulation_ClientSetup() waited", Time() - startTime, "secs to get LocalClientPlayer" )

	thread IntroScreen_Setup()
}

// first fast introscreen, not the module loading screen
function IntroScreen_Setup()
{
	local player = GetLocalClientPlayer()
	player.EndSignal( "OnDestroy" )

	// if we connected late don't set up this introscreen
	if ( GetGameState() >= eGameState.Playing )
		return

	// make sure the classic MP hardcoded intro times have been set before we override
	while ( !level.clientScriptInitialized )
		wait 0

	level.introScreen_doLoadingIcon = false

	CinematicIntroScreen_SetTextFadeTimes( TEAM_IMC, 0, 0, 0 )
	CinematicIntroScreen_SetTextFadeTimes( TEAM_MILITIA, 0, 0, 0 )

	CinematicIntroScreen_SetTextSpacingTimes( TEAM_IMC, 0 )
	CinematicIntroScreen_SetTextSpacingTimes( TEAM_MILITIA, 0 )

	CinematicIntroScreen_SetTeamLogoFadeTimes( TEAM_IMC, 0, 0, 0, 0 )
	CinematicIntroScreen_SetTeamLogoFadeTimes( TEAM_MILITIA, 0, 0, 0, 0 )

	CinematicIntroScreen_SetBlackscreenFadeTimes( TEAM_IMC, 0, 0.2 )
	CinematicIntroScreen_SetBlackscreenFadeTimes( TEAM_MILITIA, 0, 0.2 )
}

function SimulationClient_MusicInit()
{
	if ( GetGameState() <= eGameState.Playing )
		DisableGlobalMusic()
}

function GamestateChange_TryEnableMusic()
{
	if ( GAMETYPE == COOPERATIVE )
		return

	if ( GetGameState() != eGameState.Playing )
		return

	// only have to turn the music back on for round 1
	if ( !HasSwitchedSides() && !GetRoundsPlayed() )
		EnableGlobalMusic()
}

function DisableGlobalMusic()
{
	if ( !level.musicEnabled )
		return

	printt( "Simulation client: disabling global music" )
	level.musicEnabled = false
}


function EnableGlobalMusic()
{
	if ( !level.musicEnabled )
	{
		printt( "Simulation client: enabling global music" )
	level.musicEnabled = true
	}

	thread DelayPlayActionMusic()
}
//Globalize( ServerCallback_EnableGlobalMusic )


function DelayPlayActionMusic()
{
	Assert( GetGameState() == eGameState.Playing )

	local player = GetLocalClientPlayer()

	if ( player != GetLocalViewPlayer() || IsWatchingKillReplay() )
		return

	player.EndSignal( "OnDestroy" )

	wait 0.2

	if ( GetGameState() != eGameState.Playing )
		return

	switch( GameRules.GetGameMode() )
	{
		case LAST_TITAN_STANDING:
		case WINGMAN_LAST_TITAN_STANDING:
		case TITAN_BRAWL:
		case TITAN_MFD:
		case TITAN_MFD_PRO:
			printt( "Simulation post intro: playing LTS drop intro music" )
			thread ForcePlayMusicToCompletion( eMusicPieceID.LEVEL_INTRO )
			break

		default:
			printt( "Simulation post intro: playing action music" )
			PlayActionMusic()  // this can't get double called, there is a debounce time
			break
	}
}

main()
