
const NUM_EOG_CHALLENGE_BOXES = 6

function GetContentScaleFactor( menu )
{
	local screenSize = menu.GetSize()
	local scaleFactor = {}
	scaleFactor[0] <- screenSize[0].tofloat() / 860.0
	scaleFactor[1] <- screenSize[1].tofloat() / 480.0
	return scaleFactor
}

function ContentScaledX( val )
{
	return (val * GetContentScaleFactor( GetMenu( "MainMenu" ) )[0])
}


function ContentScaledY( val )
{
	return (val * GetContentScaleFactor( GetMenu( "MainMenu" ) )[1])
}


const LOBBY_BACKGROUND_DEFAULT = "../ui/menu/common/menu_background_neutral"
const LOBBY_BACKGROUND_IMC = "../ui/menu/common/menu_background_imc"
const LOBBY_BACKGROUND_MILITIA = "../ui/menu/common/menu_background_militia"

s_lobbyBackgrounds <- [
	LOBBY_BACKGROUND_IMC,
	LOBBY_BACKGROUND_MILITIA
]
const BACKGROUND_COUNT = 2

function GetMatchLobbyBackground()
{
	if ( IsPrivateMatch() )
		return LOBBY_BACKGROUND_DEFAULT

	if ( IsCoopMatch() )
		return LOBBY_BACKGROUND_MILITIA

	local index = uiGlobal.matchLobbyBackgroundIndex;
	if ( index < 0 )
		return LOBBY_BACKGROUND_DEFAULT

	return s_lobbyBackgrounds[index]
}

function UpdateMatchLobbyBackgroundSelection( type )
{
	if ( type != eLobbyType.MATCH )
		return

	local curIndex = uiGlobal.matchLobbyBackgroundIndex
	if ( curIndex < 0 )
		curIndex = RandomInt( BACKGROUND_COUNT )

	uiGlobal.matchLobbyBackgroundIndex = ((curIndex + 1) % BACKGROUND_COUNT)
}

function GetLobbyBackgroundImage()
{
	Assert( IsConnected() )

	local menuName = ""
	if ( uiGlobal.activeMenu != null )
		menuName = uiGlobal.activeMenu.GetName()

	local image = LOBBY_BACKGROUND_DEFAULT
	if ( (GetLobbyTypeScript() == eLobbyType.MATCH) )
		image = GetMatchLobbyBackground()

	// Special menu overwrites
	switch( menuName )
    {
	    case "BlackMarketMainMenu":
	    case "BlackMarketMenu":
		    image = "../ui/menu/common/menu_background_blackMarket"
			break
		case "RankedPlayMenu":
		case "RankedModesMenu":
		case "RankedTiersMenu":
		case "RankedSeasonsMenu":
			image = "../ui/menu/rank_menus/ranked_FE_background"
			break
    	case "CoopPartyMenu":
    	case "CoopPartyCustomMenu":
    		image = LOBBY_BACKGROUND_MILITIA
    		break
	}

	// Menu should use blurry version?
	switch( menuName )
	{
		case "EditPilotLoadoutsMenu":
		case "EditPilotLoadoutMenu":
		case "EditTitanLoadoutsMenu":
		case "EditTitanLoadoutMenu":
		case "EOG_XP":
		case "EOG_Coins":
		case "EOG_MapStars":
		case "EOG_Unlocks":
		case "EOG_Challenges":
		case "EOG_Coop":
		case "EOG_Scoreboard":
		case "EOG_Ranked":
		case "OptionsMenu":
		case "MouseKeyboardControlsMenu":
		case "GamepadControlsMenu":
		case "MouseKeyboardBindingsMenu":
		case "AdvancedVideoSettingsMenu":
		case "AudioSettingsMenu":
		case "GamepadLayoutMenu":
			image += "_blur"
			break
	}

	return image
}

function GetLobbyTeamImage( team )
{
	Assert( IsConnected() )

	if ( !GetLobbyTeamsShowAsBalanced() )
		return null

	if ( GetLobbyTypeScript() == eLobbyType.MATCH || GetLobbyTypeScript() == eLobbyType.PRIVATE_MATCH )
		return GetTeamImage( team )

	return null
}

