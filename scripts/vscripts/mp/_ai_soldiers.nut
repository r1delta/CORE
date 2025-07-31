//=========================================================
// MP ai soldier
//
//=========================================================

PrecacheModel( IMC_SPECTRE_MODEL )
PrecacheModel( MILITIA_SPECTRE_MODEL )
PrecacheModel( NEUTRAL_SPECTRE_MODEL )
PrecacheSprite( "sprites/glow_05.vmt" )
FlagInit( "disable_npcs" )
FlagInit( "Disable_IMC" )
FlagInit( "Disable_MILITIA" )
FlagInit( "Disable_SPECTRE" )
FlagSet("Disable_SPECTRE")

const RPG_USE_RARE = 0
const RPG_USE_SOMETIMES = 1
const RPG_USE_ALWAYS = 2

const STANDARDGOALRADIUS = 100

const AI_SPECTRE_ACCURACY = 1.0
const AI_SOLDIER_ACCURACY = 0.6
const AI_SPECTRE_PROFICIENCY = 2
const AI_SOLDIER_PROFICIENCY = 2

const CAPTAIN_NAME_FREQUENCY = 0.35

COOP_AT_WEAPON_RATES <- {}
COOP_AT_WEAPON_RATES[ "mp_weapon_rocket_launcher" ] <- 0.5
COOP_AT_WEAPON_RATES[ "mp_weapon_smr" ] <- 0.4
COOP_AT_WEAPON_RATES[ "mp_weapon_mgl" ] <- 0.1

const SPECTRE_GRENADE_OUT = "diag_spectre_gs_GrenadeOut_01_1"

function main()
{
	PrecacheModel( TEAM_IMC_GRUNT_MDL )
	PrecacheModel( TEAM_IMC_ROCKET_GRUNT_MDL )
	PrecacheModel( TEAM_MILITIA_GRUNT_MDL )
	PrecacheModel( TEAM_MILITIA_ROCKET_GRUNT_MDL )

	Globalize( GruntPod_Launch )
	Globalize( GruntPod_LaunchHunters )
	Globalize( GruntPod_LaunchToPoint )
	Globalize( SpectrePod_Launch )
	Globalize( SpectrePod_LaunchFollowers )
	Globalize( SpectreSquadFollowPlayer )
	Globalize( GetUniqueTeamId )
	Globalize( MakeSquadName )
	Globalize( GetPlayerSpectreSquadName )
	Globalize( SpawnSpectre )
	Globalize( SpawnGrunt )
	Globalize( SpawnGruntPropDynamic )
	Globalize( SpawnGruntLight )
	Globalize( disable_npcs )
	Globalize( Disable_IMC )
	Globalize( Disable_MILITIA )
	Globalize( Disable_SPECTRE )
	Globalize( ShouldSpawnSpectre )
	Globalize( CommonInit )
	Globalize( CommonDeath )
	Globalize( DisableRockets )
	Globalize( LaunchDropPodToGround )
	Globalize( GuyPathfindingFailsafe )
	Globalize( CreateGruntDropPod )
	Globalize( SpawnDropPodInhabitants )
	Globalize( UpdateEnemyMemoryDumpAndIncreaseMaxEnemyDist )
	Globalize( SpectreEyeGlow )
	Globalize( CreateGrunt )
	Globalize( SetupSoldierForRPGs )
	Globalize( IsNPCSpawningEnabled )
	Globalize( SetGruntTitleFromTeam )
	Globalize( EnemyChanged_Standard )
	Globalize( EnemyChanged_Rocket )
	Globalize( ResetNPCs )

	Globalize( Spawn_GruntSquad )
	Globalize( Spawn_SpectreSquad )

	Globalize( onlyimc )		// debug
	Globalize( onlymilitia )    // debug

	Globalize( GotoOrigin )
	Globalize( AssaultOrigin )
	Globalize( SquadGotoOrigin )
	Globalize( SquadAssaultOrigin )
	Globalize( CreateStrictAssaultEnt )

	Globalize( SetGlobalNPCHealth ) //debug

	level.onlySpawn <- null

	level.defaultTeamSquads <- {}
	level.defaultTeamSquads[TEAM_IMC] <- []
	level.defaultTeamSquads[TEAM_MILITIA] <- []

	// used to control who can switch to rockets
	level.teamTrackRPGUsage <- {}
	level.teamTrackRPGUsage[ TEAM_IMC ] <- 0
	level.teamTrackRPGUsage[ TEAM_MILITIA ] <- 0

	level.spectreSpawnStyle <- eSpectreSpawnStyle.MORE_FOR_ENEMY_TITANS

	FlagInit( "AllSpectre" )
	FlagInit( "AllSpectreIMC" )
	FlagInit( "AllSpectreMilitia" )
	FlagInit( "NoSpectreIMC" )
	FlagInit( "NoSpectreMilitia" )

	AddCallback_OnClientConnecting( AiSoldiers_InitPlayer )
	AddDeathCallback( "npc_spectre", CommonDeath )
	AddDeathCallback( "npc_soldier", CommonDeath )

	Globalize( ClientCommand_SpawnViewGrunt )
	Globalize( ClientCommand_SpawnViewCaptainGrunt )
	Globalize( ClientCommand_SpawnViewShieldGrunt )
	Globalize( ClientCommand_SpawnViewSpectre )
	Globalize( ClientCommand_SpawnViewShieldSpectre )

//	Globalize( ClientCommand_SpawnViewSuicideSpectre )
//	Globalize( ClientCommand_SpawnViewSniperSpectre )

//	if ( GetDeveloperLevel() > 0 )
	{
		AddClientCommandCallback( "SpawnViewGrunt", ClientCommand_SpawnViewGrunt )
		AddClientCommandCallback( "SpawnViewCaptainGrunt", ClientCommand_SpawnViewCaptainGrunt )
		AddClientCommandCallback( "SpawnViewShieldGrunt", ClientCommand_SpawnViewShieldGrunt )

		AddClientCommandCallback( "SpawnViewSpectre", ClientCommand_SpawnViewSpectre )
		AddClientCommandCallback( "SpawnViewShieldSpectre", ClientCommand_SpawnViewShieldSpectre )

//		AddClientCommandCallback( "SpawnViewSuicideSpectre", ClientCommand_SpawnViewSuicideSpectre )
//		AddClientCommandCallback( "SpawnViewSniperSpectre", ClientCommand_SpawnViewSniperSpectre )
	}

	InitCaptainNames()

	RegisterSignal("Stop_SimulateGrenadeThink")
}

function ClientCommand_SpawnViewGrunt( player, team )
{
	if ( !GetConVarBool( "sv_cheats" ) )
		return true

	SpawnViewMinion( player, team, SpawnGrunt )
	return true
}

function ClientCommand_SpawnViewShieldGrunt( player, team )
{
	if ( !GetConVarBool( "sv_cheats" ) )
		return true

	SpawnViewMinion( player, team, SpawnBubbleShieldGrunt_Signal )
	return true
}

function ClientCommand_SpawnViewCaptainGrunt( player, team )
{
	if ( !GetConVarBool( "sv_cheats" ) )
		return true

	SpawnViewMinion( player, team, SpawnGruntCaptain )
	return true
}

function ClientCommand_SpawnViewSpectre( player, team )
{
	if ( !GetConVarBool( "sv_cheats" ) )
		return true

	SpawnViewMinion( player, team, SpawnSpectre )
	return true
}

function ClientCommand_SpawnViewShieldSpectre( player, team )
{
	if ( !GetConVarBool( "sv_cheats" ) )
		return true

	SpawnViewMinion( player, team, SpawnBubbleShieldSpectre_Signal )
	return true
}

/*
function ClientCommand_SpawnViewSuicideSpectre( player, team )
{
	if ( !GetConVarBool( "sv_cheats" ) )
		return true

	SpawnViewMinion( player, team, SpawnSuicideSpectre )
	return true
}

function ClientCommand_SpawnViewSniperSpectre( player, team )
{
	if ( !GetConVarBool( "sv_cheats" ) )
		return true

	SpawnViewMinion( player, team, SpawnSniperSpectre )
	return true
}
*/

