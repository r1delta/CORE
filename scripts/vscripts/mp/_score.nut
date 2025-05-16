//=========================================================
//	_score.nut
//  Handles scoring for MP.
//
//	Interface:
//		- ScoreEvent_*(); called from various places in different scripts to award score to players
//		- ScriptCallback_OnPlayerScore(); gametypes can define this to do special handling with player score; TDM does this
//=========================================================

function main()
{
	FlagInit( "firstStrikeGiven" )
	Globalize( AddPlayerScore )
	Globalize( AddTeamScore )
	Globalize( ScoreEvent_TitanKilled )
	Globalize( ScoreEvent_PlayerKilled )
	Globalize( ScoreEvent_NPCKilled )
	Globalize( ScoreEvent_DropImpact )
	Globalize( SavedFromRodeo )

	RegisterSignal( "EventPriority_1" )
	RegisterSignal( "EventPriority_2" )
	RegisterSignal( "EventPriority_3" )
	RegisterSignal( "EventPriority_4" )
	RegisterSignal( "EventPriority_5" )
	RegisterSignal( "EventPriority_6" )

	level.gameModeScoreEventOverrideFunc <- null  //Optionally set by a gamemode
	level.gameModeScoreEventOverrides <- {} //Table is filled out by a gamemode if there is a gameModeScoreEventOverrideFunc

	level.onScoreEventFunc <- null
}

function EntitiesDidLoad()
{
	if ( level.gameModeScoreEventOverrideFunc )
		return level.gameModeScoreEventOverrideFunc.func.acall( [ level.gameModeScoreEventOverrideFunc.scope ] )
}

function SetGameModeScoreEventOverrideFunc( func )
{
	local callbackInfo = {}
	callbackInfo.func 	<- func
	callbackInfo.scope 	<- this

	level.gameModeScoreEventOverrideFunc = callbackInfo
}
Globalize ( SetGameModeScoreEventOverrideFunc )

/*
// iskyfish.2016.10.31, setting 값으로만 동작하게 해봅니다!
function AddPlayerScore( player, scoreEvent, targetEnt = null, pointValueOverride = null )
{
	if ( !IsValid_ThisFrame( player ) || !player.IsPlayer() )
		return

	if ( !player.hasConnected )
		return

	if ( IsTrainingLevel() )
		return

	local event = ScoreEventFromName( scoreEvent )

	if ( level.onScoreEventFunc != null )
		level.onScoreEventFunc.func.acall( [ level.onScoreEventFunc.scope, player, event ] )

	local eventType = event.GetType()
	local pointValue = event.GetPointValue()


	pointValue = floor( pointValue )

	if ( pointValue <=0 ) return

	player.SetScore( player.GetScore() + pointValue )

	if ( eventType == scoreEventType.ASSAULT )
		player.SetAssaultScore( player.GetAssaultScore() + pointValue )
	else if ( eventType == scoreEventType.DEFENSE )
		player.SetDefenseScore( player.GetDefenseScore() + pointValue )

	AddTitanBuildPoint( player, scoreEvent )

	// display score splash message
	local multiple = 1.0
	ShowPlayerScoreEvent( player, event, targetEnt, pointValueOverride, multiple )
	if ( event.HasConversation() )
		thread PlayPrioritisedConversation( event, player )
}*/

