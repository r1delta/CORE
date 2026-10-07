//=========================================================
// Bot slot manager
// Fills the match with script-driven pilot bots up to delta_bot_fill_target
// (humans + bots). Bots join as soon as the first human connects, so the match starts
// with them; a bot leaves whenever a human joins and comes back when one leaves.
//=========================================================

const BOT_RECONCILE_DELAY = 1.0

function main()
{
	Globalize( IsManagedBot )
	Globalize( BotManagerEnabledForMode )
	Globalize( GetBotFillTarget )
	Globalize( BotRandomizeLoadouts )

	RegisterSignal( "BotReconcile" )

	level.managedBots <- {}
	// Names of bots inside BotCreate: the engine runs the connect/first-spawn callbacks
	// before BotCreate returns, so this is how IsManagedBot recognises them that early.
	level.pendingBotNames <- {}
	file.reconcileQueued <- false
	file.watchStarted <- false

	if ( !BotManagerEnabledForMode() )
	{
		printt( "BotManager: disabled for game mode", GameRules.GetGameMode() )
		return
	}

	FlagSet( "PilotBot" )	// bots spawn as pilots and call titans themselves

	AddCallback_OnClientConnected( BotManager_OnClientConnected )
	AddCallback_OnClientDisconnected( BotManager_OnClientDisconnected )
	AddCallback_GameStateEnter( eGameState.WaitingForPlayers, BotManager_OnMatchStateEnter )
	AddCallback_GameStateEnter( eGameState.Prematch, BotManager_OnMatchStateEnter )
	AddCallback_GameStateEnter( eGameState.Playing, BotManager_OnMatchStateEnter )
}

function BotManager_OnMatchStateEnter()
{
	if ( !file.watchStarted )
	{
		file.watchStarted = true
		thread BotFillTargetWatchThread()
	}
	QueueBotReconcile()
}

// delta_bot_fill_target can be changed from the console mid-match; nothing else would notice it.
function BotFillTargetWatchThread()
{
	local lastTarget = GetBotFillTarget()
	while ( true )
	{
		wait 1.0
		local target = GetBotFillTarget()
		if ( target == lastTarget )
			continue

		printt( "BotManager: fill target changed to", target )
		lastTarget = target
		QueueBotReconcile()
	}
}

function BotManagerEnabledForMode()
{
	// The bot natives come from tier0.dll (server/ai/bot_control.cpp). Without them (an older
	// tier0.dll) these scripts do nothing and the game behaves like stock.
	if ( !( "BotCreate" in getroottable() ) )
		return false

	// Capture Point is played as an objective mode (see GetObjectivePoint in _bot_ai).
	switch ( GameRules.GetGameMode() )
	{
		case ATTRITION:
		case TEAM_DEATHMATCH:
		case CAPTURE_POINT:
			return true
	}
	return false
}

function IsManagedBot( player )
{
	if ( player in level.managedBots )
		return true
	return player.IsBot() && ( player.GetPlayerName() in level.pendingBotNames )
}

function GetBotFillTarget()
{
	local target = GetConVarInt( "delta_bot_fill_target" )
	if ( target <= 0 )
		return 0

	// Always keep one slot open so a human can connect; the bot leaves right after.
	local maxPlayers = GetCurrentPlaylistVarInt( "max players", 12 )
	return min( target, maxPlayers - 1 )
}

// How many bots the match should have with this many humans. The private match settings
// (bot_count, 0-10, see the match settings menu; 10 in a private match until set) ask for that many
// bots, as long as there's room; outside private matches delta_bot_fill_target fills up to a total of
// humans + bots. Either way bots are
// spread over the teams by GetTeamNeedingPlayer, and one slot is always kept open for a human.
function GetDesiredBotCount( humanCount )
{
	// No humans, no bots: an empty server stays empty (and can hibernate).
	if ( humanCount == 0 )
		return 0

	// A private match where the setting was never applied gets the menu's default.
	local count = GetCurrentPlaylistVarInt( "bot_count", -1 )
	if ( count < 0 && IsPrivateMatch() )
		count = PM_BOT_COUNT_DEFAULT
	if ( count < 0 )
		return max( 0, GetBotFillTarget() - humanCount )

	local room = GetCurrentPlaylistVarInt( "max players", 12 ) - 1 - humanCount
	return max( 0, min( min( count, PM_BOT_COUNT_MAX ), room ) )
}

function BotManager_OnClientConnected( player )
{
	if ( !player.IsBot() )
		QueueBotReconcile()
}

function BotManager_OnClientDisconnected( player )
{
	if ( player in level.managedBots )
		delete level.managedBots[ player ]

	if ( !player.IsBot() )
		QueueBotReconcile()
}

