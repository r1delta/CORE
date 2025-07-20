const MFDP_ELIMINATION_BASED = true

function main()
{
	IncludeScript( "mp/_gamemode_mfd" )

	AddCallback_PlayerOrNPCKilled( MFD_OnPlayerOrNPCKilled )
	level.spawnRatingFunc_Pilot = RateFrontLinePlayerSpawnpoint
	level.spawnRatingFunc_Generic = RateFrontLinePlayerSpawnpoint

	level.nv.eliminationMode = eEliminationMode.Pilots

	level.mfdAssault <- {}
	level.mfdAssault[ TEAM_IMC ] <- null
	level.mfdAssault[ TEAM_MILITIA ] <- null

	file.teams <- [ TEAM_IMC, TEAM_MILITIA ]

	// AddCallback_GameStateEnter( eGameState.Prematch, MARKED_FOR_DEATH_PrematchStart )  //MFD: LTS Variant
	AddCallback_GameStateEnter( eGameState.Playing, MARKED_FOR_DEATH_PlayingStart )
	AddCallback_OnPlayerRespawned( MARKED_FOR_DEATH_PlayerRespawned )
	AddCallback_OnClientConnected( MARKED_FOR_DEATH_AddPlayer )
	GM_AddEndRoundFunc( MARKED_FOR_DEATH_EndRoundFunc )
	AddCallback_OnClientDisconnected( MFD_Pro_PlayerDisconnected )
	

	AddSpawnCallback( "npc_spectre", MFDSpawnMinion )
	AddSpawnCallback( "npc_soldier", MFDSpawnMinion )

	AddSpawnCallback( MARKER_ENT_CLASSNAME, SpawnMarkerEnt )
	FlagSet( "PilotBot" )

	RegisterSignal( "StopReceivingScoreBonus" )
	RegisterSignal( "UpdateMarkedPlayers" )
	RegisterSignal( "PendingMarkedDisconnected" )

	AddPostEntityLoadCallback( CreateMFDAssaultPoints )

	AddCallback_OnTitanBecomesPilot( UpdateMinimapForMarkedOnClassChange )
	AddCallback_OnPilotBecomesTitan( UpdateMinimapForMarkedOnClassChange )

	level.nv.mfdOverheadPingDelay = GetCurrentPlaylistVarFloat( "mfd_ping_delay", 3.0 )

	SetSwitchSidesBased( true )
	SetRoundBased( true )
	SetShouldPlayerBeEliminatedFunc( MFD_Pro_ShouldPlayerBeEliminated )

	SetEndRoundPlayerState( ENDROUND_FREE )

	//FlagSet( "GameModeAlwaysAllowsClassicIntro" ) //Keep jumping out from dropship

	GM_AddEndRoundFunc( MFD_RoundEnd )

	AddPilotEliminationDialogueCallback( PlayMarkedForDeathProDialogue )

	SetRoundWinningKillEnabled( true )
	SetGameWonAnnouncement( "WonAnnouncementShort" )
	SetGameLostAnnouncement( "LostAnnouncementShort" )

	thread FixStartSpawns()

	Globalize( MFD_Pro_PlayerAutobalanced )
}

