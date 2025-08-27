// From game_const.h
LIFE_ALIVE		<- 0			// up and kicking
LIFE_DYING		<- 1			// not alive, not dead -- death anim, falling
LIFE_DEAD		<- 2			// corpse

experimentalClient <- false

::RUMBLE_FLAGS_NONE 			<- 0x0000
::RUMBLE_FLAG_STOP				<- 0x0001 // Stop any instance of this type of effect that's already playing.
::RUMBLE_FLAG_LOOP				<- 0x0002 // Make this effect loop.
::RUMBLE_FLAG_RESTART			<- 0x0004 // If this effect is already playing, restart it.
::RUMBLE_FLAG_UPDATE_SCALE		<- 0x0008 // Apply DATA to this effect if already playing, but don't restart.
::RUMBLE_FLAG_ONLYONE			<- 0x0010 // Don't play this effect if it is already playing.
::RUMBLE_FLAG_RANDOM_AMPLITUDE	<- 0x0020 // Amplitude scale will be randomly chosen. Between 10% and 100%
::RUMBLE_FLAG_INITIAL_SCALE		<- 0x0040 // Data is the initial scale to start this effect ( * 100 )

// Shortcuts for the console, just like gp <- GetPlayerArray
glc <- GetLocalClientPlayer
glcp <- GetLocalClientPlayer
glv <- GetLocalViewPlayer
glvp <- GetLocalViewPlayer

/***************************************************
Code constants already registered for script

enum GameMovementImpactEventType
{
	GM_IET_LANDING = 0
	GM_IET_WALLSLAM
	GM_IET_WALLSLAM_AIR
	GM_IET_HUMANFOOTSTEP
	GM_IET_TITANFOOTSTEP

	GM_IET_COUNT
	GM_IET_INVALID
}

enum Crosshair_State
{
	CROSSHAIR_STATE_SHOW_ALL = 0
	CROSSHAIR_STATE_HIT_INDICATORS_ONLY
	CROSSHAIR_STATE_HIDE_ALL

	CROSSHAIR_STATE_COUNT
}

***************************************************/

function IsSingleplayer()
{
	return !IsMultiplayer()
}

function RandomIntRange( min, max )
{
	return CodeRandomInt( min, max - 1 )
}

function ArrayRemove( array, remove )
{
	Assert( type( array ) == "array" )

	foreach ( index, ent in array )
	{
		if ( ent == remove )
		{
			array.remove( index )
			break
		}
	}
}

function StringToColorArray( colorString, delimiter = " " )
{
	local table = StringToColors( colorString, delimiter )
	local arr = []
	arr.append( table.r )
	arr.append( table.g )
	arr.append( table.b )

	if ( "a" in table )
		arr.append( table.a )
	else
		arr.append( 255 )

	return arr
}



function TimeToString( time, msec = false )
{
	local minsleft = time / 60
	local secsleft = time.tointeger() % 60
	if ( msec )
	{
		local msecsleft = (time.tofloat() - time.tointeger())
		return format( "%02d:%02d", secsleft, msecsleft * 100 )
	}
	else
	{
		return format( "%02d:%02d", minsleft, secsleft )
	}
}

function GetFraction( value, min, max )
{
	return ( value - min ) / ( max - min )
}

function GetFractionClamped( value, min, max )
{
	local frac = GetFraction( value, min, max )
	return clamp( frac, 0.0, 1.0 )
}

function GetValueFromFraction( value, value_min, value_max, return_min, return_max )
{
	local frac = GetFractionClamped( value.tofloat(), value_min.tofloat(), value_max.tofloat() )
	local retVal = return_min.tofloat() + ( ( return_max.tofloat() - return_min.tofloat() ) * frac )
	return clamp( retVal, return_min, return_max )
}