function QueueBotReconcile()
{
	if ( file.reconcileQueued )
		return

	file.reconcileQueued = true
	thread BotReconcileThread()
}

function BotReconcileThread()
{
	// Let connects/disconnects settle so counts are not off by the player in transit.
	wait BOT_RECONCILE_DELAY
	file.reconcileQueued = false

	local state = GetGameState()
	// Filling during WaitingForPlayers lets both teams be populated right away, so the
	// match leaves the lobby wait as soon as the first human is in.
	if ( state < eGameState.WaitingForPlayers || state >= eGameState.WinnerDetermined )
		return

	local humans = []
	local bots = []
	foreach ( player in GetPlayerArray() )
	{
		if ( player.IsBot() )
		{
			if ( player in level.managedBots )
				bots.append( player )
		}
		else
		{
			humans.append( player )
		}
	}

	local desiredBots = GetDesiredBotCount( humans.len() )

	// Bots are removed right away, alive or dead: a joining human must never wait for a slot.
	for ( local i = bots.len() - 1; i >= 0; i-- )
	{
		if ( !IsValid( bots[ i ] ) )
			bots.remove( i )
	}

	// The kick goes through the command buffer, so the team counts don't drop until later: keep our
	// own, or two humans joining at once (one per team) would both take a bot off the same team.
	local teamCounts = {}
	teamCounts[ TEAM_IMC ] <- GetTeamPlayerCount( TEAM_IMC )
	teamCounts[ TEAM_MILITIA ] <- GetTeamPlayerCount( TEAM_MILITIA )
	while ( bots.len() > desiredBots )
	{
		local bot = ChooseBotToRemove( bots, teamCounts )
		ArrayRemove( bots, bot )
		local team = bot.GetTeam()
		if ( team in teamCounts )
			teamCounts[ team ]--
		RemoveManagedBot( bot )
	}

	for ( local count = bots.len(); count < desiredBots; count++ )
		AddManagedBot( GetTeamNeedingPlayer() )
}

function AnyHumanDead()
{
	foreach ( player in GetPlayerArray() )
	{
		if ( !player.IsBot() && !IsAlive( player ) )
			return true
	}
	return false
}

function GetTeamNeedingPlayer()
{
	return GetTeamPlayerCount( TEAM_IMC ) <= GetTeamPlayerCount( TEAM_MILITIA ) ? TEAM_IMC : TEAM_MILITIA
}

// Remove from the larger team so the human who just joined keeps teams even.
// Within that team prefer a dead bot, then a pilot, and leave titan bots for last.
// teamCounts: players per team, minus the bots already being kicked this pass.
function ChooseBotToRemove( bots, teamCounts )
{
	local imcCount = teamCounts[ TEAM_IMC ]
	local militiaCount = teamCounts[ TEAM_MILITIA ]
	local preferredTeam = imcCount >= militiaCount ? TEAM_IMC : TEAM_MILITIA

	local best = null
	local bestScore = -1
	foreach ( bot in bots )
	{
		local score = 0
		if ( bot.GetTeam() == preferredTeam )
			score += 4
		if ( !IsAlive( bot ) )
			score += 2
		else if ( !bot.IsTitan() )
			score += 1

		if ( score > bestScore )
		{
			best = bot
			bestScore = score
		}
	}
	return best
}

function AddManagedBot( team )
{
	local requestedName = GenerateBotName()
	level.pendingBotNames[ requestedName ] <- true
	local name = BotCreate( team, requestedName )
	delete level.pendingBotNames[ requestedName ]

	if ( name == "" )
	{
		printt( "BotManager: failed to create bot for team", team )
		return
	}

	foreach ( player in GetPlayerArray() )
	{
		if ( player.IsBot() && player.GetPlayerName() == name )
		{
			level.managedBots[ player ] <- true
			return
		}
	}
}

function RemoveManagedBot( bot )
{
	if ( bot in level.managedBots )
		delete level.managedBots[ bot ]

	BotClearInput( bot )
	ServerCommand( "kickid " + bot.GetUserId() )
}

//---------------------------------------------------------
// Names
//---------------------------------------------------------
const BOT_NAME_MAX_LEN = 31

function PickRandom( array )
{
	return array[ RandomInt( array.len() ) ]
}

function GenerateBotName()
{
	local name = GenerateAnyBotName()
	for ( local attempt = 0; attempt < 10 && !BotNameAvailable( name ); attempt++ )
		name = GenerateAnyBotName()

	if ( !BotNameAvailable( name ) )
		name = name + RandomInt( 1000 )

	if ( name.len() > BOT_NAME_MAX_LEN )
		name = name.slice( 0, BOT_NAME_MAX_LEN )
	return name
}

