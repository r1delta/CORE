
const FILL_TIME_PER_BAR = 5.0
const REVEAL_WAVE_TIMING = 0.2

menu <- null
buttonsRegistered <- false
menuInitFinished <- false
menuAnimDone <- false
challengeBoxes <- []
challengeButtons <- []
challengeRewardPanels <- []
challengeBarsFilling <- 0
revealOrder <- [ 0, 1, 2, ]

filterOrder <- [ "most_progress", "complete", "almost_complete", "tracked" ]

function main()
{
	Globalize( OnOpenEOG_Challenges )
	Globalize( OnCloseEOG_Challenges )
	Globalize( CycleChallengeView )
	Globalize( GetNextChallengeView )
	Globalize( EOGChallenges_FooterData )
	Globalize( CycleChallengeViewInternal )
	Globalize( EOGChallengeButton_GotFocus )
	Globalize( EOGChallengeButton_LostFocus )
}

function InitMenu()
{
	Assert( menu != null )

	// Buttons & Background
	SetupEOGMenuCommon( menu )

	if ( menuInitFinished )
		return

	// Challenge Boxes
	for( local i = 0 ; i < NUM_EOG_CHALLENGE_BOXES ; i++ )
	{
		local box = GetElem( menu, "challenge" + i )
		Assert( box != null )
		box.s.challengeRef <- null
		box.s.challengeTier <- null
		box.Hide()
		challengeBoxes.append( box )

		local button = GetElem( menu, "ChallengeButton" + i )
		Assert( button != null )
		button.AddEventHandler( UIE_GET_FOCUS, Bind( EOGChallengeButton_GotFocus ) )
		button.AddEventHandler( UIE_LOSE_FOCUS, Bind( EOGChallengeButton_LostFocus ) )
		button.SetEnabled( false )
		challengeButtons.append( button )

		local panel = GetElem( menu, "ChallengeRewardPanel" + i )
		Assert( panel != null )
		panel.Hide()
		challengeRewardPanels.append( panel )
	}

	menuInitFinished = true
}

function OnOpenEOG_Challenges()
{
	Assert( EOGHasChallengesToShow(), "EOG Challenges menu was somehow opened when there were no challenges with progress. This shouldn't be possible" )

	// This makes the first default page be the first page with actual content
	if ( uiGlobal.EOGChallengeFilter == null )
	{
		uiGlobal.EOGChallengeFilter = filterOrder[ filterOrder.len() - 1 ]
		uiGlobal.EOGChallengeFilter = GetNextChallengeView()
	}

	menu = GetMenu( "EOG_Challenges" )
	level.currentEOGMenu = menu
	Signal( menu, "StopMenuAnimation" )
	EndSignal( menu, "StopMenuAnimation" )
	Signal( level, "CancelEOGThreadedNavigation" )

	InitMenu()

	thread OpenMenuAnimated()

	EOGOpenGlobal()

	if ( !buttonsRegistered )
	{
		buttonsRegistered = true
		RegisterButtonPressedCallback( BUTTON_A, OpenMenuStatic )
		RegisterButtonPressedCallback( KEY_SPACE, OpenMenuStatic )
		RegisterButtonPressedCallback( BUTTON_Y, CycleChallengeView )
	}

	if ( !level.doEOGAnimsChallenges )
		OpenMenuStatic(false)
}

function OnCloseEOG_Challenges()
{
	thread EOGCloseGlobal()

	if ( buttonsRegistered )
	{
		DeregisterButtonPressedCallback( BUTTON_A, OpenMenuStatic )
		DeregisterButtonPressedCallback( KEY_SPACE, OpenMenuStatic )
		DeregisterButtonPressedCallback( BUTTON_Y, CycleChallengeView )
		buttonsRegistered = false
	}

	level.doEOGAnimsChallenges = false
	menuAnimDone = false
	Signal( menu, "StopMenuAnimation" )
}

