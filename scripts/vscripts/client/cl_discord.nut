

function main() {
    Globalize( GetPresence )
}

function GetPresence() {
    thread GetPresence_Threaded()
}

function GetPresence_Threaded()
{
    local init = true
    
    while(true)
    {
        if( !IsConnected() )
            break


        local table = {}
        if(init) 
            init = false
        
       

        local map_name = GetMapName()
        table["map_name"] <- map_name
        table["map_display_name"] <- Localize(map_name)
        
        if(map_name == "mp_lobby")
            table["map_display_name"] <- Localize("LOBBY")
        else if(GetCurrentPlaylistName() == "campaign_carousel")
            table["map_display_name"] <- Localize(map_name + "_CAMPAIGN_NAME")

        table["game_mode"] <- Localize("GAMEMODE_" + GameRules.GetGameMode())

        table["playlist"] <- Localize(GetCurrentPlaylistName())
        table["playlist_display_name"] <- Localize(GetCurrentPlaylistVar("name",""))

        local players = GetPlayerArray()
        local player_count = 0
        foreach (player in players) {
            if (IsValid(player)) {
                player_count += 1
            }
        }

        table["player_count"] <- player_count
        local maxPlayers = GetCurrentPlaylistVarInt( "max players", 0 );
        table["max_players"] <- maxPlayers
        table["team"] <- GetLocalClientPlayer().GetTeam()

        SendDiscordClient(table,init)

        wait 2
    }
}