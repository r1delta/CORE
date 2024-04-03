// _dropship
//
// dropship/passenger setup:
// 1. Create an npc_dropship and target it with a point_template. Give the point_template a name.
// 2. npc_dropship targets starting path_track (see below for path setup info) AND passenger spawning point_template
// 3. passenger spawning point_template points to six passengers that will spawn and rappel at the unload spot
//
// path/unload spot setup:
// 1. create your path out of path_track entities
// 2. to create rappel targets, add six info_targets on the ground around your unload node, name them all the same
// 3. on the node where the dropship will unload, create a key/value pair called "unload" and point it at the name you gave to the rappel target info_targets
//
// spawning in script:
// 1. use GetEnt to get the point_template that targets the dropship
// 2. pass that point_template into DropshipSpawn(), this returns with the dropship ent
// 3. pass the dropship ent into DropshipDropshipFlyPathAndUnload() (thread it off if you want to do stuff right after)
//

const FX_DROPSHIP_THRUSTERS = "xo_atlas_jet_large"
const FX_GUNSHIP_DAMAGE =  "veh_gunship_damage_FULL"
const FX_DROPSHIP_DEATH = "P_veh_exp_crow"

const DROPSHIP_ROPE_ENDPOINT_FX = "runway_light_blue"
const DROPSHIP_ACL_LIGHT_GREEN_FX = "acl_light_green"
const DROPSHIP_ACL_LIGHT_RED_FX = "acl_light_red"
const DROPSHIP_ACL_LIGHT_WHITE_FX = "acl_light_white"
const ENGAGEMENT_DIST = 1024

const DEFAULT_READYANIM_BLENDTIME = 1.0

function main()
{
	Globalize( InitLeanDropship )
	Globalize( SpawnAnimatedDropship )
	Globalize( SpawnAnimatedHeroDropship )
	Globalize( GetDropshipSquadSize )
	Globalize( WarpinEffect )
	Globalize( WarpinEffectFPS )
	Globalize( WarpoutEffect )
	Globalize( WarpoutEffectFPS )
	Globalize( CloudCoverEffect )
	Globalize( WaitForNPCsDeployed )
	Globalize( CreateNPCSForDropship )
	Globalize( CreateDebugSlotsForDropship )
	Globalize( GuyDeploysOffShip )
	Globalize( PlayerPlayFakeRampAnim )
	Globalize( WaittillPlayDeployAnims )
	Globalize( GetDropshipRopeAttachments )
	Globalize( GetTeamDropshipModel )
	Globalize( DelayDropshipDelete )
	Globalize( DefensiveFreePlayers )
	Globalize( CreateDropshipAnimTable )

	if ( IsServer() )
	{
		PrecacheParticleSystem( FX_GUNSHIP_CRASH_EXPLOSION_ENTRANCE )
		PrecacheParticleSystem( FX_GUNSHIP_CRASH_EXPLOSION_EXIT )
		PrecacheParticleSystem( FX_DROPSHIP_DEATH )
		AddDeathCallback( "npc_dropship", OnNPCDropshipDeath )
		AddDamageCallback( "npc_dropship", OnDropshipDamaged )
	}

	PrecacheParticleSystem( FX_HORNET_DEATH )
	PrecacheParticleSystem( FX_GUNSHIP_DAMAGE )
	PrecacheParticleSystem( FX_DROPSHIP_THRUSTERS )
	PrecacheParticleSystem( DROPSHIP_ROPE_ENDPOINT_FX )
	PrecacheParticleSystem( DROPSHIP_ACL_LIGHT_GREEN_FX )
	PrecacheParticleSystem( DROPSHIP_ACL_LIGHT_RED_FX )
	PrecacheParticleSystem( DROPSHIP_ACL_LIGHT_WHITE_FX )

	level.DROPSHIP_DEFAULT_AIRSPEED <- 750

	PrecacheEntity( "keyframe_rope" )
	PrecacheModel( DROPSHIP_MODEL )
	PrecacheModel( DROPSHIP_HERO_MODEL )
	PrecacheModel( CROW_MODEL )
	PrecacheModel( CROW_HERO_MODEL )

	PrecacheSprite( "sprites/laserbeam.vmt" )
	PrecacheSprite( "sprites/glow_05.vmt" )

	ENGAGEMENT_DIST_SQD <- ENGAGEMENT_DIST * ENGAGEMENT_DIST

	//Array of all attachments in the dropship model. Used in DropshipDamageEffects
	local names = []
	names.append( "FRONT_TURRET"      )
	names.append( "BOMB_L"            )
	names.append( "BOMB_R"            )
	names.append( "Spotlight"         )
	names.append( "Light_Red0"        )
	names.append( "Light_Red1"        )
	names.append( "Light_Red2"        )
	names.append( "Light_Red3"        )
	names.append( "HeadlightLeft"     )
	names.append( "RopeAttachLeftA"   )
	names.append( "RopeAttachLeftB"   )
	names.append( "RopeAttachLeftC"   )
	names.append( "L_exhaust_rear_1"  )
	names.append( "L_exhaust_rear_2"  )
	names.append( "L_exhaust_front_1" )
	names.append( "Light_Green0"      )
	names.append( "Light_Green1"      )
	names.append( "Light_Green2"      )
	names.append( "Light_Green3"      )
	names.append( "HeadlightRight"    )
	names.append( "RopeAttachRightA"  )
	names.append( "RopeAttachRightB"  )
	names.append( "RopeAttachRightC"  )
	names.append( "R_exhaust_rear_1"  )
	names.append( "R_exhaust_rear_2"  )
	names.append( "R_exhaust_front_1" )

	file.dropshipAttachments <- names
}

