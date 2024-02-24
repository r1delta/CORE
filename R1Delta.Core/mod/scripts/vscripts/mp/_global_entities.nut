//=========================================================
//	_global_entities
//  Create/initialize various global entities
//=========================================================

function main()
{
	// if you set this to zero, various things that spam developer 2 won't run
	const SPAMS_DEVELOPER2 = 1

	InitialGlobalSetup()

	// puts a gameUI on each player, accessible via functions in _gameUI
	IncludeFile( "mp/_gameui" )

	level._npcSpawnCallbacks <- [] // all NPCs run these on spawned

	AddSpawnFunction( "player", PlayerPreInit )
	AddSpawnFunction( "trigger_hurt", InitDamageTriggers )

	//IncludeClassScript( "player", "entities/player_gameui" )

	_cc <- CreateEntity( "point_clientcommand" )

	SetWorldFadeIntro()

	if ( IsMultiplayer() )
	{
		IncludeFile( "_loader" )
		AddSpawnFunction( "player", SetupLoader )
	}

	PrecacheModel( "models/dev/editor_ref.mdl" )
	PrecacheModel( "models/dev/empty_model.mdl" )

	//if ( IsMenuLevel() )
//	if ( IsLobby() )
//	{
//	}
//	else
	if ( IsMultiplayer() )
	{
		// playlists.txt 에서 maps 제거.
		//Assert( GetMapCountForCurrentPlaylist(), "No maps in current playlist!" )

		level.damagePushScale <- GetCurrentPlaylistVarFloat( "damage_push", 0.0 )
		level.vortexPushScale <- GetCurrentPlaylistVarFloat( "vortex_push", 0.0 )

		MP_Precache()

		local auto = CreateEntity( "logic_auto" )
		auto.Set( "spawnflags", 1 )
		auto.ConnectOutput( "OnMultiNewMap", "ScriptCallback_OnNewMap" )

		// I want level.ent to exist!
		IncludeFile( "mp/_destructibles" )

		AddSpawnFunction( "player", MP_PlayerPostInit )

		AddSpawnFunction( "npc_crow", NPC_NoTarget )

		IncludeFile( "mp/_dialogue_chatter" )
		IncludeFile( "mp/_titan_hotdrop" )

		IncludeFile( "mp/_zipline" )
		IncludeFile( "_passives" )
		IncludeFileAllowMultipleLoads( "mp/_dogfighter" )

		if ( GetCurrentPlaylistVarInt( "script_leak", 0 ) )
		{
			thread ScriptLeakDetector()
		}
	}
	else
	{
		SP_Precache()
		IncludeFile( "_sp_player" )
		IncludeFile( "mp/class_titan" )
		//IncludeFile( "_player_health" )

		local auto = CreateEntity( "logic_auto" )
		auto.Set( "spawnflags", 1 )


		PrecacheModel( ATLAS_MODEL ) // ToDo - try moving this out of here since all levels may not have marvins. Need to make sure no levels break
		PrecacheModel( "models/robots/marvin/marvin.mdl" ) // ToDo - try moving this out of here since all levels may not have marvins. Need to make sure no levels break
	}

	IncludeFile( "mp/_leeching" )
	IncludeFile( "mp/_player_leeching" )

	if ( IsMultiplayer() )
	{
		IncludeFile( "mp/_titan_health" )

		IncludeFile( "mp/_marvin_jobs" )
		IncludeFile( "mp/_marvin_faces" )
		IncludeFile( "mp/_trigger_functions" )
		IncludeFile( "mp/_spawn_functions" )
		IncludeFile( "mp/_vehicle_utility" )
		IncludeFile( "mp/_vehicle_behavior" )
		IncludeFile( "mp/_goblin_dropship" )
		IncludeFile( "_flightpath_shared" )
	}


	IncludeFile( "mp/_melee" )
	IncludeFile( "mp/_rodeo" )
	IncludeFile( "_damage_history" )
	IncludeTitanEmbark()

	//prop_vehicle_choreo_generic currently expects a model; we're using this one
	PrecacheModel( "models/weapons/rspn101/ptpov_rspn101.mdl" )

	// model used when no model is provided
	PrecacheModel( "models/error.mdl" )

	level.worldspawn <- Entities.FindByClassname( null, "worldspawn" )

	RegisterSignal( "OnFly" )
	RegisterSignal( "OnDissolve" )
	RegisterSignal( "OnKilledEnemy" )

	g_dropZones <- []

	if ( IsMultiplayer() )
		AddSpawnCallback( "player", __PlayerDidSpawn ) // this should be called last to allow any other scripts to run first

	PrecacheSprite( "sprites/zerogxplode.spr" )

	if ( IsMultiplayer() )
	{
		if ( GameRules.GetGameMode() == "arena" )
			thread ArenaMatcher()

		if ( GameRules.GetGameMode() == "clan_arena" )
			thread ClanArena()
	}
}



