
function CBaseCombatCharacter::SetIgnoreMe()
{
	if ( "ignoreme" in this.s )
	{
		Assert( this.s.ignoreme, "Do not set .s.ignoreme directly." )
		return
	}
	this.s.ignoreme <- true
	UpdateAllRelationships()
}
RegisterClassFunctionDesc( CBaseCombatCharacter, "SetIgnoreMe", "NPCs do not attack this." )

function CBaseCombatCharacter::ClearIgnoreMe()
{
	if ( !( "ignoreme" in this.s ) )
		return

	Assert( this.s.ignoreme, "Do not set .s.ignoreme directly." )
	delete this.s.ignoreme
	UpdateAllRelationships()
}
RegisterClassFunctionDesc( CBaseCombatCharacter, "ClearIgnoreMe", "NPCs may now attack this if they do not like it." )

RegisterSignal( "ContextAction_SetBusy" )
CBaseCombatCharacter.__ContextAction_SetBusy <- CBaseCombatCharacter.ContextAction_SetBusy
function CBaseCombatCharacter::ContextAction_SetBusy()
{
	this.Signal( "ContextAction_SetBusy" )
	this.__ContextAction_SetBusy()
}


/*
CBaseCombatCharacter.__SetActiveWeapon <- CBaseCombatCharacter.SetActiveWeapon
function CBaseCombatCharacter::SetActiveWeapon( weapon )
{
	printt( "set active weapon " + weapon + " for " + this )
	return this.__SetActiveWeapon( weapon )
}

CBaseCombatCharacter.__TakeWeapon <- CBaseCombatCharacter.TakeWeapon
function CBaseCombatCharacter::TakeWeapon( weapon )
{
//	printt( "Take weapon " + weapon + " from " + this )
	return this.__TakeWeapon( weapon )
}

*/
