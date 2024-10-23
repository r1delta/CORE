
function main()
{
	Globalize( SendServerHeartbeat )
}
function SendServerHeartbeat() {
    print("Sending server heartbeat");
    // Collect data to be encoded
    local host_name = GetConVarString("hostname");
    local map_name = GetMapName();
    local game_mode = GameRules.GetGameMode();
	local data_table = {}
//		player = GetLocalClientPlayer()

    local players = GetPlayerArray()
    local player_data = []
    print("Players: " + players.len() + "\n");
    foreach(i,player in players) {
        local gen = player.GetGen()
	    local lvl = GetLevel( player )
        local name = player.GetName()
        local team = player.GetTeam()
        print("Player: " + name + " Gen: " + gen + " Lvl: " + lvl + " Team: " + team + " ID: " + i + "\n");
        player_data[i] = {
            name = name,
            gen = gen,
            lvl = lvl,
            team = team
        }


    }


    // Create a table to store data
    data_table.host_name <- host_name;
    data_table.map_name <- map_name;
    data_table.game_mode <- game_mode;
    data_table.players <- player_data;

    print("Data table: " + data_table.players);


    SendDataToCppServer(data_table);
}

function Base64Encode(data) {
    local base64_table = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    local result = "";
    local padding = "";

    local data_len = data.len();
    local i = 0;

    // Loop through input data in 3-byte chunks
    while (i < data_len) {
        local byte1 = data[i];
        local byte2 = (i + 1 < data_len) ? data[i + 1] : 0;
        local byte3 = (i + 2 < data_len) ? data[i + 2] : 0;

        local index1 = (byte1 >> 2) & 0x3F;
        local index2 = ((byte1 << 4) & 0x30) | ((byte2 >> 4) & 0x0F);
        local index3 = ((byte2 << 2) & 0x3C) | ((byte3 >> 6) & 0x03);
        local index4 = byte3 & 0x3F;

        result += base64_table[index1].tochar() + base64_table[index2].tochar();
        result += (i + 1 < data_len) ? base64_table[index3].tochar() : "=";
        result += (i + 2 < data_len) ? base64_table[index4].tochar() : "=";

        i += 3;
    }

    return result;
}