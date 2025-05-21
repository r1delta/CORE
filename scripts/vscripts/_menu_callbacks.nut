function main()
{
	IncludeScript( "_loadouts" )
	IncludeScript( "_burncards_shared")


	InitPresetLoadouts()

	AddClientCommandCallback( "SetPresetPilotLoadout", ClientCommand_SetPresetPilotLoadout ) //
	AddClientCommandCallback( "SetPresetTitanLoadout", ClientCommand_SetPresetTitanLoadout ) //
	AddClientCommandCallback( "SetCustomPilotLoadout", ClientCommand_SetCustomPilotLoadout ) //
	AddClientCommandCallback( "SetCustomTitanLoadout", ClientCommand_SetCustomTitanLoadout ) //
	AddClientCommandCallback( "InGameMenuOpened", ClientCommand_InGameMenuOpened ) //
	AddClientCommandCallback( "InGameMenuClosed", ClientCommand_InGameMenuClosed ) //
	AddClientCommandCallback( "SetLoadoutProperty", ClientCommand_SetLoadoutProperty ) //
//	AddClientCommandCallback( "LeaveMatchWithParty", ClientCommand_LeaveMatchWithParty ) //
//	AddClientCommandCallback( "LeaveMatchSolo", ClientCommand_LeaveMatchSolo ) //
	AddClientCommandCallback( "ClearNewStatus", ClientCommand_ClearNewStatus ) //
	AddClientCommandCallback( "SetTrackedChallenge", ClientCommand_SetTrackedChallenge ) //
	AddClientCommandCallback( "AbandonDailyChallenge", ClientCommand_AbandonDailyChallenge )
	AddClientCommandCallback( "CompleteChallenge", ClientCommand_CompleteChallenge )
	AddClientCommandCallback( "PilotLoadoutsMenuClosed", ClientCommand_PilotLoadoutsMenuClosed ) //
	AddClientCommandCallback( "SeasonEndDialogClosed", ClientCommand_SeasonEndDialogClosed ) //
	AddClientCommandCallback( "SetPlaylistAnnouncementSeen", ClientCommand_SetPlaylistAnnouncementSeen ) //
	AddClientCommandCallback("BCActivateCard", ClientCommand_ActivateBurnCard )
	AddClientCommandCallback("BCDeActivateCard", ClientCommand_DeActivateCard )
AddClientCommandCallback("OpenBurnCardMenu", ClientCommand_OpenBurnCardMenu )
	if ( GetDeveloperLevel() > 0 )
	{
		AddClientCommandCallback( "ToggleBubbleShield", ClientCommand_ToggleBubbleShield )
		AddClientCommandCallback( "ToggleHUD", ClientCommand_ToggleHUD )
		AddClientCommandCallback( "ToggleOffhandLowRecharge", ClientCommand_ToggleOffhandLowRecharge )
	}
	AddClientCommandCallback( "UpdateProgressionOption", ClientCommand_UpdateProgressionOption )

	RegisterSignal( "EndGiveLoadouts" )
	RegisterSignal( "NewPilotOrdnance" )

	Globalize( SetPilotLoadout )
	Globalize( SetTitanLoadout )
	Globalize( GetPersistentPilotLoadout )
	Globalize( GetPersistentTitanLoadout )
	Globalize( GetPresetTitanLoadout )
	Globalize( GetPresetPilotLoadout )
	Globalize( ValidateCustomLoadouts )

	Globalize( GiveLoadouts )
	Globalize(StopActiveBurnCard)

	Globalize( LoadoutChangeGracePeriodThink )

	Globalize( InitPilotLoadoutFromPreset )
	Globalize( InitTitanLoadoutFromPreset )

	Globalize( GetPilotPresets )
	Globalize( GetTitanPresets )
	Globalize( SetBotPilotLoadout )
	Globalize( SetBotTitanLoadout )

	file.hasInvalidLoadout <- false
}


function ClientCommand_OpenBurnCardMenu(player, ...)
{
	Remote.CallFunction_UI( player, "ServerCallback_OpenBurnCardMenu" )

	return true
}

function ClientCommand_UpdateProgressionOption( player, ... )
{
	if ( vargc != 1 )
		return false

	if ( vargv[0] == "1" )
		player.SetPersistentVar( "delta.everythingUnlocked", 1 )
	else if ( vargv[0] == "0" )
		player.SetPersistentVar( "delta.everythingUnlocked", 0 )
}

function ClientCommand_ActivateBurnCard(player, ...) {
	if (vargc != 2)
		return false

	local index = vargv[0].tointeger()

	if (index == null || index < 0 || index >= MAX_BURN_CARDS)
		return false

	// check if we already have an active burn card
	if (player.GetActiveBurnCardIndex() != -1)
	{
		SendHudMessage( player, "#BURN_CARD_IS_ACTIVE", -1, 0.4, 255, 255, 255, 255, 1.0, 2.0, 1.0 )
		return false
	}

	local cardRef = GetBurnCardFromSlot(player, index)
	local cardIndex = GetBurnCardIndexByRef(cardRef)
	SetPlayerBurnCardOnDeckIndex(player, index)
	EmitSoundOnEntityOnlyToPlayer( player, player, "UI_InGame_ActivateBurnCard" )
	Remote.CallFunction_UI( player, "SCB_RefreshBurnCardSelector" )

	return true
}

function ClientCommand_DeActivateCard(player, ...) {
	player.SetActiveBurnCardIndex(-1)
	return true
}