function ReloadScripts()
{
	reloadingScripts = true

	DeregisterRespawnCommands()

	IncludeFile( "client/cl_melee" )

	IncludeFile( "client/_cl_misc_hud" )

	IncludeFile( "client/cl_cinematic" )
	IncludeFile( "client/cl_carrier" )
	IncludeFile( "client/cl_fx" )
	IncludeTitanEmbark()

	IncludeFile( "_dialogue_shared" )
	IncludeFile( "client/_cl_music" )
	IncludeFile( "client/cl_scoreboard" )
	IncludeFile( "client/_cl_dialogue.nut" )
	IncludeFile( "client/cl_screenfade" )
	IncludeFile( "_damage_history" )
	IncludeScript( "client/_cl_anim" )

	IncludeFile( "client/cl_titan_enemy_tracker" )

	IncludeFile( "client/objects/cl_control_panel" )
	IncludeFile( "client/cl_fullscreen_map" )
	IncludeFile( "client/cl_main_hud" )
	IncludeFile( "client/cl_capture_point" )

	IncludeFile( "client/cl_introscreen" )
	IncludeFile( "client/cl_player" )
	IncludeFile( "_burncards_shared" )
	IncludeFile( "client/cl_burncard_selector" )
	IncludeFile( "client/cl_burncards" )

	IncludeFile( "_ranked_shared" )
	IncludeFile( "_ranked_gems" )

	if ( IsLobby() )
	{
		IncludeFile( "client/cl_burncards_lobby" )
	}
	else
	{
		if ( level.rankedPlayEnabled )
		{
			IncludeFile( "client/cl_ranked" )
		}
	}

	IncludeFile( "client/cl_respawnselect" )
	IncludeFile( "client/cl_replacement_titan_hud" )
	IncludeFile( "client/cl_flyout" )
	IncludeFile( "client/cl_crosshair")
	IncludeFile( "client/cl_rumble" )
	IncludeFile( "weapons/_arc_cannon" )
	IncludeFile( "weapons/_vortex" )
	IncludeFile( "weapons/_grenade" )
	IncludeScript( "weapons/_weapon_utility" )
	IncludeFile( "weapons/_smart_ammo_client")
	IncludeFile( "client/cl_titan_hud" )
	IncludeFile( "client/_cl_indicators_hud" )
//	IncludeScript( "_utility_client" )
	IncludeScript( "_utility_shared" )
	IncludeScript( "_utility_shared_all" )
	IncludeFile( "client/cl_vdu.nut" )
	IncludeFile( "_flightpath_shared" )
	IncludeFile( "client/cl_rodeo" )
	IncludeFile( "_titan_shared" )
	IncludeFile( "client/cl_titan_cockpit" )
	IncludeFile( "client/cl_titan_dialogue" )
	IncludeFile( "client/cl_rank_chip_dialogue" )
	IncludeFile( "client/cl_data_knife" )
	IncludeFile( "_melee_shared" )
	IncludeFile( "_rodeo_shared" )
	IncludeScript( "client/_cl_material_proxies" )
	IncludeFile( "_player_view_shared" )

	IncludeGameModeClientScripts()

	IncludeScript( "_codecallbacks_shared", getroottable() )

	if ( IsMultiplayer() )
	{
		IncludeFile( "client/cl_loader" )
	}

	local mapScriptName = "client/levels/cl_" + GetMapName()

	if ( ScriptExists( mapScriptName ) )
		IncludeFile( mapScriptName )


	ReloadScriptCallbacks()

	reloadingScripts = false

	return ( "reloaded client scripts" )
}

function PlayerIsFemale( player )
{
	local loadoutIndex = player.GetPersistentVar( "pilotSpawnLoadout.index" )
	return player.GetPersistentVar( "pilotLoadouts[" + loadoutIndex + "].race" ) == RACE_HUMAN_FEMALE
}

function AddCreateCallback( className, callbackFunc )
{
	Assert( "createCallbacks" in level )
	Assert( type( this ) == "table", "AddCreateCallback can only be added on a table. " + type( this ) )
	AssertParameters( callbackFunc, 2, "entity, isRecreate" )

	if ( !( className in level.createCallbacks ) )
		level.createCallbacks[className] <- []

	// Check if this function has already been added
	foreach( info in level.createCallbacks[className] )
		Assert( info.func != callbackFunc )

	local callbackInfo = {}
	callbackInfo.func <- callbackFunc
	callbackInfo.scope <- this

	level.createCallbacks[className].append( callbackInfo )
}

