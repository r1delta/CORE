
function main() {
    if( IsLobby() )
        return

    file.playerDeathsPvp <- {}
    file.playerKillsPvp <- {}
    file.playerRecentlyRodeoed <- {}

    AddCallback_OnPlayerRespawned(OnPlayerRespawned)
    AddCallback_PlayerOrNPCKilled(OnPlayerOrNPCKilled)
    AddCallback_OnClientConnected(OnClientConnected)
    AddCallback_OnClientDisconnected(OnClientDisconnected)
    AddDamageCallback("player", OnDamaged)
    AddDamageCallback("npc_solider", OnDamaged)
    AddDamageCallback("npc_titan", OnDamaged)
    AddDamageCallback("npc_spectre", OnDamaged)
    AddCallback_OnRodeoStarted(OnRodeoStarted)
    AddCallback_GameStateEnter(eGameState.WinnerDetermined, Stats_EndRound )
    AddCallback_OnWeaponAttack(OnWeaponAttack)
    Globalize(Stats_IncrementStat)
    Globalize(UpdatePlayerStat)
}

function UpdatePlayerStat(player,category,alias,amount = 1) {
    Stats_IncrementStat(player,category,alias,amount)
}

function OnRodeoStarted( player )
{
    thread StatsOnRodeo_Think( player )
}

function StatsOnRodeo_Think( player )
{
    player.EndSignal( "RodeoOver" )
    player.EndSignal( "OnDeath" )
    player.EndSignal( "OnDestroy" )
    player.EndSignal( "Disconnected" )

    local titan = GetTitanBeingRodeoed( player )

    while ( !IsValid( titan ) )
    {
        wait 0.1
        titan = GetTitanBeingRodeoed( player )
    }

    if ( IsValid( titan ) )
    {
        foreach ( k, v in file.playerRecentlyRodeoed )
        {
            if ( k == player.GetEncodedEHandle() && v == titan.GetEncodedEHandle() )
                return
        }

        if ( titan.GetTeam() == GetOtherTeam( player ) )
        {
            Stats_IncrementStat( player, "misc_stats", "rodeos", 1.0 )

            file.playerRecentlyRodeoed[ player.GetEncodedEHandle() ] <- titan.GetEncodedEHandle()
        }
    }
}

function EntitiesDidLoad() {
    thread HandleDistanceAndTimeStats()
}

