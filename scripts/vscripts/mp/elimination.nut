/*
Current Status:
	- Used to be functional, but needs tweaking. See WaitForPanelUseSignal() below for details.

Game Mode Info:
	- There are two terminals on the map.  See mp_box.nut.  Set "mp_gamemode elim" to see terminals in mp_box.
	- Everyone on the Attacking team (MILITIA) gets a Data Knife.
	- Everyone gets one life per round.
	- To win the round, the Attacking team must hack one of the terminals and defend it for 45 seconds.  Or kill all Defenders.
	- To win the round, the Defending team must kill all Attackers.
	- Defending team can unhack terminals in the 45 second time window.
	- Game is over after a team wins 4 rounds (out of 7)

Left TODO for playtest/prototype:
	- Pick two hardpoints to be used as positions for terminals - Hardpoint B and whichever is closest to the defender spawn.
	- Show icons above terminals
	- Show terminals on minimap
	- Escalating VO & SFX for final 45 seconds
	- VO to guide players
*/
function main()
{
	SetRoundBased( true )

	//GM_SetGetWinnerFunc( ELIM_GetWinner )

	SetGameModeAnnouncement( "GameModeAnnounce_TDM" ) 	//TODO: Change to real value when it is ready

	level.elimAttackTeam <- TEAM_MILITIA
	level.elimDefendTeam <- TEAM_IMC
	level.elimWinningTeam <- TEAM_UNASSIGNED
}

function GetGametypeText()
{
	return "Elimination"
}

// DISABLED because it no longer works
function ScriptCallback_OnPlayerScore( player, score )
{
	GameScore.AddTeamScore( player.GetTeam(), score )
}

function EntitiesDidLoad()
{
	printt("EntitiesDidLoad")
	thread WaitTillRoundStart()
}


function ResetGameMode()
{
	foreach( panel in level.controlPanels )
	{
		panel.SetTeam( level.elimDefendTeam )
		SetPanelUsableToEnemies( panel )
		thread WaitForPanelUseSignal( panel )
	}

	foreach( rushPanel in level.rushPanels )
	{
		rushPanel.SetTeam( level.elimDefendTeam )
		SetRushPanelUsableToEnemies( rushPanel )
		thread WaitForPanelUseSignal( rushPanel )
	}

	foreach( BBPanel in level.BBPanels )
	{
		BBPanel.SetTeam( level.elimDefendTeam )
		SetBBPanelUsableToEnemies( BBPanel )
		thread WaitForPanelUseSignal( BBPanel )
	}

	thread WaitTillRoundEnd()
}


function ELIM_GetWinner()
{
	if( level.elimWinningTeam > TEAM_UNASSIGNED )
	{
		return level.elimWinningTeam
	}

	return false
}


// NOTE:  This depends on PanelFlipsToPlayerTeamAndUsableByEnemies() being called to set the panels team before this is called.
// It used to be in PlayerUsesControlPanel() before sending the PanelReprogram_Success signal, but was rmeoved to keep that more generic.
//
// TODO:  Hook this up via AddControlPanelUseFuncTable like in _ai_turret.LinkToControlPanel() instead of waiting for the signal
function WaitForPanelUseSignal( panel )
{
	//level.ent.EndSignal( "GameEnd" )               //TODO: Find a good way to end this function

	for(;;)
	{
		panel.WaitSignal( "PanelReprogram_Success" )

		if( panel.GetTeam() == level.elimAttackTeam )
		{
			thread FuseTimer( panel );
		}
	}
}


function FuseTimer( panel )
{
	panel.EndSignal( "PanelReprogram_Success" )   	 // Cancel timer if the enemy defuses
	wait ELIMINATION_FUSE_TIME;
	level.elimWinningTeam = panel.GetTeam()
}


function WaitTillRoundStart()
{
	//level.ent.EndSignal( "GameEnd" )               //TODO: Find a good way to end this function

	for(;;)
	{
		level.ent.WaitSignal( "RoundStart" )
		thread ResetGameMode()
	}
}


function WaitTillRoundEnd()
{
	level.ent.WaitSignal( "RoundEnd" )
	level.elimWinningTeam = TEAM_UNASSIGNED
}
