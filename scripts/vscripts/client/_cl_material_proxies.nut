
function VMTCallback_ExampleEntityScriptProxy( ent )
{
	return 0.0
}

function VMTCallback_ExampleScriptModifyProxy( player )
{
	return 0.0
}

function VMTCallback_ArcCannonCrosshair( player )
{
	local weapon = player.GetActiveWeapon()
	if ( IsValid( weapon ) )
	{
		local charge = clamp ( weapon.GetWeaponChargeFraction() * ( 1 / GetArcCannonChargeFraction( weapon ) ), 0.0, 1.0 )
		local numOfFrames = 30 // 0 - N notation
		local frame = (numOfFrames * charge).tointeger()

		return frame
	}
	return 0
}

function VMTCallback_DefenderCrosshair( player )
{
	local weapon = player.GetActiveWeapon()
	local charge = weapon.GetWeaponChargeFraction()
	local numOfFrames = 30 // 0 - N notation
	local frame = (numOfFrames * charge).tointeger()

	return frame
}

function VMTCallback_TitanShotgunCrosshair( player )
{
	local currentAmmo = player.GetActiveWeaponPrimaryAmmoLoaded()
	local frame

	Assert( currentAmmo <= 9 )

	if ( currentAmmo > 9 )
		return 1;

	if ( currentAmmo == 0 )
		frame = 0
	else
		frame = ( 10 - currentAmmo )

	return frame
}

function VMTCallback_ArcCannonChargeAmount( player )
{
	local weapon = player.GetActiveWeapon()
	local charge = 0
	if ( IsValid( weapon ) && weapon.GetClassname() == "mp_titanweapon_arc_cannon" )
	{
		charge = clamp ( weapon.GetWeaponChargeFraction() * ( 1 / GetArcCannonChargeFraction( weapon ) ), 0.0, 1.0 )
	}
	return charge
}

function VMTCallback_TitanSniperCrosshair( player )
{
	local weapon = player.GetActiveWeapon()
	if ( !IsValid( weapon ) )
		return 0

	//return 0
	return weapon.GetScriptScope().GetTitanSniperChargeLevel( weapon )
}

const XRAY_PULSE_DURATION = 2.0

function VMTCallback_MPEntitySonarFrac( entity )
{
	if ( !( "createTime" in entity.s ) )
		return 0.0

	return GraphCapped( Time() - entity.s.createTime, 0, entity.s.pulseDuration, entity.s.maxFrac, 0.0 )
}

// Use ClipAmmoColor Proxy
// function VMTCallback_ClipAmmoColor( player )
// {
// 	if ( !player.GetActiveWeapon() )
// 		return Vector( 1, 1, 1 )
//
// 	local clipAmmo = player.GetActiveWeaponPrimaryAmmoLoaded()
// 	local maxClipAmmo = player.GetActiveWeaponPrimaryAmmoMaxLoaded()
//
// 	if ( clipAmmo <= maxClipAmmo * 0.1 )
// 	{
// 		return Vector( 255, 75, 66 ) * (1.0 / 255.0)
// 	}
// 	else if ( clipAmmo < maxClipAmmo * 0.4 )
// 	{
// 		return Vector( 255, 128, 64 ) * (1.0 / 255.0)
// 	}
// 	else
// 	{
// 		return Vector( 133, 231, 255 ) * (1.0 / 255.0)
// 	}
// }

// Use BackgroundAmmoColor Proxy
// function VMTCallback_BackgroundAmmoColor( player )
// {
// 	if ( !player.GetActiveWeapon() )
// 	{
// 		return Vector( 1, 1, 1 )
// 	}
//
//
// 	local clipAmmo = player.GetActiveWeaponPrimaryAmmoLoaded()
// 	local maxClipAmmo = player.GetActiveWeaponPrimaryAmmoMaxLoaded()
//
// 	if ( clipAmmo <= maxClipAmmo * 0.1 )
// 	{
// 		return Vector( 255, 175, 166 ) * (1.0 / 255.0)
// 	}
// 	else
// 	{
// 		return Vector( 255, 255, 255 ) * (1.0 / 255.0)
// 	}
// }

// Use RemainingAmmoColor instead
// function VMTCallback_RemainingAmmoColor( player )
// {
// 	if ( !player.GetActiveWeapon() )
// 		return Vector( 1, 1, 1 )
//
// 	local remainingAmmo = player.GetActiveWeaponPrimaryAmmoTotal()
// 	local maxClipAmmo = player.GetActiveWeaponPrimaryAmmoMaxLoaded()
//
// 	if ( remainingAmmo <= maxClipAmmo * 1 )
// 	{
// 		return Vector( 255, 75, 66 ) * (1.0 / 255.0)
// 	}
// 	else if ( remainingAmmo <= maxClipAmmo * 3 )
// 	{
// 		return Vector( 255, 128, 64 ) * (1.0 / 255.0)
// 	}
// 	else
// 	{
// 		return Vector( 133, 231, 255 ) * (1.0 / 255.0)
// 	}
// }

