function main()
{
	Globalize( ScriptCallback_OnClientConnecting )

	AddCallback_PlayerOrNPCKilled( TeamDeathmatch_OnPlayerOrNPCKilled )

	Riff_ForceSetSpawnAsTitan( eSpawnAsTitan.Always )
	Riff_ForceTitanExitEnabled( eTitanExitEnabled.Never )

	level.spawnRatingFunc_Pilot = RateFrontLinePlayerSpawnpoint
	level.spawnRatingFunc_Generic = RateFrontLinePlayerSpawnpoint

	FlagSet( "ForceStartSpawn" )

	AddCallback_GameStateEnter( eGameState.Prematch, TitanBrawl_PrematchStart )
	AddCallback_GameStateEnter( eGameState.Playing, TitanBrawl_PlayingStart )
}


function EntitiesDidLoad()
{
	Riff_ForceSetSpawnAsTitan( eSpawnAsTitan.Always )
	Riff_ForceTitanExitEnabled( eTitanExitEnabled.Never )

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

function TitanBrawl_PrematchStart()
{
	FlagSet( "ForceStartSpawn" )

	local players = GetPlayerArray()
	foreach ( player in players )
	{
		player.titansBuilt = 0
		player.s.respawnCount = 0
		ForceTitanBuildComplete( player )
	}
}

function TitanBrawl_PlayingStart()
{
	FlagClear( "ForceStartSpawn" )
}

