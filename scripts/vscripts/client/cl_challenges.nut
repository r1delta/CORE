
const CHALLENGE_POPUP_IN_TIME 			= 0.15
const CHALLENGE_POPUP_OUT_TIME 			= 0.3
const CHALLENGE_POPUP_DURATION 			= 3.5
const CHALLENGE_POPUP_TIMEOUT_ENABLED 	= true
const CHALLENGE_POPUP_TIMEOUT 			= 10.0	// Any challenge waiting in queue for this amount of time is forgotten about. Exception is challenge completion, they always show up

level.challengePopupQueue <- []

RegisterSignal( "ChallengePopup" )
RegisterSignal( "ChallengeQueueUpdated" )

enum ePopupType
{
	NEW,
	PROGRESS,
	COMPLETED,
}

function main()
{
	Globalize( InitChallengePopup )
	Globalize( ShowChallengePopup )
	Globalize( ServerCallback_UpdateClientChallengeProgress )
	Globalize( GetClosestWeaponChallengeRef )
	Globalize( ChallengePopup_AddPlayer )
}

function GetClosestWeaponChallengeRef( weaponRef, player )
{
	if ( !(weaponRef in level.challengeRefsForWeapon ) )
		return

	local playerLevel = GetLevel( player )

	if ( IsItemLocked( "challenges", null, player ) )
		return

	if ( GetLevel( player ) < GetUnlockLevelReq( weaponRef, 999 ) + 3 )
		return

	local bestRef = null
	local bestFrac = 0
	foreach ( challengeRef in level.challengeRefsForWeapon[weaponRef] )
	{
		local challengeProgressFrac = GetCurrentChallengeProgressFrac( challengeRef, player )

		if ( challengeProgressFrac > bestFrac )
		{
			bestFrac = challengeProgressFrac
			bestRef = challengeRef
		}
	}

	printt( bestRef, bestFrac )

	if ( bestFrac < 0.5 )
		return

	return bestRef
}

function InitChallengePopup()
{
	local player = GetLocalClientPlayer()
	InitPlayerChallenges( player )
}

function ServerCallback_UpdateClientChallengeProgress( challengeID, progress, showPopup )
{
	local player = GetLocalClientPlayer()
	if ( !IsValid( player ) )
		return

	// Get information about the challenge before we update it
	local ref 				= GetChallengeRefFromID( challengeID )
	local challengeName 	= GetChallengeName( ref, player )
	local challengeDesc 	= GetChallengeDescription( ref )
	local challengeProgress = GetCurrentChallengeProgress( ref, player )
	local challengeGoal 	= GetCurrentChallengeGoal( ref, player )
	local oldProgress 		= GetCurrentChallengeProgress( ref, player )
	local oldTier 			= GetCurrentChallengeTier( ref, player )
	local flags				= GetChallengeFlags( ref )

	// Update local table of challenge progress
	UpdateLocalChallengeProgress( ref, player, null, progress )

	if ( !showPopup )
		return

	// Determine what type of popup it is based on old progress and new progress
	challengeProgress 	= GetCurrentChallengeProgress( ref, player )
	local newTier 		= GetCurrentChallengeTier( ref, player )
	local popupType 	= null

	if ( newTier > oldTier || ( challengeProgress > oldProgress && challengeProgress == challengeGoal ) )
	{
		// We just completed a challenge
		popupType = ePopupType.COMPLETED

		// Clamp challenge progress to that tiers progress
		challengeProgress = GetGoalForChallengeTier( ref, oldTier )
	}
	else
	{
		challengeName 		= GetChallengeName( ref, player )
		challengeDesc 		= GetChallengeDescription( ref )
		challengeGoal 		= GetCurrentChallengeGoal( ref, player )

		// Did we just start the challenge or is this an update
		if ( oldProgress == 0 && progress > 0 )
			popupType 		= ePopupType.NEW
		else
			popupType 		= ePopupType.PROGRESS
	}
	Assert( popupType != null )

	// Add the popup to the popup queue
	AddChallengePopupToQueue( ref, popupType, challengeName, challengeDesc, challengeProgress, challengeGoal, newTier, flags )
}

function AddChallengePopupToQueue( ref, popupType, challengeName, challengeDesc, challengeProgress, challengeGoal, tier, flags )
{
	local popupInfo = {}
	popupInfo.ref 					<- ref
	popupInfo.popupType 			<- popupType
	popupInfo.challengeName 		<- challengeName
	popupInfo.challengeDesc 		<- challengeDesc
	popupInfo.challengeProgress 	<- challengeProgress
	popupInfo.challengeGoal 		<- challengeGoal
	popupInfo.tier 					<- tier
	popupInfo.flags 				<- flags
	popupInfo.createTime			<- Time()

	// Remove any earlier popup messages in the que that are for the same challenge because they are now old info
	local removed = false
	while(1)
	{
		removed = false
		foreach( index, table in level.challengePopupQueue )
		{
			if ( table.ref == ref )
			{
				level.challengePopupQueue.remove( index )
				removed = true
				break
			}
		}
		if ( !removed )
			break
	}

	// Add this to the queue and tell queue system an item was added
	level.challengePopupQueue.append( popupInfo )
	Signal( level.challengePopupQueue, "ChallengeQueueUpdated" )
}

