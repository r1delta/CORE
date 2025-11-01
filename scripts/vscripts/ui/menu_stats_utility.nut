
function main()
{
	Globalize( SetPieChartData )
	Globalize( SetStatsBarValues )
	Globalize( SetStatsLabelValue )
	Globalize( SetStatsValueInfo )
	Globalize( GetPercent )
	Globalize( GetItemUnlockCountData )
	Globalize( GetChallengeCompleteData )
	Globalize( HoursToTimeString )
	Globalize( StatToDistanceString )
	Globalize( StatStringReplace )
}

function SetPieChartData( menu, panelName, titleString, data )
{
	local maxSlices = 6

	Assert( data.names.len() == data.values.len() )
	Assert( data.names.len() <= maxSlices )

	local backgroundColor = [ 190, 190, 190, 255 ]

	local colors = []
	colors.append( [ 192, 94, 75, 255 ] )
	colors.append( [ 194, 173, 76, 255 ] )
	colors.append( [ 88, 172, 67, 255 ] )
	colors.append( [ 77, 127, 196, 255 ] )
	colors.append( [ 166, 91, 191, 255 ] )
	colors.append( [ 46, 188, 180, 255 ] )

	if ( "colorShift" in data )
	{
		for ( local i = 0 ; i < data.colorShift ; i++ )
		{
			colors.append( colors[0] )
			colors.remove(0)
		}
	}

	Assert( colors.len() == maxSlices )

	// Get nested panel
	local piePanel = GetElem( menu, panelName )

	// Create background
	local background = piePanel.GetChild( "BarBG" )
	background.SetBarProgress( 1.0 )
	background.SetColor( backgroundColor )

	// Calculate total of all values combined
	if ( !( "sum" in data ) )
	{
		data.sum <- 0
		foreach( value in data.values )
			data.sum += value
	}

	// Calculate bar fraction for each value
	local valueFractions = []
	foreach( value in data.values )
	{
		if ( data.sum > 0 )
			valueFractions.append( value.tofloat() / data.sum.tofloat() )
		else
			valueFractions.append( 0 )
	}

	// Set slice sizes and text data
	local titleLabel = piePanel.GetChild( "Title" )
	titleLabel.SetText( titleString )
	if ( "labelColor" in data )
		titleLabel.SetColor( data.labelColor )

	local combinedFrac = 0.0
	foreach( index, frac in valueFractions )
	{
		local barColorGuide = piePanel.GetChild( "BarColorGuide" + index )
		barColorGuide.SetColor( colors[ index ] )
		barColorGuide.Show()

		local barColorGuideFrame = piePanel.GetChild( "BarColorGuideFrame" + index )
		barColorGuideFrame.Show()

		local percent = GetPercent( frac, 1.0, 0, true )
		local barName = piePanel.GetChild( "BarName" + index )
		if ( "labelColor" in data )
			barName.SetColor( data.labelColor )

		if ( "timeBased" in data )
			SetStatsLabelValueOnLabel( barName, HoursToTimeString( data.values[ index ], data.names[ index ], percent ) )
		else
			barName.SetText( "#STATS_TEXT_AND_PERCENTAGE", data.names[ index ], percent.tostring() )

		barName.Show()

		combinedFrac += frac
		local bar = piePanel.GetChild( "Bar" + index )
		bar.SetBarProgress( combinedFrac )
		bar.SetColor( colors[ index ] )
		bar.Show()
	}
}

function SetStatsBarValues( menu, panelName, titleString, startValue, endValue, currentValue )
{
	Assert( endValue > startValue )
	Assert( currentValue >= startValue && currentValue <= endValue )

	// Get nested panel
	local panel = GetElem( menu, panelName )

	// Update titel
	local title = panel.GetChild( "Title" )
	title.SetText( titleString )

	// Update progress text
	local progressText = panel.GetChild( "ProgressText" )
	progressText.SetText( "#STATS_PROGRESS_BAR_VALUE", currentValue, endValue )

	// Update bar progress
	local frac = GraphCapped( currentValue, startValue, endValue, 0.0, 1.0 )

	local barFill = panel.GetChild( "BarFill" )
	barFill.SetScaleX( frac )

	local barFillShadow = panel.GetChild( "BarFillShadow" )
	barFillShadow.SetScaleX( frac )
}

function SetStatsValueInfo( menu, valueID, labelText, textString )
{
	local elem = GetElem( menu, "Column0Label" + valueID )
	Assert( elem != null )
	elem.SetText( labelText )

	local elem = GetElem( menu, "Column0Value" + valueID )
	Assert( elem != null )
	SetStatsLabelValueOnLabel( elem, textString )
}

function SetStatsLabelValue( menu, labelName, textString )
{
	local elem = GetElem( menu, labelName )
	Assert( elem != null)
	SetStatsLabelValueOnLabel( elem, textString )
}

