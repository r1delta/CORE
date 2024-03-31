/*
map_settings_override 1
fog_enable 0
fog_enableskybox 0

map_settings_override 1; fog_enable 1; fog_enableskybox 1
map_settings_override 1; fog_enable 0; fog_enableskybox 0

*/

const LEVIATHAN_MODEL_SMALL			= "models/Creatures/leviathan/leviathan_swampland_small.mdl"
const LEVIATHAN_MODEL 				= "models/Creatures/leviathan/leviathan_brown_background.mdl"
const LEVIATHAN_SMALL_MODEL = "models/Creatures/leviathan/leviathan_brown_airbase_small.mdl"
const LEVIATHAN_MEDIUM_MODEL = "models/Creatures/leviathan/leviathan_brown_airbase_medium.mdl"
const LEVIATHAN_LARGE_MODEL = "models/Creatures/leviathan/leviathan_brown_airbase_large.mdl"

const RADAR_A_MODEL = "models/IMC_base/radar_a.mdl"
const RADAR_B_MODEL = "models/IMC_base/radar_b.mdl"
const RADAR_C_MODEL = "models/IMC_base/radar_c.mdl"
const RADAR_D_MODEL = "models/IMC_base/radar_d.mdl"
const RADAR_E_MODEL = "models/IMC_base/radar_e.mdl"
const RADAR_F_MODEL = "models/IMC_base/radar_f.mdl"
const RADAR_G_MODEL = "models/IMC_base/radar_g.mdl"
const RADAR_H_MODEL = "models/IMC_base/radar_h.mdl"
const RADAR_I_MODEL = "models/IMC_base/radar_i.mdl"

const TOWER_PULSE_FX = "P_dog_w_pulse_st_idle"
const FX_BIRD_BURST = "eject_bird_burst_omni"
const SND_BIRD_FLOCK = "AMB_Swampland_Emitter_Birdflock"

function main()
{
	if ( reloadingScripts )
		return

	PrecacheModel( LEVIATHAN_MODEL_SMALL )
	PrecacheModel( LEVIATHAN_MODEL ) // remove

	PrecacheModel( RADAR_A_MODEL )
	PrecacheModel( RADAR_B_MODEL )
	PrecacheModel( RADAR_C_MODEL )
	PrecacheModel( RADAR_D_MODEL )
	PrecacheModel( RADAR_E_MODEL )
	PrecacheModel( RADAR_F_MODEL )
	PrecacheModel( RADAR_G_MODEL )
	PrecacheModel( RADAR_H_MODEL )
	PrecacheModel( RADAR_I_MODEL )

	PrecacheParticleSystem( TOWER_PULSE_FX )
	PrecacheParticleSystem( FX_BIRD_BURST )

	AddSpawnCallback( "trigger_multiple", SetupBirdScareTrigger )

	IncludeFile( "_flyers_shared" )

	RegisterSignal( "EndFlyerPopulate" )

	FlagSet( "IntroDone" )

	AddTitanfallBlocker( Vector(-1659, -7915, -1000), 3000, 500 )
}

function EntitiesDidLoad()
{
	if ( EvacEnabled() )
		Swampland_EvacSetup()

	if ( GetBugReproNum() == 1970 )
	{
		Disable_IMC()
		Disable_MILITIA()
	}

	TowerInit()

	LeviathanRun()
	PerchedFlyerSetup()
	thread DropshipFlyerAttack()
}

