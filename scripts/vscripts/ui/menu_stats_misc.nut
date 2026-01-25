
const MAX_DOTS_ON_GRAPH = 10

function main()
{
	Globalize( OnOpenViewStatsMisc )
	Globalize( InitStats_Misc )
}

function OnOpenViewStatsMisc()
{
}

function InitStats_Misc()
{
	local menu = GetMenu( "ViewStats_Misc_Menu" )

	SetStatsLabelValue( menu, "GamesStatValue0", 		StatToInt( "misc_stats", "titanFalls" ) )
	SetStatsLabelValue( menu, "GamesStatValue1", 		StatToInt( "misc_stats", "spectreLeeches" ) )
	SetStatsLabelValue( menu, "GamesStatValue2", 		StatToInt( "misc_stats", "burnCardsSpent" ) )
	SetStatsLabelValue( menu, "GamesStatValue3", 		StatToInt( "misc_stats", "timesEjected" ) )
	SetStatsLabelValue( menu, "GamesStatValue4", 		StatToInt( "misc_stats", "evacsAttempted" ) )
	SetStatsLabelValue( menu, "GamesStatValue5", 		StatToInt( "misc_stats", "evacsSurvived" ) )
	SetStatsLabelValue( menu, "GamesStatValue6", 		StatToInt( "misc_stats", "flagsCaptured" ) )
	SetStatsLabelValue( menu, "GamesStatValue7", 		StatToInt( "misc_stats", "flagsReturned" ) )

	AddMenuEventHandler(menu, R1DELTA_UIE_OPEN, OnOpenViewStatsMisc)
}