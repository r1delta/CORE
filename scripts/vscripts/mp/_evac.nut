const EVAC_ARRIVE_ANIM	= "cd_dropship_rescue_side_start"
const EVAC_IDLE_ANIM 	= "cd_dropship_rescue_side_idle"
const EVAC_LEAVE_ANIM 	= "cd_dropship_rescue_side_end"
const EVAC_SPACE_ANIM 	= "ds_space_flyby_dropshipA"

const EVAC_DROPSHIP_SHIELD_HEALTH = 22000
const EVAC_DROPSHIP_HEALTH = 15000
const EVAC_TRIGGER_RADIUS = 120
const EVAC_PROXIMITY_VDU_RADIUS = 400
const EVAC_SHIP_DAMAGE_MULTIPLIER_AGAINST_CLUSTER_ROCKET = 0.6
const EVAC_PREVENT_TITANFALL_RADIUS = 600

const EVAC_MINIMAP_ICON_FRIENDLY = "vgui/HUD/minimap_evac_location_friendly"
const EVAC_MINIMAP_ICON_ENEMY = "vgui/HUD/minimap_evac_location_enemy"
Minimap_PrecacheMaterial( EVAC_MINIMAP_ICON_FRIENDLY )
Minimap_PrecacheMaterial( EVAC_MINIMAP_ICON_ENEMY )


function main()
{
	//Commented out defensively. See bug 66889
	/*if ( !EvacEnabled() )
		return*/

	IncludeFile( "_evac_shared" )

	level.ExtractLocations <- {}
	level.SelectedExtractLocationIndex <- null

	Globalize( Evac_SetEvacTeam )
	Globalize( Evac_SetEvacNode )
	Globalize( Evac_SetSpaceNode )
	Globalize( Evac_SetRoundEndSetupFunc )

	Globalize( Evac_SetVDUEvacNag )
	Globalize( Evac_SetVDUPursuitNag )
	Globalize( Evac_SetVDUEvacProximity )
	Globalize( Evac_SetVDUPursuitProximity )
	Globalize( Evac_SetVDUEvacDustOff )
	Globalize( Evac_SetVDUPursuitDustOff )
	Globalize( Evac_SetVDULosersEvacPostEvac ) //ToDo: Rename this function. Name is left over from when you could pick either winning or losing team to evac
	Globalize( Evac_SetVDULosersEvacPostPursuit )  //ToDo: Rename this function. Name is left over from when you could pick either winning or losing team to evac
	Globalize( Evac_SetupDefaultVDUs )
	Globalize( Evac_GetPostEvacDialogueTime )
	Globalize( Evac_SetPostEvacDialogueTime )
	Globalize( Evac_GetDropshipArrivalWaitTime )
	Globalize( Evac_SetDropshipArrivalWaitTime )
	Globalize( Evac_CreateAnimPackage )
	Globalize( Evac_SetEvacTeamOverride )

	Globalize( Evac_SetCustomDropshipFunc )
	Globalize( Evac_AddLocation )
	Globalize( EvacShipTrigger )

	Globalize( GetNumberOfPursuitPlayersAlive )
	Globalize( GetNumberOfEvacPlayersAlive )
	Globalize( IsPlayerOnEvacDropship )
	Globalize( DecideDepartureAnnouncement ) //Globalized because it's called from DropshipPilotAnnouncesDeparture, which is in turn called from cinematic system

	level.evacTeam 			<- null
	level.pursuitTeam			<- null
	level.playersOnDropship     <- {}
	level.evacNode	 		<- null
	level.evacShipIcon      <- null
	level.evacSpaceNode 	<- null
	level.dropship <- null
	level.evacEnabled <- true
	level.evacTeamOverride <- null

	level.evacRoundEndFunc		 <- null
	level.evacCustomDropshipFunc <- null

	level.arrivalAnimStartTime 		<- null
	level.departureAnimStartTime	<- null
	level.evacProximityVDU	<- []

	level.postEvacDialogueTime <- 4.0
	level.dropshipArrivalWaitTime <- EVAC_SHIP_ARRIVE_WAIT

	level.evacVDU <- {}
	level.evacVDU[ TEAM_MILITIA ] <- {}
	level.evacVDU[ TEAM_MILITIA ].losersEvacPostEvac 			<- null
	level.evacVDU[ TEAM_MILITIA ].losersEvacPostPursuit			<- null
	level.evacVDU[ TEAM_MILITIA ].evacNag 						<- null
	level.evacVDU[ TEAM_MILITIA ].evacProximity					<- null
	level.evacVDU[ TEAM_MILITIA ].evacDustOff 					<- null
	level.evacVDU[ TEAM_MILITIA ].pursuitNag 					<- null
	level.evacVDU[ TEAM_MILITIA ].pursuitProximity				<- null
	level.evacVDU[ TEAM_MILITIA ].pursuitDustOff 				<- null

	level.evacVDU[ TEAM_IMC ] <- {}
	level.evacVDU[ TEAM_IMC ].losersEvacPostEvac 			<- null
	level.evacVDU[ TEAM_IMC ].losersEvacPostPursuit			<- null
	level.evacVDU[ TEAM_IMC ].evacNag 						<- null
	level.evacVDU[ TEAM_IMC ].evacProximity					<- null
	level.evacVDU[ TEAM_IMC ].evacDustOff 					<- null
	level.evacVDU[ TEAM_IMC ].pursuitNag 					<- null
	level.evacVDU[ TEAM_IMC ].pursuitProximity				<- null
	level.evacVDU[ TEAM_IMC ].pursuitDustOff 				<- null

	FlagInit( "EvacAnimStart" )
	FlagInit( "EvacShipArrive" )
	FlagInit( "EvacShipLeave" )
	FlagInit( "EvacFinished" )
	FlagInit( "PlayPostEvacDialogue" )
	FlagInit( "EvacKillProximityConversationThread" )
	FlagInit( "EvacEndsMatch", true )

	RegisterSignal( "EvacCancelled" )
	RegisterSignal( "EvacDropship" )

	RAGDOLL_IMPACT_TABLE_IDX <- PrecacheImpactEffectTable( "ragdoll_human" )

	RegisterSignal( "sRampOpen" )
	RegisterSignal( "sRampClose" )

	EvacShipEventsInit()

	//GM_AddEndGameFunc( EvacMain )
	Globalize( EvacMain )
	Globalize( ExfiltrationEvacMain )
}

function Evac_SetCustomDropshipFunc( func )
{
	level.evacCustomDropshipFunc = func
}

function Evac_SetEvacTeam( team )
{
	printt( "The team is: " + team )
	Assert(
		team == TEAM_IMC ||
		team == TEAM_MILITIA
	)

	level.evacTeam = team

	switch ( team )
	{
		case TEAM_IMC:
			level.pursuitTeam = TEAM_MILITIA
			break
		case TEAM_MILITIA:
			level.pursuitTeam = TEAM_IMC
			break
	}
}

function Evac_SetVDUEvacNag( team, vdu )
{
	level.evacVDU[ team ].evacNag = vdu
}

function Evac_SetVDUPursuitNag( team, vdu )
{
	level.evacVDU[ team ].pursuitNag = vdu
}

