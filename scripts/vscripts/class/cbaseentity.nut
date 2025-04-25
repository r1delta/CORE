//=========================================================
// CBaseEntity
// Properties and methods added here can be accessed on all script entities
//=========================================================
printl( "Class Script: CBaseEntity" )

CBaseEntity.ClassName <- "CBaseEntity"

// Script variables; initializing these to something other than "null" will cause them to be treated as a
// static variable on the class instead of a unique variable on each instance.
CBaseEntity.s <- null
CBaseEntity.kv <- null
CBaseEntity.nv <- null
CBaseEntity.thinkFunc <- null
CBaseEntity.thinkGuid <- null
CBaseEntity.waitFlags <- null

CBaseEntity.thinkContexts <- null
CBaseEntity.nextThinkGuid <- null
CBaseEntity.freeThinkGuids <- null
CBaseEntity.funcsByString <- null

CBaseEntity.useFunction <- null // should match on server/client

CBaseEntity._entityVars <- null

CBaseEntity.invulnerable <- 0

// this replacement could just be made in the scripts where this call happens,
// but there's too many for me to replace right now
CBaseEntity.__KeyValueFromString <- CBaseEntity.SetValueForKey
CBaseEntity.__KeyValueFromInt <- CBaseEntity.SetValueForKey

class KeyValueInterface
{
	self = null

	constructor( ent )
	{
		self = ent
	}

	function _get( key )
	{
		return self.GetValueForKey( key )
	}

	function _set( key, value )
	{
		self.SetValueForKey( key, value )
	}

	function _nexti( prevkey )
	{
		return self.GetNextKey( prevkey )
	}

	function _typeof()
	{
		return "KeyValueInterface"
	}
}

if ( GetDeveloperLevel() > 0 )
{
	function CBaseEntity::constructor()
	{
		this.s = delegate __scriptVarDelegate : {}
		this.kv = KeyValueInterface( this.weakref() )
		this.nv = NetworkValueInterface( this.weakref() )

		this.useFunction = UseReturnTrue // default use function

		waitFlags = {}

		nextThinkGuid = 0
		freeThinkGuids = []
		thinkContexts = {}
		funcsByString = {}
	}
}
else
{
	function CBaseEntity::constructor()
	{
		this.s = {}
		this.kv = KeyValueInterface( this.weakref() )
		this.nv = NetworkValueInterface( this.weakref() )

		this.useFunction = UseReturnTrue // default use function

		waitFlags = {}

		nextThinkGuid = 0
		freeThinkGuids = []
		thinkContexts = {}
		funcsByString = {}
	}
}

__scriptVarDelegate <- {}
function __scriptVarDelegate::_overwriteslot( key, value )
{
	Assert( 0, "Attempted to overwrite slot \"" + key + "\" in .s table.  See callstack for further info.\n" )
}

function __scriptVarDelegate::_typeof()
{
	return "ScriptVariableTable"
}

/*
Do not delete, thanks.

CBaseEntity.__SetOrigin <- CBaseEntity.SetOrigin
function CBaseEntity::SetOrigin( origin )
{
	if ( this.GetName() == "xauto_1" )
	{
		printl( "\n\n" )
		DumpStack()
	}
	this.__SetOrigin( origin )
}
*/

function CBaseEntity::AddOrigin( origin )
{
	this.SetOrigin( this.GetOrigin() + origin )
}


