// global player passives

// script GivePassive( GetPlayerArray()[0], PAS_ENHANCED_TITAN_AI	)


function main()
{
	Globalize( SetupLoader )
	Globalize( GetPlayerClassDataTable )

	Globalize( UpdateLastPilotLoadout )
	Globalize( UpdateLastTitanLoadout )
	Globalize( NewPilotLoadoutSelected )
	Globalize( NewTitanLoadoutSelected )

	Globalize( Loader_InitAllLoadoutTables )
}

function SetupLoader( player )
{
	// for dev
	if ( GetDeveloperLevel() > 0 )
		player.AddClientCommandCallback( "DoomTitan", ClientCommand_DoomTitan )
}

function Loader_InitPilotTable( player )
{
	local isCustom = player.GetPersistentVar( "pilotSpawnLoadout.isCustom" )
	local loadoutIndex = player.GetPersistentVar( "pilotSpawnLoadout.index" )
	player.s.pilotLoadout <- null
	player.s.pilotLoadoutCustom <- isCustom
	player.s.pilotLoadoutIndex <- loadoutIndex
	player.s.lastPilotLoadoutIndex <- null
	player.s.lastPilotLoadoutCustom <- null

	// moved to here from CodeCallback_OnClientConnectionStarted to see if that fixes bug #81099
	player.s.usedLoadoutCrate <- false
	player.s.restockAmmoTime <- 0
	player.s.restockAmmoCrate <- null
}

function Loader_InitTitanTable( player )
{
	local isCustom = player.GetPersistentVar( "titanSpawnLoadout.isCustom" )
	local loadoutIndex = player.GetPersistentVar( "titanSpawnLoadout.index" )
	player.s.titanLoadout <- null
	player.s.titanLoadoutCustom <- isCustom
	player.s.titanLoadoutIndex <- loadoutIndex
	player.s.lastTitanLoadoutIndex <- null
	player.s.lastTitanLoadoutCustom <- null
}

function Loader_InitAllLoadoutTables( player )
{
	FixInvalidGamemodeLoadoutIndex( player )
	Loader_InitPilotTable( player )
	Loader_InitTitanTable( player )
}

function GetPlayerClassDataTable( self, loaderClass )
{
	return self.playerClassData[ loaderClass ]
}

function FixInvalidGamemodeLoadoutIndex( player )
{
	local gameMode = GetConVarString( "mp_gamemode" )
	if ( !PersistenceEnumValueIsValid( "gameModesWithLoadouts", gameMode ) )
		return

	local currentPilotLoadoutIndex = player.GetPersistentVar( "pilotSpawnLoadout.index" )
	local currentTitanLoadoutIndex = player.GetPersistentVar( "titanSpawnLoadout.index" )
	local modeIndex = PersistenceGetEnumIndexForItemName( "gameModesWithLoadouts", gameMode )

	// Get the loadout slots that are gamemode valid
	local validGamemodeLoadouts = []
	for ( local i = 0 ; i < NUM_GAMEMODE_LOADOUTS ; i++ )
		validGamemodeLoadouts.append( NUM_CUSTOM_LOADOUTS + (modeIndex * NUM_GAMEMODE_LOADOUTS) + i )

	if ( currentPilotLoadoutIndex >= NUM_CUSTOM_LOADOUTS && !ArrayContains( validGamemodeLoadouts, currentPilotLoadoutIndex ) )
	{
		// Player not using a valid index, reset it
		player.SetPersistentVar( "pilotSpawnLoadout.index", 0 )
	}

	if ( currentTitanLoadoutIndex >= NUM_CUSTOM_LOADOUTS && !ArrayContains( validGamemodeLoadouts, currentTitanLoadoutIndex ) )
	{
		// Player not using a valid index, reset it
		player.SetPersistentVar( "titanSpawnLoadout.index", 0 )
	}
}

function ClientCommand_DoomTitan()
{
	local titan
	if( self.IsTitan() )
		titan = self
	else
		titan = self.GetPetTitan()
	if ( !IsAlive( titan ) )
		return true

	if ( titan.GetDoomedState() )
		return true

	local soul = titan.GetTitanSoul()
	soul.SetShieldHealth( 0 )

	titan.TakeDamage( titan.GetHealth(), null, null, { damageSourceId=eDamageSourceId.suicide } )

	return true
}

function NewPilotLoadoutSelected( player )
{
	if ( player.s.pilotLoadoutIndex != player.s.lastPilotLoadoutIndex )
		return true

	if ( player.s.pilotLoadoutCustom != player.s.lastPilotLoadoutCustom )
		return true

	return false
}


function NewTitanLoadoutSelected( player )
{
	if ( player.s.titanLoadoutIndex != player.s.lastTitanLoadoutIndex )
		return true

	if ( player.s.titanLoadoutCustom != player.s.lastTitanLoadoutCustom )
		return true

	return false
}

function UpdateLastPilotLoadout( player )
{
	player.s.lastPilotLoadoutIndex = player.s.pilotLoadoutIndex
	player.s.lastPilotLoadoutCustom = player.s.pilotLoadoutCustom
}

function UpdateLastTitanLoadout( player )
{
	player.s.lastTitanLoadoutIndex = player.s.titanLoadoutIndex
	player.s.lastTitanLoadoutCustom = player.s.titanLoadoutCustom
}