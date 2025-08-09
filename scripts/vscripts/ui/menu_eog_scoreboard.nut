
menu <- null
playerButtonsRegistered <- false

header_default_color <- [155, 178, 194]
header_highlight_color <- [204, 234, 255]
data_default_color <- [155, 178, 194]
data_highlight_color <- [230, 230, 230]
data_highlight_bg_color_friendly <- [0, 138, 166, 255]
data_highlight_bg_color_enemy <- [156, 71, 6, 255]
data_no_highlight_bg_color <- [0, 0, 0, 0]

const MAX_PLAYERS_PER_TEAM = 8

function main()
{
	Globalize( OnOpenEOG_Scoreboard )
	Globalize( OnCloseEOG_Scoreboard )
	Globalize( EOGScoreboard_FooterData )

	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_FRIENDLY_PLAYER_EVEN )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_FRIENDLY_PLAYER_ODD )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_FRIENDLY_SLOT )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_ENEMY_PLAYER_EVEN )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_ENEMY_PLAYER_ODD )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_ENEMY_SLOT )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_PILOT_KILLS )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_TITAN_KILLS )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_NPC_KILLS )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_ASSISTS )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_DEATHS )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_SCORE )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_HARDPOINT )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_ASSAULT )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_DEFENSE )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_FLAG_RETURN )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_FLAG_CAPTURE )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_VICTORY_CONTRIBUTION )
}

function InitMenu()
{
	Assert( menu != null )

	// Buttons & Background
	SetupEOGMenuCommon( menu )

	uiGlobal.eogScoreboardFocusedButton = null

	if ( !playerButtonsRegistered )
	{
		AddEventHandlerToButtonClass( menu, "BtnEOGScoreboardPlayer", UIE_GET_FOCUS, ScoreboardPlayerButton_GetFocus )
		AddEventHandlerToButtonClass( menu, "BtnEOGScoreboardPlayer", UIE_LOSE_FOCUS, ScoreboardPlayerButton_LoseFocus )
		AddEventHandlerToButtonClass( menu, "BtnEOGScoreboardPlayer", UIE_CLICK, ScoreboardPlayerButton_Click )
		playerButtonsRegistered = true
	}
}

function OnOpenEOG_Scoreboard()
{
	menu = GetMenu( "EOG_Scoreboard" )
	level.currentEOGMenu = menu
	Signal( level, "CancelEOGThreadedNavigation" )

	InitMenu()
	ShowScoreboard()

	EOGOpenGlobal()

	//wait 5
	//if ( uiGlobal.activeMenu == GetMenu( "EOG_Scoreboard" ) )
	//	CloseTopMenu()
}

function OnCloseEOG_Scoreboard()
{
	thread EOGCloseGlobal()
}

