const FX_CARRIER_WARPIN = "veh_carrier_warp_FULL_ground"
const FX_CARRIER_WARPOUT = "veh_carrier_warp_out_FULL"
const FX_ENV_GLASS_BREAK_64x48 = "env_glass_exp_64x48"
const MATCH_PROGRESS_MEGACARRIER_ARRIVES = 30
const FX_EXP_BIRM_SML = "p_exp_redeye_sml"
const ROCKET_MODEL = "models/weapons/bullets/projectile_rocket.mdl"

PrecacheParticleSystem( FX_CARRIER_WARPIN )
PrecacheParticleSystem( FX_CARRIER_WARPOUT )
PrecacheParticleSystem( FX_ENV_GLASS_BREAK_64x48 )
PrecacheParticleSystem( FX_EXP_BIRM_SML )
PrecacheModel( ROCKET_MODEL )

function main()
{
	Assert( IsServer() )
	if ( reloadingScripts )
		return

	Globalize( AddMegaCarrier )
	Globalize( MegaCarrierArrival )
	Globalize( CarrierAttack )
	Globalize( DogFightsPreview )

	FlagInit( "MegaCarrierArrived" )
	FlagInit( "MegaCarrierEscapes" )
	FlagInit( "MegaCarrierMovesOverCity" )

	FlagSet( "StratonFlybys" ) // tells flightpath to bake these into the ain
	FlagSet( "DogFights" )

	PrecacheModel( "models/vehicle/imc_carrier/vehicle_imc_carrier.mdl" )
	PrecacheModel( "models/vehicle/space_cluster/birmingham_space_clusterA.mdl" )
	PrecacheModel( "models/vehicle/capital_ship_Birmingham/birmingham.mdl" )

	RegisterSignal( "new_preview" )
	//thread CarrierEscapeCheck()
}

function EntitiesDidLoad()
{
	//thread DeleteEntityChain( "mega_carrier" )

	// verify sky camera has not changed, since client script cant find it
	local skyCamera = GetEnt( SKYBOX )
	Assert( skyCamera.kv.scale.tofloat() == level.skyCameraScale, "Scale changed!" )
	local origin = skyCamera.GetOrigin()
	Assert( origin.x.tointeger() == level.skyCameraOrg.x.tointeger(), "Scale changed!" )
	Assert( origin.y.tointeger() == level.skyCameraOrg.y.tointeger(), "Scale changed!" )
	Assert( origin.z.tointeger() == level.skyCameraOrg.z.tointeger(), "Scale changed!" )


	level.carrierGlassFX <- GetEntArrayByNameWildCard_Expensive( "mega_carrier_glass_fx*" )

	if ( !Flag( "CinematicIntro" ) )
		return

	RegisterServerVarChangeCallback( "matchProgress", MatchProgressChanged )


	FlagWait( "GamePlaying" )

}

function DeleteEntityChain( name )
{
	// make refs out of the carrier prop "animation" in leveled
	local carrier = GetEnt( name )
	local handled = {}

	for ( ;; )
	{
		if ( carrier in handled )
			break

		handled[ carrier ] <- true

		local target = carrier.GetTarget()
		if ( target == "" )
			break

		carrier = GetEnt( target )
	}

	foreach ( ent, _ in clone handled )
	{
		ent.Kill()
	}
}


function MatchProgressChanged()
{
	if ( level.nv.matchProgress < MATCH_PROGRESS_MEGACARRIER_ARRIVES )
		return

	if ( IsValid( level.nv.megaCarrier ) )
		return

	thread MegaCarrierArrival()
}

function MegaCarrierArrival()
{
	// already there? from dev perhaps
	if ( IsValid( level.nv.megaCarrier ) )
	{
		level.nv.megaCarrier.Kill()
	}

	thread AddMegaCarrier()
}



function CreateMegaCarrier( flyIn = true )
{
	//local carrier = CreateEntity( "npc_dropship" )
	////carrier.kv.spawnflags = 0
	//carrier.kv.vehiclescript = "scripts/vehicles/airvehicle_default.txt"
	//carrier.kv.teamnumber = TEAM_IMC
	//carrier.SetModel( CARRIER_MODEL )
	//carrier.SetOrigin( origin )
	//carrier.SetAngles( angles )
	//DispatchSpawn( hornet, true )
    //
	//carrier.SetInvulnerable()
	//carrier.SetAimAssistAllowed( false )

	local carrier = CreatePropDynamic( CARRIER_MODEL, Vector(0,0,0), Vector(0,0,0) )

	if ( flyIn )
		EmitSoundOnEntity( carrier, "AngelCity_Scr_MegaCarrierWarpIn" )

	carrier.Hide()
	level.nv.megaCarrier = carrier

	carrier.EndSignal( "OnDestroy" )
	carrier.s.inFlight <- true

	local anim = "ca_hover_Above_City_warpin"
	thread PlayAnimTeleport( carrier, anim, Vector(0,0,0), Vector(0,0,0) )
	WaitEndFrame() // even with a play anim teleport, need to wait before model will be actually in the right place.

	local origin = carrier.GetOrigin()
	local angles = carrier.GetAngles()

	if ( flyIn )
	{
		wait 3.9
		wait 1.5 // imc vdu starts earlier
		waitthread CarrierWarpinEffect( "models/vehicle/imc_carrier/vehicle_imc_carrier.mdl", origin, angles )
	}

	carrier.EnableRenderAlways()
	carrier.Show()

	FlagSet( "MegaCarrierArrived" )

	/* WIP for VDU cam for megacarrier
    local handle = carrier.GetEncodedEHandle()
	local players = GetPlayerArray()
	foreach ( player in players )
	{
		Remote.CallFunction_Replay( player, "ServerCallback_EntityVDUCam", handle )
	}*/

	//thread MegaCarrierGlassBreak( origin )
	return carrier
}

