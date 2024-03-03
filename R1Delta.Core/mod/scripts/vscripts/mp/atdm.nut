function main()
{
	Globalize( Atdm_OnPlayerOrNPCKilled )
	Globalize( ShowPlayerAtdmScoreEvent )

	AddCallback_PlayerOrNPCKilled( Atdm_OnPlayerOrNPCKilled )
	level.spawnRatingFunc_Pilot = RateFrontLinePlayerSpawnpoint
	level.spawnRatingFunc_Generic = RateFrontLinePlayerSpawnpoint

	SetGameModeAnnouncement( "GameModeAnnounce_TDM" )
	AddCallback_OnTitanDoomed( Atdm_OnTitanDoomed )

	//thread MatchProgressThink()
	AddCallback_GameStateEnter( eGameState.Playing, Atdm_AITitan ) //ON

}

function EntitiesDidLoad()
{
	level.evacEnabled = false
	
	//printl("running EntitiesDidLoad() in team_deathmatch.nut" )
	SetupAssaultPointKeyValues()

	//no turrets in TDM for now
	local turrets = GetNPCArrayByClass( "npc_turret_sentry" )
	foreach( turret in turrets )
	{
		turret.DisableTurret()
	}

}

function Atdm_OnTitanDoomed( victim, damageInfo )
{
	if ( !GamePlaying() )
		return

	local attacker = GetAttackerOrLastAttacker( victim, damageInfo )

	if ( !IsValid( attacker ) )
		return

	attacker = GetAttackerPlayerOrBossPlayer( attacker )

	if ( !IsValid( attacker ) )
		return

	if ( attacker.GetTeam() != GetTeamIndex(GetOtherTeams(victim)))
		return

	if ( victim.IsTitan() && !victim.IsPlayer() )
		return

	local scoreVal = ATDM_SCORE_TITAN
/*
	if( victim.IsNPC() && IsAtdmFreeTitan( victim ) )
	{
		scoreVal = ATDM_SCORE_AITITAN
	}
*/
	
	ShowPlayerAtdmScoreEvent( attacker, scoreVal )

	GameScore.AddTeamScore( attacker.GetTeam(), scoreVal )
	attacker.SetAssaultScore( attacker.GetAssaultScore() + scoreVal )
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


/************************************************************************************************\

AI TITAN INTRO

\************************************************************************************************/

function Atdm_AITitan() //AI 타이탄 관련 스크립트 // 이하의 타이탄들이 적을 찾아 전투를 하면 됨
{
	if( IsToolMode_Native() )
		return
	
	delaythread (1.3) CallAITitan( TEAM_IMC, "#NPC_CUSTOM_ATDM_PILOT_1", "titan_stryder", "mp_titanweapon_xo16", false, 0)
	delaythread (2.7) CallAITitan( TEAM_IMC, "#NPC_CUSTOM_ATDM_PILOT_2", "titan_stryder", "mp_titanweapon_rocket_launcher", false, 1 )
	delaythread (1.5) CallAITitan( TEAM_MILITIA, "#NPC_CUSTOM_ATDM_PILOT_3", "titan_stryder", "mp_titanweapon_rocket_launcher", false, 0 )
	delaythread (2.4) CallAITitan( TEAM_MILITIA, "#NPC_CUSTOM_ATDM_PILOT_4", "titan_stryder", "mp_titanweapon_xo16", false, 1 )

	//thread Atdm_GiveFreeTitanForAll () // 중립 타이탄 소환!
}

function RespawnCheck( titan, team, title, titanSettings, titanWeapon )
{
	local soul = titan.GetTitanSoul()

	for(;;)
	{
		if( !IsValid(soul) )
			break;

		wait 1.0
	}

	wait 20.0

	CallAITitan( team, title, titanSettings, titanWeapon, true )
}

function CallAITitan( team, title, titanSettings, titanWeapon, isRespawn, spawnpointIdx = 0 )
{
	local spawnpoint

	if( isRespawn == false )
	{
		local startSpawnpoints = SpawnPoints_GetTitanStart ( team )
		if ( !startSpawnpoints.len() )
			return

		if( spawnpointIdx >= startSpawnpoints.len() )
			return

		spawnpoint = startSpawnpoints[spawnpointIdx]
	}
	else
	{
		local respawnPoints = SpawnPoints_GetTitan()
		
		spawnpoint = respawnPoints[ RandomInt( respawnPoints.len() ) ]
	}

/*
	local table = CreateDefaultNPCTitanTemplate ( team )

	table.title 	= title
	table.model 	= titanModel
	table.weapon	= titanWeapon
	
	table.origin 	= spawnpoint.GetOrigin()
	table.angles 	= spawnpoint.GetAngles()
	
	table.health 	= 2250 //160607 버전으로 픽스
	table.maxHealth	= table.health
	
	local titan = SpawnNPCTitan( table )
*/
	local titan  = CreateNPCTitanFromSettings( titanSettings, team, spawnpoint.GetOrigin(), spawnpoint.GetAngles() )
	titan.SetHealth( 2250 )
	titan.SetMaxHealth( 2250 )
	titan.GiveWeapon( titanWeapon )

	titan.GiveOffhandWeapon( "mp_titanability_smoke", TAC_ABILITY_SMOKE )
	titan.SetTacticalAbility( titan.GetOffhandWeapon( TAC_ABILITY_SMOKE ), TTA_SMOKE )

	titan.SetTitle( title )
	titan.SetShortTitle( title )

	titan.SetLookDist(100000) // AI 타이탄 최대 시야 거리.

	//MakeInvincible( titan )
	DisableHealthRegen( titan )
	//DisableRodeo( titan )
	//ForceRodeoOver( titan )

	titan.SetSubclass( eSubClass.atdmFreeTitan )

	waitthread ScriptedHotDrop( titan, spawnpoint.GetOrigin(), spawnpoint.GetAngles(), "at_hotdrop_drop_2knee_turbo" )
	//waitthread ScriptedO2HotDrop( titan, spawnpoint.GetOrigin(), spawnpoint.GetAngles(), "at_hotdrop_drop_2knee_turbo" )
	
	thread RespawnCheck( titan, team, title, titanSettings, titanWeapon );
	
	titan.SetEfficientMode( false )
	titan.SetTouchTriggers( true )
	
	titan.SetDefaultSchedule( "SCHED_PATROL_PATH" )
}

/*
function ScriptedO2HotDrop( titan, origin, angles, animation )
{
	OnThreadEnd(
		function() : ( titan )
		{
			if ( IsValid( titan ) )
			{
				DeleteAnimEvent( titan, "titan_impact", OnSpearsDrop )
				DeleteAnimEvent( titan, "second_stage", OnSpearsSecondStage )
				titan.DisableRenderAlways()
			}
		}
	)
	titan.EndSignal( "OnDeath" )

	AddAnimEvent( titan, "titan_impact", Bind( OnSpearsDrop ) )
	AddAnimEvent( titan, "second_stage", OnSpearsSecondStage, origin )

	titan.EnableRenderAlways()
	EmitSoundAtPosition( origin, "titan_hot_drop_turbo_begin_3P" )

	waitthread PlayAnimTeleport( titan, animation, origin, angles )	
}
*/

/*
function OnSpearsDrop( titan, table = null )
{
	//impact fx
	OnDropImpactO2( titan )
	//EmitSoundOnEntity( titan, "O2_Scr_OgreLand_to_ArmBlownOff" )
}

function OnSpearsSecondStage( titan, origin )
{
	EmitSoundAtPosition( origin, "titan_drop_pod_turbo_landing_3P" )
}


function OnDropImpactO2( titan, e = null )
{
	PlayFX( HOTDROP_IMPACT_FX_TABLE, titan.GetOrigin(), titan.GetAngles() )

	CreateShake( titan.GetOrigin(), 4, 50, 2, 3000 )
}
*/

/************************************************************************************************\

ATDM SCRIPTS ORIGIN 

\************************************************************************************************/

function Atdm_OnPlayerOrNPCKilled( victim, attacker, damageInfo )
{
	if ( !( attacker.IsPlayer() ) )
		return

	local attackerTeam = attacker.GetTeam()
	local victimTeam = victim.GetTeam()

	if ( victimTeam == attackerTeam )
		return

	if ( victimTeam != TEAM_MILITIA && victimTeam != TEAM_IMC )
		return

	if ( GetGameState() != eGameState.Playing )
		return

	//if ( victim.IsTitan() && !victim.IsPlayer() )
	//	return

	if ( victim.IsMarvin() )
		return

 	local scoreVal = GetAtdmScore( attacker, victim )
 	printt("scoreVal: ", scoreVal)
	ShowPlayerAtdmScoreEvent( attacker, scoreVal )

	GameScore.AddTeamScore( attackerTeam, scoreVal )
	attacker.SetAssaultScore( attacker.GetAssaultScore() + scoreVal )
}


function ShowPlayerAtdmScoreEvent( player, value )
{
	local event = ScoreEventFromName( "AtdmPoints" )
	local scoreEventInt = event.GetInt()

	Remote.CallFunction_NonReplay( player, "ServerCallback_PointSplash", scoreEventInt, null, value )
}