function Evac_SetVDUEvacProximity( team, vdu )
{
	level.evacVDU[ team ].evacProximity = vdu
}

function Evac_SetVDUPursuitProximity( team, vdu )
{
	level.evacVDU[ team ].pursuitProximity = vdu
}

function Evac_SetVDUEvacDustOff( team, vdu )
{
	level.evacVDU[ team ].evacDustOff = vdu
}

function Evac_SetVDUPursuitDustOff( team, vdu )
{
	level.evacVDU[ team ].pursuitDustOff = vdu
}

function Evac_SetVDULosersEvacPostEvac( team, vdu )
{
	level.evacVDU[ team ].losersEvacPostEvac = vdu

}

function Evac_SetVDULosersEvacPostPursuit( team, vdu )
{
	level.evacVDU[ team ].losersEvacPostPursuit = vdu

}

function Evac_SetEvacNode( node )
{
	// Only call this function if you want to set a specific evac node. Not calling this function will cause a random node to be used
	level.evacNode = node
}

function Evac_SetSpaceNode( node )
{
	level.evacSpaceNode = node
}

function Evac_GetPostEvacDialogueTime()
{
	return level.postEvacDialogueTime
}

function Evac_SetPostEvacDialogueTime( time )
{
	level.postEvacDialogueTime = time
}

function Evac_SetDropshipArrivalWaitTime( time )
{
	level.dropshipArrivalWaitTime = time
}

function Evac_GetDropshipArrivalWaitTime()
{
	return level.dropshipArrivalWaitTime
}

function Evac_CreateAnimPackage( arriveAnim, idleAnim, leaveAnim )
{
	local animPackage = {}
	animPackage.arriveAnim <- arriveAnim
	animPackage.idleAnim <- idleAnim
	animPackage.leaveAnim <- leaveAnim

	return animPackage
}

// if you need to init stuff at the end of the round but before evac runs, do it with this function
function Evac_SetRoundEndSetupFunc( callbackFunc )
{
	Assert( "evacRoundEndFunc" in level )
	Assert( type( this ) == "table", "Evac_SetRoundEndFunc can only be added on a table. " + type( this ) )
	AssertParameters( callbackFunc, 0, "" )

	local name = FunctionToString( callbackFunc )
	local callbackInfo = {}
	callbackInfo.name <- name
	callbackInfo.func <- callbackFunc
	callbackInfo.scope <- this

	level.evacRoundEndFunc = callbackInfo
}


function ExfiltrationEvacMain( chaseTeam, escapeNode )
{
	/*
	if ( level.isTestmap )
	{
		if ( !level.evacNode )
		{
			printt( "Warning: No Evac Node Set up! Returning" )
			return
		}

		if ( !level.evacSpaceNode )
		{
			printt( "Warning: No Space Node Set up! Returning" )
			return
		}
	}
	*/

	if ( escapeNode )
		level.evacNode = escapeNode

	local evacTeam = GetOtherTeam( chaseTeam )

	Evac_SetEvacTeam( evacTeam )

	if ( level.evacRoundEndFunc )
	{
		local callbackInfo = level.evacRoundEndFunc
		callbackInfo.func.acall( [ callbackInfo.scope ] )
	}

	Assert( level.evacNode, "level.evacNode not set, call Evac_SetEvacNode( node ) to specify an evac point" )
	Assert( level.evacSpaceNode, "level.evacSpaceNode not set, call Evac_SetSpaceNode( node ) to specify point dropship will warp to" )

	local scriptRef = CreateEvacShipIcon( level.evacNode )
	level.evacShipIcon = scriptRef

	wait 1.0 // delay long enough for the scriptRef to get to the client... because retarded.
	if ( !GamePlayingOrSuddenDeath() )
	{
		level.evacShipIcon.Destroy()
		return
	}

	thread EvacShipInit( level.evacNode )

	thread EvacObjective( level.evacTeam )
	thread EvacVDU( level.evacTeam, chaseTeam )

	thread EvacShipMain()

	level.ent.WaitSignal( "GameStateChange" )

	FlagSet( "EvacFinished" )
	level.ent.Signal( "EvacCancelled" )

	level.evacShipIcon.Destroy()
}

function EvacOnDemand( chaseTeam, dropshipHealth = null, shieldHealth = null )
{
	/*
	if ( level.isTestmap )
	{
		if ( !level.evacNode )
		{
			printt( "Warning: No Evac Node Set up! Returning" )
			return
		}

		if ( !level.evacSpaceNode )
		{
			printt( "Warning: No Space Node Set up! Returning" )
			return
		}

	}
	*/

	if ( chaseTeam == TEAM_UNASSIGNED )
		return

	FlagClear( "EvacAnimStart" )
	FlagClear( "EvacShipArrive" )
	FlagClear( "EvacShipLeave" )
	FlagClear( "EvacFinished" )
	FlagClear( "PlayPostEvacDialogue" )
	FlagClear( "EvacKillProximityConversationThread" )

	FlagEnd( "EvacFinished" )

	local evacTeam = GetOtherTeam(chaseTeam)
	printt( "evacTeam is " + evacTeam + " attacking team is " + level.nv.attackingTeam )

	Evac_SetEvacTeam( evacTeam )

	if ( level.evacRoundEndFunc )
	{
		local callbackInfo = level.evacRoundEndFunc
		callbackInfo.func.acall( [ callbackInfo.scope ] )
	}

	local evacNode = level.evacNode

	Assert( evacNode, "level.evacNode not set, call Evac_SetEvacNode( node ) to specify an evac point" )
	Assert( level.evacSpaceNode, "level.evacSpaceNode not set, call Evac_SetSpaceNode( node ) to specify point dropship will warp to" )

	local scriptRef = CreateEvacShipIcon( evacNode )
	level.evacShipIcon = scriptRef

	DisableTitanfallForLifetimeOfEntityNearOrigin( evacNode, evacNode.GetOrigin(), EVAC_PREVENT_TITANFALL_RADIUS  )

	AddDeathCallback( "player", OnPlayerDeath )
	thread MonitorPlayers()

	OnThreadEnd(
		function() : ()
		{
			HideEvacShipIconOnMinimap()
		}
	)

	wait 1.5

	//Disable NPC spawning once we are in evac
	if ( level.evacTeam == TEAM_IMC )
		FlagSet( "Disable_IMC" )		// no random ai spawning
	else if ( level.evacTeam == TEAM_MILITIA )
		FlagSet( "Disable_MILITIA" )	// no random ai spawning

	thread EvacShipInit( evacNode )

	thread EvacObjective( level.evacTeam )
	thread EvacVDU( level.evacTeam, chaseTeam )

	thread EvacShipMain( dropshipHealth, shieldHealth )

	WaitForever() //Mainly to structure it so we clean up the EvacShipIcon properly in case evac gets interrupted
}
Globalize( EvacOnDemand )

