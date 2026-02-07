
function FragGrenadePrecache()
{
	if ( WeaponIsPrecached( self ) )
		return

	if ( IsServer() )
	{
		PrecacheEntity( "npc_grenade_frag" )
	}
}
FragGrenadePrecache()

function OnWeaponTossReleaseAnimEvent( attackParams )
{
	self.EmitWeaponSound( "Weapon_FragGrenade_Throw" )
	Grenade_Throw( self, attackParams )
	return 1
}

function OnWeaponTossPrep( prepParams )
{
	self.EmitWeaponSound( "Weapon_FragGrenade_PinPull" )
	Grenade_Deploy( self, prepParams )
}

function OnWeaponDeactivate( deactivateParams )
{
	Grenade_Deactivate( self, deactivateParams )
}

function OnProjectileCollision( collisionParams )
{
	if ( "explodeOnImpact" in self.s )
	{
		self.Explode( Vector(0,0,0) )
		return
	}
}