function OpenMenuAnimated()
{
	EndSignal( menu, "StopMenuAnimation" )
	challengeBarsFilling = 0

	if ( level.doEOGAnimsChallenges )
		EmitUISound( "Menu_GameSummary_ScreenSlideIn" )
	else
		EmitUISound( "EOGSummary.XPBreakdownPopup" )

	local challengesLockedLabel = GetElem( menu, "ChallengesLockedLabel" )
	challengesLockedLabel.Hide()

	UpdateFooterButtons()

	if ( !EOGHasChallengesToShow() )
	{
		if ( IsItemLocked( "challenges" ) )
			challengesLockedLabel.SetText( "#EOG_CHALLENGES_LOCKED", GetItemLevelReq( "challenges" ) )
		else
			challengesLockedLabel.SetText( "#EOG_NO_CHALLENGE_PROGRESS" )

		challengesLockedLabel.Show()
		uiGlobal.eog_challengesToShow[ "most_progress" ] = []
		uiGlobal.eog_challengesToShow[ "complete" ] = []
		uiGlobal.eog_challengesToShow[ "almost_complete" ] = []
		uiGlobal.eog_challengesToShow[ "tracked" ] = []
	}

	ShowChallenges()
}

function ShowChallenges()
{
	foreach( box in challengeBoxes )
		box.Hide()
	foreach( button in challengeButtons )
		button.SetEnabled( false )

	Assert( EOGHasChallengesToShow() )

	if ( uiGlobal.EOGChallengeFilter == "most_progress" )
		SetFilterDesc( "#EOG_CHALLENGES_SHOWING_MOST_PROGRESS" )
	else if ( uiGlobal.EOGChallengeFilter == "complete" )
		SetFilterDesc( "#EOG_CHALLENGES_SHOWING_COMPLETED" )
	else if ( uiGlobal.EOGChallengeFilter == "almost_complete" )
		SetFilterDesc( "#EOG_CHALLENGES_SHOWING_ALMOST_COMPLETED" )
	else if ( uiGlobal.EOGChallengeFilter == "tracked" )
		SetFilterDesc( "#EOG_CHALLENGES_SHOWING_TRACKED" )

	local numChallengesToShow = min( uiGlobal.eog_challengesToShow[ uiGlobal.EOGChallengeFilter ].len(), NUM_EOG_CHALLENGE_BOXES )
	for( local i = 0 ; i < numChallengesToShow ; i++ )
	{
		local row = i % 2
		local column = ( i / 2 ) % 3
		local delay = REVEAL_WAVE_TIMING * ( row + column )
		thread AnimateChallengeProgressInBox( i, uiGlobal.eog_challengesToShow[ uiGlobal.EOGChallengeFilter ][i], delay )
	}
}

function OpenMenuStatic( userInitiated = true )
{
	StopUISound( "Menu_GameSummary_ChallengeBarLoop" )
	if ( menuAnimDone && userInitiated )
		thread EOGNavigateRight( null )
	else
		Signal( menu, "StopMenuAnimation" )
}

