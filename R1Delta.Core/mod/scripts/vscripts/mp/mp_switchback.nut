
const LIFT_MODEL = "models/props/lift/lift.mdl"
const LIFT_SHIP_MODEL = "models/props/supply_barge/lift_ship.mdl"
const GREENHOUSE_FAN_BLADE_MODEL = "models/props/greenhouse_fan_blade/greenhouse_fan_blade_animated.mdl"
const AOE_AR_CYLINDER = "models/test/ar_cylinder.mdl"

const IMPACT_WATER_FX = "P_hmn_land_impact_water"
const IMPACT_WATER_TITAN_FX = "P_impact_dpod_water"

function main()
{
	IncludeFile( "mp_switchback_shared" )

	if ( reloadingScripts )
		return

	level.AOETrapEnabled <- true
	level.AOETitanDamage <- 200.0
	level.AOEPilotDamage <- 15.0
	level.AOEPilotInstantDamage <- 200.0
	level.AOETrapAttacker <- null

	level.AOETriggerDamagePlayers <- []
	level.AOETriggerInstantDamagePlayers <- []
	level.AOEActiveDamageTriggers <- []

	FlagSet( "DogFights" ) // tells flightpath to bake these into the ain

	GM_AddEndRoundFunc( EndRoundMain )

	PrecacheModel( LIFT_MODEL )
	PrecacheModel( LIFT_SHIP_MODEL )
	PrecacheModel( GREENHOUSE_FAN_BLADE_MODEL )
	PrecacheModel( AOE_AR_CYLINDER )
	PrecacheModel( SKYBOX_ARMADA_SHIP_MODEL_REDEYE )
	PrecacheModel( SKYBOX_ARMADA_SHIP_MODEL_BERMINGHAM )
	PrecacheEffect( IMPACT_WATER_FX )
	PrecacheEffect( IMPACT_WATER_TITAN_FX )

	AddDamageCallback( "prop_dynamic", PropDynamicDamaged )

	AddDamageCallbackSourceID( eDamageSourceId.switchback_trap, AOETrap_DamagedPlayerOrNPC )

	AddSpawnFunction( "trigger_hurt", InitSubmergedTriggers )

	AddCallback_OnPlayerRespawned( PlayerRespawned )
}

function EntitiesDidLoad()
{
	if ( EvacEnabled() )
		EvacSetup()

	AOETriggerModelInit( GetEnt( "prop_aoe_electrical_panel_1" ) )
	AOETriggerModelInit( GetEnt( "prop_ar_glow" ) )

	thread AOEDamageThread()

	local greenhouseFanTrigger = GetEnt( "trigger_greenhouse_fan_damage" )
	if ( IsValid( greenhouseFanTrigger ) )
		greenhouseFanTrigger.ConnectOutput( "OnStartTouch", GreenhouseFanDamage )

	delaythread( CLASSIC_MP_SKYSHOW_DOGFIGHTS_DELAY ) StratonHornetDogfights()

	local bug74431Fix = GetEnt( "info_spawnpoint_human_start_72" )
	if ( IsValid( bug74431Fix ) )
		bug74431Fix.SetOrigin( Vector( 2822.0, -1288.0, 98.448143 ) )

	local bug74623Fix = GetEnt( "trigger_hardpoint_C" )
	if ( IsValid( bug74623Fix ) )
		bug74623Fix.SetOrigin( Vector( 1120.0, 1916.0, 964.0 ) )

	local bug76386Positions = [ Vector( -1194, 965, 734 ),
								Vector( -1194, 965, 694 ),
								Vector( -1330, 965, 734 ),
								Vector( -1330, 965, 694 ),
								Vector( -930, 1276, 734 ),
								Vector( -930, 1276, 694 ) ]

	foreach ( pos in bug76386Positions )
	{
		local model = CreatePropDynamic( "models/nexus/nexus_window_highrise_b.mdl", pos, Vector( 0.0, 90.0, 0.0 ), 8 )
		model.MakeInvisible()
	}
}

function EvacSetup()
{
	local spectatorNode1 = GetEnt( "spec_cam1" )
	local spectatorNode2 = GetEnt( "spec_cam2" )
	local spectatorNode3 = GetEnt( "spec_cam3" )
	local spectatorNode4 = GetEnt( "spec_cam4" )

	local verticalAnims = Evac_CreateAnimPackage( "dropship_VTOL_evac_start", "dropship_VTOL_evac_idle", "dropship_VTOL_evac_end" )

	Evac_AddLocation( "escape_node2", spectatorNode2.GetOrigin(), spectatorNode2.GetAngles(), verticalAnims )
	Evac_AddLocation( "escape_node3", spectatorNode3.GetOrigin(), spectatorNode3.GetAngles(), verticalAnims )
	Evac_AddLocation( "escape_node4", spectatorNode4.GetOrigin(), spectatorNode4.GetAngles()  )

	local spacenode = GetEnt( "spaceNode" )

	Evac_SetSpaceNode( spacenode )
	Evac_SetupDefaultVDUs()
}

