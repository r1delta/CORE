//=========================================================
// Pilot bot brain
// Drives managed bots (see _bot_manager.nut) through the native BotSetInput/BotPressButtons
// usercmd injection and NavFindPath node-graph pathfinding provided by R1Delta.
//=========================================================

const BOT_THINK_INTERVAL		= 0.1
const BOT_DEBUG_HUD				= false	// shows one bot's movement diagnostics on screen
const BOT_SIGHT_RANGE			= 4000.0
const BOT_SIGHT_RADIUS			= 4000	// int copy for GetNPCArrayEx
const BOT_NPC_TARGET_BIAS		= 1.25	// at equal distance, prefer enemy pilots over grunts/spectres
const BOT_TARGET_MEMORY			= 4.0	// seconds to keep chasing the last seen position
const BOT_REPATH_INTERVAL		= 5.0
const BOT_GOAL_REPATH_DIST		= 256.0
const BOT_PATROL_TIME			= 30.0
const BOT_STUCK_TIME			= 1.0
const BOT_STUCK_DIST			= 24.0
const BOT_PILOT_NODE_REACHED	= 72.0
const BOT_TITAN_NODE_REACHED	= 180.0
const BOT_PILOT_ENGAGE_DIST		= 700.0	// stop closing in and strafe inside this range
const BOT_TITAN_ENGAGE_DIST		= 1500.0
const BOT_PILOT_AT_ENGAGE_DIST	= 1600.0	// on foot vs a titan: hold this range and shoot the anti-titan weapon
const BOT_TITAN_TOO_CLOSE_DIST	= 600.0		// on foot, a titan closer than this is a stomp waiting to happen: run
const BOT_AT_BURST				= 1.6		// longer trigger holds for anti-titan weapons (charge rifle needs the charge)
const BOT_AT_PAUSE				= 0.4
const BOT_WEAPON_SWITCH_DELAY	= 1.0

// Rodeo defence
const BOT_RODEO_TARGET_BIAS		= 0.4	// riders get picked as targets over anything at up to 2.5x the distance
const BOT_RODEO_REACTION_MIN	= 0.8
const BOT_RODEO_REACTION_MAX	= 2.0
const BOT_RODEO_DISEMBARK_CHANCE	= 60	// percent of bots that hop out to shoot the rider (others dash it out)
const BOT_RODEO_SMOKE_RETRY		= 3.0

// Rodeo attacks (kept occasional on purpose)
const BOT_RODEO_DECISION_MIN	= 8.0	// how often a bot near an enemy titan considers jumping on it
const BOT_RODEO_DECISION_MAX	= 15.0
const BOT_RODEO_MAX_START_DIST	= 900.0
const BOT_RODEO_JUMP_DIST		= 300.0	// leap for the hatch from this far out
const BOT_RODEO_APPROACH_TIMEOUT	= 8.0
const BOT_RODEO_MIN_HEALTH		= 0.6	// only start one when healthy...
const BOT_RODEO_ABORT_HEALTH	= 0.4	// ...give up the approach below this...
const BOT_RODEO_BAIL_HEALTH		= 0.35	// ...and jump off the titan below this (electric smoke etc.)
const BOT_EMBARK_DIST			= 250.0
const BOT_TITAN_CALL_RETRY		= 5.0
const BOT_TITAN_CALL_DELAY_MIN	= 5.0	// extra wait once the titan meter is full
const BOT_TITAN_CALL_DELAY_MAX	= 45.0
const BOT_TITAN_HOLD_FOR_ENEMY	= 30.0	// some bots keep the titan until they see someone, up to this long
const BOT_TITAN_CALL_SAFE_DIST	= 800.0	// don't stand still calling a titan with an enemy this close
const BOT_EJECT_HEALTH_FRAC		= 0.15
const BOT_WALL_CHECK_DIST		= 72.0

// Exploration
const BOT_EXPLORE_CANDIDATES	= 8
const BOT_EXPLORE_FAR_DIST		= 4000.0
const BOT_VISITED_MEMORY		= 6
const BOT_VISITED_RADIUS		= 800.0
const BOT_HUNT_CHANCE			= 70	// percent of patrol goals that head towards an enemy's area
const BOT_PREY_MIN_TIME			= 10.0	// how long a bot sticks with one prey
const BOT_PREY_MAX_TIME			= 25.0
const BOT_OBSTACLE_CHECK_DIST	= 64.0
const BOT_WALLRUN_MIN_DIST		= 300.0	// only start a wallrun when the next waypoint is this far along
const BOT_WALL_SEEK_DIST		= 220.0	// while travelling, drift towards walls this close to wallrun along them
const BOT_WALL_COMBAT_DIST		= 260.0	// in a fight, take to a wall this close instead of strafing on the ground
const BOT_WALL_AIR_DIST			= 160.0	// in the air, steer onto walls this close to chain wallruns
const BOT_WALL_SEEK_STRENGTH	= 0.7	// sideways input used to drift towards a wall

// Gunfight movement (pilots keep moving while they shoot)
const BOT_COMBAT_STRAFE_MIN		= 1.0	// how long before switching the circling direction
const BOT_COMBAT_STRAFE_MAX		= 2.5
const BOT_COMBAT_RANGE_SLACK	= 150.0	// tolerance around the preferred range before closing in / backing off
const BOT_COMBAT_RADIAL_SPEED	= 0.7	// how hard to close in / back off, relative to circling
const BOT_COMBAT_WALL_LEAN		= 0.5	// lean into the wall while running along it, so the wallrun sticks
const BOT_COMBAT_HOP_MIN		= 1.2	// jumps during a fight
const BOT_COMBAT_HOP_MAX		= 2.8
const BOT_COMBAT_DOUBLE_JUMP_CHANCE	= 50
const BOT_PILOT_RANGE_MIN		= 350.0	// each bot's preferred gunfight range is rolled in here
const BOT_PILOT_RANGE_MAX		= 650.0
const BOT_AT_PREFERRED_DIST		= 1100.0	// range held against titans with the anti-titan weapon

// Route variety
const BOT_FLANK_MIN_DIST		= 1200.0	// only bother flanking prey farther than this
const BOT_FLANK_REACHED			= 350.0
const BOT_FLANK_TIMEOUT			= 20.0
const BOT_NO_NAV_ROAM_DIST		= 1500.0
const BOT_HUNT_SPREAD			= 600.0

// Threats
const BOT_FLEE_TITAN_DIST		= 1500.0
const BOT_OUTNUMBER_DIST		= 1200.0
const BOT_GRENADE_DANGER_DIST	= 350.0
// Integer copies: the radius argument of GetProjectileArrayEx/GetNPCArrayEx must be an int.
const BOT_GRENADE_DANGER_RADIUS	= 350
const BOT_FLEE_TITAN_RADIUS		= 1500
const BOT_OUTNUMBER_RADIUS		= 1200
const BOT_PILOT_FLEE_HEALTH		= 0.35
const BOT_TITAN_FLEE_HEALTH		= 0.45
const BOT_FLEE_MIN_TRAVEL		= 300.0
const BOT_FLEE_MAX_TRAVEL		= 3000.0
const BOT_FLEE_CANDIDATES		= 16
const BOT_FLEE_INDOOR_BONUS		= 900.0	// flee spots under a roof...
const BOT_FLEE_HIDDEN_BONUS		= 700.0	// ...and out of the threat's line of sight score higher
const BOT_ROOF_CHECK_HEIGHT		= 600.0
const BOT_NPC_THREAT_WEIGHT		= 0.5	// a grunt/spectre counts as half an enemy when judging odds

// Abilities and ordnance
const BOT_TACTICAL_RETRY_MIN	= 4.0	// pressing an uncharged ability does nothing; just retry later
const BOT_TACTICAL_RETRY_MAX	= 8.0
const BOT_ORDNANCE_COOLDOWN_MIN	= 10.0
const BOT_ORDNANCE_COOLDOWN_MAX	= 18.0
const BOT_ORDNANCE_MIN_DIST		= 250.0	// don't frag yourself
const BOT_ORDNANCE_MAX_DIST		= 1400.0
const BOT_TACTICAL_LOW_HEALTH	= 0.6

// AI node graph hulls. The titan hull index still has to be confirmed against the .ain link data;
// until then titans path on the human graph and rely on stuck detection.
const BOT_HULL_PILOT			= 0
const BOT_HULL_TITAN			= 0

// usercmd button bits. Movement/jump/sprint are confirmed by R1Delta's vehicle input fallback;
// the rest follow the Source layout.
const BOT_IN_ATTACK				= 0x1
const BOT_IN_JUMP				= 0x2
const BOT_IN_DUCK				= 0x4
const BOT_IN_RELOAD				= 0x2000
const BOT_IN_SPEED				= 0x20000
// Offhand slots, from server.dll's own Bot_Think: bot_force_offhand 1..4 sets bits 23..26.
// Slot 0 is ordnance (grenades / titan rockets), slot 1 the tactical ability.
const BOT_IN_OFFHAND_ORDNANCE	= 0x800000
const BOT_IN_OFFHAND_TACTICAL	= 0x1000000
// Titan dash is the sprint button (+speed) tapped with a move direction.
const BOT_IN_DODGE				= 0x20000

