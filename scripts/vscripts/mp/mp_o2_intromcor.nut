const FX_ROCKET = "Rocket_Smoke_Swirl_LG"
const CRASHTIME = 16.05//13.55 + 2.5
const R101_MODEL = "models/weapons/rspn101/r101_ab_01.mdl"

enum eHardpoint
{
	warehouse
	mainReactor
	marvinBay
}

const OGRE_ARM_MODEL = "models/Titans/ogre/ogre_titan_r_arm.mdl"
const WAKEUPTIME = 1.5

function main()
{
	FlagInit( "MCORJump" )
	FlagInit( "MilitiaWarped" )
	FlagInit( "MilitiaDDayGo" )
	FlagInit( "MILITIA_IntroDone" )
	FlagInit( "MCORCrashed" )
	FlagInit( "MCORwakeup" )
	FlagInit( "KillMCORShips" )
	FlagInit( "GateOpen" )

	Globalize( O2_IntroMCORMain )
	Globalize( DEV_MCORIntroWakeup )
	Globalize( DEV_MCORIntroCrash )

	RegisterSignal( "KillFunction" )
	RegisterSignal( "DEV_MCORIntroWakeup" )

	PrecacheModel( OGRE_ARM_MODEL )
	PrecacheModel( TEAM_MILITIA_CAPTAIN_MDL )
	PrecacheModel( R101_MODEL )
	PrecacheParticleSystem( FX_ROCKET )

	level.MCORSpaceOrigin <- Vector( -7000,0, -14500 )
	level.spears <- null
	level.DebugDrones <- 0
}

function O2_IntroMCORMain()
{
	IntroSetupMilitiaHero()
	thread IntroMilitia()
}

/************************************************************************************************\

 ######  ######## ######## ##     ## ########
##    ## ##          ##    ##     ## ##     ##
##       ##          ##    ##     ## ##     ##
 ######  ######      ##    ##     ## ########
      ## ##          ##    ##     ## ##
##    ## ##          ##    ##     ## ##
 ######  ########    ##     #######  ##

\************************************************************************************************/

function IntroSetupMilitiaHero()
{
	local offset = Vector( 200,-2700,-500 )
	//MCOR 1
	////////////////////////////////////////////////////////////
	local idleOrigin = level.MCORSpaceOrigin
	local idleAngles = Vector( 35,90,20 )

	local dropOrigin1 = GetEnt( "dropOrigin1" )
	local dropOrigin2 = GetEnt( "dropOrigin2" )

	local ddayAnimNode = GetEnt( "ddayAnimNode" )

	local create			= CreateCinematicDropship()
	create.origin 			= idleOrigin
	create.team				= TEAM_MILITIA
	create.count 			= 3
	create.side				= "frantic_crashSpin"

	local event1 			= CreateCinematicEvent()
	event1.origin 			= idleOrigin
	event1.angles			= idleAngles
	event1.anim				= "ds_space_scramble_dropshipA"
	event1.teleport 		= true
	event1.skycam			= SKYBOXSPACE
	Event_AddFlagWaitToEnd( event1, "MCORJump" )
	Event_AddClientStateFunc( event1, "CE_O2VisualSettingsSpaceMCOR" )
	Event_AddClientStateFunc( event1, "CE_02AirBurstEvents" )
	Event_AddServerStateFunc( event1, CE_PlayerSkyScaleSpace )
	Event_AddAnimStartFunc( event1, Bind( MCORHerosEvent1 ) )
	Event_AddAnimStartFunc( event1, IntroMCORSoundScapeStart )

	local event2 			= CreateCinematicEvent()
	event2.origin 			= ddayAnimNode.GetOrigin()
	event2.yaw				= ddayAnimNode.GetAngles().y
	event2.anim 			= "dropship_02_crash_right"
	event2.teleport 		= true
	event2.preAnimFPSWarp 	= true
	Event_AddFlagSetOnWarp( event2, "MilitiaWarped" )
	Event_AddFlagSetOnEnd( event2, "MCORCrashed" )
	Event_AddClientStateFunc( event2, "CE_O2VisualSettingsWorldMCOR" )
	Event_AddClientStateFunc( event2, "CE_O2BloomOnRampOpen" )
	Event_AddClientStateFunc( event2, "CE_O2BlackOut" )
	Event_AddClientStateFunc( event2, "CE_O2CrashVisual" )
	Event_AddClientStateFunc( event2, "CE_O2SmokePlumes" )
	Event_AddServerStateFunc( event2, CE_PlayerSkyScaleO2MCOR )
	Event_AddServerStateFunc( event2, CE_PlayerSkyScaleO2OnRampOpenMCOR )
	Event_AddAnimStartFunc( event2, Bind( MCORHerosEventCrashSpin ) )
	Event_AddAnimStartFunc( event2, IntroMCORSoundscapeCrashSpin )

	local event3 			= CreateCinematicEvent()
	event3.origin 			= ddayAnimNode.GetOrigin() + Vector( 0, 0, 4 )//hack not sure why I have to do this -> paul looked at maya file, everything looks fine, but its not
	event3.yaw				= ddayAnimNode.GetAngles().y
	event3.anim				= "dropship_o2_postCrash_left"
	event3.teleport 		= true
	Event_AddFlagWaitToStart( event3, "MCORwakeup" )
	Event_AddFlagWaitToEnd( event3, "KillMCORShips" )
	Event_AddClientStateFunc( event3, "CE_O2Wakeup" )
	Event_AddServerStateFunc( event3, CE_PlayerSkyScaleDefault )

	AddSavedDropEvent( "introDropShipMCOR_1cr", create )
	AddSavedDropEvent( "introDropShipMCOR_1e1", event1 )
	AddSavedDropEvent( "introDropShipMCOR_1e2", event2 )
	AddSavedDropEvent( "introDropShipMCOR_1e3", event3 )

	//MCOR 2
	////////////////////////////////////////////////////////////
	local create			= CreateCinematicDropship()
	create.origin 			= idleOrigin
	create.team				= TEAM_MILITIA
	create.count 			= 3
	create.side				= "frantic_crashRoll"

	local event1 			= CreateCinematicEvent()
	event1.origin 			= idleOrigin
	event1.angles			= idleAngles
	event1.anim				= "ds_space_scramble_dropshipB"
	event1.teleport 		= true
	event1.skycam			= SKYBOXSPACE
	Event_AddFlagWaitToEnd( event1, "MCORJump" )
	Event_AddClientStateFunc( event1, "CE_O2VisualSettingsSpaceMCOR" )
	Event_AddClientStateFunc( event1, "CE_02AirBurstEvents" )
	Event_AddServerStateFunc( event1, CE_PlayerSkyScaleSpace )
	Event_AddAnimStartFunc( event1, Bind( MCORHerosEvent1 ) )
	Event_AddAnimStartFunc( event1, IntroMCORSoundScapeStart )

	local event2 			= CreateCinematicEvent()
	event2.origin 			= ddayAnimNode.GetOrigin()
	event2.yaw				= ddayAnimNode.GetAngles().y
	event2.anim 			= "dropship_02_crash_left"
	event2.teleport 		= true
	event2.preAnimFPSWarp 	= true
	Event_AddFlagSetOnWarp( event2, "MilitiaWarped" )
	Event_AddFlagSetOnEnd( event2, "MCORCrashed" )
	Event_AddClientStateFunc( event2, "CE_O2VisualSettingsWorldMCOR" )
	Event_AddClientStateFunc( event2, "CE_O2BloomOnRampOpen" )
	Event_AddClientStateFunc( event2, "CE_O2BlackOut" )
	Event_AddClientStateFunc( event2, "CE_O2CrashVisual" )
	Event_AddClientStateFunc( event2, "CE_O2SmokePlumes" )
	Event_AddServerStateFunc( event2, CE_PlayerSkyScaleO2MCOR )
	Event_AddServerStateFunc( event2, CE_PlayerSkyScaleO2OnRampOpenMCOR )
	Event_AddAnimStartFunc( event2, Bind( MCORHerosEventCrashRoll ) )
	Event_AddAnimStartFunc( event2, IntroMCORSoundscapeCrashRoll )

	local event3 			= CreateCinematicEvent()
	event3.origin 			= ddayAnimNode.GetOrigin()
	event3.yaw				= ddayAnimNode.GetAngles().y
	event3.anim				= "dropship_o2_postCrash_right"
	event3.teleport 		= true
	Event_AddFlagWaitToStart( event3, "MCORwakeup" )
	Event_AddFlagWaitToEnd( event3, "KillMCORShips" )
	Event_AddClientStateFunc( event3, "CE_O2Wakeup" )
	Event_AddServerStateFunc( event3, CE_PlayerSkyScaleDefault )

	AddSavedDropEvent( "introDropShipMCOR_2cr", create )
	AddSavedDropEvent( "introDropShipMCOR_2e1", event1 )
	AddSavedDropEvent( "introDropShipMCOR_2e2", event2 )
	AddSavedDropEvent( "introDropShipMCOR_2e3", event3 )
}

