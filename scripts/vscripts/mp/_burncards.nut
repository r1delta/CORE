function main()
{
    RegisterSignal("StartBurnCardEffect")
    IncludeScript( "_burncards_shared" );
    IncludeFile( "menu/_burncards_lobby" );
    Globalize( AddBurnCardLevelingPack );
    AddCallback_OnPlayerRespawned( PlayerRespawned )
    AddCallback_OnPlayerKilled( _OnPlayerKilled )
    Globalize(RunBurnCardFunctions)

    AddCallback_OnPilotBecomesTitan( OnTitanBecomesPilot )
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
        wait 5;
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


function DoSummonTitanBurnCard(player, cardRef) {
    ForceTitanBuildComplete(player)
   
    if(cardRef == "bc_summon_atlas") {
        local titanDataTable = GetPlayerClassDataTable( player, "titan" )
	    titanDataTable.playerSetFile = "titan_atlas"
    }
    if(cardRef == "bc_summon_ogre") {
        local titanDataTable = GetPlayerClassDataTable( player, "titan" )
	    titanDataTable.playerSetFile = "titan_ogre"
    }
    if(cardRef == "bc_summon_stryder") {
        local titanDataTable = GetPlayerClassDataTable( player, "titan" )
        titanDataTable.playerSetFile = "titan_stryder"
    }

    player.WaitSignal("CalledInReplacementTitan")
    if(cardRef == "bc_summon_atlas") {
        local titanDataTable = GetPlayerClassDataTable( player, "titan" )
	    titanDataTable.playerSetFile = "titan_atlas"
    }
    if(cardRef == "bc_summon_ogre") {
        local titanDataTable = GetPlayerClassDataTable( player, "titan" )
	    titanDataTable.playerSetFile = "titan_ogre"
    }
    if(cardRef == "bc_summon_stryder") {
        local titanDataTable = GetPlayerClassDataTable( player, "titan" )
        titanDataTable.playerSetFile = "titan_stryder"
    }
    local activeBCID = player.GetPersistentVar("activeBCID")
    
	player.SetActiveBurnCardIndex( -1 )
	player.SetPersistentVar( _GetActiveBurnCardsPersDataPrefix() + "[" + activeBCID + "].cardRef", null )
	player.SetPersistentVar( _GetActiveBurnCardsPersDataPrefix() + "[" + activeBCID + "].clearOnStart", 0 )
    player.SetPersistentVar( "activeBCID", -1 )

}

function RunBurnCardFunctions(player,cardRef) {
    
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
    local cardIndex = GetPlayerBurnCardOnDeckIndex(player);
    local cardRef = player.GetPersistentVar( _GetActiveBurnCardsPersDataPrefix() + "[" + cardIndex + "].cardRef" )
    local idx = GetBurnCardIndexByRef(cardRef);
    if(idx == -1) {
        return;
    }
    player.SetActiveBurnCardIndex(idx);
    player.SetPersistentVar("activeBCID", cardIndex);
    player.SetPersistentVar("onDeckBurnCardIndex", -1);
}

function PlayerRespawned(player) {
    printt("OnPlayerRespawned");

    if(!player) {
        return;
    }

    local cardIndex = GetPlayerBurnCardOnDeckIndex(player);
    local cardRef = player.GetPersistentVar( _GetActiveBurnCardsPersDataPrefix() + "[" + cardIndex + "].cardRef" )
    if(!cardRef) {
        return;
    }
    local idx = GetBurnCardIndexByRef(cardRef);
    if(idx == -1) {
        return;
    }
    player.SetActiveBurnCardIndex(idx);
    player.SetPersistentVar("activeBCID", cardIndex);
    player.SetPersistentVar("onDeckBurnCardIndex", -1);

    

    printt(cardRef);
    player.Signal("StartBurnCardEffect");
    RunBurnCardFunctions(player,cardRef);

    if (cardRef == "bc_cloak_forever") {
        EnableCloakForever( player )
    }

    thread RunSpawnBurnCard(player,cardRef);
}

function RunSpawnBurnCard(player,cardRef) {
    local cardData = GetBurnCardData(cardRef);

    while ( HasCinematicFlag( player, CE_FLAG_INTRO ) || HasCinematicFlag( player, CE_FLAG_CLASSIC_MP_SPAWNING ) || HasCinematicFlag( player, CE_FLAG_WAVE_SPAWNING ) )
		player.WaitSignal( "CE_FLAGS_CHANGED" )

    ChangeOnDeckBurnCardToActive(player,cardRef);

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