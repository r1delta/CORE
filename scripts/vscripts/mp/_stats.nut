
function main() {
    if(IsLobby())
        return

    AddCallback_OnPlayerRespawned(OnPlayerRespawned)
    AddCallback_PlayerOrNPCKilled(OnPlayerOrNPCKilled)
    AddCallback_OnClientConnected(OnClientConnected)
    AddCallback_OnClientDisconnected(OnClientDisconnected)
    AddDamageCallback("player", OnDamaged)
    AddDamageCallback("npc_solider", OnDamaged)
    AddDamageCallback("npc_titan", OnDamaged)
    AddDamageCallback("npc_spectre", OnDamaged)
    AddCallback_OnRodeoStarted(OnRodeoStarted)
    
    AddCallback_OnWeaponAttack(OnWeaponAttack)
    thread HandleDistanceAndTimeStats()
}

function OnRodeoStarted(player) {
    
}

function OnDamaged(ent,damageInfo) {
    
    local inflictor = damageInfo.GetInflictor()
    if(inflictor == null)
        return
    
    if(inflictor.IsPlayer()) {
        local weapon = inflictor.GetActiveWeapon()
        if(weapon == null)
            return
        local weaponName = weapon.GetClassname()
        Stats_IncrementStat( inflictor, "weapon_stats", "shotsHit", 1.0, weaponName )
        if ( damageInfo.GetCustomDamageType() & DF_CRITICAL )
		    Stats_IncrementStat( inflictor, "weapon_stats", "critHits", 1.0,weaponName )
	    if ( damageInfo.GetCustomDamageType() & DF_HEADSHOT )
		    Stats_IncrementStat( inflictor, "weapon_stats", "headshots",  1.0, weaponName )
    }
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
	thread SetLastPosForDistanceStatValid( player, true )
    player.s.lastPosForDistanceStat = player.GetOrigin()
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


function HandleDistanceAndTimeStats() {
    if(IsLobby())
        return

    while(GetGameState() < eGameState.Playing ) 
        wait 0

    local lastTickTime = Time()

    while(true) {

        foreach(player in GetPlayerArray())
        {
            if(!IsValid(player))
                continue
            
            if ( player.s.lastPosForDistanceStatValid ) {
                local distInches = Distance2D( player.s.lastPosForDistanceStat, player.GetOrigin() )
				local distMiles = distInches / 63360.0
                
                Stats_IncrementStat( player, "distance_stats", "total", distMiles )
                if(player.IsTitan()) {
                    Stats_IncrementStat( player, "distance_stats", "asTitan", distMiles )
	                local titanDataTable = GetPlayerClassDataTable( player, "titan" )
	                local titanSettings = titanDataTable.playerSetFile                    
                    Stats_IncrementStat( player, "distance_stats", "as" + titanSettings, distMiles )
                } else {
                    Stats_IncrementStat( player, "distance_stats", "asPilot", distMiles )
                }

                if(player.IsWallRunning()) {
                    Stats_IncrementStat( player, "distance_stats", "wallrunning", distMiles )
                }
                else if ( player.IsZiplining() )
                    Stats_IncrementStat( player, "distance_stats", "ziplining", distMiles )
				else if ( !player.IsOnGround() )
					Stats_IncrementStat( player, "distance_stats", "inAir", distMiles )
            }
            player.s.lastPosForDistanceStat = player.GetOrigin()
            player.s.lastPosForDistanceStatValid = true
        }


        local timeSeconds = Time() - lastTickTime
		local timeHours = timeSeconds / 3600.0

        foreach(player in GetPlayerArray())
		{
			// first tick i dont count
			if ( timeSeconds == 0 )
				break
            Stats_IncrementStat( player, "time_stats", "hours_total", timeHours )
            if(player.IsTitan())
                Stats_IncrementStat( player, "time_stats", "hours_as_titan",  timeHours )
            else
                Stats_IncrementStat( player, "time_stats", "hours_as_pilot", timeHours )
            local state = ""
			if ( player.IsWallHanging() )
				Stats_IncrementStat( player, "time_stats", "hours_wallhanging", timeHours )
            else if(player.IsWallRunning())
                Stats_IncrementStat( player, "time_stats", "hours_wallrunning", timeHours )
            else if (!IsAlive(player))
                Stats_IncrementStat( player, "time_stats", "hours_dead", timeHours )
            local activeWeapon = player.GetActiveWeapon()

            if ( IsValid( activeWeapon ) ) {
                local weaponName = activeWeapon.GetClassname()
                Stats_IncrementStat( player, "weapon_stats", "hoursUsed" ,timeHours, weaponName )
                foreach( weapon in player.GetMainWeapons() )
				{
                    Stats_IncrementStat( player, "weapon_stats", "hoursEquipped" ,timeHours, weaponName )
                }
            }

        }

		lastTickTime = Time()
        wait 0.25
    }
}


function UpdateChallengeData(player,category,statName,value,weaponName) {
    foreach (ref in level.challengeData) {
        if(ref.linkedStat && ref.linkedStat.category == category && ref.linkedStat.alias == statName && ref.linkedStat.weapon == weaponName) {
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
            if ( newTier > oldTier || (currentProgress > oldProgress && currentProgress == goal )) {

                local xp = GetChallengeXPReward(challRef,tier,player)
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
                printt("challenge completed" + challRef)
                Remote.CallFunction_Replay(player,"ServerCallback_UpdateClientChallengeProgress", id ,challengeProgress + value, shouldPopup)
            }
            Remote.CallFunction_Replay(player,"ServerCallback_UpdateClientChallengeProgress", id ,challengeProgress + value, shouldPopup)
        }
    }
}

function Stats_IncrementStat( player, category, statName,value, weaponName = null ) {

    if ( player == null )
        return

    if(!IsValidStat( category, statName,weaponName ))
        return

    if(player.IsBot())
        return

   local var = GetPersistentStatVar(category, statName, weaponName);

    if ( var == null ) {
        return
    }

    local currentValue = player.GetPersistentVar(var)
    player.SetPersistentVar(var, currentValue + value)

    UpdateChallengeData(player,category,statName,value,weaponName)
   

}

function OnPlayerOrNPCKilled(victim, attacker, damageInfo) {
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
    if ( attacker.IsPlayer() ) {
        Stats_IncrementStat( attacker, "kills_stats", "total",  1 )
        if ( IsPilot( victim ) )
            Stats_IncrementStat( attacker, "kills_stats", "pilots", 1 )
        if ( victim.IsSpectre() )
            Stats_IncrementStat( attacker, "kills_stats", "spectres", 1 )
        if ( victim.IsSoldier() )
            Stats_IncrementStat( attacker, "kills_stats", "grunts", 1 )
        if ( victim.IsTitan() )
            Stats_IncrementStat( attacker , "kills_stats", "titans", 1 )

	    if ( damageInfo.GetDamageSourceIdentifier() == eDamageSourceId.human_melee )
		    Stats_IncrementStat( attacker, "kills_stats", "pilotKickMelee", 1.0 )

	    if ( victim.IsPlayer() && damageInfo.GetDamageSourceIdentifier() == eDamageSourceId.human_melee )
		    Stats_IncrementStat( attacker, "kills_stats", "pilotKickMeleePilot", 1.0 )      
    
         if(GetActiveBurnCard( attacker ) != null) 
            Stats_IncrementStat( attacker, "kills_stats", "totalWhileUsingBurnCard", 1.0 )      

        

    }
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
        if ( attacker.IsTitan() ) {
            local titanDataTable = GetPlayerClassDataTable( attacker, "titan" )
           	local titanSettings = titanDataTable.playerSetFile
            local titanName = replace_all( titanSettings, "titan_", "" )
            Stats_IncrementStat( victim, "deaths_stats", "byTitans_" + titanName , 1.0 )
        }

        // bySpectres
		if ( attacker.IsSpectre())
			Stats_IncrementStat( victim, "deaths_stats", "bySpectres", 1.0 )

		// byGrunts
		if ( attacker.IsSoldier() )
			Stats_IncrementStat( victim, "deaths_stats", "byGrunts", 1.0 )


        if ( attacker.IsTitan() && attacker.IsNPC() ) {
            local titanDataTable = GetPlayerClassDataTable( attacker, "titan" )
           	local titanSettings = titanDataTable.playerSetFile
            local titanName = replace_all( titanSettings, "titan_", "" )
			 Stats_IncrementStat( player, "deaths_stats", "byNPCTitans_" + titanName, 1.0 )
        }
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
            printt("damage source" + source)
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
            
            if (IsPilot(victim) && victim.pilotEjecting )
		        Stats_IncrementStat( attacker, "weapon_kill_stats", "ejecting_pilots", 1.0,source )
            
            if ( victim.IsTitan() && !victim.IsNPC() )
            {    
                local titanDataTable = GetPlayerClassDataTable( attacker, "titan" )
           	    local titanSettings = titanDataTable.playerSetFile
                local titanName = replace_all( titanSettings, "titan_", "" )
                Stats_IncrementStat( attacker, "weapon_kill_stats", "titans_" + titanName, 1.0,source )
            }
            if (victim.IsTitan() && victim.IsNPC() ) {
                local titanDataTable = GetPlayerClassDataTable( attacker, "titan" )
           	    local titanSettings = titanDataTable.playerSetFile
                local titanName = replace_all( titanSettings, "titan_", "" )
                Stats_IncrementStat( attacker, "weapon_kill_stats", "npcTitans_" + titanName, 1.0 )
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
    // Stats_IncrementStat( player, "game_stats", "game_joined", 1.0 )
}

function OnClientDisconnected(player) {

}