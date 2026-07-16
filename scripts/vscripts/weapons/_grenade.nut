const DEFAULT_FUSE_TIME = 2.55
const DEFAULT_WARNING_TIME = 0.5
const GRENADE_EXPLOSIVE_WARNING_SFX_LOOP = "Weapon_Vortex_Gun.ExplosiveWarningBeep"

const EMP_GRENADE_BEAM_EFFECT	= "wpn_arc_cannon_beam"
const FX_EMP_BODY_TITAN			= "P_emp_body_titan"
const FX_EMP_BODY_HUMAN			= "P_emp_body_human"

const LASERMINE_SFX_ACTIVATE	= "Weapon_R1_LaserMine.Activate"
const LASERMINE_SFX_DEACTIVATE	= "Weapon_R1_LaserMine.Deactivate"

const LASERMINE_ATTACHPOINT = "REF"
const EMP_MAGNETIC_FORCE	= 1600
const MAG_FLIGHT_SFX_LOOP = "Explo_MGL_MagneticAttract"

//Proximity Mine Settings
const PROXIMITY_MINE_EXPLOSION_DELAY = 0.7
const PROXIMITY_MINE_ARMING_DELAY = 1.0
const TRIGGERED_ALARM_SFX = "Weapon_ProximityMine_CloseWarning"

PrecacheParticleSystem( EMP_GRENADE_BEAM_EFFECT )
PrecacheParticleSystem( FX_EMP_BODY_TITAN )
PrecacheParticleSystem( FX_EMP_BODY_HUMAN )


if ( !reloadingScripts )
{
	level.proximityTargetClassnames <- {}
	level.proximityTargetClassnames[ "npc_soldier_shield" ]	<- true
	level.proximityTargetClassnames[ "npc_soldier_heavy" ] 	<- true
	level.proximityTargetClassnames[ "npc_soldier" ] 		<- true
	level.proximityTargetClassnames[ "npc_spectre" ] 		<- true
	level.proximityTargetClassnames[ "npc_cscanner" ] 		<- true
	level.proximityTargetClassnames[ "npc_titan" ] 			<- true
	level.proximityTargetClassnames[ "npc_marvin" ] 		<- true
	level.proximityTargetClassnames[ "player" ] 			<- true
	level.proximityTargetClassnames[ "npc_turret_mega" ]	<- true
	level.proximityTargetClassnames[ "npc_turret_sentry" ]	<- true
	level.proximityTargetClassnames[ "npc_dropship" ]		<- true
}


RegisterSignal( "ThrowGrenade" )
RegisterSignal( "WeaponDeactivateEvent" )
RegisterSignal(	"OnEMPPilotHit" )
RegisterSignal( "StopGrenadeClientEffects" )
RegisterSignal( "DisableTrapWarningSound" )

function main()
{
	Globalize( Grenade_Deploy )
	Globalize( Grenade_Throw )
	Globalize( Grenade_Deactivate )
	Globalize( EMPGrenade_DamagedPlayerOrNPC )
	Globalize( LaserMine_Disable )
	Globalize( LaserMine_Enable )
	Globalize( LaserMine_DeactivateAndKill )
	Globalize( LaserMine_GetEndPointInfo )
	Globalize( PlayerTrackLaserMine )
	Globalize( PlayerUnTrackLaserMine )
	Globalize( CleanupPlayerLaserMines )
	Globalize( Grenade_Init )
	Globalize( LaserMine_StartClientEffects )
	Globalize( LaserMine_StopClientEffects )
	Globalize( AddToLaserMines )
	Globalize( DisplayEnemyLaserMines )
	Globalize( HideEnemyLaserMines )
	Globalize( EnableTrapWarningSound )
	Globalize( AddToProximityTargets )
	Globalize( ProximityMineThink )
	//Globalize( MagneticFlight )

	level._laserMines <- {}

	if ( IsClient() )
	{
		AddDestroyCallback( "npc_grenade_frag", ClientDestroyCallback_GrenadeDestroyed )
	}

	if ( IsServer() )
	{
		level._empForcedCallbacks <- {}
		level._proximityTargetArrayID <- CreateScriptManagedEntArray()

		AddDamageCallbackSourceID( eDamageSourceId.mp_weapon_grenade_emp, EMPGrenade_DamagedPlayerOrNPC )
		AddDamageCallbackSourceID( eDamageSourceId.mp_weapon_proximity_mine, EMPGrenade_DamagedPlayerOrNPC )
		AddDamageCallbackSourceID( eDamageSourceId.mp_ability_emp, EMPGrenade_DamagedPlayerOrNPC )

		level._empForcedCallbacks[eDamageSourceId.mp_weapon_grenade_emp] <- true
		level._empForcedCallbacks[eDamageSourceId.mp_weapon_proximity_mine] <- true
		level._empForcedCallbacks[eDamageSourceId.mp_ability_emp] <- true

		AddDamageCallbackSourceID( eDamageSourceId.mp_titanweapon_triple_threat, TripleThreatGrenade_DamagedPlayerOrNPC )
		AddDamageCallbackSourceID( eDamageSourceId.mp_weapon_defender, Defender_DamagedPlayerOrNPC )
		AddDamageCallbackSourceID( eDamageSourceId.mp_titanweapon_rocket_launcher, TitanRocketLauncher_DamagedPlayerOrNPC )
		AddDamageCallbackSourceID( eDamageSourceId.mp_weapon_smr, SMR_DamagedPlayerOrNPC )
		AddDamageCallbackSourceID( eDamageSourceId.mp_titanability_smoke, ElectricSmoke_DamagedPlayerOrNPC )
		AddDamageCallbackSourceID( eDamageSourceId.mp_weapon_mega4, Defender_DamagedPlayerOrNPC )

		AddDeathCallback( "npc_grenade_frag", ServerDeathCallback_GrenadeDeath )
	}
}

