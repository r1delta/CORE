//=========================================================
// Pilot bot brain
// Drives managed bots (see _bot_manager.nut) through the native BotSetInput/BotPressButtons
// usercmd injection and NavFindPath node-graph pathfinding provided by R1Delta.
//=========================================================

const BOT_THINK_INTERVAL		= 0.1
const BOT_DEBUG_HUD				= false	// shows one bot's movement diagnostics on screen
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
const BOT_TITAN_TOO_CLOSE_DIST	= 600.0		// on foot, a titan closer than this is a stomp waiting to happen: run
const BOT_AT_BURST				= 1.6		// longer trigger holds for anti-titan weapons (charge rifle needs the charge)
const BOT_AT_PAUSE				= 0.4
const BOT_WEAPON_HOLD_TIME		= 4.0	// keep a weapon at least this long after switching to it
const BOT_WEAPON_DEPLOY_TIME	= 1.0	// no trigger while the switch animation plays
const BOT_WEAPON_SWITCH_CHECK	= 2.5	// by now the switch should show in GetActiveWeapon; logged if not

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
const BOT_EXPLORE_MATE_DIST		= 1200.0	// roaming goals near a teammate's roaming goal score lower
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
const BOT_TITAN_TRIGGER_ANGLE	= 8.0		// open fire within this many degrees at most
const BOT_TITAN_PAUSE_SCALE		= 0.6
const BOT_TITAN_ORDNANCE_COOLDOWN_MIN	= 4.0	// rockets/ordnance retried this often (the weapon has its own cooldown)
const BOT_TITAN_ORDNANCE_COOLDOWN_MAX	= 8.0
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
const BOT_CLIMB_WALLRUN_JUMP_DIST	= 220.0	// jump onto the wall from this far out
const BOT_CLIMB_WALLRUN_TIME	= 0.35		// ride the wall this long before kicking off towards the roof
const BOT_CLIMB_TIMEOUT			= 3.5
const BOT_CLIMB_RETRY			= 8.0
const BOT_CLIMB_PROGRESS_TIME	= 1.6		// this long into a climb without gaining height = give up
const BOT_BAD_CLIMB_RADIUS		= 300.0		// failed climbs are remembered (team-wide) around the wall spot
const BOT_CLIMB_CHANCE_OTHERS	= 10		// percent of climb chances non-high bots take too
const BOT_OFFGRAPH_HEIGHT		= 150.0		// path's next node this far below us = we're up on something
const BOT_OFFGRAPH_BLOCK_TIME	= 6.0
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
const BOT_NPC_GRENADE_GROUP		= 3		// grunts/spectres only get a grenade when this many are bunched up
const BOT_NPC_GROUP_RADIUS		= 350

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
const BOT_TITAN_RANGE_MIN		= 350.0	// each bot's preferred titan-fight range is rolled in here
const BOT_TITAN_RANGE_MAX		= 750.0
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

	if ( !BotManagerEnabledForMode() )
		return

	AddCallback_OnPlayerRespawned( BotAI_OnPlayerRespawned )
	AddDamageCallback( "player", BotAI_OnPlayerDamaged )
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
		rodeoDisembark = false
		nextRodeoSmokeTime = 0.0
		strafeDir = 1.0
		nextStrafeFlip = 0.0
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

	// Tactics: break off from crowded fights, hold high points.
	local holding = false
	if ( !isTitan )
	{
		try { UpdateReposition( bot, brain, hasVisibleTarget ) }
		catch ( e ) { BotReportError( bot, "UpdateReposition", e ); brain.repositionUntil = 0.0 }
		try { holding = !brain.fleeing && IsHoldingVantage( bot, brain, hasVisibleTarget ) }
		catch ( e ) { BotReportError( bot, "IsHoldingVantage", e ); brain.holdUntil = 0.0 }
	}
	else if ( !brain.swatting )
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
	local disengaged = repositioning || ( plan != null && plan.disengage )
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

	if ( !isTitan )
	{
		try { UpdateCarefulMode( bot, brain ) }
		catch ( e ) { BotReportError( bot, "UpdateCarefulMode", e ); brain.careful = false }
	}

	local pressed = 0
	local buttons = 0
	local forward = 0.0
	local side = 0.0

	// Combat: hold position and strafe inside engage range, otherwise keep moving along the path.
	// While fleeing the bot keeps running and only shoots at what ends up in front of it.
	local combatWall = false
	local targetIsTitan = hasVisibleTarget && IsTitanEntity( brain.target )

	// On foot: anti-titan weapon out against titans, primary against everything else.
	try { UpdateWeaponChoice( bot, brain, isTitan ) }
	catch ( e ) { BotReportError( bot, "UpdateWeaponChoice", e ) }

	try { UpdateUnderFire( bot, brain ) }
	catch ( e ) { BotReportError( bot, "UpdateUnderFire", e ) }

	// Pilots fight anything in their weapon's effective range instead of running up to it first.
	local engageDist = BOT_TITAN_ENGAGE_DIST
	if ( !isTitan )
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
		local canRush = ( isTitan || !targetIsTitan ) && Time() > brain.meleeBlockedUntil
			&& ( brain.swatting || fabs( brain.target.GetOrigin().z - origin.z ) < BOT_MELEE_MAX_HEIGHT_DIFF )
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
			combatWall = brain.combatWallSeen
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

		// Travelling: drift onto walls along the route to wallrun them, and steer onto walls
		// in the air to chain one wallrun into the next. Not near doors or indoors.
		if ( !isTitan && forward > 0.7 && !brain.careful )
		{
			local seekDist = bot.IsOnGround() ? BOT_WALL_SEEK_DIST * brain.wallLove : BOT_WALL_AIR_DIST
			if ( !bot.IsOnGround() || Length2D( moveDir ) > BOT_WALLRUN_MIN_DIST )
			{
				local wallSide = FindWallSide( bot, seekDist )
				if ( wallSide != 0 )
					side = BotClamp( side + wallSide * BOT_WALL_SEEK_STRENGTH, -1.0, 1.0 )
			}
		}

		// Near doors and indoors: stay centered between door frames and corners.
		if ( !isTitan && brain.careful && bot.IsOnGround() )
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

	// Rodeo attempt from behind: move away from the pilot (the titan dash goes this way too).
	if ( isTitan && IsRodeoThreatBehind( bot, brain ) )
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
	}

	// Target just ducked out of sight: some bots keep firing at where it was for a moment.
	local suppressing = !hasVisibleTarget && !brain.fleeing && brain.target != null && IsValid( brain.target )
		&& brain.targetLastSeenPos != null && Time() - brain.targetLastSeenTime < brain.suppressTime

	// Aim at the target when we have one, otherwise look where we are going (always, when fleeing).
	try
	{
		if ( hasVisibleTarget && !brain.fleeing )
			AimAtTarget( bot, brain, brain.target )
		else if ( suppressing )
			AimAt( brain, bot.EyePosition(), brain.targetLastSeenPos + Vector( 0, 0, 40 ), false )
		else if ( !isTitan && !brain.fleeing && Time() < brain.alertUntil && brain.alertPos != null )
			AimAt( brain, bot.EyePosition(), brain.alertPos + Vector( 0, 0, 40 ), false )
		else if ( holding && brain.holdWatch != null )
			AimAt( brain, bot.EyePosition(), brain.holdWatch, false )
		else if ( climbing )
			AimAt( brain, origin, origin + brain.climbMoveDir * 200.0, false )
		else if ( moveDir != null )
			AimAt( brain, origin, origin + moveDir, false )
	}
	catch ( e ) { BotReportError( bot, "AimAt", e ) }

	local fireButtons = 0
	try { fireButtons = UpdateFiring( bot, brain, ( canShoot || suppressing ) && !holdFire ) }
	catch ( e ) { BotReportError( bot, "UpdateFiring", e ) }
	buttons = buttons | fireButtons

	try { buttons = buttons | UpdateAds( bot, brain, isTitan, canShoot ) }
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
		else if ( !isTitan && !unsticking && !climbing )
			pressed = pressed | UpdateParkour( bot, brain, moveDir, forward, side, combatWall )
		else
			pressed = pressed | UpdateTitanDash( bot, brain, hasVisibleTarget, inEngageRange, forward, side )
	}
	catch ( e ) { BotReportError( bot, "UpdateParkour", e ) }

	try { UpdateMelee( bot, brain, isTitan, canShoot ) }
	catch ( e ) { BotReportError( bot, "UpdateMelee", e ) }

	// After aiming, so a grenade throw can lift the pitch for its arc.
	try { pressed = pressed | UpdateAbilities( bot, brain, isTitan, canShoot ) }
	catch ( e ) { BotReportError( bot, "UpdateAbilities", e ) }

	try { UpdateStuck( bot, brain, moveDir, forward, side, !inEngageRange && !unsticking && !climbing && !brain.offGraph ) }
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
		local score = dist
		if ( inTitan )
		{
			// In a titan, the enemy titans are the fight; grunts only when nothing else is around.
			if ( IsTitanEntity( enemy ) )
				score *= BOT_TITAN_TARGET_BIAS
			else if ( !enemy.IsPlayer() )
				score *= BOT_TITAN_SMALL_TARGET_BIAS
		}
		else if ( !enemy.IsPlayer() )
			score *= BOT_NPC_TARGET_BIAS
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
		{
			brain.targetAcquiredTime = Time()
			brain.reactionTime = RollReactionTime( bot, brain, best )
		}
		brain.target = best
		brain.targetLastSeenPos = best.GetOrigin()
		brain.targetLastSeenVel = best.GetVelocity()
		brain.targetLastSeenTime = Time()
		// Seen by one, known to the team.
		ReportIntel( bot.GetTeam(), best, best.GetOrigin() )
	}
	else if ( brain.target != null && ( !IsAlive( brain.target ) || Time() - brain.targetLastSeenTime > brain.targetMemory ) )
	{
		brain.target = null
		brain.targetLastSeenPos = null
		brain.targetLastSeenVel = null
		brain.flankFor = null	// a new engagement can be flanked again
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

	local pressed = UpdateReload( bot, brain, true )
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

	// Our titan is out and can be climbed into: that is the answer to titans and to being hurt,
	// not running away from it (see ChooseAction).
	if ( !isTitan && brain.embarkTitan != null )
		return

	local threatPos = FindThreatPosition( bot, brain, isTitan, hasVisibleTarget, enemyTeam )
	if ( threatPos == null )
		return

	// Badly hurt: run for longer, to cover inside a building, until health comes back.
	local hurt = !isTitan && bot.GetHealth() < bot.GetMaxHealth() * BOT_PILOT_FLEE_HEALTH
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
		local hasAntiTitan = GetBotAntiTitanWeapon( bot ) != null
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

	// Breaking off from a brawl to come back from a new angle.
	if ( Time() < brain.repositionUntil && brain.repositionPoint != null )
		return brain.repositionPoint

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
// both near us)? Throttled; leaves brain.titanFight and brain.titanThreats (the positions of
// every titan involved).
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
	// a retreat always goes through.
	if ( desired.action != current && desired.action != "retreat" && now - brain.actionSince < BOT_ACTION_MIN_TIME
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
	}
	return plan
}

