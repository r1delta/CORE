const FLYOUT_NONE = 0
const FLYOUT_TEXT = 1
const FLYOUT_ICON = 2
const SIGNAL_ID_INFOFLYOUT_ACTIVATED = "SignalInfoFlyoutActivated"
const SIGNAL_ID_FLYOUT_ACTIVATED = "SignalFlyoutActivated"
const FLYOUT_TITLE_LINE = 0


function main()
{
	Globalize( Flyout_AddPlayer )
	Globalize( Flyout_Update )
	Globalize( Flyout_Show )
	Globalize( Flyout_ShowWeapon )
	Globalize( Flyout_ShowWeaponChallenge )
	Globalize( Flyout_Hide )

	Globalize( InfoFlyout_Icon )
	Globalize( InfoFlyout_AddPlayer )
	Globalize( InfoFlyout_Update )
	Globalize( InfoFlyout_Show )
	Globalize( InfoFlyout_Hide )
	Globalize( InfoFlyout_Init )
	Globalize( InfoFlyout_IconShow )
	Globalize( InfoFlyout_TitleShow )

	RegisterSignal( SIGNAL_ID_INFOFLYOUT_ACTIVATED )
	RegisterSignal( SIGNAL_ID_FLYOUT_ACTIVATED )

	file.infoFlyoutElements <- []

	file.infoFlyoutTitleElem <- null
	file.infoFlyoutIcon <- null
	file.infoFlyoutDescElems <- null

	file.infoFlyoutTitleLine <- null // needed for position
	file.infoFlyoutTitleLineEnd_Left <- null
	file.infoFlyoutTitleLineEnd_Right <- null
	file.infoFlyoutConnectingLine <- null

	file.infoFlyoutTitleLineThickness <- null
	file.infoFlyoutTitleLineHalfThickness <- null
	file.infoFlyoutShowStartTime <- 0
	file.infoFlyoutShowing <- FLYOUT_NONE
	file.infoFlyoutFadingOut <- false

	file.infoFlyoutEntity <- null
	file.infoFlyoutAttachment <- null

	file.flyoutElements <- []

	file.flyoutTitleElems <- null
	file.flyoutDescElems <- null
	file.flyoutTitleLine <- null
	file.flyoutTitleLineEnd_Left <- null
	file.flyoutTitleLineEnd_Right <- null
	file.flyoutConnectingLine <- null

	file.flyoutTitleLineThickness <- null
	file.flyoutTitleLineHalfThickness <- null
	file.flyoutShowStartTime <- 0
	file.flyoutShowing <- false
	file.flyoutFadingOut <- false
}

function Flyout_AddPlayer( player )
{
	file.infoFlyoutElements <- []

	file.infoFlyoutTitleElem <- null
	file.infoFlyoutIcon <- null
	file.infoFlyoutDescElems <- null

	file.infoFlyoutTitleLine <- null // needed for position
	file.infoFlyoutTitleLineEnd_Left <- null
	file.infoFlyoutTitleLineEnd_Right <- null
	file.infoFlyoutConnectingLine <- null

	file.infoFlyoutTitleLineThickness <- null
	file.infoFlyoutTitleLineHalfThickness <- null
	file.infoFlyoutShowStartTime <- 0
	file.infoFlyoutShowing <- FLYOUT_NONE
	file.infoFlyoutFadingOut <- false

	file.infoFlyoutEntity <- null
	file.infoFlyoutAttachment <- null

	file.flyoutElements <- []

	file.flyoutTitleElems <- null
	file.flyoutDescElems <- null
	file.flyoutDesc2Elems <- null
	file.flyoutTitleLine <- null
	file.flyoutTitleLineEnd_Left <- null
	file.flyoutTitleLineEnd_Right <- null
	file.flyoutConnectingLine <- null

	file.flyoutTitleLineThickness <- null
	file.flyoutTitleLineHalfThickness <- null
	file.flyoutShowStartTime <- 0
	file.flyoutShowing <- false
	file.flyoutFadingOut <- false

	Flyout_Init( player )
}

