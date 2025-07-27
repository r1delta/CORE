//_weapon_utility.nut
// where self = a megaweapon

const PROJECTILE_PREDICTED = true
const PROJECTILE_NOT_PREDICTED = false

if ( !reloadingScripts )
	level.weaponsPrecached <- {}

// what classes can sticky thrown entities stick to?
if ( !reloadingScripts )
{
	level.stickyClasses <- {}
	level.stickyClasses[ "worldspawn" ]			<- true
	level.stickyClasses[ "player" ]				<- true
	level.stickyClasses[ "npc_titan" ]			<- true
	level.stickyClasses[ "npc_spectre" ]		<- true
	level.stickyClasses[ "npc_turret_mega" ]	<- true
	level.stickyClasses[ "npc_turret_sentry" ]	<- true
	level.stickyClasses[ "npc_dropship" ]		<- true
	level.stickyClasses[ "prop_dynamic" ]		<- true

	level.trapChainReactClasses <- {}
	level.trapChainReactClasses[ "mp_weapon_frag_grenade" ]			<- true
	level.trapChainReactClasses[ "mp_weapon_grenade_repeating" ]	<- true
	level.trapChainReactClasses[ "mp_weapon_satchel" ]				<- true
	level.trapChainReactClasses[ "mp_weapon_proximity_mine" ] 		<- true
	level.trapChainReactClasses[ "mp_weapon_laser_mine" ]			<- true

	level.laserMineTripClasses <- {}
	level.laserMineTripClasses[ "player" ]							<- true
	level.laserMineTripClasses[ "npc_titan" ]						<- true
	level.laserMineTripClasses[ "npc_soldier" ]						<- true
	level.laserMineTripClasses[ "npc_spectre" ]						<- true
	level.laserMineTripClasses[ "npc_marvin" ]						<- true
	level.laserMineTripClasses[ "npc_cscanner" ]					<- true
	level.laserMineTripClasses[ "npc_dropship" ]					<- true
	level.laserMineTripClasses[ "npc_grenade_frag" ]				<- true  // ensures we get "grenade" type impacts. they are further sorted by laserMineTripClasses_GrenadeWeapons

	level.laserMineTripClasses_GrenadeWeapons <- {}
	level.laserMineTripClasses_GrenadeWeapons[ "mp_weapon_satchel" ]			<- true
	level.laserMineTripClasses_GrenadeWeapons[ "mp_weapon_proximity_mine" ]		<- true
	level.laserMineTripClasses_GrenadeWeapons[ "mp_weapon_laser_mine" ]			<- true
	level.laserMineTripClasses_GrenadeWeapons[ "mp_titanweapon_triple_threat" ]	<- true

	RegisterSignal( "Planted" )
	RegisterSignal( "OnTurretTargetChanged" )
	RegisterSignal( "StopWeaponRumble" )
}

////////////////////////////////////////////////////////////////////

function WeaponIsPrecached( weapon )
{
	if ( weapon.GetClassname() in level.weaponsPrecached )
		return true

	level.weaponsPrecached[ weapon.GetClassname() ] <- 1

	return false
}

function GlobalClientEventHandler( name )
{
	if ( name == "ammo_update" )
		UpdateViewmodelAmmo()

	if ( name == "ammo_full" )
		UpdateViewmodelAmmo( true )
}

function UpdateViewmodelAmmo( forceFull = false )
{
	if ( !IsClient() )
		return

	if ( !IsValid( self ) )
		return

	if ( !IsLocalViewPlayer( self.GetWeaponOwner() ) )
		return

	local rounds = self.GetWeaponPrimaryClipCount()
	if ( forceFull || ( rounds > AMMO_BODYGROUP_COUNT ) )
		rounds = AMMO_BODYGROUP_COUNT

	//printt( "Updating for rounds: " + rounds );
	self.SetViewmodelAmmoModelIndex( rounds )
}

function PlayWeaponSoundWithVolume( sound, volume )
{
	self.EmitWeaponSound( sound )
	SetSoundVolumeOnEntity( self, sound, volume )
}

function PlayWeaponSound_1p3p( firstPersonSound, thirdPersonSound )
{
	if ( IsClient() )
	{
		local owner = self.GetWeaponOwner()
		if ( IsLocalViewPlayer( owner ) )
			self.EmitWeaponSound( firstPersonSound )
		else
			self.EmitWeaponSound( thirdPersonSound )
	}
	else
		self.EmitWeaponSound( thirdPersonSound )
}

function SetLoopingWeaponSound_1p3p( firstPersonFirst, firstPersonLoop, firstPersonLast , thirdPersonFirst, thirdPersonLoop, thirdPersonLast )
{
	self.SetLoopingWeaponSound( firstPersonFirst, firstPersonLoop, firstPersonLast,
	                            thirdPersonFirst, thirdPersonLoop, thirdPersonLast )
}

const ADS_FRACTION_THRESHOLD = 0.5
function HandleWeaponSoundZoomIn( weapon, sound )
{
	if ( !IsClient() )
		return

	local owner = weapon.GetWeaponOwner()
	if ( !IsValid( owner ) )
		return

	local frac = owner.GetAdsFraction()
	if ( frac > ADS_FRACTION_THRESHOLD )
		return;

	weapon.EmitWeaponSound( sound )
}


function HandleWeaponSoundZoomOut( weapon, sound )
{
	if ( !IsClient() )
		return

	local owner = weapon.GetWeaponOwner()
	if ( !IsValid( owner ) )
		return

	local frac = owner.GetAdsFraction()
	if ( frac < ADS_FRACTION_THRESHOLD )
		return;

	weapon.EmitWeaponSound( sound )
}

function AttachWeaponTrailEffect( bolt, scriptalias, weapon = null )
{
	local boltTrail = CreateEntity( "info_particle_system" )
	boltTrail.SetOrigin( bolt.GetOrigin() )
	boltTrail.SetAngles( bolt.GetAngles() )  // set FX angles to match the weapon angles

	// optionally use another weapon's script scope (if calling from outside a megaweapon script)
	local weaponEffect = null
	if ( weapon != null )
		weaponEffect = weapon.GetScriptScope().GetWeaponEffect( scriptalias )

	if ( !weaponEffect )
		weaponEffect = GetWeaponEffect( scriptalias )

	boltTrail.kv.effect_name = weaponEffect
	boltTrail.kv.start_active = 1
	DispatchSpawn( boltTrail, false )

	boltTrail.SetParent ( bolt )
}

function HasPredictiveTargetingSupport()
{
	if ( !( "supportsPredictiveTargeting" in self.scope() ) )
		return false

	return self.scope().supportsPredictiveTargeting
}

function GetProjectileSpeed()
{
	Assert( "PROJECTILE_SPEED" in self.GetScriptScope(), "Couldn't get projectile speed for weapon " + self + ". Set PROJECTILE_SPEED in the megaweapon script." )
	return self.GetScriptScope().PROJECTILE_SPEED
}

function ShouldBleed( hitParams )
{
	local owner = self.GetWeaponOwner()
	local myTeam = owner.GetTeam()
	local victim = hitParams.hitEnt
	local classname = hitParams.hitEnt.GetClassname()


	if (victim.GetTeam() == myTeam)
		return false

	if	(classname == "npc_soldier")
		return true

	if	(classname != "player")
		return false

	if  (victim.GetPlayerClass() == "wallrun")
		return true

	return false
}

function DoColorCorrection( player, fileName, fadeInDuration = 1.0, duration = 0, fadeOutDuration = 1.0, isMaster = 1 )
{
	if ( IsClient() )
		return

	local colorCorrection = GetColorCorrectionByFileName( player, fileName )

	if ( !colorCorrection )
		return null

	colorCorrection.kv.fadeInDuration = fadeInDuration
	colorCorrection.kv.fadeOutDuration = fadeOutDuration
	colorCorrection.kv.spawnflags = isMaster

	colorCorrection.Fire( "Enable" )
	colorCorrection.Fire( "Disable", "", fadeInDuration + duration + 0.1 )
}


function EnableColorCorrection( player, fileName, fadeInDuration = 1.0 )
{
	if ( IsClient() )
		return

	player.EndSignal( "Disconnected" )

	local colorCorrection = GetColorCorrectionByFileName( player, fileName )

	if ( !colorCorrection )
		return null

	colorCorrection.kv.fadeInDuration = fadeInDuration
	colorCorrection.kv.spawnflags = 1

	colorCorrection.Fire( "Enable" )
}


function DisableColorCorrection( player, fileName, fadeOutDuration = 1.0 )
{
	if ( IsClient() )
		return

	local colorCorrection = GetColorCorrectionByFileName( player, fileName )

	if ( !colorCorrection )
		return null

	colorCorrection.kv.fadeOutDuration = fadeOutDuration

	colorCorrection.Fire( "Disable" )
}


