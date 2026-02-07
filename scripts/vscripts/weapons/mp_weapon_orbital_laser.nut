
self.s.guidanceEffect <- null

RegisterSignal( "EndGuidance" )
RegisterSignal( "WeaponDeactivate" )

function OrbitalLaserPrecache()
{
	if ( WeaponIsPrecached( self ) )
		return

	PrecacheParticleSystem( "orbital_laser_target" )
}
OrbitalLaserPrecache()

function OnWeaponActivate( activateParams )
{
	local player = self.GetWeaponOwner()

	if ( IsClient() && IsLocalViewPlayer( player ) )
		thread UpdateGuidanceEffect()
}


function UpdateGuidanceEffect()
{
	Assert( IsClient() )

	EndSignal( this, "EndGuidance" )

	local player = self.GetWeaponOwner()
	local effectIndex = GetParticleSystemIndex( "orbital_laser_target" )
	local guidanceTrace = GuidanceTrace( player )

	self.s.guidanceEffect = StartParticleEffectInWorldWithHandle( effectIndex, guidanceTrace.endPos, guidanceTrace.surfaceNormal )


	OnThreadEnd(
		function () : ( player )
		{
			if ( IsClient() && IsLocalViewPlayer( player ) && EffectDoesExist( self.s.guidanceEffect ) )
				EffectStop( self.s.guidanceEffect, true, false )
		}
	)

	while ( EffectDoesExist( self.s.guidanceEffect ) )
	{
		guidanceTrace = GuidanceTrace( player )

		if ( self.IsWeaponCharging() )
			EffectSetControlPointVector( self.s.guidanceEffect, 1, Vector( 255, 0, 0 ) )
		else
			EffectSetControlPointVector( self.s.guidanceEffect, 1, Vector( 255, 255, 0 ) )

		EffectSetControlPointVector( self.s.guidanceEffect, 0, guidanceTrace.endPos )
		EffectSetControlPointAngles( self.s.guidanceEffect, 0, (VectorToAngles(guidanceTrace.surfaceNormal) + Vector( 90, 0, 0 )) )

		wait 0.016
	}
}


function GuidanceTrace( player )
{
	local traceStart = player.EyePosition()
	local traceEnd = traceStart + (player.GetViewVector() * 56756) // longest possible trace given our map size limits
	local ignoreEnts = [ player ]

	return TraceLine( traceStart, traceEnd, ignoreEnts, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )
}


function OnWeaponDeactivate( deactivateParams )
{
	local player = self.GetWeaponOwner()

	EndGuidance()

	if ( IsServer() && player )
	{
		player.Signal( "WeaponDeactivate" )
		player.Signal( "FreezeLaser" )
		player.Signal( "EndLaser" )
	}
}


function EndGuidance()
{
	Signal( this, "EndGuidance" )

	self.StopWeaponSound( "NPC_CScanner.FlyLoop" )
}


function OnWeaponChargeBegin( chargeParams )
{
	self.EmitWeaponSound( "NPC_CScanner.FlyLoop" )

	if ( IsServer() )
	{
		local player = self.GetWeaponOwner()
		Signal( player, "BeginLaser" )
		Signal( player, "MoveLaser" )
	}
}


function OnWeaponChargeEnd( chargeParams )
{
	self.StopWeaponSound( "NPC_CScanner.FlyLoop" )

	local player = self.GetWeaponOwner()

	Signal( player, "FreezeLaser" )
}


function OnWeaponPrimaryAttack( attackParams )
{
	return 0
}


function OnClientAnimEvent( name )
{
}
