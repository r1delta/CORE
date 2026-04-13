function GameRules_ChangeMap( mapName, mode )
{
	if( ';' in mode || ' ' in mode)
		return

	if( ';' in mapName || ' ' in mapName)
		return

    if( IsPrivateMatch() )
        ServerCommand( "playlist " + mode )

    ServerCommand( "mp_gamemode " + mode )
    ServerCommand( "changelevel " + mapName )
}

function GameRules_ChangeCampaignMap( mapName, modeName = null )
{
	// we need to get gamemode, mv does not want to hardcode maps and gamemodes here so we're grabbing off playlist
	local gamemodeForMap = null
	for (local i = 0; i < GetMapCountForPlaylist(modeName); i++) {
		if (GetPlaylistMapByIndex(modeName, i) == mapName)
			gamemodeForMap = GetPlaylistGamemodeByIndex(modeName, i)
	}
	ServerCommand( "playlist " + modeName )
	ServerCommand( "mp_gamemode " + gamemodeForMap )
	ServerCommand( "changelevel " + mapName )
}

function GameRules_PickRandomMap()
{
    local combos = GetPlaylistCombos( GetCurrentPlaylistName())
    local rand = combos[ RandomInt( 0, combos.len() - 1 )]
    GameRules_ChangeMap( rand.mapName, rand.modeName )
}


function GameRules_EndMatch()
{
    if( IsPrivateMatch() )
	    ServerCommand("playlist private_match")

    if(!GetConVarBool("delta_return_to_lobby")) {
        GameRules_PickRandomMap()
        return
    }

    ServerCommand( "changelevel mp_lobby" )
}

function main()
{
    Globalize( GameRules_EndMatch )
    Globalize( GameRules_ChangeMap )
    Globalize( GameRules_ChangeCampaignMap )
}
