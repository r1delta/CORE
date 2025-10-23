// ============================================================================
// sv_nominate.nut
// Map nomination system for r1delta
// ============================================================================

// Nomination state
::nominateState <- {
    nominations = {}, // mapName -> count
    playerNominations = {} // playerId -> mapName
}

function InitNominate()
{
    // Register chat command handler
    AddCallback_OnClientChatMsg( Nominate_OnChatMessage )
    printt("[Nominate] System initialized")
}

function Nominate_OnChatMessage( playerIndex, message, isTeamChat )
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

    // Extract command and args from message
    local commandText = message.slice( messageStart, message.len() )
    local args = split( commandText, " " )

    if ( args.len() == 0 )
        return message

    local command = args[0].tolower()

    // Check if it's a nominate command
    if ( command != "nominate" && command != "nom" )
        return message

    // Get player entity
    local player = GetEntByIndex( playerIndex )
    if ( !IsValid( player ) )
        return message

    // Execute nominate command
    args.remove(0)
    NominateMap( player, args )

    // Block the chat message
    return ""
}

function NominateMap( player, args )
{
    // No args - show paginated menu of all maps
    if ( args.len() == 0 )
    {
        ShowNominateMenu( player, 0 )
        return
    }

    // Combine args into search string
    local searchTerm = ""
    foreach ( arg in args )
        searchTerm += arg + " "
    searchTerm = searchTerm.slice( 0, searchTerm.len() - 1 ).tolower()

    // Find matching maps (fuzzy search on both code name and friendly name)
    local matchingMaps = []
    foreach ( mapKey, mapName in MAP_NAMES )
    {
        // Check if search term is in the code name (e.g., "o2" matches "mp_o2")
        if ( mapKey.tolower().find( searchTerm ) != null )
            matchingMaps.append( mapKey )
        // Check if search term is in the friendly name (e.g., "demeter" matches "Demeter")
        else if ( mapName.tolower().find( searchTerm ) != null )
            matchingMaps.append( mapKey )
    }

    if ( matchingMaps.len() == 0 )
    {
        Chat_ServerPrivateMessage( player, "No maps found matching '" + searchTerm + "'", false )
        return
    }

    if ( matchingMaps.len() > 1 )
    {
        local matchList = ""
        local maxShow = 5
        for ( local i = 0; i < matchingMaps.len() && i < maxShow; i++ )
        {
            matchList += MAP_NAMES[matchingMaps[i]]
            if ( i < matchingMaps.len() - 1 && i < maxShow - 1 )
                matchList += ", "
        }
        Chat_ServerPrivateMessage( player, "Multiple matches (" + matchingMaps.len() + "): " + matchList, false )
        return
    }

    local nominatedMap = matchingMaps[0]

    // Check if map is in current rotation
    local playlist = GetCurrentPlaylistName()
    local playlistMaps = GetPlaylistUniqueMaps( playlist )
    if ( !ArrayContains( playlistMaps, nominatedMap ) )
    {
        Chat_ServerPrivateMessage( player, MAP_NAMES[nominatedMap] + " is not in the current rotation", false )
        return
    }

    // Check if it's the current map
    if ( nominatedMap == GetMapName() )
    {
        Chat_ServerPrivateMessage( player, "Cannot nominate the current map", false )
        return
    }

    // Remove previous nomination if exists
    local playerId = player.GetUserId()
    if ( playerId in nominateState.playerNominations )
    {
        local oldMap = nominateState.playerNominations[playerId]
        if ( oldMap in nominateState.nominations )
        {
            nominateState.nominations[oldMap]--
            if ( nominateState.nominations[oldMap] <= 0 )
                delete nominateState.nominations[oldMap]
        }
    }

    // Add new nomination
    nominateState.playerNominations[playerId] <- nominatedMap
    if ( !(nominatedMap in nominateState.nominations) )
        nominateState.nominations[nominatedMap] <- 0
    nominateState.nominations[nominatedMap]++

    Chat_ServerBroadcast( player.GetPlayerName() + " nominated " + MAP_NAMES[nominatedMap] + " (" + nominateState.nominations[nominatedMap] + " votes)" )
}

function GetNominatedMaps()
{
    // Sort nominations by vote count
    local sortedMaps = []

    foreach ( mapName, count in nominateState.nominations )
    {
        sortedMaps.append( { map = mapName, count = count } )
    }

    // Bubble sort by count (descending)
    for ( local i = 0; i < sortedMaps.len() - 1; i++ )
    {
        for ( local j = 0; j < sortedMaps.len() - i - 1; j++ )
        {
            if ( sortedMaps[j].count < sortedMaps[j + 1].count )
            {
                local temp = sortedMaps[j]
                sortedMaps[j] = sortedMaps[j + 1]
                sortedMaps[j + 1] = temp
            }
        }
    }

    local result = []
    foreach ( entry in sortedMaps )
        result.append( entry.map )

    return result
}

function Nominate_OnMapStart()
{
    nominateState.nominations = {}
    nominateState.playerNominations = {}
    printt("[Nominate] Nominations reset for new map")
}

