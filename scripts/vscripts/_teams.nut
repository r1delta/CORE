if ( IsMultiplayer() )
{
	// IsFFABased() causes errors here too
	if ( ( GAMETYPE == COOPERATIVE && GetCurrentPlaylistName() == COOPERATIVE ) || ( GAMETYPE == FFA && GetCurrentPlaylistName() == FFA ) )
	{
		// all on one team
		level.minTeamSize <- GetCurrentPlaylistVarInt( "min_players", 2 )
		level.maxTeamSize <- GetCurrentPlaylistVarInt( "max players", 6 )
	}
	else
	{
		level.minTeamSize <- GetCurrentPlaylistVarInt( "min_players", 2 ) / 2
		level.maxTeamSize <- GetCurrentPlaylistVarInt( "max players", 12 ) / 2
	}
}

function main()
{
	Globalize( GetPlayerTitansOnTeam )
	Globalize( GetPlayerTitansReadyOnTeam )
	Globalize( IsTeamFull )
}


// Counts all alive player piloted titans and pet titans
function GetPlayerTitansOnTeam( team )
{
	PerfStart( 92 )
	local teamTitans = []
	local players = []

	if ( IsClient() )
		players = GetPlayerArrayOfTeam( team )
	else
		players = GetConnectingAndConnectedPlayerArray()

	foreach ( player in players )
	{
		if ( player.GetTeam() == team )
		{
			if ( player.IsTitan() && IsAlive( player ) )
				teamTitans.append( player )
			else if ( IsAlive( player.GetPetTitan() ) )
				teamTitans.append( player.GetPetTitan() )
		}
	}

	PerfEnd( 92 )
	return teamTitans
}


function GetPlayerTitansReadyOnTeam( team )
{
	local teamTitansReady = []
	local players = []

	if ( IsClient() )
		players = GetPlayerArrayOfTeam( team )
	else
		players = GetConnectingAndConnectedPlayerArray()

	foreach ( player in players )
	{
		if ( player.GetTeam() != team )
			continue

		if ( player.IsTitan() && IsAlive( player ) )
			continue

		if ( IsAlive( player.GetPetTitan() ) )
			continue

		if ( player.GetNextTitanRespawnAvailable() < 0 )
			continue

		if ( Time() < player.GetNextTitanRespawnAvailable() )
			continue

		if ( player.GetNextTitanRespawnAvailable() >= 999999 )
			continue

		if ( !IsAlive( player ) && IsPlayerEliminated( player ) )
			continue

		teamTitansReady.append( player )
	}

	return teamTitansReady
}

function IsTeamFull( team )
{
	return ( GetTeamPlayerCount( team ) >= level.maxTeamSize )
}