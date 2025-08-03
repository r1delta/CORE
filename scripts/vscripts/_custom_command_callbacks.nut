
function main()
{
	if ( IsLobby() )
		return

	AddClientCommandCallback( "notarget", ClientCommand_ToggleNotarget )
	AddClientCommandCallback( "demigod", ClientCommand_ToggleDemigod )
	AddClientCommandCallback( "god", ClientCommand_ToggleDemigod )
	AddClientCommandCallback( "kill", ClientCommand_Kill )
	AddClientCommandCallback( "explode", ClientCommand_Explode )
	AddClientCommandCallback( "pinkmist", ClientCommand_Pinkmist )
	AddClientCommandCallback( "dissolve", ClientCommand_Dissolve )

	AddClientCommandCallback( "giveallammo", ClientCommand_GiveAllAmmo )
}

function ClientCommand_ToggleNotarget( player, ... )
{
	if ( !GetConVarBool( "sv_cheats" ) )
		return true

	if ( player.GetNoTarget() )
		print( player + " TOGGLED NOTARGET OFF" )
	else
		print( player + " TOGGLED NOTARGET ON" )

	player.SetNoTarget( !player.GetNoTarget() )
	player.SetNoTargetSmartAmmo( player.GetNoTarget() )

	return true
}

function ClientCommand_ToggleDemigod( player, ... )
{
	if ( !GetConVarBool( "sv_cheats" ) )
		return true

	if ( player.IsDemigod() )
	{
		player.DisableDemigod()
		print( player + " TOGGLED DEMIGOD OFF" )
	}
	else
	{
		player.EnableDemigod()
		print( player + " TOGGLED DEMIGOD ON" )
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
		player.Die( null, null, { scriptType = DF_GIB } )

	return true
}

function ClientCommand_Pinkmist( player, ... )
{
	if ( IsAlive( player ) && !player.IsTitan() )
		player.Dissolve( ENTITY_DISSOLVE_PINKMIST, Vector( 0 , 0, 0 ), 500 )

	return true
}

function ClientCommand_Dissolve( player, ... )
{
	if ( IsAlive( player ) && !player.IsTitan() )
	{
		EmitSoundAtPosition( player.GetOrigin(), "Object_Dissolve" )
		player.Dissolve( ENTITY_DISSOLVE_CHAR, Vector( 0, 0, 0 ), 0 )
	}

	return true
}

function ClientCommand_GiveAllAmmo( player, ... )
{
	if ( !GetConVarBool( "sv_cheats" ) )
		return true

	player.RefillAllAmmo()
	EmitSoundOnEntity( player, "Coop_AmmoBox_AmmoRefill" )

	return true
}

main()