function CarrierFliesOverCity( carrier )
{

	// break out on escape flag
	level.ent.EndSignal( "MegaCarrierEscapes" )
	if ( !level.devForcedWin ) //Only make it run around if we didn't make skip to the end via dev commands
	{
		waitthread PlayAnim( carrier, "ca_hover_above_city", Vector(0,0,0), Vector(0,0,0) )
	}
}

function AddMegaCarrier( flyIn = true )
{
	FlagClear( "MegaCarrierEscapes" )
	FlagClear( "MegaCarrierMovesOverCity" )
	if ( IsValid( level.nv.megaCarrier ) )
		level.nv.megaCarrier.Kill()

	local carrier = CreateMegaCarrier( flyIn )
	carrier.EndSignal( "OnDestroy" )

	carrier.Show()

	thread AnnounceMegaCarrierArrived()

	if ( flyIn )
		waitthread CarrierFliesOverCity( carrier )

	thread PlayAnim( carrier, "ca_hover_Above_City_Idle", Vector(0,0,0), Vector(0,0,0) )
	carrier.s.inFlight = false

	thread FightersBuzzLevel( carrier )
	thread AngelCityStratonHornetDogfights( carrier )

	for ( ;; )
	{
		waitthread WaittillCarrierMoves()

		if ( Flag( "MegaCarrierEscapes" ) )
		{
			EmitSoundOnEntity( carrier, "AngelCity_Scr_IMCLoss_MegaCarrierLeaves" )

			waitthread PlayAnim( carrier, "ca_hover_Above_City_Escape", Vector(0,0,0), Vector(0,0,0), 1.5 )

			local origin = carrier.GetOrigin()
			local angles = carrier.GetAngles()
			EmitSoundAtPosition( origin, "AngelCity_Scr_RedeyeWarpOut" )

			thread PlayFX( FX_CARRIER_WARPOUT, origin, angles )
			wait 0 // otherwise carrier pops out of existance
			carrier.Kill()
			return
		}
		else
		if ( Flag( "MegaCarrierMovesOverCity" ) )
		{
			FlagClear( "MegaCarrierMovesOverCity" )

			EmitSoundOnEntity( carrier, "AngelCity_Scr_IMCWin_MegaCarrierLeaves" )

			waitthread PlayAnim( carrier, "ca_hover_Above_City_win", Vector(0,0,0), Vector(0,0,0), 1.5 )
			thread PlayAnim( carrier, "ca_hover_Above_City_win_idle", Vector(0,0,0), Vector(0,0,0), 1.5 )
		}
	}
}

function WaittillCarrierMoves()
{
	level.ent.EndSignal( "MegaCarrierMovesOverCity" )
	FlagWait( "MegaCarrierEscapes" )
}

//function CarrierEscapeCheck()
//{
//	for ( ;; )
//	{
//		level.ent.WaitSignal( "GameStateChange" )
//
//		switch ( GetGameState() )
//		{
//			case eGameState.WinnerDetermined:
//			case eGameState.Epilogue:
//			case eGameState.Postmatch:
//				break
//		}
//	}
//
//	// flies away if militia win
//	if ( winningTeam != TEAM_MILITIA )
//		return
//
//	FlagSet( "MegaCarrierEscapes" )
//}

