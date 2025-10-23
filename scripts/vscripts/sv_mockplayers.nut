// ============================================================================
// sv_mockplayers.nut
// Mock player system for testing RTV/voting without multiple real players
// Requires sv_cheats 1
// ============================================================================

// Mock player tracking
::mockPlayers <- {
    players = [],
    nextId = 1000
}

function InitMockPlayers()
{
    // Register commands
    AddClientCommandCallback( "mock_addplayer", ClientCommand_MockAddPlayer )
    AddClientCommandCallback( "mock_removeplayer", ClientCommand_MockRemovePlayer )
    AddClientCommandCallback( "mock_clearplayers", ClientCommand_MockClearPlayers )
    AddClientCommandCallback( "mock_rtv", ClientCommand_MockRTV )
    AddClientCommandCallback( "mock_vote", ClientCommand_MockVote )
    AddClientCommandCallback( "mock_listplayers", ClientCommand_MockListPlayers )

    printt("[MockPlayers] System initialized - use sv_cheats 1 commands for testing")
    printt("[MockPlayers] Commands: mock_addplayer <name>, mock_rtv <name>, mock_vote <name> <option>")
}

// Mock player structure
class MockPlayer
{
    name = ""
    userId = 0
    hasRTVoted = false
    mapVote = -1

    constructor( playerName, id )
    {
        name = playerName
        userId = id
    }
}

function ClientCommand_MockAddPlayer( player, ... )
{
    if ( !GetConVarBool( "sv_cheats" ) )
    {
        printt("[MockPlayers] Requires sv_cheats 1")
        return true
    }

    local playerName = (vargc > 0) ? vargv[0] : ("MockPlayer" + mockPlayers.nextId)

    local mockPlayer = MockPlayer( playerName, mockPlayers.nextId )
    mockPlayers.players.append( mockPlayer )
    mockPlayers.nextId++

    printt("[MockPlayers] Added mock player:", playerName, "ID:", mockPlayer.userId)
    Chat_ServerBroadcast( playerName + " (mock) has joined the server" )

    return true
}

function ClientCommand_MockRemovePlayer( player, ... )
{
    if ( !GetConVarBool( "sv_cheats" ) )
    {
        printt("[MockPlayers] Requires sv_cheats 1")
        return true
    }

    if ( vargc < 1 )
    {
        printt("[MockPlayers] Usage: mock_removeplayer <name or index>")
        return true
    }

    local target = vargv[0]

    // Try as index first
    try
    {
        local index = target.tointeger()
        if ( index >= 0 && index < mockPlayers.players.len() )
        {
            local removed = mockPlayers.players[index]
            mockPlayers.players.remove( index )
            printt("[MockPlayers] Removed mock player:", removed.name)
            Chat_ServerBroadcast( removed.name + " (mock) has left the server" )
            return true
        }
    }
    catch ( e ) {}

    // Try as name
    for ( local i = 0; i < mockPlayers.players.len(); i++ )
    {
        if ( mockPlayers.players[i].name == target )
        {
            local removed = mockPlayers.players[i]
            mockPlayers.players.remove( i )
            printt("[MockPlayers] Removed mock player:", removed.name)
            Chat_ServerBroadcast( removed.name + " (mock) has left the server" )
            return true
        }
    }

    printt("[MockPlayers] Mock player not found:", target)
    return true
}

function ClientCommand_MockClearPlayers( player, ... )
{
    if ( !GetConVarBool( "sv_cheats" ) )
    {
        printt("[MockPlayers] Requires sv_cheats 1")
        return true
    }

    local count = mockPlayers.players.len()
    mockPlayers.players = []

    printt("[MockPlayers] Cleared all", count, "mock players")
    return true
}

function ClientCommand_MockRTV( player, ... )
{
    if ( !GetConVarBool( "sv_cheats" ) )
    {
        printt("[MockPlayers] Requires sv_cheats 1")
        return true
    }

    if ( vargc < 1 )
    {
        printt("[MockPlayers] Usage: mock_rtv <player name or index>")
        return true
    }

    local mockPlayer = FindMockPlayer( vargv[0] )
    if ( mockPlayer == null )
    {
        printt("[MockPlayers] Mock player not found:", vargv[0])
        return true
    }

    if ( mockPlayer.hasRTVoted )
    {
        printt("[MockPlayers]", mockPlayer.name, "has already RTVed")
        return true
    }

    // Simulate RTV vote
    mockPlayer.hasRTVoted = true

    if ( !("rtvState" in getroottable()) )
    {
        printt("[MockPlayers] RTV system not loaded")
        return true
    }

    rtvState.votes[mockPlayer.userId] <- true

    local currentVotes = GetRTVVoteCount() + 1 // +1 for mock vote
    local votesNeeded = CalculateRTVVotesNeeded()

    printt("[MockPlayers]", mockPlayer.name, "voted to RTV (", currentVotes, "/", votesNeeded, ")")
    Chat_ServerBroadcast( mockPlayer.name + " (mock) wants to rock the vote! (" + currentVotes + "/" + votesNeeded + " votes)" )

    // Check if enough votes
    if ( currentVotes >= votesNeeded )
    {
        StartRTV()
    }

    return true
}