// iskyfish.2016.10.31, backup
function AddPlayerScore( player, scoreEvent, targetEnt = null, pointValueOverride = null )
{
	if ( !IsValid_ThisFrame( player ) || !player.IsPlayer() )
		return

	if ( !player.hasConnected )
		return

	if ( IsTrainingLevel() )
		return

	local event = ScoreEventFromName( scoreEvent )

	if ( level.onScoreEventFunc != null )
		level.onScoreEventFunc.func.acall( [ level.onScoreEventFunc.scope, player, event ] )

	local eventType = event.GetType()
	local pointValue = event.GetPointValue()

	if ( scoreEvent in level.gameModeScoreEventOverrides )
	{
		Assert( pointValueOverride == null, "pointValueOverride and gameModeScoreEventOverrides are both set for scoreEvent: " + scoreEvent )  //HACK:
		pointValueOverride = level.gameModeScoreEventOverrides[ scoreEvent ] //Set to pointValueOverride instead of pointValue so rest of script works without changing
		//printt( "Setting pointValue for scoreEvent " + scoreEvent +  " to override: " + pointValueOverride )
	}

	if ( pointValueOverride != null )
		pointValue = pointValueOverride

	pointValue = floor( pointValue )

	local multiple

	// award points
	if ( pointValue > 0 )
	{
		player.SetScore( player.GetScore() + pointValue )

		if ( eventType == scoreEventType.ASSAULT )
			player.SetAssaultScore( player.GetAssaultScore() + pointValue )
		else if ( eventType == scoreEventType.DEFENSE )
			player.SetDefenseScore( player.GetDefenseScore() + pointValue )

		if ( event.GetXPMultiplierApplies() )
		{
			multiple = GetPlayerXPMultiple( player, targetEnt )
			if ( multiple != null )
			{
				pointValue *= multiple
				pointValue = ceil( pointValue )
				pointValueOverride = pointValue
			}
		}
		AddXP(pointValue,player, event.GetXPType() )
	}

	AddTitanBuildPoint( player, scoreEvent )

	// display score splash message
	ShowPlayerScoreEvent( player, event, targetEnt, pointValueOverride, multiple )
	if ( event.HasConversation() )
		thread PlayPrioritisedConversation( event, player )
}


function GetPlayerXPMultiple( player, targetEnt )
{
	local multiplier = null

	if ( PlayerHasServerFlag( player, SFLAG_DOUBLE_XP ) )
		multiplier = 2.0

	if ( !IsValid( targetEnt ) )
		return multiplier

	if ( targetEnt.IsTitan() && PlayerHasServerFlag( player, SFLAG_HUNTER_TITAN ) )
		return 2.5

	if ( targetEnt.IsSoldier() && PlayerHasServerFlag( player, SFLAG_HUNTER_GRUNT ) )
		return 2.5

	if ( targetEnt.IsSpectre() && PlayerHasServerFlag( player, SFLAG_HUNTER_SPECTRE ) )
		return 2.5

	if ( targetEnt.IsPlayer() && PlayerHasServerFlag( player, SFLAG_HUNTER_PILOT ) )
		return 2.5

	return multiplier
}

function PlayPrioritisedConversation( event, player )
{
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "Disconnected" )
	// create end signals for this thread based on the priority of the event
	PriorityEndSignals( event, player )

	wait event.GetTimeDelay()	// time until conversation can't be interrupted any more.
	PlayConversationToPlayer( event.GetConversation(), player )
}

function PriorityEndSignals( event, player )
{
	local priority = event.GetPriority()
	player.Signal( "EventPriority_" + priority )
	switch ( priority )
	{
		case 1:
			player.EndSignal( "EventPriority_2" )	// end on ..2 and all higher
		case 2:
			player.EndSignal( "EventPriority_3" )	// end on ...3 and all higher
		case 3:
			player.EndSignal( "EventPriority_4" )
		case 4:
			player.EndSignal( "EventPriority_5" )
		case 5:
			player.EndSignal( "EventPriority_6" )
		case 6:
			// no end signal for the highest priority
	}
}

function AddTeamScore( teamIndex, newPoints )
{
	GameScore.AddTeamScore( teamIndex, newPoints )
}


function ShowPlayerScoreEvent( player, event, associatedEntity, pointValueOverride, multiple )
{
	Assert( event != null )

	local scoreEventInt = event.GetInt()
	local entityHandle = null
	if ( associatedEntity != null )
		entityHandle = associatedEntity.GetEncodedEHandle()

	if ( multiple == null )
		Remote.CallFunction_NonReplay( player, "ServerCallback_PointSplash", scoreEventInt, entityHandle, pointValueOverride )
	else
		Remote.CallFunction_NonReplay( player, "ServerCallback_PointSplashMultiplied", scoreEventInt, entityHandle, pointValueOverride )
}

