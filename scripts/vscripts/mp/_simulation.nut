
const FX_POD_GLOWLIGHT 	= "P_pod_door_glow_FP"
const FX_POD_DLIGHT_CONSOLE1 		= "P_pod_Dlight_console1"
const FX_POD_DLIGHT_CONSOLE2 		= "P_pod_Dlight_console2"
const FX_POD_DLIGHT_BACKLIGHT_SIDE 	= "P_pod_Dlight_backlight_side"
const FX_POD_DLIGHT_BACKLIGHT_TOP 	= "P_pod_Dlight_backlight_top"

PrecacheParticleSystem( FX_POD_GLOWLIGHT )
PrecacheParticleSystem( FX_POD_DLIGHT_CONSOLE1 )
PrecacheParticleSystem( FX_POD_DLIGHT_CONSOLE2 )
PrecacheParticleSystem( FX_POD_DLIGHT_BACKLIGHT_SIDE )
PrecacheParticleSystem( FX_POD_DLIGHT_BACKLIGHT_TOP )

function main()
{
	if ( reloadingScripts )
		return

	AddDeathCallback( "npc_soldier", Simulation_GroundTroopsDeathCallback )
	AddDeathCallback( "npc_spectre", Simulation_GroundTroopsDeathCallback )
	AddDeathCallback( "npc_marvin", Simulation_GroundTroopsDeathCallback )
	AddDeathCallback( "player", Simulation_GroundTroopsDeathCallback )

	Globalize( Simulation_GroundTroopsDeathCallback )
}

function Simulation_GroundTroopsDeathCallback( guy, damageInfo )
{
	EmitSoundAtPosition( guy.GetOrigin(), "Object_Dissolve" )

	if ( ShouldDoDissolveDeath( guy, damageInfo ) )
		guy.Dissolve( ENTITY_DISSOLVE_CHAR, Vector( 0, 0, 0 ), 0 )
}

function ShouldDoDissolveDeath( guy, damageInfo )
{
	if ( !guy.IsPlayer() )
		return true

	// can't dissolve players when they're not playing the game, otherwise when the game starts again they're invisible
	local gs = GetGameState()
	if ( gs != eGameState.Playing && gs != eGameState.SuddenDeath && gs != eGameState.Epilogue )
	{
		printt( "Skipping player dissolve death because game is not active ( player:", guy, ")" )
		return false
	}

	return true
}

function TrainingPod_ViewConeLock_Shared( player )
{
	player.PlayerCone_FromAnim()
	player.PlayerCone_SetMinYaw( -25 )
	player.PlayerCone_SetMaxYaw( 25 )
	player.PlayerCone_SetMinPitch( -30 )
}

function TrainingPod_ViewConeLock_PodOpen( player )
{
	TrainingPod_ViewConeLock_Shared( player )
	player.PlayerCone_SetMaxPitch( 35 )
}

function TrainingPod_ViewConeLock_PodClosed( player )
{
	TrainingPod_ViewConeLock_Shared( player )
	player.PlayerCone_SetMaxPitch( 30 )
}

function TrainingPod_ViewConeLock_SemiStrict( player )
{
	player.PlayerCone_FromAnim()
	player.PlayerCone_SetMinYaw( -10 )
	player.PlayerCone_SetMaxYaw( 10 )
	player.PlayerCone_SetMinPitch( -10 )
	player.PlayerCone_SetMaxPitch( 10 )
}

function TrainingPod_ViewConeLock_Strict( player )
{
	player.PlayerCone_FromAnim()
	player.PlayerCone_SetMinYaw( 0 )
	player.PlayerCone_SetMaxYaw( 0 )
	player.PlayerCone_SetMinPitch( 0 )
	player.PlayerCone_SetMaxPitch( 0 )
}

function TrainingPod_SetupInteriorDLights( pod )
{
	local map = []
    map.append( { scriptAlias = "console1", 		fxName = FX_POD_DLIGHT_CONSOLE1, 		attachName = "light_console1" } )
    map.append( { scriptAlias = "console2", 		fxName = FX_POD_DLIGHT_CONSOLE2, 		attachName = "light_console2" } )
    map.append( { scriptAlias = "backlight_side_L", fxName = FX_POD_DLIGHT_BACKLIGHT_SIDE, 	attachName = "light_back1" } )
    map.append( { scriptAlias = "backlight_side_R", fxName = FX_POD_DLIGHT_BACKLIGHT_SIDE, 	attachName = "light_back2" } )
    map.append( { scriptAlias = "backlight_top", 	fxName = FX_POD_DLIGHT_BACKLIGHT_TOP, 	attachName = "light_backtop" } )
    pod.s.dLightMappings <- map
}

