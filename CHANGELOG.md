# Changelog

Changes to the script-driven bots (`CORE/scripts/vscripts/mp/_bot_ai.nut`, `_bot_manager.nut`)
and the native bot support in `r1delta-src` (`server/ai/bot_control.*`, `shared/squirrel.cpp`).

## Unreleased

### Pilot AI
- Layered brain: Perceive -> Decide -> Act, with three temperaments drawn per life and balanced across the team:
  - **Aggressive**: attacks nearby enemies, keeps attacking when hurt, chases enemies that disappear.
  - **Cautious**: seeks cover when an enemy is close, retreats at low health, repositions without line of sight.
  - **Flanker**: does not attack right away, takes an alternative route and arrives from the side (holds fire unless attacked or the enemy is closer than ~600u).
- Cover state machine: find a hidden spot with a peek position, hide, peek and shoot, return.
- Pilots avoid standing in the crossfire between titans and prefer cover.
- Pilots embark their own titan first once it is called and on the map, and fight inside it while they can.
  Pilots inside titans are more aggressive and aim more accurately.
- Grunts and spectres are treated as weak infantry.
- Knowledge system (radar pings / intel) so bots find each other while roaming instead of only chasing a chosen prey.
- Spread across routes (direct, flank, high, indoor) to stop bots clustering in the middle of the map.
  Rooftop climbing, gap leaps and roof-to-roof routes.
- Pathing around doors and impossible climbs: careful mode near doors, bad-climb memory, stuck escalation
  (hop, back off at an angle, drop the goal).
- Trapped-bot rescue: after giving up three times within 250u in 40s (trees, pockets the nav graph does not know), the bot is killed so it respawns.
- Out-of-world watchdog: a bot far outside the map bounds is killed and respawns (it is no longer teleported).
- Rooftops: every bot has a per-life taste for high ground (`roofLove`) that weights elevated roaming goals, route
  points and how often it climbs; bots sometimes stop on a roof to watch the streets below.
- Up through buildings: a wall that can't be climbed from outside (or a failed climb) sends the bot inside to an
  upper-floor / roof node, reached by the stairs, to watch from above. Upstairs, a far goal below is left through
  a window / off a balcony instead of walking back down (pilots take no fall damage). The opening is checked
  with the player hull against everything a player collides with (glass, bars, frames); an exit that leaves the
  bot on the same floor is marked bad for the team and the bot leaves windows alone for a while.
- Ledges: jump, double jump and mantle onto any ledge in reach when stuck against it, when the route, a chased target
  or a reposition point is up there, and off a wall being run along.
- Planned wallruns (`PlanWallrun` / `UpdateWallrun`): a wall roughly along the route, long and high enough and
  bringing the bot closer to its goal, is approached at a shallow angle, jumped onto at a speed-based distance, run
  along leaning into it with the view along the wall, and left on purpose: a kick towards the goal (with a double
  jump), a hop to the opposite wall (alleys, corridors), or a mantle onto a ledge at the top. Used for roofs, gaps,
  repositioning and roaming; never indoors, near doors or in combat. Debug log with `BOT_DEBUG_WALLRUN`.
- Wallrun roof climbs: approach angle and jump timing fixed, run-up when too close to the face, and a second try
  from the other side before the spot is marked bad.
- Movement input is turned with the aim at the end of the think (`BOT_INPUT_FOLLOWS_AIM`): it was worked out for
  the view before the aim turned, so the bot moved off its intended line (and off walls) every tick.
- Ground checks that must not fire on a wall (`IsOnGround()` is also true while wallrunning) go through `BotOnFoot`.
- Void guard: pilots on the ground never step or jump towards a spot with no floor, or a floor below the lowest
  node of the graph (open map edges, pits with a kill trigger); running straight across "roofs" off the graph only
  happens over solid ground.
- Grenades are used much more: against lone grunts / spectres (more with the arc grenade on spectres), always
  against titans, at a pilot that just ducked behind cover, while reloading, and dropped behind while running
  away (satchels, mines). Per-type throw range and arc; no wasted throws without a charge.
- Satchels are detonated when an enemy comes close to one (the bot itself clear of it).
- Pilots don't kick titans (player or auto-titan), riders, or anything with an enemy titan right next to it, and
  don't rush in for a kick near enemy titans.

### Aim and weapons
- More human aim: randomised error, reaction time, target leading with velocity, burst and pause patterns.
- Prefers ranged fighting over run-and-jump.
- Correct weapon switching: anti-titan weapons against titans, Archer, Charge Rifle (charge fraction), smart pistol.
- Smart pistol locks targets (no ADS for lock weapons); Archer uses ADS lock.
- Semi-automatic weapons are fired with trigger pulses instead of a held button.
- Reload when the clip is low and out of a fight.
- Melee actually connects (anim-event callback called manually, miss lockout).
- A kill by a bot replays through the victim's eyes instead of the bot's: in the bot's first-person view its
  muzzle flash and tracers never showed (they are predicted by the shooter's client, which a bot doesn't have).
