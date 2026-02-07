const MP_GIBBER_PISTOL_BURST_COUNT = 50 //number of bursts
const MP_GIBBER_PISTOL_BURST_DELAY = 0.5 //time before the popcors burst off +/- some randomness
const MP_GIBBER_PISTOL_BURST_OFFSET = 0.3 // how much + & - the delay to set off the explosions
const MP_GIBBER_PISTOL_BURST_RANGE = 150 //range of the bursts

//RegisterSignal( "HitSky" )

function GibberBurstPrecache()
{
	if ( WeaponIsPrecached( self ) )
		return

	PrecacheParticleSystem( "wpn_muzzleflash_smg_FP" )
	PrecacheParticleSystem( "wpn_muzzleflash_smg" )

	if ( IsServer() )
	{
		PrecacheEntity( "crossbow_bolt" )
	}
}
GibberBurstPrecache()

function OnWeaponPrimaryAttack( attackParams )
{
	self.EmitWeaponSound( "Weapon_r1357.Single" )
	self.EmitWeaponSound( "Weapon_bulletCasing.Single" )
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	thread FireBurstGrenade( self, attackParams )
}

function OnWeaponNpcPrimaryAttack( attackParams )
{
	self.EmitWeaponSound( "Weapon_Pistol.NPC_Single" )
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	FireBurstGrenade( self, attackParams )
}

function FireBurstGrenade( weapon, attackParams )
{
	if ( IsClient() && !self.ShouldPredictProjectiles() )
		return

	local player = weapon.GetWeaponOwner()
	local team = player.GetTeam()
	local attackPos = player.OffsetPositionFromView( attackParams[ "pos" ], Vector( 0.0, 8.0, 4.0 ) )	// forward, right, up

	local bolt = weapon.FireWeaponBolt( attackPos, attackParams.dir, 2000, damageTypes.Explosive, damageTypes.Explosive, PROJECTILE_PREDICTED )
	bolt.kv.bounceFrac = 0.0
	bolt.kv.gravity = 1.0
}

function OnClientAnimEvent( name )
{
	if ( name == "muzzle_flash" )
	{
		self.PlayWeaponEffect( "wpn_muzzleflash_smg_FP", "wpn_muzzleflash_smg", "muzzle_flash" )
	}
}

function OnProjectileCollision( collisionParams )
{
	popcornInfo <- {}
	popcornInfo.weaponName <- "mp_titanweapon_gibber_burst"
	popcornInfo.damageSourceId <- eDamageSourceId.mp_titanweapon_gibber_burst
	popcornInfo.count <- MP_GIBBER_PISTOL_BURST_COUNT
	popcornInfo.delay <- MP_GIBBER_PISTOL_BURST_DELAY
	popcornInfo.offset <- MP_GIBBER_PISTOL_BURST_OFFSET
	popcornInfo.range <- MP_GIBBER_PISTOL_BURST_RANGE

	local owner = self.GetOwner()
	if ( IsValid( owner ) )
		thread StartPopcornExplosions( self, owner, popcornInfo, null )
}