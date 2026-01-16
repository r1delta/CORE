function main()
{
	Globalize( OnOpenRankedModesMenu )
	Globalize( OnCloseRankedModesMenu )
	Globalize( InitRankedModesMenu )
	Globalize( GetSupportedGameModes )
}

function InitRankedModesMenu( menu )
{
	AddEventHandlerToButtonClass( menu, "ModeButton", UIE_GET_FOCUS, ModeButton_GetFocus )
	file.buttons <- GetElementsByClassname( menu, "ModeButton" )
	file.menu <- menu

	AddMenuEventHandler(menu, R1DELTA_UIE_OPEN, OnOpenRankedModesMenu)
	AddMenuEventHandler(menu, R1DELTA_UIE_CLOSE, OnCloseRankedModesMenu)
}

function OnOpenRankedModesMenu()
{
	SetupGameModeButtons()
	file.buttons[0].SetFocused()
}

function OnCloseRankedModesMenu()
{
}

function SetupGameModeButtons()
{
	local modesArray = GetSupportedGameModes()
	local menu = GetMenu( "RankedModesMenu" )

	foreach ( button in file.buttons )
	{
		local buttonID = button.GetScriptID().tointeger()

		if ( buttonID >= 0 && buttonID < modesArray.len() )
		{
			button.SetText( GetGameModeDisplayName( modesArray[buttonID] ) )
			button.SetEnabled( true )
		}
		else
		{
			button.SetText( "" )
			button.SetEnabled( false )
		}
	}
}

function ModeButton_GetFocus( button )
{
	if ( !IsFullyConnected() )
		return

	local mapID = button.GetScriptID().tointeger()

	local menu = GetMenu( "RankedModesMenu" )
	local nextModeImage = menu.GetChild( "NextModeImage" )
	local nextModeName = menu.GetChild( "NextModeName" )
	local nextModeDesc = menu.GetChild( "NextModeDesc" )

	local modesArray = GetSupportedGameModes()

	if ( mapID > modesArray.len() )
		return

	local modeName = modesArray[mapID]

	nextModeImage.SetImage( GetGameModeDisplayImage( modeName ) )
	nextModeName.SetText( GetGameModeDisplayName( modeName ) )
	nextModeDesc.SetText( GetGameModeDisplayDesc( modeName ) )


	// Fill in what factors into this game mode
	local mapping = GetContributionMappingForGamemode( modeName ).mapping
	local factorLabels = GetElementsByClassname( GetMenu( "RankedModesMenu" ), "FactorLabel" )
	for ( local i = 0; i < factorLabels.len(); i++ )
	{
		if ( i < mapping.len() )
		{
			local desc = GetStringForContributionType( mapping[i], modeName )
			factorLabels[i].SetText( "#RANKED_LEAGUE_POINT_FACTOR", desc )
			factorLabels[i].Show()
		}
		else
		{
			factorLabels[i].Hide()
		}
	}

	if ( factorLabels.len() > mapping.len() )
	{
		local percent = ( RankedWinLossPercent( modeName ) * 100 ).tointeger()
		// add the game win percent
		local index = mapping.len()
		local label = factorLabels[index]
		label.SetText( "#RANKED_LEAGUE_POINT_FACTOR_VICTORY", "#GAMEMODE_VICTORY", " " + percent + "%" )
		label.Show()
	}
}

function GetSupportedGameModes()
{
	if ( !IsFullyConnected() )
		return []

	local modes = {}
	local count = GetPlaylistCount()
	for ( local i = 0; i < count; i++ )
	{
		local playlist = GetPlaylistName( i )
		if ( GetPlaylistVar( playlist, "visible" ).tointeger() <= 0 )
			continue
		if ( GetPlaylistVar( playlist, "ranking_supported" ).tointeger() <= 0 )
			continue

		AddModesFromPlaylist( playlist, modes )
	}

	local modesArray = []
	foreach ( mode, _ in modes )
	{
		modesArray.append( mode )
	}

	modesArray.sort()

	return modesArray
}

function AddModesFromPlaylist( playlist, modes )
{
	local count = GetMapCountForPlaylist( playlist )
	for ( local i = 0; i < count; i++ )
	{
		local mode = GetPlaylistGamemodeByIndex( playlist, i )
		modes[ mode ] <- true
	}
}
