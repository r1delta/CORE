//=====================================================================================
//
//=====================================================================================


function main()
{
	level.damageCallbacks <- {} // these run when the entity is damage
	level.damageByCallbacks <- {} // these run when the entity is damage by specified classname
	level.damageCallbacksSourceID <- {} // these run when the entity is damage
	level.deathCallbacks <- {} // these run when the entity is destroyed
    level.onPlayerRespawnedCallbacks <- {} // these run whenever a player respawns
	level.onClientConnectingCallbacks <- {} // these run whenever a client begins connecting
	level.onClientConnectedCallbacks <- {} // these run whenever a client finished connecting
	level.onClientDisconnectingCallbacks <- {} // these run whenever a client disconnects
	level.onPilotBecomesTitanCallbacks <- {} // these run whenever a pilot player becomes a Titan
	level.onTitanBecomesPilotCallbacks <- {} // these run whenever a Titan player becomes a Pilot
	level.onPlayerKilledCallbacks <- {} //
	level.onTitanDoomedCallbacks <- {}
	level.titanDamageScaler <- {}
	level.onClientChatMsgCallbacks <- {}
	level.onOverrideLoadoutCallbacks <- {}
	level.onChangeLoadoutCallbacks <- {}

	IncludeScript( "_codecallbacks_shared", getroottable() )

	if ( IsMultiplayer() )
	{
		if ( !IsMenuLevel() )
		{
			IncludeScript( "_codecallbacks_mp", getroottable() )
		}
		IncludeScript( "_codecallbacks_matchmaking", getroottable() )
	}

}





function CodeCallback_DamageEntity( entity, damageInfo )
{
	// damage forwarding
	if ( "damageForwarding" in entity.s )
	{
		if ( IsValid( entity.s.damageForwarding ) )
			entity.s.damageForwarding.TakeDamage( damageInfo.GetDamage(), damageInfo.GetAttacker(), damageInfo.GetInflictor(), { weapon = damageInfo.GetWeapon(), origin = damageInfo.GetDamagePosition(), force = damageInfo.GetDamageForce(), scriptType = damageInfo.GetCustomDamageType(), damageSourceId = damageInfo.GetDamageSourceIdentifier() } )
		return
	}

	if ( IsMultiplayer() )
	{
		// gametype script decides if entity should take damage
		if ( !ScriptCallback_ShouldEntTakeDamage( entity, damageInfo ) )
		{
			damageInfo.SetDamage( 0 )
			return
		}
		local inflictor = damageInfo.GetInflictor()
		if( "damageNonPlayerEntities" in inflictor.s && inflictor.s.damageNonPlayerEntities == false )
		{
			damageInfo.SetDamage( 0 )
			return
		}

		if ( damageInfo.GetDamageSourceIdentifier() == eDamageSourceId.titan_step )
			HandleFootstepDamage( entity, damageInfo )

		// other scripts can modify damage values
		local className = entity.GetClassname()
		if ( className in level.damageCallbacks )
		{
			foreach ( callbackInfo in level.damageCallbacks[className] )
				callbackInfo.func.acall( [callbackInfo.scope, entity, damageInfo] )
		}

		local damageSourceId = damageInfo.GetDamageSourceIdentifier()
		if ( damageSourceId in level.damageCallbacksSourceID )
		{
			foreach ( callbackInfo in level.damageCallbacksSourceID[ damageSourceId ] )
				callbackInfo.func.acall( [callbackInfo.scope, entity, damageInfo] )
		}

		// make destructible vehicles take more damage from DF_EXPLOSION damage type
		if ( "isDestructibleVehicle" in entity.s && damageInfo.GetCustomDamageType() & DF_EXPLOSION )
			damageInfo.SetDamage( damageInfo.GetDamage() * 2.0 )

		if ( damageInfo.GetDamage() == 0 )
			return

		MPCallback_DamageEntity( entity, damageInfo )
	}

	if ( entity instanceof CBaseCombatCharacter )
		UpdateDamageState( entity, damageInfo )

	// some entities do not have the "OnDamaged" output
	if ( "codeCallbackSignalOnDamaged" in entity.s )
	{
		Assert( !entity.HasOutput( "OnDamaged" ) )
		local results = {}
		results.self <- entity
		results.activator <- damageInfo.GetAttacker()
		results.caller <- entity
		results.value <- damageInfo.GetDamage()
		results.inflictor <- damageInfo.GetInflictor()

		Signal( entity, "OnDamaged", results )
	}
}

