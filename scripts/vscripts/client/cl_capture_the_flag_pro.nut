
function main()
{
	IncludeFile( "client/cl_capture_the_flag" )

	if ( IsLobby() )
		return

	RegisterServerVarChangeCallback( "gameState", CTFP_GameStateChanged )
}

function CTFP_GameStateChanged()
{
	if ( GetGameState() <= eGameState.Playing )
	{
		CE_ResetVisualSettings( GetLocalViewPlayer() )
	}
}

main()
