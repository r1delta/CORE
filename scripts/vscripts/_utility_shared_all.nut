
function PrintObject( obj, indent, depth, maxDepth )
{
	if ( IsTable( obj ) )
	{
		if ( depth >= maxDepth )
		{
			printl( "{...}" )
			return
		}

		printl( "{" )
		foreach ( k, v in obj )
		{
			print( TableIndent( indent + 2 ) + k + " = " )
			PrintObject( v, indent + 2, depth + 1, maxDepth )
		}
		printl( TableIndent( indent ) + "}" )
	}
	else if ( IsArray( obj ) )
	{
		if ( depth >= maxDepth )
		{
			printl( "[...]" )
			return
		}

		printl( "[" )
		foreach ( v in obj )
		{
			print( TableIndent( indent + 2 ) )
			PrintObject( v, indent + 2, depth + 1, maxDepth )
		}
		printl( TableIndent( indent ) + "]" )
	}
	else if ( obj != null )
	{
		printl( "" + obj )
	}
	else
	{
		printl( "<null>" )
	}
}



function FunctionToString( func )
{
	Assert( func, "No function passed" )
	Assert( type( func ) == "function", "Type " + type( func ) + " is not a function" )

	return func.getinfos().name
}

// dump the stack trace to the console
function DumpStack( offset = 1 )
{
	for ( local i = offset; i < 20; i++ )
	{
		if ( !( "src" in getstackinfos(i) ) )
			break
		printl( i + " File : " + getstackinfos(i)["src"] + " [" + getstackinfos(i)["line"] + "]\n    Function : " + getstackinfos(i)["func"] + "() " )
	}
}

function DumpPreviousFunction()
{
	local i = 3
	if ( !( "src" in getstackinfos(i) ) )
		return
	printl( "Called from: " + getstackinfos(i)["src"] + " [" + getstackinfos(i)["line"] + "] : " + getstackinfos(i)["func"] + "() " )
}

function GetPreviousFunction()
{
	local i = 3
	if ( !( "src" in getstackinfos(i) ) )
		return ""
	return "Called from: " + getstackinfos(i)["src"] + " [" + getstackinfos(i)["line"] + "] : " + getstackinfos(i)["func"] + "() "
}

function IsNewThread()
{
	//return threads.GetCurrentThread().co == getthread()
	local i = 0
	for ( i = 0; i < 20; i++ )
	{
		if ( !( "src" in getstackinfos(i) ) )
			break
	}

	return i == 3
}

function AssertParameters( func, paramCount, paramDesc )
{
	local funcInfos = func.getinfos()
	local funcName = funcInfos.name
	// subtract one from the param count for the hidden "this" object
	Assert( funcInfos.parameters.len() == (paramCount + 1), "Function \"" + funcName +"\" must have exactly " + paramCount + " parameters (" + paramDesc + ")." )

}


function PrintTable( tbl, indent = 0, maxDepth = 4 )
{
	print( TableIndent( indent ) )
	PrintObject( tbl, indent, 0, maxDepth )
}

function Bind( func )
{
	// If you want to run a file-scoped function from outside the file
	// you have to bind its environment when you store the variable.
	return func.bindenv( this )
}

function TableIndent( indent )
{
	return ("                                            ").slice( 0, indent )
}

function ArrayRandomize( array )
{
	local temp, tempIndex

	for ( local i = 0; i < array.len(); i++ )
	{
		temp = array[i]
		tempIndex = i + RandomInt( array.len() - i )

		array[i] = array[tempIndex]
		array[tempIndex] = temp
	}
}

function ArrayRemove( array, remove )
{
	Assert( type( array ) == "array" )

	foreach ( index, ent in array )
	{
		if ( ent == remove )
		{
			array.remove( index )
			break
		}
	}
}

function GetCurrentPlaylistVarInt( val, useVal )
{
	local result = GetCurrentPlaylistVarOrUseValue( val, useVal + "" )
	if ( result == null || result == "" )
		return 0

	return result.tointeger()
}

if ( !( "CodeRandomInt" in getroottable() ) )
{
	// Just wrap the functions once, if this script is re-run.

	// Change RandomInt to go from 0 to 1 - max.
	CodeRandomInt <- RandomInt
	function RandomInt( num, opmax = null )
	{
		if ( opmax != null )
			return CodeRandomInt( num, opmax - 1 )

		return CodeRandomInt( 0, num - 1 )
	}
	RegisterFunctionDesc( "RandomInt", "If one number is supplied, generate a random number between 0 and that number minus one. If two numbers, return a random number between parm 1 and parm 2 minus one." )
}

