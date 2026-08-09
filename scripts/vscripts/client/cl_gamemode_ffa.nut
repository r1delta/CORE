
function main()
{
	AddCreateCallback( "titan_cockpit", FFAHudInit )
	AddOnDeathOrDestroyCallback( "player", FFA_PlayerDied )
}

function FFAHudInit( cockpit, isRecreate )
{
	local player = GetLocalViewPlayer()

	local vgui = cockpit.s.mainVGUI
	local scoreBars = vgui.s.scoreboardProgressBars

	// Cant use GetPlayerName for the text since it looks weird
	scoreBars.Friendly_Team.DisableAutoText()
	scoreBars.Friendly_Team.SetText( "#KILLREPLAY_YOU" )

	scoreBars.Enemy_Team.DisableAutoText()
	scoreBars.Enemy_Team.SetText( "" )

	thread FFAHudThink( player, cockpit, vgui, scoreBars )
}

function FFAHudThink( player, cockpit, vgui, scoreBars )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	cockpit.EndSignal( "OnDestroy" )

	while ( true )
	{
		UpdateFFAScoreBars()
		wait 1.0
	}
}

function FFA_PlayerDied( player )
{
	UpdateFFAScoreBars()
}

function UpdateFFAScoreBars()
{
	local player = GetLocalViewPlayer()
	if ( !player )
		return

	local leadingOpponent = null
	local players = GetSortedPlayers( GetScoreboardCompareFunc(), null )
	foreach ( candidate in players )
	{
		if ( candidate == player )
			continue

		leadingOpponent = candidate
		break
	}
	local cockpit = player.GetCockpit()
	if ( !cockpit )
		return

	local vgui = cockpit.GetMainVGUI()
	if ( !vgui )
		return

	local scoreBars = vgui.s.scoreboardProgressBars

	local playerScore = player.GetAssaultScore()
	local winnerScore = 0
	local scoreLimit = GetScoreLimit_FromPlaylist().tofloat()

	if ( leadingOpponent )
		winnerScore = leadingOpponent.GetAssaultScore()

	// BAR DOESNT WORK
	scoreBars.ScoresFriendly.SetBarProgressSource( ProgressSource.PROGRESS_SOURCE_SCRIPTED )
	//scoreBars.ScoresFriendly.SetBarProgressRemap( 0, playerScore, 0.011, 0.96 )
	scoreBars.ScoresFriendly.SetBarProgress( playerScore.tofloat() / scoreLimit )
	scoreBars.Friendly_Number.SetText( playerScore.tostring() )

	scoreBars.ScoresEnemy.SetBarProgressSource( ProgressSource.PROGRESS_SOURCE_SCRIPTED )
	//scoreBars.ScoresEnemy.SetBarProgressRemap( 0, winnerScore, 0.011, 0.96 )
	scoreBars.ScoresEnemy.SetBarProgress( winnerScore.tofloat() / scoreLimit )
	scoreBars.Enemy_Number.SetText( winnerScore.tostring() )

	if ( leadingOpponent )
		scoreBars.Enemy_Team.SetText( leadingOpponent.GetPlayerName() )
	else
		scoreBars.Enemy_Team.SetText( "" )
}

main()
