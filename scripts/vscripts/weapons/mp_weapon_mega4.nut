
// this list has to match the order that the barrels are set up in the QC file
weaponBarrelInfo <- {}
local modelMT = "models/turrets/turret_imc_lrg.mdl"  // the return value for turretEnt.GetModelName()
weaponBarrelInfo[ modelMT ] <- {}
weaponBarrelInfo[ modelMT ][ 0 ] <- {}
weaponBarrelInfo[ modelMT ][ 1 ] <- {}
weaponBarrelInfo[ modelMT ][ 2 ] <- {}
weaponBarrelInfo[ modelMT ][ 3 ] <- {}
weaponBarrelInfo[ modelMT ][ 0 ].muzzleFlashTag	<- "MUZZLE_LEFT_UPPER"
weaponBarrelInfo[ modelMT ][ 0 ].shellEjectTag 	<- "SHELL_LEFT_UPPER"
weaponBarrelInfo[ modelMT ][ 1 ].muzzleFlashTag	<- "MUZZLE_LEFT_LOWER"
weaponBarrelInfo[ modelMT ][ 1 ].shellEjectTag	<- "SHELL_LEFT_LOWER"
weaponBarrelInfo[ modelMT ][ 2 ].muzzleFlashTag	<- "MUZZLE_RIGHT_UPPER"
weaponBarrelInfo[ modelMT ][ 2 ].shellEjectTag	<- "SHELL_RIGHT_UPPER"
weaponBarrelInfo[ modelMT ][ 3 ].muzzleFlashTag	<- "MUZZLE_RIGHT_LOWER"
weaponBarrelInfo[ modelMT ][ 3 ].shellEjectTag	<- "SHELL_RIGHT_LOWER"

function MegaTurretPrecache()
{
	if ( WeaponIsPrecached( self ) )
		return

	PrecacheParticleSystem( "wpn_muzzleflash_mega_trrt" )
	PrecacheParticleSystem( "wpn_shelleject_40mm" )
}
MegaTurretPrecache()

function OnWeaponPrimaryAttack( attackParams )
{
	self.EmitWeaponSound( "megaturret_fire" )
	self.EmitWeaponSound( "Weapon_bulletCasings.Bounce" )

	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	self.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, damageTypes.LargeCaliber )
}

function OnWeaponNpcPrimaryAttack( attackParams )
{
	if ( self.HasMod( "O2Bridge" ) )
		self.EmitWeaponSound( "O2_Scr_MegaTurret_Bridge_Fire" )
	else if ( self.HasMod( "O2Beach" ) )
		self.EmitWeaponSound( "O2_Scr_MegaTurret_Beach_Fire" )
	else
		self.EmitWeaponSound( "megaturret_fire" )

	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	local weaponOwner = self.GetWeaponOwner()
	local weaponOwnerEnemy = weaponOwner.GetEnemy()

	weaponOwner.kv.AccuracyMultiplier = 0.6
	if ( IsPilot( weaponOwnerEnemy ) )
		weaponOwner.kv.AccuracyMultiplier = 3.0


	local turretOwner = self.GetOwner()

	if ( !IsAlive( turretOwner ) )
		return

	local up = weaponOwner.GetUpVector()
	local right = weaponOwner.GetRightVector()
	local launchPositionOffsets = [	( up * 20 + right * 60 ),( up * 20 + right * -60 ),( up * -20 + right * -60 ),( up * -20 + right * 60 ) ]
	local launchPosition = attackParams.pos + launchPositionOffsets[ attackParams.barrelIndex ]

	local missile = self.FireWeaponMissile( launchPosition, attackParams.dir, 2200, DF_GIB | DF_EXPLOSION, DF_GIB | DF_EXPLOSION, false, PROJECTILE_NOT_PREDICTED )
}
