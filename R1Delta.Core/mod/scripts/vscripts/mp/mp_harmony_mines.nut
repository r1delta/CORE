// RESET AFTER TESTING
const DEV_TEST 						= false
// these only work if dev_test is set
const DEV_CUSTOM_CONNECTWAIT 		= true
const DEV_CUSTOM_CONNECTWAIT_SECS 	= 1
const DEV_DISABLE_NPCS 				= true

function main()
{
	IncludeScript( "mp_harmony_mines_shared" )

	if ( reloadingScripts )
		return

	GM_AddEndRoundFunc( EndRoundMain )

	level.serverInitDone <- false

	level.diggerWheel <- null
	level.diggerWheelHurtTrig <- null
	level.diggerState <- null
	level.diggerWheelAngles <- Vector( 0, 225, 0 )

	level.grinderOn <- false

	RegisterSignal( "DiggerWheelRotationDone" )
	RegisterSignal( "DiggerWheelPushPlayersStateChange" )
	RegisterSignal( "DiggerWheelPushPlayers_Start" )
	RegisterSignal( "DiggerWheelHurtTrigger_Spinup" )
	RegisterSignal( "StopDiggerThink" )
	RegisterSignal( "StopGrinderThink" )

	AddDamageCallback( "player", DigSite_PlayerDamaged )

	PrecacheModel( "models/containers/plastic_pallet_01.mdl" )

	AddCallback_GameStateEnter( eGameState.Prematch, HarmonyMines_Prematch )
}

function HarmonyMines_Prematch()
{
	if ( !level.serverInitDone )
	{
		HarmonyMines_Server_DiggerInit()
		HarmonyMines_Server_GrinderInit()

		level.serverInitDone = true
	}
}

function EntitiesDidLoad()
{
	if ( DEV_TEST && DEV_DISABLE_NPCS )
		disable_npcs()

	if ( EvacEnabled() )
		EvacSetup()

	local bug79808 = CreatePropDynamic( "models/containers/plastic_pallet_01.mdl", Vector( -1889.0, -2500.0, 667.0 ), Vector( -26.5, 0.0, 0.0 ), 6 )
	bug79808.MakeInvisible()
}

function DigSite_PlayerDamaged( player, damageInfo )
{
	local dmg = damageInfo.GetDamage()
	local inflictor = damageInfo.GetInflictor()
	//printt( "player damage:", dmg, "inflictor:", inflictor )

	if ( inflictor.GetName() == "trigger_digger_hurt_01" )
		thread PlayerTookDamageFromDiggerWheel( player, damageInfo )
}

function HarmonyMines_Server_DiggerInit()
{
	local tn = "digger_model_scoop"
	local arr = GetEntArrayByName_Expensive( tn )
	Assert( arr.len() == 1 && arr[0] != null, "Couldn't find digger with targetname: " + tn )
	level.diggerWheel = arr[0]
	level.diggerWheel.s.waitingForRotation <- false

	AddAnimEvent( level.diggerWheel, "spin_stop", DiggerWheel_AnimEvent_SpinStop )
	AddAnimEvent( level.diggerWheel, "spin_resuming", DiggerWheel_AnimEvent_SpinResuming )
	AddAnimEvent( level.diggerWheel, "spin_resume", DiggerWheel_AnimEvent_SpinResume )

	local tn = "trigger_digger_hurt_01"
	local arr = GetEntArrayByName_Expensive( tn )
	Assert( arr.len() == 1 && arr[0] != null, "Couldn't find digger hurt trigger with targetname: " + tn )
	level.diggerWheelHurtTrig = arr[0]
	level.diggerWheelHurtTrig.s.pushPlayers <- false
	level.diggerWheelHurtTrig.s.isActive <- true

	local tn = "digger_wheel_weaponclip"
	local arr = GetEntArrayByName_Expensive( tn )
	Assert( arr.len() == 1 && arr[0] != null, "Couldn't find weaponclip func_brush with targetname: " + tn )
	local weaponclip = arr[0]
	level.diggerWheel.s.weaponclip <- weaponclip

	// parent our prebuilt weapon collision in place to the animating wheel prop
	level.diggerWheel.s.collisionMover <- CreateScriptMover( null, level.diggerWheel.GetOrigin(), level.diggerWheel.GetAngles() )
	level.diggerWheel.s.collisionMover.SetParent( level.diggerWheel, "ATTACH" )
	weaponclip.SetParent( level.diggerWheel.s.collisionMover, "ref", true )

	thread DiggerCycle()
	thread DiggerWheel_PushPlayersThink()

	// server side generator models get hidden, we only need the hitboxes that we get when they are server entities.
	// (Client ones are the ones that animate to match the digger)
	// HACK- doing this because hitboxes came online late
	local serverGeneratorNames = []
	serverGeneratorNames.append( "generator_excavator_1_server" )
	serverGeneratorNames.append( "generator_excavator_2_server" )
	serverGeneratorNames.append( "generator_excavator_3_server" )
	serverGeneratorNames.append( "generator_excavator_4_server" )
	foreach ( name in serverGeneratorNames )
	{
		local arr = GetEntArrayByName_Expensive( name )
		Assert( arr.len() == 1 )
		local serverGenerator = arr[0]
		serverGenerator.Hide()
	}
}

