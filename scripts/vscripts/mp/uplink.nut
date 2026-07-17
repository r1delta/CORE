//********************************************************************************************
//	capture_point
//********************************************************************************************

if ( !IsServer() )
	return

const SFX_SPECTRE_LIGHT_ACTIVATE = "corporate_spectre_initialize_beep"
const SFX_SPECTRE_RACK_ACTIVATE = "corporate_spectrerack_activate"
const SFX_SPECTRE_RACK_RESET = "corporate_spectrerack_reset"

const FX_SPECTRE_RACK_RESET_TOP = "P_spectre_spawn_emitter"
const FX_SPECTRE_RACK_RESET_MID = "P_spectre_spawn_emitter"
const FX_SPECTRE_RACK_RESET_BOTTOM = "P_spectre_spawn"

const FX_SPECTRE_RACK_RESET_BOTTOM_IMC = "P_spectre_spawn_imc"

PrecacheParticleSystem( FX_SPECTRE_RACK_RESET_TOP )
PrecacheParticleSystem( FX_SPECTRE_RACK_RESET_MID )
PrecacheParticleSystem( FX_SPECTRE_RACK_RESET_BOTTOM )
PrecacheParticleSystem( FX_SPECTRE_RACK_RESET_BOTTOM_IMC )

function main()
{
	AddCallback_PlayerOrNPCKilled( CapturePoint_OnPlayerOrNPCKilled )

	SetGameModeAnnouncement( "GameModeAnnounce_CP" )

	level.cpCustomSpawnFunc <- null
	level.customPlayerEliminatedMessage = "#UPLINK_RESPAWN_NEXT_SWAP"
	level.lastUplinkID <- -1

	RegisterSignal( "CapturePointStateChange" )
	RegisterSignal( "CapturePointUpdate" )
	RegisterSignal( "HardpointVO_Progress" )
	RegisterSignal( "UplinkEstablished" )
	RegisterSignal( "SpectreSpawnComplete" )

	PrecacheModel( "models/commercial/rack_spectre_triple.mdl" )

	AddCallback_OnPlayerKilled( OnUplinkPlayerKilled )
}


function EntitiesDidLoad()
{
	Uplink_RegisterMinimapMaterial( "hardpoint_locked", "vgui/hud/capture_point_minimap_locked" )
	Uplink_RegisterMinimapMaterial( "hardpoint_locked_grey", "vgui/hud/capture_point_minimap_locked_grey" )

	//SpawnPoints_SetRatingMultipliers_Enemy( "ai", -2.0, -0.25, 0.0 )
	//SpawnPoints_SetRatingMultipliers_Friendly( "ai", 0.0, 0.0, 0.0 )

	// don't do the rest if we couldn't init (testmaps)
	//level.hardpointModeInitialized =
	InitializeHardpointsForUplink()
	//if ( !level.hardpointModeInitialized )
	//return

	//SetupAssaultPointKeyValues()
	//if ( IsNPCSpawningEnabled() )
	//	thread SetupCapturePointNPCs( level.hardpoints )

	thread UplinkThink()
	thread HardpointRadiusCheck()
}


function InitializeHardpointsForUplink()
{
	// local uplinkArray = GetEntArrayByName_Expensive( UPLINK )

	local uplinkArray = GetEntArrayByClass_Expensive( "info_hardpoint" )
	uplinkArray = SortHardpointsByGroup( uplinkArray )

	// do gamemode independed init
	InitializeHardpoints( uplinkArray )

	// initialize final capture point hardpoints
	foreach( i, uplinkPoint in level.hardpoints )
	{
		uplinkPoint.SetTeam( TEAM_UNASSIGNED )
		uplinkPoint.SetName( UPLINK )

		// setup minimap data
		local hardpointStringID = GetHardpointStringID( uplinkPoint.GetHardpointID() )

		SetLockedHardpointIcons( uplinkPoint, true )
		uplinkPoint.Minimap_SetObjectScale( 0.11 )
		uplinkPoint.Minimap_SetAlignUpright( true )
		uplinkPoint.Minimap_SetClampToEdge( true )
		uplinkPoint.Minimap_SetFriendlyHeightArrow( true )
		uplinkPoint.Minimap_SetEnemyHeightArrow( true )
		uplinkPoint.Minimap_SetZOrder( 10 )

		// show on all minimaps
		uplinkPoint.Minimap_AlwaysShow( TEAM_IMC, null )
		uplinkPoint.Minimap_AlwaysShow( TEAM_MILITIA, null )

		local origin = GetUplinkPointPosInfo( uplinkPoint ).origin
		local angles = GetUplinkPointPosInfo( uplinkPoint ).angles

		local racksModel = CreatePropDynamic( "models/commercial/rack_spectre_triple.mdl", origin, angles, 6 )

		local panel = CreateEntity( "prop_control_panel" )
		panel.kv.model = "models/communication/terminal_usable_imc_01.mdl"
		panel.kv.solid = 2

		DispatchSpawn( panel, false )

		panel.SetOrigin( origin )
		panel.SetAngles( angles )

		panel.SetTeam( TEAM_UNASSIGNED )
		panel.UnsetUsable()
		panel.s.uplinkMinimapUsable <- false

		local table = {}
		table.useFunc <- UseUplinkControlPanel
		table.useEnt <- uplinkPoint
		table.scope <- this

		AddControlPanelUseFuncTable( panel, table )

		uplinkPoint.SetTerminal( panel )

		SpectreRackSetup( racksModel )
		uplinkPoint.s.racks <- racksModel
		uplinkPoint.s.ambientSound <- ""
	}

	return true
}

