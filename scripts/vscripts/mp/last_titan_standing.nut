function main()
{
	Assert( !GetCinematicMode(), "Cannot play lts in cinematic mode" )
	//if ( Riff_EliminationMode() == eEliminationMode.Default )
	//level.nv.eliminationMode = eEliminationMode.PilotsTitans

	//FlagSet( "PilotBot" )
	//Riff_ForceTitanAvailability( eTitanAvailability.Never )
	//Riff_ForceSetSpawnAsTitan( eSpawnAsTitan.Never )

	SetRoundBased( true )
	SetSwitchSidesBased( true )
	FlagSet( "ForceStartSpawn" )

	AddCallback_PlayerOrNPCKilled( SecondsPlayerOrNPCKilled )
	AddCallback_OnPlayerRespawned( LTS_OnPlayerRespawned )

	AddCallback_GameStateEnter( eGameState.Prematch, LTSPrematchStart )
	AddCallback_GameStateEnter( eGameState.Playing, LTSPlayingStart )
	AddCallback_GameStateEnter( eGameState.Epilogue, LTSEpilogueStart )
}

function EntitiesDidLoad()
{
	// HACK: Somewhere, for some reason, these specific server vars can't be overridden, this will force them in a nasty way.
	//       It should do the job until eventually we find why it behaves like this.
	ServerCommand("script (level.nv.spawnAsTitan = eSpawnAsTitan.Once)") // Spawn with a titan only once. If we force this too late, we wont spawn with a titan for the first round.
	ServerCommand("script (level.nv.titanAvailability = eTitanAvailability.Never)") // No new titans
	ServerCommand("script (level.nv.eliminationMode = eEliminationMode.PilotsTitans)") // Can eliminate both Pilots and Titans?
	SetupAssaultPointKeyValues()
	thread SetupTeamDeathmatchNPCs()
}

function LTS_OnPlayerRespawned( player )
{
	if ( GetGameState() > eGameState.Playing )
		return

	if ( Riff_TitanAvailability() == eTitanAvailability.Once )
	{
		player.SetNextTitanRespawnAvailable( 0 )
	}
}


function LTSEpilogueStart( )
{
	local players = GetPlayerArray()

	foreach ( player in players )
	{
		if ( IsAlive( player ) )
			continue

		if ( !IsPlayerEliminated( player ) )
			continue

		ClearPlayerEliminated( player )
		DecideRespawnPlayer( player )
	}
}

function LTSPlayingStart()
{
	FlagClear( "ForceStartSpawn" )
}


function LTSPrematchStart()
{
	FlagSet( "ForceStartSpawn" )

	local players = GetPlayerArray()
	foreach ( player in players )
	{
		player.titansBuilt = 0
		player.s.respawnCount = 0
		ForceTitanBuildComplete( player )
		if ( Riff_TitanAvailability() == eTitanAvailability.Once )
		{
		}
	}
}


function SecondsPlayerOrNPCKilled( entity, attacker, damageInfo )
{
	if ( !entity.IsPlayer() && !entity.IsTitan() )
		return

	if ( attacker.IsPlayer() && attacker.GetTeam() != entity.GetTeam() && !attacker.IsTitan() )
	{
	//	attacker.SetNextTitanRespawnAvailable( 0 )
	//	thread TryETATitanReadyAnnouncement( attacker )
	}

	if ( GetGameState() != eGameState.Playing && GetGameState() != eGameState.WinnerDetermined)
		return

	local isComplete = CheckEliminationModeWinner()
	if ( isComplete )
	{
		//Hack: At this point in time we haven't adjusted the kill count yet, but after we do CheckEliminationModeWinner() _base_gametype doesn't increment it for us anymore.
		if (entity.IsPlayer() && (attacker.IsPlayer() || attacker.IsTitan()))
			attacker.SetKillCount(attacker.GetKillCount() + 1)
	}
}