function GetLobbyTeamName( team )
{
	Assert( IsConnected() )

	if ( !GetLobbyTeamsShowAsBalanced() )
		return null

	if ( GetLobbyTypeScript() == eLobbyType.MATCH || GetLobbyTypeScript() == eLobbyType.PRIVATE_MATCH )
		return GetTeamName( team )

	return null
}

function GetTeamImage( team )
{
	Assert( team == TEAM_IMC || team == TEAM_MILITIA )

	if ( team == TEAM_IMC )
		return "../ui/scoreboard_imc_logo"
	else
		return "../ui/scoreboard_mcorp_logo"
}

function GetTeamName( team )
{
	Assert( team == TEAM_IMC || team == TEAM_MILITIA )

	if ( team == TEAM_IMC )
		return "#TEAM_IMC"
	else
		return "#TEAM_MCOR"
}

function RefreshPersistentFunc( func )
{
	for ( local i = 0; i < 5; i++ )
	{
		// cause who knows when persistent data changes
		delaythread( i * 0.1 ) RunFuncWithConnectedCheck( func )
	}
}

function RunFuncWithConnectedCheck( func )
{
	if ( !IsConnected() )
		return
	func()
}

function GetActiveLevel()
{
	// The level load callbacks overlap with the level init/shutdown callbacks, so we track each one separately.
	if ( uiGlobal.loadedLevel )
		return uiGlobal.loadedLevel
	else
		return uiGlobal.loadingLevel
}

function HandleLockedMenuItem( menu, button, hideTip = false )
{
	local elements = GetElementsByClassname( menu, "HideWhenLocked" )
	local buttonTooltip = menu.GetChild( "ButtonTooltip" )
	//local buttonTooltip = GetElementsByClassname( menu, "ButtonTooltip" )[0]
	local toolTipLabel = buttonTooltip.GetChild( "Label" )
	if ( "ref" in button.s && button.s.ref != null && IsItemLocked( button.s.ref ) && !hideTip )
	{
		foreach( elem in elements )
			elem.Hide()

		switch( button.s.ref )
		{
			case "pilot_custom_loadout_6":
			case "titan_custom_loadout_6":
			case "pilot_custom_loadout_8":
			case "titan_custom_loadout_8":
			case "pilot_custom_loadout_10":
			case "titan_custom_loadout_10":
			case "pilot_custom_loadout_12":
			case "titan_custom_loadout_12":
			case "pilot_custom_loadout_14":
			case "titan_custom_loadout_14":
			case "pilot_custom_loadout_16":
			case "titan_custom_loadout_16":
			case "pilot_custom_loadout_18":
			case "titan_custom_loadout_18":
				toolTipLabel.SetText( "#UNLOCKED_BY_PLAYING_GAMEMODE", UNLOCK_GAMEMODE_SLOT_1_VALUE )
				break

			case "pilot_custom_loadout_7":
			case "titan_custom_loadout_7":
			case "pilot_custom_loadout_9":
			case "titan_custom_loadout_9":
			case "pilot_custom_loadout_11":
			case "titan_custom_loadout_11":
			case "pilot_custom_loadout_13":
			case "titan_custom_loadout_13":
			case "pilot_custom_loadout_15":
			case "titan_custom_loadout_15":
			case "pilot_custom_loadout_17":
			case "titan_custom_loadout_17":
			case "pilot_custom_loadout_19":
			case "titan_custom_loadout_19":
				toolTipLabel.SetText( "#UNLOCKED_BY_PLAYING_GAMEMODE", UNLOCK_GAMEMODE_SLOT_2_VALUE )
				break

			default:
				toolTipLabel.SetText( "#UNLOCKED_AT_LEVEL", unlockLevels[button.s.ref], "" )
				break
		}

		local buttonPos = button.GetAbsPos()
		local buttonHeight = button.GetHeight()
		local tooltipHeight = buttonTooltip.GetHeight()
		local yOffset = ( tooltipHeight - buttonHeight ) / 2.0

		buttonTooltip.SetPos( buttonPos[0] + button.GetWidth() * 0.9, buttonPos[1] - yOffset )
		buttonTooltip.Show()

		return true
	}
	else
	{
		foreach( elem in elements )
			elem.Show()
		buttonTooltip.Hide()
	}
	return false
}