function InitLeanDropship( dropship )
{
	if ( dropship.kv.desiredSpeed.tofloat() <= 0 )
	{
		dropship.kv.desiredSpeed = level.DROPSHIP_DEFAULT_AIRSPEED
	}

	//dropship.s.dropFunc <- Bind( ShipDropsGuys )
}

function CreateNPCSForDropship( ship, spawnFunc, side = "both", count = null )
{
	local animGroupArray = GetAnimGroupAllSeats( side )

	if ( count == null )
		count = animGroupArray.len()
	else
	if ( count >= animGroupArray.len() )
		count = animGroupArray.len()

	local team = ship.GetTeam()
	local squadName = ship.kv.squadname
	local origin = ship.GetOrigin()
	local angles = ship.GetAngles()

	local guys = []
	local guy
	for ( local i = 0; i < count; i++ )
	{
		local guy = NPCSpawnFuncWrapper( count, i, spawnFunc, team, squadName, origin, angles )
		guys.append( guy )

		local seat 	= i
		local table = CreateDropshipAnimTable( ship, side, seat )

		thread GuyDeploysOffShip( guy, table )
	}

	return guys
}

function CreateDebugSlotsForDropship( ship, spawnFunc, side = "both", count = null )
{
	local animGroupArray = GetAnimGroupAllSeats( side )

	if ( count == null )
		count = animGroupArray.len()
	else
	if ( count >= animGroupArray.len() )
		count = animGroupArray.len()

	local team = ship.GetTeam()
	local squadName = "debugSquad" + team
	local origin = ship.GetOrigin()
	local angles = ship.GetAngles()

	local guys = []
	local guy
	for ( local i = 0; i < count; i++ )
	{
		local guy = SpawnGuyForIntroPreview( spawnFunc, team, squadName, origin, angles, i )

		guys.append( guy )

		local seat 	= i
		local sequences = GetAnimGroupSequences( side, i )

		thread DebugDropshipGuyGo( guy, sequences, ship )
	}

	return guys
}

function CreateDropshipAnimTable( ship, side, seat )
{
	local table = {}

	table.idleAnim			<- GetAnimGroup3rd( side, seat, "idle" )
	table.deployAnim		<- GetAnimGroup3rd( side, seat, "deploy" )
	table.readyAnim			<- null

	if ( HasAnimGroupSequence( side, seat, "ready" ) )
		table.readyAnim = GetAnimGroup3rd( side, seat, "ready" )

	table.shipAttach 		<- GetAnimGroupAttachment( side, seat, "deploy" )
	table.attachIndex 		<- null
	table.ship 				<- ship
	table.side				<- side
	table.blendTime			<- DEFAULT_SCRIPTED_ANIMATION_BLEND_TIME

	return table
}

