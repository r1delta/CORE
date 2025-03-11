function main()
{
    AddClientCommandCallback("SetPlayRankedOn", ClientCommand_SetPlayRankedOn)
    AddClientCommandCallback("SetPlayRankedOff", ClientCommand_SetPlayRankedOff)
    // AddCallback_OnPlayerRespawned(Ranked_OnPlayerSpawned)
    // AddCallback_OnScoreEvent(Leagues_OnScoreEvent)
    printt("Ranked is loaded")
}

//ServerCallback_ToggleRankedInGame to actually toggle the ranked state
function ClientCommand_SetPlayRankedOn(player)
{
    player.SetPersistentVar("ranked.isPlayingRanked",1)
}

function ClientCommand_SetPlayRankedOff(player)
{   
    player.SetPersistentVar("ranked.isPlayingRanked",0)
}