function Stats_EndRound()
{
    if( IsLobby() )
        return

    if( !IsRoundBasedGameOver() && IsRoundBased() )
        return

    local currentGameMode = GameRules.GetGameMode()

    foreach( player in GetPlayerArray() )
    {
        if( !IsValid( player ) )
            continue

        if( player.IsBot() )
            continue

        local killedTeam = player.GetTeam()
        local compareFunc = GetScoreboardCompareFunc()
	    local playersArray = GetSortedPlayers( compareFunc, killedTeam )
	    local playerPlacementOnTeam = GetIndexInArray( playersArray, player )

        Stats_IncrementStat(player,"game_stats","game_completed", 1)
        Stats_IncrementStat( player, "game_stats", "game_completed_total", 1.0 )

        local modePlayedStat = "mode_played_" + currentGameMode
        Stats_IncrementStat( player, "game_stats", modePlayedStat, 1.0 )

        if ( killedTeam == TEAM_IMC )
            Stats_IncrementStat( player, "game_stats", "games_completed_as_imc", 1.0 )
        else
            Stats_IncrementStat( player, "game_stats", "games_completed_as_militia", 1.0 )

        // check for mvp and top 3
        if(playerPlacementOnTeam == 0)
         {
            Stats_IncrementStat(player,"game_stats","mvp",1.0)
            Stats_IncrementStat(player,"game_stats","mvp_total",1.0 )
        }

        if(playerPlacementOnTeam <= 3)
            Stats_IncrementStat(player,"game_stats","top3OnTeam",1.0)

        if ( GetCinematicMode() )
        {
            Stats_IncrementStat( player, "game_stats", "game_completed_total_campaign", 1.0 )

            local levelIndex = GetCampaignLevelIndex( GetMapName() )

            local team = killedTeam

            if ( team == TEAM_IMC )
                player.SetPersistentVar( "campaignMapFinishedIMC[" + levelIndex + "]", 1 )
            else
                player.SetPersistentVar( "campaignMapFinishedMCOR[" + levelIndex + "]", 1 )
        }

        local winStreak = player.GetPersistentVar( "winStreak" )
        local highestWinStreak = player.GetPersistentVar( "highestWinStreak" )

        if( GetCurrentWinner() == player.GetTeam() )
        {
            if ( GetCinematicMode() )
            {
                local levelIndex = GetCampaignLevelIndex( GetMapName() )

                local team = killedTeam

                if ( team == TEAM_IMC )
                    player.SetPersistentVar( "campaignMapWonIMC[" + levelIndex + "]", 1 )
                else
                    player.SetPersistentVar( "campaignMapWonMCOR[" + levelIndex + "]", 1 )
            }

            Stats_IncrementStat( player, "game_stats", "mode_won_" + GameRules.GetGameMode(), 1.0 )

            if ( winStreak == null )
                winStreak = 0

            winStreak += 1

            if ( killedTeam == TEAM_IMC )
                Stats_IncrementStat( player, "game_stats", "games_won_as_imc", 1.0 )
            else
                Stats_IncrementStat( player, "game_stats", "games_won_as_militia", 1.0 )


            Stats_IncrementStat(player,"game_stats","game_won",1.0)

            local modeWonStat = "mode_won_" + currentGameMode
            Stats_IncrementStat( player, "game_stats", modeWonStat, 1.0 )

            local lastDailyWin = player.GetPersistentVar("lastDailyMatchVictory")

            if ( Daily_GetDay() > lastDailyWin )
            {
                AddCoins( player, COIN_REWARD_FIRST_WIN_OF_DAY, eCoinRewardType.FIRST_WIN_OF_DAY )
                player.SetPersistentVar( "lastDailyMatchVictory", Daily_GetDay() )
            } else
                AddCoins( player, COIN_REWARD_MATCH_VICTORY + COIN_REWARD_MATCH_COMPLETION, eCoinRewardType.MATCH_VICTORY )
        }
        else
        {
            local imcScore = GameRules.GetTeamScore( TEAM_IMC )
            local militiaScore = GameRules.GetTeamScore( TEAM_MILITIA )

            if ( imcScore != militiaScore )
            {
                winStreak = 0
                player.SetPersistentVar("winStreakIsDraws", 0)
            }
            else
                player.SetPersistentVar("winStreakIsDraws", 1)

            Stats_IncrementStat( player, "game_stats", "mode_played_" + GameRules.GetGameMode(), 1.0 )

            Stats_IncrementStat(player,"game_stats","game_lost",1.0)
            AddCoins( player, COIN_REWARD_MATCH_COMPLETION, eCoinRewardType.MATCH_COMPLETION )
        }

        if ( highestWinStreak == null )
            highestWinStreak = 0

        if ( winStreak > highestWinStreak )
            player.SetPersistentVar( "highestWinStreakEver", winStreak )

        player.SetPersistentVar( "winStreak", winStreak )

        local playerKills = player.GetKillCount()
        local npcKills = player.GetNPCKillCount()
        local playerDeaths = player.GetDeathCount()

        local match_kd = 0.0
        if(playerDeaths > 0)
            match_kd = (playerKills + npcKills) / playerDeaths
        else
            match_kd = playerKills + npcKills

        local pvpMatchRatio = 0.0

        if(playerDeaths > 0)
            pvpMatchRatio = playerKills / playerDeaths
        else
            pvpMatchRatio = playerKills

        local totalDeaths = player.GetPersistentVar("deathStats.total").tofloat()
        local totalKills = player.GetPersistentVar("killStats.total").tofloat()
        local totalPvpKills = player.GetPersistentVar("killStats.totalPVP").tofloat()
        local totalPvpDeaths = player.GetPersistentVar("deathStats.totalPVP").tofloat()

        local lifetimeKdRatio = 0.0

        if(totalDeaths > 0)
            lifetimeKdRatio = totalKills / totalDeaths
        else
            lifetimeKdRatio = totalKills

        local lifetimePvpRatio = 0.0

        if(totalPvpDeaths > 0)
            lifetimePvpRatio = totalPvpKills / totalPvpDeaths
        else
            lifetimePvpRatio = totalPvpKills

        local i = 0
        for ( i = NUM_GAMES_TRACK_KDRATIO - 2; i >= 0; --i )
		{
			player.SetPersistentVar( format( "kdratio_match[%i]", ( i + 1 ) ), player.GetPersistentVar( format("kdratio_match[%i]", i ) ) )
			player.SetPersistentVar( format( "kdratiopvp_match[%i]", ( i + 1 ) ), player.GetPersistentVar( format( "kdratiopvp_match[%i]", i ) ) )
		}

        player.SetPersistentVar( "kdratio_match[0]", match_kd )
        player.SetPersistentVar( "kdratiopvp_match[0]", pvpMatchRatio )
        player.SetPersistentVar( "kdratio_lifetime", lifetimeKdRatio )
        player.SetPersistentVar( "kdratiopvp_lifetime", lifetimePvpRatio )

        if( GameRules.GetGameMode() == ATTRITION && player.GetAssaultScore() >= 100 )
        {
            Stats_IncrementStat( player, "game_stats", "timesScored100AttritionPoints", playerKills )
            Stats_IncrementStat( player, "game_stats", "timesScored100AttritionPoints_total", playerKills )
        }

        local totalKillCount = player.GetKillCount() + player.GetNPCKillCount()
        if( totalKillCount > player.GetDeathCount() * 2 )
            Stats_IncrementStat( player, "game_stats", "times_kd_2_to_1_by_mode", 1.0 )

        if( player.GetKillCount() > player.GetDeathCount() * 2 )
            Stats_IncrementStat( player, "game_stats", "times_kd_2_to_1_pvp_by_mode", 1.0 )
    }
}

