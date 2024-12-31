//********************************************************************************************
//
//	MP Game Settings File
//	Designers: put variables you want to expose to everyone in this file for easy tweaking
//
//********************************************************************************************
IncludeScript( "_gamemodes" )

GAMETYPE_TEXT <- {}
GAMETYPE_TEXT[ TEAM_DEATHMATCH ] 		<- "#GAMEMODE_PILOT_HUNTER"
GAMETYPE_TEXT[ ELIMINATION ] 			<- "#GAMEMODE_ELIMINATION"
GAMETYPE_TEXT[ ATDM ] 					<- "#GAMEMODE_ATDM"
GAMETYPE_TEXT[ ATTRITION ] 				<- "#GAMEMODE_ATTRITION"
GAMETYPE_TEXT[ BIG_BROTHER ] 			<- "#GAMEMODE_BIG_BROTHER"
GAMETYPE_TEXT[ HEIST ] 					<- "#GAMEMODE_HEIST"
GAMETYPE_TEXT[ UPLINK ] 				<- "#GAMEMODE_UPLINK"
GAMETYPE_TEXT[ EXFILTRATION ] 			<- "#GAMEMODE_EXFILTRATION"
GAMETYPE_TEXT[ TITAN_TAG ] 				<- "#GAMEMODE_TITAN_TAG"
GAMETYPE_TEXT[ COOPERATIVE ] 			<- "#GAMEMODE_COOP"
GAMETYPE_TEXT[ FFA ] 			<- "#GAMEMODE_FFA"

GAMETYPE_DESC <- {}
GAMETYPE_DESC[ TEAM_DEATHMATCH ] 		<- "#GAMEMODE_PILOT_HUNTER_HINT"
GAMETYPE_DESC[ ELIMINATION ] 			<- "#GAMEMODE_ELIMINATION_HINT"
GAMETYPE_DESC[ ATDM ] 					<- "#GAMEMODE_ATDM_HINT"
GAMETYPE_DESC[ ATTRITION ] 				<- "#GAMEMODE_ATTRITION_HINT"
GAMETYPE_DESC[ HEIST ]		 			<- "#GAMEMODE_HEIST_HINT"
GAMETYPE_DESC[ UPLINK ] 				<- "#GAMEMODE_UPLINK_HINT"
GAMETYPE_DESC[ EXFILTRATION ] 			<- "#GAMEMODE_EXFILTRATION_HINT"
GAMETYPE_DESC[ TITAN_TAG ] 				<- "#GAMEMODE_TITAN_TAG_HINT"
GAMETYPE_DESC[ FFA ] 			<- "You against the world."

GAMETYPE_ICON <- {}
GAMETYPE_ICON[ TEAM_DEATHMATCH ] 		<- "../ui/menu/playlist/tdm"
GAMETYPE_ICON[ ELIMINATION ] 			<- "../ui/menu/playlist/classic"
GAMETYPE_ICON[ ATDM ] 					<- "../ui/menu/playlist/classic"
GAMETYPE_ICON[ ATTRITION ] 				<- "../ui/menu/playlist/at"
GAMETYPE_ICON[ BIG_BROTHER ] 			<- "../ui/menu/playlist/classic"
GAMETYPE_ICON[ HEIST ] 					<- "../ui/menu/playlist/classic"
GAMETYPE_ICON[ SCAVENGER ]	 			<- "../ui/menu/playlist/classic"
GAMETYPE_ICON[ UPLINK ] 				<- "../ui/menu/playlist/classic"
GAMETYPE_ICON[ EXFILTRATION ] 			<- "../ui/menu/playlist/classic"
GAMETYPE_ICON[ TITAN_TAG ] 				<- "../ui/menu/playlist/classic"
GAMETYPE_ICON[ COOPERATIVE ] 			<- "../ui/menu/playlist/coop"
GAMETYPE_ICON[ RANKED_PLAY ] 			<- "../ui/scoreboard_secret_logo"
GAMETYPE_ICON[ FFA ] 			<- "../ui/scoreboard_secret_logo"

GAMETYPE_STAR_SCORE_REQUIREMENT <- {}
GAMETYPE_STAR_SCORE_REQUIREMENT[ TEAM_DEATHMATCH ] 		<- [ 5, 10, 20 ]
GAMETYPE_STAR_SCORE_REQUIREMENT[ CAPTURE_POINT ] 		<- [ 500, 1500, 2500 ]
GAMETYPE_STAR_SCORE_REQUIREMENT[ ATTRITION ] 			<- [ 25, 75, 150 ]
GAMETYPE_STAR_SCORE_REQUIREMENT[ CAPTURE_THE_FLAG ] 	<- [ 1, 2, 3 ]
GAMETYPE_STAR_SCORE_REQUIREMENT[ LAST_TITAN_STANDING ] 	<- [ 2, 5, 8 ]
GAMETYPE_STAR_SCORE_REQUIREMENT[ MARKED_FOR_DEATH ] 	<- [ 1, 4, 7 ]
//DEFAULT VALUE - CO-OP SHOULD BE MAP SPECIFIC
GAMETYPE_STAR_SCORE_REQUIREMENT[ COOPERATIVE ] 			<- [ 10000, 50000, 100000 ]

COOP_STAR_SCORE_REQUIREMENT <- {}
//SCORES DETERMINED BY RUNNING "script Coop_GetTeamScore()" while the level is playing.
COOP_STAR_SCORE_REQUIREMENT[ "mp_airbase" ]					<- [ 620, 1245, 1870 ]
COOP_STAR_SCORE_REQUIREMENT[ "mp_angel_city" ]				<- [ 650, 1305, 1955 ]
COOP_STAR_SCORE_REQUIREMENT[ "mp_backwater" ]				<- [ 615, 1235, 1855 ]
COOP_STAR_SCORE_REQUIREMENT[ "mp_boneyard" ]				<- [ 595, 1190, 1790 ]
COOP_STAR_SCORE_REQUIREMENT[ "mp_colony" ]					<- [ 620, 1245, 1870 ]
COOP_STAR_SCORE_REQUIREMENT[ "mp_corporate" ]				<- [ 570, 1145, 1715 ]
COOP_STAR_SCORE_REQUIREMENT[ "mp_fracture" ]				<- [ 675, 1355, 2030 ]
COOP_STAR_SCORE_REQUIREMENT[ "mp_harmony_mines" ]			<- [ 615, 1230, 1845 ]
COOP_STAR_SCORE_REQUIREMENT[ "mp_haven" ]					<- [ 620, 1245, 1870 ]
COOP_STAR_SCORE_REQUIREMENT[ "mp_lagoon" ]					<- [ 700, 1405, 2110 ]
COOP_STAR_SCORE_REQUIREMENT[ "mp_nexus" ]					<- [ 620, 1240, 1865 ]
COOP_STAR_SCORE_REQUIREMENT[ "mp_o2" ]						<- [ 620, 1245, 1870 ]
COOP_STAR_SCORE_REQUIREMENT[ "mp_outpost_207" ]				<- [ 550, 1100, 1650 ]
COOP_STAR_SCORE_REQUIREMENT[ "mp_overlook" ]				<- [ 630, 1260, 1890 ]
COOP_STAR_SCORE_REQUIREMENT[ "mp_relic" ]					<- [ 550, 1100, 1650 ]
COOP_STAR_SCORE_REQUIREMENT[ "mp_rise" ]					<- [ 350, 700, 1055 ]
COOP_STAR_SCORE_REQUIREMENT[ "mp_runoff" ]					<- [ 550, 1100, 1650 ]
COOP_STAR_SCORE_REQUIREMENT[ "mp_sandtrap" ]				<- [ 675, 1355, 2030 ]
COOP_STAR_SCORE_REQUIREMENT[ "mp_smugglers_cove" ]			<- [ 595, 1190, 1785 ]
COOP_STAR_SCORE_REQUIREMENT[ "mp_switchback" ]				<- [ 570, 1145, 1715 ]
COOP_STAR_SCORE_REQUIREMENT[ "mp_training_ground" ]			<- [ 720, 1445, 2170 ]
COOP_STAR_SCORE_REQUIREMENT[ "mp_zone_18" ]					<- [ 615, 1235, 1855 ]
COOP_STAR_SCORE_REQUIREMENT[ "mp_wargames" ]				<- [ 570, 1145, 1715 ]
COOP_STAR_SCORE_REQUIREMENT[ "mp_swampland" ]				<- [ 655, 1310, 1970 ]
COOP_STAR_SCORE_REQUIREMENT[ "default" ]					<- [ 10000, 10000, 10000 ]

COOP_CUSTOMMATCH_UNLOCK_PLAYS <- 3

