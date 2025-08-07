const TD_DROPSHIP_HEALTH = 3900 //7800 = default
const MINIMAP_CLOAKED_DRONE_SCALE = 0.070
const MINIMAP_GENERATOR_SCALE = 0.125
const SNIPERLOSENEMYTIMEOUT = 10
const MORTAR_TITAN_ABORT_ATTACK_HEALTH_FRAC = 0.90 // will stop mortar attack if he's health gets below 90% of his current health.
const MORTAR_TITAN_POSITION_SEARCH_RANGE = 3072 // How far away from his spawn point a mortar titan will look for positions to mortar from.
const MORTAR_TITAN_ENGAGE_DELAY = 3.0 // How long before a mortar titan start to attack the generator if he's taken damage getting to his mortar position.
const MORTAR_TITAN_REENGAGE_DELAY = 7.0 // How long before a mortar titan goes back to attacking the generator after breaking of an attack.

const COOP_PLAYER_CONNECTION_MESSAGING_BUFFER_TIME = 15 // time after the game FIRST starts before messages about players connecting/disconnecting can print

const SHIELD_DOWN_ANNOUNCE_TIMEOUT = 4.0 // "harvester shield is down" VO will play up to this many secs after the shields actually get depleted

enum eGeneratorHealthStage {
	PERFECT
	HEALTHY
	DAMAGED
	CRITICAL
}

function main() {
	FlagInit("COOBJ_TowerDefense")
	FlagInit("TDGeneratorDestroyed")
	FlagInit("GeneratorGodMode")
	FlagInit("CoopTD_WaitingToAnnouncePlayerReinforcements")
	FlagInit("GeneratorBeam_On")
	FlagInit("CoopTD_WaveCombatInProgress")
	FlagInit("WaveAnnounceInProgress")
	FlagInit("GeneratorThreatAnnounce_InProgress")
	FlagInit("HighPopulationAnnounce_InProgress")
	FlagInit("CoopPlayerConnectionMessagingEnabled")

	RegisterSignal("StopGeneratorBeam")
	RegisterSignal("AssaultTimeOut")
	RegisterSignal("SniperTimeRelocate")
	RegisterSignal("SniperAssaultGenerator")
	RegisterSignal("AnEnemyWasKilled")
	RegisterSignal("SquadDead")
	RegisterSignal("WaveActionMusic_Starting")
	RegisterSignal("WaveSpawn_AllEnemiesDead")

	level.TD_isInited <- false
	level.TowerDefenseRoutes <- {}
	level.TowerDefenseRoutes_ForRandomSpawns <- {}
	level.TD_LastDefaultRouteIdx <-  -1
	level.introMusicStartTime <-  -1
	level.TowerDefenseWaves <- []
	level.TowerDefenseGenerator <- null
	level.TowerDefenseGenLocation <- {}
	level.TowerDefenseGenLocation.origin <- null
	level.TowerDefenseGenLocation.angles <- null
	level.waveNumTitans <- 0
	level.waveNumCloakedDrones <- 0
	level.waveNumSpawned <- 0
	level.waveTotalSpawns <- 0
	level.waveSpawnGroupInfos <- {}
	level.lastWaveIdx <- null
	level.firstSpawnDone <- false
	level.recentSpawns <- {}
	level.newEnemyAnnouncementsPlayed <- {}
	level.generatorThreats <- {}
	level.generatorAttackHistory <- {}
	level.teamScoreWaveStart <- 0
	level.playerTeamScoreWaveStart <- {}
	level.sendingPlayersAway <- false

	level.debugDrawStationaryPositions <- false
	level.debugDrawRoutes <- false

	InitTeamPlayerScoring()
	InitGeneratorAttackHistory()
	InitEOGKillHistory()

	level.TowerDefense_RegisteredSpawnFuncs <- {}
	level.TowerDefense_AddedSpawnFuncs <- []

	Globalize(TowerDefense_Main)
	Globalize(TowerDefense_AddRoute)
	Globalize(TowerDefense_AddGeneratorLocation)
	Globalize(TowerDefense_RegisterSpawnFunction)

	Globalize(TD_SpawnGruntSquad)
	Globalize(TD_SpawnSpectreSquad)
	Globalize(TD_SpawnSuicideSpectreSquad)
	Globalize(TD_SpawnSpectreSquadWithSingleSuicide)
	Globalize(TD_SpawnGruntSquadDroppod)
	Globalize(TD_SpawnGruntSquadDropship)
	Globalize(TD_SpawnSpectreSquadDroppod)
	Globalize(TD_SpawnSpectreSquadDropship)
	Globalize(TD_SpawnSuicideSpectreSquadDroppod)
	Globalize(TD_SpawnSuicideSpectreSquadDropship)
	Globalize(TD_SpawnSpectreSquadWithSingleSuicideDroppod)
	Globalize(TD_SpawnSpectreSquadWithSingleSuicideDropship)
	Globalize(TD_SpawnBubbleShieldSpectreSquad)
	Globalize(TD_SpawnBubbleShieldGruntSquad)
	Globalize(TD_SpawnSniper1x)
	Globalize(TD_SpawnSniper2x)
	Globalize(TD_SpawnSniper3x)
	Globalize(TD_SpawnSniper4x)
	Globalize(TD_SpawnCloakedDrone)
	Globalize(TD_SpawnTitan)
	Globalize(TD_SpawnAmpedTitan)
	Globalize(TD_SpawnNukeTitan)
	Globalize(TD_SpawnMortarTitan)
	Globalize(TD_SpawnEmpTitan)

	Globalize(IsTowerDefenseValid)

	AddCallback_OnClientConnected(CoopTD_ClientConnected)
	AddCallback_OnClientDisconnected(CoopTD_ClientDisconnected)

	AddDeathCallback("player", CoopTD_PlayerDeathCallback)
	AddSpawnCallback("npc_soldier", CoopTD_OnSoldierOrSpectreSpawn)
	AddSpawnCallback("npc_spectre", CoopTD_OnSoldierOrSpectreSpawn)
	AddSpawnCallback("npc_spectre", CoopTD_EnableSpectreRodeo)

	AddDamageCallback("prop_dynamic", GeneratorTookDamage)

	AddCallback_GameStateEnter(eGameState.Prematch, CoopTD_Prematch)
	AddCallback_GameStateEnter(eGameState.Playing, CoopTD_GamePlaying)
	AddCallback_GameStateEnter(eGameState.WinnerDetermined, TowerDefense_WinnerDetermined)
	AddCallback_GameStateEnter(eGameState.Postmatch, CoopTD_Postmatch)

	AddCallback_OnWaveSpawnDropshipSpawned(CoopTD_WaveSpawnDropship_SpawnCallback)

	level.coopAIPriorities <- {}
	// The order of this list becomes the priority list
	// NOTE has to have one entry for each eCoopAIType
	SetCoopAIPriority(eCoopAIType.mortarTitan)
	SetCoopAIPriority(eCoopAIType.empTitan)
	SetCoopAIPriority(eCoopAIType.nukeTitan)
	SetCoopAIPriority(eCoopAIType.suicideSpectre)
	SetCoopAIPriority(eCoopAIType.sniperSpectre)
	SetCoopAIPriority(eCoopAIType.cloakedDrone)
	SetCoopAIPriority(eCoopAIType.titan)
	SetCoopAIPriority(eCoopAIType.spectre)
	SetCoopAIPriority(eCoopAIType.grunt)

	TimerInit("Announce_PlayerDied", 20.0)
	TimerInit("Announce_PlayerRespawned", 60.0)
	TimerInit("Nag_KillStragglers", 90.0)
	TimerInit("Nag_GeneratorStatus_Global", 15.0)
	TimerInit("Nag_GeneratorHealth", 40.0)
	TimerInit("Nag_GeneratorStatus_ShieldDamage", 40.0)
	TimerInit("Nag_HoldTheLine", 120.0)
	TimerInit("Nag_GeneratorThreat", 45.0)
	TimerInit("Nag_HighPopWarning", 45.0)

	SetServerVar("aiLethality", eAILethality.Default)
	level.oldConnectedPlayersNum <- 0
}

function EntitiesDidLoad() {
	Weapon_SetDespawnTime(10) //optimization since we have soo many enemies dropping weapons.

	GeneratorThreat_Register(eCoopAIType.nukeTitan, GeneratorThreatCallback_TitanDistanceCheck, "CoopTD_GeneratorProximity_NukeTitan", 60.0, "npc_titan", eSubClass.nukeTitan)
	GeneratorThreat_Register(eCoopAIType.empTitan, GeneratorThreatCallback_ArcTitans, "CoopTD_GeneratorThreat_ArcTitan", 60.0, "npc_titan", eSubClass.empTitan)

	GeneratorThreat_Register(eCoopAIType.mortarTitan, GeneratorThreatCallback_MortarTitans, "CoopTD_GeneratorThreat_MortarTitans", 60.0, "npc_titan", eSubClass.mortarTitan)
	GeneratorThreat_Register(eCoopAIType.suicideSpectre, GeneratorThreatCallback_SuicideSpectres, "CoopTD_GeneratorThreat_SuicideSpectres", 60.0, "npc_spectre", eSubClass.suicideSpectre)
	// HACK this spectre one will work for regular spectres and/or grunts
	GeneratorThreat_Register(eCoopAIType.spectre, GeneratorThreatCallback_Infantry, "CoopTD_GeneratorThreat_Infantry", 60.0, null, null)

	// only do high population VO warnings for AITypes that have VO written
	// (Setting these up here bc the setup function needs globalized functions to be registered)
	level.aiTypeHighPopVO <- {}
	AddAITypeHighPopulationVO(eCoopAIType.empTitan, "CoopTD_HighPop_ArcTitans", "npc_titan", eSubClass.empTitan, 60.0)
	AddAITypeHighPopulationVO(eCoopAIType.nukeTitan, "CoopTD_HighPop_NukeTitans", "npc_titan", eSubClass.nukeTitan, 60.0)
	AddAITypeHighPopulationVO(eCoopAIType.mortarTitan, "CoopTD_HighPop_MortarTitans", "npc_titan", eSubClass.mortarTitan, 60.0)
	AddAITypeHighPopulationVO(eCoopAIType.suicideSpectre, "CoopTD_HighPop_SuicideSpectres", "npc_spectre", eSubClass.suicideSpectre, 60.0)

	// error check announce VO conversations, now that conversations are set up
	ValidateCustomWaveVO()
}

function CoopTD_Prematch() {
	Assert(GetGameState() == eGameState.Prematch)
	Assert(level.TowerDefenseGenLocation.origin != null, "This map is not set up for Fireteam Defense (coop)")

	TowerDefenseCreateGenerator()

	if (!Flag("ClassicMP_UsingCustomIntro") || Coop_HasRestarted()) {
		CoopMusicPlay(eMusicPieceID.COOP_OPENING)
		level.introMusicStartTime = Time()
	}

	if (Coop_HasRestarted()) {
		if (!Flag("ClassicMP_UsingCustomIntro"))
			ClearClassicDropships()

		Coop_DecrementRestarts()

		thread CoopTD_AnnounceRestart()
	} else {
		if (level.nv.coopStartTime == null)
			level.nv.coopStartTime = Time() + GetCustomIntroLength()

		thread TrackHarvesterHealthStatusOverTime(Time() - level.nv.coopStartTime)
	}
}

function CoopTD_GamePlaying() {
	if (!level.firstSpawnDone)
		level.firstSpawnDone = true

	if (Flag("ClassicMP_UsingCustomIntro")) {
		CoopMusicPlay(eMusicPieceID.COOP_OPENING)
		level.introMusicStartTime = Time()

		// usually this happens in the intro dropship callback (for better timing) but here we need to pop it when the players rez in
		if (!Flag("GeneratorBeam_On"))
			thread GeneratorStart_AndThink()
	}

	if (!Flag("CoopPlayerConnectionMessagingEnabled"))
		delaythread(COOP_PLAYER_CONNECTION_MESSAGING_BUFFER_TIME) FlagSet("CoopPlayerConnectionMessagingEnabled")

	thread TowerDefense_Main()

	// delay is necessary because other places in gamestate will try to reset player Titan respawn timer as we go from Prematch to Playing
	thread CoopTD_TryGivePlayersTurretsAndTitans(1.7)

	TowerDefenseDifficultyRamp()
}

// gives a new titan if one was previously earned
function CoopTD_TryGivePlayersTurretsAndTitans(delay = 0.0) {
	level.ent.EndSignal("OnDestroy")

	if (delay > 0)
		wait delay

	local players = GetPlayerArray()
	local playersGotTitans = []
	foreach(player in players) {
		if (CoopTD_CheckPlayerTitanAvailable(player)) {
			//SetTitanRespawnTimer( player, 1.0 )
			ForceTitanBuildComplete(player)
			playersGotTitans.append(player)
		}
	}

	// give sentries earlier to avoid player frustration
	printt("Restart info:", Coop_HasRestarted(), level.lastWaveIdx)
	if (Coop_HasRestarted() && level.lastWaveIdx != null && level.lastWaveIdx > 0) {
		GiveSentryTurretToPlayersOnTeam(level.nv.attackingTeam)
		wait 4.25
	}

	foreach(player in playersGotTitans) {
		if (!IsAlive(player))
			continue

		// HACK there are debounces and stuff that prevent this from playing reliably
		player.s.replacementTitanReady_lastNagTime == 0 // override nag timer so Sarah will talk about it
		thread TryReplacementTitanReadyAnnouncement(player)
	}
}

function TowerDefense_WinnerDetermined() {
	thread TowerDefense_WinnerDetermined_Threaded()
}

function TowerDefense_WinnerDetermined_Threaded() {
	Assert(GetGameState() == eGameState.WinnerDetermined)

	// has to match timing in Coop_DelayedWinnerDetermined
	local totalWait = GetWinnerDeterminedWait()

	if (Flag("TDGeneratorDestroyed")) {
		// LOST BUT WILL CHECKPOINT RESTART
		if (Coop_PlayersHaveRestartsLeft()) {
			local postMessageWait = COOP_POST_HUDSPLASH_VO_WAIT_LONG
			local postConvWait = totalWait - postMessageWait

			GeneratorBeamStop()

			CoopMusicPlay(eMusicPieceID.COOP_WAVELOST)

			printt("Coop objective restarting, restart #:", GetRoundScoreLimit_FromPlaylist() - Coop_GetNumRestartsLeft())

			MessageToTeam(level.nv.attackingTeam, eEventNotifications.CoopTDWaveLost) // first say we lost
			wait postMessageWait
			PlayConversationToCoopTeam("CoopTD_WaveFailed")

			Coop_ResetTeamScores()
			level.nv.TDScoreboardDisplayWaveInfo = false // Hide wave info on the scoreboard

			wait postConvWait

			// Remember here whether they'd earned a titan based on time, because when gamestate goes back to Prematch it'll be reset in global scripts
			foreach(player in GetPlayerArray())
			if (CoopTD_CheckPlayerTitanAvailable(player) && !("titanEarned" in player.s))
				player.s.titanEarned <- true

			Coop_KillAllEnemies()
		}
		// LOST AND IT'S GAME OVER
		else {
			local postConvWait = totalWait - COOP_DEFEAT_ANNOUNCEMENT_LENGTH

			//End of Wave Team Score Events doesn't trigger in defeat. All other events only need to happen if a wave is beat.
			PlayTeamScoreEvent(eCoopTeamScoreEvents.enemies_killed)
			GeneratorBeamStop()

			Coop_SetObjectiveFailed()
			thread AwardEndOfMatchAwards(1)
			local players = GetPlayerArray()
			foreach(player in players) {
				FinalPlayerUpdate(player)
			}
			thread Coop_EOG_DefeatAnnouncement()
			CoopMusicPlay(eMusicPieceID.COOP_GAMELOST)

			wait COOP_DEFEAT_ANNOUNCEMENT_LENGTH

			Coop_EOG_Harvester_Debrief(COOP_DEFEAT_ANNOUNCEMENT_LENGTH)

			wait postConvWait - COOP_POST_MATCH_SCREEN_FADE_DURATION

			local players = GetPlayerArray()
			foreach(player in players) {
				ScreenFade(player, 0, 2, 1, 255, COOP_POST_MATCH_SCREEN_FADE_DURATION, 0.0, 0x0002 | 0x0008)
				MuteAll(player, COOP_POST_MATCH_SCREEN_FADE_DURATION)
			}

			wait COOP_POST_MATCH_SCREEN_FADE_DURATION

			level.nv.TDScoreboardDisplayWaveInfo = false // Hide wave info on the scoreboard
			Coop_KillAllEnemies()
			SetGameState(eGameState.Postmatch)
		}
	}
	// WINNERS AND IT'S GAME OVER
	else {
		level.nv.TDCurrWave = null // forces enemy counter hud near minimap to hide

		local postConvWait = totalWait - COOP_VICTORY_ANNOUNCEMENT_LENGTH

		Coop_KillAllEnemies()

		Coop_SetObjectiveComplete()
		thread AwardEndOfMatchAwards(1)
		local players = GetPlayerArray()
		foreach(player in players) {
			FinalPlayerUpdate(player)
		}
		CoopMusicPlay(eMusicPieceID.COOP_GAMEWON)

		thread Coop_EOG_VictoryAnnouncement()

		wait COOP_VICTORY_ANNOUNCEMENT_LENGTH

		Coop_EOG_Harvester_Debrief(COOP_VICTORY_ANNOUNCEMENT_LENGTH)

		wait postConvWait - COOP_POST_MATCH_SCREEN_FADE_DURATION

		local players = GetPlayerArray()
		foreach(player in players) {
			ScreenFade(player, 0, 2, 1, 255, COOP_POST_MATCH_SCREEN_FADE_DURATION, 0.0, 0x0002 | 0x0008)
			MuteAll(player, COOP_POST_MATCH_SCREEN_FADE_DURATION)
		}

		wait COOP_POST_MATCH_SCREEN_FADE_DURATION

		SetGameState(eGameState.Postmatch)
	}
}

function Coop_EOG_VictoryAnnouncement() {
	MessageToTeam(level.nv.attackingTeam, eEventNotifications.CoopTDWon)

	wait COOP_POST_HUDSPLASH_VO_WAIT_LONG
	PlayConversationToCoopTeam("CoopTD_WonAnnouncement")

	wait COOP_EOG_TIME_BETWEEN_ANNOUNCEMENT_AND_STARS - COOP_POST_HUDSPLASH_VO_WAIT_LONG

	local players = GetPlayerArray()
	foreach(player in players)
	Remote.CallFunction_NonReplay(player, "ServerCallback_DisplayEOGStars", COOP_EOG_STAR_DISPLAY_TIME)
}

function Coop_EOG_DefeatAnnouncement() {
	MessageToTeam(level.nv.attackingTeam, eEventNotifications.CoopTDLost)
	wait COOP_POST_HUDSPLASH_VO_WAIT_LONG
	PlayConversationToCoopTeam("CoopTD_LostAnnouncement")

	wait COOP_EOG_TIME_BETWEEN_ANNOUNCEMENT_AND_STARS - COOP_POST_HUDSPLASH_VO_WAIT_LONG

	local players = GetPlayerArray()
	foreach(player in players)
	Remote.CallFunction_NonReplay(player, "ServerCallback_DisplayEOGStars", COOP_EOG_STAR_DISPLAY_TIME)
}

function Coop_EOG_Harvester_Debrief(timeAfterEndOfGame) {
	thread EOG_StaggeredRemoteCallFunctions(timeAfterEndOfGame)
}

function EOG_StaggeredRemoteCallFunctions(timeAfterEndOfGame) {
	local topDamageSources = GetTopDamageSourcesFromGeneratorHistory()
	local topEnemyType = topDamageSources[0].aiType
	local topDamageRatio = topDamageSources[0].damageRatio
	local secondEnemyType = topDamageSources[1].aiType
	local secondDamageRatio = topDamageSources[1].damageRatio
	local thirdEnemyType = topDamageSources[2].aiType
	local thirdDamageRatio = topDamageSources[2].damageRatio
	local fourthEnemyType = topDamageSources[3].aiType
	local fourthDamageRatio = topDamageSources[3].damageRatio

	local timeDataPoints = GetPrioritizedTimeDataPoints(timeAfterEndOfGame)
	local waveDataPoints = GetWaveDataPointTable()
	local players = GetPlayerArray()
	foreach(player in players) {
		player.FreezeControlsOnServer(false)
		player.SetInvulnerable()
		AddCinematicFlag(player, CE_FLAG_EOG_STAT_DISPLAY)
		for (local i = 0; i < waveDataPoints.len(); i++) {
			Remote.CallFunction_NonReplay(player, "ServerCallback_SetHarvesterWaveDataPoints", waveDataPoints[i][0], waveDataPoints[i][1], waveDataPoints[i][2])
		}
		for (local i = 0; i <= HARVESTER_GRAPH_DATA_POINTS; i++) {
			Remote.CallFunction_NonReplay(player, "ServerCallback_SetHarvesterTimeDataPoints", timeDataPoints[i][0], timeDataPoints[i][1], timeDataPoints[i][2])
		}
		Remote.CallFunction_NonReplay(player, "ServerCallback_HarvesterDebrief", topEnemyType, topDamageRatio, secondEnemyType, secondDamageRatio, thirdEnemyType, thirdDamageRatio, fourthEnemyType, fourthDamageRatio)
		wait 0
	}
}

function GetTopDamageSourcesFromGeneratorHistory() {
	local damageSourceArray = []
	foreach(aiTypeID, attackInfo in level.generatorAttackHistory) {
		if (aiTypeID == "global")
			continue

		local table = {}
		table.aiType <- aiTypeID
		table.damage <- attackInfo.actualDamage
		damageSourceArray.append(table)
	}

	damageSourceArray.sort(HighestDamageSort)
	damageSourceArray.resize(COOP_EOG_MAX_DAMAGE_SOURCES)

	local totalDamage = level.generatorAttackHistory.global.actualDamage
	foreach(table in damageSourceArray) {
		if (totalDamage == 0)
			table.damageRatio <- 0
		else
			table.damageRatio <- (table.damage.tofloat() / totalDamage.tofloat() * 100).tointeger()
	}

	return damageSourceArray
}

function HighestDamageSort(a, b) {
	if (a.damage > b.damage)
		return -1
	if (a.damage < b.damage)
		return 1
	return 0
}

function CoopTD_Postmatch() {
	level.ent.Signal("GameEnd")
	// ReportDevStat_RoundEnd()


	level.ui.showGameSummary = true

	if (IsMatchmakingServer()) {
		if (!level.sendingPlayersAway) {
			level.sendingPlayersAway = true
			SendAllPlayersToPartyScreen()
		}
	} else {
		Coop_TryReturnToLobby()
	}
}