// Return a random entry from an array
function Random( array )
{
	Assert( type( array ) == "array", "Not an array" )
	if ( array.len() == 0 )
		return null

	local index = RandomInt( 0, array.len() )
	return array[ index ]
}

function GetCinematicMode()
{
	return GetCurrentPlaylistVarInt( "cinematic_mode", 0 )
}

function GetClassicMPMode()
{
	if ( IsTrainingLevel() )
		return false

	return GetCurrentPlaylistVarInt( "classic_mp", 0 )
}

function IsTrainingLevel()
{
	if ( IsUI() )
	{
		local levelname = GetActiveLevel()
		if ( !levelname )
			return false

		return levelname == "mp_trainer" || levelname == "mp_npe"
	}
	else
		return level.isTrainingLevel
}

function SortLowest( a, b )
{
	if ( a > b )
		return 1

	if ( a < b )
		return -1

	return 0
}

function SortHighest( a, b )
{
	if ( a < b )
		return 1

	if ( a > b )
		return -1

	return 0
}

function min( a, b )
{
	if ( a < b )
		return a
	else
		return b
}

function max( a, b )
{
	if ( a > b )
		return a
	else
		return b
}

function fsel( A, B, C )
{
	if ( A >= 0 )
		return B;
	else
		return C;
}

function deg_sin( angle )
{
	return ( sin( angle * (PI/180) ) )
}

function deg_cos( angle )
{
	return ( cos( angle * (PI/180) ) )
}

function IsLobby()
{
	if ( IsUI() )
		return GetActiveLevel() == "mp_lobby"
	else
		return ( GetMapName() == "mp_lobby" )
}

function GetEnemyTeam( team )
{
	Assert( team == TEAM_IMC || team == TEAM_MILITIA )
	if (GetConVarString("mp_gamemode").tolower() == "ffa")
		return team
	if ( team == TEAM_IMC )
		return TEAM_MILITIA
	else
		return TEAM_IMC
}

function GetMapDisplayName( mapname )
{
	return "#" + mapname
}

function GetCampaignMapDisplayName( mapname )
{
	return "#" + mapname + "_CAMPAIGN_NAME"
}

function GetMapDisplayDesc( mapname )
{
	return "#" + mapname + "_CLASSIC_DESC"
}

function ArrayContains( array, testVal )
{
	Assert( type( array ) == "array" )

	foreach ( key, val in array )
	{
		if ( val == testVal )
			return true
	}

	return false
}

function GetIndexInArray( array, val )
{
	foreach( i, v in array )
	{
		if ( val == v )
			return i
	}
	return -1
}

function StringContains( string, searchString )
{
	local ex = regexp( searchString )
	local res = ex.search(string)
	return ( res != null )
}

function StringReplace( string, searchString, replaceString )
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

function RoundToNearestInt( value )
{
	return floor( value + 0.5 )
}

function RoundToNearestMultiplier( value, multiplier )
{
	local remainder = value % multiplier

	value -= remainder

	if ( remainder >= ( multiplier / 2 ) )
		value += multiplier

	return value
}

function DevEverythingUnlocked()
{
	return EverythingUnlockedConVarEnabled()
}

function IsPlayerEverythingUnlocked( player = null )
{
	// assume this is uiscript
	if ( player == null )
	{
		local value = GetPersistentVar( "delta.everythingUnlocked" )

		return value ? true : false
	}

	return player.GetPersistentVar( "delta.everythingUnlocked" ) ? true : false
}

function MapIsValidForPersistence( mapName )
{
	return PersistenceEnumValueIsValid( "maps", mapName )
}

