function main()
{
    RegisterSignal("StartBurnCardEffect")
    IncludeScript( "_burncards_shared" );
    IncludeFile( "menu/_burncards_lobby" );
    Globalize( AddBurnCardLevelingPack );
    AddCallback_OnPlayerRespawned( BCPlayerRespawned )
    AddCallback_OnPlayerKilled( BCOnPlayerKilled )
    Globalize( RunBurnCardFunctions)
    Globalize( ChangeOnDeckBurnCardToActive )
    Globalize( ApplyTitanBurnCards_Threaded )
    PrecacheModel( MILITIA_SPECTRE_MODEL )
    PrecacheModel( IMC_SPECTRE_MODEL )
    AddCallback_OnClientConnected( BCOnClientConnected )
}

function BCOnClientConnected( player )
{
    player.SetPersistentVar("activeBCID", -1)
    player.SetPersistentVar("onDeckBurnCardIndex", -1)

    for ( local i = 0; i < GetPlayerMaxActiveBurnCards( player ); i++ )
        player.SetPersistentVar( _GetBurnCardPersPlayerDataPrefix() + ".stashedCardRef[" + i + "]", null )


    if ( player.GetPersistentVar( _GetBurnCardPersPlayerDataPrefix() + ".autofill" ) && !IsLobby() )
	{
		thread BurncardsAutoFillEmptyActiveSlots( player )
		ChangedPlayerBurnCards( player )
	}
}

function MoveCardToActiveSlot( player, burnCardIndex, index, activeSlot )
{
	burnCardIndex = burnCardIndex.tointeger()
	if ( burnCardIndex < 0 )
		return true
	if ( burnCardIndex >= level.indexToBurnCard.len() )
		return true
	local burnCardRef = level.indexToBurnCard[ burnCardIndex ]

	index = index.tointeger()
	activeSlot = activeSlot.tointeger()
	local deck = GetPlayerBurnCardDeck( player )
	if ( index < 0 )
		return true
	if ( index >= deck.len() )
		return true

	local cardRef = deck[ index ].cardRef
	if ( cardRef == null )
		return true

	if ( burnCardRef != cardRef )
	{
		printt( "MoveCardToDeck failed, tried to move " + burnCardRef + " but found " + cardRef )
		return true
	}

	if ( activeSlot < 0 )
		return true
	if ( activeSlot >= GetPlayerMaxActiveBurnCards( player ) )
		return true

	local pileActiveBurncard = GetPlayerActiveBurnCardSlotContents( player, activeSlot )
	SetPlayerActiveBurnCardSlotContents( player, activeSlot, cardRef, false )
	deck.remove( index )

	if ( pileActiveBurncard != null )
	{
		deck.append( { cardRef = pileActiveBurncard, new = false } )
	}

	FillBurnCardDeckFromArray( player, deck )


    if ( IsLobby() )
	    Remote.CallFunction_UI( player, "SCB_UpdateBCFooter" )

	return true
}

