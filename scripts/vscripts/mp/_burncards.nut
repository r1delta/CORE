function main()
{
    RegisterSignal("StartBurnCardEffect")
    IncludeScript( "_burncards_shared" );
    IncludeFile( "menu/_burncards_lobby" );
    
    IncludeScript("_ranked_shared")
    Globalize( AddBurnCardLevelingPack );
    AddCallback_OnPlayerRespawned( PlayerRespawned )
    AddCallback_OnPlayerKilled( _OnPlayerKilled )
    Globalize(RunBurnCardFunctions)
    Globalize(ChangeOnDeckBurnCardToActive)
    Globalize(MakeActiveBurnCard)
    AddCallback_OnPlayerRespawned(Ranked_OnPlayerSpawned)
    // AddCallback_OnScoreEvent(Leagues_OnScoreEvent)
    Globalize(BurncardsAutoFillEmptyActiveSlots)

    PrecacheModel("models/Robots/spectre/mcor_spectre.mdl")
    PrecacheModel("models/Robots/spectre/imc_spectre.mdl")
    AddCallback_OnPilotBecomesTitan( OnTitanBecomesPilot )
    AddClientCommandCallback("SetPlayRankedOnInGame", ClientCommand_SetRankedPlayOnInGame)

    // SetOnScoreEventFunc(Leagues_OnScoreEvent)
}


function ClientCommand_SetRankedPlayOnInGame(player) {
    player.SetPersistentVar("ranked.isPlayingRanked",1)
    player.SetIsPlayingRanked(1)
    Remote.CallFunction_NonReplay(player, "ServerCallback_ToggleRankedInGame", true)
    Remote.CallFunction_Replay(player, "SCB_SetUserPerformance",0)
    printt("Set ranked play on in game: " + player.IsPlayingRanked())
    return true
}

function BurncardsAutoFillEmptyActiveSlots( player )
{
    local maxActive = GetPlayerMaxActiveBurnCards( player )
    for ( local i = 0; i < maxActive; i++ )
    {
        if ( !GetPlayerActiveBurnCardSlotContents( player, i ) )
        {
            local cardIndex = GetPlayerBurnCardOnDeckIndex( player )
            if ( cardIndex != -1 )
            {
                MoveCardToActiveSlot( player, cardIndex, i )
            }
        }
    }
}

function WaitForTitanActiveWeapon( titan ) {
    titan.EndSignal( "OnDestroy" )
    local weapon = null
    while (1) {
        wait 0
        weapon = titan.GetActiveWeapon()
        if(weapon) {
            break;
        }
    }
    return weapon
}

function WaitForPlayerActiveWeapon( player,className = null )
{
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "Disconnected" )

	local weapon = null

	while ( 1 )
	{
		wait 0
		weapon = player.GetActiveWeapon()

		if( weapon )
		{
			if( className )
			{
				if ( weapon.GetClassname() == className )
					break;
			}
			else
				break;
		}
	}

	return weapon
}

function RefillWeaponAmmo(player) {

    player.EndSignal( "OnDestroy" )
	player.EndSignal( "Disconnected" )
    if(!player) {
        return;
    }
    while (1) {
        if(player.IsTitan()) {
            player.WaitSignal("OnLeftTitan")
        }
        local cardRef = GetPlayerActiveBurnCard( player );
        if(!cardRef) {
            return;
        }
        local cardData = GetBurnCardData(cardRef);
        if(!(cardData.ctFlags & CT_FRAG)) {
            return;
        }
        local offhand = player.GetOffhandWeapon( 0 )
		if ( offhand )
		{
            local currentAmmo = offhand.GetWeaponPrimaryClipCount()
            if(currentAmmo != 2) {
		        offhand.SetWeaponPrimaryClipCount( currentAmmo + 1 )
            }
		}	        
        wait 8;
    }
} 


