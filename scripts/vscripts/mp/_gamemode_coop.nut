// TEMP TEMP TEMP for testing
const MINIMAP_SENTRY_TURRET_SCALE 		= 0.075

function main()
{
	Assert( GetClassicMPMode(), "You need to be in playlist coop to run coop" )

	// things that need to get set up before the included files try to reference them
	level.nv.attackingTeam = TEAM_MILITIA
	local defenders = GetOtherTeam(level.nv.attackingTeam)

	level.maxAllowedRestarts <- null

	level.loadoutCrateManagedEntArrayID <- CreateScriptManagedEntArray()

	IncludeFile( "mp/_COOBJ_towerdefense" )
	IncludeFile( "mp/_mortar_titans" )
	IncludeFile( "mp/_sniper_spectres" )
	IncludeFile( "mp/_coop_titans" )
	IncludeFile( "_gamemode_coop_shared" ) // Scripts with AI wave position adding functions must be included before calling gamemode_coop_shared
	IncludeFile( "mp/_suicide_spectres" )
	IncludeFile( "mp/_cloak_drone" )
	IncludeFile( "mp/_nuke_titans" )
	IncludeFile( "mp/_emp_titans" )

	FlagSet( "PilotBot" )
	FlagSet( "DisableSkits" )
	FlagSet( "IgnoreStartSpawn" )
	FlagInit( "ObjectiveComplete", false )
	FlagInit( "ObjectiveFailed" )

	AddCallback_OnClientConnecting( COOP_PlayerConnecting )

	SetRoundBased( true )
	SetEndRoundPlayerState( ENDROUND_FREEZE )  // the state that players will be put into between rounds (aka when resetting)
	FlagSet( "GameModeAlwaysAllowsClassicIntro" )  // Each round starts with the dropship intro
	EnableWaveSpawnByDropship( true )

	Coop_SetNumAllowedRestarts( GetRoundScoreLimit_FromPlaylist() )  // init number of restarts allowed

	AddClientCommandCallback( "InitSentryTurretPlacement", ClientCallback_InitSentryTurretPlacement )
	AddClientCommandCallback( "PlaceSentryTurret", ClientCallback_PlaceSentryTurret )
	AddClientCommandCallback( "AbortSentryTurret", ClientCallback_AbortSentryTurret )

	AddCallback_OnRodeoStarted( SetCoopPlayerRodeoStarted )
	AddCallback_OnRodeoEnded( SetCoopPlayerRodeoEnded )

	level.max_npc_per_side = 12
	SetGameModeAICount( 0, level.nv.attackingTeam )
	SetGameModeAICount( level.max_npc_per_side, defenders )
	SetLevelAICount( 0, level.nv.attackingTeam )
	SetLevelAICount( level.max_npc_per_side, defenders )

	//level.spectreSpawnStyle = eSpectreSpawnStyle.MAP_PROGRESSION

	level.spawnRatingFunc_Pilot = Bind( RateSpawnpoint_Coop )
	level.spawnRatingFunc_Generic = Bind( RateSpawnpoint_Coop )

	level.AIUseCapturePointTerminals = false // just need to touch in this mode

	SetGameModeScoreEventOverrideFunc( Coop_SetScoreEventOverride )
}

function EntitiesDidLoad()
{
	// capped the max number of spectres that can be leeched at any given time.
	// this will not stop you from leeching it'll just kill another leeched spectre

	level.maxLeechable = 6
	level.globalLeechLimit = 12
//	level.propagateOnLeech = false
	level.wifiHackOverflowDies = true
}

function COOP_PlayerConnecting( player )
{
	// need to set the team earlier or adding bots breaks
	player.SetTeam( level.nv.attackingTeam )
}

function Coop_TryReturnToLobby()
{
	printt( "Coop: Returning to lobby" )
	GameRules_ChangeMap( "mp_lobby", COOPERATIVE )
}
Globalize( Coop_TryReturnToLobby )

function SetCoopPlayerRodeoStarted( player )
{
	SetCoopPlayerRodeo( player, true )
}

function SetCoopPlayerRodeoEnded( player )
{
	SetCoopPlayerRodeo( player, false )
}

