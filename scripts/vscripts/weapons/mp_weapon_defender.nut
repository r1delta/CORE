const WIND_UP = "ChargeRifle_WindUp"
const WIND_UP_3P = "ChargeRifle_WindUp_3p"
const WIND_DOWN = "ChargeRifle_WindDown"
const WIND_DOWN_3P = "ChargeRifle_WindDown_3p"
const BURN_WIND_UP = "ChargeRifle_WindUp"
const BURN_WIND_UP_3P = "ChargeRifle_WindUp_3p"
const BURN_WIND_DOWN = "ChargeRifle_WindDown"
const BURN_WIND_DOWN_3P = "ChargeRifle_WindDown_3p"

windUpSound <- WIND_UP
windUpSound3p <- WIND_UP_3P
windDownSound <- WIND_DOWN
windDownSound3p <- WIND_DOWN_3P

chargeDownSoundDuration <- null

chargeBeginSound <- null
chargeEndSound <- null

const DEFENDER_STATE_NOTCHARGED = 0
const DEFENDER_STATE_CHARGED = 1
RegisterSignal( "DefenderStopNPCChargeReset" )
RegisterSignal( "DefenderSignalNPCChargeReset" )

function DefenderPrecache()
{
	if ( WeaponIsPrecached( self ) )
		return

	PrecacheParticleSystem( "P_wpn_defender_charge_FP" )
	PrecacheParticleSystem( "P_wpn_defender_charge" )
	PrecacheParticleSystem( "defender_charge_CH_dlight" )

	PrecacheParticleSystem( "wpn_muzzleflash_arc_cannon_fp" )
	PrecacheParticleSystem( "wpn_muzzleflash_arc_cannon" )
}
DefenderPrecache()

function main()
{
	if( IsClient() )
		AddDestroyCallback( "mp_weapon_defender", ClientDestroyCallback_Defender_Stop )
}

function OnWeaponActivate( activateParams )
{
	Defender_Start( self )
	local weaponOwner = self.GetWeaponOwner()
	if( !("weaponOwner" in self.s) )
		self.s.weaponOwner <- weaponOwner
	if ( self.HasMod( "burn_mod_defender" ) )
	{
			windUpSound = BURN_WIND_UP
			windUpSound3p =	BURN_WIND_UP_3P
			windDownSound =	BURN_WIND_DOWN
			windDownSound3p = BURN_WIND_DOWN_3P
	}

	chargeBeginSound = self.GetWeaponInfoFileKeyField( "sound_trigger_pull" )
	chargeEndSound = self.GetWeaponInfoFileKeyField( "sound_trigger_release" )

	//chargeUpSoundDuration = self.GetWeaponInfoFileKeyField( "charge_time" )
	chargeDownSoundDuration = self.GetWeaponInfoFileKeyField( "charge_cooldown_time" )
}


function OnWeaponDeactivate( deactivateParams )
{
	Defender_Stop( self )
}


function OnWeaponOwnerChanged( changeParams )
{
	if ( changeParams.newOwner == null && changeParams.oldOwner != null )
	{
		if ( IsClient() )
		{
			if ( changeParams.oldOwner == GetLocalViewPlayer() )
				Defender_Stop( self )
		}
		else
		{
			Defender_Stop( self )
		}
	}
}


function OnWeaponChargeBegin( chargeParams )
{
	Defender_ChargeBegin( self )
}


function OnWeaponChargeEnd( chargeParams )
{
	Defender_ChargeEnd( self )
}


function OnWeaponPrimaryAttack( attackParams )
{
	if ( self.GetWeaponChargeFraction() < 1.0 )
		return 0

	//thread ArcCannon_HideIdleEffect( self, (1 / fireRate) )

	return FireDefender( self, attackParams )
}


function OnWeaponNpcPrimaryAttack( attackParams )
{
	//thread ArcCannon_HideIdleEffect( self, fireRate )
	return FireDefenderNPC( self, attackParams )
}

function OnWeaponStartZoomIn()
{
	HandleWeaponSoundZoomIn( self, "Weapon_TBD.ADS_In" )
}

function OnWeaponStartZoomOut()
{
	HandleWeaponSoundZoomOut( self, "Weapon_TBD.ADS_Out" )
}


