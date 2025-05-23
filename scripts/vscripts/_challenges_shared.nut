
const CHALLENGES_ENABLED = true
const DEBUG_CHALLENGES	= false
const DEBUG_DAILIES	= false

const MAX_CHALLENGE_TIERS = 10
const CHALLENGES_RESET_AT_EACH_STAGE = false

level.challengePopupColorNew <- [ 150, 255, 150 ]
level.challengePopupColorProgress <- [ 255, 255, 255 ]
level.challengePopupColorComplete <- [ 255, 215, 0 ]
level.challengePopupColorInactive <- [ 128, 128, 128 ]

level.challengeData <- {}
level.challengeDataByCategory <- {}
level.challengeCategoryNames <- {}
level.challengeItemForCategory <- {}
level.itemRewardsForChallenge <- {}

lastAddedChallengeRef <- null
lastChallengeCategory <- null

dailyChallengeList <- {}

function main()
{
	level.challengeXPRewardsForTier <- {}
	level.challengeXPRewardsForTier[ 0 ] <- 500
	level.challengeXPRewardsForTier[ 1 ] <- 1000
	level.challengeXPRewardsForTier[ 2 ] <- 2500
	level.challengeXPRewardsForTier[ 3 ] <- 5000
	level.challengeXPRewardsForTier[ 4 ] <- 10000

	level.challengeXPRewardsForTier[ 5 ] <- 10000
	level.challengeXPRewardsForTier[ 6 ] <- 10000
	level.challengeXPRewardsForTier[ 7 ] <- 10000
	level.challengeXPRewardsForTier[ 8 ] <- 10000
	level.challengeXPRewardsForTier[ 9 ] <- 10000

	level.challengeRefsForWeapon <- {}

	Globalize( AddChallenge )
	Globalize( SetChallengeStat )
	Globalize( SetChallengeFlags )
	Globalize( SetChallengeTiers )
	Globalize( SetChallengeCategory )

	Globalize( InitPlayerChallenges )
	Globalize( UpdateChallengeRewardItems )
	Globalize( UI_GetAllChallengesProgress )
	Globalize( UI_GetSpecificChallengeProgress )
	Globalize( UpdateLocalChallengeProgress )
	Globalize( GetLocalChallengeTable )

	Globalize( GetChallengeProgressData )
	Globalize( GetChallengeCategoryName )
	Globalize( GetChallengeCategoryDesc )
	Globalize( GetChallengeCategory )
	Globalize( GetChallengeID )
	Globalize( GetChallengeName )
	Globalize( GetChallengeNameForTier )
	Globalize( GetChallengeDescription )
	Globalize( GetChallengeIcon )
	Globalize( GetChallengeProgressIsDecimal )
	Globalize( GetItemRewardForChallengeTier )
	Globalize( GetCurrentChallengeTier )
	Globalize( GetGoalForChallengeTier )
	Globalize( GetCurrentChallengeGoal )
	Globalize( GetChallengeXPReward )
	Globalize( GetChallengeBurnCardRewards )
	Globalize( GetCurrentChallengeProgress )
	Globalize( GetCurrentChallengeProgressFrac )
	Globalize( GetChallengeProgressFracForTier )
	Globalize( GetChallengeTierCount )
	Globalize( GetChallengeFlags )
	Globalize( GetChallengeRefFromID )
	Globalize( IsChallengeComplete )
	Globalize( IsChallengeTierComplete )
	Globalize( GetNumberRegenChallengesRemaining )
	Globalize( IsRegenRequirement )
	Globalize( IsDailyChallenge )
	Globalize( IsCoopChallenge )
	Globalize( IsActiveDailyChallenge )
	Globalize( GetTodaysDailyChallenges )
	Globalize( GetPlayersStoredDailyChallenges )
	Globalize( GetDailyChallengeDayAssigned )
	Globalize( GetTrackedChallenges )
	Globalize( UntrackChallengeRef )
	Globalize( GetChallengesByCategory )

	Globalize( PutChallengeNameOnLabel )
	Globalize( PutChallengeRewardsOnPanel )
	Globalize( SetChallengeNameTextOnLabel )

	Globalize( GetMatchStartChallengeProgress )
	Globalize( GetChallengeTierForProgress )
	Globalize( SetChallengeTierBurnCards )
	Globalize( GetChallengeEnumNameForRef )
	Globalize( GetChallengeStorageArrayNameForRef )
	Globalize( DebugPrintAllChallenges )
}

function SetChallengeCategory( category, title, desc = "", itemRef = null, linkedCategories = [] )
{
	Assert( category >= 0, "Invalid challenge category specified" )
	Assert( title != null, "Did not specify title for challenge category" )
	Assert( !( category in level.challengeCategoryNames ) )
	Assert( title == "" || title == null || title.find( "#" ) == 0 )
	Assert( desc == "" || desc == null || desc.find( "#" ) == 0 )

	if ( itemRef )
	{
		// should create a function that can check if a given ref is a valid ref (challenge, item, unlockRef, etc...)
		//Assert( ItemDefined( itemRef ) )
	}

	if ( !( category in level.challengeDataByCategory ) )
		level.challengeDataByCategory[ category ] <- {}

	level.challengeCategoryNames[ category ] <- {}
	level.challengeCategoryNames[ category ].title <- title
	level.challengeCategoryNames[ category ].desc <- desc
	level.challengeCategoryNames[ category ].linkedCategories <- linkedCategories

	level.challengeItemForCategory[ category ] <- itemRef

	lastChallengeCategory = category
}

function GetChallengeEnumNameForRef( ref )
{
	if ( PersistenceEnumValueIsValid( "challenge", ref ) )
		return "challenge"
	if ( PersistenceEnumValueIsValid( "dailychallenge", ref ) )
		return "dailychallenge"
	Assert( 0, "Challenge ref is invalid, not in either challenge enum" )
}

function GetChallengeStorageArrayNameForRef( ref )
{
	if ( PersistenceEnumValueIsValid( "challenge", ref ) )
		return "challenges"
	if ( PersistenceEnumValueIsValid( "dailychallenge", ref ) )
		return "dailychallenges"
	Assert( 0, "Challenge ref is invalid, not in either challenge enum" )
}