function OnDamaged( ent, damageInfo )
{
    local inflictor = damageInfo.GetInflictor()

    if( !IsValid( inflictor ) )
        return

    local attacker = damageInfo.GetAttacker()

    if ( !IsValid( attacker ) )
        return

    if ( !attacker.IsPlayer() )
        return


    local weapon = attacker.GetActiveWeapon()
    if( !IsValid( weapon ) )
        return

    local weaponName = weapon.GetClassname()

    Stats_IncrementStat( attacker, "weapon_stats", "shotsHit", 1.0, weaponName )

    local critHit = false
    local hitBox = damageInfo.GetHitBox()

    if ( CritWeaponInDamageInfo( damageInfo ) )
        critHit = IsCriticalHit( attacker, ent, hitBox, damageInfo.GetDamage(), damageInfo.GetDamageType() )

    if ( critHit )
        Stats_IncrementStat( attacker, "weapon_stats", "critHits", 1.0, weaponName )

    if( IsValidHeadShot( damageInfo, ent ) )
        Stats_IncrementStat( attacker, "weapon_stats", "headshots", 1.0, weaponName )

}

function AddCallback_OnWeaponAttack( callbackFunc)
{
    Assert( "onWeaponAttackCallbacks" in level )
	Assert( type( this ) == "table", "AddCallback_OnWeaponAttack can only be added on a table. " + type( this ) )

	local name = FunctionToString( callbackFunc )
    Assert( !( name in level.onWeaponAttackCallbacks ), "Already added " + name + " with AddCallback_OnPlayerRespawned" )

	local callbackInfo = {}
	callbackInfo.name <- name
	callbackInfo.func <- callbackFunc
	callbackInfo.scope <- this

	level.onWeaponAttackCallbacks[name] <- callbackInfo
}

function OnPlayerRespawned(player) {
    player.s.lastPosForDistanceStat <- player.GetOrigin()
	thread SetLastPosForDistanceStatValid( player, true )
}

function OnWeaponAttack(player,weapon,weaponName,shotsFired) {
    if(!IsValid(player) || !player.IsPlayer())
        return

    if(weapon == null)
        return

        local weaponName = weapon.GetClassname()
        if(!weaponName) {
            return
        }
        Stats_IncrementStat( player, "weapon_stats", "shotsFired", 1.0, weaponName )

}


function HandleDistanceAndTimeStats()
{
    if(IsLobby())
        return

    while( GetGameState() < eGameState.Playing )
        wait 0

    foreach(player in GetPlayerArray())
        thread DistanceAndTimeStats_Think( player )
}


