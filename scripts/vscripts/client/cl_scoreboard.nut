const MAX_SCORE_COLUMNS = 7
const SCOREBOARD_MATERIAL_GEN1 = "../ui/menu/generation_icons/generation_0"
const SCOREBOARD_MATERIAL_GEN2 = "../ui/menu/generation_icons/generation_1"
const SCOREBOARD_MATERIAL_GEN3 = "../ui/menu/generation_icons/generation_2"
const SCOREBOARD_MATERIAL_GEN4 = "../ui/menu/generation_icons/generation_3"
const SCOREBOARD_MATERIAL_GEN5 = "../ui/menu/generation_icons/generation_4"
const SCOREBOARD_MATERIAL_GEN6 = "../ui/menu/generation_icons/generation_5"
const SCOREBOARD_MATERIAL_GEN7 = "../ui/menu/generation_icons/generation_6"
const SCOREBOARD_MATERIAL_GEN8 = "../ui/menu/generation_icons/generation_7"
const SCOREBOARD_MATERIAL_GEN9 = "../ui/menu/generation_icons/generation_8"
const SCOREBOARD_MATERIAL_GEN10 = "../ui/menu/generation_icons/generation_9"

const SCOREBOARD_BACKGROUND = "../ui/menu/scoreboard/scoreboard"

function main()
{
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_FRIENDLY_PLAYER_EVEN )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_FRIENDLY_PLAYER_ODD )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_FRIENDLY_SLOT )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_ENEMY_PLAYER_EVEN )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_ENEMY_PLAYER_ODD )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_ENEMY_SLOT )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_MIC_INACTIVE )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_MIC_ACTIVE )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_MIC_MUTED )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_MIC_PARTYCHAT )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_STATUS_DEAD )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_STATUS_TITAN )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_STATUS_PILOT )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_STATUS_ALIVE_WITH_PET )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_STATUS_DEAD_WITH_PET )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_STATUS_EVAC )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_STATUS_TITAN_BURN )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_STATUS_TITAN_BURN_ENEMY )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_STATUS_PILOT_BURN )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_STATUS_PILOT_BURN_ENEMY )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_STATUS_ALIVE_WITH_PET_PILOT_BURN )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_STATUS_ALIVE_WITH_PET_PILOT_BURN_ENEMY )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_STATUS_ALIVE_WITH_PET_TITAN_BURN )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_STATUS_ALIVE_WITH_PET_TITAN_BURN_ENEMY )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_STATUS_DEAD_WITH_PET_BURN )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_STATUS_DEAD_WITH_PET_BURN_ENEMY )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_CONNECTION_QUALITY_1 )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_CONNECTION_QUALITY_2 )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_CONNECTION_QUALITY_3 )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_CONNECTION_QUALITY_4 )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_CONNECTION_QUALITY_5 )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_GEN1 )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_GEN2 )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_GEN3 )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_GEN4 )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_GEN5 )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_GEN6 )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_GEN7 )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_GEN8 )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_GEN9 )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_GEN10 )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_PROMO )
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

	//CoOp Precaches
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_COOP_TITAN )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_COOP_EMP_TITAN )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_COOP_MORTAR_TITAN )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_COOP_NUKE_TITAN )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_COOP_SUICIDE_SPECTRE )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_COOP_SNIPER_SPECTRE )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_COOP_SPECTRE )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_COOP_GRUNT )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_COOP_CLOAK_DRONE )

	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_COOP_BACKGROUND )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_COOP_INFO_BOX )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_COOP_STARS )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_COOP_STARS_EMPTY )

	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_COOP_PLAYER_NUMBER_1 )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_COOP_PLAYER_NUMBER_2 )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_COOP_PLAYER_NUMBER_3 )
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_COOP_PLAYER_NUMBER_4 )

	//Gamemode specific material. Long term need better way to do this.
	PrecacheHUDMaterial( SCOREBOARD_MATERIAL_MARKED_FOR_DEATH_TARGET_KILLS )

	// Precache the ranked icons
	for ( local i = 1; i <= RANKED_TIER_COUNT; i++ )
	{
		for ( local j = 1; j <= RANKED_DIVISION_COUNT; j++ )
		{
			PrecacheHUDMaterial( "../ui/menu/rank_icons/tier_" + i + "_" + j )
		}
	}

	Globalize( InitScoreboard )
	Globalize( ShowScoreboard )
	Globalize( HideScoreboard )
	Globalize( IsInScoreboard )
	Globalize( ClientCodeCallback_ScoreboardSelectionInput )
	Globalize( ClientCodeCallback_ToggleScoreboard )
	Globalize( AddColumnLabel )

	RegisterServerVarChangeCallback( "gameState", GameStateChanged )

	if ( !IsTrainingLevel() )
	{
		RegisterConCommandTriggeredCallback( "+showscores", ScoreboardButtonPressed )
		RegisterMenuButtonPressedCallback( BUTTON_BACK, ScoreboardButtonPressed )
	}

	if ( GAMETYPE == COOPERATIVE )
	{
		// only supporting ten waves at this point.
		level.waveNumberToString <- []
		level.waveNumberToString.append( "#TD_WAVE_ONE" )
		level.waveNumberToString.append( "#TD_WAVE_TWO" )
		level.waveNumberToString.append( "#TD_WAVE_THREE" )
		level.waveNumberToString.append( "#TD_WAVE_FOUR" )
		level.waveNumberToString.append( "#TD_WAVE_FIVE" )
		level.waveNumberToString.append( "#TD_WAVE_SIX" )
		level.waveNumberToString.append( "#TD_WAVE_SEVEN" )
		level.waveNumberToString.append( "#TD_WAVE_EIGHT" )
		level.waveNumberToString.append( "#TD_WAVE_NINE" )
		level.waveNumberToString.append( "#TD_WAVE_TEN" )
		level.waveNumberToString.append( "A Wave Too Many:" )
	}

	RegisterSignal( "OnHideScoreboard" )

	file.showingScoreboard <- false
	file.selectedPlayer <- null
	file.prevPlayer <- null
	file.nextPlayer <- null
	file.developer <- GetDeveloperLevel()

	file.evacPlayers <- {}

	file.menuColorCorrection <- ColorCorrection_Register( "materials/correction/menu_background.raw" )

	AddKillReplayStartedCallback( HideCrosshairIfScoreBoardIsShowing )
}

function ClientCodeCallback_ToggleScoreboard()
{
	if ( IsTrainingLevel() )
		return

	ScoreboardButtonPressed( null )
}

function IsInScoreboard( player )
{
	return file.showingScoreboard
}

function ScoreboardButtonPressed( localPlayer )
{
	if ( GetGameState() == eGameState.Postmatch )
		return

	//HACK - Need to update COOP to use GameStateEpilogue/Postmatch in a proper fashion.
	if ( GAMETYPE == COOPERATIVE && Coop_IsGameOver() )
		return

	if ( file.showingScoreboard )
		HideScoreboard()
	else
		thread ShowScoreboard()
}

