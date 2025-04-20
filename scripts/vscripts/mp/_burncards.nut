function main()
{
    RegisterSignal("StartBurnCardEffect")
    IncludeScript( "_burncards_shared" );
    IncludeFile( "menu/_burncards_lobby" );
    Globalize( AddBurnCardLevelingPack );
    AddCallback_OnPlayerRespawned( PlayerRespawned )
    AddCallback_OnPlayerKilled( _OnPlayerKilled )
    Globalize(RunBurnCardFunctions)
    Globalize(ChangeOnDeckBurnCardToActive)
    Globalize( BurnCardIntro )
    Globalize(BurncardsAutoFillEmptyActiveSlots)
    Globalize( ApplyTitanBurnCards_Threaded )
    PrecacheModel("models/Robots/spectre/mcor_spectre.mdl")
    PrecacheModel("models/Robots/spectre/imc_spectre.mdl")
    AddCallback_OnClientConnected( BurnCard_OnClientConnected )
}

function BurnCard_OnClientConnected( player )
{
    player.SetPersistentVar("activeBCID", -1)
    player.SetPersistentVar("onDeckBurnCardIndex", -1)
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
		wait 0.1
		weapon = player.GetActiveWeapon()

		if( weapon )
		{
			if( className )
			{
				if ( weapon.GetClassname() == className )
					break
			}
			else
				break
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


function RunWeaponFunction( player, cardRef )
{
    player.EndSignal( "OnDestroy" )
    player.EndSignal( "Disconnected" )
    player.EndSignal( "EndGiveLoadouts" )

    while ( HasCinematicFlag( player, CE_FLAG_INTRO ) || HasCinematicFlag( player, CE_FLAG_CLASSIC_MP_SPAWNING ) || HasCinematicFlag( player, CE_FLAG_WAVE_SPAWNING ) )
		player.WaitSignal( "CE_FLAGS_CHANGED" )

    // while ( GetGameState() < eGameState.Playing && !IsAlive( player ) )
    //     wait 0.1

    local cardData = GetBurnCardData(cardRef);
    local weaponData = GetBurnCardWeapon(cardRef);
    local weapons = player.GetMainWeapons()

    if(!weapons)
        return
    if(!weaponData)
        return
    if(player.IsTitan())
        return

    if( weaponData.weaponType == "OFFHAND0" || weaponData.weaponType == "OFFHAND1" )
    {
        Assert( IsAlive( player ) )

        local weapons = player.GetOffhandWeapons()
        local weaponToTake = null
        local slot = 0

        switch (weaponData.weaponType) {
            case "OFFHAND0":
                weaponToTake = weapons[0]
                slot = 0
                break
            case "OFFHAND1":
                weaponToTake = weapons[1]
                slot = 1;
                break
            default:
                break
        }

        WaitForPlayerActiveWeapon( player )

        player.TakeOffhandWeapon( slot )

        player.GiveOffhandWeapon( weaponData.weapon, slot, weaponData.mods )

        if( cardData.ctFlags & CT_FRAG )
            thread RefillWeaponAmmo( player )

        return
    }

    if(cardData.ctFlags & CT_WEAPON)
    {
        local weaponToTake = null;

        switch ( weaponData.weaponType )
        {
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

        printt( "Weapon to take: ", weaponToTake.GetClassname() )

        WaitForPlayerActiveWeapon( player );

        player.TakeWeapon( weaponToTake.GetClassname() )

        wait 0.1

        while ( true )
        {
            try
            {
                player.GiveWeapon(weaponData.weapon, weaponData.mods, true)
            } catch (e)
            {
                wait 0.1
                continue
            }

            break
        }

        wait 0.1

        player.SetActiveWeapon(weaponData.weapon)
    }
}

function DoSummonTitanBurnCard(player, cardRef)
{
    while ( HasCinematicFlag( player, CE_FLAG_INTRO ) || HasCinematicFlag( player, CE_FLAG_CLASSIC_MP_SPAWNING ) || HasCinematicFlag( player, CE_FLAG_WAVE_SPAWNING ) )
		player.WaitSignal( "CE_FLAGS_CHANGED" )

    ForceTitanBuildComplete(player)

    local titanDataTable = GetPlayerClassDataTable( player, "titan" )
    local oldSetFile = titanDataTable.playerSetFile

    if(cardRef == "bc_summon_atlas")
	    titanDataTable.playerSetFile = "titan_atlas"
    if(cardRef == "bc_summon_ogre")
	    titanDataTable.playerSetFile = "titan_ogre"
    if(cardRef == "bc_summon_stryder")
        titanDataTable.playerSetFile = "titan_stryder"

    player.WaitSignal("CalledInReplacementTitan")

    if (oldSetFile)
        titanDataTable.playerSetFile = oldSetFile

    local activeBCID = player.GetPersistentVar("activeBCID")

	player.SetActiveBurnCardIndex( -1 )
	player.SetPersistentVar( _GetActiveBurnCardsPersDataPrefix() + "[" + activeBCID + "].cardRef", null )
	player.SetPersistentVar( _GetActiveBurnCardsPersDataPrefix() + "[" + activeBCID + "].clearOnStart", 0 )
    player.SetPersistentVar( "activeBCID", -1 )

}

function RunBurnCardFunctions( player, cardRef )
{
    thread RunSpawnBurnCard( player, cardRef )
    local cardData = GetBurnCardData( cardRef )
    if(cardData.serverFlags)
        GiveServerFlag( player, cardData.serverFlags)

    local weaponData = GetBurnCardWeapon( cardRef )



    if ( cardData.group == BCGROUP_WEAPON || ( weaponData && weaponData.weapon ) )
        thread RunWeaponFunction(player,cardRef)

    if ( cardRef == "bc_summon_atlas" || cardRef == "bc_summon_ogre" || cardRef == "bc_summon_stryder" )
        thread DoSummonTitanBurnCard(player, cardRef)
}

function ChangeOnDeckBurnCardToActive( player )
{
    local cardIndex = GetPlayerBurnCardOnDeckIndex( player )

    if( cardIndex == -1 )
        return

    local cardRef = player.GetPersistentVar( _GetActiveBurnCardsPersDataPrefix() + "[" + cardIndex + "].cardRef" )

    local idx = GetBurnCardIndexByRef( cardRef )

    if ( idx == -1 || idx == null )
        return

    local cardData = GetBurnCardData(cardRef)



    player.SetActiveBurnCardIndex( idx )
    player.SetPersistentVar( "activeBCID", cardIndex )
    player.SetPersistentVar( "onDeckBurnCardIndex", -1 )
    if(cardData.lastsUntil != BC_FOREVER)
    {
        player.SetPersistentVar( _GetActiveBurnCardsPersDataPrefix() + "[" + cardIndex + "].cardRef", null )
    }
    SetPlayerLastActiveBurnCardFromSlot(player, cardIndex, cardRef)
    foreach( p in GetPlayerArray() )
        Remote.CallFunction_Replay( p, "ServerCallback_PlayerUsesBurnCard", player.GetEncodedEHandle(), idx, false )

}

function BurnCardIntro( player )
{
    thread BurnCardIntro_Threaded( player )
}

function RollTheDice( player, cardRef )
{
   printt("RollTheDice")

    local card =GetPlayerBurnCardFromDeck( player, RandomInt(100) )
    if(!card) {
        return;
    }
    printt("RollTheDice card: " + card.cardRef)
    SetPlayerStashedCardRef( player, card.cardRef,0 )
    SetPlayerStashedCardTime( player, 90,0 )
    local idx = GetBurnCardIndexByRef( card.cardRef )
    player.SetActiveBurnCardIndex( idx )
    player.SetPersistentVar( "activeBCID", 0 )
    player.SetPersistentVar( "onDeckBurnCardIndex", -1 )
    SetPlayerActiveBurnCardSlotContents(player, 0, card.cardRef, false )
    SetPlayerLastActiveBurnCardFromSlot(player, 0, card.cardRef)

    // stash the dice card
    local cardData = GetBurnCardData(cardRef)
    SetPlayerStashedCardRef( player, "bc_dice_ondeath",0 )
    SetPlayerStashedCardTime( player, 90,0 )
}

function BurnCardIntro_Threaded( player )
{
    while ( HasCinematicFlag( player, CE_FLAG_INTRO ) || HasCinematicFlag( player, CE_FLAG_CLASSIC_MP_SPAWNING ) || HasCinematicFlag( player, CE_FLAG_WAVE_SPAWNING ) )
        player.WaitSignal( "CE_FLAGS_CHANGED" )

    while ( GetGameState() < eGameState.Playing && !IsAlive( player ) )
        wait 0.1

    player.Signal( "StartBurnCardEffect" )

    local cardIndex = GetPlayerBurnCardOnDeckIndex(player)
    local cardRef = player.GetPersistentVar( _GetActiveBurnCardsPersDataPrefix() + "[" + cardIndex + "].cardRef" )


    local cardData = GetBurnCardData(cardRef)

    thread RunSpawnBurnCard( player, cardRef )

    if ( GetPlayerBurnCardActiveSlotID( player ) )
        return

    if ( GetBurnCardLastsUntil( cardRef ) == BC_NEXTTITANDROP )
        return

    ChangeOnDeckBurnCardToActive( player )

    printt(cardRef)

    //Stats_IncrementStat( player, "misc_stats", "burnCardsSpent", 1 )

    RunBurnCardFunctions( player, cardRef )
}

function PlayerRespawned( player )
{
    thread BurnCardPlayerRespawned_Threaded( player )
}

function BurnCardPlayerRespawned_Threaded( player )
{
    local cardIndex = GetPlayerBurnCardOnDeckIndex(player)

    local cardRef = player.GetPersistentVar( _GetActiveBurnCardsPersDataPrefix() + "[" + cardIndex + "].cardRef" )

    if( !cardRef )
        return

    if ( GetPlayerBurnCardActiveSlotID( player ) )
        return

    if ( GetBurnCardLastsUntil( cardRef ) == BC_NEXTTITANDROP )
        return

    if(cardRef == "bc_dice_ondeath") {
        thread RollTheDice(player, cardRef)
    }

    ChangeOnDeckBurnCardToActive( player )

    printt(cardRef)

    local cardData = GetBurnCardData(cardRef)

    if(cardData.rarity == BURNCARD_RARE)
        AddPlayerScore( player, "UsedBurnCard_Rare" )
    else
        AddPlayerScore( player, "UsedBurnCard_Common" )

    Stats_IncrementStat( player, "misc_stats", "burnCardsSpent", 1 )

    RunBurnCardFunctions( player, cardRef )
}

function RunSpawnBurnCard(player,cardRef)
{
    local cardData = GetBurnCardData(cardRef);

    while ( HasCinematicFlag( player, CE_FLAG_INTRO ) || HasCinematicFlag( player, CE_FLAG_CLASSIC_MP_SPAWNING ) || HasCinematicFlag( player, CE_FLAG_WAVE_SPAWNING ) )
        player.WaitSignal( "CE_FLAGS_CHANGED" )

    if (cardRef == "bc_cloak_forever")
        EnableCloakForever( player )

    if (cardRef == "bc_sonar_forever")
        ActivateBurnCardSonar( player, 9999 )

    if(cardRef == "bc_play_spectre")
    {
        local pilotDataTable = GetPlayerClassDataTable( player, level.pilotClass )
	    local pilotSettings = pilotDataTable.playerSetFile
	    pilotSettings = "pilot_spectre"
        player.SetPlayerSettings( pilotSettings )
	    player.SetPlayerPilotSettings( pilotSettings )
    }

    if(cardRef == "bc_auto_sonar")
    {
        // ActivateBurnCardSonar(player, BURNCARD_AUTO_SONAR_IMAGE_DURATION , true,null, BURNCARD_AUTO_SONAR_INTERVAL)
        // thread LoopSonarAudioPing(player)
    }

    if(cardRef == "bc_dice_ondeath") {
        thread RollTheDice(player, cardRef)
        return
    }

    // ChangeOnDeckBurnCardToActive(player);

    if( cardData.lastsUntil == BC_NEXTSPAWN)
    {
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

function _OnPlayerKilled (player,attacker)
{
    local cardRef = GetPlayerActiveBurnCard( player )

    if(!cardRef)
        return

    local lastsUntil = GetBurnCardLastsUntil( cardRef )

    if ( lastsUntil == BC_NEXTTITANDROP || cardRef == "bc_rematch" )
        StopActiveBurnCard( e.player )
}

function ApplyTitanWeaponBurnCard( titan, cardRef )
{
    local cardData = GetBurnCardData(cardRef);
    local weaponToTake = null
    local weaponData = GetBurnCardWeapon(cardRef)
    local weapons = titan.GetMainWeapons()

    while( weaponToTake == null )
    {
        foreach( weapon in weapons )
        {
            printt( weapon.GetClassname() );
            weaponToTake = weapon;
        }

        if(cardData.ctFlags & CT_TITAN_WPN) {
            Assert( IsValid( titan ) )
            if(!weaponData) {
                return;
            }

            switch (weaponData.weaponType)
            {
                case "TITAN_PRIMARY":
                    titan.TakeWeapon(weaponToTake.GetClassname())
                    wait 0.5;
                    titan.GiveWeapon(weaponData.weapon, weaponData.mods)
                    wait 0.1;
                    titan.SetActiveWeapon(weaponData.weapon)
                    break;
                case "TITAN_OFFHAND0":
                    printt("Ordnance weapon")
                    titan.TakeOffhandWeapon(0)
                    wait 0.1;
                    titan.GiveOffhandWeapon(weaponData.weapon, 0, weaponData.mods)
                    break;
                case "TITAN_OFFHAND1":
                    printt("Special weapon");
                    titan.TakeOffhandWeapon(1);
                    wait 0.1;
                    titan.GiveOffhandWeapon(weaponData.weapon, 1, weaponData.mods)
                    break;
                default:
                    break;
            }
            return
        }

        wait 0.1
    }
}

function ApplyTitanBurnCards_Threaded( titan )
{
    local player = titan.GetBossPlayer()

    local isSpawning = IsValid( player.isSpawning )

    if ( isSpawning )
    {
        while ( true )
        {
            if ( player.IsTitan() && IsAlive( player ) )
                break
            wait 0.1
        }
    } else
    {
        while ( true )
        {
            if ( IsValid( titan ) )
                break
            wait 0.1
        }
    }

    local ref

    if ( DoesPlayerHaveActiveTitanBurnCard( player ) )
    {
        ref = GetPlayerActiveBurnCard( player )
    }
    else
    {
        local index = GetPlayerBurnCardOnDeckIndex( player )
        ref = GetBurnCardFromSlot( player, index )
    }

    if ( !ref )
        return

    if ( GetBurnCardLastsUntil( ref ) == BC_NEXTTITANDROP )
    {
        if ( !DoesPlayerHaveActiveTitanBurnCard( player ) )
            ChangeOnDeckBurnCardToActive( player )
        if ( isSpawning )
            ApplyTitanWeaponBurnCard( player, ref )
        else
            ApplyTitanWeaponBurnCard( titan, ref )
    }

    // Remote.CallFunction_NonReplay(player,"ServerCallback_TitanDialogueBurnCardVO")
}



function AddBurnCardLevelingPack( cardPackName, cardPackArray )
{
    // printt( "Hit stubbed call to AddBurnCardLevelingPack" );
}
