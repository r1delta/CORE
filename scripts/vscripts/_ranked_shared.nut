const DEFAULT_SILENT_MODE = 0
const PROMO_WIN = 1
const PROMO_CONT = 0
const PROMO_LOSE = -1
const RATING_GOALS = 5
const SECRET_SOCIETY_ICON_ALPHA 		= 255

function main()
{
	if ( IsUI() )
		PrecacheRankIcons()

	Globalize( GetContributionMapping )
	Globalize( GetContributionScoreNames )
	Globalize( GetContributionXpTypes )
	Globalize( GetContributionContTypes )
	Globalize( GetRankInviteMode )

	Globalize( ContributionLossForPilotDeath )
	Globalize( GetContributionMappingForGamemode )
	Globalize( PlaylistSupportsRankedPlay )
	Globalize( GameModeSupportsRankedPlay )
	Globalize( GetPlayerRank )
	Globalize( GetPlayerOldRank )
	Globalize( GetPlayerDivision )
	Globalize( GetPlayerTier )
	Globalize( GetNextRank )
	Globalize( GetPreviousRank )
	Globalize( GetPlayerGemScore )
	Globalize( GetPlayerGemState )
	Globalize( GetPlayerTotalCompletedGems )
	Globalize( GetPreviousPlayerTotalCompletedGems )
	Globalize( GetPlayerSponsorshipsRemaining )
	Globalize( PlayerQualifiedForRanked )
	Globalize( PlayerAcceptedRankInvite )
	Globalize( GetRankImage )
	Globalize( GetPlayerTimeTillNextGemDecay )
	Globalize( GetRankedDecayRate )
	Globalize( GetPlayerGemDecayTime )
	Globalize( GetRankedSeason )
	Globalize( GetCurrentSeasonStartTime )
	Globalize( GetCurrentSeasonEndTime )
	Globalize( MatchSupportsRankedPlay )
	Globalize( TooLateForRanked )
	Globalize( RankedWinLossOnly )
	Globalize( RankedWinLossPercent )
	Globalize( RankedAlwaysLoseGem )
	// Each supported game mode needs to be added here, and needs to be added to the next few functions as well
	level.rankedInitFuncs <- {}
	level.rankedInitFuncs[ ATTRITION ] 				<- null
	level.rankedInitFuncs[ LAST_TITAN_STANDING ] 	<- null
	level.rankedInitFuncs[ TEAM_DEATHMATCH ]	 	<- null
	level.rankedInitFuncs[ PILOT_SKIRMISH ]	 		<- null
	level.rankedInitFuncs[ CAPTURE_POINT ]		 	<- null
	level.rankedInitFuncs[ CAPTURE_THE_FLAG ]	 	<- null
	level.rankedInitFuncs[ MARKED_FOR_DEATH ]	 	<- null
	level.rankedInitFuncs[ MARKED_FOR_DEATH_PRO ]	<- null

	IncludeFile( "_ranked_gems" )

	RegisterSignal( "NewPerformanceUpdate" )

	if ( IsUI() || IsClient() )
	{
		level.currentPerformance <- 0
	}

	if ( IsUI() )
	{
		RegisterSignal( "CompletedProgressTally" )
		RegisterSignal( "CapturedGem" )
		GEM_DIST <- 0.30
	}
	else
	{
		GEM_DIST <- 0.32
		level.rankedPlayEnabled <- MatchSupportsRankedPlay()
		if ( level.rankedPlayEnabled )
			file.rankedMapping <- InitContributionMappingForGameMode( GAMETYPE )

		if ( IsServer() )
		{
			IncludeFile( "mp/_ranked" )
			IncludeFile( "mp/_ranked_gamemodes" )

		}

		else
		{
			Globalize( GetContributionHint )
			if ( level.rankedPlayEnabled )
			{
				IncludeFile( "client/cl_ranked" )
			}
		}
	}
}

if ( IsUI() )
{
	function PrecacheRankIcons()
	{
		for ( local i = 0; i <= 24; i++ )
			PrecacheHUDMaterial( GetRankImage( i ) )

		PrecacheHUDMaterial( "../ui/menu/rank_menus/ranked_game_icon_next" )
		PrecacheHUDMaterial( "../ui/menu/rank_menus/ranked_game_icon_damaged" )
		PrecacheHUDMaterial( "../ui/menu/rank_menus/ranked_game_icon_success" )
		PrecacheHUDMaterial( "../ui/menu/rank_menus/ranked_game_icon_lost" )
	}
	Globalize( PrecacheRankIcons )

	function GameModeAssaultDefenseDescription( gameMode )
	{
		// this returns the string for gamemodes that care about player "score", ie assault/defense points
		switch ( gameMode )
		{
			default:
				Assert( 0, "No descriptive string for gamemode " + gamemode )
		}
	}
	Globalize( GameModeAssaultDefenseDescription )

	function GameModeAssaultDescription( gameMode )
	{
		// this returns the string for gamemodes that care about player "score", ie assault/defense points
		switch ( gameMode )
		{
			case ATTRITION:
				return "#RANKED_POINT_DESC_ATTR_POINTS"
			case CAPTURE_POINT:
				return "#RANKED_POINT_DESC_ASSAULT_POINTS"
			case COOPERATIVE:
				return "#RANKED_POINT_DESC_COOP_POINTS"
			default:
				Assert( 0, "No descriptive string for gamemode " + gamemode )
		}
	}
	Globalize( GameModeAssaultDescription )

	function GameModeDefenseDescription( gameMode )
	{
		// this returns the string for gamemodes that care about player "score", ie assault/defense points
		switch ( gameMode )
		{
			case CAPTURE_POINT:
				return "#RANKED_POINT_DESC_DEFENSE_POINTS"
			default:
				Assert( 0, "No descriptive string for gamemode " + gamemode )
		}
	}
	Globalize( GameModeDefenseDescription )

}