// Rumble
const DEFENDER_RUMBLE_CHARGE_MIN		= 10
const DEFENDER_RUMBLE_CHARGE_MAX		= 30
const DEFENDER_RUMBLE_TYPE_INDEX		= 14		// These are defined in code, 14 = RUMBLE_FLAT_BOTH

// Damage
const DEFENDER_DAMAGE_CHARGE_RATIO	= 1.0		// What amount of charge is required for full damage.

const DEFENDER_SIGNAL_DEACTIVATED = "DefenderDeactivated"
RegisterSignal( DEFENDER_SIGNAL_DEACTIVATED )

const DEFENDER_SIGNAL_CHARGEEND = "DefenderChargeEnd"
RegisterSignal( DEFENDER_SIGNAL_CHARGEEND )


function Defender_Start( weapon )
{
	weapon.EmitWeaponSound( "ChargeRifle_Charged_Loop" )
}


function Defender_Stop( weapon )
{
	weapon.Signal( DEFENDER_SIGNAL_DEACTIVATED )

	weapon.StopWeaponSound( "ChargeRifle_Charged_Loop" )

	if ( IsServer() )
	{
		StopSoundOnEntity( weapon, windDownSound )
		StopSoundOnEntity( weapon, windUpSound )
	}
	else
	{
		StopSoundOnEntity( weapon, windDownSound3p )
		StopSoundOnEntity( weapon, windUpSound3p )
	}

	weapon.StopWeaponEffect( "P_wpn_defender_charge_FP", "P_wpn_defender_charge" )
	weapon.StopWeaponEffect( "P_wpn_defender_charge", "P_wpn_defender_charge_FP" )
	weapon.StopWeaponEffect( "defender_charge_CH_dlight", "defender_charge_CH_dlight" )
}


function Defender_ChargeBegin( weapon )
{
	if ( IsClient() && InPrediction() && !IsFirstTimePredicted() )
		return

	local weaponOwner = weapon.GetWeaponOwner()
	if ( chargeBeginSound )
		self.EmitWeaponSound( chargeBeginSound )

	local chargeFraction = self.GetWeaponChargeFraction()
	local chargeTime = self.GetWeaponChargeTime()

	weapon.PlayWeaponEffect( "P_wpn_defender_charge_FP", "P_wpn_defender_charge", "muzzle_flash" )
	weapon.PlayWeaponEffect( null, "defender_charge_CH_dlight", "muzzle_flash" )

	if ( IsServer() )
	{
		StopSoundOnEntity( weapon, windDownSound3p )
		EmitSoundOnEntityExceptToPlayer( weapon, weaponOwner, windUpSound3p )
	}
	else
	{
		StopSoundOnEntity( weapon, windDownSound )
		EmitSoundOnEntityWithSeek( weapon, windUpSound, chargeTime )
		//Particle doesn't stay with attachment properly during things like Rodeo.
		//local handle = weapon.AllocateHandleForViewmodelEffect( "P_wpn_defender_charge_FP" )
		//if ( handle )
			//EffectSkipForwardToTime( handle, chargeTime )
		thread cl_ChargeRumble( weapon, DEFENDER_RUMBLE_TYPE_INDEX, DEFENDER_RUMBLE_CHARGE_MIN, DEFENDER_RUMBLE_CHARGE_MAX, DEFENDER_SIGNAL_CHARGEEND )
	}
}


function Defender_ChargeEnd( weapon )
{
	if ( IsClient() && InPrediction() && !IsFirstTimePredicted() )
		return

	local weaponOwner = weapon.GetWeaponOwner()
	if ( chargeEndSound )
		self.EmitWeaponSound( chargeEndSound )

	local chargeFraction = self.GetWeaponChargeFraction()

	local seekFrac = chargeDownSoundDuration * chargeFraction
	local seekTime = max( (1 - (seekFrac * chargeDownSoundDuration)), 0 )

	if ( IsServer() )
	{
		StopSoundOnEntity( weapon, windUpSound3p )
		if ( IsValid ( weaponOwner ) )
			EmitSoundOnEntityExceptToPlayer( weapon, weaponOwner, windDownSound3p )
	}
	else
	{
		StopSoundOnEntity( weapon, windUpSound )
		EmitSoundOnEntityWithSeek( weapon, windDownSound, seekTime )
		weapon.Signal( DEFENDER_SIGNAL_CHARGEEND )
	}

	self.StopWeaponEffect( "P_wpn_defender_charge_FP", "P_wpn_defender_charge" )
	self.StopWeaponEffect( "P_wpn_defender_charge", "P_wpn_defender_charge_FP" )
	self.StopWeaponEffect( "defender_charge_CH_dlight", "defender_charge_CH_dlight" )
}