// Melee goes through the same script callback code calls on +melee (CodeCallback_OnMeleePressed).
const BOT_PILOT_MELEE_RANGE		= 90.0	// kick range is 75, more with momentum
const BOT_TITAN_MELEE_RANGE		= 280.0	// TITAN_AIMASSIST_MELEE_ATTACK_RANGE is 300
const BOT_PILOT_MELEE_RUSH_DIST	= 250.0	// inside this, stop strafing and close in for the kick
const BOT_TITAN_MELEE_RUSH_DIST	= 450.0
const BOT_MELEE_COOLDOWN		= 1.2
const BOT_TITAN_DASH_COOLDOWN_MIN	= 3.0
const BOT_TITAN_DASH_COOLDOWN_MAX	= 6.0

function main()
{
	RegisterSignal( "BotStopThink" )

	file.skill <- [
		// reaction (s), aim error (deg), turn speed (deg per think), burst (s), burst pause (s)
		{ reaction = 0.9, aimError = 9.0, turnSpeed = 25.0, burst = 0.4, pause = 0.6 },
		{ reaction = 0.6, aimError = 5.0, turnSpeed = 40.0, burst = 0.6, pause = 0.4 },
		{ reaction = 0.35, aimError = 2.5, turnSpeed = 60.0, burst = 0.9, pause = 0.25 },
		{ reaction = 0.2, aimError = 1.0, turnSpeed = 90.0, burst = 1.2, pause = 0.15 },
	]

	if ( !BotManagerEnabledForMode() )
		return

	AddCallback_OnPlayerRespawned( BotAI_OnPlayerRespawned )
}

function BotAI_OnPlayerRespawned( player )
{
	if ( IsManagedBot( player ) )
		thread BotThink( player )
}

function GetBotSkill()
{
	local skillLevel = GetConVarInt( "delta_bot_difficulty" )
	skillLevel = max( 0, min( file.skill.len() - 1, skillLevel ) )
	return file.skill[ skillLevel ]
}

function BotThink( bot )
{
	bot.Signal( "BotStopThink" )
	bot.EndSignal( "BotStopThink" )
	bot.EndSignal( "OnDeath" )
	bot.EndSignal( "OnDestroy" )
	bot.EndSignal( "Disconnected" )

	OnThreadEnd(
		function() : ( bot )
		{
			if ( IsValid( bot ) )
				BotClearInput( bot )
		}
	)

	local angles = bot.EyeAngles()
	local brain = {
		skill = GetBotSkill()
		pitch = 0.0
		yaw = angles.y
		path = []
		pathIndex = 0
		pathGoal = null
		nextRepathTime = 0.0
		patrolGoal = null
		patrolUntil = 0.0
		target = null
		targetLastSeenPos = null
		targetLastSeenTime = -999.0
		targetAcquiredTime = 0.0
		firing = false
		nextFireToggle = 0.0
		lastProgressPos = bot.GetOrigin()
		lastProgressTime = Time()
		prey = null
		preyUntil = 0.0
		// Personality, rolled every life so bots don't all behave (or path) the same.
		preyNearestChance = RandomInt( 25, 66 )
		flankChance = RandomInt( 30, 81 )
		wallLove = RandomFloat( 0.6, 1.0 )
		roamUntil = RandomInt( 100 ) < 40 ? Time() + RandomFloat( 5.0, 15.0 ) : 0.0
		flankPoint = null
		flankFor = null
		flankUntil = 0.0
		wallrunStartTime = -999.0
		wallrunHopAfter = RandomFloat( 0.6, 1.4 )
		wasWallRunning = false
		preferredDist = RandomFloat( BOT_PILOT_RANGE_MIN, BOT_PILOT_RANGE_MAX )
		combatWallSeen = false
		nextCombatHop = Time() + RandomFloat( 0.5, 1.5 )
		planDoubleJump = false
		titanCallAt = null
		titanHoldForEnemy = false
		visitedGoals = []
		fleeing = false
		fleeUntil = 0.0
		fleeFrom = null
		fleeGoal = null
		fleeDirect = false
		ejected = false
		usedDoubleJump = false
		fleeStartTime = -999.0
		nextTacticalTime = Time() + RandomFloat( 1.0, 3.0 )
		nextOrdnanceTime = Time() + RandomFloat( 3.0, 8.0 )
		nextMeleeTime = 0.0
		nextDashTime = 0.0
		usingAntiTitan = false
		nextWeaponSwitchTime = 0.0
		rodeoTarget = null
		rodeoGiveUpTime = 0.0
		rodeoChance = RandomInt( 10, 36 )
		nextRodeoDecisionTime = Time() + RandomFloat( 5.0, 15.0 )
		rideFireToggle = false
		rodeoStartTime = null
		rodeoReaction = 0.0
		rodeoDisembark = false
		nextRodeoSmokeTime = 0.0
		strafeDir = 1.0
		nextStrafeFlip = 0.0
	}

	printt( "BotAI:", bot.GetPlayerName(), "spawned, nav nodes =", NavGetNodeCount() )

	local nextDebugTime = 0.0
	while ( true )
	{
		try { BotThinkTick( bot, brain ) }
		catch ( e ) { BotReportError( bot, "BotThinkTick", e ) }

		if ( BOT_DEBUG_HUD && Time() > nextDebugTime )
		{
			nextDebugTime = Time() + 2.0
			try { BotShowDebugHud( bot, brain ) }
			catch ( e ) { BotReportError( bot, "BotShowDebugHud", e ) }
		}
		wait BOT_THINK_INTERVAL
	}
}

