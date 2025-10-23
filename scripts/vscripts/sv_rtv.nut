// ============================================================================
// sv_rtv.nut
// Rock The Vote system for r1delta
// ============================================================================

// RTV Configuration
const RTV_PERCENTAGE_NEEDED = 0.60 // 60% of players need to RTV
const RTV_MIN_PLAYERS = 1 // Minimum players required for RTV
const RTV_COOLDOWN = 120.0 // Cooldown in seconds after failed RTV
const RTV_INITIAL_DELAY = 30.0 // Delay after map start before RTV is available

// RTV State
::rtvState <- {
    allowed = false,
    votes = {},
    votesNeeded = 0,
    nextVoteTime = 0,
    hasVoteStarted = false,
    changeInProgress = false
}

function InitRTV()
{
    // Register RTV commands (both console and chat)
    AddClientCommandCallback( "rtv", ClientCommand_RTV )
    AddClientCommandCallback( "rockthevote", ClientCommand_RTV )

    // Register chat command handler
    AddCallback_OnClientChatMsg( RTV_OnChatMessage )
    printt("[RTV] Registered RTV commands (console and chat)")

    // Delay RTV availability
    thread DelayRTVAvailability()

    printt("[RTV] System initialized")
}

function DelayRTVAvailability()
{
    wait RTV_INITIAL_DELAY
    rtvState.allowed = true
    printt("[RTV] Now available to players")
}

function RTVCommand( player, args, returnfunc )
{
    AttemptRTV( player, returnfunc )
    return true
}

function ClientCommand_RTV( player, ... )
{
    AttemptRTV( player, Chat_ServerPrivateMessage )
    return true
}

function RTV_OnChatMessage( playerIndex, message, isTeamChat )
{
    // Check if message starts with ! or t! (team chat)
    if ( message.len() < 2 )
        return message

    local messageStart = 0
    if ( message.len() > 2 && format("%c", message[0]) == "t" && format("%c", message[1]) == "!" )
        messageStart = 2
    else if ( format("%c", message[0]) == "!" )
        messageStart = 1
    else
        return message

    // Extract command from message
    local command = message.slice( messageStart, message.len() ).tolower()

    // Check if it's an RTV command
    if ( command != "rtv" && command != "rockthevote" )
        return message

    // Get player entity
    local player = GetEntByIndex( playerIndex )
    if ( !IsValid( player ) )
        return message

    // Execute RTV command
    AttemptRTV( player, Chat_ServerPrivateMessage )

    // Block the chat message
    return ""
}

function AttemptRTV( player, returnfunc )
{
    // Check if RTV is allowed
    if ( !rtvState.allowed )
    {
        returnfunc( player, "RTV is not available yet. Please wait.", false )
        return
    }

    // Check if we're in lobby
    if ( GetMapName() == "mp_lobby" )
    {
        returnfunc( player, "Cannot RTV in lobby.", false )
        return
    }

    // Check cooldown
    if ( Time() < rtvState.nextVoteTime )
    {
        local timeLeft = (rtvState.nextVoteTime - Time()).tointeger()
        returnfunc( player, "RTV is on cooldown for " + timeLeft + " more seconds.", false )
        return
    }

    // Check if vote already started
    if ( rtvState.hasVoteStarted )
    {
        returnfunc( player, "Map vote is already in progress!", false )
        return
    }

    // Check if map change is in progress
    if ( rtvState.changeInProgress )
    {
        returnfunc( player, "Map change is already in progress!", false )
        return
    }

    // Check minimum players
    local playerCount = GetPlayerArray().len()
    if ( playerCount < RTV_MIN_PLAYERS )
    {
        returnfunc( player, "Not enough players online to start RTV (need at least " + RTV_MIN_PLAYERS + " players).", false )
        return
    }

    // Check if player already voted
    local playerId = player.GetUserId()
    if ( playerId in rtvState.votes )
    {
        local currentVotes = GetRTVVoteCount()
        local votesNeeded = CalculateRTVVotesNeeded()
        returnfunc( player, "You have already voted to RTV! (" + currentVotes + "/" + votesNeeded + " votes)", false )
        return
    }

    // Record vote
    rtvState.votes[playerId] <- true
    local currentVotes = GetRTVVoteCount()
    local votesNeeded = CalculateRTVVotesNeeded()

    // Announce vote
    local msg = player.GetPlayerName() + " wants to rock the vote! (" + currentVotes + "/" + votesNeeded + " votes)"
    Chat_ServerBroadcast( msg )

    // Check if we have enough votes
    if ( currentVotes >= votesNeeded )
    {
        StartRTV()
    }
}

