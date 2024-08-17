function GameRules_ChangeMap( mapName, mode )
{
	if( ';' in mode || ' ' in mode)
		return

	if( ';' in mapName || ' ' in mapName)
		return

	ServerCommand( "launchplaylist " + mode )
	ServerCommand( "changelevel " + mapName )
}

function GameRules_EndMatch()
{
    if( IsPrivateMatch() )
    {
        GameRules_ChangeMap( "mp_lobby", "private_match" )
    } else
    {
        ServerCommand( "changelevel mp_lobby" )
    }
}

function main()
{
    Globalize( GameRules_EndMatch )
    Globalize( GameRules_ChangeMap )
}