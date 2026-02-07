function ChaffPrecache()
{
	if ( WeaponIsPrecached( self ) )
		return

	PrecacheParticleSystem( "xo_chaff" )
}
ChaffPrecache()

function OnWeaponPrimaryAttack( attackParams )
{
	// Play sound
	self.EmitWeaponSound( "Weapon_r1Chaser.Single" )
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	if ( IsClient() )
		return

	local owner = self.GetWeaponOwner()
	if ( !owner.IsPlayer() )
		return

	owner.SmartAmmoUnlock()

	local chaffPos = {}
	chaffPos[0] <- owner.OffsetPositionFromView( attackParams.pos, Vector( 20, 200, 0 ) )
	chaffPos[1] <- owner.OffsetPositionFromView( attackParams.pos, Vector( 20, -200, 0 ) )

	local decoyOwner = owner

	// Missile Decoy
	foreach( pos in chaffPos )
	{
		local decoy = CreateEntity( "missile_decoy" )
		decoy.kv.radius = 512
		decoy.SetName( UniqueString() )
		decoy.SetOrigin( pos )
		DispatchSpawn( decoy, false )
		decoy.SetOwner( decoyOwner )
		decoy.Kill( 4.0 )
	}

	// Missile Decoy Effect
	PlayFXOnEntity( "xo_chaff", owner, "vent_left" )
	PlayFXOnEntity( "xo_chaff", owner, "vent_right" )
}

function OnClientAnimEvent( name )
{
}