function DistanceAndTimeStats_Think( player )
{
    player.EndSignal( "Disconnected" )

    local lastTickTime = Time()

    for(;;)
    {
        if(!IsValid(player))
            continue

        if ( !("lastPosForDistanceStatValid" in player.s) ) {
            // Value hasn't been initialized yet, likely player just joined.
            // Initialize it now or just skip this player for this tick.
            // Initializing here might be safer:
            player.s.lastPosForDistanceStatValid <- false
            continue // Skip distance calculation for this tick
        }

        local timeSeconds = Time() - lastTickTime
		local timeHours = timeSeconds / 3600.0

        if ( player.s.lastPosForDistanceStatValid )
        {
            local distInches = Distance2D( player.s.lastPosForDistanceStat, player.GetOrigin() )
            local distMiles = distInches / 63360.0
            Stats_IncrementStat( player, "distance_stats", "total", distMiles )

            if(player.IsTitan())
            {
                Stats_IncrementStat( player, "distance_stats", "asTitan", distMiles )
                local titanDataTable = GetPlayerClassDataTable( player, "titan" )
                local titanSettings = titanDataTable.playerSetFile
                titanSettings = titanSettings.slice( 0, 1 ).toupper() + titanSettings.slice( 1, titanSettings.len() )
                Stats_IncrementStat( player, "distance_stats", "as" + titanSettings, distMiles )
            } else {
                Stats_IncrementStat( player, "distance_stats", "asPilot", distMiles )
            }

            if(player.IsWallRunning())
                Stats_IncrementStat( player, "distance_stats", "wallrunning", distMiles )
            else if ( player.IsZiplining() )
                Stats_IncrementStat( player, "distance_stats", "ziplining", distMiles )
            else if ( !player.IsOnGround() )
                Stats_IncrementStat( player, "distance_stats", "inAir", distMiles )

            if ( IsValid( player.GetTitanSoulBeingRodeoed() ) && IsValid( player.GetTitanSoulBeingRodeoed().GetBossPlayer() ) )
            {
                local soul = player.GetTitanSoulBeingRodeoed()
                local titan = soul.GetBossPlayer()

                if ( titan.GetTeam() == player.GetTeam() )
                    Stats_IncrementStat( player, "distance_stats", "onFriendlyTitan", distMiles )
                else
                    Stats_IncrementStat( player, "distance_stats", "onEnemyTitan", distMiles )
            }
        }

        if ( timeSeconds <= 0 )
            break
        Stats_IncrementStat(player,"game_stats","hoursPlayed",timeHours)
        Stats_IncrementStat( player, "time_stats", "hours_total", timeHours )
        if(player.IsTitan())
        {
            Stats_IncrementStat( player, "time_stats", "hours_as_titan",  timeHours )
            local titanDataTable = GetPlayerClassDataTable( player, "titan" )
            local titanSettings = titanDataTable.playerSetFile
            Stats_IncrementStat( player, "time_stats", "hours_as_" + titanSettings, timeHours )
        }
        else
            Stats_IncrementStat( player, "time_stats", "hours_as_pilot", timeHours )
        local state = ""
        if ( player.IsWallHanging() )
            Stats_IncrementStat( player, "time_stats", "hours_wallhanging", timeHours )
        else if(player.IsWallRunning())
            Stats_IncrementStat( player, "time_stats", "hours_wallrunning", timeHours )
        else if (!IsAlive(player))
            Stats_IncrementStat( player, "time_stats", "hours_dead", timeHours )
        else if ( !player.IsOnGround() )
            Stats_IncrementStat( player, "time_stats", "hours_inAir", timeHours )
        local activeWeapon = player.GetActiveWeapon()

        if ( IsValid( activeWeapon ) ) {
            local weaponName = activeWeapon.GetClassname()
            Stats_IncrementStat( player, "weapon_stats", "hoursUsed" ,timeHours, weaponName )
            foreach( weapon in player.GetMainWeapons() )
            {
                Stats_IncrementStat( player, "weapon_stats", "hoursEquipped" ,timeHours, weaponName )
            }
        }

        local ordnanceWeapon = player.GetOffhandWeapon( OFFHAND_RIGHT )

        if ( IsValid( ordnanceWeapon ) )
            Stats_IncrementStat( player, "weapon_stats", "hoursUsed" ,timeHours, ordnanceWeapon )


        player.s.lastPosForDistanceStat = player.GetOrigin()
        player.s.lastPosForDistanceStatValid = true

        wait 0.25
        lastTickTime = Time()
    }
}

function UpdateChallengeData(player,category,statName,value,weaponName)
{
    foreach (ref in level.challengeData)
    {
        if(ref.linkedStat && ref.linkedStat.category == category && ref.linkedStat.alias == statName && ref.linkedStat.weapon == weaponName)
        {
            local id = ref.id
            local challRef = GetChallengeRefFromID(id)

            if(IsDailyChallenge(challRef) && !IsActiveDailyChallenge(challRef,player))
                continue

            local shouldPopup = true
            local id = GetChallengeID(challRef)
            local challengeProgress = GetCurrentChallengeProgress( challRef, player )
            player.SetPersistentVar( GetChallengeStorageArrayNameForRef(challRef) + "[" + challRef + "].progress", challengeProgress + value )
            local oldProgress = challengeProgress
            local oldTier = GetChallengeTierForProgress(challRef, oldProgress)
            local challengeTable = GetLocalChallengeTable( player )
            local currentProgress = challengeProgress + value
            challengeTable[ challRef ] = challengeProgress + value
            local tier = GetChallengeTierForProgress(challRef, currentProgress)
            local goal = GetGoalForChallengeTier( challRef, tier )
            local newTier = GetChallengeTierForProgress(challRef, currentProgress)

            if ( newTier > oldTier || (currentProgress > oldProgress && currentProgress == goal ))
            {
                local xp = GetChallengeXPReward(challRef,tier,player)

                if ( IsDailyChallenge(challRef) )
                {
                    Stats_IncrementStat( player, "misc_stats", "dailyChallengesCompleted", 1 )
                    AddCoins( player, COIN_REWARD_DAILY_CHALLENGE, eCoinRewardType.DAILY_CHALLENGE )
                }

                AddPlayerScore(player,"ChallengeCompleted",null,xp)

                local burncards = GetChallengeBurnCardRewards(challRef,tier,player)
                local deck = GetPlayerBurnCardDeck( player )
                if(deck.len() < 99) {
                    foreach( card in burncards ) {
                        deck.append( { cardRef = card, new = true } )
                    }
                    FillBurnCardDeckFromArray( player, deck )
                    shouldPopup = true
                }
                printt("challenge completed: " + challRef)
            }
            Remote.CallFunction_NonReplay(player,"ServerCallback_UpdateClientChallengeProgress", id ,currentProgress, true)
        }
    }
}

