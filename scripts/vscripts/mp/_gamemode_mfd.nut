function main()
{
	Globalize( MFD_OnPlayerOrNPCKilled )

	AddCallback_PlayerOrNPCKilled( MFD_OnPlayerOrNPCKilled )
	level.spawnRatingFunc_Pilot = RateFrontLinePlayerSpawnpoint
	level.spawnRatingFunc_Generic = RateFrontLinePlayerSpawnpoint


	level.mfdAssault <- {}
	level.mfdAssault[ TEAM_IMC ] <- null
	level.mfdAssault[ TEAM_MILITIA ] <- null

	file.teams <- [ TEAM_IMC, TEAM_MILITIA ]

	AddCallback_GameStateEnter( eGameState.Playing, MARKED_FOR_DEATH_PlayingStart )
	AddCallback_OnPlayerRespawned( MARKED_FOR_DEATH_PlayerRespawned )
	AddCallback_OnClientConnected( MARKED_FOR_DEATH_AddPlayer )
	GM_AddEndRoundFunc( MARKED_FOR_DEATH_EndRoundFunc )
	AddCallback_OnClientDisconnected( MARKED_FOR_DEATH_PlayerDisconnected )

	AddSpawnCallback( "npc_spectre", MFDSpawnMinion )
	AddSpawnCallback( "npc_soldier", MFDSpawnMinion )

	AddSpawnCallback( MARKER_ENT_CLASSNAME, SpawnMarkerEnt )
	FlagSet( "PilotBot" )

	RegisterSignal( "StopReceivingScoreBonus" )
	RegisterSignal( "UpdateMarkedPlayers" )
	RegisterSignal( "PendingMarkedDisconnected" )

	AddPostEntityLoadCallback( CreateMFDAssaultPoints )

	AddCallback_OnTitanBecomesPilot( UpdateMinimapForMarkedOnClassChange )
	AddCallback_OnPilotBecomesTitan( UpdateMinimapForMarkedOnClassChange )

	GM_AddEndRoundFunc( MFD_RoundEnd )
}

function SpawnMarkerEnt( ent )
{
	FillMFDMarkers( ent )
}

function CreateMFDAssaultPoint( team )
{
	local point = CreateEntity( "assault_assaultpoint" )

	point.kv.stopToFightEnemyRadius = 5
	point.kv.allowdiversionradius = 200
	point.kv.allowdiversion = 0
	point.kv.faceAssaultPointAngles = 1
	point.kv.assaulttolerance = 120
	point.kv.nevertimeout = 1
	point.kv.strict = 1
	point.kv.forcecrouch = 1
	point.kv.spawnflags = 0
	point.kv.clearoncontact = 0
	point.kv.assaulttimeout = 999
	point.kv.arrivaltolerance = 350
	point.SetTeam( team )
	DispatchSpawn( point, true )

	level.mfdAssault[ team ] = point
}

function CreateMarkerEntsOnServer( team )
{
	local markedEnt = CreateEntity( MARKER_ENT_CLASSNAME )
	markedEnt.SetOrigin( Vector(0,0,0) )
	markedEnt.SetTeam( team )
	markedEnt.SetName( MARKET_ENT_MARKED_NAME )
	markedEnt.kv.spawnflags = 3 //Transmit to client
	DispatchSpawn( markedEnt, true )

	local pendingMarkedEnt = CreateEntity( MARKER_ENT_CLASSNAME )
	pendingMarkedEnt.SetOrigin( Vector(0,0,0) )
	pendingMarkedEnt.SetTeam( team )
	pendingMarkedEnt.SetName( MARKET_ENT_PENDING_MARKED_NAME )
	pendingMarkedEnt.kv.spawnflags = 3 //Transmit to client
	DispatchSpawn( pendingMarkedEnt, true )
}

function CreateMFDAssaultPoints()
{
	CreateMFDAssaultPoint( TEAM_MILITIA )
	CreateMFDAssaultPoint( TEAM_IMC )
}

function EntitiesDidLoad()
{
	CreateMarkerEntsOnServer( TEAM_MILITIA )
	CreateMarkerEntsOnServer( TEAM_IMC )
	//printl("running EntitiesDidLoad() in team_deathmatch.nut" )
	//SetupAssaultPointKeyValues()

	//monitor population and respawns
	thread SetupTeamDeathmatchNPCs()
}