function WaitForNPCsDeployed( npcArray )
{
	local ent = CreateScriptRef()
	ent.s.count <- 0

	OnThreadEnd(
		function() : ( ent )
		{
			if ( IsValid( ent ) )
				ent.Kill()
		}
	)

	local func =
		function( ent, guy )
		{
			ent.s.count++

			WaitSignal( guy, "npc_deployed", "OnDeath", "OnDestroy" )
			ent.s.count--

			if ( !ent.s.count )
				ent.Kill()
		}

	foreach ( guy in npcArray )
	{
		if ( IsAlive( guy ) )
			thread func( ent, guy )
	}

	ent.WaitSignal( "OnDestroy" )
}

function SpawnAnimatedHeroDropship( origin, team, squadname = null, health = null, instamission = null )
{
	local heroVersion = true
	local model = GetTeamDropshipModel( team, heroVersion )

	local dropship =  SpawnAnimatedDropship( origin, team, squadname, health, instamission, model )
	AddCustomCinematicRefFunc( dropship, Bind( CallDropShipIntLighting ) )

	return dropship
}

function CallDropShipIntLighting( player, dropship )
{
	local eHandle = dropship.GetEncodedEHandle()
	Remote.CallFunction_Replay( player, "ServerCallback_CreateDropShipIntLighting", eHandle, player.GetTeam() )
}

function SpawnAnimatedDropship( origin, team, squadname = null, health = null, instamission = null, model = null )
{
	local dropship = CreateEntity( "npc_dropship" )
	dropship.kv.spawnflags = 0
	dropship.kv.vehiclescript = "scripts/vehicles/airvehicle_default.txt"
	dropship.kv.teamnumber = team
	//Use skin where the lights are on for dropship.
	dropship.kv.skin = 1

	//dropship.SetTitle( "Dropship" )
	//dropship.SetShortTitle( "Dropship" )

	if ( model == null )
	 	model = GetTeamDropshipModel( team )

	dropship.SetModel( model )

	dropship.SetOrigin( origin )
	//dropship.SetAngles( path_start.GetAngles() )
	//dropship.kv.target = path_start.GetName()

	if ( squadname == null )
	{
		squadname = UniqueString( "dropship_squad" )
	}

	dropship.kv.squadname = squadname
	//dropship.s.pathname <- path_start.GetName()

	DispatchSpawn( dropship, true )

	local dropship_health = 10000
	if ( health )
		dropship_health = health
	dropship.SetHealth( dropship_health )
	dropship.SetMaxHealth( dropship_health )

	if ( instamission )
		dropship.nv.instamission = instamission

	dropship.EnableRenderAlways()
	dropship.SetAimAssistAllowed( false )

	dropship.kv.CollisionGroup = 21 // COLLISION_GROUP_BLOCK_WEAPONS

	AddAnimEvent( dropship, "dropship_warpout", WarpoutEffect )

	return dropship
}



function Spawn_TeamAnimatedDropship( team, origin )
{
	local dropship = CreateEntity( "npc_dropship" )
	dropship.kv.spawnflags = 0
	dropship.kv.vehiclescript = "scripts/vehicles/airvehicle_default.txt"
	dropship.kv.teamnumber = team
	dropship.kv.desiredSpeed = 2000
	//Use skin where the lights are on for dropship.
	dropship.kv.skin = 1

	local model = GetTeamDropshipModel( team )

	dropship.SetModel( model )
	dropship.SetOrigin( origin )
	dropship.SetHealth( 10000 )
	dropship.SetMaxHealth( 10000 )

	DispatchSpawn( dropship, true )

	//thread DropshipDamageEffects( dropship )

	dropship.EnableRenderAlways()
	dropship.SetAimAssistAllowed( false )

	AddAnimEvent( dropship, "dropship_warpout", WarpoutEffect )

	return dropship
}


function DepolyDropShipSquad( dropShip, soldiers, spawnPoint )
{
	local side = "both"
	local animGroupArray = GetAnimGroupAllSeats( side )

	Assert( soldiers.len() <= animGroupArray.len() )

	foreach ( index, soldier in soldiers )
	{
		local seat 	= index
		local table = CreateDropshipAnimTable( dropShip, side, seat )

		thread GuyDeploysOffShip( soldier, table )
	}

	// why aren't the dropship animations at the proper height for their ref nodes?
	local pathHack = CreateEntity( "path_track" )
	pathHack.SetOrigin( spawnPoint.GetOrigin() + Vector( 0, 0, 300 ) )
	pathHack.SetAngles( spawnPoint.GetAngles() )
	DispatchSpawn( pathHack, true )

	OnThreadEnd(
		function() : ( dropShip, pathHack )
		{
			if ( IsAlive( dropShip ) )
			{
				//wait 2.0
				dropShip.Kill()
			}

			pathHack.Destroy()
		}
	)

	local dropshipAnim = TableRandomIndex( spawnPoint.s.dropShipPathAnims )

	AddSignalAnimEvent( dropShip, "deploy" )

	thread PlayAnimTeleport( dropShip, dropshipAnim, pathHack )

	WaittillPlayDeployAnims( dropship )
	printt( "DEPLOY" )

}
Globalize( DepolyDropShipSquad )
Globalize( Spawn_TeamAnimatedDropship )