function GetColorCorrectionByFileName( player, fileName )
{
	if ( !player )
		return null

	if ( !( "colorCorrections" in player.s ) )
		player.s.colorCorrections <- {}

	if ( !( fileName in player.s.colorCorrections ) )
		player.s.colorCorrections[fileName] <- null

	if ( !IsValid( player.s.colorCorrections[fileName] ) )
	{
		//printt( "creating color corr" )
		local color_correction = CreateOwnedEntity( "color_correction", player )
		color_correction.SetName( player.GetName() + fileName )
		color_correction.kv.StartDisabled = 1
		color_correction.kv.minfalloff = -1
		color_correction.kv.maxfalloff = -1
		color_correction.kv.maxweight = 1.0
		color_correction.kv.filename = fileName
		color_correction.kv.fadeInDuration = 0.1
		color_correction.kv.fadeOutDuration = 0.1
		color_correction.kv.spawnflags = 1
		DispatchSpawn( color_correction, false )
		color_correction.SetOwner( player )

		player.s.colorCorrections[fileName] = color_correction
	}

	return player.s.colorCorrections[fileName]
}

function ApplyVectorSpread( vecShotDirection, spreadDegrees, bias = 1.0 )
{
	local angles = VectorToAngles( vecShotDirection )
	local vecUp = angles.AnglesToUp()
	local vecRight = angles.AnglesToRight()

	local sinDeg = deg_sin( spreadDegrees / 2.0 )

	// get circular gaussian spread
	local x
	local y
	local z

	if ( bias > 1.0 )
		bias = 1.0;
	else if ( bias < 0.0 )
		bias = 0.0;

	// code gets these values from cvars ai_shot_bias_min & ai_shot_bias_max
	local shotBiasMin = -1.0
	local shotBiasMax = 1.0

	// 1.0 gaussian, 0.0 is flat, -1.0 is inverse gaussian
	local shotBias = ( ( shotBiasMax - shotBiasMin ) * bias ) + shotBiasMin
	local flatness = ( fabs(shotBias) * 0.5 )

	while ( 1 )
	{
		x = RandomFloat(-1,1) * flatness + RandomFloat(-1,1) * (1 - flatness)
		y = RandomFloat(-1,1) * flatness + RandomFloat(-1,1) * (1 - flatness)
		if ( shotBias < 0 )
		{
			x = ( x >= 0 ) ? 1.0 - x : -1.0 - x
			y = ( y >= 0 ) ? 1.0 - y : -1.0 - y
		}
		z = x*x+y*y

		if (z <= 1)
			break
	}

	local addX = vecRight * ( x * sinDeg )
	local addY = vecUp * ( y * sinDeg )
	local m_vecResult = vecShotDirection + addX + addY

	return m_vecResult
}


function SetVortexPush( amount )
{
	if ( !( "vortexPush" in self.s ) )
		self.s.vortexPush <- null

	self.s.vortexPush = amount
}

function SetDamagePush( amount )
{
	if ( !( "damagePush" in self.s ) )
		self.s.damagePush <- null

	self.s.damagePush = amount
}

function WaitForExplosiveProjectileImpact( bolt, player, explosionSFX, splashDamageAmount, splashDamageAmountHeavy, splashDamageRadius, splashPushMagnitude, dmgSourceID )
{
	Assert( IsServer() )

	bolt.EndSignal( "HitSky" )

	local team = player.GetTeam()

	local result = bolt.WaitSignal( "OnWeaponBoltHit" )

	ImpactExplosion( player, team, bolt.GetOrigin(), result.activator, explosionSFX, splashDamageAmount, splashDamageAmountHeavy, splashDamageRadius, splashPushMagnitude, dmgSourceID )

	bolt.Kill()
}

function ImpactExplosion( player, team, origin, ignoreEnt, explosionSFX, splashDamageAmount, splashDamageAmountHeavy, splashDamageRadius, splashPushMagnitude, damageSourceID )
{
	// explosion damage on impact
	local env_explosion = CreateEntity( "env_explosion" )
	// visuals are handled by weapon impact effect table assignment
	env_explosion.kv.spawnflags = 1836 // No Fireball, No Smoke, No Sparks, No Fireball Smoke, No particles, No DLights
	env_explosion.kv.iMagnitude = splashDamageAmount
	env_explosion.kv.iMagnitudeHeavyArmor = splashDamageAmountHeavy
	env_explosion.kv.iRadiusOverride = splashDamageRadius
	env_explosion.kv.fireballsprite = "sprites/zerogxplode.spr"
	env_explosion.kv.rendermode = 5   //additive
	env_explosion.kv.scriptDamageType = damageTypes.Explosive
	env_explosion.kv.damageSourceId = damageSourceID
	env_explosion.SetName( UniqueString() )
	env_explosion.SetOrigin( origin )
	env_explosion.SetTeam( team )
	env_explosion.SetOwner( player )
	env_explosion.AddIgnoredEntity( ignoreEnt )
	DispatchSpawn( env_explosion, false )

	// explosion SFX
	EmitSoundAtPosition( origin, explosionSFX )

	// knockback on impact
	local knockback = CreateEntity( "env_physexplosion" )
	knockback.kv.magnitude = splashPushMagnitude
	knockback.kv.radius = splashDamageRadius
	knockback.kv.spawnflags = 11 // No Damage - Only Force, Push Players, Test LOS
	knockback.SetName( UniqueString() )
	knockback.SetOrigin( origin )
	knockback.SetTeam( team )
	DispatchSpawn( knockback, false )

	// fire and cleanup
	env_explosion.Fire( "Explode" )
	knockback.Fire( "Explode" )

	env_explosion.Kill( 1.5 )
	knockback.Kill( 1.5 )
}


function DegreesToTarget( origin, forward, targetPos )
{
	local dirToTarget = (targetPos - origin)
	dirToTarget.Normalize()
	local dot = forward.Dot( dirToTarget )
	local degToTarget = (acos( dot ) * 180 / PI)
	return degToTarget
}

function ShotgunBlast( pos, dir, numBlasts, damageType, damageScaler = 1.0, maxAngle = null, maxDistance = null )
{
	Assert( numBlasts > 0 )
	local owner = self.GetWeaponOwner()

	if( IsServer() )
	{
		/*
		Debug ConVars:
			visible_ent_cone_debug_duration_client - Set to non-zero to see debug output
			visible_ent_cone_debug_duration_server - Set to non-zero to see debug output
			visible_ent_cone_debug_draw_radius - Size of trace endpoint debug draw
		*/

		if ( maxDistance == null )
			maxDistance				= self.GetMaxDamageFarDist()

		if ( maxAngle == null )
			maxAngle				= owner.IsPlayer() ? ( owner.GetAttackSpreadAngle() * 0.5 ) : 14

		local ignoredEntities 		= [ owner ]
		local traceMask 			= TRACE_MASK_SHOT

		local antilagPlayer = null
		if ( owner.IsPlayer() )
			antilagPlayer = owner

		local results = GetVisibleEntitiesInCone( pos, dir, maxDistance, (maxAngle * 1.1), ignoredEntities, traceMask, VIS_CONE_ENTS_TEST_HITBOXES, antilagPlayer, true, true )
		foreach ( result in results )
		{
			local angleToHitbox = 0.0
			if ( !result.solidBodyHit )
				angleToHitbox = DegreesToTarget( pos, dir, result.approxClosestHitboxPos )

			numBlasts -= ShotgunBlastDamageEntity( pos, dir, result, angleToHitbox, maxAngle, numBlasts, damageType, damageScaler )
			if ( numBlasts <= 0 )
				break
		}
	}

	//Something in the TakeDamage above is triggering the weapon owner to become invalid.
	owner = self.GetWeaponOwner()
	if ( !IsValid( owner ) )
		return
	// maxTracer limit set in /r1dev/src/game/client/c_baseplayer.h
	local maxTracers = 16
	if ( numBlasts > 0 )
		self.FireWeaponBullet_Special( pos, dir, min( numBlasts, maxTracers ), damageType, false, false, true, false )
}


const SHOTGUN_ANGLE_MIN_FRACTION = 0.1;
const SHOTGUN_ANGLE_MAX_FRACTION = 1.0;
const SHOTGUN_DAMAGE_SCALE_AT_MIN_ANGLE = 0.8;
const SHOTGUN_DAMAGE_SCALE_AT_MAX_ANGLE = 0.1;

