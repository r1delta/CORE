const FX_SKYBOX_REDEYE_WARP_IN = "veh_red_warp_in_full_SB"
const FX_SKYBOX_REDEYE_WARP_OUT = "veh_red_warp_out_full_SB"
const FX_SKYBOX_BERMINGHAM_WARP_IN = "veh_birm_warp_in_full_SB"
const FX_SKYBOX_BERMINGHAM_WARP_OUT = "veh_birm_warp_out_full_SB"
const FX_ENV_TRASH_TUBE_FAST_HLD = "env_trash_tube_fast_hld"
const FX_ENV_TRASH_TUBE_SLOW_HLD = "env_trash_tube_slow_hld"
const FX_ENV_TRASH_SML_TUBE_FAST_HLD = "env_trash_tube_sml_fast_hld"
const FX_ENV_TRASH_SML_TUBE_SLOW_HLD = "env_trash_tube_sml_slow_hld"
const FX_HOLDING_TANK_WTR_GLOW_HLD = "holding_tank_wtr_glow_hld"
const FX_ELECTRIC_ARC_LG = "P_elec_arc_loop_LG_1"

const WARNING_LIGHT_ON_MODEL	= "models/lamps/warning_light_ON_orange.mdl"
const WARNING_LIGHT_OFF_MODEL 	= "models/lamps/warning_light.mdl"

level.skyboxCamOrigin <- Vector( -11896.0, -12024.0, -3984.0 )
level.progressEnabled <- true
level.progressFuncArray <- []
level.fxPairingDone	<- false
level.FX_WARNING_LIGHT_DLIGHT	<- PrecacheParticleSystem( "warning_light_orange_blink_RT" )
level.FX_WARNING_LIGHT 			<- PrecacheParticleSystem( "warning_light_orange_blink" )
level.hardpointArray			<- [ null, null, null ]
level.hardpointLightsOn			<- [ false, false, false ]
level.pumps						<- []
level.holdingTankWaterGlows		<- []
level.holdingTankWaterPositions <- []
level.holdingTankWaterOn		<- false
level.hardpointScreensOn		<- [ true, true, true ]
level.hardpointScreens			<- [ [], [], [] ]
level.hardpointGeneratorsOverloaded <- false
level.hardpointGeneratorArcPos	<- []
level.uniqueIndex				<- 0

PrecacheParticleSystem( FX_SKYBOX_REDEYE_WARP_IN )
PrecacheParticleSystem( FX_SKYBOX_REDEYE_WARP_OUT )
PrecacheParticleSystem( FX_SKYBOX_BERMINGHAM_WARP_IN )
PrecacheParticleSystem( FX_SKYBOX_BERMINGHAM_WARP_OUT )
PrecacheParticleSystem( FX_ENV_TRASH_TUBE_FAST_HLD )
PrecacheParticleSystem( FX_ENV_TRASH_TUBE_SLOW_HLD )
PrecacheParticleSystem( FX_ENV_TRASH_SML_TUBE_FAST_HLD )
PrecacheParticleSystem( FX_ENV_TRASH_SML_TUBE_SLOW_HLD )
PrecacheParticleSystem( FX_HOLDING_TANK_WTR_GLOW_HLD )
PrecacheParticleSystem( FX_ELECTRIC_ARC_LG )

function main()
{
	Globalize( PumpTurnOff )
	Globalize( PumpTurnOn )

	AddCreateCallback( "info_hardpoint", RunOffHardpointCreated )
	SetFullscreenMinimapParameters( 5.1, 600, -950, 180 )
	if ( GAMETYPE == COOPERATIVE )
		SetCustomMinimapZoom( 2 )
}

function EntitiesDidLoad()
{
	thread SkyboxSlowFlybys()
	PumpSetup()
	HoldingTankWaterSetup()
	HardpointScreensSetup()
	HardpointGeneratorsSetup()
}

