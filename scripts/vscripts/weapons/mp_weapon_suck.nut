
const VORTEXGRENADE_PULLING_SOUNDSCRIPT = "k_lab.teleport_pre_suckin"

function SuckPrecache()
{
	if ( WeaponIsPrecached( self ) )
		return

	PrecacheParticleSystem( "wpn_muzzleflash_smg_FP" )
	PrecacheParticleSystem( "wpn_muzzleflash_smg" )
	PrecacheParticleSystem( "wpn_shelleject_pistol_FP" )
	PrecacheParticleSystem( "wpn_shelleject_pistol" )
	PrecacheParticleSystem( "dissolve_flashes" )
}
SuckPrecache()

function OnWeaponPrimaryAttack( attackParams )
{
}

function OnWeaponPrimaryAttackAnimEvent( attackParams )
{
	if ( !IsServer() && !self.ShouldPredictProjectiles() )
		return

	local velocity = (attackParams.dir + Vector( 0, 0, 0.1 )) * 1200
	local angularVelocity = Vector( 3600, RandomFloat( -1200, 1200 ), 0 )
	local fuseTime = 3.9
	local scriptDamageType = 0

	local nade = self.FireWeaponGrenade( attackParams.pos, velocity, angularVelocity, fuseTime, scriptDamageType, scriptDamageType, PROJECTILE_PREDICTED, true, false )
	if ( nade )
	{
		nadeSetup( nade )
	}
}

function OnClientAnimEvent( name )
{
	if ( name == "muzzle_flash" )
	{
		self.PlayWeaponEffect( "wpn_muzzleflash_smg_FP", "wpn_muzzleflash_smg", "muzzle_flash" )
	}

	if ( name == "shell_eject" )
	{
		self.PlayWeaponEffect( "wpn_shelleject_pistol_FP", "wpn_shelleject_pistol", "shell" )
	}
}

function nadeSetup( nade )
{
	if ( IsServer() )
	{
		local owner = self.GetWeaponOwner()
		local myTeam = owner.GetTeam()

		VortexGrenade_CreateFXBall( nade )

		thread createVortexNade( nade )
	}
}

function createVortexNade( nade )
{

	wait ( 1.0 )
	local point_push = CreateEntity( "point_push" )
//	point_push.kv.spawnflags = 28  // no falloff, push players, push physics
	point_push.kv.spawnflags = 29  // test LOS before pushing, no falloff, push players, push physics
	point_push.kv.enabled = 1
	point_push.kv.magnitude = -225
	point_push.kv.radius = 350
	point_push.SetOrigin( nade.GetOrigin() )
	point_push.SetTeam( (self.GetWeaponOwner()).GetTeam() )
	//point_push.SetAngles( nade.GetAngles() )
	DispatchSpawn( point_push, false )

	point_push.SetParent( nade )

	EmitSoundOnEntity( point_push, VORTEXGRENADE_PULLING_SOUNDSCRIPT )
	point_push.Kill( 4 )
}

function VortexGrenade_CreateFXBall( nade )
{
	local fxball = CreateEntity( "info_particle_system" )
	fxball.SetOrigin( nade.GetOrigin() )
	fxball.SetOwner( self.GetWeaponOwner() )
	fxball.kv.effect_name = "dissolve_flashes"
	fxball.kv.start_active = 1
	fxball.kv.VisibilityFlags = 1
	DispatchSpawn( fxball, false )

	fxball.SetParent( nade )

	fxball.Kill( 3.9 )
}