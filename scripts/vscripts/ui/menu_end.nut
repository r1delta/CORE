const DEV = 0 //set this to 0 before checking in

function main()
{
	Globalize( OnOpenEndMenu )
	Globalize( OnCloseEndMenu )

	RegisterSignal( "PlayingEndingDone" )
	RegisterSignal( "EscAllowed" )
	RegisterSignal( "EndingDisconnected" )

	file.EscButtonPressed <- false
	file.EscAllowed <- false
}

function OnCloseEndMenu()
{
	if ( !file.EscAllowed )
		return

	if( uiGlobal.activeMenu != GetMenu( "EndMenu" ) )
		return

	CloseTopMenu()
	Signal( uiGlobal.signalDummy, "PlayingEndingDone" )
	if ( !DEV )
		ClientCommand( "EndMenuClosed" )//resets persistent data about beating game

	local reward = PlayerGetsReward()
	if ( reward )
		OnOpenCampaignRewardMenu( reward )
	else
		ShowEOGSummary()
}

function OnOpenEndMenu()
{
	AdvanceMenu( GetMenu( "EndMenu" ) )
	thread __CatchDisconnect()
	thread __OnOpenEndMenuInternal()
}

function __CatchDisconnect()
{
	EndSignal( uiGlobal.signalDummy, "PlayingEndingDone" )
	while( 1 )
	{
		wait 0.1

		if ( !IsConnected() )
			break
	}
	Signal( uiGlobal.signalDummy, "EndingDisconnected" )
}

function __OnOpenEndMenuInternal()
{
	EndSignal( uiGlobal.signalDummy, "PlayingEndingDone" )
	EndSignal( uiGlobal.signalDummy, "EndingDisconnected" )

	if ( uiGlobal.loadingLevel )
		WaitSignal( uiGlobal.signalDummy, "LevelFinishedLoading" )

	thread WaitForSkipCreditsInput()
	thread RemoveBlurDelayed()
	thread FadeFromBlack()

	if ( GetPersistentVar( "campaignFinishedIMCjustNow" ) == eCampaignFinishedNum.FIRSTTIME )
	{
		if ( GetPersistentVar( "campaignLevelsFinishedIMC" ) < CAMPAIGN_LEVEL_COUNT )
			thread DisplayText( "#ENDING_IMCWIN4_LINE1", "#ENDING_IMCWIN4_LINE2", "#ENDING_ANYWIN4_LINE3" )
		else if ( GetPersistentVar( "campaignLevelsFinishedMCOR" ) < CAMPAIGN_LEVEL_COUNT )
			thread DisplayText( "#ENDING_IMCWIN1_LINE1", "#ENDING_IMCWIN1_LINE2", "#ENDING_IMCWIN1_LINE3" )
		else
			thread DisplayText( "#ENDING_ANYWIN2_LINE1", "#ENDING_ANYWIN2_LINE2", "#ENDING_ANYWIN2_LINE3" )
	}
	else if ( GetPersistentVar( "campaignFinishedMCORjustNow" ) == eCampaignFinishedNum.FIRSTTIME )
	{
		if ( GetPersistentVar( "campaignLevelsFinishedMCOR" ) < CAMPAIGN_LEVEL_COUNT )
			thread DisplayText( "#ENDING_MCORWIN4_LINE1", "#ENDING_MCORWIN4_LINE2", "#ENDING_ANYWIN4_LINE3" )
		else if ( GetPersistentVar( "campaignLevelsFinishedIMC" ) < CAMPAIGN_LEVEL_COUNT )
			thread DisplayText( "#ENDING_MCORWIN1_LINE1", "#ENDING_MCORWIN1_LINE2", "#ENDING_MCORWIN1_LINE3" )
		else
			thread DisplayText( "#ENDING_ANYWIN2_LINE1", "#ENDING_ANYWIN2_LINE2", "#ENDING_ANYWIN2_LINE3" )
	}
	else if ( GetPersistentVar( "campaignFinishedIMCjustNow" ) )
		thread DisplayText( "#ENDING_IMCWIN3_LINE1", "#ENDING_ANYWIN3_LINE2", "#ENDING_ANYWIN3_LINE3" )
	else if ( GetPersistentVar( "campaignFinishedMCORjustNow" ) )
		thread DisplayText( "#ENDING_MCORWIN3_LINE1", "#ENDING_ANYWIN3_LINE2", "#ENDING_ANYWIN3_LINE3" )


	if ( GetPersistentVar( "campaignFinishedIMCjustNow" ) )
		EmitUISound( "Music_CampaignEnd_IMC" )
	else if ( GetPersistentVar( "campaignFinishedMCORjustNow" ) )
		EmitUISound( "Music_CampaignEnd_MCOR" )

	OnThreadEnd(
		function() : ()
		{
			OnCloseEndMenu()
		}
	)

	wait 25
	FadeToBlack()
}