function BurncardsAutoFillEmptyActiveSlots( player )
{
    while ( !PlayerFullyConnected( player ) )
        wait 0.1

    local maxActive = GetPlayerMaxActiveBurnCards( player )
    for ( local i = 0; i < maxActive; i++ )
    {
        local isEmptySlot = GetPlayerActiveBurnCardSlotContents( player, i )

        if ( isEmptySlot != null )
            continue

        local deck = GetPlayerBurnCardDeck( player )
        local randomCardIndex = RandomInt( deck.len() )
        local cardRef = deck[ randomCardIndex ].cardRef
        local index = GetBurnCardIndexByRef( cardRef )

        MoveCardToActiveSlot( player, index, randomCardIndex, i )
    }
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


function ApplyPilotWeaponBurnCards_Threaded( player, cardRef )
{
    player.EndSignal( "OnDestroy" )
    player.EndSignal( "Disconnected" )
    player.EndSignal( "EndGiveLoadouts" )

    while ( player.IsTitan() )
        player.WaitSignal("OnLeftTitan"); wait 0.5

    local cardData = GetBurnCardData(cardRef);
    local weaponData = GetBurnCardWeapon(cardRef);
    local weapons = player.GetMainWeapons()

    if( !weapons || !weaponData )
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

        while ( !IsValid( weaponToTake ) )
            wait 0.1

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

function DoSummonTitanBurnCard( player, cardRef )
{
    local cardData = GetBurnCardData(cardRef)

    if ( cardData.ctFlags & CT_TITAN && cardData.group != BCGROUP_BONUS )
        return

    StartTitanBuildProgress( player, true )

    local titanDataTable = GetPlayerClassDataTable( player, "titan" )
    local oldSetFile = titanDataTable.playerSetFile

    switch( cardRef )
    {
        case "bc_summon_atlas":
            titanDataTable.playerSetFile = "titan_atlas"
            break
        case "bc_summon_ogre":
            titanDataTable.playerSetFile = "titan_ogre"
            break
        case "bc_summon_stryder":
            titanDataTable.playerSetFile = "titan_stryder"
            break
    }

    player.WaitSignal("CalledInReplacementTitan")
    StopActiveBurnCard( player )
    if (oldSetFile) {
        player.WaitSignal("titan_impact")
        // printt("Setting titan data table back to: " + oldSetFile)
        titanDataTable.playerSetFile = oldSetFile
    }
}

function RunBurnCardFunctions( player, cardRef )
{
    thread RunSpawnBurnCard( player, cardRef )
    local cardData = GetBurnCardData( cardRef )
    if(cardData.serverFlags)
        GiveServerFlag( player, cardData.serverFlags)

    local weaponData = GetBurnCardWeapon( cardRef )

    if ( cardData.ctFlags & CT_TITAN_WPN )
    {
        local titan = player.GetTitan()
        if ( titan )
            thread ApplyTitanBurnCards_Threaded( titan )
    }

    if ( cardData.ctFlags & CT_WEAPON || cardData.ctFlags & CT_FRAG )
        thread ApplyPilotWeaponBurnCards_Threaded( player, cardRef )

    if ( cardData.ctFlags & CT_TITAN && cardData.group == BCGROUP_BONUS )
        thread DoSummonTitanBurnCard( player, cardRef )
}

// account for edge cases where it makes no sense to actually use the card
function IsBurnCardEdgeCaseUseValid( player, cardRef )
{
    local cardData = GetBurnCardData( cardRef )

    if ( cardData.ctFlags & CT_TITAN )
    {
        // no point using titan bcs if they're disabled
        if ( Riff_TitanAvailability() == eTitanAvailability.Never )
            return false

        if ( Riff_TitanAvailability() == eTitanAvailability.Once )
        {
            // titan is out, so might be valid in grace or intro
            if ( player.IsTitan() )
                return true
            
            // most likely lost titan in grace or in pilot skirmish
            if ( player.IsTitanBuildStarted() == false )
                return false
        }
    }

    if ( cardData.ctFlags & CT_GRUNT )
    {
        if ( Riff_AllowNPCs() == eAllowNPCs.None || 
             Riff_AllowNPCs() == eAllowNPCs.SpectreOnly )
            return false
    }

    if ( cardData.ctFlags & CT_SPECTRE )
    {
        if ( Riff_AllowNPCs() == eAllowNPCs.None || 
             Riff_AllowNPCs() == eAllowNPCs.GruntOnly )
            return false
    }

    return true
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


    if(cardData.rarity == BURNCARD_RARE)
        AddPlayerScore( player, "UsedBurnCard_Rare" )
    else
        AddPlayerScore( player, "UsedBurnCard_Common" )

    Stats_IncrementStat( player, "misc_stats", "burnCardsSpent", 1 )

    player.SetActiveBurnCardIndex( idx )
    player.SetPersistentVar( "activeBCID", cardIndex )
    player.SetPersistentVar( "onDeckBurnCardIndex", -1 )

    if(cardData.lastsUntil != BC_FOREVER)
        player.SetPersistentVar( _GetActiveBurnCardsPersDataPrefix() + "[" + cardIndex + "].cardRef", null )

    SetPlayerLastActiveBurnCardFromSlot(player, cardIndex, cardRef)

    foreach( p in GetPlayerArray() )
        Remote.CallFunction_Replay( p, "ServerCallback_PlayerUsesBurnCard", player.GetEncodedEHandle(), idx, false )
}

function RollTheDice( player, cardRef )
{
    printt("RollTheDice")

    local card = GetPlayerBurnCardFromDeck( player, RandomInt(100) )
    if(!card)
        return

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

function BCPlayerRespawned( player )
{
    thread BurnCardPlayerRespawned_Threaded( player )
}

function BurnCardPlayerRespawned_Threaded( player )
{
    local cardRef
    local cardIndex
    local cardData

    while ( HasCinematicFlag( player, CE_FLAG_INTRO ) || HasCinematicFlag( player, CE_FLAG_CLASSIC_MP_SPAWNING ) || HasCinematicFlag( player, CE_FLAG_WAVE_SPAWNING ) )
        player.WaitSignal( "CE_FLAGS_CHANGED" )

    printt( "BurnCardPlayerRespawned_Threaded" )

    if ( GetPlayerBurnCardActiveSlotID( player ) >= 0 )
    {
        cardIndex = GetPlayerBurnCardActiveSlotID( player )
        cardRef = GetActiveBurnCard( player )

        if( !cardRef )
            return

        if ( !IsBurnCardEdgeCaseUseValid( player, cardRef ) )
            return

        printt( "BurnCardPlayerRespawned_Threaded cardRef: " + cardRef )

        cardData = GetBurnCardData(cardRef)
    }
    else
    {
        cardIndex = GetPlayerBurnCardOnDeckIndex(player)
        cardRef = GetBurnCardFromSlot( player, cardIndex )

        if( !cardRef )
            return

        if ( !IsBurnCardEdgeCaseUseValid( player, cardRef ) )
            return

        cardData = GetBurnCardData(cardRef)

        if ( GetBurnCardLastsUntil( cardRef ) != BC_NEXTTITANDROP  )
            ChangeOnDeckBurnCardToActive( player )
    }

    if ( GetBurnCardLastsUntil( cardRef ) == BC_NEXTTITANDROP )
        return

    while ( !IsValid( player ) || IsValid( player.isSpawning ) )
        wait 0.1

    RunBurnCardFunctions( player, cardRef )
}

function RunSpawnBurnCard(player,cardRef)
{
    OnSpawned_GivePassiveLifeLong_Pilot( player )

    switch( cardRef )
    {
        case "bc_cloak_forever":
            EnableCloakForever( player )
            break
        case "bc_sonar_forever":
            ActivateBurnCardSonar( player, 9999 )
            break
        case "bc_play_spectre":
            if ( player.IsTitan() )
                player.WaitSignal( "OnLeftTitan" ); wait 0.5

            local pilotDataTable = GetPlayerClassDataTable( player, level.pilotClass )
            local pilotSettings = pilotDataTable.playerSetFile
            pilotSettings = "pilot_spectre"
            player.SetPlayerSettings( pilotSettings )
            player.SetPlayerPilotSettings( pilotSettings )
            break
        case "bc_auto_sonar":
            thread BCAutoSonarLoop( player )
            break
        case "bc_minimap_scan":
            ScanMinimapUntilDeath(player)
            break
        case "bc_dice_ondeath":
            thread RollTheDice( player, cardRef )
            break
        case "bc_free_build_time_1":
            DecrementBuildTimer( player, 40 )
            StopActiveBurnCard( player )
            break
        case "bc_free_build_time_2":
            DecrementBuildTimer(player, 80 )
            StopActiveBurnCard( player )
            break
    }
}

function BCAutoSonarLoop( player )
{
    player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "Disconnected" )

    thread LoopSonarAudioPing( player )

    for( ;; )
    {
        ActivateBurnCardSonar( player, BURNCARD_AUTO_SONAR_IMAGE_DURATION , true, null )
        wait BURNCARD_AUTO_SONAR_INTERVAL
    }
}

function BCOnPlayerKilled( player,attacker )
{
    local cardRef = GetPlayerActiveBurnCard( player )

    if( !cardRef )
        return

    local lastsUntil = GetBurnCardLastsUntil( cardRef )

    if( IsRoundBased() && !GamePlayingOrSuddenDeath() )
        return

    BurnCardOnDeath( player, attacker, BC_NEXTDEATH )

    if ( lastsUntil == BC_NEXTTITANDROP || cardRef == "bc_rematch" )
        StopActiveBurnCard( player )
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
                    titan.TakeOffhandWeapon(0)
                    wait 0.1;
                    titan.GiveOffhandWeapon(weaponData.weapon, 0, weaponData.mods)
                    break;
                case "TITAN_OFFHAND1":
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
    while ( !IsValid( player ) && !titan.IsPlayer()  )
        wait 0.1
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
        ref = GetPlayerActiveBurnCard( player )
    else
    {
        local index = GetPlayerBurnCardOnDeckIndex( player )
        ref = GetBurnCardFromSlot( player, index )
    }

    if ( !ref )
        return

    local cardData = GetBurnCardData( ref )

    if ( DoesPlayerHaveActiveTitanBurnCard( player ) )
        return

    if ( GetBurnCardLastsUntil( ref ) == BC_NEXTTITANDROP )
    {
        if ( !IsBurnCardEdgeCaseUseValid( player, cardRef ) )
            return

        ChangeOnDeckBurnCardToActive( player )
        local cardData = GetBurnCardData( ref )

        if(cardData.serverFlags)
            GiveServerFlag( player, cardData.serverFlags)

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
