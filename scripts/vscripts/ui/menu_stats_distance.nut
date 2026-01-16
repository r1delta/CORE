
function main()
{
	Globalize( OnOpenViewStatsDistance )
	Globalize( InitStats_Distance )
}

function OnOpenViewStatsDistance()
{
}

function InitStats_Distance()
{
	local menu = GetMenu( "ViewStats_Distance_Menu" )

	//#########################################
	// 		  Distance By Class Pie Chart
	//#########################################

	local distAsPilot = StatToFloat( "distance_stats", "asPilot" )
	local distAsTitan = StatToFloat( "distance_stats", "asTitan" )

	local data = {}
	data.names <- [ "#STATS_HEADER_PILOT", "#STATS_HEADER_TITAN" ]
	data.values <- [ distAsPilot, distAsTitan ]
	data.labelColor <- [ 195, 208, 217, 255 ]
	//data.timeBased <- true

	SetPieChartData( menu, "ClassPieChart", "#STATS_HEADER_DISTANCE_BY_CLASS", data )

	//#########################################
	// 		 Time By Chassis Pie Chart
	//#########################################

	local distAsStryder = StatToFloat( "distance_stats", "asTitan_stryder" )
	local distAsAtlas = StatToFloat( "distance_stats", "asTitan_atlas" )
	local distAsOgre = StatToFloat( "distance_stats", "asTitan_ogre" )

	local data = {}
	data.names <- [ "#STATS_CHASSIS_NAME_STRYDER", "#STATS_CHASSIS_NAME_ATLAS", "#STATS_CHASSIS_NAME_OGRE" ]
	data.values <- [ distAsStryder, distAsAtlas, distAsOgre ]
	data.labelColor <- [ 195, 208, 217, 255 ]
	//data.timeBased <- true
	data.colorShift <- 2

	SetPieChartData( menu, "ChassisPieChart", "#STATS_HEADER_DISTANCE_BY_CHASSIS", data )

	//#########################################
	// 			  Distance Stats
	//#########################################

	SetStatsLabelValue( menu, "GamesStatName0", 		"#STATS_HEADER_DISTANCE_TOTAL" )
	SetStatsLabelValue( menu, "GamesStatValue0", 		StatToDistanceString( "distance_stats", "total" ) )

	SetStatsLabelValue( menu, "GamesStatName1", 		"#STATS_HEADER_DISTANCE_WALLRUNNING" )
	SetStatsLabelValue( menu, "GamesStatValue1", 		StatToDistanceString( "distance_stats", "wallrunning" ) )

	SetStatsLabelValue( menu, "GamesStatName2", 		"#STATS_HEADER_DISTANCE_IN_AIR" )
	SetStatsLabelValue( menu, "GamesStatValue2", 		StatToDistanceString( "distance_stats", "inAir" ) )

	SetStatsLabelValue( menu, "GamesStatName3", 		"#STATS_HEADER_DISTANCE_ON_ZIPLINES" )
	SetStatsLabelValue( menu, "GamesStatValue3", 		StatToDistanceString( "distance_stats", "ziplining" ) )

	SetStatsLabelValue( menu, "GamesStatName4", 		"#STATS_HEADER_DISTANCE_ON_FRIENDLY_TITANS" )
	SetStatsLabelValue( menu, "GamesStatValue4", 		StatToDistanceString( "distance_stats", "onFriendlyTitan" ) )

	SetStatsLabelValue( menu, "GamesStatName5", 		"#STATS_HEADER_DISTANCE_ON_ENEMY_TITANS" )
	SetStatsLabelValue( menu, "GamesStatValue5", 		StatToDistanceString( "distance_stats", "onEnemyTitan" ) )

	AddMenuEventHandler(menu, R1DELTA_UIE_OPEN, OnOpenViewStatsDistance)
}