function AddChallenge( ref, title, desc, icon, weaponRef = null, progressDecimal = false )
{
	//HACK - Persistent data is stored as lower case, so when we use get functions for challengeRef they all return lower case.
	ref = ref.tolower()

	// Make sure a category was set
	Assert( lastChallengeCategory != null )

	// Make sure the previous challenge type had at least 1 challenge set for it
	if ( lastAddedChallengeRef != null )
	{
		Assert( level.challengeData[ lastAddedChallengeRef ].tierGoals.len() > 0, "Challenge added without any tiers set to the previous challenge" )
		Assert( level.challengeData[ lastAddedChallengeRef ].category != null, "Challenge added without a category set to the previous challenge" )
		Assert( level.challengeData[ lastAddedChallengeRef ].linkedStat != null, "Challenge added without a stat link set to the previous challenge" )
	}

	// Make sure this challenge type wasn't already added
	Assert( !( ref in level.challengeData ), "Challenge already exists, can't create it again" )

	// Make sure the data is all valid and legit
	Assert( title != null, "No challenge title specified for challenge" )
	Assert( desc != null, "No challenge description specified for challenge" )

	// Create the challenge type
	level.challengeData[ ref ] <- {}
	level.challengeData[ ref ].title <- title
	level.challengeData[ ref ].desc <- desc
	level.challengeData[ ref ].icon <- icon
	level.challengeData[ ref ].linkedStat <- null
	level.challengeData[ ref ].flags <- ( CF_PRIORITY_NORMAL )
	level.challengeData[ ref ].totalNumToComplete <- 0
	level.challengeData[ ref ].tierGoals <- []
	level.challengeData[ ref ].burnCardRewards <- [ null, null, null, null, null ]
	level.challengeData[ ref ].category <- lastChallengeCategory
	level.challengeData[ ref ].weaponRef <- weaponRef
	level.challengeData[ ref ].weaponRefName <- null
	level.challengeData[ ref ].progressDecimal <- progressDecimal
	level.challengeData[ ref ].addIndex <- level.challengeData.len()

	if ( !IsUI() )
	{
		 local id = PersistenceGetEnumIndexForItemName( GetChallengeEnumNameForRef( ref ), ref )
		 if ( lastChallengeCategory == eChallengeCategory.DAILY )
			id += PersistenceGetEnumCount("challenge")
		 level.challengeData[ ref ].id <- id
	}

	// Add to the list of challenges by category
	Assert( !( ref in level.challengeDataByCategory[ lastChallengeCategory ] ) )
	level.challengeDataByCategory[ lastChallengeCategory ][ ref ] <- level.challengeData[ ref ]

	// We make a new local table for dailies so IsDailyChallenge function can run faster since it's called during game, not just lobby
	if ( lastChallengeCategory == eChallengeCategory.DAILY )
		dailyChallengeList[ ref ] <- true

	lastAddedChallengeRef = ref

	if ( weaponRef )
	{
		if ( !(weaponRef in level.challengeRefsForWeapon) )
			level.challengeRefsForWeapon[weaponRef] <- []

		level.challengeRefsForWeapon[weaponRef].append( ref )
	}
}

function SetChallengeStat( category, alias, weapon = null )
{
	// Links the challenge to a stat that we track

	local challengeRef = lastAddedChallengeRef
	Assert( challengeRef != null )
	Assert( challengeRef in level.challengeData )

	Assert( "category" != null )
	Assert( "alias" != null )

	if ( !IsUI() )
		Assert( IsValidStat( category, alias, weapon ), "Stat specified in AddChallenge is not a valid stat" )

	level.challengeData[ challengeRef ].linkedStat = { category = category, alias = alias, weapon = weapon }
}

function SetChallengeFlags( flags )
{
	// Tells the challenge what types of popup notifications it should do for the player

	local challengeRef = lastAddedChallengeRef
	Assert( challengeRef != null )
	Assert( challengeRef in level.challengeData )

	level.challengeData[ challengeRef ].flags = flags
}

function SetChallengeTiers( valuesArray )
{
	// Adds a challenge to the last created challenge type. This is so we can have multiple challenges on the same type that are sequentially unlocked

	local challengeRef = lastAddedChallengeRef
	Assert( challengeRef != null )
	Assert( challengeRef in level.challengeData )
	Assert( IsArray( valuesArray ) )
	Assert( valuesArray.len() <= MAX_CHALLENGE_TIERS, "SetChallengeTiers tried to set more than max tiers (" + MAX_CHALLENGE_TIERS + ")" )

	// Make sure the numbers go up in the array
	local highestVal = 0
	foreach( num in valuesArray )
	{
		Assert( num > highestVal, "Challenge must have a higher requirement than the previous" )
		highestVal = num
	}

	// Make sure daily challenges only have one tier
	if ( GetChallengeCategory( challengeRef ) == eChallengeCategory.DAILY )
		Assert( valuesArray.len() == 1, "Daily challenges can only have 1 tier!" )

	level.challengeData[ challengeRef ].tierGoals = valuesArray
	if ( CHALLENGES_RESET_AT_EACH_STAGE )
	{
		foreach( num in valuesArray )
			level.challengeData[ challengeRef ].totalNumToComplete += num
	}
	else
	{
		level.challengeData[ challengeRef ].totalNumToComplete = highestVal
	}
}

function SetChallengeTierBurnCards( tier, cardSet )
{
	if ( IsUI() || IsMultiplayer() )
	{
		local challengeRef = lastAddedChallengeRef
		Assert( challengeRef != null )
		Assert( challengeRef in level.challengeData )

		// Make sure daily challenges only have one tier
		if ( GetChallengeCategory( challengeRef ) == eChallengeCategory.DAILY )
			Assert( tier == 0, "Can't set burn card rewards for daily challenge on non zero tier!" )

		Assert( tier < level.challengeData[ challengeRef ].tierGoals.len() )

		foreach ( cardRef in cardSet )
		{
			if ( cardRef.find( "random" ) == 0 )
				continue

			Assert( cardRef in level.burnCardsByName )
		}

		level.challengeData[ challengeRef ].burnCardRewards[tier] = cardSet
	}
}

