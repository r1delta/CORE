const FX_REDEYE_CRITICAL_HIT_EXPLOSION 	= "P_exp_redeye_med"
const FX_REDEYE_WARPIN 					= "veh_redeye_warp_in_FULL"
const FX_REDEYE_WARPOUT 				= "veh_redeye_warp_out_FULL"
const FX_CARRIER_WARPIN 				= "veh_carrier_warp_FULL"
const FX_CARRIER_WARPIN_GLOW 			= "veh_carrier_warp_in_mdl_glow"
const FX_CARRIER_WARPIN_WING 			= "car_warp_in_mdl_wing"
const FX_CARRIER_WARPOUT 				= "veh_carrier_warp_out_FULL"

const SFX_REDEYE_WARPIN					= "O2_Scr_RedeyeWarpIn"
const SFX_CARRIER_WARPIN				= "O2_Scr_MegaCarrierWarpIn"
const SFX_CARRIER_WARPOUT				= "O2_Scr_MegaCarrier_Warpout"
const SFX_REDEYE_WARPOUT				= "O2_Scr_Redeye_Warpout"
const SFX_REDEYE_CRIT_DAMAGE			= "O2_Redeye_CriticalDamage"

PrecacheParticleSystem( FX_REDEYE_CRITICAL_HIT_EXPLOSION )
PrecacheParticleSystem( FX_REDEYE_WARPIN )
PrecacheParticleSystem( FX_REDEYE_WARPOUT )
PrecacheParticleSystem( FX_CARRIER_WARPIN )
PrecacheParticleSystem( FX_CARRIER_WARPIN_GLOW )
PrecacheParticleSystem( FX_CARRIER_WARPIN_WING )
PrecacheParticleSystem( FX_CARRIER_WARPOUT )

PrecacheModel( FLEET_IMC_CARRIER )
PrecacheModel( FLEET_MCOR_REDEYE_1000X )
PrecacheModel( FLEET_MCOR_ANNAPOLIS_1000X )
PrecacheModel( FLEET_CAPITAL_SHIP_ARGO_1000X )
PrecacheModel( FLEET_MCOR_BIRMINGHAM_1000X )
PrecacheModel( FLEET_IMC_CARRIER_1000X )
PrecacheModel( FLEET_IMC_WALLACE_1000x )
PrecacheModel( FLEET_IMC_WALLACE_1000X_CLUSTERA )
PrecacheModel( FLEET_IMC_WALLACE_1000X_CLUSTERB )
PrecacheModel( FLEET_IMC_WALLACE_1000X_CLUSTERC )
PrecacheModel( FLEET_MCOR_ANNAPOLIS_1000X )
PrecacheModel( FLEET_CAPITAL_SHIP_ARGO_1000X )
PrecacheModel( FLEET_MCOR_BIRMINGHAM_1000X )
PrecacheModel( FLEET_IMC_CARRIER_1000X )
PrecacheModel( FLEET_IMC_WALLACE_1000x )
PrecacheModel( FLEET_IMC_WALLACE_1000X_CLUSTERA )
PrecacheModel( FLEET_IMC_WALLACE_1000X_CLUSTERB )
PrecacheModel( FLEET_IMC_WALLACE_1000X_CLUSTERC )
PrecacheModel( HORNET_MODEL )
PrecacheModel( CARRIER_MODEL )

function main()
{
	Globalize( O2_SkyShowMain )

	if ( !O2_DEV_DISABLE_SKYSHOW )
		FlagSet( "DogFights" )

	RegisterSignal( "redeye_explode" )
	RegisterSignal( "redeye_shifts_weight" )
	RegisterSignal( "new_preview" )
	RegisterSignal( "O2_StratonHornetDogfights" )
}

function O2_SkyShowMain()
{
	FlagInit( "MegaCarrierArrived" )

	if ( GetCinematicMode() )
		FlagWait( "IntroDone" )

	if ( !O2_DEV_DISABLE_SKYSHOW )
		thread SkyshowThink()
}