function ShotgunBlastDamageEntity( barrelPos, barrelVec, result, angle, maxAngle, numPellets, damageType, damageScaler )
{
	local target = result.entity

	//The damage scaler is currently only > 1 for the Titan Shotgun alt fire.
	if ( !target.IsTitan() && damageScaler > 1 )
		damageScaler = max( damageScaler * 0.4, 1.5 )

	local owner = self.GetWeaponOwner()
	// Ent in cone not valid
	if ( !IsValid( target ) || !IsValid( owner ) )
		return 0

	// Fire fake bullet towards entity for visual purposes only
	local hitLocation = result.visiblePosition
	local vecToEnt = ( hitLocation - barrelPos )
	vecToEnt.Norm()
	if ( vecToEnt.Length() == 0 )
		vecToEnt = barrelVec

	// This fires a fake bullet that doesn't do any damage. Currently it triggeres a damage callback with 0 damage which is bad.
	self.FireWeaponBullet_Special( barrelPos, vecToEnt, 1, damageType, true, true, true, false ) // fires perfect bullet with no antilag and no spread

	// Determine how much damage to do based on distance
	local distanceToTarget = Distance( barrelPos, hitLocation )

	if ( !result.solidBodyHit ) // non solid hits take 1 blast more
		distanceToTarget += 130

	local damageAmount = CalcWeaponDamage( owner, target, self, distanceToTarget )

	// vortex needs to scale damage based on number of rounds absorbed
	if ( self.GetClassname() == "mp_titanweapon_vortex_shield" )
	{
		damageAmount *= numPellets
		//printt( "scaling vortex hitscan output damage by", numPellets, "pellets for", weaponNearDamageTitan, "damage vs titans" )
	}

	local coneScaler = 1.0;
	//if ( angle > 0 )
	//	coneScaler = GraphCapped( angle, (maxAngle * SHOTGUN_ANGLE_MIN_FRACTION), (maxAngle * SHOTGUN_ANGLE_MAX_FRACTION), SHOTGUN_DAMAGE_SCALE_AT_MIN_ANGLE, SHOTGUN_DAMAGE_SCALE_AT_MAX_ANGLE )

	// Calculate the final damage abount to inflict on the target. Also scale it by damageScaler which may have been passed in by script ( used by alt fire mode on titan shotgun to fire multiple shells )
	local finalDamageAmount = damageAmount * coneScaler * damageScaler
	//printt( "angle:", angle, "- coneScaler:", coneScaler, "- damageAmount:", damageAmount, "- damageScaler:", damageScaler, "  = finalDamageAmount:", finalDamageAmount )

	// Calculate impulse force to apply based on damage
	local maxImpulseForce = self.GetWeaponInfoFileKeyField( "impulse_force" )
	local impulseForce = maxImpulseForce * coneScaler * damageScaler
	local impulseVec = barrelVec * impulseForce

	local damageSourceID = self.GetDamageSourceID()


	// Damage the target ent
	target.TakeDamage( finalDamageAmount, owner, self, { origin = barrelPos, force = impulseVec, scriptType = damageType, damageSourceId=damageSourceID, weapon = self, hitbox = result.visibleHitbox } )

	//printt( "-----------" )
	//printt( "    distanceToTarget:", distanceToTarget )
	//printt( "    damageAmount:", damageAmount )
	//printt( "    coneScaler:", coneScaler )
	//printt( "    impulseForce:", impulseForce )
	//printt( "    impulseVec:", impulseVec.x + ", " + impulseVec.y + ", " + impulseVec.z )
	//printt( "        finalDamageAmount:", finalDamageAmount )
	//PrintTable( result )

	return 1
}

// bounceDot- sets the normals it will stick to. 1.0 will stick to contact on anything, 0.65 will allow it to stick to anything greater than about a 45 degree slope
function PlantStickyEntity( ent, collisionParams, bounceDot, rotationOffset = null, ignoreRotation = false, positionOffset = null )
{
	if ( !EntityShouldStick( ent, collisionParams.hitent ) )
		return false

	if ( !( "isStickyEnt" in ent.s ) )
		ent.s.isStickyEnt <- true

	// Don't allow parenting to another "sticky" entity to prevent them parenting onto each other
	if ( "isStickyEnt" in collisionParams.hitent.s )
		return false

	// Update normal from last bouce so when it explodes it can orient the effect properly
	if ( !( "bounceNormal" in ent.s ) )
		ent.s.bounceNormal <- Vector( 0, 0, 0 )
	ent.s.bounceNormal = collisionParams.normal

	local attachTag = null
	if ( collisionParams.hitent == GetEntByIndex( 0 ) )
	{
		// Satchel hit the world
		local dot = collisionParams.normal.Dot( Vector( 0, 0, 1 ) )
		if ( dot > bounceDot )
			return false
	}

	local plantAngles
	if ( ignoreRotation )
		plantAngles = ent.GetAngles()
	else
		plantAngles = VectorToAngles( collisionParams.normal )

	if ( rotationOffset != null )
		plantAngles = plantAngles.AnglesCompose( rotationOffset )

	local plantPosition = collisionParams.pos
	if ( positionOffset != null )
		plantPosition = PositionOffsetFromOriginAngles( plantPosition, plantAngles, positionOffset.x, positionOffset.y, positionOffset.z )

	if ( !LegalOrigin( plantPosition ) )
		return false

	if ( IsServer() )
	{
		ent.s.planted = true
		ent.SetAbsOrigin( plantPosition )
		ent.SetAbsAngles( plantAngles )
	}
	else
	{
		ent.SetOrigin( plantPosition )
		ent.SetAngles( plantAngles )
	}
	ent.SetVelocity( Vector( 0, 0, 0 ) )

	//printt( " - Hitbox is:", collisionParams.hitbox, " IsWorld:", collisionParams.hitent )
	if ( !collisionParams.hitent.IsWorld() )
	{
		if ( !ent.IsMarkedForDeletion() && !collisionParams.hitent.IsMarkedForDeletion() )
		{
			ent.SetParentWithHitbox( collisionParams.hitent, collisionParams.hitbox, true )
		}
		ent.MarkAsAttached()
	}
	else
	{
		ent.SetVelocity( Vector( 0, 0, 0 ) )
		ent.StopPhysics()
		ent.MarkAsAttached()
	}

	//printt( "PlantStickyEntity" )
	//DebugDrawLine( collisionParams.pos, collisionParams.pos + Vector( 0, 0, 8000 ), 255, 0, 0, true, 100 )

	ent.Signal( "Planted" )

	return true
}

function EntityShouldStick( stickyEnt, hitent )
{
	if ( "planted" in stickyEnt.s && stickyEnt.s.planted == true )
		return false

	if ( !EntityCanHaveStickyEnts( hitent ) )
		return false

	if ( hitent == stickyEnt )
		return false

	return true
}

function EntityCanHaveStickyEnts( ent )
{
	if ( !IsValid( ent ) )
		return false

	Assert( ent.GetModelName() != null, "Sticky entity received OnProjectileCollision callback, but hitent " + ent + " has no model name specified" )

	local entClassname
	if ( IsServer() )
		entClassname = ent.GetClassname()
	else
		entClassname = ent.GetSignifierName()

	if ( !( entClassname in level.stickyClasses ) )
		return false

	// not pilots
	if ( ent.IsPlayer() && !ent.IsTitan() )
		return false

	return true
}

// shared with the vortex script which also needs to create satchels
function Satchel_PostFired_Init( satchel, player )
{
	satchel.s.onlyAllowSmartPistolDamage = false
	PlayerTrackSatchel( player, satchel )
	thread SatchelThink( satchel, player )
}

function SatchelThink( satchel, player )
{
	player.EndSignal("Disconnected")
	satchel.EndSignal("OnDestroy")

	local satchelHealth = 50
	thread TrapExplodeOnDamage( satchel, satchelHealth )
	thread SatchelExplodeOnClacker( satchel, player )
	thread SatchelHandleVortexAbsorption( satchel, player )

	// temp HACK for FX to use to figure out the size of the particle to play
	if ( Flag( "ShowExplosionRadius" ) )
		AddEntityDestroyedCallback( satchel, ShowExplosionRadiusOnExplode )

	WaitSignal( player, "OnRespawnPlayer", "NewPilotOrdnance" )
	if ( IsValid( satchel ) )
		satchel.Kill()
}

function SatchelExplodeOnClacker( satchel, player )
{
	Assert( IsValid( player ) )

	satchel.EndSignal( "OnDestroy")

	local startTime = Time()

	local result = WaitSignal( satchel, "DetonateSatchels" )
	local idx = result.satchelIdx

	// new
	wait SATCHEL_DETONATE_DELAY

	//thread EnableTrapWarningSound( satchel )

	if ( idx > 0 )
		Wait( RandomFloat( 0.07, 0.1 ) * idx )
	// end new

	/*
	if ( !satchel.s.planted )
	{
		thread EnableTrapWarningSound( satchel )

		satchel.WaitSignal( "Planted" )

		// slight delay before detonation
		wait 0.25
	}
	else
	{
		// don't want all satchels to explode at once
		if ( idx > 0 )
			Wait( RandomFloat( 0.07, 0.1 ) * idx )
	}
	*/

	PlayerUnTrackSatchel( player, satchel )

	if ( IsValid( satchel ) )
		satchel.Explode( satchel.s.bounceNormal )
}