function CE_PlayerSkyScaleO2MCOR( player, dropship )
{
	player.LerpSkyScale( SKYSCALE_O2_MCOR_PLAYER, 0.01 )
}

function CE_PlayerSkyScaleO2OnRampOpenMCOR( player, dropship )
{
	thread playerLerpSkyScaleOnSignal( player, dropship, "sRampOpen", SKYSCALE_O2_DOOROPEN_MCOR_PLAYER, 1.0 )
}

/************************************************************************************************\

##     ##    ###    #### ##    ##
###   ###   ## ##    ##  ###   ##
#### ####  ##   ##   ##  ####  ##
## ### ## ##     ##  ##  ## ## ##
##     ## #########  ##  ##  ####
##     ## ##     ##  ##  ##   ###
##     ## ##     ## #### ##    ##

\************************************************************************************************/

function IntroMilitia()
{
	FlagWait( "ReadyToStartMatch" )

	thread IntroMCORWorldRotate()
	thread IntroMCORSpaceShips()
	thread IntroMCORLanding()
	thread IntroMCORSkybox()

	local table 	= GetSavedDropEvent( "introDropShipMCOR_1cr" )
	local event1 	= GetSavedDropEvent( "introDropShipMCOR_1e1" )
	local event2 	= GetSavedDropEvent( "introDropShipMCOR_1e2" )
	local event3 	= GetSavedDropEvent( "introDropShipMCOR_1e3" )
	local dropship1 = SpawnCinematicDropship( table )
	thread RunCinematicDropship( dropship1, event1, event2, event3 )

	local table 	= GetSavedDropEvent( "introDropShipMCOR_2cr" )
	local event1 	= GetSavedDropEvent( "introDropShipMCOR_2e1" )
	local event2 	= GetSavedDropEvent( "introDropShipMCOR_2e2" )
	local event3 	= GetSavedDropEvent( "introDropShipMCOR_2e3" )
	local dropship2	= SpawnCinematicDropship( table )
	thread RunCinematicDropship( dropship2, event1, event2, event3 )

	thread DropshipMCORShakesSpin( dropship1 )
	thread DropshipMCORShakesRoll( dropship2 )
	thread IntroMCORCrashBurst( dropship1, dropship2, event2 )

	level.IntroRefs[ TEAM_MILITIA ].append( dropship1 )
	level.IntroRefs[ TEAM_MILITIA ].append( dropship2 )
	DebugSkipCinematicSlots( TEAM_MILITIA, 0 )
	//0 - front right
	//1 - back right
	//2 - front left

	dropship1.SetJetWakeFXEnabled( false )
	dropship2.SetJetWakeFXEnabled( false )

	delaythread( 22 ) FlagSet( "MCORJump" )

	IntroMilitiaDDayFlags( dropship1, dropship2 )
}

function IntroMilitiaDDayFlags( dropship1, dropship2 )
{
	FlagWait( "MilitiaWarped" )

	delaythread( CRASHTIME + WAKEUPTIME )FlagSet( "MilitiaDDayGo" )

	FlagWait( "MCORCrashed" )

	wait WAKEUPTIME

	FlagSet( "MCORwakeup" )

	wait 12
	DefensiveFreePlayers( dropship1 )
	DefensiveFreePlayers( dropship2 )
	FlagSet( "KillMCORShips" )
}

/************************************************************************************************\

######## ##       ##    ##    #### ##    ##
##       ##        ##  ##      ##  ###   ##
##       ##         ####       ##  ####  ##
######   ##          ##        ##  ## ## ##
##       ##          ##        ##  ##  ####
##       ##          ##        ##  ##   ###
##       ########    ##       #### ##    ##

\************************************************************************************************/
function DropshipMCORShakesSpin( dropship )
{
	waitthread DropshipMCORShakesCommon( dropship )

	/*wait 8.0

	//door open
	amplitude 	= 3.0
	frequency 	= 25
	duration 	= 3.0
	shake = CreateShake( dropship.GetOrigin(), amplitude, frequency, duration, radius )
	shake.SetParent( dropship, "ORIGIN" )

	wait duration - 0.5

	//min rumble with wind
	amplitude 	= 0.6
	frequency 	= 13
	duration 	= 11.25
	shake = CreateShake( dropship.GetOrigin(), amplitude, frequency, duration, radius )
	shake.SetParent( dropship, "ORIGIN" )*/
}
function DropshipMCORShakesRoll( dropship )
{
	waitthread DropshipMCORShakesCommon( dropship )
}

function DropshipMCORShakesCommon( dropship )
{
	dropship.EndSignal( "OnDeath" )

	local radius = 200
	local shake, amplitude, frequency, duration

	wait 1

	//min rumble
	amplitude 	= 0.5
	frequency 	= 10
	duration 	= 25.0
	shake = CreateShake( dropship.GetOrigin(), amplitude, frequency, duration, radius )
	shake.SetParent( dropship, "ORIGIN" )

	wait 17

	//build up to warp
	amplitude 	= 0.0
	frequency 	= 25
	duration 	= 1.0

	local max 	= 30
	local ramp 	= 0.25
	for( local i = 1; i <= max; i++ )
	{
		amplitude 	= ramp * i
		shake = CreateShake( dropship.GetOrigin(), amplitude, frequency, duration, radius )
		shake.SetParent( dropship, "ORIGIN" )

		wait 0.2
	}

	wait duration - 0.5

	//ramp down from warp
	amplitude 	= 5
	frequency 	= 25
	duration 	= 1.0
	shake = CreateShake( dropship.GetOrigin(), amplitude, frequency, duration, radius )
	shake.SetParent( dropship, "ORIGIN" )

	wait duration - 0.25

	//min rumble
	amplitude 	= 0.5
	frequency 	= 10
	duration 	= 20.0
	shake = CreateShake( dropship.GetOrigin(), amplitude, frequency, duration, radius )
	shake.SetParent( dropship, "ORIGIN" )
}

function IntroMCORCrashBurst( dropship1, dropship2, event )
{
	FlagWait( "MilitiaWarped" )

	local burstTime 	= CRASHTIME -8.75 //16.05 // 4.8

	IntroMCORCrashFireRockets( burstTime, event )

	wait burstTime
	local eHandle 	= dropship2.GetEncodedEHandle()

	local forward 	= 0
	local right 	= 250
	local up 		= 0
	CallFuncForAttachedPlayers( dropship1, "ServerCallback_O2CrashBurst", eHandle, 0, forward, right, up )

	local forward 	= 0
	local right 	= 250
	local up 		= -50
	CallFuncForAttachedPlayers( dropship2, "ServerCallback_O2CrashBurst", eHandle, 1, forward, right, up )
}