function AddKillReplayStartedCallback( callbackFunc )
{
	Assert( "killReplayStartCallbacks" in level )
	Assert( type( this ) == "table", "AddKillReplayStartedCallback can only be added on a table. " + type( this ) )
	AssertParameters( callbackFunc, 0, "" )

	// Check if this function has already been added
	foreach( info in level.killReplayStartCallbacks )
		Assert( info.func != callbackFunc )

	local callbackInfo = {}
	callbackInfo.func <- callbackFunc
	callbackInfo.scope <- this

	level.killReplayStartCallbacks.append( callbackInfo )
}

function AddKillReplayEndedCallback( callbackFunc )
{
	Assert( "killReplayEndCallbacks" in level )
	Assert( type( this ) == "table", "AddKillReplayEndedCallback can only be added on a table. " + type( this ) )
	AssertParameters( callbackFunc, 0, "" )

	// Check if this function has already been added
	foreach( info in level.killReplayEndCallbacks )
		Assert( info.func != callbackFunc )

	local callbackInfo = {}
	callbackInfo.func <- callbackFunc
	callbackInfo.scope <- this

	level.killReplayEndCallbacks.append( callbackInfo )
}

function GetAllTitans()
{
	local titans = []
	// returns the first owned titan found
	foreach ( soul in level.allTitanSouls )
	{
		if ( !IsValid( soul ) )
			continue

		if ( !IsAlive( soul.GetTitan() ) )
			continue

		titans.append( soul.GetTitan() )
	}

	return titans
}


function AddDestroyCallback( className, callbackFunc )
{
	Assert( "destroyCallbacks" in level )
	Assert( type( this ) == "table", "AddDestroyCallback can only be added on a table. " + type( this ) )
	AssertParameters( callbackFunc, 1, "entity" )

	if ( !( className in level.destroyCallbacks ) )
		level.destroyCallbacks[className] <- []

	local callbackInfo = {}
	callbackInfo.func <- callbackFunc
	callbackInfo.scope <- this

	level.destroyCallbacks[className].append( callbackInfo )
}

function AddOnDeathCallback( className, callbackFunc )
{
	Assert( "onDeathCallbacks" in level )
	Assert( type( this ) == "table", "AddOnDeathCallback can only be added on a table. " + type( this ) )
	AssertParameters( callbackFunc, 1, "entity" )

	if ( !( className in level.onDeathCallbacks ) )
		level.onDeathCallbacks[className] <- []

	local callbackInfo = {}
	callbackInfo.func <- callbackFunc
	callbackInfo.scope <- this

	level.onDeathCallbacks[className].append( callbackInfo )

	// Check if DoDeathCallback has already been enabled for this class
	foreach( info in level.createCallbacks[className] )
	{
		if ( info.func == __OnDeathCallbackEnable )
			return
	}
	AddCreateCallback( className, __OnDeathCallbackEnable )
}

function AddOnDeathOrDestroyCallback( className, callbackFunc )
{
	Assert( "onDeathOrDestroyCallbacks" in level )
	Assert( type( this ) == "table", "AddOnDeathOrDestroyCallback can only be added on a table. " + type( this ) )
	AssertParameters( callbackFunc, 1, "entity" )

	if ( !( className in level.onDeathOrDestroyCallbacks ) )
		level.onDeathOrDestroyCallbacks[className] <- []

	local callbackInfo = {}
	callbackInfo.func <- callbackFunc
	callbackInfo.scope <- this

	level.onDeathOrDestroyCallbacks[className].append( callbackInfo )

	// Check if DoDeathCallback has already been enabled for this class
	if ( className in level.createCallbacks )
	{
		foreach( info in level.createCallbacks[className] )
		{
			if ( info.func == __OnDeathCallbackEnable )
				return
		}
	}
	AddCreateCallback( className, __OnDeathCallbackEnable )
}