// ==========================================
// --------------- EVAC STUFF ---------------
// ==========================================
function Swampland_EvacSetup()
{
	//local verticalAnims = Evac_CreateAnimPackage( "dropship_VTOL_evac_start", "dropship_VTOL_evac_idle", "dropship_VTOL_evac_end" )

	local spectatorNode1 = GetEnt( "spec_cam1" )
	local spectatorNode2 = GetEnt( "spec_cam2" )
	local spectatorNode3 = GetEnt( "spec_cam3" )
	local spectatorNode4 = GetEnt( "spec_cam4" )

	Evac_AddLocation( "evac_location1", spectatorNode1.GetOrigin(), spectatorNode1.GetAngles() )
	Evac_AddLocation( "evac_location2", spectatorNode2.GetOrigin(), spectatorNode2.GetAngles() ) //, verticalAnims )
	//Evac_AddLocation( "evac_location3", spectatorNode3.GetOrigin(), spectatorNode3.GetAngles() )
	Evac_AddLocation( "evac_location4", spectatorNode4.GetOrigin(), spectatorNode4.GetAngles() )

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

/*--------------------------------------------------------------------------------------------------------*\
|
|						 BIRDS
|
\*--------------------------------------------------------------------------------------------------------*/

function SetupBirdScareTrigger( trigger )
{
	local targetName = trigger.GetName()
	if ( targetName.find( "BirdScareTrigger" ) != 0 )
		return

	trigger.ConnectOutput( "OnStartTouch", BirdScareTriggerOnStartTouch )
}

function BirdScareTriggerOnStartTouch( trigger, entity, caller, value )
{
	if ( !IsValid( entity ) )
		return
	if ( !entity.IsPlayer() )
		return

//	DebugDrawSphere( entity.EyePosition(), 16, 0, 255, 0, 30.0 )

	local velocity = entity.GetVelocity()
	local zVelocity = velocity.z

	local offset = 250.0
	local timeBeforePeek = sqrt(( offset * 2 ) / 750 )

	local delay = zVelocity / 750 - timeBeforePeek

	if ( delay < 0 )
	{
		// printt( "Speed to low or some such", delay )
		return
	}

	thread BirdScarePlayFx( entity, delay )
}

function BirdScarePlayFx( player, delay )
{
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "Disconnected" )

	wait delay

	local origin = player.EyePosition()
	local angles = player.GetAngles()

//	DebugDrawSphere( origin, 32, 255, 0, 0, 30.0 )

	PlayFX( FX_BIRD_BURST, origin, angles )
	EmitSoundAtPositionOnlyToPlayer( origin, player, SND_BIRD_FLOCK )
}

/*--------------------------------------------------------------------------------------------------------*\
|
|						 LEVIATHANS
|
\*--------------------------------------------------------------------------------------------------------*/


function LeviathanRun()
{
	thread LeviathanSpawn( "cinematic_mp_node_us23", LEVIATHAN_MODEL_SMALL, "leviathan1" )
	thread LeviathanRepeat( "cinematic_mp_node_us0", LEVIATHAN_MODEL_SMALL, "leviathan2", true )
	delaythread( 75 ) LeviathanRepeat( "cinematic_mp_node_us4", LEVIATHAN_MODEL_SMALL, "leviathan3" )
}

function LeviathanSpawn( nodeName, model, name, funcShouldInterrupt = null, funcInterrupt = null )
{
	local node = GetNodeByUniqueID( nodeName )
	node.model <- model
	thread NodeDoMoment( node )

	Assert( "leviathan" in node )

	local leviathan = node.leviathan
	leviathan.s.interrupted <- false
	leviathan.s.pathNum <- 0
	leviathan.SetName( name )
	leviathan.s.Waits = 99
	leviathan.s.remove_at_path_end = true
	leviathan.s.walk_fast = false

	if ( funcShouldInterrupt != null && funcInterrupt != null )
	{
		leviathan.s.funcShouldInterrupt <- {}
		leviathan.s.funcShouldInterrupt.func	<- funcShouldInterrupt
		leviathan.s.funcShouldInterrupt.scope	<- this

		leviathan.s.funcInterrupt <- {}
		leviathan.s.funcInterrupt.func	<- funcInterrupt
		leviathan.s.funcInterrupt.scope	<- this

		SetLeviathanLevelFunc( leviathan, LeviathanInterrupt )
	}

	return leviathan
}