function ScoreEvent_TitanKilled( titan, attacker, inflictor, damageSourceId, weaponName, scriptDamageType )
{
	local player = attacker
	if ( !player.IsPlayer() )
	{
		local actualPlayer = GetPlayerFromEntity( player )
		if ( IsValid( actualPlayer ) )
			player = actualPlayer

		if ( !player.IsPlayer() )
			return	// couldn't find a player to give the score to so we early out.
	}


	if ( titan.GetTeam() == attacker.GetTeam() )
		return false

	player.SetTitanKillCount( player.GetTitanKillCount() + 1 )
	AddTitanBuildPoint( player, "TitanKilled" )


	titan.GetTitanSoul()

	local cardRef = GetPlayerActiveBurnCard(inflictor)
	if(cardRef != null) {
	local cardData = GetBurnCardData(cardRef);
	if(cardData != null) {
	if(cardData.rarity == BURNCARD_RARE) {
		if(cardData.ctFlags & CT_TITAN_WPN) {
			AddPlayerScore(attacker,"StoppedBurnCardRareWeapon", inflictor)
		} else if (cardData.ctFlags & CT_TITAN) {
			AddPlayerScore(attacker,"StoppedBurnCardRare", inflictor)
		}
	}
	else {
		if(cardData.ctFlags & CT_TITAN_WPN) {
			AddPlayerScore(attacker,"StoppedBurnCardWeapon", inflictor)
		} else if(cardData.ctFlags & CT_TITAN) {
			AddPlayerScore(attacker,"StoppedBurnCardCommon", inflictor)
		}
	}
	}
	}

	local scoreEvent

	if ( attacker.IsPlayer() && !attacker.IsTitan() )
	{
		local settings = titan.GetPlayerSettings()
		local scriptName = GetPlayerSettingsFieldForClassName( settings, "scriptName" )

		if (!scriptName)
			return

		scoreEvent = "Kill" + scriptName

		switch ( footstepType )
		{
			case "stryder":
				scoreEvent = "KillStryder"
				break

			case "slammer":
				scoreEvent = "KillSlammer"
				break

			case "atlas":
				scoreEvent = "KillAtlas"
				break

			case "ogre":
				scoreEvent = "KillOgre"
				break
		}
		if ( GAMETYPE == COOPERATIVE )
		{
			if ( IsNukeTitan( titan ) )
				scoreEvent = "Killed_Nuke_Titan"
			else if ( IsMortarTitan( titan ) )
				scoreEvent = "Killed_Mortar_Titan"
			else if ( IsEMPTitan( titan ) )
				scoreEvent = "Killed_EMP_Titan"
		}

		if ( !scoreEvent )
			return

		if ( !IsTitanEliminationBased() )
			AddPlayerScore( player, scoreEvent, titan )
	}
	else
	{
		scoreEvent = ScoreEventForTitanEntityKilled( titan, inflictor, damageSourceId )

		if ( titan != player && !IsTitanEliminationBased() )
		{
			AddPlayerScore( player, scoreEvent, titan )

			// add bonus score
			if ( damageSourceId == eDamageSourceId.titan_melee )
			{
				local meleeEvent = "TitanMelee_VsTitan"
				AddPlayerScore( player, meleeEvent, titan )
			}
		}
	}

	if ( IsTitanEliminationBased() )
		AddPlayerScore( player, "EliminateTitan", titan )



	local titanSoul = titan.GetTitanSoul()
	if ( "recentDamageHistory" in titanSoul.s )
	{
		ScoreEvent_KillAssists( titanSoul, player, scoreEvent )
	}

	//Send obit info to clients
	local players = GetPlayerArray()
	local victimEHandle = titan.GetEncodedEHandle()
	local attackerEHandle = attacker ? attacker.GetEncodedEHandle() : null
	foreach ( player in players )
		Remote.CallFunction_NonReplay( player, "ServerCallback_OnTitanDoomed", attackerEHandle, victimEHandle, scriptDamageType, damageSourceId )

}