function SetBotTitanLoadout( player )
{
	local loadout = {}

	loadout.name <- "#TITAN_FGT_NAME_1"
	loadout.ref <- "titan_preset_loadout_1"
	loadout.setFile <- "titan_atlas"
	loadout.primary <- "mp_titanweapon_xo16"
	loadout.primaryAttachment <- null
	loadout.primaryMods <- []
	loadout.secondary <- null
	loadout.special <- "mp_titanability_bubble_shield" //전술 능력
	loadout.specialMods <- []
	loadout.ordnance <- "mp_titanweapon_salvo_rockets"
	loadout.ordnanceMods <- []
	loadout.passive1 <- "pas_defensive_core"
	loadout.passive2 <- "pas_hyper_core"
	loadout.passive3 <- null
	loadout.passive4 <- null
	loadout.passive5 <- null
	loadout.core <- null

	local table = player.playerClassData[ "titan" ]
	table.playerSetFile <- loadout.setFile
	table.primaryWeapon <- loadout.primary
	table.primaryWeaponMods <- []
	if ( loadout.primaryMods.len() != 0 )
		table.primaryWeaponMods = loadout.primaryMods

	table.secondaryWeapon <- null	// TODO: Update other script so we can safely remove this if we aren't having titan secondaries
	table.secondaryWeaponMods <- []

	table.offhandWeapons <- {}
	table.offhandWeapons[0] <- { weapon = loadout.ordnance, mods = loadout.ordnanceMods }
	table.offhandWeapons[1] <- { weapon = loadout.special, mods = loadout.specialMods }


	table.passive1 <- PassiveBitfieldFromEnum( loadout.passive1 )
	table.passive2 <- PassiveBitfieldFromEnum( loadout.passive2 )
	table.core <- loadout.core
    table.voiceChoice <- "titanos_betty"
	table.liverycode <- null
	table.liverycolor0 <- null
	table.liverycolor1 <- null
	table.liverycolor2 <- null
}
function SetBotPilotLoadout( player )
{
	local loadout = {}

	loadout.name <- player.GetName()
	loadout.skin <- "pilot_male_cq"
	loadout.ref <- null
	loadout.primary <- "mp_weapon_lmg"
	loadout.primaryMods <- []
	loadout.primaryAttachment <- "hcog"
	loadout.secondary <- "mp_weapon_rocket_launcher"
	loadout.secondaryMods <- []
	loadout.sidearm <- "mp_weapon_semipistol"
	loadout.sidearmMods <- []
	loadout.special <- "mp_ability_cloak"
	loadout.ordnance <- "mp_weapon_frag_grenade"
	loadout.ordnanceMods <- []
	loadout.passive1 <- "pas_power_cell"
	loadout.passive2 <- "pas_longer_bubble"

	// This occurs every respawn, not just at the beginning of the game
	local table = player.playerClassData[ "wallrun" ]
	table.playerSetFile <- loadout.skin
	table.primaryWeapon <- loadout.primary
	table.primaryWeaponMods <- []
	if ( loadout.primaryAttachment )
		table.primaryWeaponMods.append( loadout.primaryAttachment )

	if ( loadout.primaryMods.len() != 0 )
	{
		foreach( mod in loadout.primaryMods )
		{
			table.primaryWeaponMods.append(mod)
		}
	}

	table.secondaryWeapon <- loadout.secondary
	table.secondaryWeaponMods <- []
	if ( loadout.secondaryMods.len() != 0 )
		table.secondaryWeaponMods = loadout.secondaryMods

	table.sidearmWeapon <- loadout.sidearm
	table.sidearmWeaponMods <- []
	if ( loadout.sidearmMods.len() != 0 )
	{
		foreach( mod in loadout.sidearmMods )
		{
			table.sidearmWeaponMods.append(mod)
		}
	}

	if ( "offhandWeapons" in table && loadout.ordnance != table.offhandWeapons[0].weapon )
		player.Signal( "NewPilotOrdnance" )
	table.offhandWeapons <- {}
	table.offhandWeapons[0] <- { weapon = loadout.ordnance, mods = loadout.ordnanceMods }
	table.offhandWeapons[1] <- { weapon = loadout.special, mods = [] }

	table.passive1 <- PassiveBitfieldFromEnum( loadout.passive1 )
	table.passive2 <- PassiveBitfieldFromEnum( loadout.passive2 )

	// TODO: Add support for offhand mods
	//table.offhandWeapons[0].append( { weapon = null, mods = [] } )
	//table.offhandWeapons[0].append( { weapon = null, mods = [] } )
	//table.offhandWeapons[0].append( { weapon = null, mods = [] } )

	printl( "Set BotPilot Loadout table results" )
	PrintTable( table )
}

function InitPilotLoadoutFromPreset( player, loadoutIndex, presetIndex )
{
	presetIndex = presetIndex % pilotLoadouts.len()
	player.SetPersistentVar( "pilotLoadouts[" + loadoutIndex + "].race", pilotLoadouts[presetIndex].race )
	player.SetPersistentVar( "pilotLoadouts[" + loadoutIndex + "].primary", pilotLoadouts[presetIndex].primary )
	player.SetPersistentVar( "pilotLoadouts[" + loadoutIndex + "].primaryMod", null/*pilotLoadouts[presetIndex].primaryMod*/ )
	player.SetPersistentVar( "pilotLoadouts[" + loadoutIndex + "].primaryAttachment", null/*pilotLoadouts[presetIndex].primaryAttachment*/ )
	player.SetPersistentVar( "pilotLoadouts[" + loadoutIndex + "].secondary", pilotLoadouts[presetIndex].secondary )
	player.SetPersistentVar( "pilotLoadouts[" + loadoutIndex + "].sidearm", pilotLoadouts[presetIndex].sidearm )
	player.SetPersistentVar( "pilotLoadouts[" + loadoutIndex + "].special", pilotLoadouts[presetIndex].special )
	player.SetPersistentVar( "pilotLoadouts[" + loadoutIndex + "].ordnance", pilotLoadouts[presetIndex].ordnance )
	player.SetPersistentVar( "pilotLoadouts[" + loadoutIndex + "].passive1", pilotLoadouts[presetIndex].passive1 )
	player.SetPersistentVar( "pilotLoadouts[" + loadoutIndex + "].passive2", pilotLoadouts[presetIndex].passive2 )
}