// Use HoloSight
// function VMTCallback_HoloSight( entity )
// {
// 	return GetLocalViewPlayer().GetAdsFraction()
// }

function VMTCallback_HoloSightOffset_Common( entity, attachment = "HOLO_REAR", hOffsetMultiplier = 3.65, vOffsetMultiplier = 3.65 )
{
	local holoRearOrg = entity.GetAttachmentOrigin( entity.LookupAttachment( attachment ) )
	local holoRearAng = entity.GetAttachmentAngles( entity.LookupAttachment( attachment ) )
	local camOrg = GetLocalViewPlayer().CameraPosition()
	//local camAng = GetLocalViewPlayer().CameraAngles()

	local gunVec = holoRearAng.AnglesToForward()
	local upVec = holoRearAng.AnglesToUp()
	local rightVec = holoRearAng.AnglesToRight()

	local camVec = (holoRearOrg - camOrg)

	local hOffset = camVec.Dot( rightVec ) * hOffsetMultiplier
	local vOffset = camVec.Dot( upVec ) * vOffsetMultiplier

	return Vector( hOffset, vOffset, 0.0 )
}

function VMTCallback_HoloSightOffset_RSPN101_Front( ent )
{
	/*
	local tagOrg = ent.GetAttachmentOrigin( ent.LookupAttachment( "HOLO_FRONT" ) )
	printt( "Front", tagOrg )

	local tagOrg = ent.GetAttachmentOrigin( ent.LookupAttachment( "HOLO_REAR" ) )
	printt( "Rear", tagOrg )

	local tagOrg = ent.GetAttachmentOrigin( ent.LookupAttachment( "CAMERA_BASE" ) )
	printt( "Cam", tagOrg )

	local camOrg = GetLocalViewPlayer().CameraPosition()
	printt( "Real Cam", camOrg )
	*/

	local attachment 			= "HOLO_REAR"
	local hOffsetMultiplier 	= 0.6
	local vOffsetMultiplier		= -0.75

	local ret = VMTCallback_HoloSightOffset_Common( ent, attachment, hOffsetMultiplier, vOffsetMultiplier )
	return ret
}

function VMTCallback_HoloSightOffset_RSPN101_Rear( ent )
{
	local attachment 			= "HOLO_REAR"
	local hOffsetMultiplier 	= 0.5
	local vOffsetMultiplier		= -0.65

	local ret = VMTCallback_HoloSightOffset_Common( ent, attachment, hOffsetMultiplier, vOffsetMultiplier )
	return ret
}

function VMTCallback_VduStaticAlpha( ent )
{
	if ( level.vduCustomStatic != null )
	{
		switch ( level.vduCustomStatic )
		{
			case STATIC_RANDOM:
				local rnd = RandomFloat( 0, 4.64 )
				rnd = ( ( rnd * rnd * rnd ) / 20 ).tointeger()
				return level.vduStatic + GraphCapped( rnd, 0, 4, 0, 0.06 )

			case STATIC_LIGHT:
				local val1 = sin( Time() * 1.5 )
				local val2 = sin( Time() * 4.5 )
				local val = val1 * val2

				val *= 0.04
				local base = RandomFloat( 0.01, 0.04 )
				if ( val > 0 )
					return base + val
				else
					return base

			case STATIC_HEAVY:
				local val1 = sin( Time() * 4.5 )
				local val2 = sin( Time() * 7.5 )
				local val = val1 * val2

				val *= 0.15
				local base = RandomFloat( 0.03, 0.1 )
				if ( val > 0 )
					return base + val
				else
					return base
		}
	}

	return level.vduStatic
}

function VMTCallback_GetCloakFactor( ent )
{
	local cloakiness = ent.GetCloakFadeFactor();

	// Adjust cloakiness based on movement?
	// ...

	// Output:  Remap fade amount into our base->overpower range.
	local base = 0.2
	local cloakAmount = cloakiness * ( 1.0 - base ) + base;
	return cloakAmount;
}

function VMTCallback_TeamColor( ent )
{
	if ( ent.GetTeam() == GetLocalViewPlayer().GetTeam() )
		return Vector( 0, 0, 1 )
	else
		return Vector( 1, 0, 0 )
}


function VMTCallback_TitanDamageColor( ent )
{
	/*
	// Relative
	if ( ent.GetTeam() == GetLocalViewPlayer().GetTeam() )
		return Vector( 0, 0, 1 )
	else
		return Vector( 1, 0, 0 )
	*/

	// Absolute
	if ( ent.GetTeam() == TEAM_IMC )
		return Vector( 105.0 / 255.0, 146.0 / 255.0, 1.0 )
	else
		return Vector( 1.0, 134.0 / 255.0, 92.0 / 255.0 )
}