function IntroMCORCrashFireRockets( burstTime, event )
{
	local anim 		= event.anim
	local origin 	= event.origin
	local angles 	= Vector( 0, event.yaw, 0 )
	local dummy 	= CreatePropDynamic( DROPSHIP_MODEL, origin, angles )
	dummy.Hide()
	local result 	= dummy.Anim_GetAttachmentAtTime( anim, "R_exhaust_rear_1", burstTime )
	dummy.Kill()

	local baseDelay = 2.5
	//calculate the rocket that will hit
	local end 		= result.position + Vector( 200, 0, 0 )
	local offset	= Vector( 8000, 0, -3500 )
	local start 	= end + offset
	local delay 	= 2.0 + baseDelay
	local flyTime	= burstTime - delay

	delaythread( delay ) FireRocket( start, end, flyTime  )

	local delay 	= 0.6 + baseDelay
	local offset    = Vector( 1800, -400, -1200 )
	delaythread( delay ) FireRocket( start, CalculateMissRocket( start, end, offset ), flyTime * 2 )

	local delay 	= 1.0 + baseDelay
	local offset    = Vector( 1300, -200, -800 )
	delaythread( delay ) FireRocket( start, CalculateMissRocket( start, end, offset ), flyTime * 2 )

	local delay 	= 1.75 + baseDelay
	local offset    = Vector( 900, -700, -300 )
	delaythread( delay ) FireRocket( start, CalculateMissRocket( start, end, offset ), flyTime * 2 )
}

function CalculateMissRocket( start, end, offset )
{
	local endM 		= end + offset
	local delta 	= end - start
	endM += delta

	return endM
}

function FireRocket( start, end, time )
{
	// create the rocket
	local vec 		= start - end
	local rocket 	= CreateScriptMover( null, start, VectorToAngles( vec ) )
	local fx 		= PlayLoopFXOnEntity( FX_ROCKET, rocket, "REF" )

	OnThreadEnd(
		function () : ( fx, rocket )
		{
			if ( IsValid( fx ) )
			{
				StopFX( fx )
				fx.Kill()
			}

			if ( IsValid( rocket ) )
				rocket.Kill()
		}
	)

//	DebugDrawSphere( start, 128, 0, 255, 0, 20 )
//	DebugDrawSphere( end, 128, 255, 0, 0, 20 )
//	DebugDrawSphereOnTag( rocket, "REF", 32, 0, 0, 255, 20 )

	rocket.EndSignal( "OnDeath" )
	rocket.NonPhysicsMoveTo( end, time, 0, 0 )

	wait time
}

function IntroMCORSkybox()
{
	local worldSkybox = GetEnt( SKYBOXLEVEL )
	local ogAngles	= worldSkybox.GetAngles()

	//these angles look the best for the mcor flyin
	worldSkybox.SetAngles( Vector( 0,-18,0 ) )

	//wait for the guys screen to black out ( at this point the IMC is still in the space skybox, so they won't notice a pop )
	FlagWait( "MCORCrashed" )

	//now set the skybox angle back to what it should be for the game
	worldSkybox.SetAngles( ogAngles )
}

/************************************************************************************************\

 ######   #######  ##     ## ##    ## ########         ######   ######     ###    ########  ########
##    ## ##     ## ##     ## ###   ## ##     ##       ##    ## ##    ##   ## ##   ##     ## ##
##       ##     ## ##     ## ####  ## ##     ##       ##       ##        ##   ##  ##     ## ##
 ######  ##     ## ##     ## ## ## ## ##     ##        ######  ##       ##     ## ########  ######
      ## ##     ## ##     ## ##  #### ##     ##             ## ##       ######### ##        ##
##    ## ##     ## ##     ## ##   ### ##     ##       ##    ## ##    ## ##     ## ##        ##
 ######   #######   #######  ##    ## ########         ######   ######  ##     ## ##        ########

\************************************************************************************************/
function IntroMCORSoundScapeStart( dropship, ref, table )
{
	PlaySoundToAttachedPlayers( dropship, "O2_Scr_MilitiaIntro1_ShipAmb" )
}

function IntroMCORSoundscapeCrashSpin( dropship, ref, table )
{
	local otherShip = level.IntroRefs[ TEAM_MILITIA ][ 1 ]

	delaythread( 6.4 ) PlaySoundToAttachedPlayersOnEnt( dropship, otherShip, "O2_Scr_MilitiaIntro1_RocketsByHitShip" )
	delaythread( 11.2 ) PlaySoundToAttachedPlayers( dropship, "O2_Scr_MilitiaIntro1_ShipGoesDown" )
}

function IntroMCORSoundscapeCrashRoll( dropship, ref, table )
{
	local otherShip = level.IntroRefs[ TEAM_MILITIA ][ 1 ]

	delaythread( 6.4 ) PlaySoundToAttachedPlayersOnEnt( dropship, otherShip, "O2_Scr_MilitiaIntro2_RocketsBy" )
	delaythread( 7.4 ) PlaySoundToAttachedPlayers( dropship, "O2_Scr_MilitiaIntro2_ShipHitByRocket" )
	delaythread( 11.2 ) PlaySoundToAttachedPlayers( dropship, "O2_Scr_MilitiaIntro1_ShipGoesDown" )
}

/************************************************************************************************\

##    ## ########   ######     ######## ##       ##    ## #### ##    ##     ######  ######## ##     ## ######## ########
###   ## ##     ## ##    ##    ##       ##        ##  ##   ##  ###   ##    ##    ##    ##    ##     ## ##       ##
####  ## ##     ## ##          ##       ##         ####    ##  ####  ##    ##          ##    ##     ## ##       ##
## ## ## ########  ##          ######   ##          ##     ##  ## ## ##     ######     ##    ##     ## ######   ######
##  #### ##        ##          ##       ##          ##     ##  ##  ####          ##    ##    ##     ## ##       ##
##   ### ##        ##    ##    ##       ##          ##     ##  ##   ###    ##    ##    ##    ##     ## ##       ##
##    ## ##         ######     ##       ########    ##    #### ##    ##     ######     ##     #######  ##       ##

\************************************************************************************************/
function MCORHerosEvent1( dropship, ref, table )
{
	dropship.EndSignal( "OnDeath" )

	MCORHerosEventSetup( dropship, ref, table )

	local back 	= dropship.s.children.back
	local pilot = dropship.s.children.pilot
	local grunt = dropship.s.children.grunt

	foreach( obj in dropship.s.children )
	{
		obj.SetTeam( TEAM_MILITIA )
		obj.LerpSkyScale( SKYSCALE_SPACE, 0.01 )
	}

	thread PlayAnimTeleport( back, "Militia_O2_flyinA_crew_back", dropship, "ORIGIN" )
	thread PlayAnimTeleport( pilot, "MCOR_02_flyin_part1_pilot", dropship, "ORIGIN" )
	thread PlayAnimTeleport( grunt, "Militia_O2_flyinA_playlerC", dropship, "ORIGIN" )

	delaythread( 1 ) MCORTempDilaog1a( back, pilot, dropship )
	delaythread( 13 ) MCORTempDilaog1b( back, pilot, dropship )
}

function MCORHerosEventSetup( dropship, ref, table )
{
	local back 	= CreatePropDynamic( TEAM_MILITIA_CAPTAIN_MDL )
	local grunt = CreatePropDynamic( MILITIA_MALE_BR )//fake pilot
	local pilot = CreatePropDynamic( PILOT_MODEL )
	local weapon = CreatePropDynamic( R101_MODEL )

	dropship.s.children <- {}
	dropship.s.children.back 	<- back
	dropship.s.children.pilot 	<- pilot
	dropship.s.children.grunt 	<- grunt
	dropship.s.children.weapon 	<- weapon

	back.SetParent( dropship, "ORIGIN" )
	grunt.SetParent( dropship, "ORIGIN" )
	pilot.SetParent( dropship, "ORIGIN" )
	weapon.SetParent( grunt, "PROPGUN")

	back.MarkAsNonMovingAttachment()
	grunt.MarkAsNonMovingAttachment()
	pilot.MarkAsNonMovingAttachment()
	weapon.MarkAsNonMovingAttachment()
}

function MCORHerosEventCrashSpin( dropship, ref, table )
{
	thread MCORTempDialogue2spin( dropship )
	thread MCORTempDialogue2Common( dropship )
	thread MCORTempDialogue2MacAllan( dropship )

	MCORHerosEventCrashCommon( dropship, ref, table, "pt_o2_Militia_suckedOut_right", "MCOR_02_flyin_part2_pilot", "pt_o2_Militia_crashD" )
}

