// ============================================================================
// sv_menuselect_handler.nut
// Handles menuselect commands for all menu-based voting systems
// ============================================================================

// Global menu context tracking
// playerMenuContexts[playerIndex] = { type = 0, data = {} }
// type: 0 = none, 1 = gamemode vote, 2 = map vote, 3 = nominate menu
::playerMenuContexts <- {}

function InitMenuSelectHandler()
{
    AddClientCommandCallback( "menuselect", ClientCommand_MenuSelect )
    printt("[MenuSelect] Handler initialized")
}

function ClientCommand_MenuSelect( player, ... )
{
    if ( vargc != 1 )
    {
        printt("[MenuSelect] Invalid argument count")
        return false
    }

    local selection = vargv[0].tointeger()
    if ( selection == null )
    {
        printt("[MenuSelect] Invalid selection value")
        return false
    }

    local playerIndex = player.GetEntIndex()

    // Check if player has an active menu context
    if ( !(playerIndex in playerMenuContexts) )
    {
        printt("[MenuSelect] No active menu context for player", player.GetPlayerName())
        return true
    }

    local context = playerMenuContexts[playerIndex]

    // Route to appropriate handler based on menu type
    local shouldClearContext = true

    switch ( context.type )
    {
        case 1: // Gamemode vote
            HandleGamemodeVoteSelection( player, selection, context.data )
            break
        case 2: // Map vote
            HandleMapVoteSelection( player, selection, context.data )
            break
        case 3: // Nominate menu
            shouldClearContext = HandleNominateMenuSelection( player, selection, context.data )
            break
        default:
            printt("[MenuSelect] Unknown menu type:", context.type)
            break
    }

    // Clear menu context after processing (if handler says it's ok)
    if ( shouldClearContext )
        delete playerMenuContexts[playerIndex]

    return true
}

function SetPlayerMenuContext( player, menuType, data )
{
    local playerIndex = player.GetEntIndex()

    if ( !(playerIndex in playerMenuContexts) )
    {
        playerMenuContexts[playerIndex] <- {
            type = 0,
            data = {}
        }
    }

    playerMenuContexts[playerIndex].type = menuType
    playerMenuContexts[playerIndex].data = data
}

function ClearPlayerMenuContext( player )
{
    local playerIndex = player.GetEntIndex()
    if ( playerIndex in playerMenuContexts )
        delete playerMenuContexts[playerIndex]
}

// Globalize functions
Globalize(InitMenuSelectHandler)
Globalize(SetPlayerMenuContext)
Globalize(ClearPlayerMenuContext)