function SpawnViewMinion( player, team, spawnFunc )
{
	local origin = player.EyePosition()
	local angles = player.EyeAngles()
	local forward = angles.AnglesToForward()
	local result = TraceLine( origin, origin + forward * 2000, player )
	angles.x = 0
	angles.z = 0

	spawnFunc( team, "squad" + team + RandomInt(100), result.endPos, angles )

	return true
}

function GetFreeSquadName( team )
{
	foreach ( squadName in level.defaultTeamSquads[team] )
	{
		if ( GetNPCSquadSize( squadName ) )
			continue

		return squadName
	}

	local teamStr
	if ( team == TEAM_IMC )
		teamStr = "imc"
	else
		teamStr = "militia"

	local squadName = "squad_" + teamStr + "_" + GetUniqueTeamId( team )

	level.defaultTeamSquads[team].append( squadName )

	return squadName
}

// debug commands
function onlyimc()
{
	level.onlySpawn = TEAM_IMC
	printt( "Only spawning IMC AI" )
}

// debug commands
function onlymilitia()
{
	level.onlySpawn = TEAM_MILITIA
	printt( "Only spawning Militia AI" )
}

//////////////////////////////////////////////////////////
function AiSoldiers_InitPlayer( player )
{
	player.s.next_ai_callout_time <- -1

	local squadName = GetPlayerSpectreSquadName( player )
	player.s.spectreSquad <- squadName
}

//////////////////////////////////////////////////////////
function MakeSquadName( team, index )
{
	local teamStr

	if ( team == TEAM_IMC )
		teamStr = "imc"
	else
		teamStr = "militia"

	return "squad_" + teamStr + index
}


//////////////////////////////////////////////////////////
function GruntPod_Launch( team, squadName, spawnpoint, spawnFunc )
{
	spawnpoint.s.inUse = true
	local dropPod = LaunchDropPodToGround( team, spawnpoint.GetOrigin(), spawnpoint.GetAngles() )
	spawnpoint.s.inUse = false

	SpawnDropPodInhabitants( dropPod, team, squadName, spawnFunc )
}

//////////////////////////////////////////////////////////
function GruntPod_LaunchToPoint( team, squadName, point, angles, spawnFunc )
{
	local dropPod = LaunchDropPodToGround( team, point, angles )
	return SpawnDropPodInhabitants( dropPod, team, squadName, spawnFunc )
}

//////////////////////////////////////////////////////////
function LaunchDropPodToGround( team, origin, angles )
{
	local dropPod = CreateGruntDropPod()
	dropPod.SetTeam( team )

	// cant play animation on a newly spawned droppod
	waitthread LaunchAnimDropPod( dropPod, "pod_testpath", origin, angles )
	return dropPod
}

//////////////////////////////////////////////////////////
function SpawnDropPodInhabitants( dropPod, team, squadName, spawnFunc )
{
	return SpawnGrunts( dropPod, team, squadName, spawnFunc )
}

//////////////////////////////////////////////////////////
function GruntPod_LaunchHunters( team, squadName, spawnpoint, spawnFunc )
{
	// doesn't seem to be used except by im_fuel_extract.nut
	if ( level.onlySpawn != null )
		team = level.onlySpawn

	GruntPod_Launch( team, squadName, spawnpoint, spawnFunc )

	if ( IsNPCSpawningEnabled() )
	{
		wait 0.5

		local gruntArray = GetNPCArrayBySquad( squadName )

		//SquadAssaultEnemySpawn( gruntArray )
		if ( Flag( "FrontlineInitiated" ) )
		{
			local squadIndex = GetIndexSmallestSquad( team )
			SquadAssaultFrontline( gruntArray, squadIndex )
		}
	}
}

//////////////////////////////////////////////////////////
function SpectrePod_Launch( team, squadName, spawnpoint )
{
	GruntPod_Launch( team, squadName, spawnpoint, SpawnSpectre )
}


//////////////////////////////////////////////////////////
function SpectreSquadFollowPlayer( player, squadName )
{
	// hack; defensive check because "GetNPCArrayBySquad" give a script error if the squadname doesn't exist
	if ( !GetNPCSquadSize( squadName ) )
		return

	local spectreArray = GetNPCArrayBySquad( squadName )
	local freeFollowerSlots = 3
	local overflow = []

	foreach ( spectre in spectreArray )
	{
		if ( freeFollowerSlots )
		{
			SpectreFollow( spectre, player )
			freeFollowerSlots--
		}
		else
		{
			overflow.append( spectre )
		}
	}

	if ( overflow.len() > 0 )
	{
		if ( Flag( "FrontlineInitiated" ) )
		{
			local team = player.GetTeam()
			local squadIndex = GetIndexSmallestSquad( team )
			SquadAssaultFrontline( overflow, squadIndex )
		}
		//SquadAssaultEnemySpawn( overflow )
	}
}


//////////////////////////////////////////////////////////
function SpectrePod_LaunchFollowers( player, spawnpoint )
{
	local squadName = GetPlayerSpectreSquadName( player )

	GruntPod_Launch( player.GetTeam(), squadName, spawnpoint, SpawnSpectre )

	player.EndSignal( "OnDeath" )
	player.EndSignal( "Disconnected" )

	// hack; GetNPCArrayBySquad fails when called immediately after spawn
	wait 0

	SpectreSquadFollowPlayer( player, squadName )
}


//////////////////////////////////////////////////////////
function GruntMoverDropPodImpact( pod )
{
	pod.EndSignal( "OnDestroy" )

	pod.WaitSignal( "OnImpact" )

	local origin = pod.GetOrigin()
	local angles = pod.GetAngles()

	pod.SetOrigin( origin + Vector( 0, 0, 12 ) )
	pod.SetVelocity( Vector( 0, 0, 0 ) )
	pod.SetAngles( Vector( 0, angles.y, 0 ) )
}

//////////////////////////////////////////////////////////
function CreateGruntDropPod()
{
	local dropPod

	dropPod = CreatePropDynamic( DROPPOD_MODEL )	// model is set in InitFireteamDropPod()
	InitFireteamDropPod( dropPod )

	return dropPod
}


//////////////////////////////////////////////////////////
function CreateGrunt( team, model, weapon, alert = true, captain = false )
{
	local npc_soldier
	local alertVal = alert ? 1 : 0

	npc_soldier = CreateEntity( "npc_soldier" )
	npc_soldier.kv.spawnflags = 131072 | 512 | 4 // don't drop grenade, fall to ground, fade corpse
	npc_soldier.kv.AccuracyMultiplier = AI_SOLDIER_ACCURACY
	npc_soldier.kv.alwaysalert = alertVal
	npc_soldier.kv.reactChance = 20
	npc_soldier.kv.reactFriendlyChance = 100
	npc_soldier.kv.health = 120
	npc_soldier.kv.max_health = 120
	npc_soldier.kv.physdamagescale = 1.0
	npc_soldier.kv.WeaponProficiency = AI_SOLDIER_PROFICIENCY
	npc_soldier.kv.NumGrenades = 0
	npc_soldier.kv.teamnumber = team
	npc_soldier.kv.additionalequipment = weapon

	//npc_soldier.SetNameVisibleToEnemy( false )

	npc_soldier.SetModel( model )
	SetGruntTitleFromTeam( npc_soldier, team, captain )
	RandomizeHead( npc_soldier )

	if ( alert )
		npc_soldier.SetDefaultSchedule( "SCHED_ALERT_SCAN" )

	return npc_soldier
}

function SetGruntTitleFromTeam( grunt, team, captain = false )
{
	if ( team == TEAM_IMC )
	{
		if ( captain )
			grunt.SetTitle( GetCaptainName() )
		else
			grunt.SetTitle( "#NPC_GRUNT_IMC" )
	}
	else
	{
		if ( captain )
			grunt.SetTitle( GetCaptainName() )
		else
			grunt.SetTitle( "#NPC_GRUNT_MILITIA" )
	}
}


