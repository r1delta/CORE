// ============================================================================
// sv_mapvote.nut
// Map voting system with gamemode voting for r1delta
// ============================================================================

// Vote Configuration
const VOTE_DURATION = 20 // Seconds
const VOTE_MAP_OPTIONS = 6 // Number of map options to show
const VOTE_GAMEMODE_OPTIONS = 4 // Number of gamemode options to show
const VOTE_WARNING_TIME = 5 // Seconds before vote to warn players

// Vote State
::mapVoteState <- {
    active = false,
    isRTV = false,
    selectedGamemode = "",
    votes = {},
    options = [],
    endTime = 0,
    warningTime = 0
}

// Map display names
::MAP_NAMES <- {
    mp_airbase = "Airbase",
    mp_angel_city = "Angel City",
    mp_boneyard = "Boneyard",
    mp_colony = "Colony",
    mp_corporate = "Corporate",
    mp_fracture = "Fracture",
    mp_lagoon = "Lagoon",
    mp_nexus = "Nexus",
    mp_outpost_207 = "Outpost 207",
    mp_overlook = "Overlook",
    mp_relic = "Relic",
    mp_rise = "Rise",
    mp_smugglers_cove = "Smuggler's Cove",
    mp_training_ground = "Training Ground",
    mp_wargames = "War Games",
    mp_runoff = "Runoff",
    mp_swampland = "Swampland",
    mp_haven = "Haven",
    mp_switchback = "Export",
    mp_backwater = "Backwater",
    mp_sandtrap = "Sand Trap",
    mp_harmony_mines = "Dig Site",
    mp_zone_18 = "Zone 18",
    mp_mia = "M.I.A",
    mp_nest2 = "Nest 2",
    mp_box = "Box",
    mp_npe = "Training",
    mp_o2 = "Demeter",
    mp_lobby = "Lobby"
}

// Gamemode display names
::GAMEMODE_NAMES <- {
    tdm = "Team Deathmatch",
    aitdm = "Attrition",
    cp = "Hardpoint",
    ctf = "Capture the Flag",
    lts = "Last Titan Standing",
    mfd = "Marked for Death",
    speedball = "Speedball",
    ttdm = "Titan Deathmatch"
}

function InitMapVote()
{
    // Register chat command handler for revote
    AddCallback_OnClientChatMsg( MapVote_OnChatMessage )
    printt("[MapVote] System initialized")
}

function MapVote_OnChatMessage( playerIndex, message, isTeamChat )
{
    // Check if message starts with ! or t!
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

    // Check if it's a revote command
    if ( command != "revote" )
        return message

    // Get player entity
    local player = GetEntByIndex( playerIndex )
    if ( !IsValid( player ) )
        return message

    // Execute revote command
    RevoteMap( player )

    // Block the chat message
    return ""
}

// Revote function - brings back the current vote menu if one is active
function RevoteMap( player )
{
    if ( !mapVoteState.active )
    {
        Chat_ServerPrivateMessage( player, "No vote is currently in progress", false )
        return
    }

    // Resend the current vote menu to the player
    local menuText = "Vote for Map"
    if ( mapVoteState.selectedGamemode != "" )
        menuText += " (" + GetGamemodeDisplayName( mapVoteState.selectedGamemode ) + ")"
    menuText += ":\\n\\n"

    local keysMask = 0

    for ( local i = 0; i < mapVoteState.options.len(); i++ )
    {
        local mapName = mapVoteState.options[i]
        local displayName = GetMapDisplayName( mapName )
        menuText += "->" + (i + 1) + ". " + displayName + "\\n"
        keysMask = keysMask | (1 << i)
    }

    // Update player's menu context
    SetPlayerMenuContext( player, 2, { options = mapVoteState.options, gamemode = mapVoteState.selectedGamemode } )

    // Send menu with remaining time
    local timeRemaining = mapVoteState.endTime - Time()
    if ( timeRemaining <= 0 )
        timeRemaining = 1

    SendShowMenu( player, menuText, keysMask, timeRemaining )

    Chat_ServerPrivateMessage( player, "Vote menu reopened - you can change your vote", false )
}