function BotThinkTick( bot, brain )
{
	local origin = bot.GetOrigin()
	local isTitan = bot.IsTitan()

	// Riding an enemy titan: the rodeo has its own small loop.
	if ( !isTitan )
	{
		local ridingSoul = bot.GetTitanSoulBeingRodeoed()
		if ( IsValid( ridingSoul ) )
		{
			try { BotRodeoRideTick( bot, brain, ridingSoul ) }
			catch ( e ) { BotReportError( bot, "RodeoRide", e ) }
			return
		}
	}

	// Every stage is guarded: a failing stage is skipped for this tick and reported once,
	// instead of killing the whole think thread (which hands the bot back to the engine's
	// wander-only dev bot logic).
	try { UpdateTarget( bot, brain ) }
	catch ( e ) { BotReportError( bot, "UpdateTarget", e ) }
	local hasVisibleTarget = brain.target != null && IsValid( brain.target ) && Time() - brain.targetLastSeenTime < BOT_THINK_INTERVAL * 2

	try { UpdateThreat( bot, brain, isTitan, hasVisibleTarget ) }
	catch ( e ) { BotReportError( bot, "UpdateThreat", e ); brain.fleeing = false }

	try { UpdateTitanDecisions( bot, brain, isTitan, hasVisibleTarget ) }
	catch ( e ) { BotReportError( bot, "UpdateTitanDecisions", e ) }

	// Every now and then, go for a rodeo on a nearby enemy titan instead of shooting it.
	local rodeoTitan = null
	try { rodeoTitan = UpdateRodeoAttempt( bot, brain, isTitan, hasVisibleTarget ) }
	catch ( e ) { BotReportError( bot, "UpdateRodeoAttempt", e ); brain.rodeoTarget = null }
	if ( rodeoTitan != null )
	{
		try { BotRodeoApproachTick( bot, brain, rodeoTitan ) }
		catch ( e ) { BotReportError( bot, "RodeoApproach", e ); brain.rodeoTarget = null }
		return
	}

	local moveDir = null
	try
	{
		if ( brain.fleeing && ( brain.fleeDirect || brain.fleeGoal == null ) )
			moveDir = GetDirectFleeDirection( bot, brain )
		else
			moveDir = GetPathDirection( bot, brain, ChooseGoal( bot, brain, isTitan ), isTitan )
	}
	catch ( e )
	{
		BotReportError( bot, "Navigation", e )
		// Fall back to running straight at the target, if any.
		if ( hasVisibleTarget )
			moveDir = brain.target.GetOrigin() - origin
	}

	local pressed = 0
	local buttons = 0
	local forward = 0.0
	local side = 0.0

	// Combat: hold position and strafe inside engage range, otherwise keep moving along the path.
	// While fleeing the bot keeps running and only shoots at what ends up in front of it.
	local combatWall = false
	local targetIsTitan = hasVisibleTarget && IsTitanEntity( brain.target )
	local engageDist = isTitan ? BOT_TITAN_ENGAGE_DIST : ( targetIsTitan ? BOT_PILOT_AT_ENGAGE_DIST : BOT_PILOT_ENGAGE_DIST )
	local inEngageRange = hasVisibleTarget && !brain.fleeing && Distance( origin, brain.target.GetOrigin() ) < engageDist

	// On foot: anti-titan weapon out against titans, primary against everything else.
	try { UpdateWeaponChoice( bot, brain, isTitan ) }
	catch ( e ) { BotReportError( bot, "UpdateWeaponChoice", e ) }

	if ( inEngageRange )
	{
		local targetDist = Distance( origin, brain.target.GetOrigin() )
		// Hand to hand only makes sense pilot vs pilot/grunt or titan vs anything.
		local canRush = isTitan || !targetIsTitan
		if ( canRush && targetDist < ( isTitan ? BOT_TITAN_MELEE_RUSH_DIST : BOT_PILOT_MELEE_RUSH_DIST ) )
		{
			// Close enough to finish it hand to hand: run straight at the target.
			local relative = MoveDirRelativeToView( brain.target.GetOrigin() - origin, brain.yaw )
			forward = relative.forward
			side = relative.side
		}
		else if ( !isTitan )
		{
			// Pilots never stand still to shoot: they circle the target, run along walls and keep
			// their distance, while the aim stays on the target (movement is relative to the view).
			local combatMove = GetPilotCombatMove( bot, brain, targetIsTitan )
			combatWall = brain.combatWallSeen
			local relative = MoveDirRelativeToView( combatMove, brain.yaw )
			forward = relative.forward
			side = relative.side
		}
		else
		{
			if ( Time() > brain.nextStrafeFlip )
			{
				brain.strafeDir = -brain.strafeDir
				brain.nextStrafeFlip = Time() + RandomFloat( 0.6, 1.6 )
			}
			side = brain.strafeDir
		}
	}
	else if ( moveDir != null )
	{
		local relative = MoveDirRelativeToView( moveDir, brain.yaw )
		forward = relative.forward
		side = relative.side

		// Travelling: drift onto walls along the route to wallrun them, and steer onto walls
		// in the air to chain one wallrun into the next.
		if ( !isTitan && forward > 0.7 )
		{
			local seekDist = bot.IsOnGround() ? BOT_WALL_SEEK_DIST * brain.wallLove : BOT_WALL_AIR_DIST
			if ( !bot.IsOnGround() || Length2D( moveDir ) > BOT_WALLRUN_MIN_DIST )
			{
				local wallSide = FindWallSide( bot, seekDist )
				if ( wallSide != 0 )
					side = BotClamp( side + wallSide * BOT_WALL_SEEK_STRENGTH, -1.0, 1.0 )
			}
		}
	}

	// Aim at the target when we have one, otherwise look where we are going (always, when fleeing).
	try
	{
		if ( hasVisibleTarget && !brain.fleeing )
			AimAt( brain, bot.EyePosition(), brain.target.GetWorldSpaceCenter(), true )
		else if ( moveDir != null )
			AimAt( brain, origin, origin + moveDir, false )
	}
	catch ( e ) { BotReportError( bot, "AimAt", e ) }

	local fireButtons = 0
	try { fireButtons = UpdateFiring( bot, brain, hasVisibleTarget ) }
	catch ( e ) { BotReportError( bot, "UpdateFiring", e ) }
	buttons = buttons | fireButtons

	// Sprint between bursts (firing cancels sprint anyway).
	if ( !isTitan && forward > 0.5 && ( fireButtons & BOT_IN_ATTACK ) == 0 )
		buttons = buttons | BOT_IN_SPEED

	try { pressed = pressed | UpdateReload( bot ) }
	catch ( e ) { BotReportError( bot, "UpdateReload", e ) }

	try
	{
		if ( !isTitan && inEngageRange )
			pressed = pressed | UpdateCombatJumps( bot, brain )
		else if ( !isTitan )
			pressed = pressed | UpdateParkour( bot, brain, moveDir, forward, side, combatWall )
		else
			pressed = pressed | UpdateTitanDash( bot, brain, hasVisibleTarget, inEngageRange, side )
	}
	catch ( e ) { BotReportError( bot, "UpdateParkour", e ) }

	try { UpdateMelee( bot, brain, isTitan, hasVisibleTarget ) }
	catch ( e ) { BotReportError( bot, "UpdateMelee", e ) }

	// After aiming, so a grenade throw can lift the pitch for its arc.
	try { pressed = pressed | UpdateAbilities( bot, brain, isTitan, hasVisibleTarget ) }
	catch ( e ) { BotReportError( bot, "UpdateAbilities", e ) }

	try { UpdateStuck( bot, brain, moveDir, forward, side ) }
	catch ( e ) { BotReportError( bot, "UpdateStuck", e ) }

	try
	{
		BotSetInput( bot, forward.tofloat(), side.tofloat(), brain.pitch.tofloat(), brain.yaw.tofloat(), buttons )
		if ( pressed != 0 )
			BotPressButtons( bot, pressed )
	}
	catch ( e ) { BotReportError( bot, "BotSetInput", e ) }
}

// Debug: one bot at a time reports its native usercmd counters and real speed on the HUD.
function BotShowDebugHud( bot, brain )
{
	if ( !( "botDebugBot" in level ) || !IsValid( level.botDebugBot ) || !IsAlive( level.botDebugBot ) )
		level.botDebugBot <- bot
	if ( level.botDebugBot != bot )
		return

	local velocity = bot.GetVelocity()
	local speed = sqrt( velocity.x * velocity.x + velocity.y * velocity.y )
	local preyName = brain.prey == null ? "" : ( brain.prey.IsPlayer() ? brain.prey.GetPlayerName() : brain.prey.GetClassname() )
	local goal = brain.fleeing ? "fleeing" : ( brain.target != null ? "target" : ( brain.prey != null ? "hunting " + preyName : ( brain.patrolGoal != null ? "exploring" : "no goal" ) ) )
	local text = bot.GetPlayerName() + " vel=" + speed.tointeger() + " path=" + brain.path.len() + " " + goal
		+ "\n" + BotGetDebugInfo( bot )

	foreach ( player in GetPlayerArray() )
	{
		if ( !player.IsBot() )
			SendHudMessage( player, text, -1, 0.12, 255, 255, 120, 255, 0.0, 2.2, 0.0 )
	}
}

// First error per stage is printed and shown on every human's HUD, so it can be read in-game.
function BotReportError( bot, where, e )
{
	if ( !( "botErrorsReported" in level ) )
		level.botErrorsReported <- {}
	if ( where in level.botErrorsReported )
		return
	level.botErrorsReported[ where ] <- true

	local text = "BotAI error in " + where + ": " + e
	printt( text, "(bot:", IsValid( bot ) ? bot.GetPlayerName() : "?", ")" )
	foreach ( player in GetPlayerArray() )
	{
		if ( !player.IsBot() )
			SendHudMessage( player, text, -1, 0.25, 255, 80, 80, 255, 0.2, 60.0, 1.0 )
	}
}

//---------------------------------------------------------
// Perception
//---------------------------------------------------------
function UpdateTarget( bot, brain )
{
	local eye = bot.EyePosition()
	local enemyTeam = GetOtherTeam( bot.GetTeam() )
	local best = null
	local bestScore = BOT_SIGHT_RANGE * BOT_NPC_TARGET_BIAS

	// Enemy pilots/titans, plus the enemy team's grunts, spectres and auto-titans.
	local candidates = GetEnemyNPCs( enemyTeam, eye, BOT_SIGHT_RADIUS )
	candidates.extend( GetNPCArrayEx( "npc_titan", enemyTeam, eye, BOT_SIGHT_RADIUS ) )
	candidates.extend( GetPlayerArrayOfTeam( enemyTeam ) )
	foreach ( enemy in candidates )
	{
		if ( !IsAlive( enemy ) )
			continue

		local dist = Distance( eye, enemy.GetOrigin() )
		if ( dist >= BOT_SIGHT_RANGE )
			continue
		local score = enemy.IsPlayer() ? dist : dist * BOT_NPC_TARGET_BIAS
		// A pilot riding a titan is the first thing to shoot (to save a teammate's titan).
		if ( IsRodeoing( enemy ) )
			score *= BOT_RODEO_TARGET_BIAS
		if ( score >= bestScore || !CanSee( bot, eye, enemy ) )
			continue

		best = enemy
		bestScore = score
	}

	if ( best != null )
	{
		if ( best != brain.target )
			brain.targetAcquiredTime = Time()
		brain.target = best
		brain.targetLastSeenPos = best.GetOrigin()
		brain.targetLastSeenTime = Time()
	}
	else if ( brain.target != null && ( !IsAlive( brain.target ) || Time() - brain.targetLastSeenTime > BOT_TARGET_MEMORY ) )
	{
		brain.target = null
		brain.targetLastSeenPos = null
	}
}

// Enemy grunts and spectres within radius (an int; -1 = whole map).
function GetEnemyNPCs( enemyTeam, origin, radius )
{
	local npcs = GetNPCArrayEx( "npc_soldier", enemyTeam, origin, radius )
	npcs.extend( GetNPCArrayEx( "npc_spectre", enemyTeam, origin, radius ) )
	return npcs
}