function ShowScoreboard()
{
	EmitUISound( "EOGSummary.XPBreakdownPopup" )

	local logos = {}
	logos[ TEAM_IMC ] <- "../ui/scoreboard_imc_logo"
	logos[ TEAM_MILITIA ] <- "../ui/scoreboard_mcorp_logo"

	local friendlyTeam = GetPersistentVar( "savedScoreboardData.playerTeam" )
	local enemyTeam = GetEnemyTeam( friendlyTeam )

	local scores = {}
	scores[ TEAM_IMC ] <- GetPersistentVar( "savedScoreboardData.scoreIMC" )
	scores[ TEAM_MILITIA ] <- GetPersistentVar( "savedScoreboardData.scoreMCOR" )
	local winningTeam = friendlyTeam
	if ( scores[ TEAM_IMC ] != scores[ TEAM_MILITIA ] )
		winningTeam = scores[ TEAM_IMC ] > scores[ TEAM_MILITIA ] ? TEAM_IMC : TEAM_MILITIA
	local losingTeam = GetEnemyTeam( winningTeam )

	local numPlayers = {}
	numPlayers[ TEAM_IMC ] <- GetPersistentVar( "savedScoreboardData.numPlayersIMC" )
	numPlayers[ TEAM_MILITIA ] <- GetPersistentVar( "savedScoreboardData.numPlayersMCOR" )
	Assert( numPlayers[ winningTeam ] > 0 || numPlayers[ losingTeam ] > 0 )

	//########################################
	// 			Game mode and map
	//########################################

	local storedMode = GetPersistentVar( "savedScoreboardData.gameMode" )
	local storedModeString = PersistenceGetEnumItemNameForIndex( "gameModes", storedMode )
	local storedMap = GetPersistentVar( "savedScoreboardData.map" )

	local storedMapString = "dev map"
	if ( storedMap != -1 )
		storedMapString = PersistenceGetEnumItemNameForIndex( "maps", storedMap )

	local mapName
	if ( GetPersistentVar( "savedScoreboardData.campaign" ) == true )
		mapName = GetCampaignMapDisplayName( storedMapString )
	else
		mapName = GetMapDisplayName( storedMapString )

	GetElem( menu, "GametypeAndMap" ).SetText( "#VAR_DASH_VAR", GAMETYPE_TEXT[ storedModeString ], mapName )
	//GetElem( menu, "GametypeDesc" ).SetText( GAMETYPE_DESC[ storedModeString ] )

	//########################################
	// 				Team Logos
	//########################################

	local winningTeamLogo = GetElem( menu, "ScoreboardWinningTeamLogo" )
	winningTeamLogo.SetImage( logos[ winningTeam ] )

	local losingTeamLogo = GetElem( menu, "ScoreboardLosingTeamLogo" )
	losingTeamLogo.SetImage( logos[ losingTeam ] )

	//########################################
	// 			Team score totals
	//########################################

	GetElem( menu, "ScoreboardWinningTeamScore" ).SetText( scores[ winningTeam ].tostring() )
	GetElem( menu, "ScoreboardLosingTeamScore" ).SetText( scores[ losingTeam ].tostring() )

	//########################################
	// 			Match loss protection
	//########################################

	if ( GetPersistentVar( "savedScoreboardData.hadMatchLossProtection" ) )
		GetElem( menu, "ScoreboardLossProtection" ).Show()
	else
		GetElem( menu, "ScoreboardLossProtection" ).Hide()

	//########################################
	// 		  Scoreboard categories
	//########################################

	local scoreboardValueNames = []
	if ( storedModeString == CAPTURE_POINT )
	{
		// added RIGHT to LEFT
		ShowScoreboardColumn( 6, "deaths" )
		ShowScoreboardColumn( 5, "pilotKills" )
		ShowScoreboardColumn( 4, "defense", true )
		ShowScoreboardColumn( 3, "hardpoint", true )
		ShowScoreboardColumn( 2, null )
		ShowScoreboardColumn( 1, null )
		ShowScoreboardColumn( 0, null )

		scoreboardValueNames.append( { var = "score_deaths", highlight = false } )
		scoreboardValueNames.append( { var = "score_kills", highlight = false } )
		scoreboardValueNames.append( { var = "score_defense", highlight = true } )
		scoreboardValueNames.append( { var = "score_assault", highlight = true } )
	}
	else if ( storedModeString == ATTRITION )
	{
		// added RIGHT to LEFT
		ShowScoreboardColumn( 6, "deaths" )
		ShowScoreboardColumn( 5, "npcKills" )
		ShowScoreboardColumn( 4, "titanKills" )
		ShowScoreboardColumn( 3, "pilotKills" )
		ShowScoreboardColumn( 2, "victory", true )
		ShowScoreboardColumn( 1, null )
		ShowScoreboardColumn( 0, null )

		scoreboardValueNames.append( { var = "score_deaths", highlight = false } )
		scoreboardValueNames.append( { var = "score_npcKills", highlight = false } )
		scoreboardValueNames.append( { var = "score_titanKills", highlight = false } )
		scoreboardValueNames.append( { var = "score_kills", highlight = false } )
		scoreboardValueNames.append( { var = "score_assault", highlight = true } )
	}
	else if ( storedModeString == CAPTURE_THE_FLAG )
	{
		// added RIGHT to LEFT
		ShowScoreboardColumn( 6, "deaths" )
		ShowScoreboardColumn( 5, "titanKills" )
		ShowScoreboardColumn( 4, "pilotKills" )
		ShowScoreboardColumn( 3, "returns" )
		ShowScoreboardColumn( 2, "captures", true )
		ShowScoreboardColumn( 1, null )
		ShowScoreboardColumn( 0, null )

		scoreboardValueNames.append( { var = "score_deaths", highlight = false } )
		scoreboardValueNames.append( { var = "score_titanKills", highlight = false } )
		scoreboardValueNames.append( { var = "score_kills", highlight = false } )
		scoreboardValueNames.append( { var = "score_defense", highlight = false } )
		scoreboardValueNames.append( { var = "score_assault", highlight = true } )
	}
	else if ( storedModeString == MARKED_FOR_DEATH ||  storedModeString == MARKED_FOR_DEATH_PRO )
	{
			ShowScoreboardColumn( 6, "deaths" )
			ShowScoreboardColumn( 5, "titanKills" )
			ShowScoreboardColumn( 4, "pilotKills" )
			ShowScoreboardColumn( 3, "mfd_marksOutlasted" )
			ShowScoreboardColumn( 2, "mfd_markedKills", true )
			ShowScoreboardColumn( 1, null )
			ShowScoreboardColumn( 0, null )

			scoreboardValueNames.append( { var = "score_deaths", highlight = false } )
			scoreboardValueNames.append( { var = "score_titanKills", highlight = false } )
			scoreboardValueNames.append( { var = "score_kills", highlight = false } )
			scoreboardValueNames.append( { var = "score_defense", highlight = false } )
			scoreboardValueNames.append( { var = "score_assault", highlight = true } )
	}
	else if ( storedModeString == LAST_TITAN_STANDING || storedModeString == WINGMAN_LAST_TITAN_STANDING )
	{
		// added RIGHT to LEFT
		ShowScoreboardColumn( 6, "assists" )
		ShowScoreboardColumn( 5, "pilotKills" )
		ShowScoreboardColumn( 4, "deaths" )
		ShowScoreboardColumn( 3, "titanKills", true )
		ShowScoreboardColumn( 2, null )
		ShowScoreboardColumn( 1, null )
		ShowScoreboardColumn( 0, null )

		scoreboardValueNames.append( { var = "score_assists", highlight = false } )
		scoreboardValueNames.append( { var = "score_kills", highlight = false } )
		scoreboardValueNames.append( { var = "score_deaths", highlight = false } )
		scoreboardValueNames.append( { var = "score_titanKills", highlight = true } )
	}
	else
	{
		// added RIGHT to LEFT
		ShowScoreboardColumn( 6, "assists" )
		ShowScoreboardColumn( 5, "titanKills" )
		ShowScoreboardColumn( 4, "deaths", true )
		ShowScoreboardColumn( 3, "pilotKills", true )
		ShowScoreboardColumn( 2, null )
		ShowScoreboardColumn( 1, null )
		ShowScoreboardColumn( 0, null )

		scoreboardValueNames.append( { var = "score_assists", highlight = false } )
		scoreboardValueNames.append( { var = "score_titanKills", highlight = false } )
		scoreboardValueNames.append( { var = "score_deaths", highlight = true } )
		scoreboardValueNames.append( { var = "score_kills", highlight = true } )
	}

	//########################################
	// 		  List each player info
	//########################################

	local playerDataVars = {}
	playerDataVars[ TEAM_IMC ] <- "playersIMC"
	playerDataVars[ TEAM_MILITIA ] <- "playersMCOR"

	local maxTeamPlayers = GetPersistentVar( "savedScoreboardData.maxTeamPlayers" )

	// Winning team
	local friendlyColor = friendlyTeam == winningTeam
	local playerDataVar = playerDataVars[ winningTeam ]
	for ( local i = 0 ; i < MAX_PLAYERS_PER_TEAM ; i++ )
	{
		local panelName = "WinningPlayer" + i
		local buttonName = "BtnWinningPlayer" + i
		if ( i >= maxTeamPlayers )
			UpdatePlayerBar( panelName, buttonName, friendlyColor, i, null, null, false )	// Completely hide player slot
		else if ( i < numPlayers[ winningTeam ] )
			UpdatePlayerBar( panelName, buttonName, friendlyColor, i, playerDataVar, scoreboardValueNames )	// Show player info in slot
		else
			UpdatePlayerBar( panelName, buttonName, friendlyColor, i )	// empty player slot
	}

	// Losing team
	friendlyColor = friendlyTeam == losingTeam
	playerDataVar = playerDataVars[ losingTeam ]
	for ( local i = 0 ; i < MAX_PLAYERS_PER_TEAM ; i++ )
	{
		local panelName = "LosingPlayer" + i
		local buttonName = "BtnLosingPlayer" + i
		if ( i >= maxTeamPlayers )
			UpdatePlayerBar( panelName, buttonName, friendlyColor, i, null, null, false )	// Completely hide player slot
		else if ( i < numPlayers[ losingTeam ] )
			UpdatePlayerBar( panelName, buttonName, friendlyColor, i, playerDataVar, scoreboardValueNames )	// Show player info in slot
		else
			UpdatePlayerBar( panelName, buttonName, friendlyColor, i )	// empty player slot
	}
}

