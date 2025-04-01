
playerStatCategories <- []
level.playerStatVars <- {}
level.itemsListForStats <- {}

function main()
{
	Globalize( InitStatsTables )
	Globalize( IsValidStat )
	Globalize( StatToInt )
	Globalize( StatToFloat )
	Globalize( StatToIntAllCompetitiveModesAndMaps )
	Globalize( GetPersistentStatVar )
}

function AddItemsToStatsList( array )
{
	foreach( item in array )
		level.itemsListForStats[ item.ref ] <- true
}

function InitStatsTables()
{
	AddItemsToStatsList( GetAllItemsOfType( itemType.PILOT_PRIMARY ) )
	AddItemsToStatsList( GetAllItemsOfType( itemType.PILOT_SECONDARY ) )
	AddItemsToStatsList( GetAllItemsOfType( itemType.PILOT_SIDEARM ) )
	AddItemsToStatsList( GetAllItemsOfType( itemType.PILOT_SPECIAL ) )
	AddItemsToStatsList( GetAllItemsOfType( itemType.PILOT_ORDNANCE ) )
	AddItemsToStatsList( GetAllItemsOfType( itemType.TITAN_PRIMARY ) )
	AddItemsToStatsList( GetAllItemsOfType( itemType.TITAN_ORDNANCE ) )
	AddItemsToStatsList( GetAllItemsOfType( itemType.TITAN_SPECIAL ) )

	//##############################################
	// 					GAMES STATS
	//##############################################

	AddPersistentStatCategory( "game_stats" )

	AddPersistentStat( "game_stats", "game_joined", 						null, 	"mapStats[%mapname%].gamesJoined[%gamemode%]" )
	AddPersistentStat( "game_stats", "game_completed",						null,	"mapStats[%mapname%].gamesCompleted[%gamemode%]" )
	AddPersistentStat( "game_stats", "game_won", 							null, 	"mapStats[%mapname%].gamesWon[%gamemode%]" )
	AddPersistentStat( "game_stats", "game_lost", 							null, 	"mapStats[%mapname%].gamesLost[%gamemode%]" )
	AddPersistentStat( "game_stats", "mvp", 								null, 	"mapStats[%mapname%].topPlayerOnTeam[%gamemode%]" )
	AddPersistentStat( "game_stats", "top3OnTeam", 							null, 	"mapStats[%mapname%].top3OnTeam[%gamemode%]" )
	AddPersistentStat( "game_stats", "hoursPlayed", 						null,	"mapStats[%mapname%].hoursPlayed[%gamemode%]" )
	AddPersistentStat( "game_stats", "timesScored100AttritionPoints", 		null,	"mapStats[%mapname%].timesScored100AttritionPoints_byMap" )
	AddPersistentStat( "game_stats", "timesScored100AttritionPoints_total", null,	"gameStats.timesScored100AttritionPoints_total" )
	AddPersistentStat( "game_stats", "mode_played", 						null, 	"gameStats.modesPlayed[%gamemode%]" )
	AddPersistentStat( "game_stats", "mode_played_at", 						null, 	"gameStats.mode_played_at" )
	AddPersistentStat( "game_stats", "mode_played_ctf", 					null, 	"gameStats.mode_played_ctf" )
	AddPersistentStat( "game_stats", "mode_played_lts", 					null, 	"gameStats.mode_played_lts" )
	AddPersistentStat( "game_stats", "mode_played_cp", 						null, 	"gameStats.mode_played_cp" )
	AddPersistentStat( "game_stats", "mode_played_tdm", 					null, 	"gameStats.mode_played_tdm" )
	AddPersistentStat( "game_stats", "mode_played_wlts", 					null, 	"gameStats.mode_played_wlts" )
	AddPersistentStat( "game_stats", "mode_played_mfd", 					null, 	"gameStats.mode_played_mfd" )
	AddPersistentStat( "game_stats", "mode_played_coop", 					null, 	"gameStats.mode_played_coop" )
	AddPersistentStat( "game_stats", "mode_won_at", 						null, 	"gameStats.mode_won_at" )
	AddPersistentStat( "game_stats", "mode_won_ctf", 						null, 	"gameStats.mode_won_ctf" )
	AddPersistentStat( "game_stats", "mode_won_lts", 						null, 	"gameStats.mode_won_lts" )
	AddPersistentStat( "game_stats", "mode_won_cp", 						null, 	"gameStats.mode_won_cp" )
	AddPersistentStat( "game_stats", "mode_won_tdm", 						null, 	"gameStats.mode_won_tdm" )
	AddPersistentStat( "game_stats", "mode_won_wlts", 						null, 	"gameStats.mode_won_wlts" )
	AddPersistentStat( "game_stats", "mode_won_mfd", 						null, 	"gameStats.mode_won_mfd" )
	AddPersistentStat( "game_stats", "mode_won_coop", 						null, 	"gameStats.mode_won_coop" )
	AddPersistentStat( "game_stats", "mode_won", 							null, 	"gameStats.modesWon[%gamemode%]" )
	AddPersistentStat( "game_stats", "mvp_total", 							null, 	"gameStats.mvp_total" )
	AddPersistentStat( "game_stats", "game_completed_total",				null,	"gameStats.gamesCompletedTotal" )
	AddPersistentStat( "game_stats", "game_completed_total_campaign",		null,	"gameStats.gamesCompletedTotalCampaign" )
	AddPersistentStat( "game_stats", "games_won_as_imc",					null,	"gameStats.gamesWonAsIMC" )
	AddPersistentStat( "game_stats", "games_won_as_militia",				null,	"gameStats.gamesWonAsMilitia" )
	AddPersistentStat( "game_stats", "games_completed_as_imc",				null,	"gameStats.gamesCompletedAsIMC" )
	AddPersistentStat( "game_stats", "games_completed_as_militia",			null,	"gameStats.gamesCompletedAsMilitia" )
	AddPersistentStat( "game_stats", "pvp_kills_by_mode",					null,	"gameStats.pvpKills[%gamemode%]" )
	AddPersistentStat( "game_stats", "times_kd_2_to_1_by_mode",				null,	"gameStats.timesKillDeathRatio2to1[%gamemode%]" )
	AddPersistentStat( "game_stats", "times_kd_2_to_1_pvp_by_mode",			null,	"gameStats.timesKillDeathRatio2to1_pvp[%gamemode%]" )
	AddPersistentStat( "game_stats", "coop_perfect_waves",					null,	"gameStats.coop_perfect_waves" )

	//##############################################
	// 					TIME STATS
	//##############################################

	AddPersistentStatCategory( "time_stats" )

	AddPersistentStat( "time_stats", "hours_total", 			null, 	"timeStats.total" )
	AddPersistentStat( "time_stats", "hours_as_pilot", 			null, 	"timeStats.asPilot" )
	AddPersistentStat( "time_stats", "hours_dead", 				null, 	"timeStats.dead" )
	AddPersistentStat( "time_stats", "hours_wallhanging", 		null, 	"timeStats.wallhanging" )
	AddPersistentStat( "time_stats", "hours_wallrunning", 		null, 	"timeStats.wallrunning" )
	AddPersistentStat( "time_stats", "hours_inAir", 			null, 	"timeStats.inAir" )
	AddPersistentStat( "time_stats", "hours_as_titan", 			null, 	"timeStats.asTitanTotal" )
	AddPersistentStat( "time_stats", "hours_as_titan_stryder",	null,	"timeStats.asTitan[titan_stryder]" )
	AddPersistentStat( "time_stats", "hours_as_titan_atlas", 	null, 	"timeStats.asTitan[titan_atlas]" )
	AddPersistentStat( "time_stats", "hours_as_titan_ogre", 	null, 	"timeStats.asTitan[titan_ogre]" )

	//##############################################
	// 				DISTANCE STATS
	//##############################################

	AddPersistentStatCategory( "distance_stats" )

	AddPersistentStat( "distance_stats", "total", 			null, 	"distanceStats.total" )
	AddPersistentStat( "distance_stats", "asPilot", 		null, 	"distanceStats.asPilot" )
	AddPersistentStat( "distance_stats", "wallrunning", 	null, 	"distanceStats.wallrunning" )
	AddPersistentStat( "distance_stats", "inAir", 			null, 	"distanceStats.inAir" )
	AddPersistentStat( "distance_stats", "ziplining", 		null, 	"distanceStats.ziplining" )
	AddPersistentStat( "distance_stats", "onFriendlyTitan", null, 	"distanceStats.onFriendlyTitan" )
	AddPersistentStat( "distance_stats", "onEnemyTitan", 	null, 	"distanceStats.onEnemyTitan" )
	AddPersistentStat( "distance_stats", "asTitan", 		null, 	"distanceStats.asTitanTotal" )
	AddPersistentStat( "distance_stats", "asTitan_stryder", null, 	"distanceStats.asTitan[titan_stryder]" )
	AddPersistentStat( "distance_stats", "asTitan_atlas", 	null, 	"distanceStats.asTitan[titan_atlas]" )
	AddPersistentStat( "distance_stats", "asTitan_ogre", 	null, 	"distanceStats.asTitan[titan_ogre]" )

	//##############################################
	//				WEAPON STATS
	//##############################################

	AddPersistentStatCategory( "weapon_stats" )

	foreach( ref, val in level.itemsListForStats )
	{
		AddPersistentStat( "weapon_stats", "hoursUsed", 	ref,	"weaponStats[" + ref + "].hoursUsed" )
		AddPersistentStat( "weapon_stats", "hoursEquipped", ref,	"weaponStats[" + ref + "].hoursEquipped" )
		AddPersistentStat( "weapon_stats", "shotsFired", 	ref,	"weaponStats[" + ref + "].shotsFired" )
		AddPersistentStat( "weapon_stats", "shotsHit",		ref,	"weaponStats[" + ref + "].shotsHit" )
		AddPersistentStat( "weapon_stats", "headshots", 	ref,	"weaponStats[" + ref + "].headshots" )
		AddPersistentStat( "weapon_stats", "critHits", 		ref,	"weaponStats[" + ref + "].critHits" )
	}

	//##############################################
	//			KILLS STATS FOR WEAPON
	//##############################################

	AddPersistentStatCategory( "weapon_kill_stats" )

	foreach( ref, val in level.itemsListForStats )
	{
		AddPersistentStat( "weapon_kill_stats", "total", 				ref,	"weaponKillStats[" + ref + "].total" )
		AddPersistentStat( "weapon_kill_stats", "pilots", 				ref,	"weaponKillStats[" + ref + "].pilots" )
		AddPersistentStat( "weapon_kill_stats", "ejecting_pilots", 		ref,	"weaponKillStats[" + ref + "].ejecting_pilots" )
		AddPersistentStat( "weapon_kill_stats", "titansTotal", 			ref,	"weaponKillStats[" + ref + "].titansTotal" )
		AddPersistentStat( "weapon_kill_stats", "spectres", 			ref,	"weaponKillStats[" + ref + "].spectres" )
		AddPersistentStat( "weapon_kill_stats", "marvins", 				ref,	"weaponKillStats[" + ref + "].marvins" )
		AddPersistentStat( "weapon_kill_stats", "grunts", 				ref,	"weaponKillStats[" + ref + "].grunts" )
		AddPersistentStat( "weapon_kill_stats", "titans_stryder",		ref,	"weaponKillStats[" + ref + "].titans[titan_stryder]" )
		AddPersistentStat( "weapon_kill_stats", "titans_atlas", 		ref,	"weaponKillStats[" + ref + "].titans[titan_atlas]" )
		AddPersistentStat( "weapon_kill_stats", "titans_ogre", 			ref,	"weaponKillStats[" + ref + "].titans[titan_ogre]" )
		AddPersistentStat( "weapon_kill_stats", "npcTitans_stryder",	ref,	"weaponKillStats[" + ref + "].npcTitans[titan_stryder]" )
		AddPersistentStat( "weapon_kill_stats", "npcTitans_atlas", 		ref,	"weaponKillStats[" + ref + "].npcTitans[titan_atlas]" )
		AddPersistentStat( "weapon_kill_stats", "npcTitans_ogre", 		ref,	"weaponKillStats[" + ref + "].npcTitans[titan_ogre]" )
	}

	//##############################################
	//			  GENERAL KILLS STATS
	//##############################################

	AddPersistentStatCategory( "kills_stats" )

	AddPersistentStat( "kills_stats", "total", 						null,	"killStats.total" )
	AddPersistentStat( "kills_stats", "totalWhileUsingBurnCard", 	null,	"killStats.totalWhileUsingBurnCard" )
	AddPersistentStat( "kills_stats", "titansWhileTitanBCActive", 	null,	"killStats.titansWhileTitanBCActive" )
	AddPersistentStat( "kills_stats", "totalPVP", 					null,	"killStats.totalPVP" )
	AddPersistentStat( "kills_stats", "pilots", 					null,	"killStats.pilots" )
	AddPersistentStat( "kills_stats", "spectres", 					null,	"killStats.spectres" )
	AddPersistentStat( "kills_stats", "marvins", 					null,	"killStats.marvins" )
	AddPersistentStat( "kills_stats", "grunts", 					null,	"killStats.grunts" )
	AddPersistentStat( "kills_stats", "totalTitans", 				null,	"killStats.totalTitans" )
	AddPersistentStat( "kills_stats", "totalPilots", 				null,	"killStats.totalPilots" )
	AddPersistentStat( "kills_stats", "totalNPC", 					null,	"killStats.totalNPC" )
	AddPersistentStat( "kills_stats", "totalTitansWhileDoomed", 	null,	"killStats.totalTitansWhileDoomed" )
	AddPersistentStat( "kills_stats", "asPilot", 					null,	"killStats.asPilot" )
	AddPersistentStat( "kills_stats", "asTitan_stryder",			null,	"killStats.asTitan[titan_stryder]" )
	AddPersistentStat( "kills_stats", "asTitan_atlas", 				null,	"killStats.asTitan[titan_atlas]" )
	AddPersistentStat( "kills_stats", "asTitan_ogre", 				null,	"killStats.asTitan[titan_ogre]" )
	AddPersistentStat( "kills_stats", "firstStrikes", 				null,	"killStats.firstStrikes" )
	AddPersistentStat( "kills_stats", "ejectingPilots", 			null,	"killStats.ejectingPilots" )
	AddPersistentStat( "kills_stats", "whileEjecting", 				null,	"killStats.whileEjecting" )
	AddPersistentStat( "kills_stats", "cloakedPilots", 				null,	"killStats.cloakedPilots" )
	AddPersistentStat( "kills_stats", "whileCloaked", 				null,	"killStats.whileCloaked" )
	AddPersistentStat( "kills_stats", "wallrunningPilots", 			null,	"killStats.wallrunningPilots" )
	AddPersistentStat( "kills_stats", "whileWallrunning", 			null,	"killStats.whileWallrunning" )
	AddPersistentStat( "kills_stats", "wallhangingPilots", 			null,	"killStats.wallhangingPilots" )
	AddPersistentStat( "kills_stats", "whileWallhanging", 			null,	"killStats.whileWallhanging" )
	AddPersistentStat( "kills_stats", "pilotExecution", 			null,	"killStats.pilotExecution" )
	AddPersistentStat( "kills_stats", "pilotExecutePilot", 			null,	"killStats.pilotExecutePilot" )
	AddPersistentStat( "kills_stats", "pilotKickMelee", 			null,	"killStats.pilotKickMelee" )
	AddPersistentStat( "kills_stats", "pilotKickMeleePilot", 		null,	"killStats.pilotKickMeleePilot" )
	AddPersistentStat( "kills_stats", "titanMelee", 				null,	"killStats.titanMelee" )
	AddPersistentStat( "kills_stats", "titanMeleePilot", 			null,	"killStats.titanMeleePilot" )
	AddPersistentStat( "kills_stats", "titanStepCrush", 			null,	"killStats.titanStepCrush" )
	AddPersistentStat( "kills_stats", "titanStepCrushPilot", 		null,	"killStats.titanStepCrushPilot" )
	AddPersistentStat( "kills_stats", "titanExocutionStryder", 		null,	"killStats.titanExocutionStryder" )
	AddPersistentStat( "kills_stats", "titanExocutionAtlas", 		null,	"killStats.titanExocutionAtlas" )
	AddPersistentStat( "kills_stats", "titanExocutionOgre", 		null,	"killStats.titanExocutionOgre" )
	AddPersistentStat( "kills_stats", "titanFallKill", 				null,	"killStats.titanFallKill" )
	AddPersistentStat( "kills_stats", "petTitanKillsFollowMode",	null,	"killStats.petTitanKillsFollowMode" )
	AddPersistentStat( "kills_stats", "petTitanKillsGuardMode",		null,	"killStats.petTitanKillsGuardMode" )
	AddPersistentStat( "kills_stats", "rodeo_total",				null,	"killStats.rodeo_total" )
	AddPersistentStat( "kills_stats", "pilot_headshots_total",		null,	"killStats.pilot_headshots_total" )
	AddPersistentStat( "kills_stats", "evacShips",					null,	"killStats.evacShips" )
	AddPersistentStat( "kills_stats", "flyers",						null,	"killStats.flyers" )
	AddPersistentStat( "kills_stats", "nuclearCore",				null,	"killStats.nuclearCore" )
	AddPersistentStat( "kills_stats", "evacuatingEnemies",			null,	"killStats.evacuatingEnemies" )
	AddPersistentStat( "kills_stats", "exportTrapKills",			null,	"killStats.exportTrapKills" )
	AddPersistentStat( "kills_stats", "coopChallenge_NukeTitan_Kills",			null,	"killStats.coopChallenge_NukeTitan_Kills" )
	AddPersistentStat( "kills_stats", "coopChallenge_MortarTitan_Kills",		null,	"killStats.coopChallenge_MortarTitan_Kills" )
	AddPersistentStat( "kills_stats", "coopChallenge_EmpTitan_Kills",			null,	"killStats.coopChallenge_EmpTitan_Kills" )
	AddPersistentStat( "kills_stats", "coopChallenge_SuicideSpectre_Kills",		null,	"killStats.coopChallenge_SuicideSpectre_Kills" )
	AddPersistentStat( "kills_stats", "coopChallenge_Turret_Kills",				null,	"killStats.coopChallenge_Turret_Kills" )
	AddPersistentStat( "kills_stats", "coopChallenge_CloakDrone_Kills",			null,	"killStats.coopChallenge_CloakDrone_Kills" )
	AddPersistentStat( "kills_stats", "coopChallenge_BubbleShieldGrunt_Kills",	null,	"killStats.coopChallenge_BubbleShieldGrunt_Kills" )
	AddPersistentStat( "kills_stats", "coopChallenge_Dropship_Kills",			null,	"killStats.coopChallenge_Dropship_Kills" )
	AddPersistentStat( "kills_stats", "coopChallenge_Sniper_Kills",				null,	"killStats.coopChallenge_Sniper_Kills" )
	AddPersistentStat( "kills_stats", "ampedVortexKills",						null,	"killStats.ampedVortexKills" )
	AddPersistentStat( "kills_stats", "meleeWhileCloaked",						null,	"killStats.meleeWhileCloaked" )
	AddPersistentStat( "kills_stats", "pilotKillsWhileUsingActiveRadarPulse",	null,	"killStats.pilotKillsWhileUsingActiveRadarPulse" )
	AddPersistentStat( "kills_stats", "titanKillsAsPilot",						null,	"killStats.titanKillsAsPilot" )
	AddPersistentStat( "kills_stats", "pilotKillsWhileStimActive",				null,	"killStats.pilotKillsWhileStimActive" )
	AddPersistentStat( "kills_stats", "pilotKillsAsTitan",						null,	"killStats.pilotKillsAsTitan" )

	//##############################################
	//			  GENERAL DEATHS STATS
	//##############################################

	AddPersistentStatCategory( "deaths_stats" )

	AddPersistentStat( "deaths_stats", "total", 				null,	"deathStats.total" )
	AddPersistentStat( "deaths_stats", "totalPVP", 				null,	"deathStats.totalPVP" )
	AddPersistentStat( "deaths_stats", "asPilot", 				null,	"deathStats.asPilot" )
	AddPersistentStat( "deaths_stats", "asTitan_stryder",		null,	"deathStats.asTitan[titan_stryder]" )
	AddPersistentStat( "deaths_stats", "asTitan_atlas", 		null,	"deathStats.asTitan[titan_atlas]" )
	AddPersistentStat( "deaths_stats", "asTitan_ogre", 			null,	"deathStats.asTitan[titan_ogre]" )
	AddPersistentStat( "deaths_stats", "byPilots", 				null,	"deathStats.byPilots" )
	AddPersistentStat( "deaths_stats", "byTitans_stryder",		null,	"deathStats.byTitans[titan_stryder]" )
	AddPersistentStat( "deaths_stats", "byTitans_atlas", 		null,	"deathStats.byTitans[titan_atlas]" )
	AddPersistentStat( "deaths_stats", "byTitans_ogre", 		null,	"deathStats.byTitans[titan_ogre]" )
	AddPersistentStat( "deaths_stats", "bySpectres",			null,	"deathStats.bySpectres" )
	AddPersistentStat( "deaths_stats", "byGrunts",				null,	"deathStats.byGrunts" )
	AddPersistentStat( "deaths_stats", "byNPCTitans_stryder",	null,	"deathStats.byNPCTitans[titan_stryder]" )
	AddPersistentStat( "deaths_stats", "byNPCTitans_atlas", 	null,	"deathStats.byNPCTitans[titan_atlas]" )
	AddPersistentStat( "deaths_stats", "byNPCTitans_ogre", 		null,	"deathStats.byNPCTitans[titan_ogre]" )
	AddPersistentStat( "deaths_stats", "suicides", 				null,	"deathStats.suicides" )
	AddPersistentStat( "deaths_stats", "whileEjecting", 		null,	"deathStats.whileEjecting" )

	//##############################################
	//			  	  MISC STATS
	//##############################################

	AddPersistentStatCategory( "misc_stats" )

	AddPersistentStat( "misc_stats", "titanFalls", 					null,	"miscStats.titanFalls" )
	AddPersistentStat( "misc_stats", "titanFallsFirst", 			null,	"miscStats.titanFallsFirst" )
	AddPersistentStat( "misc_stats", "titanEmbarks", 				null,	"miscStats.titanEmbarks" )
	AddPersistentStat( "misc_stats", "rodeos", 						null,	"miscStats.rodeos" )
	AddPersistentStat( "misc_stats", "rodeosFromEject", 			null,	"miscStats.rodeosFromEject" )
	AddPersistentStat( "misc_stats", "timesEjected", 				null,	"miscStats.timesEjected" )
	AddPersistentStat( "misc_stats", "timesEjectedNuclear", 		null,	"miscStats.timesEjectedNuclear" )
	AddPersistentStat( "misc_stats", "burnCardsEarned", 			null,	"miscStats.burnCardsEarned" )
	AddPersistentStat( "misc_stats", "burnCardsSpent", 				null,	"miscStats.burnCardsSpent" )
	AddPersistentStat( "misc_stats", "spectreLeeches", 				null,	"miscStats.spectreLeeches" )
	AddPersistentStat( "misc_stats", "spectreLeechesByMap", 		null,	"miscStats.spectreLeechesByMap[%mapname%]" )
	AddPersistentStat( "misc_stats", "evacsAttempted", 				null,	"miscStats.evacsAttempted" )
	AddPersistentStat( "misc_stats", "evacsSurvived", 				null,	"miscStats.evacsSurvived" )
	AddPersistentStat( "misc_stats", "flagsCaptured", 				null,	"miscStats.flagsCaptured" )
	AddPersistentStat( "misc_stats", "flagsReturned", 				null,	"miscStats.flagsReturned" )
	AddPersistentStat( "misc_stats", "arcCannonMultiKills", 		null,	"miscStats.arcCannonMultiKills" )
	AddPersistentStat( "misc_stats", "gruntsConscripted", 			null,	"miscStats.gruntsConscripted" )
	AddPersistentStat( "misc_stats", "hardpointsCaptured", 			null,	"miscStats.hardpointsCaptured" )
	AddPersistentStat( "misc_stats", "challengeTiersCompleted", 	null,	"miscStats.challengeTiersCompleted" )
	AddPersistentStat( "misc_stats", "challengesCompleted", 		null,	"miscStats.challengesCompleted" )
	AddPersistentStat( "misc_stats", "dailyChallengesCompleted",	null,	"miscStats.dailyChallengesCompleted" )
	AddPersistentStat( "misc_stats", "timesLastTitanRemaining",		null,	"miscStats.timesLastTitanRemaining" )
	AddPersistentStat( "misc_stats", "killingSprees",				null,	"miscStats.killingSprees" )
	AddPersistentStat( "misc_stats", "coopChallengesCompleted",		null,	"miscStats.coopChallengesCompleted" )
}