function InitDropShipFlightPaths( spawnPoints )
{
	local tempDropShip = CreateEntity( "prop_dynamic" )
	tempDropShip.kv.spawnflags = 0
	tempDropShip.SetModel( DROPSHIP_MODEL )

	DispatchSpawn( tempDropShip, true )

	foreach ( spawnPoint in spawnPoints )
	{
		tempDropShip.SetOrigin( spawnPoint.GetOrigin() )

		spawnPoint.s.dropShipPathAnims <- {}
		spawnPoint.s.dropShipPathAnims[ "gd_goblin_zipline_strafe" ] <- GetDropShipAnimOffset( tempDropShip, "gd_goblin_zipline_strafe", spawnPoint )
		spawnPoint.s.dropShipPathAnims[ "gd_goblin_zipline_dive" ] <- GetDropShipAnimOffset( tempDropShip, "gd_goblin_zipline_dive", spawnPoint )
	}

	tempDropShip.Destroy()
}
Globalize( InitDropShipFlightPaths )


function GetDropShipAnimOffset( dropShip, animName, refEnt )
{
	local animStart = dropShip.Anim_GetStartForRefPoint( animName, refEnt.GetOrigin(), refEnt.GetAngles() )
	return animStart.origin - refEnt.GetOrigin()
}



function GetDropshipSquadSize( squadname )
{
	local squadsize = 0
	local dropships = GetNPCArrayByClass( "npc_dropship" )

	//printl( dropships.len()+ " dropships, checking squadname: " + squadname )
	foreach ( ship in dropships )
		if ( ship.kv.squadname == squadname )
			squadsize++

	//printl( dropships.len()+ " dropships, squadsize: " + squadsize )
	return squadsize
}

function CloudCoverEffect( dropship )
{
	local eHandle = dropship.GetEncodedEHandle()
	local slots = GetSlotsFromRef( dropship )

	foreach ( slot in slots )
	{
		local player = GetPlayerFromSlot( slot )

		if ( player != null && IsPlayer( player ) )
			Remote.CallFunction_Replay( player, "ServerCallback_DropShipCloudCoverEffect", eHandle )
	}

	wait CLOUDCOVERFXTIME
}

function WarpoutEffect( dropship )
{
	if ( !IsValid( dropship ) )
		return

	__WarpOutEffectShared( dropship )

	thread DelayDropshipDelete( dropship )
}

function DelayDropshipDelete( dropship )
{
	dropship.EndSignal( "OnDeath" )

	//very defensive check
	DefensiveFreePlayers( dropship )

	wait 0 // so the dropship wont pop out before it warps out

	dropship.Kill()
}

function DefensiveFreePlayers( dropship )
{
	if( !( "cinematicSlots" in dropship.s ) )
		return

	local players = GetPlayerArrayOfTeam( dropship.GetTeam() )
	foreach ( player in players )
	{
		if ( !IsValid( player ) )
			continue

		if ( player.GetParent() != dropship )
			continue

		if ( HasCinematicFlag( player, CE_FLAG_INTRO) )
			RemoveCinematicFlag( player, CE_FLAG_INTRO )

		if ( "cinematicSlot" in player.s )
			player.s.cinematicSlot = null

		player.EnableWeaponViewModel()
		player.ClearCinematicEventRef()
		PlayerCinematicDone( player )
	}
}

function WarpoutEffectFPS( dropship )
{
	__WarpOutEffectShared( dropship )
}

function WarpinEffect( model, animation, origin, angles, sfx = null )
{
	//we need a temp dropship to get the anim offsets
	local start = GetWarpinPosition( model, animation, origin, angles )

	__WarpInEffectShared( start.origin, start.angles, sfx )
}

