//********************************************************************************************
//	capture_point
//********************************************************************************************
Assert( IsServer() )

const CP_AWARD_TEAM_OWNED_POINTS_SIGNAL = "CP_AWARD_TEAM_OWNED_POINTS_SIGNAL"
const CP_AWARD_PLAYER_HOLD_POINTS_SIGNAL = "CP_AWARD_PLAYER_HOLD_POINTS_SIGNAL"
const CP_END_CAPPING_WAIT_SIGNAL = "CP_END_CAPPING_WAIT_SIGNAL"
const CP_LEAVE_TRIGGER = "CP_LEAVE_TRIGGER"
const CP_REINFORCE_INTERVAL = 1.0
const CP_CAPTURE_HINT_RADIUS = 1536
const CP_NAG_DEBOUNCE_TIME = 90

function main()
{
	Globalize( CapturePointSwitchPlayer )
	Globalize( AddHardpointCustomSpawnCallback )

	RegisterSignal( CP_AWARD_TEAM_OWNED_POINTS_SIGNAL )
	RegisterSignal( CP_AWARD_PLAYER_HOLD_POINTS_SIGNAL )
	RegisterSignal( CP_END_CAPPING_WAIT_SIGNAL )
	RegisterSignal( CP_LEAVE_TRIGGER )

	AddCallback_PlayerOrNPCKilled( CapturePoint_OnPlayerOrNPCKilled )

	level.cpCustomSpawnFunc <- null
	level.hardpointCaptureTime <- CAPTURE_DURATION_CAPTURE

	RegisterSignal( "CapturePointStateChange" )
	RegisterSignal( "CapturePointUpdate" )
	RegisterSignal( "HardpointVO_Progress" )

	GM_AddEndRoundFunc( CapturePointEndRound )

	FlagInit( "CapturePointsRewardTeamscore", true )

	RegisterHardpointTriggerFunc( Bind( CapturePoint_OnStartTouch ), Bind( CapturePoint_OnEndTouch ) )
	RegisterHardpointUpdateFunc( Bind( CapturePoint_Update ) )

	thread HardpointRadiusCheck()

	if ( !GetCinematicMode() && !level.matchProgressAnnounceFunc ) //Don't use default progress announcements if something custom already enabled
	{
		local table = {}
		table[ TEAM_IMC ] <- {}
		table[ TEAM_MILITIA ] <- {}
		table[ TEAM_MILITIA ][ "hardpoint_match_progress_25_percent" ] <- false
		table[ TEAM_MILITIA ][ "hardpoint_match_progress_50_percent" ] <- false
		table[ TEAM_MILITIA ][ "hardpoint_match_progress_75_percent" ] <- false
		table[ TEAM_IMC ][ "hardpoint_match_progress_25_percent" ] <- false
		table[ TEAM_IMC ][ "hardpoint_match_progress_50_percent" ] <- false
		table[ TEAM_IMC ][ "hardpoint_match_progress_75_percent" ] <- false

		level.cpMatchProgressDialog <- table
	}
}


function EntitiesDidLoad()
{
	// don't do the rest if we couldn't init (testmaps)
	level.hardpointModeInitialized = InitializeHardpointsForCapturePoint()
	if ( !level.hardpointModeInitialized )
		return
}


function InitializeHardpointsForCapturePoint()
{
	local hardpointArray = GetEntArrayByClass_Expensive( "info_hardpoint" )

	if ( hardpointArray.len() < 3 )
	{	// checks to see if the map is set up for CP
		printt( "!!!!!!!!!! cp mode can't init! Less than three info_hardpoint entities found." )
		//if ( level.isTestmap )
		//	return false
		//else
			Assert( foundHardpointEnts, "this map is not set up for cp mode." )
	}

	//if more than 3, choose three
	local desiredHardpoints = 3
	local selectedHardpoints = []
	for ( local i = 0 ; i < desiredHardpoints ; i++ )
		selectedHardpoints.append( null )
	ArrayRandomize( hardpointArray )

	//if there is a group A, choose one for it
	local need_A = true
	//if there is a group B, choose one for it
	local need_B = true
	//if there is a group C, choose one for it
	local need_C = true

	foreach( hardpoint in hardpointArray )
	{
		if ( hardpoint.HasKey( "hardpointGroup" ) )
		{
			if( hardpoint.kv.hardpointGroup == "A" && ( need_A ) )
			{
				selectedHardpoints[0] = hardpoint
				need_A = false
			}
			if ( hardpoint.kv.hardpointGroup == "B" && ( need_B ) )
			{
				selectedHardpoints[1] = hardpoint
				need_B = false
			}
			if ( hardpoint.kv.hardpointGroup == "C" && ( need_C ) )
			{
				selectedHardpoints[2] = hardpoint
				need_C = false
			}
		}
	}

	// see how many groups arent filled and fill them
	local groups_needed = desiredHardpoints - GetNumHardpointsInArray( selectedHardpoints )
	if ( groups_needed )
	{
		foreach( hardpoint in hardpointArray )
		{
			if ( hardpoint.HasKey( "hardpointGroup" ) )
				continue

			if ( hardpoint.GetName() == UPLINK )
				continue

			if ( desiredHardpoints == GetNumHardpointsInArray( selectedHardpoints ) )
				break

			AddHardpointToArray( selectedHardpoints, hardpoint )
		}
	}

	foreach( hardpoint in hardpointArray )
	{	// delete unselected hardpoints and any associated triggers and panels
		if ( !ArrayContains( selectedHardpoints, hardpoint ) )
			DeleteHardpoint( hardpoint )
	}

	// do gamemode independed init
	InitializeHardpoints( selectedHardpoints )

	Assert( level.hardpoints.len() == desiredHardpoints )

	// initialize final capture point hardpoints
	foreach( i, capturepoint in level.hardpoints )
	{
		// using "capturepoint" here to indicate that these variables etc. are used only for the capture point gamemode

		capturepoint.SetTeam( TEAM_UNASSIGNED )

		// setup minimap data
		local hardpointStringID = GetHardpointStringID( capturepoint.GetHardpointID() )

		capturepoint.Minimap_SetDefaultMaterial( GetMinimapMaterial( "hardpoint_neutral_" + hardpointStringID ) )
		capturepoint.Minimap_SetFriendlyMaterial( GetMinimapMaterial( "hardpoint_friendly_" + hardpointStringID ) )
		capturepoint.Minimap_SetEnemyMaterial( GetMinimapMaterial( "hardpoint_enemy_" + hardpointStringID ) )
		capturepoint.Minimap_SetObjectScale( 0.11 )
		capturepoint.Minimap_SetAlignUpright( true )
		capturepoint.Minimap_SetClampToEdge( true )
		capturepoint.Minimap_SetFriendlyHeightArrow( true )
		capturepoint.Minimap_SetEnemyHeightArrow( true )
		capturepoint.Minimap_SetZOrder( 10 )

		// show on all minimaps
		capturepoint.Minimap_AlwaysShow( TEAM_IMC, null )
		capturepoint.Minimap_AlwaysShow( TEAM_MILITIA, null )

		thread HardpointVO_Think( capturepoint )

		// raised capturepoint origin to stop minimap icon showing a below indicator.
		capturepoint.SetOrigin( capturepoint.GetOrigin() + Vector( 0,0,96 ) )

		AddHardpointTeamSwitchCallback( capturepoint, Bind( CapturePoint_TeamChanged ) )
	}

	return true
}


function CapturePointEndRound()
{
	// end capping in progress etc.
	foreach( hardpoint in level.hardpoints )
	{
		hardpoint.Signal( CP_END_CAPPING_WAIT_SIGNAL )
		hardpoint.SetHardpointPlayerCount( TEAM_MILITIA, 0 )
		hardpoint.SetHardpointPlayerCount( TEAM_IMC, 0 )
		hardpoint.SetHardpointAICount( TEAM_MILITIA, 0 )
		hardpoint.SetHardpointAICount( TEAM_IMC, 0 )
		CapturePoint_NotifyStateChange( hardpoint, CAPTURE_POINT_STATE_HALTED )

		hardpoint.Minimap_Hide( TEAM_IMC, null )
		hardpoint.Minimap_Hide( TEAM_MILITIA, null )

		// Disable linked turrets
		if ( "linkedMegaTurret" in hardpoint.s )
			ReleaseTurret( hardpoint.s.linkedMegaTurret )
	}
}

