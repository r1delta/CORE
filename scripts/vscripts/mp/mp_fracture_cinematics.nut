
//const LARGE_REFUEL_SHIP_MODEL = "models/vehicle/capital_ship_Birmingham/birmingham_static_01.mdl"
const LARGE_REFUEL_SHIP_MODEL = "models/vehicle/redeye/redeye2.mdl"
const REFUEL_START_ANIM = "refueling_sequence_start"
const FX_REFUEL_SHIP_WARPIN = "veh_redeye_warp_in_FULL"
const FX_REFUEL_SHIP_WARPOUT = "veh_redeye_warp_out_FULL"

const REFUEL_SHIP_RUMBLE_AMPLITUDE = 4
const REFUEL_SHIP_MOVE_SPEED = 800

const ANIM_FLIGHT_TO_HOVER = "flight_to_hover"
const ANIM_HOVER_IDLE = "hover_idle"
const ANIM_HOVER_TO_FLIGHT = "hover_to_flight"
const ANIM_CRASH = "redeye2_crash"
const ANIM_WARPOUT = "redeye2_warpout"


RegisterSignal( "arriving" )
RegisterSignal( "redeye_explode" )
RegisterSignal( "redeye_shifts_weight" )

PrecacheModel( LARGE_REFUEL_SHIP_MODEL )
PrecacheModel( SKYBOX_REFUEL_SHIP_MODEL )
PrecacheModel( SKYBOX_REFUEL_SPRITE_MODEL )
PrecacheModel( SKYBOX_ARMADA_SHIP_MODEL_REDEYE )
PrecacheModel( SKYBOX_ARMADA_SHIP_MODEL_BERMINGHAM )
PrecacheParticleSystem( FX_REFUEL_SHIP_WARPIN )
PrecacheParticleSystem( FX_REFUEL_SHIP_WARPOUT )

spawnedBigRefuelShip <- false

playedDialog <- {}
playedDialog[ TEAM_IMC ] <- {}
playedDialog[ TEAM_MILITIA ] <- {}
playedDialog[ TEAM_IMC ][ "fracture_redeye_75_percent_integrity" ] <- false
playedDialog[ TEAM_MILITIA ][ "fracture_redeye_75_percent_integrity" ] <- false
playedDialog[ TEAM_IMC ][ "fracture_redeye_50_percent_integrity" ] <- false
playedDialog[ TEAM_MILITIA ][ "fracture_redeye_50_percent_integrity" ] <- false
playedDialog[ TEAM_IMC ][ "fracture_redeye_25_percent_integrity" ] <- false
playedDialog[ TEAM_MILITIA ][ "fracture_redeye_25_percent_integrity" ] <- false

function main()
{
	if ( reloadingScripts )
		return

	level.refuelShipHover <- Vector( -1231, 4819, 3795 )
	level.refuelShipDirection <- Vector( -0.813501, 0.580235, -0.039295 )
	level.refuelShipHalfDistance <- 18000

	Globalize( BigRefuelShip_Ending_Explode )
	Globalize( BigRefuelShip_Ending_FlyAway )

	RegisterServerVarChangeCallback( "matchProgress", MatchProgressChanged )

	wait 1.0

	// Disable auto cinematics at the start of the level
	FlagClear( "AutoCinematicsEnabled" )

	// Disable auto refueling ships
	FlagClear( "RefuelShipsEnabled" )
}

