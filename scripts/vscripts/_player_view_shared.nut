
function main()
{
	Globalize( CalcTitanViewPunch )
	Globalize( CalcTitanCockpitJolt )
}

const PUNCH_SCALE_SIDE = 0.9
const PUNCH_SCALE_FRONT = 1.0

const COCKPIT_JOLT_CAP_SIDE = 1.0
const COCKPIT_JOLT_CAP_FRONT = 0.55

const HITVECTOR_DECAY_TIME = 2.0
const HITVECTOR_EXPIRE_TIME = 2.1

function CalcTitanViewPunch( player, damageInfo )
{
	Assert( player.IsPlayer() && player.IsTitan() )

	if ( damageInfo.GetCustomDamageType() & DF_DOOMED_HEALTH_LOSS )
		return 0.0

	local punchAmount = GraphCapped( damageInfo.GetDamage(), 0, 2000, 0.0, 16.0 )

	local damageSourceID = damageInfo.GetDamageSourceIdentifier()

	switch ( damageSourceID )
	{
		case eDamageSourceId.mp_titanweapon_40mm:
			punchAmount *= 1.85
			break

		case eDamageSourceId.mp_titanweapon_rocket_launcher:
			punchAmount *= 2.9
			break

		case eDamageSourceId.mp_titanweapon_xo16:
			punchAmount *= 1.1
			break

		case eDamageSourceId.titanEmpField:
			punchAmount *= 1.25
			break

		case eDamageSourceId.mp_titanweapon_arc_cannon:
			punchAmount *= 1.4
			break

		case eDamageSourceId.mp_titanweapon_triple_threat:
			punchAmount *= 1.8
			break

		case eDamageSourceId.mp_titanweapon_sniper:
			punchAmount *= 2.8
			break

		case eDamageSourceId.mp_titanweapon_salvo_rockets:
			punchAmount *= 3.8
			break

		case eDamageSourceId.mp_titanweapon_homing_rockets:
			punchAmount *= 5.5
			break

		case eDamageSourceId.mp_titanweapon_shoulder_rockets:
			punchAmount *= 1.9
			break

		case eDamageSourceId.mp_titanweapon_dumbfire_rockets:
			punchAmount *= 2.3
			break

		case eDamageSourceId.mp_weapon_rocket_launcher:
			punchAmount *= 2.4
			break

		case eDamageSourceId.mp_weapon_smr:
		case eDamageSourceId.mp_weapon_mgl:
			punchAmount *= 1.25
			break

		default:
			break
	}

	local punchDir = (player.CameraPosition() - GetDamageOrigin( damageInfo ) )
	punchDir.Normalize()
	local punchDot = fabs( punchDir.Dot( player.GetForwardVector() ) )

	punchAmount *= GraphCapped( punchDot, 0.0, 1.0, PUNCH_SCALE_SIDE, PUNCH_SCALE_FRONT )
	//printt( "before:", punchAmount )
	punchAmount *= CalcHitDampening( player, punchDir )
	//printt( "after:", punchAmount )

	return punchAmount
}


function CalcTitanCockpitJolt( player, cockpit, joltDir, damageAmount, damageType, damageSourceID )
{
	local joltMagnitude

	switch ( damageSourceID )
	{
		case eDamageSourceId.mp_titanweapon_xo16:
			joltMagnitude = GraphCapped( damageAmount, 100, 300, 20, 30 )
			break
		default:
			joltMagnitude = damageAmount * 0.1
			break
	}

	local hitDot = fabs( joltDir.Dot( player.GetForwardVector() ) )
	joltMagnitude *= GraphCapped( hitDot, 0.0, 1.0, COCKPIT_JOLT_CAP_SIDE, COCKPIT_JOLT_CAP_FRONT )
	joltMagnitude *= CalcHitDampening( player, joltDir )

	return joltMagnitude
}


function CalcHitDampening( player, joltDir )
{
	local hitInfo = GetInfoForHitVector( player, joltDir )

	local time = Time()
	local timeDiff = time - hitInfo.lastHitTime

	local hitFrac

	if ( timeDiff > HITVECTOR_DECAY_TIME )
		hitFrac = (timeDiff - HITVECTOR_DECAY_TIME) * 0.4
	else
		hitFrac = max( hitInfo.lastHitFrac - 0.4 * timeDiff, 0.1 )

	hitInfo.lastHitTime = time
	hitInfo.lastHitFrac = hitFrac

	return GraphCapped( hitFrac, 0.1, 1.0, 0.4, 1.0 )
}


function GetInfoForHitVector( player, hitVector )
{
	// tmp.. do this in a better place... connect callback maybe
	if ( !( "hitVectors" in player.s ) )
		player.s.hitVectors <- []

	local hitVectors = player.s.hitVectors

	local time = Time()

	local foundHitVector = false
	for ( local index = hitVectors.len() - 1; index >= 0; index-- )
	{
		local hitInfo = hitVectors[index]

		if ( time - hitInfo.lastHitTime >= HITVECTOR_EXPIRE_TIME )
		{
			hitVectors.remove( index )
			continue
		}

		if ( hitInfo.hitVector.Dot( hitVector ) < 0.85 )
			continue

		hitInfo.hitVector = hitVector // since this is a tolerance, update the found vector origin to the new vector
		return hitInfo
	}

	local hitInfo = {}
	hitInfo.lastHitTime <- time
	hitInfo.hitVector <- hitVector
	hitInfo.lastHitFrac <- 1.0

	hitVectors.append( hitInfo )

	return hitInfo
}