//////////////////////////////////////////////////////////
// common init for grunts and spectres
function CommonInit( npc )
{
	npc.GetNewEnemyFromSound( true )
	npc.StayCloseToSquad( true )
	//npc.SetRevealRadius( FIREATEAM_REVEAL_RADIUS )
	//npc.SetAffectedByShroud( true )
	npc.s.isFireteam <- false

	npc.s.hpAssaultIndex <- 0
	npc.s.hunterEnabled <- false

	npc.SetEngagementDistVsWeak( 0, 1500 )
	npc.SetEngagementDistVsStrong( 250, 1500 )

	npc.s.cpState <- eNPCStateCP.NONE
}

//////////////////////////////////////////////////////////
// common death function for grunts and spectres
function CommonDeath( npc, damageInfo )
{
	if( "assaultPoint" in npc.s )
		npc.s.assaultPoint.Destroy()
}


//////////////////////////////////////////////////////////
function SpawnGrunt( team, squadName, origin, angles, alert = true, weapon = null, hidden = false, captain = false )
{
	team = GetProperTeamValue( team )

	local model = GetGruntModel( team, captain )
	if ( weapon == null )
		weapon = GetGruntWeapon( team )

	local soldier = CreateGrunt( team, model, weapon, alert, captain )

	soldier.SetOrigin( origin )
	soldier.SetAngles( angles )

	//soldier.kv.health = health
	soldier.kv.squadname = squadName

	if ( hidden )
		soldier.Hide()	//may want to hide before spawning to avoid pop in scripted model swaps

	DispatchSpawn( soldier, true )

	soldier.SetDoFaceAnimations( team == TEAM_MILITIA )

	soldier.SetAISettings( "fireteam_soldier" )	// do this after spawning

	SetupSoldierForRPGs( soldier, team )

	soldier.ConnectOutput( "OnSeeEnemy", OnSoldierSeeEnemy )

	CommonInit( soldier )

	return soldier
}

function SpawnBubbleShieldGrunt( team, squadName, origin, angles)
{
	local grunt = SpawnGrunt( team, squadName, origin, angles )
	CreateBubbleShieldMinion( grunt )
	return grunt
}
Globalize( SpawnBubbleShieldGrunt )

function SpawnBubbleShieldGrunt_Signal( team, squadName, origin, angles)
{
	local grunt = SpawnBubbleShieldGrunt( team, squadName, origin, angles )
	grunt.Signal( "npc_deployed" )
	return grunt
}

function SpawnBubbleShieldSpectre( team, squadName, origin, angles )
{
	local spectre = SpawnSpectre( team, squadName, origin, angles )
	CreateBubbleShieldMinion( spectre )
	return spectre
}
Globalize( SpawnBubbleShieldSpectre )

function SpawnBubbleShieldSpectre_Signal( team, squadName, origin, angles )
{
	local spectre = SpawnBubbleShieldSpectre( team, squadName, origin, angles )
	spectre.Signal( "npc_deployed" )
	return spectre
}

function CreateBubbleShieldMinion( guy )
{
	if ( guy.IsSpectre() )
	{
		guy.SetModel( MODEL_BUBBLESHIELD_SPECTRE )
		guy.SetSubclass( eSubClass.bubbleShieldSpectre )
	}
	else
	{
		if ( guy.GetTeam() == TEAM_MILITIA )
			guy.SetModel( TEAM_MILITIA_CAPTAIN_MDL )
		else
			guy.SetModel( TEAM_IMC_CAPTAIN_MDL )

		guy.SetSubclass( eSubClass.bubbleShieldGrunt )
	}

	guy.SetAlwaysIndoor( true )//gets them to cqb walk instead of run
	guy.SetTitle( "#NPC_BUBBLESHIELD_MINION_TITLE" )

	thread CreateMinionBubbleShield( guy )//delay to give him time to exit the droppod
}
Globalize( CreateBubbleShieldMinion )


function CreateMinionBubbleShield( guy )
{
	guy.EndSignal( "OnDeath" )
	guy.EndSignal( "OnDestroy" )

	guy.WaitSignal( "npc_deployed" )
	guy.SetNPCPriorityOverride( 1 )

	local origin = guy.GetOrigin()
	local angles = guy.GetAngles()
	local degrees = 360 // full sphere

	local vortexSphere = CreateEntity( "vortex_sphere" )
	vortexSphere.kv.spawnflags = 1 //| 2 | 8 // SF_ABSORB_BULLETS | SF_BLOCK_OWNER_WEAPON | SF_ABSORB_CYLINDER
	vortexSphere.kv.enabled = 0
	vortexSphere.kv.radius = MINION_BUBBLE_SHIELD_RADIUS
	vortexSphere.kv.bullet_fov = degrees
	vortexSphere.kv.physics_pull_strength = 25
	vortexSphere.kv.physics_side_dampening = 6
	vortexSphere.kv.physics_fov = degrees
	vortexSphere.kv.physics_max_mass = 2
	vortexSphere.kv.physics_max_size = 6

	vortexSphere.SetAngles( angles ) // viewvec?
	vortexSphere.SetOrigin( origin )
	vortexSphere.SetOwner( guy )
	vortexSphere.SetMaxHealth( 32000 )
	vortexSphere.SetHealth( 32000 )

	DispatchSpawn( vortexSphere, true )
	vortexSphere.Fire( "Enable" )

	// Shield wall fx control point
	local cpoint = CreateEntity( "info_placement_helper" )
	cpoint.SetName( UniqueString( "shield_wall_controlpoint" ) )
	DispatchSpawn( cpoint, false )

	// Shield wall fx
	local particleSystem = CreateEntity( "info_particle_system" )
	particleSystem.kv.start_active = 1
	particleSystem.kv.VisibilityFlags = 7
	particleSystem.kv.effect_name = FX_SPECTRE_BUBBLESHIELD
	particleSystem.SetName( UniqueString() )
	particleSystem.SetOrigin( vortexSphere.GetOrigin() )
	DispatchSpawn( particleSystem, false )

	particleSystem.SetParent( guy, "CHESTFOCUS" )

	particleSystem.s.cpoint 	<- cpoint
	vortexSphere.s.shieldWallFX <- particleSystem

	OnThreadEnd(
		function () : ( vortexSphere, particleSystem )
		{
			if ( IsValid_ThisFrame( particleSystem ) )
			{
				particleSystem.ClearParent()
				particleSystem.Fire( "StopPlayEndCap" )
				particleSystem.Kill( 1.0 )
			}

			if ( IsValid_ThisFrame( vortexSphere ) )
			{
				StopSoundOnEntity( vortexSphere, "BubbleShield_Sustain_Loop" )
				EmitSoundOnEntity( vortexSphere, "BubbleShield_End" )
				vortexSphere.Kill()
			}
		}
	)

	vortexSphere.SetTeam( guy.GetTeam() )
	vortexSphere.SetParent( guy, "CHESTFOCUS" )
	EmitSoundOnEntity( vortexSphere, "BubbleShield_Sustain_Loop" )

	guy.WaitSignal( "OnDeath" )
}
Globalize( CreateMinionBubbleShield )


function SpawnGruntCaptain( team, squadName, origin, angles, alert = true, weapon = null, hidden = false )
{
	local captain = true
	return SpawnGrunt( team, squadName, origin, angles, alert, weapon, hidden, captain )
}
Globalize( SpawnGruntCaptain )

function SpawnGruntPropDynamic( team, squadName, origin, angles, alert = true, weapon = null, hidden = false )
{
	team = GetProperTeamValue( team )

	local model = GetGruntModel( team )
	if ( weapon == null )
		weapon = GetGruntWeapon( team )

	local fadeDist = 10000
	local soldier = CreatePropDynamic( model, origin, angles, 0, fadeDist )
	soldier.SetTeam( team )
	soldier.s.gun <- CreatePropDynamic( GetWeaponModel( weapon ), origin, angles, 0, fadeDist )
	soldier.s.gun.SetParent( soldier, "PROPGUN" )

	if ( hidden )
		soldier.Hide()

	return soldier
}

function GetProperTeamValue( team )
{
	if ( typeof team == "string" )
		team = team.tointeger()

	return team
}