function AddToLaserMines( ent )
{
	level._laserMines[ ent ] <- ent
	LaserMine_Init( ent )
}

function Grenade_Deploy( weapon, deployParams, baseFuseTime = DEFAULT_FUSE_TIME )
{
	if ( !( "startTime" in weapon.s ) )
		weapon.s.startTime <- null
	weapon.s.startTime = Time()

	local weaponOwner = weapon.GetWeaponOwner()

	if ( IsServer() )
	{
		thread CookGrenade( weapon, weaponOwner, baseFuseTime )
		thread DropGrenadeOnDeath( weapon, weaponOwner, baseFuseTime)
	}
}

function Grenade_Deactivate( weapon, deactivateParams )
{
	if ( "warningSoundTriggered" in weapon.s && weapon.s.warningSoundTriggered == true )
		StopSoundOnEntity( weapon, GRENADE_EXPLOSIVE_WARNING_SFX_LOOP )
	local weaponOwner = weapon.GetWeaponOwner()
	if( IsValid( weaponOwner ) && IsAlive( weaponOwner ) )
		weapon.Signal("WeaponDeactivateEvent")
}

function Grenade_Init( grenade, weapon )
{
	Assert( IsServer() )
	local weaponOwner = weapon.GetOwner()
	grenade.SetTeam( weaponOwner.GetTeam() )
	grenade.s.bounceNormal <- Vector( 0, 0, 0 )
	grenade.SetDamageNotifications( true )
	grenade.s.ignoreFootstepDamage <- true
	grenade.s.preventOwnerDamage <- false
	grenade.s.onlyAllowSmartPistolDamage <- true
	grenade.s.originalOwner <- weaponOwner  // for later in damage callbacks, to skip damage vs friendlies but not for og owner or his enemies
	grenade.s.planted <- false

	grenade.s.explodeBounceCount <- 0
	grenade.s.surfaceBounceNormal <- null
	grenade.s.bounceTime <- Time()
}

function Grenade_Throw( weapon, attackParams, baseFuseTime = DEFAULT_FUSE_TIME )
{
	if ( IsClient() && !weapon.ShouldPredictProjectiles() )
		return

	//TEMP FIX while Deploy anim is added to sprint
	if ( !( "startTime" in weapon.s ) )
		weapon.s.startTime <- Time()

	local weaponOwner = weapon.GetWeaponOwner()
	local attackAngles = attackParams.dir.GetAngles()
	attackAngles.x -= 5
	local forward = attackAngles.AnglesToForward()
	local velocity = (forward) * 1500
	local angularVelocity = Vector( 3600, RandomFloat( -1200, 1200 ), 0 )
	local fuseTime = baseFuseTime - ( Time() - weapon.s.startTime )

	if ( fuseTime <= 0 )
		return 0


	local frag = weapon.FireWeaponGrenade( attackParams.pos, velocity, angularVelocity, fuseTime, damageTypes.Explosive, damageTypes.Explosive, PROJECTILE_PREDICTED, true, true )

	if ( frag )
	{
		if ( IsServer() )
		{
			Grenade_Init( frag, weapon )
			thread TrapExplodeOnDamage( frag, 20, 0.0, 0.0 )
			//thread MagneticFlight( frag )
		}
		else
		{
			frag.SetTeam( weaponOwner.GetTeam()	)
		}

		if( weapon.HasModDefined( "burn_mod_emp_grenade" ) && weapon.HasMod( "burn_mod_emp_grenade" ) )
			frag.InitMagnetic( EMP_MAGNETIC_FORCE, MAG_FLIGHT_SFX_LOOP )
	}

	weaponOwner.Signal("ThrowGrenade")
}

function CookGrenade( weapon, weaponOwner, fuseTime )
{
	weaponOwner.EndSignal( "OnDeath" )
	weaponOwner.EndSignal( "ThrowGrenade" )
	weaponOwner.EndSignal( "Disconnected" )
	weapon.EndSignal( "WeaponDeactivateEvent" )
	weapon.EndSignal( "OnDestroy" )

	Assert( (fuseTime - DEFAULT_WARNING_TIME) > 0 )

	wait( fuseTime - DEFAULT_WARNING_TIME )

	if ( !IsValid( weapon ) || !IsValid( weapon.GetWeaponOwner() ) )
		return

	EmitSoundOnEntity( weapon, GRENADE_EXPLOSIVE_WARNING_SFX_LOOP )

	if ( !( "warningSoundTriggered" in weapon.s ) )
		weapon.s.warningSoundTriggered <- null
	weapon.s.warningSoundTriggered = true

	wait( DEFAULT_WARNING_TIME )

	if ( !IsValid( weapon ) || !IsValid( weapon.GetWeaponOwner() ) )
		return

	weapon.ForceRelease()

	local velocity = Vector( 0, 0, 0 )
	local angularVelocity = Vector( 0, 0, 0 )
	local frag = weapon.FireWeaponGrenade( weapon.GetOrigin(), velocity, angularVelocity, 0.1, damageTypes.Explosive, damageTypes.Explosive, PROJECTILE_NOT_PREDICTED, false, false )
	frag.SetOrigin( weaponOwner.GetOrigin() + Vector( 0, 0, 50 ) )
	frag.Explode( Vector( 0, 0, 0 ) )
	weaponOwner.Signal("ThrowGrenade")
}