function SetPointAsCapturedByTeam( hardpoint, cappingTeam )
{
	local goalProgress = 0
	if ( cappingTeam == TEAM_MILITIA )
		goalProgress = 1
	if ( cappingTeam == TEAM_IMC )
		goalProgress = -1

	hardpoint.SetHardpointEstimatedCaptureTime( -1 )
	hardpoint.SetHardpointProgressRefPoint( goalProgress )
	hardpoint.s.haltedProgress = goalProgress
	hardpoint.s.contestedCount = 0	// used when playing VO about the hardpoint being contested

	// Had to add a additional parameter to stop this function from playing sounds when switching teams.
	// This will still call functions added with AddHardpointTeamSwitchCallback(...)
	HardpointTeamChange( hardpoint, cappingTeam, true )

	hardpoint.s.lastCappingTeam = cappingTeam
	hardpoint.s.lastCaptureSide = cappingTeam

	if ( hardpoint.GetTeam() == TEAM_UNASSIGNED )
		CapturePoint_NotifyStateChange( hardpoint, CAPTURE_POINT_STATE_HALTED )
	else
		CapturePoint_NotifyStateChange( hardpoint, CAPTURE_POINT_STATE_CAPTURED )

	thread CapturePoint_Update( hardpoint )
}
Globalize( SetPointAsCapturedByTeam )

function CappingWait( hardpoint, captureTime, cappingTeam, goalProgress )
{
	hardpoint.EndSignal( CP_END_CAPPING_WAIT_SIGNAL	)

	OnThreadEnd(
		function() : ( hardpoint, captureTime )
		{
			// printt( "CappingWait ended", hardpoint, captureTime )
		}
	)

//	printt( "CappingWait", hardpoint, captureTime )
	wait captureTime

	if ( goalProgress != 0 )
	{
		if ( hardpoint.GetTeam() != cappingTeam )
		{
			// captured
			hardpoint.SetHardpointEstimatedCaptureTime( -1 )
			hardpoint.SetHardpointProgressRefPoint( goalProgress )
			hardpoint.s.haltedProgress = goalProgress
			hardpoint.s.contestedCount = 0	// used when playing VO about the hardpoint being contested
			HardpointTeamChange( hardpoint, cappingTeam )
			CapturePoint_NotifyStateChange( hardpoint, CAPTURE_POINT_STATE_CAPTURED )
			thread CapturePoint_Update( hardpoint )
		}
		else
		{
			// recaptured the point. not score should be given.
			hardpoint.SetHardpointEstimatedCaptureTime( -1 )
			hardpoint.SetHardpointProgressRefPoint( goalProgress )
			hardpoint.s.haltedProgress = goalProgress
			hardpoint.s.contestedCount = 0	// used when playing VO about the hardpoint being contested
			CapturePoint_NotifyStateChange( hardpoint, CAPTURE_POINT_STATE_CAPTURED )
			thread CapturePoint_Update( hardpoint )
		}
	}
	else
	{
		// neutralized the hardpoint, not yet captured
		hardpoint.SetHardpointEstimatedCaptureTime( -1 )
		hardpoint.SetHardpointProgressRefPoint( 0 )
		local previousTeam = hardpoint.GetTeam()
		if ( hardpoint.GetTeam() != TEAM_UNASSIGNED )
		{
			HardpointTeamChange( hardpoint, TEAM_UNASSIGNED )
			hardpoint.Signal( "CapturePointStateChange", { oldState = hardpoint.GetHardpointState(), oldTeam = previousTeam } )
		}
		thread CapturePoint_Update( hardpoint )
	}
//	printt( "CappingWait done", hardpoint, captureTime )
}


function CapturePoint_Update( hardpoint )
{
	if ( !hardpoint.Enabled() )
		return

	if ( GetGameState() != eGameState.Playing )
		return

	if ( !IsValid( hardpoint ) )
		return

	if ( !hardpoint.s.cappable )
		return

	// terminate old CappingWait thread if any
	hardpoint.Signal( CP_END_CAPPING_WAIT_SIGNAL )
	hardpoint.Signal( "CapturePointUpdate" )

	local powerTable = GetCapPower( hardpoint )

	local baseCaptureTime = level.hardpointCaptureTime

	local isBeingCapped = false
	local isCaptured = hardpoint.s.haltedProgress == 1 || hardpoint.s.haltedProgress == -1

	if ( powerTable.strongerTeam != TEAM_UNASSIGNED )
	{
		if ( powerTable.strongerTeam == hardpoint.GetTeam() && isCaptured )
			isBeingCapped = false
		else
			isBeingCapped = true
	}

	if ( isBeingCapped )
	{
		// state: CAPPING
		local cappingTeam = powerTable.strongerTeam
		local remainingTime = baseCaptureTime
		local previousProgress = hardpoint.GetHardpointProgressRefPoint()

		// previousGoalProgress will be incorrect if we got here after neutralizing at point.
		// it doesn't matter because GetHardpointEstimatedCaptureTime() is -1 and progress stays 0.0
		// - Roger
		local previousGoalProgress = GetGoalProgress( hardpoint, hardpoint.s.lastCappingTeam )
		local goalProgress = GetGoalProgress( hardpoint, cappingTeam )
		local progress = 0.0
		// progress is a value between from -1 to 1.
		// the IMC is striving for -1 and the Militia for 1

		// this is the state the hardpoint is in now, before this update.
		switch( hardpoint.GetHardpointState() )
		{
			case CAPTURE_POINT_STATE_CAPPING:
				if ( hardpoint.GetHardpointEstimatedCaptureTime() >= 0 )
					progress = GetCurrentProgress( hardpoint, baseCaptureTime, previousGoalProgress )
				break
			case CAPTURE_POINT_STATE_CAPTURED:
				progress = 1.0	// Militia owned
				if ( hardpoint.GetTeam() == TEAM_IMC )
					progress = -1.0	// IMC owned
				break
			case CAPTURE_POINT_STATE_HALTED:
				progress = hardpoint.s.haltedProgress
				break
			case CAPTURE_POINT_STATE_UNASSIGNED:
				progress = 0.0	// progress at the start of a match
				break
		}

		// clear halted progress since it would not be correct any more
		hardpoint.s.haltedProgress = null
		hardpoint.s.lastCappingTeam = cappingTeam

		// store current power for use next update
		hardpoint.s.lastPower = powerTable.power

		local totalCaptureTime = baseCaptureTime / powerTable.power
		local captureTime

		if ( goalProgress == 0 )
		{
			captureTime = totalCaptureTime * ( fabs( progress ) )
		}
		else
		{
			captureTime = totalCaptureTime * ( 1 - fabs( progress ) )
			hardpoint.s.lastCaptureSide = cappingTeam	// this team we are filling up the bar for.
//			printt( "set lastCaptureSide", hardpoint.s.lastCaptureSide )
		}

		// this will in effect change to size of the bar on the client
		hardpoint.SetHardpointEstimatedCaptureTime( Time() + captureTime )
		hardpoint.SetHardpointProgressRefPoint( progress )
		thread HardpointVO_Progress( hardpoint, progress, totalCaptureTime )

		CapturePoint_NotifyStateChange( hardpoint, CAPTURE_POINT_STATE_CAPPING )

		// will do state change etc. once captureTime has expired
		thread CappingWait( hardpoint, captureTime, cappingTeam, goalProgress )
	}
	else
	{
		if ( hardpoint.GetHardpointState() == CAPTURE_POINT_STATE_CAPTURED )
		{
			if ( powerTable.contested )
				CapturePoint_NotifyStateChange( hardpoint, CAPTURE_POINT_STATE_HALTED )
		}
		else if ( hardpoint.GetHardpointState() == CAPTURE_POINT_STATE_HALTED )
		{
			if ( !powerTable.contested && isCaptured )
				CapturePoint_NotifyStateChange( hardpoint, CAPTURE_POINT_STATE_CAPTURED )
		}
		else if ( hardpoint.GetHardpointState() == CAPTURE_POINT_STATE_CAPPING )
		{
			Assert( hardpoint.GetHardpointEstimatedCaptureTime() >= 0, "estimatedCaptureTime shouldn't be -1" )

			// state should change to halted, calculate current progress
			local previousProgress = hardpoint.GetHardpointProgressRefPoint()
			local goalProgress = GetGoalProgress( hardpoint, hardpoint.s.lastCappingTeam )

			local haltedProgress = GetCurrentProgress( hardpoint, baseCaptureTime, goalProgress )
//			printt( "halted at", haltedProgress )

			hardpoint.s.haltedProgress = haltedProgress
			hardpoint.SetHardpointProgressRefPoint( haltedProgress )
			hardpoint.SetHardpointEstimatedCaptureTime( -1 )

			CapturePoint_NotifyStateChange( hardpoint, CAPTURE_POINT_STATE_HALTED )
		}

		hardpoint.Signal( "HardpointVO_Progress" )
	}
}