function AnimateChallengeProgressInBox( boxIndex, challengeData, delay )
{
	Assert( boxIndex < challengeBoxes.len() )

	EndSignal( menu, "StopMenuAnimation" )

	// If we completed a tier, then clamp the final progress to the goal of the last completed tier. Don't overflow into the next unfinished tier
	challengeData.tierCompleteEffectsPlayed <- false
	local finalProgress = challengeData.finalProgress
	if ( challengeData.tiersCompleted.len() > 0 && uiGlobal.EOGChallengeFilter != "almost_complete" )
	{
		local highestTierCompleted = challengeData.tiersCompleted[ challengeData.tiersCompleted.len() - 1 ]
		finalProgress = GetGoalForChallengeTier( challengeData.ref, highestTierCompleted )
	}

	local box = challengeBoxes[ boxIndex ]
	local flash = box.GetChild( "Flash" )
	flash.SetAlpha( 0 )
	flash.Show()
	local background = box.GetChild( "Background" )
	background.SetColor( 255, 255, 255 )
	local completeLabel = box.GetChild( "CompleteText" )
	completeLabel.Hide()

	local currentFilter = uiGlobal.EOGChallengeFilter

	OnThreadEnd(
		function() : ( box, boxIndex, challengeData, finalProgress, currentFilter )
		{
			// If we are still the same filter finish the box animation. If the filter has changed don't do it because the new filter will handle what to show
			if ( currentFilter == uiGlobal.EOGChallengeFilter )
			{
				if ( IsFullyConnected() )
				{
					UpdateChallengeBox( boxIndex, challengeData, finalProgress )
					box.Show()
					challengeButtons[ boxIndex ].SetEnabled( true )
				}
			}
			challengeBarsFilling--
			if ( challengeBarsFilling <= 0 )
			{
				StopUISound( "Menu_GameSummary_ChallengeBarLoop" )
			    if ( uiGlobal.EOGAutoAdvance )
				    thread DelayedAutoNavigate()
			}

			menuAnimDone = true
		}
	)

	if ( uiGlobal.EOGChallengeFilter == "almost_complete" )
		return

	if ( delay > 0.0 )
		wait delay

	if ( !IsFullyConnected() )
		return

	UpdateChallengeBox( boxIndex, challengeData, challengeData.startProgress, true )
	box.Show()
	challengeButtons[ boxIndex ].SetEnabled( true )

	if ( level.doEOGAnimsChallenges )
		EmitUISound( "Menu_GameSummary_ChallengesBoxesSlam" )

	thread FlashElement( menu, flash, 1, 3.0, 30 )
	wait 2.0

	if ( !IsFullyConnected() )
		return

	// Update progress over time
	local startTime
	local endTime
	local progress = challengeData.startProgress

	local tier
	local goal
	local lastGoal = 0
	local prevFrac

	if ( challengeBarsFilling == 0 )
		EmitUISound( "Menu_GameSummary_ChallengeBarLoop" )
	challengeBarsFilling++

	while( IsFullyConnected() )
	{
		tier = GetChallengeTierForProgress( challengeData.ref, progress )
		goal = GetGoalForChallengeTier( challengeData.ref, tier )
		prevFrac = clamp( challengeData.startProgress / goal, 0.0, 1.0 )

		startTime = Time()
		endTime = startTime + FILL_TIME_PER_BAR

		// Fill this tier. When tier is full we break and continue to fill the next tier
		while( IsFullyConnected() )
		{
			local currentTime = Time() + ( FILL_TIME_PER_BAR * prevFrac )
			progress = GraphCapped( currentTime, startTime, endTime, lastGoal, goal).tofloat()

			if ( progress > finalProgress )
				progress = finalProgress

			if ( progress > goal && uiGlobal.EOGChallengeFilter != "almost_complete" )
				progress = goal

			if ( progress == challengeData.startProgress )
				continue

			UpdateChallengeBox( boxIndex, challengeData, progress )

			if ( progress == finalProgress )
				return

			if ( progress == goal )
				break

			wait 0
		}

		lastGoal = goal

		wait 0
	}
}

function DelayedAutoNavigate()
{
	EndSignal( menu, "StopMenuAnimation" )

	wait 3.0

	if ( uiGlobal.EOGAutoAdvance )
		thread EOGNavigateRight( null )
}