function SkyboxSlowFlybys()
{
	local slowFlybyShips = []

	local spawnOffset = Vector( 5.0, 0.0, -7.0 )

	local skyboxWidth = { min = -300, max = 300 }
	local skyboxLength = { min = -650, max = 300 }
	local skyboxHeight = { min = 75.0, max = 200.0 }
	local moveSpeed = { min = 14.0, max = 9.0 }
	local skyboxTotalLength = fabs( skyboxLength.max - skyboxLength.min )
	local moveDuration = { min = skyboxTotalLength / moveSpeed.min, max = skyboxTotalLength / moveSpeed.max }
	local forwardOffset = { min = 0.0, max = 200.0 }
	local rightOffset = { min = -17.5, max = 17.5 }

	local shipDirection = Vector( -0.580235, 0.813501, -0.039295 )

	local spawnAng = VectorToAngles( shipDirection )
	local right = spawnAng.AnglesToRight()

	local numShipsAcross = 8
	local shipSpacing = abs( skyboxWidth.min - skyboxWidth.max ) / numShipsAcross

	local spawnOrder = [ [ 1, 6, 4, 0, 5, 3, 7, 2 ],
						 [ 0, 4, 2, 1, 6, 3, 7, 5 ],
						 [ 0, 1, 3, 6, 7, 4, 2, 5 ],
						 [ 5, 7, 3, 6, 1, 2, 4, 0 ],
						 [ 2, 7, 3, 5, 0, 4, 6, 1 ],
						 [ 5, 2, 4, 7, 6, 3, 1, 0 ] ]

	local heights = [ [ 0.9, 0.4, 0.6, 0.1, 0.2, 0.7, 1.0, 0.3 ],
					  [ 0.4, 0.9, 0.6, 1.0, 0.9, 0.7, 0.5, 0.6 ],
					  [ 0.8, 0.1, 0.7, 0.2, 0.5, 1.0, 0.4, 0.3 ],
					  [ 0.6, 0.5, 0.7, 0.9, 1.0, 0.6, 0.9, 0.4 ],
					  [ 0.3, 1.0, 0.7, 0.2, 0.1, 0.6, 0.4, 0.9 ],
					  [ 0.3, 0.4, 1.0, 0.5, 0.2, 0.7, 0.1, 0.8 ] ]

	local durations = [ [ 0.6, 0.8, 0.7, 0.5, 0.1, 0.6, 0.2, 0.3 ],
						[ 0.4, 0.8, 0.7, 0.5, 0.1, 0.6, 0.2, 0.3 ],
					 	[ 0.6, 0.3, 0.7, 0.5, 0.1, 0.6, 0.2, 0.3 ],
					 	[ 0.3, 0.2, 0.6, 0.1, 0.5, 0.7, 0.8, 0.4 ],
					 	[ 0.3, 0.2, 0.6, 0.1, 0.5, 0.7, 0.3, 0.6 ],
					 	[ 0.3, 0.2, 0.6, 0.1, 0.5, 0.7, 0.8, 0.6 ] ]

	local forwardOffsets = [ [ 0.0, 0.8, 1.0, 0.0, 0.1, 0.6, 0.2, 0.3 ],
							 [ 0.0, 0.8, 0.7, 0.5, 0.1, 0.6, 0.2, 0.3 ],
					 		 [ 0.0, 0.3, 0.7, 0.5, 0.1, 0.6, 0.2, 0.3 ],
					 		 [ 0.3, 0.2, 0.6, 0.1, 0.5, 0.7, 0.8, 0.6 ],
					 		 [ 0.3, 0.2, 0.6, 0.1, 0.5, 0.7, 0.8, 0.4 ],
					 		 [ 0.3, 0.2, 0.6, 0.1, 0.5, 0.7, 0.3, 0.6 ] ]

	local rightOffsets = [ [ 0.6, 0.8, 0.7, 0.5, 0.1, 0.6, 0.2, 0.3 ],
						   [ 0.4, 0.8, 0.7, 0.5, 0.1, 0.6, 0.2, 0.3 ],
					 	   [ 0.6, 0.3, 0.7, 0.5, 0.1, 0.6, 0.2, 0.3 ],
					 	   [ 0.3, 0.2, 0.6, 0.1, 0.5, 0.7, 0.8, 0.6 ],
						   [ 0.3, 0.2, 0.6, 0.1, 0.5, 0.7, 0.8, 0.4 ],
					 	   [ 0.3, 0.2, 0.6, 0.1, 0.5, 0.7, 0.3, 0.6 ] ]

	local shipModels = [ [ 1, 1, 1, 0, 0, 0, 0, 0 ],
						 [ 0, 0, 1, 0, 0, 0, 0, 0 ],
						 [ 1, 0, 1, 0, 0, 0, 0, 1 ],
						 [ 0, 0, 0, 0, 0, 1, 1, 1 ],
						 [ 0, 0, 0, 0, 0, 1, 0, 0 ],
						 [ 1, 0, 0, 0, 0, 1, 0, 1 ] ]

	while ( GetGameState() <= eGameState.SuddenDeath )
	{
		foreach( i, so in spawnOrder )
		{
			foreach( index, val in so )
			{
				local shipMoveDuration = GraphCapped( durations[ i ][ index ], 0.0, 1.0, moveDuration.min, moveDuration.max )

				local offsetForward = skyboxLength.min
				offsetForward += GraphCapped( forwardOffsets[ i ][ index ], 0.0, 1.0, forwardOffset.min, forwardOffset.max )

				local offsetRight = skyboxWidth.min + ( shipSpacing / 2.0 ) + ( shipSpacing * val )
				offsetRight += GraphCapped( rightOffsets[ i ][ index ], 0.0, 1.0, rightOffset.min, rightOffset.max )

				local offsetHeight = GraphCapped( heights[ i ][ index ], 0.0, 1.0, skyboxHeight.min, skyboxHeight.max )

				local spawnPos = level.skyboxCamOrigin + spawnOffset + ( shipDirection * offsetForward ) + ( right * offsetRight ) + Vector( 0, 0, offsetHeight )
				local moveToPos = spawnPos + ( shipDirection * abs( skyboxLength.min - skyboxLength.max ) )

				local model = shipModels[ i ][ index ] == 0 ? SKYBOX_ARMADA_SHIP_MODEL_REDEYE : SKYBOX_ARMADA_SHIP_MODEL_BERMINGHAM
				local ship = CreateClientsideScriptMover( model, spawnPos, spawnAng )
				slowFlybyShips.append( ship )

				thread SkyboxShipWarpIn( ship )
				ship.NonPhysicsMoveTo( moveToPos, shipMoveDuration, 0, 0 )
				thread WarpOutFlybyShipWithDelay( ship, shipMoveDuration )

				wait( 1.0 )
			}

			wait( 24.0 )
		}
	}

	// Make some of the remaining ships warp out during the epilogue
	foreach( ship in slowFlybyShips )
	{
		if ( IsValid( ship ) && "warpinComplete" in ship.s )
			thread WarpOutFlybyShipWithDelay( ship, RandomFloat( 0.0, 30.0 ) )
	}
}