function GetUplinkPointPosInfo( uplinkPoint )
{
	local origin = uplinkPoint.GetOrigin()
	local angles = uplinkPoint.GetAngles()
	local id = uplinkPoint.GetHardpointID()

	// Map specific hacks
	switch( GetMapName() )
	{
		case "mp_boneyard":
			break
	}

	if ( angles.x < 0 )
		angles.x += 360
	else if ( angles.x > 360 )
		angles.x -= 360

	if ( angles.y < 0 )
		angles.y += 360
	else if ( angles.y > 360 )
		angles.y -= 360

	return { origin = origin, angles = angles }
}

const UPLINK_ACTIVATION_DELAY = 10.0
const UPLINK_UPLOAD_TIME = 40.0
const UPLINK_MAX_SPECTRES = 21

RanFirstUplink <- false
function UplinkThink()
{
	WaittillGameStateOrHigher( eGameState.Playing )

	while ( GetGameState() == eGameState.Playing )
	{
		local uplinkPoint = GetNewUplinkHardpoint()

		waitthread UplinkControl( uplinkPoint )

		SetActiveUplinkPoint( null )
		SetLockedHardpointIcons( uplinkPoint, true )

		wait 5.0
		MessageToAll( eEventNotifications.UplinkLocatingNextPanel, null, null, Time() + UPLINK_ACTIVATION_DELAY )
		wait UPLINK_ACTIVATION_DELAY
	}

	SetActiveUplinkPoint( null )
}

function GetNewUplinkHardpoint()
{
	local id = 1
	if ( !RanFirstUplink )
	{
		if ( GetMapName() == "mp_nexus" )
			id = RandomInt( level.hardpoints.len() )

		RanFirstUplink = true
	}
	else
	{
		id = RandomInt( level.hardpoints.len() )
		while( id == level.nv.activeUplinkID )
			id = RandomInt( level.hardpoints.len() )
	}

	return GetHardpointByID( id )
}

function UplinkControl( uplinkPoint )
{
	SetActiveUplinkPoint( uplinkPoint )

	uplinkPoint.SetHardpointState( CAPTURE_POINT_STATE_NEXT )
	level.nv.activeUplinkTime = Time() + UPLINK_ACTIVATION_DELAY
	uplinkPoint.SetHardpointEstimatedCaptureTime( level.nv.activeUplinkTime )

	SetLockedHardpointIcons( uplinkPoint, false )
	thread PlayUplinkAlert( uplinkPoint )

	wait UPLINK_ACTIVATION_DELAY

	uplinkPoint.SetHardpointEstimatedCaptureTime( -1 )
	uplinkPoint.SetHardpointState( CAPTURE_POINT_STATE_UNASSIGNED )

	local panel = uplinkPoint.GetTerminal()
	panel.SetUsableByGroup( "pilot" )
	panel.s.uplinkMinimapUsable = true

	SetDefaultHardpointIcons( uplinkPoint )

	uplinkPoint.WaitSignal( "UplinkEstablished" )

	local ambientSound = "amb_fracture_computer_console_0" + RandomInt( 1, 10 )
	EmitSoundOnEntity( uplinkPoint, ambientSound )
	uplinkPoint.s.ambientSound <- ambientSound

	OnThreadEnd(
		function() : ( uplinkPoint )
		{
			StopSoundOnEntity( uplinkPoint, uplinkPoint.s.ambientSound )
		}
	)

	uplinkPoint.SetHardpointEstimatedCaptureTime( Time() + UPLINK_UPLOAD_TIME )
	uplinkPoint.SetHardpointProgressRefPoint( Time() )

	thread UplinkSpectreSpawnThink( uplinkPoint, UPLINK_UPLOAD_TIME )

	level.nv.activeUplinkTime = Time() + UPLINK_UPLOAD_TIME

	wait UPLINK_UPLOAD_TIME
}


