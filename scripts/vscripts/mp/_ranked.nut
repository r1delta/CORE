function main()
{
    AddClientCommandCallback("JoinRankedPlay", ClientCommand_JoinRankedPlay)
    AddClientCommandCallback("SetPlayRankedOn", ClientCommand_SetPlayRankedOn)
    AddClientCommandCallback("SetPlayRankedOff", ClientCommand_SetPlayRankedOff)
    // AddClientCommandCallback("SetPlayRankedOnInGame", ClientCommand_SetRankedPlayOnInGame)
    // AddCallback_OnPlayerRespawned(Ranked_OnPlayerSpawned)
    // AddCallback_OnScoreEvent(Leagues_OnScoreEvent)
    if(!IsLobby())
        SetOnScoreEventFunc(Leagues_OnScoreEvent)

    printt("Ranked is loaded")
}

function ClientCommand_SetRankedPlayOnInGame(player) {
    player.SetPersistentVar("ranked.isPlayingRanked",1)
    player.SetIsPlayingRanked(1)
    Remote.CallFunction_NonReplay(player, "ServerCallback_ToggleRankedInGame", true)
    Remote.CallFunction_Replay(player, "SCB_SetUserPerformance",0)
    printt("Set ranked play on in game: " + player.IsPlayingRanked())
    return true
}

//ServerCallback_ToggleRankedInGame to actually toggle the ranked state
function ClientCommand_SetPlayRankedOn(player)
{
    player.SetPersistentVar("ranked.isPlayingRanked",1)
    player.SetIsPlayingRanked(1)
    return true
}

function ClientCommand_SetPlayRankedOff(player)
{
    player.SetPersistentVar("ranked.isPlayingRanked",0)
    player.SetIsPlayingRanked(0)
    return true
}

function ClientCommand_JoinRankedPlay( player )
{
    player.SetPersistentVar( "ranked.joinedRankedPlay", 1 )
}

function Leagues_OnScoreEvent(player,scoreEvent) {
    printt(player, "score event", scoreEvent)

    printt("HELLO \n \n \n \n")
}