function GetContributionMappingForGamemode( gamemode )
{
	return InitContributionMappingForGameMode( gamemode )
}

function GetContributionMapping()
{
	return file.rankedMapping.mapping
}

function GetContributionScoreNames()
{
	return file.rankedMapping.scoreNames
}

function GetContributionXpTypes()
{
	return file.rankedMapping.xpTypes
}

function GetContributionContTypes()
{
	return file.rankedMapping.contTypes
}

if ( IsClient() )
{
	// only client has this function
	function GetContributionHint()
	{
		return file.rankedMapping.introHint
	}
}

function InitContributionMappingForGameMode( gamemode )
{
	local table = CreateContributionMappingForGamemode( gamemode )
	if ( !( "mapping" in table ) )
		table.mapping <- []
	if ( !( "xpTypes" in table ) )
		table.xpTypes <- {}
	if ( !( "scoreNames" in table ) )
		table.scoreNames <- {}

	table.contTypes <- {}
	foreach ( contType in table.mapping )
	{
		table.contTypes[ contType ] <- true
	}

	Assert( ScoreEventsAreInMapping( table ) )

	if ( IsClient() )
		table.introHint <- AssignHintMessageForMapping( table )


	// print the table for debugging


	return table
}

function ScoreEventsAreInMapping( table )
{
	local hasMapping = {}
	foreach ( contType in table.mapping )
	{
		hasMapping[ contType ] <- true
	}

	foreach ( scoreEvent, contType in table.scoreNames )
	{
		Assert( contType in hasMapping, "Missing contType " + contType + " for " + scoreEvent )
	}

	return true
}

function AssignHintMessageForMapping( table )
{
	if ( "AttritionPoints" in table.scoreNames )
		return "#RANKED_ANNOUNCE_ATTRITION"

	local hasMapping = {}
	foreach ( contType in table.mapping )
	{
		hasMapping[ contType ] <- true
	}

	if ( eRankedContributionType.ASSAULT in hasMapping && eRankedContributionType.DEFENSE in hasMapping )
		return "#RANKED_ANNOUNCE_ASSAULT_DEFENSE"

	if ( eRankedContributionType.DAMAGED_TITAN in hasMapping )
		return "#RANKED_ANNOUNCE_TITAN_DAMAGE"

	if ( XP_TYPE.PILOT_KILL in table.xpTypes && XP_TYPE.PILOT_ASSIST in table.xpTypes )
	{
		if ( table.scoreNames.len() == 0 )
			return "#RANKED_ANNOUNCE_PILOT_KILLS_ASSISTS"

		if ( "MarkedTargetKilled" in table.scoreNames )
			return "#RANKED_ANNOUNCE_MFD"

		if ( "FlagCapture" in table.scoreNames )
			return "#RANKED_ANNOUNCE_CTF"

		return "#RANKED_ANNOUNCE_GAMEMODE_AND_KILLS"
	}

	return "GAME MODE NEEDS MAPPING STRING!"
}

function RankedWinLossOnly( gamemode )
{
	switch ( gamemode )
	{
		case CAPTURE_THE_FLAG:
			if ( GetCurrentPlaylistVar( "ranked_ctf_winloss" ) == "on" )
				return true

			return false

		case CAPTURE_POINT:
			if ( GetCurrentPlaylistVar( "ranked_cp_winloss" ) == "on" )
				return true

			return false
	}

	return false
}

function RankedWinLossPercent( gamemode )
{
	if ( IsUI() && !IsFullyConnected() )
		return 0.0

	switch ( gamemode )
	{
		case CAPTURE_THE_FLAG:
			return GetCurrentPlaylistVarFloat( "ranked_wlpct_ctf", 0.15 )

		case CAPTURE_POINT:
			return GetCurrentPlaylistVarFloat( "ranked_wlpct_cp", 0.15 )

		case TEAM_DEATHMATCH:
		case PILOT_SKIRMISH:
			return GetCurrentPlaylistVarFloat( "ranked_wlpct_ps", 0.05 )

		case ATTRITION:
			return GetCurrentPlaylistVarFloat( "ranked_wlpct_at", 0.05 )

		case LAST_TITAN_STANDING:
			return GetCurrentPlaylistVarFloat( "ranked_wlpct_lts", 0.15 )

		case MARKED_FOR_DEATH:
		case MARKED_FOR_DEATH_PRO:
			return GetCurrentPlaylistVarFloat( "ranked_wlpct_mfd", 0.10 )

		default:
			return GetCurrentPlaylistVarFloat( "ranked_wlpct_def", 0.10 )
	}

	return 0.0
}

