function main()
{
	Globalize( ScoreEventNameToInteger )
	Globalize( ScoreEventFromName )
	Globalize( ScoreEventFromInteger )
	Globalize( ScoreEventExists )
	//Globalize( RankedScoreEventForMethodOfDeath )
	Globalize( ScoreEventForTitanEntityKilled )
	Globalize( ScoreEventForMethodOfDeath )
	Globalize( ScoreEventForNPCKilled )
	Globalize( CreateScoreEvent )
	Globalize( InflictorOwner )
	Globalize( RankedOverrideSplashColors )

	::SCORE_SPLASH_COLORS_BURNCARDS 	<- { main = BURN_CARD_WEAPON_HUD_COLOR_STRING, glow = BURN_CARD_WEAPON_HUD_GLOW_STRING }
	::SCORE_SPLASH_COLORS_PLAYERKILLS 	<- { main = "255 220 160 255", glow = "200 64 32 255" }
	::SCORE_SPLASH_COLORS_CHALLENGE 	<- { main = "255 215 35 255", glow = "255 235 55 255" }
	::SCORE_SPLASH_COLORS_ATTRITION 	<- { main = "255 255 255 255", glow = "83 151 216 255" }
	::SCORE_SPLASH_COLORS_RANKED 		<- { main = RANKED_SPLASH_COLORS_MAIN_STRING, glow = RANKED_SPLASH_COLORS_GLOW_STRING }

	//::SCORE_SPLASH_COLORS_ATTRITION 	<- { main = "173 226 255 255", glow = "255 255 255 255" }

	level.scoreCustomColors <- {}

	InitScoreEvents()
//	IncludeFile( "_personal_best" )

//	AddPersonalBestLowest( "BestFirstStrike", "Fastest First Strike" )
}