function LeviathanRepeat( nodeName, model, name, speed = false )
{
	local node = GetNodeByUniqueID( nodeName )

	while ( true )
	{
		node.model <- model
		thread NodeDoMoment( node )

		Assert( "leviathan" in node )

		local leviathan = node.leviathan
		leviathan.s.interrupted <- false
		leviathan.s.pathNum <- 0
		leviathan.SetName( name )
		leviathan.s.Waits = 99
		leviathan.s.remove_at_path_end = true
		leviathan.s.walk_fast = speed //CoinFlip()

		leviathan.WaitSignal( "OnDestroy" )
	}
}

/*--------------------------------------------------------------------------------------------------------*\
|
|						 FLYERS
|
\*--------------------------------------------------------------------------------------------------------*/
function DebugDrawPerchedFlyer()
{
	foreach( index, perch in level.perchNoLanding )
		AddPerchedFlyerByIndex( index, true )

	foreach( index, perch in level.perchLocations )
		AddPerchedFlyerByIndex( index, false )

//	AddPerchedFlyerByIndex( 1 )

//	FlagSet( "IntroDone" )

	local perchLocations = clone level.perchLocations
	perchLocations.extend( level.perchNoLanding )

	while( true )
	{
		foreach( index, locations in perchLocations )
		{
			local origin = locations.origin
			local vector = locations.angles.AnglesToForward()
			DebugDrawLine( origin, origin + vector * 256, 255, 0, 0, true, 1.0 )
			DebugDrawLine( origin, origin + Vector( 0,0,128), 255, 255, 0, true, 1.0 )
			if ( index < level.perchLocations.len() )
				DebugDrawText( origin + Vector( 0,0,128 ), index.tostring(), true, 1.0 )
			else
				DebugDrawText( origin + Vector( 0,0,128 ), (index - level.perchLocations.len()).tostring() + "NL", true, 1.0 )
		}
		wait 1
	}
}

function DropshipFlyerAttack()
{
	while( true )
	{
		wait 30
		local rnd = RandomInt( 100 )
		if ( rnd > 33 ) // 33% chance for s dropship to be attacked.
			continue

		NextDropshipAttackedByFlyers( RandomInt( 2, 4 ) ) // two or three flyers attack
	}
}

