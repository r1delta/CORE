
const MAX_DOTS_ON_GRAPH = 10

function main()
{
	Globalize( OnOpenViewStatsKills )
	Globalize( InitStats_Kills )
}

function OnOpenViewStatsKills()
{
}

function InitStats_Kills()
{
	local menu = GetMenu( "ViewStats_Kills_Menu" )

	//#########################
	// 	   	  Kills
	//#########################

	//SetStatsLabelValue( menu, "Column0Value0", 		StatToInt( "kills_stats", "pilots" ) )
	//SetStatsLabelValue( menu, "Column0Value1", 		StatToInt( "kills_stats", "totalTitans" ) )
	//SetStatsLabelValue( menu, "Column0Value2", 		StatToInt( "kills_stats", "firstStrikes" ) )
	//SetStatsLabelValue( menu, "Column0Value3", 		StatToInt( "kills_stats", "ejectingPilots" ) )
	//SetStatsLabelValue( menu, "Column0Value4", 		StatToInt( "kills_stats", "cloakedPilots" ) )
	//SetStatsLabelValue( menu, "Column0Value5", 		StatToInt( "kills_stats", "wallrunningPilots" ) )
	//SetStatsLabelValue( menu, "Column0Value6", 		StatToInt( "kills_stats", "wallhangingPilots" ) )

	SetStatsValueInfo( menu, 0, "#STATS_KILLS_PILOTS", 				StatToInt( "kills_stats", "totalPilots" ) )
	SetStatsValueInfo( menu, 1, "#STATS_KILLS_TITANS", 				StatToInt( "kills_stats", "totalTitans" ) )
	SetStatsValueInfo( menu, 2, "#STATS_KILLS_FIRST_STRIKES", 		StatToInt( "kills_stats", "firstStrikes" ) )
	SetStatsValueInfo( menu, 3, "#STATS_KILLS_CLOAKED_PILOTS", 		StatToInt( "kills_stats", "cloakedPilots" ) )
	SetStatsValueInfo( menu, 4, "#STATS_KILLS_WALLRUNNING_PILOTS", 	StatToInt( "kills_stats", "wallrunningPilots" ) )
	SetStatsValueInfo( menu, 5, "#STATS_KILLS_WALLHANGING_PILOTS", 	StatToInt( "kills_stats", "wallhangingPilots" ) )
	SetStatsValueInfo( menu, 6, "#STATS_KILLS_EJECTING_PILOTS", 	StatToInt( "kills_stats", "ejectingPilots" ) )

	//#########################
	// 	   Kills as Pilot
	//#########################

	local totalPetTitanKills = 0
	totalPetTitanKills += StatToInt( "kills_stats", "petTitanKillsFollowMode" )
	totalPetTitanKills += StatToInt( "kills_stats", "petTitanKillsGuardMode" )

	SetStatsLabelValue( menu, "Column1Value0", 		StatToInt( "kills_stats", "asPilot" ) )
	SetStatsLabelValue( menu, "Column1Value1", 		StatToInt( "kills_stats", "whileEjecting" ) )
	SetStatsLabelValue( menu, "Column1Value2", 		StatToInt( "kills_stats", "whileCloaked" ) )
	SetStatsLabelValue( menu, "Column1Value3", 		StatToInt( "kills_stats", "whileWallrunning" ) )
	SetStatsLabelValue( menu, "Column1Value4", 		StatToInt( "kills_stats", "whileWallhanging" ) )
	SetStatsLabelValue( menu, "Column1Value5", 		StatToInt( "kills_stats", "pilotExecutePilot" ) )
	SetStatsLabelValue( menu, "Column1Value6", 		StatToInt( "kills_stats", "pilotKickMeleePilot" ) )
	SetStatsLabelValue( menu, "Column1Value7", 		StatToInt( "kills_stats", "titanFallKill" ) )
	SetStatsLabelValue( menu, "Column1Value8", 		totalPetTitanKills )
	SetStatsLabelValue( menu, "Column1Value9", 		StatToInt( "kills_stats", "rodeo_total" ) )

	//#########################
	// 	   Kills as Titan
	//#########################

	local totalAsTitan = 0
	totalAsTitan += StatToInt( "kills_stats", "asTitan_stryder" )
	totalAsTitan += StatToInt( "kills_stats", "asTitan_atlas" )
	totalAsTitan += StatToInt( "kills_stats", "asTitan_ogre" )

	local totalTitanExecutions = 0
	totalTitanExecutions += StatToInt( "kills_stats", "titanExocutionStryder" )
	totalTitanExecutions += StatToInt( "kills_stats", "titanExocutionAtlas" )
	totalTitanExecutions += StatToInt( "kills_stats", "titanExocutionOgre" )

	SetStatsLabelValue( menu, "Column3Value0", 		totalAsTitan )
	SetStatsLabelValue( menu, "Column3Value1", 		StatToInt( "kills_stats", "titanMeleePilot" ) )
	SetStatsLabelValue( menu, "Column3Value2", 		totalTitanExecutions )
	SetStatsLabelValue( menu, "Column3Value3", 		StatToInt( "kills_stats", "titanStepCrushPilot" ) )

	//#########################
	// 	   K/D Ratios
	//#########################

	// Lifetime
	local lifetimeAverage = GetPersistentVar( "kdratio_lifetime" ).tofloat()
	local formattedLifetimeAverage
	if ( lifetimeAverage % 1 == 0 )
		formattedLifetimeAverage = format( "%.0f", lifetimeAverage )
	else
		formattedLifetimeAverage = format( "%.1f", lifetimeAverage )
	SetStatsLabelValue( menu, "LifetimeAverageValue", [ "#STATS_KD_VALUE", formattedLifetimeAverage ] )

	// Lifetime (PVP)
	local lifetimeAveragePVP = GetPersistentVar( "kdratio_lifetime_pvp" ).tofloat()
	local formattedLifetimeAveragePVP
	if ( lifetimeAveragePVP % 1 == 0 )
		formattedLifetimeAveragePVP = format( "%.0f", lifetimeAveragePVP )
	else
		formattedLifetimeAveragePVP = format( "%.1f", lifetimeAveragePVP )
	SetStatsLabelValue( menu, "LifetimePVPAverageValue", [ "#STATS_KD_VALUE", formattedLifetimeAveragePVP ] )

	// Last 10 Matches
	local kdratio_match = []
	local kdratiopvp_match = []
	for ( local i = NUM_GAMES_TRACK_KDRATIO - 1 ; i >= 0 ; i-- )
	{
		kdratio_match.append( GetPersistentVar( "kdratio_match[" + i + "]" ) )
		kdratiopvp_match.append( GetPersistentVar( "kdratiopvp_match[" + i + "]" ) )
	}

	// Last 10
	local kdratio_match_sum = 0
	local count = 0
	foreach( value in kdratio_match )
	{
		if ( value == 0 )
			continue
		kdratio_match_sum += value
		count++
	}
	local kdratio_match_average = count > 0 ? kdratio_match_sum / count : kdratio_match_sum
	if ( kdratio_match_average % 1 == 0 )
		kdratio_match_average = format( "%.0f", kdratio_match_average )
	else
		kdratio_match_average = format( "%.1f", kdratio_match_average )
	SetStatsLabelValue( menu, "Last10GamesValue", [ "#STATS_KD_VALUE", kdratio_match_average ] )
	PlotKDPointsOnGraph( menu, 0, kdratio_match, lifetimeAverage )

	// Last 10 (PVP)
	local kdratiopvp_match_sum = 0
	local count = 0
	foreach( value in kdratiopvp_match )
	{
		if ( value == 0 )
			continue
		kdratiopvp_match_sum += value
		count++
	}
	local kdratiopvp_match_average = count > 0 ? kdratiopvp_match_sum / count : kdratiopvp_match_sum
	if ( kdratiopvp_match_average % 1 == 0 )
		kdratiopvp_match_average = format( "%.0f", kdratiopvp_match_average )
	else
		kdratiopvp_match_average = format( "%.1f", kdratiopvp_match_average )
	SetStatsLabelValue( menu, "Last10GamesPVPValue", [ "#STATS_KD_VALUE", kdratiopvp_match_average ] )
	PlotKDPointsOnGraph( menu, 1, kdratiopvp_match, lifetimeAveragePVP )
}