function SetStatsLabelValueOnLabel( elem, textString )
{
	if ( type( textString ) == "array" )
	{
		if ( textString.len() == 6 )
			elem.SetText( textString[0].tostring(), textString[1], textString[2], textString[3], textString[4], textString[5] )
		if ( textString.len() == 5 )
			elem.SetText( textString[0].tostring(), textString[1], textString[2], textString[3], textString[4] )
		if ( textString.len() == 4 )
			elem.SetText( textString[0].tostring(), textString[1], textString[2], textString[3] )
		if ( textString.len() == 3 )
			elem.SetText( textString[0].tostring(), textString[1], textString[2] )
		if ( textString.len() == 2 )
			elem.SetText( textString[0].tostring(), textString[1] )
		if ( textString.len() == 1 )
			elem.SetText( textString[0].tostring() )
	}
	else
	{
		elem.SetText( textString.tostring() )
	}
}

function GetPercent( numerator, denominator, defaultVal, clamp = true )
{
	local percent = defaultVal
	if ( denominator > 0 )
	{
		percent = numerator.tofloat() / denominator.tofloat()
		percent *= 100
		percent += 0.5
		percent = percent.tointeger()
	}

	if ( clamp )
	{
		if ( percent < 0 )
			percent = 0
		if ( percent > 100 )
			percent = 100
	}

	return percent
}

function GetChallengeCompleteData()
{
	local table = {}
	table.total <- 0
	table.complete <- 0

	UI_GetAllChallengesProgress()
	local allChallenges = GetLocalChallengeTable()

	foreach( challengeRef, val in allChallenges )
	{
		if ( IsDailyChallenge( challengeRef ) )
			continue
		local tierCount = GetChallengeTierCount( challengeRef )
		table.total += tierCount
		for ( local i = 0 ; i < tierCount ; i++ )
		{
			if ( IsChallengeTierComplete( challengeRef, i ) )
				table.complete++
		}
	}

	return table
}

function GetItemUnlockCountData()
{
	local table = {}
	table[ "weapons" ] <- {}
	table[ "weapons" ].total <- 0
	table[ "weapons" ].unlocked <- 0
	table[ "attachments" ] <- {}
	table[ "attachments" ].total <- 0
	table[ "attachments" ].unlocked <- 0
	table[ "mods" ] <- {}
	table[ "mods" ].total <- 0
	table[ "mods" ].unlocked <- 0
	table[ "abilities" ] <- {}
	table[ "abilities" ].total <- 0
	table[ "abilities" ].unlocked <- 0
	table[ "gear" ] <- {}
	table[ "gear" ].total <- 0
	table[ "gear" ].unlocked <- 0

	local tableMapping = {}

	tableMapping[ itemType.PILOT_PRIMARY ] 			<- "weapons"
	tableMapping[ itemType.PILOT_SECONDARY ] 		<- "weapons"
	tableMapping[ itemType.PILOT_SIDEARM ] 			<- "weapons"
	tableMapping[ itemType.PILOT_ORDNANCE ] 		<- "weapons"
	tableMapping[ itemType.TITAN_PRIMARY ] 			<- "weapons"
	tableMapping[ itemType.TITAN_ORDNANCE ] 		<- "weapons"
	tableMapping[ itemType.PILOT_PRIMARY_ATTACHMENT ] <- "attachments"
	tableMapping[ itemType.PILOT_PRIMARY_MOD ] 		<- "mods"
	tableMapping[ itemType.PILOT_SECONDARY_MOD ] 	<- "mods"
	tableMapping[ itemType.PILOT_SIDEARM_MOD ] 		<- "mods"
	tableMapping[ itemType.TITAN_PRIMARY_MOD ] 		<- "mods"
	tableMapping[ itemType.PILOT_SPECIAL ] 			<- "abilities"
	tableMapping[ itemType.TITAN_SPECIAL ] 			<- "abilities"
	tableMapping[ itemType.PILOT_PASSIVE1 ] 		<- "gear"
	tableMapping[ itemType.PILOT_PASSIVE2 ] 		<- "gear"
	tableMapping[ itemType.TITAN_PASSIVE1 ] 		<- "gear"
	tableMapping[ itemType.TITAN_PASSIVE2 ] 		<- "gear"

	local itemRefs = GetAllItemRefs()
	foreach( data in itemRefs )
	{
		if ( !( data.type in tableMapping ) )
			continue
		table[ tableMapping[ data.type ] ].total++

		if ( !IsItemLocked( data.ref, data.childRef ) )
			table[ tableMapping[ data.type ] ].unlocked++
	}

	return table
}

