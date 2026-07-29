printl( "Class Script: CAI_BaseNPC" )

CAI_BaseNPC.ClassName <- "CAI_BaseNPC"
CAI_BaseNPC.ownerPlayer <- null
CAI_BaseNPC.supportsXRay <- null
CAI_BaseNPC.supportsPredictiveTargeting <- null

function CAI_BaseNPC::SetOwnerPlayer( player )
{
	Assert( player.IsPlayer() )
	ownerPlayer = player.weakref()
	this.SetBossPlayer( player ) // SetOwnerPlayer should probably go away at some point.
}

function CAI_BaseNPC::GetDoomedState()
{
	if ( !HasSoul( this ) )
		return 0.0

	return GetTitanSoul().IsDoomed()
}

function CAI_BaseNPC::GetOwnerPlayer()
{
	return ownerPlayer
}

function CAI_BaseNPC::HasPredictiveTargetingSupport()
{
	return ( this.supportsPredictiveTargeting != null )
}

function CAI_BaseNPC::HasXRaySupport()
{
	return ( this.supportsXRay != null )
}

function CAI_BaseNPC::EnableXRay( teamNumber, playerIndex )
{
	Assert( this.HasXRaySupport() )
	this.scope().EnableXRayRenderMode( teamNumber, playerIndex )
}

function CAI_BaseNPC::DisableXRay( teamNumber, playerIndex )
{
	Assert( this.HasXRaySupport() )
	this.scope().DisableXRayRenderMode( teamNumber, playerIndex )
}


function CAI_BaseNPC::ForceCombat()
{
	this.FireNow( "UpdateEnemyMemory", "!player" )
}
RegisterClassFunctionDesc( CAI_BaseNPC, "ForceCombat", "Force into combat state by updating NPC's memory of the player." )


CAI_BaseNPC.__SetSquad <- CAI_BaseNPC.SetSquad
function CAI_BaseNPC::SetSquad( squadName )
{
	Assert( !IsMultiplayer(), "Can't add guy using guy.SetSquad anymore - please use wrapper function SetSquad( guy, squadname ) instead." )
}

/*
CAI_BaseNPC.__Anim_ScriptedPlayWithRefPoint <- CAI_BaseNPC.Anim_ScriptedPlayWithRefPoint
function CAI_BaseNPC::Anim_ScriptedPlayWithRefPoint( string, Vector, Vector2, float )
{
	printt( this, "Anim_ScriptedPlayWithRefPoint", string )
	this.__Anim_ScriptedPlayWithRefPoint( string, Vector, Vector2, float )
}

CAI_BaseNPC.__Anim_ScriptedPlay <- CAI_BaseNPC.Anim_ScriptedPlay
function CAI_BaseNPC::Anim_ScriptedPlay( string )
{
	printt( this, "Anim_ScriptedPlay", string )
	this.__Anim_ScriptedPlay( string )
}

CAI_BaseNPC.__SetMoveAnim <- CAI_BaseNPC.SetMoveAnim
function CAI_BaseNPC::SetMoveAnim( anim )
{
	if ( "marvin" in level && this == level.marvin )
	{
		printl( "Marvin set move anim " + anim )
	}
	this.__SetMoveAnim( anim )
}

CAI_BaseNPC.__ClearMoveAnim <- CAI_BaseNPC.ClearMoveAnim
function CAI_BaseNPC::ClearMoveAnim()
{
	if ( "marvin" in level && this == level.marvin )
	{
		printl( "Marvin cleared move anim." )
	}
	this.__ClearMoveAnim()
}
*/

CAI_BaseNPC.__AssaultPoint <- CAI_BaseNPC.AssaultPoint
function CAI_BaseNPC::AssaultPoint( vec, tolerance = 16 )
{
	this.__AssaultPoint( vec, tolerance )
}