function VMTCallback_MPEntityARAlpha( ent )
{
	if ( !ShouldShowWeakpoints( ent ) )
		return 0.0

	//return 0.75 + flashVal
	return 1.0
}

function VMTCallback_MPEntityARColor( ent )
{
	if ( !ShouldShowWeakpoints( ent ) )
		return Vector( 0.0, 0.0, 0.0 )

	return Vector( 1.0, 1.0, 1.0 )
}


function ShouldShowWeakpoints( ent )
{
	local player = GetLocalViewPlayer()

	if ( !IsAlive( ent ) )
		return false

	if ( !IsValid( player ) )
		return false

	if ( !ent.IsNPC() && !ent.IsPlayer() )
	{
		if ( ( "showWeakpoints" in ent.s ) && ent.s.showWeakpoints )
			return true
		else
			return false
	}

	if ( ent.GetTeam() == player.GetTeam() )
		return false

	local soul = ent.GetTitanSoul()
	if ( IsValid( soul ) )
	{
		if ( soul.GetShieldHealth() )
			return false

		if ( soul.GetInvalidHealthBarEnt() )
			return false
	}

	//Turn off AR if you are rodeoing
	if ( ent == GetTitanBeingRodeoed( player ) )
		return false

	//if ( ent.IsTitan() && ent.GetDoomedState() )
	//	return false

	if ( !WeaponCanCrit( player.GetActiveWeapon() ) )
		return false

	if ( GetHealthBarTargetEntity( player ) )
	{
		return ent == GetHealthBarTargetEntity( player )
	}
	else
	{
		local eyePos = player.EyePosition()
		eyePos.z = 0

		local entPos = ent.GetWorldSpaceCenter()
		entPos.z = 0

		local eyeVec = player.GetViewVector()
		eyeVec.z = 0
		eyeVec.Normalize()

		local dirToEnt = (entPos - eyePos)
		dirToEnt.Normalize()

		if ( dirToEnt.Dot( eyeVec ) < 0.996 )
			return false
	}

	return true
}


function VMTCallback_RBCooldown( player )
{
	local weapon = player.GetOffhandWeapon( 0 )
	if ( !IsValid( weapon ) )
		return 0

	local cooldownFrac = 1.0

	if ( "CooldownBarFracFunc" in weapon.GetScriptScope() )
		cooldownFrac = weapon.GetScriptScope().CooldownBarFracFunc()

	Assert( cooldownFrac >= 0 && cooldownFrac <= 1.0 )

	return (cooldownFrac * 60).tointeger()
}


function VMTCallback_LBCooldown( player )
{
	local weapon = player.GetOffhandWeapon( 1 )
	if ( !IsValid( weapon ) )
		return 0

	local cooldownFrac = 1.0

	if ( "CooldownBarFracFunc" in weapon.GetScriptScope() )
		cooldownFrac = weapon.GetScriptScope().CooldownBarFracFunc()

	Assert( cooldownFrac >= 0 && cooldownFrac <= 1.0 )

	return (cooldownFrac * 60).tointeger()
}

::g_frac <- 0.0

// 2.5 = lots
// 0.8 = none

function VMTCallback_DamageFlash( player )
{
	//local damageTimeDelta = Time() - GetLastDamageTime( player )

	//local frac = 0

	local frac = GetHealthFrac( player )

	//const DAMAGE_OUT_TIME = 0.5
	frac = GraphCapped( frac, 0.0, 0.75, 2.5, 0.8 )
	return Vector( frac, frac, 0.0 )
}

function VMTCallback_CompassTickerOffset( player )
{
	local playerYaw = player.CameraAngles().y

	playerYaw /= 360

	return Vector( -playerYaw, 0.0, 0.0 )
}

function VMTCallback_CompassTickerScale( player )
{
	return Vector( 0.225, 0.95, 1.0 )
}

const DAMAGEHUD_ARROW_FADE_TIME = 0.25

function VMTCallback_DamageArrowAlpha( entity )
{
	return GraphCapped( entity.s.arrowData.endTime - Time(), 0.0, DAMAGEHUD_ARROW_FADE_TIME, 0.0, 1.0 )
}


function VMTCallback_DamageArrowDepthAlpha( entity )
{
	return (entity.s.arrowData.endTime - Time()) > DAMAGEHUD_ARROW_FADE_TIME ? 1.0 : 0.0
}


function VMTCallback_DamageArrowFlash( entity )
{
	local flashVal
	if ( Time() - entity.s.arrowData.startTime < 0.15 )
		flashVal = 0.0
	else
		flashVal = GraphCapped( Time() - entity.s.arrowData.startTime, 0.15, 0.65, 2.0, 0.0 )

	return Vector( 1.0, flashVal, flashVal )
}