function PerchedFlyerSetup()
{

	local perchLocations = []
	local perchNoLanding = []

	// turn these into regular locations
	perchLocations.append( { origin = Vector( -1437.2, -5829.2, 58.0 ),		angles = Vector( 0, 90, 0 ) } )
	perchLocations.append( { origin = Vector( -3934.4, -5505.2, 904.0 ),	angles = Vector( 0, 60, 0 ), start = true } )
	perchLocations.append( { origin = Vector( -1767.5, -4761.1, 430.9 ),	angles = Vector( 0, 157, 0 ) } )
	perchLocations.append( { origin = Vector( -3600.6, -2949.1, 275.1 ),	angles = Vector( 0, -53, 0 ) } )
	perchLocations.append( { origin = Vector( -5229.9, -780.4, 1455.0 ),	angles = Vector( 0, -137, 0 ), start = true } )

	perchLocations.append( { origin = Vector( -8187.9, -923.7, 1765.4 ),	angles = Vector( 0, 83, 0 ) } )
	perchLocations.append( { origin = Vector( -7561.2, -808.8, 1584.6 ),	angles = Vector( 0, 45, 0 ), start = true } )
	perchLocations.append( { origin = Vector( -8239.7, 288.4, 1122.4 ),		angles = Vector( 0, -48, 0 ) } )
	perchLocations.append( { origin = Vector( -1896.7, 5080.8, 1369.5 ),	angles = Vector( 0, 101, 0 ), start = true } )
	perchLocations.append( { origin = Vector( -2045.5, -7055.4, 263.0 ),	angles = Vector( 0, -108, 0 ) } )

	perchLocations.append( { origin = Vector( -6010.7, -4648.3, 525.5 ),	angles = Vector( 0, 27, 0 ) } )
	perchLocations.append( { origin = Vector( -4098.0, -3745.1, 320.4 ),	angles = Vector( 0, -70, 0 ), start = true } )
	perchLocations.append( { origin = Vector( -2546.1, -5656.9, 61.0 ),		angles = Vector( 0, 111, 0 ) } )
	perchLocations.append( { origin = Vector( -3892.2, -6333.4, 126.2 ),	angles = Vector( 0, 19, 0 ) } )
	perchLocations.append( { origin = Vector( -2796.8, -3788.1, 253.2 ),	angles = Vector( 0, -156, 0 ), start = true } )

	perchLocations.append( { origin = Vector( -760.4, -5628.4, 592.7 ),		angles = Vector( 0, -178, 0 ) } )
	perchLocations.append( { origin = Vector( -1665.1, -4035.2, 430.9 ),	angles = Vector( 0, -23, 0 ) } )
	perchLocations.append( { origin = Vector( -5857.9, -925.2, 329.5 ),		angles = Vector( 0, 144, 0 ) } )
	perchLocations.append( { origin = Vector( -4412.4, -1271.4, 457.3 ),	angles = Vector( 0, -91, 0 ) } )
	perchLocations.append( { origin = Vector( -4791.8, -2518.4, 249.4 ),	angles = Vector( 0, 114, 0 ) } )

	// No landing, pre placment locations only
	perchNoLanding.append( { origin = Vector( -4732.0, 278.2, 662.1 ),		angles = Vector( 0, -136, 0 ) } )
	perchNoLanding.append( { origin = Vector( -2403.6, -2653.3, 588.2 ),	angles = Vector( 0, -179, 0 ) } )
	perchNoLanding.append( { origin = Vector( -1893.2, -2435.0, 486.0 ),	angles = Vector( 0, -90, 0 ) } )
	perchNoLanding.append( { origin = Vector( -790.3, -2188.6, 488.0 ),		angles = Vector( 0, -112, 0 ) } )
	perchNoLanding.append( { origin = Vector( -3870.2, -4019.1, 109.6 ),	angles = Vector( 0, 24, 0 ) } )

	perchNoLanding.append( { origin = Vector( -3489.4, 672.4, 478.5 ),		angles = Vector( 0, -167, 0 ) } )
	perchNoLanding.append( { origin = Vector( -4071.5, 1608.8, 964.0 ),		angles = Vector( 0, -148, 0 ) } )
	perchNoLanding.append( { origin = Vector( -6791.3, 445.6, 1215.8 ),		angles = Vector( 0, -95, 0 ) } )
	perchNoLanding.append( { origin = Vector( -2750.2, 2735.7, 1362.3 ),	angles = Vector( 0, -129, 0 ) } )
	perchNoLanding.append( { origin = Vector( -782.1, 1065.9, 442.0 ),		angles = Vector( 0, -1, 0 ) } )

	perchNoLanding.append( { origin = Vector( -1284.3, 2388.1, 269.8 ),		angles = Vector( 0, -125, 0 ) } )

	level.perchNoLanding <- perchNoLanding
	level.perchLocations <- perchLocations
	level.occupiedPerches <- {} // perch = flyer

	thread PerchedFlyerPopulate()
}