///////////////////////////////////////////////////////////////////////
//
//							INGAME ARMADA
//
///////////////////////////////////////////////////////////////////////
function SkyshowThink()
{
	level.redeye <- null
	level.carrier <- null
	local redeyePos = Vector( -3887.39, -10706.7, 5000 )
	local redeyeAngles = Vector( 0, 40, 0 )

	if ( !O2_DEV_DISABLE_SKYSHOW )
		thread O2_StratonHornetDogfights()

	FlagWait( "O2_Match45Percent" )
	RedeyeArrives( redeyePos, redeyeAngles )
	wait 1
	CarrierArrives()

	if ( !Flag( "O2_Match80Percent" ) )
		thread FirstRedeyeAndCarrierBattle()

	FlagWait( "O2_Match90Percent" )

	// Create a second redeye and another battle
	redeyePos = Vector( 14000, 4500, 5750 )
	redeyeAngles = Vector( 0, 45, 0 )
	RedeyeArrives( redeyePos, redeyeAngles)

	WaittillGameStateOrHigher( eGameState.Epilogue )

	level.redeye.Anim_Play( "hover_to_flight" )

	wait 4

	WarpOutShip( level.nv.megaCarrier, FX_CARRIER_WARPOUT, SFX_CARRIER_WARPOUT )
	level.nv.megaCarrier = null

	wait 2

	WarpOutShip( level.nv.redeye, FX_REDEYE_WARPOUT, SFX_REDEYE_WARPOUT )
	level.nv.redeye = null
}

function FirstRedeyeAndCarrierBattle()
{
	if ( level.devForcedWin )
		return

	level.ent.EndSignal( "devForcedWin" )
	level.redeye.EndSignal( "OnDestroy" )
	level.carrier.EndSignal( "OnDestroy" )
	FlagEnd( "O2_Match80Percent" )

	local halfAttackDuration = level.redeyeAttackDuration * 0.5
	local redeyeWarpPrepTime = 6

	level.redeye.MoveTo( level.redeye.GetOrigin() + level.redeye.GetForwardVector() * 20000, 75 )
	level.carrier.MoveTo( level.carrier.GetOrigin() + level.carrier.GetForwardVector() * 25000, 90 )
	level.carrier.RotateTo( level.carrier.GetAngles() + Vector( 0, -10, 0 ), halfAttackDuration )
	level.redeye.RotateTo( level.redeye.GetAngles() + Vector( 0, 10, 0 ), halfAttackDuration )

	wait halfAttackDuration

	level.carrier.RotateTo( level.carrier.GetAngles() + Vector( 0, 10, 0 ), halfAttackDuration )
	level.redeye.RotateTo( level.redeye.GetAngles() + Vector( 0, -10, 0 ), halfAttackDuration )

	local animPause = 2
	wait halfAttackDuration - animPause

	level.redeye.Anim_Play( "hover_to_flight" )

	wait animPause

	local attachIndex = level.redeye.LookupAttachment( "cell_bot2" )
	local fxOrigin = level.redeye.GetAttachmentOrigin( attachIndex )
	EmitSoundOnEntity( level.redeye, SFX_REDEYE_CRIT_DAMAGE )
	PlayFX( FX_REDEYE_CRITICAL_HIT_EXPLOSION, fxOrigin )
	level.redeye.RotateTo( level.redeye.GetAngles() + Vector( 0, 0, -5 ), 0.5 )
	wait 0.5
	level.redeye.RotateTo( level.redeye.GetAngles() + Vector( 0, 0, 5 ), 1 )
	wait 1

	attachIndex = level.redeye.LookupAttachment( "cell_bot3" )
	fxOrigin = level.redeye.GetAttachmentOrigin( attachIndex )
	EmitSoundOnEntity( level.redeye, SFX_REDEYE_CRIT_DAMAGE )
	PlayFX( FX_REDEYE_CRITICAL_HIT_EXPLOSION, fxOrigin )
	level.redeye.RotateTo( level.redeye.GetAngles() + Vector( 0, 0, -10 ), 0.5 )
	wait 0.5

	level.carrier.RotateTo( level.carrier.GetAngles() + Vector( 0, -45, 0 ), 90 )

	level.redeye.RotateTo( level.redeye.GetAngles() + Vector( 0, -30, 15 ), redeyeWarpPrepTime )
	wait redeyeWarpPrepTime
	WarpOutShip( level.nv.redeye, FX_REDEYE_WARPOUT, SFX_REDEYE_WARPOUT )
	level.nv.redeye = null
}

function RedeyeArrives( redeyePos, redeyeAngles )
{
	level.redeye = CreateAndWarpInShip( redeyePos, redeyeAngles, TEAM_MILITIA, FLEET_MCOR_REDEYE, FX_REDEYE_WARPIN )
	level.nv.redeye = level.redeye
	thread PlayAnim( level.redeye, "hover_idle" )
	EmitSoundOnEntity( level.redeye, SFX_REDEYE_WARPIN )
}

