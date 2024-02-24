const HARDPOINT_SHIFT_DELAY = 5

function main()
{
	Globalize( RegisterHardpointTriggerFunc )
	Globalize( RegisterHardpointUpdateFunc )
	Globalize( InitializeHardpoints )
	Globalize( DeleteHardpoint )

	Globalize( GetHardpointNPC )
	Globalize( GetHardpointNPCCount )
	Globalize( GetHardpointWithLeastNPC )
	Globalize( GetHardpointsSortedByNPCCount ) // this should most likely go away
	Globalize( GetHardpointSquadName )
	Globalize( GetHardpoints )
	Globalize( GetNumHardpointsControlledByTeam )

	Globalize( LinkTurretWithHardpoint )
	Globalize( LinkTargetToHardpointTurrets )

	Globalize( UpdateHardpointCount )


	Globalize( HardpointReserveNPCSlots )
	Globalize( HardpointReleaseNPCSlots )
	Globalize( NPCBusyAtHardpoint )

	Globalize( SquadAssaultHardpoint )	// takes a squadname and have them all assault a hardpoint
	Globalize( NPCsAssaultHardpoint )	// takes an array of guys
	Globalize( AssaultHardpoint )		// takes an individual guy (it's a good idea to make sure that all guys are in the same squad
	Globalize( InitializeHardpoint )

	Globalize( GetHardpointIndex )
	Globalize( EntityCanCapturePoints )
	Globalize( GetCurrentHardpointID )
	Globalize( SetCurrentHardpointID )
	Globalize( ClearCurrentHardpointID )

	Globalize( TerminalDeathAnim )
	Globalize( HardpointTerminal_HaveRecentEnemy )
	Globalize( SquadCapturePointThink )

	Globalize( AddHardpointTeamSwitchCallback )

	RegisterSignal( "StopHardpointBehavior" )
	RegisterSignal( "FreshContested" )

	RegisterSignal( "EndGoto" )
	RegisterSignal( "SquadCapturePointThink_TEAM_IMC" )
	RegisterSignal( "SquadCapturePointThink_TEAM_MILITIA" )
	RegisterSignal( "NPCStateChange" )
	RegisterSignal( "Interrupt" )

	file.triggerEnterFuncs <- []
	file.triggerLeaveFuncs <- []
	file.usedHardpointIDs <- {}
	file.hardpointUpdateFunc <- null
	level.AIUseCapturePointTerminals <- true

	AddCallback_OnClientConnecting( Hardpoint_OnClientConnecting )

	// need to precache models now that they are not compiled in.
	PrecacheModel( "models/communication/terminal_com_station.mdl" )
	PrecacheModel( "models/communication/terminal_com_station_nobase.mdl" )
	PrecacheModel( "models/communication/terminal_com_station_tall.mdl" )
	PrecacheModel( "models/communication/terminal_com_station_tall_nobase.mdl" )

	file.terminalAnimArrayIn <- [
		"pt_console_runin_R",
		"pt_console_runin_L",
		"pt_console_backin_R",
		"pt_console_backin_L"
	]

	file.terminalAnimArrayOut <- [
		"pt_console_react_R",
		"pt_console_react_R_alt",
		"pt_console_react_L",
		"pt_console_react_L_alt"
	]

	file.terminalAnimArrayDeath <- [
		"pt_console_death_slideleft",
		"pt_console_death_slideright",
	]

	// list of animations where the NPC should come to a stop before starting the animation
	file.startStillList <- {
		pt_console_backin_R = true,
		pt_console_backin_L = true
	}

	file.termainalAttachmentArray <- [ "SEAT_N", "SEAT_W", "SEAT_S", "SEAT_E" ]
}

function NearHardpoint( dropPoint )
{
	foreach ( hardpoint in level.hardpoints )
	{
		local origin = hardpoint.GetOrigin()
		origin.z -= 100 // why are hardpoints not really at the origin?
		if ( Distance( origin, dropPoint ) < SAFE_TITANFALL_DISTANCE )
			return true
	}

	return false
}
Globalize( NearHardpoint )

// pass the hardpoints that should be used in the gamemode
function InitializeHardpoints( hardpointArray )
{
	// add hardpoints to level.hardpoints
	// add the trigger to the .s of the hardpoint
	// hook up trigger to enter/leave functions
	// init npc slots on the hardpoint
	// init assault ents
	// init hardpoint names

	foreach ( hardpoint in hardpointArray )
		InitializeHardpoint( hardpoint )

	Assert( hardpointArray.len() == 3 )

	local hardpointID

	local hardpointID = 0
	hardpointArray[0].SetHardpointID( hardpointID )
	file.usedHardpointIDs[ hardpointID ] <- hardpointID

	local hardpointID = 1
	hardpointArray[1].SetHardpointID( hardpointID )
	file.usedHardpointIDs[ hardpointID ] <- hardpointID

	local hardpointID = 2
	hardpointArray[2].SetHardpointID( hardpointID )
	file.usedHardpointIDs[ hardpointID ] <- hardpointID

	InitSpawnpointNearbyHardpoints()
}

function InitializeHardpoint( hardpoint )
{
	// level.hardpoints is created in _base_gametype.nut, don't ask me why
	level.hardpoints.append( hardpoint )

	hardpoint.s.trigger <- null
	Assert( hardpoint.HasKey( "triggerTarget" ) && hardpoint.kv.triggerTarget != null )
	hardpoint.s.trigger = GetEnt( hardpoint.kv.triggerTarget )
	Assert( hardpoint.s.trigger, "Hardpoint with no trigger " + hardpoint.GetName() )
	hardpoint.s.trigger.s.hardpointEnt <- hardpoint
	hardpoint.s.trigger.ConnectOutput( "OnStartTouch", HardpointOnStartTouch )
	hardpoint.s.trigger.ConnectOutput( "OnEndTouch", HardpointOnEndTouch )

	hardpoint.s.startCapTime <- null
	hardpoint.s.lastCapTime <- null

	hardpoint.s.dialogueHistory <- { [TEAM_MILITIA] = {}, [TEAM_IMC] = {} }
	hardpoint.s.dialogueHistory[ TEAM_MILITIA ][ "StartCapping" ] <- 0
	hardpoint.s.dialogueHistory[ TEAM_IMC ][ "StartCapping" ] <- 0

	// info about entities involved with the hardpoint, used for allotting appropriate score
	hardpoint.s.teamPlayersTouching <- [ {}, {}, {}, {} ]

	// info about possession
	hardpoint.s.lastCappingTeam <- null
	hardpoint.s.lastCaptureSide <- null
	hardpoint.s.cappable <- true
	hardpoint.s.haltedProgress <- null
	hardpoint.s.lastPower <- 0
	hardpoint.s.contestedCount <- 0
	hardpoint.s.previousOwner <- TEAM_UNASSIGNED

	hardpoint.s.teamSwitchCallbacks <- []

	// ai that are assaulting this point
	hardpoint.s.assaultPointAI <- CreateScriptManagedEntArray()
	hardpoint.s.assaultPointAI_Total <- 0

	hardpoint.s.reservedNPCSlots <- { [TEAM_IMC] = 0, [TEAM_MILITIA] = 0 }
	hardpoint.SetTeam( TEAM_UNASSIGNED )
	InitializeHardpointAssaultEnts( hardpoint )
	InitializeHardpointTurrets( hardpoint )

	thread SetupHardpointTerminal( hardpoint )
}




//////////////////////////////////////////////////////////
function InitializeHardpointAssaultEnts( hardpoint )
{
	hardpoint.s.assaultPoints <- []

	Assert( hardpoint.HasKey( "target" ) && hardpoint.kv.target != null )

	hardpoint.s.assaultPoints = GetEntArrayByNameWildCard_Expensive( hardpoint.kv.target )

	// It might be worth figuring out a way to sort assaultpoints in a better way,
	// so that when npc rotate to a new point they don't crisscross.
	ArrayRandomize( hardpoint.s.assaultPoints )

	Assert( hardpoint.s.assaultPoints.len() > 0, "info_hardpoint does not have assault_assaultpoint entities: " + hardpoint.GetName() + " " + hardpoint.GetOrigin() )

	foreach ( assaultPoint in hardpoint.s.assaultPoints )
	{
		Assert( !( "hardpoint" in assaultPoint.s ), "Assaultpoint " + assaultPoint + " already initialized for hardpoint " + hardpoint )
		assaultPoint.s.hardpoint <- hardpoint
		assaultPoint.s.claimTime <- 0
		assaultPoint.kv.arrivaltolerance = 64
	}
}