function GetGruntModel( team, captain = false )
{
	local prob = RandomFloat( 0, 1 )

	if ( team == TEAM_IMC )
	{
		if ( captain )
			return TEAM_IMC_CAPTAIN_MDL

		if ( prob < 0.3  )
			return TEAM_IMC_ROCKET_GRUNT_MDL
		else
			return TEAM_IMC_GRUNT_MDL
	}
	else
	{
		if ( captain )
			return TEAM_MILITIA_CAPTAIN_MDL

		if ( prob < 0.3  )
			return TEAM_MILITIA_ROCKET_GRUNT_MDL
		else
			return TEAM_MILITIA_GRUNT_MDL
	}
}

function GetGruntWeapon( team )
{
	if ( team == TEAM_IMC )
	{
		//imc has r101
		return "mp_weapon_rspn101"
	}
	else
	{
		//militia have hemloks --> do we need to change this comment? 'cause this isn't a hemlock
		return "mp_weapon_rspn101"
	}
}

function GetWeaponModel( weapon )
{
	switch( weapon )
	{
		case "mp_weapon_rspn101":
			return "models/weapons/rspn101/r101_ab_01.mdl"//"models/weapons/rspn101/w_rspn101.mdl" --> this is the one I want to spawn, but I get a vague code error when I try
			break

		default:
			Assert( 0, "weapon: " + weapon + " not handled to return a model" )
			break
	}
}

function SpawnGruntLight( team, squadName, origin, angles, alert = true, weapon = null )
{
	local soldier = SpawnGrunt( team, squadName, origin, angles, alert, weapon )
	local model

	if ( typeof team == "string" )
		team = team.tointeger()

	if ( team == TEAM_IMC )
		model = TEAM_IMC_GRUNT_MDL
	else
	{
		if ( RandomFloat( 0, 1 ) < 0.3  )
			model = TEAM_MILITIA_ROCKET_DRONE_MDL
		else
			model = TEAM_MILITIA_DRONE_MDL
	}

	soldier.SetModel( model )
	soldier.SetEfficientMode( true )
	HideName( soldier )

	//thread DebugDroneCount( soldier )

	return soldier
}

function SetupSoldierForRPGs( soldier, team )
{
	// each AI is 0 1 or 2.
	level.teamTrackRPGUsage[ team ]++
	level.teamTrackRPGUsage[ team ] %= 3

	soldier.s.useRPGPreference <- level.teamTrackRPGUsage[ team ]

	soldier.SetEnemyChangeCallback( "EnemyChanged_Rocket" )
}


function OnSoldierSeeEnemy( guy, enemy, _, _ )
{
	TrySpottedCallout( guy, enemy )
}

function OnSpectreSeeEnemy( guy, enemy, _, _ )
{
	TrySpottedCallout( guy, enemy )
}

//////////////////////////////////////////////////////////
function IsValidRocketTarget( enemy )
{
	if ( enemy.IsTitan() )
		return true

	if ( enemy.IsNPC() )
	{
		if ( enemy.GetAIClass() == "vehicle" || enemy.IsTurret() )
			return true
	}

	return false
}

//////////////////////////////////////////////////////////
function DisableRockets( soldier )
{
	soldier.SetEnemyChangeCallback( "EnemyChanged_Standard" )
}


//////////////////////////////////////////////////////////
function UpdateAILethality( soldier, enemy )
{
	local accuracyMultiplier = soldier.IsSpectre() ? AI_SPECTRE_ACCURACY : AI_SOLDIER_ACCURACY
	local weaponProficiency = soldier.IsSpectre() ? AI_SPECTRE_PROFICIENCY : AI_SOLDIER_PROFICIENCY
	local accuracyMultiplierSniper = 100
	local weaponProficiencySniper = 2

	if ( enemy && enemy.IsPlayer() && !enemy.IsTitan() )
	{
		if ( Riff_AILethality() != eAILethality.Default )
		{
			switch ( Riff_AILethality() )
			{
				case eAILethality.TD_Low:
					accuracyMultiplier = 0.75
					weaponProficiency = 2
					accuracyMultiplierSniper = 500
					weaponProficiencySniper = 4
					break
				case eAILethality.TD_Medium:
					accuracyMultiplier = 1.0
					weaponProficiency = 2
					accuracyMultiplierSniper = 1000
					weaponProficiencySniper = 1000
					break
				case eAILethality.TD_High:
				case eAILethality.High:
					accuracyMultiplier = 1.0
					weaponProficiency = 3
					accuracyMultiplierSniper = 1000
					weaponProficiencySniper = 1000
					break
				case eAILethality.VeryHigh:
					accuracyMultiplier = 4.0
					weaponProficiency = 4
					accuracyMultiplierSniper = 1000
					weaponProficiencySniper = 1000
					break
			}
		}
	}

	//especially accurate snipers for coop tower defense
	local activeWeapon = soldier.GetActiveWeapon()
	if ( activeWeapon == null )
		return

	local activeWeaponClassname = activeWeapon.GetClassname()
	if ( activeWeaponClassname == "mp_weapon_dmr" || activeWeaponClassname == "mp_weapon_defender" )
	{
		accuracyMultiplier = accuracyMultiplierSniper
		weaponProficiency = weaponProficiencySniper
	}

	soldier.kv.AccuracyMultiplier = accuracyMultiplier
	soldier.kv.WeaponProficiency = weaponProficiency
}
Globalize( UpdateAILethality )

//////////////////////////////////////////////////////////
function EnemyChanged_Standard( soldier )
{
	UpdateAILethality( soldier, soldier.GetEnemy() )
}

function EnemyChanged_Rocket( soldier )
{
	if ( EnemyChangedSwitchWeapon( soldier ) )
		UpdateAILethality( soldier, null ) // standard accuracy when using rockets
	else
		UpdateAILethality( soldier, soldier.GetEnemy() )
}

//////////////////////////////////////////////////////////
function EnemyChangedSwitchWeapon( soldier )
{
	local atWeapon
	if ( GameRules.GetGameMode() == COOPERATIVE )
	{
		if ( "atWeapon" in soldier.s )
		{
			atWeapon = soldier.s.atWeapon
		}
		else
		{
			atWeapon = GetRandomKeyFromWeightedTable( COOP_AT_WEAPON_RATES, 1.0 )
			soldier.s.atWeapon <- atWeapon
		}
	}
	else
		atWeapon = "mp_weapon_rocket_launcher"
	local startWeapon = soldier.kv.additionalequipment

	local useATWeapon = false
	local enemy = soldier.GetEnemy()

	local currentWeapon = soldier.GetActiveWeapon()
	if ( currentWeapon )
		currentWeapon = currentWeapon.GetClassname()

	if ( IsAlive( enemy ) && IsValidRocketTarget( enemy ) )
	{
		switch ( soldier.s.useRPGPreference )
		{
			case RPG_USE_ALWAYS:
				useATWeapon = true
				break

			case RPG_USE_RARE:
				// uses rockets if his team is down more 4 or more titans
				local team = soldier.GetTeam()
				if ( CompareTitanTeamCount( team ) <= -4 )
					useATWeapon = true
				break

			case RPG_USE_SOMETIMES:
				// uses rockets if his team is down more 2 or more titans
				local team = soldier.GetTeam()
				if ( CompareTitanTeamCount( team ) <= -2 )
					useATWeapon = true
				break
		}
	}

	if ( ( useATWeapon ) && ( currentWeapon != atWeapon ) )
	{
		if ( atWeapon == "mp_weapon_rocket_launcher" )
			soldier.kv.delayFirstShot = true
		else
			soldier.kv.delayFirstShot = false
		soldier.TakeActiveWeapon()
		soldier.GiveWeapon( atWeapon )
		if ( atWeapon == "mp_weapon_rocket_launcher" )
			GiveLaserSight( soldier )

		//printl( "thread give laser sight to ai " + soldier.entindex() )
		//thread TurnOnLaserSightForRocketLauncher( soldier )
	}
	else if ( !( useATWeapon ) && ( currentWeapon != startWeapon ) )
	{
		soldier.kv.delayFirstShot = false
		soldier.TakeActiveWeapon()
		soldier.GiveWeapon( startWeapon )
	}

	return useATWeapon
}