if ( IsClient() )
{
	PrecacheHUDMaterial( GAMETYPE_ICON[ TEAM_DEATHMATCH ] )
	PrecacheHUDMaterial( GAMETYPE_ICON[ ELIMINATION ] )
	PrecacheHUDMaterial( GAMETYPE_ICON[ ATDM ] )
	PrecacheHUDMaterial( GAMETYPE_ICON[ HEIST ] )
	PrecacheHUDMaterial( GAMETYPE_ICON[ BIG_BROTHER ] )
	PrecacheHUDMaterial( GAMETYPE_ICON[ ATTRITION ] )
	PrecacheHUDMaterial( GAMETYPE_ICON[ UPLINK ] )
	PrecacheHUDMaterial( GAMETYPE_ICON[ EXFILTRATION ] )
	PrecacheHUDMaterial( GAMETYPE_ICON[ TITAN_TAG ] )
}


	GameMode_Create( CAMPAIGN )
	GameMode_SetName( CAMPAIGN, "#PL_campaign" )
	GameMode_SetDesc( CAMPAIGN, "#PL_campaign_desc" )
	GameMode_SetIcon( CAMPAIGN, "../ui/menu/playlist/campaign" )

	GameMode_Create( CAPTURE_THE_TITAN )
	GameMode_SetName( CAPTURE_THE_TITAN, "#GAMEMODE_CAPTURE_THE_TITAN" )
	GameMode_SetGameModeAttackAnnouncement( CAPTURE_THE_TITAN, "GameModeAnnounce_CTT_Attack" )
	GameMode_SetGameModeDefendAnnouncement( CAPTURE_THE_TITAN, "GameModeAnnounce_CTT_Defend" )
	GameMode_SetDesc( CAPTURE_THE_TITAN, "#GAMEMODE_CAPTURE_THE_TITAN_HINT" )
	GameMode_SetAttackDesc( CAPTURE_THE_TITAN, "#GAMEMODE_CAPTURE_THE_TITAN_ATTACK" )
	GameMode_SetDefendDesc( CAPTURE_THE_TITAN, "#GAMEMODE_CAPTURE_THE_TITAN_DEFEND" )
	GameMode_SetIcon( CAPTURE_THE_TITAN, "../ui/menu/playlist/ctf" )
	GameMode_AddServerScript( CAPTURE_THE_TITAN, "mp/capture_the_titan" )
	GameMode_AddClientScript( CAPTURE_THE_TITAN, "client/cl_capture_the_titan" )
	GameMode_AddSharedScript( CAPTURE_THE_TITAN, "_capture_the_titan_shared" )
	GameMode_AddSharedDialogueScript( CAPTURE_THE_TITAN, "_capture_the_titan_dialogue" )
	GameMode_SetDefaultScoreLimits( CAPTURE_THE_TITAN, 30, 5 )
	GameMode_SetDefaultTimeLimits( CAPTURE_THE_TITAN, 7, 5 )

	GameMode_Create( TITAN_ESCORT )
	GameMode_SetName( TITAN_ESCORT, "#GAMEMODE_TITAN_ESCORT" )
	GameMode_SetDesc( TITAN_ESCORT, "#GAMEMODE_TITAN_ESCORT_HINT" )
	GameMode_SetGameModeAnnouncement( TITAN_ESCORT, "GameModeAnnounce_TDM" )
	GameMode_AddServerScript( TITAN_ESCORT, "mp/titan_escort" )
	GameMode_AddClientScript( TITAN_ESCORT, "client/cl_gamemode_titan_escort" )
	GameMode_AddSharedScript( TITAN_ESCORT, "_titan_escort_shared" )

	GameMode_Create( COOPERATIVE )
	GameMode_SetName( COOPERATIVE, "#GAMEMODE_COOP" )
	GameMode_SetGameModeAnnouncement( COOPERATIVE, "CoopTD_GameModeAnnounce" )
	GameMode_SetGameModeAttackAnnouncement( COOPERATIVE, "CoopTD_GameModeAnnounce" )
	GameMode_SetGameModeDefendAnnouncement( COOPERATIVE, "CoopTD_GameModeAnnounce" )
	GameMode_SetIcon( COOPERATIVE, "../ui/menu/playlist/coop" )
	GameMode_SetDesc( COOPERATIVE, "#GAMEMODE_COOP_HINT" )
	GameMode_AddServerScript( COOPERATIVE, "mp/_gamemode_coop" )
	GameMode_AddServerScript( COOPERATIVE, "_coop_team_score_shared" )
	GameMode_AddServerScript( COOPERATIVE, "mp/_coop_eog_harvester_debrief" )
	GameMode_AddClientScript( COOPERATIVE, "client/cl_gamemode_coop" )
	GameMode_AddClientScript( COOPERATIVE, "client/cl_coop_hud" )
	GameMode_AddClientScript( COOPERATIVE, "_coop_team_score_shared" )
	GameMode_AddClientScript( COOPERATIVE, "client/cl_coop_eog_harvester_debrief" )
	GameMode_SetDefaultScoreLimits( COOPERATIVE, 400, 400 )
	GameMode_SetDefaultTimeLimits( COOPERATIVE, 0, 0 )

	GameMode_Create( CAPTURE_POINT )
	GameMode_SetName( CAPTURE_POINT, "#GAMEMODE_CAPTURE_POINT" )
	GameMode_SetGameModeAnnouncement( CAPTURE_POINT, "GameModeAnnounce_CP" )
	GameMode_SetDesc( CAPTURE_POINT, "#GAMEMODE_CAPTURE_POINT_HINT" )
	GameMode_SetIcon( CAPTURE_POINT, "../ui/menu/playlist/cp" )
	GameMode_AddServerScript( CAPTURE_POINT, "mp/_gamemode_cp" )
	GameMode_AddClientScript( CAPTURE_POINT, "client/cl_gamemode_cp" )
	GameMode_SetDefaultScoreLimits( CAPTURE_POINT, 400, 400 )

	GameMode_Create( LAST_TITAN_STANDING )
	GameMode_SetName( LAST_TITAN_STANDING, "#GAMEMODE_LAST_TITAN_STANDING" )
	GameMode_SetGameModeAnnouncement( LAST_TITAN_STANDING, "GameModeAnnounce_LTS" )
	GameMode_SetDesc( LAST_TITAN_STANDING, "#GAMEMODE_LAST_TITAN_STANDING_HINT" )
	GameMode_SetIcon( LAST_TITAN_STANDING, "../ui/menu/playlist/lts" )
	GameMode_AddServerScript( LAST_TITAN_STANDING, "mp/_gamemode_lts" )
	GameMode_SetDefaultScoreLimits( LAST_TITAN_STANDING, 0, 4 )
	GameMode_SetDefaultTimeLimits( LAST_TITAN_STANDING, 5, 4 )

	GameMode_Create( WINGMAN_LAST_TITAN_STANDING )
	GameMode_SetName( WINGMAN_LAST_TITAN_STANDING, "#GAMEMODE_WINGMAN_LAST_TITAN_STANDING" )
	GameMode_SetGameModeAnnouncement( WINGMAN_LAST_TITAN_STANDING, "GameModeAnnounce_WLTS" )
	GameMode_SetDesc( WINGMAN_LAST_TITAN_STANDING, "#GAMEMODE_WINGMAN_LAST_TITAN_STANDING_HINT" )
	GameMode_SetIcon( WINGMAN_LAST_TITAN_STANDING, "../ui/menu/playlist/wingman_lts" )
	GameMode_AddServerScript( WINGMAN_LAST_TITAN_STANDING, "mp/_gamemode_wlts" )
	GameMode_AddSharedDialogueScript( WINGMAN_LAST_TITAN_STANDING, "_gamemode_wlts_dialogue" )
	GameMode_SetDefaultScoreLimits( WINGMAN_LAST_TITAN_STANDING, 0, 4 )
	GameMode_SetDefaultTimeLimits( WINGMAN_LAST_TITAN_STANDING, 5, 4 )

	GameMode_Create( MARKED_FOR_DEATH )
	GameMode_SetName( MARKED_FOR_DEATH, "#GAMEMODE_MARKED_FOR_DEATH" )
	GameMode_SetGameModeAnnouncement( MARKED_FOR_DEATH, "GameModeAnnounce_MFD" )
	GameMode_SetDesc( MARKED_FOR_DEATH, "#GAMEMODE_MARKED_FOR_DEATH_HINT" )
	GameMode_SetIcon( MARKED_FOR_DEATH, "../ui/menu/playlist/mfd" )
	GameMode_AddServerScript( MARKED_FOR_DEATH, "mp/_gamemode_mfd" )
	GameMode_AddClientScript( MARKED_FOR_DEATH, "client/cl_gamemode_mfd" )
	GameMode_AddSharedScript( MARKED_FOR_DEATH, "_gamemode_mfd_shared" )
	GameMode_AddSharedDialogueScript( MARKED_FOR_DEATH, "_gamemode_mfd_dialogue" )
	GameMode_SetDefaultScoreLimits( MARKED_FOR_DEATH, 10, 0 )
	GameMode_SetDefaultTimeLimits( MARKED_FOR_DEATH, 10, 0 )

	GameMode_Create( MARKED_FOR_DEATH_PRO )
	GameMode_SetName( MARKED_FOR_DEATH_PRO, "#GAMEMODE_MARKED_FOR_DEATH_PRO" )
	GameMode_SetGameModeAnnouncement( MARKED_FOR_DEATH_PRO, "GameModeAnnounce_MFD_PRO" )
	GameMode_SetDesc( MARKED_FOR_DEATH_PRO, "#GAMEMODE_MARKED_FOR_DEATH_PRO_HINT" )
	GameMode_SetIcon( MARKED_FOR_DEATH_PRO, "../ui/menu/playlist/mfd_pro" )
	GameMode_AddServerScript( MARKED_FOR_DEATH_PRO, "mp/_gamemode_mfd_pro" )
	GameMode_AddClientScript( MARKED_FOR_DEATH_PRO, "client/cl_gamemode_mfd" )
	GameMode_AddSharedScript( MARKED_FOR_DEATH_PRO, "_gamemode_mfd_shared" )
	GameMode_AddSharedDialogueScript( MARKED_FOR_DEATH_PRO, "_gamemode_mfd_dialogue" )
	GameMode_SetDefaultScoreLimits( MARKED_FOR_DEATH_PRO, 0, 6)
	GameMode_SetDefaultTimeLimits( MARKED_FOR_DEATH_PRO, 0, 4 )

	GameMode_Create( SCAVENGER )
	GameMode_SetName( SCAVENGER, "#GAMEMODE_SCAVENGER" )
	GameMode_SetGameModeAnnouncement( SCAVENGER, "GameModeAnnounce_TDM" )
	GameMode_SetDesc( SCAVENGER, "#GAMEMODE_SCAVENGER_HINT" )
	//GameMode_SetIcon( SCAVENGER, "../ui/menu/playlist/cp" ) //Need own icon
	GameMode_AddServerScript( SCAVENGER, "mp/_gamemode_scavenger" )
	GameMode_AddClientScript( SCAVENGER, "client/cl_gamemode_scavenger" )
	GameMode_SetDefaultScoreLimits( SCAVENGER, 125, 0 )

	GameMode_Create( PILOT_SKIRMISH )
	GameMode_SetName( PILOT_SKIRMISH, "#GAMEMODE_PILOT_SKIRMISH" )
	GameMode_SetGameModeAnnouncement( PILOT_SKIRMISH, "GameModeAnnounce_PS" )
	GameMode_SetDesc( PILOT_SKIRMISH, "#GAMEMODE_PILOT_SKIRMISH_HINT" )
	GameMode_SetIcon( PILOT_SKIRMISH, "../ui/menu/playlist/tdm" )
	GameMode_AddServerScript( PILOT_SKIRMISH, "mp/_gamemode_ps" )
	GameMode_SetDefaultScoreLimits( PILOT_SKIRMISH, 100, 0 )
	GameMode_SetDefaultTimeLimits( PILOT_SKIRMISH, 15, 0 )

	GameMode_Create( CAPTURE_THE_FLAG )
	GameMode_SetName( CAPTURE_THE_FLAG, "#GAMEMODE_CAPTURE_THE_FLAG" )
	GameMode_SetGameModeAnnouncement( CAPTURE_THE_FLAG, "GameModeAnnounce_CTF" )
	GameMode_SetDesc( CAPTURE_THE_FLAG, "#GAMEMODE_CAPTURE_THE_FLAG_HINT" )
	GameMode_SetIcon( CAPTURE_THE_FLAG, "../ui/menu/playlist/ctf" )
	GameMode_AddServerScript( CAPTURE_THE_FLAG, "mp/_gamemode_ctf_pro" )
	GameMode_AddClientScript( CAPTURE_THE_FLAG, "client/cl_capture_the_flag" )
	GameMode_AddSharedScript( CAPTURE_THE_FLAG, "_capture_the_flag_shared" )
	GameMode_AddSharedDialogueScript( CAPTURE_THE_FLAG, "_gamemode_ctf_dialogue" )
	GameMode_SetDefaultScoreLimits( CAPTURE_THE_FLAG, 0, 6 )
	GameMode_SetDefaultTimeLimits( CAPTURE_THE_FLAG, 0, 3 )

	GameMode_Create( CAPTURE_THE_FLAG_PRO )
	GameMode_SetName( CAPTURE_THE_FLAG_PRO, "#GAMEMODE_CAPTURE_THE_FLAG_PRO" )
	//GameMode_SetGameModeAnnouncement( CAPTURE_THE_FLAG_PRO, "GameModeAnnounce_PS" )
	GameMode_SetGameModeAttackAnnouncement( CAPTURE_THE_FLAG_PRO, "GameModeAnnounce_PS" )
	GameMode_SetGameModeDefendAnnouncement( CAPTURE_THE_FLAG_PRO, "GameModeAnnounce_PS" )
	//GameMode_SetDesc( CAPTURE_THE_FLAG_PRO, "#GAMEMODE_CAPTURE_THE_FLAG_PRO_HINT" ) // TODO: is this still needed for scoreboard? anwyay to use attack/defend desc?
	GameMode_SetAttackDesc( CAPTURE_THE_FLAG_PRO, "#GAMEMODE_CAPTURE_THE_FLAG_PRO_ATTACK_HINT" )
	GameMode_SetDefendDesc( CAPTURE_THE_FLAG_PRO, "#GAMEMODE_CAPTURE_THE_FLAG_PRO_DEFEND_HINT" )
	GameMode_SetIcon( CAPTURE_THE_FLAG_PRO, "../ui/menu/playlist/ctf" )
	GameMode_AddServerScript( CAPTURE_THE_FLAG_PRO, "mp/_gamemode_ctf_pro" )
	GameMode_AddClientScript( CAPTURE_THE_FLAG_PRO, "client/cl_capture_the_flag" )
	GameMode_AddSharedScript( CAPTURE_THE_FLAG_PRO, "_capture_the_flag_shared" )
	GameMode_AddSharedDialogueScript( CAPTURE_THE_FLAG_PRO, "_gamemode_ctf_dialogue" )
	GameMode_SetDefaultScoreLimits( CAPTURE_THE_FLAG_PRO, 0, 6 )
	GameMode_SetDefaultTimeLimits( CAPTURE_THE_FLAG_PRO, 0, 3 )
	
	GameMode_Create( FFA )
	GameMode_SetName( FFA, "#GAMEMODE_FFA" )
	GameMode_SetGameModeAnnouncement( FFA, "GameModeAnnounce_PS" )
	GameMode_SetDesc( FFA, "#GAMEMODE_PILOT_SKIRMISH_HINT" )
	GameMode_SetIcon( FFA, "../ui/scoreboard_secret_logo" )
	GameMode_AddServerScript( FFA, "mp/_gamemode_ps" )
	GameMode_SetDefaultScoreLimits( FFA, 100, 0 )
	GameMode_SetDefaultTimeLimits( FFA, 15, 0 )
	//GameMode_AddServerScript( COOPERATIVE, "mp/_gamemode_coop")
	//GameMode_AddClientScript( COOPERATIVE, "client/cl_gamemode_coop" )
	//GameMode_AddSharedScript( COOPERATIVE, "_gamemode_coop_shared" )

