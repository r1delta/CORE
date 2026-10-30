// r2fd_players.nut : Frontier Defense with more than four players (R1 coop / "Fireteam Defense").
// Original code. No Titanfall 2 data in here.
//
// What it does (server only):
//  1. A smooth, saturating "effective player count" curve. Up to four players the waves are exactly what the wave
//     tables say. Beyond four, every wave is made bigger in proportion to effective(n) / 4 and the AI cap, the
//     titan/AI barrier thresholds of the R2 adapter (mp/r2fd.nut) follow the same factor.
//  2. Beyond four players every PLAYER weapon is amped (the burn card "amped" weapon mod of that weapon, plus a
//     damage multiplier where the game has no such mod), also the weapons of a Titan that belongs to a player.
//     Enemy NPCs and the harvester never get it. Amping an amped weapon again makes it double amped (4 x the
//     single amped damage multiplier); a weapon never goes beyond double amped.
//
// Configuration: playlist variables (set them in playlists.txt or with a playlist override) read once per wave and
// once per second, or at runtime with R2FDP_SetConfig( "name", value ) (execute_squirrel on the server). Defaults:
//
//   r2fdp_scale          1     0 = wave size, AI cap and barriers do not follow the player count
//   r2fdp_base_players   4     players up to this number get exactly the wave tables
//   r2fdp_curve_gain     10.1  asymptotic gain of the curve in effective players (effective -> base + gain)
//   r2fdp_curve_tau      15.5  how fast the curve saturates (players past the base, bigger = slower)
//   r2fdp_ai_cap_max     56    hard limit of the simultaneous AI per side after scaling (the game sets 28 for coop)
//   r2fdp_amp            1     0 = no amping
//   r2fdp_amp_threshold  4     weapons are amped while MORE than this many players are connected
//   r2fdp_amp_mult       1.5   damage multiplier of one amp on a weapon that has no burn card amped mod
//   r2fdp_amp_double     4.0   extra damage factor of the second amp (double amped = 4 x the single amped value)
//
// effective(n) = n                                      for n <= base
//              = base + gain * ( 1 - exp( -( n - base ) / tau ) )   for n > base
// wave factor f = max( 1, effective(n) / base ), applied at wave start (and again right before combat starts when
// players joined or left during the break).

const R2FDP_AMP_MAX_LEVEL = 2

function main()
{
	if ( !IsServer() )
		return

	level.r2fdp <- {}
	level.r2fdp.override <- {}
	level.r2fdp.lastKey <- ""
	level.r2fdp.baseCap <- null
	level.r2fdp.modMap <- null
	level.r2fdp.notified <- {}
	level.r2fdp.watching <- false

	Globalize( R2FDP_SetConfig )
	Globalize( R2FDP_EffectivePlayers )
	Globalize( R2FDP_WaveFactor )
	Globalize( R2FDP_AmpWeapon )
	Globalize( R2FDP_GetAmpLevel )
	Globalize( R2FDP_GetDamageMult )
	Globalize( R2FDP_Status )
	Globalize( R2FDP_ResetWeapon )
	Globalize( R2FDP_BurnModFor )

	AddDamageByCallback( "player", R2FDP_OnDamage )
	AddDamageByCallback( "npc_titan", R2FDP_OnDamage )

	AddCallback_GameStateEnter( eGameState.Playing, R2FDP_OnPlaying )
}

function R2FDP_OnPlaying()
{
	if ( level.r2fdp.watching )
		return

	level.r2fdp.watching = true
	thread R2FDP_WaveWatcher()
	thread R2FDP_AmpThink()
}

// ------------------------------------------------------------------------------------------------------------
// configuration
// ------------------------------------------------------------------------------------------------------------
function R2FDP_SetConfig( name, value )
{
	level.r2fdp.override[ name ] <- value
}

function R2FDP_Cfg( name, defaultValue )
{
	if ( name in level.r2fdp.override )
		return level.r2fdp.override[ name ]

	return GetCurrentPlaylistVarFloat( "r2fdp_" + name, defaultValue )
}

// ------------------------------------------------------------------------------------------------------------
// player count curve
// ------------------------------------------------------------------------------------------------------------
function R2FDP_EffectivePlayers( n )
{
	local base = R2FDP_Cfg( "base_players", 4.0 )
	if ( n <= base )
		return n.tofloat()

	local gain = R2FDP_Cfg( "curve_gain", 10.1 )
	local tau = R2FDP_Cfg( "curve_tau", 15.5 )
	return base + gain * ( 1.0 - exp( -( n - base ) / tau ) )
}

