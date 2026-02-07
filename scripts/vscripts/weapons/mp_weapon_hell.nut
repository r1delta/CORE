
//
// Weapon Sounds
//
/*weaponSounds <- {}
weaponSounds["fire"]	<- "Weapon_r1Chaser.Single"
weaponSounds["fire2"]	<- "Weapon_r1357.Single"
weaponSounds["npc_fire"]	<- "Weapon_r1Chaser.Single"
weaponSounds["npc_fire2"]	<- "ai_weapon_fire"


//
// Weapon Effects
//
weaponEffects <- {}
weaponEffects["muzzle_flash_fp"]	<- "wpn_muzzleflash_pistol_FP"
weaponEffects["muzzle_flash"]		<- "wpn_muzzleflash_pistol"
weaponEffects["shell_eject_fp"]		<- "wpn_shelleject_pistol_FP"
weaponEffects["shell_eject"]		<- "wpn_shelleject_pistol"
weaponEffects["env_fire_very_tiny"]		<- "env_fire_very_tiny"



foreach( key, value in weaponEffects )
	PrecacheParticleSystem( value )*/

self.SetWeaponSkin( 1 )



function OnWeaponPrimaryAttack( attackParams )
{
/*
	printl( "OnWeaponPrimaryAttack():" )
	foreach( key, value in attackParams )
		printl( "  " + key + " = " + value )
*/

	self.EmitWeaponSound( "Weapon_r1Chaser.Single" )
	self.EmitWeaponSound( "Weapon_r1357.Single" )


	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	self.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, damageTypes.FlamingGibs )

}

function OnWeaponNpcPrimaryAttack( attackParams )
{
/*
	printl( "OnWeaponNpcPrimaryAttack():" )
	foreach( key, value in attackParams )
		printl( "  " + key + " = " + value )
*/

	self.EmitWeaponSound( "Weapon_r1Chaser.Single" )
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	self.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, damageTypes.FlamingGibs )
}


function OnClientAnimEvent( name )
{
	if ( name == "shell_eject" )
	{
		self.PlayWeaponEffect( "wpn_shelleject_pistol_FP", "wpn_shelleject_pistol", "shell" )
	}
}

function OnWeaponBulletHit( hitParams )
{
	if ( IsServer() )
	{
		local impactSpark = CreateEntity( "info_particle_system" )
		impactSpark.SetOrigin( hitParams.hitPos )
		impactSpark.SetOwner( self.GetWeaponOwner() )
		impactSpark.kv.effect_name = "env_fire_very_tiny"
		impactSpark.kv.start_active = 1
		impactSpark.kv.VisibilityFlags = 1
		DispatchSpawn( impactSpark, false )

		impactSpark.Kill( 2 )
	}
}

