
menu <- null
buttonsRegistered <- false
eogMapStarsInitialized <- false
menuMapStarsAnimDone <- false

eogStarsMode <- null
eogStarsMap <- null

largeStars <- []
mapImageElem <- null
scoreReqLabels <- []
scoreReqIcons <- []
yourScoreLabel <- null

//#############################

//PrecacheHUDMaterial( CHALLENGES_IMAGE )

function main()
{
	Globalize( OnOpenEOG_MapStars )
	Globalize( OnCloseEOG_MapStars )
	Globalize( ShouldShowEOGMapStars )
}

function ShouldShowEOGMapStars()
{
	// Only show the map stars screen if we were in a public match on a valid map and mode that has stars

	local lastMap = GetStarsMap()
	if ( lastMap == null )
		return false

	local lastMode = GetStarsMode()
	if ( lastMode == null )
		return false

	if ( GetPersistentVar( "savedScoreboardData.privateMatch" ) == true )
		return false

	// Also only show it if the users stars for that map and mode changed

	local starCounts = GetStarsForScores( lastMap, lastMode )
	return starCounts.now > starCounts.previous
}

function GetStarsMap()
{
	local lastMapIndex = GetPersistentVar( "savedScoreboardData.map" )
	if ( lastMapIndex < 0 || lastMapIndex >= PersistenceGetEnumCount( "maps" ) )
		return null

	return PersistenceGetEnumItemNameForIndex( "maps", lastMapIndex )
}

function GetStarsMode()
{
	local lastModeIndex = GetPersistentVar( "savedScoreboardData.gameMode" )
	if ( lastModeIndex < 0 || lastModeIndex >= PersistenceGetEnumCount( "gameModes" ) )
		return null

	local lastMode = PersistenceGetEnumItemNameForIndex( "gameModes", lastModeIndex )
	if ( !PersistenceEnumValueIsValid( "gameModesWithStars", lastMode ) )
		return null

	return lastMode
}

function InitMenu()
{
	Assert( menu != null )

	// Buttons & Background
	SetupEOGMenuCommon( menu )

	if ( !eogMapStarsInitialized )
	{
		for ( local i = 0 ; i < 3 ; i++ )
		{
			largeStars.append( GetElem( menu, "Star" + i ) )
			scoreReqLabels.append( GetElem( menu, "ScoreReq" + i ) )
			scoreReqIcons.append( GetElem( menu, "ScoreTypeIcon" + i ) )
		}

		mapImageElem = GetElem( menu, "MapImage" )
		yourScoreLabel = GetElem( menu, "YourScore" )
		eogMapStarsInitialized = true
	}
	Assert( largeStars.len() == 3 )

	eogStarsMap = GetStarsMap()
	eogStarsMode = GetStarsMode()

	// Map Image
	mapImageElem.SetImage( "../ui/menu/lobby/lobby_image_" + eogStarsMap )

	// Map Name
	local mapNameLabel = GetElem( menu, "MapName" )
	if ( GetPersistentVar( "savedScoreboardData.campaign" ) == true )
		mapNameLabel.SetText( GetCampaignMapDisplayName( eogStarsMap ) )
	else
		mapNameLabel.SetText( GetMapDisplayName( eogStarsMap ) )

	// Mode Name
	local modeNameLabel = GetElem( menu, "GameModeName" )
	modeNameLabel.SetText( GAMETYPE_TEXT[ eogStarsMode ] )

	// Fill stars based on previous star count
	local starCount = GetStarsForScores( eogStarsMap, eogStarsMode )
	local scoreReqs = GetStarScoreRequirements( eogStarsMode, eogStarsMap )
	local usePreviousScores = true
	local scoreIcon = GetMapStarScoreImage( eogStarsMode )
	for ( local i = 0 ; i < MAX_STAR_COUNT ; i++ )
	{
		if ( starCount.previous >= i + 1 )
			largeStars[i].SetImage( MAP_STARS_IMAGE_FULL )
		else
			largeStars[i].SetImage( MAP_STARS_IMAGE_EMPTY )
		scoreReqLabels[i].SetText( scoreReqs[i].tostring() )
		scoreReqIcons[i].SetImage( scoreIcon )
	}

	yourScoreLabel.SetText( "#MAP_STARS_EOG_YOUR_SCORE", GetStarBestScores( eogStarsMap, eogStarsMode ).now.tostring() )
}

