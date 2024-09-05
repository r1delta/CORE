
//********************************************************************************************
//	_cl_mapspawn.nut
//  Called on newgame or transitions, BEFORE entities have been created and initialized
//********************************************************************************************
printl( "Code Script: _cl_mapspawn" )
IncludeScript( "_settings" )
IncludeScript( "_pdef_client" )
function ServiceEventQueue() {}

function Cl_MapspawnMain()
{
	IncludeScript( "_settings" )
	IncludeScript( "_utility_shared" )
	IncludeScript( "_utility_shared_all" )
	IncludeScript( "_utility_client" )

	if ( developer() > 0 && !IsLobby() )
	{
		modelViewerModels <- []
		level.isModelViewerActive <- false
		if ( ScriptExists( "client/_cl_model_viewer" ) )
			IncludeFile( "client/_cl_model_viewer" )
	}

	level.ent <- null
	level.scoreLimit <- {}
	level.scoreLimit[TEAM_IMC] <- IsMultiplayer() ? GetScoreLimit_FromPlaylist() : 0
	level.scoreLimit[TEAM_MILITIA] <- IsMultiplayer() ? GetScoreLimit_FromPlaylist() : 0

	level.clientVars <- {}

	Assert( !( "flags" in level ), "level.flags is being initialized somewhere else" )
	level.flags <- {}
	IncludeFile( "_flag" )
	IncludeFile( "_flags_shared" ) // flags shared by sp and mp

	IncludeFile( "_timer" )

	SetIsTrainingLevel()
	TITAN_CORE_ENABLED <- true

	if ( !IsLobby() )
	{
		IncludeFile( "_teams" )
    }

	IncludeScript( "_remote_functions" )

    if ( !IsLobby() )
    {
		IncludeScript( "_damage_types" )
		IncludeFile( "_damage_utility" )
    }

	IncludeScript( "weapons/_weapon_utility" )
	IncludeFile( "_persistentdata" )
	IncludeFile( "_xp" )

	IncludeFile( "_passives_shared" )
	IncludeFile( "_burncards_shared" )
	IncludeFile( "_black_market_shared" )

    if ( !IsLobby() )
    {
		IncludeFile( "client/cl_voice_hud" )
		IncludeFile( "client/cl_melee" )
		IncludeFile( "client/cl_titan_soul" )
    }

	IncludeScript( "client/_cl_utility_menu" )

    if ( !IsLobby() )
    {
		IncludeScript( "client/_cl_utility_splash" )
		IncludeScript( "client/_cl_anim" )
		IncludeFile( "_anim_aliases" )
    }

	IncludeScript("_codecallbacks_shared")
	IncludeScript("client/_clientcodecallbacks")

    if ( !IsLobby() )
    {
		IncludeFile( "_minimap_shared" )
		IncludeFile( "client/cl_rodeo" )
		IncludeFile( "client/cl_zipline" )
		IncludeFile( "_riff_settings" )
    }

	level.clientScriptInitialized <- false
	level.gameState <- 0
	level.g_hudElems <- {}
	level.baseColorElem <- null

	level.createCallbacks <- {}
	level.killReplayStartCallbacks <- []
	level.killReplayEndCallbacks <- []
	level.destroyCallbacks <- {}
	level.onDeathCallbacks <- {}
	level.onDeathOrDestroyCallbacks <- {}
	level.bgChangeCallbacks <- {}
	level.bgChangeModelCallbacks <- {}
	level.cinematicEventFlagChangedCallback <- {}
	level.onClientScriptInitCallback <- []
	level.onInitPlayerScripts <- []
	level.mainHudCallbacks <- []
	level.pilotHudCallbacks <- []
	level.titanHudCallbacks <- []
	level.onModelChangedCallbacks <- []

	buttonPressedCallbacks <- {}
	buttonReleaseCallbacks <- {}
	stickCallbacks <- {}

	IncludeFile( "_network_marker_shared" )

	IncludeFile( "client/_cockpit_screen" )
	IncludeFile( "_player_leeching_shared" )
	IncludeFile( "client/cl_titan_cockpit" )
	IncludeFile( "client/cl_titan_dialogue" )
	IncludeFile( "client/cl_rank_chip_dialogue" )
	IncludeFile( "client/cl_data_knife" )
	IncludeScript( "client/cl_droppod_cockpit" )
	IncludeFile( "_score_shared" )
	IncludeFile( "_death_package" )
	IncludeFile( "weapons/_smart_ammo" )
	IncludeFile( "weapons/_smart_ammo_client" )
	IncludeFile( "weapons/_arc_cannon" )
	IncludeFile( "weapons/_grenade" )
	IncludeFile( "weapons/_magnetic_ammo" )
	IncludeFile( "weapons/_vortex" )
	IncludeFile( "_titan_soul" )
	IncludeFile( "_titan_shared" )
	IncludeFile( "client/cl_goblin_dropship" )

	IncludeFile( "client/cl_sniper_vgui" )

	IncludeScript( "client/_cl_material_proxies" )

	IncludeFile( "superbar/smokescreen" )


	// bunch of level variable that _flag uses for SP but that are needed on the client for the script not to break.
	level.triggersWithFlags <- {}
	level.flagHistory <- {}


	IncludeFile( "_flightpath_shared" )//moved this below level.flags <- {} so I can set flags in it - Mo

    if ( !IsLobby() )
    {
		IncludeFile( "client/cl_precache" )
    }

	IncludeFile( "client/cl_introscreen" )
	IncludeFile( "client/cl_classic_mp" )
	IncludeFile( "client/cl_player" )
	IncludeFile( "client/cl_flyout" )
	IncludeFile( "client/cl_titan_hud" )
	IncludeFile( "client/cl_objective" )
	IncludeFile( "client/cl_crosshair" )
	IncludeFile( "client/cl_damage_states" )
	IncludeFile( "client/cl_fullscreen_map" )
	IncludeFile( "client/cl_main_hud" )
	IncludeFile( "_devstats" )
	IncludeFile( "_player_view_shared" )
	IncludeFile( "client/cl_fx" )
	IncludeFile( "client/objects/_cl_objects_manifest" )

	level.addPlayerFuncs <- [] // funcs players run when they connect

	level.traceMins <- {}
	level.traceMaxs <- {}
	CreatePilotTraceBounds()

    if ( !IsLobby() )
    {
		CinematicIntroScreen_Init()
    }

	level.minimapObjects <- {}

	FlagInit( "ClientInitComplete" )
	FlagInit( "EntitiesDidLoad" )

	level.DAMAGE_DEBUG_PRINTS <- 0

	if ( IsMultiplayer() )
	{
		if ( !IsLobby() )
		{
			IncludeFile( "client/cl_burncard_selector" )
			IncludeFile( "_stim_shared" )
			IncludeFile( "client/cl_rumble" )
		}
		IncludeFile( "client/_cl_music" )

		IncludeGameModeClientScripts()

		switch ( GetCurrentPlaylistVar( "damage_crawl", 0 ) )
		{
			case "1":
				level.DAMAGE_DEBUG_PRINTS = 1
				break
			case "2":
				level.DAMAGE_DEBUG_PRINTS = 2
				break
			case "3":
				level.DAMAGE_DEBUG_PRINTS = 3
				break
			case "console":
				level.DAMAGE_DEBUG_PRINTS = getconsttable().DAMAGE_DEBUG_PRINTS_CONSOLE
				break
			case "screen":
				level.DAMAGE_DEBUG_PRINTS = getconsttable().DAMAGE_DEBUG_PRINTS_SCREEN
				break
			case "both":
				level.DAMAGE_DEBUG_PRINTS = getconsttable().DAMAGE_DEBUG_PRINTS_BOTH
				break
		}
	}

	if ( developer() > 0 && ScriptExists( "test/cl_myscript" ) )
		IncludeScript( "test/cl_myscript", getroottable() )

	level.isTestmap <- false
	if ( ScriptExists( "test/" + GetMapName() ) )
	{
		level.isTestmap = true
		// test maps get to load stuff
		if ( !IsLobby() )
		{
			IncludeFileAllowMultipleLoads( "client/objects/cl_hornet_fighter" )
			IncludeFileAllowMultipleLoads( "client/objects/cl_phantom_fighter" )
			IncludeFileAllowMultipleLoads( "client/objects/cl_redeye" )
			IncludeFileAllowMultipleLoads( "client/objects/cl_hologram_projector" )
			IncludeFileAllowMultipleLoads( "client/objects/cl_imc_carrier" )
			IncludeFileAllowMultipleLoads( "client/objects/cl_imc_carrier_207" )
			IncludeFileAllowMultipleLoads( "client/objects/cl_annapolis" )
			IncludeFileAllowMultipleLoads( "client/objects/cl_birmingham" )
			IncludeFileAllowMultipleLoads( "client/objects/cl_bomber" )
			IncludeFileAllowMultipleLoads( "client/objects/cl_ai_turret" )
		}
	}

	RegisterSignal( "forever" )
	RegisterSignal( "UpdateTitanCounts" )
	RegisterSignal( "UpdatePlayerStatusCounts" )
	RegisterSignal( "ControllerModeChanged" )


	if ( IsMultiplayer() )
	{
		IncludeFile( "_loader" )
		IncludeFile( "client/cl_burncards" )
		if ( IsLobby() )
		{
			IncludeFile( "client/cl_burncards_lobby" )
		}
		else
		{
		    IncludeFile( "client/cl_respawnselect" )
			IncludeFile( "_damage_history" )
		}

		IncludeFile( "_ranked_shared" )

		IncludeFile( "_challenges_shared")

		IncludeFile( "_items" )
		InitItems()

		if ( !IsLobby() )
		{
			IncludeFile( "_stats_shared" )
			InitStatsTables()
			IncludeFile( "_challenges_content")
			CreateChallenges()
		}

		IncludeFile( "client/cl_loader" )

		const SNIPERCAM_CENTERSCREEN_FADE_DURATION = 0.35

		IncludeFile( "client/cl_screenfade" )

		if ( !IsLobby() )
		{
			IncludeScript( "client/cl_scoresplash", getroottable() )
			IncludeFile( "client/cl_obituary" )
			IncludeScript( "client/cl_damage_print", getroottable() )
			IncludeFile( "_hardpoints_shared" )
			IncludeFile( "client/cl_hardpoints" )
			IncludeFile( "client/_cl_indicators_hud" )
			IncludeFile( "client/_cl_health_hud" )
			IncludeFile( "client/_cl_misc_hud" )
			IncludeFile( "client/cl_kill_replay_hud" )

			IncludeScript( "_cinematic_shared" )
			IncludeFile( "client/cl_cinematic" )
		}

		if ( IsLobby() )
		{
			IncludeFile( "_playlist" )
			IncludeFile( "menu/cl_lobby" )
		}
		else
		{
			IncludeFile( "client/cl_deathrecap" )
			IncludeFile( "client/cl_scoreboard" )
			IncludeFile( "client/cl_challenges" )

			IncludeFile( "cinematic_mp/_cinematic_mp" )
			IncludeFile( "cinematic_mp/_cinematic_mp_client" )
			IncludeFile( "cinematic_mp/_cinematic_mp_editor" )

			if ( ScriptExists( "cinematic_mp/level_data/" + GetMapName() ) )
				IncludeFile( "cinematic_mp/level_data/" + GetMapName() )

			IncludeFile( "cinematic_mp/_ai_skits_clientdebugging" )
			IncludeFile( "cinematic_mp/_ai_skits" )
		}

		if ( !IsLobby() )
		{
		    IncludeFile( "client/cl_vdu.nut" )
    		IncludeFile( "client/cl_replacement_titan_hud" )

    		IncludeFile( "_dialogue_shared" )
    		IncludeFile( "client/_cl_dialogue.nut" )

    		IncludeFile( "client/levels/_cl_levels_manifest" )
    		IncludeFile( "client/cl_evac" ) //Has dependency on _objective system, must come after it. Also needs to be after client level script file is loaded, so relative ordering between level script and evac is same on server and client

    		IncludeFile( "_sonar_shared" )

    		if ( !IsLobby() && GetCurrentPlaylistVarInt( "riff_floorislava", eFloorIsLava.Default ) )
    			IncludeFile( "client/cl_riff_floor_is_lava" )
		}

		RegisterSignal( "PulseROE" )
		RegisterSignal( "OnDeath" )
	}
	else
	{
		IncludeFile( "client/levels/_cl_levels_manifest" )

		RegisterSignal( "OnDeath" )
		RegisterSignal( "OnSniperCamSpotted" )
		IncludeFile( "client/_cl_indicators_hud" )
		IncludeFile( "client/cl_redeye_turret_hud" )
	}

	if ( !IsLobby() )
	{
		IncludeFile( "client/cl_entity_creation_functions" )

		IncludeTitanEmbark()

		//Weapons_Init()

		PerfInitLabels()
	}
}

