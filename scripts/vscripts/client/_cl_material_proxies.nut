
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
	local weapon = player.GetActiveWeapon()
	local currentAmmo = player.GetActiveWeaponPrimaryAmmoLoaded()
	local numOfFrames = player.GetWeaponAmmoMaxLoaded( weapon ) // max clip ammo (9 normal, 12 extended)
	local frame

	Assert( currentAmmo <= numOfFrames )

	if ( currentAmmo > numOfFrames )
		return 1

	if ( currentAmmo == 0 )
		frame = 0
	else
		frame = ( ( numOfFrames + 1 ) - currentAmmo )

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

///////////////////////////////////////////////////////////////////////////////////////////////////////

const MAX_PROSCREEN_VALUE = 999999
function VMTCallback_ProScreen( entity )
{
	return GetProScreenStats()
}

function VMTCallback_GruntProScreen( entity )
{
	return GetProScreenStats( false, true )
}

function VMTCallback_AllProScreen( entity )
{
	return GetProScreenStats( true, true )
}

function VMTCallback_HasMaxedProScreen( entity )
{
	local kills = GetProScreenStats()

	if ( kills >= MAX_PROSCREEN_VALUE )
		return 1

	return 0
}

function GetProScreenStats( pilots = true, grunts = false )
{
	local kills = 0

	local player = GetLocalViewPlayer()
 	if ( !IsValid( player ) )
 		return kills

	local weapon = player.GetActiveWeapon()
 	if ( !IsValid( weapon ) )
 		return kills

	local weaponName = weapon.GetWeaponClassName()
	if ( !ItemDefined( weaponName ) )
		return kills

	if ( pilots )
	{
		kills += StatToInt( "weapon_kill_stats", "pilots", weaponName, player )
		kills += StatToInt( "weapon_kill_stats", "titansTotal", weaponName, player )
	}

	if ( grunts )
	{
 		kills += StatToInt( "weapon_kill_stats", "grunts", weaponName, player )
		kills += StatToInt( "weapon_kill_stats", "spectres", weaponName, player )
		kills += StatToInt( "weapon_kill_stats", "marvins", weaponName, player )
	}

	if ( kills >= MAX_PROSCREEN_VALUE )
		return MAX_PROSCREEN_VALUE

	return kills
}


// https://thunderstore.io/c/northstar/p/Creamy_jpg/Customisable_Reticles_Framework/

// cl_fovscale values
const FOV_70 = 1.0
const FOV_76 = 1.0825
const FOV_80 = 1.1375
const FOV_86 = 1.22
const FOV_90 = 1.275
const FOV_96 = 1.3575
const FOV_100 = 1.4125
const FOV_106 = 1.495
const FOV_110 = 1.55
const FOV_115 = 1.6
const FOV_120 = 1.7

function VMTCallback_FOVReticleOffset( ent )
{
	local fov = GetConVarFloat( "cl_fovScale" )
	local offset = 1.0

	// offsetVals values are completely arbitraty, i just input random numbers until they worked fine
	// No maths involved here
	local fovVals = [ FOV_70, FOV_76, FOV_80, FOV_86, FOV_90, FOV_96, FOV_100, FOV_106, FOV_110, FOV_115, FOV_120 ]
	local offsetVals = [ 1.5, 1.3, 1.25, 1.2, 1.15, 1.0, 0.95, 0.85, 0.8, 0.75, 0.65 ]

	local count = 0
	local count2 = 1
	foreach ( val in fovVals )
	{
		if ( count >= 10 )
			break

		offset = GraphCapped( fov, fovVals[count], fovVals[count2], offsetVals[count], offsetVals[count2] )

		count++
		count2++
	}

	return offset
}

function VMTCallback_ColorBlindRed( ent )
{
	local col = GetColorBlindColors()

	return col.Red
}

function VMTCallback_ColorBlindBlue( ent )
{
	local col = GetColorBlindColors()

	return col.Blue
}

function VMTCallback_ColorBlindYellow( ent )
{
	local col = GetColorBlindColors()

	return col.Yellow
}

function GetColorBlindColors()
{
	colorInfo <- {}
	colorInfo.Red <- Vector( 0, 0, 0 )
	colorInfo.Blue <- Vector( 0, 0, 0 )
	colorInfo.Yellow <- Vector( 0, 0, 0 )

	if ( !GetConVarBool( "delta_improved_colorblind" ) )
		return

	local colorblind = GetConVarInt( "colorblind_mode" )
	switch( colorblind )
	{
		// Deuteranopia
		case 1:
			colorInfo.Red = Vector( 4.45, 3.9, 0 )
			colorInfo.Blue = Vector( 0.247, 0.501, 0.965 ) * 5
			colorInfo.Yellow = Vector( 0, 0, 0 ) // TODO
			break

		// Tritanopia
		case 2:
			colorInfo.Red = Vector( 4, 2.51, 2.72 )
			colorInfo.Blue = Vector( 0.1, 5.8, 7.7 )
			colorInfo.Yellow = Vector( 0, 0, 0 )
			break

		// Protanopia
		case 3:
			colorInfo.Red = Vector( 4.1, 3.7, 0.3 )
			colorInfo.Blue = Vector( 2.8, 5.2, 9.7 )
			colorInfo.Yellow = Vector( 0, 0, 0 )
			break
	}

	return colorInfo
}