function __OnDeathCallbackEnable( entity, isRecreate )
{
	entity.DoDeathCallback( true )
}

function AddCinematicEventFlagChangedCallback( flag, callbackFunc ) //Only for local player. Clients don't get sent information about other clients' cinematicEventFlags
{
	AssertParameters( callbackFunc, 1, "player" )

	if ( !( flag in level.cinematicEventFlagChangedCallback ) )
		level.cinematicEventFlagChangedCallback[ flag ] <- []

	local callbackInfo = {}
	callbackInfo.scope <- this
	callbackInfo.func <- callbackFunc

	//printt( "Adding callback for flag: " + flag + " with function: " + callbackFunc )

	level.cinematicEventFlagChangedCallback[ flag ].append( callbackInfo )
}

function PrintAspectRatioInfo( desiredWidth, width, height )
{
	local aspectRatio = height / width
	printt( "Width/Height:", desiredWidth, ((desiredWidth * aspectRatio) + 0.5).tointeger() )
}

if ( !IsMultiplayer() )
{
	// work around for impractical split screen thing
	function GetLocalViewPlayer()
	{
		return GetPlayerArray()[0]
	}
}

function SniperCam_IsActive( player )
{
	return player.SniperCam_IsActive()
}

function SetExperimentalClient( value )
{
	experimentalClient = value
}

function ExperimentalClient()
{
	return experimentalClient
}


// returns array of client ents that match a classname and name mask
function GetClientEntArray( classname, nameMask )
{
	local ents = GetClientEntArrayBySignifier( classname )

	local returns = []
	foreach ( ent in ents )
	{
		if ( ent.GetName().find( nameMask ) == 0 )
			returns.append( ent )
	}

	return returns
}

// testing functions
function vdu()
{
	local player = GetLocalViewPlayer()
	player.Signal( "EndGuidance" )
	player.EndSignal( "EndGuidance" )

	for ( ;; )
	{
		vdufunc( player )
		wait 0
	}
}

function vdufunc( player )
{
	local attach = player.LookupAttachment( "hijack" )
	local origin = player.GetAttachmentOrigin( attach )
	local angles = player.GetAttachmentAngles( attach )
	local forward = angles.AnglesToForward()
	local right = angles.AnglesToRight()
	local up = angles.AnglesToUp()

	//angles = angles.AnglesCompose( Vector( 0, 180, 0 ) )
	origin += forward * -200
	//origin += up * 50

	level.camera.SetOrigin( origin )
	level.camera.SetAngles( angles )

}

//-----------------------------------------------------------
// CreatePropDynamic( model ) - create a generic prop_dynamic with default properties
//------------------------------------------------------------
function CreatePropDynamic( model, origin = null, angles = null )
{
	if( !origin )
		origin = Vector( 0,0,0 )
	if( !angles )
		angles = Vector( 0,0,0 )

	local prop_dynamic = CreateClientSidePropDynamic( origin, angles, model )

	return prop_dynamic
}

//-----------------------------------------------------------
// CreateScriptRef() - create a script ref
//------------------------------------------------------------
function CreateScriptRef( origin = null, angles = null )
{
	local ent = CreatePropDynamic( "models/dev/editor_ref.mdl" )

	ent.Hide()

	if ( origin )
		ent.SetOrigin( origin )
	if ( angles )
		ent.SetAngles( angles )

	return ent
}

function GetComputerName( player )
{
	local name = player.GetPlayerName()
	local msg = split( name, " " )
	if ( msg.len() < 2 )
		return ""

	msg = split( msg.top(), "(" )
	if ( msg.len() < 1 )
		return ""

	msg = split( msg[0], "-" )

	if ( msg.len() < 1 )
		return ""
	return msg[0]
}

function AddPlayerFunc( func )
{
	level.addPlayerFuncs.append( func )
}

