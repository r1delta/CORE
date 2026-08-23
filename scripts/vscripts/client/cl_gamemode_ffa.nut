
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

	local leadingOpponent = GetLeadingOpponent( player )

	local cockpit = player.GetCockpit()
	if ( !cockpit )
		return

	local vgui = cockpit.GetMainVGUI()
	if ( !vgui )
		return

	local scoreBars = vgui.s.scoreboardProgressBars

	local playerScore = player.GetAssaultScore()
	local winnerScore = ""
	local scoreLimit = GetScoreLimit_FromPlaylist().tofloat()

	local playerProgress = GraphCapped( playerScore.tofloat(), 0.0, scoreLimit, 0.0, scoreLimit )
	local winnerProgress = 0

	if ( leadingOpponent )
	{
		winnerScore = leadingOpponent.GetAssaultScore()
		winnerProgress = GraphCapped( winnerScore.tofloat(), 0.0, scoreLimit, 0.0, scoreLimit )
	}

	scoreBars.ScoresFriendly.SetBarProgressSource( ProgressSource.PROGRESS_SOURCE_SCRIPTED )
	scoreBars.ScoresFriendly.SetBarProgress( playerProgress )
	scoreBars.Friendly_Number.SetText( playerScore.tostring() )

	scoreBars.ScoresEnemy.SetBarProgressSource( ProgressSource.PROGRESS_SOURCE_SCRIPTED )
	scoreBars.ScoresEnemy.SetBarProgress( winnerProgress )
	scoreBars.Enemy_Number.SetText( winnerScore.tostring() )

	if ( leadingOpponent )
		scoreBars.Enemy_Team.SetText( leadingOpponent.GetPlayerName() )
	else
		scoreBars.Enemy_Team.SetText( "#STATS_NOT_APPLICABLE" )
}

main()