function InitScoreEvents()
{
	level.scoreEventsByName <- {}
	level.scoreEventsByIndex <- {}


	// special score event class.
	IncludeScript( "cScoreEvent" )


	local event

	event = cScoreEvent( "ChallengeCompleted" )
	event.SetPointValue( 0 )
	event.SetSplashText( "#SCORE_EVENT_CHALLENGE_COMPLETED" )
	event.SetXPMultiplierApplies( false )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_CHALLENGE )
	event.SetXPType( XP_TYPE.CHALLENGE )
	event.SetShouldStackDisplay( true )

	event = cScoreEvent( "MatchVictory" )
	event.SetPointValue( POINTVALUE_MATCH_VICTORY )
	event.SetSplashText( "#SCORE_EVENT_VICTORY" )
	event.SetShouldStackDisplay( true )
	event.SetXPType( XP_TYPE.MATCH_VICTORY )

	event = cScoreEvent( "MatchComplete" )
	event.SetPointValue( POINTVALUE_MATCH_COMPLETION )
	event.SetSplashText( "#SCORE_EVENT_COMPLETION" )
	event.SetShouldStackDisplay( true )
	event.SetXPType( XP_TYPE.MATCH_COMPLETED )

	event = cScoreEvent( "NewPlayerBonus" )
	event.SetPointValue( POINTVALUE_MATCH_VICTORY )
	event.SetSplashText( "#SCORE_EVENT_NEW_PLAYER_BONUS" )
	event.SetXPMultiplierApplies( false )
	event.SetShouldStackDisplay( true )
	event.SetXPType( XP_TYPE.NEW_PLAYER_BONUS )

	event = cScoreEvent( "RoundVictory" )
	event.SetPointValue( POINTVALUE_ROUND_WIN )
	event.SetSplashText( "#SCORE_EVENT_ROUND_WIN" )
	event.SetShouldStackDisplay( true )
	event.SetXPType( XP_TYPE.ROUND_WIN )

	event = cScoreEvent( "RoundComplete" )
	event.SetPointValue( POINTVALUE_ROUND_COMPLETION )
	event.SetSplashText( "#SCORE_EVENT_ROUND_COMPLETION" )
	event.SetShouldStackDisplay( true )
	event.SetXPType( XP_TYPE.ROUND_COMPLETE )

	event = cScoreEvent( "Kill" )
	event.SetPointValue( POINTVALUE_KILL )
	event.SetSplashText( "#SCORE_EVENT_KILLED_ENEMY" )
	event.SetShouldStackDisplay( true )
	event.SetXPType( XP_TYPE.NPC_KILL )

	event = cScoreEvent( "GenericKill" ) // more descriptive string than the heavily overused "Kill"
	event.SetPointValue( POINTVALUE_KILL )
	event.SetSplashText( "#SCORE_EVENT_KILLED_ENEMY" )
	event.SetShouldStackDisplay( true )
	event.SetXPType( XP_TYPE.NPC_KILL )

	event = cScoreEvent( "Auto_Pilot_Kill" )
	event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_KILL ) )
	event.SetSplashText( "#SCORE_EVENT_AUTO_TITAN_KILLED_ENEMY" )
	event.SetShouldStackDisplay( true )
	event.SetXPType( XP_TYPE.AUTO_TITAN_KILL )

	event = cScoreEvent( "Flipped_Spectre_Kill" )
	event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_KILL ) )
	event.SetSplashText( "#SCORE_EVENT_SPECTRE_KILLED_ENEMY" )
	event.SetShouldStackDisplay( true )
	event.SetXPType( XP_TYPE.NPC_KILL )

	event = cScoreEvent( "AutoTurret_Kill" )
	event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_KILL ) )
	event.SetSplashText( "#SCORE_EVENT_TURRET_KILLED_ENEMY" )
	event.SetXPType( XP_TYPE.NPC_KILL )

	event = cScoreEvent( "AutoTurret_KillConscript" )
	event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_KILL_FIRETEAM_AI ) )
	event.SetSplashText( "#SCORE_EVENT_TURRET_KILLED_CONSCRIPT" )
	event.SetXPType( XP_TYPE.NPC_KILL )

	event = cScoreEvent( "AerialEscort_Kill" )
	event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_KILL ) )
	event.SetSplashText( "#SCORE_EVENT_AERIAL_ESCORE_KILLED_ENEMY" )
	event.SetXPType( XP_TYPE.NPC_KILL )

	event = cScoreEvent( "Electrocute" )
	event.SetPointValue( POINTVALUE_KILL )
	event.SetSplashText( "#SCORE_EVENT_ELECTROCUTED_ENEMY" )
	event.SetXPType( XP_TYPE.NPC_KILL )

	event = cScoreEvent( "MeleeHumanExecutionVsPilot" )
	event.SetPointValue( POINTVALUE_KILL_PILOT )
	event.SetSplashText( "#SCORE_EVENT_EXECUTED_TARGET" )
	event.SetSplashTextAppendTargetName( true )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )
	event.SetXPType( XP_TYPE.PILOT_KILL )

	event = cScoreEvent( "MeleeHumanAttackVsPilot" )
	event.SetPointValue( POINTVALUE_KILL_PILOT )
	event.SetSplashText( "#SCORE_EVENT_JUMP_KICKED_TARGET" )
	event.SetSplashTextAppendTargetName( true )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )
	event.SetXPType( XP_TYPE.PILOT_KILL )

	event = cScoreEvent( "UsedBurnCard_Common" )
	event.SetPointValue( POINTVALUE_USED_BURNCARD_COMMON )
	event.SetSplashText( "#SCORE_EVENT_SPENT_BURN_CARD" )
	event.SetXPMultiplierApplies( false )
	event.SetXPType( XP_TYPE.BURNCARD_USED )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_BURNCARDS )

	event = cScoreEvent( "UsedBurnCard_Rare" )
	event.SetPointValue( POINTVALUE_USED_BURNCARD_RARE )
	event.SetSplashText( "#SCORE_EVENT_SPENT_RARE_BURN_CARD" )
	event.SetXPMultiplierApplies( false )
	event.SetXPType( XP_TYPE.BURNCARD_USED )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_BURNCARDS )

	event = cScoreEvent( "MarkedKilledMarked" )
	event.SetPointValue( POINTVALUE_MARKED_KILLED_MARKED )
	event.SetSplashText( "#SCORE_EVENT_MARKED_KILLED_MARKED" )
	event.SetXPType( XP_TYPE.SPECIAL )
	event.SetXPMultiplierApplies( true )
	event.SetType( scoreEventType.GAMEMODE )

	event = cScoreEvent( "MarkedTargetKilled" )
	event.SetPointValue( POINTVALUE_MARKED_TARGET_KILLED )
	event.SetSplashText( "#SCORE_EVENT_KILLED_MARKED_TARGET" )
	event.SetXPType( XP_TYPE.SPECIAL )
	event.SetXPMultiplierApplies( true )
	event.SetType( scoreEventType.GAMEMODE )

	event = cScoreEvent( "MarkedEscort" )
	event.SetPointValue( POINTVALUE_MARKED_ESCORT )
	event.SetSplashText( "#SCORE_EVENT_PROTECTED_MARKED_TARGET" )
	event.SetXPType( XP_TYPE.SPECIAL )
	event.SetXPMultiplierApplies( true )
	event.SetType( scoreEventType.GAMEMODE )

	event = cScoreEvent( "MarkedSurvival" )
	event.SetPointValue( POINTVALUE_MARKED_SURVIVAL )
	event.SetSplashText( "#SCORE_EVENT_MARKED_SURVIVAL" )
	event.SetXPType( XP_TYPE.SPECIAL )
	event.SetXPMultiplierApplies( true )
	event.SetType( scoreEventType.GAMEMODE )

	event = cScoreEvent( "MarkedOutlastedEnemyMarked" )
	event.SetPointValue( POINTVALUE_MARKED_OUTLASTED_ENEMY_MARKED )
	event.SetSplashText( "#SCORE_EVENT_MARKED_OUTLASTED_ENEMY_MARK" )
	event.SetXPType( XP_TYPE.SPECIAL )
	event.SetXPMultiplierApplies( true )
	event.SetType( scoreEventType.GAMEMODE )

	//IMC Soldiers
	event = cScoreEvent( "Kill_IMC_Soldier" )
	event.SetPointValue( POINTVALUE_KILL_FIRETEAM_AI )
	event.SetSplashText( "#SCORE_EVENT_KILLED_SOLDIER" )
	event.SetShouldStackDisplay( true )
	event.SetXPType( XP_TYPE.NPC_KILL )

	event = cScoreEvent( "Auto_Pilot_Kill_IMC_Soldier" )
	event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_KILL_FIRETEAM_AI ) )
	event.SetSplashText( "#SCORE_EVENT_AUTO_TITAN_KILLED_SOLDIER" )
	event.SetShouldStackDisplay( true )
	event.SetXPType( XP_TYPE.NPC_KILL )

	event = cScoreEvent( "Flipped_Spectre_Kill_IMC_Soldier" )
	event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_KILL_FIRETEAM_AI ) )
	event.SetSplashText( "#SCORE_EVENT_SPECTRE_KILLED_SOLDIER" )
	event.SetShouldStackDisplay( true )
	event.SetXPType( XP_TYPE.NPC_KILL )

	event = cScoreEvent( "Flipped_Spectre_KillConscript" )
	event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_KILL_FIRETEAM_AI ) )
	event.SetSplashText( "#SCORE_EVENT_SPECTRE_KILLED_SOLDIER" )
	event.SetShouldStackDisplay( true )
	event.SetXPType( XP_TYPE.NPC_KILL )

	event = cScoreEvent( "AutoTurret_Kill_IMC_Soldier" )
	event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_KILL_FIRETEAM_AI ) )
	event.SetSplashText( "#SCORE_EVENT_TURRET_KILLED_SOLDIER" )
	event.SetXPType( XP_TYPE.NPC_KILL )
	event.SetShouldStackDisplay( true )

	event = cScoreEvent( "AerialEscort_Kill_IMC_Soldier" )
	event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_KILL_FIRETEAM_AI ) )
	event.SetSplashText( "#SCORE_EVENT_AERIAL_ESCORT_KILLED_SOLDIER" )
	event.SetXPType( XP_TYPE.NPC_KILL )
	event.SetShouldStackDisplay( true )

	event = cScoreEvent( "MeleeHumanExecutionVs_IMC_Soldier" )
	event.SetPointValue( POINTVALUE_KILL_FIRETEAM_AI )
	event.SetSplashText( "#SCORE_EVENT_EXECUTED_SOLDIER" )
	event.SetXPType( XP_TYPE.NPC_KILL )
	event.SetShouldStackDisplay( true )

	event = cScoreEvent( "MeleeHumanAttackVs_IMC_Soldier" )
	event.SetPointValue( POINTVALUE_KILL_FIRETEAM_AI )
	event.SetSplashText( "#SCORE_EVENT_JUMP_KICKED_SOLDIER" )
	event.SetXPType( XP_TYPE.NPC_KILL )
	event.SetShouldStackDisplay( true )

	event = cScoreEvent( "Electrocute_IMC_Soldier" )
	event.SetPointValue( POINTVALUE_KILL_FIRETEAM_AI )
	event.SetSplashText( "#SCORE_EVENT_ELECTROCUTED_SOLDIER" )
	event.SetXPType( XP_TYPE.NPC_KILL )
	event.SetShouldStackDisplay( true )

	//burn card direct
	event = cScoreEvent( "BurnCard1000" )
	event.SetPointValue( 1000 )
	event.SetSplashText( "#SCORE_EVENT_1000XP" )
	event.SetXPMultiplierApplies( false )
	event.SetXPType( XP_TYPE.BURNCARD_XP )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_BURNCARDS )

	event = cScoreEvent( "BurnCard2000" )
	event.SetPointValue( 2000 )
	event.SetSplashText( "#SCORE_EVENT_2000XP" )
	event.SetXPMultiplierApplies( false )
	event.SetXPType( XP_TYPE.BURNCARD_XP )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_BURNCARDS )

	//militia
	event = cScoreEvent( "KillGrunt" )
	event.SetPointValue( POINTVALUE_KILL_FIRETEAM_AI )
	event.SetSplashText( "#SCORE_EVENT_KILLED_MILITIA" )
	event.SetShouldStackDisplay( true )
	event.SetXPType( XP_TYPE.NPC_KILL )

	event = cScoreEvent( "KillConscript" )
	event.SetPointValue( POINTVALUE_KILL_FIRETEAM_AI )
	event.SetSplashText( "#SCORE_EVENT_KILLED_CONSCRIPT" )
	event.SetShouldStackDisplay( true )
	event.SetXPType( XP_TYPE.NPC_KILL )

	event = cScoreEvent( "Auto_Pilot_KillGrunt" )
	event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_KILL_FIRETEAM_AI ) )
	event.SetSplashText( "#SCORE_EVENT_AUTO_TITAN_KILLED_MILITIA" )
	event.SetShouldStackDisplay( true )
	event.SetXPType( XP_TYPE.AUTO_TITAN_KILL )

	event = cScoreEvent( "Auto_Pilot_KillConscript" )
	event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_KILL_FIRETEAM_AI ) )
	event.SetSplashText( "#SCORE_EVENT_AUTO_TITAN_KILLED_CONSCRIPT" )
	event.SetShouldStackDisplay( true )
	event.SetXPType( XP_TYPE.AUTO_TITAN_KILL )

	event = cScoreEvent( "Flipped_Spectre_KillGrunt" )
	event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_KILL_FIRETEAM_AI ) )
	event.SetSplashText( "#SCORE_EVENT_SPECTRE_KILLED_MILITIA" )
	event.SetShouldStackDisplay( true )
	event.SetXPType( XP_TYPE.NPC_KILL )

	event = cScoreEvent( "AutoTurret_KillGrunt" )
	event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_KILL_FIRETEAM_AI ) )
	event.SetSplashText( "#SCORE_EVENT_TURRET_KILLED_MILITIA" )
	event.SetXPType( XP_TYPE.NPC_KILL )
	event.SetShouldStackDisplay( true )

	event = cScoreEvent( "AerialEscort_KillGrunt" )
	event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_KILL_FIRETEAM_AI ) )
	event.SetSplashText( "#SCORE_EVENT_AERIAL_ESCORT_KILLED_MILITIA" )
	event.SetXPType( XP_TYPE.NPC_KILL )
	event.SetShouldStackDisplay( true )

	event = cScoreEvent( "MeleeHumanExecutionVsGrunt" )
	event.SetPointValue( POINTVALUE_KILL_FIRETEAM_AI )
	event.SetSplashText( "#SCORE_EVENT_EXECUTED_MILITIA" )
	event.SetXPType( XP_TYPE.NPC_KILL )
	event.SetShouldStackDisplay( true )

	event = cScoreEvent( "MeleeHumanAttackVsGrunt" )
	event.SetPointValue( POINTVALUE_KILL_FIRETEAM_AI )
	event.SetSplashText( "#SCORE_EVENT_JUMP_KICKED_MILITIA" )
	event.SetXPType( XP_TYPE.NPC_KILL )
	event.SetShouldStackDisplay( true )

	event = cScoreEvent( "ElectrocuteFireteamAI" )
	event.SetPointValue( POINTVALUE_KILL_FIRETEAM_AI )
	event.SetSplashText( "#SCORE_EVENT_ELECTROCUTED_MILITIA" )
	event.SetXPType( XP_TYPE.NPC_KILL )
	event.SetShouldStackDisplay( true )


	//spectres
	event = cScoreEvent( "KillSpectre" )
	event.SetPointValue( POINTVALUE_KILL_SPECTRE )
	event.SetSplashText( "#SCORE_EVENT_KILLED_SPECTRE" )
	event.SetShouldStackDisplay( true )
	event.SetXPType( XP_TYPE.NPC_KILL )

	event = cScoreEvent( "Auto_Pilot_KillSpectre" )
	event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_KILL_SPECTRE ) )
	event.SetSplashText( "#SCORE_EVENT_AUTO_TITAN_KILLED_SPECTRE" )
	event.SetShouldStackDisplay( true )
	event.SetXPType( XP_TYPE.AUTO_TITAN_KILL )

	event = cScoreEvent( "Flipped_Spectre_KillSpectre" )
	event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_KILL_SPECTRE ) )
	event.SetSplashText( "#SCORE_EVENT_SPECTRE_KILLED_SPECTRE" )
	event.SetShouldStackDisplay( true )
	event.SetXPType( XP_TYPE.NPC_KILL )
	event.SetShouldStackDisplay( true )

	event = cScoreEvent( "AutoTurret_KillSpectre" )
	event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_KILL_SPECTRE ) )
	event.SetSplashText( "#SCORE_EVENT_TURRET_KILLED_SPECTRE" )
	event.SetXPType( XP_TYPE.NPC_KILL )
	event.SetShouldStackDisplay( true )

	event = cScoreEvent( "AerialEscort_KillSpectre" )
	event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_KILL_SPECTRE ) )
	event.SetSplashText( "#SCORE_EVENT_AERIAL_ESCORT_KILLED_SPECTRE" )
	event.SetXPType( XP_TYPE.NPC_KILL )
	event.SetShouldStackDisplay( true )

	event = cScoreEvent( "MeleeHumanExecutionVsSpectre" )
	event.SetPointValue( POINTVALUE_KILL_SPECTRE )
	event.SetSplashText( "#SCORE_EVENT_EXECUTED_SPECTRE" )
	event.SetXPType( XP_TYPE.NPC_KILL )
	event.SetShouldStackDisplay( true )

	event = cScoreEvent( "MeleeHumanAttackVsSpectre" )
	event.SetPointValue( POINTVALUE_KILL_SPECTRE )
	event.SetSplashText( "#SCORE_EVENT_JUMP_KICKED_SPECTRE" )
	event.SetXPType( XP_TYPE.NPC_KILL )
	event.SetShouldStackDisplay( true )

	event = cScoreEvent( "ElectrocuteSpectre" )
	event.SetPointValue( POINTVALUE_KILL_SPECTRE )
	event.SetSplashText( "#SCORE_EVENT_ELECTROCUTED_SPECTRE" )
	event.SetXPType( XP_TYPE.NPC_KILL )
	event.SetShouldStackDisplay( true )

	event = cScoreEvent( "LeechSpectre" )
	event.SetPointValue( POINTVALUE_LEECH_SPECTRE )
	event.SetSplashText( "#SCORE_EVENT_LEECHED_SPECTRE" )
	event.SetXPType( XP_TYPE.HACKING )
	event.SetShouldStackDisplay( true )

	event = cScoreEvent( "KillTitan" )
	event.SetPointValue( POINTVALUE_KILL_TITAN )
	event.SetSplashText( "#SCORE_EVENT_DOOMED_TITAN" )
	event.SetTimeDelay( 1.0 )
	event.SetXPType( XP_TYPE.TITAN_KILL )

	event = cScoreEvent( "KillAtlas" )
	event.SetPointValue( POINTVALUE_KILL_TITAN )
	event.SetSplashText( "#SCORE_EVENT_DOOMED_TITAN" )
	event.SetTimeDelay( 1.0 )
	event.SetConversation( "KillAtlas", EVENT_PRIORITY_CALLOUT )
	event.SetXPType( XP_TYPE.TITAN_KILL )

	event = cScoreEvent( "KillStryder" )
	event.SetPointValue( POINTVALUE_KILL_TITAN )
	event.SetSplashText( "#SCORE_EVENT_DOOMED_TITAN" )
	event.SetTimeDelay( 1.0 )
	event.SetConversation( "KillStryder", EVENT_PRIORITY_CALLOUT )
	event.SetXPType( XP_TYPE.TITAN_KILL )

	event = cScoreEvent( "KillOgre" )
	event.SetPointValue( POINTVALUE_KILL_TITAN )
	event.SetSplashText( "#SCORE_EVENT_DOOMED_TITAN" )
	event.SetTimeDelay( 1.0 )
	event.SetConversation( "KillOgre", EVENT_PRIORITY_CALLOUT )
	event.SetXPType( XP_TYPE.TITAN_KILL )

	event = cScoreEvent( "Auto_Pilot_KillTitan" )
	event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_KILL_TITAN ) )
	event.SetSplashText( "#SCORE_EVENT_AUTO_TITAN_KILLED_TITAN" )
	event.SetTimeDelay( 1.0 )
	event.SetXPType( XP_TYPE.TITAN_KILL )

	event = cScoreEvent( "Flipped_Spectre_KillTitan" )
	event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_KILL_TITAN ) )
	event.SetSplashText( "#SCORE_EVENT_SPECTRE_KILLED_TITAN" )
	event.SetTimeDelay( 1.0 )
	event.SetXPType( XP_TYPE.TITAN_KILL )

	event = cScoreEvent( "AutoTurret_KillTitan" )
	event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_KILL_TITAN ) )
	event.SetSplashText( "#SCORE_EVENT_TURRET_KILLED_TITAN" )
	event.SetTimeDelay( 1.0 )
	event.SetXPType( XP_TYPE.TITAN_KILL )

	event = cScoreEvent( "AerialEscort_KillTitan" )
	event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_KILL_TITAN ) )
	event.SetSplashText( "#SCORE_EVENT_AERIAL_ESCORT_KILLED_TITAN" )
	event.SetTimeDelay( 1.0 )
	event.SetXPType( XP_TYPE.TITAN_KILL )

	event = cScoreEvent( "KillTitan_Auto_Pilot" )
	event.SetPointValue( POINTVALUE_KILL_AUTOTITAN )
	event.SetSplashText( "#SCORE_EVENT_DOOMED_AUTO_TITAN" )
	event.SetTimeDelay( 1.0 )
	event.SetXPType( XP_TYPE.TITAN_KILL )

	event = cScoreEvent( "ElectrocuteTitan" )
	event.SetPointValue( POINTVALUE_ELECTROCUTE_TITAN )
	event.SetSplashText( "#SCORE_EVENT_OVERLOADED_TITAN" )
	event.SetTimeDelay( 1.0 )
	event.SetXPType( XP_TYPE.TITAN_KILL )

	event = cScoreEvent( "ElectrocuteAutoTitan" )
	event.SetPointValue( POINTVALUE_ELECTROCUTE_AUTOTITAN )
	event.SetSplashText( "#SCORE_EVENT_OVERLOADED_AUTO_TITAN" )
	event.SetTimeDelay( 1.0 )
	event.SetXPType( XP_TYPE.TITAN_KILL )

	event = cScoreEvent( "RodeoForceEject" )
	event.SetPointValue( POINTVALUE_KILL_TITAN )
	event.SetSplashText( "#SCORE_EVENT_FORCED_TITAN_EJECT_THROUGH_RODEO" )
	event.SetTimeDelay( 1.0 )
	event.SetXPType( XP_TYPE.TITAN_KILL )

	event = cScoreEvent( "KillPilot" )
	event.SetPointValue( POINTVALUE_KILL_PILOT )
	event.SetSplashText( "#SCORE_EVENT_KILLED_TARGET" )
	event.SetSplashTextAppendTargetName( true )
	event.SetXPType( XP_TYPE.PILOT_KILL )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