function AddColumnLabel( scoreboard, varName, icon, headerString, minWidth, highlight, updateFunc, columnLocalize = "#SCOREBOARD_N" )
{
	Assert( !( varName in file.columnLabels ) )

	file.numScoreColums++
	local resIndex = MAX_SCORE_COLUMNS - file.numScoreColums

	file.columnIconBackgrounds[ varName ] <- HudElement( "ScoreboardColumnIconBackground" + resIndex, scoreboard )

	file.columnIcons[ varName ] <- HudElement( "ScoreboardColumnIcon" + resIndex, scoreboard )
	file.columnIcons[ varName ].SetImage( icon )

	file.columnLabels[ varName ] <- HudElement( "ScoreboardColumnLabels" + resIndex, scoreboard )
	file.columnLabels[ varName ].SetText( headerString )

	local hudElement = HudElement( "ScoreboardEnemyTeamDataColumnLine" + resIndex, scoreboard )
	file.enemyColumnLines.AddElement( hudElement )
	file.columnLines.append( hudElement )
	file.columnLines.append( HudElement( "ScoreboardMyTeamDataColumnLine" + resIndex, scoreboard ) )

	file.nameEndColumn = file.columnLines[file.columnLines.len()-1]

	if ( highlight )
		file.columnLabels[ varName ].SetColor( file.header_highlight_color )
	else
		file.columnLabels[ varName ].SetColor( file.header_default_color )

	file.highlightColumns[ varName ] <- highlight

	local labelWidth = max( minWidth, file.columnLabels[ varName ].GetWidth() )

	file.columnLabelsWidths[ varName ] <- labelWidth
	file.columnLabelsIndexes[ varName ] <- resIndex
	file.columnLabelsUpdateFuncs[ varName ] <- updateFunc
	file.columnLabelsLocalize[ varName ] <- columnLocalize
}

function InitScoreboard()
{
	local localPlayer = GetLocalClientPlayer()
	local myTeam = localPlayer.GetTeam()
	local enemyTeam = GetEnemyTeam( myTeam )

	local mapName
	if ( GetCinematicMode() )
		mapName = GetCampaignMapDisplayName( GetMapName() )
	else
		mapName = GetMapDisplayName( GetMapName() )

	local numTeamPlayers = GetNumTeamPlayers()

	file.numScoreColums <- 0
	file.header_default_color <- [155, 178, 194]
	file.header_highlight_color <- [204, 234, 255]
	file.data_default_color <- [155, 178, 194]
	file.data_highlight_color <- [230, 230, 230]
	file.data_highlight_bg_color <- {}
	file.data_highlight_bg_color[myTeam] <- [0, 138, 166]
	file.data_highlight_bg_color[enemyTeam] <- [156, 71, 6]

	local scoreboard = HudElement( "Scoreboard" )
	file.scoreboard <- scoreboard

	file.background <- HudElement( "ScoreboardBackground", scoreboard )
	if ( numTeamPlayers > 6 )
	{
		file.background.SetImage( "HUD/white" )
		file.background.SetColor( 0, 0, 0, 240 )
		file.background.SetHeight( level.screenSize[1] * 0.875 )
		file.background.SetY( -18 )
	}

	file.header <- {}
	file.header.background <- HudElement( "ScoreboardHeaderBackground", scoreboard )
	file.header.gametypeAndMap <- HudElement( "ScoreboardGametypeAndMap", scoreboard )
	file.header.gametypeAndMap.SetText( "#VAR_DASH_VAR", GAMETYPE_TEXT[ GAMETYPE ], mapName )
	file.header.gametypeDesc <- HudElement( "ScoreboardHeaderGametypeDesc", scoreboard )
	file.header.gametypeDesc.SetText( GAMETYPE_DESC[ GAMETYPE ] )
	file.header.lossProtection <- HudElement( "ScoreboardLossProtection", scoreboard )

	file.teamElems <- {}
	file.teamElems[myTeam] <- {}
	file.teamElems[myTeam].logo <- HudElement( "ScoreboardMyTeamLogo", scoreboard )
	file.teamElems[myTeam].score <- HudElement( "ScoreboardMyTeamScore", scoreboard )

	file.teamElems[enemyTeam] <- {}
	file.teamElems[enemyTeam].logo <- HudElement( "ScoreboardEnemyTeamLogo", scoreboard )
	file.teamElems[enemyTeam].score <- HudElement( "ScoreboardEnemyTeamScore", scoreboard )

	file.teamElems[TEAM_IMC].logo.SetImage( "../ui/scoreboard_imc_logo" )
	file.teamElems[TEAM_MILITIA].logo.SetImage( "../ui/scoreboard_mcorp_logo" )

	file.columnIconBackgrounds <- {}
	file.columnIcons <- {}
	file.columnLabels <- {}
	file.columnLabelsWidths <- {}
	file.columnLabelsIndexes <- {}
	file.columnLabelsUpdateFuncs <- {}
	file.columnLabelsLocalize <- {}

	InitColumnLines( scoreboard )

	file.highlightColumns <- {}

	file.nameEndColumn <- null

	if ( GAMETYPE == COOPERATIVE )
		InitCoopScoreboard( scoreboard )

	AddColumnsForGameMode( scoreboard )

	file.playerElems <- {}
	file.playerElems[myTeam] <- []
	file.playerElems[enemyTeam] <- []

	local teams = [ myTeam, enemyTeam ]
	local prefix

	foreach ( team in teams )
	{
		if ( team == myTeam )
			prefix = "ScoreboardTeammate"
		else
			prefix = "ScoreboardOpponent"

		for ( local elem = 0; elem < level.maxTeamSize; elem++  )
		{
			local elemNum = elem.tostring()

			local table = {}
			table.background <- HudElement( prefix + "Background" + elemNum, scoreboard )
			table.selection <- HudElement( prefix + "Selection" + elemNum, scoreboard )
			table.playerNumber <- HudElement( prefix + "PlayerNumber" + elemNum, scoreboard )
			if( GAMETYPE != COOPERATIVE )
				table.playerNumber.SetWidth( 0 )
			table.status <- HudElement( prefix + "Status" + elemNum, scoreboard )
			local art = HudElement( prefix + "Art" + elemNum, scoreboard )
			table.artImage <- HudElement( "ArtImage", art )

			table.lvl <- HudElement( prefix + "Lvl" + elemNum, scoreboard )
			table.name <- HudElement( prefix + "Name" + elemNum, scoreboard )
			table.mic <- HudElement( prefix + "Mic" + elemNum, scoreboard )
			table.leader <- HudElement( prefix + "PartyLeader" + elemNum, scoreboard )
			table.connection <- HudElement( prefix + "Connection" + elemNum, scoreboard )
			if ( file.developer )
				table.ping <- HudElement( prefix + "Ping" + elemNum, scoreboard )

			foreach( varName, elem in file.columnLabels )
			{
				Assert( !( varName in table ) )

				local resIndex = file.columnLabelsIndexes[ varName ].tostring()
				local width = file.columnLabelsWidths[ varName ]

				table[varName] <- HudElement( prefix + "Column" + resIndex + "_" + elemNum, scoreboard )
				table[varName].SetWidth( width )

				if ( file.highlightColumns[varName] )
				{
					table[varName].SetColor( file.data_highlight_color )
					table[varName].SetColorBG( file.data_highlight_bg_color[team] )
				}
				else
				{
					table[varName].SetColor( file.data_default_color )
					file.columnIcons[varName].SetAlpha( 127 )
				}
			}

			file.playerElems[team].append( table )
		}
	}

	file.header.gametypeAndMap.Show()
	file.header.gametypeDesc.Show()

	file.teamElems[myTeam].logo.Show()
	file.teamElems[myTeam].score.Show()
	file.teamElems[enemyTeam].logo.Show()
	file.teamElems[enemyTeam].score.Show()

	foreach( elem in file.columnIconBackgrounds )
		elem.Show()

	foreach( elem in file.columnIcons )
		elem.Show()

	foreach( elem in file.columnLabels )
		elem.Show()

	foreach( elem in file.columnLines )
		elem.Show()

	local gamepadButtons = []
	gamepadButtons.append( HudElement( "ScoreboardGamepadFooterButton0", scoreboard ) )
	gamepadButtons.append( HudElement( "ScoreboardGamepadFooterButton1", scoreboard ) )

	foreach ( button in gamepadButtons )
		button.EnableKeyBindingIcons()

	//delaythread(2) ShowScoreboard()
}