function DropGrenadeOnDeath( weapon, weaponOwner, baseFuseTime = DEFAULT_FUSE_TIME )
{
	weaponOwner.EndSignal( "ThrowGrenade" )
	weaponOwner.EndSignal( "Disconnected" )
	weapon.EndSignal( "WeaponDeactivateEvent" )

	weaponOwner.WaitSignal( "OnDeath" )

	if( !IsValid( weaponOwner ) || !IsValid( weapon ) || IsAlive( weaponOwner ) )
		return

	local elapsedTime = Time() - weapon.s.startTime
	if ( baseFuseTime > elapsedTime )
	{
		local velocity = weaponOwner.GetForwardVector() * 10 + Vector( 0, 0, 10 )
		local angularVelocity = Vector( 0, 0, 0 )
		local fuseTime = DEFAULT_FUSE_TIME - elapsedTime
		local frag = weapon.FireWeaponGrenade( weaponOwner.GetOrigin(), velocity, angularVelocity, fuseTime, damageTypes.Explosive, damageTypes.Explosive, PROJECTILE_NOT_PREDICTED, false, false )

		if ( IsServer() )
		{
			Grenade_Init( frag, weapon )
			thread TrapExplodeOnDamage( frag, 20, 0.0, 0.0 )
		}
		else
		{
			frag.SetTeam( weaponOwner.GetTeam() )
		}
		if ( weapon.HasModDefined( "burn_mod_emp_grenade" ) && weapon.HasMod( "burn_mod_emp_grenade" ) )
			frag.InitMagnetic( EMP_MAGNETIC_FORCE, MAG_FLIGHT_SFX_LOOP )
	}
}


function TripleThreatGrenade_DamagedPlayerOrNPC( ent, damageInfo )
{
	if ( !IsValid( ent ) )
		return

	if ( ent.GetClassname() == "npc_grenade_frag" )
		return

	if ( damageInfo.GetCustomDamageType() & DF_DOOMED_HEALTH_LOSS )
		return

	local damagePosition = damageInfo.GetDamagePosition()

	local entOrigin = ent.GetOrigin()
	local distanceToOrigin = Distance( ent.GetOrigin(), damagePosition )
	local entCenter = ent.GetWorldSpaceCenter()
	local distanceToCenter = Distance( ent.GetCenter(), damagePosition )


	local normal = Vector( 0, 0, 1 )
	local inflictor = damageInfo.GetInflictor()
	if ( IsValid( inflictor.s ) )
	{
		if ( "collisionNormal" in inflictor.s )
			normal = inflictor.s.collisionNormal
	}

	local zDifferenceOrigin = deg_cos( DegreesToTarget( entOrigin, normal, damagePosition ) ) * distanceToOrigin
	local zDifferenceTop = deg_cos( DegreesToTarget( entCenter, normal, damagePosition ) ) * distanceToCenter - (entCenter.z - entOrigin.z)

	local zDamageDiff
	//Full damage if explosion is between Origin or Center.
	if ( zDifferenceOrigin > 0 && zDifferenceTop < 0 )
		zDamageDiff = 1.0
	else if ( zDifferenceTop > 0 )
		zDamageDiff = GraphCapped( zDifferenceTop, 0.0, 32.0, 1.0, 0.0 )
	else
		zDamageDiff = GraphCapped( zDifferenceOrigin, 0.0, -32.0, 1.0, 0.0 )

	damageInfo.SetDamage( damageInfo.GetDamage() * zDamageDiff )
}


function Defender_DamagedPlayerOrNPC( ent, damageInfo )
{
	if ( !IsValid( ent ) )
		return

	if ( damageInfo.GetCustomDamageType() & DF_DOOMED_HEALTH_LOSS )
		return

	local damagePosition = damageInfo.GetDamagePosition()

	local damage = Vortex_HandleElectricDamage( ent, damageInfo.GetAttacker(), damageInfo.GetDamage(), damageInfo.GetDamageSourceIdentifier(), damageInfo.GetWeapon() )
	damageInfo.SetDamage( damage )
}

function TitanRocketLauncher_DamagedPlayerOrNPC( ent, damageInfo )
{
	if ( !IsValid( ent ) )
		return

	if ( damageInfo.GetCustomDamageType() & DF_DOOMED_HEALTH_LOSS )
		return

	local damagePosition = damageInfo.GetDamagePosition()

	if ( ent == damageInfo.GetAttacker() )
		return

	// TEMP cause this fails
	if ( !( "titanRocketLauncherTitanDamageRadius" in file ) )
	{
		local innerRadius = GetWeaponInfoFileKeyField_Global( "mp_titanweapon_rocket_launcher", "explosion_inner_radius" )
		local outerRadius = GetWeaponInfoFileKeyField_Global( "mp_titanweapon_rocket_launcher", "explosionradius" )

		file.titanRocketLauncherTitanDamageRadius <- innerRadius + ((outerRadius - innerRadius) * 0.4)
		file.titanRocketLauncherOtherDamageRadius <- innerRadius + ((outerRadius - innerRadius) * 0.1)
	}

	if ( ent.IsTitan() )
	{
		if ( Distance( damagePosition, ent.GetOrigin() ) > file.titanRocketLauncherTitanDamageRadius )
			damageInfo.SetDamage( 0 )
	}
	else if ( ent.IsHumanSized() )
	{
		if ( Distance( damagePosition, ent.GetOrigin() ) > file.titanRocketLauncherOtherDamageRadius )
			damageInfo.SetDamage( 0 )
	}
}

