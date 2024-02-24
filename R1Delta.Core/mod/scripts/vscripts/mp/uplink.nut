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

const CP_AWARD_TEAM_OWNED_POINTS_SIGNAL = "CP_AWARD_TEAM_OWNED_POINTS_SIGNAL"
const CP_AWARD_PLAYER_HOLD_POINTS_SIGNAL = "CP_AWARD_PLAYER_HOLD_POINTS_SIGNAL"
const CP_END_CAPPING_WAIT_SIGNAL = "CP_END_CAPPING_WAIT_SIGNAL"
const CP_LEAVE_TRIGGER = "CP_LEAVE_TRIGGER"
const CP_REINFORCE_INTERVAL = 1.0
const CP_CAPTURE_HINT_RADIUS = 1536

function main()
{
	RegisterSignal( CP_AWARD_TEAM_OWNED_POINTS_SIGNAL )
	RegisterSignal( CP_AWARD_PLAYER_HOLD_POINTS_SIGNAL )
	RegisterSignal( CP_END_CAPPING_WAIT_SIGNAL )
	RegisterSignal( CP_LEAVE_TRIGGER )

	AddCallback_PlayerOrNPCKilled( CapturePoint_OnPlayerOrNPCKilled )

	SetGameModeAnnouncement( "GameModeAnnounce_CP" )

	level.cpCustomSpawnFunc <- null

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
}


function InitializeHardpointsForUplink()
{
	local hardpoints = GetEntArrayByClass_Expensive( "info_hardpoint" )
	foreach ( hardpoint in hardpoints )
		hardpoint.SetHardpointID( -1 )

	local uplinkArray = GetEntArrayByName_Expensive( UPLINK )


	level.hardpoints = uplinkArray

	// initialize final capture point hardpoints
	foreach( i, uplinkPoint in uplinkArray )
	{
		uplinkPoint.SetHardpointID( i )
		uplinkPoint.SetTeam( TEAM_UNASSIGNED )
		uplinkPoint.SetName( UPLINK )

		// setup minimap data
		local hardpointStringID = GetHardpointStringID( uplinkPoint.GetHardpointID() )

		uplinkPoint.Minimap_SetDefaultMaterial( GetMinimapMaterial( "hardpoint_neutral_a" ) )
		uplinkPoint.Minimap_SetFriendlyMaterial( GetMinimapMaterial( "hardpoint_friendly_a" ) )
		uplinkPoint.Minimap_SetEnemyMaterial( GetMinimapMaterial( "hardpoint_enemy_a" ) )
		uplinkPoint.Minimap_SetObjectScale( 0.11 )
		uplinkPoint.Minimap_SetAlignUpright( true )
		uplinkPoint.Minimap_SetClampToEdge( true )
		uplinkPoint.Minimap_SetFriendlyHeightArrow( true )
		uplinkPoint.Minimap_SetEnemyHeightArrow( true )
		uplinkPoint.Minimap_SetZOrder( 10 )

		// show on all minimaps
		//uplinkPoint.Minimap_Hide( TEAM_IMC, null )
		//uplinkPoint.Minimap_Hide( TEAM_MILITIA, null )

		local racksModel = CreatePropDynamic( "models/commercial/rack_spectre_triple.mdl", uplinkPoint.GetOrigin(), uplinkPoint.GetAngles(), 6 )

		local panel = CreateEntity( "prop_control_panel" )
		panel.kv.model = "models/communication/terminal_usable_imc_01.mdl"
		panel.kv.solid = 2

		DispatchSpawn( panel, false )

		panel.SetOrigin( uplinkPoint.GetOrigin() )
		panel.SetAngles( uplinkPoint.GetAngles() )

		panel.SetTeam( TEAM_UNASSIGNED )
		panel.UnsetUsable()

		thread UplinkPanelThink( panel, uplinkPoint )

		uplinkPoint.SetTerminal( panel )

		SpectreRackSetup( racksModel )
		uplinkPoint.s.racks <- racksModel
	}

	return true
}


function UplinkThink()
{
	WaittillGameStateOrHigher( eGameState.Playing )

	while ( GetGameState() == eGameState.Playing )
	{
		local uplinkPoint = GetHardpointByID( 1 /*RandomInt( level.hardpoints.len() )*/ )

		waitthread UplinkControl( uplinkPoint )

		SetActiveUplinkPoint( null )
		wait 10.0
	}

	SetActiveUplinkPoint( null )
}


const UPLINK_ACTIVATION_DELAY = 10.0
const UPLINK_UPLOAD_TIME = 40.0
const UPLINK_MAX_SPECTRES = 21

