function main()
{
	Globalize( GetConversationIndex )
	Globalize( PlaySquadConversationToPlayer )
	Globalize( PlaySquadConversationToTeam )
	Globalize( PlaySquadConversationToAll )
	Globalize( PlaySpectreChatterToAll )
	Globalize( PlaySpectreChatterToTeam )
	Globalize( PlaySpectreChatterToPlayer )
	Globalize( PlaySquadConversation )
	Globalize( PlayConversationToPlayer )
	Globalize( PlayConversationToTeam )
	Globalize( PlayConversationToAll )
	Globalize( PlayConversationToAllExcept )
	Globalize( PlayConversationExcludePlayer )
	Globalize( PlayConversationToTeamExceptPlayer )
	Globalize( ForcePlayConversationToPlayer )
	Globalize( ForcePlayConversationToAll )
	Globalize( ForcePlayConversationToTeam )
	Globalize( SetGlobalForcedDialogueOnly )
	Globalize( SetPlayerForcedDialogueOnly )
	Globalize( CodeCallback_ScriptedDialogue )
	Globalize( GetNearbyEnemyAI )
	Globalize( GetNearbyFriendlyAI )
	Globalize( CodeCallback_OnNPCLookAtHint )

	level.hotspotHints <- {}
	level.hotspotHints[ "window" ] <- "aichat_hotspot_window"
	level.hotspotHints[ "window2" ] <- "aichat_hotspot_second_floor_window"
	level.hotspotHints[ "door" ] <- "aichat_hotspot_door"
	level.hotspotHints[ "balcony" ] <- "aichat_hotspot_balcony"
	level.hotspotHints[ "corner" ] <- "aichat_hotspot_corner"

	foreach ( model in level.vduModels )
	{
		PrecacheModel( model )
	}

	RegisterFunctionDesc( "PlayConversationToPlayer", " Play conversation passed in to player specified" )

	// dialogue that comes from ai schedule notifies

	// must match order of enum eCodeDialogueID
	local array =
	[
		CodeDialogue_ManDown
		CodeDialogue_GruntSalute
		CodeDialogue_EnemyContact
		CodeDialogue_RunFromEnemy
		CodeDialogue_Reload
		CodeDialogue_MoveToAssault
		CodeDialogue_MoveToSquadLeader
		CodeDialogue_FanOut
	]

	level.codeDialogueFunc <- array
	Assert( level.codeDialogueFunc.len() == eCodeDialogueID.DIALOGUE_COUNT )
}

function CodeDialogue_GruntSalute( guy )
{
	//EmitSoundOnEntity( guy, "grunt_salute" )
	//PlaySquadConversationToAll( "grunt_salute" )
}

function CodeDialogue_EnemyContact( guy )
{
}

/*
function CodeDialogue_EnemyContact( guy )
{
	Assert( IsAlive( guy ) )

	local enemy = guy.GetEnemy()
	if ( !IsAlive( enemy ) )
		return

	if ( enemy.IsTitan() )
	{
		if ( Distance( guy.GetOrigin(), enemy.GetOrigin() ) < 1000 )
			PlaySquadConversationToAll( "aichat_spot_titan_close", guy )
		else
			PlaySquadConversationToAll( "aichat_callout_titan", guy )
		return
	}

	if ( enemy.IsPlayer() )
	{
		if ( Distance( guy.GetOrigin(), enemy.GetOrigin() ) < 1000 )
			PlaySquadConversationToAll( "aichat_engage_pilot", guy )
		else
			PlaySquadConversationToAll( "aichat_callout_pilot", guy )
		return
	}
}
*/

function CodeDialogue_RunFromEnemy( guy )
{
	local enemy = guy.GetEnemy()
	if ( !IsAlive( enemy ) )
		return

	if ( enemy.IsTitan() )
	{
		local squadName = guy.Get( "squadname" )

		local isSquad = false

		if ( squadName != "" )
		{
			local squad = GetNPCArrayBySquad( squadName )
			isSquad = squad.len() > 1
		}

		if ( isSquad )
		{
			// has a safe hint? running to building
			if ( guy.GetSafeHint() )
				PlaySquadConversationToAll( "grunt_flees_titan_building", guy )
			else
				PlaySquadConversationToAll( "grunt_group_flees_titan", guy )
		}
		else
		{
			PlaySquadConversationToAll( "grunt_flees_titan", guy )
		}
	}
}

