function main()
{
	IncludeScript( "mp/_free_for_all" )

	AddCallback_PlayerOrNPCKilled( FFA_OnPlayerOrNPCKilled )
}

function FFA_OnPlayerOrNPCKilled( victim, attacker, damageInfo )
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

main()