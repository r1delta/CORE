//********************************************************************************************
//	Lobby
//********************************************************************************************

RegisterSignal( "end_lobby_logic" )
IncludeScript("mp/mp_lobby_dialog")
function main()
{
	file.minTeamSize <- 0
	file.maxTeamSize <- 0

	file.teamMinPlayersTime <- {}
	file.teamMinPlayersTime[TEAM_IMC] <- 0
	file.teamMinPlayersTime[TEAM_MILITIA] <- 0
	file.teamReady <- {}
	file.teamReady[TEAM_IMC] <- false
	file.teamReady[TEAM_MILITIA] <- false

	file.nextMapModeCombo <- {}
	file.nextMapModeCombo.index <- null
	file.nextMapModeCombo.mapName <- null
	file.nextMapModeCombo.modeName <- null

	file.nextLaunchCommandValid <- 0

	Globalize( CodeCallback_OnPrecache )
	Globalize( CodeCallback_OnClientConnectionStarted )
	Globalize( CodeCallback_OnClientConnectionCompleted )
	Globalize( CodeCallback_OnClientDisconnected )
	Globalize( CodeCallback_OnClientSendingPersistenceToNewServer )
	Globalize( CodeCallback_DamagePlayerOrNPC )
	Globalize( CodeCallback_OnPlayerKilled )
	Globalize( CodeCallback_OnPlayerRespawned )
	Globalize( CodeCallback_WeaponFireInCloak )
	Globalize( CodeCallback_OnNPCKilled )
	Globalize( CodeCallback_GamerulesThink )
	Globalize( CodeCallback_GetWeaponDamageSourceId )
	Globalize( CodeCallback_ForceAIMissPlayer )
	Globalize( CodeCallback_ZiplineMount )
	Globalize( CodeCallback_ZiplineStart )
	Globalize( CodeCallback_ZiplineStop )
	Globalize( CodeCallback_OnEntityDestroyed )
	Globalize( CodeCallback_OnTouchHealthKit )
	Globalize( DoTraining )
	Globalize( SelectNextMap )
	Globalize( SetMinPlayers )
	Globalize( GetPartyLeaders )
	Globalize( ClearAllNewItems )
	Globalize( PrintServerGameHistory )

	if ( developer() )
		Globalize( Lobby_PickNextMapModeCombo )

	RegisterSignal( "Disconnected" )
	RegisterSignal( "CountDownTimerStopped" )

	FlagInit( "mm_lobby_logic" )
	FlagInit( "private_lobby_logic" )
	FlagInit( "CountDownTimerStarted" )

	if ( GetDeveloperLevel() > 0 )
	{
		AddClientCommandCallback( "DevLevelToggle", ClientCommand_DevLevelToggle )
		AddClientCommandCallback( "CampaignCheat", ClientCommand_CampaignCheat )
	}
	AddClientCommandCallback( "DoTraining", ClientCommand_DoTraining ) //
	AddClientCommandCallback( "CancelTraining", ClientCommand_CancelTraining ) //
	AddClientCommandCallback( "StartPrivateMatchSearch", ClientCommand_StartPrivateMatchSearch ) //
	AddClientCommandCallback( "StartCoopMatchSearch", ClientCommand_StartCoopMatchSearch ) //
	AddClientCommandCallback( "StartCoopCustomMatchSearch", ClientCommand_StartCoopCustomMatchSearch ) //
	AddClientCommandCallback( "ClickedCoopCustomMatch", ClientCommand_ClickedCoopCustomMatch ) //
	AddClientCommandCallback( "CancelPrivateMatchSearch", ClientCommand_CancelPrivateMatchSearch ) //
	AddClientCommandCallback( "CoopSetIsPrivate", ClientCommand_CoopSetIsPrivate ) //
	AddClientCommandCallback( "SetCustomMap", ClientCommand_SetCustomMap )
	AddClientCommandCallback( "PrivateMatchSetMode", ClientCommand_PrivateMatchSetMode )
	AddClientCommandCallback( "PrivateMatchLaunch", ClientCommand_PrivateMatchLaunch )
	AddClientCommandCallback( "PrivateMatchSwitchTeams", ClientCommand_PrivateMatchSwitchTeams )
	AddClientCommandCallback( "CancelMatchSearch", ClientCommand_CancelMatchSearch ) //
	AddClientCommandCallback( "GenUp", ClientCommand_GenUp ) //
	AddClientCommandCallback( "RegenMenuViewed", ClientCommand_RegenMenuViewed ) //
	AddClientCommandCallback( "RegenChallengesViewed", ClientCommand_RegenChallengesViewed ) //
	AddClientCommandCallback( "DailyChallengesViewed", ClientCommand_DailyChallengesViewed )
	AddClientCommandCallback( "UpdatePrivateMatchSetting", ClientCommand_UpdatePrivateMatchSetting ) //
	AddClientCommandCallback( "ResetMatchSettingsToDefault", ClientCommand_ResetMatchSettingsToDefault )
	AddClientCommandCallback( "NewBlackMarketItemsViewed", ClientCommand_NewBlackMarketItemsViewed )
	AddClientCommandCallback( "RequestServerChangeToLobbyType0", ClientCommand_RequestServerChangeToLobbyType0 )
	AddClientCommandCallback( "TryKickPlayersForPersonalLobby", ClientCommand_TryKickPlayersForPersonalLobby )
	AddCallback_OnClientConnected( Lobby_UpdateLobbyType )

	GameRules.EnableGlobalChat( true )
	IncludeFile("_burncards_shared")
	IncludeFile("masterServer")
	if ( !IsMatchmakingServer() )
	{
		printt( "============================================" )
		printt( "Using matchmaking" )
		printt( "============================================" )

		thread ControlMatchmakingServerLobbyLogic()
	}
	else
	{
		printt( "============================================" )
		printt( "NOT using matchmaking" )
		printt( "============================================" )

		thread LocalServerLobbyLogic()
	}

	thread WatchTeamStates()
}

function CodeCallback_OnPrecache()
{
}

function CodeCallback_OnClientConnectionStarted( player )
{
	player.s = {}
	player.s.clientScriptInitialized <- false

	if ( "ScriptCallback_OnClientConnecting" in getroottable() )
		ScriptCallback_OnClientConnecting( player )

	if ( !IsLobby() )
		AddTrackRef( player )

	printl( "!!! Player connect started: " + player.GetPlayerName() + " | " + player )

	local results = {}
	results.player <- player
	level.ent.Signal( "PlayerDidSpawn", results )

	//const MIN_BURN_CARDS = 4
	//for ( local totalBurnCards = GetPlayerBurnCardsTotal( player ); totalBurnCards < MIN_BURN_CARDS; totalBurnCards++ )
	//{
	//	GiveRandomBurnCardToPlayer( player )
	//}

	local playJoinSound = Time() > 10
	local playerEHandle = player.GetEncodedEHandle()
	local players = GetPlayerArray()

	foreach ( ent in players )
	{
		if ( ent != player )
		{
			Remote.CallFunction_UI( ent, "SCBUI_PlayerConnectedOrDisconnected", playJoinSound )
		}
	}
}

function UpdateBurnCardSet( player, setIndex )
{
	if ( !PlayerFullyConnected( player ) )
		return

	if ( !UsingAlternateBurnCardPersistence() )
		return

	local deck = GetBurnCardSetForIndex( setIndex )
	for ( local slotID = 0; slotID < INGAME_BURN_CARDS; slotID++ )
	{
		local cardRef = deck.len() ? deck.remove( 0 ) : null
		SetPlayerActiveBurnCardSlotContents( player, slotID, cardRef, false )
	}

	local pmDeck = []
	foreach ( cardRef in deck )
	{
		pmDeck.append( { cardRef = cardRef, new = false } )
	}
	FillBurnCardDeckFromArray( player, pmDeck )

	ChangedPlayerBurnCards( player )
}
Globalize( UpdateBurnCardSet )


function InitBurnCards( player )
{
	if ( !UsingAlternateBurnCardPersistence() )
		return

	local pmDeck = [
		{ cardRef = "bc_minimap", new = false }
		{ cardRef = "bc_r97_m2", new = false }
		{ cardRef = "bc_pilot_warning", new = false }
		{ cardRef = "bc_free_build_time_1", new = false }
		{ cardRef = "bc_double_agent", new = false }
		{ cardRef = "bc_titan_melee_m2", new = false}
	]

	FillBurnCardDeckFromArray( player, pmDeck )

	for ( local slotID = 0; slotID < INGAME_BURN_CARDS; slotID++ )
	{
		SetPlayerActiveBurnCardSlotContents( player, slotID, null, false )
	}

	local players = GetPlayerArray()

	UpdateBurnCardSet( player, GetCurrentPlaylistVarInt( "burn_cards_set", 0 ) )
}
Globalize(InitBurnCards)