function Stats_IncrementStat( player, category, statName, value, weaponName = null )
{

    if ( GetMapName() == "mp_npe" ) // disable stats on training
		return

    if ( player == null )
        return

    if(!IsValidStat( category, statName,weaponName ))
        return

    if(player.IsBot())
        return

    local var = GetPersistentStatVar(category, statName, weaponName);

    if ( var == null )
        return

	local fixedSaveVar
    local fixedSaveVarInt
	local timesPlayed = 0
    local mapName = GetMapName()
    local gameModeName = GameRules.GetGameMode()
    local gameMode = PersistenceGetEnumIndexForItemName( "gameModes", gameModeName )

	fixedSaveVar = var
    fixedSaveVarInt = var

    fixedSaveVar = StatStringReplace( fixedSaveVar, "%gamemode%", gameMode )
    fixedSaveVarInt = StatStringReplace( fixedSaveVarInt, "%gamemode%", gameMode )

    local mapNameIndex = PersistenceGetEnumIndexForItemName( "maps", mapName )
    if(mapNameIndex != -1)
    {
        fixedSaveVar = StatStringReplace( fixedSaveVar, "%mapname%", mapName )
        fixedSaveVarInt = StatStringReplace( fixedSaveVarInt, "%mapname%", mapNameIndex )
    }

    if ( fixedSaveVar == fixedSaveVarInt )
    {
        local currentValue = player.GetPersistentVar( fixedSaveVar )
        if ( currentValue == null )
            currentValue = 0
        player.SetPersistentVar( fixedSaveVar, currentValue + value )
    } else
    {
        if( !StringContains( fixedSaveVar, "%gamemode%" ) || !StringContains( fixedSaveVar, "%mapname%" ) )
        {
            local currentValue = player.GetPersistentVar( fixedSaveVar )
            if ( currentValue == null )
                currentValue = 0
            player.SetPersistentVar( fixedSaveVar, currentValue + value )
        }

        if( !StringContains( fixedSaveVarInt, "%gamemode%" ) || !StringContains( fixedSaveVarInt, "%mapname%" ) )
        {
            local currentValue = player.GetPersistentVar( fixedSaveVarInt )
            if ( currentValue == null )
                currentValue = 0
            player.SetPersistentVar( fixedSaveVarInt, currentValue + value )
        }
    }

    UpdateChallengeData( player, category, statName, value, weaponName )
}

function OnPlayerOrNPCKilled( victim, attacker, damageInfo )
{
    if ( victim.IsPlayer() )
		thread SetLastPosForDistanceStatValid( victim, false )

    HandleDeathStats( victim, attacker, damageInfo )

    if( victim == attacker )
		return

    HandleKillStats( victim, attacker, damageInfo )
	HandleWeaponKillStats( victim, attacker, damageInfo )
	HandleTitanStats( victim, attacker, damageInfo )
}


function SetLastPosForDistanceStatValid(player,val) {
    wait 0.1
    if ( IsValid(player) )
        player.s.lastPosForDistanceStatValid = val
}