//////////////////////////////////////////////////////////
function InitializeHardpointNames( hardpointArray )
{
	local sortFunc =
		function( a, b )
		{
			local a_haveName = a.HasKey( "hardpointName" ) && a.Get( "hardpointName" ) != "random"
			local b_haveName = b.HasKey( "hardpointName" ) && b.Get( "hardpointName" ) != "random"

			if ( a_haveName )
				return -1
			else if ( b_haveName )
				return 1
			return 0
		}

	// sort the array so that hardpoint with names get handled first
	hardpointArray.sort( sortFunc )

	// loop through the hardpoints - using a for loop since I'm not sure if foreach respects the order
	for ( local i = 0; i < hardpointArray.len(); i++ )
	{
		local hardpoint = hardpointArray[ i ]
		local thisID = null

		if ( hardpoint.HasKey( "hardpointName" ) && hardpoint.kv.hardpointName != "random" )
		{
			local id = null
			local specificName = hardpoint.kv.hardpointName

			foreach ( key, val in level.hardpointStringIDs )
			{
				if ( specificName == val )
				{
					id = key
					break
				}
			}

			Assert( id != null, "Hardpoint name '" + specificName + "' isn't recognized!" )

			// If we're already using the name print a warning
			if ( id in file.usedHardpointIDs )
				printt( "Warning: Hardpoint name " + specificName + " used on more than one simultaneously active hardpoint. Doing a random name instead." )
			else
				thisID = id
		}
		else
		{
			// If no specific ID set, assign a unused one from the list
			local id = null

			foreach ( key, val in level.hardpointStringIDs )
			{
				if ( !( key in file.usedHardpointIDs ) )
				{
					id = key
					break
				}
			}

			thisID = id
		}

		hardpoint.s.hardpointID <- thisID
		file.usedHardpointIDs[ thisID ] <- thisID
	}
}




function Hardpoint_OnClientConnecting( player )
{
	InitPlayerHardpointData( player )
}


function InitPlayerHardpointData( player )
{
	player.s.hardpointData <- {}

	player.s.hardpointData.hardpointID <- null
	player.s.hardpointData.firstUseTime <- null
	player.s.hardpointData.lastUseTime <- null

	player.s.curHardpoint <- null
	player.s.curHardpointDist <- null
	player.s.curHardpointTime <- null
	player.s.lastHardPointActivityTime <- 0 //Used to nag player into capping points
}


function UpdatePlayerHardpointData( player, hardpointEnt )
{
	local hardpointData = player.s.hardpointData

	if ( hardpointData.hardpointID != hardpointEnt.GetHardpointID() )
	{
		hardpointData.hardpointID = hardpointEnt.GetHardpointID()
		hardpointData.firstUseTime = Time()
	}

	hardpointData.lastUseTime = Time()
}


//////////////////////////////////////////////////////////
function InitializeHardpointTurrets( hardpoint )
{
	hardpoint.s.turrets <- []
	if ( hardpoint.HasKey( "turretTarget" ) )
	{
		hardpoint.s.turrets = GetEntArrayByNameWildCard_Expensive( hardpoint.kv.turretTarget )

		foreach ( turret in 	hardpoint.s.turrets )
		{
			Assert( turret.IsNPC() && turret.GetAIClass() == "turret", "Hardpoint at origin " + hardpoint.GetOrigin() + " has its 'turretTarget' key set to a non-turret entity called " + hardpoint.kv.turretTarget )
		}
	}
}


//////////////////////////////////////////////////////////
function DeleteHardpoint( hardpoint )
{
	if ( hardpoint.HasKey( "triggerTarget" ) && hardpoint.kv.triggerTarget != null )
	{
		local trigger = GetEnt( hardpoint.kv.triggerTarget )
		Assert( trigger )
		trigger.Destroy()
	}

	hardpoint.Destroy()
}


//////////////////////////////////////////////////////////
function RegisterHardpointTriggerFunc( enterFunc, leaveFunc )
{
	file.triggerEnterFuncs.append( enterFunc )
	file.triggerLeaveFuncs.append( leaveFunc )
}


function RegisterHardpointUpdateFunc( updateFunc )
{
	Assert( !file.hardpointUpdateFunc )

	file.hardpointUpdateFunc = updateFunc
}


//////////////////////////////////////////////////////////
function GetHardpointSquadName( hardpoint, team )
{
	Assert( team == TEAM_IMC || team == TEAM_MILITIA )

	local teamStr = "MILITIA"
	if ( team == TEAM_IMC )
		teamStr = "IMC"

	local StringID = GetHardpointStringID( hardpoint.GetHardpointID() )
	local squadName = StringID + "_" + teamStr + "_squad"

	return squadName
}


//////////////////////////////////////////////////////////
function GetHardpointWithLeastNPC( team )
{
	local selection
	local npcCount = 1000
	foreach ( hardpoint in level.hardpoints )
	{
		local count = GetHardpointNPCCount( hardpoint, team )
		if (  count < npcCount )
		{
			npcCount = count
			selection = hardpoint
		}
	}

	return selection
}


function GetHardpoints()
{
	Assert( "hardpoints" in level, "level.hardpoints not initalized yet" )
	Assert( level.hardpoints.len(), "level.hardpoints is an empty array" )

	return level.hardpoints
}

//////////////////////////////////////////////////////////
function GetHardpointsSortedByNPCCount( team )
{
	// returns an array where the hardpoints with least number of npc (of team) is first in the array
	local sortFunc =
		function( a, b ) : ( team )
		{
			local a_squadName = GetHardpointSquadName( a, team )
			local b_squadName = GetHardpointSquadName( b, team )
			local a_count = GetNPCSquadSize( a_squadName )
			local b_count = GetNPCSquadSize( b_squadName )

			if ( a_count < b_count )
				return -1
			else if ( a_count > b_count )
				return 1
			return 0
		}

	local hardpointArray = clone level.hardpoints
	hardpointArray.sort( sortFunc )
	return hardpointArray
}


//////////////////////////////////////////////////////////
function GetHardpointNPC( hardpoint, team )
{
	local squad = []
	local squadName = GetHardpointSquadName( hardpoint, team )
	if ( GetNPCSquadSize( squadName ) )
		squad = GetNPCArrayBySquad( squadName )
	return squad
}


//////////////////////////////////////////////////////////
function GetHardpointNPCCount( hardpoint, team )
{
	local squadName = GetHardpointSquadName( hardpoint, team )
	local npcCount = GetNPCSquadSize( squadName )
	npcCount += hardpoint.s.reservedNPCSlots[ team ]
	return npcCount
}


//////////////////////////////////////////////////////////
function HardpointReserveNPCSlots( count, hardpoint, team )
{
	hardpoint.s.reservedNPCSlots[ team ] += count
}


//////////////////////////////////////////////////////////
function HardpointReleaseNPCSlots( count, hardpoint, team )
{
	hardpoint.s.reservedNPCSlots[ team ] -= count
}


//////////////////////////////////////////////////////////
function SquadAssaultHardpoint( squadName, hardpoint )
{
	if ( !GetNPCSquadSize( squadName ) )
		return

	local squadMembers = GetNPCArrayBySquad( squadName )
	NPCsAssaultHardpoint( squadMembers, hardpoint )
}


//////////////////////////////////////////////////////////
function NPCsAssaultHardpoint( squadMembers, hardpoint )
{
	foreach ( guy in squadMembers )
		AssaultHardpoint( guy, hardpoint )
}


//////////////////////////////////////////////////////////
function AssaultHardpoint( guy, hardpoint )
{
	thread AssaultHardpointLoop( guy, hardpoint )
}