function CodeCallback_OnClientConnectionCompleted( player )
{
	printl( "!!! Player connect complete: " + player.GetPlayerName() + " | " + player )

	player.SetPlayerSettings("lobby_view")

	InitPersistentData( player )
	InitPlayerStats( player )
	InitPlayerChallenges( player )
	InitBurnCards( player )
	UpdatePlayerDecalUnlocks( player, false )
	Ranked_PlayerConnected( player )
	ValidateCustomLoadouts( player )
	SaveDateLoggedIn( player )

	// set this persistent var if you are in mm debug mode, so you can see leagues.
	player.SetPersistentVar( "ranked.debugMM", player.GetMMDbgFlags() > 0 )

	FinishClientScriptInitialization( player )

	player.FreezeControlsOnServer( true )
	player.hasConnected = true

	BurnCard_RefreshPlayer( player )

	UpdateBadRepPresent()

	if ( IsPrivateMatch() )
	{
		UpdatePrivateMatchMapIfUnavailable()
	}

	if ( GetLobbyType() == "party" )
		UpdateCustomMatchMapIfUnavailable()

	if ( GetCurrentPlaylistVarInt( "lobby_campaign_scene", 0 ) == 1 )
		thread PlayCampaignLobbyScene( player )

	if ( !GetTrainingHasEverBeenStarted( player ) && IsMatchmakingServer() )
	{
		Remote.CallFunction_UI( player, "ServerCallback_DoTraining" )
	}

	// should make onclientconnection completed callback work on lobby too
	BurnCard_PlayerConnected( player )
	BlackMarket_PlayerConnected( player )

	// force these angles because client can have incorrect angles, depending on their view when they left previous map
	player.SetOrigin( Vector(0,0,0) )
	player.SetAngles( Vector(0,0,0) )

	foreach ( callbackInfo in level.onClientConnectedCallbacks )
	{
		callbackInfo.func.acall( [callbackInfo.scope, player] )
	}
}

function CodeCallback_OnClientSendingPersistenceToNewServer( player )
{
	printt( "lobby CodeCallback_OnClientSendingPersistenceToNewServer():", player.GetPlayerName() )
}

function CodeCallback_OnClientDisconnected( player )
{
	player.Signal( "Disconnected" )
	UpdateBadRepPresent()
}

function CodeCallback_DamagePlayerOrNPC( ent, damageInfo )
{
}

function CodeCallback_OnPlayerKilled( player, damageInfo )
{
}

function CodeCallback_OnPlayerRespawned( player )
{
}

function CodeCallback_OnNPCKilled( npc, damageInfo )
{

}

function CodeCallback_WeaponFireInCloak( player )
{
}

function CodeCallback_GamerulesThink()
{
}

function CodeCallback_GetWeaponDamageSourceId( weapon )
{
}

function CodeCallback_ForceAIMissPlayer( npc, player )
{
}

function CodeCallback_ZiplineMount( player, zipline )
{
}

function CodeCallback_ZiplineStart( player, zipline )
{
}

function CodeCallback_ZiplineStop( player )
{
}

function CodeCallback_OnEntityDestroyed( entity )
{
}

function CodeCallback_OnTouchHealthKit( player, flag )
{
}

// This server will recieve this command from the client once they have loaded/run all of their scripts
// Any client hud initialization should be done here
function FinishClientScriptInitialization( player )
{
	player.s.clientScriptInitialized = true

	SyncServerVars( player )
	SyncEntityVars( player )
	SyncUIVars( player )

	Remote.CallFunction_Replay( player, "ServerCallback_ClientInitComplete" )

	return true
}


//
function MonitorClientMatchmakingConvar()
{
	printl( "!!! MonitorClientMatchmakingConvar() started" )

	local matchingPlayer = null

	for ( ;; )
	{
		if ( GetLobbyType() != "party" )
		{
			matchingPlayer = null
			wait 1
			continue
		}

		if ( matchingPlayer != null )
		{
			if ( IsValid( matchingPlayer ) )
			{
				if ( !matchingPlayer.WantsMatchmaking() )
				{
					printt( "MonitorClientMatchmakingConvar() - stopping search for player:", matchingPlayer.GetPlayerName() )
					AbortMatchSearchesForPlayer( matchingPlayer )
					matchingPlayer = null
				}
			}
			else
			{
					printt( "MonitorClientMatchmakingConvar() - player ent is no longer valid." )
					matchingPlayer = null
			}
		}

		if ( matchingPlayer == null )
		{
			local players = GetPlayerArray()
			foreach ( player in players )
			{
				if ( player.WantsMatchmaking() )
				{
					printt( "MonitorClientMatchmakingConvar() - beginning match search for player:", player.GetPlayerName() )
					SendAllPlayersToMatchmaking()
					matchingPlayer = player
					break
				}
			}
		}

		wait 0
	}
}

function ControlMatchmakingServerLobbyLogic()
{
	OnThreadEnd(
		function()
		{
			printl( "!!! ControlMatchmakingServerLobbyLogic ended" )
		}
	)

	printl( "!!! ControlMatchmakingServerLobbyLogic started" )

	thread MonitorClientMatchmakingConvar()

	local prev_shouldDoLobbyLogic = false
	local shouldDoLobbyLogic

	while ( 1 )
	{
		shouldDoLobbyLogic = GetPlayerArray().len() > 0

		if ( shouldDoLobbyLogic != prev_shouldDoLobbyLogic )
		{
			if ( shouldDoLobbyLogic )
			{
				if ( IsPrivateMatch() )
					thread PrivateMatchLobbyLogic()
				else if ( IsCoopMatch() )
					thread CoopMatchLobbyLogic()
				else
					thread MatchmakingServerLobbyLogic()
			}
			else
			{
				level.ent.Signal( "end_lobby_logic" )
			}

			prev_shouldDoLobbyLogic = shouldDoLobbyLogic
		}

		wait 0
	}
}

function PrivateMatchLobbyLogic()
{
	OnThreadEnd(
		function()
		{
			FlagClear( "private_lobby_logic" )
			printl( "!!! Privatematch lobby logic ended" )
		}
	)

	if ( Flag( "private_lobby_logic" ) )
		return

	FlagSet( "private_lobby_logic" )

	level.ent.EndSignal( "end_lobby_logic" )

	SetPlaylistVarOverride( "private_match", "1" )

	printl( "!!! Privatematch lobby logic started" )

	file.teamReady[TEAM_IMC] = false
	file.teamReady[TEAM_MILITIA] = false

	MarkTeamsAsBalanced_On()

	thread UpdateTeamReadyStatus()

	local players
	local timeRemaining
	local tickTime
	local lastTickTime

	local mapName = GetLastServerMap()
	if ( (mapName in getconsttable().ePrivateMatchMaps) )
		level.ui.privatematch_map = getconsttable().ePrivateMatchMaps[mapName]

	local modeName = GetLastServerGameMode()

	// I don't like ctf
    if (modeName == null)
		modeName = "at"

	if ( (modeName in getconsttable().ePrivateMatchModes) )
		level.ui.privatematch_mode = getconsttable().ePrivateMatchModes[modeName]

	mapName = GetMapNameForEnum( level.ui.privatematch_map )
	modeName = GetModeNameForEnum( level.ui.privatematch_mode )

	for ( ;; )
	{
		WaitEndFrame() // allow the thread that is updating file.teamReady to do it's updates

		if ( level.ui.privatematch_starting == ePrivateMatchStartState.STARTING && level.ui && file.teamReady[TEAM_IMC] && file.teamReady[TEAM_MILITIA] && mapName && modeName )
		{
			if ( level.ui.gameStartTime == null )
			{
                printt("Starting countdown!")
				StartCountDown()
				RefreshPlayerSkillRatings()
			}

			timeRemaining = level.ui.gameStartTime - Time()

			if ( timeRemaining <= 10 && timeRemaining > -0.5 )
			{
				tickTime = ceil( timeRemaining )

				if ( tickTime != lastTickTime )
				{
					players = GetPlayerArray()
					foreach ( player in players )
						EmitSoundAtPositionOnlyToPlayer( Vector(0, 0, 0), player, PREMATCH_COUNTDOWN_SOUND )

					lastTickTime = tickTime
				}
			}

			if ( Time() > level.ui.gameStartTime )
			{
				if ( Time() > level.ui.gameStartTime + 1.5 )
					level.ui.gameStartTimerComplete = true

				break
			}
		}
		else
		{
			if ( level.ui.gameStartTime != null )
				StopCountDown()

			mapName = GetMapNameForEnum( level.ui.privatematch_map )
			modeName = GetModeNameForEnum( level.ui.privatematch_mode )
		}

		wait 0
	}

	printt( "Launch it!" )
	if (modeName == "campaign_carousel") {
		// we need to get gamemode, mv does not want to hardcode maps and gamemodes here so we're grabbing off playlist
		local gamemodeForMap = null
		for (local i = 0; i < GetMapCountForPlaylist(modeName); i++) {
			if (GetPlaylistMapByIndex(modeName, i) == mapName)
				gamemodeForMap = GetPlaylistGamemodeByIndex(modeName, i)
		}
		ServerCommand( "playlist " + modeName )
		ServerCommand( "mp_gamemode " + gamemodeForMap )
		ServerCommand( "changelevel " + mapName )
	} else {
		GameRules_ChangeMap( mapName, modeName )
	}
}