function MFDSpawnMinion( minion )
{
	local team = minion.GetTeam()
	if ( team == TEAM_UNASSIGNED )
		return

	minion.AssaultPointEnt( level.mfdAssault[ team ] )
}

function MARKED_FOR_DEATH_AddPlayer( player )
{
	player.s.skippedForTargetCount <- GetInitialSkippedTargetCount() // lets player skip some rounds after connecting
}

function MARKED_FOR_DEATH_PlayerDisconnected( player )
{
	if ( player == GetPendingMarked( player.GetTeam() ) )
	{
		//printt( "Pending marked player disconnected" )
		ClearPendingMarkedPlayers()
		MessageToAll( eEventNotifications.MarkedForDeathMarkedDisconnected )
		level.ent.Signal( "PendingMarkedDisconnected" )
		thread DelayUpdateMarkedPlayers() //Necessary due to timing issues
		return
	}

	if ( player == GetMarked( player.GetTeam() ) )
	{
		//printt( "Marked player disconnected" )
		ClearMarkedPlayers()
		TellClientsMarkedChanged()
		MessageToAll( eEventNotifications.MarkedForDeathMarkedDisconnected )
	}

	UpdateMarkedPlayers()
}

function MARKED_FOR_DEATH_PlayerRespawned( player )
{
	if ( player == GetPendingMarked( player.GetTeam() ) )
		SetMinimapMaterialsForPendingMarked( player )

	UpdateMarkedPlayers()
}

function MARKED_FOR_DEATH_EndRoundFunc()
{
	UpdateMarkedPlayers()
}

function MARKED_FOR_DEATH_PrematchStart()
{
	/*if ( IsRoundBased() ) //LTS Variant
		FlagClear( "ForceStartSpawn" )*/
}

function MARKED_FOR_DEATH_PlayingStart()
{
	/*if ( IsRoundBased() ) //LTS Variant
		FlagSet( "ForceStartSpawn" )*/
	thread MarkPlayersForDeath()
	UpdateMarkedPlayers()
}

function DelayUpdateMarkedPlayers( delayTime = 0 )
{
	wait delayTime
	UpdateMarkedPlayers()
}

function UpdateMarkedPlayers()
{
	level.ent.Signal( "UpdateMarkedPlayers" )
}

function MarkPlayersForDeath()
{
	for ( ;; )
	{
		if ( !GamePlaying() )
		{
			ClearMarkedPlayers()
			return
		}

		if ( ShouldPickNewMarks() )
		{
			ClearPendingMarkedPlayers()
			ClearMarkedPlayers()
			TellClientsMarkedChanged()

			if ( ShouldWaitToPickMarks() )
				wait MFD_BETWEEN_MARKS_TIME

			waitthread TryMarkingPlayers()
			//printt( "Finished Try Marking Players" )
		}

		//printt( "Before check WaitingForMarkedToSpawn" )

		if ( WaitingForMarkedToSpawn() ) //Player we picked was dead upon picking, wait until he respawned or disconnected
		{
			MessageToAll( eEventNotifications.MarkedForDeathWaitingForMarkedToSpawn )
			while( WaitingForMarkedToSpawn()  )
			{
				//printt( "Still Waiting For Marked To Spawn" )
				TellClientsMarkedChanged()
				level.ent.WaitSignal( "UpdateMarkedPlayers" ) //Consume all the signals until we are ready to actually SetMarked targets
			}

			if ( ShouldMarkPendingMarkedPlayers() ) //Need to check again since players could have disconnected between being pending marked
				SetMarked()
		}

		//printt( "Waiting for UpdateMarkedPlayers!" )
		level.ent.WaitSignal( "UpdateMarkedPlayers" )
		//printt( "Got Signal for UpdateMarkedPlayers!" )
	}
}

function ShouldWaitToPickMarks() //Function's main purpose is to see if we should wait longer to pick marks for MFD Pro
{
	if ( !IsRoundBased() )
		return true

	if ( GetRoundsPlayed() == 0 )
		return true

	if ( IsFirstRoundAfterSwitchingSides() )
		return true

	return false
}