function StartMapVote( isRTV = false )
{
    if ( mapVoteState.active )
    {
        printt("[MapVote] Vote already in progress")
        return
    }

    mapVoteState.isRTV = isRTV
    mapVoteState.active = true
    mapVoteState.votes = {}

    local playlist = GetCurrentPlaylistName()
    local modes = GetPlaylistUniqueModes( playlist )

    printt("[MapVote] Starting vote, playlist:", playlist, "modes:", modes.len())

    // Check if we need to do gamemode vote first
    if ( modes.len() > 1 )
    {
        // Multiple gamemodes - show gamemode vote first
        ShowGamemodeVote( modes )
    }
    else
    {
        // Single gamemode - go straight to map vote
        mapVoteState.selectedGamemode = modes[0]
        ShowMapVote( modes[0] )
    }
}

function ShowGamemodeVote( gamemodes )
{
    printt("[MapVote] Showing gamemode vote, options:", gamemodes.len())

    // Limit to configured number of options
    local modeOptions = []
    local optionCount = min( gamemodes.len(), VOTE_GAMEMODE_OPTIONS )

    for ( local i = 0; i < optionCount; i++ )
    {
        modeOptions.append( gamemodes[i] )
    }

    mapVoteState.options = modeOptions
    mapVoteState.votes = {}
    mapVoteState.endTime = Time() + VOTE_DURATION

    // Build menu text
    local menuText = "Vote for Gamemode:\n\n"
    local keysMask = 0

    for ( local i = 0; i < modeOptions.len(); i++ )
    {
        local modeName = modeOptions[i]
        local displayName = GetGamemodeDisplayName( modeName )
        menuText += "->" + (i + 1) + ". " + displayName + "\n"
        keysMask = keysMask | (1 << i)
    }

    // Send menu to all players
    local players = GetPlayerArray()
    foreach ( player in players )
    {
        SetPlayerMenuContext( player, 1, { options = modeOptions } )
    }

    SendShowMenu( true, menuText, keysMask, VOTE_DURATION )

    // Announce vote
    Chat_ServerBroadcast( "Voting for gamemode! Press 1-" + modeOptions.len() + " to vote." )

    // Start timer to check results
    thread MonitorVoteCompletion( true ) // true = gamemode vote
}

function ShowMapVote( gamemode )
{
    printt("[MapVote] Showing map vote for gamemode:", gamemode)

    mapVoteState.selectedGamemode = gamemode

    // Get available maps for this gamemode
    local availableMaps = GetMapsForGamemode( gamemode )

    // Sort by least played
    local sortedMaps = SortMapsByLeastPlayed( availableMaps, gamemode )

    // Select top options
    local mapOptions = []
    local optionCount = min( sortedMaps.len(), VOTE_MAP_OPTIONS )

    for ( local i = 0; i < optionCount; i++ )
    {
        mapOptions.append( sortedMaps[i] )
    }

    mapVoteState.options = mapOptions
    mapVoteState.votes = {}
    mapVoteState.endTime = Time() + VOTE_DURATION

    // Build menu text
    local menuText = "Vote for Map"
    if ( gamemode != "" )
        menuText += " (" + GetGamemodeDisplayName( gamemode ) + ")"
    menuText += ":\n\n"

    local keysMask = 0

    for ( local i = 0; i < mapOptions.len(); i++ )
    {
        local mapName = mapOptions[i]
        local displayName = GetMapDisplayName( mapName )
        menuText += "->" + (i + 1) + ". " + displayName + "\n"
        keysMask = keysMask | (1 << i)
    }

    // Send menu to all players
    local players = GetPlayerArray()
    foreach ( player in players )
    {
        SetPlayerMenuContext( player, 2, { options = mapOptions, gamemode = gamemode } )
    }

    SendShowMenu( true, menuText, keysMask, VOTE_DURATION )

    // Announce vote
    Chat_ServerBroadcast( "Voting for map! Press 1-" + mapOptions.len() + " to vote." )

    // Start timer to check results
    thread MonitorVoteCompletion( false ) // false = map vote
}

function MonitorVoteCompletion( isGamemodeVote )
{
    local endTime = mapVoteState.endTime

    while ( Time() < endTime )
    {
        wait 1

        // Check if all players have voted
        local allVoted = true
        foreach ( player in GetPlayerArray() )
        {
            if ( !(player.GetUserId() in mapVoteState.votes) )
            {
                allVoted = false
                break
            }
        }

        if ( allVoted )
        {
            printt("[MapVote] All players voted, ending early")
            break
        }
    }

    // Process results
    if ( isGamemodeVote )
        ProcessGamemodeVoteResults()
    else
        ProcessMapVoteResults()
}

