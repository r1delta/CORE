
function main()
{
	if ( reloadingScripts )
		return
}

function EntitiesDidLoad()
{
	GM_SetObserverFunc( ObserverFunc )
	BBPanelCamSetup()
}

function BBPanelCamSetup()
{
    PrintFunc()
	//local spectatorNode1 = GetEnt( "panel_cam1" )
	//local spectatorNode2 = GetEnt( "panel_cam2" )

	level.DeathCamEnt1 <- GetEnt( "panel_cam1" )
	level.DeathCamEnt2 <- GetEnt( "panel_cam2" )

	level.DeathCamOutSide_A <- GetEnt( "panel_cam10" )
	level.DeathCamOutSide_B <- GetEnt( "panel_cam20" )

	printt( "DeathCamEnt1 = ", level.DeathCamEnt1)
	printt( "DeathCamEnt2 = ", level.DeathCamEnt2)
}

function ObserverFunc( player )
{
	printt( "player: ", player.GetName() )

	if( IsBigBrotherPanelHacked() && IsMyTeamElimination( player ) )
	{
		local HackedPanelIndex = GetHackedBBPanelIndex()

		Assert( HackedPanelIndex != 0 )

		local deathCam
		if( GetHackedBBPanelIndex() == 1 )
		{
			deathCam = level.DeathCamEnt1
		}
		else
		{
			deathCam = level.DeathCamEnt2
		}

		// player 및 같은 팀 플레이어의 옵저버 모드를 바꿈.
		local playerArray = GetPlayerArrayOfTeam( player.GetTeam() )
		foreach ( guy in playerArray )
		{
			guy.SetObserverModeStaticPosition( deathCam.GetOrigin() )
			guy.SetObserverModeStaticAngles( deathCam.GetAngles() )

			guy.StartObserverMode( OBS_MODE_STATIC_LOCKED )
			guy.SetObserverTarget( null )

			// SpectatorSelectButton Hide.
			Remote.CallFunction_NonReplay( guy, "ServerCallback_HideSpectatorSelectButtons" )
		}

		/*
		player.SetObserverModeStaticPosition( deathCam.GetOrigin() )
		player.SetObserverModeStaticAngles( deathCam.GetAngles() )

		player.StartObserverMode( OBS_MODE_STATIC_LOCKED )
		player.SetObserverTarget( null )
		*/
	}
	else
	{
		player.StartObserverMode( OBS_MODE_CHASE )
		player.SetObserverTarget( null )
	}
}

main()