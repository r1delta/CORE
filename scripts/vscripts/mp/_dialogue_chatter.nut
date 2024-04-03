const CHATTER_TIME_LAPSE = 30.0
//const CHATTER_TIME_LAPSE = 5.0  //For testing
//const CHATTER_TIME_LAPSE = 8.0  //For testing
//const CHATTER_TIME_LAPSE = 15.0 //For testing
function main()
{
	if(!IsLobby())
	{
		thread RandomAIChatter()
	}

	file.lastCanSeeChatterForSquad <- {}
	file.lastLevelSpecificChatterForSquad <- {}
	file.lastGlobalChatterForSquad <- {}
	level.levelSpecificChatterFunc <- null
	Globalize( TryFriendlyChatterToPlayer )
	Globalize( TitanVO_AlertTitansIfTargetWasKilled )
	Globalize( TitanVO_TellPlayersThatAreAlsoFightingThisTarget )
	Globalize( TitanVO_AlertTitansTargetingThisTitanOfRodeo )
	Globalize( TitanVO_DelayedTitanDown )
}

function TitanVO_TellPlayersThatAreAlsoFightingThisTarget( attacker, soul, team )
{
	local voEnum
	if ( attacker.IsTitan() )
		voEnum = eTitanVO.FRIENDLY_TITAN_HELPING
	else
		voEnum = eTitanVO.PILOT_HELPING

	local atackerIsTitan = attacker.IsTitan()
	local players = GetPlayerArrayOfTeam( team )
	foreach ( player in players )
	{
		if ( !player.IsTitan() )
			continue

		// attacker gets a score callout
		if ( player == attacker )
			continue

		if ( soul != player.currentTargetPlayerOrSoul_Ent )
			continue

		if ( Time() - player.currentTargetPlayerOrSoul_LastHitTime > CURRENT_TARGET_FORGET_TIME )
			continue

		// alert other player that cared about this target
		Remote.CallFunction_Replay( player, "SCB_TitanDialogue", voEnum )
	}
}

function TitanVO_AlertTitansTargetingThisTitanOfRodeo( rodeoer, soul )
{
	local team = rodeoer.GetTeam()

	local players = GetPlayerArray()
	foreach ( player in players )
	{
		if ( !player.IsTitan() )
			continue

		if ( player.GetTeam() != team )
			continue

		if ( soul != player.currentTargetPlayerOrSoul_Ent )
			continue

		// if we havent hurt the target recently then forget about it
		if ( Time() - player.currentTargetPlayerOrSoul_LastHitTime > CURRENT_TARGET_FORGET_TIME )
			continue

		Remote.CallFunction_Replay( player, "SCB_TitanDialogue", eTitanVO.FRIENDLY_RODEOING_ENEMY )
	}
}

function TitanVO_DelayedTitanDown( entity )
{
	local titanOrigin = entity.GetOrigin()
	local team = entity.GetTeam()

	wait 0.9

	local playerArray = GetPlayerArray()
	local dist = level.titanVOTitanDeadDistSqr

	foreach ( player in playerArray )
	{
		// only titans get BB vo
		if ( !player.IsTitan() )
			continue

		if ( DistanceSqr( titanOrigin, player.GetOrigin() ) > dist )
			continue

		if ( player.GetTeam() != team )
			Remote.CallFunction_Replay( player, "SCB_TitanDialogue", eTitanVO.ENEMY_TITAN_DEAD )
		else
			Remote.CallFunction_Replay( player, "SCB_TitanDialogue", eTitanVO.FRIENDLY_TITAN_DEAD )
	}
}