function Flyout_Init( player )
{
	// Title element
	file.flyoutTitleElems = FlyoutElementWithGlow( "Flyout_Title", "Flyout_TitleGlow" )

	// Description element
	file.flyoutDescElems = FlyoutElementWithGlow( "Flyout_Description", "Flyout_DescriptionGlow" )

	// Description element
	file.flyoutDesc2Elems = FlyoutElementWithGlow( "Flyout_Description2", "Flyout_Description2Glow" )

	// Title line element
	file.flyoutTitleLine = FlyoutElement( "Flyout_TitleLine" )
	file.flyoutTitleLineThickness = file.flyoutTitleLine.GetBaseHeight()
	file.flyoutTitleLineHalfThickness = file.flyoutTitleLineThickness / 2.0

	// Title line ends elements
	file.flyoutTitleLineEnd_Left = FlyoutElement( "Flyout_TitleLineEnd_Left" )
	file.flyoutTitleLineEnd_Right = FlyoutElement( "Flyout_TitleLineEnd_Right" )

	// Connecting Line
	file.flyoutConnectingLine = FlyoutElement( "Flyout_ConnectingLine" )
	file.flyoutConnectingLine.SetBaseAlpha( FLYOUT_CONNECTING_LINE_ALPHA )
	file.flyoutConnectingLine.SetAlpha( FLYOUT_CONNECTING_LINE_ALPHA )
}

function FlyoutElement( name )
{
	local elem = HudElement( name )
	file.flyoutElements.append( elem )
	return elem
}

function FlyoutElementWithGlow( name1, name2 )
{
	local group = HudElementGroup( name1 )
	file.flyoutElements.append( group.CreateElement( name1 ) )
	file.flyoutElements.append( group.CreateElement( name2 ) )
	return group
}

function Flyout_ShowWeapon( weaponRef, modRefs )
{
	local player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )

	if ( IsWatchingKillReplay() )
		return

	local useBurnColor = false

	foreach ( modRef in modRefs )
	{
		if ( modRef in level.burnCardWeaponModList )
			useBurnColor = true

		// TEMP prevent error for unknown mods
		if ( TMPHasSubitem( weaponRef, modRef ) )
			continue

		modRefs = []
		break
	}

	/* // GEN check?  The problem is these numbers are wrong because we don't tell the client about their challenge progress mid-match
	if ( !useBurnColor )
	{
		local challengeRef = GetClosestWeaponChallengeRef( weaponRef, player )
		if ( challengeRef )
		{
			thread Flyout_ShowWeaponChallenge( weaponRef, challengeRef )
			return
		}
	}
	*/

	wait 0.2

	Signal( player, SIGNAL_ID_FLYOUT_ACTIVATED )
	EndSignal( player, SIGNAL_ID_FLYOUT_ACTIVATED )

	file.flyoutShowing = true
	file.flyoutFadingOut = false
	file.flyoutShowStartTime = Time()

	switch ( modRefs.len() )
	{
		case 0:
			file.flyoutTitleElems.SetText( "#HUD_WEAPON_FLYOUT", GetItemName( weaponRef ) )
			file.flyoutDescElems.SetText( "#HUD_WEAPON_FLYOUT", GetItemDescription( weaponRef ) )
			file.flyoutDesc2Elems.SetText( "" )
			break
		case 1:
			file.flyoutTitleElems.SetText( "#HUD_WEAPON_FLYOUT_MODX1", GetItemName( weaponRef ), GetSubitemName( weaponRef, modRefs[0] ) )
			file.flyoutDescElems.SetText( "#HUD_WEAPON_FLYOUT", GetSubitemDescription( weaponRef, modRefs[0] ) )
			file.flyoutDesc2Elems.SetText( "" )
			break
		default:
			file.flyoutTitleElems.SetText( "#HUD_WEAPON_FLYOUT_MODX2", GetItemName( weaponRef ), GetSubitemName( weaponRef, modRefs[0] ), GetSubitemName( weaponRef, modRefs[1] )  )
			file.flyoutDescElems.SetText( "#HUD_WEAPON_FLYOUT", GetSubitemDescription( weaponRef, modRefs[0] ) )
			file.flyoutDesc2Elems.SetText( "" )
			break
	}

	if( useBurnColor )
	{
		file.flyoutTitleElems.SetColor( BURN_CARD_WEAPON_HUD_COLOR )
		file.flyoutDescElems.SetColor( BURN_CARD_WEAPON_HUD_COLOR )
		file.flyoutDesc2Elems.SetColor( BURN_CARD_WEAPON_HUD_COLOR )
		file.flyoutConnectingLine.SetColor( BURN_CARD_WEAPON_HUD_COLOR )
		file.flyoutTitleLine.SetColor( BURN_CARD_WEAPON_HUD_COLOR )
		file.flyoutTitleLineEnd_Left.SetColor( BURN_CARD_WEAPON_HUD_COLOR )
		file.flyoutTitleLineEnd_Right.SetColor( BURN_CARD_WEAPON_HUD_COLOR )

	}
	else
	{
		file.flyoutTitleElems.ReturnToBaseColor()
		file.flyoutDescElems.ReturnToBaseColor()
		file.flyoutDesc2Elems.ReturnToBaseColor()
		file.flyoutConnectingLine.ReturnToBaseColor()
		file.flyoutTitleLine.ReturnToBaseColor()
		file.flyoutTitleLineEnd_Left.ReturnToBaseColor()
		file.flyoutTitleLineEnd_Right.ReturnToBaseColor()
	}


	Wait( FLYOUT_SHOW_DURATION )

	Flyout_Hide( false )
}


