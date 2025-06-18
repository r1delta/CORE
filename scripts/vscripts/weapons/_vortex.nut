const VORTEX_SPHERE_COLOR_CHARGE_FULL	= "115 247 255"	// blue
const VORTEX_SPHERE_COLOR_CHARGE_MED	= "200 128 80"	// orange
const VORTEX_SPHERE_COLOR_CHARGE_EMPTY	= "200 80 80"	// red

const VORTEX_SPHERE_COLOR_CROSSOVERFRAC_FULL2MED	= 0.75  // from zero to this fraction, fade between full and medium charge colors
const VORTEX_SPHERE_COLOR_CROSSOVERFRAC_MED2EMPTY	= 0.95  // from "full2med" to this fraction, fade between medium and empty charge colors

const VORTEX_BULLET_ABSORB_COUNT_MAX = 32

const VORTEX_TIMED_EXPLOSIVE_FUSETIME				= 2.75	// fuse time for absorbed projectiles
const VORTEX_TIMED_EXPLOSIVE_FUSETIME_WARNINGFRAC	= 0.75	// wait this fraction of the fuse time before warning the player it's about to explode

const VORTEX_EXP_ROUNDS_RETURN_SPREAD_XY = 0.15
const VORTEX_EXP_ROUNDS_RETURN_SPREAD_Z = 0.075

const VORTEX_ELECTRIC_DAMAGE_CHARGE_DRAIN_MIN = 0.1  // fraction of charge time
const VORTEX_ELECTRIC_DAMAGE_CHARGE_DRAIN_MAX = 0.3

//The shotgun spams a lot of pellets that deal too much damage if they return full damage.
const VORTEX_SHOTGUN_DAMAGE_RATIO = 0.25


const SHIELD_WALL_BULLET_FX = "P_impact_xo_shield_cp"
PrecacheParticleSystem( SHIELD_WALL_BULLET_FX )
GetParticleSystemIndex( SHIELD_WALL_BULLET_FX )

const SHIELD_WALL_EXPMED_FX = "P_impact_exp_med_xo_shield_CP"
PrecacheParticleSystem( SHIELD_WALL_EXPMED_FX )
GetParticleSystemIndex( SHIELD_WALL_EXPMED_FX )


const SIGNAL_ID_BULLET_HIT_THINK = "signal_id_bullet_hit_think"
RegisterSignal( SIGNAL_ID_BULLET_HIT_THINK )
RegisterSignal( "VortexStopping" )

RegisterSignal( "VortexAbsorbed" )
RegisterSignal( "VortexFired" )

const VORTEX_EXPLOSIVE_WARNING_SFX_LOOP = "Weapon_Vortex_Gun.ExplosiveWarningBeep"

// These match the strings in the WeaponEd dropdown box for vortex_refire_behavior
const VORTEX_REFIRE_NONE				= ""
const VORTEX_REFIRE_BULLET				= "bullet"
const VORTEX_REFIRE_EXPLOSIVE_ROUND		= "explosive_round"
const VORTEX_REFIRE_PROXIMITY_MINE		= "proximity_mine"
const VORTEX_REFIRE_SATCHEL				= "satchel"
const VORTEX_REFIRE_ROCKET				= "rocket"
const VORTEX_REFIRE_FRAG_GRENADE		= "frag_grenade"
const VORTEX_REFIRE_TITAN_GRENADE		= "titan_grenade"

vortexIgnoreClassnames <- {}
vortexIgnoreClassnames["mp_weapon_defender"] <- true

vortexImpactWeaponInfo <- {}

function main()
{
	Globalize( CreateVortexSphere )
	Globalize( DestroyVortexSphere )
	Globalize( EnableVortexSphere )
	Globalize( ValidateVortexImpact )
	Globalize( TryVortexAbsorb )
	Globalize( VortexDrainedByImpact )
	Globalize( VortexPrimaryAttack )
	Globalize( GetVortexSphereCurrentColor )
	Globalize( GetShieldTriLerpColor )
	Globalize( IsVortexing )
	Globalize( Vortex_HandleElectricDamage )

	Globalize( Vortex_SetTagName )
	Globalize( Vortex_SetBulletCollectionOffset )

	Globalize( UpdateShieldWallColorForFrac )
	Globalize( VortexSphereDrainHealthForDamage )

	Globalize( CodeCallback_OnVortexHitBullet )
	Globalize( CodeCallback_OnVortexHitProjectile )

	level.DEG_COS_60 <- deg_cos( 60 )
}

function CreateVortexSphere( vortexWeapon, useCylinderCheck, blockOwnerWeapon, sphereRadius = 40, bulletFOV = 180 )
{
	local owner = vortexWeapon.GetWeaponOwner()
	Assert( owner )

	if ( IsServer() )
	{
		//printt( "util ent:", vortexWeapon.GetWeaponUtilityEntity() )
		Assert ( !vortexWeapon.GetWeaponUtilityEntity(), "Tried to create more than one vortex sphere on a vortex weapon!" )

		local vortexSphere = CreateEntity( "vortex_sphere" )
		Assert( vortexSphere )

		local spawnFlags = 1	// SF_ABSORB_BULLETS

		if ( useCylinderCheck )
			spawnFlags = spawnFlags | 4		// SF_ABSORB_CYLINDER

		if ( blockOwnerWeapon )
			spawnFlags = spawnFlags | 2		// SF_BLOCK_OWNER_WEAPON

		vortexSphere.kv.spawnflags = spawnFlags

		vortexSphere.kv.enabled = 0
		vortexSphere.kv.radius = sphereRadius
		vortexSphere.kv.bullet_fov = bulletFOV
		vortexSphere.kv.physics_pull_strength = 25
		vortexSphere.kv.physics_side_dampening = 6
		vortexSphere.kv.physics_fov = 360
		vortexSphere.kv.physics_max_mass = 2
		vortexSphere.kv.physics_max_size = 6
		Assert( owner.IsNPC() || owner.IsPlayer(), "Vortex script expects the weapon owner to be a player or NPC." )

		DispatchSpawn( vortexSphere, false )

		vortexSphere.SetOwner( owner )

		if ( owner.IsNPC() )
		{
			vortexSphere.SetParent( owner, "PROPGUN" )
			vortexSphere.SetLocalOrigin( Vector( 0, 35, 0 ) )
		}
		else
		{
			vortexSphere.SetParent( owner )
			vortexSphere.SetLocalOrigin( Vector( 0, 10, -30 ) )
		}
		vortexSphere.SetAbsAngles( Vector( 0, 0, 0 ) ) //Setting local angles on a parented object is not supported

		vortexSphere.SetOwnerWeapon( vortexWeapon )
		vortexWeapon.SetWeaponUtilityEntity( vortexSphere )
	}

	SetVortexAmmo( vortexWeapon, 0 )
}

function EnableVortexSphere( vortexWeapon )
{
	if ( !( "vortexImpactData" in vortexWeapon.s ) )
		vortexWeapon.s.vortexImpactData <- null

	vortexWeapon.s.vortexImpactData = []

	local weaponscope = vortexWeapon.GetScriptScope()

	local tagname = GetVortexTagName( vortexWeapon )
	local weaponOwner = vortexWeapon.GetWeaponOwner()
	local hasBurnMod = vortexWeapon.GetWeaponModSetting( "is_burn_mod" )

	if ( IsServer() )
	{
		local vortexSphere = vortexWeapon.GetWeaponUtilityEntity()
		Assert( vortexSphere )
		vortexSphere.FireNow( "Enable" )

		thread SetPlayerUsingVortex( weaponOwner, vortexWeapon )

		Vortex_CreateAbsorbFX_ControlPoints( vortexWeapon )

		// world (3P) version of the vortex sphere FX
		vortexSphere.s.worldFX <- CreateEntity( "info_particle_system" )

		if ( hasBurnMod )
		{
			if ( "fxChargingControlPointBurn" in vortexWeapon.s )
				vortexSphere.s.worldFX.kv.effect_name = vortexWeapon.s.fxChargingControlPointBurn
		}
		else
		{
			if ( "fxChargingControlPoint" in vortexWeapon.s )
				vortexSphere.s.worldFX.kv.effect_name = vortexWeapon.s.fxChargingControlPoint
		}

		vortexSphere.s.worldFX.kv.start_active = 1
		vortexSphere.s.worldFX.SetOwner( weaponOwner )
		vortexSphere.s.worldFX.SetParent( vortexWeapon, tagname )
		vortexSphere.s.worldFX.kv.VisibilityFlags = 6 // not owner only
		vortexSphere.s.worldFX.kv.cpoint1 = vortexWeapon.s.vortexSphereColorCP.GetName()
		vortexSphere.s.worldFX.SetStopType( "destroyImmediately" )

		DispatchSpawn( vortexSphere.s.worldFX, false )
	}

	SetVortexAmmo( vortexWeapon, 0 )

	if ( IsClient() && IsLocalViewPlayer( weaponOwner ) )
	{
		local fxAlias = null

		if ( hasBurnMod )
		{
			if ( "fxChargingFPControlPointBurn" in vortexWeapon.s )
				fxAlias = vortexWeapon.s.fxChargingFPControlPointBurn
		}
		else
		{
			if ( "fxChargingFPControlPoint" in vortexWeapon.s )
				fxAlias = vortexWeapon.s.fxChargingFPControlPoint
		}

		if ( fxAlias )
		{
			vortexWeapon.PlayWeaponEffect( fxAlias, null, tagname )

			local sphereClientFXHandle = vortexWeapon.AllocateHandleForViewmodelEffect( fxAlias )
			thread VortexSphereColorUpdate( vortexWeapon, sphereClientFXHandle )
		}
	}
	else if ( IsServer() )
	{
		local fxAlias = null

		if ( hasBurnMod )
		{
			if ( "fxChargingFPControlPointReplayBurn" in vortexWeapon.s )
				fxAlias = vortexWeapon.s.fxChargingFPControlPointReplayBurn
		}
		else
		{
			if ( "fxChargingFPControlPointReplay" in vortexWeapon.s )
				fxAlias = vortexWeapon.s.fxChargingFPControlPointReplay
		}

		if ( fxAlias )
			vortexWeapon.PlayWeaponEffect( fxAlias, null, tagname )

		thread VortexSphereColorUpdate( vortexWeapon )
	}
}

