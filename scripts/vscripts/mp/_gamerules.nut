function GameRules_ChangeMap( mapName, mode )
{
	if( ';' in mode || ' ' in mode)
		return

	if( ';' in mapName || ' ' in mapName)
		return

    if( IsPrivateMatch() )
    {
        local playlistName = mode
        if ( mode == CAPTURE_THE_TITAN || mode == GUN_GAME )
            playlistName = "private_match"

        ServerCommand( "playlist " + playlistName )
    }

    ServerCommand( "mp_gamemode " + mode )
    ServerCommand( "changelevel " + mapName )
}

function GameRules_ChangeCampaignMap( mapName, playlistName )
{
	local playlistCombos = GetPlaylistCombos( playlistName )
	local matchingCombos = []
	foreach ( combo in playlistCombos )
	{
		if ( combo.mapName == mapName )
			matchingCombos.append( combo )
	}

	if ( matchingCombos.len() == 0 )
	{
		if ( playlistCombos.len() == 0 )
		{
			printt( "No playlist modes found for", playlistName )
			return
		}

		printt( "No", playlistName, "playlist modes found for", mapName, "- selecting a random playlist map instead" )
		matchingCombos = playlistCombos
	}

	local combo = matchingCombos[ RandomInt( 0, matchingCombos.len() - 1 ) ]
	ServerCommand( "playlist " + playlistName )
	ServerCommand( "mp_gamemode " + combo.modeName )
	ServerCommand( "changelevel " + combo.mapName )
}

function GameRules_PickRandomMap()
{
	local playlistName = GetCurrentPlaylistName()
	local combos = GetPlaylistCombos( playlistName )
	if ( combos.len() == 0 )
		return

	local combo = combos[ RandomInt( 0, combos.len() - 1 ) ]
	if ( IsMultiGamemodePlaylist( playlistName ) )
	{
		ServerCommand( "playlist " + playlistName )
		ServerCommand( "mp_gamemode " + combo.modeName )
		ServerCommand( "changelevel " + combo.mapName )
		return
	}

	GameRules_ChangeMap( combo.mapName, combo.modeName )
}


function GameRules_EndMatch()
{
	local playlistName = GetCurrentPlaylistName()
	if ( !GetConVarBool( "delta_return_to_lobby" ) )
	{
		GameRules_PickRandomMap()
		return
	}

	if ( IsPrivateMatch() )
	{
		ServerCommand( "playlist private_match" )
		if ( IsMultiGamemodePlaylist( playlistName ) )
			ServerCommand( "mp_gamemode " + playlistName )
	}

	ServerCommand( "changelevel mp_lobby" )
}

function main()
{
    Globalize( GameRules_EndMatch )
    Globalize( GameRules_ChangeMap )
    Globalize( GameRules_ChangeCampaignMap )
}