function CanSee( bot, eye, enemy )
{
	local result = TraceLine( eye, enemy.GetWorldSpaceCenter(), bot, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )
	return result.hitEnt == enemy || result.fraction >= 0.99
}

//---------------------------------------------------------
// Titans
//---------------------------------------------------------
function UpdateTitanDecisions( bot, brain, isTitan, hasVisibleTarget )
{
	if ( isTitan )
	{
		brain.titanCallAt = null
		if ( !brain.ejected && bot.GetHealth() < bot.GetMaxHealth() * BOT_EJECT_HEALTH_FRAC )
		{
			brain.ejected = true
			thread TitanEjectPlayer( bot )
			return
		}
		UpdateRodeoDefense( bot, brain )
		return
	}

	brain.ejected = false
	brain.rodeoStartTime = null

	local petTitan = bot.GetPetTitan()
	if ( IsAlive( petTitan ) )
	{
		// Don't climb back in while an enemy is still riding it: deal with them first.
		local petSoul = petTitan.GetTitanSoul()
		local rider = IsValid( petSoul ) ? petSoul.GetRiderEnt() : null
		local enemyRider = IsValid( rider ) && rider.GetTeam() != bot.GetTeam()
		if ( !enemyRider && Distance( bot.GetOrigin(), petTitan.GetOrigin() ) < BOT_EMBARK_DIST && PlayerCanEmbarkTitan( bot, petTitan ) )
			PlayerLungesToEmbark( bot, petTitan )
		return
	}

	// Same build timer as humans (IsReplacementTitanAvailable is always true for bots, so it can't gate this).
	if ( !bot.IsTitanReady() )
	{
		brain.titanCallAt = null
		return
	}

	// Meter just filled: pick when this bot will actually drop it.
	if ( brain.titanCallAt == null )
	{
		brain.titanCallAt = Time() + RandomFloat( BOT_TITAN_CALL_DELAY_MIN, BOT_TITAN_CALL_DELAY_MAX )
		brain.titanHoldForEnemy = RandomInt( 4 ) == 0
	}

	if ( Time() < brain.titanCallAt )
		return

	// Some bots save the titan for when they spot an enemy, but never forever.
	if ( brain.titanHoldForEnemy && !hasVisibleTarget && Time() < brain.titanCallAt + BOT_TITAN_HOLD_FOR_ENEMY )
		return

	local enemyTooClose = hasVisibleTarget && Distance( bot.GetOrigin(), brain.target.GetOrigin() ) < BOT_TITAN_CALL_SAFE_DIST
	if ( brain.fleeing || enemyTooClose )
	{
		brain.titanCallAt = Time() + RandomFloat( 3.0, 10.0 )
		brain.titanHoldForEnemy = false
		return
	}

	brain.titanCallAt = Time() + BOT_TITAN_CALL_RETRY	// retried if the call doesn't go through
	brain.titanHoldForEnemy = false
	if ( IsReplacementTitanAvailable( bot ) )
		ClientCommand_ReplacementTitan( bot )
}

// An enemy pilot is riding our titan: electric smoke if we have it, otherwise (or if it isn't
// charged) most bots hop out after a moment to shoot the rider; the rest keep dashing to shake them.
function UpdateRodeoDefense( bot, brain )
{
	local soul = bot.GetTitanSoul()
	local rider = IsValid( soul ) ? soul.GetRiderEnt() : null
	if ( !IsValid( rider ) || rider.GetTeam() == bot.GetTeam() )
	{
		brain.rodeoStartTime = null
		return
	}

	local now = Time()
	if ( brain.rodeoStartTime == null )
	{
		brain.rodeoStartTime = now
		brain.rodeoReaction = RandomFloat( BOT_RODEO_REACTION_MIN, BOT_RODEO_REACTION_MAX )
		brain.rodeoDisembark = RandomInt( 100 ) < BOT_RODEO_DISEMBARK_CHANCE
		brain.nextRodeoSmokeTime = now + RandomFloat( 0.3, 0.8 )
		printt( "BotAI:", bot.GetPlayerName(), "is being rodeoed by", rider.GetPlayerName() )
	}

	local tactical = bot.GetOffhandWeapon( 1 )
	local hasSmoke = IsValid( tactical ) && tactical.GetWeaponClassName() == "mp_titanability_smoke"
	if ( hasSmoke && now > brain.nextRodeoSmokeTime )
	{
		BotPressButtons( bot, BOT_IN_OFFHAND_TACTICAL )
		brain.nextRodeoSmokeTime = now + BOT_RODEO_SMOKE_RETRY
	}

	// Smoke gets the first try; without it (or if the rider survives it) fall back to plan B.
	local waitFor = brain.rodeoReaction + ( hasSmoke ? BOT_RODEO_SMOKE_RETRY : 0.0 )
	if ( now - brain.rodeoStartTime < waitFor )
		return

	if ( brain.rodeoDisembark )
	{
		// Same as the TitanDisembark client command (which isn't globalized), minus the HUD callback.
		if ( PlayerCanDisembarkTitan( bot ) )
		{
			brain.rodeoStartTime = null
			bot.CockpitStartDisembark()
			thread PlayerDisembarksTitan( bot )
		}
	}
	else if ( now > brain.nextDashTime )
	{
		BotPressButtons( bot, BOT_IN_DODGE )
		brain.nextDashTime = now + RandomFloat( BOT_TITAN_DASH_COOLDOWN_MIN, BOT_TITAN_DASH_COOLDOWN_MAX )
	}
}

//---------------------------------------------------------
// Rodeo attacks
//---------------------------------------------------------
// Decide (rarely) to jump onto a nearby enemy titan; keep going until it works or stops making sense.
function UpdateRodeoAttempt( bot, brain, isTitan, hasVisibleTarget )
{
	if ( isTitan )
	{
		brain.rodeoTarget = null
		return null
	}

	local now = Time()
	if ( brain.rodeoTarget != null )
	{
		local titan = brain.rodeoTarget
		if ( !IsValid( titan ) || !IsAlive( titan ) || now > brain.rodeoGiveUpTime
			|| bot.GetHealth() < bot.GetMaxHealth() * BOT_RODEO_ABORT_HEALTH
			|| !IsValidTitanRodeoTarget( bot, titan ) )
		{
			brain.rodeoTarget = null
			brain.nextRodeoDecisionTime = now + RandomFloat( BOT_RODEO_DECISION_MIN, BOT_RODEO_DECISION_MAX )
			return null
		}
		return titan
	}

	if ( now < brain.nextRodeoDecisionTime || !hasVisibleTarget || brain.fleeing || !IsTitanEntity( brain.target ) )
		return null
	if ( Distance( bot.GetOrigin(), brain.target.GetOrigin() ) > BOT_RODEO_MAX_START_DIST )
		return null

	// One roll per window, so most titan encounters stay gunfights.
	brain.nextRodeoDecisionTime = now + RandomFloat( BOT_RODEO_DECISION_MIN, BOT_RODEO_DECISION_MAX )
	if ( RandomInt( 100 ) >= brain.rodeoChance || bot.GetHealth() < bot.GetMaxHealth() * BOT_RODEO_MIN_HEALTH )
		return null
	if ( !IsValidTitanRodeoTarget( bot, brain.target ) )
		return null

	brain.rodeoTarget = brain.target
	brain.rodeoGiveUpTime = now + BOT_RODEO_APPROACH_TIMEOUT
	printt( "BotAI:", bot.GetPlayerName(), "going for a rodeo" )
	return brain.rodeoTarget
}

// Sprint at the titan's hatch, jump for it and double jump if still below it. The engine
// attaches us once we're in the air close to the hatch and facing it.
function BotRodeoApproachTick( bot, brain, titan )
{
	local origin = bot.GetOrigin()
	local hatch = GetTitanHijackOrigin( titan )
	local toHatch = hatch - origin
	AimAt( brain, bot.EyePosition(), hatch, false )

	local relative = MoveDirRelativeToView( toHatch, brain.yaw )
	local pressed = 0
	if ( bot.IsOnGround() )
	{
		brain.usedDoubleJump = false
		if ( Length2D( toHatch ) < BOT_RODEO_JUMP_DIST )
			pressed = BOT_IN_JUMP
	}
	else if ( !brain.usedDoubleJump && toHatch.z > 30.0 )
	{
		brain.usedDoubleJump = true
		pressed = BOT_IN_JUMP
	}

	BotSetInput( bot, relative.forward.tofloat(), relative.side.tofloat(), brain.pitch.tofloat(), brain.yaw.tofloat(), BOT_IN_SPEED )
	if ( pressed != 0 )
		BotPressButtons( bot, pressed )
}