function ShowScoreboard()
{
	if ( file.showingScoreboard )
		return

	file.showingScoreboard = true

	local localPlayer = GetLocalClientPlayer()
	local myTeam = localPlayer.GetTeam()
	local enemyTeam = GetEnemyTeam( myTeam )

	local localPlayerPlayingRanked = PlayerPlayingRanked( localPlayer )
	UpdateClientHudVisibility( localPlayer )

	if ( !IsValid( file.selectedPlayer ) )
		file.selectedPlayer = localPlayer
	SetScoreboardPlayer( file.selectedPlayer )

	EndSignal( file, "OnHideScoreboard" )
	UpdateMainHudVisibility( localPlayer, 0.0 )
	HideScriptHUD( localPlayer )
	SetCrosshairPriorityState( crosshairPriorityLevel.MENU, CROSSHAIR_STATE_HIDE_ALL )
	ColorCorrection_SetExclusive( file.menuColorCorrection, true )
	ColorCorrection_SetWeight( file.menuColorCorrection, 1.0 )

	local screenSize = Hud.GetScreenSize()
	local resMultiplier = screenSize[1] / 480.0

	local numTeamPlayers = GetNumTeamPlayers()
	local playerSeperatorHeight = (1 * resMultiplier).tointeger()
	local playerHeight = (20 * resMultiplier).tointeger()
	local teamSeparatorHeight = (8 * resMultiplier).tointeger()
	local losingTeamYOffset = (((21 * numTeamPlayers) + 5) * resMultiplier).tointeger()

	file.background.Show()
	file.header.background.Show()
	if ( level.hasMatchLossProtection )
		file.header.lossProtection.Show()
	else
		file.header.lossProtection.Hide()

	local headerHeight = file.header.background.GetHeight()
	local teamHeight = (playerHeight + playerSeperatorHeight) * numTeamPlayers - playerSeperatorHeight

	foreach ( line in file.columnLines )
		line.SetHeight( teamHeight )

	if( GAMETYPE == COOPERATIVE )
		file.enemyColumnLines.Hide()

	local index
	local elemTable

	local teamPlayers = {}
	teamPlayers[myTeam] <- []
	teamPlayers[enemyTeam] <- []

	local teamColors = {}
	teamColors[myTeam] <- FRIENDLY_COLOR
	teamColors[enemyTeam] <- ENEMY_COLOR

	local playerSlotFilledEven = {}
	playerSlotFilledEven[myTeam] <- SCOREBOARD_MATERIAL_FRIENDLY_PLAYER_EVEN
	playerSlotFilledEven[enemyTeam] <- SCOREBOARD_MATERIAL_ENEMY_PLAYER_EVEN

	local playerSlotFilledOdd = {}
	playerSlotFilledOdd[myTeam] <- SCOREBOARD_MATERIAL_FRIENDLY_PLAYER_ODD
	playerSlotFilledOdd[enemyTeam] <- SCOREBOARD_MATERIAL_ENEMY_PLAYER_ODD

	local playerSlotEmpty = {}
	playerSlotEmpty[myTeam] <- SCOREBOARD_MATERIAL_FRIENDLY_SLOT
	playerSlotEmpty[enemyTeam] <- SCOREBOARD_MATERIAL_ENEMY_SLOT

	local teamScore = {}
	teamScore[myTeam] <- []
	teamScore[enemyTeam] <- []

	local winningTeam
	local losingTeam
	local nameMeasureElem = file.playerElems[myTeam][0].name
	local compareFunc = GetScoreboardCompareFunc( localPlayer )
	local ping

	file.scoreboard.Show()

	for ( ;; )
	{
		localPlayer = GetLocalClientPlayer()

		teamPlayers[myTeam] = GetSortedPlayers( compareFunc, myTeam )
		teamPlayers[enemyTeam] = GetSortedPlayers( compareFunc, enemyTeam )

		Assert( file.showingScoreboard )
		if ( !IsValid( file.selectedPlayer ) )
		{
			if ( IsValid( file.nextPlayer ) )
				file.selectedPlayer = file.nextPlayer
			else
				file.selectedPlayer = localPlayer
			SetScoreboardPlayer( file.selectedPlayer )
		}

		if ( IsRoundBased() )
		{
			if( GAMETYPE == COOPERATIVE )
				teamScore[myTeam] <- level.nv.TDCurrentTeamScore
			else
				teamScore[myTeam] <- GameRules.GetTeamScore2( myTeam )
			teamScore[enemyTeam] <- GameRules.GetTeamScore2( enemyTeam )
		}
		else
		{
			teamScore[myTeam] <- GameRules.GetTeamScore( myTeam )
			teamScore[enemyTeam] <- GameRules.GetTeamScore( enemyTeam )
		}

		if ( GAMETYPE == COOPERATIVE )
		{
			winningTeam = level.nv.attackingTeam
			losingTeam = GetOtherTeam( winningTeam )

			file.background.SetImage( SCOREBOARD_MATERIAL_COOP_BACKGROUND )

			file.teamElems[losingTeam].logo.Hide()
			file.teamElems[losingTeam].score.Hide()
			local waveNumber = level.nv.TDCurrWave

			file.CoopWaveContinuesRemaining.Show()
			file.CoopWaveContinuesCount.SetText( Coop_GetNumRestartsLeft().tostring() )
			file.CoopWaveContinuesCount.Show()

			if ( waveNumber != null && level.nv.TDScoreboardDisplayWaveInfo == true )
			{
				local waveName = GetWaveNameStrByID( level.nv.TDCurrWaveNameID )
				if ( waveName == null || waveName == "" )
					waveName = "Wave Info"

				local waveNumberString = level.waveNumberToString[ min( waveNumber-1, level.waveNumberToString.len()-1 ) ]

				file.CoopWaveNumber.SetText( waveNumberString )
				file.CoopWaveNumber.Show()
				file.CoopWaveName.SetText( waveName )
				file.CoopWaveName.Show()
				file.CoopWaveRemainingEnemies.Show()
				UpdateWaveEnemyTypes()
			}
			else
			{
				file.CoopWaveNumber.Hide()
				file.CoopWaveName.Hide()
				file.CoopWaveRemainingEnemies.Hide()

				HideAllWaveEnemyTypeElems()
			}

			if ( Coop_IsGameOver() )
			{
				file.CoopWaveNumber.Hide()
				file.CoopWaveName.Hide()
				file.CoopWaveRemainingEnemies.Hide()

				local eogDesc
				if ( localPlayer.GetTeam() == level.nv.winningTeam )
					file.header.gametypeDesc.SetText( "#COOP_EOG_VICTORY_SCOREBOARD_DESC", level.lastWaveIdx, level.nv.TDNumWaves )
				else
					file.header.gametypeDesc.SetText( "#COOP_EOG_DEFEAT_SCOREBOARD_DESC", (level.lastWaveIdx - 1 ), level.nv.TDNumWaves )
				HideAllWaveEnemyTypeElems()
			}
		}
		else if ( teamScore[myTeam] >= teamScore[enemyTeam] )
		{
			winningTeam = myTeam
			losingTeam = enemyTeam
		}
		else
		{
			winningTeam = enemyTeam
			losingTeam = myTeam
		}

		file.teamElems[winningTeam].score.SetText( teamScore[winningTeam].tostring() )
		file.teamElems[losingTeam].score.SetText( teamScore[losingTeam].tostring() )

		file.teamElems[winningTeam].score.SetPos( 0, -headerHeight )
		file.teamElems[losingTeam].score.SetPos( 0, -headerHeight - losingTeamYOffset )

		local allPlayers = []
		local selectedPlayerIndex = 0

		foreach ( team, players in teamPlayers )
		{
			index = 0

			foreach ( player in players )
			{
				elemTable = file.playerElems[team][index]

				if ( index % 2 == 0 )
					elemTable.background.SetImage( playerSlotFilledEven[team] )
				else
					elemTable.background.SetImage( playerSlotFilledOdd[team] )

				if ( player == file.selectedPlayer )
				{
					elemTable.selection.Show()
					selectedPlayerIndex = allPlayers.len()
				}
				else
				{
					elemTable.selection.Hide()
				}
				allPlayers.append( player )

				elemTable.background.Show()

				if ( GetGameState() == eGameState.Epilogue && player.GetParent() && player.GetParent().GetSignifierName() == "npc_dropship" )
				{
					file.evacPlayers[ player.GetEntIndex() ] <- true
				}

				if ( GAMETYPE == COOPERATIVE )
				{
					local playerIndex = player.GetEntIndex()
					Assert( playerIndex > 0 && playerIndex <= COOP_MAX_PLAYER_COUNT )
					elemTable.playerNumber.SetImage( "hud/coop/scoreboard_coop_p" + playerIndex )
					elemTable.playerNumber.Show()
				}
				//-------------------
				// Update player icon
				//-------------------

				local hasActiveNonTitanBurnCard = DoesPlayerHaveActiveNonTitanBurnCard( player )
				local hasActiveTitanBurnCard = DoesPlayerHaveActiveTitanBurnCard( player )
				local isPlayerOnLocalTeam = myTeam == player.GetTeam()

				if ( !IsAlive( player ) )
				{
					if ( player.GetPetTitan() )
					{
						if( hasActiveTitanBurnCard )
						{
							if( isPlayerOnLocalTeam )
								elemTable.status.SetImage( SCOREBOARD_MATERIAL_STATUS_DEAD_WITH_PET_BURN )
							else
								elemTable.status.SetImage( SCOREBOARD_MATERIAL_STATUS_DEAD_WITH_PET_BURN_ENEMY )
						}
						else
						{
							elemTable.status.SetImage( SCOREBOARD_MATERIAL_STATUS_DEAD_WITH_PET )
						}
					}
					else
						elemTable.status.SetImage( SCOREBOARD_MATERIAL_STATUS_DEAD )
				}
				else if ( player.GetEntIndex() in file.evacPlayers )
				{
					elemTable.status.SetImage( SCOREBOARD_MATERIAL_STATUS_EVAC )
				}
				else if ( player.GetPetTitan() )
				{
					if( hasActiveTitanBurnCard )
					{
						if( isPlayerOnLocalTeam )
							elemTable.status.SetImage( SCOREBOARD_MATERIAL_STATUS_ALIVE_WITH_PET_TITAN_BURN )
						else
							elemTable.status.SetImage( SCOREBOARD_MATERIAL_STATUS_ALIVE_WITH_PET_TITAN_BURN_ENEMY )
					}
					else if ( hasActiveNonTitanBurnCard )
					{
						if( isPlayerOnLocalTeam )
							elemTable.status.SetImage( SCOREBOARD_MATERIAL_STATUS_ALIVE_WITH_PET_PILOT_BURN )
						else
							elemTable.status.SetImage( SCOREBOARD_MATERIAL_STATUS_ALIVE_WITH_PET_PILOT_BURN_ENEMY )
					}
					else
					{
						elemTable.status.SetImage( SCOREBOARD_MATERIAL_STATUS_ALIVE_WITH_PET )
					}
				}
				else if ( player.IsTitan() )
				{
					if( hasActiveTitanBurnCard )
					{
						if( isPlayerOnLocalTeam )
							elemTable.status.SetImage( SCOREBOARD_MATERIAL_STATUS_TITAN_BURN )
						else
							elemTable.status.SetImage( SCOREBOARD_MATERIAL_STATUS_TITAN_BURN_ENEMY )
					}
					else
					{
						elemTable.status.SetImage( SCOREBOARD_MATERIAL_STATUS_TITAN )
					}
				}
				else
				{
					if( hasActiveNonTitanBurnCard )
					{
						if( isPlayerOnLocalTeam )
							elemTable.status.SetImage( SCOREBOARD_MATERIAL_STATUS_PILOT_BURN )
						else
							elemTable.status.SetImage( SCOREBOARD_MATERIAL_STATUS_PILOT_BURN_ENEMY )
					}
					else
					{
						elemTable.status.SetImage( SCOREBOARD_MATERIAL_STATUS_PILOT )
					}
				}

				if ( GetPartyLeader() == player )
					elemTable.leader.Show()
				else
					elemTable.leader.Hide()

				elemTable.status.Show()

				// Update player level number
				local lvl = GetLevel( player )
				if ( lvl != null )
				{
					elemTable.lvl.SetText( lvl.tostring() )
					elemTable.lvl.Show()
				}

				// Update player name and color
				local name = player.GetPlayerName()
				if ( player.HasBadReputation() )
					name = "* " + name

				elemTable.name.SetText( name )

				local rankImage
				if ( localPlayerPlayingRanked && PlayerPlayingRanked( player ) )
				{
					rankImage =  GetRankImage( GetPlayerRank( player ) )
				}
				else
				{
					rankImage =  GetPlayerGenIcon( player )
				}
				elemTable.artImage.SetImage( rankImage )
				elemTable.artImage.Show()

				if ( player == localPlayer )
				{
					elemTable.name.SetColor( LOCALPLAYER_NAME_COLOR, 255 )
				}
				else
				{
					if ( !IsPrivateMatch() && IsPartyMember( player ) )
					{
						elemTable.name.SetColor( 179, 255, 204, 255 )
					}
					else
					{
						elemTable.name.SetColor( [230, 230, 230, 255] )
					}
				}

				elemTable.name.Show()
				elemTable.name.SetWidth( file.nameEndColumn.GetAbsX() - nameMeasureElem.GetAbsX() )

				// Update MIC/Talking icon state
				if ( player.HasMic() )
				{
					if ( player.IsMuted() )
						elemTable.mic.SetImage( SCOREBOARD_MATERIAL_MIC_MUTED )
					else if ( player.InPartyChat() )
						elemTable.mic.SetImage( SCOREBOARD_MATERIAL_MIC_PARTYCHAT )
					else if ( player.IsTalking() )
						elemTable.mic.SetImage( SCOREBOARD_MATERIAL_MIC_ACTIVE )
					else
						elemTable.mic.SetImage( SCOREBOARD_MATERIAL_MIC_INACTIVE )

					elemTable.mic.Show()
				}
				else
				{
					elemTable.mic.Hide()
				}

				// Update connection icon
				ping = player.GetPing()

				if ( !Durango_IsDurango() )
				{
					elemTable.connection.SetText( ping.tostring() )
				}
				else
				{
					elemTable.connection.SetImage( GetConnectionImage( ping ) )

					if ( file.developer )
					{
						elemTable.ping.SetText( ping.tostring() )
						elemTable.ping.Show()
					}
				}
				elemTable.connection.Show()

				// Update column data
				foreach( varName, hudElem in file.columnLabels )
				{
					if ( !( varName in elemTable ) )
						continue

					local val = file.columnLabelsUpdateFuncs[ varName ]( player )
					elemTable[ varName ].SetText( file.columnLabelsLocalize[ varName ], val, "" )
					elemTable[ varName ].Show()
				}

				index++

				if ( index >= level.maxTeamSize )
					break
			}

			//
			{
				local loadingCount = GetTeamPendingPlayersLoading( team )
				local connectingCount = GetTeamPendingPlayersConnecting( team )
				local reservedCount = GetTeamPendingPlayersReserved( team )
				local numDone = 0
				for ( local idx = 0; idx < (reservedCount + connectingCount + loadingCount); idx++ )
				{
					if ( index >= level.maxTeamSize )
						continue

					elemTable = file.playerElems[team][index]
					foreach( elem in elemTable )
						elem.Hide()
					elemTable.background.SetImage( playerSlotEmpty[team] )
					elemTable.background.Show()
					elemTable.name.Show()

					if ( numDone < loadingCount )
					{
						elemTable.name.SetText( "#PENDING_PLAYER_STATUS_LOADING" )
						local cb = 100.0 + 80.0 * GetPulseFrac( 0.6, (index * 0.11) )
						elemTable.name.SetColor( cb, cb, cb, 255 )
					}
					else if ( numDone < (loadingCount + connectingCount) )
					{
						elemTable.name.SetText( "#PENDING_PLAYER_STATUS_CONNECTING" )
						local cb = 90.0 + 80.0 * GetPulseFrac( 0.6, (index * 0.11) )
						elemTable.name.SetColor( cb, cb, cb, 255 )
					}
					else
					{
						// Reserved:
						elemTable.name.SetText( "#PENDING_PLAYER_STATUS_CONNECTING" )
						local cb = 80
						elemTable.name.SetColor( cb, cb, cb, 255 )
					}

					numDone++
					index++
				}
			}

			while ( index < level.maxTeamSize )
			{
				elemTable = file.playerElems[team][index]

				foreach( elem in elemTable )
					elem.Hide()

				if ( GAMETYPE != COOPERATIVE || team == winningTeam )
				{
					elemTable.background.SetImage( playerSlotEmpty[team] )
					elemTable.background.Show()
				}

				index++
			}
		}

		if ( allPlayers.len() )
		{
			file.prevPlayer = allPlayers[ (selectedPlayerIndex + allPlayers.len() - 1) % allPlayers.len() ]
			file.nextPlayer = allPlayers[ (selectedPlayerIndex + 1) % allPlayers.len() ]
		}
		else
		{
			file.prevPlayer = file.selectedPlayer
			file.nextPlayer = file.selectedPlayer
		}

		teamPlayers[myTeam].clear()
		teamPlayers[enemyTeam].clear()

		wait 0
	}
}