function GenerateAnyBotName()
{
	switch ( RandomInt( 3 ) )
	{
		case 0:
			return GenerateGamertag()
		case 1:
			return GenerateCallsign()
	}
	return GenerateMemeName()
}

function BotNameAvailable( name )
{
	if ( name in level.pendingBotNames )
		return false

	foreach ( player in GetPlayerArray() )
	{
		if ( player.GetPlayerName() == name )
			return false
	}
	return true
}

// Online-player style: xNightHawk, Viper_77, darkghost99, TheRaptorTV
function GenerateGamertag()
{
	local prefixes = [ "x", "The", "Dark", "Lil", "Mr", "Big", "Its", "Real", "Pro", "Sir", "Hyper", "Toxic" ]
	local words = [ "Viper", "NightHawk", "Ghost", "Raptor", "Shadow", "Blaze", "Phantom", "Reaper", "Falcon", "Havoc",
		"Venom", "Nova", "Striker", "Wolf", "Cobra", "Titan", "Pulse", "Rogue", "Frost", "Onyx", "Specter", "Bandit",
		"Jackal", "Nomad", "Hunter", "Sniper", "Rocket", "Ninja", "Panda", "Tornado", "Kraken", "Vortex", "Glitch",
		"Pixel", "Blitz", "Comet", "Fury", "Banshee", "Cyclone", "Wraith" ]
	local seconds = [ "Runner", "Slayer", "King", "Hawk", "Fox", "Storm", "Shot", "Byte", "Strike", "Rider", "Main", "Gamer" ]
	local suffixes = [ "77", "99", "01", "13", "420", "1337", "007", "TV", "YT", "BR", "Pro", "X", "2k", "_GG" ]

	local name = PickRandom( words )
	if ( RandomInt( 3 ) == 0 )
		name = name + PickRandom( seconds )
	if ( RandomInt( 3 ) == 0 )
		name = PickRandom( prefixes ) + name

	local roll = RandomInt( 4 )
	if ( roll == 0 )
		name = name + "_" + PickRandom( suffixes )
	else if ( roll == 1 )
		name = name + PickRandom( suffixes )
	else if ( roll == 2 )
		name = name + RandomInt( 100 )

	if ( RandomInt( 5 ) == 0 )
		name = name.tolower()
	return name
}

// Titanfall style: Sgt. Blackwood, Raptor-6, Lt. Kane, Echo Mercer
function GenerateCallsign()
{
	local ranks = [ "Pvt.", "Cpl.", "Sgt.", "SSgt.", "Lt.", "Capt.", "Maj.", "Col.", "Cmdr." ]
	local surnames = [ "Blackwood", "Kane", "Mercer", "Graves", "Reyes", "Voss", "Hale", "Bishop", "Cross", "Steele",
		"Ward", "Drake", "Rourke", "Navarro", "Okafor", "Sato", "Ivanov", "Novak", "Silva", "Holt", "Briggs", "Vance",
		"Kowalski", "Mbeki", "Larsen", "Ortega", "Costa", "Fischer", "Tanaka", "Ramos" ]
	local codenames = [ "Raptor", "Echo", "Bravo", "Hammer", "Anvil", "Talon", "Saber", "Vulture", "Jester", "Warden",
		"Halo", "Zulu", "Sierra", "Kilo", "Mako", "Bolt", "Ranger", "Outlaw", "Hydra", "Lancer" ]

	switch ( RandomInt( 3 ) )
	{
		case 0:
			return PickRandom( ranks ) + " " + PickRandom( surnames )
		case 1:
			return PickRandom( codenames ) + "-" + ( RandomInt( 9 ) + 1 )
	}
	return PickRandom( codenames ) + " " + PickRandom( surnames )
}

