const SMOOTH_TIME = 0.2

const INSTA_KILL_TIME_THRESHOLD = 0.35

const BUG_REPRO_MOVEMELEE = 19114
const TITANARMMODEL = "models/weapons/arms/atlaspov.mdl"

const MELEE_AIM_ASSIST_SMOOTH_TIME = 0.15
const CLEAR_MELEE_AIM_ASSIST_ON_FIRST_HIT = 0

RegisterSignal( "MeleeSyncDone" )

PrecacheParticleSystem( "xo_damage_exp_1" )
MELEE_HUMAN_IMPACT_TABLE_IDX <- 0
MELEE_TITAN_IMPACT_TABLE_IDX <- 0
MELEE_TITAN_BIG_PUNCH_IMPACT_TABLE_IDX <- 0

FlagInit( "ForceSyncedMelee" )

const BC_EXPLOSIVE_PUNCH_FX_TABLE = "exp_medium"
const BC_EXPLOSIVE_BIG_PUNCH_FX_TABLE = "exp_large"
if ( IsServer() )
{
	PrecacheImpactEffectTable( BC_EXPLOSIVE_PUNCH_FX_TABLE )
	PrecacheImpactEffectTable( BC_EXPLOSIVE_BIG_PUNCH_FX_TABLE )
}

enum eHumanExecutionType
{
	necksnapRear
	necksnapLeft
	necksnapRight
	necksnapFront
	necksnapAboveBack
}

enum eTitanExecutionType
{
	fistThroughCockpit
	dummy //not used yet
}

function main()
{

	level.meleeHintActive <- false

	level.HUMAN_VS_TITAN_MELEE <- 1
	level.titan_attack_anim_event_count <- 0
	level.titan_attack_push_button_count <- 0

	Globalize( MeleeInit )
	Globalize( CodeCallback_OnMeleePressed )
	Globalize( CodeCallback_OnMeleeReleased )
	Globalize( CodeCallback_OnMeleeKilled )
	Globalize( CodeCallback_IsValidMeleeExecutionTarget )
	Globalize( CodeCallback_IsValidMeleeAttackTarget )
	Globalize( CodeCallback_OnMeleeAttackAnimEvent )
	Globalize( CodeCallback_OnCustomActivityFinished )
	Globalize( CodeCallback_MeleeAttackLunge )
	Globalize( IsPlayerTitanAttackerMeleeingVictim )
	Globalize( CreateMeleeScriptMoverBetweenEnts )

	Globalize( FindBestMeleeAction )
	Globalize( GetMeleeActions )
	Globalize( AddMeleeAction )
	Globalize( GetEyeOrigin )
	Globalize( PlayerConeTraceResult )
	Globalize( SetObjectCanBeMeleed )

	level.allMeleeActions <- {}
	level.allMeleeActions[ "human" ] <- {}
	level.allMeleeActions[ "titan" ] <- {}

	local table =
	{
		attackerOriginFunc = GetEyeOrigin
		targetOriginFunc = GetEyeOrigin
		array = []
		meleeThreadShared = Bind( MeleeThread_HumanVsHuman )
	}
	level.allMeleeActions[ "human" ][ "human" ] <- table

	local action =
	{
		enabled = true
		direction = Vector( -1, 0, 0 )
		distance = HUMAN_EXECUTION_RANGE
		attackerAnimation1p = "ptpov_rspn101_melee_necksnap_rear"
		attackerAnimation3p = "pt_rspn101_melee_necksnap_rear"
		targetAnimation1p = "ptpov_melee_necksnap_rear_attacked"
		targetAnimation3p = "pt_melee_necksnap_rear_attacked"
		executionType = eHumanExecutionType.necksnapRear
		minDot = 0.2
	}
	AddMeleeAction( "human", "human", action )

	if ( IsServer() )
	{
		IncludeFile( "mp/_melee_titan" )
		Globalize( ShouldHolsterWeaponForMelee )
	}

	MELEE_HUMAN_IMPACT_TABLE_IDX = PrecacheImpactEffectTable( "melee_human" )
	MELEE_TITAN_IMPACT_TABLE_IDX = PrecacheImpactEffectTable( "melee_titan" )
	MELEE_TITAN_BIG_PUNCH_IMPACT_TABLE_IDX = PrecacheImpactEffectTable( "melee_titan_big_punch" )
}




function EntitiesDidLoad()
{
}


function GetEyeOrigin( ent )
{
	return ent.EyePosition()
}

//Called after pressing the melee button to recheck for targets
function CodeCallback_IsValidMeleeExecutionTarget( attacker, target )
{
	level.meleeHintActive = false

	if ( attacker == target )
		return false

	//No more mid-air execution
	//TODO: When Titans dash towards other titans it looks like they bounce back off into the air
	//We should fix that, otherwise mid-air executions are going to happen
	if ( !attacker.IsOnGround() && attacker.IsHuman() )
		return false


	if ( !IsAlive( target ) )
		return false

	if ( !CanBeMeleed( target ) )
		return false

	if ( attacker.IsTitan() && target.IsTitan() )
	{
		if ( target.GetTitanSoul().IsEjecting() )
			return false

		if ( attacker.ContextAction_IsActive() )
			return false

		if ( target.ContextAction_IsActive() )
			return false
	}

	if ( !CheckVerticallyCloseEnough( attacker, target ) )
		return false

	//No necksnaps while wall running or mantling
	if ( attacker.IsWallRunning() )
		return false

	if ( attacker.IsMantling() )
		return false

	if ( target.IsPlayer() ) //Disallow execution on a bunch of player-only actions
	{

		if ( target.IsHuman() )
		{
			if ( target.IsWallRunning() )
				return false

			if ( target.IsMantling() )
				return false

			if ( !target.IsOnGround() ) //disallow mid-air necksnaps. Can't really do that for Titan executions since dash puts them in mid air... will have visual glitches unfortunately.
				return false

			if ( target.IsCrouched() )
				return false

			if ( Rodeo_IsAttached( target ) )
				return false
		}
	}

	//Disallow executions on contextActions marked Busy. Note that this allows
	//execution on melee and leeching context actions!
	if ( target.ContextAction_IsBusy() )
		return false

	if ( target.IsNPC() ) //NPC only checks
	{
		if ( target.ContextAction_IsActive() )
			return false

		if ( !target.IsInterruptable() )
			return false

		if ( IsServer() && IsSuicideSpectre( target ) )
			return false
	}

	if ( IsMultiplayer() )
	{
		if ( attacker.GetTeam() == target.GetTeam() && GAMETYPE != FFA )
			return false

		if ( IsServer() )
		{
			if ( "meleeExecutionAttacker" in target.s ) //Don't allow necksnap on a guy who'se already getting necksnapped
				return false
		}

	}
	else
	{
		if ( IsServer() )
		{
			if ( !target.Hates( attacker ) )
				return false
		}
	}

	local actions = GetMeleeActions( attacker, target )
	if ( !actions )
		return false

	if ( ( "isValidMeleeTargetFunc" in actions ) && !actions.isValidMeleeTargetFunc( actions, attacker, target ) )
		return false

	local action = FindBestMeleeAction( attacker, target, actions )

	if ( !action )
		return false

	if ( !PlayerMelee_IsExecutionReachable( attacker, target, 0.65 ) )
		return false

	if ( !ShouldPlayerExecuteTarget( attacker, target ) )
		return false

	level.meleeHintActive = true
	return true
}

