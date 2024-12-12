
function main()
{
	Globalize( SendServerHeartbeat )
    AddCallback_OnClientConnected( ClientConnect )
    AddCallback_OnClientDisconnected( OnClientDisconnect )
    file.ms_data <- {}
    file.ms_data["players"] <- [];
    SendServerHeartbeat();
}


function ClientConnect(player) {
    InitXP(player)
	player.GenChanged()
    player.XPChanged()
    local data_struct = {}
    data_struct.name <- player.GetPlayerName();
    data_struct.gen <- player.GetGen();
    data_struct.lvl <- GetLevel( player );
    data_struct.team <- player.GetTeam();
    file.ms_data["players"].append(data_struct);
    SendServerHeartbeat();
}

function OnClientDisconnect(player) {
   
    local name = player.GetPlayerName()
    foreach(i,p in file.ms_data["players"]) {
        if(p.name == name) {
            printt("Removing: " + p.name);
            file.ms_data["players"].remove(i);
            break;
        }
    }
    SendServerHeartbeat();
}


function SendServerHeartbeat() {
    // Collect data to be encoded
    local host_name = GetConVarString("hostname");
    local map_name = GetMapName();
    local ip = GetConVarString("hostip");
    local port = GetConVarString("hostport");
	local maxPlayers = GetCurrentPlaylistVarInt( "max players", 0 );
    local game_mode = GameRules.GetGameMode();
	local data_table = {}
    local players = GetPlayerArray()  
    // Create a table to store data
    data_table.host_name <- host_name;
    data_table.map_name <- map_name;
    data_table.game_mode <- game_mode;
    data_table.players <- file.ms_data["players"];
    data_table.max_players <- maxPlayers
    data_table.port <- port;
    
    SendDataToCppServer(data_table);
}