function SetWorldFadeIntro()
{
	GetEnt( "worldspawn" ).kv.startdark = true
}


function PlayerPreInit( self )
{
	// entities that get deleted when this player disconnects
	self.s.ownedEntities <- []

	if ( !IsMultiplayer() )
	{
		player.s.clientScriptInitialized <- true

		// Used to provide a common interface for scripting player input
		CreatePlayerGameUI( self )
	}
}

function MP_PlayerPostInit( self )
{
	local player = self
	Assert( !player.hasSpawned )
	Assert( IsMultiplayer() )

	player.InitMPClasses()

	player.hasSpawned = true

	// Used to provide a common interface for scripting player input
	CreatePlayerGameUI( player )
}

function LevelFinishedStarting()
{
	level.LevelStarting = false
}

function __PlayerDidSpawn( player )
{
	if ( "PlayerDidSpawn" in ::getroottable() )
		thread PlayerDidSpawn()

	RunFunctionInAllFileScopes( "PlayerDidSpawn" )

	FlagSet( "PlayerDidSpawn" )
	level.ent.Signal( "PlayerDidSpawn", { player=player } )
}

function ResetTitanMeleeRanges( player )
{
	if ( !player )
		player = level.player

	// defaults as of changelist 21004 (jiesang)
	ClientCommand( player, "npc_titan_charge_range 400" ) // backhand swipe
	ClientCommand( player, "npc_titan_melee_range 200" ) // stomp
}

function ClientCommand( client, command, delay = 0 )
{
	EntFireByHandle( _cc, "Command", command, delay, client, null )
}
RegisterFunctionDesc( "ClientCommand", "Execute the specified console command with optional delay. (ex. \"r_drawscreenoverlay 1\")" )

_sc <- CreateEntity( "point_servercommand" )
function ServerCommand( command, delay = 0 )
{
	EntFireByHandle( _sc, "Command", command, delay, null, null )
}
RegisterFunctionDesc( "ServerCommand", "Execute the specified console command with optional delay. (ex. \"r_drawscreenoverlay 1\")" )

_stringDelegate <- {
	function _get( key ) { return key }
}
_str <- delegate _stringDelegate : {}

__trackedRefs <- {}

function AddTrackRef( ref )
{
	//printl( "Adding ref for: " + ref.tostring() )
	__trackedRefs[ref.tostring()] <- ref.weakref()
}

function RefTrackerThink()
{
	foreach ( refName, refObj in __trackedRefs )
	{
		if ( !refObj )
		{
			delete __trackedRefs[refName]
			if ( SPAMS_DEVELOPER2 )
				level.ent.Fire( "CallScriptFunction", "RefTrackerThink", 0.033 )
			return
		}

		if ( IsValid_ThisFrame( refObj ) )
			continue

		printl( "UNFREED REFERENCE (use weakref for entities): " + refName )
		__trackedRefs[ refName ] = null
	}

	if ( SPAMS_DEVELOPER2 )
		level.ent.Fire( "CallScriptFunction", "RefTrackerThink", 2.0 )
}

function DumpTrackRefs()
{
	foreach ( refName, refObj in __trackedRefs )
	{
		if ( !refObj )
			continue

		printl( "TRACKREF: " + refName + " " + refObj )

	}
}


function SetupDropPodEntitySpawning()
{
	// used for figuring out where it is safe to spawn entities that come out of drop pods.
	TRACE_DIST_OFFSET <- 64
	TRACE_HEIGHT_OFFSET <- 32
	TRACE_LENGTH <- (Vector( 0, 0, 0 ) - Vector( TRACE_DIST_OFFSET, TRACE_DIST_OFFSET, 0 )).Length()
	TRACE_MIN_LENGTH <- (Vector( 0, 0, 0 ) - Vector( 48, 48, 0 )).Length()
	level.traceMins <- {}
	level.traceMaxs <- {}
	level.hearingSensitivity <- {}
	level.lookDist <- {}

	FindMinsMaxs( "npc_soldier" )
	FindMinsMaxs( "npc_titan" )
	FindMinsMaxs( "npc_marvin" )

	CreatePilotTraceBounds()
}


