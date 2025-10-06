_GetDeveloperLevel <- GetDeveloperLevel
GetDeveloperLevel <- null // this cannot be done here ever.
Remote.BeginRegisteringFunctions()
_RegisteringFunctions <- true

if ( IsMultiplayer() )
{
	switch ( GetMapName() )
	{
		case "mp_airbase":
			RegisterServerVar( "imcCarrierAlphaFadeStartTime", 0.0 )
			RegisterServerVar( "leviathanFootstepsShake", false )
			RegisterServerVar( "towerMainAttackStarted", -1.0 )
			RegisterServerVar( "towerMainFalling", -1.0 )
			RegisterServerVar( "towerMainDown", -1.0 )
			RegisterServerVar( "towerCharlieFalling", -1.0 )
			RegisterServerVar( "towerCharlieDown", -1.0 )
			RegisterServerVar( "towerAlphaFalling", -1.0 )
			RegisterServerVar( "towerAlphaDown", -1.0 )
			RegisterServerVar( "fightersAttackLevStage", 0 )
			RegisterServerVar( "imcWinShipsTakeOff", -1.0 )
			RegisterServerVar( "leviathanAlphaCrush", false )
			RegisterServerVar( "leviathanCharlieCrush", false )

			RegisterServerVar( "MCORClientTiming", -1 )
			Remote.RegisterFunction( "ServerCallback_FightersKillLeviathan" )
			break
		case "mp_angel_city":
			RegisterServerEntityVar( "megaCarrier" )
			//Remote.RegisterFunction( "ServerCallback_EntityVDUCam" ) //Commented out for now, WIP for VDU cam on megaCarrier
			Remote.RegisterFunction( "ServerCallback_MilitiaFleetAttackMegaCarrier" )
			Remote.RegisterFunction( "ServerCallback_IMCVictoryCarrierMoves" )
			Remote.RegisterFunction( "ServerCallback_IMCIntroHornetExplosion" )
			break
		case "mp_colony":
			RegisterServerVar( "ClientTiming", 0 )
			Remote.RegisterFunction( "ServerCallback_CreateSpectrePaletteLighting" )
			break
		case "mp_fracture":
			RegisterServerEntityVar( "RefuelShip" )
			Remote.RegisterFunction( "ServerCallback_IMCSeesFleetInvade" )
			break
		case "mp_boneyard":
			Remote.RegisterFunction( "ServerCallback_TowerExplosion" )
			Remote.RegisterFunction( "ServerCallback_HardpointPowerBurst" )
			RegisterServerVar( "pulseImminent", false )
			RegisterServerVar( "pulseCount", 0 )
			break
		case "mp_relic":
			RegisterServerVar( "shipSpeakers", false )
			RegisterServerVar( "shipLights", false )
			RegisterServerVar( "shipFx", false )
			break
		case "mp_mia":
			RegisterServerVar( "shipLights", false )
			RegisterServerVar( "shipFx", false )
			RegisterServerEntityVar( "megaCarrier" )
			RegisterServerEntityVar( "redeye" )
			RegisterServerVar( "matchProgressMilestone", 0 )
			RegisterServerEntityVar( "worldRotator" )
			break
		case "mp_o2":
			RegisterServerEntityVar( "megaCarrier" )
			RegisterServerEntityVar( "redeye" )
			RegisterServerVar( "matchProgressMilestone", 0 )
			RegisterServerVar( "introDone", 0 )
			RegisterServerEntityVar( "worldRotator" )
			RegisterServerVar( "IMCClientTiming", 0 )
			Remote.RegisterFunction( "ServerCallback_TonemappingNuke" )
			Remote.RegisterFunction( "ServerCallback_O2CrashBurst" )
			Remote.RegisterFunction( "ServerCallback_ScreenShakeOzone" )
			Remote.RegisterFunction( "CE_O2VisualSettingsTransition" )
			Remote.RegisterFunction( "ServerCallback_NukePlayers" )
			break
		case "mp_outpost_207":
			RegisterServerVar( "warningLightsOn", null )
			RegisterServerVar( "cannonVentingFXOn", null )
			RegisterServerVar( "cannonThermalDrumsSpin", null )
			RegisterServerVar( "cannonMonitorScreenStatus", 0 )
			RegisterServerVar( "capitalShipLightingFacadeAlpha", 1.0 )
			RegisterServerVar( "spaceStationLightingFacadeAlpha", 1.0 )
			RegisterServerVar( "capitalShipThrustersOn", 1.0 )
			Remote.RegisterFunction( "ServerCallback_CannonWarningVO" )
			Remote.RegisterFunction( "ServerCallback_DecoyShipWarpsIn" )
			Remote.RegisterFunction( "ServerCallback_VDU_TechTeamSequence" )
			Remote.RegisterFunction( "ServerCallback_VDU_JumpDriveSequence" )
			Remote.RegisterFunction( "ServerCallback_ResetCannonVDU" )
			Remote.RegisterFunction( "ServerCallback_VDU_WatchCapitalShip" )
			Remote.RegisterFunction( "ServerCallback_VDU_WatchCapitalShip_Escape" )
			Remote.RegisterFunction( "ServerCallback_VDU_GravesLifeboat" )
			Remote.RegisterFunction( "ServerCallback_CapitalShip_FireLifeboats" )
			Remote.RegisterFunction( "ServerCallback_PostEpilogue_IMC_IMCwon_ShipEscapeVO" )
			break
		case "mp_corporate":
			RegisterServerVar( "assemblyLineStops", null )
			RegisterServerVar( "doEnding", null )
			Remote.RegisterFunction( "ServerCallback_gameProgress" )
			break
		case "mp_overlook":
			RegisterServerVar( "emergencyLightsState", 0 )
			break
		case "mp_trainer":
			Remote.RegisterFunction( "ServerCallback_TrainerClientFunctions" )
			break
		case "mp_npe":
			Remote.RegisterFunction( "ServerCallback_SetFreezePlayerControls" )
			Remote.RegisterFunction( "ScriptCallback_NPE_ModuleChanging" )
			Remote.RegisterFunction( "ScriptCallback_DestroyPlayerCockpit" )
			Remote.RegisterFunction( "ScriptCallback_SetupLookTargets" )
			Remote.RegisterFunction( "ScriptCallback_LookTargets_WaitForLookat" )
			Remote.RegisterFunction( "ScriptCallback_LookTargets_KillLights" )
			Remote.RegisterFunction( "ServerCallback_PilotTrainingStart" )
			Remote.RegisterFunction( "ServerCallback_TrainingTeleport" )
			Remote.RegisterFunction( "ServerCallback_CleanupCorpses" )
			Remote.RegisterFunction( "ServerCallback_ShowIntroScreen" )
			Remote.RegisterFunction( "ServerCallback_DisplayTrainingPrompt" )
			Remote.RegisterFunction( "ServerCallback_HideTrainingPrompt" )
			Remote.RegisterFunction( "ServerCallback_EnableTitanModeHUD" )
			Remote.RegisterFunction( "ServerCallback_EnableTitanDisembark" )
			Remote.RegisterFunction( "ServerCallback_DisableTitanDisembark" )
			Remote.RegisterFunction( "ServerCallback_EnableTitanModeChange" )
			Remote.RegisterFunction( "ServerCallback_EnableTitanModeChange_Once" )
			Remote.RegisterFunction( "ServerCallback_DisableTitanModeChange" )
			Remote.RegisterFunction( "ScriptCallback_NPE_TrackPlayerDashMeter" )
			Remote.RegisterFunction( "ScriptCallback_NPE_TrackPlayerDashMeter_Stop" )
			Remote.RegisterFunction( "ServerCallback_ResetHoloscreen" )
			Remote.RegisterFunction( "ServerCallback_FadeHoloscreen" )
			Remote.RegisterFunction( "ServerCallback_Turbulence" )
			Remote.RegisterFunction( "ServerCallback_EnableFog" )
			Remote.RegisterFunction( "ServerCallback_DisableFog" )
			Remote.RegisterFunction( "ServerCallback_SetMeleePromptEnabled" )
			Remote.RegisterFunction( "ServerCallback_SetTrainingResumeChoice" )
			Remote.RegisterFunction( "ServerCallback_SetPlayerHasFinishedTraining" )
			Remote.RegisterFunction( "ControllerImageHint_Sprint" )
			Remote.RegisterFunction( "ControllerImageHint_Melee" )
			Remote.RegisterFunction( "ControllerImageHint_Bumper" )
			Remote.RegisterFunction( "ControllerImageHint_DPad" )
			Remote.RegisterFunction( "ControllerImageHint_OffhandDefensive" )
			Remote.RegisterFunction( "ControllerImageHint_OffhandOffensive" )
			Remote.RegisterFunction( "StopControllerImageHint" )
			Remote.RegisterFunction( "HUDHintPulse" )
			Remote.RegisterFunction( "StopHintPulse" )
			Remote.RegisterFunction( "HighlightMinimap" )
			Remote.RegisterFunction( "StopHighlightMinimap" )
			break
		case "mp_swampland":
			RegisterServerVar( "pulseImminent", false )
			break
		case "mp_switchback":
			RegisterServerVar( "aoeTrapStartTime", -1.0 )
			break
		case "mp_harmony_mines":
			RegisterServerVar( "grinderOnTime", -1.0 )
			RegisterServerVar( "grinderOffTime", -1.0 )
			RegisterServerVar( "diggerWiresState", 0 )
			RegisterServerVar( "diggerScreenShake", false )
			RegisterServerVar( "diggerGeneratorsOn", 0 )
			RegisterServerVar( "diggerFXState", 0 )
			RegisterServerVar( "diggerStartTime", -1.0 )
			RegisterServerVar( "diggerStopTime", -1.0 )
			break
		case "mp_haven":
			RegisterServerVar( "megaCarrierSpawnTime", null )
			break

		case "mp_box":
			break

	}

	Remote.RegisterFunction( "ServerCallback_FPS_Test" )// This is for local FPS tests using myscripts for standardized optimization
	Remote.RegisterFunction( "ServerCallback_FPS_Avg" )// general callback for more people to use - soupy
	Remote.RegisterFunction( "DebugSetFrontline" )
	Remote.RegisterFunction( "ServerCallback_StartCinematicNodeEditor" )
	Remote.RegisterFunction( "ServerCallback_AISkitDebugMessage" )	//chad - temp to do debug lines on my client only during real MP matches
	Remote.RegisterFunction( "ServerCallback_UpdateClientChallengeProgress" )
	Remote.RegisterFunction( "ServerCallback_EventNotification" )

	Remote.RegisterFunction( "SCB_RefreshBurnCardSelector" )
	Remote.RegisterFunction( "ServerCallback_EjectConfirmed" )

	RegisterEntityVar( "player", "buildTimeOnSpawn", 0 )
	Remote.RegisterFunction( "SCB_SetUserPerformance" )
	Remote.RegisterFunction( "SCB_UpdateSponsorables" )
	Remote.RegisterFunction( "SCB_ClientDebug" )

	if ( GAMETYPE == COOPERATIVE )
	{
		RegisterServerVar( "missionTypeID", null )
		RegisterServerVar( "objCount", null )
		RegisterServerVar( "objMax", null )
		RegisterServerVar( "objStartTime", 0 )
		RegisterServerVar( "objEndTime", 0 )
		RegisterServerVar( "TDGeneratorHealth", null )
		RegisterServerVar( "TDGeneratorShieldHealth", null )
		RegisterServerVar( "TDNumWaves", 10 )
		RegisterServerVar( "TDMaxTeamScore", 10000 )
		RegisterServerVar( "TDCurrentTeamScore", 0 )
		RegisterServerVar( "TDStoredTeamScore", 0 )
		RegisterServerVar( "TDCurrWave", null )
		RegisterServerVar( "TDCurrWaveNameID", null )
		RegisterServerVar( "TDWaveStartTime", -9999 )
		RegisterServerVar( "TDWaveTimer", 30 )
		RegisterServerVar( "TDScoreboardDisplayWaveInfo", false )

		//wave enemy types ( for icons )
		RegisterServerVar( "TD_numTitans", -1 )
		RegisterServerVar( "TD_numNukeTitans", -1 )
		RegisterServerVar( "TD_numMortarTitans", -1 )
		RegisterServerVar( "TD_numEMPTitans", -1 )
		RegisterServerVar( "TD_numGrunts", -1 )
		RegisterServerVar( "TD_numSpectres", -1 )
		RegisterServerVar( "TD_numSuicides", -1 )
		RegisterServerVar( "TD_numSnipers", -1 )
		RegisterServerVar( "TD_numCloakedDrone", -1 )
		RegisterServerVar( "TD_numTotal", 0 )
		RegisterServerVar( "coopRestartsAllowed", 0 )
		RegisterServerVar( "coopPlayersRodeoing", 0 )	// bitwise 0x01, 0x02, 0x04, 0x08


		Remote.RegisterFunction( "ServerCallback_TD_WaveAnnounce" )
		Remote.RegisterFunction( "ServerCallback_TD_WaveFinished" )
		Remote.RegisterFunction( "ServerCallback_NewEnemyAnnounceCards" )
		Remote.RegisterFunction( "ServerCallback_GiveSentryTurret" )
		Remote.RegisterFunction( "ServerCallback_TurretWorldIconShow" )
		Remote.RegisterFunction( "ServerCallback_TurretWorldIconHide" )
		Remote.RegisterFunction( "ServerCallback_DisplayCoopNotification" )
		Remote.RegisterFunction( "ServerCallback_DisplayEOGStars" )
		Remote.RegisterFunction( "ServerCallback_HarvesterDebrief" )
		Remote.RegisterFunction( "ServerCallback_SetHarvesterTimeDataPoints" )
		Remote.RegisterFunction( "ServerCallback_SetHarvesterWaveDataPoints" )
		Remote.RegisterFunction( "ServerCallback_CoopMusicPlay" )
	}

	Remote.RegisterFunction( "ServerCallback_UpdateMarker" )

	// SHOULD PROBABLY BE CODE
	RegisterServerVar( "gameStateChangeTime", null )
	RegisterServerVar( "gameState", null )
	RegisterServerVar( "gameStartTime", null )
	RegisterServerVar( "coopStartTime", null )
	RegisterServerVar( "gameEndTime", null )
	RegisterServerVar( "switchedSides", null )
	RegisterServerVar( "replayDisabled", false )

	if ( GAMETYPE == BIG_BROTHER )
	{
		// [LJS] bigbrother ??�� ?�치 ?�는지 ?�했?��? Check
		RegisterServerVar( "BigbrotherPanelHacked", false )

		// ?�킹???�널 ?�덱??
		RegisterServerVar( "HackedBigbrotherPanelIndex", 0 )

		// ??�� 진행 ?�료 ?�래�?
		RegisterServerVar( "BigBrotherPanelExplosion", false )

		RegisterServerVar( "BigBrotherHackInProgress", false )
		RegisterServerVar("bbHackStartTime",0.0)
	}


	//Round Winning Kill replay related
	RegisterServerVar( "roundWinningKillReplayEnabled", false )
	RegisterServerVar( "roundWinningKillReplayVictimEHandle", null )
	RegisterServerVar( "roundScoreLimitComplete", false )

	RegisterServerVar( "badRepPresent", false )

	RegisterServerVar( "roundBased", false )
	RegisterServerVar( "roundStartTime", null )
	RegisterServerVar( "roundEndTime", null )
	RegisterServerVar( "roundsPlayed", 0 )

	RegisterServerVar( "ffaBased", false )

	RegisterServerVar( "minPickLoadOutTime", null )
	RegisterServerVar( "connectionTimeout", 0 )
	RegisterServerVar( "winningTeam", null )
	RegisterServerVar( "titanDropEnabledForTeam", TEAM_BOTH )
	RegisterServerVar( "matchProgress", 0 )

	// Uplink
	RegisterServerVar( "activeUplinkID", null )
	RegisterServerVar( "activeUplinkTime", null )
	// Seconds
	RegisterServerVar( "secondsTitanCheckTime", null )

	// Exfil
	RegisterServerVar( "exfilState", null )
	RegisterServerVar( "attackingTeam", null )
	RegisterServerVar( "cttTitanSoul", null )
	RegisterServerVar( "cttPlayerCaptureEndTime", 0 )


	// Riffs
	RegisterServerVar( "spawnAsTitan", null )
	RegisterServerVar( "titanAvailability", null )
	RegisterServerVar( "allowNPCs", null )
	RegisterServerVar( "aiLethality", null )
	RegisterServerVar( "minimapState", null )
	RegisterServerVar( "ospState", null )
	RegisterServerVar( "ammoLimit", null )
	RegisterServerVar( "eliminationMode", null )
	RegisterServerVar( "floorIsLava", null )
	RegisterServerVar( "titanExitEnabled", null )

	// MFD
	RegisterServerVar( "mfdOverheadPingDelay", 0 )


	if ( !IsLobby() )
	{
		RegisterServerVar( "eliminatedPlayers", 0 )
	}

	Remote.RegisterFunction( "ServerCallback_YouDied" )
	Remote.RegisterFunction( "ServerCallback_YouRespawned" )

	Remote.RegisterFunction( "ServerCallback_AnnounceWinner" )
	Remote.RegisterFunction( "ServerCallback_AnnounceRoundWinner" )

	Remote.RegisterFunction( "ServerCallback_ToggleRankedInGame" )
	Remote.RegisterFunction( "ServerCallback_SetShoulderTurretTarget" )
	Remote.RegisterFunction( "ServerCallback_AddCinematicEventClientFunc" ) // an extra script layer on remote calls
	Remote.RegisterFunction( "ServerCallback_CinematicFuncInitComplete" )   // an extra script layer on remote calls
	Remote.RegisterFunction( "ServerCallback_ResetRefSkyScale" )   			// an extra script layer on remote calls
	Remote.RegisterFunction( "ServerCallback_GuidedMissileDestroyed" )
	Remote.RegisterFunction( "ServerCallback_PlayerCinematicDone" )
	Remote.RegisterFunction( "ServerCallback_DoClientSideCinematicMPMoment" ) // hard to say if this is safe as fire and forget
	Remote.RegisterFunction( "ServerCallback_SetAssistInformation" )
	Remote.RegisterFunction( "ServerCallback_PilotEMP" )
	Remote.RegisterFunction( "ServerCallback_TitanEMP" )
	Remote.RegisterFunction( "ServerCallback_AirburstIconUpdate" )
	Remote.RegisterFunction( "ServerCallback_TitanCockpitBoot" ) // all this does is reset the tone mapping
	Remote.RegisterFunction( "ServerCallback_DataKnifeReset" )
	Remote.RegisterFunction( "ServerCallback_DataKnifeStartLeech" )
	Remote.RegisterFunction( "ServerCallback_DataKnifeStartLeechTimePassed" )
	Remote.RegisterFunction( "ServerCallback_DataKnifeCancelLeech" )
	Remote.RegisterFunction( "ServerCallback_ControlPanelRefresh" )
	Remote.RegisterFunction( "ServerCallback_TurretRefresh" )
	Remote.RegisterFunction( "ServerCallback_CreateEvacShipIcon" )
	Remote.RegisterFunction( "ServerCallback_DestroyEvacShipIcon" )
	Remote.RegisterFunction( "ServerCallback_RedeyeHideEffects" )
	Remote.RegisterFunction( "ServerCallback_AddCapturePoint" )
	Remote.RegisterFunction( "ServerCallback_TitanDisembark" ) // plays a line of dialog and calls "cockpit.StartDisembark()", and does tonemapping update, hides crosshair and names
	Remote.RegisterFunction( "ServerCallback_OnEntityKilled" ) // handles obit and death recap
	Remote.RegisterFunction( "ServerCallback_OnTitanDoomed" ) // handles obit for doomed titans
	Remote.RegisterFunction( "ServerCallback_PlayerConnectedOrDisconnected" )
	Remote.RegisterFunction( "SCBUI_PlayerConnectedOrDisconnected" )
	Remote.RegisterFunction( "ServerCallback_PlayerChangedTeams" )
	Remote.RegisterFunction( "ServerCallback_GameStateEnter_Postmatch" )

	// IMPORTANT BUT MAYBE FINE AS A REMOTE CALL
	Remote.RegisterFunction( "ServerCallback_ReplacementTitanSpawnpoint" )
	Remote.RegisterFunction( "ServerCallback_TitanTookDamage" ) // should be converted into a code callback... similar to NotifyDidDamage
	Remote.RegisterFunction( "ServerCallback_PilotTookDamage" ) // should be converted into a code callback... similar to NotifyDidDamage
	Remote.RegisterFunction( "ServerCallback_PlayerUsesBurnCard" ) // tell a player that somebody used a burn card he should know about
	Remote.RegisterFunction( "ServerCallback_ScreenShake" )
	Remote.RegisterFunction( "ServerCallback_MinimapPulse" ) // if burn card moves to weapon then we dont need this
	Remote.RegisterFunction( "ServerCallback_UpdateOverheadIconForNPC" )
	Remote.RegisterFunction( "ServerCallback_SetFlagHomeOrigin" )
	Remote.RegisterFunction( "ServerCallback_UpdateOnDeckIndex" )
	Remote.RegisterFunction( "ServerCallback_OpenBurnCardMenu" )
	Remote.RegisterFunction( "ServerCallback_ExitBurnCardMenu" )



	// LESS ESSENTIAL, CAN SHIP AS REMOTE FUNCTIONS
	Remote.RegisterFunction( "ServerCallback_PlayScreenFXWarpJump" )
	Remote.RegisterFunction( "ServerCallback_Phantom_Scan" )
	Remote.RegisterFunction( "ServerCallback_RodeoScreenShake" )
	Remote.RegisterFunction( "ServerCallback_RodeoerEjectWarning" ) // play pre-eject fx on titan
	Remote.RegisterFunction( "ServerCallback_TitanEmbark" ) // used purely to play a single line of dialog
	Remote.RegisterFunction( "ServerCallback_DogFight" )
	Remote.RegisterFunction( "ServerCallback_Announcement" )
	Remote.RegisterFunction( "ServerCallback_GameModeAnnouncement" )
	Remote.RegisterFunction( "ServerCallback_PointSplash" )
	Remote.RegisterFunction( "ServerCallback_PointSplashMultiplied" )
	Remote.RegisterFunction( "ServerCallback_PlayConversation" )
	Remote.RegisterFunction( "ServerCallback_CancelScene" )
	Remote.RegisterFunction( "ServerCallback_PlaySquadConversation" )
	Remote.RegisterFunction( "ServerCallback_CreateDropShipIntLighting" )
	Remote.RegisterFunction( "ServerCallback_DropShipCloudCoverEffect" )
	Remote.RegisterFunction( "ServerCallback_EvacObit" )
	Remote.RegisterFunction( "ServerCallback_UpdateBurnCardTitle" )
	Remote.RegisterFunction( "ServerCallback_UpdateTitanModeHUD" )
	Remote.RegisterFunction( "ServerCallback_GiveMatchLossProtection" )


	Remote.RegisterFunction( "ServerCallback_TitanFallWarning" )
	Remote.RegisterFunction( "SCB_TitanDialogue" )
	Remote.RegisterFunction( "ServerCallback_TitanDialogueBurnCardVO" )

	Remote.RegisterFunction( "ServerCallback_PlayLobbyScene" )

	Remote.RegisterFunction( "ServerCallback_UserCountsUpdated" )
	Remote.RegisterFunction( "ServerCallback_PlaylistUserCountsUpdated" )

	Remote.RegisterFunction( "ServerCallback_SpiderSense" )
	Remote.RegisterFunction( "ServerCallback_UpdateDashCount" )

	// DEV ONLY
	Remote.RegisterFunction( "ServerCallback_MVUpdateModelBounds" )
	Remote.RegisterFunction( "ServerCallback_MVEnable" )
	Remote.RegisterFunction( "ServerCallback_MVDisable" )

	// SHOULD BE REMOVED
	Remote.RegisterFunction( "ServerCallback_FractureLaptopFx" ) // should be replaced with server side particle //Mo-> server side would mean 2 dlights instead of just 1 ( bad )
	Remote.RegisterFunction( "ServerCallback_SetClassicSkyScale" )
	Remote.RegisterFunction( "ServerCallback_ResetClassicSkyScale" )
}