function CarrierArrives()
{
	local carrierPos = Vector( -10146.4, -5030.47, 9500 )
	local carrierAngles = Vector( 0, 40, 0 )

	level.carrier = CreateAndWarpInShip( carrierPos, carrierAngles, TEAM_IMC, FLEET_IMC_CARRIER, FX_CARRIER_WARPIN )
	level.nv.megaCarrier = level.carrier

	thread PlayAnim( level.carrier, "ca_hover_relative_Idle" )
	EmitSoundOnEntity( level.carrier, SFX_CARRIER_WARPIN )

	// Play carrier warpin glow & wing FX
	local attachWarp 		= level.carrier.LookupAttachment( "warp_center" )
	local attachWingFrontL 	= level.carrier.LookupAttachment( "carrier_wing_front_L" )
	local attachWingFrontR 	= level.carrier.LookupAttachment( "carrier_wing_front_R" )
	local attachWingBackL 	= level.carrier.LookupAttachment( "carrier_wing_Back_L" )
	local attachWingBackR 	= level.carrier.LookupAttachment( "carrier_wing_Back_R" )
	local warpOrigin 		= level.carrier.GetAttachmentOrigin( attachWarp )
	local warpAngles 		= level.carrier.GetAttachmentAngles( attachWarp )
	local wingFrontLOrigin 	= level.carrier.GetAttachmentOrigin( attachWingFrontL )
	local wingFrontLAngles 	= level.carrier.GetAttachmentAngles( attachWingFrontL )
	local wingFrontROrigin 	= level.carrier.GetAttachmentOrigin( attachWingFrontR )
	local wingFrontRAngles 	= level.carrier.GetAttachmentAngles( attachWingFrontR )
	local wingBackLOrigin 	= level.carrier.GetAttachmentOrigin( attachWingBackL )
	local wingBackLAngles 	= level.carrier.GetAttachmentAngles( attachWingBackL )
	local wingBackROrigin 	= level.carrier.GetAttachmentOrigin( attachWingBackR )
	local wingBackRAngles 	= level.carrier.GetAttachmentAngles( attachWingBackR )

	PlayFX( FX_CARRIER_WARPIN_GLOW, warpOrigin, 		warpAngles )
	PlayFX( FX_CARRIER_WARPIN_WING, wingFrontLOrigin, 	wingFrontLAngles )
	PlayFX( FX_CARRIER_WARPIN_WING, wingFrontROrigin, 	wingFrontRAngles )
	PlayFX( FX_CARRIER_WARPIN_WING, wingBackLOrigin, 	wingBackLAngles )
	PlayFX( FX_CARRIER_WARPIN_WING, wingBackROrigin, 	wingBackRAngles )
}

function CreateAndWarpInShip( spawnPos, spawnAngles, team, model, fx )
{
	local fx = PlayFX( fx, spawnPos, spawnAngles )
	fx.EnableRenderAlways()

	wait 0.8

	local ship = CreatePropDynamic( model, spawnPos, spawnAngles );
	ship.EnableRenderAlways()
	ship.SetTeam( team )

	return ship
}

function WarpOutShip( ship, fx, soundalias )
{
	if ( !IsValid( ship ) )
		return

	local origin = ship.GetOrigin()
	local angles = ship.GetAngles()
	EmitSoundAtPosition( origin, soundalias )

	thread PlayFX( fx, origin, angles )
	wait 0 // otherwise ship pops out of existance
	ship.Kill()
}

function O2_StratonHornetDogfights()
{
	level.ent.Signal( "O2_StratonHornetDogfights" )
	level.ent.EndSignal( "O2_StratonHornetDogfights" )

	if ( GetCinematicMode() && GameRules.GetGameMode() == CAPTURE_POINT )
		FlagWait( "IntroDone" )

	local minDelay = 5
	local maxDelay = 10

	// Optimization
	if( GetCPULevel() != CPU_LEVEL_HIGHEND )
	{
		minDelay = 15
		maxDelay = 25
	}

	for ( ;; )
	{
		local yaw = RandomInt( 360 )
		thread SpawnRandomDogFight( yaw )

		wait RandomFloat( minDelay, maxDelay )
	}
}