function ProcessGamemodeVoteResults()
{
    local results = TallyVotes( mapVoteState.options )

    if ( results.winnerIndex == -1 )
    {
        // No votes - pick random
        results.winnerIndex = RandomInt( mapVoteState.options.len() )
        printt("[MapVote] No gamemode votes, selected random")
    }

    local selectedMode = mapVoteState.options[results.winnerIndex]
    mapVoteState.selectedGamemode = selectedMode

    Chat_ServerBroadcast( GetGamemodeDisplayName( selectedMode ) + " won the gamemode vote!" )

    wait 2

    // Now show map vote
    ShowMapVote( selectedMode )
}

function ProcessMapVoteResults()
{
    local results = TallyVotes( mapVoteState.options )

    if ( results.winnerIndex == -1 )
    {
        // No votes - pick random
        results.winnerIndex = RandomInt( mapVoteState.options.len() )
        printt("[MapVote] No map votes, selected random")
    }

    local selectedMap = mapVoteState.options[results.winnerIndex]
    local selectedMode = mapVoteState.selectedGamemode

    Chat_ServerBroadcast( GetMapDisplayName( selectedMap ) + " won the vote!" )

    wait 2

    // Change map
    ChangeToMap( selectedMap, selectedMode )
}

function TallyVotes( options )
{
    local voteCounts = []
    for ( local i = 0; i < options.len(); i++ )
    {
        voteCounts.append( 0 )
    }

    // Count votes
    foreach ( playerId, voteIndex in mapVoteState.votes )
    {
        if ( voteIndex >= 0 && voteIndex < voteCounts.len() )
            voteCounts[voteIndex]++
    }

    // Find winner
    local maxVotes = 0
    local winnerIndex = -1

    for ( local i = 0; i < voteCounts.len(); i++ )
    {
        if ( voteCounts[i] > maxVotes )
        {
            maxVotes = voteCounts[i]
            winnerIndex = i
        }
    }

    printt("[MapVote] Vote results:", voteCounts, "winner:", winnerIndex)

    return {
        voteCounts = voteCounts,
        winnerIndex = winnerIndex,
        maxVotes = maxVotes
    }
}

function ChangeToMap( mapName, gamemode )
{
    printt("[MapVote] Changing to", mapName, gamemode)

    Chat_ServerBroadcast( "Changing to " + GetMapDisplayName( mapName ) + "..." )

    if ( mapVoteState.isRTV )
    {
        // RTV - change immediately
        GameRules_ChangeMap( mapName, gamemode )
    }
    else
    {
        // Regular vote - change at map end
        // Store for use at map end
        if ( !("nextMapVote" in level) )
            level.nextMapVote <- {}

        level.nextMapVote.map <- mapName
        level.nextMapVote.mode <- gamemode
    }

    mapVoteState.active = false

    if ( "rtvState" in getroottable() )
    {
        rtvState.changeInProgress = true
    }
}

function GetMapsForGamemode( gamemode )
{
    local playlist = GetCurrentPlaylistName()
    local combos = GetPlaylistCombos( playlist )
    local maps = []

    foreach ( combo in combos )
    {
        if ( combo.modeName == gamemode && !ArrayContains( maps, combo.mapName ) )
        {
            // Exclude current map
            if ( combo.mapName != GetMapName() )
                maps.append( combo.mapName )
        }
    }

    printt("[MapVote] Found", maps.len(), "maps for gamemode", gamemode)

    return maps
}