function MCORHerosEventCrashRoll( dropship, ref, table )
{
	thread MCORTempDialogue2roll( dropship )
	thread MCORTempDialogue2Common( dropship )
	thread MCORTempDialogue2MacAllan( dropship )

	MCORHerosEventCrashCommon( dropship, ref, table, "pt_o2_Militia_suckedOut_left", "MCOR_02_flyin_part2_pilot", "pt_o2_Militia_crashH" )
}

function MCORHerosEventCrashCommon( dropship, ref, table, backAnim, pilotAnim, gruntAnim )
{
	local back 	= dropship.s.children.back
	local pilot = dropship.s.children.pilot
	local grunt = dropship.s.children.grunt

	if ( !IsValid( back ) || !IsValid( pilot ) || !IsValid( dropship ) )
		return

	back.EndSignal( "OnDeath" )
	pilot.EndSignal( "OnDeath" )
	dropship.EndSignal( "OnDeath" )

	thread PlayAnim( back, 	backAnim, dropship, "ORIGIN" )
	thread PlayAnim( pilot,	pilotAnim, dropship, "ORIGIN" )
	thread PlayAnim( grunt,	gruntAnim, dropship, "ORIGIN" )

	FlagWait( "MilitiaWarped" )

	foreach( obj in dropship.s.children )
		obj.LerpSkyScale( SKYSCALE_O2_MCOR_ACTOR, 0.01 )

	dropship.WaitSignal( "sRampOpen" )

	foreach( obj in dropship.s.children )
		obj.LerpSkyScale( SKYSCALE_O2_DOOROPEN_MCOR_ACTOR, 1.0 )
}

function MCORTempDilaog1a( back, pilot, dropship )
{
	if ( !IsValid( back ) || !IsValid( pilot ) || !IsValid( dropship ) )
		return

	back.EndSignal( "OnDeath" )
	pilot.EndSignal( "OnDeath" )
	dropship.EndSignal( "OnDeath" )

	wait 4
	//Pilot: Brace for impact!
	EmitSoundOnEntity( pilot, "diag_cmp_o2_mcor_fltofficer1_dsIntro_01_3" )

	wait 1.5
	//Mac: Everyone, hold on!
	EmitSoundOnEntity( back, "diag_cmp_o2_mcor_crewchief_dsIntro_01_4" )

}

function MCORTempDilaog1b( back, pilot, dropship )
{
	if ( !IsValid( back ) || !IsValid( pilot ) || !IsValid( dropship ) )
		return

	back.EndSignal( "OnDeath" )
	pilot.EndSignal( "OnDeath" )
	dropship.EndSignal( "OnDeath" )

	//Co-Pilot: Hard right!
	EmitSoundOnEntity( pilot, "diag_cmp_o2_mcor_flt01_dsIntro_01_6" )

	wait 2.0
	//Mac: Wilson, Get us the hell out of here!
	EmitSoundOnEntity( back, "diag_cmp_o2_mcor_crewchief_dsIntro_01_8" )

	wait 1.5
	//Pilot: Sir, jump calculations haven't finished yet. We might not...
	EmitSoundOnEntity( pilot, "diag_cmp_o2_mcor_fltofficer1_dsIntro_01_9" )

	wait 2.0
	//Mac: I don't give a damn, just do it! Jump now! Now dammit! Now!
	EmitSoundOnEntity( back, "diag_cmp_o2_mcor_crewchief_dsIntro_01_10" )

	wait 3.5
	//Pilot: Jumping in 3! 2! 1! Mark!
	EmitSoundOnEntity( pilot, "diag_cmp_o2_mcor_fltofficer1_dsIntro_01_11" )
}

function MCORTempDialogue2spin( dropship )
{
	local pilot 	= dropship.s.children.pilot
	local grunt 	= dropship.s.children.grunt
	if ( !IsValid( pilot ) || !IsValid( dropship ) )
		return

	pilot.EndSignal( "OnDeath" )
	dropship.EndSignal( "OnDeath" )

	wait CRASHTIME - 4.3//16.05//11.75

	//Mayday! Mayday!
	PlaySoundToAttachedPlayersOnEnt( dropship, pilot, "diag_matchIntro_o2302_08_01_mcor_flt01" )
}

function MCORTempDialogue2roll( dropship )
{
	local pilot 	= dropship.s.children.pilot
	local grunt 	= dropship.s.children.grunt
	if ( !IsValid( pilot ) || !IsValid( dropship ) )
		return

	pilot.EndSignal( "OnDeath" )
	dropship.EndSignal( "OnDeath" )

	wait CRASHTIME - 7.05 //16.05//9.0

	//Mayday mayday this is Misfit 2!
	PlaySoundToAttachedPlayersOnEnt( dropship, pilot, "diag_matchIntro_o2302_05_01_mcor_flt01" )
	wait 2.5

	//We're goin' down! I repeat, we're goin' down!
	PlaySoundToAttachedPlayersOnEnt( dropship, pilot, "diag_matchIntro_o2302_06_01_mcor_flt01" )
}

function MCORTempDialogue2Common( dropship )
{
	local pilot 	= dropship.s.children.pilot
	if ( !IsValid( pilot ) || !IsValid( dropship ) )
		return

	pilot.EndSignal( "OnDeath" )
	dropship.EndSignal( "OnDeath" )

	wait CRASHTIME - 8.05 //16.05 //8.0
	//Impact warning. Impact warning.
	PlaySoundToAttachedPlayersOnEnt( dropship, pilot, "diag_matchIntro_o2303_01_01_mcor_cpu01" )

	wait 4.0
	//Warning, altitude.  Warning, altitude. Warning, altitude.
	PlaySoundToAttachedPlayersOnEnt( dropship, pilot, "diag_matchIntro_o2303_02_01_mcor_cpu01" )
}

function MCORTempDialogue2MacAllan( dropship )
{
	dropship.EndSignal( "OnDeath" )

	wait CRASHTIME + 3.5//16.05 //22
	//Misfit, this is MacAllan. Hang on, I'm on my way.
	PlaySoundToAttachedPlayers( dropship, "diag_matchIntro_o2303_03_02_mcor_macal_V2" )
}

/************************************************************************************************\

 ######  ##    ## ##    ## ########   #######  ##     ##       ###    ########  ##     ##    ###    ########     ###
##    ## ##   ##   ##  ##  ##     ## ##     ##  ##   ##       ## ##   ##     ## ###   ###   ## ##   ##     ##   ## ##
##       ##  ##     ####   ##     ## ##     ##   ## ##       ##   ##  ##     ## #### ####  ##   ##  ##     ##  ##   ##
 ######  #####       ##    ########  ##     ##    ###       ##     ## ########  ## ### ## ##     ## ##     ## ##     ##
      ## ##  ##      ##    ##     ## ##     ##   ## ##      ######### ##   ##   ##     ## ######### ##     ## #########
##    ## ##   ##     ##    ##     ## ##     ##  ##   ##     ##     ## ##    ##  ##     ## ##     ## ##     ## ##     ##
 ######  ##    ##    ##    ########   #######  ##     ##    ##     ## ##     ## ##     ## ##     ## ########  ##     ##

\************************************************************************************************/
function IntroMCORSpaceShips()
{
	local spaceOrigin = level.MCORSpaceOrigin
	local spaceAngles = Vector( 35,90,20 )

	local ships = []

	local model = CreatePropDynamic( REDEYE_MODEL )
	model.SetTeam( TEAM_MILITIA )
	model.kv.VisibilityFlags = 2 //Only friendlies can see this
	thread PlayAnimTeleport( model, "re_space_scramble_redeye", spaceOrigin, spaceAngles )
	ships.append( model )

	local cover = CreatePropDynamic( CAPSHIP_BIRM_MODEL_LG, model.GetOrigin(), model.GetAngles() )
	cover.SetTeam( TEAM_MILITIA )
	cover.kv.VisibilityFlags = 2 //Only friendlies can see this
	cover.SetParent( model, "ORIGIN" )
	cover.MarkAsNonMovingAttachment()
	model.Hide()
	ships.append( cover )
	delaythread( 13.9 ) IntroMCORSpaceShipsSfx( cover, "O2_Scr_MilitiaIntro1_BigShipPassby" )
	delaythread( 15.3 ) IntroMCORSpaceShipsSfx( cover, "O2_Scr_MilitiaIntro1_SmallShipPassby" )

	local model = CreatePropDynamic( REDEYE_MODEL )
	model.SetTeam( TEAM_MILITIA )
	model.kv.VisibilityFlags = 2 //Only friendlies can see this
	thread PlayAnimTeleport( model, "re_space_scramble_redeyeB", spaceOrigin, spaceAngles )
	ships.append( model )

	local model = CreatePropDynamic( ANNAPOLIS_MODEL )
	model.SetTeam( TEAM_MILITIA )
	model.kv.VisibilityFlags = 2 //Only friendlies can see this
	thread PlayAnimTeleport( model, "cb_space_scramble_anna", spaceOrigin, spaceAngles )
	ships.append( model )

	local model = CreatePropDynamic( BIRMINGHAM_MODEL )
	model.SetTeam( TEAM_MILITIA )
	model.kv.VisibilityFlags = 2 //Only friendlies can see this
	thread PlayAnimTeleport( model, "cb_space_scramble_birm", spaceOrigin, spaceAngles )
	ships.append( model )
	delaythread( 8.9 ) IntroMCORSpaceShipsSfx( cover, "O2_Scr_MilitiaIntro1_LeftSideShipBy" )

	//this ship kills itself
	CreateDogFight( spaceOrigin, spaceAngles, "st_space_o2_flyby_strat", "ht_space_o2_flyby_horn", TEAM_MILITIA )

	FlagWait( "MilitiaWarped" )

	foreach( ship in ships )
		ship.Kill()
}