function CodeCallback_IsValidMeleeAttackTarget( attacker, target )
{
	if ( attacker == target )
		return false

	if ( target.IsBreakableGlass() )
		return true

	if( !ObjectCanBeMeleed( target ) )  // Objects like drones, not NPCs and living things
	{
		if ( !IsAlive( target ) )
			return false
	}

	if ( !CanBeMeleed( target ) )
		return false

	if ( attacker.GetTeam() == target.GetTeam() )
			return false

	if ( IsServer() )
	{
		if ( IsPlayer( target ) )
		{
			//Make titans not able to melee the pilot who is doing the embark animation
			if ( GetTitanBeingRodeoed( target ) == attacker )
				return false
		}
	}

	if ( target.GetParent() == attacker )
	{
		return false
	}

	return true
}


function CodeCallback_OnMeleePressed( player )
{
	//printt("Melee pressed ")
	Assert( player.PlayerMelee_CanMelee() )

	thread CodeCallback_OnMeleePressed_Internal( player )
}

function CodeCallback_OnMeleePressed_Internal( player )
{
	if ( player.IsWeaponDisabled() )
		return false

	if ( player.PlayerMelee_GetState() != PLAYER_MELEE_STATE_NONE )
		return false

	//Threaded off so we can use OnThreadEnd on server to always unforceStand
	if ( IsServer() )
	{
		OnThreadEnd(
			function () : ( player )
			{
				if ( IsValid( player ) )
				  player.UnforceStand()
			}
		)

		player.ForceStand()
	}

	local target = PlayerConeTraceResult( player, "CodeCallback_IsValidMeleeExecutionTarget" )
	if ( !PlayerTriesExecutionMelee( player, target ) )
	{
		// didn't do execution
		if ( player.IsTitan() )
			TitanNonSyncedMelee( player )

		if ( player.IsHuman() )
			HumanNonSyncedMelee( player )
	}


	//HACK: wait 0 so we don't forceStand and unforceStand on the same frame.
	//Done on the same frame this does nothing, resulting in player returning to a crouching position after melee
	wait 0

}

function AttemptScriptedExecution( player, target )
{
	Assert( IsServer() )
	if ( !CodeCallback_IsValidMeleeExecutionTarget( player, target ) )
		return

	if ( target.IsTitan() )
	{
		if ( Time() == target.GetTitanSoul().doomedTime )
		{
			return
		}
	}

	if ( PlayerTriesExecutionMelee( player, target ) )
	{
		player.ForceStand()
		// otherwise arm pops out
		thread DelayedHolster( player )
	}
}

function PlayerConeTraceResult( player, func )
{
	local range
	local angle
	if ( player.IsTitan() )
	{
		range = TITAN_EXECUTION_RANGE
		angle = TITAN_EXECUTION_ANGLE
	}
	else
	{
		range = HUMAN_EXECUTION_RANGE
		angle = HUMAN_EXECUTION_ANGLE
	}

	return PlayerMelee_ConeTrace( player, range, angle, func )
}

function ShouldHolsterWeaponForMelee( player )
{
	if ( !IsServer() )
		return true

	if ( !player.IsTitan() )
		return true

	return Time() - player.s.startDashMeleeTime > 1.0 //Fix issue with gun being out when it shouldn't, according to Mackey...
}

function PlayerTriesExecutionMelee( player, target )
{
	if ( !target )
		return false

	if ( target.ContextAction_IsBusy() )
		return false

	if ( ShouldHolsterWeaponForMelee( player ) )
		player.HolsterWeapon()

	if ( !IsAlive( target ) )
	{
		//JFS: (Just for ship). If not alive at this part, target was killed by Vortex from holstering weapon
		player.DeployWeapon()
		return
	}

	if ( player.IsTitan() )
	{
		if ( IsServer() )
		{
			player.PlayerMelee_SetState( PLAYER_MELEE_STATE_TITAN_EXECUTION )
		}
		else
		{
			player.PlayerMelee_SetState( PLAYER_MELEE_STATE_TITAN_EXECUTION_PREDICTED )
		}
	}
	else
	{
		if ( IsServer() )
		{
			player.PlayerMelee_SetState( PLAYER_MELEE_STATE_HUMAN_EXECUTION )
		}
		else
		{
			player.PlayerMelee_SetState( PLAYER_MELEE_STATE_HUMAN_EXECUTION_PREDICTED )
		}
	}

	if ( IsClient() )
	{
		player.SniperCam_Deactivate(0)
		PlayerMelee_SetAimAssistTarget( player, target, MELEE_AIM_ASSIST_SMOOTH_TIME )
		return true
	}

	if ( player.IsTitan() )
	{
		TransferDamageHistoryToTarget( target )
	}

	local rv = DoSynchedMelee( player, target )
	if ( !rv )
		player.DeployWeapon()

	return rv
}

function TransferDamageHistoryToTarget( target )
{
	local titanSoul = target.GetTitanSoul()
	if ( "recentDamageHistory" in titanSoul.s )
	{
		if ( !( "recentDamageHistory" in target.s ) )
			target.s.recentDamageHistory <- []
		foreach ( entry in titanSoul.s.recentDamageHistory )
		{
			target.s.recentDamageHistory.append( entry )
		}
	}
}

function DoSynchedMelee( player, target )
{

	local actions = GetMeleeActions( player, target )

	Assert( actions, "No melee action for " + player + " vs " + target )

	if ( IsServer() )
		PlayerMelee_StartLagCompensateTarget( player, target )

	local action = FindBestMeleeAction( player, target, actions )

	if ( IsServer() )
		PlayerMelee_FinishLagCompensateTarget( player )

	if ( !action )
		return false

	if ( IsServer() && ( "meleeThreadServer" in actions )  && actions.meleeThreadServer )
	{
		thread actions.meleeThreadServer( actions, action, player, target )
		return true
	}

	if ( "meleeThreadShared" in actions )
	{
		thread actions.meleeThreadShared( actions, action, player, target )
		return true
	}

	return false
}


function CodeCallback_OnMeleeReleased( player )
{
}


function TextDebug( msg )
{
	wait 0.5
	printt( msg )
}




function FrontDashMelee( player )
{
	return PlayerHasPassive( player, PAS_TITAN_PUNCH )
}