//Function checks if use button is being taken up by a higher priority action like
//eject, etc
function IsUseButtonAvailable( player )
{
	if ( !IsValid( player ) )
		return false

	// Can't detonate satchels during synched melee
	if ( player.ContextAction_IsMeleeExecution() )
		return false

	if ( player.IsTitan() )
	{
		// User is pressing X to eject, so don't detonate satchels
		if ( ( "ejectEnableTime" in player.s ) && Time() - player.s.ejectEnableTime < EJECT_FADE_TIME )
			return false
	}

	return true
}


//CLIENT VERSION OF SERVER WARP FUNCS
function CLWarpoutEffect( dropship )
{
	if ( !IsValid( dropship ) )
		return

	__WarpOutEffectShared( dropship )

	thread __DelayDropshipDelete( dropship )
}

function __DelayDropshipDelete( dropship )
{
	dropship.EndSignal( "OnDeath" )

	wait 0.1 // so the dropship wont pop out before it warps out

	dropship.Kill()
}

function CLWarpinEffect( model, animation, origin, angles, sfx = null )
{
	//we need a temp dropship to get the anim offsets
	local start = __GetWarpinPosition( model, animation, origin, angles )

	__WarpInEffectShared( start.origin, start.angles, sfx )
}


function __GetWarpinPosition( model, animation, origin, angles )
{
	local start

	local dummyDropship = CreatePropDynamic( model, origin, angles )
	dummyDropship.Hide()
	dummyDropship.SetOrigin( origin )
    dummyDropship.SetAngles( angles )
	start = dummyDropship.Anim_GetAttachmentAtTime( animation, "ORIGIN", 0 )
	start.origin <- start.position
    start.angles <- start.angle
	dummyDropship.Destroy()

	return start
}

function CoreActivatedVO( player )
{
	player.EndSignal( "OnDeath" )

	TitanCockpit_PlayDialog( player, "core_activated" )
	wait TITAN_CORE_CHARGE_TIME
	if ( player.IsTitan() )
		TitanCockpit_PlayDialog( player, "core_fired" )

	local coreDuration = GetTitanCoreActiveTime( player )

	// If coreDuration is less that 5 for whatever reason, dont even bother
	if ( coreDuration <= 5 )
		return

	local expiringTime = coreDuration / 1.5
	wait expiringTime
	
	if ( player.IsTitan() )
		TitanCockpit_PlayDialog( player, "core_expiring" )
}

function MonitorFlickerAndChange( screen, modelname )
{
	screen.EndSignal( "OnDestroy" )

	screen.SetModel( modelname )
	local state = false
	local flickers = RandomInt( 2, 6 ) * 2 + 1// always an odd number

	for( local i = 0; i < flickers; i++ )
	{
		if ( !state )
		{
			screen.Show()
			state = true
		}
		else
		{
			screen.Hide()
			state = false
		}
		wait RandomFloat( 0, 0.15 )
	}
}


function AddCallback_OnClientScriptInit( callbackFunc )
{
	AddCallback_Generic( "onClientScriptInitCallback", callbackFunc, this )
}

function AddCallback_OnInitPlayerScripts( callbackFunc )
{
	AddCallback_Generic( "onInitPlayerScripts", callbackFunc, this )
}



function SetHealthBarVisibilityOnEntity( entity, visible )
{
	if ( !( "healthBarVisible" in entity.s ) )
		entity.s.healthBarVisible <- visible
	else
		entity.s.healthBarVisible = visible
}

function ShouldShowHealthBarOnEntity( entity )
{
	if( !IsValid( entity ) )
		return true

	if ( !( "healthBarVisible" in entity.s ) )
		return true

	return entity.s.healthBarVisible
}

function AddCreateMainHudCallback( callbackFunc )
{
	Assert( "mainHudCallbacks" in level )
	Assert( type( this ) == "table", "AddCreateMainHudCallback can only be added on a table. " + type( this ) )
	AssertParameters( callbackFunc, 2, "mainVGUI, player" )

	local callbackInfo = {}
	callbackInfo.func <- callbackFunc
	callbackInfo.scope <- this

	level.mainHudCallbacks.append( callbackInfo )
}