// --------------------------------------------------------
// We can't validate our script scope in the constructor, so we override the one functions that need it:
// ConnectOutput and GetScriptScope
// --------------------------------------------------------
CBaseEntity.__ConnectOutput <- CBaseEntity.ConnectOutput
function CBaseEntity::ConnectOutput( outputName, func )
{
	this.ValidateScriptScope()

	if ( type( func ) == "string" )
	{
		this.__ConnectOutput( outputName, func )
		return
	}

	local funcInfos = func.getinfos()
	local funcName = funcInfos.name

	Assert( funcInfos.parameters.len() == 5, "ConnectOutput function \"" + funcName +"\" must have exactly 4 parameters (self, activator, caller, value)." )

	if ( IsFuncGlobal( func ) )
	{
		this.scope()[funcName + "_wrapper"] <- function():(funcName)
		{
			thread (getroottable()[funcName])( self, activator, caller, this.rawin( "value" ) ? value : null )
		}
		this.__ConnectOutput( outputName, funcName + "_wrapper" )
		return
	}

	local foundCount = 0;
	foreach ( scopeName, fileScope in __fileScopes )
	{
		if ( !(fileScope.rawin( funcName )) )
			continue

		if ( fileScope[funcName] != func )
			continue

		Assert( !foundCount, "Function " + funcName + " found in more than one filescope!" )
		foundCount++

		this.scope()[scopeName + "_" + funcName] <- function():(fileScope, funcName)
		{
			thread fileScope[funcName]( self, activator, caller, ("value" in this) ? value : null )
		}
		this.__ConnectOutput( outputName, scopeName + "_" + funcName )
		return
	}

	Assert( 0, "Unable to ConnectOutput for " + funcName )
}

CBaseEntity.__DisconnectOutput <- CBaseEntity.DisconnectOutput
function CBaseEntity::DisconnectOutput( outputName, func )
{
	if ( type( func ) == "string" )
	{
		this.__DisconnectOutput( outputName, func )
		return
	}

	local funcInfos = func.getinfos()
	local funcName = funcInfos.name

	if ( IsFuncGlobal( func ) )
	{
		delete this.scope()[funcName + "_wrapper"]
		this.__DisconnectOutput( outputName, funcName + "_wrapper" )
		return
	}

	local foundCount = 0;
	foreach ( scopeName, fileScope in __fileScopes )
	{
		if ( !(fileScope.rawin( funcName )) )
			continue

		if ( fileScope[funcName] != func )
			continue

		Assert( !foundCount, "Function " + funcName + " found in more than one filescope!" )
		foundCount++

		delete this.scope()[scopeName + "_" + funcName]
		this.__DisconnectOutput( outputName, scopeName + "_" + funcName )
		return
	}

	Assert( 0, "Unable to DisconnectOutput for " + funcName )
}






CBaseEntity.__GetScriptScope <- CBaseEntity.GetScriptScope
function CBaseEntity::GetScriptScope()
{
	this.ValidateScriptScope()
	return this.__GetScriptScope()
}

function CBaseEntity::_typeof()
{
	return format( "[%d] %s: %s", this.entindex(), this.GetClassname(), this.GetName() )
}

function CBaseEntity::scope()
{
	this.ValidateScriptScope()
	return this.__GetScriptScope()
}

function CBaseEntity::GetTarget()
{
	return this.GetValueForKey( "target" )
}

function CBaseEntity::Get( val )
{
	return this.GetValueForKey( val )
}

function CBaseEntity::Set( key, val )
{
	return this.SetValueForKey( key, val )
}

function CBaseEntity::WaitSignal( signalID )
{
	return ::WaitSignal( this, signalID )
}

function CBaseEntity::EndSignal( signalID )
{
	::EndSignal( this, signalID )
}

function CBaseEntity::Signal( signalID, results = null )
{
	::Signal( this, signalID, results )
}

function CBaseEntity::DisableDraw()
{
	this.FireNow( "DisableDraw" )
}
RegisterClassFunctionDesc( CBaseEntity, "DisableDraw", "consider this the mega hide" )

function CBaseEntity::EnableDraw()
{
	this.FireNow( "EnableDraw" )
}
RegisterClassFunctionDesc( CBaseEntity, "EnableDraw", "its back!" )

function CBaseEntity::Hide()
{
	//this.FireNow( "DisableDraw" )
	this.kv.disableshadows = 1
	this.kv.rendermode = 5
	this.kv.renderamt = 0
}
RegisterClassFunctionDesc( CBaseEntity, "Hide", "Hide the entity by changing its KV pairs" )

