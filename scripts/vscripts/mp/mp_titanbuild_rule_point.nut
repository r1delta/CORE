
function TitanBuildRule_Time_Main()
{
	AddCallback_TitanBuildRuleFunc( eTitanBuildRule.RULE_POINT, eTitanBuildEvent.INIT, Initialize )
	AddCallback_TitanBuildRuleFunc( eTitanBuildRule.RULE_POINT, eTitanBuildEvent.RESET_COMPLETE_CONDITION, ResetTitanBuildPoint )
	AddCallback_TitanBuildRuleFunc( eTitanBuildRule.RULE_POINT, eTitanBuildEvent.START, StartTitanBuild )
	AddCallback_TitanBuildRuleFunc( eTitanBuildRule.RULE_POINT, eTitanBuildEvent.REMAIN, GetRemainPoint )
	AddCallback_TitanBuildRuleFunc( eTitanBuildRule.RULE_POINT, eTitanBuildEvent.END_CHECK, IsComplete )
	AddCallback_TitanBuildRuleFunc( eTitanBuildRule.RULE_POINT, eTitanBuildEvent.GET_COMPLETE_CONDITION, GetTitanBuildPoint )
	AddCallback_TitanBuildRuleFunc( eTitanBuildRule.RULE_POINT, eTitanBuildEvent.ADD_BUILD_ADVENTAGE, GiveTitanBuildPointAdvantage )
	AddCallback_TitanBuildRuleFunc( eTitanBuildRule.RULE_POINT, eTitanBuildEvent.ADD_BUILD_POINT, AddBuildPoint )
	AddCallback_TitanBuildRuleFunc( eTitanBuildRule.RULE_POINT, eTitanBuildEvent.FORCE_BUILD_COMPLETE, ForceTitanBuildPointComplete )
}

function Initialize( player )
{
	player.titansBuilt = 0
	player.SetTitanBuildPoint( 0 )
	player.SetCurTitanBuildPoint( 0 )
}

function ResetTitanBuildPoint( player, amount )
{
	if ( player.IsTitan() )
	{
		return
	}

	if( amount == -1 )
	{
		player.SetTitanBuildPoint( 6 )
	}
	else
	{
		player.SetTitanBuildPoint( amount )
	}
}

function StartTitanBuild( player )
{
	player.SetCurTitanBuildPoint( 0 )
}

function GetRemainPoint( player )
{
	return player.GetTitanBuildPoint() - player.GetCurTitanBuildPoint()
}

function IsComplete( player )
{
	//printt( "[BuildRule_Point] call IsComplete" )
	return ( player.GetCurTitanBuildPoint() >= player.GetTitanBuildPoint() )
}

function GetTitanBuildPoint( player )
{
	return player.GetTitanBuildPoint()
}

function AddBuildPoint( player, event )
{
	local point = 0
	switch ( event )
	{
		case "EliminatePilot":
			point = 2
			break;

		case "KillPilot":
		case "MeleeHumanExecutionVsPilot":	// 처형
		case "MeleeHumanAttackVsPilot": // 점프킥
			point = 2
			break;

		case "TitanAssist":
			point = 3
			break;

		case "PilotAssist":
		case "evac":
		case "DefenderHacksPanel":
			point = 1
			break;

		case "TitanKilled":
			point = 6
			break

		//case "RoundVictory":
		//	UpdateBuildPoint( player, 1, "RoundVictory" ) 승패 관계 없이 3포인트 지급으로 해달라고 해서 주석 처리 - iskyfish. 151020
		//	break;

		//case "RoundComplete":
		//	UpdateBuildPoint( player, 3, "RoundComplete" ) !ky 주석처리
		//	break;

		// 플레이어 폭탄설치
		case "AttackRushPanel":
			point = 6
			break

		// 플레이어 폭탄해제
		case "DefenceRushPanel":
			point = 6
			break

		// 플레이어 rushPanel 파괴
		case "PlayerRushPanelDestroy":
			point = 6
			break

		// 공격 팀 rushPanel 파괴
		//case "TeamRushPanelDestroy":
		//	point = 2
		//	break

	}

	if( point != 0)
	{
		UpdateBuildPoint( player, point, event )
	}
}

function UpdateBuildPoint( player, point, event )
{
	player.SetCurTitanBuildPoint( player.GetCurTitanBuildPoint() + point )

	Remote.CallFunction_NonReplay( player, "ServerCallback_UpdateTitanModeHUD" )
}

function ForceTitanBuildPointComplete( player )
{
	player.SetTitanBuildPoint( 0 )
}

function GiveTitanBuildPointAdvantage( player, ent, savedDamage, shieldDamage )
{
}

TitanBuildRule_Time_Main()