function CoopTD_AnnounceRestart(delay = 0.0) {
	level.ent.EndSignal("OnDestroy")

	if (delay > 0)
		wait delay

	MessageToTeam(level.nv.attackingTeam, eEventNotifications.CoopTDWaveRestart)
	wait 1.0
	PlayConversationToCoopTeam("CoopTD_WaveRestarting")

	wait 3.5

	foreach(player in GetPlayerArray())
	if (CoopTD_CheckPlayerTitanAvailable(player))
		PlayConversationToPlayer("CoopTD_TitanReadyNag_Bish", player)
}

// Basically checks if the player has ever earned a titan
function CoopTD_CheckPlayerTitanAvailable(player) {
	if (Riff_TitanAvailability() == eTitanAvailability.Never)
		return false

	if (player.titansBuilt)
		return true

	if (player.IsTitanReady())
		return true

	if ("titanEarned" in player.s)
		return true

	return false
}

/************************************************************************************************\

 ######  ######## ######## ##     ## ########
##    ## ##          ##    ##     ## ##     ##
##       ##          ##    ##     ## ##     ##
 ######  ######      ##    ##     ## ########
      ## ##          ##    ##     ## ##
##    ## ##          ##    ##     ## ##
 ######  ########    ##     #######  ##

\************************************************************************************************/
function InitTeamPlayerScoring() {
	//Index goes from 1 - 4 instead of 0 - 3 because player.GetEntIndex() returns 1 - 4.
	local maxPlayers = GetCurrentPlaylistVarInt("max_players", 4)

	for (local i = 1; i <= maxPlayers; i++) {
		level.playerTeamScoreWaveStart[i] <- 0
	}
}

function CoopTD_ClientConnected(player) {
	delaythread(0.1) TowerDefenseDifficultyRamp() //the delaythread is necessary because if we check this frame - nothing has changed in terms of player count
	ResetPlayerKillHistory(player)
}

function CoopTD_ClientDisconnected(player) {
	level.playerTeamScoreWaveStart[player.GetEntIndex()] = 0
	delaythread(0.1) TowerDefenseDifficultyRamp() //the delaythread is necessary because if we check this frame - nothing has changed in terms of player count
}

function TowerDefenseDifficultyRamp() {
	if (GetGameState() != eGameState.Playing)
		return

	local players = GetPlayerArray()

	local currLethality = Riff_AILethality()
	local newLethality = null

	//eventually remove this - but for whatever reason the coop playlist isn't setting this
	switch (players.len()) {
		case 0:
		case 1:
		case 2:
		case 3: //low
			newLethality = eAILethality.TD_Low
			NPCSetAimConeFocusParams(3, 0.6)
			NPCSetAimPatternFocusParams(2.0, 2.75, 0.35)
			break

		case 4: //medium
			newLethality = eAILethality.TD_Medium
			NPCSetAimConeFocusParams(2.5, 0.5)
			NPCSetAimPatternFocusParams(1.25, 1.75, 0.5)
			break

		default:
			Assert(0, "coop does not support more than 4 players")
			//these are default game values
			//NPCSetAimConeFocusParams( 3, 0.6 )  //x3 spread on first enemy spotted, then .6s to narrow back to 1
			//NPCSetAimPatternFocusParams( 2.5, 3.5, 0.2 )  //2.5s to focus the spread pattern, 3.5s if he was not in your fov, .2x spread pattern if not in fov ( makes it worse )
			break
	}

	local event = null

	//are we up or down?
	if (level.oldConnectedPlayersNum < players.len())
		event = eEventNotifications.CoopPlayerConnected
	else if (level.oldConnectedPlayersNum > players.len())
		event = eEventNotifications.CoopPlayerDisconnected

	//save the new count
	level.oldConnectedPlayersNum = players.len()

	//more importantly, has our lethality changed?
	if (newLethality > currLethality)
		event = eEventNotifications.CoopDifficultyUp
	else if (newLethality < currLethality)
		event = eEventNotifications.CoopDifficultyDown

	//if we have a new event and it's not the start of the game... send the message
	if (event != null && Flag("CoopPlayerConnectionMessagingEnabled"))
		MessageToTeam(level.nv.attackingTeam, event)

	if (newLethality == currLethality)
		return

	SetServerVar("aiLethality", newLethality)

	local spectreScalar, titanScalar, suicide_titanDmg, suicide_pilotDmg

	if (newLethality > eAILethality.TD_Low) {
		spectreScalar = TD_MED_SCALAR_SPECTREHEALTH / TD_LOW_SCALAR_SPECTREHEALTH
		titanScalar = TD_MED_SCALAR_TITANHEALTH / TD_LOW_SCALAR_TITANHEALTH
		suicide_titanDmg = TD_MED_SUICIDE_TITANDMG
		suicide_pilotDmg = TD_MED_SUICIDE_PILOTDMG
	} else {
		spectreScalar = TD_LOW_SCALAR_SPECTREHEALTH / TD_MED_SCALAR_SPECTREHEALTH
		titanScalar = TD_LOW_SCALAR_TITANHEALTH / TD_MED_SCALAR_TITANHEALTH
		suicide_titanDmg = TD_LOW_SUICIDE_TITANDMG
		suicide_pilotDmg = TD_LOW_SUICIDE_PILOTDMG
	}

	local spectres = GetNPCArrayByClass("npc_spectre")
	foreach(spectre in spectres) {
		if (IsSuicideSpectre(spectre)) {
			SetSuicideSpectreExplosionData(spectre, null, suicide_titanDmg, suicide_pilotDmg)
		} else {
			spectre.SetHealth(floor(spectre.GetHealth() * spectreScalar))
			spectre.SetMaxHealth(floor(spectre.GetMaxHealth() * spectreScalar))
			UpdateAILethality(spectre, spectre.GetEnemy())
		}
	}

	local titans = GetNPCArrayByClass("npc_titan")
	foreach(titan in titans) {
		titan.SetHealth(floor(titan.GetHealth() * titanScalar))
		titan.SetMaxHealth(floor(titan.GetMaxHealth() * titanScalar))
		SetTitanAccuracyAndProficiency(titan, newLethality)

		if (newLethality > eAILethality.TD_Low) {
			TitanUnlockRocketPods(titan)
			if (TitanHasRocketPods(titan))
				TitanEnableRocketPods(titan)
		} else {
			TitanDisableRocketPods(titan)
			TitanLockRocketPods(titan)
		}
	}
}

function TowerDefense_AddRoute(route, routeAlias = null, useForRandomSpawns = true) {
	Assert(typeof route == "array")
	Assert(route.len() >= 2)

	if (routeAlias == null)
		routeAlias = "defaultRoute_" + level.TowerDefenseRoutes.len()

	Assert(!(routeAlias in level.TowerDefenseRoutes), "TD route with alias " + routeAlias + " already set up!")

	level.TowerDefenseRoutes[routeAlias] <- route

	if (useForRandomSpawns)
		level.TowerDefenseRoutes_ForRandomSpawns[routeAlias] <- route
}

function CoopTD_GetNextDefaultSpawnRoute() {
	Assert(level.TowerDefenseRoutes_ForRandomSpawns.len(), "No tower defense routes set up to handle random spawns")

	if (level.TD_LastDefaultRouteIdx == -1)
		level.TD_LastDefaultRouteIdx = RandomInt(0, level.TowerDefenseRoutes_ForRandomSpawns.len())

	local thisRouteIdx = level.TD_LastDefaultRouteIdx + 1
	if (thisRouteIdx >= level.TowerDefenseRoutes_ForRandomSpawns.len())
		thisRouteIdx = 0

	local idx = 0
	local thisRoute = null
	foreach(alias, route in level.TowerDefenseRoutes_ForRandomSpawns) {
		if (idx == thisRouteIdx) {
			thisRoute = route
			break
		}

		idx++
	}
	Assert(thisRoute != null)

	level.TD_LastDefaultRouteIdx = thisRouteIdx

	return thisRoute
}

function TowerDefense_AddGeneratorLocation(origin, angles, skipAssert = false) {
	level.TowerDefenseGenLocation.origin = origin
	level.TowerDefenseGenLocation.angles = angles

	if (!skipAssert)
		Assert(TraceLineSimple(origin + Vector(100), origin, null) > 0.999, "Harvester origin is in solid")
}

function IsTowerDefenseValid() {
	if (!level.TowerDefenseRoutes.len())
		return false

	if (level.TowerDefenseGenLocation.origin == null)
		return false

	return true
}

function GetAICountFromSpawnInfo(spawnInfo) {
	if (!("spawnFunc" in spawnInfo))
		return 0

	return GetAICountFromSpawnFunc(spawnInfo.spawnFunc)
}

function GetAICountFromSpawnFunc(spawnFunc) {
	local name = FunctionToString(spawnFunc)
	Assert(name in level.TowerDefense_RegisteredSpawnFuncs)

	return level.TowerDefense_RegisteredSpawnFuncs[name].count
}

function GetAITypeArrayFromSpawnFunc(spawnFunc) {
	local name = FunctionToString(spawnFunc)
	Assert(name in level.TowerDefense_RegisteredSpawnFuncs)

	local count = level.TowerDefense_RegisteredSpawnFuncs[name].count
	local aiTypes = level.TowerDefense_RegisteredSpawnFuncs[name].aiTypes

	if (count != aiTypes.len()) {
		Assert(aiTypes.len() == 1)
		local newTypes = []
		for (local i = 0; i < count; i++)
			newTypes.append(aiTypes[0])

		return newTypes
	} else {
		Assert(aiTypes.len() == count)
		return aiTypes
	}
}

function GetAITypeArrayFromWave(waveInfo) {
	local spawnFuncsChecked = []
	local waveAiTypes = []

	foreach(spawnInfo in waveInfo.spawngroups) {
		// don't count pause events
		if (IsWavePause(spawnInfo))
			continue

		local spawnFunc = spawnInfo.spawnFunc
		local spawnFuncName = spawnFunc.getinfos().name

		local funcAlreadyChecked = false
		foreach(checkedFuncName in spawnFuncsChecked) {
			if (spawnFuncName == checkedFuncName) {
				funcAlreadyChecked = true
				break
			}
		}

		if (funcAlreadyChecked)
			continue

		spawnFuncsChecked.append(spawnFuncName)

		local spawnfuncAiTypes = GetAITypeArrayFromSpawnFunc(spawnFunc) //an array of strings that are the types of ai spawned from this func
		foreach(aiType in spawnfuncAiTypes) {
			local aiTypeAlreadyAdded = false
			foreach(addedAiType in waveAiTypes) {
				if (aiType == addedAiType) {
					aiTypeAlreadyAdded = true
					break
				}
			}

			if (aiTypeAlreadyAdded)
				continue

			waveAiTypes.append(aiType)
		}
	}

	return waveAiTypes
}

function GetAICountFromWave(waveInfo, testType) {
	local count = 0
	foreach(spawnInfo in waveInfo.spawngroups) {
		// don't count pause events
		if (IsWavePause(spawnInfo))
			continue

		local aiTypes = GetAITypeArrayFromSpawnFunc(spawnInfo.spawnFunc) //an array of strings that are the types of ai spawned from this func
		foreach(aiType in aiTypes) {
			if (testType == aiType)
				count++
		}
	}

	if (!count)
		count = -1
	return count
}
Globalize(GetAICountFromWave)

function _RegisterSpawnFuncInternal(spawnFunc, count, aiTypes) {
	Assert(IsFunction(spawnFunc))
	Assert(IsArray(aiTypes))

	local name = FunctionToString(spawnFunc)
	Assert(!(name in level.TowerDefense_RegisteredSpawnFuncs))

	local register = {}
	register.spawnFunc <- spawnFunc
	register.count <- count
	register.aiTypes <- aiTypes

	level.TowerDefense_RegisteredSpawnFuncs[name] <- register
}

function TowerDefense_RegisterSpawnFunction(spawnFunc, count, aiTypes) {
	Assert(IsFunction(spawnFunc))
	Assert(IsArray(aiTypes))

	local name = FunctionToString(spawnFunc)
	Assert(!(name in level.TowerDefense_RegisteredSpawnFuncs))
	Assert(!(name in level.TowerDefense_AddedSpawnFuncs))

	local register = {}
	register.spawnFunc <- spawnFunc
	register.count <- count
	register.aiTypes <- aiTypes

	level.TowerDefense_AddedSpawnFuncs.append(register)
}

function TowerDefense_AddWave(waveNameAlias = null) {
	local waveNameID = null
	if (waveNameAlias != null)
		waveNameID = GetWaveNameIdByAlias(waveNameAlias)

	local waveInfo = {}
	waveInfo.spawngroups <- []
	waveInfo.waveIdx <- level.TowerDefenseWaves.len()
	waveInfo.waveNameID <- waveNameID
	waveInfo.announceVO <- null
	waveInfo.waveCompleteVO <- null
	waveInfo.postWaveBreakTime <- null

	level.TowerDefenseWaves.append(waveInfo)
	return waveInfo
}
Globalize(TowerDefense_AddWave)


function Wave_AddPause(waveInfo, pauseTime, runDependency = null) {
	Assert(typeof waveInfo == "table")
	Assert("spawngroups" in waveInfo)

	if (runDependency != null)
		Wave_VerifyRunDependency(waveInfo, runDependency)

	local spawnInfo = {}
	spawnInfo.id <- waveInfo.spawngroups.len()
	spawnInfo.hasProcessed <- false
	spawnInfo.runDependency <- runDependency
	spawnInfo.wavePause <- pauseTime

	waveInfo.spawngroups.append(spawnInfo)
}
Globalize(Wave_AddPause)


function IsWavePause(spawnInfo) {
	return ("wavePause" in spawnInfo)
}

// error checks that a group dependency points to a group that exists in this waveInfo
function Wave_VerifyRunDependency(waveInfo, runDependency, groupName = null) {
	if (groupName != null)
		Assert(runDependency != groupName, "Group name and dependent group name can't be the same: " + groupName)

	local foundOne = false
	foreach(spawnInfo in waveInfo.spawngroups) {
		// pauses don't have names
		if (IsWavePause(spawnInfo))
			continue

		if (spawnInfo.groupName == runDependency) {
			foundOne = true
			break
		}
	}

	Assert(foundOne, "Can't find spawn group named '" + runDependency + "'")
}

function Wave_AddSpawn(waveInfo, spawnFunc, groupName = null, runDependency = null, routeAlias = null) {
	Assert(typeof waveInfo == "table")
	Assert("spawngroups" in waveInfo)

	Assert(typeof spawnFunc == "function", "Wave_AddSpawn: bad spawnFunc (don't use quotes)- \"" + spawnFunc.tostring() + "\"")

	if (groupName == null)
		groupName = "default"

	// error check group dependency setup
	if (runDependency != null) {
		Wave_VerifyRunDependency(waveInfo, runDependency, groupName)

		local foundOne = false
		foreach(spawnInfo in waveInfo.spawngroups) {
			if (IsWavePause(spawnInfo))
				continue

			if (spawnInfo.groupName == runDependency) {
				foundOne = true
				break
			}
		}

		Assert(foundOne, "Can't find spawn group named '" + runDependency + " that group '" + groupName + "' depends on.")
	}

	local route = null
	if (routeAlias != null) {
		// error check route
		Assert(routeAlias in level.TowerDefenseRoutes, "Wave spawn group setup failed, route doesn't exist! " + routeAlias)
		route = level.TowerDefenseRoutes[routeAlias]
	} else
		route = CoopTD_GetNextDefaultSpawnRoute()

	local spawnInfo = {}
	spawnInfo.id <- waveInfo.spawngroups.len()
	spawnInfo.hasProcessed <- false
	spawnInfo.spawnFunc <- spawnFunc
	spawnInfo.groupName <- groupName
	spawnInfo.runDependency <- runDependency
	spawnInfo.routeAlias <- routeAlias
	spawnInfo.route <- route

	waveInfo.spawngroups.append(spawnInfo)

}
Globalize(Wave_AddSpawn)


function Wave_SetAnnounceVO(waveInfo, announceVO) {
	Assert(typeof waveInfo == "table")
	Assert("announceVO" in waveInfo)
	Assert(waveInfo.announceVO == null, "Announce VO already set up for wave " + waveInfo.waveIdx)

	waveInfo.announceVO = announceVO
}
Globalize(Wave_SetAnnounceVO)


function Wave_SetWaveCompleteVO(waveInfo, waveCompleteVO) {
	Assert(typeof waveInfo == "table")
	Assert("waveCompleteVO" in waveInfo)
	Assert(waveInfo.waveCompleteVO == null, "Wave Complete VO already set up for wave " + waveInfo.waveIdx)

	waveInfo.waveCompleteVO = waveCompleteVO
}
Globalize(Wave_SetWaveCompleteVO)


function ValidateCustomWaveVO() {
	foreach(waveInfo in level.TowerDefenseWaves) {
		if (waveInfo.announceVO != null)
			Assert((waveInfo.announceVO in level.ConvToIndex), "Bad wave announce VO soundalias (check for typos): '" + announceVO + "'")

		if (waveInfo.waveCompleteVO != null)
			Assert((waveInfo.waveCompleteVO in level.ConvToIndex), "Bad wave complete VO soundalias (check for typos): '" + waveCompleteVO + "'")
	}
}

function Wave_SetBreakTime(waveInfo, waveBreakTime) {
	Assert(typeof waveInfo == "table")
	Assert("postWaveBreakTime" in waveInfo)
	Assert(waveBreakTime >= 0)

	waveInfo.postWaveBreakTime = waveBreakTime
}
Globalize(Wave_SetBreakTime)


function CoopTeam_PingWaveRouteOnMinimaps(route, delay = 0.0, duration = null) {
	level.ent.EndSignal("OnDestroy")

	local origin = route[0]

	if (delay > 0)
		wait delay

	thread CoopTeam_PingMinimaps(origin, duration)
}

function CoopTeam_PingMinimaps(origin, duration) {
	level.ent.EndSignal("OnDestroy")

	local team = level.nv.attackingTeam
	local endTime = Time() + duration

	local randMin = -600
	local randMax = 600

	local minWait = 0.6
	local maxWait = 1.0

	while (Time() < endTime) {
		origin += Vector(RandomInt(randMin, randMax), RandomInt(randMin, randMax), 0) // after first ping do little offsets

		Minimap_CreatePingForTeam(team, origin, "vgui/HUD/titanFiringPing", 0.75)

		wait RandomFloat(minWait, maxWait)
	}
}

function CoopTeam_FlashMinimaps() {
	local players = GetLivingPlayers()

	foreach(player in players) {
		local handle = player.GetEncodedEHandle()
		Remote.CallFunction_Replay(player, "ServerCallback_MinimapPulse", handle)
	}
}


/************************************************************************************************\

##     ##    ###    #### ##    ##
###   ###   ## ##    ##  ###   ##
#### ####  ##   ##   ##  ####  ##
## ### ## ##     ##  ##  ## ## ##
##     ## #########  ##  ##  ####
##     ## ##     ##  ##  ##   ###
##     ## ##     ## #### ##    ##

\************************************************************************************************/
function TowerDefense_Main() {
	Assert(level.TowerDefenseRoutes.len())

	FlagSet("COOBJ_TowerDefense")

	level.nv.missionTypeID = eMissionType.TOWERDEFENSE
	level.nv.TDCurrWave = null // forces enemy counter hud near minimap to hide

	if (!level.TD_isInited)
		TowerDefenseInit()

	OnThreadEnd(
		function(): () {
			level.nv.missionTypeID = null
			FlagClear("COOBJ_TowerDefense")
			if (Flag("TDGeneratorDestroyed")) {
				if (GamePlaying())
					SetWinner(GetOtherTeam(level.nv.attackingTeam))
			} else {
				if (GamePlaying())
					SetWinner(level.nv.attackingTeam)
			}
		}
	)

	Assert(level.introMusicStartTime != -1)

	// buffer time between dropship exit/ game mode announce VO & music/ harvester powerup ceremony, and first wave. Mostly timed to match intro music dying down
	local introMusicBufferTime = 22.5

	if (Coop_HasRestarted())
		introMusicBufferTime -= 4.0 // we want less buffer time for a checkpoint restart

	local introMusicEndTime = level.introMusicStartTime + introMusicBufferTime
	if (Time() < introMusicEndTime)
		wait(introMusicEndTime - Time())

	waitthread TowerDefense_WaveLoop()
}

// wrapper: we're using the same method as the normal game mode announce that autoplays the first time
function TowerDefense_PlayGameModeAnnounce(delay = 0) {
	PlayConversationToCoopTeam(GetGameModeAnnouncement())
}

