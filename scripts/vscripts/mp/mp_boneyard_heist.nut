const WARNING_LIGHT_ON_MODEL	= "models/lamps/warning_light_ON_orange.mdl"
const WARNING_LIGHT_OFF_MODEL 	= "models/lamps/warning_light.mdl"
const LEVIATHAN_MODEL 			= "models/Creatures/leviathan/leviathan_brown_background.mdl"

const PULSE_FAIL_ANIM			= "dog_whistle_tower_boneyard_pulsefail"
const PULSE_SUCCESS_ANIM		= "dog_whistle_tower_boneyard_pulsesuccess"
const PULSE_EXPLODE_ANIM		= "dog_whistle_tower_boneyard_fall"
const TOWER_IDLE_ANIM			= "idle"
const TOWER_IDLE_SUCCESS_ANIM	= "idle_success"

const BARKER_MODEL				= "models/humans/mcor_hero/barker/mcor_hero_barker.mdl"

const AI_CHATTER_RECENT_PULSE_LENGTH	= 45

function main()
{
	if ( reloadingScripts )
		return

	// block an unclipped area
	AddTitanfallBlocker( Vector(-228, 1710, 1000), 550, 5000 )
	AddTitanfallBlocker( Vector(-5123, -3398, 983), 200, 5000 )
	AddTitanfallBlocker( Vector(-5256, -3759, 961), 200, 5000 )
	AddTitanfallBlocker( Vector(-5358, -4084, 937), 200, 5000 )
	AddTitanfallBlocker( Vector(-5021, -3091, 875), 200, 5000 )
	AddTitanfallBlocker( Vector(-2701, 1862, 934), 200, 5000 )

	PrecacheModel( LEVIATHAN_MODEL )
	PrecacheModel( WARNING_LIGHT_ON_MODEL )
	PrecacheModel( WARNING_LIGHT_OFF_MODEL )
	PrecacheModel( MAC_MODEL )
	PrecacheModel( BARKER_MODEL )
	PrecacheModel( BLISK_MODEL )

	IncludeFile( "_flyers_shared" )

	level.progressFuncArray		<- []
	level.progressFuncActive	<- false
	RegisterServerVarChangeCallback( "matchProgress", MatchProgressChanged )

	level.nextDropshipFlyerAttack <- 120
	level.skyboxCamOrigin <- Vector( -3584.0, 12032.0, -12032.0 )
	level.lastPulseTime <- 0

	RegisterSignal( "idle_end" )	// signaled from tower idle anim
	RegisterSignal( "towerPulse" )
	RegisterSignal( "testPulse" )
	RegisterSignal( "EndFlyerPopulate" )
	RegisterSignal( "BurnDamage" )

	FlagSet( "FlyerPickupAnalysis" )

	level.defenseTeam = TEAM_MILITIA

	level.playCinematicContent <- false
	if ( GetCinematicMode() && IsCaptureMode() )
		level.playCinematicContent = true

	if ( !level.playCinematicContent )
	{
		// early out if not in campaign and hardpoint mode
		FlagSet( "IntroDone" )
		return
	}
	else
	{
		SetGameModeAnnouncement( "GameModeAnnounce_CP" )
		GM_AddEndRoundFunc( EndRoundMain )

		RegisterSignal( "StopPath" )

		FlagInit( "Boneyard_StartIntroFlyIn" )

		RegisterSignal( "StopShaking" )

		FlagClear( "AnnounceProgressEnabled" )

		FlagSet( "CinematicIntro" )
		FlagSet( "CinematicOutro" )

		level.levelSpecificChatterFunc = BoneyardSpecificChatter
	}
}

function EntitiesDidLoad()
{
	if ( !IsServer() )
		return

	thread NpcFlyerPickupThink( { minStart = 50.0, maxStart = 60.0, minEnd = 20.0, maxEnd = 30.0 } )	// Starts script that looks for exposed NPC for flyers to pick up.
	//thread LeviathanRun()
	thread PerchedFlyerSetup()
	thread SetupDogWhistle()

	if ( EvacEnabled() ) //모드별 설정 선택
	{
		/*if ( GameRules.GetGameMode() == HEIST )
		{
			EvacSetupforHeist()
		}
		else
		{*/
			EvacSetup()
		//}
	}

	if ( !level.playCinematicContent )
	{
		AddProgressionFunc( 5, ProgressDropshipAttack, true )	// after 5% it will be called every time.
		thread DogWhistleIdle()
		return
	}
	else
	{
		// doing custom win and lose announcement when campaign and hardpoint mode
		FlagClear( "AnnounceWinnerEnabled" )

		thread IntroMain()
		thread SetupProgression()
	}
}

/*--------------------------------------------------------------------------------------------------------*\
|
|											  MISSION PROGRESS
|
\*--------------------------------------------------------------------------------------------------------*/


function SetupProgression()
{
	if ( GameRules.GetGameMode() == CAPTURE_POINT )
	{
		AddProgressionFunc( 15, HardpointPowerBurst )
		AddProgressionFunc( 40, HardpointPowerBurst )
		AddProgressionFunc( 60, HardpointPowerBurst )
		AddProgressionFunc( 75, HardpointPowerBurst )
		AddProgressionFunc( 85, HardpointPowerBurst )
	}

	// don't change number here without changing matching number in the client script
	AddProgressionFunc( 5, ProgressDropshipAttack, true )	// after 5% it will be called every time.
	AddProgressionFunc( 25, ProgressStage_Early )		// blurb 1 - 100
	AddProgressionFunc( 35, ProgressStage_ForcedPulse )	// blurb 2 - 140 ( only if pulse hasn't pulsed )
	AddProgressionFunc( 55, ProgressStage_Middle )		// blurb 3 - 220
	AddProgressionFunc( 80, ProgressStage_Late )		// blurb 4 - 320
	AddProgressionFunc( 96, ProgressStage_End )
}

function AdvanceProgression( team = TEAM_MILITIA )
{
	wait 0.5

	local steps = [ 25, 35, 55, 80 ]
	local maxScore  = GetScoreLimit_FromPlaylist()
	local teamScore = GameRules.GetTeamScore( team )
	local progress = level.nv.matchProgress

	foreach( step in steps )
	{
		if ( progress >= step )
			continue

		local goalScore = maxScore * ( step.tofloat() / 100.0 )
		AddTeamScore( team, goalScore - teamScore )
		return
	}
}


function ProgressStage_Early()
{
	if ( level.devForcedWin )  //Don't announce progress if we force win
		return

	SetGlobalForcedDialogueOnly( true )

	local winningTeam = GetWinningTeam()
	if ( winningTeam == TEAM_MILITIA || winningTeam == TEAM_UNASSIGNED )
	{
		ForcePlayConversationToTeam( "Blurb_1_Militia_Lead", TEAM_MILITIA )
		wait 4
		//thread TowerMinorPulse()
		ForcePlayConversationToTeam( "Blurb_1_Militia_Lead", TEAM_IMC )
		wait 20	// how long to wait before allowing normal dialog etc again
	}
	else
	{
		ForcePlayConversationToAll( "Blurb_1_IMC_Lead" )
		wait 20	// how long to wait before allowing normal dialog etc again
	}

	SetGlobalForcedDialogueOnly( false )
}

function ProgressStage_ForcedPulse()
{
	if ( level.devForcedWin )  //Don't announce progress if we force win
		return

	if ( level.nv.pulseCount )
		return

	SetGlobalForcedDialogueOnly( true )

	local winningTeam = GetWinningTeam()
	if ( winningTeam == TEAM_MILITIA || winningTeam == TEAM_UNASSIGNED )
	{
		ForcePlayConversationToTeam( "Blurb_2_Militia_Lead", TEAM_MILITIA )
		wait 2
		//thread TowerMinorPulse()
		ForcePlayConversationToTeam( "Blurb_2_Militia_Lead", TEAM_IMC )
		wait 15	// how long to wait before allowing normal dialog etc again
	}
	else
	{
		ForcePlayConversationToTeam( "Blurb_2_IMC_Lead", TEAM_IMC )
		wait 1
		//thread TowerMinorPulse()
		wait 2
		ForcePlayConversationToTeam( "Blurb_2_IMC_Lead", TEAM_MILITIA )
		wait 20	// how long to wait before allowing normal dialog etc again
	}

	SetGlobalForcedDialogueOnly( false )
}

function ProgressStage_Middle()
{
	if ( level.devForcedWin )  //Don't announce progress if we force win
		return

	local winningTeam = GetWinningTeam()
	if ( winningTeam == TEAM_MILITIA || winningTeam == TEAM_UNASSIGNED )
	{
		waitthread StopTowerIdle()	// stop the tower at the end of the idle
		SetGlobalForcedDialogueOnly( true )

		ForcePlayConversationToTeam( "Blurb_3_Militia_Lead", TEAM_MILITIA )
		wait 5
		//thread TowerMinorPulse()
		ForcePlayConversationToTeam( "Blurb_3_Militia_Lead", TEAM_IMC )
		wait 25	// how long to wait before allowing normal dialog etc again
	}
	else
	{
		SetGlobalForcedDialogueOnly( true )
		ForcePlayConversationToAll( "Blurb_3_IMC_Lead" )
		// increment count so that if the Militia gain the lead they will get the correct client VDU etc.
		level.nv.pulseCount++
		wait 20	// how long to wait before allowing normal dialog etc again
	}

	SetGlobalForcedDialogueOnly( false )
}

function ProgressStage_Late()
{
	if ( level.devForcedWin )  //Don't announce progress if we force win
		return

	local winningTeam = GetWinningTeam()
	if ( winningTeam == TEAM_MILITIA || winningTeam == TEAM_UNASSIGNED )
	{
		waitthread StopTowerIdle()	// stop the tower at the end of the idle
		SetGlobalForcedDialogueOnly( true )

		ForcePlayConversationToTeam( "Blurb_4_Militia_Lead", TEAM_MILITIA )
		wait 1
		//thread TowerMinorPulse()
		ForcePlayConversationToTeam( "Blurb_4_Militia_Lead", TEAM_IMC )
		wait 20	// how long to wait before allowing normal dialog etc again
	}
	else
	{
		SetGlobalForcedDialogueOnly( true )
		ForcePlayConversationToAll( "Blurb_4_IMC_Lead" )
		wait 20	// how long to wait before allowing normal dialog etc again
	}

	SetGlobalForcedDialogueOnly( false )
}

