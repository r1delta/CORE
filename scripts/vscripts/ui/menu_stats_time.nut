
function main()
{
	Globalize( OnOpenViewStatsTime )
	Globalize( InitStats_Time )
}

function OnOpenViewStatsTime()
{
}

function InitStats_Time()
{
	local menu = GetMenu( "ViewStats_Time_Menu" )

	//#########################################
	// 		  Time By Class Pie Chart
	//#########################################

	local hoursAsPilot = StatToFloat( "time_stats", "hours_as_pilot" )
	local hoursAsTitan = StatToFloat( "time_stats", "hours_as_titan" )

	local data = {}
	data.names <- [ "#STATS_HEADER_PILOT", "#STATS_HEADER_TITAN" ]
	data.values <- [ hoursAsPilot, hoursAsTitan ]
	data.labelColor <- [ 195, 208, 217, 255 ]
	data.timeBased <- true

	SetPieChartData( menu, "ClassPieChart", "#STATS_HEADER_TIME_BY_CLASS", data )

	//#########################################
	// 		 Time By Chassis Pie Chart
	//#########################################

	local hoursAsStryder = StatToFloat( "time_stats", "hours_as_titan_stryder" )
	local hoursAsAtlas = StatToFloat( "time_stats", "hours_as_titan_atlas" )
	local hoursAsOgre = StatToFloat( "time_stats", "hours_as_titan_ogre" )

	local data = {}
	data.names <- [ "#STATS_CHASSIS_NAME_STRYDER", "#STATS_CHASSIS_NAME_ATLAS", "#STATS_CHASSIS_NAME_OGRE" ]
	data.values <- [ hoursAsStryder, hoursAsAtlas, hoursAsOgre ]
	data.labelColor <- [ 195, 208, 217, 255 ]
	data.timeBased <- true
	data.colorShift <- 2

	SetPieChartData( menu, "ChassisPieChart", "#STATS_HEADER_TIME_BY_CHASSIS", data )

	//#########################################
	// 				Time Stats
	//#########################################

	SetStatsLabelValue( menu, "GamesStatName0", 		"#STATS_HEADER_TIME_PLAYED" )
	SetStatsLabelValue( menu, "GamesStatValue0", 		StatToTimeString( "time_stats", "hours_total" ) )

	SetStatsLabelValue( menu, "GamesStatName1", 		"#STATS_HEADER_TIME_IN_AIR" )
	SetStatsLabelValue( menu, "GamesStatValue1", 		StatToTimeString( "time_stats", "hours_inAir" ) )

	SetStatsLabelValue( menu, "GamesStatName2", 		"#STATS_HEADER_TIME_WALLRUNNING" )
	SetStatsLabelValue( menu, "GamesStatValue2", 		StatToTimeString( "time_stats", "hours_wallrunning" ) )

	SetStatsLabelValue( menu, "GamesStatName3", 		"#STATS_HEADER_TIME_WALLHANGING" )
	SetStatsLabelValue( menu, "GamesStatValue3", 		StatToTimeString( "time_stats", "hours_wallhanging" ) )

	AddMenuEventHandler(menu, R1DELTA_UIE_OPEN, OnOpenViewStatsTime)
}