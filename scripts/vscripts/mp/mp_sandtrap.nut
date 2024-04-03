
const IMPACT_WATER_FX = "P_hmn_land_impact_water"
const IMPACT_WATER_TITAN_FX = "P_impact_dpod_water"

function main()
{
	FlagSet( "DogFights" ) // tells flightpath to bake these into the ain

	PrecacheEffect( IMPACT_WATER_FX )
	PrecacheEffect( IMPACT_WATER_TITAN_FX )

	AddSpawnFunction( "trigger_hurt", InitSubmergedTriggers )
	AddCallback_OnPlayerRespawned( PlayerRespawned )
}

function EntitiesDidLoad()
{
	if ( EvacEnabled() )
		EvacSetup()

	delaythread( CLASSIC_MP_SKYSHOW_DOGFIGHTS_DELAY ) StratonHornetDogfights()
}

// ==========================================
// --------------- EVAC STUFF ---------------
// ==========================================
function EvacSetup()
{
	local spectatorNode1 = GetEnt( "spec_cam1" )

	Evac_AddLocation( "evac_location1", spectatorNode1.GetOrigin(), spectatorNode1.GetAngles() )
	Evac_AddLocation( "evac_location2", spectatorNode1.GetOrigin(), spectatorNode1.GetAngles() )
	Evac_AddLocation( "evac_location3", spectatorNode1.GetOrigin(), spectatorNode1.GetAngles() )

	local spacenode = GetEnt( "spacenode" )
	Evac_SetSpaceNode( spacenode )

	Evac_SetupDefaultVDUs()

	GM_SetObserverFunc( EvacObserverFunc )
}

function EvacObserverFunc( player )
{
	player.SetObserverModeStaticPosition( level.ExtractLocations[ level.SelectedExtractLocationIndex ].spectatorPos )
	player.SetObserverModeStaticAngles( level.ExtractLocations[ level.SelectedExtractLocationIndex ].spectatorAng )

	player.StartObserverMode( OBS_MODE_CHASE )
	player.SetObserverTarget( null )
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
		waterSurfaceOrg.z = -1088.0

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

if ( !reloadingScripts )
	main()