function ShouldPickNewMarks()
{
	if( !GamePlaying() )
		return false

	if ( IsAlive( GetMarked( TEAM_IMC ) ) && IsAlive( GetMarked( TEAM_MILITIA ) ) )
		return false

	if ( IsRoundBased() && IsWatchingRoundWinningKillReplay() )
		return false

	foreach ( team in file.teams )
	{
		if ( GetPlayerArrayOfTeam( team ).len() == 0 )
			return false
	}

	return true

}

function ShouldMarkPendingMarkedPlayers()
{
	if ( !GamePlaying() )
		return false

	local pendingMarkedPlayerTable = GetPendingMarks()

	foreach( team, player in pendingMarkedPlayerTable )
	{
		if ( !IsAlive( player ) )
			return false
	}

	return true
}


function WaitingForMarkedToSpawn()
{
	local imcPendingMarked = GetPendingMarked( TEAM_IMC )
	local militiaPendingMarked = GetPendingMarked( TEAM_MILITIA )
	if ( IsValid( imcPendingMarked ) && !IsAlive( imcPendingMarked ) )
	{
		//printt( "Waiting for imc Pending Marked" )
		return true
	}

	if ( IsValid( militiaPendingMarked ) && !IsAlive( militiaPendingMarked ) )
	{
		//printt( "Waiting for milita pending marked" )
		return true
	}

	return false
}

function SetPendingMarkedPlayers()
{
	local pendingMarksTable = GetPlayersToMarkTable()

	foreach ( team in file.teams )
	{
		local pendingMarked = pendingMarksTable[ team ]
		level.mfdPendingMarkedPlayerEnt[ team ].SetBossPlayer( pendingMarked )
		SetMinimapMaterialsForPendingMarked( pendingMarked )
	}

	TellClientsMarkedChanged()
}


function TryMarkingPlayers()
{
	if ( !ShouldPickNewMarks() )
	{
		//printt( "TryMarkingPlayers: return false with ShouldPickNewMarks" )
		return
	}

	SetPendingMarkedPlayers()

	local imcMark = GetPendingMarked( TEAM_IMC )
	local militiaMark = GetPendingMarked( TEAM_MILITIA )

	local countDownTime
	if ( ShouldWaitToPickMarks() )
		countDownTime = MFD_COUNTDOWN_TIME
	else
		countDownTime = MFDP_COUNTDOWN_TIME

	local timeWhenNextMarkedIsSet = Time() + countDownTime

	//Tell pending marks they will be marked soon
	MessageToPlayer( imcMark, eEventNotifications.MarkedForDeathYouWillBeMarkedNext, null, timeWhenNextMarkedIsSet )
	MessageToPlayer( militiaMark, eEventNotifications.MarkedForDeathYouWillBeMarkedNext, null, timeWhenNextMarkedIsSet )

	//Tell rest of team marks will be set soon
	MessageToTeam( TEAM_IMC, eEventNotifications.MarkedForDeathCountdownToNextMarked, imcMark, imcMark, timeWhenNextMarkedIsSet )
	MessageToTeam( TEAM_MILITIA, eEventNotifications.MarkedForDeathCountdownToNextMarked, militiaMark, militiaMark, timeWhenNextMarkedIsSet )

	PlayConversationToAll( "countdown_start" )

	level.ent.EndSignal( "PendingMarkedDisconnected" )

	wait countDownTime

	if ( !WaitingForMarkedToSpawn() && GamePlaying() )
		SetMarked()
}

function GetPlayersToMarkTable()
{
	local marked = {}
	foreach ( team in file.teams )
	{
		marked[ team ] <- GetPlayerToMarkFromTeam( team )
	}

	Assert ( marked!= null, "No player available to mark on team: " + team )

	return marked
}

function GetPlayerToMarkFromTeam( team ) //2 step process: iterate through entire array, if players have player.s.skippedfortargetcount < 0, increment it. Then pick randomly from max player.s.skippedfortarget
{
	local players = GetPlayerArrayOfTeam( team )
	local maxCount = GetInitialSkippedTargetCount() - 1 //Has to be less than minimum
	local maxPlayers = []

	//First step: increment player.s.skippedForTargetCount if < 0

	foreach ( player in players )
	{
		if ( player.s.skippedForTargetCount < 0 )
			++player.s.skippedForTargetCount
		else
			player.s.skippedForTargetCount = 0 //Force to 0 for sanity's sake
	}

	//2nd step:

	//Puts all players with max s.skippedForTargetCount in an array, and chooses one among them randomly
	foreach ( player in players )
	{
		if ( player.s.skippedForTargetCount == maxCount )
		{
			maxPlayers.append( player )
		}
		else if ( player.s.skippedForTargetCount > maxCount )
		{
			maxPlayers = [ player ]
			maxCount = player.s.skippedForTargetCount
		}
	}

	// no players on that team
	if ( !maxPlayers.len() )
		return null

	return Random( maxPlayers )
}