function TowerDefense_WaveLoop() {
	FlagClear("TDGeneratorDestroyed")
	FlagEnd("TDGeneratorDestroyed")
	FlagEnd("ObjectiveComplete")
	FlagEnd("ObjectiveFailed")

	OnThreadEnd(
		function(): () {
			FlagClear("CoopTD_WaveCombatInProgress")
			ShowAllSentryTurretsOnHud()
		}
	)

	//This is set to the requirement for 3 stars, not the actual max.
	level.nv.TDMaxTeamScore = Coop_GetTeamScore()
	level.nv.TDNumWaves = level.TowerDefenseWaves.len()
	local playerTeam = level.nv.attackingTeam
	local otherTeam = GetOtherTeam(level.nv.attackingTeam)
	local squadSize = GetSpawnSquadSize(otherTeam)

	Assert(level.TowerDefenseWaves.len(), "need to add waves for tower defense mode to work")

	local wasInGodMode = null

	foreach(waveNum, waveInfo in level.TowerDefenseWaves) {
		// check if we need to skip this wave
		if (level.lastWaveIdx != null && waveNum < level.lastWaveIdx) {
			printt("Wave Restart: Skipping wave", waveNum + 1)
			continue
		}

		ResetGeneratorAttackStreakHistory()
		level.nv.TDScoreboardDisplayWaveInfo = false // hide wave info on the scoreboard until new guys are spawned in.

		local isCheckpointRestart = Coop_HasRestarted() && (level.lastWaveIdx == null || waveNum == level.lastWaveIdx)
		local isFirstWavePlayed = (waveNum == 0 && !isCheckpointRestart)
		local isFinalWave = (waveNum == level.TowerDefenseWaves.len() - 1)

		local waveBreakMusicID = eMusicPieceID.COOP_WAITINGFORWAVE
		if (isFirstWavePlayed)
			waveBreakMusicID = eMusicPieceID.COOP_WAITINGFORFIRSTWAVE
		else if (isFinalWave)
			waveBreakMusicID = eMusicPieceID.COOP_WAITINGFORFINALWAVE

		CoopMusicPlay_ForceLoop(waveBreakMusicID)

		UpdateNumbersForNextWave(level.TowerDefenseWaves[waveNum])
		local currWave = waveNum + 1
		level.nv.TDCurrWave = currWave
		level.nv.TDCurrWaveNameID = waveInfo.waveNameID
		level.nv.TDWaveStartTime = Time()
		level.teamScoreWaveStart = level.nv.TDCurrentTeamScore
		Add_WaveStartOrEnd_HarvesterStatus()

		local harvesterWaveStartingHealth = level.nv.TDGeneratorHealth

		local waveStartWarningTime = 10.0 // time after wave announce, before spawning starts
		local waveClearBufferTime = 1.0

		// set wave break timer
		local waveBreakTime = 10.0
		if (isCheckpointRestart) {
			waveBreakTime = 7.0
		} else if (isFirstWavePlayed) {
			// first wave- short wait
			waveBreakTime = 3.0
		} else if (level.lastWaveIdx != null) {
			// check last wave info to see if we need to do a custom wave break time
			local lastWave = level.TowerDefenseWaves[level.lastWaveIdx]

			if (lastWave.postWaveBreakTime != null)
				waveBreakTime = lastWave.postWaveBreakTime

			printt("Using custom wave break time:", waveBreakTime)
		}

		if (isFirstWavePlayed) {
			if (Riff_TitanAvailability() == eTitanAvailability.Never)
				PlayConversationToCoopTeam("CoopTD_NoTitansAvailable")

			waveBreakTime += 6.5

		}

		if (waveNum > 0 && !isCheckpointRestart) // we do it earlier on checkpoint restart
			GiveSentryTurretToPlayersOnTeam(playerTeam)

		level.nv.TDWaveTimer = waveBreakTime + waveStartWarningTime

		wait max(0, waveBreakTime)

		// let the client know to show wave info on the scoreboard.
		level.nv.TDScoreboardDisplayWaveInfo = true

		// splash message
		thread WaveAnnounceSplash(waveNum, waveInfo, isCheckpointRestart)

		// when we set the last wave idx, that's our checkpoint
		level.lastWaveIdx = waveNum

		wait waveStartWarningTime

		// record the starting health just before turning off god mode
		local generatorStartingHealth = level.nv.TDGeneratorHealth

		// turn off generator god mode when the wave starts
		if (wasInGodMode == false)
			Coop_SetGeneratorGodMode(false)

		FlagSet("CoopTD_WaveCombatInProgress")
		HideAllSentryTurretsOnHud()

		thread WaveActionMusicStart(waveNum + 1, level.TowerDefenseWaves.len(), 8.0)

		waitthread TowerDefense_WaveSpawnEnemies(waveNum, waveInfo, otherTeam)

		RemoveLeftoverCloakedDrones()

		FlagClear("CoopTD_WaveCombatInProgress")

		//wait a delay so nuke titans can do their final bit of damage
		wait 1.1

		// make generator invulnerable between waves
		wasInGodMode = Flag("GeneratorGodMode")
		Coop_SetGeneratorGodMode(true)

		// Regen generator shield when the wave is over.
		level.TowerDefenseGenerator.s.nextRegenTime = Time()

		if (isFinalWave)
			Add_TimeInterval_HarvesterStatus()

		// update player stats and give personal score bonuses
		local players = GetPlayerArray()
		local waveHighScore = 0
		local highScorers = []
		foreach(player in players) {
			local waveScore = player.GetAssaultScore() - level.playerTeamScoreWaveStart[player.GetEntIndex()]
			if (waveScore > waveHighScore) {
				waveHighScore = waveScore
				highScorers = [player]
			} else if (waveScore == waveHighScore) {
				highScorers.append(player)
			}

			level.playerTeamScoreWaveStart[player.GetEntIndex()] = player.GetAssaultScore()

			if (Generator_GetHealthRatio() <= 0.15)
				AddPlayerScore(player, "CoopSurvivor")

			if (isFinalWave && player.GetDeathCount() == 0)
				AddPlayerScore(player, "CoopImmortal")
		}

		foreach(player in highScorers)
		AddPlayerScore(player, "CoopWaveMvp")

		local isFlawlessWave = (harvesterWaveStartingHealth == level.nv.TDGeneratorHealth)
		EndOfWaveTeamScoreEvents(isFinalWave, isCheckpointRestart, isFlawlessWave)

		wait waveClearBufferTime

		if (!isFinalWave) {
			ShowAllSentryTurretsOnHud()
			CoopMusicPlay(eMusicPieceID.COOP_WAVEWON)

			local players = GetPlayerArray()
			foreach(player in players)
			Remote.CallFunction_Replay(player, "ServerCallback_TD_WaveFinished")

			wait COOP_POST_HUDSPLASH_VO_WAIT + 0.2 // HACK extra wait for network delay

			local healthLostDuringWave = generatorStartingHealth - level.nv.TDGeneratorHealth

			// Give coop players feedback about how they did
			local voAlias = "CoopTD_WaveComplete"
			if (waveInfo.waveCompleteVO != null)
				voAlias = waveInfo.waveCompleteVO // maybe the LD set up a custom one (ex: Rise tiny wave)
			else if (healthLostDuringWave == 0)
				voAlias = "CoopTD_WaveCompleteComment_Perfect"
			else if ((healthLostDuringWave.tofloat() / TD_GENERATOR_HEALTH.tofloat()) <= 0.1) // <= 10% of total health
				voAlias = "CoopTD_WaveCompleteComment_VeryGood"
			else if (Generator_GetHealthRatio() <= 0.15)
				voAlias = "CoopTD_WaveCompleteComment_CloseCall"

			PlayConversationToCoopTeam(voAlias)

			wait 5.5
		}
	}
}

function EndOfWaveTeamScoreEvents(wasFinalWave, isCheckpointRestart, wasFlawlessWave) {
	//Needs to happen first to clear temporary point value before more score gets added.
	PlayTeamScoreEvent(eCoopTeamScoreEvents.enemies_killed)

	if (wasFinalWave)
		PlayTeamScoreEvent(eCoopTeamScoreEvents.final_wave_complete)
	else
		PlayTeamScoreEvent(eCoopTeamScoreEvents.wave_complete)

	if (wasFlawlessWave)
	{
		PlayTeamScoreEvent(eCoopTeamScoreEvents.flawless_wave)

		foreach( player in GetPlayerArray() )
			Stats_IncrementStat(player, "game_stats", "coop_perfect_waves", 1)
	}

	//Events will play in the order they're called.
	if (wasFinalWave) {
		PlayTeamScoreEvent(eCoopTeamScoreEvents.harvester_health)
		local retriesRemaining = Coop_GetNumRestartsLeft()
		if (retriesRemaining > 1)
			PlayTeamScoreEvent(eCoopTeamScoreEvents.retries_bonus)
		else if (retriesRemaining == 1)
			PlayTeamScoreEvent(eCoopTeamScoreEvents.retry_bonus)
	}
}

function WaveAnnounceSplash(waveIdx, waveInfo, isCheckpointRestart) {
	FlagSet("WaveAnnounceInProgress")

	OnThreadEnd(
		function(): () {
			if (IsValid(level.ent))
				FlagClear("WaveAnnounceInProgress")
		}
	)

	local restartsRemaining = Coop_GetNumRestartsLeft()

	foreach(player in GetPlayerArray())
	Remote.CallFunction_Replay(player, "ServerCallback_TD_WaveAnnounce", waveIdx, waveInfo.waveNameID, isCheckpointRestart, restartsRemaining)

	// normal wave start VO
	wait COOP_POST_HUDSPLASH_VO_WAIT

	local voTime = 4.0
	local isFirstWavePlayed = false

	local conv = "CoopTD_WaveStarting"
	if (waveIdx == 0 && !isCheckpointRestart) // sounds weird to hear "first" on checkpoint restart of what is actual first wave
	{
		conv = "CoopTD_FirstWaveStarting"
		isFirstWavePlayed = true
	} else if (level.TowerDefenseWaves.len() > 1 && waveIdx == (level.TowerDefenseWaves.len() - 1)) // don't do final wave VO if there's only one wave
	{
		conv = "CoopTD_FinalWaveStarting"
		voTime = 5.8
	}

	local voEndWait = Time() + voTime

	PlayConversationToCoopTeam(conv)

	if (isCheckpointRestart && Coop_GetNumRestartsLeft() <= 1) {
		// make sure we waited long enough for any previous VO
		if (voEndWait > Time())
			wait voEndWait - Time()

		// number of retries reminder
		if (Coop_GetNumRestartsLeft() == 1)
			PlayConversationToCoopTeam("CoopTD_WaveRetriesReminder_2")
		else if (Coop_GetNumRestartsLeft() == 0)
			PlayConversationToCoopTeam("CoopTD_WaveRetriesReminder_Final")

		voEndWait = Time() + 3.5
	} else {
		wait 1.0 // pause between big centersplash and starting to list new AIs
	}

	// make sure we waited long enough for any previous VO
	if (voEndWait > Time())
		wait voEndWait - Time()

	// Get the aiTypes in this wave and sort by priority
	local waveAITypeStrs = GetAITypeArrayFromWave(waveInfo)

	local waveAITypeIDs = []
	foreach(aiTypeStr in waveAITypeStrs) {
		local waveAITypeID = GetCoopAITypeID_ByString(aiTypeStr)
		Assert(waveAITypeID != null, "Couldn't find eCoopAIType enum id for ai type: " + aiTypeStr)

		waveAITypeIDs.append(waveAITypeID)
	}
	waveAITypeIDs = AITypeArray_SortByPriority(waveAITypeIDs)

	local enemyAnnounceStart = Time()
	local postAnnounceVOBufferTime = 10.0

	thread WaveEnemiesAnnouncement(waveAITypeIDs)

	if (!isCheckpointRestart) {
		local announceVO = null
		if (waveInfo.announceVO != null)
			announceVO = waveInfo.announceVO
		else
			announceVO = TryGetNewEnemyAnnounceVO(waveAITypeIDs)

		if (announceVO != null) {
			level.newEnemyAnnouncementsPlayed[announceVO] <- 1
			PlayConversationToCoopTeam(announceVO)

			voEndWait = Time() + 6.5

			if (isFirstWavePlayed) {
				if (voEndWait > Time())
					wait voEndWait - Time()

				PlayConversationToCoopTeam("CoopTD_MinimapSpawnPingHint")
				voEndWait = Time() + 4.0
			}

			local elapsedTime = Time() - enemyAnnounceStart
			if (elapsedTime < postAnnounceVOBufferTime)
				wait postAnnounceVOBufferTime - elapsedTime
		}
	}

	if (voEndWait > Time())
		wait voEndWait - Time()
}

// script WaveEnemiesAnnouncement( [ eCoopAIType.nukeTitan, eCoopAIType.mortarTitan, eCoopAIType.empTitan, eCoopAIType.suicideSpectre ] )
function WaveEnemiesAnnouncement(waveAITypeIDs) {
	local maxAllowed = 9 // this is the highest # of vars we can send to a remote function at once
	Assert(waveAITypeIDs.len() <= maxAllowed)

	if (!waveAITypeIDs.len())
		return // nothing to announce

	// make the array we use to plug in the variables on the remote function call
	//  - fills in with nulls if we don't have enough aiTypeIDs
	local args = []
	for (local i = 0; i < maxAllowed; i++) {
		local val = null
		if (i < waveAITypeIDs.len())
			val = waveAITypeIDs[i]

		args.append(val)
	}

	foreach(player in GetPlayerArray())
	Remote.CallFunction_Replay(player, "ServerCallback_NewEnemyAnnounceCards", args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8])
}
Globalize(WaveEnemiesAnnouncement)


// Assume the array is populated in order from highest priority to lowest
function TryGetNewEnemyAnnounceVO(newAITypes) {
	local announceVO = null

	foreach(aiTypeID in newAITypes) {
		local aiTypeStr = GetCoopAITypeString_ByID(aiTypeID)
		local vo = null

		switch (aiTypeID) {
			case eCoopAIType.empTitan:
				vo = "CoopTD_EnemyAnnounce_ArcTitans"
				break

			case eCoopAIType.nukeTitan:
				vo = "CoopTD_EnemyAnnounce_NukeTitans"
				break

			case eCoopAIType.mortarTitan:
				vo = "CoopTD_EnemyAnnounce_MortarTitans"
				break

			case eCoopAIType.cloakedDrone:
				vo = "CoopTD_EnemyAnnounce_CloakDrone"
				break

			case eCoopAIType.suicideSpectre:
				vo = "CoopTD_EnemyAnnounce_SuicideSpectre"
				break

			case eCoopAIType.titan:
				vo = "CoopTD_EnemyAnnounce_Titans"
				break

			case eCoopAIType.spectre:
			case eCoopAIType.grunt:
				vo = "CoopTD_EnemyAnnounce_Infantry"
				break
		}

		if (vo != null && !(vo in level.newEnemyAnnouncementsPlayed)) {
			announceVO = vo
			break
		}
	}

	return announceVO
}

function WaveActionMusicStart(waveNum, lastWaveNum, timeDelay = 0.0) {
	level.ent.Signal("WaveActionMusic_Starting")
	level.ent.EndSignal("WaveActionMusic_Starting")

	level.ent.EndSignal("WaveSpawn_AllEnemiesDead")
	FlagEnd("TDGeneratorDestroyed")

	if (timeDelay > 0)
		wait timeDelay

	local waveFrac = waveNum.tofloat() / lastWaveNum.tofloat() // 0= wave1, 1= final wave

	local musicID = eMusicPieceID.COOP_ACTIONMUSIC_HIGH
	if (waveFrac < 0.334)
		musicID = eMusicPieceID.COOP_ACTIONMUSIC_LOW
	else if (waveFrac < 0.67)
		musicID = eMusicPieceID.COOP_ACTIONMUSIC_MED
	else if (lastWaveNum > 1 && waveFrac == 1.0)
		musicID = eMusicPieceID.COOP_FINALWAVE_BEGIN

	printt("Coop wave", waveNum, "/", lastWaveNum, "musicID:", musicID, "waveFrac:", waveFrac)

	CoopMusicPlay_ForceLoop(musicID)
}

function TowerDefense_WaveSpawnEnemies(waveNum, waveInfo, otherTeam) {
	level.waveNumSpawned = 0
	level.waveTotalSpawns = 0
	level.waveSpawnGroupInfos = {}

	local spawngroups = waveInfo.spawngroups

	// setup wave death count stuff before starting to spawn wave enemies
	foreach(spawnInfo in spawngroups) {
		if (IsWavePause(spawnInfo))
			continue

		// have to exclude ai types that don't count against wave completion
		local aiTypes = GetAITypeArrayFromSpawnFunc(spawnInfo.spawnFunc)
		local numToExclude = 0
		foreach(aiTypeStr in aiTypes) {
			if (!TowerDefense_AITypeShouldCountTowardGroupDeaths(aiTypeStr))
				numToExclude++
		}
		if (numToExclude > 0)
			printt("Spawn enemies excluded from count:", numToExclude)

		local aiCount = GetAICountFromSpawnInfo(spawnInfo)
		aiCount -= numToExclude

		level.waveTotalSpawns += aiCount

		local groupName = spawnInfo.groupName
		if (!(groupName in level.waveSpawnGroupInfos))
			level.waveSpawnGroupInfos[groupName] <- {
				spawnCount = 0,
				dead = 0,
				reqDead = 0
			}

		level.waveSpawnGroupInfos[groupName].spawnCount += aiCount

		local groupCount = level.waveSpawnGroupInfos[groupName].spawnCount

		// for larger groups, consider the group "dead" if most of them are dead
		local reqDead = floor((groupCount * 0.5) + 0.5)
		// smaller groups- need to kill em all
		if (groupCount == 1)
			reqDead = groupCount

		level.waveSpawnGroupInfos[groupName].reqDead = reqDead
	}

	// TEMP for testing
	foreach(groupname, info in level.waveSpawnGroupInfos)
	printt("Group", groupname, "reqDead:", info.reqDead)

	local debugDepsPrinted = [] // TEMP for debugging wave issues

	thread HighPopulationAnnounce_VOThink()

	// spawn the enemies
	printt("-------- Wave", waveNum + 1, "enemies start spawning! --------")

	local workingList = clone spawngroups

	while (workingList.len()) {
		if (OnlyCloakDronesRemaining())
			break // the workingList isn't empty but it only contains cloak drones so we can stop processing it

		local usedIds = []
		local startTime = Time()

		foreach(index, spawnInfo in workingList) {
			local spawnFunc = null
			if ("spawnFunc" in spawnInfo)
				spawnFunc = spawnInfo.spawnFunc

			local spawnFuncName = "Pause"
			if (spawnFunc == null)
				spawnFuncName += ": " + spawnInfo.wavePause + " secs"
			else
				spawnFuncName = spawnFunc.getinfos().name

			// Check group death dependencies
			local runDependency = spawnInfo.runDependency
			if (runDependency) {
				Assert(runDependency in level.waveSpawnGroupInfos)

				local groupInfo = level.waveSpawnGroupInfos[runDependency]

				if (groupInfo.dead < groupInfo.reqDead) {
					if (!ArrayContains(debugDepsPrinted, spawnInfo.id)) {
						printt("Group", spawnFuncName, "waiting on dependency:", runDependency)
						debugDepsPrinted.append(spawnInfo.id)
					}

					continue
				} else {
					printt("Group death dependency '" + runDependency + "' met for " + spawnFuncName)
				}
			}

			// Wave pause check
			if (IsWavePause(spawnInfo)) {
				if (spawnInfo.id > 0) {
					local prevSpawnInfo = spawngroups[spawnInfo.id - 1]
					if (!prevSpawnInfo.hasProcessed) {
						//printt( "Wave pause waiting for previous spawn:", prevSpawnInfo.id )
						continue
					} else {
						printt("Wave pause can proceed, previous group was processed- id:", prevSpawnInfo.id)
					}
				}

				printt("Wave pausing", spawnInfo.wavePause, "secs before resuming spawning")

				wait spawnInfo.wavePause

				SetWaveGroup_Processed(waveInfo, spawnInfo)

				usedIds.append(index)
				break // reloop to get the pause out of the list
			}

			// Start to process the next spawn group
			local aiCount = GetAICountFromSpawnFunc(spawnFunc) //the num of ai spawned from this func
			local aiTypes = GetAITypeArrayFromSpawnFunc(spawnFunc) //an array of strings that are the types of ai spawned from this func

			// Titans have their own max counter but don't have to wait for AI slots
			if (GetAITypeStrIsTitan(aiTypes[0])) {
				if (GetWaveNumTitans() >= COOP_MAX_ACTIVE_TITANS)
					continue

				printt("Number of wave titans active:", GetWaveNumTitans())
				aiCount = 0
			}

			if (aiTypes[0] == "cloakedDrone") {
				if (GetWaveNumCloakedDrones() >= COOP_MAX_ACTIVE_CLOAKED_DRONES)
					continue
				printt("Number of cloaked drones active:", GetWaveNumCloakedDrones())
			}

			// WAIT until we can spawn the correct count
			while (GetFreeAISlots(otherTeam) < aiCount) {
				printt("Wave spawns: ai count limit reached, waiting for slot to free up.")

				level.ent.WaitSignal("FreeAISlotsUpdated")
			}

			local routeAlias = spawnInfo.routeAlias
			if (routeAlias == null)
				printt("Spawning group:", spawnFunc.getinfos().name)
			else
				printt("Spawning group:", spawnFunc.getinfos().name, "on route:", spawnInfo.routeAlias)

			usedIds.append(index)

			thread CoopTeam_PingWaveRouteOnMinimaps(spawnInfo.route, 1.0, 4.0)

			thread CoopTD_WaveGroupSpawnerWrapper(spawnInfo, spawnInfo.route)
			SetWaveGroup_Processed(waveInfo, spawnInfo)

			wait RandomFloat(0.5, 1.5)
		}

		// remove spawns that we just processed from the working list
		local temp = []
		foreach(index, spawnInfo in workingList) {
			// if we didn't use it up, add to the new working list
			if (!ArrayContains(usedIds, index))
				temp.append(spawnInfo)
		}
		workingList = temp

		// If nothing happened, wait before trying again
		if (Time() == startTime)
			wait 0.5
	}

	while (level.waveNumSpawned < level.waveTotalSpawns)
		wait 1

	// ALL SPAWNS DONE FOR THIS WAVE

	//wait for the wave to be eliminated
	local enemies = GetNPCArrayEx("any", otherTeam, Vector(0, 0, 0), -1)
	printt("Wave spawning done- Num enemies still alive:", enemies.len())

	thread TowerDefense_AllEnemiesSpawned(enemies)

	local deathWaitStartTime = Time()

	//wait for the wave to be neutralized
	local signalArray = ["OnDeath", "OnLeeched"]
	waitthread WaitAnySignalOnAllEnts(enemies, signalArray)

	// kill leeched spectres at the end of a wave
	local delay = 3
	thread KillLeechedSpectres(delay)

	if (Time() == deathWaitStartTime)
		wait 0.1 // always want some small delay between spawned and dead so post-spawned threads can have a chance to start up and then end on AllEnemiesDead signal

	// ALL ENEMIES NOW DEAD OR LEECHED
	level.ent.Signal("WaveSpawn_AllEnemiesDead")
}

function OnlyCloakDronesRemaining() {
	// GetTotalEnemyNum already ignores cloak drones
	if (GetTotalEnemyNum() <= 0)
		return true
	return false
}

// -------------------------------------------
// ----- AITYPE HIGH POPULATION WARNINGS -----
// -------------------------------------------
function AddAITypeHighPopulationVO(aiTypeID, voAlias, classname, subclass = null, debounceTime = 60.0) {
	Assert(!(aiTypeID in level.aiTypeHighPopVO))

	local aiTypeStr = GetCoopAITypeString_ByID(aiTypeID)
	local timerName = "Nag_HighPopWarning_" + aiTypeStr
	TimerInit(timerName, debounceTime)

	local warningInfo = {}
	warningInfo.voAlias <- voAlias
	warningInfo.timer <- timerName
	warningInfo.classname <- classname
	warningInfo.subclass <- subclass

	level.aiTypeHighPopVO[aiTypeID] <- warningInfo
}

function HighPopulationAnnounce_VOThink() {
	FlagEnd("ObjectiveComplete")
	FlagEnd("ObjectiveFailed")
	FlagEnd("TDGeneratorDestroyed")
	level.ent.EndSignal("WaveSpawn_AllEnemiesDead")

	local waitTime = 15.0

	while (1) {
		wait waitTime
		thread TryHighPopulationAnnounce()
	}
}