function SetCoopPlayerRodeo( player, state )
{
	// mark a player as rodeoing so that client HUDs can display overhead icons correctly
	local entIndex = player.GetEntIndex()
	local data = level.nv.coopPlayersRodeoing
	local playerBit = 1 << ( entIndex - 1 )					// 1 = 0x01, 2 = 0x02, 3 = 0x04, 4 = 0x08

	if ( state == true )
		level.nv.coopPlayersRodeoing = playerBit | data		// set the player bit
	else
		level.nv.coopPlayersRodeoing = ~playerBit & data	// clear the player bit
}

Globalize( SetCoopPlayerRodeo )


function RateSpawnpoint_Coop( checkclass, spawnpoint, team, player = null )
{
	local spawnpointRating = SpawnPoint_CoopScore( spawnpoint, team )
	local ratingWithPetTitan = spawnpointRating

	local rating = spawnpoint.CalculateRating( checkclass, team, spawnpointRating, ratingWithPetTitan )
}

function SpawnPoint_CoopScore( spawnpoint, team )
{
	local score = 0

	if ( !( "TowerDefenseGenerator" in level ) || !IsValid( level.TowerDefenseGenerator ) )
		return 0

	local generatorOrigin = level.TowerDefenseGenerator.GetOrigin()
	local spawnpointOrigin = spawnpoint.GetOrigin()
	local dist = DistanceSqr( generatorOrigin, spawnpointOrigin )
	local minDist = 1048576 // 1024 squared
	local maxDist = 6553600 // 2560 squared

	score = GraphCapped( dist, minDist, maxDist, 4, 0 )
	score += GraphCapped( dist, maxDist, maxDist * 2, 0, -10 ) // negative for far away distances

	return score
}

function Coop_SetObjectiveComplete()
{
	FlagSet( "ObjectiveComplete" )
}
Globalize( Coop_SetObjectiveComplete )


function Coop_SetObjectiveFailed()
{
	FlagSet( "ObjectiveFailed" )
}
Globalize( Coop_SetObjectiveFailed )


function AddLoadoutCrate( team, origin, angles, showOnMinimap = true )
{
	local crateCount = GetScriptManagedEntArray( level.loadoutCrateManagedEntArrayID ).len()
	Assert( crateCount < 3, "Can't have more then 3 Loadout Crates" )

	angles += Vector( 0, -90, 0 )

	local crate = CreatePropDynamic( LOADOUT_CRATE_MODEL, origin, angles, 6 )
	crate.SetName( "loadoutCrate" )
	crate.SetTeam( team )
	crate.SetUsable()
	crate.SetUsableByGroup( "friendlies pilot" )
	crate.SetUsePrompts( "#LOADOUT_CRATE_HOLD_USE", "#LOADOUT_CRATE_PRESS_USE" )

	if ( showOnMinimap )
	{
		crate.Minimap_SetDefaultMaterial( "vgui/hud/coop/coop_ammo_locker_icon" )
		crate.Minimap_SetObjectScale( MINIMAP_LOADOUT_CRATE_SCALE )
		crate.Minimap_SetAlignUpright( true )
		crate.Minimap_AlwaysShow( TEAM_IMC, null )
		crate.Minimap_AlwaysShow( TEAM_MILITIA, null )
		crate.Minimap_SetFriendlyHeightArrow( true )
		crate.Minimap_SetZOrder( 5 )
	}

	AddToScriptManagedEntArray( level.loadoutCrateManagedEntArrayID, crate )

	thread LoadoutCrateMarkerThink( "LoadoutCrateMarker" + crateCount.tostring(), crate )
	thread LoadoutCrateThink( crate )
	thread LoadoutCrateRestockAmmoThink( crate )
}
Globalize( AddLoadoutCrate )

function LoadoutCrateMarkerThink( marker, crate )
{
	crate.EndSignal( "OnDestroy" )
	crate.EndSignal( "OnDeath" )

	OnThreadEnd(
		function() : ( marker )
		{
			ClearMarker( marker )
		}
	)

	while( 1 )
	{
		if ( GetGameState() <= eGameState.Prematch )
			ClearMarker( marker )
		else
			SetMarker( marker, crate )

		level.ent.WaitSignal( "GameStateChange" )
	}
}