// --- Cover --------------------------------------------------------------------------------
// A cover episode: go to the spot, hide (ducked, reloading), peek to shoot, go back, hide again,
// until it times out, the enemy finds the spot, or the bot has to retreat.
// opts (optional) turns this into a titan-crossfire cover: { extra = other threat positions,
// needPeek, minThreatDist, maxRadius }. Without a peek spot the bot just hides.
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
	}
	return true
}

// Cover out of the line of fire of the titans fighting around us (p.titanThreats). Pilots with an
// anti-titan weapon, and not the cautious kind, look for a spot they can peek out of; if there
// is none (or they can't) they just hide.
function TryStartTitanCover( bot, brain, p )
{
	local origin = bot.GetOrigin()
	local primary = null
	local primaryDist = 0.0
	foreach ( pos in p.titanThreats )
	{
		local dist = Distance( origin, pos )
		if ( primary == null || dist < primaryDist )
		{
			primary = pos
			primaryDist = dist
		}
	}
	if ( primary == null )
		return false

	local canPeek = brain.temperament != "cautious" && p.health > 0.5 && GetBotAntiTitanWeapon( bot ) != null
	local opts = {
		extra = p.titanThreats
		needPeek = canPeek
		minThreatDist = BOT_TITAN_COVER_MIN_DIST
		maxRadius = BOT_TITAN_COVER_MAX_DIST
	}
	if ( TryStartCover( bot, brain, primary, opts ) )
		return true
	if ( !canPeek )
		return false
	opts.needPeek = false
	return TryStartCover( bot, brain, primary, opts )
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
	switch ( c.phase )
	{
		case "go":
			plan.goal = c.pos
			if ( Distance2D( origin, c.pos ) < BOT_COVER_REACHED )
			{
				c.phase = "hide"
				c.phaseStart = now
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
				c.until = now + RandomFloat( BOT_COVER_PEEK_MIN, BOT_COVER_PEEK_MAX )
			}
			break

		case "peek":
			plan.goal = c.peek
			if ( Distance2D( origin, c.peek ) < BOT_COVER_REACHED )
				plan.holdStill = true
			if ( now > c.until )
			{
				c.phase = "go"
				c.phaseStart = now
			}
			break
	}
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
	local threats = [ threatPos ]
	if ( opts != null )
	{
		foreach ( other in opts.extra )
			threats.append( other )
	}

	local origin = bot.GetOrigin()
	local threatEye = threatPos + Vector( 0, 0, 56 )
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
			local eye = threat + Vector( 0, 0, 56 )
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
function ApplyTemperament( brain )
{
	switch ( brain.temperament )
	{
		case "cautious":
			brain.routeStyle = RandomInt( 2 ) == 0 ? "indoor" : "high"
			brain.fleeHealth = RandomFloat( 0.40, 0.50 )
			brain.fleeMargin = -1.0
			brain.outnumberMargin = 1
			brain.repositionChance = 50
			brain.targetMemory = BOT_TARGET_MEMORY
			break

		case "flanker":
			brain.routeStyle = "flank"
			brain.fleeHealth = RandomFloat( 0.20, 0.30 )
			brain.fleeMargin = 0.1
			brain.outnumberMargin = 2
			brain.repositionChance = 60
			brain.targetMemory = BOT_TARGET_MEMORY + 1.0
			break

		default:	// aggressive
			brain.routeStyle = RandomInt( 2 ) == 0 ? "direct" : "high"
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
	local style = bot.IsTitan() ? "flank" : brain.routeStyle

	local best = null
	local bestScore = 0.0
	foreach ( index in candidates )
	{
		local pos = nav.positions[ index ]
		local detour = Distance( from, pos ) + Distance( pos, to ) - direct
		if ( detour > direct * BOT_TACTIC_MAX_DETOUR + 600.0 )
			continue

		local score = -detour * 0.3 + RandomFloat( 0.0, 300.0 )
		local lateral = ( pos - from ).Dot( perp )
		if ( side != 0.0 )
			score += lateral * side * ( style == "flank" ? 0.6 : 0.25 )

		if ( style == "high" )
			score += min( nav.elevation[ index ], BOT_HIGH_ELEVATION_MAX ) * BOT_HIGH_ELEVATION_BONUS

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
	if ( brain.repositionChance <= 0 || !hasVisibleTarget || !brain.target.IsPlayer() || IsTitanEntity( brain.target )
		|| now < brain.nextBrawlCheck || now < brain.nextRepositionTime )
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
function IsHoldingVantage( bot, brain, hasVisibleTarget )
{
	if ( Time() > brain.holdUntil )
		return false
	local lead = ( brain.prey != null && IsValid( brain.prey ) ) ? GetIntel( bot.GetTeam(), brain.prey ) : null
	if ( Time() < brain.underFireUntil || lead == null || Distance( bot.GetOrigin(), lead.pos ) < BOT_VANTAGE_BREAK_DIST )
	{
		brain.holdUntil = 0.0
		return false
	}
	// Look around that area, not at a fixed point.
	if ( Time() > brain.nextHoldLook )
	{
		brain.nextHoldLook = Time() + RandomFloat( 1.0, 2.5 )
		brain.holdWatch = lead.pos + Vector( RandomFloat( -400, 400 ), RandomFloat( -400, 400 ), 40 )
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
		return { z = nearTop.z, wall = wallPoint, along = null }

	// Higher: needs a wallrun up the face first, so there must be room to run along the wall
	// on one side, with clear air above that stretch too.
	local runStart = chest + dir * max( wallDist - 40.0, 0.0 )
	foreach ( side in [ right, right * -1.0 ] )
	{
		if ( !HasClearLine( bot, runStart, runStart + side * BOT_CLIMB_WALLRUN_LENGTH ) )
			continue
		local runColumn = column + side * ( BOT_CLIMB_WALLRUN_LENGTH * 0.6 )
		if ( !IsColumnClear( bot, runColumn, right, probeHeight ) )
			continue
		// The wall must actually continue along that stretch to run on.
		local alongWall = runStart + side * ( BOT_CLIMB_WALLRUN_LENGTH * 0.6 )
		if ( HasClearLine( bot, alongWall, alongWall + dir * 80.0 ) )
			continue
		return { z = nearTop.z, wall = wallPoint, along = side }
	}
	return null
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
// Looks for chances while travelling; high-style bots take them, others now and then.
// Returns buttons to press; brain.climbUntil > now while a climb is on, and
// brain.climbMoveDir is the direction to move in.
function UpdateClimb( bot, brain, moveDir, forward )
{
	local now = Time()
	local origin = bot.GetOrigin()

	if ( brain.climbUntil > 0.0 )
	{
		local onTop = bot.IsOnGround() && origin.z >= brain.climbTopZ - 24.0
		// No height gained after a while: this wall can't be climbed, give up early.
		local noProgress = now - brain.climbStart > BOT_CLIMB_PROGRESS_TIME && origin.z - brain.climbStartZ < 40.0
		if ( onTop || noProgress || now > brain.climbUntil )
		{
			if ( onTop )
			{
				printt( "BotAI:", bot.GetPlayerName(), "climbed onto a roof", brain.climbAlong != null ? "(wallrun)" : "(jump)" )
			}
			else
			{
				MarkBadClimbSpot( brain.climbWall )
				printt( "BotAI:", bot.GetPlayerName(), "couldn't climb, marking the spot" )
			}
			brain.climbUntil = 0.0
			brain.nextClimbCheck = now + BOT_CLIMB_RETRY
			brain.nextRepathTime = 0.0
			return 0
		}

		local chest = origin + Vector( 0, 0, 40 )
		if ( bot.IsOnGround() )
		{
			brain.usedDoubleJump = false
			brain.climbKicked = false
			brain.climbWallrunStart = 0.0
			local reach = brain.climbAlong != null ? BOT_CLIMB_WALLRUN_JUMP_DIST : 170.0
			local wallClose = !HasClearLine( bot, chest, chest + brain.climbDir * reach )
			return wallClose ? BOT_IN_JUMP : 0
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

		// Wallrun climb.
		if ( bot.IsWallRunning() )
		{
			if ( brain.climbWallrunStart == 0.0 )
				brain.climbWallrunStart = now
			// Keep running along the face, leaning into it.
			brain.climbMoveDir = brain.climbAlong + brain.climbDir * 0.5
			// Peak of the run: kick off up and towards the roof.
			if ( now - brain.climbWallrunStart > BOT_CLIMB_WALLRUN_TIME || bot.GetVelocity().z < 40.0 )
			{
				brain.climbKicked = true
				brain.climbMoveDir = brain.climbDir
				return BOT_IN_JUMP
			}
			return 0
		}
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

	if ( now < brain.nextClimbCheck || moveDir == null || forward < 0.7 || brain.careful || !bot.IsOnGround() || brain.offGraph )
		return 0
	brain.nextClimbCheck = now + BOT_CLIMB_CHECK_INTERVAL
	if ( brain.routeStyle != "high" && RandomInt( 100 ) >= BOT_CLIMB_CHANCE_OTHERS )
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
		brain.climbDir = dir
		brain.climbAlong = top.along
		// Wallrun climbs come in at an angle so we land on the wall running along it.
		brain.climbMoveDir = top.along != null ? dir * 0.6 + top.along * 0.8 : dir
		brain.climbKicked = false
		brain.climbWallrunStart = 0.0
		brain.climbTopZ = top.z
		brain.climbWall = top.wall
		brain.climbStart = now
		brain.climbStartZ = origin.z
		brain.climbUntil = now + BOT_CLIMB_TIMEOUT
		return 0
	}
	return 0
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
// BOT_GAP_DROP just ahead in the direction of travel.
function IsGapAhead( bot, dir )
{
	local length = Length2D( dir )
	if ( length < 1.0 )
		return false
	local start = bot.GetOrigin() + Vector( dir.x / length, dir.y / length, 0 ) * BOT_GAP_CHECK_AHEAD + Vector( 0, 0, 16 )
	return TraceLine( start, start - Vector( 0, 0, BOT_GAP_DROP + 16.0 ), bot, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE ).fraction >= 1.0
}

function StartVantageHold( brain )
{
	brain.holdUntil = Time() + RandomFloat( BOT_VANTAGE_HOLD_MIN, BOT_VANTAGE_HOLD_MAX )
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
// High-style bots like elevated spots, indoor-style bots covered ones.
function ChooseExploreGoal( bot, brain )
{
	local nav = GetNavCache()
	local nodeCount = nav.positions.len()
	local origin = bot.GetOrigin()
	local mates = GetTeammateBrains( bot )
	local best = null
	local bestScore = -1.0
	for ( local i = 0; i < BOT_EXPLORE_CANDIDATES; i++ )
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
		if ( brain.routeStyle == "high" )
			score += min( nav.elevation[ index ], BOT_HIGH_ELEVATION_MAX ) * BOT_HIGH_ELEVATION_BONUS
		else if ( brain.routeStyle == "indoor" && i < 3 && IsNodeIndoor( nav, index ) )
			score += BOT_INDOOR_ROUTE_BONUS
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

	local reached = isTitan ? BOT_TITAN_NODE_REACHED : ( brain.careful ? BOT_CAREFUL_NODE_REACHED : BOT_PILOT_NODE_REACHED )
	// Backtracking to a waypoint: walk all the way onto it before moving on.
	if ( Time() < brain.backtrackUntil )
		reached = BOT_BACKTRACK_NODE_REACHED
	while ( brain.pathIndex < brain.path.len() && Distance2D( origin, brain.path[ brain.pathIndex ] ) < reached )
	{
		brain.pathIndex++
		brain.backtrackUntil = 0.0
	}

	// Lost the line to the next waypoint (pushed past a door frame or a corner): go back to the
	// previous one, which we can still see, instead of grinding along the wall.
	if ( !isTitan && brain.pathIndex > 0 && brain.pathIndex < brain.path.len() && Time() > brain.nextLosCheck && bot.IsOnGround() )
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
	if ( !isTitan && brain.path.len() > 0 && Time() > brain.offGraphBlockedUntil && bot.IsOnGround() )
	{
		local next = brain.path[ brain.pathIndex < brain.path.len() ? brain.pathIndex : brain.path.len() - 1 ]
		if ( origin.z - next.z > BOT_OFFGRAPH_HEIGHT && Length2D( next - origin ) < 900.0 )
		{
			brain.offGraph = true
			local toGoal = goal - origin
			if ( Length2D( toGoal ) >= 1.0 )
				return toGoal
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
	local hull = isTitan ? BOT_HULL_TITAN : BOT_HULL_PILOT
	// Pilots: skip NPC traverse links a pilot can't follow (wall climbs, very long jumps), which
	// otherwise send bots jumping at buildings forever. Needs a DLL with NavFindPathPilot.
	local flat = ( file.hasPilotNav && !isTitan )
		? NavFindPathPilot( origin.x, origin.y, origin.z, goal.x, goal.y, goal.z, hull, BOT_PILOT_MAX_RISE, BOT_PILOT_MAX_GAP )
		: NavFindPath( origin.x, origin.y, origin.z, goal.x, goal.y, goal.z, hull )

	brain.path = []
	for ( local i = 0; i + 2 < flat.len(); i += 3 )
		brain.path.append( Vector( flat[i], flat[i + 1], flat[i + 2] ) )

	brain.pathIndex = 0
	brain.pathGoal = goal
	brain.nextRepathTime = Time() + BOT_REPATH_INTERVAL
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
	local wantsToMove = moveDir != null && ( fabs( forward ) > 0.1 || fabs( side ) > 0.1 )
	local origin = bot.GetOrigin()
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

		// Wall alongside on a long run, or in a fight: jump onto it. Heading for a wall that is
		// still a bit away, jump early and let the air steering carry us onto it.
		// Not near doors or indoors: there the walls beside us are door frames and corridors.
		local longRun = travelling && Length2D( moveDir ) > BOT_WALLRUN_MIN_DIST
		if ( ( longRun || combatWall ) && !brain.careful )
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

		// Travelling: kick off once the route leaves the wall (waypoint close or above us),
		// or right away near a door, to walk in on the ground.
		if ( travelling && ( brain.careful || moveDir.z > 48.0 || Length2D( moveDir ) < 150.0 ) )
			return BOT_IN_JUMP
		return 0
	}

	// Airborne: double jump if we still need height, or to reach a wall we're steering onto
	// before falling short of it. Near doors only for a real ledge right ahead (a doorway node
	// sitting a little higher used to trigger double jumps into the door frame).
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
		local reachWall = !brain.careful && bot.GetVelocity().z < -60.0 && FindWallSide( bot, BOT_WALL_AIR_DIST ) != 0
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
		// Too far: walk in. Closer than we'd like: stand our ground (no backpedalling away).
		local holdRadial = dist > preferred + BOT_COMBAT_RANGE_SLACK * 2 ? 1.0 : 0.0
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
		local along = closeIn ? dir : perp
		return along + wallSide * BOT_COMBAT_WALL_LEAN
	}

	// Open ground: circle the target, closing in when too far. Only backs off when the enemy
	// is right on top of a long-range weapon; otherwise a closer enemy is just fought.
	local radial = 0.0
	if ( dist > preferred + BOT_COMBAT_RANGE_SLACK )
		radial = BOT_COMBAT_RADIAL_SPEED
	else if ( dist < preferred * BOT_BACKOFF_FRACTION && preferred > BOT_BACKOFF_MIN_PREFERRED )
		radial = -BOT_COMBAT_RADIAL_SPEED * 0.5
	return perp + dir * radial
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
		return now - brain.wallrunStartTime > brain.wallrunHopAfter ? BOT_IN_JUMP : 0

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
	local toTarget = VectorToAngles( brain.target.GetWorldSpaceCenter() - bot.EyePosition() )
	if ( fabs( NormalizeYaw( toTarget.y - brain.yaw ) ) > maxAngle )
	{
		brain.firing = false
		return 0
	}

	local weapon = bot.GetActiveWeapon()
	local fireMode = IsValid( weapon ) ? GetWeaponFireMode( weapon ) : null
	if ( fireMode == "lock" )
	{
		// Archer: UpdateAds keeps the sights up; pull the trigger only once locked on
		// (tapped, it fires once per press).
		brain.firing = !brain.firing && IsSmartAmmoLocked( weapon )
		return brain.firing ? BOT_IN_ATTACK : 0
	}
	if ( fireMode == "charge" )
	{
		// Charge Rifle: hold until fully charged, then let go (it fires at full charge either way).
		if ( Time() < brain.nextFireToggle )
			return 0
		if ( brain.firing && weapon.GetWeaponChargeFraction() >= 1.0 )
		{
			brain.firing = false
			brain.nextFireToggle = Time() + BOT_AT_PAUSE
			return 0
		}
		brain.firing = true
		return BOT_IN_ATTACK
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
		reaction *= BOT_TITAN_REACTION_SCALE
	return reaction
}

// Aim at a target with lead for both sides' movement and a persistent error that settles
// while tracking. A fresh target starts with a bigger error (the "flick"); being airborne,
// moving fast or hipfiring keeps the wobble up, aiming down sights steadies it.
function AimAtTarget( bot, brain, target )
{
	local inTitan = bot.IsTitan()
	local aimError = brain.skill.aimError * ( inTitan ? BOT_TITAN_AIM_ERROR_SCALE : 1.0 )
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
	// Pilots: a bit above the center, towards the chest.
	if ( target.IsPlayer() && !target.IsTitan() )
		point = point + ( target.EyePosition() - point ) * 0.3
	// Lead moving targets: by the think delay, plus the projectile's flight time for slow
	// projectiles. Some bots lead well, others trail behind; in a titan everyone leads properly.
	local leadSkill = inTitan ? max( brain.leadSkill, BOT_TITAN_MIN_LEAD_SKILL ) : brain.leadSkill
	local leadTime = BOT_AIM_LEAD_TIME
	local speed = BotGetProjectileSpeed( bot.GetActiveWeapon() )
	if ( speed > 0.0 )
		leadTime += Distance( eye, point ) / speed
	leadTime = min( leadTime * leadSkill, BOT_LEAD_MAX_TIME )
	point = point + ( target.GetVelocity() - bot.GetVelocity() ) * leadTime

	local angles = VectorToAngles( point - eye )
	AimTowards( brain, angles.y + brain.aimErrYaw, NormalizeYaw( angles.x ) + brain.aimErrPitch )
}

// Projectile speed of a weapon for leading shots, or 0 for hitscan / unknown.
function BotGetProjectileSpeed( weapon )
{
	if ( !IsValid( weapon ) )
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

	// The Archer locks on only through the sights, at any range.
	local needsAds = !isTitan && GetWeaponFireMode( weapon ) == "lock"
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
		blocks = searchAngle != null && ( adsLock == null || adsLock.tointeger() == 0 ) && GetWeaponFireMode( weapon ) != "lock"
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

// Enemy pilot currently riding a titan (ours or anyone's).
function IsRodeoing( ent )
{
	return ent.IsPlayer() && !ent.IsTitan() && IsValid( ent.GetTitanSoulBeingRodeoed() )
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

	local weapon = WantsAntiTitanWeapon( bot, brain ) ? GetBotAntiTitanWeapon( bot ) : null
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

function WantsAntiTitanWeapon( bot, brain )
{
	if ( brain.target != null && IsValid( brain.target ) && Time() - brain.targetLastSeenTime < 3.0 && IsTitanEntity( brain.target ) )
		return true

	local eye = bot.EyePosition()
	foreach ( titan in GetTitansOfTeam( GetOtherTeam( bot.GetTeam() ), bot.GetOrigin(), BOT_PILOT_AT_ENGAGE_DIST ) )
	{
		if ( IsAlive( titan ) && CanSee( bot, eye, titan ) )
			return true
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

// Weapons that need more than holding the trigger: "lock" (Archer: ADS until locked on),
// "charge" (Charge Rifle: hold until fully charged, then let go), or null.
function GetWeaponFireMode( weapon )
{
	local weaponClass = weapon.GetWeaponClassName()
	if ( weaponClass == "mp_weapon_rocket_launcher" )
		return "lock"
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
			// Against pilots: when the odds are bad, or now and then. Against titans: always.
			// Grunts/spectres aren't worth one unless a bunch of them are packed together.
			if ( IsTitanEntity( brain.target ) )
				useOrdnance = true
			else if ( brain.target.IsPlayer() )
				useOrdnance = healthFrac < 0.7 || RandomInt( 4 ) == 0
			else
				useOrdnance = GetEnemyNPCs( brain.target.GetTeam(), brain.target.GetOrigin(), BOT_NPC_GROUP_RADIUS ).len() >= BOT_NPC_GRENADE_GROUP
		}

		if ( useOrdnance )
		{
			// Lob it: aim higher the farther away the target is.
			if ( !isTitan )
				brain.pitch = BotClamp( brain.pitch - min( targetDist * 0.008, 12.0 ), -89.0, 89.0 )
			pressed = pressed | BOT_IN_OFFHAND_ORDNANCE
			brain.nextOrdnanceTime = isTitan
				? now + RandomFloat( BOT_TITAN_ORDNANCE_COOLDOWN_MIN, BOT_TITAN_ORDNANCE_COOLDOWN_MAX )
				: now + RandomFloat( BOT_ORDNANCE_COOLDOWN_MIN, BOT_ORDNANCE_COOLDOWN_MAX )
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
function UpdateTitanDash( bot, brain, hasVisibleTarget, inEngageRange, forward, side )
{
	local now = Time()
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

	local range = swat ? BOT_SWAT_MELEE_RANGE : ( isTitan ? BOT_TITAN_MELEE_RANGE : BOT_PILOT_MELEE_RANGE )
	if ( Distance( bot.GetOrigin(), brain.target.GetOrigin() ) > range )
		return

	local toTarget = VectorToAngles( brain.target.GetWorldSpaceCenter() - bot.EyePosition() )
	if ( fabs( NormalizeYaw( toTarget.y - brain.yaw ) ) > ( swat ? BOT_SWAT_MELEE_ANGLE : 30.0 ) )
		return

	if ( !bot.PlayerMelee_CanMelee() || bot.PlayerMelee_GetState() != PLAYER_MELEE_STATE_NONE )
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