function InitTitanLoadoutFromPreset( player, loadoutIndex, presetIndex )
{
	presetIndex = presetIndex % titanLoadouts.len()

	player.SetPersistentVar( "titanLoadouts[" + loadoutIndex + "].setFile", "titan_atlas"/*titanLoadouts[presetIndex].setFile*/ )
	player.SetPersistentVar( "titanLoadouts[" + loadoutIndex + "].primary", titanLoadouts[presetIndex].primary )
	player.SetPersistentVar( "titanLoadouts[" + loadoutIndex + "].primaryMod", null/*titanLoadouts[presetIndex].primaryMod*/ )
	player.SetPersistentVar( "titanLoadouts[" + loadoutIndex + "].special", titanLoadouts[presetIndex].special )
	player.SetPersistentVar( "titanLoadouts[" + loadoutIndex + "].ordnance", titanLoadouts[presetIndex].ordnance )
	player.SetPersistentVar( "titanLoadouts[" + loadoutIndex + "].passive1", titanLoadouts[presetIndex].passive1 )
	player.SetPersistentVar( "titanLoadouts[" + loadoutIndex + "].passive2", titanLoadouts[presetIndex].passive2 )
	player.SetPersistentVar( "titanLoadouts[" + loadoutIndex + "].decal", null )
	player.SetPersistentVar( "titanLoadouts[" + loadoutIndex + "].voiceChoice", titanLoadouts[presetIndex].voiceChoice )
}

function ClientCommand_SetPresetPilotLoadout( player, ... )
{
	if ( vargc != 1 )
		return false

	local loadoutIndex = vargv[0].tointeger()
	if ( loadoutIndex == null )
		return false
	SetPilotLoadout( player, false, loadoutIndex )

	return true
}

function ClientCommand_SetTrackedChallenge( player, ... )
{
	if ( vargc != 2 )
		return false

	local trackedChallengeIndex = vargv[0].tointeger()
	Assert( trackedChallengeIndex >= 0 && trackedChallengeIndex < MAX_TRACKED_CHALLENGES )

	if ( vargv[1] == "null" )
	{
		player.SetPersistentVar( "trackedChallengeRefs[" + trackedChallengeIndex + "]", "" )
	}
	else
	{
		Assert( vargv[1] in level.challengeData )
		player.SetPersistentVar( "trackedChallengeRefs[" + trackedChallengeIndex + "]", vargv[1] )
	}

	return true
}

function ClientCommand_SetPresetTitanLoadout( player, ... )
{
	if ( vargc != 1 )
		return false

	local loadoutIndex = vargv[0].tointeger()
	if ( loadoutIndex == null )
		return false
	SetTitanLoadout( player, false, loadoutIndex )

	return true
}

function ClientCommand_SetCustomPilotLoadout( player, ... )
{
	if ( vargc != 1 )
		return false

	local loadoutIndex = vargv[0].tointeger()
	if ( loadoutIndex == null )
		return false
	SetPilotLoadout( player, true, loadoutIndex )

	return true
}

function ClientCommand_SetCustomTitanLoadout( player, ... )
{
	if ( vargc != 1 )
		return false

	local loadoutIndex = vargv[0].tointeger()
	if ( loadoutIndex == null )
		return false
	SetTitanLoadout( player, true, loadoutIndex )

	return true
}

function ClientCommand_SetLoadoutProperty( player, ... )
{
	if ( vargc < 4 )
		return false

	local value = vargv[3]
	if ( value == "null" )
		value = null

	if ( vargv[2] == "name" )
	{
		if ( value != null )
		{
			value = ""
			for( local i = 3 ; i < vargc ; i++ )
			{
				if ( i > 3 )
					value += " "
				value += vargv[i]
			}

			value = strip(value)
			if (value == "")
				return false
		}
		SetLoadoutName( player, vargv[0], vargv[1].tointeger(), value )

		player.SetPersistentVar( "cu8achievement.ach_renamedCustomLoadout", true )
	}
	else
	{
		if ( vargc != 4 )
			return false

		SetLoadoutProperty( player, vargv[0], vargv[1].tointeger(), vargv[2], value )
	}

	return true
}

function ClientCommand_InGameMenuOpened( player, ... )
{
	return true
}

function ClientCommand_InGameMenuClosed( player, ... )
{
	if ( ( "pilotLoadout" in player.s ) || ( "titanLoadout" in player.s ) )
	{
		OnPlayerCloseClassMenu( player )

		thread GiveLoadouts( player )
	}

	return true
}

function ClientCommand_PilotLoadoutsMenuClosed( player, ... )
{
	// not sure if player could ever get here and not have usedLoadoutCrate in .s
	Assert( "usedLoadoutCrate" in player.s )

	if ( !ShouldGivePilotLoadout( player ) && player.s.usedLoadoutCrate == true )
	{
		// only clear player.s.usedLoadoutCrate if loadout didn't change
		// if it changed it will be cleared inside GiveLoadouts(...)

		player.s.usedLoadoutCrate = false
	}

	return true
}

function ClientCommand_LeaveMatchWithParty( player, ... )
{
	printt( "=== SendPlayersToPartyScreen() initiated by:", player.GetPlayerName() )
	local players = GetPartyMembers( player )

	foreach ( player in players )
		printt( "=== Party member:", player.GetPlayerName() )

	//SendPlayersToPartyScreen( players )

	return true
}

function ClientCommand_LeaveMatchSolo( player, ... )
{
	printt( "=== SendPlayersToPartyScreen() initiated by:", player.GetPlayerName() )
	printt( "=== Solo player:", player.GetPlayerName() )

	//SendPlayersToPartyScreen( [ player ] )

	return true
}

function ClientCommand_ToggleBubbleShield( player, ... )
{
	level.bubbleShieldEnabled = !level.bubbleShieldEnabled
	return true

}

function ClientCommand_ToggleHUD( player, ... )
{
	if ( HasCinematicFlag( player, CE_FLAG_INTRO ) )
		RemoveCinematicFlag( player, CE_FLAG_INTRO )
	else
		AddCinematicFlag( player, CE_FLAG_INTRO )

	return true
}

function ClientCommand_ToggleOffhandLowRecharge( player, ... )
{
	if ( player.HasExtraWeaponMod( "dev_mod_low_recharge" ) )
		player.TakeExtraWeaponMod( "dev_mod_low_recharge" )
	else
		player.GiveExtraWeaponMod( "dev_mod_low_recharge" )

	return true
}