function SetMarked()
{
	local pendingMarks = GetPendingMarks()
	ClearPendingMarkedPlayers()

	foreach ( team in file.teams )
	{
		SetMarkedForTeam( team, pendingMarks[ team ] )
		if ( IsEliminationBased() )
			ProtectTeamFromElimination( team )
	}

	TellClientsMarkedChanged()
}

function ClearMarkedPlayers()
{
	foreach ( team in file.teams )
	{
		local markedPlayer = GetMarked( team )
		if ( IsValid( markedPlayer ) )
		{
			markedPlayer.Minimap_DisplayDefault( TEAM_IMC, null )
			markedPlayer.Minimap_DisplayDefault( TEAM_MILITIA, null )
			markedPlayer.SetForceCrosshairNameDraw( false )
			UpdatePlayerMinimapMaterials( markedPlayer )
			markedPlayer.Signal("StopReceivingScoreBonus" ) //Clear surviving bonus
			TakePassive( markedPlayer, PAS_MINIMAP_ALL )
		}

		level.mfdActiveMarkedPlayerEnt[ team ].ClearBossPlayer()

	}

	if ( IsEliminationBased() )
		ClearTeamEliminationProtection()
}

function GetPendingMarks()
{
	local table = {}
	foreach ( team in file.teams )
	{
		table[ team ] <- GetPendingMarked( team )
	}

	return table

}

function ClearPendingMarkedPlayers()
{
	foreach ( team in file.teams )
	{
		local pendingMarked = GetPendingMarked( team )
		if ( IsValid( pendingMarked ) )
		{
			pendingMarked.Minimap_DisplayDefault( TEAM_IMC, null )
			pendingMarked.Minimap_DisplayDefault( TEAM_MILITIA, null )
			pendingMarked.Minimap_DisableFriendlyObjectScale()
			UpdatePlayerMinimapMaterials( pendingMarked )
		}
		level.mfdPendingMarkedPlayerEnt[ team ].ClearBossPlayer()
	}
}

function TellClientsMarkedChanged()
{
	foreach ( player in GetPlayerArray() )
	{
		Remote.CallFunction_NonReplay( player, "SCB_MarkedChanged" )
	}
}

function SetMarkedForTeam( team, marked )
{
	level.mfdActiveMarkedPlayerEnt[ team ].SetBossPlayer( marked )
	thread MarkedScoreBonus( marked )
	thread MarkedUpdateAssault( marked )

	local players = GetPlayerArrayOfTeam( team )
	foreach ( player in players )
	{
		if ( player == marked )
			player.s.skippedForTargetCount = GetInitialSkippedTargetCount() // -3 lets you skip the next 2 turns of being marked.
	}

	SetMinimapMaterialsForMarked( marked )

	Remote.CallFunction_Replay( marked, "ServerCallback_PlayerUsesBurnCard", marked.GetEncodedEHandle(), 31, true )
	GivePassive( marked, PAS_MINIMAP_ALL )

	//printt( "Assigned " + marked + " of team " + team )
	TellMarkedTeammatesTargetsMarked( marked, team )
	PlayConversationToPlayer( "you_are_marked", marked )

	thread ReapplyMinimapPassive( marked )

	if ( level.nv.mfdOverheadPingDelay )
		thread PingEnemyMark( marked, GetOtherTeam(team))
}

// This is necessary because when players change their loadout during the grace period, all of their passives are removed
function ReapplyMinimapPassive( player )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "Disconnected" )

	while ( IsValid( player ) && player == GetMarked( player.GetTeam() ) )
	{
		if ( !PlayerHasPassive( player, PAS_MINIMAP_ALL ) )
		{
			Remote.CallFunction_Replay( player, "ServerCallback_PlayerUsesBurnCard", player.GetEncodedEHandle(), 30, true )
			GivePassive( player, PAS_MINIMAP_ALL )
		}

		if ( !player.s.inGracePeriod )
			return

		wait 1.0
	}
}

