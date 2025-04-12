
function main()
{
	Globalize( GetLastServerMap )
	Globalize( GetLastServerGameMode )
	Globalize( GetServerMapHistory )
	Globalize( GetServerModeHistory )
	Globalize( GetRecentServerMap )
	Globalize( GetRecentServerMode )

	Globalize( InitPlayerMapHistory )
	Globalize( InitPlayerModeHistory )
	Globalize( UpdatePlayerMapHistory )
	Globalize( UpdatePlayerModeHistory )
	Globalize( GetPlayerMapHistory )
	Globalize( GetPlayerModeHistory )

	Globalize( GetPlaylistCombos )
	Globalize( GetPlaylistUniqueMaps )
	Globalize( GetPlaylistUniqueModes )
	Globalize( GetCurrentPlaylistMaps )
	Globalize( GetMapIndex )

	Globalize( DLCFilterCombos )
	Globalize( DLCFilterMaps )
	//Globalize( PlaylistFilterMaps )
	//Globalize( PlaylistFilterModes )

	level.nextGameTest <- true
	Globalize( IsNextGameTest )

	if ( developer() )
	{
		Globalize( PrintPlayerMapHistory )
		Globalize( PrintPlayerModeHistory )

		if ( IsNextGameTest() )
		{
			level.recentMaps <- []
			level.recentModes <- []
		}
	}
}

function IsNextGameTest()
{
	if ( "nextGameTest" in level )
		return level.nextGameTest
	else
		return false
}

function GetLastServerMap()
{
	local lastMap
	local index = IsNextGameTest() ? 0 : 1 // When using real history, 0 is the current and 1 is the last map

	for ( ;; )
	{
		lastMap = GetRecentServerMap( index )
		index++

		if ( lastMap == null || lastMap == "" )
			return null

		if ( lastMap != "mp_lobby" )
			return lastMap
	}
}

function GetLastServerGameMode()
{
	local lastMode
	local lastMap
	local index = IsNextGameTest() ? 0 : 1 // When using real history, 0 is the current and 1 is the last map

	for ( ;; )
	{
		lastMode = GetRecentServerMode( index )
		lastMap = GetRecentServerMap( index )
		index++

		if ( lastMode == null || lastMode == "" )
			return null

		if ( lastMap != "mp_lobby" )
			return lastMode
	}
}

// Returns a list of played maps, limited to the map count of the current playlist, or available maps in the case of private match
function GetServerMapHistory( mapCount = MAX_GAME_HISTORY )
{
	local playlist = GetCurrentPlaylistName()
	local mapNames = []
	local mapName
	local index = 0

	for ( ;; )
	{
		mapName = GetRecentServerMap( index )

		if ( mapName == null || mapName == "" )
			break

		if ( mapName != "mp_lobby" )
		{
			mapNames.append( mapName )
			//printl( "Appending Map: " + mapName )

			if ( mapNames.len() >= mapCount )
				break
		}

		index++
	}

	return mapNames
}

// Returns a list of played modes, limited to the mode count of the current playlist, or available modes in the case of private match
function GetServerModeHistory( modeCount = MAX_GAME_HISTORY )
{
	local playlist = GetCurrentPlaylistName()
	local mapNames = []
	local mapName

	local modeNames = []
	local modeName
	local index = 0

	for ( ;; )
	{
		mapName = GetRecentServerMap( index )
		modeName = GetRecentServerMode( index )

		if ( mapName == null || mapName == "" )
			break

		if ( mapName != "mp_lobby" )
		{
			modeNames.append( modeName )
			//printl( "Appending Mode: " + modeName )

			if ( modeNames.len() >= modeCount )
				break
		}

		index++
	}

	return modeNames
}

function GetPlaylistCombos( playlist )
{
	local combos = []
	local count = GetMapCountForPlaylist( playlist )

	for ( local index = 0; index < count; index++ )
	{
		local table = {}
		table.index <- index
		table.mapName <- GetPlaylistMapByIndex( playlist, index )
		table.modeName <- GetPlaylistGamemodeByIndex( playlist, index )

		combos.append( table )
	}

	return combos
}

function GetMapIndex( mapName )
{
	local playlist = GetCurrentPlaylistName()
	local playlistMaps = GetPlaylistCombos( playlist )

	local index = 0
	foreach( map in playlistMaps )
	{
		if ( map == mapName )
			return index

		index++
	}

	printt( "Map not found in playlist!" )
}

// Used by UpdateCampaignCompletion()
function GetCurrentPlaylistMaps()
{
	local maps = []
	local count = GetMapCountForCurrentPlaylist()

	for ( local index = 0; index < count; index++ )
	{
		maps.append( GetCurrentPlaylistMapByIndex( index ) )
	}

	return maps
}

function GetPlaylistUniqueMaps( playlist )
{
	local maps = []
	local count = GetMapCountForPlaylist( playlist )
	local mapName

	for ( local index = 0; index < count; index++ )
	{
		mapName = GetPlaylistMapByIndex( playlist, index )

		if ( !ArrayContains( maps, mapName ) )
			maps.append( mapName )
	}

	return maps
}

function GetPlaylistUniqueModes( playlist )
{
	local modes = []
	local count = GetGamemodeCountForPlaylist( playlist )
	local modeName

	for ( local index = 0; index < count; index++ )
	{
		modeName = GetPlaylistGamemodeByIndex( playlist, index )

		if ( !ArrayContains( modes, modeName ) )
			modes.append( modeName )
	}

	return modes
}

function GetRecentServerMap( index )
{
	if ( IsNextGameTest() )
	{
		if ( index < level.recentMaps.len() )
			return level.recentMaps[ index ]

		return null
	}

	return GameRules.GetRecentMap( index )
}

