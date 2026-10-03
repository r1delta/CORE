//=========================================================
// Bot slot manager
// Fills the match with script-driven pilot bots up to delta_bot_fill_target
// (humans + bots). A bot leaves whenever a human joins and comes back when one leaves.
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

	switch ( GameRules.GetGameMode() )
	{
		case ATTRITION:
		case TEAM_DEATHMATCH:
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
	if ( state < eGameState.Prematch || state >= eGameState.WinnerDetermined )
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

	local desiredBots = max( 0, GetBotFillTarget() - humans.len() )

	while ( bots.len() > desiredBots )
	{
		local bot = ChooseBotToRemove( bots )
		ArrayRemove( bots, bot )
		RemoveManagedBot( bot )
	}

	for ( local count = bots.len(); count < desiredBots; count++ )
		AddManagedBot( GetTeamNeedingPlayer() )
}

function GetTeamNeedingPlayer()
{
	return GetTeamPlayerCount( TEAM_IMC ) <= GetTeamPlayerCount( TEAM_MILITIA ) ? TEAM_IMC : TEAM_MILITIA
}

// Remove from the larger team so the human who just joined keeps teams even.
// Within that team prefer a dead bot, then a pilot, and leave titan bots for last.
function ChooseBotToRemove( bots )
{
	local imcCount = GetTeamPlayerCount( TEAM_IMC )
	local militiaCount = GetTeamPlayerCount( TEAM_MILITIA )
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
	local name = RandomInt( 2 ) == 0 ? GenerateGamertag() : GenerateCallsign()
	for ( local attempt = 0; attempt < 10 && !BotNameAvailable( name ); attempt++ )
		name = RandomInt( 2 ) == 0 ? GenerateGamertag() : GenerateCallsign()

	if ( !BotNameAvailable( name ) )
		name = name + RandomInt( 1000 )

	if ( name.len() > BOT_NAME_MAX_LEN )
		name = name.slice( 0, BOT_NAME_MAX_LEN )
	return name
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