function AddCreatePilotCockpitCallback( callbackFunc )
{
	Assert( "pilotHudCallbacks" in level )
	Assert( type( this ) == "table", "AddCreatePilotCockpitCallback can only be added on a table. " + type( this ) )
	AssertParameters( callbackFunc, 2, "cockpit, player" )

	local callbackInfo = {}
	callbackInfo.func <- callbackFunc
	callbackInfo.scope <- this

	level.pilotHudCallbacks.append( callbackInfo )
}

function AddCreateTitanCockpitCallback( callbackFunc )
{
	Assert( "titanHudCallbacks" in level )
	Assert( type( this ) == "table", "AddCreateTitanCockpitCallback can only be added on a table. " + type( this ) )
	AssertParameters( callbackFunc, 2, "cockpit, player" )

	local callbackInfo = {}
	callbackInfo.func <- callbackFunc
	callbackInfo.scope <- this

	level.titanHudCallbacks.append( callbackInfo )
}

function AddOnModelChangedCallback( callbackFunc )
{
	Assert( "onModelChangedCallbacks" in level )
	Assert( type( this ) == "table", "AddOnModelChangedCallback can only be added on a table. " + type( this ) )
	AssertParameters( callbackFunc, 1, "entity" )

	local callbackInfo = {}
	callbackInfo.func <- callbackFunc
	callbackInfo.scope <- this

	level.onModelChangedCallbacks.append( callbackInfo )
}

function AddLocalPlayerDidDamageCallback( callbackFunc )
{
	Assert( "onLocalPlayerDidDamageCallbacks" in level )
	Assert( type( this ) == "table", "AddLocalPlayerDidDamageCallback can only be added on a table. " + type( this ) )
	AssertParameters( callbackFunc, 2, "attacker, params" )

	local callbackInfo = {}
	callbackInfo.func <- callbackFunc
	callbackInfo.scope <- this

	level.onLocalPlayerDidDamageCallbacks.append( callbackInfo )
}

function AddCallback_LocalClientPlayerSpawned( callbackFunc )
{
	Assert( "onLocalClientPlayerSpawnedCallbacks" in level )
	Assert( type( this ) == "table", "AddCallback_LocalClientPlayerSpawned can only be added on a table. " + type( this ) )
	AssertParameters( callbackFunc, 1, "entity" )

	local callbackInfo = {}
	callbackInfo.func <- callbackFunc
	callbackInfo.scope <- this

	level.onLocalClientPlayerSpawnedCallbacks.append( callbackInfo )
}

function AddCallback_LocalViewPlayerSpawned( callbackFunc )
{
	Assert( "onLocalViewPlayerSpawnedCallbacks" in level )
	Assert( type( this ) == "table", "AddCallback_LocalViewPlayerSpawned can only be added on a table. " + type( this ) )
	AssertParameters( callbackFunc, 1, "entity" )

	local callbackInfo = {}
	callbackInfo.func <- callbackFunc
	callbackInfo.scope <- this

	level.onLocalViewPlayerSpawnedCallbacks.append( callbackInfo )
}

function PlayerProgressionAllowed( player = null )
{
	if ( IsPrivateMatch() )
		return false
	return true
}

function TryShowSpectatorSelectButtons( clientPlayer )
{
	Assert( clientPlayer == GetLocalClientPlayer() )

	if ( !AreSpectatorControlsActiveForLocalClientPlayer() )
		return

	if ( RespawnSelectionPending() == true )
		return

	clientPlayer.cv.spectatorPrev.Show()
	clientPlayer.cv.spectatorNext.Show()

}

function HideSpectatorSelectButtons( clientPlayer )
{
	Assert( clientPlayer == GetLocalClientPlayer() )
	clientPlayer.cv.spectatorPrev.Hide()
	clientPlayer.cv.spectatorNext.Hide()
}