function PerchedFlyerPopulate()
{
	// stop populating when the match is over
	level.ent.EndSignal( "EndFlyerPopulate" )

	// indexes match a specific perch location in level.perchLocations or level.perchNoLanding
	foreach( index, perch in level.perchNoLanding )
	{
		AddPerchedFlyerByIndex( index, true )
		wait 0	// spreads a trace out over multiple frames
	}

	foreach( index, perch in level.perchLocations )
	{
		if ( "start" in perch )
		{
			AddPerchedFlyerByIndex( index )
			wait 0	// spreads a trace out over multiple frames
		}
	}

	FlagWait( "IntroDone" )

	local countStart = 10
	local countEnd = 10		// less flyers on mid and min spec machines

	while( true )
	{
		wait 5	// check every 5 seconds

		if ( level.nv.pulseImminent )
			continue

		// number of perching flyers increase as the match goes on.
		local count = GraphCapped( level.nv.matchProgress, 1, 100, countStart, countEnd ).tointeger()
		count = min( count, level.perchLocations.len() )
		// count = level.perchLocations.len()	// uncomment to populate all perches with flyers

		// remove perches from list where the flyer is invalid
		TableRemoveInvalidByValue( level.occupiedPerches )

		ArrayRandomize( level.perchLocations )

		local index = 0
		while ( level.occupiedPerches.len() < count && index < level.perchLocations.len() )
		{
			if ( level.nv.pulseImminent )
				break

			local perch = level.perchLocations[ index++ ]
			if ( perch in level.occupiedPerches || IsPlayerNear( perch.origin ) )
				continue

			local flyer = CreatePerchedFlyer( perch.origin, perch.angles )
			level.occupiedPerches[ perch ] <- flyer

			wait RandomFloat( 0, 5 )	// So that they don't all land at the same time.
		}
	}
}

function ScarePerchedFlyers()
{
	foreach ( flyer in level.occupiedPerches )
	{
		if ( IsValid( flyer ) )
			thread ScarePerchedFlyer( flyer )
	}
}

function ScarePerchedFlyer( flyer )
{
	flyer.EndSignal( "OnDestroy" )
	wait RandomFloat( 0.0, 1.5 )
	flyer.TakeDamage( 10, flyer, null, null ) // damage the flyers so that they fly away fast
}

function AddPerchedFlyerByIndex( index, noLanding = false )
{
	local perch
	if ( noLanding )
		perch = level.perchNoLanding[ index ]
	else
		perch = level.perchLocations[ index ]

	if ( perch in level.occupiedPerches )
		return null

	local flyer = CreatePerchedFlyer( perch.origin, perch.angles, !noLanding )
	level.occupiedPerches[ perch ] <- flyer

	return flyer
}

function IsPlayerNear( origin )
{
	local distSqr = 768 * 768
	local players = GetPlayerArray()
	foreach( player in players )
	{
		if ( DistanceSqr( player.GetOrigin(), origin ) < distSqr )
		{
			//printt( "player was near perch" )
			return true
		}
	}
	return false
}


/*--------------------------------------------------------------------------------------------------------*\
|
|						 TOWER
|
\*--------------------------------------------------------------------------------------------------------*/

function TowerInit()
{
	level.tower <- GetEnt( "prop_airbase_tower" )
	level.tower.SetName( "prop_airbase_tower_main" )

	Assert( level.tower )

	level.tower.s.falling <- false

	level.tower.s.tower_down <- false

	AddSignalAnimEvent( level.tower, "tower_down" )

	TowersReset()

	thread TowerPulse()
}

function TowersReset()
{
	thread PlayAnim( level.tower, "worker_base_whistle_tower_idle_new" )
	thread TowerMainSound()
}

function TowerMainSound()
{
	FlagWait( "IntroDone" )
	wait( 2.0 )
	EmitSoundOnEntity( level.tower, "airbase_scr_dogwhistle_idle" )
}

function TowerPulse()
{
	local mainTowerOrg = level.tower.GetOrigin() + Vector( 0.0, 0.0, 13365.0 )

	while ( true )
	{
		wait( 35.0 )
		level.nv.pulseImminent = true
		PlayFX( TOWER_PULSE_FX, mainTowerOrg )
		EmitSoundAtPosition( Vector( 438, -6354, 4604 ), "airbase_scr_dogwhistle_pulse" )

		ScarePerchedFlyers()

		wait( 3.0 )
		PlayFX( TOWER_PULSE_FX, mainTowerOrg )
		EmitSoundAtPosition( Vector( 438, -6354, 4604 ), "airbase_scr_dogwhistle_pulse" )

		wait( 5.0 )
		level.nv.pulseImminent = false
	}
}
main()