function CBaseEntity::Show()
{
//	this.FireNow( "EnableDraw" )
	this.kv.disableshadows = 0
	this.kv.rendermode = 0
	this.kv.renderamt = 255
}
RegisterClassFunctionDesc( CBaseEntity, "Show", "Show the entity by changing its KV pairs" )




// --------------------------------------------------------
function CBaseEntity::SetParentAttachment( attachmentName, maintainOffset = false )
{
	if ( maintainOffset )
		EntFireByHandle( this, "SetParentAttachmentMaintainOffset", attachmentName, 0, null, null )
	else
		EntFireByHandle( this, "SetParentAttachment", attachmentName, 0, null, null )
}
RegisterClassFunctionDesc( CBaseEntity, "SetParentAttachment", "Attachment name, optional maintainOffset." )

// --------------------------------------------------------
function CBaseEntity::SetParentAttachmentMaintainOffset( attachmentName )
{
	EntFireByHandle( this, "SetParentAttachmentMaintainOffset", attachmentName, 0, null, null )
}
RegisterClassFunctionDesc( CBaseEntity, "SetParentAttachment", "Attachment name, optional maintainOffset." )


// --------------------------------------------------------
function CBaseEntity::SetName( name )
{
	local oldName = this.GetName()
	if ( oldName != "" )
	{
		if ( name in level._nameList )
		{
			ArrayRemove( level._nameList[ name ], this )
		}
	}

	AddToNameList( this, name )
	this.SetValueForKey( "targetname", name )
}
RegisterClassFunctionDesc( CBaseEntity, "SetName", "Sets the name (targetname) of this entity" )


// --------------------------------------------------------
function CBaseEntity::Kill( time = 0 )
{
	// trying to provide a hint to a rare script error
	local classname = this.GetClassname()
	switch ( classname )
	{
		case "script_ref":
		case "script_mover":
			printtodiag( "(:Kill Debug) " + GetPreviousFunction() + "\n" )
	}

	EntFireByHandle( this, "kill", "", time, null, null )
}
RegisterClassFunctionDesc( CBaseEntity, "Kill", "Kill this entity" )

// --------------------------------------------------------
function CBaseEntity::Fire( output, param = "", delay = 0, activator = null, caller = null )
{
	Assert( type( output ) == "string", "output type " + type( output ) + " is not a string" )
	EntFireByHandle( this, output, param.tostring(), delay, activator, caller )
}
RegisterClassFunctionDesc( CBaseEntity, "Fire", "Fire an output on this entity, with optional parm and delay" )

function CBaseEntity::FireNow( output, param = "", activator = null, caller = null )
{
	Assert( type( output ) == "string" )
	EntFireByHandleNow( this, output, param.tostring(), activator, caller )
}
RegisterClassFunctionDesc( CBaseEntity, "FireNow", "Fire an output on this entity, with optional parm and delay (synchronous)" )

// --------------------------------------------------------
// function SetParent()
function CBaseEntity::SetParent( parentEnt, attachment = "", maintainOffset = null, blendTime = 0 )
{
	if ( type( parentEnt ) == "string" )
		parentEnt = Entities.FindByName( null, parentEnt )

	if ( maintainOffset == null )
		maintainOffset = ((attachment == "") || (attachment == 0))
	this.SetParentRaw( parentEnt, maintainOffset, blendTime, false, attachment, 0 );
}
RegisterClassFunctionDesc( CBaseEntity, "SetParent", "Sets the movement parent of this entity. \"parentEnt\" can be a name or an entity." )

