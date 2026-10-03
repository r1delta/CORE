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

### Aim and weapons
- More human aim: randomised error, reaction time, target leading with velocity, burst and pause patterns.
- Prefers ranged fighting over run-and-jump.
- Correct weapon switching: anti-titan weapons against titans, Archer, Charge Rifle (charge fraction), smart pistol.
- Smart pistol locks targets (no ADS for lock weapons); Archer uses ADS lock.
- Semi-automatic weapons are fired with trigger pulses instead of a held button.
- Reload when the clip is low and out of a fight.
- Melee actually connects (anim-event callback called manually, miss lockout).

### Titans
- More aggressive titan bots: spread out, attack each other, no clumping or pacing back and forth.
- Titans melee when needed (e.g. intercepting a rodeo attempt) and stop meleeing forever against a stronger titan.
- Titan cover and fight tuning (`BOT_TITAN_*`).

### Bot manager
- Managed bots spawn together with humans at game start (they wait before Prematch instead of spawning on connect).
- Bots are removed immediately when a human joins, alive or dead. Only managed bots are ever kicked; humans are never removed.

### Native (`r1delta-src`)
- New script function `NavFindPathPilot`: pathfinding over the .ain graph restricted to links a pilot can walk (hull and traverse bits).
  `NavFindPath` keeps its previous behaviour.
- Script falls back to `NavFindPath` when `NavFindPathPilot` is not available.

### Known issues
- Intermittent disconnect/crash (engine entity-state decode) when a dead human spectating a bot respawns. Root cause not confirmed.
- Spectating bots does not show first-person weapons, shots or titan cockpits (except Ogre), likely a fake-client viewmodel limitation.