function TryHighPopulationAnnounce() {
	if (Flag("ObjectiveComplete"))
		return

	if (Flag("ObjectiveFailed"))
		return

	if (Flag("TDGeneratorDestroyed"))
		return

	FlagEnd("ObjectiveComplete")
	FlagEnd("ObjectiveFailed")
	FlagEnd("TDGeneratorDestroyed")

	if (!TimerCheck("Nag_HighPopWarning"))
		return

	if (Flag("WaveAnnounceInProgress"))
		return

	if (Flag("GeneratorThreatAnnounce_InProgress"))
		return

	if (Flag("HighPopulationAnnounce_InProgress"))
		return

	FlagSet("HighPopulationAnnounce_InProgress")

	OnThreadEnd(
		function(): () {
			FlagClear("HighPopulationAnnounce_InProgress")
		}
	)

	local reqTitans = 4
	local reqSpectres = 15
	local nonPlayerTeam = GetOtherTeam(level.nv.attackingTeam)

	local aiHighPopWarningInfo = null

	foreach(aiTypeID, warningInfo in level.aiTypeHighPopVO) {
		local reqNum = reqTitans
		if (aiTypeID == eCoopAIType.suicideSpectre)
			reqNum = reqSpectres

		local aliveEnemies = GetNPCArrayWithSubclassEx(warningInfo.classname, nonPlayerTeam, Vector(0, 0, 0), -1, [warningInfo.subclass])
		local numSpawned = aliveEnemies.len()

		if (numSpawned >= reqNum) {
			if (!TimerCheck(warningInfo.timer))
				continue

			aiHighPopWarningInfo = warningInfo
			break // don't consider other types once we find one that qualifies
		}
	}

	if (aiHighPopWarningInfo == null)
		return

	PlayConversationToCoopTeam(aiHighPopWarningInfo.voAlias)
	TimerReset("Nag_HighPopWarning")
	TimerReset(aiHighPopWarningInfo.timer)

	wait 5.0 // so the HighPopulationAnnounce_InProgress flag gets cleared after VO is finished
}


function KillLeechedSpectres(delay) {
	wait delay

	local spectreArray = GetNPCArrayByClass("npc_spectre")
	local playerTeam = level.nv.attackingTeam
	foreach(spectre in spectreArray) {
		local team = spectre.GetTeam()
		if (team == playerTeam)
			spectre.Die()
	}
}

function GetWaveNumCloakedDrones() {
	return level.waveNumCloakedDrones
}

function IncrementWaveNumCloakedDrones() {
	level.waveNumCloakedDrones++
}

function DecrementWaveNumCloakedDrones() {
	level.waveNumCloakedDrones--
}

function GetWaveNumTitans() {
	return level.waveNumTitans
}

function IncrementWaveNumTitans() {
	level.waveNumTitans++
}

function DecrementWaveNumTitans() {
	level.waveNumTitans--
}

function GetAITypeStrIsTitan(aiTypeStr) {
	local isTitan = false
	switch (aiTypeStr) {
		case "titan":
		case "nukeTitan":
		case "mortarTitan":
		case "empTitan":
			isTitan = true
			break
	}

	return isTitan
}

function TowerDefense_AITypeShouldCountTowardGroupDeaths(aiTypeStr) {
	local shouldCount = true

	if (aiTypeStr == "cloakedDrone")
		shouldCount = false

	return shouldCount
}

function SetWaveGroup_Processed(waveInfo, spawnInfo) {
	waveInfo.spawngroups[spawnInfo.id].hasProcessed = true
}

function TowerDefense_AllEnemiesSpawned(enemies) {
	thread DecloakSnipersNearWaveEnd()

	if (enemies.len())
		thread NagCoopTeamAboutStragglers(enemies, 30.0)
}

function NagCoopTeamAboutStragglers(enemies, nagStartDelay = 0.0) {
	if (!enemies.len())
		return

	if (!Flag("CoopTD_WaveCombatInProgress"))
		return

	FlagClearEnd("CoopTD_WaveCombatInProgress")

	level.ent.EndSignal("ObjectiveComplete")
	level.ent.EndSignal("ObjectiveFailed")
	level.ent.EndSignal("WaveSpawn_AllEnemiesDead")

	// Give players a chance to kill off the stragglers before nagging
	if (nagStartDelay > 0)
		wait nagStartDelay

	local recheckWait = 5.0

	local waveTotalSpawns = level.waveTotalSpawns
	local aliveTitans = 0
	local aliveOthers = 0

	while (1) {
		wait recheckWait

		if (!TimerCheck("Nag_KillStragglers"))
			continue

		waveTotalSpawns = level.waveTotalSpawns
		aliveTitans = 0
		aliveOthers = 0

		foreach(enemy in enemies) {
			if (IsAlive(enemy)) {
				if (enemy.IsTitan())
					aliveTitans++
				else if (enemy.GetTeam() == GetOtherTeam(level.nv.attackingTeam)) // flipped spectres shouldn't be counted
					aliveOthers++
			}
		}

		// VO sounds weird if used for Titan stragglers
		if (aliveTitans > 0)
			continue

		local totalAlive = aliveTitans + aliveOthers
		local percentAlive = totalAlive.tofloat() / waveTotalSpawns.tofloat()

		if (totalAlive > 2 && percentAlive > 0.34)
			continue

		local soundAlias = "CoopTD_ClearStragglersNag_Generic"
		if (totalAlive < 6 && totalAlive > 0)
			soundAlias = "CoopTD_ClearStragglersNag_NumRem_" + totalAlive

		PlayConversationToCoopTeam(soundAlias)

		TimerReset("Nag_KillStragglers")
	}
}

function UpdateNumbersForNextWave(wave) {
	local TD_numTitans = GetAICountFromWave(wave, "titan")
	local TD_numNukeTitans = GetAICountFromWave(wave, "nukeTitan")
	local TD_numMortarTitans = GetAICountFromWave(wave, "mortarTitan")
	local TD_numEMPTitans = GetAICountFromWave(wave, "empTitan")
	local TD_numSuicides = GetAICountFromWave(wave, "suicideSpectre")
	local TD_numSnipers = GetAICountFromWave(wave, "sniperSpectre")
	local TD_numSpectres = GetAICountFromWave(wave, "spectre")
	local TD_numBubbleShieldSpectre = GetAICountFromWave(wave, "bubbleShieldSpectre")
	TD_numSpectres += (TD_numBubbleShieldSpectre > 0) ? TD_numBubbleShieldSpectre : 0
	local TD_numGrunts = GetAICountFromWave(wave, "grunt")
	local TD_numBubbleShieldGrunt = GetAICountFromWave(wave, "bubbleShieldGrunt")
	TD_numGrunts += (TD_numBubbleShieldGrunt > 0) ? TD_numBubbleShieldGrunt : 0
	local TD_numCloakedDrone = GetAICountFromWave(wave, "cloakedDrone")

	level.nv.TD_numTitans = TD_numTitans
	level.nv.TD_numNukeTitans = TD_numNukeTitans
	level.nv.TD_numMortarTitans = TD_numMortarTitans
	level.nv.TD_numEMPTitans = TD_numEMPTitans
	level.nv.TD_numSuicides = TD_numSuicides
	level.nv.TD_numSnipers = TD_numSnipers
	level.nv.TD_numSpectres = TD_numSpectres
	level.nv.TD_numGrunts = TD_numGrunts
	level.nv.TD_numCloakedDrone = TD_numCloakedDrone

	level.nv.TD_numTotal = GetTotalEnemyNum()
}

function CoopTD_WaveGroupSpawnerWrapper(spawnInfo, route) {
	local spawnFunc = spawnInfo.spawnFunc
	local groupName = spawnInfo.groupName

	// spawn the guys
	local squad = spawnFunc(route)

	local aiTypes = GetAITypeArrayFromSpawnFunc(spawnFunc)

	// set up expected prespawn aitype counts for this spawn group
	local countPerType = {}
	foreach(aiType in aiTypes) {
		if (!(aiType in countPerType))
			countPerType[aiType] <- 0

		countPerType[aiType]++
	}

	local totalAICount = aiTypes.len()

	// spawn func can fail to spawn all or some of the guys, for example if the dropship or drop pod is killed before the AIs are spawned into it
	if (squad == null || squad.len() < totalAICount) {
		// update wave total spawns
		local numMissing = totalAICount - squad.len()
		level.waveTotalSpawns -= numMissing

		// consider these unspawned guys as dead, update combat NPC "dead" total
		if (groupName in level.waveSpawnGroupInfos)
			level.waveSpawnGroupInfos[groupName].dead += numMissing

		// combat NPCs don't include cloak drones so we have to check all enemy types to try to update HUD network variables
		local workingList = clone countPerType
		foreach(guy in squad) {
			local enemyAIType = CoopTD_GetEnemyAITypeAlias(guy)

			foreach(aiType, count in countPerType) {
				if (enemyAIType == aiType)
					workingList[enemyAIType]--
			}
		}

		// now figure out for each type how many were missing and update it
		local decremented = false
		foreach(aiType, notSpawnedCount in workingList) {
			if (notSpawnedCount > 0) {
				CoopTD_DecrementHUDCount_ForAIType(aiType, notSpawnedCount)
				decremented = true
			}
		}

		// recalculate the total enemies now that the HUD count(s) might have changed
		if (decremented)
			level.nv.TD_numTotal = GetTotalEnemyNum()

		// don't do anything else because nobody spawned
		if (squad == null || squad.len() < 1)
			return
	}

	foreach(i, npc in squad) {
		local aiType = CoopTD_GetEnemyAITypeAlias(npc)
		if (GetAITypeStrIsTitan(aiType))
			IncrementWaveNumTitans()

		if (aiType != "cloakedDrone")
			level.waveNumSpawned++ // since cloakedDrones are not counted for level.waveTotalSpawns we can't add them to level.waveNumSpawned

		thread TD_OnSpawnedAIDeath(npc, aiType, groupName)
	}
}

function TD_OnSpawnedAIDeath(npc, aiType, groupName) {
	if (Flag("ObjectiveComplete") || Flag("ObjectiveFailed"))
		return

	FlagEnd("ObjectiveComplete")
	FlagEnd("ObjectiveFailed")

	WaitSignal(npc, "OnDeath", "OnDestroy", "OnLeeched")

	// set this guy as dead in his group info
	if (groupName in level.waveSpawnGroupInfos) {
		if (TowerDefense_AITypeShouldCountTowardGroupDeaths(aiType))
			level.waveSpawnGroupInfos[groupName].dead++
	}

	if (GetAITypeStrIsTitan(aiType))
		DecrementWaveNumTitans()

	if (aiType == "cloakedDrone")
		DecrementWaveNumCloakedDrones()

	CoopTD_DecrementHUDCount_ForAIType(aiType)

	level.ent.Signal("AnEnemyWasKilled")
}

function CoopTD_DecrementHUDCount_ForAIType(aiType, decrementAmt = 1) {
	switch (aiType) {
		case "titan":
			level.nv.TD_numTitans -= decrementAmt
			break

		case "nukeTitan":
			level.nv.TD_numNukeTitans -= decrementAmt
			break

		case "empTitan":
			level.nv.TD_numEMPTitans -= decrementAmt
			break

		case "mortarTitan":
			level.nv.TD_numMortarTitans -= decrementAmt
			break

		case "suicideSpectre":
			level.nv.TD_numSuicides -= decrementAmt
			break

		case "sniperSpectre":
			level.nv.TD_numSnipers -= decrementAmt
			break

		case "spectre":
		case "bubbleShieldSpectre":
			level.nv.TD_numSpectres -= decrementAmt
			break

		case "grunt":
		case "bubbleShieldGrunt":
			level.nv.TD_numGrunts -= decrementAmt
			break

		case "cloakedDrone":
			level.nv.TD_numCloakedDrone -= decrementAmt
			break

		default:
			Assert(0, "ai type " + aiType + " not supported in the tower defense hud")
	}
}

function CoopTD_GetEnemyAITypeAlias(enemy) {
	local aiTypeAlias = null

	// CLOAK DRONES
	if (enemy.GetClassname() == "prop_dynamic") {
		aiTypeAlias = "cloakedDrone"
	} else if (enemy.IsSoldier()) {
		aiTypeAlias = "grunt"
	}
	// SPECTRES
	else if (enemy.IsSpectre()) {
		local subclass = enemy.GetSubclass()
		if (subclass > eSubClass.NONE) {
			if (subclass == eSubClass.suicideSpectre)
				aiTypeAlias = "suicideSpectre"
			else if (subclass == eSubClass.sniperSpectre)
				aiTypeAlias = "sniperSpectre"
		} else {
			aiTypeAlias = "spectre"
		}
	} else if (enemy.IsTitan()) {
		local subclass = enemy.GetSubclass()
		if (subclass > eSubClass.NONE) {
			if (subclass == eSubClass.empTitan)
				aiTypeAlias = "empTitan"
			else if (subclass == eSubClass.nukeTitan)
				aiTypeAlias = "nukeTitan"
			else if (subclass == eSubClass.mortarTitan)
				aiTypeAlias = "mortarTitan"
		} else {
			aiTypeAlias = "titan"
		}
	}

	Assert(aiTypeAlias != null, "enemy of class " + enemy.GetClassname() + " not supported in the tower defense hud")

	return aiTypeAlias
}


function TowerDefenseInit() {
	local playerTeam = level.nv.attackingTeam
	local otherTeam = GetOtherTeam(level.nv.attackingTeam)
	level.max_npc_per_side = 28
	SetGameModeAICount(0, playerTeam)
	SetGameModeAICount(level.max_npc_per_side, otherTeam)
	SetLevelAICount(0, playerTeam)
	SetLevelAICount(level.max_npc_per_side, otherTeam)

	foreach(hardpoint in level.hardpoints)
	hardpoint.DisableHardpoint()

	local indoorTriggers = GetEntArrayByClass_Expensive("trigger_indoor_area")
	TriggerOff(indoorTriggers) //so guys never slow down to get to generator

	_RegisterSpawnFuncInternal(TD_SpawnTitan, 1, ["titan"])
	_RegisterSpawnFuncInternal(TD_SpawnAmpedTitan, 1, ["titan"])
	_RegisterSpawnFuncInternal(TD_SpawnNukeTitan, 1, ["nukeTitan"])
	_RegisterSpawnFuncInternal(TD_SpawnMortarTitan, 1, ["mortarTitan"])
	_RegisterSpawnFuncInternal(TD_SpawnEmpTitan, 1, ["empTitan"])

	_RegisterSpawnFuncInternal(TD_SpawnGruntSquad, GetSpawnSquadSize(otherTeam), ["grunt"])
	_RegisterSpawnFuncInternal(TD_SpawnSpectreSquad, GetSpawnSquadSize(otherTeam), ["spectre"])
	_RegisterSpawnFuncInternal(TD_SpawnSuicideSpectreSquad, GetSpawnSquadSize(otherTeam), ["suicideSpectre"])
	_RegisterSpawnFuncInternal(TD_SpawnSpectreSquadWithSingleSuicide, GetSpawnSquadSize(otherTeam), ["spectre", "spectre", "spectre", "suicideSpectre"])
	_RegisterSpawnFuncInternal(TD_SpawnGruntSquadDroppod, GetSpawnSquadSize(otherTeam), ["grunt"])
	_RegisterSpawnFuncInternal(TD_SpawnGruntSquadDropship, GetSpawnSquadSize(otherTeam), ["grunt"])
	_RegisterSpawnFuncInternal(TD_SpawnSpectreSquadDroppod, GetSpawnSquadSize(otherTeam), ["spectre"])
	_RegisterSpawnFuncInternal(TD_SpawnSpectreSquadDropship, GetSpawnSquadSize(otherTeam), ["spectre"])
	_RegisterSpawnFuncInternal(TD_SpawnSuicideSpectreSquadDroppod, GetSpawnSquadSize(otherTeam), ["suicideSpectre"])
	_RegisterSpawnFuncInternal(TD_SpawnSuicideSpectreSquadDropship, GetSpawnSquadSize(otherTeam), ["suicideSpectre"])
	_RegisterSpawnFuncInternal(TD_SpawnSpectreSquadWithSingleSuicideDroppod, GetSpawnSquadSize(otherTeam), ["spectre", "spectre", "spectre", "suicideSpectre"])
	_RegisterSpawnFuncInternal(TD_SpawnSpectreSquadWithSingleSuicideDropship, GetSpawnSquadSize(otherTeam), ["spectre", "spectre", "spectre", "suicideSpectre"])
	_RegisterSpawnFuncInternal(TD_SpawnBubbleShieldSpectreSquad, GetSpawnSquadSize(otherTeam), ["bubbleShieldSpectre", "spectre", "spectre", "spectre"])
	_RegisterSpawnFuncInternal(TD_SpawnBubbleShieldGruntSquad, GetSpawnSquadSize(otherTeam), ["bubbleShieldGrunt", "grunt", "grunt", "grunt"])
	_RegisterSpawnFuncInternal(TD_SpawnSniper1x, 1, ["sniperSpectre"])
	_RegisterSpawnFuncInternal(TD_SpawnSniper2x, 2, ["sniperSpectre"])
	_RegisterSpawnFuncInternal(TD_SpawnSniper3x, 3, ["sniperSpectre"])
	_RegisterSpawnFuncInternal(TD_SpawnSniper4x, 4, ["sniperSpectre"])
	_RegisterSpawnFuncInternal(TD_SpawnCloakedDrone, 1, ["cloakedDrone"])

	foreach(register in level.TowerDefense_AddedSpawnFuncs)
	_RegisterSpawnFuncInternal(register.spawnFunc, register.count, register.aiTypes)

	level.TD_isInited = true

	thread TowerDefenseCleanup()
}

function TowerDefenseCleanup() {
	FlagWait("ObjectiveComplete")

	local indoorTriggers = GetEntArrayByClass_Expensive("trigger_indoor_area")
	TriggerOn(indoorTriggers)

	level.TowerDefense_RegisteredSpawnFuncs = {} //clear to re-register

	level.TD_isInited = false
}


/************************************************************************************************\

######## #### ########    ###    ##    ##  ######
   ##     ##     ##      ## ##   ###   ## ##    ##
   ##     ##     ##     ##   ##  ####  ## ##
   ##     ##     ##    ##     ## ## ## ##  ######
   ##     ##     ##    ######### ##  ####       ##
   ##     ##     ##    ##     ## ##   ### ##    ##
   ##    ####    ##    ##     ## ##    ##  ######

\************************************************************************************************/
function TD_SpawnTitan(route, settings = null) {
	local titan = TD_SpawnTitan_ForRoute(route, SpawnCoopTitan, settings)
	return [titan]
}

function TD_SpawnAmpedTitan(route, settings = null) {
	local titan = TD_SpawnTitan_ForRoute(route, SpawnAmpedCoopTitan, settings)
	return [titan]
}

function TD_SpawnNukeTitan(route) {
	local titan = TD_SpawnTitan_ForRoute(route, SpawnNukeTitan)
	return [titan]
}

function TD_SpawnMortarTitan(route) {
	local titan = TD_SpawnTitan_ForRoute(route, SpawnMortarTitan)
	return [titan]
}

function TD_SpawnEmpTitan(route) {
	local titan = TD_SpawnTitan_ForRoute(route, SpawnEMPTitan)
	return [titan]
}

function TD_SpawnTitan_ForRoute(route, spawnFunc, settings = null) {
	local otherTeam = GetOtherTeam(level.nv.attackingTeam)

	local angles = GetTitanSpawnAngles(route, route[0])
	local spawnPoint = GetTitanSpawnPoint(route[0], angles)

	local origin = spawnPoint.origin
	angles = spawnPoint.angles

	local titan = null
	if (settings)
		titan = spawnFunc(origin, angles, otherTeam, settings)
	else
		titan = spawnFunc(origin, angles, otherTeam)

	titan.s.lockedRocketPods <- false

	if (Riff_AILethality() != eAILethality.Default) {
		switch (Riff_AILethality()) {
			case eAILethality.TD_Low:
				titan.SetMaxHealth(titan.GetMaxHealth() * TD_LOW_SCALAR_TITANHEALTH)
				titan.SetHealth(titan.GetMaxHealth())
				//	TitanDisableRocketPods( titan )
				//	TitanLockRocketPods( titan )
				break

			case eAILethality.TD_Medium:
				titan.SetMaxHealth(titan.GetMaxHealth() * TD_MED_SCALAR_TITANHEALTH)
				titan.SetHealth(titan.GetMaxHealth())
				break
		}
	}

	ReserveAISlots(otherTeam, 1)
	FreeAISlotOnDeath(titan)

	thread CoopTitanNPCDropsIn(titan)
	thread ShowOnMinimapOnHotdropFinished(titan)

	if (IsMortarTitan(titan))
		thread TowerDefenseMortarTitanThink(titan, route)
	else
		thread TowerDefenseTitanThink(titan, route)

	return titan
}

function ShowOnMinimapOnHotdropFinished(titan) {
	titan.EndSignal("OnDeath")
	titan.EndSignal("OnDestroy")

	WaitTillHotDropComplete(titan)

	if (IsCloaked(titan) == false) {
		titan.Minimap_AlwaysShow(TEAM_IMC, null)
		titan.Minimap_AlwaysShow(TEAM_MILITIA, null)
	}
}

/*******************************************************************\
	REGULAR AND NUKE TITANS
\*******************************************************************/
function TowerDefenseTitanThink(titan, route) {
	titan.EndSignal("OnDeath")
	titan.EndSignal("OnDestroy")

	WaitTillHotDropComplete(titan)

	local goalRadius = 200
	local checkRadiusSqr = 250 * 250

	local index = 1
	local goal = route[index]

	while (1) {
		thread GotoOrigin(titan, goal, goalRadius)

		thread SetSignalDelayed(titan, "AssaultTimeOut", 30)
		WaitSignal(titan, "OnEnterAssaultTolerance", "AssaultTimeOut")

		if (DistanceSqr(titan.GetOrigin(), goal) <= checkRadiusSqr) {
			if (index + 1 >= route.len()) {
				if (IsNukeTitan(titan)) {
					titan.SetEnemy(level.TowerDefenseGenerator)
					thread NukeTitanSeekOutGenerator(titan)
				}

				return
			}

			index++
			goal = route[index]
		}
	}
}

function NukeTitanSeekOutGenerator(titan) {
	titan.EndSignal("OnDeath")
	titan.EndSignal("OnDestroy")

	local generator = level.TowerDefenseGenerator
	local node = GetNearestNodeToPos(generator.GetOrigin())
	local goal = GetNodePos(node, HULL_TITAN)

	local goalRadius = 350
	local checkRadiusSqr = 400 * 400

	while (1) {
		thread GotoOrigin(titan, goal, goalRadius)

		thread SetSignalDelayed(titan, "AssaultTimeOut", 15)
		WaitSignal(titan, "OnEnterAssaultTolerance", "AssaultTimeOut")

		if (DistanceSqr(titan.GetOrigin(), generator.GetOrigin()) > checkRadiusSqr)
			continue

		break
	}

	thread AutoTitan_SelfDestruct(titan)
}