function CBaseEntity::SetParentWithHitbox( parentEnt, hitboxIdx, maintainOffset = null, blendTime = 0 )
{
	if ( type( parentEnt ) == "string" )
		parentEnt = Entities.FindByName( null, parentEnt )

	if ( maintainOffset == null )
		maintainOffset = (hitboxIdx == 0)
	this.SetParentRaw( parentEnt, maintainOffset, blendTime, true, "", hitboxIdx );
}
RegisterClassFunctionDesc( CBaseEntity, "SetParentWithHitbox", "Sets the movement parent of this entity, using a hitbox as the attach base. \"parentEnt\" can be a name or an entity." )

// --------------------------------------------------------
function CBaseEntity::OnBranch( branch, func )
{
	local ent = GetEnt( branch )
	Assert( ent != null, "Couldn't find logic_branch with name " + branch )
	Assert( ent.GetClassname() == "logic_branch", "Expected logic_branch but found " + ent.GetClassname() )

	printl( "Added onbranch to " + this + " for branch " + branch + " to run func " + func )
	ent.ConnectOutputTarget( "OnTrue", func, this )

}
RegisterClassFunctionDesc( CBaseEntity, "OnBranch", "Sets a function to run on this entity when the specified branch is set." )


// --------------------------------------------------------
function CBaseEntity::DisconnectBranch( branch, func )
{
	local ent = GetEnt( branch )
	Assert( ent != null, "Couldn't find logic_branch with name " + branch )
	Assert( ent.GetClassname() == "logic_branch", "Expected logic_branch but found " + ent.GetClassname() )

	local scope = ent.GetScriptScope()
	if ( func in scope )
		delete scope[func]
	ent.DisconnectOutput( "OnTrue", func )

}
RegisterClassFunctionDesc( CBaseEntity, "OnBranch", "Sets a function to run on this entity when the specified branch is set." )


function CBaseEntity::OnBranchFalse( branch, func )
{
	local ent = GetEnt( branch )
	Assert( ent != null, "Couldn't find logic_branch with name " + branch )
	Assert( ent.GetClassname() == "logic_branch", "Expected logic_branch but found " + ent.GetClassname() )

	printl( "Added onbranch to " + this + " for branch " + branch + " to run func " + func )
	ent.ConnectOutputTarget( "OnFalse", func, this )

}
RegisterClassFunctionDesc( CBaseEntity, "OnBranchFalse", "Sets a function to run on this entity when the specified branch is cleared." )


function CBaseEntity::DisconnectBranchFalse( branch, func )
{
	local ent = GetEnt( branch )
	Assert( ent != null, "Couldn't find logic_branch with name " + branch )
	Assert( ent.GetClassname() == "logic_branch", "Expected logic_branch but found " + ent.GetClassname() )

	ent.DisconnectOutput( "OnFalse", func )
	local scope = ent.GetScriptScope()
	if ( func in scope )
		delete scope[func]

}
RegisterClassFunctionDesc( CBaseEntity, "OnBranchFalse", "Sets a function to run on this entity when the specified branch is cleared." )


// --------------------------------------------------------
function CBaseEntity::AddOutput( outputName, target, inputName, parameter = "", delay = 0, maxFires = 0 )
{
	local targetName = target

	if ( type( target ) != "string" )
	{
		Assert( type( target ) == "instance" )
		targetName = target.GetName()
		Assert( targetName.len(), "AddOutput: targetted entity must have a name!" )
	}
	Assert( targetName.len(), "Attemped to AddOutput on an unnamed target" )

	local addOutputString = outputName + " " + targetName + ":" + inputName + ":" + parameter + ":" + delay + ":" + maxFires
	//printl(" Added output string: " + addOutputString )

	EntFireByHandle( this, "AddOutput", addOutputString, 0, null, null )
}
RegisterClassFunctionDesc( CBaseEntity, "AddOutput", "Connects an output on this entity to an input on another entity via code.  The \"target\" can be a name or a named entity." )