function EvacMain( chaseTeam ) //TODO: After doing some work on One Flag CTF and EvacOnDemand, it's apparent there's some subtle bugs with EvacMain that are hidden by the 10s grace respawn period given by regular Evac. Should look at this again and make sure it can be interrupted gracefully.
{
	printt( "EvacMain" )
	/*
	if ( level.isTestmap )
	{
		if ( !level.evacNode )
		{
			printt( "Warning: No Evac Node Set up! Returning" )
			return
		}

		if ( !level.evacSpaceNode )
		{
			printt( "Warning: No Space Node Set up! Returning" )
			return
		}

	}
	*/

	if ( level.evacTeamOverride )
		chaseTeam = GetOtherTeam( level.evacTeamOverride )

	if (chaseTeam == TEAM_UNASSIGNED )
		return

	local evacTeam = GetOtherTeam(chaseTeam)

	if ( level.evacTeam == null )
	{
		printt( "EvacMain: evacTeam is null" )
		Evac_SetEvacTeam( evacTeam )
	}

	if ( !GetCurrentPlaylistVarInt( "run_evac", 0 ) ) //For dev use: don't end out of evac early
	{
		if ( EvacModeShouldEnd() )
			return
	}

	if ( level.evacRoundEndFunc )
	{
		local callbackInfo = level.evacRoundEndFunc
		callbackInfo.func.acall( [ callbackInfo.scope ] )
	}

	local evacNode = level.evacNode

	Assert( evacNode, "level.evacNode not set, call Evac_SetEvacNode( node ) to specify an evac point" )
	Assert( level.evacSpaceNode, "level.evacSpaceNode not set, call Evac_SetSpaceNode( node ) to specify point dropship will warp to" )

	local scriptRef = CreateEvacShipIcon( evacNode )
	level.evacShipIcon = scriptRef

	printt( "Later on in the call" )

	DisableTitanfallForLifetimeOfEntityNearOrigin( evacNode, evacNode.GetOrigin(), EVAC_PREVENT_TITANFALL_RADIUS  )

	wait GetEvacStartDelay()

	//Disable NPC spawning once we are in evac
	if ( level.evacTeam == TEAM_IMC )
		FlagSet( "Disable_IMC" )		// no random ai spawning
	else if ( level.evacTeam == TEAM_MILITIA )
		FlagSet( "Disable_MILITIA" )	// no random ai spawning

	thread EvacShipInit( evacNode )

	thread EvacObjective( level.evacTeam )
	thread EvacVDU( level.evacTeam, GetTeamIndex(chaseTeam))

	AddDeathCallback( "player", OnPlayerDeath )
	thread MonitorPlayers()

	thread EvacShipMain()
}


function EvacObjective( evacTeam )
{
	local pursuitTeam = GetOtherTeam( evacTeam )

	FlagEnd( "EvacFinished" )

	local timeThatDropshipArrives = Time() + Evac_GetDropshipArrivalWaitTime()

	if ( GameRules.GetGameMode()  == HEIST )
	{
		// 탈출 팀만 수송선 아이콘 표시
		level.evacShipIcon.Minimap_AlwaysShow( level.evacTeam, null )
		SetTeamActiveObjective( evacTeam, "EG_DropshipExtract", timeThatDropshipArrives,  level.evacShipIcon )
		SetTeamActiveObjective( pursuitTeam, "EG_StopExtract", timeThatDropshipArrives,  null )
	}
	else
	{
		ShowEvacShipIconOnMinimap()
		SetTeamActiveObjective( evacTeam, "EG_DropshipExtract", timeThatDropshipArrives,  level.evacShipIcon )
		SetTeamActiveObjective( pursuitTeam, "EG_StopExtract", timeThatDropshipArrives,  level.evacShipIcon )
	}

	if ( GameRules.GetGameMode()  == HEIST )
	{	// 3초 빨리 미니맵에 표시
		wait Evac_GetDropshipArrivalWaitTime() - 3.0
	}
	else
	{
		wait Evac_GetDropshipArrivalWaitTime()
	}

	if ( GameRules.GetGameMode()  == HEIST )
	{
		// 공격팀도 미니 맵에 표시
		level.evacShipIcon.Minimap_AlwaysShow( level.pursuitTeam, null )
	}

	local timeThatDropshipTakesOff =  Time() + EVAC_SHIP_IDLE_TIME

	SetTeamActiveObjective( evacTeam, "EG_DropshipExtract2", timeThatDropshipTakesOff,  level.evacShipIcon )
	SetTeamActiveObjective( pursuitTeam, "EG_StopExtract2", timeThatDropshipTakesOff,  level.dropship )

	wait EVAC_SHIP_IDLE_TIME

	// anything to do here?
}


function EvacVDU( evacTeam, winningTeam )
{
	FlagEnd( "EvacFinished" )

	local losingTeam = GetOtherTeam( winningTeam )
	local pursuitTeam = GetOtherTeam( evacTeam )

	local evacTeamVDUTable = level.evacVDU[ evacTeam ]
	local pursuitTeamVDUTable = level.evacVDU[ pursuitTeam ]

	if ( pursuitTeamVDUTable.losersEvacPostPursuit )
		thread PlayPostEvacAnnouncementToTeam( pursuitTeamVDUTable.losersEvacPostPursuit, pursuitTeam )

	if ( evacTeamVDUTable.losersEvacPostEvac )
		thread PlayPostEvacAnnouncementToTeam( evacTeamVDUTable.losersEvacPostEvac, evacTeam )

	if ( evacTeamVDUTable.evacNag )
		thread NagConversation( (Evac_GetDropshipArrivalWaitTime()) * 0.65, evacTeamVDUTable.evacNag, evacTeam )

	if ( pursuitTeamVDUTable.pursuitNag )
		thread NagConversation( (Evac_GetDropshipArrivalWaitTime()) * 0.65, pursuitTeamVDUTable.pursuitNag, pursuitTeam )

	if ( evacTeamVDUTable.evacProximity	 )
		thread ProximityConversation( evacTeamVDUTable.evacProximity, evacTeam )

	if ( pursuitTeamVDUTable.pursuitProximity	 )
		thread ProximityConversation( pursuitTeamVDUTable.pursuitProximity, pursuitTeam )

	if ( evacTeamVDUTable.evacDustOff )
		thread DelayedConversationToTeam( Evac_GetDropshipArrivalWaitTime(), evacTeamVDUTable.evacDustOff, evacTeam )

	if ( pursuitTeamVDUTable.evacDustOff )
		thread DelayedConversationToTeam( Evac_GetDropshipArrivalWaitTime(), pursuitTeamVDUTable.pursuitDustOff, pursuitTeam )

	if ( GameRules.GetGameMode() != EXFILTRATION )
		delaythread ( (Evac_GetDropshipArrivalWaitTime() + EVAC_SHIP_IDLE_TIME) - 10.0 ) FlagSet( "EvacKillProximityConversationThread" )
}


function DelayedConversationToTeam( delay, conversation, team )
{
	FlagEnd( "EvacFinished" )

	wait delay

	PlayConversationToTeam( conversation, team )
}


function NagConversation( delayTime, line, team )
{
	FlagEnd( "EvacFinished" )

	wait delayTime

	local enemyTeam = GetEnemyTeam( team )
	local enemies = GetPlayerArrayOfTeam( enemyTeam )
	enemies.extend( level.evacProximityVDU )

	PlayConversationToAllExcept( line, enemies )
}

function ProximityConversation( line, team )
{
	FlagEnd( "EvacFinished" )

	foreach( index, player in GetPlayerArrayOfTeam( team ) )
	{
		//offset threads so we spread out distance checks on individual players across multiple frames
		delaythread( index * 0.1 ) ProximityConversationPlayer( line, player )
	}
}