/*******************************************************************\
	MORTAR TITANS
\*******************************************************************/
function TowerDefenseMortarTitanThink(titan, route) {
	titan.EndSignal("Doomed")
	titan.EndSignal("OnDeath")
	titan.EndSignal("OnDestroy")

	WaitTillHotDropComplete(titan)

	local minEngagementDuration = 5
	local generator = level.TowerDefenseGenerator
	local playerProximityDistSqr = pow(256, 2)
	local mortarPosition = GetRandomStationaryTitanPosition(titan.GetOrigin(), MORTAR_TITAN_POSITION_SEARCH_RANGE)
	while (mortarPosition == null) {
		// incase all stationary titan positions are in use wait for one to become available
		wait 5
		mortarPosition = GetRandomStationaryTitanPosition(titan.GetOrigin(), MORTAR_TITAN_POSITION_SEARCH_RANGE)
	}

	ClaimStationaryTitanPosition(mortarPosition)

	OnThreadEnd(
		function(): (mortarPosition) {
			// release mortar position when dead
			ReleaseStationaryTitanPosition(mortarPosition)
		}
	)

	local minDamage = 75 // so that the titan doesn't care about small amounts of damage.

	while (true) {
		local origin = mortarPosition.origin

		local startHealth = titan.GetHealth()
		waitthread MoveToMortarPosition(titan, origin, generator)

		if (startHealth > (titan.GetHealth() + minDamage)) {
			// we took damage getting to the mortar location lets wait until we stop taking damage
			waitthread MortarTitanWaitToEngage(titan, MORTAR_TITAN_ENGAGE_DELAY)
			continue
		}

		local healthBreakOff = titan.GetHealth() * MORTAR_TITAN_ABORT_ATTACK_HEALTH_FRAC

		waitthread MortarTitanKneelToAttack(titan)
		thread MortarTitanAttack(titan, generator)

		wait minEngagementDuration // aways mortar the target for a while before potentially breaking out

		// wait for interruption
		while (true) {
			if (IsEnemyWithinDist(titan, playerProximityDistSqr))
				break
			if (titan.GetHealth() < healthBreakOff)
				break

			wait 1
		}

		MortarTitanStopAttack(titan)

		// lets wait until we stop taking damage before going back to attacking the generator
		waitthread MortarTitanWaitToEngage(titan, MORTAR_TITAN_REENGAGE_DELAY)
	}
}

function IsEnemyWithinDist(titan, dist) {
	local otherTeam = GetOtherTeam(level.nv.attackingTeam)
	local origin = titan.GetOrigin()
	local players = GetLivingPlayers(otherTeam)

	foreach(player in players) {
		if (DistanceSqr(player.GetOrigin(), origin) < dist)
			return true
	}

	return false
}


/*******************************************************************\
	TOOLS
\*******************************************************************/
function GetTitanSpawnAngles(route, origin) {
	local end = route[route.len() - 1]
	local vec = end - origin
	vec.Normalize()
	local angles = VectorToAngles(vec)
	angles = Vector(0, angles.y, 0)

	return angles
}

function GetTitanSpawnPoint(centerOrigin, angles) {
	local analysis = GetAnalysisForModel(ATLAS_MODEL, HOTDROP_TURBO_ANIM)

	local drop = CreateCallinTable()
	drop.style = eDropStyle.NEAREST_YAW_FALLBACK
	drop.ownerEyePos = centerOrigin + Vector(0, 0, 60)
	drop.dist = 800
	drop.origin = centerOrigin
	drop.yaw = angles.y

	local spawnPoint = GetSpawnPointForStyle(analysis, drop)
	if (!spawnPoint)
		return {
			origin = centerOrigin,
			angles = angles
		}

	//	DebugDrawLine( centerOrigin, spawnPoint.origin, 255, 0, 0, true, 5 )
	//	DebugDrawLine( spawnPoint.origin, spawnPoint.origin + spawnPoint.angles.AnglesToForward() * 128, 255, 255, 0, true, 5 )
	return spawnPoint
}

function RateTitanSpawnPoint(spawnpoint, team, origin) {
	local dist = Distance(spawnpoint.GetOrigin(), origin)
	local rating = GraphCapped(dist, 1000, 4500, 2, 0)

	spawnpoint.CalculateRating(TD_AI, team, rating, rating) // second rating is rating with petTitan. Not used with AI I guess
	return rating
}

/************************************************************************************************\

##     ## #### ##    ## ####  #######  ##    ##  ######
###   ###  ##  ###   ##  ##  ##     ## ###   ## ##    ##
#### ####  ##  ####  ##  ##  ##     ## ####  ## ##
## ### ##  ##  ## ## ##  ##  ##     ## ## ## ##  ######
##     ##  ##  ##  ####  ##  ##     ## ##  ####       ##
##     ##  ##  ##   ###  ##  ##     ## ##   ### ##    ##
##     ## #### ##    ## ####  #######  ##    ##  ######

\************************************************************************************************/
function TD_SpawnGruntSquadDroppod(route) {
	return SpawnTowerDefenseMinions(TD_SpawnGruntSquadDroppod, "droppod", route)
}

function TD_SpawnGruntSquadDropship(route) {
	return SpawnTowerDefenseMinions(TD_SpawnGruntSquadDropship, "dropship", route)
}

function TD_SpawnSpectreSquadDroppod(route) {
	return SpawnTowerDefenseMinions(TD_SpawnSpectreSquadDroppod, "droppod", route)
}

function TD_SpawnSpectreSquadDropship(route) {
	return SpawnTowerDefenseMinions(TD_SpawnSpectreSquadDropship, "dropship", route)
}

function TD_SpawnSuicideSpectreSquadDroppod(route) {
	return SpawnTowerDefenseMinions(TD_SpawnSuicideSpectreSquadDroppod, "droppod", route)
}

function TD_SpawnSuicideSpectreSquadDropship(route) {
	return SpawnTowerDefenseMinions(TD_SpawnSuicideSpectreSquadDropship, "dropship", route)
}

function TD_SpawnSpectreSquadWithSingleSuicideDroppod(route) {
	return SpawnTowerDefenseMinions(TD_SpawnSpectreSquadWithSingleSuicideDroppod, "droppod", route)
}

function TD_SpawnSpectreSquadWithSingleSuicideDropship(route) {
	return SpawnTowerDefenseMinions(TD_SpawnSpectreSquadWithSingleSuicideDropship, "dropship", route)
}

function TD_SpawnGruntSquad(route) {
	return SpawnTowerDefenseMinions(TD_SpawnGruntSquad, "any", route)
}

function TD_SpawnSpectreSquad(route) {
	return SpawnTowerDefenseMinions(TD_SpawnSpectreSquad, "any", route)
}

function TD_SpawnSuicideSpectreSquad(route) {
	return SpawnTowerDefenseMinions(TD_SpawnSuicideSpectreSquad, "any", route)
}

function TD_SpawnSpectreSquadWithSingleSuicide(route) {
	return SpawnTowerDefenseMinions(TD_SpawnSpectreSquadWithSingleSuicide, "any", route)
}

function SpawnTowerDefenseMinions(spawnFunc, style, route) {
	local team = GetOtherTeam(level.nv.attackingTeam)
	local spawnCount = GetMinionSpawnCount(team)
	local squadName = MakeSquadName(team, "TowerDefenseMinion" + UniqueString())
	local spawnPoint = GetMinionSpawnPoint(SpawnPoints_GetDropPod(), team, route[0])
	local ai_type = TD_GetSquadType(spawnFunc)
	local npcSpawnFunc = TD_GetnpcSpawnFunc(spawnFunc)

	local droppod
	switch (style) {
		case "dropship":
			droppod = false
			break

		case "droppod":
			droppod = true
			break

		case "any":
			droppod = RandomInt(0, 100) > 25
			break

		default:
			Assert(0)
			break
	}

	local npcArray
	if (droppod)
		npcArray = TD_SpawnDroppodSquad(ai_type, team, spawnCount, spawnPoint, squadName, npcSpawnFunc)

	else
		npcArray = TD_SpawnZipLineSquad(ai_type, team, spawnCount, spawnPoint, squadName, npcSpawnFunc)

	foreach(npc in npcArray) {
		thread ShowOnMinimapOnDeploy(npc)
		thread PathFailSolution(npc)
		RandomizeMinionWeapon(npc)
		npc.kv.faceEnemyWhileMovingDistSq = 800 * 800
	}

	local suicideSquad = GetSuicideSquad(npcArray)
	local nonSuicideSquad = GetNonSuicideSquad(npcArray)

	if (nonSuicideSquad.len())
		thread TowerDefenseSquadThink(nonSuicideSquad, route)

	if (suicideSquad.len())
		thread SuicideSquadThink(suicideSquad, route)

	return npcArray
}

function ShowOnMinimapOnDeploy(npc) {
	npc.EndSignal("OnDeath")
	npc.EndSignal("OnDestroy")

	npc.WaitSignal("npc_deployed")
	if (IsCloaked(npc) == false) {
		npc.Minimap_AlwaysShow(TEAM_IMC, null)
		npc.Minimap_AlwaysShow(TEAM_MILITIA, null)
	}
}

function GetSuicideSquad(npcArray) {
	local squad = []
	foreach(npc in npcArray) {
		if (IsSuicideSpectre(npc))
			squad.append(npc)
	}
	return squad
}

function GetNonSuicideSquad(npcArray) {
	local squad = []
	foreach(npc in npcArray) {
		if (!IsSuicideSpectre(npc))
			squad.append(npc)
	}
	return squad
}

function GetMinionSpawnCount(team) {
	local numFreeSlots = GetFreeAISlots(team)
	local squadSize = GetSpawnSquadSize(team)
	local spawnCount = min(numFreeSlots, squadSize)
	Assert(spawnCount == squadSize)

	return spawnCount
}

function TD_SpawnSuicideSpectre(team, squadName, origin, angles) {
	local spectre = SpawnSuicideSpectre(team, squadName, origin, angles)
	TowerDefenseSuicideSpectreCustomize(spectre)
	return spectre
}

function TD_SpawnGrunt(team, squadname, origin, angles) {
	local grunt = SpawnGrunt(team, squadname, origin, angles)
	grunt.PreferSprint(true)
	return grunt
}

function TD_SpawnSpectre(team, squadName, origin, angles) {
	local spectre = SpawnSpectre(team, squadName, origin, angles)
	spectre.PreferSprint(true)
	return spectre
}

function TD_SpawnZipLineSquad(ai_type, team, count, spawnPoint, squadName, npcSpawnFunc) {
	local force = false
	local dropTable = TD_CreateDropTable(team, count, spawnPoint, squadName, npcSpawnFunc)
	return Spawn_TrackedZipLineSquad(ai_type, spawnPoint, dropTable)
}

function TD_SpawnDroppodSquad(ai_type, team, count, spawnPoint, squadName, npcSpawnFunc) {
	local force = false
	return Spawn_TrackedDropPodSquad(ai_type, team, count, spawnPoint, squadName, force, npcSpawnFunc)
}

function TD_CreateDropTable(team, count, spawnPoint, squadName, npcSpawnFunc) {
	local drop = CreateDropshipDropoff()
	drop.origin = spawnPoint.GetOrigin()
	drop.yaw = spawnPoint.GetAngles().y
	drop.dist = 768
	drop.count = count
	drop.team = team
	drop.squadname = squadName
	drop.npcSpawnFunc = npcSpawnFunc
	drop.style = eDropStyle.ZIPLINE_NPC
	drop.assaultEntity <- spawnPoint
	drop.dropshipHealth = TD_DROPSHIP_HEALTH

	return drop
}

function TD_GetnpcSpawnFunc(spawnFunc) {
	local aiTypes = GetAITypeArrayFromSpawnFunc(spawnFunc)
	local npcSpawnFunc = []
	foreach(aiType in aiTypes) {
		switch (aiType) {
			case "suicideSpectre":
				npcSpawnFunc.append(Bind(TD_SpawnSuicideSpectre))
				break

			case "sniperSpectre":
				npcSpawnFunc.append(SpawnSniperSpectre)
				break

			case "spectre":
				npcSpawnFunc.append(Bind(TD_SpawnSpectre))
				break

			case "grunt":
				npcSpawnFunc.append(Bind(TD_SpawnGrunt))
				break

			case "bubbleShieldSpectre":
				npcSpawnFunc.append(SpawnBubbleShieldSpectre)
				break

			case "bubbleShieldGrunt":
				npcSpawnFunc.append(SpawnBubbleShieldGrunt)
				break

			default:
				Assert(0)
		}
	}

	return npcSpawnFunc
}

function TD_GetSquadType(spawnFunc) {
	local aiTypes = GetAITypeArrayFromSpawnFunc(spawnFunc)
	switch (aiTypes[0]) {
		case "sniperSpectre":
		case "suicideSpectre":
		case "bubbleShieldSpectre":
		case "spectre":
			return "npc_spectre"

		case "bubbleShieldGrunt":
		case "grunt":
			return "npc_soldier"

		default:
			Assert(0)
	}
}


/************************************************************************************************\

########     ###    ######## ##     ## #### ##    ##  ######
##     ##   ## ##      ##    ##     ##  ##  ###   ## ##    ##
##     ##  ##   ##     ##    ##     ##  ##  ####  ## ##
########  ##     ##    ##    #########  ##  ## ## ## ##   ####
##        #########    ##    ##     ##  ##  ##  #### ##    ##
##        ##     ##    ##    ##     ##  ##  ##   ### ##    ##
##        ##     ##    ##    ##     ## #### ##    ##  ######

\************************************************************************************************/
const DEFAULT_ARRIVAL_TOLERANCE = 200
const DEFAULT_SQUAD_TOLERANCE_SQR = 250000 //500 * 500
const DEFAULT_ASSAULT_TIMEOUT = 0

function TowerDefenseSquadThink(squad, route, goal = null) {
	foreach(npc in squad)
	npc.StayCloseToSquad(true)

	if (goal == null)
		goal = route[1]

	while (squad.len()) {
		if (IsFinalDestination(route, goal))
			waitthread TD_SquadAssaultPoint(squad, goal, AssaultPointDefaultFinal)
		else
			waitthread TD_SquadAssaultPoint(squad, goal, AssaultPointDefaultBabyStep)

		ArrayRemoveDead(squad)
		if (!squad.len())
			return

		goal = GetNextGoal(route, goal)
		if (goal == null)
			return
	}
}


function TD_SquadAssaultPoint(squad, pos, setupAssaultPointFunc, timeout = DEFAULT_ASSAULT_TIMEOUT) {
	// Guys in squad can die at any time - it seems bad that this can be the case, squad should be clean earlier if at all
	ArrayRemoveInvalid(squad)

	local squadSize = squad.len()
	if (squadSize == 0)
		return

	local isSpectre = squad[0].IsSpectre() && squad[0].IsSpectreTraverseAllowed()
	local team = squad[0].GetTeam()
	local nearestNode = GetNearestNodeToPos(pos)

	local combatDir = pos - squad[0].GetOrigin()
	combatDir.Normalize()

	if (nearestNode < 0) {
		printl("Error: No path nodes near droppod spawn point at " + pos)
		return
	}

	local goalNodes = GetNearbyCoverNodes(nearestNode, squad.len(), HULL_HUMAN, isSpectre, 400, VectorToAngles(combatDir).y, 90)

	// fill up rest with regular nodes
	if (goalNodes.len() < squadSize)
		GetAdditionalNodesForNotEnoughCoverNodes(goalNodes, nearestNode, squadSize)

	foreach(i, node in goalNodes) {
		local nodePos = GetNodePos(node, HULL_HUMAN)
		local npc = squad[i]

		TD_NPC_AssaultsPoint(npc, setupAssaultPointFunc, nodePos)
	}

	waitthread SquadWaitOnFinishedAssault(squad, timeout)
}

function SquadWaitOnFinishedAssault(squad, timeout) {
	local squadStruct = {}
	foreach(npc in squad)
	thread SquadMemberWaitOnFinishedAssault(npc, squad, squadStruct)

	EndSignal(squadStruct, "AssaultTimeOut")
	EndSignal(squadStruct, "SquadDead")

	if (timeout)
		thread SetSignalDelayed(squadStruct, "AssaultTimeOut", timeout)

	WaitSignal(squadStruct, "OnEnterAssaultTolerance")
}

function SquadMemberWaitOnFinishedAssault(npc, squad, squadStruct) {
	npc.EndSignal("OnDeath")
	npc.EndSignal("OnDestroy")
	EndSignal(squadStruct, "AssaultTimeOut")
	EndSignal(squadStruct, "SquadDead")

	OnThreadEnd(
		function(): (squad, squadStruct) {
			foreach(guy in squad) {
				if (IsAlive(guy))
					return
			}
			//nobody alive
			Signal(squadStruct, "SquadDead")
		}
	)

	npc.WaitSignal("OnEnterAssaultTolerance")

	Signal(squadStruct, "OnEnterAssaultTolerance")
}

function TD_NPC_AssaultsPoint(npc, setupAssaultPointFunc, origin, angles = null) {
	Assert("assaultPoint" in npc.s)
	setupAssaultPointFunc(npc.s.assaultPoint)

	npc.s.assaultPoint.SetOrigin(origin)
	if (angles != null)
		npc.s.assaultPoint.SetAngles(angles)

	npc.AssaultPointEnt(npc.s.assaultPoint)
	npc.StayPut(true)
}

function AssaultPointDefaultBabyStep(point) {
	local finalDestination = 0
	__DefaultAssaultPointSetup(point, finalDestination)
}

function AssaultPointDefaultFinal(point) {
	local finalDestination = 1
	__DefaultAssaultPointSetup(point, finalDestination)
}

function __DefaultAssaultPointSetup(point, finalDestination = 0) {
	point.kv.stopToFightEnemyRadius = 150 //will stop moving and fight if enemy within this radius
	point.kv.allowdiversionradius = 0
	point.kv.allowdiversion = 1 //0 = do not divert from path to engage
	point.kv.faceAssaultPointAngles = 0
	point.kv.assaulttolerance = 512 //once at the assault point will move around within this radius to engage
	point.kv.nevertimeout = 1
	point.kv.strict = 1
	point.kv.forcecrouch = 0
	point.kv.spawnflags = 0
	point.kv.finalDestination = finalDestination //1 = AI will stop and engage enemies once at the goal, 0 = will NOT stop, but also have to set allowdiversion to 0
	point.kv.clearoncontact = 0 //clear this assault point on enemy contact ( not physical contact )
	point.kv.assaulttimeout = 0
	point.kv.arrivaltolerance = DEFAULT_ARRIVAL_TOLERANCE //the radius from the point at which we have arrived
}

function AssaultPointBubbleBabyStep(point) {
	local finalDestination = 0
	__BubbleAssaultPointSetup(point, finalDestination)
}

function AssaultPointBubbleFinal(point) {
	local finalDestination = 1
	__BubbleAssaultPointSetup(point, finalDestination)
}

function __BubbleAssaultPointSetup(point, finalDestination = 0) {
	point.kv.stopToFightEnemyRadius = 90 //will stop moving and fight if enemy within this radius
	point.kv.allowdiversionradius = 0
	point.kv.allowdiversion = 1 //0 = do not divert from path to engage
	point.kv.faceAssaultPointAngles = 0
	point.kv.assaulttolerance = 512 //once at the assault point will move around within this radius to engage
	point.kv.nevertimeout = 1
	point.kv.strict = 1
	point.kv.forcecrouch = 0
	point.kv.spawnflags = 0
	point.kv.finalDestination = finalDestination //1 = AI will stop and engage enemies once at the goal, 0 = will NOT stop, but also have to set allowdiversion to 0
	point.kv.clearoncontact = 0 //clear this assault point on enemy contact ( not physical contact )
	point.kv.assaulttimeout = 0
	point.kv.arrivaltolerance = DEFAULT_ARRIVAL_TOLERANCE //the radius from the point at which we have arrived
}

function GetNextGoal(route, goal) {
	local index = null
	foreach(i, pos in route) {
		if (pos != goal)
			continue

		index = i
		break
	}

	Assert(index != null)

	if (index + 1 >= route.len())
		return null

	index++
	return route[index]
}

function IsFinalDestination(route, goal) {
	return goal == route[route.len() - 1]
}

const STUCK_MIN_BUFFER_TIME = 1.5
const STUCK_MAX_BUFFER_TIME = 5.0
const RETRY_MAX_BUFFER_TIME = 7.0
const STUCK_MAX_NODE_DIST = 75
const STUCK_MAX_NODE_DIST_SQR = 5625 //pow( 75, 2 )
function PathFailSolution(npc) {
	npc.EndSignal("OnDeath")
	npc.EndSignal("OnDestroy")

	local continuallyStuck = 0.0
	local lastStuckTime = 0.0
	local killme = false
	local node

	npc.s.triedPathFailSolutionTime <- 0

	OnThreadEnd(
		function(): (node) {
			if (IsValid(node))
				node.Destroy()
		}
	)

	while (1) {
		npc.WaitSignal("OnFailedToPath")

		//OnFailedToPath will signal about once a second - so lets make sure we're getting it constantly
		local newStuckTime = Time()
		local elapsedTime = newStuckTime - lastStuckTime
		if (elapsedTime > STUCK_MIN_BUFFER_TIME)
			continuallyStuck = 0.0
		else
			continuallyStuck += elapsedTime
		lastStuckTime = newStuckTime

		//have we really been stuck for that long?
		if (continuallyStuck < STUCK_MAX_BUFFER_TIME)
			continue

		//are we busy?
		if (!npc.IsInterruptable())
			continue

		//ok we're really stuck - when was the last time we were stuck?
		local lastAttemptTime = newStuckTime - npc.s.triedPathFailSolutionTime

		//if we're stuck in a solid - it doesn't matter that we tried this already - get us out of the solid
		if (EntityInSolid(npc))
			killme = false
		//if we're not stuck in a solid and we recently tried to jump out - then we're just in a bad spot and we gotta die
		else if (lastAttemptTime < RETRY_MAX_BUFFER_TIME)
			killme = true
		//so we're not stuck, but we didn't recently try to jump out - so give us a chance.
		else
			killme = false


		//nearest node is expensive - so only do it if we already know we're not gonna die
		local npcOrigin, nearestNode, nodePos = null
		if (!killme) {
			//lets try and find a close node to jump to
			npcOrigin = npc.GetOrigin()
			nearestNode = GetNearestNodeToPos(npcOrigin)
			if (nearestNode >= 0)
				nodePos = GetNodePos(nearestNode, HULL_HUMAN)
		}

		if (killme == true || nearestNode == null || nearestNode < 0 || DistanceSqr(nodePos, npcOrigin) > STUCK_MAX_NODE_DIST_SQR) {
			//we have nowhere to go - kill us
			local scoreVal = GetCoopScoreValue(npc)
			level.nv.TDCurrentTeamScore += scoreVal
			level.nv.TDStoredTeamScore += scoreVal
			UpdatePlayerKillHistory(null, npc)
			npc.Die(level.worldspawn, level.worldspawn, {
				scriptType = DF_INSTANT,
				damageSourceId = eDamageSourceId.stuck
			})
			return
		}

		//move us to the new node
		local vec = nodePos - npcOrigin
		local angles = Vector(0, VectorToAngles(vec).y, 0)

		npc.SetAngles(angles)

		local animOffset = Vector(0, 0, 36) //the node for the anim is based off a higher point than the ground
		node = CreateScriptRef(nodePos + animOffset, angles)
		node.SetName("PathFailSolutionNode") //just so we can more easily debug this as the parent in the debugger

		local jumpAnim = "path_unstick_jump"
		local blendTime = npc.GetSequenceDuration(jumpAnim)
		npc.SetParent(node, "", false, blendTime)
		npc.Anim_ScriptedPlay(jumpAnim)
		npc.s.triedPathFailSolutionTime = newStuckTime

		wait blendTime
		npc.ClearParent()
		node.Destroy()

		//put us back on track
		npc.AssaultPointEnt(npc.s.assaultPoint)
		npc.StayPut(true)
	}
}