function HideScoreboard()
{
	if ( !file.showingScoreboard )
		return

	file.showingScoreboard = false

	SetScoreboardPlayer( null )

	file.scoreboard.Hide()

	local localPlayer = GetLocalClientPlayer()
	local myTeam = localPlayer.GetTeam()
	local enemyTeam = GetEnemyTeam( myTeam )

	UpdateClientHudVisibility( localPlayer )

	Signal( file, "OnHideScoreboard" )

	UpdateMainHudVisibility( localPlayer, 0.0 )
	ShowScriptHUD( localPlayer )
	ClearCrosshairPriority( crosshairPriorityLevel.MENU )
	ColorCorrection_SetWeight( file.menuColorCorrection, 0.0 )
}

function GameStateChanged()
{
	switch ( GetGameState() )
	{
		case eGameState.Postmatch:
			delaythread( 1.5 ) ShowScoreboard()
			break
	}
}

function updatePing( player )
{
	return player.GetPing()
}

function updateVictory( player )
{
	local scoreLimit = GetScoreLimit_FromPlaylist().tofloat()
	if ( !scoreLimit )
		return UpdateAssault( player )

	local scoreFrac = player.GetAssaultScore() / scoreLimit
	return floor( scoreFrac * 100.0 )
}

function GetConnectionImage( ping )
{
	local image

	if ( ping > 150 )
		image = SCOREBOARD_MATERIAL_CONNECTION_QUALITY_1
	else if ( ping > 100 )
		image = SCOREBOARD_MATERIAL_CONNECTION_QUALITY_2
	else if ( ping > 75 )
		image = SCOREBOARD_MATERIAL_CONNECTION_QUALITY_3
	else if ( ping > 50 )
		image = SCOREBOARD_MATERIAL_CONNECTION_QUALITY_4
	else
		image = SCOREBOARD_MATERIAL_CONNECTION_QUALITY_5

	return image
}