// On the titan: keep shooting into the hatch (trigger pulsed so semi-autos keep firing too),
// reload when dry, and jump off if it's getting us killed.
function BotRodeoRideTick( bot, brain, soul )
{
	brain.rodeoTarget = null

	local titan = soul.GetTitan()
	if ( IsValid( titan ) )
		AimAt( brain, bot.EyePosition(), GetTitanHijackOrigin( titan ), false )

	brain.rideFireToggle = !brain.rideFireToggle
	local buttons = brain.rideFireToggle ? BOT_IN_ATTACK : 0

	local pressed = UpdateReload( bot )
	if ( bot.GetHealth() < bot.GetMaxHealth() * BOT_RODEO_BAIL_HEALTH )
		pressed = pressed | BOT_IN_JUMP

	BotSetInput( bot, 0.0, 0.0, brain.pitch.tofloat(), brain.yaw.tofloat(), buttons )
	if ( pressed != 0 )
		BotPressButtons( bot, pressed )
}

//---------------------------------------------------------
// Threats
//---------------------------------------------------------
function UpdateThreat( bot, brain, isTitan, hasVisibleTarget )
{
	local origin = bot.GetOrigin()
	local enemyTeam = GetOtherTeam( bot.GetTeam() )

	// Live grenade nearby: short dash straight away from it, no pathing.
	if ( !isTitan )
	{
		// The radius argument of the Get*ArrayEx natives must be an integer.
		local grenades = GetProjectileArrayEx( "npc_grenade_frag", enemyTeam, origin, BOT_GRENADE_DANGER_RADIUS )
		if ( grenades.len() > 0 )
		{
			StartFleeing( bot, brain, grenades[0].GetOrigin(), RandomFloat( 1.0, 1.5 ), true )
			return
		}
	}

	if ( brain.fleeing )
	{
		if ( Time() < brain.fleeUntil )
			return
		StopFleeing( brain )
	}

	local threatPos = FindThreatPosition( bot, brain, isTitan, hasVisibleTarget, enemyTeam )
	if ( threatPos == null )
		return

	// Badly hurt: run for longer, to cover inside a building, until health comes back.
	local hurt = bot.GetHealth() < bot.GetMaxHealth() * ( isTitan ? BOT_TITAN_FLEE_HEALTH : BOT_PILOT_FLEE_HEALTH )
	StartFleeing( bot, brain, threatPos, hurt ? RandomFloat( 5.0, 9.0 ) : RandomFloat( 2.5, 5.0 ), false )
}

function FindThreatPosition( bot, brain, isTitan, hasVisibleTarget, enemyTeam )
{
	local origin = bot.GetOrigin()
	local eye = bot.EyePosition()

	// On foot vs an enemy titan (player or auto-titan): fight it with the anti-titan weapon from range,
	// but back off if it gets close enough to stomp us, or if we have nothing that hurts it.
	if ( !isTitan && brain.rodeoTarget == null )
	{
		local hasAntiTitan = GetPilotAntiTitanWeapon( bot ) != null
		foreach ( titan in GetEnemyTitansNear( enemyTeam, origin, BOT_FLEE_TITAN_DIST ) )
		{
			if ( !CanSee( bot, eye, titan ) )
				continue
			if ( !hasAntiTitan || Distance( origin, titan.GetOrigin() ) < BOT_TITAN_TOO_CLOSE_DIST )
				return titan.GetOrigin()
		}
	}

	if ( !hasVisibleTarget )
		return null

	local fleeHealth = isTitan ? BOT_TITAN_FLEE_HEALTH : BOT_PILOT_FLEE_HEALTH
	if ( bot.GetHealth() < bot.GetMaxHealth() * fleeHealth )
		return brain.target.GetOrigin()

	// Outnumbered: back away from the middle of the group (grunts/spectres count as half an enemy).
	local enemyCount = 0.0
	local seenCount = 0
	local enemyCenter = Vector( 0, 0, 0 )
	local enemies = GetEnemyNPCs( enemyTeam, origin, BOT_OUTNUMBER_RADIUS )
	enemies.extend( GetPlayerArrayOfTeam( enemyTeam ) )
	foreach ( enemy in enemies )
	{
		if ( !IsAlive( enemy ) || Distance( origin, enemy.GetOrigin() ) > BOT_OUTNUMBER_DIST || !CanSee( bot, eye, enemy ) )
			continue
		enemyCount += enemy.IsPlayer() ? 1.0 : BOT_NPC_THREAT_WEIGHT
		seenCount++
		enemyCenter = enemyCenter + enemy.GetOrigin()
	}

	local allyCount = 0
	foreach ( ally in GetPlayerArrayOfTeam( bot.GetTeam() ) )
	{
		if ( ally != bot && IsAlive( ally ) && Distance( origin, ally.GetOrigin() ) < BOT_OUTNUMBER_DIST )
			allyCount++
	}

	if ( seenCount > 0 && enemyCount >= allyCount + 2 )
		return enemyCenter * ( 1.0 / seenCount )

	return null
}

function GetEnemyTitansNear( enemyTeam, origin, radius )
{
	local titans = GetNPCArrayEx( "npc_titan", enemyTeam, origin, BOT_FLEE_TITAN_RADIUS )
	foreach ( player in GetPlayerArrayOfTeam( enemyTeam ) )
	{
		if ( IsAlive( player ) && player.IsTitan() && Distance( origin, player.GetOrigin() ) < radius )
			titans.append( player )
	}
	return titans
}

function StartFleeing( bot, brain, threatPos, duration, direct )
{
	if ( !brain.fleeing )
		brain.fleeStartTime = Time()
	brain.fleeing = true
	brain.fleeUntil = Time() + duration
	brain.fleeFrom = threatPos
	brain.fleeDirect = direct
	brain.fleeGoal = direct ? null : ChooseFleeGoal( bot, threatPos )
	brain.nextRepathTime = 0.0
}

function StopFleeing( brain )
{
	brain.fleeing = false
	brain.fleeFrom = null
	brain.fleeGoal = null
	brain.path = []
	brain.pathIndex = 0
	brain.nextRepathTime = 0.0
}

// Somewhere to run to: farther from the threat than we are now, preferably inside a building
// (roof overhead) and out of the threat's line of sight.
function ChooseFleeGoal( bot, threatPos )
{
	local nodeCount = NavGetNodeCount()
	if ( nodeCount == 0 )
		return null

	local origin = bot.GetOrigin()
	local currentDist = Distance( origin, threatPos )
	local threatEye = threatPos + Vector( 0, 0, 48 )
	local best = null
	local bestScore = -1.0
	for ( local i = 0; i < BOT_FLEE_CANDIDATES; i++ )
	{
		local pos = GetNodeVector( RandomInt( nodeCount ) )
		local travel = Distance( origin, pos )
		if ( travel < BOT_FLEE_MIN_TRAVEL || travel > BOT_FLEE_MAX_TRAVEL )
			continue

		local threatDist = Distance( pos, threatPos )
		local indoors = IsUnderRoof( pos )
		local hidden = TraceLine( threatEye, pos + Vector( 0, 0, 48 ), null, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE ).fraction < 1.0

		// Getting closer is only fine if it puts a roof and a wall between us.
		if ( threatDist <= currentDist && !( indoors && hidden ) )
			continue

		local score = threatDist
		if ( indoors )
			score += BOT_FLEE_INDOOR_BONUS
		if ( hidden )
			score += BOT_FLEE_HIDDEN_BONUS

		if ( score > bestScore )
		{
			best = pos
			bestScore = score
		}
	}
	return best
}

function IsUnderRoof( pos )
{
	local start = pos + Vector( 0, 0, 32 )
	return TraceLine( start, start + Vector( 0, 0, BOT_ROOF_CHECK_HEIGHT ), null, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE ).fraction < 1.0
}

function GetDirectFleeDirection( bot, brain )
{
	local away = bot.GetOrigin() - brain.fleeFrom
	local dir = Vector( away.x, away.y, 0 )
	if ( Length2D( dir ) < 1.0 )
	{
		// Standing on top of it: just run backwards from where we're facing.
		local facing = bot.GetForwardVector()
		dir = Vector( -facing.x, -facing.y, 0 )
	}
	return dir * ( 200.0 / max( Length2D( dir ), 1.0 ) )
}

//---------------------------------------------------------
// Navigation
//---------------------------------------------------------
function ChooseGoal( bot, brain, isTitan )
{
	if ( brain.fleeing )
		return brain.fleeGoal

	if ( brain.targetLastSeenPos != null )
		return brain.targetLastSeenPos

	if ( !isTitan )
	{
		local petTitan = bot.GetPetTitan()
		if ( IsAlive( petTitan ) )
			return petTitan.GetOrigin()
	}

	// Hunt: chase a chosen enemy's current position across the map (the path is rebuilt as it moves),
	// often going around through a flank point so bots don't all take the same route.
	// Some bots roam for a bit after spawning instead, to spread the team out.
	if ( Time() > brain.roamUntil )
	{
		local prey = ChoosePrey( bot, brain )
		if ( prey != null )
		{
			local flank = GetFlankPoint( bot, brain, prey )
			return flank != null ? flank : prey.GetOrigin()
		}
	}

	// Nobody to hunt: roam the map.
	local hasNav = NavGetNodeCount() > 0
	if ( brain.patrolGoal == null || Time() > brain.patrolUntil || Distance( bot.GetOrigin(), brain.patrolGoal ) < BOT_PILOT_NODE_REACHED * 2 )
	{
		if ( brain.patrolGoal != null )
			RememberVisited( brain, brain.patrolGoal )

		if ( hasNav )
		{
			brain.patrolGoal = ChooseExploreGoal( bot, brain )
			brain.patrolUntil = Time() + RandomFloat( BOT_PATROL_TIME * 0.5, BOT_PATROL_TIME * 1.35 )
		}
		else
		{
			// No node graph on this map: run straight at the enemy (stuck detection hops and re-picks).
			brain.patrolGoal = ChooseHuntGoal( bot )
			if ( brain.patrolGoal == null )
				brain.patrolGoal = GetRandomRoamPoint( bot )
			brain.patrolUntil = Time() + RandomFloat( 5.0, 10.0 )
		}
	}
	return brain.patrolGoal
}