function EMPGrenade_DamagedPlayerOrNPC( ent, damageInfo )
{
	if ( !IsValid( ent ) )
		return

	if ( damageInfo.GetCustomDamageType() & DF_DOOMED_HEALTH_LOSS )
		return

	local inflictor = damageInfo.GetInflictor()
	if( !IsValid( inflictor ) )
		return

	if ( !( inflictor instanceof CBaseGrenade || inflictor instanceof CEnvExplosion ) )
		return

	// Do electrical effect on this ent that everyone can see if they are a titan
	local tag = null
	local effect = null

	if ( ent.IsTitan() )
	{
		tag = "exp_torso_front"
		effect = FX_EMP_BODY_TITAN
	}
	else if ( ent.IsSpectre() )
	{
		tag = "CHESTFOCUS"
		effect = FX_EMP_BODY_HUMAN
		if ( !ent.ContextAction_IsActive() && IsAlive( ent ) && ent.IsInterruptable() )
			ent.Anim_Play( "pt_reboot"  )
	}
	else if ( IsPilot( ent ) )
	{
		tag = "CHESTFOCUS"
		effect = FX_EMP_BODY_HUMAN
	}

	if ( tag != null )
	{
		local inflictor = damageInfo.GetInflictor()
		if ( IsValid( inflictor ) && ( inflictor instanceof CBaseGrenade || inflictor instanceof CEnvExplosion ) )
		{
			local dist = Distance( damageInfo.GetDamagePosition(), ent.GetWorldSpaceCenter() )
			local damageRadius = inflictor.GetDamageRadius()
			local frac = GraphCapped( dist, damageRadius * 0.5, damageRadius, 1.0, 0.0 )
			local duration = EMP_GRENADE_PILOT_SCREEN_EFFECTS_DURATION_MIN + ( ( EMP_GRENADE_PILOT_SCREEN_EFFECTS_DURATION_MAX - EMP_GRENADE_PILOT_SCREEN_EFFECTS_DURATION_MIN ) * frac )
			duration += EMP_GRENADE_PILOT_SCREEN_EFFECTS_FADE * 0.75	// add a little bit of the fadeout since player is still experiencing some screen effects

			thread EMPGrenade_FX( effect, ent, tag, duration )
		}
	}

	// Don't do arc beams to entities that are on the same team... except the owner
	local attacker = damageInfo.GetAttacker()
	if ( IsValid( attacker ) && attacker.GetTeam() == ent.GetTeam() && attacker != ent )
		return

	if ( ent.IsPlayer() )
	{
		thread EMPGrenade_EffectsPlayer( ent, damageInfo )
	}
	else if ( ent.IsTitan() )
	{
		EMPGrenade_AffectsShield( ent, damageInfo )
		thread EMPGrenade_AffectsAccuracy( ent )
	}

	if ( !ent.IsPlayer() || ent.IsTitan() ) //Beam should hit cloaked targets, when cloak is updated make IsCloaked() function.
		EMPGrenade_ArcBeam( damageInfo.GetDamagePosition(), ent )
}

function EMPGrenade_FX( effect, ent, tag, duration )
{
	if ( !IsAlive( ent ) )
		return

	ent.EndSignal( "OnDestroy" )
	ent.EndSignal( "OnDeath" )

	local fxHandle = ClientStylePlayFXOnEntity( effect, ent, tag, duration )
	if ( ent.IsPlayer() )
		EmitSoundOnEntityExceptToPlayer( ent, ent, "Titan_Blue_Electricity_Cloud" )
	else
		EmitSoundOnEntity( ent, "Titan_Blue_Electricity_Cloud" )

	OnThreadEnd(
		function() : ( fxHandle, ent )
		{
			if ( IsValid( fxHandle ) )
				fxHandle.Fire( "StopPlayEndCap" )
			if ( IsValid ( ent ) )
				StopSoundOnEntity( ent, "Titan_Blue_Electricity_Cloud" )
		}
	)

	wait duration
}

function EMPGrenade_AffectsShield( titan, damageInfo )
{
	local shieldHealth = titan.GetTitanSoul().GetShieldHealth()
	local shieldDamage = titan.GetTitanSoul().GetShieldHealthMax() * 0.5

	titan.GetTitanSoul().SetShieldHealth( max( 0, shieldHealth - shieldDamage ) )

	// attacker took down titan shields
	if ( shieldHealth && !titan.GetTitanSoul().GetShieldHealth() )
	{
		local attacker = damageInfo.GetAttacker()
		if ( attacker && attacker.IsPlayer() )
			EmitSoundOnEntityOnlyToPlayer( attacker, attacker, "titan_energyshield_down" )
	}
}

function EMPGrenade_AffectsAccuracy( npcTitan )
{
	npcTitan.EndSignal( "OnDestroy" )

	npcTitan.kv.AccuracyMultiplier = 0.5
	wait EMP_GRENADE_PILOT_SCREEN_EFFECTS_DURATION_MAX
	npcTitan.kv.AccuracyMultiplier = 1.0
}

function EMPGrenade_EffectsPlayer( player, damageInfo )
{
	player.Signal( "OnEMPPilotHit" )
	player.EndSignal( "OnEMPPilotHit" )

	local inflictor = damageInfo.GetInflictor()
	local dist = Distance( damageInfo.GetDamagePosition(), player.GetWorldSpaceCenter() )
	local damageRadius = inflictor.GetDamageRadius()
	local frac = GraphCapped( dist, damageRadius * 0.5, damageRadius, 1.0, 0.0 )
	local duration = EMP_GRENADE_PILOT_SCREEN_EFFECTS_DURATION_MIN + ( ( EMP_GRENADE_PILOT_SCREEN_EFFECTS_DURATION_MAX - EMP_GRENADE_PILOT_SCREEN_EFFECTS_DURATION_MIN ) * frac )
	local strength = EMP_GRENADE_PILOT_SCREEN_EFFECTS_MIN + ( ( EMP_GRENADE_PILOT_SCREEN_EFFECTS_MAX - EMP_GRENADE_PILOT_SCREEN_EFFECTS_MIN ) * frac )
	local fadeoutDuration = EMP_GRENADE_PILOT_SCREEN_EFFECTS_FADE * frac
	local origin = inflictor.GetOrigin()

	if ( player.IsTitan() )
	{
		// Hit player should do EMP screen effects locally
		Remote.CallFunction_Replay( player, "ServerCallback_TitanCockpitEMP", EMP_GRENADE_SCREEN_EFFECTS_DURATION )

		EMPGrenade_AffectsShield( player, damageInfo )

		Remote.CallFunction_Replay( player, "ServerCallback_TitanEMP", strength, duration, fadeoutDuration )

		local duration = GraphCapped( frac, 0.0, 1.0, EMP_GRENADE_SLOW_DURATION_MIN, EMP_GRENADE_SLOW_DURATION_MAX )
		local scale = GraphCapped( frac, 0.0, 1.0, EMP_GRENADE_SLOW_SCALE_MIN, EMP_GRENADE_SLOW_SCALE_MAX )
		thread EMP_SlowPlayer( player, scale, duration )
	}
	else
	{
		local damageMin
		local damageMax
		if ( damageInfo.GetDamageSourceIdentifier() == eDamageSourceId.mp_weapon_proximity_mine )
		{
			damageMin = PROX_MINE_PILOT_DAMAGE_MIN
			damageMax = PROX_MINE_PILOT_DAMAGE_MAX
		}
		else
		{
			damageMin = EMP_GRENADE_PILOT_DAMAGE_MIN
			damageMax = EMP_GRENADE_PILOT_DAMAGE_MAX
		}

		local damage = GraphCapped( dist, damageRadius * 0.5, damageRadius, damageMax, damageMin )
		damageInfo.SetDamage( damage )

		if ( IsCloaked( player ) )
			player.SetCloakFlicker( 0.5, duration )

		Remote.CallFunction_Replay( player, "ServerCallback_PilotEMP", strength, duration, fadeoutDuration )
	}
}