// --------------------------------------------------------
function CBaseEntity::ConnectOutputTarget( outputName, functionName, target, skipcheck = false )
{
	if ( type( target ) == "string" )
		target = Entities.FindByName( null, target )

	Assert( target != null, "ConnectOutput: could not find target entity" )

	this.ValidateScriptScope()
	local scope = this.GetScriptScope()

	target.ValidateScriptScope()
	local targetScope = target.GetScriptScope()

	Assert( targetScope.rawin( functionName ), "ConnectOutput: target entity's scope does not contain function " + functionName )

	if ( !skipcheck )
		Assert( !(scope.rawin( functionName )), "ConnectOutput: entity " + this + " scope already contains function " + functionName )

	scope[functionName] <- targetScope[functionName].bindenv( targetScope )

	this.ConnectOutput( outputName, functionName )
}
RegisterClassFunctionDesc( CBaseEntity, "ConnectOutputTarget", "Connects an output on this entity to a script function on another entity.  The \"target\" can be a name or an entity." )


// --------------------------------------------------------
// Adds an output that tells this entity to run the specified scritpt code
// --------------------------------------------------------
function CBaseEntity::LinkOutputTarget( outputName, functionName, target )
{
	if ( functionName.find( "(" ) == null )
		functionName += "()"

	this.AddOutput( outputName, target, "RunScriptCode", functionName )
}

function orgdebug()
{
	self.SetNextThink( orgdebug, 0.05 )

	local origin = self.GetOrigin()
	DebugDrawBox( origin, Vector(-8,-8,-8), Vector(8,8,8), 255, 0, 0, 1, 0.1 )
	local forward = self.GetForwardVector()
	local right = self.GetRightVector()
	local up = self.GetUpVector()

	DebugDrawLine( origin, origin + forward * 25, 255, 100, 100, false, 0.1 )
	DebugDrawLine( origin, origin + up * 25, 100, 255, 100, false, 0.1 )
	DebugDrawLine( origin, origin + right * 25, 100, 100, 255, false, 0.1 )
}

function CBaseEntity::OrgPrint()
{
	this.SetNextThink( orgdebug, 0.1 )
}
RegisterClassFunctionDesc( CBaseEntity, "OrgPrint", "Sets a function to run on this entity when the specified branch is cleared." )

/*
function CanSee()
*/
function CBaseEntity::CanSee( entity )
{
	if ( !entity.IsDraw() )
		return false

	local traceOrigin = this.GetCenter()
	if ( this.GetClassname() == "player" )
	{
		traceOrigin = this.EyePosition()
	}
	else
	{
		local eyeIndex = this.LookupAttachment( "eyes" )
		if ( eyeIndex )
			traceOrigin = this.GetAttachmentOrigin( eyeIndex )
	}

	local entityCenter = entity.GetCenter()
	local trace = TraceLineSimple( traceOrigin, entityCenter, entity )
	if ( trace == 1 )
		return true

	// trying to be quick not accurate
	local boundingMaxs = entity.GetBoundingMaxs()
	local boundingMins = entity.GetBoundingMins()
	local height = boundingMaxs.z + boundingMins.z
	boundingMaxs = Vector( boundingMaxs.x, boundingMaxs.y, 0 )
	boundingMins = Vector( boundingMins.x, boundingMins.y, 0 )
	local width = ( boundingMaxs.Norm() + boundingMins.Norm() ) / 2
	width *= 0.6	// this fraction seems to work well to get a close enough trace

	local vector = this.GetRightVector()

	local entityOrigin = entity.GetOrigin()
	local originArray = []

	// top center
	originArray.append( entityOrigin + Vector( 0, 0, height ) )
	// center right
	originArray.append( entityCenter + vector * width )
	// center left
	originArray.append( entityCenter + vector * width * -1 )
	// bottom center
	originArray.append( entityOrigin )

	foreach( origin in originArray )
	{
		trace = TraceLineSimple( traceOrigin, origin, entity )
		if ( trace == 1 )
			return true
	}

	return false
}
RegisterClassFunctionDesc( CBaseEntity, "CanSee", "Returns true if this entity can see the passed entity" )