function DestroyVortexSphere( vortexWeapon )
{
	DisableVortexSphere( vortexWeapon )

	if ( IsServer() )
	{
		local vortexSphere = vortexWeapon.GetWeaponUtilityEntity()
		if ( vortexSphere )
		{
			if ( "worldFX" in vortexSphere.s )
			{
				vortexSphere.s.worldFX.Kill()
			}

			vortexSphere.Destroy()
		}

		vortexWeapon.SetWeaponUtilityEntity( null )
	}
}

function DisableVortexSphere( vortexWeapon )
{
	vortexWeapon.Signal( "VortexStopping" )

	// server cleanup
	if ( IsServer() )
	{
		local vortexSphere = vortexWeapon.GetWeaponUtilityEntity()
		if ( vortexSphere )
		{
			vortexSphere.FireNow( "Disable" )
			vortexSphere.Signal( SIGNAL_ID_BULLET_HIT_THINK )
		}

		Vortex_CleanupAllEffects( vortexWeapon )
		Vortex_ClearImpactEventData( vortexWeapon )
	}

	// client & server cleanup

	if ( vortexWeapon.GetWeaponModSetting( "is_burn_mod" ) )
	{
		if ( "fxChargingFPControlPointBurn" in vortexWeapon.s )
			vortexWeapon.StopWeaponEffect( vortexWeapon.s.fxChargingFPControlPointBurn, null )
		if ( "fxChargingFPControlPointReplayBurn" in vortexWeapon.s )
			vortexWeapon.StopWeaponEffect( vortexWeapon.s.fxChargingFPControlPointReplayBurn, null )
	}
	else
	{
		if ( "fxChargingFPControlPoint" in vortexWeapon.s )
			vortexWeapon.StopWeaponEffect( vortexWeapon.s.fxChargingFPControlPoint, null )
		if ( "fxChargingFPControlPointReplay" in vortexWeapon.s )
			vortexWeapon.StopWeaponEffect( vortexWeapon.s.fxChargingFPControlPointReplay, null )
	}
}

function Vortex_CreateAbsorbFX_ControlPoints( vortexWeapon )
{
	Assert( IsServer() )

	local player = vortexWeapon.GetWeaponOwner()
	Assert( player )

	// vortex swirling incoming rounds FX location control point
	if ( !( "vortexBulletEffectCP" in vortexWeapon.s ) )
		vortexWeapon.s.vortexBulletEffectCP <- null
	vortexWeapon.s.vortexBulletEffectCP = CreateEntity( "info_placement_helper" )
	vortexWeapon.s.vortexBulletEffectCP.SetName( UniqueString( "vortexBulletEffectCP" ) )
	vortexWeapon.s.vortexBulletEffectCP.kv.start_active = 1

	DispatchSpawn( vortexWeapon.s.vortexBulletEffectCP, false )

	local offset = GetBulletCollectionOffset( vortexWeapon )
	local origin = player.OffsetPositionFromView( player.EyePosition(), offset )

	vortexWeapon.s.vortexBulletEffectCP.SetOrigin( origin )
	vortexWeapon.s.vortexBulletEffectCP.SetParent( player, "", true, 0 )

	// vortex sphere color control point
	if ( !( "vortexSphereColorCP" in vortexWeapon.s ) )
		vortexWeapon.s.vortexSphereColorCP <- null
	vortexWeapon.s.vortexSphereColorCP = CreateEntity( "info_placement_helper" )
	vortexWeapon.s.vortexSphereColorCP.SetName( UniqueString( "vortexSphereColorCP" ) )
	vortexWeapon.s.vortexSphereColorCP.kv.start_active = 1

	DispatchSpawn( vortexWeapon.s.vortexSphereColorCP, false )
}

function Vortex_CleanupAllEffects( vortexWeapon )
{
	Assert( IsServer() )

	Vortex_CleanupImpactAbsorbFX( vortexWeapon )

	if ( ( "vortexBulletEffectCP" in vortexWeapon.s ) && IsValid_ThisFrame( vortexWeapon.s.vortexBulletEffectCP ) )
		vortexWeapon.s.vortexBulletEffectCP.Destroy()

	if ( ( "vortexSphereColorCP" in vortexWeapon.s ) && IsValid_ThisFrame( vortexWeapon.s.vortexSphereColorCP ) )
		vortexWeapon.s.vortexSphereColorCP.Destroy()
}

function SetPlayerUsingVortex( weaponOwner, vortexWeapon )
{
	weaponOwner.EndSignal( "OnDeath" )
	weaponOwner.EndSignal( "Disconnected" )

	weaponOwner.s.isVortexing <- true

	vortexWeapon.WaitSignal( "VortexStopping" )

	OnThreadEnd
	(
		function() : ( weaponOwner )
		{
			if ( IsValid_ThisFrame( weaponOwner ) && "isVortexing" in weaponOwner.s )
			{
				delete weaponOwner.s.isVortexing
			}
		}
	)
}

function IsVortexing( ent )
{
	Assert( IsServer() )

	if ( "isVortexing" in ent.s )
		return true
}

function Vortex_HandleElectricDamage( ent, attacker, damage, dmgSourceID, weapon )
{
	if ( !IsValid( ent ) )
		return damage

	if ( !ent.IsTitan() )
		return damage

	if ( !ent.IsPlayer() && !ent.IsNPC() )
		return damage

	if ( !IsVortexing( ent ) )
		return damage

	local vortexWeapon = ent.GetActiveWeapon()
	if ( !IsValid( vortexWeapon ) )
		return damage

	local vortexSphere = vortexWeapon.GetWeaponUtilityEntity()
	if ( !IsValid( vortexSphere ) )
		return damage

	if ( !IsValid( vortexWeapon ) || !IsValid( vortexSphere ) )
		return damage

	// vortex FOV check
	//printt( "sphere FOV:", vortexSphere.kv.bullet_fov )
	local sphereFOV = vortexSphere.kv.bullet_fov.tointeger()
	local attackerWeapon = attacker.GetActiveWeapon()
	local attachIdx = attackerWeapon.LookupAttachment( "muzzle_flash" )
	local beamOrg = attackerWeapon.GetAttachmentOrigin( attachIdx )
	local firingDir = beamOrg - vortexSphere.GetOrigin()
	firingDir.Normalize()
	local vortexDir = vortexSphere.GetAngles().AnglesToForward()

	local dot = vortexDir.Dot( firingDir )

	local degCos = level.DEG_COS_60
	if ( sphereFOV != 120 )
		deg_cos( sphereFOV * 0.5 )

	// not in the vortex cone
	if ( dot < degCos )
		return damage

	local attackerWeaponMinDmg	= weapon.GetWeaponModSetting("damage_far_value_titanarmor" )
	local attackerWeaponMaxDmg 	= weapon.GetWeaponModSetting("damage_near_value_titanarmor" )

	local baseCharge	= vortexWeapon.GetWeaponInfoFileKeyField( "charge_time" )
	Assert( baseCharge > 0 )

	local minDrain 		= baseCharge * VORTEX_ELECTRIC_DAMAGE_CHARGE_DRAIN_MIN
	local maxDrain 		= baseCharge * VORTEX_ELECTRIC_DAMAGE_CHARGE_DRAIN_MAX

	local chargeToDrain = Graph( damage, attackerWeaponMinDmg, attackerWeaponMaxDmg, minDrain, maxDrain )
	local newChargeTime = vortexWeapon.GetWeaponChargeTimeRemaining() - chargeToDrain

	local dmgAbsorbedPerChargeSec = attackerWeaponMaxDmg / maxDrain
	local damageRemaining = damage

	local startingChargeFrac = vortexWeapon.GetWeaponChargeFraction()

	local doElectricFX = false
	if ( newChargeTime <= 0 )
	{
		local timeOverrun = abs( newChargeTime )
		damageRemaining = dmgAbsorbedPerChargeSec * timeOverrun
		vortexWeapon.ForceRelease()
		vortexWeapon.SetWeaponChargeFraction( 1.0 )
		doElectricFX = true
	}
	else
	{
		damageRemaining = 0

		// this weapon depletes charge as it is active, therefore the scale goes from zero (full charge) to one (empty)
		local newChargeFrac = 1.0 - ( newChargeTime / baseCharge )
		Assert( newChargeFrac >= startingChargeFrac, "Arc cannon trying to add charge to the vortex!" )
		vortexWeapon.SetWeaponChargeFraction( newChargeFrac )
	}

	if ( doElectricFX )
	{
		local weaponscope = vortexWeapon.GetScriptScope()

		// play particle to show something happened
		if ( "fxElectricalExplosion" in vortexWeapon.s )
		{
			local fxRef = CreateEntity( "info_particle_system" )
			fxRef.kv.effect_name = vortexWeapon.s.fxElectricalExplosion
			fxRef.kv.start_active = 1
			fxRef.SetStopType( "destroyImmediately" )
			//fxRef.kv.VisibilityFlags = 1  // HACK this turns on owner only visibility. Uncomment when we hook up dedicated 3P effects
			fxRef.SetOwner( ent )
			fxRef.SetOrigin( vortexSphere.GetOrigin() )
			fxRef.SetParent( ent, "", true, 0 )

			DispatchSpawn( fxRef, false )
			fxRef.Kill( 1 )
		}
	}

	//printt( "VORTEX TIME REDUCED BY", chargeToDrain )
	//printt( "damage remaining after arc cannon hits vortex:", damageRemaining )
	return damageRemaining
}

