
// RegisterSignal( "EndSniperAssist" )

AMMO_BODYGROUP_COUNT <- self.GetWeaponInfoFileKeyField( "ammo_clip_size" )

function SniperPrecache()
{
	if ( WeaponIsPrecached( self ) )
		return

	PrecacheParticleSystem( "wpn_mflash_snp_hmn_smoke_side_FP" )
	PrecacheParticleSystem( "wpn_mflash_snp_hmn_smoke_side" )
	PrecacheParticleSystem( "Rocket_Smoke_SMR_Glow" )

/*	if ( IsServer() )
	{
		PrecacheEntity( "crossbow_bolt" )
	}*/
}
SniperPrecache()

/*function OnWeaponActivate( activateParams )
{
	UpdateViewmodelAmmo()

	if ( self.HasMod( "sniper_assist" ) )
		SmartAmmo_Start( self )

	if ( IsClient() )
		CreateSniperVGUI( GetLocalViewPlayer(), self, true )
}*/

// codejun DMR 스크립트 복사, 조준 타겟의 피격 위치 가져오기, 반샷이 나는 경우가 있기 때문에 추가.
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
	SmartAmmo_Stop( self )
}

function OnWeaponReload( reloadParams )
{
}

function OnClientAnimEvent( name )
{
	GlobalClientEventHandler( name )

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
	// by codejun NPC 노출되는 사운드 범위 설정 ?
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	// by codejun Fire Event, 주석 처리하면 피격 안된다.
	return FireWeaponPlayerAndNPC( attackParams, true )	
}

function OnWeaponNpcPrimaryAttack( attackParams )
{
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	return FireWeaponPlayerAndNPC( attackParams, false )
}


function FireWeaponPlayerAndNPC( attackParams, playerFired ) //기존의 프로젝타일 방식
{
	//self.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, damageTypes.LargeCaliber )

/*	local owner = self.GetWeaponOwner()
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
	}*/

	// by codejun 직사 테스트
	self.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, damageTypes.LargeCaliber )
	return 1
}

/*function FireWeaponPlayerAndNPC( attackParams, playerFired ) // 일반 사격 방식
{
	self.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, damageTypes.LargeCaliber )
	return 1
}*/

// by codejun DMR에는 없는 항목이라서 주석 처리 해봄
/*function OnWeaponBulletHit( hitParams )
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
	HandleWeaponSoundZoomIn( self, "SR_Valkyrie.ADS_In" )
}

function OnWeaponStartZoomOut()
{
	HandleWeaponSoundZoomOut( self, "SR_Valkyrie.ADS_Out" )
}
