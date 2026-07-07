//=========================================================
// C_BaseEntity
// Properties and methods added here can be accessed on all script entities
//=========================================================
printl( "Class Script: C_BaseEntity" )

C_BaseEntity.ClassName <- "C_BaseEntity"

// Script variables; initializing these to something other than "null" will cause them to be treated as a
// static variable on the class instead of a unique variable on each instance.
C_BaseEntity.s <- null
C_BaseEntity.kv <- null
C_BaseEntity.nv <- null
C_BaseEntity.hudElems <- null
C_BaseEntity.hudVisible <- null

C_BaseEntity.useFunction <- null // should match on server/client
C_BaseEntity._entityVars <- null

// Allow kill replays again
C_BaseEntity.connectTime <- null
C_BaseEntity.hasSpawned <- true
C_BaseEntity.firstSpawnTime <- null

function C_BaseEntity::constructor()
{
	this.s = {}
	this.kv = delegate __keyValueDelegate : { self = this.weakref() }
	this.hudElems = {}
	this.hudVisible = false

	this.useFunction = UseReturnTrue // default use function

	this.nv = NetworkValueInterface( this.weakref() )
}

__keyValueDelegate <- delegate getroottable() : {}
function __keyValueDelegate::_get( key )
{
	return self.GetValueForKey( key )
}

function __keyValueDelegate::_set( key, value )
{
	self.SetValueForKey( key, value )
}

function __keyValueDelegate::_newslot( key, value )
{
	printl( "\n  WARNING: attempted to create new slot \"" + key + "\" in instance key/value table.  This is not allowed.\n" )
	return false
}

function C_BaseEntity::Get( val )
{
	return this.GetValueForKey( val )
}

function C_BaseEntity::Set( key, val )
{
	return this.SetValueForKey( key, val )
}

C_BaseEntity.__GetScriptScope <- C_BaseEntity.GetScriptScope
function C_BaseEntity::GetScriptScope()
{
	this.ValidateScriptScope()
	return this.__GetScriptScope()
}

function C_BaseEntity::InitHudElem( name )
{
	this.hudElems[name] <- HudElement( name )
	if ( IsMultiplayer() )
	{

		this.hudElems[name].SetVisGroupID( 0 )
	}

	return this.hudElems[name]
}

function C_BaseEntity::InitHudElemGroup( name )
{
	this.hudElems[name] <- HudElementGroup( name )
	if ( IsMultiplayer() )
	{
		this.hudElems[name].SetVisGroupID( 0 )
	}

	return this.hudElems[name]
}

function C_BaseEntity::IsSoldier()
{
	if ( !this.IsNPC() )
		return false

	return this.GetSignifierName() == "npc_soldier"
}
RegisterClassFunctionDesc( C_BaseEntity, "IsSoldier", "Is this an npc_soldier?" )

function C_BaseEntity::ShowHUD()
{
	if ( this.hudVisible )
		return

	this.hudVisible = true

	level.menuVisGroup.Show()

	foreach ( element in this.hudElems )
		element.UpdateVisibility()
}

function C_BaseEntity::HideHUD()
{
	if ( !this.hudVisible )
		return

	this.hudVisible = false

	level.menuVisGroup.Hide()

	foreach ( element in this.hudElems )
		element.UpdateVisibility()
}

function C_BaseEntity::IsHUDVisible()
{
	return this.hudVisible
}

function C_BaseEntity::WaitSignal( signalID )
{
	return ::WaitSignal( this, signalID )
}

function C_BaseEntity::EndSignal( signalID )
{
	::EndSignal( this, signalID )
}

function C_BaseEntity::Signal( signalID, results = null )
{
	::Signal( this, signalID, results )
}


function C_BaseEntity::IsHumanSized()
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
RegisterClassFunctionDesc( C_BaseEntity, "IsHumanSized", "Is this a human sized character?" )

function C_BaseEntity::IsDropship()
{
	if ( !this.IsNPC() )
		return false
	//Probably should not use GetClassname, but npc_dropship isn't a class so can't use instanceof?
	return ( this.GetClassname() == "npc_dropship" || this.GetSignifierName() == "npc_dropship" )
}
RegisterClassFunctionDesc( C_BaseEntity, "IsDropship", "Is this a Dropship?" )


function C_BaseEntity::IsTurret()
{
	return ::IsTurret( this )
}
RegisterClassFunctionDesc( C_BaseEntity, "IsTurret", "Is this a Turret?" )

function C_BaseEntity::IsMarvin()
{
	return this.IsNPC() && this.GetAIClass() == "marvin"
}
RegisterClassFunctionDesc( C_BaseEntity, "IsMarvin", "Is this a marvin?" )

function C_BaseEntity::IsSpectre()
{
	return this.IsNPC() && this.GetAIClass() == "spectre"
}
RegisterClassFunctionDesc( C_BaseEntity, "IsSpectre", "Is this a Spectre?" )