function ClientCodeCallback_ScoreboardSelectionInput( down )
{
	if ( down )
		file.selectedPlayer = file.nextPlayer
	else
		file.selectedPlayer = file.prevPlayer

	Assert( file.showingScoreboard )
	SetScoreboardPlayer( file.selectedPlayer )
}

function GetPlayerGenIcon( player )
{
	switch ( player.GetGen() )
	{
		case 0:
			return SCOREBOARD_MATERIAL_GEN1
		case 1:
			return SCOREBOARD_MATERIAL_GEN2
		case 2:
			return SCOREBOARD_MATERIAL_GEN3
		case 3:
			return SCOREBOARD_MATERIAL_GEN4
		case 4:
			return SCOREBOARD_MATERIAL_GEN5
		case 5:
			return SCOREBOARD_MATERIAL_GEN6
		case 6:
			return SCOREBOARD_MATERIAL_GEN7
		case 7:
			return SCOREBOARD_MATERIAL_GEN8
		case 8:
			return SCOREBOARD_MATERIAL_GEN9
		case 9:
			return SCOREBOARD_MATERIAL_GEN10
		default:
			Assert( 0, "player.GetGen() did not return a value between 0 and 9" )
	}
}

function AddColumnsForGameMode( scoreboard )
{
	switch ( GAMETYPE )
	{
		case CAPTURE_POINT:
			// added RIGHT to LEFT
			AddColumnLabel( scoreboard, "deaths", SCOREBOARD_MATERIAL_DEATHS, "#SCOREBOARD_DEATHS", 0, false, UpdateDeaths )
			AddColumnLabel( scoreboard, "pilotKills", SCOREBOARD_MATERIAL_PILOT_KILLS, "#SCOREBOARD_PILOT_KILLS", 0, false, UpdateKills )
			AddColumnLabel( scoreboard, "defense", SCOREBOARD_MATERIAL_DEFENSE, "#SCOREBOARD_DEFENSE", 0, true, UpdateDefense )
			AddColumnLabel( scoreboard, "assault", SCOREBOARD_MATERIAL_HARDPOINT, "#SCOREBOARD_ASSAULT", 0, true, UpdateAssault )
			break

		case ATTRITION:
			// added RIGHT to LEFT
			AddColumnLabel( scoreboard, "deaths", SCOREBOARD_MATERIAL_DEATHS, "#SCOREBOARD_DEATHS", 0, false, UpdateDeaths )
			AddColumnLabel( scoreboard, "npcKills", SCOREBOARD_MATERIAL_NPC_KILLS, "#SCOREBOARD_GRUNT_KILLS", 0, false, UpdateNPCKills )
			AddColumnLabel( scoreboard, "titanKills", SCOREBOARD_MATERIAL_TITAN_KILLS, "#SCOREBOARD_TITAN_KILLS", 0, false, UpdateTitanKills )
			AddColumnLabel( scoreboard, "pilotKills", SCOREBOARD_MATERIAL_PILOT_KILLS, "#SCOREBOARD_PILOT_KILLS", 0, false, UpdateKills )
			AddColumnLabel( scoreboard, "victory", SCOREBOARD_MATERIAL_VICTORY_CONTRIBUTION, "#SCOREBOARD_AT_POINTS", 0, true, UpdateAssault )
			break

		case COOPERATIVE:
			// added RIGHT to LEFT
			AddColumnLabel( scoreboard, "deaths", SCOREBOARD_MATERIAL_DEATHS, "#SCOREBOARD_DEATHS", 0, false, UpdateDeaths )
			AddColumnLabel( scoreboard, "npcKills", SCOREBOARD_MATERIAL_NPC_KILLS, "#SCOREBOARD_GRUNT_KILLS", 0, false, UpdateNPCKills )
			AddColumnLabel( scoreboard, "titanKills", SCOREBOARD_MATERIAL_TITAN_KILLS, "#SCOREBOARD_TITAN_KILLS", 0, false, UpdateTitanKills )
			AddColumnLabel( scoreboard, "victory", SCOREBOARD_MATERIAL_VICTORY_CONTRIBUTION, "#SCOREBOARD_COOP_POINTS", 0, true, UpdateAssault )
			break

		case CAPTURE_THE_FLAG:
			// added RIGHT to LEFT
			AddColumnLabel( scoreboard, "deaths", SCOREBOARD_MATERIAL_DEATHS, "#SCOREBOARD_DEATHS", 0, false, UpdateDeaths )
			AddColumnLabel( scoreboard, "titanKills", SCOREBOARD_MATERIAL_TITAN_KILLS, "#SCOREBOARD_TITAN_KILLS", 0, false, UpdateTitanKills )
			AddColumnLabel( scoreboard, "pilotKills", SCOREBOARD_MATERIAL_PILOT_KILLS, "#SCOREBOARD_PILOT_KILLS", 0, false, UpdateKills )
			AddColumnLabel( scoreboard, "killsReturns", SCOREBOARD_MATERIAL_FLAG_RETURN, "#SCOREBOARD_RETURNS", 0, false, UpdateDefense )
			AddColumnLabel( scoreboard, "assault", SCOREBOARD_MATERIAL_FLAG_CAPTURE, "#SCOREBOARD_CAPTURES", 0, true, UpdateAssault )
			break

		case MARKED_FOR_DEATH:
		case MARKED_FOR_DEATH_PRO:
			// added RIGHT to LEFT
			AddColumnLabel( scoreboard, "deaths", SCOREBOARD_MATERIAL_DEATHS, "#SCOREBOARD_DEATHS", 0, false, UpdateDeaths )
			AddColumnLabel( scoreboard, "titanKills", SCOREBOARD_MATERIAL_TITAN_KILLS, "#SCOREBOARD_TITAN_KILLS", 0, false, UpdateTitanKills )
			AddColumnLabel( scoreboard, "pilotKills", SCOREBOARD_MATERIAL_PILOT_KILLS, "#SCOREBOARD_PILOT_KILLS", 0, false, UpdateKills )
			AddColumnLabel( scoreboard, "defense", SCOREBOARD_MATERIAL_DEFENSE, "#SCOREBOARD_MFD_MARKS_OUTLASTED", 0, false, UpdateDefense )
			AddColumnLabel( scoreboard, "assault", SCOREBOARD_MATERIAL_MARKED_FOR_DEATH_TARGET_KILLS, "#SCOREBOARD_MFD_SCORE", 0, true, UpdateAssault )
			break

		case LAST_TITAN_STANDING:
		case WINGMAN_LAST_TITAN_STANDING:
			// added RIGHT to LEFT
			AddColumnLabel( scoreboard, "assists", SCOREBOARD_MATERIAL_ASSISTS, "#SCOREBOARD_ASSISTS", 0, false, UpdateAssists )
			AddColumnLabel( scoreboard, "pilotKills", SCOREBOARD_MATERIAL_PILOT_KILLS, "#SCOREBOARD_PILOT_KILLS", 0, false, UpdateKills )
			AddColumnLabel( scoreboard, "deaths", SCOREBOARD_MATERIAL_DEATHS, "#SCOREBOARD_DEATHS", 0, false, UpdateDeaths )
			AddColumnLabel( scoreboard, "titanKills", SCOREBOARD_MATERIAL_TITAN_KILLS, "#SCOREBOARD_TITAN_KILLS", 0, true, UpdateTitanKills )
			break

		case  SCAVENGER:
			// added RIGHT to LEFT
			AddColumnLabel( scoreboard, "deaths", SCOREBOARD_MATERIAL_DEATHS, "#SCOREBOARD_DEATHS", 0, false, UpdateDeaths )
			AddColumnLabel( scoreboard, "titanKills", SCOREBOARD_MATERIAL_TITAN_KILLS, "#SCOREBOARD_TITAN_KILLS", 0, false, UpdateTitanKills )
			AddColumnLabel( scoreboard, "pilotKills", SCOREBOARD_MATERIAL_PILOT_KILLS, "#SCOREBOARD_PILOT_KILLS", 0, false, UpdateKills )
			AddColumnLabel( scoreboard, "assault", SCOREBOARD_MATERIAL_FLAG_CAPTURE, "#SCOREBOARD_SCORE", 0, true, UpdateAssault )
			break

		case PILOT_SKIRMISH:
			AddColumnLabel( scoreboard, "assists", SCOREBOARD_MATERIAL_ASSISTS, "#SCOREBOARD_ASSISTS", 0, false, UpdateAssists )
			AddColumnLabel( scoreboard, "deaths", SCOREBOARD_MATERIAL_DEATHS, "#SCOREBOARD_DEATHS", 0, true, UpdateDeaths )
			AddColumnLabel( scoreboard, "pilotKills", SCOREBOARD_MATERIAL_PILOT_KILLS, "#SCOREBOARD_PILOT_KILLS", 0, true, UpdateKills )
			break

		default:
			// added RIGHT to LEFT
			AddColumnLabel( scoreboard, "assists", SCOREBOARD_MATERIAL_ASSISTS, "#SCOREBOARD_ASSISTS", 0, false, UpdateAssists )
			AddColumnLabel( scoreboard, "titanKills", SCOREBOARD_MATERIAL_TITAN_KILLS, "#SCOREBOARD_TITAN_KILLS", 0, false, UpdateTitanKills )
			AddColumnLabel( scoreboard, "deaths", SCOREBOARD_MATERIAL_DEATHS, "#SCOREBOARD_DEATHS", 0, true, UpdateDeaths )
			AddColumnLabel( scoreboard, "pilotKills", SCOREBOARD_MATERIAL_PILOT_KILLS, "#SCOREBOARD_PILOT_KILLS", 0, true, UpdateKills )
			break
	}
}