// Don't remove items from this list once the game is in production
// Durango online analytics needs the numbers for each mode to stay the same
// DO NOT CHANGE THESE VALUES AFTER THEY HAVE GONE LIVE
enum eGameModes
{
	invalid =							-1,
	TEAM_DEATHMATCH_ID =				0,
	CAPTURE_POINT_ID =					1,
	ELIMINATION_ID =					2,
	ATDM_ID =							3,
	ATTRITION_ID =						4,
	CAPTURE_THE_FLAG_ID =				5,
	BIG_BROTHER_ID =					6,
	MARKED_FOR_DEATH_ID =				7,
	CAPTURE_THE_TITAN_ID =				8,
	UPLINK_ID =							9,
	LAST_TITAN_STANDING_ID =			10,
	EXFILTRATION_ID =					11,
	TITAN_TAG_ID =						12,
	TITAN_ESCORT_ID =					13,
	WINGMAN_LAST_TITAN_STANDING_ID =	14,
	PILOT_SKIRMISH_ID =					15,
	MARKED_FOR_DEATH_PRO_ID =			16,
	CAPTURE_THE_FLAG_PRO_ID =			17,
	COOPERATIVE_ID =					18,
	SCAVENGER_ID =						19,
	HEIST_ID =							20,
	FFA_ID = 21,
	CAMPAIGN_ID = 22
}

gameModesStringToIdMap <- {}
gameModesStringToIdMap[ TEAM_DEATHMATCH ] 					<- eGameModes.TEAM_DEATHMATCH_ID
gameModesStringToIdMap[ PILOT_SKIRMISH ] 					<- eGameModes.PILOT_SKIRMISH_ID
gameModesStringToIdMap[ CAPTURE_POINT ] 					<- eGameModes.CAPTURE_POINT_ID
gameModesStringToIdMap[ ELIMINATION ] 						<- eGameModes.ELIMINATION_ID
gameModesStringToIdMap[ ATDM ] 								<- eGameModes.ATDM_ID
gameModesStringToIdMap[ ATTRITION ]							<- eGameModes.ATTRITION_ID
gameModesStringToIdMap[ CAPTURE_THE_FLAG ] 					<- eGameModes.CAPTURE_THE_FLAG_ID
gameModesStringToIdMap[ BIG_BROTHER ]	 					<- eGameModes.BIG_BROTHER_ID
gameModesStringToIdMap[ COOPERATIVE ]	 					<- eGameModes.COOPERATIVE_ID
gameModesStringToIdMap[ HEIST ]			 					<- eGameModes.HEIST_ID
gameModesStringToIdMap[ MARKED_FOR_DEATH ]	 				<- eGameModes.MARKED_FOR_DEATH_ID
gameModesStringToIdMap[ SCAVENGER ]		 					<- eGameModes.SCAVENGER_ID
gameModesStringToIdMap[ CAPTURE_THE_TITAN ] 				<- eGameModes.CAPTURE_THE_TITAN_ID
gameModesStringToIdMap[ UPLINK ] 							<- eGameModes.UPLINK_ID
gameModesStringToIdMap[ LAST_TITAN_STANDING ] 				<- eGameModes.LAST_TITAN_STANDING_ID
gameModesStringToIdMap[ EXFILTRATION ] 						<- eGameModes.EXFILTRATION_ID
gameModesStringToIdMap[ TITAN_TAG ] 						<- eGameModes.TITAN_TAG_ID
gameModesStringToIdMap[ TITAN_ESCORT ] 						<- eGameModes.TITAN_ESCORT_ID
gameModesStringToIdMap[ WINGMAN_LAST_TITAN_STANDING ] 		<- eGameModes.WINGMAN_LAST_TITAN_STANDING_ID
gameModesStringToIdMap[ MARKED_FOR_DEATH_PRO ] 				<- eGameModes.MARKED_FOR_DEATH_PRO_ID
gameModesStringToIdMap[ CAPTURE_THE_FLAG_PRO ] 				<- eGameModes.CAPTURE_THE_FLAG_PRO_ID
gameModesStringToIdMap[ FFA ] 				<- eGameModes.FFA_ID
gameModesStringToIdMap[ CAMPAIGN ] 				<- eGameModes.CAMPAIGN_ID

GameMode_VerifyModes()

if ( !IsUI() && IsMultiplayer() )
{

	if ( IsServer() )
	{
		if ( GameRules.GetGameMode() == "" )
			GameRules.SetGameMode( "tdm" )
	}

	GAMETYPE <- GameRules.GetGameMode()
	printl( "GAMETYPE: " + GAMETYPE )

	Assert( GAMETYPE in GAMETYPE_TEXT, "Unsupported gamemode: " + GameRules.GetGameMode() + " is not a valid game mode." )

	level.waveSpawnType <- eWaveSpawnType.DISABLED
}

//--------------------------------------------------
// 					DEBUGGING
//--------------------------------------------------

const DAMAGE_DEBUG_PRINTS_OFF = 0
const DAMAGE_DEBUG_PRINTS_CONSOLE = 1
const DAMAGE_DEBUG_PRINTS_BOTH = 2
const DAMAGE_DEBUG_PRINTS_SCREEN = 3

const USE_NEW_LOADOUT_MENU = 1

//--------------------------------------------------
// 					POINT VALUES
//--------------------------------------------------

const POINTVALUE_MATCH_VICTORY						= 300		// Player wins the match
const POINTVALUE_MATCH_COMPLETION					= 200		// Player completes a match

const POINTVALUE_ROUND_WIN							= 250		// Player wins the round
const POINTVALUE_ROUND_COMPLETION					= 150		// Player compelets a round

// player kills
const POINTVALUE_KILL								= 100		// Player kills another player
const POINTVALUE_ASSIST								= 50		// Player assists in killing a player
const POINTVALUE_KILL_FIRETEAM_AI					= 20		// Player kills a fireteam member that is controlled by AI
const POINTVALUE_KILL_SPECTRE						= 30		// Player kills a spectre
const POINTVALUE_KILL_TITAN							= 200		// Player kills a titan
const POINTVALUE_ASSIST_TITAN						= 100		// Player assists in killing a Titan
const POINTVALUE_KILL_AUTOTITAN						= 200		// Player kills an Auto Titan
const POINTVALUE_ELECTROCUTE_TITAN					= 0			// Player electrocutes a titan
const POINTVALUE_ELECTROCUTE_AUTOTITAN				= 0			// Player electrocutes an Auto Titan
const POINTVALUE_KILL_PILOT							= 100		// Player kills a wallrunner/assassin
const POINTVALUE_KILL_MARVIN						= 5			// Player kills a marvin ( dropped by an operator )
const POINTVALUE_KILL_TURRET						= 50		// Player kills a turret ( dropped by an operator )
const POINTVALUE_KILL_HEAVY_TURRET					= 50		// Player kills a heavy turret
const POINTVALUE_KILL_LIGHT_TURRET					= 25		// Player kills a light turret
const POINTVALUE_KILL_DRONE							= 50		// Player kills a hover drone ( dropped by an operator )