function UplinkSpectreSpawnThink( uplinkPoint, duration )
{
	local panel = uplinkPoint.GetTerminal()

	local spawnDelay = max( 8.0, duration / (UPLINK_MAX_SPECTRES / 3) )
	local endTime = Time() + duration

	while ( Time() < endTime )
	{
		waitthread SpawnSpectres( uplinkPoint.s.racks, uplinkPoint.GetTeam(), UniqueString() )
		wait spawnDelay
	}
}

function UseUplinkControlPanel( panel, player, hardpoint )
{
	if ( hardpoint != GetActiveUplinkPoint() )
		return

	local player  = panel.GetBossPlayer()
	Uplink_TeamChanged( hardpoint, player.GetTeam() )
	AddPlayerScore( player, "LeechUplinkPanel" )
	hardpoint.s.lastCappingTeam = hardpoint.GetTeam()
}


function OnUplinkPlayerKilled( player, damageInfo )
{
	local activeUplinkPoint = GetActiveUplinkPoint()

	if ( !activeUplinkPoint )
		return

	local uplinkStatus = activeUplinkPoint.GetHardpointState()
	if ( uplinkStatus == CAPTURE_POINT_STATE_NEXT )
		return

	if ( activeUplinkPoint.GetTeam() == player.GetTeam() )
		SetPlayerEliminated( player )
}


function RespawnEliminatedPlayers()
{
	local players = GetPlayerArray()

	foreach ( player in players )
	{
		if ( IsAlive( player ) )
			continue

		if ( !IsPlayerEliminated( player ) )
			continue

		ClearPlayerEliminated( player )

		DecideRespawnPlayer( player )
	}
}

function SetActiveUplinkPoint( hardpoint )
{
	if ( level.nv.activeUplinkID != null )
	{
		local activeHardpoint = GetHardpointByID( level.nv.activeUplinkID )

		ResetUplinkPoint( activeHardpoint )
	}

	if ( !hardpoint )
	{
		thread RespawnEliminatedPlayers()

		level.nv.activeUplinkID = null
		return
	}

	ResetUplinkPoint( hardpoint )
	level.nv.activeUplinkID = hardpoint.GetHardpointID()
}
Globalize( SetActiveUplinkPoint )

function ResetUplinkPoint( hardpoint )
{
	hardpoint.SetHardpointState( CAPTURE_POINT_STATE_UNASSIGNED )
	hardpoint.SetHardpointEstimatedCaptureTime( -1 )
	hardpoint.SetHardpointProgressRefPoint( -1 )
	Uplink_TeamChanged( hardpoint, TEAM_UNASSIGNED )
}


function Uplink_TeamChanged( hardpoint, team )
{
	if ( team != TEAM_UNASSIGNED )
	{
		hardpoint.s.previousOwner = hardpoint.GetTeam()
		hardpoint.Signal( "UplinkEstablished" )
	}

	hardpoint.SetTeam( team )

	local panel = hardpoint.GetTerminal()
	panel.SetTeam( team )

	if ( team == TEAM_UNASSIGNED )
	{
		panel.UnsetUsable()
		panel.s.uplinkMinimapUsable = false
	}
	else
	{
		CapturePoint_AwardPlayerPoints( hardpoint )
		panel.SetUsableByGroup( "enemies pilot" )
		panel.s.uplinkMinimapUsable = true

		HardpointVO_Captured( hardpoint )
	}

	//Spawning_HardpointChangedTeams( hardpoint, previousTeam, team )

	// Give points for the team change to the appropriate people
	thread CapturePoint_AwardTeamOwnedPoints( hardpoint )
	thread CapturePoint_AwardPlayerHoldPoints( hardpoint )
}
Globalize( Uplink_TeamChanged )

function PlayersInOuterRadius( team, hardpoint )
{
	local playerArray = GetPlayerArrayOfTeam( team )
	foreach( player in playerArray )
	{
		if ( player.s.curHardpoint == hardpoint )
			return true
	}
	return false
}