function IntroMCORSpaceShipsSfx( ship, sfx )
{
	if ( !IsValid( ship ) )
		return

	foreach ( ref in level.IntroRefs[ TEAM_MILITIA ] )
		PlaySoundToAttachedPlayersOnEnt( ref, ship, sfx )
}

function IntroMCORWorldRotate()
{
	//tweak: new explosion after timing changed
	local firstShip = CreatePropDynamic( FLEET_IMC_CARRIER_1000X, Vector( -16, 14428.3, -11061.8 ), Vector( 0, 0, -25.620117 ) )
	firstShip.SetTeam( TEAM_MILITIA )
	firstShip.kv.VisibilityFlags = 2 //Only friendlies can see this
	thread ExplodeSpaceShip( 6, firstShip, TEAM_MILITIA, "O2_Scr_MilitiaIntro1_SpaceExplo1", Vector( -5000, 0, 1000 ) )

	local ships = GetEntArrayByNameWildCard_Expensive( "MCOR_skybox_MCOR_armadaExp*" )
	foreach( index, ship in ships )
	{
		switch( index )
		{
			case 1:
				local up = ship.GetUpVector()
				local forward = ship.GetForwardVector()
				ship.SetOrigin( ship.GetOrigin() + ( up * -40 ) + ( forward * -10 ) )//tweak since timing on explosion and intros changed
				break
		}
	}
	local armada = GetEntArrayByNameWildCard_Expensive( "MCOR_skybox_MCOR_armad*" )
	armada.extend( GetEntArrayByNameWildCard_Expensive( "IMC_skybox_MCOR_carriers*" ) )
	armada.append( firstShip )

	CalcArmadaMCOR( armada )

	wait 0.05

	foreach( ship in armada )
	{
		ship.ClearParent()
		ship.MoveTo( ship.s.movePos, 90.0 )
		ship.RotateTo( ship.s.moveAng, 90.0 )
		ship.SetTeam( TEAM_MILITIA )
		ship.kv.VisibilityFlags = 2 //Only friendlies can see this
	}

	local ships = GetEntArrayByNameWildCard_Expensive( "MCOR_skybox_MCOR_armadaExp*" )
	foreach( index, ship in ships )
	{
		local delay, snd, offset
		switch( index )
		{
			case 0:
				delay = 12
				snd = "O2_Scr_MilitiaIntro1_LeftSideExplo1"
				offset = Vector( 5000, 0, 0 )
				break

			case 1:
				delay = 21
				snd = "O2_Scr_MilitiaIntro1_SpaceExplo7"
				offset = Vector( -5000, 0, 1000 )
				break
		}
		thread ExplodeSpaceShip( delay, ship, TEAM_MILITIA, snd, offset )
	}

	wait 10
	local node = {}
	node.origin <- Vector( -3000,-12000,-15000 )
	node.angles <- Vector( 0,90,0 )
	local target = CreateDogFight( node.origin, node.angles )

	wait 9.0
	thread PlayFX( FX_O2_AIRBURST, target.GetOrigin(), target.GetAngles() )
	target.Kill()

	FlagWait( "MilitiaWarped" )

	local armada = GetEntArrayByNameWildCard_Expensive( "MCOR_skybox_MCOR_armad*" )
	armada.extend( GetEntArrayByNameWildCard_Expensive( "IMC_skybox_MCOR_carriers*" ) )

	foreach( ship in armada )
		ship.Kill()
}

function CalcArmadaMCOR( armada )
{
	local mySpeed = 200
	foreach( ship in armada )
	{
		ship.s.moveAng <- ship.GetAngles()

		switch( ship.GetModelName().tolower() )
		{
			case FLEET_MCOR_ANNAPOLIS_1000X:
				ship.s.movePos <- ( ship.GetOrigin() + ship.GetForwardVector() * ( 75 - mySpeed ) )
				break

			case FLEET_MCOR_BIRMINGHAM_1000X:
				ship.s.movePos <- ( ship.GetOrigin() + ship.GetForwardVector() * ( 10 - mySpeed ) )
				break

			case FLEET_MCOR_BIRMINGHAM_1000X_CLUSTERA:
				ship.s.movePos <- ( ship.GetOrigin() + ship.GetForwardVector() * ( 100 + RandomFloat( -25,25 ) - mySpeed ) )
				break

			case FLEET_MCOR_REDEYE_1000X:
			case FLEET_MCOR_REDEYE_1000X_CLUSTERA:
			case FLEET_MCOR_REDEYE_1000X_CLUSTERB:
			case FLEET_MCOR_REDEYE_1000X_CLUSTERC:
				ship.s.movePos <- ( ship.GetOrigin() + ship.GetForwardVector() * ( 125 + RandomFloat( -25,25 ) - mySpeed ) )
				break

			case FLEET_MCOR_CROW_1000X_CLUSTERA:
			case FLEET_MCOR_CROW_1000X_CLUSTERB:
				ship.s.movePos <- ( ship.GetOrigin() + ship.GetForwardVector() * ( 150 + RandomFloat( -25,25 ) - mySpeed ) )
				break

			case FLEET_IMC_CARRIER_1000X:
			case FLEET_IMC_CARRIER_1000X_CLUSTERA:
			case FLEET_IMC_CARRIER_1000X_CLUSTERB:
			case FLEET_IMC_CARRIER_1000X_CLUSTERC:
				ship.s.movePos <- ( ship.GetOrigin() + ship.GetForwardVector() * ( 100 + RandomFloat( -10,10 ) ) )
				ship.s.movePos = ship.s.movePos + ( ship.GetRightVector() * -100 )
				break

			case FLEET_IMC_WALLACE_1000x:
			case FLEET_IMC_WALLACE_1000X_CLUSTERA:
			case FLEET_IMC_WALLACE_1000X_CLUSTERB:
			case FLEET_IMC_WALLACE_1000X_CLUSTERC:
				ship.s.movePos <- ( ship.GetOrigin() + ship.GetForwardVector() * ( RandomFloat( -10,10 ) ) )
				ship.s.movePos = ship.s.movePos + ( ship.GetRightVector() * -100 )
				break

			case FLEET_CAPITAL_SHIP_ARGO_1000X:
				ship.s.movePos <- ( ship.GetOrigin() + ship.GetForwardVector() * -200 )
				ship.s.movePos = ship.s.movePos + ( ship.GetRightVector() * -50 )
				break
		}
	}
}