/*
	event = cScoreEvent( "KillPilotRanked" )
	event.SetPointValue( POINTVALUE_KILLED_RANKED_PILOT )
	event.SetSplashText( "#SCORE_EVENT_KILLED_TARGET_RANKED" )
	event.SetXPType( XP_TYPE.SPECIAL )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

	event = cScoreEvent( "KillPilotRankedTopRank" )
	event.SetPointValue( POINTVALUE_KILLED_TOP_RANKED_PILOT )
	event.SetSplashText( "#SCORE_EVENT_KILLED_TARGET_RANKED_TOP_RANK" )
	event.SetXPType( XP_TYPE.SPECIAL )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

	event = cScoreEvent( "KillPilotRankedTopPerf" )
	event.SetPointValue( POINTVALUE_KILLED_TOP_PERF_PILOT )
	event.SetSplashText( "#SCORE_EVENT_KILLED_TARGET_RANKED_TOP_PERF" )
	event.SetXPType( XP_TYPE.SPECIAL )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )
*/

	event = cScoreEvent( "Auto_Pilot_KillPilot" )
	event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_KILL_PILOT ) )
	event.SetSplashText( "#SCORE_EVENT_AUTO_TITAN_KILLED_TARGET" )
	event.SetSplashTextAppendTargetName( true )
	event.SetXPType( XP_TYPE.PILOT_KILL )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

	event = cScoreEvent( "Flipped_Spectre_KillPilot" )
	event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_KILL_PILOT ) )
	event.SetSplashText( "#SCORE_EVENT_FLIPPED_SPECTRE_KILLED_TARGET" )
	event.SetSplashTextAppendTargetName( true )
	event.SetXPType( XP_TYPE.PILOT_KILL )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

	event = cScoreEvent( "AutoTurret_KillPilot" )
	event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_KILL_PILOT ) )
	event.SetSplashText( "#SCORE_EVENT_TURRET_KILLED_TARGET" )
	event.SetSplashTextAppendTargetName( true )
	event.SetXPType( XP_TYPE.PILOT_KILL )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

	event = cScoreEvent( "AerialEscort_KillPilot" )
	event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_KILL_PILOT ) )
	event.SetSplashText( "#SCORE_EVENT_AERIAL_ESCORT_KILLED_TARGET" )
	event.SetSplashTextAppendTargetName( true )
	event.SetXPType( XP_TYPE.PILOT_KILL )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

	event = cScoreEvent( "ElectrocutePilot" )
	event.SetPointValue( POINTVALUE_KILL_PILOT )
	event.SetSplashText( "#SCORE_EVENT_ELECTROCUTED_TARGET" )
	event.SetSplashTextAppendTargetName( true )
	event.SetXPType( XP_TYPE.PILOT_KILL )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

	event = cScoreEvent( "TitanWallSmashPilot" )
	event.SetPointValue( POINTVALUE_KILL_PILOT )
	event.SetSplashText( "#SCORE_EVENT_WALL_SMASHED_PILOT" )
	event.SetXPType( XP_TYPE.PILOT_KILL )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

	event = cScoreEvent( "KillLightTurret" )
	event.SetPointValue( POINTVALUE_KILL_LIGHT_TURRET )
	event.SetSplashText( "#SCORE_EVENT_KILLED_LIGHT_TURRET" )
	event.SetXPType( XP_TYPE.NPC_KILL )
	event.SetShouldStackDisplay( true )

	event = cScoreEvent( "KillHeavyTurret" )
	event.SetPointValue( POINTVALUE_KILL_HEAVY_TURRET )
	event.SetSplashText( "#SCORE_EVENT_KILLED_HEAVY_TURRET" )
	event.SetXPType( XP_TYPE.NPC_KILL )

	event = cScoreEvent( "KillHoverDrone" )
	event.SetPointValue( POINTVALUE_KILL_DRONE )
	event.SetSplashText( "#SCORE_EVENT_KILLED_DRONE" )
	event.SetXPType( XP_TYPE.NPC_KILL )

	event = cScoreEvent( "DroppodKill" )
	event.SetPointValue( POINTVALUE_DROPPOD_KILL )
	event.SetSplashText( "#SCORE_EVENT_DROPPOD_SMASH_KILL" )
	event.SetXPType( XP_TYPE.NPC_KILL )

	event = cScoreEvent( "PilotAssist" )
	event.SetPointValue( POINTVALUE_ASSIST )
	event.SetSplashText( "#SCORE_EVENT_PILOT_ASSIST" )
	event.SetXPType( XP_TYPE.PILOT_ASSIST )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )
	event.SetSplashTextAppendTargetName( true )

	event = cScoreEvent( "TitanAssist" )
	event.SetPointValue( POINTVALUE_ASSIST_TITAN )
	event.SetSplashText( "#SCORE_EVENT_TITAN_ASSIST" )
	event.SetXPType( XP_TYPE.TITAN_ASSIST )

	event = cScoreEvent( "Headshot" )
	event.SetPointValue( POINTVALUE_HEADSHOT )
	event.SetXPType( XP_TYPE.ACCURACY )
	event.SetSplashText( "#SCORE_EVENT_HEADSHOT" )
	event.SetShouldStackDisplay( true )

	event = cScoreEvent( "NPCHeadshot" )
	event.SetPointValue( POINTVALUE_NPC_HEADSHOT )
	event.SetXPType( XP_TYPE.ACCURACY )
	event.SetSplashText( "#SCORE_EVENT_HEADSHOT" )
	event.SetShouldStackDisplay( true )

	event = cScoreEvent( "FirstStrike" )
	event.SetPointValue( POINTVALUE_FIRST_STRIKE )
	event.SetSplashText( "#SCORE_EVENT_FIRST_STRIKE" )
	event.SetConversation( "FirstStrike", EVENT_PRIORITY_CALLOUT )
	event.SetXPType( XP_TYPE.FIRST_STRIKE )

	event = cScoreEvent( "DoubleKill" )
	event.SetPointValue( POINTVALUE_DOUBLEKILL )
	event.SetSplashText( "#SCORE_EVENT_DOUBLE_KILL" )
	event.SetConversation( "DoubleKill", EVENT_PRIORITY_CALLOUTMAJOR )
	event.SetXPType( XP_TYPE.KILL_STREAK )

	event = cScoreEvent( "TripleKill" )
	event.SetPointValue( POINTVALUE_TRIPLEKILL )
	event.SetSplashText( "#SCORE_EVENT_TRIPLE_KILL" )
	event.SetConversation( "TripleKill", EVENT_PRIORITY_CALLOUTMAJOR2 )
	event.SetXPType( XP_TYPE.KILL_STREAK )

	event = cScoreEvent( "MegaKill" )
	event.SetPointValue( POINTVALUE_MEGAKILL )
	event.SetSplashText( "#SCORE_EVENT_MEGA_KILL" )
	event.SetConversation( "MegaKill", EVENT_PRIORITY_CALLOUTMAJOR3 )
	event.SetXPType( XP_TYPE.KILL_STREAK )

	event = cScoreEvent( "Mayhem" )
	event.SetPointValue( POINTVALUE_MAYHEM )
	event.SetSplashText( "#SCORE_EVENT_MAYHEM" )
	event.SetXPType( XP_TYPE.KILL_STREAK )
	event.SetShouldStackDisplay( true )

	event = cScoreEvent( "Onslaught" )
	event.SetPointValue( POINTVALUE_ONSLAUGHT )
	event.SetSplashText( "#SCORE_EVENT_ONSLAUGHT" )
	event.SetXPType( XP_TYPE.KILL_STREAK )
	event.SetShouldStackDisplay( true )

	event = cScoreEvent( "Revenge" )
	event.SetPointValue( POINTVALUE_REVENGE )
	event.SetSplashText( "#SCORE_EVENT_REVENGE" )
	event.SetXPType( XP_TYPE.REVENGE )

	event = cScoreEvent( "QuickRevenge" )
	event.SetPointValue( POINTVALUE_REVENGE_QUICK )
	event.SetSplashText( "#SCORE_EVENT_QUICK_REVENGE" )
	event.SetXPType( XP_TYPE.REVENGE )

	event = cScoreEvent( "KillingSpree" )
	event.SetPointValue( POINTVALUE_KILLINGSPREE )
	event.SetSplashText( "#SCORE_EVENT_KILLING_SPREE" )
	event.SetConversation( "KillingSpree", EVENT_PRIORITY_CALLOUTMINOR )
	event.SetXPType( XP_TYPE.KILL_STREAK )

	event = cScoreEvent( "Rampage" )
	event.SetPointValue( POINTVALUE_RAMPAGE )
	event.SetSplashText( "#SCORE_EVENT_RAMPAGE" )
	event.SetConversation( "Rampage", EVENT_PRIORITY_CALLOUTMAJOR )
	event.SetXPType( XP_TYPE.KILL_STREAK )

	event = cScoreEvent( "Showstopper" )
	event.SetPointValue( POINTVALUE_SHOWSTOPPER )
	event.SetSplashText( "#SCORE_EVENT_SHOWSTOPPER" )
	event.SetConversation( "Showstopper", EVENT_PRIORITY_CALLOUTMINOR )
	event.SetXPType( XP_TYPE.SHOWSTOPPER )

	event = cScoreEvent( "PilotEjectKill" )
	event.SetPointValue( POINTVALUE_PILOTEJECTKILL )
	event.SetSplashText( "#SCORE_EVENT_AIRBORNE_KILL" )
	event.SetConversation( "PilotEjectKill", EVENT_PRIORITY_CALLOUTMINOR )
	event.SetXPType( XP_TYPE.EJECT_KILL )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

	event = cScoreEvent( "VictoryKill" )
	event.SetPointValue( POINTVALUE_VICTORYKILL )
	event.SetSplashText( "#SCORE_EVENT_VICTORY_KILL" )
	event.SetXPType( XP_TYPE.VICTORY_KILL )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

	event = cScoreEvent( "KilledMVP" )
	event.SetPointValue( POINTVALUE_KILLED_MVP )
	event.SetSplashText( "#SCORE_EVENT_KILLED_MVP" )
	event.SetXPType( XP_TYPE.SPECIAL )

	event = cScoreEvent( "Nemesis" )
	event.SetPointValue( POINTVALUE_NEMESIS )
	event.SetSplashText( "#SCORE_EVENT_NEMESIS" )
	event.SetConversation( "Nemesis", EVENT_PRIORITY_CALLOUT )
	event.SetXPType( XP_TYPE.NEMESIS )

	event = cScoreEvent( "Dominating" )
	event.SetPointValue( POINTVALUE_DOMINATING )
	event.SetSplashText( "#SCORE_EVENT_DOMINATING" )
	event.SetConversation( "Dominating", EVENT_PRIORITY_CALLOUTMINOR2 )
	event.SetXPType( XP_TYPE.KILL_STREAK )

	event = cScoreEvent( "Comeback" )
	event.SetPointValue( POINTVALUE_COMEBACK )
	event.SetSplashText( "#SCORE_EVENT_COMEBACK" )
	event.SetConversation( "Comeback", EVENT_PRIORITY_CALLOUTMINOR )
	event.SetXPType( XP_TYPE.COMEBACK_KILL )

	event = cScoreEvent( "TitanStepCrush_KillSpectre" )
	event.SetPointValue( POINTVALUE_TITAN_STEPCRUSH + POINTVALUE_KILL_SPECTRE )
	event.SetSplashText( "#SCORE_EVENT_CRUSHED_SPECTRE" )
	event.SetShouldStackDisplay( true )
	event.SetXPType( XP_TYPE.NPC_KILL )

	event = cScoreEvent( "TitanStepCrush_KillConscript" )
	event.SetPointValue( POINTVALUE_TITAN_STEPCRUSH + POINTVALUE_KILL_FIRETEAM_AI )
	event.SetSplashText( "#SCORE_EVENT_CRUSHED_CONSCRIPT" )
	event.SetShouldStackDisplay( true )
	event.SetXPType( XP_TYPE.NPC_KILL )

	event = cScoreEvent( "TitanStepCrush_Kill_IMC_Soldier" )
	event.SetPointValue( POINTVALUE_TITAN_STEPCRUSH + POINTVALUE_KILL_FIRETEAM_AI )
	event.SetSplashText( "#SCORE_EVENT_CRUSHED_SOLDIER" )
	event.SetShouldStackDisplay( true )
	event.SetXPType( XP_TYPE.NPC_KILL )

	event = cScoreEvent( "TitanStepCrush_KillGrunt" )
	event.SetPointValue( POINTVALUE_TITAN_STEPCRUSH + POINTVALUE_KILL_FIRETEAM_AI )
	event.SetSplashText( "#SCORE_EVENT_CRUSHED_MILITIA" )
	event.SetShouldStackDisplay( true )
	event.SetXPType( XP_TYPE.NPC_KILL )

	event = cScoreEvent( "TitanStepCrushPilot" )
	event.SetPointValue( POINTVALUE_TITAN_STEPCRUSH_PILOT + POINTVALUE_KILL_PILOT )
	event.SetSplashText( "#SCORE_EVENT_CRUSHED_TARGET" )
	event.SetSplashTextAppendTargetName( true )
	event.SetConversation( "TitanStepCrush", EVENT_PRIORITY_CALLOUTMINOR )
	event.SetXPType( XP_TYPE.PILOT_KILL )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

	event = cScoreEvent( "TitanMeleeExecution" )
	event.SetPointValue( POINTVALUE_TITAN_MELEE_EXECUTION )
	event.SetSplashText( "#SCORE_EVENT_TERMINATED_TARGET")
	event.SetSplashTextAppendTargetName( true )
	event.SetXPType( XP_TYPE.PILOT_KILL )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

	event = cScoreEvent( "TitanMelee_VsHumanPilot" )
	event.SetPointValue( POINTVALUE_TITAN_MELEE_VS_PILOT )
	event.SetSplashText( "#SCORE_EVENT_PILOT_BEATDOWN" )
	event.SetXPType( XP_TYPE.PILOT_KILL )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

	event = cScoreEvent( "TitanMelee_VsHumanSizedNPC" )
	event.SetPointValue( POINTVALUE_TITAN_MELEE_VS_HUMANSIZE_NPC )
	event.SetSplashText( "#SCORE_EVENT_BEATDOWN" )
	event.SetXPType( XP_TYPE.NPC_KILL )

	event = cScoreEvent( "TitanMelee_VsTitan" )
	event.SetPointValue( POINTVALUE_TITAN_MELEE_VS_TITAN )
	event.SetSplashText( "#SCORE_EVENT_TITAN_BEATDOWN" )
	event.SetXPType( XP_TYPE.TITAN_KILL )

	event = cScoreEvent( "SavedFromRodeo" )
	event.SetPointValue( POINTVALUE_KILLED_RODEO_PILOT )
	event.SetSplashText( "#SCORE_EVENT_KILLED_RODEO_PILOT" )
	event.SetConversation( "RodeoRake", EVENT_PRIORITY_CALLOUTMINOR ) //Playing same conversation as RodeoRake for now, since the lines don't specifically mention pulling the guy off
	event.SetXPType( XP_TYPE.RODEO_RAKE )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

	event = cScoreEvent( "StoppedBurnCardCommon" )
	event.SetPointValue( POINTVALUE_STOPPED_COMMON_BURN_CARD )
	event.SetSplashText( "#SCORE_EVENT_BURN_CARD_CANCELLED" )
	event.SetXPType( XP_TYPE.BURNCARD_STOPPED )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_BURNCARDS )

	event = cScoreEvent( "StoppedBurnCardWeapon" )
	event.SetPointValue( POINTVALUE_STOPPED_COMMON_BURN_CARD )
	event.SetSplashText( "#SCORE_EVENT_BURN_CARD_WEAPON_CANCELLED" )
	event.SetXPType( XP_TYPE.BURNCARD_STOPPED )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_BURNCARDS )

	event = cScoreEvent( "burncard_free_xp" )
	event.SetPointValue( POINTVALUE_BURNCARD_EXTRA_CREDIT )
	event.SetSplashText( "#SCORE_EVENT_BURN_CARD_EXTRA_CREDIT" )
	event.SetXPType( XP_TYPE.BURNCARD_XP )
	event.SetXPMultiplierApplies( false )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_BURNCARDS )

	event = cScoreEvent( "StoppedBurnCardRare" )
	event.SetPointValue( POINTVALUE_STOPPED_RARE_BURN_CARD )
	event.SetSplashText( "#SCORE_EVENT_RARE_BURN_CARD_CANCELLED" )
	event.SetXPType( XP_TYPE.BURNCARD_STOPPED )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_BURNCARDS )

	event = cScoreEvent( "StoppedBurnCardRareWeapon" )
	event.SetPointValue( POINTVALUE_STOPPED_RARE_BURN_CARD )
	event.SetSplashText( "#SCORE_EVENT_RARE_BURN_CARD_WEAPON_CANCELLED" )
	event.SetXPType( XP_TYPE.BURNCARD_STOPPED )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_BURNCARDS )

	event = cScoreEvent( "EarnedBurnCard_TitanCommon" )
	event.SetPointValue( POINTVALUE_EARNED_COMMON_BURN_CARD )
	event.SetSplashText( "#SCORE_EVENT_EARNED_BURN_CARD_TITAN" )
	event.SetXPType( XP_TYPE.BURNCARD_EARNED )
	event.SetXPMultiplierApplies( false )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_BURNCARDS )

	event = cScoreEvent( "EarnedBurnCard_TitanRare" )
	event.SetPointValue( POINTVALUE_EARNED_RARE_BURN_CARD )
	event.SetSplashText( "#SCORE_EVENT_EARNED_RARE_BURN_CARD_TITAN" )
	event.SetXPType( XP_TYPE.BURNCARD_EARNED )
	event.SetXPMultiplierApplies( false )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_BURNCARDS )

	event = cScoreEvent( "EarnedBurnCard_PilotCommon" )
	event.SetPointValue( POINTVALUE_EARNED_COMMON_BURN_CARD )
	event.SetSplashText( "#SCORE_EVENT_EARNED_BURN_CARD_PILOT" )
	event.SetXPType( XP_TYPE.BURNCARD_EARNED )
	event.SetXPMultiplierApplies( false )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_BURNCARDS )

	event = cScoreEvent( "EarnedBurnCard_PilotRare" )
	event.SetPointValue( POINTVALUE_EARNED_RARE_BURN_CARD )
	event.SetSplashText( "#SCORE_EVENT_EARNED_RARE_BURN_CARD_PILOT" )
	event.SetXPType( XP_TYPE.BURNCARD_EARNED )
	event.SetXPMultiplierApplies( false )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_BURNCARDS )

	event = cScoreEvent( "EarnedBurnCard_MarvinCommon" )
	event.SetPointValue( POINTVALUE_EARNED_COMMON_BURN_CARD )
	event.SetSplashText( "#SCORE_EVENT_EARNED_BURN_CARD_MARVIN" )
	event.SetXPType( XP_TYPE.BURNCARD_EARNED )
	event.SetXPMultiplierApplies( false )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_BURNCARDS )

	event = cScoreEvent( "EarnedBurnCard_MarvinRare" )
	event.SetPointValue( POINTVALUE_EARNED_RARE_BURN_CARD )
	event.SetSplashText( "#SCORE_EVENT_EARNED_RARE_BURN_CARD_MARVIN" )
	event.SetXPType( XP_TYPE.BURNCARD_EARNED )
	event.SetXPMultiplierApplies( false )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_BURNCARDS )

	event = cScoreEvent( "EarnedBurnCard_SpectreCommon" )
	event.SetPointValue( POINTVALUE_EARNED_COMMON_BURN_CARD )
	event.SetSplashText( "#SCORE_EVENT_EARNED_BURN_CARD_SPECTRE" )
	event.SetXPType( XP_TYPE.BURNCARD_EARNED )
	event.SetXPMultiplierApplies( false )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_BURNCARDS )

	event = cScoreEvent( "EarnedBurnCard_SpectreRare" )
	event.SetPointValue( POINTVALUE_EARNED_RARE_BURN_CARD )
	event.SetSplashText( "#SCORE_EVENT_EARNED_RARE_BURN_CARD_SPECTRE" )
	event.SetXPType( XP_TYPE.BURNCARD_EARNED )
	event.SetXPMultiplierApplies( false )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_BURNCARDS )

	event = cScoreEvent( "EarnedBurnCard_GruntCommon" )
	event.SetPointValue( POINTVALUE_EARNED_COMMON_BURN_CARD )
	event.SetSplashText( "#SCORE_EVENT_EARNED_BURN_CARD_GRUNT" )
	event.SetXPType( XP_TYPE.BURNCARD_EARNED )
	event.SetXPMultiplierApplies( false )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_BURNCARDS )

	event = cScoreEvent( "EarnedBurnCard_GruntRare" )
	event.SetPointValue( POINTVALUE_EARNED_RARE_BURN_CARD )
	event.SetSplashText( "#SCORE_EVENT_EARNED_RARE_BURN_CARD_GRUNT" )
	event.SetXPType( XP_TYPE.BURNCARD_EARNED )
	event.SetXPMultiplierApplies( false )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_BURNCARDS )

	event = cScoreEvent( "EarnedBurnCard_PackCommon" )
	event.SetPointValue( POINTVALUE_EARNED_COMMON_BURN_CARD )
	event.SetSplashText( "#SCORE_EVENT_EARNED_BURN_CARD_PACK" )
	event.SetXPType( XP_TYPE.BURNCARD_EARNED )
	event.SetXPMultiplierApplies( false )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_BURNCARDS )

	event = cScoreEvent( "EarnedBurnCard_PackRare" )
	event.SetPointValue( POINTVALUE_EARNED_RARE_BURN_CARD )
	event.SetSplashText( "#SCORE_EVENT_EARNED_RARE_BURN_CARD_PACK" )
	event.SetXPType( XP_TYPE.BURNCARD_EARNED )
	event.SetXPMultiplierApplies( false )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_BURNCARDS )

	event = cScoreEvent( "EarnedBurnCard_ChallengeCommon" )
	event.SetPointValue( POINTVALUE_EARNED_COMMON_BURN_CARD )
	event.SetSplashText( "#SCORE_EVENT_EARNED_BURN_CARD_CHALLENGE" )
	event.SetXPType( XP_TYPE.BURNCARD_EARNED )
	event.SetXPMultiplierApplies( false )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_BURNCARDS )

	event = cScoreEvent( "EarnedBurnCard_ChallengeRare" )
	event.SetPointValue( POINTVALUE_EARNED_RARE_BURN_CARD )
	event.SetSplashText( "#SCORE_EVENT_EARNED_RARE_BURN_CARD_CHALLENGE" )
	event.SetXPType( XP_TYPE.BURNCARD_EARNED )
	event.SetXPMultiplierApplies( false )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_BURNCARDS )

	event = cScoreEvent( "EarnedBurnCard_VictoryCommon" )
	event.SetPointValue( POINTVALUE_EARNED_COMMON_BURN_CARD )
	event.SetSplashText( "#SCORE_EVENT_EARNED_BURN_CARD_VICTORY" )
	event.SetXPType( XP_TYPE.BURNCARD_EARNED )
	event.SetXPMultiplierApplies( false )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_BURNCARDS )

	event = cScoreEvent( "EarnedBurnCard_VictoryRare" )
	event.SetPointValue( POINTVALUE_EARNED_RARE_BURN_CARD )
	event.SetSplashText( "#SCORE_EVENT_EARNED_RARE_BURN_CARD_VICTORY" )
	event.SetXPType( XP_TYPE.BURNCARD_EARNED )
	event.SetXPMultiplierApplies( false )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_BURNCARDS )

	event = cScoreEvent( "EarnedBurnCard_EvacCommon" )
	event.SetPointValue( POINTVALUE_EARNED_COMMON_BURN_CARD )
	event.SetSplashText( "#SCORE_EVENT_EARNED_BURN_CARD_EVAC" )
	event.SetXPType( XP_TYPE.BURNCARD_EARNED )
	event.SetXPMultiplierApplies( false )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_BURNCARDS )

	event = cScoreEvent( "EarnedBurnCard_EvacRare" )
	event.SetPointValue( POINTVALUE_EARNED_RARE_BURN_CARD )
	event.SetSplashText( "#SCORE_EVENT_EARNED_RARE_BURN_CARD_EVAC" )
	event.SetXPType( XP_TYPE.BURNCARD_EARNED )
	event.SetXPMultiplierApplies( false )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_BURNCARDS )

	event = cScoreEvent( "EarnedBurnCardCommon" )
	event.SetPointValue( POINTVALUE_EARNED_COMMON_BURN_CARD )
	event.SetSplashText( "#SCORE_EVENT_EARNED_BURN_CARD" )
	event.SetXPType( XP_TYPE.BURNCARD_EARNED )
	event.SetXPMultiplierApplies( false )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_BURNCARDS )

	event = cScoreEvent( "EarnedBurnCardRare" )
	event.SetPointValue( POINTVALUE_EARNED_RARE_BURN_CARD )
	event.SetSplashText( "#SCORE_EVENT_EARNED_RARE_BURN_CARD" )
	event.SetXPType( XP_TYPE.BURNCARD_EARNED )
	event.SetXPMultiplierApplies( false )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_BURNCARDS )

	event = cScoreEvent( "RodeoRake" )
	event.SetPointValue( POINTVALUE_RODEO_PILOT_BEATDOWN )
	event.SetSplashText( "#SCORE_EVENT_RODEO_PILOT_BEATDOWN" )
	event.SetConversation( "RodeoRake", EVENT_PRIORITY_CALLOUTMINOR )
	event.SetXPType( XP_TYPE.RODEO_RAKE )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

	event = cScoreEvent( "Destroyed_Satchel" )
	event.SetPointValue( POINTVALUE_DESTROYED_SATCHEL )
	event.SetSplashText( "#SCORE_EVENT_DESTROYED_SATCHEL_CHARGE" )
	event.SetShouldStackDisplay( true )
	event.SetXPType( XP_TYPE.DESTROYED_EXPLOSIVES )

	event = cScoreEvent( "Destored_Proximity_Mine" )
	event.SetPointValue( POINTVALUE_DESTROYED_PROXIMITY_MINE )
	event.SetSplashText( "#SCORE_EVENT_DESTROYED_PROXIMITY_CHARGE" )
	event.SetShouldStackDisplay( true )
	event.SetXPType( XP_TYPE.DESTROYED_EXPLOSIVES )

	event = cScoreEvent( "Destroyed_Laser_Mine" )
	event.SetPointValue( POINTVALUE_DESTROYED_LASER_MINE )
	event.SetSplashText( "#SCORE_EVENT_DESTROYED_LASER_MINE" )
	event.SetShouldStackDisplay( true )
	event.SetXPType( XP_TYPE.DESTROYED_EXPLOSIVES )

	// Capture Point Gametype specific events

	// Awarded for being the first player in the control zone to cap it
	event = cScoreEvent( "ControlPointCapture" )
	event.SetPointValue( POINTVALUE_HARDPOINT_CAPTURE )
	event.SetPointValueIcon( "hud/operator/currency_icon" )
	event.SetSplashText( "#SCORE_EVENT_HARDPOINT_CAPTURED" )
	event.SetType( scoreEventType.ASSAULT )
	event.SetXPType( XP_TYPE.HARDPOINT_CAPTURE )

	// Awarded to all players inside the control point when it's captured
	event = cScoreEvent( "ControlPointCaptureAssist" )
	event.SetPointValue( POINTVALUE_HARDPOINT_CAPTURE_ASSIST )
	event.SetPointValueIcon( "hud/operator/currency_icon" )
	event.SetSplashText( "#SCORE_EVENT_HARDPOINT_CAPTURE_ASSIST" )
	event.SetType( scoreEventType.ASSAULT )
	event.SetXPType( XP_TYPE.HARDPOINT_ASSIST )

	// Awarded for being the first player in the control zone to neutralize an enemy point
	event = cScoreEvent( "ControlPointNeutralize" )
	event.SetPointValue( POINTVALUE_HARDPOINT_NEUTRALIZE )
	event.SetPointValueIcon( "hud/operator/currency_icon" )
	event.SetSplashText( "#SCORE_EVENT_HARDPOINT_NEUTRALIZED" )
	event.SetType( scoreEventType.ASSAULT )
	event.SetXPType( XP_TYPE.HARDPOINT_NEUTRALIZE )

	// Awarded to all players inside the control point when it's neutralized
	event = cScoreEvent( "ControlPointNeutralizeAssist" )
	event.SetPointValue( POINTVALUE_HARDPOINT_NEUTRALIZE_ASSIST )
	event.SetPointValueIcon( "hud/operator/currency_icon" )
	event.SetSplashText( "#SCORE_EVENT_HARDPOINT_NEUTRALIZE_ASSIST" )
	event.SetType( scoreEventType.ASSAULT )
	event.SetXPType( XP_TYPE.HARDPOINT_ASSIST )

	// Kill a player inside an enemy hardpoint from outside the hardpoint (nearby)
	event = cScoreEvent( "HardpointSiege" )
	event.SetPointValue( POINTVALUE_HARDPOINT_SIEGE )
	event.SetPointValueIcon( "hud/operator/currency_icon" )
	event.SetSplashText( "#SCORE_EVENT_HARDPOINT_SIEGE" )
	event.SetType( scoreEventType.ASSAULT )
	event.SetXPType( XP_TYPE.HARDPOINT_KILL )
	event.SetShouldStackDisplay( true )

	// Kill a player inside an enemy hardpoint from outside the hardpoint (far)
	event = cScoreEvent( "HardpointSnipe" )
	event.SetPointValue( POINTVALUE_HARDPOINT_SNIPE )
	event.SetPointValueIcon( "hud/operator/currency_icon" )
	event.SetSplashText( "#SCORE_EVENT_HARDPOINT_RANGED_SUPPORT" )
	event.SetType( scoreEventType.ASSAULT )
	event.SetXPType( XP_TYPE.HARDPOINT_KILL )
	event.SetShouldStackDisplay( true )

	// Kill a player inside an enemy hardpoint from inside the hardpoint
	event = cScoreEvent( "HardpointAssault" )
	event.SetPointValue( POINTVALUE_HARDPOINT_ASSAULT )
	event.SetPointValueIcon( "hud/operator/currency_icon" )
	event.SetSplashText( "#SCORE_EVENT_HARDPOINT_ASSAULT" )
	event.SetType( scoreEventType.ASSAULT )
	event.SetXPType( XP_TYPE.HARDPOINT_KILL )
	event.SetShouldStackDisplay( true )

	// Kill an NPC inside an enemy hardpoint from outside the hardpoint (nearby)
	event = cScoreEvent( "HardpointSiegeNPC" )
	event.SetPointValue( POINTVALUE_HARDPOINT_SIEGE_NPC )
	event.SetPointValueIcon( "hud/operator/currency_icon" )
	event.SetSplashText( "#SCORE_EVENT_HARDPOINT_SIEGE" )
	event.SetType( scoreEventType.ASSAULT )
	event.SetXPType( XP_TYPE.HARDPOINT_KILL )
	event.SetShouldStackDisplay( true )

	// Kill an NPC inside an enemy hardpoint from outside the hardpoint (far)
	event = cScoreEvent( "HardpointSnipeNPC" )
	event.SetPointValue( POINTVALUE_HARDPOINT_SNIPE_NPC )
	event.SetPointValueIcon( "hud/operator/currency_icon" )
	event.SetSplashText( "#SCORE_EVENT_HARDPOINT_RANGED_SUPPORT" )
	event.SetType( scoreEventType.ASSAULT )
	event.SetXPType( XP_TYPE.HARDPOINT_KILL )
	event.SetShouldStackDisplay( true )

	// Kill an NPC inside an enemy hardpoint from inside the hardpoint
	event = cScoreEvent( "HardpointAssaultNPC" )
	event.SetPointValue( POINTVALUE_HARDPOINT_ASSAULT_NPC )
	event.SetPointValueIcon( "hud/operator/currency_icon" )
	event.SetSplashText( "#SCORE_EVENT_HARDPOINT_ASSAULT" )
	event.SetType( scoreEventType.ASSAULT )
	event.SetXPType( XP_TYPE.HARDPOINT_KILL )
	event.SetShouldStackDisplay( true )

	// Kill a player outside a friendly hardpoint from inside the hardpoint
	event = cScoreEvent( "HardpointPerimeterDefense" )
	event.SetPointValue( POINTVALUE_HARDPOINT_PERIMETER_DEFENSE )
	event.SetPointValueIcon( "hud/operator/currency_icon" )
	event.SetSplashText( "#SCORE_EVENT_HARDPOINT_PERIMETER_DEFENSE" )
	event.SetType( scoreEventType.DEFENSE )
	event.SetXPType( XP_TYPE.HARDPOINT_DEFEND_KILL )
	event.SetShouldStackDisplay( true )

	// Kill a player inside a friendly hardpoint from inside the hardpoint
	event = cScoreEvent( "HardpointDefense" )
	event.SetPointValue( POINTVALUE_HARDPOINT_DEFENSE )
	event.SetPointValueIcon( "hud/operator/currency_icon" )
	event.SetSplashText( "#SCORE_EVENT_HARDPOINT_DEFENSE" )
	event.SetType( scoreEventType.DEFENSE )
	event.SetXPType( XP_TYPE.HARDPOINT_DEFEND_KILL )
	event.SetShouldStackDisplay( true )

	// Kill an NPC outside a friendly hardpoint from inside the hardpoint
	event = cScoreEvent( "HardpointPerimeterDefenseNPC" )
	event.SetPointValue( POINTVALUE_HARDPOINT_PERIMETER_DEFENSE_NPC )
	event.SetPointValueIcon( "hud/operator/currency_icon" )
	event.SetSplashText( "#SCORE_EVENT_HARDPOINT_PERIMETER_DEFENSE" )
	event.SetType( scoreEventType.DEFENSE )
	event.SetXPType( XP_TYPE.HARDPOINT_DEFEND_KILL )
	event.SetShouldStackDisplay( true )

	// Kill an NPC inside a friendly hardpoint from inside the hardpoint
	event = cScoreEvent( "HardpointDefenseNPC" )
	event.SetPointValue( POINTVALUE_HARDPOINT_DEFENSE_NPC )
	event.SetPointValueIcon( "hud/operator/currency_icon" )
	event.SetSplashText( "#SCORE_EVENT_HARDPOINT_DEFENSE" )
	event.SetType( scoreEventType.DEFENSE )
	event.SetXPType( XP_TYPE.HARDPOINT_DEFEND_KILL )
	event.SetShouldStackDisplay( true )

	// Awarded for continuing to hold a secured hardpoint
	event = cScoreEvent( "ControlPointHold" )
	event.SetPointValue( POINTVALUE_HARDPOINT_HOLD )
	event.SetPointValueIcon( "hud/operator/currency_icon" )
	event.SetSplashText( "#SCORE_EVENT_HARDPOINT_HOLD" )
	event.SetType( scoreEventType.DEFENSE )
	event.SetXPType( XP_TYPE.HARDPOINT_DEFEND )
	event.SetShouldStackDisplay( true )

	// Awarded for continuing to hold a secured hardpoint
	event = cScoreEvent( "TitanHold" )
	event.SetPointValueIcon( "hud/operator/currency_icon" )
	event.SetSplashText( "#SCORE_EVENT_TITAN_HOLD" )
	event.SetType( scoreEventType.DEFENSE )
	event.SetXPType( XP_TYPE.HARDPOINT_DEFEND )
	event.SetShouldStackDisplay( true )

	// Capture a flag
	event = cScoreEvent( "FlagCapture" )
	event.SetPointValue( POINTVALUE_FLAG_CAPTURE )
	event.SetPointValueIcon( "hud/operator/currency_icon" )
	event.SetSplashText( "#SCORE_EVENT_FLAG_CAPTURE" )
	event.SetXPType( XP_TYPE.CTF_FLAG_CAPTURE )
	event.SetType( scoreEventType.GAMEMODE )

	// Return a flag
	event = cScoreEvent( "FlagReturn" )
	event.SetPointValue( POINTVALUE_FLAG_RETURN )
	event.SetPointValueIcon( "hud/operator/currency_icon" )
	event.SetSplashText( "#SCORE_EVENT_FLAG_RETURN" )
	event.SetXPType( XP_TYPE.CTF_FLAG_RETURN )
	event.SetType( scoreEventType.GAMEMODE )

	// Kill flag carrier
	event = cScoreEvent( "FlagCarrierKill" )
	event.SetPointValue( POINTVALUE_FLAG_CARRIER_KILL )
	event.SetPointValueIcon( "hud/operator/currency_icon" )
	event.SetSplashText( "#SCORE_EVENT_KILLED_FLAG_CARRIER" )
	event.SetXPType( XP_TYPE.CTF_FLAG_CARRIER_KILL )
	event.SetType( scoreEventType.GAMEMODE )

	// Assist a flag capture
	event = cScoreEvent( "FlagCaptureAssist" )
	event.SetPointValue( POINTVALUE_FLAG_CAPTURE_ASSIST )
	event.SetPointValueIcon( "hud/operator/currency_icon" )
	event.SetSplashText( "#SCORE_EVENT_FLAG_CAPTURE_ASSIST" )
	event.SetXPType( XP_TYPE.SPECIAL )
	event.SetType( scoreEventType.GAMEMODE )

	//  Control Panel scoring events
	event = cScoreEvent( "ControlPanelHeavyTurretActivate" )
	event.SetPointValue( POINTVALUE_CONTROL_PANEL_ACTIVATE )
	event.SetPointValueIcon( "hud/operator/currency_icon" )
	event.SetSplashText( "#SCORE_EVENT_HEAVY_TURRET_ACTIVATED" )
	event.SetXPType( XP_TYPE.HACKING )

	// Scavenger mode scoring
	event = cScoreEvent( "CollectOre" )
	event.SetPointValue( POINTVALUE_ORE_PICKUP )
	event.SetPointValueIcon( "hud/operator/currency_icon" )
	event.SetSplashText( "#SCORE_EVENT_COLLECTED_ORE" )
	event.SetXPType( XP_TYPE.SPECIAL )
	event.SetShouldStackDisplay( true )

	event = cScoreEvent( "DepositOre" )
	event.SetPointValue( POINTVALUE_ORE_DEPOSIT )
	event.SetPointValueIcon( "hud/operator/currency_icon" )
	event.SetSplashText( "#SCORE_EVENT_DEPOSITED_ORE" )
	event.SetXPType( XP_TYPE.SPECIAL )
	event.SetShouldStackDisplay( true )

	event = cScoreEvent( "CollectMegaOre" )
	event.SetPointValue( POINTVALUE_MEGA_ORE_PICKUP )
	event.SetPointValueIcon( "hud/operator/currency_icon" )
	event.SetSplashText( "#SCORE_EVENT_COLLECTED_MEGA_ORE" )
	event.SetXPType( XP_TYPE.SPECIAL )
	event.SetShouldStackDisplay( true )

	event = cScoreEvent( "CollectOreFromPlayer" )
	event.SetPointValue( POINTVALUE_ORE_FROM_PLAYER_PICKUP )
	event.SetPointValueIcon( "hud/operator/currency_icon" )
	event.SetSplashText( "#SCORE_EVENT_COLLECTED_ORE_FROM_PLAYER" )
	event.SetXPType( XP_TYPE.SPECIAL )
	event.SetShouldStackDisplay( true )

	//end scavenger mode scoring

	event = cScoreEvent( "ControlPanelLightTurretActivate" )
	event.SetPointValue( POINTVALUE_CONTROL_PANEL_ACTIVATE_LIGHT )
	event.SetPointValueIcon( "hud/operator/currency_icon" )
	event.SetSplashText( "#SCORE_EVENT_LIGHT_TURRETS_ACTIVATED" )
	event.SetXPType( XP_TYPE.HACKING )
	event.SetShouldStackDisplay( true )

	event = cScoreEvent( "ControlPanelSpectreActivate" )
	event.SetPointValue( POINTVALUE_CONTROL_PANEL_ACTIVATE )
	event.SetPointValueIcon( "hud/operator/currency_icon" )
	event.SetSplashText( "#SCORE_EVENT_SPECTRES_REQUESTED" )
	event.SetXPType( XP_TYPE.HACKING )

	event = cScoreEvent( "ControlPanelFuelPumpActivate" )
	event.SetPointValue( POINTVALUE_CONTROL_PANEL_ACTIVATE )
	event.SetPointValueIcon( "hud/operator/currency_icon" )
	event.SetSplashText( "#SCORE_EVENT_FUEL_PUMP_ACTIVATED" )
	event.SetXPType( XP_TYPE.HACKING )

	event = cScoreEvent( "RodeoEnemyTitan" )
	event.SetPointValue( POINTVALUE_RODEOD )
	event.SetSplashText( "#SCORE_EVENT_RODEOED_ENEMY_TITAN" )
	event.SetXPType( XP_TYPE.RODEO_RIDE )

	event = cScoreEvent( "HitchRide" )
	event.SetPointValue( POINTVALUE_RODEOD_FRIEND )
	event.SetSplashText( "#SCORE_EVENT_HITCH_A_RIDE" )
	event.SetXPType( XP_TYPE.RODEO_RIDE )

	event = cScoreEvent( "GiveRide" )
	event.SetPointValue( POINTVALUE_FRIEND_RIDE )
	event.SetSplashText( "#SCORE_EVENT_GIVE_A_FRIEND_A_LIFT" )
	event.SetXPType( XP_TYPE.RODEO_RIDE )

	event = cScoreEvent( "Titanfall" )
	event.SetPointValue( POINTVALUE_CALLED_IN_TITAN )
	event.SetSplashText( "#SCORE_EVENT_TITANFALL" )
	event.SetShouldStackDisplay( true )
	event.SetXPType( XP_TYPE.TITANFALL )

	event = cScoreEvent( "FirstTitanfall" )
	event.SetPointValue( POINTVALUE_FIRST_TITANFALL )
	event.SetSplashText( "#SCORE_EVENT_FIRST_TITANFALL" )
	event.SetXPType( XP_TYPE.TITANFALL )

