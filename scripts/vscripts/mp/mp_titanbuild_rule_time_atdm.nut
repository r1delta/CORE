

function TitanBuildRule_Time_ATDM_Main()
{
	AddCallback_TitanBuildRuleFunc( eTitanBuildRule.RULE_TIME_ATDM, eTitanBuildEvent.INIT, Initialize )
	AddCallback_TitanBuildRuleFunc( eTitanBuildRule.RULE_TIME_ATDM, eTitanBuildEvent.RESET_COMPLETE_CONDITION, ResetTitanBuildTime )
	AddCallback_TitanBuildRuleFunc( eTitanBuildRule.RULE_TIME_ATDM, eTitanBuildEvent.START, StartTitanBuild )
	AddCallback_TitanBuildRuleFunc( eTitanBuildRule.RULE_TIME_ATDM, eTitanBuildEvent.REMAIN, GetRemainTime )
	AddCallback_TitanBuildRuleFunc( eTitanBuildRule.RULE_TIME_ATDM, eTitanBuildEvent.END_CHECK, IsComplete )
	AddCallback_TitanBuildRuleFunc( eTitanBuildRule.RULE_TIME_ATDM, eTitanBuildEvent.GET_COMPLETE_CONDITION, GetTitanBuildTime )
	AddCallback_TitanBuildRuleFunc( eTitanBuildRule.RULE_TIME_ATDM, eTitanBuildEvent.ADD_BUILD_ADVENTAGE, GiveTitanBuildTimeAdvantage )
	AddCallback_TitanBuildRuleFunc( eTitanBuildRule.RULE_TIME_ATDM, eTitanBuildEvent.FORCE_BUILD_COMPLETE, ForceTitanBuildTimeComplete )
	AddCallback_TitanBuildRuleFunc( eTitanBuildRule.RULE_TIME_ATDM, eTitanBuildEvent.DECREMENT_BUILD_CONDITION, DecrementBuildTime )
}

function Initialize( player )
{
	player.titansBuilt = 0
	player.SetTitanBuildTime( 0 )
	player.SetTitanRespawnTime( -1 )
}

function ResetTitanBuildTime( player )
{
	local forceBuild = false
	local buildTime
	local reBuildTime
	if( forceBuild == true )
	{
		buildTime = 0
		reBuildTime = 0
	}
	else
	{
		buildTime = 240
		reBuildTime = 240
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
	printt( "[BuildRule_Time] call IsComplete" )
	return ( player.GetTitanRespawnTime() <= Time() )
}

function GiveTitanBuildTimeAdvantage( player, ent, savedDamage, shieldDamage )
{
	local timerCredit = 0

	if ( IsAlive( ent ) )
	{
		if ( ent.IsTitan() )
		{
			// ATDM AI Titan
			if( ent.IsNPC() && IsAtdmFreeTitan( ent ) )
			{
				timerCredit = 45
			}
			else
			{
				timerCredit = GetCurrentPlaylistVarFloat( "titan_kill_credit", 0.5 )
				if ( PlayerHasServerFlag( player, SFLAG_HUNTER_TITAN ) )
					timerCredit *= 2.0
			}
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
				if ( ent.IsTurret() )
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
	}

	if ( timerCredit )
	{
		DecrementBuildTime( player, timerCredit )
	}
}

function DecrementBuildTime( player, credit )
{
	local newRespawnTime = player.GetTitanRespawnTime() - credit
	if (newRespawnTime >= 0) {
		player.SetTitanRespawnTime(newRespawnTime)
	}
}

function ForceTitanBuildTimeComplete( player )
{
	player.SetTitanRespawnTime( 0 )
	player.SetTitanBuildTime( 0 )
}

TitanBuildRule_Time_ATDM_Main()