function LoadoutCrateThink( crate )
{
	crate.EndSignal( "OnDestroy" )
	while( true )
	{
		local results = crate.WaitSignal( "OnPlayerUse" )
		local player = results.activator

		if ( player.IsPlayer() )
		{
			thread UsingLoadoutCrate( crate, player )
			wait 1	// debounce on using the crate to minimize the risk of using it twice before the menu opens.
		}
	}
}

function LoadoutCrateRestockAmmoThink( crate )
{
	crate.EndSignal( "OnDestroy" )
	local distSqr
	local crateOrigin = crate.GetOrigin()
	local triggerDistSqr = 96 * 96
	local resetDistSqr = 384 * 384

	while( true )
	{
		wait 1 // check every second
		local playerArray = GetLivingPlayers()
		foreach( player in playerArray )
		{
			if ( player.IsTitan() )
				continue

			distSqr = DistanceSqr( crateOrigin, player.GetOrigin() )
			if ( distSqr <= triggerDistSqr && player.s.restockAmmoTime < Time() )
			{
				player.s.restockAmmoCrate = crate
				player.s.restockAmmoTime = Time() + 10 // debounce time before you can get new ammo again if you stay next to the crate.
				MessageToPlayer( player, eEventNotifications.CoopAmmoRefilled, null, null )
				EmitSoundOnEntityOnlyToPlayer( player, player, "Coop_AmmoBox_AmmoRefill" )
				RestockPlayerAmmo( player )
			}
			if ( distSqr > resetDistSqr && player.s.restockAmmoTime > 0 && player.s.restockAmmoCrate == crate )
			{
				player.s.restockAmmoCrate = null
				player.s.restockAmmoTime = 0
			}
		}
	}
}

function UsingLoadoutCrate( crate, player )
{
	player.s.usedLoadoutCrate = true
	EmitSoundOnEntityOnlyToPlayer( player, player, "Coop_AmmoBox_Open" )
	Remote.CallFunction_UI( player, "ServerCallback_OpenPilotLoadoutMenu" )
}

// should be called if we enter an epilogue ... maybe?
function DestroyAllLoadoutCrates()
{
	local crateArray = GetScriptManagedEntArray( level.loadoutCrateManagedEntArrayID )
	foreach( crate in crateArray )
		crate.Destroy()

	//dissolve didn't work
	//Dissolve( ENTITY_DISSOLVE_CHAR, Vector( 0, 0, 0 ), 0 )
	//ENTITY_DISSOLVE_CORE
	//ENTITY_DISSOLVE_NORMAL
}
Globalize( DestroyAllLoadoutCrates )


function Coop_KillAllEnemies()
{
	Assert( GameRules.GetGameMode() == COOPERATIVE )

	// mostly copied from ResetNPCs()
	local guys = GetNPCArray()
	guys.extend( GetNPCCloakedDrones() )

	foreach ( guy in guys )
	{
		if ( guy.GetTeam() == level.nv.attackingTeam )
			continue

		if ( guy.GetClassname() == "npc_turret_mega" || guy.GetClassname() == "npc_turret_sentry" )
			continue

		// don't destroy the player team dropships that carry players into combat
		if ( guy.GetClassname() == "npc_dropship" && "classicMPDropships" in level )
		{
			local playerTeam = level.nv.attackingTeam
			local foundIt = false

			// don't clean up player spawn dropships, even if they are for a non coop team (classic_mp timing issue)
			local playerSpawnDropships = level.classicMPDropships[ TEAM_MILITIA ]
			playerSpawnDropships.extend( level.classicMPDropships[ TEAM_IMC ] )

			foreach ( dropship in playerSpawnDropships )
			{
				if ( IsValid( dropship ) && dropship == guy )
				{
					foundIt = true
					break
				}
			}

			if ( foundIt )
				continue
		}

		if ( guy.GetClassname() == "npc_titan" && IsValid( guy.GetTitanSoul() ) )
		{
			guy.GetTitanSoul().Destroy()
		}

		guy.Destroy()
	}

	printt( "Coop Enemies Killed" )
}
Globalize( Coop_KillAllEnemies )