function EMPGrenade_ArcBeam( grenadePos, ent)
{
	Assert( IsValid( ent ) )
	local lifeDuration = 0.5

	// Control point sets the end position of the effect
	local cpEnd = CreateEntity( "info_placement_helper" )
	cpEnd.SetName( UniqueString( "emp_grenade_beam_cpEnd" ) )
	cpEnd.SetOrigin( grenadePos )
	DispatchSpawn( cpEnd, false )

	local zapBeam = CreateEntity( "info_particle_system" )
	zapBeam.kv.cpoint1 = cpEnd.GetName()
	zapBeam.kv.effect_name = EMP_GRENADE_BEAM_EFFECT
	zapBeam.kv.start_active = 0
	zapBeam.SetOrigin( ent.GetWorldSpaceCenter() )
	if ( !ent.IsMarkedForDeletion() ) // TODO: This is a hack for shipping. Should not be parenting to deleted entities
	{
		zapBeam.SetParent( ent, "", true, 0.0 )
	}

	DispatchSpawn( zapBeam )

	zapBeam.Fire( "Start" )
	zapBeam.Fire( "StopPlayEndCap", "", lifeDuration )
	zapBeam.Kill( lifeDuration )
	cpEnd.Kill( lifeDuration )
}

function EMPLaserMine( mine )
{
	mine.EndSignal( "OnDestroy" )

	LaserMine_Disable( mine )
	wait EMP_GRENADE_SCREEN_EFFECTS_DURATION
	thread LaserMine_Enable( mine )
}

function LaserMine_Disable( mine )
{
	if ( !IsValid( mine ) )
		return

	mine.Signal( "DisableTrapWarningSound" )
	mine.nv.armed = false
}

function LaserMine_Enable( mine )
{
	if ( !IsValid( mine ) )
		return

	thread EnableTrapWarningSound( mine )
//	mine.nv.armed = true
}

// handles enabling/disabling "grenade" (thrown) weapons, for example when they get disabled via EMP
function VarChangeCallback_GrenadeActiveStatusChanged( grenade )
{
	//grenade.nv.armed ? printt( "enabling grenade" ) : printt( "disabling grenade" )

	if ( grenade.GetWeaponClassName() == "mp_weapon_laser_mine" )
	{
		StopSoundOnEntity( grenade, LASERMINE_SFX_ACTIVATE )
		StopSoundOnEntity( grenade, LASERMINE_SFX_DEACTIVATE )

//		if ( grenade.nv.armed )
//		{
//			EmitSoundOnEntity( grenade, LASERMINE_SFX_ACTIVATE )
//			LaserMine_StartClientEffects( grenade )
//			thread LaserMine_UpdateClientEffects( grenade )
//		}
//		else
		{
			EmitSoundOnEntity( grenade, LASERMINE_SFX_DEACTIVATE )
			LaserMine_StopClientEffects( grenade, false )
		}
	}
}

// moves the end point around as the mine moves
function LaserMine_UpdateClientEffects( mine )
{
	Assert( IsClient() )
	Assert( "laserbeamFXHandle" in mine.s )

	mine.EndSignal( "StopGrenadeClientEffects" )
	mine.EndSignal( "OnDestroy" )

	local lastOrigin = mine.GetOrigin()

	while ( 1 )
	{
		wait 0

		if ( mine.GetOrigin() == lastOrigin )
			continue

		local endPointInfo = LaserMine_GetEndPointInfo( mine)
		local traceResult = endPointInfo.traceResult
		local endPointOrg = endPointInfo.endPointOrg

		EffectSetControlPointVector( mine.s.laserbeamFXHandle, 2, endPointOrg )

		/* TODO UNCOMMENT WHEN StartParticleEffectOnEntityWithPos ATTACHES WITH AN OFFSET
		// need to move the end point effect as well
		if ( traceResult < 1.0 )
		{
			if ( mine.s.laserbeamEndPointFXHandle )
				EffectStop( mine.s.laserbeamEndPointFXHandle, true, true )

			LaserMine_CreateBeamEndPointEffect( mine, endPointOrg )
		}
		*/
	}
}