function HandleKillStats( victim, attacker, damageInfo ) {
    local player = null
    local damageSource = damageInfo.GetDamageSourceIdentifier()
    local playerPetTitan = null

    if ( GAMETYPE == COOPERATIVE )
    {
        if ( attacker.IsTurret() )
        {
            local bossPlayer = attacker.GetBossPlayer()

            if ( !IsValid( bossPlayer ) )
                return

            Stats_IncrementStat( bossPlayer, "kills_stats", "coopChallenge_Turret_Kills", 1.0 )
        }

        if ( attacker.IsNPC() && IsSniperSpectre( attacker ) )
        {
            local damageHistory = attacker.s.recentDamageHistory

            foreach( entry in damageHistory )
            {
                local attackerWeakRef = entry.attackerWeakRef

                if ( !IsValid( attackerWeakRef ) )
                    continue

                if ( attackerWeakRef.IsPlayer() )
                    Stats_IncrementStat( attackerWeakRef, "kills_stats", "coopChallenge_SuicideSpectre_Kills", 1.0 )
            }
        }


        if ( !attacker.IsPlayer() )
            return

        if ( IsSniperSpectre( victim ) )
        {
            switch(damageSource)
            {
                case eDamageSourceId.mp_weapon_sniper:
                case eDamageSourceId.mp_weapon_dmr:
                    Stats_IncrementStat( attacker, "kills_stats", "coopChallenge_Sniper_Kills", 1.0 )
            }
        }

        if ( victim.IsNPC() && CloakedDroneIsSquadClaimed( victim.kv.squadname ) )
            Stats_IncrementStat( attacker, "kills_stats", "coopChallenge_CloakDrone_Kills", 1.0 )

        if ( victim.IsDropship() )
            Stats_IncrementStat( attacker, "kills_stats", "coopChallenge_Dropship_Kills", 1.0 )

        if ( victim.IsTitan() )
        {
            if ( victim.GetSubclass() == eSubClass.empTitan )
            {
                local wasAffectedByTitanEmp = false

                foreach( history in attacker.s.recentDamageHistory )
                {
                    if ( history.damageSourceId == eDamageSourceId.titanEmpField )
                        wasAffectedByTitanEmp = true
                }

                if ( !wasAffectedByTitanEmp )
                    Stats_IncrementStat( attacker, "kills_stats", "coopChallenge_EmpTitan_Kills", 1.0 )
            }

            if ( victim.GetSubClass() == eSubClass.nukeTitan )
            {
                if ( damageSource == eDamageSourceId.nuclear_core )
                    Stats_IncrementStat( attacker, "kills_stats", "coopChallenge_NukeTitan_Kills", 1.0 )
            }

            if ( victim.GetSubClass() == eSubClass.mortarTitan )
            {
                local soul = victim.GetTitanSoul()
                if ( Time() - soul.createTime <= 30 )
                    Stats_IncrementStat( attacker, "kills_stats", "coopChallenge_MortarTitan_Kills", 1.0 )
            }
        }
    }

    if ( attacker.IsNPC() )
	{
		if ( !attacker.IsTitan() ) // Normal NPCs case
			return

        local soul = attacker.GetTitanSoul()
        if ( !IsValid( soul ) )
            return

		if ( !IsPetTitan( attacker ) ) // NPC Titans case
			return

		player = soul.GetBossPlayer()
        if ( !IsValid( player ) )
            return
		playerPetTitan = attacker
	}
	else if ( attacker.IsPlayer() )
		player = attacker
	else
		return

    if(IsPilot(attacker)) {
        Stats_IncrementStat( attacker, "kills_stats", "asPilot", 1 )
    }

    if ( victim.IsPlayer() || victim.GetBossPlayer() )
		Stats_IncrementStat( attacker, "kill_stats", "totalPVP", 1.0 )

    if ( attacker.IsPlayer() )
    {
        Stats_IncrementStat( attacker, "kills_stats", "total",  1 )
        if(victim.IsPlayer())
            Stats_IncrementStat( attacker, "game_stats", "pvp_kills_by_mode", 1 )

        if(IsPilot(victim))
         Stats_IncrementStat( attacker, "kills_stats", "totalPilots", 1 )

        if(victim.IsNPC())
            Stats_IncrementStat( attacker, "kills_stats", "totalNPC", 1 )
        if ( victim.IsSpectre() )
            Stats_IncrementStat( attacker, "kills_stats", "spectres", 1 )
        if ( victim.IsSoldier() )
            Stats_IncrementStat( attacker, "kills_stats", "grunts", 1 )
        if ( victim.IsTitan() )
        {
            Stats_IncrementStat( attacker , "kills_stats", "titans", 1 )
            Stats_IncrementStat( attacker, "kills_stats", "totalTitans", 1 )
        }
	    if ( damageInfo.GetDamageSourceIdentifier() == eDamageSourceId.human_melee )
		    Stats_IncrementStat( attacker, "kills_stats", "pilotKickMelee", 1.0 )

	    if ( victim.IsPlayer() && damageInfo.GetDamageSourceIdentifier() == eDamageSourceId.human_melee )
		    Stats_IncrementStat( attacker, "kills_stats", "pilotKickMeleePilot", 1.0 )

         if(GetActiveBurnCard( attacker ) != null)
            Stats_IncrementStat( attacker, "kills_stats", "totalWhileUsingBurnCard", 1.0 )

        if( GetGameState() == eGameState.Epilogue )
            Stats_IncrementStat( attacker, "kills_stats", "evacuatingEnemies", 1.0 )

        if( damageInfo.GetDamageSourceIdentifier() == eDamageSourceId.nuclear_core && victim.IsPlayer() )
            Stats_IncrementStat( attacker, "kills_stats", "nuclearCore", 1.0 )
    }

    local victimIsPilot = IsPilot( victim )
    local victimIsTitan = victim.IsTitan()


    if(attacker.IsTitan())
    {
        if( attacker.GetDoomedState() )
            Stats_IncrementStat( attacker, "kills_stats", "totalTitansWhileDoomed", 1 )

        local titanDataTable = GetPlayerClassDataTable( attacker, "titan" )
        local titanSettings = titanDataTable.playerSetFile
        local titanName = StringReplaceAll( titanSettings, "titan_", "" )
        Stats_IncrementStat( attacker, "kills_stats", "asTitan_" +titanName, 1.0 )
    }

    	// ejectingPilots
	if ( victimIsPilot && victim.pilotEjecting )
		Stats_IncrementStat( player, "kills_stats", "ejectingPilots", 1.0 )

	// whileEjecting
	if ( attacker.IsPlayer() && attacker.pilotEjecting )
		Stats_IncrementStat( player, "kills_stats", "whileEjecting",  1.0 )

	// cloakedPilots
	if ( victimIsPilot && IsCloaked( victim ) )
		Stats_IncrementStat( player, "kills_stats", "cloakedPilots", 1.0 )

	// whileCloaked
	if ( attacker == player && IsCloaked( attacker ) )
		Stats_IncrementStat( player, "kills_stats", "whileCloaked", 1.0 )

	// wallrunningPilots
	if ( victimIsPilot && victim.IsWallRunning() )
		Stats_IncrementStat( player, "kills_stats", "wallrunningPilots",  1.0 )

	// whileWallrunning
	if ( attacker == player && attacker.IsWallRunning() )
		Stats_IncrementStat( player, "kills_stats", "whileWallrunning", 1.0 )

	// wallhangingPilots
	if ( victimIsPilot && victim.IsWallHanging() )
		Stats_IncrementStat( player, "kills_stats", "wallhangingPilots", 1.0 )

	// whileWallhanging
	if ( attacker == player && attacker.IsWallHanging() )
		Stats_IncrementStat( player, "kills_stats", "whileWallhanging",  1.0 )

    if( damageInfo.GetDamageSourceIdentifier() == eDamageSourceId.titan_step)
      {
         Stats_IncrementStat( player, "kills_stats", "titanStepCrush", 1.0 )
         if(victimIsPilot)
            Stats_IncrementStat( player, "kills_stats", "titanStepCrushPilot", 1.0 )
      }

    // 			Stats_IncrementStat( attacker, "kills_stats","titanMeleePilot",1.0)

    if(!player.IsTitan() && damageInfo.GetDamageSourceIdentifier() == eDamageSourceId.titan_melee) {
        Stats_IncrementStat( player, "kills_stats", "titanMelee", 1.0 )
    }

    if ( damageInfo.GetDamageSourceIdentifier() == eDamageSourceId.titan_fall  )
		        Stats_IncrementStat( player, "kills_stats", "titanFallKill", 1.0 )

    if ( damageSource == eDamageSourceId.titan_execution ) {
        local titanDataTable = GetPlayerClassDataTable( attacker, "titan" )
        local titanSettings = titanDataTable.playerSetFile
        local titanName = StringReplaceAll( titanSettings, "titan_", "" )
		titanName = titanName.slice( 0, 1 ).toupper() + titanName.slice( 1, titanName.len() )
        Stats_IncrementStat( player, "kills_stats", "titanExocution" + titanName, 1.0 )
    }

    if ( IsEvacDropship( victim ) )
		Stats_IncrementStat( player, "kills_stats", "evacShips", 1.0 )

    if ( attacker == playerPetTitan && player.GetPetTitanMode() == eNPCTitanMode.FOLLOW )
		Stats_IncrementStat( player, "kills_stats", "petTitanKillsFollowMode",  1.0 )

	// petTitanKillsGuardMode
	if ( attacker == playerPetTitan && player.GetPetTitanMode() == eNPCTitanMode.STAY )
		Stats_IncrementStat( player, "kills_stats", "petTitanKillsGuardMode",  1.0 )

	// pilotKillsAsTitan
	if ( victimIsPilot && attacker.IsTitan() )
		Stats_IncrementStat( player, "kills_stats", "pilotKillsAsTitan", 1.0 )

	// pilotKillsAsPilot
	if ( victimIsPilot && IsPilot( attacker ) )
		Stats_IncrementStat( player, "kills_stats", "pilotKillsAsPilot", 1.0 )

	// titanKillsAsTitan
	if ( victimIsTitan && attacker.IsTitan() )
		Stats_IncrementStat( player, "kills_stats", "titanKillsAsTitan",  1.0 )
}

