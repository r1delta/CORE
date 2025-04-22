
function main()
{
    RegisterSignal( "StopHeartbeat" )
    Globalize( SendServerHeartbeat )
    AddCallback_OnClientConnected( ClientConnect )
    AddCallback_OnClientDisconnected( OnClientDisconnect )

    
    // Start initial heartbeat with random delay (0-5s)
    thread DelayedFirstHeartbeat()
    
    // Start repeating heartbeat thread
    thread HeartbeatLoop()
}

function DelayedFirstHeartbeat()
{
    // Random initial delay between 0-5 seconds
    wait RandomFloat(0.0, 5.0)
    SendServerHeartbeat()
}

function HeartbeatLoop()
{
    level.ent.EndSignal( "StopHeartbeat" )
    
    while(1)
    {
        // Wait 10 seconds + random jitter between -2.5 and +2.5 seconds
        wait (7.0 + RandomFloat(-2.5, 2.5))
        SendServerHeartbeat()
    }
}

function ClientConnect(player) {
    SendServerHeartbeat(); 
}

function OnClientDisconnect(player) {
    SendServerHeartbeat();
    local xp = player.GetPersistentVar("xp")
    player.SetPersistentVar("previousXP",xp)
}

function SendServerHeartbeat() {
    // Collect data to be encoded
    local host_name = GetConVarString("hostname");
    local map_name = GetMapName();
    local port = GetConVarInt("hostport"); // Get as integer
	local maxPlayers = GetCurrentPlaylistVarInt( "max players", 0 );
    local game_mode = GameRules.GetGameMode();
	local data_table = {}
    local players = []
    
    foreach(player in GetPlayerArray()){
        if(player.IsBot()) {
            continue; // Skip bots
        }
        local data_struct = {}
        data_struct.name <- player.GetPlayerName();
        data_struct.gen <- player.GetGen();
        data_struct.lvl <- GetLevel( player );
        data_struct.team <- player.GetTeam();
        players.append(data_struct);
    }
    // Create a table to store data
    data_table.host_name <- host_name;
    data_table.map_name <- map_name;
    data_table.game_mode <- game_mode;
    data_table.playlist <- GetCurrentPlaylistName()
    data_table.playlist_display_name <- GetCurrentPlaylistVar("name","")
    data_table.players <- players;
    data_table.max_players <- maxPlayers
    
    SendDataToCppServer(data_table);
}