function UpdateChallengeBox( boxIndex, challengeData, progress, isStartProgress = false )
{
	if ( !IsFullyConnected() )
		return

	local box = challengeBoxes[ boxIndex ]
	local flash = box.GetChild( "Flash" )
	local completeLabel = box.GetChild( "CompleteText" )
	local background = box.GetChild( "Background" )
	local nameLabel = box.GetChild( "Name" )
	local descLabel = box.GetChild( "Description" )
	local icon = box.GetChild( "Icon" )
	local progressLabel = box.GetChild( "Progress" )
	local barFillPrevious = box.GetChild( "BarFillPrevious" )
	local barFillNew = box.GetChild( "BarFillNew" )
	barFillNew.Show()
	local barFillShadow = box.GetChild( "BarFillShadow" )
	local trackedIcon = box.GetChild( "TrackedIcon" )
	local isTrackedChallenge = IsEOGTrackedChallenge( challengeData.ref )
	local tier = GetChallengeTierForProgress( challengeData.ref, progress )
	local goal = GetGoalForChallengeTier( challengeData.ref, tier )
	local challengeIcon = GetChallengeIcon( challengeData.ref )

	// If the challenge is exactly complete, show a full bar instead of empty bar for next tier
	if ( !isStartProgress && tier > 0 && uiGlobal.EOGChallengeFilter != "almost_complete" )
	{
		local lastGoal = GetGoalForChallengeTier( challengeData.ref, tier - 1 )
		if ( progress.tofloat() == lastGoal.tofloat() )
		{
			tier--
			goal = GetGoalForChallengeTier( challengeData.ref, tier )
		}
	}

	local frac = clamp( progress / goal, 0.0, 1.0 )
	local prevFrac = clamp( challengeData.startProgress / goal, 0.0, 1.0 )
	local desc = GetChallengeDescription( challengeData.ref )

	// Update Challenge Name Display
	PutChallengeNameOnLabel( nameLabel, challengeData.ref, tier )

	PutChallengeRewardsOnPanel( challengeData.ref, tier, challengeRewardPanels[ boxIndex ] )

	// Update Challenge Description Display
	if ( desc.len() == 1 )
		descLabel.SetText( desc[0], goal )
	else
		descLabel.SetText( desc[0], goal, desc[1] )

	// Update challenge icon
	icon.SetImage( challengeIcon )

	// Update Progress Readout Display
	local progressDisplayValue
	if ( GetChallengeProgressIsDecimal( challengeData.ref ) || ( goal % 1 != 0 && progress % 1 != 0 ) )
		progressDisplayValue = format( "%.2f", (progress * 100).tointeger() / 100.0 )
	else
		progressDisplayValue = floor(progress)

	local progressString
	if ( isTrackedChallenge )
	{
		trackedIcon.Show()
		progressString = "#CHALLENGE_POPUP_TRACKED_PROGRESS_STRING"
		nameLabel.SetColor( 102, 194, 204 )
		if ( uiGlobal.activeMenu != null )
		{
			local iconWidth = trackedIcon.GetWidth()
			nameLabel.SetWidth( nameLabel.GetBaseWidth() - iconWidth )
			descLabel.SetWidth( descLabel.GetBaseWidth() - iconWidth )
		}
	}
	else
	{
		trackedIcon.Hide()
		progressString = "#CHALLENGE_POPUP_PROGRESS_STRING"
		nameLabel.SetColor( 255, 255, 255 )
		nameLabel.SetWidth( nameLabel.GetBaseWidth() )
		descLabel.SetWidth( descLabel.GetBaseWidth() )
	}

	progressLabel.SetText( progressString , progressDisplayValue, goal )

	// Update Progress Bar
	barFillNew.SetScaleX( frac )
	barFillPrevious.SetScaleX( prevFrac )
	barFillShadow.SetScaleX( max( prevFrac, frac ) )

	if ( frac == 1.0 && !challengeData.tierCompleteEffectsPlayed && !isStartProgress && uiGlobal.EOGChallengeFilter != "almost_complete" )
	{
		challengeData.tierCompleteEffectsPlayed = true

		// Challenge leveled up
		if ( level.doEOGAnimsChallenges )
			EmitUISound( "Menu_GameSummary_ChallengeCompleted" )

		completeLabel.Show()
		flash.SetAlpha( 0 )
		flash.Show()
		thread FlashElement( menu, flash, 1, 3.0, 50 )
		background.SetColor( level.challengePopupColorComplete[0], level.challengePopupColorComplete[1], level.challengePopupColorComplete[2] )
	}
	else if ( frac < 1.0 )
		challengeData.tierCompleteEffectsPlayed = false
}

function SetFilterDesc( locString )
{
	local label = GetElem( menu, "FilterDesc" )
	label.SetText( locString )
}

function GetNextChallengeView()
{
	local currentFilterIndex = GetIndexInArray( filterOrder, uiGlobal.EOGChallengeFilter )

	for ( local i = 0 ; i < filterOrder.len() ; i++ )
	{
		currentFilterIndex++
		if ( currentFilterIndex >= filterOrder.len() )
			currentFilterIndex = 0

		if ( uiGlobal.eog_challengesToShow[ filterOrder[ currentFilterIndex ] ].len() > 0 )
			return filterOrder[ currentFilterIndex ]
	}

	return filterOrder[ currentFilterIndex ]
}

function CycleChallengeView(...)
{
	CycleChallengeViewInternal()
}

function CycleChallengeViewInternal()
{
	if ( !IsFullyConnected() )
		return

	uiGlobal.EOGChallengeFilter = GetNextChallengeView()
	level.doEOGAnimsChallenges = false

	ShowChallenges()
	OpenMenuStatic(false)
	UpdateFooterButtons()
}