// this function handles all incoming vortex impact events
function TryVortexAbsorb( vortexSphere, attacker, origin, damageSourceID, weapon, weaponName, impactType, projectile = null, damageType = null, reflect = false )
{
	Assert( IsServer() )
	if ( weaponName in vortexIgnoreClassnames )
		return

	local vortexWeapon = vortexSphere.GetOwnerWeapon()
	local owner = vortexWeapon.GetWeaponOwner()

	// keep cycling the oldest hitscan bullets out
	if( !reflect )
		Vortex_ClampHitscanBulletCount( vortexWeapon, impactType )

	// vortex spheres tag refired projectiles with info about the original projectile for accurate duplication when re-absorbed
	if ( projectile )
	{
		if ( "originalDamageSource" in projectile.s )
		{
			damageSourceID = projectile.s.originalDamageSource

			// Vortex Volley Achievement
			if ( IsValid( owner ) && owner.IsPlayer() )
			{
				if ( PlayerProgressionAllowed( owner ) )
					owner.SetPersistentVar( "ach_vortexVolley", true )
			}
		}

		// Max projectile stat tracking
		local projectilesInVortex = 1
		if ( "vortexImpactData" in vortexWeapon.s )
			projectilesInVortex += vortexWeapon.s.vortexImpactData.len()
		if ( IsValid( owner ) && owner.IsPlayer() && PlayerProgressionAllowed( owner ) )
		{
			local record = owner.GetPersistentVar( "mostProjectilesCollectedInVortex" )
			if ( projectilesInVortex > record )
				owner.SetPersistentVar( "mostProjectilesCollectedInVortex", projectilesInVortex )
		}
	}

	local impactData = Vortex_CreateImpactEventData( vortexWeapon, attacker, origin, damageSourceID, weaponName, impactType )

	VortexDrainedByImpact( vortexWeapon, weapon, projectile, damageType )

	VortexImpactData_AddSpecialBehavior( impactData )

	if ( !Vortex_ScriptCanHandleImpactEvent( impactData ) )
		return false

	Vortex_StoreImpactEvent( vortexWeapon, impactData )

	VortexImpact_PlayAbsorbedFX( vortexWeapon, impactData )

	VortexImpact_RunThinkFunctions( vortexWeapon, impactData, projectile )

	Vortex_NotifyAttackerDidDamage( impactData.attacker, owner, impactData.origin )

	local maxShotgunPelletsToIgnore = VORTEX_BULLET_ABSORB_COUNT_MAX * ( 1 - VORTEX_SHOTGUN_DAMAGE_RATIO )
	if ( weaponName == "mp_weapon_shotgun" && ( vortexWeapon.s.shotgunPelletsToIgnore + 1 ) <  maxShotgunPelletsToIgnore )
			vortexWeapon.s.shotgunPelletsToIgnore += ( 1 - VORTEX_SHOTGUN_DAMAGE_RATIO )

	if ( reflect )
	{
		local attackParams = {}
		attackParams.pos <- owner.EyePosition()
		attackParams.dir <- owner.GetViewVector()

		local bulletsFired = VortexReflectAttack( vortexWeapon, attackParams, impactData.origin )

		Vortex_CleanupImpactAbsorbFX( vortexWeapon )
		Vortex_ClearImpactEventData( vortexWeapon )
	}

	return true
}

function VortexDrainedByImpact( vortexWeapon, weapon, projectile, damageType )
{
	if ( vortexWeapon.HasMod( "unlimited_charge_time" ) )
		return

	local amount
	if ( projectile )
	{
		amount = projectile.GetWeaponInfoFileKeyField( "vortex_drain" )
	}
	else
	{
		amount = weapon.GetWeaponInfoFileKeyField( "vortex_drain" )
	}

	if ( !amount )
		return
	amount = amount.tofloat()

	if ( damageType != null && damageType == damageTypes.Electric )
		amount *= 1.5

	if ( weapon.GetClassname() == "mp_titanweapon_arc_cannon" )
		amount += amount * weapon.GetWeaponChargeFraction()

	local frac = vortexWeapon.GetWeaponChargeFraction()

	// taper off the effect of blasting the shield at the lower end of remaining charge time
	amount *= GraphCapped( frac, 0.5, 0.87, 1.0, 0.0 )
	if ( amount <= 0 )
		return

	frac += amount

	// weird backwards function
	if ( frac >= 1.0 )
		frac = 1.0

	vortexWeapon.SetWeaponChargeFraction( frac )
}


function VortexSlowOwner( player, attacker, refireBehavior, damageSourceID )
{
	if ( !IsAlive( player ) )
		return

	local velocity = player.GetVelocity()

	switch ( refireBehavior )
	{
		case "bullet":

			switch ( damageSourceID )
			{
				case eDamageSourceId.mp_titanweapon_xo16:
					VortexSlowOwnerFromAttacker( player, attacker, velocity, 0.55 )
					break

				default:
					VortexSlowOwnerFromAttacker( player, attacker, velocity, 0.75 )
					break
			}

			return
		case "explosive_round":
			VortexSlowOwnerFromAttacker( player, attacker, velocity, 2.0 )
			return

		// special case for shoulder rocket dumbfire missile
		case "rocket":
			if ( damageSourceID == eDamageSourceId.mp_titanweapon_dumbfire_rockets || damageSourceID == mp_titanweapon_salvo_rockets )
			{
				VortexSlowOwnerFromAttacker( player, attacker, velocity, 2.0 )
				return
			}
	}

	local newVel = velocity * 0.1
	player.SetVelocity( newVel )
}

function VortexSlowOwnerFromAttacker( player, attacker, velocity, multiplier )
{
	local damageForward = player.GetOrigin() - attacker.GetOrigin()
	damageForward.z = 0
	damageForward.Norm()

	local velForward = player.GetVelocity()
	velForward.z = 0
	velForward.Norm()

	local dot = velForward.Dot( damageForward )
	if ( dot >= -0.5 )
		return

	dot += 0.5
	dot *= -2.0

	local negateVelocity = velocity * -multiplier
	negateVelocity *= dot

	velocity += negateVelocity
	player.SetVelocity( velocity )
}



function Vortex_ClampHitscanBulletCount( vortexWeapon, impactType )
{
	if ( impactType == "hitscan" && GetBulletsAbsorbedCount( vortexWeapon ) >= ( VORTEX_BULLET_ABSORB_COUNT_MAX - 1 ) )
		Vortex_RemoveOldestHitscanImpact( vortexWeapon )
}

function Vortex_RemoveOldestHitscanImpact( vortexWeapon )
{
	local impactDataToRemove = null

	local vortexSphere = vortexWeapon.GetWeaponUtilityEntity()

	local bulletImpacts = Vortex_GetHitscanBulletImpacts( vortexWeapon )
	local impactDataToRemove = bulletImpacts[ 0 ]  // since it's an array, the first one will be the oldest

	Vortex_RemoveImpactEvent( vortexWeapon, impactDataToRemove )

	vortexSphere.RemoveBulletFromSphere()
}

function Vortex_CreateImpactEventData( vortexWeapon, attacker, origin, damageSourceID, weaponName, impactType )
{
	local player = vortexWeapon.GetWeaponOwner()

	local impactData = {}

	impactData.attacker				<- attacker
	impactData.origin				<- origin
	impactData.damageSourceID		<- damageSourceID
	impactData.weaponName			<- weaponName
	impactData.impactType			<- impactType

	impactData.refireBehavior		<- VORTEX_REFIRE_NONE
	impactData.absorbSFX			<- "Vortex_Shield_AbsorbBulletSmall"

	impactData.team 				<- null
	// sets a team even if the attacker disconnected
	if ( IsValid_ThisFrame( attacker ) )
	{
		impactData.team = attacker.GetTeam()
	}
	else
	{
		// default to opposite team
		if ( player.GetTeam() == TEAM_IMC )
			impactData.team = TEAM_MILITIA
		else
			impactData.team = TEAM_IMC
	}

	impactData.timedExplosive		<- false

	impactData.absorbFX				<- null
	impactData.absorbFX_3p			<- null
	impactData.fxEnt_absorb			<- null

	impactData.fireFunction			<- null
	impactData.thinkFunction		<- null

	impactData.explosionradius		<- null
	impactData.explosion_damage		<- null
	impactData.impact_effect_table	<- null
	// -- everything from here down relies on being able to read a megaweapon file
	if ( !( impactData.weaponName in vortexImpactWeaponInfo ) )
	{
		vortexImpactWeaponInfo[ impactData.weaponName ] <- {}
		vortexImpactWeaponInfo[ impactData.weaponName ].absorbFX 						<- GetWeaponInfoFileKeyField_Global( impactData.weaponName, "vortex_absorb_effect" )
		vortexImpactWeaponInfo[ impactData.weaponName ].absorbFX_3p 					<- GetWeaponInfoFileKeyField_Global( impactData.weaponName, "vortex_absorb_effect_third_person" )
		vortexImpactWeaponInfo[ impactData.weaponName ].refireBehavior 					<- GetWeaponInfoFileKeyField_Global( impactData.weaponName, "vortex_refire_behavior" )
		vortexImpactWeaponInfo[ impactData.weaponName ].absorbSound 					<- GetWeaponInfoFileKeyField_Global( impactData.weaponName, "vortex_absorb_sound" )
		vortexImpactWeaponInfo[ impactData.weaponName ].explosionradius 				<- GetWeaponInfoFileKeyField_Global( impactData.weaponName, "explosionradius" )
		vortexImpactWeaponInfo[ impactData.weaponName ].explosion_damage_heavy_armor	<- GetWeaponInfoFileKeyField_Global( impactData.weaponName, "explosion_damage_heavy_armor" )
		vortexImpactWeaponInfo[ impactData.weaponName ].explosion_damage				<- GetWeaponInfoFileKeyField_Global( impactData.weaponName, "explosion_damage" )
		vortexImpactWeaponInfo[ impactData.weaponName ].impact_effect_table				<- GetWeaponInfoFileKeyField_Global( impactData.weaponName, "impact_effect_table" )
	}

	impactData.absorbFX				= vortexImpactWeaponInfo[ impactData.weaponName ].absorbFX
	impactData.absorbFX_3p			= vortexImpactWeaponInfo[ impactData.weaponName ].absorbFX_3p
	if ( impactData.absorbFX )
		Assert( impactData.absorbFX_3p, "Missing 3rd person absorb effect for " + impactData.weaponName )
	impactData.refireBehavior		= vortexImpactWeaponInfo[ impactData.weaponName ].refireBehavior

	local absorbSound = vortexImpactWeaponInfo[ impactData.weaponName ].absorbSound
	if ( absorbSound )
		impactData.absorbSFX = absorbSound

	// info we need for refiring (some types of) impacts
	impactData.explosionradius		= vortexImpactWeaponInfo[ impactData.weaponName ].explosionradius
	impactData.explosion_damage		= vortexImpactWeaponInfo[ impactData.weaponName ].explosion_damage_heavy_armor
	if ( impactData.explosion_damage == null )
		impactData.explosion_damage		= vortexImpactWeaponInfo[ impactData.weaponName ].explosion_damage
	impactData.impact_effect_table	= vortexImpactWeaponInfo[ impactData.weaponName ].impact_effect_table

	return impactData
}