function DisplayText( text1, text2, text3 )
{
	EndSignal( uiGlobal.signalDummy, "PlayingEndingDone" )
	EndSignal( uiGlobal.signalDummy, "EndingDisconnected" )

	local menu = GetMenu( "EndMenu" )
	local scan = GetElem( menu, "Congrats_Scan" )
	scan.Hide()

	local lines = []
	local num = 3
	for( local i = 0; i < num; i++ )
	{
		local line = {}
		line.text <- GetElem( menu, "Congrats_Line" + i )
		line.shadow <- GetElem( menu, "Congrats_Shadow" + i )
		line.text.Show()
		line.text.SetColor( 255,255,255,255 )
		line.shadow.Show()
		line.text.SetAlpha( 0 )
		line.shadow.SetAlpha( 0 )
		//SetPosition( line.text, x, y + ( i * 40 ) )

		lines.append( line )
	}

	SetTextWithShadow( lines[0], text1 )
	SetTextWithShadow( lines[1], text2 )
	SetTextWithShadow( lines[2], text3 )

	wait 6.0
	thread DoScan( scan, lines[0].text.GetPos()[0], lines[0].text.GetPos()[1] )

	local time = 3
	local shadowTime = time * 0.25
	for( local i = 0; i < num; i++ )
	{

		lines[i].text.FadeOverTime( 255, time, INTERPOLATOR_ACCEL )
		wait shadowTime
		lines[i].shadow.FadeOverTime( 180, time - shadowTime, INTERPOLATOR_ACCEL )

		wait 2.0 - shadowTime
	}

	wait 8.0

	for( local i = 0; i < num; i++ )
	{
		local time = 3.5
		lines[i].text.FadeOverTime( 0, time, INTERPOLATOR_ACCEL )
		lines[i].shadow.FadeOverTime( 0, time * 0.75, INTERPOLATOR_ACCEL )
	}
}

function DoScan( scan, x, y )
{
	EndSignal( uiGlobal.signalDummy, "PlayingEndingDone" )
	EndSignal( uiGlobal.signalDummy, "EndingDisconnected" )

	local time, scaletime
	local offset = 500

	//animate
	scan.Show()
	scan.ReturnToBaseSize()
	scan.SetScale( 0.02, 1.5 )
	scan.SetColor( 255, 255, 255, 0 )
	scan.SetPos( x + offset - 20, y - 20 )

	time = 0.25
	scan.OffsetOverTime( -offset, 0, time, INTERPOLATOR_ACCEL )
	scan.FadeOverTime( 190, 0.1 )
	wait time

	scaletime = 0.5
	time = 0.1
	scan.ScaleOverTime( 1.0, 0.0, scaletime, INTERPOLATOR_DEACCEL )
	scan.OffsetOverTime( 0, 45, scaletime, INTERPOLATOR_DEACCEL )
	scan.FadeOverTime( 230, time, INTERPOLATOR_ACCEL )

	wait time
	scan.FadeOverTime( 0, scaletime - time, INTERPOLATOR_DEACCEL )

	wait scaletime
	scan.Hide()
}

function SetTextWithShadow( line, text )
{
	line.text.SetText( text )
	line.shadow.SetText( text )
}

function FadeFromBlack()
{
	EndSignal( uiGlobal.signalDummy, "PlayingEndingDone" )
	EndSignal( uiGlobal.signalDummy, "EndingDisconnected" )

	local menu = GetMenu( "EndMenu" )
	local black = GetElem( menu, "FullBlack" )

	black.Show()
	black.SetAlpha( 255 )
	wait 1.5
	black.FadeOverTime( 0, 3, INTERPOLATOR_ACCEL )
}

function FadeToBlack()
{
	local menu = GetMenu( "EndMenu" )
	local black = GetElem( menu, "FullBlack" )

	local time = 3

	black.Show()
	black.SetAlpha( 0 )
	black.FadeOverTime( 255, time, INTERPOLATOR_ACCEL )

	wait time
}

