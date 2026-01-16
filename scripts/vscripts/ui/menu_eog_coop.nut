menu <- null
playerButtonsRegistered <- false
coopStoredData <- {}
teamButton <- null

function main()
{
	Globalize( OnOpenEOG_Coop )
	Globalize( OnCloseEOG_Coop )
	Globalize( EOGCoop_FooterData )

	PrecacheHUDMaterial( "../ui/menu/coop_eog_mission_summary/coop_eog_player_icon_1" )
	PrecacheHUDMaterial( "../ui/menu/coop_eog_mission_summary/coop_eog_player_icon_2" )
	PrecacheHUDMaterial( "../ui/menu/coop_eog_mission_summary/coop_eog_player_icon_3" )
	PrecacheHUDMaterial( "../ui/menu/coop_eog_mission_summary/coop_eog_player_icon_4" )
}

function InitMenu()
{
	Assert( menu != null )
	// Buttons & Background
	SetupEOGMenuCommon( menu )

	uiGlobal.eogCoopFocusedButton = null

	if ( !playerButtonsRegistered )
	{
		for( local i = 0 ; i < 5 ; i++ )
		{
			local button = GetElem( menu, "BtnCoop" + i )
			{
				button.s.index <- i
				button.s.playerUID <- ""
				button.AddEventHandler( UIE_GET_FOCUS, Bind( EOG_CoopButton_GetFocus ) )
				button.AddEventHandler( UIE_LOSE_FOCUS, Bind( EOG_CoopButton_LoseFocus ) )
				button.AddEventHandler( UIE_CLICK, Bind( EOG_CoopButton_Click )  )
			}

			if ( i == 0 )
				teamButton = button
		}
		playerButtonsRegistered = true
	}
}

function OnOpenEOG_Coop()
{
	menu = GetMenu( "EOG_Coop" )
	level.currentEOGMenu = menu
	Signal( level, "CancelEOGThreadedNavigation" )

	coopStoredData = {}
	InitMenu()
	GetCoopScoreboardValuesFromPersistence( menu )
	DisplayKillCountsForIndex( menu, 0 )
	teamButton.SetFocused()

	EOGOpenGlobal()
}

function OnCloseEOG_Coop()
{
	thread EOGCloseGlobal()
}

function EOG_CoopButton_GetFocus( button )
{
	uiGlobal.eogCoopFocusedButton = button
	DisplayKillCountsForIndex( menu, button.s.index )
	UpdateFooterButtons()
}

function EOG_CoopButton_LoseFocus( button )
{
	uiGlobal.eogCoopFocusedButton = null
	UpdateFooterButtons()
}

function EOG_CoopButton_Click( button )
{
	//if ( uiGlobal.eogCoopSelectedButton != null )
	//	uiGlobal.eogCoopSelectedButton.SetSelected( false )

	//button.SetSelected( true )


	uiGlobal.eogCoopSelectedButton = button

	Assert( "playerUID" in button.s )
	if ( button.s.playerUID != "" )
		ShowPlayerProfileCardForUID( button.s.playerUID )
}

function EOGCoop_FooterData( footerData )
{
	footerData.gamepad.append( { label = "#B_BUTTON_BACK" } )
	footerData.pc.append( { label = "#BACK", func = PCBackButton_Activate } )

	if ( uiGlobal.eogCoopFocusedButton != null && ( "playerUID" in uiGlobal.eogCoopFocusedButton.s) && uiGlobal.eogCoopFocusedButton.s.playerUID != "" )
	{
		footerData.pc.append( { label = "#MOUSE1_VIEW_PLAYER_PROFILE" } )
		if ( Durango_IsDurango() )
			footerData.gamepad.append( { label = "#A_BUTTON_GAMERCARD" } )
		else
			footerData.gamepad.append( { label = "#A_BUTTON_PLAYER_PROFILE" } )
	}
}