function DiggerWheel_AnimEvent_SpinStop( diggerWheel )
{
	SetDiggerScreenShakeState( eDiggerState.TWITCH )
	SetDiggerGeneratorState( eDiggerState.TWITCH )
	SetDiggerFXState( eDiggerState.TWITCH )
	SetDiggerWheelHurtTriggerPushPlayers( false )

	level.nv.diggerStopTime = Time()

	SetDiggerWheelHurtTriggerActive( false )
}

function DiggerWheel_AnimEvent_SpinResuming( diggerWheel )
{
	SetDiggerGeneratorState( eDiggerState.SPIN )
	SetDiggerFXState( eDiggerState.SPIN )
	SetDiggerWheelHurtTriggerPushPlayers( true )
	SetDiggerWheelHurtTriggerActive( true )

	level.nv.diggerStartTime = Time()
}

function DiggerWheel_AnimEvent_SpinResume( diggerWheel )
{
	SetDiggerScreenShakeState( eDiggerState.SPIN )
}

function SetDiggerWheelHurtTriggerPushPlayers( doPushPlayers )
{
	if ( level.diggerWheelHurtTrig.s.pushPlayers == doPushPlayers )
		return

	level.diggerWheelHurtTrig.s.pushPlayers = doPushPlayers

	level.ent.Signal( "DiggerWheelPushPlayersStateChange" )
}

function SetDiggerWheelHurtTriggerActive( isActive )
{
	if ( level.diggerWheelHurtTrig.s.isActive == isActive )
		return

	if ( isActive )
		thread DiggerWheelHurtTriggerBecomesActive()
	else
		level.diggerWheelHurtTrig.Fire( "Disable" )

	level.diggerWheelHurtTrig.s.isActive = isActive
}

function DiggerWheelHurtTriggerBecomesActive()
{
	level.ent.Signal( "DiggerWheelHurtTrigger_Spinup" )
	level.ent.EndSignal( "DiggerWheelHurtTrigger_Spinup" )

	local trig = level.diggerWheelHurtTrig
	trig.EndSignal( "OnDestroy" )

	local pilotHealth = 200
	local forceDmgMultiplier = 2  // needed to punch through pilot shields

	local minDmg = ( pilotHealth * 0.25 ) * 2
	local maxDmg = pilotHealth * 2

	local timeToScale = 3
	local startTime = Time()
	local endTime = startTime + timeToScale

	trig.kv.Damage = minDmg
	trig.Fire( "Enable" )

	while ( Time() < endTime )
	{
		//printt( "time diff:", endTime - Time() )
		local dmg = GraphCapped( endTime - Time(), timeToScale, 0, minDmg, maxDmg )
		trig.kv.Damage = dmg
		//printt( "trigger damage:", trig.kv.Damage )
		wait 0.1
	}

	trig.kv.Damage = maxDmg
}