function FindMinsMaxs( classname )
{
	if ( classname in level.traceMins )
		return

	// Called at start by entities that are going to be spawned relative to a drop pod
	local ent = CreateEntity( classname )
	ent.SetTeam( 3 )
	ent.SetName( "MinsMaxs_" + classname )
	ent.kv.spawnflags = 8 // SF_NPC_ALLOW_SPAWN_SOLID
	DispatchSpawn( ent, false )
	level.traceMins[ classname ] <- ent.GetBoundingMins()
	level.traceMaxs[ classname ] <- ent.GetBoundingMaxs()
	level.hearingSensitivity[ classname ] <- ent.GetHearingSensitivity()
	level.lookDist[ classname ] <- ent.GetLookDist()
	ent.Destroy()
}


function SP_Precache()
{
	PrecacheModel( "models/dev/editor_ref.mdl" )

	// -- SP Droppod precaches --
	PrecacheEntity( "prop_droppod", null /*"entities/droppod/prop_droppod.nut"*/, "models/vehicle/droppod_battery/droppod_battery_export.mdl" )
	PrecacheEffect( "droppod_trail" )
	PrecacheEffect( "ar_droppod_impact" )
	PrecacheEffect( "droppod_impact" )
	// --------------------------

	const CRITICAL_DAMAGE_SOUND0 = "hl1/fvox/health_critical.wav"
	const CRITICAL_DAMAGE_SOUND1 = "hl1/fvox/health_dropping.wav"
	const CRITICAL_DAMAGE_SOUND2 = "hl1/fvox/health_dropping2.wav"
	const CRITICAL_DAMAGE_SOUND3 = "hl1/fvox/seek_medic.wav"
	const CRITICAL_DAMAGE_SOUND4 = "hl1/fvox/near_death.wav"
	const CRITICAL_DAMAGE_SOUND5 = "hl1/fvox/blood_loss.wav"

	const FASTMEDKIT_START_SOUND = "hl1/fvox/automedic_on.wav"
}


function MP_Precache()
{
	VPKNotifyFile( "cfg/startup_dedi.cfg" )
	VPKNotifyFile( "cfg/startup_dedi_retail.cfg" )

	// -- player fast medkit precaches
	const FASTMEDKIT_START_SOUND = "hl1/fvox/automedic_on.wav"
	//const FASTMEDKIT_START_SOUND = "ui/loadout_click.wav"
	// --------------------------
}


function InitialGlobalSetup()
{

	AddPostEntityLoadCallback( SetupDropPodEntitySpawning )

	SetupFilterEnemy()


	level.podDissolver <- CreateEntity( "env_entity_dissolver" )
	level.podDissolver.kv.magnitude = 0
	level.podDissolver.kv.dissolvetype = 3
	DispatchSpawn( level.podDissolver, false )

	if ( GetDeveloperLevel() > 0 )
		thread AINFileIsUpToDateCheck()
}

if ( IsMultiplayer() /*&& !IsMenuLevel()*/ )
{
	__AINFileIsUpToDate <- AINFileIsUpToDate
	function AINFileIsUpToDate()
	{
		if ( GetMapName().find( "mp_" ) == 0 && GetAINScriptVersion() != AIN_REV )
			return false

		return __AINFileIsUpToDate()
	}
}

// paths out of date
function AINFileIsUpToDateCheck()
{

	if ( IsMultiplayer() )
	{
		level.ent.WaitSignal( "PlayerDidSpawn" )

		if ( AINFileIsUpToDate() )
			return

		//JFS: Avoid showing warning for Nexus in dev. See bug 77862 for background.
		if ( GetMapName() == "mp_nexus" )
			return

		for ( ;; )
		{
			wait 0.5
			local players = GetPlayerArray()
			foreach ( player in players )
			{
				if ( IsValid_ThisFrame( player ) )
					Hud.Hide( player, "pathsOutOfDate" )
			}

			wait 0.3
			local players = GetPlayerArray()
			foreach ( player in players )
			{
				if ( IsValid_ThisFrame( player ) )
					Hud.Show( player, "pathsOutOfDate" )
			}
		}
	}
	else
	{
		level.ent.WaitSignal( "PlayerDidSpawn" )

		if ( AINFileIsUpToDate() )
			return

		thread PlayerSeesGraphWarning( player )
	}
}