function GetRTVVoteCount()
{
    // Count votes from players who are still connected
    local validVotes = 0
    local currentPlayerIds = []

    foreach ( player in GetPlayerArray() )
    {
        currentPlayerIds.append( player.GetUserId() )
    }

    foreach ( playerId, voted in rtvState.votes )
    {
        if ( ArrayContains( currentPlayerIds, playerId ) )
            validVotes++
    }

    return validVotes
}

function CalculateRTVVotesNeeded()
{
    local playerCount = GetPlayerArray().len()
    local needed = (playerCount * RTV_PERCENTAGE_NEEDED).tointeger()

    if ( needed == 0 )
        needed = 1

    return needed
}

function StartRTV()
{
    rtvState.hasVoteStarted = true

    Chat_ServerBroadcast( "RTV vote passed! Starting map vote..." )
    printt("[RTV] Vote passed, starting map vote")

    // Start map vote (implemented in sv_mapvote.nut)
    thread StartMapVote( true ) // true = is RTV
}

function ResetRTV()
{
    rtvState.votes = {}
    rtvState.hasVoteStarted = false
    rtvState.nextVoteTime = Time() + RTV_COOLDOWN
    printt("[RTV] Vote state reset, cooldown active")
}

// Called when a player disconnects
function RTV_OnPlayerDisconnected( player )
{
    local playerId = player.GetUserId()

    if ( playerId in rtvState.votes )
        delete rtvState.votes[playerId]

    // Check if we still have enough votes
    if ( !rtvState.hasVoteStarted && rtvState.votes.len() > 0 )
    {
        local currentVotes = GetRTVVoteCount()
        local votesNeeded = CalculateRTVVotesNeeded()

        if ( currentVotes >= votesNeeded )
        {
            StartRTV()
        }
    }
}

// Called on map start
function RTV_OnMapStart()
{
    rtvState.votes = {}
    rtvState.hasVoteStarted = false
    rtvState.changeInProgress = false
    rtvState.allowed = false
    thread DelayRTVAvailability()
    printt("[RTV] State reset for new map")
}

// Helper function for broadcasting chat messages
function Chat_ServerBroadcast( message )
{
    if ( "LSendChatMsg" in getroottable() )
    {
        LSendChatMsg( true, 0, message, false, false )
    }
    else
    {
        // Fallback: send to all players individually
        foreach ( player in GetPlayerArray() )
        {
            Chat_ServerPrivateMessage( player, message, false )
        }
    }
}

function Chat_ServerPrivateMessage( player, message, isTeam )
{
    if ( "LSendChatMsg" in getroottable() )
    {
        LSendChatMsg( player, 0, message, isTeam, false )
    }
    else if ( "SendChatMsg" in getroottable() )
    {
        SendChatMsg( player, 0, message, isTeam, false )
    }
}

// Admin command to force RTV
function ForceRTV( player, args, returnfunc )
{
    if ( rtvState.hasVoteStarted )
    {
        returnfunc( player, "Map vote is already in progress!", false )
        return true
    }

    Chat_ServerBroadcast( player.GetPlayerName() + " forced a map vote!" )
    StartRTV()
    return true
}

// Globalize functions
Globalize(InitRTV)
Globalize(RTV_OnChatMessage)
Globalize(AttemptRTV)
Globalize(GetRTVVoteCount)
Globalize(CalculateRTVVotesNeeded)
Globalize(StartRTV)
Globalize(ResetRTV)
Globalize(RTV_OnPlayerDisconnected)
Globalize(RTV_OnMapStart)
Globalize(Chat_ServerBroadcast)
Globalize(Chat_ServerPrivateMessage)
Globalize(ForceRTV)