function ProgressStage_End()
{
	if ( level.devForcedWin )  //Don't announce progress if we force win
		return

	// Stop the tower idle so that we don't have to wait for it when the match ends.
	thread StopTowerIdle()	// stop the tower at the end of the idle
}

function AddProgressionFunc( progress, func, everyTime = false )
{
	local funcTable = {}
	funcTable.func			<- func
	funcTable.progress		<- progress
	funcTable.everyTime		<- everyTime
	funcTable.scope			<- this
	funcTable.called		<- false
	funcTable.done			<- false

	level.progressFuncArray.append( funcTable )
}

function MatchProgressChanged()
{
	thread MatchProgressChangedThread()
}


function MatchProgressChangedThread()
{
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

		waitthread funcTable.func()

		if ( !funcTable.everyTime )
			funcTable.done = true
	}
}

function ProgressDropshipAttack()
{
	if ( level.devForcedWin )  //Don't announce progress if we force win
		return

	// printt( "ProgressDropshipAttack" )
	// check to see if the next dropship should be attacked by flyers
	if ( ShouldFlyersAttackDropship() )
		NextDropshipAttackedByFlyers( RandomInt( 2, 4 ) ) // two or three flyers attack
}

function ShouldFlyersAttackDropship()
{
	if ( Time() < level.nextDropshipFlyerAttack )
		return false

	// success, flyers are going to attack the next dropship
	// lets figure out how long to wait for the one after that

	local minAtStart = 70
	local maxAtStart = 140
	local minAtEnd	 = 30
	local maxAtEnd	 = 60

	local min = GraphCapped( level.nv.matchProgress, 1, 100, minAtStart, minAtEnd ).tointeger()
	local max = GraphCapped( level.nv.matchProgress, 1, 100, maxAtStart, maxAtEnd ).tointeger()

	level.nextDropshipFlyerAttack = RandomInt( min, max ) + Time()
//	printt( "level.nextDropshipFlyerAttack", level.nextDropshipFlyerAttack, min, max )

	return true
}

function SetupDogWhistle()
{
	level.dogWhistle <- GetEnt( "dog_whistle" )
	level.dogWhistle.s.idle <- false
	level.dogWhistle.s.origin <- level.dogWhistle.GetOrigin()
	level.dogWhistle.s.angles <- level.dogWhistle.GetAngles()
	level.dogWhistle.s.majorPulse <- false
	level.dogWhistle.s.deathClip <- GetEnt( "tower_building_clip" )

	AddAnimEvent( level.dogWhistle, "tower_pulse_fail", TowerPulseFailEvent )
	AddAnimEvent( level.dogWhistle, "tower_pulse_success", TowerPulseSuccessEvent )

	// store the kill delay of each indoor area
	local distPerSec = 1000.0

	level.indoorTriggerArray <- GetEntArrayByClass_Expensive( "trigger_indoor_area" )
	foreach( trigger in level.indoorTriggerArray )
	{
		local dist = Distance( level.dogWhistle.GetOrigin(), trigger.GetOrigin() )
		trigger.s.delay <- dist / distPerSec
		trigger.s.titanDeath <- false
	}

	level.burnTriggerArray <- GetEntArrayByNameWildCard_Expensive( "BoneyardDeathTrigger*" )
	foreach( trigger in level.burnTriggerArray )
	{
		local dist = Distance( level.dogWhistle.GetOrigin(), trigger.GetOrigin() )
		trigger.s.delay <- dist / distPerSec
		trigger.s.titanDeath <- false
	}

	local titanBurnTriggerArray = GetEntArrayByNameWildCard_Expensive( "BoneyardTitanDeathTrigger*" )
	foreach( trigger in titanBurnTriggerArray )
	{
		local dist = Distance( level.dogWhistle.GetOrigin(), trigger.GetOrigin() )
		trigger.s.delay <- dist / distPerSec
		trigger.s.titanDeath <- true
	}

	level.burnTriggerArray.extend( titanBurnTriggerArray )
}

function TowerMinorPulse()
{
	level.dogWhistle.Signal( "testPulse" )
	level.dogWhistle.EndSignal( "testPulse" )

	//level.nv.pulseImminent = true
	level.nv.pulseCount++

//	printt( "TowerMinorPulse" )
	PlayAnim( level.dogWhistle, PULSE_FAIL_ANIM, level.dogWhistle, null, 0.0 )

	thread DogWhistleIdle()

	wait 10
	// starts adding back flyers
	//level.nv.pulseImminent = false
}

function TowerPulseFailEvent( tower )
{
	tower.Signal( "towerPulse" )
	level.lastPulseTime = Time()

	ScarePerchedFlyers()

	local players = GetLivingPlayers()
	foreach( player in players )
	{
		if ( player.IsTitan() )
			Remote.CallFunction_Replay( player, "ServerCallback_TitanEMP", 0.10, 0.5, 2.0 )
		else
			Remote.CallFunction_Replay( player, "ServerCallback_PilotEMP", 0.10, 0.5, 2.0 )
	}
}

function TowerMajorPulse()
{
	level.dogWhistle.Signal( "testPulse" )
	level.dogWhistle.EndSignal( "testPulse" )

	//level.nv.pulseImminent = true
	level.nv.pulseCount = 4

	// printt( "TowerMajorPulse" )
	PlayAnim( level.dogWhistle, PULSE_SUCCESS_ANIM, level.dogWhistle, null, 0.0 )
	thread DogWhistleIdle( true )
}

function TowerPulseSuccessEvent( tower )
{
	tower.Signal( "towerPulse" )
	tower.s.majorPulse = true
	level.lastPulseTime = Time()

	ScarePerchedFlyers()

	local players = GetLivingPlayers()
	foreach( player in players )
	{
		if ( player.IsTitan() )
			Remote.CallFunction_Replay( player, "ServerCallback_TitanEMP", 0.15, 2.0, 4.0 )
		else
			Remote.CallFunction_Replay( player, "ServerCallback_PilotEMP", 0.15, 2.0, 4.0 )
	}
}

function RemoveIndoorSpawns()
{
	// remove any spawnpoints that doesn't have the spawn_outdoors key
	local spawnpointArray = GetEntArrayByClass_Expensive( "info_spawnpoint_human" )
	foreach( spawnpoint in spawnpointArray )
	{
		if ( spawnpoint.HasKey( "spawn_outdoors" ) )
			continue
		spawnpoint.Destroy()
	}
}

function TowerExplode( delay = 20 )
{
	level.dogWhistle.Signal( "testPulse" )
	level.dogWhistle.EndSignal( "testPulse" )

	local players = GetPlayerArray()
	foreach ( player in players )
		Remote.CallFunction_NonReplay( player, "ServerCallback_TowerExplosion", delay )

	local soundSpacing = 0.45
	wait max( delay - soundSpacing, 0 )

	EmitSoundOnEntity( level.dogWhistle, "boneyard_scr_dogwhistle_explosion" )
	wait soundSpacing

	local origin = level.dogWhistle.s.origin
	local angles = level.dogWhistle.s.angles

	thread PlayAnimTeleport( level.dogWhistle, PULSE_EXPLODE_ANIM, origin, angles )

	ScarePerchedFlyers()
}

function InfernoDeath( trigger, delay, instantDeath )
{
	trigger.EndSignal( "OnDestroy" )

	wait delay

	if ( instantDeath )
	{
		trigger.ConnectOutput( "OnStartTouch", TriggerInDoorDeath )
	}
	else
	{
		trigger.ConnectOutput( "OnStartTouch", TriggerBurnDamage )
		trigger.ConnectOutput( "OnEndTouch", TriggerBurnDamageOff )
	}

	local touchingEnts = trigger.GetTouchingEntities()
	foreach( ent in touchingEnts )
	{
		if ( ( ent.IsPlayer() || ent.IsNPC() ) && IsAlive( ent ) )
			ent.Die( level.worldspawn, level.worldspawn, { scriptType = DF_INSTANT, damageSourceId = eDamageSourceId.indoor_inferno } )
	}
}

function TriggerInDoorDeath( self, activator, caller, value )
{
	if ( ( activator.IsPlayer() || activator.IsNPC() ) && IsAlive( activator ) )
	{
		if ( activator.IsTitan() )
			return	// don't kill titans

		activator.Die( self, self, { scriptType = DF_INSTANT, damageSourceId = eDamageSourceId.indoor_inferno } )
	}
}

function TriggerBurnDamage( self, activator, caller, value )
{
	if ( IsAlive( activator ) && ( activator.IsPlayer() || activator.IsNPC() ) )
	{
		if ( activator.IsTitan() && !self.s.titanDeath )
			return	// don't damage titans unless the triggers s.titanDeath is true

		thread TriggerBurnDamageThread( activator, self )
	}
}

function TriggerBurnDamageThread( guy, trigger )
{
	guy.EndSignal( "OnDeath" )
	guy.EndSignal( "OnDestroy" )
	guy.EndSignal( "BurnDamage" )

	local damage = guy.GetMaxHealth() / 10

	while( true )
	{
		guy.TakeDamage( damage, trigger, trigger, { scriptType = DF_INSTANT, damageSourceId = eDamageSourceId.burn } )
		wait 0.25
	}
}

function TriggerBurnDamageOff( self, activator, caller, value )
{
	if ( IsAlive( activator ) && ( activator.IsPlayer() || activator.IsNPC() ) )
	{
		if ( activator.IsTitan() && !self.s.titanDeath )
			return	// don't damage titans unless the triggers s.titanDeath is true

		activator.Signal( "BurnDamage" )
	}
}

function DogWhistleIdle( success = false )
{
	level.dogWhistle.s.idle = true

	local anim = TOWER_IDLE_ANIM
	if ( success )
		anim = TOWER_IDLE_SUCCESS_ANIM

	PlayAnim( level.dogWhistle, anim, level.dogWhistle, null, 0.0 )
}

function StopTowerIdle()
{
	waitthread WaitForDogWhistleIdle()

	level.dogWhistle.s.idle = false
	level.dogWhistle.Anim_Stop()
}

function WaitForDogWhistleIdle()
{
	if ( level.dogWhistle.s.idle )
	{
		level.dogWhistle.WaitSignal( "idle_end" )
	}
}