function PingEnemyMark( marked, team )
{
	marked.EndSignal( "OnDeath" )
	marked.EndSignal( "Disconnected" )

	while ( IsValid( marked ) && marked == GetMarked( marked.GetTeam() ) )
	{
		Minimap_CreatePingForTeam( team, marked.GetOrigin(), MFD_MINIMAP_ENEMY_MATERIAL, 1.0 )
		wait level.nv.mfdOverheadPingDelay
	}
}

function TellMarkedTeammatesTargetsMarked( marked, team )
{
	local imcScore = GameRules.GetTeamScore( TEAM_IMC )
	local militiaScore = GameRules.GetTeamScore( TEAM_MILITIA )

	if ( imcScore > 0 || militiaScore > 0  )
		PlayConversationToTeamExceptPlayer( "targets_marked_short", team, marked )
	else
		PlayConversationToTeamExceptPlayer( "targets_marked_long", team, marked )
}

function SetMinimapMaterialsForPendingMarked( pendingMarked )
{
	pendingMarked.Minimap_SetFriendlyMaterial( MFD_MINIMAP_PENDING_MARK_FRIENDLY_MATERIAL )
	pendingMarked.Minimap_SetPartyMemberMaterial( MFD_MINIMAP_PENDING_MARK_FRIENDLY_MATERIAL )
	pendingMarked.Minimap_SetFriendlyObjectScale( 0.15 )
	pendingMarked.Minimap_SetAlignUpright( true )
	pendingMarked.Minimap_SetZOrder( 10 )
}

function SetMinimapMaterialsForMarked( marked )
{
	local playerTeam = marked.GetTeam()
	if ( !level.nv.mfdOverheadPingDelay )
		marked.Minimap_AlwaysShow(GetOtherTeam( playerTeam ), null)

	marked.Minimap_SetFriendlyMaterial( MFD_MINIMAP_FRIENDLY_MATERIAL )
	marked.Minimap_SetEnemyMaterial( MFD_MINIMAP_ENEMY_MATERIAL )
	marked.Minimap_SetPartyMemberMaterial( MFD_MINIMAP_FRIENDLY_MATERIAL )
	marked.Minimap_SetObjectScale( 0.15 )
	marked.Minimap_SetAlignUpright( true )
	marked.Minimap_SetZOrder( 10 )

	if ( !level.nv.mfdOverheadPingDelay )
		marked.SetForceCrosshairNameDraw( true )
}

function UpdateMinimapForMarkedOnClassChange( player, npc_titan )
{
	local playerTeam = player.GetTeam()
	if ( player == GetMarked( playerTeam ) )
		SetMinimapMaterialsForMarked( player )
	else if(  player == GetPendingMarked( playerTeam )  )
		SetMinimapMaterialsForPendingMarked( player )
}

function MarkedUpdateAssault( marked )
{
	marked.EndSignal( "OnDeath" )
	marked.EndSignal( "OnDestroy" )
	marked.EndSignal( "Disconnected" )
	local team = marked.GetTeam()
	local enemyTeam = GetOtherTeam(team)

	for ( ;; )
	{
		if ( marked != GetMarked( team ) )
			return

		local node = GetNearestNodeToPos( marked.GetOrigin() )
		if ( node >= 0 )
		{
			local pos = GetNodePos( node, 0 )
			level.mfdAssault[ enemyTeam ].SetOrigin( pos )
			ForceMinionsAssault( team )
			//DrawArrow( pos )
		}
		else
		{
			ClearMinionAssault( team )
		}

		wait 2
	}
}

function ForceMinionsAssault( team )
{
	local ai = GetTeamMinions( team )
	local assault = level.mfdAssault[ team ]
	for ( local i = 0; i < ai.len(); i++ )
	{
		ai[i].AssaultPointEnt( assault )
	}
}

function ClearMinionAssault( team )
{
	local ai = GetTeamMinions( team )
	foreach( minion in ai )
	{
		minion.DisableBehavior( "assault" )
	}
}

