
//
// Weapon Sounds
//
/*weaponSounds <- {}
weaponSounds["fire"]	<- "Weapon_r1Garand.Fire"

weaponSounds["ping"]	<- "Weapon_r1Garand.Ping"
weaponSounds["npc_fire"]	<- "ai_weapon_fire"
weaponSounds["single_casing"]	<- "Weapon_bulletCasing.Single"


//
// Weapon Effects
//
weaponEffects <- {}

foreach( key, value in weaponEffects )
	PrecacheParticleSystem( value )*/


function OnWeaponPrimaryAttack( attackParams )
{
	self.EmitWeaponSound( "Weapon_r1Garand.Fire" )

	//self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	if ( IsServer() )
	{
		local velocity = (attackParams.dir + Vector( 0, 0, 0.05 )) * 1000
		local velocity2 = (attackParams.dir + Vector( -0.3, 0, 0.05 )) * 1000
		local velocity3 = (attackParams.dir + Vector( 0.3, 0, 0.05 )) * 1000
		local angularVelocity = Vector( RandomFloat( -1200, 1200 ), 100, 0 )
		local fuseTime = 2
		local scriptDamageType = damageTypes.Gibs

		self.FireWeaponGrenade( attackParams.pos, velocity, angularVelocity, fuseTime, scriptDamageType, scriptDamageType, PROJECTILE_NOT_PREDICTED, true, false )
		self.FireWeaponGrenade( attackParams.pos, velocity2, angularVelocity, fuseTime, scriptDamageType, scriptDamageType, PROJECTILE_NOT_PREDICTED, true, false )
		self.FireWeaponGrenade( attackParams.pos, velocity3, angularVelocity, fuseTime, scriptDamageType, scriptDamageType, PROJECTILE_NOT_PREDICTED, true, false )
	}
}


function OnClientAnimEvent( eventName )
{
}