function FixStartSpawns()
{
	FlagWait( "EntitiesDidLoad" )
	level.nv.eliminationMode = eEliminationMode.Pilots
	switch ( GetMapName() )
	{
		case "mp_rise":
			MoveStartSpawn( "info_spawnpoint_human_start_4",	Vector( -4754.31, 530.761, 425 ),	Vector( 0, 0.0, 0 )	)
			MoveStartSpawn( "info_spawnpoint_human_start_16",	Vector( 1853.35, 3231.19, 31 ),		Vector( 0, -90.0, 0 ) )
			MoveStartSpawn( "info_spawnpoint_human_start_17",	Vector( 1748.29, 3361.25, 31 ),		Vector( 0, -90.0, 0 ) )
			MoveStartSpawn( "info_spawnpoint_human_start_2",	Vector( 1820.3, 3408.32 , 31 ),		Vector( 0, -90.0, 0 ) )
			MoveStartSpawn( "info_spawnpoint_human_start_10",	Vector( 1883.32, 3482.48, 31 ),		Vector( 0, -90.0, 0 ) )
			MoveStartSpawn( "info_spawnpoint_human_start_11",	Vector( 1948.26, 3406.57, 31 ),		Vector( 0, -90.0, 0 ) )
			MoveStartSpawn( "info_spawnpoint_human_start_12",	Vector( 1967.37, 3240.42, 31 ),		Vector( 0, -90.0, 0 ) )
			MoveStartSpawn( "info_spawnpoint_human_start_14",	Vector( 2037.34, 3460.53, 31 ),		Vector( 0, -90.0, 0 ) )
			MoveStartSpawn( "info_spawnpoint_human_start_15",	Vector( 1887.33, 3315.32, 31 ),		Vector( 0, -90.0, 0 ) )
			MoveStartSpawn( "info_spawnpoint_human_start_18",	Vector( 1765.33, 3271.1, 31 ),		Vector( 0, -90.0, 0 ) )
			MoveStartSpawn( "info_spawnpoint_human_start_1",	Vector( -4624.68, 413.207, 425 ),	Vector( 0, 0.0, 0 )	)
			MoveStartSpawn( "info_spawnpoint_human_start_3",	Vector( -4577.88, 472.948, 425 ),	Vector( 0, 0.0, 0 )	)
			MoveStartSpawn( "info_spawnpoint_human_start_5",	Vector( -4618.58, 236.846, 425 ),	Vector( 0, 0.0, 0 )	)
			MoveStartSpawn( "info_spawnpoint_human_start_6",	Vector( -4552.44, 326.207, 425 ),	Vector( 0, 0.0, 0 )	)
			MoveStartSpawn( "info_spawnpoint_human_start_7",	Vector( -4756.06, 232.337, 425 ),	Vector( 0, 0.0, 0 )	)
			MoveStartSpawn( "info_spawnpoint_human_start_8",	Vector( -4717.84, 329.441, 425 ),	Vector( 0, 0.0, 0 )	)
			MoveStartSpawn( "info_spawnpoint_human_start_9",	Vector( -4665.37, 555.152, 425 ),	Vector( 0, 0.0, 0 )	)
			MoveStartSpawn( "info_spawnpoint_human_start_13",	Vector( -4728.95, 438.283, 425 ),	Vector( 0, 0.0, 0 )	)
			break

		case "mp_training_ground":
			local allSpawns = GetEntArrayByClass_Expensive( "info_spawnpoint_human_start" )
			local spawnOrg = Vector( 0.0, 0.0, 0.0 )
			local spawn4Org = GetEnt( "info_spawnpoint_human_start_4" ).GetOrigin()
			local spawn18Org = GetEnt( "info_spawnpoint_human_start_18" ).GetOrigin()
			local maxDist = 400.0

			foreach ( spawn in allSpawns )
			{
				spawnOrg = spawn.GetOrigin()
				if ( ( Distance( spawnOrg, spawn4Org ) > maxDist ) && ( Distance( spawnOrg, spawn18Org ) > maxDist ) )
					spawn.Destroy()
			}

			break
	}
}

function MoveStartSpawn( targetName, origin, angles )
{
	local ent = GetEnt( targetName )
	ent.SetOrigin( origin )
	ent.SetAngles( angles )
}

