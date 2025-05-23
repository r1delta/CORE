printl( "Class Script: CBasePlayer" )
::DoIncludeScript( "_pdef", this)
__nextInputHandle <- 0

CBasePlayer.ClassName <- "CBasePlayer"
CBasePlayer.hasSpawned <- null
CBasePlayer.hasConnected <- null
CBasePlayer.operatorRig <- null
CBasePlayer.isSpawning <- null
CBasePlayer.disableWeaponSlots <- false
CBasePlayer.supportsXRay <- null
CBasePlayer.supportsPredictiveTargeting <- null
CBasePlayer.lastAbilityUseTime <- 0
CBasePlayer.clientCommandCallbacks <- null
CBasePlayer.pilotEjecting <- false
CBasePlayer.pilotEjectStartTime <- 0
CBasePlayer.pilotEjectEndTime <- 0

CBasePlayer.demigod <- false
CBasePlayer.rodeoDisabledTime <- 0
CBasePlayer.lastTitanTime <- 0

CBasePlayer.globalHint <- null
CBasePlayer.playerClassData <- null
CBasePlayer.escalation <- null
CBasePlayer.pilotAbility <- null
CBasePlayer.connectTime <- null
CBasePlayer.titansBuilt <- 0
CBasePlayer.spawnTime <- 0
CBasePlayer.serverFlags <- 0
CBasePlayer.watchingKillreplayEndTime <- 0
CBasePlayer.cloakedForever <- false
CBasePlayer.stimmedForever <- false
CBasePlayer.currentTargetPlayerOrSoul_Ent <- null
CBasePlayer.currentTargetPlayerOrSoul_LastHitTime <- 0

RegisterSignal( "OnRespawnPlayer" )
RegisterSignal( "NewViewAnimEntity" )
RegisterSignal( "PlayerDisconnected" )

function CBasePlayer::constructor()
{
	::CBaseEntity.constructor()

	clientCommandCallbacks = {}
}

// Server implementation of GetPersistentVar
function CBasePlayer::GetPersistentVar(key) {
    if (!IsValidKey(key)) return null
    local value = GetPersistentStringForClient(this, key, "pdata_null")
    local unpackedKey = UnpackKey(key)
    local type = pdef_keys[unpackedKey]

    if (type in pdef_enums) {
        return ((value == "pdata_null") || !PersistenceEnumValueIsValid(type, value)) ? null : value
    } else if (type == "int") {
        return (value == "pdata_null") ? 0 : value.tointeger()
    } else if (type == "float") {
        return (value == "pdata_null") ? 0.0 : value.tofloat()
    } else if (type == "bool") {
        return (value == "pdata_null") ? false : (value.tointeger() == 1)
    } else if (type == "string") {
        return (value == "pdata_null") ? "" : value
    } else {
        return (value == "pdata_null") ? "" : value
    }
}
// Client/UI implementation of GetPersistentVarAsInt
function CBasePlayer::GetPersistentVarAsInt(name) {
    local value = this.GetPersistentVar(name)
    return (typeof value == "integer") ? value : 0
}
// Server implementation of SetPersistentVar
function CBasePlayer::SetPersistentVar(key, value) {
    if (!IsValidKey(key, value)) return
    local serializedValue = (value == null) ? "pdata_null" : value
    local unpackedKey = UnpackKey(key)
    local type = pdef_keys[unpackedKey]
	 if(value == "") 
        serializedValue = "pdata_null"
	 
    if (serializedValue != "pdata_null") {
        if (type == "int") {
            serializedValue = value.tostring()
        } else if (type == "float") {
            serializedValue = value.tostring()
        } else if (type == "bool") {
            serializedValue = value ? "1" : "0"
        } else if (type == "string") {
            serializedValue = value
        }
    }
    SetPersistentStringForClient(this, key, serializedValue)
}

__RespawnPlayer <- CBasePlayer.RespawnPlayer
function CBasePlayer::RespawnPlayer( ent )
{
	this.Signal( "OnRespawnPlayer", { ent = ent } )

	// hack. Players should clear all these on spawn.
	this.ClearViewOffsetEntity()
	this.ClearAnimViewEntity()
	this.spawnTime = Time()

	this.ClearReplayDelay()
	this.ClearViewEntity()

	// titan melee can set these vars, and they need to clear on respawn:
	this.SetOwner( null )
	this.kv.VisibilityFlags = 7 // visible


	Assert( !this.GetParent(), this + " should not have a parent yet! - Parent: " + this.GetParent() )
	this.__RespawnPlayer( ent )
}

