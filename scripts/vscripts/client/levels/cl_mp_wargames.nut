function main()
{
	IncludeFileAllowMultipleLoads( "client/cl_carrier" ) //Included for skyshow dogfights
	IncludeFileAllowMultipleLoads( "client/objects/cl_hornet_fighter" )
	IncludeFileAllowMultipleLoads( "client/objects/cl_phantom_fighter" )

	SetFullscreenMinimapParameters( 4.9, -1000, 250, 180 )
	if ( GAMETYPE == COOPERATIVE )
		SetCustomMinimapZoom( 2 )

	// --- custom classic MP scripting after here ---
	if ( !GetClassicMPMode() )
		return

	WargamesClient_MusicInit()
	RegisterServerVarChangeCallback( "gameState", GamestateChange_TryEnableMusic )

	ClassicMP_Client_SetGameStateEnterFunc_PickLoadOut( ClassicMP_Wargames_GameStateEnterFunc_PickLoadOut )

	level.FX_POD_SCREEN_IN	<- PrecacheParticleSystem( "P_pod_screen_lasers_IN" )

	thread Wargames_ClientPlayerSetup()
}

function ClassicMP_Wargames_GameStateEnterFunc_PickLoadOut( player )
{
	player.cv.waitingForPlayersDesc.SetText( "#HUD_WAITING_FOR_PLAYERS_BASIC" ) //#HUD_WARPJUMPIN1  // #HUD_WAITING_FOR_PLAYERS_BASIC  // #CONNECTING_TRAINING
	player.cv.waitingForPlayersDesc.Show()
	player.cv.waitingForPlayersLine.Show()
	player.cv.waitingForPlayersTimer.Show()
}

function Wargames_ClientPlayerSetup()
{
	local startTime = Time()
	local player = GetLocalClientPlayer()
	while ( player == null )
	{
		wait 0
		player = GetLocalClientPlayer()
	}
	//printt( "Wargames_ClientSetup() waited", Time() - startTime, "secs to get LocalClientPlayer" )

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

function WargamesClient_MusicInit()
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

	printt( "Wargames client: disabling global music" )
	level.musicEnabled = false
}


function EnableGlobalMusic()
{
	if ( !level.musicEnabled )
	{
		printt( "Wargames client: enabling global music" )
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
		
	if ( GameRules.GetGameMode() == LAST_TITAN_STANDING || GameRules.GetGameMode() == WINGMAN_LAST_TITAN_STANDING )
	{
		printt( "Wargames post intro: playing LTS drop intro music" )
		thread ForcePlayMusicToCompletion( eMusicPieceID.LEVEL_INTRO )
	}
	else
	{
		printt( "Wargames post intro: playing action music" )
		PlayActionMusic()  // this can't get double called, there is a debounce time
	}
}