function ClientCommand_SeasonEndDialogClosed( player, ... )
{
	player.SetPersistentVar( "ranked.showSeasonEndDialog", false )
	return true
}

function ClientCommand_SetPlaylistAnnouncementSeen( player, ... )
{
	player.SetPersistentVar( "playlistAnnouncementSeen", true )
	return true
}

function StopActiveBurnCard( player )
{
	local cardRef = GetPlayerActiveBurnCard( player )

	if (cardRef == null)
		return

	local activeBCID = player.GetPersistentVar( "activeBCID" )
	player.SetPersistentVar( "activeBCID", -1 )
	player.SetActiveBurnCardIndex( -1 )
	player.SetPersistentVar( _GetActiveBurnCardsPersDataPrefix() + "[" + activeBCID + "].cardRef", null )
	player.SetPersistentVar( _GetActiveBurnCardsPersDataPrefix() + "[" + activeBCID + "].clearOnStart", 0 )

}

function GiveLoadouts( player )
{
	player.Signal( "EndGiveLoadouts" )
	player.EndSignal( "EndGiveLoadouts" )
	if ( !IsAlive( player ) )
		return

	if ( IsTrainingLevel() )
		return

	// This occurs every respawn, not just at the beginning of the game
	if ( !player.s.inGracePeriod && player.s.usedLoadoutCrate == false )
		return

	if ( player.s.usedLoadoutCrate == true )
	{
		player.s.usedLoadoutCrate = false

		// clear the current burn card if it's a pilot weapon.
		local cardRef = GetPlayerActiveBurnCard( player )
		printt( "cardRef: ", cardRef )
		if ( cardRef != null )
		{
			local cardData = GetBurnCardData( cardRef )
			if ( cardData.group == BCGROUP_WEAPON && cardData.lastsUntil == BC_NEXTDEATH )
				StopActiveBurnCard( player )
		}
	}

	player.EndSignal( "OnDeath" )
	player.EndSignal( "Disconnected" )

	// Can't get new weapon during intro, bad things can happen
	while ( HasCinematicFlag( player, CE_FLAG_INTRO ) || HasCinematicFlag( player, CE_FLAG_CLASSIC_MP_SPAWNING ) || HasCinematicFlag( player, CE_FLAG_WAVE_SPAWNING ) )
		player.WaitSignal( "CE_FLAGS_CHANGED" )

	switch ( player.GetPlayerClass() )
	{
		case level.pilotClass:
			if ( ShouldGivePilotLoadout( player ) )
			{
				TakeAllWeapons( player )
				local pilotDataTable = GetPlayerClassDataTable( player, level.pilotClass )
				Wallrun_GiveLoadout( player, pilotDataTable ) //Passives are given in here
			}
			break

		case "titan":
		    local titanDataTable = GetPlayerClassDataTable( player, "titan" )
			local titanSettings = titanDataTable.playerSetFile
			TakeAllPassives( player )
			player.SetPlayerSettings( titanSettings )

			local soul = player.GetTitanSoul()

			if ( ShouldGiveTitanLoadout( player ) )
			{
				TakeAllWeapons( player )
				if ( IsValid( soul.rocketPod.model ) )
					soul.rocketPod.model.Kill()
				soul.rocketPod.model = null

				soul.passives = 0 //Clear out passives on soul

				CreateTitanRocketPods( soul, soul.GetTitan() )
				GiveTitanWeaponsForPlayer( player, player )
				SetTitanOSForPlayer( player )
				SetDecalForTitan( player )
			}
			else
			{
				GivePlayerPassivesFromSoul( player, soul )
			}

			OnSpawned_GivePassiveLifeLong_Pilot( player )

			break
	}
}


function ShouldGivePilotLoadout( player )
{
	if ( GetPlayerBurnCardOnDeckIndex( player ) != null )
		return true

	return NewPilotLoadoutSelected( player )
}


function ShouldGiveTitanLoadout( player )
{
	if ( GetPlayerBurnCardOnDeckIndex( player ) != null )
		return true

	return NewTitanLoadoutSelected( player )
}


function LoadoutChangeGracePeriodThink( player )
{
	player.s.inGracePeriod = true

	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnPrimaryAttack" )
	player.EndSignal( "StartBurnCardEffect" )
	player.EndSignal( "CalledInReplacementTitan" )
	player.EndSignal( "player_embarks_titan" )

	OnThreadEnd(
		function() : ( player )
		{
			if ( !IsValid( player ) )
				return

			player.s.inGracePeriod = false
		}
	)

	while ( GetGameState() < eGameState.Playing )
		wait 0

	local endTime = Time() + CLASS_CHANGE_GRACE_PERIOD

	local suitPower = player.GetSuitPower()

	while ( Time() < endTime )
	{
		// dash breaks grace period
		if ( player.GetSuitPower() < suitPower )
			break

		wait 0
	}
}


