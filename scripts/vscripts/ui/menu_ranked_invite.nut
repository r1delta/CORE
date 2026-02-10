function main()
{
	Globalize( OnOpenRankedInviteMenu )
	Globalize( OnCloseRankedInviteMenu )
	Globalize( InitRankedInviteMenu )
	Globalize( SCB_UpdateSponsorables )
	Globalize( HasPlayersToInvite )

	file.hasSponsorables <- false
}

function InitRankedInviteMenu()
{
	local menu = GetMenu( "RankedInviteMenu" )
	file.menu <- menu
	file.SponsorPlayerButton <- GetElementsByClassname( menu, "SponsorPlayerButton" )
	foreach ( button in file.SponsorPlayerButton )
	{
		button.AddEventHandler( UIE_CLICK, Bind( OnClick_SponsorPlayerButton ) )
		button.s.hash <- null
		button.SetEnabled( true )
		button.Hide()
	}

	file.SponsorLabel_Subtitle <- menu.GetChild( "SponsorLabel_Subtitle" )
	file.SponsorLabel_Subtitle1 <- menu.GetChild( "SponsorLabel_Subtitle1" )

	AddMenuEventHandler(menu, R1DELTA_UIE_OPEN, OnOpenRankedInviteMenu)
	AddMenuEventHandler(menu, R1DELTA_UIE_CLOSE, OnCloseRankedInviteMenu)
}

function OnCloseRankedInviteMenu()
{
}

function OnOpenRankedInviteMenu()
{
	// request the sponsorable players
	if ( !IsFullyConnected() )
		return

	file.hasSponsorables = false
	UpdateFooterButtons()

	local max = PersistenceGetArrayCount( "ranked.sponsorHash" )
	for ( local i = 0; i < max; i++ )
	{
		local button = file.SponsorPlayerButton[i]
		button.SetText( "" )
		button.Hide()
	}

	if ( DevEverythingUnlocked() )
		file.SponsorLabel_Subtitle.SetText( "Disabled (dev EVERYTHING_UNLOCKED is set!)" )
	else
		file.SponsorLabel_Subtitle.SetText( "" )

	local count = GetPlayerSponsorshipsRemaining()
	switch ( count )
	{
		case 0:
			file.SponsorLabel_Subtitle1.SetText( "" )
			break

		case 1:
			file.SponsorLabel_Subtitle1.SetText( "#RANKED_MENU_SPONSOR_SINGULAR" )
			break

		default:
			file.SponsorLabel_Subtitle1.SetText( "#RANKED_MENU_SPONSOR_PLURAL", count )
			break
	}

	ClientCommand( "RequestSponsorables" )
}

function SCB_UpdateSponsorables( count )
{
	file.hasSponsorables = false
	if ( count == 0 )
	{
		//local button = file.SponsorPlayerButton[0]
		//button.SetText( "blah" )
		//button.Show()
		file.SponsorLabel_Subtitle.SetText( "#RANKED_MENU_SPONSOR_NONE" )
		return
	}

	file.SponsorLabel_Subtitle.SetText( "" )


	for ( local i = 0; i < count; i++ )
	{
		local hash = GetPersistentVar( "ranked.sponsorHash[" + i + "]" )
		local name = GetPersistentVar( "ranked.sponsorName[" + i + "]" )
		local button = file.SponsorPlayerButton[i]
		button.SetText( name )
		button.s.hash = hash
		button.Show()
		file.hasSponsorables = true

		if ( i == 0 )
			button.SetFocused()
	}

	UpdateFooterButtons()

	local max = PersistenceGetArrayCount( "ranked.sponsorHash" )
	for ( local i = count; i < max; i++ )
	{
		local button = file.SponsorPlayerButton[i]
		button.SetText( "" )
		button.Hide()
	}
}

function OnClick_SponsorPlayerButton( button )
{
	ClientCommand( "SponsorPlayer " + button.s.hash )
	CloseTopMenu()
}

function HasPlayersToInvite()
{
	return file.hasSponsorables
}