function CodeDialogue_Reload( guy )
{
	PlaySquadConversationToAll( "aichat_reload", guy )
}

function CodeDialogue_FanOut( guy )
{
	PlaySquadConversationToAll( "aichat_fan_out", guy )
}

function CodeDialogue_MoveToSquadLeader( guy )
{
	PlaySquadConversationToAll( "aichat_move_squadlead", guy )
}

function CodeDialogue_MoveToAssault( guy )
{
	if ( "assaultFrontline" in guy.s )
	{
		local squadName = guy.Get( "squadname" )

		local isSquad = false

		if ( squadName != "" )
		{
			local squad = GetNPCArrayBySquad( squadName )
			isSquad = squad.len() > 1
		}

		if ( isSquad )
			PlaySquadConversationToAll( "aichat_move_out", guy )
	}
}


function CodeDialogue_ManDown( guy )
{
}

function SetGlobalForcedDialogueOnly( value )
{
	level.nv.forcedDialogueOnly = value
}


function SetPlayerForcedDialogueOnly( player, value )
{
	player.SetForcedDialogueOnly( value )
}

function PlayConversationExcludePlayer( conversationType, excludePlayer )
{
	if ( IsForcedDialogueOnly( player ) )
	{
		printt( "ForcedDialogueOnly, not playing conversationType: " + conversationType )
		return
	}

	local playerArr = GetPlayerArray()
	foreach( player in playerArr )
	{
		if ( player == excludePlayer )
			continue

		PlayConversation_internal( conversationType, player )
	}
}

function PlayConversationToPlayer( conversationType, player )
{
	if ( IsForcedDialogueOnly( player ) )
	{
		printt( "ForcedDialogueOnly, not playing conversationType: " + conversationType )
		return
	}

	PlayConversation_internal( conversationType, player )
}

function PlayConversationToTeam( conversationType, team )
{
	local playerArr = GetPlayerArrayOfTeam( team )
	foreach( player in playerArr )
		PlayConversationToPlayer( conversationType, player )
}

function PlayConversationToTeamExceptPlayer( conversationType, team, excludePlayer )
{
	local playerArr = GetPlayerArrayOfTeam( team )
	foreach( player in playerArr )
	{
		if ( player == excludePlayer )
			continue

		PlayConversation_internal( conversationType, player )
	}
}

function PlayConversationToAll( conversationType )
{
	local playerArr = GetPlayerArray()
	foreach( player in playerArr )
		PlayConversationToPlayer( conversationType, player )
}

function PlayConversation_internal( conversationType, player )
{
	if ( conversationType == null || conversationType == "" )
		return
	local conversationID = GetConversationIndex( conversationType )
	Remote.CallFunction_NonReplay( player, "ServerCallback_PlayConversation", conversationID )
}

function ForcePlayConversationToAll( conversationType )
{
	local playerArr = GetPlayerArray()
	foreach( player in playerArr )
	{
		ForcePlayConversationToPlayer( conversationType, player )
	}
}

function ForcePlayConversationToTeam( conversationType, team )
{
	local playerArr = GetPlayerArrayOfTeam( team )
	foreach( player in playerArr )
	{
		ForcePlayConversationToPlayer( conversationType, player )
	}
}

//Like PlayConversation, but no checking for flags
function ForcePlayConversationToPlayer( conversationType, player )
{
	PlayConversation_internal( conversationType, player )
}

// 1700 units
function GetNearbyFriendlyAI( origin, team )
{
	local guys = []
	local ai = GetNPCArrayEx( "npc_soldier", team, origin, AI_CONVERSATION_RANGE )
	foreach ( guy in ai )
	{
		if ( IsAlive( guy ) )
			guys.append( guy )
	}

	return guys
}

function GetNearbyEnemyAI( origin, team )
{
	team = GetEnemyTeam( team )

	local guys = []
	local ai = GetNPCArrayEx( "npc_soldier", team, origin, AI_CONVERSATION_RANGE )
	foreach ( guy in ai )
	{
		if ( IsAlive( guy ) )
			guys.append( guy )
	}

	return guys
}

function SquadExistsForConversation( ai, conversationType )
{
	if ( !IsAlive( ai ) )
		return false

	// only soldiers play squad conversations
	if ( !ai.IsSoldier() )
		return false

	//Squadless AI don't play squad conversations
	local squadName = ai.Get( "squadname" )
	if ( squadName == "" )
		return false

	if ( !( conversationType in level.ConvToIndex) )
	{
		printt( "*****WARNING***** Conversation " + conversationType + " does not exist! Returning" )
		return false
	}

	return true
}

