function main()
{
	if ( IsServer() )
	{
		level.musicEvents <- {}
		level.musicEvents[ TEAM_IMC ] <- {}
		level.musicEvents[ TEAM_MILITIA ] <- {}

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

function CreateLevelWinnerDeterminedMusicEvent()
{
	//printt( "Creating CreateLevelWinnerDeterminedMusicEvent" )

	local winningTeam = GetWinningTeam()

	if (GetTeamIndex(winningTeam))
	{
		local losingTeam = GetOtherTeams(winningTeam)
		CreateTeamMusicEvent( GetTeamIndex(winningTeam) + 1, eMusicPieceID.LEVEL_WIN, Time() )
		CreateTeamMusicEvent( GetTeamIndex(losingTeam) + 1, eMusicPieceID.LEVEL_LOSS, Time() )
	}
	else
	{
		CreateTeamMusicEvent( TEAM_MILITIA, eMusicPieceID.LEVEL_DRAW, Time() )
		CreateTeamMusicEvent( TEAM_IMC, eMusicPieceID.LEVEL_DRAW, Time() )
	}
}