function GetMinionSpawnPoint( spawnPointArray, team, origin )
{
	SpawnPoints_InitRatings( null )

	foreach ( spawnpoint in spawnPointArray )
	{
		// the returned rating doesn't have any purpose. the real rating is stored using spawnpoint.CalculateRating(...)
		local rating = RateMinionSpawnPoint( spawnpoint, team, origin )
		// DebugDrawText( spawnpoint.GetOrigin() + Vector( 0,0,200), rating.tostring(), false, 10 )
	}

	SpawnPoints_SortDropPod()
	spawnPointArray = SpawnPoints_GetDropPod()

	foreach ( spawnpoint in spawnPointArray )
	{
		if ( IsSpawnpointValidDrop( spawnpoint, team ) )
			return spawnpoint
	}

	// we will always return a spawnpoint even if it's a bad one.
	return spawnPointArray[0]
}
Globalize( GetMinionSpawnPoint )

function RateMinionSpawnPoint( spawnpoint, team, origin )
{
	local dist = Distance( spawnpoint.GetOrigin(), origin )
	local rating = GraphCapped( dist, 1000, 3000, 2, 0 )

	spawnpoint.CalculateRating( TD_AI, team, rating, rating ) // second rating is rating with petTitan. Not used with AI I guess
	return rating
}


function Coop_DamageGenerator( dmg )
{
	if ( !( "TowerDefenseGenerator" in level ) )
		return

	if ( !IsValid( level.TowerDefenseGenerator ) )
		return

	if ( Flag( "GeneratorGodMode" ) )
		Coop_SetGeneratorGodMode( false )

	// HACK -2 is eDamageSourceId.suicide, can't use eDamageSourceId when called from a dev menu command though (scope issue?)
	level.TowerDefenseGenerator.TakeDamage( dmg, null, null, { damageSourceId = -2 } )
}
Globalize( Coop_DamageGenerator )


function Coop_SetGeneratorGodMode( isOn )
{
	Assert( GameRules.GetGameMode() == COOPERATIVE )

	if ( isOn )
	{
		FlagSet( "GeneratorGodMode" )
		printt( "Generator god mode ON" )
	}
	else
	{
		FlagClear( "GeneratorGodMode" )
		printt( "Generator god mode OFF" )
	}
}
Globalize( Coop_SetGeneratorGodMode )


function GiveSentryTurretToPlayersOnTeam( team )
{
	local playerArray = GetPlayerArrayOfTeam( team )

	foreach( player in playerArray )
	{
		GiveSentryTurret( player )
	}
}
Globalize( GiveSentryTurretToPlayersOnTeam )


function GiveSentryTurret( player )
{
	if ( !IsValid( player ) )
		return

	if ( !( "sentryTurretCount" in player.s ) )
		player.s.sentryTurretCount <- 0

	player.s.sentryTurretCount = min( COOP_SENTRY_TURRET_MAX_COUNT_INV, player.s.sentryTurretCount + 1 )

	Remote.CallFunction_Replay( player, "ServerCallback_GiveSentryTurret" )
}

function ClientCallback_InitSentryTurretPlacement( player )
{
	// need this callback to get the player to lower his weapon. HolsterWeapon exist on the client but doesn't work

	if ( !IsValid( player ) )
		return

	if ( !( "sentryTurretCount" in player.s ) || player.s.sentryTurretCount <= 0 )
		return

	EmitSoundOnEntityOnlyToPlayer( player, player, "CoOp_SentryGun_PlacementHologramOn" )

	player.HolsterWeapon()

	return true
}