function Vortex_ScriptCanHandleImpactEvent( impactData )
{
	if ( impactData.refireBehavior == VORTEX_REFIRE_NONE )
		return false

	if ( !impactData.absorbFX )
		return false

	if ( impactData.impactType == "projectile" && !impactData.impact_effect_table )
		return false

	// if satchel attacker is dead (disconnected or died since throwing), don't absorb
	if ( ( impactData.refireBehavior == VORTEX_REFIRE_SATCHEL || impactData.refireBehavior == VORTEX_REFIRE_PROXIMITY_MINE ) && PlayerDiedOrDisconnected( impactData.attacker ) )
		return false

	return true
}

function Vortex_StoreImpactEvent( vortexWeapon, impactData )
{
	Assert( IsServer() )

	Assert( "vortexImpactData" in vortexWeapon.s )

	vortexWeapon.s.vortexImpactData.append( impactData )
}

// safely removes data for a single impact event
function Vortex_RemoveImpactEvent( vortexWeapon, impactData )
{
	Vortex_ImpactData_KillAbsorbFX( impactData )

	ArrayRemove( vortexWeapon.s.vortexImpactData, impactData )
}

function Vortex_GetAllImpactEvents( vortexWeapon )
{
	Assert( IsServer() )

	local impactData = []

	if ( !( "vortexImpactData" in vortexWeapon.s ) )
		return impactData

	return vortexWeapon.s.vortexImpactData
}

function Vortex_ClearImpactEventData( vortexWeapon )
{
	Assert( IsServer() )

	if ( "vortexImpactData" in vortexWeapon.s )
		vortexWeapon.s.vortexImpactData = []
}

function VortexImpact_PlayAbsorbedFX( vortexWeapon, impactData )
{
	Assert( IsServer() )

	// generic shield ping FX
	Vortex_SpawnShieldPingFX( vortexWeapon, impactData )

	// specific absorb FX
	impactData.fxEnt_absorb = Vortex_SpawnImpactAbsorbFX( vortexWeapon, impactData )
}

// FX played when something first enters the vortex sphere
function Vortex_SpawnShieldPingFX( vortexWeapon, impactData )
{
	Assert( IsServer() )

	local player = vortexWeapon.GetWeaponOwner()
	Assert( player )

	local absorbSFX = impactData.absorbSFX
	//printt( "SFX absorb sound:", absorbSFX )
	if ( vortexWeapon.GetWeaponModSetting( "is_burn_mod" ) )
		EmitSoundOnEntity( vortexWeapon, "Vortex_Shield_Deflect_Amped" )
	else
		EmitSoundOnEntity( vortexWeapon, absorbSFX )

	local pingFX = CreateEntity( "info_particle_system" )

	if ( vortexWeapon.GetWeaponModSetting( "is_burn_mod" ) )
	{
		if ( "fxBulletHitBurn" in vortexWeapon.s )
			pingFX.kv.effect_name = vortexWeapon.s.fxBulletHitBurn
	}
	else
	{
		if ( "fxBulletHit" in vortexWeapon.s )
			pingFX.kv.effect_name = vortexWeapon.s.fxBulletHit
	}

	pingFX.kv.start_active = 1

	DispatchSpawn( pingFX, false )

	pingFX.SetOrigin( impactData.origin )
	pingFX.SetParent( player, "", true, 0 )
	pingFX.Kill( 0.25 )
}

function Vortex_SpawnImpactAbsorbFX( vortexWeapon, impactData )
{
	Assert( IsServer() )

	// in case we're in the middle of cleaning the weapon up
	if ( !IsValid( vortexWeapon.s.vortexBulletEffectCP ) )
		return

	local owner = vortexWeapon.GetWeaponOwner()
	Assert( owner )

	local fxRefs = []

	// owner
	{
		local fxRef = CreateEntity( "info_particle_system" )

		fxRef.kv.effect_name = impactData.absorbFX
		fxRef.kv.start_active = 1
		fxRef.SetStopType( "destroyImmediately" )
		fxRef.kv.VisibilityFlags = 1 // owner only visibility
		fxRef.kv.cpoint1 = vortexWeapon.s.vortexBulletEffectCP.GetName()

		DispatchSpawn( fxRef, false )

		fxRef.SetOwner( owner )
		fxRef.SetOrigin( impactData.origin )
		fxRef.SetParent( owner, "", true, 0 )

		fxRefs.append( fxRef )
	}

	// everyone else
	{
		local fxRef = CreateEntity( "info_particle_system" )

		fxRef.kv.effect_name = impactData.absorbFX_3p
		fxRef.kv.start_active = 1
		fxRef.SetStopType( "destroyImmediately" )
		fxRef.kv.VisibilityFlags = 6  // other only visibility
		fxRef.kv.cpoint1 = vortexWeapon.s.vortexBulletEffectCP.GetName()

		DispatchSpawn( fxRef, false )

		fxRef.SetOwner( owner )
		fxRef.SetOrigin( impactData.origin )
		fxRef.SetParent( owner, "", true, 0 )

		fxRefs.append( fxRef )
	}

	return fxRefs
}

function Vortex_CleanupImpactAbsorbFX( vortexWeapon )
{
	Assert( IsServer() )

	if ( !( "vortexImpactData" in vortexWeapon.s ) )
		return

	foreach ( impactData in Vortex_GetAllImpactEvents( vortexWeapon ) )
	{
		Vortex_ImpactData_KillAbsorbFX( impactData )
	}
}

function Vortex_ImpactData_KillAbsorbFX( impactData )
{
	foreach ( fxRef in impactData.fxEnt_absorb )
	{
		if ( !IsValid( fxRef ) )
			continue

		fxRef.Fire( "DestroyImmediately" )
		fxRef.Kill()
	}
}

// sets up refire behavior and think function for each impact
function VortexImpactData_AddSpecialBehavior( impactData )
{
	if ( impactData.refireBehavior == VORTEX_REFIRE_NONE )
		return

	switch( impactData.refireBehavior )
	{
		case VORTEX_REFIRE_EXPLOSIVE_ROUND:
			impactData.fireFunction = Vortex_FireBackExplosiveRound.bindenv( this )
			break

		case VORTEX_REFIRE_ROCKET:
			impactData.fireFunction = Vortex_FireBackRocket.bindenv( this )
			impactData.timedExplosive = false
			break

		case VORTEX_REFIRE_FRAG_GRENADE:
			impactData.fireFunction = Vortex_FireBackFragGrenade.bindenv( this )
			impactData.timedExplosive = false
			break

		case VORTEX_REFIRE_TITAN_GRENADE:
			impactData.fireFunction = Vortex_FireBackTitanGrenade.bindenv( this )
			impactData.timedExplosive = false
			break

		case VORTEX_REFIRE_SATCHEL:
			impactData.fireFunction = Vortex_FireBackSatchel.bindenv( this )
			//impactData.thinkFunction = Vortex_SatchelAbsorbedThink.bindenv( this )
			break

		case VORTEX_REFIRE_PROXIMITY_MINE:
			impactData.fireFunction = Vortex_FireBackProximityMine.bindenv( this )
			break
	}
}

function VortexImpact_RunThinkFunctions( vortexWeapon, impactData, projectile = null )
{
	Assert( IsServer() )

	if ( projectile != null )
		Assert( IsValid( projectile ) )

	if ( impactData.timedExplosive && DoExplosiveProjectileTimer() )
	{
		thread VortexTimedExplosiveProjectileThink( vortexWeapon, impactData )
		//thread VortexImpact_TimedExplosiveBeepWarning( vortexWeapon, impactData )
	}

	if ( impactData.thinkFunction )
		thread impactData.thinkFunction( vortexWeapon, impactData, projectile )
}

function DoExplosiveProjectileTimer()
{
	return !( IsTrainingLevel() )
}

function Vortex_SatchelAbsorbedThink( vortexWeapon, impactData, satchel )
{
	satchel.Signal( "VortexAbsorbed" )

	impactData.attacker.EndSignal( "OnDeath" )
	impactData.attacker.EndSignal( "Disconnected" )
	vortexWeapon.EndSignal( "VortexFired" )
	vortexWeapon.EndSignal( "OnDestroy" )

	OnThreadEnd
	(
		function() : ( impactData, vortexWeapon )
		{
			if ( PlayerDiedOrDisconnected( impactData.attacker ) && IsValid( vortexWeapon ) )
			{
				Vortex_RemoveImpactEvent( vortexWeapon, impactData )
			}
		}
	)

	impactData.attacker.WaitSignal( "DetonateSatchels" )

	local vortexSphere = vortexWeapon.GetWeaponUtilityEntity()
	Assert( IsValid( vortexSphere ) )

	Vortex_AbsorbedProjectileExplodes( vortexWeapon, vortexSphere, impactData )

	vortexWeapon.SetWeaponChargeFraction( 1 )  // force the vortex to release
}