function CreateContributionMappingForGamemode( gamemode )
{
	if ( RankedWinLossOnly( gamemode ) )
		return {}

	switch ( gamemode )
	{
		case ATTRITION:
			return {
				mapping =
				[
					eRankedContributionType.ASSAULT 			// from GetAssaultScore()
					eRankedContributionType.LOSS_PILOT_DEATH	// manually credited in _ranked_gamemodes
				]

				scoreNames =
				{
					AttritionPoints 	= eRankedContributionType.ASSAULT
				}
			}

		case LAST_TITAN_STANDING:
			return {
				mapping =
				[
					eRankedContributionType.DAMAGED_TITAN 		// scored automatically by _ranked
					eRankedContributionType.LTS_PILOT_KILL		// scored manually in _ranked_gamemodes
				]
			}

		case TEAM_DEATHMATCH:
		case PILOT_SKIRMISH:

			local table = {
				mapping =
				[
					eRankedContributionType.TDM_PILOT_KILLS		// from xpTypes mapping
					eRankedContributionType.TDM_PILOT_ASSISTS	// from xpTypes mapping
					eRankedContributionType.LOSS_PILOT_DEATH	// manually credited in _ranked_gamemodes
				]

				xpTypes = {}
			}

			if ( !IsLobby() )
			{
				// lobby doesn't know about xp types and doesn't need to, yet
				// Leagues_OnScoreEvent adds ranked points for these events
				table.xpTypes[ XP_TYPE.PILOT_KILL ] 	<- eRankedContributionType.TDM_PILOT_KILLS
				table.xpTypes[ XP_TYPE.PILOT_ASSIST ] 	<- eRankedContributionType.TDM_PILOT_ASSISTS
			}

			return table

		case CAPTURE_POINT:
			local table =
			{
				mapping =
				[
					eRankedContributionType.ASSAULT 	// from GetAssaultScore()
					eRankedContributionType.DEFENSE 	// from GetDefenseScore()
					eRankedContributionType.LOSS_PILOT_DEATH	// manually credited in _ranked_gamemodes
					eRankedContributionType.TDM_PILOT_KILLS		// from xpTypes mapping
					eRankedContributionType.TDM_PILOT_ASSISTS	// from xpTypes mapping
				]
			}

			if ( !IsLobby() )
			{
				// lobby doesn't know about xp types and doesn't need to, yet
				table.xpTypes <- {}

				// Leagues_OnScoreEvent adds ranked points for these events
				table.xpTypes[ XP_TYPE.PILOT_KILL ] 	<- eRankedContributionType.TDM_PILOT_KILLS
				table.xpTypes[ XP_TYPE.PILOT_ASSIST ] 	<- eRankedContributionType.TDM_PILOT_ASSISTS
			}

			return table

		case CAPTURE_THE_FLAG:
			local table = {
				mapping =
				[
					eRankedContributionType.CTF_FLAG_CAPTURES 			// from score name mapping
					eRankedContributionType.CTF_FLAG_ASSISTS			// from score name mapping
					eRankedContributionType.CTF_FLAG_CARRIER_KILLS		// from score name mapping
					eRankedContributionType.CTF_FLAG_RETURNS			// from score name mapping

					eRankedContributionType.TDM_PILOT_KILLS		// from xpTypes mapping
					eRankedContributionType.TDM_PILOT_ASSISTS	// from xpTypes mapping
					eRankedContributionType.LOSS_PILOT_DEATH	// manually credited in _ranked_gamemodes
				]

				// Leagues_OnScoreEvent adds ranked points for these events
				scoreNames =
				{
					FlagCapture 		= eRankedContributionType.CTF_FLAG_CAPTURES
					FlagReturn 			= eRankedContributionType.CTF_FLAG_RETURNS
					FlagCarrierKill 	= eRankedContributionType.CTF_FLAG_CARRIER_KILLS
					FlagCaptureAssist 	= eRankedContributionType.CTF_FLAG_ASSISTS
				}
			}

			if ( !IsLobby() )
			{
				// lobby doesn't know about xp types and doesn't need to, yet
				table.xpTypes <- {}

				// Leagues_OnScoreEvent adds ranked points for these events
				table.xpTypes[ XP_TYPE.PILOT_KILL ] 	<- eRankedContributionType.TDM_PILOT_KILLS
				table.xpTypes[ XP_TYPE.PILOT_ASSIST ] 	<- eRankedContributionType.TDM_PILOT_ASSISTS
			}

			return table


		case MARKED_FOR_DEATH_PRO:
		case MARKED_FOR_DEATH:

			local table = {
				mapping =
				[
					//eRankedContributionType.MarkedSurvival					// from score name mapping
					eRankedContributionType.MarkedKilledMarked				// from score name mapping
					eRankedContributionType.MarkedOutlastedEnemyMarked		// from score name mapping
					eRankedContributionType.MarkedTargetKilled				// from score name mapping
					eRankedContributionType.MarkedEscort					// from score name mapping

					eRankedContributionType.TDM_PILOT_KILLS		// from xpTypes mapping
					eRankedContributionType.TDM_PILOT_ASSISTS	// from xpTypes mapping
					eRankedContributionType.LOSS_PILOT_DEATH	// manually credited in _ranked_gamemodes
				]

				// Leagues_OnScoreEvent adds ranked points for these events
				scoreNames =
				{
					//MarkedSurvival 				= eRankedContributionType.MarkedSurvival
					MarkedKilledMarked 			= eRankedContributionType.MarkedKilledMarked
					MarkedOutlastedEnemyMarked 	= eRankedContributionType.MarkedOutlastedEnemyMarked
					MarkedTargetKilled 			= eRankedContributionType.MarkedTargetKilled
					MarkedEscort				= eRankedContributionType.MarkedEscort
				}
			}

			if ( !IsLobby() )
			{
				// lobby doesn't know about xp types and doesn't need to, yet
				table.xpTypes <- {}

				// Leagues_OnScoreEvent adds ranked points for these events
				table.xpTypes[ XP_TYPE.PILOT_KILL ] 	<- eRankedContributionType.TDM_PILOT_KILLS
				table.xpTypes[ XP_TYPE.PILOT_ASSIST ] 	<- eRankedContributionType.TDM_PILOT_ASSISTS
			}

			return table

		default:
			Assert( 0, "Unhandled gamemode " + gamemode )
	}
}