function InitPlayerChallenges( player )
{
	if ( !CHALLENGES_ENABLED )
		return

	if ( DEBUG_CHALLENGES )
	{
		if ( IsServer() )
			printt( "#################### SERVER InitPlayerChallenges ####################" )
		else if ( IsClient() )
			printt( "#################### CLIENT InitPlayerChallenges ####################" )
		else
			printt( "#################### UI InitPlayerChallenges ####################" )
		printt( "player:", player )
	}

	Assert( IsValid( player ) )
	Assert( player.IsPlayer() )

	if ( IsItemLocked( "challenges", null, player ) )
	{
		if ( DEBUG_CHALLENGES )
			printt( "CHALLENGES LOCKED FOR PLAYER", player )
	}

	//######################################################
	// Daily Challenge Init
	//######################################################
	if ( IsServer() && !player.IsBot() )
	{
		// First look to see if the player should start new dailies.
		local dailyChallengeDayIndex = player.GetPersistentVar( "dailyChallengeDayIndex" )
		local activeDailyIndex = Daily_GetDay()

		// This can happen in dev mode when we are faking the next day
		if ( activeDailyIndex < dailyChallengeDayIndex )
			player.SetPersistentVar( "dailyChallengeDayIndex", 0 )

		local maxDailies = PersistenceGetArrayCount( "activeDailyChallenges" )

		if ( DEBUG_DAILIES )
		{
			printt( "############################################################" )
			printt( "    DAILY CHALLENGE UPDATE")
			printt( "       LAST DAY UPDATED:", dailyChallengeDayIndex )
			printt( "       CURRENT DAY:", activeDailyIndex )
			printt( "Stored dailies from persistence:" )

			for ( local i = 0 ; i < maxDailies ; i++ )
			{
				printt( "  ", player.GetPersistentVar( "activeDailyChallenges[" + i + "].ref" ) )
			}
		}

		// Correct for bugs by making sure tracked challenges are still valid.
		// This can happen if a player abandons a challenge that was tracked and the server didn't finish untracking it before abandoning it
		local trackedChallengeRefs = GetTrackedChallenges( player )
		foreach( ref in trackedChallengeRefs )
		{
			if ( ref != "" && IsDailyChallenge( ref ) && !IsActiveDailyChallenge( ref, player ) )
			{
				printt( ref, "IS AN INVALID DAILY. UNTRACKING IT TO FIX BUG!" )
				UntrackChallengeRef( player, ref )
			}
		}

		// If the player is out of date then we reset the progress on the current daily
		//   challenge refs to make sure they are starting them from scratch and don't have
		//   left over values from last time this ref was used as a daily several days ago
		if ( activeDailyIndex > dailyChallengeDayIndex )
		{
			if ( DEBUG_DAILIES )
				printt( "Player's daily challenges are outdated (" + dailyChallengeDayIndex + "). Setting new ones. Today is a new day (" + activeDailyIndex + ")!" )

			// Update their persistence to the current day index, so challenge data doesn't get wiped during subsequent games during the same day
			// Also lets us know that we've done this logic already today
			player.SetPersistentVar( "dailyChallengeDayIndex", activeDailyIndex )

			// Get todays challenges
			local dailyRefs = GetTodaysDailyChallenges()
			if ( DEBUG_DAILIES )
			{
				printt( "Today's challenges:" )
				PrintTable( dailyRefs )
			}

			// Get daily challenges player still has stored
			local storedDailies = []
			local storedRefs = GetPlayersStoredDailyChallenges( player )
			foreach( ref in storedRefs )
			{
				// Only add incomplete challenges to the array. Completed challenges we untrack if they were tracked before
				local currentDailyProgress = player.GetPersistentVar( "dailychallenges[" + ref + "].progress" )
				local dailyGoal = level.challengeData[ ref ].totalNumToComplete
				if ( currentDailyProgress >= dailyGoal )
				{
					// daily is stored but complete
					UntrackChallengeRef( player, ref )
				}
				else
				{
					local table = {}
					table.ref <- ref
					table.day <- GetDailyChallengeDayAssigned( ref, player )
					storedDailies.append( table )
				}
			}

			if ( DEBUG_DAILIES )
			{
				printt( "Stored challenges:" )
				PrintTable( storedDailies )
			}

			// See if player has room for any new dailies
			local slotsAvailable = maxDailies - storedDailies.len()
			if ( DEBUG_DAILIES )
			{
				printt( "Max dailies:", maxDailies )
				printt( "Slots available:", slotsAvailable )
			}

			// Remove new dailies if we already have that stored
			// "newDailies" will contain only today's new daily refs that aren't already being worked on from a previous day
			local newDailies = []
			foreach( ref in dailyRefs )
			{
				if ( !ArrayContains( storedRefs, ref ) )
				{
					local table = {}
					table.ref <- ref
					table.day <- activeDailyIndex
					newDailies.append( table )
				}
				else if ( DEBUG_DAILIES )
					printt( "  ", ref, "already in stored dailies. Not adding again" )
			}

			if ( DEBUG_DAILIES )
			{
				printt( "Dailies to add:" )
				PrintTable( newDailies )
			}

			if ( slotsAvailable > 0 && newDailies.len() > 0)
			{
				// Try to add all the new dailies unless we run out of slots
				local numToAdd = min( slotsAvailable, newDailies.len() )
				Assert( numToAdd > 0 )
				if ( DEBUG_DAILIES )
					printt( "  adding", numToAdd, "new dailies" )

				for ( local i = 0 ; i < numToAdd ; i++ )
				{
					// Clear the challenge progress for the daily refs since they may have old values left behind from several days ago
					if ( DEBUG_DAILIES )
						printt( "Resetting progress on challenge:", newDailies[i].ref )
					player.SetPersistentVar( "dailychallenges[" + newDailies[i].ref + "].progress", 0 )
					player.SetPersistentVar( "dailychallenges[" + newDailies[i].ref + "].previousProgress", 0 )

					// Add new daily to the array
					storedDailies.append( newDailies[i] )

					// Make daily challenge category as new
					player.SetPersistentVar( "newDailyChallenges", true )
				}

				if ( DEBUG_DAILIES )
				{
					printt( "New stored dailies:" )
					PrintTable( storedDailies )
				}

				printt( "Updating persistence..." )

				// Save the new and old dailies back to persistence
				for ( local i = 0 ; i < maxDailies ; i++ )
				{
					if ( i < storedDailies.len() )
					{
						printt( "  writing:", storedDailies[i].ref, storedDailies[i].day )
						player.SetPersistentVar( "activeDailyChallenges[" + i + "].ref", storedDailies[i].ref )
						player.SetPersistentVar( "activeDailyChallenges[" + i + "].day", storedDailies[i].day )
					}
					else
					{
						printt( "  writing:", null, 0 )
						player.SetPersistentVar( "activeDailyChallenges[" + i + "].ref", null )
						player.SetPersistentVar( "activeDailyChallenges[" + i + "].day", 0 )
					}
				}
			}
			else
			{
				if ( DEBUG_DAILIES && newDailies.len() == 0 )
					printt( "No new dailies to add. They are all already stored" )
				if ( DEBUG_DAILIES && slotsAvailable <= 0 )
					printt( "No slots available for new dailies" )
			}



			if ( DEBUG_DAILIES )
			{
				printt( "Stored dailies from persistence:" )
				for ( local i = 0 ; i < maxDailies ; i++ )
				{
					printt( "  ", player.GetPersistentVar( "activeDailyChallenges[" + i + "].ref" ), player.GetPersistentVar( "activeDailyChallenges[" + i + "].day" ) )
				}
			}
		}
		else
		{
			if ( DEBUG_DAILIES )
				printt( "Not giving any new daily challenges. Player already logged in today (" + activeDailyIndex + ")" )
		}
		if ( DEBUG_DAILIES )
			printt( "############################################################" )
	}
	//######################################################
	//######################################################

	player.s.challengeProgress <- {}
	player.s.trackedChallengeProgress <- {}

	if ( IsClient() )
		Assert( !( "clientChallengeProgress" in level ) )

	foreach( challengeRef, data in level.challengeData )
	{
		Assert( !( challengeRef in player.s.challengeProgress ) )
		local persistenceValue = player.GetPersistentVar( GetChallengeStorageArrayNameForRef(challengeRef) + "[" + challengeRef + "].progress" )
		player.s.challengeProgress[ challengeRef ] <- persistenceValue

		// Since this runs when a player connects, we store off their current challenge progress to new vars so EOG Summary can figure out what challenges were completed during the match
		if ( IsServer() && !IsLobby() )
			player.SetPersistentVar( GetChallengeStorageArrayNameForRef(challengeRef) + "[" + challengeRef + "].previousProgress", persistenceValue )
	}

 	player.s.trackedChallengeProgress <- clone player.s.challengeProgress
	if ( IsClient() )
		level.clientChallengeProgress <- clone player.s.challengeProgress
}

