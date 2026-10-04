// Burn Card Escalation: free for all where burn cards stack on one pilot. Every pilot spawns with one random card for
// every BCE_SECONDS_PER_CARD seconds the match has been running, and each kill on another pilot pulls one more.
// A pilot holding the three permanent tactical cards, Map Hack and Prosthetic Legs, plus at least BCE_HVT_OTHER_CARDS
// other cards, becomes a High-Value Target: killing them is worth 2 points, 2 cards and one of their permanent tactical cards.
// Those five cards are never handed out by spawn cards, nor by a pilot's first BCE_HVT_CARD_MIN_KILLS kills of a life.
//
// Cards come in two kinds. Pilot cards are slot-style keys (see level.bceCardKeys in main): weapon cards add the burn mod of
// whatever weapon is equipped in that slot, so a pilot keeps their own loadout. Titan cards each fill one of seven Titan slots
// (level.bceTitanSlots) and only come for what the pilot's Titan loadout has equipped: the amped weapon cards follow the Titan's
// primary, ordnance and tactical, and Massive Payload needs the Nuclear Eject kit. They wait on the pilot and are used up by the
// pilot's next Titan drop.
// The first cards of a life are handed out in a fixed order (level.bceOpeningSteps), after that at random.

const BCE_HVT_OTHER_CARDS = 3
const BCE_SECONDS_PER_CARD = 90.0
const BCE_HVT_CARD_MIN_KILLS = 3 // kills in one life before kill cards can include the cards a High-Value Target needs

