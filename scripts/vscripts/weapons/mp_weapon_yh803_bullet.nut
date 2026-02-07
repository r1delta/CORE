
function YH803BulletPrecache()
{
	if ( WeaponIsPrecached( self ) )
		return

	PrecacheParticleSystem( "wpn_muzzleflash_sentry" )
	PrecacheParticleSystem( "wpn_shelleject_sentry" )
}
YH803BulletPrecache()

function OnWeaponPrimaryAttack( attackParams )
{
	//self.EmitWeaponSound( "Coop_SentryGun.Fire" )
	//self.EmitWeaponSound( "Weapon_bulletCasings.Bounce" )
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	self.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, 0 )
}

function OnWeaponNpcPrimaryAttack( attackParams )
{
	//self.EmitWeaponSound( "Coop_SentryGun.Fire" )
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	self.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, 0 )

//	self.PlayWeaponEffect( "wpn_muzzleflash_sentry", "wpn_muzzleflash_sentry", "muzzle_flash" )
//	self.PlayWeaponEffect( "wpn_shelleject_sentry", "wpn_shelleject_sentry", "shell" )
}

function OnWeaponActivate( activateParams )
{
	SetLoopingWeaponSound_1p3p( "Coop_Weapon_SentryGun_FirstShot_3P", "Coop_Weapon_SentryGun_Loop_3P", "Coop_Weapon_SentryGun_LoopEnd_3P",
		                           "Coop_Weapon_SentryGun_FirstShot_3P", "Coop_Weapon_SentryGun_Loop_3P", "Coop_Weapon_SentryGun_LoopEnd_3P" )
}

function OnWeaponDeactivate( deactivateParams )
{
	self.ClearLoopingWeaponSound()
}