function InitCoopScoreboard( scoreboard )
{
	file.CoopWaveNumber				<- null
	file.CoopWaveName				<- null
	file.CoopWaveRemainingEnemies	<- null
	file.CoopWaveEnemyTypeArray		<- []
	file.CoopWaveContinuesRemaining	<- null
	file.CoopWaveContinuesCount		<- null
	file.CoopStars					<- {}
	file.CoopStars[0]				<- null
	file.CoopStars[1]				<- null
	file.CoopStars[2]				<- null

	file.CoopWaveNumber				= HudElement( "ScoreboardTD_WaveNumber", scoreboard )
	file.CoopWaveName				= HudElement( "ScoreboardTD_WaveName", scoreboard )
	file.CoopWaveRemainingEnemies	= HudElement( "ScoreboardTD_RemainingEnemies", scoreboard )
	file.CoopWaveContinuesRemaining	= HudElement( "ScoreboardTD_ContinuesRemaining_Title", scoreboard )
	file.CoopWaveContinuesCount		= HudElement( "ScoreboardTD_ContinuesRemaining_Count", scoreboard )
	file.CoopStars[0]				= HudElement( "ScoreboardTD_Star_0", scoreboard )
	file.CoopStars[1]				= HudElement( "ScoreboardTD_Star_1", scoreboard )
	file.CoopStars[2]				= HudElement( "ScoreboardTD_Star_2", scoreboard )

	file.CoopWaveNumber.Hide()
	file.CoopWaveName.Hide()
	file.CoopWaveRemainingEnemies.Hide()
	file.CoopWaveContinuesRemaining.Hide()
	file.CoopWaveContinuesCount.Hide()
	file.CoopStars[0].Show()
	file.CoopStars[1].Show()
	file.CoopStars[2].Show()

	InitWaveEnemyTypes( scoreboard )
}

