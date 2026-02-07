
RegisterSignal( "Deactivated" )

const MORTAR_NUM_ROUNDS = 4
const MORTAR_TIME_BETWEEN_ROUNDS = 0.5
const MORTAR_AIR_TIME = 2.0
const MORTAR_MIN_RANGE = 1000
const MORTAR_MAX_RANGE = 6000
const MORTAR_MAX_DEVIATION = 350
const MORTAR_START_HEIGHT = 2000

const MORTAR_IMPACT_BURST_COUNT = 5		//number of bursts
const MORTAR_IMPACT_BURST_DELAY = 0.5 	//time before the popcors burst off +/- some randomness
const MORTAR_IMPACT_BURST_OFFSET = 0.3 	// how much + & - the delay to set off the explosions
const MORTAR_IMPACT_BURST_RANGE = 150 	//range of the bursts

const MORTAR_PRECHARGE_BUFFER_TIME = 1.0

const CROSSHAIR_INDEX_CURRENT = 0
const CROSSHAIR_INDEX_PREVIOUS = 1
const CROSSHAIR_INDEX_RANGEFINDER = 2

function MortarPrecache()
{
	if ( WeaponIsPrecached( self ) )
		return

	PrecacheParticleSystem( "orbital_rocket_CH_flash" )
	PrecacheParticleSystem( "wpn_mortar_tracer" )
}
MortarPrecache()

function Mortar_End()
{
	self.Signal( "Deactivated" )
}

function OnWeaponActivate( activateParams )
{
}

function OnWeaponDeactivate( deactivateParams )
{
	Mortar_End()
}

function OnWeaponChargeBegin( chargeParams )
{
	thread IncreaseRangeOverTime( self )
}

function OnWeaponChargeEnd( chargeParams )
{
	Mortar_End()
}

function OnWeaponPrimaryAttack( attackParams )
{
	Mortar_End()

	local frac = GetMortarRangeFrac( self )

	if ( IsClient() )
	{
		local player = self.GetWeaponOwner()
		if ( !( "lastMortarFireFrac" in player.s ) )
			player.s.lastMortarFireFrac <- 0.0
		player.s.lastMortarFireFrac = frac
		return
	}

	thread FireMortars_Server( self.GetWeaponOwner(), frac )
}

function FireMortars_Client( weapon, player )
{
	local effectIndex
	local effect
	for( local i = 0 ; i < MORTAR_NUM_ROUNDS ; i++ )
	{
		if ( !IsValid( player ) )
			return

		local effectOrigin = player.GetWorldSpaceCenter()

		effectIndex = GetParticleSystemIndex( "orbital_rocket_CH_flash" )
		effect = StartParticleEffectInWorldWithHandle( effectIndex, effectOrigin, Vector( 0, 0, 1 ) )

		effectIndex = GetParticleSystemIndex( "wpn_mortar_tracer" )
		effect = StartParticleEffectInWorldWithHandle( effectIndex, effectOrigin, Vector( 0, 0, 1 ) )
		EffectSetControlPointVector( effect, 1, effectOrigin + Vector( 0, 0, 2000 ) )

		EmitSoundOnEntity( player, "PropAPC.FireCannon" )

		wait MORTAR_TIME_BETWEEN_ROUNDS
	}
}

function FireMortars_Server( player, frac )
{
	local dist = GraphCapped( frac, 0.0, 1.0, MORTAR_MIN_RANGE, MORTAR_MAX_RANGE )

	local playerAngles = Vector( 0, player.EyeAngles().y, 0 )
	local viewVector = player.GetViewVector()
	local playerForward = playerAngles.AnglesToForward()
	playerForward.Norm()
	local impactLocation = player.GetOrigin() + ( playerForward * dist )
	CreateNoSpawnArea( player.GetTeam(), impactLocation, MORTAR_AIR_TIME + 5.0 + MORTAR_TIME_BETWEEN_ROUNDS * MORTAR_NUM_ROUNDS , 500 )
	//DebugDrawLine( impactLocation, impactLocation + Vector( 0, 0, 2000 ), 0, 0, 255, true, 15 )

	wait MORTAR_AIR_TIME

	for( local i = 0 ; i < MORTAR_NUM_ROUNDS ; i++ )
	{
		thread MortarRoundFalls( player, impactLocation, i != 0 )
		wait MORTAR_TIME_BETWEEN_ROUNDS
	}
}

function OnClientAnimEvent( name )
{
	if ( name == "muzzle_flash" )
	{
		thread FireMortars_Client( self, self.GetWeaponOwner() )
	}
}

function GetMortarRangeFrac( weapon )
{
	local totalChargeTime = weapon.GetWeaponChargeTime() + weapon.GetWeaponChargeTimeRemaining()
	local frac = GraphCapped( weapon.GetWeaponChargeTime(), MORTAR_PRECHARGE_BUFFER_TIME, totalChargeTime, 0.0, 1.0 )
	frac = RoundToNearestMultiplier( frac, 0.1 )
	frac = clamp( frac, 0.0, 1.0 )
	return frac
}