function UplinkControl( uplinkPoint )
{
	SetActiveUplinkPoint( uplinkPoint )

	uplinkPoint.SetHardpointState( CAPTURE_POINT_STATE_NEXT )
	level.nv.activeUplinkTime = Time() + UPLINK_ACTIVATION_DELAY
	uplinkPoint.SetHardpointEstimatedCaptureTime( level.nv.activeUplinkTime )

	wait UPLINK_ACTIVATION_DELAY

	uplinkPoint.SetHardpointEstimatedCaptureTime( -1 )
	uplinkPoint.SetHardpointState( CAPTURE_POINT_STATE_UNASSIGNED )
	uplinkPoint.GetTerminal().SetUsableByGroup( "pilot" )

	uplinkPoint.WaitSignal( "UplinkEstablished" )

	local panel = uplinkPoint.GetTerminal()
	panel.EndSignal( "PanelReprogram_Success" )

	uplinkPoint.SetHardpointEstimatedCaptureTime( Time() + UPLINK_UPLOAD_TIME )
	uplinkPoint.SetHardpointProgressRefPoint( Time() )

	thread UplinkSpectreSpawnThink( uplinkPoint, UPLINK_UPLOAD_TIME )

	level.nv.activeUplinkTime = Time() + UPLINK_UPLOAD_TIME

	wait UPLINK_UPLOAD_TIME
}


function UplinkSpectreSpawnThink( uplinkPoint, duration )
{
	local panel = uplinkPoint.GetTerminal()
	panel.EndSignal( "PanelReprogram_Success" )

	local spawnDelay = max( 8.0, duration / (UPLINK_MAX_SPECTRES / 3) )

	local endTime = Time() + duration

	while ( Time() < endTime )
	{
		waitthread SpawnSpectres( uplinkPoint.s.racks, uplinkPoint.GetTeam(), UniqueString() )
	}
}