//////////////////////////////////////////////////////////
function AssaultHardpointLoop( guy, hardpoint )
{
	if ( !hardpoint.Enabled() )
		return

	guy.Signal( "StopHardpointBehavior" )
	guy.EndSignal( "StopHardpointBehavior" )
	guy.EndSignal( "OnDeath" )
	guy.EndSignal( "OnDestroy" )

	local team = guy.GetTeam()

	AddToScriptManagedEntArray( hardpoint.s.assaultPointAI, guy )

	OnThreadEnd(
		function() : ( guy, hardpoint, team )
		{
			if ( IsValid( guy ) )
			{
				// how to handle spectres switching teams? Assert for now so that It's not forgotten.
				Assert( guy.GetTeam() == team, "The guy, probably a Spectre, didn't have the same team when he died as he did when he assaulted the hardpoint" )

				// release any claimed assault points
				if ( IsValid( guy.s.assaultPointHardpoint ) )
					guy.s.assaultPointHardpoint.s.claimTime = 0

				// reset the NPC to normal
				guy.DisableBehavior( "Assault" )
				guy.StayCloseToSquad( true )
				delete guy.s.assaultPointHardpoint
			}
		}
	)

	local hardpointSquadName = GetHardpointSquadName( hardpoint, guy.GetTeam() )

	// this is using assault_assaultpoint ents placed in the world
	Assert( !( "assaultPointHardpoint" in guy.s ) )
	guy.s.assaultPointHardpoint <- null

	local assaultPoint = null

	local spawnPointArray = GetNearestDropPodSpawnPoints( hardpoint.GetOrigin() )

	while ( true )
	{
		assaultPoint = ClaimAssaultPoint( hardpoint, assaultPoint )
		guy.s.assaultPointHardpoint = assaultPoint

		local delay = HARDPOINT_SHIFT_DELAY + RandomFloat( 0, 0.3 )

		if ( assaultPoint )
		{
			guy.AssaultPointEnt( assaultPoint )
			guy.WaitSignal( "OnFinishedAssault" )
			guy.StayCloseToSquad( false )

			assaultPoint.s.claimTime = Time() + delay
	//		guy.kv.NumGrenades = 5
		}
		else
		{
			local origin

			if ( ShouldHangOutsideHardpoint( guy, hardpoint, spawnPointArray ) )
			{
				local spawnPoint = Random( spawnPointArray )
				origin = spawnPoint.GetOrigin()
			}
			else
			{
				local terminal = hardpoint.GetTerminal()
				local nearestNode = GetNearestNodeToPos( terminal.GetOrigin() )
				Assert( nearestNode )
				local neighborNodes = GetNeighborNodes( nearestNode, 10, HULL_HUMAN )
				local node = Random( neighborNodes )
				origin = GetNodePos( node, HULL_HUMAN )
			}

			//DebugDrawLine( guy.GetOrigin(), origin + Vector( 0,0,150 ), RandomInt(255), RandomInt(255), RandomInt(255), true, 3 )
			guy.AssaultPoint( origin )
			guy.WaitSignal( "OnFinishedAssault" )
//			guy.StayPut( true )
		}

		wait delay
	}
}

function ShouldHangOutsideHardpoint( guy, hardpoint, spawnPointArray )
{
	// no place to hang
	if ( !spawnPointArray.len() )
		return false

	if ( Distance( guy.GetOrigin(), hardpoint.GetTerminal().GetOrigin() ) > 1200 )
		return false

	// hardpoint is not captured, run inside!
	if ( hardpoint.GetHardpointState() != CAPTURE_POINT_STATE_CAPTURED )
		return false

	// hardpoint is captured, but its our team, so hang outside
	return hardpoint.GetTeam() == guy.GetTeam()
}

function GetAIAssaultingHardPoint( hardpoint )
{
	local guys = []
	local array = GetScriptManagedEntArray( hardpoint.s.assaultPointAI )
	foreach ( guy in array )
	{
		if ( IsAlive( guy ) )
			guys.append( guy )
	}
	return guys
}
Globalize( GetAIAssaultingHardPoint )

function KillAIAssaultingHardPoint( hardpoint )
{
	local array = GetScriptManagedEntArray( hardpoint.s.assaultPointAI )
	foreach ( guy in array )
	{
		if ( IsAlive( guy ) )
			guy.Die()
	}
}
Globalize( KillAIAssaultingHardPoint )

function GetNearestDropPodSpawnPoints( origin )
{
	local array = ArrayClosest( SpawnPoints_GetDropPod(), origin )
	local max = 5
	if ( max > array.len() )
		max = array.len()
	local result = []
	for ( local i = 0; i < max; i++ )
	{
		result.append( array[i] )
	}
	return result
}


//////////////////////////////////////////////////////////
function ClaimAssaultPoint( hardpoint, previousAssaultPoint = null )
{
	local assaultPointArray = hardpoint.s.assaultPoints
	local pointCount = assaultPointArray.len( )
	local time = Time()
	local startIndex = 0

	// find startIndex
	foreach ( index, assaultPoint in hardpoint.s.assaultPoints )
	{
		if ( previousAssaultPoint != assaultPoint )
			continue

		startIndex = index + 1
		break
	}

	for ( local i = 0; i < pointCount; i++ )
	{
		local index = ( startIndex + i ) % pointCount
		local assaultPoint = assaultPointArray[ index ]

		if ( assaultPoint.s.claimTime < 0 )
			continue
		if ( assaultPoint.s.claimTime > time )
			continue
		if ( assaultPoint == previousAssaultPoint )
			continue

		assaultPoint.s.claimTime = -1
		return assaultPoint
	}

	return null
}


//////////////////////////////////////////////////////////
function GetHardpointIndex( hardpoint )
{
	Assert( level.hardpoints.len() == 3 )

	foreach( index, point in level.hardpoints )
	{
		if ( hardpoint == point )
			return index
	}

	Assert( false, hardpoint + " is not a valid hardpoint entity!" )
}


//////////////////////////////////////////////////////////
function SetCurrentHardpointID( ent, id )
{
	// when a something leaves one trigger and enters another in the same frame
	// this function would get called before the clear function.
	// the WaitFrameEnd assures that things happen in the right order.
	// -Roger
	if ( "currentHardpointID" in ent.s )
		WaitEndFrame()

	if ( "currentHardpointID" in ent.s )
		ent.s.currentHardpointID = id
	else
		ent.s.currentHardpointID <- id
}


//////////////////////////////////////////////////////////
function ClearCurrentHardpointID( ent )
{
	if ( "currentHardpointID" in ent.s )
		delete ent.s.currentHardpointID
}


//////////////////////////////////////////////////////////
function GetCurrentHardpointID( ent )
{
	local id = null

	if ( "currentHardpointID" in ent.s )
		id = ent.s.currentHardpointID

	return id
}


function EntityCanCapturePoints( entity )
{
	Assert( entity != null )

	if ( entity.IsPlayer() )
		return true

	if ( entity.GetTeam() == TEAM_IMC || entity.GetTeam() == TEAM_MILITIA )
	{
		if ( entity.IsNPC() )
			return true
	}

	return false
}


//////////////////////////////////////////////////////////
function HardpointOnStartTouch( self, activator, caller, value )
{
	local touchEnt = activator

	if ( !IsAlive( touchEnt ) || !EntityCanCapturePoints( touchEnt ) )
		return

	local hardpoint = self.s.hardpointEnt

	if ( !GetFriendlyCount( hardpoint, touchEnt ) && !GetEnemyCount( hardpoint, touchEnt ) && hardpoint.GetTeam() != touchEnt.GetTeam() )
	{
		hardpoint.s.startCapTime = Time()
		hardpoint.s.lastCapTime = null
	}

	if ( touchEnt.IsPlayer() )
	{
		UpdatePlayerHardpointData( touchEnt, hardpoint )

		//printl( "Enter hardpoint player " + touchEnt.GetPlayerName() + " team: " + touchEnt.GetTeam() )
		hardpoint.s.teamPlayersTouching[ touchEnt.GetTeam() ][ touchEnt ] <- Time()

		if ( touchEnt.GetHardpointEntity() != hardpoint )
		{
			touchEnt.SetHardpointEntity( hardpoint )
//			printt( touchEnt + " touching hard point " + hardpoint )
		}
	}

	SetCurrentHardpointID( touchEnt, hardpoint.GetHardpointID() )
	UpdateHardpointCount( hardpoint )

	foreach ( func in file.triggerEnterFuncs )
		thread func( touchEnt, self, hardpoint )
}