function GetPlayerRank( player = null )
{
	if ( IsUI() )
		return GetGemsToRank( GetPlayerTotalCompletedGems() )

	return player.GetRank()
}

function GetPlayerOldRank( player = null )
{
	Assert ( IsUI() || IsServer() || ( IsClient() && IsLocalClientPlayer( player ) ) )

	local previousGemCount
	if ( IsUI() )
	{
		if ( !IsFullyConnected() )
			return 0

		previousGemCount = GetPersistentVar( "ranked.previousGemCount" )
	}
	else
		previousGemCount = player.GetPersistentVar( "ranked.previousGemCount" )

	return GetGemsToRank( previousGemCount )
}

function GetPlayerDivision( player= null )
{
	local rank = GetPlayerRank()
	return (rank / 5).tointeger()
}

function GetPlayerTier( player= null )
{
	local rank = GetPlayerRank()
	return (rank % 5).tointeger()
}

function GetNextRank( currentRank )
{
	return currentRank == MAX_RANK ? MAX_RANK : currentRank + 1
}

function GetPreviousRank( currentRank )
{
	return currentRank == 0 ? 0 : currentRank - 1
}

function GetRankImage( rank )
{
	rank = clamp( rank, 0, MAX_RANK )

	local rankColor = 1
	local rankTier = ( rank % 5 ) + 1

	if ( rank < 5 )
		rankColor = 1
	else if ( rank < 10 )
		rankColor = 2
	else if ( rank < 15 )
		rankColor = 3
	else if ( rank < 20 )
		rankColor = 4
	else
		rankColor = 5

	return "../ui/menu/rank_icons/tier_" + rankColor + "_" + rankTier
}

if ( IsUI() )
{
	function PlaylistSupportsRankedPlay()
	{
		if ( GetLobbyTypeScript() == eLobbyType.SOLO )
			return true

		return GetCurrentPlaylistVarInt( "ranking_supported", 0 )
	}

	function GameModeSupportsRankedPlay()
	{
		if ( GetLobbyTypeScript() == eLobbyType.SOLO )
			return true

		if ( level.ui.nextMapModeComboIndex == null )
			return true

		local modeName = GetCurrentPlaylistGamemodeByIndex( level.ui.nextMapModeComboIndex )
		if ( !PersistenceEnumValueIsValid( "gameModes", modeName ) )
			return false

		return modeName in level.rankedInitFuncs
	}
}
else
{
	function PlaylistSupportsRankedPlay()
	{
		if ( IsMenuLevel() )
			return false

		if ( IsPrivateMatch() && !IsDelta() )
			return false

		if ( !GetCurrentPlaylistVarInt( "ranking_supported", 0 ) )
			return false

		return true
	}

	function GameModeSupportsRankedPlay()
	{
//		if ( !PersistenceEnumValueIsValid( "gameModes", GAMETYPE ) )
//			return false

		return GAMETYPE in level.rankedInitFuncs
	}
}

function GetPlayerGemState( player, index, usePreviousData = false )
{
	if ( IsUI() )
	{
		if ( !IsFullyConnected() )
			return "gem_undefeated"
	}

	if ( usePreviousData )
	{
		local previousSize = PersistenceGetArrayCount( "ranked.previousGems" )
		local previousGemCount = IsUI() ? GetPersistentVar( "ranked.previousGemCount" ) : player.GetPersistentVar( "ranked.previousGemCount" )
		if ( index >= previousGemCount - 1 && index < previousGemCount + previousSize - 1 )
		{
			local previousGemsIndex = index - previousGemCount + 1
			local var = "ranked.previousGems[" + previousGemsIndex + "].gemState"

			if ( IsUI() )
				return GetPersistentVar( var )
			else
				return player.GetPersistentVar( var )
		}

//		return "gem_captured"
	}

	if ( IsUI() )
		return GetPersistentVar( "ranked.gems" + "[" + index + "].gemState" )
	return player.GetPersistentVar( "ranked.gems" + "[" + index + "].gemState" )
}