function EndRoundMain()
{
	if ( EvacEnabled() )
		GM_SetObserverFunc( EvacObserverFunc )
}

function EvacObserverFunc( player )
{
	player.SetObserverModeStaticPosition( level.ExtractLocations[ level.SelectedExtractLocationIndex ].spectatorPos )
	player.SetObserverModeStaticAngles( level.ExtractLocations[ level.SelectedExtractLocationIndex ].spectatorAng )

	player.StartObserverMode( OBS_MODE_CHASE )
	player.SetObserverTarget( null )
}

function GreenhouseFanDamage( self, activator, caller, value )
{
	activator.TakeDamage( 8.0, self, self, { scriptType = DF_INSTANT, damageSourceId = eDamageSourceId.splat } )
}

function InitSubmergedTriggers( self )
{
	if ( !self.HasKey( "damageSourceName" ) )
		return

	if ( self.GetValueForKey( "damageSourceName" ) == "submerged" )
	{
		self.ConnectOutput( "OnStartTouch", SubmergedTriggerOnStartTouch )
		self.ConnectOutput( "OnEndTouch", SubmergedTriggerOnEndTouch )
	}
}

function SubmergedTriggerOnStartTouch( self, activator, caller, value )
{
	if ( activator.IsPlayer() )
	{
		local impactWaterFX = IMPACT_WATER_FX
		local impactWater1PSound = "Switchback_Death_Splash_1P"
		local impactWater3PSound = "Switchback_Death_Splash_3P"

		if ( activator.IsTitan() )
		{
			if ( !( "isInDeepWater" in activator.s ) )
				activator.s.isInDeepWater <- true

			activator.s.isInDeepWater = true

			impactWaterFX = IMPACT_WATER_TITAN_FX

			impactWater1PSound = "Switchback_Death_TitanSplash_1P"
			impactWater3PSound = "Switchback_Death_TitanSplash_3P"
		}

		local waterSurfaceOrg = activator.GetOrigin()
		waterSurfaceOrg.z = -132.0

		local effect = CreateEntity( "info_particle_system" )
		effect.SetOrigin( waterSurfaceOrg )
		effect.kv.effect_name = impactWaterFX
		effect.kv.start_active = 1
		effect.SetStopType( "destroyImmediately" )

		DispatchSpawn( effect, false )

		EmitSoundOnEntityOnlyToPlayer( activator, activator, impactWater1PSound )
		EmitSoundOnEntityExceptToPlayer( activator, activator, impactWater3PSound )
	}
}

function SubmergedTriggerOnEndTouch( self, activator, caller, value )
{
	if ( IsAlive( activator ) )
	{
		if ( "isInDeepWater" in activator.s )
			activator.s.isInDeepWater = false

		StopSoundOnEntity( activator, "Switchback_Death_Splash_1P" )
		StopSoundOnEntity( activator, "Switchback_Death_Splash_3P" )

		StopSoundOnEntity( activator, "Switchback_Death_TitanSplash_1P" )
		StopSoundOnEntity( activator, "Switchback_Death_TitanSplash_3P" )
	}
}

function PlayerRespawned( player )
{
	if ( "isInDeepWater" in player.s )
		player.s.isInDeepWater = false

	StopSoundOnEntity( player, "Switchback_Death_Splash_1P" )
	StopSoundOnEntity( player, "Switchback_Death_Splash_3P" )

	StopSoundOnEntity( player, "Switchback_Death_TitanSplash_1P" )
	StopSoundOnEntity( player, "Switchback_Death_TitanSplash_3P" )
}

function AOETrap_DamagedPlayerOrNPC( ent, damageInfo )
{
	if ( !IsAlive( ent ) || !ent.IsPlayer() )
		return

	local currentTime = Time()
	if ( !( "nextSmokeSoundTime" in ent.s ) )
		ent.s.nextSmokeSoundTime <- currentTime

	if ( ent.s.nextSmokeSoundTime <= currentTime )
	{
		if ( ent.IsPlayer() )
		{
			if ( ent.IsTitan() )
				EmitSoundOnEntityOnlyToPlayer( ent, ent, ELECTRIC_SMOKESCREEN_SFX_DAMAGE_1P_Titan )
			else
				EmitSoundOnEntityOnlyToPlayer( ent, ent, ELECTRIC_SMOKESCREEN_SFX_DAMAGE_1P_Pilot )
		}

		ent.s.nextSmokeSoundTime = currentTime + RandomFloat( 0.4, 0.9 )
	}
}