function IncreaseRangeOverTime( weapon )
{
	weapon.EndSignal( "Deactivated" )

	local nearestVal = 0.0
	local rangeFinderVal = 0.0
	local lastNearestVal = 0.0
	local player = self.GetWeaponOwner()

	// Update the dim grey marker that shows where your last shot was
	if ( IsClient() )
	{
		local lastFireNearestVal = 0.0
		if ( !( "lastMortarFireFrac" in player.s ) )
			player.s.lastMortarFireFrac <- 0.0
		SetCrosshairMovement( CROSSHAIR_INDEX_PREVIOUS, 0, player.s.lastMortarFireFrac )
	}

	// Update ticker mark for this shot, as well as the red range marker
	while(1)
	{
		wait 0

		if ( !IsValid( weapon ) || !IsValid( player ) )
			break

		nearestVal = GetMortarRangeFrac( weapon )
		rangeFinderVal = UpdateRangeFinder( player )
		if ( lastNearestVal != nearestVal )
		{
			if ( IsClient() )
			{
				SetCrosshairMovement( CROSSHAIR_INDEX_CURRENT, 0, nearestVal )
				EmitSoundOnEntity( weapon.GetWeaponOwner(), "Weapon_SmartAmmo.TargetingClick" )
			}
			lastNearestVal = nearestVal
		}
	}
}

function UpdateRangeFinder( player )
{
	// Get where the player is looking, then determine the distance
	local traceStart = player.EyePosition()
	local traceEnd = traceStart + ( player.GetViewVector() * MORTAR_MAX_RANGE )
	local ignoreEnts = [ player ]
	local traceResult = TraceLine( traceStart, traceEnd, ignoreEnts, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )
	local viewingDistance = MORTAR_MAX_RANGE * traceResult.fraction

	// Determine where the marker should be on the crosshair based on the distance
	local rangeFinderFrac = GraphCapped( viewingDistance, MORTAR_MIN_RANGE, MORTAR_MAX_RANGE, 0.0, 1.0 )

	// Update the range finder marker
	if ( IsClient() )
		SetCrosshairMovement( CROSSHAIR_INDEX_RANGEFINDER, 0, rangeFinderFrac )

	return rangeFinderFrac
}

function CooldownBarFracFunc()
{
	if ( IsValid( self ) )
		return 1.0 - self.GetWeaponChargeFraction()
	return 0
}

function MortarRoundFalls( player, centerPos, deviate = true )
{
	if ( !IsValid( player ) )
		return

	local playerTeam = player.GetTeam()

	local impactPos = centerPos

	// Calculate position of impact based on deviation
	if ( deviate )
	{
		local randDir = Vector( RandomFloat( -1, 1 ), RandomFloat( -1, 1 ), 0 )
		randDir.Norm()
		impactPos = impactPos + ( randDir * RandomFloat( 0.0, MORTAR_MAX_DEVIATION ) )
	}

	// Trace to get the real impact position
	local traceStart = Vector( impactPos.x, impactPos.y, 16384 )
	local traceEnd = Vector( impactPos.x, impactPos.y, -16000 )
	local traceResult = TraceLine( traceStart, traceEnd, null, (TRACE_MASK_NPCSOLID_BRUSHONLY|TRACE_MASK_WATER), TRACE_COLLISION_GROUP_NONE )
	if ( traceResult.hitSky ) // retrace because we hit a sky brush from outside the level, not the ground
	{
		traceStart = traceResult.endPos
		traceStart.z -= 1
		traceResult = TraceLine( traceStart, traceEnd, null, (TRACE_MASK_NPCSOLID_BRUSHONLY|TRACE_MASK_WATER), TRACE_COLLISION_GROUP_NONE )
	}
	impactPos = traceResult.endPos

	// Trace up from the impact to get the start position ( required in case the sky is lower than MORTAR_START_HEIGHT above the imapct position
	local impactStartPos = impactPos + Vector( 0, 0, MORTAR_START_HEIGHT )
	traceResult = TraceLine( impactPos, impactStartPos, null, (TRACE_MASK_NPCSOLID_BRUSHONLY|TRACE_MASK_WATER), TRACE_COLLISION_GROUP_NONE )
	impactStartPos = traceResult.endPos

	//DebugDrawLine( impactPos, impactStartPos, 0, 0, 255, true, 15 )

	// Incomming Sound Effect
	EmitSoundAtPosition( impactPos, "orbital_strike_incoming" )
	wait 1.25

	if ( !IsValid( player ) )
		return

	local weaponName = "mp_titanweapon_mortar"
	local damageSourceID = eDamageSourceId.mp_titanweapon_mortar

	// Rocket
	local rocket = CreateEntity( "rpg_missile" )
	rocket.SetOrigin( impactStartPos )
	rocket.SetAngles( Vector( 90, 0, 0 ) )
	rocket.SetOwner( player )
	rocket.SetTeam( playerTeam )
	rocket.SetModel( "models/weapons/bullets/projectile_rocket.mdl" )	//"models/weapons/bullets/projectile_rocket_large.mdl"
	rocket.SetImpactEffectTable( ROCKET_IMPACT_FX_TABLE )
	rocket.SetWeaponClassName( weaponName )
	rocket.kv.damageSourceId = damageSourceID
	DispatchSpawn( rocket )
}

function OnProjectileCollision( collisionParams )
{
	if ( MORTAR_IMPACT_BURST_COUNT > 0 )
	{
		popcornInfo <- {}
		popcornInfo.weaponName <-"mp_titanweapon_mortar"
		popcornInfo.weaponMods <- null
		popcornInfo.damageSourceId <- eDamageSourceId.mp_titanweapon_mortar
		popcornInfo.count 	<- MORTAR_IMPACT_BURST_COUNT
		popcornInfo.delay 	<- MORTAR_IMPACT_BURST_DELAY
		popcornInfo.offset 	<- MORTAR_IMPACT_BURST_OFFSET
		popcornInfo.range 	<- MORTAR_IMPACT_BURST_RANGE
		popcornInfo.duration <- CLUSTER_ROCKET_DURATION
		popcornInfo.groupSize <- CLUSTER_ROCKET_BURST_GROUP_SIZE

		local player = self.GetOwner()
		if ( IsValid( player ) )
			thread StartPopcornExplosions( self, player, popcornInfo, null )
	}
}