// Mostly the nearest enemy, sometimes a random one so bots spread out; switch every so often.
function ChoosePrey( bot, brain )
{
	if ( brain.prey != null && IsValid( brain.prey ) && IsAlive( brain.prey ) && Time() < brain.preyUntil )
		return brain.prey

	local origin = bot.GetOrigin()
	local enemyTeam = GetOtherTeam( bot.GetTeam() )
	local pilots = []
	local nearest = null
	local nearestDist = 0.0

	// Nearest of anything hostile (pilots, grunts, spectres); random picks are pilots only.
	local candidates = GetEnemyNPCs( enemyTeam, origin, -1 )
	candidates.extend( GetPlayerArrayOfTeam( enemyTeam ) )
	foreach ( enemy in candidates )
	{
		if ( !IsAlive( enemy ) )
			continue
		if ( enemy.IsPlayer() )
			pilots.append( enemy )
		local dist = Distance( origin, enemy.GetOrigin() )
		if ( nearest == null || dist < nearestDist )
		{
			nearest = enemy
			nearestDist = dist
		}
	}

	if ( nearest == null )
	{
		brain.prey = null
		return null
	}

	if ( RandomInt( 100 ) < brain.preyNearestChance || pilots.len() == 0 )
		brain.prey = nearest
	else
		brain.prey = pilots[ RandomInt( pilots.len() ) ]
	brain.preyUntil = Time() + RandomFloat( BOT_PREY_MIN_TIME, BOT_PREY_MAX_TIME )
	return brain.prey
}

// A node off to one side of the straight line to the prey, visited on the way there.
// Decided once per prey; dropped once reached, on timeout, or when the prey is close anyway.
function GetFlankPoint( bot, brain, prey )
{
	local origin = bot.GetOrigin()
	local preyPos = prey.GetOrigin()

	if ( brain.flankFor != prey )
	{
		brain.flankFor = prey
		brain.flankPoint = null
		local dist = Distance( origin, preyPos )
		if ( dist > BOT_FLANK_MIN_DIST && RandomInt( 100 ) < brain.flankChance && NavGetNodeCount() > 0 )
		{
			local toPrey = preyPos - origin
			local length = max( Length2D( toPrey ), 1.0 )
			local perp = Vector( -toPrey.y / length, toPrey.x / length, 0 )
			local along = origin + toPrey * RandomFloat( 0.3, 0.6 )
			local offset = RandomFloat( 0.4, 1.0 ) * min( dist * 0.5, 1800.0 ) * ( RandomInt( 2 ) == 0 ? -1.0 : 1.0 )
			brain.flankPoint = FindNodeNear( along + perp * offset )
			brain.flankUntil = Time() + BOT_FLANK_TIMEOUT
		}
	}

	if ( brain.flankPoint == null )
		return null

	if ( Time() > brain.flankUntil
		|| Distance( origin, brain.flankPoint ) < BOT_FLANK_REACHED
		|| Distance( origin, preyPos ) < Distance( brain.flankPoint, preyPos ) )
	{
		brain.flankPoint = null
		return null
	}
	return brain.flankPoint
}

// Nearest graph node to a point, so the goal is always somewhere walkable.
// A path from a point to itself is just that point's nearest node.
function FindNodeNear( point )
{
	local flat = NavFindPath( point.x, point.y, point.z, point.x, point.y, point.z, BOT_HULL_PILOT )
	if ( flat.len() < 3 )
		return null
	return Vector( flat[0], flat[1], flat[2] )
}

function GetRandomRoamPoint( bot )
{
	local yaw = RandomFloat( -PI, PI )
	return bot.GetOrigin() + Vector( cos( yaw ) * BOT_NO_NAV_ROAM_DIST, sin( yaw ) * BOT_NO_NAV_ROAM_DIST, 0 )
}

// Roam the whole map: prefer far nodes we haven't been to lately, and sometimes go hunting
// around a random enemy so bots drift towards the action instead of wandering forever.
function ChooseExploreGoal( bot, brain )
{
	if ( RandomInt( 100 ) < BOT_HUNT_CHANCE )
	{
		local huntGoal = ChooseHuntGoal( bot )
		if ( huntGoal != null )
			return huntGoal
	}

	local nodeCount = NavGetNodeCount()
	local origin = bot.GetOrigin()
	local best = null
	local bestScore = -1.0
	for ( local i = 0; i < BOT_EXPLORE_CANDIDATES; i++ )
	{
		local pos = GetNodeVector( RandomInt( nodeCount ) )
		local score = min( Distance( origin, pos ), BOT_EXPLORE_FAR_DIST )
		if ( WasVisited( brain, pos ) )
			score *= 0.2
		score += RandomFloat( 0.0, 800.0 )

		if ( score > bestScore )
		{
			best = pos
			bestScore = score
		}
	}
	return best
}

function ChooseHuntGoal( bot )
{
	local enemies = []
	foreach ( enemy in GetPlayerArrayOfTeam( GetOtherTeam( bot.GetTeam() ) ) )
	{
		if ( IsAlive( enemy ) )
			enemies.append( enemy )
	}
	if ( enemies.len() == 0 )
		return null

	local enemyPos = enemies[ RandomInt( enemies.len() ) ].GetOrigin()
	return enemyPos + Vector( RandomFloat( -BOT_HUNT_SPREAD, BOT_HUNT_SPREAD ), RandomFloat( -BOT_HUNT_SPREAD, BOT_HUNT_SPREAD ), 0 )
}

function RememberVisited( brain, pos )
{
	brain.visitedGoals.append( pos )
	if ( brain.visitedGoals.len() > BOT_VISITED_MEMORY )
		brain.visitedGoals.remove( 0 )
}

function WasVisited( brain, pos )
{
	foreach ( visited in brain.visitedGoals )
	{
		if ( Distance( visited, pos ) < BOT_VISITED_RADIUS )
			return true
	}
	return false
}

function GetNodeVector( index )
{
	local pos = NavGetNodePosition( index )
	return Vector( pos[0], pos[1], pos[2] )
}

function GetPathDirection( bot, brain, goal, isTitan )
{
	if ( goal == null )
		return null

	local origin = bot.GetOrigin()
	local needsRepath = brain.pathGoal == null
		|| Distance( goal, brain.pathGoal ) > BOT_GOAL_REPATH_DIST
		|| Time() > brain.nextRepathTime
		|| brain.pathIndex >= brain.path.len()

	if ( needsRepath )
		BuildPath( bot, brain, goal, isTitan )

	local reached = isTitan ? BOT_TITAN_NODE_REACHED : BOT_PILOT_NODE_REACHED
	while ( brain.pathIndex < brain.path.len() && Distance2D( origin, brain.path[ brain.pathIndex ] ) < reached )
		brain.pathIndex++

	local waypoint = brain.pathIndex < brain.path.len() ? brain.path[ brain.pathIndex ] : goal
	local dir = waypoint - origin
	if ( Length2D( dir ) < 1.0 )
		return null
	return dir
}

function BuildPath( bot, brain, goal, isTitan )
{
	local origin = bot.GetOrigin()
	local hull = isTitan ? BOT_HULL_TITAN : BOT_HULL_PILOT
	local flat = NavFindPath( origin.x, origin.y, origin.z, goal.x, goal.y, goal.z, hull )

	brain.path = []
	for ( local i = 0; i + 2 < flat.len(); i += 3 )
		brain.path.append( Vector( flat[i], flat[i + 1], flat[i + 2] ) )

	brain.pathIndex = 0
	brain.pathGoal = goal
	brain.nextRepathTime = Time() + BOT_REPATH_INTERVAL
}

function UpdateStuck( bot, brain, moveDir, forward, side )
{
	local wantsToMove = moveDir != null && ( fabs( forward ) > 0.1 || fabs( side ) > 0.1 )
	local origin = bot.GetOrigin()

	if ( !wantsToMove || Distance( origin, brain.lastProgressPos ) > BOT_STUCK_DIST )
	{
		brain.lastProgressPos = origin
		brain.lastProgressTime = Time()
		return
	}

	if ( Time() - brain.lastProgressTime < BOT_STUCK_TIME )
		return

	// Stuck: hop and pick a fresh route (and a new patrol point if we were patrolling).
	BotPressButtons( bot, BOT_IN_JUMP )
	brain.nextRepathTime = 0.0
	brain.patrolGoal = null
	brain.flankPoint = null
	brain.lastProgressPos = origin
	brain.lastProgressTime = Time()
}

