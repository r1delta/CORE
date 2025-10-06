// Titan Brawl (Auto) enhances the base Titan Brawl ruleset by filling empty
// player slots with autonomous NPC Titans. These Titans use randomized loadouts,
// actively patrol the battlefield, and hunt both players and AI. Roster data is
// replicated so clients can present the bots on the scoreboard.

IncludeScript( "mp/_gamemode_titan_brawl" )

::TitanBrawlAuto_BaseMain <- main
::TitanBrawlAuto_BaseEntitiesDidLoad <- EntitiesDidLoad

const TITAN_BRAWL_AUTO_RESPAWN_DELAY = 0.5


function main()
{
    TitanBrawlAuto_BaseMain()
    TitanBrawlAuto_Init()
}

function EntitiesDidLoad()
{
    TitanBrawlAuto_BaseEntitiesDidLoad()
    TitanBrawlAuto_EntitiesDidLoad()
}
function TitanBrawlAuto_Init()
{
    printt("[TitanBrawlAuto] Init called, gamemode:", GameRules.GetGameMode())
    
    if ( GameRules.GetGameMode() != TITAN_BRAWL_AUTO )
    {
        printt("[TitanBrawlAuto] Init exiting - wrong gamemode")
        return
    }
    
    printt("[TitanBrawlAuto] Init continuing...")

    // Re-init safe: if we have old data, clear it first
    if ( "autoTitanData" in level )
        TitanBrawlAuto_ClearRoster()

    // --- Per-match state ---
    level.autoTitanData <- {}
    level.autoTitanData[ TEAM_IMC ] <- []
    level.autoTitanData[ TEAM_MILITIA ] <- []
    level.autoTitanLookup <- {}
    level.autoTitanGuidCounter <- 0
    level.autoTitanLastRosterBroadcast <- 0.0

    printt("[TitanBrawlAuto] Data structures initialized")


    // --- Seed pools under level.* (no :: globals) ---
    level.autoTitanSettings <- ["titan_atlas", "titan_ogre", "titan_stryder"]

	// Health values for each titan class
	level.autoTitanHealthValues <- {
		titan_atlas = 10000,
		titan_ogre = 12500,
		titan_stryder = 7500
	}

	level.autoTitanWeaponPool <- [
		{ weapon = "mp_titanweapon_xo16",             mod = null },
		{ weapon = "mp_titanweapon_40mm",             mod = null },
		{ weapon = "mp_titanweapon_rocket_launcher",  mod = null },
		{ weapon = "mp_titanweapon_sniper",           mod = null },
		{ weapon = "mp_titanweapon_triple_threat",    mod = null },
		{ weapon = "mp_titanweapon_arc_cannon",       mod = null },
		{ weapon = "mp_titanweapon_shotgun",          mod = null }
	]

	// Weapon mods pool for random loadouts
	level.autoTitanWeaponMods <- {
		mp_titanweapon_xo16 = ["accelerator", "extended_ammo"],
		mp_titanweapon_40mm = ["burst", "extended_ammo"],
		mp_titanweapon_rocket_launcher = ["extended_ammo", "rapid_fire_missiles"],
		mp_titanweapon_sniper = ["extended_ammo", "instant_shot"],
		mp_titanweapon_triple_threat = ["extended_ammo", "mine_field"],
		mp_titanweapon_arc_cannon = ["capacitor"],
		mp_titanweapon_shotgun = []
	}

	// Ordnance pool for random loadouts
	level.autoTitanOrdnancePool <- [
		"mp_titanweapon_salvo_rockets",
		"mp_titanweapon_homing_rockets",
		"mp_titanweapon_dumbfire_rockets",
		"mp_titanweapon_shoulder_rockets"
	]

    // Names from respawnKillInfected in _persistentdata.nut
	level.autoTitanUnusedNames <- [
		"HkySk8r187", "HkySk8r187_Dev", "Princess Cowboy", "Raukin", "RSPNCompONEnt",
		"Doc Feffer", "zurishmy", "Monsterclip", "Swakdaddy", "BladeOfLegend",
		"ZombieJolie", "DKo5", "REDKo5", "STEELES JUSTICE", "A559SSIN", "NBTBadMutha",
		"rBadMofo", "Rayme", "RoBoTg", "MurderStein-dev", "chrish-re", "TheSpawnexe",
		"Xehn", "fatmojo69", "rab7166", "TSUEnami", "RespawnBlade"
	]
	
	ArrayRandomize( level.autoTitanUnusedNames )
	level.autoTitanNamesByTeam <- {}
	level.autoTitanNamesByTeam[TEAM_IMC] <- []
	level.autoTitanNamesByTeam[TEAM_MILITIA] <- []


    if ( !( "autoTitanCallbacksBound" in level ) || !level.autoTitanCallbacksBound )
    {
        printt("[TitanBrawlAuto] Binding callbacks...")
        AddCallback_OnClientConnected( TitanBrawlAuto_OnClientChanged )
        AddCallback_OnClientDisconnected( TitanBrawlAuto_OnClientChanged )
        AddCallback_PlayerOrNPCKilled( TitanBrawlAuto_OnPlayerOrNPCKilled )
        AddCallback_GameStateEnter( eGameState.WaitingForPlayers, TitanBrawlAuto_OnStateChanged )
        AddCallback_GameStateEnter( eGameState.Prematch,          TitanBrawlAuto_OnStateChanged )
        AddCallback_GameStateEnter( eGameState.Playing,           TitanBrawlAuto_OnStateChanged )
        AddCallback_GameStateEnter( eGameState.Postmatch,         TitanBrawlAuto_OnStateChanged )

        level.autoTitanCallbacksBound <- true
        printt("[TitanBrawlAuto] Callbacks bound successfully")
    }
    
    printt("[TitanBrawlAuto] Init complete")

}
function TitanBrawlAuto_EntitiesDidLoad()
{
    printt("[TitanBrawlAuto] EntitiesDidLoad called")
    
    if ( GameRules.GetGameMode() != TITAN_BRAWL_AUTO )
        return
    if ( !("autoTitanData" in level) )
    {
        printt("[TitanBrawlAuto] EntitiesDidLoad - autoTitanData not found!")
        return
    }
    
    printt("[TitanBrawlAuto] EntitiesDidLoad - calling RefreshRoster")
    TitanBrawlAuto_RefreshRoster()
}