function InitWaveEnemyTypes( scoreboard )
{
	for ( local i = 0; i < 10; i++ )
	{
		local elem = HudElement( "ScoreboardTD_WaveEnemyType_" + i, scoreboard )
		elem.s.bg <- elem.GetChild( "WaveEnemyType_info_box" )
		elem.s.count <- elem.GetChild( "WaveEnemyType_Count" )
		elem.s.image <- elem.GetChild( "WaveEnemyType_Image" )
		elem.s.name <- elem.GetChild( "WaveEnemyType_Name" )

		HideWaveEnemyTypeElem( elem )

		file.CoopWaveEnemyTypeArray.append( elem )
	}
}

function UpdateWaveEnemyTypes()
{
	local scoreboard = file.scoreboard

	local TD_numTitans 			= level.nv.TD_numTitans
	local TD_numNukeTitans 		= level.nv.TD_numNukeTitans
	local TD_numMortarTitans	= level.nv.TD_numMortarTitans
	local TD_numEMPTitans 		= level.nv.TD_numEMPTitans
	local TD_numSuicides 		= level.nv.TD_numSuicides
	local TD_numSnipers 		= level.nv.TD_numSnipers
	local TD_numSpectres 		= level.nv.TD_numSpectres
	local TD_numGrunts 			= level.nv.TD_numGrunts
	local TD_numCloakedDrone 	= level.nv.TD_numCloakedDrone
	local totalEnemyNum 		= GetTotalEnemyNum()

	HideAllWaveEnemyTypeElems()

	//the order here desides the display order
	local iconIndex = 0
	if ( TD_numEMPTitans >= 0 )
	{
		SetWaveEnemyTypeIcon( iconIndex, SCOREBOARD_MATERIAL_COOP_EMP_TITAN, TD_numEMPTitans, eCoopAIType.empTitan )
		iconIndex++
	}
	if ( TD_numNukeTitans >= 0 )
	{
		SetWaveEnemyTypeIcon( iconIndex, SCOREBOARD_MATERIAL_COOP_NUKE_TITAN, TD_numNukeTitans, eCoopAIType.nukeTitan )
		iconIndex++
	}
	if ( TD_numMortarTitans >= 0 )
	{
		SetWaveEnemyTypeIcon( iconIndex, SCOREBOARD_MATERIAL_COOP_MORTAR_TITAN, TD_numMortarTitans, eCoopAIType.mortarTitan )
		iconIndex++
	}
	if ( TD_numTitans >= 0 )
	{
		SetWaveEnemyTypeIcon( iconIndex, SCOREBOARD_MATERIAL_COOP_TITAN, TD_numTitans, eCoopAIType.titan )
		iconIndex++
	}
	if ( TD_numCloakedDrone >= 0 )
	{
		SetWaveEnemyTypeIcon( iconIndex, SCOREBOARD_MATERIAL_COOP_CLOAK_DRONE, TD_numCloakedDrone, eCoopAIType.cloakedDrone )
		iconIndex++
	}
	if ( TD_numSuicides >= 0 )
	{
		SetWaveEnemyTypeIcon( iconIndex, SCOREBOARD_MATERIAL_COOP_SUICIDE_SPECTRE, TD_numSuicides, eCoopAIType.suicideSpectre )
		iconIndex++
	}
	if ( TD_numSnipers >= 0 )
	{
		SetWaveEnemyTypeIcon( iconIndex, SCOREBOARD_MATERIAL_COOP_SNIPER_SPECTRE, TD_numSnipers, eCoopAIType.sniperSpectre )
		iconIndex++
	}
	if ( TD_numSpectres >= 0 )
	{
		SetWaveEnemyTypeIcon( iconIndex, SCOREBOARD_MATERIAL_COOP_SPECTRE, TD_numSpectres, eCoopAIType.spectre )
		iconIndex++
	}
	if ( TD_numGrunts >= 0 )
	{
		SetWaveEnemyTypeIcon( iconIndex, SCOREBOARD_MATERIAL_COOP_GRUNT, TD_numGrunts, eCoopAIType.grunt )
		iconIndex++
	}
}