//coop specific minions
const POINTVALUE_COOP_KILL_SUICIDE_SPECTRE				= 15
const POINTVALUE_COOP_KILL_SNIPER_SPECTRE				= 40
const POINTVALUE_COOP_KILL_TITAN						= 100
const POINTVALUE_COOP_ASSIST_TITAN						= 50
const POINTVALUE_COOP_KILL_NUKE_TITAN					= 125
const POINTVALUE_COOP_KILL_MORTAR_TITAN					= 125
const POINTVALUE_COOP_KILL_EMP_TITAN					= 125
const POINTVALUE_COOP_KILL_CLOAKING_DRONE				= 50
const POINTVALUE_COOP_KILL_BUBBLE_SHIELD_GRUNT			= 75
const POINTVALUE_COOP_KILL_BUBBLE_SHIELD_SPECTRE		= 75

const POINTVALUE_AUTOTITAN_MULTIPLIER				= 1.00		// when a player's auto titan kills something, multiply the normal points by this much

// extra points for special events
const POINTVALUE_DROPPOD_KILL						= 0			// Players droppod landed on and killed an enemy
const POINTVALUE_OPERATOR_KILL						= 0			// Player kills an operator drone
const POINTVALUE_SPOTTING_ASSIST					= 0			// Player spots an enemy as operator and someone kills the spotted enemy
const POINTVALUE_HEADSHOT							= 25		// Extra points awarded for the kill being a headshot
const POINTVALUE_NPC_HEADSHOT						= 10
const POINTVALUE_FIRST_STRIKE						= 100		// Extra points awarded for getting the first kill of the match
//const POINTVALUE_PERSONAL_BEST						= 100		// Points for beating a personal best
const POINTVALUE_DOUBLEKILL							= 50		// Extra points awarded for getting 2 kills in quick succession
const POINTVALUE_TRIPLEKILL							= 75		// Extra points awarded for getting 3 kills in quick succession
const POINTVALUE_MEGAKILL							= 100		// Extra points awarded for getting more than 3 kills in quick succession
const POINTVALUE_MAYHEM								= 50		// Extra points awarded for killing 4 or more, ai or pilots, in quick succesion.
const POINTVALUE_ONSLAUGHT							= 150		// Extra points awarded for killing 8 or more, ai or pilots, in quick succesion.
const POINTVALUE_KILLINGSPREE						= 25		// Extra points awarded for killing 3-4 players without dying.
const POINTVALUE_RAMPAGE							= 50		// Extra points awarded for killing 5 or more players without dying.
const POINTVALUE_SHOWSTOPPER						= 50		// Extra points awarded for killing someone on a killing spree or rampage.
const POINTVALUE_REVENGE							= 50		// Extra points awarded for killing the player that just killed you
const POINTVALUE_PILOTEJECTKILL						= 50		// Killing an airborne pilot after he has ejected.
const POINTVALUE_REVENGE_QUICK						= 50		// Extra points awarded for getting revenge, but in a short amout of time
const POINTVALUE_NEMESIS							= 100		// Extra points awarded for killing a player that has killed you many times in a row
const POINTVALUE_DOMINATING							= 50		// Extra points awarded for killing the same player many times in a row without them killing you
const POINTVALUE_COMEBACK							= 100		// Extra points awarded when you keep dying without getting any kills and finally get a kill
const POINTVALUE_TITAN_STEPCRUSH					= 10		// Stepped on enemy as a titan
const POINTVALUE_TITAN_STEPCRUSH_PILOT				= 100		// Stepped on pilot as a Titan
const POINTVALUE_TITAN_MELEE_EXECUTION				= 200		// Synch melee killed an enemy Titan as a Titan
const POINTVALUE_TITAN_MELEE_VS_PILOT				= 100		// Melee punched a enemy human Pilot as a Titan
const POINTVALUE_TITAN_MELEE_VS_HUMANSIZE_NPC		= 10		// Melee killed an enemy human-sized target as a Titan
const POINTVALUE_TITAN_MELEE_VS_TITAN				= 200		// Melee killed an enemy auto Titan as a Titan
const POINTVALUE_KILLED_RODEO_PILOT					= 100		// Killed somebody that was rodeo'ing a friend
const POINTVALUE_RODEO_PILOT_BEATDOWN				= 200		// Killed somebody that was rodeo'ing a friend with Titan melee.
const POINTVALUE_SUPER_USED_SMOKESCREEN				= 0			// used the smokescreen super move
const POINTVALUE_SUPER_USED_ELECTRIC_SMOKESCREEN	= 0			// used the electric smokescreen super move
const POINTVALUE_SUPER_USED_EE_SMOKESCREEN			= 0			// used the explosive electric smokescreen super move
const POINTVALUE_GUIDED_ORBITAL_LASER				= 0			// used the orbital laser super
const POINTVALUE_LEECH_SPECTRE						= 25		// Player leeches a Spectre
const POINTVALUE_DESTROYED_SATCHEL					= 0 		// destroyed an enemy satchel
const POINTVALUE_DESTROYED_PROXIMITY_MINE			= 0 		// destroyed an enemy proximity charge
const POINTVALUE_DESTROYED_LASER_MINE				= 0 		// destroyed an enemy laser mine
const POINTVALUE_VICTORYKILL						= 100		// Getting the last kill on TDM.
const POINTVALUE_KILLED_MVP							= 25 		// Killed the MVP on the other team
const POINTVALUE_STOPPED_COMMON_BURN_CARD			= 25
const POINTVALUE_STOPPED_UNCOMMON_BURN_CARD			= 50
const POINTVALUE_STOPPED_RARE_BURN_CARD				= 100
const POINTVALUE_EARNED_COMMON_BURN_CARD			= 25
const POINTVALUE_EARNED_RARE_BURN_CARD				= 100
const POINTVALUE_USED_BURNCARD_COMMON				= 25
const POINTVALUE_USED_BURNCARD_RARE					= 100
const POINTVALUE_BURNCARD_EXTRA_CREDIT				= 1000

// capture point
const POINTVALUE_HARDPOINT_CAPTURE					= 250		// first person inside the hardpoint gets these points when it's captured
const POINTVALUE_HARDPOINT_CAPTURE_ASSIST			= 100		// everyone else who helped cap gets these points when it's captured
const POINTVALUE_HARDPOINT_NEUTRALIZE				= 150		// first person inside the hardpoint gets these points when it's neutralized
const POINTVALUE_HARDPOINT_NEUTRALIZE_ASSIST		= 75		// everyone else who helped cap gets these points when it's neutralized
const POINTVALUE_HARDPOINT_SIEGE					= 50		// Kill a player inside an enemy hardpoint from outside the hardpoint (nearby)
const POINTVALUE_HARDPOINT_SNIPE					= 50		// Kill a player inside an enemy hardpoint from outside the hardpoint (far)
const POINTVALUE_HARDPOINT_ASSAULT					= 50		// Kill a player inside an enemy hardpoint from inside the hardpoint
const POINTVALUE_HARDPOINT_SIEGE_NPC				= 10		// Kill an NPC inside an enemy hardpoint from outside the hardpoint (nearby)
const POINTVALUE_HARDPOINT_SNIPE_NPC				= 10		// Kill an NPC inside an enemy hardpoint from outside the hardpoint (far)
const POINTVALUE_HARDPOINT_ASSAULT_NPC				= 10		// Kill an NPC inside an enemy hardpoint from inside the hardpoint
const POINTVALUE_HARDPOINT_PERIMETER_DEFENSE		= 50		// Kill a player outside a friendly hardpoint from inside the hardpoint
const POINTVALUE_HARDPOINT_DEFENSE					= 50		// Kill a player inside a friendly hardpoint from inside the hardpoint
const POINTVALUE_HARDPOINT_PERIMETER_DEFENSE_NPC	= 10		// Kill an NPC outside a friendly hardpoint from inside the hardpoint
const POINTVALUE_HARDPOINT_DEFENSE_NPC				= 10		// Kill an NPC inside a friendly hardpoint from inside the hardpoint
const POINTVALUE_HARDPOINT_HOLD						= 25		// Player is in a secure hardpoint owned by their team
const TEAMPOINTVALUE_HARDPOINT_CAPTURE				= 20		// Number of points awarded to the team for capturing a point
const TEAMPOINTVALUE_HARDPOINT_OWNED				= 1			// Number of points awarded to the team while the hardpoint is owned

// last titan standing
const POINTVALUE_ELIMINATE_TITAN					= 450
const POINTVALUE_ELIMINATE_PILOT					= 250

//wingman lts
const POINTVALUE_WLTS_ELIMINATE_TITAN				= 375
const POINTVALUE_WLTS_ELIMINATE_PILOT				= 225
const POINTVALUE_WLTS_KILL_TITAN					= 300
const POINTVALUE_WLTS_ASSIST_TITAN					= 150
const POINTVALUE_WLTS_KILL_AUTOTITAN				= 300
const POINTVALUE_WLTS_KILL_PILOT                    = 150
const POINTVALUE_WLTS_ASSIST						= 75		// Player assists in killing a pilot

// capture the flag
const POINTVALUE_FLAG_CAPTURE						= 400
const POINTVALUE_FLAG_CAPTURE_ASSIST				= 100
const POINTVALUE_FLAG_RETURN						= 100
const POINTVALUE_FLAG_CARRIER_KILL					= 100

const HARDPOINT_RANGED_ASSAULT_DIST					= 2500		// If within this range assault is credited as "siege", if outside the assault is credited as "ranged"
const HARDPOINT_PERIMETER_DEFENSE_RANGE				= 2500		// Players defending their owned hardpoint against victims within this range from them are credited as "perimeter defense"