function TrySpectreVirus( victim, damageInfo )
{
	local attacker = damageInfo.GetAttacker()
	if ( !victim.IsSpectre() )
		return false
	if ( !IsAlive( attacker ) )
		return false
	if ( !attacker.IsTitan() )
		return false
	if ( !attacker.IsPlayer() )
		return false
	if ( !PlayerHasPassive( attacker, PAS_WIFI_SPECTRE ) )
		return false

	thread LeechPropagate( victim, attacker )
	return true
}


function HandleFootstepDamage( victim, damageInfo )
{
	if ( TrySpectreVirus( victim, damageInfo ) )
	{
		damageInfo.SetDamage( 0 )
		return
	}

	if ( ShouldTakeFootstepDamage( victim, damageInfo ) )
	{
		damageInfo.SetDamage( 0 )
		return
	}
}

function ShouldTakeFootstepDamage( victim, damageInfo )
{
	if ( "ignoreFootstepDamage" in victim.s && victim.s.ignoreFootstepDamage == true )
		return true

	//Turn off footstep damage if attacker is Titan and trying to step on you,
	//otherwise lunge assist will pull attacker forward and step on victim
	local attacker = damageInfo.GetAttacker()
	if ( IsPlayerTitanAttackerMeleeingVictim( attacker, victim ) )
		return true

	return false
}



function CodeCallback_OnEntityKilled( entity, damageInfo )
{
	HandleDeathPackage( entity, damageInfo )

	if ( "OnEntityKilled" in entity.s )
		entity.s.OnEntityKilled( entity, damageInfo )

	local className = entity.GetClassname()
	if ( className in level.deathCallbacks )
	{
		foreach ( callbackInfo in level.deathCallbacks[className] )
			callbackInfo.func.acall( [callbackInfo.scope, entity, damageInfo] )
	}

	// some entities do not have the "OnDeath" output
	if ( "codeCallbackSignalOnDeath" in entity.s )
	{
		Assert( !entity.HasOutput( "OnDeath" ) )
		local results = {}
		results.self <- entity
		results.activator <- damageInfo.GetAttacker()
		results.caller <- entity

		Signal( entity, "OnDeath", results )
	}

	SendEntityKilledEvent( entity, damageInfo )
}


function SendEntityKilledEvent( entity, damageInfo )
{
	local players = GetPlayerArray()

	local attacker = damageInfo.GetAttacker()
	// trigger_hurt is no longer networked, so the "attacker" fails to display obituaries
	if ( attacker )
	{
		local attackerClassname = attacker.GetClassname()

		if ( attackerClassname == "trigger_hurt" || attackerClassname == "trigger_multiple" )
			attacker = GetEntByIndex( 0 ) // worldspawn
	}

	local attackerEHandle = attacker ? attacker.GetEncodedEHandle() : null

	local victimEHandle = entity.GetEncodedEHandle()
	local scriptDamageType = damageInfo.GetCustomDamageType()
	local damageSourceId = damageInfo.GetDamageSourceIdentifier()

	if ( scriptDamageType & DF_VORTEX_REFIRE )
		damageSourceId = eDamageSourceId.mp_titanweapon_vortex_shield

	if ( IsValidHeadShot( damageInfo, entity ) )
		scriptDamageType = scriptDamageType | DF_HEADSHOT
	else
		scriptDamageType = scriptDamageType & (~DF_HEADSHOT)

	foreach ( player in players )
	{
		Remote.CallFunction_NonReplay( player, "ServerCallback_OnEntityKilled", attackerEHandle, victimEHandle, scriptDamageType, damageSourceId )
	}
}

//=====================================================================================
// Utility functions
//=====================================================================================

function AddDamageCallback( className, callbackFunc )
{
	Assert( "damageCallbacks" in level )
	Assert( type( this ) == "table", "AddDamageCallback can only be added on a table. " + type( this ) )
	AssertParameters( callbackFunc, 2, "entity, damageInfo" )

	if ( !( className in level.damageCallbacks ) )
		level.damageCallbacks[className] <- []

	local callbackInfo = {}
	callbackInfo.func <- callbackFunc
	callbackInfo.scope <- this

	level.damageCallbacks[className].append( callbackInfo )
}

