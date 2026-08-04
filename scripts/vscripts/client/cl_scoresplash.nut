/*
	ToDo:
		-make first item in list pulse or flash
		-make headshots smaller, need to be able to set font or font scale
*/

const NUM_SPLASH_LINES				= 5		// Max number of splash messages that will stack up. If more splash messages are created than allowed, the oldest get truncated off the list

SPLASH_TEXT_COLOR_CONVERTED <- StringToColors( SPLASH_TEXT_COLOR )		// Splash text color

//--------------------------------------------------
//--------------------------------------------------

splashLines <- {}
splashTotalHudGroup <- null
splashIconSize <- 24
nextSplashIndexToUse <- 0
multiScoreTotal <- 0
lastMultiScoreShowTime <- ( 0 - SPLASH_DURATION )
multiScoreTotalIsShowing <- false
multiScoreTotalIsFading <- false
finishedSplashInit <- false
lastSplashVisibleTimes <- []
splashFadeDelay <- SPLASH_DURATION - SPLASH_FADE_OUT_DURATION

Assert( SPLASH_FADE_OUT_DURATION <= SPLASH_DURATION )

function InitSplash()
{
	if ( finishedSplashInit )
		return

	AddKillReplayStartedCallback( ClearScoreSplashArea )

	local screenSize = Hud.GetScreenSize()
	local screenCenterX = screenSize[ 0 ] / 2
	local screenCenterY = screenSize[ 1 ] / 2
	local defaultSplashPosX = screenCenterX + ( SPLASH_X * GetContentScaleFactor()[0] )
	local defaultSplashPosY = screenCenterY + ( SPLASH_Y * GetContentScaleFactor()[1] )
	local textBoxWidth = 1000
	local textBoxHeight = 64
	local flareWidth = 128
	local flareHeight = 64
	local elem

	// Scrolling/Stacking point splashes use the class HUDSplashLine
	for( local i = 0 ; i < NUM_SPLASH_LINES ; i++ )
	{
		// Master group containing all elements
		local masterGroup = HudElementGroup( "HUDSplashLine" + i )

		// Description hud element group
		local descGroup = HudElementGroup( "HUDSplashLineDesc" + i )
		elem = descGroup.CreateElement( "SplashLineDesc_" + i )

		descGroup.SetBaseSize( textBoxWidth, textBoxHeight )
		descGroup.SetBasePos( defaultSplashPosX - textBoxWidth, defaultSplashPosY )

		masterGroup.AddGroup( descGroup )

		local descGlowGroup = HudElementGroup( "HUDSplashLineDesc" + i )
		elem = descGlowGroup.CreateElement( "SplashLineDescGlow_" + i )

		descGlowGroup.SetBaseSize( textBoxWidth, textBoxHeight )
		descGlowGroup.SetBasePos( defaultSplashPosX - textBoxWidth, defaultSplashPosY )

		masterGroup.AddGroup( descGlowGroup )

		// Flare effect element
		local flareElem = HudElement( "SplashLineDescFlare_" + i )
		flareElem.SetBaseSize( flareWidth, flareHeight )
		//flareElem.SetBasePos( defaultSplashPosX - ( flareWidth / 2.0 ), defaultSplashPosY + ( textBoxHeight / 2.0 ) - ( flareHeight / 2.0 ) )
		masterGroup.AddElement( flareElem )

		// Value hud element group
		local valueGroup = HudElementGroup( "HUDSplashLineValue" + i )

		elem = valueGroup.CreateElement( "SplashLineValue_" + i )

		valueGroup.SetBaseSize( textBoxWidth, textBoxHeight )
		valueGroup.SetBasePos( defaultSplashPosX + SPLASH_X_GAP, defaultSplashPosY )

		masterGroup.AddGroup( valueGroup )

		// Value icon element
		local valueIcon = masterGroup.CreateElement( "SplashLineValueIcon_" + i )
		local iconOffsetY = ( ( textBoxHeight - splashIconSize ) / 2 )
		valueIcon.SetBaseSize( splashIconSize, splashIconSize )
		valueIcon.SetBasePos( defaultSplashPosX + SPLASH_X_GAP, defaultSplashPosY + iconOffsetY )

		// Create class instance for this SplashLineValueIcon_
		splashLines[ i ] <- HUDSplashLine( "HUDSplashLine" + i )
		splashLines[ i ].SetDuration( SPLASH_DURATION, SPLASH_FADE_OUT_DURATION )
		splashLines[ i ].SetScroll( SPLASH_SPACING, SPLASH_SCROLL_TIME )
		splashLines[ i ].SetTypeDuration( SPLASH_TYPEWRITER_TIME )
		splashLines[ i ].SetMasterGroup( masterGroup )
		splashLines[ i ].AddSplashGroup( "baseDesc", descGroup )
		splashLines[ i ].AddSplashGroup( "desc", descGroup )
		splashLines[ i ].AddSplashGroup( "descGlow", descGlowGroup )
		splashLines[ i ].AddSplashGroup( "value", valueGroup )
		splashLines[ i ].AddIconElem( "value", valueIcon )
		splashLines[ i ].SetFlareEffectElem( "desc", flareElem );
	}

	// Multi score total just uses hud element class and a group since it's just one set of text that doesn't do anything fancy
	if ( SPLASH_SHOW_MULTI_SCORE_TOTAL )
	{
		splashTotalHudGroup = HudElementGroup( "SplashTotalValueGroup" )

		elem = splashTotalHudGroup.CreateElement( "SplashTotalValue" )

		splashTotalHudGroup.SetBaseColor( SPLASH_TEXT_COLOR_CONVERTED.r, SPLASH_TEXT_COLOR_CONVERTED.g, SPLASH_TEXT_COLOR_CONVERTED.b, SPLASH_TEXT_COLOR_CONVERTED.a )
		splashTotalHudGroup.SetText( "" )
		splashTotalHudGroup.SetSize( textBoxWidth, textBoxHeight )
		splashTotalHudGroup.SetPos( screenCenterX + ( SPLASH_TOTAL_POS_X * GetContentScaleFactor()[0] ), screenCenterY + ( SPLASH_TOTAL_POS_Y * GetContentScaleFactor()[0] ) )
	}

	finishedSplashInit = true
}