/************************************************************************************************\

##    ## ########   ######     ########          ########     ###    ##    ##
###   ## ##     ## ##    ##    ##     ##         ##     ##   ## ##    ##  ##
####  ## ##     ## ##          ##     ##         ##     ##  ##   ##    ####
## ## ## ########  ##          ##     ## ####### ##     ## ##     ##    ##
##  #### ##        ##          ##     ##         ##     ## #########    ##
##   ### ##        ##    ##    ##     ##         ##     ## ##     ##    ##
##    ## ##         ######     ########          ########  ##     ##    ##

\************************************************************************************************/
function IntroMCORLanding()
{
	FlagWait( "MilitiaDDayGo" )

	//titans
	delaythread( 2.0 ) IntroLandingSpears( GetEnt( "MCOR_intro_titan_spears" ) )

	delaythread( 0.25 ) IntroLandingTitanRunAndDie( GetEnt( "MCOR_intro_titan_left" ), "#NPC_SGT_BLANTON", GetEnt( "turret_IMC_intro_1" ), 350 )
	delaythread( 0.0 ) IntroLandingTitanRunAndDie( GetEnt( "MCOR_intro_titan_right" ), "#NPC_SGT_EMSLIE", GetEnt( "turret_IMC_intro_4" ), 250 )

	//drones
	local nodes = GetEntArrayByNameWildCard_Expensive( "MCOR_intro_droppod_landing*" )
	foreach ( index, node in nodes )
		delaythread( 1.75 ) IntroLandingDropPod( node, index, nodes.len() )

	local nodes = GetEntArrayByNameWildCard_Expensive( "MCOR_intro_droppod_wave2*" )
	foreach ( index, node in nodes )
		delaythread( 10.0 ) IntroLandingWave2( node, index, nodes.len() )

	//turrets
	foreach ( turret in GetEntArrayByNameWildCard_Expensive( "turret_IMC_intro*" ) )
		delaythread( 4.0 ) IntroLandingTurrets( turret )

	delaythread( 19.0 ) IntroLandingTurretsOff( GetEnt( "turret_IMC_intro_2" ) )
	delaythread( 20.0 ) IntroLandingTurretsOff( GetEnt( "turret_IMC_intro_4" ) )
	delaythread( 21.0 ) IntroLandingTurretsOff( GetEnt( "turret_IMC_intro_1" ) )
	delaythread( 23.0 ) IntroLandingTurretsOff( GetEnt( "turret_IMC_intro_3" ) )
}

function IntroLandingTurrets( turret )
{
	if ( !IsAlive( turret ) )
		return
	turret.EndSignal( "OnDeath" )

	turret.TakeWeapon( "mp_weapon_mega_turret" )
	turret.GiveWeapon( "mp_weapon_mega_turret", [ "O2Beach" ] )
	turret.SetActiveWeapon( "mp_weapon_mega_turret" )
	turret.s.notitle <- true

	turret.Minimap_Hide( TEAM_IMC, null )
	turret.Minimap_Hide( TEAM_MILITIA, null )

	turret.EnableTurret()
	TurretChangeTeam( turret, TEAM_IMC )
	turret.ClearBossPlayer()
	turret.SetTitle( "#O2_TURRET_NAME" )
	//turret.kv.AccuracyMultiplier = 1000

	while( 1 )
	{
		turret.WaitSignal( "OnFoundEnemy" )

		local enemy = turret.GetEnemy()
		if ( !IsValid( enemy ) )
			continue
		if ( enemy.IsPlayer() && IsAlive( level.spears ) )
			turret.SetEnemy( level.spears )
	}
}

function IntroLandingTurretsOff( turret )
{
	if ( !IsValid( turret ) )
		return

	turret.TakeDamage( 50000, null, null, {} )
	turret.DisableTurret()
}

function IntroLandingSpears( node )
{
	local table 	= CreateDefaultNPCTitanTemplate( TEAM_MILITIA )
	table.title 	= "#NPC_MACALLAN"
	table.origin 	= node.GetOrigin()
	table.angles 	= node.GetAngles()
	table.model 	= OGRE_MODEL
	table.health 	= 10000
	table.maxHealth	= table.health
	table.weapon	= "mp_titanweapon_rocket_launcher"

	local titan = SpawnNPCTitan( table )
	MakeInvincible( titan )
	DisableHealthRegen( titan )
	DisableRodeo( titan )
	ForceRodeoOver( titan )
	titan.SetEfficientMode( true )
	titan.SetTouchTriggers( false )
	level.spears = titan

	local gate = CreatePropDynamic( O2_GATE_MODEL )
	local gateNode = GetEnt( "ddayAnimNode" )
	thread PlayAnimTeleport( gate, "imc_gate_o2_idle", gateNode )

	local table = {}
	table.gate <- gate
	table.gateNode <- gateNode

	titan.EndSignal( "OnDeath" )

	waitthread ScriptedO2HotDrop( titan, node.GetOrigin(), node.GetAngles(), "at_hotdrop_drop_2knee_turbo", table )
}

function ScriptedO2HotDrop( titan, origin, angles, animation, table )
{
	OnThreadEnd(
		function() : ( titan )
		{
			if ( IsValid( titan ) )
			{
				DeleteAnimEvent( titan, "titan_impact", OnSpearsDrop )
				DeleteAnimEvent( titan, "second_stage", OnSpearsSecondStage )
				titan.DisableRenderAlways()
			}
		}
	)
	titan.EndSignal( "OnDeath" )

	AddAnimEvent( titan, "titan_impact", Bind( OnSpearsDrop ), table )
	AddAnimEvent( titan, "second_stage", OnSpearsSecondStage, origin )

	titan.EnableRenderAlways()
	EmitSoundAtPosition( origin, "O2_Scr_MacAllanTitan_hot_drop_turbo_begin" )
	waitthread PlayAnimTeleport( titan, animation, origin, angles )
}

function OnSpearsSecondStage( titan, origin )
{
	EmitSoundAtPosition( origin, "O2_Scr_MacAllanTitan_drop_pod_turbo_landing" )
}

function OnSpearsDrop( titan, table = null )
{
	//impact fx
	OnDropImpactO2( titan )
	EmitSoundOnEntity( titan, "O2_Scr_OgreLand_to_ArmBlownOff" )

	thread _OnSpearsDropThread( titan, table )
}

function _OnSpearsDropThread( titan, table )
{
	local gate = table.gate
	local gateNode = table.gateNode

	titan.EndSignal( "OnDeath" )

	local mac = CreatePropDynamic( MAC_MODEL )
	mac.SetTeam( TEAM_MILITIA )
	mac.SetParent( titan, "hijack" )
	mac.MarkAsNonMovingAttachment()

	delaythread( 4.5 ) HolyShit()
 	thread PlayAnimTeleport( mac, "macal_o2_Militia_pepTalk", titan, "hijack" )
	waitthread PlayAnimGravity( titan, "ogre_o2_Militia_pepTalk" )

	mac.Kill()
	titan.Anim_Stop()
	titan.AllowFlee( false )
	titan.AllowHandSignals( false )
	titan.SetEfficientMode( false )
	titan.DisableStarts()
	titan.DisableArrivalOnce( true )

	thread SpearsEnemy( titan )

	local node = GetEnt( "ddayAnimNode" )
	local anim = "ogre_o2_Militia_gateSmash"

	local animStartPos = titan.Anim_GetStartForRefPoint( anim, node.GetOrigin(), node.GetAngles() )

	waitthread RunToAnimStartForced( titan, anim, node )

	thread MacAllanIntro( titan, node )

	//lose the arm
	local bodyGroupIndex = titan.FindBodyGroup( "right_arm" )
	local state = 2
	titan.SetBodygroup( bodyGroupIndex, state )

	local arm = CreatePropDynamic( OGRE_ARM_MODEL )
	arm.SetTeam( TEAM_MILITIA )
	arm.SetSkin( 1 )
	delaythread( 30 ) KillEnt( arm )

	EmitSoundOnEntity( titan, "O2_Scr_OgreArmBlownOff_to_Collapse" )
	thread PlayAnimTeleport( arm, "ogre_r_arm_smashed", gateNode )
	thread PlayAnim( gate, "imc_gate_o2_gateSmash", gateNode )
	thread PlayAnim( titan, anim, node )
}