function PlayerDiedOrDisconnected( player )
{
	if ( !IsValid( player ) )
		return true

	if ( !IsAlive( player ) )
		return true

	if ( "disconnected" in player.s && player.s.disconnected == true )
		return true

	return false
}

/*
function VortexImpact_TimedExplosiveBeepWarning( vortexWeapon, impactData )
{
	// play the warning SFX when close to detonation - first impact only
	local timedExplosiveImpacts = Vortex_GetTimedExplosiveImpacts( vortexWeapon )
	if ( timedExplosiveImpacts.len() > 1 )
		return

	local vortexSphere = vortexWeapon.GetWeaponUtilityEntity()
	if ( !IsValid( vortexSphere ) )
		return

	vortexWeapon.EndSignal( "VortexFired" )
	vortexWeapon.EndSignal( "OnDestroy" )
	vortexSphere.EndSignal( "OnDestroy" )

	local vortexChargeTimeMax = vortexWeapon.GetWeaponInfoFileKeyField( "charge_time" )
	while( vortexWeapon.GetWeaponChargeTimeRemaining() > ( vortexChargeTimeMax * ( 1 - VORTEX_TIMED_EXPLOSIVE_FUSETIME_WARNINGFRAC ) ) )
		wait 0.05

	EmitSoundOnEntity( vortexSphere, VORTEX_EXPLOSIVE_WARNING_SFX_LOOP )

	OnThreadEnd(
		function() : ( vortexSphere )
		{
			if ( IsValid( vortexSphere ) )
			{
				StopSoundOnEntity( vortexSphere, VORTEX_EXPLOSIVE_WARNING_SFX_LOOP )
			}
		}
	)

	while ( vortexWeapon.GetWeaponChargeTimeRemaining() > 0.05 )
		wait 0.05
}
*/

function VortexTimedExplosiveProjectileThink( vortexWeapon, impactData )
{
	Assert( IsServer() )

	// if fuse time is longer than the vortex charge time, don't run the thread
	if ( VORTEX_TIMED_EXPLOSIVE_FUSETIME > vortexWeapon.GetWeaponInfoFileKeyField( "charge_time" ) )
		return

	local vortexSphere = vortexWeapon.GetWeaponUtilityEntity()
	if ( !IsValid( vortexSphere ) )
		return

	vortexWeapon.EndSignal( "OnDestroy" )
	vortexSphere.EndSignal( "OnDestroy" )
	foreach ( fxRef in impactData.fxEnt_absorb )
	{
		fxRef.EndSignal( "OnDestroy" )
	}

	// the first one we absorb will play the warning SFX when close to detonation
	local firstAbsorbed = false
	local timedExplosiveImpacts = Vortex_GetTimedExplosiveImpacts( vortexWeapon )
	local timedExplosiveImpactsCount = timedExplosiveImpacts.len()

	if ( timedExplosiveImpactsCount == 1 )
		firstAbsorbed = true

	// only the first one we absorb needs to trigger the blast
	if ( !firstAbsorbed )
		return

	local warningSoundStopped = true

	OnThreadEnd(
		function() : ( vortexSphere, warningSoundStopped )
		{
			if ( IsValid( vortexSphere ) && !warningSoundStopped )
			{
				StopSoundOnEntity( vortexSphere, VORTEX_EXPLOSIVE_WARNING_SFX_LOOP )
			}
		}
	)

	// wait until it's time to start beeping
	local beepTime = VORTEX_TIMED_EXPLOSIVE_FUSETIME * ( 1 - VORTEX_TIMED_EXPLOSIVE_FUSETIME_WARNINGFRAC )
	Wait( VORTEX_TIMED_EXPLOSIVE_FUSETIME - beepTime )

	EmitSoundOnEntity( vortexSphere, VORTEX_EXPLOSIVE_WARNING_SFX_LOOP )
	warningSoundStopped = false

	Wait( beepTime )
	StopSoundOnEntity( vortexSphere, VORTEX_EXPLOSIVE_WARNING_SFX_LOOP )
	warningSoundStopped = true

	Vortex_DetonateAllTimedExplosives( vortexWeapon )

	//printt( "force releasing", vortexWeapon )
	vortexWeapon.ForceRelease()
	vortexWeapon.SetWeaponChargeFraction( 1.0 )

	DestroyVortexSphere( vortexWeapon )
}

function Vortex_DetonateAllTimedExplosives( vortexWeapon )
{
	local vortexSphere = vortexWeapon.GetWeaponUtilityEntity()
	if ( !IsValid( vortexSphere ) )
		return

	// detonate all explosive projectiles
	local timedExplosiveImpacts = Vortex_GetTimedExplosiveImpacts( vortexWeapon )
	local timedExplosiveImpactsCount = timedExplosiveImpacts.len()

	foreach ( idx, impactData in timedExplosiveImpacts )
		Vortex_AbsorbedProjectileExplodes( vortexWeapon, vortexSphere, impactData )
}

function Vortex_AbsorbedProjectileExplodes( vortexWeapon, vortexSphere, impactData )
{
	Assert( IsServer() )

	local player = vortexWeapon.GetWeaponOwner()
	Assert( player )

	local refireOrigin = Vortex_GenerateRandomRefireOrigin( vortexWeapon, 10 )

	//custom explosion types
	if ( impactData.damageSourceID == eDamageSourceId.mp_titanweapon_dumbfire_rockets )
	{
		local fakeRocket = CreateScriptRef()
		fakeRocket.SetOrigin( refireOrigin )
		fakeRocket.SetOwner( player )

		ClusterRocket_Detonate( fakeRocket, vortexWeapon.GetAngles().AnglesToForward() )
	}
	// generic explosion
	else
	{
		local explosionLifetime = 1.0
		local explosionOrigin = refireOrigin

		local env_explosion = CreateEntity( "env_explosion" )

		Assert( impactData.impact_effect_table != null )
		env_explosion.kv.impact_effect_table = impactData.impact_effect_table

		env_explosion.kv.rendermode = 5   //additive
		env_explosion.SetName( UniqueString( "vortex_absorbed_projectile_explosion" ) )

		env_explosion.SetOrigin( explosionOrigin )
		env_explosion.SetOwner( impactData.attacker )
		env_explosion.SetTeam( impactData.team )
		env_explosion.kv.damageSourceId = impactData.damageSourceID

		env_explosion.kv.iRadiusOverride	= impactData.explosionradius
		env_explosion.kv.iMagnitude			= impactData.explosion_damage

		env_explosion.kv.scriptDamageType = damageTypes.Explosive // HACK should get this from impactData (need projectile damageType from vortex projectile hit callback)

		DispatchSpawn( env_explosion, false )

		env_explosion.Fire( "Explode" )
		env_explosion.Kill( explosionLifetime )
	}

	// removes the FX and the impact event so we don't try to refire this projectile later
	Vortex_RemoveImpactEvent( vortexWeapon, impactData )
}

function VortexPrimaryAttack( vortexWeapon, attackParams )
{
	local vortexSphere = vortexWeapon.GetWeaponUtilityEntity()
	if ( !vortexSphere )
		return 0

	if ( IsServer() )
		Assert( vortexSphere )

	local weaponOwner = vortexWeapon.GetWeaponOwner()

	local totalfired = 0

	local forceReleased = false
	// in this case, it's also considered "force released" if the charge time runs out
	if ( vortexWeapon.IsForceRelease() || vortexWeapon.GetWeaponChargeFraction() == 1 )
		forceReleased = true

	// PREDICTED REFIRES
	// bullet impact events don't individually fire back per event because we aggregate and then shotgun blast them
	local bulletsFired = Vortex_FireBackBullets( vortexWeapon, attackParams )
	totalfired += bulletsFired

	// UNPREDICTED REFIRES
	if ( IsServer() )
	{
		//printt( "server: force released?", forceReleased )


		local unpredictedRefires = Vortex_GetProjectileImpacts( vortexWeapon )

		// HACK we don't actually want to refire them with a spiral but
		//   this is to temporarily ensure compatibility with the Titan rocket launcher
		if ( !( "spiralMissileIdx" in vortexWeapon.s ) )
			vortexWeapon.s.spiralMissileIdx <- null
		vortexWeapon.s.spiralMissileIdx = 0

		foreach ( impactData in unpredictedRefires )
		{
			if ( !impactData.fireFunction )
				continue

			if ( impactData.fireFunction( vortexWeapon, attackParams, impactData ) )
				totalfired++
		}
	}

	SetVortexAmmo( vortexWeapon, 0 )

	vortexWeapon.Signal( "VortexFired" )

	if ( forceReleased )
		DestroyVortexSphere( vortexWeapon )
	else
		DisableVortexSphere( vortexWeapon )

	return totalfired
}

function Vortex_FireBackBullets( vortexWeapon, attackParams )
{
	local bulletCount = GetBulletsAbsorbedCount( vortexWeapon )
	//Defensive Check - Couldn't repro error.
	if ( "shotgunPelletsToIgnore" in vortexWeapon.s )
		bulletCount = ceil( bulletCount - vortexWeapon.s.shotgunPelletsToIgnore )

	if ( bulletCount )
	{
		bulletCount = min( bulletCount, MAX_BULLET_PER_SHOT )

		//if ( IsClient() && GetLocalViewPlayer() == vortexWeapon.GetWeaponOwner() )
		//	printt( "vortex firing", bulletCount, "bullets" )

		local radius = IsMultiplayer() ? LOUD_WEAPON_AI_SOUND_RADIUS_MP : LOUD_WEAPON_AI_SOUND_RADIUS
		vortexWeapon.EmitWeaponNpcSound( radius, 0.2 )
		local damageTypes = damageTypes.Shotgun | DF_VORTEX_REFIRE
		if ( bulletCount == 1 )
			vortexWeapon.FireWeaponBullet( attackParams.pos, attackParams.dir, bulletCount, damageTypes )
		else
			vortexWeapon.GetScriptScope().ShotgunBlast( attackParams.pos, attackParams.dir, bulletCount, damageTypes )
	}

	return bulletCount
}

