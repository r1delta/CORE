
RegisterSignal( "EndSniperAssist" )

AMMO_BODYGROUP_COUNT <- self.GetWeaponInfoFileKeyField( "ammo_clip_size" )

function SniperPrecache()
{
	if ( WeaponIsPrecached( self ) )
		return

	PrecacheParticleSystem( "wpn_mflash_snp_hmn_smoke_side_FP" )
	PrecacheParticleSystem( "wpn_mflash_snp_hmn_smoke_side" )
	PrecacheParticleSystem( "Rocket_Smoke_SMR_Glow" )

	if ( IsServer() )
	{
		PrecacheEntity( "crossbow_bolt" )
	}
}
SniperPrecache()

function OnWeaponActivate( activateParams )
{
	UpdateViewmodelAmmo()

	if ( self.HasMod( "sniper_assist" ) )
		SmartAmmo_Start( self )

	if ( IsClient() )
		CreateSniperVGUI( GetLocalViewPlayer(), self, true )
}

function OnWeaponOwnerChanged( changeParams )
{
	if ( !IsClient() )
		return

	if ( changeParams.oldOwner == GetLocalViewPlayer() && changeParams.newOwner != GetLocalViewPlayer() )
	{
	}
}

function OnWeaponDeactivate( deactivateParams )
{
	if ( !IsClient() )
		return

	DestroySniperVGUI( self )
	SmartAmmo_Stop( self )
}

function OnWeaponReload( reloadParams )
{
}

function OnClientAnimEvent( name )
{
	GlobalClientEventHandler( name )

	if ( name == "muzzle_flash" )
	{
		self.PlayWeaponEffect( "wpn_mflash_snp_hmn_smoke_side_FP", "wpn_mflash_snp_hmn_smoke_side", "muzzle_flash_L" )
		self.PlayWeaponEffect( "wpn_mflash_snp_hmn_smoke_side_FP", "wpn_mflash_snp_hmn_smoke_side", "muzzle_flash_R" )
	}

	if ( name == "shell_eject" )
	{
		thread DelayedCasingsSound( 0.6 )
	}
}

function DelayedCasingsSound( delayTime )
{
	Wait( delayTime )

	if ( !IsValid( self ) )
		return

	self.EmitWeaponSound( "large_shell_drop" )
}

function OnWeaponPrimaryAttack( attackParams )
{
	local player = self.GetWeaponOwner()

	if( self.HasMod("silencer") )
		self.EmitWeaponSound( "Anti_Titan_Rifle.SingleSuppressed" )
	else
		self.EmitWeaponSound( "Anti_Titan_Rifle.Single" )

	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	return FireWeaponPlayerAndNPC( attackParams, true )
}

function OnWeaponNpcPrimaryAttack( attackParams )
{
	self.EmitWeaponSound( "Weapon_XO16.Single" )
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	return FireWeaponPlayerAndNPC( attackParams, false )
}


function FireWeaponPlayerAndNPC( attackParams, playerFired )
{
	//self.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, damageTypes.LargeCaliber )

	local owner = self.GetWeaponOwner()
	local shouldCreateProjectile = false
	if ( IsServer() || self.ShouldPredictProjectiles() )
		shouldCreateProjectile = true
	if ( IsClient() && !playerFired )
		shouldCreateProjectile = false

	if ( shouldCreateProjectile )
	{
		local bolt = self.FireWeaponBolt( attackParams.pos, attackParams.dir, 10000, damageTypes.LargeCaliber | DF_SPECTRE_GIB, damageTypes.LargeCaliber | DF_SPECTRE_GIB | DF_EXPLOSION, playerFired )
		bolt.kv.bounceFrac = 0.00
		bolt.kv.gravity = 0.001

		if ( IsClient() )
		{
			StartParticleEffectOnEntity( bolt, GetParticleSystemIndex( "Rocket_Smoke_SMR_Glow" ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
		}
	}

	return 1
}

function OnWeaponBulletHit( hitParams )
{
	if ( IsClient() )
		return

	if( hitParams.hitEnt != level.worldspawn )
	{
		local passThroughInfo = GetBulletPassThroughTargets( self.GetWeaponOwner(), hitParams )
		PassThroughDamage( passThroughInfo.targetArray )
	}
}


function OnWeaponStartZoomIn()
{
	HandleWeaponSoundZoomIn( self, "Weapon_Rangemaster_Kraber.ADS_In" )
}

function OnWeaponStartZoomOut()
{
	HandleWeaponSoundZoomOut( self, "Weapon_Rangemaster_Kraber.ADS_Out" )
}
