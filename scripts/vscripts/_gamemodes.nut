level.gameModeDefs <- {}

// TODO: scoreboards

/*************************************************************
	Setters
*************************************************************/

function GameMode_Create( gameModeName )
{
	Assert( !(gameModeName in level.gameModeDefs), "Gametype already defined!" )

	level.gameModeDefs[gameModeName] <-
	{
		name = gameModeName,
		name_localized = "Undefined Game Mode",
		desc_localized = "Undefined Game Mode Description",
		desc_attack = ""
		desc_defend = ""
		gameModeAnnoucement = null,
		gameModeAttackAnnoucement = null,
		gameModeDefendAnnoucement = null,
		icon = "../ui/menu/playlist/classic",
		serverScripts = [],
		clientScripts = [],
		sharedScripts = [],
		sharedDialogueScripts = [],
		defaultScoreLimit = 100,
		defaultTimeLimit = 10,
		defaultRoundScoreLimit = 5,
		defaultRoundTimeLimit = 5
	}

	return level.gameModeDefs[gameModeName]
}


function GameMode_SetName( gameModeName, nameText )
{
	Assert( gameModeName in level.gameModeDefs, "No MP Gametype specified in _settings.nut" )
	level.gameModeDefs[gameModeName].name_localized = nameText
}

function GameMode_SetGameModeAnnouncement( gameModeName, gameModeAnnoucement ) //Note: Still need to register the conversation, probably in a _gamemode_dialogue.nut file. Look at _gamemode_mfd_dialogue.nut for an example
{
	Assert( gameModeName in level.gameModeDefs, "No MP Gametype specified in _settings.nut" )
	level.gameModeDefs[gameModeName].gameModeAnnoucement = gameModeAnnoucement
}

function GameMode_SetGameModeAttackAnnouncement( gameModeName, gameModeAttackAnnoucement ) //Note: Still need to register the conversation, probably in a _gamemode_dialogue.nut file. Look at _capture_the_titan_dialogue.nut for an example
{
	Assert( gameModeName in level.gameModeDefs, "No MP Gametype specified in _settings.nut" )
	level.gameModeDefs[gameModeName].gameModeAttackAnnoucement = gameModeAttackAnnoucement
}


function GameMode_SetGameModeDefendAnnouncement( gameModeName, gameModeDefendAnnoucement )
{
	Assert( gameModeName in level.gameModeDefs, "No MP Gametype specified in _settings.nut" ) //Note: Still need to register the conversation, probably in a _gamemode_dialogue.nut file. Look at _capture_the_titan_dialogue.nut for an example
	level.gameModeDefs[gameModeName].gameModeDefendAnnoucement = gameModeDefendAnnoucement
}


function GameMode_SetDesc( gameModeName, descText )
{
	Assert( gameModeName in level.gameModeDefs, "No MP Gametype specified in _settings.nut" )
	level.gameModeDefs[gameModeName].desc_localized = descText
}

function GameMode_SetAttackDesc( gameModeName, descText )
{
	Assert( gameModeName in level.gameModeDefs, "No MP Gametype specified in _settings.nut" )
	level.gameModeDefs[gameModeName].desc_attack = descText
}

function GameMode_SetDefendDesc( gameModeName, descText )
{
	Assert( gameModeName in level.gameModeDefs, "No MP Gametype specified in _settings.nut" )
	level.gameModeDefs[gameModeName].desc_defend = descText
}


function GameMode_SetIcon( gameModeName, icon )
{
	Assert( gameModeName in level.gameModeDefs, "No MP Gametype specified in _settings.nut" )
	level.gameModeDefs[gameModeName].icon = icon
}


function GameMode_AddServerScript( gameModeName, scriptName )
{
	Assert( gameModeName in level.gameModeDefs, "No MP Gametype specified in _settings.nut" )
//	Assert( ScriptExists( scriptName ) )
	level.gameModeDefs[gameModeName].serverScripts.append( scriptName )
}


function GameMode_AddClientScript( gameModeName, scriptName )
{
	Assert( gameModeName in level.gameModeDefs, "No MP Gametype specified in _settings.nut" )
//	Assert( ScriptExists( scriptName ) )
	level.gameModeDefs[gameModeName].clientScripts.append( scriptName )
}


function GameMode_AddSharedScript( gameModeName, scriptName )
{
	Assert( gameModeName in level.gameModeDefs, "No MP Gametype specified in _settings.nut" )
//	Assert( ScriptExists( scriptName ) )
	level.gameModeDefs[gameModeName].sharedScripts.append( scriptName )
}

function GameMode_AddSharedDialogueScript( gameModeName, scriptName )
{
	Assert( gameModeName in level.gameModeDefs, "No MP Gametype specified in _settings.nut" )
//	Assert( ScriptExists( scriptName ) )
	level.gameModeDefs[gameModeName].sharedDialogueScripts.append( scriptName )
}

function GameMode_SetDefaultScoreLimits( gameModeName, scoreLimit, roundScoreLimit )
{
	Assert( gameModeName in level.gameModeDefs, "No MP Gametype specified in _settings.nut" )
	level.gameModeDefs[gameModeName].defaultScoreLimit = scoreLimit
	level.gameModeDefs[gameModeName].defaultRoundScoreLimit = roundScoreLimit
}