function UplinkPanelThink( panel, hardpoint )
{
	while( true )
	{
		local results = panel.WaitSignal( "PanelReprogram_Success" )

		local player = results.player

		Uplink_TeamChanged( hardpoint, player.GetTeam() )
	}
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


function GetActiveUplinkPoint()
{
	if ( level.nv.activeUplinkID == null )
		return null

	return GetHardpointByID( level.nv.activeUplinkID )
}


function ResetUplinkPoint( hardpoint )
{
	hardpoint.SetHardpointState( CAPTURE_POINT_STATE_UNASSIGNED )
	hardpoint.SetHardpointEstimatedCaptureTime( -1 )
	hardpoint.SetHardpointProgressRefPoint( -1 )
	Uplink_TeamChanged( hardpoint, TEAM_UNASSIGNED )
}


function Uplink_TeamChanged( hardpoint, team )
{
	hardpoint.SetTeam( team )

	if ( team != TEAM_UNASSIGNED )
		hardpoint.Signal( "UplinkEstablished" )

	local panel = hardpoint.GetTerminal()

	if ( team == TEAM_UNASSIGNED )
		panel.UnsetUsable()
	else
		panel.SetUsableByGroup( "enemies pilot" )

	//Spawning_HardpointChangedTeams( hardpoint, previousTeam, team )

	/*
	// Give points for the team change to the appropriate people
	CapturePoint_AwardPlayerPoints( hardpoint )
	thread CapturePoint_AwardTeamOwnedPoints( hardpoint )
	thread CapturePoint_AwardPlayerHoldPoints( hardpoint )
	*/
}
Globalize( Uplink_TeamChanged )


/*
both teams have 1.5 points for full duration
one point should award scoreLimit / 1.5 / timeLimitMinutes points per minute
*/
function CapturePoint_AwardTeamOwnedPoints( hardpoint )
{
	hardpoint.s.trigger.Signal( CP_AWARD_TEAM_OWNED_POINTS_SIGNAL )
	EndSignal( hardpoint.s.trigger, CP_AWARD_TEAM_OWNED_POINTS_SIGNAL )

	if ( hardpoint.GetTeam() == TEAM_UNASSIGNED )
		return

	//GameScore.AddTeamScore( hardpoint.GetTeam(), TEAMPOINTVALUE_HARDPOINT_CAPTURE )

	while( GetGameState() == eGameState.Playing )
	{
		Wait( TEAM_OWNED_SCORE_FREQ )
		GameScore.AddTeamScore( hardpoint.GetTeam(), TEAMPOINTVALUE_HARDPOINT_OWNED )
	}
}

function CapturePoint_AwardPlayerHoldPoints( hardpoint )
{
	hardpoint.s.trigger.Signal( CP_AWARD_PLAYER_HOLD_POINTS_SIGNAL )
	EndSignal( hardpoint.s.trigger, CP_AWARD_PLAYER_HOLD_POINTS_SIGNAL )

	if ( hardpoint.GetTeam() == TEAM_UNASSIGNED )
		return

	while( GetGameState() == eGameState.Playing )
	{
		Wait( PLAYER_HELD_SCORE_FREQ )
		CapturePoint_AwardPlayerHoldPointsInternal( hardpoint )
	}
}

function CapturePoint_AwardPlayerPoints( hardpoint )
{
	if( GetGameState() != eGameState.Playing )
		return

	local teamToGetPoints = hardpoint.GetTeam()
	if ( hardpoint.GetTeam() == TEAM_UNASSIGNED )
		teamToGetPoints = hardpoint.s.lastCappingTeam

	/*
	if ( teamToGetPoints == TEAM_UNASSIGNED )
		printl( "TRYING TO AWARD PLAYER POINTS FOR TEAM: UNASSIGNED" )
	else if ( teamToGetPoints == TEAM_IMC )
		printl( "TRYING TO AWARD PLAYER POINTS FOR TEAM: IMC" )
	else if ( teamToGetPoints == TEAM_MILITIA )
		printl( "TRYING TO AWARD PLAYER POINTS FOR TEAM: MILITIA" )
	*/

	// There should be some players in the array, otherwise not sure how it could have possibly changed ownership
	Assert( teamToGetPoints != TEAM_UNASSIGNED )
	//Assert( hardpoint.s.teamPlayersTouching[ teamToGetPoints ].len() > 0 )

	// Find the player who was in the trigger first
	local earliestPlayer = null
	local earliestTime = Time() + 1000

	foreach( player, time in hardpoint.s.teamPlayersTouching[ teamToGetPoints ] )
	{
		if ( !IsValid_ThisFrame( player ) )
			continue

		if ( time < earliestTime )
		{
			earliestPlayer = player
			earliestTime = time
		}
	}

	if ( !IsValid( earliestPlayer ) )
		return // lone player capping hardpoint probably disconnected

	local operatorControlled = false
	if ( !IsPlayer( earliestPlayer ) )
	{
		earliestPlayer = earliestPlayer.GetOwnerPlayer()
		//printl( "earliestPlayer was a marvin, owner = " + earliestPlayer.GetClassname() )
		if ( !earliestPlayer || !IsPlayer( earliestPlayer ) )
			return
		operatorControlled = true
	}

	// Award points to the player who was in the trigger the soonest
	if ( hardpoint.GetTeam() == TEAM_UNASSIGNED )
		AddPlayerScore( earliestPlayer, "ControlPointNeutralize" )
	else
		AddPlayerScore( earliestPlayer, "ControlPointCapture" )

	// Give points to everyone else also standing in the trigger when it changed
	// Make an array of players instead of looping through them so we can avoid duplicates, because if an operator has multiple marvins in the trigger you dont want to award points for each OnEndTouch
	local playersToGetPoints = {}
	foreach( player, time in hardpoint.s.teamPlayersTouching[ teamToGetPoints ] )
	{
		if ( !IsPlayer( player ) )
		{
			player = player.GetOwnerPlayer()
			if ( !IsPlayer( player ) )
				continue
		}

		if ( player == earliestPlayer )
			continue

		if ( player in playersToGetPoints )
			continue

		playersToGetPoints[ player ] <- true
	}

	// loop through the players array and award the points
	foreach( player, val in playersToGetPoints )
	{
		if ( hardpoint.GetTeam() == TEAM_UNASSIGNED )
			AddPlayerScore( player, "ControlPointNeutralizeAssist" )
		else
			AddPlayerScore( player, "ControlPointCaptureAssist" )
	}
}

function CapturePoint_AwardPlayerHoldPointsInternal( hardpoint )
{
	if( GetGameState() != eGameState.Playing )
		return

	local teamToGetPoints = hardpoint.GetTeam()
	if ( teamToGetPoints == TEAM_UNASSIGNED )
		teamToGetPoints = hardpoint.s.lastCappingTeam

	local players = GetPlayerArrayOfTeam( teamToGetPoints )

	foreach ( player in players )
	{
		Assert( "curHardpoint" in player.s && "curHardpointTime" in player.s )

		if ( !IsAlive( player ) || player.s.curHardpoint == null || player.s.curHardpointTime == null )
			continue

		if ( player.s.curHardpoint == hardpoint )
		{
			if ( (Time() - player.s.curHardpointTime) >= PLAYER_HELD_SCORE_FREQ )
				AddPlayerScore( player, "ControlPointHold" )
		}
	}
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

		spectreSpawnModel = CreatePropDynamic( MILITIA_SPECTRE_MODEL, spawnPos, spawnAng, 8 ) //<- 8 = "hitboxes only"
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

///////////////////////////////////////////////////////////////////////////////////////////////
function SpectreDefaultSpawn( spectre )
{
	if ( spectre.GetModelName() != UPLINK_SPECTRE_MODEL )
		spectre.SetModel( UPLINK_SPECTRE_MODEL )
}
