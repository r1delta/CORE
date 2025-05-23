function main()
{
    AddClientCommandCallback("JoinRankedPlay", ClientCommand_JoinRankedPlay)
    AddClientCommandCallback("SetPlayRankedOn", ClientCommand_SetPlayRankedOn)
    AddClientCommandCallback("SetPlayRankedOff", ClientCommand_SetPlayRankedOff)
    // AddCallback_OnPlayerRespawned(Ranked_OnPlayerSpawned)

    if( !IsLobby() )
    {
        SetOnScoreEventFunc(Leagues_OnScoreEvent)
        AddClientCommandCallback("SetPlayRankedOnInGame", ClientCommand_SetRankedPlayOnInGame)
        AddCallback_GameStateEnter( eGameState.Playing, Ranked_EnableRankChipOnPlaying )
    }

    printt("Ranked is loaded")

    file.doneRankChipEnableFunc <- false
}

function Ranked_EnableRankChipOnPlaying()
{
    if( file.doneRankChipEnableFunc )
        return

    file.doneRankChipEnableFunc = true

    foreach ( player in GetPlayerArray() )
    {
        if ( !IsValid(player) )
            continue

        if ( player.GetPersistentVar("ranked.isPlayingRanked") && !player.IsPlayingRanked() )
        {
            player.SetIsPlayingRanked( true )
            Remote.CallFunction_NonReplay( player, "ServerCallback_ToggleRankedInGame", true )
            Remote.CallFunction_Replay( player, "SCB_SetUserPerformance", 0 )
        }
    }
}

function ClientCommand_SetRankedPlayOnInGame( player, ... )
{
    if ( TooLateForRanked() )
        return

    if ( !MatchSupportsRankedPlay( player ) )
        return

    if ( player.IsPlayingRanked() )
        return

    player.SetPersistentVar("ranked.isPlayingRanked", 1)
    player.SetIsPlayingRanked(1)
    Remote.CallFunction_NonReplay(player, "ServerCallback_ToggleRankedInGame", true)
    Remote.CallFunction_Replay(player, "SCB_SetUserPerformance",0)
    printt("Set ranked play on in game: " + player.IsPlayingRanked())
    return true
}

//ServerCallback_ToggleRankedInGame to actually toggle the ranked state
function ClientCommand_SetPlayRankedOn(player)
{
    if ( !IsLobby() )
        return

    player.SetPersistentVar("ranked.isPlayingRanked",1)
    player.SetIsPlayingRanked(1)
    return true
}

function ClientCommand_SetPlayRankedOff(player)
{
    if ( !IsLobby() )
        return

    player.SetPersistentVar("ranked.isPlayingRanked",0)
    player.SetIsPlayingRanked(0)
    return true
}

function ClientCommand_JoinRankedPlay( player )
{
    player.SetPersistentVar( "ranked.joinedRankedPlay", 1 )
}

function Leagues_OnScoreEvent( player, scoreEvent )
{
    // printt(player, "score event", scoreEvent)

    if ( !player.IsPlayingRanked() )
        return

    if ( TooLateForRanked() )
        return

    if ( !MatchSupportsRankedPlay( player ) )
        return

    local gamemode = GameRules.GetGameMode()

    // need to dump level.performanceGoals from vanilla
    //
    // attrition is the easiest to hook up but move this to _ranked_gamemodes later
    //
    // based on pondering my orb, ranked could look like
    // previousPerformance = PreviousAssaultScore / (PreviousAssaultScore + PreviousDeathPenalty)
    // currentPerformance = CurrentAssaultScore / (CurrentAssaultScore + CurrentDeathPenalty)
    // GrowthRate = (CurrentPerformance - PreviousPerformance) / TimeElapsed (Time() vs Time() between score events)
    //
    // only thing worth considering afterwards is lobby average skill vs this growth value
    // presumabely though this is calculated at the end of the match along with the win percentage bonus (thankfully is also in _ranked_shared)
    // however GrowthRate is graphed against level.performanceGoals which is what we don't have at the moment
    //
    // relevant functions to work with afterwards might be GetGoalPerf and GetGoalIndexFromScore
    //
    // thanks to https://www.reddit.com/r/titanfall/comments/2klo81/how_ranked_play_works_and_changes/
    // we know the death penalty is deathcount * 3 in attrition, hopefully all the tuning is done in level.performanceGoals
    // and we don't have to tweak any multipliers to the player performance

    switch( gamemode )
    {
        case ATTRITION:
            break

    }
}