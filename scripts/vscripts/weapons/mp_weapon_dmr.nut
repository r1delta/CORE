
AMMO_BODYGROUP_COUNT <- self.GetWeaponInfoFileKeyField( "ammo_clip_size" )

function DMRPrecache()
{
	if ( WeaponIsPrecached( self ) )
		return

	PrecacheParticleSystem( "wpn_mflash_snp_hmn_smoke_side_FP" )
	PrecacheParticleSystem( "wpn_mflash_snp_hmn_smoke_side" )
	PrecacheParticleSystem( "Rocket_Smoke_SMR_Glow" )
}
DMRPrecache()

function OnWeaponActivate( activateParams )
{
	if ( !( "zoomTimeIn" in self.s ) )
		self.s.zoomTimeIn <- self.GetWeaponModSetting( "zoom_time_in" )

	if ( !IsClient() )
		return

	if ( self.GetWeaponOwner() != GetLocalViewPlayer() )
		return

	//if ( self.HasMod( "sniper_assist" ) )
	CreateSniperVGUI( GetLocalViewPlayer(), self )
}

function OnWeaponOwnerChanged( changeParams )
{
	if ( !IsClient() )
		return

	if ( changeParams.oldOwner == GetLocalViewPlayer() && changeParams.newOwner != GetLocalViewPlayer() )
		DestroySniperVGUI( self )
}

function OnWeaponDeactivate( deactivateParams )
{
	if ( !IsClient() )
		return

	DestroySniperVGUI( self )
	if( self.HasMod( "burn_mod_dmr" ) )
		ForceDeactivateSonar( self, FORCE_SONAR_DEACTIVATE )
}

function OnWeaponReload( reloadParams )
{
}

function OnClientAnimEvent( name )
{
	GlobalClientEventHandler( name )

	if ( name == "muzzle_flash" )
	{
		if( !self.HasMod("silencer") )
		{
			self.PlayWeaponEffect( "wpn_mflash_snp_hmn_smoke_side_FP", "wpn_mflash_snp_hmn_smoke_side", "muzzle_flash_L" )
			self.PlayWeaponEffect( "wpn_mflash_snp_hmn_smoke_side_FP", "wpn_mflash_snp_hmn_smoke_side", "muzzle_flash_R" )
		}
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
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	return FireWeaponPlayerAndNPC( attackParams, true )
}

function OnWeaponNpcPrimaryAttack( attackParams )
{
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	return FireWeaponPlayerAndNPC( attackParams, false )
}

function FireWeaponPlayerAndNPC( attackParams, playerFired )
{
	/*
	local owner = self.GetWeaponOwner()
	local shouldCreateProjectile = false
	if ( IsServer() || self.ShouldPredictProjectiles() )
		shouldCreateProjectile = true
	if ( IsClient() && !playerFired )
		shouldCreateProjectile = false

	if ( shouldCreateProjectile )
	{
	local bolt = self.FireWeaponBolt( attackParams.pos, attackParams.dir, 15000, damageTypes.LargeCaliber | DF_SPECTRE_GIB, damageTypes.LargeCaliber | DF_SPECTRE_GIB, playerFired )
		bolt.kv.bounceFrac = 0.00
		bolt.kv.gravity = 0.001

		if ( IsClient() )
		{
			StartParticleEffectOnEntity( bolt, GetParticleSystemIndex( "Rocket_Smoke_SMR_Glow" ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
		}
	}
	*/

	self.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, damageTypes.LargeCaliber )
	return 1
}

/* Shouldn't have this unless we can do it for both sniper rifles.
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
*/

function OnWeaponStartZoomIn()
{
	HandleWeaponSoundZoomIn( self, "Weapon_Rangemaster_Kraber.ADS_In" )
	if( self.HasMod( "burn_mod_dmr" ) )
		thread ActiveWeaponSonar( self, 100000, self.s.zoomTimeIn )
}

function OnWeaponStartZoomOut()
{
	HandleWeaponSoundZoomOut( self, "Weapon_Rangemaster_Kraber.ADS_Out" )
	if( self.HasMod( "burn_mod_dmr" ) )
		ForceDeactivateSonar( self, FORCE_SONAR_DEACTIVATE )
}