function SkyboxShipWarpIn( ship )
{
	ship.EndSignal( "OnDestroy" )
	local fxID = null
	switch( ship.GetModelName() )
	{
		case SKYBOX_ARMADA_SHIP_MODEL_REDEYE:
			fxID = GetParticleSystemIndex( FX_SKYBOX_REDEYE_WARP_IN )
			break
		case SKYBOX_ARMADA_SHIP_MODEL_BERMINGHAM:
			fxID = GetParticleSystemIndex( FX_SKYBOX_BERMINGHAM_WARP_IN )
			break
		default:
			Assert( 0, "Invalid model for skybox warp in effect for " + ship.GetModelName() )
	}
	Assert( fxID != null )

	ship.Hide()
	EmitSkyboxSoundAtPosition( ship.GetOrigin(), "largeship_warpin" )
	local fx = StartParticleEffectInWorldWithHandle( fxID, ship.GetOrigin(), ship.GetAngles() )
	wait 0.25
	ship.Show()
	ship.s.warpinComplete <- true
}

function SkyboxShipWarpOut( ship )
{
	local fxID = null
	switch( ship.GetModelName() )
	{
		case SKYBOX_ARMADA_SHIP_MODEL_REDEYE:
			fxID = GetParticleSystemIndex( FX_SKYBOX_REDEYE_WARP_OUT )
			break
		case SKYBOX_ARMADA_SHIP_MODEL_BERMINGHAM:
			fxID = GetParticleSystemIndex( FX_SKYBOX_BERMINGHAM_WARP_OUT )
			break
		default:
			Assert( 0, "Invalid model for skybox warp out effect" )
	}
	Assert( fxID != null )
	local fx = StartParticleEffectInWorldWithHandle( fxID, ship.GetOrigin(), ship.GetAngles() )
}

function WarpOutFlybyShipWithDelay( ship, delay = 0 )
{
	wait delay
	if ( !IsValid( ship ) )
		return

	SkyboxShipWarpOut( ship )
	ship.Kill()
}

