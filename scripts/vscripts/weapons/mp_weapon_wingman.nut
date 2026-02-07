const PH_ROCKET_FX_TABLE 		= "exp_wingman_explosive_rounds"

self.s.lastFireTeam <- 0

function WingmanPrecache()
{
	if ( WeaponIsPrecached( self ) )
		return

	if ( IsServer() )
	{
		PrecacheImpactEffectTable( PH_ROCKET_FX_TABLE )
	}
}
WingmanPrecache()

function OnWeaponPrimaryAttack( attackParams )
{
	// work around for weapons firing twice on client sometimes. Bugged.
	if ( self.s.lastFireTeam == Time() )
		return
	self.s.lastFireTeam = Time()

	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	if ( self.HasMod( "explosive_rounds" ) )
		self.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, damageTypes.GibBullet | DF_EXPLOSION | DF_SPECTRE_GIB )
	else
		self.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, damageTypes.Bullet | damageTypes.LargeCaliber | DF_SPECTRE_GIB )
}

function OnWeaponNpcPrimaryAttack( attackParams )
{
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	self.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, damageTypes.Bullet | damageTypes.LargeCaliber )
}

function OnWeaponBulletHit( hitParams )
{
	//Temporarily using CreateExplosion until a feature to support explosions off bullets.
	if ( IsServer() && self.HasMod("explosive_rounds") )
		CreateExplosion( hitParams.hitPos, 100, 100, 50, 100, self.GetWeaponOwner(), 0, "Weapon.Explosion_Med", eDamageSourceId.mp_weapon_wingman, true, PH_ROCKET_FX_TABLE )
}

function OnWeaponStartZoomIn()
{
	HandleWeaponSoundZoomIn( self, "Weapon_B3.ADS_In" )
}


function OnWeaponStartZoomOut()
{
	HandleWeaponSoundZoomOut( self, "Weapon_B3.ADS_Out" )
}

function OnWeaponActivate( activateParams )
{
}