// Internet meme style: Lt. Larper, Mogger-67, Aura_maxxing, SigmaClanker, xRizzlerx
function GenerateMemeName()
{
	local ranks = [ "Pvt.", "Cpl.", "Sgt.", "Lt.", "Capt.", "Maj.", "Col.", "Cmdr.", "Gen." ]
	// Nouns that read as a person: work after a rank, before a number, alone
	local people = [ "Larper", "Mogger", "Rizzler", "Yapper", "Glazer", "Clanker", "Sigma", "Unc", "NPC", "Delulu",
		"Crashout", "Skibidi", "Mewer", "Jester", "Fanum", "Goober", "Aura Farmer", "Chill Guy", "Ohio Boss",
		"Tung Tung", "Sahur", "Tralalero", "Brainrot", "Ratio", "Copium", "Doomscroll", "Lowtaper", "Huzz" ]
	// Things you can max: Aura_maxxing, Rizzmaxxer
	local maxxables = [ "Aura", "Rizz", "Looks", "Sigma", "Yap", "Mog", "Cope", "Grind", "Jester", "Sleep",
		"Bounce", "Gun", "Wallrun", "Titan", "Ejection" ]
	local tails = [ "67", "6-7", "41", "69", "420", "999", "1000", "NoCap", "Fr", "Ong", "Cooked", "Bussin", "Ohio",
		"Mid", "W", "L", "GOAT", "Era", "Core", "Mode" ]
	local leads = [ "Lowkey", "Highkey", "Certified", "Literally", "Unironically", "Sigma", "Ohio", "Skibidi",
		"Mid", "Cooked", "Chopped", "Delulu", "Locked In", "Based", "Feral", "Cracked", "Goofy" ]

	local name
	switch ( RandomInt( 7 ) )
	{
		case 6:		// John Titanfall
		{
			local john = PickRandom( [ "Titanfall", "Titanfall", "Titanfall", "Pilot", "Wallrun", "Smart Pistol", "Kraber",
				"IMC", "Militia", "Ogre", "Atlas", "Stryder", "Grunt", "Spectre", "Marvin", "Dropship", "Evac",
				"Pork", "Skibidi", "Ohio", "Sigma", "Clanker", "Fortnite", "Respawn" ] )
			return RandomInt( 4 ) == 0 ? "John " + john + " " + PickRandom( [ "2", "Jr.", "III", "67" ] ) : "John " + john
		}
		case 0:		// Lt. Larper
			name = PickRandom( ranks ) + " " + PickRandom( people )
			break
		case 1:		// Mogger-67
			name = PickRandom( people ) + "-" + PickRandom( [ "67", "67", "41", "69", "420", "1000" ] )
			break
		case 2:		// Aura_maxxing, RizzMaxxer
		{
			local base = PickRandom( maxxables )
			local suffix = PickRandom( [ "_maxxing", "maxxing", "Maxxing", "Maxxer", "_maxxer", "maxx" ] )
			name = base + suffix
			break
		}
		case 3:		// CertifiedYapper, Locked In Clanker
			name = PickRandom( leads ) + ( RandomInt( 2 ) == 0 ? " " : "" ) + PickRandom( people )
			break
		case 4:		// Rizzler_NoCap, SigmaOhio
			name = PickRandom( people ) + ( RandomInt( 2 ) == 0 ? "_" : "" ) + PickRandom( tails )
			break
		default:	// xRizzlerx, iAmTheMogger
		{
			local person = PickRandom( people )
			local wrap = RandomInt( 3 )
			if ( wrap == 0 )
				name = "x" + person + "x"
			else if ( wrap == 1 )
				name = "TheReal" + person
			else
				name = "Not" + person
			break
		}
	}

	// Spaces only make sense in the rank/lead styles; tags lose them like real handles
	if ( name.find( "." ) == null && RandomInt( 2 ) == 0 )
		name = StripSpaces( name )
	if ( RandomInt( 6 ) == 0 )
		name = name.tolower()
	return name
}

function StripSpaces( text )
{
	local result = ""
	foreach ( part in split( text, " " ) )
		result = result + part
	return result
}

//---------------------------------------------------------
// Loadouts: rolled once when the bot connects and kept for the whole match
//---------------------------------------------------------
function BotRandomizeLoadouts( player )
{
	local pilotTable = player.playerClassData[ level.pilotClass ]
	RandomizeBotLoadout( pilotTable, false )
	pilotTable.passive1 <- PassiveBitfieldFromEnum( PickRandomItemRef( itemType.PILOT_PASSIVE1 ) )
	pilotTable.passive2 <- PassiveBitfieldFromEnum( PickRandomItemRef( itemType.PILOT_PASSIVE2 ) )
	OverrideBotLoadout( pilotTable, false )

	local titanTable = player.playerClassData[ "titan" ]
	RandomizeBotLoadout( titanTable, true )
	titanTable.passive1 <- PassiveBitfieldFromEnum( PickRandomItemRef( itemType.TITAN_PASSIVE1 ) )
	titanTable.passive2 <- PassiveBitfieldFromEnum( PickRandomItemRef( itemType.TITAN_PASSIVE2 ) )
	OverrideBotLoadout( titanTable, true )

	printt( "BotManager:", player.GetPlayerName(), "pilot", pilotTable.primaryWeapon, pilotTable.secondaryWeapon,
		pilotTable.sidearmWeapon, pilotTable.offhandWeapons[0].weapon, pilotTable.offhandWeapons[1].weapon,
		"| titan", titanTable.playerSetFile, titanTable.primaryWeapon, titanTable.offhandWeapons[0].weapon,
		titanTable.offhandWeapons[1].weapon )
}

function PickRandomItemRef( type )
{
	return PickRandom( GetAllItemsOfType( type ) ).ref
}