function TitanBrawlAuto_OnStateChanged()
{
    printt("[TitanBrawlAuto] OnStateChanged called, state:", GetGameState())
    
    if ( GameRules.GetGameMode() != TITAN_BRAWL_AUTO )
        return

    local state = GetGameState()

    switch ( state )
    {
        case eGameState.WaitingForPlayers:
        case eGameState.Prematch:
        case eGameState.Playing:
            printt("[TitanBrawlAuto] State", state, "- calling RefreshRoster")
            TitanBrawlAuto_RefreshRoster()
            break

        case eGameState.Postmatch:
            printt("[TitanBrawlAuto] Postmatch - calling ClearRoster")
            TitanBrawlAuto_ClearRoster()
            break
    }
}



function TitanBrawlAuto_OnClientChanged( player )
{
    if ( GameRules.GetGameMode() != TITAN_BRAWL_AUTO )
        return

    TitanBrawlAuto_RefreshRoster()
}
function TitanBrawlAuto_OnPlayerOrNPCKilled( victim, attacker, damageInfo )
{
    if ( GameRules.GetGameMode() != TITAN_BRAWL_AUTO )
        return

    local killer = GetAttackerOrLastAttacker( victim, damageInfo )
    if ( IsValid( killer ) && TitanBrawlAuto_IsAutoTitanEntity( killer ) )
    {
        local entry = level.autoTitanLookup[ killer ]
        entry.kills++
        if ( victim.IsTitan() )
            entry.titanKills++
    }

    if ( IsValid( victim ) && TitanBrawlAuto_IsAutoTitanEntity( victim ) )
    {
        local entry = level.autoTitanLookup[ victim ]
        entry.alive = false
        entry.deaths++
        entry.titan = null
        level.autoTitanLookup.rawdelete( victim )
        TitanBrawlAuto_ScheduleRespawn( entry )
    }

    // Award team points for kills (fixes issue #1)
    if ( IsValid( attacker ) && IsValid( victim ) )
    {
        local attackerTeam = attacker.GetTeam()
        local victimTeam = victim.GetTeam()

        // Award points if victim is a player or auto titan, and not same team
        if ( attackerTeam != victimTeam )
        {
            local isVictimPlayerOrAutoTitan = victim.IsPlayer() || TitanBrawlAuto_IsAutoTitanEntity( victim )
            if ( isVictimPlayerOrAutoTitan )
            {
                GameScore.AddTeamScore( attackerTeam, 1 )
            }
        }
    }

    TitanBrawlAuto_BroadcastRoster()
}

