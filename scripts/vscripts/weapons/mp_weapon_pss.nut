
weaponFireID <- GetWeaponFireID( self )
Assert( weaponFireID < MAX_WEAPON_FIRE_ID )

function PSSPrecache()
{
	if ( WeaponIsPrecached( self ) )
		return

	PrecacheParticleSystem( "wpn_muzzleflash_smg_FP" )
	PrecacheParticleSystem( "wpn_muzzleflash_smg" )
	PrecacheParticleSystem( "wpn_shelleject_rifle_assault_FP" )
	PrecacheParticleSystem( "wpn_shelleject_rifle_assault" )
}
PSSPrecache()

function OnWeaponPrimaryAttack( attackParams )
{
	self.EmitWeaponSound( "Anti_Titan_Rifle.Single" )
	self.EmitWeaponSound( "Weapon_bulletCasings.Bounce" )
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	self.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, damageTypes.Instant | damageTypes.Bullet )
}


function OnWeaponNpcPrimaryAttack( attackParams )
{
	self.EmitWeaponSound( "Anti_Titan_Rifle.Single" )
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	self.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, damageTypes.Instant | damageTypes.SmallArms )
}


function OnWeaponStartZoomIn()
{
	HandleWeaponSoundZoomIn( self, "Weapon_hemlok.ADS_In" )
}


function OnWeaponStartZoomOut()
{
	HandleWeaponSoundZoomOut( self, "Weapon_hemlok.ADS_Out" )
}


function OnClientAnimEvent( name )
{
	if ( name == "muzzle_flash" )
		self.PlayWeaponEffect( "wpn_muzzleflash_smg_FP", wpn_muzzleflash_smg , "muzzle_flash" )

	if ( name == "shell_eject" )
		self.PlayWeaponEffect( "wpn_shelleject_rifle_assault_FP", "wpn_shelleject_rifle_assault", "shell" )
}