function CapturePoint_OnPlayerOrNPCKilled( entity, attacker, damageInfo )
{
	local attacker = damageInfo.GetAttacker()
	local attackerTeam = attacker.GetTeam()
	local entTeam = entity.GetTeam()

	if ( attackerTeam != entTeam && attacker.IsPlayer() )
		CapturePointKillScoreEvent( entity, attacker )

	// clear hardpoint ID now that we don't need it anymore for callbacks
	ClearCurrentHardpointID( entity )
}


//////////////////////////////////////////////////////////
function CapturePointKillScoreEvent( victim, player )
{
	local victimHardpoint = null
	local playerHardpoint = null

	local victim_hpID = GetCurrentHardpointID( victim )
	local player_hpID = GetCurrentHardpointID( player )

	if ( !victim_hpID && !player_hpID )
		return

	if ( victim.GetTeam() != TEAM_IMC && victim.GetTeam() != TEAM_MILITIA )
		return

	if ( victim_hpID )
		victimHardpoint = GetHardpointByID( victim_hpID )

	if ( player_hpID )
		playerHardpoint = GetHardpointByID( player_hpID )

	// the score bonuses below currently only get awarded when the hardpoint is owned by one of the teams
	if ( ( victimHardpoint && victimHardpoint.GetTeam() == TEAM_UNASSIGNED ) && ( playerHardpoint && playerHardpoint.GetTeam() == TEAM_UNASSIGNED ) )
		return

	local scoreEventAlias = null

	// both players are in the same hardpoint
	if ( victimHardpoint && playerHardpoint && ( victimHardpoint == playerHardpoint ) )
	{
		local sharedHardpoint = victimHardpoint

		// victim team owns the hardpoint
		if ( sharedHardpoint.GetTeam() == victim.GetTeam() )
			scoreEventAlias = "HardpointAssault"
		// player team owns the hardpoint
		else if ( sharedHardpoint.GetTeam() == player.GetTeam() )
			scoreEventAlias = "HardpointDefense"
	}
	// victim is in the hardpoint, player is not
	else if ( victimHardpoint && !playerHardpoint )
	{
		if ( victimHardpoint.GetTeam() != TEAM_UNASSIGNED )
		{
			local dist = Distance( player.GetOrigin(), victim.GetOrigin() )

			if ( dist >= HARDPOINT_RANGED_ASSAULT_DIST )
				scoreEventAlias = "HardpointSnipe"
			else
				scoreEventAlias = "HardpointSiege"
		}
	}
	// player is in the hardpoint, victim is not
	else if ( playerHardpoint && !victimHardpoint )
	{
		if ( playerHardpoint.GetTeam() == player.GetTeam() )
		{
			local dist = Distance( player.GetOrigin(), victim.GetOrigin() )

			if ( dist <= HARDPOINT_PERIMETER_DEFENSE_RANGE )
				scoreEventAlias = "HardpointPerimeterDefense"
		}
	}

	if ( scoreEventAlias )
	{
		if ( victim.IsNPC() )
			scoreEventAlias += "NPC"

		AddPlayerScore( player, scoreEventAlias, victim )
	}
}

function HardpointVO_Captured( hardpoint )
{
	local hpTrig = hardpoint.s.trigger
	local players = GetPlayerArray()
	local hardpointStringID = GetHardpointStringID( hardpoint.GetHardpointID() )

	local cappingTeam = hardpoint.s.lastCappingTeam
	local previousOwner = hardpoint.s.previousOwner
	local enemyClose = false

	foreach( player in players )
	{
		// if opposing team and curHardpoint is hardpoint there is an enemy close
		if ( player.GetTeam() != cappingTeam && ( "curHardpoint" in player.s && player.s.curHardpoint == hardpoint ) )
		{
			enemyClose = true
			break
		}
	}

	foreach ( player in players )
	{
		local team = player.GetTeam()

		if ( team != cappingTeam )
		{
			// not on the capping team
			if  ( team == previousOwner )
			{
				// team used to control the hardpoint
				local convAlias = "hardpoint_lost_" + hardpointStringID

				PlayConversationToPlayer( convAlias, player )
			}
			continue
		}

		local convAlias = "hardpoint_captured_" + hardpointStringID
		PlayConversationToPlayer( convAlias, player )
	}
}