function SetPilotLoadout( player, isCustom, loadoutIndex )
{
	local loadout = GetPersistentPilotLoadout( player, isCustom, loadoutIndex )

	// This occurs every respawn, not just at the beginning of the game

	if ( LoadoutWillChangeAtNextSpawn( player, isCustom, loadoutIndex ) )
	{
		if ( GetWaveSpawnType() == eWaveSpawnType.DISABLED )
			SendHudMessage( player, "#GAMEMODE_CHANGE_CLASS_NEXT_SPAWN", -1, 0.4, 255, 255, 255, 255, 1.0, 2.0, 1.0 )
		else
			SendHudMessage( player, "#GAMEMODE_CHANGE_CLASS_NEXT_DEPLOY", -1, 0.4, 255, 255, 255, 255, 1.0, 2.0, 1.0 )
	}
	else if ( player.s.usedLoadoutCrate == true )
	{
		// play special sound when setting loadout using a loadout crate
		EmitSoundOnEntityOnlyToPlayer( player, player, "Coop_AmmoBox_Close" )
	}

	player.s.pilotLoadoutIndex = loadoutIndex
	player.s.pilotLoadoutCustom = isCustom
	player.s.pilotLoadout = loadout

	local table = player.playerClassData[ "wallrun" ]
	table.race <- loadout.race
	table.playerSetFile <- GetSetFileFromPrimaryWeaponAndPersistentData( loadout.primary, loadout.race == RACE_HUMAN_FEMALE )
	table.primaryWeapon <- loadout.primary
	table.secondaryWeapon <- loadout.secondary
	table.sidearmWeapon <- loadout.sidearm

	if ( "offhandWeapons" in table && loadout.ordnance != table.offhandWeapons[0].weapon )
		player.Signal( "NewPilotOrdnance" )
	table.offhandWeapons <- {}
	table.offhandWeapons[0] <- { weapon = loadout.ordnance, mods = [] }
	table.offhandWeapons[1] <- { weapon = loadout.special, mods = [] }

	table.primaryWeaponMods <- []
	if ( loadout.primaryAttachment )
		table.primaryWeaponMods.append( loadout.primaryAttachment )
	if ( loadout.primaryMod )
		table.primaryWeaponMods.append( loadout.primaryMod )

	table.secondaryWeaponMods <- []
	table.sidearmWeaponMods <- []
	

	table.passive1 <- PassiveBitfieldFromEnum( loadout.passive1 )
	table.passive2 <- PassiveBitfieldFromEnum( loadout.passive2 )

	TableDump(loadout)
	// loadout.sidearmMod <- null
	if (loadout.sidearmMod)
		table.sidearmWeaponMods.append( loadout.sidearmMod )

	// if (loadout.secondaryMod)
	// 	table.secondaryWeaponMods.append( loadout.secondaryMod )

	
	// TODO: Add support for offhand mods
	//table.offhandWeapons[0].append( { weapon = null, mods = [] } )
	//table.offhandWeapons[0].append( { weapon = null, mods = [] } )
	//table.offhandWeapons[0].append( { weapon = null, mods = [] } )

	//printl( "SetPilotLoadout table results" )
	//PrintTable( table )

	SetPersistentSpawnLoadout( player, "pilot", isCustom, loadoutIndex )
}

function LoadoutWillChangeAtNextSpawn( player, isCustom, loadoutIndex )
{
	if ( GetGameState() != eGameState.Playing )
		return false	// we don't get a message when we are not playing.

	if ( player.s.usedLoadoutCrate == true )
		return false	// we don't get a message when we use a loadout crate.

	if ( player.s.inGracePeriod )
		return false	// we don't get a message if we are within the grace period

	if ( player.s.pilotLoadoutIndex == loadoutIndex && player.s.pilotLoadoutCustom == isCustom )
		return false	// we don't get a message if we didn't actually change our loadout

	return true	// we will have to wait for next spawn before we get our new loadout
}

function TryTakePassive( passiveNum, player, table )
{
	if ( !( passiveNum in table ) )
		return

	local passive = table[ passiveNum ]
	if ( passive == null )
		return

	if ( !PlayerHasPassive( player, passive ) )
		return
	TakePassive( player, passive )
}

function SetTitanLoadout( player, isCustom, loadoutIndex )
{
	local loadout = GetPersistentTitanLoadout( player, isCustom, loadoutIndex )

	// This occurs every respawn, not just at the beginning of the game
	if ( GamePlayingOrSuddenDeath() && !player.s.inGracePeriod && (player.s.pilotLoadoutIndex != loadoutIndex || player.s.pilotLoadoutCustom != isCustom) )
		SendHudMessage( player, "#GAMEMODE_CHANGE_CLASS_NEXT_TITAN", -1, 0.4, 255, 255, 255, 255, 1.0, 2.0, 1.0 )

	player.s.titanLoadoutIndex = loadoutIndex
	player.s.titanLoadoutCustom = isCustom
	player.s.titanLoadout = loadout

	local table = player.playerClassData[ "titan" ]
	table.playerSetFile <- loadout.setFile
	table.primaryWeapon <- loadout.primary
	table.secondaryWeapon <- null	// TODO: Update other script so we can safely remove this if we aren't having titan secondaries

	table.offhandWeapons <- {}
	table.offhandWeapons[0] <- { weapon = loadout.ordnance, mods = [] }
	table.offhandWeapons[1] <- { weapon = loadout.special, mods = [] }

	table.primaryWeaponMods <- []
	if ( loadout.primaryAttachment )
		table.primaryWeaponMods.append( loadout.primaryAttachment )
	if ( loadout.primaryMod )
		table.primaryWeaponMods.append( loadout.primaryMod )

	table.secondaryWeaponMods <- []
	table.sidearmWeaponMods <- []

	table.passive1 <- PassiveBitfieldFromEnum( loadout.passive1 )
	table.passive2 <- PassiveBitfieldFromEnum( loadout.passive2 )

	table.decal <- loadout.decal
	table.voiceChoice <- loadout.voiceChoice

	SetPersistentSpawnLoadout( player, "titan", isCustom, loadoutIndex )
}

function GetPresetPilotLoadout( loadoutIndex )
{
	Assert( loadoutIndex < pilotLoadouts.len(), "Invalid pilot loadout index " + loadoutIndex + " is greater than number of loadouts (" + pilotLoadouts.len() + ")" )
	return clone pilotLoadouts[ loadoutIndex ]
}

function GetPresetTitanLoadout( loadoutIndex )
{
	Assert( loadoutIndex < titanLoadouts.len(), "Invalid pilot loadout index " + loadoutIndex + " is greater than number of loadouts (" + titanLoadouts.len() + ")" )
	return clone titanLoadouts[ loadoutIndex ]
}

function GetRandomTitanLoadout()
{
	local keys = []
	foreach ( index, table in titanLoadouts )
	{
		keys.append( index )
	}
	local key = Random( keys )
	return GetPresetTitanLoadout( key )
}
Globalize( GetRandomTitanLoadout )