function ProximityConversationPlayer( line, player )
{
	if ( !IsValid( player ) )
		return

	FlagEnd( "EvacFinished" )

	player.EndSignal( "Disconnected" )
	player.EndSignal( "OnDeath" )
	FlagEnd( "EvacKillProximityConversationThread" )

	WaitPlayerNearEvac( player )

	level.evacProximityVDU.append( player )

	PlayConversationToPlayer( line, player )
}

function WaitPlayerNearEvac( player )
{
	if ( !IsValid( player ) )
		return

	player.EndSignal( "Disconnected" )
	player.EndSignal( "OnDeath" )

	local radius 	= EVAC_PROXIMITY_VDU_RADIUS
	local radiusSqr = radius * radius

	while( 1 )
	{
		local distance = DistanceSqr( player.GetOrigin(), level.evacNode.GetOrigin() )
		//	print( distance, radiusSqr )
		if ( distance < radiusSqr )
			return

		wait 0.5
	}
}

function GetEvacPlayersThatAreAlive()
{
	//grab the current list of players who are alive
	local evacPlayers = []
	foreach ( player in GetPlayerArrayOfTeam( level.evacTeam ) )
	{
		if ( !IsAlive( player ) )
			continue

		evacPlayers.append( player )
	}

	return evacPlayers
}

function EvacShipEventsInit()
{
	local create			= CreateCinematicDropship()
	local event1 			= CreateCinematicEvent()
	local event2 			= CreateCinematicEvent()
	local event3 			= CreateCinematicEvent()
	local event4 			= CreateCinematicEvent()

	AddSavedDropEvent( "EvacShipEpilogue_cr", create )
	AddSavedDropEvent( "EvacShipEpilogue_e1", event1 )
	AddSavedDropEvent( "EvacShipEpilogue_e2", event2 )
	AddSavedDropEvent( "EvacShipEpilogue_e3", event3 )
	AddSavedDropEvent( "EvacShipEpilogue_e4", event4 )
}

function EvacShipInit( node )
{
	local spacenode 		= level.evacSpaceNode

	local arriveAnim = EVAC_ARRIVE_ANIM
	local idleAnim = EVAC_IDLE_ANIM
	local leaveAnim = EVAC_LEAVE_ANIM

	if ( "animPackage" in node.s && node.s.animPackage )
	{
		arriveAnim	= node.s.animPackage.arriveAnim
		idleAnim	= node.s.animPackage.idleAnim
		leaveAnim	= node.s.animPackage.leaveAnim
	}

	local create			= GetSavedDropEvent( "EvacShipEpilogue_cr" )
	create.origin 			= spacenode.GetOrigin()
	create.team				= level.evacTeam
	create.count 			= 8
	create.side 			= "rescueRamp"

	local event1 			= GetSavedDropEvent( "EvacShipEpilogue_e1" )
	event1.origin 			= node.GetOrigin()
	event1.yaw	 			= node.GetAngles().y
	event1.anim				= arriveAnim
	event1.teleport 		= true
	event1.preAnimWarp 		= true
	Event_AddFlagSetOnWarp( event1, "EvacAnimStart" )
	Event_AddFlagSetOnEnd( event1, "EvacShipArrive" )
	Event_AddServerStateFunc( event1, CE_PlayerSkyScaleEvacDropshipEnter )

	local event2 			= GetSavedDropEvent( "EvacShipEpilogue_e2" )
	event2.origin 			= node.GetOrigin()
	event2.yaw	 			= node.GetAngles().y
	event2.anim				= idleAnim
	Event_AddFlagWaitToEnd( event2, "EvacShipLeave" )

	local event3 			= GetSavedDropEvent( "EvacShipEpilogue_e3" )
	event3.origin 			= node.GetOrigin()
	event3.yaw	 			= node.GetAngles().y
	event3.anim				= leaveAnim
	event3.postAnimFPSWarp 	= true
	Event_AddServerStateFunc( event3, CE_PlayerSkyScaleOnDoorClose )
	Event_AddAnimStartFunc( event3, UpdateObjectiveDropshipLeaving )
	Event_AddAnimStartFunc( event3, DropshipPilotAnnouncesDeparture )
	Event_AddServerStateFunc( event3, PlayersOnGunPutAwayGuns )

	local event4 			= GetSavedDropEvent( "EvacShipEpilogue_e4" )
	event4.origin 			= spacenode.GetOrigin()
	event4.angles 			= spacenode.GetAngles()
	event4.anim				= EVAC_SPACE_ANIM
	event4.teleport 		= true
	Event_AddFlagSetOnStart( event4, "EvacFinished" )
	Event_AddAnimStartFunc( event4, UpdateObjectiveDropshipGotAway )
	Event_AddClientStateFunc( event4, "CE_VisualSettingsSpace" )
	Event_AddServerStateFunc( event4, CE_PlayerSkyScaleSpace )

	local dummy = CreatePropDynamic( CROW_MODEL )
	dummy.Hide()

	local arrivalAnimDuration = dummy.GetSequenceDuration( event1.anim )
	local frac = dummy.GetScriptedAnimEventCycleFrac( event1.anim, "ReadyToLoad" )
	Assert( frac != -1 )
	local emarkStartTime = arrivalAnimDuration * frac

	local departAnimDuration = dummy.GetSequenceDuration( event3.anim )
	local frac = dummy.GetScriptedAnimEventCycleFrac( event3.anim, "DustOff" )
	Assert( frac != -1 )
	local dustOffTime = departAnimDuration * frac

	local warpInFxTime = 0
	if ( event1.preAnimWarp )
		warpInFxTime = WARPINFXTIME

	dummy.Kill()

	level.arrivalAnimStartTime = Time() + Evac_GetDropshipArrivalWaitTime() - warpInFxTime - emarkStartTime
	level.departureAnimStartTime = Time() + ( Evac_GetDropshipArrivalWaitTime() + EVAC_SHIP_IDLE_TIME) - (dustOffTime)
}

function GetEvacStartDelay()
{
	return GetWinnerDeterminedWait() //Test getting rid of epilogue bar completely. Make objectives show up earlier as a result
	//return GetWinnerDeterminedWait() + EVAC_OBJECTIVE_WAIT
}

function GetTimeTillArrivalAnim()
{
	return level.arrivalAnimStartTime - Time()
}

function GetTimeTillDepartureAnim()
{
	return level.departureAnimStartTime - Time()
}

function AllEvacPlayersRescued( evacPlayers, rescuedPlayers )
{
	return evacPlayers.len() == rescuedPlayers.len()

}

function GetRescuedPlayers( dropship )
{
	local rescuedPlayers = []

	foreach( slot in GetSlotsFromRef( dropship ) )
	{
		local player = GetPlayerFromSlot( slot )

		if ( player && IsAlive( player ) )
			rescuedPlayers.append( player )
	}

	return rescuedPlayers
}