function AnnounceMegaCarrierArrived()
{
	if ( level.devForcedWin ) //Don't bother announcing the mega carrier if we skipped to the end
		return

	//Make the AI chatter about it sometime after it's arrived
	wait ( RandomFloat( 10.0, 20.0 ) )

	local players = GetPlayerArray()
	foreach ( player in players )
		TryFriendlyChatterToPlayer( player, "ai_announce_megacarrier" )
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

function MegaCarrierGlassBreak( origin )
{
	local fx = level.carrierGlassFX

	foreach ( node in fx )
	{
		local dist = DistanceSqr( origin, node.GetOrigin() )
		local time = ( dist * 0.00000002 ) - 0.1
		if ( time < 0 )
			time = 0

		delaythread( time ) PlaySoundOnEnt( node, "Breakable.MatGlass" )
		delaythread( time ) PlayFX( FX_ENV_GLASS_BREAK_64x48, node.GetOrigin(), node.GetAngles() + Vector( 90,0,0 ) )
	}
}


function FightersBuzzLevel(carrier )
{
	carrier.EndSignal( "OnDestroy" )

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

function AngelCityStratonHornetDogfights( carrier )
{
	level.ent.Signal( "new_preview" )
	level.ent.EndSignal( "new_preview" )
	carrier.EndSignal( "OnDestroy" )

	for ( ;; )
	{
		for ( local i = 0; i < 20; i++ )
		{
			local yaw = RandomInt( 360 )
			thread SpawnRandomDogFight( yaw )

			wait RandomFloat( 4, 6 )
		}

		wait 20

		for ( local i = 0; i < 20; i++ )
		{
			local yaw = RandomInt( 360 )
			thread SpawnRandomDogFight( yaw )

			wait RandomFloat( 8, 20 )
		}

		wait 40
	}
}


function DogFightsPreview()
{
	level.ent.Signal( "new_preview" )
	level.ent.EndSignal( "new_preview" )
	for ( ;; )
	{
		local yaw = RandomInt( 360 )
		thread SpawnRandomDogFight( yaw )
		wait 5
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

function CarrierAttack()
{
	local carrier = level.nv.megaCarrier
	if ( !IsValid( carrier ) )
		return

	local spawns = [
		Vector(14281,	 -11085, 1422),
		Vector(15723,	 -7710, 1691) ,
		Vector(15564,	 -3655, 1691) ,
		Vector(15291,	 -202, 1691)  ,
		Vector(15553,	 2740, 1691)  ,
		Vector(14831,	 13672, 1691) ,
		Vector(12606,	 15656, 1986) ,
		Vector(8130, 	-15354, 1349) ,
		Vector(12236,	 -15137, 1412)
	]

	local origin = Random( spawns ) + Vector(0,0,2000)

	local offset = GetTorpedoOffset( carrier, RandomInt( level.carrierTorpedoPoints.len() ) )
	local refOrigin = offset.refOrigin
	local pointAngles = offset.angles
	local pointOrigin = offset.origin

	if ( !LegalOrigin( refOrigin ) )
		return

	local vec = refOrigin - origin
	local angles = VectorToAngles( vec )

	local vehicle = SpawnHornet( origin, angles )
	vehicle.EndSignal( "OnDeath" )
	OnThreadEnd(
		function () : ( vehicle )
		{
			if ( IsValid( vehicle ) )
				vehicle.Kill()
		}
	)
	vehicle.Kill( 60 )
//	DebugDrawLine( origin, Vector(0,0,1500), 255, 255, 0, true, 30.0 )

	//local vec = origin - start
	//vec.Norm()
	//local shipAngles = VectorToAngles( vec )
	//vehicle.SetAngles( shipAngles )
	// fly to anim blend start point
	local anims = [ "ht_carrier_attack_1" ] // , "ht_carrier_launch_2", "ht_carrier_launch_3" ]
	local anim = Random( anims )

	local animStart = vehicle.Anim_GetStartForRefPoint( anim, refOrigin, pointAngles )
	printt( "reforg " + refOrigin )
	printt( "refang " + pointAngles )
	printt( "origin " + animStart.origin )
	if ( !LegalOrigin( animStart.origin ) )
	{
		return
	}

	//thread VehicleLineDebug( vehicle, animStart.origin )

	//local result = vehicle.Anim_GetAttachmentAtTime( anim, "ORIGIN", 0.0 )
	//local shipAngles = result.angle.AnglesCompose( angles )
	//vehicle.SetAngles( shipAngles )
	vehicle.FlyToPointToAnim( animStart.origin, anim )
	//DebugDrawLine( vehicle.GetOrigin(), animStart.origin, 0, 255, 0, true, 30.0 )

	// any other incoming fly commands will break him out of this sequence
	vehicle.WaitSignal( "OnArrived" )

	// dont hover while playing a scripted animation
//	vehicle.kv.isUsingHoverNoise = false

	// play anim
	waitthread PlayAnim( vehicle, anim, refOrigin, pointAngles, 0.5 )
	vehicle.Kill()
}

function VehicleLineDebug( vehicle, origin )
{
	vehicle.EndSignal( "OnArrived" )
	vehicle.EndSignal( "OnDeath" )

	for ( ;; )
	{
		DebugDrawLine( vehicle.GetOrigin(), origin, 255, 0, 0, true, 1.0 )
		wait 1
	}
}

function SpawnHornet( origin, angles )
{
	local hornet = CreateEntity( "npc_dropship" )
	//hornet.kv.spawnflags = 0
	hornet.kv.vehiclescript = "scripts/vehicles/airvehicle_default.txt"
	hornet.kv.teamnumber = TEAM_MILITIA
	hornet.SetModel( HORNET_MODEL )
	hornet.SetOrigin( origin )
	hornet.SetAngles( angles )
	DispatchSpawn( hornet, true )

	local hornet_health = 500
	hornet.SetHealth( hornet_health )
	hornet.SetMaxHealth( hornet_health )

	hornet.EnableRenderAlways()
	hornet.SetAimAssistAllowed( false )

	return hornet
}