function MatchmakingServerLobbyLogic()
{
    OnThreadEnd(
        function()
        {
            FlagClear( "mm_lobby_logic" )
            printl( "!!! Matchmaking server lobby logic ended" )
        }
    )

    if ( Flag( "mm_lobby_logic" ) )
        return
    FlagSet( "mm_lobby_logic" )

    level.ent.EndSignal( "end_lobby_logic" )

    printl( "!!! Matchmaking server lobby logic started" )

    SetPlaylistVarOverride( "private_match", "0" )

    file.teamReady[TEAM_IMC] = true
    file.teamReady[TEAM_MILITIA] = true

    local players
    local timeRemaining
    local tickTime
    local lastTickTime
    local needSkillBalance = true

    for ( ;; )
    {
        local report_timeRemaining = -1

        if ( ReadyToStart() )
        {
            if ( file.nextMapModeCombo.index == null )
            {
                SelectNextMap()
            }
            else
            {
                if ( level.ui.gameStartTime == null )
                {
                    StartCountDown()
                    RefreshPlayerSkillRatings()
                }

                timeRemaining = level.ui.gameStartTime - Time()
                report_timeRemaining = timeRemaining

                if ( GetConVarBool("delta_autoBalanceTeams") && needSkillBalance && (timeRemaining <= 10) )
                {
                    // Add autobalancing logic here, just before marking teams as balanced
                    local players = GetPlayerArray()
                    if ( GetCurrentPlaylistName() == "COOPERATIVE" )
                    {
                        // In cooperative, put everyone on TEAM_MILITIA
                        foreach ( p in players )
                            p.SetTeam( TEAM_MILITIA )
                    }
                    else
                    {
                        local imcPlayers = []
                        local militiaPlayers = []

                        foreach ( p in players )
                        {
                            if ( p.GetTeam() == TEAM_IMC )
                                imcPlayers.append(p)
                            else if ( p.GetTeam() == TEAM_MILITIA )
                                militiaPlayers.append(p)
                        }

                        local totalPlayers = players.len()
                        local targetPerTeam = ceil(totalPlayers / 2.0)

                        if ( imcPlayers.len() > militiaPlayers.len() )
                        {
                            local playersToMove = imcPlayers.len() - targetPerTeam
                            for ( local i = 0; i < playersToMove; i++ )
                            {
                                if ( imcPlayers.len() > 0 )
                                    imcPlayers[i].TrueTeamSwitch()
                            }
                        }
                        else if ( militiaPlayers.len() > imcPlayers.len() )
                        {
                            local playersToMove = militiaPlayers.len() - targetPerTeam
                            for ( local i = 0; i < playersToMove; i++ )
                            {
                                if ( militiaPlayers.len() > 0 )
                                    militiaPlayers[i].TrueTeamSwitch()
                            }
                        }
                    }


                    MarkTeamsAsBalanced_On()
                    needSkillBalance = false
                }

                if ( timeRemaining <= 10 && timeRemaining > -0.5 )
                {
                    tickTime = ceil( timeRemaining )

                    if ( tickTime != lastTickTime )
                    {
                        players = GetPlayerArray()
                        foreach ( player in players )
                            EmitSoundAtPositionOnlyToPlayer( Vector(0, 0, 0), player, PREMATCH_COUNTDOWN_SOUND )

                        lastTickTime = tickTime
                    }
                }

                if ( Time() > level.ui.gameStartTime )
                {
                    if ( Matchmaking_MayProceedToGame() )
                        break

                    if ( Time() > level.ui.gameStartTime + 1.5 )
                        level.ui.gameStartTimerComplete = true
                }
            }
        }
        else
        {
            if ( level.ui.gameStartTime != null )
                StopCountDown()

            needSkillBalance = true
            MarkTeamsAsBalanced_Off()
        }

        local nextMapName = file.nextMapModeCombo.mapName
        if ( nextMapName == null )
            nextMapName = ""
        NoteLobbyState( report_timeRemaining, nextMapName )
        wait 0
    }

    NoteLobbyState( 0, "" )
    GameRules_ChangeMap( file.nextMapModeCombo.mapName, file.nextMapModeCombo.modeName )
}

function ChooseCoopMap()
{
	printt( "CHOOSE COOP MAP" )
	// If any of the players hasn't played before, choose one of the 3 "newbie" maps, Lagoon, Overlook, Relic
	local playerArray = GetPlayerArray()
	local gameHasNewbie = false
	//foreach ( player in playerArray )
	//{
	//	local gamesPlayed =	player.GetPersistentVar( "gamestats.modesplayed[coop]" )
	//	if ( gamesPlayed == 0 )
	//		gameHasNewbie = true
	//}

	local allowedMaps = null
	if ( gameHasNewbie == true && GetCurrentPlaylistVarInt( "coop_newPlayerMapLimitEnabled", 1 ) )
		allowedMaps = [ "mp_lagoon", "mp_overlook", "mp_relic" ]

	local combo = Lobby_PickNextMapModeCombo( allowedMaps )

	if ( gameHasNewbie == true )
		printt( "Choosing new player coop map:", combo.mapName )
	else
		printt( "Choosing random coop map:", combo.mapName )

	return { mapName = getconsttable().ePrivateMatchMaps[ combo.mapName ] , index = combo.index }
}

function CoopMatchLobbyLogic()
{
	OnThreadEnd(
		function()
		{
			FlagClear( "mm_lobby_logic" )
			printl( "!!! Coop lobby logic ended" )
		}
	)
	if ( Flag( "mm_lobby_logic" ) )
		return
	FlagSet( "mm_lobby_logic" )
	level.ent.EndSignal( "end_lobby_logic" )
	printl( "!!! Coop lobby logic started" )
	///////////////////

	SetPlaylistVarOverride( "private_match", "0" )

	file.teamReady[TEAM_IMC] = false
	file.teamReady[TEAM_MILITIA] = false

	thread UpdateTeamReadyStatus()

	local lastTickTime

	local everStartedACountdown = false

	for ( ;; )
	{
		local report_timeRemaining = -1

		local requestedMap = ""
		if ( requestedMap != "" && level.ui.coopLobbyMap == null )
		{
			printt( "Forcing to requested coop map:", requestedMap )
			local mapIndex = getconsttable().ePrivateMatchMaps[requestedMap]
			level.ui.coopLobbyMap = mapIndex
			level.ui.nextMapModeComboIndex = mapIndex
		}

		local notWaitingForPossibleMapRequest = (Matchmaking_MayProceedToGame() || (level.ui.coopLobbyMap != null))
		if ( (ReadyToStart() && notWaitingForPossibleMapRequest) || IsClosedMatch() )
		{
			if ( level.ui.coopLobbyMap == null )
			{
				local coopMapTable = ChooseCoopMap()
				level.ui.coopLobbyMap = coopMapTable.mapName
				level.ui.nextMapModeComboIndex = coopMapTable.index
			}
			else
			{
				if ( level.ui.gameStartTime == null )
				{
					StartCountDown()
					everStartedACountdown = true
				}

				local timeRemaining = level.ui.gameStartTime - Time()
				report_timeRemaining = timeRemaining

				if ( (timeRemaining <= 10) && (timeRemaining > -0.5) )
				{
					local tickTime = ceil( timeRemaining )
					if ( tickTime != lastTickTime )
					{
						local players = GetPlayerArray()
						foreach ( player in players )
							EmitSoundAtPositionOnlyToPlayer( Vector(0, 0, 0), player, PREMATCH_COUNTDOWN_SOUND )

						lastTickTime = tickTime
					}
				}

				if ( Time() > level.ui.gameStartTime )
				{
					if ( Matchmaking_MayProceedToGame() )
						break

					if ( Time() > level.ui.gameStartTime + 1.5 )
						level.ui.gameStartTimerComplete = true
				}
			}
		}
		else
		{
			if ( level.ui.gameStartTime != null )
				StopCountDown()

			if ( !everStartedACountdown && (requestedMap == "") && (level.ui.coopLobbyMap != null) )
				level.ui.coopLobbyMap = null
		}

		local nextMapName = ""
		if ( level.ui.coopLobbyMap != null )
			nextMapName = GetMapNameForEnum( level.ui.coopLobbyMap )
		NoteLobbyState( report_timeRemaining, nextMapName )
		wait 0
	}

	Assert( level.ui.coopLobbyMap != null )
	local mapName = GetMapNameForEnum( level.ui.coopLobbyMap )
	NoteLobbyState( 0, "" )
	GameRules_ChangeMap( mapName, "coop" )
}

