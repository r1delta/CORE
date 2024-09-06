function CodeCallback_OnSpawned( ent )
{
	local classname = ent.GetClassname()

	if ( classname in _entityClassVars )
	{
		if ( !ent._entityVars )
			InitEntityVars( ent )

		//ent.ConnectOutput( "OnDestroy", "_RemoveFromEntityList" )
	}

    if ( IsLobby() )
    {
		local name = ent.GetName()
		if ( name != "" )
			AddToNameList( ent, name )
		ent.scope().RunMySpawnFunctionsMP()
        return
    }

	if ( ent.IsNPC() )
	{
		// all NPCs run these functions
		foreach ( func in level._npcSpawnCallbacks )
		{
			func( ent )
		}
	}

	// this avoids spamming script errors if something went wrong early on.
	if ( !("level" in getroottable()) )
	{
		Assert( 0 )
		return
	}

	local name = ent.GetName()
	if ( name != "" )
		AddToNameList( ent, name )

	if ( ent instanceof CBaseCombatCharacter && ent.GetModelName() != "" )
		InitDamageStates( ent )

	/*
	if ( !( "totalSpawned" in level ) )
	{
		level.totalSpawned <- {}
		level.totalSpawned.total <- 0
	}

	if ( !( "classname" in level.totalSpawned ) )
	{
		level.totalSpawned[ classname ] <- {}
	}

	level.totalSpawned[ classname ][ ent ] <- ent
	level.totalSpawned.total++
	*/

	RegisterForDamageDeathCallbacks( ent )

	if ( IsMultiplayer() )
	{
		ent.scope().RunMySpawnFunctionsMP()
		return
	}

	RunMySpawnFunctionsSP( ent )
}

function RunMySpawnFunctionsSP( self )
{
	if ( !IsValid_ThisFrame( self ) )
	{
		// entity was deleted already
		return
	}

	local classname = self.GetClassname()

	if ( !( classname in level.SpawnActions ) )
	{
		return
	}

	if ( classname in level.SpawnActionsLiving )
	{
		if ( !IsAlive( self ) )
		{
			return
		}
	}

	foreach ( idx, action in level.SpawnActions[ classname ] )
	{
		if ( action.type == "script" )
		{
			IncludeScript( action.script, self.GetScriptScope() )
		}
		else if ( action.type == "function" )
		{
			local args = ArrayCopy( action.args )
			args.insert( 0, this )
			args.append( self )

			local infos = action.func.getinfos()
			Assert( infos.parameters.len() == args.len(), "AddSpawnFunction function " + infos.name + " has invalid number of parameters." )

			action.func.acall( args )
		}
		else if ( action.type == "callback" )
		{
			Assert( action.args.len() == 1 )
			local args = ArrayCopy( action.args )
			args.append( self )
			action.func.acall( args )
		}

		if ( !IsValid_ThisFrame( self ) ) // could die during spawn funcs
		{
			return
		}
	}

	if ( !IsMultiplayer() && IsPlayer( self ) )
	{
		thread __PlayerDidSpawn( self )
	}
}


function RunMySpawnFunctionsMP()
{
	if ( !IsValid_ThisFrame( self ) )
	{
		// entity was deleted already
		return
	}

	local classname = self.GetClassname()

	if ( !( classname in level.SpawnActions ) )
	{
		return
	}

	if ( classname in level.SpawnActionsLiving )
	{
		if ( !IsAlive( self ) )
		{
			return
		}
	}

	foreach ( idx, action in level.SpawnActions[ classname ] )
	{
		if ( action.type == "script" )
		{
			IncludeScript( action.script, self.GetScriptScope() )
		}
		else if ( action.type == "function" )
		{
			local args = ArrayCopy( action.args )
			args.insert( 0, this )
			args.append( self )

			local infos = action.func.getinfos()
			Assert( infos.parameters.len() == args.len(), "AddSpawnFunction function " + infos.name + " has invalid number of parameters." )

			action.func.acall( args )
		}
		else if ( action.type == "callback" )
		{
			Assert( action.args.len() == 1 )
			local args = ArrayCopy( action.args )
			args.append( self )
			action.func.acall( args )
		}

		if ( !IsValid_ThisFrame( self ) ) // could die during spawn funcs
		{
			return
		}
	}

	if ( !IsMultiplayer() && IsPlayer( self ) )
	{
		thread __PlayerDidSpawn( self )
	}
}