//EVAC
	event = cScoreEvent( "GetToChopper" )
	event.SetPointValue( POINTVALUE_GET_TO_CHOPPER )
	event.SetSplashText( "#SCORE_EVENT_GET_TO_THE_CHOPPER" )
	event.SetXPType( XP_TYPE.EPILOGUE_GET_TO_CHOPPER )

	event = cScoreEvent( "HotZoneExtract" )
	event.SetPointValue( POINTVALUE_HOTZONE_EXTRACT )
	event.SetSplashText( "#SCORE_EVENT_HOT_ZONE_EXTRACT" )
	event.SetXPType( XP_TYPE.EPILOGUE_EVAC )

	event = cScoreEvent( "SoleSurvivor" )
	event.SetPointValue( POINTVALUE_SOLE_SURVIVOR )
	event.SetSplashText( "#SCORE_EVENT_SOLE_SURVIVOR" )
	event.SetXPType( XP_TYPE.EPILOGUE_SOLE_SURVIVOR )

	event = cScoreEvent( "TeamBonusFullEvac" )
	event.SetPointValue( POINTVALUE_FULL_TEAM_EVAC )
	event.SetSplashText( "#SCORE_EVENT_TEAM_BONUS_FULL_TEAM_EVAC" )
	event.SetXPType( XP_TYPE.EPILOGUE_FULL_TEAM_EVAC )

	event = cScoreEvent( "KillRescueShip" )
	event.SetPointValue( POINTVALUE_EVAC_DENIED )
	event.SetSplashText( "#SCORE_EVENT_EVAC_DENIED" )
	event.SetXPType( XP_TYPE.EPILOGUE_KILL_SHIP )

	event = cScoreEvent( "TeamBonusKilledAll" )
	event.SetPointValue( POINTVALUE_FULL_TEAM_KILL )
	event.SetSplashText( "#SCORE_EVENT_TEAM_BONUS_KILLED_ALL_COMBATANTS" )
	event.SetXPType( XP_TYPE.EPILOGUE_KILL_ALL )

	event = cScoreEvent( "SelfBonusKilledAll" )
	event.SetPointValue( POINTVALUE_FULL_TEAM_KILL_SOLO )
	event.SetSplashText( "#SCORE_EVENT_SOLO_KILLED_ALL_COMBATANTS" )
	event.SetXPType( XP_TYPE.EPILOGUE_KILL_ALL )

	event = cScoreEvent( "KilledStraton" )
	event.SetPointValue( POINTVALUE_KILLED_DOGFIGHTER )
	event.SetSplashText( "#SCORE_EVENT_DESTROYED_PHANTOM" )
	event.SetXPType( XP_TYPE.DROPSHIP_KILL )

	event = cScoreEvent( "KilledHornet" )
	event.SetPointValue( POINTVALUE_KILLED_DOGFIGHTER )
	event.SetSplashText( "#SCORE_EVENT_DESTROYED_HORNET" )
	event.SetXPType( XP_TYPE.DROPSHIP_KILL )

	event = cScoreEvent( "KilledCrow" )
	event.SetPointValue( POINTVALUE_KILLED_DOGFIGHTER )
	event.SetSplashText( "#SCORE_EVENT_DESTROYED_CROW" )
	event.SetXPType( XP_TYPE.DROPSHIP_KILL )

	event = cScoreEvent( "KilledGoblin" )
	event.SetPointValue( POINTVALUE_KILLED_DOGFIGHTER )
	event.SetSplashText( "#SCORE_EVENT_DESTROYED_GOBLIN" )
	event.SetXPType( XP_TYPE.DROPSHIP_KILL )

	event = cScoreEvent( "Auto_Turret_Killed_Goblin" )
	event.SetPointValue( POINTVALUE_KILLED_DOGFIGHTER )
	event.SetSplashText( "#SCORE_EVENT_COOP_AUTO_TURRET_KILL_GOBLIN" )
	event.SetXPType( XP_TYPE.DROPSHIP_KILL )

	event = cScoreEvent( "KilledEscapee" )
	event.SetPointValue( POINTVALUE_KILLED_ESCAPEE )
	event.SetSplashText( "#SCORE_EVENT_KILLED_EVACUATING_ENEMY" )
	event.SetXPType( XP_TYPE.EPILOGUE_KILL )

	event = cScoreEvent( "FishInBarrel" )
	event.SetPointValue( POINTVALUE_FISHINBARREL )
	event.SetSplashText( "#SCORE_EVENT_FISH_IN_A_BARREL" )
	event.SetXPType( XP_TYPE.EPILOGUE_KILL )

	event = cScoreEvent( "FlyerKill" )
	event.SetPointValue( POINTVALUE_KILL_FLYER )
	event.SetSplashText( "#SCORE_EVENT_KILLED_FLYER" )
	event.SetXPType( XP_TYPE.NPC_KILL )

	event = cScoreEvent( "EliminateTitan" )
	event.SetPointValue( POINTVALUE_ELIMINATE_TITAN )
	event.SetSplashTextAppendTargetName( true )
	event.SetSplashText( "#SCORE_EVENT_TITAN_ELIMINATED" )
	event.SetXPType( XP_TYPE.TITAN_KILL )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

	event = cScoreEvent( "EliminatePilot" )
	event.SetPointValue( POINTVALUE_ELIMINATE_PILOT )
	event.SetSplashTextAppendTargetName( true )
	event.SetSplashText( "#SCORE_EVENT_PILOT_ELIMINATED" )
	event.SetXPType( XP_TYPE.PILOT_KILL )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

	event = cScoreEvent( "AttritionPoints" )
	event.SetSplashText( "#SCORE_EVENT_ATTRITION_POINTS" )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_ATTRITION )
	event.SetShouldStackDisplay( true )
	event.SetType( scoreEventType.GAMEMODE )

	event = cScoreEvent( "TitanTagPoints" )
	event.SetSplashText( "#SCORE_EVENT_TITAN_TAG_POINTS" )
	event.SetScoreSplashColors( SCORE_SPLASH_COLORS_ATTRITION )
	event.SetShouldStackDisplay( true )
	event.SetType( scoreEventType.GAMEMODE )

	// Level Specific
	event = cScoreEvent( "AngelCity_SearchDroneKill" )
	event.SetPointValue( POINTVALUE_KILL_ANGELCITY_SEARCHDRONE )
	event.SetSplashText( "#SCORE_EVENT_KILLED_SEARCH_DRONE" )
	event.SetXPType( XP_TYPE.NPC_KILL )

	//COOP Nuke Titan
		event = cScoreEvent( "Killed_Nuke_Titan" )
		event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_COOP_KILL_NUKE_TITAN ) )
		event.SetSplashText( "#SCORE_EVENT_COOP_KILL_NUKE_TITAN" )
		event.SetShouldStackDisplay( true )
		event.SetXPType( XP_TYPE.TITAN_KILL )
		event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

		event = cScoreEvent( "Auto_Titan_Killed_Nuke_Titan" )
		event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_COOP_KILL_NUKE_TITAN ) )
		event.SetSplashText( "#SCORE_EVENT_COOP_AUTO_TITAN_KILL_NUKE_TITAN" )
		event.SetShouldStackDisplay( true )
		event.SetXPType( XP_TYPE.TITAN_KILL )
		event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

		event = cScoreEvent( "Flipped_Spectre_Killed_Nuke_Titan" )
		event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_COOP_KILL_NUKE_TITAN ) )
		event.SetSplashText( "#SCORE_EVENT_COOP_FLIPPED_SPECTRE_KILL_NUKE_TITAN" )
		event.SetShouldStackDisplay( true )
		event.SetXPType( XP_TYPE.TITAN_KILL )
		event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

		event = cScoreEvent( "Auto_Turret_Killed_Nuke_Titan" )
		event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_COOP_KILL_NUKE_TITAN ) )
		event.SetSplashText( "#SCORE_EVENT_COOP_AUTO_TURRET_KILL_NUKE_TITAN" )
		event.SetShouldStackDisplay( true )
		event.SetXPType( XP_TYPE.TITAN_KILL )
		event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

	//COOP Mortar Titan
		event = cScoreEvent( "Killed_Mortar_Titan" )
		event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_COOP_KILL_MORTAR_TITAN ) )
		event.SetSplashText( "#SCORE_EVENT_COOP_KILL_MORTAR_TITAN" )
		event.SetShouldStackDisplay( true )
		event.SetXPType( XP_TYPE.TITAN_KILL )
		event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

		event = cScoreEvent( "Auto_Titan_Killed_Mortar_Titan" )
		event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_COOP_KILL_MORTAR_TITAN ) )
		event.SetSplashText( "#SCORE_EVENT_COOP_AUTO_TITAN_KILL_MORTAR_TITAN" )
		event.SetShouldStackDisplay( true )
		event.SetXPType( XP_TYPE.TITAN_KILL )
		event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

		event = cScoreEvent( "Flipped_Spectre_Killed_Mortar_Titan" )
		event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_COOP_KILL_MORTAR_TITAN ) )
		event.SetSplashText( "#SCORE_EVENT_COOP_FLIPPED_SPECTRE_KILL_MORTAR_TITAN" )
		event.SetShouldStackDisplay( true )
		event.SetXPType( XP_TYPE.TITAN_KILL )
		event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

		event = cScoreEvent( "Auto_Turret_Killed_Mortar_Titan" )
		event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_COOP_KILL_MORTAR_TITAN ) )
		event.SetSplashText( "#SCORE_EVENT_COOP_AUTO_TURRET_KILL_MORTAR_TITAN" )
		event.SetShouldStackDisplay( true )
		event.SetXPType( XP_TYPE.TITAN_KILL )
		event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

	//COOP EMP Titan
		event = cScoreEvent( "Killed_EMP_Titan" )
		event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_COOP_KILL_EMP_TITAN ) )
		event.SetSplashText( "#SCORE_EVENT_COOP_KILL_EMP_TITAN" )
		event.SetShouldStackDisplay( true )
		event.SetXPType( XP_TYPE.TITAN_KILL )
		event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

		event = cScoreEvent( "Auto_Titan_Killed_EMP_Titan" )
		event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_COOP_KILL_EMP_TITAN ) )
		event.SetSplashText( "#SCORE_EVENT_COOP_AUTO_TITAN_KILL_EMP_TITAN" )
		event.SetShouldStackDisplay( true )
		event.SetXPType( XP_TYPE.TITAN_KILL )
		event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

		event = cScoreEvent( "Flipped_Spectre_Killed_EMP_Titan" )
		event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_COOP_KILL_EMP_TITAN ) )
		event.SetSplashText( "#SCORE_EVENT_COOP_FLIPPED_SPECTRE_KILL_EMP_TITAN" )
		event.SetShouldStackDisplay( true )
		event.SetXPType( XP_TYPE.TITAN_KILL )
		event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

		event = cScoreEvent( "Auto_Turret_Killed_EMP_Titan" )
		event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_COOP_KILL_EMP_TITAN ) )
		event.SetSplashText( "#SCORE_EVENT_COOP_AUTO_TURRET_KILL_EMP_TITAN" )
		event.SetShouldStackDisplay( true )
		event.SetXPType( XP_TYPE.TITAN_KILL )
		event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

	//COOP Suicide Spectre
		event = cScoreEvent( "Killed_Suicide_Spectre" )
		event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_COOP_KILL_SUICIDE_SPECTRE ) )
		event.SetSplashText( "#SCORE_EVENT_COOP_KILL_SUICIDE_SPECTRE" )
		event.SetShouldStackDisplay( true )
		event.SetXPType( XP_TYPE.NPC_KILL )
		event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

		event = cScoreEvent( "Auto_Titan_Killed_Suicide_Spectre" )
		event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_COOP_KILL_SUICIDE_SPECTRE ) )
		event.SetSplashText( "#SCORE_EVENT_COOP_AUTO_TITAN_KILL_SUICIDE_SPECTRE" )
		event.SetShouldStackDisplay( true )
		event.SetXPType( XP_TYPE.NPC_KILL )
		event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

		event = cScoreEvent( "Flipped_Spectre_Killed_Suicide_Spectre" )
		event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_COOP_KILL_SUICIDE_SPECTRE ) )
		event.SetSplashText( "#SCORE_EVENT_COOP_FLIPPED_SPECTRE_KILL_SUICIDE_SPECTRE" )
		event.SetShouldStackDisplay( true )
		event.SetXPType( XP_TYPE.NPC_KILL )
		event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

		event = cScoreEvent( "Auto_Turret_Killed_Suicide_Spectre" )
		event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_COOP_KILL_SUICIDE_SPECTRE ) )
		event.SetSplashText( "#SCORE_EVENT_COOP_AUTO_TURRET_KILL_SUICIDE_SPECTRE" )
		event.SetShouldStackDisplay( true )
		event.SetXPType( XP_TYPE.NPC_KILL )
		event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

	//COOP Sniper Spectre
		event = cScoreEvent( "Killed_Sniper_Spectre" )
		event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_COOP_KILL_SNIPER_SPECTRE ) )
		event.SetSplashText( "#SCORE_EVENT_COOP_KILL_SNIPER_SPECTRE" )
		event.SetShouldStackDisplay( true )
		event.SetXPType( XP_TYPE.NPC_KILL )
		event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

		event = cScoreEvent( "Auto_Titan_Killed_Sniper_Spectre" )
		event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_COOP_KILL_SNIPER_SPECTRE ) )
		event.SetSplashText( "#SCORE_EVENT_COOP_AUTO_TITAN_KILL_SNIPER_SPECTRE" )
		event.SetShouldStackDisplay( true )
		event.SetXPType( XP_TYPE.NPC_KILL )
		event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

		event = cScoreEvent( "Flipped_Spectre_Killed_Sniper_Spectre" )
		event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_COOP_KILL_SNIPER_SPECTRE ) )
		event.SetSplashText( "#SCORE_EVENT_COOP_FLIPPED_SPECTRE_KILL_SNIPER_SPECTRE" )
		event.SetShouldStackDisplay( true )
		event.SetXPType( XP_TYPE.NPC_KILL )
		event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

		event = cScoreEvent( "Auto_Turret_Killed_Sniper_Spectre" )
		event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_COOP_KILL_SNIPER_SPECTRE ) )
		event.SetSplashText( "#SCORE_EVENT_COOP_AUTO_TURRET_KILL_SNIPER_SPECTRE" )
		event.SetShouldStackDisplay( true )
		event.SetXPType( XP_TYPE.NPC_KILL )
		event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

		event = cScoreEvent( "TitanStepCrush_Killed_Sniper_Spectre" )
		event.SetPointValue( POINTVALUE_TITAN_STEPCRUSH + POINTVALUE_KILL_SPECTRE )
		event.SetSplashText( "#SCORE_EVENT_COOP_CRUSHED_SNIPER_SPECTRE" )
		event.SetShouldStackDisplay( true )
		event.SetXPType( XP_TYPE.NPC_KILL )
		event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

	//COOP Bubble Shield Spectre
		event = cScoreEvent( "Killed_Bubble_Shield_Spectre" )
		event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_COOP_KILL_BUBBLE_SHIELD_SPECTRE ) )
		event.SetSplashText( "#SCORE_EVENT_COOP_KILL_BUBBLE_SHIELD_SPECTRE" )
		event.SetShouldStackDisplay( true )
		event.SetXPType( XP_TYPE.NPC_KILL )
		event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

		event = cScoreEvent( "Auto_Titan_Killed_Bubble_Shield_Spectre" )
		event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_COOP_KILL_BUBBLE_SHIELD_SPECTRE ) )
		event.SetSplashText( "#SCORE_EVENT_COOP_AUTO_TITAN_KILL_BUBBLE_SHIELD_SPECTRE" )
		event.SetShouldStackDisplay( true )
		event.SetXPType( XP_TYPE.NPC_KILL )
		event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

		event = cScoreEvent( "Flipped_Spectre_Killed_Bubble_Shield_Spectre" )
		event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_COOP_KILL_BUBBLE_SHIELD_SPECTRE ) )
		event.SetSplashText( "#SCORE_EVENT_COOP_FLIPPED_SPECTRE_KILL_BUBBLE_SHIELD_SPECTRE" )
		event.SetShouldStackDisplay( true )
		event.SetXPType( XP_TYPE.NPC_KILL )
		event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

		event = cScoreEvent( "Auto_Turret_Killed_Bubble_Shield_Spectre" )
		event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_COOP_KILL_BUBBLE_SHIELD_SPECTRE ) )
		event.SetSplashText( "#SCORE_EVENT_COOP_AUTO_TITAN_KILL_BUBBLE_SHIELD_SPECTRE" )
		event.SetShouldStackDisplay( true )
		event.SetXPType( XP_TYPE.NPC_KILL )
		event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

	//COOP Bubble Shield Grunt
		event = cScoreEvent( "Killed_Bubble_Shield_Grunt" )
		event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_COOP_KILL_BUBBLE_SHIELD_GRUNT ) )
		event.SetSplashText( "#SCORE_EVENT_COOP_KILL_BUBBLE_SHIELD_GRUNT" )
		event.SetShouldStackDisplay( true )
		event.SetXPType( XP_TYPE.NPC_KILL )
		event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

		event = cScoreEvent( "Auto_Titan_Killed_Bubble_Shield_Grunt" )
		event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_COOP_KILL_BUBBLE_SHIELD_GRUNT ) )
		event.SetSplashText( "#SCORE_EVENT_COOP_AUTO_TITAN_KILL_BUBBLE_SHIELD_GRUNT" )
		event.SetShouldStackDisplay( true )
		event.SetXPType( XP_TYPE.NPC_KILL )
		event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

		event = cScoreEvent( "Flipped_Spectre_Killed_Bubble_Shield_Grunt" )
		event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_COOP_KILL_BUBBLE_SHIELD_GRUNT ) )
		event.SetSplashText( "#SCORE_EVENT_COOP_FLIPPED_SPECTRE_KILL_BUBBLE_SHIELD_GRUNT" )
		event.SetShouldStackDisplay( true )
		event.SetXPType( XP_TYPE.NPC_KILL )
		event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

		event = cScoreEvent( "Auto_Turret_Killed_Bubble_Shield_Grunt" )
		event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_COOP_KILL_BUBBLE_SHIELD_GRUNT ) )
		event.SetSplashText( "#SCORE_EVENT_COOP_AUTO_TURRET_KILL_BUBBLE_SHIELD_GRUNT" )
		event.SetShouldStackDisplay( true )
		event.SetXPType( XP_TYPE.NPC_KILL )
		event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )
	//COOP Cloaking Drone
		event = cScoreEvent( "Killed_Cloaking_Drone" )
		event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_COOP_KILL_CLOAKING_DRONE ) )
		event.SetSplashText( "#SCORE_EVENT_COOP_KILL_CLOAKING_DRONE" )
		event.SetShouldStackDisplay( true )
		event.SetXPType( XP_TYPE.NPC_KILL )
		event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

		event = cScoreEvent( "Auto_Titan_Killed_Cloaking_Drone" )
		event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_COOP_KILL_CLOAKING_DRONE ) )
		event.SetSplashText( "#SCORE_EVENT_COOP_AUTO_TITAN_KILL_CLOAKING_DRONE" )
		event.SetShouldStackDisplay( true )
		event.SetXPType( XP_TYPE.NPC_KILL )
		event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

		event = cScoreEvent( "Flipped_Spectre_Killed_Cloaking_Drone" )
		event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_COOP_KILL_CLOAKING_DRONE ) )
		event.SetSplashText( "#SCORE_EVENT_COOP_FLIPPED_SPECTRE_KILL_CLOAKING_DRONE" )
		event.SetShouldStackDisplay( true )
		event.SetXPType( XP_TYPE.NPC_KILL )
		event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

		event = cScoreEvent( "Auto_Turret_Killed_Cloaking_Drone" )
		event.SetPointValue( ScaleScoreForAutoTitan( POINTVALUE_COOP_KILL_CLOAKING_DRONE ) )
		event.SetSplashText( "#SCORE_EVENT_COOP_AUTO_TURRET_KILL_CLOAKING_DRONE" )
		event.SetShouldStackDisplay( true )
		event.SetXPType( XP_TYPE.NPC_KILL )
		event.SetScoreSplashColors( SCORE_SPLASH_COLORS_PLAYERKILLS )

	event = cScoreEvent( "CoopTurretKillStreak" )
	event.SetPointValue( POINTVALUE_COOP_TURRET_KILL_STREAK )
	event.SetSplashText( "#SCORE_EVENT_KILL_STREAK" )
	event.SetXPType( XP_TYPE.KILL_STREAK )
	event.SetShouldStackDisplay( true )

	event = cScoreEvent( "CoopWaveMvp" )
	event.SetPointValue( POINTVALUE_COOP_WAVE_MVP )
	event.SetSplashText( "#SCORE_EVENT_WAVE_MVP" )
	event.SetXPType( XP_TYPE.SPECIAL )
	event.SetShouldStackDisplay( true )

	event = cScoreEvent( "CoopSurvivor" )
	event.SetPointValue( POINTVALUE_COOP_SURVIVOR )
	event.SetSplashText( "#SCORE_EVENT_SURVIVOR" )
	event.SetXPType( XP_TYPE.SPECIAL )
	event.SetShouldStackDisplay( true )

	event = cScoreEvent( "CoopImmortal" )
	event.SetPointValue( POINTVALUE_COOP_IMMORTAL )
	event.SetSplashText( "#SCORE_EVENT_IMMORTAL" )
	event.SetXPType( XP_TYPE.SPECIAL )
	event.SetShouldStackDisplay( true )
}