//////////////////////////////////////////////////////////
function HardpointOnEndTouch( self, activator, caller, value )
{
	local hardpoint = self.s.hardpointEnt
	local touchEnt = activator

	if ( touchEnt == null )
	{
		// Update the hardpoint here to catch Pilots entering their Auto Titans while inside a hardpoint trigger.
		if ( IsValid( hardpoint ) )
			Hardpoint_Update( hardpoint )
		return
	}

	if ( !EntityCanCapturePoints( touchEnt ) )
		return

	if ( touchEnt.IsPlayer() && touchEnt in hardpoint.s.teamPlayersTouching[ touchEnt.GetTeam() ] )
	{
		delete hardpoint.s.teamPlayersTouching[ touchEnt.GetTeam() ][ touchEnt ]

		if ( touchEnt.GetHardpointEntity() == hardpoint )
			touchEnt.SetHardpointEntity( null )
	}

	// only clear the hardpointID if he's not dying. This way death callbacks can read it later
	if ( IsAlive( touchEnt ) )
		ClearCurrentHardpointID( touchEnt )

	if ( GetFriendlyCount( hardpoint, touchEnt ) == 1 && !GetEnemyCount( hardpoint, touchEnt ) && hardpoint.GetTeam() != touchEnt.GetTeam() )
	{
		hardpoint.s.startCapTime = null
		hardpoint.s.lastCapTime = Time()
	}

	UpdateHardpointCount( hardpoint )

	foreach ( func in file.triggerLeaveFuncs )
		thread func( touchEnt, self, hardpoint )
}


const HARDPOINT_TITAN_BREAK_CONTEST = true

// temp function that is needed until I always get a reliable activator from OnStartTouch and OnEndTouch
function UpdateHardpointCount( point )
{
	local freshContested = false
	local touchingEnts = point.s.trigger.GetTouchingEntities()

	local teamAICount = {}
	teamAICount[TEAM_IMC] <- 0
	teamAICount[TEAM_MILITIA] <- 0

	local teamPlayerCount = {}
	teamPlayerCount[TEAM_IMC] <- 0
	teamPlayerCount[TEAM_MILITIA] <- 0

	local teamTitanCount = {}
	teamTitanCount[TEAM_IMC] <- 0
	teamTitanCount[TEAM_MILITIA] <- 0

	local lastAICounts = {}
	lastAICounts[TEAM_IMC] <- point.GetHardpointAICount( TEAM_IMC )
	lastAICounts[TEAM_MILITIA] <- point.GetHardpointAICount( TEAM_MILITIA )

	local lastPlayerCounts = {}
	lastPlayerCounts[TEAM_IMC] <- point.GetHardpointPlayerCount( TEAM_IMC )
	lastPlayerCounts[TEAM_MILITIA] <- point.GetHardpointPlayerCount( TEAM_MILITIA )

	local lastTitanCounts = {}
	lastTitanCounts[TEAM_IMC] <- point.GetHardpointPlayerTitanCount( TEAM_IMC )
	lastTitanCounts[TEAM_MILITIA] <- point.GetHardpointPlayerTitanCount( TEAM_MILITIA )

	foreach ( ent in touchingEnts )
	{
		if ( IsAlive( ent ) && EntityCanCapturePoints( ent ) )
		{
			// only add AI that are using a terminal
			local usingTerminal = !level.AIUseCapturePointTerminals || ( "cpState" in ent.s && ent.s.cpState == eNPCStateCP.USING_TERMINAL )

			local entTeam = ent.GetTeam()

			if ( IsPlayer( ent ) )
			{
				teamPlayerCount[entTeam]++
				if ( ent.IsTitan() )
					teamTitanCount[entTeam]++
			}
			else if ( usingTerminal )
			{
				teamAICount[entTeam]++
			}
		}
	}

	local lastCappingTeam = point.s.lastCappingTeam

	if ( lastCappingTeam == TEAM_IMC || lastCappingTeam == TEAM_MILITIA )
	{
		local otherTeam = GetTeamIndex(GetOtherTeams(1 << lastCappingTeam))

		local wasContested = GetCapPowerFromTables( point, lastPlayerCounts, lastTitanCounts, lastAICounts ).contested
		local isContested = GetCapPowerFromTables( point, teamPlayerCount, teamTitanCount, teamAICount ).contested

		if ( isContested && !wasContested )
		{
			point.s.contestedCount++
			freshContested = true
		}
	}


	point.SetHardpointAICount( TEAM_IMC, teamAICount[TEAM_IMC] )
	point.SetHardpointAICount( TEAM_MILITIA, teamAICount[TEAM_MILITIA] )
	point.SetHardpointPlayerCount( TEAM_IMC, teamPlayerCount[TEAM_IMC] )
	point.SetHardpointPlayerCount( TEAM_MILITIA, teamPlayerCount[TEAM_MILITIA] )
	point.SetHardpointPlayerTitanCount( TEAM_IMC, teamTitanCount[TEAM_IMC] )
	point.SetHardpointPlayerTitanCount( TEAM_MILITIA, teamTitanCount[TEAM_MILITIA] )

	// hardpoint is contested now but wasn't before
	if ( freshContested )
		point.Signal( "FreshContested" )
}


///////////////////////////////////////////////////////////
function SetupHardpointTerminal( hardpoint )
{
	local nearTarget = UsingPropDynamic( hardpoint )

	local model = hardpoint.kv.model
	local origin = hardpoint.GetOrigin()
	local angles = hardpoint.GetAngles()

	Assert( model != "", "no model set for info_hardpoint at " + origin )

	local terminal = CreatePropDynamic( model, origin, angles, 6 )

	if ( !nearTarget )
	{
		Assert( hardpoint.HasKey( "nearTarget" ), "The info_hardpoint must target at least 4 assault_assaultpoints with it's nearTarget key/value." )
		nearTarget = hardpoint.kv.nearTarget
	}

	terminal.s.captureDialogue <- { [TEAM_IMC] = false, [TEAM_MILITIA] = false }
	terminal.s.deathTimestamp <- 0

	// store data about the terminal etc on the info_hardpoint entity for use later on.
	hardpoint.SetTerminal( terminal )

	wait 1	// no need to set up terminal anims on the first frame.
	SetupTerminalAnims( terminal )

	local terminalOrigin = terminal.GetOrigin()

	local nodeArray = []
	nodeArray = GetEntArrayByNameWildCard_Expensive( nearTarget )

	if ( nodeArray.len() < 4 )
	{
		// if we don't have enough
		local array = clone hardpoint.s.assaultPoints
		array = ArrayClosest( array, terminalOrigin )
		nodeArray.extend( array )
		nodeArray.resize( 4 )
	}

	Assert( nodeArray.len() >= 4, "couldn't find 4 assault_assaultpoint for the hardpoint terminal at " + terminal.GetOrigin() )
	terminal.s.nodeArray <- nodeArray

	terminal.SetTeam( hardpoint.GetTeam() )
}

//////////////////////////////////////////////////////////
function SetupTerminalAnims( terminal )
{
	local animEnt = CreatePropDynamic( TEAM_MILITIA_GRUNT_MDL, Vector( 0,0,0 ), Vector( 0,0,0 ) )
	animEnt.Hide()	// since it's drawn out over multiple frames lets hide this entity
	animEnt.NotSolid()
	terminal.s.slotTable <- {}
	terminal.s.slotsInUse <- 0
	terminal.s.slotsVacated <- 0

	foreach( slot in file.termainalAttachmentArray )
	{
		local animArray = []
		local id = terminal.LookupAttachment( slot )

		local animArrayIn = GetValidAnims( file.terminalAnimArrayIn, animEnt, terminal, slot, id, false, false )
		local animArrayOut = GetValidAnims( file.terminalAnimArrayOut, animEnt, terminal, slot, id, true, false )
		local animArrayDeath = GetValidAnims( file.terminalAnimArrayDeath, animEnt, terminal, slot, id, true, false )

		if ( animArrayIn && animArrayOut && animArrayDeath )
		{
			terminal.s.slotTable[ slot ] <- {
				attachment = slot,
				animArrayIn = animArrayIn,
				animArrayOut = animArrayOut,
				animArrayDeath = animArrayDeath,
				inUse = false
				capping = false
			}
		}
		wait 0	// it's fine to spread these traces out over more then one frame.
	}

	Assert( terminal.s.slotTable.len() >= 2, "Couldn't find 2 animations to use for terminal at " + terminal.GetOrigin() )

	animEnt.Destroy()
}

