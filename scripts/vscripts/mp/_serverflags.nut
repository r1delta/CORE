Assert( IsServer() )

function main()
{
	Globalize( GiveServerFlag )
	Globalize( TakeServerFlag )
	Globalize( PlayerHasServerFlag )
}

function GiveServerFlag( player, passive )
{
	if ( !( player.serverFlags & passive ) )
	{
		player.serverFlags = player.serverFlags | passive
	}

	// enter/exit functions for specific passives
	switch ( passive )
	{
		case SFLAG_BC_FAST_MOVESPEED:
			player.UpdateMoveSpeedScale()
			break
	}
}

function TakeServerFlag( player, passive )
{
	if ( !PlayerHasServerFlag( player, passive ) )
		return

	player.serverFlags = player.serverFlags & ( ~passive )

	// enter/exit functions for specific passives
	switch ( passive )
	{
		case SFLAG_BC_FAST_MOVESPEED:
			player.UpdateMoveSpeedScale()
			break
	}

}

function PlayerHasServerFlag( player, passive )
{
	return player.serverFlags & passive
}
