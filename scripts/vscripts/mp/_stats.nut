

function main() {
    if(IsLobby())
        return
    AddCallback_OnPlayerRespawned(OnPlayerRespawned)
    AddCallback_PlayerOrNPCKilled(OnPlayerOrNPCKilled)
    AddCallback_OnClientConnected(OnClientConnected)
    AddCallback_OnClientDisconnected(OnClientDisconnected)

    thread HandleDistanceAndTimeStats()
    // thread SaveStatsThread()
}


function OnPlayerRespawned(player) {
	thread SetLastPosForDistanceStatValid( player, true )
    player.s.lastPosForDistanceStat = player.GetOrigin()
}


function HandleDistanceAndTimeStats() {
    if(IsLobby())
        return

    while(GetGameState() < eGameState.Playing ) 
        wait 0

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
                    local titanSetfile = GetPlayerSettingsFieldForClassName( attacker, "titan" )
                    local titanName = replace_all( titanSetfile, "titan_", "" )
           
                    Stats_IncrementStat( player, "distance_stats", "asTitan_" + titanName, distMiles )
                } else {
                    Stats_IncrementStat( player, "distance_stats", "asPilot", distMiles )
                }

                if(player.IsWallRunning()) {
                    Stats_IncrementStat( player, "distance_stats", "wallRunning", distMiles )
                }
                // else if(PlayerIsRodeoingTarget()){}
                else if ( player.IsZiplining() )
                    Stats_IncrementStat( player, "distance_stats", "ziplining", distMiles )
				else if ( !player.IsOnGround() )
					Stats_IncrementStat( player, "distance_stats", "inAir", distMiles )
            }
            player.s.lastPosForDistanceStat = player.GetOrigin()
            player.s.lastPosForDistanceStatValid = true

        }
        wait 0.1
    }
}


function Stats_IncrementStat( player, category, statName,value, weaponName = null ) {

    if ( player == null )
        return

   local var = GetPersistentStatVar(category, statName, weaponName);

    if ( var == null ) {
        return
    }

    local currentValue = player.GetPersistentVar(var)
    player.SetPersistentVar(var, currentValue + value)
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
        if ( attacker.IsTitan() ){
            local titanSetfile = GetPlayerSettingsFieldForClassName( attacker, "titan" )
            local titanName = replace_all( titanSetfile, "titan_", "" )
            Stats_IncrementStat( victim, "deaths_stats", "byTitans_" + titanName , 1.0 )
        }

        // bySpectres
		if ( attacker.IsSpectre())
			Stats_IncrementStat( victim, "deaths_stats", "bySpectres", 1.0 )

		// byGrunts
		if ( attacker.IsSoldier() )
			Stats_IncrementStat( victim, "deaths_stats", "byGrunts", 1.0 )


        if ( attacker.IsTitan() && attacker.IsNPC() ) {
             local titanSetfile = GetPlayerSettingsFieldForClassName( attacker, "titan" )
             local titanName = replace_all( titanSetfile, "titan_", "" )
            
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
            Stats_IncrementStat( attacker, "weapon_kill_stats","total" , 1.0, source )
            if(IsPilot(victim))
                Stats_IncrementStat( attacker, "weapon_kill_stats","pilots" , 1.0, source )
            if ( victim.IsSpectre())
			    Stats_IncrementStat( attacker, "weapon_kill_stats", "spectres", 1.0 ,source)
		    if ( victim.IsSoldier() )
			    Stats_IncrementStat( attacker, "weapon_kill_stats", "grunts", 1.0,source )
            
            if (IsPilot(victim) && victim.pilotEjecting )
		        Stats_IncrementStat( attacker, "weapon_kill_stats", "ejecting_pilots", 1.0,source )


        }
    }
}

function HandleTitanStats( victim, attacker, damageInfo ) {
    if ( attacker.IsPlayer() ) {
        local weapon = damageInfo.GetInflictor()
        if ( weapon != null ) {
            local weaponName = weapon.GetClassname()
            if ( weaponName == "npc_titan" ) {
                // Stats_IncrementStat( attacker, "titan_kill_stats", "total", "", 1 )
            }
        }
    }
}

function OnClientConnected(player) {
    player.s.lastPosForDistanceStatValid <- false
    player.s.lastPosForDistanceStat <- null
    // Stats_IncrementStat( player, "game_stats", "game_joined", 1.0 )
}

function OnClientDisconnected(player) {

}