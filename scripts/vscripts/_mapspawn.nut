//=========================================================
//	_mapspawn.nut
//  Called on newgame or transitions, BEFORE entities have been created and initialized
//=========================================================
	printl( "Code Script: _mapspawn" )
	IncludeScript( "_settings" )
	IncludeScript( "_utility_shared" )
	IncludeScript( "_utility_shared_all" )
	IncludeScript( "_utility" )
	IncludeScript( "_remote_functions" )
	LoadDiamond()

    if ( false )
    {
    	// IMPORTANT: Cut down minimal scripts required for optimized lobby. This codepath is only run if "optimized_lobby_enabled" convar is non-zero.
		_PostEntityLoadCallbacks <- []
		_ClientCommandCallbacks <- {}
		Assert( !( "flags" in level ), "level.flags is being initialized somewhere else" )
		level.flags <- {}
		level._nameList <- {} // array of names, to check if name is unique
		level.SpawnActions <- {} // these run after all initial spawn functions have run
		level.triggersWithFlags <- {}
		level.ent <- CreateEntity( "logic_script" )
		level.ent.SetName( "Level Ent" )
		level.isTestmap <- false
		SetIsTrainingLevel()
		DispatchSpawn( level.ent, true )
    	IncludeFile( "_flag" )
		IncludeFile( "_flags_shared" ) // flags shared by sp and mp
		IncludeFile( "addon/_addonapi.nut" )
		FlagInit( "EntitiesDidLoad" )
		FlagInit( "PlayerDidSpawn" )
		IncludeFile( "mp/_anim" )
		IncludeFile( "mp/_viewcone" )
		IncludeFile( "_devstats" )
		RegisterSignal( "OnChangedPlayerClass" )
		IncludeScript( "mp/_utility_mp" )
		IncludeFile( "mp/_serverflags" )
		IncludeScript( "_codecallbacks" )
		IncludeScript( "_ui_vars" )
	 	IncludeFile( "_ranked_shared" )
  		IncludeFile( "_passives_shared" )
		IncludeFile( "mp/_burncards_utility" )
		IncludeFile( "mp/_burncards" )
		IncludeFile( "_burncards_shared" )
		IncludeFile( "_challenges_shared" )
		IncludeFile( "_items" )
		InitItems()

		IncludeFile( "_stats_shared" )
		InitStatsTables()
		IncludeFile( "_challenges_content" )
		IncludeFile( "mp/_challenges" )
		CreateChallenges()
		IncludeFile( "mp/_stats" )

		IncludeFile( "_playlist" )
		IncludeFile( "_ranked_shared" )
		IncludeFile( "_persistentdata" )
		IncludeFile( "_xp" )
		IncludeFile( "mp/_gamerules")
		IncludeFile( "menu/_lobby" )
		IncludeFile( "_black_market_shared" )
		IncludeFile( "mp/_black_market_loot" )
		IncludeFile( "mp/_black_market" )

		IncludeFile( "_menu_callbacks" )

		level.LevelStarting <- true
		level.ent.Fire( "CallScriptFunction", "LevelFinishedStarting", 0.1 )
	}

	function CodeCallback_ClientCommand( player, args )
	{
		RegisterSignal( "RefreshDice" )
		PerfStart( PerfIndexServer.CB_ClientCommand )
		/*
		printl( "############################" )
		printl( "CodeCallback_ClientCommand()" )
		printl( "player = " + player )
		printl( "args:" )
		foreach( key, value in args )
			printl( key + " : " + value )
		printl( "############################" )
		*/
		local commandString = args.remove( 0 )
		local result = false

		if ( commandString in player.clientCommandCallbacks )
		{
			// Insert the player's scope so that it becomes the "this" object in the function;
			// if the function used .bindenv(), the "this" object will override it
			args.insert( 0, player.scope() )

			local infos = player.clientCommandCallbacks[commandString].getinfos()
			if( infos.parameters.len() != args.len() )
			{
				CodeWarning( "Wrong number of arguments for ClientCommand " + commandString )
				PerfEnd( PerfIndexServer.CB_ClientCommand )
				return false
			}

			result = player.clientCommandCallbacks[commandString].acall( args )
		}
		else if ( commandString in _ClientCommandCallbacks )
		{
			args.insert( 0, null )
			args.insert( 1, player )

			local infos = _ClientCommandCallbacks[commandString].getinfos()
			if( infos.parameters.len() != args.len() )
			{
				local variableArguments = false
				foreach ( param in infos.parameters )
				{
					if ( param != "..." )
						continue

 					variableArguments = true
					break
				}

				if ( !variableArguments )
				{
					CodeWarning( "Wrong number of arguments for ClientCommand " + commandString )
					PerfEnd( PerfIndexServer.CB_ClientCommand )
					return false
				}
			}

			result = _ClientCommandCallbacks[commandString].acall( args )
		}

		PerfEnd( PerfIndexServer.CB_ClientCommand )
		return result
	}

	if ( developer() > 0 && ScriptExists( "test/myscript" ) )
		IncludeScript( "test/myscript", getroottable() )

	IncludeScript( "_damage_types" )
	IncludeFile( "_damage_utility" )
	IncludeFile( "_teams" )
	IncludeScript( "weapons/_weapon_utility" )
	IncludeScript( "_codecallbacks" )
	IncludeScript( "_ui_vars" )
	IncludeFile( "_player_leeching_shared" )
	IncludeFile( "weapons/_smart_ammo" )
	IncludeFile( "weapons/_arc_cannon" )
	IncludeFile( "weapons/_grenade" )
	IncludeFile( "weapons/_magnetic_ammo" )
	IncludeFile( "weapons/_vortex" )

	if ( developer() > 0 )
		PrecacheWeapon( "weapon_cubemap" )

	// "level" table; use to store global variables on a per level basis

	level._nameList <- {} // array of names, to check if name is unique
	// add a convience entity for firing events
	level.ent <- CreateEntity( "logic_script" )
	level.ent.SetName( "Level Ent" )
	DispatchSpawn( level.ent, true )

	level.triggersWithFlags <- {}

	level.precached <- {} // to avoid re-precaching
	//level.precached.models <- {}
	level.precached.entities <- {}
	level.precached.colorCorrections <- {}
	level.precached.sprites <- {}
	//level.precached.modelPhysics <- {}
	level.precached.scripts <- {}
	level.precached.effects <- {}
	level.precached.weapons <- {}

	level.privateMatchForcedEnd <- null
	level.defenseTeam <- TEAM_IMC

	PrecacheTitanImpactEffectTables( "titan_landing", "titan_footstep", "titan_dodge" )
	PrecachePilotImpactEffectTables( "pilot_landing" )

	level.isTestmap <- false
	SetIsTrainingLevel()

	TITAN_CORE_ENABLED <- true

	Assert( !( "flags" in level ), "level.flags is being initialized somewhere else" )
	level.flags <- {}

	_PostEntityLoadCallbacks <- []
	_ClientCommandCallbacks <- {}
	level.SpawnActions <- {} // these run after all initial spawn functions have run
	level.SpawnActionsLiving <- {} // this adds an IsAlive check to spawn actions
	level.SpawnAsClassActions <- [] // For MP, these are run after a player spawns as a specific class
	level.pointTemplateSpawnFunctions <- {} // stores spawn functions for things that spawn from point templates
	level.onRodeoStartedCallbacks <- {} // runs when a player starts rodeoing a titan
	level.onRodeoEndedCallbacks <- {} // runs when a player stops rodeoing a titan

	level.hardpointModeInitialized <- false

	// global flag functions
	IncludeFile( "_flag" )
	IncludeFile( "_flags_shared" ) // flags shared by sp and mp
	IncludeFile( "_timer" )
	IncludeFile( "mp/_anim" )
	IncludeFile( "_anim_aliases" )
	IncludeFile( "_death_package" )
	IncludeFile( "_titan_soul" )
	IncludeFile( "_titan_shared" )
	IncludeFile( "mp/_titan_transfer" )
	IncludeFile( "mp/_titan_npc" )
	IncludeFile( "mp/_titan_npc_behavior" )
	IncludeFile( "_player_view_shared" )
	IncludeFile( "_devstats" )
	IncludeFile( "cinematic_mp/_refuel_ships" )
	IncludeFile( "mp/_tonecontroller" )

	IncludeFile( "mp/_cinematic_anims" )

	FlagInit( "operatorEnabled" )
	FlagInit( "EntitiesDidLoad" )
	FlagInit( "FireteamDropPodExperience" )
	FlagInit( "FireteamAutoSpawn" )
	FlagInit( "PlayerDidSpawn" )
	FlagInit( "DebugFoundEnemy" )
	FlagInit( "OldAnimRefStyle" )
	FlagInit( "EarlyCatch" )
	FlagInit( "ForceStartSpawn" )
	FlagInit( "IgnoreStartSpawn" )
	FlagInit( "ShowExplosionRadius" )  // temp HACK

	FlagSet( "FireteamDropPodExperience" )

	level.LevelStarting <- true
	level.ent.Fire( "CallScriptFunction", "LevelFinishedStarting", 0.1 )

	level.operatorAbilityClasses <- {}
	RegisterSignal( "OnChangedPlayerClass" )
	RegisterSignal( "OnLeftTitan" )
	RegisterSignal( "Disconnected" )
	RegisterSignal( "TeamChange" )
	RegisterSignal( "LeftClass" )
	RegisterSignal( "forever" )
	RegisterSignal( "waitOver" )
	RegisterSignal( "HitSky" )

	PrecacheModel( DEFAULT_VIEW_MODEL )

	if ( IsMenuLevel() )
	{
		IncludeScript( "mp/_utility_mp" )
		IncludeFile( "mp/_serverflags" )
		IncludeFile( "_passives_shared" )
		IncludeFile( "mp/_burncards_utility" )
		IncludeFile( "mp/_burncards" )
		IncludeFile( "_burncards_shared" )
	}
	else
	{
		IncludeScript( "mp/_utility_mp" )
		IncludeFile( "mp/_serverflags" )
		IncludeFile( "_passives_shared" )
		IncludeFile( "mp/_burncards" )
		IncludeFile( "_burncards_shared" )
		IncludeFile( "mp/_cinematic" ) // difference between these two files is??
		IncludeFile( "cinematic_mp/_cinematic_mp" ) // difference between these two files is??
		IncludeFile( "cinematic_mp/_cinematic_mp_server" )
		IncludeFile( "cinematic_mp/_cinematic_mp_editor" )

		IncludeFile( "_stim_shared" )

		if ( ScriptExists( "cinematic_mp/level_data/" + GetMapName() ) )
		{
			IncludeFile( "cinematic_mp/level_data/" + GetMapName() )
			VerifyCinematicMPNodes()
		}

		IncludeFile( "cinematic_mp/_ai_skits_anims" )
		IncludeFile( "cinematic_mp/_ai_skits" )

		IncludeFile( "mp/_utility_dropzone" )
		IncludeFile( "entities/_droppod" )
		IncludeFile( "entities/_droppod_fireteam" )
		IncludeFile( "entities/_droppod_titan" )
		IncludeFile( "entities/_droppod_wallrun" )
		IncludeFile( "_objective" )
		IncludeScript( "_template_registry" )

		if ( IsMultiplayer() )
		{
			IncludeScript( "mp/_mapspawn_mp" )
		}
		if ( developer() > 0 )
		{
			modelViewerModels <- []
			if ( ScriptExists( "mp/_model_viewer" ) )
				IncludeFile( "mp/_model_viewer" )
		}
	}

	IncludeFile( "_dialogue_shared" )
	IncludeFile( "_challenges_shared" )
	IncludeFile( "_items" )
	InitItems()
	IncludeFile( "_stats_shared" )
	InitStatsTables()
	IncludeFile( "_challenges_content" )

	CreateChallenges()
	// InitChallenges()
	IncludeFile( "mp/_stats" )
	IncludeFile( "_menu_callbacks" )

	IncludeScript( "mp/_global_entities" )

	local mapname = GetMapName()

	if ( ScriptExists( mapname ) )
	{
		IncludeScript( mapname )
	}
	else
	if ( ScriptExists( "test/" + mapname ) )
	{
		level.isTestmap = true
		IncludeScript( "test/" + mapname )
	}
	else
	if ( ScriptExists( "sp/" + mapname + "/" + mapname ) )
	{
		IncludeScript( "sp/" + mapname + "/" + mapname )
	}
	else
	if ( ScriptExists( "mp/" + mapname ) )
	{
		IncludeScript( "mp/" + mapname )
	}

	IncludeScript( "_cinematic_shared" )
	IncludeFile( "_minimap_shared" )	// need to be after _remote_functions is included
	IncludeFile( "_playlist" )
	IncludeFile( "_ranked_shared" )

	if ( IsMenuLevel() )
	{
		if ( IsLobby() )
		{
			IncludeFile( "_persistentdata" )
			IncludeFile( "_xp" )
			IncludeFile( "mp/_gamerules")
			IncludeFile( "menu/_lobby" )
			IncludeFile( "_black_market_shared" )
			IncludeFile( "mp/_black_market_loot" )
			IncludeFile( "mp/_black_market" )
		}
	}
	else
	{
		if ( IsMultiplayer() )
		{
			IncludeFile( "mp/_evac" ) //Has depedency on _goblin_dropship, which is included in _global_entities, which is included after mapspawn_mp
		}
	}

	// NOTE this should run after level scripts get a chance to override default behavior
	if ( IsMultiplayer() && GetClassicMPMode() && !IsLobby() )
		ClassicMP_TryDefaultIntroSetup()

	function LobbyRestartThink()
	{
		// Wait for 6 hours (6 * 60 * 60 seconds)
		wait 21600
		printl( "6 hour uptime reached, returning to lobby." )
		ServerCommand( "map mp_lobby" )
	}

	// Training
	if ( mapname == "mp_npe" ) {
                ServerCommand("sv_pausable 1")
	} else {
                ServerCommand("sv_pausable 0")
	}

	// Lobby specific convar settings and restart timer
	if ( IsLobby() )
	{
		ServerCommand( "sv_kickPlayersTooFarInFuture 0" )
	}
	else
	{
		ServerCommand( "sv_kickPlayersTooFarInFuture 1" )
		thread LobbyRestartThink()
	}

	level.ui.isDedicatedServer = IsDedicated()

	function TryWaitForListenHostToFinishConnecting()
	{
		for(;;)
		{
			local players = GetPlayerArray()

			if( players.len() > 0 )
			{
				local playerName = players[0].GetPlayerName()
				local myName = GetConVarString( "name" )

				local cleanedName = StringReplaceAll( myName, "#", "" )

				if( cleanedName.len() > 32 )
					cleanedName = cleanedName.slice( 0, 32 )

				if ( playerName == cleanedName )
				{
					level.ui.listenHostUsernameHash = FNV1A( cleanedName )
					printl( "Listen host is: " + cleanedName )
					return
				}
			}

			wait 0.1
		}
	}

	if( !IsDedicated() )
	    thread TryWaitForListenHostToFinishConnecting()