function HandleDeathStats( victim, attacker, damageInfo ) {

   if(!IsValid(victim) || !victim.IsPlayer())
        return

    Stats_IncrementStat( victim, "deaths_stats", "total",  1.0 )


    if ( IsValid( attacker ) )
	{
		if ( attacker.IsPlayer() || attacker.GetBossPlayer() )
		{
			Stats_IncrementStat( victim, "deaths_stats", "totalPVP", 1.0 )
		}

		// byPilots
		if ( IsPilot( attacker ) )
			Stats_IncrementStat( victim, "deaths_stats", "byPilots", 1.0 )

        // byTitans
        if ( attacker.IsTitan() && !attacker.IsNPC() ) {
            local titanDataTable = GetPlayerClassDataTable( attacker, "titan" )
            local titanSettings = titanDataTable.playerSetFile
            local titanName = StringReplaceAll( titanSettings, "titan_", "" )
            Stats_IncrementStat( victim, "deaths_stats", "byTitans_" + titanName , 1.0 )
        }

        // bySpectres
		if ( attacker.IsSpectre())
			Stats_IncrementStat( victim, "deaths_stats", "bySpectres", 1.0 )

		// byGrunts
		if ( attacker.IsSoldier() )
			Stats_IncrementStat( victim, "deaths_stats", "byGrunts", 1.0 )


        // if ( attacker.IsTitan() && attacker.IsNPC() ) {
        //     printt("npc titan killed")
        //    	local titanSettings = attacker.s.titanSettings
        //     local titanName = StringReplaceAll( titanSettings, "titan_", "" )
		// 	Stats_IncrementStat( victim, "deaths_stats", "byNPCTitans_" + titanName, 1.0 )
        // }

    }

    if(victim.IsPlayer())
        Stats_IncrementStat( victim, "deaths_stats", "asPilot", 1.0 )


    if( damageInfo.GetDamageSourceIdentifier() == eDamageSourceId.suicide)
        Stats_IncrementStat( victim, "deaths_stats", "suicides", 1.0 )

    if ( victim.pilotEjecting )
		Stats_IncrementStat( victim, "deaths_stats", "whileEjecting", 1.0 )


}