function TitanBrawlAuto_IsAutoTitanEntity( ent )
{
    return IsValid( ent ) && ent.GetClassname() == "npc_titan" && ( ent in level.autoTitanLookup )
}

function TitanBrawlAuto_ClearRoster()
{
    if ( !("autoTitanData" in level) )
        return

    foreach ( team, entries in level.autoTitanData )
    {
        foreach ( entry in entries )
            TitanBrawlAuto_RemoveEntry( entry )
        entries.clear()
    }

    level.autoTitanLookup.clear()
    //level.nv.autoTitanRosterIMC = ""
    //level.nv.autoTitanRosterMilitia = ""
    level.autoTitanNamesByTeam[TEAM_IMC].clear()
    level.autoTitanNamesByTeam[TEAM_MILITIA].clear()

    TitanBrawlAuto_BroadcastRoster( true )
}

function TitanBrawlAuto_RefreshRoster()
{
    printt("[TitanBrawlAuto] RefreshRoster called")
    local maxPerTeam = TitanBrawlAuto_GetMaxTeamPlayers()
    printt("[TitanBrawlAuto] Max per team:", maxPerTeam)
    TitanBrawlAuto_RebalanceTeam( TEAM_IMC, maxPerTeam )
    TitanBrawlAuto_RebalanceTeam( TEAM_MILITIA, maxPerTeam )
    TitanBrawlAuto_BroadcastRoster()
}

function TitanBrawlAuto_RebalanceTeam( team, maxPerTeam )
{
    printt("[TitanBrawlAuto] RebalanceTeam - team:", team, "maxPerTeam:", maxPerTeam)
    
    local players = GetPlayerArrayOfTeam( team )
    printt("[TitanBrawlAuto] Players on team:", players.len())
    
    local humanCount = 0
    foreach ( player in players )
    {
        if ( player.IsBot() )
            continue
        humanCount++
    }

    printt("[TitanBrawlAuto] Human count:", humanCount)
    
    local desiredAuto = max( 0, maxPerTeam - humanCount )
    printt("[TitanBrawlAuto] Desired auto titans:", desiredAuto)
    
    local entries = level.autoTitanData[ team ]
    printt("[TitanBrawlAuto] Current auto titans:", entries.len())

    while ( entries.len() < desiredAuto )
    {
        printt("[TitanBrawlAuto] Creating new auto titan entry...")
        local entry = TitanBrawlAuto_CreateEntry( team )
        entries.append( entry )
        printt("[TitanBrawlAuto] Spawning auto titan...")
        thread TitanBrawlAuto_SpawnEntry( entry )
    }

    while ( entries.len() > desiredAuto )
    {
        printt("[TitanBrawlAuto] Removing excess auto titan...")
        local idx = entries.len() - 1
        TitanBrawlAuto_RemoveEntry( entries[idx] )
        entries.remove( idx )
    }
    
    printt("[TitanBrawlAuto] RebalanceTeam complete")
}

function TitanBrawlAuto_CreateEntry( team )
{
    if ( !"autoTitanGuidCounter" in level ) // safety if init ever short-circuits
        level.autoTitanGuidCounter <- 0

    level.autoTitanGuidCounter++
    local guid = level.autoTitanGuidCounter
    local name = TitanBrawlAuto_PopName( team )
    local settings   = TitanBrawlAuto_RandomChoice( level.autoTitanSettings )
    local weaponInfo = TitanBrawlAuto_RandomChoice( level.autoTitanWeaponPool )

    // Random weapon mod
    local weaponMod = null
    if ( weaponInfo.weapon in level.autoTitanWeaponMods )
    {
        local modsForWeapon = level.autoTitanWeaponMods[weaponInfo.weapon]
        if ( modsForWeapon.len() > 0 && RandomInt( 100 ) < 70 ) // 70% chance to have mod
            weaponMod = TitanBrawlAuto_RandomChoice( modsForWeapon )
    }

    // Random ordnance
    local ordnance = TitanBrawlAuto_RandomChoice( level.autoTitanOrdnancePool )

    local entry = {
        guid = guid, team = team, name = name, settings = settings,
        weapon = weaponInfo.weapon, weaponMod = weaponMod,
        ordnance = ordnance,
        kills = 0, deaths = 0, titanKills = 0, assists = 0,
        alive = false, titan = null, respawnToken = null, removed = false,
		spottedPlayers = {}

    }
    return entry
}