function ClientCallback_PlaceSentryTurret( player, posX, posY, posZ, angX, angY, angZ ) // might have to pass the origin and angles etc. as xyz...
{
	if ( !IsValid( player ) )
		return

	if ( !( "sentryTurretCount" in player.s ) || player.s.sentryTurretCount <= 0 )
		return

	local weapon = "mp_weapon_yh803_bullet"
	local title = "mp_weapon_yh803_bullet"
	local team = player.GetTeam()
	local origin = Vector( posX.tointeger(), posY.tointeger(), posZ.tointeger() + 1 )
	local angles = Vector( angX.tointeger(), angY.tointeger(), angZ.tointeger() )
	local name = ""

	local turret = SpawnTurret( "npc_turret_sentry", SENTRY_TURRET_MODEL, weapon, title, team, origin, angles, name, 6 /*vPhysics*/ )

	turret.kv.AccuracyMultiplier = COOP_TURRET_ACCURACY_MULTIPLIER
	turret.SetMaxHealth( COOP_TURRET_HEALTH )
	turret.SetHealth( COOP_TURRET_HEALTH )

	turret.s.preventOwnerDamage <- true
	thread CaptureTurret( turret, team, player )
	thread SentryTurretOnDeath( turret, player )
	thread CoopTD_ProcessPlayerTurretKill( turret, player )

	player.s.sentryTurretCount = max( 0, player.s.sentryTurretCount - 1 )

	player.DeployWeapon()

	turret.SetTitle( " " )
	turret.SetShortTitle( " " ) //hack to stop the bossplayername from drawing through code
	turret.Minimap_SetDefaultMaterial( "vgui/HUD/coop/minimap_coop_turret" )
	turret.Minimap_SetAlignUpright( true )
	turret.Minimap_SetObjectScale( MINIMAP_SENTRY_TURRET_SCALE )
	turret.Minimap_Hide( TEAM_MILITIA, null )
	turret.Minimap_Hide( TEAM_IMC, null )
	SentryTurret_ShowOnHud( turret )

	turret.SetUsable()
	turret.SetUsableByGroup( "owner pilot" )
	turret.SetUsePrompts( "#TURRET_DISMANTLE_HOLD_USE", "#TURRET_DISMANTLE_PRESS_USE" )
	thread DismantleTurretThink( turret )

	return true
}

function DismantleTurretThink( turret )
{
	turret.EndSignal( "OnDestroy" )

	while( 1 )
	{
		local results = turret.WaitSignal( "OnPlayerUse" )

		if ( !IsAlive( turret ) )
			return

		local player = results.activator

		if ( !IsValid( player ) )
			continue

		if ( !player.IsPlayer() )
			continue

		if ( player != turret.GetBossPlayer() )
			continue

		//dissolve away
		EmitSoundOnEntity( turret, "Coop_SentryGun_ScrapTurret" )
		turret.Dissolve( ENTITY_DISSOLVE_NORMAL, Vector( 0, 0, 0 ), 500 )

		//if you let the disolve finish - then it will play it's death explosion fx
		wait 1.85
		turret.Destroy()
		return
	}
}

function SentryTurret_ShowOnHud( turret )
{
	if ( FlagExists( "CoopTD_WaveCombatInProgress" ) && Flag( "CoopTD_WaveCombatInProgress" ) )
		return

	local player = turret.GetBossPlayer()
	if ( !IsValid( player ) )
		return
	if ( !player.IsPlayer() )
		return

	local team = player.GetTeam()
	turret.Minimap_AlwaysShow( 0, player )
	local ehandle = turret.GetEncodedEHandle()
	Remote.CallFunction_Replay( player, "ServerCallback_TurretWorldIconShow", ehandle  )
}

function SentryTurret_HideOnHud( turret )
{
	local player = turret.GetBossPlayer()
	if ( !IsValid( player ) )
		return
	if ( !player.IsPlayer() )
		return

	local player = turret.GetBossPlayer()
	if ( !IsValid( player ) )
		return
	if ( !player.IsPlayer() )
		return

	local team = player.GetTeam()
	turret.Minimap_Hide( team, player )
	local ehandle = turret.GetEncodedEHandle()
	Remote.CallFunction_Replay( player, "ServerCallback_TurretWorldIconHide", ehandle )
}

function HideAllSentryTurretsOnHud()
{
	local turrets = GetNPCArrayByClass( "npc_turret_sentry" )
	foreach ( turret in turrets )
		SentryTurret_HideOnHud( turret )
}
Globalize( HideAllSentryTurretsOnHud )