function PumpSetup()
{
	local sndRef = CreateScriptRef( Vector( -2256.0, -1226.0, 340.5 ) )
	level.pumps.append( { id = 1, fxOnStr = FX_ENV_TRASH_TUBE_FAST_HLD,	fxOffStr = FX_ENV_TRASH_TUBE_SLOW_HLD
						  maxSpeed = 1.8, org = Vector( -2256.0, -1226.0, -140.0 ),	fxOrg = Vector( -2256.0, -1226.0, 340.5 ),	fxAng = Vector( 0.0, 0.0, 0.0 ),	offset = 0.0,
						  sndEnt = sndRef,	sndLoop = "Runoff_Emit_WaterTube_Loop",			sndStart = "Runoff_Emit_WaterTube_Start",	sndStop = "Runoff_Emit_WaterTube_Stop" } )

	sndRef = CreateScriptRef( Vector( -2256.0, -858.0, 340.5 ) )
	level.pumps.append( { id = 1, fxOnStr = FX_ENV_TRASH_TUBE_FAST_HLD,	fxOffStr = FX_ENV_TRASH_TUBE_SLOW_HLD
						  maxSpeed = 1.8, org = Vector( -2256.0, -858.0, -140.0 ),	fxOrg = Vector( -2256.0, -858.0, 340.5 ),	fxAng = Vector( 0.0, 0.0, 0.0 ),	offset = 4.0,
						  sndEnt = sndRef,	sndLoop = "Runoff_Emit_WaterTube_Loop",			sndStart = "Runoff_Emit_WaterTube_Start",	sndStop = "Runoff_Emit_WaterTube_Stop" } )

	sndRef = CreateScriptRef( Vector( 388.0, -1820.0, 112.0 ) )
	level.pumps.append( { id = 0, fxOnStr = FX_ENV_TRASH_SML_TUBE_FAST_HLD,	fxOffStr = FX_ENV_TRASH_SML_TUBE_SLOW_HLD
						  maxSpeed = 1.8, org = Vector( 420.0, -1820.0, 170.0 ),	fxOrg = Vector( 420.0, -1820.0, 170.0 ),	fxAng = Vector( 0.0, 0.0, 180.0 ),	offset = 0.0,
						  sndEnt = sndRef,	sndLoop = "Runoff_Emit_SmallWaterTube_Loop",	sndStart = "Runoff_Emit_WaterTube_Start",	sndStop = "Runoff_Emit_WaterTube_Stop" } )

	level.pumps.append( { id = 0, fxOnStr = FX_ENV_TRASH_SML_TUBE_FAST_HLD,	fxOffStr = FX_ENV_TRASH_SML_TUBE_SLOW_HLD
						  maxSpeed = 1.8, org = Vector( 356.0, -1820.0, 18.0 ),		fxOrg = Vector( 356.0, -1820.0, 18.0 ),		fxAng = Vector( 0.0, 0.0, 0.0 ),	offset = 4.0 } )

	local orgOffset = Vector( 0.0, 0.0, 364.0 )
	local trashAng = Vector( 0.0, 0.0, 0.0 )

	foreach ( pump in level.pumps )
	{
		pump.bottomWrap <- pump.org.z - 364.0
		pump.topWrap <- pump.org.z + 728.0

		pump.on <- false
		pump.speed <- 0.0
		pump.rotSpeed <- 0.0
		pump.fxOn <- GetParticleSystemIndex( pump.fxOnStr )
		pump.fxOff <- GetParticleSystemIndex( pump.fxOffStr )

		if ( pump.on )
			pump.fx <- StartParticleEffectInWorldWithHandle( pump.fxOn, pump.fxOrg, pump.fxAng )
		else
			pump.fx <- StartParticleEffectInWorldWithHandle( pump.fxOff, pump.fxOrg, pump.fxAng )

		EffectSetDontKillForReplay( pump.fx )
	}

	if ( !IsCaptureMode() )
		thread PumpCycle()
}