function CodeCallback_RunClientConnectScripts( player )
{
	Assert( IsValid( player ) )
	Assert( player == GetLocalClientPlayer() )
	thread RunClientConnectScriptsThreaded( player )
}

function RunClientConnectScriptsThreaded( player )
{
	Assert( IsValid( player ) )
	Assert( player == GetLocalClientPlayer() )

	if ( level.clientScriptInitialized )
		return

	player.cv = level.clientVars

	level.ent = CreateClientSidePointCamera( Vector( 0, 0, 0 ), Vector( 0, 0, 0 ), 50 )
	level.ent.Hide()
	Assert( level.ent )

	level.baseColorElem = HudElement( "HudBaseColor" )

	Init_ClientScripts( player )

	FlagWait( "ClientInitComplete" )

	Assert( IsValid( player ) )
	Assert( player == GetLocalClientPlayer() )

	level.clientScriptInitialized = true

	if ( "EntitiesDidLoad" in getroottable() )
	{
		thread EntitiesDidLoad()
	}

	RunFunctionInAllFileScopes( "EntitiesDidLoad" )
	FlagSet( "EntitiesDidLoad" )

	if ( Durango_IsDurango() )
	{
		// Update game progress based off gen and xp
		Assert( IsValid( player ) )
		Assert( player == GetLocalClientPlayer() );
		Assert( MAX_LEVEL > 0 );

		if ( player.GetGen() > 0 )
			Durango_SetGameProgress( 1.0 )
		else
		{
			// temp fix for level curve bug
			local result = player.GetLevel().tofloat() / MAX_LEVEL
			if ( result > 1.0 )
				result = 1.0
			Durango_SetGameProgress( result )
		}
	}
}