function TitanNonSyncedMelee( player )
{
	local attackerAnimGesture3p
	local attackerAnim1p
	local meleeSwingSound

	local range = TITAN_AIMASSIST_MELEE_ATTACK_RANGE
	local angle = TITAN_AIMASSIST_MELEE_ATTACK_ANGLE

	local aimAssistTarget = PlayerMelee_ConeTrace( player, range, angle, "CodeCallback_IsValidMeleeAttackTarget" )

	if ( IsServer() && IsAlive( aimAssistTarget ) )
		player.s.currentMeleeAttackTarget = aimAssistTarget

	local attackState = DecideTitanMeleeAttackType( player )

	player.PlayerMelee_SetState( attackState )

	local titanSoul = player.GetTitanSoul()
	local titanType = GetSoulTitanType( titanSoul )

	switch ( player.PlayerMelee_GetState() )
	{
		case PLAYER_MELEE_STATE_TITAN_MELEE_JAB:
			attackerAnimGesture3p = "ACT_GESTURE_MELEE_ATTACK1"
			attackerAnim1p = "ACT_VM_MELEE_ATTACK1"
			meleeSwingSound = titanType + "_melee_swing_fast"
			break

		case PLAYER_MELEE_STATE_TITAN_DASH_PUNCH:
		default:
			attackerAnimGesture3p = "ACT_GESTURE_MELEE_ATTACK2"
			attackerAnim1p = "ACT_VM_MELEE_ATTACK2"
			meleeSwingSound = titanType + "_Melee_BigPunch_Swing_Fast"
			break
	}

	local weapon = player.GetActiveWeapon()
	if ( !weapon  )
		return

	if ( !weapon.Anim_HasActivity( attackerAnim1p ) )
	{
		if ( weapon.IsWeaponOffhand() )
		{
			player.ClearOffhand()
		}
		else
		{
			return
		}
	}

	player.PlayerMelee_StartAttack()

	// Client only: Push player towards closest, valid melee target
	if ( IsClient() )
	{
		//No range multipler for titan attacks, because it feels alright without it
		if ( player.PlayerMelee_GetState() == PLAYER_MELEE_STATE_TITAN_DASH_PUNCH )
		{
			range = TITAN_AIMASSIST_DASH_ATTACK_RANGE
			angle = TITAN_AIMASSIST_DASH_ATTACK_ANGLE
		}

		if ( !WasRecentlyHitForDamageType( player, damageTypes.TitanMelee, DAMAGE_BREAK_MELEE_TIME ) )
		{
			if ( IsValid( aimAssistTarget )  && aimAssistTarget.IsHumanSized() ) //Only turn on for Titans vs Humans for now
				PlayerMelee_SetAimAssistTarget( player, aimAssistTarget, MELEE_AIM_ASSIST_SMOOTH_TIME )
		}

	}

	if ( IsServer() )
	{
		if ( player.IsPredicting() )
		{
			EmitSoundOnEntityExceptToPlayer( player, player, meleeSwingSound )
		}
		else
		{
			EmitSoundOnEntity( player, meleeSwingSound )
		}

		player.Anim_PlayGesture( attackerAnimGesture3p )

		if ( attackState == PLAYER_MELEE_STATE_TITAN_DASH_PUNCH )
		{
			thread MeleeJetFX( player )
			player.s.startDashMeleeTime = Time()
		}
	}
	else if ( IsFirstTimePredicted() )
	{
		Assert( InPrediction() )
		EmitSoundOnEntity( player, meleeSwingSound )
	}

	player.Weapon_StartCustomActivity( attackerAnim1p, true )
}

function MeleeJetFX( player )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "Disconnected" )

	local fx = []

	OnThreadEnd(
		function () : ( fx )
		{
			foreach ( effect in fx )
			{

				if ( !IsValid( effect ) )
					continue
				effect.ClearParent()
				effect.Destroy()
			}
		}
	)

	fx.append ( PlayFXOnEntity( "xo_atlas_jet_large", player, "thrust" ) )
	fx.append ( PlayFXOnEntity( "xo_atlas_jet_large", player, "vent_left" ) )
	fx.append ( PlayFXOnEntity( "xo_atlas_jet_large", player, "vent_right" ) )

	wait 1
}

function HumanNonSyncedMelee( player )
{
	//Pretty much copy pasted from TitanNonSyncedMelee
	local attackerAnimGesture3p
	local attackerAnim1p
	local melee3pSound
	local melee1pSound

	local weapon = player.GetActiveWeapon()
	if ( !IsValid( weapon ) )
		return

	player.PlayerMelee_SetState( PLAYER_MELEE_STATE_HUMAN_KICK_ATTACK )

	local meleeAttackType = player.PlayerMelee_GetState()
	switch ( meleeAttackType )
	{
		case PLAYER_MELEE_STATE_HUMAN_KICK_ATTACK:
		default:
		{
			//printt("kick attack chosen")
			attackerAnimGesture3p = "ACT_MELEE_ATTACK2"
			attackerAnim1p = "ACT_VM_MELEE_ATTACK1"

			local footsteps = player.GetPlayerSettingsField( "footstep_type" )
			if ( footsteps == "robot" )
			{
				melee3pSound = "Spectre.Servo.Melee.Short"
				melee1pSound = "Spectre.Servo.Melee.Short_1P"
			}
			else
			{
				melee3pSound = "player_melee_kick_3P"
				melee1pSound = "player_melee_kick_1P"
			}
			break
		}
	}

	if ( !weapon.Anim_HasActivity( attackerAnim1p ) )
	{
		printt("*WARNING* Weapon doesn't have melee activity: " + attackerAnim1p)
		player.PlayerMelee_SetState( PLAYER_MELEE_STATE_NONE )
		return
	}

	//printt("Starting Human Melee" )
	player.PlayerMelee_StartAttack()

	// Client only: Push player towards closest, valid melee target
	if ( IsClient() )
	{
		local playerVelocity = player.GetVelocity()
		local forwardVel = Vector( playerVelocity.x, playerVelocity.y, 0 )
		local aimAssistMultipler = GraphCapped( forwardVel.LengthSqr(), 0, 100000, HUMAN_MELEE_ATTACK_ASSIST_RANGE_MULTIPLIER_LOW_THRESHOLD, HUMAN_MELEE_ATTACK_ASSIST_RANGE_MULTIPLIER_HIGH_THRESHOLD ) //66000 is about sprint speed squared. Wall run max speed is about 240000.

		local range = AdjustDownwardKickRange( player )
		 range *=  aimAssistMultipler
		//printt( "AimAssistMultiplier: " + aimAssistMultipler + ", range : " + range )

		local angle =  HUMAN_MELEE_ATTACK_ASSIST_ANGLE
		local aimAssistTarget = PlayerMelee_ConeTrace( player, range, angle, "CodeCallback_IsValidMeleeAttackTarget" )

		if ( !WasRecentlyHitForDamage( player, 100, DAMAGE_BREAK_MELEE_TIME ) && IsAlive( aimAssistTarget ) ) //If player took a chunk of damage recently, stop auto assist from kicking in
		{

			local displacement = player.GetOrigin() - aimAssistTarget.GetOrigin()
			displacement.z = 0
			local distance = displacement.Length()
			local reducedAngle =  GraphCapped( distance, range * 0.35, range, angle, angle * 0.35 )

			//printt( "Distance: " + distance + ", range: " + range + ", angle: " + angle + ", reducedAngle: " + reducedAngle )

			local reducedAngleTarget = PlayerMelee_ConeTrace( player, range, reducedAngle, "CodeCallback_IsValidMeleeAttackTarget" )

			if ( reducedAngleTarget == aimAssistTarget )
				PlayerMelee_SetAimAssistTarget( player, aimAssistTarget, MELEE_AIM_ASSIST_SMOOTH_TIME )
		}
	}

	if ( IsServer() )
	{
		EmitDifferentSoundsOnEntityForPlayerAndWorld( melee1pSound, melee3pSound, player, player )
		player.Anim_PlayGesture( attackerAnimGesture3p )
	}

	player.Weapon_StartCustomActivity( attackerAnim1p, false )
}

function HumanAttack( human )
{
	//Pretty much a copy paste from TitanAttack
	if ( !IsValid( human ) )
	{
		return
	}

	if ( human.PlayerMelee_GetAttackHitEntity() )
	{
		return
	}

	local traceResult = PerformMeleeAttackTrace( human )
	if ( !traceResult )
	{
		return
	}

	if ( IsValid( traceResult.entity )  )
	{
		human.DispatchImpactEffects( traceResult.entity, traceResult.startPosition, traceResult.position, traceResult.surfaceProp, traceResult.hitbox, traceResult.damageType, MELEE_HUMAN_IMPACT_TABLE_IDX, human, traceResult.impactEffectFlags )

		human.PlayerMelee_SetAttackHitEntity( traceResult.entity )

		// Clear aim assist target now that we've hit something.
		//This will restore player control
		if ( CLEAR_MELEE_AIM_ASSIST_ON_FIRST_HIT && IsClient() )
		{
			PlayerMelee_SetAimAssistTarget( human, null, 0.0 )
		}

		if ( traceResult.entity.IsHumanSized() )
		{
			HumanAttackHumanSized( human, traceResult )
		}
		else if ( traceResult.entity.IsBreakableGlass() )
		{
			if ( IsServer() )
				traceResult.entity.BreakSphere( traceResult.position, 50 )
		}
	}
}

