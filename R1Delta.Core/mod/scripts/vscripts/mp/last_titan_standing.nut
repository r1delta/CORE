function main()
{
	Assert( !GetCinematicMode(), "Cannot play lts in cinematic mode" )

	if ( Riff_EliminationMode() == eEliminationMode.Default )
		level.nv.eliminationMode = eEliminationMode.PilotsTitans

	//FlagSet( "PilotBot" )
	SetServerVar( "spawnAsTitan", 1 )
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
	SetupAssaultPointKeyValues()
	thread SetupTeamDeathmatchNPCs()
}

function LTS_OnPlayerRespawned( player )
{
	if ( GetGameState() > eGameState.Playing )
		return

	if ( Riff_TitanAvailability() == eTitanAvailability.Once )
	{
		//player.SetNextTitanRespawnAvailable( 0 )
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