function ScaleScoreForAutoTitan( eventPoints )
{
	local score = eventPoints * POINTVALUE_AUTOTITAN_MULTIPLIER
	score = RoundToNearestMultiplier( score, 5.0 )

	if ( score < 10 )
		score = 10

	//printl( "eventPoints: " + eventPoints + ", adjusted: " + score )

	return score
}

function ScoreEventNameToInteger( eventName )
{
	local event = ScoreEventFromName( eventName )
	return event.GetInt()
}

function ScoreEventFromName( eventName )
{
	Assert( eventName in level.scoreEventsByName, "Score event " +eventName + " does not exist" )
	return level.scoreEventsByName[ eventName ]
}

function ScoreEventFromInteger( integer )
{
	Assert( integer < level.scoreEventsByIndex.len() )
	Assert( integer >= 0 )
	return level.scoreEventsByIndex[ integer ]
}

function ScoreEventExists( eventName )
{
	return event in level.scoreEventsByName
}

function ScoreEventForTitanEntityKilled( titan, inflictor, damageSourceId )
{
	inflictor = InflictorOwner( inflictor )  // turns env_explosion into a player or npc
	if ( GAMETYPE == COOPERATIVE )
	{
		if ( IsValid( inflictor ) )
		{
			if ( IsTitanNPC( inflictor ) )
			{
				if ( IsNukeTitan( titan ) )
					return "Auto_Titan_Killed_Nuke_Titan"
				else if ( IsMortarTitan( titan ) )
					return "Auto_Titan_Killed_Mortar_Titan"
				else if ( IsEMPTitan( titan ) )
					return "Auto_Titan_Killed_EMP_Titan"
			}

			if ( IsPlayerControlledSpectre( inflictor ) )
			{
				if ( IsNukeTitan( titan ) )
					return "Flipped_Spectre_Killed_Nuke_Titan"
				else if ( IsMortarTitan( titan ) )
					return "Flipped_Spectre_Killed_Mortar_Titan"
				else if ( IsEMPTitan( titan ) )
					return "Flipped_Spectre_Killed_EMP_Titan"
			}

			if ( IsPlayerControlledTurret( inflictor ) )
			{
				if ( IsNukeTitan( titan ) )
					return "Auto_Turret_Killed_Nuke_Titan"
				else if ( IsMortarTitan( titan ) )
					return "Auto_Turret_Killed_Mortar_Titan"
				else if ( IsEMPTitan( titan ) )
					return "Auto_Turret_Killed_EMP_Titan"
			}
		}
	}

	local electrocuted = damageSourceId == eDamageSourceId.super_electric_smoke_screen

	// hack: shouldn't need a HasSoul check, something changed with Mo's recent titan melee changes
	if ( titan.IsTitan() && titan.IsNPC() && HasSoul( titan ) && !titan.GetTitanSoul().IsEjecting() && inflictor.IsPlayer() )
	{
		if ( IsPetTitan( titan ) )
			return electrocuted ? "ElectrocuteAutoTitan" : "KillTitan_Auto_Pilot"
		else
			return electrocuted ? "ElectrocuteTitan" : "KillTitan"
	}
	else if ( IsValid( inflictor ) )
	{
		if ( IsTitanNPC( inflictor ) )
			return "Auto_Pilot_KillTitan"

		if ( IsPlayerControlledSpectre( inflictor ) )
			return "Flipped_Spectre_KillTitan"

		if ( IsPlayerControlledTurret( inflictor ) )
		{
			if ( IsAlive( inflictor.GetParent() ) )
				return "AerialEscort_KillTitan"
			else
				return "AutoTurret_KillTitan"
		}
	}

	if ( electrocuted )
		return "ElectrocuteTitan"

	if ( damageSourceId == eDamageSourceId.rodeo )
		return "Rodeo"

	if ( damageSourceId == eDamageSourceId.rodeo_forced_titan_eject )
		return "RodeoForceEject"

	if ( GAMETYPE == COOPERATIVE )
	{
		if ( IsNukeTitan( titan ) )
			return "Killed_Nuke_Titan"
		else if ( IsMortarTitan( titan ) )
			return "Killed_Mortar_Titan"
		else if ( IsEMPTitan( titan ) )
			return "Killed_EMP_Titan"
	}
	//Default case
	return "KillTitan"
}