// wave size factor: 1 up to the base player count, effective( n ) / base beyond
function R2FDP_WaveFactor( n )
{
	if ( R2FDP_Cfg( "scale", 1 ) == 0 )
		return 1.0

	local base = R2FDP_Cfg( "base_players", 4.0 )
	return max( 1.0, R2FDP_EffectivePlayers( n ) / base )
}

function R2FDP_Status()
{
	local n = GetPlayerArray().len()
	local eff = R2FDP_EffectivePlayers( n )
	local f = R2FDP_WaveFactor( n )
	local cap = R2FDP_AICap( f )
	printt( "R2FDP status: players", n, "effective", eff, "waveFactor", f, "aiCap", cap, "ampActive", R2FDP_AmpActive() )
}

// ------------------------------------------------------------------------------------------------------------
// wave scaling
// ------------------------------------------------------------------------------------------------------------
// the AI cap per side the game sets itself (28 in coop, TowerDefenseInit) times the wave factor, limited by ai_cap_max
function R2FDP_AICap( factor )
{
	local base = level.r2fdp.baseCap != null ? level.r2fdp.baseCap : level.max_npc_per_side
	local cap = floor( base * factor + 0.5 ).tointeger()
	local capMax = R2FDP_Cfg( "ai_cap_max", 56 ).tointeger()
	return clamp( cap, base, max( base, capMax ) )
}

function R2FDP_ApplyAICap( factor )
{
	local cap = R2FDP_AICap( factor )
	local defenders = GetOtherTeam( level.nv.attackingTeam )

	// the Set*AICount functions assert count <= max_npc_per_side
	level.max_npc_per_side = cap
	SetGameModeAICount( cap, defenders )
	SetLevelAICount( cap, defenders )
	level.midSpecAICount[ defenders ] = cap
	return cap
}

// rebuilds the group list of one wave from its untouched base list: after every base entry that spawns AI the extra
// squads / titans the factor asks for are inserted (a per spawn function accumulator spreads the fractional part).
function R2FDP_PrepareWave( waveIdx, factor )
{
	local waveInfo = level.TowerDefenseWaves[ waveIdx ]
	if ( !( "r2fdpBase" in waveInfo ) )
		waveInfo.r2fdpBase <- clone waveInfo.spawngroups

	local base = waveInfo.r2fdpBase
	local extraPer = factor - 1.0
	local out = []
	local acc = {}
	local added = 0
	foreach ( info in base )
	{
		info.hasProcessed = false
		out.append( info )

		if ( !( "spawnFunc" in info ) || extraPer < 0.001 )
			continue

		local key = FunctionToString( info.spawnFunc )
		local a = ( key in acc ? acc[ key ] : 0.0 ) + extraPer
		while ( a >= 0.999 )
		{
			a -= 1.0
			local copy = clone info
			copy.hasProcessed = false
			out.append( copy )
			added++
		}
		acc[ key ] <- a
	}

	foreach ( i, info in out )
		info.id = i

	waveInfo.spawngroups = out

	// the barriers of the R2 adapter ("continue when at most n enemies are alive") grow with the wave
	if ( "r2fd" in level && waveIdx in level.r2fd.barriers )
	{
		foreach ( b in level.r2fd.barriers[ waveIdx ] )
		{
			if ( !( "n0" in b ) )
				b.n0 <- b.n

			b.n = ceil( b.n0 * factor ).tointeger()
		}
	}

	UpdateNumbersForNextWave( waveInfo )

	local baseAI = 0
	foreach ( info in base )
		baseAI += GetAICountFromSpawnInfo( info )

	local scaledAI = 0
	foreach ( info in out )
		scaledAI += GetAICountFromSpawnInfo( info )

	return { added = added, baseAI = baseAI, scaledAI = scaledAI }
}

function R2FDP_WaveWatcher()
{
	level.ent.EndSignal( "OnDestroy" )

	while ( true )
	{
		wait 0.25

		if ( Flag( "CoopTD_WaveCombatInProgress" ) )
			continue

		local currWave = level.nv.TDCurrWave
		if ( currWave == null )
			continue

		local waveIdx = currWave - 1
		if ( waveIdx < 0 || waveIdx >= level.TowerDefenseWaves.len() )
			continue

		local n = GetPlayerArray().len()
		local factor = R2FDP_WaveFactor( n )

		// one key per wave start (a wave restart starts again with the same index) and player count
		local key = waveIdx + ":" + level.nv.TDWaveStartTime + ":" + n
		if ( key == level.r2fdp.lastKey )
			continue
		level.r2fdp.lastKey = key

		// the game raises its own AI cap (coop: 28) when the tower defense mode is set up, so read it at the first wave
		if ( level.r2fdp.baseCap == null )
			level.r2fdp.baseCap = level.max_npc_per_side

		local cap = R2FDP_ApplyAICap( factor )
		local rep = R2FDP_PrepareWave( waveIdx, factor )
		printt( "R2FDP wave", currWave, "players", n, "effective", R2FDP_EffectivePlayers( n ), "factor", factor, "extra spawn groups", rep.added, "AI base", rep.baseAI, "AI scaled", rep.scaledAI, "ai cap", cap )
	}
}