function ScoreEvent_PlayerKilled( player, attacker, damageInfo )
{
	Assert( attacker.IsPlayer() )
	Assert( player.IsPlayer() )

	ScoreCheck_InitStats( attacker )
	ScoreCheck_InitStats( player )

	player.s.lastKiller = attacker

	if ( player.GetTeam() == attacker.GetTeam() )
	{
		//Preventing streaks from continuing after suicides.
		player.s.numberKillsSinceLastDeath = 0
		return false
	}

	local awardedEliminationScore = false

	if(GetPlayerActiveBurnCard(player) != null) {
		local cardRef = GetPlayerActiveBurnCard(player)
		local cardData = GetBurnCardData(cardRef);
    	if(cardData.rarity == BURNCARD_RARE) {
			if(cardData.ctFlags & CT_TITAN_WPN) {
				AddPlayerScore(attacker,"StoppedBurnCardRareWeapon")
			}
			else {
				AddPlayerScore(attacker,"StoppedBurnCardRare")
			}
		}
		else {
		if(cardData.ctFlags & CT_WEAPON) {
			AddPlayerScore(attacker,"StoppedBurnCardWeapon")
		} else {
			AddPlayerScore(attacker,"StoppedBurnCardCommon")
		}
		}
    }
	// Player is a titan that was killed, bypassing doomed state
	if ( player.IsTitan() && !player.GetDoomedState() )
	{
		ScoreEvent_TitanKilled( player, attacker, damageInfo.GetInflictor(), damageInfo.GetDamageSourceIdentifier(), _GetWeaponNameFromDamageInfo( damageInfo ), damageInfo.GetCustomDamageType() )
	}
	else
	{
		if ( IsPilotEliminationBased() && IsPlayerEliminated( player )  )
		{
			AddPlayerScore( attacker, "EliminatePilot", player )
			awardedEliminationScore = true
		}

		if ( SavedFromRodeo( player, attacker ) )
		{
	        local rodeoTitan = GetTitanBeingRodeoed( player )
	        if ( rodeoTitan.IsPlayer() )
		        Remote.CallFunction_Replay( rodeoTitan, "SCB_TitanDialogue", eTitanVO.RODEO_RAKE )
			if ( damageInfo.GetDamageSourceIdentifier() == eDamageSourceId.titan_melee && !awardedEliminationScore )
			{	AddPlayerScore( attacker, "RodeoRake", player )
				Stats_IncrementStat( attacker, "kills_stats","rodeo_total",1.0)
			}else if ( !awardedEliminationScore )
				AddPlayerScore( attacker, "SavedFromRodeo", player )
		}
		else if ( !player.IsTitan() && damageInfo.GetDamageSourceIdentifier() == eDamageSourceId.titan_melee && !awardedEliminationScore )
		{
			AddPlayerScore( attacker, "TitanMelee_VsHumanPilot", player )
			Stats_IncrementStat( attacker, "kills_stats","titanMeleePilot",1.0)
		}

		if ( player.pilotEjecting && !awardedEliminationScore )
			AddPlayerScore( attacker, "PilotEjectKill", player )
	}

	local scoreEvent = ScoreEventForMethodOfDeath( player, damageInfo )
	if ( !awardedEliminationScore )
		AddPlayerScore( attacker, scoreEvent, player )

	if ( IsValidHeadShot( damageInfo, player ) )
		AddPlayerScore( attacker, "Headshot", player )

	// check if player was killed has a burn card

	ScoreCheck_DroppodKill( attacker, damageInfo )

	ScoreCheck_Kill( attacker, player )

	if ( "recentDamageHistory" in player.s || ( player.isTitan() && ( "recentDamageHistory" in player.GetTitanSoul().s ) )  )
		ScoreEvent_KillAssists( player, attacker, scoreEvent )
}

function ScoreEvent_KillAssists( ent, attacker, scoreEvent )
{
	// this only works for players and npc titans right now.
	// the reason is that NPC grunts etc doesn't use the _damage_history script to keep track of their damage.

	Assert( ent != null )
	Assert( scoreEvent != null )

	local playerTable = {}
	local lastDeathTime = 0
	if ( "lastDeathTime" in ent.s )
		lastDeathTime = ent.s.lastDeathTime

	playerTable = AddToPlayerAssistTable( playerTable, ent.s.recentDamageHistory, attacker, lastDeathTime )
	if ( ent.IsTitan() && ( "recentDamageHistory" in ent.GetTitanSoul().s ) )
		playerTable = AddToPlayerAssistTable( playerTable, ent.GetTitanSoul().s.recentDamageHistory, attacker, lastDeathTime )

	local assist

	if ( IsSoul( ent ) )
	{
		ent = ent.GetTitan()

		if ( !IsValid( ent ) || !ent.IsTitan() )
			return

		assist = "TitanAssist"
	}
	else
	{
		assist = "PilotAssist"
	}

	foreach ( player, damage in playerTable )
	{
		if ( player == ent )
			continue

		player.SetAssistCount( player.GetAssistCount() + 1 )
		AddPlayerScore( player, assist, ent )
	}
}

