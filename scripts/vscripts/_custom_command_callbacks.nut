
function main()
{
	if ( IsLobby() )
		return

	AddClientCommandCallback( "notarget", ClientCommand_ToggleNotarget )
	AddClientCommandCallback( "demigod", ClientCommand_ToggleDemigod )
	AddClientCommandCallback( "god", ClientCommand_ToggleDemigod )
	AddClientCommandCallback( "kill", ClientCommand_Kill )
	AddClientCommandCallback( "die", ClientCommand_Kill )
	AddClientCommandCallback( "explode", ClientCommand_Explode )
	AddClientCommandCallback( "pinkmist", ClientCommand_Explode )
	AddClientCommandCallback( "dissolve", ClientCommand_Dissolve )
	AddClientCommandCallback( "vanish", ClientCommand_Vanish )

	AddClientCommandCallback( "giveallammo", ClientCommand_GiveAllAmmo )
}

function ClientCommand_ToggleNotarget( player, ... )
{
	if ( !GetConVarBool( "sv_cheats" ) )
		return true

	local name = player.GetPlayerName()

	if ( player.GetNoTarget() )
		printt( name + " TOGGLED NOTARGET OFF" )
	else
		printt( name + " TOGGLED NOTARGET ON" )

	player.SetNoTarget( !player.GetNoTarget() )
	player.SetNoTargetSmartAmmo( player.GetNoTarget() )

	return true
}

function ClientCommand_ToggleDemigod( player, ... )
{
	if ( !GetConVarBool( "sv_cheats" ) )
		return true

	local name = player.GetPlayerName()

	if ( player.IsDemigod() )
	{
		player.DisableDemigod()
		printt( name + " TOGGLED DEMIGOD OFF" )
	}
	else
	{
		player.EnableDemigod()
		printt( name + " TOGGLED DEMIGOD ON" )
	}

	return true
}

function CanUseKillCommands( player )
{
	// Pretty much exacly what i need
	if ( !IsReplacementTitanAvailableForGameState() )
		return false

	if ( !IsAlive( player ) )
		return false

	return true
}

// Using worldspawn as the attacker so titans dont become unavailable for that player after dying
// DF_MELEE makes titans pathetically ragdoll instead of exploding
function ClientCommand_Kill( player, ... )
{
	if ( CanUseKillCommands( player ) )
		player.Die( level.worldspawn, level.worldspawn, { scriptType = DF_MELEE, damageSourceId = eDamageSourceId.suicide } )

	return true
}

function ClientCommand_Explode( player, ... )
{
	if ( CanUseKillCommands( player ) )
		player.Die( level.worldspawn, level.worldspawn, { scriptType = DF_GIB | DF_DISSOLVE, damageSourceId = eDamageSourceId.suicide } )

	return true
}

function ClientCommand_Dissolve( player, ... )
{
	if ( CanUseKillCommands( player ) )
	{
		player.Die( level.worldspawn, level.worldspawn, { scriptType = DF_MELEE, damageSourceId = eDamageSourceId.suicide } )
		player.Dissolve( ENTITY_DISSOLVE_CHAR, Vector( 0, 0, 0 ), 0 )
		EmitSoundAtPosition( player.GetOrigin(), "Object_Dissolve" )
	}

	return true
}

function ClientCommand_Vanish( player, ... )
{
	if ( CanUseKillCommands( player ) )
	{
		player.MakeInvisible()
		player.Die( level.worldspawn, level.worldspawn, { scriptType = DF_MELEE, damageSourceId = eDamageSourceId.suicide } )
	}

	return true
}

function ClientCommand_GiveAllAmmo( player, ... )
{
	if ( !GetConVarBool( "sv_cheats" ) )
		return true

	RestockPlayerAmmo( player )
	EmitSoundOnEntity( player, "Coop_AmmoBox_AmmoRefill" )

	return true
}

main()