function CBaseEntity::IsMarvin()
{
	if ( !this.IsNPC() )
		return false

	return this.GetBodyType() == "marvin"
}
RegisterClassFunctionDesc( CBaseEntity, "IsMarvin", "Is this a marvin?" )

function CBaseEntity::IsSpectre()
{
	return this.IsNPC() && this.GetAIClass() == "spectre"
}
RegisterClassFunctionDesc( CBaseEntity, "IsSpectre", "Is this a Spectre?" )


function CBaseEntity::IsNPCTitan()
{
	return this.IsNPC() && this.IsTitan()
}


function CBaseEntity::IsDropship()
{
	//Probably should not use GetClassname, but npc_dropship isn't a class so can't use instanceof?
	return this.IsNPC() && this.GetClassname() == "npc_dropship"
}
RegisterClassFunctionDesc( CBaseEntity, "IsDropship", "Is this a Dropship?" )

function CBaseEntity::IsTurret()
{
	return ::IsTurret( this )
}
RegisterClassFunctionDesc( CBaseEntity, "IsTurret", "Is this a Turret?" )

function CBaseEntity::IsMegaTurret()
{
	return this.IsNPC() && this.GetClassname() == "npc_turret_mega"
}
RegisterClassFunctionDesc( CBaseEntity, "IsMegaTurret", "Is this a MegaTurret?" )


function CBaseEntity::IsHumanSized()
{
	if ( this.IsPlayer() )
	{
		return this.IsHuman()
	}

	if ( this.IsNPC() )
	{
		local bodyType = this.GetBodyType()
		return bodyType == "human" || bodyType == "marvin"
	}

	return false
}
RegisterClassFunctionDesc( CBaseEntity, "IsHumanSized", "Is this a human sized character?" )

function CBaseEntity::IsSoldier()
{
	if ( !this.IsNPC() )
		return false

	return this.GetClassname() == "npc_soldier"
}
RegisterClassFunctionDesc( CBaseEntity, "IsSoldier", "Is this an npc_soldier?" )


// --------------------------------------------------------
function CBaseEntity::SetNextThink( newThink = null, thinkDelay = 0.0 )
{
	this.ValidateScriptScope()
	if ( newThink != null )
	{
		Assert( type( newThink ) == "function" )

		local newGuid = UniqueString()
		thinkGuid = UniqueString() + "think"
		thinkFunc = newThink

		EntFireByHandle( this, "RunScriptCode", "_RunThink( \"" + thinkGuid + "\" )", thinkDelay, this, this )
	}
	else
	{
		thinkGuid = ""
		thinkFunc = null
	}
}
RegisterClassFunctionDesc( CBaseEntity, "SetNextThink", "Sets and then calls this entities next think function with an optional delay." )


function CBaseEntity::RegisterThinkContext( contextName )
{
	Assert( !(contextName in thinkContexts), "Think context " + contextName + " already registered!" )
	thinkContexts[contextName] <- null
}

function _GetContextThinkGuid()
{
	if ( !this.freeThinkGuids.len() )
		return this.nextThinkGuid++

	return this.freeThinkGuids.remove( 0 )
}

function CBaseEntity::SetContextThink( thinkFunc, nextThinkTime, contextName )
{
	Assert( (contextName in thinkContexts), "Entity " + GetName() + " does not contain think context " + contextName )

	local contextThinkGuid = _GetContextThinkGuid()

	thinkContexts[contextName] = { func = thinkFunc, guid = contextThinkGuid }

	EntFireByHandle( this, "RunScriptCode", "_RunContextThink( \"" + contextName + "\", " + contextThinkGuid + " )", nextThinkTime, this, this )
}

function _RunContextThink( contextName, thinkGuid )
{
	// in some cases this function can be called on an entity that has been removed by code
	if ( !IsValid_ThisFrame( activator ) )
		return

	activator.freeThinkGuids.append( thinkGuid )

	if ( !activator.thinkContexts[contextName] )
		return

	if ( activator.thinkContexts[contextName].guid != thinkGuid )
		return

	activator.thinkContexts[contextName].func.call( activator.GetScriptScope() )
}