function SatchelHandleVortexAbsorption( satchel, player )
{
	satchel.WaitSignal( "VortexAbsorbed" )

	//printt( "satchel absorbed by vortex!" )
	PlayerUnTrackSatchel( player, satchel )
}

function ProximityMineHandleVortexAbsorption( proximityMine, player )
{
	proximityMine.WaitSignal( "VortexAbsorbed" )

	//printt( "proximity mine absorbed by vortex!" )
	PlayerUnTrackProximityMine( player, proximityMine )
}

function ProximityCharge_PostFired_Init( proximityMine, player )
{
	proximityMine.s.onlyAllowSmartPistolDamage = false
	PlayerTrackProximityMine( player, proximityMine )
}

function PlayerTrackSatchel( player, satchel )
{
	player.s.activeSatchels.append( satchel )
	ArrayRemoveInvalid( player.s.activeSatchels )
}

function PlayerTrackProximityMine( player, proximityMine )
{
	player.s.activeProximityMines.append( proximityMine )
	ArrayRemoveInvalid( player.s.activeProximityMines )
}

function PlayerTrackTripleThreatMine( player, mine )
{
	player.s.activeTripleThreatMines.append( mine )
	ArrayRemoveInvalid( player.s.activeTripleThreatMines )
}

function PlayerUnTrackSatchel( player, satchel )
{
	if ( !IsValid_ThisFrame( player ) )
		return

	if ( !IsValid_ThisFrame( satchel ) )
		return

	ArrayRemoveInvalid( player.s.activeSatchels )
	ArrayRemove( player.s.activeSatchels, satchel )
}

function PlayerUnTrackProximityMine( player, mine )
{
	if ( !IsValid_ThisFrame( player ) )
		return

	if ( !IsValid_ThisFrame( mine ) )
		return

	ArrayRemoveInvalid( player.s.activeProximityMines )
	ArrayRemove( player.s.activeProximityMines, mine )
}

function PlayerUnTrackTripleThreatMine( player, mine )
{
	if ( !IsValid_ThisFrame( player ) )
		return

	if ( !IsValid_ThisFrame( mine ) )
		return

	ArrayRemoveInvalid( player.s.activeTripleThreatMines )
	ArrayRemove( player.s.activeTripleThreatMines, mine )
}

// gets called from callback functions when players die or disconnect
function CleanupPlayerSatchels( player )
{
	ArrayRemoveInvalid( player.s.activeSatchels )

	local satchels = clone player.s.activeSatchels
	foreach ( satchel in satchels )
		CleanupPlayerSatchel( player, satchel )
}

function CleanupPlayerProximityMines( player )
{
	ArrayRemoveInvalid( player.s.activeProximityMines )

	local mines = clone player.s.activeProximityMines
	foreach ( mine in mines )
		CleanupPlayerProximityMine( player, mine )
}

function CleanupPlayerTripleThreatMines( player )
{
	ArrayRemoveInvalid( player.s.activeTripleThreatMines )

	local mines = clone player.s.activeTripleThreatMines
	foreach ( mine in mines )
		CleanupPlayerTripleThreatMine( player, mine )
}

function CleanupPlayerSatchel( player, satchel )
{
	PlayerUnTrackSatchel( player, satchel )
	satchel.Kill()
}

function CleanupPlayerProximityMine( player, mine )
{
	PlayerUnTrackProximityMine( player, mine )
	mine.Kill()
}

function CleanupPlayerTripleThreatMine( player, mine )
{
	PlayerUnTrackTripleThreatMine( player, mine )
	mine.Kill()
}

function DetonateAllPlantedExplosives( player )
{
	// ToDo: Could use Player_DetonateSatchels but it only tracks satchels, not laser mines.

	// Detonate all explosives - satchels and laser mines are also frag grenades in disguise
	local grenades = GetProjectileArrayEx( "npc_grenade_frag", -1, Vector( 0, 0, 0 ), -1 )

	foreach( grenade in grenades )
	{
		if ( grenade.GetOwner() != player )
			continue

		if ( grenade.GetDamageSourceID() != eDamageSourceId.mp_weapon_satchel && grenade.GetDamageSourceID() != eDamageSourceId.mp_weapon_proximity_mine )
			continue

		thread ExplodePlantedGrenadeAfterDelay( grenade, RandomFloat( 0.75, 0.95 ) )
	}
}

function ExplodePlantedGrenadeAfterDelay( grenade, delay )
{
	grenade.EndSignal( "OnDeath" )
	grenade.EndSignal( "OnDestroy" )

	local endTime = Time() + delay

	while ( Time() < endTime )
	{
		EmitSoundOnEntity( grenade, DEFAULT_WARNING_SFX	)
		wait 0.1
	}

	local normal = ( "bounceNormal" in grenade.s ) ? grenade.s.bounceNormal : Vector( 0, 0, 0 )
	grenade.Explode( normal )
}

function Player_DetonateSatchels( player )
{
	Assert( IsServer() )
	Assert( "activeSatchels" in player.s )

	ArrayRemoveInvalid( player.s.activeSatchels )

	player.Signal( "DetonateSatchels" )

	foreach ( idx, satchel in player.s.activeSatchels )
		satchel.Signal( "DetonateSatchels", { satchelIdx = idx } )
}


function ShowExplosionRadiusOnExplode( ent )
{
	local innerRadius = self.GetWeaponInfoFileKeyField( "explosion_inner_radius" )
	local outerRadius = self.GetWeaponInfoFileKeyField( "explosionradius" )

	local org = ent.GetOrigin()
	local angles = Vector( 0, 0, 0 )
	thread DebugDrawCircle( org, angles, innerRadius, 255, 255, 51, 3 )
	thread DebugDrawCircle( org, angles, outerRadius, 255, 255, 255, 3 )
}

// shared between nades, satchels and laser mines
function TrapExplodeOnDamage( trapEnt, trapEntHealth = 50, waitMin = 0.0, waitMax = 0.0 )
{
	EndSignal( trapEnt, "OnDestroy" )

	trapEnt.SetDamageNotifications( true )
	local trapEntHealth = trapEntHealth
	local results
	local attacker

	while ( 1 )
	{
		if ( !IsValid( trapEnt ) )
			return
		results = WaitSignal( trapEnt, "OnDamaged" )
		attacker = results.activator
		local shouldDamageTrap = false
		if( "onlyAllowSmartPistolDamage" in trapEnt.s && trapEnt.s.onlyAllowSmartPistolDamage == true )
		{
				if( IsValid( attacker ) && ( attacker.IsNPC() || attacker.IsPlayer() ) )
				{
					local attackerWeapon = attacker.GetActiveWeapon()
					if( IsValid(attackerWeapon) && attackerWeapon.GetClassname() == "mp_weapon_smart_pistol")
						shouldDamageTrap = true
				}
		}
		else
		{
			shouldDamageTrap = true
		}

		if ( shouldDamageTrap )
			trapEntHealth -= results.value

		if ( trapEntHealth <= 0 )
			break
	}

	if ( !IsValid( trapEnt ) )
		return

	local inflictor = results.inflictor // waiting on code feature to pass inflictor with OnDamaged signal results table

	if ( waitMin >= 0 && waitMax > 0 )
	{
		local waitTime = RandomFloat( waitMin, waitMax )

		if ( waitTime > 0 )
			wait waitTime
	}
	else if ( IsValid( inflictor ) && "GetDamageSourceID" in inflictor )
	{
		local dmgSourceID = inflictor.GetDamageSourceID()
		local inflictorClass = GetNameFromDamageSourceID( dmgSourceID )

		if ( inflictorClass in level.trapChainReactClasses )
		{
			// chain reaction delay
			Wait( RandomFloat( 0.2, 0.275 ) )
		}
	}

	if ( !IsValid( trapEnt ) )
		return

	if ( IsValid( attacker ) )
	{
		if ( attacker.IsPlayer() )
		{
			AddPlayerScoreForTrapDestruction( attacker, trapEnt )
			trapEnt.SetOwner( attacker )

			// Give satchels on the titan a slightly longer fuse so they don't blow up as the pilot is ejecting. The 0.2 wait gives the pilot enough time to clear the blast zone
			if ( ( attacker.pilotEjecting ) && ( Time() - attacker.pilotEjectStartTime <= 1.0 ) && trapEnt.s.planted == true )
				wait 0.2
		}
		else if ( "lastAttacker" in attacker.s )
		{
			// for chain explosions, figure out the attacking player that started the chain
			trapEnt.SetOwner( attacker.s.lastAttacker )
		}
	}

	trapEnt.Explode( trapEnt.s.bounceNormal )
}

