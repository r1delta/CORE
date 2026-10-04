// Burn Card Escalation: free for all where burn cards stack on one pilot. Every pilot spawns with a number of random
// cards equal to the whole minutes the match has been running, and each kill on another pilot pulls one more.
// A pilot holding all three permanent tactical cards plus at least BCE_HVT_OTHER_CARDS other cards becomes a
// High-Value Target: killing them is worth 2 points, 2 cards and one of their permanent tactical cards.
//
// A "card" here is a slot-style key (see level.bceCardKeys in main). Weapon cards are not fixed weapons: they add the burn mod of
// whatever weapon is equipped in that slot, so a pilot keeps their own loadout.

const BCE_HVT_OTHER_CARDS = 3
const BCE_SECONDS_PER_CARD = 60.0

function main()
{
	// Order only matters for display; availability decides what can be pulled
	level.bceCardKeys <- [
		"primary", "sidearm", "secondary", "grenade", "tactical",
		"stim_forever", "cloak_forever", "sonar_forever",
		"fast_movespeed", "pilot_warning", "minimap"
	]

	level.bcePermaKeys <- [ "stim_forever", "cloak_forever", "sonar_forever" ]

	AddCallback_PlayerOrNPCKilled( BCE_OnPlayerOrNPCKilled )
	AddCallback_OnPlayerRespawned( BCE_PlayerRespawned )
}

function BCE_GetCards( player )
{
	if ( !( "bceCards" in player.s ) )
		player.s.bceCards <- {}

	return player.s.bceCards
}

function BCE_IsHighValueTarget( player )
{
	return "bceHVT" in player.s && player.s.bceHVT
}

function BCE_SpawnCardCount()
{
	return ( GameTime.PlayingTime() / BCE_SECONDS_PER_CARD ).tointeger()
}

function BCE_CardName( key )
{
	switch ( key )
	{
		case "primary":			return "Primary Weapon"
		case "sidearm":			return "Sidearm"
		case "secondary":		return "Anti-Titan Weapon"
		case "grenade":			return "Ordnance"
		case "tactical":		return "Amped Tactical"
		case "stim_forever":	return "Perma Stim"
		case "cloak_forever":	return "Perma Cloak"
		case "sonar_forever":	return "Perma Sonar"
		case "fast_movespeed":	return "Fast Movespeed"
		case "pilot_warning":	return "Pilot Warning"
		case "minimap":			return "Minimap"
	}

	return key
}

// The weapon a slot card would upgrade, or null
function BCE_GetSlotWeapon( player, key )
{
	local mains = player.GetMainWeapons()
	local offhands = player.GetOffhandWeapons()

	switch ( key )
	{
		case "primary":		return mains.len() > 0 ? mains[0] : null
		case "sidearm":		return mains.len() > 1 ? mains[1] : null
		case "secondary":	return mains.len() > 2 ? mains[2] : null
		case "grenade":		return offhands.len() > 0 ? offhands[0] : null
		case "tactical":	return offhands.len() > 1 ? offhands[1] : null
	}

	return null
}

// Name of the burn card mod that upgrades this weapon, or null when the game has none for it
function BCE_GetBurnMod( weapon, key )
{
	if ( !IsValid( weapon ) )
		return null

	local className = weapon.GetClassname()
	local modName = null

	if ( key == "tactical" )
	{
		switch ( className )
		{
			case "mp_ability_heal":		modName = "bc_super_stim"; break
			case "mp_ability_cloak":	modName = "bc_super_cloak"; break
			case "mp_ability_sonar":	modName = "bc_super_sonar"; break
		}
	}
	else
	{
		switch ( className )
		{
			case "mp_weapon_grenade_emp":	modName = "burn_mod_emp_grenade"; break
			case "mp_weapon_mega1":			modName = "burn_mod_valkyrie"; break
			case "mp_weapon_mega2":			modName = "burn_mod_twinb"; break
			default:						modName = "burn_mod_" + className.slice( 10 ); break
		}
	}

	if ( modName == null || !weapon.HasModDefined( modName ) )
		return null

	return modName
}

function BCE_CardAvailable( player, key )
{
	switch ( key )
	{
		case "primary":
		case "sidearm":
		case "secondary":
		case "grenade":
		case "tactical":
			return BCE_GetBurnMod( BCE_GetSlotWeapon( player, key ), key ) != null
	}

	return true
}

// Every card this pilot could still be given: not already held, and one that has something to apply to
function BCE_GetCandidates( player )
{
	local held = BCE_GetCards( player )
	local candidates = []

	foreach ( key in level.bceCardKeys )
	{
		if ( key in held )
			continue

		if ( BCE_CardAvailable( player, key ) )
			candidates.append( key )
	}

	return candidates
}

function BCE_AddWeaponMod( weapon, modName )
{
	local mods = []
	foreach ( mod in weapon.GetMods() )
		mods.append( mod )

	if ( ArrayContains( mods, modName ) )
		return

	mods.append( modName )
	weapon.SetMods( mods )
}

function BCE_ApplyCard( player, key )
{
	player.EndSignal( "Disconnected" )
	player.EndSignal( "OnDeath" )

	while ( IsValid( player.isSpawning ) )
		wait 0.1

	if ( player.IsTitan() )
	{
		player.WaitSignal( "OnLeftTitan" )
		wait 0.5
	}

	switch ( key )
	{
		case "primary":
		case "sidearm":
		case "secondary":
		case "grenade":
		case "tactical":
			local weapon = BCE_GetSlotWeapon( player, key )
			local modName = BCE_GetBurnMod( weapon, key )
			if ( modName != null )
				BCE_AddWeaponMod( weapon, modName )
			break

		case "stim_forever":
			player.stimmedForever = true
			StimPlayer( player, USE_TIME_INFINITE )
			break

		case "cloak_forever":
			EnableCloakForever( player )
			break

		case "sonar_forever":
			ActivateBurnCardSonar( player, 9999 )
			break

		case "fast_movespeed":
			GiveServerFlag( player, SFLAG_BC_FAST_MOVESPEED )
			break

		case "pilot_warning":
			BCSpiderSense( player )
			break

		case "minimap":
			GivePassiveLifeLong( player, PAS_MINIMAP_ALL )
			break
	}
}