function ServerCallback_PointSplashMultiplied( scoreEventInt, associatedEntityHandle = null, pointValueOverride = null )
{
	ServerCallback_PointSplash( scoreEventInt, associatedEntityHandle, pointValueOverride, true )
}

function ServerCallback_PointSplash( scoreEventInt, associatedEntityHandle = null, pointValueOverride = null, multiplied = false )
{
	local player = GetLocalClientPlayer()
	if ( IsWatchingKillReplay() )
		return

	local event = ScoreEventFromInteger( scoreEventInt )

	local associatedEntity = null
	if ( associatedEntityHandle != null )
		associatedEntity = GetEntityFromEncodedEHandle( associatedEntityHandle )

	if ( event.GetShouldStackDisplay() )
		UpdateStackingSplash( event, associatedEntity, pointValueOverride, multiplied )
	else
		_CreateNewSplash( event, associatedEntity, pointValueOverride, multiplied )
}

function _CreateNewSplash( event, associatedEntity, pointValueOverride, multiplied = false, extraText = null, overrideValue = null, stackCount = null )
{
	InitSplash()

	// Determine how many points to display on the screen
	local pointValue = event.GetPointValue()

	if ( pointValueOverride != null )
		pointValue = pointValueOverride

	if ( ( pointValue == null ) || ( pointValue <= 0  ) )
		return

	local splashText = event.GetSplashText()
	if ( splashText == null )
		return

	if ( level.rankedPlayEnabled )
	{
		if ( EventRewardsRankedPoints( event ) )
		{
			if ( PlayerPlayingRanked( GetLocalClientPlayer() ) )
				RankedScoreSplash()
		}
	}

	// Keep a running total of how many points are given out. This gets reset back to 0 when all splashes have faded
	multiScoreTotal += pointValue
	UpdateMultiScoreText()

	local next = nextSplashIndexToUse
	BumpDownExistingSplashes()

	local hasIcon = event.HasPointValueIcon()
	local splashes = splashLines[ next ]
	// Only operators get icons with their points for now. If we want this for regular players we have to refactor a few things
	if ( GetLocalViewPlayer().GetPlayerClass() != "dronecontroller" )
		hasIcon = false

	local usePlayerColor = associatedEntity && associatedEntity.IsPlayer()

	local preValueString = "+"
	if ( hasIcon )
		preValueString = ""
	pointValue = preValueString + pointValue.tostring()

	if ( overrideValue != null )
		pointValue = overrideValue

	splashes.SetIconMaterial( "value", event.GetPointValueIcon(), splashIconSize, hasIcon )
	splashes.SetTextForGroup( "baseDesc", splashText )

	if ( extraText == null )
	{
		extraText = ""
		if ( event.GetSplashTextAppendTargetName() && IsValid( associatedEntity ) )
		{
			extraText = ( ( associatedEntity.IsPlayer() ) ? associatedEntity.GetPlayerName() : associatedEntity.GetName() )
		}
	}

	if ( stackCount == null )
	{
		splashes.SetStackCount( 1 )
	}
	else
	{
		splashes.SetStackCount( stackCount + 1 )
	}
	splashes.SetTextForGroup( "desc", splashText, extraText )
	splashes.SetTextForGroup( "descGlow", splashText, extraText )
	splashes.SetTextForGroup( "value", pointValue )

	//printt( "adding " + event.name + " line " + next )
	local customColors
	if ( event in level.scoreCustomColors )
	{
		customColors = level.scoreCustomColors[ event ]
		splashes.SetColorForGroup( "desc", customColors.main )
		splashes.SetColorForGroup( "descGlow", customColors.glow )
		splashes.SetColorForGroup( "value", customColors.main )
	}
	else if ( multiplied )
	{
		splashes.SetColorForGroup( "desc", SCORE_SPLASH_COLORS_BURNCARDS.main )
		splashes.SetColorForGroup( "descGlow", SCORE_SPLASH_COLORS_BURNCARDS.glow )
		splashes.SetColorForGroup( "value", SCORE_SPLASH_COLORS_BURNCARDS.main )
	}
	else
	{
		splashes.SetColorForGroup( "desc", SPLASH_TEXT_COLOR )
		splashes.SetColorForGroup( "descGlow", "0 0 0 0" )
		splashes.SetColorForGroup( "value", SPLASH_TEXT_COLOR )
	}

	local time = Time()

	splashes.Display()
	splashes.SetStartTime( time )

	EmitSoundOnEntity( GetLocalViewPlayer(), "PlayerUI.SplashTextDisplay" )

	lastSplashVisibleTimes.append( time )
	while( lastSplashVisibleTimes.len() > SPLASH_MULTI_SCORE_REQUIREMENT )
		lastSplashVisibleTimes.remove( 0 )

	// increment which hud elems to use next time
	nextSplashIndexToUse++
	if ( nextSplashIndexToUse >= NUM_SPLASH_LINES )
		nextSplashIndexToUse = 0

	//ShouldShowMultiScoreTotal()
}