function TitanBrawlAuto_SpottingThink( titan, entry )
{
    titan.EndSignal( "OnDeath" )
    titan.EndSignal( "OnDestroy" )

    while ( true )
    {
        local enemyTeam = GetOtherTeam( entry.team )
        local enemyPlayers = GetPlayerArrayOfTeam( enemyTeam )
        
        foreach ( player in enemyPlayers )
        {
            if ( !IsValid( player ) || !IsAlive( player ) )
                continue
            
            // Skip if already spotted
            if ( player in entry.spottedPlayers )
                continue
            
            // Check if titan is facing the player
            local toPlayer = player.GetOrigin() - titan.GetOrigin()
            toPlayer.Norm()
            local facing = titan.GetForwardVector()
            local dot = facing.Dot( toPlayer )
            
            // Within ~90 degree cone (0.5 = ~60 degrees, 0.0 = 90 degrees)
            if ( dot > 0.0 )
            {
                // Check line of sight
                local traceResult = TraceLine( titan.EyePosition(), player.EyePosition(), [titan], TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )
                
                if ( traceResult.fraction >= 0.99 || traceResult.hitEnt == player )
                {
                    // Player spotted!
                    entry.spottedPlayers[player] <- true
                    printt( "[AutoTitan]", entry.name, "spotted player:", player.GetPlayerName() )
                }
            }
        }
        
        wait 0.5  // Check twice per second
    }
}
function TitanBrawlAuto_RemoveEntry( entry )
{
    entry.removed = true
    entry.respawnToken = null

    if ( IsValid( entry.titan ) )
    {
        if ( entry.titan in level.autoTitanLookup )
            level.autoTitanLookup.rawdelete( entry.titan )

        entry.titan.Die( level.worldspawn, level.worldspawn, { scriptType = DF_INSTANT, damageSourceId = eDamageSourceId.round_end } )
    }

    entry.titan = null
    entry.alive = false
    TitanBrawlAuto_ReturnName( entry.name, entry.team )
}
function TitanBrawlAuto_SpawnEntry( entry )
{
    printt("[TitanBrawlAuto] SpawnEntry called for team:", entry.team)

    // Add random stagger to prevent all titans spawning simultaneously
    local stagger = RandomFloat( 0.1, 0.3 )
    wait stagger

    if ( entry.removed )
    {
        printt("[TitanBrawlAuto] Entry is removed, aborting")
        return
    }

    if ( !TitanBrawlAuto_CanSpawnEntry( entry.team ) )
    {
        printt("[TitanBrawlAuto] Cannot spawn yet (wrong game state)")
        if ( entry.respawnToken == null )
            TitanBrawlAuto_ScheduleRespawn( entry )
        return
    }

    printt("[TitanBrawlAuto] Selecting spawn point...")
    local spawnData = TitanBrawlAuto_SelectSpawn( entry.team )
    if ( spawnData == null )
    {
        printt("[TitanBrawlAuto] No spawn point found, scheduling respawn")
        if ( entry.respawnToken == null )
            TitanBrawlAuto_ScheduleRespawn( entry )
        return
    }

    printt("[TitanBrawlAuto] Creating NPC titan...")
    local titan = CreateNPCTitanFromSettings( entry.settings, entry.team, spawnData.origin, spawnData.angles )
    if ( !IsValid( titan ) )
    {
        printt("[TitanBrawlAuto] Failed to create titan!")
        if ( entry.respawnToken == null )
            TitanBrawlAuto_ScheduleRespawn( entry )
        return
    }

    printt("[TitanBrawlAuto] Titan created successfully, setting up...")

    // Set class-specific health (fixes issue #3)
    local titanHealth = 10000  // default
    if ( entry.settings in level.autoTitanHealthValues )
        titanHealth = level.autoTitanHealthValues[ entry.settings ]

    titan.SetHealth( titanHealth )
    titan.SetMaxHealth( titanHealth )
    print(entry.weapon)
    // Give weapon with proper mod handling
    //if ( entry.weaponMod != null )
    //    titan.GiveWeapon( entry.weapon, entry.weaponMod )
    //else
        titan.GiveWeapon( entry.weapon, [] )
    
    // Give random tactical ability
    local tacChoice = RandomInt( 3 )
    if ( tacChoice == 0 )
    {
        titan.GiveOffhandWeapon( "mp_titanability_bubble_shield", TAC_ABILITY_WALL, [] )
        titan.SetTacticalAbility( titan.GetOffhandWeapon( TAC_ABILITY_WALL ), TTA_WALL )
    }
    else if ( tacChoice == 1 )
    {
        titan.GiveOffhandWeapon( "mp_titanability_smoke", TAC_ABILITY_SMOKE, [] )
        titan.SetTacticalAbility( titan.GetOffhandWeapon( TAC_ABILITY_SMOKE ), TTA_SMOKE )
    }
    else
    {
        titan.SetTacticalAbility( titan.GetOffhandWeapon( TAC_ABILITY_VORTEX ), TTA_VORTEX )
    }
    
    titan.SetLookDist( 120000 )
	titan.PreferSprint( true )
    //titan.SetDefaultSchedule( "SCHED_PATROL_PATH" )
    titan.SetTitle( entry.name )
    titan.SetShortTitle( entry.name )
    titan.SetTouchTriggers( true )
    titan.SetEfficientMode( false )

    // Give guardian chip behavior (max weapon proficiency)
    titan.kv.WeaponProficiency = 4

    if ( "guardModePoint" in titan.s )
    {
        if ( IsValid( titan.s.guardModePoint ) )
            titan.s.guardModePoint.Kill()
        delete titan.s.guardModePoint
    }

    waitthread ScriptedHotDrop( titan, spawnData.origin, spawnData.angles, "at_hotdrop_drop_2knee_turbo" )

    entry.titan = titan
    entry.alive = true
    entry.respawnToken = null
    entry.removed = false

    level.autoTitanLookup[ titan ] <- entry
    titan.s.autoBrawlEntry <- entry

    thread TitanBrawlAuto_TitanLifecycle( titan, entry )
    thread TitanBrawlAuto_HuntThink( titan, entry )
	thread TitanBrawlAuto_SpottingThink( titan, entry )

    TitanBrawlAuto_BroadcastRoster()
}
function TitanBrawlAuto_TitanLifecycle( titan, entry )
{
    titan.EndSignal( "OnDeath" )
    titan.EndSignal( "OnDestroy" )

    titan.WaitSignal( "OnDeath" )

    if ( titan in level.autoTitanLookup )
        level.autoTitanLookup.rawdelete( titan )

	if ( entry.removed )
		return
	
	entry.alive = false
	entry.titan = null
	entry.spottedPlayers = {}  // Clear spotted players on death
	TitanBrawlAuto_ScheduleRespawn( entry )
    TitanBrawlAuto_BroadcastRoster()
}