function GetTimesPlayedMap( mapName, player = null )
{
	if ( !IsUI() )
		Assert( IsValid( player ) )

	local numModes = PersistenceGetEnumCount( "gameModes" )
	if ( !MapIsValidForPersistence( mapName ) )
		return 0

	local statVarName = GetPersistentStatVar( "game_stats", "game_completed" )
	local fixedSaveVar
	local timesPlayed = 0
	for ( local modeIndex = 0 ; modeIndex < numModes ; modeIndex++ )
	{
		fixedSaveVar = statVarName
		fixedSaveVar = StatStringReplace( fixedSaveVar, "%mapname%", mapName )
		fixedSaveVar = StatStringReplace( fixedSaveVar, "%gamemode%", modeIndex )
		timesPlayed += IsUI()? GetPersistentVar( fixedSaveVar ) : player.GetPersistentVar( fixedSaveVar )
	}

	return timesPlayed
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

function GetAllModesAndMapsCompleteData( player = null )
{
	if ( !IsUI() )
		Assert( IsValid( player ) )

	// hard coded list of shipping maps and modes
	local modes = []
	modes.append( "tdm" )
	modes.append( "cp" )
	modes.append( "at" )
	modes.append( "ctf" )
	modes.append( "lts" )

	local maps = []
	maps.append( "mp_airbase" )
	maps.append( "mp_angel_city" )
	maps.append( "mp_boneyard" )
	maps.append( "mp_colony" )
	maps.append( "mp_corporate" )
	maps.append( "mp_fracture" )
	maps.append( "mp_lagoon" )
	maps.append( "mp_nexus" )
	maps.append( "mp_o2" )
	maps.append( "mp_outpost_207" )
	maps.append( "mp_overlook" )
	maps.append( "mp_relic" )
	maps.append( "mp_rise" )
	maps.append( "mp_smugglers_cove" )
	maps.append( "mp_training_ground" )

	local data = {}
	data.required <- modes.len() * maps.len()
	data.progress <- 0

	local currentMap = null
	local currentMode = null
	if ( !IsLobby() && !IsUI() )
	{
		currentMap = GetMapName()
		currentMode = GameRules.GetGameMode()
	}

	local statVarName = GetPersistentStatVar( "game_stats", "game_completed" )
	local fixedSaveVar
	foreach( mode in modes )
	{
		foreach( map in maps )
		{
			fixedSaveVar = statVarName
			fixedSaveVar = StatStringReplace( fixedSaveVar, "%mapname%", map )
			fixedSaveVar = StatStringReplace( fixedSaveVar, "%gamemode%", mode )

			if ( map == currentMap && mode == currentMode )
			{
				data.progress++
				continue
			}

			local timesPlayed = IsUI()? GetPersistentVar( fixedSaveVar ) : player.GetPersistentVar( fixedSaveVar )
			if ( timesPlayed > 0 )
				data.progress++
		}
	}

	return data
}

function Daily_GetCurrentTime()
{
	// Returns the unix timestap offset to the timezone we want to use
	return GetUnixTimestamp() + DAILY_RESET_TIME_ZONE_OFFSET * SECONDS_PER_HOUR
}

function Daily_GetDay( timeStamp = null )
{
	// Returns an integer for what day it is. Each day is +1 from previous day
	if ( timeStamp == null )
		timeStamp = Daily_GetCurrentTime()
	return (timeStamp / SECONDS_PER_DAY).tointeger()
}

function Daily_SecondsTillDayEnd()
{
	// Returns the number of seconds left in the current day. This can be used in a timer to count down till the end of the day when dailies reset
	local currentDayStart = Daily_GetDay() * SECONDS_PER_DAY
	return currentDayStart + SECONDS_PER_DAY - Daily_GetCurrentTime()
}

function GetPersistenceEnumAsArray( persistenceEnumName )
{
	local enumSize = PersistenceGetEnumCount( persistenceEnumName )
	local returnArray = []
	for ( local i = 0 ; i < enumSize ; i++ )
	{
		returnArray.append( PersistenceGetEnumItemNameForIndex( persistenceEnumName, i ) )
	}

	return returnArray
}

function GetCampaignLevelIndex( mapName )
{
	if ( mapName in campaignMaps )
		return campaignMaps[ mapName ]
	return null
}

if ( IsClient() )
{
	function PlayerPlayingRanked( player )
	{
		if ( !level.rankedPlayEnabled )
			return false

		if ( player.IsBot() )
			return true

		// return true
		return player.IsPlayingRanked()
	}
}

if ( IsServer() )
{
	function PlayerPlayingRanked( player )
	{
		if ( !level.rankedPlayEnabled )
			return false

		if ( player.IsBot() )
			return true

		return player.GetPersistentVar( "ranked.isPlayingRanked" )
	}
}

if ( IsUI() )
{
	function PlayerPlayingRanked( player = null )
	{
		return GetPersistentVar( "ranked.isPlayingRanked" )
	}
}

function PlayerPlayingRanked( player = null )
{
	if ( IsServer() )
	{
		if ( !level.rankedPlayEnabled )
			return false

		if ( player.IsBot() )
			return true

		return player.GetPersistentVar( "ranked.isPlayingRanked" )
	}

	if ( IsClient() )
	{
		if ( !level.rankedPlayEnabled )
			return false

		if ( player.IsBot() )
			return true
		// return true
		// return player.GetPersistentVar( "ranked.isPlayingRanked" )
		return player.IsPlayingRanked()
	}

	if ( IsUI() )
	{
		return GetPersistentVar( "ranked.isPlayingRanked" )
	}
}

function SkillToString( val )
{
	// Don't show .0 for ints
	if ( val % 1 == 0 )
		return format( "%i", val )

	return format( "%.1f", val )
}

function SkillToPerformance( val )
{
	return ( val * 100 ).tointeger()
}

function ShouldSetGoldTierStar( mapName, modeName, player = null, usePreviousScores = false )
{
	if ( !IsUI() )
	{
		Assert( player != null )
		Assert( player.IsPlayer() )
	}

	if ( !PersistenceEnumValueIsValid( "maps", mapName ) )
		return false

	if ( !PersistenceEnumValueIsValid( "gameModesWithStars", modeName ) )
		return false

	local scores = GetStarBestScores( mapName, modeName, player )
	local scoreToBeat = GetStarScoreRequirements( modeName , mapName )[MAX_STAR_COUNT]
	local score
	if ( usePreviousScores )
		score = scores.previous
	else
		score = scores.now

	if ( score >= scoreToBeat )//scoreToBeat )
		return true

	return false
}

function GetStarsForScores( mapName, modeName, player = null )
{
	if ( !IsUI() )
	{
		Assert( player != null )
		Assert( player.IsPlayer() )
	}

	local starCounts = {}
	starCounts.now <- 0
	starCounts.previous <- 0

	if ( !PersistenceEnumValueIsValid( "maps", mapName ) )
		return starCounts

	if ( !PersistenceEnumValueIsValid( "gameModesWithStars", modeName ) )
		return starCounts

	local scores = GetStarBestScores( mapName, modeName, player )
	local scoreReqs = GetStarScoreRequirements( modeName, mapName )

	for( local i = 0; i < MAX_STAR_COUNT; i ++ )
	{
		local score = scoreReqs[i]
		if ( scores.now >= score )
			starCounts.now++
		if ( scores.previous >= score )
			starCounts.previous++
	}

	return starCounts
}

function GetStarBestScores( mapName, modeName, player = null )
{
	if ( !IsUI() )
	{
		Assert( player != null )
		Assert( player.IsPlayer() )
	}

	if ( !PersistenceEnumValueIsValid( "maps", mapName ) )
		return 0

	if ( !PersistenceEnumValueIsValid( "gameModesWithStars", modeName ) )
		return 0

	local scores = {}

	local varName = "mapStars[" + mapName + "].bestScore[" + modeName + "]"
	scores.now <- IsUI() ? GetPersistentVar( varName ) : player.GetPersistentVar( varName )

	varName = "mapStars[" + mapName + "].previousBestScore[" + modeName + "]"
	scores.previous <- IsUI() ? GetPersistentVar( varName ) : player.GetPersistentVar( varName )

	return scores
}

function GetStarScoreRequirements( modeName, mapName = null )
{
	Assert( modeName in GAMETYPE_STAR_SCORE_REQUIREMENT )
	if ( modeName == COOPERATIVE )
	{
		if ( !( mapName in COOP_STAR_SCORE_REQUIREMENT ) )
			return COOP_STAR_SCORE_REQUIREMENT[ "default" ]	// so that we don't break test maps etc.

		return COOP_STAR_SCORE_REQUIREMENT[ mapName ]
	}

	return GAMETYPE_STAR_SCORE_REQUIREMENT[ modeName ]
}

function GetTotalMapStarsForMode( modeName, player = null )
{
	if ( !IsUI() )
	{
		Assert( player != null )
		Assert( player.IsPlayer() )
	}

	local mapCount = PersistenceGetEnumCount( "maps" )
	local mapName = null
	local totalStars = 0
	for ( local i = 0 ; i < mapCount ; i++ )
	{
		mapName = PersistenceGetEnumItemNameForIndex( "maps", i )
		totalStars += GetStarsForScores( mapName, modeName, player ).now
	}

	return totalStars
}

function Coop_GetMaxTeamScore( mapName = null )
{
	//Coop gives 3 stars for 90% completion, but this returns the max possible value.
	if ( mapName == null )
		mapName = GetMapName()

	if ( developer() > 0 && !( mapName in COOP_STAR_SCORE_REQUIREMENT ) )
		return COOP_STAR_SCORE_REQUIREMENT[ "default" ][MAX_STAR_COUNT]	// so that we don't break test maps etc.

	Assert( mapName in COOP_STAR_SCORE_REQUIREMENT )
	return COOP_STAR_SCORE_REQUIREMENT[ mapName ][MAX_STAR_COUNT]
}

function SecondsToDHMS( seconds )
{
	local times = {}

	// extract days
	times["d"] <- floor( seconds / SECONDS_PER_DAY )

	// extract hours
	local hourSeconds = seconds % SECONDS_PER_DAY
	times["h"] <- floor( hourSeconds / SECONDS_PER_HOUR )

	// extract minutes
	local minuteSeconds = hourSeconds % SECONDS_PER_HOUR
	times["m"] <- floor( minuteSeconds / SECONDS_PER_MINUTE )

	// extract the remaining seconds
	local remainingSeconds = minuteSeconds % SECONDS_PER_MINUTE
	times["s"] <- ceil( remainingSeconds )

	return times
}

function __YearToDays(y)
{
	return (y)*365 + (y)/4 - (y)/100 + (y)/400
}

function GetUnixTimeParts( unixtime = null )
{
	// Chad's function to convert unix time to month, day, year, hours, minutes, seconds. Used for ranked play seasons

	local timeParts = {}
	timeParts["year"] <- null
	timeParts["month"] <- null
	timeParts["day"] <- null
	timeParts["hour"] <- null
	timeParts["minute"] <- null
	timeParts["second"] <- null

	if ( unixtime == null )
		unixtime = Daily_GetCurrentTime()

	// Get hours / minutes / seconds

	timeParts["second"] = unixtime % 60
	unixtime /= 60

	timeParts["minute"] = unixtime % 60
	unixtime /= 60

	timeParts["hour"] = unixtime % 24
	unixtime /= 24

	// unixtime is now days since 01/01/1970 UTC * Rebaseline to the Common Era

	unixtime += 719499

	// Roll forward looking for the year. Have to start at 1969 because the year we calculate here
	// runs from March, so January and February 1970 will come out as 1969

	for ( timeParts["year"] = 1969 ; unixtime > __YearToDays( timeParts["year"] + 1 ) + 30 ; timeParts["year"]++ )
	{
	}

	// We have our "year", so subtract off the days accounted for by full years.
	unixtime -= __YearToDays( timeParts["year"] )

	// unixtime is now number of days we are into the year (remembering that March 1 is the first day of the "year" still)

	// Roll forward looking for the month. 1 = March through to 12 = February
	for ( timeParts["month"] = 1 ; timeParts["month"] < 12 && unixtime > 367 * ( timeParts["month"] + 1 ) / 12 ; timeParts["month"]++ )
	{
	}

	// Subtract off the days accounted for by full months
	unixtime -= 367 * timeParts["month"] / 12

	// unixtime is now number of days we are into the month

	// Adjust the month/year so that 1 = January, and years start where we usually expect them to
	timeParts["month"] += 2
	if ( timeParts["month"] > 12 )
	{
		timeParts["month"] -= 12
		timeParts["year"]++
	}

	timeParts["day"] = unixtime

	//printt( "Current Date and Time:" )
	//printt( "    ", timeParts["month"] + "/" + timeParts["day"] + "/" + timeParts["year"], "-", timeParts["hour"] + ":" + timeParts["minute"] + ":" + timeParts["second"] )
	return timeParts
}

function PrintTimeParts( table )
{
	printt( "    ", table["month"] + "/" + table["day"] + "/" + table["year"], "-", table["hour"] + ":" + table["minute"] + ":" + table["second"] )
}

function IsPrivateMatch()
{
    if( !IsServer() && !IsConnected() )
        return false

    // since vanilla will reload the playlists we can get away with using a bogus default value since it shouldn't exist
	// this will 100% fall apart if we run loadPlaylists in mp_lobby, but should probably be fine since we always hit frontend when hosting
	if( GetCurrentPlaylistVarInt( "private_match", 2 ) == 2)
		return GetCurrentPlaylistName() == "private_match" && GetConVarInt("sv_lobbyType") == 1
	if( IsLobby() )
		return GetCurrentPlaylistName() == "private_match" && GetConVarInt("sv_lobbyType") == 1
	else
	{
    	return ( GetCurrentPlaylistVarInt( "private_match", 0 ) == 1 ) && ( GetConVarInt("sv_lobbyType") == 1 )
	}
}

function FNV1A( str )
{
	local hash = 2166136261
	local prime = 16777619

	for ( local i = 0; i < str.len(); i++ )
	{
		hash = hash ^ str[i]
		hash *= prime
	}

	return hash
}

function StringReplaceAll(original, find, replace)
{
    local result = ""
    local pos = 0
    local find_len = find.len()

    if (find_len == 0)
        return original


    while (true)
    {
        local index = original.find(find, pos)

        if (index == null)
        {
            local remaining = original.slice(pos, original.len())
            result += remaining
            break
        }

        local before = original.slice(pos, index);
        result += before + replace;

        pos = index + find_len;
    }

    return result;
}