//////////////////////////////////////////////////////////
function TrySpottedCallout( guy, enemy )
{
	if ( !IsAlive( guy ) )
		return

	if ( !IsAlive( enemy ) )
		return

	if ( enemy.IsTitan() )
	{
		if ( guy.IsSpectre() ) //Spectre callouts
		{
			if ( Distance( guy.GetOrigin(), enemy.GetOrigin() ) < 1000 )
				PlaySpectreChatterToAll( "spectre_gs_spotclosetitancall_01", guy )
			else
				PlaySpectreChatterToAll( "spectre_gs_spotfartitan_1_1", guy )
		}
		else //Grunt callouts
		{
			if ( Distance( guy.GetOrigin(), enemy.GetOrigin() ) < 1000 )
				PlaySquadConversationToAll( "aichat_spot_titan_close", guy )
			else
				PlaySquadConversationToAll( "aichat_callout_titan", guy )
		}

		SetSpottedToTeam( enemy, guy.GetTeam(), 2.0 )
	}
	else if ( enemy.IsPlayer() )
	{
		if ( guy.IsSpectre() ) //Spectre callouts
		{
			if ( Distance( guy.GetOrigin(), enemy.GetOrigin() ) < 1000 )
				PlaySpectreChatterToAll( "spectre_gs_engagepilotenemy_01_1", guy )
			else
				PlaySpectreChatterToAll( "spectre_gs_spotenemypilot_01_1", guy )

		}
		else //Grunt callouts
		{
			if ( Distance( guy.GetOrigin(), enemy.GetOrigin() ) < 1000 )
			{
				PlaySquadConversationToAll( "aichat_engage_pilot", guy )
			}
			else
			{
				if ( CoinFlip() )
					PlaySquadConversationToAll( "aichat_callout_pilot_call_response", guy )
				else
					PlaySquadConversationToAll( "aichat_callout_pilot", guy )
			}
		}
		SetSpottedToTeam( enemy, guy.GetTeam(), 2.0 )
	}
}

function SetSpottedToTeam( entity, team, duration )
{
	local players = GetPlayerArray()

	//Minimap_CreatePingForTeam( team, entity.GetOrigin(), "vgui/HUD/firingPing", 0.25 )
	//Minimap_CreatePingForTeam( team, entity.GetOrigin(), "vgui/HUD/firingPing", 1.5 )
	//Minimap_CreatePingForTeam( team, entity.GetOrigin(), "vgui/HUD/firingPing", 2.75 )

	foreach ( player in players )
	{
		if ( player.GetTeam() != team )
			continue

		entity.SpottedToPlayer( player, duration )
	}
}
Globalize( SetSpottedToTeam )

//////////////////////////////////////////////////////////
// HasLaserSight should handle rare case of this thread running multiple times on npc
function TurnOnLaserSightForRocketLauncher( soldier )
{
	soldier.EndSignal( "OnDeath" )
	soldier.WaitSignal( "OnGiveWeapon" )

	local weapon = soldier.GetActiveWeapon()
	if ( weapon && weapon.GetClassname() == "mp_weapon_rocket_launcher" )
	{
		GiveLaserSight( soldier )  // auto cleans up on death or when weapon is taken
		//printl( "give laser sight to ai " + soldier.entindex() )
	}
}


function Spawn_GruntSquad( team, count, spawnOrigin, spawnAngles, squadName = null, force = false, spawnFunc = null )
{
	if ( spawnFunc == null )
		spawnFunc = SpawnGrunt

	return CreateNPCSForDroppod( team, count, spawnOrigin, spawnAngles, squadName, force, spawnFunc )
}

function Spawn_SpectreSquad( team, count, spawnOrigin, spawnAngles, squadName = null, force = false, spawnFunc = null )
{
	if ( spawnFunc == null )
		spawnFunc = SpawnSpectre

	return CreateNPCSForDroppod( team, count, spawnOrigin, spawnAngles, squadName, force, spawnFunc )
}

//this function allows you to pass a single spawnFunc or an array. That way you can spawn different kinds of AI in the same vehicle
function NPCSpawnFuncWrapper( count, index, spawnFunc, team, squadName, origin, angles )
{
	if ( type( spawnFunc ) == "array" )
		return __SpawnFuncArrayWrapper( count, index, spawnFunc, team, squadName, origin, angles )
	else
		return __SpawnFuncWrapper( count, index, spawnFunc, team, squadName, origin, angles )
}
Globalize( NPCSpawnFuncWrapper )


function __SpawnFuncWrapper( count, index, spawnFunc, team, squadName, origin, angles )
{
	Assert( type( spawnFunc ) == "function" )
	local guy

	if ( ShouldSpawnCaptain( count, index, spawnFunc ) )
		guy = SpawnGruntCaptain( team, squadName, origin, angles )
	else
		guy = spawnFunc( team, squadName, origin, angles )

	return guy
}

function __SpawnFuncArrayWrapper( count, index, spawnFuncArray, team, squadName, origin, angles )
{
	Assert( type( spawnFuncArray ) == "array" )
	Assert( index in spawnFuncArray )
	local spawnFunc = spawnFuncArray[ index ]

	return __SpawnFuncWrapper( count, index, spawnFunc, team, squadName, origin, angles )
}


function ShouldSpawnCaptain( count, index, spawnFunc )
{
	if ( spawnFunc != SpawnGrunt )
		return false

	if ( count < 4 )
		return false

	if ( index != 3 )
		return false

	if ( RandomFloat( 0,1 ) >= CAPTAIN_NAME_FREQUENCY )
		return false

	return true
}
Globalize( ShouldSpawnCaptain )


//a unified function for spawning npc's in the droppod ( like the dropship has )
function CreateNPCSForDroppod( team, count, spawnOrigin, spawnAngles, squadName, force, spawnFunc )
{
	if ( !IsNPCSpawningEnabled( team ) && !force )
		return []

	local soldierEntities = []

	if ( !squadName )
		squadName = GetFreeSquadName( team )

	for ( local idx = 0; idx < count; idx++ )
	{
		local ent = NPCSpawnFuncWrapper( count, idx, spawnFunc, team, squadName, spawnOrigin, spawnAngles )
		if ( !ent )
			continue

		soldierEntities.append( ent )

		ent.Anim_ScriptedPlay( "pt_dp_idle_a" )
		ent.MakeInvisible()
		local weapon = ent.GetActiveWeapon()
		if ( IsValid( weapon ) )
			weapon.MakeInvisible()
		wait 0
	}

	// because of wait 0 above, entities could die before returning
	local finalSoldiers = []
	foreach ( soldier in soldierEntities )
	{
		if ( IsAlive( soldier ) )
			finalSoldiers.append( soldier )
	}

	return finalSoldiers
}
Globalize( CreateNPCSForDroppod )
//////////////////////////////////////////////////////////
function SpawnGrunts( dropPod, team, squadName, spawnFunc )
{
	local spawnOrigin = dropPod.GetOrigin()
	local spawnAngles = dropPod.GetAngles()

	local soldierEntities = []

	local orgs = []
	local forwards = []
	FillEntitySpawnPositions( spawnOrigin, spawnAngles, "npc_soldier", orgs, forwards )

	local numNPCs = 4
	if ( spawnFunc == SpawnSpectre )
		numNPCs = 3

	for ( local idx = 0; idx < numNPCs && idx < orgs.len(); idx++ )
	{
		local ent = spawnFunc( team, squadName, spawnOrigin, spawnAngles )

		if ( !ent )
			continue

		soldierEntities.append( ent )

		AddTrackRef( ent )

		ent.SetOrigin( orgs[idx] )
		ent.SetVelocity( Vector( 0, 0, 0 ) )
		ent.SetForwardVector( forwards[idx] )
	}

	ActivateFireteamDropPod( dropPod, null, soldierEntities )
	return soldierEntities
}


__uniqueId_team_imc <- 0
__uniqueId_team_militia <- 0

//////////////////////////////////////////////////////////
function GetUniqueTeamId( team )
{
	if ( team == TEAM_IMC )
	{
		return ++__uniqueId_team_imc
	}
	else
	{
		return ++__uniqueId_team_militia
	}
}


