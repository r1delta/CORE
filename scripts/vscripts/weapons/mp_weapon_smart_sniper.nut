
// sets the RSPN-101 color to blue, remove when using different model
self.SetWeaponSkin( 2 )

//==================================================================================================

function SmartSniperPrecache()
{
	if ( WeaponIsPrecached( self ) )
		return

	PrecacheParticleSystem( "wpn_mflash_40mm_smoke_side_FP" )
	PrecacheParticleSystem( "wpn_mflash_40mm_smoke_side" )

	if ( IsServer() )
	{
		PrecacheModel( TITAN_40MM_SHELL_EJECT )

		PrecacheEntity( "crossbow_bolt" )
	}
}
SmartSniperPrecache()

function OnWeaponActivate( activateParams )
{
	//old usage
	//SmartAmmo_SetEffectiveRange( self, 100, 5000 )
	//SmartAmmo_SetDotLimitActive( self, 0.994 )
	//SmartAmmo_SetTargetTitans( self, false )
	//SmartAmmo_Start( self, true )
}

function OnWeaponDeactivate( deactivateParams )
{
	SmartAmmo_Stop( self )
}

function OnClientAnimEvent( name )
{
	if ( name == "muzzle_flash" )
		self.PlayWeaponEffect( "wpn_muzzleflash_pistol_FP", "wpn_muzzleflash_pistol", "muzzle_flash" )

	if ( name == "shell_eject" )
		self.PlayWeaponEffect( "wpn_shelleject_pistol_FP", "wpn_shelleject_pistol", "shell" )
}

function OnWeaponPrimaryAttack( attackParams )
{
	return SmartAmmo_FireWeapon( self, attackParams )
}

function OnWeaponNpcPrimaryAttack( attackParams )
{
	PlayWeaponSound( "Weapon_XO16.Single" )
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS, 0.2 )
	self.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, 0 )
}