/*
function MoveTo()
*/

function CBaseEntity::MoveTo( dest, time, easeIn = 0, easeOut = 0 )
{
	if ( this.GetClassname() == "script_mover" )
	{
		Assert( this.kv.SpawnAsPhysicsMover == "0", "Physics script mover tried to do non physics move" )
		this.NonPhysicsMoveTo( dest, time, easeIn, easeOut)
		return
	}

	thread CBaseEntityMoverMoveToThread( this, dest, time, easeIn, easeOut )
}
RegisterClassFunctionDesc( CBaseEntity, "MoveTo", "Move to the specified origin over time with ease in and ease out." )


/*
function RotateTo()
*/

function CBaseEntity::RotateTo( dest, time, easeIn = 0, easeOut = 0 )
{
	if ( this.GetClassname() == "script_mover" )
	{
		Assert( this.kv.SpawnAsPhysicsMover == "0", "Physics script mover tried to do non physics move" )
		this.NonPhysicsRotateTo( dest, time, easeIn, easeOut)
		return
	}

	thread CBaseEntityRotateToThread( this, dest, time, easeIn, easeOut )
}
RegisterClassFunctionDesc( CBaseEntity, "RotateTo", "Rotate to the specified angles over time with ease in and ease out." )


/*
function ParentToMover()
*/
function CBaseEntity::ParentToMover()
{
	Assert( this.GetClassname() != "script_mover", "Tried to parent to mover a script mover!" )

	this.ClearParent()
	this.s._internalMover <- CreateScriptMover( this )
	this.s.moverCommandCount <- 0
	this.SetParent( this.s._internalMover, "", false )
}
RegisterClassFunctionDesc( CBaseEntity, "MoveTo", "Move to the specified origin over time with ease in and ease out." )

CBaseEntity.__ClearParent <- CBaseEntity.ClearParent
function CBaseEntity::ClearParent()
{
	if ( "_internalMover" in this.s )
	{
		// create the mover
		CBaseEntityCleanupMover( this )
	}

	this.__ClearParent()
}

function CBaseEntityCleanupMover( self )
{
	Assert( "_internalMover" in self.s, "No mover for " + self )

	local mover = self.s._internalMover
	if ( !IsValid_ThisFrame( self ) )
	{
		if ( IsValid_ThisFrame( mover ) )
			mover.Kill()
		return
	}

	// if not, then clean it up

	// if we have changed our parent since the moveto, then a bug will occur.
	// If we had a GetParent() this could be fixed, but really, ents should
	// not auto delete their children.
	delete self.s._internalMover
	delete self.s.moverCommandCount

	self.ClearParent()
	mover.Kill()
}

function CBaseEntityMoverMoveToThread( self, dest, time, easeIn = 0, easeOut = 0 )
{
	if ( !( "_internalMover" in self.s ) )
	{
		// create the mover
		self.ParentToMover()
	}

	Assert( IsValid_ThisFrame( self.s._internalMover ), self + "'s mover " + self.s._internalMover + " is no longer valid." )

	self.s.moverCommandCount++
	local mover = self.s._internalMover

	OnThreadEnd(
		function() : ( self )
		{
			if ( !( "_internalMover" in self.s ) )
				return

			// this mover command is done
			self.s.moverCommandCount--

			// are other mover commands still active?
			if ( self.s.moverCommandCount )
				return

			// create the mover
			CBaseEntityCleanupMover( self )
		}
	)

	self.s._internalMover.NonPhysicsMoveTo( dest, time, easeIn, easeOut)
	wait time
}