function RemoveBlurDelayed()
{
	WaitEndFrame()
	SetBlurEnabled( false )
}

function SetOffset( elem, time, x, y = 0, sX = 1, sY = 1 )
{
	local pos = elem.GetBasePos()
	elem.SetPos( pos[0] + x, pos[1] + y )
	//elem.OffsetOverTime( -x, -y, time )
	elem.MoveOverTime( pos[0], pos[1], time )

	if ( sX != 1 || sY != 1 )
	{
		elem.SetScale( sX, sY )
		elem.ScaleOverTime( 1.0, 1.0, time )
	}
}

function SetPosition( elem, x, y = 0 )
{
	local pos = elem.GetBasePos()
	elem.SetPos( pos[0] + x, pos[1] + y )
}

function WaitForSkipCreditsInput()
{
	EndSignal( uiGlobal.signalDummy, "PlayingEndingDone" )
	EndSignal( uiGlobal.signalDummy, "EndingDisconnected" )

	local inputs = []

	// Gamepad
	inputs.append( BUTTON_B )
	inputs.append( BUTTON_BACK )
	inputs.append( BUTTON_START )

	// Keyboard/Mouse
	inputs.append( KEY_ESCAPE )

	thread HandleEscapeButtonAllowed()
	thread HandleEscapeButtonIcon()

	if ( GetPersistentVar( "campaignFinishedIMCjustNow" ) == eCampaignFinishedNum.FIRSTTIME || GetPersistentVar( "campaignFinishedMCORjustNow" ) == eCampaignFinishedNum.FIRSTTIME )
		wait 3
	else
		wait 0.1

	foreach ( input in inputs )
		RegisterButtonPressedCallback( input, ThreadSkipEndingButton_Press )

	OnThreadEnd(
		function() : ( inputs )
		{
			foreach ( input in inputs )
				DeregisterButtonPressedCallback( input, ThreadSkipEndingButton_Press )
		}
	)

	WaitSignal( uiGlobal.signalDummy, "PlayingEndingDone" )
}

function HandleEscapeButtonIcon()
{
	EndSignal( uiGlobal.signalDummy, "PlayingEndingDone" )
	EndSignal( uiGlobal.signalDummy, "EndingDisconnected" )

	//show esc button
	local menu = GetMenu( "EndMenu" )
	local back = []
	back.append( GetElem( menu, "ImgBackConsole" ) )
	back.append( GetElem( menu, "LblBackConsole" ) )
	back.append( GetElementsByClassname( menu, "PCBackButtonClass" )[0] )

	foreach( elem in back )
		elem.Hide()

	WaitSignal( uiGlobal.signalDummy, "EscAllowed" )

	if ( !file.EscButtonPressed )
		return

	foreach( elem in back )
	{
		elem.Show()
		elem.SetAlpha( 0 )
		elem.FadeOverTime( 255, 1.0, INTERPOLATOR_ACCEL )
	}
}

function HandleEscapeButtonAllowed()
{
	EndSignal( uiGlobal.signalDummy, "PlayingEndingDone" )
	EndSignal( uiGlobal.signalDummy, "EndingDisconnected" )

	file.EscAllowed = false

	local delay
	if ( GetPersistentVar( "campaignFinishedIMCjustNow" ) == eCampaignFinishedNum.FIRSTTIME || GetPersistentVar( "campaignFinishedMCORjustNow" ) == eCampaignFinishedNum.FIRSTTIME )
		delay = 12
	else
		delay = 3.5

	wait delay

	file.EscAllowed = true
	Signal( uiGlobal.signalDummy, "EscAllowed" )
}

function ThreadSkipEndingButton_Press( button )
{
	thread SkipEndingButton_Press()
}

function SkipEndingButton_Press()
{
	file.EscButtonPressed = true

	if ( file.EscAllowed )
		OnCloseEndMenu()
}

function PlayerGetsReward()
{
	if ( GetPersistentVar( "rewardChassis[titan_stryder]" ) && GetPersistentVar( "newChassis[titan_stryder]" ) )
		return eCampaignReward.REWARD_STRYDER
	else if ( GetPersistentVar( "rewardChassis[titan_ogre]" ) && GetPersistentVar( "newChassis[titan_ogre]" ) )
		return eCampaignReward.REWARD_OGRE

	return 0
}