function MarkedScoreBonus( marked )
{
	marked.EndSignal( "OnDeath" )
	marked.EndSignal( "OnDestroy" )
	marked.EndSignal( "Disconnected" )

	marked.Signal( "StopReceivingScoreBonus" )
	marked.EndSignal( "StopReceivingScoreBonus" )

	for ( ;; )
	{
		if ( marked != GetMarked( marked.GetTeam() ) )
			return

		wait 12
		AddPlayerScore( marked, "MarkedSurvival" )
	}
}

function MFD_OnPlayerOrNPCKilled( victim, attacker, damageInfo )
{
	if ( GetGameState() != eGameState.Playing )
		return

	if ( !victim.IsPlayer() )
		return

	local victimTeam = victim.GetTeam()
	local otherTeam = GetOtherTeam(victimTeam)

	local victimWasMarked = victim == GetMarked( victimTeam )

	local playerAttacker = IsValid( attacker ) && attacker.IsPlayer()

	if ( !victimWasMarked )
	{
		if ( playerAttacker )
			TO_TryProtectedFriendlyTarget( victim, attacker )

		return
	}

	if ( victimTeam != TEAM_MILITIA && victimTeam != TEAM_IMC )
		return

	local scoreVal = 1

	local enemyTeamMarked = GetMarked( otherTeam )
	PlayConversationToTeamExceptPlayer( "friendly_marked_down", victimTeam, victim )

	if ( playerAttacker && attacker != victim )
	{
		MessageToAll( eEventNotifications.MarkedForDeathKill, null, victim, attacker.GetEncodedEHandle() )
		attacker.SetAssaultScore( attacker.GetAssaultScore() + scoreVal )
		EmitSoundOnEntityOnlyToPlayer( attacker, attacker, "UI_InGame_MarkedForDeath_MarkKilled" )

		if ( enemyTeamMarked == attacker ) //Marked player on 1 team killed marked player on another
		{
			AddPlayerScore( attacker, "MarkedKilledMarked", victim )
			PlayConversationToTeamExceptPlayer( "enemy_marked_down", otherTeam, attacker ) //Attacker's VO played below in DelayKilledMarkConversation

			if ( IsAlive( enemyTeamMarked ) )
			{
				AddPlayerScore( enemyTeamMarked, "MarkedOutlastedEnemyMarked", victim )
				enemyTeamMarked.SetDefenseScore( enemyTeamMarked.GetDefenseScore() + 1 )
			}

		}
		else //Someone else on the team killed the enemy marked
		{
			AddPlayerScore( attacker, "MarkedTargetKilled", victim )
			if ( IsAlive( enemyTeamMarked ) )
			{
				AddPlayerScore( enemyTeamMarked, "MarkedOutlastedEnemyMarked", victim )
				enemyTeamMarked.SetDefenseScore( enemyTeamMarked.GetDefenseScore() + 1 )
				EmitSoundOnEntityOnlyToPlayer( enemyTeamMarked, enemyTeamMarked, "UI_InGame_MarkedForDeath_PlayerUnmarked" )
				PlayConversationToPlayer( "outlasted_enemy_mark", enemyTeamMarked )

				foreach( player in GetPlayerArrayOfTeam( otherTeam ) )
				{
					if ( player == enemyTeamMarked )
						continue

					if ( player == attacker )
						continue

					PlayConversationToPlayer( "enemy_marked_down", player )
				}
			}
		}

		thread DelayKilledMarkConversation( attacker ) //Pause for VO as requested by Audio for effect
	}
	else
	{
		MessageToAll( eEventNotifications.MarkedForDeathKill, null, victim )
		if ( IsAlive( enemyTeamMarked ) )
		{
			AddPlayerScore( enemyTeamMarked, "MarkedOutlastedEnemyMarked", victim )
			enemyTeamMarked.SetDefenseScore( enemyTeamMarked.GetDefenseScore() + 1 )
			PlayConversationToPlayer( "outlasted_enemy_mark", enemyTeamMarked )

			PlayConversationToTeamExceptPlayer( "enemy_marked_down", otherTeam, enemyTeamMarked ) //EnemyMarked will have conversation "outlasted_enemy_mark" playing already
		}
		else
		{
			PlayConversationToTeam( "enemy_marked_down", otherTeam )
		}
	}

	if ( IsRoundBased() )
	{
		//Hack: At this point in time we haven't adjusted the kill count yet, but after we do SetWinner() _base_gametype doesn't increment it for us anymore.
		if ( attacker.IsPlayer() )
			attacker.SetKillCount( attacker.GetKillCount() + 1 )
		thread DelayKillNotification( attacker, victim )
		local replayViewEntity = attacker
		local inflictor = damageInfo.GetInflictor() //At this point in time, if the inflictor was a player's NPC titan/hacked spectre etc, the attacker has already been set to the player
		if ( inflictor.IsNPC() && inflictor.GetBossPlayer() == attacker )
			replayViewEntity = inflictor
		else if ( !attacker.IsPlayer() && !attacker.IsNPC() )
			replayViewEntity = victim //Set view to victim in case of jumping into hurt triggers, etc. More work to be done here
		SetRoundWinningKillReplayEntities( replayViewEntity, victim )

		SetWinLossReasons( "#GAMEMODE_MARKED_FOR_DEATH_PRO_WIN_ANNOUNCEMENT", "#GAMEMODE_MARKED_FOR_DEATH_PRO_LOSS_ANNOUNCEMENT")
		local scoringTeam = GetOtherTeam(victim)
		SetWinner( scoringTeam )

	}
	else
	{
		GameScore.AddTeamScore( otherTeam, scoreVal )
	}

	UpdateMarkedPlayers()
}

