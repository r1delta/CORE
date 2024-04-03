function main()
{
	Globalize( RegisterRushpointUpdateFunc )
	Globalize( InitializeRushpoints )

	Globalize( GetRushpoints )

	Globalize( InitializeRushpoint )

	Globalize( GetRushpointIndex )
	Globalize( GetCurrentRushpointID )
	Globalize( SetCurrentRushpointID )
	Globalize( ClearCurrentRushpointID )

	Globalize( AddRushpointTeamSwitchCallback )

	file.usedRushpointIDs <- {}
	file.rushpointUpdateFunc <- null

}

// pass the hardpoints that should be used in the gamemode
function InitializeRushpoints( rushpointArray )
{
	// add hardpoints to level.hardpoints
	// add the trigger to the .s of the hardpoint
	// hook up trigger to enter/leave functions
	// init npc slots on the hardpoint
	// init assault ents
	// init hardpoint names

	foreach ( rushpoint in rushpointArray )
		InitializeRushpoint( rushpoint )

	Assert( rushpointArray.len() == 2 )

	for( local rushpointID = 0; rushpointID < rushpointArray.len(); rushpointID++ )
	{
		rushpointArray[rushpointID].SetRushpointID( rushpointID )
		file.usedRushpointIDs[ rushpointID ] <- rushpointID
	}
}

function InitializeRushpoint( rushpoint )
{
	// level.hardpoints is created in _base_gametype.nut, don't ask me why
	level.rushpoints.append( rushpoint )

	rushpoint.s.startHackingTime <- null
	rushpoint.s.lastHackingTime <- null

	rushpoint.s.teamSwitchCallbacks <- []

	rushpoint.SetTeam(GetOtherTeam(level.nv.attackingTeam))
}


function RegisterRushpointUpdateFunc( updateFunc )
{
	Assert( !file.rushpointUpdateFunc )

	file.rushpointUpdateFunc = updateFunc
}


function GetRushpoints()
{
	Assert( "rushpoints" in level, "level.rushpoints not initalized yet" )
	Assert( level.rushpoints.len(), "level.rushpoints is an empty array" )

	return level.rushpoints
}


//////////////////////////////////////////////////////////
function GetRushpointIndex( rushpoint )
{
	Assert( level.rushpoints.len() == 3 )

	foreach( index, point in level.rushpoints )
	{
		if ( rushpoint == point )
			return index
	}

	Assert( false, rushpoint + " is not a valid rushpoint entity!" )
}


//////////////////////////////////////////////////////////
function SetCurrentRushpointID( ent, id )
{
	// when a something leaves one trigger and enters another in the same frame
	// this function would get called before the clear function.
	// the WaitFrameEnd assures that things happen in the right order.
	// -Roger
	if ( "currentRushpointID" in ent.s )
		WaitEndFrame()

	if ( "currentRushpointID" in ent.s )
		ent.s.currentRushpointID = id
	else
		ent.s.currentRushpointID <- id
}


//////////////////////////////////////////////////////////
function ClearCurrentRushpointID( ent )
{
	if ( "currentRushpointID" in ent.s )
		delete ent.s.currentRushpointID
}


//////////////////////////////////////////////////////////
function GetCurrentRushpointID( ent )
{
	local id = null

	if ( "currentRushpointID" in ent.s )
		id = ent.s.currentRushpointID

	return id
}

function Rushpoint_Update( rushpoint )
{
	if ( GetGameState() != eGameState.Playing )
		return

	file.rushpointUpdateFunc( rushpoint )
}

//////////////////////////////////////////////////////////
function RushPointThink( rushpoint )
{
	while ( true )
	{
		local state = GetRushPointThinkState( rushpoint )

		switch ( state )
		{
			case "HACKING":
				break

			case "NOT_HACKING":

				break

			default:
				break
		}

		waitthread WaitForUpdate( capturepoint, guys, state )
//		printt( "Wait ended" )
	}
}

//////////////////////////////////////////////////////////
function GetRushPointThinkState( rushpoint )
{
	// 포인트의 팀이 공격 팀이면 해킹 상태.
	if ( rushpoint.GetTeam() == level.nv.attackingTeam )
		return "HACKING"

	return "NOT_HACKING"
}

function AddRushpointTeamSwitchCallback( rushpoint, callbackFunc )
{
	Assert( "teamSwitchCallbacks" in rushpoint.s )
	Assert( type( this ) == "table", "AddRushpointTeamSwitchCallback can only be added on a table. " + type( this ) )
	AssertParameters( callbackFunc, 2, "rushpoint, team" )

	local callbackInfo = {}
	callbackInfo.func <- callbackFunc
	callbackInfo.scope <- this

	hardpoint.s.teamSwitchCallbacks.append( callbackInfo )
}

function RushpointTeamChange( rushpoint, team, silent = false )
{
	// Change the hardpoint team and notify all players
	local previousTeam = rushpoint.GetTeam()

	if ( team == previousTeam )
		return

	rushpoint.SetTeam( team )

//	Use AddRushpointTeamSwitchCallback( hardpoint, callbackFunc ) to add
	foreach ( callbackInfo in hardpoint.s.teamSwitchCallbacks )
	{
		callbackInfo.func.acall( [ callbackInfo.scope, hardpoint, previousTeam ] )
	}
}
// tmp until cleanup is done
Globalize( RushpointTeamChange )