function TitanAttack( titan )
{
	if ( !IsValid( titan ) )
	{
		return
	}

	if ( titan.PlayerMelee_GetAttackHitEntity() )
	{
		return
	}

	local traceResult = PerformMeleeAttackTrace( titan )
	if ( !traceResult )
	{
		return
	}

	if ( IsValid( traceResult.entity )  )
	{
		local hasBigPunch = PlayerHasPassive( titan, PAS_TITAN_PUNCH )
		if ( hasBigPunch ) //Big punch uses separate impact table
			titan.DispatchImpactEffects( traceResult.entity, traceResult.startPosition, traceResult.position, traceResult.surfaceProp, traceResult.hitbox, traceResult.damageType, MELEE_TITAN_BIG_PUNCH_IMPACT_TABLE_IDX, titan, traceResult.impactEffectFlags )
		else
			titan.DispatchImpactEffects( traceResult.entity, traceResult.startPosition, traceResult.position, traceResult.surfaceProp, traceResult.hitbox, traceResult.damageType, MELEE_TITAN_IMPACT_TABLE_IDX, titan, traceResult.impactEffectFlags )

		TryExplosivePunch( titan, traceResult.position, hasBigPunch )

		titan.PlayerMelee_SetAttackHitEntity( traceResult.entity )

		// Clear aim assist target now that we've hit something.
		//This will restore player control
		if ( CLEAR_MELEE_AIM_ASSIST_ON_FIRST_HIT && IsClient() )
		{
			PlayerMelee_SetAimAssistTarget( titan, null, 0.0 )
		}

		if ( traceResult.entity.IsHumanSized() )
		{
			TitanAttackHumanSized( titan, traceResult )
		}
		else if ( traceResult.entity.IsTitan() )
		{
			TitanAttackTitan( titan, traceResult )
		}
		else if ( ShouldMeleeDamage( traceResult.entity ) ) // Catches cases for dropships, turrets, etc
		{
			TitanAttackDefault( titan, traceResult )
		}
		else if ( traceResult.entity.IsBreakableGlass() )
		{
			if ( IsServer() )
				traceResult.entity.BreakSphere( traceResult.position, 150 )
		}
	}
}

function TargetHitMeFirst( target, me )
{
	if ( target.s.lastMeleeVictim != me )
		return false

	return Time() - target.s.lastMeleeHitTime <= 0.2
}

function ShouldClampTargetVelocity( targetVelocity, pushBackVelocity, clampRatio )
{
	local dot = targetVelocity.Dot( pushBackVelocity )
	if ( dot < 0 )
		return true

	if ( dot <= 0 )
		return false

	local velRatio = targetVelocity.LengthSqr() / pushBackVelocity.LengthSqr()

	return velRatio < clampRatio
}
Globalize( ShouldClampTargetVelocity )


function CanBeMeleed( target )
{
	if ( target.IsPlayer() )
		return true

	if ( target.IsNPC() )
		return true

	if ( ObjectCanBeMeleed( target ) )
		return true

	return false
}

// IMPORTANT: Only used for non-player, non-living special cases like prop_dynamics we want to be able to melee (drones, etc)
function ObjectCanBeMeleed(ent)
{
	if ( !( "canBeMeleed" in ent.s ) )
		return false

	return ent.s.canBeMeleed
}

// IMPORTANT: Only used for non-player, non-living special cases like prop_dynamics we want to be able to melee (drones, etc)
function SetObjectCanBeMeleed(ent, value)
{
	Assert( !ent.IsPlayer(), ent + " should not be a player. This is for non-player, non-NPC entities.")
	Assert( !ent.IsNPC(), ent + " should not be an NPC. This is for non-player, non-NPC entities.")

	if ( !( "canBeMeleed" in ent.s ) )
		ent.s.canBeMeleed <- null

	ent.s.canBeMeleed = value
}

function CodeCallback_OnMeleeKilled( target )
{
	if ( !IsAlive( target ) )
		return

	target.ClearInvulnerable()

	local damageSourceId
	if ( target.IsTitan() )
	{
		// I don't think this branch ever gets hit. Titan executions do something else.
		damageSourceId = eDamageSourceId.titan_execution
	}
	else
	{
		damageSourceId = eDamageSourceId.human_execution
	}

	local attacker
	if ( "meleeExecutionAttacker" in target.s )
	{
		attacker = target.s.meleeExecutionAttacker
	}
	else if ( "lastMeleeExecutionAttacker" in target.s )
	{
		attacker = target.s.lastMeleeExecutionAttacker
	}
	else
	{
		attacker = null
	}

	local damageAmount = target.GetMaxHealth() + 1
	target.TakeDamage( damageAmount , attacker, attacker, { forceKill = true, damageType = DMG_MELEE_EXECUTION, damageSourceId = damageSourceId, scriptType = DF_NO_INDICATOR } )
}


//function TitanExposionDeath( titan, attacker )
//{
//	if ( !IsAlive( titan ) )
//		return
//
//	ExplodeTitanBits( titan )
//	// and your pretty titan too!
//
//	//TitanEjectExplosion
//	local deathTable = { scriptType = damageTypes.TitanMelee, forceKill = true, damageType = DMG_MELEE_EXECUTION, damageSourceId = eDamageSourceId.titan_execution }
//	titan.TakeDamage( titan.GetMaxHealth() + 1, attacker, attacker, deathTable )
//}

function CreateMeleeScriptMoverBetweenEnts( attacker, target )
{
	local endOrigin = target.GetOrigin()
	local startOrigin = attacker.GetOrigin()
	local refVec = endOrigin - startOrigin

	local refAng = VectorToAngles( refVec )
	if ( abs( refAng.x ) > 35 ) //If pitch is too much, use angles from either attacker or target
	{
		if ( attacker.IsTitan() )
			refAng = attacker.GetAngles()  //Doing titan synced kill from front, so use attacker's origin
		else
			refAng = target.GetAngles()  // Doing rear necksnap, so use target's angles
	}



	local refPos = endOrigin - refVec * 0.5

	local ref = CreateScriptMover( attacker )
	ref.SetOrigin( refPos )
	ref.SetAngles( refAng )

	return ref
}

function MeleeThread_HumanVsHuman( actions, action, attacker, target )
{
	// function off for reload scripts
	MeleeThread_HumanVsHumanInternal( actions, action, attacker, target )
}