function Init_ClientScripts( player )
{
	if ( SafeareaSettingIsEnabled() )
		level.safeAreaScale <- 1.0
	else
		level.safeAreaScale <- 0.0

	level.screenSize <- Hud.GetScreenSize()

	local aspectRatio = level.screenSize[0].tofloat() / level.screenSize[1].tofloat()
	level.aspectRatioScale <- min( aspectRatio / (16.0/9.0), 1.0 )

	level.safeArea <- HudElement( "SafeArea" )
	level.safeAreaCenter <- HudElement( "SafeAreaCenter" )

	if ( level.safeAreaScale != 1.0 )
	{
		level.safeArea.SetWidth( level.screenSize[0] - (level.screenSize[0] * 0.025) )
		level.safeArea.SetHeight( level.screenSize[1] - (level.screenSize[1] * 0.025) )
		level.safeAreaCenter.SetWidth( level.screenSize[0] - (level.screenSize[0] * 0.025) )
		level.safeAreaCenter.SetHeight( level.screenSize[1] - (level.screenSize[1] * 0.025) )
	}

	if ( !IsLobby() )
    {
		Player_AddClient( player )
    }

	if ( !IsMultiplayer() )
		return

	if ( IsMultiplayer() )
	{
		ScreenFade_AddClient()

        if ( !IsLobby() )
        {
			InitVoiceHUD( player )
			Dialog_AddClient( player )
        }

		if ( !Durango_IsDurango() )
			InitChatHUD()

		if ( !IsLobby() )
		{
			MiscHUD_AddClient( player )
			ClassicMP_AddClient()
			KillReplayHud_AddClient()
			InitScoreboard()
			InitDeathRecap()
			InitChallengePopup()
			InitLoadoutReminder()
			RespawnSelect_AddClient()
			MainHud_AddClient( player )
			InitFullscreenMap()
			ReplacementTitanHUD_AddClient( player )
			InitCrosshair()

			// Added via AddCallback_OnClientScriptInit
			foreach ( callbackInfo in level.onClientScriptInitCallback )
			{
				callbackInfo.func.acall( [callbackInfo.scope, player] )
			}
		}
		else
		{
			BurnCards_AddLobbyClient()
		}
	}
}