//////////////////////////////////////////////////////////
function GetPlayerSpectreSquadName( player )
{
	return "player" + player.entindex() + "spectreSquad"
}


//////////////////////////////////////////////////////////
function SpawnSpectre( team, squadName, origin, angles, alert = true, weapon = null, hidden = false )
{
	team = GetProperTeamValue( team )

	local model
	local alertVal = alert ? 1 : 0

	if ( team == TEAM_IMC )
	{
		if ( weapon == null )
			weapon = "mp_weapon_r97"
		model = IMC_SPECTRE_MODEL
	}
	else if ( team == TEAM_MILITIA )
	{
		if ( weapon == null )
			weapon = "mp_weapon_r97" //both teams have r97 for now
		model = MILITIA_SPECTRE_MODEL
	}
	else	//Neutral team zero - "TEAM_UNASSIGNED"
	{
		if ( weapon == null )
			weapon = "mp_weapon_r97" //both teams have r97 for now
		model = NEUTRAL_SPECTRE_MODEL
	}

	local spectre = CreateEntity( "npc_spectre" )
	spectre.kv.spawnflags = 131072 | 512 | 4 // don't drop grenade, fall to ground, fade corpse
	spectre.kv.AccuracyMultiplier = AI_SPECTRE_ACCURACY
	spectre.kv.alwaysalert = alertVal
	spectre.kv.reactChance = 0
	spectre.kv.reactFriendlyChance = 0
	spectre.kv.physdamagescale = 1.0
	spectre.kv.WeaponProficiency = AI_SPECTRE_PROFICIENCY
	spectre.kv.NumGrenades = 0
	spectre.kv.teamnumber = team
	spectre.kv.additionalequipment = weapon

	spectre.SetModel( model )
	spectre.SetOrigin( origin )
	spectre.SetAngles( angles )
	spectre.kv.squadname = squadName

	if ( hidden )
		spectre.Hide()	//may want to hide before spawning to avoid pop in scripted model swaps

	DispatchSpawn( spectre, true )

	spectre.ConnectOutput( "OnGainEnemyLOS", OnSpectreSeeEnemy )

	return spectre
}

//////////////////////////////////////////////////////////
function SpectreEyeGlow( spectre )
{
	return
	//printl( "eye glow" )
	local env_sprite = CreateEntity( "env_sprite" )
	env_sprite.SetOrigin( spectre.GetOrigin() )
//	titan.GetAttachmentOrigin( titan.LookupAttachment( "CAMERA_EYE" ) )
//	titan.s.laserScanAttachPoint <- "CAMERA_EYE"
	env_sprite.SetParent( spectre, "EYEGLOW" )
	env_sprite.kv.rendermode = 9 //World glow, uses proxy size for visibility
	env_sprite.kv.rendercolor = "233 67 67 255"  //red
	env_sprite.kv.rendercolorFriendly = "67 87 233 255"	// blue
	env_sprite.SetTeam( spectre.GetTeam() )			// must set TEAM
	env_sprite.kv.model = "sprites/glow_05.vmt"
	env_sprite.kv.scale = "0.04"
	env_sprite.kv.GlowProxySize = 1.0
	env_sprite.kv.HDRColorScale = 15.0
	DispatchSpawn( env_sprite, false )
	spectre.s.eye_glow <- env_sprite

	spectre.EndSignal( "OnDestroy" )
	spectre.WaitSignal( "OnDeath" )
	spectre.s.eye_glow.Kill()
}


//////////////////////////////////////////////////////////
function SpectreFollow( spectre, player )
{
	spectre.SetShortTitle( "" )
	spectre.SetBossPlayer( player )
	//spectre.SetTitle( "Spectre" )

	spectre.InitFollowBehavior( player, AIF_FIRETEAM )
	spectre.EnableBehavior( "Follow" )
}


//////////////////////////////////////////////////////////
function disable_npcs()
{
	FlagSet( "disable_npcs" )
	printl( "disabling_npcs" )
	local guys = GetNPCArray()
	foreach ( guy in guys )
	{
		if ( guy.GetClassname() == "npc_turret_mega" )
			continue
		if ( guy.GetClassname() == "npc_turret_mega_bb" )
			continue
		if ( guy.GetClassname() == "npc_turret_sentry" )
			continue
		if ( guy.GetClassname() == "npc_titan" )
			continue

		guy.Kill()
	}
}


function ResetNPCs()
{
	local guys = GetNPCArray()
	foreach ( guy in guys )
	{
		if ( guy.GetClassname() == "npc_turret_mega" )
			continue
		if ( guy.GetClassname() == "npc_turret_mega_bb" )
			continue
		if ( guy.GetClassname() == "npc_turret_sentry" )
			continue

		if ( guy.GetClassname() == "npc_titan" && IsValid( guy.GetTitanSoul() ) )
		{
			guy.GetTitanSoul().Destroy()
		}

		guy.Destroy()
	}
}

//////////////////////////////////////////////////////////
function Disable_IMC()
{
	FlagSet( "Disable_IMC" )
	printl( "Disable_IMC" )
	local guys = GetNPCArray()
	foreach ( guy in guys )
		if ( guy.GetTeam() == TEAM_IMC )
			guy.Kill()
}


//////////////////////////////////////////////////////////
function Disable_MILITIA()
{
	FlagSet( "Disable_MILITIA" )
	printl( "Disable_MILITIA" )
	local guys = GetNPCArray()
	foreach ( guy in guys )
		if ( guy.GetTeam() == TEAM_MILITIA )
			guy.Kill()
}

function Disable_SPECTRE()
{

}

//////////////////////////////////////////////////////////
function IsNPCSpawningEnabled( team = null )
{
	if( GAMETYPE ==  DEVTEST)
		return false

	if ( Riff_AllowNPCs() != eAllowNPCs.Default )
	{
		if ( Riff_AllowNPCs() == eAllowNPCs.None )
			return false

		return true
	}

	if ( Flag( "disable_npcs" ) )
		return false
	if ( team == TEAM_MILITIA && Flag( "Disable_MILITIA" ) )
		return false
	if ( team == TEAM_IMC && Flag( "Disable_IMC" ) )
		return false

	return true
}

//////////////////////////////////////////////////////////
function ShouldSpawnSpectre( team )
{
	if ( Riff_AllowNPCs() != eAllowNPCs.Default )
	{
		return (Riff_AllowNPCs() == eAllowNPCs.SpectreOnly)
	}

	if ( ( team == TEAM_IMC ) && ( Flag( "AllSpectreIMC" ) ) )
		return true

	if ( ( team == TEAM_MILITIA ) && ( Flag( "AllSpectreMilitia" ) ) )
		return true

	if ( ( team == TEAM_IMC ) && ( Flag( "NoSpectreIMC" ) ) )
		return false

	if ( ( team == TEAM_MILITIA ) && ( Flag( "NoSpectreMilitia" ) ) )
		return false

	if ( GetCurrentPlaylistVarInt( "no_spectres", 0 ) )
		return false

	if ( ( Flag( "AllSpectre" ) ) )
		return true

	switch ( level.spectreSpawnStyle )
	{
		case eSpectreSpawnStyle.MORE_FOR_ENEMY_TITANS:
			local enemyTeam = GetOtherTeam(team)
			local titanCount = GetTitanCount( enemyTeam )
			local spectreCount = GetSpectreCount( team )

		//	local desiredSpectreCount = GraphCapped( titanCount, 1, 4, -3.0, 9.0 )
			local desiredSpectreCount = GraphCapped( titanCount, 1, 5, -2.0, 10.0 )

			return spectreCount < desiredSpectreCount

		case eSpectreSpawnStyle.MAP_PROGRESSION:

			local spectreCount = GetSpectreCount( team )

			local progress = GetMatchProgress()
			if ( progress < 25 )
				return spectreCount <= 0

			local maxAI = GetMaxAICount( team )
			if ( progress < 50 )
				return spectreCount <= 5

			local maxSpectres = max( maxAI * 0.3, 5 )
			return spectreCount <= maxSpectres
	}

	Assert( 0, "What?" )
}

