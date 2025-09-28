PrecacheParticleSystem( "P_sonar" )

function main()
{
	PrecacheModel( "models/humans/pete/mri_male.mdl" )
	PrecacheModel( "models/humans/pilot/female_cq/mri_female.mdl" )
	Globalize( ActivateBurnCardSonar )
	Globalize( ActivateSonar )
	Globalize( ActiveWeaponSonar )
	Globalize( ForceDeactivateSonar )
	RegisterSignal( FORCE_SONAR_DEACTIVATE )

	if ( IsClient() )
	{
		AddCinematicEventFlagChangedCallback( CE_FLAG_SONAR_ACTIVE, SonarActiveChanged )
		AddCinematicEventFlagChangedCallback( CE_FLAG_SONAR_PING, SonarPingChanged )
	}

}

//Not splitting this into sonar and cl_sonar yet until we have more reason to
if ( IsServer() )
{
	function LoopSonarAudioPing( player, setCEFlag = false )
	{
		player.EndSignal( "OnDeath" )
		player.EndSignal( "Disconnected" )

		local otherTeam = GetOtherTeam( player.GetTeam() )

		if ( setCEFlag )
		{
			AddCinematicFlag( player, CE_FLAG_SONAR_ACTIVE )

			OnThreadEnd(
				function() : ( player )
				{
					if ( !IsValid( player ) )
						return

					RemoveCinematicFlag( player, CE_FLAG_SONAR_ACTIVE )
				}
			)
		}

		if ( !( "sonarEndTime" in player.s ) )
			player.s.sonarEndTime <- null

		while ( true )
		{
			//Potentially have different 1P/3P sounds for sonar pulse
			//EmitDifferentSoundsOnEntityForPlayerAndWorld( "radarpulse_ping", "radarpulse_ping", player, player )
			EmitSoundOnEntityToTeam( player, "radarpulse_ping", otherTeam  )

			local table = GetSonarDurationAndInterval( player )
			player.s.sonarEndTime = Time() + table.duration

			wait table.interval
		}
	}
	Globalize( LoopSonarAudioPing )

	function SonarColorCorrection( player, duration, uniqueEndSignal = null, colorCorrectionOverride = null )
	{
		player.EndSignal( "OnDestroy" )
		player.EndSignal( "OnDeath" )
		player.EndSignal( "Disconnected" )
		//player.EndSignal( "OnChangedPlayerClass" )

		if ( uniqueEndSignal )
			player.EndSignal( uniqueEndSignal )

		local colorCorrection
		if ( colorCorrectionOverride )
			colorCorrection = GetColorCorrectionByFileName( player, colorCorrectionOverride )
		else
			colorCorrection	= GetColorCorrectionByFileName( player, "materials/correction/mp_ability_sonar.raw" )

		if ( !colorCorrection )
			return null

		OnThreadEnd(
			function() : ( colorCorrection )
			{
				colorCorrection.Fire( "Disable" )
			}
		)

		local fadeInDuration = 0.5
		local fadeOutDuration = 1
		if ( uniqueEndSignal )
			fadeOutDuration = 0
		local colorTime = duration
		local maxweight = 2
		local isMaster = 1

		colorCorrection.kv.fadeInDuration = fadeInDuration
		colorCorrection.kv.fadeOutDuration = fadeOutDuration
		colorCorrection.kv.maxweight = maxweight
		colorCorrection.kv.spawnflags = isMaster

		colorCorrection.Fire( "Enable" )
		colorCorrection.Fire( "Disable", "", colorTime + fadeInDuration )

		wait ( colorTime + fadeInDuration )
	}
	Globalize ( SonarColorCorrection )

}

function GetSonarDurationAndInterval( player )
{
	local cardRef = GetPlayerActiveBurnCard( player )
	if ( cardRef != null )
	{
		switch ( cardRef )
		{
			case "bc_auto_sonar":
				return { interval = BURNCARD_AUTO_SONAR_INTERVAL, duration = BURNCARD_AUTO_SONAR_IMAGE_DURATION }

			case "bc_sonar_forever":
				return { interval = SONAR_PULSE_DELAY, duration = SONAR_PULSE_DURATION }
		}
	}

	return { interval = SONAR_PULSE_DELAY, duration = SONAR_PULSE_DURATION }
}