function EndRoundMain()
{
	// make sure no more AI is spawned
	FlagSet( "Disable_IMC" )
	FlagSet( "Disable_MILITIA" )
	level.ent.Signal( "EndFlyerPopulate" )

	local winningTeam = GetWinningTeam()

	if ( winningTeam == TEAM_IMC )
		thread EndRoundIMCWin()
	else
		thread EndRoundMCORWin()

	//-------------------------
	// Break AI out of global logic and have them run towards the evac point
	//-------------------------
	foreach( hardpoint in level.hardpoints )
	{
		// stop hardpoint ai think function
		hardpoint.Signal( "SquadCapturePointThink_TEAM_IMC" )
		hardpoint.Signal( "SquadCapturePointThink_TEAM_MILITIA" )
	}

	local nearestNode = GetNearestNodeToPos( level.evacNode.GetOrigin() )
	local nodeArray = GetNeighborNodes( nearestNode, 24, HULL_HUMAN )
	local npcArray = GetGruntsAndSpectres()

	foreach( index, npc in npcArray )
	{
		if( IsValid( npc ) )
		{
			npc.SetHealth( 1 )
			npc.Signal( "StopHardpointBehavior" )

			local node = nodeArray[ index % nodeArray.len() ]
			local origin = GetNodePos( node, HULL_HUMAN )

			local point = npc.s.assaultPoint
			point.kv.stopToFightEnemyRadius = 512
			point.kv.allowdiversionradius = 0
			point.kv.allowdiversion = 0
			point.kv.faceAssaultPointAngles = 0
			point.kv.assaulttolerance = 512
			point.kv.nevertimeout = 0
			point.kv.strict = 1
			point.kv.forcecrouch = 0
			point.kv.spawnflags = 0
			point.kv.clearoncontact = 0
			point.kv.assaulttimeout = 3.0
			point.kv.arrivaltolerance = 512
			point.SetOrigin( origin )

			npc.AssaultPointEnt( point )
		}
	}
}

function EndRoundIMCWin()
{
	// no more spawning indoors
	RemoveIndoorSpawns()
	local delay = 17
	thread TowerExplode( delay )	// explode in 17 seconds

	SetGlobalForcedDialogueOnly( true )
	ForcePlayConversationToAll( "IMCWin" )

	wait delay

	// block players from entering the dog whistle tower. anyone already inside will be killed.
	level.dogWhistle.s.deathClip.Fire( "enable" )

	foreach( trigger in level.indoorTriggerArray )
	{
		thread InfernoDeath( trigger, trigger.s.delay, true )
	}

	foreach( trigger in level.burnTriggerArray )
	{
		thread InfernoDeath( trigger, trigger.s.delay, false )
	}

	wait 5
	ForcePlayConversationToAll( "epilogue_mid_imc_win" )

	wait 22 // IMC side is the longer conversation
	SetGlobalForcedDialogueOnly( false )

	FlagWait( "EvacShipArrive" )
	wait 4

	SetGlobalForcedDialogueOnly( true )

	ForcePlayConversationToTeam( "post_epilogue_loss", TEAM_MILITIA )
	ForcePlayConversationToTeam( "post_epilogue_win", TEAM_IMC )

	wait 16
	SetGlobalForcedDialogueOnly( false )
}

function EndRoundMCORWin()
{
	SetGlobalForcedDialogueOnly( true )
	ForcePlayConversationToAll( "MilitiaWin" )

	wait 4
	thread TowerMajorPulse()

	wait 15
	ForcePlayConversationToTeam( "epilogue_mid_militia_win", TEAM_IMC )
	ForcePlayConversationToTeam( "epilogue_mid_militia_win", TEAM_MILITIA )

	wait 21 // IMC side is the longer conversation

	SetGlobalForcedDialogueOnly( false )

	FlagWait( "EvacShipArrive" )
	wait 4

	SetGlobalForcedDialogueOnly( true )

	ForcePlayConversationToTeam( "post_epilogue_win", TEAM_MILITIA )
	ForcePlayConversationToTeam( "post_epilogue_loss", TEAM_IMC )

	wait 16
	SetGlobalForcedDialogueOnly( false )
}

/*--------------------------------------------------------------------------------------------------------*\
|
|						CAPTUREPOINT
|
\*--------------------------------------------------------------------------------------------------------*/