function HandleWeaponKillStats( victim, attacker, damageInfo ) {
    if ( attacker.IsPlayer() ) {
        local weapon = damageInfo.GetInflictor()
        if ( weapon != null ) {
            local source = GetNameFromDamageSourceID(damageInfo.GetDamageSourceIdentifier())
            if(source == "human_execution") {
                Stats_IncrementStat(attacker,"kill_stats","pilotExecution",1.0)
                if(IsPilot(victim)) {
                    Stats_IncrementStat(attacker,"kill_stats","pilotExecutePilot",1.0)
                }
                return
            }

            Stats_IncrementStat( attacker, "weapon_kill_stats","total" , 1.0, source )
            if(IsPilot(victim))
                Stats_IncrementStat( attacker, "weapon_kill_stats","pilots" , 1.0, source )
            if ( victim.IsSpectre())
			    Stats_IncrementStat( attacker, "weapon_kill_stats", "spectres", 1.0 ,source)
		    if ( victim.IsSoldier() )
			    Stats_IncrementStat( attacker, "weapon_kill_stats", "grunts", 1.0,source )
            if ( victim.IsMarvin() )
                Stats_IncrementStat( attacker, "weapon_kill_stats", "marvins", 1.0,source )

            if (IsPilot(victim) && victim.pilotEjecting )
		        Stats_IncrementStat( attacker, "weapon_kill_stats", "ejecting_pilots", 1.0,source )

            if ( victim.IsTitan() && !victim.IsNPC() )
            {
                local titanDataTable = GetPlayerClassDataTable( attacker, "titan" )
           	    local titanSettings = titanDataTable.playerSetFile
                local titanName = StringReplaceAll( titanSettings, "titan_", "" )
                printt("titan name: " + titanName)
                // titans_atlas
                Stats_IncrementStat( attacker, "weapon_kill_stats", "titansTotal", 1.0,source )
                Stats_IncrementStat( attacker, "weapon_kill_stats", "titans_" + titanName, 1.0,source )
            }
            if (victim.IsTitan() && victim.IsNPC() ) {
                local titanDataTable = GetPlayerClassDataTable( attacker, "titan" )
           	    local titanSettings = titanDataTable.playerSetFile
                local titanName = StringReplaceAll( titanSettings, "titan_", "" )
                Stats_IncrementStat( attacker, "weapon_kill_stats", "titansTotal", 1.0,source )
                Stats_IncrementStat( attacker, "weapon_kill_stats", "npcTitans_" + titanName, 1.0,source )
            }
            if ( IsValidHeadShot( damageInfo, victim ) )
            {
                if( victim.IsPlayer() )
                    Stats_IncrementStat( attacker, "kill_stats", "pilot_headshots_total", 1.0 )

		        Stats_IncrementStat( attacker, "weapon_stats", "headshots",  1.0, source )
            }
        }
    }
}

function HandleTitanStats( victim, attacker, damageInfo ) {
    if ( attacker.IsPlayer() ) {

    }
}

function OnClientConnected(player) {
    player.s.lastPosForDistanceStatValid <- false
    player.s.lastPosForDistanceStat <- null
    Stats_IncrementStat( player, "game_stats", "game_joined", 1.0 )
}

function OnClientDisconnected(player) {

}