const PELLETS_PER_BARREL = 11  // number of fake antilag bullets to fire per blast (for the look)
const PELLETS_PER_ADDITIONAL_BARREL = 3

const PLASMA_RIFLE_SPEED = 2500
const PLASMA_RIFLE_SPREAD = 2.0  // full cone width in degrees: every shot lands within half of this of the aim

// tmp_plasma_ball is a short lived effect, so the trail stops while the shot is still flying. It is put back on the shot
// this often to keep the electricity on it until the shot is gone.
const PLASMA_RIFLE_TRAIL_REFRESH = 0.5

function TitanShotgunPrecache( weapon )
{
	if ( WeaponIsPrecached( self ) )
		return

	PrecacheParticleSystem( "wpn_muzzleflash_xo_shotgun_fp" )
	PrecacheParticleSystem( "wpn_shelleject_titan_shot_fp" )
	PrecacheParticleSystem( "wpn_shelleject_pistol" )
	PrecacheParticleSystem( "wpn_muzzleflash_xo_shotgun" )

	PrecacheParticleSystem( "wpn_muzzleflash_xo_shotgun_ALT_FP" )
	PrecacheParticleSystem( "wpn_muzzleflash_xo_shotgun_ALT" )
	PrecacheParticleSystem( "wpn_shelleject_titan_shot_alt_fp" )
	PrecacheParticleSystem( "wpn_shelleject_pistol_FP" )
	PrecacheParticleSystem( "tmp_plasma_ball" )
}
TitanShotgunPrecache( self )

function OnWeaponPrimaryAttack( attackParams )
{
	if ( self.HasMod( "plasma_rifle" ) )
	{
		if ( IsServer() || self.ShouldPredictProjectiles() )
		{
			self.EmitWeaponSound( "Weapon_smartrifle.Fire" )
			local dir = ApplyVectorSpread( attackParams.dir, PLASMA_RIFLE_SPREAD )
			local bolt = self.FireWeaponBolt( attackParams.pos, dir, PLASMA_RIFLE_SPEED, damageTypes.GibBullet | DF_IMPACT | DF_EXPLOSION | DF_SPECTRE_GIB, DF_EXPLOSION | DF_RAGDOLL | DF_SPECTRE_GIB, true )
			bolt.kv.bounceFrac = 0.0
			bolt.kv.gravity = 0.01
			if ( IsServer() )
				thread PlasmaRifleBoltKeepTrail( bolt )
		}

		return 1
	}

	local totalBarrels = self.GetWeaponInfoFileKeyField( "ammo_clip_size" )

	local numBarrelsToFire = 1

	self.EmitWeaponSound( "titan_shotgun_mega_fire" )
	if ( attackParams.firstTimePredicted )
		thread PlayCasingsSound( numBarrelsToFire )

	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	ShotgunBlast( attackParams.pos, attackParams.dir, PELLETS_PER_BARREL, damageTypes.Shotgun, numBarrelsToFire )

	return 1
}

// The electricity on the shot is a short lived effect, so it is put back on the bolt while the bolt is still flying.
// Without this the trail fades out part way through the flight and the shot arrives looking like nothing happened.
// It runs on the server because the bolt a client holds from its own prediction is destroyed within a fraction of a
// second, while the server's bolt lives for the whole flight, so the effect has to follow that one.
function PlasmaRifleBoltKeepTrail( bolt )
{
	bolt.EndSignal( "OnDestroy" )

	while ( IsValid( bolt ) )
	{
		PlayFXOnEntity( "tmp_plasma_ball", bolt )
		wait PLASMA_RIFLE_TRAIL_REFRESH
	}
}

function PlayCasingsSound( numCasings )
{
	self.EndSignal( "OnDestroy" )

	local minDelay = 0.1
	local maxDelay = 0.3

	for ( local i = 0; i < numCasings; i++ )
	{
		self.EmitWeaponSound( "Weapon_shellCasings.Bounce" )
		Wait ( RandomFloat( minDelay, maxDelay ) )
	}
}

function OnWeaponNpcPrimaryAttack( attackParams )
{
	self.EmitWeaponSound( "Weapon_shellCasings.Bounce" )

	local numBarrelsToFire = 1

	local numPellets = PELLETS_PER_BARREL

	numBarrelsToFire = self.GetWeaponPrimaryClipCount()
	numPellets = PELLETS_PER_BARREL + ( ( numBarrelsToFire - 1 ) * PELLETS_PER_ADDITIONAL_BARREL )


	self.EmitWeaponSound( "titan_shotgun_mega_fire" )

	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	ShotgunBlast( attackParams.pos, attackParams.dir, numPellets, damageTypes.Shotgun, numBarrelsToFire )

	return 1
}

function OnClientAnimEvent( name )
{
	if ( name == "muzzle_flash" )
	{
		if ( self.IsWeaponAdsButtonPressed() )
			self.PlayWeaponEffect( "wpn_muzzleflash_xo_shotgun_ALT_FP", "wpn_muzzleflash_xo_shotgun_ALT", "muzzle_flash" )
		else
			self.PlayWeaponEffect( "wpn_muzzleflash_xo_shotgun_fp", "wpn_muzzleflash_xo_shotgun", "muzzle_flash" )
	}

	if ( name == "shell_eject" )
	{
		if ( self.IsWeaponAdsButtonPressed() )
			self.PlayWeaponEffect( "wpn_shelleject_titan_shot_alt_fp", "wpn_shelleject_pistol_FP", "shell" )
		else
			self.PlayWeaponEffect( "wpn_shelleject_titan_shot_fp", "wpn_shelleject_pistol", "shell" )
	}

}

function OnWeaponStartZoomIn()
{
	HandleWeaponSoundZoomIn( self, "Weapon_Titan_Shotgun.ALT_On" )
}


function OnWeaponStartZoomOut()
{
	HandleWeaponSoundZoomOut( self, "Weapon_Titan_Shotgun.ALT_Off" )
}