function TitanVO_AlertTitansIfTargetWasKilled( victim, attacker )
{
	local team = GetOtherTeam( victim.GetTeam() )
	local players = GetPlayerArrayOfTeam( team )

	if ( victim.IsTitan() )
		victim = victim.GetTitanSoul()

	foreach ( player in players )
	{
		if ( !player.IsTitan() )
			continue

		// attacker gets a score callout
		if ( player == attacker )
			continue

		if ( victim != player.currentTargetPlayerOrSoul_Ent )
			continue

		if ( Time() - player.currentTargetPlayerOrSoul_LastHitTime > CURRENT_TARGET_FORGET_TIME )
			continue

		// alert other player that cared about this target
		Remote.CallFunction_Replay( player, "SCB_TitanDialogue", eTitanVO.ENEMY_TARGET_ELIMINATED )
	}
}

function RandomAIChatter()
{
	FlagWait( "GamePlaying" )

	OnThreadEnd(
		function () : ()
		{
			// self perpetuating
			level.levelSpecificChatterFunc = null
			thread RandomAIChatter()
		}
	)

	level.ent.EndSignal( "GamePlaying" )

	local probability
	for ( ;; )
	{
		PerfStart( PerfIndexServer.AIChatter )

		//Just try talking a whole bunch for now. Probably super inefficient. Come back and do more optimizations later/at conversation system levels
		probability = RandomFloat( 0, 1 )

		// TryLevelSpecificDialogue() //For testing

		if ( probability < 0.33 )
			TryGlobalChatterDialogue()
		else if ( probability < 0.66 )
			TryLevelSpecificDialogue() //If there is no level specific chatter, then this just does nothing. Probably fine since that means we are in classic mode and we want less chatter in it anyway.
		else
			TryNearbyAllyPilotComingThrough()

		PerfEnd( PerfIndexServer.AIChatter )
		wait 1.0
	}
}

function TryNearbyAllyPilotComingThrough()
{
	local ai = GetAllSoldiers()
	local player, dist
	local playerOrg, aiOrg
	local time = Time()

	// each guy tries to find a nearby player to talk about
	foreach ( guy in ai )
	{
		// amortized so need to check guy alive
		if ( !IsAlive( guy ) )
			continue

		local squadName = guy.Get( "squadname" )
		if ( squadName == "" )
			continue

		if ( !( squadName in file.lastCanSeeChatterForSquad ) )
		{
			file.lastCanSeeChatterForSquad[ squadName ] <- 0
		}

		// dont chat too much
		if ( time < file.lastCanSeeChatterForSquad[ squadName ] + CHATTER_TIME_LAPSE )
			continue

		player = guy.GetNearestVisibleFriendlyPlayer()
		if ( !IsAlive( player ) )
			continue

		playerOrg = player.GetOrigin()
		aiOrg = guy.GetOrigin()
		dist = Distance( playerOrg, aiOrg )

		if ( player.IsTitan() )
		{
			if ( dist > 900 )
				continue

			// must be sameish height level
			if ( fabs( playerOrg.z - aiOrg.z ) > 350 )
				continue

			PlaySquadConversationToAll( "aichat_titan_cheer", guy )
		}
		else
		{
			if ( dist > 1200 )
				continue

			// must be sameish height level
			if ( fabs( playerOrg.z - aiOrg.z ) > 450 )
				continue

			//Want to make this conversation in particular pretty low chances of happening
			local rand = RandomFloat( 0, 1 )
			if ( rand > 0.2 )
				continue

			PlaySquadConversationToAll( "aichat_address_pilot", guy )
		}

		file.lastCanSeeChatterForSquad[ squadName ] = time

	}

}

