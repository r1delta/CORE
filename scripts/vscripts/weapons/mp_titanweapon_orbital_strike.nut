const BEACON_IDLE_SFX = "OrbitalStrike_Emitter_Idle"
const BEACON_ACTIVATE_SFX = "OrbitalStrike_Emitter_Active"


RegisterSignal( "OrbitalStrikeSlam" )

function OrbitalStrikePrecache()
{
	if ( WeaponIsPrecached( self ) )
		return

	if ( IsServer() )
	{
		PrecacheEntity( "npc_grenade_frag" )
	}
}
OrbitalStrikePrecache()

function OnWeaponPrimaryAttack( attackParams )
{
	if ( IsClient() && !self.ShouldPredictProjectiles() )
		return

	local weaponOwner = self.GetWeaponOwner()
	local attackAngles = attackParams.dir.GetAngles()
	attackAngles.x -= 5
	local forward = attackAngles.AnglesToForward()
	local velocity = (forward) * 1200
	local angularVelocity = Vector( 3600, RandomFloat( -1200, 1200 ), 0 )

	local strikeMarker = self.FireWeaponGrenade( attackParams.pos, velocity, angularVelocity, 20.0, damageTypes.Explosive, damageTypes.Explosive, PROJECTILE_PREDICTED, true, true )

	if ( strikeMarker )
	{
		strikeMarker.s.planted <- false

		if ( IsServer() )
		{
			EmitSoundOnEntity( strikeMarker, BEACON_IDLE_SFX )
			thread StrikeMarkerThink( weaponOwner, strikeMarker )
		}
	}
}


function StrikeMarkerThink( weaponOwner, strikeMarker )
{
	strikeMarker.EndSignal( "OnDestroy" )
	strikeMarker.EndSignal( "Planted" )

	weaponOwner.WaitSignal( "OrbitalStrikeSlam" )

	strikeMarker.SetVelocity( Vector( 0, 0, -600 ) )
}


function OnWeaponOffhandFirePressedNotReady( attackParams )
{
	local weaponOwner = self.GetWeaponOwner()

	weaponOwner.Signal( "OrbitalStrikeSlam" )
}


function OnProjectileCollision( collisionParams )
{
	local bounceDot = 1.0  // sets the dot of the normals it'll stick to
	local result = PlantStickyEntity( self, collisionParams, bounceDot )
	local duration = 10.0
	local startDelay = 2.0
	local addedflightDuration = 1.0

	if ( IsServer() && result )
	{
		EmitSoundOnEntity( self, "Weapon_R1_Satchel.Attach" )

		local player = self.GetOwner()

		if ( !IsValid( player ) )
		{
			self.Kill()
			return
		}

		thread PlayActivationSound( self, startDelay )
		thread OrbitalStrike( player, self, 50, 300, duration, startDelay )
		self.Fire( "Kill", "", duration + startDelay + addedflightDuration )
	}
}

function PlayActivationSound( beacon, startDelay )
{
	beacon.EndSignal( "OnDestroy" )

	wait startDelay

	EmitSoundOnEntity( beacon, BEACON_ACTIVATE_SFX )
}