function AddPlayerScoreForTrapDestruction( player, trapEnt )
{
	// don't get score for killing your own trap
	if ( "originalOwner" in trapEnt.s && trapEnt.s.originalOwner == player )
		return

	local trapClass = trapEnt.GetWeaponClassName()
	if ( !trapClass )
		return

	local scoreEvent = null
	if ( trapClass == "mp_weapon_satchel" )
		scoreEvent = "Destroyed_Satchel"
	else if ( trapClass == "mp_weapon_proximity_mine" )
		scoreEvent = "Destored_Proximity_Mine"
	else if ( trapClass == "mp_weapon_laser_mine" )
		scoreEvent = "Destroyed_Laser_Mine"

	if ( !scoreEvent )
		return

	AddPlayerScore( player, scoreEvent, trapEnt )
}

function GetBulletPassThroughTargets( attacker, hitParams )
{
	//HACK requires code later
	passThroughInfo <- {}
	passThroughInfo.endPos <- null
	passThroughInfo.targetArray <- []

	local result = null
	local ignoreEnts = [ attacker, hitParams.hitEnt ]

	while ( 1 )
	{
		local vector = ( hitParams["hitPos"] - hitParams["startPos"] ) * 1000
		ArrayRemoveInvalid( ignoreEnts )
		result = TraceLine( hitParams["startPos"], vector, ignoreEnts, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )

		if ( result.hitEnt == level.worldspawn )
			break

		ignoreEnts.append( result.hitEnt )

		if ( IsValidPassThroughTarget( result.hitEnt, attacker ) )
			passThroughInfo.targetArray.append( result.hitEnt )
	}
	passThroughInfo.endPos = result.endPos

	return passThroughInfo
}


function WeaponCanCrit( weapon )
{
	// player sometimes has no weapon during titan exit, mantle, etc...
	if ( !weapon )
		return false

	return weapon.IsCriticalHitWeapon()
}


function WeaponCancelsCloak( weapon )
{
	if ( !IsValid( weapon ) )
		return false

	switch ( weapon.GetClassname() )
	{
		case "mp_weapon_frag_grenade":
		case "mp_weapon_grenade_emp":
		case "mp_weapon_laser_mine":
		case "mp_weapon_satchel":
		case "mp_weapon_proximity_mine":
			return false
		default:
			break
	}

	return true
}

function IsValidPassThroughTarget( target, attacker )
{
	//Tied to PassThroughHack function remove when supported by code.
	if ( target == level.worldspawn )
		return false

	if ( !IsValid( target ) )
		return false

	if ( target.GetTeam() == attacker.GetTeam() )
		return false

	if ( target.GetTeam() != TEAM_IMC && target.GetTeam() != TEAM_MILITIA )
		return false

	return true
}

function PassThroughDamage( targetArray )
{
	//Tied to PassThroughHack function remove when supported by code.

	local damageSourceID = self.GetDamageSourceID()
	local owner = self.GetWeaponOwner()

	foreach ( ent in targetArray )
	{
		local distanceToTarget = Distance( self.GetOrigin(), ent.GetOrigin() )
		local damageToDeal = CalcWeaponDamage( owner, ent, self, distanceToTarget )

		ent.TakeDamage( damageToDeal, owner, self.GetWeaponOwner(), { damageSourceId=damageSourceID } )
	}
}


function StartPopcornExplosions( projectile, owner, popcornInfo, customFxTable = null )
{
	Assert( IsValid( owner ) )

	local weaponName = popcornInfo.weaponName
	local selfDamage = true
	local innerRadius = GetWeaponInfoFileKeyField_Global( weaponName, "explosion_inner_radius" )
	local outerRadius = GetWeaponInfoFileKeyField_Global( weaponName, "explosionradius" )
	local explosionDamage
	local explosionDamageHeavyArmor

	if ( IsPlayer( owner ) )
	{
		owner.EndSignal( "Disconnected" )
		explosionDamage = GetWeaponInfoFileKeyField_Global( weaponName, "explosion_damage" )
		explosionDamageHeavyArmor = GetWeaponInfoFileKeyField_Global( weaponName, "explosion_damage_heavy_armor" )
	}
	else
	{
		explosionDamage = GetWeaponInfoFileKeyField_Global( weaponName, "npc_explosion_damage" )
		explosionDamageHeavyArmor = GetWeaponInfoFileKeyField_Global( weaponName, "npc_explosion_damage_heavy_armor" )
	}

	PopcornExplosionBurst( projectile.GetOrigin(), explosionDamage, explosionDamageHeavyArmor, innerRadius, outerRadius, owner, null, selfDamage, popcornInfo, customFxTable )

	if ( IsValid( projectile ) )
		projectile.Kill()
}

function MakeMissileAccelerate( missile, missileAccelSpeedStart, missileAccelSpeedEnd, duration, delay = 0 )
{
	Assert( IsValid_ThisFrame( missile ) )
	missile.EndSignal( "OnDestroy" )

	local tickRate = 0.1
	local increasePerTick = ( missileAccelSpeedEnd.tofloat() - missileAccelSpeedStart.tofloat() ) / ( duration.tofloat() / tickRate.tofloat() )
	local speed = missileAccelSpeedStart

	if ( delay > 0 )
		wait delay

	while ( IsValid( missile ) )
	{
		local velocity = missile.GetVelocity()
		velocity.Norm()
		missile.SetVelocity( velocity * speed )

		speed += increasePerTick
		if ( speed >= missileAccelSpeedEnd )
			return
	}
}

function GetVectorFromPositionToCrosshair( player, startPos )
{
	Assert( IsValid( player ) )

	// See where we're looking
	local traceStart = player.EyePosition()
	local traceEnd = traceStart + ( player.GetViewVector() * 20000 )
	local ignoreEnts = [ player ]
	local traceResult = TraceLine( traceStart, traceEnd, ignoreEnts, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )

	// Return vec from startPos to where we are looking
	local vec = traceResult.endPos - startPos
	vec.Norm()
	return vec
}

/*
function InitMissileForRandomDriftBasic( missile, startPos, startDir )
{
	missile.s.randomFloat <- RandomFloat( 0, 1 )
	missile.s.startPos <- startPos
	missile.s.startDir <- startDir
}
*/

function InitMissileForRandomDriftForVortexHigh( missile, startPos, startDir )
{
	missile.InitMissileForRandomDrift( startPos, startDir, 8, 2.5, 0, 0, 100, 100 )
}

function InitMissileForRandomDriftForVortexLow( missile, startPos, startDir )
{
	missile.InitMissileForRandomDrift( startPos, startDir, 0.3, 0.085, 0, 0, 0.5, 0.5 )
}

/*
function InitMissileForRandomDrift( missile, startPos, startDir )
{
	InitMissileForRandomDriftBasic( missile, startPos, startDir )

	missile.s.drift_windiness <- missile.GetWeaponInfoFileKeyField( "projectile_drift_windiness" )
	missile.s.drift_intensity <- missile.GetWeaponInfoFileKeyField( "projectile_drift_intensity" )

	missile.s.straight_time_min <- missile.GetWeaponInfoFileKeyField( "projectile_straight_time_min" )
	missile.s.straight_time_max <- missile.GetWeaponInfoFileKeyField( "projectile_straight_time_max" )

	missile.s.straight_radius_min <- missile.GetWeaponInfoFileKeyField( "projectile_straight_radius_min" )
	if ( missile.s.straight_radius_min < 1 )
		missile.s.straight_radius_min = 1
	missile.s.straight_radius_max <- missile.GetWeaponInfoFileKeyField( "projectile_straight_radius_max" )
	if ( missile.s.straight_radius_max < 1 )
		missile.s.straight_radius_max = 1
}

function SmoothRandom( x )
{
	return 0.25 * (sin(x) + sin(x * 0.762) + sin(x * 0.363) + sin(x * 0.084))
}

function MissileRandomDrift( timeElapsed, timeStep, windiness, intensity )
{
	// This function makes the missile go in a random direction.
	// Windiness is how frequently the missile changes direction.
	// Intensity is how strongly the missile steers in the direction it has chosen.

	local sampleTime = timeElapsed - timeStep * 0.5

	intensity *= timeStep

	local offset = self.s.randomFloat * 1000

	local offsetx = intensity * SmoothRandom( offset     +       sampleTime * windiness )
	local offsety = intensity * SmoothRandom( offset * 2 + 100 + sampleTime * windiness )

	local right = self.GetRightVector()
	local up = self.GetUpVector()

	//DebugDrawLine( self.GetOrigin(), self.GetOrigin() + right * 100, 255,255,255, true, 0 )
	//DebugDrawLine( self.GetOrigin(), self.GetOrigin() + up * 100, 255,128,255, true, 0 )

	local dir = self.GetVelocity()
	local speed = dir.Normalize()
	dir += right * offsetx
	dir += up * offsety
	dir.Normalize()
	dir *= speed

	return dir
}

// designed to be called every frame (GetProjectileVelocity callback) on projectiles that are flying through the air
function ApplyMissileControlledDrift( missile, timeElapsed, timeStep )
{
	// If we have a target, don't do anything fancy; just let code do the homing behavior
	if ( missile.GetTarget() )
		return missile.GetVelocity()

	local s = missile.s
	return MissileControlledDrift( timeElapsed, timeStep, s.drift_windiness, s.drift_intensity, s.straight_time_min, s.straight_time_max, s.straight_radius_min, s.straight_radius_max )
}

function MissileControlledDrift( timeElapsed, timeStep, windiness, intensity, pathTimeMin, pathTimeMax, pathRadiusMin, pathRadiusMax )
{
	// Start with random drift.
	local vel = MissileRandomDrift( timeElapsed, timeStep, windiness, intensity )

	// Straighten our velocity back along our original path if we're below pathTimeMax.
	// Path time is how long it tries to stay on a straight path.
	// Path radius is how far it can get from its straight path.
	if ( timeElapsed < pathTimeMax )
	{
		local org = self.GetOrigin()
		local alongPathLen = self.s.startDir.Dot( org - self.s.startPos )
		local alongPathPos = self.s.startPos + self.s.startDir * alongPathLen
		local offPathOffset = org - alongPathPos
		local pathDist = offPathOffset.Length()

		local speed = vel.Length()

		local lerp = 1
		if ( timeElapsed > pathTimeMin )
			lerp = 1.0 - (timeElapsed - pathTimeMin) / (pathTimeMax - pathTimeMin)

		local pathRadius = pathRadiusMax + (pathRadiusMin - pathRadiusMax) * lerp

		// This circle shows the radius the missile is allowed to be in.
		//if ( IsServer() )
		//	DebugDrawCircle( alongPathPos, VectorToAngles( VectorToAngles( self.s.startDir ).AnglesToUp() ), pathRadius, 255,255,255, 0 )

		local backToPathVel = offPathOffset * -1
		// Cap backToPathVel at speed
		if ( pathDist > pathRadius )
			backToPathVel *= speed / pathDist
		else
			backToPathVel *= speed / pathRadius

		if ( pathDist < pathRadius )
		{
			backToPathVel += self.s.startDir * (speed * (1.0 - pathDist / pathRadius))
		}

		//DebugDrawLine( org, org + vel * 0.1, 255,255,255, true, 0 )
		//DebugDrawLine( org, org + backToPathVel * intensity * lerp * 0.1, 128,255,128, true, 0 )

		vel += backToPathVel * (intensity * timeStep)
		vel.Normalize()
		vel *= speed
	}

	return vel
}
*/