function UpdateChallengeRewardItems( parentRef, childRef, type, challengeReq, challengeTier )
{
	if ( challengeReq == null )
		return
	Assert( challengeTier != null )
	Assert( challengeTier >= 0 )

	if ( !( challengeReq in level.itemRewardsForChallenge ) )
		level.itemRewardsForChallenge[ challengeReq ] <- {}
	Assert ( !( challengeTier in level.itemRewardsForChallenge[ challengeReq ] ) )

	level.itemRewardsForChallenge[ challengeReq ][ challengeTier ] <-{}
	level.itemRewardsForChallenge[ challengeReq ][ challengeTier ].parentRef <- parentRef
	level.itemRewardsForChallenge[ challengeReq ][ challengeTier ].childRef <- childRef
	level.itemRewardsForChallenge[ challengeReq ][ challengeTier ].type <- type
}

function GetLocalChallengeTable( player = null )
{
	if ( IsUI() )
		return uiGlobal.ui_ChallengeProgress

	if ( IsServer() )
	{
		Assert( IsValid( player ) )
		Assert( player.IsPlayer() )
		Assert( "challengeProgress" in player.s )
		return player.s.challengeProgress
	}

	if ( IsClient() )
	{
		Assert( "clientChallengeProgress" in level )
		return level.clientChallengeProgress
	}

	Assert( 0 )
}

function UI_GetAllChallengesProgress()
{
	//##########################################################################
	// 		Updates local table that stores persistent challenge progress
	//##########################################################################

	Assert( IsUI(), "Can't call UI_GetAllChallengesProgress outside of UI Script" )

	// Get the players progress for all challenges
	uiGlobal.ui_ChallengeProgress = {}
	foreach( challengeRef, data in level.challengeData )
		uiGlobal.ui_ChallengeProgress[ challengeRef ] <- GetPersistentVar( GetChallengeStorageArrayNameForRef(challengeRef) + "[" + challengeRef + "].progress" )
}


function UI_GetSpecificChallengeProgress( challengeRef )
{
	uiGlobal.ui_ChallengeProgress[ challengeRef ] <- GetPersistentVar( GetChallengeStorageArrayNameForRef(challengeRef) + "[" + challengeRef + "].progress" )
}

function UpdateLocalChallengeProgress( challengeRef, player, changeInValue, totalValue = null )
{
	if ( !CHALLENGES_ENABLED )
		return

	if ( !IsValid( player ) || !player.IsPlayer() )
		return

	local challengeTable = GetLocalChallengeTable( player )
	Assert( challengeRef in challengeTable )

	if ( changeInValue == null )
	{
		Assert( totalValue != null )
		challengeTable[ challengeRef ] = totalValue
	}
	else
		challengeTable[ challengeRef ] += changeInValue

	if ( DEBUG_CHALLENGES )
	{
		printt( "#################################" )
		printt( challengeRef, " = ", challengeTable[ challengeRef ] )
		printt( "#################################" )
	}
}

function _GetChallengeProgressTotal( challengeRef, player = null )
{
	// Returns the total progress of a challenge type
	local challengeTable = GetLocalChallengeTable( player )
	Assert( challengeRef in challengeTable, "Tried to get challenge progress with invalid challenge ref" )
	return challengeTable[ challengeRef ]
}

function GetChallengeCategory( challengeRef )
{
	Assert( challengeRef in level.challengeData, "Called GetChallengeCategory with invalid challenge ref" )
	return level.challengeData[ challengeRef ].category
}

function IsDailyChallenge( challengeRef )
{
	Assert( challengeRef in level.challengeData, "Called IsDailyChallenge with invalid challenge ref" )
	return ( challengeRef in dailyChallengeList )	// faster to use simple local table instead of getting category on level table and doing several lookups
	//return GetChallengeCategory( challengeRef ) == eChallengeCategory.DAILY
}

function IsCoopChallenge( challengeRef )
{
	Assert( challengeRef in level.challengeData, "Called IsCoopChallenge with invalid challenge ref" )
	return GetChallengeCategory( challengeRef ) == eChallengeCategory.COOP
}

function IsActiveDailyChallenge( challengeRef, player = null )
{
	Assert( challengeRef in level.challengeData, "Called IsActiveDailyChallenge with invalid challenge ref" )
	Assert( IsDailyChallenge( challengeRef ) )

	return ArrayContains( GetPlayersStoredDailyChallenges( player ), challengeRef )
}

function GetPlayersStoredDailyChallenges( player = null )
{
	if ( !IsUI() )
		Assert( IsValid( player ) && IsPlayer( player ) )

	local maxRefs = PersistenceGetArrayCount( "activeDailyChallenges" )
	local refs = []
	for ( local i = 0 ; i < maxRefs ; i++ )
	{
		local ref = IsUI() ? GetPersistentVar( "activeDailyChallenges[" + i + "].ref" ) : player.GetPersistentVar( "activeDailyChallenges[" + i + "].ref" )

		if ( ref == null )
			continue

		refs.append( ref )
	}
	return refs
}