function RunWeaponFunction(player,cardRef) {
    if(!IsAlive(player)) {
        return;
    }
    player.EndSignal( "OnDestroy" )
    player.EndSignal( "Disconnected" )
    player.EndSignal("EndGiveLoadouts")
    while ( HasCinematicFlag( player, CE_FLAG_INTRO ) || HasCinematicFlag( player, CE_FLAG_CLASSIC_MP_SPAWNING ) || HasCinematicFlag( player, CE_FLAG_WAVE_SPAWNING ) )
		player.WaitSignal( "CE_FLAGS_CHANGED" )
    local cardData = GetBurnCardData(cardRef);
    local weaponData = GetBurnCardWeapon(cardRef);
    local weapons = player.GetMainWeapons()
    if(player.IsTitan())
        return;
    if(weaponData.weaponType == "OFFHAND0" || weaponData.weaponType == "OFFHAND1") {
        Assert( IsAlive( player ) )
        local weapons = player.GetOffhandWeapons()
        local weaponToTake = null;
        local slot = 0;
        switch (weaponData.weaponType) {
            case "OFFHAND0":
                weaponToTake = weapons[0];
                slot = 0;
                break;
            case "OFFHAND1":
                weaponToTake = weapons[1];
                slot = 1;
                break;
            default:
                break;
        }
        player.TakeOffhandWeapon(slot);
        WaitForPlayerActiveWeapon(player);
        player.GiveOffhandWeapon(weaponData.weapon, slot, weaponData.mods);
        if(cardData.ctFlags & CT_FRAG) {
            thread RefillWeaponAmmo(player)
        }
        return
    }

if(cardData.ctFlags & CT_WEAPON) {
    local weaponToTake = null;
    if(player.IsTitan())
        return;
    switch (weaponData.weaponType) {
        case "PRIMARY":
            weaponToTake = weapons[0];
            break;
        case "SIDEARM":
            weaponToTake = weapons[1];
            break;
        case "SECONDARY":
            weaponToTake = weapons[2];
            break;
        default:
            break;
    }
    player.TakeWeapon(weaponToTake.GetClassname());
    WaitForPlayerActiveWeapon(player);
    player.GiveWeapon(weaponData.weapon, weaponData.mods);
    player.SetActiveWeapon(weaponData.weapon);   
    }
}

function MakeActiveBurnCard(player,index) {
    if (index == null || index < 0 || index >= MAX_BURN_CARDS)
		return false
	local cardRef = GetBurnCardFromSlot(player, index)
	local cardIndex = GetBurnCardIndexByRef(cardRef)
	printt("ActivateBurnCard Change: ", cardRef)
	player.SetPersistentVar( "activeBCID", index )
	player.SetActiveBurnCardIndex(cardIndex)
	player.SetPersistentVar("onDeckBurnCardIndex", -1);
    foreach( p in GetPlayerArray() ) {
        Remote.CallFunction_Replay(p,"ServerCallback_PlayerUsesBurnCard", player.GetEncodedEHandle(), cardIndex ,false)
    }
    return true;
}

function DoSummonTitanBurnCard(player, cardRef) {
    
    
    while ( HasCinematicFlag( player, CE_FLAG_INTRO ) || HasCinematicFlag( player, CE_FLAG_CLASSIC_MP_SPAWNING ) || HasCinematicFlag( player, CE_FLAG_WAVE_SPAWNING ) )
		player.WaitSignal( "CE_FLAGS_CHANGED" )

    ForceTitanBuildComplete(player)
    local titanDataTable = GetPlayerClassDataTable( player, "titan" )
    local oldSetFile = titanDataTable.playerSetFile
    if(cardRef == "bc_summon_atlas") {
	    titanDataTable.playerSetFile = "titan_atlas"
    }
    if(cardRef == "bc_summon_ogre") {
	    titanDataTable.playerSetFile = "titan_ogre"
    }
    if(cardRef == "bc_summon_stryder") {
        titanDataTable.playerSetFile = "titan_stryder"
    }
    player.WaitSignal("CalledInReplacementTitan")
    if (oldSetFile) {
        titanDataTable.playerSetFile = oldSetFile
    }
    local activeBCID = player.GetPersistentVar("activeBCID")
	player.SetActiveBurnCardIndex( -1 )
	player.SetPersistentVar( _GetActiveBurnCardsPersDataPrefix() + "[" + activeBCID + "].cardRef", null )
	player.SetPersistentVar( _GetActiveBurnCardsPersDataPrefix() + "[" + activeBCID + "].clearOnStart", 0 )
    player.SetPersistentVar( "activeBCID", -1 )

}

