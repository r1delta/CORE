function main()
{
	AddCallback_OnClientConnected( FFA_OnClientConnected )
	AddCallback_OnClientDisconnected( FFA_OnClientDisconnected )
	AddCallback_OnPlayerRespawned( FFA_PlayerRespawned )

	level.spawnRatingFunc_Pilot = RateSpawnpoint_Generic
	level.spawnRatingFunc_Generic = RateSpawnpoint_Generic

	level.ffaPlayerRelationshipMonitorRunning <- false
	level.ffaScanInProgress <- false

	SetFFABased( true )
}

function EntitiesDidLoad()
{
	SetupAssaultPointKeyValues()

	//no turrets in TDM for now
	local turrets = GetNPCArrayByClass( "npc_turret_sentry" )
	foreach( turret in turrets )
	{
		turret.DisableTurret()
	}

	//monitor population and respawns
	thread SetupTeamDeathmatchNPCs()
	level.nv.allowNPCs = eAllowNPCs.None

	thread FFAOwnedNPCRelationshipMonitor()
	thread FFAPlayerRelationshipMonitor()
	thread FFA_MinimapScanAndRemoveDropships()
}

function FFAPlayerRelationshipMonitor()
{
	if ( level.ffaPlayerRelationshipMonitorRunning )
		return

	level.ffaPlayerRelationshipMonitorRunning = true

	OnThreadEnd(
		function()
		{
			level.ffaPlayerRelationshipMonitorRunning = false
		}
	)

	while ( IsFFABased() )
	{
		foreach ( player in GetPlayerArray() )
		{
			if ( IsValid( player ) )
			{
				player.SetNameVisibleToFriendly( false )
				player.SetNameVisibleToEnemy( false )
				SetCrosshairTeamColoringDisabled( player, true )
			}
		}

		wait 0.5
	}
}

function FFA_OnClientConnected( player )
{
	player.s.FFA_PlayedBurnCardAnim <- false

	SetCrosshairTeamColoringDisabled( player, true )

	player.SetNameVisibleToEnemy( false )
	player.SetNameVisibleToFriendly( false )

	UpdateFFAAutoTitanRelationships()
}

function FFA_OnClientDisconnected( player )
{
	thread FFA_UpdateAutoTitanRelationshipsAfterDisconnect( player )
}

function FFA_UpdateAutoTitanRelationshipsAfterDisconnect( player )
{
	if ( IsValid( player ) )
		player.WaitSignal( "Disconnected" )

	while ( IsValid( player ) )
		wait 0

	UpdateFFAAutoTitanRelationships()
}

function FFA_MinimapScanAndRemoveDropships()
{
	wait 0.1 // Extra buffer for maps creating spawns from script

	KillAllEntitiesOfType( "info_spawnpoint_dropship" )
	KillAllEntitiesOfType( "info_spawnpoint_dropship_start" )
	// FFA removes these entities, so the classic intro must not retain their handles.
	level.dropship_start_spawns.clear()

	for ( ;; )
	{
		while( GetGameState() < eGameState.Playing || TimeSpentInCurrentState() < 5.0 )
			wait 0

		foreach( player in GetPlayerArray() )
		{
			if ( !IsAlive( player ) )
				continue

			if ( !player.s.FFA_PlayedBurnCardAnim )
			{
				Remote.CallFunction_NonReplay( player, "ServerCallback_PlayerUsesBurnCard", player.GetEncodedEHandle(), 30, true )
				player.s.FFA_PlayedBurnCardAnim = true
			}

			player.Signal( "GlobalMinimapScan" )
 			thread ScanMinimap( player ) 
		}
		thread SetScanInProgress()

		wait 10.0
	}
}

function SetScanInProgress()
{
	level.ffaScanInProgress = true
	wait 3.0
	level.ffaScanInProgress = false
}

function FFA_PlayerRespawned( player )
{
	if ( level.ffaScanInProgress )
	{
		if ( !player.s.FFA_PlayedBurnCardAnim )
		{
			Remote.CallFunction_NonReplay( player, "ServerCallback_PlayerUsesBurnCard", player.GetEncodedEHandle(), 30, true )
			player.s.FFA_PlayedBurnCardAnim = true
		}

		player.Signal( "GlobalMinimapScan" )
 		thread ScanMinimap( player ) 
	}
}