function TrainingPod_TurnOnInteriorDLight( scriptAlias, pod )
{
	local fxName
	local attachName
	foreach ( mapping in pod.s.dLightMappings )
	{
		if ( mapping.scriptAlias == scriptAlias )
		{
			fxName = mapping.fxName
			attachName = mapping.attachName
			break
		}
	}

	Assert( fxName && attachName )

	local fxHandle = PlayLoopFXOnEntity( fxName, pod, attachName )
	pod.s.dLights.append( fxHandle )
}

function TrainingPod_KillInteriorDLights_Delayed( pod, delay )
{
	if ( IsTrainingLevel() )
	{
		level.player.EndSignal( "OnDestroy" )
		level.player.EndSignal( "Disconnected" )
		level.ent.EndSignal( "ModuleChanging" )
	}

	pod.EndSignal( "OnDestroy" )

	wait delay

	TrainingPod_KillInteriorDLights( pod )
}

function TrainingPod_KillInteriorDLights( pod )
{
	foreach ( fxHandle in pod.s.dLights )
	{
		if ( !IsValid_ThisFrame( fxHandle ) )
			continue

		KillFX( fxHandle )
	}

	pod.s.dLights = []
}

function TrainingPod_SnapLaserEmittersToAttachPoints( pod )
{
	foreach ( emitter in pod.s.laserEmitters )
	{
		local attachID = pod.LookupAttachment( emitter.s.attachName )
		local attachOrg = pod.GetAttachmentOrigin( attachID )
		local attachAng = pod.GetAttachmentAngles( attachID )

		emitter.ClearParent()
		emitter.SetOrigin( attachOrg )  // HACK set this to ANYTHING  (even 0, 0, 0) and the position is correct, otherwise it's offset from the attachpoint when parented
		emitter.SetParent( pod, emitter.s.attachName )
	}
}

function TrainingPod_InteriorFX_CommonSetup( pod )
{
	if ( pod.s.laserEmitters.len() )
	{
		TrainingPod_KillLasers( pod )
		TrainingPod_ResetLaserEmitterRotation( pod )
	}

	TrainingPod_KillGlowFX( pod )
}

function TrainingPod_KillLasers( pod, doEndCap = false )
{
	foreach ( emitter in pod.s.laserEmitters )
	{
		if ( IsValid_ThisFrame( emitter.s.fxHandle ) )
		{
			if ( !doEndCap )
			{
				//printt( "killing laser FX", emitter.s.fxHandle )
				KillFX( emitter.s.fxHandle )
			}
			else
			{
				//printt( "killing laser FX with endcap", emitter.s.fxHandle )
				KillFXWithEndcap( emitter.s.fxHandle )
			}
		}

		emitter.s.fxHandle = null
	}
}

function TrainingPod_ResetLaserEmitterRotation( pod )
{
	if ( !( "laserEmitters" in pod.s ) )
		return

	foreach ( emitter in pod.s.laserEmitters )
	{
		//reset to start position
		emitter.RotateTo( emitter.s.ogAng, 0.05 )
	}
}

function TrainingPod_KillGlowFX( pod )
{
	foreach ( fxHandle in pod.s.glowLightFXHandles )
	{
		if ( !IsValid_ThisFrame( fxHandle ) )
			continue

		KillFX( fxHandle )
	}

	pod.s.glowLightFXHandles = []
}