function C_BaseEntity::IsMegaTurret()
{
	return this.IsNPC() && this.GetClassname() == "npc_turret_mega"
}
RegisterClassFunctionDesc( C_BaseEntity, "IsMegaTurret", "Is this a MegaTurret?" )

function C_BaseEntity::SetParent( parentEnt, attachment = "", maintainOffset = null, blendTime = 0 )
{
	if ( type( parentEnt ) == "string" )
		parentEnt = Entities.FindByName( null, parentEnt )

	// blendTime is not currently supported by client script in code:
	blendTime = 0
	if ( maintainOffset == null )
		maintainOffset = ((attachment == "") || (attachment == 0))
	this.SetParentRaw( parentEnt, maintainOffset, blendTime, false, attachment, 0 );

	if ( !( "s" in this ) )
		this.s <- {}
	if ( !( "parentEnt" in this.s ) )
		this.s.parentEnt <- null

	this.s.parentEnt = parentEnt.weakref()
}
RegisterClassFunctionDesc( C_BaseEntity, "SetParent", "Sets the movement parent of this entity. \"parentEnt\" can be a name or an entity." )


function C_BaseEntity::SetParentWithHitbox( parentEnt, hitboxIdx, maintainOffset = null, blendTime = 0 )
{
	if ( type( parentEnt ) == "string" )
		parentEnt = Entities.FindByName( null, parentEnt )

	// blendTime is not currently supported by client script in code:
	blendTime = 0
	if ( maintainOffset == null )
		maintainOffset = (hitboxIdx == 0)
	this.SetParentRaw( parentEnt, maintainOffset, blendTime, true, "", hitboxIdx );

	if ( !( "s" in this ) )
		this.s <- {}
	if ( !( "parentEnt" in this.s ) )
		this.s.parentEnt <- null

	this.s.parentEnt = parentEnt.weakref()
}
RegisterClassFunctionDesc( C_BaseEntity, "SetParentWithHitbox", "Sets the movement parent of this entity, using a hitbox as the attach base. \"parentEnt\" can be a name or an entity." )

function C_BaseEntity::IsGrenade()
{
	switch( this.GetClassname() )
	{
		case "grenade":
		case "npc_grenade_frag":
		case "magnetic_grenade":
			return true
		default:
			return false
	}
}
RegisterClassFunctionDesc( C_BaseEntity, "IsGrenade", "Is this a grenade?" )

function C_BaseEntity::Hide()
{
	this.SetInvisibleForLocalPlayer( 0 )
}
RegisterClassFunctionDesc( C_BaseEntity, "Hide", "Hide the entity by calling SetInvisibleForLocalPlayer( 0 ).  This will also hide any attached particles.  Use DisableDraw if you just want the model hidden." )

function C_BaseEntity::Show()
{
	this.SetVisibleForLocalPlayer( 0 )
}
RegisterClassFunctionDesc( C_BaseEntity, "Show", "Show the entity by calling SetVisibleForLocalPlayer( 0 )" )

function C_BaseEntity::clHide()
{
	this.SetInvisibleForLocalPlayer( 0 )
}
RegisterClassFunctionDesc( C_BaseEntity, "clHide", "Hide the entity by calling SetInvisibleForLocalPlayer( 0 ).  This will also hide any attached particles.  Use DisableDraw if you just want the model hidden." )

function C_BaseEntity::clShow()
{
	this.SetVisibleForLocalPlayer( 0 )
}
RegisterClassFunctionDesc( C_BaseEntity, "clShow", "Show the entity by calling SetVisibleForLocalPlayer( 0 )" )

function C_BaseEntity::clGetParent()
{
	if ( !( "s" in this ) )
		return null
	if ( "parentEnt" in this.s )
		return this.s.parentEnt

	return null
}
RegisterClassFunctionDesc( C_BaseEntity, "clGetParent", "Returns the entity's parent if there is one. Returns null if not" )

function C_BaseEntity::clClearParent()
{
	//this.ClearParent() --> No clear parent on client!

	if ( !( "s" in this ) )
		return
	if ( "parentEnt" in this.s )
		this.s.parentEnt = null
}
RegisterClassFunctionDesc( C_BaseEntity, "clClearParent", "Clear this entity's parent" )

function C_BaseEntity::clWaittillAnimDone()
{
	waitthread C_BaseEntityWaittillAnimDone( this )
}
RegisterClassFunctionDesc( C_BaseEntity, "clWaittillAnimDone", "Wait until an animation notifies OnAnimationDone or OnAnimationInterrupted" )

function C_BaseEntityWaittillAnimDone( self )
{
	if ( self.IsPlayer() )
		self.EndSignal( "Disconnected" )

	self.EndSignal( "OnAnimationInterrupted" )
	self.WaitSignal( "OnAnimationDone" )
}

function C_BaseEntity::clKill()
{
	this.Destroy()
}
RegisterClassFunctionDesc( C_BaseEntity, "clKill", "Kill this entity" )

// why clKill instead of Kill?

function C_BaseEntity::Kill()
{
	this.Destroy()
}
RegisterClassFunctionDesc( C_BaseEntity, "Kill", "Kill this entity" )