function AddPersistentStatCategory( category )
{
	playerStatCategories.append( category )
	level.playerStatVars[ category ] <- {}
}

function AddPersistentStat( category, alias, weapon, var )
{
	if ( weapon == null )
	{
		Assert( !( alias in level.playerStatVars[ category ] ), "Duplicate stat alias " + alias + " in category " + category )
		level.playerStatVars[ category ][ alias ] <- var
	}
	else
	{
		if ( !( alias in level.playerStatVars[ category ] ) )
			level.playerStatVars[ category ][ alias ] <- {}
		Assert( !( var in level.playerStatVars[ category ][ alias ] ) )
		level.playerStatVars[ category ][ alias ][ weapon ] <- var
	}
}

function IsValidStat( category, alias, weapon )
{
	if ( category == null || alias == null )
		return false

	if ( !( category in level.playerStatVars ) )
		return false

	level.playerStatVars[ category ]

	if ( !( alias in level.playerStatVars[ category ] ) )
		return false

	if ( weapon == null )
		return IsString( level.playerStatVars[ category ][ alias ] )

	return ( weapon in level.playerStatVars[ category ][ alias ] )
}

function GetPersistentStatVar( category, alias, weapon = null )
{
	Assert( category in level.playerStatVars, "Invalid stat category " + category )
	Assert( alias in level.playerStatVars[ category ], "No stat alias " + alias + " in category " + category )

	if ( weapon == null )
	{
		return level.playerStatVars[ category ][ alias ]
	}
	else
	{
		Assert( weapon in level.playerStatVars[ category ][ alias ] )
		return level.playerStatVars[ category ][ alias ][ weapon ]
	}
}