// NOTE doesn't run on Titans! instead look at ScoreEvent_TitanKilled
function ScoreEvent_NPCKilled( npc, attacker, damageInfo )
{
	Assert( attacker.IsPlayer() )
	Assert( npc.IsNPC() )

	ScoreCheck_InitStats( attacker )
	ScoreCheck_InitStats( npc )

	if ( npc.GetTeam() == attacker.GetTeam() )
		return false

	if ( npc.IsMarvin() )
		return

	local scoreEvent = ScoreEventForNPCKilled(npc, damageInfo)

	AddPlayerScore( attacker, scoreEvent, npc )

	if ( IsValidHeadShot( damageInfo, npc ) )
		AddPlayerScore( attacker, "NPCHeadshot", npc )

	ScoreCheck_DroppodKill( attacker, damageInfo )

	if ( damageInfo.GetDamageSourceIdentifier() == eDamageSourceId.titan_melee )
		AddPlayerScore( attacker, "TitanMelee_VsHumanSizedNPC", npc )

	ScoreCheck_Kill( attacker, npc )

	if ( "recentDamageHistory" in npc.s )
		ScoreEvent_KillAssists( npc, attacker, scoreEvent )
}

function ScoreEvent_DropImpact( player )
{
	// player may have disconnected before droppod hit the ground
	if ( !IsValid_ThisFrame( player ) )
		return

	Assert( player.IsPlayer() )

	if ( player.GetPlayerClass() == "dronecontroller" )
		return

	thread DropImpactWait( player )
}

function DropImpactWait( player )
{
	local delay = 0.1
	wait delay

	if ( !IsValid_ThisFrame( player ) )
		return

	if ( ( "lastDroppodKillTime" in player.s ) && ( Time() - player.s.lastDroppodKillTime <= delay ) )
		return

	AddPlayerScore( player, "DropSuccess" )
}

function ScoreCheck_Kill( attacker, killed )
{
	Assert( killed != null )

	local currentTime = Time()
	if ( ( killed != null ) && ( IsValid_ThisFrame( killed ) ) )
	{
		killed.s.numberDeathsSinceLastKill++
	}

	// Check for various score bonuses for killing players
	if ( IsPlayer( killed ) )
	{
		ScoreCheck_FirstStrike( attacker, killed )
		ScoreCheck_KillingSpree( attacker, killed )
		ScoreCheck_Comeback( attacker )
		ScoreCheck_VictoryKill( attacker, killed )
		ScoreCheck_Nemesis( attacker, killed )
		ScoreCheck_SpotAssist( attacker, killed, currentTime )
		ScoreCheck_Revenge( attacker, killed, currentTime )
		ScoreCheck_KilledMVP( attacker, killed )
	}

	// Score bonuses for killing NPC's and players
	ScoreCheck_MultiKill( attacker, killed, currentTime )

	attacker.s.numberDeathsSinceLastKill = 0
}

function ScoreCheck_VictoryKill( attacker, player )
{
	if ( GetGameState() > eGameState.SuddenDeath )
		return

	local gameMode = GameRules.GetGameMode()

	if ( ( gameMode == TEAM_DEATHMATCH || gameMode == PILOT_SKIRMISH ) && GameRules.GetTeamScore( attacker.GetTeam() ) == GetScoreLimit_FromPlaylist() )
		AddPlayerScore( attacker, "VictoryKill", player )
}

function ScoreCheck_KilledMVP( attacker, player )
{
	if ( !IsPlayer( attacker ) )
		return

	local killedTeam = player.GetTeam()

	if ( killedTeam != TEAM_MILITIA && killedTeam != TEAM_IMC )
		return

	local compareFunc = GetScoreboardCompareFunc()
	local playersArray = GetSortedPlayers( compareFunc, killedTeam )
	local playerPlacementOnTeam = GetIndexInArray( playersArray, player )

	if ( playersArray.len() >= 3 && playerPlacementOnTeam == 0 )
		AddPlayerScore( attacker, "KilledMVP", player )
}