function Flyout_ShowWeaponChallenge( weaponRef, challengeRef )
{
	local player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )

	wait 0.2

	Signal( player, SIGNAL_ID_FLYOUT_ACTIVATED )
	EndSignal( player, SIGNAL_ID_FLYOUT_ACTIVATED )

	file.flyoutShowing = true
	file.flyoutFadingOut = false
	file.flyoutShowStartTime = Time()

	local challengeName = GetChallengeName( challengeRef, player )
	local challengeDesc = GetChallengeDescription( challengeRef )
	local challengeProgress = GetCurrentChallengeProgress( challengeRef )
	local challengeGoal = GetCurrentChallengeGoal( challengeRef )

	file.flyoutTitleElems.SetText( "#HUD_WEAPON_FLYOUT", GetItemName( weaponRef ) )
	file.flyoutDescElems.SetText( challengeDesc[0], challengeGoal, challengeDesc[1] )
	//file.flyoutDescElems.SetText( challengeName[0], challengeName[1], challengeName[2] )
	file.flyoutDesc2Elems.SetText( "#CHALLENGE_POPUP_PROGRESS_STRING", challengeProgress, challengeGoal )

	file.flyoutTitleElems.ReturnToBaseColor()
	file.flyoutDescElems.ReturnToBaseColor()
	file.flyoutDesc2Elems.ReturnToBaseColor()
	file.flyoutConnectingLine.ReturnToBaseColor()
	file.flyoutTitleLine.ReturnToBaseColor()
	file.flyoutTitleLineEnd_Left.ReturnToBaseColor()
	file.flyoutTitleLineEnd_Right.ReturnToBaseColor()

	Wait( FLYOUT_SHOW_CHALLENGE_DURATION )

	Flyout_Hide( false )
}


function Flyout_Show( title, desc = "" )
{
	thread FlyoutShow_Threaded( title, desc )
}