function DelayKilledMarkConversation( attacker ) //Pause for VO as requested by Audio for effect
{
	attacker.EndSignal( "OnDestroy" )
	attacker.EndSignal( "Disconnected" )

	wait 0.75

	local attackerScore = attacker.GetAssaultScore()

	if ( IsRoundBased() )
	{
		//Have shorter VO for MFDP so they don't get cut off by Round Winning Kill Replay starting.
		if ( attackerScore > 2 )
			PlayConversationToPlayer( "you_killed_many_marks_short", attacker )
		else
			PlayConversationToPlayer( "you_killed_marked_short", attacker )
	}
	else
	{
		if ( attackerScore > 2 )
			PlayConversationToPlayer( "you_killed_many_marks", attacker )
		else
		PlayConversationToPlayer( "you_killed_marked", attacker )
	}



}

function DelayKillNotification( attacker, victim )
{
	wait MFD_PRO_KILL_ANNOUNCEMENT_WAIT

	if ( IsValid( victim ) )
	{
		if ( IsValid( attacker ) && attacker != victim && attacker.IsPlayer() )
			MessageToAll( eEventNotifications.MarkedForDeathKill, null, victim, attacker.GetEncodedEHandle() )
		else
			MessageToAll( eEventNotifications.MarkedForDeathKill, null, victim )
	}

}

function TO_TryProtectedFriendlyTarget( victim, attacker )
{
	local friendlyTarget = GetMarked( attacker.GetTeam() )

	if ( !IsAlive( friendlyTarget ) )
		return

	if ( attacker == friendlyTarget )
		return

	if ( attacker == victim )
		return

	// can also check damage history
	if ( !WithinProtectRange( friendlyTarget, victim, attacker ) )
		return

	AddPlayerScore( attacker, "MarkedEscort", victim )
}

function WithinProtectRange( friendlyTarget, victim, attacker ) //Return true if attacker is close to target or if victim is close to target
{
	local targetOrigin = friendlyTarget.GetOrigin()

	if ( Distance( attacker.GetOrigin(), targetOrigin ) < MFD_ESCORT_RADIUS )
		return true

	return Distance( victim.GetOrigin(), targetOrigin ) < MFD_ESCORT_RADIUS
}

function MFD_RoundEnd()
{
	ClearPendingMarkedPlayers()
	ClearMarkedPlayers()
	TellClientsMarkedChanged()
}

function GetInitialSkippedTargetCount()
{
	local value = ( MFD_ROUNDS_SKIPPED_AFTER_BEING_MARKED * -1 ) - 1
	//printt( "GetInitialSkippedTargetCount: " + value )
	return value
}

function ArePlayersMarked()
{
	foreach ( team in file.teams )
	{
		local markedPlayer = GetMarked( team )
		if ( !IsValid( markedPlayer ) )
			return false
	}

	return true
}


