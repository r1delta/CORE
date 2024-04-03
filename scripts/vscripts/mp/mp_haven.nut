const FX_CARRIER_WARPIN = "veh_carrier_warp_FULL"
const FX_CARRIER_WARPOUT = "veh_carrier_warp_out_FULL"

function main()
{
	if ( reloadingScripts )
		return

	PrecacheParticleSystem( FX_CARRIER_WARPIN )
	PrecacheParticleSystem( FX_CARRIER_WARPOUT )

	PrecacheModel( "models/vehicle/imc_carrier/vehicle_imc_carrier.mdl" )

	level.megaCarrier <- null

	level.progressFuncArray <- []
	RegisterServerVarChangeCallback( "matchProgress", MatchProgressUpdate )

	FlagSet( "DogFights" ) // tells flightpath to bake these into the ain

	GM_AddEndRoundFunc( EndRoundMain )
}

function EntitiesDidLoad()
{
	if ( GetBugReproNum() == 1970 )
	{
		Disable_IMC()
		Disable_MILITIA()
	}

	if ( EvacEnabled() )
		EvacSetup()

	AddProgressionFunc( 5, StratonHornetDogfights )
	AddProgressionFunc( 15, MegaCarrierLooping )
	AddProgressionFunc( 90, EndDogfights )
}


/***********************************************************
********************	  CARRIER		********************
************************************************************/
// copied and modified from mp_angel_city

function MegaCarrierLooping()
{
	FlagWait( "GamePlaying" )

	local carrierWarpPoints = []
	carrierWarpPoints.append( { origin = Vector(6000,-2000,250), angles = Vector(0,130,0) } )
	carrierWarpPoints.append( { origin = Vector(5500,1000,0), angles = Vector(0,180,0) } )
	carrierWarpPoints.append( { origin = Vector(10000,-10000,2000), angles = Vector(0,85,0) } )
	carrierWarpPoints.append( { origin = Vector(-16000,-5500,1000), angles = Vector(0,-65,0) } )

	local index = 0
	while( eGameState.Playing && level.nv.matchProgress < 90 )
	{
		if ( index == 0 )
			ArrayRandomize( carrierWarpPoints )

		waitthread AddMegaCarrier( true, carrierWarpPoints[ index ].origin, carrierWarpPoints[ index ].angles )
		local waitTime = RandomFloat( 20, 60 )
		wait waitTime

		index = ( index + 1 ) % carrierWarpPoints.len()
	}
}

function EndDogfights()
{
	Signal( level.ent, "StratonHornetDogfights" )
}

function AddMegaCarrier( flyIn = true, origin = Vector(0,0,0), angles = Vector(0,0,0) )
{
	if ( IsValid( level.megaCarrier ) )
	{
		level.megaCarrier.Kill()
		wait 0 // let the old megaCarrier have time to die
	}

	level.nv.megaCarrierSpawnTime = Time()

	local carrier = CreateMegaCarrier( flyIn, origin, angles )
	carrier.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ()
		{
			level.nv.megaCarrierSpawnTime = null
		}
	)

	carrier.Show()

	level.nv.megaCarrierSpawnTime

	if ( flyIn )
		waitthread CarrierFliesOverCity( carrier, origin, angles )

	thread PlayAnim( carrier, "ca_hover_Above_City_Idle", origin, angles )
	carrier.s.inFlight = false

	if ( level.nv.matchProgress > 75 )
	{
		EmitSoundOnEntity( carrier, "AngelCity_Scr_IMCLoss_MegaCarrierLeaves" )
		waitthread PlayAnim( carrier, "ca_hover_Above_City_Escape", origin, angles, 1.5 )
	}
	else
	{
		EmitSoundOnEntity( carrier, "Haven_Scr_CarrierWarpOut" )
		waitthread PlayAnim( carrier, "ca_hover_Above_City_win_short", origin, angles, 1.5 )
	}

	local origin = carrier.GetOrigin()
	local angles = carrier.GetAngles()

	EmitSoundAtPosition( origin, "AngelCity_Scr_RedeyeWarpOut" )

	thread PlayFX( FX_CARRIER_WARPOUT, origin, angles )
	wait 0 // otherwise carrier pops out of existance
	carrier.Kill()
}

function CreateMegaCarrier( flyIn, origin, angles )
{
	local carrier = CreatePropDynamic( CARRIER_MODEL, origin, angles )
	carrier.SetName( "megaCarrier" )

	if ( flyIn )
		EmitSoundOnEntity( carrier, "AngelCity_Scr_MegaCarrierWarpIn" )

	carrier.Hide()
	level.megaCarrier = carrier

	carrier.EndSignal( "OnDestroy" )
	carrier.s.inFlight <- true

	local anim = "ca_hover_Above_City_warpin"
	thread PlayAnimTeleport( carrier, anim, origin, angles )
	WaitEndFrame() // even with a play anim teleport, need to wait before model will be actually in the right place.

	origin = carrier.GetOrigin()
	angles = carrier.GetAngles()

	if ( flyIn )
	{
		waitthread CarrierWarpinEffect( "models/vehicle/imc_carrier/vehicle_imc_carrier.mdl", origin, angles )
	}

	carrier.EnableRenderAlways()
	carrier.Show()

	return carrier
}