function WarpinEffectFPS( ent, animation, origin, angles, sfx = null )
{
	local model = ent.GetModelName()

	//we need a temp dropship to get the anim offsets
	local start = GetWarpinPosition( model, animation, origin, angles )

	__WarpInEffectShared( start.origin, start.angles, sfx )
}

function OnNPCDropshipDeath( dropship, damageInfo )
{
	if ( !IsValid( dropship ) )
		return

	local modelName = dropship.GetModelName()

	switch( modelName )
	{
		case CROW_MODEL:
		case CROW_HERO_MODEL:
		case DROPSHIP_MODEL:
		case DROPSHIP_HERO_MODEL:
		{
			local dropshipOrigin = dropship.GetOrigin()

			PlayFX( "P_veh_exp_crow", dropshipOrigin )

			EmitSoundAtPosition( dropshipOrigin, "Goblin_Dropship_Explode" )
		}

		default:
			return
	}

}

function OnDropshipDamaged( dropship, damageInfo )
{
	local damage = damageInfo.GetDamage()

	//Tried to give visual shield indicator, but it doesn't seem to work?
	//local damageFlags = damageInfo.GetCustomDamageType()
	//damageInfo.SetCustomDamageType( damageFlags | DF_SHIELD_DAMAGE )

	// store the damage so all hits can be tallied
	StoreDamageHistoryAndUpdate( dropship, 120.0, damageInfo.GetDamage(), damageInfo.GetInflictor().GetOrigin(), damageInfo.GetCustomDamageType(), damageInfo.GetDamageSourceIdentifier(), damageInfo.GetAttacker() )

	// this signal is used in _refuel_ships.nut
	dropship.Signal( "OnTakeDamage", { position = damageInfo.GetDamagePosition(), damage = damageInfo.GetDamage() } )

	if ( damageInfo.GetDamage() < 450 )
		return

	local pos = damageInfo.GetDamagePosition()
	PlayFX( FX_GUNSHIP_DAMAGE, pos )
}

function GuyDeploysOffShip( guy, table )
{
	guy.EndSignal( "OnDeath" )
	local ship 			= table.ship
	local shipAttach 	= table.shipAttach

	OnThreadEnd(
		function() : ( guy, ship )
		{
			if ( !IsValid( guy ) )
				return

			if ( ship != null )
			{
				if ( !IsAlive( ship ) && IsAlive( guy ) )
				{
					// try to transfer the last attacker from the ship to the attached guys.
					local attacker = null
					if ( "lastAttacker" in ship.s && IsValid( ship.s.lastAttacker ) )
						attacker = ship.s.lastAttacker

					guy.TakeDamage( 500, attacker, attacker, null )
				}
			}

			if ( !IsAlive( guy ) )
				guy.BecomeRagdoll( Vector(0,0,0) )
			}
	)

	guy.SetEfficientMode( true )
	HideName( guy )

	Assert( shipAttach, "Ship but no shipAttach" )
	ship.EndSignal( "OnDeath" )
	GuyAnimatesRelativeToShipAttachment( guy, table )

	WaittillPlayDeployAnims( ship )

	GuyAnimatesOut( guy, table )
}

function WaittillPlayDeployAnims( ref )
{
	waitthread WaittillPlayDeployAnimsThread( ref )
}

function WaittillPlayDeployAnimsThread( ref )
{
	ref.EndSignal( "OnDeath" )

	ref.WaitSignal( "deploy" )
}

function GuyAnimatesOut( guy, table )
{
	switch( table.side )
	{
		case "ramp":
			waitthread GuyPlayFakeRampAnim( guy, table.shipAttach, table.ship )//-> hack
			break

		case "left":
		case "right":
		case "both":
		case "zipline":
			waitthread GuyZiplinesToGround( guy, table )
			break

		default:
			thread PlayAnim( guy, table.deployAnim, table.ship, table.shipAttach )
			break
	}


	guy.SetEfficientMode( false )
	guy.SetNameVisibleToOwner( true )

	guy.WaittillAnimDone()
	guy.ClearParent()

	UpdateEnemyMemoryDumpAndIncreaseMaxEnemyDist( guy )

	guy.Signal( "npc_deployed" )
}