// SHOULD PROBABLY BE CODE
Remote.RegisterFunction( "ServerCallback_ClientInitComplete" )

RegisterServerVar( "forcedDialogueOnly", false )

// SHOULD GO AWAY
Remote.RegisterFunction( "ServerCallback_SetEntityVar" )
Remote.RegisterFunction( "ServerCallback_SetServerVar" )


// POSSIBLY CAN STAY AS REMOTE FUNCTIONS
Remote.RegisterFunction( "ServerCallback_PlayTeamMusicEvent" )
Remote.RegisterFunction( "ServerCallback_TitanCockpitEMP" )
Remote.RegisterFunction( "ServerCallback_PlayerEarnedBurnCard" )
Remote.RegisterFunction( "ServerCallback_PlayerStoppedBurnCard" )

// UI FUNCTIONS
Remote.RegisterFunction( "ServerCallback_SetUIVar" )
Remote.RegisterFunction( "ServerCallback_ShowInvertLookMenu" )
Remote.RegisterFunction( "ServerCallback_LoadoutsUpdated" )
Remote.RegisterFunction( "ServerCallback_DoTraining" )
Remote.RegisterFunction( "ServerCallback_EndTraining" )
Remote.RegisterFunction( "ServerCallback_ShopPurchaseStatus" )
Remote.RegisterFunction( "ServerCallback_OpenPilotLoadoutMenu" )
Remote.RegisterFunction( "ServerCallback_DevOpenTitanLoadoutMenu" )