function BCE_Notify( player, text )
{
	SendHudMessage( player, text, -1, 0.4, 255, 255, 255, 255, 0.5, 3.0, 1.0 )
}

// The stock burn card this card corresponds to, for its animation. Weapon cards use the card made for the equipped weapon.
function BCE_GetCardRef( key, weapon )
{
	switch ( key )
	{
		case "stim_forever":	return "bc_stim_forever"
		case "cloak_forever":	return "bc_cloak_forever"
		case "sonar_forever":	return "bc_sonar_forever"
		case "fast_movespeed":	return "bc_fast_movespeed"
		case "pilot_warning":	return "bc_pilot_warning"
		case "minimap":			return "bc_minimap"
	}

	if ( !IsValid( weapon ) )
		return null

	local className = weapon.GetClassname()
	foreach ( ref in level.burnCards )
	{
		local data = GetBurnCardData( ref )
		if ( "Weapon" in data && data.Weapon == className )
			return ref
	}

	return null
}

// The same burn card animation FFA plays for the minimap scan, shown to the pilot who got the card
function BCE_PlayCardAnimation( player, key )
{
	local ref = BCE_GetCardRef( key, BCE_GetSlotWeapon( player, key ) )
	local index = ref != null ? GetBurnCardIndexByRef( ref ) : null

	if ( index == null || index == -1 )
	{
		BCE_Notify( player, "+ " + BCE_CardName( key ) ) // no burn card exists for this weapon
		return
	}

	Remote.CallFunction_NonReplay( player, "ServerCallback_PlayerUsesBurnCard", player.GetEncodedEHandle(), index, true )
}

function BCE_GiveCard( player, key )
{
	BCE_GetCards( player )[ key ] <- true
	thread BCE_ApplyCard( player, key )
	BCE_PlayCardAnimation( player, key )
	BCE_CheckHighValueTarget( player )
}

// Pulls up to count random cards that fit, returns how many were given
function BCE_PullCards( player, count )
{
	local given = 0
	for ( local i = 0; i < count; i++ )
	{
		local candidates = BCE_GetCandidates( player )
		if ( candidates.len() == 0 )
			break

		BCE_GiveCard( player, Random( candidates ) )
		given++
	}

	return given
}

function BCE_CheckHighValueTarget( player )
{
	if ( BCE_IsHighValueTarget( player ) )
		return

	local held = BCE_GetCards( player )
	foreach ( key in level.bcePermaKeys )
	{
		if ( !( key in held ) )
			return
	}

	if ( held.len() - level.bcePermaKeys.len() < BCE_HVT_OTHER_CARDS )
		return

	player.s.bceHVT <- true

	foreach ( other in GetPlayerArray() )
		BCE_Notify( other, player.GetPlayerName() + " is a HIGH-VALUE TARGET" )
}

function BCE_ClearCards( player )
{
	local held = BCE_GetCards( player )

	if ( "fast_movespeed" in held )
		TakeServerFlag( player, SFLAG_BC_FAST_MOVESPEED )

	if ( "minimap" in held )
		TakePassive( player, PAS_MINIMAP_ALL )

	player.s.bceCards = {}
	player.s.bceHVT <- false
}

function BCE_PlayerRespawned( player )
{
	thread BCE_SpawnCards( player )
}

function BCE_SpawnCards( player )
{
	player.EndSignal( "Disconnected" )
	player.EndSignal( "OnDeath" )

	while ( IsValid( player.isSpawning ) )
		wait 0.1

	wait 1.0 // after the loadout has been given

	// Cards held across a respawn that was not a death are put back first
	foreach ( key, v in BCE_GetCards( player ) )
		thread BCE_ApplyCard( player, key )

	BCE_PullCards( player, BCE_SpawnCardCount() - BCE_GetCards( player ).len() )
}

function BCE_OnPlayerOrNPCKilled( victim, attacker, damageInfo )
{
	if ( !victim.IsPlayer() )
		return

	local victimWasTarget = BCE_IsHighValueTarget( victim )
	BCE_ClearCards( victim )

	if ( GetGameState() >= eGameState.WinnerDetermined )
		return

	local scorer = GetEntityOwningPlayer( attacker )
	if ( !IsValid( scorer ) || !scorer.IsPlayer() || scorer == victim )
		return

	if ( ShouldPreventFriendlyFire( victim, scorer ) )
		return

	scorer.SetAssaultScore( scorer.GetAssaultScore() + ( victimWasTarget ? 2 : 1 ) )

	if ( !IsAlive( scorer ) )
		return

	local pulls = 1
	if ( victimWasTarget )
	{
		pulls = 2

		// One of the permanent tactical cards they were carrying, if the killer is missing any
		local held = BCE_GetCards( scorer )
		local missing = []
		foreach ( key in level.bcePermaKeys )
		{
			if ( !( key in held ) )
				missing.append( key )
		}

		if ( missing.len() > 0 )
			BCE_GiveCard( scorer, Random( missing ) )
	}

	BCE_PullCards( scorer, pulls )
}

main()