function AOETriggerModelInit( ent )
{
	if ( IsValid( ent ) )
		ent.s.IsAOETrigger <- true
}

function PropDynamicDamaged( prop, damageInfo )
{
	if ( !IsValid( prop ) )
		return

	if ( !( "IsAOETrigger" in prop.s ) )
		return

	local attacker = damageInfo.GetAttacker()
	if ( !IsValid( attacker ) || !IsPlayer( attacker ) || !IsAlive( attacker ) )
		return

	thread AOEElectricalPanelDamaged( attacker )
}

function AOEElectricalPanelDamaged( attacker )
{
	local arGlowModel = GetEnt( "prop_ar_glow" )

	if ( level.AOETrapEnabled )
	{
		level.AOETrapEnabled = false
		arGlowModel.DisableDraw()

		level.nv.aoeTrapStartTime = Time()
		level.AOETrapAttacker = attacker

		EmitSoundAtPosition( Vector( -47.0, -656.0, 616.0 ), "Switchback_Terminal_Activate" )
		thread AOETrapFire( Time() )

		wait( level.AOETrapResetTime )

		level.AOETrapEnabled = true
		arGlowModel.EnableDraw()
	}
}

function AOETrapFire( startTime )
{
	if ( IsValid( level.AOETrapAttacker ) )
		ForcePlayConversationToPlayer( "aoe_trap_shot", level.AOETrapAttacker )

	local trigger = GetEnt( "trigger_aoe_smoke_damage_1" )
	local touchingEnts = trigger.GetTouchingEntities()
	foreach ( ent in touchingEnts )
	{
		if ( ent.IsPlayer() )
			ForcePlayConversationToPlayer( "aoe_trap_shot", ent )
	}

	local arcDelay = level.AOEArcDuration / 12.0
	local initialDelay = 0.25

	local count = 0

	for ( local i = 1; i <= 12; i++ )
	{
		while ( Time() <= startTime + initialDelay + arcDelay * count )
			wait( 0.0 )
		AOEAddDamageTrigger( GetEnt( "trigger_aoe_elec_damage_" + i ), level.AOEArcFXLifetime, true )
		//DebugDrawBox( GetEnt( "trigger_aoe_elec_damage_" + i ).GetOrigin(), GetEnt( "trigger_aoe_elec_damage_" + i ).GetBoundingMins(), GetEnt( "trigger_aoe_elec_damage_" + i ).GetBoundingMaxs(), 255, 255, 0, 1, level.AOEArcFXLifetime )

		count++
	}

	wait( arcDelay )

	AOEAddDamageTrigger( GetEnt( "trigger_aoe_smoke_damage_1" ), level.AOESmokeDuration )
	//DebugDrawBox( GetEnt( "trigger_aoe_smoke_damage_1" ).GetOrigin(), GetEnt( "trigger_aoe_smoke_damage_1" ).GetBoundingMins(), GetEnt( "trigger_aoe_smoke_damage_1" ).GetBoundingMaxs(), 255, 255, 0, 1, level.AOESmokeDuration )

	local startTime = Time() - 2.05 - arcDelay
	foreach ( res in level.AOEResiduals )
	{
		while ( Time() < startTime + res.time )
			wait( 0.0 )

		AOEAddDamageTrigger( GetEnt( "trigger_aoe_elec_damage_" + ( res.index + 1 ) ), level.AOEArcFXLifetime, true )
		//DebugDrawBox( GetEnt( "trigger_aoe_elec_damage_" + ( res.index + 1 ) ).GetOrigin(), GetEnt( "trigger_aoe_elec_damage_" + ( res.index + 1 ) ).GetBoundingMins(), GetEnt( "trigger_aoe_elec_damage_" + ( res.index + 1 ) ).GetBoundingMaxs(), 255, 255, 0, 1, level.AOEArcFXLifetime )
	}
}

function AOETriggerDamageEntered( self, activator, caller, value )
{
	if ( !IsValid( activator ) )
		return false

	if ( !activator.IsPlayer() && !activator.IsNPC() )
		return false

	if ( !( "damageTriggerCount" in activator.s ) )
		activator.s.damageTriggerCount <- 0

	activator.s.damageTriggerCount++

	if ( IsValueInArray( level.AOETriggerDamagePlayers, activator ) )
		return false

	level.AOETriggerDamagePlayers.append( activator )
	return true
}