function ShouldDisplayQuickMatchButton()
{
	if ( !IsFullyConnected() )
		return false

	if ( WaitingForLeader() || !AmIPartyLeader() )
		return false

	local lastModeName = PersistenceGetEnumItemNameForIndex( "gameModes", GetPersistentVar( "savedScoreboardData.gameMode" ) )
	return ( lastModeName == COOPERATIVE && !uiGlobal.playerOpenedEOG )
}
Globalize ( ShouldDisplayQuickMatchButton )

function EOGCoop_QuickMatchFooter( footerData )
{
	if ( !ShouldDisplayQuickMatchButton() )
		return

	footerData.gamepad.append( { label = "#EOG_FOOTER_XBOX_QUICK_MATCH" } )
	footerData.pc.append( { label = "#EOG_FOOTER_PC_QUICK_MATCH", func = AdvanceToQuickMatchMenu } )
}
Globalize( EOGCoop_QuickMatchFooter )

function AdvanceToQuickMatchMenu( button )
{
	if ( uiGlobal.activeDialog )
		return

	CoopQuickMatchButton_Activate( button )
}
Globalize( AdvanceToQuickMatchMenu )

function GetCoopScoreboardValuesFromPersistence( menu )
{
	//Setting the variables that only need to be set once and are always displayed.
	local storedMode = GetPersistentVar( "savedScoreboardData.gameMode" )
	local storedModeString = PersistenceGetEnumItemNameForIndex( "gameModes", storedMode )
	local storedMap = GetPersistentVar( "savedScoreboardData.map" )

	local storedMapString = "dev map"
	if ( storedMap != -1 )
		storedMapString = PersistenceGetEnumItemNameForIndex( "maps", storedMap )

	local mapName = GetMapDisplayName( storedMapString )

	GetElem( menu, "GametypeAndMap" ).SetText( "#VAR_DASH_VAR", GAMETYPE_TEXT[ storedModeString ], mapName )

	local completedWaves = GetPersistentVar( "savedCoopData.completedWaves" )
	local totalWaves = GetPersistentVar( "savedCoopData.totalWaves" )
	GetElem( menu, "WavesCleared" ).SetText( "#COOP_POSTGAME_WAVES_CLEARED", completedWaves, totalWaves )


	local enemiesKilled = GetPersistentVar( "savedCoopData.teamScore.enemiesKilled" )
	local maxEnemiesKilled = GetPersistentVar( "savedCoopData.teamScore.maxEnemiesKilled" )
	local value = GetElem( menu, "RightSideText_Value_0" )
	value.SetText( enemiesKilled.tostring() + "/" + maxEnemiesKilled.tostring() )
	if ( enemiesKilled == maxEnemiesKilled )
	{
		GetElem( menu, "RightSideText_0" ).SetColor( 230, 206, 50, 255 )
		value.SetColor( 230, 206, 50, 255 )
	}
	else
	{
		GetElem( menu, "RightSideText_0" ).SetColor( 255, 255, 255, 255 )
		value.SetColor( 255, 255, 255, 255 )
	}
	local waveComplete = GetPersistentVar( "savedCoopData.teamScore.wavesCompletedBonus" )
	local maxWaveComplete = GetPersistentVar( "savedCoopData.teamScore.maxWavesCompletedBonus" )
	local value = GetElem( menu, "RightSideText_Value_1" )
	value.SetText( waveComplete.tostring() + "/" + maxWaveComplete.tostring() )
	if ( waveComplete == maxWaveComplete )
	{
		GetElem( menu, "RightSideText_1" ).SetColor( 230, 206, 50, 255 )
		value.SetColor( 230, 206, 50, 255 )
	}
	else
	{
		GetElem( menu, "RightSideText_1" ).SetColor( 255, 255, 255, 255 )
		value.SetColor( 255, 255, 255, 255 )
	}
	local finalWaveComplete = GetPersistentVar( "savedCoopData.teamScore.finalWaveCompletedBonus" )
	local maxFinalWaveComplete = GetPersistentVar( "savedCoopData.teamScore.maxFinalWaveCompletedBonus" )
	local value = GetElem( menu, "RightSideText_Value_2" )
	value.SetText( finalWaveComplete.tostring() + "/" + maxFinalWaveComplete.tostring() )
	if ( finalWaveComplete == maxFinalWaveComplete )
	{
		GetElem( menu, "RightSideText_2" ).SetColor( 230, 206, 50, 255 )
		value.SetColor( 230, 206, 50, 255 )
	}
	else
	{
		GetElem( menu, "RightSideText_2" ).SetColor( 255, 255, 255, 255 )
		value.SetColor( 255, 255, 255, 255 )
	}
	local flawlessWaveBonus = GetPersistentVar( "savedCoopData.teamScore.flawlessWaveBonus" )
	local maxFlawlessWaveBonus = GetPersistentVar( "savedCoopData.teamScore.maxFlawlessWaveBonus" )
	local value = GetElem( menu, "RightSideText_Value_3" )
	value.SetText( flawlessWaveBonus.tostring() + "/" + maxFlawlessWaveBonus.tostring() )
	if ( flawlessWaveBonus == maxFlawlessWaveBonus )
	{
		GetElem( menu, "RightSideText_3" ).SetColor( 230, 206, 50, 255 )
		value.SetColor( 230, 206, 50, 255 )
	}
	else
	{
		GetElem( menu, "RightSideText_3" ).SetColor( 255, 255, 255, 255 )
		value.SetColor( 255, 255, 255, 255 )
	}
	local harvesterHealth = GetPersistentVar( "savedCoopData.teamScore.harvesterHealth" )
	local maxHarvesterHealth = GetPersistentVar( "savedCoopData.teamScore.maxHarvesterHealth" )
	local value = GetElem( menu, "RightSideText_Value_4" )
	value.SetText( harvesterHealth.tostring() + "/" + maxHarvesterHealth.tostring() )
	if ( harvesterHealth == maxHarvesterHealth )
	{
		GetElem( menu, "RightSideText_4" ).SetColor( 230, 206, 50, 255 )
		value.SetColor( 230, 206, 50, 255 )
	}
	else
	{
		GetElem( menu, "RightSideText_4" ).SetColor( 255, 255, 255, 255 )
		value.SetColor( 255, 255, 255, 255 )
	}
	local retryBonus = GetPersistentVar( "savedCoopData.teamScore.retriesBonus" )
	local maxRetryBonus = GetPersistentVar( "savedCoopData.teamScore.maxRetriesBonus" )
	local value = GetElem( menu, "RightSideText_Value_5" )
	value.SetText( retryBonus.tostring() + "/" + maxRetryBonus.tostring() )
	if ( retryBonus == maxRetryBonus )
	{
		GetElem( menu, "RightSideText_5" ).SetColor( 230, 206, 50, 255 )
		value.SetColor( 230, 206, 50, 255 )
	}
	else
	{
		GetElem( menu, "RightSideText_5" ).SetColor( 255, 255, 255, 255 )
		value.SetColor( 255, 255, 255, 255 )
	}
	local teamScore = GetPersistentVar( "savedCoopData.teamScore.teamScore" )
	GetElem( menu, "RightSideText_Value_6" ).SetText( teamScore.tostring() )

	local finalHarvesterHealth = GetPersistentVar( "savedCoopData.harvesterHealth" )
	GetElem( menu, "RightSideText_Value_7" ).SetText( finalHarvesterHealth + "%" )
	local retriesUsed = GetPersistentVar( "savedCoopData.retriesUsed" )
	GetElem( menu, "RightSideText_Value_8" ).SetText( retriesUsed.tostring() )
	local gameDuration = GetPersistentVar( "savedCoopData.gameDuration" )
	local gameDurationElem = GetElem( menu, "RightSideText_Value_9" )
	local minutes = gameDuration / 60
	local seconds = gameDuration % 60
	if ( seconds < 10 )
		gameDurationElem.SetText( minutes + ":0" + seconds )
	else
		gameDurationElem.SetText( minutes + ":" + seconds )

	local starsEarned = GetPersistentVar( "savedCoopData.starsEarned" )
	local starReqs = GetStarScoreRequirements( COOPERATIVE, storedMapString )
	for ( local i = 0; i < 3; i++ )
	{
		local star = GetElem( menu, "StarIcon_" + i )
		if ( i + 1 <= starsEarned )
			star.SetImage( "../ui/menu/lobby/map_star_full" )
		else
			star.SetImage( "../ui/menu/lobby/map_star_empty" )

		GetElem( menu, "StarLabel_" + i ).SetText( starReqs[i].tostring() )
	}

	//Store Team Data
	coopStoredData[0] <- {}
	local militiaData = coopStoredData[0]
	militiaData[ "name" ] <- "#EOG_COOP_TEAM" //TEAM_MCOR
	local maxDisplayedEnemyTypes = 9
	for ( local i = 0; i < maxDisplayedEnemyTypes; i++ )
	{
		local turretKillCount = GetPersistentVar( "savedCoopData.militiaKillCounts[" + i + "].turretKillCount" )
		local totalKillCount = GetPersistentVar( "savedCoopData.militiaKillCounts[" + i + "].killCount" ) + turretKillCount
		militiaData[i] <- [ totalKillCount, turretKillCount ]
	}
	for ( local i = 0; i < 4; i++ )
	{
		//Store Player Info
		local buttonIndex = i + 1
		coopStoredData[ buttonIndex ] <- {}
		local playerData = coopStoredData[buttonIndex]
		playerData[ "name" ] <- GetPersistentVar( "savedCoopData.players[" + i + "].name" )
		playerData[ "xuid" ] <- GetPersistentVar( "savedCoopData.players[" + i + "].xuid" )
		playerData[ "entityIndex" ] <- GetPersistentVar( "savedCoopData.players[" + i + "].entityIndex" )

		local button = GetElem( menu, "BtnCoop" + buttonIndex )
		if ( playerData[ "name" ] == "" )
		{
			button.SetEnabled( false )
			button.Hide()
			GetElem( menu, "PlayerIcon_" + buttonIndex ).Hide()
			continue
		}
		else
		{
			button.SetEnabled( true )
			GetElem( menu, "PlayerIcon_" + buttonIndex ).Show()
			button.SetText( playerData[ "name" ] )
			button.s.playerUID = playerData[ "xuid" ]
			button.Show()
		}

		for ( local k = 0; k < maxDisplayedEnemyTypes; k++ )
		{
			local turretKillCount = GetPersistentVar( "savedCoopData.players[" + i + "].enemyType[" + k + "].turretKillCount" )
			local totalKillCount = GetPersistentVar( "savedCoopData.players[" + i + "].enemyType[" + k + "].killCount" ) + turretKillCount
			playerData[k] <- [ totalKillCount, turretKillCount ]
		}
	}
}

