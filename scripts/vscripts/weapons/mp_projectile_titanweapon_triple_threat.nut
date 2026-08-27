function OnProjectileCollision( collisionParams )
{
	local hitEnt = collisionParams.hitent
	if( !IsValid( hitEnt ) )
		return

	if( "impactFuse" in self.s && self.s.impactFuse == true )
		self.Explode( Vector( 0,0,0 ) )

	if( hitEnt.GetClassname() == "player" && !hitEnt.IsTitan() )
		return

	if( !IsValid( self ) )
		return

	if( IsMagneticTarget( hitEnt ) )
	{
		local shouldDetonate = hitEnt.GetTeam() != self.GetTeam()
		if ( IsServer() && IsFFABased() )
			shouldDetonate = !ShouldPreventFriendlyFire( hitEnt, self )

		if( shouldDetonate )
		{
			local normal = Vector( 0, 0, 1 )
			if( "collisionNormal" in self.s )
				normal = self.s.collisionNormal
			self.Explode( normal )
		}
	}
	else if( "becomeProxMine" in self.s && self.s.becomeProxMine == true )
	{
		local bounceDot = 1.0
		if( !("collisionNormal" in self.s ) )
		{
			PlantStickyEntity( self, collisionParams, bounceDot )
			self.s.collisionNormal <- collisionParams.normal
			if ( IsServer() )
				thread TripleThreatProximityTrigger( self )
		}
	}
	else if( "rollingRound" in self.s && self.s.rollingRound == true )
	{
		self.SetVelocity( self.GetVelocity() * 1.5 )
	}
}

function TripleThreatProximityTrigger( nade )
{
	//Hack, shouldn't be necessary with the IsValid check in OnProjectileCollision.
	if( !IsValid( nade ) )
		return

	nade.EndSignal( "OnDestroy" )
	EmitSoundOnEntity( nade, "Wpn_TripleThreat_Grenade_MineAttach" )

	wait MINE_FIELD_ACTIVATION_TIME

	EmitSoundOnEntity( nade, "Weapon_Vortex_Gun.ExplosiveWarningBeep" )
	local rangeCheck = PROX_MINE_RANGE
	local isFFA = IsFFABased()
	local rangeCheckSqr = rangeCheck * rangeCheck
	local hasTriggeredSound = 0
	while( 1 )
	{
		local origin = nade.GetOrigin()
		local team = nade.GetTeam()

		if( nade.s.planted == true )
		{
			local entityArray
			if ( isFFA )
				entityArray = GetScriptManagedEntArray( level._proximityTargetArrayID )
			else
				entityArray = GetScriptManagedEntArrayWithinCenter( level._proximityTargetArrayID, team, origin, rangeCheck )
			foreach( ent in entityArray )
			{
				if ( !IsValid( ent ) )
					continue

				if ( isFFA )
				{
					if ( ShouldPreventFriendlyFire( nade, ent ) )
						continue

					if ( DistanceSqr( ent.GetWorldSpaceCenter(), origin ) > rangeCheckSqr )
						continue
				}

				if ( MINE_FIELD_TITAN_ONLY )
					if ( !ent.IsTitan() )
						continue

				if ( IsAlive( ent ) )
				{
					nade.Signal( "ProxMineTrigger" )
					return
				}
			}
		}
		wait 0
	}
}