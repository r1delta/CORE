
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

	if ( self.GetClassname() == "mp_weapon_mega_turret_aa" )
	{
		// AA turrets share this script but do fake bullets for framerate optimization since they dont shoot any players
		self.FireWeaponBullet_Special( attackParams.pos, attackParams.dir, 1, 0, true, false, true, false )
	}
	else
	{
		local weaponOwner = self.GetWeaponOwner()
		local weaponOwnerEnemy = weaponOwner.GetEnemy()

		weaponOwner.kv.AccuracyMultiplier = 0.6
		if ( IsPilot( weaponOwnerEnemy ) )
			weaponOwner.kv.AccuracyMultiplier = 3.0

		self.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, 0 )
	}

	local muzzleFlashFX = "wpn_muzzleflash_mega_trrt"
	local shellEjectFX = "wpn_shelleject_40mm"

	local turretOwner = self.GetOwner()

	if ( !IsAlive( turretOwner ) )
		return

	local ownerModel = turretOwner.GetModelName()

	if ( ownerModel in weaponBarrelInfo )
	{
		local barrelIndex = attackParams.barrelIndex
		local barrelInfo = weaponBarrelInfo[ ownerModel ][ barrelIndex ]
		local muzzleTagIdx = turretOwner.LookupAttachment( barrelInfo.muzzleFlashTag )
		local shellTagIdx = turretOwner.LookupAttachment( barrelInfo.shellEjectTag )

		//printt( "barrel index: " + barrelIndex )

		self.PlayWeaponEffectOnOwner( muzzleFlashFX, muzzleTagIdx )
		self.PlayWeaponEffectOnOwner( shellEjectFX, shellTagIdx )
	}
	else
	{
		//fallback to oldstyle if the model isn't recognized
		printl( "Warning, megaturret's owner world model isn't set up for multi barrel firing: '" + ownerModel + "'" )
		self.PlayWeaponEffect( muzzleFlashFX, muzzleFlashFX, "muzzle_flash" )
	}
}