function DisplayKillCountsForIndex( menu, index )
{
	GetElem( menu, "KillCount_PlayerName" ).SetText( coopStoredData[index][ "name" ] )
	GetElem( menu, "KillCount_PlayerIcon" ).SetImage( GetCoopEOGIconFromIndex( index ) )
	GetElem( menu, "LargePlayerIcon" ).SetImage( GetCoopEOGIconFromIndex( index ) )

	local playerRowCount = 0
	local turretRowCount = 0
	local playerTotalKillCount = 0
	local turretTotalKillCount = 0
	local maxDisplayedEnemyTypes = 9
	for( local i = 0; i < maxDisplayedEnemyTypes; i++ )
	{
		local table = coopStoredData[index][i]
		local icon = GetCoopEnemyTypeIcon( i )
		local playerKills = table[0]
		if( playerKills > 0 )
		{
			playerTotalKillCount += playerKills
			local iconElem = GetElem( menu, "KillCount_PlayerRow_EnemyIcon_" + playerRowCount )
			iconElem.SetImage( icon )
			iconElem.Show()
			local textElem = GetElem( menu, "KillCount_PlayerRow_EnemyLabel_" + playerRowCount )
			textElem.SetText( playerKills.tostring() )
			textElem.Show()
			playerRowCount++
		}
		local turretKillCount = table[1]
		if( turretKillCount > 0 )
		{
			turretTotalKillCount += turretKillCount
			local iconElem = GetElem( menu, "KillCount_TurretRow_EnemyIcon_" + turretRowCount )
			iconElem.SetImage( icon )
			iconElem.Show()
			local textElem = GetElem( menu, "KillCount_TurretRow_EnemyLabel_" + turretRowCount )
			textElem.SetText( turretKillCount.tostring() )
			textElem.Show()
			turretRowCount++
		}
	}

	for( local i = playerRowCount; i < maxDisplayedEnemyTypes; i ++ )
	{
		GetElem( menu, "KillCount_PlayerRow_EnemyIcon_" + i ).Hide()
		GetElem( menu, "KillCount_PlayerRow_EnemyLabel_" + i ).Hide()
	}
	for( local i = turretRowCount; i < maxDisplayedEnemyTypes; i ++ )
	{
		GetElem( menu, "KillCount_TurretRow_EnemyIcon_" + i ).Hide()
		GetElem( menu, "KillCount_TurretRow_EnemyLabel_" + i ).Hide()
	}

	GetElem( menu, "KillCount_PlayerEnemiesKilled" ).SetText( "#COOP_POSTGAME_X_ENEMIES_KILLED", playerTotalKillCount )
	GetElem( menu, "KillCount_TurretEnemiesKilled" ).SetText( "#COOP_POSTGAME_X_ENEMIES_KILLED", turretTotalKillCount )
}