function ScoreCheck_FirstStrike( attacker, killed )
{
	if ( Flag( "firstStrikeGiven" ) )
		return

	AddPlayerScore( attacker, "FirstStrike" )
	FlagSet( "firstStrikeGiven" )
	Stats_IncrementStat( attacker, "kills_stats","firstStrikes",1.0)

	if ( ShouldShowFirstStrike() )
		MessageToAll( eEventNotifications.PlayerFirstStrike, null, killed, attacker.GetEncodedEHandle() )

//	BeatPersonalBest( attacker, "BestFirstStrike", GameTime.TimeSpentInCurrentState() )
}

function ShouldShowFirstStrike()
{
	switch ( GAMETYPE )
	{
		case LAST_TITAN_STANDING:
		case WINGMAN_LAST_TITAN_STANDING:
		case MARKED_FOR_DEATH:
		case MARKED_FOR_DEATH_PRO:
			return false

		default:
			return true
	}

}

function ScoreCheck_MultiKill( attacker, killed, currentTime )
{
	//----------------------------------------
	// Double Kill, Triple Kill, Mega Kill,
	//----------------------------------------

	if ( !IsPlayer( attacker ) )
		return

	//Replace for loop with global function at a later time.
	for( local i = 0; i < attacker.s.recentPlayerKilledTimes.len(); )
	{
		if ( attacker.s.recentPlayerKilledTimes[i] < ( currentTime - CASCADINGKILL_REQUIREMENT_TIME ) )
		{
			attacker.s.recentPlayerKilledTimes.remove( i )
		}
		else
		{
			i++
		}
	}

//Creating two lists, one with just pilots and one with grunts and pilots.
	if ( IsPlayer( killed ) )
	{
		attacker.s.recentPlayerKilledTimes.append( currentTime )
		AddRecentAllKilledTime( attacker, currentTime )

		local killSpreeEvent = false
		if ( attacker.s.recentPlayerKilledTimes.len() >= MEGAKILL_REQUIREMENT_KILLS )
		{
			AddPlayerScore( attacker, "MegaKill" )
			killSpreeEvent = true
		}
		else if ( attacker.s.recentPlayerKilledTimes.len() == TRIPLEKILL_REQUIREMENT_KILLS )
		{
			AddPlayerScore( attacker, "TripleKill" )
			killSpreeEvent = true
		}
		else if ( attacker.s.recentPlayerKilledTimes.len() == DOUBLEKILL_REQUIREMENT_KILLS )
		{
			AddPlayerScore( attacker, "DoubleKill" )
			killSpreeEvent = true
		}
		//Resetting the time on recentPlayerKilledTimes so people can chain their kill events with a consistent interval between kills.
		if ( killSpreeEvent == true )
		{
			for( local i = 0; i < attacker.s.recentPlayerKilledTimes.len(); i++ )
			{
				attacker.s.recentPlayerKilledTimes[i] = currentTime
			}
		}
	}
	else
	{
		AddRecentAllKilledTime( attacker, currentTime )
	}

	//----------------------------------------
	// Mayhem Kill (Killing 4 grunts or pilots within the amount of time)
	//----------------------------------------

	//Don't keep track of more kills than we care about for onslaught bonus
	if ( attacker.s.recentAllKilledTimes.len() > ONSLAUGHT_REQUIREMENT_KILLS )
		attacker.s.recentAllKilledTimes.remove( 0 )

	local recentAllKilledLength = attacker.s.recentAllKilledTimes.len()
	if ( recentAllKilledLength > 0 && recentAllKilledLength % MAYHEM_REQUIREMENT_KILLS == 0 )
	{
		local elapsedTimeForKills = ( currentTime - attacker.s.recentAllKilledTimes[ max( 0, recentAllKilledLength - 4 )] )
		if ( elapsedTimeForKills <= MAYHEM_REQUIREMENT_TIME )
		{
			AddPlayerScore( attacker, "Mayhem" )
			//attacker.s.recentAllKilledTimes = []

			local weapon = attacker.GetActiveWeapon()

			if ( weapon.GetClassname() == "mp_titanweapon_arc_cannon" )
				Stats_IncrementStat( attacker, "misc_stats", "arcCannonMultiKills", 1 )
		}
	}
	if ( recentAllKilledLength == ONSLAUGHT_REQUIREMENT_KILLS )
	{
		local elapsedTimeForKills = ( currentTime - attacker.s.recentAllKilledTimes[0] )
		if ( elapsedTimeForKills <= MAYHEM_REQUIREMENT_TIME )
		{
			AddPlayerScore( attacker, "Onslaught" )
			attacker.s.recentAllKilledTimes = []
		}
	}
}

