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

function GameRules_EndMatch()
{
    if( IsPrivateMatch() )
	    ServerCommand("playlist private_match")

    ServerCommand( "changelevel mp_lobby" )
}

function main()
{
    Globalize( GameRules_EndMatch )
    Globalize( GameRules_ChangeMap )
}
