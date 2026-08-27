function main()
{
	AddCallback_PlayerOrNPCKilled( FFA_OnPlayerOrNPCKilled )
	AddCallback_OnClientConnected( FFA_OnClientConnected )
	AddCallback_OnClientDisconnected( FFA_OnClientDisconnected )

	level.spawnRatingFunc_Pilot = RateSpawnpoint_Generic
	level.spawnRatingFunc_Generic = RateSpawnpoint_Generic

	SetFFABased( true )
	thread FFAOwnedNPCRelationshipMonitor()
	thread FFAPlayerRelationshipMonitor()
}

function FFAPlayerRelationshipMonitor()
{
	if ( "ffaPlayerRelationshipMonitorRunning" in level )
	{
		if ( level.ffaPlayerRelationshipMonitorRunning )
			return

		level.ffaPlayerRelationshipMonitorRunning = true
	}
	else
	{
		level.ffaPlayerRelationshipMonitorRunning <- true
	}
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
	// level.titanAvailabilityCheck = Bind( IsPlayerTitanAvailable )
	// level.titanRebuildAvailabilityCheck = Bind( ShouldRebuildTitan )
	// Riff_ForceTitanAvailability( eTitanAvailability.Custom )
}

function FFA_OnPlayerOrNPCKilled( victim, attacker, damageInfo )
{
	if ( GetGameState() >= eGameState.WinnerDetermined )
		return

	if ( !victim.IsPlayer() )
		return

	local scoringPlayer = GetEntityOwningPlayer( attacker )
	if ( !IsValid( scoringPlayer ) || !scoringPlayer.IsPlayer() )
		return

	if ( ShouldPreventFriendlyFire( victim, attacker ) )
		return

	scoringPlayer.SetAssaultScore( scoringPlayer.GetAssaultScore() + 1 )
}