function MeleeThread_HumanVsHumanInternal( actions, action, attacker, target )
{
	Assert( target.IsHumanSized(), target + " is not human sized melee target" )
	Assert( attacker.IsPlayer() && attacker.IsHumanSized(), attacker + " is not human sized player attacker" )
	Assert( IsAlive( attacker ) )
	Assert( IsAlive( target ) )

	 if ( target.IsPlayer() )
	 	BurnCardOnDeath( target, attacker, BC_NEXTDEATH )

	local e = {}
	e.targetStartOrigin <- target.GetOrigin()
	e.attackerStartOrigin <- attacker.GetOrigin()
	local ref = CreateMeleeScriptMoverBetweenEnts( attacker, target )

	local angles = target.GetAngles()
	angles.x = ref.GetAngles().x.tointeger()

	ref.SetAngles( angles )
	ref.SetOrigin( target.GetOrigin() )

	OnThreadEnd(
		function() : ( ref, target, attacker )
		{
			if ( IsValid( ref ) )
			{
				if ( IsValid( attacker ) )
					attacker.ClearParent()

				if ( IsValid( target ) )
					target.ClearParent()

				ref.Kill()
			}

			if ( IsValid( attacker ) )
			{
				attacker.PlayerMelee_SetState( PLAYER_MELEE_STATE_NONE )
			}
		}
	)

	thread MeleeThread_HumanVsHuman_Attacker( actions, action, attacker, target, ref, e )

	// target's sequence is longer
	waitthread MeleeThread_HumanVsHuman_Target( actions, action, attacker, target, ref, e )
}


function MeleeThread_HumanVsHuman_Target( actions, action, attacker, target, ref, e )
{
	attacker.EndSignal( "OnAnimationDone" )
	attacker.EndSignal( "OnAnimationInterrupted" )
	attacker.EndSignal( "OnDeath" )
	attacker.EndSignal( "Disconnected" )
	attacker.EndSignal( "ScriptAnimStop" )

	OnThreadEnd(
		function() : ( attacker, target, e )
		{
			if ( IsValid( target ) )
			{
				target.ClearParent()
				target.Solid()
				target.PlayerMelee_ExecutionEndTarget()
				DeleteAnimEvent( target, "mark_for_death", MarkForDeath )
				//target.Anim_Stop()

				if ( target.IsPlayer() )
					target.ClearAnimViewEntity()

				if ( IsAlive( target ) )
				{
					if ( "markedForExecutionDeath" in target.s ) //Kill off target if he already reached blackout part of melee
					{
						Assert( "meleeExecutionAttacker"  in target.s, "No meleeExecutionAttacker in target.s" )
						//printt( "Killing off target "  + target + " because he already reached blackout part of execution!" )

						local damageAmount = target.GetMaxHealth() + 1
						target.TakeDamage( damageAmount, target.s.meleeExecutionAttacker, target.s.meleeExecutionAttacker, { forceKill = true, damageType = DMG_MELEE_EXECUTION, damageSourceId = eDamageSourceId.human_execution } )
						delete target.s.markedForExecutionDeath

					}
					else if ( target.IsPlayer() ) //NPCs don't have DeployWeapon()
					{
						target.DeployWeapon()
					}
				}

				if ( "meleeExecutionAttacker" in target.s )
				{
					if ( "lastMeleeExecutionAttacker" in target.s )
					{
						delete target.s.lastMeleeExecutionAttacker
					}

					target.s.lastMeleeExecutionAttacker <- target.s.meleeExecutionAttacker
					delete target.s.meleeExecutionAttacker
				}
			}
		}
	)

	//Break out of context actions like hacking control panel etc
	if ( target.ContextAction_IsActive() )
		target.Anim_Stop()

	target.PlayerMelee_ExecutionStartTarget( attacker )

	target.s.meleeExecutionAttacker <- attacker
	AddAnimEvent( target, "mark_for_death", MarkForDeath )

	local targetSequence = CreateFirstPersonSequence()
	targetSequence.blendTime = 0.25
	targetSequence.attachment = "ref"
	targetSequence.thirdPersonAnim = action.targetAnimation3p

	if ( target.IsPlayer() )
	{
		target.HolsterWeapon()
		targetSequence.firstPersonAnim = action.targetAnimation1p
	}

	target.NotSolid()

	local necksnapSoundPrefix
	if ( target.IsSpectre() )
		necksnapSoundPrefix = "Spectre_"
	else if ( target.IsHuman() )
		necksnapSoundPrefix = "Human_"
	else assert( false, "Necksnap target is neither human nor spectre" )

	local necksnap1pSound
	local necksnap3pSound
	local footsteps = attacker.GetPlayerSettingsField( "footstep_type" )
	if ( footsteps == "robot" )
	{
		if ( target.IsHuman() )
			necksnap1pSound = "Spectre_vs_Human_Mvmt_Melee_NeckSnap_1p_vs_3p"
		else
			necksnap1pSound = "Spectre_vs_Spectre_Mvmt_Melee_NeckSnap_1p_vs_3p"
		necksnap3pSound = "Spectre_Mvmt_Melee_NeckSnap_3p_vs_3p"
	}
	else
	{
		necksnap1pSound = necksnapSoundPrefix + "Mvmt_Melee_NeckSnap_1p_vs_3p"
		necksnap3pSound = necksnapSoundPrefix + "Mvmt_Melee_NeckSnap_3p_vs_3p"
	}

	EmitDifferentSoundsOnEntityForPlayerAndWorld( necksnap1pSound, necksnap3pSound, target, attacker )

	waitthread FirstPersonSequence( targetSequence, target, ref )
}

function MeleeThread_HumanVsHuman_Attacker( actions, action, attacker, target, ref, e )
{
	attacker.EndSignal( "OnAnimationDone" )
	attacker.EndSignal( "OnAnimationInterrupted" )
	attacker.EndSignal( "OnDeath" )
	attacker.EndSignal( "Disconnected" )
	attacker.EndSignal( "ScriptAnimStop" )

	OnThreadEnd(
		function() : ( attacker, target, e )
		{
			if ( IsValid( attacker ) )
			{
				attacker.ClearParent()
				attacker.PlayerMelee_ExecutionEndAttacker()
				attacker.ClearAnimViewEntity()
				attacker.DeployWeapon()
			}

			if ( !IsAlive( attacker ) )
				attacker.Anim_Stop()

		}
	)

	local attackerSequence = CreateFirstPersonSequence()
	attackerSequence.blendTime = 0.4
	attackerSequence.attachment = "ref"
	attackerSequence.thirdPersonAnim = action.attackerAnimation3p
	attackerSequence.firstPersonAnim = action.attackerAnimation1p

	local duration = attacker.GetSequenceDuration( attackerSequence.thirdPersonAnim )

	attacker.PlayerMelee_ExecutionStartAttacker( Time() + duration )
	attacker.HolsterWeapon()

	thread FirstPersonSequence( attackerSequence, attacker, ref )

	wait duration
}

function WeaponCatch( attacker, weaponClass )
{
	local givenWeapon = attacker.GiveWeapon( weaponClass )

	local weapons = attacker.GetMainWeapons()
	foreach ( weapon in weapons )
	{
		if ( weapon.GetClassname() == weaponClass )
		{
			weapon.EnableCatchAnimation()
			attacker.SetActiveWeapon( weaponClass )
			break
		}
	}

	attacker.DeployWeapon()
}

function AddMeleeAction( attackerType, targetType, table )
{
	Assert( attackerType in level.allMeleeActions, "Have not setup melee actions for attacker type " + attackerType )
	Assert( targetType in level.allMeleeActions[ attackerType ], "Have not setup melee actions fortarget type " + targetType )

	// sqr the distance
	table.distance = table.distance * table.distance

	level.allMeleeActions[ attackerType ][ targetType ].array.append( table )
}