function SetWaveEnemyTypeIcon( index, image, num, aiTypeIdx )
{
	local elem = file.CoopWaveEnemyTypeArray[ index ]
	elem.Show()

	elem.s.bg.Show()

	elem.s.image.SetImage( image )
	elem.s.image.Show()

	elem.s.count.SetText( num.tostring() )
	elem.s.count.Show()

	local aiTypeInfo = level.enemyAnnounceCardInfos[ aiTypeIdx ]
	local name = aiTypeInfo.title

	elem.s.name.SetText( name )
	elem.s.name.Show()
}

function HideWaveEnemyTypeElem( elem )
{
	elem.Hide()
	elem.s.bg.Hide()
	elem.s.count.Hide()
	elem.s.image.Hide()
	elem.s.name.Hide()
}

function HideAllWaveEnemyTypeElems()
{
	foreach( elem in file.CoopWaveEnemyTypeArray )
	{
		HideWaveEnemyTypeElem( elem )
	}
}

function SetFullScoreboardStar( starIndex )
{
	file.CoopStars[starIndex].SetImage( SCOREBOARD_MATERIAL_COOP_STARS )
}
Globalize( SetFullScoreboardStar )


function SetEmptyScoreboardStar( starIndex )
{
	file.CoopStars[starIndex].SetImage( SCOREBOARD_MATERIAL_COOP_STARS_EMPTY )
}
Globalize( SetEmptyScoreboardStar )

function GetNumTeamPlayers()
{
	if ( GAMETYPE == COOPERATIVE )
		return max( 4, GetCurrentPlaylistVar( "max players", 4 ).tointeger() )
	else
		return max( 6, GetCurrentPlaylistVar( "max players", 12 ).tointeger() / 2.0 )
}

function InitColumnLines( scoreboard )
{
	file.columnLines <- []
	file.columnLines.append( HudElement( "ScoreboardMyTeamColumnLineMic", scoreboard ) )
	file.columnLines.append( HudElement( "ScoreboardMyTeamColumnLineStatus", scoreboard ) )
	file.columnLines.append( HudElement( "ScoreboardMyTeamColumnLineLvl", scoreboard ) )
	file.columnLines.append( HudElement( "ScoreboardMyTeamColumnLineConnection", scoreboard ) )
	file.columnLines.append( HudElement( "ScoreboardMyTeamColumnLinePlayerNumber", scoreboard ) )

	file.enemyColumnLines <- HudElementGroup( "enemyColumnLines" )
	local hudElement = HudElement( "ScoreboardEnemyTeamColumnLineMic", scoreboard )
	file.enemyColumnLines.AddElement( hudElement )
	file.columnLines.append( hudElement )
	local hudElement = HudElement( "ScoreboardEnemyTeamColumnLineStatus", scoreboard )
	file.enemyColumnLines.AddElement( hudElement )
	file.columnLines.append( hudElement )
	local hudElement = HudElement( "ScoreboardEnemyTeamColumnLineLvl", scoreboard )
	file.enemyColumnLines.AddElement( hudElement )
	file.columnLines.append( hudElement )
	local hudElement = HudElement( "ScoreboardEnemyTeamColumnLineConnection", scoreboard )
	file.enemyColumnLines.AddElement( hudElement )
	file.columnLines.append( hudElement )
	local hudElement = HudElement( "ScoreboardEnemyTeamColumnLinePlayerNumber", scoreboard )
	file.enemyColumnLines.AddElement( hudElement )
	file.columnLines.append( hudElement )
}

function HideCrosshairIfScoreBoardIsShowing()
{
	local player = GetLocalClientPlayer()

	if ( IsInScoreboard( player ) )
		SetCrosshairPriorityState( crosshairPriorityLevel.MENU, CROSSHAIR_STATE_HIDE_ALL )
}