function StatToInt( category, alias, weapon = null, player = null )
{
	if ( !IsUI() )
		Assert( IsValid( player ) )

	local statString = GetPersistentStatVar( category, alias, weapon )

	local value
	if ( IsUI() )
		value = GetPersistentVar( statString )
	else
		value = player.GetPersistentVar( statString )

	return value.tointeger()
}

function StatToFloat( category, alias, weapon = null, player = null )
{
	if ( !IsUI() )
		Assert( IsValid( player ) )

	local statString = GetPersistentStatVar( category, alias, weapon )

	local value
	if ( IsUI() )
		value = GetPersistentVar( statString )
	else
		value = player.GetPersistentVar( statString )

	return value.tofloat()
}

function StatToIntAllCompetitiveModesAndMaps( category, alias, weapon = null, player = null )
{
	if ( !IsUI() )
		Assert( IsValid( player ) )

	local count = 0

	local numMaps = PersistenceGetEnumCount( "maps" )
	local numModes = PersistenceGetEnumCount( "gameModes" )

	local statVarName = GetPersistentStatVar( category, alias, weapon )
	local fixedSaveVar

	for( local mode = 0 ; mode < numModes ; mode++ )
	{
		if ( mode == eGameModes.COOPERATIVE_ID )
			continue

		for( local map = 0 ; map < numMaps ; map++ )
		{
			fixedSaveVar = statVarName
			fixedSaveVar = StatStringReplace( fixedSaveVar, "%mapname%", map )
			fixedSaveVar = StatStringReplace( fixedSaveVar, "%gamemode%", mode )
			count += IsUI() ? GetPersistentVar( fixedSaveVar ) : player.GetPersistentVar( fixedSaveVar )
        }
	}

	return count
}