function FindBestMeleeAction( attacker, target, actions )
{
	local attackerPos = actions.attackerOriginFunc( attacker ) // + ( attacker.GetVelocity() * SMOOTH_TIME )
	local targetPos = actions.targetOriginFunc( target )

	local absTargetToPlayerDir
	if ( attackerPos == targetPos )
	{
		absTargetToPlayerDir = Vector( 1, 0, 0 )
	}
	else
	{
		local angles = attacker.EyeAngles()
		local forward = angles.AnglesToForward()

		absTargetToPlayerDir = ( attackerPos - targetPos )
		absTargetToPlayerDir.Normalize()

		// is the target in my fov?
		if ( forward.Dot( absTargetToPlayerDir * -1 ) < 0.77 )
			return null
	}

	local relTargetToPlayerDir = CalcRelativeVector( Vector( 0, target.EyeAngles().y, 0 ), absTargetToPlayerDir )

	local bestAction = null
	local bestDot = -2
	local dist = ( actions.attackerOriginFunc( attacker ) - actions.targetOriginFunc( target ) ).Length()

	foreach ( action in actions.array )
	{
		if ( !action.enabled )
			continue

		//if ( attacker.IsDodging() )
		//{
		//	if ( dist > action.dashingDistance )
		//		continue
		//}
		//else
		{
			if ( dist > action.distance )
				continue
		}

		local dot = relTargetToPlayerDir.Dot( action.direction )

		//printt( "Dot: " + dot )

		if ( "minDot" in action )
		{
			if ( dot < action.minDot )
				continue
		}

		if ( dot > bestDot )
		{
			bestAction = action
			bestDot = dot
		}
	}

	return bestAction
}

//Function is necessary because melee trace on an enemy Titan will return the driveable,
//which is neither a player nor an NPC, hence we can't just do
//if (! (ent.IsPlayer() || ent.IsNPC()) return null else return ent.GetBodyType
function GetMeleeType( ent )
{
	if ( ent.IsPlayer() )
		return ent.GetBodyType()

	if ( ent.IsNPC() )
		return ent.GetBodyType()

	if ( ent.IsTitan() )
		return "titan"

	Assert( 0, "Unknown ent type" )
}

function GetMeleeActions( attacker, target )
{
	local attackerType = GetMeleeType( attacker )
	local targetType = GetMeleeType( target )

	if ( !( attackerType in level.allMeleeActions ) )
	{
		return null
	}

	if ( !( targetType in level.allMeleeActions[ attackerType ] ) )
	{
		return null
	}

	return level.allMeleeActions[ attackerType ][ targetType ]
}

function CodeCallback_OnMeleeAttackAnimEvent( player )
{
	Assert( IsValid( player ) )
	if ( player.PlayerMelee_IsAttackActive() )
	{
		if ( player.IsTitan() )
			TitanAttack( player )
		else if ( player.IsHuman() )
			HumanAttack( player )
	}

}

function CodeCallback_OnCustomActivityFinished( weapon, player, activity )
{
	if ( IsValid( player ) && player.PlayerMelee_IsAttackActive() )
	{
		//printt("Cleaning up melee")
		//Melee clean up.
		player.PlayerMelee_EndAttack()
		player.PlayerMelee_SetState( PLAYER_MELEE_STATE_NONE )

		if ( IsServer() )
			player.s.currentMeleeAttackTarget = null

	}
}

function CodeCallback_MeleeAttackLunge( player, playerForwardDir, playerVelocity, meleeLungeMode )
{
	local hitEnt =  player.PlayerMelee_GetAttackHitEntity()
	if ( IsValid( hitEnt ) )
	{
		//printt( "HitEnt" )
		//If you're a titan and you got hit recenlty by Titan damage, don't let melee bring you to a stop
		if ( player.IsTitan() )
		{
			if ( IsServer() )
			{
				if ( WasRecentlyHitForDamageType( player.GetTitanSoul(), damageTypes.TitanMelee, DAMAGE_BREAK_MELEE_TIME ) )
				{
					return playerVelocity
				}
			}
			else
			{
				if ( WasRecentlyHitForDamageType( player, damageTypes.TitanMelee, DAMAGE_BREAK_MELEE_TIME ) )
					return playerVelocity
			}

			local prevHit = IsValid( player.PlayerMelee_GetPrevAttackHitEntity() )

			if ( !prevHit )
			{
				return Vector( 0, 0, playerVelocity.z )
			}
			else
			{
				if ( hitEnt.IsTitan() )
				{
					// push the player backwards a bit to buffer from the enemy titan
					// needs to handle punching grunts differently, doesn't have that info currently
					local vel = Vector( playerForwardDir.x, playerForwardDir.y, 0 )

					local meleeState = player.PlayerMelee_GetState()
					switch ( meleeState )
					{
						case PLAYER_MELEE_STATE_TITAN_MELEE_JAB:
							return vel * -350

						case PLAYER_MELEE_STATE_TITAN_DASH_PUNCH:
							return vel * -150
					}

					return vel * -200
				}

			}
		}

		local prevHit = IsValid( player.PlayerMelee_GetPrevAttackHitEntity() )
		if ( !prevHit )
		{
			return Vector( 0, 0, playerVelocity.z )
		}
		else
		{
			return playerVelocity
		}

	}

	local meleeLungeSpeed = GetSettingsForPlayer_MeleeTable( player ).meleeLungeSpeed
	//printt( "lunging" )

	if ( meleeLungeMode == LUNGE_IGNORE )
	{
		local meleeState = player.PlayerMelee_GetState()
		switch ( meleeState )
		{
			case PLAYER_MELEE_STATE_TITAN_DASH_PUNCH: //Dash punch, so even if you're not hitting anything  give some significant forward momentum
			{
				local lungeDir = playerForwardDir

				local titanSoul = player.GetTitanSoul()
				local titanType = GetSoulTitanType( titanSoul )

				local lungeVel = lungeDir * meleeLungeSpeed

				local initialVelProportion = 0.078
				local finalVel = playerVelocity * initialVelProportion + lungeVel * ( 1.0 - initialVelProportion ) //Accelerates slightly into the punch as opposed to being at constant lunge speed.
				finalVel.z = playerVelocity.z //Don't make melee change whether you rise or fall
				//printt( "finalVel: " + finalVel + ", LUNGE_IGNORE, PLAYER_MELEE_STATE_TITAN_DASH_PUNCH" )
				return finalVel
			}

			//Note: Remember that human melee does that too
			case PLAYER_MELEE_STATE_TITAN_MELEE_JAB:
			default:
				return playerVelocity
		}
	}
	else if ( meleeLungeMode == LUNGE_FORWARD )
	{
		if ( player.IsTitan() )
		{
			if ( IsServer() )
			{
				if ( WasRecentlyHitForDamageType( player.GetTitanSoul(), damageTypes.TitanMelee, DAMAGE_BREAK_MELEE_TIME ) )
					return playerVelocity
			}
			else
			{
				if ( WasRecentlyHitForDamageType( player, damageTypes.TitanMelee, DAMAGE_BREAK_MELEE_TIME ) )
					return playerVelocity
			}

			meleeLungeSpeed = 500 //Lunge forward when hitting a human sized targe at the same speed regardless of chasis
		}

		local lungeDir = playerForwardDir
		local lungeVel = lungeDir * meleeLungeSpeed
		lungeVel.z = playerVelocity.z //Don't make melee change whether you rise or fall

		//printt( "lungeVel: " + lungeVel + ", LUNGE_FORWARD" )
		return lungeVel
	}
	else if ( meleeLungeMode == LUNGE_STOP )
	{
		//printt( "Lunge Stop" )
		return Vector( 0, 0, playerVelocity.z )
	}
	else
	{
		Assert( 0 ) // Unhandled lunge mode
	}
}