function Vortex_FireBackExplosiveRound( vortexWeapon, attackParams, impactData )
{
	// common projectile data
	local projSpeed		= 8000
	local damageType	= damageTypes.Explosive
	local impactSFX		= vortexWeapon.EmitWeaponSound( "Weapon.Explosion_Med" )

	local attackPos
	//Requires code feature to properly fire tracers from offset positions.
	//if ( vortexWeapon.GetWeaponModSetting( "is_burn_mod" ) )
	//	attackPos = impactData.origin
	//else
		attackPos = Vortex_GenerateRandomRefireOrigin( vortexWeapon )

	local fireVec = Vortex_GenerateRandomRefireVector( vortexWeapon )

	// fire off the bolt
	local bolt = vortexWeapon.FireWeaponBolt( attackPos, fireVec, projSpeed, damageTypes.Explosive | DF_VORTEX_REFIRE, damageTypes.Explosive | DF_VORTEX_REFIRE, PROJECTILE_NOT_PREDICTED )
	bolt.kv.bounceFrac = 0.0
	bolt.kv.gravity = 0.3

	Vortex_ProjectileCommonSetup( vortexWeapon, bolt, impactData )

	return true
}

function Vortex_GenerateRandomRefireOrigin( vortexWeapon, distFromCenter = 3 )
{
	local distFromCenter_neg = distFromCenter * -1

	local attackPos = vortexWeapon.s.vortexBulletEffectCP.GetOrigin()

	local x = RandomFloat( distFromCenter_neg, distFromCenter )
	local y = RandomFloat( distFromCenter_neg, distFromCenter )
	local z = RandomFloat( distFromCenter_neg, distFromCenter )

	attackPos = attackPos + Vector( x, y, z )

	return attackPos
}

function Vortex_GenerateRandomRefireVector( vortexWeapon )
{
	local vecSpread = VORTEX_EXP_ROUNDS_RETURN_SPREAD_XY
	local vecSpreadZ = VORTEX_EXP_ROUNDS_RETURN_SPREAD_Z

	local x = RandomFloat( vecSpread * -1, vecSpread )
	local y = RandomFloat( vecSpread * -1, vecSpread )
	local z = RandomFloat( vecSpreadZ * -1, vecSpreadZ )

	local fireVec = vortexWeapon.GetWeaponOwner().GetViewVector() + Vector( x, y, z )
	return fireVec
}

function Vortex_FireBackRocket( vortexWeapon, attackParams, impactData )
{
	// TODO prediction for clients
	Assert( IsServer() )

	local rocket = vortexWeapon.FireWeaponMissile( attackParams.pos, attackParams.dir, 1800, damageTypes.LargeCaliberExp | DF_VORTEX_REFIRE, damageTypes.LargeCaliberExp | DF_VORTEX_REFIRE, false, PROJECTILE_NOT_PREDICTED )

	if ( rocket )
	{
		rocket.kv.lifetime = RandomFloat( 2.6, 3.5 )

		InitMissileForRandomDriftForVortexLow( rocket, attackParams.pos, attackParams.dir )

		Vortex_ProjectileCommonSetup( vortexWeapon, rocket, impactData )
	}

	return true
}

function Vortex_FireBackFragGrenade( vortexWeapon, attackParams, impactData )
{
	// TODO prediction for clients
	Assert( IsServer() )

	local frag = Vortex_FireBackGrenade_Common( vortexWeapon, attackParams, impactData )
	frag.SetModel( GRENADE_MODEL )

	return true
}

function Vortex_FireBackTitanGrenade( vortexWeapon, attackParams, impactData )
{
	// TODO prediction for clients
	Assert( IsServer() )

	local titanGrenade = Vortex_FireBackGrenade_Common( vortexWeapon, attackParams, impactData )
	titanGrenade.SetModel( GRENADE_MODEL_LARGE )

	return true
}

function Vortex_FireBackSatchel( vortexWeapon, attackParams, impactData )
{
	// TODO prediction for clients
	Assert( IsServer() )

	// when the satchel owner dies, the satchel impact event is removed from impactData
	//local satchelOwner = impactData.attacker
	// satchel owner could have died during the refiring frame from hitscan bullets
	//if ( PlayerDiedOrDisconnected( satchelOwner ) )
		//return false

	local fuseTime = 1
	local scriptDamageType = 0

	local satchel = Vortex_FireBackGrenade_Common( vortexWeapon, attackParams, impactData, fuseTime, scriptDamageType | DF_VORTEX_REFIRE)
	satchel.SetModel( SATCHEL_CHARGE_MODEL )
	/*
	satchel.SetTeam( satchelOwner.GetTeam() )  // makes the refired satchel do the correct blinky light color and FoF crosshair coloring
	satchel.SetOwner( satchelOwner )

	// set the satchel back up on its owner now that it's a real boy again
	Satchel_PostFired_Init( satchel, satchelOwner )
	*/

	return true
}

function Vortex_FireBackProximityMine( vortexWeapon, attackParams, impactData )
{
	// TODO prediction for clients
	Assert( IsServer() )

	local proxMineOwner = vortexWeapon.GetWeaponOwner()

	if ( !IsValid( proxMineOwner ) )
		return false

	if ( PlayerDiedOrDisconnected( proxMineOwner ) )
		return false

	local fuseTime = 0  // infinite
	local scriptDamageType = 0

	local proxMine = Vortex_FireBackGrenade_Common( vortexWeapon, attackParams, impactData, fuseTime, scriptDamageType | DF_VORTEX_REFIRE)
	proxMine.SetModel( PROX_MINE_MODEL )
	proxMine.SetTeam( proxMineOwner.GetTeam() ) // makes the refired satchel do the correct blinky light color and FoF crosshair coloring
	proxMine.SetOwner( proxMineOwner )

	thread ProximityMineThink( proxMine, proxMineOwner )

	return true
}

function Vortex_FireBackGrenade_Common( vortexWeapon, attackParams, impactData, fuseTime = 1.25, scriptDamageType = null )
{
	local x = RandomFloat( -0.2, 0.2 )
	local y = RandomFloat( -0.2, 0.2 )
	local z = RandomFloat( -0.2, 0.2 )

	local velocity = ( attackParams.dir + Vector( x, y, z ) ) * 1500
	local angularVelocity = Vector( RandomFloat( -1200, 1200 ), 100, 0 )

	if ( !scriptDamageType )
		scriptDamageType = damageTypes.Explosive

	local grenade = vortexWeapon.FireWeaponGrenade( attackParams.pos, velocity, angularVelocity, fuseTime, scriptDamageType | DF_VORTEX_REFIRE, scriptDamageType | DF_VORTEX_REFIRE, PROJECTILE_NOT_PREDICTED, true, true )
	Grenade_Init( grenade, vortexWeapon )

	if ( grenade )
	{
		Vortex_ProjectileCommonSetup( vortexWeapon, grenade, impactData )
	}

	return grenade
}

function Vortex_ProjectileCommonSetup( vortexWeapon, projectile, impactData )
{
	// custom tag it so it shows up correctly if it hits another vortex sphere
	projectile.s.originalDamageSource <- impactData.damageSourceID

	Vortex_SetImpactEffectTable_OnProjectile( projectile, impactData )  // set the correct impact effect table

	projectile.SetVortexRefired( true ) // This tells code the projectile was refired from the vortex so that it uses "projectile_vortex_vscript"
	projectile.SetWeaponClassName( impactData.weaponName )  // causes the projectile to use its normal trail FX

	projectile.SetDamageSourceID( impactData.damageSourceID ) // obit will show the owner weapon
}

// gives a refired projectile the correct impact effect table
function Vortex_SetImpactEffectTable_OnProjectile( projectile, impactData )
{
	local fxTableHandle = GetImpactEffectTable( impactData.impact_effect_table )

	projectile.SetImpactEffectTable( fxTableHandle )
}

// absorbed bullets are tracked with a special networked kv variable because clients need to know how many bullets to fire as well, when they are doing the client version of FireWeaponBullet
function GetBulletsAbsorbedCount( vortexWeapon )
{
	if ( !vortexWeapon )
		return 0

	local vortexSphere = vortexWeapon.GetWeaponUtilityEntity()
	if ( !vortexSphere )
		return 0

	local networkedBulletAbsorbedCount = vortexSphere.kv.bullet_absorbed_count.tointeger()
	local returnCount = 0

	if ( IsClient() )
	{
		returnCount = networkedBulletAbsorbedCount
	}
	else
	{
		local hitscanImpactDataCount = GetHitscanBulletImpactCount( vortexWeapon )

		//if ( hitscanImpactDataCount != networkedBulletAbsorbedCount )
		//	printt( "WARNING: server hitscan bullet count doesn't match the vortex sphere's kv.bullet_absorbed_count. Server count:", hitscanImpactDataCount, "Network var count:", networkedBulletAbsorbedCount )

		returnCount = hitscanImpactDataCount
	}

	return returnCount
}

function Vortex_GetProjectileImpacts( vortexWeapon )
{
	Assert( IsServer() )

	local impacts = []
	foreach ( impactData in Vortex_GetAllImpactEvents( vortexWeapon ) )
	{
		if ( impactData.impactType == "projectile" )
			impacts.append( impactData )
	}

	return impacts
}

function Vortex_GetHitscanBulletImpacts( vortexWeapon )
{
	Assert( IsServer() )

	local impacts = []
	foreach ( impactData in Vortex_GetAllImpactEvents( vortexWeapon ) )
	{
		if ( impactData.impactType == "hitscan" )
			impacts.append( impactData )
	}

	return impacts
}