function RunBurnCardFunctions(player,cardRef) {
    thread RunSpawnBurnCard(player,cardRef);
    local cardData = GetBurnCardData(cardRef);
    if(cardData.serverFlags) {
        printt("Card has server flags");
        GiveServerFlag(player, cardData.serverFlags);
    }
    local weaponData = GetBurnCardWeapon(cardRef);
    if(cardData.group == BCGROUP_WEAPON || (weaponData && weaponData.weapon)) {
        thread RunWeaponFunction(player,cardRef);
    }

    if(cardRef == "bc_summon_atlas") {
        thread DoSummonTitanBurnCard(player, cardRef);
    }
    if(cardRef == "bc_summon_ogre") {
        thread DoSummonTitanBurnCard(player, cardRef);
    }
    if(cardRef == "bc_summon_stryder") {
        thread DoSummonTitanBurnCard(player, cardRef);
    }
    
}


function ChangeOnDeckBurnCardToActive(player) {
    if(!player) {
        return;
    }
    local cardIndex = GetPlayerBurnCardOnDeckIndex(player);
    if(cardIndex == -1) {
        return;
    }
    local cardRef = player.GetPersistentVar( _GetActiveBurnCardsPersDataPrefix() + "[" + cardIndex + "].cardRef" )
    if(!cardRef) {
        return;
    }
    local idx = GetBurnCardIndexByRef(cardRef);
    if(idx == -1 || !cardRef || idx == null) {
        return;
    }
    player.SetActiveBurnCardIndex(idx);
    player.SetPersistentVar("activeBCID", cardIndex);
    player.SetPersistentVar("onDeckBurnCardIndex", -1);
    foreach( p in GetPlayerArray() ) {
        Remote.CallFunction_Replay(p,"ServerCallback_PlayerUsesBurnCard", player.GetEncodedEHandle(), idx ,false)
    }

}

function PlayerRespawned(player) {    
    if(!player) {
        return;
    }

    // for(local i = 0; i < 50; i++) {
    //     player.SetPersistentVar("ranked.gems" + "[" + i + "].gemState", "gem_captured")
    //     player.SetPersistentVar("ranked.gems" + "[" + i + "].gemScore", 100)
    // }

    local cardIndex = GetPlayerBurnCardOnDeckIndex(player);
    local cardRef = player.GetPersistentVar( _GetActiveBurnCardsPersDataPrefix() + "[" + cardIndex + "].cardRef" )
    if(!cardRef) {
        return;
    }
    ChangeOnDeckBurnCardToActive(player);
    printt(cardRef);
    player.Signal("StartBurnCardEffect");
    local cardData = GetBurnCardData(cardRef);
    // card data ... check rarity and stuf
    if(cardData.rarity == BURNCARD_RARE) {
        AddPlayerScore(player,"UsedBurnCard_Rare")
    }
    else {
        AddPlayerScore(player,"UsedBurnCard_Common")
    }
    Stats_IncrementStat(player,"misc_stats","burnCardsSpent",1)
    RunBurnCardFunctions(player,cardRef);  
}

function RunSpawnBurnCard(player,cardRef) {
    local cardData = GetBurnCardData(cardRef);

    while ( HasCinematicFlag( player, CE_FLAG_INTRO ) || HasCinematicFlag( player, CE_FLAG_CLASSIC_MP_SPAWNING ) || HasCinematicFlag( player, CE_FLAG_WAVE_SPAWNING ) )
	{
        player.WaitSignal( "CE_FLAGS_CHANGED" )
    }

    if (cardRef == "bc_cloak_forever") {
        EnableCloakForever( player )
    }

    if (cardRef == "bc_sonar_forever") {
        ActivateBurnCardSonar(player, 9999)
    }
    if(cardRef == "bc_play_spectre") {
        local pilotDataTable = GetPlayerClassDataTable( player, level.pilotClass )
	    local pilotSettings = pilotDataTable.playerSetFile
	    pilotSettings = "pilot_spectre" 
        player.SetPlayerSettings( pilotSettings )
	    player.SetPlayerPilotSettings( pilotSettings )
    }
    if(cardRef == "bc_auto_sonar") {
        // ActivateBurnCardSonar(player, BURNCARD_AUTO_SONAR_IMAGE_DURATION , true,null, BURNCARD_AUTO_SONAR_INTERVAL)
        // thread LoopSonarAudioPing(player)
    }


    // ChangeOnDeckBurnCardToActive(player);

    if( cardData.lastsUntil == BC_NEXTSPAWN) {
        if(cardRef == "bc_free_build_time_1") {
            DecrementBuildTimer(player,40)
            StopActiveBurnCard(player);
        }
        if(cardRef == "bc_free_build_time_2") {
            DecrementBuildTimer(player,80)
            StopActiveBurnCard(player);
        }
       
    }

}