function EOGChallenges_FooterData( footerData )
{
	footerData.gamepad.append( { label = "#B_BUTTON_BACK" } )
	footerData.pc.append( { label = "#BACK", func = PCBackButton_Activate } )

	local eogchallengemenu = GetMenu( "EOG_Challenges" )

	local nextView = GetNextChallengeView()
	if ( nextView != uiGlobal.EOGChallengeFilter )
	{
		if ( uiGlobal.EOGChallengeFilter == "most_progress" )
		{
			footerData.gamepad.append( { label = "#Y_BUTTON_EOG_CHALLENGES_SHOW_MOST_PROGRESS" } )
			footerData.pc.append( { label = "#EOG_CHALLENGES_SHOW_MOST_PROGRESS", func = CycleChallengeView } )
		}
		if ( uiGlobal.EOGChallengeFilter == "complete" )
		{
			footerData.gamepad.append( { label = "#Y_BUTTON_EOG_CHALLENGES_SHOW_COMPLETED" } )
			footerData.pc.append( { label = "#EOG_CHALLENGES_SHOW_COMPLETED", func = CycleChallengeView } )
		}
		if ( uiGlobal.EOGChallengeFilter == "almost_complete" )
		{
			footerData.gamepad.append( { label = "#Y_BUTTON_EOG_CHALLENGES_SHOW_ALMOST_COMPLETED" } )
			footerData.pc.append( { label = "#EOG_CHALLENGES_SHOW_ALMOST_COMPLETED", func = CycleChallengeView } )
		}
		if ( uiGlobal.EOGChallengeFilter == "tracked" )
		{
			footerData.gamepad.append( { label = "#Y_BUTTON_EOG_CHALLENGES_SHOW_TRACKED" } )
			footerData.pc.append( { label = "#EOG_CHALLENGES_SHOW_TRACKED", func = CycleChallengeView } )
		}
	}
}

function EOGChallengeButton_GotFocus( button )
{
	local buttonID = button.GetScriptID().tointeger()
	local box = challengeBoxes[ buttonID ]
	local backgroundSelected = box.GetChild( "BackgroundSelected" )
	backgroundSelected.Show()

	local panel = challengeRewardPanels[ buttonID ]
	panel.Show()

	for( local i = 0 ; i < NUM_EOG_CHALLENGE_BOXES ; i++ )
		SetChallengeBoxDim( i, i != buttonID )
}

function EOGChallengeButton_LostFocus( button )
{
	local buttonID = button.GetScriptID().tointeger()
	local box = challengeBoxes[ buttonID ]
	local backgroundSelected = box.GetChild( "BackgroundSelected" )
	backgroundSelected.Hide()

	local panel = challengeRewardPanels[ buttonID ]
	panel.Hide()

	for( local i = 0 ; i < NUM_EOG_CHALLENGE_BOXES ; i++ )
		SetChallengeBoxDim( i, false )
}

function SetChallengeBoxDim( boxIndex, bDim )
{
	local alpha = bDim ? 70 : 255

	local box = challengeBoxes[ boxIndex ]

	local completeLabel 	= box.GetChild( "CompleteText" )
	local background 		= box.GetChild( "Background" )
	local nameLabel 		= box.GetChild( "Name" )
	local descLabel 		= box.GetChild( "Description" )
	local icon 				= box.GetChild( "Icon" )
	local progressLabel 	= box.GetChild( "Progress" )
	local barFillPrevious 	= box.GetChild( "BarFillPrevious" )
	local barFillNew 		= box.GetChild( "BarFillNew" )
	local barFillShadow 	= box.GetChild( "BarFillShadow" )

	completeLabel.SetAlpha( alpha )
	background.SetAlpha( alpha )
	nameLabel.SetAlpha( alpha )
	descLabel.SetAlpha( alpha )
	icon.SetAlpha( alpha )
	progressLabel.SetAlpha( alpha )
	barFillPrevious.SetAlpha( alpha )
	barFillNew.SetAlpha( alpha )
	barFillShadow.SetAlpha( alpha )
}

function IsEOGTrackedChallenge( challengeRef )
{
	for ( local i = 0; i < MAX_TRACKED_CHALLENGES; i++ )
	{
		if ( challengeRef == GetPersistentVar( "EOGTrackedChallengeRefs[" + i + "]" ) )
			return true
	}

	return false
}