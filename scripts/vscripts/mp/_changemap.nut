function main()
{
	Globalize( CodeCallback_MatchIsOver )
}


function CodeCallback_MatchIsOver()
{

	PopulatePostgameData()
	/*
	switch ( GAMETYPE )
	{
		case COOPERATIVE:
			GameRules.ChangeMap( "mp_lobby", GAMETYPE )
			break

		default:
			GameRules.ChangeMap( "", GAMETYPE ) // [LJS] 이전 게임모드 유지.
			//GameRules.ChangeMap( "mp_lobby", TEAM_DEATHMATCH )
	}
	*/
}

function PopulatePostgameData()
{
	// show the postgame scoreboard summary
	SetUIVar( level, "showGameSummary", true )

	foreach ( entity player in GetPlayerArray() )
	{
		local teams = GetCurrentPlaylistVarInt( "max_teams", 2 )
		local standardTeams = teams != 2
		
		local enumModeIndex = 0`
		local enumMapIndex = 0
				
		enumModeIndex = PersistenceGetEnumIndexForItemName( "gamemodes", GAMETYPE )
		enumMapIndex = PersistenceGetEnumIndexForItemName( "maps", GetMapName() )
		
	
	
		player.SetPersistentVar( "postGameData.myTeam", player.GetTeam() )
		player.SetPersistentVar( "postGameData.myXuid", player.GetUID() )
		player.SetPersistentVar( "postGameData.gameMode", enumModeIndex )
		player.SetPersistentVar( "postGameData.map", enumMapIndex )
		player.SetPersistentVar( "postGameData.teams", standardTeams )
		player.SetPersistentVar( "postGameData.maxTeamSize", teams )
		player.SetPersistentVar( "postGameData.privateMatch", true )
		player.SetPersistentVar( "postGameData.ranked", true )
		player.SetPersistentVar( "postGameData.hadMatchLossProtection", false )
		
		player.SetPersistentVar( "isFDPostGameScoreboardValid", GAMETYPE == FD )
		
		if ( standardTeams )
		{
			if ( player.GetTeam() == TEAM_MILITIA )
			{
				player.SetPersistentVar( "postGameData.factionMCOR", GetFactionChoice( player ) )
				player.SetPersistentVar( "postGameData.factionIMC", GetEnemyFaction( player ) )
			}
			else
			{
				player.SetPersistentVar( "postGameData.factionIMC", GetFactionChoice( player ) )
				player.SetPersistentVar( "postGameData.factionMCOR", GetEnemyFaction( player ) )
			}
			
			player.SetPersistentVar( "postGameData.scoreMCOR", GameRules_GetTeamScore( TEAM_MILITIA ) )
			player.SetPersistentVar( "postGameData.scoreIMC", GameRules_GetTeamScore( TEAM_IMC ) )
		}
		else
		{
			player.SetPersistentVar( "postGameData.factionMCOR", GetFactionChoice( player ) )
			player.SetPersistentVar( "postGameData.scoreMCOR", GameRules_GetTeamScore( player.GetTeam() ) )
		}
		
		local otherPlayers = GetPlayerArray()
		local scoreTypes = GameMode_GetScoreboardColumnScoreTypes( GAMETYPE )
		local persistenceArrayCount = PersistenceGetArrayCount( "postGameData.players" )
		for ( local i = 0; i < min( otherPlayers.len(), persistenceArrayCount ); i++ )
		{
			player.SetPersistentVar( "postGameData.players[" + i + "].team", otherPlayers[ i ].GetTeam() )
			player.SetPersistentVar( "postGameData.players[" + i + "].name", otherPlayers[ i ].GetPlayerName() )
			player.SetPersistentVar( "postGameData.players[" + i + "].xuid", otherPlayers[ i ].GetUID() )
			player.SetPersistentVar( "postGameData.players[" + i + "].callsignIconIndex", otherPlayers[ i ].GetPersistentVarAsInt( "activeCallsignIconIndex" ) )
			
			for ( local j = 0; j < scoreTypes.len(); j++ )
				player.SetPersistentVar( "postGameData.players[" + i + "].scores[" + j + "]", otherPlayers[ i ].GetPlayerGameStat( scoreTypes[ j ] ) )
		}
		
		player.SetPersistentVar( "isPostGameScoreboardValid", true )
	}
}