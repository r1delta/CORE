function main()
{
	Globalize( ScriptCallback_OnClientConnecting )
	Globalize( Attrition_OnPlayerOrNPCKilled )
	Globalize( ShowPlayerAttritionScoreEvent )

	AddCallback_PlayerOrNPCKilled( Attrition_OnPlayerOrNPCKilled )
	level.spawnRatingFunc_Pilot = RateFrontLinePlayerSpawnpoint
	level.spawnRatingFunc_Generic = RateFrontLinePlayerSpawnpoint

	SetGameModeAnnouncement( "GameModeAnnounce_AT" )
	AddCallback_OnTitanDoomed( Attrition_OnTitanDoomed )

	//thread MatchProgressThink()
}

function EntitiesDidLoad()
{
	//printl("running EntitiesDidLoad() in team_deathmatch.nut" )
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

function Attrition_OnTitanDoomed( victim, damageInfo )
{
	if ( !GamePlaying() )
		return

	local attacker = GetAttackerOrLastAttacker( victim, damageInfo )

	if ( !IsValid( attacker ) )
		return

	attacker = GetAttackerPlayerOrBossPlayer( attacker )

	if ( !IsValid( attacker ) )
		return

	if ( attacker.GetTeam() != GetOtherTeam(victim) )
		return

	local scoreVal = ATTRITION_SCORE_TITAN
	ShowPlayerAttritionScoreEvent( attacker, scoreVal )

	GameScore.AddTeamScore( attacker.GetTeam(), scoreVal )
	attacker.SetAssaultScore( attacker.GetAssaultScore() + scoreVal )
}

function ScriptCallback_OnClientConnecting( player )
{
}

function MatchProgressThink()
{
	FlagWait( "GamePlaying" )

	while ( GetGameState() == eGameState.Playing )
	{
		local militiaProgress = GetMatchProgress_Score( TEAM_MILITIA )
		if ( militiaProgress > 70 )
			FlagSet( "Disable_MILITIA" )

		local imcProgress = GetMatchProgress_Score( TEAM_IMC )
		if ( imcProgress > 70 )
			FlagSet( "Disable_IMC" )

		wait 0.1
	}
}

function Attrition_OnPlayerOrNPCKilled( victim, attacker, damageInfo )
{
	if ( !( attacker.IsPlayer() ) )
		return

	local attackerTeam = attacker.GetTeam()
	local victimTeam = victim.GetTeam()

	if ( victim.GetTeam() == attackerTeam )
		return

	if ( victimTeam != TEAM_MILITIA && victimTeam != TEAM_IMC )
		return

	if ( GetGameState() != eGameState.Playing )
		return

	if ( victim.IsTitan() && !victim.IsPlayer() )
		return

	if ( victim.IsMarvin() )
		return

 	local scoreVal = GetAttritionScore( attacker, victim )
	ShowPlayerAttritionScoreEvent( attacker, scoreVal )

	GameScore.AddTeamScore( attacker.GetTeam(), scoreVal )
	attacker.SetAssaultScore( attacker.GetAssaultScore() + scoreVal )
}


function ShowPlayerAttritionScoreEvent( player, value )
{
	local event = ScoreEventFromName( "AttritionPoints" )
	local scoreEventInt = event.GetInt()

	Remote.CallFunction_NonReplay( player, "ServerCallback_PointSplash", scoreEventInt, null, value )
}