function AddRecentAllKilledTime( attacker, currentTime )
{
	if ( attacker.s.recentAllKilledTimes.len() > 0 && currentTime - attacker.s.recentAllKilledTimes[ 0 ] > MAYHEM_REQUIREMENT_TIME )
		attacker.s.recentAllKilledTimes = []

	attacker.s.recentAllKilledTimes.append( currentTime )
}

function ScoreCheck_Revenge( attacker, killed, currentTime )
{
	//---------------------------------------------------------------
	// Revenge ( Get killed by a player, respawn and kill them next )
	//---------------------------------------------------------------

	if ( killed == null )
		return

	if ( !IsValid_ThisFrame( killed ) )
		return

	// Only get revenge on real players, not NPCs
	if ( !IsPlayer( killed ) )
		return

	killed.s.lastKiller = attacker
	killed.s.seekingRevenge = true

	//You have to let them know it's worth it, or it's not worth it :)
	if ( ( attacker.s.lastKiller == attacker ) && ( (currentTime - attacker.s.lastDeathTime) < WORTHIT_REQUIREMENT_TIME ) )
		PlayConversationToPlayer( "WorthIt", attacker )

	if ( ( attacker.s.lastKiller == killed ) && ( attacker.s.seekingRevenge ) )
	{
		if ( ( currentTime - attacker.s.lastDeathTime ) <= QUICK_REVENGE_TIME_LIMIT )
			AddPlayerScore( attacker, "QuickRevenge" )
		else
			AddPlayerScore( attacker, "Revenge" )

		// set to null so we can't keep getting revenge kills unless they kill you again
		attacker.s.lastKiller = null
	}

	attacker.s.seekingRevenge = false
}

function ScoreCheck_KillingSpree( attacker, killed )
{
	if ( ( killed == null ) || ( !IsValid_ThisFrame( killed ) ) )
		return

	local killedKills = killed.s.numberKillsSinceLastDeath
	attacker.s.numberKillsSinceLastDeath += 1
	killed.s.numberKillsSinceLastDeath = 0

	if ( killedKills >= KILLINGSPREE_KILL_REQUIREMENT )
	{
		AddPlayerScore( attacker, "Showstopper" )
	}

	if ( attacker.s.numberKillsSinceLastDeath >= RAMPAGE_KILL_REQUIREMENT )
	{
		AddPlayerScore( attacker, "Rampage" )
		return
	}

	if ( attacker.s.numberKillsSinceLastDeath >= KILLINGSPREE_KILL_REQUIREMENT )
	{
		Stats_IncrementStat( attacker, "misc_stats", "killingSprees", 1 )
		AddPlayerScore( attacker, "KillingSpree" )
		return
	}
}

function ScoreCheck_Nemesis( attacker, killed )
{
	if ( ( killed == null ) || ( !IsValid_ThisFrame( killed ) ) )
		return

	if ( !IsPlayer( killed ) )
		return

	// Add the kill to the attackers streak
	if ( !( killed in attacker.s.playerKillStreaks ) )
		attacker.s.playerKillStreaks[ killed ] <- 0
	attacker.s.playerKillStreaks[ killed ]++
	if ( attacker.s.playerKillStreaks[ killed ] >= DOMINATING_KILL_REQUIREMENT )
	{
		AddPlayerScore( attacker, "Dominating" )
	}

	// Remove any streak from the killed player to the attacker
	if ( attacker in killed.s.playerKillStreaks )
	{
		if ( killed.s.playerKillStreaks[ attacker ] >= NEMESIS_KILL_REQUIREMENT )
		{
			AddPlayerScore( attacker, "Nemesis" )
		}
		delete killed.s.playerKillStreaks[ attacker ]
	}
}

