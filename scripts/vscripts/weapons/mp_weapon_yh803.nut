
self.s.pilotDamageRatio <- 1.0

function YH803Precache()
{
	if ( WeaponIsPrecached( self ) )
		return

	PrecacheParticleSystem( "wpn_muzzleflash_xo_rocket" )
}
YH803Precache()

function OnWeaponActivate( activateParams )
{
	if ( IsServer() )
	{
		// temp name
		if ( self.GetClassname() == "mp_weapon_turret_rockets" )
		{
			// hack to make explosions do less damage to pilots
			self.s.pilotDamageRatio = 0.12
		}
	}
}



function OnWeaponPrimaryAttack( attackParams )
{
/*
	printl( "OnWeaponPrimaryAttack():" )
	foreach( key, value in attackParams )
		printl( "  " + key + " = " + value )
*/

	self.EmitWeaponSound( "Weapon_Titan_Rocket_Launcher.Fire" )
	self.EmitWeaponSound( "Weapon_bulletCasing.Single" )
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	self.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, 0 )
}

function OnWeaponNpcPrimaryAttack( attackParams )
{
/*
	printl( "OnWeaponNpcPrimaryAttack():" )
	foreach( key, value in attackParams )
		printl( "  " + key + " = " + value )
*/

/*
	self.EmitWeaponSound( weaponSounds["fire"] )
	//self.EmitWeaponSound( "Weapon_Titan_Rocket_Launcher.Fire" )
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	self.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, 0 )

	self.PlayWeaponEffect( weaponEffects["wpn_muzzleflash_xo_rocket"], weaponEffects["wpn_muzzleflash_xo_rocket"], "muzzle_flash" )
*/
	self.EmitWeaponSound( "Weapon_Titan_Rocket_Launcher.Fire" )
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	local owner = self.GetWeaponOwner()
	if ( IsServer() )
	{
		local missile = self.FireWeaponMissile( attackParams["pos"], attackParams["dir"], 1800, 0, 0, true, PROJECTILE_NOT_PREDICTED )

		if ( missile )
		{
			// temp name
			// hack to make explosions do less damage to pilots
			missile.s.pilotDamageRatio <- self.s.pilotDamageRatio
		}
	}

	self.PlayWeaponEffect( "wpn_muzzleflash_xo_rocket", "wpn_muzzleflash_xo_rocket", "muzzle_flash" )
}