function PlayerSeesGraphWarning( player )
{
	player.EndSignal( "Disconnected" )
	local i
	local minWait = 0.03
	local maxWait = 0.7
	local result
	local max = 15
	for ( i = 0; i < max; i++ )
	{
		result = Graph( i, 0, max, maxWait, minWait )

		wait result
		if ( !IsValid_ThisFrame( player ) )
			return

		Hud.Hide( player, "pathsOutOfDate" )

		wait result * 0.5
		if ( !IsValid_ThisFrame( player ) )
			return

		Hud.Show( player, "pathsOutOfDate" )
	}

	for ( ;; )
	{
		wait 0.5
		if ( !IsValid_ThisFrame( player ) )
			return

		Hud.Hide( player, "pathsOutOfDate" )

		wait 0.3
		if ( !IsValid_ThisFrame( player ) )
			return

		Hud.Show( player, "pathsOutOfDate" )
	}

}

function SetupFilterEnemy()
{
	level.filter_enemy <- CreateEntity( "filter_enemy" )
	level.filter_enemy.SetName( "filter_all" )
	level.filter_enemy.kv.Negated = 1
	level.filter_enemy.kv.filtername = "*"
	DispatchSpawn( level.filter_enemy, false )
}

function ServerAnimEvent( ent, name )
{
	if ( !( name in ent.s.serverAnimEvents ) )
		return

	if ( "serverAnimEvents_optionalVars" in ent.s )
	{
		if ( name in ent.s.serverAnimEvents_optionalVars )
		{
			local optionalVar = ent.s.serverAnimEvents_optionalVars[ name ]
			thread ent.s.serverAnimEvents[ name ]( ent, optionalVar )
			return
		}
	}

	thread ent.s.serverAnimEvents[ name ]( ent )
}


// called by code when an animation does { event AE_SV_VSCRIPT_CALLBACK FrameNumber "some string" }
// and by a script function OnFootstep, apparently.
function CodeCallback_OnServerAnimEvent( ent, name )
{
	PerfStart( PerfIndexServer.CB_OnServerAnimEvent )

	if ( "serverAnimEvents" in ent.s )
	{
		ServerAnimEvent( ent, name )
	}

	if ( name in level.globalServerAnimEvents )
	{
		thread level.globalServerAnimEvents[ name ]( ent )
		PerfEnd( PerfIndexServer.CB_OnServerAnimEvent )
		return
	}


	// couldn't find this name on the guy or the global anim events,
	// so try breaking it down. If we didn't find it, it means
	// script needs to handle the event, even if it is just to
	// do nothing with it

	local tokens = split( name, ":" )
	local name = tokens[0]

	if ( name in level.globalServerAnimEvents )
	{
		Assert( tokens.len() == 2, "Format is event:parameter" )
		level.globalServerAnimEvents[ name ]( ent, tokens[1] )
	}
	PerfEnd( PerfIndexServer.CB_OnServerAnimEvent )
}


// Look up and set damageSourceIds for environmental damage triggers
// This works this way so maps don't have to be recompiled if any damageSourceIds change
function InitDamageTriggers( self )
{
	if ( !self.HasKey( "damageSourceName" ) )
		return

	switch ( self.GetValueForKey( "damageSourceName" ) )
	{
		case "fall":
			self.kv.damageSourceId = eDamageSourceId.fall
			break

		case "splat":
			self.kv.damageSourceId = eDamageSourceId.splat
			break

		case "burn":
			self.kv.damageSourceId = eDamageSourceId.burn
			break

		case "submerged":
			self.kv.damageSourceId = eDamageSourceId.submerged
			break

		default:
			Assert( "Unsupported damage source name on trigger_hurt: " + self.GetValueForKey( "damageSourceName" ) )
	}
}

function ScriptLeakDetector()
{
	level.ent.Signal( "GameEnd" )
	OnThreadEnd(
		function() : ()
		{
			TotalEnts()
		}
	)

	wait 0
	TotalEnts()

	for ( ;; )
	{
		wait 60
		TotalEnts()
	}
}

main()