function FlyoutShow_Threaded( title, desc )
{
	local player = GetLocalViewPlayer()
	Signal( player, SIGNAL_ID_FLYOUT_ACTIVATED )
	EndSignal( player, SIGNAL_ID_FLYOUT_ACTIVATED )

	file.flyoutShowing = true
	file.flyoutFadingOut = false
	file.flyoutShowStartTime = Time()

	file.flyoutTitleElems.SetTextTypeWriter( title, FLYOUT_TITLE_TYPE_TIME )
	file.flyoutDescElems.SetTextTypeWriter( desc, FLYOUT_TITLE_TYPE_TIME )

	Wait( FLYOUT_SHOW_DURATION )

	Flyout_Hide( false )
}

function Flyout_Hide( instant = true )
{
	thread Flyout_Hide_Threaded( instant )
}

function Flyout_Hide_Threaded( instant )
{
	local player = GetLocalViewPlayer()
	Signal( player, SIGNAL_ID_FLYOUT_ACTIVATED )

	if ( !instant )
	{
		file.flyoutFadingOut = true
		foreach ( elem in file.flyoutElements )
			elem.FadeOverTime( 0, FLYOUT_FADE_OUT_TIME )

		Wait( FLYOUT_FADE_OUT_TIME )
	}

	Flyout_HideAll()

	file.flyoutShowing = false
	file.flyoutFadingOut = false
}

function Flyout_HideAll()
{
	foreach ( elem in file.flyoutElements )
		elem.Hide()
}

function Flyout_Update()
{
	if ( !file.flyoutShowing )
		return

	if ( !GetLocalViewPlayer().GetViewModelEntity() || IsWatchingKillReplay() )
	{
		Flyout_Hide( true )
		return
	}

	FlyoutUpdate_Text()
	FlyoutUpdate_Lines()
}

function FlyoutUpdate_Text()
{
	file.flyoutTitleElems.Show()
	file.flyoutDescElems.Show()
	file.flyoutDesc2Elems.Show()
	if ( !file.flyoutFadingOut )
	{
		foreach ( elem in file.flyoutTitleElems.GetElements() )
		{
			elem.SetAlpha( elem.GetBaseAlpha() )
		}

		foreach ( elem in file.flyoutDescElems.GetElements() )
		{
			elem.SetAlpha( elem.GetBaseAlpha() )
		}

		foreach ( elem in file.flyoutDesc2Elems.GetElements() )
		{
			elem.SetAlpha( elem.GetBaseAlpha() )
		}
	}
}