function Dropship_TookDamage( dropship, damageInfo )
{
	if ( dropship != level.dropship )
		return

	if ( !IsAlive( dropship ) )
		return

	local soul = dropship.GetTitanSoul()

	if ( !soul )
		return

	if ( Flag( "EvacFinished" ) )
	{
		damageInfo.SetDamage( 0 )
		return
	}

	if ( damageInfo.GetForceKill() )
	{
		soul.SetShieldHealth( 0 )
		return
	}

	local damageSourceID = damageInfo.GetDamageSourceIdentifier()
	if ( damageSourceID == eDamageSourceId.nuclear_core )
	{
		local damage = damageInfo.GetDamage()
		damage *= EVAC_SHIP_DAMAGE_MULTIPLIER_AGAINST_NUCLEAR_CORE
		//printt( "Reducing damage to dropship from nuclear core from " + damageInfo.GetDamage() + " to " + damage )
		damageInfo.SetDamage( damage )

	}
	else if ( damageSourceID == eDamageSourceId.mp_titanweapon_dumbfire_rockets )
	{
		local damage = damageInfo.GetDamage()
		damage *= EVAC_SHIP_DAMAGE_MULTIPLIER_AGAINST_CLUSTER_ROCKET
		//printt( "Reducing damage to dropship from cluster missile from " + damageInfo.GetDamage() + " to " + damage )
		damageInfo.SetDamage( damage )
	}
	else if( damageSourceID == eDamageSourceId.titan_fall )
	{
		damageInfo.SetDamage( 0 )
	}


	soul.s.nextRegenTime = Time() + EVAC_SHIP_SHIELD_REGEN_DELAY

	ShieldModifyDamage( dropship, damageInfo )
}

function DropshipTitanShieldRegenThink( soul, dropship )
{
	dropship.EndSignal( "OnDestroy" )

	soul.s.nextRegenTime <- 0

	local lastShieldHealth = soul.GetShieldHealth()
	local maxShield = soul.GetShieldHealthMax()
	local lastTime = Time()
	local shieldRegenRate = maxShield / ( EVAC_SHIP_SHIELD_REGEN_TIME / SHIELD_REGEN_TICK_TIME )

	while ( true )
	{
		local shieldHealth = soul.GetShieldHealth()

		if ( Time() >= soul.s.nextRegenTime )
		{
			local shieldHealth = soul.GetShieldHealth()
			local frameTime = max( 0.0, Time() - lastTime )
			local adjustedShieldRegenRate = shieldRegenRate * frameTime / SHIELD_REGEN_TICK_TIME

			soul.SetShieldHealth( min( soul.GetShieldHealthMax(), shieldHealth + adjustedShieldRegenRate ) )
		}

		lastShieldHealth = shieldHealth
		lastTime = Time()
		wait 0
	}
}

function EvacShipMain( health = EVAC_DROPSHIP_HEALTH, shield = EVAC_DROPSHIP_SHIELD_HEALTH )
{
	level.ent.EndSignal( "EvacCancelled" )

	if ( !Flag( "EvacEndsMatch" ) )
		FlagEnd( "EvacFinished" )

	wait GetTimeTillArrivalAnim()

	local create 	= GetSavedDropEvent( "EvacShipEpilogue_cr" )
	local event1 	= GetSavedDropEvent( "EvacShipEpilogue_e1" )
	local event2 	= GetSavedDropEvent( "EvacShipEpilogue_e2" )
	local event3 	= GetSavedDropEvent( "EvacShipEpilogue_e3" )
	local event4 	= GetSavedDropEvent( "EvacShipEpilogue_e4" )

	local dropship 	= SpawnCinematicDropship( create )
	level.dropship = dropship
	level.ent.Signal( "EvacDropship", { dropship = dropship } )

	//Add a pilot to the dropship
	local pilot
	if ( level.evacTeam == TEAM_IMC )
	 	pilot = CreatePropDynamic( TEAM_IMC_CAPTAIN_MDL )
	 else if ( level.evacTeam == TEAM_MILITIA )
	 	pilot = CreatePropDynamic( TEAM_MILITIA_CAPTAIN_MDL )
	 else Assert( false, "Unsupported team: " + level.evacTeam + " evacing!" )

	pilot.SetParent( dropship, "ORIGIN" )
	pilot.MarkAsNonMovingAttachment()

	dropship.s.pilot <- pilot

	thread PlayAnimTeleport( pilot, "Militia_flyinA_idle_mac", dropship, "ORIGIN" )


	AddDamageCallback( "npc_dropship", Dropship_TookDamage )

	local dropshipSoul = CreateEntity( "titan_soul" )
	DispatchSpawn( dropshipSoul )
	level.dropship.SetTitanSoul( dropshipSoul )
	dropshipSoul.SetTitan( level.dropship )
	dropshipSoul.SetShieldHealthMax( shield )
	dropshipSoul.SetShieldHealth( shield )
	thread DropshipTitanShieldRegenThink( dropshipSoul, dropship )

	EvacShipTrigger( dropship ) //Enable players to jump onto the ship once dropship is created

	if ( level.evacCustomDropshipFunc )
		level.evacCustomDropshipFunc( dropship )

	thread RunEvacDropship( dropship, event1, event2, event3, event4 )

	if ( GameRules.GetGameMode() != HEIST )
		thread EvacShipDeathScore( dropship )

	dropship.ClearInvulnerable()
	dropship.SetHealth( health )
	dropship.SetMaxHealth( health )

	local dropshipSounds = []

	OnThreadEnd(
		function() : ( dropship, dropshipSounds )
		{
			HideEvacShipIconOnMinimap()

			if ( Flag( "EvacEndsMatch" ) )
			{
				printt("[DEBUG_DEBUG] EvacEndsMatch\n");

				thread EndEpilogue()

				if ( IsAlive( dropship ) )
				{
					return
				}
				else if ( IsValid( dropship ) )
				{
					foreach ( sound in dropshipSounds )
						StopSoundOnEntity( dropship, sound )

					KillPlayersOnDropship( dropship )
				}
			}
			else
			{
				printt("[DEBUG_DEBUG] NOT EvacEndsMatch\n");

				local evacPlayerCount = 0
				foreach( player, _ in level.playersOnDropship )
				{
					if ( !IsAlive( player ) )
						continue

					evacPlayerCount++
				}

				if ( level.nv.winningTeam == null )
				{
					if ( evacPlayerCount )
					{

						if ( IsAlive( dropship ) )
						{
							SetWinLossReasons( "#HEIST_SUCCEED_ESCAPE_TO_SHIP_EVACTEAM", "#HEIST_FAILED_INTERRUPT_ESCAPE_DEFTEAM" ) //CTF PRo only. Make this more generic later
							SetWinner( level.evacTeam )
						}
						else
						{
							SetWinLossReasons( "#HEIST_SUCCEED_INTERRUPT_ESCAPE_DEFTEAM", "#HEIST_FAILED_ESCAPE_TO_SHIP_EVACTEAM" )
							SetWinner( GetOtherTeam( level.evacTeam ) )
						}

					}
					else
					{
						SetWinLossReasons( "#HEIST_SUCCEED_INTERRUPT_ESCAPE_DEFTEAM", "#HEIST_FAILED_ESCAPE_TO_SHIP_EVACTEAM" ) //CTF PRo only. Make this more generic later
						SetWinner( GetOtherTeam( level.evacTeam ) )
					}
				}

				if ( IsAlive( dropship ) )
				{
					foreach( player, _ in level.playersOnDropship )
					{
						if ( IsAlive( player ) )
						{
							if ( GetTitanBuildRule()/*GameRules.GetTitanBuildRule()*/ == eTitanBuildRule.RULE_POINT )
							{
								AddTitanBuildPoint( player, "evac" )
							}
						}
					}
				}
				else if ( IsValid( dropship ) )
				{
					foreach ( sound in dropshipSounds )
						StopSoundOnEntity( dropship, sound )

					KillPlayersOnDropship( dropship )
				}
			}

		}
	)

	dropship.EndSignal( "OnDeath" )

	local soundPrefix
	if ( dropship.GetTeam() == TEAM_IMC )
		soundPrefix = "Goblin_IMC_"
	else if ( dropship.GetTeam() == TEAM_MILITIA )
		soundPrefix = "Crow_MCOR_"
	else assert( "Unsupported Team!" )


	FlagWait( "EvacAnimStart" )
	local flyinSound = soundPrefix + "Evac_FlyIn"
	dropshipSounds.append( flyinSound )
	EmitSoundOnEntity( dropship, flyinSound )

	FlagWait( "EvacShipArrive" )
	FadeOutSoundOnEntity( dropship, flyinSound, 1.0 )
	local hoverSound = soundPrefix + "Evac_Hover"
	dropshipSounds.append( hoverSound )
	EmitSoundOnEntity( dropship, hoverSound )

	wait GetTimeTillDepartureAnim()

	FadeOutSoundOnEntity( dropship, hoverSound, 1.0 )
	local flyoutSound = soundPrefix + "Evac_FlyOut"
	dropshipSounds.append( flyoutSound )
	EmitSoundOnEntity( dropship, flyoutSound )

	FlagSet( "EvacShipLeave" )
	if ( Flag( "EvacEndsMatch" ) )
		HideEvacShipIconOnMinimap()

	FlagWait( "EvacFinished" )
	thread EvacEscapeScore( dropship )
}