function TitanBrawlAuto_ScheduleRespawn( entry )
{
    if ( entry.respawnToken != null )
        return

    entry.respawnToken <- {}
    local token = entry.respawnToken
    thread TitanBrawlAuto_RespawnEntryThink( entry, token )
}

function TitanBrawlAuto_RespawnEntryThink( entry, token )
{
    local startTime = Time()
    while ( Time() - startTime < TITAN_BRAWL_AUTO_RESPAWN_DELAY )
    {
        if ( entry.removed )
            return
        if ( entry.respawnToken != token )
            return
        if ( !TitanBrawlAuto_CanSpawnEntry( entry.team ) )
        {
            wait 0.25
            continue
        }
        wait 0.25
    }

    if ( entry.removed )
        return
    if ( entry.respawnToken != token )
        return
    if ( !TitanBrawlAuto_IsEntryActive( entry ) )
        return

    TitanBrawlAuto_SpawnEntry( entry )
}

function TitanBrawlAuto_IsEntryActive( entry )
{
    foreach ( other in level.autoTitanData[ entry.team ] )
    {
        if ( other == entry )
            return true
    }
    return false
}

function TitanBrawlAuto_HuntThink( titan, entry )
{
    titan.EndSignal( "OnDeath" )
    titan.EndSignal( "OnDestroy" )

    local lastValidTargetTime = Time()
    local lastPosition = titan.GetOrigin()
    local lastPositionCheckTime = Time()
    local stuckThreshold = 2.0  // If titan hasn't moved in 2 seconds, it's stuck
    local minMovementDistance = 100.0  // Minimum distance to consider "moved"

    while ( true )
    {
        // Check if titan is stuck (hasn't moved significantly)
        local currentTime = Time()
        local currentPosition = titan.GetOrigin()
        local timeSinceLastCheck = currentTime - lastPositionCheckTime

        if ( timeSinceLastCheck >= stuckThreshold )
        {
            local distanceMoved = Distance( currentPosition, lastPosition )

            if ( distanceMoved < minMovementDistance )
            {
                // Titan is stuck! Force it to find a new location
                printt("[AutoTitan]", entry.name, "is stuck, forcing new target")
                TitanBrawlAuto_SendToRandomLocation( titan, entry )
                lastValidTargetTime = currentTime
            }

            lastPosition = currentPosition
            lastPositionCheckTime = currentTime
        }

        local target = TitanBrawlAuto_SelectTarget( titan, entry )
        if ( IsValid( target ) )
        {
			printt("TARGET:" + target)
            titan.SetEnemy( target )
            SendAIToAssaultPoint( titan, target.GetOrigin(), null, 256 )
            lastValidTargetTime = currentTime
        }
        else
        {
            // No valid target - make titan roam to prevent standing still
            local timeSinceLastTarget = currentTime - lastValidTargetTime
            if ( timeSinceLastTarget >= 1.0 )
            {
                TitanBrawlAuto_SendToRandomLocation( titan, entry )
                lastValidTargetTime = currentTime
            }
        }
        wait RandomFloat( 1.5, 3.0 )
    }
}

