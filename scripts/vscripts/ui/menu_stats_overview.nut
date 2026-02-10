
const IMAGE_TITAN_STRYDER = "../ui/menu/personal_stats/ps_titan_icon_stryder"
const IMAGE_TITAN_ATLAS = "../ui/menu/personal_stats/ps_titan_icon_atlas"
const IMAGE_TITAN_OGRE = "../ui/menu/personal_stats/ps_titan_icon_ogre"

PrecacheHUDMaterial( IMAGE_TITAN_STRYDER )
PrecacheHUDMaterial( IMAGE_TITAN_ATLAS )
PrecacheHUDMaterial( IMAGE_TITAN_OGRE )

function main()
{
	Globalize( OnOpenViewStatsOverview )
	Globalize( InitStats_Overview )
}

function OnOpenViewStatsOverview()
{
}

function InitStats_Overview()
{
	local menu = GetMenu( "ViewStats_Overview_Menu" )
	local nextIndex = 0

	//#########################
	// 		  Games
	//#########################

	local gamesPlayed = StatToIntAllCompetitiveModesAndMaps( "game_stats", "game_completed" )
	local gamesWon = StatToIntAllCompetitiveModesAndMaps( "game_stats", "game_won" )
	local winPercent = GetPercent( gamesWon, gamesPlayed, 0 )
	local timesMVP = StatToInt( "game_stats", "mvp_total" )
	local timesTop3 = StatToIntAllCompetitiveModesAndMaps( "game_stats", "top3OnTeam" )

	SetStatsLabelValue( menu, "GamesStatName" + nextIndex, 		"#STATS_GAMES_PLAYED" )
	SetStatsLabelValue( menu, "GamesStatValue" + nextIndex, 	gamesPlayed )
	nextIndex++
	SetStatsLabelValue( menu, "GamesStatName" + nextIndex, 		"#STATS_GAMES_WON" )
	SetStatsLabelValue( menu, "GamesStatValue" + nextIndex, 	gamesWon )
	nextIndex++
	SetStatsLabelValue( menu, "GamesStatName" + nextIndex, 		"#STATS_GAMES_WIN_PERCENT" )
	SetStatsLabelValue( menu, "GamesStatValue" + nextIndex, 	[ "#STATS_PERCENTAGE", winPercent ] )
	nextIndex++
	SetStatsLabelValue( menu, "GamesStatName" + nextIndex, 		"#STATS_GAMES_MVP" )
	SetStatsLabelValue( menu, "GamesStatValue" + nextIndex, 	timesMVP )
	nextIndex++
	SetStatsLabelValue( menu, "GamesStatName" + nextIndex, 		"#STATS_GAMES_TOP3" )
	SetStatsLabelValue( menu, "GamesStatValue" + nextIndex, 	timesTop3 )

	//#########################
	// 		   Modes
	//#########################

	local gameModePlayedVar = GetPersistentStatVar( "game_stats", "mode_played" )
	local basicModes = [ "tdm", "cp", "at", "lts", "ctf" ]

	local timesPlayedArray = []
	local gameModeNamesArray = []
	local otherGameModesPlayed = 0
	local gameModesArray = GetPersistenceEnumAsArray( "gameModes" )

	foreach ( modeName in gameModesArray )
	{
		local gameModePlaysVar = StatStringReplace( gameModePlayedVar, "%gamemode%", modeName )
		local timesPlayed = GetPersistentVar( gameModePlaysVar )

		if ( ArrayContains( basicModes, modeName ) )  //Don't really like doing ArrayContains, but Chad prefers not storing a separate enum in persistence that contains the "other" gamemodes
		{
			timesPlayedArray.append( timesPlayed )
			gameModeNamesArray.append( GAMETYPE_TEXT[ modeName] )
		}
		else
		{
			otherGameModesPlayed += timesPlayed
		}
	}

	//Add Other game modes' data to the end of the arrays
	gameModeNamesArray.append( "#GAMEMODE_OTHER"  )
	timesPlayedArray.append( otherGameModesPlayed )

	data <- {}
	data.names <- gameModeNamesArray
	data.values <- timesPlayedArray
	//data.sum <- 5

	SetPieChartData( menu, "ModesPieChart", "#GAME_MODES_PLAYED", data )

	//#########################
	// 		Completion
	//#########################

	// Challenges complete
	local challengeData = GetChallengeCompleteData()
	SetStatsBarValues( menu, "CompletionBar0", "#STATS_COMPLETION_CHALLENGES", 		0, challengeData.total, challengeData.complete )

	// Item unlocks
	local itemUnlockData = GetItemUnlockCountData()
	SetStatsBarValues( menu, "CompletionBar1", "#STATS_COMPLETION_WEAPONS", 	0, itemUnlockData["weapons"].total, 	itemUnlockData["weapons"].unlocked )
	SetStatsBarValues( menu, "CompletionBar2", "#STATS_COMPLETION_ATTACHMENTS", 0, itemUnlockData["attachments"].total, itemUnlockData["attachments"].unlocked )
	SetStatsBarValues( menu, "CompletionBar3", "#STATS_COMPLETION_MODS", 		0, itemUnlockData["mods"].total, 		itemUnlockData["mods"].unlocked )
	SetStatsBarValues( menu, "CompletionBar4", "#STATS_COMPLETION_ABILITIES", 	0, itemUnlockData["abilities"].total, 	itemUnlockData["abilities"].unlocked )
	SetStatsBarValues( menu, "CompletionBar5", "#STATS_COMPLETION_GEAR", 		0, itemUnlockData["gear"].total, 		itemUnlockData["gear"].unlocked )

	//#########################
	// 		  Weapons
	//#########################

	local weaponData = GetOverviewWeaponData()

	local tableIndex
	local weaponImageElem
	local weaponNameElem
	local weaponDescElem
	local noDataElem

	// Weapon with most kills
	tableIndex = "most_kills"
	weaponImageElem = GetElem( menu, "WeaponImage0" )
	weaponNameElem = GetElem( menu, "WeaponName0" )
	weaponDescElem = GetElem( menu, "WeaponDesc0" )
	noDataElem = GetElem( menu, "WeaponImageTextOverlay0" )
	if ( weaponData[ tableIndex ].ref != null )
	{
		weaponImageElem.SetImage( GetItemImage( weaponData[ tableIndex ].ref ) )
		weaponImageElem.Show()
		weaponNameElem.SetText(weaponData[ tableIndex ].printName )
		weaponNameElem.Show()
		weaponDescElem.SetText( "#STATS_MOST_KILLS_VALUE", weaponData[ tableIndex ].val )
		weaponDescElem.Show()
		noDataElem.Hide()
	}
	else
	{
		weaponImageElem.Hide()
		weaponNameElem.Hide()
		weaponDescElem.Hide()
		noDataElem.Show()
	}

	// Most Used Weapon
	tableIndex = "most_used"
	weaponImageElem = GetElem( menu, "WeaponImage1" )
	weaponNameElem = GetElem( menu, "WeaponName1" )
	weaponDescElem = GetElem( menu, "WeaponDesc1" )
	noDataElem = GetElem( menu, "WeaponImageTextOverlay1" )
	if ( weaponData[ tableIndex ].ref != null )
	{
		weaponImageElem.SetImage( GetItemImage( weaponData[ tableIndex ].ref ) )
		weaponImageElem.Show()
		weaponNameElem.SetText(weaponData[ tableIndex ].printName )
		weaponNameElem.Show()
		SetStatsLabelValue( menu, "WeaponDesc1", HoursToTimeString( weaponData[ tableIndex ].val ) )
		weaponDescElem.Show()
		noDataElem.Hide()
	}
	else
	{
		weaponImageElem.Hide()
		weaponNameElem.Hide()
		weaponDescElem.Hide()
		noDataElem.Show()
	}

	// Weapon with highest KPM
	tableIndex = "highest_kpm"
	weaponImageElem = GetElem( menu, "WeaponImage2" )
	weaponNameElem = GetElem( menu, "WeaponName2" )
	weaponDescElem = GetElem( menu, "WeaponDesc2" )
	noDataElem = GetElem( menu, "WeaponImageTextOverlay2" )
	if ( weaponData[ tableIndex ].ref != null )
	{
		weaponImageElem.SetImage( GetItemImage( weaponData[ tableIndex ].ref ) )
		weaponImageElem.Show()
		weaponNameElem.SetText(weaponData[ tableIndex ].printName )
		weaponNameElem.Show()
		weaponDescElem.SetText( "#STATS_MOST_EFFICIENT_VALUE", weaponData[ tableIndex ].val )
		weaponDescElem.Show()
		noDataElem.Hide()
	}
	else
	{
		weaponImageElem.Hide()
		weaponNameElem.Hide()
		weaponDescElem.Hide()
		noDataElem.Show()
	}

	//#########################
	// 		Titan Unlocks
	//#########################

	local unlockedCount = 0

	local imageLabel = GetElem( menu, "TitanUnlockImage0" )
	if ( !IsItemLocked( "titan_stryder" ) )
	{
		imageLabel.SetImage( IMAGE_TITAN_STRYDER )
		unlockedCount++
	}
	else
		imageLabel.SetImage( "../ui/menu/personal_stats/ps_titan_icon_locked" )

	imageLabel = GetElem( menu, "TitanUnlockImage1" )
	if ( !IsItemLocked( "titan_atlas" ) )
	{
		imageLabel.SetImage( IMAGE_TITAN_ATLAS )
		unlockedCount++
	}
	else
		imageLabel.SetImage( "../ui/menu/personal_stats/ps_titan_icon_locked" )

	imageLabel = GetElem( menu, "TitanUnlockImage2" )
	if ( !IsItemLocked( "titan_ogre" ) )
	{
		imageLabel.SetImage( IMAGE_TITAN_OGRE )
		unlockedCount++
	}
	else
		imageLabel.SetImage( "../ui/menu/personal_stats/ps_titan_icon_locked" )

	local unlockCountLabel = GetElem( menu, "TitanUnlocksCount" )
	unlockCountLabel.SetText( "#STATS_CHASSIS_UNLOCK_COUNT", unlockedCount.tostring() )

	AddMenuEventHandler(menu, R1DELTA_UIE_OPEN, OnOpenViewStatsOverview)
}