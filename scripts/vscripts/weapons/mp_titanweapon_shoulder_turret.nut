RegisterSignal( "SetTurretEnemy" )
RegisterSignal( "TurretDisabled" )

function OnWeaponPrimaryAttack( attackParams )
{
	local ownerPlayer = self.GetWeaponOwner()
	Assert( IsValid( ownerPlayer) && ownerPlayer.IsPlayer() )
	Assert( ownerPlayer.IsTitan() )

	if ( IsServer() )
	{
		local duration = self.GetWeaponInfoFileKeyField( "fire_duration" )
		local coolDown = 1.0 / self.GetWeaponInfoFileKeyField( "fire_rate" )

		local duration = min( duration, coolDown - 5.0 )

		local soul = ownerPlayer.GetTitanSoul()
		Assert( soul )

		local turret = soul.shoulderTurret.model
		Assert( turret )

		thread ShoulderTurretThink( turret, ownerPlayer, duration )
		thread ShoulderTurretEnemyThink( turret, ownerPlayer )
		turret.SetEnemyChangeCallback( "OnTurretTargetChanged" )

	}
	else
	{
		thread ShoulderTurretTargetChangeThink( ownerPlayer )
	}

	return 1
}


function OnWeaponOffhandFirePressedNotReady( attackParams )
{
	if ( !IsServer() )
		return

	local owner = self.GetWeaponOwner()

	if ( !owner.IsPlayer() )
		return

	local ignoredEntities 		= [ owner, self ]
	local antilagPlayer 		= owner
	local traceMask 			= TRACE_MASK_SHOT
	local flags					= VIS_CONE_ENTS_TEST_HITBOXES | VIS_CONE_ENTS_IGNORE_VORTEX

	local results = GetVisibleEntitiesInCone( owner.EyePosition(), owner.GetViewVector(), 4000, 10.0, ignoredEntities, traceMask, flags, antilagPlayer, false, false )

	local bestTarget = null
	local bestDot = -1

	local viewVector = owner.GetViewVector()

	PrintTable( results )

	foreach ( data in results )
	{
		if ( !IsValidShoulderTurretTarget( owner, data.entity ) )
		{
			printt( "invalid target", data.entity )
			continue
		}

		local vecToTarget = data.entity.GetWorldSpaceCenter() - owner.EyePosition()
		vecToTarget.Normalize()
		local dot = viewVector.Dot( vecToTarget )

		if ( !bestTarget || dot > bestDot )
		{
			bestTarget = data.entity
			bestDot = dot
		}
	}

	if ( bestTarget )
		owner.Signal( "SetTurretEnemy", { entity = bestTarget } )
}


function IsValidShoulderTurretTarget( player, entity )
{
	if ( !entity )
		return false

	if ( !entity.IsPlayer() && !entity.IsNPC() )
		return false

	if ( entity.GetTeam() == player.GetTeam() )
		return false

	return true
}


function ShoulderTurretThink( turret, ownerPlayer, duration )
{
	turret.EndSignal( "OnDeath" )

	turret.EnableTurret()
	EmitSoundOnEntity( ownerPlayer, "MegaTurret_Extend_Guns" )

	wait duration

	EmitSoundOnEntity( ownerPlayer, "MegaTurret_Retract_Guns" )

	turret.DisableTurret()
	turret.Signal( "TurretDisabled" )
}


function ShoulderTurretEnemyThink( turret, ownerPlayer )
{
	turret.EndSignal( "TurretDisabled" )
	turret.EndSignal( "OnDeath" )

	while ( true )
	{
		local results = WaitSignal( ownerPlayer, "SetTurretEnemy" )

		if ( !IsValid( results.entity ) )
			continue

		if ( results.entity == turret.GetEnemy() )
			return

		turret.FireNow( "ForgetEntity", "!activator", turret.GetEnemy() )
		turret.SetEnemy( results.entity )
		turret.SetEnemyLKP( results.entity, results.entity.GetOrigin() )
		//turret.FireNow( "UpdateEnemyMemory", "!activator", results.entity )
	}
}


function ShoulderTurretTargetChangeThink( ownerPlayer )
{
	while ( true )
	{
		local results = WaitSignal( ownerPlayer, "OnTurretTargetChanged" )

		local target = results.target

		if ( target )
		{
			waitthread UpdateShoulderTurretTargetUI( ownerPlayer, target )
		}
		else
		{
			ownerPlayer.hudElems.TitanShoulderTurretMissileLockReticle.Hide()
		}
	}
}


function UpdateShoulderTurretTargetUI( ownerPlayer, target )
{
	target.EndSignal( "OnDeath" )
	ownerPlayer.EndSignal( "OnTurretTargetChanged" )

	EmitSoundOnEntity( ownerPlayer, "Weapon_SmartAmmo.TargetLocked" )

	local wsc = target.GetWorldSpaceCenter()
	local origin = target.GetOrigin()
	local zOffset = wsc.z - origin.z
	local elemHeight = ownerPlayer.hudElems.TitanShoulderTurretMissileLockReticle.GetBaseHeight().tofloat()

	OnThreadEnd(
		function() : ( ownerPlayer, target )
		{
			if ( !IsAlive( target ) )
				ownerPlayer.hudElems.TitanShoulderTurretMissileLockReticle.Hide()
		}
	)

	ownerPlayer.hudElems.TitanShoulderTurretMissileLockReticle.SetEntity( target, Vector( 0, 0, zOffset ), 0.5, 0.5 )
	ownerPlayer.hudElems.TitanShoulderTurretMissileLockReticle.Show()

	ownerPlayer.hudElems.TitanShoulderTurretMissileLockReticle.SetScale( 3.0, 3.0 )

	local screenHeight = GetEntityScreenHeight( ownerPlayer, target, 1000 )
	local scale = screenHeight / elemHeight

	ownerPlayer.hudElems.TitanShoulderTurretMissileLockReticle.ScaleOverTime( scale, scale, 0.25, INTERPOLATOR_DEACCEL )

	wait 0.25

	while ( true )
	{
		local screenHeight = GetEntityScreenHeight( ownerPlayer, target )
		local scale = screenHeight / elemHeight

		ownerPlayer.hudElems.TitanShoulderTurretMissileLockReticle.SetScale( scale, scale )

		local traceID = DeferredTraceLine( ownerPlayer.EyePosition(), target.GetWorldSpaceCenter(), ownerPlayer, TRACE_MASK_SOLID_BRUSHONLY | TRACE_MASK_WATER, TRACE_COLLISION_GROUP_NONE )
		wait 0
		if ( !IsDeferredTraceValid( traceID ) )
			continue

		local result = GetDeferredTraceResult( traceID )

		if ( result.fraction >= 0.99 )
			ownerPlayer.hudElems.TitanShoulderTurretMissileLockReticle.Show()
		else
			ownerPlayer.hudElems.TitanShoulderTurretMissileLockReticle.Hide()
	}
}