function LaserMine_StartClientEffects( mine )
{
	Assert( IsClient() )

	local player = GetLocalViewPlayer()

	//Removing existing laser mines Fx until I can figure out what's causing this to be triggered twice before a StopClient is called.
	LaserMine_RemoveFx( mine )

	local attachID = mine.LookupAttachment( LASERMINE_ATTACHPOINT )

	// blinking light FX
	local handle_blinkylight = StartParticleEffectOnEntity( mine, GetParticleSystemIndex( "wpn_laser_blink" ), FX_PATTACH_POINT_FOLLOW, attachID )
	local color
	if ( player.GetTeam() == mine.GetTeam() )
		color = FRIENDLY_COLOR_FX
	else
		color = ENEMY_COLOR_FX

	local colorVec = Vector( color[0], color[1], color[2] )

	EffectSetControlPointVector( handle_blinkylight, 1, colorVec )

	local endPointInfo = LaserMine_GetEndPointInfo( mine)
	local traceResult = endPointInfo.traceResult
	local endPointOrg = endPointInfo.endPointOrg

	// laser beam FX
	local handle_laserbeam = StartParticleEffectOnEntity( mine, GetParticleSystemIndex( "wpn_laser_beam" ), FX_PATTACH_POINT_FOLLOW, attachID )
	EffectSetControlPointVector( handle_laserbeam, 2, endPointOrg )  // worldspace location of the laser beam end point
	mine.s.grenadeEffectHandles.append( handle_laserbeam )
	mine.s.laserbeamFXHandle = handle_laserbeam

	// only add end point effect if the laser intersects with something
	local handle_beamEnd = null
	if ( traceResult < 1.0 )
		LaserMine_CreateBeamEndPointEffect( mine, endPointOrg )

//	if ( player.GetTeam() != mine.GetTeam() )
//	{
//		if ( !IsCloaked( player ) && !PlayerHasEnhancement( player, "en_advanced_optics" ) )
//			return
//	}

	foreach ( effectHandle in mine.s.grenadeEffectHandles )
		EffectSetControlPointVector( effectHandle, 1, colorVec )
}

function LaserMine_RemoveFx( mine )
{
	foreach ( effectHandle in mine.s.grenadeEffectHandles )
		if ( EffectDoesExist( effectHandle ) )
			  EffectStop( effectHandle, true, true )
	if ( ( "laserbeamFXHandle" in mine.s ) && mine.s.laserbeamFXHandle != null )
	{
		if ( EffectDoesExist( mine.s.laserbeamFXHandle ) )
			EffectStop( mine.s.laserbeamFXHandle, true, true )
	}
	if ( ( "laserbeamEndPointFXHandle" in mine.s ) && mine.s.laserbeamEndPointFXHandle != null )
	{
		if ( EffectDoesExist( mine.s.laserbeamEndPointFXHandle ) )
			EffectStop( mine.s.laserbeamEndPointFXHandle, true, true )
	}
}

function LaserMine_CreateBeamEndPointEffect( mine, endPointOrg )
{
	Assert( IsClient() )

	local attachID = mine.LookupAttachment( LASERMINE_ATTACHPOINT )

	// HACK code bug preventing it from working
	local fxAttachType = FX_PATTACH_POINT_FOLLOW
	if ( GetBugReproNum() == 20891 )
		fxAttachType = FX_PATTACH_CUSTOMORIGIN_FOLLOW

	local handle_beamEnd = StartParticleEffectOnEntityWithPos( mine, GetParticleSystemIndex( "wpn_laser_end"), fxAttachType, attachID, endPointOrg, Vector( 0, 0, 0 ) )
	mine.s.grenadeEffectHandles.append( handle_beamEnd )  // add it to the array to be cleaned up later

	if ( !( "laserbeamEndPointFXHandle" in mine.s ) )
		mine.s.laserbeamEndPointFXHandle <- null

	mine.s.laserbeamEndPointFXHandle = handle_beamEnd
}

function LaserMine_StopClientEffects( mine, hideOnlyFromEnemies )
{
	Assert( IsClient() )

//	local player = GetLocalViewPlayer()
//	if ( hideOnlyFromEnemies && player.GetTeam() != mine.GetTeam() )
//	{
//		if ( PlayerHasEnhancement( player, "en_advanced_optics" ) )
//			return
//	}

	mine.Signal( "StopGrenadeClientEffects" )

	LaserMine_RemoveFx( mine )

	mine.s.grenadeEffectHandles = []
	mine.s.laserbeamFXHandle = null
	mine.s.laserbeamEndPointFXHandle = null

}

// client & server, returns a table with the traceResult to and the end point origin of the mine's detection laser
function LaserMine_GetEndPointInfo( mine )
{
	local mineAngles = mine.GetAngles()
	mineAngles = mineAngles.AnglesCompose( Vector( -90, 0, 0 ) )
	local startPoint = mine.GetOrigin()
	local maxTrace = GetWeaponInfoFileKeyField_Global( "mp_weapon_laser_mine", "explosionradius" )
	local endPoint = mine.GetOrigin() + ( mineAngles.AnglesToForward() * maxTrace )

	local traceResult = TraceLineSimple( startPoint, endPoint, mine.GetOwner() )
	local traceDist = maxTrace * traceResult
	local endPointOrg = startPoint + ( mineAngles.AnglesToForward() * traceDist )

	local returnTable = {}
	returnTable.traceResult <- traceResult
	returnTable.endPointOrg <- endPointOrg
	return returnTable
}

function LaserMine_DeactivateAndKill( mine )
{
	Assert( IsServer() )

	mine.EndSignal( "OnDestroy" )

	// untrack it before waiting, in case player is up against the max lasermines in world limit
	PlayerUnTrackLaserMine( mine )

	LaserMine_Disable( mine )

	wait 0.5

	mine.Kill()
}