function GetValidAnims( animArray, animEnt, terminal, slot, id, exit = false, line = false )
{
	local array = []
	local zOffset = 4	// roughly how uneven the ground can be where you place the hardpoint terminal

	foreach( anim in animArray )
	{
		// check to see if the animation is in a valid spot
		local start
		local end

		if ( !exit )
		{
			local table = animEnt.Anim_GetStartForRefEntity( anim, terminal, slot )
			start = table.origin + Vector( 0, 0, zOffset )
			end = terminal.GetAttachmentOrigin( id ) + Vector( 0, 0, zOffset )
		}
		else
		{
			animEnt.SetOrigin( terminal.GetAttachmentOrigin( id ) )
			animEnt.SetAngles( terminal.GetAttachmentAngles( id ) )

			local duration = animEnt.GetSequenceDuration( anim )
			local table = animEnt.Anim_GetAttachmentAtTime( anim, "ORIGIN", duration )

			start = table.position + Vector( 0, 0, zOffset )
			end = terminal.GetAttachmentOrigin( id ) + Vector( 0, 0, zOffset )
		}

		animEnt.SetOrigin( Vector( 0, 0, 0 ) )

//		local traceFracDown = TraceLineSimple( start + Vector( 0, 0, 32), start + Vector( 0, 0, -32), terminal )
		local result = TraceLine( start + Vector( 0, 0, 32 - zOffset ), start + Vector( 0, 0, -32 - zOffset ), terminal, TRACE_MASK_SHOT_HULL, TRACE_COLLISION_GROUP_NONE )
		local traceFracDown = result.fraction
		if ( result.startSolid )
			traceFracDown = 0

		if ( VectorCompare( start, end ) )
		{
			start += Vector( 0, 0, 10 )
			traceFracDown = 0
		}

//		local traceFrac = TraceHullSimple( start, end, level.traceMins[ "npc_soldier" ], level.traceMaxs[ "npc_soldier" ], terminal )
		result = TraceHull( start, end, level.traceMins[ "npc_soldier" ], level.traceMaxs[ "npc_soldier" ], terminal, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )
		local traceFrac = result.fraction
		if ( result.startSolid )
			traceFrac = 0

		if ( traceFrac > 0.99 && traceFracDown < 0.6 )
		{
			array.append( anim )
			if ( line )
				DebugDrawLine( start, end, 0, 255, 0, true, 20 )
		}
		else if ( line )
		{
				// fail
				if ( traceFracDown < 0.6 )
					DebugDrawLine( start, start + Vector( 0, 0, -16 ), 255, 128, 0, false, 20 )
				DebugDrawLine( start, result.endPos, 255, 0, 0, false, 20 )
				DebugDrawLine( result.endPos, result.endPos + Vector( 0, 0, 16 ), 255, 0, 128, false, 20 )
		}
	}

	if ( array.len() )
		return array
	else
		return null
}

//////////////////////////////////////////////////////////
function GetFreeTerminalSlot( terminal, guy )
{
	// Get Closest free slot to the guy

	local slotArray = []
	foreach( slot in terminal.s.slotTable )
	{
		if ( slot.inUse )
			continue

		slotArray.append( slot )
	}

	Assert( slotArray.len(), "Couldn't find a free terminal slot for terminal at " + terminal.GetOrigin() )

	local guyOrigin =  guy.GetOrigin()
	local shortestDist = null
	local closestSlot

	foreach( slot in slotArray )
	{
		local id = terminal.LookupAttachment( slot.attachment )
		local slotOrigin = terminal.GetAttachmentOrigin( id )
		local dist = DistanceSqr( slotOrigin, guyOrigin )
		if ( !closestSlot || dist < shortestDist )
		{
			shortestDist = dist
			closestSlot = slot
		}
	}

	return closestSlot
}


// hack to keep the current way of doing it working.
function UsingPropDynamic( hardpoint )
{
	if ( !hardpoint.HasKey( "controlTarget" ) )
		return

	local terminal
	local entArray = GetEntArrayByNameWildCard_Expensive( hardpoint.kv.controlTarget )
	foreach( ent in entArray )
	{
		if ( ent.GetClassname() != "prop_dynamic" )
			continue
		if ( !ent.LookupAttachment( "SEAT_N" ) )
			continue

		terminal = ent
		break
	}

	if ( !terminal )
		return

	CodeWarning( "Hardpoint is setup incorrectly at " + hardpoint.GetOrigin() )

	// copy data from the prop_dynamic to the info_hardpoint
	hardpoint.kv.model = terminal.GetModelName()
	hardpoint.SetOrigin( terminal.GetOrigin() )
	hardpoint.SetAngles( terminal.GetAngles() )
	local target = terminal.kv.target

	// remove the old terminal
	terminal.Destroy()

	return target
}



//////////////////////////////////////////////////////////
function HardpointTerminal_HaveRecentEnemy( guys, terminal )
{
	if ( Time() - terminal.s.deathTimestamp < 5.0 )
		return true

	foreach( guy in guys )
	{
		if ( "lastDamageTime" in guy.s )
		{
			if ( Time() - guy.s.lastDamageTime < 5.0 )
				return true
		}

		local enemy = guy.GetEnemy()
		if ( !enemy )
			continue
		if ( guy.TimeSinceSeen( enemy ) > 5.0 )
			continue
		// this means that the npc never actually saw the enemy.
		if ( guy.TimeSinceKnown( enemy ) < guy.TimeSinceSeen( enemy ) )
			continue

		return true
	}

	return false
}



//////////////////////////////////////////////////////////
function GetSlot( guy, terminal, hardpoint )
{
	if ( terminal.s.slotsInUse >= 2 )
		return false

	if ( "terminalSlot" in guy.s )
		return false

	if ( GameRules.GetGameMode() == UPLINK && hardpoint.GetHardpointID() != level.nv.activeUplinkID )
		return false

	guy.s.terminalSlot		<- GetFreeTerminalSlot( terminal, guy )
	guy.s.terminalAnimIn	<- Random( guy.s.terminalSlot.animArrayIn )
	guy.s.terminalAnimOut	<- Random( guy.s.terminalSlot.animArrayOut )
	guy.s.terminalDeathAnim	<- Random( guy.s.terminalSlot.animArrayDeath )

	guy.s.terminalSlot.inUse = true

	thread ReleaseSlot( guy, terminal, guy.s.terminalSlot, hardpoint )

	return true
}

//////////////////////////////////////////////////////////
function ReleaseSlot( guy, terminal, terminalSlot, hardpoint )
{
	OnThreadEnd(
		function() : ( guy, terminal, terminalSlot, hardpoint )
		{
			terminal.s.slotsInUse--
			Assert( !( terminal.s.slotsInUse < 0 ) )
			terminalSlot.inUse = false
			terminalSlot.capping = false

			// update capture point since the npc no longer give capping power
			Hardpoint_Update( hardpoint )

			if ( !IsAlive( guy ) )
			{
				terminal.s.deathTimestamp = Time()
				return
			}

			delete guy.s.terminalSlot
			delete guy.s.terminalAnimIn
			delete guy.s.terminalAnimOut
			delete guy.s.terminalDeathAnim
		}
	)

	terminal.s.slotsInUse++

	guy.EndSignal( "OnDestroy" )
	guy.EndSignal( "OnDeath" )
	guy.WaitSignal( "Interrupt" )
}