//scavenger
const POINTVALUE_ORE_PICKUP                         = 5
const POINTVALUE_MEGA_ORE_PICKUP                    = 20
const POINTVALUE_ORE_DEPOSIT                        = 10
const POINTVALUE_ORE_FROM_PLAYER_PICKUP             = 15
const MAX_ORE_PLAYER_CAN_CARRY                      = 10

//Marked For Death
const POINTVALUE_MARKED_KILLED_MARKED               = 350
const POINTVALUE_MARKED_TARGET_KILLED 				= 200
const POINTVALUE_MARKED_ESCORT                      = 100
const POINTVALUE_MARKED_SURVIVAL                    = 200
const POINTVALUE_MARKED_OUTLASTED_ENEMY_MARKED      = 100

//COOPERATIVE
const POINTVALUE_COOP_WAVE_MVP						= 100
const POINTVALUE_COOP_TURRET_KILL_STREAK			= 25
const COOP_TURRET_KILL_STREAK_REQUIREMENT			= 5
const POINTVALUE_COOP_IMMORTAL						= 350
const POINTVALUE_COOP_SURVIVOR						= 100

// Control Panel events
const POINTVALUE_CONTROL_PANEL_ACTIVATE				= 100
const POINTVALUE_CONTROL_PANEL_ACTIVATE_LIGHT		= 50 //Hacking a light turret ( since they generally tend to come in bunches )

const POINTVALUE_FIRST_TITANFALL					= 100
const POINTVALUE_CALLED_IN_TITAN					= 25
const POINTVALUE_CABER_PLANTED						= 0
const POINTVALUE_RODEOD								= 50

const POINTVALUE_RODEOD_FRIEND						= 0
const POINTVALUE_FRIEND_RIDE						= 0
const POINTVALUE_GET_TO_CHOPPER						= 200		// - making it to the dropship as losing team member
const POINTVALUE_HOTZONE_EXTRACT					= 200		// REDUNDANT???- making it to the dropship as losing team member
const POINTVALUE_SOLE_SURVIVOR						= 100		// - sole member from losing team who makes it out alive
const POINTVALUE_FULL_TEAM_EVAC						= 200		// - every member of the losing team who was alive at beginning of epilogue makes it out alive
const POINTVALUE_EVAC_DENIED						= 100		// - destroy the rescue dropship as winning team member
const POINTVALUE_KILLED_ESCAPEE						= 50		// - kill a member of the losing team as a member of the winning team
const POINTVALUE_FULL_TEAM_KILL						= 100		// - Kill everyone on the losing team as a member of the winning team
const POINTVALUE_FULL_TEAM_KILL_SOLO				= 200		// - Singlehandedly kill everyone on losing team as a member of the winning team
const POINTVALUE_FISHINBARREL						= 100		// - Kill everyone on the losing team simultaneously by blowing up the evac ship with them in it

const POINTVALUE_KILLED_RANKED_PILOT				= 100
const POINTVALUE_KILLED_TOP_RANKED_PILOT			= 200
const POINTVALUE_KILLED_TOP_PERF_PILOT				= 200

const POINTVALUE_KILLED_DOGFIGHTER					= 100

const POINTVALUE_KILL_ANGELCITY_SEARCHDRONE			= 5
const POINTVALUE_KILL_FLYER							= 100

//--------------------------------------------------
//				POINT VALUES ( OPERATOR )
//--------------------------------------------------

const POINTVALUE_HARVEST							= 50		// Havester currency generated per timer
const POINTVALUE_RESUPPLY							= 25		// Operator drops a supply droppod. Points awarded each time a player resupplies off it.
const POINTVALUE_HEAL								= 50		// Operator drops a heal droppod. Points awarded each time a player heals off it.
const POINTVALUE_DRONE_GETS_KILL					= 50		// Operator deploys a hover drone. Points each time it kills something.
const POINTVALUE_MARVIN_GETS_KILL					= 30		// Operator deploys marvins. Points awarded each time one of them kills something.
const POINTVALUE_TURRET_GETS_KILL					= 40		// Operator deploys a turret. Points awarded each time it kills something.


//--------------------------------------------------
// 				SCORE EVENT RULES
//--------------------------------------------------

const DOUBLEKILL_REQUIREMENT_KILLS 			= 2			// Number of kills the player must get in quick succession to get a multikill reward
const TRIPLEKILL_REQUIREMENT_KILLS 			= 3			// Number of kills the player must get in quick succession to get a multikill reward
const MEGAKILL_REQUIREMENT_KILLS 			= 4			// Number of kills the player must get in quick succession to get a multikill reward
const CASCADINGKILL_REQUIREMENT_TIME 		= 5.0		// The number of required kills must happen in this amount of time for a multikill reward
const ONSLAUGHT_REQUIREMENT_KILLS 			= 8			// Number of kills, of pilots in grunts, the player must get in quick succession to get an onslaught reward
const MAYHEM_REQUIREMENT_KILLS 				= 4			// Number of kills, of pilots in grunts, the player must get in quick succession to get a mayhem reward
const MAYHEM_REQUIREMENT_TIME 				= 2.0		// The number of required kills must happen in this amount of time for a mayhem reward
const QUICK_REVENGE_TIME_LIMIT 				= 20.0		// When you get the "Revenge" bonus on the player that just killed you, doing so in this amount of time gives you "Quick Revenge" bonus instead
const NEMESIS_KILL_REQUIREMENT 				= 3			// Number of times your nemesis must kill you without you killing them to enable "Nemesis" reward
const DOMINATING_KILL_REQUIREMENT			= 3			// Killing someone who considers you their nemesis.
const RAMPAGE_KILL_REQUIREMENT				= 5			// Killing 5 or more players without dying.
const KILLINGSPREE_KILL_REQUIREMENT			= 3			// Killing 3 or more players without dying.
const COMEBACK_DEATHS_REQUIREMENT 			= 3			// Number of times the player must die with no kills to be eligible for "Comeback" reward
const WORTHIT_REQUIREMENT_TIME 				= 0.5		// The amount of time you have to track if you killed a player and yourself at the same time.


//--------------------------------------------------
//					DROP PODS
//--------------------------------------------------

const DROPPOD_SPEED 						= 2500		// Speed of player drop pods
const DROPPOD_SPEED_BOOST 					= 15000		// Boost speed of player drop pods
const OPERATOR_POD_SPEED 					= 2500		// Speed of operator ability pods
const OPERATOR_POD_SPEED_BOOST 				= 15000		// Boost speed of operator drop pods
const OPERATOR_DROP_POD_DROP_OFFSET			= 2048		// Drop pod drops from this height above the landing origin

//--------------------------------------------------
//					FOG OF WAR
//--------------------------------------------------

const DEFAULT_PLAYER_DROPPOD_REVEAL_RADIUS 	= 100			// Default player drop pod for Fireteams, Titans, and Wallrunners
const DEFAULT_OPERATOR_POD_REVEAL_RADIUS 	= 0				// Default operator pod reveal radius. Overwritten by settings below
const OPERATOR_TARGET_REVEAL_RADIUS			= 220			// Operator crosshair reveal radius
const FIREATEAM_REVEAL_RADIUS 				= 200
const TITAN_REVEAL_RADIUS 					= 300
const WALLRUN_REVEAL_RADIUS 				= 200
const DRONECONTROLLER_REVEAL_RADIUS			= 150			// operator vehicle
const MARVIN_REVEAL_RADIUS 					= 300			// operator deployable marvins
const HOVERDRONE_REVEAL_RADIUS 				= 150			// operator deployable hover drone, NOT the players controllable drone
const TURRET_REVEAL_RADIUS 					= 100			// operator deployable turret
const HARVESTER_REVEAL_RADIUS				= 450			// operator harvest pod
const AMMO_REVEAL_RADIUS					= 650			// operator ammo pod


//--------------------------------------------------
// 			OPERATOR ABILITY ( COOLDOWNS )
//--------------------------------------------------

const NUMBER_OPERATOR_ABILITIES 			= 6				// Don't increase this unless you know what you're doing
const GLOBAL_COOLDOWN_TIME					= 0.25			// Global cooldown timer. When operator uses any ability, all other abilities are inactive for this amount of time
const HARVEST_COOLDOWN 						= 10			// Harvester cooldown ( seconds )
const MARVINS_COOLDOWN 						= 20			// Marvins cooldown ( seconds )
const HEALTHSTATION_COOLDOWN 				= 15			// Health Station cooldown ( seconds )
const AMMOSTATION_COOLDOWN 					= 15			// Ammo Station cooldown ( seconds )
const TURRET_COOLDOWN 						= 10			// Turret cooldown ( seconds )
const HOVERDRONE_COOLDOWN					= 25			// Hover Drone cooldown ( seconds )
const STRIKE_COOLDOWN 						= 60
const OPERATOR_STARTING_POINTS 				= 250			// Turret cooldown ( seconds )


//--------------------------------------------------
// 			OPERATOR ABILITY ( COSTS )
//--------------------------------------------------

// Harvester
const HARVEST_COST 							= 50			// Harvester currency cost
const HARVEST_COST_LEVEL2 					= 200			// Cost to upgrade harvester to level 2
const HARVEST_COST_LEVEL3 					= 500			// Cost to upgrade harvester to level 3

// Marvins
const MARVINS_COST 							= 300			// Marvins currency cost
const MARVINS_REPAIR_COST 					= 25			// Currency cost to repair a damaged marvin
const MARVINS_BUFF_COST 					= 100			// Currency cost to buff the health of a marvin

// Health Station
const HEALTHSTATION_COST 					= 100			// Health Station currency cost

// Ammo Station
const AMMOSTATION_COST 						= 25			// Ammo Station currency cost

// Turret
const TURRET_COST 							= 75			// Turret currency cost

// Satellite Strike
const STRIKE_COST 							= 500			// Turret currency cost

// Hover Drone
const HOVERDRONE_COST 						= 125			// Hover Drone currency cost

// Operator Selection
const OPERATOR_COST_HEAL_FIRETEAM			= 0			// Cost to highlight and heal a wallrunner
const OPERATOR_COST_CLOAK_FIRETEAM			= 0			// Cost to highlight and cloak a wallrunner
const OPERATOR_COST_HEAL_WALLRUNNER			= 0			// Cost to highlight and heal a wallrunner
const OPERATOR_COST_CLOAK_WALLRUNNER		= 0			// Cost to highlight and cloak a wallrunner
const OPERATOR_COST_HEAL_TITAN				= 0			// Cost to highlight and heal a titan
const OPERATOR_COST_CLOAK_TITAN				= 0			// Cost to highlight and cloak a titan