function ClientDestroyCallback_GrenadeDestroyed( grenade )
{
	Assert( IsClient() )

	local localPlayer = GetLocalViewPlayer()
	if ( !IsValid( localPlayer ) )
		return

	if ( !grenade.IsClientCreated() && grenade.GetOwner() == localPlayer )
	{
		if ( grenade in localPlayer.s.activeTraps )
			delete localPlayer.s.activeTraps[ grenade ]
	}

	if ( "grenadeEffectHandles" in grenade.s )
	{
		foreach ( effectHandle in grenade.s.grenadeEffectHandles )
		{
			if ( EffectDoesExist( effectHandle ) )
				EffectStop( effectHandle, true, true )
		}
	}
}

function ServerDeathCallback_GrenadeDeath( grenade, damageInfo )
{
	Assert( IsServer() )

	if ( grenade.GetWeaponClassName() == "mp_weapon_laser_mine" )
		LaserMine_Cleanup( grenade )
}


function LaserMine_Init( ent )
{
	ent.s.grenadeEffectHandles 		<- []
	ent.s.laserbeamFXHandle 			<- null
	ent.s.laserbeamEndPointFXHandle 	<- null
}


function LaserMine_Cleanup( mine )
{
	Assert( IsServer() )

	PlayerUnTrackLaserMine( mine )

	Assert( "laserEndPointEnt" in trapEnt.s )
	if ( IsValid( trapEnt.s.laserEndPointEnt ) )
		delete trapEnt.s.laserEndPointEnt
}


function PlayerTrackLaserMine( player, mine )
{
	Assert( IsServer() )

	player.s.activeLaserMines.append( mine )
	ArrayRemoveInvalid( player.s.activeLaserMines )
}


function PlayerUnTrackLaserMine( mine )
{
	Assert( IsServer() )

	local player = mine.GetOwner()
	if ( !player )
		return

	if ( !IsValid_ThisFrame( player ) )
		return

	if ( !IsValid_ThisFrame( mine ) )
		return

	ArrayRemoveInvalid( player.s.activeLaserMines )
	ArrayRemove( player.s.activeLaserMines, mine )
}


function CleanupPlayerLaserMines( player )
{
	Assert( IsServer() )

	ArrayRemoveInvalid( player.s.activeLaserMines )

	local minesToCleanup = clone player.s.activeLaserMines

	foreach ( mine in minesToCleanup )
	{
		thread LaserMine_DeactivateAndKill( mine )
	}
}

function DisplayEnemyLaserMines( player )
{
	foreach ( laserMine in clone level._laserMines )
	{
		if ( !IsValid_ThisFrame( laserMine ) )
		{
			delete level._laserMines[laserMine]
		}
		else
		{
			if ( laserMine.GetTeam() != player.GetTeam() )
				LaserMine_StartClientEffects( laserMine )
		}
	}
}

function HideEnemyLaserMines( player )
{
	foreach ( laserMine in clone level._laserMines )
	{
		if ( !IsValid( laserMine ) )
			delete level._laserMines[ laserMine ]
		else
		{
			if ( laserMine.GetTeam() != player.GetTeam() )
				LaserMine_StopClientEffects( laserMine, true )
		}
	}
}

function EnableTrapWarningSound( trap, delay = 0, warningSound = DEFAULT_WARNING_SFX )
{
	Assert( IsServer() )

	trap.EndSignal( "OnDestroy" )
	trap.EndSignal( "DisableTrapWarningSound" )

	if ( delay > 0 )
		wait delay

	while ( IsValid( trap ) )
	{
		EmitSoundOnEntityToTeam( trap, warningSound, GetOtherTeam( trap.GetTeam() ) )
		wait 1.0
	}
}

function AddToProximityTargets( ent )
{
	AddToScriptManagedEntArray( level._proximityTargetArrayID, ent );
}

function ProximityMineThink( proximityMine, owner )
{
	Assert( IsServer() )
	proximityMine.EndSignal( "OnDestroy" )
	if ( owner.IsPlayer() )
	{
		owner.EndSignal( "OnRespawnPlayer" )
		owner.EndSignal( "NewPilotOrdnance" )
		owner.EndSignal( "Disconnected" )
	}
	else
	{
		owner.EndSignal( "OnDestroy" )
	}

	OnThreadEnd(
		function() : ( proximityMine )
		{
			if ( IsValid( proximityMine ) )
				proximityMine.Kill()
		}
	)
	thread TrapExplodeOnDamage( proximityMine, 50 )
	thread ProximityMineHandleVortexAbsorption( proximityMine, owner )

	// Don't try to explode until it's been planted
	if ( !proximityMine.s.planted )
		proximityMine.WaitSignal( "Planted" )

	wait PROXIMITY_MINE_ARMING_DELAY

	local enemyTeam = proximityMine.GetTeam() == TEAM_IMC ? TEAM_MILITIA : TEAM_IMC
	local explodeRadius = proximityMine.GetDamageRadius()
	local triggerRadius = ( ( explodeRadius * 0.75 ) + 0.5 ).tointeger()
	local lastTimeNPCsChecked = 0
	local NPCTickRate = 0.5
	local PlayerTickRate = 0.2

	// Wait for someone to enter proximity
	while( IsValid( proximityMine ) && IsValid( owner ) )
	{
		if ( lastTimeNPCsChecked + NPCTickRate <= Time() )
		{
			local nearbyNPCs = GetNPCArrayEx( "any", enemyTeam, proximityMine.GetOrigin(), triggerRadius )
			foreach( ent in nearbyNPCs )
			{
				if ( ShouldSetOffProximityMine( proximityMine, ent ) )
				{
					ProximityMine_Explode( proximityMine, owner )
					return
				}
			}
			lastTimeNPCsChecked = Time()
		}

		local nearbyPlayers = GetPlayerArrayEx( "any", enemyTeam, proximityMine.GetOrigin(), triggerRadius )
		foreach( ent in nearbyPlayers )
		{
			if ( ShouldSetOffProximityMine( proximityMine, ent ) )
			{
				ProximityMine_Explode( proximityMine, owner )
				return
			}
		}

		wait PlayerTickRate
	}
}