function OnOpenEOG_MapStars()
{
	if ( developer() > 0 )
	{
		DumpStack()
		Assert( ShouldShowEOGMapStars(), "EOG Map Stars tried to open but no progress was made on map stars" )
	}

	menu = GetMenu( "EOG_MapStars" )
	level.currentEOGMenu = menu
	Signal( menu, "StopMenuAnimation" )
	EndSignal( menu, "StopMenuAnimation" )
	Signal( level, "CancelEOGThreadedNavigation" )

	InitMenu()
	thread OpenMenuAnimated()

	EOGOpenGlobal()

	wait 0
	if ( !buttonsRegistered )
	{
		RegisterButtonPressedCallback( BUTTON_A, OpenMenuStatic )
		RegisterButtonPressedCallback( KEY_SPACE, OpenMenuStatic )
		buttonsRegistered = true
	}

	if ( !level.doEOGAnimsMapStars )
		OpenMenuStatic(false)
}

function OnCloseEOG_MapStars()
{
	thread EOGCloseGlobal()

	if ( buttonsRegistered )
	{
		DeregisterButtonPressedCallback( BUTTON_A, OpenMenuStatic )
		DeregisterButtonPressedCallback( KEY_SPACE, OpenMenuStatic )
		buttonsRegistered = false
	}

	level.doEOGAnimsMapStars = false
	menuMapStarsAnimDone = false
	Signal( menu, "StopMenuAnimation" )
}

function OpenMenuAnimated()
{
	if ( level.doEOGAnimsMapStars )
		EmitUISound( "Menu_GameSummary_ScreenSlideIn" )
	else
		EmitUISound( "EOGSummary.XPBreakdownPopup" )

	OnThreadEnd(
		function() : (  )
		{
			if ( !IsFullyConnected() )
				return

			menuMapStarsAnimDone = true

			local starCount = GetStarsForScores( eogStarsMap, eogStarsMode )
			for ( local i = 0 ; i < 3 ; i++ )
			{
				if ( starCount.now >= i + 1 )
					largeStars[i].SetImage( MAP_STARS_IMAGE_FULL )
				else
					largeStars[i].SetImage( MAP_STARS_IMAGE_EMPTY )
			}

			if ( level.doEOGAnimsMapStars && uiGlobal.EOGAutoAdvance )
				thread EOGNavigateRight( null, true )
		}
	)

	EndSignal( menu, "StopMenuAnimation" )

	thread FancyLabelFadeIn( menu, mapImageElem, -500, 0, false, 0.15, false, 0.0 )//, "Menu_GameSummary_ChallengesBoxesSlam" )
	foreach( star in largeStars )
		thread FancyLabelFadeIn( menu, star, 500, 0, false, 0.15, false, 0.0 )//, "Menu_GameSummary_ChallengesBoxesSlam" )

	wait 1.0

	// Fill in the stars
	local starCount = GetStarsForScores( eogStarsMap, eogStarsMode )
	for ( local i = 0 ; i < 3 ; i++ )
	{
		if ( starCount.now >= i + 1 && starCount.previous < i + 1 )
			waitthread FillStar( i )
	}

	menuMapStarsAnimDone = true
	wait 2.0
}

function OpenMenuStatic( userInitiated = true )
{
	if ( menuMapStarsAnimDone && userInitiated )
		thread EOGNavigateRight( null )
	else
		Signal( menu, "StopMenuAnimation" )
}

