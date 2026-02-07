
const PELLETS_PER_BARREL = 11
const PELLETS_PER_ADDITIONAL_BARREL = 3

function Mega13Precache()
{
	if ( WeaponIsPrecached( self ) )
		return

	PrecacheParticleSystem( "wpn_muzzleflash_xo_shotgun_fp" )
	PrecacheParticleSystem( "wpn_shelleject_pistol_FP" )
	PrecacheParticleSystem( "wpn_shelleject_pistol" )
	PrecacheParticleSystem( "wpn_muzzleflash_xo_shotgun" )
}
Mega13Precache()

function OnWeaponActivate( activateParams )
{
}

function OnWeaponPrimaryAttack( attackParams )
{
	local totalBarrels = self.GetWeaponInfoFileKeyField( "ammo_clip_size" )

	local numBarrelsToFire = 1
	local fireSound = "Weapon_R1Shotgun.Single"

	if ( self.IsWeaponAdsButtonPressed() )
	{
		numBarrelsToFire = self.GetWeaponPrimaryClipCount()
		fireSound = "titan_shotgun_mega_fire"
	}

	local numPellets = PELLETS_PER_BARREL + ( ( numBarrelsToFire - 1 ) * PELLETS_PER_ADDITIONAL_BARREL )

	self.EmitWeaponSound( fireSound )
	if ( attackParams.firstTimePredicted )
		thread PlayCasingsSound( numBarrelsToFire )

	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	ShotgunBlast( attackParams.pos, attackParams.dir, numPellets, damageTypes.Shotgun, numBarrelsToFire )

	return numBarrelsToFire
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
	self.EmitWeaponSound( "Weapon_R1Shotgun.Single" )
	self.EmitWeaponSound( "Weapon_shellCasings.Bounce" )
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	self.FireWeaponBullet( attackParams.pos, attackParams.dir, pelletsPerBarrel, damageTypes.Shotgun )

	return 1
}

function OnClientAnimEvent( name )
{
	if ( name == "muzzle_flash" )
		self.PlayWeaponEffect( "wpn_muzzleflash_xo_shotgun_fp", "wpn_muzzleflash_xo_shotgun", "muzzle_flash" )

	if ( name == "shell_eject" )
		self.PlayWeaponEffect( "wpn_shelleject_pistol_FP", "wpn_shelleject_pistol", "shell" )
}