function UpdatePrivateMatchReadyStatus( cancelStart = false )
{
	if ( !file.teamReady[TEAM_IMC] || !file.teamReady[TEAM_MILITIA] )
	{
		level.ui.privatematch_starting = ePrivateMatchStartState.NOT_READY
		return
	}

	if ( !cancelStart && level.ui.privatematch_starting == ePrivateMatchStartState.STARTING )
		return

	if ( file.teamReady[TEAM_IMC] && file.teamReady[TEAM_MILITIA] )
		level.ui.privatematch_starting = ePrivateMatchStartState.READY
}


function IsAnyPlayerMMDebug()
{
	local players = GetPlayerArray()
	foreach ( player in players )
	{
		if ( player.GetMMDbgFlags() > 0 )
			return true;
	}

	return false;
}


function UpdateTeamReadyStatus()
{
	OnThreadEnd(
		function()
		{
			printt( "UpdateTeamReadyStatus OnThreadEnd: all teamReady to false" )
			file.teamReady[TEAM_IMC] = false
			file.teamReady[TEAM_MILITIA] = false

			printl( "!!! UpdateTeamReadyStatus ended" )
		}
	)

	level.ent.EndSignal( "end_lobby_logic" )

	printl( "!!! UpdateTeamReadyStatus started" )

	local teams = [ TEAM_IMC, TEAM_MILITIA ]
	local minPlayers = GetCurrentPlaylistVarInt( "min_players", 2 )
	local minPlayersDecayRate = GetCurrentPlaylistVarFloat( "min_players_decayrate", 10 )
	local maxPlayers = GetCurrentPlaylistVarInt( "max players", 12 )

	if ( minPlayers > maxPlayers )
		minPlayers = maxPlayers

	if ( IsCoopMatch() )
	{
		file.minTeamSize = minPlayers
		file.maxTeamSize = maxPlayers
	}
	else
	{
		file.minTeamSize = minPlayers / 2
		file.maxTeamSize = maxPlayers / 2
	}

	for ( ;; )
	{
		foreach ( team in teams )
		{
			local playerCount = GetTeamPlayerCount( team )

			if ( IsPrivateMatch() )
			{
				if ( IsAnyPlayerMMDebug() || GetConVarBool( "developer" ) )
					file.teamReady[team] = true
				else if ( (playerCount > file.maxTeamSize) || (playerCount < 1) || ((GetTeamPlayerCount( TEAM_IMC ) + GetTeamPlayerCount( TEAM_MILITIA )) < minPlayers) )
					// Be able to start the private match solo for now (probably forever)
					file.teamReady[team] = false
				else
					file.teamReady[team] = true
				file.teamReady[team] = true
			}
			else
			{
				if ( (playerCount < file.minTeamSize) || (playerCount > file.maxTeamSize) )
				{
					file.teamReady[team] = false
					if ( playerCount == 0 )
						file.teamMinPlayersTime[team] = 0
				}
				else
				{
					if ( file.teamMinPlayersTime[team] == 0 )
						file.teamMinPlayersTime[team] = Time()

					if ( minPlayersDecayRate <= 0 )
					{
						file.teamReady[team] = true
					}
					else
					{
						// Hold out for max players, gradually relax to min players:
						local timeElapsed = (Time() - file.teamMinPlayersTime[team])
						local minPlayers = (file.maxTeamSize - floor( timeElapsed / minPlayersDecayRate ))
						if ( minPlayers < file.minTeamSize )
							minPlayers = file.minTeamSize

						if ( playerCount >= minPlayers )
							file.teamReady[team] = true
						else
							file.teamReady[team] = false
					}
				}
			}
		}

		if ( IsPrivateMatch() )
			UpdatePrivateMatchReadyStatus()

		wait 0
	}
}

// for debugging
function SetMinPlayers( num )
{
	file.minTeamSize = num
}

function UpdateTeamStates()
{
	local imcPlayers = GetTeamPlayerCount( TEAM_IMC )
	local milPlayers = GetTeamPlayerCount( TEAM_MILITIA )

	local anyoneHere = (imcPlayers > 0 || milPlayers > 0)
	local bothTeamsHere = (imcPlayers > 0 && milPlayers > 0)

	if ( anyoneHere && !file.anyoneHere )
		file.lobbyStartTime = Time()

	if ( bothTeamsHere && !file.bothTeamsHere )
		file.hadBothTeamsTime = Time()

	file.anyoneHere = anyoneHere
	file.bothTeamsHere = bothTeamsHere
}

function WatchTeamStates()
{
	file.anyoneHere <- false
	file.bothTeamsHere <- false

	file.lobbyStartTime <- Time()
	file.hadBothTeamsTime <- Time()

	for ( ;; )
	{
		UpdateTeamStates()
		wait 0.5
	}
}

function StopCountDown()
{
	level.ent.Signal( "CountDownTimerStopped" )

	level.ui.gameStartTime = null
	level.ui.gameStartTimerComplete = false

	FlagClear( "CountDownTimerStarted" )
	AllPlayersUnMuteAll( 4.0 )
}

function ready()
{
	// dev command to start the server
	local time = Time() + 30
	SetUIVar( "gameStartTime", time )
}
Globalize( ready )

function StartCountDown()
{
	local countdownDefault = GetCurrentPlaylistVarInt( "lobby_countdown", 60 )

	if( GetConVarBool( "developer" ) )
		countdownDefault = 5

	if ( IsPrivateMatch() || IsCoopMatch() )
	{
		level.ui.gameStartTime = Time() + countdownDefault
	}
	else
	{
		UpdateTeamStates()
		local endTime = (file.hadBothTeamsTime + countdownDefault)
		printt("StartCountDown: endTime = " + endTime)
		local countdownMin = GetCurrentPlaylistVarInt( "lobby_countdown_min", 30 )
		local delta = (endTime - Time())
		if ( delta < countdownMin )
			endTime = (Time() + countdownMin)

		level.ui.gameStartTime = endTime
	}

	level.ui.gameStartTimerComplete = false

	FlagSet( "CountDownTimerStarted" )

	local fadeTime = MUTEALLFADEIN
	local delay = (level.ui.gameStartTime - Time()) - fadeTime

	thread MuteAllOnExitLobby( delay, fadeTime )
}

function MuteAllOnExitLobby( delay, fadeTime )
{
	level.ent.EndSignal( "CountDownTimerStopped" )

	wait delay

	AllPlayersMuteAll( fadeTime )
}