function DebugDrawStationaryPositions() {
	if (level.debugDrawStationaryPositions == false)
		level.debugDrawStationaryPositions = true
	else
		level.debugDrawStationaryPositions = false

	while (level.debugDrawStationaryPositions == true) {
		foreach(table in level.stationaryTitanPositions) {
			local pos = table.origin
			local originString = format("Mortar: %d, %d, %d", pos.x, pos.y, pos.z)
			DebugDrawText(pos, originString, false, 0.5)
			DebugDrawLine(pos, pos + Vector(0, 0, 128), 255, 0, 0, true, 0.5)
		}
		foreach(table in level.TowerDefense_SniperNodes) {
			local pos = table.pos
			local originString = format("Sniper: %d, %d, %d", pos.x, pos.y, pos.z)
			DebugDrawText(pos, originString, false, 0.5)
			DebugDrawLine(pos, pos + Vector(0, 0, 128), 255, 255, 0, true, 0.5)
		}
		wait 0.5
	}
}
Globalize(DebugDrawStationaryPositions)

function DebugDrawRoutes() {
	if (level.debugDrawRoutes == false)
		level.debugDrawRoutes = true
	else
		level.debugDrawRoutes = false

	while (level.debugDrawRoutes == true) {
		foreach(route in level.TowerDefenseRoutes) {
			local originString = format("%d, %d, %d", route[0].x, route[0].y, route[0].z)
			DebugDrawText(route[0], originString, false, 0.5)
			DrawStar(route[0], 64, 0.5, true)
			for (local i = 1; i < route.len(); i++) {
				DebugDrawLine(route[i - 1], route[i], 255, 255, 128, true, 0.5)
			}
		}
		wait 0.5
	}
}
Globalize(DebugDrawRoutes)

/************************************************************************************************\

########  ##     ## ########  ########  ##       ########     ######  ##     ## #### ######## ##       ########
##     ## ##     ## ##     ## ##     ## ##       ##          ##    ## ##     ##  ##  ##       ##       ##     ##
##     ## ##     ## ##     ## ##     ## ##       ##          ##       ##     ##  ##  ##       ##       ##     ##
########  ##     ## ########  ########  ##       ######       ######  #########  ##  ######   ##       ##     ##
##     ## ##     ## ##     ## ##     ## ##       ##                ## ##     ##  ##  ##       ##       ##     ##
##     ## ##     ## ##     ## ##     ## ##       ##          ##    ## ##     ##  ##  ##       ##       ##     ##
########   #######  ########  ########  ######## ########     ######  ##     ## #### ######## ######## ########

\************************************************************************************************/
function TD_SpawnBubbleShieldSpectreSquad(route) {
	return TD_SpawnBubbleShieldMinionSquad(route, TD_SpawnBubbleShieldSpectreSquad)
}

function TD_SpawnBubbleShieldGruntSquad(route) {
	return TD_SpawnBubbleShieldMinionSquad(route, TD_SpawnBubbleShieldGruntSquad)
}

function TD_SpawnBubbleShieldMinionSquad(route, spawnFunc) {
	local team = GetOtherTeam(level.nv.attackingTeam)
	local spawnCount = GetMinionSpawnCount(team)
	local squadName = MakeSquadName(team, "TowerDefensenBubbleShieldSpectre" + UniqueString())
	local spawnPoint = GetMinionSpawnPoint(SpawnPoints_GetDropPod(), team, route[0])
	local ai_type = TD_GetSquadType(spawnFunc)
	local npcSpawnFunc = TD_GetnpcSpawnFunc(spawnFunc)

	local squad = TD_SpawnDroppodSquad(ai_type, team, spawnCount, spawnPoint, squadName, npcSpawnFunc)

	if (squad.len() == 0)
		return []

	foreach(npc in squad) {
		thread ShowOnMinimapOnDeploy(npc)
		thread PathFailSolution(npc)
		GiveMinionWeapon(npc, "mp_weapon_shotgun")
	}

	//get bubble man
	if (IsBubbleShieldMinion(squad[0])) {
		local bubbleMan = squad[0]
		thread TowerDefenseBubbleSquadThink(bubbleMan, squad, route)
	} else
		thread TowerDefenseSquadThink(squad, route)


	return squad
}

function TowerDefenseBubbleSquadThink(bubbleMan, squad, route) {
	foreach(npc in squad) {
		if (npc.IsSpectre())
			npc.AllowSpectreTraverse(false)
		if (npc != bubbleMan) {
			npc.InitFollowBehavior(bubbleMan, AIF_FIRETEAM)
			npc.EnableBehavior("Follow")
		}
	}

	local goal = route[1]
	thread bubbleManSFX(bubbleMan)
	while (IsAlive(bubbleMan)) {
		if (IsFinalDestination(route, goal))
			waitthread TD_SquadAssaultPoint([bubbleMan], goal, AssaultPointBubbleFinal)
		else
			waitthread TD_SquadAssaultPoint([bubbleMan], goal, AssaultPointBubbleBabyStep)

		ArrayRemoveDead(squad)
		if (!squad.len())
			return

		if (!IsAlive(bubbleMan))
			break

		goal = GetNextGoal(route, goal)
		if (goal == null)
			return
	}

	ArrayRemoveDead(squad)

	foreach(npc in squad) {
		if (npc.IsSpectre())
			npc.AllowSpectreTraverse(true)
	}

	thread TowerDefenseSquadThink(squad, route, goal)
}

function bubbleManSFX(bubbleMan) {
	bubbleMan.EndSignal("OnDeath")
	bubbleMan.EndSignal("OnDestroy")

	OnThreadEnd(
		function(): (bubbleMan) {
			if (IsValid(bubbleMan)) {
				EmitSoundOnEntity(bubbleMan, "ShieldSoldier_Shield_End")
				StopSoundOnEntity(bubbleMan, "ShieldSoldier_Shield_Loop")
			}
		}
	)

	EmitSoundOnEntity(bubbleMan, "ShieldSoldier_Shield_Loop")

	WaitForever()
}

/************************************************************************************************\

 ######  ##    ## #### ########  ######## ########
##    ## ###   ##  ##  ##     ## ##       ##     ##
##       ####  ##  ##  ##     ## ##       ##     ##
 ######  ## ## ##  ##  ########  ######   ########
      ## ##  ####  ##  ##        ##       ##   ##
##    ## ##   ###  ##  ##        ##       ##    ##
 ######  ##    ## #### ##        ######## ##     ##

\************************************************************************************************/
function TD_SpawnSniper1x(route) {
	return __SpawnSniperCommon(route, TD_SpawnSniper1x)
}

function TD_SpawnSniper2x(route) {
	return __SpawnSniperCommon(route, TD_SpawnSniper2x)
}

function TD_SpawnSniper3x(route) {
	return __SpawnSniperCommon(route, TD_SpawnSniper3x)
}

function TD_SpawnSniper4x(route) {
	return __SpawnSniperCommon(route, TD_SpawnSniper4x)
}

function __SpawnSniperCommon(route, spawnFunc) {
	local team = GetOtherTeam(level.nv.attackingTeam)
	local spawnCount = GetAICountFromSpawnFunc(spawnFunc)
	local squadName = MakeSquadName(team, "TowerDefenseSniper" + UniqueString())
	local spawnPoint = GetMinionSpawnPoint(SpawnPoints_GetDropPod(), team, route[0])
	local ai_type = TD_GetSquadType(spawnFunc)
	local npcSpawnFunc = TD_GetnpcSpawnFunc(spawnFunc)

	local squad = TD_SpawnDroppodSquad(ai_type, team, spawnCount, spawnPoint, squadName, npcSpawnFunc)

	foreach(sniper in squad)
	thread TowerDefenseSniperThink(sniper, route)

	return squad
}

function HandleSniperLeech(sniper) {
	sniper.EndSignal("OnDeath")
	sniper.EndSignal("OnDestroy")

	sniper.WaitSignal("OnLeeched")

	thread SniperBehavior(sniper)
}

function TowerDefenseSniperThink(sniper, route) {
	sniper.EndSignal("OnDeath")
	sniper.EndSignal("OnDestroy")
	sniper.EndSignal("SniperAssaultGenerator")
	sniper.EndSignal("OnLeeched")

	thread HandleSniperLeech(sniper)

	sniper.WaitSignal("npc_deployed")

	thread ShowOnMinimapOnDeploy(sniper)
	thread PathFailSolution(sniper)
	thread SniperBehavior(sniper)
}

function SniperBehavior(sniper) {
	sniper.EndSignal("OnDeath")
	sniper.EndSignal("OnDestroy")
	sniper.EndSignal("SniperAssaultGenerator")
	sniper.EndSignal("OnLeeched")

	OnThreadEnd(
		function(): (sniper) {
			if (IsAlive(sniper))
				sniper.AssaultPoint(level.TowerDefenseGenLocation.origin)
		}
	)

	local SniperTooCloseDistSqr = 256 * 256
	while (1) {
		//find a new sniping location
		sniper.PreferSprint(true)
		Sniper_MoveToNewLocation(sniper)
		sniper.PreferSprint(false)

		local relocateTimeCheck = 12
		while (1) {
			//hangout here for a while
			thread SetSignalDelayed(sniper, "SniperTimeRelocate", relocateTimeCheck)
			local result = WaitSignal(sniper, "OnDamaged", "SniperTimeRelocate", "OnLostEnemy", "OnLostEnemyLOS")

			//when we first get to our new location we wait a good bit, after that we constantly check for badguys near us and other things
			relocateTimeCheck = 3

			if (result.signal == "OnDamaged") {
				wait 3
				break
			}

			local enemy = sniper.GetEnemy()
			if (enemy == null || !IsAlive(enemy)) //do we not have an enemy?
				break

			//do we have an enemy that is all up in our grill?
			if (DistanceSqr(enemy.GetOrigin(), sniper.GetOrigin()) < SniperTooCloseDistSqr) {
				if (sniper.CanSee(enemy))
					break
			}

			if (!SniperOnLostEnemyLOS(sniper))
				break

			//if we get this far that means we're good to stick around here some more, just loop back to the top
		}
	}
}

function SniperOnLostEnemyLOS(sniper) {
	sniper.EndSignal("OnDeath")
	sniper.EndSignal("OnDestroy")

	local timeout = 0
	local maxTimeout = SNIPERLOSENEMYTIMEOUT
	local interval = 0.2

	while (1) {
		local enemy = sniper.GetEnemy()
		if (!enemy)
			return false

		if (sniper.CanSee(enemy))
			return true

		timeout += interval
		if (timeout >= maxTimeout)
			return false

		wait interval
	}
}

function DecloakSnipersNearWaveEnd() {
	while (1) {
		//basically if out of the last 5 guys, 1 is a sniper, decloak all the snipers
		if (OnlySnipersAreLeft(4)) {
			PermanentlyDecloakAllSnipers()
			return
		}

		level.ent.WaitSignal("AnEnemyWasKilled")
	}
}


function OnlySnipersAreLeft(threshold) {
	local enemies = GetNPCArrayEx("any", GetOtherTeam(level.nv.attackingTeam), Vector(0, 0, 0), -1)

	local count = 0
	foreach(guy in enemies) {
		if (!IsAlive(guy))
			continue

		if (!(guy.IsTitan() || guy.IsSpectre() || guy.IsSoldier()))
			continue

		count++
	}

	count -= threshold

	return (count <= level.nv.TD_numSnipers)
}

function PermanentlyDecloakAllSnipers() {
	local spectres = GetNPCArrayByClass("npc_spectre")
	local snipers = []
	foreach(npc in spectres) {
		if (!IsSniperSpectre(npc))
			continue

		npc.SetCanCloak(false)
		SniperDeCloak(npc)
		npc.Signal("SniperAssaultGenerator")
	}
}

/************************************************************************************************\
CLOAKED DRONE
\************************************************************************************************/

function TD_SpawnCloakedDrone(route) {
	local team = GetOtherTeam(level.nv.attackingTeam)
	local origin = route[0]
	local cloakedDrone = SpawnCloakDrone(team, origin, Vector(0, 0, 0))

	IncrementWaveNumCloakedDrones()

	return [cloakedDrone]
}

/************************************************************************************************\

 ######  ##     ## ####  ######  #### ########  ########
##    ## ##     ##  ##  ##    ##  ##  ##     ## ##
##       ##     ##  ##  ##        ##  ##     ## ##
 ######  ##     ##  ##  ##        ##  ##     ## ######
      ## ##     ##  ##  ##        ##  ##     ## ##
##    ## ##     ##  ##  ##    ##  ##  ##     ## ##
 ######   #######  ####  ######  #### ########  ########

\************************************************************************************************/
function TowerDefenseSuicideSpectreCustomize(spectre) {
	if (Riff_AILethality() > eAILethality.TD_Low)
		SetSuicideSpectreExplosionData(spectre, null, TD_MED_SUICIDE_TITANDMG, TD_MED_SUICIDE_PILOTDMG)
	else
		SetSuicideSpectreExplosionData(spectre, null, TD_LOW_SUICIDE_TITANDMG, TD_LOW_SUICIDE_PILOTDMG)

	DisableNeutralize(spectre)
	SetFastSpectre(spectre)
}

function SuicideSquadThink(squad, route, goal = null) {
	foreach(npc in squad) {
		npc.kv.squadname = ""
		npc.StayCloseToSquad(true)
	}

	if (goal == null)
		goal = route[1]

	while (1) {
		ArrayRemoveDead(squad)
		if (!squad.len())
			return

		foreach(spectre in squad)
		spectre.DisableArrivalOnce(true)

		if (IsFinalDestination(route, goal))
			waitthread TD_SquadAssaultPoint(squad, goal, AssaultPointSuicideFinal)
		else
			waitthread TD_SquadAssaultPoint(squad, goal, AssaultPointSuicideBabyStep)

		goal = GetNextGoal(route, goal)
		if (goal == null)
			break
	}

	//we're near the generator
	local generator = level.TowerDefenseGenerator
	foreach(spectre in squad) {
		if (IsAlive(spectre)) {
			SetSuicideSpectreExplosionData(spectre, 280)
			spectre.SetEnemy(generator)
		}
	}
}

function AssaultPointSuicideBabyStep(point) {
	point.kv.finalDestination = 0
	point.kv.nevertimeout = 1
	__SuicideAssaultPointSetup(point)
}

function AssaultPointSuicideFinal(point) {
	point.kv.finalDestination = 1
	point.kv.nevertimeout = 0
	__SuicideAssaultPointSetup(point)
}

function __SuicideAssaultPointSetup(point) {
	point.kv.stopToFightEnemyRadius = SPECTRE_MAX_SIGHT_DIST //will stop moving and fight if enemy within this radius
	point.kv.allowdiversionradius = SPECTRE_MAX_SIGHT_DIST
	point.kv.allowdiversion = 1 //0 = do not divert from path to engage
	point.kv.faceAssaultPointAngles = 0
	point.kv.assaulttolerance = 64 //once at the assault point will move around within this radius to engage
	point.kv.strict = 1
	point.kv.forcecrouch = 0
	point.kv.spawnflags = 0
	point.kv.clearoncontact = 0 //clear this assault point on enemy contact ( not physical contact )
	point.kv.assaulttimeout = 0
	point.kv.arrivaltolerance = DEFAULT_ARRIVAL_TOLERANCE //the radius from the point at which we have arrived
}

/************************************************************************************************\

 ######   ######## ##    ## ######## ########     ###    ########  #######  ########
##    ##  ##       ###   ## ##       ##     ##   ## ##      ##    ##     ## ##     ##
##        ##       ####  ## ##       ##     ##  ##   ##     ##    ##     ## ##     ##
##   #### ######   ## ## ## ######   ########  ##     ##    ##    ##     ## ########
##    ##  ##       ##  #### ##       ##   ##   #########    ##    ##     ## ##   ##
##    ##  ##       ##   ### ##       ##    ##  ##     ##    ##    ##     ## ##    ##
 ######   ######## ##    ## ######## ##     ## ##     ##    ##     #######  ##     ##

\************************************************************************************************/
function TowerDefenseCreateGenerator() {
	level.nv.TDGeneratorHealth = TD_GENERATOR_HEALTH
	level.nv.TDGeneratorShieldHealth = TD_GENERATOR_SHIELD_HEALTH
	ClearMarker(MARKER_TOWERDEFENSEGENERATOR)

	if (level.TowerDefenseGenerator == null) {
		local origin = level.TowerDefenseGenLocation.origin
		local angles = level.TowerDefenseGenLocation.angles
		local team = level.nv.attackingTeam
		local angleOffset = Vector(0, 90, 0)
		local solidType = 6 // 0 = no collision, 2 = bounding box, 6 = use vPhysics, 8 = hitboxes only

		local generator = CreatePropDynamic(MODEL_GEN_TOWER, Vector(0, 0, 0), Vector(0, -90, 0) + angleOffset, solidType)
		generator.EnableAttackableByAI()
		generator.s.isGeneratorModel <- true
		generator.SetTeam(team)
		SetVisibleEntitiesInConeQueriableEnabled(generator, true) //for arc cannon and emp titan

		DisableTitanfallForLifetimeOfEntityNearOrigin(generator, origin, 192)

		generator.SetOrigin(origin)
		generator.SetAngles(angles)

		// spawn rings model at the attach point and hide until it's time to start up
		local attachID = generator.LookupAttachment("ATTACH")
		local attachOrg = generator.GetAttachmentOrigin(attachID)
		local attachAng = generator.GetAttachmentAngles(attachID)
		local ringSolidity = 0 // no collision
		local generatorRings = CreatePropDynamic(MODEL_GEN_TOWER_RINGS, attachOrg, attachAng, ringSolidity)
		generatorRings.Hide()
		generatorRings.s.currAnim <- null
		generator.s.rings <- generatorRings

		generator.s.healthStage <- null
		generator.s.damageFX <- null
		generator.s.damageSFX <- null
		generator.s.ambientSFX <- null

		// give generator some health so that nuke titans and suicide spectres will do damage to it.
		// this health doesn't actually go down when it takes damage
		generator.SetMaxHealth(999999)
		generator.SetHealth(999999)

		local cpoint = CreateEntity("info_placement_helper")
		cpoint.SetName(UniqueString("generator_fx_colors"))
		DispatchSpawn(cpoint, false)
		generator.s.fxColorControlPoint <- cpoint

		generator.Minimap_AlwaysShow(TEAM_IMC, null)
		generator.Minimap_AlwaysShow(TEAM_MILITIA, null)
		generator.Minimap_SetDefaultMaterial("vgui/HUD/coop/coop_harvester")
		generator.Minimap_SetAlignUpright(true)
		generator.Minimap_SetObjectScale(MINIMAP_GENERATOR_SCALE)
		generator.Minimap_SetAlignUpright(true)
		generator.Minimap_SetZOrder(10)

		thread ClearMarker_OnEntDeath(generator, MARKER_TOWERDEFENSEGENERATOR)

		generator.s.shieldsDownTime <- null

		thread GeneratorShieldRegenThink(generator)
		thread Generator_StatusVOThink(generator)

		level.TowerDefenseGenerator = generator
	}

	level.TowerDefenseGenerator.s.healthStage = eGeneratorHealthStage.PERFECT

	Generator_KillDmgFX() // kills off damage FX on prematch, under black screen
}

function GeneratorRingsPlayAnim(animAlias) {
	local rings = level.TowerDefenseGenerator.s.rings

	if (rings.s.currAnim != null && rings.s.currAnim != animAlias) {
		rings.Anim_Stop()
		rings.s.currAnim = null
	}

	rings.s.currAnim = animAlias
	PlayAnim(rings, animAlias)
}

function ClearMarker_OnEntDeath(ent, markeralias) {
	WaitSignal(ent, "OnDeath", "OnDestroy")

	ClearMarker(markeralias)
}

function GeneratorBeamStop() {
	local generator = level.TowerDefenseGenerator

	generator.Signal("StopGeneratorBeam")
}
Globalize(GeneratorBeamStop)