function GetGoalProgress( hardpoint, team )
{
	if ( hardpoint.GetHardpointProgressRefPoint() == 0 )
	{
		if ( hardpoint.s.lastCappingTeam && hardpoint.s.lastCappingTeam != team )
			return 0.0
	}

	if ( team == TEAM_IMC && hardpoint.GetHardpointProgressRefPoint() <= 0 )
		return -1.0

	if ( team == TEAM_MILITIA && hardpoint.GetHardpointProgressRefPoint() >= 0 )
		return 1.0

	return 0.0
}

function GetCurrentProgress( hardpoint, baseCaptureTime, previousGoalProgress )
{
	local remainingTime = hardpoint.GetHardpointEstimatedCaptureTime() - Time()
	local progress = GraphCapped( ( remainingTime * hardpoint.s.lastPower ), 0, baseCaptureTime, 1, 0 )

	if ( previousGoalProgress == 0 )
		progress = Graph( progress, 0, 1, 1, 0 )

	// if the bar was on the IMC side progress is a value between 0 and -1
	if ( hardpoint.s.lastCaptureSide == TEAM_IMC )
		progress *= -1

	return progress
}


function CapturePoint_OnStartTouch( touchEnt, trigger, hardpoint )
{
	CapturePoint_Update( hardpoint )
}


function CapturePoint_OnEndTouch( touchEnt, trigger, hardpoint)
{
	if ( !hardpoint.Enabled() )
		return

	touchEnt.Signal( CP_LEAVE_TRIGGER )

	if ( GetGameState() != eGameState.Playing )
		return

	if ( GetFriendlyCount( hardpoint, touchEnt ) == 0 && !GetEnemyCount( hardpoint, touchEnt ) && hardpoint.GetTeam() != touchEnt.GetTeam() )
	{
		local isPlayer = touchEnt.IsPlayer()
		local isAlive = IsAlive( touchEnt )
		local notCaptured = hardpoint.GetHardpointState() != CAPTURE_POINT_STATE_CAPTURED
		local notSameTeam = hardpoint.GetTeam() != touchEnt.GetTeam()

		if ( isPlayer && isAlive && notCaptured && notSameTeam )
		{
			local hardpointStringID = GetHardpointStringID( hardpoint.GetHardpointID() )
			PlayConversationToPlayer( "hardpoint_player_outofrange_" + hardpointStringID, touchEnt )
		}
	}

	CapturePoint_Update( hardpoint )
}


function CapturePoint_NotifyStateChange( hardpoint, newState )
{
	if ( newState == hardpoint.GetHardpointState() )
		return

	local oldState = hardpoint.GetHardpointState()

	// this in effect notifies all clients of the state change
	hardpoint.SetHardpointState( newState )
	hardpoint.Signal( "CapturePointStateChange", { oldState = oldState } )
}

function CapturePoint_TeamChanged( hardpoint, previousTeam )
{
	local team = hardpoint.GetTeam()

	Spawning_HardpointChangedTeams( hardpoint, previousTeam, team )

	// Give points for the team change to the appropriate people
	CapturePoint_AwardPlayerPoints( hardpoint )

	if ( Flag( "CapturePointsRewardTeamscore" ) )
		thread CapturePoint_AwardTeamOwnedPoints( hardpoint )

	thread CapturePoint_AwardPlayerHoldPoints( hardpoint )
}


function HardpointVO_StartCapping( hardpoint )
{
	local hpTrig = hardpoint.s.trigger
	local players = GetPlayerArray()

	local owningTeam = hardpoint.GetTeam()
	local cappingTeam = hardpoint.s.lastCappingTeam
	local hardpointStringID = GetHardpointStringID( hardpoint.GetHardpointID() )

	foreach ( player in players )
	{
		local team = player.GetTeam()

		local lastTimePlayed = hardpoint.s.dialogueHistory[ team ][ "StartCapping" ]
		if ( Time() - lastTimePlayed < 10.0 )
			continue

		if ( player.GetTeam() == cappingTeam )
		{
			if ( hpTrig.IsTouching( player ) )
			{
				if ( owningTeam != TEAM_UNASSIGNED )
				{
					local convAlias = "hardpoint_player_status_0_" + hardpointStringID
					PlayConversationToPlayer( convAlias, player )
				}
				else
				{
					local convAlias = "hardpoint_player_capping_" + hardpointStringID
					PlayConversationToPlayer( convAlias, player )
				}
			}
			else
			{
				local convAlias = "hardpoint_capping_" + hardpointStringID
				PlayConversationToPlayer( convAlias, player )
			}

			// store the last time StartCapping dialogue was played for this hardpoint
			hardpoint.s.dialogueHistory[ team ][ "StartCapping" ] = Time()
		}
	}
}


function HardpointVO_StartContested( hardpoint )
{
	local hpTrig = hardpoint.s.trigger
	local players = GetPlayerArray()

	local owningTeam = hardpoint.GetTeam()
	local hardpointStringID = GetHardpointStringID( hardpoint.GetHardpointID() )

	foreach ( player in players )
	{
		if ( player.GetTeam() != owningTeam )
		{
			if ( hpTrig.IsTouching( player ) )
			{
				local convAlias = "hardpoint_player_contested_capture_" + hardpointStringID
				PlayConversationToPlayer( convAlias, player )
			}
			else
			{
				// ADD engaging dialog
				//local convAlias = "hardpoint_capping_" + hardpointStringID
				//PlayConversationToPlayer( convAlias, player )
			}
		}
	}
}

function HardpointVO_Contested( hardpoint )
{
	local hpTrig = hardpoint.s.trigger
	local players = GetPlayerArray()

	local owningTeam = hardpoint.GetTeam()
	local cappingTeam = hardpoint.s.lastCappingTeam
	local hardpointStringID = GetHardpointStringID( hardpoint.GetHardpointID() )
	local state = hardpoint.GetHardpointState() // the state has not been updated yet, but that is fine.
	local powerTable = GetCapPower( hardpoint )

	if ( hardpoint.GetHardpointEstimatedCaptureTime() )
	{
		// don't mention enemies if we are close to capturing. It might block more important dialog.
		// once we have a queue system if should be fine to play.
		local timeUntilCapture = hardpoint.GetHardpointEstimatedCaptureTime() - Time()
		if ( timeUntilCapture < 5.0 )
			return
	}

	foreach ( player in players )
	{
		if ( player.GetTeam() == cappingTeam )
		{
			if ( player.s.curHardpoint == hardpoint )
			{
				if ( powerTable.strongerTeam == TEAM_UNASSIGNED ) // no team is stronger
				{
					// play halted lines
					local convAlias = "hardpoint_player_contested_" + hardpointStringID
					PlayConversationToPlayer( convAlias, player )
				}
				else if ( state == CAPTURE_POINT_STATE_CAPPING )
				{
					if ( hardpoint.s.contestedCount == 1 )
					{
						// first time we are contested since last time we where capped
						// play interference lines
						local convAlias = "hardpoint_player_interference_" + hardpointStringID
						PlayConversationToPlayer( convAlias, player )
					}
					else
					{
						// play interference again lines
						local convAlias = "hardpoint_player_interference_again_" + hardpointStringID
						PlayConversationToPlayer( convAlias, player )
					}
				}
			}
		}
		else if ( player.GetTeam() == cappingTeam )
		{
			// ADD  dialog for the team that is contesting
		}
	}
}


