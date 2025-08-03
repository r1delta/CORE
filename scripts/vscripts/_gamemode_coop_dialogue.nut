function main()
{
	Globalize( RegisterCoopConversations )
}

// Will be called from game_state_dialog.nut
function RegisterCoopConversations()
{
	/*
	Priorities high to low:
	VO_PRIORITY_STORY
	VO_PRIORITY_GAMESTATE
	VO_PRIORITY_GAMEMODE
	VO_PRIORITY_PLAYERSTATE
	*/

	RegisterConversation( "CoopTD_GameModeAnnounce", 			VO_PRIORITY_GAMESTATE )
	RegisterConversation( "CoopTD_WonAnnouncement",				VO_PRIORITY_GAMESTATE )  // players won
	RegisterConversation( "CoopTD_LostAnnouncement",			VO_PRIORITY_GAMESTATE )  // players lost

	RegisterConversation( "CoopTD_NoTitansAvailable",			VO_PRIORITY_GAMEMODE )  // no titans available during the match
	RegisterConversation( "CoopTD_FirstWaveStarting",			VO_PRIORITY_GAMEMODE )  // first wave incoming
	RegisterConversation( "CoopTD_MinimapSpawnPingHint",		VO_PRIORITY_GAMEMODE )  // tip to watch minimap for spawn pings
	RegisterConversation( "CoopTD_WaveStarting",				VO_PRIORITY_GAMEMODE )  // another wave incoming
	RegisterConversation( "CoopTD_FinalWaveStarting", 			VO_PRIORITY_GAMEMODE )  // final wave incoming
	RegisterConversation( "CoopTD_WaveComplete",				VO_PRIORITY_GAMEMODE )  // wave survived
	RegisterConversation( "CoopTD_WaveFailed",					VO_PRIORITY_GAMEMODE )  // wave failed- harvester down
	RegisterConversation( "CoopTD_WaveRestarting",				VO_PRIORITY_GAMEMODE )  // sending down another harvester
	RegisterConversation( "CoopTD_TitanReadyNag_Bish", 			VO_PRIORITY_GAMEMODE )  // reminding retrying players that they have a titan ready
	RegisterConversation( "CoopTD_WaveRetriesReminder_2",		VO_PRIORITY_GAMEMODE )  // only 2 chances left
	RegisterConversation( "CoopTD_WaveRetriesReminder_Final",	VO_PRIORITY_GAMEMODE )  // final chance

	RegisterConversation( "CoopTD_WaveCompleteComment_CloseCall",		VO_PRIORITY_GAMEMODE ) 	// players almost lost, but didn't
	RegisterConversation( "CoopTD_WaveCompleteComment_VeryGood",		VO_PRIORITY_GAMEMODE ) 	// Generator took only light health damage
	RegisterConversation( "CoopTD_WaveCompleteComment_Perfect",			VO_PRIORITY_GAMEMODE ) 	// Generator took no health damage at all
	RegisterConversation( "CoopTD_WaveCompleteComment_Rise_TinyWave", 	VO_PRIORITY_GAMEMODE ) 	// special case

	RegisterConversation( "CoopTD_GeneratorShield_Recharging", 			VO_PRIORITY_GAMEMODE )  // generator shields recharging
	RegisterConversation( "CoopTD_GeneratorShield_Recharging_Short", 	VO_PRIORITY_GAMEMODE )  // generator shields recharging (shorter duration)
	RegisterConversation( "CoopTD_GeneratorShield_Full", 				VO_PRIORITY_GAMEMODE )  // generator shields full
	RegisterConversation( "CoopTD_GeneratorShield_Damage_Light", 		VO_PRIORITY_GAMEMODE )  // generator shield taking damage
	RegisterConversation( "CoopTD_GeneratorShield_Damage_Heavy", 		VO_PRIORITY_GAMEMODE )  // generator shield almost depleted
	RegisterConversation( "CoopTD_GeneratorShield_Down", 				VO_PRIORITY_GAMEMODE )  // generator shields down

	RegisterConversation( "CoopTD_GeneratorHealth_75", 				VO_PRIORITY_GAMEMODE )  // generator health at 75%
	RegisterConversation( "CoopTD_GeneratorHealth_50", 				VO_PRIORITY_GAMEMODE )  // generator health at 50%
	RegisterConversation( "CoopTD_GeneratorHealth_50_Nag", 			VO_PRIORITY_GAMEMODE )  // generator health at 50% (nag)
	RegisterConversation( "CoopTD_GeneratorHealth_25", 				VO_PRIORITY_GAMEMODE )  // generator health at 25%
	RegisterConversation( "CoopTD_GeneratorHealth_25_Nag", 			VO_PRIORITY_GAMEMODE )  // generator health at 25% (nag)
	RegisterConversation( "CoopTD_GeneratorHealth_Low", 			VO_PRIORITY_GAMEMODE )  // generator health low

	RegisterConversation( "CoopTD_HoldTheLine", 					VO_PRIORITY_GAMEMODE )  // Hold the line! / Keep pushing team!

	RegisterConversation( "CoopTD_PilotDown_Single", 				VO_PRIORITY_PLAYERSTATE ) 	// single pilot down
	RegisterConversation( "CoopTD_PilotDown_Multi", 				VO_PRIORITY_PLAYERSTATE ) 	// multiple pilots down
	RegisterConversation( "CoopTD_LastPilotAlive", 					VO_PRIORITY_PLAYERSTATE ) 	// last pilot alive
	RegisterConversation( "CoopTD_RespawningPlayer", 				VO_PRIORITY_PLAYERSTATE ) 	// single player is respawning
	RegisterConversation( "CoopTD_RespawningPlayers", 				VO_PRIORITY_PLAYERSTATE ) 	// multiple players are respawning

	RegisterConversation( "CoopTD_TurretAvailable", 				VO_PRIORITY_PLAYERSTATE )	// player turret becomes available
	RegisterConversation( "CoopTD_TurretAvailableNag", 				VO_PRIORITY_PLAYERSTATE ) 	// player turret available nag
	RegisterConversation( "CoopTD_TurretDestroyed", 				VO_PRIORITY_PLAYERSTATE ) 	// player turret destroyed
	RegisterConversation( "CoopTD_TurretDeadAndReady", 				VO_PRIORITY_PLAYERSTATE ) 	// player turret destroyed, and one ready
	RegisterConversation( "CoopTD_TurretKillstreak", 				VO_PRIORITY_PLAYERSTATE ) 	// player turret has lots of kills
	RegisterConversation( "CoopTD_TurretKilledTitan", 				VO_PRIORITY_PLAYERSTATE ) 	// player turret killed a titan
	RegisterConversation( "CoopTD_TurretKilledTitan_Multi", 		VO_PRIORITY_PLAYERSTATE ) 	// player turret killed multiple titans

	RegisterConversation( "CoopTD_ClearStragglersNag_Generic", 		VO_PRIORITY_GAMEMODE )  // clear stragglers
	RegisterConversation( "CoopTD_ClearStragglersNag_NumRem_5", 	VO_PRIORITY_GAMEMODE )
	RegisterConversation( "CoopTD_ClearStragglersNag_NumRem_4", 	VO_PRIORITY_GAMEMODE )
	RegisterConversation( "CoopTD_ClearStragglersNag_NumRem_3", 	VO_PRIORITY_GAMEMODE )
	RegisterConversation( "CoopTD_ClearStragglersNag_NumRem_2", 	VO_PRIORITY_GAMEMODE )
	RegisterConversation( "CoopTD_ClearStragglersNag_NumRem_1", 	VO_PRIORITY_GAMEMODE )

	RegisterConversation( "CoopTD_EnemyAnnounce_Infantry", 			VO_PRIORITY_GAMEMODE )
	RegisterConversation( "CoopTD_EnemyAnnounce_SuicideSpectre", 	VO_PRIORITY_GAMEMODE )
	RegisterConversation( "CoopTD_EnemyAnnounce_CloakDrone", 		VO_PRIORITY_GAMEMODE )
	RegisterConversation( "CoopTD_EnemyAnnounce_Titans", 			VO_PRIORITY_GAMEMODE )
	RegisterConversation( "CoopTD_EnemyAnnounce_MortarTitans", 		VO_PRIORITY_GAMEMODE )
	RegisterConversation( "CoopTD_EnemyAnnounce_NukeTitans", 		VO_PRIORITY_GAMEMODE )
	RegisterConversation( "CoopTD_EnemyAnnounce_ArcTitans", 		VO_PRIORITY_GAMEMODE )

	// wave announce enemy combo lines
	RegisterConversation( "CoopTD_EnemyAnnounce_Infantry_NoTitans", 	VO_PRIORITY_GAMEMODE )
	RegisterConversation( "CoopTD_EnemyAnnounce_Combo_NukeMortar", 		VO_PRIORITY_GAMEMODE )
	RegisterConversation( "CoopTD_EnemyAnnounce_Combo_ArcMortar", 		VO_PRIORITY_GAMEMODE )
	RegisterConversation( "CoopTD_EnemyAnnounce_Combo_ArcNuke", 		VO_PRIORITY_GAMEMODE )
	RegisterConversation( "CoopTD_EnemyAnnounce_Combo_CloakNuke", 		VO_PRIORITY_GAMEMODE )
	RegisterConversation( "CoopTD_EnemyAnnounce_Combo_NukeSuicide", 	VO_PRIORITY_GAMEMODE )
	RegisterConversation( "CoopTD_EnemyAnnounce_Combo_SniperSuicide", 	VO_PRIORITY_GAMEMODE )
	RegisterConversation( "CoopTD_EnemyAnnounce_Combo_MortarSuicide", 	VO_PRIORITY_GAMEMODE )

	// wave announce special case lines
	RegisterConversation( "CoopTD_EnemyAnnounce_KitchenSink", 		VO_PRIORITY_GAMEMODE )
	RegisterConversation( "CoopTD_EnemyAnnounce_NukeTrain", 		VO_PRIORITY_GAMEMODE )
	RegisterConversation( "CoopTD_EnemyAnnounce_Rise_HugeWave", 	VO_PRIORITY_GAMEMODE )

	RegisterConversation( "CoopTD_HighPop_ArcTitans", 				VO_PRIORITY_GAMEMODE )  // aiType high population warning: arc titans
	RegisterConversation( "CoopTD_HighPop_NukeTitans", 				VO_PRIORITY_GAMEMODE )  // aiType high population warning: nuke titans
	RegisterConversation( "CoopTD_HighPop_MortarTitans", 			VO_PRIORITY_GAMEMODE )  // aiType high population warning: mortar titans
	RegisterConversation( "CoopTD_HighPop_SuicideSpectres", 		VO_PRIORITY_GAMEMODE )  // aiType high population warning: suicide spectres

	RegisterConversation( "CoopTD_GeneratorProximity_NukeTitan", 	VO_PRIORITY_GAMEMODE )  // nuke titan close to generator
	RegisterConversation( "CoopTD_GeneratorThreat_SuicideSpectres", VO_PRIORITY_GAMEMODE )  // suicide spectres damaging generator
	RegisterConversation( "CoopTD_GeneratorThreat_MortarTitans", 	VO_PRIORITY_GAMEMODE )  // mortar titans shelling generator
	RegisterConversation( "CoopTD_GeneratorThreat_ArcTitan", 		VO_PRIORITY_GAMEMODE )  // arc titan damaging generator

	RegisterConversation( "CoopTD_GeneratorThreat_Infantry", 		VO_PRIORITY_GAMEMODE )  // lots of infantry near generator damaging it

	RegisterConversation( "CoopTD_SpectreRodeoWarning", 			VO_PRIORITY_GAMESTATE ) // Spectre rodeoing player- HACK the priority is super high so players will hear it
	RegisterConversation( "CoopTD_SpectreRodeoWarning_Short", 		VO_PRIORITY_GAMESTATE ) // Spectre rodeoing player (short duration variant)


	if ( IsServer() )
		return

	/**************************  Tower Defense mode announcements  *****************************/
	/**************************		     Militia only!		       *****************************/

	AddVDULineForBish( "CoopTD_GameModeAnnounce", "diag_gm_coop_modeAnnc_mcor_bish" )

	// no titans available during the match
	AddVDULineForBish( "CoopTD_NoTitansAvailable", "diag_gm_coop_waveNoTitanDrops_mcor_Bish" )

	// first wave incoming
	AddVDULineForBish( "CoopTD_FirstWaveStarting", "diag_gm_coop_firstWaveStartPrefix_mcor_Bish" )

	// tip to watch minimap for spawn pings
	AddVDULineForBish( "CoopTD_MinimapSpawnPingHint", "diag_gm_coop_minimapTip_mcor_Bish" )

	// another wave incoming
	AddVDULineForBish( "CoopTD_WaveStarting", "diag_gm_coop_newWaveStartPrefix_mcor_Bish" )

	// final wave incoming
	AddVDULineForBish( "CoopTD_FinalWaveStarting", "diag_gm_coop_finalWaveStart_mcor_Bish" )

	// wave survived
	AddVDULineForBish( "CoopTD_WaveComplete", "diag_gm_coop_waveVictory_mcor_Bish" )

	// wave survived + players almost lost, but didn't
	AddVDULineForBish( "CoopTD_WaveCompleteComment_CloseCall",	"diag_gm_coop_waveRecapLowHealth_mcor_Bish" )

	// wave survived + Generator took only light health damage
	AddVDULineForBish( "CoopTD_WaveCompleteComment_VeryGood", "diag_gm_coop_waveRecapNearPerfect_mcor_Bish" )

	// wave survived + Generator took no health damage at all
	AddVDULineForBish( "CoopTD_WaveCompleteComment_Perfect", "diag_gm_coop_waveRecapPerfect_mcor_Bish" )

	// special case
	AddVDULineForBish( "CoopTD_WaveCompleteComment_Rise_TinyWave", "diag_gm_coop_tinyWaveInc_mcor_Bish" )

	// wave failed- harvester down
	AddVDULineForBish( "CoopTD_WaveFailed", "diag_gm_coop_baseDeath_mcor_Bish" )

	// sending down another harvester
	AddVDULineForBish( "CoopTD_WaveRestarting", "diag_gm_coop_waveRestart_mcor_Bish" )

	// only 2 chances left
	AddVDULineForBish( "CoopTD_WaveRetriesReminder_2", "diag_gm_coop_waveRedoTwo_mcor_Bish" )

	// final chance
	AddVDULineForBish( "CoopTD_WaveRetriesReminder_Final", "diag_gm_coop_waveRedoFinal_mcor_Bish" )

	// reminding retrying players that they have a titan ready
	AddVDULineForBish( "CoopTD_TitanReadyNag_Bish", "diag_gm_coop_titanReadyNag_mcor_Bish" )


	// players won
	AddVDULineForBish( "CoopTD_WonAnnouncement", "diag_gm_coop_matchVictory2_mcor_Bish" )  // version w/o background cheering- "diag_gm_coop_matchVictory_mcor_Bish"

	// players lost
	AddVDULineForBish( "CoopTD_LostAnnouncement", "diag_gm_coop_matchDefeat_mcor_Bish" )

	// generator shields recharging
	AddVDULineForSarah( "CoopTD_GeneratorShield_Recharging", "diag_gm_coop_baseShieldRecharging_mcor_Sarah" )

	// generator shields recharging (shorter duration)
	AddVDULineForSarah( "CoopTD_GeneratorShield_Recharging_Short", "diag_gm_coop_baseShieldRechargingShort_mcor_Sarah" )

	// generator shields full
	AddVDULineForSarah( "CoopTD_GeneratorShield_Full", "diag_gm_coop_baseShieldUp_mcor_Sarah" )

	// generator shield taking damage
	AddVDULineForSarah( "CoopTD_GeneratorShield_Damage_Light", "diag_gm_coop_baseShieldTakingDmg_mcor_Sarah" )

	// generator shield almost depleted
	AddVDULineForSarah( "CoopTD_GeneratorShield_Damage_Heavy", "diag_gm_coop_baseShieldLow_mcor_Sarah" )

	// generator shields down
	AddVDULineForSarah( "CoopTD_GeneratorShield_Down", "diag_gm_coop_baseShieldDown_mcor_Sarah" )

	// generator health at 75%
	AddVDULineForSarah( "CoopTD_GeneratorHealth_75", "diag_gm_coop_baseHealth75_mcor_Sarah" )

	// generator health at 50%
	AddVDULineForSarah( "CoopTD_GeneratorHealth_50", "diag_gm_coop_baseHealth50_mcor_Sarah" )
	// generator health at 50% (nag)
	AddVDULineForSarah( "CoopTD_GeneratorHealth_50_Nag", "diag_gm_coop_baseHealth50nag_mcor_Sarah" )

	// generator health at 25%
	AddVDULineForSarah( "CoopTD_GeneratorHealth_25", "diag_gm_coop_baseHealth25nag_mcor_Sarah" )
	// generator health at 25% (nag)
	AddVDULineForSarah( "CoopTD_GeneratorHealth_25_Nag", "diag_gm_coop_baseHealth25nag_mcor_Sarah" )

	// generator health low
	AddVDULineForSarah( "CoopTD_GeneratorHealth_Low", "diag_gm_coop_baseLowHealth_mcor_Sarah" )

	// Hold the line!
	AddVDULineForSarah( "CoopTD_HoldTheLine", "diag_gm_coop_baseShieldLowHolding_mcor_Sarah" )

	// single pilot down
	AddVDULineForSarah( "CoopTD_PilotDown_Single", "diag_gm_coop_singlePilotDown_mcor_Sarah" )

	// multiple pilots down
	AddVDULineForSarah( "CoopTD_PilotDown_Multi", "diag_gm_coop_multiPilotDown_mcor_Sarah" )

	// last pilot alive
	AddVDULineForSarah( "CoopTD_LastPilotAlive", "diag_gm_coop_onlyPlayerIsAlive_mcor_Sarah" )

	// single player is respawning
	AddVDULineForSarah( "CoopTD_RespawningPlayer", "diag_gm_coop_pilotRespawnSingle_mcor_Sarah" )

	// multiple players are respawning
	AddVDULineForSarah( "CoopTD_RespawningPlayers", "diag_gm_coop_pilotRespawn_mcor_Sarah" )

	// player turret becomes available
	AddVDULineForSarah( "CoopTD_TurretAvailable", "diag_gm_coop_playerTurretEarned_mcor_Sarah" )

	// player turret available nag
	AddVDULineForSarah( "CoopTD_TurretAvailableNag", "diag_gm_coop_playerTurretNag_mcor_Sarah" )

	// player turret destroyed
	AddVDULineForSarah( "CoopTD_TurretDestroyed", "diag_gm_coop_playerTurretDestro_mcor_Sarah" )

	// player turret destroyed and another one ready
	AddVDULineForSarah( "CoopTD_TurretDeadAndReady", "diag_gm_coop_playerTurretDeadAndReady_mcor_Sarah" )

	// player turret has lots of kills
	AddVDULineForSarah( "CoopTD_TurretKillstreak", "diag_gm_coop_playerTurretHighKills_mcor_Sarah" )

	// player turret killed a titan
	AddVDULineForSarah( "CoopTD_TurretKilledTitan", "diag_gm_coop_playerTurretKilledTitan_mcor_Sarah" )

	// player turret killed multiple titans
	AddVDULineForSarah( "CoopTD_TurretKilledTitan_Multi", "diag_gm_coop_playerTurretKilledTitanAgain_mcor_Sarah" )

	// clear stragglers
	AddVDULineForSarah( "CoopTD_ClearStragglersNag_Generic", "diag_gm_coop_waveCleanup_mcor_Sarah" )
	AddVDULineForSarah( "CoopTD_ClearStragglersNag_NumRem_5", "diag_gm_coop_waveCleanup5_mcor_Sarah" )
	AddVDULineForSarah( "CoopTD_ClearStragglersNag_NumRem_4", "diag_gm_coop_waveCleanup4_mcor_Sarah" )
	AddVDULineForSarah( "CoopTD_ClearStragglersNag_NumRem_3", "diag_gm_coop_waveCleanup3_mcor_Sarah" )
	AddVDULineForSarah( "CoopTD_ClearStragglersNag_NumRem_2", "diag_gm_coop_waveCleanup2_mcor_Sarah" )
	AddVDULineForSarah( "CoopTD_ClearStragglersNag_NumRem_1", "diag_gm_coop_waveCleanup1_mcor_Sarah" )

	// new enemy announcements
	AddVDULineForBish( "CoopTD_EnemyAnnounce_Infantry", 		"diag_gm_coop_waveTypeInfantry_mcor_Bish" )
	AddVDULineForBish( "CoopTD_EnemyAnnounce_SuicideSpectre", 	"diag_gm_coop_waveTypeSuicideSpectre_mcor_Bish" )
	AddVDULineForBish( "CoopTD_EnemyAnnounce_CloakDrone", 		"diag_gm_coop_waveTypeCloakDrone_mcor_Bish" )
	AddVDULineForBish( "CoopTD_EnemyAnnounce_Titans", 			"diag_gm_coop_waveTypeTitanReg_mcor_Bish" )
	AddVDULineForBish( "CoopTD_EnemyAnnounce_MortarTitans", 	"diag_gm_coop_waveTypeTitanMortar_mcor_Bish" )
	AddVDULineForBish( "CoopTD_EnemyAnnounce_NukeTitans", 		"diag_gm_coop_waveTypeTitanNuke_mcor_Bish" )
	AddVDULineForBish( "CoopTD_EnemyAnnounce_ArcTitans", 		"diag_gm_coop_waveTypeTitanArc_mcor_Bish" )

	// wave announce enemy combo lines
	AddVDULineForBish( "CoopTD_EnemyAnnounce_Infantry_NoTitans", 	"diag_gm_coop_waveTypeInfantryNoTitans_mcor_Bish" )
	AddVDULineForBish( "CoopTD_EnemyAnnounce_Combo_NukeMortar", 	"diag_gm_coop_waveComboNukeMortar_mcor_Bish" )
	AddVDULineForBish( "CoopTD_EnemyAnnounce_Combo_ArcMortar", 		"diag_gm_coop_waveComboArcMortar_mcor_Bish" )
	AddVDULineForBish( "CoopTD_EnemyAnnounce_Combo_ArcNuke", 		"diag_gm_coop_waveComboArcNuke_mcor_Bish" )
	AddVDULineForBish( "CoopTD_EnemyAnnounce_Combo_CloakNuke", 		"diag_gm_coop_waveComboCloakNuke_mcor_Bish" )
	AddVDULineForBish( "CoopTD_EnemyAnnounce_Combo_NukeSuicide", 	"diag_gm_coop_waveComboNukeSuicide_mcor_Bish" )
	AddVDULineForBish( "CoopTD_EnemyAnnounce_Combo_SniperSuicide", 	"diag_gm_coop_waveComboSniperSuicide_mcor_Bish" )
	AddVDULineForBish( "CoopTD_EnemyAnnounce_Combo_MortarSuicide", 	"diag_gm_coop_waveComboMortarSuicide_mcor_Bish" )

	// wave announce special case lines
	AddVDULineForBish( "CoopTD_EnemyAnnounce_KitchenSink", 		"diag_gm_coop_waveComboMultiMix_mcor_Bish" )
	AddVDULineForBish( "CoopTD_EnemyAnnounce_NukeTrain", 		"diag_gm_coop_waveComboNukeTrain_mcor_Bish" )
	AddVDULineForBish( "CoopTD_EnemyAnnounce_Rise_HugeWave", 	"diag_gm_coop_bigWaveInc_mcor_Bish" )

	// aiType high population warning: arc titans
	AddVDULineForSarah( "CoopTD_HighPop_ArcTitans", 			"diag_gm_coop_incArcTitanClump_mcor_Sarah" )

	// aiType high population warning: nuke titans
	AddVDULineForSarah( "CoopTD_HighPop_NukeTitans", 			"diag_gm_coop_incTitansNukeClump_mcor_Sarah" )

	// aiType high population warning: mortar titans
	AddVDULineForSarah( "CoopTD_HighPop_MortarTitans", 			"diag_gm_coop_incTitansMortarClump_mcor_Sarah" )

	// aiType high population warning: suicide spectres
	AddVDULineForSarah( "CoopTD_HighPop_SuicideSpectres", 		"diag_gm_coop_incSpectresSuicideClump_mcor_Sarah" )

	// nuke titan close to generator
	AddVDULineForSarah( "CoopTD_GeneratorProximity_NukeTitan", "diag_gm_coop_nukeTitanNearBase_mcor_Sarah" )

	// suicide spectres damaging generator
	AddVDULineForSarah( "CoopTD_GeneratorThreat_SuicideSpectres", "diag_gm_coop_nagSpectresSuicideAtBase_mcor_Sarah" )

	// mortar titans shelling generator
	AddVDULineForSarah( "CoopTD_GeneratorThreat_MortarTitans", "diag_gm_coop_nagKillTitansMortar_mcor_Sarah" )

	// arc titan damaging generator
	AddVDULineForSarah( "CoopTD_GeneratorThreat_ArcTitan", "diag_gm_coop_nagTitanArcAtBase_mcor_Sarah" )

	// lots of infantry near generator damaging it
	AddVDULineForSarah( "CoopTD_GeneratorThreat_Infantry", "diag_gm_coop_nagKillInfantry_mcor_Sarah" )

	// Spectre rodeoing player
	AddVDULineForSarah( "CoopTD_SpectreRodeoWarning", "diag_gm_coop_spectreRodeo_mcor_Sarah" )

	// Spectre rodeoing player (short duration variant)
	AddVDULineForSarah( "CoopTD_SpectreRodeoWarning_Short", "diag_gm_coop_spectreRodeoShort_mcor_Sarah" )
}

main()