function GetHitscanBulletImpactCount( vortexWeapon )
{
	Assert( IsServer() )

	local count = 0
	foreach ( impactData in Vortex_GetAllImpactEvents( vortexWeapon ) )
	{
		if ( impactData.impactType == "hitscan" )
			count++
	}

	return count
}

function Vortex_GetTimedExplosiveImpacts( vortexWeapon )
{
	local impacts = []

	foreach ( impactData in Vortex_GetAllImpactEvents( vortexWeapon ) )
	{
		if ( impactData.timedExplosive )
			impacts.append( impactData )
	}

	return impacts
}

function GetDamageSourceID_ForWeaponEnt( weapon )
{
	local weaponClassname = weapon.GetClassname()

	foreach ( name, id in getconsttable().eDamageSourceId )
	{
		if ( name == weaponClassname )
			return id
	}

	return null
}

// // lets the damage callback communicate to the attacker that he hit a vortex shield
function Vortex_NotifyAttackerDidDamage( attacker, vortexOwner, hitPos )
{
	if ( !IsValid( attacker ) || !attacker.IsPlayer() )
		return

	if ( !IsValid( vortexOwner ) )
		return

	Assert( hitPos )

	attacker.NotifyDidDamage( vortexOwner, 0, hitPos, 0, 0, DAMAGEFLAG_VICTIM_HAS_VORTEX, 0, null, 0 )
}

function SetVortexAmmo( vortexWeapon, count )
{
	local owner = vortexWeapon.GetWeaponOwner()
	if ( !IsValid_ThisFrame( owner ) )
		return
	if ( IsClient() && !IsLocalViewPlayer( owner ) )
		return

	vortexWeapon.SetWeaponPrimaryAmmoCount( count )
}


// sets the RGB color value for the vortex sphere FX based on current charge fraction
function VortexSphereColorUpdate( weapon, sphereClientFXHandle = null )
{
	weapon.EndSignal( "VortexStopping" )

	if ( IsClient() )
		Assert( sphereClientFXHandle != null )

	while( IsValid( weapon ) )
	{
		local colorVec = GetVortexSphereCurrentColor( weapon )

		// update the world entity that is linked to the world FX playing on the server
		if ( IsServer() )
		{
			weapon.s.vortexSphereColorCP.SetOrigin( colorVec )
		}
		else
		{
			// handles the server killing the vortex sphere without the client knowing right away,
			//  for example if an explosive goes off and we short circuit the charge timer
			if ( !EffectDoesExist( sphereClientFXHandle ) )
				break

			EffectSetControlPointVector( sphereClientFXHandle, 1, colorVec )
		}

		wait 0
	}
}

function GetVortexSphereCurrentColor( weapon )
{
	PerfStart( PerfIndexShared.GetVortexSphereCurrentColor + SharedPerfIndexStart )

	local color1 = StringToColors( VORTEX_SPHERE_COLOR_CHARGE_FULL )
	local color2 = StringToColors( VORTEX_SPHERE_COLOR_CHARGE_MED )
	local color3 = StringToColors( VORTEX_SPHERE_COLOR_CHARGE_EMPTY )

	local crossover1 = VORTEX_SPHERE_COLOR_CROSSOVERFRAC_FULL2MED  // from zero to this fraction, fade between color1 and color2
	local crossover2 = VORTEX_SPHERE_COLOR_CROSSOVERFRAC_MED2EMPTY  // from crossover1 to this fraction, fade between color2 and color3

	local chargeFrac = weapon.GetWeaponChargeFraction()

	local r = null
	local g = null
	local b = null
	// 0 = full charge, 1 = no charge remaining
	if ( chargeFrac < crossover1 )
	{
		r = Graph( chargeFrac, 0, crossover1, color1.r, color2.r )
		g = Graph( chargeFrac, 0, crossover1, color1.g, color2.g )
		b = Graph( chargeFrac, 0, crossover1, color1.b, color2.b )
	}
	else if ( chargeFrac < crossover2 )
	{
		r = Graph( chargeFrac, crossover1, crossover2, color2.r, color3.r )
		g = Graph( chargeFrac, crossover1, crossover2, color2.g, color3.g )
		b = Graph( chargeFrac, crossover1, crossover2, color2.b, color3.b )
	}
	else
	{
		// for the last bit of overload timer, keep it max danger color
		r = color3.r
		g = color3.g
		b = color3.b
	}

	PerfEnd( PerfIndexShared.GetVortexSphereCurrentColor + SharedPerfIndexStart )
	return Vector( r, g, b )
}

function GetShieldTriLerpColor( frac )
{
	PerfStart( PerfIndexShared.GetVortexSphereCurrentColor + SharedPerfIndexStart )

	local color1 = StringToColors( VORTEX_SPHERE_COLOR_CHARGE_FULL )
	local color2 = StringToColors( VORTEX_SPHERE_COLOR_CHARGE_MED )
	local color3 = StringToColors( VORTEX_SPHERE_COLOR_CHARGE_EMPTY )

	local crossover1 = VORTEX_SPHERE_COLOR_CROSSOVERFRAC_FULL2MED  // from zero to this fraction, fade between color1 and color2
	local crossover2 = VORTEX_SPHERE_COLOR_CROSSOVERFRAC_MED2EMPTY  // from crossover1 to this fraction, fade between color2 and color3

	local chargeFrac = frac

	local r = null
	local g = null
	local b = null
	// 0 = full charge, 1 = no charge remaining
	if ( chargeFrac < crossover1 )
	{
		r = Graph( chargeFrac, 0, crossover1, color1.r, color2.r )
		g = Graph( chargeFrac, 0, crossover1, color1.g, color2.g )
		b = Graph( chargeFrac, 0, crossover1, color1.b, color2.b )
	}
	else if ( chargeFrac < crossover2 )
	{
		r = Graph( chargeFrac, crossover1, crossover2, color2.r, color3.r )
		g = Graph( chargeFrac, crossover1, crossover2, color2.g, color3.g )
		b = Graph( chargeFrac, crossover1, crossover2, color2.b, color3.b )
	}
	else
	{
		// for the last bit of overload timer, keep it max danger color
		r = color3.r
		g = color3.g
		b = color3.b
	}

	PerfEnd( PerfIndexShared.GetVortexSphereCurrentColor + SharedPerfIndexStart )
	return Vector( r, g, b )
}


// generic impact validation
function ValidateVortexImpact( vortexSphere, projectile = null )
{
	Assert( IsServer() )

	if ( !IsValid( vortexSphere ) )
		return false

	if ( !vortexSphere.GetOwnerWeapon() )
		return false

	local vortexWeapon = vortexSphere.GetOwnerWeapon()
	if ( !IsValid( vortexWeapon ) )
		return false

	if ( projectile )
	{
		if (  !IsValid_ThisFrame( projectile ) )
		{
			return false
		}

		if ( !projectile.GetWeaponClassName() )
		{
			return false
		}
	}


	return true
}

/********************************/
/*	Setting override functions	*/
/********************************/

function Vortex_SetTagName( weapon, tagName )
{
	Vortex_SetWeaponSettingOverride( weapon, "vortexTagName", tagName )
}

function Vortex_SetBulletCollectionOffset( weapon, offset )
{
	Vortex_SetWeaponSettingOverride( weapon, "bulletCollectionOffset", offset )
}

function Vortex_SetWeaponSettingOverride( weapon, setting, value )
{
	if ( !( setting in weapon.s ) )
		weapon.s[ setting ] <- null
	weapon.s[ setting ] = value
}

function GetVortexTagName( weapon )
{
	if ( "vortexTagName" in weapon.s )
		return weapon.s.vortexTagName
	return "vortex_center"
}

function GetBulletCollectionOffset( weapon )
{
	if ( "bulletCollectionOffset" in weapon.s )
		return weapon.s.bulletCollectionOffset

	local owner = weapon.GetWeaponOwner()
	if ( owner.IsTitan() )
		return Vector( 300, -90, -70.0 )
	else
		return Vector( 80.0, 17, -11 )
}


function VortexSphereDrainHealthForDamage( vortexSphere, weapon, projectile, damageType = null )
{
	local amount = 0
	if ( projectile )
		amount = projectile.GetWeaponInfoFileKeyField( "vortex_drain" )
	else
		amount = weapon.GetWeaponInfoFileKeyField( "vortex_drain" )

	if ( !amount )
		return

	amount = amount.tofloat()

	if ( damageType == damageTypes.Electric )
		amount *= 1.5

	local currentHealth = vortexSphere.GetHealth()
	vortexSphere.SetHealth( currentHealth - amount )
	UpdateShieldWallColorForFrac( vortexSphere.s.shieldWallFX, GetHealthFrac( vortexSphere ) )

	if ( vortexSphere.GetHealth() <= 0 )
	{
		// play break FX
	}
}

function UpdateShieldWallColorForFrac( shieldWallFX, colorFrac )
{
	local color = GetShieldTriLerpColor( 1 - colorFrac )
	shieldWallFX.s.cpoint.SetOrigin( color )
}