function UpdateStackingSplash( event, associatedEntity, pointValueOverride, multiplied = false )
{
	for( local i = 0; i < splashLines.len(); i++ )
	{
		if ( splashLines[ i ].textGroupStrings[ "baseDesc" ] == event.GetSplashText() && splashLines[ i ].startTime > Time() - SPLASH_DURATION )
		{
			local pointValue = event.GetPointValue()
			if ( pointValueOverride != null )
				pointValue = pointValueOverride
			local pointSum = splashLines[ i ].textGroupStrings[ "value" ].tointeger() + pointValue
			local pointString = "+" + pointSum.tostring()
			local stackCount = splashLines[ i ].GetStackCount()
			local overrideText = " (x" + ( stackCount + 1 )  + ")"
			RemoveLineAndShiftUpSplashes( i )

			_CreateNewSplash( event, associatedEntity, pointValueOverride, multiplied, overrideText, pointString, stackCount )
			return
		}
	}
	_CreateNewSplash( event, associatedEntity, pointValueOverride, multiplied )
}

function RemoveLineAndShiftUpSplashes( index )
{
	//printt( "Distance From Top ", GetDistanceFromTop( index ) )
	for ( local j = 0; j < ( NUM_SPLASH_LINES - ( GetDistanceFromTop( index ) ) ); j++ )
	{
		for( local i = 0; i < splashLines.len(); i++ )
		{
			//printt( splashLines[ i ].textGroupStrings[ "baseDesc" ], " baseDesc", splashLines[ i ].textGroupStrings[ "desc" ], "desc", " index ", i )
		}
		//printt( "Next Splash Index = ", nextSplashIndexToUse )
		//printt( "==============================" )
		local currentIndex = index - j
		if( currentIndex < 0 )
			currentIndex = NUM_SPLASH_LINES + currentIndex

		local nextIndex = currentIndex - 1
		if( nextIndex < 0 )
			nextIndex = NUM_SPLASH_LINES + nextIndex

		if( Time() - splashLines[ nextIndex ].startTime < SPLASH_DURATION )
		{
			splashLines[ currentIndex ].SetTextForGroup( "desc", splashLines[ nextIndex ].textGroupStrings[ "desc" ], splashLines[ nextIndex ].textGroupStringsVar1[ "desc" ] )
			splashLines[ currentIndex ].SetTextForGroup( "descGlow", splashLines[ nextIndex ].textGroupStrings[ "desc" ], splashLines[ nextIndex ].textGroupStringsVar1[ "desc" ] )
			splashLines[ currentIndex ].SetTextForGroup( "value", splashLines[ nextIndex ].textGroupStrings[ "value" ] )
			splashLines[ currentIndex ].SetTextForGroup( "baseDesc", splashLines[ nextIndex ].textGroupStrings[ "baseDesc" ] )
			splashLines[ currentIndex ].SetStartTime( splashLines[ nextIndex ].startTime )
			splashLines[ currentIndex ].SetColorForGroup( "desc", splashLines[ nextIndex ].textGroupColors[ "desc" ] )
			splashLines[ currentIndex ].SetColorForGroup( "descGlow", splashLines[ nextIndex ].textGroupColors[ "descGlow" ] )
			splashLines[ currentIndex ].SetColorForGroup( "value", splashLines[ nextIndex ].textGroupColors[ "value" ] )
			splashLines[ currentIndex ].SetStackCount( splashLines[ nextIndex ].GetStackCount() )

			splashLines[ nextIndex ].SetTextForGroup( "desc", "" )
			splashLines[ nextIndex ].SetTextForGroup( "descGlow", "" )
			splashLines[ nextIndex ].SetTextForGroup( "value", "" )
			splashLines[ nextIndex ].SetTextForGroup( "baseDesc", "" )
			splashLines[ nextIndex ].SetColorForGroup( "desc", SPLASH_TEXT_COLOR )
			splashLines[ nextIndex ].SetColorForGroup( "descGlow", "0 0 0 0" )
			splashLines[ nextIndex ].SetColorForGroup( "value", SPLASH_TEXT_COLOR )
			splashLines[ nextIndex ].SetStackCount( 1 )

			splashLines[ nextIndex ].UpdateTextDisplay()
		}
		else
		{
			splashLines[ currentIndex ].SetTextForGroup( "desc", "", "" )
			splashLines[ currentIndex ].SetTextForGroup( "descGlow", "" )
			splashLines[ currentIndex ].SetTextForGroup( "value", "" )
			splashLines[ currentIndex ].SetTextForGroup( "baseDesc", "" )
			splashLines[ currentIndex ].SetColorForGroup( "desc", SPLASH_TEXT_COLOR )
			splashLines[ currentIndex ].SetColorForGroup( "descGlow", "0 0 0 0" )
			splashLines[ currentIndex ].SetColorForGroup( "value", SPLASH_TEXT_COLOR )
			splashLines[ currentIndex ].SetStackCount( 1 )
		}
		splashLines[ currentIndex ].UpdateTextDisplay()
	}
}