function GeneratorStart_AndThink(startDelay = 0.0) {
	local generator = level.TowerDefenseGenerator
	Assert(IsValid(generator))
	local rings = generator.s.rings
	Assert(IsValid(rings))

	FlagSet("GeneratorBeam_On")

	generator.Signal("StopGeneratorBeam")
	generator.EndSignal("StopGeneratorBeam")

	generator.EndSignal("OnDestroy")
	rings.EndSignal("OnDestroy")

	if (startDelay > 0)
		wait startDelay

	EmitSoundOnEntity(generator, "Coop_Generator_Startup")
	Generator_StartAmbientSFX("Coop_Generator_Ambient_Healthy")
	delaythread(2) SetMarker(MARKER_TOWERDEFENSEGENERATOR, generator)

	local harvesterBeamFX = PlayFXWithControlPoint(FX_GEN_HARVESTER_BEAM, generator.GetOrigin(), generator.s.fxColorControlPoint, null, null, null, C_PLAYFX_LOOP)

	OnThreadEnd(
		function(): (generator, harvesterBeamFX, rings) {
			if (IsValid(harvesterBeamFX)) {
				local beamEndcapWait = 8.0
				if (GetGameState() == eGameState.WinnerDetermined)
					beamEndcapWait = GetWinnerDeterminedWait() // we want the endcap to play until WinnerDetermined ends and the screen fades

				thread KillFXWithEndcap(harvesterBeamFX, beamEndcapWait)
			}

			if (IsValid(rings))
				thread GeneratorRings_DeathSequence()

			if (IsValid(generator)) {
				Generator_FadeAmbientSFX()
				// damage FX will get stopped in TowerDefenseCreateGenerator (we want those to linger until after retry screen fade)

				// HACK if it took a ton of damage all at once, it might skip updating color and starting the low health FX (like when we kill the generator with a 1-shot command for testing)
				if (!IsValid(generator.s.damageFX)) {
					Generator_UpdateFXColorControlPoint()
					Generator_StartDmgFX(FX_GEN_HEALTH_LOW)
				}
			}

			FlagClear("GeneratorBeam_On")
		}
	)

	Generator_UpdateFXColorControlPoint()

	// rings rise up and then idle
	rings.Show()
	GeneratorRingsPlayAnim("generator_rise")
	thread GeneratorRingsPlayAnim("generator_cycle_fast")

	local maxHealth = TD_GENERATOR_HEALTH
	local oldHealthRatio = 0
	local oldShieldRatio = 0

	while (true) {
		local healthRatio = Generator_GetHealthRatio()
		local shieldRatio = Generator_GetShieldRatio()

		// Hack since NPC can get inside the generator on some maps when mantling.
		DestoyNPCInsideGenerator(generator.GetOrigin())

		if (healthRatio != oldHealthRatio || shieldRatio != oldShieldRatio) {
			Generator_UpdateFXColorControlPoint()

			oldHealthRatio = healthRatio
			oldShieldRatio = shieldRatio
		}

		local healthFrac_DAMAGED = 0.7
		local healthFrac_CRITICAL = 0.45

		// update generator SFX and damage FX
		if (healthRatio < 1.0) {
			if (healthRatio >= healthFrac_DAMAGED && generator.s.healthStage != eGeneratorHealthStage.HEALTHY) {
				generator.s.healthStage = eGeneratorHealthStage.HEALTHY

				Generator_StartAmbientSFX("Coop_Generator_Ambient_Healthy")
				thread GeneratorRingsPlayAnim("generator_cycle_fast")
			} else if ((healthRatio < healthFrac_DAMAGED && healthRatio >= healthFrac_CRITICAL) && generator.s.healthStage != eGeneratorHealthStage.DAMAGED) {
				generator.s.healthStage = eGeneratorHealthStage.DAMAGED

				Generator_StartAmbientSFX("Coop_Generator_Ambient_Damaged")
				thread GeneratorRingsPlayAnim("generator_cycle_fast")
			} else if (healthRatio < healthFrac_CRITICAL && generator.s.healthStage != eGeneratorHealthStage.CRITICAL) {
				generator.s.healthStage = eGeneratorHealthStage.CRITICAL

				Generator_StartAmbientSFX("Coop_Generator_Ambient_Critical")
				Generator_StartDmgFX(FX_GEN_HEALTH_LOW)
				thread GeneratorRingsPlayAnim("generator_cycle_slow")
			}
		} else if (generator.s.healthStage != eGeneratorHealthStage.PERFECT) {
			generator.s.healthStage = eGeneratorHealthStage.PERFECT

			Generator_StartAmbientSFX("Coop_Generator_Ambient_Healthy")
		}

		wait HARVESTER_BEAM_TICK_TIME
	}
}
Globalize(GeneratorStart_AndThink)

function DestoyNPCInsideGenerator(generatorOrigin) {
	local npcArray = GetNPCArrayEx("npc_soldier", TEAM_IMC, generatorOrigin, 80)
	npcArray.extend(GetNPCArrayEx("npc_spectre", TEAM_IMC, generatorOrigin, 80))
	npcArray.extend(GetNPCArrayEx("npc_titan", TEAM_IMC, generatorOrigin, 80))

	//	DebugDrawCircle( generatorOrigin, Vector( 0, 0, 0 ), 80, 255, 0, 0, 1 )
	foreach(npc in npcArray) {
		local scoreVal = GetCoopScoreValue(npc)
		level.nv.TDCurrentTeamScore += scoreVal
		level.nv.TDStoredTeamScore += scoreVal
		UpdatePlayerKillHistory(null, npc)
		npc.Die(level.worldspawn, level.worldspawn, {
			scriptType = DF_INSTANT,
			damageSourceId = eDamageSourceId.stuck
		})
	}
}

function Generator_StartDmgFX(fxID) {
	local generator = level.TowerDefenseGenerator

	if (IsValid(generator.s.damageFX))
		StopFX(generator.s.damageFX)

	if (generator.s.damageSFX != null)
		StopSoundOnEntity(generator, generator.s.damageSFX)

	generator.s.damageFX = PlayFXWithControlPoint(fxID, generator.GetOrigin(), generator.s.fxColorControlPoint, null, null, null, C_PLAYFX_LOOP)

	generator.s.damageSFX = "Coop_Generator_Electrical_Arcs"
	EmitSoundOnEntity(generator, generator.s.damageSFX)
}

function Generator_KillDmgFX() {
	local generator = level.TowerDefenseGenerator

	if (IsValid(generator.s.damageFX))
		StopFX_DestroyImmediately(generator.s.damageFX)

	if (generator.s.damageSFX != null)
		StopSoundOnEntity(generator, generator.s.damageSFX)
}

function Generator_StartAmbientSFX(soundAlias) {
	local generator = level.TowerDefenseGenerator

	if (generator.s.ambientSFX != null && generator.s.ambientSFX == soundAlias)
		return

	Generator_FadeAmbientSFX()

	EmitSoundOnEntity(generator, soundAlias)
	generator.s.ambientSFX = soundAlias
}

function Generator_FadeAmbientSFX() {
	Generator_StopAmbientSFX(true)
}

function Generator_StopAmbientSFX(doFade = false) {
	local generator = level.TowerDefenseGenerator

	if (generator.s.ambientSFX != null) {
		if (doFade)
			FadeOutSoundOnEntity(generator, generator.s.ambientSFX, 1.0)
		else
			StopSoundOnEntity(generator, generator.s.ambientSFX)

		generator.s.ambientSFX = null
	}
}

function GeneratorRings_DeathSequence() {
	local rings = level.TowerDefenseGenerator.s.rings
	rings.EndSignal("OnDestroy")

	GeneratorRingsPlayAnim("generator_fall")

	rings.Hide()
	thread GeneratorRingsPlayAnim("generator_idle")
}


function Generator_UpdateFXColorControlPoint() {
	local generator = level.TowerDefenseGenerator

	local colors = Generator_GetHealthStatusColorTable()
	local colorVec = Vector(colors.r, colors.g, colors.b)

	generator.s.fxColorControlPoint.SetOrigin(colorVec)
}

function GeneratorShieldRegenThink(generator) {
	generator.EndSignal("OnDestroy")

	generator.s.nextRegenTime <- 0

	local alarmSoundAlias = "Coop_Generator_UnderAttack_Alarm"
	local alarmFadeTime = 1.0

	OnThreadEnd(
		function(): (generator, alarmSoundAlias) {
			if (IsValid(generator))
				StopSoundOnEntity(generator, alarmSoundAlias)
		}
	)

	local lastShieldHealth = level.nv.TDGeneratorShieldHealth
	local shieldHealthSound = false
	local soundAlarm = false
	local shieldRegenStarted = false
	local maxShield = TD_GENERATOR_SHIELD_HEALTH
	local shieldRegenRate = maxShield / (GENERATOR_SHIELD_REGEN_TIME / SHIELD_REGEN_TICK_TIME)
	local lastTime = Time()

	while (true) {
		local shieldHealth = level.nv.TDGeneratorShieldHealth

		if (Flag("TDGeneratorDestroyed")) {
			FadeOutSoundOnEntity(generator, alarmSoundAlias, alarmFadeTime)
			soundAlarm = false
		} else if (shieldHealth == 0 && soundAlarm == false) {
			generator.s.shieldsDownTime = Time()

			EmitSoundOnEntity(generator, alarmSoundAlias)
			soundAlarm = true
		}
		if (ShouldRegenShield(generator, shieldHealth, maxShield)) {
			local frameTime = max(0.0, Time() - lastTime)
			local adjustedShieldRegenRate = shieldRegenRate * frameTime / SHIELD_REGEN_TICK_TIME
			shieldHealth = min(TD_GENERATOR_SHIELD_HEALTH, shieldHealth + adjustedShieldRegenRate)
			if (lastShieldHealth != TD_GENERATOR_SHIELD_HEALTH && shieldHealth == TD_GENERATOR_SHIELD_HEALTH)
				EmitSoundOnEntity(generator, "Coop_Generator_ShieldRecharge_End") //EmitSoundToTeamPlayers( "Coop_Generator_ShieldRecharge_End", level.nv.attackingTeam )
			else if (!shieldRegenStarted) {
				local seekTime = GENERATOR_SHIELD_REGEN_TIME * lastShieldHealth / TD_GENERATOR_SHIELD_HEALTH
				PlayGeneratorShieldResumeSFX(generator, seekTime)
				if (lastShieldHealth == 0)
					EmitSoundOnEntity(generator, "Coop_Generator_ShieldRecharge_Start") //EmitSoundToTeamPlayers( "Coop_Generator_ShieldRecharge_Start", level.nv.attackingTeam )
				EmitSoundOnEntity(generator, "Coop_Generator_ShieldRecharge_ResumeClick")
			}
			FadeOutSoundOnEntity(generator, alarmSoundAlias, alarmFadeTime)
			soundAlarm = false
			shieldRegenStarted = true
		} else {
			shieldRegenStarted = false
		}

		level.nv.TDGeneratorShieldHealth = shieldHealth
		lastShieldHealth = shieldHealth
		lastTime = Time()
		wait 0
	}
}

function PlayGeneratorShieldResumeSFX(generator, seekTime) {
	//We generally don't seek on the server, so we don't have a general function.
	local playerArray = GetPlayerArray()
	foreach(player in playerArray) {
		EmitSoundOnEntityOnlyToPlayerWithSeek(generator, player, "Coop_Generator_ShieldRecharge_Resume", seekTime)
	}
}

function ShouldRegenShield(generator, shieldHealth, maxShield) {
	if (GetGameState() < eGameState.Playing)
		return false

	if (GetGameState() > eGameState.Playing && !Flag("ObjectiveComplete"))
		return false

	if (generator.s.nextRegenTime > Time())
		return false

	if (shieldHealth == maxShield)
		return false

	return true
}

const TITAN_GENERATOR_MELEE_DMG = 1000

function GeneratorTookDamage(generator, damageInfo) {
	if (!("isGeneratorModel" in generator.s))
		return

	if (!Flag("COOBJ_TowerDefense"))
		return

	if (Flag("GeneratorGodMode")) {
		damageInfo.SetDamage(0)
		return
	}

	local damageAmount = damageInfo.GetDamage()
	local attacker = damageInfo.GetAttacker()
	local inflictor = damageInfo.GetInflictor()
	local playerTeam = level.nv.attackingTeam

	// ADJUST DAMAGE SCALE IF NECESSARY
	local damageSourceID = damageInfo.GetDamageSourceIdentifier()
	switch (damageSourceID) {
		case eDamageSourceId.nuclear_core:
			damageAmount *= GENERATOR_DAMAGE_NUKE_CORE_MULTIPLIER
		case eDamageSourceId.mp_titanweapon_rocket_launcher:
			if (IsValid(inflictor) && "mortar" in inflictor.s)
				damageAmount *= GENERATOR_DAMAGE_MORTAR_ROCKET_MULTIPLIER
			break

		case eDamageSourceId.titanEmpField:
			damageInfo.SetDamage(0)
			damageAmount = 0
			level.nv.TDGeneratorShieldHealth = 0
			break

		case eDamageSourceId.titan_melee:
			damageAmount = min(damageAmount, TITAN_GENERATOR_MELEE_DMG)
			damageInfo.SetDamage(damageAmount)
			break

		case eDamageSourceId.titan_step:
		case eDamageSourceId.invalid:
			if (damageInfo.GetDamageType() == DMG_CLUB) {
				damageAmount = min(damageAmount, TITAN_GENERATOR_MELEE_DMG)
				damageInfo.SetDamage(damageAmount)
			} else {
				damageInfo.SetDamage(0)
				return
			}
			break
		case eDamageSourceId.titan_fall:
			damageInfo.SetDamage(0)
			return
			break
	}

	if (Riff_AILethality() < eAILethality.TD_Medium)
		damageInfo.SetDamage(damageInfo.GetDamage() * TD_LOW_SCALAR_GENERATOR_DMG)

	local preShieldDamage = damageAmount
	// NOW AFFECT SHIELDS/HEALTH BASED ON HOW MUCH DMG SHIELDS ABSORBED
	if (level.nv.TDGeneratorShieldHealth > 0) {
		local shieldHealth = level.nv.TDGeneratorShieldHealth
		local newShieldHealth = max(0, level.nv.TDGeneratorShieldHealth - damageAmount)
		level.nv.TDGeneratorShieldHealth = newShieldHealth

		if (shieldHealth > 0 && newShieldHealth == 0)
			EmitSoundOnEntity(generator, "Coop_Generator_ShieldDown") //EmitSoundToTeamPlayers( "Coop_Generator_ShieldDown", playerTeam )

		damageAmount = max(0, damageAmount - shieldHealth)
	}
	// if you kill/destroy a guy while his missile is in the air, the attacker will be the missile instead of the dead guy.
	if (attacker.IsNPC() && attacker.GetTeam() != playerTeam) {
		local attackerClass = attacker.GetClassname()
		local attackerSubclass = attacker.GetSubclass()

		local aiTypeID = Coop_GetAITypeID_ByClassAndSubclass(attackerClass, attackerSubclass)
		UpdateGeneratorAttackHistory(aiTypeID, preShieldDamage, damageAmount)
	}

	generator.s.nextRegenTime = Time() + GENERATOR_SHIELD_REGEN_DELAY

	// RETURN IF NO DAMAGE WAS DEALT
	if (damageAmount <= 0) {
		Play3PHarvesterImpactSounds(generator, damageInfo)
		return
	}

	level.nv.TDGeneratorHealth -= damageAmount

	if (level.nv.TDGeneratorHealth < 0) {
		EmitSoundOnEntity(generator, "Coop_Generator_Destroyed") //EmitSoundToTeamPlayers( "Coop_Generator_Destroyed", level.nv.attackingTeam )
		FlagSet("TDGeneratorDestroyed")
		//Catch the last wave state during defeat.
		if (Coop_GetNumRestartsLeft() == 0) {
			Add_TimeInterval_HarvesterStatus()
		}
	}
}

function InitGeneratorAttackHistory() {
	local defaultTable = {
		totalDamage = 0,
		currentDamageStreak = 0,
		lastDamageTime = -1,
		actualDamage = 0
	}

	level.generatorAttackHistory.global <- clone defaultTable

	foreach(nameKey, aiTypeID in getconsttable().eCoopAIType)
	level.generatorAttackHistory[aiTypeID] <- clone defaultTable
}

function InitEOGKillHistory() {
	level.killHistory <- {}
	//Index 0 = Militia Team Stats
	for (local i = 0; i <= COOP_MAX_PLAYER_COUNT; i++) {
		level.killHistory[i] <- {}
		local playerKillCount = 0
		local turretKillCount = 0
		foreach(nameKey, aiTypeID in getconsttable().eCoopAIType)
		level.killHistory[i][aiTypeID] <- [playerKillCount, turretKillCount]
	}
}

function ResetPlayerKillHistory(player) {
	local index = player.GetEntIndex()
	foreach(nameKey, aiTypeID in getconsttable().eCoopAIType)
	level.killHistory[index][aiTypeID] <- [0, 0]
}

function UpdatePlayerKillHistory(player, npc, attackerIsTurret = false) {
	//This adds to the team record and player record. There are cases where the team can get credit without any players getting credit.
	local indexArray = [0]
	if (player != null)
		indexArray.append(player.GetEntIndex())

	local npcClass = npc.GetClassname()
	local npcSubclass = null
	if (npcClass != "prop_dynamic")
		npcSubclass = npc.GetSubclass()

	local aiTypeID = Coop_GetAITypeID_ByClassAndSubclass(npcClass, npcSubclass)
	for (local i = 0; i < indexArray.len(); i++) {
		if (attackerIsTurret)
			level.killHistory[indexArray[i]][aiTypeID][1]++
		else
			level.killHistory[indexArray[i]][aiTypeID][0]++
	}
}
Globalize(UpdatePlayerKillHistory)

function ResetGeneratorAttackStreakHistory() {
	foreach(aiTypeID, attackInfo in level.generatorAttackHistory) {
		// Only reset streak stuff, not total damage
		attackInfo.currentDamageStreak = 0
		attackInfo.lastDamageTime = -1
	}

	level.generatorAttackHistory.global.currentDamageStreak = 0
	level.generatorAttackHistory.global.lastDamageTime = -1
}

function UpdateGeneratorAttackHistory(aiTypeID, preShieldDamageAmount, postShieldDamageAmount) {
	// GLOBAL attack history update
	local globalInfo = level.generatorAttackHistory.global
	globalInfo.totalDamage += preShieldDamageAmount
	globalInfo.actualDamage += postShieldDamageAmount

	if (globalInfo.lastDamageTime != -1 && Time() - globalInfo.lastDamageTime >= GENERATOR_DAMAGE_STREAK_TIMEOUT)
		globalInfo.currentDamageStreak = 0

	globalInfo.currentDamageStreak += preShieldDamageAmount
	globalInfo.lastDamageTime = Time()

	// AIType specific attack history update
	local attackInfo = level.generatorAttackHistory[aiTypeID]

	attackInfo.totalDamage += preShieldDamageAmount
	attackInfo.actualDamage += postShieldDamageAmount

	if (attackInfo.lastDamageTime != -1 && Time() - attackInfo.lastDamageTime >= GENERATOR_DAMAGE_STREAK_TIMEOUT)
		attackInfo.currentDamageStreak = 0

	attackInfo.currentDamageStreak += preShieldDamageAmount
	attackInfo.lastDamageTime = Time()

	//printt( "Attack history update:", GetCoopAITypeString_ByID( aiTypeID ), "dmg / dmgstreak:", attackInfo.totalDamage, "/", attackInfo.currentDamageStreak )
}

function Generator_CheckDamageStreak(aiTypeID, reqStreakDmg) {
	local idx = "global"
	if (aiTypeID != idx) {
		ValidateCoopAITypeIdx(aiTypeID)
		idx = aiTypeID
	}

	local attackInfo = level.generatorAttackHistory[aiTypeID]

	// hasn't attacked the generator yet this wave
	if (attackInfo.lastDamageTime == -1)
		return false

	// no active damage streak
	if (Time() - attackInfo.lastDamageTime >= GENERATOR_DAMAGE_STREAK_TIMEOUT)
		return false

	// damage streak hasn't hit threshold
	if (attackInfo.currentDamageStreak < reqStreakDmg)
		return false

	return true
}

function Generator_StatusVOThink(generator) {
	FlagEnd("ObjectiveComplete")
	FlagEnd("ObjectiveFailed")

	generator.EndSignal("OnDestroy")

	local lastShieldHealth = level.nv.TDGeneratorShieldHealth
	local lastGeneratorHealth = level.nv.TDGeneratorHealth

	// these switches get flipped on and off so we're not spamming VO requests against a timer
	local canAnnounceShieldRecharging = true
	local canAnnounceShieldDown = true
	local canAnnounceShieldFull = false // don't want the announce to happen at game start
	local canAnnounceHealthStatus = true
	local resetCanAnnounceHealth_aboveFrac = 0.0
	local resetCanAnnounceHealth_belowFrac = 1.0

	local shieldHealth
	local maxShield
	local shieldRatio

	local generatorHealth
	local maxHealth
	local healthRatio

	local playedVO = false
	local longWait = 4.5

	local lastThreatCheck = Time()
	local threatCheckRate = 5.0

	while (1) {
		if (playedVO) {
			TimerReset("Nag_GeneratorStatus_Global")
			wait longWait
		} else
			wait SHIELD_REGEN_TICK_TIME

		if (!Flag("CoopTD_WaveCombatInProgress") || Flag("TDGeneratorDestroyed")) {
			wait longWait
			continue
		}

		// Specific threat announcement will supercede generic status announcement
		if (Time() - lastThreatCheck >= threatCheckRate) {
			lastThreatCheck = Time()

			waitthread Generator_TryAnnounceThreats(generator)
			continue
		}

		shieldHealth = level.nv.TDGeneratorShieldHealth
		maxShield = TD_GENERATOR_SHIELD_HEALTH
		shieldRatio = shieldHealth.tofloat() / maxShield.tofloat()

		generatorHealth = level.nv.TDGeneratorHealth
		maxHealth = TD_GENERATOR_HEALTH
		healthRatio = generatorHealth.tofloat() / maxHealth.tofloat()

		playedVO = false

		if (!TimerCheck("Nag_GeneratorStatus_Global"))
			continue

		// protects us against announcing that the shields are down long after they've actually gone down
		local shieldsDownTime = generator.s.shieldsDownTime
		if (canAnnounceShieldDown && shieldsDownTime != null && (Time() - shieldsDownTime) > SHIELD_DOWN_ANNOUNCE_TIMEOUT)
			canAnnounceShieldDown = false

		// Shields down: initial announce
		if (shieldRatio <= 0.0 && canAnnounceShieldDown) {
			PlayConversationToCoopTeam("CoopTD_GeneratorShield_Down")
			canAnnounceShieldDown = false
			playedVO = true
		}
		// Shields down: Low health announce
		else if (shieldRatio <= 0.0 && canAnnounceHealthStatus && TimerCheck("Nag_GeneratorHealth")) {
			local healthVO = null

			local fracs = {}
			fracs[75] <- {
				max = 0.8,
				min = 0.7
			}
			fracs[50] <- {
				max = 0.6,
				min = 0.4
			}
			fracs[25] <- {
				max = 0.3,
				min = 0.2
			}

			if (healthRatio <= fracs[75].max && healthRatio >= fracs[75].min) {
				healthVO = "CoopTD_GeneratorHealth_75"
				resetCanAnnounceHealth_aboveFrac = fracs[75].max
				resetCanAnnounceHealth_belowFrac = fracs[75].min
			} else if (healthRatio <= fracs[50].max && healthRatio >= fracs[50].min) {
				healthVO = "CoopTD_GeneratorHealth_50"
				if (CoinFlip())
					healthVO = "CoopTD_GeneratorHealth_50_Nag"

				resetCanAnnounceHealth_aboveFrac = fracs[50].max
				resetCanAnnounceHealth_belowFrac = fracs[50].min
			} else if (healthRatio <= fracs[25].max && healthRatio >= fracs[25].min) {
				healthVO = "CoopTD_GeneratorHealth_25"
				if (CoinFlip())
					healthVO = "CoopTD_GeneratorHealth_25_Nag"

				resetCanAnnounceHealth_aboveFrac = fracs[25].max
				resetCanAnnounceHealth_belowFrac = fracs[25].min
			} else if (healthRatio < fracs[25].min) {
				healthVO = "CoopTD_GeneratorHealth_Low"
				resetCanAnnounceHealth_aboveFrac = 0.2
				resetCanAnnounceHealth_belowFrac = 0.0
			}

			if (healthVO != null) {
				TimerReset("Nag_GeneratorHealth")
				PlayConversationToCoopTeam(healthVO)
				canAnnounceHealthStatus = false
				playedVO = true
			}
		}
		// Shields down: HOLD THE LINE!!
		else if (shieldRatio <= 0.0 && !canAnnounceHealthStatus && TimerCheck("Nag_HoldTheLine")) {
			// This should trigger when the coop team is fighting hard to keep it together.
			if (GeneratorStatus_PlayersFightingDesperately(shieldRatio, healthRatio)) {
				TimerReset("Nag_HoldTheLine")
				PlayConversationToCoopTeam("CoopTD_HoldTheLine")
				playedVO = true
			}
		}
		// shields up
		else if (shieldRatio > 0.0) {
			if (!canAnnounceShieldDown)
				canAnnounceShieldDown = true

			// Full shields announce
			if (shieldRatio == 1.0 && canAnnounceShieldFull) {
				PlayConversationToCoopTeam("CoopTD_GeneratorShield_Full")
				canAnnounceShieldFull = false
				playedVO = true
			} else if (shieldRatio < 0.9 && shieldHealth < lastShieldHealth && TimerCheck("Nag_GeneratorStatus_ShieldDamage")) {
				TimerReset("Nag_GeneratorStatus_ShieldDamage")

				local alias = "CoopTD_GeneratorShield_Damage_Light"
				if (shieldRatio < 0.5)
					alias = "CoopTD_GeneratorShield_Damage_Heavy"

				PlayConversationToCoopTeam(alias)
				playedVO = true
			}
			// Recharging announce
			else if (shieldRatio < 1.0 && shieldHealth > lastShieldHealth && canAnnounceShieldRecharging) {
				PlayConversationToCoopTeam("CoopTD_GeneratorShield_Recharging")
				canAnnounceShieldRecharging = false
				playedVO = true
			}
		}

		if (!canAnnounceHealthStatus && generatorHealth < lastGeneratorHealth && (healthRatio > resetCanAnnounceHealth_aboveFrac || healthRatio < resetCanAnnounceHealth_belowFrac)) {
			printt("Resetting health announce", healthRatio, resetCanAnnounceHealth_aboveFrac, resetCanAnnounceHealth_belowFrac)
			canAnnounceHealthStatus = true
		}

		if (shieldRatio < 1.0 && shieldHealth < lastShieldHealth && !canAnnounceShieldRecharging)
			canAnnounceShieldRecharging = true

		if (shieldRatio < 0.0 && !canAnnounceShieldFull)
			canAnnounceShieldFull = true

		lastShieldHealth = shieldHealth
		lastGeneratorHealth = generatorHealth
	}
}