function ShowAllSentryTurretsOnHud()
{
	local turrets = GetNPCArrayByClass( "npc_turret_sentry" )
	foreach ( turret in turrets )
		SentryTurret_ShowOnHud( turret )
}
Globalize( ShowAllSentryTurretsOnHud )

function ClientCallback_AbortSentryTurret( player )
{
	if ( !IsValid( player ) )
		return

	if ( player.ContextAction_IsActive() == false )
		player.DeployWeapon()

	return true
}

function SentryTurretOnDeath( turret, player )
{
	turret.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( turret )
		{
			// seems like this might cause issues with ai_turret script not expecting the turrets to ever go away?
			// I've not managed to break it yet so I guess we'll see if it works with dedis etc.
			if ( IsValid( turret ) )
			{
				EmitSoundOnEntity( turret, "Coop_SentryGun_Explode" )
				turret.Destroy()
			}
		}
	)

	turret.WaitSignal( "OnDeath" )
}

function CoopTD_ProcessPlayerTurretKill( turret, turretOwner )
{
	turret.EndSignal( "OnDeath" )
	turret.EndSignal( "OnDestroy" )

	local oldtotalKills = turret.kv.killCount.tointeger()

	while( 1 )
	{
		wait 0.5

		local totalKills = turret.kv.killCount.tointeger()
		local killDetected = ( totalKills > oldtotalKills )
		if ( killDetected )
		{
			if ( totalKills % COOP_TURRET_KILL_STREAK_REQUIREMENT == 0 )
				AddPlayerScore( turretOwner, "CoopTurretKillStreak" )
		}

		oldtotalKills = totalKills
	}
}


// ------------------------------
// --------- VO & MUSIC ---------
// ------------------------------
function PlayConversationToCoopTeam( soundAlias )
{
	printt( "Playing conversation to coop team:", soundAlias )

	PlayConversationToTeam( soundAlias, level.nv.attackingTeam )
}
Globalize( PlayConversationToCoopTeam )


function PlayConversationToAliveCoopPlayers( soundAlias )
{
	local livingPlayers = GetLivingPlayers()

	foreach ( player in livingPlayers )
		PlayConversationToCoopPlayer( soundAlias, player )
}
Globalize( PlayConversationToAliveCoopPlayers )


function PlayConversationToCoopPlayer( alias, player )
{
	printt( "Playing turret conversation to player:", alias, player )

	PlayConversationToPlayer( alias, player )
}
Globalize( PlayConversationToCoopPlayer )


function CoopMusicPlay( musicID  )
{
	CoopMusicPlay_Common( musicID )

	CreateTeamMusicEvent( TEAM_MILITIA, musicID, Time() )

	foreach ( player in GetPlayerArray() )
		Remote.CallFunction_Replay( player, "ServerCallback_CoopMusicPlay", musicID )
}
Globalize( CoopMusicPlay )


function CoopMusicPlay_ForceLoop( musicID  )
{
	CoopMusicPlay_Common( musicID )

	local shouldSeek = false  // when a late player connects, can't seek into currently playing track bc of how these aliases are set up. Just start from the beginning instead.
	CreateTeamMusicEvent( TEAM_MILITIA, musicID, 0, shouldSeek )

	foreach ( player in GetPlayerArray() )
		Remote.CallFunction_Replay( player, "ServerCallback_CoopMusicPlay", musicID, true )
}
Globalize( CoopMusicPlay_ForceLoop )


function CoopMusicPlay_Common( musicID )
{
	local musicName = null
	foreach ( name, id in getconsttable().eMusicPieceID )
	{
		if ( musicID == id )
		{
			musicName = name
			break
		}
	}
	Assert( musicName != null, "CoopMusicPlay: bad musicID " + musicID )

	printt( "Playing coop music:", musicName )
}

function Coop_SetScoreEventOverride()
{
	level.gameModeScoreEventOverrides[ "KillTitan" ] 		<- POINTVALUE_COOP_KILL_TITAN
	level.gameModeScoreEventOverrides[ "TitanAssist" ] 		<- POINTVALUE_COOP_ASSIST_TITAN
}