//////////////////////////////////////////////////////////
function UpdateEnemyMemoryDumpAndIncreaseMaxEnemyDist( guy )
{
	UpdateEnemyMemoryFromTeammates( guy )
	guy.kv.maxEnemyDist = 16000
}

function GuyPathfindingFailsafe( guy )
{
	local hull
	if ( guy.IsTitan() )
	{
		hull = HULL_TITAN
	}
	else
	{
		hull = HULL_HUMAN
	}

	local nearestNode = GetNearestNodeToPos( guy.GetOrigin() )
	local neighborNodes = GetNeighborNodes( nearestNode, 3, hull )
	local index = Random( neighborNodes )

	if ( index == null || index < 0 )
	{
		guy.Kill()
		return
	}

	local origin = GetNodePos( index, hull )
	guy.AssaultPoint( origin )
	guy.EndSignal( "OnDeath" )

	thread GuyTeleportsOnPathFail( guy, origin )

	wait 0.5
	guy.DisableBehavior( "Assault" )
}

function GuyTeleportsOnPathFail( guy, origin )
{
	guy.EndSignal( "OnFailedToPath" )

	local e = {}
	e.waited <- false
	OnThreadEnd(
		function() : ( guy, origin, e )
		{
			if ( !IsAlive( guy ) )
				return

			// wait was cut off
			if ( !e.waited )
				guy.SetOrigin( origin )
		}
	)

	wait 2
	e.waited = true
}

function CreateStrictAssaultEnt( origin, angles = null, radius = STANDARDGOALRADIUS )
{
	local assaultnode = CreateEntity( "assault_assaultpoint" )
	assaultnode.kv.assaulttimeout 	= 3.0
	assaultnode.kv.assaulttolerance = 0
	assaultnode.kv.arrivaltolerance = radius
	assaultnode.kv.allowdiversion	= 0
	assaultnode.kv.strict			= 1
	assaultnode.kv.nevertimeout		= 1

	if ( angles )
	{
		assaultnode.kv.faceAssaultPointAngles = 1
		assaultnode.SetAngles( angles )
	}

	assaultnode.SetOrigin( origin )
	DispatchSpawn( assaultnode )

	return assaultnode
}

function CreateAssaultEnt( origin, angles = null, radius = STANDARDGOALRADIUS )
{
	local assaultnode = CreateEntity( "assault_assaultpoint" )
	assaultnode.kv.assaulttimeout 	= 3.0
	assaultnode.kv.assaulttolerance = radius
	assaultnode.kv.arrivaltolerance = radius
	assaultnode.kv.allowdiversion	= 1
	assaultnode.kv.strict			= 0
	assaultnode.kv.nevertimeout		= 1

	if ( angles )
	{
		assaultnode.kv.faceAssaultPointAngles = 1
		assaultnode.SetAngles( angles )
	}

	assaultnode.SetOrigin( origin )
	DispatchSpawn( assaultnode )

	return assaultnode
}

function SquadGotoOrigin( group, origin, radius = STANDARDGOALRADIUS )
{
	foreach( member in group )
		thread GotoOrigin( member, origin, radius )
}

function SquadAssaultOrigin( group, origin, radius = STANDARDGOALRADIUS )
{
	foreach( member in group )
		thread AssaultOrigin( member, origin, radius )
}

function GotoOrigin( guy, origin, radius = STANDARDGOALRADIUS )
{
	waitthread SendAIToAssaultPoint( guy, origin, null, radius, CreateStrictAssaultEnt )
}

function AssaultOrigin( guy, origin, radius = STANDARDGOALRADIUS )
{
	waitthread SendAIToAssaultPoint( guy, origin, null, radius, CreateAssaultEnt )
}

function SendAIToAssaultPoint( guy, origin, angles, radius = STANDARDGOALRADIUS, creatAssaultPointFunc = CreateStrictAssaultEnt )
{
	Assert( IsAlive( guy ) )
	guy.Anim_Stop() // in case we were doing an anim already
	guy.EndSignal( "OnDeath" )

	local allowFlee = guy.GetAllowFlee()
	local allowHandSignal = guy.GetAllowHandSignals()

	guy.AllowFlee( false )
	guy.AllowHandSignals( false )

	local assaultEnt = creatAssaultPointFunc( origin, angles, radius )

	OnThreadEnd(
		function() : ( assaultEnt )
		{
			assaultEnt.Kill()
		}
	)

	guy.AssaultPointEnt( assaultEnt )
	//thread DebugAssaultEnt( guy, assaultEnt )
	guy.WaitSignal( "OnFinishedAssault" )

	guy.AllowFlee( allowFlee )
	guy.AllowHandSignals( allowHandSignal )
}
Globalize( SendAIToAssaultPoint )

function GetCaptainName()
{
	level.captainNamesIndex++
	if ( level.captainNamesIndex >= level.captainNames.len() )
		level.captainNamesIndex = 0

	return level.captainNames[ level.captainNamesIndex ]
}

function InitCaptainNames()
{
	level.captainNames <- [
		"#NPC_CUSTOM_CAPTAIN_0",
		"#NPC_CUSTOM_CAPTAIN_1",
		"#NPC_CUSTOM_CAPTAIN_2",
		"#NPC_CUSTOM_CAPTAIN_3",
		"#NPC_CUSTOM_CAPTAIN_4",
		"#NPC_CUSTOM_CAPTAIN_5",
		"#NPC_CUSTOM_CAPTAIN_6",
		"#NPC_CUSTOM_CAPTAIN_7",
		"#NPC_CUSTOM_CAPTAIN_8",
		"#NPC_CUSTOM_CAPTAIN_9",
		"#NPC_CUSTOM_CAPTAIN_10",
		"#NPC_CUSTOM_CAPTAIN_11",
		"#NPC_CUSTOM_CAPTAIN_12",
		"#NPC_CUSTOM_CAPTAIN_13",
		"#NPC_CUSTOM_CAPTAIN_14",
		"#NPC_CUSTOM_CAPTAIN_15",
		"#NPC_CUSTOM_CAPTAIN_16",
		"#NPC_CUSTOM_CAPTAIN_17",
		"#NPC_CUSTOM_CAPTAIN_18",
		"#NPC_CUSTOM_CAPTAIN_19",
		"#NPC_CUSTOM_CAPTAIN_20",
		"#NPC_CUSTOM_CAPTAIN_21",
		"#NPC_CUSTOM_CAPTAIN_22",
		"#NPC_CUSTOM_CAPTAIN_23",
		"#NPC_CUSTOM_CAPTAIN_24",
		"#NPC_CUSTOM_CAPTAIN_25",
		"#NPC_CUSTOM_CAPTAIN_26",
		"#NPC_CUSTOM_CAPTAIN_27",
		"#NPC_CUSTOM_CAPTAIN_28",
		"#NPC_CUSTOM_CAPTAIN_29",
		"#NPC_CUSTOM_CAPTAIN_30",
		"#NPC_CUSTOM_CAPTAIN_31",
		"#NPC_CUSTOM_CAPTAIN_32",
		"#NPC_CUSTOM_CAPTAIN_33",
		"#NPC_CUSTOM_CAPTAIN_34",
		"#NPC_CUSTOM_CAPTAIN_35",
		"#NPC_CUSTOM_CAPTAIN_36",
		"#NPC_CUSTOM_CAPTAIN_37",
		"#NPC_CUSTOM_CAPTAIN_38",
		"#NPC_CUSTOM_CAPTAIN_39",
		"#NPC_CUSTOM_CAPTAIN_40",
		"#NPC_CUSTOM_CAPTAIN_41",
		"#NPC_CUSTOM_CAPTAIN_42",
		"#NPC_CUSTOM_CAPTAIN_43",
		"#NPC_CUSTOM_CAPTAIN_44",
		"#NPC_CUSTOM_CAPTAIN_45",
		"#NPC_CUSTOM_CAPTAIN_46",
		"#NPC_CUSTOM_CAPTAIN_47",
		"#NPC_CUSTOM_CAPTAIN_48",
		"#NPC_CUSTOM_CAPTAIN_49",
		"#NPC_CUSTOM_CAPTAIN_50",
		"#NPC_CUSTOM_CAPTAIN_51",
		"#NPC_CUSTOM_CAPTAIN_52",
		"#NPC_CUSTOM_CAPTAIN_53",
		"#NPC_CUSTOM_CAPTAIN_54",
		"#NPC_CUSTOM_CAPTAIN_55",
		"#NPC_CUSTOM_CAPTAIN_56",
		"#NPC_CUSTOM_CAPTAIN_57",
		"#NPC_CUSTOM_CAPTAIN_58",
		"#NPC_CUSTOM_CAPTAIN_59",
		"#NPC_CUSTOM_CAPTAIN_60",
		"#NPC_CUSTOM_CAPTAIN_61",
		"#NPC_CUSTOM_CAPTAIN_62",
		"#NPC_CUSTOM_CAPTAIN_63",
		"#NPC_CUSTOM_CAPTAIN_64",
		"#NPC_CUSTOM_CAPTAIN_65",
		"#NPC_CUSTOM_CAPTAIN_66",
		"#NPC_CUSTOM_CAPTAIN_67",
		"#NPC_CUSTOM_CAPTAIN_68",
		"#NPC_CUSTOM_CAPTAIN_69",
		"#NPC_CUSTOM_CAPTAIN_70",
		"#NPC_CUSTOM_CAPTAIN_71",
		"#NPC_CUSTOM_CAPTAIN_72",
		"#NPC_CUSTOM_CAPTAIN_73",
		"#NPC_CUSTOM_CAPTAIN_74",
		"#NPC_CUSTOM_CAPTAIN_75",
		"#NPC_CUSTOM_CAPTAIN_76",
		"#NPC_CUSTOM_CAPTAIN_77",
		"#NPC_CUSTOM_CAPTAIN_78",
		"#NPC_CUSTOM_CAPTAIN_79",
		"#NPC_CUSTOM_CAPTAIN_80",
		"#NPC_CUSTOM_CAPTAIN_81",
		"#NPC_CUSTOM_CAPTAIN_82",
		"#NPC_CUSTOM_CAPTAIN_83",
		"#NPC_CUSTOM_CAPTAIN_84",
		"#NPC_CUSTOM_CAPTAIN_85",
		"#NPC_CUSTOM_CAPTAIN_86",
		"#NPC_CUSTOM_CAPTAIN_87",
		"#NPC_CUSTOM_CAPTAIN_88",
		"#NPC_CUSTOM_CAPTAIN_89",
		"#NPC_CUSTOM_CAPTAIN_90",
		"#NPC_CUSTOM_CAPTAIN_91",
		"#NPC_CUSTOM_CAPTAIN_92",
		"#NPC_CUSTOM_CAPTAIN_93",
		"#NPC_CUSTOM_CAPTAIN_94",
		"#NPC_CUSTOM_CAPTAIN_95"
	]

	ArrayRandomize( level.captainNames )
	level.captainNamesIndex <- 0
}