function GetSquadEHandles( ai )
{
	local aiHandles = [ null, null, null, null ]

	local squadName = ai.Get( "squadname" )

	if ( squadName == "" )
		return aiHandles

	local squad = GetNPCArrayBySquad( squadName )
	ArrayRemove( squad, ai )
	aiHandles[ 0 ] = ai.GetEncodedEHandle()

	local nextIdx = 1

	foreach ( guy in squad )
	{
		if ( !IsValid( guy ) )
			continue

		Assert( guy.GetClassname() == "npc_soldier", "Can't do squad dialogue for squad " + squadName + " because one of the squad members is not an npc_soldier: " + guy )

		aiHandles[ nextIdx ] = guy.GetEncodedEHandle()

		++nextIdx

		if ( nextIdx >= aiHandles.len() )
			break
	}

	return aiHandles
}

function PlaySquadConversationToPlayer( conversationType, player, ai, rangeSqr = AI_CONVERSATION_RANGE_SQR  )
{
	if ( SquadExistsForConversation( ai, conversationType ) )
	{
		local aiHandles = GetSquadEHandles( ai )
		PlaySquadConversationToPlayer_Internal( conversationType, player, ai, rangeSqr, aiHandles )
	}

}

// All PlaySquadConversation functions eventually funnel down to this.
// Funciton is broken apart from PlaySquadConversationToPlayer since PlaySquadConversationToPlayer has
// a few expensive checks that only need to be run once for every conversation we're trying to play,
// as opposed to for every player we're trying to play a conversation to.
function PlaySquadConversationToPlayer_Internal( conversationType, player, ai, rangeSqr, aiHandles )
{
	Assert( IsAlive( ai ), ai + " is dead." )
	Assert( aiHandles.len() == 4 )
	local org = ai.GetOrigin()
	local time = Time()
	local allowedTime = time - MIN_TIME_BETWEEN_SAME_CONVERSATION

	// tell client to play conversation
	local conversationID = GetConversationIndex( conversationType )
	if ( !ShouldPlaySquadConversation( player, conversationType, allowedTime, org, rangeSqr ) )
		return

	UpdateConversationTracking( player, conversationType, time )
	Remote.CallFunction_Replay( player, "ServerCallback_PlaySquadConversation", conversationID, aiHandles[0], aiHandles[1], aiHandles[2], aiHandles[3] )


}

function PlaySquadConversation( conversationType, ai )
{
	PlaySquadConversationToAll( conversationType, ai )
}

function PlaySquadConversationToAll( conversationType, ai, rangeSqr = AI_CONVERSATION_RANGE_SQR )
{
	if ( !SquadExistsForConversation( ai, conversationType ) )
		return

	local aiHandles = GetSquadEHandles( ai )

	local players = GetPlayerArray()
	foreach ( player in players )
	{
		PlaySquadConversationToPlayer_Internal( conversationType, player, ai, rangeSqr, aiHandles )
	}
}

function PlaySquadConversationToTeam( conversationType, team, ai, rangeSqr = AI_CONVERSATION_RANGE_SQR )
{
	if ( !SquadExistsForConversation( ai, conversationType ) )
		return

	local aiHandles = GetSquadEHandles( ai )

	local players = GetPlayerArrayOfTeam( team )
	foreach ( player in players )
	{
		PlaySquadConversationToPlayer_Internal( conversationType, player, ai, rangeSqr, aiHandles )
	}

}

function PlaySpectreChatterToAll( conversationType, spectre, rangeSqr = AI_CONVERSATION_RANGE_SQR )
{
	PlaySpectreChatterToTeam( conversationType, TEAM_IMC, spectre, rangeSqr )
	PlaySpectreChatterToTeam( conversationType, TEAM_MILITIA, spectre, rangeSqr )
}

function PlaySpectreChatterToTeam( conversationType, team, spectre, rangeSqr = AI_CONVERSATION_RANGE_SQR )
{
	local players = GetPlayerArrayOfTeam( team )
	foreach ( player in players )
	{
		PlaySpectreChatterToPlayer( conversationType, player, spectre, rangeSqr = AI_CONVERSATION_RANGE_SQR )
	}

}