function TryGlobalChatterDialogue()
{
	local time = Time()
	local ai = GetAllSoldiers()

	// each guy tries to find a nearby player to talk about
	foreach ( guy in ai )
	{
		// amortized so need to check guy alive
		if ( !IsAlive( guy ) )
			continue

		//Don't idle chatter when firing at someone
		if ( guy.InCombat() )
			continue

		local squadName = guy.Get( "squadname" )
		if ( squadName == "" )
			continue

		if ( !( squadName in file.lastGlobalChatterForSquad ) )
		{
			file.lastGlobalChatterForSquad[ squadName ] <- 0
		}

		// dont chat too much
		if ( time < file.lastGlobalChatterForSquad[ squadName ] + CHATTER_TIME_LAPSE )
			continue
		local probability = RandomFloat( 0, 1 )
		if ( probability < 0.33 )
		{
			//printt( "Prob high enough for level chat" )
			//Don't chat too much about level specific stuff either. Note that this is a team based check, and is in addition to your squad not chatting too much
			if ( time < file.lastGlobalChatterForSquad[ squadName ] + CHATTER_TIME_LAPSE )
			{
				//printt( "Chatted about level too recently, continuing" )
				continue
			}

			PlaySquadConversationToTeam( "aichat_global_chatter", guy.GetTeam(), guy, AI_FRIENDLY_CHATTER_RANGE_SQR )

			file.lastGlobalChatterForSquad[ squadName ] = time
		}
	}
}

function TryLevelSpecificDialogue()
{
	if ( !level.levelSpecificChatterFunc )
		return

	local time = Time()
	local ai = GetAllSoldiers()

	// each guy tries to find a nearby player to talk about
	foreach ( guy in ai )
	{
		// amortized so need to check guy alive
		if ( !IsAlive( guy ) )
			continue

		//Don't idle chatter when firing at someone
		if ( guy.InCombat() )
			continue

		local squadName = guy.Get( "squadname" )
		if ( squadName == "" )
			continue

		if ( !( squadName in file.lastLevelSpecificChatterForSquad ) )
		{
			file.lastLevelSpecificChatterForSquad[ squadName ] <- 0
		}

		// dont chat too much
		if ( time < file.lastLevelSpecificChatterForSquad[ squadName ] + CHATTER_TIME_LAPSE )
			continue
		local probability = RandomFloat( 0, 1 )
		if ( probability < 0.33 )
		{
			//printt( "Prob high enough for level chat" )
			//Don't chat too much about level specific stuff either. Note that this is a team based check, and is in addition to your squad not chatting too much
			if ( time < file.lastLevelSpecificChatterForSquad[ squadName ] + CHATTER_TIME_LAPSE )
			{
				//printt( "Chatted about level too recently, continuing" )
				continue
			}

		local levelSpecificChatterResult = level.levelSpecificChatterFunc( guy )

	     if ( levelSpecificChatterResult )
			{
				file.lastLevelSpecificChatterForSquad[ squadName ] = Time()
				return
			}
		}
	}
}

function TryFriendlyChatterToPlayer( player, conversation, rangeSqr = AI_CONVERSATION_RANGE_SQR   )
{
	if ( !IsValid( player ) )
		return

	local time = Time()
	local ai = GetAllSoldiers()
	local playerOrigin = player.GetOrigin()
    local playerTeam = player.GetTeam()

	// each guy tries to find a nearby player to talk about
	foreach ( guy in ai )
	{
		// amortized so need to check guy alive
		if ( !IsAlive( guy ) )
			continue

		if ( guy.GetTeam() != playerTeam )
			continue

		//Don't idle chatter when firing at someone
		if ( guy.InCombat() )
			continue

		local squadName = guy.Get( "squadname" )
		if ( squadName == "" )
			continue

		local squadMembers = GetNPCArrayBySquad( squadName )
		local foundNonSoldier = false
		foreach ( member in squadMembers )
		{
			if ( !member.IsSoldier() )
			{
				foundNonSoldier = true
				break
			}
		}

		if ( foundNonSoldier )
		{
			printt( "Found a non soldier in squad " + squadName )
			foreach ( member in squadMembers )
			{
				printt( "Member " + member.GetClassname() + ": " + member.GetName() )
			}
			Assert( 0 )
		}

		local squaredDistanceToGuy = (guy.GetOrigin() - playerOrigin ).LengthSqr()
		if ( squaredDistanceToGuy > rangeSqr )
			continue

		PlaySquadConversationToPlayer( conversation, player, guy, rangeSqr  )
		return

	}

	printt( "Tried to get AI to chatter with " + conversation + " to player " + player + ", but no suitable AI to do so" )


}
