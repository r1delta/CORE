
smartRifle_ColorCorrection <- "materials/correction/orange_contrast.raw"

//==================================================================================================

function SmartCannonPrecache()
{
	if ( WeaponIsPrecached( self ) )
		return

	PrecacheParticleSystem( "wpn_muzzleflash_xo_FP" )
	PrecacheParticleSystem( "wpn_muzzleflash_xo" )
	PrecacheParticleSystem( "wpn_shelleject_pistol_FP" )
	PrecacheParticleSystem( "wpn_shelleject_pistol" )
}
SmartCannonPrecache()

function OnWeaponActivate( activateParams )
{
	local player = self.GetWeaponOwner()

	// Old usage
	//SmartAmmo_Start( self )
	//SmartAmmo_SetEffectiveRange( self, 100, 5000 )
	//SmartAmmo_SetUnlockFalloffTime( self, 0.0 )
	//SmartAmmo_SetDotLimitActive( self, 0.996 )
	//SmartAmmo_SetDotLimit( self, 0.994 )
//	DoColorCorrection( player, smartRifle_ColorCorrection, 0, 100 )
}

function OnWeaponDeactivate( deactivateParams )
{
	SmartAmmo_Stop( self )
}

function OnClientAnimEvent( name )
{
	if ( name == "muzzle_flash" )
		self.PlayWeaponEffect( "wpn_muzzleflash_xo_FP", "wpn_muzzleflash_xo", "muzzle_flash" )

	if ( name == "shell_eject" )
		self.PlayWeaponEffect( "wpn_shelleject_pistol_FP", "wpn_shelleject_pistol", "shell" )
}

function OnWeaponPrimaryAttack( attackParams )
{
	return SmartAmmo_FireWeapon( self, attackParams )
}