function FlyoutUpdate_Lines()
{
	/************************************************/
	/*	Title line ( matches width of title text )	*/
	/************************************************/

	local width1 = file.flyoutTitleElems.GetTextWidth()
	local width2 = file.flyoutDescElems.GetTextWidth()
	local width = width1 > width2 ? width1 : width2

	if ( width <= 0 )
	{
		file.flyoutTitleLine.Hide()
		file.flyoutTitleLineEnd_Left.Hide()
		file.flyoutTitleLineEnd_Right.Hide()
		file.flyoutConnectingLine.Hide()
		return
	}

	file.flyoutTitleLine.SetWidth( width )
	file.flyoutTitleLine.Show()
	if ( !file.flyoutFadingOut )
		file.flyoutTitleLine.SetAlpha( file.flyoutTitleLine.GetBaseAlpha() )

	file.flyoutTitleLineEnd_Left.SetX( file.flyoutTitleLine.GetX() - ( file.flyoutTitleLineEnd_Left.GetWidth() ) )
	file.flyoutTitleLineEnd_Left.SetY( file.flyoutTitleLine.GetY() )
	file.flyoutTitleLineEnd_Left.Show()
	if ( !file.flyoutFadingOut )
		file.flyoutTitleLineEnd_Left.SetAlpha( file.flyoutTitleLineEnd_Left.GetBaseAlpha() )

	file.flyoutTitleLineEnd_Right.SetX( file.flyoutTitleLine.GetX() + width - ( file.flyoutTitleLineEnd_Right.GetWidth() * 0.5 ) )
	file.flyoutTitleLineEnd_Right.SetY( file.flyoutTitleLine.GetY() )
	file.flyoutTitleLineEnd_Right.Show()
	if ( !file.flyoutFadingOut )
		file.flyoutTitleLineEnd_Right.SetAlpha( file.flyoutTitleLineEnd_Right.GetBaseAlpha() )

	/************************************************/
	/*				Connecting Line					*/
	/************************************************/
	local time = Time()

	// We don't show the connecting line until the main line is done growing
	if ( time - file.flyoutShowStartTime < FLYOUT_TITLE_TYPE_TIME )
		return

	// Connecting line goes from end of title line to point, but grows in size to reach that point
	local screenPos = GetViewmodelBoneLocation()
	local startX = file.flyoutTitleLine.GetX() + width + ( file.flyoutTitleLineEnd_Right.GetWidth() * 0.25 )
	local startY = file.flyoutTitleLine.GetY()
	local endX = screenPos[0]
	local endY = screenPos[1]

	// calculate the angle of the connecting line
	local offsetX = endX - startX
	local offsetY = endY - startY
	local angle = ( atan( offsetX / offsetY ) * ( 180 / PI ) )

	// Calculate how long the connecting line should be
	local length = sqrt( offsetX * offsetX + offsetY * offsetY )
	local connectLineStartTime = file.flyoutShowStartTime + FLYOUT_TITLE_TYPE_TIME
	local connectLineEndTime = connectLineStartTime + FLYOUT_POINT_LINE_TIME
	length = GetValueFromFraction( time, connectLineStartTime, connectLineEndTime, 0.0, length )
	local offsetXfrac = GetValueFromFraction( time, connectLineStartTime, connectLineEndTime, offsetX, 0.0 )
	local offsetYfrac = GetValueFromFraction( time, connectLineStartTime, connectLineEndTime, offsetY, 0.0 )

	// Calculate where the line should be positioned
	local posX = endX - ( offsetXfrac / 2.0 ) - ( length / 2.0 ) - ( offsetX / 2.0 )
	local posY = endY - ( offsetYfrac / 2.0 ) - ( offsetY / 2.0 )

	// Position the diagonal connecting line
	file.flyoutConnectingLine.SetWidth( length )
	file.flyoutConnectingLine.SetPos( posX, posY )
	file.flyoutConnectingLine.SetRotation( angle + 90.0 )
	file.flyoutConnectingLine.Show()
	if ( !file.flyoutFadingOut )
		file.flyoutConnectingLine.SetAlpha( file.flyoutConnectingLine.GetBaseAlpha() )
}

function GetViewmodelBoneLocation()
{
	local viewmodel = GetLocalViewPlayer().GetViewModelEntity()
	local screenSize = Hud.GetScreenSize()

	local attachIndex = viewmodel.LookupAttachment( "shell" )
	if ( attachIndex && attachIndex >= 0 )
	{
		local worldCoord = viewmodel.GetAttachmentOrigin( attachIndex )
		local pos = Hud.ToScreenSpaceClamped( worldCoord )
		return Hud.ClipScreenPositionToBox( pos[0], pos[1], 0, screenSize[0], 0, screenSize[1] )
	}
	else
	{
		local pos = []
		pos.append( screenSize[0] / 2.0 )
		pos.append( screenSize[1] - 100.0 )
		return pos
	}
}



















function InfoFlyout_AddPlayer()
{
	InfoFlyout_Init()
}