function main()
{
	// Order only matters for display; availability decides what can be pulled
	level.bceCardKeys <- [
		"primary", "sidearm", "secondary", "grenade", "tactical",
		"stim_forever", "cloak_forever", "sonar_forever",
		"fast_movespeed", "pilot_warning", "minimap"
	]

	level.bcePermaKeys <- [ "stim_forever", "cloak_forever", "sonar_forever" ]

	// Everything a High-Value Target must hold, on top of BCE_HVT_OTHER_CARDS other cards: the permanent tacticals,
	// Map Hack ("minimap") and Prosthetic Legs ("fast_movespeed")
	level.bceHvtKeys <- [ "stim_forever", "cloak_forever", "sonar_forever", "minimap", "fast_movespeed" ]

	// The only weapon mods an amped weapon keeps: the scope the pilot had equipped
	level.bceScopes <- { iron_sights = true, hcog = true, holosight = true, aog = true, scope_4x = true, scope_6x = true }

	// The order cards are handed out in at the start of a life; after the last step they are drawn at random from everything left.
	//   pilot: a common pilot card    titan: a Titan card    rare: a rare pilot card (see BCE_NextCardKey)
	level.bceOpeningSteps <- [ "pilot", "titan", "pilot", "rare", "titan" ]

	// The seven Titan slots and the burn cards that can fill each one
	level.bceTitanKeys <- [ "titan_primary", "titan_tactical", "titan_ordnance", "titan_core", "titan_dash", "titan_punch", "titan_nuclear" ]
	level.bceTitanSlots <- {
		titan_primary = [ "bc_titan_40mm_m2", "bc_titan_arc_cannon_m2", "bc_titan_rocket_launcher_m2", "bc_titan_sniper_m2", "bc_titan_triple_threat_m2", "bc_titan_xo16_m2" ],
		titan_tactical = [ "bc_titan_vortex_shield_m2", "bc_titan_electric_smoke_m2", "bc_titan_shield_wall_m2" ],
		titan_ordnance = [ "bc_titan_dumbfire_missile_m2", "bc_titan_homing_rockets_m2", "bc_titan_salvo_rockets_m2", "bc_titan_shoulder_rockets_m2" ],
		titan_core = [ "bc_core_charged" ],			// Super Charger
		titan_dash = [ "bc_extra_dash" ],			// Turbo Engine
		titan_punch = [ "bc_titan_melee_m2" ],		// Explosive Punch
		titan_nuclear = [ "bc_nuclear_core" ]		// Massive Payload (amped nuclear eject)
	}

	AddCallback_PlayerOrNPCKilled( BCE_OnPlayerOrNPCKilled )
	AddCallback_OnPlayerRespawned( BCE_PlayerRespawned )
	AddCallback_OnChangeLoadout( BCE_OnChangeLoadout )
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

function BCE_IsTitanKey( key )
{
	return key in level.bceTitanSlots
}

// Cards held that are not Titan cards
function BCE_PilotCardCount( player )
{
	local count = 0
	foreach ( key, v in BCE_GetCards( player ) )
	{
		if ( !BCE_IsTitanKey( key ) )
			count++
	}

	return count
}

// The keys of the held cards in the order they were given (the HUD list shows them that way)
function BCE_GetCardOrder( player )
{
	if ( !( "bceOrder" in player.s ) )
		player.s.bceOrder <- []

	return player.s.bceOrder
}

// How many steps of the opening order this life has used
function BCE_GetSequenceStep( player )
{
	return "bceSeq" in player.s ? player.s.bceSeq : 0
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

// Every card this pilot could still be given: not already held, and one that has something to apply to.
// The cards a High-Value Target needs are left out unless allowHvtCards.
function BCE_GetCandidates( player, allowHvtCards )
{
	local held = BCE_GetCards( player )
	local candidates = []

	foreach ( key in level.bceCardKeys )
	{
		if ( key in held )
			continue

		if ( !allowHvtCards && ArrayContains( level.bceHvtKeys, key ) )
			continue

		if ( BCE_CardAvailable( player, key ) )
			candidates.append( key )
	}

	return candidates
}

// Amps a weapon with the card's mod. A main weapon loses every mod except its scope (an amped R-97 with a Scatterfire
// barrel would be too strong); offhands keep what they had. Perk mods (pas_*) are put back by the game whenever a
// weapon's mods change, so they are neither kept nor counted here.
//
// Mods set on the weapon in the pilot's hands are listed but do not count (orange crosshair, amped damage) until the weapon
// is next drawn, and cards arrive in the middle of fights. So the held weapon is holstered around the change and
// redeployed in the same frame: the new mods count at once, with no weapon switch and no replacement weapon (no ammo reset).
function BCE_AddWeaponMod( player, weapon, modName, keepOnlyScope )
{
	local current = []
	foreach ( mod in weapon.GetMods() )
	{
		if ( mod.find( "pas_" ) != 0 )
			current.append( mod )
	}

	local mods = []
	foreach ( mod in current )
	{
		if ( mod == modName )
			continue

		if ( !keepOnlyScope || mod in level.bceScopes )
			mods.append( mod )
	}
	mods.append( modName )

	local same = mods.len() == current.len()
	foreach ( mod in mods )
	{
		if ( !ArrayContains( current, mod ) )
			same = false
	}
	if ( same )
		return

	local held = player.GetActiveWeapon() == weapon
	if ( held )
		player.HolsterWeapon()

	// The engine can reject a mod change that comes right after another one on the same weapon, so try again next frame
	local applied = false
	for ( local attempt = 0; attempt < 10 && !applied; attempt++ )
	{
		try
		{
			weapon.SetMods( mods )
			applied = true
		}
		catch ( e )
		{
			wait 0
		}
	}

	// Losing extended ammo and the like shrinks the magazine; don't leave the extra rounds in it
	if ( applied && keepOnlyScope )
	{
		local baseClip = GetWeaponInfoFileKeyField_Global( weapon.GetClassname(), "ammo_clip_size" )
		if ( baseClip != null && weapon.GetWeaponPrimaryClipCount() > baseClip.tointeger() )
			weapon.SetWeaponPrimaryClipCount( baseClip.tointeger() )
	}

	if ( held )
	{
		player.DeployWeapon()
		weapon.SetNextAttackAllowedTime( Time() ) // the draw animation still plays, but the pilot can fire straight away
	}
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
				BCE_AddWeaponMod( player, weapon, modName, key != "grenade" && key != "tactical" )
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

// The same burn card animation FFA plays for the minimap scan, shown to the pilot who got the card.
// Returns the index of the burn card that was shown, or null when the game has no burn card for this one.
function BCE_PlayCardAnimation( player, key, ref )
{
	local index = ref != null ? GetBurnCardIndexByRef( ref ) : null

	if ( index == null || index == -1 )
	{
		BCE_Notify( player, "+ " + BCE_CardName( key ) ) // no burn card exists for this weapon
		return null
	}

	Remote.CallFunction_NonReplay( player, "ServerCallback_PlayerUsesBurnCard", player.GetEncodedEHandle(), index, true )
	return index
}

function BCE_GiveCard( player, key )
{
	// Each slot holds one card
	if ( key in BCE_GetCards( player ) )
		return

	// The stock burn card this card stands for: the card made for the weapon equipped in the slot (the pilot's own weapon for
	// a pilot card, the weapon in the Titan loadout for a Titan card)
	local ref = null
	if ( BCE_IsTitanKey( key ) )
	{
		ref = BCE_GetTitanSlotRef( player, key )
		if ( ref == null )
			return // nothing in the Titan loadout this card could amp
	}
	else
		ref = BCE_GetCardRef( key, BCE_GetSlotWeapon( player, key ) )

	BCE_GetCards( player )[ key ] <- ( ref != null ? ref : true )
	BCE_GetCardOrder( player ).append( key )

	// Titan cards wait for the next Titan drop (BCE_ApplyTitanCards)
	if ( !BCE_IsTitanKey( key ) )
		thread BCE_ApplyCard( player, key )

	// The client keeps the lists of cards shown on the HUD (see client/cl_gamemode_burn_card_escalation.nut)
	local index = BCE_PlayCardAnimation( player, key, ref )
	if ( index != null )
		Remote.CallFunction_NonReplay( player, BCE_IsTitanKey( key ) ? "ServerCallback_BCE_TitanCardAdded" : "ServerCallback_BCE_CardAdded", index )

	BCE_CheckHighValueTarget( player )
}

// Random element of a list, or null when it is empty
function BCE_RandomOrNull( list )
{
	return list.len() > 0 ? Random( list ) : null
}

function BCE_IsRareCard( key )
{
	local ref = BCE_GetCardRef( key, null )
	return ref != null && GetBurnCardData( ref ).rarity == BURNCARD_RARE
}

// The keys of the list that are rare (rare = true) or not rare (rare = false) pilot cards
function BCE_FilterRare( keys, rare )
{
	local out = []
	foreach ( key in keys )
	{
		if ( BCE_IsRareCard( key ) == rare )
			out.append( key )
	}

	return out
}

// The burn card that amps a weapon of this class in a Titan slot, or null when the game has none for it
function BCE_FindTitanWeaponRef( key, className )
{
	if ( className == null )
		return null

	foreach ( ref in level.bceTitanSlots[ key ] )
	{
		local data = GetBurnCardData( ref )
		if ( "Weapon" in data && data.Weapon == className )
			return ref
	}

	return null
}

// The card this pilot's Titan loadout can be given for a slot, or null when nothing equipped fits. The weapon slots follow
// the weapons in the loadout, the nuclear card needs the Nuclear Eject kit, and the core, dash and punch cards fit every Titan.
function BCE_GetTitanSlotRef( player, key )
{
	local loadout = player.playerClassData[ "titan" ]

	switch ( key )
	{
		case "titan_primary":
			return BCE_FindTitanWeaponRef( key, loadout.primaryWeapon )

		case "titan_ordnance":
		case "titan_tactical":
			local slot = key == "titan_ordnance" ? 0 : 1
			local offhands = loadout.offhandWeapons
			if ( !offhands || !( slot in offhands ) || !( "weapon" in offhands[ slot ] ) )
				return null

			return BCE_FindTitanWeaponRef( key, offhands[ slot ].weapon )

		case "titan_nuclear":
			local kits = 0
			if ( loadout.passive1 )
				kits = kits | loadout.passive1
			if ( loadout.passive2 )
				kits = kits | loadout.passive2

			if ( ( kits & PAS_BUILD_UP_NUCLEAR_CORE ) == 0 )
				return null
			break
	}

	return level.bceTitanSlots[ key ][0]
}

// The card for the weapon a dropped Titan really carries in a slot. The loadout can change between earning a card and the
// drop, and the card has to amp what the Titan has.
function BCE_GetTitanEquippedRef( titan, key )
{
	local className = null

	if ( key == "titan_primary" )
	{
		local mains = titan.GetMainWeapons()
		if ( mains.len() > 0 )
			className = mains[0].GetClassname()
	}
	else
	{
		local slot = key == "titan_ordnance" ? 0 : 1
		local offhands = titan.GetOffhandWeapons()
		if ( offhands.len() > slot && IsValid( offhands[ slot ] ) )
			className = offhands[ slot ].GetClassname()
	}

	return BCE_FindTitanWeaponRef( key, className )
}

// Titan slots this pilot has no card for yet and has something equipped to fill
function BCE_GetTitanCandidates( player )
{
	local held = BCE_GetCards( player )
	local candidates = []
	foreach ( key in level.bceTitanKeys )
	{
		if ( !( key in held ) && BCE_GetTitanSlotRef( player, key ) != null )
			candidates.append( key )
	}

	return candidates
}

// The next card this pilot gets: the next step of the opening order while this life has one left, then any card at random.
// A step that has nothing to give falls back to a common pilot card; only a rare step held up by allowHvtCards (the rare
// cards are the ones a High-Value Target needs) stays put, so the next card that may be rare takes it. Null when no card is left.
function BCE_NextCardKey( player, allowHvtCards )
{
	local seq = BCE_GetSequenceStep( player )
	local pilot = BCE_GetCandidates( player, allowHvtCards )
	local titan = BCE_GetTitanCandidates( player )
	local common = BCE_FilterRare( pilot, false )
	local step = seq < level.bceOpeningSteps.len() ? level.bceOpeningSteps[ seq ] : "any"
	local key = null
	local advance = true

	if ( step == "pilot" )
	{
		key = BCE_RandomOrNull( common )
	}
	else if ( step == "titan" )
	{
		key = BCE_RandomOrNull( titan )
	}
	else if ( step == "rare" )
	{
		key = BCE_RandomOrNull( BCE_FilterRare( pilot, true ) )

		// No rare card to give: either they are all held (the step is done) or the pilot may not have them yet (the step waits)
		if ( key == null )
			advance = BCE_FilterRare( BCE_GetCandidates( player, true ), true ).len() == 0
	}
	else
	{
		local all = []
		all.extend( pilot )
		all.extend( titan )
		key = BCE_RandomOrNull( all )
	}

	if ( key == null )
		key = BCE_RandomOrNull( common )
	if ( key == null )
		key = BCE_RandomOrNull( pilot )
	if ( key == null )
		key = BCE_RandomOrNull( titan )
	if ( key == null )
		return null

	if ( advance && seq < level.bceOpeningSteps.len() )
		player.s.bceSeq <- seq + 1

	return key
}

// Pulls up to count cards, returns how many were given
function BCE_PullCards( player, count, allowHvtCards )
{
	local given = 0
	for ( local i = 0; i < count; i++ )
	{
		local key = BCE_NextCardKey( player, allowHvtCards )
		if ( key == null )
			break

		BCE_GiveCard( player, key )
		given++
	}

	return given
}

function BCE_CheckHighValueTarget( player )
{
	if ( BCE_IsHighValueTarget( player ) )
		return

	local held = BCE_GetCards( player )
	foreach ( key in level.bceHvtKeys )
	{
		if ( !( key in held ) )
			return
	}

	if ( BCE_PilotCardCount( player ) - level.bceHvtKeys.len() < BCE_HVT_OTHER_CARDS )
		return

	player.s.bceHVT <- true

	// Shown to everyone like the First Strike notification (see ServerCallback_BCE_HighValueTarget in the client script)
	foreach ( other in GetPlayerArray() )
		Remote.CallFunction_NonReplay( other, "ServerCallback_BCE_HighValueTarget", player.GetEncodedEHandle() )

	thread BCE_HighValueTargetMinimap( player )
}

// A High-Value Target is on everyone's minimap for as long as they are one. They have Map Hack, so this evens it out.
// Whatever else works out what a pilot sees on their minimap (the free for all scan that gives everyone Map Hack for three
// seconds every ten and takes it away again, a pilot's passives changing, a respawn) puts the HVT back to the default for that
// pilot, so it is applied again ten times a second. When the HVT dies the minimap goes back to what each pilot's own passives say.
function BCE_HighValueTargetMinimap( target )
{
	target.EndSignal( "OnDeath" )
	target.EndSignal( "Disconnected" )

	OnThreadEnd(
		function() : ( target )
		{
			if ( !IsValid( target ) )
				return

			foreach ( viewer in GetPlayerArray() )
			{
				if ( viewer != target )
					UpdateMinimapStatus( viewer )
			}
		}
	)

	for ( ;; )
	{
		foreach ( viewer in GetPlayerArray() )
		{
			if ( viewer == target )
				continue

			target.Minimap_AlwaysShow( TEAM_INVALID, viewer )

			// The stock minimap code does the same: the line above does not reach the viewers in free for all
			if ( IsFFABased() )
			{
				target.Minimap_AlwaysShow( TEAM_IMC, viewer )
				target.Minimap_AlwaysShow( TEAM_MILITIA, viewer )
			}
		}

		wait 0.1
	}
}

function BCE_ClearCards( player )
{
	local held = BCE_GetCards( player )

	if ( "fast_movespeed" in held )
		TakeServerFlag( player, SFLAG_BC_FAST_MOVESPEED )

	if ( "minimap" in held )
		TakePassive( player, PAS_MINIMAP_ALL )

	// Titan cards wait for the next Titan drop and survive the pilot's death
	local titanCards = {}
	local order = []
	foreach ( key in BCE_GetCardOrder( player ) )
	{
		if ( BCE_IsTitanKey( key ) && key in held )
		{
			titanCards[ key ] <- held[ key ]
			order.append( key )
		}
	}

	player.s.bceCards = titanCards
	player.s.bceOrder = order
	player.s.bceSeq <- 0
	BCE_SyncCardList( player )
	player.s.bceHVT <- false
	player.s.bceKills <- 0
}

// Tells the client which cards the pilot holds, in the order they were given
function BCE_SyncCardList( player )
{
	Remote.CallFunction_NonReplay( player, "ServerCallback_BCE_CardsCleared" )

	local held = BCE_GetCards( player )
	foreach ( key in BCE_GetCardOrder( player ) )
	{
		if ( !( key in held ) )
			continue

		local ref = held[ key ]
		local index = typeof( ref ) == "string" ? GetBurnCardIndexByRef( ref ) : null
		if ( index != null && index != -1 )
			Remote.CallFunction_NonReplay( player, BCE_IsTitanKey( key ) ? "ServerCallback_BCE_TitanCardAdded" : "ServerCallback_BCE_CardAdded", index )
	}
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

	// Cards held across a respawn that was not a death are put back first (Titan cards wait for a Titan drop)
	foreach ( key, v in BCE_GetCards( player ) )
	{
		if ( !BCE_IsTitanKey( key ) )
			thread BCE_ApplyCard( player, key )
	}

	BCE_PullCards( player, BCE_SpawnCardCount() - BCE_PilotCardCount( player ), false )
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
	local kills = BCE_CountKill( scorer )

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

	BCE_PullCards( scorer, pulls, kills > BCE_HVT_CARD_MIN_KILLS )
}

// Kills this pilot has made since they last died
function BCE_CountKill( player )
{
	if ( !( "bceKills" in player.s ) )
		player.s.bceKills <- 0

	player.s.bceKills++
	return player.s.bceKills
}

// ---- Titan cards ----

// Runs whenever a pilot or a Titan gets a loadout. When a Titan does, the Titan cards the pilot is holding go on it.
// Disembarking, ejecting and Titan executions also make a Titan from a player; there the player is still a Titan when this runs,
// and those are not drops, so the cards keep waiting for the next drop.
function BCE_OnChangeLoadout( player, loadoutTable, isTitan )
{
	if ( isTitan && !player.IsTitan() )
		thread BCE_ApplyTitanCards( player )
}

// The Titan cards the pilot is holding, in the order they were given
function BCE_GetTitanCardKeys( player )
{
	local held = BCE_GetCards( player )
	local keys = []
	foreach ( key in BCE_GetCardOrder( player ) )
	{
		if ( BCE_IsTitanKey( key ) && key in held )
			keys.append( key )
	}

	return keys
}

function BCE_RemoveCard( player, key )
{
	local held = BCE_GetCards( player )
	if ( key in held )
		delete held[ key ]

	local order = BCE_GetCardOrder( player )
	for ( local i = order.len() - 1; i >= 0; i-- )
	{
		if ( order[i] == key )
			order.remove( i )
	}
}

// Puts the Titan cards on the pilot's Titan as it drops and uses them up; the slots are free to be earned again afterwards
function BCE_ApplyTitanCards( player )
{
	player.EndSignal( "Disconnected" )

	// A Titan can get its loadout more than once; one application at a time
	if ( "bceApplyingTitan" in player.s && player.s.bceApplyingTitan )
		return

	if ( BCE_GetTitanCardKeys( player ).len() == 0 )
		return

	player.s.bceApplyingTitan <- true
	OnThreadEnd(
		function() : ( player )
		{
			if ( IsValid( player ) )
				player.s.bceApplyingTitan <- false
		}
	)

	// The pilot is the Titan when they spawn as one, otherwise their Titan is in the map
	local titan = null
	for ( local tries = 0; tries < 100; tries++ )
	{
		titan = player.IsTitan() ? player : GetPlayerTitanInMap( player )
		if ( IsAlive( titan ) && IsValid( titan.GetTitanSoul() ) )
			break

		titan = null
		wait 0.1
	}

	if ( titan == null )
		return

	local soul = titan.GetTitanSoul()
	local held = BCE_GetCards( player )
	local flags = []
	local nuclear = false

	foreach ( key in BCE_GetTitanCardKeys( player ) )
	{
		local ref = held[ key ]

		switch ( key )
		{
			case "titan_primary":
			case "titan_tactical":
			case "titan_ordnance":
				local weaponRef = BCE_GetTitanEquippedRef( titan, key )
				if ( weaponRef != null )
					ApplyTitanWeaponBurnCard( titan, weaponRef )
				break

			case "titan_core":
				SetCoreCharged( soul )
				break

			case "titan_dash":
			case "titan_punch":
				local flag = GetBurnCardData( ref ).serverFlags
				GiveServerFlag( player, flag )
				flags.append( flag )
				break

			case "titan_nuclear":
				GivePassiveLifeLong( player, PAS_NUCLEAR_CORE )
				nuclear = true
				break
		}

		BCE_RemoveCard( player, key )
	}

	BCE_SyncCardList( player )

	if ( flags.len() > 0 || nuclear )
		thread BCE_TakeAwayTitanCards( player, soul, flags, nuclear )
}

// The Titan's flags and passive go with the Titan
function BCE_TakeAwayTitanCards( player, soul, flags, nuclear )
{
	soul.EndSignal( "OnTitanDeath" )
	player.EndSignal( "Disconnected" )

	OnThreadEnd(
		function() : ( player, flags, nuclear )
		{
			if ( !IsValid( player ) )
				return

			foreach ( flag in flags )
				TakeServerFlag( player, flag )

			if ( nuclear )
				TakePassive( player, PAS_NUCLEAR_CORE )
		}
	)

	WaitForever()
}

main()