function PumpTurnOn( id )
{
	foreach ( pump in level.pumps )
	{
		if ( pump.id == id )
		{
			if ( !pump.on )
			{
				pump.on = true
				EffectStop( pump.fx, false, true )
				pump.fx = StartParticleEffectInWorldWithHandle( pump.fxOn, pump.fxOrg, pump.fxAng )
				EffectSetDontKillForReplay( pump.fx )
				if ( "sndEnt" in pump )
				{
					if ( IsValid( pump.sndEnt ) )
					{
						EmitSoundOnEntity( pump.sndEnt, pump.sndStart )
						EmitSoundOnEntity( pump.sndEnt, pump.sndLoop )
					}
				}
			}
		}
	}
}

function PumpTurnOff( id )
{
	foreach ( pump in level.pumps )
	{
		if ( pump.id == id )
		{
			if ( pump.on )
			{
				pump.on = false
				EffectStop( pump.fx, false, true )
				pump.fx = StartParticleEffectInWorldWithHandle( pump.fxOff, pump.fxOrg, pump.fxAng )
				EffectSetDontKillForReplay( pump.fx )

				if ( "sndEnt" in pump )
				{
					if ( IsValid( pump.sndEnt ) )
					{
						StopSoundOnEntity( pump.sndEnt, pump.sndLoop )
						EmitSoundOnEntity( pump.sndEnt, pump.sndStop )
					}
				}
			}
		}
	}
}

function PumpCycle()
{
	while ( true )
	{
		PumpTurnOn( 0 )
		PumpTurnOn( 1 )
		wait( 60.0 )
		PumpTurnOff( 0 )
		PumpTurnOff( 1 )
		wait( 10.0 )
	}
}

function HoldingTankWaterSetup()
{
	level.holdingTankWaterPositions.append( Vector( 251.0, 731.0, 21.0 ) )
	level.holdingTankWaterPositions.append( Vector( 436.0, 901.0, 21.0 ) )
	level.holdingTankWaterPositions.append( Vector( 579.0, 718.0, 21.0 ) )

	level.holdingTankWaterSoundEnts <- []
	foreach ( pos in level.holdingTankWaterPositions )
		level.holdingTankWaterSoundEnts.append( CreateScriptRef( pos ) )

	HoldingTankWaterGlowOn()
}

function HoldingTankWaterGlowOn()
{
	if ( level.holdingTankWaterOn )
		return

	level.holdingTankWaterOn = true

	local fxID = GetParticleSystemIndex( FX_HOLDING_TANK_WTR_GLOW_HLD )

	foreach ( soundEnt in level.holdingTankWaterSoundEnts )
	{
		if ( IsValid( soundEnt ) )
			EmitSoundOnEntity( soundEnt, "Runoff_Emit_HeatedWater" )
	}

	foreach ( pos in level.holdingTankWaterPositions )
	{
		local fx = StartParticleEffectInWorldWithHandle( fxID, pos, Vector( 0.0, 0.0, 0.0 ) )
		EffectSetDontKillForReplay( fx )

		level.holdingTankWaterGlows.append( fx )
	}
}

function HoldingTankWaterGlowOff()
{
	if ( !level.holdingTankWaterOn )
		return

	level.holdingTankWaterOn = false

	foreach ( soundEnt in level.holdingTankWaterSoundEnts )
	{
		if ( IsValid( soundEnt ) )
			StopSoundOnEntity( soundEnt, "Runoff_Emit_HeatedWater" )
	}

	foreach ( glow in level.holdingTankWaterGlows )
		EffectStop( glow, false, true )
}

function RunOffHardpointCreated( hardpoint, isRecreate )
{
	if ( isRecreate || GameRules.GetGameMode() != CAPTURE_POINT )
		return

	local hardpointID = hardpoint.GetHardpointID()
	level.hardpointArray[ hardpointID ] = hardpoint

	thread RunOffHardpointSetup( hardpoint )
}