//////////////////////////////////////////////////////////
function RunToSlot( guy, terminal, hardpoint, state )
{
	// can be interrupted
	guy.EndSignal( "OnDestroy" )
	guy.EndSignal( "OnDeath" )
	guy.EndSignal( "Interrupt" )

	OnThreadEnd(
		function() : ( guy )
		{
			if ( IsAlive( guy ) )
				guy.CrouchCombat( true )
		}
	)

	Assert( guy.s.terminalSlot )
	local slot = guy.s.terminalSlot
	local anim = guy.s.terminalAnimIn

	local squadName = guy.Get( "squadname" )
	local squadSize = GetNPCSquadSize( squadName )
	if ( squadSize >= 2 && state == "NOT_OWNED" )
	{
		// only try dialogue if the hardpoint isn't owned
		if ( terminal.s.slotsInUse == 1 ) // the first guy starts the conversation
			PlaySquadConversationToAll( "aichat_capturing_hardpoint", guy )
	}

	if ( anim in file.startStillList )
	{
		local result = guy.Anim_GetStartForRefEntity( anim, terminal, slot.attachment )
		local origin = result.origin
		local angles = result.angles

		guy.CrouchCombat( false )	// resets in the end thread
		SetAssaultPointValues( guy.s.assaultPoint, 512, 16, 0, 1 )
		waitthread GotoOriginCP( guy, origin, angles )
	}
	else
	{
		RunToAnimStart( guy, anim, terminal, slot.attachment )
	}


	guy.s.cpState = eNPCStateCP.AT_TERMINAL

	hardpoint.Signal( "NPCStateChange" )
}

//////////////////////////////////////////////////////////
function UseTerminal( guy, terminal, hardpoint )
{
	// not interrupted
	guy.EndSignal( "OnDeath" )
	guy.EndSignal( "OnDestroy" )

	if ( guy.ContextAction_IsActive() || guy.ContextAction_IsBusy() )
	{
		guy.s.cpState = eNPCStateCP.NONE
		return
	}

	if ( !guy.IsInterruptable() )
	{
		guy.s.cpState = eNPCStateCP.NONE
		return
	}

	if ( guy.GetParent() )
	{
		// TODO: Fancy code function to log info about how this happened...
		guy.s.cpState = eNPCStateCP.NONE
		return
	}

	local slot = guy.s.terminalSlot
	local anim = guy.s.terminalAnimIn

	terminal.s.slotsVacated = 0

	guy.ContextAction_SetBusy()
	PlayAnim( guy, anim, terminal, slot.attachment )

	SetDeathFuncName( guy, "TerminalDeathAnim" )

	// can't do this state change elsewhere, without a bunch of extra work, so this will be where it's done
	guy.s.cpState = eNPCStateCP.USING_TERMINAL
	guy.s.terminalSlot.capping = true
	thread Hardpoint_Update( hardpoint )

	thread PlayAnim( guy, "pt_console_idle", terminal, slot.attachment )

	hardpoint.Signal( "NPCStateChange" )
}

//////////////////////////////////////////////////////////
function GuyOnTerminal( hardpoint )
{
	if ( !hardpoint.GetTerminal() )
		return true

	local terminal = hardpoint.GetTerminal()
	foreach( slot in terminal.s.slotTable )
	{
		if ( slot.capping )
			return true
	}

	return false
}

//////////////////////////////////////////////////////////
function LeaveTerminal( guy, terminal, hardpoint )
{
	// not interrupted
	guy.EndSignal( "OnDeath" )
	guy.EndSignal( "OnDestroy" )

	local slot = guy.s.terminalSlot
	local anim = guy.s.terminalAnimOut
	terminal.s.slotsVacated++

	// update capture point since the npc no longer give capping power
	Hardpoint_Update( hardpoint )

	waitthread LeaveTerminalWait( guy, hardpoint )

	PlayAnim( guy, anim, terminal, slot.attachment )

	guy.ContextAction_ClearBusy()
	ClearDeathFuncName( guy )

	guy.s.cpState = eNPCStateCP.NONE
	guy.Signal( "Interrupt" )	// release the terminal slot
	hardpoint.Signal( "NPCStateChange" )
}

function TerminalCapturedChatter( guy, terminal, team )
{
	guy.EndSignal( "OnDeath" )
	guy.EndSignal( "OnDestroy" )
	guy.EndSignal( "OnFoundEnemy" )
	guy.EndSignal( "OnSeeEnemy" )	// temp signal from script when an enemy is sighted
	guy.EndSignal( "OnDamaged" )

	// stops capture dialog from being played more the once per capture event
	terminal.s.captureDialogue[ team ] = true

	// wait a while so that dialogs doesn't overlap.
	wait RandomFloat( 4.0, 6.0 )

	// might be possible for the point to be lost while waiting, so lets not talk unless still captured
	if ( terminal.s.captureDialogue[ team ] )
	{
		PlaySquadConversationToAll( "aichat_captured_hardpoint", guy )
	}
}


function LeaveTerminalWait( guy, hardpoint )
{
	guy.EndSignal( "OnDeath" )
	guy.EndSignal( "OnDestroy" )
	guy.EndSignal( "OnFoundEnemy" )
	guy.EndSignal( "OnSeeEnemy" )	// temp signal from script when an enemy is sighted
	guy.EndSignal( "OnDamaged" )
	hardpoint.EndSignal( "NPCStateChange" )

	wait RandomFloat( 0, 0.5 )
}

//////////////////////////////////////////////////////////
function ConvergeAtTerminal( guy, hardpoint )
{
	// can be interrupted
	guy.EndSignal( "OnDestroy" )
	guy.EndSignal( "OnDeath" )
	guy.EndSignal( "Interrupt" )

	local terminal = hardpoint.GetTerminal()
	local team = guy.GetTeam()
	local assaultPoint

	ArrayRandomize( terminal.s.nodeArray )

	foreach( point in terminal.s.nodeArray )
	{
		/*
			having to claim nodes is stupid.
			we need to be able to send ai to an area and have them use available cover nodes
		*/

		if ( !( "claimTable" in point.s ) )
			point.s.claimTable <- { [TEAM_IMC] = 0, [TEAM_MILITIA] = 0 }

		if ( point.s.claimTable[ team ] != 0 )
			continue

		point.s.claimTable[ team ] = 1
		assaultPoint = point
		break
	}

	// TEMP FIX
	if ( !assaultPoint )
		return

	Assert( assaultPoint )

	OnThreadEnd(
		function() : ( guy, team, assaultPoint )
		{
			// releasing the assault point here might cause stacking since the guy isn't moving away from the spot
			// if we get a GoToRadius function claiming nodes shouldn't be needed. It will be in code, where it belongs.
			assaultPoint.s.claimTable[ team ] = 0
//			if ( IsAlive( guy ) )
//				guy.DisableBehavior( "assault" )
		}
	)

	local origin = assaultPoint.GetOrigin()
	local angles = assaultPoint.GetAngles()
	SetAssaultPointValues( guy.s.assaultPoint, 512, 128, 1, 1 )
	waitthread GotoOriginCP( guy, origin, angles )

	// delay the change of state a bit to make it look more natural
	wait RandomFloat( 1, 3 )

	guy.s.cpState = eNPCStateCP.AT_POINT
	hardpoint.Signal( "NPCStateChange" )
}

//////////////////////////////////////////////////////////
function NPCBusyAtHardpoint( npc )
{
	if ( !( "cpState" in npc.s ) )
		return false

	// is the npc busy interacting with the hardpoint terminal
	if ( npc.s.cpState == eNPCStateCP.MOVING_TO_TERMINAL )
		return true
	if ( npc.s.cpState == eNPCStateCP.AT_TERMINAL )
		return true
	if ( npc.s.cpState == eNPCStateCP.SITTING_DOWN )
		return true
	if ( npc.s.cpState == eNPCStateCP.USING_TERMINAL )
		return true
	if ( npc.s.cpState == eNPCStateCP.STANDING_UP )
		return true

	return false
}

function Hardpoint_Update( hardpoint )
{
	if ( GetGameState() != eGameState.Playing )
		return

	UpdateHardpointCount( hardpoint )

	file.hardpointUpdateFunc( hardpoint )
}