function HardpointPowerBurst()
{
	local players = GetPlayerArray()
	foreach ( player in players )
		Remote.CallFunction_Replay( player, "ServerCallback_HardpointPowerBurst" )
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

function PerchedFlyerSetup()
{
	local perchLocations = []
	perchLocations.append( { origin = Vector( -4888, -3415, 981 ),	angles = Vector( 0, 23, 0 ) } )
	perchLocations.append( { origin = Vector( -2231, -2370, 699 ),	angles = Vector( 0, -61, 0 ) } )
	perchLocations.append( { origin = Vector( -1499, -1925, 653 ),	angles = Vector( 0, -30, 0 ) } )
	perchLocations.append( { origin = Vector( -1163, 2657, 689 ),	angles = Vector( 0, -146, 0 ) } )
	perchLocations.append( { origin = Vector( -2533, 2166, 941 ),	angles = Vector( 0, -23, 0 ) } )

	perchLocations.append( { origin = Vector( -2764, 1720, 916 ),	angles = Vector( 0, -42, 0 ) } )
	perchLocations.append( { origin = Vector( 427, -1048, 400 ),	angles = Vector( 0, 95, 0 ) } )
	perchLocations.append( { origin = Vector( 726, 2551, 726 ),		angles = Vector( 0, -36, 0 ) } )
	perchLocations.append( { origin = Vector( 1850, 249, 574 ),		angles = Vector( 0, -10, 0 ) } )
	perchLocations.append( { origin = Vector( -900, 1411, 1352 ),	angles = Vector( 0, -81, 0 ) } )

	perchLocations.append( { origin = Vector( -1781, 3193, 861 ),	angles = Vector( 0, -144, 0 ) } )
	perchLocations.append( { origin = Vector( 352, 3213, 1214 ),	angles = Vector( 0, 10, 0 ) } )
	perchLocations.append( { origin = Vector( -3219, -3843, 700 ),	angles = Vector( 0, 55, 0 ) } )
	perchLocations.append( { origin = Vector( -3775, 1291, 1258 ),	angles = Vector( 0, -11, 0 ) } )
	perchLocations.append( { origin = Vector( -952, 3204, 1057 ),	angles = Vector( 0, 174, 0 ) } )

	perchLocations.append( { origin = Vector( -2901, -1972, 446 ),	angles = Vector( 0, 34, 0 ) } )
	perchLocations.append( { origin = Vector( 2292, 1294, 816 ),	angles = Vector( 0, -19, 0 ) } )
	perchLocations.append( { origin = Vector( -2766, -94, 242 ),	angles = Vector( 0, 68, 0 ) } )
	perchLocations.append( { origin = Vector( -1071, 2043, 806 ),	angles = Vector( 0, -124, 0 ) } )
	perchLocations.append( { origin = Vector( -5272, -3963, 959 ),	angles = Vector( 0, -15, 0 ) } )

	perchLocations.append( { origin = Vector( -1149, -1963, 538 ),	angles = Vector( 0, 26, 0 ) } )
	perchLocations.append( { origin = Vector( -3387, -1997, 410 ),	angles = Vector( 0, -59, 0 ) } )
	perchLocations.append( { origin = Vector( -564, -2263, 169 ),	angles = Vector( 0, -84, 0 ) } )
	perchLocations.append( { origin = Vector( -2241, -3191, 175 ),	angles = Vector( 0, -77, 0 ) } )
	perchLocations.append( { origin = Vector( -1386, -4318, 477 ),	angles = Vector( 0, 163, 0 ) } )

	// No landing, pre placment locations only
	local perchNoLanding = []
	perchNoLanding.append( { origin = Vector( -3771, -2538, 396 ),	angles = Vector( 0, -0, 0 ) } )
	perchNoLanding.append( { origin = Vector( -2172, -2041, 788 ),	angles = Vector( 0, -152, 0 ) } )
	perchNoLanding.append( { origin = Vector( 1374, -1421, 728 ),	angles = Vector( 0, 117, 0 ) } )
	perchNoLanding.append( { origin = Vector( -500, 476, 346 ),		angles = Vector( 0, 179, 0 ) } )
	perchNoLanding.append( { origin = Vector( -3696, 211, 819 ),	angles = Vector( 0, 0, 0 ) } )

	perchNoLanding.append( { origin = Vector( -3278, 778, 328 ),	angles = Vector( 0, 0, 0 ) } )
	perchNoLanding.append( { origin = Vector( -3121, 2049, 673 ),	angles = Vector( 0, 160, 0 ) } )
	perchNoLanding.append( { origin = Vector( -3646, 1473, 816 ),	angles = Vector( 0, 25, 0 ) } )
	perchNoLanding.append( { origin = Vector( -2036, 3509, 861 ),	angles = Vector( 0, -165, 0 ) } )
	perchNoLanding.append( { origin = Vector( -1025, -1136, 410 ),	angles = Vector( 0, 160, 0 ) } )

	perchNoLanding.append( { origin = Vector( 632, 698, 580 ),		angles = Vector( 0, 31, 0 ) } )
	perchNoLanding.append( { origin = Vector( -4591, -3696, 573 ),	angles = Vector( 0, -31, 0 ) } )
	perchNoLanding.append( { origin = Vector( -1375, 2725, 689 ),	angles = Vector( 0, -163, 0 ) } )
	perchNoLanding.append( { origin = Vector( -2724, 2004, 952 ),	angles = Vector( 0, 142, 0 ) } )
	perchNoLanding.append( { origin = Vector( -2554, -3132, 232 ),	angles = Vector( 0, -169, 0 ) } )

	level.perchNoLanding <- perchNoLanding
	level.perchLocations <- perchLocations
	level.occupiedPerches <- {} // perch = flyer

	thread PerchedFlyerPopulate()
}

function PerchedFlyerPopulate()
{
	// stop populating when the match is over
	level.ent.EndSignal( "EndFlyerPopulate" )
	local highend = GetCPULevelWrapper() == CPU_LEVEL_HIGHEND

	// indexes match a specific perch location in level.perchLocations or level.perchNoLanding
	foreach( index, perch in level.perchNoLanding )
	{
		AddPerchedFlyerByIndex( index, true )
		wait 0	// spreads a trace out over multiple frames
	}

	local indexArray = [ 1, 12, 19, 5, 10 ]
	foreach( index in indexArray )
	{
		AddPerchedFlyerByIndex( index )
		wait 0	// spreads a trace out over multiple frames
	}

	FlagWait( "IntroDone" )

	local countStart = 6
	local countEnd = highend ? 16 : 10		// less flyers on mid and min spec machines

	while( true )
	{
		wait 5	// check ever 5 seconds

		/*if ( level.nv.pulseImminent )
			continue*/

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
			/*if ( level.nv.pulseImminent )
				break*/

			local perch = level.perchLocations[ index++ ]
			if ( perch in level.occupiedPerches || IsPlayerNear( perch.origin ) )
				continue

			local flyer = CreatePerchedFlyer( perch.origin, perch.angles )
			level.occupiedPerches[ perch ] <- flyer

			wait RandomFloat( 0, 2 )	// So that they don't all land at the same time.
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
	wait RandomFloat( 0, 1.5 )
	flyer.TakeDamage( 10, flyer, null, null ) // damage the flyers so that they fly away fast
}

function AddPerchedFlyerByIndex( index, noLanding = false )
{
	local perch = level.perchLocations[ index ]
	if ( noLanding )
		perch = level.perchNoLanding[ index ]

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
|						LEVIATHAN
|
\*--------------------------------------------------------------------------------------------------------*/
function LeviathanRun()
{
	foreach( node in level.cinematicNodesByType[ CINEMATIC_TYPES.LEVIATHAN_SPAWN ] )
	{
		thread DoServerSideCinematicMPMoment( node )
	}

	local levNode1 = GetNodeByUniqueID( "cinematic_mp_node_lev01" )
	Assert( "leviathan" in levNode1 )
	local leviathan1 = levNode1.leviathan
	leviathan1.s.interrupted <- false
	leviathan1.SetName( "leviathan1" )
	SetLeviathanLevelFunc( leviathan1, LeviathanInterrupt )

	local levNode2 = GetNodeByUniqueID( "cinematic_mp_node_lev02" )
	Assert( "leviathan" in levNode2 )
	local leviathan2 = levNode2.leviathan
	leviathan2.s.interrupted <- false
	leviathan2.SetName( "leviathan2" )
	SetLeviathanLevelFunc( leviathan2, LeviathanInterrupt )

	local levNode3 = GetNodeByUniqueID( "cinematic_mp_node_lev03" )
	Assert( "leviathan" in levNode3 )
	local leviathan3 = levNode3.leviathan
	leviathan3.SetName( "leviathan3" )

	local levNode4 = GetNodeByUniqueID( "cinematic_mp_node_lev04" )
	Assert( "leviathan" in levNode4 )
	local leviathan4 = levNode4.leviathan
	leviathan4.SetName( "leviathan4" )
}

function LeviathanInterrupt( leviathan, var, resultTable )
{
	leviathan.EndSignal( "OnDestroy" )

	if ( level.nv.matchProgress < 100 )
		return	// don't change the return value

	if ( leviathan.s.interrupted )
		return

	if ( GetWinningTeam() == TEAM_IMC )
		return

	// if var is a bool we are waiting so lets return true to end the wait thread
	if ( type( var ) == "bool" )
	{
		//printt( "leviathan interrupt", leviathan )
		resultTable.resultVar = true
		return
	}

	// lets find the new path that the leviathan should walk
	local pathNodeList = {}
	pathNodeList.leviathan1 <- "cinematic_mp_node_path1"
	pathNodeList.leviathan2 <- "cinematic_mp_node_path2"

	Assert( leviathan.GetName() in pathNodeList )
	local name = leviathan.GetName()
	local pathNode = GetNodeByUniqueID( pathNodeList[ name ] )
	if ( "picked" in pathNode )
		return	// don't change the return value

	pathNode.picked <- true

	if ( leviathan.s.walking )
	{
		// still walking so come to a stop
		leviathan.s.walking = false
		waitthread PlayAnim( leviathan, "lev_trans_2_idle" )
	}

	while ( !level.dogWhistle.s.majorPulse )
	{
		thread PlayAnim( leviathan, "leviathan_idle_short" )
		level.dogWhistle.WaitSignal( "towerPulse" )
	}

	if ( name == "leviathan1" )
	{
		waitthread PlayAnim( leviathan, "leviathan_death" )
		leviathan.Signal( "EndLeviathanThink" )
	}
	else if ( name == "leviathan2" )
	{
		waitthread PlayAnim( leviathan, "leviathan_reaction_big" )
		waitthread PlayAnim( leviathan, "leviathan_reaction_howl" )
	}

	//printt( "leviathan new path", leviathan )
	leviathan.s.interrupted = true
	resultTable.resultVar = pathNode
}

/*--------------------------------------------------------------------------------------------------------*\
|
|							TEMP
|
\*--------------------------------------------------------------------------------------------------------*/
function ToggleSkyModel()
{
	local player = GetEntByIndex(1)
	if ( !( "skyboxModel" in player.s ) )
	{
		player.s.skyboxModel <-	CreatePropDynamic( "models/levels_terrain/mp_boneyard/boneyard_dunes01_lowpoly.mdl", GetEnt("skybox_cam_level" ).GetOrigin(), Vector(0,90,0) )
	}
	else
	{
		player.s.skyboxModel.Destroy()
		delete player.s.skyboxModel
	}
}


// DEV function to toggle player view between the skybox and the real world.
function TogglePlayerView()
{
	local player = GetEntByIndex(1)
	if ( !( "skyboxView" in player.s ) )
		player.s.skyboxView <- false

	local skyOrigin = GetEnt( "skybox_cam_level" ).GetOrigin()

	if ( !player.s.skyboxView )
	{
		ClientCommand( player, "sv_noclipspeed 0.1" )
		player.s.skyboxView = true
		local offset = player.GetOrigin()
		offset *= 0.001
		player.SetOrigin( skyOrigin + offset + Vector( 0, 0, -59.4 ) )
	}
	else
	{
		ClientCommand( player, "sv_noclipspeed 5" )
		player.s.skyboxView = false
		local offset = player.GetOrigin() - skyOrigin +	Vector( 0, 0, 59.4 )
		offset *= 1000

		if ( abs( offset.x ) > 15000 )
			offset = Vector( 0,0,2000 )
		if ( abs( offset.y ) > 15000 )
			offset = Vector( 0,0,2000 )
		if ( abs( offset.z ) > 15000 )
			offset = Vector( 0,0,2000 )

		player.SetOrigin( offset )
	}
}


/*--------------------------------------------------------------------------------------------------------*\
|
|													INTRO
|
\*--------------------------------------------------------------------------------------------------------*/

function IntroMain()
{
	if ( !level.playCinematicContent )
		return	// early out if not in campaign and hardpoint mode

	SetCustomIntroLength( 30 )	// tweak so that countdown ends as the guys jump out of the ship.

	FlagSet( "Disable_IMC" )
	FlagSet( "Disable_MILITIA" )

	IntroSetupMilitia()
	IntroSetupIMC()

	FlagWait( "ReadyToStartMatch" )

	SetGlobalForcedDialogueOnly( true )

	thread IntroMilitia()
	thread IntroIMC()

	wait 13	// tweak to get more or less time in the air before jumping out of the ship.

	FlagSet( "Boneyard_StartIntroFlyIn" )

	WaittillGameStateOrHigher( eGameState.Playing )	// this will be as the guys jump out of the ship

	wait 15.0	// arbitrary delay before dialog can start and the game mode announcement happens
	SetGlobalForcedDialogueOnly( false )
	FlagSet( "IntroDone" )

	wait 10.0	// let new ai spawn in as needed

	FlagClear( "Disable_IMC" )
	FlagClear( "Disable_MILITIA" )

	ReleaseCinematicNPC()
}

function ReleaseCinematicNPC()
{
//	printt( "*************************" )
//	printt( "** ReleaseCinematicNPC **" )
//	printt( "*************************" )

	local teamNames = [ "IMC", "MILITIA" ]
	local squadNames = [ "squad1", "squad2", "squad3" ]

	foreach( team in teamNames )
	{
		foreach( index, squadName in squadNames )
		{
			local combinedName = team + "_" + squadName
			if ( !GetNPCSquadSize( combinedName ) )
				continue

			local squad = GetNPCArrayBySquad( combinedName )

			foreach( npc in squad )
			{
				npc.SetLookDist( 5000 )
				npc.AllowHandSignals( true )
				npc.StayPut( false )
				npc.Signal( "StopPath" )
				//npc.DisableBehavior( "Assault" )
			}

			if ( squad.len() )
			{
				if ( GameRules.GetGameMode() == CAPTURE_POINT )
					JoinHPAssault( squad, index )
				else
					ScriptedSquadAssault( squad, index )
			}
		}
	}
}

function JoinHPAssault( guys, hardpointID )
{
	if ( !guys.len() )
		return

	local team = guys[ 0 ].GetTeam()
	local hardpoint
	local hardpoints = GetHardpoints()
	foreach( point in hardpoints )
	{
		if ( hardpointID != point.GetHardpointID() )
			continue

		hardpoint = point
		break
	}

	Assert( hardpoint )

	local hpIndex 		= GetHardpointIndex( hardpoint )
	local squadName 	= MakeSquadName( team, hpIndex )

//	printt( guys[0].kv.squadname, "goes to", hardpoint, "with new squadname", squadName )

	foreach( guy in guys )
	{
		// safety check
		if ( GetReservedSquadSize( squadName ) >= 4 )
			break

		SetSquad( guy, squadName )
	}

	thread SquadCapturePointThink( squadName, hardpoint, team )
}

function IntroSetupMilitia()
{
	//MILITIA SIDE
	////////////////////////////////////////////////////////////
	local create_1				= CreateCinematicDropship()
	create_1.origin 			= Vector( -1000, 4096, -11776 )
	create_1.team				= TEAM_MILITIA
	create_1.count 				= 4
	create_1.side 				= "jumpQuick"
	create_1.turret				= false

	local event_idle_1 			= CreateCinematicEvent()
	event_idle_1.origin 		= Vector( -1000, 4096, -11776 )
	event_idle_1.yaw	 		= 0
	event_idle_1.anim			= "dropship_player_intro_idle" // this is what plays behind the black screen?
	event_idle_1.teleport 		= true
	Event_AddFlagWaitToEnd( event_idle_1, "Boneyard_StartIntroFlyIn" )

	local event_flyin_1 		= CreateCinematicEvent()
	event_flyin_1.origin 		= Vector( -2749.151, 3942.313, 1399.25 )
	event_flyin_1.yaw			= 146.656
	event_flyin_1.anim			= "dropship_boneyard_flyin_mcor_R"
	event_flyin_1.teleport 		= true

	Event_AddAnimStartFunc( event_flyin_1, IntroMilitiaHeroes )
	Event_AddClientStateFunc( event_flyin_1, "CE_VisualSettingBoneyardMCOR" )
	Event_AddClientStateFunc( event_flyin_1, "CE_BloomOnRampOpenBoneyardMCOR" )
	Event_AddServerStateFunc( event_flyin_1, CE_BoneyardPlayerSkyScaleDesertMCOR )
	Event_AddServerStateFunc( event_flyin_1, CE_BoneyardPlayerSkyScaleOnRampOpenMCOR )

	AddSavedDropEvent( "introDropShipMCOR_1cr", create_1 )
	AddSavedDropEvent( "introDropShipMCOR_1e1", event_idle_1 )
	AddSavedDropEvent( "introDropShipMCOR_1e2", event_flyin_1 )

	////////////////////////////////////////////////////////////
	local create_2				= CreateCinematicDropship()
	create_2.origin 			= Vector( 1000, 4096, -11776 )
	create_2.team				= TEAM_MILITIA
	create_2.count 				= 4
	create_2.side 				= "jumpQuick"
	create_2.turret				= false

	local event_idle_2			= CreateCinematicEvent()
	event_idle_2.origin 		= Vector( 1000, 4096, -11776 )
	event_idle_2.yaw	 		= 0
	event_idle_2.anim			= "dropship_player_intro_idle"
	event_idle_2.teleport 		= true
	Event_AddFlagWaitToEnd( event_idle_2, "Boneyard_StartIntroFlyIn" )

	local event_flyin_2			= CreateCinematicEvent()
	event_flyin_2.origin 		= Vector( -3815.171, 3299.02, 1747.311 )
	event_flyin_2.yaw			= 146.656
	event_flyin_2.anim			= "dropship_boneyard_flyin_mcor_L"
	event_flyin_2.teleport 		= true

	Event_AddAnimStartFunc( event_flyin_2, IntroMilitiaHeroes )
	Event_AddClientStateFunc( event_flyin_2, "CE_VisualSettingBoneyardMCOR" )
	Event_AddClientStateFunc( event_flyin_2, "CE_BloomOnRampOpenBoneyardMCOR" )
	Event_AddServerStateFunc( event_flyin_2, CE_BoneyardPlayerSkyScaleDesertMCOR )
	Event_AddServerStateFunc( event_flyin_2, CE_BoneyardPlayerSkyScaleOnRampOpenMCOR )

	AddSavedDropEvent( "introDropShipMCOR_2cr", create_2 )
	AddSavedDropEvent( "introDropShipMCOR_2e1", event_idle_2 )
	AddSavedDropEvent( "introDropShipMCOR_2e2", event_flyin_2 )
}

function IntroSetupIMC()
{
	//IMC SIDE
	////////////////////////////////////////////////////////////
	local create_1				= CreateCinematicDropship()
	create_1.origin 			= Vector( 10000, 4096, -5112 )
	create_1.team				= TEAM_IMC
	create_1.count 				= 4
	create_1.side 				= "jumpQuick"
	create_1.turret				= false

	local event_idle_1 			= CreateCinematicEvent()
	event_idle_1.origin 		= Vector( 10000, 4096, -5112 )
	event_idle_1.yaw	 		= 0
	event_idle_1.anim			= "dropship_player_intro_idle"
	event_idle_1.teleport 		= true
	Event_AddFlagWaitToEnd( event_idle_1, "Boneyard_StartIntroFlyIn" )

	Event_AddAnimStartFunc( event_idle_1, IntroIMCHeroes )

	local event_flyin_1 		= CreateCinematicEvent()
	event_flyin_1.origin 		= Vector( -3580.699, -4775.866, 1149.72 )
	event_flyin_1.yaw			= 264.965
	event_flyin_1.anim			= "dropship_boneyard_flyin_imc_R"
	event_flyin_1.teleport		= true

	Event_AddClientStateFunc( event_flyin_1, "CE_VisualSettingBoneyardIMC" )
	Event_AddClientStateFunc( event_flyin_1, "CE_BloomOnRampOpenBoneyardIMC" )
	Event_AddServerStateFunc( event_flyin_1, CE_BoneyardPlayerSkyScaleDesertIMC )
	Event_AddServerStateFunc( event_flyin_1, CE_BoneyardPlayerSkyScaleOnRampOpenIMC )

	AddSavedDropEvent( "introDropShipIMC_1cr", create_1 )
	AddSavedDropEvent( "introDropShipIMC_1e1", event_idle_1 )
	AddSavedDropEvent( "introDropShipIMC_1e2", event_flyin_1 )

	////////////////////////////////////////////////////////////
	local create_2				= CreateCinematicDropship()
	create_2.origin 			= Vector( 10000, 4096, -5112 )
	create_2.team				= TEAM_IMC
	create_2.count 				= 4
	create_2.side 				= "jumpQuick"
	create_2.turret				= false

	local event_idle_2 			= CreateCinematicEvent()
	event_idle_2.origin 		= Vector( 10000, 4096, -5112 )
	event_idle_2.yaw	 		= 0
	event_idle_2.anim			= "dropship_player_intro_idle"
	event_idle_2.teleport		 = true
	Event_AddFlagWaitToEnd( event_idle_2, "Boneyard_StartIntroFlyIn" )

	Event_AddAnimStartFunc( event_idle_2, IntroIMCHeroes )

	local event_flyin_2 		= CreateCinematicEvent()
	event_flyin_2.origin 		= Vector( -2396.975, -4662.362, 1379.969 )
	event_flyin_2.yaw	 		= 304.462
	event_flyin_2.anim			= "dropship_boneyard_flyin_imc_L"
	event_flyin_2.teleport 		= true

	Event_AddClientStateFunc( event_flyin_2, "CE_VisualSettingBoneyardIMC" )
	Event_AddClientStateFunc( event_flyin_2, "CE_BloomOnRampOpenBoneyardIMC" )
	Event_AddServerStateFunc( event_flyin_2, CE_BoneyardPlayerSkyScaleDesertIMC )
	Event_AddServerStateFunc( event_flyin_2, CE_BoneyardPlayerSkyScaleOnRampOpenIMC )

	AddSavedDropEvent( "introDropShipIMC_2cr", create_2 )
	AddSavedDropEvent( "introDropShipIMC_2e1", event_idle_2 )
	AddSavedDropEvent( "introDropShipIMC_2e2", event_flyin_2 )
}

function IntroMilitia()
{
	local table 	= GetSavedDropEvent( "introDropShipMCOR_2cr" )
	local event1 	= GetSavedDropEvent( "introDropShipMCOR_2e1" )
	local event2 	= GetSavedDropEvent( "introDropShipMCOR_2e2" )
	local dropship2 = SpawnCinematicDropship( table )
	thread RunCinematicDropship( dropship2, event1, event2 )

	local table 	= GetSavedDropEvent( "introDropShipMCOR_1cr" )
	local event1 	= GetSavedDropEvent( "introDropShipMCOR_1e1" )
	local event2 	= GetSavedDropEvent( "introDropShipMCOR_1e2" )
	local dropship1 = SpawnCinematicDropship( table )
	thread RunCinematicDropship( dropship1, event1, event2 )

	thread IntroMCORExperience( dropship1, dropship2 )
//	DebugSkipCinematicSlots( TEAM_MILITIA, 4 )

	thread IntroMilitiaDialog()
	thread IntroMilitiaFlyers()
	thread IntroMilitiaGrunts()
}

function IntroMilitiaHeroes( dropship, ref, table )
{
	dropship.EndSignal( "OnDeath" )

	local pilot = CreatePropDynamic( TEAM_MILITIA_GRUNT_MDL )
	local mac = CreatePropDynamic( MAC_MODEL )
	local barker = CreatePropDynamic( BARKER_MODEL )

	pilot.SetParent( dropship, "ORIGIN" )
	mac.SetParent( dropship, "ORIGIN" )
	dropship.s.mac <- mac
	barker.SetParent( dropship, "ORIGIN" )
	dropship.s.barker <- barker

	pilot.MarkAsNonMovingAttachment()
	mac.MarkAsNonMovingAttachment()
	barker.MarkAsNonMovingAttachment()

	pilot.LerpSkyScale( SKYSCALE_BONEYARD_MCOR_ACTOR, 0.01 )
	mac.LerpSkyScale( SKYSCALE_BONEYARD_MCOR_ACTOR, 0.01 )
	barker.LerpSkyScale( SKYSCALE_BONEYARD_MCOR_ACTOR, 0.01 )

	thread PlayAnimTeleport( pilot, "Militia_flyinA_idle_mac", dropship, "ORIGIN" )
	thread PlayAnimTeleport( mac, "pt_boneyard_flyin_mac", dropship, "ORIGIN" )
	thread PlayAnimTeleport( barker, "Boneyard_Mcor_intro_Bar", dropship, "ORIGIN" )

	dropship.WaitSignal( "sRampOpen" )

	pilot.LerpSkyScale( SKYSCALE_BONEYARD_DOOROPEN_MCOR_ACTOR, 1 )
	mac.LerpSkyScale( SKYSCALE_BONEYARD_DOOROPEN_MCOR_ACTOR, 1 )
	barker.LerpSkyScale( SKYSCALE_BONEYARD_DOOROPEN_MCOR_ACTOR, 1 )
}

function IntroMilitiaDialog()
{
	ForcePlayConversationToTeam( "matchIntro", TEAM_MILITIA )

	// should be when the guy jumps out the back
	WaittillGameStateOrHigher( eGameState.Playing )

	local squad1 = GetNPCArrayBySquad( "MILITIA_squad1" )
	if ( squad1.len() >= 3 )
	{
		thread DelayEmitSound( 1, squad1[0], "diag_hp_matchIntro_BY103_01_01_mcor_grunt1" )
		thread DelayEmitSound( 3, squad1[1], "diag_hp_matchIntro_BY103_02_01_mcor_grunt2" )
		thread DelayEmitSound( 10.5, squad1[1], "diag_hp_matchIntro_BY103_04_01_mcor_grunt2" )
	}

	local flyerGuy = GetNPCArrayBySquad( "MILITIA_flyerGuy" )
	if ( flyerGuy.len() == 1 )
	{
		// not loud enough
		thread DelayEmitSound( 7, flyerGuy[0], "diag_hp_matchIntro_BY103_03_01_mcor_grunt3" )
	}

	local squad3 = GetNPCArrayBySquad( "MILITIA_squad2" )
	if ( squad3.len() )
	{
		thread DelayEmitSound( 6, squad3[0], "diag_sitFlavor_BY204_01_01_mcor_grunt1" )
	}


}

function IntroMilitiaFlyers()
{
	// pickup moment
	local origin = Vector( -1677.5, 1846.5, 240.0 )
	local angles = Vector( 0, 92.0, 0 )
	thread FlyerPickupIntroMoment( TEAM_MILITIA, "normalDive", origin, angles, 3, true, "MILITIA_flyerGuy" )
}


function Spawn_IntroZipLineDropship( team, count, spawnPoint, squadName = null )
{
	// Have to copy Spawn_TrackedZipLineGruntSquad(...) so that I can set s.canDieInPrematch on the dropship. So bad.

//	Assert( count <= GetFreeAISlots(team) )

	ReserveAISlots( team, count )
	ReserveSquadSlots( squadName, count, "npc_soldier", team )

	spawnPoint.s.inUse = true

	local drop = CreateDropshipDropoff()
	drop.origin = spawnPoint.GetOrigin()
	drop.yaw = spawnPoint.GetAngles().y
	drop.dist = 768
	drop.count = count
	drop.team = team
	drop.squadname = squadName
	drop.npcSpawnFunc = SpawnGrunt
	drop.style = eDropStyle.ZIPLINE_NPC
	drop.assaultEntity <- spawnPoint
	thread RunDropshipDropoff( drop )

	local soldierEntities = []
	if ( drop.success )
	{
		// get the guys that spawned
		local results = WaitSignal( drop, "OnDropoff" )
		Assert( "guys" in results )

		if ( results.guys )
			soldierEntities = results.guys
	}

	drop.dropship.s.canDieInPrematch <- true

	if ( count != soldierEntities.len() )
		ReleaseAISlots( team, count - soldierEntities.len() )
	ReleaseSquadSlots( squadName, count, "npc_soldier" )

	foreach ( soldier in soldierEntities )
		FreeAISlotOnDeath( soldier )

	spawnPoint.s.inUse = false

	return soldierEntities
}

function IntroFlyersAttackDropship( team, count, origin, angles, squadName, destination, index )
{
	// force the dropship to use the vertical dropoff
	local old_dropshipDropoffAnims = level.dropshipDropoffAnims
	level.dropshipDropoffAnims = [ DROPSHIP_VERTICAL ]

	local ref = CreateScriptRef( origin, angles )
	ref.s.inUse <- false	// mimics a real spawnpoint
	NextDropshipAttackedByFlyers()
	local squad = Spawn_IntroZipLineDropship( team, count, ref, squadName )
	ref.Destroy()

	// need to delay them from capturing the hardpoint
	foreach( npc in squad )
		npc.AssaultPoint( destination, 256 )

	// restore the old array
	level.dropshipDropoffAnims = old_dropshipDropoffAnims
}

function IntroMilitiaGrunts()
{
	// squad 3 ziplining in
	delaythread( 13.5 ) IntroFlyersAttackDropship( TEAM_MILITIA, 4, Vector( -2044, 2872, 172 ), Vector( 0, 0, 0 ), "MILITIA_squad3", Vector( 273, 1369, 159 ), 2 )
	delaythread( 33.75 ) PlayFX( "droppod_impact", Vector(-1483, 2312, 275 ) )

	local locations = []
	locations.append( { pos = Vector( -2816, 2798, 245 ), ang = Vector( 0, -65.454529, 0 ),
						destination = Vector( -3228, -1186, -83 ),
						delay = 19.0, indexStart = 0, squad = "MILITIA_squad1" } ) //17

	locations.append( { pos = Vector( -1886, 3321, 200 ), ang = Vector( 0, -100, 0 ),
						destination = Vector( -446, -1807, -280 ),
						delay = 23.5, indexStart = 3, squad = "MILITIA_squad2" } ) //17

	foreach( location in locations )
	{
		local node = CreateScriptRef( location.pos, location.ang )
		local indexStart = location.indexStart

		for ( local i = 0 ; i < 3 ; i++ )
		{
			local guy = Spawn_TrackedGrunt( TEAM_MILITIA, location.squad, node.GetOrigin() + Vector( 0,0,64 ), node.GetAngles() )
			guy.SetLookDist( 1500 )
			guy.AllowHandSignals( false )
			thread IntroGruntSquadPlayAnim( guy, i + indexStart, node, location.delay, location.destination )
		}
	}

	// NPC following a path
	local pathArray = []
	// squad 1
	pathArray.append( [ Vector( -2065, 3042, 149 ), Vector( -2866, 1683, 156 ), Vector( -3228, -1186, -83 ) ] )
	// squad 2
	pathArray.append( [ Vector( -3479, 3074, 250 ), Vector( -2020, 3505, 203 ), Vector( -446, -1807, -280 ) ] )

	local npcArray = []
	npcArray.append( { path = pathArray[0], squad = "MILITIA_squad1", delay = 28.0 } )
	npcArray.append( { path = pathArray[1], squad = "MILITIA_squad2", delay = 22.0 } )

	foreach( table in npcArray )
	{
		local grunt = Spawn_TrackedGrunt( TEAM_MILITIA, table.squad, table.path[0], Vector( 0,0,0 ) )
		grunt.StayPut( true )
		grunt.SetLookDist( 1500 )
		grunt.AllowHandSignals( false )
		thread NPCRunPath( grunt, table.path, table.delay )
	}
}

function IntroMCORExperience( dropship1, dropship2 )
{
	thread DropshipMCORFlyinShake( dropship1 )
	thread DropshipMCORFlyinShake( dropship2 )

	thread IntroDropshipSounds( dropship1, "Boneyard_Scr_MilitiaIntro_DropshipFlyinAmb", "Boneyard_Scr_MilitiaIntro_DropshipFlyaway" )
	thread IntroDropshipSounds( dropship2, "Boneyard_Scr_MilitiaIntro_DropshipFlyinAmb", "Boneyard_Scr_MilitiaIntro_DropshipFlyaway" )
}

function DropshipMCORIdleShake( dropship )
{
	dropship.EndSignal( "StopShaking" )
	dropship.EndSignal( "OnDeath" )

	local radius = 200
	local shake, amplitude, frequency, duration

	//min rumble
	amplitude 	= 0.25
	frequency 	= 5
	duration 	= 20.0
	shake = CreateShake( dropship.GetOrigin(), amplitude, frequency, duration, radius )
	shake.SetParent( dropship, "ORIGIN" )

	//sound of ship rattling
	wait 7
	amplitude 	= 1
	frequency 	= 25
	duration 	= 5
	shake = CreateShake( dropship.GetOrigin(), amplitude, frequency, duration, radius )
	shake.SetParent( dropship, "ORIGIN" )

	wait duration - 1.0
	//min rumble
	amplitude 	= 0.25
	frequency 	= 5
	duration 	= 20.0
	shake = CreateShake( dropship.GetOrigin(), amplitude, frequency, duration, radius )
	shake.SetParent( dropship, "ORIGIN" )

	//bermingham passing by window
	wait 11
	amplitude 	= 0.75
	frequency 	= 25
	duration 	= 5
	shake = CreateShake( dropship.GetOrigin(), amplitude, frequency, duration, radius )
	shake.SetParent( dropship, "ORIGIN" )

	wait duration - 1.0
	//min rumble
	amplitude 	= 0.25
	frequency 	= 5
	duration 	= 40.0
	shake = CreateShake( dropship.GetOrigin(), amplitude, frequency, duration, radius )
	shake.SetParent( dropship, "ORIGIN" )
}

function DropshipMCORFlyinShake( dropship )
{
	dropship.Signal( "StopShaking" )
	dropship.EndSignal( "OnDeath" )

	local radius = 200
	local shake, amplitude, frequency, duration

	wait 2.0
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

	wait 6.0

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
	shake.SetParent( dropship, "ORIGIN" )
}

function IntroIMC()
{
	local table 	= GetSavedDropEvent( "introDropShipIMC_1cr" )
	local event1 	= GetSavedDropEvent( "introDropShipIMC_1e1" )
	local event2 	= GetSavedDropEvent( "introDropShipIMC_1e2" )
	local dropship1 = SpawnCinematicDropship( table )
	thread RunCinematicDropship( dropship1, event1, event2 )

	local table 	= GetSavedDropEvent( "introDropShipIMC_2cr" )
	local event1 	= GetSavedDropEvent( "introDropShipIMC_2e1" )
	local event2 	= GetSavedDropEvent( "introDropShipIMC_2e2" )
	local dropship2 = SpawnCinematicDropship( table )
	thread RunCinematicDropship( dropship2, event1, event2 )
//	DebugSkipCinematicSlots( TEAM_IMC, 4 )

	thread IntroIMCExperience( dropship1, dropship2 )

	thread IntroIMCDialog()
	thread IntroIMCFlyers()
	thread IntroIMCGrunts()
}

function IntroIMCHeroes( dropship, ref, table )
{
	dropship.EndSignal( "OnDeath" )

	// temp hack until dropship_boneyard_flyin_imc_R and L can be made to fit Blisk intro animation
	FlagWait( "ReadyToStartMatch" )
	wait 11	// this is two seconds before the flyin anim starts

	local pilot = CreatePropDynamic( TEAM_IMC_GRUNT_MDL )
	local blisk = CreatePropDynamic( BLISK_MODEL )

	blisk.SetParent( dropship, "ORIGIN" )
	pilot.SetParent( dropship, "ORIGIN" )
	dropship.s.blisk <- blisk

	blisk.MarkAsNonMovingAttachment()
	pilot.MarkAsNonMovingAttachment()

	pilot.LerpSkyScale( SKYSCALE_BONEYARD_IMC_ACTOR, 0.01 )
	blisk.LerpSkyScale( SKYSCALE_BONEYARD_IMC_ACTOR, 0.01 )

	thread PlayAnimTeleport( pilot, "Militia_flyinA_idle_mac", dropship, "ORIGIN" )
	thread PlayAnimTeleport( blisk, "pt_boneyard_flyin_blisk", dropship, "ORIGIN" )

	dropship.WaitSignal( "sRampOpen" )

	pilot.LerpSkyScale( SKYSCALE_BONEYARD_DOOROPEN_IMC_ACTOR, 1 )
	blisk.LerpSkyScale( SKYSCALE_BONEYARD_DOOROPEN_IMC_ACTOR, 1 )
}

function IntroIMCDialog()
{
	delaythread( 5.5 ) ForcePlayConversationToTeam( "matchIntro", TEAM_IMC )

	// should be when the guy jumps out the back
	WaittillGameStateOrHigher( eGameState.Playing )

	local squad1 = GetNPCArrayBySquad( "IMC_squad1" )
	if ( squad1.len() )
	{
		thread DelayEmitSound( 3, squad1[0], "diag_sitFlavor_BY207_01_01_imc_grunt1" )
		thread DelayEmitSound( 9, squad1[0], "diag_sitFlavor_BY208_01_01_imc_grunt1" )
		thread DelayEmitSound( 10, squad1[0], "diag_sitFlavor_BY209_01_01_imc_grunt1" )
	}
}

function IntroIMCTest()
{
	thread IntroIMCFlyers()
	thread IntroIMCGrunts()
}

function IntroIMCFlyers()
{
	local origin = Vector( -4040.0, -3426.0, 25.0 )
	local angles = Vector( 8.0, 65.0, 0.0 )
	thread FlyerPickupIntroMoment( TEAM_IMC, "intro", origin, angles, 29.0, false )

	local path_1 = []
	path_1.append( Vector( -1204.898560, -1205.601563, -350.565948 ) )
	path_1.append( Vector( -1452.796753, -1522.324463, -384.880554 ) )
	path_1.append( Vector( -1660.641479, -1749.558838, -400.745819 ) )
	path_1.append( Vector( -1743.543091, -1908.991211, -389.188629 ) )
	path_1.append( Vector( -1793.098267, -2024.895996, -372.683167 ) )
	path_1.append( Vector( -2030.086304, -2277.348145, -327.184570 ) )
	path_1.append( Vector( -2099.264648, -2324.800293, -316.593048 ) )

//	doesn't look good enough when it dies.
//	thread FlyerCrawMoments( TEAM_IMC, path_1, 21.0, false )
}

function IntroIMCGrunts()
{
	local locations = []
	locations.append( { pos = Vector( -3501, -4041, 125 ), ang = Vector( 0, 95.0, 0 ),
						destination = Vector( -3541, -809, 20 ),
						delay = 16.0, indexStart = 0, squad = "IMC_squad1" } )

	locations.append( { pos = Vector( -3040, -3358, 80 ), ang = Vector( 0, 72, 0 ),
						destination = [ Vector( -2170, -2220, -245 ), Vector( -869, -907, -267 ) ],
						delay = 20.5, indexStart = 3, squad = "IMC_squad2" } )

	foreach( location in locations )
	{
		local node = CreateScriptRef( location.pos, location.ang )
		local indexStart = location.indexStart

		for ( local i = 0 ; i < 3 ; i++ )
		{
			local guy = Spawn_TrackedGrunt( TEAM_IMC, location.squad, node.GetOrigin(), node.GetAngles() )
			guy.SetLookDist( 750 )
			guy.AllowHandSignals( false )
			thread IntroGruntSquadPlayAnim( guy, i + indexStart, node, location.delay, location.destination )
		}
	}

	// NPC following a path
	local pathArray = []
	// squad 1
	pathArray.append( [ Vector( -2088, -4674, 305 ), Vector( -3696, -3863, 43 ), Vector( -3318, -1152, -143 ) ] )
	// squad 2
	pathArray.append( [ Vector( -2667, -4839, 235 ),  Vector( -3098, -3154, -6 ), Vector( -869, -907, -267 ) ] )
	// squad 3
	pathArray.append( [ Vector( -2891, -3806, 64 ), Vector( -1419, -3337, 60 ), Vector( 897, -1267, 277 ), Vector( 899, 851, 304 ) ] )
	pathArray.append( [ Vector( -3027, -3822, 62 ), Vector( -1419, -3337, 60 ), Vector( 897, -1267, 277 ), Vector( 899, 851, 304 ) ] )
	pathArray.append( [ Vector( -3164, -3986, 69 ), Vector( -1419, -3337, 60 ), Vector( 897, -1267, 277 ), Vector( 899, 851, 304 ) ] )
	pathArray.append( [ Vector( -2843, -4103, 93 ), Vector( -1419, -3337, 60 ), Vector( 897, -1267, 277 ), Vector( 899, 851, 304 ) ] )

	local npcArray = []
	npcArray.append( { path = pathArray[0], squad = "IMC_squad1", delay = 28.0 } )
	npcArray.append( { path = pathArray[1], squad = "IMC_squad2", delay = 26.0 } )
	npcArray.append( { path = pathArray[2], squad = "IMC_squad3", delay = 12.5 } )
	npcArray.append( { path = pathArray[3], squad = "IMC_squad3", delay = 12.5 } )
	npcArray.append( { path = pathArray[5], squad = "IMC_squad3", delay = 12.5 } )
	npcArray.append( { path = pathArray[4], squad = "IMC_squad3", delay = 12.5 } )

	foreach( table in npcArray )
	{
		local grunt = Spawn_TrackedGrunt( TEAM_IMC, table.squad, table.path[0], Vector( 0,0,0 ) )
		grunt.StayPut( true )
		grunt.SetLookDist( 1500 )
		grunt.AllowHandSignals( false )
		thread NPCRunPath( grunt, table.path, table.delay )
	}
}

function FlyerCrawMoments( team, path, delay = 0, waitTillPlaying = true )
{
	if ( waitTillPlaying )
		WaittillGameStateOrHigher( eGameState.Playing )

	wait delay

	local origin = path[0]
	local angles = ( path[1] - path[0] ).GetAngles()

	local flyer	= CreateServerFlyer( origin, angles )

	local otherTeam = ( team == TEAM_IMC ) ? TEAM_MILITIA : TEAM_IMC
	SpawnBullseye( otherTeam, flyer )

	thread FlyerCrawl( flyer, path, 0 )
}

function IntroIMCExperience( dropship1, dropship2 )
{
	thread DropshipIMCFlyinShake( dropship1 )
	thread DropshipIMCFlyinShake( dropship2 )

	thread IntroDropshipSounds( dropship1, "Boneyard_Scr_IMCIntro_FlyIn" )
	thread IntroDropshipSounds( dropship2, "Boneyard_Scr_IMCIntro_FlyIn" )
}

function DropshipIMCFlyinShake( dropship )
{
	dropship.Signal( "StopShaking" )
	dropship.EndSignal( "OnDeath" )

	local radius = 200
	local shake, amplitude, frequency, duration

	//min rumble
	amplitude 	= 0.5
	frequency 	= 10
	duration 	= 20.0
	shake = CreateShake( dropship.GetOrigin(), amplitude, frequency, duration, radius )
	shake.SetParent( dropship, "ORIGIN" )

	wait 16.25

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
	shake.SetParent( dropship, "ORIGIN" )
}

function CE_BoneyardPlayerSkyScaleDesertIMC( player, dropship )
{
	player.LerpSkyScale( SKYSCALE_BONEYARD_IMC_PLAYER, 0.01 )
}

function CE_BoneyardPlayerSkyScaleDesertMCOR( player, dropship )
{
	player.LerpSkyScale( SKYSCALE_BONEYARD_MCOR_PLAYER, 0.01 )
}

function CE_BoneyardPlayerSkyScaleOnRampOpenIMC( player, dropship )
{
	thread playerLerpSkyScaleOnSignal( player, dropship, "sRampOpen", SKYSCALE_BONEYARD_DOOROPEN_IMC_PLAYER, 1.0 )
}

function CE_BoneyardPlayerSkyScaleOnRampOpenMCOR( player, dropship )
{
	thread playerLerpSkyScaleOnSignal( player, dropship, "sRampOpen", SKYSCALE_BONEYARD_DOOROPEN_MCOR_PLAYER, 1.0 )
}

function IntroGruntSquadPlayAnim( guy, index, node, delay, destination )
{
	guy.EndSignal( "OnDeath" )

	local idles = [
		"pt_titan_briefingA_guy1_idle",
		"pt_titan_briefingA_guy2_idle",
		"pt_titan_briefingA_guy3_idle",
		"pt_titan_briefingB_guy1_idle",
		"pt_titan_briefingB_guy2_idle",
		"pt_titan_briefingB_guy3_idle",
	]

	local anims = [
		"pt_titan_briefingA_guy1",
		"pt_titan_briefingA_guy2",
		"pt_titan_briefingA_guy3",
		"pt_titan_briefingB_guy1",
		"pt_titan_briefingB_guy2",
		"pt_titan_briefingB_guy3",
	]

	guy.SetEfficientMode( true )
	guy.NotSolid()
	guy.SetNoTarget( true )

	thread PlayAnimGravity( guy, idles[ index ], node )

	wait delay

	guy.Solid()
	guy.DisableStarts()
	waitthread PlayAnimGravity( guy, anims[ index ], node )

	guy.SetNoTarget( false )
	guy.SetNoTargetSmartAmmo( false )
	guy.SetEfficientMode( false )

	if ( type( destination ) == "array" )
		NPCRunPath( guy, destination )
	else
		guy.AssaultPoint( destination, 512 )

	wait 2

	guy.EnableStarts()
}

function FlyerPickupIntroMoment( team, anim, origin, angles, delay = 0, waitTillPlaying = true, squadName = "" )
{
	local npc = SpawnGrunt( team, squadName, origin, angles )

	npc.EndSignal( "OnDeath" )
	npc.EndSignal( "OnDestroy" )

	// need idle loop
	thread PlayAnim( npc, "pt_bored_idle_console_A" )

	if ( waitTillPlaying )
		WaittillGameStateOrHigher( eGameState.Playing )

	if ( delay )
		wait delay

	thread FlyerPickupNpc( npc, origin, angles, GetPickupAnimation( anim ), 5000 )
}

function IntroDropshipSounds( dropship, sound, sound2 = null )
{
	WaittillGameStateOrHigher( eGameState.Prematch )
	PlaySoundToAttachedPlayers( dropship, sound )

	WaittillGameStateOrHigher( eGameState.Playing )

	if ( sound2 )
		EmitSoundOnEntity( dropship, sound2 )
}

/*--------------------------------------------------------------------------------------------------------*\
|
|														EPILOGUE
|
\*--------------------------------------------------------------------------------------------------------*/

// dev function for placing a dropship model at a possible evac location
function evacship()
{
	local player = GetEntByIndex( 1 )
	if ( !( "evacship" in level ) )
		level.evacship <- CreatePropDynamic( "models/vehicle/crow_dropship/crow_dropship_hero.mdl", player.GetOrigin() )

	printt( "previous", level.evacship.GetOrigin(), level.evacship.GetAngles().y )

	local origin = player.GetOrigin() + player.GetViewVector() * 300 + Vector( 0, 0, 40 )
	local angles = player.GetAngles() + Vector( 0, 90, 0 )
	if ( CoinFlip() )
		angles = player.GetAngles() + Vector( 0, -90, 0 )

	level.evacship.SetOrigin( origin )
	level.evacship.SetAngles( angles )

	printt( "new", origin, angles.y )
}

function EvacSetup()
{
	local verticalAnims = Evac_CreateAnimPackage( "dropship_VTOL_evac_start", "dropship_VTOL_evac_idle", "dropship_VTOL_evac_end" )

//	local spectatorNode1 = GetEnt( "spec_cam1" )
	/*local spectatorNode2 = GetEnt( "spec_cam2" )
	local spectatorNode3 = GetEnt( "spec_cam3" )*/
	local spectatorNode4 = GetEnt( "spec_cam4" )
	local spectatorNode5 = GetEnt( "spec_cam5" )

//	Evac_AddLocation( "evac_location1", spectatorNode1.GetOrigin(), spectatorNode1.GetAngles() )
	/*Evac_AddLocation( "evac_location2", spectatorNode2.GetOrigin(), spectatorNode2.GetAngles(), verticalAnims )
	Evac_AddLocation( "evac_location3", spectatorNode3.GetOrigin(), spectatorNode3.GetAngles() )*/
	Evac_AddLocation( "evac_location4", spectatorNode4.GetOrigin(), spectatorNode4.GetAngles() )
	Evac_AddLocation( "evac_location5", spectatorNode5.GetOrigin(), spectatorNode5.GetAngles(), verticalAnims )

	local spacenode = GetEnt( "end_spacenode" )
	Evac_SetSpaceNode( spacenode )

	Evac_SetupDefaultVDUs()

	GM_SetObserverFunc( EvacObserverFunc )
}

/*function EvacSetupforHeist() 테스트용 추가
{
	local verticalAnims = Evac_CreateAnimPackage( "dropship_VTOL_evac_start", "dropship_VTOL_evac_idle", "dropship_VTOL_evac_end" )

	//local spectatorNode2 = GetEnt( "spec_cam2" )
	//local spectatorNode3 = GetEnt( "spec_cam3" )
	local spectatorNode4 = GetEnt( "spec_cam4" )
	local spectatorNode5 = GetEnt( "spec_cam5" )

//	Evac_AddLocation( "evac_location1", spectatorNode1.GetOrigin(), spectatorNode1.GetAngles() )
	//Evac_AddLocation( "evac_location2", spectatorNode2.GetOrigin(), spectatorNode2.GetAngles(), verticalAnims )
	//Evac_AddLocation( "evac_location3", spectatorNode3.GetOrigin(), spectatorNode3.GetAngles() )
	Evac_AddLocation( "evac_location4", spectatorNode4.GetOrigin(), spectatorNode4.GetAngles() )
	Evac_AddLocation( "evac_location5", spectatorNode5.GetOrigin(), spectatorNode5.GetAngles(), verticalAnims )

	local spacenode = GetEnt( "end_spacenode" )
	Evac_SetSpaceNode( spacenode )

	Evac_SetupDefaultVDUs()

	GM_SetObserverFunc( EvacObserverFunc )
}*/

function EvacObserverFunc( player )
{
	player.SetObserverModeStaticPosition( level.ExtractLocations[ level.SelectedExtractLocationIndex ].spectatorPos )
	player.SetObserverModeStaticAngles( level.ExtractLocations[ level.SelectedExtractLocationIndex ].spectatorAng )

	player.StartObserverMode( OBS_MODE_CHASE )
	player.SetObserverTarget( null )

	//player.SetOrigin( level.ExtractLocations[ level.SelectedExtractLocationIndex ].spectatorPos )
	//player.SetAngles( level.ExtractLocations[ level.SelectedExtractLocationIndex ].spectatorAng )
}

function GetGruntsAndSpectres()
{
	local dudes = GetNPCArrayByClass( "npc_spectre" )
	ArrayAppend( dudes, GetNPCArrayByClass( "npc_soldier" ) )
	return dudes
}

/*--------------------------------------------------------------------------------------------------------*\
|
|												AI CHATTER
|
\*--------------------------------------------------------------------------------------------------------*/

function BoneyardSpecificChatter( npc )
{
	Assert( GetMapName() == "mp_boneyard" )

	if ( !GamePlayingOrSuddenDeath() )
		return false

	if ( Time() - level.lastPulseTime < AI_CHATTER_RECENT_PULSE_LENGTH )
		PlaySquadConversationToTeam( "boneyard_grunt_chatter_after_pulse", npc.GetTeam(), npc, AI_FRIENDLY_CHATTER_RANGE_SQR )
	else
		PlaySquadConversationToTeam( "boneyard_grunt_chatter", npc.GetTeam(), npc, AI_FRIENDLY_CHATTER_RANGE_SQR )

	return true //return false if we should not be doing chatter so we can fall through and do other chatter if needed
}

/*--------------------------------------------------------------------------------------------------------*\
|
|												UTILITY FUNCTIONS
|
\*--------------------------------------------------------------------------------------------------------*/

function DelayEmitSound( delay, entity, alias )
{
	entity.EndSignal( "OnDestroy" )
	entity.EndSignal( "OnDeath" )

	wait delay

	EmitSoundOnEntity( entity, alias )
}

function NPCRunPath( npc, path, delay = 0 )
{
	npc.EndSignal( "StopPath" )
	npc.EndSignal( "OnDeath" )

	thread PlayAnimGravity( npc, "pt_bored_idle_console_A" )

	if ( delay )
		wait delay

	npc.Anim_Stop()

	foreach( pathPoint in path )
	{
		// DebugDrawLine( npc.GetOrigin(), pathPoint, 255, 0, 0, true, 5.0 )
		npc.AssaultPoint( pathPoint, 256 )
		npc.WaitSignal( "OnEnterAssaultTolerance" )
	}
}

/*--------------------------------------------------------------------------------------------------------*\
|
|						DEBUG FUNCTIONS
|
\*--------------------------------------------------------------------------------------------------------*/
function RagdollTest()
{
	thread CrawlTest()
	thread FlyerRagdoll()
}

function CrawlTest()
{
	wait 3

	local path = []
	path.append( Vector( -2619.436035, -3500.063721, 45.598980 ) )
	path.append( Vector( -2779.835693, -3470.745117, 31.490475 ) )
	path.append( Vector( -2926.442871, -3505.724609, 30.857700 ) )
	path.append( Vector( -3065.259766, -3302.491211, 8.465942 ) )
	path.append( Vector( -3124.519043, -3072.233398, -36.312931 ) )

	local origin = path[0]
	local angles = ( path[1] - path[0] ).GetAngles()

	local flyer	= CreateServerFlyer( origin, angles )

	thread FlyerCrawl( flyer, path, 10 )
}

function FlyerRagdoll()
{
	local origin1 = Vector( -4900, -3100, 3000 )
	local origin2 = Vector( -3600, -3500, 3000 )
	local angles = Vector( 0, -100, 0 )

	local flyer1	= CreateServerFlyer( origin1, angles )
	local flyer2	= CreateServerFlyer( origin2, angles )
	wait 3
	flyer1.BecomeRagdoll( Vector(0,0,0) )
	wait 1
	flyer2.BecomeRagdoll( Vector(0,0,0) )
}

function FlyerPickupTest()
{
	local origin1 = Vector( -3693, -4072, 63 )
	local angles1 = Vector( 0, -100, 0 )
	local guy1 = SpawnGrunt( TEAM_IMC, "", origin1, angles1 )

	local origin2 = Vector( -3600, -3819, 43 )
	local angles2 = Vector( 0, -70, 0 )
	local guy2 = SpawnGrunt( TEAM_IMC, "", origin2, angles2 )

	local origin3 = Vector( -4040.0, -3426.0, 25.0 )
	local angles3 = Vector( 8.0, 65.0, 0.0 )
	local guy3 = SpawnGrunt( TEAM_IMC, "", origin3, angles3 )

	thread FlyerPickupNpc( guy1, origin1, angles1, GetPickupAnimation( "normalDive") )
	thread FlyerPickupNpc( guy2, origin2, angles2, GetPickupAnimation( "steepDive") )
	thread FlyerPickupNpc( guy3, origin3, angles3, GetPickupAnimation( "intro") )
}

function FlyerDropshipAttackTest()
{
	thread FlyerDropshipAttackTestThread()
}

function FlyerDropshipAttackTestThread()
{
	if ( !( "dropshipAttack" in level ) )
		level.dropshipAttack <- 0

	disable_npcs()
	wait 2
	local ref = CreateScriptRef( Vector( -3050, -3236, 62 ), Vector( 0, 0, 0 ) )
	ref.s.inUse <- false	// mimics a real spawnpoint
	NextDropshipAttackedByFlyers()

	if ( level.dropshipAttack % 2 )
		thread Spawn_TrackedZipLineGruntSquad( 3, 4, ref, "squad1" )
	else
		thread Spawn_TrackedZipLineGruntSquad( 2, 4, ref, "squad1" )

	level.dropshipAttack++
}

function TestPickupNode()
{
	local player = GetEntByIndex( 1 )
	local origin = player.GetOrigin()

	local analysis = GetAnalysisForModel( FLYER_MODEL, "flyer_PickingUp_Soldier_dive" )
	local pickup = CreateCallinTable()
	pickup.style = eDropStyle.HOTDROP // ZIPLINE_NPC //NEAREST
	pickup.origin = origin
	pickup.dist = 800
	pickup.yaw = RandomInt( 0, 360 )
	pickup.ownerEyePos = origin
 	local spawnPoint = GetSpawnPointForStyle( analysis, pickup )
 	if ( !spawnPoint )
 	{
 		printt( "failed" )
 		return
 	}

 	printt( "Distance", Distance( origin, spawnPoint.origin ) )
 	DebugDrawLine( origin, spawnPoint.origin, 0, 0, 255, true, 10 )
}

main()