//--------------------------------------------------
// 			OPERATOR ABILITY ( SETTINGS )
//--------------------------------------------------

// Global
const OPERATOR_SELECTION_ENABLED			= 0				// Turn on/off the operator being able to highlight entities and perform actions on them
const ABILITY_COOLDOWN_LAG_ADJUST_MAX_MS 	= 300.0			// When a client uses an operator ability the clients time is sent to the server. The server uses the clients time for the cooldown, but clampped to within this many milleseconds of the servers time.
const OPERATOR_FREE_POINTS_AMOUNT	 		= 25			// Operator gets this many points for free each interval
const OPERATOR_FREE_POINTS_INTERVAL 		= 15.0			// Interval length in seconds in which to give operator free points

// Operator Ability - Ammo Station
const AMMOSTATION_DISPLAYNAME 				= "AMMO BAY"	// Name displayed on operator HUD
const AMMOSTATION_DURATION 					= 30			// Number of seconds the ammo station lasts before automatically destroying itself
const AMMOSTATION_ZONERADIUS 				= 300			// Players must stand within this distance to receive ammo
const AMMOSTATION_INTERVAL					= 1.0			// Number of seconds to wait before trying to fill nearby player ammo again

// Operator Ability - Harvester
const HARVEST_DISPLAYNAME 					= "HARVESTER"	// Name displayed on operator HUD
const HARVEST_DURATION 						= 1600			// Number of seconds the harvester lasts before automatically destroying itself
const HARVEST_INTERVAL		 				= 10.0			// Number of seconds of each harvest interval. Points are awarded after each interval.
const HARVEST_INTERVAL_LEVEL2		 		= 6.0			// Interval time for level 2 harvester
const HARVEST_INTERVAL_LEVEL3		 		= 3.0			// Interval time for level 3 harvester
const HARVEST_HEALTH 						= 1000			// Harvester health. When it takes this much damage it's destroyed

// Operator Ability - Health Station
const HEALTHSTATION_DISPLAYNAME 			= "MED BAY"		// Name displayed on operator HUD
const HEALTHSTATION_DURATION 				= 30			// Number of seconds the health station lasts before automatically destroying itself
const HEALTHSTATION_ZONERADIUS 				= 300			// Players must stand withing this distance to receive health
const HEALTHSTATION_HEAL_FRAC 				= 0.01			// Percent of player max health to regen per interval. 0.01 means 1% heal per tick
const HEALTHSTATION_INTERVAL 				= 0.1			// Number of seconds of heal interval. Every interval all players within the radius get healed based on the heal frac

// Operator Ability - Hover Drone
//const HOVERDRONE_DISPLAYNAME 				= "DRONE"		// Name displayed on operator HUD
//const HOVERDRONE_HEALTH 					= 15			// Amount of health the hover drone has
//const HOVERDRONE_ACCURACY 					= 1.0		// Accuracy for the hover drone gun
//const HOVERDRONE_MOVE_SPEED_SCALE 			= 3.0		// Movement speed multiplier for hover drone

// Operator Ability - Marvins
const MARVINS_DISPLAYNAME 					= "TROOPS"		// Name displayed on operator HUD
const MARVINS_BUFF_MULTIPLIER				= 2.5			// Health buff multiplier. 2.5 means 250% health when buffed

// Operator Ability - Turret
const TURRET_DISPLAYNAME 					= "TURRET"		// Name displayed on operator HUD
const TURRET_ATTACK_RANGE 					= 1500			// Max distance the turret can shoot
const TURRET_ACCURACY_MULTIPLIER			= 1.0			// Accuracy multiplier


// Operator Ability - Strike
const STRIKE_DISPLAYNAME 					= "SATELLITE STRIKE"		// Name displayed on operator HUD


//--------------------------------------------------
// 					OBITUARIES
//--------------------------------------------------

const OBITUARY_ENABLED_PLAYERS				= 1
const OBITUARY_ENABLED_NPC					= 0
const OBITUARY_ENABLED_NPC_TITANS			= 1

const OBITUARY_DURATION						= 6.0					// Amount of seconds an obituary stays on the screen
const OBITUARY_FADE_OUT_DURATION			= 1.0					// Seconds it takes for an obituary to fade out once it starts fading
const OBITUARY_MIN_DURATION					= 2.0					// min time an Obit will display on the screen.
const OBITUARY_SCROLL_TIME					= 0.1					// Number of seconds it takes for an obituary to scroll down when a new one pops up
const OBITUARY_TYPEWRITER_TIME				= 0.1					// Number of seconds it takes for the obituary message to type out when it first pops up

const OBITUARY_COLOR_DEFAULT 				= "255 255 255 255"		// Default text color for obituary messages
const OBITUARY_COLOR_FRIENDLY 				= "49 188 204 255"		// Text color for the player name in the obituary message if friendly
const OBITUARY_COLOR_PARTY 					= "179 255 204 255"		//
const OBITUARY_COLOR_WEAPON	 				= "255 255 255 255"		// Text color for the weapon name involved in the obituary message
const OBITUARY_COLOR_ENEMY 					= "229 86 23 255"		// Text color for the player name in the obituary message if enemy
const OBITUARY_COLOR_LOCALPLAYER 			= "245 245 150 255"		// Text color for the player name in the obituary message if the player is yourself

const OBITUARY_Y							= 80					// Y placement on the screen where obituary messages are displayed
const OBITUARY_SPACING						= 12					// Distance between obituary message lines


//--------------------------------------------------
// 				SCORE SPLASH MESSAGES
//--------------------------------------------------


const SPLASH_X								= 30				// Screen X position offset from center for splash messages
const SPLASH_X_GAP							= 10				// Distance between the point value and the description box
const SPLASH_Y								= 90				// Screen Y position offset from center for splash messages
const SPLASH_DURATION 						= 5.0				// Time in seconds the splash message lasts, this time includes the fade time
const SPLASH_FADE_OUT_DURATION				= 0.5				// Time in seconds to fade the splash message. Must be greater than the total duration of the splash message
const SPLASH_SPACING						= 12				// When multiple splash messages are in the list, this is how far they are spaced on the Y axis
const SPLASH_SCROLL_TIME					= 0.1				// Time in seconds it takes for a splash to scroll to the next line
const SPLASH_TYPEWRITER_TIME				= 0.25				// Time in seconds it takes to spell out the splash message in typewriter fashion
const SPLASH_SHOW_MULTI_SCORE_TOTAL			= 1					// Enable or disable the multiscore total value feature. 0/1 to turn off/on respectively
const SPLASH_MULTI_SCORE_REQUIREMENT		= 1					// Number of splash lines displayed at once to trigger the score total to show
const SPLASH_TOTAL_POS_X					= 50
const SPLASH_TOTAL_POS_Y					= -30
const SPLASH_TEXT_COLOR 					= "173 226 255 180"	// Splash text color
//const SPLASH_TEXT_COLOR 					= "255 255 255 255"	// Splash text color


//--------------------------------------------------
// 				CAPTURE POINT GAMETYPE
//--------------------------------------------------

const TEAM_OWNED_SCORE_FREQ					= 2.0				// How often in seconds to award team points for holding the point over time
const PLAYER_HELD_SCORE_FREQ				= 10.0				// How often in seconds to award points to players for holding the point over time

const CAPTURE_DURATION_CAPTURE				= 10.0				// Number of seconds it takes to capture a control point
const CAPTURE_DURATION_NEUTRALIZE	 		= 10				// Number of seconds it takes to neutralize a control point
const CAPTURE_POINT_COLOR_FRIENDLY 			= "77 142 197 255"	// Color of control point HUD overlays when friendly controlled
const CAPTURE_POINT_COLOR_ENEMY 			= "192 120 77 255"	//252 113 51 240 // Color of control point HUD overlays when enemy controlled
const CAPTURE_POINT_COLOR_NEUTRAL 			= "190 190 190 255"	// Color of control point HUD overlays when neutral
const CAPTURE_POINT_COLOR_FRIENDLY_CAP		= "77 142 197 255"	// while being captured pulse between neutral and this color
const CAPTURE_POINT_COLOR_ENEMY_CAP			= "192 120 77 255"	// while being captured pulse between neutral and this color
const CAPTURE_POINT_ALPHA_MIN_VALUE			= 120				// Alpha value of world icons when at distance
const CAPTURE_POINT_ALPHA_MIN_DISTANCE 		= 2000				// Distance player is from capture zone to draw at min alpha
const CAPTURE_POINT_ALPHA_MAX_VALUE 		= 255				// Alpha value of world icons when close range
const CAPTURE_POINT_ALPHA_MAX_DISTANCE 		= 400				// Distance player is from capture zone to draw at max alpha
const CAPTURE_POINT_CROSSHAIR_DIST_MAX 		= 40000				// Distance squared from crosshairs where world icon shows at normal alpha
const CAPTURE_POINT_CROSSHAIR_DIST_MIN 		= 2500				// Distance squared from crosshairs where world icon shows at max modified alpha
const CAPTURE_POINT_CROSSHAIR_ALPHA_MOD		= 0.5				// Amount to modify world icon alpha when it's over the crosshairs
const CAPTURE_POINT_SLIDE_IN_TIME			= 0.15
const CAPTURE_POINT_SLIDE_OUT_TIME			= 0.1
const CAPTURE_POINT_MINIMAP_ICON_SCALE		= 0.15
const CAPTURE_POINT_TITANS_BREAK_CONTEST	= true

const CAPTURE_POINT_AI_CAP_POWER			= 0.25				// Power of an AI towards capturing a hardpoint
const CAPTURE_POINT_PLAYER_CAP_POWER		= 0.5				// Power of a Player towards capturing a hardpoint
const CAPTURE_POINT_MAX_CAP_POWER			= 3.0				// max total combined cap power

const CAPTURE_POINT_MAX_PULSE_SPEED			= 2.0				// longest pulse time

const CAPTURE_POINT_STATE_UNASSIGNED		= 0					// State at start of match
const CAPTURE_POINT_STATE_HALTED			= 1					// In this state the bar is not moving and the icon is at full oppacity
const CAPTURE_POINT_STATE_CAPPING			= 2					// In this state the bar is moving and the icon pulsate
const CAPTURE_POINT_STATE_CAPTURED			= 3					// TBD what this looks like exatly.
const CAPTURE_POINT_STATE_NEXT				= 4					// State at start of match

