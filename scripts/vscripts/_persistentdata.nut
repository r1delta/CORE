
function main()
{
	if ( !IsUI() )
	{
		Globalize( InitPersistentData )
		Globalize( ResetCustomLoadouts )
		Globalize( GetPersistentIntArray )
		Globalize( SetPersistentArray )
	}
}

if ( !IsUI() )
{
	function InitPersistentData( player )
	{
		InitBurnCardPersistence( player )

		if ( !player.GetPersistentVar( "previouslyInitialized" ) )
		{
			//printt( "======================================================================================="  )
			//printt( "Setting persistent data defaults======================================================"  )
			//printt( "======================================================================================="  )

		    // TODO: REPLACE THIS WITH A DATA DRIVEN SOURCE
			// TODO: Once unlock levels for weapons and custom loadouts are set, update with a better variety.

			ResetCustomLoadouts( player )

			player.SetPersistentVar( "previouslyInitialized", 1 )
		}

		local initializedVersion = player.GetPersistentVar( "initializedVersion" )

		if ( initializedVersion < 2 )
		{
			//printt( "======================================================================================="  )
			//printt( "Setting persistent data defaults for revision # 1 ===================================="  )

			// Track Gooser progress ( ejecting pilot kills ) before requirements changed so we can reward these players later if they did it the hard way
			if ( player.GetGen() > 4 )
			{
				// Player is Gen 6 or higher already, they did the full Gooser challenge to 50
				player.SetPersistentVar( "previousGooserProgress", 50 )
				//printt( "player completed gooser legit, storing their progress of 50" )
			}
			else if ( player.GetGen() == 4 )
			{
				// Player is on the challenge currently, so just save off their progress before it changed
				local progress = player.GetPersistentVar( "challenges[ch_ejecting_pilot_kills].progress" )
				player.SetPersistentVar( "previousGooserProgress", progress )
				//printt( "player currently on gooser, storing their progress of", progress )
			}

			//printt( "======================================================================================="  )
		}

		if ( initializedVersion < 3 )
		{
			//printt( "======================================================================================="  )
			//printt( "Setting persistent data defaults for revision # 2 ===================================="  )
			//printt( "======================================================================================="  )

			// init additional custom loadout slots added in patch #2
			ResetAdditionalCustomLoadouts( player )
			InitPlayerMapHistory( player )
			InitPlayerModeHistory( player )
		}

		if ( initializedVersion < 4 )
		{
			//printt( "======================================================================================="  )
			//printt( "Setting persistent data defaults for revision # 3 ===================================="  )
			//printt( "======================================================================================="  )

			player.SetPersistentVar( "bm.coinCount", CURRENCY_COIN_WALLET_START_AMOUNT )
		}

		// NOTE: Revision #4 was removed since it is no longer needed

		if ( initializedVersion < 6 )
		{
			// This is just to initially infect some Respawn employees so it can spread to other players that kill us
			//printt( "======================================================================================="  )
			//printt( "Setting persistent data defaults for revision # 5 ===================================="  )

			local playerName = player.GetPlayerName()
			local infectedNames = [ "HkySk8r187", "HkySk8r187_Dev", "Princess Cowboy", "Raukin", "RSPNCompONEnt",
									"Doc Feffer", "zurishmy", "Monsterclip", "Swakdaddy", "BladeOfLegend",
									"ZombieJolie", "DKo5", "REDKo5", "STEELES JUSTICE", "A559SSIN", "NBTBadMutha",
									"rBadMofo", "Rayme", "RoBoTg", "MurderStein-dev", "chrish-re", "TheSpawnexe",
									"Xehn", "fatmojo69", "rab7166", "TSUEnami", "RespawnBlade" ]

			//printt( "Infected Dev Member Names:" )
			//PrintTable( infectedNames )

			if ( ArrayContains( infectedNames, playerName ) )
			{
				printt( "Your account name", playerName, "has been marked with the Respawn infection" )
				player.SetPersistentVar( "respawnKillInfected", true )
			}

			//printt( "======================================================================================="  )
		}

		if ( initializedVersion < 7 )
		{
			player.SetPersistentVar( "activeBCID", -1 )
		}

		if ( initializedVersion < 9 )
		{
			player.SetPersistentVar( "dailyChallengeDayIndex", 0 )
		}

		if ( initializedVersion < 10 )
		{
			// Upgrade people to new tracking system. Takes their old stored index value and looks up the ref for that index and puts it into the new ref vars
			for ( local i = 0; i < MAX_TRACKED_CHALLENGES; i++ )
			{
				local trackedIndex = player.GetPersistentVar( "trackedChallenges[" + i + "]" )
				if ( trackedIndex > 0 && trackedIndex < PersistenceGetEnumCount( "challenge" ) )
				{
					local trackedRef = PersistenceGetEnumItemNameForIndex( "challenge", trackedIndex )
					player.SetPersistentVar( "trackedChallengeRefs[" + i + "]", trackedRef )
				}
			}

			for ( local i = 0; i < MAX_TRACKED_CHALLENGES; i++ )
			{
				local trackedIndex = player.GetPersistentVar( "EOGTrackedChallenges[" + i + "]" )
				if ( trackedIndex > 0 && trackedIndex < PersistenceGetEnumCount( "challenge" ) )
				{
					local trackedRef = PersistenceGetEnumItemNameForIndex( "challenge", trackedIndex )
					player.SetPersistentVar( "EOGTrackedChallengeRefs[" + i + "]", trackedRef )
				}
			}
		}

		if ( initializedVersion < 11 )
		{
			player.SetPersistentVar( "dailyChallengeDayIndex", 0 )

			// I added new vars that track how many times we've played each mode.
			// We had it in an array but that doesn't work well with challenges, so this updates the new vars to the old values

			player.SetPersistentVar( "gameStats.mode_played_at", player.GetPersistentVar( "gameStats.modesPlayed[at]" ) )
			player.SetPersistentVar( "gameStats.mode_played_ctf", player.GetPersistentVar( "gameStats.modesPlayed[ctf]" ) )
			player.SetPersistentVar( "gameStats.mode_played_lts", player.GetPersistentVar( "gameStats.modesPlayed[lts]" ) )
			player.SetPersistentVar( "gameStats.mode_played_cp", player.GetPersistentVar( "gameStats.modesPlayed[cp]" ) )
			player.SetPersistentVar( "gameStats.mode_played_tdm", player.GetPersistentVar( "gameStats.modesPlayed[tdm]" ) )
			player.SetPersistentVar( "gameStats.mode_played_wlts", player.GetPersistentVar( "gameStats.modesPlayed[wlts]" ) )
			player.SetPersistentVar( "gameStats.mode_played_mfd", player.GetPersistentVar( "gameStats.modesPlayed[mfd]" ) )

			player.SetPersistentVar( "gameStats.mode_won_at", player.GetPersistentVar( "gameStats.modesWon[at]" ) )
			player.SetPersistentVar( "gameStats.mode_won_ctf", player.GetPersistentVar( "gameStats.modesWon[ctf]" ) )
			player.SetPersistentVar( "gameStats.mode_won_lts", player.GetPersistentVar( "gameStats.modesWon[lts]" ) )
			player.SetPersistentVar( "gameStats.mode_won_cp", player.GetPersistentVar( "gameStats.modesWon[cp]" ) )
			player.SetPersistentVar( "gameStats.mode_won_tdm", player.GetPersistentVar( "gameStats.modesWon[tdm]" ) )
			player.SetPersistentVar( "gameStats.mode_won_wlts", player.GetPersistentVar( "gameStats.modesWon[wlts]" ) )
			player.SetPersistentVar( "gameStats.mode_won_mfd", player.GetPersistentVar( "gameStats.modesWon[mfd]" ) )
		}

		if ( initializedVersion < 12 )
		{
			local challengeTiersComplete = 0
			local challengesFullyComplete = 0
			local numRefs = PersistenceGetEnumCount( "challenge" )
			for ( local i = 0 ; i < numRefs ; i++ )
			{
				local ref = PersistenceGetEnumItemNameForIndex( "challenge", i )
				if ( !( ref in level.challengeData ) )
					continue

				local tierCount = GetChallengeTierCount( ref )
				local progress = player.GetPersistentVar( "challenges[" + ref + "].progress" )

				for ( local tier = 0 ; tier < tierCount ; tier++ )
				{
					local goal = GetGoalForChallengeTier( ref, tier )
					if ( progress >= goal )
					{
						challengeTiersComplete++
						if ( tier + 1 == tierCount )
							challengesFullyComplete++
					}
				}
			}

			local currentVal = player.GetPersistentVar( "miscStats.challengeTiersCompleted" )
			player.SetPersistentVar( "miscStats.challengeTiersCompleted", currentVal + challengeTiersComplete )

			local currentVal = player.GetPersistentVar( "miscStats.challengesCompleted" )
			player.SetPersistentVar( "miscStats.challengesCompleted", currentVal + challengesFullyComplete )
		}

		if ( initializedVersion < 13 )
		{
			InitPlayerModeHistory( player )
		}

		if ( initializedVersion < 14 )
		{
			local idx = 0
			for ( local i = 1 ; i < 3 ; i++ )
			{
				player.SetPersistentVar( "pilotLoadouts[" + ( i + 14 ) + "].name", "#CUSTOM_PILOT_" + i )
				InitPilotLoadoutFromPreset( player, ( i + 14 ), idx )
				player.SetPersistentVar( "titanLoadouts[" + ( i + 14 ) + "].name", "#CUSTOM_TITAN_" + i )
				InitTitanLoadoutFromPreset( player, ( i + 14 ), idx )

				idx++
			}
		}

		if ( initializedVersion < 15 )
		{
			player.SetPersistentVar( "ranked.sponsorshipsRemaining", RANKED_SPONSORSHIPS_START_VALUE )
		}

		if ( initializedVersion < 16  )
		{
			//2 new loadouts for MFD turning into a full-time game mode
			InitializeNewCustomLoadout( player, 17, 1 )
			InitializeNewCustomLoadout( player, 18, 2 )
		}

		if ( initializedVersion < 17 )
		{
			// reworked this
			ResetRankSkillHistory( player )
		}

		if ( initializedVersion < 18 )
		{
			// changed meaning of this var
			local viewed = player.GetPersistentVar( "ranked.viewedRankedPlayIntro" )
			player.SetPersistentVar( "ranked.joinedRankedPlay", viewed )
		}

		if ( initializedVersion < 19 )
		{
			// Update CU8 achievement vars

			// Update black market coin coint to be semi-retroactive
			local coinCount = player.GetPersistentVar( "bm.coinCount" )
			player.SetPersistentVar( "cu8achievement.ach_blackMarketCreditsEarned", coinCount )

			// Already reached gen 10, and forged certifications didn't exist yet so give the achievement
			if ( player.GetGen() >= 9 )
				player.SetPersistentVar( "cu8achievement.ach_reachedGen10NoForgedCert", true )

			// Check now if they have already purchased all Titan OS voices since we only check when an item is purchased from here on out
			CheckTitanVoiceAchievement( player )

			// Check if user already has titan decal achievment criteria met
			CheckTitanDecalAchievement( player )
		}

		if ( initializedVersion < 20 )
		{
			// Init player seasons and season history to use a big negative number for uninitialized since 0 is now beta season
			player.SetPersistentVar( "ranked.currentSeason.season", RANKED_INVALID_SEASON )
			local maxHistroySize = PersistenceGetArrayCount( "ranked.seasonHistory" )
			for ( local i = 0 ; i < maxHistroySize ; i++ )
				player.SetPersistentVar( "ranked.seasonHistory[" + i + "].season", RANKED_INVALID_SEASON )
		}

		if ( initializedVersion < 21 )
		{
			local nextMaxDecayTime = Daily_GetCurrentTime() + GetRankedDecayRate()
			local nextPlayerDecayTime = GetPlayerGemDecayTime( player )

			if ( nextPlayerDecayTime > nextMaxDecayTime )
				UpdateGemDecayTime( player )
		}

		player.SetPersistentVar( "initializedVersion", PERSISTENCE_INIT_VERSION )
		player.SetPersistentVar( "spawnAsTitan", false )
	}

	function ResetCustomLoadouts( player )
	{
		player.SetPersistentVar( "pilotLoadouts[0].name", "#CUSTOM_PILOT_1" )
		player.SetPersistentVar( "pilotLoadouts[1].name", "#CUSTOM_PILOT_2" )
		player.SetPersistentVar( "pilotLoadouts[2].name", "#CUSTOM_PILOT_3" )
		player.SetPersistentVar( "pilotLoadouts[3].name", "#CUSTOM_PILOT_4" )
		player.SetPersistentVar( "pilotLoadouts[4].name", "#CUSTOM_PILOT_5" )

		InitPilotLoadoutFromPreset( player, 0, 0 )
		InitPilotLoadoutFromPreset( player, 1, 1 )
		InitPilotLoadoutFromPreset( player, 2, 2 )
		InitPilotLoadoutFromPreset( player, 3, 3 )
		InitPilotLoadoutFromPreset( player, 4, 4 )

		player.SetPersistentVar( "titanLoadouts[0].name", "#CUSTOM_TITAN_1" )
		player.SetPersistentVar( "titanLoadouts[1].name", "#CUSTOM_TITAN_2" )
		player.SetPersistentVar( "titanLoadouts[2].name", "#CUSTOM_TITAN_3" )
		player.SetPersistentVar( "titanLoadouts[3].name", "#CUSTOM_TITAN_4" )
		player.SetPersistentVar( "titanLoadouts[4].name", "#CUSTOM_TITAN_5" )

		InitTitanLoadoutFromPreset( player, 0, 0 )
		InitTitanLoadoutFromPreset( player, 1, 1 )
		InitTitanLoadoutFromPreset( player, 2, 2 )
		InitTitanLoadoutFromPreset( player, 3, 3 )
		InitTitanLoadoutFromPreset( player, 4, 4 )

		ResetAdditionalCustomLoadouts( player )

		player.SetPersistentVar( "pilotSpawnLoadout.isCustom", false )
		player.SetPersistentVar( "titanSpawnLoadout.isCustom", false )
	}

	function ResetAdditionalCustomLoadouts( player )
	{
		local idx = 0
		local numModes = PersistenceGetEnumCount( "gameModesWithLoadouts" )
		for ( local i = 5 ; i < NUM_CUSTOM_LOADOUTS + (NUM_GAMEMODE_LOADOUTS * numModes) ; i++ )
		{
			local displayNum = i + 1
			if ( i >= NUM_CUSTOM_LOADOUTS )
				displayNum = abs(((i % NUM_GAMEMODE_LOADOUTS) + 1) - NUM_GAMEMODE_LOADOUTS) + 1

			player.SetPersistentVar( "pilotLoadouts[" + i + "].name", "#CUSTOM_PILOT_" + displayNum )
			InitPilotLoadoutFromPreset( player, i, idx )
			player.SetPersistentVar( "titanLoadouts[" + i + "].name", "#CUSTOM_TITAN_" + displayNum )
			InitTitanLoadoutFromPreset( player, i, idx )

			idx++
			if ( idx > 2 )
				idx = 0
		}
	}

	function InitializeNewCustomLoadout( player, loadoutNumber, displayNum ) //Assume we have same number of pilotLoadouts as TitanLoadouts!
	{
		player.SetPersistentVar( "pilotLoadouts[" + loadoutNumber + "].name", "#CUSTOM_PILOT_" + displayNum )
		InitPilotLoadoutFromPreset( player, loadoutNumber, 0 )
		player.SetPersistentVar( "titanLoadouts[" + loadoutNumber + "].name", "#CUSTOM_TITAN_" + displayNum )
		InitTitanLoadoutFromPreset( player, loadoutNumber, 0 )
	}

	// Get a script array from a persistent int array
	function GetPersistentIntArray( player, variableName )
	{
		local array = []
		local size = PersistenceGetArrayCount( variableName )

		for ( local i = 0; i < size; i++ )
		{
			local element = player.GetPersistentVarAsInt( variableName + "[" + i + "]" )

			array.append( element )
		}

		return array
	}

	// Sets element values in a persistent array from a script array. Modifies elements up to the size of the script array, but not more than the persistent array size.
	function SetPersistentArray( player, variableName, array )
	{
		local size = PersistenceGetArrayCount( variableName )

		for ( local i = 0; i < size; i++ )
		{
			if ( i >= array.len() )
				break

			player.SetPersistentVar( variableName + "[" + i + "]", array[i] )
		}
	}
}