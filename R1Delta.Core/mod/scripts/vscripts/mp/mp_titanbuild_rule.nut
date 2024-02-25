function TitanBuildRuleMain()
{
	printt( "[TitanBuildRule] call TitanBuildRuleMain" )

	level.titanBuildRuleFunctions <- []
	level.titanBuildRuleFunctions.resize( eTitanBuildRule._count_ )

	for ( local index = 0; index < level.titanBuildRuleFunctions.len(); index++ )
	{
		level.titanBuildRuleFunctions[index] = []
		level.titanBuildRuleFunctions[index].resize( eTitanBuildEvent._count_ )

	}

	IncludeScript( "mp/mp_titanBuild_rule_time" )
	IncludeScript( "mp/mp_titanBuild_rule_time_atdm" )
	IncludeScript( "mp/mp_titanBuild_rule_point" )

}


function AddCallback_TitanBuildRuleFunc( buildRule, event, callbackFunc )
{
	//Assert(  ( event in level.titanBuildEventString ), "invalid event : " + event )
	Assert( event > eTitanBuildEvent.invalid && event < eTitanBuildEvent._count_ )

	local name = FunctionToString( callbackFunc )

	local callbackInfo = {}
	callbackInfo.name <- name
	callbackInfo.func <- callbackFunc
	callbackInfo.scope <- this

	level.titanBuildRuleFunctions[buildRule][event] = callbackInfo
}

function InitTitanBuildRule( player )
{
	player.SetTitanBuildStarted( false )
	player.SetTitanReady( false )

	local buildRule = 0/*GameRules.GetTitanBuildRule()*/

	local callbackInfo = level.titanBuildRuleFunctions[buildRule][eTitanBuildEvent.INIT]

	if( callbackInfo == null )
		return

	callbackInfo.func.acall( [callbackInfo.scope, player] )
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
	local buildRule = 0/*GameRules.GetTitanBuildRule()*/

	local callbackInfo = level.titanBuildRuleFunctions[buildRule][eTitanBuildEvent.RESET_COMPLETE_CONDITION]

	if( callbackInfo == null )
		return

	callbackInfo.func.acall( [callbackInfo.scope, player, forceBuild ] )
}

function StartTitanBuildProgress( player, forceBuild = false )
{
	// 타이탄 사용 안함
	if( level.nv.titanAvailability == eTitanAvailability.Never )
		return

	// 한판에 타이탄 한번만 사용하고 타이탄을 한번이상 리스폰 했을경우.
	if( level.nv.titanAvailability == eTitanAvailability.Once && player.titansBuilt > 0 )
		return

	// 강제 소환이 아니고 트레이닝 모드일때
	if ((GAMETYPE == "tutorial" || GAMETYPE == "titan_tutorial") && forceBuild == false)
	 	return

	// 타이탄 빌드가 진행중일 경우
	if( player.IsTitanBuildStarted() == true )
		return

	// 타이탄이 준비되어 있을경우
	if( player.IsTitanReady() == true )
		return

	// 타이탄이 소환된 상태 일때
	if( player.IsTitanDeployed() == true )
		return

	local buildRule = 0/*GameRules.GetTitanBuildRule()*/

	local callbackInfo = level.titanBuildRuleFunctions[buildRule][eTitanBuildEvent.START]

	printt( callbackInfo )
	if( callbackInfo == null )
		return

	player.SetTitanBuildStarted( true )
	player.SetTitanReady( false	)

	ResetTitanBuildCompleteCondition( player, forceBuild )	

	callbackInfo.func.acall( [callbackInfo.scope, player] )

	Remote.CallFunction_NonReplay( player, "ServerCallback_UpdateTitanModeHUD" )

	thread Update( player )
}

function Update( player )
{
	local buildRule = 0/*GameRules.GetTitanBuildRule()*/

	for(;;)
	{
		wait 0

		//local playerArray = GetPlayerArray()

		//foeeach( player in playerArray )
		//{
			if( !IsValid( player ) )
				return
				
			if( player.IsTitanBuildStarted() == false )
				return

			if( player.IsTitanReady() == true )
				return

			if( player.IsTitanDeployed() == true )
				return

			// 빌드 완성.
			if( IsTitanBuildComplete(player )  )
			{
				player.SetTitanBuildStarted( false )
				player.SetTitanReady( true )

				// if (GAMETYPE != "tutorial" && GAMETYPE != "titan_tutorial" && ShouldSpawnAsTitan(player) == false)
				// 	SetPlayerActiveObjective( player, "Titan_Status_Ready" )
			}
			 
		//}
	}
}

function IsTitanBuildComplete( player )
{
	local buildRule = 0/*GameRules.GetTitanBuildRule()*/

	local callbackInfo = level.titanBuildRuleFunctions[buildRule][eTitanBuildEvent.END_CHECK]

	if( callbackInfo != null )
	{
		return callbackInfo.func.acall( [callbackInfo.scope, player] )
	}

	return false
}

function GetRemain( player )
{
	if( player.IsTitanBuildStarted() == false )
		return -1

	local buildRule = 0/*GameRules.GetTitanBuildRule()*/

	local callbackInfo = level.titanBuildRuleFunctions[buildRule][eTitanBuildEvent.REMAIN]

	if( callbackInfo == null )
		return -1

	local remain = callbackInfo.func.acall( [callbackInfo.scope, player] )

	return remain
}

function GetCompleteCondition( player )
{
	local buildRule = 0/*GameRules.GetTitanBuildRule()*/

	local callbackInfo = level.titanBuildRuleFunctions[buildRule][eTitanBuildEvent.GET_COMPLETE_CONDITION]

	if( callbackInfo == null )
		return -1

	return ( callbackInfo.func.acall( [callbackInfo.scope, player] ) )
}

function ShouldGiveTimerCredit( player, victim )
{
	if ( player == victim )
		return false

	if ( player.IsTitan() && player.GetDoomedState() )
		return false

	if( player.IsTitanBuildStarted() == false || player.IsTitanReady() == true || player.IsTitanDeployed() == true )
	{
		return false
	}

	return true
}

function GiveTitanBuildAdvantage( player, ent, saveDamage = 0, shieldDamage = 0)
{
	if( ShouldGiveTimerCredit( player, ent) == false )
		return

	local buildRule = 0/*GameRules.GetTitanBuildRule()*/

	local callbackInfo = level.titanBuildRuleFunctions[buildRule][eTitanBuildEvent.ADD_BUILD_ADVENTAGE]

	if( callbackInfo == null )
		return

	Remote.CallFunction_NonReplay( player, "ServerCallback_UpdateTitanModeHUD" )

	callbackInfo.func.acall( [callbackInfo.scope, player, ent, saveDamage, shieldDamage] )
}

function DecrementBuild( player, amount )
{
	local buildRule = 0/*GameRules.GetTitanBuildRule()*/

	local callbackInfo = level.titanBuildRuleFunctions[buildRule][eTitanBuildEvent.DECREMENT_BUILD_CONDITION]

	if( callbackInfo == null )
		return

	callbackInfo.func.acall( [callbackInfo.scope, player, amount] )
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
	local buildRule = 0/*GameRules.GetTitanBuildRule()*/

	local callbackInfo = level.titanBuildRuleFunctions[buildRule][eTitanBuildEvent.ADD_BUILD_POINT]

	if( callbackInfo == null )
		return

	callbackInfo.func.acall( [callbackInfo.scope, player, event] )

	Remote.CallFunction_NonReplay( player, "ServerCallback_UpdateTitanModeHUD" )
}
TitanBuildRuleMain()