function SetGlobalNPCHealth( healthValue ) //Debug, for trailer team
{
	local npcArray = GetNPCArray()

	foreach( npc in npcArray )
	{
		npc.SetMaxHealth( healthValue )
		npc.SetHealth( healthValue )
	}
}

function RandomizeMinionWeapon( npc )
{
	if ( IsSuicideSpectre( npc ) )
			return

	local gruntWeapons = [
		"mp_weapon_rspn101",
		"mp_weapon_rspn101",
		"mp_weapon_hemlok",
		"mp_weapon_lmg",
		]
	local spectreWeapons = [
		"mp_weapon_car",
		"mp_weapon_r97",
		]

	local weapon
	if ( npc.IsSpectre() )
		weapon = Random( spectreWeapons )
	else
		weapon = Random( gruntWeapons )

	GiveMinionWeapon( npc, weapon )
}
Globalize( RandomizeMinionWeapon )

function GiveMinionWeapon( npc, weapon )
{
	npc.kv.additionalequipment = weapon
	npc.TakeActiveWeapon()
	npc.GiveWeapon( weapon )
}
Globalize( GiveMinionWeapon )

// Somewhat hacky way to get AI to throw grenades. Good enough for now.
function SimulateGrenadeThrowing( npc )
{
	thread SimulateGrenadeThink( npc )
}
Globalize( SimulateGrenadeThrowing )

function SimulateGrenadeThink(npc) {
	npc.EndSignal("OnDestroy")
	npc.EndSignal("OnDeath")
	npc.EndSignal("Stop_SimulateGrenadeThink")

	OnThreadEnd(
		function(): (npc) {
			if (IsAlive(npc))
				DeleteAnimEvent(npc, "grenade_throw", NPCGrenadeThrow)
		}
	)

	AddAnimEvent(npc, "grenade_throw", NPCGrenadeThrow)

	if (RandomInt(100) < 50)
		npc.GiveOffhandWeapon("mp_weapon_frag_grenade", 0)
	else
		npc.GiveOffhandWeapon("mp_weapon_grenade_emp", 0)

	local npcRadius = 2000
	local npcRadiusSqr = npcRadius * npcRadius

	for (;;) {
		wait RandomFloat(4.5, 5.5)

		local npcPos = npc.GetWorldSpaceCenter()
		local grenadeTargets = GetPlayerArray()
		grenadeTargets.extend(GetNPCArrayEx("npc_turret_sentry", GetOtherTeam( npc.GetTeam() ), npcPos, npcRadius))
		foreach(target in grenadeTargets) {
			if (!IsAlive(target))
				continue

			local targetPosition
			if (target.IsPlayer())
				targetPosition = target.EyePosition()
			else
				targetPosition = target.GetWorldSpaceCenter()

			if (DistanceSqr(targetPosition, npcPos) > npcRadiusSqr)
				continue
			//Intent is to use this as a rooftop deterent, not normal combat.
			if (targetPosition.z - npcPos.z < 75)
				continue

			if (npc.IsInterruptable() == false)
				continue

			if (npc.CanSee(target) && npc.GetEnemy() == target) {
				npc.Anim_ScriptedAllowPain(true)
				npc.Anim_ScriptedPlay("coop_grenade_throw")
				npc.WaittillAnimDone()
				npc.Anim_ScriptedAllowPain(false)
				npc.AssaultPointEnt(npc.s.assaultPoint)
				npc.Signal("Stop_SimulateGrenadeThink")
			}
			wait 0
		}
	}
}

function NPCGrenadeThrow(npc) {
	Assert(IsValid(npc))

	local id = npc.LookupAttachment("R_HAND")
	local npcPos = npc.GetAttachmentOrigin(id)
	local weapon = npc.GetOffhandWeapon(0)

	local enemy = npc.GetEnemy()

	if (!IsValid(weapon) || !IsValid(enemy))
		return

	local throwPosition
	if (enemy.IsPlayer())
		throwPosition = enemy.EyePosition()
	else
		throwPosition = enemy.GetWorldSpaceCenter()

	throwPosition += Vector(RandomFloat(-64, 64), RandomFloat(-64, 64), RandomFloat(-32, 32))

	local vel = GetVelocityForDestOverTime(npcPos, throwPosition, 2.0)

	if (weapon.GetClassname() == "mp_weapon_grenade_emp") {
		// magic multipliers to get the EMP grenade to travel the same distance as the frag.
		vel.x *= 2.0
		vel.y *= 2.0
		vel.z *= 1.25
	}
	local frag = weapon.FireWeaponGrenade(npcPos, vel, Vector(0, 0, 0), 3.0, damageTypes.GibBullet | DF_IMPACT | DF_EXPLOSION | DF_SPECTRE_GIB, DF_EXPLOSION | DF_RAGDOLL | DF_SPECTRE_GIB, PROJECTILE_NOT_PREDICTED, false, false)

	frag.SetOwner(npc)
	Grenade_Init(frag, weapon)
	thread TrapExplodeOnDamage(frag, 20, 0.0, 0.0)

	if (npc.IsSpectre())
		EmitSoundOnEntity(npc, SPECTRE_GRENADE_OUT)
	else
		PlaySquadConversationToAll( "aichat_grenade_incoming", npc )
		//EmitSoundOnEntity(npc, GRUNT_GRENADE_OUT)
}