function GetPlayerGemScore( player, index, usePreviousData = false )
{
	if ( IsUI() )
	{
		if ( !IsFullyConnected() )
			return 0.0
	}

	if ( usePreviousData )
	{
		local previousSize = PersistenceGetArrayCount( "ranked.previousGems" )
		local previousGemCount = IsUI() ? GetPersistentVar( "ranked.previousGemCount" ) : player.GetPersistentVar( "ranked.previousGemCount" )
		if ( index >= previousGemCount - 1 && index < previousGemCount + previousSize - 1 )
		{
			local previousGemsIndex = index - previousGemCount + 1
			local var = "ranked.previousGems[" + previousGemsIndex + "].gemScore"
			if ( IsUI() )
				return GetPersistentVar( var )
			else
				return player.GetPersistentVar( var )
		}
	}

	if ( IsUI() )
		return GetPersistentVar( "ranked.gems" + "[" + index + "].gemScore" )

	return player.GetPersistentVar( "ranked.gems" + "[" + index + "].gemScore" )
}

function GetPlayerTotalCompletedGems( player = null )
{
	local count = 0
	local max = GetMaxGems()
	for ( local i = 0 ; i < max ; i++ )
	{
		local gemState = GetPlayerGemState( player, i )

		switch ( gemState )
		{
			case "gem_captured":
			case "gem_damaged":
				count++
				break
		}
	}

	return count
}

function GetPreviousPlayerTotalCompletedGems( player = null )
{
	local count = 0
	local max = GetMaxGems()
	for ( local i = 0 ; i < max ; i++ )
	{
		local gemState = GetPlayerGemState( player, i, true )

		switch ( gemState )
		{
			case "gem_captured":
			case "gem_damaged":
				count++
				break
		}
	}

	return count
}



function GetPlayerSponsorshipsRemaining( player = null )
{
	if ( IsUI() )
	{
		if ( !IsFullyConnected() )
			return 0

		return GetPersistentVar( "ranked.sponsorshipsRemaining" )
	}

	return player.GetPersistentVar( "ranked.sponsorshipsRemaining" )
}

function PlayerAcceptedRankInvite( player = null )
{
	if ( IsUI() )
	{
		if ( !IsFullyConnected() )
			return false

		return GetPersistentVar( "ranked.joinedRankedPlay" )
	}
	else
	{
		return player.GetPersistentVar( "ranked.joinedRankedPlay" )
	}

	return false
}

function PlayerQualifiedForRanked( player = null )
{
	// return true

	if ( IsUI() )
	{
		// gen 10 players get one invite
		if ( GetGen() >= MAX_GEN )
			return true

		if ( GetRankInviteMode() == "none" )
			return GetGen() > 0 || GetLevel() >= 32

		if ( !IsFullyConnected() )
			return false

		if ( GetPersistentVar( "ranked.joinedRankedPlay" ) )
			return true
		return GetPersistentVar( "ranked.mySponsorName" ) != ""
	}

	// gen 10 players get one invite
	if ( player.GetGen() >= MAX_GEN )
		return true

	if ( GetRankInviteMode() == "none" )
		return player.GetGen() > 0 || GetLevel( player ) >= 32

	if ( player.GetPersistentVar( "ranked.joinedRankedPlay" ) )
		return true
	return player.GetPersistentVar( "ranked.mySponsorName" ) != ""
}

function GetPlayerTimeTillNextGemDecay( player = null, currentTime = null )
{
	local nextGemDecayTime = GetPlayerGemDecayTime( player )
	if ( currentTime == null )
		currentTime = Daily_GetCurrentTime()
	return nextGemDecayTime - currentTime
}

function GetRankedDecayRate()
{
	// amount of time before gem decays
	return GetCurrentPlaylistVarFloat( "ranked_decay_days", 1.0 ) * SECONDS_PER_DAY
}

function GetPlayerGemDecayTime( player = null )
{
	// amount of time until this player gets gem decay
	if ( IsUI() && !IsFullyConnected() )
		return 0

	local savedTime = IsUI() ? GetPersistentVar( "ranked.nextGemDecayTime" ) : player.GetPersistentVar( "ranked.nextGemDecayTime" )
	local currentTime = Daily_GetCurrentTime()
	if ( savedTime == 0 )
		savedTime = currentTime + (GetRankedDecayRate())
	return savedTime
}

function GetRankedSeason( unixTime = null )
{
	local timeParts = GetUnixTimeParts( unixTime )
	local yearsElapsed = timeParts["year"] - 1970
	local monthsElapsed = ( yearsElapsed * 12 ) + timeParts["month"] - RANKED_SEASON_OFFSET
	local numDaysPerSeason = ( 28 / RANKED_SEASONS_PER_MONTH ).tointeger()
	local numSeasonsElapsedThisMonth = min( timeParts["day"] / numDaysPerSeason, RANKED_SEASONS_PER_MONTH - 1 )
	local seasonsElapsed = (monthsElapsed * RANKED_SEASONS_PER_MONTH) + numSeasonsElapsedThisMonth

	return seasonsElapsed
}

