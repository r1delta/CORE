function main()
{
    AddClientCommandCallback("SetPlayRankedOn", ClientCommand_SetPlayRankedOn)
    AddClientCommandCallback("SetPlayRankedOff", ClientCommand_SetPlayRankedOff)
    // AddClientCommandCallback("SetPlayRankedOnInGame", ClientCommand_SetRankedPlayOnInGame)
    // AddCallback_OnPlayerRespawned(Ranked_OnPlayerSpawned)
    // AddCallback_OnScoreEvent(Leagues_OnScoreEvent)
    if(!IsLobby()) {
        SetOnScoreEventFunc(Leagues_OnScoreEvent)
    }
    printt("Ranked is loaded")
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



function Leagues_OnScoreEvent(player,scoreEvent) {
    printt(player, "score event", scoreEvent)

    printt("HELLO \n \n \n \n")
}