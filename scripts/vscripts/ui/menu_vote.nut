
function main()
{
	Globalize( InitVoteMenu )
	Globalize( OnOpenVoteMenu )
	Globalize( OnCloseVoteMenu )

	RegisterSignal( "OnCloseVoteMenu" )
}

function InitVoteMenu( menu )
{
	SetupButton( menu.GetChild( "BtnKickPlayer" ), "#VOTETYPE_KICK_DESC" )
	SetupButton( menu.GetChild( "BtnMapChange" ), "#VOTETYPE_CHANGE_LEVEL_DESC" )
	SetupButton( menu.GetChild( "BtnNextMap" ), "#VOTETYPE_NEXT_LEVEL_DESC" )
	SetupButton( menu.GetChild( "BtnNextMode" ), "#VOTETYPE_NEXT_GAMEMODE_DESC" )
	SetupButton( menu.GetChild( "BtnTeamScramble" ), "#VOTETYPE_SCRAMBLE_DESC" )
	SetupButton( menu.GetChild( "BtnToggleAlltalk" ), "#VOTETYPE_ALLTALK_DESC" )
	SetupButton( menu.GetChild( "BtnRestartMatch" ), "#VOTETYPE_RESTART_MATCH_DESC" )

	AddEventHandlerToButtonClass( menu, "VoteTypeButtonClass", UIE_CLICK, VoteTypeButtonClass_Clicked )
	AddEventHandlerToButtonClass( menu, "PCFooterButtonClass", UIE_GET_FOCUS, PCFooterButtonClass_Focused )
}

function OnOpenVoteMenu( menu )
{
	thread SetVotetypeAvailability( menu )
}

function OnCloseVoteMenu( menu )
{
	Signal( uiGlobal.signalDummy, "OnCloseVoteMenu" )
}

function SetVotetypeAvailability( menu )
{
	EndSignal( uiGlobal.signalDummy, "OnCloseVoteMenu" )

	local buttons = GetElementsByClassname( menu, "VoteTypeButtonClass" )
	while ( 1 )
	{
		foreach ( button in buttons )
		{
			local buttonID = button.GetScriptID().tointeger()

			if ( !CanCreateVoteOfType( buttonID, null ) )
				button.SetLocked( true )
			else
				button.SetLocked( false )
		}

		wait 1.0
	}
}

function VoteTypeButtonClass_Clicked( button )
{
	if ( button.IsLocked() )
		return

	local buttonID = button.GetScriptID().tointeger()

	if ( VoteTypeNeedsTarget( buttonID ) )
	{
		uiGlobal.selectedVote = buttonID
		AdvanceMenu( GetMenu( "VoteTargetMenu" ) )
	}
	else
	{
		ClientCommand( "StartVote " + buttonID )
		CloseAllInGameMenus()
	}
}

function PCFooterButtonClass_Focused( button )
{
	local menu = GetMenu( "VoteMenu" )
	SetElementsTextByClassname( menu, "MenuItemDescriptionClass", "" )
}