function PlotKDPointsOnGraph( menu, graphIndex, values, dottedAverage )
{
	//printt( "values:" )
	//PrintTable( values )

	local background = GetElem( menu, "KDRatioLast10Graph" + graphIndex )
	local graphHeight = background.GetBaseHeight()
	local graphOrigin = background.GetAbsPos()
	graphOrigin[1] += graphHeight
	local dotSpacing = background.GetBaseWidth() / 9.0
	local dotPositions = []

	// Calculate min/max for the graph
	local graphMin = 0.0
	local graphMax = max( dottedAverage, 1.0 )
	foreach( value in values )
	{
		if ( value > graphMax )
			graphMax = value
	}
	graphMax += graphMax * 0.1

	local maxLabel = GetElem( menu, "Graph" + graphIndex + "ValueMax" )
	local maxValueString = format( "%.1f", graphMax )
	maxLabel.SetText( maxValueString )

	// Plot the dots
	for ( local i = 0 ; i < MAX_DOTS_ON_GRAPH ; i++ )
	{
		local dot = GetElem( menu, "Graph" + graphIndex + "Dot" + i )

		if ( i >= values.len() )
		{
			dot.Hide()
			continue
		}

		local dotOffset = GraphCapped( values[i], graphMin, graphMax, 0, graphHeight )

		local posX = graphOrigin[0] - ( dot.GetBaseWidth() * 0.5 ) + ( dotSpacing * i )
		local posY = graphOrigin[1] - ( dot.GetBaseHeight() * 0.5 ) - dotOffset
		dot.SetPos( posX, posY )
		dot.Show()

		dotPositions.append( [ posX + ( dot.GetBaseWidth() * 0.5 ), posY + ( dot.GetBaseHeight() * 0.5 ) ] )
	}

	// Place the dotted lifetime average line
	local dottedLine = GetElem( menu, "KDRatioLast10Graph" + graphIndex + "DottedLine0" )
	local dottedLineOffset = GraphCapped( dottedAverage, graphMin, graphMax, 0, graphHeight )
	local posX = graphOrigin[0]
	local posY = graphOrigin[1] - ( dottedLine.GetBaseHeight() * 0.5 ) - dottedLineOffset
	dottedLine.SetPos( posX, posY )
	dottedLine.Show()

	// Place the dotted zero line
	local dottedLine = GetElem( menu, "KDRatioLast10Graph" + graphIndex + "DottedLine1" )
	local dottedLineOffset = GraphCapped( 0.0, graphMin, graphMax, 0, graphHeight )
	local posX = graphOrigin[0]
	local posY = graphOrigin[1] - ( dottedLine.GetBaseHeight() * 0.5 ) - dottedLineOffset
	dottedLine.SetPos( posX, posY )
	dottedLine.Show()

	// Connect the dots with lines
	for ( local i = 1 ; i < MAX_DOTS_ON_GRAPH ; i++ )
	{
		local line = GetElem( menu, "Graph" + graphIndex + "Line" + i )

		if ( i >= values.len() )
		{
			line.Hide()
			continue
		}

		// Get angle from previous dot to this dot
		local startPos = dotPositions[i-1]
		local endPos = dotPositions[i]
		local offsetX = endPos[0] - startPos[0]
		local offsetY = endPos[1] - startPos[1]
		local angle = ( atan( offsetX / offsetY ) * ( 180 / PI ) )

		// Get line length
		local length = sqrt( offsetX * offsetX + offsetY * offsetY )

		// Calculate where the line should be positioned
		local posX = endPos[0] - ( offsetX / 2.0 ) - ( length / 2.0 )
		local posY = endPos[1] - ( offsetY / 2.0 ) - ( line.GetBaseHeight() / 2.0 )

		//line.SetHeight( 2.0 )
		line.SetWidth( length )
		line.SetRotation( angle + 90.0 )
		line.SetPos( posX, posY )
		line.Show()
	}

	AddMenuEventHandler(menu, R1DELTA_UIE_OPEN, OnOpenViewStatsKills)
}