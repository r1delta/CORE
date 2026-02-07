
function ThumperPrecache()
{
	if ( WeaponIsPrecached( self ) )
		return

	PrecacheParticleSystem( "wpn_muzzleflash_xo_fp" )
	PrecacheParticleSystem( "wpn_muzzleflash_xo" )

	if ( IsServer() )
	{
		PrecacheModel( "models/weapons/grenades/m20_f_grenade.mdl" )
	}
}
ThumperPrecache()

function OnWeaponPrimaryAttack( attackParams )
{
	self.EmitWeaponSound( "Weapon_r1Garand.Fire" )

	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	if ( !IsServer() )
		return

	thread FireRateCheck( self )
	local attackVec1
	local attackVec2
	local attackVec3

	local attackAngles = attackParams.dir.GetAngles()
	local fuseTime = 1.8  // 1.5
	local scriptDamageType = damageTypes.Explosive

	local attackOffsets

	// run this before firing
	thread WeaponRegenAmmoPrototypeNew( self, 0.7 )


//		if ( self.IsWeaponAdsButtonPressed() )

//			attackOffsets = [
//								Vector( 0, RandomFloat( -1, 1 ), 0 )

	local numShots = min( self.GetWeaponPrimaryClipCount(), 1 )
//		Assert( numShots <= attackOffsets.len() )

	local attackVec = ( attackAngles ).AnglesToForward() * 2000 // 2k is about the max velocity of grenades right now
	local angularVelocity = Vector( RandomFloat( -1200, 1200 ), 100, 0 )
	local nade = self.FireWeaponGrenade( attackParams.pos, attackVec, angularVelocity, fuseTime, scriptDamageType, scriptDamageType, PROJECTILE_NOT_PREDICTED, true, false )
	if ( nade )
	{
		nade.SetModel( "models/weapons/grenades/m20_f_grenade.mdl" )
	}

	return numShots
}

function FireRateCheck( weapon )
{
	if ( "fireRate" in weapon.s )
		return
	weapon.s.fireRate <- weapon.GetFireRateDelay()
	weapon.EndSignal( "OnDestroy" )

	local wasZoomed = OwnerZooms( weapon )
	local zoomed
	for ( ;; )
	{
		zoomed = OwnerZooms( weapon )
		if ( wasZoomed == zoomed )
		{
			wait 0
			continue
		}

		wasZoomed = zoomed
		if ( zoomed )
			weapon.SetFireRateDelay( weapon.s.fireRate * 0.25 )
		else
			weapon.SetFireRateDelay( weapon.s.fireRate )
		printt( "Weapon fire rate " + weapon.GetFireRateDelay() )

		wait 0
	}
}


function WeaponRegenAmmoPrototypeNew( weapon, delay )
{
	if ( "maxAmmo" in weapon.s )
		return

	weapon.EndSignal( "OnDestroy" )
	weapon.s.maxAmmo <- weapon.GetWeaponPrimaryClipCount()

	local ammo
	for ( ;; )
	{
		wait delay
		ammo = weapon.GetWeaponPrimaryClipCount()
		if ( ammo < weapon.s.maxAmmo )
			weapon.SetWeaponPrimaryClipCount( ammo + 1 )
	}
}



function OnClientAnimEvent( name )
{
	if ( name == "muzzle_flash" )
		self.PlayWeaponEffect( "wpn_muzzleflash_xo_fp", "wpn_muzzleflash_xo", "muzzle_flash" )
}


/*
		if ( self.IsWeaponAdsButtonPressed() )
		{
			local attackVec = (attackAngles + Vector( 10, 0, 0 )).AnglesToForward() * 12000
			self.FireWeaponGrenade( attackParams.pos, attackVec, angularVelocity, fuseTime, scriptDamageType, PROJECTILE_NOT_PREDICTED, true )

			return 1
		}
		else
		{
			local attackOffsets = [ 	Vector( 0, 0, 0 ),
										Vector( 5, 0, 0 ),
										Vector( -5, 0, 0 ),
										Vector( 10, 0, 0 ),
										Vector( -10, 0, 0 ) ]

			local numShots = self.GetWeaponPrimaryClipCount()
			Assert( numShots < attackOffsets.len() )

			for( local i = 0; i < numShots; i++ )
			{
				local attackVec = (attackAngles + attackOffsets[i]).AnglesToForward() * 12000
				self.FireWeaponGrenade( attackParams.pos, attackVec, angularVelocity, fuseTime, scriptDamageType, PROJECTILE_NOT_PREDICTED, true )
			}

			return 3
		}

*/