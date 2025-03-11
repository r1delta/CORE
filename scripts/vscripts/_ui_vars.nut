class UIValueInterface
{
	function _get( key )
	{
		return ::GetUIVar( key )
	}

	function _set( key, value )
	{
		Assert( ::IsServer() )
		return ::SetUIVar( key, value )
	}
}

level.ui <- UIValueInterface()

_uiVars <- {}
_uiEntityVars <- {}
_uiVarHandles <- {}
_nextUIVarIndex <- 0
_uiVarChangeCallbacks <- {}

function RegisterUIVar( varName, value )
{
	Assert( !(varName in _uiVars ) )

	if ( IsServer() )
		_uiVarHandles[varName] <- _nextUIVarIndex
	else
		_uiVarHandles[_nextUIVarIndex] <- varName

	_nextUIVarIndex++

	_uiVars[varName] <- value
}

function GetUIVar( varName )
{
	Assert( varName in _uiVars )

	return _uiVars[varName]
}

function SetUIVar( varName, value )
{
	Assert( IsServer() )
	Assert( varName in _uiVars )
	Assert( typeof value != "string" )

	if ( _uiVars[varName] == value )
		return

	_uiVars[varName] = value

	// Run change callback if one exists
	thread UIVarChangedCallbacks( varName )

	// Update the var on all clients
	local players = GetPlayerArray()
	foreach ( player in players )
	{
		if ( !player.s.clientScriptInitialized )
			continue

		Remote.CallFunction_UI( player, "ServerCallback_SetUIVar", _uiVarHandles[varName], value )
	}
}

function ServerCallback_SetUIVar( varHandle, value )
{
	local varName = _uiVarHandles[varHandle]

	_uiVars[varName] = value

	if ( !(varName in _uiVarChangeCallbacks) )
		return

	foreach ( callbackFunc in _uiVarChangeCallbacks[varName] )
		callbackFunc()
}

function RegisterUIVarChangeCallback( varName, callbackFunc )
{
	if ( !(varName in _uiVarChangeCallbacks) )
		_uiVarChangeCallbacks[varName] <- []

	_uiVarChangeCallbacks[varName].append( callbackFunc.bindenv( this ) )
}

function UIVarChangedCallbacks( varName )
{
	// Run change callback if one exists
	if ( !( varName in _uiVarChangeCallbacks ) )
		return

	foreach ( callbackFunc in _uiVarChangeCallbacks[varName] )
		callbackFunc()
}

function SyncUIVars( player )
{
	Assert( IsServer() )

	foreach ( varName, value in _uiVars )
	{
		Remote.CallFunction_UI( player, "ServerCallback_SetUIVar", _uiVarHandles[varName], value )
	}
}

RegisterUIVar( "gameStartTime", null )
RegisterUIVar( "gameStartTimerComplete", false )
RegisterUIVar( "nextMapModeComboIndex", null )
RegisterUIVar( "trainingModule", eTrainingModules.BEDROOM )
RegisterUIVar( "disableDev", null )
RegisterUIVar( "showGameSummary", false )
RegisterUIVar( "badRepPresent", false )
RegisterUIVar( "privatematch_map", ePrivateMatchMaps.mp_fracture )
RegisterUIVar( "privatematch_mode", eGameModes.ATTRITION_ID )
RegisterUIVar( "privatematch_starting", ePrivateMatchStartState.NOT_READY )
RegisterUIVar( "coopLobbyMap", null ) // ePrivateMatchMaps.mp_fracture
RegisterUIVar( "createamatch_isPrivate", false )
RegisterUIVar( "penalizeDisconnect", true )
RegisterUIVar( "rankedPenalizeDisconnect", false )
RegisterUIVar( "rankEnableMode", eRankEnabledModes.NOT_ENOUGH_PEOPLE )