function GetCoopEnemyTypeIcon( key )
{
	switch( key )
	{
		case eCoopAIType.titan:
			return SCOREBOARD_MATERIAL_COOP_TITAN
		case eCoopAIType.empTitan:
			return SCOREBOARD_MATERIAL_COOP_EMP_TITAN
		case eCoopAIType.mortarTitan:
			return SCOREBOARD_MATERIAL_COOP_MORTAR_TITAN
		case eCoopAIType.nukeTitan:
			return SCOREBOARD_MATERIAL_COOP_NUKE_TITAN
		case eCoopAIType.cloakedDrone:
			return SCOREBOARD_MATERIAL_COOP_CLOAK_DRONE
		case eCoopAIType.suicideSpectre:
			return SCOREBOARD_MATERIAL_COOP_SUICIDE_SPECTRE
		case eCoopAIType.sniperSpectre:
			return SCOREBOARD_MATERIAL_COOP_SNIPER_SPECTRE
		case eCoopAIType.spectre:
			return SCOREBOARD_MATERIAL_COOP_SPECTRE
		case eCoopAIType.grunt:
			return SCOREBOARD_MATERIAL_COOP_GRUNT

		default:
			Assert( "No matching enemy type for key value" )
			break
	}
}

function GetCoopEOGIconFromIndex( index )
{
	switch( index )
	{
		case 0:
			return "../ui/menu/coop_eog_mission_summary/coop_eog_team_icon"
		case 1:
			return "../ui/menu/coop_eog_mission_summary/coop_eog_player_icon_1"
		case 2:
			return "../ui/menu/coop_eog_mission_summary/coop_eog_player_icon_2"
		case 3:
			return "../ui/menu/coop_eog_mission_summary/coop_eog_player_icon_3"
		case 4:
			return "../ui/menu/coop_eog_mission_summary/coop_eog_player_icon_4"

		default:
			Assert( "No matching icon for index" )
			break
	}

}