function TitanBrawlAuto_SendToRandomLocation( titan, entry )
{
    // Try to find a random assault point or spawn point to patrol to
    local enemyTeam = GetOtherTeam( entry.team )
    local assaultPoints = GetEntArrayByClass_Expensive( "info_frontline" )

    if ( assaultPoints.len() > 0 )
    {
        local randomPoint = assaultPoints[ RandomInt( assaultPoints.len() ) ]
        SendAIToAssaultPoint( titan, randomPoint.GetOrigin(), null, 512 )
        return
    }

    // Fallback: move toward enemy spawn
    local enemySpawns = SpawnPoints_GetTitanStart( enemyTeam )
    if ( enemySpawns.len() > 0 )
    {
        local randomSpawn = enemySpawns[ RandomInt( enemySpawns.len() ) ]
        SendAIToAssaultPoint( titan, randomSpawn.GetOrigin(), null, 512 )
        return
    }

    // Last resort: move in a random direction
    local currentPos = titan.GetOrigin()
    local randomOffset = Vector( RandomFloat( -1000, 1000 ), RandomFloat( -1000, 1000 ), 0 )
    local newPos = currentPos + randomOffset
    SendAIToAssaultPoint( titan, newPos, null, 256 )
}
function TitanBrawlAuto_SelectTarget( titan, entry )
{
    local enemyTeam = GetOtherTeam( entry.team )
    local origin = titan.GetOrigin()
    
    // Priority 1: Players (only spotted ones) and ALL Titans
    local highPriority = []
    
    // Add spotted players only
    local enemyPlayers = GetPlayerArrayOfTeam( enemyTeam )
    foreach ( player in enemyPlayers )
    {
        if ( player in entry.spottedPlayers )
            highPriority.append( player )
    }
    
    // Add ALL enemy titans (always valid targets)
    highPriority.extend( GetNPCArrayEx( "npc_titan", enemyTeam, origin, -1 ) )
    
    foreach ( otherEntry in level.autoTitanData[ enemyTeam ] )
    {
        if ( otherEntry.alive && IsValid( otherEntry.titan ) )
            highPriority.append( otherEntry.titan )
    }
    
    // Check high priority targets first
    local best = TitanBrawlAuto_FindClosestValid( highPriority, origin )
    if ( best != null )
        return best
    
    // Priority 2: Low priority NPCs (soldiers/spectres)
    local lowPriority = []
    lowPriority.extend( GetNPCArrayEx( "npc_soldier", enemyTeam, origin, -1 ) )
    lowPriority.extend( GetNPCArrayEx( "npc_spectre", enemyTeam, origin, -1 ) )
    
    return TitanBrawlAuto_FindClosestValid( lowPriority, origin )
}

