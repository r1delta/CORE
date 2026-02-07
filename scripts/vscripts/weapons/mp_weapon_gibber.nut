
//self.SetWeaponSkin( 1 )		// sets the RSPN-101 color to red, remove when using different model

ACCURACY_MIN 			<- 20.0		// accuracy spread in degrees when not in ADS
ACCURACY_MAX 			<- 1.0		// accuracy spread in degrees when in ADS for max time limit
ACCURACY_SCALE_TIME 	<- 1.5		// time it takes to go from min accuracy to max accuracy while in ADS
accuracyNow 			<- ACCURACY_MIN
timeInADS 				<- 0
adsStartTime 			<- 0
crosshairGibberPistol	<- null

RegisterSignal( "GibberPistolThinkEnd" )
RegisterSignal( "HitSky" )

AMMO_BODYGROUP_COUNT <- 6

function GibberPrecache()
{
	if ( WeaponIsPrecached( self ) )
		return

	PrecacheParticleSystem( "wpn_muzzleflash_smg_FP" )
	PrecacheParticleSystem( "wpn_muzzleflash_smg" )
	PrecacheParticleSystem( "wpn_shelleject_pistol_FP" )
	PrecacheParticleSystem( "wpn_shelleject_pistol" )

	if ( IsServer() )
	{
		PrecacheEntity( "crossbow_bolt" )
	}
}
GibberPrecache()

function OnWeaponActivate( activateParams )
{
	UpdateViewmodelAmmo()
	ShowReticle()
}

function OnWeaponDeactivate( deactivateParams )
{
	HideReticle()
}

function ShowReticle()
{
	local player = self.GetWeaponOwner()
	if ( !IsValid_ThisFrame( player ) )
		return

	if ( IsClient() )
	{
		if ( !IsLocalViewPlayer( player ) )
			return

		if ( crosshairGibberPistol == null )
			crosshairGibberPistol = HudElement( "Crosshair_GibberPistol" )

		crosshairGibberPistol.ReturnToBasePos()
		crosshairGibberPistol.ReturnToBaseSize()
		crosshairGibberPistol.Show()
	}

	thread GibberPistolThink()
}

function HideReticle()
{
	if ( IsClient() )
	{
		if ( crosshairGibberPistol != null )
		{
			crosshairGibberPistol.ReturnToBasePos()
			crosshairGibberPistol.ReturnToBaseSize()
			crosshairGibberPistol.Hide()
		}

		Signal( self, "GibberPistolThinkEnd" )
	}

	if ( IsServer() )
		self.Signal( "GibberPistolThinkEnd" )
}

function GibberPistolThink()
{
	local player = self.GetWeaponOwner()

	if ( !IsValid_ThisFrame( player ) )
		return

	ReduceAccuracyTimer( 0.5 )

	if ( IsClient() )
	{
		if ( !IsLocalViewPlayer( player ) )
			return

		EndSignal( self, "GibberPistolThinkEnd" )
		EndSignal( player, "OnDeath" )
	}

	if ( IsServer() )
	{
		self.EndSignal( "GibberPistolThinkEnd" )
		player.EndSignal( "OnDeath" )
		player.EndSignal( "Disconnected" )
	}

	local reticleScale
	local offsetX
	local offsetY
	local basePos
	local baseSize

	if ( IsClient() )
	{
		basePos = crosshairGibberPistol.GetBasePos()
		baseSize = crosshairGibberPistol.GetBaseSize()
	}

	while( IsValid_ThisFrame( self ) )
	{
		if ( !self.IsWeaponInAds() )
			adsStartTime = Time()
		timeInADS = Time() - adsStartTime

		accuracyNow = GetValueFromFraction( timeInADS, 0.0, ACCURACY_SCALE_TIME, ACCURACY_MIN, ACCURACY_MAX )
		reticleScale = GetValueFromFraction( timeInADS, 0.0, ACCURACY_SCALE_TIME, 1.0, 0.2 )

		if ( IsClient() )
		{
			offsetX = ( baseSize[0] - ( baseSize[0] * reticleScale ) ) / 2.0
			offsetY = ( baseSize[1] - ( baseSize[1] * reticleScale ) ) / 2.0
			crosshairGibberPistol.SetScale( reticleScale, reticleScale )
			crosshairGibberPistol.SetX( basePos[0] + offsetX )
			crosshairGibberPistol.SetY( basePos[1] + offsetY )
		}

		Wait(0)
	}
}