function RunOffHardpointSetup( hardpoint )
{
	EndSignal( hardpoint, "OnDestroy" )
	FlagWait( "ClientInitComplete" )

	local hardpointID = hardpoint.GetHardpointID()

	// warning lights
	local warningLightModelArray = GetClientEntArray( "prop_dynamic", "warning_light" )
	hardpoint.s.warningLightModelArray <- ArrayWithin( warningLightModelArray, hardpoint.GetOrigin(), 1500.0 )

	// fx pairing
	if ( !level.fxPairingDone )
	{
		// lights
		local lightFxArray = GetClientEntArray( "info_target_clientside", "warning_light_fx" )
		PairFxWithEntity( warningLightModelArray, lightFxArray, level.FX_WARNING_LIGHT, 32 )
		local dLightFxArray = GetClientEntArray( "info_target_clientside", "warning_light_dlight_fx" )
		PairFxWithEntity( warningLightModelArray, dLightFxArray, level.FX_WARNING_LIGHT_DLIGHT, 32 )
		level.fxPairingDone = true
	}

	while ( true )
	{
		local team = hardpoint.GetTeam()

		switch ( hardpointID )
		{
			case 0:
				switch ( team )
				{
					case TEAM_IMC:
						break

					case TEAM_MILITIA:
						HoldingTankWaterGlowOff()
						HardpointScreensOff( hardpoint, hardpointID )
						break

					default:
						HoldingTankWaterGlowOn()
						HardpointScreensOn( hardpoint, hardpointID )
				}
				break

			case 1:
				switch ( team )
				{
					case TEAM_IMC:
						break

					case TEAM_MILITIA:
						PumpTurnOff( 1 )
						break

					default:
						PumpTurnOn( 1 )
				}
				break

			case 2:
				switch ( team )
				{
					case TEAM_IMC:
						break

					case TEAM_MILITIA:
						PumpTurnOff( 0 )
						HardpointLightsOn( hardpoint, hardpointID )
						thread HardpointGeneratorsOverload()
						break

					default:
						PumpTurnOn( 0 )
						HardpointLightsOff( hardpoint, hardpointID )
						HardpointGeneratorsNormal()
				}
				break

			default:
				Assert( true )
		}

		hardpoint.WaitSignal( "HardpointStateChanged" )
	}
}

function GetHardpointFromID( hardpointID )
{
	Assert( IsValid( level.hardpointArray[ hardpointID ] ) )
	return level.hardpointArray[ hardpointID ]
}

function HardpointScreensSetup()
{
	level.hardpointScreens[ 0 ].append( GetClientEnt( "prop_dynamic", "hardpoint_c_screens_1" ) )
	level.hardpointScreens[ 0 ].append( GetClientEnt( "prop_dynamic", "hardpoint_c_screens_2" ) )
	level.hardpointScreens[ 0 ].extend( GetClientEntArray( "prop_dynamic", "hardpoint_c_screens_3" ) )
}

function HardpointGeneratorsSetup()
{
	level.hardpointGeneratorArcPos.append( Vector( 400.0, -2696.4, 103.8 ) )
	level.hardpointGeneratorArcPos.append( Vector( 400.0, -2670.8, 103.2 ) )
	level.hardpointGeneratorArcPos.append( Vector( 400.0, -2682.5, 87.75 ) )

	level.hardpointGeneratorArcPos.append( Vector( 400.0, -2508.4, 103.8 ) )
	level.hardpointGeneratorArcPos.append( Vector( 400.0, -2482.8, 103.2 ) )
	level.hardpointGeneratorArcPos.append( Vector( 400.0, -2494.5, 87.75 ) )

	level.hardpointGeneratorArcPos.append( Vector( 400.0, -2320.4, 103.8 ) )
	level.hardpointGeneratorArcPos.append( Vector( 400.0, -2294.8, 103.2 ) )
	level.hardpointGeneratorArcPos.append( Vector( 400.0, -2306.5, 87.75 ) )

	level.hardpointGeneratorArcPos.append( Vector( 125.0, -2320.4, 103.8 ) )
	level.hardpointGeneratorArcPos.append( Vector( 125.0, -2294.8, 103.2 ) )
	level.hardpointGeneratorArcPos.append( Vector( 125.0, -2306.5, 87.75 ) )
}

function HardpointGeneratorsOverload()
{
	if ( level.hardpointGeneratorsOverloaded )
		return

	level.hardpointGeneratorsOverloaded = true

	local fxID = GetParticleSystemIndex( FX_ELECTRIC_ARC_LG )
	local numArcPoses = level.hardpointGeneratorArcPos.len()

	while ( level.hardpointGeneratorsOverloaded )
	{
		local pos = level.hardpointGeneratorArcPos[ RandomInt( numArcPoses ) ]
		StartParticleEffectInWorld( fxID, pos, Vector( 0.0, 0.0, 0.0 ) )
		EmitSoundAtPosition( pos, "Runoff_hardpoint_electricity" )
		wait( 0.3 + RandomFloat( 0.0, 0.2 ) )
	}
}

