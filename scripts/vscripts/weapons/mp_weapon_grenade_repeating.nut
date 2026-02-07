
REPEATING_EXLOPSION_FX <- "Weapon_ElectricSmokescreen.Explosion"

REPEATING_EXPLOSION_SOUND <- "Weapon.Explosion_Med"

function W40mmPrecache()
{
	if ( WeaponIsPrecached( self ) )
		return

	if ( IsServer() )
	{
		PrecacheEntity( "npc_grenade_frag" )
	}
}
W40mmPrecache()

function OnWeaponPrimaryAttackAnimEvent( attackParams )
{
	return Grenade_Throw( self, attackParams )
}

function OnWeaponActivate( activateParams )
{
	Grenade_Deploy( self, activateParams )
}

function OnWeaponDeactivate( deactivateParams )
{
	Grenade_Deactivate( self, deactivateParams )
}

function OnProjectileCollision( collisionParams )
{
	if ( IsServer() )
	{
		local currentTime = Time()

		if( self.s.explodeBounceCount == 0 || currentTime - self.s.bounceTime > 0.1 )
		{
			self.s.bounceTime = currentTime
			if ( self.s.explodeBounceCount == 2 )
			{
				self.Explode( Vector( 0, 0, 0 ) )
			}
			else
			{
				self.s.explodeBounceCount++
				self.s.surfaceBounceNormal = collisionParams.normal

				local explosionDamage = GetWeaponInfoFileKeyField_Global( "mp_weapon_grenade_repeating", "explosion_damage" )
				local innerRadius = GetWeaponInfoFileKeyField_Global( "mp_weapon_grenade_repeating", "explosion_inner_radius" )
				local outerRadius = GetWeaponInfoFileKeyField_Global( "mp_weapon_grenade_repeating", "explosionradius" )

				CreateExplosion( collisionParams.pos, explosionDamage/1.5, explosionDamage/1.5, innerRadius / 2, outerRadius / 2, self.GetOwner(), 0.0, REPEATING_EXLOPSION_FX, eDamageSourceId.mp_weapon_grenade_repeating, true )
				EmitSoundOnEntity( self, REPEATING_EXPLOSION_SOUND )

				local reflection = VectorReflectionAcrossNormal( self.GetVelocity(), collisionParams.normal )
				if( abs( reflection.z ) < 300 )
					reflection.z = 300
				self.SetVelocity( reflection * 0.75 )
			}
		}
	}
}