// Removed for now to see if ranked play feels OK without it
/*
function RankedScoreEventForMethodOfDeath( player, attacker )
{
	local scoreEvent = "KillPilotRanked"

	if ( attacker )
	{
		local topRank = 0
		local topPoints = 0
		local players = GetPlayerArray()

		// Find the highest ranked and performing players
		foreach( thisPlayer in players )
		{
			if( thisPlayer == attacker )
				continue

			if( !PlayerPlayingRanked( thisPlayer ) )
				continue

			local rank = GetPlayerRank( thisPlayer )
			local points = GetPlayerContributionTotal( thisPlayer )

			if ( rank >= topRank )
				topRank = rank

			if ( points >= topPoints )
				topPoints = points
		}

		if( GetPlayerRank( player ) >= topRank )
			scoreEvent = "KillPilotRankedTopRank"

		if( GetPlayerContributionTotal( player ) >= topPoints )
			scoreEvent = "KillPilotRankedTopPerf"
	}

	return scoreEvent
}
*/

function ScoreEventForMethodOfDeath( player, damageInfo )
{
	local scoreEvent
	scoreEvent = "KillPilot"
	local inflictor = damageInfo.GetInflictor()
	inflictor = InflictorOwner( inflictor ) // turns env_explosion into a player or npc

	if ( inflictor )
	{
		if ( IsTitanNPC( inflictor ) )
			return "Auto_Pilot_KillPilot"

		if ( IsPlayerControlledSpectre( inflictor ) )
			return "Flipped_Spectre_KillPilot"

		if ( IsPlayerControlledTurret( inflictor ) )
		{
			if ( IsAlive( inflictor.GetParent() ) )
				return "AerialEscort_KillPilot"
			else
				return "AutoTurret_KillPilot"
		}
	}

	local damageSourceId = damageInfo.GetDamageSourceIdentifier()
	if ( damageSourceId == eDamageSourceId.super_electric_smoke_screen )
	{
		return "ElectrocutePilot"
	}

	if ( damageSourceId == eDamageSourceId.human_melee )
	{
		return  "MeleeHumanAttackVsPilot"
	}

	if ( damageSourceId == eDamageSourceId.human_execution )
	{
		return  "MeleeHumanExecutionVsPilot"
	}

	if ( damageSourceId == eDamageSourceId.titan_execution )
	{
		return  "TitanMeleeExecution"
	}

	if ( damageSourceId == eDamageSourceId.wall_smash)
	{
		scoreEvent =  "TitanWallSmashPilot"
	}

	if ( IsTitanCrushDamage( damageInfo ) )
	{
		return "TitanStepCrushPilot"
	}

	return scoreEvent
}