function GetPersistentPilotLoadout( player, isCustom, loadoutIndex )
{
	if ( !isCustom )
	{
		if ( loadoutIndex < pilotLoadouts.len() )
			return pilotLoadouts[loadoutIndex]
		else
			return pilotLoadouts[0] // Use default loadout if the player's persistent spawn loadout index no longer exists
	}

	// if ( IsItemLocked( "pilot_custom_loadout_" + (loadoutIndex + 1), null, player ) )
	// 	return pilotLoadouts[0]

	local loadout = {}
	loadout.name <- player.GetPersistentVar( "pilotLoadouts[" + loadoutIndex + "].name" )
	loadout.primary <- player.GetPersistentVar( "pilotLoadouts[" + loadoutIndex + "].primary" )
	loadout.secondary <- player.GetPersistentVar( "pilotLoadouts[" + loadoutIndex + "].secondary" )
	loadout.sidearm <- player.GetPersistentVar( "pilotLoadouts[" + loadoutIndex + "].sidearm" )
	loadout.special <- player.GetPersistentVar( "pilotLoadouts[" + loadoutIndex + "].special" )
	loadout.ordnance <- player.GetPersistentVar( "pilotLoadouts[" + loadoutIndex + "].ordnance" )
	loadout.primaryMod <- player.GetPersistentVar( "pilotLoadouts[" + loadoutIndex + "].primaryMod" )
	loadout.primaryAttachment <- player.GetPersistentVar( "pilotLoadouts[" + loadoutIndex + "].primaryAttachment" )
	loadout.sidearmMod <- player.GetPersistentVar( "pilotLoadouts[" + loadoutIndex + "].sidearmMod" )
	loadout.passive1 <- player.GetPersistentVar( "pilotLoadouts[" + loadoutIndex + "].passive1" )
	loadout.passive2 <- player.GetPersistentVar( "pilotLoadouts[" + loadoutIndex + "].passive2" )
	loadout.race <- player.GetPersistentVar( "pilotLoadouts[" + loadoutIndex + "].race" )

	foreach ( property, value in loadout )
	{
		if ( ValidateLoadoutProperty( player, "pilot", loadoutIndex, property, value ) )
			continue

		// invalid choice invalidates the whole loadout
		printt( "Pilot player " + player + " has invalid loadout item " + value )
		InitPilotLoadoutFromPreset( player, loadoutIndex, 0 )

		file.hasInvalidLoadout = true

		return pilotLoadouts[0]
	}

	return loadout
}

function GetPersistentTitanLoadout( player, isCustom, loadoutIndex )
{
	if ( !isCustom )
	{
		if ( loadoutIndex < titanLoadouts.len() )
			return titanLoadouts[loadoutIndex]
		else
			return titanLoadouts[0] // Use default loadout if the player's persistent spawn loadout index no longer exists
	}

	// if ( IsItemLocked( "titan_custom_loadout_" + (loadoutIndex + 1), null, player ) )
	// 	return titanLoadouts[0]

	local loadout = {}
	loadout.name <- player.GetPersistentVar( "titanLoadouts[" + loadoutIndex + "].name" )
	loadout.setFile <- player.GetPersistentVar( "titanLoadouts[" + loadoutIndex + "].setFile" )
	loadout.primary <- player.GetPersistentVar( "titanLoadouts[" + loadoutIndex + "].primary" )
	loadout.special <- player.GetPersistentVar( "titanLoadouts[" + loadoutIndex + "].special" )
	loadout.ordnance <- player.GetPersistentVar( "titanLoadouts[" + loadoutIndex + "].ordnance" )
	loadout.primaryMod <- player.GetPersistentVar( "titanLoadouts[" + loadoutIndex + "].primaryMod" )
	loadout.secondary <- null
	loadout.primaryAttachment <- null
	loadout.passive1 <- player.GetPersistentVar( "titanLoadouts[" + loadoutIndex + "].passive1" )
	loadout.passive2 <- player.GetPersistentVar( "titanLoadouts[" + loadoutIndex + "].passive2" )
	loadout.decal <- player.GetPersistentVar( "titanLoadouts[" + loadoutIndex + "].decal" )
	loadout.voiceChoice <- player.GetPersistentVar( "titanLoadouts[" + loadoutIndex + "].voiceChoice" )

	foreach ( property, value in loadout )
	{
		if ( ValidateLoadoutProperty( player, "titan", loadoutIndex, property, value ) )
			continue

		printt( "Titan player " + player + " has invalid loadout item " + value )
		InitTitanLoadoutFromPreset( player, loadoutIndex, 0 )

		file.hasInvalidLoadout = true

		return titanLoadouts[0]
	}

	return loadout
}

function ValidateCustomLoadouts( player )
{
	file.hasInvalidLoadout = false

	GetPersistentPilotLoadout( player, true, 0 )
	GetPersistentPilotLoadout( player, true, 1 )
	GetPersistentPilotLoadout( player, true, 2 )
	GetPersistentPilotLoadout( player, true, 3 )
	GetPersistentPilotLoadout( player, true, 4 )

	GetPersistentTitanLoadout( player, true, 0 )
	GetPersistentTitanLoadout( player, true, 1 )
	GetPersistentTitanLoadout( player, true, 2 )
	GetPersistentTitanLoadout( player, true, 3 )
	GetPersistentTitanLoadout( player, true, 4 )

	if ( file.hasInvalidLoadout && !IsLobby() )
		Remote.CallFunction_UI( player, "ServerCallback_LoadoutsUpdated" )

	file.hasInvalidLoadout = false
}

function IsValidPilotLoadoutProperty( property )
{
	switch ( property )
	{
		case "name":
		case "primary":
		case "secondary":
		case "sidearm":
		case "special":
		case "ordnance":
		case "primaryAttachment":
		case "primaryMod":
		case "sidearmMod":
		case "secondaryMod":
		case "passive1":
		case "passive2":
		case "race":
			return true

		default:
			return false
	}

	return false
}

function IsValidTitanLoadoutProperty( property )
{
	switch ( property )
	{
		case "name":
		case "setFile":
		case "primary":
		case "special":
		case "ordnance":
		case "primaryMod":
		case "passive1":
		case "passive2":
		case "decal":
		case "voiceChoice":
			return true

		default:
			return false
	}

	return false
}

