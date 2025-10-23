// ============================================================================
// sv_rtv_autorun.nut
// Autorun file for RTV and map voting system
// ============================================================================

printt("=====================================")
printt("[RTV/MapVote] Initializing system...")
printt("=====================================")

// Define callback functions first
function RTV_OnClientDisconnected( player )
{
    RTV_OnPlayerDisconnected( player )
}

function Nominate_OnClientDisconnected( player )
{
    Nominate_OnPlayerDisconnected( player )
}

function CheckForVoteResultAtMapEnd()
{
    // Wait for match to end
    while ( GetGameState() != eGameState.Postmatch )
        wait 1

    // Check if we have a voted map to go to
    if ( "nextMapVote" in level )
    {
        wait 3 // Give time for score screen

        printt("[RTV/MapVote] Applying voted map at map end")
        MapVote_OnMapEnd()
    }
}

// Include required files
IncludeFile( "sv_menuselect_handler" )
IncludeFile( "sv_rtv" )
IncludeFile( "sv_mapvote" )
IncludeFile( "sv_nominate" )
IncludeFile( "sv_mockplayers" )

// Initialize systems
InitMenuSelectHandler()
InitRTV()
InitMapVote()
InitNominate()
InitMockPlayers()

// Reset RTV state on map start (autorun file runs on map start)
RTV_OnMapStart()
Nominate_OnMapStart()
MockPlayers_OnMapStart()

// Start monitoring for vote result at map end
thread CheckForVoteResultAtMapEnd()

// Register callbacks
AddCallback_OnClientDisconnected( RTV_OnPlayerDisconnected )
AddCallback_OnClientDisconnected( Nominate_OnPlayerDisconnected )

printt("=====================================")
printt("[RTV/MapVote/Nominate] System ready!")
printt("[RTV/MapVote/Nominate] Chat commands:")
printt("  !rtv or !rockthevote - Start Rock The Vote")
printt("  !nominate [map] - Nominate a map (fuzzy search)")
printt("  !nominate - Show all maps in paginated menu")
printt("  !revote - Reopen current vote menu")
printt("[RTV/MapVote/Nominate] Mock player commands (sv_cheats 1):")
printt("  mock_addplayer <name> - Add mock player")
printt("  mock_rtv <name> - Mock player votes RTV")
printt("  mock_vote <name> <1-9> - Mock player votes in map vote")
printt("  mock_listplayers - List all mock players")
printt("  mock_clearplayers - Remove all mock players")
printt("=====================================")
