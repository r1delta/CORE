//=========================================================
// Pilot bot brain
// Drives managed bots (see _bot_manager.nut) through the native BotSetInput/BotPressButtons
// usercmd injection and NavFindPath node-graph pathfinding provided by R1Delta.
//=========================================================

const BOT_THINK_INTERVAL		= 0.1
const BOT_DEBUG_HUD				= false	// shows one bot's movement diagnostics on screen
const BOT_DEBUG_SPAWN_DEATHS	= false	// log any player death within BOT_SPAWN_DEATH_WINDOW of spawning
const BOT_SPAWN_DEATH_WINDOW	= 3.0
const BOT_SPAWN_TRACE_TIME		= 1.2	// per-tick bot log kept this long after spawning (dumped on a spawn death)
const BOT_SIGHT_RANGE			= 4000.0
const BOT_SIGHT_RADIUS			= 4000	// int copy for GetNPCArrayEx
const BOT_NPC_TARGET_BIAS		= 1.8	// pilots are the real fight: a grunt/spectre must be much closer to be picked first
const BOT_TARGET_MEMORY			= 4.0	// seconds to keep chasing the last seen position
const BOT_REPATH_INTERVAL		= 5.0
const BOT_GOAL_REPATH_DIST		= 256.0
const BOT_PATROL_TIME			= 30.0
const BOT_STUCK_TIME			= 1.0
const BOT_STUCK_DIST			= 24.0
// Doors and interiors: wall-seeking parkour near a building entrance makes bots stick to the
// facade beside the door and hop at it forever. Near a roofed waypoint, indoors, and for a while
// after getting stuck, bots walk the path precisely instead ("careful" mode).
const BOT_DOOR_APPROACH_DIST	= 700.0	// careful once a roofed waypoint is this close
const BOT_CAREFUL_NODE_REACHED	= 40.0	// tighter waypoint radius, so doorways are walked through, not cut
const BOT_INDOOR_CHECK_INTERVAL	= 0.5
const BOT_CAREFUL_AFTER_STUCK	= 5.0
// Stuck that isn't standing still: bouncing around without getting closer to the waypoint.
const BOT_WAYPOINT_PROGRESS		= 48.0
const BOT_WAYPOINT_STUCK_TIME	= 2.5
const BOT_STUCK_RESET_TIME		= 5.0	// stuck again within this escalates (hop, back off, new route)
const BOT_UNSTICK_TIME			= 0.6
const BOT_LOS_CHECK_INTERVAL	= 0.3	// how often a pilot checks it can still see its next waypoint
const BOT_BACKTRACK_TIME		= 1.0	// stepping back to the previous waypoint, at most this long
const BOT_BACKTRACK_NODE_REACHED	= 24.0
const BOT_WHISKER_OFFSET		= 18.0	// side rays this far off center (about the pilot's half width)
const BOT_WHISKER_LENGTH		= 96.0
const BOT_WHISKER_STRENGTH		= 0.7
const BOT_PILOT_NODE_REACHED	= 72.0
const BOT_TITAN_NODE_REACHED	= 180.0
const BOT_TITAN_ENGAGE_DIST		= 1500.0
const BOT_PILOT_AT_ENGAGE_DIST	= 1600.0	// on foot vs a titan: hold this range and shoot the anti-titan weapon
const BOT_TITAN_TOO_CLOSE_DIST	= 450.0		// on foot, a titan closer than this is a stomp waiting to happen: run
const BOT_AT_BURST				= 1.6		// longer trigger holds for anti-titan weapons (charge rifle needs the charge)
const BOT_AT_PAUSE				= 0.4
const BOT_PILOT_AT_TITAN_BIAS	= 0.5		// on foot with a loaded anti-titan weapon, titans are picked over anything at up to 2x the distance...
const BOT_PILOT_NO_AT_TITAN_BIAS	= 1.5	// ...without one, only when nothing else is around
const BOT_AT_KEEP_TIME			= 6.0		// keep the anti-titan weapon out this long after a titan was the target / in sight
const BOT_AT_PILOT_SWAP_DIST	= 600.0		// an enemy pilot in sight this close: primary out, whatever titans are around
const BOT_AT_CHARGE_MAX_HOLD	= 3.0		// charge rifle: let go after this long even if never lined up
const BOT_AT_CHARGE_START_ANGLE	= 20.0		// ...and only start charging within this many degrees of the target
const BOT_TITAN_FLEE_MIN		= 1.2		// with an anti-titan weapon, a titan too close is only run from this long...
const BOT_TITAN_FLEE_MAX		= 2.2		// ...before turning to shoot it again
const BOT_WEAPON_HOLD_TIME		= 4.0	// keep a weapon at least this long after switching to it
const BOT_WEAPON_DEPLOY_TIME	= 1.0	// no trigger while the switch animation plays
const BOT_WEAPON_SWITCH_CHECK	= 2.5	// by now the switch should show in GetActiveWeapon; logged if not

// Rodeo defence
const BOT_RODEO_TARGET_BIAS		= 0.4	// riders get picked as targets over anything at up to 2.5x the distance
const BOT_RODEO_REACTION_MIN	= 0.5	// time before hopping out to shoot the rider...
const BOT_RODEO_REACTION_MAX	= 1.2
const BOT_RODEO_SMOKE_GRACE		= 0.7	// ...plus this when a charged electric smoke gets the first try
const BOT_RODEO_SMOKE_RETRY		= 3.0
const BOT_RODEO_AIM_DEPTH		= 0.35	// rider aims this far from the hatch towards the titan's center (the hatch hitbox)
const BOT_TITAN_RIDER_BIAS		= 0.7	// in a titan: a pilot riding a friendly titan is picked over others at up to 1.4x the distance
const BOT_RIDER_HELP_DIST		= 1800.0	// on foot: an enemy riding a friendly titan this close is gone after...
const BOT_RIDER_SCAN_INTERVAL	= 0.3		// ...looked for this often
const BOT_RIDER_ANGLE_DIST		= 450.0		// no line on the rider: go round to this far from the titan, on the rider's side
const BOT_RIDER_ANGLE_REFRESH	= 1.0		// (that spot follows the titan this often)
const BOT_RIDER_KEEP_PILOT_DIST	= 900.0		// an enemy pilot in sight this close stays the target instead

// Rodeo attacks (kept occasional on purpose)
const BOT_RODEO_DECISION_MIN	= 8.0	// how often a bot near an enemy titan considers jumping on it
const BOT_RODEO_DECISION_MAX	= 15.0
const BOT_RODEO_MAX_START_DIST	= 900.0
const BOT_RODEO_JUMP_DIST		= 300.0	// leap for the hatch from this far out
const BOT_RODEO_APPROACH_TIMEOUT	= 8.0
const BOT_RODEO_NO_AT_BONUS		= 45	// percent added to the rodeo chance with no usable anti-titan weapon...
const BOT_RODEO_CLOSE_BONUS		= 25	// ...and with the titan already too close to fight from range
const BOT_RODEO_DECISION_NO_AT_MIN	= 2.0	// without an anti-titan weapon a rodeo is the only answer: considered this often
const BOT_RODEO_DECISION_NO_AT_MAX	= 4.0
const BOT_RODEO_MIN_HEALTH		= 0.6	// only start one when healthy...
const BOT_RODEO_ABORT_HEALTH	= 0.4	// ...give up the approach below this...
const BOT_RODEO_BAIL_HEALTH		= 0.35	// ...and jump off the titan below this (electric smoke etc.)
const BOT_RODEO_CLIMB_TIME		= 3.0	// the climb on (and hatch rip) keeps the weapon holstered about this long: no switch tries counted then
const BOT_RODEO_SWITCH_RETRY	= 0.5	// on the titan with the anti-titan weapon still out: ask for the primary this often...
const BOT_RODEO_SWITCH_ALT_TRIES	= 3		// ...from this many tries on, alternate primary / sidearm...
const BOT_RODEO_SWITCH_FORCE_TRIES	= 5	// ...once at this many, holster and redeploy to push the switch through...
const BOT_RODEO_SWITCH_GIVE_UP	= 7.0	// ...and still stuck on the launcher this long into the ride (climb included): jump off

// Riding friendly titans. Code starts a rodeo on any titan a pilot touches mid-air, so bots, always
// jumping and wallrunning around their own titans, kept climbing on by accident. With the server's
// "hold to rodeo" set to friendly-only (player.s.holdToRodeoState, HOLD_RODEO_FRIENDLY in
// _rodeo_shared.nut) a friendly titan needs +use, which bots never press; enemy titans stay automatic.
// A bot only switches that off for a ride it chose: a way out of a fight it's running from.
const BOT_HOLD_RODEO_AUTO		= 0		// HOLD_RODEO_DISABLED: any titan, no +use
const BOT_HOLD_RODEO_FRIENDLY	= 2		// HOLD_RODEO_FRIENDLY: friendly titans only with +use
const BOT_RIDE_DIST				= 450.0	// running away with a friendly titan this close: hitch a ride...
const BOT_RIDE_CHANCE			= 40	// ...this often per check...
const BOT_RIDE_DECISION			= 3.0	// ...checked this often
const BOT_RIDE_APPROACH_TIMEOUT	= 4.0
const BOT_RIDE_MIN_TIME			= 4.0	// stay on this long...
const BOT_RIDE_MAX_TIME			= 10.0	// ...up to this, then jump off and carry on
const BOT_EMBARK_DIST			= 250.0
const BOT_TITAN_CALL_RETRY		= 5.0
const BOT_TITAN_CALL_DELAY_MIN	= 5.0	// extra wait once the titan meter is full
const BOT_TITAN_CALL_DELAY_MAX	= 45.0
const BOT_TITAN_HOLD_FOR_ENEMY	= 30.0	// some bots keep the titan until they see someone, up to this long
const BOT_TITAN_CALL_SAFE_DIST	= 800.0	// don't stand still calling a titan with an enemy this close
const BOT_TITAN_BALANCE_CHECK	= 3.0	// titans out on each team counted this often while a titan is ready
const BOT_TITAN_LEAD_HOLD		= 2		// our team has this many more titans out than theirs: hold the call...
const BOT_TITAN_LEAD_HOLD_MAX	= 60.0	// ...for at most this long after the meter filled
const BOT_EJECT_HEALTH_FRAC		= 0.15
const BOT_WALL_CHECK_DIST		= 72.0

// Exploration
const BOT_EXPLORE_CANDIDATES	= 8
const BOT_EXPLORE_FAR_DIST		= 4000.0
const BOT_VISITED_MEMORY		= 6
const BOT_VISITED_RADIUS		= 800.0
const BOT_EXPLORE_MATE_DIST		= 1200.0	// roaming goals near a teammate's roaming goal score lower
const BOT_PREY_MIN_TIME			= 10.0	// how long a bot sticks with one prey
const BOT_PREY_MAX_TIME			= 25.0
const BOT_OBSTACLE_CHECK_DIST	= 64.0
const BOT_WALLRUN_MIN_DIST		= 300.0	// a wallrun just for speed only when the goal is at least this far
const BOT_WALL_COMBAT_DIST		= 260.0	// in a fight, take to a wall this close instead of strafing on the ground
const BOT_WALL_AIR_DIST			= 160.0	// in a fight, in the air, double jump onto walls this close

// Planned wallruns (see PlanWallrun / UpdateWallrun): along a wall that takes us towards where the
// route goes, up to a ledge, or across a gap; with a planned way off it.
const BOT_DEBUG_WALLRUN			= false	// log each planned wallrun and how it ended (+ IsOnGround on a wall, once)
const BOT_INPUT_FOLLOWS_AIM		= true	// turn the move input with the aim at the end of the tick (see BotThinkTick)
const BOT_WR_PLAN_INTERVAL		= 0.4	// look for a wall to run this often on foot...
const BOT_WR_PLAN_INTERVAL_UP	= 0.2	// ...and this often when the way on is up
const BOT_WR_MIN_SPEED			= 160.0	// only plan / jump onto the wall running at least this fast
const BOT_WR_LEAD				= 96.0	// probe for the wall this far ahead of us
const BOT_WR_SIDE_DIST			= 240.0	// ...and up to this far to the side
const BOT_WR_MAX_ANGLE_COS		= 0.42	// |wall normal . route| under this = wall within ~25 deg of the route
const BOT_WR_RUN_LENGTH			= 320.0	// room along the wall needed for a run
const BOT_WR_WALL_OFFSET		= 28.0	// where we run: this far off the face
const BOT_WR_MIN_WALL_HEIGHT	= 110.0	// the face must reach at least this high above our feet
const BOT_WR_MIN_PROGRESS		= 0.4	// the run must bring us this fraction of its length closer to the target
const BOT_WR_LAND_AHEAD			= 120.0	// past the end of the run there must be no void this far on
const BOT_WR_UP_MIN				= 48.0	// a target this much above us = run for the height
const BOT_WR_UP_MAX_DIST		= 900.0	// ...when it's within this (2D)
const BOT_WR_GAP_AHEAD			= 160.0	// a gap this far ahead = run along the wall across it
const BOT_WR_LOOKAHEAD_DIST		= 300.0	// steer for the waypoint after the next one when the next is this close
const BOT_WR_APPROACH_ANGLE		= 25.0	// come in at the wall at this angle (deg)...
const BOT_WR_APPROACH_ANGLE_FAR	= 40.0	// ...or steeper when still far off it...
const BOT_WR_FAR_LATERAL		= 140.0	// ...farther than this
const BOT_WR_JUMP_LEAD			= 0.42	// jump this many seconds (of speed into the wall) before reaching it...
const BOT_WR_JUMP_MIN			= 40.0	// ...but from no closer than this...
const BOT_WR_JUMP_MAX			= 120.0	// ...and no farther than this
const BOT_WR_APPROACH_TIME		= 1.8	// not at the wall by then: the plan is off
const BOT_WR_LATCH_TIME			= 0.8	// jumped and not on the wall by then: missed it
const BOT_WR_LEAN				= 0.3	// on the wall, lean into it this much so the run sticks
const BOT_WR_AIR_LEAN			= 0.7	// in the air, steer into the wall this much
const BOT_WR_MIN_RUN			= 0.35	// ride the wall at least this long (unless it ends)...
const BOT_WR_MAX_RUN			= 1.5	// ...and at most this long before kicking off
const BOT_WR_KICK_AHEAD			= 96.0	// kick off when the target is less than this far further along the wall
const BOT_WR_KICK_REACH			= 280.0	// a kick off must not land in the void this far out
const BOT_WR_KICK_AWAY			= 0.35	// a kick off always pushes at least this much away from the wall
const BOT_WR_HOP_DIST			= 300.0	// a facing wall this close = hop across to it
const BOT_WR_HOP_CHECK			= 0.2	// look for one this often
const BOT_WR_MAX_CHAIN			= 4		// wallruns chained in one go, at most
const BOT_WR_END_CHECK			= 72.0	// the wall ending this far ahead = kick off now
const BOT_WR_FAIL_COOLDOWN		= 3.0	// no new plan this long after one failed
const BOT_WR_BAD_WALL_TIME		= 20.0	// a wall we missed isn't tried again for this long...
const BOT_WR_BAD_WALL_RADIUS	= 150.0	// ...within this of where we aimed
const BOT_WR_STALE				= 0.35	// UpdateWallrun not run for this long (rodeo, fight): the plan is dropped
const BOT_WR_REACH_BONUS		= 300.0	// goal score for spots a wallrun gets us up to (scaled by wallLove, style)

// Gunfight movement (pilots keep moving while they shoot)
const BOT_COMBAT_STRAFE_MIN		= 1.0	// how long before switching the circling direction
const BOT_COMBAT_STRAFE_MAX		= 2.5
const BOT_COMBAT_RANGE_SLACK	= 150.0	// tolerance around the preferred range before closing in / backing off
const BOT_COMBAT_RADIAL_SPEED	= 0.7	// how hard to close in / back off, relative to circling
const BOT_COMBAT_WALL_LEAN		= 0.5	// lean into the wall while running along it, so the wallrun sticks
const BOT_COMBAT_HOP_MIN		= 1.2	// jumps during a fight
const BOT_COMBAT_HOP_MAX		= 2.8
const BOT_COMBAT_DOUBLE_JUMP_CHANCE	= 50
const BOT_AT_PREFERRED_DIST		= 1100.0	// range held against titans with the anti-titan weapon

// Ranged fights: the gunfight range comes from the weapon's damage falloff, so rifles fight
// from afar and shotguns/SMGs close in. At range, bots plant themselves and aim down sights.
const BOT_RANGE_FACTOR_MIN		= 0.7	// each bot holds this fraction of its weapon's full-damage range
const BOT_RANGE_FACTOR_MAX		= 1.0
const BOT_PILOT_RANGE_MIN		= 300.0
const BOT_PILOT_RANGE_MAX		= 1100.0
const BOT_BACKOFF_FRACTION		= 0.35		// only back off from an enemy closer than this fraction of the preferred range...
const BOT_BACKOFF_MIN_PREFERRED	= 1000.0	// ...and only with a long-range weapon (preferred range above this)
const BOT_PILOT_ENGAGE_MIN		= 900.0		// stop travelling and fight inside the weapon's falloff range, clamped to this
const BOT_PILOT_ENGAGE_MAX		= 2500.0
const BOT_HOLD_DIST				= 700.0		// farther than this, fight from a steady spot instead of hopping around
const BOT_HOLD_MOVE_SCALE		= 0.4		// slow side steps while holding (keeps the spread tight)
const BOT_UNDER_FIRE_MIN		= 1.0		// after taking a hit, dodge for this long before settling again
const BOT_UNDER_FIRE_MAX		= 2.0
const BOT_ADS_MIN_DIST			= 450.0		// hipfire inside this, aim down sights beyond it
const BOT_ADS_PROBE_CHECKS		= 15		// failed checks before giving up on an ADS button candidate

// Aim: an error offset that's rolled when a target is picked up and then settles while tracking,
// instead of fresh random shake every tick. Moving/airborne/hipfire keep it from settling as much.
const BOT_AIM_FLICK_ERROR		= 2.0		// initial error, in multiples of the skill's aim error
const BOT_AIM_SETTLE			= 0.72		// error kept per think while tracking
const BOT_AIM_NOISE				= 0.3		// fresh wobble per think, in multiples of the skill's aim error
const BOT_AIM_LEAD_TIME			= 0.1		// lead moving targets by one think (the view lags the target by that much)
const BOT_FIRE_HESITATE_CHANCE	= 15		// percent of burst gaps that run long (re-aiming, like a person would)

// In a titan, a bot is a sharper, more aggressive shooter: steadier aim, quicker reactions,
// longer bursts, and it always leads (titan weapons are mostly slow projectiles).
const BOT_TITAN_AIM_ERROR_SCALE	= 0.5
const BOT_TITAN_MIN_LEAD_SKILL	= 0.9
const BOT_TITAN_REACTION_SCALE	= 0.6
// ...but those three are for titan duels. Against pilots, grunts and spectres a titan bot aims and
// reacts no better than a pilot (titans were mowing pilots down, so whichever team got its titans
// out first kept the other one from ever coming back).
const BOT_TITAN_VS_SMALL_AIM_ERROR_SCALE	= 1.3
const BOT_TITAN_VS_SMALL_REACTION_SCALE	= 1.15
const BOT_TITAN_TRIGGER_ANGLE	= 8.0		// open fire within this many degrees at most
const BOT_TITAN_PAUSE_SCALE		= 0.6
// Titan ordnance (see UpdateTitanOrdnance). The button is held through BotSetInput, not pulsed:
// Multi-Target Missiles only build locks while it's held and fire on release, Slaved Warheads
// dry-fire (and waste their cooldown) without a full lock, the rest fire on a short tap.
const BOT_TITAN_ORDNANCE_CHECK	= 0.3		// how often a titan looks for an ordnance shot
const BOT_TITAN_ORDNANCE_TAP_HOLD	= 0.3	// a "tap" is held this long (a single think could miss the press)
const BOT_TITAN_ORDNANCE_AFTER	= 1.0		// after a release, wait this long before trying again
const BOT_TITAN_ORDNANCE_VERIFY	= 0.5		// ...and check this long after it that something went out
const BOT_TITAN_ORDNANCE_ANGLE	= 6.0		// dumb-fire ordnance only within this many degrees of the target
const BOT_TITAN_ORDNANCE_MIN_DIST	= 250.0
const BOT_TITAN_ORDNANCE_MAX_DIST	= 3000.0
const BOT_TITAN_ORDNANCE_LOCK_MIN	= 0.8	// Multi-Target Missiles: held at least this long...
const BOT_TITAN_ORDNANCE_LOCK_MAX	= 3.0	// ...at most this long...
const BOT_TITAN_ORDNANCE_LOCKS	= 3.0		// ...and let go early once this many locks are on
const BOT_TITAN_ORDNANCE_GROUP	= 2			// grunts/spectres only get ordnance when this many are bunched up...
const BOT_TITAN_ORDNANCE_PILOT_CHANCE	= 40	// ...pilots this percent of the time; titans always
const BOT_TITAN_ORDNANCE_PILOT_SKIP	= 3.0		// a lost pilot roll holds the ordnance back from pilots this long
const BOT_TITAN_ORDNANCE_LOCK_REPORT	= 6.0	// Slaved Warheads wanted this long without ever locking: logged once
// Projectile speeds (units/s) for leading shots; weapons not listed are treated as hitscan.
// From the weapon scripts (PROJECTILE_SPEED, missileSpeed, ...).
const BOT_LEAD_MAX_TIME			= 1.2		// never lead further ahead than this

// Map knowledge. Bots don't know where enemies are: only where they (or a teammate) last saw
// one, where a shot at them came from, and an occasional radar-like ping (in the game the
// minimap shows enemies that fire). With no leads they roam the map and fight what they meet.
const BOT_INTEL_MEMORY			= 20.0		// a sighting is a lead for this long
const BOT_INTEL_CLEAR_DIST		= 350.0		// reached a lead and nobody's there: it went cold
const BOT_INTEL_PING_MIN		= 15.0		// per team, a random enemy pilot's rough position leaks this often
const BOT_INTEL_PING_MAX		= 30.0
const BOT_INTEL_PING_SPREAD		= 700.0
const BOT_ALERT_TIME			= 4.0		// shot by someone out of sight: turn and go that way for this long

// Route variety
// Teammates spread out: prey already hunted by other bots looks farther away, bots near each
// other going for the same prey take different flanks, and bots travelling too close push apart.
const BOT_PREY_CLAIM_PENALTY	= 0.8		// each teammate already on a prey adds this much to its distance score
const BOT_PREY_NPC_WEIGHT		= 1.6		// grunts/spectres count as this much farther away than pilots when hunting
const BOT_PREY_RANDOMNESS		= 0.3		// +- this fraction of noise on prey scores, so picks vary
const BOT_CROWD_DIST			= 900.0		// a teammate this close heading for the same prey means take another route
const BOT_ALLY_SPACING_DIST		= 260.0		// travelling pilots closer than this to a teammate drift apart
const BOT_ALLY_SPACING_STRENGTH	= 0.8
const BOT_FLANK_MIN_DIST		= 900.0		// only bother flanking prey farther than this

// Tactics. Each bot has a route style (rolled per life, balanced across the team):
//   direct - goes straight at the prey; flank - wide side routes; high - elevated nodes,
//   rooftops and overwatch; indoor - covered routes (tunnels, interiors).
// Waypoints are picked from the AI node graph by scoring sampled nodes for the style.
const BOT_NAV_CELL				= 512.0		// grid cell size for the node cache
const BOT_TACTIC_SAMPLES		= 14		// sample spots per tactical point decision
const BOT_TACTIC_NODES_PER_CELL	= 3
const BOT_TACTIC_MAX_DETOUR		= 0.9		// extra travel allowed, as a fraction of the direct distance (+600)
const BOT_HIGH_ELEVATION_BONUS	= 2.5		// score per unit of height above the local ground (high style)
const BOT_HIGH_ELEVATION_MAX	= 500.0
const BOT_INDOOR_ROUTE_BONUS	= 700.0		// score for a covered node (indoor style)
const BOT_TEAMMATE_POINT_DIST	= 600.0		// a teammate's waypoint this close is someone else's route
// Overwatch: high-style bots that reach an elevated point hold it and watch the prey's area.
const BOT_VANTAGE_MIN_ELEVATION	= 120.0

// Going up through the building: a wall that can't be climbed from outside (or a climb that just
// failed) sends the bot inside to an upper floor / roof node near it, which the node graph reaches by
// the stairs; up there it watches the streets below for a while (see TryGoUpstairs).
const BOT_STAIRS_SEARCH_RADIUS	= 700.0	// upper-floor nodes this close (2D) to the wall
const BOT_STAIRS_MIN_RISE		= 100.0	// ...at least this far above us
const BOT_STAIRS_CHANCE			= 35	// percent, no climbable roof ahead but a wall: go in and up instead
const BOT_STAIRS_TIMEOUT		= 25.0	// not up there by then: forget it
const BOT_STAIRS_REACHED		= 96.0
const BOT_STAIRS_HOLD_MIN		= 4.0	// watching from up there this long
const BOT_STAIRS_HOLD_MAX		= 9.0
const BOT_STAIRS_COOLDOWN		= 40.0	// before the next trip upstairs

// Leaving an upper floor through a window / off a balcony instead of walking back down: pilots
// take no fall damage, so an opening towards a goal that's below us is the quick way out.
const BOT_WINDOW_CHECK_INTERVAL	= 1.0
const BOT_WINDOW_MIN_GOAL_DIST	= 700.0	// only for a goal this far away...
const BOT_WINDOW_MIN_GOAL_DROP	= 120.0	// ...and this far below us
const BOT_WINDOW_AHEAD			= 140.0	// opening checked this far ahead, at chest and head height
const BOT_WINDOW_MIN_DROP		= 120.0	// floor beyond it at least this far down...
const BOT_WINDOW_MAX_DROP		= 1500.0	// ...and at most this
const BOT_WINDOW_EXIT_TIME		= 1.5	// run and jump out that way for at most this long
const BOT_WINDOW_JUMP_LIFT		= 40.0	// the body fit is checked this high up (the jump over the sill)
const BOT_WINDOW_FAIL_COOLDOWN	= 12.0	// a jump out that didn't take us down: no window tries for this long
const BOT_VANTAGE_HOLD_MIN		= 4.0
const BOT_VANTAGE_HOLD_MAX		= 10.0
const BOT_VANTAGE_BREAK_DIST	= 600.0		// prey this close ends the hold
// Leaving brawls: non-direct bots in a crowded fight sometimes break off to come back from
// a new angle or from above, shooting on the way.
const BOT_BRAWL_CHECK_INTERVAL	= 2.0
const BOT_BRAWL_ENEMY_COUNT		= 2			// visible enemy pilots within BOT_BRAWL_RADIUS...
const BOT_BRAWL_ALLY_COUNT		= 1			// ...with this many teammates around = a brawl
const BOT_BRAWL_RADIUS			= 1500.0
const BOT_DUEL_DIST				= 900.0		// target closer than this: never break off to reposition
const BOT_BUNCHED_DIST			= 500.0		// teammates this close in a fight...
const BOT_BUNCHED_ALLY_COUNT	= 2			// ...this many of them = bunched up, spread out
const BOT_CHASE_SPREAD_MIN_DIST	= 500.0		// lost target closer than this: just go to where it was
const BOT_COMBAT_SPACING_DIST	= 400.0		// in a gunfight, drift away from teammates closer than this
const BOT_COMBAT_SPACING_STRENGTH	= 1.2
const BOT_REPOSITION_TIME		= 6.0
const BOT_REPOSITION_COOLDOWN	= 12.0
const BOT_REPOSITION_RADIUS_MIN	= 600.0
const BOT_REPOSITION_RADIUS_MAX	= 1400.0
// Rooftops: climb buildings along the route (wall + double jump + mantle), run across roofs
// straight at the goal (the node graph doesn't go up there), and leap gaps at roof edges.
const BOT_CLIMB_CHECK_INTERVAL	= 1.0
const BOT_CLIMB_WALL_DIST		= 260.0		// a wall this far ahead along the route...
const BOT_CLIMB_MIN_HEIGHT		= 90.0		// ...topped by a walkable roof this high...
const BOT_CLIMB_MAX_HEIGHT		= 170.0		// ...up to what a jump + double jump + mantle surely reaches,
const BOT_CLIMB_WALLRUN_MAX_HEIGHT	= 320.0	// ...or up to this with a wallrun up the face first
const BOT_CLIMB_WALLRUN_LENGTH	= 220.0		// room along the wall needed for the wallrun
const BOT_CLIMB_WALLRUN_TIME	= 0.5		// ride the wall at most this long before kicking off towards the roof...
const BOT_CLIMB_WALLRUN_MIN_TIME	= 0.15	// ...and at least this long (then kick once we stop rising)
const BOT_CLIMB_TIMEOUT			= 3.5
const BOT_CLIMB_RETRY			= 8.0
const BOT_CLIMB_PROGRESS_TIME	= 1.6		// this long after the first jump without gaining height = give up
const BOT_CLIMB_APPROACH_TIME	= 2.2		// not jumped by this long into a climb = give up
const BOT_CLIMB_RUNUP_MIN		= 60.0		// wallrun climb: closer to the wall than this, back off for a run-up first
const BOT_BAD_CLIMB_RADIUS		= 300.0		// failed climbs are remembered (team-wide) around the wall spot
// Ledges: jump, double jump and mantle onto anything in reach that's in the way up, the way a
// player does it without thinking: when stuck against it, when the route or the target we're
// chasing is up there, and off a wall we're running along (see TryStartLedgeMantle).
const BOT_LEDGE_MIN_HEIGHT		= 30.0		// below this it's a step: walked or hopped
const BOT_LEDGE_WALL_DIST		= 110.0		// the ledge's face this close ahead
const BOT_LEDGE_UP_DIST			= 40.0		// route / target at least this far above us: worth going up
const BOT_LEDGE_GOAL_DIST		= 1200.0	// a goal up high this close (2D) counts too (reposition / flank points)
const BOT_LEDGE_CHECK_INTERVAL	= 0.3
const BOT_LEDGE_TIMEOUT			= 1.6
const BOT_LEDGE_WALLRUN_REACH	= 200.0		// running along a wall: a top up to this far above us
const BOT_LEDGE_WALLRUN_CHECK	= 0.2
const BOT_CLIMB_CHANCE_OTHERS	= 10		// percent of climb chances non-high bots take too...
const BOT_CLIMB_CHANCE_ROOF_LOVE	= 40	// ...plus this times the bot's roofLove (see WantsClimb)
const BOT_ROOF_GOAL_BONUS		= 600.0		// roaming: an elevated goal scores this much more (times roofLove)
const BOT_ROOF_ROUTE_SCALE		= 0.4		// non-high bots weigh route point height at this fraction (times roofLove)
const BOT_ROOF_EXTRA_CANDIDATES	= 4			// roof lovers look at this many more roaming goals
const BOT_ROOF_HOLD_CHANCE		= 35		// percent (times roofLove) to stop a while on a high roaming goal...
const BOT_ROOF_HOLD_MIN			= 2.0		// ...for this long
const BOT_ROOF_HOLD_MAX			= 5.0
const BOT_OFFGRAPH_HEIGHT		= 150.0		// path's next node this far below us = we're up on something
const BOT_OFFGRAPH_BLOCK_TIME	= 6.0

// The void: maps with open edges (War Games' simulation, ledges over the sky) kill whoever falls
// past them with a trigger. Before a pilot on the ground moves somewhere, the floor just ahead is
// probed: nothing below, or a floor deeper than the lowest node of the graph, is a pit (see IsVoidAt).
const BOT_VOID_AHEAD			= 120.0		// floor probed this far ahead of the move
const BOT_VOID_AHEAD_TITAN		= 220.0		// ...for a titan (wider, and a dash goes far)
const BOT_VOID_PROBE			= 2500.0	// ...down this far
const BOT_VOID_MARGIN			= 128.0		// floor this far below the lowest graph node: a pit
const BOT_GAP_CHECK_AHEAD		= 72.0
const BOT_GAP_DROP				= 100.0		// no floor this far down just ahead = an edge: jump it
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
const BOT_PILOT_FLEE_HEALTH		= 0.35	// badly hurt (longer retreats, see UpdateThreat)

// Pilot brain, in layers: Perceive (what is going on) -> Decide (which action) -> ExecuteAction
// (what that action changes in the plan for this tick). Each pilot has a temperament, rolled per
// life and balanced across the team, that sets the rules of the Decide step (see ApplyTemperament
// for the per-temperament numbers) and its route style:
//   aggressive - attacks whatever is near, keeps attacking when hurt, chases what runs away
//   cautious   - looks for cover when an enemy is near, falls back when hurt, repositions when blind
//   flanker    - doesn't attack right away: finds another route, arrives from the side, then attacks
const BOT_ACTION_MIN_TIME		= 1.0	// an action is kept at least this long (except retreating)
const BOT_FLANKER_MIN_DIST		= 600.0	// flankers go around enemies farther than this (and not under fire)
const BOT_RELOAD_FRAC			= 0.2	// clip fraction under which a bot in a fight reloads first
const BOT_RELOAD_MIN_ENEMY_DIST	= 350.0	// ...unless the enemy is this close
const BOT_CHASE_LEAD_TIME		= 1.5	// aggressive bots chase where a fleeing enemy is heading, up to this far ahead (seconds of its velocity)

// Cover. Cover spots are graph nodes that are hidden from the threat, with a peek spot a step to
// the side that can see it. A bot goes there, hides (reloading, ducked), peeks to shoot, hides again.
const BOT_COVER_SAMPLES			= 14
const BOT_COVER_MIN_DIST		= 120.0
const BOT_COVER_MAX_DIST		= 600.0
const BOT_COVER_PEEK_OFFSET		= 64.0
const BOT_COVER_REACHED			= 48.0
const BOT_COVER_HIDE_MIN		= 1.0
const BOT_COVER_HIDE_MAX		= 2.2
const BOT_COVER_PEEK_MIN		= 1.0
const BOT_COVER_PEEK_MAX		= 1.8
const BOT_COVER_MAX_TIME		= 14.0	// a cover episode ends after this long
const BOT_COVER_COOLDOWN		= 4.0	// before looking for cover again after an episode
const BOT_COVER_FAIL_COOLDOWN	= 1.5	// before looking again after finding nothing
const BOT_COVER_MATE_DIST		= 250.0	// a spot this close to a teammate's cover scores lower
const BOT_COVER_FAIL_REPOSITION	= 50	// percent: no cover found, change the angle instead

// Titan crossfire. When friendly and enemy titans are fighting near a pilot on foot, the pilot
// gets out of the line of fire: it takes cover hidden from every titan involved (and stays there
// until the fight moves away), instead of wandering through it. Pilots with an anti-titan weapon
// (and not the cautious kind) peek out to shoot at the titans.
const BOT_TITAN_FIGHT_RADIUS	= 1800		// titans within this of the pilot are looked at...
const BOT_TITAN_FIGHT_PAIR_DIST	= 1800.0	// ...and it's a fight if a friendly and an enemy one are this close
const BOT_TITAN_SCAN_INTERVAL	= 0.5
const BOT_TITAN_COVER_MIN_DIST	= 600.0		// cover spots at least this far from every titan involved
const BOT_TITAN_COVER_MAX_DIST	= 900.0		// ...and up to this far from the pilot
const BOT_TITAN_COVER_MAX_TIME	= 12.0
const BOT_TITAN_COVER_PILOT_DIST	= 500.0	// an enemy pilot this close is fought, not hidden from
const BOT_TITAN_COVER_EYE_HEIGHT	= 150.0	// titans see over what hides a pilot from another pilot
const BOT_TITAN_PEEK_MIN		= 2.5		// out on the peek spot this long (time to lock on / charge)...
const BOT_TITAN_PEEK_MAX		= 4.0
const BOT_TITAN_PEEK_HARD_MAX	= 6.5		// ...never longer than this per peek, even mid-lock
const BOT_TITAN_HIDE_MIN		= 1.5		// back behind cover this long between peeks
const BOT_TITAN_HIDE_MAX		= 3.0
const BOT_TITAN_PEEK_MIN_HEALTH	= 0.35		// below this, just hide

// Getting into our own titan once it has been called and is on the map: the first thing a pilot
// does (the titan is the better place to fight from), from anywhere within this distance.
const BOT_EMBARK_MAX_DIST		= 4000.0

// Out-of-world watchdog: how far outside the area the node graph covers a bot may be before it
// is put back (see UpdateBoundsWatchdog).
const BOT_BOUNDS_CHECK_INTERVAL	= 2.0
const BOT_BOUNDS_MARGIN_XY		= 2500.0
const BOT_BOUNDS_BELOW			= 1000.0
const BOT_BOUNDS_ABOVE			= 3000.0
const BOT_FLEE_MIN_TRAVEL		= 300.0
const BOT_FLEE_MAX_TRAVEL		= 3000.0
const BOT_FLEE_CANDIDATES		= 16
const BOT_FLEE_INDOOR_BONUS		= 900.0	// flee spots under a roof...
const BOT_FLEE_HIDDEN_BONUS		= 700.0	// ...and out of the threat's line of sight score higher
const BOT_ROOF_CHECK_HEIGHT		= 600.0
const BOT_NPC_GRENADE_GROUP		= 2		// grunts/spectres always get a grenade when this many are bunched up...
const BOT_ORDNANCE_NPC_CHANCE	= 45	// ...a lone one this percent of the checks...
const BOT_ORDNANCE_SPECTRE_EMP_BONUS	= 35	// ...more with an arc grenade against a spectre
const BOT_NPC_GROUP_RADIUS		= 350

// Abilities and ordnance
const BOT_TACTICAL_RETRY_MIN	= 4.0	// pressing an uncharged ability does nothing; just retry later
const BOT_TACTICAL_RETRY_MAX	= 8.0
const BOT_ORDNANCE_COOLDOWN_MIN	= 3.0	// between throws (the grenade's own recharge still applies)
const BOT_ORDNANCE_COOLDOWN_MAX	= 6.0
const BOT_ORDNANCE_NOT_READY	= 1.0	// no charge left: check again this soon
const BOT_ORDNANCE_RETRY_MIN	= 0.6	// nothing worth a grenade this check: look again this soon
const BOT_ORDNANCE_RETRY_MAX	= 1.2
const BOT_ORDNANCE_BUSY_RETRY	= 0.5	// mid weapon switch / mid lock-on: look again this soon
const BOT_ORDNANCE_DROP_DIST	= 900.0	// running from someone this close: drop a satchel / mine behind us...
const BOT_ORDNANCE_DROP_PITCH	= 80.0	// ...tossed down at our feet (pitch, down) without turning around
const BOT_ORDNANCE_MIN_DIST		= 250.0	// don't frag yourself
const BOT_ORDNANCE_MAX_DIST		= 1400.0
const BOT_ORDNANCE_PILOT_CHANCE	= 55	// percent per check against a pilot in sight (always when losing)
const BOT_ORDNANCE_COVER_CHANCE	= 70	// percent per check against a pilot that just ducked behind cover...
const BOT_ORDNANCE_COVER_MIN	= 0.4	// ...gone out of sight this long ago...
const BOT_ORDNANCE_COVER_MAX	= 3.0	// ...but not longer
const BOT_ORDNANCE_LOB_TIME		= 0.7	// aim is held on the arc this long (the toss leaves the hand on a later anim event)
const BOT_SATCHEL_TRIGGER_DIST	= 220.0	// an enemy this close to one of our satchels sets them off...
const BOT_SATCHEL_TITAN_DIST	= 320.0	// ...a titan (bigger hull) from a bit farther...
const BOT_SATCHEL_SAFE_DIST		= 320.0	// ...unless we're this close to that satchel ourselves
const BOT_SATCHEL_SCAN_RADIUS	= 400	// int, for GetNPCArrayEx
const BOT_SATCHEL_REACTION_MIN	= 0.15
const BOT_SATCHEL_REACTION_MAX	= 0.45

// Epilogue evac
const BOT_EVAC_SHIP_NEAR_NODE	= 1000.0	// the dropship counts as landed once its ramp is this close to the evac point
const BOT_EVAC_BOARD_DIST		= 500.0		// from here, run and jump straight at the ramp
const BOT_EVAC_TITAN_EXIT_DIST	= 1500.0	// titans hop out this close to the evac point (they can't board)
// Boarding needs the head (HeadFocus, ~60 above the feet) within 120 of the ramp trigger. A ramp
// higher than a jump + double jump reaches from the ground is boarded from a launch point instead:
// a roof or ledge next to the ship, climbed onto first, jumped from (see UpdateEvacLaunch).
const BOT_EVAC_HEAD_HEIGHT		= 60.0		// head above the feet
const BOT_EVAC_HEAD_MARGIN		= 60.0		// keep jumping while the head is no more than this above the ramp
const BOT_EVAC_GROUND_REACH		= 260.0		// a ramp up to this high above the ground under it is boarded from the ground...
const BOT_EVAC_GROUND_PROBE		= 2000.0	// (how far down the ground is looked for)
const BOT_EVAC_GROUND_TRIES		= 3			// ...and after this many missed jumps from the ground, a launch point anyway
const BOT_EVAC_GROUND_JUMP_DIST	= 250.0		// from the ground, jump this close to the ramp...
const BOT_EVAC_RUNUP_MIN_DIST	= 140.0		// ...but standing still closer than this, back off for a run-up first
const BOT_EVAC_RUNUP_SPEED		= 150.0
const BOT_EVAC_RUNUP_TIME		= 0.8
const BOT_EVAC_RAMP_MOVED		= 150.0		// the ramp moved this far (ship still settling): judge it again
const BOT_EVAC_LAUNCH_MIN_GAP	= 60.0		// launch points: this far from the ramp (flat)...
const BOT_EVAC_LAUNCH_MAX_GAP	= 380.0		// ...up to this far...
const BOT_EVAC_LAUNCH_MAX_RISE	= 150.0		// ...with the ramp at most this far above the head...
const BOT_EVAC_LAUNCH_MAX_DROP	= 250.0		// ...or at most this far below it
const BOT_EVAC_LAUNCH_SIDE_BONUS	= 200.0	// spots on the ship's open (ramp) side score higher
const BOT_EVAC_LAUNCH_CHECKS	= 6			// best spots checked for a clear jump line, per search
const BOT_EVAC_ROOF_DIRS		= 12		// roof probes around the ramp
const BOT_EVAC_LAUNCH_JUMP_DIST	= 300.0		// from a launch point, jump this close to the ramp (or at its edge)
const BOT_EVAC_LAUNCH_REACHED	= 64.0
const BOT_EVAC_LAUNCH_REACH_TIME	= 20.0	// a launch point not reached within this (once closer than the next) is dropped
const BOT_EVAC_LAUNCH_TIMER_DIST	= 1000.0
const BOT_EVAC_LAUNCH_TRIES		= 3			// ...as is one jumped from this many times without boarding
const BOT_EVAC_LAUNCH_LOST_DROP	= 96.0		// back on the ground this far below the launch point: climb up again
const BOT_EVAC_LAUNCH_SEARCH_RETRY	= 2.0
const BOT_EVAC_BAD_LAUNCH_RADIUS	= 120.0	// dropped launch points are avoided (team-wide) this close
const BOT_EVAC_AIM_CONE			= 55.0		// running for the ship: only turn to shoot what's within this many degrees of the run (keeps the sprint)...
const BOT_EVAC_SHOOT_DIST		= 1500.0	// ...and this close
const BOT_EVAC_GRENADE_DODGE_MIN	= 0.5	// a grenade on the evac run: hop aside this long, not the usual 1-1.5 s
const BOT_EVAC_GRENADE_DODGE_MAX	= 0.8
const BOT_TACTICAL_LOW_HEALTH	= 0.6

// AI node graph hulls. The titan hull index still has to be confirmed against the .ain link data;
// until then titans path on the human graph and rely on stuck detection.
const BOT_HULL_PILOT			= 0
const BOT_HULL_TITAN			= 0
// NPC traverse links a pilot path may still use (see NavFindPathPilot): climbing at most this
// high (jump + double jump + mantle) and crossing at most this far. Going down is always fine.
const BOT_PILOT_MAX_RISE		= 120.0
const BOT_PILOT_MAX_GAP			= 450.0

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
const BOT_MELEE_HIT_DELAY		= 0.15	// into the swing before the hit is checked (see BotMeleeFollowUp)
const BOT_MELEE_SWING_TIME		= 0.6	// window in which a swing can still connect
const BOT_MELEE_MAX_MISSES		= 2		// swings in a row that didn't connect before giving up on melee...
const BOT_MELEE_BLOCK_MIN		= 5.0	// ...for this long, fighting with the gun instead
const BOT_MELEE_BLOCK_MAX		= 8.0
const BOT_MELEE_TITAN_CLEARANCE	= 220.0	// on foot: no kick with an enemy titan this close (the kick cone would land on it)
const BOT_RUSH_TITAN_CLEARANCE	= 400.0	// ...and no rushing in at a pilot when we or it are this close to one
const BOT_TITAN_DASH_COOLDOWN_MIN	= 3.0
const BOT_TITAN_DASH_COOLDOWN_MAX	= 6.0

// Rodeo interception: an enemy pilot closing in on a titan bot (or already right next to it)
// becomes its target over anything else, the titan turns on it faster than usual and punches it
// out of the air before it reaches the hatch; one coming from behind gets dashed away from.
const BOT_SWAT_DIST				= 500.0	// enemy pilots this close are checked...
const BOT_SWAT_CLOSE_DIST		= 260.0	// ...always a threat this close...
const BOT_SWAT_APPROACH_SPEED	= 150.0	// ...otherwise only when closing in at least this fast
const BOT_SWAT_TURN_BONUS		= 1.8	// faster turning while swatting
const BOT_SWAT_MELEE_RANGE		= 300.0
const BOT_SWAT_MELEE_ANGLE		= 40.0
const BOT_SWAT_COOLDOWN			= 0.8
const BOT_SWAT_DODGE_ANGLE		= 110.0	// pilot this far off our facing and close: dash instead
const BOT_SWAT_DODGE_DIST		= 350.0

// Titan fights: titans close in and brawl instead of trading shots from max range.
// Titan health doesn't regenerate, so they never retreat just for being hurt (they eject instead).
const BOT_TITAN_RANGE_MIN		= 350.0	// each bot's preferred titan-fight range is rolled in here (weapons without a band)
const BOT_TITAN_RANGE_MAX		= 750.0
const BOT_TITAN_ENGAGE_MARGIN	= 500.0	// a titan starts fighting this far beyond its preferred range

// Vortex shield (see UpdateTitanVortex): put up against an enemy titan shooting at us, held to
// catch a volley, let go to throw it back.
const BOT_VORTEX_MAX_DIST		= 2500.0
const BOT_VORTEX_PROJECTILE_RADIUS	= 900	// int, for GetProjectileArrayEx: enemy rockets / grenades this close
const BOT_VORTEX_MAX_START_CHARGE	= 0.4	// only put it up with at least this much of its time left (charge used)
const BOT_VORTEX_RELEASE_CHARGE	= 0.9	// let go before the game forces it at 1.0
const BOT_VORTEX_HOLD_MIN		= 1.0
const BOT_VORTEX_HOLD_MAX		= 2.2
const BOT_VORTEX_MIN_HOLD		= 0.5	// target gone: still hold this long before letting go
const BOT_VORTEX_COOLDOWN_MIN	= 1.5	// after a throw, before putting it up again
const BOT_VORTEX_COOLDOWN_MAX	= 3.0
const BOT_TITAN_PRESS_HEALTH	= 0.6	// target this hurt (or weaker than us): go in for the punch
const BOT_TITAN_TARGET_BIAS		= 0.5	// in a titan, enemy titans are picked over anything at up to 2x the distance
const BOT_TITAN_SMALL_TARGET_BIAS	= 1.6	// ...and grunts/spectres only when nothing better is in sight
const BOT_TITAN_SPACING_DIST	= 350.0	// friendly titans closer than this push apart instead of piling up
const BOT_TITAN_DASH_IN_DIST	= 400.0	// dash forward when this much farther out than the preferred range
const BOT_TITAN_OUTNUMBER_MARGIN	= 2		// titans only back off when facing this many more enemy titans than friendly ones
const BOT_TITAN_OUTNUMBER_RADIUS	= 1500
const BOT_TITAN_ORBIT_MIN		= 2.5	// a titan circles its target one way for this long...
const BOT_TITAN_ORBIT_MAX		= 5.0	// ...before (maybe) switching
const BOT_TITAN_COMBAT_SPACING_DIST	= 650.0	// in a fight, friendly titans closer than this push apart
const BOT_TITAN_BUNCHED_DIST	= 700.0	// a friendly titan this close in a fight = bunched up...
const BOT_TITAN_REPOSITION_CHANCE	= 60	// ...and this often one of them breaks off to a new angle
const BOT_TITAN_ELEVATED_TARGET_DIST	= 900.0	// back off this far from a pilot up on a roof to get an angle
const BOT_MELEE_MAX_HEIGHT_DIFF	= 120.0	// never charge in for melee at something this far above or below
// Titans stuck on stairs, steps and narrow passages (see TitanStuckResponse).
const BOT_TITAN_STUCK_RESET_TIME	= 6.0	// stuck again within this escalates (step out, skip / reposition, detour)
const BOT_TITAN_UNSTICK_TIME	= 1.0		// step out (with a dash) this long
const BOT_TITAN_STUCK_IGNORE_DIST	= 300.0	// in a fight, blocked this close to the target = body to body with it, not stuck
const BOT_TITAN_STEP_HEIGHT		= 20.0		// hull probes start this high, so they pass over steps
const BOT_TITAN_PROBE_DIST		= 160.0		// how far each probe looks for room to step out
const BOT_TITAN_PROBE_CLEAR		= 0.85		// fraction of a probe that must be free
const BOT_TITAN_PROBE_HULL_SCALE	= 0.85	// probes use a slightly narrower hull than the titan's
const BOT_TITAN_BACKOFF_TIME	= 4.0		// stuck in a fight: hold range (no charging in) this long
const BOT_TITAN_BAD_SPOT_TIME	= 60.0		// places titans got stuck for good are avoided this long...
const BOT_TITAN_BAD_SPOT_RADIUS	= 250.0		// ...within this radius
const BOT_TITAN_BAD_SPOT_MAX	= 24
const BOT_TITAN_DETOUR_TIME		= 10.0		// after giving up on a route: head for a detour point this long
const BOT_TITAN_NODE_REACH_Z	= 96.0		// a waypoint only counts as reached within this height (switchback stairs)
const BOT_TITAN_MAX_NODE_ELEVATION	= 200.0	// tactical points this far above the local ground are out of a titan's reach
const BOT_TITAN_MAX_RISE		= 24.0		// NPC traverse links a titan path may use (see NavFindPathPilot): barely any climb...
const BOT_TITAN_MAX_GAP			= 200.0		// ...and short gaps only
const BOT_TITAN_HULL_PROBE		= 4			// .ain hull tried first for titan paths (-1 = off); falls back to BOT_HULL_TITAN

// Titan awareness: nuclear ejections, our particle wall and our electric smoke.
// The smoke and wall numbers are estimates (their sizes live in the weapon files, not the scripts).
const BOT_NUKE_DANGER_RADIUS	= 1100.0	// a nuclear ejection hits titans out to ~750; room to run on top of that
const BOT_NUKE_THREAT_TIME		= 6.0		// eject (~2s) + fuse (1.3s) + blast (up to 1.7s), with a margin
const BOT_SHIELD_WALL_SCAN_INTERVAL	= 0.5
const BOT_SHIELD_WALL_COVER_DIST	= 160.0	// stand this far behind our particle wall, seen from the target...
const BOT_SHIELD_WALL_STRAFE	= 110.0		// ...side-stepping at most this far along it
const BOT_SHIELD_WALL_MAX_DIST	= 900.0		// a wall farther away than this isn't worth walking back to
const BOT_SMOKE_DURATION		= 6.0		// how long the electric smoke keeps cooking a rider
const BOT_SMOKE_STAY_RADIUS		= 120.0		// with a rider on, stay this close to where the smoke went off

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

	file.brains <- {}			// bot -> brain, for team coordination
	file.nav <- null			// node cache for tactical points, built on first use (see GetNavCache)
	file.badClimbSpots <- []	// walls bots failed to climb this map
	file.wrGroundLogged <- false	// BOT_DEBUG_WALLRUN: IsOnGround on a wall reported once
	file.hasPilotNav <- "NavFindPathPilot" in getroottable()
	if ( !file.hasPilotNav )
		printt( "BotAI: NavFindPathPilot not available (older DLL), pilot paths may include NPC-only climbs" )
	file.intel <- {}			// team -> { enemy -> { pos, time } }, see ReportIntel
	file.nextIntelPing <- {}	// team -> time of the next radar-like ping
	file.weaponRanges <- {}		// weapon class -> { near, far }
	file.clipSizes <- {}		// weapon class -> magazine size
	file.noAds <- {}			// weapon class -> true if aiming down sights breaks it (see WeaponBlocksAds)
	file.semiAuto <- {}			// weapon class -> true if it needs a fresh trigger press per shot
	file.projectileSpeeds <- {
		mp_titanweapon_40mm = 8000.0
		mp_titanweapon_rocket_launcher = 2300.0
		mp_titanweapon_dumbfire_rockets = 2500.0
		mp_titanweapon_shotgun = 2500.0
		mp_titanweapon_sniper = 10000.0
		mp_titanweapon_charge_cannon = 10000.0
	}
	// ADS button bit: not confirmed for this engine, so it's found in game (see UpdateAds).
	// Source's IN_ZOOM first, then IN_ATTACK2. null = still probing, 0 = none worked.
	file.adsCandidates <- [ 0x80000, 0x800 ]
	file.adsProbeIndex <- 0
	file.adsProbeFails <- 0
	file.adsBit <- null
	file.nukes <- []			// nuclear ejections going off soon: { pos, team, until }, see BotAI_OnTitanEject
	file.titanBadSpots <- []	// places titans got stuck for good: { pos, until }, see MarkTitanBadSpot
	// Titan-sized .ain hull for titan paths, dropped for the map if it hardly ever finds one (see BuildTitanPath).
	file.titanHull <- BOT_TITAN_HULL_PROBE >= 0 ? BOT_TITAN_HULL_PROBE : null
	file.titanHullTries <- 0
	file.titanHullHits <- 0
	file.evacBadLaunches <- []	// evac launch points that didn't work out (team-wide), see UpdateEvacLaunch
	// Pilot ordnance, per class: throw range, how much the arc is lifted per unit of distance (and at
	// most), and whether it's worth dropping behind us while running away. Satchels and mines are
	// tossed slowly, so they only reach short distances and need a much higher arc.
	file.ordnanceProfiles <- {
		mp_weapon_frag_grenade = { minDist = 250.0, maxDist = 1400.0, lift = 0.008, liftMax = 12.0, drop = false }
		mp_weapon_grenade_emp = { minDist = 200.0, maxDist = 1500.0, lift = 0.008, liftMax = 12.0, drop = false }
		mp_weapon_satchel = { minDist = 150.0, maxDist = 500.0, lift = 0.04, liftMax = 30.0, drop = true }
		mp_weapon_proximity_mine = { minDist = 100.0, maxDist = 450.0, lift = 0.04, liftMax = 30.0, drop = true }
	}
	file.ordnanceMissReported <- {}	// titan ordnance class -> true once a held press was seen not firing
	// Titan main weapons: the range band each one does its damage in. A titan fights from inside its
	// own weapon's band (rolled per bot within it, see UpdateTitanPreferredDist): the shotgun and the
	// arc cannon only hurt up close, the railgun / charge cannon want distance. Weapons not listed
	// use their weapon file's damage falloff distances.
	file.titanWeaponRanges <- {
		mp_titanweapon_shotgun = { min = 200.0, max = 400.0 }
		mp_titanweapon_arc_cannon = { min = 300.0, max = 550.0 }
		mp_titanweapon_triple_threat = { min = 400.0, max = 700.0 }
		mp_titanweapon_rocket_launcher = { min = 500.0, max = 850.0 }
		mp_titanweapon_xo16 = { min = 550.0, max = 1000.0 }
		mp_titanweapon_minigun = { min = 550.0, max = 1000.0 }
		mp_titanweapon_40mm = { min = 650.0, max = 1100.0 }
		mp_titanweapon_sniper = { min = 1200.0, max = 2000.0 }
		mp_titanweapon_charge_cannon = { min = 1100.0, max = 1800.0 }
	}

	if ( !BotManagerEnabledForMode() )
		return

	AddCallback_OnPlayerRespawned( BotAI_OnPlayerRespawned )
	AddDamageCallback( "player", BotAI_OnPlayerDamaged )
	AddCallback_OnTitanEject( BotAI_OnTitanEject )
	AddCallback_OnRodeoStarted( BotAI_OnRodeoStarted )
	if ( BOT_DEBUG_SPAWN_DEATHS )
		AddCallback_OnPlayerKilled( BotAI_DebugSpawnDeath )
}

// A bot just got on an enemy titan. The game holsters the weapon and deploys it again once the
// climb is done (PlayerBeginsRodeo); asking for the primary now means that's what comes out,
// instead of the anti-titan weapon that's useless up there.
function BotAI_OnRodeoStarted( player )
{
	if ( !IsValid( player ) || !( player in file.brains ) )
		return
	local brain = file.brains[ player ]
	brain.rideSince = Time()
	brain.rideSwitchTries = 0
	brain.rideSwitchForced = false
	brain.rideGaveUp = false
	local active = player.GetActiveWeapon()
	if ( IsValid( active ) && IsAntiTitanWeapon( active ) )
		BotRequestRideWeapon( player, brain, GetBotRodeoWeapon( player ) )
}

// A titan is ejecting: if it's a nuclear ejection, remember where for a few seconds so titan
// bots can get clear of the blast (see FindNukeThreat).
function BotAI_OnTitanEject( player, soul )
{
	if ( !IsValid( soul ) )
		return
	local titan = soul.GetTitan()
	if ( !IsValid( titan ) )
		return
	local payload = IsValid( player ) ? GetNuclearPayload( player ) : NPC_GetNuclearPayload( titan )
	if ( payload <= 0 )
		return
	file.nukes.append( { pos = titan.GetOrigin(), team = titan.GetTeam(), until = Time() + BOT_NUKE_THREAT_TIME } )
}

// A bot got hit: its team learns where the shooter is, and the bot turns and heads that way
// even if the shooter is out of sight.
function BotAI_OnPlayerDamaged( player, damageInfo )
{
	if ( !IsValid( player ) || !( player in file.brains ) )
		return
	local attacker = damageInfo.GetAttacker()
	if ( !IsValid( attacker ) || attacker == player || attacker.GetTeam() == player.GetTeam() )
		return
	if ( !attacker.IsPlayer() && !attacker.IsNPC() )
		return

	ReportIntel( player.GetTeam(), attacker, attacker.GetOrigin() )
	local brain = file.brains[ player ]
	brain.alertPos = attacker.GetOrigin()
	brain.alertUntil = Time() + BOT_ALERT_TIME
}

function BotAI_OnPlayerRespawned( player )
{
	// Spawn-death diagnostic: where this life started, and a fresh per-tick log for it.
	if ( BOT_DEBUG_SPAWN_DEATHS )
	{
		player.s.dbgSpawnOrigin <- player.GetOrigin()
		player.s.dbgSpawnTrace <- []
	}

	if ( IsManagedBot( player ) )
		thread BotThink( player )
}

// Spawn-death diagnostic helpers: short, safe descriptions for the log lines below.
function BotAI_DbgF( value )
{
	if ( value == null )
		return "null"
	return format( "%.2f", value.tofloat() )
}

function BotAI_DbgVec( vec )
{
	if ( vec == null )
		return "null"
	return format( "(%.0f %.0f %.0f)", vec.x, vec.y, vec.z )
}

function BotAI_DbgEnt( ent )
{
	if ( ent == null )
		return "null"
	if ( !IsValid( ent ) )
		return "invalid"
	local text = ent.GetClassname() + " '" + ent.GetName() + "' #" + ent.GetEntIndex()
	if ( ent.IsPlayer() )
		text += " (" + ent.GetPlayerName() + ")"
	return text
}

// One line per think for the first BOT_SPAWN_TRACE_TIME seconds of a life (see BotAI_DebugSpawnDeath).
function BotAI_DebugSpawnTrace( bot, brain )
{
	if ( !( "dbgSpawnTrace" in bot.s ) || !( "respawnTime" in bot.s ) )
		return
	local alive = Time() - bot.s.respawnTime
	if ( alive > BOT_SPAWN_TRACE_TIME )
		return

	local line = "t=" + BotAI_DbgF( alive )
	line += " org=" + BotAI_DbgVec( bot.GetOrigin() )
	line += " vel=" + BotAI_DbgVec( bot.GetVelocity() )
	line += " ground=" + ( bot.IsOnGround() ? "1" : "0" )
	line += " hp=" + bot.GetHealth()
	line += " parent=" + BotAI_DbgEnt( bot.GetParent() )
	line += " anim=" + ( bot.Anim_IsActive() ? "1" : "0" )
	local input = brain.dbgInput
	if ( input != null )
		line += " in: fwd=" + BotAI_DbgF( input.forward ) + " side=" + BotAI_DbgF( input.side ) + " pitch=" + BotAI_DbgF( input.pitch ) + " yaw=" + BotAI_DbgF( input.yaw ) + " buttons=" + input.buttons + " pressed=" + input.pressed
	else
		line += " in: none"
	bot.s.dbgSpawnTrace.append( line )
}

// Logs any player who dies within BOT_SPAWN_DEATH_WINDOW of spawning: what killed them, where, and
// (for our bots) what they did each think since spawning. Quiet otherwise.
function BotAI_DebugSpawnDeath( player, damageInfo )
{
	try
	{
		if ( !IsValid( player ) )
			return
		local now = Time()
		local sincePrevDeath = ( "dbgLastDeathTime" in player.s ) ? now - player.s.dbgLastDeathTime : null
		player.s.dbgLastDeathTime <- now

		if ( !( "respawnTime" in player.s ) )
			return
		local alive = now - player.s.respawnTime
		if ( alive > BOT_SPAWN_DEATH_WINDOW )
			return

		local spawnOrigin = ( "dbgSpawnOrigin" in player.s ) ? player.s.dbgSpawnOrigin : null
		printt( "BotAI-DBG: SPAWN DEATH", player.GetPlayerName(), "bot =", player.IsBot(), "alive =", BotAI_DbgF( alive ),
			"sincePrevDeath =", BotAI_DbgF( sincePrevDeath ), "origin =", BotAI_DbgVec( player.GetOrigin() ),
			"spawnOrigin =", BotAI_DbgVec( spawnOrigin ), "vel =", BotAI_DbgVec( player.GetVelocity() ),
			"onGround =", player.IsOnGround(), "titan =", player.IsTitan() )
		printt( "BotAI-DBG:   dmg =", damageInfo.GetDamage(), "dmgType =", damageInfo.GetDamageType(),
			"custom =", damageInfo.GetCustomDamageType(), "sourceId =", damageInfo.GetDamageSourceIdentifier(),
			"forceKill =", damageInfo.GetForceKill(), "pos =", BotAI_DbgVec( damageInfo.GetDamagePosition() ) )
		printt( "BotAI-DBG:   attacker =", BotAI_DbgEnt( damageInfo.GetAttacker() ), "| inflictor =", BotAI_DbgEnt( damageInfo.GetInflictor() ),
			"| weapon =", BotAI_DbgEnt( damageInfo.GetWeapon() ), "| parent =", BotAI_DbgEnt( player.GetParent() ) )

		if ( "dbgSpawnTrace" in player.s )
		{
			foreach ( line in player.s.dbgSpawnTrace )
				printt( "BotAI-DBG:     " + line )
		}
	}
	catch ( e )
	{
		printt( "BotAI-DBG: BotAI_DebugSpawnDeath failed:", e )
	}
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
			if ( bot in file.brains )
				delete file.brains[ bot ]
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
		careful = false
		carefulUntil = 0.0
		indoors = false
		nextIndoorCheck = 0.0
		roofCheckPath = null
		roofCheckIndex = -1
		waypointIndoor = false
		stuckCount = 0
		lastStuckTime = -999.0
		unstickUntil = 0.0
		trapPos = null
		trapTime = -999.0
		trapCount = 0
		unstickDir = null
		wpProgressIndex = -1
		wpProgressPath = null
		nextLosCheck = 0.0
		backtrackUntil = 0.0
		wpProgressDist = 0.0
		wpProgressTime = 0.0
		prey = null
		preyUntil = 0.0
		// Personality, rolled every life so bots don't all behave (or path) the same.
		flankChance = RandomInt( 30, 81 )
		flankSide = 0.0	// -1 / 1 = which side of the straight line this bot is taking to its prey
		temperament = ChooseTemperament( bot )
		routeStyle = "direct"		// set from the temperament by ApplyTemperament
		fleeMargin = 0.25			// ...as are these: retreat rules, memory, how often to reposition
		outnumberMargin = 2
		repositionChance = 50
		targetMemory = BOT_TARGET_MEMORY
		targetLastSeenVel = null
		mode = "navigate"
		action = "move"
		actionSince = 0.0
		cover = null
		nextCoverTime = 0.0
		wantReload = false
		nextBoundsCheck = 0.0
		triggerPulse = false
		embarkTitan = null
		titanFight = false
		titanThreats = []
		nextTitanScan = 0.0
		flankElevation = 0.0
		holdUntil = 0.0
		holdWatch = null
		nextHoldLook = 0.0
		alertPos = null
		alertUntil = 0.0
		chaseFor = null
		chaseSeenTime = -1.0
		chasePoint = null
		repositionUntil = 0.0
		repositionPoint = null
		nextBrawlCheck = 0.0
		nextRepositionTime = 0.0
		climbUntil = 0.0
		climbDir = null
		climbTopZ = 0.0
		climbWall = null
		climbAlong = null
		climbMoveDir = null
		climbKicked = false
		climbWallrunStart = 0.0
		climbStart = 0.0
		climbStartZ = 0.0
		climbIsLedge = false	// the climb is a quick ledge mantle (see TryStartLedgeMantle), not a building
		climbJumpTime = 0.0		// first jump of the climb (0 = still running up to the wall)
		climbAltAlong = null	// wallrun climb: the other side to run along, if the first one fails...
		climbTries = 0			// ...and how many times we switched
		nextLedgeCheck = 0.0
		nextWallLedgeCheck = 0.0
		nextClimbCheck = 0.0
		offGraph = false
		offGraphBlockedUntil = 0.0
		planGapDouble = false
		wallLove = RandomFloat( 0.6, 1.0 )
		roamUntil = RandomInt( 100 ) < 40 ? Time() + RandomFloat( 5.0, 15.0 ) : 0.0
		flankPoint = null
		flankFor = null
		flankUntil = 0.0
		wallrunStartTime = -999.0
		wallrunHopAfter = RandomFloat( 0.6, 1.4 )
		wasWallRunning = false
		// Planned wallrun (see UpdateWallrun): the phase, why, and how we mean to get off the wall...
		wrPhase = "none"		// "none" / "approach" / "air" / "run" / "kick"
		wrReason = null			// "up" / "gap" / "long" / "adopted" (on a wall we didn't plan)
		wrExit = null			// "goal" (kick towards the route) / "ledge" (up onto it) / "hop" (to the facing wall)
		wrInto = null			// ...flat unit vector into the wall...
		wrAlong = null			// ...and along it, the way we run
		wrWallPoint = null		// point on the face we're coming in at
		wrTarget = null			// where the run is taking us (route point / goal)
		wrMoveDir = null		// this tick's move direction (world) while the plan is on...
		wrLookDir = null		// ...and where to look
		wrKickDir = null		// direction of the kick off the wall
		wrPhaseStart = 0.0
		wrRunStart = 0.0
		wrChain = 0				// wallruns in this go
		wrPlanDouble = false	// double jump after the kick off
		wrJumped = false		// we jumped for the wall (not just bumped off the ground on the way)
		wrNextPlan = 0.0
		wrNextHopCheck = 0.0
		wrLastTick = 0.0		// last time UpdateWallrun ran (a gap = the plan is stale)
		wrBadWall = null		// wall we last missed, not tried again...
		wrBadUntil = 0.0		// ...until then
		rangeFactor = RandomFloat( BOT_RANGE_FACTOR_MIN, BOT_RANGE_FACTOR_MAX )
		fleeHealth = 0.2
		combatHold = false
		underFireUntil = 0.0
		lastHealth = bot.GetHealth()
		wantAds = false
		adsHeldBit = 0
		// Shooting habits, rolled per life: sprayers vs tappers, trigger-happy vs patient,
		// good vs bad at leading, quick vs smooth on the mouse, early reloaders vs dry reloaders.
		burstScale = RandomFloat( 0.6, 1.6 )
		pauseScale = RandomFloat( 0.7, 1.5 )
		triggerAngle = RandomFloat( 4.0, 14.0 )
		leadSkill = RandomFloat( 0.3, 1.2 )
		aimSmooth = RandomFloat( 0.4, 0.75 )
		overshootChance = RandomInt( 40, 81 )
		suppressTime = RandomInt( 100 ) < 55 ? RandomFloat( 0.3, 1.0 ) : 0.0
		reloadAt = RandomFloat( 0.0, 0.4 )
		nextReloadCheck = 0.0
		reactionTime = 0.5
		aimErrTarget = null
		aimErrYaw = 0.0
		aimErrPitch = 0.0
		titanPreferredDist = RandomFloat( BOT_TITAN_RANGE_MIN, BOT_TITAN_RANGE_MAX )
		titanRangeClass = null	// main weapon titanPreferredDist was rolled for (see UpdateTitanPreferredDist)
		upstairsGoal = null		// upper-floor node we're going up to through the building (see TryGoUpstairs)...
		upstairsUntil = 0.0		// ...until then
		nextUpstairsTime = 0.0
		nextWindowCheck = 0.0
		windowExitDir = null	// jumping out a window / off a balcony this way...
		windowExitStart = 0.0
		windowStartZ = 0.0		// height we jumped out from (still up here afterwards = it didn't work)
		windowSpot = null		// the opening we went for
		windowExitUntil = 0.0	// ...until then
		vortexHoldStart = 0.0	// vortex shield held up since...
		vortexHoldUntil = 0.0	// ...until then (0 = not held)
		nextVortexTime = 0.0
		combatWallSeen = false
		nextCombatHop = Time() + RandomFloat( 0.5, 1.5 )
		planDoubleJump = false
		titanCallAt = null
		titanHoldForEnemy = false
		titanReadySince = 0.0	// titan meter full since (see the team balance in UpdateTitanDecisions)...
		titanLead = 0			// ...titans out on our team minus theirs, last counted...
		nextTitanBalanceCheck = 0.0	// ...and when to count again
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
		lobPos = null			// where a grenade on its way out of the hand is aimed...
		lobUntil = 0.0			// ...and until when the arc is held
		satchelDetonateAt = null	// an enemy walked onto our satchels: set them off at this time
		evac = null				// epilogue, our team escaping: { pos, board } (see GetEvacGoal)
		nextMeleeTime = 0.0
		meleeMisses = 0
		swatting = false
		meleeBlockedUntil = 0.0
		nextDashTime = 0.0
		usingAntiTitan = false
		nextWeaponSwitchTime = 0.0
		weaponWanted = null
		weaponSwitchTime = -999.0
		weaponCheckDone = true
		rodeoTarget = null
		rodeoGiveUpTime = 0.0
		rodeoChance = RandomInt( 10, 36 )
		nextRodeoDecisionTime = Time() + RandomFloat( 5.0, 15.0 )
		rideFireToggle = false
		rodeoStartTime = null
		rodeoReaction = 0.0
		rideSince = 0.0			// riding an enemy titan since (0 = not riding)
		nextRideSwitchTime = 0.0	// on the titan: next time to ask for the primary again...
		rideSwitchTries = 0		// ...how many times it was asked for this ride...
		rideSwitchForced = false	// ...and whether the holster/deploy push was used
		rideGaveUp = false		// stuck on the launcher up there: jumping off (logged once per ride)
		rodeoFriendly = false	// rodeoTarget is a friendly titan we're hitching a ride on (to get away)
		nextFriendlyRideTime = 0.0
		rideLength = 0.0		// a friendly ride lasts this long
		evacRamp = null			// evac: the ramp position the launch decision was made for...
		evacGroundReach = true	// ...whether it can be boarded from the ground...
		evacFails = 0			// ...jumps that landed back on the ground...
		evacJumped = false		// ...a boarding jump is in the air
		evacLaunch = null		// launch point for a high ramp: { pos, roof, fails, reached, until }
		nextEvacLaunchSearch = 0.0
		evacRunupUntil = 0.0	// backing off for a run-up until then...
		evacRunupDir = null		// ...this way
		roofLove = 0.3			// 0..1, how much this bot likes rooftops (set by ApplyTemperament)
		patrolElevation = 0.0	// height above the local ground of the current roaming goal
		holdRoam = false		// holding a high spot reached while roaming (no lead needed)
		ordnanceMode = null		// titan ordnance being held: "lock" / "charge" / "tap"...
		ordnanceHoldStart = 0.0
		ordnanceHoldUntil = 0.0	// ...until then (0 = not held)
		ordnanceClip = -1		// ordnance clip when the press started (a drop = it fired)
		ordnanceVerifyAt = 0.0	// check that the last press fired something at this time
		ordnancePilotSkipUntil = 0.0	// titan ordnance held back from pilots until then (lost roll)
		ordnanceLockWaitSince = 0.0	// Slaved Warheads ready with a target but no lock since (0 = not waiting)
		lobProfile = null		// ordnance profile of the grenade in lobPos (see GetOrdnanceProfile)
		lobDrop = false			// the grenade in lobPos is dropped at our feet while running (look down, keep facing)
		nextRodeoSmokeTime = 0.0
		fleeingNuke = false
		tacticalClip = -1		// titan tactical charges seen last tick (a drop = it was just used)
		smokePos = null			// where our electric smoke went off...
		smokeUntil = 0.0		// ...and until when it lasts
		shieldWall = null		// our particle wall, while it's up
		nextShieldWallScan = 0.0
		strafeDir = 1.0
		nextStrafeFlip = 0.0
		unstickDash = false		// titan stuck: dash out on the next tick (see TitanStuckResponse)
		titanBackOffUntil = 0.0	// titan stuck mid-fight: hold range instead of charging in until then
		titanDetour = null		// titan gave up on a route: go through here first...
		titanDetourUntil = 0.0	// ...until then
		atWantUntil = 0.0		// keep the anti-titan weapon out until then (see WantsAntiTitanWeapon)
		atAimingTime = -999.0	// last time the anti-titan weapon was locking / charging on a target
		chargeStart = 0.0		// charge rifle: when the current charge started...
		chargeClip = -1			// ...and the clip then (a drop = the shot went off)
		threatIsTitan = false	// the threat being run from is a titan (see FindThreatPosition)
		titanEnemies = []		// enemy titans around a titan fight (see ScanTitanFight)
		targetAimOffset = null	// the part of the target in sight, relative to its origin (riders: head or body over the titan)
		rescueRider = null		// enemy riding a friendly titan near us, being shot off it (see UpdateRiderRescue)...
		rescueTitan = null		// ...the titan it's on...
		rescuePoint = null		// ...the spot to go to for a line on it
		nextRiderScan = 0.0
		nextRescuePointTime = 0.0
		evacStarted = false		// the evac run already began (see BotStartEvac)
		dbgInput = null			// last input sent by BotThinkTick (spawn-death diagnostic)
	}

	// Shared so teammates can see who's hunting whom and which way they're going.
	file.brains[ bot ] <- brain
	ApplyTemperament( brain )

	printt( "BotAI:", bot.GetPlayerName(), "spawned, nav nodes =", NavGetNodeCount() )

	local nextDebugTime = 0.0
	while ( true )
	{
		try { BotThinkTick( bot, brain ) }
		catch ( e ) { BotReportError( bot, "BotThinkTick", e ) }

		// Spawn-death diagnostic: log the first moments of each life, dumped if the bot dies early.
		if ( BOT_DEBUG_SPAWN_DEATHS )
		{
			try { BotAI_DebugSpawnTrace( bot, brain ) }
			catch ( e ) { BotReportError( bot, "BotAI_DebugSpawnTrace", e ) }
		}

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
	try { UpdateBoundsWatchdog( bot, brain ) }
	catch ( e ) { BotReportError( bot, "UpdateBoundsWatchdog", e ) }

	local origin = bot.GetOrigin()
	local isTitan = bot.IsTitan()

	// Epilogue: aboard the evac dropship there's nothing left to do.
	if ( IsBotOnEvacDropship( bot ) )
		return
	brain.evac = null
	try { brain.evac = GetEvacGoal( bot ) }
	catch ( e ) { BotReportError( bot, "GetEvacGoal", e ) }
	// A ramp too high to reach from the ground: go up somewhere next to it first.
	try { UpdateEvacLaunch( bot, brain, isTitan ) }
	catch ( e ) { BotReportError( bot, "UpdateEvacLaunch", e ); brain.evacLaunch = null }
	// The moment the evac starts for us, drop everything else (see BotStartEvac).
	local evacNow = brain.evac != null
	if ( evacNow && !brain.evacStarted )
	{
		try { BotStartEvac( bot, brain ) }
		catch ( e ) { BotReportError( bot, "BotStartEvac", e ) }
	}
	brain.evacStarted = evacNow

	// Friendly titans only by choice (see BOT_HOLD_RODEO_FRIENDLY).
	local holdToRodeo = ( brain.rodeoFriendly && brain.rodeoTarget != null ) ? BOT_HOLD_RODEO_AUTO : BOT_HOLD_RODEO_FRIENDLY
	if ( !( "holdToRodeoState" in bot.s ) )
		bot.s.holdToRodeoState <- holdToRodeo
	else
		bot.s.holdToRodeoState = holdToRodeo

	// Riding a titan: the rodeo has its own small loop.
	if ( !isTitan )
	{
		local ridingSoul = bot.GetTitanSoulBeingRodeoed()
		if ( IsValid( ridingSoul ) )
		{
			// Normally set by BotAI_OnRodeoStarted; this covers a ride that started without it.
			if ( brain.rideSince == 0.0 )
				brain.rideSince = Time()
			try { BotRodeoRideTick( bot, brain, ridingSoul ) }
			catch ( e ) { BotReportError( bot, "RodeoRide", e ) }
			return
		}
		brain.rideSince = 0.0
		brain.rideSwitchTries = 0
		brain.rideSwitchForced = false
		brain.rideGaveUp = false
	}

	// Every stage is guarded: a failing stage is skipped for this tick and reported once,
	// instead of killing the whole think thread (which hands the bot back to the engine's
	// wander-only dev bot logic).
	try { UpdateTarget( bot, brain ) }
	catch ( e ) { BotReportError( bot, "UpdateTarget", e ) }

	// In a titan: a pilot going for a rodeo takes priority over everything else.
	brain.swatting = false
	if ( isTitan )
	{
		try { UpdateRodeoIntercept( bot, brain ) }
		catch ( e ) { BotReportError( bot, "UpdateRodeoIntercept", e ) }
	}
	local hasVisibleTarget = brain.target != null && IsValid( brain.target ) && Time() - brain.targetLastSeenTime < BOT_THINK_INTERVAL * 2

	try { UpdateThreat( bot, brain, isTitan, hasVisibleTarget ) }
	catch ( e ) { BotReportError( bot, "UpdateThreat", e ); brain.fleeing = false }

	try { UpdateTitanDecisions( bot, brain, isTitan, hasVisibleTarget ) }
	catch ( e ) { BotReportError( bot, "UpdateTitanDecisions", e ) }

	if ( isTitan )
	{
		try { UpdateTitanTactical( bot, brain ) }
		catch ( e ) { BotReportError( bot, "UpdateTitanTactical", e ); brain.shieldWall = null }
	}

	// Epilogue: titans can't board, so hop out near the evac point; pilots close to the ship's
	// ramp run and jump straight for it (the node graph doesn't go up there).
	if ( brain.evac != null )
	{
		if ( isTitan )
		{
			try { UpdateEvacDisembark( bot, brain ) }
			catch ( e ) { BotReportError( bot, "UpdateEvacDisembark", e ) }
		}
		// With a launch point, evac.board only stays set once we're standing on it (UpdateEvacLaunch
		// points evac at the launch point, board = false, while we're still on the way there).
		else if ( brain.evac.board && ( brain.evacLaunch != null || Length2D( brain.evac.pos - origin ) < BOT_EVAC_BOARD_DIST ) )
		{
			try { BotEvacBoardTick( bot, brain, brain.evac.pos ) }
			catch ( e ) { BotReportError( bot, "EvacBoard", e ) }
			return
		}
	}

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

	// Tactics: break off from crowded fights, hold high points. None of it on the evac run.
	local holding = false
	if ( !isTitan )
	{
		if ( brain.evac == null )
		{
			try { UpdateReposition( bot, brain, hasVisibleTarget ) }
			catch ( e ) { BotReportError( bot, "UpdateReposition", e ); brain.repositionUntil = 0.0 }
			try { holding = !brain.fleeing && IsHoldingVantage( bot, brain, hasVisibleTarget ) }
			catch ( e ) { BotReportError( bot, "IsHoldingVantage", e ); brain.holdUntil = 0.0; brain.holdRoam = false }
		}
	}
	else if ( !brain.swatting && brain.evac == null )
	{
		try { UpdateTitanReposition( bot, brain, hasVisibleTarget ) }
		catch ( e ) { BotReportError( bot, "UpdateTitanReposition", e ); brain.repositionUntil = 0.0 }
	}
	local repositioning = !brain.fleeing && !brain.swatting && Time() < brain.repositionUntil

	// Pilots: perceive, decide, and get this tick's plan (see PilotPlan). A failing plan just
	// leaves the bot on its default behavior for the tick.
	local plan = null
	brain.wantReload = false
	if ( !isTitan )
	{
		try { plan = PilotPlan( bot, brain, hasVisibleTarget ) }
		catch ( e ) { BotReportError( bot, "PilotPlan", e ); plan = null }
	}
	local disengaged = repositioning || ( plan != null && plan.disengage ) || brain.evac != null
	local embarking = plan != null && plan.action == "embark"
	local holdFire = plan != null && plan.holdFire
	local canShoot = hasVisibleTarget && !holdFire

	local moveDir = null
	try
	{
		if ( brain.fleeing && ( brain.fleeDirect || brain.fleeGoal == null ) )
			moveDir = GetDirectFleeDirection( bot, brain )
		else if ( plan != null && plan.holdStill && !brain.fleeing )
			moveDir = null
		else
			moveDir = GetPathDirection( bot, brain, ( plan != null && plan.goal != null && !brain.fleeing ) ? plan.goal : ChooseGoal( bot, brain, isTitan ), isTitan )
	}
	catch ( e )
	{
		BotReportError( bot, "Navigation", e )
		// Fall back to running straight at the target, if any.
		if ( hasVisibleTarget )
			moveDir = brain.target.GetOrigin() - origin
	}

	// Epilogue, on foot, running for the ship: only what's roughly ahead and close is shot at.
	// Turning round to shoot something behind (a titan by the ship, a pilot chasing us) turned the
	// run into a backpedal: no sprint, and the ship left without us.
	local evacRun = !isTitan && brain.evac != null && moveDir != null && Length2D( moveDir ) >= 1.0
	local evacNoShoot = false
	if ( evacRun && hasVisibleTarget )
	{
		try
		{
			local toTarget = brain.target.GetOrigin() - origin
			local offRun = fabs( NormalizeYaw( VectorToAngles( toTarget ).y - VectorToAngles( moveDir ).y ) )
			evacNoShoot = offRun > BOT_EVAC_AIM_CONE || Distance( origin, brain.target.GetOrigin() ) > BOT_EVAC_SHOOT_DIST
				|| IsTitanEntity( brain.target )
		}
		catch ( e ) { BotReportError( bot, "EvacAim", e ); evacNoShoot = true }
	}
	if ( evacNoShoot )
		canShoot = false

	if ( !isTitan )
	{
		try { UpdateCarefulMode( bot, brain ) }
		catch ( e ) { BotReportError( bot, "UpdateCarefulMode", e ); brain.careful = false }
	}

	local pressed = 0
	local buttons = 0
	local forward = 0.0
	local side = 0.0
	// Every forward / side below is worked out relative to this view yaw; the aim turns the view
	// afterwards, and the input is turned with it at the end (see BOT_INPUT_FOLLOWS_AIM).
	local inputYaw = brain.yaw

	// Combat: hold position and strafe inside engage range, otherwise keep moving along the path.
	// While fleeing the bot keeps running and only shoots at what ends up in front of it.
	local targetIsTitan = hasVisibleTarget && IsTitanEntity( brain.target )

	// On foot: anti-titan weapon out against titans, primary against everything else.
	try { UpdateWeaponChoice( bot, brain, isTitan ) }
	catch ( e ) { BotReportError( bot, "UpdateWeaponChoice", e ) }

	try { UpdateUnderFire( bot, brain ) }
	catch ( e ) { BotReportError( bot, "UpdateUnderFire", e ) }

	// Pilots fight anything in their weapon's effective range instead of running up to it first.
	local engageDist = BOT_TITAN_ENGAGE_DIST
	if ( isTitan )
	{
		// Long-range titan weapons open up from farther out.
		try { engageDist = max( engageDist, UpdateTitanPreferredDist( bot, brain ) + BOT_TITAN_ENGAGE_MARGIN ) }
		catch ( e ) { BotReportError( bot, "UpdateTitanPreferredDist", e ) }
	}
	else
		engageDist = targetIsTitan ? BOT_PILOT_AT_ENGAGE_DIST : GetPilotEngageDist( bot )
	// While repositioning the bot keeps moving along its route, shooting on the way.
	local inEngageRange = hasVisibleTarget && !brain.fleeing && !disengaged && Distance( origin, brain.target.GetOrigin() ) < engageDist
	brain.combatHold = false

	if ( inEngageRange )
	{
		local targetDist = Distance( origin, brain.target.GetOrigin() )
		// Hand to hand only makes sense pilot vs pilot/grunt or titan vs anything.
		// And never at something well above or below us (a pilot up on a roof): that just
		// pins the bot against the building underneath it.
		// A titan that just got stuck charging in (stairs, a pilot up on a ledge) holds range for a while.
		local canRush = ( isTitan || !targetIsTitan ) && Time() > brain.meleeBlockedUntil
			&& ( brain.swatting || fabs( brain.target.GetOrigin().z - origin.z ) < BOT_MELEE_MAX_HEIGHT_DIFF )
			&& !( isTitan && !brain.swatting && Time() < brain.titanBackOffUntil )
		// Never at a rider (it's up on the titan: shot, not chased), and on foot never at a pilot
		// standing next to an enemy titan, or with one next to us: the kick would land on the titan.
		canRush = canRush && !IsRodeoing( brain.target )
			&& ( isTitan || ( !IsNearEnemyTitan( brain, origin, BOT_RUSH_TITAN_CLEARANCE )
				&& !IsNearEnemyTitan( brain, brain.target.GetOrigin(), BOT_RUSH_TITAN_CLEARANCE ) ) )
		if ( canRush && targetDist < ( isTitan ? BOT_TITAN_MELEE_RUSH_DIST : BOT_PILOT_MELEE_RUSH_DIST ) )
		{
			// Close enough to finish it hand to hand: run straight at the target.
			local relative = MoveDirRelativeToView( brain.target.GetOrigin() - origin, brain.yaw )
			forward = relative.forward
			side = relative.side
		}
		else if ( !isTitan )
		{
			// Up close pilots circle the target and run along walls; at range they hold a spot and
			// side-step slowly so the shots land. The aim stays on the target either way.
			local combatMove = GetPilotCombatMove( bot, brain, targetIsTitan )
			// Spread around the target instead of fighting shoulder to shoulder.
			local spacing = GetAllySpacingPush( bot, BOT_COMBAT_SPACING_DIST, BOT_COMBAT_SPACING_STRENGTH )
			if ( spacing != null )
				combatMove = combatMove + spacing
			local relative = MoveDirRelativeToView( combatMove, brain.yaw )
			local scale = brain.combatHold ? BOT_HOLD_MOVE_SCALE : 1.0
			forward = relative.forward * scale
			side = relative.side * scale
		}
		else
		{
			// Titans circle the target while closing to brawling range, and push in for the kill.
			local relative = MoveDirRelativeToView( GetTitanCombatMove( bot, brain ), brain.yaw )
			forward = relative.forward
			side = relative.side
		}
	}
	else if ( moveDir != null )
	{
		local relative = MoveDirRelativeToView( moveDir, brain.yaw )
		forward = relative.forward
		side = relative.side

		// (Wallruns while travelling are planned, see UpdateWallrun below.)

		// Near doors and indoors: stay centered between door frames and corners.
		if ( !isTitan && brain.careful && BotOnFoot( bot ) )
		{
			local nudge = GetWhiskerNudge( bot, moveDir )
			if ( nudge != null )
			{
				local nudgeRelative = MoveDirRelativeToView( nudge, brain.yaw )
				forward = BotClamp( forward + nudgeRelative.forward * BOT_WHISKER_STRENGTH, -1.0, 1.0 )
				side = BotClamp( side + nudgeRelative.side * BOT_WHISKER_STRENGTH, -1.0, 1.0 )
			}
		}

		// Don't travel in a conga line: drift off teammates that are right next to us
		// (but squeeze through doorways in single file).
		if ( !isTitan && !brain.careful )
		{
			local push = GetAllySpacingPush( bot )
			if ( push != null )
			{
				local strength = min( Length2D( push ), 1.0 )
				local pushRelative = MoveDirRelativeToView( push, brain.yaw )
				forward = BotClamp( forward + pushRelative.forward * strength, -1.0, 1.0 )
				side = BotClamp( side + pushRelative.side * strength, -1.0, 1.0 )
			}
		}
	}

	// Backing off after getting stuck twice in a row (see UpdateStuck): overrides the route.
	local unsticking = !isTitan && !inEngageRange && Time() < brain.unstickUntil && brain.unstickDir != null
	if ( unsticking )
	{
		local relative = MoveDirRelativeToView( brain.unstickDir, brain.yaw )
		forward = relative.forward
		side = relative.side
	}

	// Climbing a building on the way: overrides the route until up or given up.
	local climbing = false
	if ( !isTitan && !inEngageRange && !unsticking && !brain.fleeing && !embarking )
	{
		try { pressed = pressed | UpdateClimb( bot, brain, moveDir, forward ) }
		catch ( e ) { BotReportError( bot, "UpdateClimb", e ); brain.climbUntil = 0.0 }
		climbing = brain.climbUntil > Time()
		if ( climbing )
		{
			local relative = MoveDirRelativeToView( brain.climbMoveDir, brain.yaw )
			forward = relative.forward
			side = relative.side
		}
	}

	// Planned wallruns (see UpdateWallrun): along a wall that takes us where the route goes, up to a
	// ledge or across a gap. Overrides the route until we're off the wall and down again.
	local wallrunning = false
	local directFlee = brain.fleeing && ( brain.fleeDirect || brain.fleeGoal == null )
	if ( !isTitan && !inEngageRange && !unsticking && !climbing && !embarking && !directFlee && moveDir != null )
	{
		try { pressed = pressed | UpdateWallrun( bot, brain, moveDir ) }
		catch ( e ) { BotReportError( bot, "UpdateWallrun", e ); ResetWallrunPlan( bot, brain, "error" ) }
		wallrunning = brain.wrPhase != "none" && brain.wrMoveDir != null
		if ( wallrunning )
		{
			local relative = MoveDirRelativeToView( brain.wrMoveDir, brain.yaw )
			forward = relative.forward
			side = relative.side
		}
	}
	else if ( brain.wrPhase != "none" )
		ResetWallrunPlan( bot, brain, "aborted" )

	// Upstairs and going somewhere far below: out through a window / off the balcony.
	local windowExit = false
	if ( !isTitan && !climbing && !wallrunning && !inEngageRange && !unsticking && !brain.fleeing && !embarking && moveDir != null )
	{
		try { pressed = pressed | UpdateWindowExit( bot, brain ) }
		catch ( e ) { BotReportError( bot, "UpdateWindowExit", e ); brain.windowExitUntil = 0.0 }
		windowExit = brain.windowExitUntil > Time()
		if ( windowExit )
		{
			local relative = MoveDirRelativeToView( brain.windowExitDir, brain.yaw )
			forward = relative.forward
			side = relative.side
		}
	}
	else
		brain.windowExitUntil = 0.0

	// Rodeo attempt from behind: move away from the pilot (the titan dash goes this way too).
	if ( isTitan && brain.evac == null && IsRodeoThreatBehind( bot, brain ) )
	{
		local relative = MoveDirRelativeToView( origin - brain.target.GetOrigin(), brain.yaw )
		forward = relative.forward
		side = relative.side
	}

	// Friendly titans too close: spread out instead of standing in a pile.
	if ( isTitan )
	{
		try
		{
			local push = GetTitanSpacingPush( bot, inEngageRange ? BOT_TITAN_COMBAT_SPACING_DIST : BOT_TITAN_SPACING_DIST )
			if ( push != null )
			{
				local strength = min( Length2D( push ), 1.0 )
				local relative = MoveDirRelativeToView( push, brain.yaw )
				forward = BotClamp( forward + relative.forward * strength, -1.0, 1.0 )
				side = BotClamp( side + relative.side * strength, -1.0, 1.0 )
			}
		}
		catch ( e ) { BotReportError( bot, "TitanSpacing", e ) }

		// Holding ground (in our smoke with a rider on, behind our particle wall) wins over the
		// fight movement and the spacing above; running from a nuke wins over this, and on the evac
		// run nothing holds the titan back from the evac point.
		if ( !brain.fleeingNuke && brain.evac == null )
		{
			local holdMove = null
			try { holdMove = GetTitanHoldMove( bot, brain ) }
			catch ( e ) { BotReportError( bot, "TitanHoldMove", e ); brain.shieldWall = null }
			if ( holdMove != null )
			{
				if ( Length2D( holdMove ) < 1.0 )
				{
					forward = 0.0
					side = 0.0
				}
				else
				{
					local relative = MoveDirRelativeToView( holdMove, brain.yaw )
					local scale = min( Length2D( holdMove ) / 100.0, 1.0 )	// ease in on the spot
					forward = relative.forward * scale
					side = relative.side * scale
				}
			}
		}

		// Stuck (see TitanStuckResponse): step out the way the hull fits, over the fight and the route.
		if ( !brain.fleeingNuke && Time() < brain.unstickUntil && brain.unstickDir != null )
		{
			local relative = MoveDirRelativeToView( brain.unstickDir, brain.yaw )
			forward = relative.forward
			side = relative.side
		}
	}

	// Target just ducked out of sight: some bots keep firing at where it was for a moment
	// (never with the anti-titan weapon: its few rounds are for the titan itself).
	local suppressing = !hasVisibleTarget && !brain.fleeing && brain.target != null && IsValid( brain.target )
		&& brain.targetLastSeenPos != null && Time() - brain.targetLastSeenTime < brain.suppressTime
		&& !brain.usingAntiTitan
		&& !evacRun							// (the evac run looks where it's going)
		&& !IsRodeoing( brain.target )		// (a rider out of sight is behind a titan: that would hit the titan)

	// Aim at the target when we have one, otherwise look where we are going (always, when fleeing,
	// and on the evac run when the target is off the way to the ship).
	try
	{
		if ( hasVisibleTarget && !brain.fleeing && !evacNoShoot )
			AimAtTarget( bot, brain, brain.target )
		else if ( suppressing )
			AimAt( brain, bot.EyePosition(), brain.targetLastSeenPos + Vector( 0, 0, 40 ), false )
		else if ( plan != null && plan.lookAt != null )
			AimAt( brain, bot.EyePosition(), plan.lookAt, false )	// behind cover: keep facing the titan, ready to peek
		else if ( !isTitan && !brain.fleeing && brain.evac == null && Time() < brain.alertUntil && brain.alertPos != null )	// (not on the evac run: a hit from a titan by the ship turned the run into a backpedal)
			AimAt( brain, bot.EyePosition(), brain.alertPos + Vector( 0, 0, 40 ), false )
		else if ( holding && brain.holdWatch != null )
			AimAt( brain, bot.EyePosition(), brain.holdWatch, false )
		else if ( wallrunning && brain.wrLookDir != null )
			AimAt( brain, origin, origin + brain.wrLookDir * 200.0, false )
		else if ( climbing )
			AimAt( brain, origin, origin + brain.climbMoveDir * 200.0, false )
		else if ( windowExit )
			AimAt( brain, origin, origin + brain.windowExitDir * 200.0, false )
		else if ( moveDir != null )
			AimAt( brain, origin, origin + moveDir, false )
	}
	catch ( e ) { BotReportError( bot, "AimAt", e ) }

	// A grenade being thrown: keep the arc until it has left the hand.
	// A satchel / mine dropped while running: look down at our feet but keep the heading, so the
	// run (moveDir above was made relative to this yaw) isn't turned around.
	if ( !isTitan && brain.lobPos != null && Time() < brain.lobUntil )
	{
		if ( brain.lobDrop )
			AimTowards( brain, brain.yaw, BOT_ORDNANCE_DROP_PITCH )
		else
			AimLob( bot, brain, brain.lobPos, brain.lobProfile )
	}

	// The move input was worked out for the view at the start of the tick; the aim has turned since.
	// Turn the input with it so we move where we meant to (a wallrun stays on its wall while the view
	// swings to a target; a turn towards the next waypoint doesn't carry us past it).
	if ( BOT_INPUT_FOLLOWS_AIM && !isTitan )
	{
		local turned = NormalizeYaw( brain.yaw - inputYaw )
		if ( fabs( turned ) > 0.5 )
		{
			local relative = RotateInputForYaw( forward, side, turned )
			forward = relative.forward
			side = relative.side
		}
		inputYaw = brain.yaw
	}

	local fireButtons = 0
	try { fireButtons = UpdateFiring( bot, brain, ( canShoot || suppressing ) && !holdFire ) }
	catch ( e ) { BotReportError( bot, "UpdateFiring", e ) }
	buttons = buttons | fireButtons

	// (No sights on the evac run: aiming down them would stop the sprint.)
	try { buttons = buttons | UpdateAds( bot, brain, isTitan, canShoot && !evacRun ) }
	catch ( e ) { BotReportError( bot, "UpdateAds", e ); brain.wantAds = false; file.adsBit = 0 }

	// Hiding behind cover: duck.
	if ( plan != null && plan.crouch )
		buttons = buttons | BOT_IN_DUCK

	// Sprint between bursts (firing cancels sprint anyway), but not while aiming down sights.
	if ( !isTitan && forward > 0.5 && !brain.wantAds && ( fireButtons & BOT_IN_ATTACK ) == 0 )
		buttons = buttons | BOT_IN_SPEED

	try { pressed = pressed | UpdateReload( bot, brain, hasVisibleTarget || suppressing ) }
	catch ( e ) { BotReportError( bot, "UpdateReload", e ) }

	try
	{
		if ( !isTitan && inEngageRange )
			pressed = pressed | UpdateCombatJumps( bot, brain )
		else if ( !isTitan && wallrunning )
		{
			// A planned wallrun does its own jumping (UpdateWallrun).
		}
		else if ( !isTitan && !unsticking && !climbing )
			pressed = pressed | UpdateParkour( bot, brain, moveDir, forward )
		else
			pressed = pressed | UpdateTitanDash( bot, brain, hasVisibleTarget, inEngageRange, forward, side )
	}
	catch ( e ) { BotReportError( bot, "UpdateParkour", e ) }

	try { UpdateMelee( bot, brain, isTitan, canShoot ) }
	catch ( e ) { BotReportError( bot, "UpdateMelee", e ) }

	// After aiming, so a grenade throw can lift the pitch for its arc.
	// Pilots may throw while reloading (a grenade doesn't need the gun loaded); the other reasons
	// to hold fire (flanking unseen, ...) hold the grenade too.
	local canThrow = hasVisibleTarget && ( !holdFire || ( plan != null && plan.action == "reload" ) )
	try { pressed = pressed | UpdateAbilities( bot, brain, isTitan, isTitan ? canShoot : canThrow ) }
	catch ( e ) { BotReportError( bot, "UpdateAbilities", e ) }

	// Titan ordnance is held (multi-target missiles lock on while the button is down), so it goes
	// into the held buttons for BotSetInput below, not into the one-tick presses.
	if ( isTitan )
	{
		try { buttons = buttons | UpdateTitanOrdnance( bot, brain, canShoot ) }
		catch ( e ) { BotReportError( bot, "UpdateTitanOrdnance", e ); brain.ordnanceHoldUntil = 0.0 }
		// Vortex shield: held to catch, let go to throw it all back (also a held button).
		try { buttons = buttons | UpdateTitanVortex( bot, brain, hasVisibleTarget ) }
		catch ( e ) { BotReportError( bot, "UpdateTitanVortex", e ); brain.vortexHoldUntil = 0.0 }
		// The trigger would set off the shield early (its "fire" is the throw): hands off it meanwhile.
		if ( brain.vortexHoldUntil > 0.0 )
			buttons = buttons & ~BOT_IN_ATTACK
	}
	else
	{
		brain.ordnanceHoldUntil = 0.0
		brain.vortexHoldUntil = 0.0
	}

	if ( !isTitan )
	{
		try { UpdateSatchelDetonation( bot, brain ) }
		catch ( e ) { BotReportError( bot, "UpdateSatchelDetonation", e ); brain.satchelDetonateAt = null }
	}

	// A grenade throw (UpdateAbilities) may have turned the view again since: same as above.
	if ( BOT_INPUT_FOLLOWS_AIM && !isTitan )
	{
		local turned = NormalizeYaw( brain.yaw - inputYaw )
		if ( fabs( turned ) > 0.5 )
		{
			local relative = RotateInputForYaw( forward, side, turned )
			forward = relative.forward
			side = relative.side
		}
	}

	// Nobody walks, jumps or dashes off into the void (open map edges, pits with a kill trigger):
	// pilots die there, and so do titans now (see mp_wargames.nut).
	{
		try
		{
			local safe = AvoidVoid( bot, brain, forward, side, pressed )
			forward = safe.forward
			side = safe.side
			pressed = safe.pressed
		}
		catch ( e ) { BotReportError( bot, "AvoidVoid", e ) }
	}

	try { UpdateStuck( bot, brain, moveDir, forward, side, !inEngageRange && !unsticking && !climbing && !wallrunning && !brain.offGraph ) }
	catch ( e ) { BotReportError( bot, "UpdateStuck", e ) }

	if ( BOT_DEBUG_SPAWN_DEATHS )
		brain.dbgInput = { forward = forward, side = side, pitch = brain.pitch, yaw = brain.yaw, buttons = buttons, pressed = pressed }

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
	local text = bot.GetPlayerName() + " [" + brain.temperament + " " + brain.mode + "." + brain.action + "] vel=" + speed.tointeger()
		+ " path=" + brain.path.len() + " " + goal
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
	local inTitan = bot.IsTitan()
	local best = null
	local bestScore = BOT_SIGHT_RANGE * 2.0	// above any biased score inside sight range
	local bestPoint = null					// riders: the point of it that's in sight
	local prevTarget = brain.target			// (see the rider override at the end)
	local prevAcquiredTime = brain.targetAcquiredTime
	local prevReactionTime = brain.reactionTime
	// On foot: whether titans are worth picking depends on having something that hurts them.
	local atWeapon = inTitan ? null : GetBotUsableAntiTitanWeapon( bot )

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
		// A titan still inside its titanfall dome can't be hurt: a titan bot doesn't waste time on it.
		if ( inTitan && IsInBubbleShield( enemy ) )
			continue
		// Running for the evac ship on foot: titans are run past, not fought (or turned to look at).
		if ( !inTitan && brain.evac != null && IsTitanEntity( enemy ) )
			continue
		// The rider on our own back can't be aimed at from the cockpit: chasing it just spins the
		// titan in circles. UpdateRodeoDefense deals with it (smoke, or hop out and shoot it).
		if ( inTitan && enemy.IsPlayer() && enemy.GetTitanSoulBeingRodeoed() == bot.GetTitanSoul() )
			continue
		local score = dist
		if ( inTitan )
		{
			// In a titan, the enemy titans are the fight; grunts only when nothing else is around.
			if ( IsTitanEntity( enemy ) )
				score *= BOT_TITAN_TARGET_BIAS
			else if ( !enemy.IsPlayer() )
				score *= BOT_TITAN_SMALL_TARGET_BIAS
		}
		else if ( IsTitanEntity( enemy ) )
		{
			// On foot, player titans and auto-titans alike: the anti-titan weapon's job, or something
			// to keep away from without one. One still inside its titanfall dome can't be hurt yet.
			score *= atWeapon != null ? BOT_PILOT_AT_TITAN_BIAS : BOT_PILOT_NO_AT_TITAN_BIAS
			if ( IsInBubbleShield( enemy ) )
				score *= 3.0
		}
		// An enemy pilot right on us is fought first, titans or not (the same bias as above, so a
		// titan doesn't win just for being big; see BOT_AT_PILOT_SWAP_DIST).
		else if ( enemy.IsPlayer() && atWeapon != null && dist < BOT_AT_PILOT_SWAP_DIST )
			score *= BOT_PILOT_AT_TITAN_BIAS
		else if ( !enemy.IsPlayer() )
			score *= BOT_NPC_TARGET_BIAS
		// A pilot riding a titan is the first thing to shoot (to save a teammate's titan). From a
		// titan a bit less so: the enemy titans are still the fight.
		local riding = IsRodeoing( enemy )
		if ( riding )
			score *= inTitan ? BOT_TITAN_RIDER_BIAS : BOT_RODEO_TARGET_BIAS
		if ( score >= bestScore )
			continue
		// A rider's body sits behind the titan's hull: the center trace hits the titan and the rider
		// never counted as seen. Its head or body is looked for instead, the titan not counting.
		local seenPoint = null
		if ( riding )
		{
			seenPoint = GetRiderVisiblePoint( bot, eye, enemy )
			if ( seenPoint == null )
				continue
		}
		else if ( !CanSee( bot, eye, enemy ) )
			continue

		best = enemy
		bestScore = score
		bestPoint = seenPoint
	}

	if ( best != null )
	{
		if ( best != brain.target )
		{
			brain.targetAcquiredTime = Time()
			brain.reactionTime = RollReactionTime( bot, brain, best )
		}
		brain.targetAimOffset = bestPoint != null ? bestPoint - best.GetOrigin() : null
		brain.target = best
		brain.targetLastSeenPos = best.GetOrigin()
		brain.targetLastSeenVel = best.GetVelocity()
		brain.targetLastSeenTime = Time()
		// Seen by one, known to the team.
		ReportIntel( bot.GetTeam(), best, best.GetOrigin() )
	}
	else if ( brain.target != null && ( !IsAlive( brain.target ) || Time() - brain.targetLastSeenTime > brain.targetMemory
		|| ( inTitan && IsInBubbleShield( brain.target ) )
		|| ( !inTitan && brain.evac != null && IsTitanEntity( brain.target ) )
		|| ( inTitan && brain.target.IsPlayer() && brain.target.GetTitanSoulBeingRodeoed() == bot.GetTitanSoul() ) ) )
	{
		brain.target = null
		brain.targetLastSeenPos = null
		brain.targetLastSeenVel = null
		brain.targetAimOffset = null
		brain.flankFor = null	// a new engagement can be flanked again
	}

	if ( !inTitan )
	{
		UpdateRiderRescue( bot, brain )
		// Switched away above and handed back to the same rider by the override: still the same
		// target, so its reaction time keeps running (restarted every tick, the bot never fired).
		if ( brain.target == prevTarget )
		{
			brain.targetAcquiredTime = prevAcquiredTime
			brain.reactionTime = prevReactionTime
		}
	}
}

// Hopped out because of a rider (see UpdateRodeoDefense): that rider is the target, ahead of
// anything else. Once in sight it's shot; until then it's kept as a remembered target so the
// bot walks around the titan to get a line on it instead of wandering off.
// True when there is such a rider (it's the target now), false otherwise.
function UpdatePetRiderTarget( bot, brain )
{
	local petTitan = bot.GetPetTitan()
	if ( !IsValid( petTitan ) || !IsAlive( petTitan ) )
		return false
	local petSoul = petTitan.GetTitanSoul()
	local rider = IsValid( petSoul ) ? petSoul.GetRiderEnt() : null
	if ( !IsValid( rider ) || !IsAlive( rider ) || rider.GetTeam() == bot.GetTeam() || !rider.IsPlayer() )
		return false

	local now = Time()
	if ( brain.target != rider )
	{
		brain.target = rider
		brain.targetAcquiredTime = now
		brain.reactionTime = brain.skill.reaction * RandomFloat( 0.5, 0.9 )
	}
	brain.targetLastSeenPos = rider.GetOrigin()
	brain.targetLastSeenVel = petTitan.GetVelocity()	// the rider moves with the titan

	local seenPoint = GetRiderVisiblePoint( bot, bot.EyePosition(), rider )
	if ( seenPoint != null )
	{
		brain.targetLastSeenTime = now
		brain.targetAimOffset = seenPoint - rider.GetOrigin()
	}
	else
		brain.targetLastSeenTime = now - BOT_THINK_INTERVAL * 3	// known, but not in sight
	return true
}

// The point of a titan rider that is in sight from eye, or null. The head pokes out above the
// hatch even when the body is hidden behind the hull; a trace that ends on the titan itself
// doesn't count (shots there are absorbed by the titan, which may be our own team's).
function GetRiderVisiblePoint( bot, eye, rider )
{
	local soul = rider.GetTitanSoulBeingRodeoed()
	local titan = IsValid( soul ) ? soul.GetTitan() : null
	foreach ( point in [ rider.EyePosition(), rider.GetWorldSpaceCenter() ] )
	{
		local result = TraceLine( eye, point, bot, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )
		if ( result.hitEnt == rider || ( result.fraction >= 0.99 && ( !IsValid( titan ) || result.hitEnt != titan ) ) )
			return point
	}
	return null
}

// Nearest enemy pilot riding a titan of our team within BOT_RIDER_HELP_DIST:
// { rider, titan }, or null.
function FindFriendlyTitanRider( bot )
{
	local origin = bot.GetOrigin()
	local team = bot.GetTeam()
	local best = null
	local bestDist = BOT_RIDER_HELP_DIST
	foreach ( enemy in GetPlayerArrayOfTeam( GetOtherTeam( team ) ) )
	{
		if ( !IsAlive( enemy ) || !IsRodeoing( enemy ) )
			continue
		local soul = enemy.GetTitanSoulBeingRodeoed()
		local titan = soul.GetTitan()
		if ( !IsValid( titan ) || !IsAlive( titan ) || titan.GetTeam() != team )
			continue
		local dist = Distance( origin, enemy.GetOrigin() )
		if ( dist < bestDist )
		{
			best = { rider = enemy, titan = titan }
			bestDist = dist
		}
	}
	return best
}

// Where to stand for a line on a rider the titan's hull hides: out from the titan on the rider's
// side (behind the titan when the rider is right over its center), BOT_RIDER_ANGLE_DIST away.
function GetRiderAnglePoint( titan, rider )
{
	local titanPos = titan.GetOrigin()
	local out = Normalize2D( rider.GetOrigin() - titanPos )
	if ( Length2D( out ) < 0.5 )
		out = Normalize2D( titan.GetForwardVector() * -1.0 )
	return titanPos + out * BOT_RIDER_ANGLE_DIST
}

// On foot: an enemy riding one of our team's titans is shot off it, whoever's titan it is (the
// titan's own pilot has UpdatePetRiderTarget for its auto-titan, run first). With no line on the
// rider (the hull hides it), it's kept as a remembered target and ChooseAction's "rescue" walks
// the bot round to an angle (rescuePoint). An enemy pilot in sight close by is fought first.
function UpdateRiderRescue( bot, brain )
{
	if ( brain.evac != null || UpdatePetRiderTarget( bot, brain ) )
	{
		brain.rescueRider = null
		brain.rescueTitan = null
		brain.rescuePoint = null
		return
	}

	local now = Time()
	// The rider we're after got off, died, or the titan did.
	if ( brain.rescueRider != null )
	{
		local still = IsValid( brain.rescueRider ) && IsAlive( brain.rescueRider )
			&& IsValid( brain.rescueTitan ) && IsAlive( brain.rescueTitan )
		if ( still )
		{
			local soul = brain.rescueRider.GetTitanSoulBeingRodeoed()
			still = IsValid( soul ) && soul.GetTitan() == brain.rescueTitan
		}
		if ( !still )
		{
			brain.rescueRider = null
			brain.rescueTitan = null
			brain.rescuePoint = null
		}
	}

	if ( now >= brain.nextRiderScan )
	{
		brain.nextRiderScan = now + BOT_RIDER_SCAN_INTERVAL
		local found = FindFriendlyTitanRider( bot )
		if ( found == null )
		{
			brain.rescueRider = null
			brain.rescueTitan = null
			brain.rescuePoint = null
		}
		else if ( found.rider != brain.rescueRider )
		{
			brain.rescueRider = found.rider
			brain.rescueTitan = found.titan
			brain.rescuePoint = null
		}
	}
	if ( brain.rescueRider == null )
		return

	local rider = brain.rescueRider
	local titan = brain.rescueTitan
	if ( brain.rescuePoint == null || now >= brain.nextRescuePointTime )
	{
		brain.rescuePoint = GetRiderAnglePoint( titan, rider )
		brain.nextRescuePointTime = now + BOT_RIDER_ANGLE_REFRESH
	}

	// UpdateTarget already has it in sight this tick.
	local target = brain.target
	if ( target == rider && brain.targetLastSeenTime >= now )
		return
	// An enemy pilot in sight close by would shoot us in the back: that fight comes first.
	if ( target != null && target != rider && IsValid( target ) && target.IsPlayer() && !target.IsTitan()
		&& brain.targetLastSeenTime >= now && Distance( bot.GetOrigin(), target.GetOrigin() ) < BOT_RIDER_KEEP_PILOT_DIST )
		return

	if ( target != rider )
	{
		brain.target = rider
		brain.targetAcquiredTime = now
		brain.reactionTime = RollReactionTime( bot, brain, rider )
	}
	brain.targetLastSeenPos = rider.GetOrigin()
	brain.targetLastSeenVel = titan.GetVelocity()	// the rider moves with the titan
	local seenPoint = GetRiderVisiblePoint( bot, bot.EyePosition(), rider )
	if ( seenPoint != null )
	{
		brain.targetLastSeenTime = now
		brain.targetAimOffset = seenPoint - rider.GetOrigin()
	}
	else
		brain.targetLastSeenTime = now - BOT_THINK_INTERVAL * 3	// known, but not in sight
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

	// Escaping on the evac ship: no climbing back into a titan, no calling one in.
	if ( brain.evac != null )
		return

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
	local now = Time()
	if ( brain.titanCallAt == null )
	{
		brain.titanCallAt = now + RandomFloat( BOT_TITAN_CALL_DELAY_MIN, BOT_TITAN_CALL_DELAY_MAX )
		brain.titanHoldForEnemy = RandomInt( 4 ) == 0
		brain.titanReadySince = now
		brain.nextTitanBalanceCheck = 0.0
	}

	// Team balance: a team with fewer titans out than the other calls its own in straight away (no
	// waiting, no saving it for later); a team already well ahead in titans holds its bots' calls for a
	// while. Otherwise the side that got its titans out first keeps stomping the other one.
	if ( now >= brain.nextTitanBalanceCheck )
	{
		brain.nextTitanBalanceCheck = now + BOT_TITAN_BALANCE_CHECK
		brain.titanLead = GetTeamTitanLead( bot )
	}
	if ( brain.titanLead < 0 )
	{
		// Behind: drop the long random wait (a short retry / back-off still applies).
		brain.titanHoldForEnemy = false
		if ( brain.titanCallAt > now + BOT_TITAN_CALL_RETRY )
			brain.titanCallAt = now
	}
	else if ( brain.titanLead >= BOT_TITAN_LEAD_HOLD && now - brain.titanReadySince < BOT_TITAN_LEAD_HOLD_MAX )
		return

	if ( now < brain.titanCallAt )
		return

	// Some bots save the titan for when they spot an enemy, but never forever.
	if ( brain.titanHoldForEnemy && !hasVisibleTarget && now < brain.titanCallAt + BOT_TITAN_HOLD_FOR_ENEMY )
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

// Our titan tactical: a charge spent since last tick (the clip dropped) means it just went off,
// so the electric smoke's spot is remembered. Our particle wall is looked up while it's up.
function UpdateTitanTactical( bot, brain )
{
	local tactical = bot.GetOffhandWeapon( 1 )
	if ( !IsValid( tactical ) )
	{
		brain.shieldWall = null
		return
	}

	local now = Time()
	local name = tactical.GetWeaponClassName()
	local clip = tactical.GetWeaponPrimaryClipCount()
	if ( clip < brain.tacticalClip && name == "mp_titanability_smoke" )
	{
		brain.smokePos = bot.GetOrigin()
		brain.smokeUntil = now + BOT_SMOKE_DURATION
	}
	brain.tacticalClip = clip

	if ( name != "mp_titanability_bubble_shield" )
	{
		brain.shieldWall = null
		return
	}
	if ( IsValid( brain.shieldWall ) || now < brain.nextShieldWallScan )
		return
	brain.nextShieldWallScan = now + BOT_SHIELD_WALL_SCAN_INTERVAL
	brain.shieldWall = FindOwnShieldWall( bot )
}

// The particle wall is a vortex_sphere owned by the titan that put it up (a titan with the wall
// has no vortex shield, so nothing else of ours can match).
function FindOwnShieldWall( bot )
{
	foreach ( ent in GetEntArrayByClass_Expensive( "vortex_sphere" ) )
	{
		if ( IsValid( ent ) && ent.GetOwner() == bot )
			return ent
	}
	return null
}

// Our electric smoke is still going and an enemy pilot is riding us: stay in the smoke, it's what
// kills the rider (dashing or walking out of it just lets them keep shooting).
function IsHoldingInSmoke( bot, brain )
{
	if ( brain.smokePos == null || Time() > brain.smokeUntil )
		return false
	local soul = bot.GetTitanSoul()
	local rider = IsValid( soul ) ? soul.GetRiderEnt() : null
	return IsValid( rider ) && rider.GetTeam() != bot.GetTeam()
}

// Where a titan should be moving to hold its ground, or null to move as usual: back into our
// electric smoke while a rider is on, or behind our particle wall while fighting.
// A zero vector means stand still.
function GetTitanHoldMove( bot, brain )
{
	local origin = bot.GetOrigin()

	if ( IsHoldingInSmoke( bot, brain ) )
	{
		local toSmoke = brain.smokePos - origin
		toSmoke = Vector( toSmoke.x, toSmoke.y, 0 )
		return Length2D( toSmoke ) > BOT_SMOKE_STAY_RADIUS ? toSmoke : Vector( 0, 0, 0 )
	}

	// A pilot about to jump on us has to be punched, and a lost fight run from, wall or not.
	local wall = brain.shieldWall
	if ( brain.swatting || brain.fleeing || !IsValid( wall ) || brain.target == null || !IsValid( brain.target ) )
		return null
	local wallPos = wall.GetOrigin()
	if ( Distance( origin, wallPos ) > BOT_SHIELD_WALL_MAX_DIST )
		return null

	// Behind the wall as seen from the target, whichever way the wall faces: the wall stays between
	// us and them. Side-step along it so we're not a still target.
	local fromTarget = wallPos - brain.target.GetOrigin()
	fromTarget = Vector( fromTarget.x, fromTarget.y, 0 )
	local len = Length2D( fromTarget )
	if ( len < 1.0 )
		return null
	fromTarget = fromTarget * ( 1.0 / len )
	local along = Vector( -fromTarget.y, fromTarget.x, 0 )

	if ( Time() > brain.nextStrafeFlip )
	{
		brain.strafeDir = -brain.strafeDir
		brain.nextStrafeFlip = Time() + RandomFloat( 0.8, 1.6 )
	}
	local lateral = BotClamp( ( origin - wallPos ).Dot( along ) + brain.strafeDir * 60.0, -BOT_SHIELD_WALL_STRAFE, BOT_SHIELD_WALL_STRAFE )
	local spot = wallPos + fromTarget * BOT_SHIELD_WALL_COVER_DIST + along * lateral
	local toSpot = spot - origin
	return Vector( toSpot.x, toSpot.y, 0 )
}

// An enemy pilot is riding our titan: electric smoke if we have it charged, otherwise (or once the
// smoke is over and the rider is still on) hop out and shoot the rider off (see UpdatePetRiderTarget).
// Dashing is only the fallback while disembarking isn't possible: it never shakes a rider off.
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
	local tactical = bot.GetOffhandWeapon( 1 )
	local hasSmoke = IsValid( tactical ) && tactical.GetWeaponClassName() == "mp_titanability_smoke"
		&& tactical.GetWeaponPrimaryClipCount() > 0
	if ( brain.rodeoStartTime == null )
	{
		brain.rodeoStartTime = now
		brain.rodeoReaction = RandomFloat( BOT_RODEO_REACTION_MIN, BOT_RODEO_REACTION_MAX ) + ( hasSmoke ? BOT_RODEO_SMOKE_GRACE : 0.0 )
		brain.nextRodeoSmokeTime = now + RandomFloat( 0.2, 0.5 )
		printt( "BotAI:", bot.GetPlayerName(), "is being rodeoed by", rider.GetPlayerName() )
	}

	if ( hasSmoke && now > brain.nextRodeoSmokeTime )
	{
		BotPressButtons( bot, BOT_IN_OFFHAND_TACTICAL )
		brain.nextRodeoSmokeTime = now + BOT_RODEO_SMOKE_RETRY
	}

	// The smoke is up: stay in it and let it work (see GetTitanHoldMove), no hopping out or dashing.
	if ( IsHoldingInSmoke( bot, brain ) )
		return

	if ( now - brain.rodeoStartTime < brain.rodeoReaction )
		return

	// Same as the TitanDisembark client command (which isn't globalized), minus the HUD callback.
	if ( PlayerCanDisembarkTitan( bot ) )
	{
		brain.rodeoStartTime = null
		printt( "BotAI:", bot.GetPlayerName(), "hopping out to shoot the rider" )
		bot.CockpitStartDisembark()
		thread PlayerDisembarksTitan( bot )
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
		if ( !IsValid( titan ) || !IsAlive( titan ) || now > brain.rodeoGiveUpTime || brain.evac != null
			|| bot.GetHealth() < bot.GetMaxHealth() * BOT_RODEO_ABORT_HEALTH
			|| !IsValidTitanRodeoTarget( bot, titan ) )
		{
			brain.rodeoTarget = null
			brain.rodeoFriendly = false
			brain.nextRodeoDecisionTime = now + RandomFloat( BOT_RODEO_DECISION_MIN, BOT_RODEO_DECISION_MAX )
			return null
		}
		return titan
	}
	brain.rodeoFriendly = false

	local ride = TryFriendlyRide( bot, brain )
	if ( ride != null )
		return ride

	// Running from the titan itself is no reason not to jump on it instead (a grenade at our feet is).
	local fleeingTitan = brain.fleeing && brain.threatIsTitan && !brain.fleeDirect
	if ( now < brain.nextRodeoDecisionTime || !hasVisibleTarget || ( brain.fleeing && !fleeingTitan ) || brain.evac != null || !IsTitanEntity( brain.target ) )
		return null
	local dist = Distance( bot.GetOrigin(), brain.target.GetOrigin() )
	if ( dist > BOT_RODEO_MAX_START_DIST )
		return null

	// One roll per window, so most titan encounters stay gunfights. With nothing that hurts the
	// titan (or with it already on top of us) a rodeo is the answer far more often.
	local hasAntiTitan = GetBotUsableAntiTitanWeapon( bot ) != null
	local chance = brain.rodeoChance
	if ( !hasAntiTitan )
		chance += BOT_RODEO_NO_AT_BONUS
	if ( dist < BOT_TITAN_TOO_CLOSE_DIST )
		chance += BOT_RODEO_CLOSE_BONUS
	brain.nextRodeoDecisionTime = now + ( hasAntiTitan ? RandomFloat( BOT_RODEO_DECISION_MIN, BOT_RODEO_DECISION_MAX )
		: RandomFloat( BOT_RODEO_DECISION_NO_AT_MIN, BOT_RODEO_DECISION_NO_AT_MAX ) )
	if ( RandomInt( 100 ) >= chance || bot.GetHealth() < bot.GetMaxHealth() * BOT_RODEO_MIN_HEALTH )
		return null
	if ( !IsValidTitanRodeoTarget( bot, brain.target ) )
		return null

	if ( brain.fleeing )
		StopFleeing( brain )
	brain.rodeoTarget = brain.target
	brain.rodeoGiveUpTime = now + BOT_RODEO_APPROACH_TIMEOUT
	printt( "BotAI:", bot.GetPlayerName(), "going for a rodeo" )
	return brain.rodeoTarget
}

// Running away (not from a grenade) with a friendly titan right there: now and then, climb on it
// and let it carry us out. The only time a bot rides a friendly titan.
function TryFriendlyRide( bot, brain )
{
	local now = Time()
	if ( !brain.fleeing || brain.fleeDirect || brain.evac != null || now < brain.nextFriendlyRideTime )
		return null
	brain.nextFriendlyRideTime = now + BOT_RIDE_DECISION
	if ( RandomInt( 100 ) >= BOT_RIDE_CHANCE )
		return null

	local origin = bot.GetOrigin()
	local eye = bot.EyePosition()
	foreach ( titan in GetTitansOfTeam( bot.GetTeam(), origin, BOT_RIDE_DIST ) )
	{
		if ( !IsAlive( titan ) || !IsValidTitanRodeoTarget( bot, titan ) || !CanSee( bot, eye, titan ) )
			continue
		local doomed = false
		try { doomed = titan.GetDoomedState() }
		catch ( e ) {}
		if ( doomed )
			continue

		StopFleeing( brain )
		brain.rodeoTarget = titan
		brain.rodeoFriendly = true
		brain.rodeoGiveUpTime = now + BOT_RIDE_APPROACH_TIMEOUT
		brain.rideLength = RandomFloat( BOT_RIDE_MIN_TIME, BOT_RIDE_MAX_TIME )
		printt( "BotAI:", bot.GetPlayerName(), "hitching a ride on a friendly titan to get away" )
		return titan
	}
	return null
}

// Sprint at the titan's hatch, jump for it and double jump if still below it. The engine
// attaches us once we're in the air close to the hatch and facing it.
function BotRodeoApproachTick( bot, brain, titan )
{
	// The anti-titan weapon is useless on the titan's back: get the primary out on the way there,
	// so it's already in hand when the ride starts.
	local active = bot.GetActiveWeapon()
	if ( !brain.rodeoFriendly && IsValid( active ) && IsAntiTitanWeapon( active ) && Time() > brain.nextRideSwitchTime )
		BotRequestRideWeapon( bot, brain, GetBotRodeoWeapon( bot ) )

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

// On the titan: get the anti-titan weapon away (it doesn't work from up here: the Archer needs
// ADS, the Charge Rifle a charge-and-release, and once empty it just keeps reloading), then keep
// shooting the primary into the hatch (trigger pulsed so semi-autos keep firing too), reload when
// dry, and jump off if it's getting us killed or the switch never goes through.
function BotRodeoRideTick( bot, brain, soul )
{
	brain.rodeoTarget = null
	local now = Time()

	// Epilogue evac: no ride is worth missing the ship. Off the titan (enemy or friendly), now.
	if ( brain.evac != null )
	{
		BotSetInput( bot, 0.0, 0.0, brain.pitch.tofloat(), brain.yaw.tofloat(), 0 )
		BotPressButtons( bot, BOT_IN_JUMP )
		return
	}

	local titan = soul.GetTitan()
	if ( IsValid( titan ) && titan.GetTeam() == bot.GetTeam() )
	{
		BotFriendlyRideTick( bot, brain, titan )
		return
	}
	if ( IsValid( titan ) )
		AimAt( brain, bot.EyePosition(), GetRodeoAimPoint( titan ), false )

	// Not throttled by nextWeaponSwitchTime (UpdateWeaponChoice may have just set it seconds
	// ahead for the launcher): asked again every BOT_RODEO_SWITCH_RETRY until it's out.
	local active = bot.GetActiveWeapon()
	local onAntiTitan = IsValid( active ) && IsAntiTitanWeapon( active )
	// Still climbing on (weapon holstered by PlayerBeginsRodeo, the request from BotAI_OnRodeoStarted
	// comes out on its DeployWeapon): only ask once, no counting, and no holster/deploy of our own
	// that would pull the gun out in the middle of the climb.
	local climbing = brain.rideSince > 0.0 && now - brain.rideSince < BOT_RODEO_CLIMB_TIME
	if ( onAntiTitan && climbing && brain.rideSwitchTries == 0 )
	{
		BotRequestRideWeapon( bot, brain, GetBotRodeoWeapon( bot ) )
	}
	else if ( onAntiTitan && !climbing && now > brain.nextRideSwitchTime )
	{
		local weapon = GetBotRodeoWeapon( bot )
		// A few asks didn't do it: try the other gun every other time.
		if ( brain.rideSwitchTries >= BOT_RODEO_SWITCH_ALT_TRIES && brain.rideSwitchTries % 2 == 1 )
		{
			local primary = GetPilotAntiPersonnelWeapon( bot )
			local other = weapon == primary ? GetPilotSideArmWeapon( bot ) : primary
			if ( other != null )
				weapon = other
		}
		// Still nothing: once, holster and redeploy around the request (the engine picks the
		// requested weapon on deploy, like the melee weapon catch does).
		if ( weapon != null && brain.rideSwitchTries >= BOT_RODEO_SWITCH_FORCE_TRIES && !brain.rideSwitchForced )
		{
			brain.rideSwitchForced = true
			printt( "BotAI:", bot.GetPlayerName(), "still has the anti-titan weapon on the titan, holstering to force", weapon.GetWeaponClassName() )
			bot.HolsterWeapon()
			BotRequestRideWeapon( bot, brain, weapon )
			bot.DeployWeapon()
		}
		else
		{
			BotRequestRideWeapon( bot, brain, weapon )
		}
	}

	// Only shoot (and reload) a gun that's out and done deploying: pulling the trigger or reloading
	// the launcher is what kept it in hand before.
	local ready = IsValid( active ) && !onAntiTitan && now - brain.weaponSwitchTime > BOT_WEAPON_DEPLOY_TIME
	local buttons = 0
	local pressed = 0
	if ( ready )
	{
		brain.rideFireToggle = !brain.rideFireToggle
		buttons = brain.rideFireToggle ? BOT_IN_ATTACK : 0
		pressed = UpdateReload( bot, brain, true )
	}

	if ( bot.GetHealth() < bot.GetMaxHealth() * BOT_RODEO_BAIL_HEALTH )
		pressed = pressed | BOT_IN_JUMP

	// Stuck with the launcher up here: we're just a target. Jump off and fight from the ground.
	local stuckOnLauncher = onAntiTitan && brain.rideSince > 0.0 && now - brain.rideSince > BOT_RODEO_SWITCH_GIVE_UP
	if ( stuckOnLauncher )
	{
		if ( !brain.rideGaveUp )
		{
			brain.rideGaveUp = true
			printt( "BotAI:", bot.GetPlayerName(), "couldn't get the anti-titan weapon away on the titan, jumping off" )
		}
		pressed = pressed | BOT_IN_JUMP
	}

	BotSetInput( bot, 0.0, 0.0, brain.pitch.tofloat(), brain.yaw.tofloat(), buttons )
	if ( pressed != 0 )
		BotPressButtons( bot, pressed )
}

// Riding a friendly titan out of a fight: the view is free up here, so shoot whatever comes into
// sight, and hop off after a while (or once the titan is doomed) to get back to it on foot.
function BotFriendlyRideTick( bot, brain, titan )
{
	local now = Time()
	try { UpdateTarget( bot, brain ) }
	catch ( e ) { BotReportError( bot, "UpdateTarget", e ) }
	try { UpdateWeaponChoice( bot, brain, false ) }
	catch ( e ) { BotReportError( bot, "UpdateWeaponChoice", e ) }

	local hasVisibleTarget = brain.target != null && IsValid( brain.target ) && now - brain.targetLastSeenTime < BOT_THINK_INTERVAL * 2
	if ( hasVisibleTarget )
		AimAtTarget( bot, brain, brain.target )
	local buttons = 0
	try { buttons = UpdateFiring( bot, brain, hasVisibleTarget ) }
	catch ( e ) { BotReportError( bot, "UpdateFiring", e ) }
	local pressed = UpdateReload( bot, brain, hasVisibleTarget )

	local doomed = false
	try { doomed = titan.GetDoomedState() }
	catch ( e ) {}
	local rideTime = brain.rideLength > 0.0 ? brain.rideLength : BOT_RIDE_MIN_TIME
	if ( doomed || ( brain.rideSince > 0.0 && now - brain.rideSince > rideTime ) )
		pressed = pressed | BOT_IN_JUMP

	BotSetInput( bot, 0.0, 0.0, brain.pitch.tofloat(), brain.yaw.tofloat(), buttons )
	if ( pressed != 0 )
		BotPressButtons( bot, pressed )
}

// The gun to ride a titan with: one with the slammer mod if we have it, else the primary while it
// has ammo, else the sidearm (same order as the game's unused ForceWeaponSwitchForRodeo).
function GetBotRodeoWeapon( bot )
{
	local primary = GetPilotAntiPersonnelWeapon( bot )
	local sidearm = GetPilotSideArmWeapon( bot )
	foreach ( weapon in [ primary, sidearm ] )
	{
		if ( weapon == null )
			continue
		local slammer = false
		try { slammer = weapon.HasModDefined( "slammer" ) && weapon.HasMod( "slammer" ) }
		catch ( e ) {}
		if ( slammer )
			return weapon
	}
	if ( primary != null && BotWeaponHasAmmo( bot, primary ) )
		return primary
	if ( sidearm != null )
		return sidearm
	return primary
}

// Ask for the riding gun. Bypasses UpdateWeaponChoice's hold time, and is retried on its own
// clock (nextRideSwitchTime) until the anti-titan weapon is gone.
function BotRequestRideWeapon( bot, brain, weapon )
{
	local now = Time()
	brain.nextRideSwitchTime = now + BOT_RODEO_SWITCH_RETRY
	brain.rideSwitchTries++
	if ( weapon == null )
		return
	bot.SetActiveWeapon( weapon.GetWeaponClassName() )
	brain.weaponWanted = weapon
	brain.weaponSwitchTime = now
	brain.weaponCheckDone = false
	brain.nextWeaponSwitchTime = now + BOT_WEAPON_DEPLOY_TIME
}

// Down into the open hatch: GetTitanHijackOrigin is raised to about the rider's own eye height,
// so aiming at it points nowhere. The hatch hitbox sits under the attachment, inside the titan.
function GetRodeoAimPoint( titan )
{
	local hatch = titan.GetAttachmentOrigin( titan.LookupAttachment( "hijack" ) )
	return hatch + ( titan.GetWorldSpaceCenter() - hatch ) * BOT_RODEO_AIM_DEPTH
}

function BotWeaponHasAmmo( bot, weapon )
{
	return bot.GetWeaponAmmoLoaded( weapon ) != 0 || bot.GetWeaponAmmoStockpile( weapon ) != 0
}

//---------------------------------------------------------
// Epilogue evac
//---------------------------------------------------------
function IsBotOnEvacDropship( bot )
{
	return "playersOnDropship" in level && bot in level.playersOnDropship
}

// Our team is the one escaping (see _evac.nut): where to go, or null. Until the dropship has come
// down at the evac point that's the point itself; then it's the ship's ramp, where boarding is
// checked (EvacShipTriggerCheck: the head within the ramp trigger's radius).
function GetEvacGoal( bot )
{
	if ( GetGameState() != eGameState.Epilogue )
		return null
	if ( !( "evacTeam" in level ) || level.evacTeam == null || bot.GetTeam() != level.evacTeam )
		return null
	if ( !( "evacNode" in level ) || !IsValid( level.evacNode ) )
		return null
	try { if ( Flag( "EvacFinished" ) ) return null }
	catch ( e ) {}

	// The ship was there and got shot down: nothing left to run to.
	local ship = "dropship" in level ? level.dropship : null
	if ( ship != null && !IsAlive( ship ) )
		return null

	local nodePos = level.evacNode.GetOrigin()
	if ( IsAlive( ship ) && "trigger" in ship.s && IsValid( ship.s.trigger ) )
	{
		local ramp = ship.s.trigger.GetOrigin()
		if ( Distance( ramp, nodePos ) < BOT_EVAC_SHIP_NEAR_NODE )
			return { pos = ramp, board = true }
	}
	// The ship has taken off (its ramp is away from the point): too late to get on.
	try { if ( Flag( "EvacShipLeave" ) ) return null }
	catch ( e ) {}
	return { pos = nodePos, board = false }
}

// The evac just started for us: drop whatever the bot was in the middle of (a retreat, cover,
// a reposition or flank, a high point being held or climbed to, a rodeo, a rider hunt) so the
// whole run goes to the ship, and have the tactical ready for the way there.
function BotStartEvac( bot, brain )
{
	printt( "BotAI:", bot.GetPlayerName(), "running for the evac ship" )
	if ( brain.fleeing && !brain.fleeDirect )
		StopFleeing( brain )
	if ( brain.cover != null )
		EndCover( brain, 0.0 )
	brain.repositionUntil = 0.0
	brain.repositionPoint = null
	brain.holdUntil = 0.0
	brain.holdRoam = false
	brain.upstairsGoal = null
	brain.flankPoint = null
	brain.flankUntil = 0.0
	brain.chasePoint = null
	brain.alertUntil = 0.0
	brain.climbUntil = 0.0
	brain.climbIsLedge = false
	brain.windowExitUntil = 0.0
	ResetWallrunPlan( bot, brain, "aborted" )
	brain.rodeoTarget = null
	brain.rodeoFriendly = false
	brain.rescueRider = null
	brain.rescueTitan = null
	brain.rescuePoint = null
	brain.path = []
	brain.pathIndex = 0
	brain.nextRepathTime = 0.0
	brain.nextTacticalTime = min( brain.nextTacticalTime, Time() )
}

// In a titan near the evac point: get out and go the rest of the way on foot.
function UpdateEvacDisembark( bot, brain )
{
	if ( brain.evac == null )
		return
	if ( Distance( bot.GetOrigin(), brain.evac.pos ) > BOT_EVAC_TITAN_EXIT_DIST )
		return
	if ( !PlayerCanDisembarkTitan( bot ) )
		return
	printt( "BotAI:", bot.GetPlayerName(), "leaving the titan to make the evac" )
	bot.CockpitStartDisembark()
	thread PlayerDisembarksTitan( bot )
}

// Boarding a ramp that's too high to reach from the ground (or after missing it from the ground a
// few times): pick a launch point next to the ship (a node or a roof at the right height with a
// clear jump line), and point brain.evac at it, with climbing on, until we're standing on it.
// From there brain.evac is the ramp again and BotEvacBoardTick does the jump. Launch points that
// don't work out are dropped for the whole team.
function UpdateEvacLaunch( bot, brain, isTitan )
{
	if ( brain.evac == null || !brain.evac.board || isTitan )
	{
		brain.evacRamp = null
		brain.evacLaunch = null
		brain.evacFails = 0
		brain.evacJumped = false
		brain.evacGroundReach = true
		brain.evacRunupUntil = 0.0
		return
	}

	local now = Time()
	local ramp = brain.evac.pos
	// New ramp (or the ship still settling): judge it again.
	if ( brain.evacRamp == null || Distance( ramp, brain.evacRamp ) > BOT_EVAC_RAMP_MOVED )
	{
		brain.evacRamp = ramp
		brain.evacLaunch = null
		brain.evacFails = 0
		brain.nextEvacLaunchSearch = 0.0
		brain.evacGroundReach = IsEvacRampReachableFromGround( bot, ramp )
		if ( !brain.evacGroundReach )
			printt( "BotAI:", bot.GetPlayerName(), "evac ramp is too high to reach from the ground, looking for a launch point" )
	}
	if ( brain.evacGroundReach && brain.evacFails < BOT_EVAC_GROUND_TRIES )
		return

	local launch = brain.evacLaunch
	if ( launch != null && ( launch.fails >= BOT_EVAC_LAUNCH_TRIES || ( !launch.reached && now > launch.until ) ) )
	{
		printt( "BotAI:", bot.GetPlayerName(), "dropping an evac launch point", launch.fails >= BOT_EVAC_LAUNCH_TRIES ? "(missed the ramp from it)" : "(couldn't get up there)" )
		file.evacBadLaunches.append( launch.pos )
		if ( file.evacBadLaunches.len() > 64 )
			file.evacBadLaunches.remove( 0 )
		brain.evacLaunch = null
		launch = null
	}
	if ( launch == null )
	{
		if ( now < brain.nextEvacLaunchSearch )
			return
		brain.nextEvacLaunchSearch = now + BOT_EVAC_LAUNCH_SEARCH_RETRY
		launch = FindEvacLaunchPoint( bot, ramp )
		brain.evacLaunch = launch
		// Nothing found: keep trying run-ups from the ground until the next search.
		if ( launch == null )
			return
		printt( "BotAI:", bot.GetPlayerName(), "heading for an evac launch point", launch.roof ? "(roof)" : "(node)",
			( ramp.z - launch.pos.z ).tointeger(), "below the ramp" )
	}

	local origin = bot.GetOrigin()
	local launchFlat = Length2D( launch.pos - origin )
	// Still far off (the search runs as soon as the ship is down, wherever we are): the time to get
	// up there only starts counting close by, or a far bot would drop a good spot for the whole team.
	if ( !launch.reached && launchFlat > BOT_EVAC_LAUNCH_TIMER_DIST )
		launch.until = now + BOT_EVAC_LAUNCH_REACH_TIME
	if ( bot.IsOnGround() )
	{
		if ( !launch.reached && launchFlat < BOT_EVAC_LAUNCH_REACHED && fabs( launch.pos.z - origin.z ) < 48.0 )
		{
			launch.reached = true
		}
		else if ( launch.reached && ( origin.z < launch.pos.z - BOT_EVAC_LAUNCH_LOST_DROP || launchFlat > BOT_EVAC_LAUNCH_MAX_GAP * 1.5 ) )
		{
			// Fell (or jumped) off and landed well below it, or wandered off away from it: go back up.
			// A boarding jump that ends down here is a miss from this launch point (counted here:
			// BotEvacBoardTick doesn't run again until we're back up).
			if ( brain.evacJumped )
			{
				brain.evacFails++
				launch.fails++
				printt( "BotAI:", bot.GetPlayerName(), "missed the evac ramp from a launch point (" + launch.fails + ")" )
			}
			launch.reached = false
			launch.until = now + BOT_EVAC_LAUNCH_REACH_TIME
		}
	}
	if ( !launch.reached )
	{
		// (A jump marked before we were up here isn't a miss from this launch point.)
		brain.evacJumped = false
		brain.evac = { pos = launch.pos, board = false, climb = true }
	}
}

// Is the ground under the ramp close enough below it to board from there with a jump + double jump?
function IsEvacRampReachableFromGround( bot, ramp )
{
	local down = TraceLine( ramp, ramp - Vector( 0, 0, BOT_EVAC_GROUND_PROBE ), bot, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE )
	if ( down.startSolid || down.fraction >= 1.0 )
		return false
	return ramp.z - down.endPos.z <= BOT_EVAC_GROUND_REACH
}

function IsBadEvacLaunch( pos )
{
	foreach ( spot in file.evacBadLaunches )
	{
		if ( Distance( spot, pos ) < BOT_EVAC_BAD_LAUNCH_RADIUS )
			return true
	}
	return false
}

// Score of a spot to jump for the ramp from (higher is better), or null if it can't work: too
// close or too far, the ramp too high above the head (or too far below it), or a dropped spot.
// out = flat direction the ramp sticks out of the ship; spots on that side are easier.
function ScoreEvacLaunchSpot( ramp, out, pos )
{
	local flat = Length2D( ramp - pos )
	if ( flat < BOT_EVAC_LAUNCH_MIN_GAP || flat > BOT_EVAC_LAUNCH_MAX_GAP )
		return null
	local rise = ramp.z - ( pos.z + BOT_EVAC_HEAD_HEIGHT )
	if ( rise > BOT_EVAC_LAUNCH_MAX_RISE || -rise > BOT_EVAC_LAUNCH_MAX_DROP )
		return null
	if ( IsBadEvacLaunch( pos ) )
		return null
	return -flat * 0.5 - max( rise, 0.0 ) * 2.0 + Normalize2D( pos - ramp ).Dot( out ) * BOT_EVAC_LAUNCH_SIDE_BONUS
}

// Launch point for a high ramp: graph nodes in the cells around it, plus roofs found by probing
// down in a ring around it. The best few are checked for a clear line from head height to the
// ramp. Returns { pos, roof, fails, reached, until } or null.
function FindEvacLaunchPoint( bot, ramp )
{
	local ship = "dropship" in level ? level.dropship : null
	local out = IsValid( ship ) ? Normalize2D( ramp - ship.GetOrigin() ) : Vector( 0, 0, 0 )

	local candidates = []
	local nav = GetNavCache()
	for ( local dx = -1; dx <= 1; dx++ )
	{
		for ( local dy = -1; dy <= 1; dy++ )
		{
			local key = NavCellKey( ramp.x + dx * BOT_NAV_CELL, ramp.y + dy * BOT_NAV_CELL )
			if ( !( key in nav.cells ) )
				continue
			foreach ( index in nav.cells[ key ] )
			{
				local pos = nav.positions[ index ]
				local score = ScoreEvacLaunchSpot( ramp, out, pos )
				if ( score != null )
					candidates.append( { pos = pos, roof = false, score = score } )
			}
		}
	}

	// Roofs and ledges the graph doesn't cover: probe down from above the ramp's height, keeping
	// only walkable tops with standing room.
	local probeDepth = BOT_EVAC_LAUNCH_MAX_DROP + BOT_EVAC_LAUNCH_MAX_RISE + BOT_EVAC_HEAD_HEIGHT
	for ( local i = 0; i < BOT_EVAC_ROOF_DIRS; i++ )
	{
		local yaw = 2.0 * PI * i / BOT_EVAC_ROOF_DIRS
		local dir = Vector( cos( yaw ), sin( yaw ), 0 )
		foreach ( radius in [ 200.0, 340.0 ] )
		{
			local top = ramp + dir * radius + Vector( 0, 0, BOT_EVAC_LAUNCH_MAX_DROP )
			local down = TraceLine( top, top - Vector( 0, 0, probeDepth ), bot, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE )
			if ( down.fraction >= 1.0 || down.startSolid || down.surfaceNormal.z < 0.7 )
				continue
			if ( !HasClearLine( bot, down.endPos + Vector( 0, 0, 8 ), down.endPos + Vector( 0, 0, 80 ) ) )
				continue
			local score = ScoreEvacLaunchSpot( ramp, out, down.endPos )
			if ( score != null )
				candidates.append( { pos = down.endPos, roof = true, score = score } )
		}
	}

	// Best first, only a few traced.
	for ( local check = 0; check < BOT_EVAC_LAUNCH_CHECKS && candidates.len() > 0; check++ )
	{
		local bestIndex = 0
		for ( local i = 1; i < candidates.len(); i++ )
		{
			if ( candidates[ i ].score > candidates[ bestIndex ].score )
				bestIndex = i
		}
		local spot = candidates[ bestIndex ]
		candidates.remove( bestIndex )
		if ( HasClearLine( bot, spot.pos + Vector( 0, 0, BOT_EVAC_HEAD_HEIGHT ), ramp ) )
			return { pos = spot.pos, roof = spot.roof, fails = 0, reached = false, until = Time() + BOT_EVAC_LAUNCH_REACH_TIME }
	}
	return null
}

// Which way to back off for a run-up: straight away from the ramp, or (right under it) out the
// ship's open side.
function GetEvacRunupDir( origin, ramp )
{
	local away = origin - ramp
	if ( Length2D( away ) >= 16.0 )
		return Normalize2D( away )
	local ship = "dropship" in level ? level.dropship : null
	if ( IsValid( ship ) )
		return Normalize2D( ramp - ship.GetOrigin() )
	return Vector( 1, 0, 0 )
}

// Last stretch to the ramp (from the ground or from a launch point): sprint at it, jump when close
// (or at the launch point's edge) and double jump on the way up. Standing right under it, back off
// first for a run-up: a standing jump goes nowhere. Landing again without boarding counts as a miss
// (see UpdateEvacLaunch). `below` = how far the ramp is above the head.
function BotEvacBoardTick( bot, brain, ramp )
{
	local now = Time()
	local origin = bot.GetOrigin()
	local toRamp = ramp - origin
	local flat = Length2D( toRamp )
	local launch = brain.evacLaunch
	local below = ramp.z - ( origin.z + BOT_EVAC_HEAD_HEIGHT )
	AimAt( brain, bot.EyePosition(), ramp, false )

	local moveDir = toRamp
	local pressed = 0
	if ( bot.IsOnGround() )
	{
		if ( brain.evacJumped )
		{
			brain.evacJumped = false
			brain.evacFails++
			if ( launch != null )
				launch.fails++
			printt( "BotAI:", bot.GetPlayerName(), "missed the evac ramp", launch != null ? "from a launch point" : "from the ground", "(" + brain.evacFails + ")" )
		}
		brain.usedDoubleJump = false

		if ( now < brain.evacRunupUntil && brain.evacRunupDir != null )
		{
			// Backing off for the run-up, but never off an edge.
			if ( IsGapAhead( bot, brain.evacRunupDir ) )
				brain.evacRunupUntil = 0.0
			else
				moveDir = brain.evacRunupDir
		}
		else if ( below > 0.0 && flat < BOT_EVAC_RUNUP_MIN_DIST && Length2D( bot.GetVelocity() ) < BOT_EVAC_RUNUP_SPEED )
		{
			brain.evacRunupDir = GetEvacRunupDir( origin, ramp )
			brain.evacRunupUntil = now + BOT_EVAC_RUNUP_TIME
			moveDir = brain.evacRunupDir
		}
		else
		{
			local jumpDist = launch != null ? BOT_EVAC_LAUNCH_JUMP_DIST : BOT_EVAC_GROUND_JUMP_DIST
			if ( below > -BOT_EVAC_HEAD_MARGIN && ( flat < jumpDist || ( launch != null && IsGapAhead( bot, toRamp ) ) ) )
				pressed = BOT_IN_JUMP
		}
	}
	else
	{
		// In the air during boarding = a jump for the ramp (counted as a miss if we land again).
		brain.evacJumped = true
		if ( !brain.usedDoubleJump && below > -BOT_EVAC_HEAD_MARGIN && bot.GetVelocity().z < 50.0 )
		{
			brain.usedDoubleJump = true
			pressed = BOT_IN_JUMP
		}
	}

	local relative = MoveDirRelativeToView( moveDir, brain.yaw )
	// Right over the ramp in the air: stop pushing, or we sail past it.
	local scale = ( !bot.IsOnGround() && flat < 48.0 ) ? 0.0 : 1.0
	BotSetInput( bot, ( relative.forward * scale ).tofloat(), ( relative.side * scale ).tofloat(), brain.pitch.tofloat(), brain.yaw.tofloat(), BOT_IN_SPEED )
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

	// In a titan, an enemy nuclear ejection nearby beats everything: run straight out of the blast
	// (the titan dash kicks in as the run starts, see UpdateTitanDash).
	brain.fleeingNuke = false
	if ( isTitan )
	{
		local nuke = FindNukeThreat( bot )
		if ( nuke != null )
		{
			if ( !brain.fleeing )
				printt( "BotAI:", bot.GetPlayerName(), "running from a nuclear ejection" )
			StartFleeing( bot, brain, nuke.pos, nuke.until - Time() + 0.5, true )
			brain.fleeingNuke = true
			return
		}
	}

	// Live grenade nearby: short dash straight away from it, no pathing.
	if ( !isTitan )
	{
		// The radius argument of the Get*ArrayEx natives must be an integer.
		local grenades = GetProjectileArrayEx( "npc_grenade_frag", enemyTeam, origin, BOT_GRENADE_DANGER_RADIUS )
		if ( grenades.len() > 0 )
		{
			// On the evac run only a quick hop aside, then straight back on the way to the ship.
			local dodge = brain.evac != null ? RandomFloat( BOT_EVAC_GRENADE_DODGE_MIN, BOT_EVAC_GRENADE_DODGE_MAX ) : RandomFloat( 1.0, 1.5 )
			StartFleeing( bot, brain, grenades[0].GetOrigin(), dodge, true )
			return
		}
	}

	// Escaping on the evac ship: getting there is the way out, not running somewhere else. A
	// retreat begun before the evac (from a titan, hurt) is dropped right away instead of being
	// run to the end; only a grenade dodge runs its course.
	if ( brain.evac != null )
	{
		if ( brain.fleeing && ( !brain.fleeDirect || Time() >= brain.fleeUntil ) )
			StopFleeing( brain )
		return
	}

	if ( brain.fleeing )
	{
		if ( Time() < brain.fleeUntil )
			return
		StopFleeing( brain )
	}

	// Our titan is out and can be climbed into: that is the answer to titans and to being hurt,
	// not running away from it (see ChooseAction).
	if ( !isTitan && brain.embarkTitan != null )
		return

	local threatPos = FindThreatPosition( bot, brain, isTitan, hasVisibleTarget, enemyTeam )
	if ( threatPos == null )
		return

	// Badly hurt: run for longer, to cover inside a building, until health comes back.
	local hurt = !isTitan && bot.GetHealth() < bot.GetMaxHealth() * BOT_PILOT_FLEE_HEALTH
	local duration = hurt ? RandomFloat( 5.0, 9.0 ) : RandomFloat( 2.5, 5.0 )
	// A titan too close while we can hurt it: only get some room, then turn and shoot again
	// (nothing gets shot while running away).
	if ( !isTitan && brain.threatIsTitan && GetBotUsableAntiTitanWeapon( bot ) != null )
		duration = RandomFloat( BOT_TITAN_FLEE_MIN, BOT_TITAN_FLEE_MAX )
	StartFleeing( bot, brain, threatPos, duration, false )
}

// Where the danger to run from is, or null. Leaves brain.threatIsTitan set when it's a titan.
function FindThreatPosition( bot, brain, isTitan, hasVisibleTarget, enemyTeam )
{
	local origin = bot.GetOrigin()
	local eye = bot.EyePosition()
	brain.threatIsTitan = false

	// On foot vs an enemy titan (player or auto-titan): fight it with the anti-titan weapon from range,
	// but back off if it gets close enough to stomp us, or if we have nothing (loaded) that hurts it.
	if ( !isTitan && brain.rodeoTarget == null )
	{
		local hasAntiTitan = GetBotUsableAntiTitanWeapon( bot ) != null
		foreach ( titan in GetEnemyTitansNear( enemyTeam, origin, BOT_FLEE_TITAN_DIST ) )
		{
			if ( !CanSee( bot, eye, titan ) )
				continue
			if ( !hasAntiTitan || Distance( origin, titan.GetOrigin() ) < BOT_TITAN_TOO_CLOSE_DIST )
			{
				brain.threatIsTitan = true
				return titan.GetOrigin()
			}
		}
	}

	if ( !hasVisibleTarget )
		return null

	if ( isTitan )
		return FindTitanThreatPosition( bot, enemyTeam )

	// Grunts and spectres are fodder for a pilot: never a reason to run. Against a pilot, back out
	// when hurt enough for this temperament's nerve (aggressive: nearly dead and losing badly;
	// cautious: below about half health, whatever the enemy's health).
	local ownFrac = bot.GetHealth().tofloat() / max( bot.GetMaxHealth(), 1 )
	if ( ownFrac < brain.fleeHealth && brain.target.IsPlayer() )
	{
		local targetFrac = brain.target.GetHealth().tofloat() / max( brain.target.GetMaxHealth(), 1 )
		if ( targetFrac > ownFrac + brain.fleeMargin )
			return brain.target.GetOrigin()
	}

	// Outnumbered by enemy pilots: back away from the middle of the group.
	local enemyCount = 0
	local enemyCenter = Vector( 0, 0, 0 )
	foreach ( enemy in GetPlayerArrayOfTeam( enemyTeam ) )
	{
		if ( !IsAlive( enemy ) || Distance( origin, enemy.GetOrigin() ) > BOT_OUTNUMBER_DIST || !CanSee( bot, eye, enemy ) )
			continue
		enemyCount++
		enemyCenter = enemyCenter + enemy.GetOrigin()
	}
	local seenCount = enemyCount

	local allyCount = 0
	foreach ( ally in GetPlayerArrayOfTeam( bot.GetTeam() ) )
	{
		if ( ally != bot && IsAlive( ally ) && Distance( origin, ally.GetOrigin() ) < BOT_OUTNUMBER_DIST )
			allyCount++
	}

	if ( seenCount > 0 && enemyCount >= allyCount + brain.outnumberMargin )
		return enemyCenter * ( 1.0 / seenCount )

	return null
}

// Titans don't back off from pilots, grunts or their own damage (health doesn't come back;
// they eject when it's over). Only a clear titan-count disadvantage makes them give ground.
function FindTitanThreatPosition( bot, enemyTeam )
{
	local origin = bot.GetOrigin()
	local eye = bot.EyePosition()

	local enemyCount = 0
	local enemyCenter = Vector( 0, 0, 0 )
	foreach ( titan in GetTitansOfTeam( enemyTeam, origin, BOT_TITAN_OUTNUMBER_RADIUS ) )
	{
		if ( !IsAlive( titan ) || !CanSee( bot, eye, titan ) )
			continue
		enemyCount++
		enemyCenter = enemyCenter + titan.GetOrigin()
	}

	// Ourselves included.
	local allyCount = GetTitansOfTeam( bot.GetTeam(), origin, BOT_TITAN_OUTNUMBER_RADIUS ).len()
	if ( enemyCount > 0 && enemyCount >= allyCount + BOT_TITAN_OUTNUMBER_MARGIN )
		return enemyCenter * ( 1.0 / enemyCount )

	return null
}

// An enemy nuclear ejection close enough to hurt, or null. Expired ones are dropped here.
function FindNukeThreat( bot )
{
	local now = Time()
	local origin = bot.GetOrigin()
	local team = bot.GetTeam()
	for ( local i = file.nukes.len() - 1; i >= 0; i-- )
	{
		local nuke = file.nukes[ i ]
		if ( now > nuke.until )
		{
			file.nukes.remove( i )
			continue
		}
		// The blast only hurts the other team.
		if ( nuke.team != team && Distance( origin, nuke.pos ) < BOT_NUKE_DANGER_RADIUS )
			return nuke
	}
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
	brain.threatIsTitan = false
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
	local isTitan = bot.IsTitan()
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
		// Titans don't run back to where one of them got stuck.
		if ( isTitan && IsTitanBadSpot( pos ) )
			continue

		local threatDist = Distance( pos, threatPos )
		// Titans don't fit indoors: a roof just means a spot they'll get stuck trying to reach.
		local indoors = !isTitan && IsUnderRoof( pos )
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

	// Epilogue: everything else waits, head for the evac ship.
	if ( brain.evac != null )
		return brain.evac.pos

	// Breaking off from a brawl to come back from a new angle.
	if ( Time() < brain.repositionUntil && brain.repositionPoint != null )
		return brain.repositionPoint

	// A titan that gave up on a route (see TitanStuckResponse): around through the detour point first.
	if ( isTitan && brain.titanDetour != null )
	{
		if ( Time() < brain.titanDetourUntil && Distance2D( bot.GetOrigin(), brain.titanDetour ) > BOT_FLANK_REACHED )
			return brain.titanDetour
		brain.titanDetour = null
	}

	if ( brain.targetLastSeenPos != null )
	{
		if ( !isTitan && brain.temperament == "aggressive" )
		{
			// Straight after it, to where it is heading rather than where it was.
			local lost = Time() - brain.targetLastSeenTime
			if ( lost > 0.3 && brain.targetLastSeenVel != null )
			{
				local velocity = brain.targetLastSeenVel
				return brain.targetLastSeenPos + Vector( velocity.x, velocity.y, 0 ) * min( lost, BOT_CHASE_LEAD_TIME )
			}
		}
		else if ( !isTitan )
		{
			local chase = GetChasePoint( bot, brain )
			if ( chase != null )
				return chase
		}
		return brain.targetLastSeenPos
	}

	// Shot at by someone we can't see: go that way.
	if ( !isTitan && Time() < brain.alertUntil && brain.alertPos != null )
		return brain.alertPos

	// Holding a high point: stay put.
	if ( !isTitan && Time() < brain.holdUntil )
		return null

	// Going up through a building (see TryGoUpstairs): once up there, watch the streets below.
	if ( !isTitan && brain.upstairsGoal != null )
	{
		local toGoal = brain.upstairsGoal - bot.GetOrigin()
		if ( Time() > brain.upstairsUntil )
		{
			brain.upstairsGoal = null
		}
		else if ( Length2D( toGoal ) < BOT_STAIRS_REACHED && fabs( toGoal.z ) < 64.0 )
		{
			brain.upstairsGoal = null
			brain.holdRoam = true
			brain.holdUntil = Time() + RandomFloat( BOT_STAIRS_HOLD_MIN, BOT_STAIRS_HOLD_MAX )
			brain.nextHoldLook = 0.0
			printt( "BotAI:", bot.GetPlayerName(), "made it upstairs, watching from above" )
			return null
		}
		else
			return brain.upstairsGoal
	}

	if ( !isTitan )
	{
		local petTitan = bot.GetPetTitan()
		if ( IsAlive( petTitan ) )
			return petTitan.GetOrigin()
	}

	// Hunt: head for where an enemy was last reported (not where it really is), usually through
	// a route point that fits the bot's style. Some bots roam for a bit after spawning instead.
	// Titans skip the roaming and flanking: they go straight for the fight.
	if ( isTitan || Time() > brain.roamUntil )
	{
		local prey = ChoosePrey( bot, brain )
		if ( prey != null )
		{
			if ( isTitan )
				return prey.GetOrigin()

			local lead = GetIntel( bot.GetTeam(), prey )
			if ( lead != null )
			{
				if ( Distance( bot.GetOrigin(), lead.pos ) > BOT_INTEL_CLEAR_DIST )
				{
					local flank = GetFlankPoint( bot, brain, prey, lead.pos )
					return flank != null ? flank : lead.pos
				}
				// Got there and nobody's around: the lead went cold.
				ClearIntel( bot.GetTeam(), prey )
				brain.prey = null
			}
		}
	}

	// No leads: roam the map, and fight whoever turns up.
	local hasNav = NavGetNodeCount() > 0
	local patrolReached = brain.patrolGoal != null && Distance( bot.GetOrigin(), brain.patrolGoal ) < BOT_PILOT_NODE_REACHED * 2
	// Running across the roofs towards the goal (off the graph): roof lovers aren't pulled back
	// down to a new goal just because the time ran out.
	local patrolExpired = Time() > brain.patrolUntil && !( !isTitan && brain.offGraph && brain.roofLove >= 0.5 )
	if ( brain.patrolGoal == null || patrolExpired || patrolReached )
	{
		if ( brain.patrolGoal != null )
		{
			RememberVisited( brain, brain.patrolGoal )
			// Made it up to a high roaming goal: roof lovers stop there a moment and look around
			// (see IsHoldingVantage, no lead needed for this one).
			if ( !isTitan && patrolReached && brain.patrolElevation >= BOT_VANTAGE_MIN_ELEVATION
				&& RandomInt( 100 ) < BOT_ROOF_HOLD_CHANCE * brain.roofLove )
			{
				brain.holdRoam = true
				brain.holdUntil = Time() + RandomFloat( BOT_ROOF_HOLD_MIN, BOT_ROOF_HOLD_MAX )
				brain.nextHoldLook = 0.0
				brain.patrolGoal = null
				brain.patrolElevation = 0.0
				return null
			}
		}

		if ( hasNav )
		{
			brain.patrolGoal = ChooseExploreGoal( bot, brain )
			brain.patrolUntil = Time() + RandomFloat( BOT_PATROL_TIME * 0.5, BOT_PATROL_TIME * 1.35 )
		}
		else
		{
			// No node graph on this map: run straight at the enemy (stuck detection hops and re-picks).
			brain.patrolGoal = ChooseHuntGoal( bot )
			brain.patrolElevation = 0.0
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
	// In a titan, the nearest enemy titan anywhere on the map comes first.
	if ( bot.IsTitan() )
	{
		local titanPrey = FindNearestEnemyTitan( bot )
		if ( titanPrey != null )
		{
			if ( brain.prey != titanPrey )
			{
				brain.prey = titanPrey
				brain.preyUntil = Time() + RandomFloat( BOT_PREY_MIN_TIME, BOT_PREY_MAX_TIME )
			}
			return titanPrey
		}
	}

	// Pilots only hunt enemies the team has a lead on (see ReportIntel); no lead = no prey,
	// and the bot roams instead.
	local leads = GetTeamIntel( bot.GetTeam() )
	if ( brain.prey != null && IsValid( brain.prey ) && IsAlive( brain.prey ) && Time() < brain.preyUntil && brain.prey in leads )
		return brain.prey

	// Closest lead wins, but pilots count as closer than grunts/spectres, and every teammate
	// already hunting an enemy makes it look farther away, so the team splits up between leads.
	local origin = bot.GetOrigin()
	local claims = GetPreyClaims( bot )
	local best = null
	local bestScore = 0.0
	foreach ( enemy, lead in leads )
	{
		if ( !IsValid( enemy ) || !IsAlive( enemy ) )
			continue
		local score = Distance( origin, lead.pos )
		if ( !enemy.IsPlayer() )
			score *= BOT_PREY_NPC_WEIGHT
		if ( enemy in claims )
			score *= 1.0 + BOT_PREY_CLAIM_PENALTY * claims[ enemy ]
		score *= RandomFloat( 1.0 - BOT_PREY_RANDOMNESS, 1.0 + BOT_PREY_RANDOMNESS )
		if ( best == null || score < bestScore )
		{
			best = enemy
			bestScore = score
		}
	}

	brain.prey = best
	brain.preyUntil = Time() + RandomFloat( BOT_PREY_MIN_TIME, BOT_PREY_MAX_TIME )
	return best
}

//---------------------------------------------------------
// Map knowledge
//---------------------------------------------------------
function ReportIntel( team, enemy, pos )
{
	if ( !( team in file.intel ) )
		file.intel[ team ] <- {}
	file.intel[ team ][ enemy ] <- { pos = pos, time = Time() }
}

function ClearIntel( team, enemy )
{
	if ( team in file.intel && enemy in file.intel[ team ] )
		delete file.intel[ team ][ enemy ]
}

function GetIntel( team, enemy )
{
	if ( !( team in file.intel ) || !( enemy in file.intel[ team ] ) )
		return null
	local lead = file.intel[ team ][ enemy ]
	return Time() - lead.time < BOT_INTEL_MEMORY ? lead : null
}

// The team's live leads (stale and dead ones dropped). Also where the radar-like ping happens:
// every so often one random enemy pilot's rough position becomes known, which keeps the match
// moving when nobody has seen anyone for a while.
function GetTeamIntel( team )
{
	if ( !( team in file.intel ) )
		file.intel[ team ] <- {}
	local leads = file.intel[ team ]

	local now = Time()
	if ( !( team in file.nextIntelPing ) )
		file.nextIntelPing[ team ] <- now + RandomFloat( BOT_INTEL_PING_MIN * 0.5, BOT_INTEL_PING_MAX * 0.5 )
	if ( now > file.nextIntelPing[ team ] )
	{
		file.nextIntelPing[ team ] = now + RandomFloat( BOT_INTEL_PING_MIN, BOT_INTEL_PING_MAX )
		local enemies = []
		foreach ( enemy in GetPlayerArrayOfTeam( GetOtherTeam( team ) ) )
		{
			if ( IsAlive( enemy ) )
				enemies.append( enemy )
		}
		if ( enemies.len() > 0 )
		{
			local enemy = enemies[ RandomInt( enemies.len() ) ]
			local spread = Vector( RandomFloat( -1, 1 ), RandomFloat( -1, 1 ), 0 ) * BOT_INTEL_PING_SPREAD
			ReportIntel( team, enemy, enemy.GetOrigin() + spread )
		}
	}

	local stale = []
	foreach ( enemy, lead in leads )
	{
		if ( !IsValid( enemy ) || !IsAlive( enemy ) || now - lead.time > BOT_INTEL_MEMORY )
			stale.append( enemy )
	}
	foreach ( enemy in stale )
		delete leads[ enemy ]
	return leads
}

// Living teammate bots (not this one) and their brains.
function GetTeammateBrains( bot )
{
	local result = []
	local team = bot.GetTeam()
	foreach ( other, otherBrain in file.brains )
	{
		if ( other != bot && IsValid( other ) && IsAlive( other ) && other.GetTeam() == team )
			result.append( { bot = other, brain = otherBrain } )
	}
	return result
}

// Enemy -> how many teammate bots are currently hunting it.
function GetPreyClaims( bot )
{
	local claims = {}
	foreach ( mate in GetTeammateBrains( bot ) )
	{
		local prey = mate.brain.prey
		if ( prey == null || !IsValid( prey ) )
			continue
		if ( prey in claims )
			claims[ prey ]++
		else
			claims[ prey ] <- 1
	}
	return claims
}

// Teammates near us going for the same prey, and which flank side they took (sum of -1/0/1).
function GetCrowdOnPrey( bot, prey )
{
	local origin = bot.GetOrigin()
	local crowd = { count = 0, sideSum = 0.0 }
	foreach ( mate in GetTeammateBrains( bot ) )
	{
		if ( mate.brain.prey != prey || Distance( origin, mate.bot.GetOrigin() ) > BOT_CROWD_DIST )
			continue
		crowd.count++
		crowd.sideSum += mate.brain.flankSide
	}
	return crowd
}

// Pilots drift away from teammates closer than radius (null if none): right next to us while
// travelling, a bit wider in a gunfight so the team surrounds a target instead of piling up.
function GetAllySpacingPush( bot, radius = BOT_ALLY_SPACING_DIST, strength = BOT_ALLY_SPACING_STRENGTH )
{
	local origin = bot.GetOrigin()
	local push = Vector( 0, 0, 0 )
	local found = false
	foreach ( ally in GetPlayerArrayOfTeam( bot.GetTeam() ) )
	{
		if ( ally == bot || !IsAlive( ally ) || ally.IsTitan() )
			continue
		local away = origin - ally.GetOrigin()
		local dist = Length2D( away )
		if ( dist >= radius )
			continue
		if ( dist < 1.0 )
		{
			away = bot.GetRightVector()
			dist = 1.0
		}
		push = push + Vector( away.x / dist, away.y / dist, 0 ) * ( 1.0 - dist / radius )
		found = true
	}
	return found ? push * strength : null
}

function FindNearestEnemyTitan( bot )
{
	local origin = bot.GetOrigin()
	local nearest = null
	local nearestDist = 0.0
	foreach ( titan in GetTitansOfTeam( GetOtherTeam( bot.GetTeam() ), origin, -1 ) )
	{
		if ( !IsAlive( titan ) )
			continue
		local dist = Distance( origin, titan.GetOrigin() )
		if ( nearest == null || dist < nearestDist )
		{
			nearest = titan
			nearestDist = dist
		}
	}
	return nearest
}

// A node off to one side of the straight line to the prey, visited on the way there.
// Decided once per prey; dropped once reached, on timeout, or when the prey is close anyway.
function GetFlankPoint( bot, brain, prey, preyPos, minDist = BOT_FLANK_MIN_DIST )
{
	local origin = bot.GetOrigin()

	if ( brain.flankFor != prey )
	{
		brain.flankFor = prey
		brain.flankPoint = null
		brain.flankSide = 0.0
		local dist = Distance( origin, preyPos )

		// Teammates nearby already heading for this prey: always take a different route, on the
		// side fewer of them took. The first one there goes straight; the next ones go around.
		// Only "direct" bots may go straight, and only while nobody else is taking that line.
		local crowd = GetCrowdOnPrey( bot, prey )
		local flank = brain.routeStyle != "direct" || crowd.count > 0 || RandomInt( 100 ) < brain.flankChance
		if ( dist > minDist && flank && NavGetNodeCount() > 0 )
		{
			// Flankers and crowded routes commit to a side (the one fewer teammates took);
			// high/indoor bots take whichever side has the better high ground or cover.
			local side = 0.0
			if ( crowd.sideSum > 0.0 )
				side = -1.0
			else if ( crowd.sideSum < 0.0 )
				side = 1.0
			else if ( brain.routeStyle == "flank" || brain.routeStyle == "direct" )
				side = RandomInt( 2 ) == 0 ? -1.0 : 1.0

			local point = ChooseRoutePoint( bot, brain, preyPos, side )
			if ( point != null )
			{
				brain.flankPoint = point.pos
				brain.flankElevation = point.elevation
				local lateral = ( point.pos - origin ).Dot( Vector( -( preyPos - origin ).y, ( preyPos - origin ).x, 0 ) )
				brain.flankSide = lateral >= 0.0 ? 1.0 : -1.0
				brain.flankUntil = Time() + BOT_FLANK_TIMEOUT
			}
		}
	}

	if ( brain.flankPoint == null )
		return null

	// Elevated points count as reached only when actually up there, not standing underneath.
	local toPoint = brain.flankPoint - origin
	local reached = brain.flankElevation >= BOT_VANTAGE_MIN_ELEVATION
		? ( Length2D( toPoint ) < 150.0 && fabs( toPoint.z ) < 72.0 )
		: Distance( origin, brain.flankPoint ) < BOT_FLANK_REACHED
	if ( reached && brain.routeStyle == "high" && brain.flankElevation >= BOT_VANTAGE_MIN_ELEVATION )
		StartVantageHold( brain )

	if ( reached || Time() > brain.flankUntil
		|| Distance( origin, preyPos ) < Distance( brain.flankPoint, preyPos ) )
	{
		brain.flankPoint = null
		brain.flankSide = 0.0
		brain.flankElevation = 0.0
		return null
	}
	return brain.flankPoint
}

//---------------------------------------------------------
// Tactics
//---------------------------------------------------------
//---------------------------------------------------------
// Pilot brain: Perceive -> Decide -> ExecuteAction
//---------------------------------------------------------
// One tick of the pilot's thinking. Returns the plan for this tick: which action the bot is
// in and what it changes (a goal to walk to, whether to leave the usual combat movement, hold
// still, hold fire, crouch). BotThinkTick applies the plan on top of its movement, aiming and
// shooting; the retreat itself is still driven by UpdateThreat / StartFleeing.
function PilotPlan( bot, brain, hasVisibleTarget )
{
	local p = Perceive( bot, brain, hasVisibleTarget )
	local d = Decide( bot, brain, p )
	return ExecuteAction( bot, brain, p, d )
}

// --- Perception: enemy, objective, danger -------------------------------------------------
function Perceive( bot, brain, hasVisibleTarget )
{
	local now = Time()
	brain.embarkTitan = FindEmbarkTitan( bot )
	ScanTitanFight( bot, brain )
	local weapon = bot.GetActiveWeapon()
	local clipSize = IsValid( weapon ) ? GetWeaponClipSize( weapon ) : 0
	local clipLeft = clipSize > 1 ? weapon.GetWeaponPrimaryClipCount().tofloat() / clipSize : 1.0
	local enemy = hasVisibleTarget ? brain.target : null

	return {
		// enemy
		hasEnemy = hasVisibleTarget
		enemyDist = hasVisibleTarget ? Distance( bot.GetOrigin(), enemy.GetOrigin() ) : 99999.0
		enemyIsPilot = hasVisibleTarget && enemy.IsPlayer() && !enemy.IsTitan()
		enemyLooking = hasVisibleTarget && IsLookingAt( enemy, bot )
		// went out of sight a moment ago (and is still remembered)
		enemyLost = !hasVisibleTarget && brain.target != null && IsValid( brain.target ) && brain.targetLastSeenPos != null
		engageDist = GetPilotEngageDist( bot )
		// objective: a place worth going to apart from hunting (none until modes with objectives are enabled)
		objective = GetObjectivePoint( bot, brain )
		alerted = now < brain.alertUntil
		// our own titan, called and on the map, that we can get into
		embarkTitan = brain.embarkTitan
		// danger
		titanFight = brain.titanFight
		titanThreats = brain.titanThreats
		titanEnemies = brain.titanEnemies
		health = bot.GetHealth().tofloat() / max( bot.GetMaxHealth(), 1 )
		underFire = now < brain.underFireUntil
		clipFrac = clipLeft
		fleeing = brain.fleeing
	}
}

// Is ent facing target (within about 28 degrees, sideways only)?
function IsLookingAt( ent, target )
{
	local toTarget = target.GetOrigin() - ent.GetOrigin()
	local dist = Length2D( toTarget )
	local view = ent.GetForwardVector()
	local viewLength = Length2D( view )
	if ( dist < 1.0 || viewLength < 0.01 )
		return false
	return ( view.x * toTarget.x + view.y * toTarget.y ) / ( dist * viewLength ) > 0.88
}

// Our own titan, if it has been called, is on the map and can be climbed into: alive, not
// ejecting or doomed, nobody from the other team riding it, not absurdly far away. Else null.
function FindEmbarkTitan( bot )
{
	if ( bot in file.brains && file.brains[ bot ].evac != null )
		return null
	local pet = bot.GetPetTitan()
	if ( !IsAlive( pet ) )
		return null
	local soul = pet.GetTitanSoul()
	if ( !IsValid( soul ) || soul.IsEjecting() )
		return null
	local rider = soul.GetRiderEnt()
	if ( IsValid( rider ) && rider.GetTeam() != bot.GetTeam() )
		return null
	if ( Distance( bot.GetOrigin(), pet.GetOrigin() ) > BOT_EMBARK_MAX_DIST )
		return null
	try { if ( pet.GetDoomedState() ) return null }
	catch ( e ) {}
	return pet
}

// Out-of-world watchdog. A bot that ends up far outside the area the node graph covers (fallen
// out of the map, thrown past the sky limit, a bad position) is a bot the engine has to keep
// networking at coordinates it was never meant to encode; every player that observes it then
// receives that entity state. Such a bot is killed (so it respawns) and the console says so.
function UpdateBoundsWatchdog( bot, brain )
{
	local now = Time()
	if ( now < brain.nextBoundsCheck )
		return
	brain.nextBoundsCheck = now + BOT_BOUNDS_CHECK_INTERVAL

	local nav = GetNavCache()
	if ( nav.positions.len() == 0 )
		return

	local origin = bot.GetOrigin()
	local bad = origin.x != origin.x || origin.y != origin.y || origin.z != origin.z	// NaN
	if ( !bad )
	{
		bad = origin.z < nav.minZ - BOT_BOUNDS_BELOW || origin.z > nav.maxZ + BOT_BOUNDS_ABOVE
			|| origin.x < nav.minX - BOT_BOUNDS_MARGIN_XY || origin.x > nav.maxX + BOT_BOUNDS_MARGIN_XY
			|| origin.y < nav.minY - BOT_BOUNDS_MARGIN_XY || origin.y > nav.maxY + BOT_BOUNDS_MARGIN_XY
	}
	if ( !bad )
		return

	// Not teleported back: a bot popping across the map in front of anyone watching it is itself a
	// state the engine has to network oddly. Killing it sends it through the normal respawn.
	printt( "BotAI:", bot.GetPlayerName(), "was out of the world at", origin, "- killing it so it respawns" )
	bot.TakeDamage( bot.GetMaxHealth() + 1000, null, null, { forceKill = true, damageSourceId = eDamageSourceId.suicide } )
}

// Is there a titan fight around the pilot (a friendly and an enemy titan close to each other,
// both near us)? Throttled; leaves brain.titanFight, brain.titanThreats (the positions of
// every titan involved) and brain.titanEnemies (the living enemy titans around us).
function ScanTitanFight( bot, brain )
{
	local now = Time()
	if ( now < brain.nextTitanScan )
		return
	brain.nextTitanScan = now + BOT_TITAN_SCAN_INTERVAL

	local origin = bot.GetOrigin()
	local enemies = GetTitansOfTeam( GetOtherTeam( bot.GetTeam() ), origin, BOT_TITAN_FIGHT_RADIUS )
	local allies = GetTitansOfTeam( bot.GetTeam(), origin, BOT_TITAN_FIGHT_RADIUS )

	local fight = false
	foreach ( enemy in enemies )
	{
		if ( !IsAlive( enemy ) )
			continue
		foreach ( ally in allies )
		{
			if ( IsAlive( ally ) && Distance( enemy.GetOrigin(), ally.GetOrigin() ) < BOT_TITAN_FIGHT_PAIR_DIST )
			{
				fight = true
				break
			}
		}
		if ( fight )
			break
	}

	brain.titanFight = fight
	brain.titanThreats = []
	brain.titanEnemies = []
	foreach ( enemy in enemies )
	{
		if ( IsAlive( enemy ) )
			brain.titanEnemies.append( enemy )
	}
	if ( !fight )
		return
	foreach ( titan in enemies )
	{
		if ( IsAlive( titan ) )
			brain.titanThreats.append( titan.GetOrigin() )
	}
	foreach ( titan in allies )
	{
		if ( IsAlive( titan ) )
			brain.titanThreats.append( titan.GetOrigin() )
	}
}

// Capture / defend points. Bots only play modes without objectives for now (see
// BotManagerEnabledForMode), so there is nothing to return yet.
function GetObjectivePoint( bot, brain )
{
	return null
}

// --- Decision ----------------------------------------------------------------------------
function Decide( bot, brain, p )
{
	local now = Time()
	local desired = ChooseAction( bot, brain, p )
	local current = brain.action

	// Keep the current action for a moment so the bot doesn't flip between two every tick;
	// a retreat always goes through, and so does going for a rider on a titan (a flank held
	// the trigger meanwhile).
	local forRider = desired.action == "rescue" || ( p.hasEnemy && IsRodeoing( brain.target ) )
	if ( desired.action != current && desired.action != "retreat" && desired.action != "evac" && !forRider && now - brain.actionSince < BOT_ACTION_MIN_TIME
		&& IsActionValid( brain, p, current ) )
		return { mode = brain.mode, action = current }

	if ( desired.action != current )
	{
		brain.action = desired.action
		brain.mode = desired.mode
		brain.actionSince = now
	}
	return desired
}

function IsActionValid( brain, p, action )
{
	switch ( action )
	{
		case "attack":
		case "reload":
			return p.hasEnemy
		case "cover":
			return brain.cover != null
		case "embark":
			return brain.embarkTitan != null
		case "flank":
			return brain.flankPoint != null && Time() < brain.flankUntil
		case "reposition":
			return Time() < brain.repositionUntil
		case "retreat":
			return brain.fleeing
		case "evac":
			return brain.evac != null
		case "rescue":
			return brain.rescueRider != null
	}
	return true
}

// The rules. Danger first, then what this temperament does about the enemy it sees, then what it
// does about one it lost, then going about its business.
//   mode "combat":   attack, flank, reload
//   mode "navigate": move, chase, capture
//   mode "survive":  cover, retreat, reposition
function ChooseAction( bot, brain, p )
{
	local now = Time()
	local temperament = brain.temperament

	// A grenade at our feet beats everything.
	if ( p.fleeing && brain.fleeDirect )
	{
		if ( brain.cover != null )
			EndCover( brain, BOT_COVER_COOLDOWN )
		return { mode = "survive", action = "retreat" }
	}

	// Epilogue, our team escaping: to the evac ship, shooting on the way but never stopping to fight.
	if ( brain.evac != null )
	{
		if ( brain.cover != null )
			EndCover( brain, 0.0 )
		return { mode = "navigate", action = "evac" }
	}

	// Our titan is out and we can get into it: that comes before fighting, hiding or running (a pilot
	// fights from inside a titan for as long as it can). A retreat from a titan that was only
	// triggered by UpdateThreat is dropped; UpdateThreat won't start another while this holds.
	if ( p.embarkTitan != null )
	{
		if ( brain.cover != null )
			EndCover( brain, 0.0 )
		if ( brain.fleeing )
			StopFleeing( brain )
		return { mode = "navigate", action = "embark" }
	}

	// Danger that UpdateThreat already turned into a retreat (titan, hurt / outnumbered by this
	// temperament's own limits, see FindThreatPosition).
	if ( p.fleeing )
	{
		if ( brain.cover != null )
			EndCover( brain, BOT_COVER_COOLDOWN )
		return { mode = "survive", action = "retreat" }
	}

	// An enemy riding a titan (a teammate's, see UpdateRiderRescue): in sight, shoot it off now,
	// from wherever we are (no cover, no flanking with the trigger held); out of sight behind the
	// hull, go round the titan for a line on it.
	if ( p.hasEnemy && IsRodeoing( brain.target ) )
	{
		if ( brain.cover != null )
			EndCover( brain, 0.0 )
		return { mode = "combat", action = "attack" }
	}
	if ( brain.rescueRider != null && !p.hasEnemy )
	{
		if ( brain.cover != null )
			EndCover( brain, 0.0 )
		return { mode = "combat", action = "rescue" }
	}

	// In cover: the cover routine owns the bot until the episode ends.
	if ( brain.cover != null )
		return { mode = "survive", action = "cover" }

	// Titans fighting around us: out of the crossfire and behind cover, unless an enemy pilot is
	// right on us.
	if ( p.titanFight && now >= brain.nextCoverTime
		&& !( p.hasEnemy && p.enemyIsPilot && p.enemyDist < BOT_TITAN_COVER_PILOT_DIST ) )
	{
		if ( TryStartTitanCover( bot, brain, p ) )
			return { mode = "survive", action = "cover" }
	}

	// Leaving a crowded fight for a new angle.
	if ( now < brain.repositionUntil )
		return { mode = "survive", action = "reposition" }

	if ( p.hasEnemy )
	{
		// Grunts, spectres and titans: the same fight for every temperament.
		if ( !p.enemyIsPilot )
			return { mode = "combat", action = "attack" }

		local enemyPos = brain.target.GetOrigin()

		if ( temperament == "cautious" )
		{
			// Enemy close: look for cover, or failing that change the angle, before fighting.
			if ( now >= brain.nextCoverTime && p.enemyDist < p.engageDist )
			{
				if ( TryStartCover( bot, brain, enemyPos ) )
					return { mode = "survive", action = "cover" }
				if ( now >= brain.nextRepositionTime && RandomInt( 100 ) < BOT_COVER_FAIL_REPOSITION && StartReposition( bot, brain, enemyPos ) )
					return { mode = "survive", action = "reposition" }
			}
		}
		else if ( temperament == "flanker" )
		{
			// Hurt and being shot: take cover. Otherwise don't open up: go around and arrive from the
			// side. Under fire or with the enemy close, fight it out (GetFlankPoint hands back null
			// once we are in position, too).
			if ( p.health < 0.5 && p.underFire && now >= brain.nextCoverTime && TryStartCover( bot, brain, enemyPos ) )
				return { mode = "survive", action = "cover" }
			if ( !p.underFire && p.enemyDist > BOT_FLANKER_MIN_DIST
				&& GetFlankPoint( bot, brain, brain.target, enemyPos, BOT_FLANKER_MIN_DIST ) != null )
				return { mode = "combat", action = "flank" }
		}

		// Clip nearly empty with the enemy not yet on top of us: reload while still moving.
		if ( p.clipFrac < BOT_RELOAD_FRAC && p.enemyDist > BOT_RELOAD_MIN_ENEMY_DIST )
			return { mode = "combat", action = "reload" }
		return { mode = "combat", action = "attack" }
	}

	if ( p.enemyLost )
	{
		// Lost it: cautious bots take a new angle, flankers finish the way round, aggressive
		// bots run after it (ChooseGoal sends them where it was heading).
		if ( temperament == "cautious" && now >= brain.nextRepositionTime && StartReposition( bot, brain, brain.targetLastSeenPos ) )
			return { mode = "survive", action = "reposition" }
		if ( temperament == "flanker" && brain.flankPoint != null && now < brain.flankUntil )
			return { mode = "combat", action = "flank" }
		return { mode = "navigate", action = "chase" }
	}

	if ( p.objective != null )
		return { mode = "navigate", action = "capture" }
	return { mode = "navigate", action = "move" }
}

// --- Actions: what each one changes in this tick's plan ------------------------------------
function ExecuteAction( bot, brain, p, d )
{
	local plan = {
		mode = d.mode
		action = d.action
		goal = null			// walk here instead of the usual goal
		disengage = false	// no combat movement (circling / holding): move along the goal instead
		holdStill = false	// stand still
		holdFire = false	// don't shoot, throw or aim down sights
		crouch = false
		lookAt = null		// face this point when there's nothing to shoot (behind titan cover)
	}
	switch ( d.action )
	{
		case "reload":
			brain.wantReload = true
			plan.holdFire = true
			break

		case "flank":
			plan.goal = brain.flankPoint
			plan.disengage = true
			plan.holdFire = true
			break

		case "cover":
			if ( brain.cover != null )
				CoverTick( bot, brain, p, plan )
			break

		case "embark":
			// Run to the titan (UpdateTitanDecisions climbs in once we are close enough),
			// shooting whatever is in the way.
			plan.goal = p.embarkTitan.GetOrigin()
			plan.disengage = true
			break

		case "reposition":
			plan.disengage = true
			break

		case "capture":
			plan.goal = p.objective
			break

		case "evac":
			// Kept for a moment by Decide even after the evac went away (see IsActionValid).
			if ( brain.evac != null )
				plan.goal = brain.evac.pos
			plan.disengage = true
			break

		case "rescue":
			// Round the titan to where the rider shows over the hull (see UpdateRiderRescue).
			// Kept for a moment by Decide after the rider is gone: then the usual goal.
			plan.goal = brain.rescuePoint
			break
	}
	return plan
}

// --- Cover --------------------------------------------------------------------------------
// A cover episode: go to the spot, hide (ducked, reloading), peek to shoot, go back, hide again,
// until it times out, the enemy finds the spot, or the bot has to retreat.
// opts (optional) turns this into a titan-crossfire cover: { extra = other threat positions,
// needPeek, minThreatDist, maxRadius, eyeHeight }. Without a peek spot the bot just hides.
function TryStartCover( bot, brain, threatPos, opts = null )
{
	local now = Time()
	local spot = FindCoverSpot( bot, threatPos, opts )
	if ( spot == null )
	{
		brain.nextCoverTime = now + BOT_COVER_FAIL_COOLDOWN
		return false
	}
	local titanCover = opts != null
	brain.cover = {
		pos = spot.pos
		peek = spot.peek
		canPeek = !titanCover || opts.needPeek
		titanCover = titanCover
		phase = "go"
		phaseStart = now
		until = 0.0
		expire = now + ( titanCover ? BOT_TITAN_COVER_MAX_TIME : BOT_COVER_MAX_TIME )
		threatEnt = null	// titan cover: the enemy titan we hide from and peek at
		peekArrived = 0.0	// titan cover: when we got onto the peek spot (0 = not yet this peek)
		peekClip = -1		// titan cover: anti-titan clip when the peek started (a drop = we got a shot off)
		peekShot = false	// titan cover: shot fired this peek, duck back
	}
	return true
}

// Cover out of the line of fire of the titans fighting around us (p.titanThreats). Pilots with a
// loaded anti-titan weapon and enough health look for a spot they can peek out of to shoot the
// nearest enemy titan; if there is none (or they can't) they just hide.
function TryStartTitanCover( bot, brain, p )
{
	local origin = bot.GetOrigin()
	// The nearest enemy titan is the one to hide from and peek at.
	local threatEnt = null
	local primary = null
	local primaryDist = 0.0
	foreach ( titan in p.titanEnemies )
	{
		if ( !IsValid( titan ) || !IsAlive( titan ) )
			continue
		local dist = Distance( origin, titan.GetOrigin() )
		if ( primary == null || dist < primaryDist )
		{
			threatEnt = titan
			primary = titan.GetOrigin()
			primaryDist = dist
		}
	}
	if ( primary == null )
	{
		foreach ( pos in p.titanThreats )
		{
			local dist = Distance( origin, pos )
			if ( primary == null || dist < primaryDist )
			{
				primary = pos
				primaryDist = dist
			}
		}
	}
	if ( primary == null )
		return false

	local canPeek = p.health > BOT_TITAN_PEEK_MIN_HEALTH && GetBotUsableAntiTitanWeapon( bot ) != null
	local opts = {
		extra = p.titanThreats
		needPeek = canPeek
		minThreatDist = BOT_TITAN_COVER_MIN_DIST
		maxRadius = BOT_TITAN_COVER_MAX_DIST
		eyeHeight = BOT_TITAN_COVER_EYE_HEIGHT
	}
	local started = TryStartCover( bot, brain, primary, opts )
	if ( !started && canPeek )
	{
		opts.needPeek = false
		started = TryStartCover( bot, brain, primary, opts )
	}
	if ( started )
		brain.cover.threatEnt = threatEnt
	return started
}

function EndCover( brain, cooldown )
{
	brain.cover = null
	brain.nextCoverTime = Time() + cooldown
}

function CoverTick( bot, brain, p, plan )
{
	local c = brain.cover
	local now = Time()
	local origin = bot.GetOrigin()

	if ( now > c.expire )
	{
		EndCover( brain, BOT_COVER_COOLDOWN )
		return
	}
	// The titan fight moved away before we even got there.
	if ( c.titanCover && !p.titanFight && c.phase == "go" )
	{
		EndCover( brain, 1.0 )
		return
	}

	plan.disengage = true
	// Titan cover: keep facing the titan from behind cover, so a peek starts already lined up.
	if ( c.titanCover && c.phase != "go" && c.threatEnt != null && IsValid( c.threatEnt ) && IsAlive( c.threatEnt ) )
		plan.lookAt = c.threatEnt.GetWorldSpaceCenter()

	switch ( c.phase )
	{
		case "go":
			plan.goal = c.pos
			if ( Distance2D( origin, c.pos ) < BOT_COVER_REACHED )
			{
				c.phase = "hide"
				c.phaseStart = now
				if ( c.titanCover )
				{
					local hideScale = brain.temperament == "cautious" ? 1.5 : 1.0
					c.until = now + RandomFloat( BOT_TITAN_HIDE_MIN, BOT_TITAN_HIDE_MAX ) * hideScale
				}
				else
					c.until = now + RandomFloat( BOT_COVER_HIDE_MIN, BOT_COVER_HIDE_MAX )
			}
			break

		case "hide":
			plan.holdStill = true
			plan.crouch = true
			brain.wantReload = true
			if ( c.titanCover )
			{
				// Out of the crossfire: stay until the fight moves on; if something hits us here,
				// look for another spot.
				if ( !p.titanFight && now - c.phaseStart > 1.5 )
				{
					EndCover( brain, 1.0 )
					break
				}
				if ( p.underFire && now - c.phaseStart > 0.3 )
				{
					EndCover( brain, 0.3 )
					break
				}
			}
			// Seen while hiding: the spot is no good any more.
			else if ( p.hasEnemy && now - c.phaseStart > 0.5 )
			{
				EndCover( brain, BOT_COVER_COOLDOWN * 0.5 )
				break
			}
			if ( now > c.until )
			{
				if ( !c.canPeek )
				{
					c.until = now + 1.0	// just hiding: keep waiting
					break
				}
				c.phase = "peek"
				c.phaseStart = now
				if ( c.titanCover )
				{
					// The real length is set on arrival (see below); this only caps the whole peek.
					c.until = now + BOT_TITAN_PEEK_HARD_MAX
					c.peekArrived = 0.0
					c.peekShot = false
					local weapon = bot.GetActiveWeapon()
					c.peekClip = ( IsValid( weapon ) && IsAntiTitanWeapon( weapon ) ) ? weapon.GetWeaponPrimaryClipCount() : -1
				}
				else
					c.until = now + RandomFloat( BOT_COVER_PEEK_MIN, BOT_COVER_PEEK_MAX )
			}
			break

		case "peek":
			plan.goal = c.peek
			if ( Distance2D( origin, c.peek ) < BOT_COVER_REACHED )
			{
				plan.holdStill = true
				if ( c.titanCover && c.peekArrived == 0.0 )
				{
					c.peekArrived = now
					c.until = min( c.until, now + RandomFloat( BOT_TITAN_PEEK_MIN, BOT_TITAN_PEEK_MAX ) )
				}
			}
			if ( c.titanCover )
				UpdateTitanPeek( bot, brain, c, now )
			if ( now > c.until )
			{
				c.phase = "go"
				c.phaseStart = now
			}
			break
	}
}

// Peeking out at a titan: stay out while the anti-titan weapon is locking or charging (up to the
// hard cap), and duck back right after a shot went off (the clip dropped).
function UpdateTitanPeek( bot, brain, c, now )
{
	if ( c.peekShot )
		return
	local weapon = bot.GetActiveWeapon()
	if ( IsValid( weapon ) && IsAntiTitanWeapon( weapon ) )
	{
		local clip = weapon.GetWeaponPrimaryClipCount()
		if ( c.peekClip >= 0 && clip < c.peekClip )
		{
			c.peekShot = true
			c.until = min( c.until, now + 0.4 )
			return
		}
		c.peekClip = clip
	}
	else
		c.peekClip = -1	// not the anti-titan weapon (yet): nothing to compare against
	if ( now - brain.atAimingTime < 0.3 )
		c.until = min( max( c.until, now + 0.5 ), c.phaseStart + BOT_TITAN_PEEK_HARD_MAX )
}

// A graph node near the bot that the threat can't see (standing or ducked), not closer to the
// threat than we are, with a peek spot a step to the side that can see it. { pos, peek } or null.
// opts (see TryStartCover) adds more threats the spot must be hidden from, a minimum distance
// from all of them, a bigger search radius, and makes the peek spot optional.
function FindCoverSpot( bot, threatPos, opts = null )
{
	local nav = GetNavCache()
	if ( nav.positions.len() == 0 )
		return null

	local needPeek = opts == null || opts.needPeek
	local minThreatDist = opts != null ? opts.minThreatDist : 0.0
	local maxRadius = opts != null ? opts.maxRadius : BOT_COVER_MAX_DIST
	// Where the threat looks from: a pilot's eyes, or a titan's cockpit high above them.
	local eyeHeight = ( opts != null && "eyeHeight" in opts ) ? opts.eyeHeight : 56.0
	local threats = [ threatPos ]
	if ( opts != null )
	{
		foreach ( other in opts.extra )
			threats.append( other )
	}

	local origin = bot.GetOrigin()
	local threatEye = threatPos + Vector( 0, 0, eyeHeight )
	local toThreat = threatPos - origin
	local toThreatLength = max( Length2D( toThreat ), 1.0 )
	local side = Vector( -toThreat.y / toThreatLength, toThreat.x / toThreatLength, 0 )
	local ownThreatDist = Distance( origin, threatPos )

	local spots = []
	for ( local i = 0; i < BOT_COVER_SAMPLES; i++ )
	{
		local yaw = RandomFloat( -PI, PI )
		local radius = RandomFloat( BOT_COVER_MIN_DIST, maxRadius )
		spots.append( origin + Vector( cos( yaw ) * radius, sin( yaw ) * radius, 0 ) )
	}

	local mates = GetTeammateBrains( bot )
	local best = null
	local bestScore = 0.0
	foreach ( index in SampleNodesAt( nav, spots ) )
	{
		local pos = nav.positions[ index ]
		if ( fabs( pos.z - origin.z ) > 120.0 || Distance( pos, threatPos ) < ownThreatDist - 200.0 )
			continue

		// Hidden from every threat, standing and ducked, and not right next to any of them.
		local exposed = false
		foreach ( threat in threats )
		{
			if ( Distance( pos, threat ) < minThreatDist )
			{
				exposed = true
				break
			}
			local eye = threat + Vector( 0, 0, eyeHeight )
			if ( HasClearLine( bot, eye, pos + Vector( 0, 0, 60 ) ) || HasClearLine( bot, eye, pos + Vector( 0, 0, 24 ) ) )
			{
				exposed = true
				break
			}
		}
		if ( exposed )
			continue

		local peek = pos
		if ( needPeek )
		{
			peek = null
			foreach ( dirSign in [ 1.0, -1.0 ] )
			{
				local candidate = pos + side * ( BOT_COVER_PEEK_OFFSET * dirSign )
				if ( HasClearLine( bot, threatEye, candidate + Vector( 0, 0, 56 ) )
					&& HasClearLine( bot, pos + Vector( 0, 0, 36 ), candidate + Vector( 0, 0, 36 ) ) )
				{
					peek = candidate
					break
				}
			}
			if ( peek == null )
				continue
		}

		local score = -Distance( origin, pos ) + RandomFloat( 0.0, 200.0 )
		foreach ( mate in mates )
		{
			if ( mate.brain.cover != null && Distance( mate.brain.cover.pos, pos ) < BOT_COVER_MATE_DIST )
				score -= 600.0
		}
		if ( best == null || score > bestScore )
		{
			best = { pos = pos, peek = peek }
			bestScore = score
		}
	}
	return best
}

// Temperament for a new life, steering the team towards a mix (temperaments teammates already
// have get rarer).
function ChooseTemperament( bot )
{
	local weights = { aggressive = 40, cautious = 25, flanker = 35 }
	foreach ( mate in GetTeammateBrains( bot ) )
	{
		local temperament = mate.brain.temperament
		if ( temperament in weights )
			weights[ temperament ] = max( 6, weights[ temperament ] - 8 )
	}
	local total = 0
	foreach ( weight in weights )
		total += weight
	local roll = RandomInt( total )
	foreach ( temperament, weight in weights )
	{
		if ( roll < weight )
			return temperament
		roll -= weight
	}
	return "aggressive"
}

// The numbers behind each temperament; the route follows the temperament.
//   fleeHealth      - retreat from a pilot duel below this health fraction...
//   fleeMargin      - ...if the enemy has this much more health than us (negative = regardless)
//   outnumberMargin - retreat when visible enemy pilots outnumber nearby allies by this many
//   repositionChance- percent chance to leave a crowded fight for a new angle
//   targetMemory    - seconds to keep after an enemy that went out of sight
//   roofLove        - 0..1, how much the bot takes to rooftops: climbing chances (WantsClimb),
//                     high roaming goals and holds there, height of route points. "high" route
//                     bots love roofs, indoor ones hardly; flankers and direct ones in between.
function ApplyTemperament( brain )
{
	switch ( brain.temperament )
	{
		case "cautious":
			brain.routeStyle = RandomInt( 2 ) == 0 ? "indoor" : "high"
			brain.roofLove = brain.routeStyle == "high" ? RandomFloat( 0.8, 1.0 ) : RandomFloat( 0.1, 0.3 )
			brain.fleeHealth = RandomFloat( 0.40, 0.50 )
			brain.fleeMargin = -1.0
			brain.outnumberMargin = 1
			brain.repositionChance = 50
			brain.targetMemory = BOT_TARGET_MEMORY
			break

		case "flanker":
			brain.routeStyle = "flank"
			brain.roofLove = RandomFloat( 0.4, 0.7 )
			brain.fleeHealth = RandomFloat( 0.20, 0.30 )
			brain.fleeMargin = 0.1
			brain.outnumberMargin = 2
			brain.repositionChance = 60
			brain.targetMemory = BOT_TARGET_MEMORY + 1.0
			break

		default:	// aggressive
			brain.routeStyle = RandomInt( 2 ) == 0 ? "direct" : "high"
			brain.roofLove = brain.routeStyle == "high" ? RandomFloat( 0.8, 1.0 ) : RandomFloat( 0.3, 0.6 )
			brain.fleeHealth = RandomFloat( 0.10, 0.20 )
			brain.fleeMargin = 0.25
			brain.outnumberMargin = 3
			brain.repositionChance = 0
			brain.targetMemory = BOT_TARGET_MEMORY * 2.0
			break
	}
}

function NavCellKey( x, y )
{
	return ( floor( x / BOT_NAV_CELL ).tointeger() + 1000 ) * 10000 + ( floor( y / BOT_NAV_CELL ).tointeger() + 1000 )
}

// All node positions in a grid, plus each node's height above the lowest node around it
// (upper floors, walkways, roofs the graph reaches). Built once per map.
function GetNavCache()
{
	if ( file.nav != null )
		return file.nav

	// minX.. maxZ: bounding box of the whole graph, for the out-of-world watchdog.
	local nav = { positions = [], cells = {}, elevation = [], indoor = {}
		minX = 1.0e9, minY = 1.0e9, minZ = 1.0e9, maxX = -1.0e9, maxY = -1.0e9, maxZ = -1.0e9 }
	local count = NavGetNodeCount()
	local cellMinZ = {}
	for ( local i = 0; i < count; i++ )
	{
		local pos = GetNodeVector( i )
		nav.positions.append( pos )
		nav.minX = min( nav.minX, pos.x )
		nav.minY = min( nav.minY, pos.y )
		nav.minZ = min( nav.minZ, pos.z )
		nav.maxX = max( nav.maxX, pos.x )
		nav.maxY = max( nav.maxY, pos.y )
		nav.maxZ = max( nav.maxZ, pos.z )
		local key = NavCellKey( pos.x, pos.y )
		if ( key in nav.cells )
		{
			nav.cells[ key ].append( i )
			if ( pos.z < cellMinZ[ key ] )
				cellMinZ[ key ] = pos.z
		}
		else
		{
			nav.cells[ key ] <- [ i ]
			cellMinZ[ key ] <- pos.z
		}
	}

	foreach ( pos in nav.positions )
	{
		local ground = pos.z
		for ( local dx = -1; dx <= 1; dx++ )
		{
			for ( local dy = -1; dy <= 1; dy++ )
			{
				local key = NavCellKey( pos.x + dx * BOT_NAV_CELL, pos.y + dy * BOT_NAV_CELL )
				if ( key in cellMinZ && cellMinZ[ key ] < ground )
					ground = cellMinZ[ key ]
			}
		}
		nav.elevation.append( pos.z - ground )
	}

	printt( "BotAI: node cache built,", count, "nodes" )
	file.nav = nav
	return nav
}

function IsNodeIndoor( nav, index )
{
	if ( !( index in nav.indoor ) )
		nav.indoor[ index ] <- IsUnderRoof( nav.positions[ index ] )
	return nav.indoor[ index ]
}

// A few random nodes from the grid cell around each spot.
function SampleNodesAt( nav, spots )
{
	local result = []
	foreach ( spot in spots )
	{
		local key = NavCellKey( spot.x, spot.y )
		if ( !( key in nav.cells ) )
			continue
		local cell = nav.cells[ key ]
		for ( local n = 0; n < BOT_TACTIC_NODES_PER_CELL && n < cell.len(); n++ )
			result.append( cell[ RandomInt( cell.len() ) ] )
	}
	return result
}

// Best node for this bot's route style among the candidates: elevated for "high", covered for
// "indoor", wide for flankers; never a teammate's waypoint, never a huge detour from `from` to `to`.
// Returns { pos, elevation } or null.
function ScoreTacticalNodes( bot, brain, nav, candidates, from, to, side )
{
	local direct = Distance( from, to )
	local toTarget = to - from
	local length = max( Length2D( toTarget ), 1.0 )
	local perp = Vector( -toTarget.y / length, toTarget.x / length, 0 )
	local mates = GetTeammateBrains( bot )
	// Titans can't use roofs or interiors: they just look for a good angle.
	local isTitan = bot.IsTitan()
	local style = isTitan ? "flank" : brain.routeStyle

	local best = null
	local bestScore = 0.0
	foreach ( index in candidates )
	{
		local pos = nav.positions[ index ]
		// Nothing up high (walkways, stairs up to them) or where a titan just got stuck.
		if ( isTitan && ( nav.elevation[ index ] > BOT_TITAN_MAX_NODE_ELEVATION || IsTitanBadSpot( pos ) ) )
			continue
		local detour = Distance( from, pos ) + Distance( pos, to ) - direct
		if ( detour > direct * BOT_TACTIC_MAX_DETOUR + 600.0 )
			continue

		local score = -detour * 0.3 + RandomFloat( 0.0, 300.0 )
		local lateral = ( pos - from ).Dot( perp )
		if ( side != 0.0 )
			score += lateral * side * ( style == "flank" ? 0.6 : 0.25 )

		if ( style == "high" )
			score += min( nav.elevation[ index ], BOT_HIGH_ELEVATION_MAX ) * BOT_HIGH_ELEVATION_BONUS
		else if ( !isTitan )	// other pilots like height too, as much as their roofLove says
			score += min( nav.elevation[ index ], BOT_HIGH_ELEVATION_MAX ) * BOT_HIGH_ELEVATION_BONUS * brain.roofLove * BOT_ROOF_ROUTE_SCALE
		// Pilots: spots a wallrun gets us up to, by taste.
		if ( !isTitan && nav.elevation[ index ] >= BOT_CLIMB_MIN_HEIGHT && nav.elevation[ index ] <= BOT_CLIMB_WALLRUN_MAX_HEIGHT )
			score += BOT_WR_REACH_BONUS * brain.wallLove * WallrunStyleFactor( brain )

		foreach ( mate in mates )
		{
			local matePoint = mate.brain.flankPoint != null ? mate.brain.flankPoint : mate.brain.repositionPoint
			if ( matePoint != null && Distance( matePoint, pos ) < BOT_TEAMMATE_POINT_DIST )
				score -= 900.0
			if ( Distance( mate.bot.GetOrigin(), pos ) < BOT_TEAMMATE_POINT_DIST * 0.6 )
				score -= 400.0
		}

		if ( best == null || score > bestScore )
		{
			best = index
			bestScore = score
		}
	}

	// Covered routes: only the best few get the (traced) roof check.
	if ( style == "indoor" && candidates.len() > 0 )
	{
		local indoorBest = null
		local tries = 0
		foreach ( index in candidates )
		{
			if ( tries++ >= 6 )
				break
			local pos = nav.positions[ index ]
			if ( Distance( from, pos ) + Distance( pos, to ) - direct > direct * BOT_TACTIC_MAX_DETOUR + 600.0 )
				continue
			if ( IsNodeIndoor( nav, index ) )
			{
				indoorBest = index
				break
			}
		}
		if ( indoorBest != null )
			best = indoorBest
	}

	if ( best == null )
		return null
	return { pos = nav.positions[ best ], elevation = nav.elevation[ best ] }
}

// A waypoint on the way to the prey, off the straight line on `side` (0 = either), fitting the style.
function ChooseRoutePoint( bot, brain, preyPos, side )
{
	local nav = GetNavCache()
	if ( nav.positions.len() == 0 )
		return null

	local origin = bot.GetOrigin()
	local toPrey = preyPos - origin
	local dist = Distance( origin, preyPos )
	local length = max( Length2D( toPrey ), 1.0 )
	local perp = Vector( -toPrey.y / length, toPrey.x / length, 0 )
	local lateralMax = min( dist * 0.6, 2000.0 )

	local spots = []
	for ( local i = 0; i < BOT_TACTIC_SAMPLES; i++ )
	{
		local lateral = RandomFloat( 0.15, 1.0 ) * lateralMax
		local lateralSide = side != 0.0 ? side : ( RandomInt( 2 ) == 0 ? -1.0 : 1.0 )
		if ( brain.routeStyle != "flank" && RandomInt( 3 ) == 0 )
			lateral *= 0.3	// non-flankers also consider routes close to the direct line
		spots.append( origin + toPrey * RandomFloat( 0.2, 0.75 ) + perp * ( lateral * lateralSide ) )
	}
	return ScoreTacticalNodes( bot, brain, nav, SampleNodesAt( nav, spots ), origin, preyPos, side )
}

// Somewhere around the enemy, at an angle from where we are now (or above it), to come back
// into a crowded fight from a new direction.
function ChooseRepositionPoint( bot, brain, enemyPos )
{
	local nav = GetNavCache()
	if ( nav.positions.len() == 0 )
		return null

	local origin = bot.GetOrigin()
	local fromEnemy = origin - enemyPos
	local baseYaw = atan2( fromEnemy.y, fromEnemy.x )
	local side = RandomInt( 2 ) == 0 ? -1.0 : 1.0
	local spots = []
	for ( local i = 0; i < BOT_TACTIC_SAMPLES; i++ )
	{
		local yaw = baseYaw + side * RandomFloat( 0.8, 1.8 )
		local radius = RandomFloat( BOT_REPOSITION_RADIUS_MIN, BOT_REPOSITION_RADIUS_MAX )
		spots.append( enemyPos + Vector( cos( yaw ) * radius, sin( yaw ) * radius, 0 ) )
	}
	// Scored as a route from here to the enemy: elevated / covered / wide as the style wants.
	return ScoreTacticalNodes( bot, brain, nav, SampleNodesAt( nav, spots ), origin, enemyPos, 0.0 )
}

// Target ducked out of sight and teammates are after it too: instead of everyone running to the
// same last-seen spot, go around through a point on the side away from them. Decided once per
// lost target; null = just go to the last-seen spot.
function GetChasePoint( bot, brain )
{
	local target = brain.target
	if ( target == null || !IsValid( target ) || Time() - brain.targetLastSeenTime < 0.3 )
		return null

	if ( brain.chaseFor != target || brain.chaseSeenTime != brain.targetLastSeenTime )
	{
		brain.chaseFor = target
		brain.chaseSeenTime = brain.targetLastSeenTime
		brain.chasePoint = null

		local origin = bot.GetOrigin()
		local lastSeen = brain.targetLastSeenPos
		if ( Distance( origin, lastSeen ) < BOT_CHASE_SPREAD_MIN_DIST )
			return null

		// Which side of our line to the target are the teammates chasing it on?
		local toTarget = lastSeen - origin
		local perp = Vector( -toTarget.y, toTarget.x, 0 )
		local mateSide = 0.0
		local mates = 0
		foreach ( mate in GetTeammateBrains( bot ) )
		{
			if ( mate.brain.target != target || Distance( mate.bot.GetOrigin(), lastSeen ) > BOT_CROWD_DIST * 1.5 )
				continue
			mates++
			mateSide += ( mate.bot.GetOrigin() - origin ).Dot( perp ) >= 0.0 ? 1.0 : -1.0
		}
		if ( mates == 0 )
			return null

		local side = mateSide > 0.0 ? -1.0 : ( mateSide < 0.0 ? 1.0 : ( RandomInt( 2 ) == 0 ? -1.0 : 1.0 ) )
		local point = ChooseRoutePoint( bot, brain, lastSeen, side )
		if ( point != null )
			brain.chasePoint = point.pos
	}

	if ( brain.chasePoint != null && Distance( bot.GetOrigin(), brain.chasePoint ) < BOT_FLANK_REACHED )
		brain.chasePoint = null
	return brain.chasePoint
}

// Crowded fight: sometimes break off and come back from a new angle. A brawl is several enemy
// pilots in sight with a teammate around, or any enemy pilot with teammates bunched up on us.
function UpdateReposition( bot, brain, hasVisibleTarget )
{
	local now = Time()
	if ( now < brain.repositionUntil )
	{
		if ( brain.repositionPoint == null || Distance( bot.GetOrigin(), brain.repositionPoint ) < BOT_FLANK_REACHED )
			brain.repositionUntil = 0.0
		return
	}
	// (A rider on a titan is shot off where it is, not walked away from.)
	if ( brain.repositionChance <= 0 || !hasVisibleTarget || !brain.target.IsPlayer() || IsTitanEntity( brain.target )
		|| IsRodeoing( brain.target ) || now < brain.nextBrawlCheck || now < brain.nextRepositionTime )
		return
	brain.nextBrawlCheck = now + BOT_BRAWL_CHECK_INTERVAL

	if ( bot.GetHealth() < bot.GetMaxHealth() * 0.5 )
		return

	// A close duel is fought out, not walked away from.
	local origin = bot.GetOrigin()
	if ( Distance( origin, brain.target.GetOrigin() ) < BOT_DUEL_DIST )
		return

	local eye = bot.EyePosition()
	local enemies = 0
	foreach ( enemy in GetPlayerArrayOfTeam( GetOtherTeam( bot.GetTeam() ) ) )
	{
		if ( IsAlive( enemy ) && !enemy.IsTitan() && Distance( origin, enemy.GetOrigin() ) < BOT_BRAWL_RADIUS && CanSee( bot, eye, enemy ) )
			enemies++
	}
	local allies = 0
	local alliesClose = 0
	foreach ( ally in GetPlayerArrayOfTeam( bot.GetTeam() ) )
	{
		if ( ally == bot || !IsAlive( ally ) || ally.IsTitan() )
			continue
		local dist = Distance( origin, ally.GetOrigin() )
		if ( dist < BOT_BRAWL_RADIUS * 0.6 )
			allies++
		if ( dist < BOT_BUNCHED_DIST )
			alliesClose++
	}
	local brawl = ( enemies >= BOT_BRAWL_ENEMY_COUNT && allies >= BOT_BRAWL_ALLY_COUNT )
		|| ( enemies >= 1 && alliesClose >= BOT_BUNCHED_ALLY_COUNT )
	if ( !brawl || RandomInt( 100 ) >= brain.repositionChance )
		return

	StartReposition( bot, brain, brain.target.GetOrigin() )
}

// Head for a point around enemyPos at a new angle (from above, for high-style bots), for a while.
// False if no such point was found.
function StartReposition( bot, brain, enemyPos )
{
	local now = Time()
	local point = ChooseRepositionPoint( bot, brain, enemyPos )
	if ( point == null )
		return false
	brain.repositionPoint = point.pos
	brain.repositionUntil = now + BOT_REPOSITION_TIME
	brain.nextRepositionTime = now + BOT_REPOSITION_COOLDOWN
	brain.nextRepathTime = 0.0
	if ( brain.routeStyle == "high" && point.elevation >= BOT_VANTAGE_MIN_ELEVATION )
		brain.flankElevation = point.elevation
	return true
}

// Overwatch: hold an elevated point for a while, watching the area where the prey was last
// reported. Ends early when we get shot, when the lead goes stale or is close by, or when a
// fight starts (the combat code takes over).
// A roof reached while roaming (brain.holdRoam, see ChooseGoal) is held without a lead: the bot
// looks around the streets below instead.
function IsHoldingVantage( bot, brain, hasVisibleTarget )
{
	if ( Time() > brain.holdUntil )
	{
		brain.holdRoam = false
		return false
	}
	local lead = ( brain.prey != null && IsValid( brain.prey ) ) ? GetIntel( bot.GetTeam(), brain.prey ) : null
	local leadClose = lead != null && Distance( bot.GetOrigin(), lead.pos ) < BOT_VANTAGE_BREAK_DIST
	if ( Time() < brain.underFireUntil || leadClose || ( lead == null && !brain.holdRoam ) )
	{
		brain.holdUntil = 0.0
		brain.holdRoam = false
		return false
	}
	// Look around that area, not at a fixed point.
	if ( Time() > brain.nextHoldLook )
	{
		brain.nextHoldLook = Time() + RandomFloat( 1.0, 2.5 )
		if ( lead != null )
		{
			brain.holdWatch = lead.pos + Vector( RandomFloat( -400, 400 ), RandomFloat( -400, 400 ), 40 )
		}
		else
		{
			local yaw = RandomFloat( -PI, PI )
			brain.holdWatch = bot.EyePosition() + Vector( cos( yaw ) * 1200.0, sin( yaw ) * 1200.0, -150.0 )
		}
	}
	return !hasVisibleTarget
}

// Height of a walkable roof just behind a wall in direction dir, or null. The probe comes down
// onto the top from above, past the wall face, with clear air on our side of it.
function FindClimbableRoof( bot, dir )
{
	local origin = bot.GetOrigin()
	local chest = origin + Vector( 0, 0, 40 )
	local wall = TraceLine( chest, chest + dir * BOT_CLIMB_WALL_DIST, bot, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE )
	if ( wall.fraction >= 1.0 )
		return null
	local wallDist = BOT_CLIMB_WALL_DIST * wall.fraction
	local wallPoint = chest + dir * wallDist
	if ( IsBadClimbSpot( wallPoint ) )
		return null

	// Clear air straight up in front of the wall: overhanging eaves, balconies and walls that
	// lean out over us leave no way up, however good the top looks.
	// Checked across the pilot's width (center and both shoulders), not just one thin line.
	local probeHeight = BOT_CLIMB_WALLRUN_MAX_HEIGHT + 72.0
	local right = Vector( dir.y, -dir.x, 0 )
	local column = origin + dir * max( wallDist - 24.0, 0.0 )
	if ( !IsColumnClear( bot, column, right, probeHeight ) )
		return null

	local above = origin + Vector( 0, 0, probeHeight )
	local nearTop = FindRoofSurface( bot, above, dir, wallDist + 56.0, probeHeight )
	if ( nearTop == null )
		return null
	local height = nearTop.z - origin.z
	if ( height < BOT_CLIMB_MIN_HEIGHT || height > BOT_CLIMB_WALLRUN_MAX_HEIGHT )
		return null

	// A real roof goes on past the edge at the same height; a lip, a ledge or the top of a
	// slanted panel doesn't.
	local farTop = FindRoofSurface( bot, above, dir, wallDist + 150.0, probeHeight )
	if ( farTop == null || fabs( farTop.z - nearTop.z ) > 32.0 )
		return null

	// Low enough to jump straight up to the edge.
	if ( height <= BOT_CLIMB_MAX_HEIGHT )
		return { z = nearTop.z, wall = wallPoint, along = null, alt = null, face = dir }

	// Higher: needs a wallrun up the face first, so there must be room to run along the wall
	// on one side, with clear air above that stretch too. Along the face itself (its normal), not
	// along the probe direction, which can be well off it.
	local face = fabs( wall.surfaceNormal.z ) < 0.3 ? Normalize2D( wall.surfaceNormal ) * -1.0 : dir
	local faceRight = Vector( face.y, -face.x, 0 )
	local runStart = chest + dir * max( wallDist - 40.0, 0.0 )
	local sides = []
	foreach ( side in [ faceRight, faceRight * -1.0 ] )
	{
		if ( !HasClearLine( bot, runStart, runStart + side * BOT_CLIMB_WALLRUN_LENGTH ) )
			continue
		local runColumn = column + side * ( BOT_CLIMB_WALLRUN_LENGTH * 0.6 )
		if ( !IsColumnClear( bot, runColumn, faceRight, probeHeight ) )
			continue
		// The wall must actually continue along that stretch to run on.
		local alongWall = runStart + side * ( BOT_CLIMB_WALLRUN_LENGTH * 0.6 )
		if ( HasClearLine( bot, alongWall, alongWall + face * 80.0 ) )
			continue
		sides.append( side )
	}
	if ( sides.len() == 0 )
		return null
	// Both sides work: the other one is the second try if the first fails (see UpdateClimb).
	return { z = nearTop.z, wall = wallPoint, along = sides[0], alt = sides.len() > 1 ? sides[1] : null, face = face }
}

// Clear air from waist height up to `height` above base, across the pilot's width.
function IsColumnClear( bot, base, right, height )
{
	foreach ( offset in [ Vector( 0, 0, 0 ), right * BOT_WHISKER_OFFSET, right * -BOT_WHISKER_OFFSET ] )
	{
		local point = base + offset
		if ( !HasClearLine( bot, point + Vector( 0, 0, 40 ), point + Vector( 0, 0, height ) ) )
			return false
	}
	return true
}

// Walkable surface below the point `ahead` units along dir at the probe height, with standing
// room on it; null if there is none (or the air on the way there is blocked).
function FindRoofSurface( bot, above, dir, ahead, probeHeight )
{
	local probe = above + dir * ahead
	if ( TraceLine( above, probe, bot, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE ).fraction < 1.0 )
		return null
	local down = TraceLine( probe, probe - Vector( 0, 0, probeHeight + 32.0 ), bot, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE )
	if ( down.fraction >= 1.0 || down.startSolid || down.surfaceNormal.z < 0.7 )
		return null
	if ( TraceLine( down.endPos + Vector( 0, 0, 8 ), down.endPos + Vector( 0, 0, 80 ), bot, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE ).fraction < 1.0 )
		return null
	return down.endPos
}

// Walls a bot already failed to climb, shared by the whole team so nobody else tries them.
function IsBadClimbSpot( pos )
{
	foreach ( spot in file.badClimbSpots )
	{
		if ( Distance( spot, pos ) < BOT_BAD_CLIMB_RADIUS )
			return true
	}
	return false
}

function MarkBadClimbSpot( pos )
{
	file.badClimbSpots.append( pos )
	if ( file.badClimbSpots.len() > 64 )
		file.badClimbSpots.remove( 0 )
}

// Climbing a building, the way a player does it. Direct (low roof): sprint at the wall, jump
// when close, double jump near the top and keep pushing forward so the mantle takes us over
// the edge. Wallrun (higher roof): come in at an angle so we land on the wall running along it,
// ride it up for a moment, kick off towards the roof, then double jump onto the edge.
// Looks for chances while travelling; high-style bots take them, others as often as their
// roofLove says (see WantsClimb), and every bot on its way to an evac launch point.
// Returns buttons to press; brain.climbUntil > now while a climb is on, and
// brain.climbMoveDir is the direction to move in.
function UpdateClimb( bot, brain, moveDir, forward )
{
	local now = Time()
	local origin = bot.GetOrigin()

	if ( brain.climbUntil > 0.0 )
	{
		// (IsOnGround can be true on a wall: on foot = on the ground and not wallrunning.)
		local wallRunning = bot.IsWallRunning()
		local onFoot = bot.IsOnGround() && !wallRunning
		local onTop = onFoot && origin.z >= brain.climbTopZ - 24.0
		// No height gained a while after the first jump, or never got to jump at all: this wall
		// can't be climbed, give up early. (Counted from the jump: the run-up takes its time.)
		local noProgress = ( brain.climbJumpTime > 0.0 && now - brain.climbJumpTime > BOT_CLIMB_PROGRESS_TIME && origin.z - brain.climbStartZ < 40.0 )
			|| ( brain.climbJumpTime == 0.0 && now - brain.climbStart > BOT_CLIMB_APPROACH_TIME )
		if ( onTop || noProgress || now > brain.climbUntil )
		{
			local wasLedge = brain.climbIsLedge
			brain.climbIsLedge = false
			brain.climbUntil = 0.0
			brain.nextRepathTime = 0.0
			if ( wasLedge )
			{
				// A ledge on the way: no fuss either way, just don't try that one again.
				if ( !onTop )
					MarkBadClimbSpot( brain.climbWall )
				brain.nextLedgeCheck = now + ( onTop ? BOT_LEDGE_CHECK_INTERVAL : 1.0 )
				return 0
			}
			if ( onTop )
			{
				printt( "BotAI:", bot.GetPlayerName(), "climbed onto a roof", brain.climbAlong != null ? "(wallrun)" : "(jump)" )
			}
			else if ( brain.climbAlong != null && brain.climbAltAlong != null && brain.climbTries < 1 )
			{
				// A wallrun climb that didn't work one way: run up the face the other way first.
				brain.climbAlong = brain.climbAltAlong
				brain.climbAltAlong = null
				brain.climbTries++
				brain.climbStart = now
				brain.climbStartZ = origin.z
				brain.climbJumpTime = 0.0
				brain.climbKicked = false
				brain.climbWallrunStart = 0.0
				brain.climbUntil = now + BOT_CLIMB_TIMEOUT
				printt( "BotAI:", bot.GetPlayerName(), "retrying the climb from the other side" )
				return 0
			}
			else
			{
				MarkBadClimbSpot( brain.climbWall )
				printt( "BotAI:", bot.GetPlayerName(), "couldn't climb, marking the spot" )
				// Can't get up the outside: go in and take the stairs.
				TryGoUpstairs( bot, brain, brain.climbWall )
			}
			brain.nextClimbCheck = now + BOT_CLIMB_RETRY
			return 0
		}

		local chest = origin + Vector( 0, 0, 40 )

		// Wallrun climb, on the wall (checked first: IsOnGround can be true up there too).
		if ( brain.climbAlong != null && wallRunning )
		{
			brain.usedDoubleJump = false	// touching the wall gives the double jump back
			if ( brain.climbWallrunStart == 0.0 )
				brain.climbWallrunStart = now
			// Keep running along the face, leaning into it.
			brain.climbMoveDir = brain.climbAlong + brain.climbDir * 0.5
			// Peak of the run (stopped rising after a moment on the wall, or ridden long enough):
			// kick off up and towards the roof.
			local ride = now - brain.climbWallrunStart
			if ( ( ride > BOT_CLIMB_WALLRUN_MIN_TIME && bot.GetVelocity().z < 40.0 ) || ride > BOT_CLIMB_WALLRUN_TIME )
			{
				brain.climbKicked = true
				brain.climbMoveDir = Normalize2D( brain.climbAlong * 0.4 + brain.climbDir )
				return BOT_IN_JUMP
			}
			return 0
		}

		if ( onFoot )
		{
			brain.usedDoubleJump = false
			brain.climbKicked = false
			brain.climbWallrunStart = 0.0
			local jump = false
			if ( brain.climbAlong != null )
			{
				// Wallrun climb: come in at the face at an angle and jump from the right distance
				// to land on it running. Too close to it for that: back off along it for a run-up.
				// (Once backing off, back off twice as far, so the run in has room to build up speed;
				// once running in, carry on to the jump: it comes before we're at the face.)
				local lateral = Dot2D( brain.climbWall - chest, brain.climbDir )
				local backingOff = Dot2D( brain.climbMoveDir, brain.climbDir ) < 0.0
				local runningIn = !backingOff && Dot2D( bot.GetVelocity(), brain.climbDir ) > 60.0
				local jumpDist = WallrunJumpDist( bot, brain.climbDir )
				if ( brain.climbJumpTime == 0.0 && !runningIn && lateral < ( backingOff ? BOT_CLIMB_RUNUP_MIN * 2.0 : BOT_CLIMB_RUNUP_MIN ) )
					brain.climbMoveDir = Normalize2D( brain.climbAlong - brain.climbDir * 0.7 )
				else
				{
					local angle = ( lateral > BOT_WR_FAR_LATERAL ? 40.0 : 30.0 ) * ( PI / 180.0 )
					brain.climbMoveDir = brain.climbAlong * cos( angle ) + brain.climbDir * sin( angle )
					jump = lateral <= jumpDist
				}
			}
			else
				jump = !HasClearLine( bot, chest, chest + brain.climbDir * 170.0 )
			if ( !jump )
				return 0
			if ( brain.climbJumpTime == 0.0 )
			{
				brain.climbJumpTime = now
				brain.climbUntil = max( brain.climbUntil, now + BOT_CLIMB_TIMEOUT - 1.0 )
			}
			return BOT_IN_JUMP
		}

		// Direct climb: double jump near the top of the first jump.
		if ( brain.climbAlong == null )
		{
			if ( !brain.usedDoubleJump && bot.GetVelocity().z < 120.0 )
			{
				brain.usedDoubleJump = true
				return BOT_IN_JUMP
			}
			return 0
		}

		// Wallrun climb, in the air.
		if ( brain.climbKicked )
		{
			// Off the wall: double jump onto the edge.
			brain.climbMoveDir = brain.climbDir
			if ( !brain.usedDoubleJump && bot.GetVelocity().z < 100.0 )
			{
				brain.usedDoubleJump = true
				return BOT_IN_JUMP
			}
		}
		return 0
	}

	// Running along a wall with a ledge up beside it that the route / target is on (or that a planned
	// wallrun went up the wall for): kick off onto it.
	if ( bot.IsWallRunning() && now >= brain.nextWallLedgeCheck )
	{
		brain.nextWallLedgeCheck = now + BOT_LEDGE_WALLRUN_CHECK
		if ( ( WantsHigherGround( bot, brain ) || brain.wrReason == "up" ) && TryStartWallrunLedge( bot, brain ) )
			return 0
	}

	// A ledge right ahead and the way on (route, chased target) is up there: mantle onto it.
	if ( now >= brain.nextLedgeCheck && moveDir != null && forward > 0.5 && !brain.careful && BotOnFoot( bot ) )
	{
		brain.nextLedgeCheck = now + BOT_LEDGE_CHECK_INTERVAL
		if ( WantsHigherGround( bot, brain ) && TryStartLedgeMantle( bot, brain, Normalize2D( moveDir ) ) )
			return 0
	}

	// On the way to an evac launch point (see UpdateEvacLaunch), or repositioning to a point up
	// high, every climb is taken, checked twice as often.
	local evacClimb = ( brain.evac != null && "climb" in brain.evac && brain.evac.climb ) || IsRepositioningUp( bot, brain )
	if ( now < brain.nextClimbCheck || moveDir == null || forward < 0.7 || brain.careful || !BotOnFoot( bot ) || brain.offGraph )
		return 0
	brain.nextClimbCheck = now + ( evacClimb ? BOT_CLIMB_CHECK_INTERVAL * 0.5 : BOT_CLIMB_CHECK_INTERVAL )
	// On the evac run roofs are only climbed for a launch point (evac.climb), never for the view.
	if ( !evacClimb && brain.evac != null )
		return 0
	if ( !evacClimb && !WantsClimb( brain ) )
		return 0

	local length = max( Length2D( moveDir ), 1.0 )
	local ahead = Vector( moveDir.x / length, moveDir.y / length, 0 )
	local right = Vector( ahead.y, -ahead.x, 0 )
	// Only roofs that lie the way we're going (straight ahead or slightly off): a climb that
	// takes us sideways off the route is a detour that rarely pays off.
	local dirs = [ ahead, ( ahead * 0.92 + right * 0.38 ), ( ahead * 0.92 - right * 0.38 ) ]
	foreach ( dir in dirs )
	{
		local top = FindClimbableRoof( bot, dir )
		if ( top == null )
			continue
		// Wallrun climbs work off the wall face itself (straight into it), not the probe direction.
		brain.climbDir = ( top.face != null && top.along != null ) ? top.face : dir
		brain.climbAlong = top.along
		brain.climbAltAlong = top.alt
		brain.climbTries = 0
		brain.climbJumpTime = 0.0
		// Wallrun climbs come in at an angle so we land on the wall running along it.
		brain.climbMoveDir = top.along != null ? brain.climbDir * 0.5 + top.along * 0.87 : dir
		brain.climbKicked = false
		brain.climbWallrunStart = 0.0
		brain.climbTopZ = top.z
		brain.climbWall = top.wall
		brain.climbStart = now
		brain.climbStartZ = origin.z
		brain.climbUntil = now + BOT_CLIMB_TIMEOUT
		brain.climbIsLedge = false
		return 0
	}

	// A wall ahead with no climbable roof on it: sometimes go in and up the stairs instead.
	if ( !evacClimb && RandomInt( 100 ) < BOT_STAIRS_CHANCE )
	{
		local chest = origin + Vector( 0, 0, 40 )
		local wall = TraceLine( chest, chest + ahead * BOT_CLIMB_WALL_DIST, bot, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE )
		if ( wall.fraction < 1.0 )
			TryGoUpstairs( bot, brain, wall.endPos )
	}
	return 0
}

// Is the way on above us? The next waypoint of the route, a nearby goal up high (a reposition or
// flank point on a ledge, a roof), or the target we're chasing.
function WantsHigherGround( bot, brain )
{
	local origin = bot.GetOrigin()
	local z = origin.z
	if ( brain.pathIndex < brain.path.len() && brain.path[ brain.pathIndex ].z - z > BOT_LEDGE_UP_DIST )
		return true
	if ( brain.pathGoal != null && brain.pathGoal.z - z > BOT_LEDGE_UP_DIST && Length2D( brain.pathGoal - origin ) < BOT_LEDGE_GOAL_DIST )
		return true
	if ( IsRepositioningUp( bot, brain ) )
		return true
	return brain.target != null && IsValid( brain.target ) && brain.targetLastSeenPos != null
		&& brain.targetLastSeenPos.z - z > BOT_LEDGE_UP_DIST
}

// Repositioning (a new angle on a fight) to a point above us: every way up on the route is taken.
function IsRepositioningUp( bot, brain )
{
	// Running for the evac ship: any reposition left over from before doesn't count.
	if ( brain.evac != null )
		return false
	return Time() < brain.repositionUntil && brain.repositionPoint != null
		&& brain.repositionPoint.z - bot.GetOrigin().z > BOT_LEDGE_UP_DIST
}

// A ledge in direction dir we can get onto with a jump, a double jump and the mantle: a face close
// ahead, a walkable top with standing room within BOT_CLIMB_MAX_HEIGHT, and clear air above us on
// the way up. Starts it as a short direct climb (UpdateClimb runs it). True if started.
function TryStartLedgeMantle( bot, brain, dir )
{
	if ( dir == null || Length2D( dir ) < 0.5 || brain.climbUntil > 0.0 )
		return false
	local origin = bot.GetOrigin()
	local knee = origin + Vector( 0, 0, 20 )
	local face = TraceLine( knee, knee + dir * BOT_LEDGE_WALL_DIST, bot, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE )
	if ( face.fraction >= 1.0 || face.startSolid )
		return false
	local faceDist = BOT_LEDGE_WALL_DIST * face.fraction
	local facePoint = knee + dir * faceDist
	if ( IsBadClimbSpot( facePoint ) )
		return false

	local probeHeight = BOT_CLIMB_MAX_HEIGHT + 72.0
	local right = Vector( dir.y, -dir.x, 0 )
	if ( !IsColumnClear( bot, origin + dir * max( faceDist - 24.0, 0.0 ), right, probeHeight ) )
		return false
	local top = FindRoofSurface( bot, origin + Vector( 0, 0, probeHeight ), dir, faceDist + 40.0, probeHeight )
	if ( top == null )
		return false
	local height = top.z - origin.z
	if ( height < BOT_LEDGE_MIN_HEIGHT || height > BOT_CLIMB_MAX_HEIGHT )
		return false
	if ( IsVoidAt( bot, top ) )
		return false

	StartLedgeClimb( bot, brain, dir, null, top.z, facePoint )
	return true
}

// Wallrunning: a top up beside the wall (the side the wall is on) within reach. Kick off the wall
// towards it next tick, then double jump and mantle (UpdateClimb's wallrun climb). True if started.
function TryStartWallrunLedge( bot, brain )
{
	if ( brain.climbUntil > 0.0 )
		return false
	local origin = bot.GetOrigin()
	local along = Normalize2D( bot.GetVelocity() )
	if ( Length2D( along ) < 0.5 )
		return false
	local right = Vector( along.y, -along.x, 0 )
	local chest = origin + Vector( 0, 0, 40 )
	foreach ( side in [ right, right * -1.0 ] )
	{
		local wall = TraceLine( chest, chest + side * 64.0, bot, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE )
		if ( wall.fraction >= 1.0 )
			continue
		local probeHeight = BOT_LEDGE_WALLRUN_REACH + 72.0
		local top = FindRoofSurface( bot, origin + Vector( 0, 0, probeHeight ), side, 64.0 * wall.fraction + 48.0, probeHeight )
		if ( top == null || top.z - origin.z < BOT_LEDGE_MIN_HEIGHT || top.z - origin.z > BOT_LEDGE_WALLRUN_REACH || IsVoidAt( bot, top ) )
			continue
		StartLedgeClimb( bot, brain, side, along, top.z, chest + side * ( 64.0 * wall.fraction ) )
		// Already on the wall: kick off on the next tick.
		brain.climbWallrunStart = Time() - BOT_CLIMB_WALLRUN_TIME
		return true
	}
	return false
}

function StartLedgeClimb( bot, brain, dir, along, topZ, wallPoint )
{
	local now = Time()
	brain.climbDir = dir
	brain.climbAlong = along
	brain.climbMoveDir = along != null ? along + dir * 0.5 : dir
	brain.climbKicked = false
	brain.climbWallrunStart = 0.0
	brain.climbTopZ = topZ
	brain.climbWall = wallPoint
	brain.climbStart = now
	brain.climbStartZ = bot.GetOrigin().z
	brain.climbUntil = now + BOT_LEDGE_TIMEOUT
	brain.climbIsLedge = true
	brain.climbJumpTime = now	// (a ledge is right there: no run-up, the progress check runs from now)
	brain.climbAltAlong = null
}

// Up through the building next to `near`: the best upper-floor / roof node around it (high above
// us, close to the wall) becomes the goal, and the node graph takes us there by the stairs inside.
// True if one was found.
function TryGoUpstairs( bot, brain, near )
{
	local now = Time()
	// (Never on the evac run: the ship is the only place to go.)
	if ( near == null || brain.upstairsGoal != null || now < brain.nextUpstairsTime || brain.evac != null )
		return false
	local nav = GetNavCache()
	if ( nav.positions.len() == 0 )
		return false

	local origin = bot.GetOrigin()
	local best = null
	local bestScore = 0.0
	for ( local dx = -1; dx <= 1; dx++ )
	{
		for ( local dy = -1; dy <= 1; dy++ )
		{
			local key = NavCellKey( near.x + dx * BOT_NAV_CELL, near.y + dy * BOT_NAV_CELL )
			if ( !( key in nav.cells ) )
				continue
			foreach ( index in nav.cells[ key ] )
			{
				local pos = nav.positions[ index ]
				if ( pos.z - origin.z < BOT_STAIRS_MIN_RISE || nav.elevation[ index ] < BOT_VANTAGE_MIN_ELEVATION )
					continue
				local flat = Length2D( pos - near )
				if ( flat > BOT_STAIRS_SEARCH_RADIUS )
					continue
				local score = nav.elevation[ index ] * 0.5 - flat
				if ( best == null || score > bestScore )
				{
					best = pos
					bestScore = score
				}
			}
		}
	}
	brain.nextUpstairsTime = now + BOT_STAIRS_COOLDOWN
	if ( best == null )
		return false

	brain.upstairsGoal = best
	brain.upstairsUntil = now + BOT_STAIRS_TIMEOUT
	brain.nextRepathTime = 0.0
	printt( "BotAI:", bot.GetPlayerName(), "going inside to take the stairs up" )
	return true
}

// Upstairs, heading somewhere well below and far away: if there's an opening that way (a window,
// a balcony, a roof edge) with floor some way down beyond it, run and jump out of it rather than
// walk back down the stairs. Returns buttons to press; brain.windowExitUntil > now while it's on.
function UpdateWindowExit( bot, brain )
{
	local now = Time()
	local origin = bot.GetOrigin()
	if ( brain.windowExitUntil > 0.0 )
	{
		// Landed (or ran out of time): back to the route from down here.
		if ( now > brain.windowExitUntil || ( BotOnFoot( bot ) && now - brain.windowExitStart > 0.4 ) )
		{
			brain.windowExitUntil = 0.0
			brain.nextRepathTime = 0.0
			// Still on the same floor: the way out didn't take us (a frame, glass, bars). Nobody tries
			// that opening again, and this bot leaves windows alone for a while and takes the stairs.
			if ( origin.z > brain.windowStartZ - BOT_WINDOW_MIN_DROP * 0.5 )
			{
				MarkBadClimbSpot( brain.windowSpot )
				brain.nextWindowCheck = now + BOT_WINDOW_FAIL_COOLDOWN
				printt( "BotAI:", bot.GetPlayerName(), "couldn't get out that way, marking it" )
			}
		}
		return 0
	}

	if ( now < brain.nextWindowCheck || !BotOnFoot( bot ) || brain.pathGoal == null )
		return 0
	brain.nextWindowCheck = now + BOT_WINDOW_CHECK_INTERVAL
	local toGoal = brain.pathGoal - origin
	local flat = Length2D( toGoal )
	if ( flat < BOT_WINDOW_MIN_GOAL_DIST || toGoal.z > -BOT_WINDOW_MIN_GOAL_DROP )
		return 0

	local dir = Vector( toGoal.x / flat, toGoal.y / flat, 0 )
	local right = Vector( dir.y, -dir.x, 0 )
	foreach ( probeDir in [ dir, ( dir * 0.85 + right * 0.53 ), ( dir * 0.85 - right * 0.53 ) ] )
	{
		local d = Normalize2D( probeDir )
		local spot = origin + d * ( BOT_WINDOW_AHEAD * 0.5 )
		if ( IsBadClimbSpot( spot ) )
			continue
		// The whole body has to fit through, at the height of the jump over the sill, against
		// everything a player bumps into (glass, bars, window frames and props, not just brushes).
		local lift = origin + Vector( 0, 0, BOT_WINDOW_JUMP_LIFT )
		local body = TraceHull( lift, lift + d * BOT_WINDOW_AHEAD, bot.GetPlayerMins(), bot.GetPlayerMaxs(), bot, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER )
		if ( body.startSolid || body.fraction < 1.0 )
			continue
		local beyond = origin + d * BOT_WINDOW_AHEAD + Vector( 0, 0, 16 )
		local land = TraceLine( beyond, beyond - Vector( 0, 0, BOT_WINDOW_MAX_DROP ), bot, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE )
		if ( land.fraction >= 1.0 || land.startSolid || land.surfaceNormal.z < 0.7 )
			continue
		if ( origin.z - land.endPos.z < BOT_WINDOW_MIN_DROP )
			continue

		brain.windowExitDir = d
		brain.windowStartZ = origin.z
		brain.windowSpot = spot
		brain.windowExitStart = now
		brain.windowExitUntil = now + BOT_WINDOW_EXIT_TIME
		printt( "BotAI:", bot.GetPlayerName(), "jumping out", origin.z - land.endPos.z, "units down" )
		return BOT_IN_JUMP
	}
	return 0
}

// Take this climb chance? Always for high-style bots, otherwise more often the more the bot
// likes rooftops.
function WantsClimb( brain )
{
	if ( brain.routeStyle == "high" )
		return true
	return RandomInt( 100 ) < BOT_CLIMB_CHANCE_OTHERS + brain.roofLove * BOT_CLIMB_CHANCE_ROOF_LOVE
}

function HasClearLine( bot, from, to )
{
	return TraceLine( from, to, bot, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE ).fraction >= 1.0
}

// Doorway centering: one ray along each side of the body towards the waypoint. If only one
// side would scrape something (a door frame, a corner), steer away from that side. World-space
// push, or null.
function GetWhiskerNudge( bot, moveDir )
{
	local length = Length2D( moveDir )
	if ( length < 1.0 )
		return null
	local dir = Vector( moveDir.x / length, moveDir.y / length, 0 )
	local right = Vector( dir.y, -dir.x, 0 )
	local start = bot.GetOrigin() + Vector( 0, 0, 36 )
	local reach = dir * min( length, BOT_WHISKER_LENGTH )
	local rightBlocked = !HasClearLine( bot, start + right * BOT_WHISKER_OFFSET, start + right * BOT_WHISKER_OFFSET + reach )
	local leftBlocked = !HasClearLine( bot, start - right * BOT_WHISKER_OFFSET, start - right * BOT_WHISKER_OFFSET + reach )
	if ( rightBlocked == leftBlocked )
		return null
	return right * ( rightBlocked ? -BOT_WHISKER_STRENGTH : BOT_WHISKER_STRENGTH )
}

// Gap ahead (roof edge, ledge over a drop) while running: true if there's no floor within
// BOT_GAP_DROP `ahead` units on in the direction of travel.
function IsGapAhead( bot, dir, ahead = BOT_GAP_CHECK_AHEAD )
{
	local length = Length2D( dir )
	if ( length < 1.0 )
		return false
	local start = bot.GetOrigin() + Vector( dir.x / length, dir.y / length, 0 ) * ahead + Vector( 0, 0, 16 )
	return TraceLine( start, start - Vector( 0, 0, BOT_GAP_DROP + 16.0 ), bot, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE ).fraction >= 1.0
}

function StartVantageHold( brain )
{
	brain.holdUntil = Time() + RandomFloat( BOT_VANTAGE_HOLD_MIN, BOT_VANTAGE_HOLD_MAX )
	brain.holdRoam = false		// a lead-based hold: ends when the lead does
	brain.nextHoldLook = 0.0
	printt( "BotAI: holding a high point" )
}


function GetRandomRoamPoint( bot )
{
	local yaw = RandomFloat( -PI, PI )
	return bot.GetOrigin() + Vector( cos( yaw ) * BOT_NO_NAV_ROAM_DIST, sin( yaw ) * BOT_NO_NAV_ROAM_DIST, 0 )
}

// Roam the whole map with no lead on anyone: prefer far nodes we haven't been to lately and
// that no teammate is already heading for, so the team sweeps the map and runs into enemies.
// Elevated spots score higher for every bot, by its roofLove (fully for high-style bots), with a
// flat bonus for real vantage heights; indoor-style bots like covered ones. Records the chosen
// goal's height in brain.patrolElevation (see the roof hold in ChooseGoal).
function ChooseExploreGoal( bot, brain )
{
	local nav = GetNavCache()
	local nodeCount = nav.positions.len()
	local origin = bot.GetOrigin()
	local mates = GetTeammateBrains( bot )
	local best = null
	local bestScore = -1.0
	local bestElevation = 0.0
	local heightWeight = brain.routeStyle == "high" ? 1.0 : brain.roofLove
	local candidates = BOT_EXPLORE_CANDIDATES + ( brain.roofLove >= 0.5 ? BOT_ROOF_EXTRA_CANDIDATES : 0 )
	for ( local i = 0; i < candidates; i++ )
	{
		local index = RandomInt( nodeCount )
		local pos = nav.positions[ index ]
		local score = min( Distance( origin, pos ), BOT_EXPLORE_FAR_DIST )
		if ( WasVisited( brain, pos ) )
			score *= 0.2
		foreach ( mate in mates )
		{
			if ( mate.brain.patrolGoal != null && Distance( mate.brain.patrolGoal, pos ) < BOT_EXPLORE_MATE_DIST )
				score *= 0.4
		}
		local elevation = nav.elevation[ index ]
		score += min( elevation, BOT_HIGH_ELEVATION_MAX ) * BOT_HIGH_ELEVATION_BONUS * heightWeight
		if ( elevation >= BOT_VANTAGE_MIN_ELEVATION )
			score += BOT_ROOF_GOAL_BONUS * brain.roofLove
		// Pilots: up where a wallrun (or a wallrun climb) gets us, worth going for, by taste.
		if ( !bot.IsTitan() && elevation >= BOT_CLIMB_MIN_HEIGHT && elevation <= BOT_CLIMB_WALLRUN_MAX_HEIGHT )
			score += BOT_WR_REACH_BONUS * brain.wallLove * WallrunStyleFactor( brain )
		if ( brain.routeStyle == "indoor" && i < 3 && IsNodeIndoor( nav, index ) )
			score += BOT_INDOOR_ROUTE_BONUS
		score += RandomFloat( 0.0, 800.0 )

		if ( score > bestScore )
		{
			best = pos
			bestScore = score
			bestElevation = elevation
		}
	}
	brain.patrolElevation = bestElevation
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
	// Mid-wallrun the timed repath would restart the path (and turn the view) halfway along the
	// wall: it waits until we're down again (ResetWallrunPlan repaths then), unless the goal moved.
	if ( needsRepath && ( brain.wrPhase == "run" || brain.wrPhase == "air" || brain.wrPhase == "kick" )
		&& Time() - brain.wrLastTick <= BOT_WR_STALE && brain.pathGoal != null && Distance( goal, brain.pathGoal ) <= BOT_GOAL_REPATH_DIST && brain.pathIndex < brain.path.len() )
		needsRepath = false

	if ( needsRepath )
		BuildPath( bot, brain, goal, isTitan )

	local reached = isTitan ? BOT_TITAN_NODE_REACHED : ( brain.careful ? BOT_CAREFUL_NODE_REACHED : BOT_PILOT_NODE_REACHED )
	// Backtracking to a waypoint: walk all the way onto it before moving on.
	if ( Time() < brain.backtrackUntil )
		reached = BOT_BACKTRACK_NODE_REACHED
	// Titans: the wide radius must not count a waypoint on the floor above or below (switchback
	// stairs) as reached, or the titan cuts the corner into the wall.
	while ( brain.pathIndex < brain.path.len() && Distance2D( origin, brain.path[ brain.pathIndex ] ) < reached
		&& ( !isTitan || fabs( brain.path[ brain.pathIndex ].z - origin.z ) < BOT_TITAN_NODE_REACH_Z ) )
	{
		brain.pathIndex++
		brain.backtrackUntil = 0.0
	}

	// Lost the line to the next waypoint (pushed past a door frame or a corner): go back to the
	// previous one, which we can still see, instead of grinding along the wall.
	if ( !isTitan && brain.pathIndex > 0 && brain.pathIndex < brain.path.len() && Time() > brain.nextLosCheck && BotOnFoot( bot ) && brain.wrPhase == "none" )
	{
		brain.nextLosCheck = Time() + BOT_LOS_CHECK_INTERVAL
		local waist = Vector( 0, 0, 36 )
		local nextPos = brain.path[ brain.pathIndex ]
		local prevPos = brain.path[ brain.pathIndex - 1 ]
		if ( !HasClearLine( bot, origin + waist, nextPos + waist ) && HasClearLine( bot, origin + waist, prevPos + waist )
			&& Distance2D( origin, prevPos ) > BOT_BACKTRACK_NODE_REACHED )
		{
			brain.pathIndex--
			brain.backtrackUntil = Time() + BOT_BACKTRACK_TIME
		}
	}

	// Up on a roof (or anything the node graph doesn't cover): the path's next node is somewhere
	// far below. Run straight at the goal across the roofs instead; edges are leapt by the
	// parkour code, and getting stuck up there hands control back to the path for a while.
	brain.offGraph = false
	if ( !isTitan && brain.path.len() > 0 && Time() > brain.offGraphBlockedUntil && BotOnFoot( bot ) )
	{
		local next = brain.path[ brain.pathIndex < brain.path.len() ? brain.pathIndex : brain.path.len() - 1 ]
		if ( origin.z - next.z > BOT_OFFGRAPH_HEIGHT && Length2D( next - origin ) < 900.0 )
		{
			local toGoal = goal - origin
			// Straight at the goal only over solid ground: the space between "up here" and the goal
			// can be the void off the edge of the map (spawn platforms above the graph, War Games).
			if ( Length2D( toGoal ) >= 1.0 && !IsVoidAt( bot, origin + Normalize2D( toGoal ) * BOT_VOID_AHEAD ) )
			{
				brain.offGraph = true
				return toGoal
			}
			brain.offGraphBlockedUntil = Time() + BOT_OFFGRAPH_BLOCK_TIME
		}
	}

	local waypoint = brain.pathIndex < brain.path.len() ? brain.path[ brain.pathIndex ] : goal
	local dir = waypoint - origin
	if ( Length2D( dir ) < 1.0 )
		return null
	return dir
}

function BuildPath( bot, brain, goal, isTitan )
{
	local origin = bot.GetOrigin()
	local flat = null
	if ( isTitan )
		flat = BuildTitanPath( origin, goal )
	// Pilots: skip NPC traverse links a pilot can't follow (wall climbs, very long jumps), which
	// otherwise send bots jumping at buildings forever. Needs a DLL with NavFindPathPilot.
	else if ( file.hasPilotNav )
		flat = NavFindPathPilot( origin.x, origin.y, origin.z, goal.x, goal.y, goal.z, BOT_HULL_PILOT, BOT_PILOT_MAX_RISE, BOT_PILOT_MAX_GAP )
	else
		flat = NavFindPath( origin.x, origin.y, origin.z, goal.x, goal.y, goal.z, BOT_HULL_PILOT )

	brain.path = []
	for ( local i = 0; i + 2 < flat.len(); i += 3 )
		brain.path.append( Vector( flat[i], flat[i + 1], flat[i + 2] ) )

	brain.pathIndex = 0
	brain.pathGoal = goal
	brain.nextRepathTime = Time() + BOT_REPATH_INTERVAL
}

// Titan route, flat [x, y, z, ...]: on the titan-sized hull first (where the map's graph has
// links for it), then on the human hull without the NPC climbs and long jumps a titan can't take,
// then on the plain human graph. A titan hull that hardly ever finds a path on this map (the
// graph has no links for it) is dropped for the rest of the map.
function BuildTitanPath( origin, goal )
{
	if ( file.titanHull != null )
	{
		local flat = TitanFindPath( origin, goal, file.titanHull )
		file.titanHullTries++
		if ( flat.len() >= 3 )
		{
			file.titanHullHits++
			return flat
		}
		if ( file.titanHullTries >= 12 && file.titanHullHits < 3 )
		{
			printt( "BotAI: titan hull", file.titanHull, "found", file.titanHullHits, "paths in", file.titanHullTries, "tries, titans use the human graph on this map" )
			file.titanHull = null
		}
	}

	local flat = TitanFindPath( origin, goal, BOT_HULL_TITAN )
	if ( flat.len() >= 3 || !file.hasPilotNav )
		return flat
	return NavFindPath( origin.x, origin.y, origin.z, goal.x, goal.y, goal.z, BOT_HULL_TITAN )
}

// One titan path query on a hull, limited to traverse links a titan can follow when the DLL can.
function TitanFindPath( origin, goal, hull )
{
	if ( file.hasPilotNav )
		return NavFindPathPilot( origin.x, origin.y, origin.z, goal.x, goal.y, goal.z, hull, BOT_TITAN_MAX_RISE, BOT_TITAN_MAX_GAP )
	return NavFindPath( origin.x, origin.y, origin.z, goal.x, goal.y, goal.z, hull )
}

// Careful mode (see BOT_DOOR_APPROACH_DIST): indoors, approaching a roofed waypoint, or shortly
// after being stuck. Roof checks are cached per waypoint and throttled for the bot itself.
function UpdateCarefulMode( bot, brain )
{
	local now = Time()
	if ( now > brain.nextIndoorCheck )
	{
		brain.nextIndoorCheck = now + BOT_INDOOR_CHECK_INTERVAL
		brain.indoors = IsUnderRoof( bot.GetOrigin() )
	}

	local index = brain.pathIndex
	if ( brain.roofCheckPath != brain.path || brain.roofCheckIndex != index )
	{
		brain.roofCheckPath = brain.path
		brain.roofCheckIndex = index
		brain.waypointIndoor = false
		for ( local i = index; i < brain.path.len() && i <= index + 1; i++ )
		{
			if ( IsUnderRoof( brain.path[ i ] ) )
			{
				brain.waypointIndoor = true
				break
			}
		}
	}

	local doorAhead = brain.waypointIndoor && index < brain.path.len()
		&& Distance( bot.GetOrigin(), brain.path[ index ] ) < BOT_DOOR_APPROACH_DIST
	brain.careful = now < brain.carefulUntil || brain.indoors || doorAhead
}

// Stuck is either standing still (blocked) or bouncing around without getting any closer to
// the next waypoint (hopping at a wall beside a door). Each repeat within a few seconds
// escalates: hop and re-path, then back off at an angle, then drop the waypoint and the goal.
function UpdateStuck( bot, brain, moveDir, forward, side, travelling )
{
	local now = Time()
	local origin = bot.GetOrigin()
	local isTitan = bot.IsTitan()

	// In a synced animation (execution, embark, hatch): standing still there isn't being stuck.
	if ( bot.ContextAction_IsActive() )
	{
		brain.lastProgressPos = origin
		brain.lastProgressTime = now
		brain.wpProgressIndex = -1
		return
	}

	// On a wall we're moving (a wallrun detours from the route on purpose): the checks start over
	// once we're off it.
	if ( bot.IsWallRunning() )
	{
		brain.lastProgressPos = origin
		brain.lastProgressTime = now
		brain.wpProgressIndex = -1
		return
	}

	// Titans also check in a fight (the fight movement has no route behind it, so moveDir may be null);
	// but pushing into the target itself (a brawl, punching a pilot) or turning on a rider isn't stuck.
	local titanBrawl = isTitan && !travelling && ( brain.swatting || ( brain.target != null && IsValid( brain.target )
		&& Time() - brain.targetLastSeenTime < 0.5 && Distance2D( origin, brain.target.GetOrigin() ) < BOT_TITAN_STUCK_IGNORE_DIST ) )
	local wantsToMove = ( moveDir != null || isTitan ) && !titanBrawl && ( fabs( forward ) > 0.1 || fabs( side ) > 0.1 )
	local stuck = false

	if ( !wantsToMove || Distance( origin, brain.lastProgressPos ) > BOT_STUCK_DIST )
	{
		brain.lastProgressPos = origin
		brain.lastProgressTime = now
	}
	else if ( now - brain.lastProgressTime >= BOT_STUCK_TIME )
	{
		stuck = true
	}

	if ( travelling && brain.pathIndex < brain.path.len() )
	{
		local dist = Distance( origin, brain.path[ brain.pathIndex ] )
		if ( brain.wpProgressIndex != brain.pathIndex || brain.wpProgressPath != brain.path
			|| brain.wpProgressDist - dist > BOT_WAYPOINT_PROGRESS )
		{
			brain.wpProgressIndex = brain.pathIndex
			brain.wpProgressPath = brain.path
			brain.wpProgressDist = dist
			brain.wpProgressTime = now
		}
		else if ( now - brain.wpProgressTime > BOT_WAYPOINT_STUCK_TIME )
		{
			stuck = true
		}
	}
	else
	{
		brain.wpProgressIndex = -1
	}

	if ( !stuck )
		return

	// Titans have their own way out (they can't hop over things or back off at an angle into a doorway).
	if ( isTitan )
	{
		TitanStuckResponse( bot, brain, InputToWorldDir( brain.yaw, forward, side ), travelling )
		return
	}

	// Pinned in a corner mid-fight (the combat movement keeps pushing into it): circle the
	// other way for a while and hop, instead of re-pathing a route we aren't following.
	if ( !travelling && brain.target != null && Time() - brain.targetLastSeenTime < 0.5 )
	{
		brain.strafeDir = -brain.strafeDir
		brain.nextStrafeFlip = now + RandomFloat( 1.5, 3.0 )
		brain.underFireUntil = now + 1.0	// leave the ranged "hold" so the bot actually moves
		BotPressButtons( bot, BOT_IN_JUMP )
		brain.lastProgressPos = origin
		brain.lastProgressTime = now
		return
	}

	// Up against a ledge, a crate, a wall top in reach: get up it (jump, double jump, mantle) the
	// way we were going, instead of a single hop that only reaches knee-high things.
	if ( TryStartLedgeMantle( bot, brain, InputToWorldDir( brain.yaw, forward, side ) ) )
	{
		brain.lastProgressPos = origin
		brain.lastProgressTime = now
		brain.wpProgressIndex = -1
		return
	}

	if ( now - brain.lastStuckTime > BOT_STUCK_RESET_TIME )
		brain.stuckCount = 0
	brain.stuckCount++
	brain.lastStuckTime = now
	brain.carefulUntil = now + BOT_CAREFUL_AFTER_STUCK
	brain.lastProgressPos = origin
	brain.lastProgressTime = now
	brain.wpProgressIndex = -1
	brain.nextRepathTime = 0.0
	brain.flankPoint = null

	if ( brain.stuckCount == 1 )
	{
		// First time: hop and pick a fresh route.
		BotPressButtons( bot, BOT_IN_JUMP )
		brain.patrolGoal = null
		return
	}

	// Again: back off for a moment, away from where we were heading and off to one side,
	// so the next approach comes in from a different angle (and lines up with the doorway).
	local away = moveDir != null ? Vector( -moveDir.x, -moveDir.y, 0 ) : bot.GetForwardVector() * -1.0
	local length = max( Length2D( away ), 1.0 )
	away = Vector( away.x / length, away.y / length, 0 )
	local perp = Vector( -away.y, away.x, 0 ) * ( RandomInt( 2 ) == 0 ? -1.0 : 1.0 )
	brain.unstickDir = away + perp * RandomFloat( 0.5, 1.0 )
	brain.unstickUntil = now + BOT_UNSTICK_TIME
	// Blocked while running across roofs: follow the node path down for a while.
	if ( brain.offGraph )
		brain.offGraphBlockedUntil = now + BOT_OFFGRAPH_BLOCK_TIME
	if ( brain.climbUntil > 0.0 && brain.climbWall != null )
		MarkBadClimbSpot( brain.climbWall )
	brain.climbUntil = 0.0

	if ( brain.stuckCount >= 3 )
	{
		// Still stuck: give up on this way through and on the goal behind it.
		brain.stuckCount = 0
		brain.patrolGoal = null
		brain.prey = null
		brain.flankFor = null
		if ( brain.target == null || Time() - brain.targetLastSeenTime > 1.0 )
			brain.targetLastSeenPos = null
		printt( "BotAI:", bot.GetPlayerName(), "stuck, picking a new goal" )

		// Gave up several times in the same spot (a tree or a pocket the nav graph doesn't know
		// about): nothing we try gets out, so let it respawn instead of standing there.
		if ( brain.trapPos != null && Distance( origin, brain.trapPos ) < 250.0 && now - brain.trapTime < 40.0 )
			brain.trapCount++
		else
			brain.trapCount = 1
		brain.trapPos = origin
		brain.trapTime = now
		if ( brain.trapCount >= 3 && IsAlive( bot ) && !bot.IsTitan() )
		{
			printt( "BotAI:", bot.GetPlayerName(), "trapped at", origin, "- killing it so it respawns" )
			brain.trapCount = 0
			bot.TakeDamage( bot.GetMaxHealth() + 1000, null, null, { forceKill = true, damageSourceId = eDamageSourceId.suicide } )
		}
	}
}

// A titan stuck on stairs, steps or in a narrow passage. blockedDir is the way it was trying to
// go (world space, may be null). Every time: step out with a dash the way the hull fits. Again
// within a few seconds: in a fight, take a new angle on the target; travelling, skip the waypoint
// if the next one is in reach. A third time: avoid this spot (for every titan, for a while) and
// go around through a detour point.
function TitanStuckResponse( bot, brain, blockedDir, travelling )
{
	local now = Time()
	local origin = bot.GetOrigin()
	local fighting = !travelling && brain.target != null && IsValid( brain.target ) && now - brain.targetLastSeenTime < 0.5

	if ( now - brain.lastStuckTime > BOT_TITAN_STUCK_RESET_TIME )
		brain.stuckCount = 0
	brain.stuckCount++
	brain.lastStuckTime = now
	brain.lastProgressPos = origin
	brain.lastProgressTime = now
	brain.wpProgressIndex = -1

	if ( blockedDir == null )
	{
		local facing = bot.GetForwardVector()
		blockedDir = Vector( facing.x, facing.y, 0 )
	}
	brain.unstickDir = FindTitanFreeDir( bot, brain, blockedDir )
	brain.unstickUntil = now + BOT_TITAN_UNSTICK_TIME
	brain.unstickDash = true
	// Re-path once out, from wherever that leaves us.
	brain.nextRepathTime = now + BOT_TITAN_UNSTICK_TIME
	if ( fighting )
		brain.titanBackOffUntil = now + BOT_TITAN_BACKOFF_TIME

	if ( brain.stuckCount == 2 )
	{
		if ( fighting )
		{
			local point = ChooseRepositionPoint( bot, brain, brain.target.GetOrigin() )
			if ( point != null )
			{
				brain.repositionPoint = point.pos
				brain.repositionUntil = now + BOT_REPOSITION_TIME
				brain.nextRepositionTime = now + BOT_REPOSITION_COOLDOWN
			}
		}
		else if ( TitanSkipWaypoint( bot, brain ) )
		{
			// Keep the shortened route instead of re-deriving the same one right away.
			brain.nextRepathTime = now + BOT_REPATH_INTERVAL
		}
		return
	}

	if ( brain.stuckCount < 3 )
		return

	// Still stuck: this way through doesn't work for a titan. Remember the spot, and go around.
	brain.stuckCount = 0
	local length = max( Length2D( blockedDir ), 0.01 )
	// The waypoint we couldn't reach, or (fighting, off the route) the spot just ahead of us.
	local blocked = ( travelling && brain.pathIndex < brain.path.len() ) ? brain.path[ brain.pathIndex ]
		: origin + Vector( blockedDir.x / length, blockedDir.y / length, 0 ) * BOT_TITAN_PROBE_DIST
	MarkTitanBadSpot( blocked )
	if ( brain.pathGoal != null )
	{
		local point = ChooseRepositionPoint( bot, brain, brain.pathGoal )
		if ( point != null )
		{
			brain.titanDetour = point.pos
			brain.titanDetourUntil = now + BOT_TITAN_DETOUR_TIME
		}
	}
	brain.patrolGoal = null
	brain.prey = null
	if ( !fighting )
		brain.targetLastSeenPos = null
	brain.nextRepathTime = 0.0
	printt( "BotAI:", bot.GetPlayerName(), "titan stuck at", origin, "- avoiding the spot", brain.titanDetour != null ? "and taking a detour" : "" )
}

// Unit direction (world space) a titan can step out to: hull probes, raised over steps and a bit
// narrower than the titan, at growing angles from the blocked direction (the current orbit side
// first). Straight back if nothing is clear.
function FindTitanFreeDir( bot, brain, blockedDir )
{
	local length = max( Length2D( blockedDir ), 0.01 )
	local baseYaw = atan2( blockedDir.y / length, blockedDir.x / length )
	local origin = bot.GetOrigin()
	local start = origin + Vector( 0, 0, BOT_TITAN_STEP_HEIGHT )
	local playerMins = bot.GetPlayerMins()
	local playerMaxs = bot.GetPlayerMaxs()
	local scale = BOT_TITAN_PROBE_HULL_SCALE
	local mins = Vector( playerMins.x * scale, playerMins.y * scale, 0 )
	local maxs = Vector( playerMaxs.x * scale, playerMaxs.y * scale, playerMaxs.z * scale )

	local sign = brain.strafeDir >= 0.0 ? 1.0 : -1.0
	foreach ( offset in [ 45.0, -45.0, 90.0, -90.0, 135.0, -135.0, 180.0 ] )
	{
		local yaw = baseYaw + offset * sign * ( PI / 180.0 )
		local dir = Vector( cos( yaw ), sin( yaw ), 0 )
		local result = TraceHull( start, start + dir * BOT_TITAN_PROBE_DIST, mins, maxs, bot, TRACE_MASK_PLAYERSOLID_BRUSHONLY, TRACE_COLLISION_GROUP_PLAYER )
		if ( !result.startSolid && result.fraction >= BOT_TITAN_PROBE_CLEAR )
			return dir
	}
	return Vector( -blockedDir.x / length, -blockedDir.y / length, 0 )
}

// Stuck on the way to a waypoint: if the hull fits straight to the one after it, go for that one.
// True if the waypoint was skipped.
function TitanSkipWaypoint( bot, brain )
{
	if ( brain.pathIndex + 1 >= brain.path.len() )
		return false
	local step = Vector( 0, 0, BOT_TITAN_STEP_HEIGHT )
	local playerMins = bot.GetPlayerMins()
	local playerMaxs = bot.GetPlayerMaxs()
	local scale = BOT_TITAN_PROBE_HULL_SCALE
	local mins = Vector( playerMins.x * scale, playerMins.y * scale, 0 )
	local maxs = Vector( playerMaxs.x * scale, playerMaxs.y * scale, playerMaxs.z * scale )
	local result = TraceHull( bot.GetOrigin() + step, brain.path[ brain.pathIndex + 1 ] + step, mins, maxs, bot, TRACE_MASK_PLAYERSOLID_BRUSHONLY, TRACE_COLLISION_GROUP_PLAYER )
	if ( result.startSolid || result.fraction < 0.95 )
		return false
	brain.pathIndex++
	brain.wpProgressIndex = -1
	return true
}

// Places titans got stuck for good (shared by all titans for BOT_TITAN_BAD_SPOT_TIME): tactical
// points and flee spots there are skipped. Expired ones are dropped here.
function IsTitanBadSpot( pos )
{
	local now = Time()
	for ( local i = file.titanBadSpots.len() - 1; i >= 0; i-- )
	{
		local spot = file.titanBadSpots[ i ]
		if ( now > spot.until )
		{
			file.titanBadSpots.remove( i )
			continue
		}
		if ( Distance( spot.pos, pos ) < BOT_TITAN_BAD_SPOT_RADIUS )
			return true
	}
	return false
}

function MarkTitanBadSpot( pos )
{
	local until = Time() + BOT_TITAN_BAD_SPOT_TIME
	foreach ( spot in file.titanBadSpots )
	{
		// Same spot again: just remember it longer.
		if ( Distance( spot.pos, pos ) < BOT_TITAN_BAD_SPOT_RADIUS )
		{
			spot.until = until
			return
		}
	}
	file.titanBadSpots.append( { pos = pos, until = until } )
	if ( file.titanBadSpots.len() > BOT_TITAN_BAD_SPOT_MAX )
		file.titanBadSpots.remove( 0 )
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

// A pit or the edge of the map at pos: no floor below it within BOT_VOID_PROBE, or a floor deeper
// than the lowest node of the graph (nothing the map means to be walked on is down there).
function IsVoidAt( bot, pos )
{
	local nav = GetNavCache()
	if ( nav.positions.len() == 0 )
		return false
	local start = pos + Vector( 0, 0, 32 )
	local down = TraceLine( start, start - Vector( 0, 0, BOT_VOID_PROBE ), bot, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE )
	if ( down.startSolid )
		return false	// probe started inside a wall: that's a wall ahead, not a pit
	if ( down.fraction >= 1.0 )
		return true
	return down.endPos.z < nav.minZ - BOT_VOID_MARGIN
}

// Last check before a pilot on the ground moves: never step or jump into the void. The path's
// next waypoint is taken instead if that way is safe (the graph never leads into a pit), else the
// bot stops where it is. Returns the adjusted { forward, side, pressed }.
function AvoidVoid( bot, brain, forward, side, pressed )
{
	local result = { forward = forward, side = side, pressed = pressed }
	// (IsOnGround can be true on a wall: a wall over a pit is no reason to stop.)
	if ( !bot.IsOnGround() || bot.IsWallRunning() )
		return result
	// The input was turned with the aim (see BotThinkTick), so it's relative to the final yaw.
	local dir = InputToWorldDir( brain.yaw, forward, side )
	if ( dir == null )
		return result
	local origin = bot.GetOrigin()
	// Running in for a planned wallrun over a pit (or jumping for it this tick): the wall is the floor
	// (the plan checked the far end), as long as we're fast and about to jump onto it. The edge of the
	// pit coming before the planned jump point: jump for the wall from there.
	if ( ( brain.wrPhase == "approach" || brain.wrPhase == "air" ) && brain.wrAlong != null && Dot2D( dir, brain.wrAlong ) > 0.7
		&& Dot2D( brain.wrWallPoint - origin, brain.wrInto ) < BOT_WR_JUMP_MAX + 40.0
		&& Length2D( bot.GetVelocity() ) > BOT_WR_MIN_SPEED )
	{
		if ( brain.wrPhase == "approach" && IsVoidAt( bot, origin + dir * BOT_WR_JUMP_MIN ) )
		{
			brain.wrPhase = "air"
			brain.wrPhaseStart = Time()
			brain.wrJumped = true
			brain.usedDoubleJump = false
			result.pressed = pressed | BOT_IN_JUMP
		}
		return result
	}
	// A titan is wider and a dash carries it much further: look further ahead.
	local isTitan = bot.IsTitan()
	local ahead = isTitan ? BOT_VOID_AHEAD_TITAN : BOT_VOID_AHEAD
	if ( !IsVoidAt( bot, origin + dir * ahead ) )
		return result

	// Whatever sent us this way (running across "roofs", a window, a leap, a wallrun, a dash) is off for a while.
	brain.offGraphBlockedUntil = Time() + BOT_OFFGRAPH_BLOCK_TIME
	brain.windowExitUntil = 0.0
	brain.climbUntil = 0.0
	brain.climbIsLedge = false
	ResetWallrunPlan( bot, brain, "void" )
	result.pressed = pressed & ~( isTitan ? BOT_IN_DODGE : BOT_IN_JUMP )
	result.forward = 0.0
	result.side = 0.0
	if ( brain.pathIndex < brain.path.len() )
	{
		local toNode = brain.path[ brain.pathIndex ] - origin
		if ( Length2D( toNode ) > 1.0 && !IsVoidAt( bot, origin + Normalize2D( toNode ) * ahead ) )
		{
			local relative = MoveDirRelativeToView( toNode, brain.yaw )
			result.forward = relative.forward
			result.side = relative.side
		}
	}
	return result
}

// The inverse: the world-space unit direction a forward/side input moves in, or null for no input.
function InputToWorldDir( viewYaw, forward, side )
{
	if ( fabs( forward ) < 0.01 && fabs( side ) < 0.01 )
		return null
	local yaw = viewYaw * ( PI / 180.0 ) + atan2( -side, forward )
	return Vector( cos( yaw ), sin( yaw ), 0 )
}

// Standing / running on the floor. IsOnGround can be true while wallrunning too, so anything
// that means "on foot" checks this instead.
function BotOnFoot( bot )
{
	return bot.IsOnGround() && !bot.IsWallRunning()
}

// Dot product of the horizontal parts of a and b.
function Dot2D( a, b )
{
	return a.x * b.x + a.y * b.y
}

// forward / side input worked out for view yaw Y, turned so it moves the same way in the world
// when sent with view yaw Y + turned (degrees).
// MoveDirRelativeToView: forward = cos( d ), side = -sin( d ) with d = moveYaw - viewYaw, and
// InputToWorldDir adds atan2( -side, forward ) = d back onto the view yaw. With the view turned by
// t, the same world direction needs d - t: cos( d - t ) = forward * cos( t ) - side * sin( t ),
// -sin( d - t ) = side * cos( t ) + forward * sin( t ). (Linear, so a scaled input stays scaled.)
function RotateInputForYaw( forward, side, turned )
{
	local t = turned * ( PI / 180.0 )
	local c = cos( t )
	local s = sin( t )
	local newForward = forward * c - side * s
	local newSide = side * c + forward * s
	// A full diagonal (1, 1) turned onto an axis would be 1.41 there: scale back into -1..1,
	// keeping the direction.
	local over = max( max( fabs( newForward ), fabs( newSide ) ), 1.0 )
	return { forward = newForward / over, side = newSide / over }
}

// How far out from a wall to jump at it: the time to cover the gap at our speed into the wall, so
// a shallow run-in jumps close and a steep one earlier.
function WallrunJumpDist( bot, into )
{
	local perp = max( Dot2D( bot.GetVelocity(), into ), 60.0 )
	return BotClamp( perp * BOT_WR_JUMP_LEAD, BOT_WR_JUMP_MIN, BOT_WR_JUMP_MAX )
}

// How keen the route style is on wallrunning just for the speed of it.
function WallrunStyleFactor( brain )
{
	switch ( brain.routeStyle )
	{
		case "high":	return 1.0
		case "flank":	return 0.9
		case "indoor":	return 0.35
	}
	return 0.7
}

//---------------------------------------------------------
// Planned wallruns
//---------------------------------------------------------
// On foot and moving, every BOT_WR_PLAN_INTERVAL: is there a wall along the way that takes us up
// (the route / goal is above), across a gap, or just a good way further at speed? If so: run in at
// an angle, jump onto it from the right distance, ride it leaning in, and kick off it towards
// where the route goes (double jumping on if the way on isn't below), or hop across to a facing
// wall. Wallruns we didn't plan (fell onto a wall) are adopted and finished the same way.
// Returns buttons to press; while brain.wrPhase != "none", brain.wrMoveDir / wrLookDir say where
// to move and look.

// Where the route takes us from here: the next waypoint (or the one after, when that's close), the
// goal itself off the graph, else straight on.
function GetWallrunSteerTarget( bot, brain, moveDir )
{
	local origin = bot.GetOrigin()
	if ( brain.offGraph && brain.pathGoal != null )
		return brain.pathGoal
	local count = brain.path.len()
	if ( brain.pathIndex < count )
	{
		local i = brain.pathIndex
		if ( i + 1 < count && Distance2D( origin, brain.path[ i ] ) < BOT_WR_LOOKAHEAD_DIST )
			i++
		return brain.path[ i ]
	}
	return origin + moveDir
}

// A wall on `side` (flat unit vector) of a run in direction d, a little ahead: near-vertical, facing
// us, running roughly along d, and high enough to run on. { point, normal, along, lateral } or null.
function ProbeWallrunWall( bot, origin, d, side )
{
	local start = origin + Vector( 0, 0, 48 ) + d * BOT_WR_LEAD
	local hit = TraceLine( start, start + side * BOT_WR_SIDE_DIST, bot, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE )
	if ( hit.fraction >= 1.0 || hit.startSolid )
		return null
	if ( fabs( hit.surfaceNormal.z ) > 0.3 )
		return null		// a slope or a ledge top, not a wall
	local normal = Normalize2D( hit.surfaceNormal )
	if ( Dot2D( normal, side ) > -0.7 )
		return null		// facing away from us at a slant
	if ( fabs( Dot2D( normal, d ) ) > BOT_WR_MAX_ANGLE_COS )
		return null		// runs across the way we're going, not along it
	local along = Normalize2D( d - normal * Dot2D( d, normal ) )
	local lateral = BOT_WR_SIDE_DIST * hit.fraction
	// Tall enough: a fence or a low wall doesn't take a wallrun.
	local high = origin + Vector( 0, 0, BOT_WR_MIN_WALL_HEIGHT ) + d * BOT_WR_LEAD
	if ( HasClearLine( bot, high, high + side * ( lateral + 24.0 ) ) )
		return null
	return { point = hit.endPos, normal = normal, along = along, lateral = lateral }
}

// Room to run the whole length along the wall (nothing in the way), and the wall really goes on
// that far (same face halfway and at the end).
function CheckWallrunRoom( bot, wall )
{
	local runStart = wall.point + wall.normal * BOT_WR_WALL_OFFSET
	local runEnd = runStart + wall.along * BOT_WR_RUN_LENGTH
	if ( !HasClearLine( bot, runStart, runEnd ) )
		return false
	foreach ( frac in [ 0.5, 1.0 ] )
	{
		local p = runStart + wall.along * ( BOT_WR_RUN_LENGTH * frac )
		local face = TraceLine( p, p - wall.normal * ( BOT_WR_WALL_OFFSET + 24.0 ), bot, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE )
		if ( face.fraction >= 1.0 || face.startSolid || Dot2D( Normalize2D( face.surfaceNormal ), wall.normal ) < 0.85 )
			return false
	}
	return true
}

// Look for a wall worth running along (see above). True if a plan was made (wrPhase = "approach").
function PlanWallrun( bot, brain, moveDir )
{
	// Near doors / indoors the walls are door frames and corridors.
	if ( brain.careful || brain.indoors )
		return false
	if ( Length2D( bot.GetVelocity() ) < BOT_WR_MIN_SPEED )
		return false
	local now = Time()
	local origin = bot.GetOrigin()
	local target = GetWallrunSteerTarget( bot, brain, moveDir )
	local toTarget = target - origin
	local flat = Length2D( toTarget )
	if ( flat < 150.0 )
		return false
	local d = Normalize2D( toTarget )

	// Why run the wall: for height, across a gap, or (by taste) just for the speed on a long way.
	local reason = null
	if ( ( toTarget.z > BOT_WR_UP_MIN && flat < BOT_WR_UP_MAX_DIST ) || IsRepositioningUp( bot, brain ) )
		reason = "up"
	else if ( IsGapAhead( bot, d, BOT_WR_GAP_AHEAD ) )
		reason = "gap"
	else if ( flat > BOT_WALLRUN_MIN_DIST && RandomFloat( 0.0, 1.0 ) < ( brain.patrolElevation >= BOT_VANTAGE_MIN_ELEVATION ? 1.0 : brain.wallLove * WallrunStyleFactor( brain ) ) )
		reason = "long"
	else
		return false

	local best = null
	local bestScore = 0.0
	foreach ( side in [ Vector( d.y, -d.x, 0 ), Vector( -d.y, d.x, 0 ) ] )
	{
		local wall = ProbeWallrunWall( bot, origin, d, side )
		if ( wall == null )
			continue
		if ( brain.wrBadWall != null && now < brain.wrBadUntil && Distance( wall.point, brain.wrBadWall ) < BOT_WR_BAD_WALL_RADIUS )
			continue
		local runStart = wall.point + wall.normal * BOT_WR_WALL_OFFSET
		local runEnd = runStart + wall.along * BOT_WR_RUN_LENGTH
		// The run must take us closer to where we're going (for height, just not away from it).
		local progress = flat - Length2D( target - runEnd )
		if ( reason == "up" ? progress < 0.0 : progress < BOT_WR_RUN_LENGTH * BOT_WR_MIN_PROGRESS )
			continue
		if ( IsUnderRoof( runStart ) )
			continue
		if ( !CheckWallrunRoom( bot, wall ) )
			continue
		// Somewhere to come down past the end of it.
		if ( IsVoidAt( bot, runEnd + wall.along * BOT_WR_LAND_AHEAD ) )
			continue
		local score = progress - wall.lateral * 0.5
		if ( best == null || score > bestScore )
		{
			best = wall
			bestScore = score
		}
	}
	if ( best == null )
		return false

	brain.wrPhase = "approach"
	brain.wrReason = reason
	brain.wrExit = reason == "up" ? "ledge" : "goal"
	brain.wrInto = best.normal * -1.0
	brain.wrAlong = best.along
	brain.wrWallPoint = best.point
	brain.wrTarget = target
	brain.wrMoveDir = null
	brain.wrLookDir = null
	brain.wrKickDir = null
	brain.wrPhaseStart = now
	brain.wrChain = 0
	brain.wrPlanDouble = false
	brain.wrJumped = false
	if ( BOT_DEBUG_WALLRUN )
		printt( "BotAI:", bot.GetPlayerName(), "wallrun planned:", reason, "- wall", best.lateral, "away, progress", bestScore )
	return true
}

// Flat normal of a wall within 64 units of the chest in one of dirs (first hit wins), or null.
function FindRunWallNormal( bot, dirs )
{
	local chest = bot.GetOrigin() + Vector( 0, 0, 40 )
	foreach ( dir in dirs )
	{
		local hit = TraceLine( chest, chest + dir * 64.0, bot, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE )
		if ( hit.fraction >= 1.0 || hit.startSolid )
			continue
		local normal = Normalize2D( hit.surfaceNormal )
		if ( Length2D( normal ) > 0.5 )
			return normal
	}
	return null
}

// The wall we're on has this flat normal: into it, and along it the way we're moving.
function SetWallrunWall( brain, normal, vel )
{
	brain.wrInto = normal * -1.0
	local along = Normalize2D( vel - normal * Dot2D( vel, normal ) )
	if ( Length2D( along ) > 0.5 )
		brain.wrAlong = along
	else if ( brain.wrAlong == null )
		brain.wrAlong = Vector( -normal.y, normal.x, 0 )
}

// On a wall we didn't plan for (fell / jumped onto it): take it over as a run. True if the wall was found.
function WallrunAdopt( bot, brain, moveDir )
{
	local vel = bot.GetVelocity()
	local v = Normalize2D( vel )
	if ( Length2D( v ) < 0.5 )
		return false
	local right = Vector( v.y, -v.x, 0 )
	local normal = FindRunWallNormal( bot, [ right, right * -1.0 ] )
	if ( normal == null )
		return false
	SetWallrunWall( brain, normal, vel )
	brain.wrPhase = "run"
	brain.wrRunStart = brain.wallrunStartTime
	brain.wrReason = "adopted"
	brain.wrExit = "goal"
	brain.wrChain = 1
	brain.wrPlanDouble = false
	brain.wrWallPoint = bot.GetOrigin() + Vector( 0, 0, 48 )
	brain.wrTarget = GetWallrunSteerTarget( bot, brain, moveDir )
	return true
}

// A wall facing ours across the gap (an alley), close enough to hop over to.
function FindHopWall( bot, brain )
{
	local away = brain.wrInto * -1.0
	local p = bot.GetOrigin() + Vector( 0, 0, 40 ) + brain.wrAlong * 64.0
	local hit = TraceLine( p, p + away * BOT_WR_HOP_DIST, bot, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE )
	return hit.fraction < 1.0 && !hit.startSolid && Dot2D( Normalize2D( hit.surfaceNormal ), away ) < -0.85
}

// Kick-off direction towards toTarget, always pushing off the wall at least a bit; null if the
// target is behind the wall (kicking off would only take us away from it).
function GetWallrunKickDir( brain, toTarget )
{
	local away = brain.wrInto * -1.0
	local dir = Normalize2D( toTarget )
	if ( Length2D( dir ) < 0.5 )
		dir = brain.wrAlong
	local a = Dot2D( dir, away )
	if ( a < -0.5 )
		return null
	return Normalize2D( ( dir - away * a ) + away * max( a, BOT_WR_KICK_AWAY ) )
}

// The plan is over: result is "done" / "missed" / "timeout" / "void" / "aborted" / "error". A wall
// we failed to get onto isn't planned again for a while; the stuck checks start over from here.
function ResetWallrunPlan( bot, brain, result )
{
	if ( brain.wrPhase == "none" )
		return
	local now = Time()
	if ( BOT_DEBUG_WALLRUN )
		printt( "BotAI:", bot.GetPlayerName(), "wallrun", brain.wrReason, "ended in phase", brain.wrPhase, "-", result, "after", brain.wrChain, "walls" )
	local failed = result == "missed" || result == "timeout" || result == "void"
	if ( failed && brain.wrWallPoint != null )
	{
		brain.wrBadWall = brain.wrWallPoint
		brain.wrBadUntil = now + BOT_WR_BAD_WALL_TIME
	}
	brain.wrPhase = "none"
	brain.wrReason = null
	brain.wrExit = null
	brain.wrInto = null
	brain.wrAlong = null
	brain.wrWallPoint = null
	brain.wrTarget = null
	brain.wrMoveDir = null
	brain.wrLookDir = null
	brain.wrKickDir = null
	brain.wrChain = 0
	brain.wrPlanDouble = false
	brain.wrJumped = false
	brain.wrNextPlan = now + ( failed ? BOT_WR_FAIL_COOLDOWN : BOT_WR_PLAN_INTERVAL )
	brain.wpProgressIndex = -1
	brain.lastProgressPos = bot.GetOrigin()
	brain.lastProgressTime = now
	// Landed somewhere else than the route expected: find the way on from here.
	if ( result == "done" )
		brain.nextRepathTime = 0.0
}

// Kick off the wall in dir: jump now, steer that way in the air.
function StartWallrunKick( brain, dir, now )
{
	brain.wrKickDir = dir
	brain.wrPhase = "kick"
	brain.wrPhaseStart = now
	brain.wrMoveDir = dir
	brain.wrLookDir = dir
}

function UpdateWallrun( bot, brain, moveDir )
{
	local now = Time()
	// Not run for a while (a rodeo, a fight, a climb): whatever the plan was, it's out of date.
	if ( brain.wrPhase != "none" && now - brain.wrLastTick > BOT_WR_STALE )
		ResetWallrunPlan( bot, brain, "aborted" )
	brain.wrLastTick = now

	local origin = bot.GetOrigin()
	local vel = bot.GetVelocity()
	local wallRunning = bot.IsWallRunning()
	local onFoot = bot.IsOnGround() && !wallRunning
	// (UpdateParkour / UpdateCombatJumps keep these too; whichever runs first this tick sets them.)
	if ( wallRunning && !brain.wasWallRunning )
	{
		brain.wallrunStartTime = now
		brain.wallrunHopAfter = RandomFloat( 0.6, 1.4 )
	}
	brain.wasWallRunning = wallRunning
	if ( wallRunning )
	{
		brain.usedDoubleJump = false	// touching a wall gives the double jump back
		if ( BOT_DEBUG_WALLRUN && !file.wrGroundLogged && bot.IsOnGround() )
		{
			file.wrGroundLogged = true
			printt( "BotAI:", bot.GetPlayerName(), "IsOnGround() is true while wallrunning" )
		}
	}

	if ( brain.wrPhase == "none" )
	{
		if ( wallRunning )
		{
			// Near doors / indoors UpdateParkour gets us off the wall instead.
			if ( brain.careful || !WallrunAdopt( bot, brain, moveDir ) )
				return 0
		}
		else if ( onFoot && now >= brain.wrNextPlan )
		{
			brain.wrNextPlan = now + ( WantsHigherGround( bot, brain ) ? BOT_WR_PLAN_INTERVAL_UP : BOT_WR_PLAN_INTERVAL )
			if ( !PlanWallrun( bot, brain, moveDir ) )
				return 0
		}
		else
			return 0
	}

	// Running in at the wall at an angle, and jumping onto it from the right distance.
	if ( brain.wrPhase == "approach" )
	{
		if ( wallRunning )
		{
			brain.wrPhase = "run"
			brain.wrRunStart = now
			brain.wrChain = 1
		}
		else if ( !onFoot )
		{
			brain.wrPhase = "air"
			brain.wrPhaseStart = now
		}
		else
		{
			local lateral = Dot2D( brain.wrWallPoint - origin, brain.wrInto )
			local passed = Dot2D( origin - brain.wrWallPoint, brain.wrAlong ) > BOT_WR_RUN_LENGTH * 0.5
			if ( lateral < -16.0 || passed || now - brain.wrPhaseStart > BOT_WR_APPROACH_TIME )
			{
				ResetWallrunPlan( bot, brain, "timeout" )
				return 0
			}
			local angle = ( lateral > BOT_WR_FAR_LATERAL ? BOT_WR_APPROACH_ANGLE_FAR : BOT_WR_APPROACH_ANGLE ) * ( PI / 180.0 )
			brain.wrMoveDir = brain.wrAlong * cos( angle ) + brain.wrInto * sin( angle )
			brain.wrLookDir = brain.wrMoveDir
			if ( lateral <= WallrunJumpDist( bot, brain.wrInto ) && Length2D( vel ) > BOT_WR_MIN_SPEED )
			{
				brain.wrPhase = "air"
				brain.wrPhaseStart = now
				brain.wrJumped = true
				brain.usedDoubleJump = false
				return BOT_IN_JUMP
			}
			return 0
		}
	}

	// Jumped: steer onto the wall, double jumping if we're dropping short of it.
	if ( brain.wrPhase == "air" )
	{
		if ( wallRunning )
		{
			brain.wrPhase = "run"
			brain.wrRunStart = now
			brain.wrChain++
		}
		else
		{
			local inAir = now - brain.wrPhaseStart
			if ( ( onFoot && inAir > 0.15 ) || inAir > BOT_WR_LATCH_TIME )
			{
				// (Off the ground without our jump, a step or a bump: not the wall's fault.)
				ResetWallrunPlan( bot, brain, brain.wrJumped ? "missed" : "aborted" )
				return 0
			}
			brain.wrMoveDir = Normalize2D( brain.wrAlong + brain.wrInto * BOT_WR_AIR_LEAN )
			brain.wrLookDir = brain.wrAlong
			local lateral = Dot2D( brain.wrWallPoint - origin, brain.wrInto )
			// Without our jump only over a real drop (off an edge), not stepping down a stair.
			if ( lateral > 24.0 && !brain.usedDoubleJump && vel.z < 0.0 && ( brain.wrJumped
				|| TraceLine( origin, origin - Vector( 0, 0, 96 ), bot, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE ).fraction >= 1.0 ) )
			{
				brain.usedDoubleJump = true
				return BOT_IN_JUMP
			}
			return 0
		}
	}

	// On the wall: run along it leaning in, then kick off towards the route (or hop to a facing wall).
	if ( brain.wrPhase == "run" )
	{
		if ( !wallRunning )
		{
			if ( onFoot )
			{
				ResetWallrunPlan( bot, brain, "done" )
				return 0
			}
			// Fell off (the wall ended): carry on the way we're flying.
			local flying = Normalize2D( vel )
			StartWallrunKick( brain, Length2D( flying ) > 0.5 ? flying : brain.wrAlong, now )
			return 0
		}

		// Follow the wall as it bends; nothing beside us or just ahead = it ends here.
		local normal = FindRunWallNormal( bot, [ brain.wrInto ] )
		local wallEnds = normal == null
		if ( normal != null )
		{
			if ( Length2D( vel ) > 50.0 )
				SetWallrunWall( brain, normal, vel )
			else
				brain.wrInto = normal * -1.0
			local ahead = origin + Vector( 0, 0, 40 ) + brain.wrAlong * BOT_WR_END_CHECK
			wallEnds = HasClearLine( bot, ahead, ahead + brain.wrInto * 64.0 )
		}

		brain.wrTarget = GetWallrunSteerTarget( bot, brain, moveDir )
		local toTarget = brain.wrTarget - origin
		local targetAhead = Dot2D( toTarget, brain.wrAlong )
		local ride = now - brain.wrRunStart
		brain.wrMoveDir = Normalize2D( brain.wrAlong + brain.wrInto * BOT_WR_LEAN )
		brain.wrLookDir = brain.wrAlong

		// A door / indoors coming up: off the wall now, to walk in on the ground.
		if ( brain.careful )
		{
			local dir = GetWallrunKickDir( brain, toTarget )
			if ( dir != null && !IsVoidAt( bot, origin + dir * BOT_WR_KICK_REACH ) )
			{
				brain.wrPlanDouble = false
				StartWallrunKick( brain, dir, now )
				return BOT_IN_JUMP
			}
			ResetWallrunPlan( bot, brain, "aborted" )
			return 0
		}

		if ( ride < BOT_WR_MIN_RUN && !wallEnds )
			return 0

		// An alley: hop across to the facing wall and keep going on that one.
		if ( now >= brain.wrNextHopCheck && brain.wrChain < BOT_WR_MAX_CHAIN && ride > 0.4 && targetAhead > BOT_WR_KICK_AHEAD * 2.0 )
		{
			brain.wrNextHopCheck = now + BOT_WR_HOP_CHECK
			if ( FindHopWall( bot, brain ) )
			{
				brain.wrExit = "hop"
				brain.wrPlanDouble = false
				StartWallrunKick( brain, Normalize2D( brain.wrAlong * 0.8 - brain.wrInto * 0.6 ), now )
				return BOT_IN_JUMP
			}
		}

		// The wall ends, we've been on it long enough, or the route leaves it: kick off towards
		// the route, double jumping on unless the way on is down. Never into the void: then we
		// ride it out instead.
		if ( wallEnds || ride > BOT_WR_MAX_RUN || targetAhead < BOT_WR_KICK_AHEAD )
		{
			local dir = GetWallrunKickDir( brain, toTarget )
			if ( dir != null && !IsVoidAt( bot, origin + dir * BOT_WR_KICK_REACH ) )
			{
				brain.wrPlanDouble = toTarget.z > -64.0
				StartWallrunKick( brain, dir, now )
				return BOT_IN_JUMP
			}
		}
		return 0
	}

	// Off the wall: fly the kick direction until we land or catch the next wall.
	if ( brain.wrPhase == "kick" )
	{
		local sinceKick = now - brain.wrPhaseStart
		if ( wallRunning && sinceKick > 0.2 )
		{
			// The next wall (hopped across, or caught on the way): on the side we pushed off towards
			// first, else whichever side it is.
			local normal = FindRunWallNormal( bot, [ brain.wrInto * -1.0 ] )
			if ( normal == null )
			{
				local v = Normalize2D( vel )
				local right = Vector( v.y, -v.x, 0 )
				normal = FindRunWallNormal( bot, [ right, right * -1.0 ] )
			}
			if ( normal != null )
				SetWallrunWall( brain, normal, vel )
			brain.wrPhase = "run"
			brain.wrRunStart = now
			brain.wrChain++
			brain.wrExit = "goal"
			brain.wrMoveDir = Normalize2D( brain.wrAlong + brain.wrInto * BOT_WR_LEAN )
			brain.wrLookDir = brain.wrAlong
			return 0
		}
		if ( onFoot || sinceKick > 1.5 )
		{
			ResetWallrunPlan( bot, brain, "done" )
			return 0
		}
		brain.wrMoveDir = brain.wrKickDir
		brain.wrLookDir = brain.wrKickDir
		// (Not while still on the wall: that press would be another wall jump.)
		if ( wallRunning )
			return 0
		if ( brain.wrPlanDouble && !brain.usedDoubleJump && vel.z < 60.0 )
		{
			brain.usedDoubleJump = true
			brain.wrPlanDouble = false
			return BOT_IN_JUMP
		}
		// Hopping across: the double jump carries us the rest of the way to the facing wall.
		if ( brain.wrExit == "hop" && !brain.usedDoubleJump && vel.z < -60.0 )
		{
			brain.usedDoubleJump = true
			return BOT_IN_JUMP
		}
		return 0
	}
	return 0
}

function UpdateParkour( bot, brain, moveDir, forward )
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

	// First: IsOnGround can be true on a wall too, so the wall is checked before the ground.
	// On a wall we didn't plan (planned ones are run by UpdateWallrun, and parkour is off then):
	// kick off once the route leaves the wall (waypoint close or above us), or right away near a
	// door, to walk in on the ground. Touching a wall gives the double jump back.
	if ( wallRunning )
	{
		brain.usedDoubleJump = false
		if ( travelling && ( brain.careful || moveDir.z > 48.0 || Length2D( moveDir ) < 150.0 ) )
			return BOT_IN_JUMP
		return 0
	}

	if ( bot.IsOnGround() )
	{
		brain.usedDoubleJump = false
		brain.planGapDouble = false

		// Running at a roof edge or a ledge over a drop: leap it (and double jump across) instead
		// of stepping off, so bots cross from one building to the next.
		if ( travelling && forward > 0.6 && !brain.careful && Length2D( bot.GetVelocity() ) > 200.0 && IsGapAhead( bot, moveDir ) )
		{
			brain.planGapDouble = true
			return BOT_IN_JUMP
		}

		if ( travelling )
		{
			// Next waypoint is above us: jump to climb onto it.
			if ( moveDir.z > 48.0 && Length2D( moveDir ) < 250.0 )
				return BOT_IN_JUMP

			// Something knee-high in the way: hop it.
			if ( IsObstacleAhead( bot, moveDir ) )
				return BOT_IN_JUMP
		}

		// (Jumping onto walls while travelling is planned, see PlanWallrun.)
		return 0
	}

	// Airborne: double jump if we still need height. Near doors only for a real ledge right ahead
	// (a doorway node sitting a little higher used to trigger double jumps into the door frame).
	// Gap leap: second jump near the top of the arc if there's still nothing below ahead.
	if ( brain.planGapDouble && !brain.usedDoubleJump && bot.GetVelocity().z < 40.0 && IsGapAhead( bot, bot.GetVelocity() ) )
	{
		brain.usedDoubleJump = true
		brain.planGapDouble = false
		return BOT_IN_JUMP
	}

	if ( !brain.usedDoubleJump )
	{
		local needHeight = travelling && ( brain.careful ? ( moveDir.z > 64.0 && Length2D( moveDir ) < 200.0 ) : moveDir.z > 24.0 )
		if ( needHeight )
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
	// Grunts and spectres are no match for a pilot: push right in on them (shooting on the way,
	// kicking when close) instead of trading shots from cover like against another pilot.
	local vsInfantry = !targetIsTitan && !brain.target.IsPlayer()
	local preferred = targetIsTitan ? BOT_AT_PREFERRED_DIST : ( vsInfantry ? BOT_PILOT_RANGE_MIN : GetPilotPreferredDist( bot, brain ) )
	local closeIn = dist > preferred

	// At range and not being hit: plant and shoot. Side-step slowly and only drift towards the
	// preferred range; no walls, no hops (the caller scales this down to a walk).
	if ( !vsInfantry && dist > BOT_HOLD_DIST && Time() > brain.underFireUntil && !bot.IsWallRunning() )
	{
		brain.combatHold = true
		brain.combatWallSeen = false
		if ( Time() > brain.nextStrafeFlip )
		{
			brain.strafeDir = -brain.strafeDir
			brain.nextStrafeFlip = Time() + RandomFloat( BOT_COMBAT_STRAFE_MIN, BOT_COMBAT_STRAFE_MAX )
		}
		// Too far: walk in. Closer than we'd like: stand our ground (no backpedalling away),
		// except from a titan: give ground to keep it at anti-titan range.
		local holdRadial = dist > preferred + BOT_COMBAT_RANGE_SLACK * 2 ? 1.0 : 0.0
		if ( targetIsTitan && dist < preferred - BOT_COMBAT_RANGE_SLACK )
			holdRadial = -BOT_COMBAT_RADIAL_SPEED
		return Vector( -dir.y, dir.x, 0 ) * brain.strafeDir + dir * holdRadial
	}

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

	// A wall to either side of the line to the target: run along it (towards the target when
	// far, sideways around it otherwise) with a slight lean into it; the combat jumps put us on it.
	// Not near doors or indoors, where the "walls" are door frames and corridor corners.
	local wallSide = brain.careful ? null : FindWallAlong( bot, perp, BOT_WALL_COMBAT_DIST * brain.wallLove )
	brain.combatWallSeen = wallSide != null
	if ( wallSide != null )
	{
		// A titan right on us: along the wall but backing off, never running in under its feet.
		if ( targetIsTitan && dist < BOT_TITAN_TOO_CLOSE_DIST )
			return perp - dir * BOT_COMBAT_RADIAL_SPEED + wallSide * BOT_COMBAT_WALL_LEAN
		local along = closeIn ? dir : perp
		return along + wallSide * BOT_COMBAT_WALL_LEAN
	}

	// Open ground: circle the target, closing in when too far. Only backs off when the enemy
	// is right on top of a long-range weapon; otherwise a closer enemy is just fought.
	local radial = 0.0
	if ( dist > preferred + BOT_COMBAT_RANGE_SLACK )
		radial = BOT_COMBAT_RADIAL_SPEED
	else if ( targetIsTitan && dist < preferred - BOT_COMBAT_RANGE_SLACK )
		radial = -BOT_COMBAT_RADIAL_SPEED	// a titan closing in: keep the distance, it stomps and punches
	else if ( dist < preferred * BOT_BACKOFF_FRACTION && preferred > BOT_BACKOFF_MIN_PREFERRED )
		radial = -BOT_COMBAT_RADIAL_SPEED * 0.5
	return perp + dir * radial
}

// The range this titan fights from, inside its main weapon's damage band (file.titanWeaponRanges,
// else the weapon file's falloff distances). Rolled again only when the weapon changes, so each bot
// keeps its own spot in the band.
function UpdateTitanPreferredDist( bot, brain )
{
	local weapon = bot.GetActiveWeapon()
	if ( !IsValid( weapon ) )
		return brain.titanPreferredDist
	local weaponClass = weapon.GetWeaponClassName()
	if ( weaponClass == brain.titanRangeClass )
		return brain.titanPreferredDist
	brain.titanRangeClass = weaponClass

	local band = null
	if ( weaponClass in file.titanWeaponRanges )
		band = file.titanWeaponRanges[ weaponClass ]
	else
	{
		local ranges = GetWeaponRanges( weapon )
		band = { min = BotClamp( ranges.near * 0.6, 250.0, 1500.0 ), max = BotClamp( ranges.near, 400.0, 2000.0 ) }
		if ( band.max < band.min )
			band.max = band.min
	}
	brain.titanPreferredDist = RandomFloat( band.min, band.max )
	return brain.titanPreferredDist
}

// Where a titan moves in a fight (world space; the aim stays on the target): circle the target
// while closing to its preferred range, and charge in for the punch when the target is weak.
function GetTitanCombatMove( bot, brain )
{
	local target = brain.target
	local toTarget = target.GetOrigin() - bot.GetOrigin()
	local dist = max( Length2D( toTarget ), 1.0 )
	local dir = Vector( toTarget.x / dist, toTarget.y / dist, 0 )

	// Orbit the target in one direction for a while (not a side-to-side shuffle), and pick the
	// direction that takes us away from friendly titans fighting the same fight.
	if ( Time() > brain.nextStrafeFlip )
	{
		brain.strafeDir = ChooseTitanOrbitDir( bot, dir, -brain.strafeDir )
		brain.nextStrafeFlip = Time() + RandomFloat( BOT_TITAN_ORBIT_MIN, BOT_TITAN_ORBIT_MAX )
	}
	local perp = Vector( -dir.y, dir.x, 0 ) * brain.strafeDir

	local preferred = brain.titanPreferredDist
	local targetFrac = target.GetHealth().tofloat() / max( target.GetMaxHealth(), 1 )
	local ownFrac = bot.GetHealth().tofloat() / max( bot.GetMaxHealth(), 1 )
	local heightDiff = target.GetOrigin().z - bot.GetOrigin().z
	if ( !IsTitanEntity( target ) && heightDiff > BOT_MELEE_MAX_HEIGHT_DIFF && !brain.swatting )
	{
		// A pilot up on a roof or a ledge: no punching that. Back off far enough to get an angle
		// on it instead of standing underneath.
		preferred = max( preferred, BOT_TITAN_ELEVATED_TARGET_DIST )
	}
	else
	{
		local wantsPunch = !IsTitanEntity( target ) || targetFrac < BOT_TITAN_PRESS_HEALTH || targetFrac < ownFrac
		if ( wantsPunch && Time() > brain.meleeBlockedUntil )
			preferred = BOT_TITAN_MELEE_RUSH_DIST * 0.8
	}
	// Just got stuck charging in (see TitanStuckResponse): hold range for a while instead.
	if ( Time() < brain.titanBackOffUntil && !brain.swatting )
		preferred = max( preferred, IsTitanEntity( target ) ? BOT_TITAN_RANGE_MAX : BOT_TITAN_ELEVATED_TARGET_DIST )

	local radial = 0.0
	if ( dist > preferred + BOT_COMBAT_RANGE_SLACK )
		radial = 1.0
	else if ( dist < preferred - BOT_COMBAT_RANGE_SLACK )
		radial = -0.6
	return perp * 0.8 + dir * radial
}

// Orbit direction (1 / -1, see GetTitanCombatMove) away from the nearest friendly titan,
// or `fallback` when there is none nearby.
function ChooseTitanOrbitDir( bot, dirToTarget, fallback )
{
	local origin = bot.GetOrigin()
	local nearest = null
	local nearestDist = 0.0
	foreach ( ally in GetTitansOfTeam( bot.GetTeam(), origin, BOT_TITAN_COMBAT_SPACING_DIST * 1.5 ) )
	{
		if ( ally == bot )
			continue
		local dist = Distance( origin, ally.GetOrigin() )
		if ( nearest == null || dist < nearestDist )
		{
			nearest = ally
			nearestDist = dist
		}
	}
	if ( nearest == null )
		return fallback
	local perp = Vector( -dirToTarget.y, dirToTarget.x, 0 )
	return ( nearest.GetOrigin() - origin ).Dot( perp ) > 0.0 ? -1.0 : 1.0
}

// Away from friendly titans inside radius, stronger the closer they are; null if none.
// Wider in a fight, so a team of titans spreads around its target instead of standing in a pile.
function GetTitanSpacingPush( bot, radius = BOT_TITAN_SPACING_DIST )
{
	local origin = bot.GetOrigin()
	local push = Vector( 0, 0, 0 )
	local found = false
	foreach ( ally in GetTitansOfTeam( bot.GetTeam(), origin, radius ) )
	{
		if ( ally == bot )
			continue
		local away = origin - ally.GetOrigin()
		local dist = Length2D( away )
		if ( dist >= radius )
			continue
		if ( dist < 1.0 )
		{
			// Right on top of each other: pick a side.
			away = bot.GetRightVector()
			dist = 1.0
		}
		local weight = 1.0 - dist / radius
		push = push + Vector( away.x / dist, away.y / dist, 0 ) * weight
		found = true
	}
	return found ? push : null
}

// Titans bunched up with other friendly titans in a fight: some break off and come back from
// a new angle (same idea as UpdateReposition for pilots; the titan keeps shooting on the way).
function UpdateTitanReposition( bot, brain, hasVisibleTarget )
{
	local now = Time()
	if ( now < brain.repositionUntil )
	{
		if ( brain.repositionPoint == null || Distance( bot.GetOrigin(), brain.repositionPoint ) < BOT_FLANK_REACHED )
			brain.repositionUntil = 0.0
		return
	}
	if ( !hasVisibleTarget || now < brain.nextBrawlCheck || now < brain.nextRepositionTime )
		return
	brain.nextBrawlCheck = now + BOT_BRAWL_CHECK_INTERVAL

	// The list includes this bot's own titan.
	local allies = GetTitansOfTeam( bot.GetTeam(), bot.GetOrigin(), BOT_TITAN_BUNCHED_DIST ).len() - 1
	if ( allies < 1 || RandomInt( 100 ) >= BOT_TITAN_REPOSITION_CHANCE )
		return

	local point = ChooseRepositionPoint( bot, brain, brain.target.GetOrigin() )
	if ( point == null )
		return
	brain.repositionPoint = point.pos
	brain.repositionUntil = now + BOT_REPOSITION_TIME
	brain.nextRepositionTime = now + BOT_REPOSITION_COOLDOWN
	brain.nextRepathTime = 0.0
}

// Titans of a team (player titans and auto-titans) within radius of origin (-1 = whole map).
// Titans out on our team minus titans out on the other (players in titans and auto-titans, map-wide).
function GetTeamTitanLead( bot )
{
	local team = bot.GetTeam()
	local origin = bot.GetOrigin()
	return GetTitansOfTeam( team, origin, -1 ).len() - GetTitansOfTeam( GetOtherTeam( team ), origin, -1 ).len()
}

function GetTitansOfTeam( team, origin, radius )
{
	local titans = GetNPCArrayEx( "npc_titan", team, origin, radius.tointeger() )
	foreach ( player in GetPlayerArrayOfTeam( team ) )
	{
		if ( IsAlive( player ) && player.IsTitan() && ( radius < 0 || Distance( origin, player.GetOrigin() ) < radius ) )
			titans.append( player )
	}
	return titans
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
	{
		brain.usedDoubleJump = false	// touching a wall gives the double jump back
		return now - brain.wallrunStartTime > brain.wallrunHopAfter ? BOT_IN_JUMP : 0
	}

	// Holding a spot for a ranged shot, or fighting near a door / indoors: stay on the ground.
	if ( brain.combatHold || brain.careful )
		return 0

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

function UpdateFiring( bot, brain, canShoot )
{
	if ( !canShoot || Time() - brain.targetAcquiredTime < brain.reactionTime )
	{
		brain.firing = false
		return 0
	}

	// Hands off the trigger while a weapon switch plays out.
	if ( Time() - brain.weaponSwitchTime < BOT_WEAPON_DEPLOY_TIME )
	{
		brain.firing = false
		return 0
	}

	// Only shoot once on target, by this bot's own standard: trigger-happy ones open up while
	// still swinging onto the target, patient ones wait; everyone is pickier at long range.
	local inTitan = bot.IsTitan()
	local targetDist = Distance( bot.GetOrigin(), brain.target.GetOrigin() )
	local triggerAngle = inTitan ? min( brain.triggerAngle, BOT_TITAN_TRIGGER_ANGLE ) : brain.triggerAngle
	local maxAngle = BotClamp( triggerAngle * 800.0 / max( targetDist, 1.0 ), 2.0, triggerAngle )
	// (A rider: the part of it AimAtTarget aims at, seen over the hull; its center is in the titan.)
	local aimPoint = brain.target.GetWorldSpaceCenter()
	if ( brain.targetAimOffset != null && IsRodeoing( brain.target ) )
		aimPoint = brain.target.GetOrigin() + brain.targetAimOffset
	local toTarget = VectorToAngles( aimPoint - bot.EyePosition() )
	local angleOff = fabs( NormalizeYaw( toTarget.y - brain.yaw ) )
	local onTarget = angleOff <= maxAngle

	local now = Time()
	local weapon = bot.GetActiveWeapon()
	local fireMode = IsValid( weapon ) ? GetWeaponFireMode( weapon ) : null
	if ( fireMode == "charge" )
	{
		// Charge Rifle: start charging once roughly lined up and keep holding while the aim
		// settles (letting go early wastes the charge). Let go when the shot went off (the clip
		// dropped), when fully charged and on target, or after holding too long either way.
		if ( !brain.firing )
		{
			if ( now < brain.nextFireToggle || angleOff > BOT_AT_CHARGE_START_ANGLE )
				return 0
			brain.firing = true
			brain.chargeStart = now
			brain.chargeClip = weapon.GetWeaponPrimaryClipCount()
			brain.atAimingTime = now
			return BOT_IN_ATTACK
		}
		brain.atAimingTime = now
		local fired = weapon.GetWeaponPrimaryClipCount() < brain.chargeClip
		local charged = weapon.GetWeaponChargeFraction() >= 1.0
		if ( fired || now - brain.chargeStart > BOT_AT_CHARGE_MAX_HOLD || ( charged && onTarget ) )
		{
			brain.firing = false
			brain.nextFireToggle = now + BOT_AT_PAUSE
			return 0
		}
		return BOT_IN_ATTACK
	}

	// Archer: the sights are up (see UpdateAds) and it's locking on: that counts as aiming at
	// the titan, even before the crosshair is on it (keeps a peek out from cover going).
	if ( fireMode == "lock" && IsSmartAmmoLocking( weapon ) )
		brain.atAimingTime = now

	if ( !onTarget )
	{
		brain.firing = false
		return 0
	}

	if ( fireMode == "lock" )
	{
		// Archer: UpdateAds keeps the sights up; pull the trigger only once locked on
		// (tapped, it fires once per press).
		brain.firing = !brain.firing && IsSmartAmmoLocked( weapon )
		return brain.firing ? BOT_IN_ATTACK : 0
	}
	if ( fireMode == "guided" )
	{
		// Archer with guided missiles: no lock-on, the rocket follows the sights. Tap the trigger
		// only while aiming down sights (UpdateAds holds them), and keep the aim on the target.
		if ( !brain.wantAds )
		{
			brain.firing = false
			return 0
		}
		brain.atAimingTime = now
		brain.firing = !brain.firing
		return brain.firing ? BOT_IN_ATTACK : 0
	}

	if ( Time() > brain.nextFireToggle )
	{
		brain.firing = !brain.firing
		local burst = brain.usingAntiTitan ? BOT_AT_BURST : brain.skill.burst * brain.burstScale
		local pause = brain.usingAntiTitan ? BOT_AT_PAUSE : brain.skill.pause * brain.pauseScale
		// Far away: shorter bursts with longer gaps, so recoil and spread reset between them.
		if ( !brain.usingAntiTitan && targetDist > BOT_HOLD_DIST * 1.5 )
		{
			burst *= 0.6
			pause *= 1.5
		}
		// No two bursts alike, and now and then a longer gap to re-settle the aim. In a titan:
		// long bursts, short gaps, no hesitating.
		burst *= RandomFloat( 0.6, 1.5 )
		pause *= RandomFloat( 0.6, 1.5 )
		if ( inTitan )
		{
			burst = max( burst, brain.skill.burst )
			pause *= BOT_TITAN_PAUSE_SCALE
		}
		else if ( !brain.firing && RandomInt( 100 ) < BOT_FIRE_HESITATE_CHANCE )
			pause += RandomFloat( 0.2, 0.6 )
		brain.nextFireToggle = Time() + ( brain.firing ? burst : pause )
	}
	if ( !brain.firing )
		return 0
	// Semi-auto weapons: press, release, press... for the length of the burst.
	if ( IsValid( weapon ) && IsSemiAutoWeapon( weapon ) )
	{
		brain.triggerPulse = !brain.triggerPulse
		return brain.triggerPulse ? BOT_IN_ATTACK : 0
	}
	return BOT_IN_ATTACK
}

// How long before the first shot at a new target: the skill's reaction with human spread,
// slower when it showed up off to the side or behind, or when we're the one being shot at.
function RollReactionTime( bot, brain, target )
{
	local reaction = brain.skill.reaction * RandomFloat( 0.7, 1.6 )
	local toTarget = VectorToAngles( target.GetWorldSpaceCenter() - bot.EyePosition() )
	local offAngle = fabs( NormalizeYaw( toTarget.y - brain.yaw ) )
	if ( offAngle > 90.0 )
		reaction += RandomFloat( 0.2, 0.45 )
	else if ( offAngle > 40.0 )
		reaction += RandomFloat( 0.05, 0.2 )
	if ( Time() < brain.underFireUntil )
		reaction += RandomFloat( 0.0, 0.2 )
	if ( bot.IsTitan() )
		reaction *= IsTitanEntity( target ) ? BOT_TITAN_REACTION_SCALE : BOT_TITAN_VS_SMALL_REACTION_SCALE
	return reaction
}

// Aim at a target with lead for both sides' movement and a persistent error that settles
// while tracking. A fresh target starts with a bigger error (the "flick"); being airborne,
// moving fast or hipfiring keeps the wobble up, aiming down sights steadies it.
function AimAtTarget( bot, brain, target )
{
	local inTitan = bot.IsTitan()
	// In a titan the aim is steady against other titans; against a pilot (small, fast, wallrunning)
	// a titan's guns are no laser, or titans just mow pilots down and the match snowballs.
	local smallTarget = inTitan && !IsTitanEntity( target )
	local aimError = brain.skill.aimError * ( inTitan ? ( smallTarget ? BOT_TITAN_VS_SMALL_AIM_ERROR_SCALE : BOT_TITAN_AIM_ERROR_SCALE ) : 1.0 )
	local eye = bot.EyePosition()
	if ( brain.aimErrTarget != target )
	{
		brain.aimErrTarget = target
		// A flick usually overshoots: the error lands past the target, in the direction of the swing.
		local swing = NormalizeYaw( VectorToAngles( target.GetWorldSpaceCenter() - eye ).y - brain.yaw )
		local swingSign = swing >= 0.0 ? 1.0 : -1.0
		if ( RandomInt( 100 ) < brain.overshootChance )
			brain.aimErrYaw = swingSign * RandomFloat( 0.4, 1.0 ) * aimError * BOT_AIM_FLICK_ERROR
		else
			brain.aimErrYaw = RandomFloat( -1.0, 1.0 ) * aimError * BOT_AIM_FLICK_ERROR
		brain.aimErrPitch = RandomFloat( -0.5, 0.5 ) * aimError * BOT_AIM_FLICK_ERROR
	}

	local ownSpeed = Length2D( bot.GetVelocity() )
	local wobble = 1.0
	if ( !bot.IsOnGround() && !bot.IsWallRunning() )
		wobble += 1.0
	if ( ownSpeed > 250.0 )
		wobble += 0.5
	// Getting shot rattles the aim.
	if ( Time() < brain.underFireUntil )
		wobble += 0.5
	if ( brain.wantAds )
		wobble *= 0.5

	local noise = aimError * BOT_AIM_NOISE * wobble
	brain.aimErrYaw = brain.aimErrYaw * BOT_AIM_SETTLE + RandomFloat( -noise, noise )
	brain.aimErrPitch = brain.aimErrPitch * BOT_AIM_SETTLE + RandomFloat( -noise, noise ) * 0.5

	local point = target.GetWorldSpaceCenter()
	local targetVel = target.GetVelocity()
	if ( IsRodeoing( target ) )
	{
		// A rider: at the part of it seen over the hull (see GetRiderVisiblePoint), else the head;
		// the center is usually inside the titan, which soaks the shots. It moves with the titan.
		point = brain.targetAimOffset != null ? target.GetOrigin() + brain.targetAimOffset : target.EyePosition()
		local soul = target.GetTitanSoulBeingRodeoed()
		local titan = soul.GetTitan()
		if ( IsValid( titan ) )
			targetVel = titan.GetVelocity()
	}
	// Pilots: a bit above the center, towards the chest.
	else if ( target.IsPlayer() && !target.IsTitan() )
		point = point + ( target.EyePosition() - point ) * 0.3
	// Lead moving targets: by the think delay, plus the projectile's flight time for slow
	// projectiles. Some bots lead well, others trail behind; in a titan everyone leads properly.
	local leadSkill = ( inTitan && !smallTarget ) ? max( brain.leadSkill, BOT_TITAN_MIN_LEAD_SKILL ) : brain.leadSkill
	local leadTime = BOT_AIM_LEAD_TIME
	local speed = BotGetProjectileSpeed( bot.GetActiveWeapon() )
	if ( speed > 0.0 )
		leadTime += Distance( eye, point ) / speed
	leadTime = min( leadTime * leadSkill, BOT_LEAD_MAX_TIME )
	point = point + ( targetVel - bot.GetVelocity() ) * leadTime

	local angles = VectorToAngles( point - eye )
	AimTowards( brain, angles.y + brain.aimErrYaw, NormalizeYaw( angles.x ) + brain.aimErrPitch )
}

// Projectile speed of a weapon for leading shots, or 0 for hitscan / unknown.
function BotGetProjectileSpeed( weapon )
{
	if ( !IsValid( weapon ) )
		return 0.0
	// Homing / guided rockets steer themselves: leading them only throws the aim off.
	local fireMode = GetWeaponFireMode( weapon )
	if ( fireMode == "lock" || fireMode == "guided" )
		return 0.0
	local weaponClass = weapon.GetWeaponClassName()
	return weaponClass in file.projectileSpeeds ? file.projectileSpeeds[ weaponClass ] : 0.0
}

// Mouse-like turning: big swings fast, the last few degrees slower (a fraction of what's left
// each think, at this bot's own smoothness), never faster than the skill's turn speed.
function AimTowards( brain, desiredYaw, desiredPitch )
{
	// Swatting a pilot off a rodeo attempt: whip around fast and decisively.
	local turn = brain.skill.turnSpeed * ( brain.swatting ? BOT_SWAT_TURN_BONUS : 1.0 )
	local smooth = brain.swatting ? max( brain.aimSmooth, 0.85 ) : brain.aimSmooth
	local yawDelta = NormalizeYaw( desiredYaw - brain.yaw )
	local pitchDelta = desiredPitch - brain.pitch
	local yawStep = BotClamp( yawDelta * smooth + ( yawDelta >= 0.0 ? 0.3 : -0.3 ), -turn, turn )
	local pitchStep = BotClamp( pitchDelta * smooth, -turn, turn )
	if ( fabs( yawStep ) > fabs( yawDelta ) )
		yawStep = yawDelta
	brain.yaw = NormalizeYaw( brain.yaw + yawStep )
	brain.pitch = BotClamp( brain.pitch + pitchStep, -89.0, 89.0 )
}

// Hold ADS for shots at range. The button bit is probed in game: while unconfirmed, a bot that
// wants to aim holds the current candidate and the next think checks whether the weapon saw it.
function UpdateAds( bot, brain, isTitan, hasVisibleTarget )
{
	local weapon = bot.GetActiveWeapon()
	brain.wantAds = false
	if ( !hasVisibleTarget || brain.fleeing || !IsValid( weapon ) || file.adsBit == 0 )
	{
		brain.adsHeldBit = 0
		return 0
	}
	// Titan weapons whose ADS changes how they fire rather than how accurate they are.
	local weaponClass = weapon.GetWeaponClassName()
	if ( weaponClass == "mp_titanweapon_rocket_launcher" || weaponClass == "mp_titanweapon_triple_threat" || weaponClass == "mp_titanweapon_shotgun" )
		return 0
	// Weapons that stop working when aimed (the smart pistol doesn't lock on in ADS).
	if ( WeaponBlocksAds( weapon ) )
	{
		brain.adsHeldBit = 0
		return 0
	}

	// The Archer locks on (or guides its missile) only through the sights, at any range.
	local fireMode = GetWeaponFireMode( weapon )
	local needsAds = !isTitan && ( fireMode == "lock" || fireMode == "guided" )
	local dist = Distance( bot.GetOrigin(), brain.target.GetOrigin() )
	local tooClose = dist < ( isTitan ? BOT_TITAN_MELEE_RUSH_DIST * 1.5 : BOT_ADS_MIN_DIST )
	if ( ( tooClose && !needsAds ) || Time() - brain.targetAcquiredTime < brain.skill.reaction * 0.5
		|| Time() - brain.weaponSwitchTime < BOT_WEAPON_DEPLOY_TIME )
	{
		brain.adsHeldBit = 0
		return 0
	}

	if ( file.adsBit == null )
	{
		// Held the candidate since last think: did it register?
		local candidate = file.adsCandidates[ file.adsProbeIndex ]
		if ( brain.adsHeldBit == candidate )
		{
			if ( weapon.IsWeaponAdsButtonPressed() )
			{
				file.adsBit = candidate
				printt( "BotAI: ADS button bit is", candidate )
			}
			else if ( ++file.adsProbeFails >= BOT_ADS_PROBE_CHECKS )
			{
				file.adsProbeFails = 0
				file.adsProbeIndex++
				if ( file.adsProbeIndex >= file.adsCandidates.len() )
				{
					file.adsBit = 0
					printt( "BotAI: no ADS button bit found, bots will hipfire" )
					brain.adsHeldBit = 0
					return 0
				}
			}
		}
		brain.adsHeldBit = file.adsBit != null ? file.adsBit : file.adsCandidates[ file.adsProbeIndex ]
	}
	else
	{
		brain.adsHeldBit = file.adsBit
	}

	brain.wantAds = true
	return brain.adsHeldBit
}

// Smart ammo weapons (the smart pistol) with "smart_ammo_allow_ads_lock 0" don't lock on while
// aiming down sights, so a bot must never ADS with them. The Archer is smart ammo too, but it
// only works through its sights and has its own fire mode (see GetWeaponFireMode).
function WeaponBlocksAds( weapon )
{
	local weaponClass = weapon.GetWeaponClassName()
	if ( weaponClass in file.noAds )
		return file.noAds[ weaponClass ]

	local blocks = false
	try
	{
		local searchAngle = weapon.GetWeaponInfoFileKeyField( "smart_ammo_search_angle" )
		local adsLock = weapon.GetWeaponInfoFileKeyField( "smart_ammo_allow_ads_lock" )
		local fireMode = GetWeaponFireMode( weapon )
		blocks = searchAngle != null && ( adsLock == null || adsLock.tointeger() == 0 ) && fireMode != "lock" && fireMode != "guided"
	}
	catch ( e ) {}
	file.noAds[ weaponClass ] <- blocks
	return blocks
}

// Semi-automatic weapons fire once per trigger press, so holding the button for a whole burst
// gives a single shot: the trigger has to be pulsed.
function IsSemiAutoWeapon( weapon )
{
	local weaponClass = weapon.GetWeaponClassName()
	if ( weaponClass in file.semiAuto )
		return file.semiAuto[ weaponClass ]

	local semiAuto = false
	try { semiAuto = weapon.GetWeaponInfoFileKeyField( "fire_mode" ) == "semi-auto" }
	catch ( e ) {}
	file.semiAuto[ weaponClass ] <- semiAuto
	return semiAuto
}

// Taking damage breaks a ranged hold for a moment: dodge first, settle again after.
function UpdateUnderFire( bot, brain )
{
	local health = bot.GetHealth()
	if ( health < brain.lastHealth )
		brain.underFireUntil = Time() + RandomFloat( BOT_UNDER_FIRE_MIN, BOT_UNDER_FIRE_MAX )
	brain.lastHealth = health
}

// Damage falloff distances of a weapon, read once per weapon class from its weapon file.
function GetWeaponRanges( weapon )
{
	local weaponClass = weapon.GetWeaponClassName()
	if ( weaponClass in file.weaponRanges )
		return file.weaponRanges[ weaponClass ]

	local ranges = { near = 800.0, far = 1500.0 }
	try
	{
		local near = weapon.GetWeaponInfoFileKeyField( "damage_near_distance" )
		local far = weapon.GetWeaponInfoFileKeyField( "damage_far_distance" )
		if ( near != null )
			ranges.near = near.tofloat()
		if ( far != null )
			ranges.far = far.tofloat()
	}
	catch ( e ) {}
	file.weaponRanges[ weaponClass ] <- ranges
	return ranges
}

// Inside this, a pilot stops travelling and fights with what's in hand.
function GetPilotEngageDist( bot )
{
	local weapon = bot.GetActiveWeapon()
	if ( !IsValid( weapon ) )
		return BOT_PILOT_ENGAGE_MIN
	return BotClamp( GetWeaponRanges( weapon ).far, BOT_PILOT_ENGAGE_MIN, BOT_PILOT_ENGAGE_MAX )
}

// The range this pilot likes to fight at with its current weapon.
function GetPilotPreferredDist( bot, brain )
{
	local weapon = bot.GetActiveWeapon()
	local near = IsValid( weapon ) ? GetWeaponRanges( weapon ).near : 600.0
	return BotClamp( near * brain.rangeFactor, BOT_PILOT_RANGE_MIN, BOT_PILOT_RANGE_MAX )
}

// Always reload when dry. Out of a fight, top up once the clip is under this bot's own
// threshold: some reload after every few shots, others only ever run dry.
function UpdateReload( bot, brain, inFight )
{
	local weapon = bot.GetActiveWeapon()
	if ( !IsValid( weapon ) )
		return 0
	local clip = weapon.GetWeaponPrimaryClipCount()
	if ( clip == 0 )
		return BOT_IN_RELOAD
	// Hiding behind cover (or told to reload): top up whenever the clip isn't full.
	if ( brain.wantReload )
	{
		local size = GetWeaponClipSize( weapon )
		return size > 1 && clip < size ? BOT_IN_RELOAD : 0
	}
	if ( inFight || Time() - brain.targetLastSeenTime < 1.5 || brain.reloadAt <= 0.0 || Time() < brain.nextReloadCheck )
		return 0

	brain.nextReloadCheck = Time() + 1.0
	local clipSize = GetWeaponClipSize( weapon )
	return clipSize > 1 && clip < clipSize * brain.reloadAt ? BOT_IN_RELOAD : 0
}

// Magazine size from the weapon file, cached per class (0 if unknown).
function GetWeaponClipSize( weapon )
{
	local weaponClass = weapon.GetWeaponClassName()
	if ( weaponClass in file.clipSizes )
		return file.clipSizes[ weaponClass ]

	local size = 0
	try
	{
		local value = weapon.GetWeaponInfoFileKeyField( "ammo_clip_size" )
		if ( value != null )
			size = value.tointeger()
	}
	catch ( e ) {}
	file.clipSizes[ weaponClass ] <- size
	return size
}

function IsTitanEntity( ent )
{
	return ent.IsPlayer() ? ent.IsTitan() : ent.GetClassname() == "npc_titan"
}

// A titan fresh from titanfall, still inside its dome shield (nothing gets through it).
function IsInBubbleShield( ent )
{
	if ( !IsTitanEntity( ent ) )
		return false
	local soul = ent.GetTitanSoul()
	return IsValid( soul ) && IsValid( soul.bubbleShield )
}

// Enemy pilot currently riding a titan (ours or anyone's).
function IsRodeoing( ent )
{
	return ent.IsPlayer() && !ent.IsTitan() && IsValid( ent.GetTitanSoulBeingRodeoed() )
}

// An enemy titan within dist of pos, from the pilot's titan scan (brain.titanEnemies: every
// enemy titan within BOT_TITAN_FIGHT_RADIUS, refreshed by ScanTitanFight each half second).
function IsNearEnemyTitan( brain, pos, dist )
{
	foreach ( titan in brain.titanEnemies )
	{
		if ( IsValid( titan ) && IsAlive( titan ) && Distance( titan.GetOrigin(), pos ) < dist )
			return true
	}
	return false
}

// On foot: anti-titan weapon out while an enemy titan is the target or close by in sight, the
// primary otherwise. The choice is held for a few seconds: switching every time the nearest
// target changed between a titan and a grunt kept restarting the (slow) anti-titan deploy, so the
// weapon never actually came out.
function UpdateWeaponChoice( bot, brain, isTitan )
{
	if ( isTitan )
		return

	local active = bot.GetActiveWeapon()
	brain.usingAntiTitan = IsValid( active ) && IsAntiTitanWeapon( active )
	CheckWeaponSwitch( bot, brain, active )

	if ( Time() < brain.nextWeaponSwitchTime )
		return

	local weapon = WantsAntiTitanWeapon( bot, brain ) ? GetBotUsableAntiTitanWeapon( bot ) : null
	if ( weapon == null )
		weapon = GetPilotAntiPersonnelWeapon( bot )
	if ( weapon == null )
		weapon = GetPilotSideArmWeapon( bot )
	if ( weapon == null || ( IsValid( active ) && active == weapon ) )
		return

	bot.SetActiveWeapon( weapon.GetWeaponClassName() )
	brain.weaponWanted = weapon
	brain.weaponSwitchTime = Time()
	brain.weaponCheckDone = false
	brain.nextWeaponSwitchTime = Time() + BOT_WEAPON_HOLD_TIME
}

function IsAntiTitanWeapon( weapon )
{
	return weapon.GetWeaponInfoFileKeyField( "is_anti_titan" ) == 1
}

// Anti-titan weapon out? Kept out for a while once a titan was around (each switch costs a slow
// deploy), and while peeking at titans from cover; but an enemy pilot in sight up close is a
// gunfight, and that needs the primary.
function WantsAntiTitanWeapon( bot, brain )
{
	// On the evac run titans aren't fought: the primary stays out (a launcher's ADS / charge
	// would stop the sprint).
	if ( brain.evac != null )
		return false
	local now = Time()
	local target = brain.target
	local targetKnown = target != null && IsValid( target ) && now - brain.targetLastSeenTime < 3.0
	local pilotInSight = targetKnown && now - brain.targetLastSeenTime < BOT_THINK_INTERVAL * 2 && target.IsPlayer() && !target.IsTitan()
	if ( pilotInSight && Distance( bot.GetOrigin(), target.GetOrigin() ) < BOT_AT_PILOT_SWAP_DIST )
		return false

	if ( targetKnown && IsTitanEntity( target ) )
	{
		brain.atWantUntil = now + BOT_AT_KEEP_TIME
		return true
	}
	if ( brain.cover != null && brain.cover.titanCover && brain.cover.canPeek )
		return true
	// The keep-out time doesn't hold the launcher against a pilot we're now fighting (the Archer
	// can't even lock onto one); a titan still in sight below does.
	if ( now < brain.atWantUntil && !pilotInSight )
		return true

	local eye = bot.EyePosition()
	foreach ( titan in GetTitansOfTeam( GetOtherTeam( bot.GetTeam() ), bot.GetOrigin(), BOT_PILOT_AT_ENGAGE_DIST ) )
	{
		if ( IsAlive( titan ) && CanSee( bot, eye, titan ) )
		{
			brain.atWantUntil = now + BOT_AT_KEEP_TIME
			return true
		}
	}
	return false
}

// The Archer only fires with ADS held (lock-on starts on zoom in), so it's useless if the ADS
// button was never found; the bot then treats titans as if it had no anti-titan weapon.
function GetBotAntiTitanWeapon( bot )
{
	local weapon = GetPilotAntiTitanWeapon( bot )
	if ( weapon != null && weapon.GetWeaponClassName() == "mp_weapon_rocket_launcher" && file.adsBit == 0 )
		return null
	return weapon
}

// The anti-titan weapon, if it can be used right now (see GetBotAntiTitanWeapon) and still has
// ammo (loaded or in reserve); else null. An empty launcher is no reason to stand and fight a titan.
function GetBotUsableAntiTitanWeapon( bot )
{
	local weapon = GetBotAntiTitanWeapon( bot )
	if ( weapon == null || !BotWeaponHasAmmo( bot, weapon ) )
		return null
	return weapon
}

// Weapons that need more than holding the trigger: "lock" (Archer: ADS until locked on),
// "guided" (Archer with guided missiles: no lock-on, fired through the sights and steered by
// the aim), "charge" (Charge Rifle: hold until fully charged, then let go), or null.
function GetWeaponFireMode( weapon )
{
	local weaponClass = weapon.GetWeaponClassName()
	if ( weaponClass == "mp_weapon_rocket_launcher" )
	{
		local guided = false
		try { guided = weapon.HasMod( "guided_missile" ) }
		catch ( e ) {}
		return guided ? "guided" : "lock"
	}
	if ( weaponClass == "mp_weapon_defender" )
		return "charge"
	return null
}

// Server-side check that a requested switch went through, reported once per bot.
function CheckWeaponSwitch( bot, brain, active )
{
	if ( brain.weaponCheckDone || Time() - brain.weaponSwitchTime < BOT_WEAPON_SWITCH_CHECK )
		return
	brain.weaponCheckDone = true
	if ( !IsValid( brain.weaponWanted ) || ( IsValid( active ) && active == brain.weaponWanted ) )
		return

	if ( !( "botWeaponSwitchReported" in level ) )
		level.botWeaponSwitchReported <- {}
	local name = bot.GetPlayerName()
	if ( name in level.botWeaponSwitchReported )
		return
	level.botWeaponSwitchReported[ name ] <- true
	printt( "BotAI:", name, "asked for", brain.weaponWanted.GetWeaponClassName(), "but still has",
		IsValid( active ) ? active.GetWeaponClassName() : "nothing" )
}

// Archer lock-on complete on any target?
function IsSmartAmmoLocked( weapon )
{
	if ( !weapon.SmartAmmo_IsEnabled() )
		return false
	foreach ( target in weapon.SmartAmmo_GetTargets() )
	{
		if ( target.fraction >= 1.0 )
			return true
	}
	return false
}

// Archer lock-on under way on any target? (SmartAmmo_IsEnabled alone only means the sights are up.)
function IsSmartAmmoLocking( weapon )
{
	if ( !weapon.SmartAmmo_IsEnabled() )
		return false
	foreach ( target in weapon.SmartAmmo_GetTargets() )
	{
		if ( target.fraction > 0.01 )	// _smart_ammo.nut parks known targets at 0.0001
			return true
	}
	return false
}

// Tactical ability and ordnance, used when they help the bot survive a fight.
// Pressing one that isn't charged does nothing, so a failed press is just retried later.
function UpdateAbilities( bot, brain, isTitan, hasVisibleTarget )
{
	local pressed = 0
	local now = Time()
	local healthFrac = bot.GetHealth().tofloat() / max( bot.GetMaxHealth(), 1 )

	if ( now > brain.nextTacticalTime )
	{
		local useTactical = false
		if ( isTitan )
		{
			// Smoke / particle wall while taking a beating. The vortex shield is held, not tapped
			// (see UpdateTitanVortex).
			local tactical = bot.GetOffhandWeapon( 1 )
			local isVortex = IsValid( tactical ) && tactical.GetWeaponClassName() == "mp_titanweapon_vortex_shield"
			useTactical = !isVortex && hasVisibleTarget && healthFrac < 0.75
		}
		else
		{
			// Cloak/stim to break away as soon as a retreat starts, or when a fight is going badly.
			// Out of combat, the odd use while hunting (active radar pings who's around).
			// On the evac run: stim / cloak the moment anything threatens the way to the ship.
			useTactical = ( brain.fleeing && now - brain.fleeStartTime < 1.0 )
				|| ( hasVisibleTarget && healthFrac < BOT_TACTICAL_LOW_HEALTH )
				|| ( !hasVisibleTarget && brain.prey != null && RandomInt( 150 ) == 0 )
				|| ( brain.evac != null && ( hasVisibleTarget || now < brain.underFireUntil || brain.titanEnemies.len() > 0 ) )
		}

		if ( useTactical )
		{
			pressed = pressed | BOT_IN_OFFHAND_TACTICAL
			brain.nextTacticalTime = now + RandomFloat( BOT_TACTICAL_RETRY_MIN, BOT_TACTICAL_RETRY_MAX )
		}
	}

	// Pilots on the evac run: no grenades (the throw turns the view and holds it on the arc,
	// skewing the run).
	if ( !isTitan && brain.evac != null )
		return pressed

	// Titan ordnance is held, not pressed: see UpdateTitanOrdnance.
	if ( isTitan || now <= brain.nextOrdnanceTime )
		return pressed

	// Pressing it with no charge left does nothing: don't burn the whole cooldown on that.
	local ordnance = bot.GetOffhandWeapon( 0 )
	if ( !IsValid( ordnance ) || ordnance.GetWeaponPrimaryClipCount() <= 0 )
	{
		brain.nextOrdnanceTime = now + BOT_ORDNANCE_NOT_READY
		return pressed
	}
	local profile = GetOrdnanceProfile( ordnance )

	// A throw now would cut short the weapon coming out, or a launcher that's shooting / locked on.
	if ( now - brain.weaponSwitchTime < BOT_WEAPON_DEPLOY_TIME
		|| ( brain.usingAntiTitan && ( brain.firing || IsAntiTitanLockedNow( bot ) ) ) )
	{
		brain.nextOrdnanceTime = now + BOT_ORDNANCE_BUSY_RETRY
		return pressed
	}

	// Pilots: where to throw, if anywhere this check. Running away, only satchels and mines are
	// worth it: dropped behind us, in the way of whoever is chasing.
	// (Dropped at our feet, looking down along the run: turning to face the pursuer would stall the
	// run, and the aim hold would keep turning back to the spot as we pass it.)
	local throwAt = null
	local origin = bot.GetOrigin()
	local drop = false
	if ( brain.fleeing )
	{
		drop = !brain.fleeDirect && profile.drop && brain.fleeFrom != null && Distance( origin, brain.fleeFrom ) < BOT_ORDNANCE_DROP_DIST
		if ( drop )
			throwAt = origin
	}
	else
	{
		throwAt = GetPilotGrenadeSpot( bot, brain, hasVisibleTarget, healthFrac, profile, ordnance )
	}
	if ( throwAt == null )
	{
		brain.nextOrdnanceTime = now + RandomFloat( BOT_ORDNANCE_RETRY_MIN, BOT_ORDNANCE_RETRY_MAX )
		return pressed
	}

	brain.lobPos = throwAt
	brain.lobProfile = profile
	brain.lobDrop = drop
	brain.lobUntil = now + BOT_ORDNANCE_LOB_TIME
	if ( drop )
		AimTowards( brain, brain.yaw, BOT_ORDNANCE_DROP_PITCH )
	else
		AimLob( bot, brain, throwAt, profile )
	pressed = pressed | BOT_IN_OFFHAND_ORDNANCE
	brain.nextOrdnanceTime = now + RandomFloat( BOT_ORDNANCE_COOLDOWN_MIN, BOT_ORDNANCE_COOLDOWN_MAX )
	return pressed
}

// Throw range and arc for this ordnance (see file.ordnanceProfiles); frag-like defaults otherwise.
function GetOrdnanceProfile( weapon )
{
	local weaponClass = weapon.GetWeaponClassName()
	if ( weaponClass in file.ordnanceProfiles )
		return file.ordnanceProfiles[ weaponClass ]
	return { minDist = BOT_ORDNANCE_MIN_DIST, maxDist = BOT_ORDNANCE_MAX_DIST, lift = 0.008, liftMax = 12.0, drop = false }
}

// The Archer out and locked on: a grenade now would throw the lock away.
function IsAntiTitanLockedNow( bot )
{
	local active = bot.GetActiveWeapon()
	return IsValid( active ) && GetWeaponFireMode( active ) == "lock" && IsSmartAmmoLocked( active )
}

// Where a pilot bot should throw its grenade right now, or null.
// - Target in sight (within this ordnance's range): titans always, pilots often (always when
//   we're losing), grunts and spectres always when bunched up and often on their own (arc grenades
//   even more often against spectres). A proximity mine goes in a soldier's path, short of it.
// - Pilot target that just ducked behind cover: at where it was last seen, it's still there.
function GetPilotGrenadeSpot( bot, brain, hasVisibleTarget, healthFrac, profile, ordnance )
{
	local target = brain.target
	if ( target == null || !IsValid( target ) || !IsAlive( target ) )
		return null

	local origin = bot.GetOrigin()
	local ordnanceClass = ordnance.GetWeaponClassName()
	if ( hasVisibleTarget )
	{
		local targetPos = target.GetOrigin()
		local dist = Distance( origin, targetPos )
		if ( dist < profile.minDist || dist > profile.maxDist )
			return null
		local isTitan = IsTitanEntity( target )
		local use = false
		if ( isTitan )
			use = true
		else if ( target.IsPlayer() )
			use = healthFrac < 0.7 || RandomInt( 100 ) < BOT_ORDNANCE_PILOT_CHANCE
		else
		{
			local chance = BOT_ORDNANCE_NPC_CHANCE
			if ( target.GetClassname() == "npc_spectre" && ordnanceClass == "mp_weapon_grenade_emp" )
				chance += BOT_ORDNANCE_SPECTRE_EMP_BONUS
			use = RandomInt( 100 ) < chance
				|| GetEnemyNPCs( target.GetTeam(), targetPos, BOT_NPC_GROUP_RADIUS ).len() >= BOT_NPC_GRENADE_GROUP
		}
		if ( !use )
			return null
		if ( !isTitan && ordnanceClass == "mp_weapon_proximity_mine" )
			return origin + ( targetPos - origin ) * 0.7
		return targetPos
	}

	// Flush it out of cover.
	if ( !target.IsPlayer() || IsTitanEntity( target ) || brain.targetLastSeenPos == null )
		return null
	local lost = Time() - brain.targetLastSeenTime
	if ( lost < BOT_ORDNANCE_COVER_MIN || lost > BOT_ORDNANCE_COVER_MAX )
		return null
	local dist = Distance( origin, brain.targetLastSeenPos )
	if ( dist < profile.minDist || dist > profile.maxDist )
		return null
	return RandomInt( 100 ) < BOT_ORDNANCE_COVER_CHANCE ? brain.targetLastSeenPos : null
}

//---------------------------------------------------------
// Titan ordnance
//---------------------------------------------------------
// How the titan's ordnance is fired: "lock" (Slaved Warheads: needs a full lock when pressed, or it
// dry-fires), "charge" (Multi-Target Missiles: locks build while held, fire on release), "tap".
function GetTitanOrdnanceMode( weapon )
{
	local weaponClass = weapon.GetWeaponClassName()
	if ( weaponClass == "mp_titanweapon_homing_rockets" )
		return "lock"
	if ( weaponClass == "mp_titanweapon_shoulder_rockets" )
		return "charge"
	return "tap"
}

// Off cooldown and loaded (same test the rocket pods use, see _titan_shared.nut).
function IsTitanOrdnanceReady( weapon )
{
	try
	{
		if ( !weapon.IsReadyToFire() || weapon.IsReloading() )
			return false
	}
	catch ( e ) {}
	local clipSize = GetWeaponClipSize( weapon )
	return clipSize <= 0 || weapon.GetWeaponPrimaryClipCount() > 0
}

// Rockets locked so far: a target's fraction counts its full locks (2.0 = two rockets on it).
function GetSmartAmmoLockCount( weapon )
{
	if ( !weapon.SmartAmmo_IsEnabled() )
		return 0.0
	local locks = 0.0
	foreach ( target in weapon.SmartAmmo_GetTargets() )
	{
		if ( target.fraction >= 1.0 )
			locks += floor( target.fraction )
	}
	return locks
}

// Titans always get the ordnance; grunts/spectres when bunched up; pilots often. The pilot roll is
// made once per BOT_TITAN_ORDNANCE_PILOT_SKIP, not every check (that came out as always).
function IsWorthTitanOrdnance( brain, target )
{
	if ( IsTitanEntity( target ) )
		return true
	if ( target.IsPlayer() )
	{
		local now = Time()
		if ( now < brain.ordnancePilotSkipUntil )
			return false
		if ( RandomInt( 100 ) < BOT_TITAN_ORDNANCE_PILOT_CHANCE )
			return true
		brain.ordnancePilotSkipUntil = now + BOT_TITAN_ORDNANCE_PILOT_SKIP
		return false
	}
	return GetEnemyNPCs( target.GetTeam(), target.GetOrigin(), BOT_NPC_GROUP_RADIUS ).len() >= BOT_TITAN_ORDNANCE_GROUP
}

// Vortex shield: hold the tactical to put it up and catch what's coming at us, let go to throw it
// all back where we're aiming (at the target: the aim stays on it). Put up when an enemy titan in
// sight is shooting at us (we're taking damage, or its rockets are flying our way); held a moment
// so it catches a volley, then released before the charge runs out (the game forces it at full).
// Returns the buttons to hold this tick.
function UpdateTitanVortex( bot, brain, hasVisibleTarget )
{
	local now = Time()
	local vortex = bot.GetOffhandWeapon( 1 )
	if ( !IsValid( vortex ) || vortex.GetWeaponClassName() != "mp_titanweapon_vortex_shield" )
	{
		brain.vortexHoldUntil = 0.0
		return 0
	}
	local charge = vortex.GetWeaponChargeFraction()	// how much of the shield's time is used up

	if ( brain.vortexHoldUntil > 0.0 )
	{
		// Let go: time's up, almost drained, or the target is gone (nothing to throw it at).
		local held = now - brain.vortexHoldStart
		if ( now >= brain.vortexHoldUntil || charge >= BOT_VORTEX_RELEASE_CHARGE
			|| ( !hasVisibleTarget && held > BOT_VORTEX_MIN_HOLD ) )
		{
			brain.vortexHoldUntil = 0.0
			brain.nextVortexTime = now + RandomFloat( BOT_VORTEX_COOLDOWN_MIN, BOT_VORTEX_COOLDOWN_MAX )
			return 0
		}
		return BOT_IN_OFFHAND_TACTICAL
	}

	if ( now < brain.nextVortexTime || !hasVisibleTarget || brain.fleeingNuke || brain.swatting || brain.ordnanceHoldUntil > 0.0
		|| charge > BOT_VORTEX_MAX_START_CHARGE || !IsTitanEntity( brain.target ) )
		return 0
	if ( Distance( bot.GetOrigin(), brain.target.GetOrigin() ) > BOT_VORTEX_MAX_DIST )
		return 0

	// Something to catch: hits coming in, or enemy rockets / grenades flying around us.
	local underFire = now < brain.underFireUntil
	local incoming = false
	if ( !underFire )
	{
		local enemyTeam = GetOtherTeam( bot.GetTeam() )
		incoming = GetProjectileArrayEx( "rpg_missile", enemyTeam, bot.GetOrigin(), BOT_VORTEX_PROJECTILE_RADIUS ).len() > 0
			|| GetProjectileArrayEx( "npc_grenade_frag", enemyTeam, bot.GetOrigin(), BOT_VORTEX_PROJECTILE_RADIUS ).len() > 0
	}
	if ( !underFire && !incoming )
		return 0

	brain.vortexHoldStart = now
	brain.vortexHoldUntil = now + RandomFloat( BOT_VORTEX_HOLD_MIN, BOT_VORTEX_HOLD_MAX )
	return BOT_IN_OFFHAND_TACTICAL
}

// In a titan: fire the ordnance whenever it's ready and there's something worth it in sight.
// Returns the buttons to hold this tick (for BotSetInput): a press is held for a moment (or, for
// Multi-Target Missiles, until enough locks are on), then released. A release is checked a bit
// later to have fired something; a press that never does is logged once per weapon class.
function UpdateTitanOrdnance( bot, brain, hasVisibleTarget )
{
	local now = Time()
	local weapon = bot.GetOffhandWeapon( 0 )

	if ( brain.ordnanceHoldUntil > 0.0 )
	{
		local release = now >= brain.ordnanceHoldUntil || !IsValid( weapon )
		if ( !release && brain.ordnanceMode == "charge" && now - brain.ordnanceHoldStart >= BOT_TITAN_ORDNANCE_LOCK_MIN )
			release = !hasVisibleTarget || GetSmartAmmoLockCount( weapon ) >= BOT_TITAN_ORDNANCE_LOCKS
		if ( !release )
			return BOT_IN_OFFHAND_ORDNANCE
		brain.ordnanceHoldUntil = 0.0
		brain.ordnanceVerifyAt = now + BOT_TITAN_ORDNANCE_VERIFY
		brain.nextOrdnanceTime = now + BOT_TITAN_ORDNANCE_AFTER
		return 0
	}

	if ( brain.ordnanceVerifyAt > 0.0 && now >= brain.ordnanceVerifyAt )
	{
		brain.ordnanceVerifyAt = 0.0
		if ( IsValid( weapon ) )
		{
			local fired = weapon.GetWeaponPrimaryClipCount() < brain.ordnanceClip || !IsTitanOrdnanceReady( weapon )
			local weaponClass = weapon.GetWeaponClassName()
			if ( !fired && !( weaponClass in file.ordnanceMissReported ) )
			{
				file.ordnanceMissReported[ weaponClass ] <- true
				printt( "BotAI:", bot.GetPlayerName(), "held", weaponClass, "(" + brain.ordnanceMode + ") but nothing fired" )
			}
		}
	}

	if ( !hasVisibleTarget )
		brain.ordnanceLockWaitSince = 0.0
	if ( now < brain.nextOrdnanceTime || !hasVisibleTarget || brain.fleeingNuke || !IsValid( weapon ) || brain.vortexHoldUntil > 0.0 )
		return 0
	brain.nextOrdnanceTime = now + BOT_TITAN_ORDNANCE_CHECK

	local target = brain.target
	if ( IsInBubbleShield( target ) || !IsTitanOrdnanceReady( weapon ) )
		return 0
	local dist = Distance( bot.GetOrigin(), target.GetOrigin() )
	if ( dist < BOT_TITAN_ORDNANCE_MIN_DIST || dist > BOT_TITAN_ORDNANCE_MAX_DIST || !IsWorthTitanOrdnance( brain, target ) )
		return 0

	local mode = GetTitanOrdnanceMode( weapon )
	if ( mode == "lock" )
	{
		// Pressed without a full lock it only dry-fires and starts the cooldown.
		local locked = false
		try { locked = IsSmartAmmoLocked( weapon ) }
		catch ( e ) {}
		if ( !locked )
		{
			// Never locking at all (the offhand's smart ammo not running for bots?) would just look
			// like a titan that doesn't use its ordnance: say so once.
			if ( brain.ordnanceLockWaitSince == 0.0 )
				brain.ordnanceLockWaitSince = now
			else if ( now - brain.ordnanceLockWaitSince > BOT_TITAN_ORDNANCE_LOCK_REPORT && !( "nolock" in file.ordnanceMissReported ) )
			{
				file.ordnanceMissReported[ "nolock" ] <- true
				printt( "BotAI:", bot.GetPlayerName(), "has had", weapon.GetWeaponClassName(), "ready on a target for",
					BOT_TITAN_ORDNANCE_LOCK_REPORT, "s without a lock" )
			}
			return 0
		}
		brain.ordnanceLockWaitSince = 0.0
	}
	else if ( mode == "charge" )
	{
		// Locking takes a while: not with the target already on top of us (we're punching it).
		if ( dist < BOT_TITAN_MELEE_RUSH_DIST )
			return 0
	}
	else
	{
		// Dumb-fire: only when actually pointed at the target.
		local toTarget = VectorToAngles( target.GetWorldSpaceCenter() - bot.EyePosition() )
		if ( fabs( NormalizeYaw( toTarget.y - brain.yaw ) ) > BOT_TITAN_ORDNANCE_ANGLE )
			return 0
	}

	brain.ordnanceMode = mode
	brain.ordnanceHoldStart = now
	brain.ordnanceHoldUntil = now + ( mode == "charge" ? BOT_TITAN_ORDNANCE_LOCK_MAX : BOT_TITAN_ORDNANCE_TAP_HOLD )
	brain.ordnanceClip = weapon.GetWeaponPrimaryClipCount()
	return BOT_IN_OFFHAND_ORDNANCE
}

// Satchels only go off on the clacker: once an enemy is on top of one of ours (and we're clear of
// it), set them all off after a short reaction, like the clacker's fire does (Player_DetonateSatchels).
// The enemy has to be in sight, or be the target we just lost behind cover (thrown on purpose).
function UpdateSatchelDetonation( bot, brain )
{
	if ( !( "activeSatchels" in bot.s ) )
		return
	ArrayRemoveInvalid( bot.s.activeSatchels )
	if ( bot.s.activeSatchels.len() == 0 )
	{
		brain.satchelDetonateAt = null
		return
	}

	if ( !SatchelHasVictim( bot, brain ) )
	{
		brain.satchelDetonateAt = null
		return
	}

	local now = Time()
	if ( brain.satchelDetonateAt == null )
	{
		brain.satchelDetonateAt = now + RandomFloat( BOT_SATCHEL_REACTION_MIN, BOT_SATCHEL_REACTION_MAX )
		return
	}
	if ( now < brain.satchelDetonateAt )
		return

	brain.satchelDetonateAt = null
	printt( "BotAI:", bot.GetPlayerName(), "detonating satchels" )
	Player_DetonateSatchels( bot )
}

function SatchelHasVictim( bot, brain )
{
	local origin = bot.GetOrigin()
	local eye = bot.EyePosition()
	local enemyTeam = GetOtherTeam( bot.GetTeam() )
	local justLost = brain.target != null && IsValid( brain.target ) && Time() - brain.targetLastSeenTime < BOT_ORDNANCE_COVER_MAX

	foreach ( satchel in bot.s.activeSatchels )
	{
		local pos = satchel.GetOrigin()
		if ( Distance( origin, pos ) < BOT_SATCHEL_SAFE_DIST )
			continue

		local enemies = GetEnemyNPCs( enemyTeam, pos, BOT_SATCHEL_SCAN_RADIUS )
		enemies.extend( GetNPCArrayEx( "npc_titan", enemyTeam, pos, BOT_SATCHEL_SCAN_RADIUS ) )
		enemies.extend( GetPlayerArrayOfTeam( enemyTeam ) )
		foreach ( enemy in enemies )
		{
			if ( !IsAlive( enemy ) )
				continue
			local reach = IsTitanEntity( enemy ) ? BOT_SATCHEL_TITAN_DIST : BOT_SATCHEL_TRIGGER_DIST
			if ( Distance( pos, enemy.GetOrigin() ) > reach )
				continue
			if ( ( justLost && enemy == brain.target ) || CanSee( bot, eye, enemy ) )
				return true
		}
	}
	return false
}

// Aim a grenade at a spot: higher the farther away it is, so it arcs onto it. Slow tosses
// (satchels, mines) need a much higher arc, see file.ordnanceProfiles.
function AimLob( bot, brain, spot, profile = null )
{
	local eye = bot.EyePosition()
	local angles = VectorToAngles( spot - eye )
	local liftPerUnit = profile != null ? profile.lift : 0.008
	local liftMax = profile != null ? profile.liftMax : 12.0
	local lift = min( Distance( eye, spot ) * liftPerUnit, liftMax )
	AimTowards( brain, angles.y, BotClamp( NormalizeYaw( angles.x ) - lift, -89.0, 89.0 ) )
}

// Titan dash: a tap of sprint while moving. It goes the way the titan is already moving, so
// sideways while strafing in a fight and along the escape route when running away.
function UpdateTitanDash( bot, brain, hasVisibleTarget, inEngageRange, forward, side )
{
	local now = Time()
	// A dash would carry us out of our own electric smoke with a rider still on.
	if ( IsHoldingInSmoke( bot, brain ) )
		return 0

	// Just got stuck (see TitanStuckResponse): dash out the way we're stepping, cooldown or not
	// (the dash meter is the real limit).
	if ( brain.unstickDash )
	{
		brain.unstickDash = false
		if ( now < brain.unstickUntil )
		{
			brain.nextDashTime = now + RandomFloat( BOT_TITAN_DASH_COOLDOWN_MIN, BOT_TITAN_DASH_COOLDOWN_MAX )
			return BOT_IN_DODGE
		}
	}

	if ( now < brain.nextDashTime )
		return 0

	// Rodeo attempt from behind, too close to turn and punch in time: dash away from the pilot
	// (the dash goes the way we're moving, so move away from it this tick and dash).
	if ( IsRodeoThreatBehind( bot, brain ) )
	{
		brain.nextDashTime = now + RandomFloat( BOT_TITAN_DASH_COOLDOWN_MIN, BOT_TITAN_DASH_COOLDOWN_MAX )
		return BOT_IN_DODGE
	}

	local hurt = bot.GetHealth() < bot.GetMaxHealth() * 0.5
	local dodgeInFight = inEngageRange && fabs( side ) > 0.5 && RandomInt( hurt ? 2 : 5 ) == 0
	local breakAway = brain.fleeing && now - brain.fleeStartTime < 0.5
	// Target in sight but still far: dash straight at it to start the brawl sooner.
	local dashIn = hasVisibleTarget && !brain.fleeing && forward > 0.7
		&& Distance( bot.GetOrigin(), brain.target.GetOrigin() ) > brain.titanPreferredDist + BOT_TITAN_DASH_IN_DIST
		&& RandomInt( 2 ) == 0
	if ( !dodgeInFight && !breakAway && !dashIn )
		return 0

	brain.nextDashTime = now + RandomFloat( BOT_TITAN_DASH_COOLDOWN_MIN, BOT_TITAN_DASH_COOLDOWN_MAX )
	return BOT_IN_DODGE
}

// Enemy pilot closing in on us (or right next to us), not yet on board: the one to deal with
// first. Nearest such pilot, or null.
function FindRodeoThreat( bot )
{
	local origin = bot.GetOrigin()
	local eye = bot.EyePosition()
	local best = null
	local bestDist = 0.0
	foreach ( enemy in GetPlayerArrayOfTeam( GetOtherTeam( bot.GetTeam() ) ) )
	{
		if ( !IsAlive( enemy ) || enemy.IsTitan() || IsValid( enemy.GetTitanSoulBeingRodeoed() ) )
			continue
		local toUs = origin - enemy.GetOrigin()
		local dist = Distance( origin, enemy.GetOrigin() )
		if ( dist > BOT_SWAT_DIST || !CanSee( bot, eye, enemy ) )
			continue
		local closing = enemy.GetVelocity().Dot( toUs * ( 1.0 / max( dist, 1.0 ) ) )
		if ( dist > BOT_SWAT_CLOSE_DIST && closing < BOT_SWAT_APPROACH_SPEED )
			continue
		if ( best == null || dist < bestDist )
		{
			best = enemy
			bestDist = dist
		}
	}
	return best
}

// Make the rodeo threat (if any) the target right away, with a quick reaction: the titan turns
// on it (faster, see AimTowards), the combat code charges it and UpdateMelee punches it.
function UpdateRodeoIntercept( bot, brain )
{
	local threat = FindRodeoThreat( bot )
	if ( threat == null )
		return

	if ( brain.target != threat )
	{
		brain.target = threat
		brain.targetAcquiredTime = Time()
		brain.reactionTime = brain.skill.reaction * RandomFloat( 0.4, 0.8 )
	}
	brain.targetLastSeenPos = threat.GetOrigin()
	brain.targetLastSeenTime = Time()
	brain.swatting = true
}

// The rodeo threat is close behind us: too late to turn and punch, get away from it instead.
function IsRodeoThreatBehind( bot, brain )
{
	if ( !brain.swatting || brain.target == null || !IsValid( brain.target ) )
		return false
	local toPilot = brain.target.GetOrigin() - bot.GetOrigin()
	local offAngle = fabs( NormalizeYaw( VectorToAngles( toPilot ).y - brain.yaw ) )
	return offAngle > BOT_SWAT_DODGE_ANGLE && Length2D( toPilot ) < BOT_SWAT_DODGE_DIST
}

// Kick / titan punch / execution when the target is right in front of us. Calls the same
// script entry point code uses for +melee, so the game's own melee rules apply.
// Swatting a pilot off a rodeo attempt ignores the "melee keeps missing" lockout and uses a
// wider reach and angle (the punch cone catches a pilot in mid-air).
function UpdateMelee( bot, brain, isTitan, hasVisibleTarget )
{
	local swat = isTitan && brain.swatting
	if ( !hasVisibleTarget || Time() < brain.nextMeleeTime || ( !swat && Time() < brain.meleeBlockedUntil ) )
		return

	// A pilot on a titan's back is shot off, never swung at (the swing lands on the titan).
	local target = brain.target
	if ( IsRodeoing( target ) )
		return
	// On foot a kick only ever goes at pilots and grunts: never at a titan (the user in one got
	// kicked at), not while running away or for the evac ship, and not with an enemy titan right
	// there, since the game's melee cone picks whatever is in front and that would be the titan.
	if ( !isTitan )
	{
		if ( IsTitanEntity( target ) || brain.fleeing || brain.evac != null )
			return
	}

	local range = swat ? BOT_SWAT_MELEE_RANGE : ( isTitan ? BOT_TITAN_MELEE_RANGE : BOT_PILOT_MELEE_RANGE )
	if ( Distance( bot.GetOrigin(), target.GetOrigin() ) > range )
		return

	local toTarget = VectorToAngles( target.GetWorldSpaceCenter() - bot.EyePosition() )
	if ( fabs( NormalizeYaw( toTarget.y - brain.yaw ) ) > ( swat ? BOT_SWAT_MELEE_ANGLE : 30.0 ) )
		return

	if ( !bot.PlayerMelee_CanMelee() || bot.PlayerMelee_GetState() != PLAYER_MELEE_STATE_NONE )
		return

	// Checked live (not from the half-second titan scan) since a swing is about to go out: a titan
	// that just walked up must not catch the kick.
	if ( !isTitan && GetTitansOfTeam( GetOtherTeam( bot.GetTeam() ), bot.GetOrigin(), BOT_MELEE_TITAN_CLEARANCE ).len() > 0 )
		return

	brain.nextMeleeTime = Time() + ( swat ? BOT_SWAT_COOLDOWN : BOT_MELEE_COOLDOWN )
	CodeCallback_OnMeleePressed( bot )
	thread BotMeleeFollowUp( bot, brain )
}

// The hit of a kick/punch is applied from an animation event of the first-person melee anim
// (CodeCallback_OnMeleeAttackAnimEvent), which doesn't seem to fire for bots: the swing plays,
// never connects, and the bot swings again forever at point blank. Fire the same callback
// during the swing (it's a no-op once something was hit), and if swings still keep missing,
// stop meleeing for a while and go back to shooting.
function BotMeleeFollowUp( bot, brain )
{
	bot.EndSignal( "OnDeath" )
	bot.EndSignal( "OnDestroy" )
	bot.EndSignal( "Disconnected" )

	local connected = false
	local endTime = Time() + BOT_MELEE_SWING_TIME
	wait BOT_MELEE_HIT_DELAY
	while ( Time() < endTime )
	{
		// Went into a synced execution instead: that's a success, the animation handles the rest.
		if ( bot.ContextAction_IsActive() )
		{
			connected = true
			break
		}
		if ( !bot.PlayerMelee_IsAttackActive() )
			break
		if ( !IsValid( bot.PlayerMelee_GetAttackHitEntity() ) )
			CodeCallback_OnMeleeAttackAnimEvent( bot )
		if ( IsValid( bot.PlayerMelee_GetAttackHitEntity() ) )
		{
			connected = true
			break
		}
		wait 0.05
	}

	if ( connected )
	{
		brain.meleeMisses = 0
		return
	}
	if ( ++brain.meleeMisses >= BOT_MELEE_MAX_MISSES )
	{
		brain.meleeMisses = 0
		brain.meleeBlockedUntil = Time() + RandomFloat( BOT_MELEE_BLOCK_MIN, BOT_MELEE_BLOCK_MAX )
	}
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

// Flat unit vector along v, or a zero vector if v has no horizontal length.
function Normalize2D( v )
{
	local length = Length2D( v )
	if ( length < 0.001 )
		return Vector( 0, 0, 0 )
	return Vector( v.x / length, v.y / length, 0 )
}