function LocalServerLobbyLogic()
{
	Assert( !IsMatchmakingServer() )
	printt("Using local server logic")
	file.teamReady[TEAM_IMC] = false
	file.teamReady[TEAM_MILITIA] = false

	thread UpdateTeamReadyStatus()

	local players
	local timeRemaining
	local tickTime
	local lastTickTime
	local needSkillBalance = true

	for ( ;; )
	{
		if ( ReadyToStart() )
		{
			if ( file.nextMapModeCombo.index == null )
			{
				SelectNextMap()
			}
			else
			{
				if ( level.ui.gameStartTime == null )
					StartCountDown()

				timeRemaining = level.ui.gameStartTime - Time()

				if ( needSkillBalance && (timeRemaining <= 10) )
				{
					MarkTeamsAsBalanced_On()
					needSkillBalance = false
				}

				if ( timeRemaining <= 10 )
				{
					tickTime = ceil( timeRemaining )

					if ( tickTime != lastTickTime )
					{
						players = GetPlayerArray()
						foreach ( player in players )
							EmitSoundAtPositionOnlyToPlayer( Vector(0, 0, 0), player, PREMATCH_COUNTDOWN_SOUND )

						lastTickTime = tickTime
					}
				}

				if ( Time() > level.ui.gameStartTime )
					break
			}
		}
		else
		{
			if ( level.ui.gameStartTime != null )
				StopCountDown()

			if ( GetCinematicMode() )
				MarkTeamsAsBalanced_On()
			else
				MarkTeamsAsBalanced_Off()
		}

		wait 0
	}

	if ( GetCurrentPlaylistVarInt( "local_autostart", 1 ) )
		GameRules_ChangeMap( file.nextMapModeCombo.mapName, file.nextMapModeCombo.modeName )
}

function PrintServerGameHistory()
{
	printt( "==============================================" )
	printt( "Server Game History" )

	local mapHistoryCount = GetServerMapHistory().len()
	local modeHistoryCount = GetServerModeHistory().len()

	local mapHistory
	if ( IsNextGameTest() )
		mapHistory = clone level.recentMaps
	else
		mapHistory = GetServerMapHistory( mapHistoryCount )

	mapHistory.reverse()
	PrintTable( mapHistory )

	local modeHistory
	if ( IsNextGameTest() )
		modeHistory = clone level.recentModes
	else
		modeHistory = GetServerModeHistory( modeHistoryCount )

	modeHistory.reverse()
	PrintTable( modeHistory )
}

function GetRecentMapModeCombo()
{
	return { map = GetConVarString("host_mostRecentMap"), mode = GetConVarString("mp_gamemode") }
}

function GetNextComboInOrder()
{
	local playlist = GetCurrentPlaylistName()
	local count = GetMapCountForCurrentPlaylist()

	if ( count <= 0 )
		return

	local currentCombo = GetRecentMapModeCombo()
	print(currentCombo.map + " " + currentCombo.mode)
	local mode
	local mapIndex = 0
	for ( local index = 0; index < count; index++ )
	{
		local map = GetCurrentPlaylistMapByIndex( index )
		local mode = GetCurrentPlaylistGamemodeByIndex( index )
		if ( map == currentCombo.map && mode == currentCombo.mode )
		{
			mapIndex = index + 1
			break
		}
	}

	mapIndex %= count

	local map = GetCurrentPlaylistMapByIndex( mapIndex )
	local mode = GetCurrentPlaylistGamemodeByIndex( mapIndex )

	printt( "Selecting next local playtest combo. Picked " + map + ", " + mode )
	return { mapName = map, modeName = mode, index = mapIndex }
}

function Lobby_PickNextMapModeCombo( allowedMaps = null )
{
	if ( GetCurrentPlaylistVarInt( "play_in_order", 0 ) )
	{
		return GetNextComboInOrder()
	}

	local playlist = GetCurrentPlaylistName()

	//printt( "==============================================" )
	//printt( "Current Playlist:", playlist )
	//printt( "Maps:" )
	//PrintTable( GetPlaylistUniqueMaps( playlist ) )
	//printt( "Modes:" )
	//PrintTable( GetPlaylistUniqueModes( playlist ) )

	local allCombos = GetPlaylistCombos( playlist )
	Assert( allCombos.len() != 0, "No maps found in playlist!" )

	local availableCombos = DLCFilterCombos( allCombos )
	Assert( availableCombos.len() != 0, "No maps available after DLC filter!" )

	local availableMaps = DLCFilterMaps( GetPlaylistUniqueMaps( playlist ) )
	local availableModes = GetPlaylistUniqueModes( playlist )

	//printt( "==============================================" )
	//printt( "Available Maps:" )
	//PrintTable( availableMaps )

	local players = GetPlayerArray()
	local mapHistories = []
	local modeHistories = []

	foreach ( player in players )
	{
		mapHistories.append( GetPlayerMapHistory( player ) )
		modeHistories.append( GetPlayerModeHistory( player ) )
	}

	local numMapsToAvoid = floor( availableMaps.len() * 0.5 ) // Avoid recent maps up to half available size. This avoids very short and very long replay stretches.
	if ( numMapsToAvoid <= 0 )
		numMapsToAvoid = 1

	if ( allowedMaps != null )
		numMapsToAvoid = max( 1, floor( allowedMaps.len() * 0.5 ) )

	local numModesToAvoid = floor( availableModes.len() * 0.5 ) // Avoid recent modes up to half available size. This avoids very short and very long replay stretches.
	if ( numModesToAvoid <= 0 )
		numModesToAvoid = 1

	local selectionPool = []
	local avoidScore = 1000
	local highestScore = 0

	foreach ( combo in availableCombos )
	{
		combo.score <- 0

		foreach ( mapHistory in mapHistories )
		{
			for ( local i = 0; i < mapHistory.len(); i++ )
			{
				if ( mapHistory[i] != combo.mapName )
					continue

				if ( i < numMapsToAvoid )
					combo.score += avoidScore
				else
					combo.score++
			}
		}

		foreach ( modeHistory in modeHistories )
		{
			for ( local i = 0; i < modeHistory.len(); i++ )
			{
				if ( modeHistory[i] != combo.modeName )
					continue

				if ( i < numModesToAvoid )
					combo.score += avoidScore
				else
					combo.score++
			}
		}

		if ( allowedMaps != null && !ArrayContains( allowedMaps, combo.mapName ) )
			continue	// don't add to the selectionPool if the map isn't in the allowedMaps array

		selectionPool.append( combo )

		if ( combo.score > highestScore )
			highestScore = combo.score
	}

	local bestScore = highestScore

	foreach ( combo in selectionPool )
	{
		if ( combo.score < bestScore )
			bestScore = combo.score
	}

	//PrintTable( selectionPool )

	for ( local i = 0; i < selectionPool.len(); )
	{
		if ( selectionPool[i].score != bestScore )
		{
			selectionPool.remove( i )
			continue // don't increment i
		}

		i++
	}

	//printt( "==============================================" )
	//printt( "selectionPool" )
	//PrintTable( selectionPool )

	local nextCombo = Random( selectionPool )

	printt( "==============================================" )
	printt( "Next Game Map/Mode" )
	PrintTable( nextCombo )

	if ( IsNextGameTest() )
	{
		foreach ( player in players )
		{
			UpdatePlayerMapHistory( player, nextCombo.mapName )
			UpdatePlayerModeHistory( player, nextCombo.modeName )
		}

		level.recentMaps.insert( 0, nextCombo.mapName )
		while ( level.recentMaps.len() > MAX_GAME_HISTORY ) // Match code limit
			level.recentMaps.pop()

		level.recentModes.insert( 0, nextCombo.modeName )
		while ( level.recentModes.len() > MAX_GAME_HISTORY ) // Match code limit
			level.recentModes.pop()
	}

	return nextCombo
}

function SelectNextMap()
{
	if ( IsMatchmakingServer() && !IsCoopMatch() )
	{
		if ( !file.teamReady[TEAM_IMC] || !file.teamReady[TEAM_MILITIA] )
			return
	}

	printt( "Selecting next map" )
	if ( GetCinematicMode() )
		file.nextMapModeCombo = GetNextComboInOrder()
	else
		file.nextMapModeCombo = Lobby_PickNextMapModeCombo()

	level.ui.nextMapModeComboIndex = file.nextMapModeCombo.index
	printt( "SelectNextMap(), level.ui.nextMapModeComboIndex =", level.ui.nextMapModeComboIndex )
	printt( "Next map: " + file.nextMapModeCombo.mapName )
}

function ClearNextMap()
{
	file.nextMapModeCombo.index = null
	file.nextMapModeCombo.mapName = null
	file.nextMapModeCombo.modeName = null

	level.ui.nextMapModeComboIndex = file.nextMapModeCombo.index
	printt( "ClearNextMap(), level.ui.nextMapModeComboIndex =", level.ui.nextMapModeComboIndex )
	printt( "Next map cleared" )
}