function MFD_Pro_PlayerDisconnected( player )
{
	if ( player == GetPendingMarked( player.GetTeam() ) )
	{
		//printt( "Pending marked player disconnected" )
		ClearPendingMarkedPlayers()
		MessageToAll( eEventNotifications.MarkedForDeathMarkedDisconnected )
		level.ent.Signal( "PendingMarkedDisconnected" )
		thread DelayUpdateMarkedPlayers() //Necessary due to timing issues
		return
	}

	if ( player == GetMarked( player.GetTeam() ) )
	{
		//printt( "Marked player disconnected" )
		if ( !IsWatchingRoundWinningKillReplay() ) //if watching kill replay already, let that handle setting the winner.
		{
			ClearMarkedPlayers()
			TellClientsMarkedChanged()
			SetWinLossReasons( "#GAMEMODE_MARKED_FOR_DEATH_PRO_DISCONNECT_WIN_ANNOUNCEMENT", "#GAMEMODE_MARKED_FOR_DEATH_PRO_DISCONNECT_LOSS_ANNOUNCEMENT" )
			local otherTeam = GetOtherTeam( player.GetTeam() )
			SetWinner( otherTeam )
		}

	}

	UpdateMarkedPlayers()
}

function MFD_Pro_PlayerAutobalanced( player, oldTeam, newTeam )
{
	if ( player == GetPendingMarked( oldTeam ) )
	{
		//printt( "Pending marked player auto-balanced" )
		ClearPendingMarkedPlayers()
		MessageToAll( eEventNotifications.MarkedForDeathMarkedAutobalanced )
		level.ent.Signal( "PendingMarkedDisconnected" )
		thread DelayUpdateMarkedPlayers() //Necessary due to timing issues
		return
	}
	else if ( player == GetMarked( oldTeam ) )
	{
		//printt( "Marked player auto-balanced" )
		ClearMarkedPlayers()
		TellClientsMarkedChanged()
		MessageToAll( eEventNotifications.MarkedForDeathMarkedAutobalanced )
	}
	else
	{
		if ( player.GetTeam() == oldTeam )
			MessageToPlayer( player, eEventNotifications.TeammateAutobalanced, null, null )
		else if ( player.GetTeam() == newTeam )
			MessageToPlayer( player, eEventNotifications.EnemyAutobalanced, null, null )
	}

	UpdateMarkedPlayers()
}

function MFD_Pro_ShouldPlayerBeEliminated( player )
{
	if ( !IsPilotEliminationBased() )
		return false

	if ( GetGameState() > eGameState.SuddenDeath )
		return true

	return ArePlayersMarked()
}

function PlayMarkedForDeathProDialogue( team1, team1PlayersAlive, team2, team2PlayersAlive )
{
	if ( level.nv.winningTeam != null )
		return

	local team1Marked = GetMarked( team1 )
	local team2Marked = GetMarked( team2 )

	if ( !IsAlive( team1Marked ) || !IsAlive( team2Marked ) )
		return

	local team1NumPlayersAlive = team1PlayersAlive.len()
	local team2NumPlayersAlive = team2PlayersAlive.len()

	if ( level.lastTeamPilots[ team1 ] != team1NumPlayersAlive )
	{
		if ( team1NumPlayersAlive == 2 )
		{
			foreach ( player in team1PlayersAlive )
			{
				if ( player == team1Marked )
					PlayConversationToPlayer( "MFDPFriendlyPilotsLeftTwoMarkedPlayer", player )
				else
					PlayConversationToPlayer( "MFDPFriendlyPilotsLeftTwo", player )
			}

			PlayConversationToTeam( "MFDPEnemyPilotsLeftTwo", team2 )
		}
		else if ( team1NumPlayersAlive == 1 && team2NumPlayersAlive == 1 )
		{
			PlayConversationToPlayer( "MFDPBothTeamsPilotsLeftOne", team1Marked )
			PlayConversationToPlayer( "MFDPBothTeamsPilotsLeftOne", team2Marked )
		}
		else if ( team1NumPlayersAlive == 1 )
		{
			PlayConversationToPlayer( "YouAreTheLastPilot", team1Marked )
			PlayConversationToTeam( "MFDPEnemyMarkIsAlone", team2 )
		}
	}
}