function GetElementsByClassnameForMenus( classname, menus )
{
	local elements = []

	foreach ( menu in menus )
		elements.extend( GetElementsByClassname( menu, classname ) )

	return elements
}

function TeamIDToSmartGlassString( team )
{
	if ( team == TEAM_IMC )
		return "imc"
	if ( team == TEAM_MILITIA )
		return "militia"
	return "unassigned"
}

function WaitFrameOrUntilLevelLoaded()
{
	wait 0

	while ( uiGlobal.loadedLevel == null )
		wait 0
}

function IsPlayerAlone()
{
	local myTeam = GetTeam()
	local enemyTeam = GetEnemyTeam( myTeam )

	if ( GetTeamSize( myTeam ) == 1 && GetTeamSize( enemyTeam ) == 0 )
		return true

	return false
}

function IsMyPartyAlone()
{
	local myTeam = GetTeam()
	local enemyTeam = GetEnemyTeam( myTeam )

	if ( GetTeamSize( enemyTeam ) || ( GetPartyMembers().len() != GetTeamSize( myTeam ) ) )
		return false

	return true
}

function PartyHasMembers()
{
	if ( GetPartyMembers().len() > 1 )
		return true

	return false
}

function GetGameModeDisplayName( mode )
{
	return GAMETYPE_TEXT[ mode ]
}

function GetGameModeDisplayDesc( mode )
{
	return GAMETYPE_DESC[ mode ]
}

function GetGameModeDisplayImage( mode )
{
	return GAMETYPE_ICON[ mode ]
}

function ShouldShowEOGSummary()
{
	if ( level.ui.showGameSummary == false )
		return false

	if ( uiGlobal.viewedGameSummary == true )
		return false

	if ( uiGlobal.previousLevel == null || uiGlobal.previousLevel == "mp_lobby" || uiGlobal.previousLevel == "mp_npe" )
		return false

	SmartGlass_SendEvent( "GameSummary", "", "", "" )
	return true
}

function ShouldJumpToCoopPartyMenu()
{
    if ( IsPrivateMatch() )
        return false
	if ( (uiGlobal.previousPlaylist == null) || (uiGlobal.previousPlaylist != "coop") )
		return false
	if ( (uiGlobal.previousLevel == null) || (uiGlobal.previousLevel == "mp_lobby") || (uiGlobal.previousLevel == "mp_npe") )
		return false
	if ( GetLobbyTypeScript() == eLobbyType.MATCH )
		return false
	if ( !AmIPartyLeader() )
		return false
	return true
}

function GetCurrentPlaylistVarFloat( val, useVal )
{
	local result = GetCurrentPlaylistVarOrUseValue( val, useVal + "" )
	if ( result == null || result == "" )
		return 0

	return result.tofloat()
}

function PlayerProgressionAllowed( player = null )
{
	if ( IsPrivateMatch() )
		return false
	return true
}

