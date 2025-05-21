function main()
{
    RegisterSignal("StartBurnCardEffect")
    IncludeScript( "_burncards_shared" );
    IncludeFile( "menu/_burncards_lobby" );
    AddCallback_OnPlayerRespawned( BCPlayerRespawned )
    AddCallback_OnPlayerKilled( BCOnPlayerKilled )
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
    {
        local stashedRef = GetPlayerStashedCardRef( player, i )

        if( stashedRef )
            SetPlayerActiveBurnCardSlotContents( player, i, stashedRef, false )

        player.SetPersistentVar( _GetBurnCardPersPlayerDataPrefix() + ".stashedCardRef[" + i + "]", null )

        local ref = GetBurnCardFromSlot( player, i )

        if ( ref == null )
            continue

        if ( IsLobby() )
            continue

        if ( IsDiceCard( GetBurnCardFromSlot( player, i ) ) )
            thread RollTheDice( player, i )
    }

    if ( player.GetPersistentVar( _GetBurnCardPersPlayerDataPrefix() + ".autofill" ) )
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

    if ( GetPlayerBurnCardDeck( player ).len() == 0 )
        return

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

function RefillWeaponAmmo( player )
{
    player.EndSignal( "OnDestroy" )
	player.EndSignal( "Disconnected" )

    while ( true )
    {
        if( player.IsTitan() )
            player.WaitSignal("OnLeftTitan")

        local cardRef = GetPlayerActiveBurnCard( player )

        if(!cardRef)
            return

        local cardData = GetBurnCardData(cardRef)

        if( !(cardData.ctFlags & CT_FRAG) )
            return

        local offhand = player.GetOffhandWeapon( 0 )
		if ( offhand )
		{
            local currentAmmo = offhand.GetWeaponPrimaryClipCount()
            local maxAmmo = 2

            if ( PlayerHasPassive( player, PAS_ORDNANCE_PACK))
                maxAmmo = 3

            if(currentAmmo != maxAmmo)
		        offhand.SetWeaponPrimaryClipCount( currentAmmo + 1 )
		}

        wait 8
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
                player.GiveWeapon(weaponData.weapon, weaponData.mods, false)
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

function IsAmpedTactical( cardRef )
{
    switch ( cardRef )
    {
        case "bc_super_stim":
            return true
        case "bc_super_cloak":
            return true
        case "bc_super_sonar":
            return true
        default:
            return false
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

    if ( IsAmpedTactical( cardRef ) )
        ApplyAmpedTactical( player, cardRef )

    if ( cardData.ctFlags & CT_TITAN && cardData.group == BCGROUP_BONUS )
        thread DoSummonTitanBurnCard( player, cardRef )
}

function ApplyAmpedTactical( player, cardRef )
{
    if( player.IsTitan() )
        player.WaitSignal("OnLeftTitan"); wait 0.5

    local mods = []

    switch( cardRef )
    {
        case "bc_super_stim":
            mods = [ "bc_super_stim" ]
            break
        case "bc_super_cloak":
            mods = [ "bc_super_cloak" ]
            break
        case "bc_super_sonar":
            mods = [ "bc_super_sonar" ]
            break
    }

    local cardData = GetBurnCardData( cardRef )
    local weaponData = GetBurnCardWeapon( cardRef )

    if( !weaponData )
        return

    if( weaponData.weaponType == "OFFHAND0" || weaponData.weaponType == "OFFHAND1" )
    {
        local weapons = player.GetOffhandWeapons()
        local weaponToTake = null
        local slot = 0

        switch (weaponData.weaponType)
        {
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
        player.GiveOffhandWeapon( weaponData.weapon, slot, mods )
    }
}

// account for edge cases where it makes no sense to actually use the card
function IsBurnCardEdgeCaseUseValid( player, cardRef )
{
    local cardData = GetBurnCardData( cardRef )

    if ( cardData.ctFlags & CT_TITAN || cardData.ctFlags & CT_BUILDTIME )
    {
        if ( Riff_TitanAvailability() == eTitanAvailability.Never )
            return false

        if ( Riff_TitanAvailability() == eTitanAvailability.Once )
        {
            if ( player.IsTitan() || IsValid( player.GetPetTitan() ) )
                return true

            if ( player.IsTitanBuildStarted() == false )
                return false
        }
    }

    // only for buildtime reduction cards
    if ( cardData.ctFlags == CT_BUILDTIME && cardRef != "bc_fast_build_2" )
    {
        if ( player.IsTitanReady() )
            return false

        if ( player.IsTitan() )
            if ( GetTitanCoreTimer( player ) <= 0 )
                return false

        if ( IsValid( player.GetPetTitan() ) )
            if ( GetTitanCoreTimer( player.GetPetTitan() ) <= 0 )
                return false
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

    player.Signal( "StartBurnCardEffect" )

    SetPlayerLastActiveBurnCardFromSlot( player, cardIndex, cardRef )

    foreach( p in GetPlayerArray() )
        Remote.CallFunction_Replay( p, "ServerCallback_PlayerUsesBurnCard", player.GetEncodedEHandle(), idx, false )

    if ( PlayerHasDiceStashed( player, cardIndex ) )
    {
        local deck = GetPlayerBurnCardDeck( player )

        for( local i = 0; i < deck.len(); i++ )
        {
            if ( deck[i].cardRef == cardRef )
            {
                deck.remove( i )
                break
            }
        }

        FillBurnCardDeckFromArray( player, deck )
    }
}

function RemoveCardsOfRarityFromDeckArray( deck, rarity )
{
    for( local i = 0; i < deck.len(); i++ )
    {
        if ( GetBurnCardRarity( deck[i].cardRef ) == rarity || IsDiceCard( deck[i].cardRef ) )
            deck.remove( i )
    }
}

function RemoveDiceCardFromDeck( deck)
{
    for( local i = 0; i < deck.len(); i++ )
    {
        if ( IsDiceCard( deck[i].cardRef ) )
            deck.remove( i )
    }
}

function RollTheDice_PickCard( player, slot )
{
    local deck = GetPlayerBurnCardDeck( player )

    if ( deck.len() == 0 )
        return

    local removeCommons = RandomFloat( 0, 1.0 ) <= 1.0 / NON_RARES_PER_RARE

    if ( removeCommons )
        RemoveCardsOfRarityFromDeckArray( deck, BURNCARD_COMMON )
    else
        RemoveCardsOfRarityFromDeckArray( deck, BURNCARD_RARE )

    // if this somehow blows up just ignore the fancy rules
    if ( deck.len() == 0 )
        deck = GetPlayerBurnCardDeck( player )

    RemoveDiceCardFromDeck( deck )

    // don't bother using dice if there's no cards left
    if ( deck.len() == 0 )
    {
        player.SetPersistentVar( _GetActiveBurnCardsPersDataPrefix() + "[" + slot + "].cardRef", null )
        return
    }

    local card = deck[ RandomInt( deck.len() ) ]

    if( !card || card.cardRef == "bc_dice_ondeath" )
        return

    local cardRef = card.cardRef

    local stashTime = Time() + 90
    printt( "RollTheDice card: " + card.cardRef )

    SetPlayerActiveBurnCardSlotContents(player, slot, card.cardRef, false )
    SetPlayerLastActiveBurnCardFromSlot(player, slot, card.cardRef )

    SetPlayerStashedCardTime( player, stashTime.tointeger(), slot )
}

function RollTheDice( player, slot )
{
    player.EndSignal( "Disconnected" )

    RollTheDice_PickCard( player, slot )

    local diceNextTime = Time() + 90

    SetPlayerStashedCardRef( player, "bc_dice_ondeath", slot )

    for( ;; )
    {
        while ( GetPlayerBurnCardActiveSlotID( player ) == slot )
        {
            if ( DoesPlayerHaveActiveTitanBurnCard( player ) )
            {
                local titan = player.IsTitan() ? player : player.GetPetTitan()

                if ( !IsValid( titan ) )
                {
                    wait 0.1
                    continue
                }

                local soul = titan.GetTitanSoul()
                local player = titan.GetBossPlayer()

                soul.WaitSignal( "OnTitanDeath" )
            } else
                player.WaitSignal( "OnDeath" )
            diceNextTime = Time() + 90

            // stash the dice card
            SetPlayerStashedCardTime( player, diceNextTime.tointeger(), slot )

            wait 0.1
        }

        if ( Time() >= diceNextTime )
        {
            RollTheDice_PickCard( player, slot )
            Remote.CallFunction_UI( player, "SCB_RefreshBurnCardSelector" )
            player.Signal("RefreshDice")

            diceNextTime = Time() + 90
        }

        wait 0.1
    }
}

function BCPlayerRespawned( player )
{
    thread BurnCardPlayerRespawned_Threaded( player )
}

function BCLoadoutGrace_Think( player )
{
    player.EndSignal( "OnDestroy" )
    player.EndSignal( "Disconnected" )
    player.EndSignal( "StartBurnCardEffect" )

    if ( !player.s.inGracePeriod )
        player.WaitSignal( "EndGiveLoadouts" )

    local cardIndex
    local cardRef
    local cardData

    while( player.s.inGracePeriod && !( GetPlayerBurnCardActiveSlotID( player ) >= 0 ) )
    {
        cardIndex = GetPlayerBurnCardOnDeckIndex( player )
        cardRef = GetBurnCardFromSlot( player, cardIndex )

        if ( cardRef != null )
        {
            if ( !IsBurnCardEdgeCaseUseValid( player, cardRef ) )
            {
                wait 0.1
                continue
            }

            // don't burn rematch if you're alive
            if ( cardRef == "bc_rematch" )
            {
                wait 0.1
                continue
            }

            cardData = GetBurnCardData( cardRef )

            local lastsUntil = GetBurnCardLastsUntil( cardRef )

            if ( lastsUntil != BC_NEXTTITANDROP )
                ChangeOnDeckBurnCardToActive( player )
            else if ( player.IsTitan() )
                ChangeOnDeckBurnCardToActive( player )
        }

        wait 0.1
    }
}

function BurnCardPlayerRespawned_Threaded( player )
{
    local cardRef
    local cardIndex
    local cardData

    player.EndSignal( "Disconnected" )

    while ( !IsValid( player ) )
        wait 0.1

    // some missions in campaign do not use CE flags properly and rely on eGameState.Playing,
    if ( GetCinematicMode() )
        WaittillGameStateOrHigher( eGameState.Playing )

    while ( HasCinematicFlag( player, CE_FLAG_INTRO ) || HasCinematicFlag( player, CE_FLAG_CLASSIC_MP_SPAWNING ) || HasCinematicFlag( player, CE_FLAG_WAVE_SPAWNING ) )
        player.WaitSignal( "CE_FLAGS_CHANGED" );

    if ( GAMETYPE == COOPERATIVE)
    {
        while( ArrayContains( level.dropshipSpawnPlayerList[level.nv.attackingTeam], player ) )
            wait 0.1
    }

    printt( "BurnCardPlayerRespawned_Threaded" )

    cardIndex = GetPlayerBurnCardOnDeckIndex( player )
    cardRef = GetBurnCardFromSlot( player, cardIndex )

    if ( GetActiveBurnCard( player ) )
    {
        cardRef = GetActiveBurnCard( player )

        if ( DoesPlayerHaveActiveTitanBurnCard( player ) )
            return
    }

    if( cardRef )
    {
        if ( !IsBurnCardEdgeCaseUseValid( player, cardRef ) )
            return

        cardData = GetBurnCardData(cardRef)

        if ( GetBurnCardLastsUntil( cardRef ) != BC_NEXTTITANDROP )
            ChangeOnDeckBurnCardToActive( player )
    }
    else
    {
        waitthread BCLoadoutGrace_Think( player )

        cardIndex = GetPlayerBurnCardActiveSlotID( player )
        cardRef = GetActiveBurnCard( player )
    }

    if ( !cardRef )
        return

    if ( GetBurnCardLastsUntil( cardRef ) == BC_NEXTTITANDROP )
        return

    while ( !IsValid( player ) || IsValid( player.isSpawning ) )
        wait 0.1

    RunBurnCardFunctions( player, cardRef )
}

function RunSpawnBurnCard( player, cardRef )
{
    player.EndSignal( "Disconnected" )

    OnSpawned_GivePassiveLifeLong_Pilot( player )

    switch( cardRef )
    {
        case "bc_cloak_forever":
            if ( player.IsTitan() )
                player.WaitSignal( "OnLeftTitan" ); wait 0.5

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
        case "bc_free_build_time_1":
            if ( IsValid( player.GetPetTitan() ) )
            {
                local titan = player.GetPetTitan()
                local soul = titan.GetTitanSoul()

                soul.WaitSignal( "OnSoulTransfer" )
            }

            DecrementBuildTimer( player, 40 )
            StopActiveBurnCard( player )
            break
        case "bc_free_build_time_2":
            if ( IsValid( player.GetPetTitan() ) )
            {
                local titan = player.GetPetTitan()
                local soul = titan.GetTitanSoul()

                soul.WaitSignal( "OnSoulTransfer" )
            }

            DecrementBuildTimer( player, 80 )
            StopActiveBurnCard( player )
            break
        case "bc_pilot_warning":
            if ( player.IsTitan() )
                player.WaitSignal( "OnLeftTitan" ); wait 0.5

            BCSpiderSense( player )
            break
    }
}

function BCSpiderSense( player )
{
    thread BCSpiderSense_Think( player )
}

function BCSpiderSense_Think( player )
{
    player.EndSignal( "OnDeath" )
    player.EndSignal( "OnDestroy" )
    player.EndSignal( "Disconnected" )

    for( ;; )
    {
        foreach ( guy in GetPlayerArray() )
        {
            if ( !IsValid( guy ) )
                continue

            if ( !IsAlive( guy ) )
                continue

            if ( GetOtherTeam( player ) == guy.GetTeam() )
            {
                local distance = Distance( player.GetOrigin(), guy.GetOrigin() )

                if ( distance < 1000 && distance >= 500 )
                {
                    EmitSoundOnEntityOnlyToPlayer( player, player, "BurnCard_SpiderSense_DistantWarn" )
                    Remote.CallFunction_Replay( player, "ServerCallback_SpiderSense" )
                    wait 1.25
                }

                if ( distance < 500 )
                {
                    EmitSoundOnEntityOnlyToPlayer( player, player, "BurnCard_SpiderSense_CloseWarn" )
                    Remote.CallFunction_Replay( player, "ServerCallback_SpiderSense" )
                    wait 1.25
                }
            }
        }

        wait 1
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

function BCOnPlayerKilled( player, damageInfo )
{
    local cardRef = GetPlayerActiveBurnCard( player )

    if( !cardRef )
        return

    local lastsUntil = GetBurnCardLastsUntil( cardRef )

    if( IsRoundBased() && GetActiveBurnCard( player ) && damageInfo.GetDamageSourceIdentifier() != eDamageSourceId.round_end )
        StopActiveBurnCard( player )

    if( IsRoundBased() && !GamePlayingOrSuddenDeath() )
        return

    BurnCardOnDeath( player, damageInfo, BC_NEXTDEATH )

    if ( cardRef == "bc_rematch" )
        StopActiveBurnCard( player )
}

function ApplyTitanWeaponBurnCard( titan, cardRef )
{
    local cardData = GetBurnCardData(cardRef);
    local weaponToTake = null
    local weaponData = GetBurnCardWeapon(cardRef)
    local weapons = titan.GetMainWeapons()

    if ( !( cardData.ctFlags & CT_TITAN_WPN ) )
        return

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

    local isSpawning = false

    if ( IsValid( player ) )
        isSpawning = IsValid( player.isSpawning )
    else
        player = titan

    player.EndSignal( "Disconnected")

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

    if ( !GetPlayerActiveBurnCard( player ) )
    {
        local cardIndex = GetPlayerBurnCardOnDeckIndex(player)
        ref = GetBurnCardFromSlot( player, cardIndex )

        if( ref )
        {
            if ( !IsBurnCardEdgeCaseUseValid( player, ref ) )
                return

            if ( GetBurnCardLastsUntil( ref ) != BC_NEXTTITANDROP && !isSpawning)
                return

            ChangeOnDeckBurnCardToActive( player )
        }
        else
        {
            waitthread BCLoadoutGrace_Think( player )

            cardIndex = GetPlayerBurnCardActiveSlotID( player )
            ref = GetActiveBurnCard( player )

            if ( DoesPlayerHaveActiveNonTitanBurnCard( player ) )
                return
        }
    }

    if ( !ref )
        return

    local cardData = GetBurnCardData( ref )

    if ( GetBurnCardLastsUntil( ref ) == BC_NEXTTITANDROP )
    {
        local cardData = GetBurnCardData( ref )

        if(cardData.serverFlags)
            GiveServerFlag( player, cardData.serverFlags)

        RunSpawnBurnCard( player, ref )

        if ( isSpawning )
            ApplyTitanWeaponBurnCard( player, ref )
        else
            ApplyTitanWeaponBurnCard( titan, ref )
    }


    if ( isSpawning )
        thread TakeAwayTitanBCOnDeath( player )
    else
        thread TakeAwayTitanBCOnDeath( titan )

    if ( isSpawning )
        Remote.CallFunction_NonReplay( player,"ServerCallback_TitanDialogueBurnCardVO" )
}

function TakeAwayTitanBCOnDeath( titan )
{
    local soul = titan.GetTitanSoul()

    local player

    if ( !titan.IsPlayer())
        player = titan.GetBossPlayer()
    else
        player = titan

    soul.EndSignal( "OnTitanDeath" )
    player.EndSignal( "Disconnected" )

	OnThreadEnd(
		function() : ( player )
		{
            if ( !IsValid( player ) )
                return

            if ( DoesPlayerHaveActiveTitanBurnCard( player ) )
                StopActiveBurnCard( player )
		}
	)

    WaitForever()
}