if ( IsLobby() )
{
	Remote.RegisterFunction( "SCB_UpdateRankedPlayMenu" )
	Remote.RegisterFunction( "SCB_UpdateBC" )
	Remote.RegisterFunction( "SCB_RefreshBlackMarket" )
	Remote.RegisterFunction( "ServerCallback_ShopOpenBurnCardPack" )
	Remote.RegisterFunction( "ServerCallback_ShopOpenGenericItem" )
	Remote.RegisterFunction( "SCB_RefreshCards" )
	Remote.RegisterFunction( "SCB_RefreshLobby" )
	Remote.RegisterFunction( "SCB_UpdateEmptySlots" )
	Remote.RegisterFunction( "SCB_UpdateBCFooter" )
}

if ( !IsModelViewer() )
{
	switch ( GameRules.GetGameMode() )
	{
		case MARKED_FOR_DEATH:
		case MARKED_FOR_DEATH_PRO:
		case TITAN_MFD:
		case TITAN_MFD_PRO:
			Remote.RegisterFunction( "SCB_MarkedChanged" )
			break

		case SCAVENGER:
			Remote.RegisterFunction( "SCB_DeliveredOre" )
			Remote.RegisterFunction( "SCB_CantPickupMegaOre" )
			break

		case BIG_BROTHER:
		case HEIST:
			Remote.RegisterFunction( "SCB_BBUpdate" )
			Remote.RegisterFunction( "SCB_BBVdu" )
			break
	}
}

