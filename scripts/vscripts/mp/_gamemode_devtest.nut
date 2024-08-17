function main()
{
	Globalize( ScriptCallback_OnClientConnecting )

	AddCallback_PlayerOrNPCKilled( TeamDeathmatch_OnPlayerOrNPCKilled )

	level.spawnRatingFunc_Pilot = RateFrontLinePlayerSpawnpoint
	level.spawnRatingFunc_Generic = RateFrontLinePlayerSpawnpoint

	AddClientCommandCallback( "leaveDevTest", ClientCommand_LeaveDevTest )
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
	return
}

function ClientCommand_LeaveDevTest( player )
{
	GameRules_EndMatch()
}