function PlayerTookDamageFromDiggerWheel( player, damageInfo )
{
	Assert( damageInfo.GetInflictor().GetName() == "trigger_digger_hurt_01" )

	if ( !player.IsPlayer() )
		return

	if ( player.IsBot() )
		return

	local playerhealth = player.GetHealth()
	local incomingDmg = damageInfo.GetDamage()

	local alias_1p = "DigSite_Scr_Digger_DamageImpact_3p_vs_1p"
	local alias_3p = "DigSite_Scr_Digger_DamageImpact_3p_vs_3p"

	if ( playerhealth - incomingDmg <= 0 )
	{
		//printt( "PLAYER WILL DIEEEE", incomingDmg, playerhealth)

		alias_1p = "DigSite_Scr_Digger_DamageImpact_Kill_3p_vs_1p"
		alias_3p = "DigSite_Scr_Digger_DamageImpact_Kill_3p_vs_3p"
	}
	//else
	//{
	//	printt( "Player getting hurt!", incomingDmg, playerhealth )
	//}

	EmitSoundOnEntityOnlyToPlayer( player, player, alias_1p )
	EmitSoundAtPositionExceptToPlayer( player.GetOrigin(), player, alias_3p )
}

function SetDiggerScreenShakeState( newstate )
{
	if ( level.nv.diggerScreenShake == newstate )
		return

	level.nv.diggerScreenShake = newstate
}

function SetDiggerGeneratorState( newstate )
{
	if ( level.nv.diggerGeneratorsOn == newstate )
		return

	//printt( "Setting digger generator state:", newstate )

	level.nv.diggerGeneratorsOn = newstate
}

function SetDiggerFXState( newstate )
{
	if ( level.nv.diggerFXState == newstate )
		return

	level.nv.diggerFXState = newstate
}

function DiggerCycle()
{
	level.ent.Signal( "StopDiggerThink" )
	level.ent.EndSignal( "StopDiggerThink" )

	level.diggerWheel.EndSignal( "OnDestroy" )

	local idleRotations = 8

	while ( 1 )
	{
		//printt( "Digger wheel SPIN" )
		level.diggerWheel.s.waitingForRotation = false
		DiggerStart()

		for ( local i = 0; i < idleRotations; i++ )
		{
			if ( i == idleRotations - 1 )  // second to last rotation
				level.diggerWheel.s.waitingForRotation = true

			level.diggerWheel.WaitSignal( "DiggerWheelRotationDone" )
		}

		//printt( "Digger wheel TWITCH" )
		DiggerTwitch()
	}
}

function DiggerWheel_PushPlayersThink()
{
	level.diggerWheel.EndSignal( "OnDestroy" )

	level.ent.Signal( "DiggerWheelPushPlayers_Start" )
	level.ent.EndSignal( "DiggerWheelPushPlayers_Start" )

	while ( 1 )
	{
		if ( !level.diggerWheelHurtTrig.s.pushPlayers )
		{
			level.ent.WaitSignal( "DiggerWheelPushPlayersStateChange" )
			continue
		}

		local numPushed = 0

		foreach ( player in GetPlayerArray() )
		{
			if ( !IsValid( player ) )
				continue

			if ( !level.diggerWheelHurtTrig.IsTouching( player ) )
			{
				//printt( "Not touching hurt trigger!" )
				continue
			}

			local pushDelay = 0
			local minWait = 0
			if ( numPushed > 0 )
				pushDelay = RandomFloat( 0.01, 0.02 )

			DiggerWheelPushTouchingPlayer( player, pushDelay )

			numPushed++
		}

		wait RandomFloat( 0.18, 0.26 )
	}
}