//---------------------------------------------------------
// Movement helpers
//---------------------------------------------------------
function MoveDirRelativeToView( moveDir, viewYaw )
{
	local moveYaw = atan2( moveDir.y, moveDir.x ) * ( 180.0 / PI )
	local delta = NormalizeYaw( moveYaw - viewYaw ) * ( PI / 180.0 )
	// Source movement: +forward along view, +side to the right (negative yaw direction).
	return { forward = cos( delta ), side = -sin( delta ) }
}

function UpdateParkour( bot, brain, moveDir, forward, side, combatWall )
{
	local now = Time()
	local wallRunning = bot.IsWallRunning()
	if ( wallRunning && !brain.wasWallRunning )
	{
		brain.wallrunStartTime = now
		brain.wallrunHopAfter = RandomFloat( 0.6, 1.4 )
	}
	brain.wasWallRunning = wallRunning

	local travelling = moveDir != null && forward > 0.3

	if ( bot.IsOnGround() )
	{
		brain.usedDoubleJump = false

		if ( travelling )
		{
			// Next waypoint is above us: jump to climb onto it.
			if ( moveDir.z > 48.0 && Length2D( moveDir ) < 250.0 )
				return BOT_IN_JUMP

			// Something knee-high in the way: hop it.
			if ( IsObstacleAhead( bot, moveDir ) )
				return BOT_IN_JUMP
		}

		// Wall alongside on a long run, or in a fight: jump onto it. Heading for a wall that is
		// still a bit away, jump early and let the air steering carry us onto it.
		local longRun = travelling && Length2D( moveDir ) > BOT_WALLRUN_MIN_DIST
		if ( longRun || combatWall )
		{
			if ( IsWallBeside( bot ) )
				return BOT_IN_JUMP
			if ( fabs( side ) > 0.5 && FindWallSide( bot, BOT_WALL_AIR_DIST ) != 0 )
				return BOT_IN_JUMP
		}
		return 0
	}

	if ( wallRunning )
	{
		// In a fight, don't sit on one wall: hop off after a moment (onto the next wall if there is one).
		if ( combatWall && now - brain.wallrunStartTime > brain.wallrunHopAfter )
			return BOT_IN_JUMP

		// Travelling: kick off once the route leaves the wall (waypoint close or above us).
		if ( travelling && ( moveDir.z > 48.0 || Length2D( moveDir ) < 150.0 ) )
			return BOT_IN_JUMP
		return 0
	}

	// Airborne: double jump if we still need height, or to reach a wall we're steering onto
	// before falling short of it.
	if ( !brain.usedDoubleJump )
	{
		local needHeight = travelling && moveDir.z > 24.0
		local reachWall = bot.GetVelocity().z < -60.0 && FindWallSide( bot, BOT_WALL_AIR_DIST ) != 0
		if ( needHeight || reachWall )
		{
			brain.usedDoubleJump = true
			return BOT_IN_JUMP
		}
	}

	return 0
}

// Where a pilot runs during a gunfight (world space; the aim stays on the target):
// along a wall if one is at hand, otherwise circling the target while holding its preferred range.
function GetPilotCombatMove( bot, brain, targetIsTitan )
{
	local origin = bot.GetOrigin()
	local toTarget = brain.target.GetOrigin() - origin
	local dist = max( Length2D( toTarget ), 1.0 )
	local dir = Vector( toTarget.x / dist, toTarget.y / dist, 0 )
	local preferred = targetIsTitan ? BOT_AT_PREFERRED_DIST : brain.preferredDist
	local closeIn = dist > preferred

	// Already on a wall: keep riding it the way we're going.
	if ( bot.IsWallRunning() )
	{
		local velocity = bot.GetVelocity()
		local speed = Length2D( velocity )
		if ( speed > 50.0 )
			return Vector( velocity.x / speed, velocity.y / speed, 0 )
	}

	if ( Time() > brain.nextStrafeFlip )
	{
		brain.strafeDir = -brain.strafeDir
		brain.nextStrafeFlip = Time() + RandomFloat( BOT_COMBAT_STRAFE_MIN, BOT_COMBAT_STRAFE_MAX )
	}
	local perp = Vector( -dir.y, dir.x, 0 ) * brain.strafeDir

	// A wall to either side of the line to the target: run along it (towards or away from the
	// target to hold range) with a slight lean into it, and the combat jumps put us on it.
	local wallSide = FindWallAlong( bot, perp, BOT_WALL_COMBAT_DIST * brain.wallLove )
	brain.combatWallSeen = wallSide != null
	if ( wallSide != null )
	{
		local along = closeIn ? dir : dir * -1.0
		return along + wallSide * BOT_COMBAT_WALL_LEAN
	}

	// Open ground: circle the target, drifting in or out towards the preferred range.
	local radial = 0.0
	if ( dist > preferred + BOT_COMBAT_RANGE_SLACK )
		radial = BOT_COMBAT_RADIAL_SPEED
	else if ( dist < preferred - BOT_COMBAT_RANGE_SLACK )
		radial = -BOT_COMBAT_RADIAL_SPEED
	return perp + dir * radial
}

// Unit vector towards a wall within dist on the strafe side or the opposite side, or null.
function FindWallAlong( bot, perp, dist )
{
	local start = bot.GetOrigin() + Vector( 0, 0, 40 )
	foreach ( side in [ perp, perp * -1.0 ] )
	{
		if ( TraceLine( start, start + side * dist, bot, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE ).fraction < 1.0 )
			return side
	}
	return null
}

// Gunfight movement for pilots: hop every so often (half the time with a double jump),
// jump onto walls that are right beside us, and hop off a wall after a moment on it.
function UpdateCombatJumps( bot, brain )
{
	local now = Time()
	local wallRunning = bot.IsWallRunning()
	if ( wallRunning && !brain.wasWallRunning )
	{
		brain.wallrunStartTime = now
		brain.wallrunHopAfter = RandomFloat( 0.6, 1.4 )
	}
	brain.wasWallRunning = wallRunning

	if ( wallRunning )
		return now - brain.wallrunStartTime > brain.wallrunHopAfter ? BOT_IN_JUMP : 0

	if ( bot.IsOnGround() )
	{
		brain.usedDoubleJump = false
		if ( brain.combatWallSeen && IsWallBeside( bot ) )
			return BOT_IN_JUMP
		if ( now > brain.nextCombatHop )
		{
			brain.nextCombatHop = now + RandomFloat( BOT_COMBAT_HOP_MIN, BOT_COMBAT_HOP_MAX )
			brain.planDoubleJump = RandomInt( 100 ) < BOT_COMBAT_DOUBLE_JUMP_CHANCE
			return BOT_IN_JUMP
		}
		return 0
	}

	// Near the top of the jump: double jump if planned, or to reach a wall we're heading for.
	if ( !brain.usedDoubleJump && bot.GetVelocity().z < 80.0 )
	{
		local reachWall = brain.combatWallSeen && FindWallSide( bot, BOT_WALL_AIR_DIST ) != 0
		if ( brain.planDoubleJump || reachWall )
		{
			brain.usedDoubleJump = true
			brain.planDoubleJump = false
			return BOT_IN_JUMP
		}
	}
	return 0
}

// Which side has a wall within dist: 1 = right, -1 = left, 0 = none (nearest wins).
function FindWallSide( bot, dist )
{
	local origin = bot.GetOrigin() + Vector( 0, 0, 40 )
	local right = bot.GetRightVector()
	local rightHit = TraceLine( origin, origin + right * dist, bot, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE ).fraction
	local leftHit = TraceLine( origin, origin - right * dist, bot, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE ).fraction
	if ( rightHit >= 1.0 && leftHit >= 1.0 )
		return 0
	return rightHit <= leftHit ? 1 : -1
}

function IsObstacleAhead( bot, moveDir )
{
	local length = Length2D( moveDir )
	if ( length < 1.0 )
		return false

	local dir = Vector( moveDir.x / length, moveDir.y / length, 0 )
	local origin = bot.GetOrigin()
	local knee = origin + Vector( 0, 0, 24 )
	local head = origin + Vector( 0, 0, 72 )
	local low = TraceLine( knee, knee + dir * BOT_OBSTACLE_CHECK_DIST, bot, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE )
	if ( low.fraction >= 1.0 )
		return false

	// Only jump if it's low enough to clear; a full wall is the pathing/stuck logic's problem.
	local high = TraceLine( head, head + dir * BOT_OBSTACLE_CHECK_DIST, bot, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE )
	return high.fraction >= 1.0
}