function HolyShit()
{
	//Holy shit, it's MacAllan
	EmitSoundAtPosition( Vector( 3455.386230, -4244.083008, -256.524994 ), "diag_hp_matchIntro_O2182_01_01_mcor_grunt1" )
}

function MacGenerationCallout()
{
	//Those 11th gen pilots have all the best toys
	EmitSoundAtPosition( Vector( 1993.380493, -2260.605469, 35.491417), "diag_hp_matchIntro_O2183_01_01_mcor_grunt2" )
}

function SpearsEnemy( titan )
{
	local turret = GetEnt( "turret_IMC_intro_2" )
	titan.SetEnemy( turret )

	wait 4
	IntroLandingTurretsOff( turret )
	titan.SetEnemy( GetEnt( "turret_IMC_intro_3" ) )
}

function MoveStartSpawns()
{
	local spawns = GetEntArrayByNameWildCard_Expensive( "startSpawnMCOR_campaign*" )

	foreach( index, spawn in spawns )
	{
		spawn.SetOrigin( level.O2StartSpawns[ index ].pos )
		spawn.SetAngles( level.O2StartSpawns[ index ].ang )
	}
}

function MacAllanIntro( titan, node )
{
	delaythread( 3 ) FlagSet( "GateOpen" )
	delaythread( 3 ) MoveStartSpawns()

	wait 6

	local mac = CreateGrunt( TEAM_MILITIA, MAC_MODEL, "mp_weapon_rspn101" )
	DispatchSpawn( mac )
	mac.SetTitle( "#NPC_MACALLAN" )
	MakeInvincible( mac )
	mac.SetEfficientMode( true )
	mac.SetLookDist( 1 )
	HideName( titan )

	local anim = "mac_o2_takethosehardpoints"
	local time = mac.GetSequenceDuration( anim )

	waitthread PlayAnimTeleport( mac, "macal_o2_Militia_gateSmash", node )
	waitthread PlayAnimGravity( mac, anim )


	//mac.SetMoveAnim( "sprint_F_fast" )
	local goal = Vector( 2024, -2161, 0 )
	thread GotoOrigin( mac, goal )

	wait 2.0

	FlagSet( "MILITIA_IntroDone" )

	local goal = Vector( 1996, -1638, 0 )
	thread GotoOrigin( mac, goal )

	local fade = 2
	local duration = 6

	mac.SetCloakDuration( fade, duration, fade )
	EmitSoundOnEntity( mac, "cloak_on" )

	thread MacGenerationCallout()

	wait 1.75

	mac.Kill()
}

function IntroLandingTitanRunAndDie( node, name, turret, dmg )
{
	local table 	= CreateDefaultNPCTitanTemplate( TEAM_MILITIA )
	table.title 	= name
	table.health 	= 3000
	table.maxHealth	= table.health
	table.origin 	= node.GetOrigin()
	table.angles 	= node.GetAngles()

	local titan = SpawnNPCTitan( table )
	titan.SetEfficientMode( true )
	titan.SetTouchTriggers( false )

	local animation = "at_hotdrop_drop_2knee_turbo"
	thread ScriptedHotDrop( titan, node.GetOrigin(), node.GetAngles(), animation, true )
	wait 5.4
	waitthread PlayAnimGravity( titan, "at_MP_embark_fast" )
	titan.SetEfficientMode( false )

	titan.Anim_Stop()
	titan.AllowFlee( false )
	titan.AllowHandSignals( false )

	titan.SetEnemy( turret )

	local assault = GetEnt( node.GetTarget() )
	titan.AssaultPointEnt( assault )

	titan.EndSignal( "OnDeath" )

	while( 1 )
	{
		titan.TakeDamage( dmg, turret, turret, { damageSourceId= eDamageSourceId.mp_weapon_mega_turret_aa } )
		wait 0.25
	}
}

function IntroLandingWave2( node, index, max )
{
	local totalTime = 2.0
	local increment = totalTime / max
	local time = index * increment

	wait time

	local offset = Vector( 0, 0, 8 )
	local numGuys = GetCPULevelWrapper() == CPU_LEVEL_HIGHEND ? 4 : 3
	local squad = Spawn_ScriptedTrackedDropPodGruntSquad( TEAM_MILITIA, numGuys, node.GetOrigin() + offset, node.GetAngles(), "MCORDPWave2" + index )
	foreach( guy in squad )
	{
		guy.IgnoreClusterDangerTime( true )
		guy.SetEfficientMode( true )
		guy.s.ogLookDist <- guy.GetLookDist()
		guy.SetLookDist( 1 )
		MakeInvincible( guy )
	}

	local end = GetEnt( "ddayAnimNode" )

	wait 2.25

	local offsets = [
		Vector( 64, 0, 0 ),
		Vector( -64, 0, 0 ),
		Vector( 0, 64, 0 ),
		Vector( 0, -64, 0 )
	]

	foreach( num, guy in squad )
		thread GotoOrigin( guy, end.GetOrigin() + Vector( 0,0,4 ) + offsets[ num ] )

	FlagWait( "GateOpen" )

	local hp = null
	switch ( node.GetName() )
	{
		case "MCOR_intro_droppod_wave2_2":
			wait 2
			foreach( num, guy in squad )
				thread GotoOrigin( guy, Vector( 2024, -2161, 0 ) + offsets[ num ] )

			wait 6
			hp = eHardpoint.marvinBay
			break

		case "MCOR_intro_droppod_wave2_1":
			foreach( num, guy in squad )
				thread GotoOrigin( guy, Vector( -7, -1702, 21 ) + offsets[ num ] )

			wait 15
			hp = eHardpoint.mainReactor
			break

		case "MCOR_intro_droppod_wave2_3":
			foreach( num, guy in squad )
				thread GotoOrigin( guy, Vector( 1051, -1465, 14 ) + offsets[ num ] )

			wait 15
			hp = eHardpoint.warehouse
			break

		default:
			Assert( false, "didn't handle " + node.GetName() )
			break
	}

	foreach( guy in squad )
		ClearInvincible( guy )

	ScriptedSquadAssault( squad, hp )

	wait 4

	ArrayRemoveDead( squad )

	foreach( guy in squad )
	{
		guy.IgnoreClusterDangerTime( false )
		guy.SetEfficientMode( false )
		guy.SetLookDist( guy.s.ogLookDist )
	}
}

function IntroLandingDropPod( node, index, max )
{
	local totalTime = 2.0
	local increment = totalTime / max
	local time = index * increment

	wait time

	local numGuys = GetCPULevelWrapper() == CPU_LEVEL_HIGHEND ? 4 : 3
	local squad = Spawn_ScriptedTrackedDropPodGruntSquad( TEAM_MILITIA, numGuys, node.GetOrigin(), node.GetAngles(), "MCORDPIntro" + index, SpawnGruntLight, ImpactNoShake )
	//ScriptedSquadAssault( squad, index )

	local goals = GetEntArrayByNameWildCard_Expensive( node.GetTarget() + "*" )

	Assert( goals.len() >= squad.len() )

	local end = GetEnt( "ddayAnimNode" )
	local dist = Distance2D( end.GetOrigin(), node.GetOrigin() )
	local dieTime = ( dist * 0.0033	)

	foreach ( i, drone in squad )
		thread IntroLandingGuyRunAndDie( drone, goals[ i ], dieTime )
}