function GotoOriginCP( guy, origin, angles = null )
{
	Assert( IsAlive( guy ) )

	guy.Signal( "EndGoto" )

	guy.EndSignal( "EndGoto" )
	guy.EndSignal( "OnDeath" )
	guy.EndSignal( "OnDestroy" )

	local assaultPoint = guy.s.assaultPoint

	assaultPoint.SetOrigin( origin )

	if ( angles )
	{
		assaultPoint.kv.faceAssaultPointAngles = 1
		assaultPoint.SetAngles( angles )
	}

	guy.AssaultPointEnt( assaultPoint )
/*
	DebugDrawLine( origin, origin + Vector( 0,0,64), 255, 0, 128, true, 20 )
	if ( angles )
		DebugDrawLine( origin + Vector( 0,0,64), origin + Vector( 0,0,64) + angles.AnglesToForward() * 32, 128, 0, 255, true, 20 )
*/
	guy.WaitSignal( "OnFinishedAssault" )
}

function TerminalDeathAnim( guy )
{
	Assert( "terminalDeathAnim" in guy.s )
	guy.Anim_Play( guy.s.terminalDeathAnim )
	WaitSignalOnDeadEnt( guy, "OnAnimationDone" )
	guy.BecomeRagdoll( Vector( 0, 0, 0 ) )
}


//////////////////////////////////////////////////////////
function SetAssaultPointValues( point, stopToFightRadius = 800, radius = 512, strict = 0, neverTimeout = 1 )
{
	point.kv.stopToFightEnemyRadius = stopToFightRadius
	point.kv.allowdiversionradius = 0
	point.kv.allowdiversion = 1
	point.kv.faceAssaultPointAngles = 0
	point.kv.assaulttolerance = 120
	point.kv.nevertimeout = neverTimeout	// set to 0 to clear assault on reaching assaultpoint
	point.kv.strict = strict
	point.kv.forcecrouch = 0
	point.kv.spawnflags = 0
	point.kv.clearoncontact = 0
	point.kv.assaulttimeout = 3.0
	point.kv.arrivaltolerance = radius
}



//////////////////////////////////////////////////////////
function SquadCapturePointThink( squadName, capturepoint, team )
{
	local signalString = "SquadCapturePointThink"
	signalString += team == TEAM_MILITIA ? "_TEAM_MILITIA" : "_TEAM_IMC"

	capturepoint.Signal( signalString )
	capturepoint.EndSignal( signalString )

	if ( !GetNPCSquadSize( squadName ) )
		return

	// this should go away once all capturepoints have terminals
	if ( !capturepoint.GetTerminal() || GameRules.GetGameMode() == UPLINK )
	{
		// in cases where we don't have a terminal fall back to assaulting hardpoints old style.
		SquadAssaultHardpoint( squadName, capturepoint )
		return
	}

	local terminal = capturepoint.GetTerminal()
	local signalTable = {}

	while ( true )
	{
		local guys = GetNPCArrayBySquad( squadName )
		ArrayRemoveDead( guys )	// shouldn't have to do this
		guys = ArrayClosest( guys, terminal.GetOrigin() )

		local state = GetCapturePointThinkState( capturepoint, team, guys )

		switch ( state )
		{
			case "OWNED":
				// spread out or stay where we are if we're already spread out.
				foreach( guy in guys )
				{
					switch( guy.s.cpState )
					{
						case eNPCStateCP.AT_TERMINAL:
							// sit down
							guy.s.cpState = eNPCStateCP.SITTING_DOWN
							thread UseTerminal( guy, terminal, capturepoint )
							break
						case eNPCStateCP.NONE:
						case eNPCStateCP.CONVERGE:
						case eNPCStateCP.AT_POINT:
							if( terminal.s.slotsInUse == 0 )
							{
								guy.Signal( "Interrupt" )
								// if terminal is empty set a guy to use it
								local foundSlot = GetSlot( guy, terminal, capturepoint )
								if ( foundSlot )
								{
									guy.s.cpState = eNPCStateCP.MOVING_TO_TERMINAL
									thread RunToSlot( guy, terminal, capturepoint, state )
								}
								break
							}
							else
							{
								// change state to spread_out
								// assault hardpoint old style
								guy.s.cpState = eNPCStateCP.SPREAD_OUT
								guy.Signal( "Interrupt" )
								thread AssaultHardpoint( guy, capturepoint )
								break
							}
						case eNPCStateCP.USING_TERMINAL:
							// change state to standing_up
							// stand up <- changes state to none when done?
							// one guy will stay on the terminal until enemies show up
							if( terminal.s.slotsVacated == 0 && terminal.s.slotsInUse == 2 )
							{
								guy.s.cpState = eNPCStateCP.STANDING_UP
								thread LeaveTerminal( guy, terminal, capturepoint )
							}
							else if ( !terminal.s.captureDialogue[ team ] )
							{
								thread TerminalCapturedChatter( guy, terminal, team )
							}
							break
						case eNPCStateCP.MOVING_TO_TERMINAL:
						case eNPCStateCP.SITTING_DOWN:
						case eNPCStateCP.STANDING_UP:
							// do nothing, transitional events
							break
						case eNPCStateCP.SPREAD_OUT:
							// do nothing, this is the state we strive for
							break
					}
				}
				break
			case "NOT_OWNED":
				// allow capture dialog to be played again
				terminal.s.captureDialogue[ team ] = false
				// converge on point if not at point or converging already
				// sit and capture point if at point and seat is available
				foreach( guy in guys )
				{
					switch( guy.s.cpState )
					{
						case eNPCStateCP.AT_POINT:
							// run to seat <- changes state to at_terminal when done
							local foundSlot = GetSlot( guy, terminal, capturepoint )
							if ( foundSlot )
							{
								guy.s.cpState = eNPCStateCP.MOVING_TO_TERMINAL
								thread RunToSlot( guy, terminal, capturepoint, state )
							}
							break
						case eNPCStateCP.AT_TERMINAL:
							// change state to sitting_down
							// sit down and idle <- changes state to using_terminal when done (before idle)
							guy.s.cpState = eNPCStateCP.SITTING_DOWN
							thread UseTerminal( guy, terminal, capturepoint )
							break
						case eNPCStateCP.NONE:
						case eNPCStateCP.SPREAD_OUT:
							// change state to converge
							// abort spread out action
							// run to assault node, converge <- changes state to at_point when done
							guy.s.cpState = eNPCStateCP.CONVERGE
							guy.Signal( "Interrupt" )
							guy.Signal( "StopHardpointBehavior" )
							thread ConvergeAtTerminal( guy, capturepoint )
							break
						case eNPCStateCP.MOVING_TO_TERMINAL:
						case eNPCStateCP.SITTING_DOWN:
						case eNPCStateCP.STANDING_UP:
						case eNPCStateCP.CONVERGE:
							// do nothing, transitional events
							break
						case eNPCStateCP.USING_TERMINAL:
							// do nothing, these are the states we strive for
							break
					}
				}
				break
			case "CONTESTED":
				// converge on point if not at point
				// stand up and fight if sitting/capturing
				foreach( guy in guys )
				{
					switch( guy.s.cpState )
					{
						case eNPCStateCP.USING_TERMINAL:
							// change state to standing_up
							// stand up <- changes state to none when done?
							guy.s.cpState = eNPCStateCP.STANDING_UP
							thread LeaveTerminal( guy, terminal, capturepoint )
							break
						case eNPCStateCP.NONE:
						case eNPCStateCP.AT_TERMINAL:
						case eNPCStateCP.SPREAD_OUT:
							// change state to converge
							// guy.Signal( "StopHardpointBehavior" )	// abort spread out action
							// run to assault node, converge <- changes state to at_point when done
							guy.s.cpState = eNPCStateCP.CONVERGE
							guy.Signal( "Interrupt" )
							guy.Signal( "StopHardpointBehavior" )
							thread ConvergeAtTerminal( guy, capturepoint )
						case eNPCStateCP.MOVING_TO_TERMINAL:
						case eNPCStateCP.SITTING_DOWN:
						case eNPCStateCP.STANDING_UP:
						case eNPCStateCP.CONVERGE:
							// do nothing, transitional events
							break
						case eNPCStateCP.AT_POINT:
							// do nothing, this is the state we strive for
							break
					}
				}
				break
			default:
				break
		}

		waitthread WaitForUpdate( capturepoint, guys, state )
//		printt( "Wait ended" )
	}
}

