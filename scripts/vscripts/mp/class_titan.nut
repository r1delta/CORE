const TITAN_HATCHCOMMANDANIMTIME = 1.5	// cooldown time between toggling the cockpit state. Will be needed when we have animations to play

const COCKPIT_JOLT_DAMAGE_MIN = 1
const COCKPIT_JOLT_DAMAGE_MAX = 200
const TITAN_STUMBLE_HEALTH_PERCENTAGE = 0.5

thisClassName <- "titan"

function main()
{
	Globalize( Titan_AddPlayer )
	Globalize( Titan_OnPlayerDeath )
	Globalize( Titan_CreateDropPod )
	Globalize( GiveTitanWeaponsForPlayer )
	Globalize( GiveTitanWeaponsForLoadoutData )
	Globalize( ClientCommand_TitanEject )
	Globalize( GiveHotDropTitanWeaponsForPlayer )
	Globalize( GiveNPCTitanTacticalAbility )
	Globalize( SetTitanOSForPlayer )
	Globalize( SetDecalForTitan )

	AddClientCommandCallback( "TitanEject", ClientCommand_TitanEject ) //
}


function TitanMoverDropPodLaunch( player, pod )
{
	pod.EndSignal( "OnDestroy" )

	pod.WaitSignal( "OnLaunch" )

	local angles = pod.GetUpVector().GetAngles()
	local offset = pod.GetUpVector() * 500

	pod.s.camera.Fire( "Enable", "!activator", 0, player )
	player.SetPlayerSettings( DEFAULT_BOT_TITAN )
	player.MinimapHide()
}

function TitanMoverDropPodImpact( player, pod )
{
	player.EndSignal( "Disconnected" )
	pod.EndSignal( "OnDestroy" )

	pod.WaitSignal( "OnImpact" )

	player.isSpawning = null

	pod.s.camera.FireNow( "Disable" )
	player.RespawnPlayer( pod )

	ScoreEvent_DropImpact( player )
}

function Titan_CreateDropPod( player )
{
	local dropPod = CreateMoverDropPod( player )

	InitTitanDropPod( dropPod )

	player.isSpawning = dropPod

	thread TitanMoverDropPodLaunch( player, dropPod )
	thread TitanMoverDropPodImpact( player, dropPod )

	return dropPod
}


function Titan_AddPlayer( player )
{
	player.playerClassData[thisClassName] <- {}
	player.s.ejectPressTime <- 0
	player.s.ejectPressCount <- 0
	player.s.lastStaggerTime <- 0
}

function GiveNPCTitanTacticalAbility( titan )
{
	local weapon = titan.GetOffhandWeapon( 1 )
	if ( weapon )
	{
		local weaponName = weapon.GetWeaponClassName()
		local abilityType = TTA_NONE

		switch ( weaponName )
		{
		case "mp_titanweapon_vortex_shield":
			abilityType = TTA_VORTEX
			break

		case "mp_titanability_smoke":
		case "mp_titanweapon_charge_cannon": //added by kwanyongjung
			abilityType = TTA_SMOKE
			break

		case "mp_titanability_bubble_shield":
			abilityType = TTA_WALL
			break

		default:
			Assert( 0, "invalid titan tactical ability " + weaponName )
			break
		}

		titan.SetTacticalAbility( weapon, abilityType )
	}
}