function IntroLandingGuyRunAndDie( drone, assault, dieTime )
{
	drone.EndSignal( "OnDeath" )
	drone.EndSignal( "KillFunction" )

	drone.Anim_Stop()
	drone.SetHealth( 1 )
	drone.DisableStarts()
	drone.s.canDieInPrematch <- true
	drone.AllowFlee( false )
	drone.AllowHandSignals( false )
	drone.SetEfficientMode( true )
	drone.SetLookDist( 1 )
	drone.IgnoreClusterDangerTime( true )

	OnThreadEnd(
		function() : ( drone )
		{
			if ( !IsValid( drone ) )
				return

			local attachID = drone.LookupAttachment( "CHESTFOCUS" )
			local origin = drone.GetAttachmentOrigin( attachID )
			local angles = drone.GetAttachmentAngles( attachID )
			thread PlayFX( FX_BLOOD_SQUIB, drone.GetOrigin(), drone.GetAngles() )

			drone.TakeDamage( 500, null, null, {} )
		}
	)

	delaythread( dieTime + RandomFloat( 0, 1.5 ) ) SendSignal( drone, "KillFunction" )//kill him randomly
	//thread IntroLandingGuyStumble( drone )

	while( assault )
	{
		drone.DisableArrivalOnce( true )

		drone.AssaultPointEnt( assault )
		drone.WaitSignal( "OnFinishedAssault" )

		if ( !assault.GetTarget() )
			break

		assault = GetEnt( assault.GetTarget() )
	}
}

function IntroLandingGuyStumble( drone )
{
	drone.EndSignal( "OnDeath" )

	local anims = []
	anims.append( "a_panic_run_stumble_small" )
	anims.append( "a_panic_run_stumble" )
	anims.append( "pain_sprint_kneeslide" )
	anims.append( "pain_sprint_stumble" )
	anims.append( "pain_sprint_shoulder" )
	anims.append( "pain_sprint_gut" )
	anims.append( "pain_sprint_duck" )
	anims.append( "pain_sprint_arm" )

	while( 1 )
	{
		wait RandomFloat( 1, 5 )
		local anim = Random( anims )
		local time = drone.GetSequenceDuration( anim )

		drone.SetMoveAnim( anim )

		wait time
		drone.ClearMoveAnim()
	}
}

function DebugDroneCount( soldier )
{
	level.DebugDrones++
	printt( "AI COUNT: ", level.DebugDrones )

	soldier.WaitSignal( "OnDeath" )

	level.DebugDrones--
	printt( "AI COUNT: ", level.DebugDrones )
}

function SendSignal( ent, msg )
{
	if ( IsValid( ent ) )
		ent.Signal( msg )
}

function KillEnt( ent )
{
	if ( IsValid( ent ) )
		ent.Kill()
}

function OnDropImpactO2( titan, e = null )
{
	PlayFX( HOTDROP_IMPACT_FX_TABLE, titan.GetOrigin(), titan.GetAngles() )

	CreateShake( titan.GetOrigin(), 4, 50, 2, 3000 )
}

function ImpactNoShake( ent, e = null )
{
	PlayFX( HOTDROP_IMPACT_FX_TABLE, ent.GetOrigin(), ent.GetAngles() )
}

/************************************************************************************************\

########  ######## ##     ##    ##     ## ######## ##    ## ##     ##
##     ## ##       ##     ##    ###   ### ##       ###   ## ##     ##
##     ## ##       ##     ##    #### #### ##       ####  ## ##     ##
##     ## ######   ##     ##    ## ### ## ######   ## ## ## ##     ##
##     ## ##        ##   ##     ##     ## ##       ##  #### ##     ##
##     ## ##         ## ##      ##     ## ##       ##   ### ##     ##
########  ########    ###       ##     ## ######## ##    ##  #######

\************************************************************************************************/

function DEV_MCORIntroCrash( seat )
{
	level.ent.Signal( "DEV_MCORIntroWakeup" )
	level.ent.EndSignal( "DEV_MCORIntroWakeup" )

	DEV_MCORIntroSetup()

	thread IntroMCORLanding()

	local devEvent 	= GetSavedDropEvent( "devEvent" )

	local table 	= GetSavedDropEvent( "introDropShipMCOR_1cr" )
	local event1 	= GetSavedDropEvent( "introDropShipMCOR_1e1" )
	local event2 	= GetSavedDropEvent( "introDropShipMCOR_1e2" )
	local event3 	= GetSavedDropEvent( "introDropShipMCOR_1e3" )
	local dropship1 = SpawnCinematicDropship( table )
	thread RunCinematicDropship( dropship1, event1, event2, event3 )

	local table 	= GetSavedDropEvent( "introDropShipMCOR_2cr" )
	local event1 	= GetSavedDropEvent( "introDropShipMCOR_2e1" )
	local event2 	= GetSavedDropEvent( "introDropShipMCOR_2e2" )
	local event3 	= GetSavedDropEvent( "introDropShipMCOR_2e3" )
	local dropship2	= SpawnCinematicDropship( table )
	thread RunCinematicDropship( dropship2, event1, event2, event3 )

	DebugSkipCinematicSlots( TEAM_MILITIA, seat )
	dropship1.SetJetWakeFXEnabled( false )
	dropship2.SetJetWakeFXEnabled( false )

	wait 0.1

	DEV_HackAttachPlayer( dropship1, dropship2 )

	wait 0.1//event1
	FlagSet( "MCORJump" )

	IntroMilitiaDDayFlags()
}

function DEV_MCORIntroWakeup( seat )
{
	level.ent.Signal( "DEV_MCORIntroWakeup" )
	level.ent.EndSignal( "DEV_MCORIntroWakeup" )

	DEV_MCORIntroSetup()

	thread IntroMCORLanding()

	local devEvent 	= GetSavedDropEvent( "devEvent" )

	local table 	= GetSavedDropEvent( "introDropShipMCOR_1cr" )
	local event3 	= GetSavedDropEvent( "introDropShipMCOR_1e3" )
	local dropship1 = SpawnCinematicDropship( table )
	thread RunCinematicDropship( dropship1, devEvent, devEvent, event3 )

	local table 	= GetSavedDropEvent( "introDropShipMCOR_2cr" )
	local event3 	= GetSavedDropEvent( "introDropShipMCOR_2e3" )
	local dropship2	= SpawnCinematicDropship( table )
	thread RunCinematicDropship( dropship2, devEvent, devEvent, event3 )

	DebugSkipCinematicSlots( TEAM_MILITIA, seat )
	dropship1.SetJetWakeFXEnabled( false )
	dropship2.SetJetWakeFXEnabled( false )

	wait 0.1

	DEV_HackAttachPlayer( dropship1, dropship2 )

	wait 0.1//event1
	dropship1.Anim_Stop()
	dropship2.Anim_Stop()

	wait 0.1//event2
	dropship1.Anim_Stop()
	dropship2.Anim_Stop()

	FlagSet( "MilitiaDDayGo" )

	wait 3.3 - WAKEUPTIME
	FlagSet( "MCORCrashed" )

	wait WAKEUPTIME
	FlagSet( "MCORwakeup" )

	wait 12
	FlagSet( "KillMCORShips" )
}

function DEV_MCORIntroSetup()
{
	local player = GetPlayerArray()[ 0 ]
	player.ClearParent()
	player.Anim_Stop()
	level.ent.Signal( "closeSpawnWindow" )

	disable_npcs()

	wait 0.1

	FlagClear( "MCORwakeup" )
	FlagClear( "MCORCrashed" )
	FlagClear( "KillMCORShips" )
	FlagClear( "MilitiaDDayGo" )
	FlagClear( "GateOpen" )
	FlagClear( "MCORJump" )
	FlagClear( "MilitiaWarped" )

	if ( ( "storedDropEvents" in level ) && ( "introDropShipMCOR_1cr" in level.storedDropEvents ) )
		return

	IntroSetupMilitiaHero()

	local ddayAnimNode 		= GetEnt( "ddayAnimNode" )
	local devEvent 			= CreateCinematicEvent()
	devEvent.origin 		= ddayAnimNode.GetOrigin()
	devEvent.yaw			= ddayAnimNode.GetAngles().y
	devEvent.anim			= "dropship_o2_postCrash_left"
	devEvent.teleport 		= true
	AddSavedDropEvent( "devEvent", devEvent )

	local event = GetSavedDropEvent( "introDropShipMCOR_1e1" )
	event.animStartFunc = []
	Event_AddAnimStartFunc( event, MCORHerosEventSetup )
	local event = GetSavedDropEvent( "introDropShipMCOR_2e1" )
	event.animStartFunc = []
	Event_AddAnimStartFunc( event, MCORHerosEventSetup )
}