function AddToTitanDamageScaling( ent, scale )
{
	level.titanDamageScaler[ ent ] <- scale
}

function ClearTitanDamageScaling( ent )
{
	if ( ent in level.titanDamageScaler )
		delete level.titanDamageScaler[ ent ]
}

function AddDamageByCallback( className, callbackFunc )
{
	Assert( "damageByCallbacks" in level )
	Assert( type( this ) == "table", "AddDamageByCallback can only be added on a table. " + type( this ) )
	AssertParameters( callbackFunc, 2, "entity, damageInfo" )

	if ( !( className in level.damageByCallbacks ) )
		level.damageByCallbacks[className] <- []

	local callbackInfo = {}
	callbackInfo.func <- callbackFunc
	callbackInfo.scope <- this

	level.damageByCallbacks[className].append( callbackInfo )
}

function RemoveDamageCallback( className, callbackFunc )
{
	Assert( "damageCallbacks" in level )
	Assert( type( this ) == "table", "RemoveDamageCallback can only be removed on a table. " + type( this ) )
	AssertParameters( callbackFunc, 2, "entity, damageInfo" )

	Assert ( className in level.damageCallbacks )

	local targetCallbackIndex = -1
	local damageCallbackArray = level.damageCallbacks[ className ]
	for ( local i = 0; i < damageCallbackArray.len(); ++i )
	{
		if ( damageCallbackArray[ i ].func == callbackFunc )
		{
			targetCallbackIndex = i
			break
		}
	}

	Assert( targetCallbackIndex >= 0, " Requested DamageCallback to be removed not found! " )
	damageCallbackArray.remove( targetCallbackIndex )
}

function DamageCallbackExists( className, callbackFunc )
{
	Assert( "damageCallbacks" in level )
	AssertParameters( callbackFunc, 2, "entity, damageInfo" )

	if ( !( className in level.damageCallbacks ) )
		return false

	local foundIt = false
	local damageCallbackArray = level.damageCallbacks[ className ]
	for ( local i = 0; i < damageCallbackArray.len(); ++i )
	{
		if ( damageCallbackArray[ i ].func == callbackFunc )
		{
			foundIt = true
			break
		}
	}

	return foundIt
}

function AddDamageCallbackSourceID( id, callbackFunc )
{
	Assert( "damageCallbacksSourceID" in level )
	Assert( type( this ) == "table", "AddDamageCallbackSourceID can only be added on a table. " + type( this ) )
	AssertParameters( callbackFunc, 2, "entity, damageInfo" )

	if ( !( id in level.damageCallbacksSourceID ) )
		level.damageCallbacksSourceID[id] <- []

	local callbackInfo = {}
	callbackInfo.func <- callbackFunc
	callbackInfo.scope <- this

	level.damageCallbacksSourceID[id].append( callbackInfo )
}

function AddDeathCallback( className, callbackFunc )
{
	Assert( "deathCallbacks" in level )
	Assert( type( this ) == "table", "AddDeathCallback can only be added on a table. " + type( this ) )
	AssertParameters( callbackFunc, 2, "entity, damageInfo" )

	if ( !( className in level.deathCallbacks ) )
		level.deathCallbacks[className] <- []

	local callbackInfo = {}
	callbackInfo.func <- callbackFunc
	callbackInfo.scope <- this

	level.deathCallbacks[className].append( callbackInfo )
}


function AddCallback_OnPlayerRespawned( callbackFunc )
{
	Assert( "onPlayerRespawnedCallbacks" in level )
	Assert( type( this ) == "table", "AddCallback_OnPlayerRespawned can only be added on a table. " + type( this ) )
	AssertParameters( callbackFunc, 1, "player" )

	local name = FunctionToString( callbackFunc )
	Assert( !( name in level.onPlayerRespawnedCallbacks ), "Already added " + name + " with AddCallback_OnPlayerRespawned" )

	local callbackInfo = {}
	callbackInfo.name <- name
	callbackInfo.func <- callbackFunc
	callbackInfo.scope <- this

	level.onPlayerRespawnedCallbacks[name] <- callbackInfo
}


