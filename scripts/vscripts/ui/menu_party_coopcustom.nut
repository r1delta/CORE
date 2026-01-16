function main()
{
	Globalize( InitCoopPartyCustomMenu )
	Globalize( OnOpenCoopPartyCustomMenu )
	Globalize( OnCloseCoopPartyCustomMenu )
}

function InitCoopPartyCustomMenu( menu )
{
	AddEventHandlerToButton( menu, "CoopCustomChooseMapButton", UIE_CLICK, Bind( CoopCustomChooseMapButton_Activate ) )
	AddEventHandlerToButton( menu, "CoopCustomIsOpenToPublicButton", UIE_CLICK, Bind( CoopCustomIsOpenToPublicButton_Activate ) )
	AddEventHandlerToButton( menu, "CoopCustomLaunchButton", UIE_CLICK, Bind( CoopCustomLaunchButton_Activate ) )

	RegisterUIVarChangeCallback( "privatematch_map", CreateAMatchMapVarChanged )
	RegisterUIVarChangeCallback( "createamatch_isPrivate", CreateAMatchIsPrivateVarChanged )

	file.CoopCustomMapLabel <- menu.GetChild( "CoopCustomMapLabel" )
	file.CoopCustomIsOpenToPublicLabel <- menu.GetChild( "CoopCustomIsOpenToPublicLabel" )
	file.CoopCustomLowpopBackground <- menu.GetChild( "CoopCustomLowpopBackground" )
	file.CoopCustomLowpopWarningTitle <- menu.GetChild( "CoopCustomLowpopWarningTitle" )
	file.CoopCustomLowpopWarningText <- menu.GetChild( "CoopCustomLowpopWarningText" )
}

function OnOpenCoopPartyCustomMenu( menu )
{
	UpdateTeamInfo( menu, GetTeam() )

	local buttons = GetElementsByClassname( menu, "CoopCustomMapSelectClass" )
	if ( buttons.len() > 0 )
		buttons[0].SetFocused()
}

function SetCoopCreateAMatchMapname( mapName )
{
	file.CoopCustomMapLabel.SetText( GetMapDisplayName( mapName ) )
}
Globalize( SetCoopCreateAMatchMapname )
function CreateAMatchMapVarChanged()
{
	SetCoopCreateAMatchMapname( GetPrivateMatchMapNameForEnum( level.ui.privatematch_map ) )
}

function SetLabelMatchIsPrivate( isPrivate )
{
	if ( isPrivate )
	{
		file.CoopCustomIsOpenToPublicLabel.SetText( "#NO" )
		file.CoopCustomIsOpenToPublicLabel.SetColor( 220, 110, 100 )

		if ( GetPartyMembers().len() < 3 )
			ShowLowpopWarning()
	}
	else
	{
		file.CoopCustomIsOpenToPublicLabel.SetText( "#YES" )
		file.CoopCustomIsOpenToPublicLabel.SetColor( 70, 220, 90 )
			HideLowpopWarning()
	}
}
function CreateAMatchIsPrivateVarChanged()
{
	this.SetLabelMatchIsPrivate( level.ui.createamatch_isPrivate )
}

function OnPlayerConnectOrLeave_CoopPartyCustomMenu( menu )
{
	if ( level.ui.createamatch_isPrivate && (GetPartyMembers().len() < 3) )
		ShowLowpopWarning()
	else
		HideLowpopWarning()
}
Globalize( OnPlayerConnectOrLeave_CoopPartyCustomMenu )

function CoopCustomChooseMapButton_Activate( button )
{
	local partySize = GetPartyMembers().len()
	if ( partySize > 4 )
	{
		CloseTopMenu()
		CloseTopMenu()
		return
	}

	local handlerFunc = AdvanceMenuEventHandler( GetMenu( "MapsMenu" ) )
	handlerFunc( button )
}


function CoopCustomIsOpenToPublicButton_Activate( button )
{
	local partySize = GetPartyMembers().len()
	if ( partySize > 4 )
	{
		CloseTopMenu()
		CloseTopMenu()
		return
	}

	local newValue = !level.ui.createamatch_isPrivate
	printt( "Requesting isPrivate to be:", newValue )
	ClientCommand( "CoopSetIsPrivate " + (newValue ? "1" : "0") )
	SetLabelMatchIsPrivate( newValue )
}


function CoopCustomLaunchButton_Activate( button )
{
	local partySize = GetPartyMembers().len()
	if ( partySize > 4 )
	{
		CloseTopMenu()
		CloseTopMenu()
		return
	}

	ClientCommand( "match_playlist coop" )
	ClientCommand( "StartCoopCustomMatchSearch" )
	CloseTopMenu()
	CloseTopMenu()
	ShowMatchConnectDialog()
}

function ShowLowpopWarning()
{
	file.CoopCustomLowpopBackground.SetVisible( true )
	file.CoopCustomLowpopWarningTitle.SetVisible( true )
	file.CoopCustomLowpopWarningText.SetVisible( true )
}

function HideLowpopWarning()
{
	file.CoopCustomLowpopBackground.SetVisible( false )
	file.CoopCustomLowpopWarningTitle.SetVisible( false )
	file.CoopCustomLowpopWarningText.SetVisible( false )
}

function OnCloseCoopPartyCustomMenu( menu )
{
	if ( IsConnected() )
		UpdateTeamInfo( GetMenu( "LobbyMenu" ), GetTeam() )	
}