function ScoreEventForNPCKilled(npc, damageInfo)
{
	local scoreEvent
	local inflictor = damageInfo.GetInflictor()
	inflictor = InflictorOwner( inflictor ) // turns env_explosion into a player or npc

	local damageSourceId = damageInfo.GetDamageSourceIdentifier()

	local classname = npc.GetClassname()
	switch ( classname )
	{
		case "npc_turret_mega":
			return "KillHeavyTurret"

		case "npc_turret_sentry":
			return "KillLightTurret"

		case "npc_dropship":
			if ( "dogfighter" in npc.s )
			{
				switch ( npc.GetTeam() )
				{
					case TEAM_MILITIA:
						return "KilledHornet"
					case TEAM_IMC:
						return "KilledStraton"
				}
			}

			switch ( npc.GetTeam() )
			{
				case TEAM_MILITIA:
					return "KilledCrow"
				case TEAM_IMC:
					if ( inflictor && IsPlayerControlledTurret( inflictor ) )
						return "Auto_Turret_Killed_Goblin"
					return "KilledGoblin"
			}

			break

		case "npc_spectre":
			scoreEvent = "KillSpectre"
			if ( inflictor )
			{
				if ( IsTitanCrushDamage( damageInfo ) )
				{
					if ( GAMETYPE == COOPERATIVE )
					{
						if ( IsSniperSpectre( npc ) )
							return "TitanStepCrush_Killed_Sniper_Spectre"
					}
					return "TitanStepCrush_"+ scoreEvent
				}

				if ( IsTitanNPC( inflictor ) )
				{
					if ( GAMETYPE == COOPERATIVE )
					{
						if ( IsSuicideSpectre( npc ) )
							return "Auto_Titan_Killed_Suicide_Spectre"
						else if ( IsSniperSpectre( npc ) )
							return "Auto_Titan_Killed_Sniper_Spectre"
						else if ( IsBubbleShieldMinion( npc ) )
							return "Auto_Titan_Killed_Bubble_Shield_Spectre"
					}
					return  "Auto_Pilot_" + scoreEvent
				}

				if ( IsPlayerControlledSpectre( inflictor) )
				{
					if ( GAMETYPE == COOPERATIVE )
					{
						if ( IsSuicideSpectre( npc ) )
							return "Flipped_Spectre_Killed_Suicide_Spectre"
						else if ( IsSniperSpectre( npc ) )
							return "Flipped_Spectre_Killed_Sniper_Spectre"
						else if ( IsBubbleShieldMinion( npc ) )
							return "Flipped_Spectre_Killed_Bubble_Shield_Spectre"
					}
					return  "Flipped_Spectre_" + scoreEvent
				}

				if ( IsPlayerControlledTurret( inflictor ) )
				{
					if ( GAMETYPE == COOPERATIVE )
					{
						if ( IsSuicideSpectre( npc ) )
							return "Auto_Turret_Killed_Suicide_Spectre"
						else if ( IsSniperSpectre( npc ) )
							return "Auto_Turret_Killed_Sniper_Spectre"
						else if ( IsBubbleShieldMinion( npc ) )
							return "Auto_Turret_Killed_Bubble_Shield_Spectre"
					}

					return "AutoTurret_" + scoreEvent
				}

	            if ( GAMETYPE == COOPERATIVE )
	            {
					if ( IsSuicideSpectre( npc ) )
			            return scoreEvent = "Killed_Suicide_Spectre"
					else if ( IsSniperSpectre( npc ) )
						return "Killed_Sniper_Spectre"
		            else if ( IsBubbleShieldMinion( npc ) )
			            return scoreEvent = "Killed_Bubble_Shield_Spectre"
	            }

				if ( damageSourceId == eDamageSourceId.super_electric_smoke_screen )
				{
					return "ElectrocuteSpectre"
				}

				if ( damageSourceId == eDamageSourceId.human_execution )
				{
					return  "MeleeHumanExecutionVsSpectre"
				}

				if ( damageSourceId == eDamageSourceId.human_melee )
				{
					return  "MeleeHumanAttackVsSpectre"
				}

			}

			return scoreEvent
	}

	if ( npc.GetAIClass() == "human" )
	{
		if ( IsConscript( npc ) )
		{
			scoreEvent = "KillConscript"
		}
		else
		{
			scoreEvent = "KillGrunt"
			if ( npc.GetTeam() == TEAM_IMC )
				scoreEvent = "Kill_IMC_Soldier"
		}

		if ( inflictor )
		{
			if ( IsTitanCrushDamage( damageInfo ) )
			{
				return "TitanStepCrush_"+ scoreEvent
			}

			if ( IsTitanNPC( inflictor ) )
			{
				if ( GAMETYPE == COOPERATIVE )
				{
					if ( IsBubbleShieldMinion( npc ) )
						return "Auto_Titan_Killed_Bubble_Shield_Grunt"
				}
				return "Auto_Pilot_" + scoreEvent
			}

			if ( IsPlayerControlledSpectre( inflictor ) )
			{
				if ( GAMETYPE == COOPERATIVE )
				{
					if ( IsBubbleShieldMinion( npc ) )
						return "Flipped_Spectre_Killed_Bubble_Shield_Grunt"
				}
				return  "Flipped_Spectre_" + scoreEvent
			}

			if ( IsPlayerControlledTurret( inflictor ) )
			{
				if ( GAMETYPE == COOPERATIVE )
				{
					if ( IsBubbleShieldMinion( npc ) )
						return "Auto_Turret_Killed_Bubble_Shield_Grunt"
				}
				if ( IsAlive( inflictor.GetParent() ) )
					return "AerialEscort_" + scoreEvent
				else
					return "AutoTurret_" + scoreEvent
			}

			if ( GAMETYPE == COOPERATIVE )
			{
				if ( IsBubbleShieldMinion( npc ) )
					return "Killed_Bubble_Shield_Grunt"
			}

			if ( damageSourceId == eDamageSourceId.super_electric_smoke_screen )
			{
				scoreEvent = "ElectrocuteFireteamAI"
				if ( npc.GetTeam() == TEAM_IMC )
					scoreEvent = "Electrocute_IMC_Soldier"
			}

			if ( damageSourceId == eDamageSourceId.human_melee )
			{
				scoreEvent =  "MeleeHumanAttackVsGrunt"
				if ( npc.GetTeam() == TEAM_IMC )
					scoreEvent = "MeleeHumanAttackVs_IMC_Soldier"
			}

			if ( damageSourceId == eDamageSourceId.human_execution )
			{
				scoreEvent =  "MeleeHumanExecutionVsGrunt"
				if ( npc.GetTeam() == TEAM_IMC )
					scoreEvent = "MeleeHumanExecutionVs_IMC_Soldier"
			}

		}
		return scoreEvent
	}

	scoreEvent = "GenericKill"
	if ( inflictor )
	{
		if ( IsTitanNPC( inflictor ) )
		{
			return  "Auto_Pilot_" + scoreEvent
		}

		if ( IsPlayerControlledSpectre( inflictor ) )
		{
			return  "Flipped_Spectre_" + scoreEvent
		}

		if ( IsPlayerControlledTurret( inflictor ) )
		{
			return "AutoTurret_" + scoreEvent
		}

		if ( damageSourceId == eDamageSourceId.super_electric_smoke_screen )
		{
			return  "Electrocute"
		}
	}
	return scoreEvent
}

