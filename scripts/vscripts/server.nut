function main()
{
	Globalize( SendServerHeartbeat )
}

function SendServerHeartbeat() {
    // Collect data to be encoded
    local host_name = GetConVarString("hostname");
    local map_name = GetMapName();
    local ip = GetConVarString("hostip");
    local port = GetConVarString("hostport");
    local game_mode = GameRules.GetGameMode();
	local data_table = {}
    local players = GetPlayerArray()
    local player_data = []
   
    foreach(i,player in players) {
        local gen = player.GetGen()
	    local lvl = GetLevel( player )
        local name = player.GetPlayerName()
        local team = player.GetTeam()
        local data_struct = {}
        data_struct.name <- name;
        data_struct.gen <- gen;
        data_struct.lvl <- lvl;
        data_struct.team <- team;
        player_data.append(data_struct);
    }
    // Create a table to store data
    data_table.host_name <- host_name;
    data_table.map_name <- map_name;
    data_table.game_mode <- game_mode;
    data_table.players <- player_data;
    // data_table.ip <- ip;
    data_table.port <- port;
    if(players.len() > 0) {
        SendDataToCppServer(data_table);
    }
}

function SetLevel( newLevel, player = null )
{
    if ( newLevel < 1 )
        newLevel = 1
    else if ( newLevel > MAX_LEVEL )
        newLevel = MAX_LEVEL
    if ( player )
    {
        SetPersistentStringForClient( player, "xp", GetXPForLevel( newLevel ) )
        player.SetPersistentVar( "previousXP", player.GetPersistentVar( "xp" ) )
        _SetXP( player, GetXPForLevel( newLevel ) )
        DevClearAllNewStatus(player)
        return
    }
    local players = GetPlayerArray()
    foreach ( player in players )
    {
        _SetXP( player, GetXPForLevel( newLevel ) )
        DevClearAllNewStatus(player)
    }
}

function DevSetGen( newGen, player )
{
    newGen -= 1 // Because internally they go from 0..9 and humans will enter 1..10
    if ( newGen < 0 )
        newGen = 0
    if( newGen > MAX_GEN )
        newGen = MAX_GEN
    SetLevel( 1, player )
    player.SetPersistentVar( "gen", newGen )
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