const CAPTURE_POINT_ENEMY					= "Contested: %d/%d"
const CAPTURE_POINT_ENEMIES					= "Contested: %d/%d"
const CAPTURE_POINT_EMPTY					= ""
const CAPTURE_POINT_SECURE					= "Secured" // Controlled

//--------------------------------------------------
// 				GAME STATE
//--------------------------------------------------

const GAME_POSTMATCH_LENGTH = 12.0
const GAME_WINNER_DETERMINED_ROUND_WAIT = 10.0
const GAME_WINNER_DETERMINED_FINAL_ROUND_WAIT = 3.0
const GAME_WINNER_DETERMINED_FINAL_ROUND_WITH_ROUND_WINNING_KILL_REPLAY_WAIT = 13.0
const GAME_WINNER_DETERMINED_ROUND_WAIT_WITH_ROUND_WINNING_KILL_REPLAY_WAIT = 14.0

const GAME_WINNER_DETERMINED_WAIT = 6.0
const GAME_EPILOGUE_PLAYER_RESPAWN_LEEWAY = 10.0
const GAME_EPILOGUE_ENDING_LEADUP = 6.0
const GAME_POSTROUND_CLEANUP_WAIT = 5.0
const PREMATCH_COUNTDOWN_SOUND = "Menu_Timer_LobbyCountdown_Tick"
const WAITING_FOR_PLAYERS_COUNTDOWN_SOUND = "Menu_Timer_Tick"

enum eGameState	// These must stay in order from beginning of a match till the end
{
	WaitingForCustomStart, // mainly for e3
	WaitingForPlayers,
	PickLoadout,
	Prematch,
	Playing,
	SuddenDeath,
	SwitchingSides,
	WinnerDetermined,
	Epilogue,
	Postmatch,

	_count_
}

//--------------------------------------------------
// 				FIRETEAM DROPPOD
//--------------------------------------------------

const FIRETEAM_DROPPOD_FORCE_EXIT			= 15				// How long until a Fireteam is forced to leave the droppod


//--------------------------------------------------
// 				MEGA WEAPONS
//--------------------------------------------------

const LOUD_WEAPON_AI_SOUND_RADIUS			= 4000
const LOUD_WEAPON_AI_SOUND_RADIUS_MP		= 5000
const WEAPON_FLYOUT_DEBOUNCE_TIME 			= 2.0				// If a flyout for the same weapon happend within this time it gets suppressed. Fixes ugliness when switching weapons back and fourth quickly
const WEAPON_FLYOUTS_ENABLED				= 1					// Turns on/off weapon title flyouts
const FLYOUT_TITLE_TYPE_TIME 				= 0.2				// Duration of the weapon flyout text typewriter effect
const FLYOUT_POINT_LINE_TIME 				= 0.2				// Time it takes the connecting line to animate to point to the gun
const FLYOUT_SHOW_DURATION 					= 2.0				// Amount of time the weapon flyout stays on screen
const FLYOUT_SHOW_CHALLENGE_DURATION 		= 3.0				// Amount of time the weapon flyout stays on screen
const FLYOUT_FADE_OUT_TIME 					= 0.5				// Time it takes to fade out
const FLYOUT_CONNECTING_LINE_ALPHA 			= 100				// Alpha of the connecting line
const SATCHEL_CLACKER_SOUND					= "Weapon_R1_Clacker.TriggerPull"
const LASER_TRIP_MINE_SOUND					= "PlayerUI.LoadoutSelect"

//--------------------------------------------------
// 				OBJECTIVES
//--------------------------------------------------

const OBJECTIVE_SCREEN_MAX_LOCATIONS	 	= 8

//--------------------------------------------------
// 				ENEMY SPOTTING
//--------------------------------------------------

const DETECTED_COLOR_FILENAME			= "materials/correction/detected.raw"
const DETECTED_TEXT_DURATION			= 5.0
const DETECTED_COLOR_DURATION			= 0.1
const ENEMY_SPOTTED_ONSCREEN_ICON 		= "hud/spotted"
const ENEMY_SPOTTED_OFFSCREEN_ICON 		= "hud/spotted_offscreen"
const ENEMY_SPOTTED_DURATION 			= 5.0
const MAX_SPOTTED 						= 18 // must match elements in HudScripted_mp.res
const DETECTED_ALARM_SOUND				= "PlayerUI.SlotChange"
const ENEMY_SPOTTED_ICON_SNAP_TIME		= 0.15	// time it takes for icon to scale and snap onto target
const ENEMY_SPOTTED_ICON_SIZE_MIN		= 0.5	// scale of marker at max distance
const ENEMY_SPOTTED_ICON_SIZE_MAX		= 1.75	// scale of marker at min distance
const ENEMY_SPOTTED_ICON_ALPHA_MIN		= 150	// alpha of marker at max distance
const ENEMY_SPOTTED_ICON_ALPHA_MAX		= 255	// alpha of marker at min distance
const ENEMY_SPOTTED_ICON_DIST_MIN		= 100	// min distance for scale and alpha settings
const ENEMY_SPOTTED_ICON_DIST_MAX		= 1500	// max distance for scale and alpha settings


//--------------------------------------------------
// 				PLAYER SPAWNING
//--------------------------------------------------
const START_SPAWN_GRACE_PERIOD			= 20.0
const CLASS_CHANGE_GRACE_PERIOD			= 20.0
const WAVE_SPAWN_GRACE_PERIOD			= 3.0
const WAVE_SPAWN_INTERVAL				= 25.0

//--------------------------------------------------
// 				ELIMINATION
//--------------------------------------------------
const ELIM_FIRST_SPAWN_GRACE_PERIOD		= 20.0
const ELIM_TITAN_SPAWN_GRACE_PERIOD		= 30.0

//--------------------------------------------------
// 			TITAN ROCKET POD STATES
//--------------------------------------------------

enum eRocketPodState
{
	reloading
	loaded
	ready
	last_eRocketPodState
}


//--------------------------------------------------
// 				PLAYER HEALTH BARS
//--------------------------------------------------

PLAYER_HEALTH_BAR_CLASSNAMES 							<- {}
PLAYER_HEALTH_BAR_CLASSNAMES["npc_dropship"]			<- true
PLAYER_HEALTH_BAR_CLASSNAMES["npc_turret_mega"]			<- true
PLAYER_HEALTH_BAR_CLASSNAMES["npc_turret_sentry"]		<- true

const HEALTH_BARS_ENABLED_SP							= 1			// Turn on/off health bar drawing
const HEALTH_BARS_ENABLED_MP							= 1			// Turn on/off health bar drawing
const HEALTH_BARS_ENEMIES_ONLY							= 1			// Show health bars for enemy players only?
const HEALTH_BAR_MAX_DISTANCE							= 5000		// Players further away than this wont show a health bar
const HEALTH_BAR_HEAD_OFFSET							= 2		// Offset above the players head where the health bar will be shown


//--------------------------------------------------
//
//--------------------------------------------------
const FIRETEAM_AVENGED_DEBOUNCE							= 5.0


// -- Overdrive --

const OVERDRIVE_FIRE_SOUND = "Player.FireOverdrive"

const DROPSHIP_TIME_LEVEL1 = 2.0

const OVERDRIVE_TIME_LEVEL1 = 20.0
const OVERDRIVE_DAMAGE_LEVEL1 = 1.3

const OVERDRIVE_TIME_LEVEL2 = 20.0
const OVERDRIVE_DAMAGE_LEVEL2 = 1.4
const OVERDRIVE_ARMOR_LEVEL2 = 0.65

const OVERDRIVE_TIME_LEVEL3 = 15.0
const OVERDRIVE_DAMAGE_LEVEL3 = 1.1


// -- smokescreens --

const SMOKESCREEN_DAMAGE_OUTER_RADIUS = 350
const SMOKESCREEN_DAMAGE_INNER_RADIUS = 320

const SMOKESCREEN_FX_OFFSET_TITAN = 200

const SMOKESCREEN_TRACEVOL_HEIGHT_HUMAN = 170
const SMOKESCREEN_TRACEVOL_HEIGHT_TITAN = 230

const SMOKESCREEN_FX_LIFETIME_HUMAN = 9.0
const SMOKESCREEN_FX_LIFETIME_TITAN = 9.0

const ELECTRIC_SMOKESCREEN_FX_LIFETIME_HUMAN = 7.0
const ELECTRIC_SMOKESCREEN_FX_LIFETIME_TITAN = 7.0
const ELECTRIC_SMOKESCREEN_FX_EXTRA_BURN_CARD_LIFETIME = 5.0

const ELECTRIC_SMOKESCREEN_DAMAGE_PER_SEC_HUMAN = 150
const ELECTRIC_SMOKESCREEN_DAMAGE_PER_SEC_TITAN = 2000

const SFX_SMOKE_DEPLOY = "Titan_Offhand_ElectricSmoke_Deploy"
const SFX_SMOKE_DEPLOY_BURN = "Titan_Offhand_ElectricSmoke_Deploy_Amped"
const SFX_SMOKE_LOOP = "Titan_Offhand_ElectricSmoke_Loop"
const SFX_SMOKE_DISPERSE = "Titan_Offhand_ElectricSmoke_Disperse"
const SFX_SMOKE_DAMAGE = "Titan_Offhand_ElectricSmoke_Damage"
const ELECTRIC_SMOKESCREEN_SFX_DAMAGE_1P_Pilot = "Titan_Offhand_ElectricSmoke_Human_Damage_1P"
const ELECTRIC_SMOKESCREEN_SFX_DAMAGE_3P_Pilot = "Titan_Offhand_ElectricSmoke_Human_Damage_3P"
const ELECTRIC_SMOKESCREEN_SFX_DAMAGE_1P_Titan = "Titan_Offhand_ElectricSmoke_Titan_Damage_1P"
const ELECTRIC_SMOKESCREEN_SFX_DAMAGE_3P_Titan = "Titan_Offhand_ElectricSmoke_Titan_Damage_3P"

const SMOKESCREEN_SFX_POPCORN_EXPLOSION = "Weapon_ElectricSmokescreen.Explosion"

const FX_SMOKESCREEN_HUMAN_BURST = "wpn_smokescreen_human"
const FX_ELECTRIC_SMOKESCREEN = "P_wpn_smk_electric"
const FX_ELECTRIC_SMOKESCREEN_BURN = "P_wpn_smk_electric_burn_mod"

//--------------------------------------------------
// 				TITAN HEALTH REGEN
//--------------------------------------------------