function EvacShipDeathScore( dropship )
{
	dropship.WaitSignal( "OnDeath" )

	local killer = null
	if ( "lastAttacker" in dropship.s )
		killer = dropship.s.lastAttacker

	if ( !IsValid( killer ) )
		return

	if ( killer.GetTeam() == level.pursuitTeam )
	{
		AddPlayerScore( killer, "KillRescueShip" )
	}

	if ( GetNumberOfEvacPlayersAlive() == 0 )
		return

	local rescuedPlayers = GetRescuedPlayers( dropship )
	if ( !rescuedPlayers.len() )
		return
    local evacPlayers = GetPlayerArrayOfTeam( level.evacTeam )
	if ( !AllEvacPlayersRescued(  evacPlayers, rescuedPlayers ) )
		return

	if ( killer.GetTeam() == level.pursuitTeam )
	{
		AddPlayerScore( killer, "FishInBarrel" )
	}
}

function EvacEscapeScore( dropship )
{
	dropship.EndSignal( "OnDeath" )

	wait 2

	local rescuedPlayers = GetRescuedPlayers( dropship )
	foreach( player in rescuedPlayers )
	{
		AddPlayerScore( player, "HotZoneExtract" )
	}

	if ( rescuedPlayers.len() == 1 )
	{
		AddPlayerScore( rescuedPlayers[ 0 ], "SoleSurvivor" )
	}

	local evacPlayers = GetPlayerArrayOfTeam( level.evacTeam )

	if ( !AllEvacPlayersRescued( evacPlayers, rescuedPlayers ) )
		return

	if ( evacPlayers.len() == 1 )
		return

	foreach( player in rescuedPlayers )
	{
		AddPlayerScore( player, "TeamBonusFullEvac" )
	}
}

function AwardBonusScoreIfAllEvacPlayersKilledBySamePlayer( lastPlayerKilled )
{
	local killer = null
	if ( !( "lastAttacker" in lastPlayerKilled.s ) )
		return

	killer = lastPlayerKilled.s.lastAttacker

	if ( !IsValid( killer ) )
		return

	local evacPlayers = GetPlayerArrayOfTeam( level.evacTeam )
	foreach ( player in evacPlayers )
	{
		if ( !( "lastAttacker" in player.s ) )
			return

		if ( !player.s.lastAttacker )
			return

		if ( player.s.lastAttacker != killer )
			return
	}

	if ( killer.GetTeam() == level.pursuitTeam )
	{
		AddPlayerScore( killer, "SelfBonusKilledAll" )
	}
}

function KillPlayersOnDropship( dropship )
{
	local killer = null
	if ( ( "lastAttacker" in dropship.s ) )
		killer = dropship.s.lastAttacker

	foreach( player, _ in level.playersOnDropship )
	{
		if ( !IsAlive( player ) )
				continue

		player.ClearParent()
		player.DisableWeaponViewModel()

		local randomAngles = Vector( 0, RandomFloat( 0, 360 ), 0 )

		player.ClearInvulnerable() //Because we set invulnerable when the players get on
		player.SetRagdollImpactFX( RAGDOLL_IMPACT_TABLE_IDX )
		player.BecomeRagdoll( ( randomAngles.AnglesToForward() + Vector( 0,0,1.25 ) ) * 70000 )

		if ( !IsValid( killer ) )
			player.Die( player, player, { damageSourceId = eDamageSourceId.evac_dropship_explosion }  )
		else
			player.TakeDamage( player.GetHealth(), killer, killer, { damageSourceId = eDamageSourceId.evac_dropship_explosion }  )
	}

}
function EvacShipTrigger( dropship ) //TODO: Hacky. Polling is bad. Should rewrite this so it's just a trigger on touch
{
	Assert( IsAlive( dropship ), "Dropship is dead" )
	dropship.EndSignal( "OnDeath" )

	local radius 	= EVAC_TRIGGER_RADIUS
	local radiusSqr = radius * radius
	local index 	= dropship.LookupAttachment( "RampAttachD" )

	local trigger = CreateScriptMover( dropship )
	trigger.SetOrigin( dropship.GetAttachmentOrigin( index ) + ( dropship.GetUpVector() * 32 ) )
	trigger.SetParent( dropship, "ORIGIN", true )

	dropship.s.trigger <- trigger
}

function EvacShipTriggerCheck( dropship ) //TODO: Hacky. Polling is bad. Should rewrite this so it's just a trigger on touch
{
	if ( Flag( "EvacFinished" ) )
		return

	if ( !IsAlive( dropship ) )
		return

	if ( !("trigger" in dropship.s ) )
		return

	local radiusSqr = EVAC_TRIGGER_RADIUS * EVAC_TRIGGER_RADIUS
	local index 	= dropship.LookupAttachment( "RampAttachD" )

	local pilots = GetAllPilots( level.evacTeam )
	foreach ( pilot in pilots )
	{
		if ( !ShouldLetPilotBoardDropship( pilot ) )
			continue

		local index 	= pilot.LookupAttachment( "HeadFocus" )
		local origin	= pilot.GetAttachmentOrigin( index )

		local distance = DistanceSqr( origin, dropship.s.trigger.GetOrigin() )

		if ( distance < radiusSqr )
		{
			if ( TryAddPlayerToCinematic( pilot, GetSlotGroupIndex( dropship ) ) )
			{
				pilot.TouchGround() //Turn off jumpjet effect
				//Note: In here we used to delete the world icon for the dropship once they got inside. That got removed as part of the changes to the objective system. If we want to redo that it's easiest to create a custom objective for the player when he gets in

				pilot.ContextAction_SetBusy() //Stop being necksnapped
				AddPlayerScore( pilot, "GetToChopper" )

				level.playersOnDropship[ pilot ] <- true
				SetPlayerForcedDialogueOnly( pilot, true ) //No more misc dialogue
				pilot.SetIsValidChaseObserverTarget( false )
				if ( EVAL_PASSENGER_INVULNERABILITY )
					pilot.SetInvulnerable() //Cleared when ship dies
			}
		}
	}
}

