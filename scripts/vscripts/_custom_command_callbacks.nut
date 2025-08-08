
function main()
{
	if ( IsLobby() )
		return

	AddClientCommandCallback( "notarget", ClientCommand_ToggleNotarget )
	AddClientCommandCallback( "demigod", ClientCommand_ToggleDemigod )
	AddClientCommandCallback( "god", ClientCommand_ToggleDemigod )
	AddClientCommandCallback( "kill", ClientCommand_Kill )
	AddClientCommandCallback( "explode", ClientCommand_Explode )
	AddClientCommandCallback( "pinkmist", ClientCommand_Explode )
	AddClientCommandCallback( "dissolve", ClientCommand_Dissolve )

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

function ClientCommand_Kill( player, ... )
{
	if ( IsAlive( player ) && !player.IsTitan() )
		player.Die()

	return true
}

function ClientCommand_Explode( player, ... )
{
	if ( IsAlive( player ) && !player.IsTitan() )
		player.Die( null, null, { scriptType = DF_GIB | DF_DISSOLVE } )

	return true
}

function ClientCommand_Dissolve( player, ... )
{
	if ( IsAlive( player ) && !player.IsTitan() )
	{
		player.Dissolve( ENTITY_DISSOLVE_CHAR, Vector( 0, 0, 0 ), 0 )
		EmitSoundAtPosition( player.GetOrigin(), "Object_Dissolve" )
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