function GetDailyChallengeDayAssigned( challengeRef, player = null )
{
	Assert( IsDailyChallenge( challengeRef ) )
	Assert( IsActiveDailyChallenge( challengeRef, player ) )

	if ( !IsUI() )
		Assert( IsValid( player ) && IsPlayer( player ) )

	local maxRefs = PersistenceGetArrayCount( "activeDailyChallenges" )
	for ( local i = 0 ; i < maxRefs ; i++ )
	{
		local ref = IsUI() ? GetPersistentVar( "activeDailyChallenges[" + i + "].ref" ) : player.GetPersistentVar( "activeDailyChallenges[" + i + "].ref" )

		if ( ref != challengeRef )
			continue

		local day = IsUI() ? GetPersistentVar( "activeDailyChallenges[" + i + "].day" ) : player.GetPersistentVar( "activeDailyChallenges[" + i + "].day" )
		return day
	}
	Assert( 0, "GetDailyChallengeDaysOld failed" )
}

function GetTodaysDailyChallenges()
{
	local challengeRefs = []
	foreach( list in level.dailyChallenges )
	{
		local index = Daily_GetDay() % list.len()
		challengeRefs.append( list[index] )
	}
	Assert( challengeRefs.len() == level.dailyChallenges.len() )
	return challengeRefs
}

function GetChallengeCategoryName( category )
{
	Assert( category in level.challengeCategoryNames, "Called GetChallengeCategoryName with invalid category" )
	return level.challengeCategoryNames[ category ].title
}

function GetChallengeCategoryDesc( category )
{
	Assert( category in level.challengeCategoryNames, "Called GetChallengeCategoryDesc with invalid category" )
	return level.challengeCategoryNames[ category ].desc
}

function GetChallengeID( challengeRef )
{
	//##########################################################################
	// 			Returns the ID of the challenge for ref
	//##########################################################################

	Assert( !IsUI() )
	Assert( challengeRef in level.challengeData, "Tried to call GetChallengeID with invalid challenge ref" )
	return level.challengeData[ challengeRef ].id
}

function GetChallengeName( challengeRef, player = null )
{
	//##########################################################################
	// 			Returns the name of the challenge for challengeRef
	//##########################################################################

	Assert( challengeRef in level.challengeData, "Tried to call GetChallengeName with invalid challenge ref " + challengeRef )

	local currentTier = GetCurrentChallengeTier( challengeRef, player )
	Assert( currentTier in level.challengeData[ challengeRef ].tierGoals, "Invalid challenge index" )

	if ( IsDailyChallenge( challengeRef ) )
		return GetDailyChallengeName( challengeRef )
	else
		return GetChallengeNameForTier( challengeRef, currentTier, player )
}

function GetDailyChallengeName( challengeRef )
{
	Assert( challengeRef in level.challengeData, "Tried to call GetChallengeNameForTier with invalid challenge ref" )

	local weaponName = null
	if ( level.challengeData[ challengeRef ].weaponRef != null )
	{
		if ( level.challengeData[ challengeRef ].weaponRefName == null )
			level.challengeData[ challengeRef ].weaponRefName = GetWeaponInfoFileKeyField_Global( level.challengeData[ challengeRef ].weaponRef, "printname" )
		weaponName = level.challengeData[ challengeRef ].weaponRefName
	}

	local challengeNameParts = []

	if ( weaponName == null )
	{
		challengeNameParts.append( "#CHALLENGE_NAME_DAILY" )
		challengeNameParts.append( level.challengeData[ challengeRef ].title )
	}
	else
	{
		challengeNameParts.append( "#CHALLENGE_NAME_DAILY_WEAPON" )
		challengeNameParts.append( level.challengeData[ challengeRef ].title )
		challengeNameParts.append( weaponName )
	}

	return challengeNameParts
}

function GetChallengeNameForTier( challengeRef, tier, player = null )
{
	//##########################################################################
	// 		Returns the name of the challenge given the specified tier
	//##########################################################################

	Assert( challengeRef in level.challengeData, "Tried to call GetChallengeNameForTier with invalid challenge ref" )
	Assert( tier in level.challengeData[ challengeRef ].tierGoals, "Invalid challenge tier index" )

	local weaponName = null
	if ( level.challengeData[ challengeRef ].weaponRef != null )
	{
		if ( level.challengeData[ challengeRef ].weaponRefName == null )
			level.challengeData[ challengeRef ].weaponRefName = GetWeaponInfoFileKeyField_Global( level.challengeData[ challengeRef ].weaponRef, "printname" )
		weaponName = level.challengeData[ challengeRef ].weaponRefName
	}

	local challengeNameParts = []

	if ( weaponName == null )
	{
		challengeNameParts.append( "#CHALLENGE_NAME_PART_" + tier.tostring() )
		challengeNameParts.append( level.challengeData[ challengeRef ].title )
	}
	else
	{
		challengeNameParts.append( "#CHALLENGE_NAME_PART_" + tier.tostring() + "_WEAPON" )
		challengeNameParts.append( level.challengeData[ challengeRef ].title )
		challengeNameParts.append( weaponName )
	}

	return challengeNameParts
}

function GetChallengeDescription( challengeRef )
{
	//##########################################################################
	// 			Returns the description of the challenge
	//##########################################################################

	Assert( challengeRef in level.challengeData, "Tried to call GetChallengeProgressName with invalid challenge ref" )

	local descNameParts = []
	descNameParts.append( level.challengeData[ challengeRef ].desc )
	if ( level.challengeData[ challengeRef ].weaponRef != null )
	{
		if ( level.challengeData[ challengeRef ].weaponRefName == null )
			level.challengeData[ challengeRef ].weaponRefName = GetWeaponInfoFileKeyField_Global( level.challengeData[ challengeRef ].weaponRef, "printname" )
		descNameParts.append( level.challengeData[ challengeRef ].weaponRefName )
	}

	return descNameParts
}

function GetChallengeIcon( challengeRef )
{
	//##########################################################################
	// 			Returns the icon of the challenge
	//##########################################################################

	Assert( challengeRef in level.challengeData, "Tried to call GetChallengeIcon with invalid challenge ref" )
	return level.challengeData[ challengeRef ].icon
}

function GetChallengeProgressIsDecimal( challengeRef )
{
	Assert( challengeRef in level.challengeData, "Tried to call GetChallengeProgressIsDecimal with invalid challenge ref" )
	return level.challengeData[ challengeRef ].progressDecimal
}

function GetItemRewardForChallengeTier( challengeRef, tier )
{
	if ( !( challengeRef in level.itemRewardsForChallenge ) )
		return null

	if ( !( tier in level.itemRewardsForChallenge[ challengeRef ] ) )
		return null

	return level.itemRewardsForChallenge[ challengeRef ][ tier ]
}