function GeneratorStatus_PlayersFightingDesperately(shieldRatio, healthRatio) {
	if (shieldRatio > 0.0)
		return false

	if (healthRatio > 0.65)
		return false

	// check if there's an active damage streak
	if (!Generator_CheckDamageStreak("global", GENERATOR_THREAT_WARN_STREAKDMG_GLOBAL))
		return false

	local reqNumPlayers = 2
	local reqPlayerDist = 3000
	local reqNumTitans = 5
	local reqNonMortarFrac = 0.6

	local playerTeam = level.nv.attackingTeam
	local nonPlayerTeam = GetOtherTeam(level.nv.attackingTeam)

	local generator = level.TowerDefenseGenerator
	local generatorOrg = generator.GetOrigin()

	local players = GetPlayerArrayEx("any", playerTeam, generatorOrg, reqPlayerDist)

	// respawning players don't get counted as active defenders
	local temp = []
	foreach(player in players) {
		if (HasCinematicFlag(player, CE_FLAG_WAVE_SPAWNING) || HasCinematicFlag(player, CE_FLAG_CLASSIC_MP_SPAWNING))
			continue

		temp.append(player)
	}
	players = temp

	local numPlayers = players.len()

	// make sure enough players are defending near the generator
	if (numPlayers < reqNumPlayers)
		return false

	local titans = GetNPCArrayEx("npc_titan", nonPlayerTeam, Vector(0, 0, 0), -1)
	local numTitans = titans.len()

	if (numTitans < reqNumTitans)
		return false

	local mortarTitans = []
	foreach(titan in titans)
	if (titan.GetSubclass() == eSubClass.mortarTitan)
		mortarTitans.append(titan)

	local numMortarTitans = mortarTitans.len()
	local numNonMortarTitans = numTitans - numMortarTitans

	// too many of the titans are mortar titans
	if ((numNonMortarTitans.tofloat() / numTitans.tofloat()) < reqNonMortarFrac)
		return false

	return true
}

// ----------------------------------
// ----- GENERATOR AI THREAT VO -----
// ----------------------------------
function GeneratorThreat_Register(aiTypeIdx, callbackFunc, soundAlias, debounceTime = 60.0, classname = null, subclass = null) {
	Assert(!(aiTypeIdx in level.generatorThreats), "AItype already set up for generator threats")

	local aiTypeStr = GetCoopAITypeString_ByID(aiTypeIdx)

	local timerName = "Nag_GeneratorThreat_" + aiTypeStr
	TimerInit(timerName, debounceTime)

	local threatInfo = ClassicMP_CreateCallbackTable(callbackFunc)
	threatInfo.aiTypeIdx <- aiTypeIdx
	threatInfo.aiTypeStr <- aiTypeStr
	threatInfo.classname <- classname
	threatInfo.subclass <- subclass
	threatInfo.timer <- timerName
	threatInfo.soundAlias <- soundAlias
	threatInfo.priority <- level.generatorThreats.len() + 1 // assume first one registered = highest priority

	level.generatorThreats[aiTypeIdx] <- threatInfo
}

function Generator_TryAnnounceThreats(generator) {
	FlagEnd("ObjectiveComplete")
	FlagEnd("ObjectiveFailed")

	generator.EndSignal("OnDestroy")

	OnThreadEnd(
		function(): () {
			if (Flag("GeneratorThreatAnnounce_InProgress"))
				FlagClear("GeneratorThreatAnnounce_InProgress")
		}
	)

	if (GetGameState() != eGameState.Playing)
		return

	// if there's not a wave active don't do any thinking
	if (level.nv.TDCurrWave == null)
		return

	if (!TimerCheck("Nag_GeneratorThreat"))
		return

	if (Flag("HighPopulationAnnounce_InProgress"))
		return

	local announceThreatInfo = null
	foreach(aiTypeIdx, threatInfo in level.generatorThreats) {
		if (!TimerCheck(threatInfo.timer))
			continue

		// do we already have a more important threat to talk about?
		// (low # = high priority, #1 is the first priority)
		if (announceThreatInfo && announceThreatInfo.priority < threatInfo.priority)
			continue

		// callback function figures out if we are threatened by this aiType
		if (!threatInfo.func.acall([threatInfo.scope, generator, threatInfo]))
			continue

		announceThreatInfo = threatInfo

		// maybe earlyout if we know no aiType is more important than this one
		if (announceThreatInfo && announceThreatInfo.priority == 1)
			break
	}

	if (announceThreatInfo) {
		// reset global and aitype specific timers
		TimerReset("Nag_GeneratorThreat")
		TimerReset(announceThreatInfo.timer)

		FlagSet("GeneratorThreatAnnounce_InProgress")

		PlayConversationToCoopTeam(announceThreatInfo.soundAlias)

		wait 4.5
		FlagClear("GeneratorThreatAnnounce_InProgress")
	}
}

function AreEnoughNPCsWithinRange(classname, testOrg, maxRange, minThreatsRequired = 1, subclassArray = null) {
	local nonPlayerTeam = GetOtherTeam(level.nv.attackingTeam)

	local npcs = GetNPCArrayWithSubclassEx(classname, nonPlayerTeam, testOrg, maxRange, subclassArray)

	return npcs.len() >= minThreatsRequired
}

function GeneratorThreatCallback_TitanDistanceCheck(generator, threatInfo) {
	local maxDist = GENERATOR_THREAT_WARN_DIST_TITAN
	local numRequired = 1

	return AreEnoughNPCsWithinRange(threatInfo.classname, generator.GetOrigin(), maxDist, numRequired, [threatInfo.subclass])
}

function GeneratorThreatCallback_ArcTitans(generator, threatInfo) {
	local maxDist = ARC_TITAN_EMP_FIELD_RADIUS
	local numRequired = 1

	return AreEnoughNPCsWithinRange(threatInfo.classname, generator.GetOrigin(), maxDist, numRequired, [threatInfo.subclass])
}

function GeneratorThreatCallback_SuicideSpectres(generator, threatInfo) {
	return Generator_CheckDamageStreak(eCoopAIType.suicideSpectre, GENERATOR_THREAT_WARN_STREAKDMG_SUICIDE_SPECTRES)
}

function GeneratorThreatCallback_MortarTitans(generator, threatInfo) {
	return Generator_CheckDamageStreak(eCoopAIType.mortarTitan, GENERATOR_THREAT_WARN_STREAKDMG_MORTAR_TITANS)
}

// this will work for regular spectres as well as grunts
function GeneratorThreatCallback_Infantry(generator, threatInfo) {
	local maxDist = GENERATOR_THREAT_WARN_DIST_INFANTRY
	local numRequired = GENERATOR_THREAT_WARN_NUM_REQ_INFANTRY

	local nonPlayerTeam = GetOtherTeam(level.nv.attackingTeam)
	local testOrg = generator.GetOrigin()

	local infantry = GetNPCArrayEx("npc_soldier", nonPlayerTeam, testOrg, maxDist)
	infantry.extend(GetNPCArrayWithSubclassEx("npc_spectre", nonPlayerTeam, testOrg, maxDist, [eSubClass.NONE]))

	return infantry.len() >= numRequired
}


/************************************************************************************************\

##     ## ####  ######   ######
###   ###  ##  ##    ## ##    ##
#### ####  ##  ##       ##
## ### ##  ##   ######  ##
##     ##  ##        ## ##
##     ##  ##  ##    ## ##    ##
##     ## ####  ######   ######

\************************************************************************************************/
function SetCoopAIPriority(aiTypeID) {
	// highest = 1
	local priority = level.coopAIPriorities.len() + 1

	level.coopAIPriorities[aiTypeID] <- priority
}

function AITypeArray_SortByPriority(waveAITypeIDs) {
	local prioritySorted = []
	local workingList = clone waveAITypeIDs

	while (workingList.len() > 0) {
		local bestPriorityVal = null
		local highestPriorityAITypeID = null
		foreach(id in workingList) {
			Assert(id in level.coopAIPriorities, "No priority set up for coop aiType: " + GetCoopAITypeString_ByID(id))

			if (bestPriorityVal == null || level.coopAIPriorities[id] < bestPriorityVal) {
				bestPriorityVal = level.coopAIPriorities[id]
				highestPriorityAITypeID = id
			}
		}
		Assert(highestPriorityAITypeID != null)

		prioritySorted.append(highestPriorityAITypeID)

		// make a new working list without the one we just grabbed
		local temp = []
		foreach(index, aiTypeID in workingList) {
			// if we didn't use it up, add to the new working list
			if (aiTypeID != highestPriorityAITypeID)
				temp.append(aiTypeID)
		}
		workingList = temp
	}

	Assert(prioritySorted.len() == waveAITypeIDs.len())

	printt("AI IN WAVE BY PRIORITY:")
	foreach(aiTypeID in prioritySorted)
	printt(level.coopAIPriorities[aiTypeID] + ". " + GetCoopAITypeString_ByID(aiTypeID))

	return prioritySorted
}

function KillFXWithEndcap(fxHandle, killDelay = 1.0) {
	if (!IsValid_ThisFrame(fxHandle))
		return

	fxHandle.Fire("StopPlayEndCap")
	wait killDelay

	if (!IsValid_ThisFrame(fxHandle))
		return

	fxHandle.ClearParent()
	fxHandle.Destroy()
}

function CoopTD_PlayerDeathCallback(deadPlayer, damageInfo) {
	if (GetGameState() != eGameState.Playing)
		return

	printt("CoopTD player died!", deadPlayer)

	CoopTD_TryPlayerDeathVO()
}

function CoopTD_TryPlayerDeathVO() {
	if (!TimerCheck("Announce_PlayerDied"))
		return

	printt("Playing player death VO")

	TimerReset("Announce_PlayerDied")

	local players = GetPlayerArray()

	local alivePlayers = []
	local deadPlayers = []
	foreach(player in players) {
		// coming in on the dropship
		//if ( HasCinematicFlag( player, CE_FLAG_WAVE_SPAWNING ) || HasCinematicFlag( player, CE_FLAG_CLASSIC_MP_SPAWNING ) )

		if (IsAlive(player)) {
			alivePlayers.append(player)
		} else {
			deadPlayers.append(player)
		}
	}

	local soundAlias = "CoopTD_PilotDown_Single"
	if (alivePlayers.len() == 1)
		soundAlias = "CoopTD_LastPilotAlive"
	else if (deadPlayers.len() > 1)
		soundAlias = "CoopTD_PilotDown_Multi"

	PlayConversationToAliveCoopPlayers(soundAlias)
}

function CoopTD_OnSoldierOrSpectreSpawn(npc) {
	if (RandomInt(100) < 20)
		SimulateGrenadeThrowing( npc )
}

function CoopTD_EnableSpectreRodeo(spectre) {
	SimulateSpectreRodeo(spectre)
}

/************************************************************************************************\

########  #######   #######  ##        ######
   ##    ##     ## ##     ## ##       ##    ##
   ##    ##     ## ##     ## ##       ##
   ##    ##     ## ##     ## ##        ######
   ##    ##     ## ##     ## ##             ##
   ##    ##     ## ##     ## ##       ##    ##
   ##     #######   #######  ########  ######

\************************************************************************************************/
function TriggerOff(value) {
	local triggers
	if (IsArray(value))
		triggers = value
	else
		triggers = [value]

	foreach(trigger in triggers) {
		local origin = trigger.GetOrigin()
		if (!("originalOrigin" in trigger.s))
			trigger.s.originalOrigin <- origin
		trigger.SetOrigin(Vector(origin.x, origin.y, -16000))
	}
}

function TriggerOn(value) {
	local triggers
	if (IsArray(value))
		triggers = value
	else
		triggers = [value]

	foreach(trigger in triggers) {
		if (!("originalOrigin" in trigger.s))
			continue
		trigger.SetOrigin(trigger.s.originalOrigin)
	}
}

function DevSpectreRodeo() {
	local player = GetPlayerArray()[0]
	local vec = player.GetAngles().AnglesToForward()

	local origin = player.GetOrigin() + (vec * 500)
	local angles = player.GetAngles() + Vector(0, 90, 0)
	local spectre = SpawnSpectre(TEAM_IMC, "SOMEWTF", origin, angles)
	GiveMinionWeapon(spectre, "mp_weapon_r97")

	local vec = angles.AnglesToForward()
	local origin = origin + (vec * 400)
	local yaw = angles.y + 180
	if (yaw > 360)
		yaw -= 360

	local titan = SpawnCoopTitan(origin, Vector(0, yaw, 0), TEAM_MILITIA)

	thread SpectreRodeo(spectre, titan)
}
Globalize(DevSpectreRodeo)


/************************************************************************************************\

##      ##    ###    ##     ## ########        ######  ########     ###    ##      ## ##    ##
##  ##  ##   ## ##   ##     ## ##             ##    ## ##     ##   ## ##   ##  ##  ## ###   ##
##  ##  ##  ##   ##  ##     ## ##             ##       ##     ##  ##   ##  ##  ##  ## ####  ##
##  ##  ## ##     ## ##     ## ######          ######  ########  ##     ## ##  ##  ## ## ## ##
##  ##  ## #########  ##   ##  ##                   ## ##        ######### ##  ##  ## ##  ####
##  ##  ## ##     ##   ## ##   ##             ##    ## ##        ##     ## ##  ##  ## ##   ###
 ###  ###  ##     ##    ###    ########        ######  ##        ##     ##  ###  ###  ##    ##

\************************************************************************************************/

function SetCustomWaveSpawn_SideView(origin = null, angles = null, shipAnim = "dropship_coop_respawn") {
	thread __SetCustomWaveSpawn_SideView(origin, angles, shipAnim)
}
Globalize(SetCustomWaveSpawn_SideView)


function __SetCustomWaveSpawn_SideView(origin, angles, shipAnim) {
	WaitEndFrame() //make sure the generator location has been set, because unless specificed that is the origin and angle of our new spawnpoint
	if (origin != null)
		Assert(angles != null, "if you're going to set an origin for SetCustomWaveSpawn_SideView, then you MUST also set an angles")
	else {
		origin = level.TowerDefenseGenLocation.origin
		angles = level.TowerDefenseGenLocation.angles
	}

	local team = level.nv.attackingTeam
	AddWaveSpawnCustomSpawnPoint(team, origin, angles)

	SetWaveSpawnCustomDropshipAnim(shipAnim)

	local idleAnims = []
	AddRideAnims(idleAnims, 0, "pt_ds_side_intro_gen_idle_B", "ptpov_ds_side_intro_gen_idle_B", null, "ORIGIN", ViewConeSideRightStandFront)
	AddRideAnims(idleAnims, 0, "pt_ds_side_intro_gen_idle_A", "ptpov_ds_side_intro_gen_idle_A", null, "ORIGIN", ViewConeSideRightStandBack)
	AddRideAnims(idleAnims, 0, "pt_ds_side_intro_gen_idle_C", "ptpov_ds_side_intro_gen_idle_C", null, "ORIGIN", ViewConeSideRightSitBack)
	AddRideAnims(idleAnims, 0, "pt_ds_side_intro_gen_idle_D", "ptpov_ds_side_intro_gen_idle_D", null, "ORIGIN", ViewConeSideRightSitFront)
	foreach(anim in idleAnims)
	AddWaveSpawnCustomPlayerRideAnimIdle(anim)

	local jumpAnims = []
	AddRideAnims(jumpAnims, 0, "pt_ds_side_intro_gen_exit_B", "ptpov_ds_side_intro_gen_exit_B", null, "ORIGIN", ViewConeRampFree)
	AddRideAnims(jumpAnims, 0, "pt_ds_side_intro_gen_exit_A", "ptpov_ds_side_intro_gen_exit_A", null, "ORIGIN", ViewConeRampFree)
	AddRideAnims(jumpAnims, 0, "pt_ds_side_intro_gen_exit_C", "ptpov_ds_side_intro_gen_exit_C", null, "ORIGIN", ViewConeRampFree)
	AddRideAnims(jumpAnims, 0, "pt_ds_side_intro_gen_exit_D", "ptpov_ds_side_intro_gen_exit_D", null, "ORIGIN", ViewConeRampFree)
	foreach(anim in jumpAnims)
	AddWaveSpawnCustomPlayerRideAnimJump(anim)
}

// remember - this gets called for every dropship spawn
function CoopTD_WaveSpawnDropship_SpawnCallback(dropship, anim) {
	dropship.NotSolid()
	thread WaveSpawnDropship_AddBish(dropship, anim)

	local duration = dropship.GetSequenceDuration(anim)

	// LEVEL INTRO FLY-IN
	if (GetGameState() == eGameState.Prematch) {
		if (!Flag("GeneratorBeam_On")) {
			// We know that the anim we're using in Prematch is the short "classic" dropship intro
			local beamStartDelay = duration * 0.225 // timed to "pop" beam as players exit the dropships
			thread GeneratorStart_AndThink(beamStartDelay)
		}
	}
	// PLAYER WAVE SPAWN
	else {
		// want the announce to happen when the dropship gets close to dropping guys off
		local announceDelay = duration * 0.8
		thread CoopTD_PlayerReinforcementsAnnounce(announceDelay)
	}
}


function CoopTD_PlayerReinforcementsAnnounce(announceDelay = 0.0) {
	if (Flag("TDGeneratorDestroyed") || Flag("ObjectiveComplete") || Flag("ObjectiveFailed"))
		return

	FlagEnd("TDGeneratorDestroyed")
	FlagEnd("ObjectiveComplete")
	FlagEnd("ObjectiveFailed")

	if (Flag("CoopTD_WaitingToAnnouncePlayerReinforcements"))
		return

	FlagSet("CoopTD_WaitingToAnnouncePlayerReinforcements")

	OnThreadEnd(
		function(): () {
			FlagClear("CoopTD_WaitingToAnnouncePlayerReinforcements")
		}
	)

	if (announceDelay > 0)
		wait announceDelay

	if (!TimerCheck("Announce_PlayerRespawned"))
		return

	local numReinforcements = 0

	// count up players on the dropship(s)
	local playerArray = level.dropshipSpawnPlayerList[level.nv.attackingTeam]
	numReinforcements += playerArray.len()

	// TODO add players spawning as titans to the count
	if (numReinforcements <= 0) {
		printt("WARNING: wanted to do reinforce announce but couldn't:", playerArray.len())
		return
	}

	local alias = "CoopTD_RespawningPlayer"
	if (numReinforcements > 1)
		alias = "CoopTD_RespawningPlayers"

	PlayConversationToCoopTeam(alias)
	TimerReset("Announce_PlayerRespawned")
}
Globalize(CoopTD_PlayerReinforcementsAnnounce)

function Coop_IsHardmode() {
	return true
}

function Play3PHarvesterImpactSounds(generator, damageInfo) {
	local soundAlias = null
	local damageType = damageInfo.GetCustomDamageType()
	local damageSource = damageInfo.GetDamageSourceIdentifier()
	if (damageType & DF_MELEE)
		soundAlias = "HarvesterShield.MeleeImpact_3P_vs_3P"
	else if (damageSource == eDamageSourceId.mp_titanweapon_arc_cannon || damageSource == eDamageSourceId.mp_weapon_defender)
		soundAlias = "HarvesterShield.Energy.BulletImpact_3P_vs_3P"
	else if ((damageSource = eDamageSourceId.mp_titanweapon_xo16 || damageSource = eDamageSourceId.mp_weapon_mega3) && damageType & DF_ELECTRICAL)
		soundAlias = "HarvesterShield.AmpedXO16.BulletImpact_3P_vs_3P"
	else if (damageType & DF_EXPLOSION)
		soundAlias = "HarvesterShield.Explosive.BulletImpact_3P_vs_3P"
	else if (damageType & damageTypes.Bullet || damageType & damageTypes.SmallArms || damageType & DF_SHOTGUN)
		soundAlias = "HarvesterShield.Light.BulletImpact_3P_vs_3P"
	else if (damageType & damageTypes.LargeCaliber || damageType & DF_GIB)
		soundAlias = "HarvesterShield.Heavy.BulletImpact_3P_vs_3P"

	if (soundAlias != null)
		EmitSoundOnEntity(generator, soundAlias)
}