/*
CBasePlayer.__SetTrackEntity <- CBasePlayer.SetTrackEntity
function CBasePlayer::SetTrackEntity( ent )
{
	printl( "\nTime " + Time() + " Ent " + ent )

	DumpStack()
	this.__SetTrackEntity( ent )
}
*/

CBasePlayer.__ClearAnimViewEntity <- CBasePlayer.ClearAnimViewEntity
function CBasePlayer::ClearAnimViewEntity( time = 0.3 )
{
	local viewEnt = this.GetFirstPersonProxy()
	viewEnt.Hide()
	viewEnt.Anim_Stop()
	this.SetAnimViewEntityLerpOutTime( time )
	this.__ClearAnimViewEntity()

//	local viewEnt = self.GetFirstPersonProxy()
//	viewEnt.Hide()
//	self.__ClearAnimViewEntity()
}

CBasePlayer.__SetAnimViewEntity <- CBasePlayer.SetAnimViewEntity
function CBasePlayer::SetAnimViewEntity( model )
{
	// clear any attempts to hide the view anim entity
	this.Signal( "NewViewAnimEntity" )
	this.__SetAnimViewEntity( model )
}


function CBasePlayer::AddClientCommandCallback( commandString, callbackFunc )
{
	Assert( !(commandString in _ClientCommandCallbacks) )

	clientCommandCallbacks[commandString] <- callbackFunc
}


function CBasePlayer::ShowHint( message, binding )
{
	if ( globalHint == null )
	{
		globalHint = InstructorHint( message )
	}
	else
	{
		globalHint.SetCaption( message )
	}

	globalHint.SetBinding( binding )
	globalHint.ShowHint( this )
}


function CBasePlayer::HideHint()
{
	if ( globalHint == null )
		return

	globalHint.HideHint()
}

function CBasePlayer::GetDropEntForPoint( origin )
{
	return null
}


function CBasePlayer::GetPlayerClassData( myClass )
{
	Assert( myClass in playerClassData, myClass + " not in playerClassData" )
	return playerClassData[ myClass ]
}


function CBasePlayer::InitMPClasses()
{
	playerClassData = {}
        if (entindex() != 19) { SetName("player" +entindex() ) }
	if(!IsLobby())
	{
		Titan_AddPlayer( this )
		Wallrun_AddPlayer( this )
	}

	Loader_InitAllLoadoutTables( this )
}


function CBasePlayer::InitSPClasses()
{
	playerClassData = {}
	SetName( GetName() + entindex() )

	Titan_AddPlayer( this )
}


// function SpawnAsClass()
function CBasePlayer::SpawnAsClass( className = null )
{
	if ( !className )
	{
		className = GetPlayerClass()
	}

	switch ( className )
	{
		case level.pilotClass:
			Wallrun_OnPlayerSpawn( this )
			break

		default:
			Assert( 0, "Tried to spawn as unsupported " + className )
	}

	if ( "PlayerDidSpawnAsClass" in ::getroottable() )
		::PlayerDidSpawnAsClass( this, className )
}


function CBasePlayer::GiveScriptWeapon( weaponName, equipSlot = null )
{
	this.scope().GiveScriptWeapon( weaponName, equipSlot )
}

// OnClassChanged OnChangedClass ClassChanged ChangeClass ChangedClass
function CBasePlayer::OnChangedPlayerClass( oldPlayerClass )
{
	local playerClass = this.GetPlayerClass()

	if ( playerClass == oldPlayerClass )
		return

	local resultTable = {}
	resultTable.playerClass <- playerClass
	resultTable.oldPlayerClass <- oldPlayerClass
	this.Signal( "OnChangedPlayerClass", resultTable )

	// leave the old class
	switch ( oldPlayerClass )
	{
		case "titan":
			this.Signal( "OnLeftTitan" )
			PlayerStopsBeingTitan( this )
			break

		case level.pilotClass:
			break

		case "dronecontroller":
			DroneController_PlayerLeavingClass( this )
			break
	}

	// join the new class
	switch ( playerClass )
	{
		case "titan":
			local titanType = this.GetPlayerSettingsField( "footstep_type" )
			// code aint callin this currently
			CodeCallback_PlayerInTitanCockpit( this, this )
			this.Minimap_SetEnemyHeightArrow( false )
			this.Minimap_SetFriendlyHeightArrow( false )

			ResetTitanBuildTime( this )
			break

		case level.pilotClass:
			this.Minimap_SetEnemyHeightArrow( true )
			this.Minimap_SetFriendlyHeightArrow( true )
			ResetTitanBuildTime( this )
			RandomizeHead( this )
			break

		case "dronecontroller":
			DroneController_PlayerEnteringClass( this )
			break
	}
}