function ResetAccuracyTimer()
{
	adsStartTime = Time()
	timeInADS = 0
}

function ReduceAccuracyTimer( Reduction )
{
	timeInADS = clamp( timeInADS, 0, ACCURACY_SCALE_TIME)
	timeInADS = timeInADS - Reduction
	timeInADS = max( timeInADS, 0 )
	adsStartTime = Time() - timeInADS
}

function OnClientAnimEvent( name )
{
	GlobalClientEventHandler( name )

	if ( name == "muzzle_flash" )
		self.PlayWeaponEffect( "wpn_muzzleflash_smg_FP", "wpn_muzzleflash_smg", "muzzle_flash" )

	//if ( name == "shell_eject" )
	//	self.PlayWeaponEffect( "wpn_shelleject_pistol_FP", "wpn_shelleject_pistol", "shell" )
}

function OnWeaponPrimaryAttack( attackParams )
{
	local rand = RandomInt( 0, 10000 )
	local player = self.GetWeaponOwner()

	self.EmitWeaponSound( "Weapon_r1357.Single" )
	self.EmitWeaponSound( "Weapon_bulletCasing.Single" )
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	local bulletVec = ApplyVectorSpread( attackParams.dir, accuracyNow )

	if ( IsServer() || self.ShouldPredictProjectiles() )
	{
		FireProjectile( self, player, attackParams.pos, bulletVec )
	}

	ReduceAccuracyTimer( 0.4 )
}

function OnWeaponNpcPrimaryAttack( attackParams )
{
	self.EmitWeaponSound( "Weapon_Pistol.NPC_Single" )
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	if ( IsServer() )
	{
		FireProjectile( self, self.GetWeaponOwner(), attackParams.pos, attackParams.dir )
	}
}

function FireProjectile( weapon, player, startPos, direction )
{
	local bolt = self.FireWeaponBolt( startPos, direction, 2500, damageTypes.Explosive, damageTypes.Explosive, PROJECTILE_PREDICTED )
	bolt.kv.bounceFrac = 0.0
	bolt.kv.gravity = 1.1

	/*
	if ( IsServer() )
		thread BoltHitThink( bolt, player )
	*/
}

function BoltHitThink( bolt, player )
{
	thread OnBoltHit( bolt, player )

	bolt.WaitSignal( "OnDestroy" )
	bolt.Signal( "HitSky" ) // work around the fact that "OnDestroy" happens before "OnWeaponBoltHit"
}

function OnBoltHit( bolt, player )
{
	bolt.EndSignal( "HitSky" )

	local team = player.GetTeam()

	bolt.WaitSignal( "OnWeaponBoltHit" )
	//---------------------
	// Explosion on impact
	//---------------------

	local env_explosion = CreateEntity( "env_explosion" )
	env_explosion.kv.iMagnitude = 165
	env_explosion.kv.iRadiusOverride = 150
	env_explosion.kv.iInnerRadius = 75
	env_explosion.kv.fireballsprite = "sprites/zerogxplode.spr"
	env_explosion.kv.rendermode = 5   //additive
	env_explosion.kv.scriptDamageType = damageTypes.Ragdoll
	env_explosion.kv.damageSourceId = eDamageSourceId.mp_weapon_gibber
	env_explosion.SetName( UniqueString() )
	env_explosion.SetOrigin( bolt.GetOrigin() )
	env_explosion.SetTeam( team )
	env_explosion.SetOwner( player )
	DispatchSpawn( env_explosion, false )

	env_explosion.Fire( "Explode" )

	env_explosion.Kill( 1.5 )
	bolt.Kill()
}