function CBaseEntityRotateToThread( self, dest, time, easeIn = 0, easeOut = 0 )
{
	if ( !( "_internalMover" in self.s ) )
	{
		// create the mover
		self.ParentToMover()
	}

	Assert( IsValid_ThisFrame( self.s._internalMover ), self + "'s mover " + self.s._internalMover + " is no longer valid." )

	self.s.moverCommandCount++
	local mover = self.s._internalMover

	OnThreadEnd(
		function() : ( self )
		{
			if ( !( "_internalMover" in self.s ) )
				return

			// this mover command is done
			self.s.moverCommandCount--

			// are other mover commands still active?
			if ( self.s.moverCommandCount )
				return

			// create the mover
			CBaseEntityCleanupMover( self )
		}
	)

	self.s._internalMover.NonPhysicsRotateTo( dest, time, easeIn, easeOut)
	wait time
}


/*
	//thread this.MoveToThread( dest, time, easeIn, easeOut )
function CBaseEntity::MoveToThread( dest, time, easeIn = 0, easeOut = 0 )
{
	this.Signal( "new_move_to" )
	this.EndSignal( "new_move_to" )

	local start = this.GetOrigin()
	local startTime = Time()
	local endTime = startTime + time
	local org
	local dif

	for ( ;; )
	{
		if ( Time() > endTime )
			break

		dif = Interpolate( startTime, time, easeIn, easeOut )
		//printl( "Dif " + dif )
		//dif = Graph( Time(), startTime, 1, endTime, 0 )
		org = start * ( 1 - dif ) + dest * dif
		this.SetOrigin( org )
		wait 0
	}

	this.SetOrigin( dest )
}
*/

function CBaseEntity::AddVar( varname, value )
{
	Assert( !( varname in this.s ), "Tried to add variable to " + this + " that already existed: " + varname )

	this.s[ varname ] <- value
}

function CBaseEntity::CallDelayed( func, delay )
{
	this.ValidateScriptScope()
	EntFireByHandle( this, "RunScriptCode", CreateStringForFunction( func ), delay, this, this )
}
RegisterClassFunctionDesc( CBaseEntity, "CallDelayed", "Calls the given function after the given delay." )

function CBaseEntity::CreateStringForFunction( func )
{
	// this is a general purpose function that returns a string which, when executed,
	// runs the given function on this entity.
	// the function must be called (or the entity deleted) at some point to avoid leaking the new slot we make in this table.

	Assert( type( func ) == "function" )

	local newGuid = UniqueString()
	funcsByString[newGuid] <- func

	return "_RunFunctionByString( \"" + newGuid + "\" )"
}

function _RunFunctionByString( guid )
{
	Assert( activator.funcsByString[guid] )

	local func = activator.funcsByString[guid].bindenv( activator.scope() )
	delete activator.funcsByString[guid]

	func()
}

function CBaseEntity::SetDamageNotifications( state )
{
	this.kv.damageNotifications = state
}

function CBaseEntity::SetDeathNotifications( state )
{
	this.kv.deathNotifications = state
}

function CBaseEntity::InitFlag( signalID, initialValue = false )
{
	Assert( !(signalID in this.waitFlags) )
	RegisterSignal( signalID )

	this.waitFlags[signalID] <- initialValue
}

function CBaseEntity::WaitFlag( signalID )
{
	// Note: waitflags[signalID] is set to true by code in API_Signal.
	if ( !this.waitFlags[signalID] )
		return ::WaitSignal( this, signalID )

	return
}

function CBaseEntity::IsFlagSet( signalID )
{
	return this.waitFlags[signalID]
}

function CBaseEntity::ClearFlag( signalID )
{
	this.waitFlags[signalID] = false
}

function CBaseEntity::SetFlag( signalID )
{
	::Signal( this, signalID )
}

CBaseEntity.__Die <- CBaseEntity.Die
function CBaseEntity::Die( guy1 = null, guy2 = null, table = null )
{
	if ( guy1 == null )
		guy1 == this
	if ( guy2 == null )
		guy2 == this
	if ( table == null )
		table = {}
	this.__Die( guy1, guy2, table )
}