function Init_PlayerScripts( player )
{
	Player_AddPlayer( player )

	HealthBarOverlayHUD_AddPlayer( player )
	Low_Ammo_Warning_AddPlayer( player )
	TitanHud_AddPlayer() // bad; overwrites level. variables
	TitanCockpit_AddPlayer( player )
	Flyout_AddPlayer( player ) // should not be called this... does nothing with the player entity
	InfoFlyout_AddPlayer() // should not be called this... does nothing with the player entity
	SmartAmmo_LockedOntoWarningHUD_Init()
	SniperVGUI_AddPlayer( player )
	OutOfBoundsOverlayHUD_AddPlayer( player )

	if ( IsMultiplayer() )
	{
		if ( !IsMenuLevel() )
		{
			SetupVDU( player )
			MiscHUD_AddPlayer( player )
			HealthHUD_AddPlayer( player )
			RodeoHUD_AddPlayer( player )
			ReplacementTitanHUD_AddPlayer( player )

			//MainHud_AddPlayer( player )
			ChallengePopup_AddPlayer( player )
			thread ReportDevStat_FrameRate( player )

			switch ( GameRules.GetGameMode() )
			{
				case "ctf":
				case "ctfp":
				CTF_AddPlayer( player )
					break
				case "ctt":
				CTT_AddPlayer( player )
					break
				case "exfil":
				Exfil_AddPlayer( player )
					break
			}

			// Added via AddCallback_OnInitPlayerScripts
			foreach ( callbackInfo in level.onInitPlayerScripts )
			{
				callbackInfo.func.acall( [callbackInfo.scope, player] )
			}
		}

		if ( IsLobby() )
			thread Lobby_AddPlayer( player )

		player.s.hasValidClass <- false

		foreach ( addPlayerFunc in level.addPlayerFuncs )
		{
			addPlayerFunc( player )
		}

		SmartGlass_SetGlobalProperty( SMARTGLASS_PROP_GAMEMODE, GameRules.GetGameMode() )
	}

	Crosshair_AddPlayer( player )

	if ( !("playerScriptsInitialized" in player.s) )
		player.s.playerScriptsInitialized <- true
}