////////////////////////////////////////////////////////////////////////////////////////
function SpectreRackSetup( rack )
{
	local pos = rack.GetOrigin()
	local ang = rack.GetAngles()

	local spectreSpawnModel
	local spawnAng
	local spawnPos

	rack.s.spectreSpawnModels <- []

	for ( local i = 0; i < 3; i++ )
	{
		if ( i == 0 )
		{
			spawnAng = ang + Vector( 0, -90, 0 )
			spawnPos = PositionOffsetFromEnt( rack, -16, 24, 0 )
		}
		else if ( i == 1 )
		{
			spawnAng = ang + Vector( 0, 180, 0 )
			spawnPos = PositionOffsetFromEnt( rack, -48, 0, 0 )
		}
		else
		{
			spawnAng = ang + Vector( 0, 90, 0 )
			spawnPos = PositionOffsetFromEnt( rack, -16, -24, 0 )
		}

		spectreSpawnModel = CreatePropDynamic( NEUTRAL_SPECTRE_MODEL, spawnPos, spawnAng, 8 ) //<- 8 = "hitboxes only"
		spectreSpawnModel.s.spawnPos <- spawnPos
		spectreSpawnModel.s.spawnAng <- spawnAng
		spectreSpawnModel.s.animEnt <- CreateScriptRef( spawnPos, spawnAng )
		spectreSpawnModel.Anim_PlayWithRefPoint( "sp_med_bay_dropidle_A", spawnPos, spawnAng, 0 )
		spectreSpawnModel.s.posSpawnFxTop <- PositionOffsetFromEnt( spectreSpawnModel, 12, -0.25, 93.7036 )
		spectreSpawnModel.s.angSpawnFxTop <- spawnAng + Vector( 0, 0, 180 ) + Vector( 0, 90, 0 )
		spectreSpawnModel.s.posSpawnFxMid <- PositionOffsetFromEnt( spectreSpawnModel, 12, -0.25, 9.2036 )
		spectreSpawnModel.s.angSpawnFxMid <- spawnAng + Vector( 0, 0, 0 ) + Vector( 0, 90, 0 )
		spectreSpawnModel.s.posSpawnFxBottom <- spawnPos
		spectreSpawnModel.s.angSpawnFxBottom <- spawnAng + Vector( 0, -90, 0 ) + Vector( 0, 90, 0 )
		spectreSpawnModel.Hide()

		local angles = [ spectreSpawnModel.s.angSpawnFxTop, spectreSpawnModel.s.angSpawnFxMid, spectreSpawnModel.s.angSpawnFxBottom ]
		foreach ( ang in angles )
		{
			if ( ang.y < 0 )
				ang.y += 360
			else if ( ang.y > 360 )
				ang.y -= 360
		}

		rack.s.spectreSpawnModels.append( spectreSpawnModel )
	}
}

////////////////////////////////////////////////////////////////////////////////////////
function SpawnSpectres( rack, team, squadName )
{
	local soundPos = rack.GetOrigin() + Vector( 0, 0, 72)
	EmitSoundAtPosition( soundPos, SFX_SPECTRE_LIGHT_ACTIVATE )
	EmitSoundAtPosition( soundPos, SFX_SPECTRE_RACK_ACTIVATE )

	foreach ( spectreSpawnModel in rack.s.spectreSpawnModels )
		thread SpawnRackedSpectre( spectreSpawnModel, team, squadName )

	level.ent.WaitSignal( "SpectreSpawnComplete" )
}