//////////////////////////////////////////////////////////
function GetCapturePointThinkState( capturepoint, team, guys )
{
//		OWNED is when it's owned by the own team
//		NOT_OWNED is when it's not owned by other team and not contested
//		CONTESTED is when both team have forces in the hardpoint

	local powerTable = GetCapPower( capturepoint )
	local otherTeam = team == TEAM_IMC ? TEAM_MILITIA : TEAM_IMC
	local pointTeam = capturepoint.GetTeam()
	local strongerTeam = powerTable.strongerTeam

	if ( powerTable.contested || HardpointTerminal_HaveRecentEnemy( guys, capturepoint.GetTerminal() ) || powerTable.strongerTeam == otherTeam )
		return "CONTESTED"

	if ( pointTeam == team )
		return "OWNED"

	return "NOT_OWNED"
}


//////////////////////////////////////////////////////////
function WaitForUpdate( capturepoint, guys, state )
{
	capturepoint.EndSignal( "NPCStateChange" )
	capturepoint.EndSignal( "CapturePointStateChange" )
	capturepoint.EndSignal( "CapturePointUpdate" )

	foreach( guy in guys )
	{
		guy.EndSignal( "OnDestroy" )
		guy.EndSignal( "OnDeath" )
		guy.EndSignal( "OnFoundEnemy" )
		guy.EndSignal( "OnSeeEnemy" )
		guy.EndSignal( "OnDamaged" )
	}

	if ( state == "CONTESTED" )
	{
		wait 1.0 // check the state periodically in case we haven't seen the enemy in a while.
	}
	else
	{
		WaitForever()
	}
}


//////////////////////////////////////////////////////////
function GetNumHardpointsControlledByTeam( team )
{
	local count = 0
	foreach( i, capturepoint in level.hardpoints )
	{
		if ( capturepoint.GetTeam() == team )
			count++
	}
	return count
}



function AddHardpointTeamSwitchCallback( hardpoint, callbackFunc )
{
	Assert( "teamSwitchCallbacks" in hardpoint.s )
	Assert( type( this ) == "table", "AddHardpointTeamSwitchCallback can only be added on a table. " + type( this ) )
	AssertParameters( callbackFunc, 2, "hardpoint, team" )

	local callbackInfo = {}
	callbackInfo.func <- callbackFunc
	callbackInfo.scope <- this

	hardpoint.s.teamSwitchCallbacks.append( callbackInfo )
}



function HardpointTeamChange( hardpoint, team, silent = false )
{
	// Change the hardpoint team and notify all players
	local previousTeam = hardpoint.GetTeam()

	if ( team == previousTeam )
		return

	if ( previousTeam != TEAM_UNASSIGNED )
		hardpoint.s.previousOwner = hardpoint.GetTeam()

	hardpoint.SetTeam( team )

	local terminal = hardpoint.GetTerminal()
	if ( terminal )
	{
		local lastTeam = terminal.GetTeam()
		terminal.SetTeam( team )

		StopSoundOnEntity( terminal, "hardpoint_console_idle" )
		if ( lastTeam != TEAM_UNASSIGNED && team == TEAM_UNASSIGNED && !silent )
		{
			EmitSoundOnEntity( terminal, "hardpoint_console_nuetral" )
		}
		else if ( team != TEAM_UNASSIGNED && !silent )
		{
			EmitSoundOnEntity( terminal, "hardpoint_console_captured" )
			EmitSoundOnEntity( terminal, "hardpoint_console_idle" )
		}
	}

	//update the turrets we need to get them each time because they are deleted and remade
	if ( hardpoint.HasKey( "turretTarget" ) )
		HardpointTurretsChangedTeam( hardpoint, team )

	//update the spectres
	if ( hardpoint.HasKey( "spectreTarget" ) && hardpoint.kv.spectreTarget != null )
		HardpointSpectresChangedTeam( hardpoint, team )

//	Use AddHardpointTeamSwitchCallback( hardpoint, callbackFunc ) to add
		foreach ( callbackInfo in hardpoint.s.teamSwitchCallbacks )
			callbackInfo.func.acall( [ callbackInfo.scope, hardpoint, previousTeam ] )

	//Disabling control panels associated with hardpoints for now Re-examine if needed later
	//update the control panels
	/*if ( hardpoint.HasKey( "panelTarget" ) && hardpoint.kv.panelTarget != null )
		HardpointControlPanelsChangedTeam( hardpoint, team )*/

	UpdateHardpointTurret( hardpoint )
}
// tmp until cleanup is done
Globalize( HardpointTeamChange )




function LinkTurretWithHardpoint( hardpoint, turret, team )
{
	Assert( IsValid( hardpoint ) )
	Assert( hardpoint.GetClassname() == "info_hardpoint" )
	Assert( IsValid( turret ) )
	Assert( team == TEAM_IMC || team == TEAM_MILITIA )
	Assert( !( "linkedMegaTurret" in hardpoint.s ) )
	Assert( !( "linkedMegaTurretTeam" in hardpoint.s ) )

	turret.Minimap_Hide( TEAM_IMC, null )
	turret.Minimap_Hide( TEAM_MILITIA, null )

	hardpoint.s.linkedMegaTurret <- turret
	hardpoint.s.linkedMegaTurretTeam <- team

	HardpointTurretDeactivate( turret )
}

function LinkTargetToHardpointTurrets( target, lastKnownPosition )
{
	Assert( IsValid( target ) )
	local hardpointArray = GetEntArrayByClass_Expensive( "info_hardpoint" )
	foreach( hardpoint in hardpointArray )
	{
		if ( !( "linkedMegaTurretTarget" in hardpoint.s ) )
			hardpoint.s.linkedMegaTurretTarget <- null
		hardpoint.s.linkedMegaTurretTarget = target

		hardpoint.s.linkedMegaTurret.SetEnemy( target )
		hardpoint.s.linkedMegaTurret.SetEnemyLKP( target, lastKnownPosition )
		hardpoint.s.linkedMegaTurret.Fire( "UpdateEnemyMemory", target.GetName() )
	}
}

function UpdateHardpointTurret( hardpoint )
{
	if ( !( "linkedMegaTurret" in hardpoint.s ) )
		return

	local turret = hardpoint.s.linkedMegaTurret
	Assert( IsValid( turret ) )
	local hardpointTeam = hardpoint.GetTeam()

	if ( hardpointTeam == hardpoint.s.linkedMegaTurretTeam )
	{
		local turretTarget = null
		if ( "linkedMegaTurretTarget" in hardpoint.s )
			turretTarget = hardpoint.s.linkedMegaTurretTarget
		thread HardpointTurretActivate( hardpoint.s.linkedMegaTurret, hardpointTeam, turretTarget )
	}
	else
		thread HardpointTurretDeactivate( turret )
}

function HardpointTurretsChangedTeam( hardpoint, team )
{
	for ( local i = 0; i < hardpoint.s.turrets.len(); i++ )
	{
		local turret = hardpoint.s.turrets[ i ]

		// spawn replacement turret if old one is dead.
		if ( !IsAlive( turret ) )
		{
			turret = SpawnReplacementTurret( turret )
			hardpoint.s.turrets[ i ] = turret
		}

		TurretChangeTeam( turret, team )
		if ( team == TEAM_UNASSIGNED )
			turret.DisableTurret()
		else
			turret.EnableTurret()
	}
}

function HardpointControlPanelsChangedTeam( hardpoint, team )
{
	//Disabling control panels associated with hardpoints for now Re-examine if needed later
	return

	local panels = hardpoint.s.panels

	foreach( panel in panels )
	{
		if ( !IsValid( panel ) )
			continue

		PanelSetTeam( panel, team )
		if ( team == TEAM_UNASSIGNED )
			ReleasePanel( panel )
		else
			EnablePanel( panel )

		UpdatePanelState( panel )
	}
}
