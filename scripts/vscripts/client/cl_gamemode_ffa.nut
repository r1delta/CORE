
function main()
{
	AddCreateCallback( "titan_cockpit", FFAHudInit )
}

function FFAHudInit( cockpit, isRecreate )
{
	local player = GetLocalViewPlayer()
	local vgui = cockpit.s.mainVGUI

	// Why the fuck is this running twice??????
	if ( "ffa_what" in vgui.s )
		return

	local panel = vgui.s.panel
	local scoreBars = vgui.s.scoreboardProgressBars

	// Cant use GetPlayerName for the text since it looks weird
	scoreBars.Friendly_Team.DisableAutoText()
	scoreBars.Friendly_Team.SetText( "#KILLREPLAY_YOU" )

	scoreBars.Enemy_Team.DisableAutoText()
	scoreBars.Enemy_Team.SetText( "" )

	scoreBars.GameInfo_Icon.Hide()

	local group = HudElementGroup( "FFACharGroup" )
	local frame = group.CreateElement( "CoopCharFrame", panel )
	local icon 	= group.CreateElement( "CoopCharIcon", panel )

	icon.SetImage( GetCharacterFaceImage( player ) )
	group.Show()

	vgui.s.ffaGroup <- group

	thread FFAHudThink( player, cockpit )

	vgui.s.ffa_what <- true
}

function FFAHudThink( player, cockpit )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	cockpit.EndSignal( "OnDestroy" )

	while ( true )
	{
		UpdateFFAScoreBars()
		wait 0.1
	}
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

	local players = GetSortedPlayers( GetScoreboardCompareFunc(), null )
	if ( players.len() == 0 )
		return

	local frameImage = "HUD/empty"
	local playerSpot
	for ( local i = 0; i < players.len(); i++ )
	{
		if ( player == players[i] )
		{
			playerSpot = i + 1
			break
		}
	}

	if ( playerSpot < 5 )
		frameImage = "HUD/coop/coop_char_frame_p" + playerSpot

	local group = vgui.s.ffaGroup
	group.GetElement( "CoopCharFrame" ).SetImage( frameImage )
	group.GetElement( "CoopCharIcon" ).SetImage( GetCharacterFaceImage( player ) )
}

main()