function GetCurrentChallengeTier( challengeRef, player = null )
{
	// Returns what challenge index we are on based on total challenge progress

	Assert( challengeRef in level.challengeData, "Called GetCurrentChallengeTier with invalid challengeRef" )
	local playerChallengeProgress = _GetChallengeProgressTotal( challengeRef, player )

	foreach( index, tierGoal in level.challengeData[ challengeRef ].tierGoals )
	{
		if ( playerChallengeProgress < tierGoal )
			return index
		if ( CHALLENGES_RESET_AT_EACH_STAGE )
			playerChallengeProgress -= tierGoal
	}

	// Player must be done with all challenges
	return level.challengeData[ challengeRef ].tierGoals.len() - 1
}

function GetGoalForChallengeTier( challengeRef, tier )
{
	//##########################################################################
	// 			Returns goal number to reach specified tier
	//##########################################################################

	Assert( challengeRef in level.challengeData, "Called GetGoalForChallengeTier with invalid challenge ref" )
	Assert( tier in level.challengeData[ challengeRef ].tierGoals, "Called GetGoalForChallengeTier with invalid tier" )

	return level.challengeData[ challengeRef ].tierGoals[ tier ]
}

function GetCurrentChallengeGoal( challengeRef, player = null )
{
	//##########################################################################
	// 			Returns goal number to reach for current challenge
	//##########################################################################

	Assert( challengeRef in level.challengeData, "Called GetCurrentChallengeGoal with invalid challenge ref" )
	local currentTier = GetCurrentChallengeTier( challengeRef, player )

	Assert( currentTier in level.challengeData[ challengeRef ].tierGoals, "Invalid challenge index in GetCurrentChallengeGoal" )
	return level.challengeData[ challengeRef ].tierGoals[ currentTier ]
}

function GetChallengeXPReward( challengeRef, tier, player = null )
{
	//##########################################################################
	// 			Returns XP reward for the specified challenge tier
	//##########################################################################

	Assert( challengeRef in level.challengeData, "Called GetChallengeXPReward with invalid challenge ref" )
	Assert( tier in level.challengeXPRewardsForTier )
	return level.challengeXPRewardsForTier[ tier ]
}

function GetChallengeBurnCardRewards( challengeRef, tier, player = null )
{
	//##########################################################################
	// 			Returns Burn Card rewards for the current challenge tier
	//##########################################################################

	Assert( challengeRef in level.challengeData, "Called GetChallengeBurnCardRewards with invalid challenge ref" )

	local cards = []

	if ( !level.challengeData[ challengeRef ].burnCardRewards[tier] )
		return cards

	return ( clone level.challengeData[ challengeRef ].burnCardRewards[ tier ] )
}

function GetChallengeProgressData( challengeRef, player )
{
	local data = {}
	data.progress <- GetCurrentChallengeProgress( challengeRef, player )
	data.tier <- GetCurrentChallengeTier( challengeRef, player )
	data.tierGoal <- level.challengeData[ challengeRef ].tierGoals[ data.tier ].tofloat()
	data.progressFrac <- clamp( data.progress.tofloat() / data.tierGoal, 0.0, 1.0 )

	return data
}


function GetCurrentChallengeProgress( challengeRef, player = null )
{
	//##########################################################################
	// 			Returns progress into current challenge
	//##########################################################################

	Assert( challengeRef in level.challengeData, "Called GetCurrentChallengeProgress with invalid challenge ref" )

	local playerChallengeProgress = _GetChallengeProgressTotal( challengeRef, player )

	if ( CHALLENGES_RESET_AT_EACH_STAGE )
	{
		foreach( index, tierGoal in level.challengeData[ challengeRef ].tierGoals )
		{
			if ( playerChallengeProgress <= tierGoal )
				return playerChallengeProgress

			playerChallengeProgress -= tierGoal
		}
		Assert( 0, "Error trying to get challenge progress" )
	}
	else
		return clamp( playerChallengeProgress, 0, level.challengeData[ challengeRef ].totalNumToComplete )
}

function GetCurrentChallengeProgressFrac( challengeRef, player = null )
{
	//##########################################################################
	// 			Returns progress into current challenge ( 0-1 )
	//##########################################################################

	Assert( challengeRef in level.challengeData, "Called GetCurrentChallengeProgressFrac with invalid challenge ref" )

	local tierGoal =  GetCurrentChallengeGoal( challengeRef, player ).tofloat()
	local progress = GetCurrentChallengeProgress( challengeRef, player ).tofloat()

	return clamp( progress / tierGoal, 0.0, 1.0 )
}

function GetChallengeProgressFracForTier( challengeRef, tier, player = null )
{
	//##########################################################################
	// 		  Returns progress into challenge for specified tier ( 0-1 )
	//##########################################################################

	Assert( challengeRef in level.challengeData, "Called GetChallengeProgressFracForTier with invalid challenge ref" )

	local tierGoal =  GetGoalForChallengeTier( challengeRef, tier ).tofloat()
	local progress = GetCurrentChallengeProgress( challengeRef, player ).tofloat()

	return clamp( progress / tierGoal, 0.0, 1.0 )
}

function GetChallengeTierCount( challengeRef )
{
	//##########################################################################
	// 		  Returns the number of challenges in the challenge type
	//##########################################################################

	Assert( challengeRef in level.challengeData, "Called GetChallengeTierCount with invalid challenge ref" )
	return level.challengeData[ challengeRef ].tierGoals.len()
}

function GetChallengeFlags( challengeRef )
{
	//##########################################################################
	// 		  		Returns the flags set for this challenge
	//##########################################################################

	Assert( challengeRef in level.challengeData, "Called GetChallengeFlags with invalid challenge ref" )
	return level.challengeData[ challengeRef ].flags
}

function IsChallengeComplete( challengeRef, player = null )
{
	//##########################################################################
	// 		  Returns true if all tiers of the challenge are complete
	//##########################################################################

	Assert( challengeRef in level.challengeData, "Called IsChallengeComplete with invalid challenge ref" )

	local progressTotal = _GetChallengeProgressTotal( challengeRef, player )

	return progressTotal >= level.challengeData[ challengeRef ].totalNumToComplete
}

function IsChallengeTierComplete( challengeRef, tier, player = null )
{
	//##########################################################################
	// 	  Returns true if the specified tier of the challenge is complete
	//##########################################################################

	Assert( challengeRef in level.challengeData, "Called IsChallengeTierComplete with invalid challenge ref" )

	local progressTotal = _GetChallengeProgressTotal( challengeRef, player )
	local goal = GetGoalForChallengeTier( challengeRef, tier )

	return progressTotal >= goal
}

