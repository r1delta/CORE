function main()
{
	if ( IsServer() )
	{
		level.musicEvents <- {}
		level.musicEvents[ TEAM_IMC ] <- {}
		level.musicEvents[ TEAM_MILITIA ] <- {}
		level.winnerDeterminedMusicEvent <- null

		Globalize( CreateTeamMusicEvent )
		Globalize( PlayCurrentTeamMusicEventsOnPlayer )

		Globalize( CreateLevelIntroMusicEvent )
		Globalize( CreateLevelWinnerDeterminedMusicEvent )

		GM_AddPreMatchFunc( CreateLevelIntroMusicEvent )
	}

}

function CreateTeamMusicEvent( team, musicPieceID, timeMusicStarted, shouldSeek = true )
{
	//printt( "Creating TeamMusicEvent. Team: " + team + ", musicPieceID: " + musicPieceID + ", timeMusicStarted: " + timeMusicStarted )

	Assert( !( shouldSeek == false && timeMusicStarted > 0 ), "Don't pass in timeMusicStarted when creating a TeamMusicEvent with shouldSeek set to false!" )

	local musicEvent = {}
	musicEvent.musicPieceID 	<- musicPieceID
	musicEvent.timeMusicStarted <- timeMusicStarted
	musicEvent.shouldSeek <- shouldSeek

	level.musicEvents[ team ] = musicEvent
}

function PlayCurrentTeamMusicEventsOnPlayer( player )
{
	if ( IsFFABased() && level.winnerDeterminedMusicEvent != null )
	{
		PlayLevelWinnerDeterminedMusicEventOnPlayer( player )
		return
	}

	//printt( "PlayCurrentTeamMusicEventsOnPlayer" )
	local team = player.GetTeam()
	local musicEvent = level.musicEvents[ team ]
	if (  musicEvent.len() == 0 ) //No current music event
		return

	Remote.CallFunction_NonReplay( player, "ServerCallback_PlayTeamMusicEvent", musicEvent.musicPieceID, musicEvent.timeMusicStarted, musicEvent.shouldSeek )
}

function CreateLevelIntroMusicEvent()
{
	//printt( "Creating LevelIntroMusicEvent" )
	CreateTeamMusicEvent( TEAM_IMC, eMusicPieceID.LEVEL_INTRO, Time() )
	CreateTeamMusicEvent( TEAM_MILITIA, eMusicPieceID.LEVEL_INTRO, Time() )
}

function PlayLevelWinnerDeterminedMusicEventOnPlayer( player )
{
	local musicPieceID
	if ( level.winningPlayer == null )
		musicPieceID = eMusicPieceID.LEVEL_DRAW
	else if ( player == level.winningPlayer )
		musicPieceID = eMusicPieceID.LEVEL_WIN
	else
		musicPieceID = eMusicPieceID.LEVEL_LOSS

	local musicEvent = level.winnerDeterminedMusicEvent
	Remote.CallFunction_NonReplay( player, "ServerCallback_PlayTeamMusicEvent", musicPieceID, musicEvent.timeMusicStarted, musicEvent.shouldSeek )
}

function CreateLevelWinnerDeterminedMusicEvent()
{
	//printt( "Creating CreateLevelWinnerDeterminedMusicEvent" )

	if ( IsFFABased() )
	{
		level.winnerDeterminedMusicEvent = {
			timeMusicStarted = Time(),
			shouldSeek = true
		}

		foreach ( player in GetPlayerArray() )
			PlayLevelWinnerDeterminedMusicEventOnPlayer( player )

		return
	}
	local winningTeam = GetWinningTeam()

	if (winningTeam)
	{
		local losingTeam = GetOtherTeam(winningTeam)
		printt( "Winning team: " + winningTeam + ", losing team: " + losingTeam )
		CreateTeamMusicEvent( winningTeam, eMusicPieceID.LEVEL_WIN, Time() )
		CreateTeamMusicEvent( losingTeam, eMusicPieceID.LEVEL_LOSS, Time() )
	}
	else
	{
		CreateTeamMusicEvent( TEAM_MILITIA, eMusicPieceID.LEVEL_DRAW, Time() )
		CreateTeamMusicEvent( TEAM_IMC, eMusicPieceID.LEVEL_DRAW, Time() )
	}
}
