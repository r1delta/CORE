
const DEFAULT_EMP_FUSE_TIME = 1.75

function GrenadeEMPPrecache()
{
	if ( WeaponIsPrecached( self ) )
		return

	if ( IsServer() )
	{
		PrecacheEntity( "npc_grenade_frag" )
	}
}
GrenadeEMPPrecache()

function OnWeaponTossReleaseAnimEvent( attackParams )
{
	self.EmitWeaponSound( "Weapon_EMPGrenade_Throw" )
	Grenade_Throw( self, attackParams, DEFAULT_EMP_FUSE_TIME )
	return 1
}

function OnWeaponTossPrep( prepParams )
{
	self.EmitWeaponSound( "Weapon_EMPGrenade_PinPull" )
	Grenade_Deploy( self, prepParams, DEFAULT_EMP_FUSE_TIME )
}

function OnWeaponDeactivate( deactivateParams )
{
	Grenade_Deactivate( self, deactivateParams )
}

function OnProjectileCollision( collisionParams )
{
	local hitEnt = collisionParams.hitent
	if( hitEnt != null && IsMagneticTarget( hitEnt ) )
	{
		if( hitEnt.GetTeam() != self.GetTeam() )
			self.Explode( Vector( 0, 0, 0 ) )
	}
}

//function OnWeaponPrimaryAttack( attackParams )
//{
//	if ( self.IsForceRelease() )
//		return false
//	else
//		return true
//}

