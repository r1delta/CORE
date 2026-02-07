
const LAUNCH_VELOCITY 	= 1800
const FUSE_TIME 		= 2.5
const MGL_MAGNETIC_FORCE	= 1600
const MAX_BONUS_VELOCITY = 1250

RegisterSignal( "GibberPistolThinkEnd" )
RegisterSignal( "HitSky" )
RegisterSignal( "GrenadeStick" )

function MGLPrecache()
{
	if ( WeaponIsPrecached( self ) )
		return

	if ( IsServer() )
	{
		PrecacheEntity( "npc_grenade_frag" )
		PrecacheEntity( "crossbow_bolt" )
	}
}
MGLPrecache()

function OnWeaponActivate( activateParams )
{
	AMMO_BODYGROUP_COUNT <- min( self.GetWeaponModSetting( "ammo_clip_size" ), 6 )
	UpdateViewmodelAmmo()
}

function OnWeaponDeactivate( deactivateParams )
{
}

function OnClientAnimEvent( name )
{
	GlobalClientEventHandler( name )
}

function OnWeaponPrimaryAttack( attackParams )
{
	local rand = RandomInt( 0, 10000 )
	local player = self.GetWeaponOwner()

	self.EmitWeaponSound( "Weapon_MGL.Single" )
	self.EmitWeaponSound( "Weapon_bulletCasing.Single" )
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	//local bulletVec = ApplyVectorSpread( attackParams.dir, player.GetAttackSpreadAngle() * 2.0 )
	//attackParams.dir = bulletVec

	if ( IsServer() || self.ShouldPredictProjectiles() )
	{
		local offset = Vector( 30.0, 6.0, -4.0 )
		if ( self.IsWeaponInAds() )
			offset = Vector( 30.0, 0.0, -3.0 )
		local attackPos = player.OffsetPositionFromView( attackParams[ "pos" ], offset )	// forward, right, up
		FireGrenade( attackParams )
	}
}

function OnWeaponNpcPrimaryAttack( attackParams )
{
	self.EmitWeaponSound( "Weapon_MGL.Single" )
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	if ( IsServer() )
		FireGrenade( attackParams, true )
}

function FireGrenade( attackParams, isNPCFiring = false )
{
	local attackAngles = attackParams.dir.GetAngles()
	attackAngles.x -= 2
	attackParams.dir = (attackAngles + Vector( RandomFloat( -1, 1 ), 0, 0 )).AnglesToForward()
	local velocity = LAUNCH_VELOCITY
	local attackVec = attackParams.dir * ( velocity )
	local angularVelocity = Vector( RandomFloat( -1200, 1200 ), 100, 0 )
	local fuseTime = FUSE_TIME
	if ( self.HasMod( "long_fuse" ) )
		fuseTime *= 2.0
	local nade = self.FireWeaponGrenade( attackParams.pos, attackVec, angularVelocity, fuseTime, damageTypes.Explosive, damageTypes.Explosive, !isNPCFiring, true, false )

	if ( nade )
	{
		if( IsServer() )
		{
			EmitSoundOnEntity( nade, "Weapon_R1_MGL_Grenade_Emitter" )
			Grenade_Init( nade, self )
		}
		else
		{
			//InitMagnetic needs to be after the team is set on both client and server.
			local weaponOwner = self.GetWeaponOwner()
			nade.SetTeam( weaponOwner.GetTeam() )
		}
		nade.InitMagnetic( MGL_MAGNETIC_FORCE, "Explo_MGL_MagneticAttract" )

		//thread MagneticFlight( nade, MGL_MAGNETIC_FORCE )
	}
}

function OnWeaponStartZoomIn()
{
	HandleWeaponSoundZoomIn( self, "Weapon_R1_MGL_ADS_In" )
}


function OnWeaponStartZoomOut()
{
	HandleWeaponSoundZoomOut( self, "Weapon_R1_MGL_ADS_Out" )
}