function GetRecentServerMode( index )
{
	if ( IsNextGameTest() )
	{
		if ( index < level.recentModes.len() )
			return level.recentModes[ index ]

		return null
	}

	return GameRules.GetRecentGameMode( index )
}

// Same as map count for now
function GetGamemodeCountForPlaylist( playlist )
{
	return GetMapCountForPlaylist( playlist )
}

// Removes unavailable combos based on DLC map availability
function DLCFilterCombos( combos )
{
	local filteredCombos = []

	foreach ( combo in combos )
	{
		local dlcMapGroup = GetDLCMapGroupForMap( combo.mapName )

		if ( ServerHasDLCMapGroupEnabled( dlcMapGroup ) )
			filteredCombos.append( combo )
	}

	return filteredCombos
}

// Removes unavailable maps based on DLC map availability
function DLCFilterMaps( maplist )
{
	local filteredMaps = []

	foreach ( map in maplist )
	{
		local dlcMapGroup = GetDLCMapGroupForMap( map )

		if ( ServerHasDLCMapGroupEnabled( dlcMapGroup ) )
			filteredMaps.append( map )
	}

	return filteredMaps
}

// Removes maps not found in a given playlist
/*function PlaylistFilterMaps( maplist, playlist )
{
	local filteredMaps = []
	local playlistMaps = GetPlaylistUniqueMaps( playlist )

	foreach ( map in maplist )
	{
		if ( ArrayContains( playlistMaps, map ) )
			filteredMaps.append( map )
	}

	return filteredMaps
}

// Removes modes not found in a given playlist
function PlaylistFilterModes( modelist, playlist )
{
	local filteredModes = []
	local playlistModes = GetPlaylistUniqueModes( playlist )

	foreach ( mode in modelist )
	{
		if ( ArrayContains( playlistModes, mode ) )
			filteredModes.append( mode )
	}

	return filteredModes
}*/

// Initialize all player persistent map history to -1, which we treat as null
function InitPlayerMapHistory( player )
{
	local size = PersistenceGetArrayCount( "mapHistory" )

	for ( local i = 0; i < size; i++ )
		player.SetPersistentVar( "mapHistory[" + i + "]", -1 )
}

// Initialize all player persistent mode history to -1, which we treat as null
function InitPlayerModeHistory( player )
{
	local size = PersistenceGetArrayCount( "modeHistory" )

	for ( local i = 0; i < size; i++ )
		player.SetPersistentVar( "modeHistory[" + i + "]", -1 )
}

// Return a player map history array
function GetPlayerMapHistory( player )
{
	local mapIDHistory = GetPersistentIntArray( player, "mapHistory" )
	local enumCount = PersistenceGetEnumCount( "maps" )
	local mapHistory = []

	foreach ( mapID in mapIDHistory )
	{
		if ( !IsValidPersistentMapID( mapID ) )
			continue

		local mapName = PersistenceGetEnumItemNameForIndex( "maps", mapID )
		mapHistory.append( mapName )
	}

	return mapHistory
}

// Return a player mode history array
function GetPlayerModeHistory( player )
{
	local modeIDHistory = GetPersistentIntArray( player, "modeHistory" )
	local enumCount = PersistenceGetEnumCount( "gameModes" )
	local modeHistory = []

	foreach ( modeID in modeIDHistory )
	{
		if ( !IsValidPersistentModeID( modeID ) )
			continue

		local modeName = PersistenceGetEnumItemNameForIndex( "gameModes", modeID )
		modeHistory.append( modeName )
	}

	return modeHistory
}

// Add a played map to a player's persistent map history
function UpdatePlayerMapHistory( player, playedMapName )
{
	local mapHistory = GetPlayerMapHistory( player )
	local mapIDHistory = []

	mapHistory.insert( 0, playedMapName )

	foreach ( map in mapHistory )
	{
		if ( !MapIsValidForPersistence( map ) )
			continue

		local mapID = PersistenceGetEnumIndexForItemName( "maps", map )

		if ( IsValidPersistentMapID( mapID ) )
			mapIDHistory.append( mapID )
	}

	SetPersistentArray( player, "mapHistory", mapIDHistory )
}

// Add a played mode to a player's persistent mode history
function UpdatePlayerModeHistory( player, playedModeName )
{
	local modeHistory = GetPlayerModeHistory( player )
	local modeIDHistory = []

	modeHistory.insert( 0, playedModeName )

	foreach ( mode in modeHistory )
	{
		if ( !PersistenceEnumValueIsValid( "gameModes", mode ) )
			continue

		local modeID = PersistenceGetEnumIndexForItemName( "gameModes", mode )

		if ( IsValidPersistentModeID( modeID ) )
			modeIDHistory.append( modeID )
	}

	SetPersistentArray( player, "modeHistory", modeIDHistory )
}

function PrintPlayerMapHistory( player = null )
{
	if ( developer() && player == null )
		player = GetPlayerArray()[0]

	PrintTable( GetPlayerMapHistory( player ) )
}

function PrintPlayerModeHistory( player = null )
{
	if ( developer() && player == null )
		player = GetPlayerArray()[0]

	PrintTable( GetPlayerModeHistory( player ) )
}

function IsValidPersistentMapID( mapID )
{
	local enumCount = PersistenceGetEnumCount( "maps" )

	// -1 acts as null, 0 and 1 are test maps
	if ( mapID < 2 || mapID >= enumCount )
		return false

	return true
}

function IsValidPersistentModeID( modeID )
{
	local enumCount = PersistenceGetEnumCount( "gameModes" )

	// -1 acts as null
	if ( modeID < 0 || modeID >= enumCount )
		return false

	return true
}