CAI_BaseNPC.__SetTeam <- CAI_BaseNPC.SetTeam
function CAI_BaseNPC::SetTeam( team )
{
	local currentTeam = this.GetTeam()
	local alreadyAssignedValidTeam = ( currentTeam == TEAM_IMC || currentTeam == TEAM_MILITIA )

	this.__SetTeam( team )

	if ( this.GetModelName() == "" )
		return

	if ( this.IsSoldier() || this.IsSpectre() )
	{
		local eHandle = this.GetEncodedEHandle()

		local players = GetPlayerArray()
		foreach ( player in players )
		{
			Remote.CallFunction_Replay( player, "ServerCallback_UpdateOverheadIconForNPC", eHandle )
		}
	}

	local modelTable = this.CreateTableFromModelKeyValues()

	if ( !modelTable )
		return

	if ( !( "teamSkin" in modelTable ) )
		return

	if ( alreadyAssignedValidTeam && ( !( "swapTeamOnLeech" in modelTable.teamSkin ) ) )
		return

	SetSkinForTeam( this, team )

	if ( this.IsTitan() )
	{
		//Set rocket pod skin correctly
		if ( !HasSoul( this ) )
		{
			//printt( "No soul!" )
			return
		}

		local soul = this.GetTitanSoul()
		local leftRocketPod = soul.rocketPod.model
		if ( IsValid( leftRocketPod ) )
		{
			//printt( "Setting team for npc left rocket pod" )
			SetSkinForTeam( leftRocketPod, team )
		}
	}

	//TODO : Satchel stuff for npc turrets. This doesn't quite work yet

	/*if ( "satchels" in this.s )
	{
		foreach ( satchel in this.s.satchels )
		{
			printt("switching satchel: " + satchel + " for turret:" + this )
			local enemyTeam = GetOtherTeam( this )
			satchel.SetTeam( enemyTeam )
			Assert( "glowSatchel" in satchel.s )
			satchel.s.glowSatchel.kv.TeamNumber = enemyTeam
			"Resetting visibility flags since it isn't changed automatically when team is changed"
			printt( "Setting visiblity Flags once" )
			satchel.s.glowSatchel.kv.VisibilityFlags = 0
			printt( "Setting visiblity Flags twice" )
			satchel.s.glowSatchel.kv.VisibilityFlags = 3
		}
	}	*/
}





function CAI_BaseNPC::GetPlayerSettings()
{
	Assert( this.IsTitan(), this + " is not a titan" )
	Assert( "titanSettings" in this.s && this.s.titanSettings, this + " does not have titan settings" )
	return this.s.titanSettings
}

function CAI_BaseNPC::GetPlayerSettingsNum()
{
	local settings = this.GetPlayerSettings()

	return GetPlayerSettingsNumFromString( settings )
}


/*
CAI_BaseNPC.__SetName <- CAI_BaseNPC.SetName
function CAI_BaseNPC::SetName( name )
{
	if ( this.GetName() == "" )
	{
		printl( "\n")
		DumpStack()
	}
	printl( "Setting name of " + this + " to " + name )
	this.__SetName( name )
}
*/

function CAI_BaseNPC::DropWeapon()
{
	local weapon = this.GetActiveWeapon()
	if ( !weapon )
		return
	local name = weapon.GetClassname()

	// giving the weapon you have drops a new one in its place
	this.GiveWeapon( name )
	this.TakeActiveWeapon()
}
RegisterClassFunctionDesc( CAI_BaseNPC, "DropWeapon", "Drop the weapon the NPC is currently using." )



// function FindHatedPlayers()
// find NPCs I should hate
function CAI_BaseNPC::FindHatedPlayers()
{
	return GetRelatedEntities( this, RelationshipGroupHates, "relationshipPlayers_Group" )
}

// function FindLikedPlayers()
// find NPCs I should Like
function CAI_BaseNPC::FindLikedPlayers()
{
	return GetRelatedEntities( this, RelationshipGroupLikes, "relationshipPlayers_Group" )
}

// function FindHatedNPCs()
// find NPCs I should hate
function CAI_BaseNPC::FindHatedNPCs()
{
	return GetRelatedEntities( this, RelationshipGroupHates, "relationshipNPCs_Group" )
}

// function FindLikedNPCs()
function CAI_BaseNPC::FindLikedNPCs()
{
	return GetRelatedEntities( this, RelationshipGroupLikes, "relationshipNPCs_Group" )
}

function CAI_BaseNPC::DisableStarts()
{
	this.kv.disableArrivalMoveTransitions = true
}
RegisterClassFunctionDesc( CAI_BaseNPC, "DisableStarts", "Disables movement start anims" )

function CAI_BaseNPC::EnableStarts()
{
	this.kv.disableArrivalMoveTransitions = false
}
RegisterClassFunctionDesc( CAI_BaseNPC, "EnableStarts", "Enables movement start anims" )

function CAI_BaseNPC::InCombat()
{
	local enemy = this.GetEnemy()
	if ( !IsValid( enemy ) )
		return false

	return this.CanSee( enemy )
}
RegisterClassFunctionDesc( CAI_BaseNPC, "InCombat", "Returns true if NPC is in combat" )