function PlayCampaignLobbyScene( player )
{
	Assert( IsValid( player ) )
	Assert( IsPlayer( player ) )

	player.EndSignal( "Disconnected" )

	while( 1 )
	{
		FlagWait( "CountDownTimerStarted" )

		if ( !GetCinematicMode() )
			return

		local timeCountDown = level.ui.gameStartTime - Time()
		local delay = timeCountDown - 73 // 63 seconds for lobby VO, 10 seconds for breathing room at the end.
		if ( delay < 0 )
			delay = 0

		if ( delay )
			wait delay // give the lobby some breathing room

		if ( !Flag( "CountDownTimerStarted" ) )
			continue

		local nextMap = file.nextMapModeCombo.mapName
		Assert( nextMap )

		local timeLeft = level.ui.gameStartTime - Time()
		PlayLobbyScene( player, nextMap, timeLeft )

		FlagWaitClear( "CountDownTimerStarted" )
	}
}

function ClientCommand_DevLevelToggle( player, team, level )
{
	if ( developer() == 0 )
		return true

	team = team.tointeger()
	level = level.tointeger()

	printt( "hi " + team + " " + level + " : " + type( level ) )
	if ( team == 0 )
	{
		local value = player.GetPersistentVar( "campaignMapFinishedIMC[" + level + "]" )
		value = !value
		player.SetPersistentVar( "campaignMapFinishedIMC[" + level + "]", value )
		if ( value )
			player.SetPersistentVar( "desiredCampaignMapIndex[0]", (level + 1) % CAMPAIGN_LEVEL_COUNT )
	}
	else
	{
		local value = player.GetPersistentVar( "campaignMapFinishedMCOR[" + level + "]" )
		value = !value
		player.SetPersistentVar( "campaignMapFinishedMCOR[" + level + "]", value )
		if ( value )
			player.SetPersistentVar( "desiredCampaignMapIndex[1]", (level + 1) % CAMPAIGN_LEVEL_COUNT )
	}

	return true
}

function ClientCommand_CampaignCheat( player, cheatStr )
{
	if ( developer() == 0 )
		return true

	if ( cheatStr == "imc" )
	{
		printt( "Player " + player + " cheating to IMC" )
		player.SetPersistentVar( "campaignTeam", TEAM_IMC )
		return true
	}
	else if ( cheatStr == "militia" )
	{
		printt( "Player " + player + " cheating to Militia" )
		player.SetPersistentVar( "campaignTeam", TEAM_MILITIA )
		return true
	}

	local cheatToLevel = cheatStr.tointeger()

	printt( "Player " + player + " cheating to level " + cheatToLevel )

	for ( local level = 0; level < CAMPAIGN_LEVEL_COUNT; level++ )
	{
		player.SetPersistentVar( "campaignMapFinishedIMC[" + level + "]", level < cheatToLevel )
		player.SetPersistentVar( "campaignMapFinishedMCOR[" + level + "]", level < cheatToLevel )
	}
	player.SetPersistentVar( "desiredCampaignMapIndex[0]", cheatToLevel % CAMPAIGN_LEVEL_COUNT )
	player.SetPersistentVar( "desiredCampaignMapIndex[1]", cheatToLevel % CAMPAIGN_LEVEL_COUNT )

	player.SetPersistentVar( "campaignLevelsFinishedIMC", cheatToLevel )
	player.SetPersistentVar( "campaignLevelsFinishedMCOR", cheatToLevel )
	player.SetPersistentVar( "campaignStarted", cheatToLevel > 0 )

	if ( cheatToLevel < CAMPAIGN_LEVEL_COUNT )
	{
		if ( player.GetPersistentVar( "campaignTeam" ) == TEAM_ANY )
			player.SetPersistentVar( "campaignTeam", Random( [ TEAM_IMC, TEAM_MILITIA ] ) )
	}
	else
	{
		player.SetPersistentVar( "campaignTeam", TEAM_ANY )
	}

	return true
}

function DoTraining()
{
	if ( GetConnectingAndConnectedPlayerArray().len() != 1 )
		return

	level.ent.Signal( "end_lobby_logic" )

	local player = GetPlayerArray()[0]
	SendPlayerToTraining( player )
}

function ClientCommand_DoTraining( player, ... )
{
	DoTraining()
	return true
}

function ClientCommand_CancelTraining( player, ... )
{
	AbortTrainingSearchesForPlayer( player )
	return true
}

function GetPartyLeaders()
{
	local players = GetPlayerArray()
	local leaders = []
	local leader

	foreach ( player in players )
	{
		leader = GetPartyLeader( player )
		if ( leader && !ArrayContains( leaders, leader ) )
			leaders.append( leader )
	}

	return leaders
}

function ClientCommand_GenUp( player )
{
	// Make sure the player is able to gen up
	if ( !CanGenUp( player ) )
		return false

	GenUp( player )
	return true
}

function ClientCommand_RegenMenuViewed( player )
{
	player.SetPersistentVar( "regenShowNew", false )
	return true
}

function ClientCommand_RegenChallengesViewed( player )
{
	player.SetPersistentVar( "newRegenChallenges", false )
	return true
}

function ClientCommand_DailyChallengesViewed( player )
{
	player.SetPersistentVar( "newDailyChallenges", false )
	return true
}

function ClearAllNewItems( player )
{
	local persistentArraysToClear = []
	persistentArraysToClear.append( "newLoadoutItems" )
	persistentArraysToClear.append( "newMods" )
	persistentArraysToClear.append( "newChassis" )
	persistentArraysToClear.append( "newPilotPassives" )
	persistentArraysToClear.append( "newTitanPassives" )
	persistentArraysToClear.append( "newUnlocks" )

	foreach( persArray in persistentArraysToClear )
	{
		local size = PersistenceGetArrayCount( persArray )
		for ( local i = 0 ; i < size ; i++ )
			player.SetPersistentVar( persArray + "[" + i + "]", false )
	}
}


function ClientCommand_StartPrivateMatchSearch( player, ... )
{
	if ( GetLobbyType() != "party" )
	{
		printt( "Wrong lobby type for StartPrivateMatchSearch command:", GetLobbyType() )
		return false
	}

	if ( GetPartyLeader( player ) != player )
	{
		printt( "Player", player.GetPlayerName(), "tried to 'StartPrivateMatchSearch', but is a party follower." )
		return false
	}

	SendAllPlayersToPrivateMatch()
	return true
}

function ClientCommand_StartCoopMatchSearch( player, ... )
{
	if ( GetMapName() != "mp_lobby")
		return false

	if ( GetLobbyType() != "party" )
	{
		printt( "Wrong lobby type for StartCoopMatchSearch command:", GetLobbyType() )
		return false
	}

	if ( GetPartyLeader( player ) != player )
	{
		printt( "Player", player.GetPlayerName(), "tried to 'StartCoopMatchSearch', but is a party follower." )
		return false
	}

	//local playlistName = GetCurrentPlaylistName()
	//if ( playlistName != "coop" )
	//{
	//	printt( "Wrong active playlist for StartCoopMatchSearch command:", playlistName )
	//	return false
	//}

	printt( player.GetPlayerName(), "is starting coop search." )
	SendAllPlayersToCoopMatch( "", false )
	return true
}

function ClientCommand_ClickedCoopCustomMatch( player, ... )
{
	if ( GetMapName() != "mp_lobby")
		return false

	printt( player.GetPlayerName(), "clicked on coop custom match." )
	player.SetPersistentVar( "haveSeenCustomCoop", true )
	return true
}

function ClientCommand_StartCoopCustomMatchSearch( player, ... )
{
	if ( GetMapName() != "mp_lobby")
		return false

	if ( GetLobbyType() != "party" )
	{
		printt( "Wrong lobby type for StartCoopCustomMatchSearch command:", GetLobbyType() )
		return false
	}

	if ( GetPartyLeader( player ) != player )
	{
		printt( "Player", player.GetPlayerName(), "tried to 'StartCoopCustomMatchSearch', but is a party follower." )
		return false
	}

	//local playlistName = GetCurrentPlaylistName()
	//if ( playlistName != "coop" )
	//{
	//	printt( "Wrong active playlist for StartCoopCustomMatchSearch command:", playlistName )
	//	return false
	//}

	local mapName = GetMapNameForEnum( level.ui.privatematch_map )
	if ( mapName == null )
		return true

	local isPrivate = level.ui.createamatch_isPrivate
	printt( player.GetPlayerName(), "is starting custom coop search on map:", mapName, " isPrivate:", isPrivate )
	SendAllPlayersToCoopMatch( mapName, isPrivate )
	return true
}

