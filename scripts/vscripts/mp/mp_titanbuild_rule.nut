// I fucking hate nexon

function main()
{
	// printt( "[TitanBuildRule] call TitanBuildRuleMain" )

	// level.titanBuildRuleFunctions <- []
	// level.titanBuildRuleFunctions.resize( eTitanBuildRule._count_ )

	// for ( local index = 0; index < level.titanBuildRuleFunctions.len(); index++ )
	// {
	// 	level.titanBuildRuleFunctions[index] = []
	// 	level.titanBuildRuleFunctions[index].resize( eTitanBuildEvent._count_ )

	// }

	// IncludeScript( "mp/mp_titanBuild_rule_time" )
	// IncludeScript( "mp/mp_titanBuild_rule_time_atdm" )
	// IncludeScript( "mp/mp_titanBuild_rule_point" )
	AddCallback_GameStateEnter( eGameState.Playing, RoundBasedTitanReset )
}


// function AddCallback_TitanBuildRuleFunc( buildRule, event, callbackFunc )
// {
// 	//Assert(  ( event in level.titanBuildEventString ), "invalid event : " + event )
// 	Assert( event > eTitanBuildEvent.invalid && event < eTitanBuildEvent._count_ )

// 	local name = FunctionToString( callbackFunc )

// 	local callbackInfo = {}
// 	callbackInfo.name <- name
// 	callbackInfo.func <- callbackFunc
// 	callbackInfo.scope <- this

// 	level.titanBuildRuleFunctions[buildRule][event] = callbackInfo
// }

function InitTitanBuildRule( player )
{
	player.SetTitanBuildStarted( false )
	player.SetTitanReady( false )
	player.titansBuilt = 0
	player.SetTitanBuildTime( 0 )
	player.SetTitanRespawnTime( -1 )
}

function TitanDeployed( player )
{
	player.titansBuilt++
	player.SetTitanDeployed( true )
	player.SetTitanBuildStarted( false )
	player.SetTitanReady( false )
}

function ResetTitanBuildCompleteCondition( player, forceBuild = false )
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
		player.SetTitanBuildTime( reBuildTime )
	}
	else
	{
		player.SetTitanBuildTime( buildTime )
	}
}

function StartTitanBuildProgress( player, forceBuild = false, rebuild = false )
{
	if( level.nv.titanAvailability == eTitanAvailability.Never )
		return

	if( level.nv.titanAvailability == eTitanAvailability.Once && player.titansBuilt > 0 )
		return

	if ( !forceBuild && !rebuild )
	{
		if( player.IsTitanBuildStarted() || player.IsTitanReady() || player.IsTitanDeployed() )
			return
	}

	printt( "StartTitanBuildProgress: " + player.GetName() )

	player.SetTitanBuildStarted( true )
	player.SetTitanReady( false	)

	ResetTitanBuildCompleteCondition( player, forceBuild )

	StartTitanBuild( player )

	Remote.CallFunction_NonReplay( player, "ServerCallback_UpdateTitanModeHUD" )

	thread Update( player )
}

function StartTitanBuild( player )
{
	player.SetTitanRespawnTime( Time() + player.GetTitanBuildTime() )
}

function ETACanNagPlayer( player )
{
	ETAAnnouncementAllowanceTime <- 10.0

	return player.s.replacementTitanETA_lastNagTime == 0 || Time() - player.s.replacementTitanETA_lastNagTime >= ETAAnnouncementAllowanceTime
}