//HACK
function GuyPlayFakeRampAnim( guy, anim, ref )
{
	switch( anim )
	{
		case "RampAttachB":
			wait 0.05
			break
		case "RampAttachC":
			wait 0.1
			break
		case "RampAttachD":
			wait 0.15
			break
		case "RampAttachE":
			wait 0.2
			break
		case "RampAttachF":
			wait 0.25
			break
	}

	guy.Anim_ScriptedPlay( "stand_2_run_F_v2" )
	guy.WaittillAnimDone()
	guy.ClearParent()

	guy.Anim_ScriptedPlay( "sprint" )

	switch( anim )
	{
		case "RampAttachA":
			wait 0.2
			guy.Anim_ScriptedPlay( "Sprint_turn_90L" )
			guy.Anim_EnablePlanting()
			guy.WaittillAnimDone()
			guy.Anim_ScriptedPlay( "run_2_stand_F" )
			break

		case "RampAttachB":
			wait 0.2
			guy.Anim_ScriptedPlay( "Sprint_turn_90R" )
			guy.Anim_EnablePlanting()
			guy.WaittillAnimDone()
			guy.Anim_ScriptedPlay( "run_2_stand_F" )
			break

		case "RampAttachE":
			wait 0.75
			guy.Anim_ScriptedPlay( "run_2_stand_45L" )
			guy.Anim_EnablePlanting()
			break

		case "RampAttachF":
			wait 0.75
			guy.Anim_ScriptedPlay( "run_2_stand_45R" )
			guy.Anim_EnablePlanting()
			break

		default:
			wait 1.0
			guy.Anim_ScriptedPlay( "run_2_stand_F" )
			guy.Anim_EnablePlanting()
			break
	}
}

//HACK
function PlayerPlayFakeRampAnim( sequence, player, ref )
{
	if ( sequence.viewConeFunction )
		sequence.viewConeFunction( player )

	local team = player.GetTeam()

	local npc = SpawnGrunt( team, "", player.GetOrigin(), player.GetAngles() )
	player.SetParent( npc, "", false, 0.0 )

	npc.SetParent( ref, sequence.attachment, false, 0.0 )
	npc.kv.VisibilityFlags = 6 // visible to everybody but owner
	npc.SetOwner( player )
	HideName( npc )
	MakeInvincible( npc )

	player.Hide()
	player.HolsterWeapon()

	if ( team == TEAM_IMC )
		guy.SetModel( IMC_MALE_BR )
	else
		guy.SetModel( MILITIA_MALE_BR )

	waitthread GuyPlayFakeRampAnim( npc, sequence.attachment, ref )

	npc.WaittillAnimDone()

	player.Show()
	player.ClearParent()
	player.DeployWeapon()
	player.Anim_Stop()
	npc.Kill()
}

function GuyAnimatesRelativeToShipAttachment( guy, table )
{
	table.attachIndex <- table.ship.LookupAttachment( table.shipAttach )
	guy.SetOrigin( table.ship.GetOrigin() )

	guy.SetParent( table.ship, table.shipAttach, false, 0 )

	guy.Anim_ScriptedPlay( table.idleAnim )
}

function GetTeamDropshipModel( team, hero = false )
{
	if ( hero )
	{
		if ( team == TEAM_IMC )
			return DROPSHIP_HERO_MODEL
		else
			return CROW_HERO_MODEL
	}
	else
	{
		if ( team == TEAM_IMC )
			return DROPSHIP_MODEL
		else
			return CROW_MODEL
	}
}

function GetDropshipRopeAttachments( side = "both" )
{
	local attachments = {}

	if ( side = "both" )
	{
		attachments[ "left" ] <- []
		attachments[ "right" ] <- []

		local animGroupArray = GetAnimGroupAllSeats( "left" )
		foreach( seat, table in animGroupArray )
			attachments[ "left" ].append( GetAnimGroupAttachment( "left", seat, "deploy" ) )

		local animGroupArray = GetAnimGroupAllSeats( "right" )
		foreach( seat, table in animGroupArray )
			attachments[ "right" ].append( GetAnimGroupAttachment( "right", seat, "deploy" ) )
	}
	else
	{
		attachments[ side ] <- []
		local animGroupArray = GetAnimGroupAllSeats( side )

		foreach( seat, table in animGroupArray )
			attachments[ side ].append( GetAnimGroupAttachment( side, seat, "deploy" ) )
	}

	return attachments
}