function CodeCallback_OnVortexHitBullet( vortexSphere, damageInfo )
{
	local owner = vortexSphere.GetOwner()
	if ( owner != null && owner.IsNPC() && owner.GetBossPlayer() == null )
	{
		return CodeCallback_OnVortexHitBullet_BubbleShieldNPC( vortexSphere, damageInfo )
	}

	local damageAngles = vortexSphere.GetAngles()
	damageAngles = damageAngles.AnglesCompose( Vector( 90, 0, 0 ) )
	if ( IsClient() )
	{
		// TODO: slightly change angles to match radius rotation of vortex cylinder
		local effectHandle = StartParticleEffectInWorldWithHandle( GetParticleSystemIndex( SHIELD_WALL_BULLET_FX ), damageInfo.GetDamagePosition(), damageAngles )
		//local color = GetShieldTriLerpColor( 1 - GetHealthFrac( vortexSphere ) )
		local color = GetShieldTriLerpColor( 0 )
		EffectSetControlPointVector( effectHandle, 1, color )

		if ( damageInfo.GetAttacker() && damageInfo.GetAttacker().IsTitan() )
			EmitSoundAtPosition( damageInfo.GetDamagePosition(), "TitanShieldWall.Heavy.BulletImpact_1P_vs_3P" )
		else
			EmitSoundAtPosition( damageInfo.GetDamagePosition(), "TitanShieldWall.Light.BulletImpact_1P_vs_3P" )
	}
	else
	{
		PlayFXWithControlPoint( SHIELD_WALL_BULLET_FX, damageInfo.GetDamagePosition(), vortexSphere.s.shieldWallFX.s.cpoint, null, null, damageAngles )
		VortexSphereDrainHealthForDamage( vortexSphere, damageInfo.GetWeapon(), null )

		if ( damageInfo.GetAttacker() && damageInfo.GetAttacker().IsTitan() )
			EmitSoundAtPosition( damageInfo.GetDamagePosition(), "TitanShieldWall.Heavy.BulletImpact_3P_vs_3P" )
		else
			EmitSoundAtPosition( damageInfo.GetDamagePosition(), "TitanShieldWall.Light.BulletImpact_3P_vs_3P" )
	}
	return true
}

function CodeCallback_OnVortexHitBullet_BubbleShieldNPC( vortexSphere, damageInfo )
{
	local vortexOrigin 	= vortexSphere.GetOrigin()
	local damageOrigin 	= damageInfo.GetDamagePosition()

	local dist = DistanceSqr( vortexOrigin, damageOrigin )
	if ( dist < MINION_BUBBLE_SHIELD_RADIUS_SQR )
		return false//the damage is coming from INSIDE the sphere

	local damageVec 	= damageOrigin - vortexOrigin
	local damageAngles 	= VectorToAngles( damageVec )
	damageAngles = damageAngles.AnglesCompose( Vector( 90, 0, 0 ) )

	if ( IsClient() )
	{
		local effectHandle = StartParticleEffectInWorldWithHandle( GetParticleSystemIndex( SHIELD_WALL_BULLET_FX ), damageOrigin, damageAngles )

		local color = GetShieldTriLerpColor( 0.9 )
		EffectSetControlPointVector( effectHandle, 1, color )

		if ( damageInfo.GetAttacker() && damageInfo.GetAttacker().IsTitan() )
			EmitSoundAtPosition( damageInfo.GetDamagePosition(), "TitanShieldWall.Heavy.BulletImpact_1P_vs_3P" )
		else
			EmitSoundAtPosition( damageInfo.GetDamagePosition(), "TitanShieldWall.Light.BulletImpact_1P_vs_3P" )
	}
	else
	{
		PlayFXWithControlPoint( SHIELD_WALL_BULLET_FX, damageOrigin, vortexSphere.s.shieldWallFX.s.cpoint, null, null, damageAngles )
		//VortexSphereDrainHealthForDamage( vortexSphere, damageInfo.GetWeapon(), null )

		if ( damageInfo.GetAttacker() && damageInfo.GetAttacker().IsTitan() )
			EmitSoundAtPosition( damageInfo.GetDamagePosition(), "TitanShieldWall.Heavy.BulletImpact_3P_vs_3P" )
		else
			EmitSoundAtPosition( damageInfo.GetDamagePosition(), "TitanShieldWall.Light.BulletImpact_3P_vs_3P" )
	}
	return true
}

function CodeCallback_OnVortexHitProjectile( vortexSphere, attacker, projectile, contactPos )
{
	local owner = vortexSphere.GetOwner()
	if ( owner != null && owner.IsNPC() && owner.GetBossPlayer() == null )
	{
		return CodeCallback_OnVortexHitProjectile_BubbleShieldNPC( vortexSphere, attacker, projectile, contactPos )
	}

	local damageAngles = vortexSphere.GetAngles()
	damageAngles = damageAngles.AnglesCompose( Vector( 90, 0, 0 ) )
	if ( IsClient() )
	{
		local effectHandle = StartParticleEffectInWorldWithHandle( GetParticleSystemIndex( SHIELD_WALL_EXPMED_FX ), contactPos, damageAngles )
		//local color = GetShieldTriLerpColor( 1 - GetHealthFrac( vortexSphere ) )
		local color = GetShieldTriLerpColor( 0 )
		EffectSetControlPointVector( effectHandle, 1, color )

		EmitSoundAtPosition( contactPos, "TitanShieldWall.Explosive.BulletImpact_1P_vs_3P" )
	}
	else
	{
		PlayFXWithControlPoint( SHIELD_WALL_EXPMED_FX, contactPos, vortexSphere.s.shieldWallFX.s.cpoint, null, null, damageAngles )
		VortexSphereDrainHealthForDamage( vortexSphere, null, projectile )

		EmitSoundAtPosition( contactPos, "TitanShieldWall.Explosive.BulletImpact_3P_vs_3P" )

		if ( projectile.GetDamageSourceID() == eDamageSourceId.mp_titanweapon_dumbfire_rockets )
		{
			local normal = projectile.GetVelocity() * -1
			normal.Normalize()
			ClusterRocket_Detonate( projectile, normal )
			CreateNoSpawnArea( vortexSphere.GetTeam(), contactPos, ( CLUSTER_ROCKET_BURST_COUNT / 5.0 ) * 0.5 + 1.0, CLUSTER_ROCKET_BURST_RANGE + 100 )
		}
	}
	return true
}

function CodeCallback_OnVortexHitProjectile_BubbleShieldNPC( vortexSphere, attacker, projectile, contactPos )
{
	local vortexOrigin 	= vortexSphere.GetOrigin()

	local dist = DistanceSqr( vortexOrigin, contactPos )
	if ( dist < MINION_BUBBLE_SHIELD_RADIUS_SQR )
		return false//the damage is coming from INSIDE the sphere

	local damageVec 	= contactPos - vortexOrigin
	damageVec.Normalize()
	local damageAngles 	= VectorToAngles( damageVec )
	damageAngles = damageAngles.AnglesCompose( Vector( 90, 0, 0 ) )

	if ( IsClient() )
	{
		local effectHandle = StartParticleEffectInWorldWithHandle( GetParticleSystemIndex( SHIELD_WALL_EXPMED_FX ), contactPos, damageAngles )

		local color = GetShieldTriLerpColor( 0.9 )
		EffectSetControlPointVector( effectHandle, 1, color )

		EmitSoundAtPosition( contactPos, "TitanShieldWall.Explosive.BulletImpact_1P_vs_3P" )
	}
	else
	{
		PlayFXWithControlPoint( SHIELD_WALL_EXPMED_FX, contactPos, vortexSphere.s.shieldWallFX.s.cpoint, null, null, damageAngles )
		VortexSphereDrainHealthForDamage( vortexSphere, null, projectile )

		EmitSoundAtPosition( contactPos, "TitanShieldWall.Explosive.BulletImpact_3P_vs_3P" )

		if ( projectile.GetDamageSourceID() == eDamageSourceId.mp_titanweapon_dumbfire_rockets )
		{
			local normal = projectile.GetVelocity() * -1
			normal.Normalize()
			ClusterRocket_Detonate( projectile, normal )
			CreateNoSpawnArea( vortexSphere.GetTeam(), contactPos, ( CLUSTER_ROCKET_BURST_COUNT / 5.0 ) * 0.5 + 1.0, CLUSTER_ROCKET_BURST_RANGE + 100 )
		}
	}
	return true
}

function VortexReflectAttack( vortexWeapon, attackParams, reflectOrigin )
{
	local vortexSphere = vortexWeapon.GetWeaponUtilityEntity()
	if ( !vortexSphere )
		return 0

	if ( IsServer() )
		Assert( vortexSphere )

	local weaponOwner = vortexWeapon.GetWeaponOwner()

	local totalfired = 0

	local forceReleased = false
	// in this case, it's also considered "force released" if the charge time runs out
	if ( vortexWeapon.IsForceRelease() || vortexWeapon.GetWeaponChargeFraction() == 1 )
		forceReleased = true

	//Requires code feature to properly fire tracers from offset positions.
	//if ( vortexWeapon.GetWeaponModSetting( "is_burn_mod" ) )
	//	attackParams.pos = reflectOrigin

	// PREDICTED REFIRES
	// bullet impact events don't individually fire back per event because we aggregate and then shotgun blast them

	//Remove the below script after FireWeaponBulletBroadcast
	//local bulletsFired = Vortex_FireBackBullets( vortexWeapon, attackParams )
	//totalfired += bulletsFired
	local bulletCount = GetBulletsAbsorbedCount( vortexWeapon )
	if ( bulletCount > 0 )
	{
		if ( "ampedBulletCount" in vortexWeapon.s )
			vortexWeapon.s.ampedBulletCount++
		else
			vortexWeapon.s.ampedBulletCount <- 1
		vortexWeapon.Signal( "FireAmpedVortexBullet" )
		totalfired += 1
	}

	// UNPREDICTED REFIRES
	if ( IsServer() )
	{
		//printt( "server: force released?", forceReleased )


		local unpredictedRefires = Vortex_GetProjectileImpacts( vortexWeapon )

		// HACK we don't actually want to refire them with a spiral but
		//   this is to temporarily ensure compatibility with the Titan rocket launcher
		if ( !( "spiralMissileIdx" in vortexWeapon.s ) )
			vortexWeapon.s.spiralMissileIdx <- null
		vortexWeapon.s.spiralMissileIdx = 0

		foreach ( impactData in unpredictedRefires )
		{
			if ( !impactData.fireFunction )
				continue

			if ( impactData.fireFunction( vortexWeapon, attackParams, impactData ) )
				totalfired++
		}
	}

	SetVortexAmmo( vortexWeapon, 0 )

	vortexWeapon.Signal( "VortexFired" )
	vortexSphere.kv.bullet_absorbed_count = 0

	/*
	if ( forceReleased )
		DestroyVortexSphere( vortexWeapon )
	else
		DisableVortexSphere( vortexWeapon )
	*/

	return totalfired
}