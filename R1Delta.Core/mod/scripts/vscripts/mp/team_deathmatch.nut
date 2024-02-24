function main()
{
	Globalize( ScriptCallback_OnClientConnecting )

	AddCallback_PlayerOrNPCKilled( TeamDeathmatch_OnPlayerOrNPCKilled )

	level.spawnRatingFunc_Pilot = RateFrontLinePlayerSpawnpoint
	level.spawnRatingFunc_Generic = RateFrontLinePlayerSpawnpoint

	SetGameModeAnnouncement( "GameModeAnnounce_TDM" )
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