function ClusterRocket_Detonate( rocket, normal )
{
	if ( IsServer() )
	{
		local owner = rocket.GetOwner()
		if ( IsValid( owner ) )
		{
			local count
			local duration

			if ( "burnMod" in rocket.s )
			{
				count = CLUSTER_ROCKET_BURST_COUNT_BURN
				duration = CLUSTER_ROCKET_DURATION_BURN
			}
			else
			{
				count = CLUSTER_ROCKET_BURST_COUNT
				duration = CLUSTER_ROCKET_DURATION
			}

			popcornInfo <- {}
			popcornInfo.weaponName <- "mp_titanweapon_dumbfire_rockets"
			popcornInfo.weaponMods <- rocket.GetMods()
			popcornInfo.damageSourceId <- eDamageSourceId.mp_titanweapon_dumbfire_rockets
			popcornInfo.count <- count
			popcornInfo.delay <- CLUSTER_ROCKET_BURST_DELAY
			popcornInfo.offset <- CLUSTER_ROCKET_BURST_OFFSET
			popcornInfo.range <- CLUSTER_ROCKET_BURST_RANGE
			popcornInfo.normal <- normal
			popcornInfo.duration <- duration
			popcornInfo.groupSize <- CLUSTER_ROCKET_BURST_GROUP_SIZE

			thread StartClusterExplosions( rocket, owner, popcornInfo, CLUSTER_ROCKET_FX_TABLE )
		}
	}
}


function StartClusterExplosions( projectile, owner, popcornInfo, customFxTable = null )
{
	Assert( IsValid( owner ) )

	local weaponName = popcornInfo.weaponName
	local selfDamage = true
	local innerRadius
	local outerRadius
	local explosionDamage
	local explosionDamageHeavyArmor
	if ( "initializedClusterExplosions" in projectile.s )
	{
		innerRadius = projectile.s.innerRadius
		outerRadius = projectile.s.outerRadius
		if( IsPlayer( owner ) )
		{
			explosionDamage = projectile.s.explosionDamage
			explosionDamageHeavyArmor = projectile.s.explosionDamageHeavyArmor
		}
		else
		{
			explosionDamage = projectile.s.npcExplosionDamage
			explosionDamageHeavyArmor = projectile.s.npcExplosionDamageHeavyArmor
		}
	}
	else
	{
		innerRadius = GetWeaponInfoFileKeyField_Global( weaponName, "explosion_inner_radius" )
		outerRadius = GetWeaponInfoFileKeyField_Global( weaponName, "explosionradius" )
	  	if ( IsPlayer( owner ) )
	 	{
			explosionDamage = GetWeaponInfoFileKeyField_Global( weaponName, "explosion_damage" )
			explosionDamageHeavyArmor = GetWeaponInfoFileKeyField_Global( weaponName, "explosion_damage_heavy_armor" )
		}
		else
		{
			explosionDamage = GetWeaponInfoFileKeyField_Global( weaponName, "npc_explosion_damage" )
			explosionDamageHeavyArmor = GetWeaponInfoFileKeyField_Global( weaponName, "npc_explosion_damage_heavy_armor" )
	  	}
	}

	if ( IsPlayer( owner ) )
		owner.EndSignal( "Disconnected" )

	thread ClusterRocketBursts( projectile.GetOrigin(), explosionDamage, explosionDamageHeavyArmor, innerRadius, outerRadius, owner, selfDamage, popcornInfo, customFxTable )

	if ( IsValid( projectile ) )
		projectile.Kill()
}


//------------------------------------------------------------
// ClusterRocketBurst() - does a "popcorn airburst" explosion effect over time around the origin. Total distance is based on popRangeBase
// - returns the entity in case you want to parent it
//------------------------------------------------------------
function ClusterRocketBursts( origin, damage, damageHeavyArmor, innerRadius, outerRadius, owner = null, selfDamage = true, popcornInfo = null, customFxTable = null )
{
	// No Damage - Only Force
	// Push players
	// Test LOS before pushing
	local flags = 11
	// create a blast that knocks pilots out of the way
	CreatePhysExplosion( origin, outerRadius, "large", flags )

	local clusterExplosion = CreateClusterExplosion( origin + (popcornInfo.normal * 8.0), damage, damageHeavyArmor, innerRadius, outerRadius, owner, popcornInfo.damageSourceId, popcornInfo.weaponMods )

	local count = popcornInfo.groupSize
	for ( local index = 0; index < count; index++ )
	{
		thread ClusterRocketBurst( origin, damage, damageHeavyArmor, innerRadius, outerRadius, clusterExplosion, owner, selfDamage, popcornInfo, customFxTable )
		wait 0
	}

	wait CLUSTER_ROCKET_DURATION + 5.0

	clusterExplosion.Kill()
}

function ClusterRocketBurst( origin, damage, damageHeavyArmor, innerRadius, outerRadius, clusterExplosion, owner = null, selfDamage = true, popcornInfo = null, customFxTable = null )
{
	// first explosion always happens where you fired
	local eDamageSource = popcornInfo.damageSourceId
	local numBursts = popcornInfo.count
	local popRangeBase = popcornInfo.range
	local popDelayBase = popcornInfo.delay
	local popDelayRandRange = popcornInfo.offset
	local duration = popcornInfo.duration
	local groupSize = popcornInfo.groupSize

	local counter = 0
	local randVec = null
	local randRangeMod = null
	local popRange = null
	local popVec = null
	local popOri = origin
	local popDelay = null
	local colTrace

	local burstDelay = duration / ( numBursts / groupSize )

	local clusterBurstOrigin = origin + (popcornInfo.normal * 8.0)
	local clusterBurstEnt = CreateClusterBurst( clusterBurstOrigin )

	while( counter <= numBursts / popcornInfo.groupSize )
	{
		randVec = RandomVecInDome( popcornInfo.normal )
		randRangeMod = ( RandomFloat( 0, 1 ) )
		popRange = popRangeBase * randRangeMod
		popVec = randVec * popRange
		popOri = origin + popVec
		popDelay = popDelayBase + RandomFloat( -popDelayRandRange, popDelayRandRange )

		colTrace = TraceLineSimple( origin, popOri, null )
		if ( colTrace < 1 )
		{
			popVec = popVec * colTrace
			popOri = origin + popVec
		}

		clusterBurstEnt.SetOrigin( clusterBurstOrigin )

		local velocity = GetVelocityForDestOverTime( clusterBurstEnt.GetOrigin(), popOri, burstDelay - popDelay )
		clusterBurstEnt.SetVelocity( velocity )

		clusterBurstOrigin = popOri

		counter++

		wait burstDelay - popDelay

		clusterExplosion.SetOrigin( clusterBurstOrigin )
		clusterExplosion.Fire( "Explode", "", 0, owner )
	}

	clusterBurstEnt.Destroy()
}