function MatchProgressChanged()
{
	if ( GetCinematicMode() && ( GAMETYPE == CAPTURE_POINT ) )
		thread FractureGameStateDialog()

	//##########################################
	// RED EYE REFUEL SHIP FLIES IN AND REFUELS
	//##########################################

	if ( level.nv.matchProgress >= MATCH_PROGRESS_RED_EYE_AND_ARMADA )
	{
		if ( !spawnedBigRefuelShip )
		{
			printt( "REDEYE INCOMMING" )

			spawnedBigRefuelShip = true
			level.nv.RefuelShip = CreateBigRefuelShip()
			thread BigRefuelShip_EnterAndRefuel( level.nv.RefuelShip )
			if ( GAMETYPE == CAPTURE_POINT )
				LinkTargetToHardpointTurrets( level.nv.RefuelShip.s.bullseye, level.refuelShipHover )
		}
	}

	//############################
	// DOGFIGHTS AND FLYBYS START
	//############################

	if ( level.nv.matchProgress >= MATCH_PROGRESS_AIR_ZINGERS )
	{
		if ( !Flag( "AutoCinematicsEnabled" ) )
		{
			printt( "AIR ZINGERS STARTING" )

			FlagSet( "AutoCinematicsEnabled" )
		}
	}

	//#########################################################
	// SMALL REFUEL SHIPS EXTRACT FUEL FROM THE PLAYABLE SPACE
	//#########################################################

	if ( level.nv.matchProgress >= MATCH_PROGRESS_REFUEL_GOBLINS )
	{
		if ( !Flag( "RefuelShipsEnabled" ) )
		{
			printt( "REFUEL GOBLINS STARTING" )

			FlagSet( "RefuelShipsEnabled" )
		}
	}
}

function FractureGameStateDialog()
{
	local imcScore = GameRules.GetTeamScore( TEAM_IMC )
	local scoreLimit = GetScoreLimit_FromPlaylist()
	local imcScoreProgress = ( imcScore.tofloat() / scoreLimit.tofloat() ) * 100.0

	local alias = null
	local requireIMCHasPointForMilitiaDialog = true

	if ( imcScoreProgress >= 75.0 )
		alias = "fracture_redeye_25_percent_integrity"
	else if ( imcScoreProgress >= 50.0 )
	{
		alias = "fracture_redeye_50_percent_integrity"
		requireIMCHasPointForMilitiaDialog = false
	}
	else if ( imcScoreProgress >= 25.0 )
		alias = "fracture_redeye_75_percent_integrity"

	if ( !alias )
		return

	// IMC
	if ( !playedDialog[ TEAM_IMC ][ alias ] )
	{
		playedDialog[ TEAM_IMC ][ alias ] = true
		PlayConversationToTeam( alias, TEAM_IMC )
	}

	// MILITIA
	if ( !playedDialog[ TEAM_MILITIA ][ alias ] )
	{
		if ( !requireIMCHasPointForMilitiaDialog || GetNumHardpointsControlledByTeam( TEAM_IMC ) > 0 )
		{
			playedDialog[ TEAM_MILITIA ][ alias ] = true
			PlayConversationToTeam( alias, TEAM_MILITIA )
		}
	}
}

function BigRefuelShip_EnterAndRefuel( ship )
{
	local moveDuration = level.refuelShipHalfDistance / REFUEL_SHIP_MOVE_SPEED

	// Move the ship to the hover point over time
	ship.s.scriptMover.NonPhysicsMoveTo( level.refuelShipHover, moveDuration, 0, moveDuration * 0.8 )
	EmitSoundOnEntity( ship, "fracture_scr_Redeye_FlyIn" )

	// Animate the ship
	local animDuration = ship.GetSequenceDuration( ANIM_FLIGHT_TO_HOVER )
	local animStartDelay = moveDuration - animDuration
	if ( animStartDelay > 0 )
	{
		wait animStartDelay
		if ( !IsValid( ship ) )
			return
	}
	ship.Anim_Play( ANIM_FLIGHT_TO_HOVER )
	wait animDuration
	if ( !IsValid( ship ) )
		return
	ship.Anim_Play( ANIM_HOVER_IDLE )
}