function CBasePlayer::OnDeathAsClass( damageInfo )
{
	switch ( GetPlayerClass() )
	{
		case "titan":
			Titan_OnPlayerDeath( this, damageInfo )
			break

		case level.pilotClass:
			Wallrun_OnPlayerDeath( this, damageInfo )
			break
	}
}

function CBasePlayer::IsDisconnected()
{
	return "disconnected" in this.s
}


function CBasePlayer::Disconnected()
{
	this.s.disconnected <- true
	this.Signal( "Disconnected" )
	level.ent.Signal( "PlayerDisconnected" )

	if ( HasSoul( this ) )
	{
		thread SoulDies( this.GetTitanSoul() )
	}

	foreach ( ent in this.s.ownedEntities )
	{
		ent.Destroy()
	}

	local titan = GetPlayerTitanInMap( this )
	if ( IsAlive( titan ) && titan.IsNPC() )
	{
		local soul = titan.GetTitanSoul()
		if ( IsValid( soul ) && soul.followOnly )
			FreeAutoTitan( titan )
		else
			titan.Die()
	}

	CleanupPlayerSatchels( this )
	CleanupPlayerProximityMines( this )
	CleanupPlayerLaserMines( this )
	CleanupPlayerTripleThreatMines( this )

	if ( globalHint != null )
	{
		globalHint.Kill()
		globalHint = null
	}

	switch ( GetPlayerClass() )
	{
		case "dronecontroller":
			thread DroneController_PlayerDisconnected( this )
			break
	}
}


function CBasePlayer::GetClassDataEnts()
{
	local ents = []
	local added

	if ( playerClassData == null )
		return ents;

	foreach ( ent in playerClassData )
	{
		added = false

		foreach ( newent in ents )
		{
			if ( newent == ent )
			{
				added = true
				break
			}
		}

		if ( !added )
			ents.append( ent )
	}

	return ents
}


function CBasePlayer::CleanupMPClasses()
{
}


const DEBUG_INPUT_CALLBACKS = 1

// used to link a global, always active gameui output to a function in the target script
function CBasePlayer::CreateInputCallback( outputName, func, env = null, isCritical = true )
{
	// player's gameUI isn't handling this output yet
	if ( !(outputName in gameUI.scope()) )
	{
		// create a table to hold a list of functions linked to this output
		gameUI.scope().linkedFunctions[outputName] <- {}

		gameUI.scope()[outputName] <- function():(outputName)
		{
			foreach( inputHandle, funcInfo in linkedFunctions[outputName] )
			{
				if ( funcInfo.critical )
				{
					Assert( funcInfo.closure, "InputCallback function for output " + outputName + " no longer exists! " + funcInfo.debugName )
					Assert( funcInfo.environment, "InputCallback environment for output " + outputName + " no longer exists! " + funcInfo.debugName )
				}
				else if ( !funcInfo.closure || !funcInfo.environment )
				{
					delete linkedFunctions[outputName][inputHandle]
					continue
				}

				funcInfo.closure.call( funcInfo.environment )
			}
		}

		gameUI.ConnectOutput( outputName, outputName )
	}

	local inputHandle = __nextInputHandle++

	// if there is no environment, we're probably binding to an inline function; this means we need to hold a strong referene to keep it from being deleted
	if ( !env )
	{
		env = getroottable()
		gameUI.scope().linkedFunctions[outputName][inputHandle] <- { closure = func, environment = env, debugName = "", critical = true }
	}
	else
	{
		gameUI.scope().linkedFunctions[outputName][inputHandle] <- { closure = func.weakref(), environment = env.weakref(), debugName = "", critical = isCritical }
	}

	if ( DEBUG_INPUT_CALLBACKS )
	{
		local debugName = env.tostring()
		if ( type( env ) == "table" && "self" in env )
			debugName = env.self.tostring()

		gameUI.scope().linkedFunctions[outputName][inputHandle].debugName = debugName
	}

	return inputHandle
}