////////////////////////////////////////////////////////////////////////////////////////
function SpawnRackedSpectre( spectreSpawnModel, team, squadName )
{
	//-----------------------------------------
	// 3D Printing FX to "replenish" Spectre
	//-----------------------------------------
	EmitSoundAtPosition( spectreSpawnModel.GetOrigin() + Vector( 0, 0, 72 ), SFX_SPECTRE_RACK_RESET )
	PlayFX( FX_SPECTRE_RACK_RESET_TOP, spectreSpawnModel.s.posSpawnFxTop, spectreSpawnModel.s.angSpawnFxTop )
	PlayFX( FX_SPECTRE_RACK_RESET_MID, spectreSpawnModel.s.posSpawnFxMid, spectreSpawnModel.s.angSpawnFxMid )
	if ( team == TEAM_IMC )
		PlayFX( FX_SPECTRE_RACK_RESET_BOTTOM_IMC, spectreSpawnModel.s.posSpawnFxBottom, spectreSpawnModel.s.angSpawnFxBottom )
	else
		PlayFX( FX_SPECTRE_RACK_RESET_BOTTOM, spectreSpawnModel.s.posSpawnFxBottom, spectreSpawnModel.s.angSpawnFxBottom )

	wait 4.2
	//spectreSpawnModel.Show()

	//-----------------------------------------
	// Hide fake spectre and spawn a real one
	//-----------------------------------------
	local spectre = Spawn_TrackedSpectre( team, squadName, spectreSpawnModel.GetOrigin(), spectreSpawnModel.GetAngles(), true, null, true )// <---hidden when spawned
	spectre.SetModel( NEUTRAL_SPECTRE_MODEL )
	MakeInvincible( spectre )
	thread PlayAnimTeleport( spectre, "sp_med_bay_dropidle_A", spectreSpawnModel.s.animEnt )
	local weapon = spectre.GetActiveWeapon()
	spectre.TakeActiveWeapon()	//need to hide weapon or we'll see a pop
	local weapon = weapon.GetClassname()

	spectre.EndSignal( "OnDeath" )
	spectre.EndSignal( "OnDestroy" )

	wait 0.3
	spectre.Show()
	wait 0.1
	spectreSpawnModel.Hide()
	spectre.Show()
	spectre.GiveWeapon( weapon )
	spectre.SetActiveWeapon( weapon )
	spectre.Anim_Stop()
	waitthread PlayAnim( spectre, "sp_med_bay_drop_armed", spectreSpawnModel.s.animEnt )
	ClearInvincible( spectre )

	wait 1

	level.ent.Signal( "SpectreSpawnComplete" )
}

function SetDefaultHardpointIcons( uplinkPoint )
{
	local icons = GetDefaultHardpointIcons( uplinkPoint )

	uplinkPoint.Minimap_SetDefaultMaterial( icons.neutral )
	uplinkPoint.Minimap_SetFriendlyMaterial( icons.friendly )
	uplinkPoint.Minimap_SetEnemyMaterial( icons.enemy )
}

function GetDefaultHardpointIcons( uplinkPoint )
{
	local hardpointStringID = GetHardpointStringID( uplinkPoint.GetHardpointID() )

	local table = {}
	table.neutral <- GetMinimapMaterial( "hardpoint_neutral_" + hardpointStringID )
	table.friendly <- GetMinimapMaterial( "hardpoint_friendly_" + hardpointStringID )
	table.enemy <- GetMinimapMaterial( "hardpoint_enemy_" + hardpointStringID )

	return table
}

function SetLockedHardpointIcons( uplinkPoint, grey )
{
	local icon = grey ? GetMinimapMaterial( "hardpoint_locked_grey" ) : GetMinimapMaterial( "hardpoint_locked" )

	uplinkPoint.Minimap_SetDefaultMaterial( icon )
	uplinkPoint.Minimap_SetFriendlyMaterial( icon )
	uplinkPoint.Minimap_SetEnemyMaterial( icon )
}

// Blatantly copied form scavenger loll
function PlayUplinkAlert( uplinkPoint )
{
	uplinkPoint.EndSignal( "UplinkEstablished" )

	while ( true )
	{
		EmitSoundOnEntity( uplinkPoint, "TEMP_Scavenger_Titan_Ore_Ping" )

		local pingCount = 5

		while( pingCount )
		{
			local icon = uplinkPoint.GetTerminal().s.uplinkMinimapUsable ? GetDefaultHardpointIcons( uplinkPoint ).neutral : GetMinimapMaterial( "hardpoint_locked" )
			Minimap_CreatePingForTeam( TEAM_IMC, uplinkPoint.GetOrigin(), icon, 0.5 )
			Minimap_CreatePingForTeam( TEAM_MILITIA, uplinkPoint.GetOrigin(), icon, 0.5 )
			--pingCount
			wait 0.4
		}

		wait 3.0
	}
}

// Literally only here so i dont have to add yet another random file to the repo
function Uplink_RegisterMinimapMaterial( materialRef, material )
{
	Assert( !( materialRef in level.minimapMaterials ) )
	Assert( level.allowRegisterMinimapMaterials )

	level.minimapMaterials[ materialRef ] <- material

	if( IsServer() )
		Minimap_PrecacheMaterial( material )
}

///////////////////////////////////////////////////////////////////////////////////////////////
function SpectreDefaultSpawn( spectre )
{
	if ( spectre.GetModelName() != UPLINK_SPECTRE_MODEL )
		spectre.SetModel( UPLINK_SPECTRE_MODEL )
}