function TryHandleTitanETA( player )
{
	ETA2MinUpperBound <- 123
	ETA2MinLowerBound <- 115
	ETA60sUpperBound <- 63
	ETA60sLowerBound <- 55
	ETA30sUpperBound <- 33
	ETA30sLowerBound <- 25
	ETA15sUpperBound <- 18
	ETA15sLowerBound <- 12

	if( GetRemain( player ) <= 0)
		return

	if ( GetGameState() > eGameState.Epilogue )
		return

	if( ( GetRemain( player ) < ETA2MinUpperBound && GetRemain( player ) > ETA2MinLowerBound ) && ETACanNagPlayer( player ) )
	{
		if ( player.titansBuilt )
			PlayConversationToPlayer( "TitanReplacementETA120s" , player )
		else
			PlayConversationToPlayer( "FirstTitanETA120s", player )

		player.s.replacementTitanETA_lastNagTime = Time()
	}
	else if( ( GetRemain( player ) < ETA60sUpperBound && GetRemain( player ) > ETA60sLowerBound  ) && ETACanNagPlayer( player ) )
	{
		if ( player.titansBuilt )
			PlayConversationToPlayer( "TitanReplacementETA60s" , player )
		else
			PlayConversationToPlayer( "FirstTitanETA60s", player )

		player.s.replacementTitanETA_lastNagTime = Time()
	}
	else if( ( GetRemain( player ) < ETA30sUpperBound && GetRemain( player ) > ETA30sLowerBound ) && ETACanNagPlayer( player ) )
	{
		if ( player.titansBuilt )
			PlayConversationToPlayer( "TitanReplacementETA30s" , player )
		else
			PlayConversationToPlayer( "FirstTitanETA30s", player )

		player.s.replacementTitanETA_lastNagTime = Time()

	}
	else if( ( GetRemain( player ) < ETA15sUpperBound && GetRemain( player ) > ETA15sLowerBound ) && ETACanNagPlayer( player ) )
	{
		if ( player.titansBuilt )
			PlayConversationToPlayer( "TitanReplacementETA15s" , player )
		else
			PlayConversationToPlayer( "FirstTitanETA15s", player )

		player.s.replacementTitanETA_lastNagTime = Time()
	}
}

function NagPlayerTitan( player )
{
	for(;;)
	{
		wait 0;

		if( !IsValid( player ) )
			return

		if(player.IsTitanDeployed())
			return

		TryReplacementTitanReadyAnnouncement( player )
	}
}

function Update( player )
{
	for(;;)
	{
		wait 0

		if( !IsValid( player ) )
			return

		if( player.IsTitanBuildStarted() == false )
			return

		if( player.IsTitanReady() == true )
			return

		if( player.IsTitanDeployed() == true )
			return

		if( IsTitanBuildComplete(player )  )
		{
			player.SetTitanBuildStarted( false )
			player.SetTitanReady( true )
			thread NagPlayerTitan( player )
		} else {
			TryHandleTitanETA( player )
		}
	}
}

function IsTitanBuildComplete( player )
{
	return ( player.GetTitanRespawnTime() <= Time() )
}

function GetRemain( player )
{
	if( player.IsTitanBuildStarted() == false )
		return -1

	return player.GetTitanRespawnTime() - Time()
}

function GetCompleteCondition( player )
{
	return player.GetTitanBuildTime()
}

function ShouldGiveTimerCredit( player, victim )
{
	if ( player == victim )
		return false

	if ( player.IsTitan() && player.GetDoomedState() )
		return false

	return true
}

function GiveTitanBuildAdvantage( player, ent, saveDamage = 0, shieldDamage = 0)
{
	if( ShouldGiveTimerCredit( player, ent) == false )
		return

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
		DecrementBuild( player, timerCredit )
	}
}

function DecrementBuild( player, amount )
{
	local newRespawnTime = player.GetTitanRespawnTime() - amount
	if (newRespawnTime >= 0) {
		player.SetTitanRespawnTime(newRespawnTime)
	}
}

function ForceTitanBuildComplete( player )
{
	if( player.IsTitanReady() == true )
		return

	player.SetTitanBuildStarted( false )
	StartTitanBuildProgress( player, true )
}

function AddTitanBuildPoint( player, event )
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

function RoundBasedTitanReset()
{
	if ( IsRoundBased() )
	{
		local players = GetPlayerArray()
		foreach ( player in players )
		{
			StartTitanBuildProgress( player, false, true )
		}
	}
}


main()