function UpdatePlayerBar( panelName, buttonName, friendlyColor, index, teamVar = null, valueNames = null, visible = true )
{
	local panel = GetElem( menu, panelName )
	Assert( panel != null )

	// Background
	local background = panel.GetChild( "Background" )
	if ( teamVar == null )
	{
		if ( friendlyColor )
			background.SetImage( SCOREBOARD_MATERIAL_FRIENDLY_SLOT )
		else
			background.SetImage( SCOREBOARD_MATERIAL_ENEMY_SLOT )
	}
	else
	{
		if ( friendlyColor )
			background.SetImage( SCOREBOARD_MATERIAL_FRIENDLY_PLAYER_EVEN )
		else
			background.SetImage( SCOREBOARD_MATERIAL_ENEMY_PLAYER_EVEN )
	}
	if ( visible )
		background.Show()
	else
		background.Hide()

	// Player name
	local nameLabel = panel.GetChild( "PlayerName" )
	if ( teamVar == null )
		nameLabel.Hide()
	else
	{
		local playerName = GetPersistentVar( "savedScoreboardData." + teamVar + "[" + index + "].name" )
		nameLabel.SetText( playerName )
		nameLabel.Show()

		if ( friendlyColor && GetPersistentVar( "savedScoreboardData.playerIndex" ) == index )
			nameLabel.SetColor( LOCALPLAYER_NAME_COLOR[0], LOCALPLAYER_NAME_COLOR[1], LOCALPLAYER_NAME_COLOR[2] )
		else
			nameLabel.SetColor( 230, 230, 230 )
	}

	// Player UID button
	local button = GetElementsByClassname( menu, buttonName )[0]
	Assert( button != null )

	if ( "playerUID" in button.s )
		delete button.s.playerUID

	if ( teamVar == null )
		button.SetEnabled( false )
	else
	{
		button.SetEnabled( true )
		button.s.playerUID <- GetPersistentVar( "savedScoreboardData." + teamVar + "[" + index + "].xuid" )
	}

	// Player level
	local levelLabel = panel.GetChild( "PlayerLevel" )
	if ( teamVar == null )
	{
		levelLabel.SetText( "" )
		levelLabel.Hide()
	}
	else
	{
		local playerLevel = GetPersistentVar( "savedScoreboardData." + teamVar + "[" + index + "].level" )
		levelLabel.SetText( playerLevel.tostring() )
		levelLabel.Show()
	}

	// Player gen or rank icon
	local genLabel = panel.GetChild( "GenIcon" )
	if ( teamVar == null )
	{
		genLabel.SetImage( "" )
		genLabel.Hide()
	}
	else
	{
		local imageName

		if ( GetPersistentVar( "savedScoreboardData." + teamVar + "[" + index + "].playingRanked" ) )
		{
			local playerRank = GetPersistentVar( "savedScoreboardData." + teamVar + "[" + index + "].rank" )
			imageName =  GetRankImage( playerRank )
		}
		else
		{
			local playerGen = GetPersistentVar( "savedScoreboardData." + teamVar + "[" + index + "].gen" )
			imageName = "../ui/menu/generation_icons/generation_" + playerGen
		}

		genLabel.SetImage( imageName )
		genLabel.Show()
	}

	// Score values
	for( local i = 6 ; i >= 0 ; i-- )
	{
		local value = panel.GetChild( "ColumnValue" + i )
		local line = panel.GetChild( "ColumnValueLine" + i )

		if ( valueNames == null || i < 7 - valueNames.len() )
		{
			value.Hide()
			line.Hide()
		}
		else
		{
			local var = valueNames[ 6 - i ].var
			local highlight = valueNames[ 6 - i ].highlight
			local val = GetPersistentVar( "savedScoreboardData." + teamVar + "[" + index + "]." + var )
			value.SetText( val.tostring() )
			value.Show()
			line.Show()

			if ( highlight )
			{
				value.SetColor( data_highlight_color )
				if ( friendlyColor )
					value.SetColorBG( data_highlight_bg_color_friendly )
				else
					value.SetColorBG( data_highlight_bg_color_enemy )
			}
			else
			{
				value.SetColor( data_default_color )
				value.SetColorBG( data_no_highlight_bg_color )

			}
		}
	}
}