RegisterString( "#GAMEMODE_NO_TITANS_REMAINING" )
RegisterString( "#GAMEMODE_ENEMY_TITANS_DESTROYED" )
RegisterString( "#GAMEMODE_FRIENDLY_TITANS_DESTROYED" )
RegisterString( "#GAMEMODE_ENEMY_PILOTS_ELIMINATED" )
RegisterString( "#GAMEMODE_FRIENDLY_PILOTS_ELIMINATED" )
RegisterString( "#GAMEMODE_TIME_LIMIT_REACHED" )
RegisterString( "#GAMEMODE_SCORE_LIMIT_REACHED" )
RegisterString( "#GAMEMODE_PREPARE_FOR_EVAC" )
RegisterString( "#GAMEMODE_AWAIT_INSTRUCTIONS" )
RegisterString( "#GAMEMODE_TITAN_TIME_ADVANTAGE" )
RegisterString( "#GAMEMODE_TITAN_TIME_DISADVANTAGE" )
RegisterString( "#GAMEMODE_TITAN_DAMAGE_ADVANTAGE" )
RegisterString( "#GAMEMODE_TITAN_DAMAGE_DISADVANTAGE" )
RegisterString( "#GAMEMODE_TITAN_TITAN_ADVANTAGE" )
RegisterString( "#GAMEMODE_TITAN_TITAN_DISADVANTAGE" )
RegisterString( "#GAMEMODE_DEFENDERS_WIN" )
RegisterString( "#GAMEMODE_ATTACKERS_WIN" )
RegisterString( "#GAMEMODE_MARKED_FOR_DEATH_PRO_WIN_ANNOUNCEMENT" )
RegisterString( "#GAMEMODE_MARKED_FOR_DEATH_PRO_LOSS_ANNOUNCEMENT" )
RegisterString( "#GAMEMODE_MARKED_FOR_DEATH_PRO_DISCONNECT_WIN_ANNOUNCEMENT" )
RegisterString( "#GAMEMODE_MARKED_FOR_DEATH_PRO_DISCONNECT_LOSS_ANNOUNCEMENT" )
RegisterString( "#BIG_BROTHER_PANEL_HACKED" )
RegisterString( "#CAPTURE_THE_FLAG_FLAG_ESCAPED" )
RegisterString( "#CAPTURE_THE_FLAG_FLAG_CAPTURE_STOPPED" )
RegisterString( "#CAPTURE_THE_FLAG_PRO_ESCAPE_TO_SHIP" )
RegisterString( "#CAPTURE_THE_FLAG_PRO_ESCORT_STOP_FLAG")
RegisterString( "#CAPTURE_THE_FLAG_PRO_FLAG_TAKEN" )

RegisterString( "#GAMESTATE_SWITCHING_SIDES" )

RegisterString( "#GAMEMODE_HOST_ENDED_MATCH" )

RegisterString( "#HEIST_TEAM_HACKED_PANEL" )
RegisterString( "#HEIST_DATA_STOLEN" )

Remote.EndRegisteringFunctions()
GetDeveloperLevel <- _GetDeveloperLevel
delete _GetDeveloperLevel
_RegisteringFunctions <- false