function AddCallback_OnPlayerKilled( callbackFunc )
{
	Assert( "onPlayerKilledCallbacks" in level )
	Assert( type( this ) == "table", "AddCallback_OnPlayerKilled can only be added on a table. " + type( this ) )
	AssertParameters( callbackFunc, 2, "player, damageInfo" )

	local name = FunctionToString( callbackFunc )
	Assert( !( name in level.onPlayerKilledCallbacks ), "Already added " + name + " with AddCallback_OnPlayerKilled" )

	local callbackInfo = {}
	callbackInfo.name <- name
	callbackInfo.func <- callbackFunc
	callbackInfo.scope <- this

	level.onPlayerKilledCallbacks[name] <- callbackInfo
}


function AddCallback_OnTitanDoomed( callbackFunc )
{
	Assert( "onTitanDoomedCallbacks" in level )
	Assert( type( this ) == "table", "AddCallback_OnTitanDoomed can only be added on a table. " + type( this ) )
	AssertParameters( callbackFunc, 2, "titan, attacker, inflictor, damageSourceId, weaponName" )

	local name = FunctionToString( callbackFunc )
	Assert( !( name in level.onTitanDoomedCallbacks ), "Already added " + name + " with AddCallback_OnTitanDoomed" )

	local callbackInfo = {}
	callbackInfo.name <- name
	callbackInfo.func <- callbackFunc
	callbackInfo.scope <- this

	level.onTitanDoomedCallbacks[name] <- callbackInfo
}

function AddCallback_OnClientConnecting( callbackFunc )
{
	Assert( "onClientConnectingCallbacks" in level )
	Assert( type( this ) == "table", "AddCallback_OnClientConnecting can only be added on a table. " + type( this ) )
	AssertParameters( callbackFunc, 1, "player" )

	local name = FunctionToString( callbackFunc )
	Assert( !( name in level.onClientConnectingCallbacks ), "Already added " + name + " with AddCallback_OnClientConnecting" )

	local callbackInfo = {}
	callbackInfo.name <- name
	callbackInfo.func <- callbackFunc
	callbackInfo.scope <- this

	level.onClientConnectingCallbacks[name] <- callbackInfo
}


function AddCallback_OnClientConnected( callbackFunc )
{
	Assert( "onClientConnectedCallbacks" in level )
	Assert( type( this ) == "table", "AddCallback_OnClientConnected can only be added on a table. " + type( this ) )
	AssertParameters( callbackFunc, 1, "player" )

	local name = FunctionToString( callbackFunc )
	Assert( !( name in level.onClientConnectedCallbacks ), "Already added " + name + " with AddCallback_OnClientConnected" )

	local callbackInfo = {}
	callbackInfo.name <- name
	callbackInfo.func <- callbackFunc
	callbackInfo.scope <- this

	level.onClientConnectedCallbacks[name] <- callbackInfo
}


function AddCallback_OnClientDisconnected( callbackFunc )
{
	Assert( "onClientDisconnectingCallbacks" in level )
	Assert( type( this ) == "table", "AddCallback_OnClientDisconnected can only be added on a table. " + type( this ) )
	AssertParameters( callbackFunc, 1, "player" )

	local name = FunctionToString( callbackFunc )
	Assert( !( name in level.onClientDisconnectingCallbacks ), "Already added " + name + " with AddCallback_OnClientDisconnected" )

	local callbackInfo = {}
	callbackInfo.name <- name
	callbackInfo.func <- callbackFunc
	callbackInfo.scope <- this

	level.onClientDisconnectingCallbacks[name] <- callbackInfo
}

function AddCallback_OnPilotBecomesTitan( callbackFunc )
{
	Assert( "onPilotBecomesTitanCallbacks" in level )
	Assert( type( this ) == "table", "AddCallback_OnPilotBecomesTitan can only be added on a table. " + type( this ) )
	AssertParameters( callbackFunc, 2, "player, npc_titan" )

	local name = FunctionToString( callbackFunc )
	Assert( !( name in level.onPilotBecomesTitanCallbacks ), "Already added " + name + " with AddCallback_OnPilotBecomesTitan" )

	local callbackInfo = {}
	callbackInfo.name <- name
	callbackInfo.func <- callbackFunc
	callbackInfo.scope <- this

	level.onPilotBecomesTitanCallbacks[name] <- callbackInfo
}