function GameMode_SetDefaultTimeLimits( gameModeName, timeLimit, roundTimeLimit )
{
	Assert( gameModeName in level.gameModeDefs, "No MP Gametype specified in _settings.nut" )
	level.gameModeDefs[gameModeName].defaultTimeLimit = timeLimit
	level.gameModeDefs[gameModeName].defaultRoundTimeLimit = roundTimeLimit
}

/*************************************************************
	Getters
*************************************************************/

function GameMode_GetScoreLimit( gameModeName )
{
	Assert( gameModeName in level.gameModeDefs, "No MP Gametype specified in _settings.nut" )
	return GetCurrentPlaylistVarInt( gameModeName + "_scorelimit", level.gameModeDefs[gameModeName].defaultScoreLimit )
}


function GameMode_GetRoundScoreLimit( gameModeName )
{
	Assert( gameModeName in level.gameModeDefs, "No MP Gametype specified in _settings.nut" )
	return GetCurrentPlaylistVarInt( gameModeName + "_roundscorelimit", level.gameModeDefs[gameModeName].defaultRoundScoreLimit )
}


function GameMode_GetTimeLimit( gameModeName )
{
	Assert( gameModeName in level.gameModeDefs, "No MP Gametype specified in _settings.nut" )
	return GetCurrentPlaylistVarInt( gameModeName + "_timelimit", level.gameModeDefs[gameModeName].defaultTimeLimit )
}


function GameMode_GetRoundTimeLimit( gameModeName )
{
	Assert( gameModeName in level.gameModeDefs, "No MP Gametype specified in _settings.nut" )
	return GetCurrentPlaylistVarInt( gameModeName + "_roundtimelimit", level.gameModeDefs[gameModeName].defaultRoundTimeLimit )
}

function GameMode_GetGameModeAnnouncement( gameModeName )
{
	Assert( gameModeName in level.gameModeDefs, "No MP Gametype specified in _settings.nut" )
	return level.gameModeDefs[gameModeName].gameModeAnnoucement
}

function GameMode_GetGameModeAttackAnnouncement( gameModeName )
{
	Assert( gameModeName in level.gameModeDefs, "No MP Gametype specified in _settings.nut" )
	return level.gameModeDefs[gameModeName].gameModeAttackAnnoucement
}

function GameMode_GetGameModeDefendAnnouncement( gameModeName )
{
	Assert( gameModeName in level.gameModeDefs, "No MP Gametype specified in _settings.nut" )
	return level.gameModeDefs[gameModeName].gameModeDefendAnnoucement
}

function GameMode_GetDesc( gameModeName )
{
	Assert( gameModeName in level.gameModeDefs, "No MP Gametype specified in _settings.nut" )
	return level.gameModeDefs[gameModeName].desc_localized
}

function GameMode_GetAttackDesc( gameModeName )
{
	Assert( gameModeName in level.gameModeDefs, "No MP Gametype specified in _settings.nut" )
	return level.gameModeDefs[gameModeName].desc_attack
}

function GameMode_GetDefendDesc( gameModeName )
{
	Assert( gameModeName in level.gameModeDefs, "No MP Gametype specified in _settings.nut" )
	return level.gameModeDefs[gameModeName].desc_defend
}


/*************************************************************

*************************************************************/
function GameMode_RunServerScripts( gameModeName )
{
	Assert( gameModeName in level.gameModeDefs, "No MP Gametype specified in _settings.nut" )

	foreach ( scriptName in level.gameModeDefs[gameModeName].serverScripts )
	{
		IncludeFile( scriptName )
	}
}


function GameMode_RunClientScripts( gameModeName )
{
	Assert( gameModeName in level.gameModeDefs, "No MP Gametype specified in _settings.nut" )

	foreach ( scriptName in level.gameModeDefs[gameModeName].clientScripts )
	{
		IncludeFile( scriptName )
	}
}


function GameMode_RunSharedScripts( gameModeName )
{
	Assert( gameModeName in level.gameModeDefs, "No MP Gametype specified in _settings.nut" )

	foreach ( scriptName in level.gameModeDefs[gameModeName].sharedScripts )
	{
		IncludeFile( scriptName )
	}
}

function GameMode_RunSharedDialogueScripts( gameModeName )
{
	Assert( gameModeName in level.gameModeDefs, "No MP Gametype specified in _settings.nut" )

	foreach ( scriptName in level.gameModeDefs[gameModeName].sharedDialogueScripts )
	{
		IncludeFile( scriptName )
	}
}


function GameMode_VerifyModes()
{
	foreach ( gameModeName, gameModeData in level.gameModeDefs )
	{
		Assert( gameModeName in gameModesStringToIdMap, "GAMEMODE not defined in gameModesStringToIdMap!" )

		local gameModeId = gameModesStringToIdMap[gameModeName]
		local foundGameModeIdString = false
		foreach ( idString, gameModeEnumId in getconsttable().eGameModes )
		{
			if ( gameModeEnumId != gameModeId )
				continue

			foundGameModeIdString = true
			break
		}
		Assert( foundGameModeIdString, "GAMEMODE not defined properly in eGameModes!" )

		GAMETYPE_TEXT[gameModeName] <- gameModeData.name_localized
		GAMETYPE_DESC[gameModeName] <- gameModeData.desc_localized
		GAMETYPE_ICON[gameModeName] <- gameModeData.icon
		if ( IsClient() )
		{
			PrecacheHUDMaterial( GAMETYPE_ICON[gameModeName] )
		}
	}
}


function GameMode_IsDefined( gameModeName )
{
	return (gameModeName in level.gameModeDefs)
}