function GetMatchStartChallengeProgress( challengeRef, player = null )
{
	Assert( challengeRef in level.challengeData )
	if ( IsUI() )
		return GetPersistentVar( GetChallengeStorageArrayNameForRef(challengeRef) + "[" + challengeRef + "].previousProgress" )

	Assert( IsValid( player ) && player.IsPlayer() )
	return player.GetPersistentVar( GetChallengeStorageArrayNameForRef(challengeRef) + "[" + challengeRef + "].previousProgress" )
}

function GetChallengeTierForProgress( challengeRef, progress )
{
	Assert( challengeRef in level.challengeData, "Tried to call GetChallengeTierForProgress with invalid challenge ref" )

	foreach( index, tierGoal in level.challengeData[ challengeRef ].tierGoals )
	{
		if ( progress < tierGoal )
			return index
		if ( CHALLENGES_RESET_AT_EACH_STAGE )
			progress -= tierGoal
	}

	// Player must be done with all challenges
	return level.challengeData[ challengeRef ].tierGoals.len() - 1
}

function GetChallengeRefFromID( id )
{
	//##########################################################################
	// 	  	Returns the challenge ref string with the matching id
	//##########################################################################
	Assert( IsClient() )

	foreach( challengeRef, data in level.challengeData )
	{
		if ( data.id == id )
			return challengeRef
	}
	Assert( 0, "No challenge ref with ID" + id )
}

function PutChallengeNameOnLabel( label, challengeRef, tier = null, player = null )
{
	Assert( !IsServer() )
	Assert( challengeRef in level.challengeData, "Tried to call PutChallengeNameOnLabel with invalid challenge ref" )

	local name
	if ( tier == null || IsDailyChallenge( challengeRef ) )
		name = GetChallengeName( challengeRef, player )
	else
		name = GetChallengeNameForTier( challengeRef, tier, player )

	SetChallengeNameTextOnLabel( label, name )
}

function SetChallengeNameTextOnLabel( label, name )
{
	Assert( name.len() )
	if ( name.len() == 2 )
		label.SetText( name[0], name[1] )
	else if ( name.len() == 3 )
		label.SetText( name[0], name[1], name[2] )
	else
		Assert( 0, "Unhandled challenge name format" )
}

function GetNumberRegenChallengesRemaining( player = null )
{
	local remaining = 0
	local gen = IsUI() ? GetGen() : player.GetGen()

	if ( ( gen + 1 ) in level.regenChallenges )
	{
		foreach( challengeRef in level.regenChallenges[ gen + 1 ] )
		{
			if ( !IsChallengeComplete( challengeRef, player ) )
				remaining++
		}
	}

	return remaining
}

function IsRegenRequirement( challengeRef, player = null )
{
	local gen = IsUI() ? GetGen() : player.GetGen()

	if ( ( gen + 1 ) in level.regenChallenges )
	{
		foreach( ref in level.regenChallenges[ gen + 1 ] )
		{
			if ( ref == challengeRef )
				return true
		}
	}

	return false
}

function GetChallengesByCategory( category )
{
	Assert( category in level.challengeDataByCategory )
	local refs = []
	foreach( key, val in level.challengeDataByCategory[ category ] )
	{
		refs.append( key )
	}
	return refs
}