function _OnPlayerKilled (player,attacker) {

    if(!player) {
        return;
    }

    if(!attacker) {
        return;
    }

    local cardRef = GetPlayerActiveBurnCard( player );
    if(!cardRef) {
        return;
    }

    local cardData = GetBurnCardData(cardRef);

    if ( player.IsPlayer() )
	 	BurnCardOnDeath( player, attacker, BC_NEXTDEATH )

    if(cardRef == "bc_rematch") {
        StopActiveBurnCard(player);
    }
}

function ApplyTitanWeaponBurnCard(player,titan_npc,cardRef) {
    local cardData = GetBurnCardData(cardRef);
    if(cardData.ctFlags & CT_TITAN_WPN) {
        Assert( IsValid( titan ) )
        local weaponToTake = null;
	    local soul = player.GetTitanSoul()
        if(!soul) {
            return;
        }
        local titan = soul.GetTitan()
        if(!titan) {
            return;
        }
        local weaponData = GetBurnCardWeapon(cardRef);
	    local weapons = titan.GetMainWeapons()
        foreach(weapon in weapons) {
            printt(weapon.GetClassname());
            weaponToTake = weapon;
        }
        switch (weaponData.weaponType) {
        case "TITAN_PRIMARY":
            titan.TakeWeapon(weaponToTake.GetClassname());
            titan.GiveWeapon(weaponData.weapon, weaponData.mods);
            break;
        case "TITAN_OFFHAND0":
            printt("Ordnance weapon");
            titan.TakeOffhandWeapon(0);
            wait 0.1;
            titan.GiveOffhandWeapon(weaponData.weapon, 0, weaponData.mods);
            break;
        case "TITAN_OFFHAND1":
            printt("Special weapon");
            titan.TakeOffhandWeapon(1);
            wait 0.1;
            titan.GiveOffhandWeapon(weaponData.weapon, 1, weaponData.mods);
            break;
        default:
            break;
    }
        return
    }
}

function OnTitanBecomesPilot(player,titan) {

    if(!player) {
        return;
    }

    if(DoesPlayerHaveActiveTitanBurnCard(player)) {
        local cardRef = GetPlayerActiveBurnCard( player );
        thread ApplyTitanWeaponBurnCard(player,titan,cardRef);
        return;
    }


}



function AddBurnCardLevelingPack( cardPackName, cardPackArray )
{
    // printt( "Hit stubbed call to AddBurnCardLevelingPack" );
}

function Ranked_OnPlayerSpawned(player)
{   
    if(!player) {
        return
    }
    printt("ranked is playing ranked" + player.GetPersistentVar("ranked.isPlayingRanked"))
    // local currentSkill = GetPlayerPerformanceGoals(player)

    if(player.GetPersistentVar("ranked.isPlayingRanked") == 1) {
         player.SetIsPlayingRanked(1)
        //  local amount = PersistenceGetArrayCount("ranked.gems")
        //  printt("amount", amount)
        //  local rank = GetGemsToRank(amount);
        //  printt("rank", rank)
        //  player.SetRank(rank)
         Remote.CallFunction_NonReplay( player, "SCB_SetUserPerformance", 5 )
        
    }

    SetOnScoreEventFunc(Leagues_OnScoreEvent)
    SetUIVar("rankEnableMode", eRankEnabledModes.ALLOWED_DURING_PERSONAL_GRACE_PERIOD)
}


function Leagues_OnScoreEvent(player,scoreEvent) {
    
    
}