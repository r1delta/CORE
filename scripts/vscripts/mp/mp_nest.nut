
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
	local spectatorNode1 = GetEnt( "panel_cam1" )
	local spectatorNode2 = GetEnt( "panel_cam2" )

	level.DeathCamEnt1 <- spectatorNode1
	level.DeathCamEnt2 <- spectatorNode2

	printt( "DeathCamEnt1 = ", spectatorNode1)
	printt( "DeathCamEnt2 = ", spectatorNode2)
}

function ObserverFunc( player )
{
	if( IsBigBrotherPanelHacked() )
	{
		player.SetObserverModeStaticPosition( level.DeathCamEnt1.GetOrigin() )
		player.SetObserverModeStaticAngles( level.DeathCamEnt1.GetAngles() )
		//player.SetObserverTarget( level.DeathCamEnt1.kv.target )
	}

	player.StartObserverMode( OBS_MODE_CHASE )
	player.SetObserverTarget( null )
}

main()