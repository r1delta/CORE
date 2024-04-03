function main()
{
	Globalize( ScriptCallback_OnClientConnecting )
	Globalize( Attrition_OnPlayerOrNPCKilled )
	Globalize( ShowPlayerAttritionScoreEvent )

	AddCallback_PlayerOrNPCKilled( Attrition_OnPlayerOrNPCKilled )

	AddCallback_OnTitanDoomed( TitanTag_OnTitanDoomed )

	level.spawnRatingFunc_Pilot = RateFrontLinePlayerSpawnpoint
	level.spawnRatingFunc_Generic = RateFrontLinePlayerSpawnpoint

	if ( Riff_TitanAvailability() == eTitanAvailability.Default )
		level.nv.titanAvailability = eTitanAvailability.Never

	if ( Riff_SpawnAsTitan() == eSpawnAsTitan.Default )
		level.nv.spawnAsTitan = eSpawnAsTitan.Never

	SetGameModeAnnouncement( "GameModeAnnounce_AT" )

	level.theTitanSoul <- null
}

function EntitiesDidLoad()
{
	//printl("running EntitiesDidLoad() in team_deathmatch.nut" )
	SetupAssaultPointKeyValues()

	//monitor population and respawns
	thread SetupTeamDeathmatchNPCs()
}

function ScriptCallback_OnClientConnecting( player )
{
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

	if ( (!level.theTitanSoul || !IsValid( level.theTitanSoul )) && victim.IsPlayer() )
	{
		thread AwardTheTitanToPlayer( attacker )
	}
	else if ( attacker.IsTitan() && attacker.GetTitanSoul() == level.theTitanSoul )
	{
		//GameScore.AddTeamScore( attacker.GetTeam(), 10 )

	 	local scoreVal = GetAttritionScore( attacker, victim )
		ShowPlayerAttritionScoreEvent( attacker, scoreVal )

		GameScore.AddTeamScore( attacker.GetTeam(), scoreVal )
		attacker.SetAssaultScore( attacker.GetAssaultScore() + scoreVal )
	}
}


function AwardTheTitanToPlayer( player )
{
	level.theTitanSoul = true

	local titanTeam = player.GetTeam()
	local otherTeam = GetOtherTeam(titanTeam)

	MessageToTeam( titanTeam, eEventNotifications.FriendlyPlayerHasTheTitan, null, player )
	MessageToTeam( otherTeam, eEventNotifications.EnemyPlayerHasTheTitan, player, player )
	MessageToPlayer( player, eEventNotifications.YouHaveTheTitan, null, Time() + 5.0 )

	wait 5.0

	if ( !IsValid( player ) )
	{
		level.theTitanSoul = null
		return
	}

	// TODO: fix potential strange timing allowing double titans with summon burn cards
	if ( !player.IsTitan() && !IsValid( player.GetPetTitan() ) )
	{
		local spawnPoint = GetTitanReplacementPoint( player, false )
		local origin = spawnPoint.origin
		Assert( origin )

		waitthread ForceReplacementTitan( player, spawnPoint )
	}

	if ( !IsValid( player ) || (!IsValid( player.GetPetTitan() ) && !player.IsTitan()) )
	{
		level.theTitanSoul = null
		return
	}

	local titanSoul
	if ( player.IsTitan() )
		titanSoul = player.GetTitanSoul()
	else
		titanSoul = player.GetPetTitan().GetTitanSoul()

	level.theTitanSoul = titanSoul

	titanSoul.EndSignal( "Doomed" )
	titanSoul.EndSignal( "OnDestroy" )
	player.EndSignal( "Disconnected" )
	player.EndSignal( "OnDestroy" )

	local nextScoreTime = Time()

	OnThreadEnd(
		function() : ( player )
		{
			if ( IsValid( player ) )
				player.SetForceCrosshairNameDraw( false )
		}
	)

	while ( true )
	{
		if ( Time() >= nextScoreTime )
		{
			ShowPlayerAttritionScoreEvent( player, 1 )
			AddPlayerScore( player, "TitanHold", null, 25 ) // temp scoring
			GameScore.AddTeamScore( player.GetTeam(), 1 )

			nextScoreTime = Time() + 8.0
		}

		if ( player.IsTitan() )
			player.SetForceCrosshairNameDraw( true )
		else
			player.SetForceCrosshairNameDraw( false )

		local titan = titanSoul.GetTitan()

		if ( titan )
			titan.SetForceCrosshairNameDraw( true )

		wait 0
	}

}


function TitanTag_OnTitanDoomed( titan, damageInfo )
{
	local attacker = GetAttackerOrLastAttacker( titan, damageInfo )

	if ( IsValid( attacker ) && IsPlayer( attacker ) )
		thread AwardTheTitanToPlayer( attacker )
	else
		level.theTitan = null
}


function ShowPlayerAttritionScoreEvent( player, value )
{
	local event = ScoreEventFromName( "TitanTagPoints" )
	local scoreEventInt = event.GetInt()

	Remote.CallFunction_NonReplay( player, "ServerCallback_PointSplash", scoreEventInt, null, value )
}