function UpdateStarPanelData( panel, mapName, modeName )
{
	local gameModeListCount = 7
	local numStars = 3

	// Update game modes and stars
	local numGameModes = PersistenceGetEnumCount( "gameModesWithStars" )
	Assert( numGameModes <= gameModeListCount )
	for ( local i = 0 ; i < gameModeListCount ; i++ )
	{
		local infoPanel = panel.GetChild( "Row" + i )

		local stars = []
		for ( local k = 0 ; k < numStars ; k++ )
			stars.append( infoPanel.GetChild( "Star" + k ) )

		local modeNameLabel = infoPanel.GetChild( "ModeName" )
		local modeReqLabel = infoPanel.GetChild( "ModeRequirements" )
		local bestLabel = infoPanel.GetChild( "Best" )
		local highlight = infoPanel.GetChild( "Highlight" )
		local icon = infoPanel.GetChild( "ScoreTypeIcon" )

		if ( i < numGameModes )
		{
			// Update
			local iterationGameMode = PersistenceGetEnumItemNameForIndex( "gameModesWithStars", i )

			modeNameLabel.SetText( GAMETYPE_TEXT[ iterationGameMode ] )

			local scoreReqs = GetStarScoreRequirements( iterationGameMode, mapName )
			modeReqLabel.SetText( "#MAP_STARS_REQ_VALUES", scoreReqs[0], scoreReqs[1], scoreReqs[2] )

			bestLabel.SetText( GetStarBestScores( mapName, iterationGameMode ).now.tostring() )

			if ( iterationGameMode == modeName )
			{
				highlight.Show()
				modeNameLabel.SetColor( [204, 234, 255, 255] )
				modeReqLabel.SetColor( [204, 234, 255, 255] )
				bestLabel.SetColor( [204, 234, 255, 255] )
			}
			else
			{
				highlight.Hide()
				modeNameLabel.SetColor( [204, 234, 255, 128] )
				modeReqLabel.SetColor( [204, 234, 255, 128] )
				bestLabel.SetColor( [204, 234, 255, 128] )
			}

			icon.SetImage( GetMapStarScoreImage( iterationGameMode ) )

			local starCount = GetStarsForScores( mapName, iterationGameMode )
			for ( local k = 0 ; k < numStars ; k++ )
			{
				if ( k + 1 <= starCount.now )
					stars[k].SetImage( MAP_STARS_IMAGE_FULL )
				else
					stars[k].SetImage( MAP_STARS_IMAGE_EMPTY )
			}

			infoPanel.Show()
		}
		else
		{
			// Hide
			infoPanel.Hide()
		}
	}
}

function UpdateSelectedMapStarData( menu, mapName, gameMode )
{
	local numStars = 3

	local starCount = GetStarsForScores( mapName, gameMode )

	for ( local k = 0 ; k < numStars ; k++ )
	{
		local star = menu.GetChild( "MapStar" + k )

		star.SetColor( 255, 255, 255 )	// reset the color
		if ( k + 1 <= starCount.now )
		{
			star.SetImage( MAP_STARS_IMAGE_FULL )
			star.Show()
		}
		else
		{
			star.SetImage( MAP_STARS_IMAGE_EMPTY )
			star.Show()
		}
	}
}

function GetMapStarScoreImage( gameMode )
{
	switch( gameMode )
	{
		case "tdm":
			return SCOREBOARD_MATERIAL_PILOT_KILLS
		case "cp":
			return SCOREBOARD_MATERIAL_HARDPOINT
		case "at":
			return SCOREBOARD_MATERIAL_VICTORY_CONTRIBUTION
		case "ctf":
			return SCOREBOARD_MATERIAL_FLAG_CAPTURE
		case "lts":
			return SCOREBOARD_MATERIAL_TITAN_KILLS
		case "mfd":
			return SCOREBOARD_MATERIAL_MARKED_FOR_DEATH_TARGET_KILLS
		case "coop":
			return SCOREBOARD_MATERIAL_VICTORY_CONTRIBUTION
		default:
			Assert( 0 , "Unhandled game mode for map stars" )
	}
}

// this has some drawbacks, if someone has the same name as the host their UI will act like their host.
// this doesn't matter on the server since we check index 0 but we can't getplayerarray in ui
::AmIPartyLeader__ <- AmIPartyLeader
function AmIPartyLeader()
{
    if ( !IsDelta() )
        return ::AmIPartyLeader__()

    if ( level.ui.isDedicatedServer )
        return false

    local privateMatchLeaderNameHash = level.ui.listenHostUsernameHash

    if ( privateMatchLeaderNameHash == null )
        return false

    local myName = GetConVarString( "name" )

	local cleanedName = StringReplaceAll( myName, "#", "" )

	if( cleanedName.len() > 32 )
		cleanedName = cleanedName.slice( 0, 32 )

    if ( FNV1A( cleanedName ) == privateMatchLeaderNameHash )
        return true

    return false
}