function AOETriggerDamageExited( self, activator, caller, value )
{
	if ( !IsValid( activator ) )
		return false

	if ( !activator.IsPlayer() && !activator.IsNPC() )
		return false

	activator.s.damageTriggerCount--

	if ( activator.s.damageTriggerCount > 0 )
		return false

	local index = GetIndexInArray( level.AOETriggerDamagePlayers, activator )
	if ( index < 0 )
		return false

	level.AOETriggerDamagePlayers.remove( index )
	return true
}

function AOETriggerInstantDamageEntered( self, activator, caller, value )
{
	if ( !AOETriggerDamageEntered( self, activator, caller, value ) )
		return

	if ( IsValueInArray( level.AOETriggerInstantDamagePlayers, activator ) )
		return false

	level.AOETriggerInstantDamagePlayers.append( activator )
}

function AOETriggerInstantDamageExited( self, activator, caller, value )
{
	if ( !AOETriggerDamageExited( self, activator, caller, value ) )
		return

	local index = GetIndexInArray( level.AOETriggerInstantDamagePlayers, activator )
	if ( index < 0 )
		return

	level.AOETriggerInstantDamagePlayers.remove( index )
}

function AOEAddDamageTrigger( trigger, time, instant = false )
{
	local endTime = Time() + time

	local index = GetIndexInArray( level.AOEActiveDamageTriggers, trigger )

	if ( index >= 0 )
	{
		if ( endTime <= trigger.s.damageEndTime )
			return
	}

	if ( !( "instant" in trigger.s ) )
		trigger.s.instant <- instant

	if ( !( "damageEndTime" in trigger.s ) )
		trigger.s.damageEndTime <- endTime
	else
		trigger.s.damageEndTime = endTime

	if ( index < 0 )
	{
		level.AOEActiveDamageTriggers.append( trigger )

		if ( !instant )
		{
			trigger.ConnectOutput( "OnStartTouch", AOETriggerDamageEntered )
			trigger.ConnectOutput( "OnEndTouch", AOETriggerDamageExited )

			local touchingEnts = trigger.GetTouchingEntities()
			foreach ( ent in touchingEnts )
				AOETriggerDamageEntered( trigger, ent, null, null )
		}
		else
		{
			trigger.ConnectOutput( "OnStartTouch", AOETriggerInstantDamageEntered )
			trigger.ConnectOutput( "OnEndTouch", AOETriggerInstantDamageExited )

			local touchingEnts = trigger.GetTouchingEntities()
			foreach ( ent in touchingEnts )
				AOETriggerInstantDamageEntered( trigger, ent, null, null )
		}
	}
}

function AOEDamageThread()
{
	local damage = 0.0
	local attacker = null
	local inflictor = null
	local time = -1.0
	local trigger = null
	local touchingEnts = null

	while ( true )
	{
		time = Time()

		for ( local i = 0; i < level.AOEActiveDamageTriggers.len(); i++ )
		{
			trigger = level.AOEActiveDamageTriggers[ i ]

			if ( time >= trigger.s.damageEndTime )
			{
				if ( !trigger.s.instant )
				{
					trigger.DisconnectOutput( "OnStartTouch", AOETriggerDamageEntered )
					trigger.DisconnectOutput( "OnEndTouch", AOETriggerDamageExited )
				}
				else
				{
					trigger.DisconnectOutput( "OnStartTouch", AOETriggerInstantDamageEntered )
					trigger.DisconnectOutput( "OnEndTouch", AOETriggerInstantDamageExited )
				}

				touchingEnts = trigger.GetTouchingEntities()
				foreach ( ent in touchingEnts )
					AOETriggerInstantDamageExited( trigger, ent, null, null )

				level.AOEActiveDamageTriggers.remove( i )

				i--
			}
		}

		foreach ( player in level.AOETriggerDamagePlayers )
		{
			if ( !IsValid( player ) )
				continue

			if ( player.IsTitan() )
			{
				damage = level.AOETitanDamage
			}
			else
			{
				local index = GetIndexInArray( level.AOETriggerInstantDamagePlayers, player )
				if ( index < 0 )
					damage = level.AOEPilotDamage
				else
					damage = level.AOEPilotInstantDamage
			}

			attacker = level.AOETrapAttacker
			inflictor = level.AOETrapAttacker

			if ( IsValid( attacker ) && player.GetTeam() == attacker.GetTeam() )
				attacker = GetEntByIndex( 0 ) // worldspawn

			player.TakeDamage( damage, attacker, inflictor, { scriptType = DF_INSTANT | DF_ELECTRICAL | DF_GIB, damageSourceId = eDamageSourceId.switchback_trap } )
		}
		wait( 0.1 )
	}
}

main()