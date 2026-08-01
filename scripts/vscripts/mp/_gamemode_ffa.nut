function main()
{
	AddCallback_PlayerOrNPCKilled( FFA_OnPlayerOrNPCKilled )

	level.spawnRatingFunc_Pilot = RateSpawnpoint_Generic
	level.spawnRatingFunc_Generic = RateSpawnpoint_Generic

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
	// level.titanAvailabilityCheck = Bind( IsPlayerTitanAvailable )
	// level.titanRebuildAvailabilityCheck = Bind( ShouldRebuildTitan )
	// Riff_ForceTitanAvailability( eTitanAvailability.Custom )
}

function FFA_OnPlayerOrNPCKilled( victim, attacker, damageInfo )
{
	if ( GetGameState() > eGameState.WinnerDetermined )
		return

	if ( !victim.IsPlayer() )
		return

	if ( !attacker.IsPlayer() )
		return

	local attackerTeam = attacker.GetTeam()

	if ( ShouldPreventFriendlyFire( victim, attacker ) )
		return

	attacker.SetAssaultScore( attacker.GetAssaultScore() + 1 )
}
