function main()
{
    AddClientCommandCallback("SetPlayRankedOn", ClientCommand_SetPlayRankedOn)
    AddClientCommandCallback("SetPlayRankedOff", ClientCommand_SetPlayRankedOff)
    AddCallback_OnPlayerRespawned(Ranked_OnPlayerSpawned)
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


function Ranked_OnPlayerSpawned(player)
{   
    if(!player) return
    printt("ranked is playing ranked" + player.GetPersistentVar("ranked.isPlayingRanked"))
    local currentSkill = player.GetPersistentVar("ranked.currentSkill")
    local currentPerformance = SkillToPerformance(currentSkill)
    thread SpawnThread(player)
}

function SpawnThread(player) {
   
    Remote.CallFunction_NonReplay( player, "SCB_SetUserPerformance", 0 )
}