// ------------------------------------------------------------------------------------------------------------
// amped weapons
// ------------------------------------------------------------------------------------------------------------
function R2FDP_AmpActive()
{
	if ( R2FDP_Cfg( "amp", 1 ) == 0 )
		return false

	return GetPlayerArray().len() > R2FDP_Cfg( "amp_threshold", 4 )
}

// weapon class -> burn card amped mod, built from the burn card table
function R2FDP_BuildModMap()
{
	local map = {}

	foreach ( ref, data in level.burnCardData )
	{
		if ( !( "Weapon" in data ) || !( "WeaponMod" in data ) )
			continue

		if ( data.WeaponMod == null || data.Weapon == null )
			continue

		if ( !( data.Weapon in map ) )
			map[ data.Weapon ] <- data.WeaponMod
	}

	// the amped tactical abilities are mods of their own
	map[ "mp_ability_heal" ] <- "bc_super_stim"
	map[ "mp_ability_cloak" ] <- "bc_super_cloak"
	map[ "mp_ability_sonar" ] <- "bc_super_sonar"

	level.r2fdp.modMap = map
}

// the amped mod this weapon can carry, or null when the game defines none
function R2FDP_BurnModFor( weapon )
{
	if ( level.r2fdp.modMap == null )
		R2FDP_BuildModMap()

	local className = weapon.GetClassname()
	if ( !( className in level.r2fdp.modMap ) )
		return null

	local modName = level.r2fdp.modMap[ className ]
	try
	{
		if ( !weapon.HasModDefined( modName ) )
			return null
	}
	catch ( e )
	{
		return null
	}

	return modName
}

function R2FDP_HasMod( weapon, modName )
{
	if ( modName == null )
		return false

	try
	{
		return weapon.HasMod( modName )
	}
	catch ( e )
	{
		return false
	}
}

// per weapon entity: pre = the player count amp (0 / 1), api = amps added through R2FDP_AmpWeapon, added = the burn
// card mod was put on by this script (so it can be taken off again), tries = failed SetMods attempts
function R2FDP_State( weapon )
{
	if ( !( "r2fdp" in weapon.s ) )
		weapon.s.r2fdp <- { pre = 0, api = 0, added = false, tries = 0 }

	return weapon.s.r2fdp
}

// amp level 0 / 1 / 2. A mod the weapon carries that this script did not add (loadout, burn card) is one level.
function R2FDP_GetAmpLevel( weapon )
{
	local st = R2FDP_State( weapon )
	local natural = ( R2FDP_HasMod( weapon, R2FDP_BurnModFor( weapon ) ) && !st.added ) ? 1 : 0
	return min( natural + st.pre + st.api, R2FDP_AMP_MAX_LEVEL )
}

// total damage factor of the weapon: 1 / M / 4 x M. M is what the amped mod does itself where the weapon has one
// (the game's data, so 1 here), r2fdp_amp_mult where it has none.
function R2FDP_GetDamageMult( weapon )
{
	local level_ = R2FDP_GetAmpLevel( weapon )
	if ( level_ == 0 )
		return 1.0

	local modName = R2FDP_BurnModFor( weapon )
	local single = R2FDP_HasMod( weapon, modName ) ? 1.0 : R2FDP_Cfg( "amp_mult", 1.5 )
	if ( level_ == 1 )
		return single

	return single * R2FDP_Cfg( "amp_double", 4.0 )
}

// amps once more, never beyond double amped. Returns the level.
function R2FDP_AmpWeapon( weapon )
{
	local st = R2FDP_State( weapon )
	if ( R2FDP_GetAmpLevel( weapon ) < R2FDP_AMP_MAX_LEVEL )
		st.api++

	R2FDP_SyncMods( weapon.GetWeaponOwner(), weapon, st )
	return R2FDP_GetAmpLevel( weapon )
}

// drops everything this script did to the weapon (the mod it added and the amps it counted)
function R2FDP_ResetWeapon( weapon )
{
	local st = R2FDP_State( weapon )
	st.pre = 0
	st.api = 0
	R2FDP_SyncMods( weapon.GetWeaponOwner(), weapon, st )
}