function Nominate_OnPlayerDisconnected( player )
{
    local playerId = player.GetUserId()

    if ( playerId in nominateState.playerNominations )
    {
        local nominatedMap = nominateState.playerNominations[playerId]
        if ( nominatedMap in nominateState.nominations )
        {
            nominateState.nominations[nominatedMap]--
            if ( nominateState.nominations[nominatedMap] <= 0 )
                delete nominateState.nominations[nominatedMap]
        }
        delete nominateState.playerNominations[playerId]
    }
}
function ShowNominateMenu( player, page )
{
    // Get only maps in current playlist rotation
    local playlist = GetCurrentPlaylistName()
    local playlistMaps = GetPlaylistUniqueMaps( playlist )
    local availableMaps = []

    foreach ( mapKey in playlistMaps )
    {
        // Skip lobby and current map
        if ( mapKey == "mp_lobby" || mapKey == GetMapName() )
            continue
        if ( mapKey in MAP_NAMES )
            availableMaps.append( mapKey )
    }

    // Paging model: page 0 has up to 8 maps, subsequent pages up to 7 maps
    local N = availableMaps.len()
    local firstCap = 8
    local otherCap = 7

    local totalPages = (N <= firstCap) ? 1 : 1 + ((N - firstCap + otherCap - 1) / otherCap)

    if ( totalPages <= 0 )
        totalPages = 1

    // Normalize requested page
    if ( page < 0 )
        page = totalPages - 1
    else if ( page >= totalPages )
        page = 0

    // Compute slice
    local startIdx, cap
    if ( page == 0 )
    {
        startIdx = 0
        cap = firstCap
    }
    else
    {
        startIdx = firstCap + (page - 1) * otherCap
        cap = otherCap
    }
    local endIdx = startIdx + cap
    if ( endIdx > N )
        endIdx = N

    // Build menu
    local menuText = "Nominate Map (Page " + (page + 1) + "/" + totalPages + "):\n\n"
    local menuOptions = []
    local keysMask = 0

    for ( local i = startIdx; i < endIdx; i++ )
    {
        local mapKey = availableMaps[i]
        local displayName = MAP_NAMES[mapKey]
        local optionNum = (i - startIdx) + 1 // 1..cap (max 8 on first, 7 otherwise)
        menuText += "->" + optionNum + ". " + displayName + "\n"
        menuOptions.append( mapKey )
        keysMask = keysMask | (1 << (optionNum - 1)) // bits 0..(cap-1)
    }

    // Navigation: 8=Prev (only if page>0), 9=Next (only if page<last), 0=Cancel always
    if ( page > 0 )
    {
        menuText += "->8. Previous Page\n"
        keysMask = keysMask | (1 << 7) // key 8
    }

    if ( page < totalPages - 1 )
    {
        menuText += "->9. Next Page\n"
        keysMask = keysMask | (1 << 8) // key 9
    }

    menuText += "->0. Cancel\n"
    keysMask = keysMask | (1 << 9) // key 0

    // Store context
    SetPlayerMenuContext( player, 3, { options = menuOptions, page = page, totalPages = totalPages } )

    // Send menu
    SendShowMenu( player, menuText, keysMask, 60 )
}

function HandleNominateMenuSelection( player, selection, data )
{
    // 0 key = cancel
    if ( selection == 10 )
    {
        Chat_ServerPrivateMessage( player, "Nomination cancelled", false )
        return true // Clear menu context
    }

    local totalPages = ("totalPages" in data) ? data.totalPages : 1

    // 8 key = previous page (only valid when page > 0)
    if ( selection == 8 && data.page > 0 )
    {
        ShowNominateMenu( player, data.page - 1 )
        return false // Keep context for pagination
    }

    // 9 key = next page (only valid when not on last page)
    if ( selection == 9 && data.page < totalPages - 1 )
    {
        ShowNominateMenu( player, data.page + 1 )
        return false // Keep context for pagination
    }

    // Otherwise, treat as map selection
    local voteIndex = selection - 1
    if ( voteIndex < 0 || voteIndex >= data.options.len() )
    {
        printt("[Nominate] Invalid selection:", selection)
        return
    }

    local nominatedMap = data.options[voteIndex]

    // Check if map is in current rotation
    local playlist = GetCurrentPlaylistName()
    local playlistMaps = GetPlaylistUniqueMaps( playlist )
    if ( !ArrayContains( playlistMaps, nominatedMap ) )
    {
        Chat_ServerPrivateMessage( player, MAP_NAMES[nominatedMap] + " is not in the current rotation", false )
        return
    }

    // Check if it's the current map
    if ( nominatedMap == GetMapName() )
    {
        Chat_ServerPrivateMessage( player, "Cannot nominate the current map", false )
        return
    }

    // Remove previous nomination if exists
    local playerId = player.GetUserId()
    if ( playerId in nominateState.playerNominations )
    {
        local oldMap = nominateState.playerNominations[playerId]
        if ( oldMap in nominateState.nominations )
        {
            nominateState.nominations[oldMap]--
            if ( nominateState.nominations[oldMap] <= 0 )
                delete nominateState.nominations[oldMap]
        }
    }

    // Add new nomination
    nominateState.playerNominations[playerId] <- nominatedMap
    if ( !(nominatedMap in nominateState.nominations) )
        nominateState.nominations[nominatedMap] <- 0
    nominateState.nominations[nominatedMap]++

    Chat_ServerBroadcast( player.GetPlayerName() + " nominated " + MAP_NAMES[nominatedMap] + " (" + nominateState.nominations[nominatedMap] + " votes)" )
    printt("[Nominate]", player.GetPlayerName(), "nominated", nominatedMap)

    return true // Clear menu context after actual nomination
}


// Globalize functions
Globalize(InitNominate)
Globalize(Nominate_OnChatMessage)
Globalize(NominateMap)
Globalize(ShowNominateMenu)
Globalize(GetNominatedMaps)
Globalize(Nominate_OnMapStart)
Globalize(Nominate_OnPlayerDisconnected)
Globalize(HandleNominateMenuSelection)