function GiveTitanWeaponsForPlayer( player, titan, existingTitan = false )
{
	if (GetMapName() == "mp_npe")
		return

	UpdateLastTitanLoadout( player )

	local table = player.playerClassData["titan"]

	if ( level.onOverrideLoadoutCallbacks )
		foreach ( callbackInfo in level.onOverrideLoadoutCallbacks )
			callbackInfo.func.acall( [callbackInfo.scope, player, table, true] )

	local soul = titan.GetTitanSoul()
	if ( soul )
	{
		if ( table.passive1 )
		{
			GivePassive( soul, table.passive1 )
		}
		if ( table.passive2 )
		{
			GivePassive( soul, table.passive2 )
		}
	}

	if ( player.IsBot() )
	{
		local bot_randomize_loadout = GetConVarInt( "bot_randomize_loadout" )
		if ( bot_randomize_loadout )
			RandomizeBotLoadout( table, true )
		OverrideBotLoadout( table, true )
	}

	//Existing Titan is to prevent disembark and eject from starting a burn card that's been put on deck after the Titan has been called in.

	if ( table.primaryWeapon )
		titan.GiveWeapon( table.primaryWeapon, table.primaryWeaponMods )

	if ( table.secondaryWeapon )
		titan.GiveWeapon( table.secondaryWeapon, table.secondaryWeaponMods )

	if ( table.offhandWeapons )
	{
	    local offhands = table.offhandWeapons

	    // take offhand weapons first if necessary
	    titan.TakeOffhandWeapon( 0 )
	    titan.TakeOffhandWeapon( 1 )

        if ( "weapon" in offhands[0] )
        {
			if ( !TryAssignOffhand( player, titan, offhands, 0, "offhands_titans_offensive" ) )
					titan.GiveOffhandWeapon( offhands[0].weapon, 0, [] )
	    }

        if ( "weapon" in offhands[1] )
        {
			if ( !TryAssignOffhand( player, titan, offhands, 1, "offhands_titans_defensive" ) )
				titan.GiveOffhandWeapon( offhands[1].weapon, 1, [] )
	    }
	}

	if ( titan.IsNPC() )
		GiveNPCTitanTacticalAbility( titan )

	local soul = player.GetTitanSoul()
	if ( !IsValid( soul ) )
		soul = titan.GetTitanSoul()
	Assert( IsValid( soul ) )

	local titanType = GetSoulTitanType( soul )

	// Give Titan it's signature active ability
	titan.TakeOffhandWeapon( 2 )

	titan.GiveOffhandWeapon( "mp_titanability_fusion_core", 2 )

	if ( IsValid( soul.rocketPod.model ) )
		soul.rocketPod.model.Kill()
	soul.rocketPod.model = null

	if ( LoadoutContainsRocketPodWeapon( player ) )
	{
		CreateTitanRocketPods( soul, titan )
	}

	if (!existingTitan)
	  	thread ApplyTitanBurnCards_Threaded( titan )

	if ( level.onChangeLoadoutCallbacks )
		foreach ( callbackInfo in level.onChangeLoadoutCallbacks )
			callbackInfo.func.acall( [callbackInfo.scope, player, table, true] )
}


function GiveHotDropTitanWeaponsForPlayer( player, titan )
{
	if ( IsTrainingLevel() )
		return

	local table = player.playerClassData["titan"]

	if ( table.primaryWeapon )
		titan.GiveWeapon( table.primaryWeapon, table.primaryWeaponMods )

	local soul = titan.GetTitanSoul()
	Assert( IsValid( soul ) )
	Assert( !IsValid( soul.rocketPod.model ) )

	wait 0.1

	if ( LoadoutContainsRocketPodWeapon( player ) )
		CreateTitanRocketPods( soul, titan )
}


function GiveTitanWeaponsForLoadoutData( titan, table )
{
	titan.GiveWeapon( table.primary, [] )

	if ( table.secondary )
		titan.GiveWeapon( table.secondary, [] )

    titan.TakeOffhandWeapon( 0 )
    titan.TakeOffhandWeapon( 1 )

	if ( table.ordnance )
		titan.GiveOffhandWeapon( table.ordnance, 0, [] )

	if ( table.special )
		titan.GiveOffhandWeapon( table.special, 1, [] )
}


function Titan_OnPlayerDeath( player, damageInfo )
{
	delete player.s.storedPilotLoadout
}


function PlayerCanEject( player )
{
	if ( !IsAlive( player ) )
		return false

	if ( !player.IsTitan() )
		return false

//	if ( "embarkingTitan" in player.s )
//		return false

	if ( "isDisembarking" in player.s )
		return false

	return true
}

function ClientCommand_TitanEject( player, ejectPressCount )
{
	if ( !PlayerCanEject( player ) )
		return true

	ejectPressCount = ejectPressCount.tointeger()

	if ( ejectPressCount < 0 )
		return false

	player.s.ejectPressTime = Time()
	player.s.ejectPressCount = ejectPressCount.tointeger()

	if ( player.s.ejectPressCount < 3 )
		return true

	thread TitanEjectPlayer( player )

	return true
}

function SetTitanOSForPlayer( player )
{
	local playerClassDataTable = GetPlayerClassDataTable( player, "titan" )
	local titanLoadoutVoice = playerClassDataTable.voiceChoice
	local titanOSEnumIndex = PersistenceGetEnumIndexForItemName( "titanOS", titanLoadoutVoice )

	if ( titanOSEnumIndex == -1 )
	{
		titanOSEnumIndex = 0
	}

	player.SetVoicePackIndex ( titanOSEnumIndex )
}


function SetDecalForTitan( player )
{
	local playerClassDataTable = GetPlayerClassDataTable( player, "titan" )
	local titanLoadoutDecal = playerClassDataTable.decal
	local team = player.GetTeam()
	local skinIndex

	if ( titanLoadoutDecal == null )
		skinIndex = team == TEAM_MILITIA ? 1 : 0
	else
		skinIndex = GetDecalSkinForTeam( titanLoadoutDecal, team )

	if ( player.IsTitan() )
	    player.SetSkin( skinIndex )
	else
	{
		local titan = player.GetPetTitan()
		if ( IsValid( titan ) )
			titan.SetSkin( skinIndex )
	}
}