function HardpointVO_Neutralize( hardpoint )
{
	local hpTrig = hardpoint.s.trigger
	local players = GetPlayerArray()
	local hardpointStringID = GetHardpointStringID( hardpoint.GetHardpointID() )

	local owningTeam = hardpoint.GetTeam()
	local cappingTeam = hardpoint.s.lastCappingTeam

	foreach ( player in players )
	{
		if ( player.GetTeam() != cappingTeam )
		{
			local convAlias = "hardpoint_losing_" + hardpointStringID

			if ( Distance( player.GetOrigin(), hardpoint.GetOrigin() ) < 1536.0 && !hpTrig.IsTouching( player ) )
				convAlias = "hardpoint_engaging_" + hardpointStringID

			PlayConversationToPlayer( convAlias, player )
			continue
		}
		else if ( player.GetTeam() == cappingTeam )
		{
			if ( hpTrig.IsTouching( player ) )
			{
				local convAlias = "hardpoint_player_status_neutral_0_" + hardpointStringID
				PlayConversationToPlayer( convAlias, player )
			}
		}
	}
}


function HardpointVO_Captured( hardpoint )
{
	local hpTrig = hardpoint.s.trigger
	local players = GetPlayerArray()
	local hardpointStringID = GetHardpointStringID( hardpoint.GetHardpointID() )

	local cappingTeam = hardpoint.s.lastCappingTeam
	local previousOwner = hardpoint.s.previousOwner
	local enemyClose = false

	foreach( player in players )
	{
		// if opposing team and curHardpoint is hardpoint there is an enemy close
		if ( player.GetTeam() != cappingTeam && ( "curHardpoint" in player.s && player.s.curHardpoint == hardpoint ) )
		{
			enemyClose = true
			break
		}
	}

	local otherPoints = []
	local map = { a = 0, b = 1, c = 2 }
	switch ( hardpointStringID )
	{
		case "a":
			otherPoints = [ "b", "c" ]
			break

		case "b":
			otherPoints = [ "a", "c" ]
			break

		case "c":
			otherPoints = [ "a", "b" ]
			break
	}

	for ( local index = otherPoints.len() - 1; index >= 0; index-- )
	{
		local stringID = otherPoints[index]
		if ( level.hardpoints[ map[stringID] ].GetTeam() == cappingTeam )
			otherPoints.remove( index )
	}

	foreach ( player in players )
	{
		local team = player.GetTeam()

		if ( team != cappingTeam )
		{
			// not on the capping team
			if  ( team == previousOwner )
			{
				// team used to control the hardpoint
				local convAlias = "hardpoint_lost_all"

				if ( otherPoints.len() > 0 )
					convAlias = "hardpoint_lost_" + hardpointStringID

				PlayConversationToPlayer( convAlias, player )
			}
			continue
		}

		if ( hpTrig.IsTouching( player ) )
		{
			// touching the trigger and on the capping team
			local convAlias = "hardpoint_player_captured_" + hardpointStringID

			if ( enemyClose && CoinFlip() )
			{
				convAlias = "hardpoint_player_captured_enemy_" + hardpointStringID
			}
			else if ( otherPoints.len() == 2 )
			{
				convAlias = "hardpoint_player_captured_get_" + otherPoints[0] + otherPoints[1] + "_" + hardpointStringID
			}
			else if ( otherPoints.len() == 1 )
			{
				// play a more cocky line if we're ahead
				if ( GameScore.GS_GetWinningTeam() == cappingTeam && CoinFlip() )
					convAlias = "hardpoint_player_captured_get_one_" + hardpointStringID
				else
					convAlias = "hardpoint_player_captured_get_" + otherPoints[0] + "_" + hardpointStringID
			}

			PlayConversationToPlayer( convAlias, player )
		}
		else
		{
			// not touching the trigger but on the capping team
			local convAlias = "hardpoint_captured_" + hardpointStringID
			PlayConversationToPlayer( convAlias, player )
		}
	}
}


function HardpointVO_Progress( hardpoint, progress, capDuration )
{
	if ( !hardpoint.Enabled() )
		return

	hardpoint.Signal( "HardpointVO_Progress" )
	hardpoint.EndSignal( "HardpointVO_Progress" )

	local hardpointStringID = GetHardpointStringID( hardpoint.GetHardpointID() )
	local convAliasBase = (hardpoint.GetTeam() == TEAM_UNASSIGNED) ? "hardpoint_player_status_neutral_" : "hardpoint_player_status_"
	local cappingTeam = hardpoint.s.lastCappingTeam

	local convAlias
	local progressFrac

	if ( hardpoint.GetTeam() != TEAM_UNASSIGNED && hardpoint.GetTeam() != cappingTeam )
		progress = 1 - progress

	if ( fabs( progress ) < 0.25 )
		progressFrac = 0.25
	else if ( fabs( progress ) < 0.50 )
		progressFrac = 0.50
	else if ( fabs( progress ) < 0.75 )
		progressFrac = 0.75
	else
		return

	wait capDuration * (progressFrac - progress)

	while ( progressFrac <= 0.75 )
	{
		if ( progressFrac <= 0.25 )
			convAlias = convAliasBase + "25_" + hardpointStringID
		else if ( progressFrac <= 0.50 )
			convAlias = convAliasBase + "50_" + hardpointStringID
		else if ( progressFrac <= 0.75 )
			convAlias = convAliasBase + "75_" + hardpointStringID

		// capture points have been sped up; don't play dialog too often
		if ( ((hardpoint.GetTeam() == TEAM_UNASSIGNED) && progressFrac == 0.50)
			 || ((hardpoint.GetTeam() != TEAM_UNASSIGNED) && (progressFrac == 0.25 || progressFrac == 0.75)) )
		{
			local players = GetPlayerArray()
			foreach ( player in players )
			{
				if ( player.GetTeam() == cappingTeam && player.s.curHardpoint == hardpoint )
				{
					PlayConversationToPlayer( convAlias, player )
				}
			}
		}

		wait capDuration * 0.25

		progressFrac += 0.25
	}
}

function HardpointVO_Think( hardpoint )
{
	while ( GetGameState() <= eGameState.Playing )
	{
		local results = WaitSignal( hardpoint, "CapturePointStateChange" )
		if ( !hardpoint.Enabled() )
			continue

		//printt( "CapturePointStateChange", hardpoint, hardpoint.GetHardpointState() )

		local newState = hardpoint.GetHardpointState()
		local oldState = results.oldState
		local newTeam = hardpoint.GetTeam()
		local oldTeam = "oldTeam" in results ? results.oldTeam : newTeam

//		printt( oldState, newState, hardpoint )

		if ( oldState == CAPTURE_POINT_STATE_UNASSIGNED && newState == CAPTURE_POINT_STATE_CAPPING )
		{
			// starting capture of uncaptured point
			HardpointVO_StartCapping( hardpoint )
		}
		else if ( oldState == CAPTURE_POINT_STATE_CAPPING && newState == CAPTURE_POINT_STATE_CAPTURED )
		{
			// completed capturing hardpoint
			HardpointVO_Captured( hardpoint )

			foreach( player in hardpoint.s.teamPlayersTouching[ newTeam ] )
				Stats_IncrementStat( player, "misc_stats", "hardspointsCaptured", 1 )
		}
		else if ( oldState == CAPTURE_POINT_STATE_CAPPING && newState == CAPTURE_POINT_STATE_CAPPING )
		{
			// changed from owned by a team to neutral during capping
			if ( newTeam == TEAM_UNASSIGNED && oldTeam != newTeam )
				HardpointVO_Neutralize( hardpoint )
		}
		else if ( oldState == CAPTURE_POINT_STATE_CAPTURED && newState == CAPTURE_POINT_STATE_CAPPING )
		{
			// started capturing an unoccupied hardpoint
			HardpointVO_StartCapping( hardpoint )
		}
		else if ( oldState == CAPTURE_POINT_STATE_CAPTURED && newState == CAPTURE_POINT_STATE_HALTED )
		{
			// started capturing an occupied hardpoint
			HardpointVO_StartContested( hardpoint )
		}
		else if ( oldState == CAPTURE_POINT_STATE_HALTED && newState == CAPTURE_POINT_STATE_CAPTURED )
		{
			// prevented neutralizing of a captured hardpoint
		}
		else if ( oldState == CAPTURE_POINT_STATE_HALTED && newState == CAPTURE_POINT_STATE_CAPPING )
		{
			// cleared hardpoint OR exited and re-entered hardpoint
			HardpointVO_StartCapping( hardpoint )
		}
	}
}