if ( IsClient() )
{
	function SonarPulse( player, maxDistance, pulseSpeed )
	{
		local wasDMRSonar = IsDMRSonar( player )
		local maxDistance = wasDMRSonar ? SONAR_PULSE_RANGE_MAX_DMR : SONAR_PULSE_RANGE_MAX

		local playerEyeOrigin = player.EyePosition()

		local mriEnts = GetPlayerArrayEx( "any", -1, playerEyeOrigin, maxDistance )
		mriEnts.extend( GetNPCArrayEx( "npc_titan", -1, playerEyeOrigin, maxDistance ) )
		mriEnts.extend( GetNPCArrayEx( "npc_soldier", -1, playerEyeOrigin, maxDistance ) )
		mriEnts.extend( GetNPCArrayEx( "npc_spectre", -1, playerEyeOrigin, maxDistance ) )

		EmitSoundOnEntity( player, "radarpulse_ping" )

		local table = GetSonarDurationAndInterval( player )
		local sonarImageDuration = table.duration
		foreach ( ent in mriEnts )
		{
			if ( ent == GetLocalViewPlayer() )
				continue

			if ( !IsAlive( ent ) )
				continue

			if ( IsCloaked( ent ) )
				continue

			local dist = Distance( playerEyeOrigin, ent.GetWorldSpaceCenter() )
			local startDelay = dist / pulseSpeed
			thread SonarShowEntityToPlayer( ent, player, dist, startDelay, sonarImageDuration, wasDMRSonar )
		}
	}
	Globalize( SonarPulse )


	function SonarShowEntityToPlayer( entity, player, distance, startDelay, sonarImageDuration, wasDMRSonar )
	{
		entity.EndSignal( "OnDeath" )
		entity.EndSignal( "OnDestroy" )
		player.EndSignal( "OnDestroy" )

		wait startDelay

		if ( wasDMRSonar && !IsDMRSonar( player ) )
		{
			player.Signal( FORCE_SONAR_DEACTIVATE )
			return
		}

		local cloneEnt
		local modelName = entity.GetModelName()

		local skin = 0
		// TODO: cache these results globally based on model name
		if ( entity.IsHumanSized() && !entity.IsSpectre() ) // won't look right for spectres
		{
			if ( modelName.find( "female" ) == null )
				modelName = "models/humans/pete/mri_male.mdl"
			else
				modelName = "models/humans/pilot/female_cq/mri_female.mdl"
		}
		else
		{
			local entKVs = entity.CreateTableFromModelKeyValues()

			if ( "sonar_skin" in entKVs )
				skin = entKVs.sonar_skin.tointeger()
		}

		local maxDistance = wasDMRSonar ? SONAR_PULSE_RANGE_MAX_DMR : SONAR_PULSE_RANGE_MAX

		cloneEnt = CreateClientSidePropDynamicClone( entity, modelName )
		if ( !cloneEnt ) // probably one of those damned hero characters...
			return
		cloneEnt.SetSkin( skin )
		cloneEnt.s.createTime <- Time()
		cloneEnt.s.pulseDuration <- sonarImageDuration
		cloneEnt.s.maxFrac <- distance / maxDistance
		cloneEnt.EnableRenderAlways()

		if ( wasDMRSonar)
			thread DestroyAfterDelay( cloneEnt, sonarImageDuration, player, FORCE_SONAR_DEACTIVATE )
		else
			thread DestroyAfterDelay( cloneEnt, sonarImageDuration, player )
	}


	function IsDMRSonar( player )
	{
		local activeWeapon = player.GetActiveWeapon()

		if ( !activeWeapon )
			return false

		if ( !activeWeapon.HasModDefined( "burn_mod_dmr" ) || !activeWeapon.HasMod( "burn_mod_dmr" ) )
			return false

		if ( !activeWeapon.IsWeaponInAds() )
			return false

		return true
	}


	function DestroyAfterDelay( entity, delay, player, uniqueEndSignal = null )
	{
		entity.EndSignal( "OnDestroy" )
		player.EndSignal( "OnDestroy" )
		if ( uniqueEndSignal )
			player.EndSignal( uniqueEndSignal )

		local headOffset = (entity.GetWorldSpaceCenter() - entity.GetOrigin())
		local endTime = Time() + delay

		OnThreadEnd(
			function() : ( entity )
			{
				if ( IsValid( entity ) )
					entity.Destroy()
			}
		)

		while ( Time() < endTime )
		{
			local headTraceID = DeferredTraceLine( player.EyePosition(), entity.GetWorldSpaceCenter() + headOffset, player, TRACE_MASK_SOLID_BRUSHONLY | TRACE_MASK_WATER, TRACE_COLLISION_GROUP_NONE )
			wait 0

			if ( !IsDeferredTraceValid( headTraceID ) )
				continue

			local headResult = GetDeferredTraceResult( headTraceID )
			if ( headResult.fraction < 0.99 )
				continue

			local centerTraceID = DeferredTraceLine( player.EyePosition(), entity.GetWorldSpaceCenter(), player, TRACE_MASK_SOLID_BRUSHONLY | TRACE_MASK_WATER, TRACE_COLLISION_GROUP_NONE )
			wait 0

			if ( !IsDeferredTraceValid( centerTraceID ) )
				continue

			local centerResult = GetDeferredTraceResult( centerTraceID )
			if ( centerResult.fraction < 0.99 )
				continue

			entity.s.pulseDuration = (Time() - entity.s.createTime) + 0.1
			wait 0.15

			break
		}
	}


	function SonarActiveChanged( player )
	{
		if ( !( "sonarFXHandle" in player.s ) )
			player.s.sonarFXHandle <- null

		if ( player.GetCinematicEventFlags() & CE_FLAG_SONAR_ACTIVE )
		{
			local cockpit = player.GetCockpit()

			if ( !cockpit )
				return

			if( player.s.sonarFXHandle && EffectDoesExist( player.s.sonarFXHandle ) )
				EffectStop( player.s.sonarFXHandle, false, true )

			player.s.sonarFXHandle = StartParticleEffectOnEntity( cockpit, GetParticleSystemIndex( "P_sonar" ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
		}
		else
		{
			if ( player.s.sonarFXHandle && EffectDoesExist( player.s.sonarFXHandle ) )
				EffectStop( player.s.sonarFXHandle, false, true )

			player.s.sonarFXHandle = null
		}
	}
	Globalize( SonarActiveChanged )

	function SonarPingChanged( player )
	{
		if ( player != GetLocalViewPlayer() )
			return

		thread SonarPulse( player, SONAR_PULSE_RANGE_MAX, SONAR_PULSE_SPEED )
	}
}

function ActivateBurnCardSonar( player, duration, triggerScreenEffects = true, colorCorrectionOverride = null, pulseDelay = SONAR_PULSE_DELAY  )
{
	EmitSoundOnEntity( player, "radarpulse_on" )

	thread SonarSoundThink( null, player, duration, null, pulseDelay )
	thread ServerSonarThink( player, duration, null, triggerScreenEffects, pulseDelay )

	if ( !( "sonarEndTime" in player.s ) )
		player.s.sonarEndTime <- 0
	player.s.sonarEndTime = Time() + duration + pulseDelay

	if ( colorCorrectionOverride )
		thread SonarColorCorrection( player, duration, null, colorCorrectionOverride )
}


function ActivateSonar( weapon, duration, triggerScreenEffects = true, colorCorrectionOverride = null,  pulseDelay = SONAR_PULSE_DELAY  )
{
	local ownerPlayer = weapon.GetWeaponOwner()
	if ( !IsValid( ownerPlayer ) || !ownerPlayer.IsPlayer() )
		return
	weapon.GetScriptScope().PlayWeaponSound_1p3p( "radarpulse_on", "radarpulse_on" )

	if ( IsServer() )
	{
		thread SonarSoundThink( weapon, ownerPlayer, duration, null, pulseDelay )
		thread ServerSonarThink( ownerPlayer, duration, null, true, pulseDelay ) //HACK: triggerScreenEffects parameter not respected, passed as true regardless

		if ( !( "sonarEndTime" in ownerPlayer.s ) )
			ownerPlayer.s.sonarEndTime <- 0
		ownerPlayer.s.sonarEndTime = Time() + duration + pulseDelay

		thread SonarColorCorrection( ownerPlayer, duration, null, colorCorrectionOverride )
	}
}


function ActiveWeaponSonar( weapon, duration, delay = null, pulseDelay = SONAR_PULSE_DELAY )
{
	local ownerPlayer = weapon.GetWeaponOwner()
	if ( !IsValid( ownerPlayer ) || !ownerPlayer.IsPlayer() )
		return
	ownerPlayer.EndSignal( FORCE_SONAR_DEACTIVATE )

	weapon.GetScriptScope().PlayWeaponSound_1p3p( "radarpulse_on", "radarpulse_on" )

	if ( IsServer() )
	{
		thread SonarSoundThink( weapon, ownerPlayer, duration, FORCE_SONAR_DEACTIVATE, pulseDelay )
		if ( !( "sonarEndTime" in ownerPlayer.s ) )
			ownerPlayer.s.sonarEndTime <- 0
		ownerPlayer.s.sonarEndTime = Time() + duration + pulseDelay
		thread SonarColorCorrection( ownerPlayer, duration, FORCE_SONAR_DEACTIVATE, DMR_SONAR_SCOPE_COLOR_CORRECTION )

		if ( delay )
			wait delay

		if ( !IsValid( ownerPlayer ) )
			return
	
		thread ServerSonarThink( ownerPlayer, duration, FORCE_SONAR_DEACTIVATE, false, pulseDelay )
	}
}


function ServerSonarThink( player, duration, uniqueEndSignal = null, triggerScreenEffects = null, pulseDelay = SONAR_PULSE_DELAY )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "Disconnected" )
	local maxDistance = SONAR_PULSE_RANGE_MAX
	local pulseSpeed = SONAR_PULSE_SPEED
	local playerTeam = player.GetTeam()
	local startTime = Time()

	if( uniqueEndSignal )
		player.EndSignal( uniqueEndSignal )

	if ( triggerScreenEffects )
	{
		AddCinematicFlag( player, CE_FLAG_SONAR_ACTIVE )

		OnThreadEnd(
			function() : ( player )
			{
				if ( !IsValid( player ) )
					return

				RemoveCinematicFlag( player, CE_FLAG_SONAR_ACTIVE )
			}
		)
	}

	local hasFlag = HasCinematicFlag( player, CE_FLAG_SONAR_PING )
	while ( Time() - startTime < duration )
	{
		if ( triggerScreenEffects && !HasCinematicFlag( player, CE_FLAG_SONAR_ACTIVE ) ) //Fix edge case where normal sonar cancels burn card sonar forever
				AddCinematicFlag( player, CE_FLAG_SONAR_ACTIVE )

		if ( hasFlag )
			RemoveCinematicFlag( player, CE_FLAG_SONAR_PING )
		else
			AddCinematicFlag( player, CE_FLAG_SONAR_PING )

		hasFlag = !hasFlag

		wait pulseDelay
	}
}


function SonarSoundThink( weapon, player, duration, uniqueEndSignal = null, pulseDelay = SONAR_PULSE_DELAY )
{
	if ( IsValid( weapon ) )  //ActivateBurnCardSonar passes null for weapon on purpose, so check it.
		weapon.EndSignal( "OnDestroy" )

	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "Disconnected" )

	if( uniqueEndSignal )
		player.EndSignal( uniqueEndSignal )

	local enemyTeam = GetOtherTeam( player.GetTeam() )

	local startTime = Time()
	while ( Time() - startTime < (duration - SONAR_PULSE_DELAY) )
	{
		wait pulseDelay

		//if ( IsClient() )
		//	EmitSoundOnEntityOnlyToPlayer( player, player, "radarpulse_ping" )
		//else
			EmitSoundOnEntityToTeam( player, "radarpulse_ping", enemyTeam )
	}
}


function ForceDeactivateSonar( self, uniqueEndSignal )
{
	local weaponOwner = self.GetWeaponOwner()
	if ( IsValid( weaponOwner ) )
		weaponOwner.Signal( uniqueEndSignal )
}