function GetCurrentSeasonEndTime()
{
	local unixTimeNow = Daily_GetCurrentTime()
	local timePartsNow = GetUnixTimeParts( unixTimeNow )
	local currentSeason = GetRankedSeason( unixTimeNow )

	// Add days until we roll over to the next month
	local unixTimeNextSeason = unixTimeNow
	local nextSeason = currentSeason
	while( nextSeason == currentSeason )
	{
		unixTimeNextSeason += SECONDS_PER_DAY
		nextSeason = GetRankedSeason( unixTimeNextSeason )
	}

	// Subtract time we went over to the next month
	unixTimeNextSeason -= (timePartsNow["hour"] * SECONDS_PER_HOUR) + (timePartsNow["minute"] * SECONDS_PER_MINUTE) + timePartsNow["second"]

	return unixTimeNextSeason
}

function GetCurrentSeasonStartTime()
{
	local unixTimeNow = Daily_GetCurrentTime()
	local timePartsNow = GetUnixTimeParts( unixTimeNow )
	local currentSeason = GetRankedSeason( unixTimeNow )

	// Go back days until we find the previous season
	local unixTimePreviousSeason = unixTimeNow
	local previousSeason = currentSeason
	while( previousSeason == currentSeason )
	{
		unixTimePreviousSeason -= SECONDS_PER_DAY
		previousSeason = GetRankedSeason( unixTimePreviousSeason )
	}

	// Subtract time left in the day, then add 1 day for when the season first started
	unixTimePreviousSeason -= (timePartsNow["hour"] * SECONDS_PER_HOUR) + (timePartsNow["minute"] * SECONDS_PER_MINUTE) + timePartsNow["second"]
	unixTimePreviousSeason += SECONDS_PER_DAY

	return unixTimePreviousSeason
}




function ContributionLossForPilotDeath()
{
	return eRankedContributionType.LOSS_PILOT_DEATH in GetContributionContTypes()
}


function InitRankedPanelElems( elemGroup, rankedPanel, hudGroup = null )
{
	elemGroup.paused <- false
	elemGroup.RankedGoals <- []

	if ( IsClient() )
	{
		elemGroup.RankedBG								<- hudGroup.CreateElement( "RankedBG", rankedPanel )
		elemGroup.RankedLogo 							<- hudGroup.CreateElement( "RankedLogo", rankedPanel )
		elemGroup.RankedGoal_NoNumbersProgressBar 		<- hudGroup.CreateElement( "RankedGoal_NoNumbersProgressBar", rankedPanel )

		for ( local i = 0; i < RATING_GOALS; i++ )
		{
			elemGroup.RankedGoals.append( hudGroup.CreateElement( "RankedGoal_Gem" + i, rankedPanel ) )
		}
	}
	else
	{
		elemGroup.RankedBG								<- rankedPanel.GetChild( "RankedBG" )
		elemGroup.RankedLogo 							<- rankedPanel.GetChild( "RankedLogo" )
		elemGroup.RankedGoal_NoNumbersProgressBar 		<- rankedPanel.GetChild( "RankedGoal_NoNumbersProgressBar" )

		for ( local i = 0; i < RATING_GOALS; i++ )
		{
			elemGroup.RankedGoals.append( rankedPanel.GetChild( "RankedGoal_Gem" + i ) )
		}
	}

	elemGroup.RankedBG.SetAlpha( 0 )
	elemGroup.RankedBG.ClearPulsate()

	if ( !( "GameInfo_Icon" in elemGroup ) )
		elemGroup.GameInfo_Icon <- null

	elemGroup.outElem <- elemGroup.RankedLogo
	elemGroup.inElem <- elemGroup.GameInfo_Icon

	elemGroup.RankedGoal_NoNumbersProgressBar.SetColor( RANKED_SPLASH_COLORS_MAIN )
}
Globalize( InitRankedPanelElems )

function UpdateProgressBarsOverTime( elemGroup, menuOrCockpit = null, forceJumpToCurrentState = false )
{
	local jumpToCurrentState

	if ( IsUI() )
	{
		EndSignal( menuOrCockpit, "StopMenuAnimation" )
		jumpToCurrentState = forceJumpToCurrentState

		OnThreadEnd(
			function() : (  )
			{
				StopUISound( "UI_RankedSummary_BattleMark_Blinking" )
				StopUISound( "UI_RankedSummary_CircleFill" )
			}
		)
	}
	else
	{
		jumpToCurrentState = true

		if ( menuOrCockpit )
			menuOrCockpit.EndSignal( "OnDestroy" )
	}

	elemGroup.RankedGoal_NoNumbersProgressBar.SetBarProgressRemap( 0, 1.0, 0.0, 1.0 )
		//if ( level.performanceGoals.top() < 100.0 )
		//	goals.append( 100.0 )

	local e = {}
	e.lastFrame <- { perf = 0.01, goalIndex = 0 }
	e.nextFrame <- { perf = 0, goalIndex = 0 }

	local width = elemGroup.RankedBG.GetWidth()

	if ( jumpToCurrentState )
	{
		local goalIndex = GetGoalIndexFromScore( level.currentPerformance )
		local nextPerf = GetGoalPerf( level.currentPerformance, goalIndex )
		e.lastFrame <- { perf = nextPerf, goalIndex = goalIndex }
		e.nextFrame <- { perf = nextPerf, goalIndex = goalIndex }
		elemGroup.RankedGoal_NoNumbersProgressBar.SetBarProgress( nextPerf )
		if ( nextPerf == 1.0 )
			goalIndex++
		GemTransition( elemGroup, goalIndex, 0 )
		if ( IsUI() )
			GemWonText( goalIndex - 1 )
	}
	else
	{
		e.lastFrame <- { perf = 0.01, goalIndex = 0 }
		e.nextFrame <- { perf = 0, goalIndex = 0 }
		GemTransition( elemGroup, 0, 0 )
	}

	for ( ;; )
	{
		if ( !TransitionProgressBar( e, elemGroup, width ) )
		{
			if ( IsUI() && !elemGroup.paused )
			{
				Signal( level, "CompletedProgressTally" )
				return
			}

			WaitSignal( level, "NewPerformanceUpdate" )
		}
	}
}
Globalize( UpdateProgressBarsOverTime )

