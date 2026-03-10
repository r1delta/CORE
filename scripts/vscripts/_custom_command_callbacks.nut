
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

	// "getpos" is already taken but doesnt work
	AddClientCommandCallback( "getposs", ClientCommand_GetPos )
	AddClientCommandCallback( "getmypos", ClientCommand_GetPos )
	AddClientCommandCallback( "getplayerpos", ClientCommand_GetPos )
	AddClientCommandCallback( "getscriptpos", ClientCommand_GetScriptPos )
	AddClientCommandCallback( "setpos", ClientCommand_SetPos )
	AddClientCommandCallback( "setang", ClientCommand_SetAng )
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
	// Pretty much exactly what i need
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

function ClientCommand_GetPos( player, ... )
{
	printt( "==========================" )

	local pos = player.GetOrigin()
	local ang = VectorToAngles( player.GetViewVector() )

	if ( vargc > 0 )
		ang.x = 0

	printt( PrettyVector( pos ) + ", " + PrettyVector( ang ) )
	printt( format( "setpos %f %f %f; setang %f %f", pos.x, pos.y, pos.z, ang.x, ang.y ) )

	printt( "==========================" )

	return true
}

function ClientCommand_GetScriptPos( player, ... )
{
	printt( "==========================" )

	local pos = player.GetOrigin()
	local ang = VectorToAngles( player.GetViewVector() )

	if ( vargc > 0 )
		ang.x = 0

	printt( "{ origin = " + PrettyVector( pos ) + ", " + "angles = " + PrettyVector( ang ) + " }," )
	printt( format( "setpos %f %f %f; setang %f %f", pos.x, pos.y, pos.z, ang.x, ang.y ) )

	printt( "==========================" )

	return true
}

function ClientCommand_SetPos( player, ... )
{
	if ( !GetConVarBool( "sv_cheats" ) )
		return true

	if ( !CanUseKillCommands( player ) )
		return true

	if ( vargc < 3 )
		return true

	local pos = Vector( vargv[0].tofloat(), vargv[1].tofloat(), vargv[2].tofloat() )
	ClampToWorldspace( pos )

	player.SetOrigin( pos )
	//PrintVector( pos )

	return true
}

function ClientCommand_SetAng( player, ... )
{
	if ( !GetConVarBool( "sv_cheats" ) )
		return true

	if ( !CanUseKillCommands( player ) )
		return true

	if ( vargc < 2 )
		return true

	local x = clamp( vargv[0].tofloat(), -360.0, 360.0 )
	local y = clamp( vargv[1].tofloat(), -360.0, 360.0 )

	local ang = Vector( x, y, 0 )
	player.SetAngles( ang )
	//PrintVector( ang )

	return true
}

main()