function FillStar( index )
{
	local emptyStar = largeStars[index]
	emptyStar.SetImage( MAP_STARS_IMAGE_EMPTY )
	local bigStar = GetElem( menu, "StarFull" )
	local smallStars = GetElementsByClassname( menu, "SmallStar" )
	Assert( smallStars.len() > 0 )

	local emptyStarSize = emptyStar.GetSize()
	local emptyStarPos = emptyStar.GetBasePos()
	local emptyStarCenter = [ emptyStarPos[0] + emptyStarSize[0] / 2.0, emptyStarPos[1] + emptyStarSize[1] / 2.0 ]

	local duration = 0.5
	local startAlpha = 0
	local endAlpha = 255
	local startScale = 15.0
	local endScale = 1.0

	local startPos = [emptyStarCenter[0] - (emptyStarSize[0] * startScale * 0.5 ), emptyStarCenter[1] - (emptyStarSize[1] * startScale * 0.5 )]
	local endPos = [emptyStarCenter[0] - (emptyStarSize[0] * endScale * 0.5 ), emptyStarCenter[1] - (emptyStarSize[1] * endScale * 0.5 )]

	OnThreadEnd(
		function() : ( bigStar, endScale, endPos, endAlpha, smallStars, emptyStar )
		{
			bigStar.SetScale( endScale, endScale )
			bigStar.SetPos( endPos[0], endPos[1] )
			bigStar.SetAlpha( endAlpha )
			foreach( star in smallStars )
				star.Hide()
			emptyStar.SetImage( MAP_STARS_IMAGE_FULL )
			bigStar.Hide()
		}
	)

	local soundAlias
	if ( index == 0 )
		soundAlias = "UI_Lobby_StarEarned_First"
	else if ( index == 1 )
		soundAlias = "UI_Lobby_StarEarned_Second"
	else
		soundAlias = "UI_Lobby_StarEarned_Third"
	EmitUISound( soundAlias )
	wait 0.15

	bigStar.Show()

	bigStar.SetScale( startScale, startScale )
	bigStar.SetPos( startPos[0], startPos[1] )
	bigStar.SetAlpha( startAlpha )

	bigStar.ScaleOverTime( endScale, endScale, duration, INTERPOLATOR_ACCEL )
	bigStar.MoveOverTime( endPos[0], endPos[1], duration, INTERPOLATOR_ACCEL )
	bigStar.FadeOverTime( endAlpha, duration, INTERPOLATOR_ACCEL )

	wait duration

	local degOffset = 360.0 / smallStars.len().tofloat()
	local moveDist = 350
	startAlpha = 255
	endAlpha = 0
	duration = 0.8//RandomFloat( 1.3, 1.8 )
	startScale = 2.0//RandomFloat( 2.0, 3.0 )
	endScale = 0.7//RandomFloat( 0.4, 0.8 )
	smallStars[0].ReturnToBaseSize()
	local smallStarSize = smallStars[0].GetSize()
	startPos = [emptyStarCenter[0] - (smallStarSize[0] * startScale * 0.5 ), emptyStarCenter[1] - (smallStarSize[1] * startScale * 0.5 )]

	foreach( index, star in smallStars )
	{
		local moveDistThisStar = moveDist
		if ( index % 2 )
			moveDistThisStar *= 0.65

		local angle = degOffset * index
		local endPos = [ startPos[0] + deg_cos(angle) * moveDistThisStar, startPos[1] + deg_sin(angle) * moveDistThisStar ]

		star.SetScale( startScale, startScale )
		star.SetPos( startPos[0], startPos[1] )
		star.SetAlpha( startAlpha )

		//star.ScaleOverTime( endScale, endScale, duration, INTERPOLATOR_DEACCEL )
		star.MoveOverTime( endPos[0], endPos[1], duration, INTERPOLATOR_DEACCEL )
		star.FadeOverTime( endAlpha, duration, INTERPOLATOR_DEACCEL )

		star.SetImage( "../ui/menu/lobby/map_star_small" + RandomInt(3) )
		star.Show()
	}

	wait duration
}