function ClientCommand_MockVote( player, ... )
{
    if ( !GetConVarBool( "sv_cheats" ) )
    {
        printt("[MockPlayers] Requires sv_cheats 1")
        return true
    }

    if ( vargc < 2 )
    {
        printt("[MockPlayers] Usage: mock_vote <player name> <option 1-9>")
        return true
    }

    local mockPlayer = FindMockPlayer( vargv[0] )
    if ( mockPlayer == null )
    {
        printt("[MockPlayers] Mock player not found:", vargv[0])
        return true
    }

    local option = vargv[1].tointeger()
    if ( option == null || option < 1 || option > 9 )
    {
        printt("[MockPlayers] Invalid option, must be 1-9")
        return true
    }

    if ( !("mapVoteState" in getroottable()) )
    {
        printt("[MockPlayers] Map vote system not loaded")
        return true
    }

    if ( !mapVoteState.active )
    {
        printt("[MockPlayers] No active vote")
        return true
    }

    // Simulate vote
    local voteIndex = option - 1

    if ( voteIndex >= mapVoteState.options.len() )
    {
        printt("[MockPlayers] Invalid option for current vote")
        return true
    }

    mapVoteState.votes[mockPlayer.userId] <- voteIndex

    local optionName = mapVoteState.options[voteIndex]
    printt("[MockPlayers]", mockPlayer.name, "voted for option", option, "(", optionName, ")")
    Chat_ServerBroadcast( mockPlayer.name + " (mock) voted for: " + optionName )

    return true
}

function ClientCommand_MockListPlayers( player, ... )
{
    if ( !GetConVarBool( "sv_cheats" ) )
    {
        printt("[MockPlayers] Requires sv_cheats 1")
        return true
    }

    if ( mockPlayers.players.len() == 0 )
    {
        printt("[MockPlayers] No mock players")
        return true
    }

    printt("[MockPlayers] Mock players:")
    for ( local i = 0; i < mockPlayers.players.len(); i++ )
    {
        local p = mockPlayers.players[i]
        printt("  [" + i + "] " + p.name + " (ID: " + p.userId + ", RTV: " + p.hasRTVoted + ")")
    }

    return true
}

function FindMockPlayer( nameOrIndex )
{
    // Try as index first
    try
    {
        local index = nameOrIndex.tointeger()
        if ( index >= 0 && index < mockPlayers.players.len() )
            return mockPlayers.players[index]
    }
    catch ( e ) {}

    // Try as name
    foreach ( mockPlayer in mockPlayers.players )
    {
        if ( mockPlayer.name == nameOrIndex )
            return mockPlayer
    }

    return null
}

// Override GetPlayerArray to include mock players in vote counts
function GetPlayerArrayWithMocks()
{
    local realPlayers = GetPlayerArray()
    return realPlayers.len() + mockPlayers.players.len()
}

// Modify RTV vote calculation to include mocks
function GetRTVVoteCount_WithMocks()
{
    local count = GetRTVVoteCount() // Real player votes

    // Add mock player votes
    foreach ( mockPlayer in mockPlayers.players )
    {
        if ( mockPlayer.hasRTVoted )
            count++
    }

    return count
}

function CalculateRTVVotesNeeded_WithMocks()
{
    local playerCount = GetPlayerArray().len() + mockPlayers.players.len()
    local needed = (playerCount * RTV_PERCENTAGE_NEEDED).tointeger()

    if ( needed == 0 )
        needed = 1

    return needed
}

// Reset mock votes on map change
function MockPlayers_OnMapStart()
{
    foreach ( mockPlayer in mockPlayers.players )
    {
        mockPlayer.hasRTVoted = false
        mockPlayer.mapVote = -1
    }

    printt("[MockPlayers] Reset votes for all mock players")
}

// Globalize functions
Globalize(InitMockPlayers)
Globalize(MockPlayers_OnMapStart)