function CreateClusterBurst( origin )
{
	local prop_physics = CreateEntity( "prop_physics" )
	prop_physics.kv.model = "models/weapons/bullets/projectile_rocket.mdl"
	prop_physics.kv.fadedist = 2000
	prop_physics.kv.renderamt = 255
	prop_physics.kv.rendercolor = "255 255 255"
	prop_physics.kv.CollisionGroup = 1 //COLLISION_GROUP_DEBRIS

	prop_physics.kv.minhealthdmg = 9999
	prop_physics.kv.nodamageforces = 1
	prop_physics.kv.inertiaScale = 1.0

	prop_physics.SetOrigin( origin )
	DispatchSpawn( prop_physics, false )
	prop_physics.SetModel( "models/weapons/grenades/m20_f_grenade.mdl" )

	PlayFXOnEntity( "P_wpn_dumbfire_burst_trail", prop_physics )

	return prop_physics
}


//------------------------------------------------------------
// CreateExplosion() - create and fire an explosion at a specified origin. Optionally specify owner, delay, sound alias
// - returns the entity in case you want to parent it
//------------------------------------------------------------
function CreateClusterExplosion( origin, magnitude, magnitudeHeavyArmor, innerRadius, outerRadius, owner, eDamageSourceId, weaponMods = null  )
{
	local env_explosion = CreateEntity( "env_explosion" )

	local flags = SF_ENVEXPLOSION_NODECAL | SF_ENVEXPLOSION_REPEATABLE | SF_ENVEXPLOSION_ALIVE_ONLY

	env_explosion.kv.impact_effect_table = CLUSTER_ROCKET_FX_TABLE
	env_explosion.kv.spawnflags = flags
	env_explosion.SetOrigin( origin )
	env_explosion.kv.iMagnitude = magnitude
	env_explosion.kv.iMagnitudeHeavyArmor = magnitudeHeavyArmor
	env_explosion.kv.iInnerRadius = innerRadius
	env_explosion.kv.iRadiusOverride = outerRadius
	env_explosion.kv.fireballsprite = "sprites/zerogxplode.spr"
	env_explosion.kv.rendermode = 5
	env_explosion.kv.scriptDamageType = damageTypes.Explosive
	env_explosion.kv.damageSourceId = eDamageSourceId
	if ( weaponMods )
		env_explosion.s.weaponMods <- weaponMods

	if ( IsValid_ThisFrame( owner ) )
	{
		env_explosion.SetTeam( owner.GetTeam() )
		env_explosion.SetOwner( owner )
	}

	DispatchSpawn( env_explosion, false )

	return env_explosion
}



function GetVelocityForDestOverTime( startPoint, endPoint, duration )
{
	const GRAVITY = 750

	local Vox = (endPoint.x - startPoint.x) / duration
	local Voy = (endPoint.y - startPoint.y) / duration
	local Voz = (endPoint.z + 0.5 * GRAVITY * duration * duration - startPoint.z) / duration

	return Vector( Vox, Voy, Voz )
}

function HasLockedTarget( weapon )
{
	if ( weapon.SmartAmmo_IsEnabled() )
	{
		local targets = weapon.SmartAmmo_GetTargets()
		if ( targets.len() > 0 )
		{
			foreach ( target in targets )
			{
				if ( target.fraction == 1 )
					return true
			}
		}
	}
	return false
}

function CanWeaponShootWhileRunning( weapon )
{
	if ( "primary_fire_does_not_block_sprint" in weapon.s )
		return weapon.s.primary_fire_does_not_block_sprint

	if ( weapon.GetWeaponInfoFileKeyField( "primary_fire_does_not_block_sprint" ) == 1 )
	{
		weapon.s.primary_fire_does_not_block_sprint <- true
		return true
	}

	weapon.s.primary_fire_does_not_block_sprint <- false
	return false
}

//A and B control which direction it charges and how quickly.
function DisplayChargeAmmoBar( weapon, weaponOwner, a = 0, b = 1.0, cockpit = null )
{
	if( IsValid( cockpit ) )
	{
		cockpit.s.weaponAmmoCount.Hide()
		cockpit.s.weaponMagsLabel.Hide()
		cockpit.s.weaponMags[0].Hide()
	}

	weaponOwner.s.weaponUpdateData = { weapon = weapon, a = a, b = b }
}

function HideChargeAmmoBar( weapon, weaponOwner )
{
	weaponOwner.s.weaponUpdateData = {}
	weaponOwner.Signal( "ResetWeapons" )
}

function DebugDrawWeapon( weapon )
{
	if ( !IsClient() )
		return

	local drawTime 		= 20
	local radius

	local spreadAngle 	= weapon.GetWeaponOwner().GetAttackSpreadAngle()
	local spreadSin 	= deg_sin( spreadAngle * 0.5 )
	local nearDist 		= weapon.GetWeaponInfoFileKeyField( "damage_near_distance" )
	local farDist 		= weapon.GetWeaponInfoFileKeyField( "damage_far_distance" )
	local nearDmg 		= weapon.GetWeaponInfoFileKeyField( "damage_near_value" )
	local farDmg 		= weapon.GetWeaponInfoFileKeyField( "damage_far_value" )

	local barrelPos 	= weapon.GetAttackPosition()
	local barrelVec 	= weapon.GetAttackDirection()
	local circleAng 	= VectorToAngles( barrelVec ).AnglesCompose( Vector( 90, 0, 0 ) )

	local nearPos 		= barrelPos + ( barrelVec * nearDist )
	local farPos 		= barrelPos + ( barrelVec * farDist )

	// Straight line for center cone
	DebugDrawLine( barrelPos, nearPos, 255, 0, 0, true, drawTime )
	DebugDrawLine( nearPos, farPos, 255, 255, 0, true, drawTime )

	// Circle representing spread at near distance
	radius = spreadSin * nearDist
	local pointsOnCircleNear = DebugDrawCircle( nearPos, circleAng, radius, 255, 0, 0, drawTime )
	for( local i = 0 ; i < pointsOnCircleNear.len() ; i++ )
		DebugDrawLine( barrelPos, pointsOnCircleNear[i], 255, 0, 0, true, drawTime )
	DebugDrawText( nearPos + Vector( 0, 0, radius + 15.0 ), nearDmg.tostring(), true, drawTime )

	// Circle representing spread at far distance
	radius = spreadSin * farDist
	local pointsOnCircleFar = DebugDrawCircle( farPos, circleAng, radius, 255, 255, 0, drawTime )
	for( local i = 0 ; i < pointsOnCircleFar.len() ; i++ )
		DebugDrawLine( pointsOnCircleNear[i], pointsOnCircleFar[i], 255, 255, 0, true, drawTime )
	DebugDrawText( farPos + Vector( 0, 0, radius + 15.0 ), farDmg.tostring(), true, drawTime )
}

function GetWeaponFireID( weapon )
{
	return RandomInt( 4 )
}


function cl_ChargeRumble( weapon, rumbleIndex, rumbleMin, rumbleMax, endSig )
{
	Assert( IsClient() )

	local player = weapon.GetWeaponOwner()
	if ( !IsLocalViewPlayer( player ) )
		return

	player.EndSignal( "StopWeaponRumble" )
	weapon.EndSignal( endSig )
	weapon.EndSignal( "OnDestroy" )

	Assert( IsValid( player ) )

	OnThreadEnd(
		function() : ( player, rumbleIndex )
		{
			if ( IsValid( player ) )
			{
				player.RumbleEffect( rumbleIndex, 0, RUMBLE_FLAG_STOP )
			}
		}
	)

	// Start rumble effect
	player.RumbleEffect( rumbleIndex, rumbleMin, RUMBLE_FLAG_LOOP | RUMBLE_FLAG_INITIAL_SCALE )

	// Increase rumble strength as we charge up the weapon more
	local rumbleAmount
	while(1)
	{
		rumbleAmount = Graph( weapon.GetWeaponChargeFraction(), 0, 1, rumbleMin, rumbleMax )
		player.RumbleEffect( rumbleIndex, rumbleAmount, RUMBLE_FLAG_UPDATE_SCALE )

		// seems really weird to issue rumble commands at 60hz -Mackey
		wait 0
	}
}

function cl_ChargeRumble_Stop( weapon, player = null )
{
	Assert( IsClient() )
	Assert( IsValid( weapon ) )

	if ( player == null )
		player = weapon.GetWeaponOwner()

	if ( IsValid( player ) && player.IsPlayer() && IsLocalViewPlayer( player ) )
		player.RumbleEffect( ARC_CANNON_RUMBLE_TYPE_INDEX, 0, RUMBLE_FLAG_STOP )
}