function PerformMeleeAttackTrace( player )
{
	local meleeState = player.PlayerMelee_GetState()
	switch ( meleeState )
	{
		case PLAYER_MELEE_STATE_HUMAN_KICK_ATTACK:
		{
			//If looking down, extend attack range slightly
			local range = AdjustDownwardKickRange( player )
			return PlayerMelee_AttackTrace( player, range, "CodeCallback_IsValidMeleeAttackTarget" )
		}

		case PLAYER_MELEE_STATE_TITAN_MELEE_JAB:
			return PlayerMelee_AttackTrace( player, 200, "CodeCallback_IsValidMeleeAttackTarget" )

		case PLAYER_MELEE_STATE_TITAN_DASH_PUNCH:
			return PlayerMelee_AttackTrace( player, 200, "CodeCallback_IsValidMeleeAttackTarget" )

		case PLAYER_MELEE_STATE_HUMAN_EXECUTION_PREDICTED:
		case PLAYER_MELEE_STATE_HUMAN_EXECUTION:
		case PLAYER_MELEE_STATE_TITAN_EXECUTION_PREDICTED:
		case PLAYER_MELEE_STATE_TITAN_EXECUTION:
			return null // In an execution right now, don't do an attack.

		default:
		{
			printt("***WARNING*** Unhandled Melee Attack Type: " + meleeState )
		}
	}
}
//Function calls Rumble effect multiple times
//to get a stronger rumble
function SetMeleeRumble( player )
{
	player.EndSignal( "OnDestroy" )
	for ( local i = 0; i < 5; ++i )
	{
		player.RumbleEffect( 6, 0, 4 )
		wait 0
	}
}

function MeleeInit( player )
{
	player.s.lastMeleeVictim <- null //Used to stop disable melee aim assist temporarily after getting meleed to avoid "bumper cars" melee. Set only after melee attack has successfully connected
	player.s.lastMeleeHitTime <- 0
	player.s.currentMeleeAttackTarget <- null //Used to stop Titans stepping on pilots/grunts while meleeing. Set immediately after aim assist decides on melee target
	AddAnimEvent( player, "screen_blackout", MeleeBlackoutScreen )
	//player.PlayerMelee_SetState( PLAYER_MELEE_STATE_NONE )
}

function MeleeBlackoutScreen( player )
{
	if ( IsServer() )
		ScreenFadeToBlack( player, 0.7, 1.2 )
}

function MarkForDeath( target )
{
	if ( target.IsNPC() )
	{
		//printt("Killing marked for death npc " + target )
		//Just kill off NPC now, otherwise it will play pain animations on death
		CodeCallback_OnMeleeKilled( target )
	}
	else
	{
		//printt("marking player " + target + " for death")
		target.s.markedForExecutionDeath <- true //This will kill off the player even if the execution animation is interruped from this point forward
	}
}

function ShouldMeleeDamage(entity)
{
	if ( entity.IsNPC() )
		return true

	if ( ObjectCanBeMeleed( entity ) )
		return true

	return false
}

function DecideTitanMeleeAttackType( player )
{
	if ( FrontDashMelee( player ) )
		return PLAYER_MELEE_STATE_TITAN_DASH_PUNCH

	return PLAYER_MELEE_STATE_TITAN_MELEE_JAB
}

function DecideHumanMeleeAttackType( player )
{
	//Just return kick for now
	return PLAYER_MELEE_STATE_HUMAN_KICK_ATTACK
}

function ShouldPlayerExecuteTarget( player, target )
{
	if ( player.IsTitan() )
	{
		if ( !target.IsTitan() )
			return false

		//NPC Titans don't get synced killed since our only animation for sync kill is ripping pilot out
		if ( target.IsNPC() )
		{
			if ( target.GetTitanSoul().GetStance() != STANCE_STAND )
				return false
		}

		if ( Flag( "ForceSyncedMelee" )  )
			return true

		return target.GetDoomedState()
	}

	if ( player.IsHuman() )
	{
		if ( !target.IsHumanSized() )
			return false

		if ( IsServer() && Flag( "ForceSyncedMelee" )  )
			return true

		//Only do execution if player is not moving at sprinting speed
		if ( target.GetVelocity().LengthSqr() > ( 40000 ) )
			return false
	}

	return true
}

function ClampVerticalVelocity( targetVelocity, maxVerticalVelocity )
{
	local clampedVelocity = targetVelocity
	if ( clampedVelocity.z > maxVerticalVelocity )
	{
		printt( "clampedVelocity.z: " + clampedVelocity.z +", maxVerticalVelocity:" + maxVerticalVelocity )
		clampedVelocity = Vector( targetVelocity.x, targetVelocity.y, maxVerticalVelocity )
	}

	return clampedVelocity
}
Globalize( ClampVerticalVelocity )


function TitanAttackHumanSized( titan, traceResult )
{
	if ( IsClient() )
	{
		thread SetMeleeRumble( titan )
		return
	}
	local angles = titan.EyeAngles()
	local scriptDmgType = damageTypes.TitanMelee

	if ( traceResult.entity.IsHuman() )
		scriptDmgType = damageTypes.TitanMeleePinkMist

	local hitEnt = traceResult.entity
	local damageAmount = hitEnt.GetMaxHealth() + 1

	local pushBackVelocity = angles.AnglesToForward() * 800

	local directionVector = hitEnt.GetOrigin() - titan.GetOrigin()
	if ( directionVector.Dot(pushBackVelocity) < 0)
	{
		pushBackVelocity = pushBackVelocity * -1
		//printt("Pushback velocity reversed!")
	}

	if ( hitEnt.IsPlayer() )
	{
		//Strip away rodeo protection by melee
		local titanBeingRodeoed = GetTitanBeingRodeoed( hitEnt )
		if ( IsValid( titanBeingRodeoed ) )
		{
			//printt( "DamageAmount in TitanAttackHumanSized: " + damageAmount )
			TakeAwayFriendlyRodeoPlayerProtection( titanBeingRodeoed )
		}
	}

	if ( hitEnt.IsNPC() )
	{
		 if ( !("silentDeath" in hitEnt.s ) ) //Stop grunts from screaming when gibbed due to titan melee attack
		 	hitEnt.s.silentDeath <- true
	}


	hitEnt.SetVelocity( hitEnt.GetVelocity() + pushBackVelocity )
	hitEnt.TakeDamage( damageAmount, titan, titan, { scriptType = scriptDmgType, forceKill = true, damageType = DMG_MELEE_ATTACK, damageSourceId = eDamageSourceId.titan_melee } )
}

function HumanAttackHumanSized( human, traceResult )
{
	if ( IsClient() )
	{
		return
	}
	local angles = human.EyeAngles()
	local scriptDmgType = damageTypes.HumanMelee
	local target = traceResult.entity
	human.PlayerMelee_SetAttackHitEntity( target )

	local damageAmount
	local pushBackVelocity //WARNING: HACKY! Should do something more physics based like add some kind of impulse instead of adding velocity

	local meleeType = human.PlayerMelee_GetState()
	switch ( meleeType )
	{
		case PLAYER_MELEE_STATE_HUMAN_KICK_ATTACK:
		{
			damageAmount = target.GetHealth() + 1
			break
		}

		default:
		{
			Assert( false, "Unknown human melee attack!" )
			break
		}
	}

	if ( target.IsPlayer() ) //Strip away rodeo protection
	{
		local titanBeingRodeoed = GetTitanBeingRodeoed( target )
		if ( IsValid( titanBeingRodeoed ) )
		{
			TakeAwayFriendlyRodeoPlayerProtection( titanBeingRodeoed )
		}
	}

	target.TakeDamage( damageAmount, human, human, { scriptType = scriptDmgType, damageType = DMG_MELEE_ATTACK, damageSourceId = eDamageSourceId.human_melee } )
}

