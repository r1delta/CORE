

function TitanBuildRule_Time_Main()
{
	printt("hitting init for TitanBuildRule_Time_Main")
	Globalize( GiveTitanBuildTimeAdvantage )

	AddCallback_TitanBuildRuleFunc( eTitanBuildRule.RULE_TIME, eTitanBuildEvent.INIT, Initialize )
	AddCallback_TitanBuildRuleFunc( eTitanBuildRule.RULE_TIME, eTitanBuildEvent.RESET_COMPLETE_CONDITION, ResetTitanBuildTime )
	AddCallback_TitanBuildRuleFunc( eTitanBuildRule.RULE_TIME, eTitanBuildEvent.START, StartTitanBuild )
	AddCallback_TitanBuildRuleFunc( eTitanBuildRule.RULE_TIME, eTitanBuildEvent.REMAIN, GetRemainTime )
	AddCallback_TitanBuildRuleFunc( eTitanBuildRule.RULE_TIME, eTitanBuildEvent.END_CHECK, IsComplete )
	AddCallback_TitanBuildRuleFunc( eTitanBuildRule.RULE_TIME, eTitanBuildEvent.GET_COMPLETE_CONDITION, GetTitanBuildTime )
	AddCallback_TitanBuildRuleFunc( eTitanBuildRule.RULE_TIME, eTitanBuildEvent.ADD_BUILD_ADVENTAGE, GiveTitanBuildTimeAdvantage )
	AddCallback_TitanBuildRuleFunc( eTitanBuildRule.RULE_TIME, eTitanBuildEvent.FORCE_BUILD_COMPLETE, ForceTitanBuildTimeComplete )
	AddCallback_TitanBuildRuleFunc( eTitanBuildRule.RULE_TIME, eTitanBuildEvent.DECREMENT_BUILD_CONDITION, DecrementBuildTime )
}

function Initialize( player )
{
	player.titansBuilt = 0
	player.SetTitanBuildTime( 0 )
	player.SetTitanRespawnTime( -1 )
}

function ResetTitanBuildTime( player, forceBuild )
{
	local buildTime
	local reBuildTime
	if( forceBuild == true )
	{
		buildTime = 0
		reBuildTime = 0
	}
	else
	{
		buildTime = GetCurrentPlaylistVarInt( "titan_build_time", 240 )
		reBuildTime = GetCurrentPlaylistVarInt( "titan_rebuild_time", 150 )
	}

	if( player.titansBuilt > 0 )
	{
		// 리빌드인 경우
		player.SetTitanBuildTime( reBuildTime )
	}
	else
	{
		//최초 빌드
		player.SetTitanBuildTime( buildTime )
	}

	//printt("[digm] ResetTitanBuildTime!!! reBuildTime = " + reBuildTime + " titansBuilt = " + player.titansBuilt)
}

function StartTitanBuild( player )
{
	player.SetTitanRespawnTime( Time() + player.GetTitanBuildTime() )
}

function GetRemainTime( player )
{
	return player.GetTitanRespawnTime() - Time()
}

function GetTitanBuildTime( player )
{
	return player.GetTitanBuildTime()
}

function IsComplete( player )
{
	//printt( "[BuildRule_Time] call IsComplete" )
	return ( player.GetTitanRespawnTime() <= Time() )
}

function GiveTitanBuildTimeAdvantage( player, ent, savedDamage, shieldDamage )
{
	local timerCredit = 0

	printt( "GiveTitanBuildTimeAdvantage: " + player.GetName() + " " + ent.GetName() + " " + savedDamage + " " + shieldDamage )

	if ( IsAlive( ent ) )
	{
		if ( ent.IsTitan() )
		{
			timerCredit = GetCurrentPlaylistVarFloat( "titan_kill_credit", 0.5 )
			if ( PlayerHasServerFlag( player, SFLAG_HUNTER_TITAN ) )
				timerCredit *= 2.0
		}
		else
		{
			if ( ent.IsPlayer() )
			{
				timerCredit = GetCurrentPlaylistVarFloat( "player_kill_credit", 0.5 )
				if ( PlayerHasServerFlag( player, SFLAG_HUNTER_PILOT ) )
					timerCredit *= 2.5
			}
			else
			{
				if ( ent.IsSoldier() )
				{
					timerCredit = GetCurrentPlaylistVarFloat( "ai_kill_credit", 0.5 )
					if ( PlayerHasServerFlag( player, SFLAG_HUNTER_GRUNT ) )
						timerCredit *= 2.5
				}
				else
				if ( ent.IsSpectre() )
				{
					timerCredit = GetCurrentPlaylistVarFloat( "spectre_kill_credit", 0.5 )
					if ( PlayerHasServerFlag( player, SFLAG_HUNTER_SPECTRE ) )
						timerCredit *= 2.5
				}
				else
				if ( ent.IsTurret() && ent.GetTeam() != TEAM_UNASSIGNED)
				{

					timerCredit = GetCurrentPlaylistVarFloat( "megaturret_kill_credit", 0.5 )
					//No 2x burn card for shooting mega turret
				}
				else
				if ( IsEvacDropship( ent ) )
				{
					timerCredit = GetCurrentPlaylistVarFloat( "evac_dropship_kill_credit", 0.5 )
				}
			}
		}

		if ( player.IsTitan() && PlayerHasPassive( player, PAS_HYPER_CORE ) )
			timerCredit *= 2.0

		local dealtDamage = min( ent.GetHealth(), savedDamage + shieldDamage )
		timerCredit = timerCredit * (dealtDamage / ent.GetMaxHealth().tofloat())
		//printt("[digm][GiveTitanBuildTimeAdvantage] dealtDamage = " + dealtDamage + " savedDamage = " + savedDamage + " shieldDamage = " + shieldDamage + " timerCredit = " + timerCredit)
	}

	if ( timerCredit )
	{
		DecrementBuildTime( player, timerCredit )
	}
}

function DecrementBuildTime( player, credit )
{
	printt( "Decrementing titan build by: " + credit + " for player: " + player.GetName() )
	player.SetTitanRespawnTime( player.GetTitanRespawnTime() - credit )
}

function ForceTitanBuildTimeComplete( player )
{
	player.SetTitanRespawnTime( 0 )
	player.SetTitanBuildTime( 0 )
}

TitanBuildRule_Time_Main()