function CBasePlayer::DestroyInputCallback( inputHandle )
{
	foreach ( outputName, functionSet in gameUI.scope().linkedFunctions )
	{
		if ( !(inputHandle in functionSet) )
			continue

		delete functionSet[inputHandle]

		if ( !functionSet.len() )
		{
			delete gameUI.scope().linkedFunctions[outputName]
			delete gameUI.scope()[outputName]
			gameUI.DisconnectOutput( outputName, outputName )
		}

		return
	}

	Assert( 0, "DestroyInputCallback: Could not find inputHandle in function list." )
}

function CBasePlayer::HasPredictiveTargetingSupport()
{
	return ( this.supportsPredictiveTargeting != null )
}

function CBasePlayer::HasXRaySupport()
{
	return ( this.supportsXRay != null )
}

function CBasePlayer::EnableXRay( teamNumber, playerIndex )
{
	Assert( this.HasXRaySupport() )
	this.scope().EnableXRayRenderMode( teamNumber, playerIndex )
}

function CBasePlayer::DisableXRay( teamNumber, playerIndex )
{
	Assert( this.HasXRaySupport() )
	this.scope().DisableXRayRenderMode( teamNumber, playerIndex )
}

function CBasePlayer::GetDoomedState()
{
	local soul = this.GetTitanSoul()
	if ( !IsValid( soul ) )
		return 0.0

	return soul.IsDoomed()
}

function CBasePlayer::EnableDemigod()
{
	this.demigod = true
}

function CBasePlayer::DisableDemigod()
{
	this.demigod = false
}

function CBasePlayer::IsDemigod()
{
	return this.demigod
}

function CBasePlayer::GetBodyType()
{
	return this.GetPlayerSettingsField( "weaponClass" )
}
RegisterClassFunctionDesc( CBasePlayer, "GetBodyType", "Get player body type" )


CBasePlayer.__SetTeam <- CBasePlayer.SetTeam
function CBasePlayer::SetTeam( team )
{
	this.__SetTeam( team )
	if ( HasSoul( this ) )
	{
		local soul = this.GetTitanSoul()
		local leftRocketPod = soul.rocketPod.model
		if ( IsValid( leftRocketPod ) )
		{
			//printt( "Setting team for left rocket pod" )
			SetSkinForTeam( leftRocketPod, team )
		}
	}
}


function CBasePlayer::IsFastPlayerCheck()
{
	if ( this.IsSprinting() )
		return true

	if ( this.IsWallRunning() )
		return true

	if ( this.IsDoubleJumping() )
		return true

	local miss_speed = ( 180*180 )
	if ( this.IsTitan() )
		miss_speed = 220*220

	if ( this.GetVelocity().LengthSqr() > miss_speed )
		return true

	return false
}


function CBasePlayer::IsFastPlayer()
{
	local result = IsFastPlayerCheck()
	if ( result )
		this.s.lastFastTime = Time()

	return result
}


function CBasePlayer::GiveExtraWeaponMod( mod )
{
	if ( this.HasExtraWeaponMod( mod ) )
		return

	local mods = this.GetExtraWeaponMods()
	mods.append( mod )

	this.SetExtraWeaponMods( mods )
}


function CBasePlayer::HasExtraWeaponMod( mod )
{
	local mods = this.GetExtraWeaponMods()
	foreach( _mod in mods )
	{
		if ( _mod == mod )
			return true
	}
	return false
}


function CBasePlayer::TakeExtraWeaponMod( mod )
{
	if ( !this.HasExtraWeaponMod( mod ) )
		return

	local mods = this.GetExtraWeaponMods()
	ArrayRemove( mods, mod )

	this.SetExtraWeaponMods( mods )
}

function CBasePlayer::ClearExtraWeaponMods()
{
	this.SetExtraWeaponMods( [] )
}


function CBasePlayer::SetPlayerPilotSettings( settingsName )
{
	this.SetPlayerRequestedSettings( settingsName )
}

function CBasePlayer::RecordLastMatchContribution( contribution )
{
	// replace with code function
}

function CBasePlayer::RecordLastMatchPerformance( matchPerformance )
{
	// replace with code function
}

function CBasePlayer::RecordSkill( skill )
{
	// replace with code function
	this.SetPersistentVar( "ranked.recordedSkill", skill )
}

function CBasePlayer::GetPlayerPilotSettings()
{
	return this.GetPlayerRequestedSettings()
}

