// Titan Brawl FFA: Free For All rules (every player is their own team, score per kill) with Titan Brawl's forced
// settings (everyone spawns as a Titan and can never leave it). The FFA rules come from mp/_free_for_all, which
// _settings.nut loads as a separate server script of this mode just before this one. Kills score for the killer,
// as in the plain FFA mode.

function main()
{
	AddCallback_PlayerOrNPCKilled( TitanFFA_OnPlayerOrNPCKilled )

	Riff_ForceSetSpawnAsTitan( eSpawnAsTitan.Always )
	Riff_ForceTitanExitEnabled( eTitanExitEnabled.Never )

	FlagSet( "ForceStartSpawn" )

	AddCallback_GameStateEnter( eGameState.Prematch, TitanFFA_PrematchStart )
	AddCallback_GameStateEnter( eGameState.Playing, TitanFFA_PlayingStart )
}

function EntitiesDidLoad()
{
	// The riff settings are applied again once the level is up, so force them again as Titan Brawl does
	Riff_ForceSetSpawnAsTitan( eSpawnAsTitan.Always )
	Riff_ForceTitanExitEnabled( eTitanExitEnabled.Never )
}

function TitanFFA_OnPlayerOrNPCKilled( victim, attacker, damageInfo )
{
	if ( !victim.IsPlayer() )
		return

	if ( GetGameState() >= eGameState.WinnerDetermined )
		return

	local scoringPlayer = GetEntityOwningPlayer( attacker )
	if ( !IsValid( scoringPlayer ) || !scoringPlayer.IsPlayer() )
		return

	if ( ShouldPreventFriendlyFire( victim, attacker ) )
		return

	scoringPlayer.SetAssaultScore( scoringPlayer.GetAssaultScore() + 1 )
}

function TitanFFA_PrematchStart()
{
	FlagSet( "ForceStartSpawn" )

	foreach ( player in GetPlayerArray() )
	{
		player.titansBuilt = 0
		player.s.respawnCount = 0
		ForceTitanBuildComplete( player )
	}
}

function TitanFFA_PlayingStart()
{
	FlagClear( "ForceStartSpawn" )
}