function HardpointGeneratorsNormal()
{
	level.hardpointGeneratorsOverloaded = false
}

function HardpointLightsOn( hardpoint, hardpointID )
{
	if ( level.hardpointLightsOn[ hardpointID ] )
		return

	level.hardpointLightsOn[ hardpointID ] = true

	foreach( lightModel in hardpoint.s.warningLightModelArray )
		thread TurnLightOn( lightModel, true )
}

function HardpointLightsOff( hardpoint, hardpointID )
{
	if ( !level.hardpointLightsOn[ hardpointID ] )
		return

	level.hardpointLightsOn[ hardpointID ] = false

	foreach( lightModel in hardpoint.s.warningLightModelArray )
		thread TurnLightOff( lightModel, false )
}

function TurnLightOff( lightModel, instant )
{
	lightModel.EndSignal( "OnDestroy" )

	local player = GetLocalViewPlayer()
	if ( !IsWatchingKillReplay() && !instant )
		wait RandomFloat( 0, 2.0 )

	if ( !IsValid( lightModel ) )
		return

	lightModel.SetModel( WARNING_LIGHT_OFF_MODEL )
	if ( lightModel.s.fxHandle )
	{
		EffectStop( lightModel.s.fxHandle, false, true )
		lightModel.s.fxHandle = null
	}
}

function TurnLightOn( lightModel, instant )
{
	lightModel.EndSignal( "OnDestroy" )

	// dsync the lights a bit
	if ( !IsWatchingKillReplay() )
		wait RandomFloat( 0, 2.0 )

	if ( !IsValid( lightModel ) )
		return

	lightModel.SetModel( WARNING_LIGHT_ON_MODEL )

	local origin = lightModel.s.fxEnt.GetOrigin()
	local angles = lightModel.s.fxEnt.GetAngles()

	lightModel.s.fxHandle = StartParticleEffectInWorldWithHandle( lightModel.s.fxID, origin, angles )
	EffectSetDontKillForReplay( lightModel.s.fxHandle )
}

function PairFxWithEntity( entityArray, fxArray, fxID, maxDist = 32, soundTypeID = null )
{
	local maxDist = pow( maxDist, 2 )

	// find the closest fx to an entity and pair them up
	foreach( entity in entityArray )
	{
		local origin = entity.GetOrigin()
		foreach( index, fxEnt in fxArray )
		{
			if ( DistanceSqr( fxEnt.GetOrigin(), origin ) < maxDist )
			{
				Assert( !( "fxEnt" in entity.s ), "tried to add an fx to a entity that already had one paired with it." )
				local uniqueIndex = level.uniqueIndex++
				local sound = null
				if ( soundTypeID )
				{
					local soundArray = level.soundTable[ soundTypeID ]
					sound = soundArray[ uniqueIndex % soundArray.len() ]
				}

				entity.s.fxEnt			<- fxEnt
				entity.s.fxID			<- fxID
				entity.s.fxHandle	 	<- null
				entity.s.index			<- uniqueIndex
				entity.s.sound			<- sound
				entity.s.active			<- false
				entity.s.playing		<- false

				fxArray.remove( index )
				break
			}
		}
	}
}

function HardpointScreensOn( hardpoint, hardpointID )
{
	if ( level.hardpointScreensOn[ hardpointID ] )
		return

	level.hardpointScreensOn[ hardpointID ] = true

	foreach ( screen in level.hardpointScreens[ hardpointID ] )
		thread MonitorFlicker( screen, true )
}

function HardpointScreensOff( hardpoint, hardpointID )
{
	if ( !level.hardpointScreensOn[ hardpointID ] )
		return

	level.hardpointScreensOn[ hardpointID ] = false

	foreach ( screen in level.hardpointScreens[ hardpointID ] )
		thread MonitorFlicker( screen, false )
}

function MonitorFlicker( monitor, active )
{
	local player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )
	monitor.EndSignal( "OnDestroy" )

	local flickers = RandomInt( 2, 6 ) * 2 + 1 // always an odd number
	local state = !active

	wait RandomFloat( 0, 0.5 )	// longer initial wait so that not every screen powers on at the same time.

	for ( local i = 0; i < flickers; i++ )
	{
		if ( !state )
		{
			monitor.Show()
			state = true
		}
		else
		{
			monitor.Hide()
			state = false
		}
		wait RandomFloat( 0, 0.2 )
	}
}