function InfoFlyout_Init()
{
	// Title element
	file.infoFlyoutTitleElem = InfoFlyoutElement( "InfoFlyout_Title" )
	file.infoFlyoutTitleElem.EnableKeyBindingIcons()
	file.infoFlyoutIcon = InfoFlyoutElement( "InfoFlyout_Icon" )

	// Description element
	file.infoFlyoutDescElems = InfoFlyoutElementWithGlow( "InfoFlyout_Description", "InfoFlyout_DescriptionGlow" )

	// Title line element
	file.infoFlyoutTitleLine = InfoFlyoutElement( "InfoFlyout_TitleLine" )
	file.infoFlyoutTitleLineThickness = file.infoFlyoutTitleLine.GetBaseHeight()
	file.infoFlyoutTitleLineHalfThickness = file.infoFlyoutTitleLineThickness / 2.0

	// Title line ends elements
	file.infoFlyoutTitleLineEnd_Left = InfoFlyoutElement( "InfoFlyout_TitleLineEnd_Left" )
	file.infoFlyoutTitleLineEnd_Right = InfoFlyoutElement( "InfoFlyout_TitleLineEnd_Right" )

	// Connecting Line
	file.infoFlyoutConnectingLine = InfoFlyoutElement( "InfoFlyout_ConnectingLine" )
	file.infoFlyoutConnectingLine.SetBaseAlpha( FLYOUT_CONNECTING_LINE_ALPHA )
	file.infoFlyoutConnectingLine.SetAlpha( FLYOUT_CONNECTING_LINE_ALPHA )
}

function InfoFlyoutElement( name )
{
	local elem = HudElement( name )
	file.infoFlyoutElements.append( elem )
	return elem
}

function InfoFlyoutElementWithGlow( name1, name2 )
{
	local group = HudElementGroup( name1 )

	// all flyout elements rae added to this array
	file.infoFlyoutElements.append( group.CreateElement( name1 ) )
	file.infoFlyoutElements.append( group.CreateElement( name2 ) )
	return group
}

function InfoFlyout_Show( title, desc, entity, attachment )
{
	thread InfoFlyoutShow_Threaded( title, desc, entity, attachment )
}

function InfoFlyoutShow_Threaded( title, desc, entity, attachment )
{
	local player = GetLocalViewPlayer()
	Signal( player, SIGNAL_ID_INFOFLYOUT_ACTIVATED )
	EndSignal( player, SIGNAL_ID_INFOFLYOUT_ACTIVATED )

	InfoFlyout_TitleShow( title, desc, entity, attachment )

	wait FLYOUT_SHOW_DURATION

	InfoFlyout_Hide()
}

function InfoFlyout_TitleShow( title, desc, entity, attachment )
{
	file.infoFlyoutShowing = FLYOUT_TEXT
	file.infoFlyoutFadingOut = false
	file.infoFlyoutShowStartTime = Time()

	file.infoFlyoutEntity = entity
	file.infoFlyoutAttachment = attachment

	file.infoFlyoutTitleElem.SetTextTypeWriter( title, FLYOUT_TITLE_TYPE_TIME )
	file.infoFlyoutDescElems.SetTextTypeWriter( desc, FLYOUT_TITLE_TYPE_TIME )
}

function InfoFlyout_Icon( image, desc, entity, attachment )
{
	thread InfoFlyout_IconThread( image, desc, entity, attachment )
}

function InfoFlyout_IconThread( image, desc, entity, attachment )
{
	local player = GetLocalViewPlayer()
	player.Signal( SIGNAL_ID_INFOFLYOUT_ACTIVATED )
	player.EndSignal( SIGNAL_ID_INFOFLYOUT_ACTIVATED )

	InfoFlyout_IconShow( image, desc, entity, attachment )
	wait FLYOUT_SHOW_DURATION
	thread InfoFlyout_Fadeout()
}


function InfoFlyout_IconShow( image, desc, entity, attachment )
{
	local player = GetLocalViewPlayer()
	Signal( player, SIGNAL_ID_INFOFLYOUT_ACTIVATED )
	InfoFlyout_IconShow( image, desc, entity, attachment )
}

function InfoFlyout_IconShow( image, desc, entity, attachment )
{
	file.infoFlyoutShowing = FLYOUT_ICON
	file.infoFlyoutFadingOut = false
	file.infoFlyoutShowStartTime = Time()

	file.infoFlyoutEntity = entity
	file.infoFlyoutAttachment = attachment

	file.infoFlyoutIcon.SetImage( image )
	file.infoFlyoutDescElems.SetTextTypeWriter( desc, FLYOUT_TITLE_TYPE_TIME )
	SetInfoElemsTobaseAlpha()
}

