
AMMO_BODYGROUP_COUNT <- 6

if ( IsServer() )
{
	ROCKET_IMPACT_FX_TABLE			<- PrecacheImpactEffectTable( "orbital_strike" )
}

function OnWeaponActivate( activateParams )
{
	UpdateViewmodelAmmo()
}

function OnWeaponDeactivate( deactivateParams )
{
}

function OnWeaponPrimaryAttack( attackParams )
{
	self.EmitWeaponSound( "Weapon_ARL.Single" )
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	local weaponOwner = self.GetWeaponOwner()
	local bulletVec = ApplyVectorSpread( attackParams.dir, weaponOwner.GetAttackSpreadAngle() - 1.0 )
	attackParams.dir = bulletVec

	if ( IsServer() || self.ShouldPredictProjectiles() )
	{
		local baseSpeed = 2800
		if ( self.HasMod("tank_buster" ) )
			baseSpeed *= 0.7
		local missile = self.FireWeaponMissile( attackParams.pos, attackParams.dir, baseSpeed, DF_GIB | DF_EXPLOSION, DF_GIB | DF_EXPLOSION, false, PROJECTILE_PREDICTED )
		if ( missile )
		{
			if ( IsServer() )
			{
				EmitSoundOnEntity( missile, "Weapon_ARL.Projectile" )
				if( self.HasMod("tank_buster" ) )
					missile.s.weaponRef <- self

				// projectiles are currently too fast for this to work
				//local results = TraceLine( attackParams.pos, attackParams.pos + (attackParams.dir * 4000) , weaponOwner,  (TRACE_MASK_SHOT | CONTENTS_BLOCKLOS), TRACE_COLLISION_GROUP_NONE )
				//SetMissileTarget( missile, results.hitEnt, weaponOwner )
			}

			missile.InitMissileForRandomDriftFromWeaponSettings( attackParams.pos, attackParams.dir )
			//InitMissileForRandomDrift( missile, attackParams.pos, attackParams.dir )
		}
	}
}


function SetMissileTarget( missile, target, weaponOwner )
{
	if ( !IsAlive( target ) )
		return

	if ( !target.IsPlayer() && !target.IsNPC() )
		return

	if ( target.GetTeam() == weaponOwner.GetTeam() )
		return

	//if ( !target.IsTitan() )
	//	return

	missile.SetTarget( target, Vector( 0, 0, 0 ) )
	missile.SetHomingSpeeds( 500, 0 )
}


function OnWeaponNpcPrimaryAttack( attackParams )
{
	self.EmitWeaponSound( "Weapon_ARL.Single" )
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	if ( IsServer() )
	{
		local missile = self.FireWeaponMissile( attackParams.pos, attackParams.dir, 2000, damageTypes.LargeCaliberExp, damageTypes.LargeCaliberExp, true, PROJECTILE_NOT_PREDICTED )
		if ( missile )
		{
			EmitSoundOnEntity( missile, "Weapon_ARL.Projectile" )
			missile.InitMissileForRandomDriftFromWeaponSettings( attackParams.pos, attackParams.dir )
			//InitMissileForRandomDrift( missile, attackParams.pos, attackParams.dir )
		}
	}
}


function OnClientAnimEvent( name )
{
	GlobalClientEventHandler( name )
}

function OnWeaponStartZoomIn()
{
	HandleWeaponSoundZoomIn( self, "Weapon_ARL.ADS_In" )
}

function OnWeaponStartZoomOut()
{
	HandleWeaponSoundZoomOut( self, "Weapon_ARL.ADS_Out" )
}