function ProximityMine_Explode( proximityMine, owner )
{
	local explodeTime = Time() + PROXIMITY_MINE_EXPLOSION_DELAY
	EmitSoundOnEntity( proximityMine, TRIGGERED_ALARM_SFX )

	wait PROXIMITY_MINE_EXPLOSION_DELAY

	if( owner.IsPlayer() )
		PlayerUnTrackProximityMine( owner, proximityMine )
	if ( IsValid( proximityMine ) )
		proximityMine.Explode( proximityMine.s.bounceNormal )
}

function ShouldSetOffProximityMine( proximityMine, ent )
{
	if ( !IsAlive( ent ) )
		return false

	local results = TraceLine( proximityMine.GetOrigin(), ent.EyePosition(), proximityMine, (TRACE_MASK_SHOT | CONTENTS_BLOCKLOS), TRACE_COLLISION_GROUP_NONE )
	if ( results.fraction >= 1 || results.hitEnt == ent )
		return true

	return false
}


/*
function MagneticFlight( nade, magneticForce = DEFAULT_MAGNETIC_FORCE )
{
	nade.EndSignal( "OnDestroy" )
	nade.EndSignal( "GrenadeStick" )

	local hasTriggeredSound = 0
	local highestMagneticRange = GetHighestMagneticRange()
	local rangeModifier = 1.0
	if ( "poweredMagnet" in nade.s && nade.s.poweredMagnet == true )
		rangeModifier = 1.5
	local magnetizedVelocity = magneticForce
	if ( "high_density" in nade.s && nade.s.high_density == true )
		magnetizedVelocity *= 0.6

	while ( 1 )
	{
		local nadeOrigin = nade.GetOrigin()
		local entityArray = GetScriptManagedEntArrayWithinCenter( level._magneticTargetsArrayID, nade.GetTeam(), nadeOrigin, ( highestMagneticRange * rangeModifier ) )
		foreach ( ent in entityArray )
		{
			if ( !IsAlive( ent ) )
				continue

			if ( ent.IsPlayer() && !ent.IsTitan() )
				continue

			if ( Distance ( ent.GetWorldSpaceCenter(), nadeOrigin ) <= ( GetMagneticRangeForTargetType( ent ) * rangeModifier ) )
			{
				SetVelocityTowardsEntity( nade, ent, magnetizedVelocity )
				//SetVelocityTowardsEntityTag( nade, ent, tag, MAGNETIC_FORCE )
				if ( hasTriggeredSound == 0 )
				{
					EmitSoundOnEntity( nade, MAG_FLIGHT_SFX_LOOP )
					hasTriggeredSound = 1
				}
				break
			}
		}
		wait 0
	}
}
*/

function SMR_DamagedPlayerOrNPC( ent, damageInfo )
{
	//Hack - JFS ( The explosion radius is too small on the SMR to deal splash damage to pilots on a Titan. )
	if ( !IsValid( ent ) )
		return

	if ( !ent.IsTitan() )
		return

	if ( damageInfo.GetCustomDamageType() & DF_DOOMED_HEALTH_LOSS )
		return

	local attacker = damageInfo.GetAttacker()

	if ( IsValid( attacker ) && attacker.IsPlayer() && attacker.GetTitanSoulBeingRodeoed() == ent.GetTitanSoul() )
		attacker.TakeDamage( 30, attacker, attacker, { scriptType = DF_GIB | DF_EXPLOSION, damageSourceId = eDamageSourceId.mp_weapon_smr, weapon = damageInfo.GetWeapon() } )
}


function ElectricSmoke_DamagedPlayerOrNPC( ent, damageInfo )
{
	if ( !IsValid( ent ) )
		return

	if ( !IsAlive( ent ) )
		return

	local attacker = damageInfo.GetAttacker()

	local currentTime = Time()
	if ( !( "nextSmokeSoundTime" in ent.s ) )
	{
		if ( ent.IsPlayer() )
			ent.s.nextSmokeSoundTime <- currentTime
		else
			ent.s.nextSmokeSoundTime <- currentTime + RandomFloat( 0.0, 0.5 )
	}

	if ( ent.s.nextSmokeSoundTime <= currentTime )
	{
		if( ent.IsPlayer() )
		{

			if ( ent.IsTitan() )
			{
				EmitSoundOnEntityExceptToPlayer( ent, ent, ELECTRIC_SMOKESCREEN_SFX_DAMAGE_3P_Titan )
				EmitSoundOnEntityOnlyToPlayer( ent, ent, ELECTRIC_SMOKESCREEN_SFX_DAMAGE_1P_Titan )
				ent.s.nextSmokeSoundTime = currentTime + RandomFloat( 0.75, 1.25 )
			}
			else
			{
					EmitSoundOnEntityExceptToPlayer( ent, ent, ELECTRIC_SMOKESCREEN_SFX_DAMAGE_3P_Pilot )
					EmitSoundOnEntityOnlyToPlayer( ent, ent, ELECTRIC_SMOKESCREEN_SFX_DAMAGE_1P_Pilot )
			}
		}
		else
		{
			if( ent.IsTitan() )
				EmitSoundOnEntity( ent, ELECTRIC_SMOKESCREEN_SFX_DAMAGE_3P_Titan )
			else if ( ent.IsHumanSized() )
				EmitSoundOnEntity( ent, ELECTRIC_SMOKESCREEN_SFX_DAMAGE_3P_Pilot )
		}

		if ( IsValid( attacker ) )
			EmitSoundOnEntity( attacker, "Player.Hitbeep" )
		ent.s.nextSmokeSoundTime = currentTime + RandomFloat( 0.75, 1.25 )
	}
}

