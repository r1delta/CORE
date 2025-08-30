function main()
{
	Globalize( ScriptCallback_OnClientConnecting )

	AddCallback_PlayerOrNPCKilled( TeamDeathmatch_OnPlayerOrNPCKilled )
	level.spawnRatingFunc_Pilot = RateFrontLinePlayerSpawnpoint
	level.spawnRatingFunc_Generic = RateFrontLinePlayerSpawnpoint

	//SetGameModeAnnouncement( "GameModeAnnounce_PST" )
	level.spawnRatingFunc_Pilot = RateSpawnpoint_Generic
	level.spawnRatingFunc_Generic = RateSpawnpoint_Generic
	Riff_ForceTitanAvailability( eTitanAvailability.Never )
	// AddCallback_OnPlayerKilled( PlayerKilledByEnemy )
	// level.titanAvailabilityCheck = Bind( IsPlayerTitanAvailable )
	// level.titanRebuildAvailabilityCheck = Bind( ShouldRebuildTitan )
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

function ScriptCallback_OnClientConnecting( player )
{
}

function TeamDeathmatch_OnPlayerOrNPCKilled( victim, attacker, damageInfo )
{
	if ( !( victim.IsPlayer() ) )
		return

	local attackerTeam = attacker.GetTeam()

	if ( ShouldPreventFriendlyFire( victim, attacker ) )
		return

	GameScore.AddTeamScore( attackerTeam, 1 )
}

function PlayerKilledByEnemy( player, damageInfo )
{
	local attacker = damageInfo.GetAttacker()

	if ( !attacker.IsPlayer() )
		return

	printt("PlayerKilledByEnemy: ", player.GetName(), " killed by ", attacker.GetName() )
	printt("    attacker.s.numberKillsSinceLastDeath: ", attacker.s.numberKillsSinceLastDeath )

	// play the dialoge for 3 kill before titan
	local killsForTitan = GetCurrentPlaylistVarInt( "kill_for_titan", 7 )
	switch ( attacker.s.numberKillsSinceLastDeath )
	{
		case killsForTitan - 3:
			PlayConversationToPlayer( "PS_3KillBeforeTitan", attacker )
			break
		case killsForTitan - 2:
			PlayConversationToPlayer( "PS_2KillBeforeTitan", attacker )
			break
		case killsForTitan - 1:
			PlayConversationToPlayer( "PS_1KillBeforeTitan", attacker )
			break
		case killsForTitan:
			PlayConversationToPlayer(  "PS_TitanReady", attacker )
			break
		default:
			// do nothing
			break
	}

	if ( attacker.s.numberKillsSinceLastDeath != GetCurrentPlaylistVarInt( "kill_for_titan", 7 ) )
		return
	printt("    Forcing titan build complete for ", attacker.GetName() )
	ForceTitanBuildComplete( attacker )
	thread TryETATitanReadyAnnouncement( attacker )
}

function ShouldRebuildTitan( player )
{
	return false
}

function IsPlayerTitanAvailable( player )
{
	local result = player.IsTitanReady()
	printt("IsPlayerTitanAvailable: Checking titan availability for ", player.GetName()  , " result: ", result )
	return result
}