function HardpointSpectresChangedTeam( point, team )
{
	//no spectres for neutralizing
	if( ( team != TEAM_IMC ) && ( team != TEAM_MILITIA ) )
		return

	//get the squad for this hardpoint
	local index = GetHardpointIndex( point )
	local squadName = MakeSquadName( point.GetTeam(), index )
	local squadMembers = GetNPCArrayBySquad( squadName )

	// spawn them
	local spawners = GetEntArrayByName_Expensive( point.kv.spectreTarget )
	//assert( spawners.len() > 0, "Broken spectre spawners " + point.GetName()  )

	foreach( spawn in spawners )
	{
		local spawnOrigin = spawn.GetOrigin()
		local spawnAngles = spawn.GetAngles()
		local spectre = SpawnSpectre( team, squadName, spawnOrigin, spawnAngles )
		squadMembers.append( spectre )
	}

	//tell them to guard here
	NPCsAssaultHardpoint( squadMembers, point )
}


const HARDPOINT_CLOSE_DIST = 768

// to be replaced with acutal triggers
function HardpointRadiusCheck()
{
	while ( true )
	{
		local players = GetPlayerArray()
		foreach ( player in players )
		{
			if ( !IsAlive( player ) )
				continue

			local playerWasCloseToHardPoint = false

			foreach ( hardpoint in level.hardpoints )
			{
				if ( !hardpoint.Enabled() )
					continue

				local distance = Distance( player.GetOrigin(), hardpoint.GetOrigin() )

				if ( distance < 1536 )
				{
					player.s.curHardpoint = hardpoint
					player.s.curHardpointDist = distance
					player.s.lastHardPointActivityTime = Time()

					if ( !player.s.curHardpointTime )
					{
						player.s.curHardpointTime = Time()
						CapturePointVO_Approaching( player, hardpoint, distance )
					}

					playerWasCloseToHardPoint = true
				}
				else if ( distance >= 1536 && hardpoint == player.s.curHardpoint )
				{
					player.s.curHardpoint = null
					player.s.curHardpointDist = null
					player.s.curHardpointTime = null
					Remote.CallFunction_NonReplay( player, "ServerCallback_CancelScene", 0 ) // this should be more robust... scene index, etc.. for next game
				}
			}

			if ( !playerWasCloseToHardPoint )
				CapturePointVO_Nag( player )
		}

		wait 0.5
	}
}

function PlayersInOuterRadius( team, hardpoint )
{
	local playerArray = GetPlayerArrayOfTeam( team )
	foreach( player in playerArray )
	{
		if ( player.s.curHardpoint == hardpoint )
			return true
	}
	return false
}

/*
both teams have 1.5 points for full duration
one point should award scoreLimit / 1.5 / timeLimitMinutes points per minute
*/
function CapturePoint_AwardTeamOwnedPoints( hardpoint )
{
	hardpoint.s.trigger.Signal( CP_AWARD_TEAM_OWNED_POINTS_SIGNAL )
	EndSignal( hardpoint.s.trigger, CP_AWARD_TEAM_OWNED_POINTS_SIGNAL )

	if ( hardpoint.GetTeam() == TEAM_UNASSIGNED )
		return

/*
	// 하드포인트에 가장 먼저 진입한 player 가 titan 탑승 상태일 때와 아닌 경우 포인트 다르게.
	// 하드포인트에 가장 먼저 진한 플레이어 찾는 코드 추가.
	// 단 파일럿 상태로 진입 후 캡쳐 진행 도중 타이탄 소환 및 탑승 시
	// 타이탄 상태로 점령한 포인트로 올라간다.
	// 원래는 capture point 는 없고 hold 포인트만 1씩 올려주고 있다.
	// Find the player who was in the trigger first
	local earliestPlayer = null
	local earliestTime = Time() + 1000

	foreach( player, time in hardpoint.s.teamPlayersTouching[ hardpoint.GetTeam() ] )
	{
		if ( !IsValid_ThisFrame( player ) )
			continue

		if ( time < earliestTime )
		{
			earliestPlayer = player
			earliestTime = time
		}
	}

	if ( !IsValid( earliestPlayer ) )
		return // lone player capping hardpoint probably disconnected

	local operatorControlled = false
	if ( !IsPlayer( earliestPlayer ) )
	{
		earliestPlayer = earliestPlayer.GetOwnerPlayer()
		//printl( "earliestPlayer was a marvin, owner = " + earliestPlayer.GetClassname() )
		if ( !earliestPlayer || !IsPlayer( earliestPlayer ) )
			return
		operatorControlled = true
	}


	if( earliestPlayer.IsTitan() )
		GameScore.AddTeamScore( hardpoint.GetTeam(), TEAMPOINTVALUE_HARDPOINT_CAPTURE_TITAN )
	else
		GameScore.AddTeamScore( hardpoint.GetTeam(), TEAMPOINTVALUE_HARDPOINT_CAPTURE )
	*/

	while( GetGameState() == eGameState.Playing )
	{
		Wait( TEAM_OWNED_SCORE_FREQ )
		GameScore.AddTeamScore( hardpoint.GetTeam(), TEAMPOINTVALUE_HARDPOINT_OWNED )
		if ( !GetCinematicMode() && !level.matchProgressAnnounceFunc ) //Don't use default progress announcements if something custom already enabled
		{
			CPMatchProgressDialogue( TEAM_IMC )
			CPMatchProgressDialogue( TEAM_MILITIA )
		}

	}
}

function CapturePoint_AwardPlayerHoldPoints( hardpoint )
{
	hardpoint.s.trigger.Signal( CP_AWARD_PLAYER_HOLD_POINTS_SIGNAL )
	EndSignal( hardpoint.s.trigger, CP_AWARD_PLAYER_HOLD_POINTS_SIGNAL )

	if ( hardpoint.GetTeam() == TEAM_UNASSIGNED )
		return

	while( GetGameState() == eGameState.Playing )
	{
		Wait( PLAYER_HELD_SCORE_FREQ )
		CapturePoint_AwardPlayerHoldPointsInternal( hardpoint )
	}
}