function TransitionProgressBar( e, elemGroup, width )
{
	if ( elemGroup.paused )
		return false

	if ( FillNextFrame( e ) )
	{
		TransitionFrames( e, elemGroup, width )
		//printt( " " )
		//printt( "From " + e.lastFrame.goalIndex + ": " + e.lastFrame.perf + " to " + e.nextFrame.goalIndex + ": " + e.nextFrame.perf )
		e.lastFrame = clone e.nextFrame
		return true
	}
	return false
}

function GetLowerGoal( goalIndex )
{
	local lastGoal
	if ( goalIndex > 0 )
		return level.performanceGoals[ goalIndex - 1 ]
	return 0
}

function GetGoalPerf( performance, nextGoalIndex )
{
	return GraphCapped( performance, GetLowerGoal( nextGoalIndex ), level.performanceGoals[ nextGoalIndex ], 0, 1.0 )
}

function FillNextFrame( e )
{
	local prevPerf = e.lastFrame.perf
	local prevGoalIndex = e.lastFrame.goalIndex

	local performance = level.currentPerformance
	local nextGoalIndex = GetGoalIndexFromScore( performance )

	// moving within one goal
	if ( nextGoalIndex == prevGoalIndex )
	{
		local nextPerf = GetGoalPerf( performance, nextGoalIndex )

		// hasn't changed, need new destination
		if ( nextPerf == e.lastFrame.perf )
			return false

		e.nextFrame.perf = nextPerf
		e.nextFrame.goalIndex = nextGoalIndex
		return true
	}

	// rising to a higher goal
	if ( nextGoalIndex > prevGoalIndex )
	{
		// can't go up more than one goal per transition
		nextGoalIndex = min( nextGoalIndex, prevGoalIndex + 1 )

		if ( e.lastFrame.perf == 1.0 )
		{
			// already full? then move to next goal
			local goal = level.performanceGoals[ nextGoalIndex ]
			e.lastFrame.goalIndex = nextGoalIndex
			e.lastFrame.perf = 0.0
			e.nextFrame.goalIndex = nextGoalIndex
			e.nextFrame.perf = GetGoalPerf( level.performanceGoals[ prevGoalIndex ], nextGoalIndex )
		}
		else
		{
			// fill it up
			e.nextFrame.perf = 1.0
			e.nextFrame.goalIndex = prevGoalIndex
		}

		return true
	}

	// falling to a lower goal

	// can't fall more than one goal per transition
	nextGoalIndex = max( nextGoalIndex, prevGoalIndex - 1 )

	local lowerGoal = level.performanceGoals[ nextGoalIndex ]
	local higherGoal = level.performanceGoals[ prevGoalIndex ]
	local lowerPerf = GetGoalPerf( lowerGoal, prevGoalIndex )

	if ( prevPerf > lowerPerf )
	{
		// we're within a goal and falling to the next lower, so first, drop to the lower goal line
		e.nextFrame.goalIndex = prevGoalIndex
		e.nextFrame.perf = lowerPerf
		return true
	}

	// fall from 1.0
	e.lastFrame.goalIndex = nextGoalIndex
	e.lastFrame.perf = 1.0

	performance = GetGoalPerf( performance, nextGoalIndex )
	e.nextFrame.goalIndex = nextGoalIndex
	e.nextFrame.perf = max( performance, lowerPerf )

	return true
}


