function main()
{
	Globalize( ScriptCallback_OnClientConnecting )

	AddCallback_PlayerOrNPCKilled( TeamDeathmatch_OnPlayerOrNPCKilled )
	level.spawnRatingFunc_Pilot = RateFrontLinePlayerSpawnpoint
	level.spawnRatingFunc_Generic = RateFrontLinePlayerSpawnpoint

	//SetGameModeAnnouncement( "GameModeAnnounce_PS" )
	level.spawnRatingFunc_Pilot = RateSpawnpoint_Generic
	level.spawnRatingFunc_Generic = RateSpawnpoint_Generic
	Riff_ForceTitanAvailability( eTitanAvailability.Never )
	//AddCallback_OnPlayerKilled( PlayerKilledByEnemy )
	//level.titanAvailabilityCheck = Bind( IsPlayerTitanAvailable )
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
}

function ScriptCallback_OnClientConnecting( player )
{
}

function TeamDeathmatch_OnPlayerOrNPCKilled( victim, attacker, damageInfo )
{
	if ( !( victim.IsPlayer() ) )
		return

	local attackerTeam = attacker.GetTeam()

	if ( victim.GetTeam() == attackerTeam )
		return

	GameScore.AddTeamScore( attackerTeam, 1 )
}

function PlayerKilledByEnemy( player, damageInfo )
{
	local attacker = damageInfo.GetAttacker()

	if ( !attacker.IsPlayer() )
		return

	if ( attacker.s.numberKillsSinceLastDeath != GetCurrentPlaylistVarInt( "kill_for_titan", 7 ) )
		return

	ForceTitanBuildComplete( attacker )

	if( IsTitanBuildTimeRule() )
	{
		thread TryETATitanReadyAnnouncement( attacker )
	}
}


function IsPlayerTitanAvailable( player )
{
	return player.IsTitanReady()
}