Globalize( EvacShipTriggerCheck )

function ShouldLetPilotBoardDropship( pilot )
{
	if ( !IsAlive( pilot ) )
		return false

	if ( IsPlayerInCinematic( pilot ) )
		return false

	if ( IsPlayerEmbarking( pilot ) )
		return false

	if ( IsPlayerDisembarking( pilot ) )
		return false

	if ( pilot.ContextAction_IsActive() )
		return false

	if ( GAMETYPE == CAPTURE_THE_FLAG_PRO ) //If more and more game modes need this, should make this a thing controllable from game mode scripts
	{
		if ( !PlayerHasEnemyFlag( pilot ) )
			return false
	}

	return true

}

function PlayersOnGunPutAwayGuns( player, dropship )
{
	player.EndSignal( "Disconnected" )

	wait 1.0

	player.s.doNotReturnWeaponViewModel <- true

	if ( IsAlive( player ) )
		player.DisableWeaponViewModel()
}

const MINIMAP_EVAC_SCALE = 0.2
//coop = x * 0.572
const MINIMAP_EVAC_SCALE_COOP = 0.114
function CreateEvacShipIcon( node )
{
	local evacscale = MINIMAP_EVAC_SCALE
	if ( GAMETYPE == COOPERATIVE )
		evacscale = MINIMAP_EVAC_SCALE_COOP

	local ent = CreateScriptRefMinimap( node.GetOrigin(), node.GetAngles() )
	ent.kv.spawnflags = 3 //Transmit to client
	ent.SetTeam( level.evacTeam )
	ent.Minimap_SetDefaultMaterial( EVAC_MINIMAP_ICON_FRIENDLY )
	ent.Minimap_SetEnemyMaterial( EVAC_MINIMAP_ICON_ENEMY )
	ent.Minimap_SetFriendlyMaterial( EVAC_MINIMAP_ICON_FRIENDLY )
	ent.Minimap_SetAlignUpright( true )
	ent.Minimap_SetClampToEdge( true )
	ent.Minimap_SetObjectScale( evacscale )
	ent.Minimap_SetZOrder( 10 )
	return ent

}

function ShowEvacShipIconOnMinimap()
{
	level.evacShipIcon.Minimap_AlwaysShow( level.pursuitTeam, null )
	level.evacShipIcon.Minimap_AlwaysShow( level.evacTeam, null )
}

function HideEvacShipIconOnMinimap()
{
	level.evacShipIcon.Minimap_Hide( level.pursuitTeam, null )
	level.evacShipIcon.Minimap_Hide( level.evacTeam, null )
}

function Evac_SetEvacTeamOverride( evacTeam )
{
	level.evacTeamOverride = evacTeam
}

function Evac_AddLocation( nodeName, spectatorPos, spectatorAng, animPackage = null )
{
	local ent = GetEnt( nodeName )
	Assert( ent != null )

	local index = level.ExtractLocations.len()

	level.ExtractLocations[ index ] <- {}
	level.ExtractLocations[ index ].node <- ent
	level.ExtractLocations[ index ].spectatorPos <- spectatorPos
	level.ExtractLocations[ index ].spectatorAng <- spectatorAng

	ent.s.animPackage <- animPackage

	level.SelectedExtractLocationIndex = RandomInt( level.ExtractLocations.len() )

	level.evacNode = level.ExtractLocations[ level.SelectedExtractLocationIndex ].node
}

function Evac_SetupDefaultVDUs()
{
	Evac_SetVDUEvacNag( 		TEAM_MILITIA, 		"evac_nag" )
	Evac_SetVDUEvacNag( 		TEAM_IMC, 			"evac_nag" )
	Evac_SetVDUPursuitNag( TEAM_MILITIA, "pursuit_nag" )
	Evac_SetVDUPursuitNag( TEAM_IMC, "pursuit_nag" )
	Evac_SetVDUEvacProximity( TEAM_MILITIA, "evac_proximity" )
	Evac_SetVDUEvacProximity( TEAM_IMC, "evac_proximity" )
	Evac_SetVDUPursuitProximity( TEAM_MILITIA, "pursuit_proximity" )
	Evac_SetVDUPursuitProximity( TEAM_IMC, "pursuit_proximity" )
	Evac_SetVDUEvacDustOff( TEAM_MILITIA, "evac_dustoff" )
	Evac_SetVDUEvacDustOff( TEAM_IMC, "evac_dustoff" )
	Evac_SetVDUPursuitDustOff( TEAM_MILITIA, "pursuit_dustoff" )
	Evac_SetVDUPursuitDustOff( TEAM_IMC, "pursuit_dustoff" )
}

function PlayPostEvacAnnouncementToTeam( announcement, team )
{
	//printt( "PlayPostEvacAnnouncementToTeam, announcement: " + announcement + ", team: " + team )
	FlagWait( "PlayPostEvacDialogue" )
	ForcePlayConversationToTeam( announcement, team )
}

function OnPlayerDeath( player, damageInfo )
{
	if ( !IsPlayerEliminated( player ) )
		return

	MuteDialogueForPlayer( player )

	if ( player.GetTeam() == level.pursuitTeam )
		return

	//Give Pursuit team extra points for killing off escapees
	AwardBonusScoreIfAllEvacPlayersKilled( player )

	local killer = null
	if ( !( "lastAttacker" in player.s ) )
		return

	killer = player.s.lastAttacker

	if ( !IsValid( killer ) )
		return

	if ( killer.GetTeam() == level.pursuitTeam && player != killer )
	{
		AddPlayerScore( killer, "KilledEscapee" )
	}

	printt( "ON PLAYER DEATH 8" )
}

function GetNumberOfEvacPlayersAlive()
{
	Assert( level.evacTeam )
	return GameTeams.GetNumLivingPlayers( level.evacTeam )
}

function GetNumberOfPursuitPlayersAlive()
{
	Assert( level.pursuitTeam )
	return GameTeams.GetNumLivingPlayers( level.pursuitTeam )
}


function AwardBonusScoreIfAllEvacPlayersKilled( evacPlayer )
{
	if ( GetNumberOfEvacPlayersAlive() > 0 )
		return

	foreach ( player in GetPlayerArrayOfTeam( level.pursuitTeam ) )
	{
		AddPlayerScore( player, "TeamBonusKilledAll" )
	}

	AwardBonusScoreIfAllEvacPlayersKilledBySamePlayer( evacPlayer ) //Check to see if the entire team was killed by one dude
}