function TransitionFrames( e, elemGroup, width )
{
	//return
	local perfDif = fabs( e.nextFrame.perf - e.lastFrame.perf )
	if ( perfDif == 0.0 )
		return

	local time
	if ( IsUI() )
	{
		EmitUISound( "UI_RankedSummary_CircleFill" )
		time = GraphCapped( perfDif, 0, 1.0, 0.25, 0.8 )
	}
	else
	{
		// transition slowly if the player hasn't done anything lately
		if ( e.nextFrame.perf != 1.0 && e.lastFrame.perf != 1.0 && Time() - level.lastRankScoreSplash > RANKED_RECALC_TIMESLICE )
			time = RANKED_RECALC_TIMESLICE
		else
			time = GraphCapped( perfDif, 0, 1.0, 0.2, 0.7 )
	}

	if ( e.lastFrame.perf == 1.0 )
	{
		// coming from 1.0
		GemTransition( elemGroup, e.nextFrame.goalIndex, 0 )
		// lost a gem
		EmitSoundOnEntity( GetLocalClientPlayer(), "UI_InGame_League_BelowGoal" )
	}

	// transition the bar
	Assert( e.lastFrame.perf >= 0 && e.lastFrame.perf <= 1.0 )
	Assert( e.nextFrame.perf >= 0 && e.nextFrame.perf <= 1.0 )
	elemGroup.RankedGoal_NoNumbersProgressBar.SetBarProgressOverTime( e.lastFrame.perf, e.nextFrame.perf, time )
	wait time

	if ( IsUI() )
			StopUISound( "UI_RankedSummary_CircleFill" )

	if ( e.nextFrame.perf == 1.0 )
	{
		// gained a gem
		if ( IsUI() )
		{
			EmitUISound( "UI_RankedSummary_CircleTick_Reached" )
			EmitUISound( "UI_RankedSummary_BattleMark_Blinking" )
		}
		else
		{
			EmitSoundOnEntity( GetLocalClientPlayer(), "UI_InGame_League_AboveGoal" )
		}

		if ( IsUI() )
			Signal( level, "CapturedGem" )

		GemTransition( elemGroup, e.nextFrame.goalIndex + 1 )

		elemGroup.RankedBG.SetPulsate( 0.25, 1.0, 25 )
		elemGroup.RankedBG.SetColor( 255, 255, 255, 150 )

		wait 0.3

		if ( IsUI() )
		{
			EmitUISound( "UI_RankedSummary_BattleMark_Blinking" )
			EmitUISound( "UI_RankedSummary_BattleMark_Locked" )

			wait 0.3
		}

		elemGroup.RankedBG.ClearPulsate()
		FadeBGToBlack( elemGroup )
	}
}

function BlendInCurrentLogo( elemGroup )
{
	if ( !elemGroup.GameInfo_Icon )
		return
	elemGroup.inElem.FadeOverTime( SECRET_SOCIETY_ICON_ALPHA, 0.4 )
	elemGroup.outElem.FadeOverTime( 0, 0.4 )
}
Globalize( BlendInCurrentLogo )

function GemTransition( elemGroup, completedCount, time = 0.3 )
{
	local count = level.performanceGoals.len()
	BlendInCurrentLogo( elemGroup )

	local dist = elemGroup.RankedBG.GetWidth() * GEM_DIST
	local range = 30
	local offset = count * 0.5 - 0.5

	for ( local index = 0; index < count; index++ )
	{
		local elem = elemGroup.RankedGoals[ index ]
		local x, y
		local degree = offset * -range + index * range
		degree -= 90

		x = deg_cos( degree ) * dist
		y = deg_sin( degree ) * dist

		degree = 270 - degree

		elem.SetRotation( degree )
		elem.Show()
		elem.SetAlpha( 255 )

		if ( index < completedCount )
		{
			elem.SetImage( "hud/ranked_goal_tiny_filled" )
			elem.SetColor( 255, 255, 255, 255 )
		}
		else
		{
			elem.SetImage( "hud/ranked_goal_tiny_empty" )
			elem.SetColor( 50, 76, 82, 255 )
		}

		if ( index == completedCount - 1 && time > 0 )
		{
			elem.SetScale( 6.5, 6.5 )
			elem.ScaleOverTime( 1.0, 1.0, time )
			elem.SetAlpha( 0 )
			elem.FadeOverTime( 255, time )
			elem.SetPos( 0, 0 )
			elem.MoveOverTime( x, y, time )
		}
		else
		{
			elem.SetPos( x, y )
		}
	}

	for ( local i = count; i < RATING_GOALS; i++ )
	{
		elemGroup.RankedGoals[ i ].Hide()
	}
}
Globalize( GemTransition )

function FadeBGToBlack( elemGroup )
{
	elemGroup.RankedBG.FadeOverTime( 0, 0.5 )
}
Globalize( FadeBGToBlack )


function GetGoalIndexFromScore( score )
{
	foreach ( index, goal in level.performanceGoals )
	{
		if ( goal > score )
			return index
	}
	return level.performanceGoals.len() - 1
}
Globalize( GetGoalIndexFromScore )


function MatchSupportsRankedPlay( player = null )
{
	if( IsPrivateMatch() && !IsDelta() )
		return false

	if ( !PlaylistSupportsRankedPlay() )
		return false

	if ( !GameModeSupportsRankedPlay() )
		return false

	return true
}


function TooLateForRanked()
{
	if ( level.nv.matchProgress >= 90 )		// Over 90%? Don't let ranks be late enabled
		return true

	if ( IsRoundBased() ) 				// Last round?
	{
		local lastPlayableRound = GetRoundScoreLimit_FromPlaylist() - 1 	// -1 because the round being played for the win is the one before the limit
		if ( level.nv.roundsPlayed >= lastPlayableRound )
			return true
	}

	return false
}

function GetRankInviteMode()
{
	local var = GetCurrentPlaylistVar( "RankInviteMode" )
	if ( var == "" )
		return "gen10"
	return var
}

function RankedAlwaysLoseGem()
{
	if ( IsUI() && !IsFullyConnected() )
		return true

	local var = GetCurrentPlaylistVar( "ranked_lose_gem" )
	if ( var == "" )
		var = "on"
	return var == "on"
}
