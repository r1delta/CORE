const EXFIL_GRACEPERIOD = 60.0

function main()
{
	Assert( !GetCinematicMode(), "Cannot play exfil in cinematic mode" )

	level.nv.eliminationMode = eEliminationMode.Pilots
	FlagSet( "PilotBot" )
	FlagSet( "ForceStartSpawn" )
	SetRoundBased( true )

	GM_AddPlayingThinkFunc( ExfilPlayingThink )
	GM_AddStartRoundFunc( ExfilRoundStart )
	GM_AddEndRoundFunc( ExfilRoundEnd )

	SetGameModeAnnouncement( "GameModeAnnounce_TDM" ) 	//TODO: Change to real value when it is ready

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

			panel.SetTeam(GetTeamIndex(GetOtherTeams(1 << level.nv.attackingTeam)))
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

			panel.SetTeam(GetTeamIndex(GetOtherTeams(1 << level.nv.attackingTeam)))
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
		thread ExfiltrationEvacMain(GetTeamIndex(GetOtherTeams(1 << level.nv.attackingTeam)), panel.s.escapeNode )
	}
}


function ExfilPlayingThink()
{
	/*
	if ( Time() >= level.nv.secondsTitanCheckTime && !level.nv.exfilState )
	{
		level.nv.exfilState = true
		level.nv.secondsTitanCheckTime = null

		thread ExfiltrationEvacMain( TEAM_MILITIA )
	}
	*/
}


function ExfilRoundStart()
{
	local startTime = IsRoundBased() ? level.nv.roundStartTime : level.nv.gameStartTime

	level.nv.secondsTitanCheckTime = null//startTime + EXFIL_GRACEPERIOD
	level.nv.exfilState = 0

	foreach ( exfilPanel in level.exfilPanels )
	{
		exfilPanel.SetUsableByGroup( "enemies pilot" )
		exfilPanel.SetTeam(GetTeamIndex(GetOtherTeams(1 << level.nv.attackingTeam)))
	}

	if ( IsValid( level.dropship ) )
		level.dropship.Destroy()

	FlagClear( "EvacAnimStart" )
	FlagClear( "EvacShipArrive" )
	FlagClear( "EvacShipLeave" )
	FlagClear( "EvacFinished" )
	FlagClear( "PlayPostEvacDialogue" )
	FlagClear( "EvacKillProximityConversationThread" )

	// meh defensive
	ClearTeamActiveObjective( TEAM_IMC )
	ClearTeamActiveObjective( TEAM_MILITIA )
}

function ExfilRoundEnd()
{
	ClearTeamActiveObjective( TEAM_IMC )
	ClearTeamActiveObjective( TEAM_MILITIA )
}

function ExfilTimeLimitComplete()
{

}