function TitanAttackTitan( titan, traceResult )
{
	if ( IsClient() )
	{
		//Note to self: Once playerAsTitan is live, revisit this so that hit effects don't play
		// if you dont' actually deal damage. Problem is right now that Titan_Driveable doesn't exist on Client
		// so Client has no way to tell if the trace returned the titan or the player
		thread SetMeleeRumble( titan )
		return
	}

	local angles = titan.EyeAngles()

	local enemyTitan

	enemyTitan = traceResult.entity
	titan.PlayerMelee_SetAttackHitEntity( enemyTitan )

	if ( IsTitanWithinBubbleShield( enemyTitan ) )
		return

	//Detect if Simultaneous Melee occured
	if ( IsValid( enemyTitan ) && TargetHitMeFirst( enemyTitan, titan ) )
	{
		//Do nothing for now. Long run do some kind of superhero clash style both players bounce away thing?
		//printt("Simultaneous melee detected!")
	}

	local damageAmount = GetSettingsForPlayer_MeleeTable( titan ).meleeDamage //Player table, respects mods.
	//WARNING: HACKY! Should do something more physics based like add some kind of impulse instead of adding velocity
	local pushBackVelocity

	pushBackVelocity = angles.AnglesToForward() * GetSettingsForClass_MeleeTable( enemyTitan.GetPlayerSettings() ).meleePushback

	local dashPunch = titan.PlayerMelee_GetState() == PLAYER_MELEE_STATE_TITAN_DASH_PUNCH
	if ( dashPunch )
		pushBackVelocity *= 1.25


	//printt("Damage amount: " + damageAmount + " , pushBackVelocity: " + pushBackVelocity.LengthSqr() )
	local directionVector = enemyTitan.GetOrigin() - titan.GetOrigin()
	if ( directionVector.Dot( pushBackVelocity ) < 0 )
	{
		pushBackVelocity = pushBackVelocity * -1
		//printt("Pushback velocity reversed!")
	}

	//Push enemy back first before doing damage to get rid of some dependencies
	local targetVelocity

	targetVelocity = enemyTitan.GetVelocity()

	targetVelocity += pushBackVelocity

	// Put a floor on the targetVelocity: has to be at least 0.85 of the pushback velocity to be able to push back players far enough
	// so that their slow melee attack doesn't still connect after being hit by a fast melee.
	local clampRatio = 0.85
	if ( ShouldClampTargetVelocity( targetVelocity, pushBackVelocity, clampRatio ) )
	{
		targetVelocity = pushBackVelocity * clampRatio
	}

	targetVelocity += Vector(0,0,100 )
	targetVelocity = ClampVerticalVelocity( targetVelocity, TITAN_MELEE_MAX_VERTICAL_PUSHBACK  )

	if ( IsServer() )
	{
		enemyTitan.SetVelocity( targetVelocity )
		if ( enemyTitan.IsPlayer() && enemyTitan.PlayerMelee_IsAttackActive() )
		{
			enemyTitan.PlayerMelee_EndAttack()
			enemyTitan.PlayerMelee_SetState( PLAYER_MELEE_STATE_NONE )
			enemyTitan.s.currentMeleeAttackTarget = null
		}
	}

	local damageTable =
	{
		scriptType = damageTypes.TitanMelee
		forceKill = false
		damageType = DMG_MELEE_ATTACK
		damageSourceId = eDamageSourceId.titan_melee
	}

	titan.s.lastMeleeVictim = enemyTitan
	titan.s.lastMeleeHitTime = Time()
	//Temp Hack: Make NPC Titans die when you hit them in doomed state
	if ( enemyTitan.IsNPC() && enemyTitan.GetDoomedState() )
		damageAmount = enemyTitan.GetHealth() + 1
	enemyTitan.TakeDamage( damageAmount, titan, titan, damageTable )

	if ( dashPunch && CodeCallback_IsValidMeleeExecutionTarget( titan, enemyTitan ) )
	{
		thread AttemptScriptedExecution( titan, enemyTitan )
	}
}

function TryExplosivePunch( titan, position, hasBigPunchMod = false )
{
	if ( IsClient() )
		return

	local player
	if ( titan.IsPlayer() )
		player = titan
	else
		player = titan.GetBossPlayer()

	if ( IsValid( player ) && PlayerHasServerFlag( player, SFLAG_BC_EXPLOSIVE_PUNCH ) )
	{
		if ( hasBigPunchMod )
			CreateExplosion( position, 800, 800, 400, 400, titan, 0.0, "Weapon_ElectricSmokeScreen.Explosion", eDamageSourceId.titan_melee, false, BC_EXPLOSIVE_BIG_PUNCH_FX_TABLE )
		else
			CreateExplosion( position, 400, 400, 300, 300, titan, 0.0, "Weapon_ElectricSmokeScreen.Explosion", eDamageSourceId.titan_melee, false, BC_EXPLOSIVE_PUNCH_FX_TABLE )
	}
}

function DelayedHolster( player )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "Disconnected" )
	local titanType = GetSoulTitanType( player.GetTitanSoul() )
	local delay
	switch ( titanType )
	{
		case "ogre":
			delay = 0.54
			break
		default:
			delay = 0.35
	}
	wait delay
	player.HolsterWeapon()
}

function TitanAttackDefault( titan, traceResult )
{
	if ( IsClient() )
	{
		thread SetMeleeRumble( titan )
		return
	}

	local damageAmount = GetSettingsForPlayer_MeleeTable( titan ).meleeDamage //Player table, respects mods.
	//No push back: 2 examples of things we hit with this function are dropships and turrets,
	//none of which should be pushed back.

	local damageTable =
	{
		scriptType = damageTypes.TitanMelee
		forceKill = false
		damageType = DMG_MELEE_ATTACK
		damageSourceId = eDamageSourceId.titan_melee
	}
	traceResult.entity.TakeDamage( damageAmount, titan, titan, damageTable )
	titan.PlayerMelee_SetAttackHitEntity( traceResult.entity )
}

function IsPlayerTitanAttackerMeleeingVictim( attacker, victim )
{
	if ( !attacker.IsTitan() )
		return false

	if ( !IsPlayer( attacker ) )
		return false

	return attacker.s.currentMeleeAttackTarget == victim
}

function CheckVerticallyCloseEnough( attacker, target )
{
	local attackerOrigin = attacker.GetOrigin()
	local targetOrigin = target.GetOrigin()

	local verticalDistance = abs( attackerOrigin.z - targetOrigin.z )
	local halfHeight = 0

	if ( attacker.IsTitan() )
		halfHeight = 92.5
	else if ( attacker.IsHuman() )
		halfHeight = 30

	Assert( halfHeight, "Attacker is neither Titan nor Human" )

	//printt( "vertical distance: " + verticalDistance )
	return verticalDistance < halfHeight

}

function AdjustDownwardKickRange( player ) //If looking down, extend attack range slightly
{
	local range = HUMAN_KICK_MELEE_ATTACK_RANGE
	local eyeAngles = player.EyeAngles()
	if ( eyeAngles.x > 45 )
	{
		range = GraphCapped( eyeAngles.x, 45, 90, HUMAN_KICK_MELEE_ATTACK_RANGE, HUMAN_KICK_MELEE_ATTACK_MAX_DOWNWARDS_RANGE )
		//printt( "Kick range is: " + range )
	}

	return range
}

