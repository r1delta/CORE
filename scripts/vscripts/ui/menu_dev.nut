
function OnOpenDevMenu()
{
	if ( developer() == 0 )
		return

	local activeLevel = GetActiveLevel()
	Assert( activeLevel )

	devCommands <- []
	SetupDevCommand( devCommands, "Disable NPCs", "script disable_npcs()" )
	SetupDevCommand( devCommands, "Swap the teams", "script teamswap()" )
	SetupDevCommand( devCommands, "Force time limit", "script ForceTimeLimitDone()" )
	SetupDevCommand( devCommands, "Force IMC win", "script ForceIMCWin()" )
	SetupDevCommand( devCommands, "Force Militia win", "script ForceMilitiaWin()" )
	SetupDevCommand( devCommands, "Force Match End", "script ForceMatchEnd()" )
	SetupDevCommand( devCommands, "Force Draw", "script ForceDraw()" )
	SetupDevCommand( devCommands, "Free Titans for everybody", "script GiveAllTitans()" )
	SetupDevCommand( devCommands, "[COOP] Kill All Enemies", "script Coop_KillAllEnemies_MenuCall()" )
	SetupDevCommand( devCommands, "[COOP] Kill Generator", "script Coop_KillGenerator_MenuCall()" )
	SetupDevCommand( devCommands, "[COOP] Generator God Mode Toggle", "script Coop_SetGeneratorGodMode_MenuCall()" )
	SetupDevCommand( devCommands, "[COOP] Toggle Draw Routes", "script thread DebugDrawRoutes()" )
	SetupDevCommand( devCommands, "[COOP] Toggle Draw Stationary positions", "script thread DebugDrawStationaryPositions()" )
	SetupDevCommand( devCommands, "Toggle titan enemy tracking", "script_client FlagToggle( \"titan_enemy_tracker_enabled\" )" )
	//SetupDevCommand( devCommands, "PlaySpyglassVDU", "script ForcePlayConversationToAll(\"SpyglassVDU\")" )
	//SetupDevCommand( devCommands, "PlayGravesVDU", "script ForcePlayConversationToAll(\"GravesVDU\")" )
	//SetupDevCommand( devCommands, "PlayBliskVDU", "script ForcePlayConversationToAll(\"BliskVDU\")" )
	SetupDevCommand( devCommands, "PlaySarahVDU", "script ForcePlayConversationToAll(\"SarahVDU\")" )
	//SetupDevCommand( devCommands, "PlayMacVDU", "script ForcePlayConversationToAll(\"MacVDU\")" )
	//SetupDevCommand( devCommands, "PlayBishVDU", "script ForcePlayConversationToAll(\"BishVDU\")" )
	//SetupDevCommand( devCommands, "PlayMCORGruntBattleRifleVDU", "script ForcePlayConversationToAll(\"MCORGruntBattleRifleVDU\")" )
	//SetupDevCommand( devCommands, "PlayMCORGruntAntiTitanVDU", "script ForcePlayConversationToAll(\"MCORGruntAntiTitanVDU\")" )
	//SetupDevCommand( devCommands, "PlayIMCSoldierBattleRifleVDU", "script ForcePlayConversationToAll(\"IMCSoldierBattleRifleVDU\")" )
	SetupDevCommand( devCommands, "Doom my titan", "script_client GetLocalViewPlayer().ClientCommand( \"DoomTitan\" )" )
	SetupDevCommand( devCommands, "Summon Players to player 0", "script summonplayers()" )
	SetupDevCommand( devCommands, "ToggleTitanCallInEffects", "script FlagToggle( \"EnableIncomingTitanDropEffects\" )" )
	SetupDevCommand( devCommands, "TrailerTitanDrop", "script_client GetLocalViewPlayer().ClientCommand( \"TrailerTitanDrop\" )" )
	//SetupDevCommand( devCommands, "AI Chatter: aichat_callout_pilot_dev", "script playconvtest(\"aichat_callout_pilot_dev\")" )
	//SetupDevCommand( devCommands, "AI Chatter: grunt_flees_titan_dev", "script playconvtest(\"grunt_flees_titan_dev\")" )
	SetupDevCommand( devCommands, "Spawn IMC grunt", "SpawnViewGrunt " + TEAM_IMC )
	SetupDevCommand( devCommands, "Spawn Militia grunt", "SpawnViewGrunt " + TEAM_MILITIA )
	SetupDevCommand( devCommands, "Enable titan-always-executes-titan", "script FlagSet( \"ForceSyncedMelee\" )" )
	SetupDevCommand( devCommands, "Fix 3rd person embark pop", "script FlagToggle( \"Embark3rdPersonFix\" )" )
	//SetupDevCommand( devCommands, "Toggle GPMM style melee", "script ToggleGPMMMelee()" )
	SetupDevCommand( devCommands, "Display Titanfall spots", "script thread ShowAllTitanFallSpots()" )
	SetupDevCommand( devCommands, "Toggle check inside Titanfall Blocker", "script thread DevCheckInTitanfallBlocker()" )
	//SetupDevCommand( devCommands, "Display Embark times", "script DebugEmbarkTimes()" )
	SetupDevCommand( devCommands, "Kill All Titans", "script killtitans()" )
	SetupDevCommand( devCommands, "Kill All Minions", "script killminions()" )
	SetupDevCommand( devCommands, "Simulate Game Scoring", "script thread SimulateGameScore()" )
	SetupDevCommand( devCommands, "Test Classic MP spawns", "script thread DebugTestDropshipStartSpawns()" )
	SetupDevCommand( devCommands, "Toggle Skybox View", "script thread ToggleSkyboxView()" )
	//SetupDevCommand( devCommands, "Reset New Player Experience", "script thread ResetNewPlayerExperience();script_client thread ResetNewPlayerExperience()" )
	SetupDevCommand( devCommands, "Unlock Burn Cards Set 1", "script allcards(0)" )
	SetupDevCommand( devCommands, "Unlock Burn Cards Set 2", "script allcards(1)" )
	SetupDevCommand( devCommands, "Toggle Bubble Shield", "ToggleBubbleShield" )
	SetupDevCommand( devCommands, "Toggle Grenade Indicators", "script_client ToggleGrenadeIndicators()" )
	SetupDevCommand( devCommands, "Toggle HUD", "ToggleHUD" )
	SetupDevCommand( devCommands, "Toggle Offhand Low Recharge", "ToggleOffhandLowRecharge" )
	SetupDevCommand( devCommands, "Lots of Coins", "script DebugMaxCoins()" )
	SetupDevCommand( devCommands, "Clear Coins", "script DebugClearCoins()" )
	SetupDevCommand( devCommands, "Max Activity (Pilots)", "script SetMaxActivityMode(1)" )
	SetupDevCommand( devCommands, "Max Activity (Titans)", "script SetMaxActivityMode(2)" )
	SetupDevCommand( devCommands, "Max Activity (Pilots+Titans)", "script SetMaxActivityMode(3)" )
	SetupDevCommand( devCommands, "Max Activity (Conger Mode)", "script SetMaxActivityMode(4)" )
	SetupDevCommand( devCommands, "Max Activity (Disabled)", "script SetMaxActivityMode(0)" )
	SetupDevCommand( devCommands, "Map Metrics Toggle", "script_client GetLocalClientPlayer().ClientCommand( \"toggle map_metrics 0 1 2 3\" )" )
	SetupDevCommand( devCommands, "Toggle Model Viewer", "script thread ToggleModelViewer();script disable_npcs();script_client TitanModeHUD_Disable( GetLocalViewPlayer() )" )

	devLevelCommands <- []

	switch ( activeLevel )
	{
		case "mp_titan_rodeo":
			SetupDevCommand( devLevelCommands, "Atlas titans", "script thread TitanTypes( \"titan_atlas\")" )
			SetupDevCommand( devLevelCommands, "Ogre titans", "script thread TitanTypes( \"titan_ogre\")" )
			SetupDevCommand( devLevelCommands, "Stryder titans", "script thread TitanTypes( \"titan_stryder\")" )
			break

		case "mp_flightpath":
			SetupDevCommand( devLevelCommands, "Dropship fly in", "script thread DisplayAnim( DROPSHIP_MODEL, DROPSHIP_STRAFE )" )
			SetupDevCommand( devLevelCommands, "Straton fly by", "script thread DisplayAnim( HORNET_MODEL, STRATON_FLIGHT_ANIM )" )
			SetupDevCommand( devLevelCommands, "Carrier warp in", "script thread DisplayAnim( CARRIER_MODEL, \"ca_hover_above_city\" )" )
			SetupDevCommand( devLevelCommands, "Fighter Air Attack", "script thread DisplayAnim( HORNET_MODEL, \"st_AngelCity_IMC_Win_Full\" )" )
			SetupDevCommand( devLevelCommands, "Hornet torpedo run new 1", "script thread DisplayAnim( HORNET_MODEL, \"ht_carrier_Final_attack_1\" )" )
			SetupDevCommand( devLevelCommands, "Hornet torpedo run new 2", "script thread DisplayAnim( HORNET_MODEL, \"ht_carrier_Final_attack_2\" )" )
			SetupDevCommand( devLevelCommands, "Hornet torpedo run1", "script thread DisplayAnim( HORNET_MODEL, \"ht_carrier_attack_1\" )" )
			SetupDevCommand( devLevelCommands, "Hornet torpedo run2", "script thread DisplayAnim( HORNET_MODEL, \"ht_carrier_attack_2\" )" )
			SetupDevCommand( devLevelCommands, "Hornet torpedo run3", "script thread DisplayAnim( HORNET_MODEL, \"ht_carrier_attack_3\" )" )
			SetupDevCommand( devLevelCommands, "Dogfight 1", "script thread DogFight(1)" )
			SetupDevCommand( devLevelCommands, "Dogfight 2", "script thread DogFight(2)" )
			SetupDevCommand( devLevelCommands, "Dogfight 3", "script thread DogFight(3)" )
			SetupDevCommand( devLevelCommands, "Straton carrier exit 1", "script thread DisplayAnim( STRATON_MODEL, \"st_carrier_launch_1\" )" )
			SetupDevCommand( devLevelCommands, "Straton carrier exit 2", "script thread DisplayAnim( STRATON_MODEL, \"st_carrier_launch_2\" )" )
			SetupDevCommand( devLevelCommands, "Straton carrier exit 3", "script thread DisplayAnim( STRATON_MODEL, \"st_carrier_launch_3\" )" )
			SetupDevCommand( devLevelCommands, "Straton carrier exit 4", "script thread DisplayAnim( STRATON_MODEL, \"st_carrier_launch_4\" )" )
			SetupDevCommand( devLevelCommands, "Straton carrier exit 5", "script thread DisplayAnim( STRATON_MODEL, \"st_carrier_launch_5\" )" )
			SetupDevCommand( devLevelCommands, "Straton carrier exit 6", "script thread DisplayAnim( STRATON_MODEL, \"st_carrier_launch_6\" )" )
			SetupDevCommand( devLevelCommands, "Straton carrier exit 7", "script thread DisplayAnim( STRATON_MODEL, \"st_carrier_launch_7\" )" )
			SetupDevCommand( devLevelCommands, "Straton carrier exit 8", "script thread DisplayAnim( STRATON_MODEL, \"st_carrier_launch_8\" )" )
			break

		case "mp_airbase":
			SetupDevCommand( devLevelCommands, "Pre North Tower Collapse", "script thread DEV_PreNorthTowerFall()" )
			SetupDevCommand( devLevelCommands, "North Tower Collapse", "script thread DEV_NorthTowerFall()" )
			SetupDevCommand( devLevelCommands, "North Tower Collapse Post (Militia Only)", "script thread DEV_TowerNorthTowerFallPost()" )
			SetupDevCommand( devLevelCommands, "East Tower Collapse", "script thread DEV_EastTowerFall()" )
			SetupDevCommand( devLevelCommands, "Pre Final Tower", "script thread DEV_PreFinalTower()" )
			SetupDevCommand( devLevelCommands, "Militia Win", "script thread DEV_MilitiaWin()" )
			SetupDevCommand( devLevelCommands, "IMC Win", "script thread DEV_IMCWin()" )
			SetupDevCommand( devLevelCommands, "Militia Score Ticker", "script thread DEV_MilitiaScoreTicker()" )
			SetupDevCommand( devLevelCommands, "IMC Score Ticker", "script thread DEV_IMCScoreTicker()" )
			break

		case "mp_angel_city":
			SetupDevCommand( devLevelCommands, "Replay IMC intro", "script thread ReplayIMCIntro()" )
			SetupDevCommand( devLevelCommands, "Replay Militia intro", "script thread ReplayMilitiaIntro()" )
			SetupDevCommand( devLevelCommands, "Preview dog fights", "script thread DogFightsPreview()" )
			SetupDevCommand( devLevelCommands, "Preview hornet swarm (requires carrier exists)", "script_client thread HornetSwarmEndingAttack()" )
			SetupDevCommand( devLevelCommands, "Mega Carrier warps in", "script thread AddMegaCarrier()" )
			SetupDevCommand( devLevelCommands, "IMC victory (requires carrier exists)", "script thread IMCWinCarrierMoves()" )
			SetupDevCommand( devLevelCommands, "Mega Carrier idles (skip fly over)", "script thread AddMegaCarrier( false )" )
			SetupDevCommand( devLevelCommands, "Militia victory (requires carrier exists)", "script thread MilitiaWinAttackMegaCarrier()" )
			break

		case "mp_outpost_207":
			SetupDevCommand( devLevelCommands, "MCOR Ground Intro Action", "script thread IntroTitan_MCOR( true )" )
			SetupDevCommand( devLevelCommands, "IMC Ground Intro Action", "script thread IntroTitan_IMC( true )" )

			SetupDevCommand( devLevelCommands, "Simulate Game Scoring", "script thread SimulateGameScore()" )

			SetupDevCommand( devLevelCommands, "Decoy Ship Sequence", "script thread DecoyShip()" )
			SetupDevCommand( devLevelCommands, "Jump Drive Sequence", "script thread JumpDrivesDisabled( true )" )

			SetupDevCommand( devLevelCommands, "MCOR Hit 1/4 Score First", "script thread GameStateUpdate_QuarterMark( TEAM_MILITIA, true )" )
			SetupDevCommand( devLevelCommands, "IMC Hit 1/4 Score Before MCOR", "script thread GameStateUpdate_QuarterMark( TEAM_IMC, false )" )
			SetupDevCommand( devLevelCommands, "MCOR Hit 1/4 Score After IMC", "script thread GameStateUpdate_QuarterMark( TEAM_MILITIA, false )" )

			SetupDevCommand( devLevelCommands, "MCOR Hit 1/2 Score First", "script thread GameStateUpdate_HalfwayMark( TEAM_MILITIA, true )" )
			SetupDevCommand( devLevelCommands, "IMC Hit 1/2 Score Before MCOR", "script thread GameStateUpdate_HalfwayMark( TEAM_IMC, false )" )
			SetupDevCommand( devLevelCommands, "MCOR Hit 1/2 Score After IMC", "script thread GameStateUpdate_HalfwayMark( TEAM_MILITIA, false )" )

			SetupDevCommand( devLevelCommands, "MCOR Hit 3/4 Score First", "script thread GameStateUpdate_ThreeQuarterMark( TEAM_MILITIA, true )" )
			SetupDevCommand( devLevelCommands, "IMC Hit 3/4 Score Before MCOR", "script thread GameStateUpdate_ThreeQuarterMark( TEAM_IMC, false )" )
			SetupDevCommand( devLevelCommands, "MCOR Hit 3/4 Score After IMC", "script thread GameStateUpdate_ThreeQuarterMark( TEAM_MILITIA, false )" )

			SetupDevCommand( devLevelCommands, "MCOR Win Sequence", "script thread Outpost_CinematicEpilogueAction( TEAM_MILITIA )" )
			SetupDevCommand( devLevelCommands, "IMC Win Sequence", "script thread Outpost_CinematicEpilogueAction( TEAM_IMC )" )

			SetupDevCommand( devLevelCommands, "Reset Capital Ship To Start Pos", "script thread CapitalShipReset()" )
			SetupDevCommand( devLevelCommands, "Fast Capital Ship Drift Path", "script thread CapitalShipDriftPath( null, true )" )
			SetupDevCommand( devLevelCommands, "Capital Ship Drift Path Segment 1", "script thread CapitalShip_DriftSegment_1( null, true )" )
			SetupDevCommand( devLevelCommands, "Capital Ship Drift Path Segment 2", "script thread CapitalShip_DriftSegment_2( null, true )" )
			SetupDevCommand( devLevelCommands, "Capital Ship Drift Path Segment 3", "script thread CapitalShip_DriftSegment_3( null, true )" )
			SetupDevCommand( devLevelCommands, "Capital Ship Drift Path Segment 4", "script thread CapitalShip_DriftSegment_4( null, true )" )

			SetupDevCommand( devLevelCommands, "Capital Ship Escapes Early (IMC big win)", "script thread CapitalShip_Escapes( true, true )" )
			SetupDevCommand( devLevelCommands, "Capital Ship Escapes", "script thread CapitalShip_Escapes( false, true )" )
			SetupDevCommand( devLevelCommands, "Capital Ship Breaks Into Pieces", "script thread CapitalShip_BreaksIntoPieces( true )" )
			SetupDevCommand( devLevelCommands, "Capital Ship Restore From Pieces", "script thread CapitalShip_RestoreFromPieces()" )

			SetupDevCommand( devLevelCommands, "Fire Cannon At Capital Ship", "script thread AimAndFire()" )
			SetupDevCommand( devLevelCommands, "Skybox Cannons Rotate Test", "script thread SkyCannons_TestRotation()" )
			break

		case "mp_corporate":
			SetupDevCommand( devLevelCommands, "Progress Dialogue 10% (CAMPAIGN HARDPOINTS ONLY)", "script thread DEV_MatchProgressDialogue( 1 )" )
			SetupDevCommand( devLevelCommands, "Progress Dialogue 25% (CAMPAIGN HARDPOINTS ONLY)", "script thread DEV_MatchProgressDialogue( 2 )" )
			SetupDevCommand( devLevelCommands, "Progress Dialogue 50% (CAMPAIGN HARDPOINTS ONLY)", "script thread DEV_MatchProgressDialogue( 3 )" )
			SetupDevCommand( devLevelCommands, "Progress Dialogue 75% (CAMPAIGN HARDPOINTS ONLY)", "script thread DEV_MatchProgressDialogue( 4 )" )
			SetupDevCommand( devLevelCommands, "Progress Dialogue Epilogue 1 (CAMPAIGN HARDPOINTS ONLY)", "script thread DEV_MatchProgressDialogue( 5 )" )
			SetupDevCommand( devLevelCommands, "Progress Dialogue Epilogue 2 (CAMPAIGN HARDPOINTS ONLY)", "script thread DEV_MatchProgressDialogue( 6 )" )
			SetupDevCommand( devLevelCommands, "Factory blows up", "script DEV_EvacFactoryBlowsUp()" )
			SetupDevCommand( devLevelCommands, "Spectre climb", "script DEV_SpectreClimb()" )
			SetupDevCommand( devLevelCommands, "IMC Epilogue: Evac #1", "script DEV_SpectreSwarm( 0 )" )
			SetupDevCommand( devLevelCommands, "IMC Epilogue: Evac #2", "script DEV_SpectreSwarm( 1 )" )
			SetupDevCommand( devLevelCommands, "IMC Epilogue: Evac #3", "script DEV_SpectreSwarm( 2 )" )
			break
		case "mp_colony":
			SetupDevCommand( devLevelCommands, "Progress Dialogue 15% (CAMPAIGN ATTRITION ONLY)", "script thread DEV_MatchProgressDialogue( 1 )" )
			SetupDevCommand( devLevelCommands, "Progress Dialogue 40% (CAMPAIGN ATTRITION ONLY)", "script thread DEV_MatchProgressDialogue( 2 )" )
			SetupDevCommand( devLevelCommands, "Progress Dialogue 60% (CAMPAIGN ATTRITION ONLY)", "script thread DEV_MatchProgressDialogue( 3 )" )
			SetupDevCommand( devLevelCommands, "Progress Dialogue 80% (CAMPAIGN ATTRITION ONLY)", "script thread DEV_MatchProgressDialogue( 4 )" )
			SetupDevCommand( devLevelCommands, "Progress Dialogue Epilogue (CAMPAIGN ATTRITION ONLY)", "script thread DEV_MatchProgressDialogue( 5 )" )
			break
		case "mp_boneyard":
			SetupDevCommand( devLevelCommands, "Advance Score, Militia Lead", "script thread AdvanceProgression( TEAM_MILITIA )" )
			SetupDevCommand( devLevelCommands, "Advance Score, IMC Lead", "script thread AdvanceProgression( TEAM_IMC )" )
			SetupDevCommand( devLevelCommands, "Flyer Ragdoll Test", "script RagdollTest()" )
			SetupDevCommand( devLevelCommands, "Flyer Pickup Test", "script FlyerPickupTest()" )
			SetupDevCommand( devLevelCommands, "Flyer Dropship Attack", "script FlyerDropshipAttackTest()" )
			SetupDevCommand( devLevelCommands, "Tower Minor Pulse", "script thread TowerMinorPulse()" )
			SetupDevCommand( devLevelCommands, "Tower Major Pulse", "script thread TowerMajorPulse()" )
			SetupDevCommand( devLevelCommands, "Tower Explode", "script thread TowerExplode( 2 )" )
			SetupDevCommand( devLevelCommands, "Add Flyers", "script_client thread AddFlyers()" )
			SetupDevCommand( devLevelCommands, "Hardpoint Electric Burst", "script_client thread DevHardpointElectricBurst()" )
			break

		case "mp_relic":
			SetupDevCommand( devLevelCommands, "Advance Score", "script thread AdvanceProgression()" )
			SetupDevCommand( devLevelCommands, "Turn On Ship Lights", "script ShipLightsTurnOn()" )
			SetupDevCommand( devLevelCommands, "Turn Off Ship Lights", "script ShipLightsTurnOff()" )
			SetupDevCommand( devLevelCommands, "Turn On Ship Speakers", "script level.nv.shipSpeakers = true" )
			SetupDevCommand( devLevelCommands, "Turn Off Ship Speakers", "script level.nv.shipSpeakers = false" )
			SetupDevCommand( devLevelCommands, "Start Ship Engines", "script thread DevActivateEngines()" )
			SetupDevCommand( devLevelCommands, "Start Engines Malfunction", "script thread DevShipEnginesMalfunction()" )
			SetupDevCommand( devLevelCommands, "Right Engine Fall Off", "script thread RightEngineFallOff()" )
			SetupDevCommand( devLevelCommands, "Reset Engines", "script thread DevDeactivateEngines()" )
			SetupDevCommand( devLevelCommands, "Activate Ship FX", "script level.nv.shipFx = true" )
			SetupDevCommand( devLevelCommands, "Deactivate Ship FX", "script level.nv.shipFx = false" )
			SetupDevCommand( devLevelCommands, "MacAllan Pickup", "script thread ProgressStageMilitia_Last()" )
			SetupDevCommand( devLevelCommands, "Militia Intro", "script thread TestMilitiaIntro()" )

			SetupDevCommand( devLevelCommands, "Blisk: diag_matchProg_IMC04_RC114_01_01_imc_blisk", "script ForcePlayConversationToAll( \"BliskTest1\" )" )
			SetupDevCommand( devLevelCommands, "MacAllan: diag_matchProg_MIL01_RC107_01_01_mcor_macal", "script ForcePlayConversationToAll( \"MacTest1\" )" )
			SetupDevCommand( devLevelCommands, "MacAllan: diag_matchProg_MIL02_RC109_02_01_mcor_macal", "script ForcePlayConversationToAll( \"MacTest2\" )" )
			SetupDevCommand( devLevelCommands, "MacAllan: diag_matchProg_MIL02_RC111_04_01_mcor_macal", "script ForcePlayConversationToAll( \"MacTest3\" )" )
			break

		case "mp_fracture":
			SetupDevCommand( devLevelCommands, "IMC Captain Anim", "script thread IntroIMCCaptain( true )" )
			break

		case "mp_o2":
			SetupDevCommand( devLevelCommands, "Militia Intro: Wakeup Seat 1", "script thread DEV_MCORIntroWakeup( 0 )" )
			SetupDevCommand( devLevelCommands, "Militia Intro: Wakeup Seat 2", "script thread DEV_MCORIntroWakeup( 1 )" )
			SetupDevCommand( devLevelCommands, "Militia Intro: Wakeup Seat 3", "script thread DEV_MCORIntroWakeup( 2 )" )

			SetupDevCommand( devLevelCommands, "Militia Intro: Wakeup Seat 5", "script thread DEV_MCORIntroWakeup( 3 )" )
			SetupDevCommand( devLevelCommands, "Militia Intro: Wakeup Seat 6", "script thread DEV_MCORIntroWakeup( 4 )" )
			SetupDevCommand( devLevelCommands, "Militia Intro: Wakeup Seat 7", "script thread DEV_MCORIntroWakeup( 5 )" )

			SetupDevCommand( devLevelCommands, "Militia Intro: Crash Seat 1", "script thread DEV_MCORIntroCrash( 0 )" )
			SetupDevCommand( devLevelCommands, "Militia Intro: Crash Seat 2", "script thread DEV_MCORIntroCrash( 1 )" )
			SetupDevCommand( devLevelCommands, "Militia Intro: Crash Seat 3", "script thread DEV_MCORIntroCrash( 2 )" )

			SetupDevCommand( devLevelCommands, "Militia Intro: Crash Seat 5", "script thread DEV_MCORIntroCrash( 3 )" )
			SetupDevCommand( devLevelCommands, "Militia Intro: Crash Seat 6", "script thread DEV_MCORIntroCrash( 4 )" )
			SetupDevCommand( devLevelCommands, "Militia Intro: Crash Seat 7", "script thread DEV_MCORIntroCrash( 5 )" )

			SetupDevCommand( devLevelCommands, "Enable Militia FX on All Hardpoints", "script_client DEV_TeamFX(TEAM_MILITIA)" )
			SetupDevCommand( devLevelCommands, "Enable IMC FX on All Hardpoints", "script_client DEV_TeamFX(TEAM_IMC)" )
			SetupDevCommand( devLevelCommands, "Disable All Hardpoint FX (Level Start Status)", "script_client DEV_TeamFX()" )
			SetupDevCommand( devLevelCommands, "Test Nuke FX", "script_client DEV_TestNukeFX()" )

			SetupDevCommand( devLevelCommands, "IMC Intro: Ready Start 1", "script thread DEV_IMCIntroStart( 0 )" )
			SetupDevCommand( devLevelCommands, "IMC Intro: Ready Start 2", "script thread DEV_IMCIntroStart( 1 )" )
			SetupDevCommand( devLevelCommands, "IMC Intro: Ready Start 3", "script thread DEV_IMCIntroStart( 2 )" )
			SetupDevCommand( devLevelCommands, "IMC Intro: Ready Start 4", "script thread DEV_IMCIntroStart( 3 )" )

			SetupDevCommand( devLevelCommands, "End: Bad Idea", 			"script_client thread StoryBlurb2( TEAM_MILITIA )" )
			SetupDevCommand( devLevelCommands, "End: Ambush Militia", 		"script_client thread StoryBlurb3( TEAM_MILITIA )" )
			SetupDevCommand( devLevelCommands, "End: Ambush IMC", 			"script_client thread StoryBlurb3( TEAM_IMC )" )
			SetupDevCommand( devLevelCommands, "End: Sacrifice Militia", 	"script_client thread StoryBlurb4( TEAM_MILITIA )" )
			SetupDevCommand( devLevelCommands, "End: Sacrifice IMC",		"script_client thread StoryBlurb4( TEAM_IMC )" )
			SetupDevCommand( devLevelCommands, "End: Finale Militia",		"script_client thread StoryBlurb5( TEAM_MILITIA )" )
			SetupDevCommand( devLevelCommands, "End: Finale IMC",			"script_client thread StoryBlurb5( TEAM_IMC )" )
			SetupDevCommand( devLevelCommands, "End: Post Epilogue",		"script thread DoPostEpilogue( true )" )

			break

		case "mp_npe":
			SetupDevCommand( devLevelCommands, "Cabin [LEVEL START]", 		"script thread StartTrainingModule_FromDevMenu( eTrainingModules.BEDROOM )" )
			SetupDevCommand( devLevelCommands, "Sprint & Jump", 			"script thread StartTrainingModule_FromDevMenu( eTrainingModules.JUMP )" )
			SetupDevCommand( devLevelCommands, "Wallrun",					"script thread StartTrainingModule_FromDevMenu( eTrainingModules.WALLRUN )" )
			SetupDevCommand( devLevelCommands, "Wallrun Playground", 		"script thread StartTrainingModule_FromDevMenu( eTrainingModules.WALLRUN_PLAYGROUND )" )
			SetupDevCommand( devLevelCommands, "Double Jump", 				"script thread StartTrainingModule_FromDevMenu( eTrainingModules.DOUBLEJUMP )" )
			SetupDevCommand( devLevelCommands, "Double Jump Playground", 	"script thread StartTrainingModule_FromDevMenu( eTrainingModules.DOUBLEJUMP_PLAYGROUND )" )
			SetupDevCommand( devLevelCommands, "Cloak", 					"script thread StartTrainingModule_FromDevMenu( eTrainingModules.CLOAK )" )
			SetupDevCommand( devLevelCommands, "Basic Combat",				"script thread StartTrainingModule_FromDevMenu( eTrainingModules.BASIC_COMBAT )" )
			SetupDevCommand( devLevelCommands, "Firing Range: Rifle", 		"script thread StartTrainingModule_FromDevMenu( eTrainingModules.FIRINGRANGE )" )
			SetupDevCommand( devLevelCommands, "Firing Range: Grenades", 	"script thread StartTrainingModule_FromDevMenu( eTrainingModules.FIRINGRANGE_GRENADES )" )
			SetupDevCommand( devLevelCommands, "Pilot Mosh Pit", 			"script thread StartTrainingModule_FromDevMenu( eTrainingModules.MOSH_PIT )" )
			SetupDevCommand( devLevelCommands, "Titan Dash", 				"script thread StartTrainingModule_FromDevMenu( eTrainingModules.TITAN_DASH )" )
			SetupDevCommand( devLevelCommands, "Titan Vortex",	 			"script thread StartTrainingModule_FromDevMenu( eTrainingModules.TITAN_VORTEX )" )
			SetupDevCommand( devLevelCommands, "Titan AI Control", 			"script thread StartTrainingModule_FromDevMenu( eTrainingModules.TITAN_PET )" )
			SetupDevCommand( devLevelCommands, "Titan Mosh Pit", 			"script thread StartTrainingModule_FromDevMenu( eTrainingModules.TITAN_MOSH_PIT )" )
			SetupDevCommand( devLevelCommands, "Cabin Ending", 				"script thread StartTrainingModule_FromDevMenu( eTrainingModules.BEDROOM_END )" )
			SetupDevCommand( devLevelCommands, "Dev Test Start", 			"script thread StartTrainingModule_FromDevMenu( eTrainingModules.TEST )" )
			break

		case "model_viewer":
			SetupDevCommand( devLevelCommands, "Toggle Rebreather Masks", "script ToggleRebreatherMasks()" )
			break
	}

	local buttons = GetElementsByClassname( GetMenu( "DevMenu" ), "DevButtonClass" )
	foreach ( button in buttons )
	{
		local buttonID = button.GetScriptID().tointeger()

		if ( buttonID < devCommands.len() )
		{
			button.SetText( devCommands[buttonID].label )
			button.SetEnabled( true )
		}
		else
		{
			button.SetText( "" )
			button.SetEnabled( false )
		}
	}

	local buttons = GetElementsByClassname( GetMenu( "DevLevelMenu" ), "DevLevelButtonClass" )
	foreach ( button in buttons )
	{
		local buttonID = button.GetScriptID().tointeger()

		if ( buttonID < devLevelCommands.len() )
		{
			button.SetText( devLevelCommands[buttonID].label )
			button.SetEnabled( true )
		}
		else
		{
			button.SetText( "" )
			button.SetEnabled( false )
		}
	}
}

function SetupDevCommand( commandArray, label, command )
{
	local table = {}
	table.label <- label
	table.command <- command

	printt( "command" + command )

	commandArray.append( table )
}

function OnDevButton_Activate( button )
{
	if ( level.ui.disableDev )
	{
		CodeWarning( "Dev commands disabled on matchingmaking servers." )
		return
	}

	local buttonID = button.GetScriptID().tointeger()
	local command = devCommands[buttonID].command
	printt( "command" + command )

	if ( type( command ) == "string" )
		ClientCommand( command )
	else
		command()

	CloseAllInGameMenus()
}


function OnDevLevelButton_Activate( button )
{
	if ( level.ui.disableDev )
	{
		CodeWarning( "Dev commands disabled on matchingmaking servers." )
		return
	}

	local buttonID = button.GetScriptID().tointeger()

	ClientCommand( devLevelCommands[buttonID].command )

	CloseAllInGameMenus()
}