function AddCallback_OnTitanBecomesPilot( callbackFunc )
{
	Assert( "onTitanBecomesPilotCallbacks" in level )
	Assert( type( this ) == "table", "AddCallback_OnTitanBecomesPilot can only be added on a table. " + type( this ) )
	AssertParameters( callbackFunc, 2, "playerTitan, npc_titan" )

	local name = FunctionToString( callbackFunc )
	Assert( !( name in level.onTitanBecomesPilotCallbacks ), "Already added " + name + " with AddCallback_OnTitanBecomesPilot" )

	local callbackInfo = {}
	callbackInfo.name <- name
	callbackInfo.func <- callbackFunc
	callbackInfo.scope <- this

	level.onTitanBecomesPilotCallbacks[name] <- callbackInfo
}


function EnableDamageForwarding( damagedEnt, targetEnt )
{
	Assert( IsValid ( damagedEnt ) )
	Assert( IsValid( targetEnt ) )

	damagedEnt.SetDamageNotifications( true )

	if ( !( "damageForwarding" in damagedEnt.s ) )
		damagedEnt.s.damageForwarding <- null
	damagedEnt.s.damageForwarding = targetEnt
}

//=====================================================================================
// Register functions are called when an entity spawns.
//=====================================================================================

function RegisterForDamageDeathCallbacks( entity )
{
	local className = entity.GetClassname()

	if ( className in level.damageCallbacks )
		entity.SetDamageNotifications( true )

	if ( className in level.deathCallbacks )
		entity.SetDeathNotifications( true )
}


function CodeCallback_OnInventoryChanged( player )
{
}

function CodeCallback_OnEntityChangedTeam( entity )
{
}

function AddCallback_OnClientChatMsg( callbackFunc )
{
	Assert( "onClientChatMsgCallbacks" in level )
	Assert( type( this ) == "table", "AddCallback_OnClientChatMsg can only be added on a table. " + type( this ) )
	AssertParameters( callbackFunc, 3, "playerIndex, msg, isTeamChat" )

	local name = FunctionToString( callbackFunc )
	Assert( !( name in level.onClientChatMsgCallbacks ), "Already added " + name + " with AddCallback_OnClientChatMsg" )

	local callbackInfo = {}
	callbackInfo.name <- name
	callbackInfo.func <- callbackFunc
	callbackInfo.scope <- this

	level.onClientChatMsgCallbacks[name] <- callbackInfo
}

function CodeCallback_OnClientChatMsg( playerIndex, msg, isTeamChat )
{
    local primaryoutput = msg
	foreach ( callbackInfo in level.onClientChatMsgCallbacks )
	{
		local text = callbackInfo.func.acall( [callbackInfo.scope, playerIndex, msg, isTeamChat] )
		if ( text == "" ) {
			primaryoutput = ""} //if one callback wants to block the message, the message will always be blocked
        else if (primaryoutput != "" && text != msg) {
            primaryoutput = text // elsewise fight it out idk and hope for best?
        }
	}
	return primaryoutput
}

function AddCallback_OnOverrideLoadout( callbackFunc )
{
	Assert( "onOverrideLoadoutCallbacks" in level )
	Assert( type( this ) == "table", "AddCallback_OnOverrideLoadout can only be added on a table. " + type( this ) )
	AssertParameters( callbackFunc, 3, "player, loadoutTable, isTitan" )

	local name = FunctionToString( callbackFunc )
	Assert( !( name in level.onOverrideLoadoutCallbacks ), "Already added " + name + " with AddCallback_OnOverrideLoadout" )

	local callbackInfo = {}
	callbackInfo.name <- name
	callbackInfo.func <- callbackFunc
	callbackInfo.scope <- this

	level.onOverrideLoadoutCallbacks[name] <- callbackInfo
}

function AddCallback_OnChangeLoadout( callbackFunc )
{
	Assert( "onChangeLoadoutCallbacks" in level )
	Assert( type( this ) == "table", "AddCallback_OnChangeLoadout can only be added on a table. " + type( this ) )
	AssertParameters( callbackFunc, 3, "player, loadoutTable, isTitan" )

	local name = FunctionToString( callbackFunc )
	Assert( !( name in level.onChangeLoadoutCallbacks ), "Already added " + name + " with AddCallback_OnChangeLoadout" )

	local callbackInfo = {}
	callbackInfo.name <- name
	callbackInfo.func <- callbackFunc
	callbackInfo.scope <- this

	level.onChangeLoadoutCallbacks[name] <- callbackInfo
}

main()