function ShowScoreboardColumn( index, varType, highlight = false )
{
	local descLabel = GetElem( menu, "ScoreboardColumnLabels" + index )
	local iconBackground = GetElem( menu, "ScoreboardColumnIconBackground" + index )
	local icon = GetElem( menu, "ScoreboardColumnIcon" + index )

	switch( varType )
	{
		case "assists":
			descLabel.SetText( "#SCOREBOARD_ASSISTS" )
			icon.SetImage( SCOREBOARD_MATERIAL_ASSISTS )
			break

		case "titanKills":
			descLabel.SetText( "#SCOREBOARD_TITAN_KILLS" )
			icon.SetImage( SCOREBOARD_MATERIAL_TITAN_KILLS )
			break

		case "deaths":
			descLabel.SetText( "#SCOREBOARD_DEATHS" )
			icon.SetImage( SCOREBOARD_MATERIAL_DEATHS )
			break

		case "pilotKills":
			descLabel.SetText( "#SCOREBOARD_PILOT_KILLS" )
			icon.SetImage( SCOREBOARD_MATERIAL_PILOT_KILLS )
			break

		case "returns":
			descLabel.SetText( "#SCOREBOARD_RETURNS" )
			icon.SetImage( SCOREBOARD_MATERIAL_FLAG_RETURN )
			break

		case "hardpoint":
			descLabel.SetText( "#SCOREBOARD_ASSAULT" )
			icon.SetImage( SCOREBOARD_MATERIAL_HARDPOINT )
			break

		case "assault":
			descLabel.SetText( "#SCOREBOARD_ASSAULT" )
			icon.SetImage( SCOREBOARD_MATERIAL_ASSAULT )
			break

		case "captures":
			descLabel.SetText( "#SCOREBOARD_CAPTURES" )
			icon.SetImage( SCOREBOARD_MATERIAL_FLAG_CAPTURE )
			break

		case "npcKills":
			descLabel.SetText( "#SCOREBOARD_GRUNT_KILLS" )
			icon.SetImage( SCOREBOARD_MATERIAL_NPC_KILLS )
			break

		case "victory":
			descLabel.SetText( "#SCOREBOARD_AT_POINTS" )
			icon.SetImage( SCOREBOARD_MATERIAL_VICTORY_CONTRIBUTION )
			break

		case "defense":
			descLabel.SetText( "#SCOREBOARD_DEFENSE" )
			icon.SetImage( SCOREBOARD_MATERIAL_DEFENSE )
			break

		case "mfd_markedKills":
			descLabel.SetText( "#SCOREBOARD_MFD_SCORE" )
			icon.SetImage( SCOREBOARD_MATERIAL_MARKED_FOR_DEATH_TARGET_KILLS )
			break

		case "mfd_marksOutlasted":
			descLabel.SetText( "#SCOREBOARD_MFD_MARKS_OUTLASTED" )
			icon.SetImage( SCOREBOARD_MATERIAL_DEFENSE )
			break

		default:
			Assert( varType == null )
			break
	}

	if ( varType == null )
	{
		descLabel.Hide()
		iconBackground.Hide()
		icon.Hide()
	}
	else
	{
		if ( highlight )
		{
			descLabel.SetColor( header_highlight_color )
			icon.SetAlpha( 255 )
		}
		else
		{
			descLabel.SetColor( header_default_color )
			icon.SetAlpha( 127 )
		}

		descLabel.Show()
		iconBackground.Show()
		icon.Show()
	}
}

function ScoreboardPlayerButton_GetFocus( button )
{
	uiGlobal.eogScoreboardFocusedButton = button
	UpdateFooterButtons()
}

function ScoreboardPlayerButton_LoseFocus( button )
{
	uiGlobal.eogScoreboardFocusedButton = null
	UpdateFooterButtons()
}

function ScoreboardPlayerButton_Click( button )
{
	Assert( "playerUID" in button.s )
	if ( button.s.playerUID != "" )
		ShowPlayerProfileCardForUID( button.s.playerUID )
}

function EOGScoreboard_FooterData( footerData )
{
	footerData.gamepad.append( { label = "#B_BUTTON_BACK" } )
	footerData.pc.append( { label = "#BACK", func = PCBackButton_Activate } )

	if ( uiGlobal.eogScoreboardFocusedButton != null && ("playerUID" in uiGlobal.eogScoreboardFocusedButton.s) )
	{
		footerData.pc.append( { label = "#MOUSE1_VIEW_PLAYER_PROFILE" } )
		if ( Durango_IsDurango() )
			footerData.gamepad.append( { label = "#A_BUTTON_GAMERCARD" } )
		else
			footerData.gamepad.append( { label = "#A_BUTTON_PLAYER_PROFILE" } )
	}
}