function InfoFlyout_Hide_Threaded()
{
	thread InfoFlyout_Fadeout()
}

function InfoFlyout_Fadeout()
{
	local player = GetLocalViewPlayer()
	Signal( player, SIGNAL_ID_INFOFLYOUT_ACTIVATED )
	EndSignal( player, SIGNAL_ID_INFOFLYOUT_ACTIVATED )

	file.infoFlyoutFadingOut = true
	foreach ( elem in file.infoFlyoutElements )
	{
		elem.FadeOverTime( 0, FLYOUT_FADE_OUT_TIME )
	}

	wait FLYOUT_FADE_OUT_TIME
	InfoFlyout_Hide()
}

function InfoFlyout_Hide()
{
	foreach ( elem in file.infoFlyoutElements )
	{
		elem.Hide()
	}

	file.infoFlyoutShowing = FLYOUT_NONE
	file.infoFlyoutFadingOut = false

	local player = GetLocalViewPlayer()
	if ( IsValid( player ) )
		Signal( player, SIGNAL_ID_INFOFLYOUT_ACTIVATED )
}

function InfoFlyout_Update()
{
	if ( !file.infoFlyoutShowing )
		return

	InfoFlyoutUpdate_Text()
	InfoFlyoutUpdate_Lines()
}

function InfoFlyoutUpdate_Text()
{
	switch ( file.infoFlyoutShowing )
	{
		case FLYOUT_TEXT:
			file.infoFlyoutTitleElem.Show()
			break

		case FLYOUT_ICON:
			file.infoFlyoutIcon.Show()
			break
	}

	file.infoFlyoutDescElems.Show()
	if ( !file.infoFlyoutFadingOut )
	{
		SetInfoElemsTobaseAlpha()
	}
}

function SetInfoElemsTobaseAlpha()
{
	file.infoFlyoutIcon.SetAlpha( file.infoFlyoutIcon.GetBaseAlpha() )
	file.infoFlyoutTitleElem.SetAlpha( file.infoFlyoutTitleElem.GetBaseAlpha() )

	foreach ( elem in file.infoFlyoutDescElems.GetElements() )
	{
		elem.SetAlpha( elem.GetBaseAlpha() )
	}
}