function SortMapsByLeastPlayed( maps, gamemode )
{
    local players = GetPlayerArray()
    if ( players.len() == 0 )
    {
        // No players - shuffle randomly
        return ShuffleArray( maps )
    }

    // Calculate average play counts for each map
    local mapPlayCounts = {}

    foreach ( mapName in maps )
    {
        local totalPlays = 0
        local validPlayers = 0

        foreach ( player in players )
        {
            if ( !IsValid( player ) || player.IsBot() )
                continue

            local plays = GetMapPlayCount( player, mapName, gamemode )
            totalPlays += plays
            validPlayers++
        }

        local avgPlays = validPlayers > 0 ? (totalPlays.tofloat() / validPlayers) : 0
        mapPlayCounts[mapName] <- avgPlays
    }

    // Sort maps by average play count using bubble sort (closure capture issues in r1delta)
    for ( local i = 0; i < maps.len() - 1; i++ )
    {
        for ( local j = 0; j < maps.len() - i - 1; j++ )
        {
            local playsA = (maps[j] in mapPlayCounts) ? mapPlayCounts[maps[j]] : 0
            local playsB = (maps[j + 1] in mapPlayCounts) ? mapPlayCounts[maps[j + 1]] : 0

            if ( playsA > playsB )
            {
                local temp = maps[j]
                maps[j] = maps[j + 1]
                maps[j + 1] = temp
            }
        }
    }

    printt("[MapVote] Sorted maps by least played")

    return maps
}

function GetMapPlayCount( player, mapName, gamemode )
{
    if ( !IsValid( player ) )
        return 0

    // Try to get specific gamemode play count
    local key = "mapStats[" + mapName + "].gamesCompleted[" + gamemode + "]"
    local count = player.GetPersistentVar( key )

    if ( count == null )
        count = 0

    return count.tointeger()
}

function GetMapDisplayName( mapName )
{
    if ( mapName in MAP_NAMES )
        return MAP_NAMES[mapName]

    return mapName
}

function GetGamemodeDisplayName( gamemode )
{
    if ( gamemode in GAMEMODE_NAMES )
        return GAMEMODE_NAMES[gamemode]

    return gamemode
}

function ShuffleArray( arr )
{
    local shuffled = clone arr

    for ( local i = shuffled.len() - 1; i > 0; i-- )
    {
        local j = RandomInt( i + 1 )
        local temp = shuffled[i]
        shuffled[i] = shuffled[j]
        shuffled[j] = temp
    }

    return shuffled
}

// Menu selection handlers (called from sv_menuselect_handler.nut)
function HandleGamemodeVoteSelection( player, selection, data )
{
    local playerId = player.GetUserId()

    // Convert menu selection (1-based) to array index (0-based)
    local voteIndex = selection - 1

    if ( voteIndex < 0 || voteIndex >= data.options.len() )
    {
        printt("[MapVote] Invalid gamemode selection:", selection)
        return
    }

    // Record vote
    mapVoteState.votes[playerId] <- voteIndex

    local modeName = data.options[voteIndex]
    Chat_ServerPrivateMessage( player, "You voted for: " + GetGamemodeDisplayName( modeName ), false )

    printt("[MapVote]", player.GetPlayerName(), "voted for gamemode", modeName)
}

function HandleMapVoteSelection( player, selection, data )
{
    local playerId = player.GetUserId()

    // Convert menu selection (1-based) to array index (0-based)
    local voteIndex = selection - 1

    if ( voteIndex < 0 || voteIndex >= data.options.len() )
    {
        printt("[MapVote] Invalid map selection:", selection)
        return
    }

    // Record vote
    mapVoteState.votes[playerId] <- voteIndex

    local mapName = data.options[voteIndex]
    Chat_ServerPrivateMessage( player, "You voted for: " + GetMapDisplayName( mapName ), false )

    printt("[MapVote]", player.GetPlayerName(), "voted for map", mapName)
}

// Called at map end to apply voted map
function MapVote_OnMapEnd()
{
    if ( "nextMapVote" in level && !mapVoteState.isRTV )
    {
        local mapName = level.nextMapVote.map
        local gamemode = level.nextMapVote.mode

        printt("[MapVote] Applying vote result at map end:", mapName, gamemode)
        GameRules_ChangeMap( mapName, gamemode )
    }
    else
    {
        // No vote result - normal behavior
        GameRules_EndMatch()
    }
}

// Min function helper
function min( a, b )
{
    return a < b ? a : b
}

// Globalize functions
Globalize(InitMapVote)
Globalize(MapVote_OnChatMessage)
Globalize(StartMapVote)
Globalize(ShowGamemodeVote)
Globalize(ShowMapVote)
Globalize(HandleGamemodeVoteSelection)
Globalize(HandleMapVoteSelection)
Globalize(MapVote_OnMapEnd)
Globalize(RevoteMap)
Globalize(GetMapDisplayName)
Globalize(GetGamemodeDisplayName)
