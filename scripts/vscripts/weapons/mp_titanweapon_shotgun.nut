const PELLETS_PER_BARREL = 11  // number of fake antilag bullets to fire per blast (for the look)
const PELLETS_PER_ADDITIONAL_BARREL = 3

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
}
TitanShotgunPrecache( self )

function OnWeaponPrimaryAttack( attackParams )
{
	if ( self.HasMod( "plasma_rifle" ) )
	{
		if ( IsServer() || self.ShouldPredictProjectiles() )
		{
			self.EmitWeaponSound( "Weapon_smartrifle.Fire" )
			local speed = 2500
			local bolt = self.FireWeaponBolt( attackParams.pos, attackParams.dir, speed, damageTypes.GibBullet | DF_IMPACT | DF_EXPLOSION | DF_SPECTRE_GIB, DF_EXPLOSION | DF_RAGDOLL | DF_SPECTRE_GIB, true )
			bolt.kv.bounceFrac = 0.0
			bolt.kv.gravity = 0.01
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