const HEALTH_REGEN_TICK_TIME 					= 0.1
const TITAN_HEALTH_REGEN_DELAY					= 7.0		// Titan must wait this long after taking damage before any regen begins
const TITAN_HEALTH_REGEN_TIME					= 14.0		// Time it takes a titan to regen a full health bar
const TITAN_DEFAULT_PERMANANT_DAMAGE_FRAC		= 0.8		// Amount of permanent damage to take relative to damage taken. 0.3 means when titan takes 100 damage, 30 of it will be permanent and non rechargeable

const TITAN_GARAGE_TICK_TIME 					= 1
const TITAN_GARAGE_HEALTH_REGEN					= 150
const TITAN_GARAGE_MAX_HEALTH_REGEN				= 300

const DEFAULT_BOT_TITAN = "titan_atlas"

const MAX_DAMAGE_HISTORY_TIME 					= 12.0
const MAX_NPC_KILL_STEAL_PREVENTION_TIME		= 0.0 //fatal damage from an NPC will check for assisting players and give them the kill

const TITAN_DOOMED_EJECT_PROTECTION_TIME		= 1.5
const TITAN_DOOMED_INVUL_TIME 					= 0.25
const TITAN_EJECT_MAX_PRESS_DELAY				= 0.5
const TITAN_DOOMED_HEALTH						= 5000
const TITAN_DOOMED_MAX_DURATION					= 6.0
const TITAN_DOOMED_MAX_INITIAL_LOSS_FRAC		= 0.25

const HIT_GROUP_HEADSHOT 						= 1			// Hit group box ID for the head on the character models. Used to determine a headsho

const COCKPIT_HEALTHBARS						= 1

//--------------------------------------------------
// 				MELEE
//--------------------------------------------------
const HUMAN_KICK_MELEE_ATTACK_RANGE = 75
const HUMAN_KICK_MELEE_ATTACK_MAX_DOWNWARDS_RANGE = 110 //Extend range slightly when kicking downwards to deal with problem that kick is originating from eye angle and players are taller than they are wide
const HUMAN_MELEE_ATTACK_ASSIST_RANGE_MULTIPLIER_LOW_THRESHOLD = 1.65  //Coupled with HUMAN_MELEE_ATTACK_ASSIST_RANGE_MULTIPLIER_HIGH_THRESHOLD. Player's velocity is GraphCapped among these 2 values, and multiplied with HUMAN_KICK_MELEE_ATTACK_RANGE to give aim assist range
const HUMAN_MELEE_ATTACK_ASSIST_RANGE_MULTIPLIER_HIGH_THRESHOLD = 2.5  //Coupled with HUMAN_MELEE_ATTACK_ASSIST_RANGE_MULTIPLIER_LOW_THRESHOLD. Player's velocity is GraphCapped among these 2 values, and multiplied with HUMAN_KICK_MELEE_ATTACK_RANGE to give aim assist range

const HUMAN_EXECUTION_RANGE = 115
const HUMAN_EXECUTION_ANGLE = 40
const HUMAN_MELEE_ATTACK_ASSIST_ANGLE = 40

//Should move to set file when we get the chance, similar to titan melee damage settings
const HUMAN_MELEE_KICK_ATTACK_DAMAGE = 120
const HUMAN_MELEE_KICK_ATTACK_PUSHBACK_MULTIPLIER = 600

const TITAN_ATTACK_RANGE = 200
const TITAN_EXECUTION_RANGE = 350
const TITAN_EXECUTION_ANGLE = 45
const TITAN_AIMASSIST_MELEE_ATTACK_RANGE = 300
const TITAN_AIMASSIST_MELEE_ATTACK_ANGLE = 35
const TITAN_AIMASSIST_DASH_ATTACK_RANGE = 400
const TITAN_AIMASSIST_DASH_ATTACK_ANGLE = 35
const TITAN_MELEE_MAX_VERTICAL_PUSHBACK = 550.0
//Note: Damage amounts, pushBack and melee lunge speed are defined in set files for the various titans

//--------------------------------------------------
// 				RODEO
//--------------------------------------------------
const RODEO_WALL_CRASH_SPEED_LIMIT_SQUARED = 400000			//Speed limit squared threshold at which titan running into wall plays sound
const RODEO_DAMAGE = 500  //Was used for caber style rodeo and wingman style rodeo, not used currently
const RODEO_WEAPON_DAMAGE_MULTIPLIER = 4 //When rodeoing and firing a non-explosive weapon, we multiply the damage it should do to titans by this amount.
const RODEO_HITBOX_NUMBER = 34 //This is the hitbox assigned for the "brains" of the titan that is exposed during rodeo
const RODEO_DAMAGE_STATE_0_THRESHOLD = 1.0
const RODEO_DAMAGE_STATE_1_THRESHOLD = 0.85
const RODEO_DAMAGE_STATE_2_THRESHOLD = 0.65
const RODEO_DAMAGE_STATE_3_THRESHOLD = 0.40
const RODEO_DAMAGE_STATE_4_THRESHOLD = 0.15

//--------------------------------------------------
// 				CONVERSATIONS
//--------------------------------------------------

const VO_PRIORITY_STORY						= 3000	// will cut off any line playing, even lines of the same priority
const VO_PRIORITY_GAMESTATE					= 1500	// will cut off any line playing, even lines of the same priority
const VO_PRIORITY_ELIMINATION_STATUS		= 1250  // will cut off any line playing, even lines of the same priority
const VO_PRIORITY_GAMEMODE					= 800
const VO_PRIORITY_PLAYERSTATE				= 500

// Priorities for event conversations triggered due to killing one or more enemies etc.
const EVENT_PRIORITY_CALLOUTMAJOR3				= 6
const EVENT_PRIORITY_CALLOUTMAJOR2				= 5
const EVENT_PRIORITY_CALLOUTMAJOR				= 4
const EVENT_PRIORITY_CALLOUT					= 3
const EVENT_PRIORITY_CALLOUTMINOR2				= 2
const EVENT_PRIORITY_CALLOUTMINOR				= 1

// ai are on their own conversation track now
const VO_PRIORITY_AI_CHATTER_HIGH		= 200
const VO_PRIORITY_AI_CHATTER			= 100
const VO_PRIORITY_AI_CHATTER_LOW		= 50
const VO_PRIORITY_AI_CHATTER_LOWEST		= 25

const VO_HARDPOINT_HELP_REQUEST_MINWAIT		= 20 // secs to wait between any help requests
const VO_HARDPOINT_HELP_REQUEST_TIMEOUT		= 40 // secs after the help request that it will still be valid for them to thank the player
const VO_HARDPOINT_PLAYER_THANKS_MINWAIT	= 15 // secs to wait between thanking the player

const VO_AI_CHATTER_TO_PLAYER_MINWAIT		= 60  // how frequently each player can possibly hear NPCs call out other players
const VO_AI_CHATTER_PLAYER_CALLOUT_MAXDIST	= 3500  // units from the AI calling out the enemy that a player needs to be to hear the callout

if ( !( "pilotClass" in level ) )
	level.pilotClass <- "wallrun"


//--------------------------------------------------
// 				INSTAMISSIONS
//--------------------------------------------------
enum instamissionTypes
{
	VIP_EXTRACTION
	FUEL_EXTRACTION
	CAPTURE_MEGA_TURRET
}


//--------------------------------------------------
// 				NPC TITANS
//--------------------------------------------------


const TITAN_KNEEL_DISTANCE = 720
const TITAN_FORCE_KNEEL_DISTANCE = 220
const TITAN_STAND_DISTANCE = 850



// static effect to indicate cockpit damage
const TITAN_COCKPIT_DAMAGE_STATIC = 0

const STANCE_KNEEL = 0
const STANCE_KNEELING = 1 // actively kneeling from stand
const STANCE_STANDING = 2 // actively standing from kneel
const STANCE_STAND = 3


// damage caused by rodeo human cabers
const CABER_DAMAGE_TITAN	= 1800
const CABER_DAMAGE_PILOT	= 90
const CABER_SHOT_MODEL = "models/weapons/caber_shot/caber_shot.mdl"


//--------------------------------------------------
// 				TITAN DAMAGE
//--------------------------------------------------

const TITAN_DAMAGE_STATE_ARMOR_HEALTH			= 0.25	// percentage of titan's total health. Value of 0.1 means each armor piece will have health of 10% titans total health
const TITAN_ADDITIVE_FLINCH_DAMAGE_THRESHOLD	= 150	// incoming damage needs to be higher than this value in order for the Titan to do additive flinch pain anims
const COCKPIT_SPARK_FX_DAMAGE_LIMIT = 100 // damage above this amount plays a white flash on the cockpit screen.

//--------------------------------------------------
// 					ATDM GAMEMODE
//--------------------------------------------------

ATDM_TITAN_TEAM 					<- TEAM_IMC
const ATDM_PILOTS_PER_TITAN 		= 1
const ATDM_TITAN_KILLS_TO_WIN_MULT	= 4

//------------------------------------------------------
// Hit Indicator Threshold
//------------------------------------------------------

const PILOT_HIT_INDICATOR_DAMAGE_LIMIT = 1 //Damage also has to be above this amount to display a critical hit message to the player.



//------------------------------------------------------
// Titan core
//------------------------------------------------------
const TITAN_CORE_PUSHBACK_MULTIPLIER_VS_TITANS = 0.40 // when the core starts, it does a push that is equal to a titan melee punch, multiplied by this number.


//------------------------------------------------------
// Bubble shield
//------------------------------------------------------

const PILOT_BUBBLE_SHIELD_INVULNERABILITY_RANGE = 200
const TITAN_BUBBLE_SHIELD_INVULNERABILITY_RANGE = 170
const TITAN_BUBBLE_SHIELD_DAMAGE_RANGE = 200
const TITAN_BUBBLE_SHIELD_DAMAGE_PULSE = 400

const CTF_FLAG_MODEL = "models/signs/flag_base_pole_ctf.mdl"
const CTF_FLAG_BASE_MODEL = "models/communication/flag_base.mdl"

//------------------------------------------------------
// Round Winning Kill Replay consts
//------------------------------------------------------
const ROUND_WINNING_KILL_REPLAY_STARTUP_WAIT = 3.5
const ROUND_WINNING_KILL_REPLAY_LENGTH_OF_REPLAY = 7.5
const ROUND_WINNING_KILL_REPLAY_SCREEN_FADE_TIME = 4.0
const ROUND_WINNING_KILL_REPLAY_POST_DEATH_TIME = 3.5