// function UpdateMoveSpeedScale()
function CBasePlayer::UpdateMoveSpeedScale()
{
	local moveSpeedScale = 1.0

	if ( this.IsHuman() )
	{
		local playerHasStim = PlayerHasServerFlag( this, SFLAG_STIM_OFFHAND  )
		local playerHasMoveFastBurnCard = PlayerHasServerFlag( this, SFLAG_BC_FAST_MOVESPEED )
		if ( playerHasStim )
			moveSpeedScale = ABILITY_STIM_SPEED_MOD  //Stim speed boost wins over burn card speed boost
		else if ( playerHasMoveFastBurnCard )
			moveSpeedScale = BURNCARD_FAST_MOVESPEED
	}

	this.SetMoveSpeedScale( moveSpeedScale )
}


//CBasePlayer.__GetActiveBurnCardIndex <- CBasePlayer.GetActiveBurnCardIndex
function CBasePlayer::GetActiveBurnCardIndex()
{
	local value =  getroottable().GetActiveBurnCardIndex(this) - 1;
	return value
}

function _GetBurnCardPersPlayerDataPrefix()
{
	if ( IsPrivateMatch() && !IsDelta() )
		return "pm_bc"
	else
		return "bc"
}

//CBasePlayer.__SetActiveBurnCardIndex <- CBasePlayer.SetActiveBurnCardIndex
function CBasePlayer::SetActiveBurnCardIndex( val )
{
	this.SetPersistentVar( _GetBurnCardPersPlayerDataPrefix()  + ".uiActiveBurnCardIndex", val + 1 )
	// this.SetPersistentVar( "activeBCID", val + 1 )
	getroottable().SetActiveBurnCardIndexForPlayer( this, val + 1 )

}

function CBasePlayer::SetIsPlayingRanked( isPlayingRanked )
{
	printt("SetActiveBurnCardIndex " + isPlayingRanked )

	// getroottable().SetIsPlayingRanked(this,isPlayingRanked )
}

function CBasePlayer::GetPlayerIP() {
	return getroottable().GetPlayerIP(this);
}

function CBasePlayer::GetUserId() {
	return getroottable().GetPlayerUserId(this);
}


/*

CBasePlayer.__SetNextTitanRespawnAvailable <- CBasePlayer.SetNextTitanRespawnAvailable
function CBasePlayer::SetNextTitanRespawnAvailable( time )
{
	printt( "SetNextTitanRespawnAvailable " )
	DumpStack()
	return this.__SetNextTitanRespawnAvailable( time )
}

CBasePlayer.__GiveOffhandWeapon <- CBasePlayer.GiveOffhandWeapon
function CBasePlayer::GiveOffhandWeapon( weapon, slot, mods )
{
	printt( "GGDG " )
	printt( this + " GiveOffhandWeapon", weapon, slot, mods )
	DumpStack()
	return this.__GiveOffhandWeapon( weapon, slot, mods )
}

CBasePlayer.__EnableWeapon <- CBasePlayer.EnableWeapon
function CBasePlayer::EnableWeapon()
{
	printt( this + " enableWeapon" )
	return this.__EnableWeapon()
}

CBasePlayer.__DisableWeapon <- CBasePlayer.DisableWeapon
function CBasePlayer::DisableWeapon()
{
	printt( this + " disableWeapon" )
	return this.__DisableWeapon()
}


CBasePlayer.__EnableWeaponViewmodel <- CBasePlayer.EnableWeaponViewmodel
function CBasePlayer::EnableWeaponViewmodel()
{
	printt( this + " enableWeaponViewmodel" )
	return this.__EnableWeaponViewmodel()
}

CBasePlayer.__DisableWeaponViewmodel <- CBasePlayer.DisableWeaponViewmodel
function CBasePlayer::DisableWeaponViewmodel()
{
	printt( this + " disableWeaponViewmodel" )
	return this.__DisableWeaponViewmodel()
}


CBasePlayer.__HolsterWeapon <- CBasePlayer.HolsterWeapon
function CBasePlayer::HolsterWeapon()
{
	printt( this + " HolsterWeapon" )
	return this.__HolsterWeapon()
}

CBasePlayer.__DeployWeapon <- CBasePlayer.DeployWeapon
function CBasePlayer::DeployWeapon()
{
	printt( this + " DeployWeapon" )
	DumpStack()
	return this.__DeployWeapon()
}


CBasePlayer.__TakeWeapon <- CBasePlayer.TakeWeapon
function CBasePlayer::TakeWeapon( wep )
{
	printt( this + " TakeWeapon " + wep )
	return this.__TakeWeapon( wep )
}


CBasePlayer.__GiveWeapon <- CBasePlayer.GiveWeapon
function CBasePlayer::GiveWeapon( wep )
{
	printt( this + " GiveWeapon " + wep )
	return this.__GiveWeapon( wep )
}

*/