- Anti-titan weapons used much more: titans in sight are the target with a loaded anti-titan weapon (unless a
  pilot is close), the weapon stays out between peeks, titan-crossfire cover peeks with it (pre-aimed at the
  titan), pilots only step back briefly from a titan that is too close, and pilots without one rodeo more often.
- Charge Rifle charge/release fixed; Archer with the guided-missile mod handled; no suppressive fire with
  anti-titan ammo.

### Rodeo
- Riders aim into the open hatch (the old aim point was at the rider's own eye height) and switch from the
  anti-titan weapon to the primary on the way to the titan and on it (retries, holster/deploy push, jump off if
  stuck with the launcher).
- Rodeo damage from bot riders always counts as a hatch hit (as for spectres): the exact hatch hitbox can't be
  aimed at and every other hit was soaked by the shield/armor (`mp/_titan_health.nut`).
- Bots no longer climb onto friendly titans by accident (they use the server's friendly-only "hold to rodeo"
  setting); they only hitch a ride on a friendly titan to get away from a fight.
- Titan bots with an enemy rider: electric smoke if charged, otherwise always hop out and shoot the rider (no more
  dashing in circles, the rider on their own back is no longer targeted).
- Teammates of a rodeoed titan shoot the rider: its head is checked for line of sight over the hull, aimed at and
  led with the titan's velocity, and out of sight they walk round to the titan's back to get a line on it.

### Epilogue evac
- The losing team's bots run for the evac ship and board it; titans hop out near the evac point.
- A ramp too high to reach from the ground: bots climb nearby high ground (nav nodes or roofs found by probes)
  and jump from there; run-ups from the ground, failed launch points shared by the team.
- Once the evac starts, nothing diverts the bot: earlier retreats, cover, repositioning, rodeo and rides are
  dropped, titans aren't targeted, the sprint is kept (only targets ahead are shot), tactical abilities are used.
- Fixed a script error after the ship left (the "evac" action was kept with no evac goal).

### Titans
- More aggressive titan bots: spread out, attack each other, no clumping or pacing back and forth.
- Titans melee when needed (e.g. intercepting a rodeo attempt) and stop meleeing forever against a stronger titan.
- Titan cover and fight tuning (`BOT_TITAN_*`).
- Titan bots ignore enemy titans still inside their titanfall dome shield (nothing gets through it).
- Titan bots run straight out of the blast of an enemy nuclear ejection (tracked through `AddCallback_OnTitanEject`).
- Titan bots with the particle wall fight from behind it: they stand on the far side of the wall from their
  target and side-step along it.
- Titan bots that popped electric smoke with an enemy rider on stay inside the smoke (no dash, no hopping out)
  until it runs out.
- Each titan fights inside its main weapon's damage range (shotgun / arc cannon up close, railgun far away).
- Titan ordnance used whenever ready: Slaved Warheads fired once locked, Multi-Target Missiles held to lock on and
  released, dumb-fire ordnance when on target.
- Vortex shield held to catch incoming fire and released at the target to throw it back.
- Stuck titans (stairs, steps): dash the way a hull probe finds free, then a new angle or skipped waypoint, then a
  detour around a spot remembered as bad; titan paths avoid climb links and try the titan hull first.
- Balance: titan bots keep their sharp aim, quick reactions and perfect leading for titan duels only; against
  pilots, grunts and spectres they aim and react like a pilot. Bot titan calls follow the titans out on each team:
  a team with fewer titans calls them in right away, a team two or more ahead holds its calls (up to 60 s), so
  the side that got its titans out first no longer stomps the other one.
- Titan bots don't walk or dash into the void either.

### Maps
- War Games: titans that fall into the simulation's death pits die like pilots (the pit triggers' damage per hit
  only scratched a titan, so titans kept fighting down there).

### Bot manager
- Managed bots spawn together with humans at game start (they wait before Prematch instead of spawning on connect).
- Bots are removed immediately when a human joins, alive or dead. Only managed bots are ever kicked; humans are never removed.
- Fixed bots dying ~1 s after every respawn on War Games: the simulation dissolve on death (and the dissolve from arc cannon, titan embark/crush and similar dissolve deaths on any map) is no longer applied to bots, since it outlived their quick respawn and killed the new life.

### Native (`r1delta-src`)
- New script function `NavFindPathPilot`: pathfinding over the .ain graph restricted to links a pilot can walk (hull and traverse bits).
  `NavFindPath` keeps its previous behaviour.
- Script falls back to `NavFindPath` when `NavFindPathPilot` is not available.

### Known issues
- Intermittent disconnect/crash (engine entity-state decode) when a dead human spectating a bot respawns. Root cause not confirmed, i'm investigating da cause :D
  Cause narrowed down: `CL_CopyExistingEntity` deltas an entity whose stored packed state in the old frame is -1 and reads `buffer + 0xFFFFFFFF` (engine+0x1D6F60).
  The native hook now refuses that case with a Host_Error naming the entity instead of crashing.
- Untested in game: whether held offhand buttons from bots (titan ordnance lock-on, vortex shield) behave like a
  held key; whether titan hull 4 is a usable titan path hull on every map (it falls back to the human hull).
