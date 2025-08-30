
function main()
{
	AddCreateCallback( "titan_cockpit", FFAHudInit )
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

	thread FFAHudThink( player, cockpit, vgui, scoreBars )
}

function FFAHudThink( player, cockpit, vgui, scoreBars )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	cockpit.EndSignal( "OnDestroy" )

    local ffaTeam = player.GetTeam()
    local compareFunc = GetScoreboardCompareFunc()
	local playersArray = GetSortedPlayers( compareFunc, ffaTeam )
	local localPlayerPlacement = GetIndexInArray( playersArray, player )

	local winningPlayer

	// The idea here is to eventually make scorebars track player kills instead of TeamScore
	while ( true )
	{
		playersArray = GetSortedPlayers( compareFunc, ffaTeam )
		localPlayerPlacement = GetIndexInArray( playersArray, player )

		foreach ( otherPlayer in GetPlayerArray() )
		{
			if ( GetIndexInArray( playersArray, otherPlayer ) == 0 )
				winningPlayer = otherPlayer
		}

		if ( player == winningPlayer )
		{
			scoreBars.Enemy_Team.SetText( "#CHALLENGE_GAMES_MVP" ) // RANKED_PLAY_ADVOCATE_LINE3 // DAILYCHALLENGE_PET_TITAN_KILLS_GUARD_MODE
		}
		else
		{
			scoreBars.Enemy_Team.SetText( "#CHALLENGE_GAMES_MVP" )
		}

		wait 1.0
	}
}

main()