function TrainingPod_GlowLightsArraySetup( pod )
{
	local rows = []
	// rows are set up bottom to top
	// lights are set up outside to in (in = door close seam; opposite for each side)
	// process two rows per loop (one for each door side)
	local row = []
	row.append( [ "fx_glow_L_door012", "fx_glow_L_door013" ] )
	row.append( [ "fx_glow_R_door014", "fx_glow_R_door013" ] )
	rows.append( row )

	local row = []
	row.append( [ "fx_glow_L_door014", "fx_glow_L_door011" ] )
	row.append( [ "fx_glow_R_door012", "fx_glow_R_door011" ] )
	rows.append( row )

	local row = []
	row.append( [ "fx_glow_L_door09", "fx_glow_L_door010" ] )
	row.append( [ "fx_glow_R_door09", "fx_glow_R_door010" ] )
	rows.append( row )

	local row = []
	row.append( [ "fx_glow_L_door07", "fx_glow_L_door08" ] )
	row.append( [ "fx_glow_R_door07", "fx_glow_R_door08" ] )
	rows.append( row )

	local row = []
	row.append( [ "fx_glow_L_door05", "fx_glow_L_door06" ] )
	row.append( [ "fx_glow_R_door05", "fx_glow_R_door06" ] )
	rows.append( row )

	local row = []
	row.append( [ "fx_glow_L_door03", "fx_glow_L_door04" ] )
	row.append( [ "fx_glow_R_door03", "fx_glow_R_door04" ] )
	rows.append( row )

	local row = []
	row.append( [ "fx_glow_L_door01", "fx_glow_L_door02" ] )
	row.append( [ "fx_glow_R_door01", "fx_glow_R_door02" ] )
	rows.append( row )

	if ( GetMapName() == "mp_wargames" )
		pod.s.trainingPodGlowLightRows = rows
	else
		level.trainingPodGlowLightRows = rows
}

function TrainingPod_GlowLightsTurnOn( pod, lightWait, rowWait )
{
	//local startTime = Time()

	local lightRows = GetMapName() == "mp_wargames" ? pod.s.trainingPodGlowLightRows : level.trainingPodGlowLightRows

	// light up one light on each side at a time
	foreach ( row in lightRows )
	{
		local loopTime = Time()

		// assume both sides have same number of lights
		local numLights = row[ 0 ].len()

		for ( local i = 0; i < numLights; i++ )
		{
			foreach ( side in row )
			{
				local attachName = side[ i ]
				local fxHandle = PlayLoopFXOnEntity( FX_POD_GLOWLIGHT, pod, attachName )
				pod.s.glowLightFXHandles.append( fxHandle )
			}

			if ( lightWait > 0 )
				wait lightWait
		}

		if ( rowWait > 0)
			wait rowWait
	}

	//printt( "glow lights turn on took", Time() - startTime, "secs" )
}

// ==============================================================
// MP Exclusive
// ==============================================================