function ClientCommand_CoopSetIsPrivate( player, ... )
{
	if ( GetLobbyType() == "game" )
		return false
	if ( GetMapName() != "mp_lobby")
		return false

	if ( vargc <= 0 )
		return true

	local setPrivate = (vargv[0] == "1")
	printt( player.GetPlayerName(), "set coop search isPrivate to:", setPrivate )
	level.ui.createamatch_isPrivate = setPrivate
	return true
}

function ClientCommand_CancelPrivateMatchSearch( player, ... )
{
	if ( GetLobbyType() != "party" )
	{
		printt( "Wrong lobby type for CancelPrivateMatchSearch command:", GetLobbyType() )
		return false
	}

	AbortPrivateMatchSearchesForPlayer( player )
	return true
}


function ClientCommand_SetCustomMap( player, ... )
{
	if ( GetMapName() != "mp_lobby")
		return false

	if ( IsPrivateMatch() )
	{
		if ( GetLobbyType() != "game" )
			return false
		if ( level.ui.privatematch_starting == ePrivateMatchStartState.STARTING )
			return true
	}
	else
	{
		if ( GetLobbyType() == "game" )
			return false
	}

	if ( vargc <= 0 )
		return true
	if ( GetPartyLeader( player ) != player )
	{
		printt( "Player", player.GetPlayerName(), "tried to 'PrivateMatchSetMap', but is a party follower." )
		return false
	}
	local mapName = vargv[0]
	if ( !(mapName in getconsttable().ePrivateMatchMaps) )
		return true

	printt( player.GetPlayerName(), "set custom map to:", mapName )
	level.ui.privatematch_map = getconsttable().ePrivateMatchMaps[mapName]

	if ( IsPrivateMatch() )
		UpdatePrivateMatchReadyStatus( true )

	return true
}

function ClientCommand_PrivateMatchSetMode( player, ... )
{
	if ( !IsPrivateMatch() )
		return false
	if ( GetLobbyType() != "game" )
		return false
	if ( GetMapName() != "mp_lobby")
		return false

	if ( vargc <= 0 )
		return true
	if ( GetPartyLeader( player ) != player )
	{
		printt( "Player", player.GetPlayerName(), "tried to 'PrivateMatchSetMode', but is a party follower." )
		return false
	}
	local modeName = vargv[0]
	if ( !(modeName in getconsttable().ePrivateMatchModes ) )
		return true

	if ( level.ui.privatematch_starting == ePrivateMatchStartState.STARTING )
		return true

	printt( player.GetPlayerName(), "set private_match mode to:", modeName )
	level.ui.privatematch_mode = getconsttable().ePrivateMatchModes[modeName]
	UpdatePrivateMatchReadyStatus( true )

	return true
}

function GetMapNameForEnum( enumVal )
{
	foreach ( name, id in getconsttable().ePrivateMatchMaps )
	{
		if ( id == enumVal )
			return name
	}
	return null
}

function GetModeNameForEnum( enumVal )
{
	foreach ( name, id in getconsttable().ePrivateMatchModes )
	{
		if ( id == enumVal )
			return name
	}

	return null
}

function ClientCommand_PrivateMatchLaunch( player, ... )
{
    if ( !IsPrivateMatch() )
        return false
    if ( GetLobbyType() != "game" )
        return false
    if ( GetMapName() != "mp_lobby")
        return false
    if ( GetPartyLeader( player ) != player )
    {
        printt( "Player", player.GetPlayerName(), "tried to 'PrivateMatchLaunch', but is a party follower." )
        return false
    }
    local mapName = GetMapNameForEnum( level.ui.privatematch_map )
    if ( mapName == null )
        return true

    local modeName = GetModeNameForEnum( level.ui.privatematch_mode )
    if ( modeName == null )
        return true

    if ( Time() < file.nextLaunchCommandValid )
        return true

    local players = GetPlayerArray()
    // Force everyone to Militia in Cooperative mode, regardless of autobalance setting
    if ( modeName == "COOPERATIVE" )
    {
        foreach ( p in players )
        {
            if ( p.GetTeam() != TEAM_MILITIA )
                p.SetTeam( TEAM_MILITIA )
        }
    }
    // Add autobalancing logic here, just before marking teams as balanced
    else if ( GetConVarBool( "delta_autoBalanceTeams" ) )
    {
        //if ( modeName == "COOPERATIVE" ) // Original coop check moved above
        //{
        //    // In cooperative, put everyone on TEAM_MILITIA
        //    foreach ( p in players )
        //        p.SetTeam( TEAM_MILITIA )
        //}
        //else
        //{
            local imcPlayers = []
            local militiaPlayers = []

            // Sort current players by team
            foreach ( p in players )
            {
                if ( p.GetTeam() == TEAM_IMC )
                    imcPlayers.append(p)
                else if ( p.GetTeam() == TEAM_MILITIA )
                    militiaPlayers.append(p)
            }

            // Calculate how many players need to be moved
            local totalPlayers = players.len()
            local targetPerTeam = ceil(totalPlayers / 2.0)

            // Balance from larger team to smaller team
            if ( imcPlayers.len() > militiaPlayers.len() )
            {
                local playersToMove = imcPlayers.len() - targetPerTeam
                for ( local i = 0; i < playersToMove; i++ )
                {
                    if ( imcPlayers.len() > 0 )
                        imcPlayers[i].TrueTeamSwitch()
                }
            }
            else if ( militiaPlayers.len() > imcPlayers.len() )
            {
                local playersToMove = militiaPlayers.len() - targetPerTeam
                for ( local i = 0; i < playersToMove; i++ )
                {
                    if ( militiaPlayers.len() > 0 )
                        militiaPlayers[i].TrueTeamSwitch()
                }
            }
        //}
    }

    file.nextLaunchCommandValid = Time() + 0.25

    if ( level.ui.privatematch_starting == ePrivateMatchStartState.STARTING )
        UpdatePrivateMatchReadyStatus( true )
    else
        level.ui.privatematch_starting = ePrivateMatchStartState.STARTING

    printt( player.GetPlayerName(), "launched private match:", mapName, modeName )
    return true
}

function ClientCommand_PrivateMatchSwitchTeams( player, ... )
{
    if ( !IsPrivateMatch() )
        return false
    if ( GetLobbyType() != "game" )
        return false
    if ( GetMapName() != "mp_lobby")
        return false

    if ( level.ui.privatematch_starting == ePrivateMatchStartState.STARTING )
        return false

    // Get current team counts
    local currentIMCCount = GetTeamPlayerCount( TEAM_IMC )
    local currentMilitiaCount = GetTeamPlayerCount( TEAM_MILITIA )

    // Calculate what the counts would be after the switch
    local newIMCCount = currentIMCCount
    local newMilitiaCount = currentMilitiaCount

    if (player.GetTeam() == TEAM_IMC)
    {
        newIMCCount--
        newMilitiaCount++
    }
    else if (player.GetTeam() == TEAM_MILITIA)
    {
        newIMCCount++
        newMilitiaCount--
    }

    // If auto-balance is enabled, prevent manual switches that increase imbalance.
    if ( GetConVarBool( "delta_autoBalanceTeams" ) )
    {
        local currentImbalance = abs(currentIMCCount - currentMilitiaCount)
        local newImbalance = abs(newIMCCount - newMilitiaCount)
        if ( newImbalance > currentImbalance )
        {
             printt( "AutoBalance enabled: Preventing manual team switch that would increase imbalance." )
             return false
        }
    }
    // Original check (commented out): Don't allow the switch if it would create an imbalance of more than 1 player
    // if (abs(newIMCCount - newMilitiaCount) > 1)
    //    return false

    player.TrueTeamSwitch()
    UpdatePrivateMatchReadyStatus( true )
    return true
}

function ClientCommand_CancelMatchSearch( player, ... )
{
	if ( GetLobbyType() != "party" )
	{
		printt( "Wrong lobby type for CancelMatchSearch command:", GetLobbyType() )
		return false
	}

	AbortMatchSearchesForPlayer( player )
	return true
}

function ClientCommand_ResetMatchSettingsToDefault( player, ... )
{
	if ( !IsPrivateMatch() )
		return false
	if ( GetLobbyType() != "game" )
		return false
	if ( GetMapName() != "mp_lobby")
		return false

	ClearPlaylistVarOverrides()

    return true
}