function ChallengePopup_AddPlayer( player )
{
	if ( player != GetLocalClientPlayer() )
		return
	thread ChallengePopupQueueThink( player )
}

function ChallengePopupQueueThink( player )
{
	player.EndSignal( "OnDestroy" )

	while( IsValid( player ) )
	{
		if ( level.challengePopupQueue.len() == 0 )
			WaitSignal( level.challengePopupQueue, "ChallengeQueueUpdated" )

		// Remove popups that have been in the queue longer than the timeout duration
		RemoveTimedOutPopups()
		if ( level.challengePopupQueue.len() == 0 )
			continue

		Assert( level.challengePopupQueue.len() > 0 )

		// Sort the queue level.challengePopupQueue
		level.challengePopupQueue.sort( ChallengePopupSortFunc )

		local popupInfo = level.challengePopupQueue[0]
		level.challengePopupQueue.remove( 0 )
		thread ShowChallengePopup( popupInfo )
		wait CHALLENGE_POPUP_IN_TIME + CHALLENGE_POPUP_DURATION
	}
}

function RemoveTimedOutPopups()
{
	if ( !CHALLENGE_POPUP_TIMEOUT_ENABLED )
		return

	local currentTime = Time()
	local newArray = []

	foreach( popupInfo in level.challengePopupQueue )
	{
		if ( popupInfo.popupType == ePopupType.COMPLETED || ( currentTime - popupInfo.createTime <= CHALLENGE_POPUP_TIMEOUT ) )
			newArray.append( popupInfo )
	}

	level.challengePopupQueue = newArray
}

function ChallengePopupSortFunc( a, b )
{
	// Challenge completion popups take priority, then new, then progress
	local priorityOrder = {}
	priorityOrder[ ePopupType.PROGRESS ] <- 0
	priorityOrder[ ePopupType.NEW ] <- 1
	priorityOrder[ ePopupType.COMPLETED ] <- 2
	if ( priorityOrder[ a.popupType ] > priorityOrder[ b.popupType ] )
		return -1
	else if ( priorityOrder[ b.popupType ] > priorityOrder[ a.popupType ] )
		return 1

	// Challenge popup types are the same, take other factors into account
	Assert( a.popupType == b.popupType )

	// Challenges of higher priority are more important
	if ( ( a.flags & CF_PRIORITY_HIGH ) && !( b.flags & CF_PRIORITY_HIGH ) )
		return -1
	else if ( ( b.flags & CF_PRIORITY_HIGH ) && !( a.flags & CF_PRIORITY_HIGH ) )
		return 1

	if ( ( a.flags & CF_PRIORITY_LOW ) && !( b.flags & CF_PRIORITY_LOW ) )
		return 1
	else if ( ( b.flags & CF_PRIORITY_LOW ) && !( a.flags & CF_PRIORITY_LOW ) )
		return -1

	// Challenges have the same priority

	// Challenges of higher tiers are more important
	if ( a.tier > b.tier )
		return -1
	else if ( b.tier > a.tier )
		return 1

	// Challenges are of the same tier
	Assert( a.tier == b.tier )

	return 0
}

function ShowChallengePopup( popupInfo )
{
	if ( GetGameState() >= eGameState.Postmatch )
		return

	if ( popupInfo.popupType != ePopupType.COMPLETED )
		return

	Signal( file, "ChallengePopup" )
	EndSignal( file, "ChallengePopup" )

	local challengeLocString = popupInfo.challengeName[0]
	popupInfo.challengeName.remove(0)
	for ( local i = popupInfo.challengeName.len() ; i < 5 ; i++ )
		popupInfo.challengeName.append( null )
	Assert( popupInfo.challengeName.len() == 5 )
	AnnouncementMessage( GetLocalClientPlayer(), "#CHALLENGE_POPUP_HEADER_COMPLETED", challengeLocString, [255, 215, 35], [null, null, null, null, null], popupInfo.challengeName, "UI_InGame_ChallengeCompleted" )

	//if ( popupInfo.challengeDesc.len() == 1 )
	//	file.challengePopupDesc.SetText( popupInfo.challengeDesc[0], popupInfo.challengeGoal )
	//else
	//	file.challengePopupDesc.SetText( popupInfo.challengeDesc[0], popupInfo.challengeGoal, popupInfo.challengeDesc[1] )
}