function DiggerWheelPushTouchingPlayer( player, pushDelay = 0 )
{
	player.EndSignal( "OnDestroy" )

	if ( pushDelay > 0 )
		wait pushDelay

	//printt( "---- Pushing", player )

	local playerOrg = player.GetOrigin()
	local wheelOrg = level.diggerWheel.GetOrigin()
	local vecToPlayer = playerOrg - wheelOrg
	vecToPlayer.Norm()
	local angleToPlayer = VectorToAngles( vecToPlayer )
	local pushVec = angleToPlayer.AnglesToUp()
	//printt( "pushVec:", pushVec, "pushAng:", VectorToAngles( pushVec ) )

	// depending on where we are along the outside of the wheel, we might need to point the opposite way to match rotation direction
	//DebugDrawAngles( wheelOrg, level.diggerWheelAngles, 10.0 )
	local wheelFwdVec = level.diggerWheelAngles.AnglesToForward()  // faces the same direction as the digger arm- negative dot means we're on the "back side" so we will adjust

	local rotationAxisDot = vecToPlayer.Dot( wheelFwdVec )
	if ( rotationAxisDot < 0 )
	{
		local oldPV = pushVec
		pushVec *= -1
		//printt( "DOT:", rotationAxisDot )
		//printt( "Adjusted pushVec from", oldPV, "to", pushVec )
	}

	//DebugDrawAngles( playerOrg, VectorToAngles( pushVec ), 5.0 )  // draw impulse vector

	local pushbackStrength = 370
	local pushbackVelocity = pushVec * pushbackStrength
	local targetVelocity = player.GetVelocity()
	targetVelocity += pushbackVelocity
	//printt( "pushbackVelocity:", pushbackVelocity.LengthSqr() )

	/*
	local zVel = 300
	if ( playerOrg.z < wheelOrg.z )
		zVel *= -1

	targetVelocity += Vector( 0, 0, zVel )  // add vertical impulse
	//printt( "target velocity after vertical impulse added", targetVelocity )
	targetVelocity = ClampVerticalVelocity( targetVelocity, 500 )
	//printt( "target velocity after vertical impulse + clamp", targetVelocity )
	*/

	player.SetVelocity( targetVelocity )
	if ( player.IsPlayer() && player.PlayerMelee_IsAttackActive() )
	{
		player.PlayerMelee_EndAttack()
		player.PlayerMelee_SetState( PLAYER_MELEE_STATE_NONE )
		player.s.currentMeleeAttackTarget = null
	}
}

function SetDiggerWiresState( newstate )
{
	if ( level.nv.diggerWiresState == newstate )
		return

	level.nv.diggerWiresState = newstate
}

function DiggerStart()
{
	if ( level.diggerState == eDiggerState.SPIN )
		return

	// if things aren't already turned on, turn them on (for ex., when starting with this state)
	DiggerWheel_AnimEvent_SpinResuming( level.diggerWheel )
	DiggerWheel_AnimEvent_SpinResume( level.diggerWheel )

	SetDiggerState( eDiggerState.SPIN )
	SetDiggerWiresState( eDiggerState.SPIN )

	thread DiggerWheel_SpinningIdle()
}

function DiggerWheel_SpinningIdle()
{
	level.diggerWheel.EndSignal( "OnDestroy" )

	if ( level.diggerState != eDiggerState.SPIN )
		return

	EmitSoundOnEntity( level.diggerWheel, "DigSite_Scr_Digger_Spin_LP" )

	local currAnim = "spin_tension"
	local duration = level.diggerWheel.GetSequenceDuration( "spin_tension" )

	// needed to add waitingForRotation so we didn't call another PlayAnim if we are cancelling out of this anim
	while ( level.diggerState == eDiggerState.SPIN && !level.diggerWheel.s.waitingForRotation )
	{
		//printt( "spin start:", currAnim )
		thread PlayAnim( level.diggerWheel, currAnim )
		wait duration

		if ( currAnim == "spin_tension" )
			currAnim = "spin_tension_dupe"
		else
			currAnim = "spin_tension"

		level.diggerWheel.Signal( "DiggerWheelRotationDone" )
	}
}