function CapturePoint_AwardPlayerPoints( hardpoint )
{
	if( GetGameState() != eGameState.Playing )
		return

	local teamToGetPoints = hardpoint.GetTeam()
	if ( hardpoint.GetTeam() == TEAM_UNASSIGNED )
		teamToGetPoints = hardpoint.s.lastCappingTeam

	/*
	if ( teamToGetPoints == TEAM_UNASSIGNED )
		printl( "TRYING TO AWARD PLAYER POINTS FOR TEAM: UNASSIGNED" )
	else if ( teamToGetPoints == TEAM_IMC )
		printl( "TRYING TO AWARD PLAYER POINTS FOR TEAM: IMC" )
	else if ( teamToGetPoints == TEAM_MILITIA )
		printl( "TRYING TO AWARD PLAYER POINTS FOR TEAM: MILITIA" )
	*/

	// There should be some players in the array, otherwise not sure how it could have possibly changed ownership
	Assert( teamToGetPoints != TEAM_UNASSIGNED )
	//Assert( hardpoint.s.teamPlayersTouching[ teamToGetPoints ].len() > 0 )

	// Find the player who was in the trigger first
	local earliestPlayer = null
	local earliestTime = Time() + 1000

	foreach( player, time in hardpoint.s.teamPlayersTouching[ teamToGetPoints ] )
	{
		if ( !IsValid_ThisFrame( player ) )
			continue

		if ( time < earliestTime )
		{
			earliestPlayer = player
			earliestTime = time
		}
	}

	if ( !IsValid( earliestPlayer ) )
		return // lone player capping hardpoint probably disconnected

	local operatorControlled = false
	if ( !IsPlayer( earliestPlayer ) )
	{
		earliestPlayer = earliestPlayer.GetOwnerPlayer()
		//printl( "earliestPlayer was a marvin, owner = " + earliestPlayer.GetClassname() )
		if ( !earliestPlayer || !IsPlayer( earliestPlayer ) )
			return
		operatorControlled = true
	}

	// Award points to the player who was in the trigger the soonest
	if ( hardpoint.GetTeam() == TEAM_UNASSIGNED )
	{
		AddPlayerScore( earliestPlayer, "ControlPointNeutralize" )
	}
	else
	{
		AddPlayerScore( earliestPlayer, "ControlPointCapture" )
	}

	// Give points to everyone else also standing in the trigger when it changed
	// Make an array of players instead of looping through them so we can avoid duplicates, because if an operator has multiple marvins in the trigger you dont want to award points for each OnEndTouch
	local playersToGetPoints = {}
	foreach ( player, time in hardpoint.s.teamPlayersTouching[ teamToGetPoints ] )
	{
		if ( !IsPlayer( player ) )
		{
			player = player.GetOwnerPlayer()
			if ( !IsPlayer( player ) )
				continue
		}

		if ( player == earliestPlayer )
			continue

		if ( player in playersToGetPoints )
			continue

		playersToGetPoints[ player ] <- true
	}

	// loop through the players array and award the points
	foreach ( player, val in playersToGetPoints )
	{
		if ( hardpoint.GetTeam() == TEAM_UNASSIGNED )
		{
			AddPlayerScore( player, "ControlPointNeutralizeAssist" )
		}
		else
		{
			AddPlayerScore( player, "ControlPointCaptureAssist" )
		}
	}
}

function CapturePoint_AwardPlayerHoldPointsInternal( hardpoint )
{
	if( GetGameState() != eGameState.Playing )
		return

	local teamToGetPoints = hardpoint.GetTeam()
	if ( teamToGetPoints == TEAM_UNASSIGNED )
		teamToGetPoints = hardpoint.s.lastCappingTeam

	local players = GetPlayerArrayOfTeam( teamToGetPoints )

	foreach ( player in players )
	{
		Assert( "curHardpoint" in player.s && "curHardpointTime" in player.s )

		if ( !IsAlive( player ) || player.s.curHardpoint == null || player.s.curHardpointTime == null )
			continue

		if ( player.s.curHardpoint == hardpoint && player.s.curHardpointDist < 800 )
		{
			if ( (Time() - player.s.curHardpointTime) >= PLAYER_HELD_SCORE_FREQ )
			{
				local numHeldPoints = 0
				foreach ( hardpoint in level.hardpoints )
				{
					if ( hardpoint.GetTeam() != player.GetTeam() )
						continue

					numHeldPoints++
				}

				if ( numHeldPoints )
					AddPlayerScore( player, "ControlPointHold", null, POINTVALUE_HARDPOINT_HOLD /* numHeldPoints*/ )
			}
		}
	}
}

function CapturePoint_OnPlayerOrNPCKilled( entity, attacker, damageInfo )
{
	local attacker = damageInfo.GetAttacker()
	local attackerTeam = attacker.GetTeam()
	local entTeam = entity.GetTeam()

	if ( attackerTeam != entTeam && ( entity.IsNPC() && entity.GetBodyType() == "human" ) && ( attackerTeam == TEAM_IMC || attackerTeam == TEAM_MILITIA ) )
	{
		local hardpointID = GetCurrentHardpointID( attacker )
	}

	if ( attackerTeam != entTeam && attacker.IsPlayer() )
		CapturePointKillScoreEvent( entity, attacker )

	// clear hardpoint ID now that we don't need it anymore for callbacks
	ClearCurrentHardpointID( entity )
}


function CapturePointSwitchPlayer( player, oldTeam, newTeam )
{
	local hpID = GetCurrentHardpointID( player )

	if ( hpID == null )
		return

	local hardpoint = GetHardpointByID( hpID )
	Assert( hardpoint != null )

	if ( player in hardpoint.s.teamPlayersTouching[ oldTeam ] )
	{
		delete hardpoint.s.teamPlayersTouching[ oldTeam ][ player ]

		Assert( !( player in hardpoint.s.teamPlayersTouching[ newTeam ] ) )
		hardpoint.s.teamPlayersTouching[ newTeam ][ player ] <- Time()
	}
}

//////////////////////////////////////////////////////////
function SetupCapturePointNPCs( hardpointArray )
{
	FlagEnd( "disable_npcs" )

	FlagWait( "ReadyToStartMatch" )

	local waitTime = GameTime.TimeLeftSeconds() - GetDropPodAnimDuration() + 3

	if ( GetGameState() <= eGameState.Prematch && waitTime > 0 )
		wait waitTime

	thread CapturePointSpawnNPCsThink()	//default CP spawn logic
}
Globalize( SetupCapturePointNPCs )

//////////////////////////////////////////////////////////
function CapturePointSpawnNPCsThink()
{
	FlagEnd( "disable_npcs" )

	local teams = [TEAM_IMC, TEAM_MILITIA]

	while ( IsNPCSpawningEnabled() )
	{
		if ( !Flag( "Disable_IMC" ) )
			thread CapturePointSpawnNPCs( TEAM_IMC )
		if ( !Flag( "Disable_MILITIA" ) )
			thread CapturePointSpawnNPCs( TEAM_MILITIA )

		wait CP_REINFORCE_INTERVAL
	}
}


//////////////////////////////////////////////////////////
function CapturePointSpawnNPCs( team )
{
	local numFreeSlots = GetFreeAISlots( team )

	// while we have enough free slots try to spawn in a squad
	while ( numFreeSlots >= GetSpawnSquadSize( team ) )
	{
		// if no spawn happened break out of this loop.
		if ( !SpawnCapturePointSquad( team, numFreeSlots ) )
			break

		// add a little wait so that we don't spawn squads at the exact same time.
		wait RandomFloat( 0.3, 0.7 )

		// the function above will have used up some free slots, lets see how many remain
		numFreeSlots = GetFreeAISlots( team )
	}
}


//////////////////////////////////////////////////////////
function SpawnCapturePointSquad( team, numFreeSlots )
{
	if ( !IsNPCSpawningEnabled() )
		return false

	local spawnCount = min( numFreeSlots, GetSpawnSquadSize( team ) )
	Assert( spawnCount <= GetFreeAISlots(team) )

	local squadName
	local spawnPointArray
	local capturepoint

	local useStartSpawn = GetGameState() <= eGameState.Prematch
	if ( !useStartSpawn && GetGameState() <= eGameState.Playing )
		useStartSpawn = GameTime.PlayingTime() < 5.0

	if ( useStartSpawn )
	{
		local shouldSpawnSpectre = ShouldSpawnSpectre( team )

		local squadIndex = TryGetSmallestValidSquad( team, shouldSpawnSpectre )
		if ( squadIndex == null )
			return false

		squadName = MakeSquadName( team, squadIndex )
		capturepoint = level.hardpoints[ squadIndex ]

		// use start spawnpoints of the correct team
		spawnPointArray = SpawnPoints_GetDropPodStart( team )

		Assert( /*level.isTestmap ||*/ spawnPointArray.len(), "level didn't have any info_spawnpoint_droppod_start for team " + team )
		if ( !spawnPointArray.len() )
		{
			useStartSpawn = false
			spawnPointArray = SpawnPoints_GetDropPod()
		}
	}
	else
	{
		// CP mode is still using hardpoints to define the capture area
		foreach( index, hardpoint in level.hardpoints )
		{
			local hardpointState = hardpoint.GetHardpointState()
			local owned = hardpoint.GetHardpointState() == CAPTURE_POINT_STATE_CAPTURED && hardpoint.GetTeam() == team

			local hasPlayer = PlayersInOuterRadius( team, hardpoint )
			if( !hasPlayer && !owned )
				continue

			squadName = MakeSquadName( team, index )
			local squadSize = GetNPCSquadSize( squadName )
			squadSize += GetReservedAISquadSlots( squadName )	// add on any reserved AI squad slots

			if ( squadSize > 0 )
				continue

			capturepoint = hardpoint
			break
		}

		// don't spawn if no capturepoint was found.
		if ( !capturepoint )
			return false

		spawnPointArray = SpawnPoints_GetDropPod()
	}

	// if something got this far and we don't have any spawnpoints then something is wrong.
	Assert( spawnPointArray.len() )

	local spawnPoint
	if ( useStartSpawn )
		spawnPoint = GetCapturePointSpawnPoint_StartSpawn( spawnPointArray, team, capturepoint )
	else
		spawnPoint = GetCapturePointSpawnPoint( spawnPointArray, team, capturepoint )

	Assert( spawnPoint )
	level.aiSpawnCounter[ team ]++

	Assert( spawnCount <= GetFreeAISlots(team) )

	thread SpawnCapturePointSquadAndHoldHardpoint( spawnPoint, team, spawnCount, squadName, capturepoint )

	return true
}