function ScoreCheck_Comeback( attacker )
{
	if ( attacker.s.numberDeathsSinceLastKill >= ( COMEBACK_DEATHS_REQUIREMENT + 1 ) )
	{
		AddPlayerScore( attacker, "Comeback" )
	}
}

function ScoreCheck_SpotAssist( attacker, killed, currentTime )
{
	if ( ( killed == null ) || ( !IsValid_ThisFrame( killed ) ) )
		return

	if ( !( "lastDetectedTime" in killed.s ) )
		return

	if ( !( "detectedBy" in killed.s ) )
		return

	local timeSinceSpotted = currentTime - killed.s.lastDetectedTime
	if ( timeSinceSpotted > ENEMY_SPOTTED_DURATION )
		return

	local spotter = killed.s.detectedBy
	if ( spotter == attacker )
		return

	if ( ( spotter == null ) || ( !IsValid_ThisFrame( spotter ) ) )
		return

	if ( !IsPlayer( spotter ) )
		return

	AddPlayerScore( spotter, "OperatorSpottingAssist" )
}

function ScoreCheck_DroppodKill( attacker, damageInfo )
{
	local inflictor = damageInfo.GetInflictor()
	if ( inflictor == null )
		return

	if ( inflictor.GetClassname() != "env_explosion" )
		return

	if ( !( "lastDroppodImpactTime" in attacker.s ) )
		return

	if ( Time() - attacker.s.lastDroppodImpactTime > 0.25 )
		return

	// Was a drop pod killed

	if ( !( "lastDroppodKillTime" in attacker.s ) )
		attacker.s.lastDroppodKillTime <- null
	attacker.s.lastDroppodKillTime = Time()

	AddPlayerScore( attacker, "DroppodKill" )
}

function ScoreCheck_InitStats( player )
{
	if ( player == null )
		return

	if ( !IsValid_ThisFrame( player ) )
		return

	if ( !( "recentPlayerKilledTimes" in player.s ) )
		player.s.recentPlayerKilledTimes <- []

	if ( !( "recentAllKilledTimes" in player.s ) )
		player.s.recentAllKilledTimes <- []

	if ( !( "lastKiller" in player.s ) )
		player.s.lastKiller <- null

	if ( !( "seekingRevenge" in player.s ) )
		player.s.seekingRevenge <- null

	if ( !( "playerKillStreaks" in player.s ) )
		player.s.playerKillStreaks <- {}

	if ( !( "numberKillsSinceLastDeath" in player.s ) )
		player.s.numberKillsSinceLastDeath <- 0

	if ( !( "numberDeathsSinceLastKill" in player.s ) )
		player.s.numberDeathsSinceLastKill <- 0
}

function SavedFromRodeo( rodeoPlayer, attacker )
{
	local titan = GetTitanBeingRodeoed( rodeoPlayer )
	if ( !IsAlive( titan ) )
		return false

	if ( titan == attacker )
		return false

	local petTitan = attacker.GetPetTitan()
	if ( IsAlive( petTitan ) )
	{
		// no bonus for saving your own titan
		if ( titan == petTitan )
			return false
	}

	return true
}

function AddToPlayerAssistTable( playerTable, recentDamageHistory, attacker, lastDeathTime)
{
	foreach ( damageTable in recentDamageHistory )
	{
		if ( !IsValid( damageTable.attackerWeakRef ) || !damageTable.attackerWeakRef.IsPlayer() )
			continue

		if ( damageTable.attackerWeakRef == attacker )
			continue

		if ( damageTable.time <= lastDeathTime )
			continue

		// accumulate total damage
		if ( !( damageTable.attackerWeakRef in playerTable ) )
			playerTable[ damageTable.attackerWeakRef ] <- 0
		playerTable[ damageTable.attackerWeakRef ] += damageTable.damage
	}
	return playerTable
}

function _GetWeaponNameFromDamageInfo( damageInfo )
{
	local weaponName = null
	local weapon = damageInfo.GetWeapon()

	if ( IsValid( weapon ) )
		weaponName = weapon.GetClassname()
	else
		weaponName = GetNameFromDamageSourceID( damageInfo.GetDamageSourceIdentifier() )

	if ( damageInfo.ShouldRecordStatsForWeapon() )
		return weaponName

	return null
}
Globalize( _GetWeaponNameFromDamageInfo )