function InflictorOwner( inflictor )
{
	if ( IsValid( inflictor )  )
	{
		local inflictorOwner = inflictor.GetOwner()
		if ( IsValid( inflictorOwner ) )
			inflictor = inflictorOwner
	}

	return 	inflictor
}

function IsTitanNPC( ent )
{
	if ( ent.IsTitan() && ent.IsNPC() )
		return true

	return false
}
Globalize( IsTitanNPC )

function IsPlayerControlledSpectre( ent )
{
	if ( ent.GetClassname() == "npc_spectre" && ent.GetBossPlayer() != null )
		return true

	return false
}
Globalize( IsPlayerControlledSpectre )

function IsPlayerControlledTurret( ent )
{
	if ( ent.IsTurret() && ent.GetBossPlayer() != null )
		return true

	return false
}
Globalize( IsPlayerControlledTurret )

function CreateScoreEvent( eventName )
{
	local event = cScoreEvent( eventName )
	return event
}

function RankedOverrideSplashColors()
{
	local scoreNames = GetContributionScoreNames()
	foreach( name, val in scoreNames )
	{
		if (name in level.scoreEventsByName )
		{
			level.scoreEventsByName[ name ].SetScoreSplashColors( SCORE_SPLASH_COLORS_RANKED )
		}
	}

	foreach( event in level.scoreEventsByName )
	{
		if ( EventRewardsRankedPoints( event ) )
			event.SetScoreSplashColors( SCORE_SPLASH_COLORS_RANKED )
	}
}