function IsWallBeside( bot )
{
	local origin = bot.GetOrigin() + Vector( 0, 0, 40 )
	local right = bot.GetRightVector()
	foreach ( dir in [ right, right * -1 ] )
	{
		local result = TraceLine( origin, origin + dir * BOT_WALL_CHECK_DIST, bot, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE )
		if ( result.fraction < 1.0 )
			return true
	}
	return false
}

//---------------------------------------------------------
// Aim and weapons
//---------------------------------------------------------
function AimAt( brain, from, to, addError )
{
	local angles = VectorToAngles( to - from )
	local desiredPitch = NormalizeYaw( angles.x )
	local desiredYaw = angles.y

	if ( addError )
	{
		desiredPitch += RandomFloat( -brain.skill.aimError, brain.skill.aimError ) * 0.5
		desiredYaw += RandomFloat( -brain.skill.aimError, brain.skill.aimError )
	}

	local turn = brain.skill.turnSpeed
	brain.yaw = NormalizeYaw( brain.yaw + BotClamp( NormalizeYaw( desiredYaw - brain.yaw ), -turn, turn ) )
	brain.pitch = BotClamp( brain.pitch + BotClamp( desiredPitch - brain.pitch, -turn, turn ), -89.0, 89.0 )
}

function UpdateFiring( bot, brain, hasVisibleTarget )
{
	if ( !hasVisibleTarget || Time() - brain.targetAcquiredTime < brain.skill.reaction )
	{
		brain.firing = false
		return 0
	}

	// Only shoot once roughly on target.
	local toTarget = VectorToAngles( brain.target.GetWorldSpaceCenter() - bot.EyePosition() )
	if ( fabs( NormalizeYaw( toTarget.y - brain.yaw ) ) > 15.0 )
		return 0

	if ( Time() > brain.nextFireToggle )
	{
		brain.firing = !brain.firing
		local burst = brain.usingAntiTitan ? BOT_AT_BURST : brain.skill.burst
		local pause = brain.usingAntiTitan ? BOT_AT_PAUSE : brain.skill.pause
		brain.nextFireToggle = Time() + ( brain.firing ? burst : pause )
	}
	return brain.firing ? BOT_IN_ATTACK : 0
}

function UpdateReload( bot )
{
	local weapon = bot.GetActiveWeapon()
	if ( !IsValid( weapon ) )
		return 0
	return weapon.GetWeaponPrimaryClipCount() == 0 ? BOT_IN_RELOAD : 0
}

function IsTitanEntity( ent )
{
	return ent.IsPlayer() ? ent.IsTitan() : ent.GetClassname() == "npc_titan"
}

// Enemy pilot currently riding a titan (ours or anyone's).
function IsRodeoing( ent )
{
	return ent.IsPlayer() && !ent.IsTitan() && IsValid( ent.GetTitanSoulBeingRodeoed() )
}

// On foot: anti-titan weapon out while the target is a titan, back to the primary otherwise.
function UpdateWeaponChoice( bot, brain, isTitan )
{
	if ( isTitan || Time() < brain.nextWeaponSwitchTime )
		return

	local recentTarget = brain.target != null && IsValid( brain.target ) && Time() - brain.targetLastSeenTime < 3.0
	local wantAntiTitan = recentTarget && IsTitanEntity( brain.target )

	local weapon = wantAntiTitan ? GetPilotAntiTitanWeapon( bot ) : GetPilotAntiPersonnelWeapon( bot )
	if ( weapon == null && !wantAntiTitan )
		weapon = GetPilotSideArmWeapon( bot )
	brain.usingAntiTitan = wantAntiTitan && weapon != null
	if ( weapon == null )
		return

	local active = bot.GetActiveWeapon()
	if ( IsValid( active ) && active == weapon )
		return

	bot.SetActiveWeapon( weapon.GetWeaponClassName() )
	brain.nextWeaponSwitchTime = Time() + BOT_WEAPON_SWITCH_DELAY
}

// Tactical ability and ordnance, used when they help the bot survive a fight.
// Pressing one that isn't charged does nothing, so a failed press is just retried later.
function UpdateAbilities( bot, brain, isTitan, hasVisibleTarget )
{
	local pressed = 0
	local now = Time()
	local healthFrac = bot.GetHealth().tofloat() / max( bot.GetMaxHealth(), 1 )
	local targetDist = hasVisibleTarget ? Distance( bot.GetOrigin(), brain.target.GetOrigin() ) : 0.0

	if ( now > brain.nextTacticalTime )
	{
		local useTactical = false
		if ( isTitan )
		{
			// Vortex / smoke / particle wall while taking a beating.
			useTactical = hasVisibleTarget && healthFrac < 0.75
		}
		else
		{
			// Cloak/stim to break away as soon as a retreat starts, or when a fight is going badly.
			// Out of combat, the odd use while hunting (active radar pings who's around).
			useTactical = ( brain.fleeing && now - brain.fleeStartTime < 1.0 )
				|| ( hasVisibleTarget && healthFrac < BOT_TACTICAL_LOW_HEALTH )
				|| ( !hasVisibleTarget && brain.prey != null && RandomInt( 150 ) == 0 )
		}

		if ( useTactical )
		{
			pressed = pressed | BOT_IN_OFFHAND_TACTICAL
			brain.nextTacticalTime = now + RandomFloat( BOT_TACTICAL_RETRY_MIN, BOT_TACTICAL_RETRY_MAX )
		}
	}

	// Ordnance needs the bot looking at the target, so not while running away.
	if ( now > brain.nextOrdnanceTime && hasVisibleTarget && !brain.fleeing )
	{
		local useOrdnance = false
		if ( isTitan )
		{
			useOrdnance = targetDist < 3000.0
		}
		else if ( targetDist > BOT_ORDNANCE_MIN_DIST && targetDist < BOT_ORDNANCE_MAX_DIST )
		{
			// Grenade when the odds are bad, the target is a titan, or a group is bunched up;
			// otherwise only now and then.
			useOrdnance = healthFrac < 0.7 || IsTitanEntity( brain.target ) || RandomInt( 4 ) == 0
		}

		if ( useOrdnance )
		{
			// Lob it: aim higher the farther away the target is.
			if ( !isTitan )
				brain.pitch = BotClamp( brain.pitch - min( targetDist * 0.008, 12.0 ), -89.0, 89.0 )
			pressed = pressed | BOT_IN_OFFHAND_ORDNANCE
			brain.nextOrdnanceTime = now + RandomFloat( BOT_ORDNANCE_COOLDOWN_MIN, BOT_ORDNANCE_COOLDOWN_MAX )
		}
		else
		{
			brain.nextOrdnanceTime = now + RandomFloat( 1.0, 3.0 )
		}
	}

	return pressed
}

// Titan dash: a tap of sprint while moving. It goes the way the titan is already moving, so
// sideways while strafing in a fight and along the escape route when running away.
function UpdateTitanDash( bot, brain, hasVisibleTarget, inEngageRange, side )
{
	local now = Time()
	if ( now < brain.nextDashTime )
		return 0

	local hurt = bot.GetHealth() < bot.GetMaxHealth() * 0.5
	local dodgeInFight = inEngageRange && fabs( side ) > 0.5 && RandomInt( hurt ? 3 : 8 ) == 0
	local breakAway = brain.fleeing && now - brain.fleeStartTime < 0.5
	if ( !dodgeInFight && !breakAway )
		return 0

	brain.nextDashTime = now + RandomFloat( BOT_TITAN_DASH_COOLDOWN_MIN, BOT_TITAN_DASH_COOLDOWN_MAX )
	return BOT_IN_DODGE
}

// Kick / titan punch / execution when the target is right in front of us. Calls the same
// script entry point code uses for +melee, so the game's own melee rules apply.
function UpdateMelee( bot, brain, isTitan, hasVisibleTarget )
{
	if ( !hasVisibleTarget || Time() < brain.nextMeleeTime )
		return

	local range = isTitan ? BOT_TITAN_MELEE_RANGE : BOT_PILOT_MELEE_RANGE
	if ( Distance( bot.GetOrigin(), brain.target.GetOrigin() ) > range )
		return

	local toTarget = VectorToAngles( brain.target.GetWorldSpaceCenter() - bot.EyePosition() )
	if ( fabs( NormalizeYaw( toTarget.y - brain.yaw ) ) > 30.0 )
		return

	if ( !bot.PlayerMelee_CanMelee() || bot.PlayerMelee_GetState() != PLAYER_MELEE_STATE_NONE )
		return

	brain.nextMeleeTime = Time() + BOT_MELEE_COOLDOWN
	CodeCallback_OnMeleePressed( bot )
}

//---------------------------------------------------------
// Math
//---------------------------------------------------------
function NormalizeYaw( yaw )
{
	yaw = yaw % 360.0
	if ( yaw > 180.0 )
		yaw -= 360.0
	else if ( yaw < -180.0 )
		yaw += 360.0
	return yaw
}

function BotClamp( value, low, high )
{
	return value < low ? low : ( value > high ? high : value )
}

function Length2D( v )
{
	return sqrt( v.x * v.x + v.y * v.y )
}