function ShouldDoPostEvacDialogue()
{
	if ( !GetCinematicMode() && !GetCurrentPlaylistVarInt( "run_evac", 0 )  )
		return false

	if ( GetBugReproNum() != 39844 ) //TODO: look into why this causes Bug 39844.
	{
		if ( !level.evacVDU[ level.evacTeam ].losersEvacPostEvac ) //If no post evac dialogue set up for the level, just return early
			return false

		if ( !level.evacVDU[ level.pursuitTeam ].losersEvacPostPursuit ) //If no post evac dialogue set up for the level, just return early
			return false
	}

	return true
}

function EndEpilogue()
{
	UpdateObjectives()
	//printt( "Setting EvacFinished" )
	FlagSet( "EvacFinished" )

	SetGlobalForcedDialogueOnly( true ) //Stop misc chatter

	wait 3.0 //Just for timing purposes to give a beat
	FlagSet( "PlayPostEvacDialogue" ) //Post Evac dialogue triggers here
	EscapedPlayersObitPrint()

	wait level.postEvacDialogueTime //Default time is 4.0

	ClearTeamActiveObjective( TEAM_IMC )
	ClearTeamActiveObjective( TEAM_MILITIA )

	ForceEpilogueEnd()
}

function EscapedPlayersObitPrint() //Print Chin[ Evacuated ]
{
	foreach( player in GetPlayerArray() )
	{
		foreach( evacPlayer, _ in level.playersOnDropship )
		{
			if ( !IsAlive( evacPlayer ) )
				continue

			local evacPlayerHandle = evacPlayer.GetEncodedEHandle()

			Remote.CallFunction_NonReplay( player, "ServerCallback_EvacObit", evacPlayerHandle )
		}
	}
}

function UpdateObjectives()
{
	if ( Flag( "EvacFinished" ) ) //Don't need to further update objectives if dropship has successfully warped out
		return

	local evacTeam = level.evacTeam
	local pursuitTeam = GetOtherTeam( evacTeam )

	if ( GetNumberOfEvacPlayersAlive() == 0 )
	{
		 SetTeamActiveObjective( evacTeam, "EG_DropshipExtractEvacPlayersKilled" )
		 SetTeamActiveObjective( pursuitTeam, "EG_StopExtractEvacPlayersKilled" )

	}
	else if( !IsAlive( level.dropship ) )
	{
		SetTeamActiveObjective( evacTeam, "EG_DropshipExtractDropshipDestroyed" )
		SetTeamActiveObjective( pursuitTeam, "EG_StopExtractDropshipDestroyed" )
	}

}

function MonitorPlayers()
{
	while( true )
	{
		waitthread WaitUntilPlayerHasDiedOrDisconnected()
		if ( EvacModeShouldEnd() )
		{
			if ( !Flag( "EvacEndsMatch" ) )
			{
				FlagSet( "EvacFinished" )
				//Don't clear objectives here since we want message to remain to tell players why they lost. Depend on game mode to clear it appropriately
				/*ClearTeamActiveObjective( TEAM_IMC )
				ClearTeamActiveObjective( TEAM_MILITIA )*/
				return
			}

			thread EndEpilogue()

		}
	}
}

function WaitUntilPlayerHasDiedOrDisconnected()
{
	level.ent.EndSignal( "PlayerDisconnected" )
	level.ent.EndSignal( "PlayerKilled" )

	WaitForever()
}

function EvacModeShouldEnd()
{
	//First check to see if any other players are still connected
	printt(level.evacTeam)
	printt(GetOtherTeam(level.evacTeam))
	local evacPlayers = GetPlayerArrayOfTeam( level.evacTeam )
	local pursuitPlayers = GetPlayerArrayOfTeam( GetOtherTeam(level.evacTeam) )

	if ( evacPlayers.len() == 0 )
		return true

	if ( pursuitPlayers.len() == 0 && GameRules.GetGameMode() != COOPERATIVE )
		return true

	//Next check to see if players are still alive
	if ( NoActiveEvacPlayers() ) //Players can still respawn
		return false

	if ( GetNumberOfEvacPlayersAlive() == 0 )
		return true

	//If dropship was created and is dead. This normally doesn't get hit at all since
	//the dropship EvacDropshipMain() terminates the epilogue when the dropship dies.
	if ( level.dropship != null && !IsAlive( level.dropship ) )
		return true

	return false
}

function MuteDialogueForPlayer( player )
{
	SetPlayerForcedDialogueOnly( player, true )
}


function UpdateObjectiveDropshipLeaving( dropship, ref, table ) //Don't need any of these parameters, but they are passed in...
{
	if ( Flag( "EvacFinished" ) )
		return

	local evacTeam = level.evacTeam
	local pursuitTeam = GetOtherTeam(level.evacTeam)

	SetTeamActiveObjective( evacTeam, "EG_DropshipExtractDropshipFlyingAway" )
	SetTeamActiveObjective( pursuitTeam, "EG_StopExtractDropshipFlyingAway", Time() + 2.5, level.dropship )
}

function DropshipPilotAnnouncesDeparture( dropship, ref, table )
{
	if ( Flag( "EvacFinished" ) )
		return

	Assert( IsValid( dropship.s.pilot ) )

	local departureAnnouncement = DecideDepartureAnnouncement()

	EmitSoundOnEntity( dropship.s.pilot, departureAnnouncement )
}

function DecideDepartureAnnouncement()
{
	local teamString
	if ( level.evacTeam == TEAM_IMC )
		teamString = "imc"
	else if ( level.evacTeam == TEAM_MILITIA )
		teamString = "mcor"
	else Assert( false, "Unsupported team" )

	local lineNumber = RandomInt( 1, 4 )

	return ( "diag_" + teamString + "_dspilot_evacDepartTimeReached_101_0" + lineNumber )
}



function UpdateObjectiveDropshipGotAway( dropship, ref, table ) //Don't need any of these parameters, but they are passed in...
{
	local evacTeam = level.evacTeam
	local pursuitTeam = GetOtherTeam(level.evacTeam)

	if ( GetNumberOfPursuitPlayersAlive() != 0 )
		SetTeamActiveObjective( evacTeam, "EG_DropshipExtractFailedEscape" )
	if ( GetNumberOfEvacPlayersAlive() != 0 )
		SetTeamActiveObjective( pursuitTeam, "EG_StopExtractDropshipSuccessfulEscape" )

	//If you actually got away, set the correct objective
	foreach( pilot, _ in level.playersOnDropship )
	{
		if ( !IsAlive( pilot ) )
			continue

		SetPlayerActiveObjective(  pilot, "EG_DropshipExtractSuccessfulEscape" )
	}

}

function IsPlayerOnEvacDropship( player )
{
	return player in level.playersOnDropship
}

function NoActiveEvacPlayers()
{
	local players = GetPlayerArray()

	local imcPlayers = 0
	local militiaPlayers = 0

	foreach ( player in players )
	{
		if ( !IsAlive( player ) && IsPlayerEliminated( player ) )
			continue

		if ( player.GetTeam() == TEAM_IMC )
			imcPlayers++
		else if ( player.GetTeam() == TEAM_MILITIA )
			militiaPlayers++
	}

	if ( !imcPlayers || !militiaPlayers )
		return false

	return true
}