function PlaySpectreChatterToPlayer( conversationType, player, spectre, rangeSqr = AI_CONVERSATION_RANGE_SQR )
{
	//PrintFunc()
	local spectreOrigin = spectre.GetOrigin()
	local time = Time()
	local allowedTime = time - MIN_TIME_BETWEEN_SAME_CONVERSATION

	local teamSpecificSoundAlias = GetSpectreTeamSpecificSoundAlias( spectre, conversationType )

	Assert( DoesAliasExist( teamSpecificSoundAlias ) )

	//printt( "Trying to play spectre chatter: " +  teamSpecificSoundAlias + " to player: " + player)
	if ( !ShouldPlaySquadConversation( player, teamSpecificSoundAlias, allowedTime, spectreOrigin, rangeSqr ) )
		return

	UpdateConversationTracking( player, teamSpecificSoundAlias, time )

	EmitSoundOnEntityOnlyToPlayer( spectre, player, teamSpecificSoundAlias )
}

function GetSpectreTeamSpecificSoundAlias( spectre, partialConversationAlias )
{
	local spectreTeam = spectre.GetTeam()

	if ( spectreTeam == TEAM_IMC )
		return "diag_imc_" + partialConversationAlias
	else if ( spectreTeam == TEAM_MILITIA )
		return "diag_militia_" + partialConversationAlias

	Assert( false, "Team for spectre: " + spectre + " is neither IMC nor militia" )

	return null

}

//	function PlayAIConversation( conversationType, ai, rangeSqr = AI_CONVERSATION_RANGE_SQR )
//	{
//		if ( !( conversationType in level.ConvToIndex) )
//		{
//			printt( "*****WARNING***** Conversation " + conversationType + " does not exist! Returning" )
//			return
//		}
//		local players = GetPlayerArray()
//
//		Assert( IsAlive( ai ), ai + " is dead." )
//		local org = ai.GetOrigin()
//		local time = Time()
//		local allowedTime = time - MIN_TIME_BETWEEN_SAME_CONVERSATION
//
//		local entityHandle = ai.GetEncodedEHandle()
//		// tell client to play conversation
//		local conversationID = GetConversationIndex( conversationType )
//
//		foreach ( player in players )
//		{
//			if ( !ShouldPlaySquadConversationToAll( player, conversationType, allowedTime, org, rangeSqr ) )
//				continue
//
//			UpdateConversationTracking( player, conversationType, time )
//
//			Remote.CallFunction_Replay( player, "ServerCallback_PlaySquadConversation", conversationID, entityHandle )
//		}
//	}

function PlayConversationToAllExcept( conversationType, exceptions )
{
	local playerArr = GetPlayerArray()

	local playerTab = ArrayValuesToTableKeys(  playerArr )

	local exceptionsTable = exceptions
	if ( type( exceptions ) == "array" )
	{
		exceptionsTable = ArrayValuesToTableKeys( exceptions )
	}

	Assert( type( exceptionsTable ) == "table" )

	foreach ( player, val in playerTab )
	{
		if ( player in exceptionsTable )
			continue

		PlayConversationToPlayer( conversationType, player )
	}
}


function CodeCallback_ScriptedDialogue( guy, dialogueID )
{
	Assert( dialogueID < level.codeDialogueFunc.len() )

	if ( level.codeDialogueFunc[ dialogueID ] )
	{
		level.codeDialogueFunc[ dialogueID ]( guy )
	}
}

function UpdateConversationTracking( player, conversationType, time )
{
	if ( !( conversationType in player.s.lastAIConversationTime ) )
		player.s.lastAIConversationTime[ conversationType ] <- time
	else
		player.s.lastAIConversationTime[ conversationType ] = time
}

function GetConversationIndex( conversation )
{
	Assert( conversation != null, "No conversation specified." )
	Assert( typeof( conversation ) == "string" )
	Assert( conversation in level.ConvToIndex, "Conversation " + conversation + " does not exist!" )
	return level.ConvToIndex[ conversation ]
}

function CodeCallback_OnNPCLookAtHint( npc, hint )
{
	if ( !hint.HasKey( "hotspot" ) )
		return

	local hint = hint.kv.hotspot.tolower()
	if ( hint in level.hotspotHints )
	{
		local alias = level.hotspotHints[ hint ]

		local prob = RandomFloat( 0, 1 )

		if ( prob > 0.8 )  //Make this family of conversations happen less often
			PlaySquadConversationToAll( alias, npc )
	}
}