function R2FDP_SetMods( owner, weapon, mods )
{
	local held = IsValid( owner ) && owner.IsPlayer() && owner.GetActiveWeapon() == weapon
	if ( held )
		owner.HolsterWeapon()

	local applied = false
	try
	{
		weapon.SetMods( mods )
		applied = true
	}
	catch ( e )
	{
	}

	if ( held )
	{
		owner.DeployWeapon()
		weapon.SetNextAttackAllowedTime( Time() )
	}

	return applied
}

// keeps the burn card mod of the weapon in step with its amp level: carried while any amp counts, off otherwise
function R2FDP_SyncMods( owner, weapon, st )
{
	local modName = R2FDP_BurnModFor( weapon )
	if ( modName == null )
		return

	local has = R2FDP_HasMod( weapon, modName )
	local extra = st.pre + st.api

	local current = []
	foreach ( mod in weapon.GetMods() )
	{
		if ( mod.find( "pas_" ) != 0 )
			current.append( mod )
	}

	if ( extra > 0 && !has )
	{
		if ( st.tries >= 10 )
			return

		current.append( modName )
		// the engine can throw after the mod went on (and can refuse it), so the weapon itself is the truth
		R2FDP_SetMods( owner, weapon, current )
		if ( R2FDP_HasMod( weapon, modName ) )
			st.added = true
		else
			st.tries++
	}
	else if ( extra == 0 && has && st.added )
	{
		local mods = []
		foreach ( mod in current )
		{
			if ( mod != modName )
				mods.append( mod )
		}

		R2FDP_SetMods( owner, weapon, mods )
		if ( !R2FDP_HasMod( weapon, modName ) )
			st.added = false
	}
}

function R2FDP_SyncWeapon( owner, weapon, active )
{
	local st = R2FDP_State( weapon )
	local wantPre = active ? 1 : 0
	if ( st.pre == wantPre && ( st.pre + st.api == 0 ) == !st.added )
		return false

	st.pre = wantPre
	R2FDP_SyncMods( owner, weapon, st )
	return true
}

function R2FDP_SyncEntity( ent, active )
{
	local weapons = []
	foreach ( w in ent.GetMainWeapons() )
		weapons.append( w )
	foreach ( w in ent.GetOffhandWeapons() )
		weapons.append( w )

	local changed = false
	foreach ( weapon in weapons )
	{
		if ( !IsValid( weapon ) )
			continue

		if ( R2FDP_SyncWeapon( ent, weapon, active ) )
			changed = true
	}

	return changed
}

function R2FDP_AmpThink()
{
	level.ent.EndSignal( "OnDestroy" )

	while ( true )
	{
		wait 1.0

		local active = R2FDP_AmpActive()
		foreach ( player in GetPlayerArray() )
		{
			if ( !IsValid( player ) || !IsAlive( player ) )
				continue

			local changed = false
			try
			{
				if ( R2FDP_SyncEntity( player, active ) )
					changed = true

				local titan = player.GetPetTitan()
				if ( titan != null && IsValid( titan ) && titan != player && IsAlive( titan ) )
				{
					if ( R2FDP_SyncEntity( titan, active ) )
						changed = true
				}
			}
			catch ( e )
			{
				printt( "R2FDP amp sync error for", player, e )
			}

			local idx = player.GetEntIndex()
			local was = idx in level.r2fdp.notified && level.r2fdp.notified[ idx ]
			if ( active && !was )
			{
				level.r2fdp.notified[ idx ] <- true
				SendHudMessage( player, "WEAPONS AMPED", -1, 0.4, 255, 190, 40, 255, 0.5, 3.0, 1.0 )
			}
			else if ( !active && was )
			{
				level.r2fdp.notified[ idx ] <- false
			}
		}
	}
}

// the damage factor of the attacking weapon: players and Titans that belong to a player only
function R2FDP_OnDamage( victim, damageInfo )
{
	local attacker = damageInfo.GetAttacker()
	if ( !IsValid( attacker ) )
		return

	if ( attacker.IsNPC() )
	{
		local soul = attacker.GetTitanSoul()
		if ( !soul )
			return

		local boss = soul.GetBossPlayer()
		if ( !IsValid( boss ) )
			return
	}
	else if ( !attacker.IsPlayer() )
	{
		return
	}

	local weapon = damageInfo.GetWeapon()
	if ( !IsValid( weapon ) )
		weapon = attacker.GetActiveWeapon()

	if ( !IsValid( weapon ) )
		return

	local mult = R2FDP_GetDamageMult( weapon )
	local before = damageInfo.GetDamage()
	if ( mult != 1.0 )
		damageInfo.SetDamage( before * mult )

	if ( R2FDP_Cfg( "debug", 0 ) != 0 )
		printt( "R2FDP damage", weapon.GetClassname(), "mult", mult, "before", before, "after", damageInfo.GetDamage() )
}