if ( !IsTrainingLevel() )
{
	function Intro_PlayersStartFirstPersonSequence()
	{
		foreach ( player in level.playersWatchingIntro )
			thread Intro_StartPlayerFirstPersonSequence( player )
	}

	function PlayPodGamemodeVoicelines( playFallbackGenVoiceline = true )
	{
		foreach ( player in level.playersWatchingIntro )
		{
			local genIdx = player.GetGen()
			local origin = player.GetOrigin()
			//printt( "$$$$ Player", player, "genIdx:", genIdx )

			// GetGen 1 = gen 2
			// GetGen 9 = gen 10

			if ( genIdx > 0 && genIdx <= 9 )
			{
				local gen = genIdx + 1
				Assert( gen >= 2 && gen <= 10 )  // make sure we have an alias to play
				// "Gen [x] Pilot on deck." (w variants)
				local genAlias = "diag_dlc1_WG_pilot_onboard_gen" + gen
				EmitSoundAtPositionOnlyToPlayer( origin, player, genAlias )
			}
			else
			{
				if ( playFallbackGenVoiceline )
				{
					// "Welcome back."
					EmitSoundAtPositionOnlyToPlayer( origin, player, "diag_dlc1_WG129_01_01_neut_tutai" )
				}
			}
		}

		wait 2.75

		if ( GetMapName() == "mp_npe" )
		{
			switch ( GameRules.GetGameMode() )
			{
				case LAST_TITAN_STANDING:
				case WINGMAN_LAST_TITAN_STANDING:
				case TITAN_BRAWL:
				case TITAN_MFD:
				case TITAN_MFD_PRO:
				case TITAN_BRAWL_AUTO:
					// Now beginning Titan training.
					EmitSoundToIntroPlayers( "diag_tut_npeLevel_NP275_01_01_neut_tutai" )
					wait 3
					break
				
				default:
					// "Prepare for combat."
					EmitSoundToIntroPlayers( "diag_dlc1_WG_pod_getready" )
					wait 2.4
					break
			}
		}
		else
		{
			// "Prepare for combat."
			EmitSoundToIntroPlayers( "diag_dlc1_WG_pod_getready" )
			wait 2.4
		}

	    local modeAliases = {}
	    modeAliases[ ATTRITION ] 					<- "diag_dlc1_WG136_01_01_neut_tutai"  // "Attrition."
	    modeAliases[ TEAM_DEATHMATCH ] 				<- "diag_dlc1_WG137_01_01_neut_tutai"  // "Pilot Hunter."
	    modeAliases[ SCAVENGER ] 					<- "diag_dlc1_WG137_01_01_neut_tutai"
	    modeAliases[ CAPTURE_POINT ] 				<- "diag_dlc1_WG138_01_01_neut_tutai"  // "Hardpoint Domination."
	    modeAliases[ LAST_TITAN_STANDING ] 			<- "diag_dlc1_WG139_01_01_neut_tutai"  // "Last Titan Standing."
	    modeAliases[ "lts_ffa" ]		 			<- "diag_dlc1_WG139_01_01_neut_tutai"  // "Last Titan Standing."
	    modeAliases[ WINGMAN_LAST_TITAN_STANDING ] 	<- "diag_dlc1_WG142_01_01_neut_tutai"  // "Wingman Last Titan Standing."
	    modeAliases[ CAPTURE_THE_FLAG ] 			<- "diag_dlc1_WG140_01_01_neut_tutai"  // "Capture The Flag."
	    modeAliases[ CAPTURE_THE_FLAG_PRO ] 		<- "diag_dlc1_WG140_01_01_neut_tutai"
	    modeAliases[ PILOT_SKIRMISH ] 				<- "diag_dlc1_WG232_01_01_neut_tutai"
	    modeAliases[ MARKED_FOR_DEATH ] 			<- "diag_dlc1_WG236_01_01_neut_tutai"
	    modeAliases[ MARKED_FOR_DEATH_PRO ] 		<- "diag_dlc1_WG237_01_01_neut_tutai"
	    modeAliases[ TITAN_BRAWL ] 					<- "diag_dlc1_WG137_01_01_neut_tutai"
	    modeAliases[ TITAN_MFD ] 					<- "diag_dlc1_WG236_01_01_neut_tutai"
	    modeAliases[ TITAN_MFD_PRO ] 				<- "diag_dlc1_WG237_01_01_neut_tutai"

		// make sure we have VO for the game mode
		local mode = GameRules.GetGameMode()
		local modeAlias
		if ( !( mode in modeAliases ) )
		{
			modeAlias = modeAliases[ TEAM_DEATHMATCH ]
			printt( "Couldn't find alias VO for gamemode", mode,". Defaulting to pilot hunter." )
			//printt( "Couldn't find alias VO for gamemode", mode,", finishing training pod VO early." )
			//return
		}
		else
		{
			modeAlias = modeAliases[ mode ]
		}

	    // "Simulation mode is:"
	    EmitSoundToIntroPlayers( "diag_dlc1_WG135_01_01_neut_tutai" )

	    wait 1.5

	    EmitSoundToIntroPlayers( modeAlias )
	}

	function EmitSoundToIntroPlayers( alias )
	{
	    foreach ( player in level.playersWatchingIntro )
	    	if ( IsValid( player ) )
				EmitSoundAtPositionOnlyToPlayer( player.GetOrigin(), player, alias )
	}

	function EmitSoundOnlyToIntroPlayers( alias, team = null )
	{
		foreach ( player in level.playersWatchingIntro )
		{
			if ( !IsValid( player ) )
				continue

			if ( team && player.GetTeam() != team )
				continue

			printt( "Emitting sound on player", player )
			EmitSoundOnEntityOnlyToPlayer( player, player, alias )
		}
	}

	function FadeOutSoundOnIntroPlayers( alias, fadeTime )
	{
		foreach ( player in level.playersWatchingIntro )
			if ( IsValid( player ) )
				FadeOutSoundOnEntity( player, alias, fadeTime )
	}

	function SimulationStartSpawnLifecycleIsValid( player, token )
	{
		if ( !IsValid( player )
			|| !player.hasConnected
			|| !IsAlive( player )
			|| !( "simulationSpawnRetryToken" in player.s )
			|| player.s.simulationSpawnRetryToken != token )
		{
			return false
		}

		switch ( GetGameState() )
		{
			case eGameState.Prematch:
			case eGameState.Playing:
			case eGameState.SuddenDeath:
				break

			default:
				return false
		}

		if ( PlayerShouldObserve( player ) )
			return false

		if ( IsPlayerInCinematic( player )
			&& ( !( "playersWatchingIntro" in level ) || !ArrayContains( level.playersWatchingIntro, player ) ) )
		{
			return false
		}

		return true
	}

	function ReleaseSimulationStartSpawnReservation( reservation, token )
	{
		local spawnPoint = reservation.spawnPoint
		if ( IsValid( spawnPoint )
			&& "simulationSpawnReservationToken" in spawnPoint.s
			&& spawnPoint.s.simulationSpawnReservationToken == token )
		{
			spawnPoint.s.simulationSpawnReservationToken = null
			spawnPoint.s.inUse = false
		}

		reservation.spawnPoint = null
	}


	function TeleportPlayerToRealStartSpawn( player )
	{
		if ( !IsValid( player ) )
			return

		if ( IsRoundBased() && GetRoundsPlayed() > 0 )
			return  // subsequent rounds don't do custom intro so gamestate scripts can handle spawning

		if ( !( "simulationSpawnRetryToken" in player.s ) )
			player.s.simulationSpawnRetryToken <- null
		if ( player.s.simulationSpawnRetryToken != null )
			return

		local token = UniqueString( "simulation_start_spawn" )
		player.s.simulationSpawnRetryToken = token
		local reservation = {
			spawnPoint = null
		}

		player.EndSignal( "Disconnected" )
		player.EndSignal( "OnDeath" )

		OnThreadEnd(
			function() : ( player, token, reservation )
			{
				ReleaseSimulationStartSpawnReservation( reservation, token )

				if ( IsValid( player )
					&& "simulationSpawnRetryToken" in player.s
					&& player.s.simulationSpawnRetryToken == token )
				{
					player.s.simulationSpawnRetryToken = null
				}
			}
		)

		if ( !SimulationStartSpawnLifecycleIsValid( player, token ) )
			return

		if ( ShouldIntroSpawnAsTitan() )
		{
			// Titan spawning owns its own point reservation while this wrapper retains the simulation owner.
			while ( SimulationStartSpawnLifecycleIsValid( player, token ) && !player.IsTitan() )
			{
				waitthread TitanPlayerHotDropsIntoLevel( player, null, null, true, token )
				if ( SimulationStartSpawnLifecycleIsValid( player, token ) && !player.IsTitan() )
					wait 0.1
			}

			if ( !SimulationStartSpawnLifecycleIsValid( player, token ) )
				return
		}
		else
		{
			player.EndSignal( "OnRespawned" )
			local spawnPoint

			while ( !spawnPoint )
			{
				while ( !spawnPoint )
				{
					if ( !SimulationStartSpawnLifecycleIsValid( player, token ) )
						return

					spawnPoint = FindStartSpawnPoint( player )

					if ( !spawnPoint )
					{
						if ( !SimulationStartSpawnLifecycleIsValid( player, token ) )
							return
						wait 0.1
					}
				}

				if ( !SimulationStartSpawnLifecycleIsValid( player, token ) )
					return

				reservation.spawnPoint = spawnPoint
				if ( !( "simulationSpawnReservationToken" in spawnPoint.s ) )
					spawnPoint.s.simulationSpawnReservationToken <- null
				spawnPoint.s.simulationSpawnReservationToken = token
				spawnPoint.s.inUse = true

				if ( !SimulationStartSpawnLifecycleIsValid( player, token )
					|| spawnPoint.s.simulationSpawnReservationToken != token )
				{
					return
				}

				WaitEndFrame()
				if ( !SimulationStartSpawnLifecycleIsValid( player, token ) )
					return

				if ( !IsReservedSpawnpointValid( spawnPoint, player.GetTeam(), player ) )
				{
					ReleaseSimulationStartSpawnReservation( reservation, token )
					spawnPoint = null
					continue
				}
			}

			Assert( player.GetParent() == null, "ERROR Can't teleport player to real start spawn because he's still parented to entity: " + player.GetParent() )

			if ( !SimulationStartSpawnLifecycleIsValid( player, token ) )
				return
			thread TeleportPlayer_MaterializeSFX( player, 0.4 )

			if ( !SimulationStartSpawnLifecycleIsValid( player, token ) )
				return
			player.SetOrigin( spawnPoint.GetOrigin() )
			player.SetAngles( spawnPoint.GetAngles() )

			//printt( player, "teleported to real start spawn,", "origin:", spawnpoint.GetOrigin(), "angles:", spawnpoint.GetAngles() )
		}
	}

	function TeleportPlayer_MaterializeSFX( player, delay = 0.0 )
	{
		player.EndSignal( "Disconnected" )

		if ( delay > 0.0 )
			wait delay

		EmitSoundOnEntityOnlyToPlayer( player, player, "Wargames_Materialize" )
	}
}

main()