function BumpDownExistingSplashes()
{
	foreach( index, splash in splashLines )
	{
		local numLinesAway = GetDistanceFromTop( index )
		splash.Scroll( numLinesAway )
	}
}

function UpdateMultiScoreText()
{
	if ( !SPLASH_SHOW_MULTI_SCORE_TOTAL )
		return

	if ( multiScoreTotalIsFading )
		return

	splashTotalHudGroup.SetTextTypeWriter( "+" + multiScoreTotal.tostring(), SPLASH_TYPEWRITER_TIME )
}

function ShouldShowMultiScoreTotal()
{
	local time = Time()
	local bShowTotal = true

	if ( !SPLASH_SHOW_MULTI_SCORE_TOTAL )
		bShowTotal = false

	if ( lastSplashVisibleTimes.len() < SPLASH_MULTI_SCORE_REQUIREMENT )
		bShowTotal = false

	if ( ( lastSplashVisibleTimes[ 0 ] + SPLASH_DURATION ) < time )
		bShowTotal = false

	if ( bShowTotal )
	{
		multiScoreTotalIsShowing = true
		multiScoreTotalIsFading = false

		UpdateMultiScoreText()
		splashTotalHudGroup.ReturnToBaseColor()
		splashTotalHudGroup.Show()
		splashTotalHudGroup.FadeOverTimeDelayed( 0, SPLASH_FADE_OUT_DURATION, splashFadeDelay )
		lastMultiScoreShowTime = time
	}
}

function ScoreSplashThink()
{
	local time = Time()
	local fadeoutStartTime = lastMultiScoreShowTime + splashFadeDelay
	local fadeoutEndTime = lastMultiScoreShowTime + SPLASH_DURATION

	if ( fadeoutEndTime <= time )
	{
		// Total is completely hidden

		if ( multiScoreTotalIsShowing )
		{
			multiScoreTotal = 0
			UpdateMultiScoreText()
		}

		multiScoreTotalIsShowing = false
		multiScoreTotalIsFading = false
	}
	else if ( fadeoutStartTime <= time )
	{
		// Total is in process of fading out
		multiScoreTotalIsFading = true
	}
}

function GetDistanceFromTop( index )
{
	if ( index <= nextSplashIndexToUse )
		return nextSplashIndexToUse - index
	else
		return NUM_SPLASH_LINES - ( index - nextSplashIndexToUse )
}

function ClearScoreSplashArea()
{
	for( local i = 0; i < splashLines.len(); i++ )
	{
		splashLines[ i ].masterGroup.FadeOverTime( 0, 0.15 )
	}
}