function ClientCommand_UpdatePrivateMatchSetting( player, ... )
{
	if ( !IsPrivateMatch() )
		return false
	if ( GetLobbyType() != "game" )
		return false
	if ( GetMapName() != "mp_lobby")
		return false
        if ( GetPartyLeader( player ) != player )
        {
            printt( "Player", player.GetPlayerName(), "tried to 'UpdatePrivateMatchSetting', but is a party follower." )
            return false
        }

	if ( level.ui.privatematch_starting == ePrivateMatchStartState.STARTING )
		return

	if ( vargc <= 2 )
	{
		printt( "failed vargc", vargc )
		return true
	}

	local modeName = vargv[0]
	if ( modeName != GetModeNameForEnum( level.ui.privatematch_mode ) )
	{
		printt( "failed modeName", modeName )
		return true
	}

	local pmVarName = vargv[1]
	if ( !(pmVarName in playlistVarMap) )
	{
		printt( "failed pmVarName", pmVarName )
		return true
	}

	printt( "recv UpdatePrivateMatchSetting", vargv[0], vargv[1], vargv[2] )

	local pmVarVal = vargv[2]

	switch ( pmVarName )
	{
		case "pm_score_limit":
			if ( modeName == "lts" )
				SetPlaylistVarOverride( modeName + "_roundscorelimit", "" + pmSettingsMap["pm_score_limit"][modeName][pmVarVal.tointeger()] )
			else
				SetPlaylistVarOverride( modeName + "_scorelimit", "" + pmSettingsMap["pm_score_limit"][modeName][pmVarVal.tointeger()] )
			break

		case "pm_time_limit":
			if ( modeName == "lts" )
				SetPlaylistVarOverride( modeName + "_roundtimelimit", "" + pmVarVal.tointeger() )
			else
				SetPlaylistVarOverride( modeName + "_timelimit", "" + pmVarVal.tointeger() )
			break

		case "pm_burn_cards":
			local value = pmSettingsMap[pmVarName][pmVarVal.tointeger()]

			if ( !(pmVarVal.tointeger() in pmSettingsMap[pmVarName]) )
				return true

			// JFS: the default -1 passed here... when switching from any non-zero "burn_cards_set" to "0",
			// GetCurrentPlaylistVarInt returns the default value instead of a real value for some reason
			local oldValue = GetCurrentPlaylistVarInt( playlistVarMap[pmVarName], -1 )
			SetPlaylistVarOverride( playlistVarMap[pmVarName], "" + value )

			if ( value != oldValue )
			{
				local players = GetPlayerArray()
				foreach ( player in players )
				{
					UpdateBurnCardSet( player, pmVarVal.tointeger() )
				}
			}
			break

		case "pm_pilot_health":
		case "pm_titan_shields":
			local value = pmSettingsMap[pmVarName][pmVarVal.tointeger()]
			SetPlaylistVarOverride( playlistVarMap[pmVarName], "" + value )
			break

		case "pm_pilot_ammo":
		case "pm_pilot_minimap":
		case "pm_ai_type":
		case "pm_ai_lethality":
			local value = GetMappedValueFromPrivateMatchVar( pmVarName, pmVarVal )
			SetPlaylistVarOverride( playlistVarMap[pmVarName], "" + value )
			break

		case "pm_pilot_respawn_delay":
			local value = pmVarVal.tofloat()

			if ( value <= 3.0 )
				break

			value = clamp( value, 3.0, 60.0 )

			SetPlaylistVarOverride( playlistVarMap[pmVarName], "" + value )
			break

		case "pm_titan_build":
			local value = pmVarVal.tofloat() * 60
			if ( value == 0 )
				value = 1
			else
				value = RoundToNearestMultiplier( clamp( value, 30, 600 ), 30 )

			SetPlaylistVarOverride( playlistVarMap[pmVarName], "" + value.tointeger() )
			break

		case "pm_titan_rebuild":
			local value = pmVarVal.tofloat() * 60
			if ( value == 0 )
				value = 1
			else if ( value > 314.99999 )
				value = 0
			else
				value = RoundToNearestMultiplier( clamp( value, 30, 300 ), 30 )

			SetPlaylistVarOverride( playlistVarMap[pmVarName], "" + value.tointeger() )
			break
		case "riff_floorislava":
			local value = pmVarVal.tointeger()
			SetPlaylistVarOverride( playlistVarMap[pmVarName], "" + value )
			break
	}

	SetPlaylistVarOverride( "private_match", "1" )

	return true
}

function ClientCommand_NewBlackMarketItemsViewed( player )
{
	player.SetPersistentVar( "bm.newBlackMarketItems", false )
	return true
}

function ClientCommand_RequestServerChangeToLobbyType0( player )
{
	if ( !IsLobby() )
		return true

	if( IsDedicated() )
		return true

	if ( GetPlayerArray()[0] != player )
		return true

	if ( GetPlayerArray().len() > 1 )
	{
		if ( !IsPrivateMatch() )
			return

		for( local i = 0; i < GetPlayerArray().len(); i++ )
		{
			if ( i == 0 )
				continue

			ServerCommand(format("kickid %d \"Server Shutting Down\"", GetPlayerArray()[i].GetUserId()))
		}
	}

	ServerCommand( "sv_lobbyType 0")
}

function ClientCommand_TryKickPlayersForPersonalLobby( player )
{
	if ( !IsLobby() )
		return true

	if( IsDedicated() )
		return true

	if ( GetPlayerArray()[0] != player )
		return true

	if ( GetPlayerArray().len() > 1 )
	{
		for( local i = 0; i < GetPlayerArray().len(); i++ )
		{
			if ( i == 0 )
				continue

			ServerCommand(format("kickid %d \"Server Shutting Down\"", GetPlayerArray()[i].GetUserId()))
		}
	}
}

// helpful on a direct connect
function Lobby_UpdateLobbyType( player )
{
	if ( !IsLobby() )
		return true

	if ( GetConVarBool("sv_lobbyType") )
		return true

	if ( GetPlayerArray().len() > 1 )
	    ServerCommand( "sv_lobbyType 1" )
}

function GetMappedValueFromPrivateMatchVar( pmVarName, pmVarSetting )
{
	local pmSetting = 0 // zero equals default
	foreach ( index, value in pmSettingsMap[pmVarName] )
	{
		if ( value.tostring() != pmVarSetting )
			continue

		pmSetting = value
		break
	}

	return pmSetting
}

function ReadyToStart()
{
	if ( IsPrivateMatch() )
		return false

	if ( DevLobbyIsFrozen() )
		return false;

	if ( IsCoopMatch() )
		return file.teamReady[TEAM_MILITIA]

	// if ( !file.teamReady[TEAM_IMC] )
	// 	return false
	// if ( !file.teamReady[TEAM_MILITIA] )
	// 	return false

	// local minPlayersSpread = GetCurrentPlaylistVarInt( "min_players_spread", 2 )
	// local playerSpread = abs( GetTeamPlayerCount( TEAM_IMC ) - GetTeamPlayerCount( TEAM_MILITIA ) )
	// if ( playerSpread > minPlayersSpread )
	// 	return false

    // Require more than 1 player total
    local totalPlayers = GetTeamPlayerCount( TEAM_IMC ) + GetTeamPlayerCount( TEAM_MILITIA )
    if ( totalPlayers <= 1 )
        return false


	return true
}

// Changes the private match map setting to a map that all players can play if the current map can't be
function UpdatePrivateMatchMapIfUnavailable()
{
	local mapName = GetMapNameForEnum( level.ui.privatematch_map )

	if ( mapName )
	{
		local dlcGroup = GetDLCMapGroupForMap( mapName )

		if ( !ServerHasDLCMapGroupEnabled( dlcGroup ) )
		{
			level.ui.privatematch_map = getconsttable().ePrivateMatchMaps["mp_fracture"]
			UpdatePrivateMatchReadyStatus( true )
		}
	}
}

function UpdateCustomMatchMapIfUnavailable()
{
	local mapName = GetMapNameForEnum( level.ui.privatematch_map )
	if ( !mapName )
		return

	local dlcGroup = GetDLCMapGroupForMap( mapName )
	if ( ServerHasDLCMapGroupEnabled( dlcGroup ) )
		return

	level.ui.privatematch_map = getconsttable().ePrivateMatchMaps["mp_fracture"]
}