function DiggerTwitch()
{
	level.diggerWheel.EndSignal( "OnDestroy" )

	if ( level.diggerState == eDiggerState.TWITCH )
		return

	SetDiggerState( eDiggerState.TWITCH )
	SetDiggerWiresState( eDiggerState.TWITCH )

	FadeOutSoundOnEntity( level.diggerWheel, "DigSite_Scr_Digger_Spin_LP", 0.5 )
	EmitSoundOnEntity( level.diggerWheel, "DigSite_Scr_Digger_Spindown_Twitch_Spinup" )

	local duration = level.diggerWheel.GetSequenceDuration( "spin_twitch" )
	thread PlayAnim( level.diggerWheel, "spin_twitch" )
	wait duration

	//printt( "twitch done" )
}


function SetDiggerState( state )
{
	local table = getconsttable().eDiggerState
	local foundIt = false
	foreach( key, val in table )
	{
		if ( state == val )
		{
			foundIt = key
			break
		}
	}
	Assert( foundIt, "Couldn't set unknown eDiggerState: " + state )

	level.diggerState = state
}

// server controls grinder status
function HarmonyMines_Server_GrinderInit()
{
	if ( !IsCaptureMode() )
	{
		thread GrinderCycle()
		return
	}

	Grinder_SetState( true )

	// let hardpoint entities get set up
	while ( !level.hardpointModeInitialized )
		wait 0

	local hardpoint = GetHardpointByID( 2 )
	AddHardpointTeamSwitchCallback( hardpoint, GrinderHardpointSwitch )
}

function Grinder_GetState()
{
	return level.grinderOn
}

function Grinder_SetState( newState )
{
	Assert( type( newState ) == "bool" )

	if ( newState == Grinder_GetState() )
		return

	level.grinderOn = newState

	if ( level.grinderOn )
		level.nv.grinderOnTime = Time()
	else
		level.nv.grinderOffTime = Time()
}

function GrinderHardpointSwitch( hardpoint, previousTeam )
{
	local team = hardpoint.GetTeam()

	//printt( "Hardpoint Switch, team:", team, "previousTeam:", previousTeam )

	switch ( team )
	{
		case level.HOME_TEAM:
			break

		case level.AWAY_TEAM:
			Grinder_SetState( false )
			break

		default:
			Grinder_SetState( true )
	}
}

function GrinderCycle()
{
	level.ent.Signal( "StopGrinderThink" )
	level.ent.EndSignal( "StopGrinderThink" )

	local cycleTime = 20
	local preCycleWarningTime = 3

	while ( 1 )
	{
		if ( !Grinder_GetState() )
		{
			Grinder_SetState( true )
			wait cycleTime

			//wait cycleTime - preCycleWarningTime
			//printt( "state changing to OFF in", preCycleWarningTime, "secs" )
			//wait preCycleWarningTime

		}
		else
		{
			Grinder_SetState( false )
			wait cycleTime

			//wait cycleTime - preCycleWarningTime
			//printt( "state changing to ON in", preCycleWarningTime, "secs" )
			//wait preCycleWarningTime

		}
	}
}

function EvacSetup()
{
	local spectatorNode1 = GetEnt( "spec_cam1" )
	local spectatorNode2 = GetEnt( "spec_cam2" )
	local spectatorNode3 = GetEnt( "spec_cam3" )

	local vtolAnimPack = Evac_CreateAnimPackage( "dropship_VTOL_evac_start", "dropship_VTOL_evac_idle", "dropship_VTOL_evac_end" )

	Evac_AddLocation( "escape_node1", spectatorNode1.GetOrigin(), spectatorNode1.GetAngles(), vtolAnimPack )
	Evac_AddLocation( "escape_node2", spectatorNode2.GetOrigin(), spectatorNode2.GetAngles(), vtolAnimPack )
	Evac_AddLocation( "escape_node3", spectatorNode3.GetOrigin(), spectatorNode3.GetAngles(), vtolAnimPack )

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

function GetScriptPos( player = null )
{
	if ( !player )
		player = gp()[0]

	local pos = player.GetOrigin()
	local ang = player.GetAngles()

	local returnStr = "origin = Vector( " + pos.x + ", " + pos.y + ", " + pos.z + " ), angles = Vector( 0, " + ang.y + ", 0 )"
	return returnStr
}


main()