function TitanBrawlAuto_FindClosestValid( candidates, origin )
{
    local best = null
    local bestDist = 99999999.0
    
    foreach ( candidate in candidates )
    {
        if ( !IsValid( candidate ) )
            continue
        if ( candidate.IsPlayer() && !IsAlive( candidate ) )
            continue
        
        local dist = DistanceSqr( candidate.GetOrigin(), origin )
        if ( dist < bestDist )
        {
            best = candidate
            bestDist = dist
        }
    }
    
    return best
}
function TitanBrawlAuto_SelectSpawn( team )
{
    local startSpawns = SpawnPoints_GetTitanStart( team )
    if ( startSpawns.len() )
    {
        local idx = RandomInt( startSpawns.len() )
        return { origin = startSpawns[idx].GetOrigin(), angles = startSpawns[idx].GetAngles() }
    }

    local fallback = SpawnPoints_GetTitan()
    if ( fallback.len() )
    {
        local idx = RandomInt( fallback.len() )
        return { origin = fallback[idx].GetOrigin(), angles = fallback[idx].GetAngles() }
    }

    local players = GetPlayerArrayOfTeam( team )
    if ( players.len() )
    {
        local base = players[0]
        return { origin = base.GetOrigin(), angles = base.GetAngles() }
    }

    return null
}

function TitanBrawlAuto_GetMaxTeamPlayers()
{
    local maxPlayers = GetCurrentPlaylistVarInt( "max players", 12 )
    if ( maxPlayers <= 0 )
        maxPlayers = 12
    return max( 6, (maxPlayers / 2.0).tointeger() )
}

function TitanBrawlAuto_CanSpawnEntry( team )
{
    local state = GetGameState()
    if ( state == eGameState.WaitingForPlayers )
        return false
    if ( state >= eGameState.Postmatch )
        return false
    return true
}

function TitanBrawlAuto_BroadcastRoster( force = false )
{
    //if ( !( "autoTitanData" in level ) )
    //    return
	//
    //local now = Time()
    //if ( !force && now - level.autoTitanLastRosterBroadcast < 0.2 )
    //    return
	//
    //level.nv.autoTitanRosterIMC = TitanBrawlAuto_EncodeRoster( TEAM_IMC )
    //level.nv.autoTitanRosterMilitia = TitanBrawlAuto_EncodeRoster( TEAM_MILITIA )
    //level.autoTitanLastRosterBroadcast = now
}

function TitanBrawlAuto_EncodeRoster( team )
{
    local entries = level.autoTitanData[ team ]
    if ( entries.len() == 0 )
        return ""

    local parts = []
    foreach ( entry in entries )
    {
        local alive = entry.alive ? 1 : 0
        parts.append( format( "%d,%s,%d,%d,%d,%d,%d", entry.guid, entry.name, entry.kills, entry.deaths, entry.titanKills, entry.assists, alive ) )
    }
    
    // Manual join instead of parts.join( ";" )
    if ( parts.len() == 0 )
        return ""
    
    local result = parts[0]
    for ( local i = 1; i < parts.len(); i++ )
        result += ";" + parts[i]
    
    return result
}
function TitanBrawlAuto_PopName( team )
{
    // First, try to reuse a name from this team
    if ( level.autoTitanNamesByTeam[team].len() > 0 )
    {
        local name = level.autoTitanNamesByTeam[team].remove( level.autoTitanNamesByTeam[team].len() - 1 )
        printt( "[AutoTitan] Reusing name", name, "for team", team )
        return name
    }
    
    // No recycled names for this team, get a fresh one
    if ( level.autoTitanUnusedNames.len() > 0 )
    {
        local name = level.autoTitanUnusedNames.remove( level.autoTitanUnusedNames.len() - 1 )
        printt( "[AutoTitan] Using new name", name, "for team", team )
        return name
    }
    
    // Fallback: generate unique name
    return format( "Auto Titan %02d", level.autoTitanGuidCounter )
}
function TitanBrawlAuto_ReturnName( name, team )
{
    if ( name == null )
        return
    
    // Check if it's a generated name (fallback)
    if ( name.find( "Auto Titan" ) == 0 )
        return
    
    // Return the name to this team's pool for later reuse
    level.autoTitanNamesByTeam[team].append( name )
    printt( "[AutoTitan] Returned name", name, "to team", team, "pool" )
}

function TitanBrawlAuto_RandomChoice( array )
{
    return array[ RandomInt( array.len() ) ]
}