function OnTurretTargetChanged( turret )
{
	turret.Signal( "OnTurretTargetChanged" )

	local ownerPlayer = turret.GetBossPlayer()

	if ( !ownerPlayer )
		return

	local target = turret.GetEnemy()

	if ( target )
		target = target.GetEncodedEHandle()

	Remote.CallFunction_Replay( ownerPlayer, "ServerCallback_SetShoulderTurretTarget", target )

	ownerPlayer.Signal( "OnTurretTargetChanged" )
}


function ServerCallback_SetShoulderTurretTarget( targetEHandle )
{
	local player = GetLocalViewPlayer()

	local target = null

	if ( targetEHandle )
		target = GetEntityFromEncodedEHandle( targetEHandle )

	player.Signal( "OnTurretTargetChanged", { target = target } )
}

function ServerCallback_GuidedMissileDestroyed()
{
	local player = GetLocalViewPlayer()

	// guided missiles has not been updated to work with replays. added this if statement defensively just in case. - Roger
	if ( !( "missileInFlight" in player.s ) )
		return

	player.s.missileInFlight = false
}

function ServerCallback_AirburstIconUpdate( toggle )
{
	local player = GetLocalViewPlayer()
	local cockpit = player.GetCockpit()
	if( cockpit )
	{
		local mainVGUI = cockpit.GetMainVGUI()
		if ( mainVGUI )
		{
			if( toggle )
				cockpit.s.offhandHud[OFFHAND_RIGHT].icon.SetImage( "HUD/dpad_airburst_activate" )
			else
				cockpit.s.offhandHud[OFFHAND_RIGHT].icon.SetImage( "HUD/dpad_airburst" )
		}
	}
}

function FireExpandContractMissiles( weapon, attackParams, attackPos, attackDir, shouldPredict, rocketsPerShot, missileSpeed, launchOutAng, launchOutTime, launchInAng, launchInTime, launchInLerpTime, launchStraightLerpTime, applyRandSpread, burstFireCountOverride = null, debugDrawPath = false )
{
	local missileVecs = GetExpandContractRocketTrajectories( weapon, attackParams.burstIndex, attackPos, attackDir, rocketsPerShot, launchOutAng, launchInAng, burstFireCountOverride )
	local player = weapon.GetWeaponOwner()
	local firedMissiles = []

	local missileEndPos = player.EyePosition() + ( player.GetViewVector() * 5000 )

	for ( local i = 0 ; i < rocketsPerShot ; i++ )
	{
		local missile = weapon.FireWeaponMissile( attackPos, attackDir, missileSpeed, damageTypes.Explosive | DF_IMPACT, damageTypes.Explosive, false, shouldPredict )

		if ( missile )
		{
			/*
			missile.s.flightData <- {
								launchOutVec = missileVecs[i].outward,
								launchOutTime = launchOutTime,
								launchInLerpTime = launchInLerpTime,
								launchInVec = missileVecs[i].inward,
								launchInTime = launchInTime,
								launchStraightLerpTime = launchStraightLerpTime,
								endPos = missileEndPos,
								applyRandSpread = applyRandSpread
							}
			*/

			missile.InitMissileExpandContract( missileVecs[i].outward, missileVecs[i].inward, launchOutTime, launchInLerpTime, launchInTime, launchStraightLerpTime, missileEndPos, applyRandSpread )

			if( IsServer() && debugDrawPath )
				thread DebugDrawMissilePath( missile )

			//InitMissileForRandomDrift( missile, attackPos, attackDir )
			missile.InitMissileForRandomDriftFromWeaponSettings( attackPos, attackDir )

			firedMissiles.append( missile )
		}
	}

	return firedMissiles
}

function GetExpandContractRocketTrajectories( weapon, burstIndex, attackPos, attackDir, rocketsPerShot, launchOutAng, launchInAng, burstFireCount = null )
{
	local DEBUG_DRAW_MATH = false

	if ( !( "burstFireCount" in weapon.s ) )
		weapon.s.burstFireCount <- weapon.GetWeaponModSetting( "burst_fire_count" )
	if ( burstFireCount == null )
		burstFireCount = weapon.s.burstFireCount

	local additionalRotation = ( ( 360.0 / rocketsPerShot ) / burstFireCount ) * burstIndex
	//printt( "burstIndex:", burstIndex )
	//printt( "rocketsPerShot:", rocketsPerShot )
	//printt( "burstFireCount:", burstFireCount )

	local ang = VectorToAngles( attackDir )
	local forward = ang.AnglesToForward()
	local right = ang.AnglesToRight()
	local up = ang.AnglesToUp()

	if ( DEBUG_DRAW_MATH )
		DebugDrawLine( attackPos, attackPos + ( forward * 1000 ), 255, 0, 0, true, 30 )

	// Create points on circle
	local offsetAng = 360.0 / rocketsPerShot
	local points = []
	for ( local i = 0 ; i < rocketsPerShot ; i++ )
	{
		local a = offsetAng * i + additionalRotation
		local vec = Vector( 0, 0, 0 )
		vec += up * deg_sin( a )
		vec += right * deg_cos( a )

		if ( DEBUG_DRAW_MATH )
			DebugDrawLine( attackPos, attackPos + ( vec * 50 ), 10, 10, 10, true, 30 )
	}

	// Create missile points
	local x = right * deg_sin( launchOutAng )
	local y = up * deg_sin( launchOutAng )
	local z = forward * deg_cos( launchOutAng )
	local rx = right * deg_sin( launchInAng )
	local ry = up * deg_sin( launchInAng )
	local rz = forward * deg_cos( launchInAng )
	local missilePoints = []
	for ( local i = 0 ; i < rocketsPerShot ; i++ )
	{
		local points = {}

		// Outward vec
		local a = offsetAng * i + additionalRotation
		local s = deg_sin( a )
		local c = deg_cos( a )
		local vecOut = z + x * c + y * s
		vecOut.Norm()
		points.outward <- vecOut

		// Inward vec
		local vecIn = rz + rx * c + ry * s
		points.inward <- vecIn

		// Add to array
		missilePoints.append( points )

		if ( DEBUG_DRAW_MATH )
		{
			DebugDrawLine( attackPos, attackPos + ( vecOut * 50 ), 255, 255, 0, true, 30 )
			DebugDrawLine( attackPos + vecOut * 50, attackPos + vecOut * 50 + ( vecIn * 50 ), 255, 0, 255, true, 30 )
		}
	}

	return missilePoints
}

function DebugDrawMissilePath( missile )
{
	EndSignal( missile, "OnDestroy" )
	local lastPos = missile.GetOrigin()
	while(1)
	{
		wait 0
		if ( !IsValid( missile ) )
			return
		DebugDrawLine( lastPos, missile.GetOrigin(), 0, 255, 0, true, 20 )
		lastPos = missile.GetOrigin()
	}
}

function ServerCallback_GameStateEnter_Postmatch()
{
	local player = GetLocalViewPlayer()
	player.Signal( "StopWeaponRumble" )
}


function RegenerateOffhandAmmoOverTime( weapon, rechargeTime, maxAmmo, offhandIndex )
{
	weapon.Signal( "RegenAmmo" )
	weapon.EndSignal( "RegenAmmo" )
	weapon.EndSignal( "OnDestroy" )

	if ( IsClient() )
	{
		local weaponOwner = weapon.GetWeaponOwner()
		if ( IsValid( weaponOwner ) && weaponOwner.IsPlayer() )
		{
			local cockpit = weaponOwner.GetCockpit()
			if ( IsValid( cockpit ) )
			{
				cockpit.s.offhandHud[offhandIndex].bar.SetBarProgressSource( ProgressSource.PROGRESS_SOURCE_SCRIPTED )
				cockpit.s.offhandHud[offhandIndex].bar.SetBarProgressRemap( 0.0, 1.0, 0.0, 1.0 )
				cockpit.s.offhandHud[offhandIndex].bar.SetBarProgressAndRate( 1.0 / maxAmmo , 1 / ( rechargeTime * maxAmmo ) )
			}
		}
	}

	if ( !( "totalChargeTime" in weapon.s ) )
		weapon.s.totalChargeTime <- rechargeTime

	if ( !( "nextChargeTime" in weapon.s ) )
		weapon.s.nextChargeTime <- null

	for ( ;; )
	{
		weapon.s.nextChargeTime = rechargeTime + Time()

		wait rechargeTime

		if ( IsServer() )
		{
			local ammo = weapon.GetWeaponPrimaryClipCount()
			if ( ammo < maxAmmo )
				weapon.SetWeaponPrimaryClipCount( ammo + 1 )
		}
	}
}

function DoesPlayerOwnWeapon( player, weapon )
{
	if ( !IsValid( player ) )
		return false

	if ( !IsValid( weapon ) )
		return false

	if ( player == weapon.GetWeaponOwner() )
		return true

	return false
}