function CodeCallback_ServerVarChanged( varName )
{
	if ( !(varName in _serverVarChangeCallbacks) )
		return

	foreach ( callbackFunc in _serverVarChangeCallbacks[varName] )
		thread callbackFunc()
}


function CodeCallback_EntityVarChanged( entity, varName, newValue, oldValue )
{
	local className = entity.GetSignifierName()

	if ( !(className in _entityClassVarChangeCallbacks) )
		return

	if ( !(varName in _entityClassVarChangeCallbacks[className]) )
		return

	foreach ( callbackFunc in _entityClassVarChangeCallbacks[className][varName] )
	{
		local infos = callbackFunc.getinfos()
		if ( infos.parameters.len() == 2 )
			callbackFunc( entity )
		else
			callbackFunc( entity, newValue, oldValue )
	}
}

// called from _base_gametype::ClientCommand_ClientScriptInitialized()
function ServerCallback_ClientInitComplete()
{
	FlagSet( "ClientInitComplete" )
}


function StripPrefix( stringName, prefix )
{
	local index = stringName.find( prefix )

	if ( index != 0 )
		return stringName

	return stringName.slice( prefix.len(), stringName.len() )
}


function GetTableNumContents( table, contents )
{
	foreach ( k, v in table )
	{
		contents.num++

		if ( typeof v == "table" )
		{
			GetTableNumContents( v, contents )
		}
	}
}


function PerfInitLabels()
{
	PerfClearAll()

	local table = getconsttable().PerfIndexClient
    foreach( string, int in table )
         PerfInitLabel( int, string.tostring() )

	local sharedTable = getconsttable().PerfIndexShared
    foreach( string, int in sharedTable )
         PerfInitLabel( int + SharedPerfIndexStart, string.tostring() )
}

function IncludeGameModeClientScripts()
{
	switch ( GameRules.GetGameMode() )
	{
		case "uplink":
			IncludeFile( "client/cl_uplink" )
			break

		case "exfil":
			IncludeFile( "client/cl_exfiltration" )
			break

		case BIG_BROTHER:
			IncludeFile( "client/cl_big_brother" )
			break

		case "heist":
			IncludeFile( "client/cl_gamemode_heist" )
			break

		case "tt":
			break

		case "ctf":
			IncludeScript( "_capture_the_flag_shared" )
			IncludeFile( "client/cl_capture_the_flag" )
			break

		case "tdm":
		case "at":
			break

		default:
			GameMode_RunSharedScripts( GAMETYPE )
			GameMode_RunClientScripts( GAMETYPE )
	}
}

// call this last
Cl_MapspawnMain()