/*HACK -> it uses 2 fire commands to do one shot
1 - the first fire command charges the gun
2 - the second fire command fires the gun
3 - if the second fire command doesn't come within 4 seconds, the gun decharges
*/
function FireDefenderNPC( weapon, attackParams )
{
	if ( !IsServer() )
		return

	local weaponOwner = weapon.GetWeaponOwner()
	if ( !( "npcDefenderState" in weaponOwner.s ) )
		weaponOwner.s.npcDefenderState <- DEFENDER_STATE_NOTCHARGED

	if ( weaponOwner.s.npcDefenderState == DEFENDER_STATE_NOTCHARGED )
	{
		weaponOwner.s.npcDefenderState = DEFENDER_STATE_CHARGED
		return FireDefenderNPCCharge( weaponOwner, weapon, attackParams )
	}
	else
	{
		weaponOwner.Signal( "DefenderStopNPCChargeReset" )
		weaponOwner.s.npcDefenderState = DEFENDER_STATE_NOTCHARGED
		return FireDefender( weapon, attackParams )
	}
}

function FireDefenderNPCCharge( weaponOwner, weapon, attackParams )
{
	if ( chargeBeginSound )
		self.EmitWeaponSound( chargeBeginSound )

	weapon.PlayWeaponEffect( "P_wpn_defender_charge_FP", "P_wpn_defender_charge", "muzzle_flash" )
	weapon.PlayWeaponEffect( null, "defender_charge_CH_dlight", "muzzle_flash" )

	StopSoundOnEntity( weapon, windDownSound3p )
	EmitSoundOnEntity( weapon, windUpSound3p )

	thread DefenderNPCChargeReset( weaponOwner, weapon )
	return 0
}

function DefenderNPCChargeReset( weaponOwner, weapon )
{
	if ( !IsAlive( weaponOwner ) )
		return

	weaponOwner.EndSignal( "OnDeath" )
	weaponOwner.EndSignal( "OnDestroy" )
	weaponOwner.EndSignal( "DefenderStopNPCChargeReset" )
	thread StopWeaponEffectOnOwnerDeath( weaponOwner, weapon )

	wait 4.5

	if ( IsValid( weaponOwner ) )
	{
		weaponOwner.Signal( "DefenderSignalNPCChargeReset" )
		weaponOwner.s.npcDefenderState = DEFENDER_STATE_NOTCHARGED
	}
	if ( IsValid( weapon ) )
	{
		StopSoundOnEntity( weapon, windUpSound3p )
		EmitSoundOnEntity( weapon, windDownSound3p )
	}
}

function StopWeaponEffectOnOwnerDeath( weaponOwner, weapon )
{
	WaitSignal( weaponOwner, "OnDeath", "DefenderStopNPCChargeReset", "DefenderSignalNPCChargeReset" )

	if ( !IsValid( weapon ) )
		return

	weapon.StopWeaponEffect( "P_wpn_defender_charge_FP", "P_wpn_defender_charge" )
	weapon.StopWeaponEffect( null, "defender_charge_CH_dlight" )
}

function FireDefender( weapon, attackParams )
{
	if ( IsServer() )
	{
		StopSoundOnEntity( weapon, windDownSound )
		StopSoundOnEntity( weapon, windUpSound )
	}
	else
	{
		StopSoundOnEntity( weapon, windDownSound3p )
		StopSoundOnEntity( weapon, windUpSound3p )
	}

	local weaponOwner = self.GetWeaponOwner()
	if ( weaponOwner.IsPlayer() )
		self.EmitWeaponSound( "ChargeRifle_Fire" )
	else
		self.EmitWeaponSound( "ChargeRifle_Fire" )
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	self.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, DF_GIB | DF_SPECTRE_GIB | DF_EXPLOSION )
	return 1
}

function ClientDestroyCallback_Defender_Stop( entity )
{
	Defender_Stop( entity )
}
