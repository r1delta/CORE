const EXFIL_GRACEPERIOD = 60.0

function main()
{
	Assert( !GetCinematicMode(), "Cannot play exfil in cinematic mode" )

	level.nv.eliminationMode = eEliminationMode.Pilots
	FlagSet( "PilotBot" )
	//FlagSet( "ForceStartSpawn" )
	SetRoundBased( true )
	SetAttackDefendBased( true )

	FlagInit( "DefendersWinDraw" )

	AddCallback_GameStateEnter( eGameState.Playing, ExfilPlaying )
	GM_AddStartRoundFunc( ExfilRoundStart )
	GM_AddEndRoundFunc( ExfilRoundEnd )

	level.exfilPanels <- []
	level.nv.attackingTeam = TEAM_IMC

	WaitEndFrame() // _evac runs later than it should
	FlagClear( "EvacEndsMatch" )

}


function EntitiesDidLoad()
{
	local exfilPanels = GetEntArrayByClass_Expensive( "prop_exfil_panel" )

	if ( !exfilPanels.len() )
	{
		local attackerStartOrigin = Vector( 0, 0, 0 )
		local attackerStartSpawns = GetEntArrayByClass_Expensive( "info_spawnpoint_human_start" )
		Assert( attackerStartSpawns.len() )
		foreach ( spawnpoint in attackerStartSpawns )
		{
			if ( spawnpoint.GetTeam() != level.nv.attackingTeam )
				continue

			attackerStartOrigin += spawnpoint.GetOrigin()
		}

		attackerStartOrigin.x /= attackerStartSpawns.len()
		attackerStartOrigin.y /= attackerStartSpawns.len()
		attackerStartOrigin.z /= attackerStartSpawns.len()

		local hardpoints = ArrayFarthest( GetEntArrayByClass_Expensive( "info_hardpoint" ), attackerStartOrigin )

		foreach ( hardpoint in hardpoints )
		{
			local panel = CreateEntity( "prop_control_panel" )
			panel.kv.model = "models/communication/terminal_usable_imc_01.mdl"
			panel.kv.solid = 2

			panel.SetName( level.exfilPanels.len() ? "exfil_panel_b" : "exfil_panel_a" )
			DispatchSpawn( panel, false )

			panel.s.escapeNode <- null

			panel.SetOrigin( hardpoint.GetOrigin() )

			panel.SetTeam(GetOtherTeam(level.nv.attackingTeam))
			panel.UnsetUsable()

			thread ExfilPanelThink( panel )

			level.exfilPanels.append( panel )

			if ( level.exfilPanels.len() >= 2 )
				break
		}
	}
	else
	{
		foreach ( levelPanel in exfilPanels )
		{
			local panel = CreateEntity( "prop_control_panel" )
			panel.kv.model = "models/communication/terminal_usable_imc_01.mdl"
			panel.kv.solid = 1

			panel.SetName( level.exfilPanels.len() ? "exfil_panel_b" : "exfil_panel_a" )
			DispatchSpawn( panel, false )

			local escapeNode = GetEnt( levelPanel.kv.target )
			panel.s.escapeNode <- escapeNode

			panel.SetOrigin( levelPanel.GetOrigin() )
			panel.SetAngles( levelPanel.GetAngles() )
			levelPanel.Destroy()

			panel.SetTeam(GetOtherTeam(level.nv.attackingTeam))
			panel.UnsetUsable()

			thread ExfilPanelThink( panel )

			level.exfilPanels.append( panel )

			if ( level.exfilPanels.len() >= 2 )
				break
		}
	}

	SetupAssaultPointKeyValues()
	thread SetupTeamDeathmatchNPCs()
}


function ExfilPanelThink( panel )
{
	while( true )
	{
		panel.WaitSignal( "PanelReprogram_Success" )

		if ( level.nv.exfilState )
			continue

		level.nv.exfilState = 1

		foreach ( exfilPanel in level.exfilPanels )
		{
			exfilPanel.UnsetUsable()
		}

		Evac_SetDropshipArrivalWaitTime( 30.0 )
		thread EvacOnDemand(GetOtherTeam(level.nv.attackingTeam), panel.s.escapeNode )
	}
}

function ExfilPlaying()
{
	thread ExfilPlayingThink()
}

function ExfilPlayingThink()
{
	if ( Time() >= level.nv.secondsTitanCheckTime && !level.nv.exfilState )
	{
		level.nv.exfilState = true
		level.nv.secondsTitanCheckTime = null

		//thread ExfiltrationEvacMain( TEAM_MILITIA )
	}
}


function ExfilRoundStart()
{
	local startTime = IsRoundBased() ? level.nv.roundStartTime : level.nv.gameStartTime

	level.nv.secondsTitanCheckTime = null//startTime + EXFIL_GRACEPERIOD
	level.nv.exfilState = 0

	foreach ( exfilPanel in level.exfilPanels )
	{
		exfilPanel.SetUsableByGroup( "enemies pilot" )
		exfilPanel.SetTeam(GetOtherTeam(level.nv.attackingTeam))
	}

	SetGlobalForcedDialogueOnly( false ) //Reset from evac from previous round
	foreach( player in GetPlayerArray() )
	{
		SetPlayerForcedDialogueOnly( player, false )
	}

	ClearTeamActiveObjective( TEAM_IMC )
	ClearTeamActiveObjective( TEAM_MILITIA )

	//FlagClear( "EvacAnimStart" )
	//FlagClear( "EvacShipArrive" )
	//FlagClear( "EvacShipLeave" )
	FlagClear( "EvacFinished" )
	//FlagClear( "PlayPostEvacDialogue" )
	//FlagClear( "EvacKillProximityConversationThread" )
}

function ExfilRoundEnd()
{
	FlagSet( "EvacFinished" )
}

function ExfilTimeLimitComplete()
{

}