function GetPilotLoadoutPropertyEnum( property )
{
	switch ( property )
	{
		case "name":
			return null
		case "primary":
			return "loadoutItems"
		case "secondary":
			return "loadoutItems"
		case "sidearm":
			return "loadoutItems"
		case "special":
			return "loadoutItems"
		case "ordnance":
			return "loadoutItems"
		case "primaryAttachment":
		case "primaryMod":
			return "pilotMod"
		case "passive1":
		case "passive2":
			return "pilotPassive"
		case "race":
			return "pilotRace"

		default:
			return false
	}

	return false
}

function GetTitanLoadoutPropertyEnum( property )
{
	switch ( property )
	{
		case "name":
			return null
		case "setFile":
			return "titanSetFile"
		case "primary":
			return "loadoutItems"
		case "special":
			return "loadoutItems"
		case "ordnance":
			return "loadoutItems"
		case "primaryMod":
			return "titanMod"
		case "passive1":
		case "passive2":
			return "titanPassive"
		case "decal":
			return "titanDecals"

		default:
			return null
	}

	return null
}

function SetLoadoutName( player, loadoutType, loadoutIndex, name )
{
	if ( !name )
	{
		CodeWarning( "Null name parameter to SetLoadoutName" )
		return
	}

	local loadoutProperty = "name"
	if ( loadoutType != "pilot" && loadoutType != "titan" )
	{
		CodeWarning( "Invalid loadoutType parameter to SetLoadoutName: " + loadoutType )
		return
	}

	if ( loadoutIndex == null || loadoutIndex.tointeger() >= PersistenceGetArrayCount( loadoutType + "Loadouts" ) )
	{
		CodeWarning( "Invalid loadoutIndex parameter to SetLoadoutName: " + loadoutIndex )
		return
	}

	player.SetPersistentVar( loadoutType + "Loadouts[" + loadoutIndex + "]." + loadoutProperty, name )

	// Durango Achievement
	if ( loadoutType == "pilot" )
		player.SetPersistentVar( "ach_createPilotLoadout", true )
	else if ( loadoutType == "titan" )
		player.SetPersistentVar( "ach_createTitanLoadout", true )
}

function SetLoadoutProperty( player, loadoutType, loadoutIndex, property, value )
{
	printt( "=======================================================================================" )
	printt( "loadoutType:", loadoutType, "loadoutIndex:", loadoutIndex, "property:" , property, "value:", value )
	printl( "script GetPlayerArray()[0].SetPersistentVar( \"" + loadoutType + "Loadouts[" + loadoutIndex + "]." + property + "\", \"" + value + "\" )" )
	printt( "=======================================================================================" )

	if ( !property )
	{
		CodeWarning( "Null property parameter to SetLoadoutProperty" )
		return
	}

	local loadoutProperty = property.tostring()
	local loadoutPropertyEnum = null
	if ( loadoutType == "pilot" )
	{
		if ( !IsValidPilotLoadoutProperty( loadoutProperty ) )
		{
			printt( "Invalid property parameter to SetLoadoutProperty: " + loadoutProperty )
			return
		}

		loadoutPropertyEnum = GetPilotLoadoutPropertyEnum( loadoutProperty )
	}
	else if ( loadoutType == "titan" )
	{
		if ( !IsValidTitanLoadoutProperty( loadoutProperty ) )
		{
			printt( "Invalid property parameter to SetLoadoutProperty: " + loadoutProperty )
			return
		}

		loadoutPropertyEnum = GetTitanLoadoutPropertyEnum( loadoutProperty )
	}
	else
	{
		printt( "Invalid loadoutType parameter to SetLoadoutProperty: " + loadoutType )
		return
	}

	if ( loadoutIndex == null || loadoutIndex.tointeger() >= PersistenceGetArrayCount( loadoutType + "Loadouts" ) )
	{
		printt( "Invalid loadoutIndex parameter to SetLoadoutProperty: " + loadoutIndex )
		return
	}

	if ( value && !IsRefValid( value ) )
	{
		printt( "Invalid ref value parameter to SetLoadoutProperty: " + value )
		return
	}

	if ( !loadoutPropertyEnum || !value )
	{
		printt( "SetLoadoutProperty: " + loadoutType + "Loadouts[" + loadoutIndex + "]." + loadoutProperty + " = " + value )
	}
	else if ( !PersistenceEnumValueIsValid( loadoutPropertyEnum, value ) )
	{
		CodeWarning( "Invalid ref value parameter for property " + loadoutProperty + " in SetLoadoutProperty: " + value )
		return
	}
   printt("DEBUG:", player, loadoutType, loadoutIndex, loadoutProperty, value)
	if ( !ValidateLoadoutProperty( player, loadoutType, loadoutIndex, loadoutProperty, value ) )
		return

	player.SetPersistentVar( loadoutType + "Loadouts[" + loadoutIndex + "]." + loadoutProperty, value )

	// Durango Achievement
	if ( loadoutType == "pilot" )
		player.SetPersistentVar( "ach_createPilotLoadout", true )
	else if ( loadoutType == "titan" )
		player.SetPersistentVar( "ach_createTitanLoadout", true )
}

function SetPersistentSpawnLoadout( player, loadoutType, isCustom, loadoutIndex )
{
	//printt( "=======================================================================================" )
	//printt( "loadoutType:", loadoutType, "isCustom:", isCustom, "loadoutIndex:", loadoutIndex )
	//printl( "script GetPlayerArray()[0].SetPersistentVar( \"" + loadoutType + "SpawnLoadout.isCustom\", \"" + isCustom + "\" )" )
	//printl( "script GetPlayerArray()[0].SetPersistentVar( \"" + loadoutType + "SpawnLoadout.index\", \"" + loadoutIndex + "\" )" )
	//printt( "=======================================================================================" )

	player.SetPersistentVar( loadoutType + "SpawnLoadout.isCustom", isCustom )
	player.SetPersistentVar( loadoutType + "SpawnLoadout.index", loadoutIndex ) // TODO: Update name
}