function PutChallengeRewardsOnPanel( challengeRef, tier, panel )
{
	local challengeXPRewardLabel = panel.GetChild( "ChallengeXPRewardLabel" )
	local challengeXPRewardSmallLabel = panel.GetChild( "ChallengeXPRewardSmallLabel" )
	local coinCountIcon = panel.GetChild( "CoinCountIcon" )
	local coinAmountLabel = panel.GetChild( "CoinAmountLabel" )
	local challengeDailyXPRewardSmallLabel = panel.GetChild( "ChallengeDailyXPRewardSmallLabel" )
	local coinCountIconSmall = panel.GetChild( "CoinCountIconSmall" )
	local coinAmountLabelSmall = panel.GetChild( "CoinAmountLabelSmall" )
	local challengeItemRewardNameLabel = panel.GetChild( "ChallengeRewardNameLabel" )
	local challengeItemRewardDescLabel = panel.GetChild( "ChallengeRewardDescLabel" )
	local challengeItemRewardIcon = panel.GetChild( "ChallengeRewardIcon" )

	local bcPanels = []
	bcPanels.append( panel.GetChild( "ChallengeBurnCardReward1" ) )
	bcPanels.append( panel.GetChild( "ChallengeBurnCardReward2" ) )
	bcPanels.append( panel.GetChild( "ChallengeBurnCardReward3" ) )
	bcPanels.append( panel.GetChild( "ChallengeBurnCardReward4" ) )

	local challengeBurnCardRewardPanels = []
	challengeBurnCardRewardPanels.resize( bcPanels.len() )

	foreach ( index, elem in bcPanels )
	{
		local scriptID = elem.GetScriptID().tointeger()
		challengeBurnCardRewardPanels[scriptID] = {}
		CreateBurnCardPanel( challengeBurnCardRewardPanels[scriptID], elem )
		HideBurnCard( challengeBurnCardRewardPanels[scriptID] )
	}

	challengeXPRewardLabel.Hide()
	challengeXPRewardSmallLabel.Hide()
	coinCountIcon.Hide()
	coinAmountLabel.Hide()
	challengeDailyXPRewardSmallLabel.Hide()
	coinCountIconSmall.Hide()
	coinAmountLabelSmall.Hide()

	local challengeRewardItemData = GetItemRewardForChallengeTier( challengeRef, tier )
	if ( challengeRewardItemData != null )
	{
		local itemDesc = null
		local itemImage = null
		if ( challengeRewardItemData.childRef != null )
		{
			local subItemName = GetSubitemName( challengeRewardItemData.parentRef, challengeRewardItemData.childRef )
			local itemName = GetItemName( challengeRewardItemData.parentRef )
			local typeName = GetLocalizedNameFromItemType( challengeRewardItemData.type )
			challengeItemRewardNameLabel.SetText( "#CHALLENGE_REWARD_SUBITEM_NAME", itemName, typeName, subItemName )

			itemDesc = GetSubitemDescription( challengeRewardItemData.parentRef, challengeRewardItemData.childRef )
			itemImage = GetSubitemImage( challengeRewardItemData.parentRef, challengeRewardItemData.childRef )
		}
		else
		{
			local itemName = GetItemName( challengeRewardItemData.parentRef )
			local typeName = GetLocalizedNameFromItemType( challengeRewardItemData.type )
			challengeItemRewardNameLabel.SetText( "#CHALLENGE_REWARD_ITEM_NAME", typeName, itemName )

			itemDesc = GetItemDescription( challengeRewardItemData.parentRef )
			itemImage = GetItemImage( challengeRewardItemData.parentRef )
		}
		Assert( itemDesc != null )
		Assert( itemImage != null )

		challengeItemRewardDescLabel.SetText( itemDesc )
		challengeItemRewardIcon.SetImage( itemImage )

		challengeItemRewardNameLabel.Show()
		challengeItemRewardDescLabel.Show()
		challengeItemRewardIcon.Show()
		challengeXPRewardLabel.Hide()

		foreach ( bcTable in challengeBurnCardRewardPanels )
			HideBurnCard( bcTable )
	}
	else
	{
		local xpReward = GetChallengeXPReward( challengeRef, tier )
		challengeXPRewardSmallLabel.SetText( "#CHALLENGE_REWARD_XP_VALUE", xpReward )
		challengeXPRewardLabel.SetText( "#CHALLENGE_REWARD_XP_VALUE", xpReward )
		challengeDailyXPRewardSmallLabel.SetText( "#CHALLENGE_REWARD_XP_VALUE", xpReward )
		challengeItemRewardNameLabel.Hide()
		challengeItemRewardDescLabel.Hide()
		challengeItemRewardIcon.Hide()

		coinAmountLabel.SetText( COIN_REWARD_DAILY_CHALLENGE.tostring() )
		coinAmountLabelSmall.SetText( COIN_REWARD_DAILY_CHALLENGE.tostring() )

		local cardRefs = GetChallengeBurnCardRewards( challengeRef, tier )

		// hide the burn card rewards until burn cards are unlocked?
		if ( IsItemLocked( "burn_card_slot_1" ) )
			cardRefs = []

		if ( !cardRefs.len() )
		{
			foreach ( bcTable in challengeBurnCardRewardPanels )
				HideBurnCard( bcTable )

			challengeXPRewardSmallLabel.Hide()
			challengeXPRewardLabel.Show()

			if ( IsDailyChallenge( challengeRef ) && IsBlackMarketUnlocked() )
			{
				coinCountIcon.Show()
				coinAmountLabel.Show()
			}
		}
		else
		{
			if ( IsDailyChallenge( challengeRef ) )
			{
				challengeDailyXPRewardSmallLabel.Show()
				if ( IsBlackMarketUnlocked() )
				{
					coinCountIconSmall.Show()
					coinAmountLabelSmall.Show()
				}
				else
				{
					coinCountIconSmall.Hide()
					coinAmountLabelSmall.Hide()
				}
			}
			else
			{
				challengeXPRewardSmallLabel.Show()
				challengeXPRewardLabel.Hide()
			}

			foreach ( index, bcTable in challengeBurnCardRewardPanels )
			{
				if ( index < cardRefs.len() )
				{
					SetBurnCardToCard( bcTable, true, cardRefs[index] )
					ShowBurnCard( bcTable )
				}
				else
				{
					HideBurnCard( bcTable )
				}
			}

			local cardWidth = challengeBurnCardRewardPanels[0].panel.GetWidth()
			if ( cardRefs.len() > 1 )
			{
				local otherCardXOffset = challengeBurnCardRewardPanels[1].panel.GetX()
				cardWidth += otherCardXOffset
			}

			local xOffset = (cardWidth * 0.5) * ( 1 - cardRefs.len() )
			challengeBurnCardRewardPanels[0].panel.SetX( xOffset )
		}
	}
}

function DebugPrintAllChallenges()
{
	local player = GetPlayerArray()[0]
	local totalChallenges = 0

	foreach( category, data in level.challengeDataByCategory )
	{
		if ( data.len() == 0 )
			continue

		print( "\n" )
		print( "\n" )
		print( GetChallengeCategoryName( category ) )
		print( "\n" )
		printt( "-------------------------------------")
		foreach( challengeRef, challengeData in data )
		{
			local challengeName = GetChallengeName( challengeRef, player )[1]
			local challengeDesc = GetChallengeDescription( challengeRef )
			local tierCount = GetChallengeTierCount( challengeRef )
			local tierGoals = []
			for ( local i = 0 ; i < tierCount ; i++ )
				tierGoals.append( GetGoalForChallengeTier( challengeRef, i ) )

			print( "    " )
			print( challengeName )
			print( "  -  ")
			print( challengeDesc[0] )
			print( "  (" )
			foreach( index, goal in tierGoals )
			{
				if ( index != 0 )
					print( "/" )
				print( goal )
			}
			print( ")" )

			print( "\n" )

			totalChallenges++
		}
	}
	printt( "Total Challenges:", totalChallenges )
}

function GetTrackedChallenges( player = null )
{
	if ( !IsUI() )
		Assert( IsValid( player ) )

	local trackedChallenges = []
	for ( local i = 0; i < MAX_TRACKED_CHALLENGES; i++ )
	{
		local ref = IsUI() ? GetPersistentVar( "trackedChallengeRefs[" + i + "]" ) : player.GetPersistentVar( "trackedChallengeRefs[" + i + "]" )
		trackedChallenges.append( ref )
	}
	return trackedChallenges
}

function UntrackChallengeRef( player, ref )
{
	Assert( IsServer() )
	Assert( ref != null )
	Assert( ref != "" )

	local found = false
	for ( local i = 0; i < MAX_TRACKED_CHALLENGES; i++ )
	{
		if ( player.GetPersistentVar( "trackedChallengeRefs[" + i + "]" ) == ref )
		{
			player.SetPersistentVar( "trackedChallengeRefs[" + i + "]", "" )
			found = true
		}
		else if ( found )
		{
			player.SetPersistentVar( "trackedChallengeRefs[" + (i - 1) + "]", player.GetPersistentVar( "trackedChallengeRefs[" + i + "]" ) )
			player.SetPersistentVar( "trackedChallengeRefs[" + i + "]", "" )
		}
	}

	found = false
	for ( local i = 0; i < MAX_TRACKED_CHALLENGES; i++ )
	{
		if ( player.GetPersistentVar( "EOGTrackedChallengeRefs[" + i + "]" ) == ref )
		{
			player.SetPersistentVar( "EOGTrackedChallengeRefs[" + i + "]", "" )
			found = true
		}
		else if ( found )
		{
			player.SetPersistentVar( "EOGTrackedChallengeRefs[" + (i - 1) + "]", player.GetPersistentVar( "EOGTrackedChallengeRefs[" + i + "]" ) )
			player.SetPersistentVar( "EOGTrackedChallengeRefs[" + i + "]", "" )
		}
	}
}