function BigRefuelShip_Ending_FlyAway()
{
	local ship = level.nv.RefuelShip
	if ( !IsValid( ship ) )
		return

	RefuelShipNoTarget( ship )

	local animDuration = ship.GetSequenceDuration( ANIM_WARPOUT )
	ship.Anim_Play( ANIM_WARPOUT )
	EmitSoundOnEntity( ship, "fracture_scr_Redeye_FlyOut" )

	wait animDuration - 1.0

	if ( !IsValid( ship ) )
		return

	// warpout effect
	local tagID = ship.LookupAttachment( "ORIGIN" )
	local fx = PlayFXOnEntity( FX_REFUEL_SHIP_WARPOUT, ship, "ORIGIN" )
	fx.EnableRenderAlways()

	wait 0.05

	local players = GetPlayerArray()
	foreach( player in players )
		Remote.CallFunction_Replay( player, "ServerCallback_RedeyeHideEffects" )
	level.nv.RefuelShip = null
	ship.Hide()

	wait 1

	ship.Kill()
}

function BigRefuelShip_Ending_Explode()
{
	local ship = level.nv.RefuelShip
	if ( !IsValid( ship ) )
		return

	RefuelShipNoTarget( ship )

	ship.Anim_Play( ANIM_CRASH )
	EmitSoundOnEntity( ship, "fracture_scr_Redeye_Explode" )

	WaitSignal( ship, "redeye_explode" )

	ship.Hide()
	local players = GetPlayerArray()
	foreach( player in players )
		Remote.CallFunction_Replay( player, "ServerCallback_RedeyeHideEffects" )
}

function RefuelShipNoTarget( ship )
{
	if ( !IsValid( ship ) )
		return
	if ( !( "bullseye" in ship.s ) )
		return
	if ( !IsValid( ship.s.bullseye ) )
		return
	ship.s.bullseye.SetNoTarget( true )
	ship.s.bullseye.SetNoTargetSmartAmmo( true )
}

function CreateBigRefuelShip()
{
	local spawnPos = level.refuelShipHover + ( level.refuelShipDirection * -level.refuelShipHalfDistance )
	local spawnAng = VectorToAngles( level.refuelShipDirection )

	EmitSoundAtPosition( spawnPos, "dropship_warpin" )
	wait 2.0
	local fx = PlayFX( FX_REFUEL_SHIP_WARPIN, spawnPos, spawnAng + Vector( 0,0,0 ) )
	fx.EnableRenderAlways()
	wait 0.8

	// Spawn the ship
	local ship = CreatePropDynamic( LARGE_REFUEL_SHIP_MODEL, spawnPos, spawnAng, 2 )
	ship.SetTeam( TEAM_MILITIA )
	ship.EnableRenderAlways()

	// Spawn a script mover and parent ship to it
	ship.s.scriptMover <- CreateScriptMover( ship )
	ship.s.scriptMover.SetOrigin( spawnPos )
	ship.SetParent( ship.s.scriptMover )

	// Spawn a NPC_bullseye for the turrets to shoot
	ship.s.bullseye <- CreateEntity( "npc_bullseye" )
	ship.s.bullseye.SetName( "refuel_ship_bullseye" )
	ship.s.bullseye.kv.rendercolor = "255 255 255"
	ship.s.bullseye.kv.renderamt = 0
	ship.s.bullseye.kv.health = 9999
	ship.s.bullseye.kv.max_health = -1
	ship.s.bullseye.kv.spawnflags = 516
	ship.s.bullseye.kv.FieldOfView = 0.5
	ship.s.bullseye.kv.FieldOfViewAlert = 0.2
	ship.s.bullseye.kv.AccuracyMultiplier = 1.0
	ship.s.bullseye.kv.reactChance = 100
	ship.s.bullseye.kv.physdamagescale = 1.0
	ship.s.bullseye.kv.WeaponProficiency = 3
	ship.s.bullseye.kv.minangle = "360"
	DispatchSpawn( ship.s.bullseye, false )

	ship.s.bullseye.SetTeam( TEAM_MILITIA )
	ship.s.bullseye.SetOrigin( ship.GetOrigin() - Vector( 0, 0, 150 ) )
	ship.s.bullseye.SetParent( ship )

	return ship
}