function GetOverviewWeaponData()
{
	local table = {}
	table[ "most_kills" ] <- {}
	table[ "most_kills" ].ref <- null
	table[ "most_kills" ].printName <- null
	table[ "most_kills" ].val <- 0
	table[ "most_used" ] <- {}
	table[ "most_used" ].ref <- null
	table[ "most_used" ].printName <- null
	table[ "most_used" ].val <- 0
	table[ "highest_kpm" ] <- {}
	table[ "highest_kpm" ].ref <- null
	table[ "highest_kpm" ].printName <- null
	table[ "highest_kpm" ].val <- 0

	local allWeapons = []

	allWeapons.extend( GetAllItemsOfType( itemType.PILOT_PRIMARY ) )
	allWeapons.extend( GetAllItemsOfType( itemType.PILOT_SECONDARY ) )
	allWeapons.extend( GetAllItemsOfType( itemType.PILOT_SIDEARM ) )
	allWeapons.extend( GetAllItemsOfType( itemType.TITAN_PRIMARY ) )
	allWeapons.extend( GetAllItemsOfType( itemType.TITAN_ORDNANCE ) )

	foreach( weapon in allWeapons )
	{
		local weaponName = weapon.ref
		local weaponDisplayName = GetWeaponInfoFileKeyField_Global( weaponName, "printname" )

		local val = StatToInt( "weapon_kill_stats", "total", weaponName )
		if ( val > table[ "most_kills" ].val )
		{
			table[ "most_kills" ].ref = weaponName
			table[ "most_kills" ].printName = weaponDisplayName
			table[ "most_kills" ].val = val
		}

		val = StatToFloat( "weapon_stats", "hoursUsed", weaponName )
		if ( val > table[ "most_used" ].val )
		{
			table[ "most_used" ].ref = weaponName
			table[ "most_used" ].printName = weaponDisplayName
			table[ "most_used" ].val = val
		}

		local killsPerMinute = 0
		local hoursEquipped = StatToFloat( "weapon_stats", "hoursEquipped", weaponName )
		local killCount = StatToInt( "weapon_kill_stats", "total", weaponName )
		if ( hoursEquipped > 0 )
			killsPerMinute = format( "%.2f", ( killCount / ( hoursEquipped * 60.0 ) ).tofloat() )
		if ( killsPerMinute.tofloat() > table[ "highest_kpm" ].val.tofloat() )
		{
			table[ "highest_kpm" ].ref = weaponName
			table[ "highest_kpm" ].printName = weaponDisplayName
			table[ "highest_kpm" ].val = killsPerMinute
		}
	}

	return table
}

function StatStringReplace( string, searchString, replaceString )
{
	local ex = regexp( searchString )
	local res = ex.search(string)
	if ( res != null )
	{
		local part1 = ""
		local part2 = ""

		part1 = string.slice( 0, res.begin )
		part2 = string.slice( res.end, string.len() )

		string = part1 + replaceString.tostring() + part2
	}
	return string
}

function StatToTimeString( category, alias, weapon = null )
{
	//Converts hours float to a formatted time string

	local statString = GetPersistentStatVar( category, alias, weapon )
	local savedHours = GetPersistentVar( statString )

	return HoursToTimeString( savedHours )
}

function HoursToTimeString( savedHours, pieChartHeader = null, pieChartPercent = null )
{
	local timeString = []
	local minutes = floor( savedHours * 60.0 )

	if ( minutes < 0 )
		minutes = 0

	local days = 0
	local hours = 0

	while( minutes >= 1440 )
	{
		minutes -= 1440
		days++
	}

	while( minutes >= 60 )
	{
		minutes -= 60
		hours++
	}


	if ( days > 0 && hours > 0 && minutes > 0 )
	{
		timeString.append( "#STATS_TIME_STRING_D_H_M" )
		timeString.append( days )
		timeString.append( hours )
		timeString.append( minutes )
	}
	else if ( days > 0 && hours == 0 && minutes == 0 )
	{
		timeString.append( "#STATS_TIME_STRING_D" )
		timeString.append( days )
	}
	else if ( days == 0 && hours > 0 && minutes == 0 )
	{
		timeString.append( "#STATS_TIME_STRING_H" )
		timeString.append( hours )
	}
	else if ( days == 0 && hours == 0 && minutes >= 0 )
	{
		timeString.append( "#STATS_TIME_STRING_M" )
		timeString.append( minutes )
	}
	else if ( days > 0 && hours > 0 && minutes == 0 )
	{
		timeString.append( "#STATS_TIME_STRING_D_H" )
		timeString.append( days )
		timeString.append( hours )
	}
	else if ( days == 0 && hours > 0 && minutes > 0 )
	{
		timeString.append( "#STATS_TIME_STRING_H_M" )
		timeString.append( hours )
		timeString.append( minutes )
	}
	else if ( days > 0 && hours == 0 && minutes > 0 )
	{
		timeString.append( "#STATS_TIME_STRING_D_M" )
		timeString.append( days )
		timeString.append( minutes )
	}
	else
		Assert( 0, "Unhandled time string creation case" )

	if ( pieChartHeader != null )
	{
		Assert( pieChartPercent != null )
		timeString[0] = timeString[0] + "_PIECHART"
		timeString.append( pieChartHeader )
		timeString.append( pieChartPercent )
	}

	return timeString
}

function StatToDistanceString( category, alias, weapon = null )
{
	local statString = GetPersistentStatVar( category, alias, weapon )
	local kilometers = GetPersistentVar( statString )

	local distString = []

	distString.append( "#STATS_KILOMETERS_ABBREVIATION" )

	if ( kilometers % 1 == 0 )
		distString.append( format( "%.0f", kilometers ) )
	else
		distString.append( format( "%.2f", kilometers ) )

	return distString
}