function SpawnSquadAtHardpoint( capturepoint, team, squadSize = 4 )
{
	// squad spawns in a dropship, enters and holds hardpoint
	local squadName = UniqueString( CAPTURE_POINT )

	local spawnPointArray = SpawnPoints_GetDropPod()
	// if something got this far and we don't have any spawnpoints then something is wrong.
	Assert( spawnPointArray.len() )

	local spawnPoint = GetCapturePointSpawnPoint( spawnPointArray, team, capturepoint )
	Assert( spawnPoint )
	level.aiSpawnCounter[ team ]++
	capturepoint.s.assaultPointAI_Total += squadSize

	Assert( squadSize <= GetFreeAISlots(team) )

	local npcArray
	//--------------------------------------
	// Default CP spawning behavior
	//--------------------------------------
	if ( ShouldSpawnSpectre( team ) )
	{
		npcArray = Spawn_TrackedDropPodSpectreSquad( team, squadSize, spawnPoint, squadName )
	}
	else
	{
		if ( level.aiSpawnCounter[ team ] % 3 == 0 ) // 1 in every 3 grunt squad comes in via ship
			npcArray = Spawn_TrackedZipLineGruntSquad( team, squadSize, spawnPoint, squadName )
		else
			npcArray = Spawn_TrackedDropPodGruntSquad( team, squadSize, spawnPoint, squadName )
	}

	NPCsAssaultHardpoint( npcArray, capturepoint )
	return npcArray
}
Globalize( SpawnSquadAtHardpoint )

function SpawnSpectreDefenders( capturepoint, team, squadSize = 4 )
{
	// squad spawns in a dropship, enters and holds hardpoint
	local squadName = UniqueString( CAPTURE_POINT )

	local spawnPointArray = SpawnPoints_GetDropPod()
	// if something got this far and we don't have any spawnpoints then something is wrong.
	Assert( spawnPointArray.len() )

	local spawnPoint = GetCapturePointSpawnPoint( spawnPointArray, team, capturepoint )
	Assert( spawnPoint )
	level.aiSpawnCounter[ team ]++
	capturepoint.s.assaultPointAI_Total += squadSize

	Assert( squadSize <= GetFreeAISlots(team) )

	local npcArray = Spawn_TrackedDropPodSpectreSquad( team, squadSize, spawnPoint, squadName )

	NPCsAssaultHardpoint( npcArray, capturepoint )
	return npcArray
}
Globalize( SpawnSpectreDefenders )

//////////////////////////////////////////////////////////
function SpawnCapturePointSquadAndHoldHardpoint( spawnPoint, team, squadSize, squadName, capturepoint )
{
	local npcArray

	//------------------------------------------------
	// Team owns the CP and we want to use custom level spawns
	//------------------------------------------------
	// Set with AddHardpointCustomSpawnCallback()
	if ( ( level.cpCustomSpawnFunc ) && ( capturepoint.GetTeam() == team ) )
	{
		local callbackInfo = level.cpCustomSpawnFunc
		npcArray = callbackInfo.func.acall( [ callbackInfo.scope, capturepoint, team, squadSize, squadName ] )
	}

	if ( !npcArray )
	{
		Assert( squadSize <= GetFreeAISlots(team) )

		//--------------------------------------
		// Default CP spawning behavior
		//--------------------------------------
		if ( ShouldSpawnSpectre( team ) )
		{
			npcArray = Spawn_TrackedDropPodSpectreSquad( team, squadSize, spawnPoint, squadName )
		}
		else
		{
			if ( level.aiSpawnCounter[ team ] % 3 == 0 ) // 1 in every 3 grunt squad comes in via ship
				npcArray = Spawn_TrackedZipLineGruntSquad( team, squadSize, spawnPoint, squadName )
			else
				npcArray = Spawn_TrackedDropPodGruntSquad( team, squadSize, spawnPoint, squadName )
		}
	}

	thread SquadCapturePointThink( squadName, capturepoint, team )
}
Globalize( SpawnCapturePointSquadAndHoldHardpoint )

//////////////////////////////////////////////////////////
function GetCapturePointSpawnPoint( spawnPointArray, team, capturepoint )
{
	SpawnPoints_InitRatings( null )

	foreach ( spawnpoint in spawnPointArray )
		RateCapturePointNPCSpawnpoint( spawnpoint, team, capturepoint )

	SpawnPoints_SortDropPod()
	spawnPointArray = SpawnPoints_GetDropPod()

	return FindValidDropInSpawnpoints( spawnPointArray, team )
}
Globalize( GetCapturePointSpawnPoint )

//////////////////////////////////////////////////////////
function GetCapturePointSpawnPoint_StartSpawn( spawnPointArray, team, capturepoint )
{
	SpawnPoints_InitRatings( null )

	foreach ( spawnpoint in spawnPointArray )
		RateCapturePointNPCSpawnpoint( spawnpoint, team, capturepoint )

	SpawnPoints_SortDropPodStart()
	spawnPointArray = SpawnPoints_GetDropPodStart( team )

	return FindValidDropInSpawnpoints( spawnPointArray, team )
}

function FindValidDropInSpawnpoints( spawnPointArray, team )
{
	foreach ( spawnpoint in spawnPointArray )
	{
		if ( IsSpawnpointValidDrop( spawnpoint, team ) )
			return spawnpoint
	}

	// we will always return a spawnpoint even if it's a bad one.
	return spawnPointArray[0]
}


//////////////////////////////////////////////////////////
function RateCapturePointNPCSpawnpoint( spawnpoint, team, capturepoint )
{
	// away from titans but as close to the capture point as possible.

	local titanFriendlyRating = spawnpoint.NearbyAllyScore( team, "titan" )
	local titanEnemyRating = spawnpoint.NearbyEnemyScore( team, "titan" )
	local npcEnemyRating = spawnpoint.NearbyEnemyScore( team, "ai" )
	local npcFriendlyRating = spawnpoint.NearbyAllyScore( team, "ai" )
	local pilotFriendlyRating = spawnpoint.NearbyAllyScore( team, "wallrun" )
	local pilotEnemyRating = spawnpoint.NearbyEnemyScore( team, "wallrun" )

	local capturepointRating = SpawnPoint_CapturePointScore( spawnpoint, capturepoint )

	titanEnemyRating		*= 2.0
	pilotEnemyRating		*= 0.25
	npcEnemyRating			*= 0.0
	titanFriendlyRating		*= 0.0
	pilotFriendlyRating		*= 0.0
	npcFriendlyRating		*= 0.0

	capturepointRating		*= 4.0

	local enemyTotal = titanEnemyRating + pilotEnemyRating + npcEnemyRating
	local friendlyTotal = titanFriendlyRating + pilotFriendlyRating + npcFriendlyRating
	local rating = friendlyTotal - enemyTotal + capturepointRating

	spawnpoint.CalculateRating( TD_AI, team, rating, 0 )

	return rating
}

