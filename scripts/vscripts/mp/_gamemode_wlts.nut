//LTS and WLTS are almost the same for now

function main()
{
	IncludeFile( "mp/last_titan_standing" )

	SetGameModeScoreEventOverrideFunc( WLTS_SetScoreEventOverride )

	AddCallback_PlayerOrNPCKilled( PlayWLTSDialogue )
	GM_AddEndRoundFunc( WLTS_RoundEnd )
	RegisterSignal( "WLTS_RoundEnd" )

}

function WLTS_SetScoreEventOverride()
{
	//Only do scoreEventOverrides for events involving killing Titan and killing pilots. Bonuses like headshots, melee kills etc are not overriden
	level.gameModeScoreEventOverrides[ "EliminateTitan" ] 	<- POINTVALUE_WLTS_ELIMINATE_TITAN

/*	for ( local i = 0 ; i < Native_GetTitanCount() ; i+=1 )
	{
		local strTitanType = Native_GetTitanScriptType(i)
		local strEventName = "Kill" + strTitanType
		level.gameModeScoreEventOverrides[ strEventName ] 		<- POINTVALUE_WLTS_KILL_TITAN
	}*/

	level.gameModeScoreEventOverrides[ "KillAtlas" ] 		<- POINTVALUE_WLTS_KILL_TITAN
	level.gameModeScoreEventOverrides[ "KillStryder" ] 		<- POINTVALUE_WLTS_KILL_TITAN
//	level.gameModeScoreEventOverrides[ "KillSlammer" ] 		<- POINTVALUE_WLTS_KILL_TITAN
	level.gameModeScoreEventOverrides[ "KillOgre" ] 		<- POINTVALUE_WLTS_KILL_TITAN

	level.gameModeScoreEventOverrides[ "KillTitan" ] 		<- POINTVALUE_WLTS_KILL_TITAN
	level.gameModeScoreEventOverrides[ "TitanAssist" ] 		<- POINTVALUE_WLTS_ASSIST_TITAN
	level.gameModeScoreEventOverrides[ "EliminatePilot" ] 	<- POINTVALUE_WLTS_ELIMINATE_PILOT
	level.gameModeScoreEventOverrides[ "KillPilot" ] 		<- POINTVALUE_WLTS_KILL_PILOT
	level.gameModeScoreEventOverrides[ "PilotAssist" ] 		<- POINTVALUE_WLTS_ASSIST
}

function PlayWLTSDialogue( entity, attacker, damageInfo )
{
	if ( !entity.IsPlayer() && !entity.IsTitan() )
		return

	if ( GetGameState() != eGameState.Playing )
		return

	local entityTeam = entity.GetTeam()
	local entityPlayerTeamLeftAlive = GetLivingPlayers( entityTeam )

	Assert( entityPlayerTeamLeftAlive.len() <= 2, "WLTS has more than 2 players left alive on team: " + entityTeam )

	if ( entityPlayerTeamLeftAlive.len() == 0 ) //No one left alive
		return

	if ( entity.IsPlayer() )
	{
		PlayConversationToPlayer( "WingmanIsKilled", entityPlayerTeamLeftAlive[0] )
		thread TellPlayerHeIsAloneAfterAWhile( entityPlayerTeamLeftAlive[0] )
	}
	else if ( entity.IsTitan() && TitanCountsForLTS( entity ) )
	{
		local ownerPlayer = entity.GetBossPlayer()
		if ( !IsValid( ownerPlayer ) )
			return

		foreach( player in entityPlayerTeamLeftAlive  )
		{
			if ( player == ownerPlayer )
				continue

			PlayConversationToPlayer( "WingmanTitanDown", player )
		}
	}
}

function TitanCountsForLTS( titan )
{
	return !( "noLongerCountsForLTS" in titan.s )
}

function TellPlayerHeIsAloneAfterAWhile( player )
{
	local randomDelay = RandomInt( 7, 15 )

	level.ent.EndSignal( "WLTS_RoundEnd" )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "Disconnected" )

	wait randomDelay

	if ( !IsAlive( player ) )
		return

	local enemyTeam = GetOtherTeam(player.GetTeam())
	local enemyPlayersAlive = GameTeams.GetNumLivingPlayers( enemyTeam )

	if ( enemyPlayersAlive == 2 )
	{
		PlayConversationToPlayer( "OnYourOwnDownThere", player )
	}
}

function WLTS_RoundEnd()
{
	level.ent.Signal( "WLTS_RoundEnd" )

}