function InfoFlyoutUpdate_Lines()
{
	/************************************************/
	/*	Title line ( matches width of title text )	*/
	/************************************************/

	local width1 = file.infoFlyoutTitleElem.GetTextWidth()
	local width2 = file.infoFlyoutDescElems.GetTextWidth()
	local width = width1 > width2 ? width1 : width2

	if ( width <= 0 || !IsValid( file.infoFlyoutEntity ) )
	{
		file.infoFlyoutTitleLine.Hide()
		file.infoFlyoutTitleLineEnd_Left.Hide()
		file.infoFlyoutTitleLineEnd_Right.Hide()
		file.infoFlyoutConnectingLine.Hide()
		return
	}

	file.infoFlyoutTitleLine.SetWidth( width )
	file.infoFlyoutTitleLineEnd_Left.SetX( file.infoFlyoutTitleLine.GetX() - ( file.infoFlyoutTitleLineEnd_Left.GetWidth() ) )
	file.infoFlyoutTitleLineEnd_Left.SetY( file.infoFlyoutTitleLine.GetY() )
	file.infoFlyoutTitleLineEnd_Right.SetX( file.infoFlyoutTitleLine.GetX() + width - ( file.infoFlyoutTitleLineEnd_Right.GetWidth() * 0.5 ) )
	file.infoFlyoutTitleLineEnd_Right.SetY( file.infoFlyoutTitleLine.GetY() )

	if ( FLYOUT_TITLE_LINE )
	{
		file.infoFlyoutTitleLine.Show()
		if ( !file.infoFlyoutFadingOut )
			file.infoFlyoutTitleLine.SetAlpha( file.infoFlyoutTitleLine.GetBaseAlpha() )

		file.infoFlyoutTitleLineEnd_Left.Show()
		if ( !file.infoFlyoutFadingOut )
			file.flyoutTitleLineEnd_Left.SetAlpha( file.flyoutTitleLineEnd_Left.GetBaseAlpha() )

		file.infoFlyoutTitleLineEnd_Right.Show()
		if ( !file.infoFlyoutFadingOut )
			file.infoFlyoutTitleLineEnd_Right.SetAlpha( file.infoFlyoutTitleLineEnd_Right.GetBaseAlpha() )
	}

	/************************************************/
	/*				Connecting Line					*/
	/************************************************/
	local time = Time()

	// We don't show the connecting line until the main line is done growing
	if ( time - file.infoFlyoutShowStartTime < FLYOUT_TITLE_TYPE_TIME )
		return

	// Connecting line goes from end of title line to point, but grows in size to reach that point
	local screenPos = GetEntAttachmentScreenLocation( file.infoFlyoutEntity, file.infoFlyoutAttachment )

	if ( !screenPos )
		return

	local startX = file.infoFlyoutTitleLine.GetX() /*+ width +*/ + ( file.infoFlyoutTitleLineEnd_Right.GetWidth() * 0.25 )
	local startY = file.infoFlyoutTitleLine.GetY()

	local endX = screenPos[0]
	local endY = screenPos[1]

	// calculate the angle of the connecting line
	local offsetX = endX - startX
	local offsetY = endY - startY
	local angle = ( atan( offsetX / offsetY ) * ( 180 / PI ) )

	// Calculate how long the connecting line should be
	local length = sqrt( offsetX * offsetX + offsetY * offsetY )
	local connectLineStartTime = file.infoFlyoutShowStartTime + FLYOUT_TITLE_TYPE_TIME
	local connectLineEndTime = connectLineStartTime + FLYOUT_POINT_LINE_TIME
	length = GetValueFromFraction( time, connectLineStartTime, connectLineEndTime, 0.0, length )
	local offsetXfrac = GetValueFromFraction( time, connectLineStartTime, connectLineEndTime, offsetX, 0.0 )
	local offsetYfrac = GetValueFromFraction( time, connectLineStartTime, connectLineEndTime, offsetY, 0.0 )

	// Calculate where the line should be positioned
	local posX = endX - ( offsetXfrac / 2.0 ) - ( length / 2.0 ) - ( offsetX / 2.0 )
	local posY = endY - ( offsetYfrac / 2.0 ) - ( offsetY / 2.0 )

	// Position the diagonal connecting line
	file.infoFlyoutConnectingLine.SetWidth( length )
	file.infoFlyoutConnectingLine.SetPos( posX, posY )
	file.infoFlyoutConnectingLine.SetRotation( angle + 90.0 )
	file.infoFlyoutConnectingLine.Show()

	if ( !file.infoFlyoutFadingOut )
		file.infoFlyoutConnectingLine.SetAlpha( file.infoFlyoutConnectingLine.GetBaseAlpha() )
}

function GetEntAttachmentScreenLocation( entity, attachment )
{
	local screenSize = Hud.GetScreenSize()

	local worldCoord
	if ( entity.IsZipline() )
	{
		worldCoord = GetLocalViewPlayer().GetUsePromptPosition()
	}
	else
	{
		local attachIndex = entity.LookupAttachment( attachment )
		if ( attachIndex <= 0 )
			return null

		worldCoord = entity.GetAttachmentOrigin( attachIndex )
	}

	local pos = Hud.ToScreenSpaceClamped( worldCoord )
	return Hud.ClipScreenPositionToBox( pos[0], pos[1], 0, screenSize[0], 0, screenSize[1] )
}