//////////////////////////////////////////////////////////
function SpawnPoint_CapturePointScore( spawnpoint, capturepoint )
{
	local nearDistSqr = 256 * 256
	local farDistSqr = 6000 * 6000

	local score = 0
	local spawnOrigin = spawnpoint.GetOrigin()

	local distSqr = DistanceSqr( capturepoint.GetOrigin(), spawnOrigin )
	score += GraphCapped( distSqr, nearDistSqr, farDistSqr, 1, 0 )

	return score
}

//////////////////////////////////////////////////////////
function CapturePointKillScoreEvent( victim, player )
{
	local victimHardpoint = null
	local playerHardpoint = null

	local victim_hpID = GetCurrentHardpointID( victim )
	local player_hpID = GetCurrentHardpointID( player )

	if ( victim_hpID == null && player_hpID == null )
		return

	if ( victim.GetTeam() != TEAM_IMC && victim.GetTeam() != TEAM_MILITIA )
		return

	if ( victim_hpID != null )
		victimHardpoint = GetHardpointByID( victim_hpID )

	if ( player_hpID != null )
		playerHardpoint = GetHardpointByID( player_hpID )

	// the score bonuses below currently only get awarded when the hardpoint is owned by one of the teams
	if ( ( victimHardpoint && victimHardpoint.GetTeam() == TEAM_UNASSIGNED ) && ( playerHardpoint && playerHardpoint.GetTeam() == TEAM_UNASSIGNED ) )
		return

	local scoreEventAlias = null

	// both players are in the same hardpoint
	if ( victimHardpoint && playerHardpoint && ( victimHardpoint == playerHardpoint ) )
	{
		local sharedHardpoint = victimHardpoint

		// victim team owns the hardpoint
		if ( sharedHardpoint.GetTeam() == victim.GetTeam() )
			scoreEventAlias = "HardpointAssault"
		// player team owns the hardpoint
		else if ( sharedHardpoint.GetTeam() == player.GetTeam() )
			scoreEventAlias = "HardpointDefense"
	}
	// victim is in the hardpoint, player is not
	else if ( victimHardpoint && !playerHardpoint )
	{
		if ( victimHardpoint.GetTeam() != TEAM_UNASSIGNED )
		{
			local dist = Distance( player.GetOrigin(), victim.GetOrigin() )

			if ( dist >= HARDPOINT_RANGED_ASSAULT_DIST )
				scoreEventAlias = "HardpointSnipe"
			else
				scoreEventAlias = "HardpointSiege"
		}
	}
	// player is in the hardpoint, victim is not
	else if ( playerHardpoint && !victimHardpoint )
	{
		if ( playerHardpoint.GetTeam() == player.GetTeam() )
		{
			local dist = Distance( player.GetOrigin(), victim.GetOrigin() )

			if ( dist <= HARDPOINT_PERIMETER_DEFENSE_RANGE )
				scoreEventAlias = "HardpointPerimeterDefense"
		}
	}

	if ( scoreEventAlias )
	{
		if ( victim.IsNPC() )
			scoreEventAlias += "NPC"

		AddPlayerScore( player, scoreEventAlias, victim )
	}
}

//////////////////////////////////////////////////////////
function CapturePointVO_Allowed( player )
{
	return ( GetGameState() == eGameState.Playing && player.s.hasDoneTryGameModeAnnouncement )
}


//////////////////////////////////////////////////////////
function CapturePointVO_Approaching( player, hardpoint, distance )
{
	if ( !CapturePointVO_Allowed( player ) )
		return

	local team = player.GetTeam()

	if ( hardpoint.s.lastCappingTeam == player.GetTeam() )
		return

	local powerTable = GetCapPower( hardpoint )

	if ( powerTable.contested )
	{
		if ( hardpoint.s.startCapTime && Time() - hardpoint.s.startCapTime > 5.0 )
			return

		if ( hardpoint.s.lastCapTime && Time() - hardpoint.s.lastCapTime < 8.0 )
			return
	}

	local hardpointStringID = GetHardpointStringID( hardpoint.GetHardpointID() )

	local vector = hardpoint.GetOrigin() - player.GetOrigin()
	vector.Norm()
	local view = player.GetViewVector()
	local dot = vector.Dot( view )

	local team = player.GetTeam()
	local otherTeam = team == TEAM_IMC ? TEAM_MILITIA : TEAM_IMC
	local powerTable = GetCapPower( hardpoint )
	local haveEnemies = ( otherTeam == powerTable.strongerTeam || powerTable.contested )

	if ( haveEnemies )
	{
		// player is closing in on a enemy occupied hardpoint
		PlayConversationToPlayer( "hardpoint_player_approach_enemy_" + hardpointStringID, player )
	}
	else if ( dot > 0.86 ) // ~30 degree
	{
		// player is facing the hardpoint
		PlayConversationToPlayer( "hardpoint_player_approach_ahead_" + hardpointStringID, player )
	}
	else
	{
		// player is looking away from the hardpoint, be less specific with the dialog
		PlayConversationToPlayer( "hardpoint_player_approach_" + hardpointStringID, player )
	}
	return true
}


//////////////////////////////////////////////////////////
function CapturePointVO_Nag( player )
{
	if ( !CapturePointVO_Allowed( player ) )
		return

	Assert( player.IsPlayer() )

	Assert( IsAlive( player ) ) //Checked before we got in here, but checking again

	local timeSinceLastHardPointActivity = Time() - player.s.lastHardPointActivityTime

	if ( timeSinceLastHardPointActivity >  CP_NAG_DEBOUNCE_TIME )
	{
		//printt( "Nagging because timeSinceLastHardPointActivity is: " + timeSinceLastHardPointActivity )
		PlayConversationToPlayer( "hardpoint_nag",  player )
		player.s.lastHardPointActivityTime = Time()
	}
	/*else
	{
		printt( "No need to nag because timeSinceLastHardPointActivity: " + timeSinceLastHardPointActivity )

	}*/

}


function GetNumHardpointsInArray( array )
{
	local count = 0
	foreach( item in array )
	{
		if ( item != null )
			count++
	}
	return count
}

function AddHardpointToArray( array, val )
{
	foreach( i, item in array )
	{
		if ( item == null )
		{
			array[ i ] = val
			return
		}
	}
	array.append( val )
}

//////////////////////////////////////////////////////////////////////////////////////////
// Call a custom function that overrides the CP spawn logic (used in some cinematic levels)
function AddHardpointCustomSpawnCallback( callbackFunc )
{
	Assert( "cpCustomSpawnFunc" in level )
	Assert( type( this ) == "table", "CapturePointSetupCustomSpawnFunc can only be added on a table. " + type( this ) )
	AssertParameters( callbackFunc, 4, "capturepoint, team, squadSize, squadName" )

	local name = FunctionToString( callbackFunc )
	local callbackInfo = {}
	callbackInfo.name <- name
	callbackInfo.func <- callbackFunc
	callbackInfo.scope <- this

	level.cpCustomSpawnFunc = callbackInfo
}

//////////////////////////////////////////////////////////////////////////////////////////
// Hardpoint match progress stuff
function CPMatchProgressDialogue( team )
{
	local score = GameRules.GetTeamScore( team )
	local scoreLimit = GetScoreLimit_FromPlaylist()
	local scoreProgress = ( score.tofloat() / scoreLimit.tofloat() ) * 100.0

	//printt( "scoreProgress:" + scoreProgress + " for team: " + team )

	local alias = null

	if ( scoreProgress >= 75.0 )
		alias = "hardpoint_match_progress_75_percent"
	else if ( scoreProgress >= 50.0 )
		alias = "hardpoint_match_progress_50_percent"
	else if ( scoreProgress >= 25.0 )
		alias = "hardpoint_match_progress_25_percent"

	if ( !alias )
		return

	//printt( "Alias: " + alias )

	if ( !level.cpMatchProgressDialog[ team ][ alias ] )
	{
		level.cpMatchProgressDialog[ team ][ alias ] = true
		PlayConversationToTeam( alias, team )
	}

}