function CarrierWarpinEffect( model, origin, angles )
{
	local time = 0.54

	local totalTime = 2.0
	local preWait = 0
	//wait preWait
	EmitSoundAtPosition( origin, "dropship_warpin" )
	wait ( totalTime - preWait )
	local fx = PlayFX( FX_CARRIER_WARPIN, origin, angles )
	//DrawArrow( origin, angles, 10.0, 350 )
	fx.EnableRenderAlways()

	wait time
	wait 0.16
}

function CarrierFliesOverCity( carrier, origin, angles )
{
	if ( !level.devForcedWin ) //Only make it run around if we didn't make skip to the end via dev commands
	{
		waitthread PlayAnim( carrier, "ca_hover_above_city", origin, angles )
	}
}

/***********************************************************
********************	  DOG FIGHT		********************
************************************************************/

function FightersBuzzLevel()
{
	level.ent.Signal( "FightersBuzzLevel" )
	level.ent.EndSignal( "FightersBuzzLevel" )

	for ( ;; )
	{
		local yaw = RandomInt( 360 )

		local count = RandomInt( 2, 5 )
		for ( local i = 0; i < count; i++ )
		{
			thread SpawnRandomLowFlyingFighter( yaw )
			wait RandomFloat( 0.2, 1.0 )
		}

		wait RandomFloat( 15, 25 )
	}
}

function SpawnRandomLowFlyingFighter( yaw )
{
	local model
	if ( CoinFlip() )
		model = STRATON_MODEL
	else
		model = HORNET_MODEL

	local anim = STRATON_FLIGHT_ANIM
	local analysis = GetAnalysisForModel( STRATON_MODEL, anim ) // use straton for the analysis

	local drop = CreateCallinTable()
	drop.style = eDropStyle.RANDOM_FROM_YAW // spawn at a random node that points the right direction
	drop.yaw = yaw
 	local spawnPoint = GetSpawnPointForStyle( analysis, drop )
 	if ( !spawnPoint )
 		return

	local dropship = CreatePropDynamic( model, Vector(0,0,0), Vector(0,0,0) )
	waitthread PlayAnimTeleport( dropship, anim, spawnPoint.origin, spawnPoint.angles )
	dropship.Kill()
}


/***********************************************************
********************		EVAC		********************
************************************************************/

function EvacSetup()
{
	local spectatorNode1 = GetEnt( "spec_cam1" )
	local spectatorNode2 = GetEnt( "spec_cam2" )
	local spectatorNode3 = GetEnt( "spec_cam3" )

	local verticalAnims = Evac_CreateAnimPackage( "dropship_VTOL_evac_start", "dropship_VTOL_evac_idle", "dropship_VTOL_evac_end" )

	Evac_AddLocation( "evac_location1", spectatorNode1.GetOrigin(), spectatorNode1.GetAngles(), verticalAnims )
	Evac_AddLocation( "evac_location2", spectatorNode2.GetOrigin(), spectatorNode2.GetAngles(), verticalAnims )
	Evac_AddLocation( "evac_location3", spectatorNode3.GetOrigin(), spectatorNode3.GetAngles() )

	local spacenode = GetEnt( "spacenode" )

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

/***********************************************************
****************	   MATCH PROGRESS		****************
************************************************************/

function MatchProgressUpdate()
{
	thread MatchProgressUpdateThread( level.nv.matchProgress )
}

function MatchProgressUpdateThread( progression )
{
	if ( level.devForcedWin )  //Don't announce progress if we force win
		return

	foreach ( funcTable in level.progressFuncArray )
	{
		if ( funcTable.called && !funcTable.done )
			return	// this will stop anything later to run until the current update is done.

		if ( funcTable.done )
			continue

		if ( level.nv.matchProgress < funcTable.progress )
			continue

		if ( !funcTable.everyTime )
			funcTable.called = true

		if ( funcTable.threaded )
			thread funcTable.func()
		else
			waitthread funcTable.func()

		if ( !funcTable.everyTime )
			funcTable.done = true
	}
}

function AddProgressionFunc( progress, func, everyTime = false, threaded = true )
{
	local funcTable = {}
	funcTable.func			<- func
	funcTable.progress		<- progress
	funcTable.everyTime		<- everyTime
	funcTable.threaded		<- threaded
	funcTable.called		<- false
	funcTable.done			<- false


	level.progressFuncArray.append( funcTable )
}

function AdvanceProgression( team = TEAM_MILITIA )
{
	wait 0.5

	local maxScore  = GetScoreLimit_FromPlaylist()
	local teamScore = GameRules.GetTeamScore( team )
	local progress = level.nv.matchProgress

	local steps = []
	foreach( progressTable in level.progressFuncArray )
	{
		if ( !ArrayContains( steps, progressTable.progress ) )
			steps.append( progressTable.progress )
	}
	steps.sort( SortAlphabetize )

	foreach( step in steps )
	{
		if ( progress >= step )
			continue

		local goalScore = ceil( maxScore * ( step.tofloat() / 100.0 ) )
		AddTeamScore( team, goalScore - teamScore )
		return
	}
}

// bind z "script thread AdvanceProgression()"

main()