function ValidateLoadoutProperty( player, loadoutType, loadoutIndex, property, ref )
{
//    printt(player, loadoutType, loadoutIndex, property, ref)
	local childRef = null
	switch ( property )
	{
		case "primaryMod":
		case "primaryAttachment":
			childRef = ref
			ref = player.GetPersistentVar( loadoutType + "Loadouts[" + loadoutIndex + "].primary" )
			//local key = loadoutType + "Loadouts[" + loadoutIndex + "].primary"
			//local value = GetPersistentStringForClient(player, key, "pdata_null")
			//local unpackedKey = UnpackKey(key)
			//local type = pdef_keys[unpackedKey]
			//printt("DEBUG: ", value, unpackedKey, type)
			break
		case "sidearmMod":
			childRef = ref
			ref = player.GetPersistentVar( loadoutType + "Loadouts[" + loadoutIndex + "].sidearm" )
			break
	}

	// invalid attachment
	if ( childRef && !TMPHasSubitem( ref, childRef ) )
		return false

	
	if(childRef) {
		local itemData = GetSubitemData( ref, childRef )
		if ( itemData == null )
			return false

		if(itemData.type == itemType.PILOT_PRIMARY_MOD && itemData.displayInMenu == false)
			return false
		
		if(itemData.type == itemType.PILOT_SIDEARM_MOD && itemData.displayInMenu == false)
			return false

	}
	return true
}

function GetPilotPresets()
{
	return pilotLoadouts
}


function GetTitanPresets()
{
	return titanLoadouts
}


function ClientCommand_ClearNewStatus( player, ... )
{
	if ( vargc != 1 )
		return false

	local ref = vargv[0]
	if ( ItemDefined( ref ) )
	{
		local refType = GetItemType( ref )

		switch ( refType )
		{
			case itemType.PILOT_PRIMARY:
			case itemType.PILOT_SECONDARY:
			case itemType.PILOT_SIDEARM:
			case itemType.PILOT_SPECIAL:
			case itemType.PILOT_ORDNANCE:
			case itemType.TITAN_SPECIAL:
			case itemType.TITAN_ORDNANCE:
			case itemType.TITAN_PRIMARY:
				player.SetPersistentVar( "newLoadoutItems[" + ref + "]", false )
				break

			case itemType.TITAN_SETFILE:
				player.SetPersistentVar( "newChassis[" + ref + "]", false )
				break

			case itemType.PILOT_PASSIVE1:
			case itemType.PILOT_PASSIVE2:
				player.SetPersistentVar( "newPilotPassives[" + ref + "]", false )
				break

			case itemType.TITAN_PASSIVE1:
			case itemType.TITAN_PASSIVE2:
				player.SetPersistentVar( "newTitanPassives[" + ref + "]", false )
				break

			case itemType.TITAN_DECAL:
				player.SetPersistentVar( "newTitanDecals[" + ref + "]", false )
				break

			case itemType.TITAN_OS:
				player.SetPersistentVar( "newTitanOS[" + ref + "]", false )
				break
		}
	}
	else if ( ref in combinedModData )
	{
		player.SetPersistentVar( "newMods[" + ref + "]", false )
	}
	else if ( ref in unlockLevels )
	{
		player.SetPersistentVar( "newUnlocks[" + ref + "]", false )
	}
	else
	{
		printt( "ClientCommand_ClearNewStatus: invalid ref " + ref )
		return false
	}

	return true
}

function ClientCommand_AbandonDailyChallenge( player, ... )
{
	Assert( vargc == 1 )
	local ref = vargv[0]

	Assert( IsDailyChallenge( ref ) )
	Assert( IsActiveDailyChallenge( ref, player ) )

	// Clear the challenge from stored dailies
	local maxDailies = PersistenceGetArrayCount( "activeDailyChallenges" )
	for ( local i = 0 ; i < maxDailies ; i++ )
	{
		if ( player.GetPersistentVar( "activeDailyChallenges[" + i + "].ref" ) == ref )
		{
			player.SetPersistentVar( "activeDailyChallenges[" + i + "].ref", null )
			player.SetPersistentVar( "activeDailyChallenges[" + i + "].day", 0 )
		}
	}

	return true
}

function ClientCommand_CompleteChallenge( player, ... )
{
	Assert( vargc == 1 )
	local ref = vargv[0]

	Assert( !IsDailyChallenge( ref ) )

	// Make sure the server says the player has challenge skips available
	local challengeSkips = player.GetPersistentVar( "bm.challengeSkips" )
	if ( challengeSkips <= 0 )
		return true

	// Get info about the challenge
	local tiers = GetChallengeTierCount( ref )
	local goal = GetGoalForChallengeTier( ref, tiers - 1 )

	// Update player challenges completed stat
	local tiersSkipped = 0
	for ( local i = 0 ; i < tiers ; i++ )
	{
		if ( !IsChallengeTierComplete( ref, i, player ) )
			tiersSkipped++
	}

	local challengeTiersCompleted = player.GetPersistentVar( "miscStats.challengeTiersCompleted" )
	player.SetPersistentVar( "miscStats.challengeTiersCompleted", challengeTiersCompleted + tiersSkipped )

	// Update progress on the challenge to be complete
	player.SetPersistentVar( GetChallengeStorageArrayNameForRef(ref) + "[" + ref + "].progress", goal )
	player.SetPersistentVar( "bm.challengeSkips", challengeSkips - 1 )

	// Update forged certs used stats
	local forgedCertsUsed = player.GetPersistentVar( "miscStats.forgedCertificationsUsed" )
	player.SetPersistentVar( "miscStats.forgedCertificationsUsed", forgedCertsUsed + 1 )
	if ( IsRegenRequirement( ref, player ) )
	{
		local regenForgedCertsUsed = player.GetPersistentVar( "miscStats.regenForgedCertificationsUsed" )
		player.SetPersistentVar( "miscStats.regenForgedCertificationsUsed", regenForgedCertsUsed + 1 )
	}

	return true
}